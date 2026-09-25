import sys,json,tempfile,unittest
from pathlib import Path
from unittest.mock import Mock,patch
sys.path.insert(0,str(Path(__file__).resolve().parents[1]))
import orchestrate as o
import usage

class Stage04Tests(unittest.TestCase):
    def setUp(self):
        self.tmp=tempfile.TemporaryDirectory();self.addCleanup(self.tmp.cleanup);self.root=Path(self.tmp.name)
    def events(self,lines):
        p=self.root/'events.jsonl';p.write_text('\n'.join(json.dumps(x) if isinstance(x,dict) else x for x in lines));return p
    def test_exact_emitted_fields(self):
        fields={'input_tokens':7,'cached_input_tokens':4,'output_tokens':3,'reasoning_output_tokens':2,'cache_write_input_tokens':0}
        out=usage.emitted_usage(self.events([{'type':'turn.completed','usage':fields}]))
        self.assertEqual(out['events'][0]['usage'],fields);self.assertEqual(out['actual_usage'],fields)
    def test_absent_usage_null(self):
        out=usage.emitted_usage(self.events([{'type':'thread.started'}]));self.assertTrue(all(v is None for v in out['actual_usage'].values()));self.assertEqual(out['availability'],'not emitted by installed Codex CLI')
    def test_does_not_invent_reasoning(self):
        out=usage.emitted_usage(self.events([{'type':'turn.completed','usage':{'input_tokens':9}}]));self.assertIsNone(out['actual_usage']['reasoning_output_tokens']);self.assertNotIn('total_tokens',out['actual_usage'])
    def test_malformed_preserves_valid(self):
        out=usage.emitted_usage(self.events(['{',{'type':'turn.completed','usage':{'input_tokens':9}}]));self.assertEqual(out['actual_usage']['input_tokens'],9);self.assertEqual(out['malformed_jsonl_lines'],1)
    def test_only_usage_accounting_no_message_text(self):
        out=usage.emitted_usage(self.events([{'type':'turn.completed','usage':{'input_tokens':9,'secret':'not stored'},'message':'not stored'}]));self.assertNotIn('not stored',json.dumps(out))
    def test_unknown_event_not_invented(self):
        out=usage.emitted_usage(self.events([{'type':'made.up','usage':{'input_tokens':9}}]));self.assertIsNone(out['actual_usage']['input_tokens'])
    def test_telemetry_failure_nonfatal(self):
        self.assertIsNone(usage.begin(Mock(), 'executor','unchanged',self.root,self.root,'model','medium'));usage.finish(None)
    def test_exact_three_gate_order(self):
        c=o.Controller();self.assertEqual([(g['id'],g['contracts']) for g in c.gates[-3:]],[('M04A',['H06']),('M04B',['D02']),('M04C',['D03'])]);self.assertFalse(any(g['id'].startswith('M05') for g in c.gates))
    def test_checkpoint(self):self.assertEqual(o.Controller().checkpoint,'STAGE04_COMPLETE_HUMAN_CHECKPOINT')
    def test_contract_dependencies_unchanged(self):
        ts={x['id']:x for x in o.read_json(o.PROJECT/'contracts/theorems.json')['theorems']}
        self.assertEqual(ts['H06']['dependencies'],['H02','H04']);self.assertEqual(ts['D02']['dependencies'],[]);self.assertEqual(ts['D03']['dependencies'],['H07','H08','H10','H12','D02'])
    def test_each_new_gate_medium(self):
        c=o.Controller();accepted=[g['id'] for g in c.gates if g['id'].startswith('M03')]
        for gate in c.gates[-3:]:
            state={'accepted':accepted,'gate':'previous','executor_history':[]};self.assertEqual(c.executor_plan(state)['reasoning_effort'],'medium');accepted.append(gate['id'])
    def test_one_record_per_invocation(self):
        c=Mock();c.runtime=self.root;c.state_path=self.root/'state.json';usage.write(c.state_path,{'revisions':0});usage.write(self.root/'executor_invocation.json',{'gate_id':'M04A'})
        usage.write(self.root/'contexts/M04A/gate_context.json',{'id':'M04A'})
        first=usage.begin(c,'executor','fixed prompt',self.root,self.root,'gpt-5.6-sol','medium');usage.finish(first,0)
        second=usage.begin(c,'executor','fixed prompt',self.root,self.root,'gpt-5.6-sol','medium');usage.finish(second,0)
        self.assertEqual(len(list((self.root/'usage/M04A').glob('*.json'))),2);self.assertEqual(first[1]['prompt_characters'],12)
    def test_interface_cache_metadata_observational(self):
        c=Mock();c.runtime=self.root;c.state_path=self.root/'state.json';usage.write(c.state_path,{'revisions':0});usage.write(self.root/'executor_invocation.json',{'gate_id':'M04A'});usage.write(self.root/'usage_cache/M04A.json',{'H02':True,'H04':True})
        record=usage.begin(c,'executor','unchanged',self.root,self.root,'gpt-5.6-sol','medium');self.assertTrue(record[1]['cached_accepted_interfaces_used'])
