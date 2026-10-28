"""Combined E02 certificate regressions; no real model invocations."""
import copy,json,sys,tempfile,unittest
from pathlib import Path
from unittest.mock import Mock,patch
sys.path.insert(0,str(Path(__file__).resolve().parents[1]))
from shared_imports import POLICIES,structure,compare,sha,canonical,import_graph,CLASSIFICATION
from shared_suffix import regions,validate_graph,validate_certificate,CLASSIFICATION as INCIDENT
from header_suffix_reconciliation import eligible
from context_shared import validate
from orchestrate import Stop

class HeaderSuffixTests(unittest.TestCase):
    def setUp(self):
        self.p=copy.deepcopy(POLICIES['M10B2'])
        self.old=b'import Base\n\nnamespace Aiyagari1994\ntheorem old : True := True.intro\nend Aiyagari1994\n'
        self.imp=('import '+self.p['imports'][0]+'\n').encode()
        self.suffix=b'\nnamespace Aiyagari1994\nnoncomputable section\nopen MeasureTheory\ntheorem caps_above_naturalLimit_equivalent : True := True.intro\nend\nend Aiyagari1994\n'
        self.new=self.imp+self.old+self.suffix
        b=[dict(name='Aiyagari1994.old',kind='theorem',unsafe=False,partial=False,reducibility='opaque theorem',mutual_block=[],levels=[],type='True',value='True.intro',project_dependencies=['base'],axioms=['propext'])]
        a=copy.deepcopy(b)+[dict(b[0],name=self.p['new_declarations'][0])]
        self.art={'baseline_raw.json':b,'candidate_raw.json':a,'accepted_shared_declarations_baseline.json':copy.deepcopy(b),'accepted_shared_declarations_candidate.json':copy.deepcopy(b),'import_graph.json':{self.p['imports'][0]:[]}}
        self.ts={'theorems':[dict(id='E01',status='GREEN',module=self.p['module'],declaration=b[0]['name'],dependencies=[]),dict(id='E02',status='REVIEW_READY',module=self.p['module'],declaration=a[1]['name'],dependencies=[])]}
        self.bt=copy.deepcopy(self.ts);self.bt['theorems'][1]['status']='UNFORMALIZED'
        compact=lambda xs:[{k:(sha(canonical(v)) if k in ('type','value','project_dependencies') else v) for k,v in x.items()} for x in xs]
        self.cert=dict(classification=CLASSIFICATION,incident_classification=INCIDENT,result='PASS',module=self.p['module'],baseline_commit='base',input_sha256='key',source_sha256=sha(self.new),source_prefix_unchanged=True,authorized_imports=self.p['imports'],accepted_declarations=[b[0]['name']],baseline_fingerprints=compact(b),candidate_fingerprints=compact(b),header_suffix=regions(self.old,self.new,self.p))
        self.state=dict(status='HUMAN_STOP',gate='M10B2',diagnostic='UNAUTHORIZED_SUFFIX_COMMAND',baseline='a070cfc574abc1fbd6fdabe735784cc173b938ae',attempt=1,revisions=0,executor_effort_index=0,executor_history=[dict(attempt=1,gate_id='M10B2',invocation_number=1,model='gpt-5.6-sol',outcome='COMPLETED',reason='INITIAL',reasoning_effort='medium',substantive_round=1)])
    def check(self):return regions(self.old,self.new,self.p)
    def bad(self):self.assertRaises(ValueError,self.check)
    def context(self):return validate(self.cert,self.p,'M10B2','base',self.old,self.new,self.art,self.ts,self.bt,self.art['import_graph.json'],'key')
    def test_exact_candidate_fixture(self):
        r=regions(EXACT_OLD,EXACT_NEW,self.p)
        self.assertEqual(r['accepted_start'],52);self.assertEqual(r['authorized_suffix_preamble'],['noncomputable section','open MeasureTheory'])
    def test_certified_header(self):self.assertEqual(structure(self.old,self.new,self.p),self.p['imports'])
    def test_whitespace_offset(self):
        self.new=b'\n \n'+self.new;self.assertEqual(self.check()['accepted_start'],len(self.imp)+3)
    def test_uncertified_import(self):self.new=b'import Evil\n'+self.new;self.bad()
    def test_two_imports(self):self.new=self.imp+self.new;self.bad()
    def test_changed_old_import(self):self.new=self.new.replace(b'import Base',b'import Changed');self.bad()
    def test_removed_old_import(self):self.new=self.new.replace(b'import Base\n',b'');self.bad()
    def test_cycle(self):
        with tempfile.TemporaryDirectory() as d:
            p=Path(d)/'Aiyagari1994';p.mkdir();(p/'X.lean').write_text('import Aiyagari1994.X\n');self.assertRaisesRegex(ValueError,'IMPORT_CYCLE',import_graph,d,['Aiyagari1994.X'])
    def test_future_import(self):
        with tempfile.TemporaryDirectory() as d:
            self.assertRaisesRegex(ValueError,'UNAUTHORIZED_DEPENDENCY',validate_graph,d,{'Aiyagari1994.Analysis.M10B3.Future':[]},self.p,set())
    def test_wrapper_backimport(self):
        self.assertRaisesRegex(ValueError,'IMPORT_CYCLE',validate_graph,'/',{'Aiyagari1994.Extensions.BorrowingCap':[]},self.p,set())
    def test_graph_accepted_and_gate_owned(self):
        with tempfile.TemporaryDirectory() as d:
            graph={self.p['imports'][0]:['Aiyagari1994.Base'],'Aiyagari1994.Base':[]}
            for m in graph:
                f=Path(d)/(m.replace('.','/')+'.lean');f.parent.mkdir(parents=True,exist_ok=True);f.write_text('')
            validate_graph(d,graph,self.p,{'Aiyagari1994/Base.lean'})
    def test_missing_import(self):self.assertRaisesRegex(ValueError,'MISSING_PROJECT_IMPORT',import_graph,'/nonexistent',self.p['imports'])
    def test_exact_recovered_bytes(self):
        r=self.check();self.assertEqual(self.new[r['accepted_start']:r['accepted_end']],self.old)
    def test_changed_accepted_source(self):self.new=self.new.replace(b'theorem old',b'theorem changed');self.bad()
    def mutate(self,key,value):
        self.art['candidate_raw.json'][0][key]=value
        self.assertRaisesRegex(ValueError,'HEADER_IMPORT_CHANGED_ACCEPTED_SEMANTICS',self.context)
    def test_changed_type(self):self.mutate('type','False')
    def test_changed_proof(self):self.mutate('value','different')
    def test_changed_dependencies(self):self.mutate('project_dependencies',['bad'])
    def test_changed_axioms(self):self.mutate('axioms',['bad'])
    def test_changed_universes(self):self.mutate('levels',['u'])
    def test_changed_metadata(self):self.mutate('unsafe',True)
    def test_only_noncomputable(self):self.new=self.new.replace(b'open MeasureTheory\n',b'');self.check()
    def test_only_open(self):self.new=self.new.replace(b'noncomputable section\n',b'').replace(b'\nend\n',b'\n');self.check()
    def test_no_preamble(self):self.new=self.new.replace(b'noncomputable section\n',b'').replace(b'open MeasureTheory\n',b'').replace(b'\nend\n',b'\n');self.check()
    def test_preboundary_commands(self):
        for command in ['noncomputable section','open MeasureTheory']:
            with self.subTest(command=command):
                self.new=self.imp+(command+'\n').encode()+self.old+self.suffix;self.bad()
    def inject(self,cmd):self.new=self.new.replace(b'open MeasureTheory\n',b'open MeasureTheory\n'+cmd.encode()+b'\n');self.bad()
    def test_set_option(self):self.inject('set_option autoImplicit false')
    def test_attribute(self):self.inject('attribute [simp] old')
    def test_dangerous_commands(self):
        for command in ['local instance','instance','notation "x" => True','macro "x" : term => `(True)','syntax "x" : term','open scoped BigOperators','axiom bad : False','opaque bad : True','namespace Foo','def bad := True','lemma bad : True := True.intro']:
            with self.subTest(command=command):
                self.new=self.imp+self.old+self.suffix;self.inject(command)
    def test_command_after_proof(self):
        self.new=self.new.replace(b'True.intro\nend\n',b'True.intro\nrun_cmd IO.println 1\nend\n');self.bad()
    def test_gate_declaration(self):self.assertEqual(self.check()['new_declarations'],self.p['new_declarations'])
    def test_future_declaration(self):self.new=self.new.replace(b'caps_above_naturalLimit_equivalent',b'naturalBound_governmentDebt_correspondence');self.bad()
    def test_extra_declaration(self):self.new=self.new.replace(b'end\nend',b'theorem bad : True := True.intro\nend\nend');self.bad()
    def test_stale_hash(self):self.cert['header_suffix']['candidate_sha256']='stale';self.assertRaises(ValueError,self.context)
    def test_context_same_certificate(self):self.assertEqual(len(self.context()),1)
    def test_context_tamper(self):self.cert['header_suffix']['accepted_start']=0;self.assertRaises(ValueError,self.context)
    def test_snapshot_suffix(self):
        from gate_context import appended_body
        c=Mock();c.error=Stop
        with patch('shared_imports.certify',return_value=self.cert):
            self.assertEqual(appended_body(c,{'id':'M10B2'},self.p['module'],self.old.decode(),self.new.decode()),self.suffix.decode())
        self.assertEqual(self.cert['header_suffix']['added_header_imports'],self.p['imports'])
        self.assertEqual(self.cert['header_suffix']['authorized_suffix_preamble'],['noncomputable section','open MeasureTheory'])
    def test_candidate_unchanged(self):
        before=sha(self.new);self.context();self.assertEqual(before,sha(self.new))
    def test_one_medium_unchanged(self):
        before=copy.deepcopy(self.state);eligible(self.state);self.assertEqual(before,self.state)
    def test_second_invocation_rejected(self):self.state['executor_history']*=2;self.assertRaises(Stop,eligible,self.state)
    def test_effort_escalation_rejected(self):self.state['executor_history'][0]['reasoning_effort']='high';self.assertRaises(Stop,eligible,self.state)
    def test_revision_rejected(self):self.state['revisions']=1;self.assertRaises(Stop,eligible,self.state)
    def test_review_started_rejected(self):self.state['snapshot_sha256']='x';self.assertRaises(Stop,eligible,self.state)
    def test_no_review_in_certificate(self):
        from shared_imports import guard
        c=Mock();c.error=Stop
        with patch('shared_imports.certify',return_value=self.cert):guard(c,{'id':'M10B2'},self.p['module'])
        c.model_run.assert_not_called();c.review_submission.assert_not_called()
    def test_review_context_still_required(self):
        from gate_context import validate_context
        c=Mock()
        with tempfile.TemporaryDirectory() as d:self.assertRaises(Exception,validate_context,Path(d),c,{'id':'M10B2'},'base')
        c.model_run.assert_not_called()

