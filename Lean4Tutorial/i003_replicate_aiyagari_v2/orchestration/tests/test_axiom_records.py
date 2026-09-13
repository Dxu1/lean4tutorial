import json
from pathlib import Path
import unittest
from unittest.mock import patch
import test_orchestrator as fixtures
from axiom_records import parse_axiom_records as parse, AxiomEvidenceError, ALLOWED

o=fixtures.o
ACTUAL=Path(__file__).parent/'fixtures/h12_axioms.txt'

class ParserTests(unittest.TestCase):
    def record(self,body):return "'foo' depends on axioms: "+body
    def ok(self,body):return parse(self.record(body),['foo'])[0]['axioms']
    def bad(self,text,kind='AXIOM_EVIDENCE_MALFORMED'):
        with self.assertRaisesRegex(AxiomEvidenceError,kind):parse(text)
    def test_one_line(self):self.assertEqual(set(self.ok('[propext, Classical.choice, Quot.sound]')),ALLOWED)
    def test_next_line_bracket(self):self.assertEqual(self.ok('\n [propext]'),['propext'])
    def test_one_per_line(self):self.assertEqual(set(self.ok('[\npropext,\nClassical.choice,\nQuot.sound\n]')),ALLOWED)
    def test_indentation(self):self.assertEqual(parse("   'foo' depends on axioms:\n\t [ propext ]")[0]['axioms'],['propext'])
    def test_comma_spacing(self):self.assertEqual(set(self.ok('[propext\n,Classical.choice ,\nQuot.sound]')),ALLOWED)
    def test_empty(self):self.assertEqual(self.ok('[]'),[])
    def test_subset(self):self.assertEqual(self.ok('[Classical.choice]'),['Classical.choice'])
    def test_order(self):self.assertEqual(set(self.ok('[Quot.sound,propext,Classical.choice]')),ALLOWED)
    def test_duplicate_permitted(self):self.assertEqual(self.ok('[propext,propext]'),['propext','propext'])
    def test_unknown(self):self.bad(self.record('[Other]'),'GENUINE_NONSTANDARD_AXIOM')
    def test_wrapped_unknown(self):self.bad(self.record('[propext,\nOther\n]'),'GENUINE_NONSTANDARD_AXIOM')
    def test_truncated(self):self.bad(self.record('[propext,\n'))
    def test_missing_close(self):self.bad(self.record('[propext'))
    def test_bad_header(self):self.bad("'foo' depend on axioms: [propext]")
    def test_unrelated_brackets(self):self.assertEqual(parse('Build [324/324] done\nother [unknown]'),[])
    def test_adjacent(self):self.assertEqual(len(parse("'a' depends on axioms: []\n'b' depends on axioms: [propext]")),2)
    def test_same_line_adjacent(self):self.assertEqual(len(parse("'a' depends on axioms: [] 'b' depends on axioms: []")),2)
    def test_324(self):self.assertEqual(len(parse('\n'.join(f"'d{i}' depends on axioms: [propext]" for i in range(324)),[f'd{i}' for i in range(324)])),324)
    def test_one_invalid_among_hundreds(self):self.bad('\n'.join(f"'d{i}' depends on axioms: ["+('Other' if i==198 else 'propext')+']' for i in range(324)),'GENUINE_NONSTANDARD_AXIOM')
    def test_wrapping_invariant(self):
        for sep in [',',', ', ',\n', '\n , \t']:
            self.assertEqual(set(self.ok('[ '+sep.join(sorted(ALLOWED))+' ]')),ALLOWED)
    def test_h12_fixture(self):
        records=parse(ACTUAL.read_text());self.assertEqual(len(records),324)
        self.assertEqual({a for r in records for a in r['axioms']},ALLOWED)
        self.assertTrue(any('\n' in r['raw'] for r in records))
    def test_no_axioms_explicit(self):self.assertEqual(parse("'foo' does not depend on any axioms",['foo'])[0]['axioms'],[])
    def test_missing_record(self):
        with self.assertRaisesRegex(AxiomEvidenceError,'coverage'):parse(self.record('[]'),['foo','bar'])
    def test_duplicate_declaration(self):self.bad(self.record('[]')+'\n'+self.record('[]'))
    def test_trailing_junk(self):self.bad(self.record('[propext] unsafe'))
    def test_nested_bracket(self):self.bad(self.record('[[propext]]'))
    def test_empty_item(self):self.bad(self.record('[propext,]'))
    def test_missing_comma(self):self.bad(self.record('[propext Classical.choice]'))
    def test_truncation_before_next_record(self):self.bad(self.record('[propext\n')+"'bar' depends on axioms: []")

