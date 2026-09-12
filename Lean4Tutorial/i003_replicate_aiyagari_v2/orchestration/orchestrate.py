#!/usr/bin/env python3
"""Subscription-only, fail-closed controller. No model SDK or network client."""
from __future__ import annotations
import argparse
import contextlib
import fcntl
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tempfile
import time

sys.path.insert(0,str(Path(__file__).resolve().parent))
from mechanical import MechanicalEvidence
from review_evidence import required_sources, source_consistency, ledger_errors, evidence_repair_eligible

PROJECT = Path(__file__).resolve().parents[1]
CHECKPOINT = 'STAGE03_COMPLETE_HUMAN_CHECKPOINT'
DIMENSIONS = tuple(f'D{i:02d}' for i in range(1, 21))
CORE_DIMENSIONS = {'D01','D02','D05','D06','D07','D13','D14','D15','D16','D17','D18','D19','D20'}
MANUAL_ZIP_OVERRIDE = ('Do not create a manual review ZIP. The controller will freeze and package '
                       'the review snapshot after deterministic checks. Produce the required '
                       'implementation, reports, audits, logs and synchronized ledger only.')
QUALIFICATION = ('Never use rightMarginalValue m 0 as the economic zero-state marginal. '
                 'rightMarginalValue is economically meaningful only at positive states. '
                 'At zero use the separate ENNReal zeroRightMarginal, which may be infinite.')
H09_ROUTE = '''H09 mandatory proof route: keep original consumption and save an additional initial h;
divide the Bellman comparison by h; apply monotone convergence to nonnegative concave
difference quotients as h ↓ 0. Initially work with the nonnegative extended integral.
Only after a finite left marginal proves conditional finiteness may you convert to a real integral.
The theorem holds for all R > 0. No beta*R < 1 assumption and no consumption-positivity
assumption. At the zero-resource boundary use the separate extended zeroRightMarginal.'''

SCOPE_REPAIR_FILES = {
    'orchestration/orchestrate.py', 'orchestration/tests/test_orchestrator.py',
    'orchestration/README.md', 'reports/orchestration_scope_incident_m03b1.md',
}
EXECUTOR_LOG_NAMES = frozenset({
    'accepted_source_preservation.log', 'artifact_sha256.log', 'assert_no_sorry.log',
    'audit.log', 'changed_files.log', 'commands.json', 'contracts.log', 'docs_build.log',
    'full_build.log', 'git_diff_check.log', 'log_provenance.md', 'new_exports.txt',
    'pdf_qa.md', 'pdf_render.log', 'prohibited_patterns.log', 'prohibited_patterns_hits.log',
    'signatures.log', 'targeted_build.log', 'transitive_axioms.log', 'verified_sources.sha256',
})

# Mechanical outputs only. commands.json, prose QA/provenance and the manually
# patched export inventory remain authored files under strict whitespace checks.
GENERATED_LOG_PRODUCERS = {
    'accepted_source_preservation.log': 'git diff',
    'artifact_sha256.log': 'shasum -a 256',
    'assert_no_sorry.log': 'assert_no_sorry',
    'audit.log': 'lake env lean Audit.lean',
    'changed_files.log': 'git diff',
    'contracts.log': 'python3 tools/check_contracts.py',
    'docs_build.log': 'bash tools/build_docs.sh proof_ledger',
    'full_build.log': 'lake build',
    'git_diff_check.log': 'git diff --check',
    'pdf_render.log': 'pdftoppm',
    'prohibited_patterns.log': 'rg',
    'prohibited_patterns_hits.log': 'rg',
    'signatures.log': 'lake env lean {signature_probe}',
    'targeted_build.log': 'lake build {module}',
    'transitive_axioms.log': 'depends on axioms',
    'verified_sources.sha256': 'shasum -a 256',
}

class Stop(RuntimeError):
    pass

def canonical(value):
    return json.dumps(value, sort_keys=True, separators=(',', ':'), ensure_ascii=False).encode()

def digest(data):
    return hashlib.sha256(data).hexdigest()

def read_json(path):
    return json.loads(Path(path).read_text())

def atomic_json(path, value):
    path = Path(path)
    path.parent.mkdir(parents=True, exist_ok=True)
    fd, name = tempfile.mkstemp(dir=path.parent, prefix='.writing-')
    try:
        with os.fdopen(fd, 'wb') as f:
            f.write(canonical(value) + b'\n'); f.flush(); os.fsync(f.fileno())
        os.replace(name, path)
        directory = os.open(path.parent, os.O_RDONLY)
        try: os.fsync(directory)
        finally: os.close(directory)
    finally:
        if os.path.exists(name): os.unlink(name)

def clean_environment(env=None):
    # Auth stays in Codex's credential store. Never forward provider credentials or endpoints.
    source = os.environ if env is None else env
    return {k: v for k, v in source.items() if not (
        any(x in k.upper() for x in ('API_KEY', 'APIKEY', 'ACCESS_TOKEN', 'AUTH_TOKEN'))
        or k.upper().startswith(('OPENAI_', 'AZURE_OPENAI_', 'ANTHROPIC_', 'CODEX_API_', 'CODEX_MODEL_', 'CODEX_PROVIDER_')))}

def invoke(args, cwd=None, **kwargs):
    return subprocess.run(args, cwd=cwd, env=clean_environment(), text=True,
                          capture_output=True, **kwargs)

def authenticate(binary, minimum=(0, 153, 0)):
    if not binary: raise Stop('CODEX_MISSING: install Codex CLI; no fallback is permitted.')
    version = invoke([binary, '--version'])
    match = re.search(r'codex-cli (\d+)\.(\d+)\.(\d+)([^\s]*)', version.stdout)
    if version.returncode or not match or tuple(map(int, match.groups()[:3])) < tuple(minimum):
        raise Stop('CODEX_VERSION: Codex CLI >= 0.153.0 required; update manually.')
    auth = invoke([binary, 'login', 'status'])
    # Discard raw authentication output; report only this enumerated safe result.
    lines = (auth.stdout + '\n' + auth.stderr).splitlines()
    if auth.returncode or not any(x.strip() == 'Logged in using ChatGPT' for x in lines) or any('api key' in x.lower() or 'api-key' in x.lower() or 'api_key' in x.lower() for x in lines):
        raise Stop('CHATGPT_AUTH_REQUIRED: manually run `codex login`, then retry. No API-key login or billing fallback.')
    help_result = invoke([binary, 'exec', '--help'])
    if help_result.returncode or '--ignore-user-config' not in help_result.stdout:
        raise Stop('CLI_ISOLATION_UNAVAILABLE: --ignore-user-config required; update Codex manually.')
    return {'version': match.group(0), 'authentication': 'ChatGPT subscription', 'api_key_environment': 'stripped'}

def codex_command(binary, model, reasoning, cwd, sandbox, final, schema=None):
    args = [binary, 'exec', '--ignore-user-config', '--ignore-rules', '--ephemeral',
            '--cd', str(cwd), '--sandbox', sandbox, '--json', '--model', model,
            '--config', 'forced_login_method="chatgpt"', '--config', 'model_provider="openai"',
            '--config', 'approval_policy="never"', '--config', 'service_tier="default"',
            '--config', f'model_reasoning_effort="{reasoning}"',
            '--config', 'features.apps=false', '--config', 'features.multi_agent=false',
            '--config', 'project_doc_max_bytes=0',
            '--output-last-message', str(final)]
    if sandbox == 'read-only': args.append('--skip-git-repo-check')
    if schema: args += ['--output-schema', str(schema)]
    return args + ['-']

def model_catalog(model, reasoning):
    path = Path(os.environ.get('CODEX_HOME', str(Path.home() / '.codex'))) / 'models_cache.json'
    try: models = read_json(path)['models']
    except (OSError, ValueError, KeyError): raise Stop('MODEL_CATALOG_MISSING: refresh Codex model catalog manually.')
    for item in models:
        if item.get('slug') == model:
            if reasoning in [v.get('effort') for v in item.get('supported_reasoning_levels', [])]: return
    raise Stop(f'MODEL_UNAVAILABLE: {model} with {reasoning}; no fallback.')

def validate_review(value):
    required = {'gate_id', 'attempt', 'snapshot_sha256', 'verdict', 'confidence',
                'requires_human_review', 'contract_assessments', 'blocking_findings',
                'nonblocking_findings', 'qualifications', 'revision_prompt', 'dimension_assessments'}
    if not isinstance(value, dict) or set(value) != required: raise Stop('MALFORMED_REVIEW: fields')
    if type(value['attempt']) is not int or value['attempt'] < 1: raise Stop('MALFORMED_REVIEW: attempt')
    if not isinstance(value['gate_id'], str) or not isinstance(value['snapshot_sha256'], str) or not re.fullmatch('[a-f0-9]{64}', value['snapshot_sha256']): raise Stop('MALFORMED_REVIEW: identity')
    if value['verdict'] not in ('PASS', 'REVISE', 'BLOCK') or value['confidence'] not in ('HIGH', 'MEDIUM', 'LOW') or type(value['requires_human_review']) is not bool: raise Stop('MALFORMED_REVIEW: verdict')
    for name in ('blocking_findings', 'nonblocking_findings', 'qualifications'):
        if not isinstance(value[name], list) or not all(isinstance(x, str) for x in value[name]): raise Stop('MALFORMED_REVIEW: findings')
    if value['revision_prompt'] is not None and not isinstance(value['revision_prompt'], str): raise Stop('MALFORMED_REVIEW: revision')
    if not isinstance(value['contract_assessments'], list): raise Stop('MALFORMED_REVIEW: assessments')
    for x in value['contract_assessments']:
        if not isinstance(x, dict) or set(x) != {'contract_id', 'adequate', 'assessment'} or type(x['adequate']) is not bool or not isinstance(x['contract_id'], str) or not isinstance(x['assessment'], str) or not x['assessment'].strip(): raise Stop('MALFORMED_REVIEW: assessment')
    dimensions = value['dimension_assessments']
    if not isinstance(dimensions, list) or len(dimensions) != 20:
        raise Stop('MALFORMED_REVIEW: exactly twenty dimension assessments required')
    seen = set()
    for item in dimensions:
        if not isinstance(item, dict) or set(item) != {'dimension_id','status','evidence'}:
            raise Stop('MALFORMED_REVIEW: dimension fields')
        did, status, evidence = item['dimension_id'], item['status'], item['evidence']
        if not isinstance(did,str) or did not in DIMENSIONS or did in seen:
            raise Stop('MALFORMED_REVIEW: missing, unknown or duplicate dimension')
        seen.add(did)
        if status not in ('PASS','FAIL','NOT_APPLICABLE','UNCERTAIN'):
            raise Stop('MALFORMED_REVIEW: dimension status')
        # A minimum content floor rejects empty/generic approvals; it cannot prove evidence truthful.
        if not isinstance(evidence,str) or len(evidence.strip()) < 40 or len(evidence.split()) < 6:
            raise Stop('MALFORMED_REVIEW: substantive dimension evidence required')
        if status == 'NOT_APPLICABLE':
            if did in CORE_DIMENSIONS:
                raise Stop('MALFORMED_REVIEW: core dimension cannot be NOT_APPLICABLE')
            if len(evidence.strip()) < 60 or not re.search(r'\b(because|since|as|does not|no .* required)\b', evidence, re.I):
                raise Stop('MALFORMED_REVIEW: NOT_APPLICABLE needs a specific applicability explanation')
    return value

