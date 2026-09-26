import sys,unittest,json,tempfile
from pathlib import Path
from unittest.mock import patch,Mock
sys.path.insert(0,str(Path(__file__).resolve().parents[1]))
from a03_repair import RepairController,ledger_status,AUTHORITY,export_name_resume_eligible
from orchestrate import Controller,Stop,read_json
class A03RepairTests(unittest.TestCase):
 def test_isolated_roles_and_scope(self):
  c=RepairController();self.assertEqual(c.gates[-1]['id'],'M06DR');self.assertEqual(c.gates[-1]['contracts'],['A03']);self.assertEqual(c.runtime,c.root/'tmp_orchestration/a03_repair');self.assertNotEqual(c.usage_report_path(c.gates[-1]),Controller().usage_report_path(c.gates[-1]));self.assertEqual(c.executor_plan({'accepted':[g['id'] for g in c.gates[:-1]],'gate':'M06DR','executor_effort_index':0,'executor_invocation_reason':'INITIAL'})['reasoning_effort'],'medium')
 def test_status_update_is_narrow(self):
  c=Controller();text=(c.root/'docs/proof_ledger.md').read_text();contracts=read_json(c.root/'contracts/theorems.json');next(t for t in contracts['theorems'] if t['id']=='A03')['status']='IN_PROGRESS';new=ledger_status(text,'IN_PROGRESS',contracts)
  self.assertIn('**Status:** IN_PROGRESS.',new);self.assertEqual(text.split('## A03')[0].split('\n\n',2)[-1].split('## A02')[1],new.split('## A03')[0].split('\n\n',2)[-1].split('## A02')[1]);self.assertEqual(text.split('## A04')[1],new.split('## A04')[1])
 def test_ambiguous_ledger_rejected(self):
  with self.assertRaises(Stop):ledger_status('## A03\nNo status\n','IN_PROGRESS',{'theorems':[]})
 def test_integration_failure_does_not_complete(self):
  c=RepairController();c.preserve_predecessors=Mock();c.save=Mock()
  with patch('stage06.integration',side_effect=Stop('FAIL')):
   with self.assertRaises(Stop):c.finish_stage({})
  c.save.assert_not_called()
 def test_original_gate_history_not_rewritten(self):
  a=Controller();b=RepairController();self.assertEqual(a.gates[:-1],b.gates[:-1]);self.assertEqual(a.gates[-1]['id'],'M06D');self.assertIn('independent normalized price and debt-shift',AUTHORITY)

 def test_export_reconciliation_rejects_semantic_stop(self):
  self.assertFalse(export_name_resume_eligible({'status':'HUMAN_STOP','diagnostic':'CONTRACT_OR_STATUS_MUTATION'}))
 def test_export_reconciliation_exact_pre_review_case(self):
  s={'status':'HUMAN_STOP','gate':'M06DR','diagnostic':'REVIEW_CONTEXT_INCOMPLETE: new contract export coverage','attempt':1,'revisions':0,'reviewer_verdict':None,'snapshot_sha256':None,'acceptance_committed':False,'executor_history':[{}]}
  self.assertTrue(export_name_resume_eligible(s));s['reviewer_verdict']={'verdict':'REVISE'};self.assertFalse(export_name_resume_eligible(s))
 def test_export_reconciliation_ineligible_stop_does_not_save(self):
  c=RepairController();c.status=Mock(return_value={'status':'HUMAN_STOP','diagnostic':'CONTRACT_OR_STATUS_MUTATION'});c.save=Mock()
  with self.assertRaises(Stop):c.reconcile_export_name('unused')
  c.save.assert_not_called()
