import copy,json,sys,tempfile,unittest
from pathlib import Path
from unittest.mock import Mock,patch
sys.path.insert(0,str(Path(__file__).resolve().parents[1]))
from shared_imports import structure,compare,import_graph,eligible,POLICIES,guard,MODULE
from orchestrate import Controller,Stop

class SharedImportTests(unittest.TestCase):
    def setUp(self):
        self.policy=copy.deepcopy(POLICIES['M09B2']);self.old=b'import Aiyagari1994.Analysis.M09B1.FiniteCapExistence\n\nnamespace Aiyagari1994\ntheorem finiteCap_equilibrium_exists : True := True.intro\nend Aiyagari1994\n'
        self.suffix=b'\n/-! G03 wrapper -/\nnamespace Aiyagari1994\ntheorem naturalCap_equilibrium_exists : True := True.intro\nend Aiyagari1994\n'
        self.imp=b'import Aiyagari1994.Analysis.M09B2.NaturalCapExistence\n'
        self.new=self.old.replace(b'\n',b'\n'+self.imp,1)+self.suffix
        self.b=[{'name':'Aiyagari1994.finiteCap_equilibrium_exists','kind':'theorem','unsafe':False,'partial':False,'reducibility':'opaque theorem','mutual_block':[],'levels':[],'type':'Expr.const True','value':'Expr.const True.intro','project_dependencies':['base'],'axioms':['propext']}]
        self.a=copy.deepcopy(self.b)+[dict(self.b[0],name=self.policy['new_declarations'][0])]
        self.ts={'theorems':[{'id':'G03','declaration':self.policy['new_declarations'][0],'dependencies':['G01']},{'id':'G01','declaration':'defG01','dependencies':[]},{'id':'G02','declaration':'g02','dependencies':[]}]}
        self.state={'status':'HUMAN_STOP','gate':'M09B2','diagnostic':'ACCEPTED_LEAN_CHANGED: '+MODULE,'attempt':1,'revisions':0,'executor_effort_index':0,'executor_history':[{'attempt':1,'gate_id':'M09B2','invocation_number':1,'model':'gpt-5.6-sol','outcome':'COMPLETED','reason':'INITIAL','reasoning_effort':'medium','substantive_round':1}]}
    def check(self):return structure(self.old,self.new,self.policy)
    def comp(self):return compare(self.b,self.a,self.policy,self.ts)
    def test_exact_m09b2_fixture(self):self.assertEqual(self.check(),self.policy['imports'])
    def test_unchanged_accepted_semantics(self):self.assertEqual(self.comp(),self.b)
    def test_changed_accepted_source(self):self.new=self.new.replace(b'finiteCap_equilibrium_exists : True',b'finiteCap_equilibrium_exists : False');self.assertRaises(ValueError,self.check)
    def test_same_source_changed_value(self):self.a[0]['value']='different';self.assertRaisesRegex(ValueError,'IMPORT_CHANGED',self.comp)
    def test_changed_dependency_closure(self):self.a[0]['project_dependencies'].append('new');self.assertRaises(ValueError,self.comp)
    def test_changed_axiom_closure(self):self.a[0]['axioms'].append('bad');self.assertRaises(ValueError,self.comp)
    def test_unauthorized_import(self):self.new=self.new.replace(self.imp,b'import Unauthorized\n');self.assertRaises(ValueError,self.check)
    def test_import_cycle(self):
        with tempfile.TemporaryDirectory() as t:
            p=Path(t)/'Aiyagari1994';p.mkdir();(p/'A.lean').write_text('import Aiyagari1994.B\n');(p/'B.lean').write_text('import Aiyagari1994.A\n');self.assertRaisesRegex(ValueError,'IMPORT_CYCLE',import_graph,t,['Aiyagari1994.A'])
    def test_inside_accepted_prefix(self):self.new=self.new.replace(b'namespace',b'theorem bad : True := True.intro\nnamespace',1);self.assertRaises(ValueError,self.check)
    def test_gate_owned_append(self):self.assertEqual(self.check(),self.policy['imports'])
    def test_nonimport_header_edit(self):self.new=b'set_option autoImplicit false\n'+self.new;self.assertRaises(ValueError,self.check)
    def test_multiple_each_authorized(self):
        self.policy['imports'].append('Aiyagari1994.Analysis.M09B2.Second');self.new=self.new.replace(self.imp,self.imp+b'import Aiyagari1994.Analysis.M09B2.Second\n');self.assertEqual(self.check(),self.policy['imports']);self.policy['imports'].pop();self.assertRaises(ValueError,self.check)
    def test_duplicate_import(self):self.new=self.new.replace(self.imp,self.imp*2);self.assertRaises(ValueError,self.check)
    def test_status_mutation_still_prohibited(self):
        c=Mock(spec=Controller);c.project_files.return_value={};c.baseline_contracts.return_value={'theorems':[{'id':'G02','status':'GREEN'},{'id':'G03','status':'UNFORMALIZED'}]};c.root=Path('/unused')
        gate={'id':'M09B2','contracts':['G03'],'module':MODULE,'signature_probe':'probe','report':'report','analytical_audit':'audit'};c.mechanical=None
        with patch('orchestrate.read_json',return_value={'theorems':[{'id':'G02','status':'REVIEW_READY'},{'id':'G03','status':'REVIEW_READY'}]}):self.assertRaisesRegex(Stop,'CONTRACT_OR_STATUS_MUTATION',Controller._semantic_scope,c,gate,{'baseline':'x'}, {})
    def test_identity_preserved(self):before=copy.deepcopy(self.state);eligible(self.state);self.assertEqual(before,self.state)
    def test_effort_escalation_rejected(self):self.state['executor_history'][0]['reasoning_effort']='high';self.assertRaises(ValueError,eligible,self.state)
    def test_repeat_executor_rejected(self):self.state['executor_history']*=2;self.assertRaises(ValueError,eligible,self.state)
    def test_no_astra_in_guard(self):
        c=Mock();c.error=Stop
        with patch('shared_imports.certify',return_value={'result':'PASS'}):guard(c,{'id':'M09B2'},MODULE)
        c.review_submission.assert_not_called();c.snapshot.assert_not_called();c.model_run.assert_not_called()
    def test_review_already_started_rejected(self):self.state['snapshot_sha256']='hash';self.assertRaises(ValueError,eligible,self.state)
    def test_unknown_module_default_guard(self):
        c=Mock();c.error=Stop;self.assertRaisesRegex(Stop,'ACCEPTED_LEAN_CHANGED',guard,c,{'id':'other'},'x')
    def test_hidden_formal_dependency(self):self.a[1]['project_dependencies']=['g02'];self.assertRaisesRegex(ValueError,'UNAUTHORIZED_DEPENDENCY',self.comp)
    def test_missing_proof_value(self):self.b[0]['value']='';self.assertRaises(ValueError,self.comp)
    def test_extra_declaration(self):self.a.append(dict(self.b[0],name='unassigned'));self.assertRaises(ValueError,self.comp)
    def test_suffix_environment_command(self):self.new+=b'attribute [simp] finiteCap_equilibrium_exists\n';self.assertRaises(ValueError,self.check)
    def test_unauthorized_suffix_name(self):self.new=self.new.replace(b'theorem naturalCap_equilibrium_exists',b'theorem later');self.assertRaises(ValueError,self.check)
    def test_g02_import_rejected(self):
        with tempfile.TemporaryDirectory() as t:
            p=Path(t)/'Aiyagari1994/Analysis/M09B1';p.mkdir(parents=True);(p/'FiniteCapExistence.lean').write_text('');self.assertRaisesRegex(ValueError,'UNAUTHORIZED_DEPENDENCY',import_graph,t,['Aiyagari1994.Analysis.M09B1.FiniteCapExistence'])
    def test_context_completeness_precedes_astra(self):
        # The production policy remains fail closed on any incomplete snapshot.
        from gate_context import validate_context
        builder=Mock();builder.root=Path('/missing');builder.c=Mock()
        with tempfile.TemporaryDirectory() as t:
            self.assertRaises(Exception,validate_context,Path(t),builder,{'id':'M09B2'},'baseline')
        builder.c.model_run.assert_not_called()