def decision(value, gate, attempt, sha, checks_passed, max_revisions=2, revisions=None):
    validate_review(value)
    if value['gate_id'] != gate['id'] or value['attempt'] != attempt or value['snapshot_sha256'] != sha: raise Stop('REVIEW_IDENTITY_MISMATCH')
    if not checks_passed or value['requires_human_review'] or value['confidence'] != 'HIGH': return 'HUMAN_STOP'
    if any(x['dimension_id']=='D04' and x['status']=='UNCERTAIN' for x in value['dimension_assessments']): return 'HUMAN_STOP'
    if value['verdict'] == 'PASS':
        a = value['contract_assessments']
        if value['blocking_findings'] or len(a) != len(gate['contracts']) or {x['contract_id'] for x in a} != set(gate['contracts']) or not all(x['adequate'] for x in a): return 'HUMAN_STOP'
        if any(x['status'] in ('FAIL','UNCERTAIN') for x in value['dimension_assessments']): return 'HUMAN_STOP'
        return 'ACCEPTANCE_RECORDING'
    if value['verdict'] == 'REVISE' and (attempt-1 if revisions is None else revisions) < max_revisions and value['revision_prompt'] and value['revision_prompt'].strip(): return 'READY_TO_EXECUTE'
    return 'HUMAN_STOP'

def next_gate(gates, accepted):
    return next((g for g in gates if g['id'] not in accepted), None)

def strip_lean_comments(text):
    # Nested Lean comments. Keep strings: conservative false positives stop for review.
    out = []; i = 0; depth = 0
    while i < len(text):
        if text[i:i+2] == '/-': depth += 1; i += 2
        elif depth and text[i:i+2] == '-/': depth -= 1; i += 2
        elif depth: i += 1
        elif text[i:i+2] == '--':
            end = text.find('\n', i); i = len(text) if end < 0 else end
        else: out.append(text[i]); i += 1
    if depth: raise Stop('UNTERMINATED_LEAN_COMMENT')
    return ''.join(out)

