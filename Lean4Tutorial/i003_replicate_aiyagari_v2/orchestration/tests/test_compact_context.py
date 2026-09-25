"""Synthetic evidence and mocked models only; no subscription/model calls."""
import sys,json,copy,tempfile,unittest,subprocess,shutil
from pathlib import Path
from unittest.mock import Mock,patch
sys.path.insert(0,str(Path(__file__).resolve().parents[1]))
import orchestrate as o
import gate_context as g
import compact_review as cr
ROOT=Path(__file__).resolve().parents[2]
SHA='a'*64

def verdict(**kw):
    v={'gate_id':'TEST','attempt':1,'snapshot_sha256':SHA,'verdict':'PASS','confidence':'HIGH','requires_human_review':False,'contract_assessments':[{'contract_id':'H12','adequate':True,'assessment':'Exact declared finite integral conclusion is established.'}],'blocking_findings':[],'nonblocking_findings':[],'qualifications':[],'revision_prompt':None,'dimension_assessments':[{'dimension_id':d,'status':'PASS','refs':['contract:H12'],'summary':'The finite integral conclusion matches the assigned contract.'} for d in cr.DIMENSIONS]};v.update(kw);return v

class PolicyTests(unittest.TestCase):
    def setUp(self):
        self.tmp=tempfile.TemporaryDirectory();self.addCleanup(self.tmp.cleanup);self.root=Path(self.tmp.name)
        g.write(self.root/'evidence_aliases.json',{'contract:H12':'contracts.json#H12'})
        self.c=Mock();self.c.config={'max_revisions':2};self.c.project_files.return_value={'f':'hash'}
        self.state={'snapshot_path':str(self.root),'snapshot_sha256':SHA,'reviewed_files':{'f':'hash'},'attempt':1,'revisions':0}
        self.gate={'id':'TEST','contracts':['H12']};self.calls=[]
    def run_reviews(self,*vs):
        values=iter(vs)
        def call(role,prompt,cwd,directory):
            self.calls.append((role,prompt,g.read(directory/'reviewer_invocation.json')))
            value=next(values)
            if isinstance(value,Exception):raise value
            return json.dumps(value) if isinstance(value,dict) else value
        self.c.model_run.side_effect=call
        return cr.adjudicate(self.c,self.gate,self.state,self.root,'INDEPENDENT BASE PROMPT')
    def test_initial_high(self):self.run_reviews(verdict());self.assertEqual(self.calls[0][2]['effort'],'high')
    def test_clean_pass_no_xhigh(self):self.run_reviews(verdict());self.assertEqual(len(self.calls),1)
    def test_high_revise_adjudicates(self):self.run_reviews(verdict(verdict='REVISE',revision_prompt='Repair finite integral proof.'),verdict());self.assertEqual(self.calls[-1][2]['effort'],'xhigh')
    def test_high_block_adjudicates(self):self.run_reviews(verdict(verdict='BLOCK'),verdict());self.assertEqual(len(self.calls),2)
    def test_high_uncertain_adjudicates(self):
        v=verdict();v['dimension_assessments'][1].update(status='UNCERTAIN',summary='The supplied finite integral argument does not establish the required boundary case because a dominating bound is missing.')
        self.run_reviews(v,verdict());self.assertEqual(len(self.calls),2)
    def test_low_confidence_adjudicates(self):self.run_reviews(verdict(confidence='LOW'),verdict());self.assertEqual(len(self.calls),2)
    def test_human_flag_adjudicates(self):self.run_reviews(verdict(requires_human_review=True),verdict());self.assertEqual(len(self.calls),2)
    def test_xhigh_pass_operative(self):self.run_reviews(verdict(verdict='BLOCK'),verdict());self.assertEqual(self.state['operative_reviewer']['effort'],'xhigh')
    def test_xhigh_revise_existing_policy(self):
        raw,_=self.run_reviews(verdict(verdict='BLOCK'),verdict(verdict='REVISE',revision_prompt='Repair same gate.'));self.assertEqual(o.decision(json.loads(raw),self.gate,1,SHA,True),'READY_TO_EXECUTE')
    def test_xhigh_block_human_stop(self):
        raw,_=self.run_reviews(verdict(verdict='BLOCK'),verdict(verdict='BLOCK'));self.assertEqual(o.decision(json.loads(raw),self.gate,1,SHA,True),'HUMAN_STOP')
    def test_no_executor_revision_increment(self):self.run_reviews(verdict(verdict='BLOCK'),verdict());self.assertEqual(self.state['revisions'],0)
    def test_no_high_prose_in_xhigh(self):self.run_reviews(verdict(verdict='BLOCK',qualifications=['SECRET INITIAL PROSE']),verdict());self.assertEqual(self.calls[0][1],self.calls[1][1]);self.assertNotIn('SECRET',self.calls[1][1])
    def test_schema_retry_then_adjudicate(self):self.run_reviews('{','{',verdict());self.assertEqual([c[2]['effort'] for c in self.calls],['high','high','xhigh'])
    def test_schema_retry_clean_pass(self):self.run_reviews('{',verdict());self.assertEqual(len(self.calls),2);self.assertEqual(self.state['operative_reviewer']['effort'],'high')
    def test_malformed_xhigh_stops(self):
        with self.assertRaises(o.Stop):self.run_reviews('{','{','{','{')
        self.assertEqual(len(self.calls),4)
    def test_identity_stops_before_adjudication(self):
        with self.assertRaises(o.Stop):self.run_reviews(verdict(snapshot_sha256='b'*64))
        self.assertEqual(len(self.calls),1)
    def test_infrastructure_stops_no_escalation(self):
        with self.assertRaises(o.Stop):self.run_reviews(o.Stop('MODEL_FAILED_OR_USAGE_LIMIT'))
        self.assertEqual(len(self.calls),1)
    def test_restart_reuses_completed_calls(self):self.run_reviews(verdict(verdict='BLOCK'),verdict());self.run_reviews();self.assertEqual(len(self.calls),2)
    def test_journal_tampering_rejected(self):
        _,directory=self.run_reviews(verdict());(directory/'reviewer_final.json').write_text('{}')
        with self.assertRaises(o.Stop):self.run_reviews()
    def test_mutation_stops(self):
        self.c.project_files.side_effect=[{'f':'hash'},{'f':'changed'}]
        with self.assertRaises(o.Stop):self.run_reviews(verdict())
    def test_all_twenty_required(self):
        v=verdict();v['dimension_assessments'].pop()
        with self.assertRaises(ValueError):cr.dimensions(v)
    def test_concise_pass_accepted(self):cr.dimensions(verdict())
    def test_generic_rejected(self):
        v=verdict();v['dimension_assessments'][0]['summary']='All checks pass.'
        with self.assertRaises(ValueError):cr.dimensions(v)
    def test_fail_requires_substance(self):
        v=verdict();v['dimension_assessments'][0].update(status='FAIL',summary='The required proof is absent.')
        with self.assertRaises(ValueError):cr.dimensions(v)
    def test_qualifications_not_truncated(self):
        q='Mandatory boundary qualification. '*1000;v=verdict(qualifications=[q]);cr.dimensions(v);self.assertEqual(v['qualifications'][0],q)
    def test_reference_must_resolve(self):
        with self.assertRaises(ValueError):cr.dimensions(verdict(),{})
    def test_core_na_rejected(self):
        v=verdict();v['dimension_assessments'][0].update(status='NOT_APPLICABLE',summary='This condition is absent because the synthetic proof does not use the corresponding real integral conversion.')
        with self.assertRaises(ValueError):cr.dimensions(v)
    def test_pass_length_bound(self):
        v=verdict();v['dimension_assessments'][0]['summary']='word '*80
        with self.assertRaises(ValueError):cr.dimensions(v)

    def test_controller_applies_only_operative_revision(self):
        c=o.Controller();c.config={**c.config,'context_version':1,'reviewer_policy_version':1}
        self.state.update(baseline='b'*40,verification_directory='checks',executor_history=[{'outcome':'COMPLETED'}],executor_effort_index=0,executor_invocation_reason='INITIAL')
        outputs=iter([verdict(verdict='REVISE',revision_prompt='High suggestion'),verdict(verdict='REVISE',revision_prompt='XHigh operative repair')])
        with patch.object(c,'verify_snapshot'),patch.object(c,'review_evidence_checks'),patch.object(c,'approved_source_evidence'),patch.object(c,'project_files',return_value={'f':'hash'}),patch.object(c,'save'),patch.object(c,'executor_plan',return_value={'reasoning_effort':'medium'}),patch.object(c,'model_run',side_effect=lambda *args:json.dumps(next(outputs))),patch.object(g,'validate_context',return_value='REVIEW_CONTEXT_COMPLETE'):
            action=c.review_submission(self.gate,self.state,self.root)
        self.assertEqual(action,'READY_TO_EXECUTE');self.assertEqual(self.state['revisions'],1);self.assertEqual(self.state['revision_prompt'],'XHigh operative repair')
    def test_checkpoint_returns_without_preflight_or_model(self):
        import contextlib
        c=o.Controller()
        with patch.object(c,'lock',return_value=contextlib.nullcontext()),patch.object(c,'status',return_value={'status':c.checkpoint}),patch.object(c,'preflight') as preflight,patch.object(c,'model_run') as model:
            self.assertEqual(c.run(),{'status':c.checkpoint});preflight.assert_not_called();model.assert_not_called()