class ReconcileTests(unittest.TestCase):
    setUp=fixtures.ControllerTests.setUp
    write=fixtures.ControllerTests.write
    git=fixtures.ControllerTests.git
    def incident(self):
        s=self.c.status();s.update(status='HUMAN_STOP',gate='M03C',attempt=1,revisions=0,executor_effort_index=0,
            executor_invocation_reason='INITIAL',diagnostic='NONSTANDARD_AXIOM',accepted=['M03A','M03B1','M03B2','M03B3'],
            snapshot_sha256=None,reviewer_verdict=None,acceptance_committed=False,outer_status=[],
            verification_directory='checks/pre_review_001',initial_files=self.c.project_files(),
            executor_history=[{'gate_id':'M03C','attempt':1,'invocation_number':1,'model':'gpt-5.6-sol','reasoning_effort':'medium','reason':'INITIAL','substantive_round':1,'outcome':'COMPLETED'}])
        self.write('H12.lean','preserved proof fixture\n');self.write('docs/proof_ledger.md','preserved ledger fixture\n')
        data=ACTUAL.read_text();self.write('Audit.lean','\n'.join('#print axioms '+r['declaration'] for r in parse(data))+'\n')
        a=self.c.attempt_directory({'id':'M03C'},1);(a/s['verification_directory']).mkdir(parents=True)
        (a/s['verification_directory']/'audit.log').write_text(data)
        (a/'executor_final.md').write_text('original completed executor')
        o.atomic_json(self.c.state_path,s)
        receipt={'classification':'AXIOM_PARSER_FORMAT_DEFECT','baseline':s['baseline'],'state_sha256':o.digest(self.c.state_path.read_bytes()),'project_files':self.c.project_files(),'attempt_files':{str(p.relative_to(a)):o.digest(p.read_bytes()) for p in a.rglob('*') if p.is_file()}}
        p=self.c.runtime/'preservation.json';o.atomic_json(p,receipt)
        self.write('reports/axiom_parser_incident.md','parser repair fixture\n');self.git('add','project/reports/axiom_parser_incident.md');self.git('commit','-qm','Infrastructure parser repair')
        return (p,o.digest(p.read_bytes()),self.git('rev-parse','HEAD')),s
    def reconcile(self,args):
        with patch.object(self.c,'reconstruct_accepted',return_value=['M03A','M03B1','M03B2','M03B3']),patch.object(self.c,'frozen_scope'),patch.object(self.c,'save',side_effect=lambda s,status:s.update(status=status)),patch.object(self.c,'model_run',side_effect=AssertionError('no model in reconciliation')):
            return self.c.reconcile_axioms(*args)
    def test_attempt_preserved(self):
        a,s=self.incident();self.assertEqual(self.reconcile(a)['attempt'],s['attempt'])
    def test_invocation_preserved(self):
        a,s=self.incident();self.assertEqual(self.reconcile(a)['executor_history'],s['executor_history'])
    def test_effort_preserved(self):
        a,s=self.incident();self.assertEqual(self.reconcile(a)['executor_effort_index'],0)
    def test_revision_preserved(self):
        a,s=self.incident();self.assertEqual(self.reconcile(a)['revisions'],0)
    def test_submission_preserved(self):
        a,s=self.incident();after=self.reconcile(a)
        self.assertEqual(after['status'],'POST_EXECUTOR_RECONCILED')
        self.assertEqual((self.root/'H12.lean').read_text(),'preserved proof fixture\n')
    def test_changed_math_rejected(self):
        a,s=self.incident();self.write('H12.lean','changed')
        with self.assertRaisesRegex(o.Stop,'H12_SUBMISSION_CHANGED'):self.reconcile(a)
    def test_changed_evidence_rejected(self):
        a,s=self.incident();(self.c.attempt_directory({'id':'M03C'},1)/'executor_final.md').write_text('changed')
        with self.assertRaisesRegex(o.Stop,'EXECUTOR_EVIDENCE_CHANGED'):self.reconcile(a)