class Controller:
    def __init__(self, root=PROJECT):
        self.root = Path(root).resolve(); self.o = self.root / 'orchestration'
        self.config = read_json(self.o / 'config.json'); self.gates = read_json(self.o / 'gates.json')['gates']
        if self.config['reviewer_reasoning'] != 'xhigh' or self.config['stage_checkpoint'] != CHECKPOINT or self.config['reviewer_model'] != 'gpt-6-astra' or self.config['executor_model'] == 'gpt-6-astra' or self.config['max_revisions'] != 2: raise Stop('INVALID_ROLE_CONFIGURATION')
        sequence=self.config.get('executor_reasoning_effort_sequence')
        supported_order=['minimal','low','medium','high','xhigh']
        if not isinstance(sequence,list) or not sequence or any(x not in supported_order for x in sequence) or sequence!=sorted(set(sequence),key=supported_order.index):
            raise Stop('INVALID_EXECUTOR_REASONING_POLICY: require a nonempty increasing sequence capped at xhigh')
        self.runtime = self.root / self.config['runtime']
        if self.runtime != self.root / 'tmp_orchestration': raise Stop('INVALID_RUNTIME_PATH')
        self.state_path = self.runtime / 'state.json'
        self.binary = shutil.which('codex')
        self.error=Stop
        self.mechanical=MechanicalEvidence(self) if self.config.get('mechanical_artifacts_version')==1 else None

    def git(self, *args):
        r = invoke(['git', *args], self.root)
        if r.returncode: raise Stop('GIT_FAILURE: ' + ' '.join(args[:2]))
        return r.stdout

    def tracked(self, name):
        return name in self.git('ls-files','--',name).splitlines()

    def acceptance_record(self, gate):
        stem = '03a' if gate['id']=='M03A' else gate['id'].lower()
        md = f'reviews/{stem}_acceptance.md'; js = f'reviews/{stem}_acceptance.json'
        fail = lambda why: Stop(f"ACCEPTANCE_STATE_INCONSISTENT: {gate['id']}: {why}")
        if not self.tracked(md) or not (self.root/md).is_file(): raise fail('missing tracked Markdown acceptance record')
        text = (self.root/md).read_text()
        if not re.search(r'^# '+re.escape(gate['id'])+r'\b', text) or 'Decision: ACCEPT' not in text:
            raise fail('Markdown gate/decision mismatch')
        match = re.search(r'(?:Snapshot )?SHA-256:\s*`?([a-f0-9]{64})`?(?:\s|$)', text)
        if not match: raise fail('missing valid reviewed SHA-256')
        if not self.tracked(js):
            if gate['id']!='M03A': raise fail('missing tracked structured acceptance record')
            # Bootstrap the historical externally accepted record; do not trust untracked metadata.
            qualification = text.split('## Mandatory qualification\n',1)
            if len(qualification)!=2: raise fail('missing historical qualification')
            return {'gate_id':'M03A','contract_ids':gate['contracts'],'reviewer_type':'external user-supplied review',
                    'reviewer_model':None,'snapshot_sha256':match[1],'final_verdict':'ACCEPT',
                    'qualifications':[qualification[1].strip().split('\n\n')[0]],'nonblocking_findings':[],
                    'accepted_commit_sha':None,'evidence_directory':'reports/logs/03a_acceptance/'}
        try: record=read_json(self.root/js)
        except (OSError,ValueError): raise fail('invalid structured acceptance JSON')
        if not isinstance(record,dict): raise fail('structured acceptance must be an object')
        if record.get('gate_id')!=gate['id'] or record.get('contract_ids')!=gate['contracts'] or record.get('snapshot_sha256')!=match[1]:
            raise fail('structured/Markdown identity mismatch')
        if record.get('final_verdict') not in ('PASS','ACCEPT'): raise fail('record is not accepted')
        for key in ('qualifications','nonblocking_findings'):
            if not isinstance(record.get(key),list) or not all(isinstance(x,str) and x.strip() for x in record[key]): raise fail('invalid '+key)
        if not record.get('reviewer_type') or (gate['id']!='M03A' and record.get('reviewer_model')!='gpt-6-astra'): raise fail('invalid reviewer identity')
        commit=record.get('accepted_commit_sha')
        if commit is not None and (not isinstance(commit,str) or not re.fullmatch('[a-f0-9]{40}',commit)): raise fail('invalid accepted commit SHA')
        if commit is None:
            record['accepted_commit_sha']=self.git('log','-1','--diff-filter=A','--format=%H','--',js).strip() or None
        return record

    def reconstruct_accepted(self):
        try:
            if not self.tracked('contracts/theorems.json'): raise Stop('untracked theorem manifest')
            entries=read_json(self.root/'contracts/theorems.json')['theorems']
            statuses={t['id']:t['status'] for t in entries}
            if len(statuses)!=len(entries): raise Stop('duplicate contract IDs')
            accepted=[]; gap=False
            for gate in self.gates:
                if any(cid not in statuses for cid in gate['contracts']): raise Stop(gate['id']+': missing assigned contract')
                green=[statuses[cid]=='GREEN' for cid in gate['contracts']]
                stem='03a' if gate['id']=='M03A' else gate['id'].lower()
                records=any((self.root/f'reviews/{stem}_acceptance.{ext}').exists() for ext in ('md','json'))
                if any(green) and not all(green): raise Stop(gate['id']+': partial GREEN gate')
                if all(green):
                    if gap: raise Stop(gate['id']+': noncontiguous acceptance')
                    self.acceptance_record(gate); accepted.append(gate['id'])
                else:
                    if records: raise Stop(gate['id']+': acceptance record without GREEN contracts')
                    if gate['id']=='M03A': raise Stop('M03A external accepted boundary missing')
                    gap=True
            return accepted
        except (Stop,OSError,ValueError,KeyError,TypeError) as e:
            if str(e).startswith('ACCEPTANCE_STATE_INCONSISTENT:'): raise
            raise Stop('ACCEPTANCE_STATE_INCONSISTENT: '+str(e))

    def status(self):
        if self.state_path.exists():
            state=read_json(self.state_path)
            if state.get('status') in ('READY_TO_EXECUTE','GATE_ACCEPTED',CHECKPOINT):
                if state.get('accepted')!=self.reconstruct_accepted():
                    raise Stop('ACCEPTANCE_STATE_INCONSISTENT: runtime cache disagrees with tracked acceptance prefix; reconcile cache without changing GREEN contracts')
            return self.expose_executor_plan(state)
        accepted=self.reconstruct_accepted(); gate=next_gate(self.gates,accepted)
        return self.expose_executor_plan({'status': 'READY_TO_EXECUTE' if gate else CHECKPOINT,
                'gate': gate['id'] if gate else None, 'attempt': 1,
                'baseline': self.git('rev-parse', 'HEAD').strip(), 'accepted': accepted,
                'snapshot_sha256': None, 'reviewer_verdict': None, 'acceptance_committed': False, 'revisions': 0, 'executor_effort_index':0,
                'executor_invocation_reason':'INITIAL', 'executor_history':[]})

    def executor_plan(self,state):
        gate=next_gate(self.gates,state['accepted'])
        if not gate: return {'model':None,'reasoning_effort':None,'reason':None,'gate_id':None}
        sequence=self.config['executor_reasoning_effort_sequence']
        index=state.get('executor_effort_index')
        if gate['id']!=state['gate']:
            index=0; reason='INITIAL'
        else:
            if index is None:
                # Do not guess efforts for attempts made under the older fixed-XHigh policy.
                if state.get('attempt',1)!=1 or state.get('revisions',0)!=0 or state.get('status')!='READY_TO_EXECUTE':
                    raise Stop('EXECUTOR_POLICY_STATE_INVALID: old active runtime needs explicit reconciliation')
                index=0
            reason=state.get('executor_invocation_reason','INITIAL')
        if type(index) is not int or not 0<=index<len(sequence) or reason not in ('INITIAL','REVIEWER_REVISION','DETERMINISTIC_REPAIR'):
            raise Stop('EXECUTOR_POLICY_STATE_INVALID: invalid effort index or invocation reason')
        history=state.get('executor_history',[]) if gate['id']==state['gate'] else []
        if history:
            last=history[-1]
            if last.get('model')!=self.config['executor_model'] or last.get('reasoning_effort') not in sequence or sequence.index(last['reasoning_effort'])>index:
                raise Stop('EXECUTOR_POLICY_STATE_INVALID: refusing an inferred policy change or within-gate downgrade')
        return {'gate_id':gate['id'],'model':self.config['executor_model'],
                'reasoning_effort':sequence[index],'reason':reason}

    def expose_executor_plan(self,state):
        plan=self.executor_plan(state)
        state.update(next_executor_model=plan['model'],next_executor_effort=plan['reasoning_effort'],
                     next_executor_reason=plan['reason'],next_executor_gate=plan['gate_id'])
        if self.mechanical and state.get('gate'):
            state['evidence_paths']={k:str(v) for k,v in self.mechanical.paths(state['gate'],state['attempt']).items()}
        return state

    def authorize_executor_revision(self,state,reason):
        # Called only after an existing controller decision authorizes a same-gate repair.
        if reason not in ('REVIEWER_REVISION','DETERMINISTIC_REPAIR'):
            raise Stop('EXECUTOR_POLICY_STATE_INVALID: infrastructure failure is not a substantive revision')
        history=state.get('executor_history',[])
        if not history or history[-1].get('outcome')!='COMPLETED':
            raise Stop('EXECUTOR_POLICY_STATE_INVALID: no completed executor attempt to revise')
        if state.get('revisions',0)>=self.config['max_revisions']:
            raise Stop('MAXIMUM_REVISIONS: no additional mathematical invocation authorized')
        self.executor_plan(state)  # validate before mutating counters
        state['revisions']=state.get('revisions',0)+1
        state['executor_effort_index']=min(state.get('executor_effort_index',0)+1,len(self.config['executor_reasoning_effort_sequence'])-1)
        state['executor_invocation_reason']=reason
        state['attempt']+=1

    def begin_executor_invocation(self,state,attempt_dir):
        plan=self.executor_plan(state)
        item={**plan,'attempt':state['attempt'],'invocation_number':len(state.get('executor_history',[]))+1,
              'substantive_round':state.get('revisions',0)+1,'outcome':'STARTED'}
        state.setdefault('executor_history',[]).append(item)
        atomic_json(attempt_dir/'executor_invocation.json',item)
        atomic_json(attempt_dir/'executor_invocations.json',state['executor_history'])
        return item

    def finish_executor_invocation(self,state,attempt_dir,outcome):
        state['executor_history'][-1]['outcome']=outcome
        atomic_json(attempt_dir/'executor_invocation.json',state['executor_history'][-1])
        atomic_json(attempt_dir/'executor_invocations.json',state['executor_history'])

    def require_unaccepted(self, gate):
        entries=read_json(self.root/'contracts/theorems.json')['theorems']
        if any(t['status']=='GREEN' for t in entries if t['id'] in gate['contracts']):
            raise Stop('ACCEPTANCE_STATE_INCONSISTENT: refusing to rerun or downgrade GREEN gate '+gate['id'])

    def predecessor_records(self, state):
        expected=[g['id'] for g in self.gates[:len(state['accepted'])]]
        if state['accepted']!=expected: raise Stop('ACCEPTANCE_STATE_INCONSISTENT: cached prefix is not contiguous')
        return [self.acceptance_record(g) for g in self.gates if g['id'] in state['accepted']]

    def save(self, state, status=None):
        if status: state['status'] = status
        self.expose_executor_plan(state)
        atomic_json(self.state_path, state)

    @contextlib.contextmanager
    def lock(self):
        self.runtime.mkdir(parents=True, exist_ok=True)
        with (self.runtime / 'controller.lock').open('a') as f:
            try: fcntl.flock(f, fcntl.LOCK_EX | fcntl.LOCK_NB)
            except BlockingIOError: raise Stop('CONTROLLER_ALREADY_RUNNING')
            yield

    def project_files(self):
        names = self.git('ls-files', '-z', '--cached', '--others', '--exclude-standard', '--', '.').split('\0')
        result = {}
        for name in sorted(set(n for n in names if n)):
            p = self.root / name
            if p.is_symlink(): raise Stop('SYMLINK_FORBIDDEN: ' + name)
            if p.is_file(): result[name] = digest(p.read_bytes())
        return result

    def ensure_clean(self):
        if self.git('status', '--porcelain', '--untracked-files=all', '--', '.').strip(): raise Stop('UNEXPECTED_DIRTY_PROJECT: preserve work; commit or inspect manually before run.')
        if self.git('diff', '--cached', '--name-only').strip(): raise Stop('PREEXISTING_STAGED_FILES: preserve outer repository index; resolve manually.')

    def preflight(self, smoke=True):
        info = authenticate(self.binary, self.config['minimum_codex_version'])
        for effort in self.config['executor_reasoning_effort_sequence']: model_catalog(self.config['executor_model'],effort)
        model_catalog(self.config['reviewer_model'],self.config['reviewer_reasoning'])
        info.update(executor_model=self.config['executor_model'], executor_reasoning_effort_sequence=self.config['executor_reasoning_effort_sequence'], reviewer_model=self.config['reviewer_model'], reviewer_reasoning=self.config['reviewer_reasoning'])
        cache = self.runtime / 'preflight.json'
        fingerprint = digest(canonical(info))
        # Cache only within a day; authentication is freshly checked on every call.
        if cache.exists():
            old = read_json(cache)
            if old.get('fingerprint') == fingerprint and time.time()-old.get('verified_at', 0) < 86400 and old.get('astra_smoke') == 'PASS': return old
        if not smoke: raise Stop('ASTRA_VERIFICATION_REQUIRED: run preflight.')
        smoke_dir = self.runtime / 'smoke' / str(time.time_ns()); smoke_dir.mkdir(parents=True)
        final = smoke_dir / 'final.txt'
        args = codex_command(self.binary, self.config['reviewer_model'], self.config['reviewer_reasoning'], smoke_dir, 'read-only', final)
        r = invoke(args, input='Do not use any tools, read files, or perform mathematics. Reply exactly: ASTRA_SUBSCRIPTION_OK\n')
        # Smoke events contain no task data or auth output. Preserve auditability.
        (smoke_dir / 'events.jsonl').write_text(r.stdout)
        (smoke_dir / 'result.json').write_text(json.dumps({'exit_code':r.returncode,'final_present':final.exists()})+'\n')
        if r.returncode or not final.exists() or final.read_text().strip() != 'ASTRA_SUBSCRIPTION_OK':
            raise Stop('ASTRA_UNAVAILABLE_OR_USAGE_LIMIT: smoke did not succeed; state preserved; no provider/billing fallback. Inspect Codex manually.')
        info.update(astra_smoke='PASS', fingerprint=fingerprint, verified_at=time.time())
        atomic_json(cache, info)
        return info

    def gate_prompt(self, gate, state):
        self.require_unaccepted(gate)
        ts = read_json(self.root / 'contracts/theorems.json')['theorems']
        exact = [t for t in ts if t['id'] in gate['contracts']]
        if len(exact) != len(gate['contracts']): raise Stop('MISSING_CONTRACT')
        pieces = [(self.o / 'prompts/executor_wrapper.md').read_text(),
                  f"Assigned gate: {gate['id']}; ONLY contracts {gate['contracts']}. Accepted predecessors: {state['accepted']}. Accepted baseline: {state['baseline']}.",
                  f"Required module: {gate['module']}; signature probe: {gate['signature_probe']}; gate report: {gate['report']}; analytical audit: {gate['analytical_audit']}.",
                  QUALIFICATION, 'Exact assigned contracts (including source locators):\n'+json.dumps(exact, indent=2)]
        for n in ['AGENTS.md', 'prompts/03_household_analysis.md', 'docs/architecture.md', 'docs/lean_interfaces.md', 'docs/dependency_graph.md', 'contracts/assumptions.json', 'reviews/03a_acceptance.md']:
            pieces += [f'\n--- {n} ---\n'+(self.root/n).read_text()]
        pieces.append('MANDATORY CARRY-FORWARD QUALIFICATIONS\nPreserve every predecessor qualification and nonblocking finding below unless the user/design authority explicitly revises it. These records are acceptance evidence, not authority to alter this gate.\n'+json.dumps(self.predecessor_records(state),indent=2,ensure_ascii=False))
        if gate['id'] == 'M03B1': pieces.append(H09_ROUTE)
        if self.mechanical:
            pieces.append('MECHANICAL EVIDENCE POLICY (overrides historical report-log conventions): The controller owns all verification output paths under '+str(self.mechanical.paths(gate,state['attempt'])['checks'])+'. Do not write logs, inventories, command summaries or QA notes under reports/logs. Run local builds with output to stdout (captured by the executor process records); report semantic proof and visual QA conclusions in the assigned milestone/analytical report. The controller independently generates build/audit/export/scope/source/diff evidence after you finish. Do not edit orchestration/runtime state or controller records. Only semantic project outputs belong in Git.')
        if state.get('revision_prompt'): pieces.append('Independent reviewer SAME-GATE repair instruction:\n'+state['revision_prompt'])
        pieces.append(f"STOP after {gate['id']} REVIEW_READY. The general prompt below/above does not authorize another gate. Do not alter orchestration, tools, accepted theorem bodies, or contract semantics. Mark only assigned status REVIEW_READY. Use exact ledger status line '**Status:** REVIEW_READY.' in assigned section. Add every new exported declaration to Audit.lean with #check, assert_no_sorry and #print axioms. Put all new helper files under Aiyagari1994/Analysis/{gate['id']}/. Append to a shared accepted module only when the assigned target uses that exact module. {MANUAL_ZIP_OVERRIDE} This overrides historical manual ZIP instructions in AGENTS and the original milestone prompt for orchestrated runs. No self-awarded GREEN.")
        return '\n\n'.join(pieces)+'\n'

    def dry_run(self):
        state = self.status(); gate = next_gate(self.gates, state['accepted'])
        if not gate: return {'status': CHECKPOINT}
        sources=self.approved_source_evidence(gate)
        directory = self.runtime / 'dry_run'; directory.mkdir(parents=True, exist_ok=True)
        (directory / 'executor_prompt.md').write_text(self.gate_prompt(gate, state))
        plan=self.executor_plan(state)
        planned_command=codex_command(self.binary or 'codex',plan['model'],plan['reasoning_effort'],self.root,'workspace-write',directory/'executor_final.md')
        inputs = {'executor':plan,'planned_executor_command':planned_command,'gate': gate['id'], 'contracts': gate['contracts'], 'executor_invoked': False, 'reviewer_invoked': False,
                  'review_inputs': ['project Lean sources', 'contracts', 'architecture/interfaces', 'original M03 prompt', 'prior acceptances', 'ledger source', 'gate reports', 'fresh deterministic logs', 'baseline diff', 'canonical snapshot manifest'],
                  'qualification': QUALIFICATION, 'source_evidence':[item[2] for item in sources]}
        atomic_json(directory / 'planned_review_inputs.json', inputs)
        return inputs

    def baseline_contracts(self, baseline):
        prefix = self.git('rev-parse', '--show-prefix').strip()
        return json.loads(self.git('show', f'{baseline}:{prefix}contracts/theorems.json'))

    def frozen_scope(self, gate, state, initial, ready=True):
        if self.mechanical and ready:
            return self.mechanical.reconcile(gate,state,initial)
        return self._semantic_scope(gate,state,initial,ready)

    def _semantic_scope(self, gate, state, initial, ready=True, ignored=()):
        if ready: self.require_unaccepted(gate)
        current = self.project_files()
        changed = {n for n in set(initial)|set(current) if initial.get(n) != current.get(n)} - set(ignored)
        allowed = {'All.lean', 'Audit.lean', 'Aiyagari1994.lean', 'contracts/theorems.json', 'docs/proof_ledger.md', 'docs/proof_ledger.tex', 'docs/proof_ledger.pdf', gate['module'], gate['signature_probe'], gate['report'], gate['analytical_audit']}
        allowed.add(f"reports/{gate['id'].lower()}_signatures.md")
        log_names=self.mechanical.registry['legacy_semantic_companions'] if self.mechanical else EXECUTOR_LOG_NAMES
        allowed.update(f"reports/logs/{stem}/{name}" for stem in (gate['id'].lower(), gate['id'][1:].lower()) for name in log_names)
        for n in changed:
            if n not in allowed and not n.startswith(f"Aiyagari1994/Analysis/{gate['id']}/"):
                raise Stop('UNEXPECTED_DIRTY_PROJECT: ' + n)
            if n not in current: raise Stop('DELETION_FORBIDDEN: ' + n)
        before = self.baseline_contracts(state['baseline']); after = read_json(self.root/'contracts/theorems.json')
        expected = json.loads(json.dumps(before))
        for t in expected['theorems']:
            if t['id'] in gate['contracts']: t['status'] = 'REVIEW_READY' if ready else 'GREEN'
        if after != expected: raise Stop('CONTRACT_OR_STATUS_MUTATION')
        # Existing accepted shared modules and root aggregators may only be appended to.
        prefix = self.git('rev-parse', '--show-prefix').strip()
        for n in changed:
            if n.endswith('.lean') and n in initial:
                original = self.git('show', f"{state['baseline']}:{prefix}{n}")
                if not (self.root/n).read_text().startswith(original): raise Stop('ACCEPTED_LEAN_CHANGED: ' + n)
        return current

    def command_log(self, name, args, directory):
        if self.mechanical: return self.mechanical.command(name,args,directory,clean_environment())
        directory.mkdir(parents=True, exist_ok=True)
        with (directory/(name+'.log')).open('w') as out:
            out.write('Command: '+json.dumps(args)+'\n'); out.flush()
            r = subprocess.run(args, cwd=self.root, env=clean_environment(), stdout=out, stderr=subprocess.STDOUT, text=True)
            out.write(f'\nExit: {r.returncode}\n')
        if r.returncode: raise Stop('DETERMINISTIC_CHECK_FAILED: '+name)
        return (directory/(name+'.log')).read_text()

    def generated_evidence(self, gate, directory):
        """Validate known output provenance, then inventory its unchanged bytes.

        Executor event records are provenance only, never an adequacy verdict.
        Independent checks still execute and must pass before review.
        """
        paths={f"reports/logs/{stem}/{name}":producer.format(
            signature_probe=gate['signature_probe'],module=gate['module'][:-5].replace('/','.'))
            for stem in (gate['id'].lower(),gate['id'][1:].lower())
            for name,producer in GENERATED_LOG_PRODUCERS.items()}
        paths={n:producer for n,producer in paths.items() if (self.root/n).is_file()}
        if not paths: return {}
        state=self.status()
        events=self.runtime/'runs'/gate['id']/f"attempt_{state['attempt']:03d}"/'executor_events.jsonl'
        if not events.is_file(): raise Stop('GENERATED_EVIDENCE_MISSING_PRODUCER_EVENTS')
        completed=[]
        for line in events.read_text().splitlines():
            try: event=json.loads(line)
            except ValueError: raise Stop('GENERATED_EVIDENCE_MALFORMED_PRODUCER_EVENTS')
            item=event.get('item',{})
            if event.get('type')=='item.completed' and item.get('type')=='command_execution': completed.append(item)
        inventory={}
        for name,producer in paths.items():
            # Require an actual output redirection, not a later read/mention.
            writes=[item for item in completed if re.search(r'>{1,2}\s*[\'"]?'+re.escape(name)+r"(?:[\'\"\s;]|$)",item.get('command',''))]
            if not writes or writes[-1].get('exit_code')!=0 or producer not in writes[-1].get('command',''):
                raise Stop('GENERATED_EVIDENCE_PRODUCER_MISMATCH: '+name)
            inventory[name]={'sha256':digest((self.root/name).read_bytes()),
                'producer':producer,'producer_event':writes[-1].get('id'),
                'exit_code':0,'event_log_sha256':digest(events.read_bytes())}
        directory.mkdir(parents=True,exist_ok=True)
        atomic_json(directory/'generated_evidence.json',inventory)
        return inventory

    def diff_checks(self, gate, directory):
        generated={} if self.mechanical else self.generated_evidence(gate,directory)
        # The exclusions are exact validated current-gate paths, never reports/**.
        self.command_log('git_diff_check', ['git','diff','--check','--','.']+
            [':(exclude)'+name for name in sorted(generated)], directory)
        for n in self.git('ls-files','--others','--exclude-standard','--','.').splitlines():
            if n not in generated and (self.root/n).suffix!='.pdf':
                r=invoke(['git','diff','--no-index','--check','/dev/null',str(self.root/n)])
                if r.stdout.strip() or r.stderr.strip() or r.returncode not in (0,1): raise Stop('NEW_FILE_DIFF_CHECK: '+n)
        if any(digest((self.root/n).read_bytes())!=entry['sha256'] for n,entry in generated.items()):
            raise Stop('GENERATED_EVIDENCE_CHANGED')
        self.evidence_text(directory,'new_file_diff_check','PASS: strict authored-file checks; runtime generated bytes preserved.\n')

    def evidence_text(self,directory,kind,text):
        if self.mechanical: return self.mechanical.capture(directory,kind,text)
        path=Path(directory)/(kind+'.log');path.write_text(text);return path

    def check_directory(self,gate,state,phase):
        if self.mechanical: return self.mechanical.batch(gate,state['attempt'],phase)
        return self.runtime/'runs'/gate['id']/f"attempt_{state['attempt']:03d}"/('acceptance_checks' if phase=='acceptance' else state.get('verification_directory','pre_review_checks'))

    def attempt_directory(self,gate,attempt):
        if self.mechanical: return self.mechanical.paths(gate,attempt)['attempt']
        return self.runtime/'runs'/gate['id']/f'attempt_{attempt:03d}'

    def checks(self, gate, directory):
        for n in (gate['module'], gate['signature_probe'], gate['report'], gate['analytical_audit']):
            if not (self.root/n).is_file(): raise Stop('MISSING_GATE_EVIDENCE: '+n)
        self.command_log('targeted_build', ['lake','build',gate['module'][:-5].replace('/','.')], directory)
        self.command_log('full_build', ['lake','build'], directory)
        audit = self.command_log('audit', ['lake','env','lean','Audit.lean'], directory)
        self.command_log('contracts', [sys.executable,'tools/check_contracts.py'], directory)
        signatures = self.command_log('signatures', ['lake','env','lean',gate['signature_probe']], directory)
        audit_source = (self.root/'Audit.lean').read_text()
        names = re.findall(r'^assert_no_sorry (\S+)\s*$', audit_source, re.M)
        printed = re.findall(r'^#print axioms (\S+)\s*$', audit_source, re.M)
        checked = re.findall(r'^#check (\S+)\s*$', audit_source, re.M)
        ax = [x for x in audit.splitlines() if 'depends on axioms:' in x or 'does not depend on any axioms' in x]
        if not names or len(ax) != len(printed) or set(names) != set(printed) or not set(names) <= set(checked): raise Stop('INCOMPLETE_AXIOM_AUDIT')
        for line in ax:
            if 'depends on axioms:' in line:
                match = re.search(r'\[(.*)\]', line)
                if not match or not set(match[1].split(', ')) <= {'propext','Classical.choice','Quot.sound'}: raise Stop('NONSTANDARD_AXIOM')
        ts = read_json(self.root/'contracts/theorems.json')['theorems']
        for t in ts:
            if t['id'] in gate['contracts'] and (t['declaration'] not in names or t['declaration'] not in signatures): raise Stop('MISSING_CONTRACT_SIGNATURE_AUDIT')
        self.evidence_text(directory,'transitive_axioms','\n'.join(ax)+'\n')
        self.evidence_text(directory,'assert_no_sorry','Audit.lean exited 0; silent assertions passed:\n'+'\n'.join(names)+'\n')
        lean_files = [p for p in self.project_files() if p.endswith('.lean')]
        for n in lean_files:
            s = strip_lean_comments((self.root/n).read_text())
            if re.search(r'\b(sorry|admit|axiom|unsafe|native_decide)\b|Lean\.ofReduceBool', s): raise Stop('PROHIBITED_PATTERN: '+n)
        self.evidence_text(directory,'prohibited_patterns','PASS: nested-comment-aware conservative scan\n'+'\n'.join(lean_files)+'\n')
        self.review_evidence_checks()
        # Verification must not overwrite the submitted ledger's TeX/PDF bytes.
        with tempfile.TemporaryDirectory(prefix='aiyagari-doc-check-') as scratch:
            scratch = Path(scratch)
            for n in ('docs/proof_ledger.md','docs/header.tex','docs/ledger_header.tex',
                      'contracts/theorems.json','tools/build_docs.sh'):
                target=scratch/n; target.parent.mkdir(parents=True,exist_ok=True)
                shutil.copyfile(self.root/n,target)
            self.command_log('documentation', ['bash',str(scratch/'tools/build_docs.sh'),'proof_ledger'], directory)
            if self.config.get('review_evidence_version') and (scratch/'docs/proof_ledger.tex').read_bytes()!=(self.root/'docs/proof_ledger.tex').read_bytes():
                raise Stop('LEDGER_TEX_OUT_OF_SYNC')
        self.diff_checks(gate,directory)
        ledger = (self.root/'docs/proof_ledger.md').read_text()
        for t in ts:
            match = re.search(r'^## '+re.escape(t['id'])+r'\b.*?\n(.*?)(?=^## |\Z)', ledger, re.M|re.S)
            if not match or not re.search(r'\*\*Status:\*\*\s*'+t['status']+r'\b', match[1]): raise Stop('LEDGER_STATUS_MISMATCH: '+t['id'])
        (directory/'checks.json').write_text(json.dumps({'passed': True, 'assertions':len(names), 'axiom_outputs':len(ax), 'lean_files':len(lean_files)},indent=2)+'\n')
        if self.mechanical:
            self.evidence_text(directory,'export_inventory','\n'.join(names)+'\n')
            self.evidence_text(directory,'source_validation',json.dumps({'verified_sources':[item[2] for item in self.approved_source_evidence(gate)],'metadata_discrepancies':source_consistency(ts,{x['id']:x for x in read_json(self.root/'contracts/source_manifest.json')['sources']})},indent=2)+'\n')
            self.evidence_text(directory,'frozen_scope',json.dumps({'gate':gate['id'],'semantic_files':self.project_files(),'scope':'controller validated; no unregistered evidence exemptions'},sort_keys=True)+'\n')
            self.mechanical.summary(directory,{'assertions':len(names),'axiom_outputs':len(ax),'lean_files':len(lean_files)},require_complete=True)
        return True

    def diff_text(self, baseline):
        diff = self.git('diff','--binary',baseline,'--','.')
        for n in self.git('ls-files','--others','--exclude-standard','--','.').splitlines():
            r = invoke(['git','diff','--no-index','--binary','/dev/null',n], self.root)
            if r.returncode not in (0,1): raise Stop('NEW_FILE_DIFF_FAILED')
            diff += r.stdout
        return diff

    def approved_source_evidence(self, gate):
        try:
            entries=read_json(self.root/'contracts/theorems.json')['theorems']
            assigned=[t for t in entries if t['id'] in gate['contracts']]
            if len(assigned)!=len(gate['contracts']): raise Stop('assigned contract missing')
            records=read_json(self.root/'contracts/source_manifest.json')['sources']
            catalog={item['id']:item for item in records}
            ids=set()
            for t in assigned:
                if not isinstance(t.get('sources'),list) or not all(isinstance(x,str) for x in t['sources']): raise Stop('missing source IDs for '+t['id'])
                if t['sources'] and (not isinstance(t.get('source_locator'),str) or not t['source_locator'].strip()): raise Stop('missing precise source locator for '+t['id'])
                ids.update(required_sources(t,catalog))
            records=read_json(self.root/'contracts/source_manifest.json')['sources']
            catalog={item['id']:item for item in records}
            if len(catalog)!=len(records): raise Stop('duplicate source IDs')
            evidence=[]
            for sid in sorted(ids):
                if sid not in catalog: raise Stop('unknown approved source '+sid)
                item=catalog[sid]; name=item['local_name']; sha=item['sha256']
                if Path(name).name!=name or Path(name).suffix.lower()!='.pdf' or not re.fullmatch('[a-f0-9]{64}',sha): raise Stop('invalid approved source entry '+sid)
                path=self.root/'sources/papers'/name
                if any(p.is_symlink() for p in (self.root/'sources',self.root/'sources/papers',path)): raise Stop('symlink source forbidden '+sid)
                if not path.is_file(): raise Stop('missing approved PDF '+sid+': '+str(path))
                data=path.read_bytes()
                if digest(data)!=sha: raise Stop('SHA-256 mismatch for '+sid)
                evidence.append((name,data,{'source_id':sid,'file':'source_evidence/'+name,'sha256':sha,
                    'contract_locators':{t['id']:t.get('source_locator','') for t in assigned if sid in required_sources(t,catalog)}}))
            return evidence
        except (Stop,OSError,ValueError,KeyError,TypeError) as e:
            raise Stop('SOURCE_EVIDENCE_INCOMPLETE: APPROVED_SOURCE_EVIDENCE_INVALID: '+str(e))

    def review_evidence_checks(self):
        if not self.config.get('review_evidence_version'): return
        contracts=read_json(self.root/'contracts/theorems.json')['theorems']
        errors=ledger_errors((self.root/'docs/proof_ledger.md').read_text(),contracts)
        if errors: raise Stop('LEDGER_STATUS_MISMATCH: '+ '; '.join(errors))

    def snapshot(self, gate, state, attempt_dir):
        self.review_evidence_checks()
        sources=self.approved_source_evidence(gate)
        predecessors=self.predecessor_records(state)
        dest = self.runtime/'review_snapshots'/f"{gate['id']}_attempt_{state['attempt']:03d}_{time.time_ns()}"
        dest.mkdir(parents=True)
        allowed_roots = ('Aiyagari1994/', 'Probes/', 'contracts/', 'docs/', 'prompts/', 'reviews/', 'reports/', 'tools/')
        excluded = {'.pdf','.zip','.gz','.tar','.olean','.ilean','.c','.o','.aux','.fls','.fdb_latexmk','.synctex','.pyc'}
        for n in self.project_files():
            if not (n.startswith(allowed_roots) or n in ('AGENTS.md','README.md','.gitignore','lean-toolchain','lakefile.lean','lakefile.toml','lake-manifest.json','All.lean','Audit.lean','Aiyagari1994.lean')): continue
            if Path(n).suffix in excluded or '__pycache__' in Path(n).parts or Path(n).name == '.DS_Store': continue
            p=dest/n; p.parent.mkdir(parents=True,exist_ok=True); shutil.copyfile(self.root/n,p)
        atomic_json(dest/'predecessor_acceptances.json',predecessors)
        if (attempt_dir/'executor_invocations.json').is_file(): shutil.copyfile(attempt_dir/'executor_invocations.json',dest/'executor_invocations.json')
        (dest/'source_evidence').mkdir()
        for name,data,metadata in sources: (dest/'source_evidence'/name).write_bytes(data)
        atomic_json(dest/'source_evidence/index.json',[item[2] for item in sources])
        catalog={t['id']:t for t in read_json(self.root/'contracts/source_manifest.json')['sources']}
        atomic_json(dest/'source_evidence/consistency.json',source_consistency(read_json(self.root/'contracts/theorems.json')['theorems'],catalog))
        shutil.copytree(attempt_dir/state.get('verification_directory','pre_review_checks'),dest/'verification')
        if self.mechanical and (attempt_dir/'checks/migration.json').exists():
            shutil.copytree(attempt_dir/'checks/migrated_executor',dest/'legacy_executor_evidence')
            shutil.copyfile(attempt_dir/'checks/migration.json',dest/'legacy_migration.json')
        (dest/'git_diff.txt').write_text(self.diff_text(state['baseline']))
        atomic_json(dest/'git_state.json',{'baseline':state['baseline'],'head':self.git('rev-parse','HEAD').strip(),'status':self.git('status','--porcelain','--','.').splitlines(),'gate':gate['id'],'attempt':state['attempt']})
        files = {str(p.relative_to(dest)):digest(p.read_bytes()) for p in sorted(dest.rglob('*')) if p.is_file()}
        manifest = {'version':1,'gate':gate['id'],'attempt':state['attempt'],'baseline':state['baseline'],'files':files}
        sha = digest(canonical(manifest))
        atomic_json(dest/'snapshot_manifest.json',manifest)
        manifest_path=attempt_dir/(f"evidence_snapshot_{time.time_ns()}.json" if state.get('evidence_repair') else 'snapshot_manifest.json')
        atomic_json(manifest_path,manifest)
        state['snapshot_manifest_path']=str(manifest_path)
        for p in sorted(dest.rglob('*'),reverse=True): p.chmod(0o555 if p.is_dir() else 0o444)
        dest.chmod(0o555)
        state['snapshot_sha256']=sha; state['snapshot_path']=str(dest)
        return dest,sha

    def verify_snapshot(self, state):
        dest=Path(state['snapshot_path']); manifest=read_json(dest/'snapshot_manifest.json')
        if digest(canonical(manifest)) != state['snapshot_sha256']: raise Stop('SNAPSHOT_CHANGED')
        files={str(p.relative_to(dest)):digest(p.read_bytes()) for p in dest.rglob('*') if p.is_file() and str(p.relative_to(dest))!='snapshot_manifest.json'}
        if files != manifest['files'] or any(p.is_symlink() for p in dest.rglob('*')): raise Stop('SNAPSHOT_CHANGED')

    def model_run(self, role, prompt, cwd, attempt_dir):
        # Fresh auth and capability verification before *each* model process.
        self.preflight()
        final=attempt_dir/('reviewer_final.json' if role=='reviewer' else 'executor_final.md')
        if role=='executor':
            planned=read_json(attempt_dir/'executor_invocation.json')
            model,effort=planned['model'],planned['reasoning_effort']
        else:
            model,effort=self.config['reviewer_model'],self.config['reviewer_reasoning']
        args=codex_command(self.binary,model,effort,cwd,'read-only' if role=='reviewer' else 'workspace-write',final,self.o/'schemas/review.schema.json' if role=='reviewer' else None)
        with (attempt_dir/(role+'_events.jsonl')).open('w') as events, (attempt_dir/(role+'_stderr.log')).open('w') as err:
            r=subprocess.run(args,input=prompt,cwd=cwd,env=clean_environment(),text=True,stdout=events,stderr=err)
        if r.returncode or not final.is_file(): raise Stop('MODEL_FAILED_OR_USAGE_LIMIT: '+role+'; preserved attempt; no fallback.')
        return final.read_text()

    def review_submission(self,gate,state,attempt_dir,retry=False):
        self.verify_snapshot(state)
        self.review_evidence_checks()
        self.approved_source_evidence(gate)
        if self.project_files()!=state['reviewed_files']: raise Stop('PROJECT_CHANGED_SINCE_REVIEW')
        dest=Path(state['snapshot_path']); sha=state['snapshot_sha256']
        output_dir=attempt_dir
        if retry or state.get('evidence_repair'):
            output_dir=attempt_dir/f"reviewer_retry_{time.time_ns()}"
            output_dir.mkdir()
        prompt=(self.o/'prompts/reviewer.md').read_text()+f"\nGate: {gate['id']}; assigned contracts: {gate['contracts']}; attempt: {state['attempt']}; snapshot_sha256: {sha}\n"+QUALIFICATION
        (output_dir/'review_prompt.md').write_text(prompt)
        state['review_attempt_dir']=str(attempt_dir)
        self.save(state,'REVIEWER_RUNNING')
        try: result=self.model_run('reviewer',prompt,dest,output_dir)
        except Stop:
            # Explicit --resume re-reviews this SAME frozen submission, never re-executes it.
            state['owned_files']=self.project_files(); state['resume_phase']='REVIEW_RETRY'
            raise
        self.verify_snapshot(state)
        if self.project_files()!=state['reviewed_files']: raise Stop('REVIEWER_PROJECT_MUTATION')
        (output_dir/'reviewer_final.json').write_text(result)
        try: verdict=json.loads(result)
        except ValueError: raise Stop('MALFORMED_REVIEW_JSON')
        action=decision(verdict,gate,state['attempt'],sha,True,self.config['max_revisions'],state.get('revisions',0))
        state['reviewer_verdict']=verdict
        state['review_output_dir']=str(output_dir)
        atomic_json(output_dir/'controller_decision.json',{'action':action,'snapshot_sha256':sha})
        if action=='READY_TO_EXECUTE':
            self.authorize_executor_revision(state,'REVIEWER_REVISION')
            state['revision_prompt']=verdict['revision_prompt']; state['owned_files']=self.project_files()
        self.save(state,action)
        return action

    def persist_review_evidence(self,gate,state,attempt_dir):
        relative=self.mechanical.paths(gate,state['attempt'])['durable'] if self.mechanical else f"reports/logs/{gate['id'].lower()}/review"
        dest=self.root/relative
        if dest.exists(): raise Stop('REVIEW_EVIDENCE_ALREADY_EXISTS')
        output=Path(state.get('review_output_dir',attempt_dir))
        # Retry review artifacts come from the successful retry, never a failed first response.
        manifest_path=Path(state.get('snapshot_manifest_path',attempt_dir/'snapshot_manifest.json'))
        manifest=read_json(manifest_path)
        if digest(canonical(manifest))!=state['snapshot_sha256']: raise Stop('REVIEW_EVIDENCE_HASH_MISMATCH')
        final=read_json(output/'reviewer_final.json')
        controller=read_json(output/'controller_decision.json')
        if final!=state['reviewer_verdict'] or controller!={'action':'ACCEPTANCE_RECORDING','snapshot_sha256':state['snapshot_sha256']}:
            raise Stop('REVIEW_EVIDENCE_VERDICT_MISMATCH')
        selected={'snapshot_manifest.json':manifest_path,
                  'reviewer_final.json':output/'reviewer_final.json',
                  'controller_decision.json':output/'controller_decision.json',
                  'review_prompt.md':output/'review_prompt.md'}
        if (attempt_dir/'executor_final.md').is_file(): selected['executor_final.md']=attempt_dir/'executor_final.md'
        if (attempt_dir/'executor_invocations.json').is_file(): selected['executor_invocations.json']=attempt_dir/'executor_invocations.json'
        if self.mechanical:
            selected.pop('review_prompt.md',None);selected.pop('executor_final.md',None)
            selected['deterministic_summary.json']=attempt_dir/state['verification_directory']/'deterministic_summary.json'
            if digest(selected['deterministic_summary.json'].read_bytes())!=manifest['files'].get('verification/deterministic_summary.json'):
                raise Stop('DETERMINISTIC_SUMMARY_HASH_MISMATCH')
        data={name:path.read_bytes() for name,path in selected.items()}
        if self.mechanical:
            data['executor_summary.json']=canonical({'invocations':state['executor_history'],
                'final_sha256':digest((attempt_dir/'executor_final.md').read_bytes()),
                'runtime_attempt':str(attempt_dir),'outcome':'COMPLETED'})+b'\n'
        secret_pattern=rb'(?:sk-(?:proj-|svcacct-)?[A-Za-z0-9_-]{20,}|Bearer [A-Za-z0-9_.-]{20,}|-----BEGIN (?:RSA |EC |OPENSSH )?PRIVATE KEY-----)'
        if any(re.search(secret_pattern,b) for b in data.values()): raise Stop('CREDENTIAL_PATTERN_IN_REVIEW_EVIDENCE: do not commit; inspect locally without exposing values')
        if any(len(b)>2_000_000 for b in data.values()): raise Stop('COMPACT_REVIEW_EVIDENCE_TOO_LARGE')
        dest.mkdir(parents=True)
        for name,content in data.items(): (dest/name).write_bytes(content)
        return relative

    def record_acceptance(self, gate, state, attempt_dir):
        self.verify_snapshot(state)
        if self.project_files()!=state['reviewed_files']: raise Stop('PROJECT_CHANGED_SINCE_REVIEW')
        verdict=state['reviewer_verdict']
        if decision(verdict,gate,state['attempt'],state['snapshot_sha256'],True)!='ACCEPTANCE_RECORDING': raise Stop('ACCEPTANCE_NOT_AUTHORIZED')
        before=self.project_files()
        review_evidence=self.persist_review_evidence(gate,state,attempt_dir)
        original=read_json(self.root/'contracts/theorems.json')
        updated=json.loads(json.dumps(original))
        for t in updated['theorems']:
            if t['id'] in gate['contracts']:
                if t['status']!='REVIEW_READY': raise Stop('ACCEPTANCE_STATUS_INVALID')
                t['status']='GREEN'
        review_path=f"reviews/{gate['id'].lower()}_acceptance.md"
        (self.root/review_path).write_text(f"# {gate['id']} independent automated acceptance\n\nDecision: ACCEPT. Reviewer: fresh GPT-6 Astra through ChatGPT-authenticated Codex CLI, read-only frozen snapshot.\n\nSnapshot SHA-256: {state['snapshot_sha256']}\n\n{QUALIFICATION}\n\nExact independent verdict and qualifications:\n\n```json\n{json.dumps(verdict,indent=2)}\n```\n")
        structured_path=f"reviews/{gate['id'].lower()}_acceptance.json"
        atomic_json(self.root/structured_path,{'gate_id':gate['id'],'contract_ids':gate['contracts'],
            'reviewer_type':'independent fresh Codex reviewer','reviewer_model':self.config['reviewer_model'],
            'snapshot_sha256':state['snapshot_sha256'],'final_verdict':verdict['verdict'],
            'qualifications':verdict['qualifications'],'nonblocking_findings':verdict['nonblocking_findings'],
            'accepted_commit_sha':None,'accepted_commit_locator':f'git log --diff-filter=A -- {structured_path}',
            'evidence_directory':review_evidence})
        with (self.root/review_path).open('a') as record:
            record.write(f"\nDurable review evidence: `{review_evidence}/`. Structured record: `{structured_path}`.\n")
        (self.root/'contracts/theorems.json').write_text(json.dumps(updated,indent=2,ensure_ascii=False)+'\n')
        ledger=self.root/'docs/proof_ledger.md'; text=ledger.read_text()
        for cid in gate['contracts']:
            pat=r'(^## '+re.escape(cid)+r'\b.*?\n)(.*?)(?=^## |\Z)'
            def promote(m):
                section,n=re.subn(r'\*\*Status:\*\* REVIEW_READY\.',f'**Status:** GREEN. Independent Astra acceptance: `{review_path}`.',m[2],count=1)
                if n!=1: raise Stop('LEDGER_PROMOTION_AMBIGUOUS')
                return m[1]+section
            text,n=re.subn(pat,promote,text,flags=re.M|re.S)
            if n!=1: raise Stop('LEDGER_PROMOTION_AMBIGUOUS')
        # The first paragraph is status metadata, not a proof. Generate it mechanically.
        statuses={status:[t['id'] for t in updated['theorems'] if t['status']==status] for status in ('GREEN','REVIEW_READY','UNFORMALIZED')}
        overview='**Economic status:** '+ '; '.join(', '.join(ids)+' are **'+status+'**' for status,ids in statuses.items() if ids)+'. M00 bootstrap acceptance remains infrastructure only. Exact acceptance records are in `reviews/`. Proposed proof plans remain proposed until checked.'
        text,n=re.subn(r'^\*\*Economic status:\*\*[^\n]*',lambda _:overview,text,count=1,flags=re.M)
        if n!=1: raise Stop('LEDGER_OVERVIEW_AMBIGUOUS')
        ledger.write_text(text)
        if self.config.get('review_evidence_version'):
            # Promotion changes generated metadata; regenerate tracked TeX/PDF too.
            result=invoke(['bash','tools/build_docs.sh','proof_ledger'],self.root)
            build_path=attempt_dir/f'acceptance_document_build_{time.time_ns()}.log'
            build_path.write_text(result.stdout+result.stderr)
            if result.returncode: raise Stop('ACCEPTANCE_DOCUMENT_BUILD_FAILED')
        acceptance_checks=self.check_directory(gate,state,'acceptance')
        self.checks(gate,acceptance_checks)
        if ledger.read_text()!=text: raise Stop('ACCEPTANCE_LEDGER_CONTENT_MUTATION')
        evidence=f"reports/logs/{gate['id'].lower()}/acceptance"
        if self.mechanical:
            shutil.copyfile(acceptance_checks/'deterministic_summary.json',self.root/review_evidence/'acceptance_summary.json')
        else:
            evidence_path=self.root/evidence
            if evidence_path.exists(): raise Stop('ACCEPTANCE_EVIDENCE_ALREADY_EXISTS')
            shutil.copytree(acceptance_checks,evidence_path)
            for log in evidence_path.glob('*.log'):
                log.write_text('\n'.join(line.rstrip() for line in log.read_text().splitlines())+'\n')
        after=self.project_files(); allowed={review_path,structured_path,'contracts/theorems.json','docs/proof_ledger.md','docs/proof_ledger.tex','docs/proof_ledger.pdf'}
        if any(n not in allowed and not n.startswith(evidence+'/') and not n.startswith(review_evidence+'/') for n in set(before)|set(after) if before.get(n)!=after.get(n)): raise Stop('ACCEPTANCE_FILE_ALLOWLIST_VIOLATION')
        if read_json(self.root/'contracts/theorems.json')!=updated: raise Stop('ACCEPTANCE_CONTRACT_MUTATION')
        state['acceptance_files']=after; state['acceptance_message']=f"Accept Aiyagari {gate['id']} after independent Astra review {state['snapshot_sha256']}"
        self.save(state,'ACCEPTANCE_COMMIT_PENDING')
        self.commit_acceptance(state)

    def commit_acceptance(self,state):
        # Recover the crash window after commit succeeded but before state was saved.
        head=self.git('rev-parse','HEAD').strip()
        if head!=state['baseline']:
            if self.git('log','-1','--format=%B').strip()!=state['acceptance_message'] or self.git('rev-parse','HEAD^').strip()!=state['baseline']: raise Stop('BASELINE_MOVED')
            self.ensure_clean()
        else:
            if self.project_files()!=state['acceptance_files']: raise Stop('ACCEPTANCE_FILES_CHANGED')
            # A prior interrupted staging operation may contain project files only.
            prefix=self.git('rev-parse','--show-prefix').strip()
            staged=self.git('diff','--cached','--name-only').splitlines()
            if any(not n.startswith(prefix) for n in staged): raise Stop('OUTER_INDEX_DIRTY')
            self.git('add','--','.')
            self.git('commit','--only','-m',state['acceptance_message'],'--','.')
            head=self.git('rev-parse','HEAD').strip(); self.ensure_clean()
        state['baseline']=head; state['acceptance_committed']=True
        if state['gate'] not in state['accepted']: state['accepted'].append(state['gate'])
        atomic_json(self.runtime/'accepted'/f"{state['gate']}.json",{'commit':head,'snapshot_sha256':state['snapshot_sha256'],'verdict':state['reviewer_verdict']})
        self.save(state,'GATE_ACCEPTED')

    def reconcile_scope(self, receipt_path, receipt_sha256, expected_head):
        """Explicit recovery of this completed M03B1 scope incident; never calls a model."""
        with self.lock():
            raw=Path(receipt_path).read_bytes()
            if digest(raw)!=receipt_sha256: raise Stop('RECONCILE_RECEIPT_HASH_MISMATCH')
            receipt=json.loads(raw); state=self.status()
            if digest(self.state_path.read_bytes())!=receipt['state_sha256']:
                raise Stop('RECONCILE_STATE_CHANGED')
            expected_history=[{'attempt':1,'gate_id':'M03B1','invocation_number':1,
                'model':'gpt-5.6-sol','outcome':'COMPLETED','reason':'INITIAL',
                'reasoning_effort':'medium','substantive_round':1}]
            hygiene=receipt.get('classification')=='GENERATED_EVIDENCE_HYGIENE_DEFECT'
            expected_stop=('NEW_FILE_DIFF_CHECK: reports/logs/03b1/docs_build.log' if hygiene else
                'UNEXPECTED_DIRTY_PROJECT: reports/logs/03b1/new_exports.txt')
            if (receipt.get('classification') not in ('ORCHESTRATION_SCOPE_ALLOWLIST_DEFECT','GENERATED_EVIDENCE_HYGIENE_DEFECT')
                or state.get('status')!='HUMAN_STOP' or state.get('gate')!='M03B1'
                or state.get('attempt')!=1 or state.get('revisions')!=0
                or state.get('executor_history')!=expected_history
                or state.get('executor_effort_index')!=0
                or state.get('executor_invocation_reason')!='INITIAL'
                or state.get('accepted')!=['M03A'] or state.get('reviewer_verdict') is not None
                or state.get('snapshot_sha256') is not None or state.get('acceptance_committed')
                or state.get('diagnostic')!=expected_stop):
                raise Stop('RECONCILE_NOT_EXACT_SCOPE_INCIDENT')
            old=receipt['baseline']; head=self.git('rev-parse','HEAD').strip()
            if state['baseline']!=old or head!=expected_head or self.git('rev-parse','HEAD^').strip()!=old:
                raise Stop('RECONCILE_BASELINE_MISMATCH')
            if len(self.git('rev-list','--parents','-n','1','HEAD').split())!=2:
                raise Stop('RECONCILE_MERGE_FORBIDDEN')
            prefix=self.git('rev-parse','--show-prefix').strip()
            changed=set(self.git('diff','--name-only',old,head,'--').splitlines())
            if not changed or not changed<={prefix+n for n in SCOPE_REPAIR_FILES}:
                raise Stop('RECONCILE_NON_INFRASTRUCTURE_COMMIT')
            if self.git('diff','--cached','--name-only').strip(): raise Stop('RECONCILE_STAGED_FILES')
            current=self.project_files()
            without_infra=lambda files: {n:h for n,h in files.items() if n not in SCOPE_REPAIR_FILES}
            if without_infra(current)!=without_infra(receipt['project_files']):
                raise Stop('RECONCILE_SUBMISSION_CHANGED')
            initial=dict(state['initial_files'])
            for name in SCOPE_REPAIR_FILES:
                if name in current:
                    blob=invoke(['git','show',f'{head}:{prefix}{name}'],self.root)
                    if blob.returncode or digest(blob.stdout.encode())!=current[name]:
                        raise Stop('RECONCILE_UNCOMMITTED_INFRASTRUCTURE: '+name)
                    initial[name]=current[name]
                elif name in initial: raise Stop('RECONCILE_INFRASTRUCTURE_DELETION')
            attempt_dir=self.runtime/'runs/M03B1/attempt_001'
            evidence={str(p.relative_to(attempt_dir)):digest(p.read_bytes()) for p in attempt_dir.rglob('*') if p.is_file()}
            if evidence!=receipt['attempt_files']: raise Stop('RECONCILE_ATTEMPT_EVIDENCE_CHANGED')
            if not (attempt_dir/'executor_final.md').read_text().strip(): raise Stop('RECONCILE_NO_EXECUTOR_FINAL')
            outer=sorted(x for x in self.git('-c','status.relativePaths=false','status','--porcelain','--untracked-files=all').splitlines() if not x[3:].startswith(prefix))
            if outer!=state['outer_status']: raise Stop('OUTER_REPOSITORY_CHANGED')
            if hygiene:
                prior_path=self.runtime/'scope_incident_m03b1/reconciliation.json'
                prior_raw=prior_path.read_bytes(); prior=json.loads(prior_raw)
                if (state.get('scope_reconciliation')!=str(prior_path)
                    or digest(prior_raw)!=receipt.get('previous_reconciliation_sha256')
                    or prior.get('infrastructure_commit')!=old):
                    raise Stop('RECONCILE_PRIOR_TRANSITION_MISMATCH')
                if without_infra(current)!=without_infra(prior['preserved_project_files']):
                    raise Stop('RECONCILE_ORIGINAL_SUBMISSION_CHANGED')
                if any(evidence.get(n)!=h for n,h in prior['preserved_attempt_files'].items()):
                    raise Stop('RECONCILE_ORIGINAL_EXECUTOR_CHANGED')
            candidate=json.loads(json.dumps(state)); candidate.update(baseline=head,initial_files=initial)
            gate=next_gate(self.gates,state['accepted'])
            self.frozen_scope(gate,candidate,initial)
            transition={'old_baseline':old,'infrastructure_commit':head,'receipt_sha256':receipt_sha256,
                'classification':receipt['classification'],'attempt':1,'effort':'medium',
                'executor_rerun':False,'preserved_attempt_files':evidence,'preserved_project_files':current}
            incident='generated_log_incident_m03b1' if hygiene else 'scope_incident_m03b1'
            record=self.runtime/incident/'reconciliation.json'
            if record.exists(): raise Stop('RECONCILIATION_ALREADY_RECORDED')
            atomic_json(record,transition)
            if hygiene:
                candidate['generated_log_reconciliation']=str(record)
                candidate['verification_directory']='pre_review_checks_'+head
            else: candidate['scope_reconciliation']=str(record)
            candidate['owned_files']=current; candidate.pop('diagnostic',None)
            self.save(candidate,'POST_EXECUTOR_RECONCILED')
            return candidate

    def reconcile_runtime(self,receipt_path,receipt_sha256,expected_head):
        """User-authorized migration of the completed H10 attempt, not a retry."""
        with self.lock():
            if not self.mechanical: raise Stop('RUNTIME_ARCHITECTURE_REQUIRED')
            raw=Path(receipt_path).read_bytes()
            if digest(raw)!=receipt_sha256: raise Stop('RECONCILE_RECEIPT_HASH_MISMATCH')
            receipt=json.loads(raw);state=self.status();head=self.git('rev-parse','HEAD').strip()
            record=self.runtime/'mechanical_refactor/reconciliation.json'
            if state['status']=='POST_EXECUTOR_RECONCILED' and record.exists():
                prior=read_json(record)
                if prior['receipt_sha256']==receipt_sha256 and head==expected_head==state['baseline'] and self.project_files()==state['owned_files']:
                    return state
                raise Stop('RECONCILE_RESTART_MISMATCH')
            if digest(self.state_path.read_bytes())!=receipt['state_sha256']:raise Stop('RECONCILE_STATE_CHANGED')
            expected=[{'gate_id':'M03B2','attempt':1,'invocation_number':1,'model':'gpt-5.6-sol',
                'reasoning_effort':'medium','reason':'INITIAL','substantive_round':1,'outcome':'COMPLETED'}]
            if (state['status']!='HUMAN_STOP' or state['gate']!='M03B2' or state['attempt']!=1
                or state['executor_history']!=expected or state['revisions']!=0 or state['executor_effort_index']!=0
                or state['executor_invocation_reason']!='INITIAL' or state['reviewer_verdict'] is not None
                or state['accepted']!=['M03A','M03B1'] or state['acceptance_committed']
                or state['diagnostic']!='UNEXPECTED_DIRTY_PROJECT: reports/logs/m03b2/frozen_scope.log'):
                raise Stop('RECONCILE_NOT_EXACT_H10_INCIDENT')
            if state['accepted']!=self.reconstruct_accepted():raise Stop('RECONCILE_PREDECESSOR_CHANGED')
            old=receipt['baseline']
            if state['baseline']!=old or head!=expected_head or self.git('rev-list','--parents','-n','1','HEAD').split()!=[head,old]:
                raise Stop('RECONCILE_BASELINE_MISMATCH')
            infra=SCOPE_REPAIR_FILES|{'orchestration/config.json','orchestration/artifacts.json',
                'orchestration/mechanical.py','reports/orchestration_mechanical_artifact_refactor.md'}
            prefix=self.git('rev-parse','--show-prefix').strip()
            changed=set(self.git('diff','--name-only',old,head).splitlines())
            if not changed or not changed<={prefix+n for n in infra}:raise Stop('RECONCILE_NON_INFRASTRUCTURE_COMMIT')
            if self.git('diff','--cached','--name-only').strip():raise Stop('RECONCILE_STAGED_FILES')
            current=self.project_files();initial=dict(state['initial_files'])
            attempt=self.attempt_directory(state['gate'],1)
            if any(digest((attempt/n).read_bytes())!=h for n,h in receipt['attempt_files'].items()):raise Stop('RECONCILE_EXECUTOR_EVIDENCE_CHANGED')
            journal=attempt/'checks/migration.json'
            migrated=read_json(journal)['files'] if journal.exists() else {}
            for n,entry in migrated.items():
                if receipt['project_files'].get(n)!=entry['sha256'] or digest(Path(entry['runtime_path']).read_bytes())!=entry['sha256']:
                    raise Stop('RECONCILE_MIGRATION_MISMATCH')
            select=lambda files:{n:h for n,h in files.items() if n not in infra and n not in migrated}
            if select(current)!=select(receipt['project_files']):raise Stop('RECONCILE_H10_SUBMISSION_CHANGED')
            for name in infra:
                if name in current:
                    blob=invoke(['git','show',f'{head}:{prefix}{name}'],self.root)
                    if blob.returncode or digest(blob.stdout.encode())!=current[name]:raise Stop('RECONCILE_UNCOMMITTED_INFRASTRUCTURE')
                    initial[name]=current[name]
            outer=sorted(x for x in self.git('-c','status.relativePaths=false','status','--porcelain','--untracked-files=all').splitlines() if not x[3:].startswith(prefix))
            if outer!=state['outer_status']:raise Stop('OUTER_REPOSITORY_CHANGED')
            candidate=json.loads(json.dumps(state));candidate.update(baseline=head,initial_files=initial)
            gate=next_gate(self.gates,state['accepted'])
            self.frozen_scope(gate,candidate,initial)
            candidate['owned_files']=self.project_files();candidate.pop('diagnostic',None)
            candidate.pop('verification_directory',None)
            atomic_json(record,{'old_baseline':old,'infrastructure_commit':head,'receipt_sha256':receipt_sha256,
                'outcome':'AUTO_RECONCILE','gate':'M03B2','attempt':1,'executor_history':expected,
                'semantic_hashes':candidate['owned_files'],'migration_journal':str(journal)})
            self.save(candidate,'POST_EXECUTOR_RECONCILED');return candidate

    def reconcile_evidence(self,receipt_path,receipt_sha256,expected_head):
        """Explicit user authorization applies only to the hash-bound H10 review."""
        with self.lock():
            raw=Path(receipt_path).read_bytes()
            if digest(raw)!=receipt_sha256: raise Stop('RECONCILE_RECEIPT_HASH_MISMATCH')
            receipt=json.loads(raw); state=self.status()
            if digest(self.state_path.read_bytes())!=receipt['state_sha256']: raise Stop('RECONCILE_STATE_CHANGED')
            attempt=self.attempt_directory({'id':'M03B2'},1)
            review_raw=(attempt/'reviewer_final.json').read_bytes()
            authorized='ba7389b5477b16cdbcf0d2a58f2bd4ca6132ad39f07fadef0ce3cb9014b58cbd'
            if (receipt.get('classification')!='REVIEW_EVIDENCE_REPAIR'
                or json.loads(review_raw)!=state.get('reviewer_verdict')
                or not evidence_repair_eligible(state,authorized,digest(review_raw))):
                raise Stop('REVIEW_EVIDENCE_REPAIR_NOT_AUTHORIZED')
            if state['accepted']!=['M03A','M03B1'] or state['accepted']!=self.reconstruct_accepted() or state['acceptance_committed']:
                raise Stop('RECONCILE_PREDECESSOR_CHANGED')
            self.verify_snapshot(state)
            for n,h in receipt['attempt_files'].items():
                if digest((attempt/n).read_bytes())!=h: raise Stop('RECONCILE_EXECUTOR_EVIDENCE_CHANGED')
            head=self.git('rev-parse','HEAD').strip(); old=receipt['baseline']
            if state['baseline']!=old or head!=expected_head or self.git('rev-list','--parents','-n','1','HEAD').split()!=[head,old]:
                raise Stop('RECONCILE_BASELINE_MISMATCH')
            allowed={'orchestration/orchestrate.py','orchestration/review_evidence.py',
                'orchestration/config.json','orchestration/tests/test_orchestrator.py',
                'orchestration/tests/test_review_evidence.py','orchestration/README.md',
                'docs/proof_ledger.md','docs/proof_ledger.tex','docs/proof_ledger.pdf',
                'reports/review_evidence_repair.md','reports/orchestration_mechanical_artifact_refactor.md'}
            prefix=self.git('rev-parse','--show-prefix').strip()
            changed=set(self.git('diff','--name-only',old,head).splitlines())
            if not changed or not changed<={prefix+n for n in allowed}: raise Stop('RECONCILE_NON_INFRASTRUCTURE_COMMIT')
            if self.git('diff','--cached','--name-only').strip(): raise Stop('RECONCILE_STAGED_FILES')
            current=self.project_files()
            select=lambda fs:{n:h for n,h in fs.items() if n not in allowed}
            if select(current)!=select(receipt['project_files']): raise Stop('RECONCILE_H10_SUBMISSION_CHANGED')
            # Entire Lean/Audit/probe/contracts and predecessor records are in select.
            # The two exact authorized status replacements are separately verified.
            prior=(Path(receipt_path).parent/'ledger_before.md').read_text()
            if digest(prior.encode())!=receipt['project_files']['docs/proof_ledger.md']: raise Stop('RECONCILE_LEDGER_RECEIPT_CHANGED')
            old_boundary='At M03A acceptance, H09 and later targets were UNFORMALIZED; H09 is now separately REVIEW_READY in the following M03B1 entry, while H10 onward remain UNFORMALIZED.'
            new_boundary='Historically, at M03A acceptance, H09 and later targets were UNFORMALIZED. Current statuses are generated in the economic-status overview and individual contract headings. H09 passed independent Astra review; see `reviews/m03b1_acceptance.md` and its structured counterpart. The H10 heading records its current independent-review status.'
            old_audit='Kernel checking is complete;\neconomic adequacy remains for external review and no GREEN status is claimed.'
            new_audit='Kernel checking is complete. H09 passed independent Astra review and is GREEN; see\n`reviews/m03b1_acceptance.md` and `reviews/m03b1_acceptance.json`. All qualifications in that\nacceptance, including the finite-left boundary qualification, remain in force.'
            if prior.count(old_boundary)!=1 or prior.count(old_audit)!=1 or (self.root/'docs/proof_ledger.md').read_text()!=prior.replace(old_boundary,new_boundary).replace(old_audit,new_audit):
                raise Stop('RECONCILE_MATHEMATICAL_LEDGER_CHANGED')
            initial=dict(state['initial_files'])
            for name in allowed:
                if name in current:
                    blob=subprocess.run(['git','show',f'{head}:{prefix}{name}'],cwd=self.root,capture_output=True)
                    if blob.returncode or digest(blob.stdout)!=current[name]: raise Stop('RECONCILE_UNCOMMITTED_INFRASTRUCTURE: '+name)
                    initial[name]=current[name]
            outer=sorted(x for x in self.git('-c','status.relativePaths=false','status','--porcelain','--untracked-files=all').splitlines() if not x[3:].startswith(prefix))
            if outer!=state['outer_status']: raise Stop('OUTER_REPOSITORY_CHANGED')
            candidate=json.loads(json.dumps(state)); candidate.update(baseline=head,initial_files=initial)
            candidate['evidence_repair']={'classification':'REVIEW_EVIDENCE_REPAIR','prior_snapshot':state['snapshot_path'],
                'prior_snapshot_sha256':state['snapshot_sha256'],'prior_review_sha256':authorized,'receipt_sha256':receipt_sha256}
            candidate['owned_files']=current
            candidate.pop('diagnostic',None);candidate.pop('resume_phase',None)
            self.frozen_scope(next_gate(self.gates,state['accepted']),candidate,initial)
            record=self.runtime/'review_evidence_repair/reconciliation.json'
            if record.exists(): raise Stop('RECONCILIATION_ALREADY_RECORDED')
            atomic_json(record,{'classification':'REVIEW_EVIDENCE_REPAIR','commit':head,'receipt_sha256':receipt_sha256,
                'executor_history':state['executor_history'],'preserved_files':select(current),'old_snapshot':state['snapshot_sha256']})
            self.save(candidate,'POST_EXECUTOR_RECONCILED'); return candidate

    def run(self, resume=False):
        with self.lock():
            state=self.status()
            try:
                if state['status']==CHECKPOINT: return state
                if state['status']=='ACCEPTANCE_COMMIT_PENDING': self.commit_acceptance(state)
                if state['status']=='HUMAN_STOP':
                    # Only an explicit --resume after a model/usage failure is eligible.
                    if not resume or not state.get('resume_phase') or self.project_files()!=state.get('owned_files'): raise Stop('HUMAN_STOP: inspect preserved evidence; semantic stops require manual review, not automatic retry.')
                    self.save(state,state.pop('resume_phase'))
                if state['status'] in ('EXECUTOR_RUNNING','REVIEWER_RUNNING','DETERMINISTIC_CHECKS','ACCEPTANCE_RECORDING','FROZEN_FOR_REVIEW'):
                    raise Stop('INTERRUPTED_PHASE: preserve files and obtain manual reconciliation; no duplicated execution or acceptance.')
                if not state.get('initial_files'): self.ensure_clean()
                try:
                    if state['status']!='POST_EXECUTOR_RECONCILED': self.preflight()
                except Stop:
                    if state['status'] in ('READY_TO_EXECUTE','GATE_ACCEPTED','REVIEW_RETRY'):
                        state['resume_phase']=state['status']; state['owned_files']=self.project_files()
                    raise
                if state['status']=='REVIEW_RETRY':
                    gate=next_gate(self.gates,state['accepted'])
                    if not gate or gate['id']!=state['gate']: raise Stop('STATE_GATE_MISMATCH')
                    attempt_dir=Path(state['review_attempt_dir'])
                    action=self.review_submission(gate,state,attempt_dir,retry=True)
                    if action=='HUMAN_STOP': return state
                    if action=='ACCEPTANCE_RECORDING': self.record_acceptance(gate,state,attempt_dir)
                if state['status']=='POST_EXECUTOR_RECONCILED':
                    gate=next_gate(self.gates,state['accepted'])
                    if not gate or gate['id']!=state['gate']: raise Stop('STATE_GATE_MISMATCH')
                    if self.git('rev-parse','HEAD').strip()!=state['baseline']: raise Stop('BASELINE_MOVED')
                    if self.project_files()!=state['owned_files']: raise Stop('RECONCILE_SUBMISSION_CHANGED')
                    attempt_dir=self.attempt_directory(gate,state['attempt'])
                    self.save(state,'DETERMINISTIC_CHECKS')
                    self.frozen_scope(gate,state,state['initial_files'])
                    if self.mechanical: state['owned_files']=self.project_files()
                    check_dir=self.check_directory(gate,state,'pre_review')
                    state['verification_directory']=str(check_dir.relative_to(attempt_dir))
                    if self.mechanical: self.save(state,'POST_EXECUTOR_RECONCILED')
                    self.checks(gate,check_dir)
                    self.frozen_scope(gate,state,state['initial_files'])
                    if self.project_files()!=state['owned_files']: raise Stop('RECONCILE_CHECKS_CHANGED_SUBMISSION')
                    self.preflight()
                    state['reviewed_files']=self.project_files()
                    self.snapshot(gate,state,attempt_dir); self.save(state,'FROZEN_FOR_REVIEW')
                    action=self.review_submission(gate,state,attempt_dir)
                    if action=='HUMAN_STOP': return state
                    if action=='ACCEPTANCE_RECORDING': self.record_acceptance(gate,state,attempt_dir)
                while True:
                    if state['status']=='GATE_ACCEPTED':
                        gate=next_gate(self.gates,state['accepted'])
                        if not gate: self.save(state,CHECKPOINT); return state
                        state.update(gate=gate['id'],attempt=1,snapshot_sha256=None,reviewer_verdict=None,acceptance_committed=False,revision_prompt=None,revisions=0,executor_effort_index=0,executor_invocation_reason='INITIAL',executor_history=[])
                        state.pop('owned_files',None)
                        state.pop('verification_directory',None)
                        state.pop('evidence_repair',None)
                        state.pop('snapshot_manifest_path',None)
                        self.save(state,'READY_TO_EXECUTE')
                    gate=next_gate(self.gates,state['accepted'])
                    if not gate: self.save(state,CHECKPOINT); return state
                    if state['gate']!=gate['id']: raise Stop('STATE_GATE_MISMATCH')
                    if not state.get('initial_files') or state.get('initial_gate')!=gate['id']:
                        self.ensure_clean(); state['baseline']=self.git('rev-parse','HEAD').strip()
                        state['initial_files']=self.project_files(); state['initial_gate']=gate['id']
                    elif state.get('owned_files') and self.project_files()!=state['owned_files']: raise Stop('UNEXPECTED_DIRTY_PROJECT')
                    if self.git('rev-parse','HEAD').strip()!=state['baseline']: raise Stop('BASELINE_MOVED')
                    attempt_dir=self.attempt_directory(gate,state['attempt'])
                    if attempt_dir.exists(): raise Stop('ATTEMPT_ALREADY_EXISTS: explicit manual reconciliation required; evidence never overwritten.')
                    attempt_dir.mkdir(parents=True)
                    state.pop('verification_directory',None)
                    prompt=self.gate_prompt(gate,state); (attempt_dir/'executor_prompt.md').write_text(prompt)
                    prefix=self.git('rev-parse','--show-prefix').strip()
                    state['outer_status']=sorted(x for x in self.git('-c','status.relativePaths=false','status','--porcelain','--untracked-files=all').splitlines() if not x[3:].startswith(prefix))
                    self.begin_executor_invocation(state,attempt_dir)
                    self.save(state,'EXECUTOR_RUNNING')
                    try:
                        executor_final=self.model_run('executor',prompt,self.root,attempt_dir)
                        if not executor_final.strip(): raise Stop('MODEL_FAILED_OR_USAGE_LIMIT: empty executor final; no substantive completion')
                        (attempt_dir/'executor_final.md').write_text(executor_final)
                    except (Stop,KeyboardInterrupt,OSError,subprocess.SubprocessError):
                        self.finish_executor_invocation(state,attempt_dir,'INFRASTRUCTURE_FAILURE')
                        state['owned_files']=self.project_files(); state['resume_phase']='READY_TO_EXECUTE'; state['attempt']+=1
                        raise
                    self.finish_executor_invocation(state,attempt_dir,'COMPLETED')
                    if self.git('rev-parse','HEAD').strip()!=state['baseline']: raise Stop('EXECUTOR_COMMITTED_UNAUTHORIZED')
                    if self.git('diff','--cached','--name-only').strip(): raise Stop('EXECUTOR_STAGED_UNAUTHORIZED')
                    # Compare outer status without reading prohibited prior source contents.
                    prefix=self.git('rev-parse','--show-prefix').strip()
                    outer=lambda status: sorted(x for x in status.splitlines() if not x[3:].startswith(prefix))
                    # porcelain paths are root-relative when status.relativePaths=false.
                    if outer(self.git('-c','status.relativePaths=false','status','--porcelain','--untracked-files=all'))!=state['outer_status']:
                        raise Stop('OUTER_REPOSITORY_CHANGED')
                    self.save(state,'DETERMINISTIC_CHECKS')
                    self.frozen_scope(gate,state,state['initial_files'])
                    if self.mechanical: state['owned_files']=self.project_files()
                    check_dir=self.check_directory(gate,state,'pre_review')
                    state['verification_directory']=str(check_dir.relative_to(attempt_dir))
                    if self.mechanical: self.save(state,'POST_EXECUTOR_RECONCILED')
                    self.checks(gate,check_dir)
                    self.frozen_scope(gate,state,state['initial_files'])
                    state['reviewed_files']=self.project_files()
                    dest,sha=self.snapshot(gate,state,attempt_dir); self.save(state,'FROZEN_FOR_REVIEW')
                    action=self.review_submission(gate,state,attempt_dir)
                    if action=='HUMAN_STOP': return state
                    if action=='READY_TO_EXECUTE': continue
                    self.record_acceptance(gate,state,attempt_dir)
            except (Stop,KeyboardInterrupt,OSError,ValueError,subprocess.SubprocessError) as e:
                state['diagnostic']=str(e) or 'INTERRUPTED'
                state['stop_class']='INFRASTRUCTURE' if any(word in state['diagnostic'] for word in ('INFRASTRUCTURE','USAGE','AUTH','MODEL_FAILED','INTERRUPTED')) else 'HUMAN_REVIEW'
                self.save(state,'HUMAN_STOP'); raise Stop(state['diagnostic'])