class ContextTests(unittest.TestCase):
    def setUp(self):
        self.tmp=tempfile.TemporaryDirectory();self.addCleanup(self.tmp.cleanup);self.root=Path(self.tmp.name)/'repo';self.root.mkdir()
        def git(*args):return subprocess.check_output(['git',*args],cwd=self.root,text=True,stderr=subprocess.DEVNULL)
        self.git=git;git('init','-q');git('config','user.email','fixture@example.invalid');git('config','user.name','Fixture')
        self.c=Mock();self.c.config={};self.c.root=self.root;self.c.o=ROOT/'orchestration';self.c.runtime=self.root/'tmp_orchestration';self.c.git.side_effect=git
        self.put('Audit.lean','#print axioms T.old\n');self.put('Aiyagari1994/Old.lean','theorem old : True := True.intro\n');git('add','.');git('commit','-qm','baseline');self.baseline=git('rev-parse','HEAD').strip()
        self.contract={'id':'H12','stage':'03','status':'REVIEW_READY','declaration':'T.new','module':'Aiyagari1994/New.lean','assumptions':['BASIC'],'dependencies':['H11'],'sources':['A93'],'source_locator':'A93 printed p. 37 / PDF p. 38'}
        dep={**self.contract,'id':'H11','status':'GREEN','declaration':'T.old','module':'Aiyagari1994/Old.lean','dependencies':[]}
        g.write(self.root/'contracts/theorems.json',{'theorems':[self.contract,dep,{**dep,'id':'UNRELATED'}]});g.write(self.root/'contracts/assumptions.json',{'profiles':{'BASIC':{'exact':'primitive'}}})
        g.write(self.root/'contracts/source_manifest.json',{'sources':[{'id':'A93','sha256':g.sha(b'PDF'),'local_name':'approved.pdf','pdf_pages':45}]});self.put('sources/papers/approved.pdf','PDF')
        self.put('docs/architecture.md','### 4.3 Envelope and Euler conditions\nEXACT ARCHITECTURE.\n');self.put('prompts/03_household_analysis.md','6. Exact approved proof route.\n\n7. Unrelated.\n');self.put('docs/proof_ledger.md','## H12 — Euler\n\n**Status:** REVIEW_READY.\nExact proof.\n')
        self.put('Audit.lean','#check T.new\n#print axioms T.old\n#print axioms T.new\n');self.put('Aiyagari1994/New.lean','namespace T\ntheorem new : True := True.intro\nend T\n')
        self.qual={'qualification_id':'q1','text':'Exact mandatory boundary qualification.'};g.write(self.root/'reports/stage03_accepted_qualifications.json',{'records':[{**self.qual,'acceptance_record':'reviews/prior.json'}]})
        self.b=g.ContextBuilder(self.c);self.interface={'contract_id':'H11','declaration':'T.old','exact_elaborated_signature':'T.old : True','qualifications':['Exact predecessor qualification.']};self.b.interface=Mock(return_value=self.interface)
        self.gate={'id':'TEST','contracts':['H12']};self.ver=self.root/'tmp_orchestration/checks';self.ver.mkdir(parents=True)
        audit="T.new : True\n'T.old' depends on axioms: [propext]\n'T.new' depends on axioms: [propext]\n";(self.ver/'audit.log').write_text(audit)
        checks={}
        for name in ('targeted_build','full_build','audit','contracts','signatures','documentation','transitive_axioms','assert_no_sorry','prohibited_patterns','export_inventory','source_validation','frozen_scope','git_diff_check','new_file_diff_check'):
            p=self.ver/(name+'.log')
            if not p.exists():p.write_text('controller PASS\n')
            checks[name]={'path':str(p),'exit_code':0,'sha256':g.sha(p.read_bytes()),'producer':'controller:'+name}
        g.write(self.ver/'deterministic_summary.json',{'checks':checks});self.dest=Path(self.tmp.name)/'snapshot'
        # PDF extraction tested separately; these fixtures preserve verified full fallback.
        self.extract=patch.object(g.subprocess,'run',wraps=subprocess.run)
    def put(self,name,text):p=self.root/name;p.parent.mkdir(parents=True,exist_ok=True);p.write_text(text)
    def build(self):return g.build_snapshot(self.b,self.gate,self.baseline,self.ver,self.dest)
    def rehash(self):
        m=g.read(self.dest/'snapshot_manifest.json');m['files']={str(p.relative_to(self.dest)):g.sha(p.read_bytes()) for p in self.dest.rglob('*') if p.is_file() and p.name!='snapshot_manifest.json'};g.write(self.dest/'snapshot_manifest.json',m)
    def validate(self):return g.validate_context(self.dest,self.b,self.gate,self.baseline,verification=self.ver)
    def test_exact_contract(self):self.assertEqual(self.b.capsule(self.gate,self.baseline)[0]['assigned_contracts'],[self.contract])
    def test_only_relevant_contract(self):self.assertEqual([x['id'] for x in self.b.capsule(self.gate,self.baseline)[0]['assigned_contracts']],['H12'])
    def test_mandatory_qualifications(self):self.assertEqual(self.b.qualifications()[0]['text'],self.qual['text'])
    def test_provenance(self):self.assertEqual(self.b.capsule(self.gate,self.baseline)[0]['provenance'][0]['sha256'],g.sha((self.root/'contracts/theorems.json').read_bytes()))
    def test_deterministic_capsule(self):self.assertEqual(g.canonical(self.b.capsule(self.gate,self.baseline)),g.canonical(self.b.capsule(self.gate,self.baseline)))
    def test_direct_dependency_interface(self):self.assertEqual(set(self.b.capsule(self.gate,self.baseline)[1]),{'H11'})
    def test_unrelated_dependencies_omitted(self):self.b.capsule(self.gate,self.baseline);self.b.interface.assert_called_once_with('H11')
    def test_signature_exact(self):self.assertEqual(self.b.capsule(self.gate,self.baseline)[1]['H11']['exact_elaborated_signature'],'T.old : True')
    def test_interface_qualification_preserved(self):self.assertEqual(self.b.capsule(self.gate,self.baseline)[1]['H11']['qualifications'],self.interface['qualifications'])
    def test_changed_files_included(self):self.build();self.assertTrue((self.dest/'Aiyagari1994/New.lean').exists())
    def test_unrelated_lean_omitted(self):self.build();self.assertFalse((self.dest/'Aiyagari1994/Old.lean').exists())
    def test_raw_logs_omitted(self):self.build();self.assertEqual(list(self.dest.rglob('*.log')),[])
    def test_compact_summaries_present(self):self.build();self.assertTrue((self.dest/'verification/signatures_summary.json').exists());self.assertEqual(self.validate(),'REVIEW_CONTEXT_COMPLETE')
    def test_missing_dependency_fails(self):self.build();(self.dest/'dependencies/H11.json').unlink();self.rehash();self.assertRaises((ValueError,OSError),self.validate)
    def test_missing_contract_fails(self):self.build();g.write(self.dest/'contracts.json',[]);self.rehash();self.assertRaises(ValueError,self.validate)
    def test_missing_qualification_fails(self):self.build();g.write(self.dest/'predecessor_qualifications.json',[]);self.rehash();self.assertRaises(ValueError,self.validate)
    def test_missing_signature_fails(self):self.build();g.write(self.dest/'verification/signatures_summary.json',{});self.rehash();self.assertRaises(ValueError,self.validate)
    def test_missing_check_fails(self):
        self.build();p=self.dest/'verification/deterministic_summary.json';s=g.read(p);del s['checks']['audit'];g.write(p,s);self.rehash();self.assertRaises(ValueError,self.validate)
    def test_wrong_source_page_fails(self):
        self.build();p=self.dest/'source_evidence/index.json';s=g.read(p);s[0]['original_pdf_pages']=[1];g.write(p,s);self.rehash();self.assertRaises(ValueError,self.validate)
    def test_source_pages_locator(self):self.build();self.assertEqual(g.read(self.dest/'source_evidence/index.json')[0]['original_pdf_pages'],[38])
    def test_source_mutation_rejected(self):self.put('sources/papers/approved.pdf','bad');self.assertRaises(ValueError,self.build)
    def test_missing_lean_fails(self):self.build();(self.dest/'Aiyagari1994/New.lean').unlink();self.rehash();self.assertRaises((OSError,ValueError),self.validate)
    def test_preview_never_review_ready(self):g.build_snapshot(self.b,self.gate,self.baseline,None,self.dest,True);self.assertRaises(ValueError,self.validate)
    def test_unknown_route_fails(self):self.gate['contracts']=['UNRELATED'];self.assertRaises(ValueError,self.b.capsule,self.gate,self.baseline)
    def test_signature_multiline_preserved(self):self.assertEqual(g.signatures('T.name (x : Nat) :\n  x = x\nother\n',['T.name'])['T.name'],'T.name (x : Nat) :\n  x = x')
    def test_missing_axiom_record_fails(self):
        p=self.ver/'audit.log';p.write_text("T.new : True\n'T.new' depends on axioms: [propext]\n");s=g.read(self.ver/'deterministic_summary.json');s['checks']['audit']['sha256']=g.sha(p.read_bytes());g.write(self.ver/'deterministic_summary.json',s);self.assertRaises(ValueError,self.build)

    def test_cache_invalidates_on_acceptance_sha(self):
        self.put('lean-toolchain','leanprover/lean4:v4.32.0\n');self.put('lake-manifest.json','{}')
        self.put('reviews/accepted.json','{}');self.b.interface=g.ContextBuilder.interface.__get__(self.b)
        self.b.acceptance=Mock(return_value=('reviews/accepted.json','a'*40,SHA,['retain this']))
        source=(self.root/'Aiyagari1994/Old.lean').read_bytes()
        output="T.old : True\n'T.old' depends on axioms: [propext]\n"
        with patch.object(g.subprocess,'check_output',return_value=source),patch.object(g.subprocess,'run',return_value=Mock(returncode=0,stdout=output,stderr='')) as run,patch.object(self.c,'git',return_value=''):
            first=self.b.interface('H11');again=self.b.interface('H11');self.assertEqual(first,again);self.assertEqual(run.call_count,1)
            self.b.acceptance.return_value=('reviews/accepted.json','b'*40,SHA,['retain this'])
            second=self.b.interface('H11');self.assertEqual(run.call_count,2);self.assertNotEqual(first['cache_key'],second['cache_key'])
    def test_reliable_extraction_omits_unrelated_pages(self):
        import types
        selected=[]
        class Reader:
            def __init__(self,input):self.pages=list(range(45)) if not isinstance(input,Path) else list(selected)
        class Writer:
            def add_page(self,page):selected.append(page)
            def write(self,target):target.write_bytes(b'EXACT PAGE 38')
        with patch.dict(sys.modules,{'pypdf':types.SimpleNamespace(PdfReader=Reader,PdfWriter=Writer)}):
            index=self.b.source_pages([self.contract],self.dest)
        self.assertEqual(selected,[37]);self.assertFalse(index[0]['full_pdf_fallback']);self.assertEqual(list(self.dest.glob('*.pdf')),[self.dest/'A93_pages.pdf'])
    def test_tampered_raw_evidence_fails(self):
        self.build();(self.ver/'full_build.log').write_text('changed')
        with self.assertRaises(ValueError):g.validate_context(self.dest,self.b,self.gate,self.baseline,verification=self.ver)
    def test_snapshot_hash_mutation_fails(self):
        self.build();(self.dest/'ledger.md').write_text('changed');self.assertRaises(ValueError,self.validate)