EXACT_OLD = b'import Aiyagari1994.Analysis.M10B1.ZeroRateCap\n\nnamespace Aiyagari1994\nnoncomputable section\n\n/-- E01: zero-rate finite-cap changes preserve the shifted canonical household and translate\nstationary net asset supply one-for-one. -/\ntheorem zeroRate_cap_change_exact\n    (m : HouseholdPrimitives) (hsmooth : UtilitySmooth m.utility)\n    (hcurvature : UtilityCurvature m.utility) (hnd : IncomeNondegenerate m.income)\n    (b\xe2\x82\x81 b\xe2\x82\x82 : \xe2\x84\x9d) (hb\xe2\x82\x81 : 0 \xe2\x89\xa4 b\xe2\x82\x81) (hb\xe2\x82\x82 : 0 \xe2\x89\xa4 b\xe2\x82\x82) (w : \xe2\x84\x9d) (hw : 0 < w) :\n    let m\xe2\x82\x81 := M10B1.zeroRateHousehold m b\xe2\x82\x81 hb\xe2\x82\x81 w hw\n    let m\xe2\x82\x82 := M10B1.zeroRateHousehold m b\xe2\x82\x82 hb\xe2\x82\x82 w hw\n    let h\xe2\x82\x81 := M10B1.zeroRate_beta_grossReturn_lt_one m b\xe2\x82\x81 hb\xe2\x82\x81 w hw\n    let h\xe2\x82\x82 := M10B1.zeroRate_beta_grossReturn_lt_one m b\xe2\x82\x82 hb\xe2\x82\x82 w hw\n    let pi\xe2\x82\x81 := M06C.stationaryLaw m\xe2\x82\x81 hsmooth hcurvature hnd h\xe2\x82\x81\n    let pi\xe2\x82\x82 := M06C.stationaryLaw m\xe2\x82\x82 hsmooth hcurvature hnd h\xe2\x82\x82\n    m\xe2\x82\x81 = m\xe2\x82\x82 \xe2\x88\xa7\n      valueFunction m\xe2\x82\x81 = valueFunction m\xe2\x82\x82 \xe2\x88\xa7\n      assetPolicy m\xe2\x82\x81 = assetPolicy m\xe2\x82\x82 \xe2\x88\xa7\n      consumptionPolicy m\xe2\x82\x81 = consumptionPolicy m\xe2\x82\x82 \xe2\x88\xa7\n      pi\xe2\x82\x81 = pi\xe2\x82\x82 \xe2\x88\xa7\n      stationaryAssetSupply m\xe2\x82\x82 b\xe2\x82\x82 pi\xe2\x82\x82 - stationaryAssetSupply m\xe2\x82\x81 b\xe2\x82\x81 pi\xe2\x82\x81 =\n        -(b\xe2\x82\x82 - b\xe2\x82\x81) :=\n  M10B1.zeroRate_cap_change_exact m hsmooth hcurvature hnd b\xe2\x82\x81 b\xe2\x82\x82 hb\xe2\x82\x81 hb\xe2\x82\x82 w hw\n\nend\nend Aiyagari1994\n'
EXACT_NEW = b"import Aiyagari1994.Analysis.M10B2.CapsAboveNatural\nimport Aiyagari1994.Analysis.M10B1.ZeroRateCap\n\nnamespace Aiyagari1994\nnoncomputable section\n\n/-- E01: zero-rate finite-cap changes preserve the shifted canonical household and translate\nstationary net asset supply one-for-one. -/\ntheorem zeroRate_cap_change_exact\n    (m : HouseholdPrimitives) (hsmooth : UtilitySmooth m.utility)\n    (hcurvature : UtilityCurvature m.utility) (hnd : IncomeNondegenerate m.income)\n    (b\xe2\x82\x81 b\xe2\x82\x82 : \xe2\x84\x9d) (hb\xe2\x82\x81 : 0 \xe2\x89\xa4 b\xe2\x82\x81) (hb\xe2\x82\x82 : 0 \xe2\x89\xa4 b\xe2\x82\x82) (w : \xe2\x84\x9d) (hw : 0 < w) :\n    let m\xe2\x82\x81 := M10B1.zeroRateHousehold m b\xe2\x82\x81 hb\xe2\x82\x81 w hw\n    let m\xe2\x82\x82 := M10B1.zeroRateHousehold m b\xe2\x82\x82 hb\xe2\x82\x82 w hw\n    let h\xe2\x82\x81 := M10B1.zeroRate_beta_grossReturn_lt_one m b\xe2\x82\x81 hb\xe2\x82\x81 w hw\n    let h\xe2\x82\x82 := M10B1.zeroRate_beta_grossReturn_lt_one m b\xe2\x82\x82 hb\xe2\x82\x82 w hw\n    let pi\xe2\x82\x81 := M06C.stationaryLaw m\xe2\x82\x81 hsmooth hcurvature hnd h\xe2\x82\x81\n    let pi\xe2\x82\x82 := M06C.stationaryLaw m\xe2\x82\x82 hsmooth hcurvature hnd h\xe2\x82\x82\n    m\xe2\x82\x81 = m\xe2\x82\x82 \xe2\x88\xa7\n      valueFunction m\xe2\x82\x81 = valueFunction m\xe2\x82\x82 \xe2\x88\xa7\n      assetPolicy m\xe2\x82\x81 = assetPolicy m\xe2\x82\x82 \xe2\x88\xa7\n      consumptionPolicy m\xe2\x82\x81 = consumptionPolicy m\xe2\x82\x82 \xe2\x88\xa7\n      pi\xe2\x82\x81 = pi\xe2\x82\x82 \xe2\x88\xa7\n      stationaryAssetSupply m\xe2\x82\x82 b\xe2\x82\x82 pi\xe2\x82\x82 - stationaryAssetSupply m\xe2\x82\x81 b\xe2\x82\x81 pi\xe2\x82\x81 =\n        -(b\xe2\x82\x82 - b\xe2\x82\x81) :=\n  M10B1.zeroRate_cap_change_exact m hsmooth hcurvature hnd b\xe2\x82\x81 b\xe2\x82\x82 hb\xe2\x82\x81 hb\xe2\x82\x82 w hw\n\nend\nend Aiyagari1994\n\nnamespace Aiyagari1994\nnoncomputable section\nopen MeasureTheory\n\n/-- E02: positive-rate finite caps weakly above the natural limit induce the same normalized\nhousehold and canonical policies; under S05's separate premises, laws and net supply coincide. -/\ntheorem caps_above_naturalLimit_equivalent\n    (m : HouseholdPrimitives) (b\xe2\x82\x81 b\xe2\x82\x82 : \xe2\x84\x9d) (hb\xe2\x82\x81 : 0 \xe2\x89\xa4 b\xe2\x82\x81) (hb\xe2\x82\x82 : 0 \xe2\x89\xa4 b\xe2\x82\x82)\n    (w : \xe2\x84\x9d) (hw : 0 < w) (r : \xe2\x84\x9d) (hr : 0 < r)\n    (hcap\xe2\x82\x81 : naturalLimit m.income.lower w r \xe2\x89\xa4 b\xe2\x82\x81)\n    (hcap\xe2\x82\x82 : naturalLimit m.income.lower w r \xe2\x89\xa4 b\xe2\x82\x82) :\n    let phi := naturalLimit m.income.lower w r\n    let m\xe2\x82\x81 := M10B2.capHousehold m b\xe2\x82\x81 hb\xe2\x82\x81 w hw r hr\n    let m\xe2\x82\x82 := M10B2.capHousehold m b\xe2\x82\x82 hb\xe2\x82\x82 w hw r hr\n    effectiveLimit b\xe2\x82\x81 m.income.lower w r = phi \xe2\x88\xa7\n      effectiveLimit b\xe2\x82\x82 m.income.lower w r = phi \xe2\x88\xa7\n      m\xe2\x82\x81 = m\xe2\x82\x82 \xe2\x88\xa7\n      valueFunction m\xe2\x82\x81 = valueFunction m\xe2\x82\x82 \xe2\x88\xa7\n      assetPolicy m\xe2\x82\x81 = assetPolicy m\xe2\x82\x82 \xe2\x88\xa7\n      consumptionPolicy m\xe2\x82\x81 = consumptionPolicy m\xe2\x82\x82 \xe2\x88\xa7\n      householdKernel m\xe2\x82\x81 = householdKernel m\xe2\x82\x82 \xe2\x88\xa7\n      householdLawStep m\xe2\x82\x81 = householdLawStep m\xe2\x82\x82 \xe2\x88\xa7\n      \xe2\x88\x80 (hsmooth : UtilitySmooth m.utility) (hcurvature : UtilityCurvature m.utility)\n        (hnd : IncomeNondegenerate m.income)\n        (hbetaR\xe2\x82\x81 : m\xe2\x82\x81.beta * m\xe2\x82\x81.prices.grossReturn < 1)\n        (hbetaR\xe2\x82\x82 : m\xe2\x82\x82.beta * m\xe2\x82\x82.prices.grossReturn < 1),\n        let pi\xe2\x82\x81 := M10B2.stationaryLaw m\xe2\x82\x81 hsmooth hcurvature hnd hbetaR\xe2\x82\x81\n        let pi\xe2\x82\x82 := M10B2.stationaryLaw m\xe2\x82\x82 hsmooth hcurvature hnd hbetaR\xe2\x82\x82\n        Integrable (fun z : Resources \xe2\x86\xa6 (assetPolicy m\xe2\x82\x81 z : \xe2\x84\x9d) - phi)\n            (pi\xe2\x82\x81 : Measure Resources) \xe2\x88\xa7\n          Integrable (fun z : Resources \xe2\x86\xa6 (assetPolicy m\xe2\x82\x82 z : \xe2\x84\x9d) - phi)\n            (pi\xe2\x82\x82 : Measure Resources) \xe2\x88\xa7\n          pi\xe2\x82\x81 = pi\xe2\x82\x82 \xe2\x88\xa7\n          M10B2.stationaryNetAssetSupply m\xe2\x82\x81 phi pi\xe2\x82\x81 =\n            M10B2.stationaryNetAssetSupply m\xe2\x82\x82 phi pi\xe2\x82\x82 :=\n  M10B2.caps_above_naturalLimit_equivalent m b\xe2\x82\x81 b\xe2\x82\x82 hb\xe2\x82\x81 hb\xe2\x82\x82 w hw r hr hcap\xe2\x82\x81 hcap\xe2\x82\x82\n\nend\nend Aiyagari1994\n"