def main(argv=None):
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('command',choices=['status','preflight','dry-run','run','reconcile-scope','reconcile-runtime','reconcile-evidence'])
    parser.add_argument('--resume',action='store_true',help='Explicit retry after a preserved model/usage failure only')
    parser.add_argument('--receipt')
    parser.add_argument('--receipt-sha256')
    parser.add_argument('--expected-head')
    args=parser.parse_args(argv)
    try:
        c=Controller()
        if args.command=='status': result=c.status()
        elif args.command=='reconcile-evidence':
            if not all((args.receipt,args.receipt_sha256,args.expected_head)):raise Stop('RECONCILE_ARGUMENTS_REQUIRED')
            result=c.reconcile_evidence(args.receipt,args.receipt_sha256,args.expected_head)
        elif args.command=='reconcile-runtime':
            if not all((args.receipt,args.receipt_sha256,args.expected_head)):raise Stop('RECONCILE_ARGUMENTS_REQUIRED')
            result=c.reconcile_runtime(args.receipt,args.receipt_sha256,args.expected_head)
        elif args.command=='reconcile-scope':
            if not all((args.receipt,args.receipt_sha256,args.expected_head)): raise Stop('RECONCILE_ARGUMENTS_REQUIRED')
            result=c.reconcile_scope(args.receipt,args.receipt_sha256,args.expected_head)
        elif args.command=='preflight':
            with c.lock(): result=c.preflight()
        elif args.command=='dry-run':
            with c.lock(): result=c.dry_run()
        else: result=c.run(args.resume)
        print(json.dumps(result,indent=2)); return 0
    except (Stop,OSError,ValueError) as e:
        print('STOP: '+str(e),file=sys.stderr); return 2

if __name__=='__main__': sys.exit(main())
