"""Mocked evidence tests: no Lean/model allowance is consumed."""
import copy
import json
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch
import test_orchestrator as fixtures
from review_evidence import locator_ids, required_sources, source_consistency, ledger_errors, evidence_repair_eligible

o=fixtures.o

class EvidenceTests(unittest.TestCase):
    setUp=fixtures.ControllerTests.setUp
    write=fixtures.ControllerTests.write
    git=fixtures.ControllerTests.git
    def sources(self,locator='A93 Appendix; A94 equations (5)-(7), printed pp. 666-667 / PDF pp. 9-10',sid='H10'):
        ts=[{'id':sid,'sources':['A93'],'source_locator':locator,'status':'REVIEW_READY'}]
        records=[]
        for source in ['A93','A94']:
            data=(source+' synthetic PDF fixture').encode()
            records.append({'id':source,'local_name':source+'.pdf','sha256':o.digest(data)})
            self.write('sources/papers/'+source+'.pdf',data.decode())
        self.write('contracts/theorems.json',json.dumps({'theorems':ts}))
        self.write('contracts/source_manifest.json',json.dumps({'sources':records}))
        return ts,{r['id']:r for r in records},{'id':'M03B2','contracts':[sid]}
    def ledger(self,status='GREEN',prose=''):
        return f'**Economic status:** H09 is **{status}**.\n\n## H09 — Fixture\n\n**Status:** {status}.\n\n{prose}\n'
    def test_h10_union(self):
        ts,cat,g=self.sources();self.assertEqual(required_sources(ts[0],cat),{'A93','A94'})
    def test_omitted_known_id(self):
        ts,cat,g=self.sources('A94 only');self.assertEqual(required_sources(ts[0],cat),{'A93','A94'})
    def test_unknown_text_not_source(self):
        ts,cat,g=self.sources('A940 FA94 A94x unknown.pdf UNKNOWN');self.assertEqual(locator_ids(ts[0],cat),set())
    def test_hash_failure_before_model(self):
        ts,cat,g=self.sources();self.write('sources/papers/A94.pdf','corrupt')
        with patch.object(self.c,'model_run') as model,self.assertRaisesRegex(o.Stop,'SOURCE_EVIDENCE_INCOMPLETE'):
            self.c.snapshot(g,{},self.c.runtime)
        model.assert_not_called()
    def test_missing_before_model(self):
        ts,cat,g=self.sources();(self.root/'sources/papers/A94.pdf').unlink()
        with patch.object(self.c,'model_run') as model,self.assertRaisesRegex(o.Stop,'SOURCE_EVIDENCE_INCOMPLETE'):
            self.c.snapshot(g,{},self.c.runtime)
        model.assert_not_called()
    def test_index_exact_locator_and_hash(self):
        ts,cat,g=self.sources();state={'attempt':1,'baseline':self.git('rev-parse','HEAD')}
        attempt=self.c.runtime/'attempt';(attempt/'pre_review_checks').mkdir(parents=True)
        with patch.object(self.c,'predecessor_records',return_value=[]): dest,sha=self.c.snapshot(g,state,attempt)
        index=o.read_json(dest/'source_evidence/index.json')
        self.assertEqual({x['source_id'] for x in index},{'A93','A94'})
        for item in index:
            self.assertEqual(item['contract_locators'],{'H10':ts[0]['source_locator']})
            self.assertEqual(o.digest((dest/item['file']).read_bytes()),cat[item['source_id']]['sha256'])
    def test_later_stage03(self):
        for sid in ['H11','H12','H13','H14']:
            ts,cat,g=self.sources('A94 equations (5)-(7)',sid)
            self.assertEqual({e[2]['source_id'] for e in self.c.approved_source_evidence(g)},{'A93','A94'})
    def test_consistency_sorted(self):
        ts,cat,g=self.sources();self.assertEqual(source_consistency(ts,cat)[0]['missing_from_sources'],['A94'])
    def test_stale_prose_before_model(self):
        self.c.config['review_evidence_version']=1
        self.write('contracts/theorems.json',json.dumps({'theorems':[{'id':'H09','status':'GREEN'}]}))
        self.write('docs/proof_ledger.md',self.ledger(prose='economic adequacy remains for external review and no GREEN status is claimed.'))
        with patch.object(self.c,'model_run') as model,self.assertRaisesRegex(o.Stop,'LEDGER_STATUS_MISMATCH'):
            self.c.snapshot({}, {},self.c.runtime)
        model.assert_not_called()
    def test_historical_sentence_allowed(self):
        text=self.ledger(prose='Historically, before M03B1 acceptance, H09 is REVIEW_READY. At the M03A submission boundary, H09 is UNFORMALIZED.')
        self.assertEqual(ledger_errors(text,[{'id':'H09','status':'GREEN'}]),[])
    def test_historical_does_not_mask_next_sentence(self):
        text=self.ledger(prose='Historically, before M03B1 acceptance, H09 is REVIEW_READY. H09 is REVIEW_READY.')
        self.assertTrue(ledger_errors(text,[{'id':'H09','status':'GREEN'}]))
    def test_global_mismatch(self):
        self.assertTrue(ledger_errors(self.ledger(),[{'id':'H09','status':'REVIEW_READY'}]))
    def test_ready_claims_green(self):
        self.assertTrue(ledger_errors(self.ledger('REVIEW_READY','H09 is GREEN.'),[{'id':'H09','status':'REVIEW_READY'}]))
    def test_future_claims_complete(self):
        self.assertTrue(ledger_errors(self.ledger('UNFORMALIZED','The contract is completed.'),[{'id':'H09','status':'UNFORMALIZED'}]))
    def repair_state(self):
        v=fixtures.verdict(gate_id='M03B2',verdict='BLOCK',confidence='HIGH',blocking_findings=['D04: missing evidence','D16: stale prose'])
        for d in v['dimension_assessments']:
            if d['dimension_id'] in {'D04','D16','D20'}:d['status']='FAIL'
        return {'gate':'M03B2','status':'HUMAN_STOP','attempt':1,'revisions':0,'executor_effort_index':0,'executor_invocation_reason':'INITIAL',
            'executor_history':[{'gate_id':'M03B2','attempt':1,'invocation_number':1,'model':'gpt-5.6-sol','reasoning_effort':'medium','reason':'INITIAL','substantive_round':1,'outcome':'COMPLETED'}],'reviewer_verdict':v}
    def test_eligible_preserves_invocation(self):
        s=self.repair_state();before=copy.deepcopy(s);self.assertTrue(evidence_repair_eligible(s,'hash','hash'));self.assertEqual(s,before)
    def test_medium_preserved(self):
        s=self.repair_state();evidence_repair_eligible(s,'hash','hash');self.assertEqual(s['executor_history'][0]['reasoning_effort'],'medium')
    def test_revision_preserved(self):
        s=self.repair_state();evidence_repair_eligible(s,'hash','hash');self.assertEqual(s['revisions'],0)
    def test_no_math_writes(self):
        self.write('H10.lean','preserved mathematical submission\n');before=(self.root/'H10.lean').read_bytes()
        ts,cat,g=self.sources();self.c.approved_source_evidence(g);evidence_repair_eligible(self.repair_state(),'hash','hash')
        self.assertEqual((self.root/'H10.lean').read_bytes(),before)
    def test_math_block_refused(self):
        for dimension in ['D01','D02','D05','D07','D18']:
            s=self.repair_state()
            next(d for d in s['reviewer_verdict']['dimension_assessments'] if d['dimension_id']==dimension)['status']='FAIL'
            self.assertFalse(evidence_repair_eligible(s,'hash','hash'))
    def test_unauthorized_review_refused(self):
        self.assertFalse(evidence_repair_eligible(self.repair_state(),'authorized','different'))
    def test_fresh_review_preserves_old_output(self):
        ts,cat,g=self.sources();s=self.repair_state();s.update(accepted=['M03A','M03B1'],baseline=self.git('rev-parse','HEAD'),evidence_repair={'classification':'REVIEW_EVIDENCE_REPAIR'})
        self.c.gates=[{'id':'M03A','contracts':[]},{'id':'M03B1','contracts':[]},g]
        attempt=self.c.runtime/'attempt';(attempt/'pre_review_checks').mkdir(parents=True)
        (attempt/'reviewer_final.json').write_text('old BLOCK\n');(attempt/'snapshot_manifest.json').write_text('old manifest\n')
        with patch.object(self.c,'predecessor_records',return_value=[]):self.c.snapshot(g,s,attempt)
        s['reviewed_files']=self.c.project_files()
        v=fixtures.verdict(gate_id='M03B2',snapshot_sha256=s['snapshot_sha256'],contract_assessments=[{'contract_id':'H10','adequate':True,'assessment':'Fixture only'}])
        with patch.object(self.c,'model_run',return_value=json.dumps(v)) as model:
            self.assertEqual(self.c.review_submission(g,s,attempt),'ACCEPTANCE_RECORDING')
        self.assertEqual(model.call_args.args[0],'reviewer');self.assertEqual(model.call_count,1)
        self.assertNotIn('old BLOCK',model.call_args.args[1])
        self.assertEqual((attempt/'reviewer_final.json').read_text(),'old BLOCK\n')
        self.assertEqual((attempt/'snapshot_manifest.json').read_text(),'old manifest\n')
        self.assertEqual(s['attempt'],1);self.assertEqual(s['revisions'],0)

    def reconciliation_fixture(self):
        old_boundary='At M03A acceptance, H09 and later targets were UNFORMALIZED; H09 is now separately REVIEW_READY in the following M03B1 entry, while H10 onward remain UNFORMALIZED.'
        new_boundary='Historically, at M03A acceptance, H09 and later targets were UNFORMALIZED. Current statuses are generated in the economic-status overview and individual contract headings. H09 passed independent Astra review; see `reviews/m03b1_acceptance.md` and its structured counterpart. The H10 heading records its current independent-review status.'
        old_audit='Kernel checking is complete;\neconomic adequacy remains for external review and no GREEN status is claimed.'
        new_audit='Kernel checking is complete. H09 passed independent Astra review and is GREEN; see\n`reviews/m03b1_acceptance.md` and `reviews/m03b1_acceptance.json`. All qualifications in that\nacceptance, including the finite-left boundary qualification, remain in force.'
        self.write('docs/proof_ledger.md',old_boundary+'\n'+old_audit)
        self.git('add','.');self.git('commit','-qm','Accepted fixture')
        state=self.c.status();state.update(self.repair_state());state.update(accepted=['M03A','M03B1'],acceptance_committed=False,
            baseline=self.git('rev-parse','HEAD'),initial_files=self.c.project_files(),outer_status=[],snapshot_path='old',snapshot_sha256=fixtures.SHA)
        self.write('H10.lean','preserved H10 bytes\n')
        attempt=self.c.attempt_directory({'id':'M03B2'},1);attempt.mkdir(parents=True)
        o.atomic_json(attempt/'reviewer_final.json',state['reviewer_verdict'])
        (attempt/'executor_final.md').write_text('completed Medium fixture')
        # Save raw state; production save's gate-plan lookup is independent of reconciliation.
        o.atomic_json(self.c.state_path,state)
        receipt={'classification':'REVIEW_EVIDENCE_REPAIR','baseline':state['baseline'],
            'state_sha256':o.digest(self.c.state_path.read_bytes()),'project_files':self.c.project_files(),
            'attempt_files':{str(p.relative_to(attempt)):o.digest(p.read_bytes()) for p in attempt.rglob('*') if p.is_file()}}
        directory=self.c.runtime/'review_evidence_repair';directory.mkdir()
        (directory/'ledger_before.md').write_bytes((self.root/'docs/proof_ledger.md').read_bytes())
        path=directory/'preservation.json';o.atomic_json(path,receipt)
        self.write('docs/proof_ledger.md',new_boundary+'\n'+new_audit)
        self.write('reports/review_evidence_repair.md','evidence repair fixture\n')
        self.git('add','project/docs/proof_ledger.md','project/reports/review_evidence_repair.md')
        self.git('commit','-qm','Repair evidence fixture')
        return path,o.digest(path.read_bytes()),self.git('rev-parse','HEAD'),state
    def reconciliation(self,args):
        # Eligibility/hash authorization tested separately; mock only the fixed production
        # incident identity, predecessor reconstruction, and existing snapshot/scope checks.
        with patch.object(o,'evidence_repair_eligible',return_value=True),patch.object(self.c,'verify_snapshot'),patch.object(self.c,'frozen_scope'),patch.object(self.c,'reconstruct_accepted',return_value=['M03A','M03B1']),patch.object(self.c,'save',side_effect=lambda s,status:s.update(status=status)),patch.object(self.c,'model_run',side_effect=AssertionError('executor forbidden')):
            return self.c.reconcile_evidence(*args)
    def test_reconcile_preserves_complete_executor_identity(self):
        path,sha,head,before=self.reconciliation_fixture()
        after=self.reconciliation((path,sha,head))
        for key in ['attempt','revisions','executor_history','executor_effort_index','executor_invocation_reason']:
            self.assertEqual(after[key],before[key])
        self.assertEqual(after['status'],'POST_EXECUTOR_RECONCILED')
        self.assertEqual((self.root/'H10.lean').read_text(),'preserved H10 bytes\n')
    def test_reconcile_rejects_changed_math(self):
        path,sha,head,before=self.reconciliation_fixture();self.write('H10.lean','changed proof')
        with self.assertRaisesRegex(o.Stop,'H10_SUBMISSION_CHANGED'):self.reconciliation((path,sha,head))
    def test_reconcile_rejects_changed_executor_evidence(self):
        path,sha,head,before=self.reconciliation_fixture()
        (self.c.attempt_directory({'id':'M03B2'},1)/'executor_final.md').write_text('changed')
        with self.assertRaisesRegex(o.Stop,'EXECUTOR_EVIDENCE_CHANGED'):self.reconciliation((path,sha,head))
    def test_reconcile_rejects_mathematical_ledger_edit(self):
        path,sha,head,before=self.reconciliation_fixture()
        with (self.root/'docs/proof_ledger.md').open('a') as f:f.write(' altered readable proof')
        with self.assertRaisesRegex(o.Stop,'MATHEMATICAL_LEDGER_CHANGED'):self.reconciliation((path,sha,head))