class FreezeTests(unittest.TestCase):
    BASE='ea76b6c49f8349fc727686d174c89b35dce0cf80'
    def unchanged(self,names):
        prefix=subprocess.check_output(['git','rev-parse','--show-prefix'],cwd=ROOT,text=True).strip()
        for name in names:
            before=subprocess.check_output(['git','show',self.BASE+':'+prefix+name],cwd=ROOT)
            self.assertEqual((ROOT/name).read_bytes(),before,name)
    def test_all_accepted_lean_unchanged(self):
        names=subprocess.check_output(['git','ls-tree','-r','--name-only',self.BASE,'--','.'],cwd=ROOT,text=True).splitlines()
        self.unchanged([n for n in names if n.endswith('.lean') and n not in ('All.lean','Audit.lean')])
        prefix=subprocess.check_output(['git','rev-parse','--show-prefix'],cwd=ROOT,text=True).strip()
        for n in ('All.lean','Audit.lean'):
            before=subprocess.check_output(['git','show',self.BASE+':'+prefix+n],cwd=ROOT)
            self.assertTrue((ROOT/n).read_bytes().startswith(before),n)
    def test_contracts_unchanged(self):
        self.unchanged([str(p.relative_to(ROOT)) for p in (ROOT/'contracts').glob('*') if p.is_file() and p.name!='theorems.json'])
        self.test_only_authorized_m04_status_changes()
    def test_only_authorized_m04_status_changes(self):
        prefix=subprocess.check_output(['git','rev-parse','--show-prefix'],cwd=ROOT,text=True).strip()
        before=json.loads(subprocess.check_output(['git','show',self.BASE+':'+prefix+'contracts/theorems.json'],cwd=ROOT))
        current=o.read_json(ROOT/'contracts/theorems.json');by={t['id']:t for t in current['theorems']}
        for t in before['theorems']:
            if t['id'] in ('H06','D02','D03','S01','S02','S03','S04','S05'):
                self.assertIn(by[t['id']]['status'],('UNFORMALIZED','IN_PROGRESS','KERNEL_CHECKED','REVIEW_READY','GREEN','BLOCKED'))
                t['status']=by[t['id']]['status']
        self.assertEqual(before,current)

    def test_no_m06_executor_invocation(self):
        self.assertFalse(any((ROOT/'tmp_orchestration/runs').glob('M06*/**/executor_invocation.json')))
        self.assertNotIn('M06',[g['id'] for g in o.Controller().gates])

if __name__=='__main__':unittest.main()
