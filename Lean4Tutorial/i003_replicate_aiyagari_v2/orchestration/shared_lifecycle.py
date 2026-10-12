"""Runtime-backed shared-module lifecycle; directories and status labels prove nothing."""
import json, subprocess
from pathlib import Path
from shared_imports import POLICIES, sha

CLASSIFICATION = 'PRE_EXECUTOR_SHARED_PROVENANCE_SELECTION_ERROR'

def need(ok, reason):
    if not ok:
        raise ValueError('REVIEW_CONTEXT_INCOMPLETE: shared lifecycle ' + reason)

def blob(c, ref, name):
    prefix = c.git('rev-parse', '--show-prefix').strip()
    return subprocess.check_output(['git', 'show', ref + ':' + prefix + name], cwd=c.root)

def semantic_files(c, gate, policy):
    names = {policy['module']}
    names.update(str(p.relative_to(c.root)) for p in
                 (c.root/'Aiyagari1994/Analysis'/gate['id']).rglob('*.lean'))
    return {n: sha((c.root/n).read_bytes()) for n in sorted(names)}

def record_candidate(c, gate, state, directory):
    """Called by controller only after successful executor completion, before checks."""
    policy = POLICIES.get(gate['id'])
    if not policy:
        return
    from orchestrate import atomic_json
    h = state['executor_history'][-1]
    need(h['gate_id'] == gate['id'] and h['outcome'] == 'COMPLETED', 'completion missing')
    original = blob(c, state['baseline'], policy['module'])
    files = semantic_files(c, gate, policy)
    # A no-change result is recorded honestly and rejected by phase validation.
    atomic_json(directory/'shared_candidate.json', {
        'gate': gate['id'], 'baseline': state['baseline'], 'invocation': h,
        'baseline_sha256': sha(original), 'files': files,
        'executor_final_sha256': sha((directory/'executor_final.md').read_bytes())})

def phase(c, gate, state):
    policy = POLICIES[gate['id']]
    if c.tracked(f"reviews/{gate['id'].lower()}_acceptance.json"):
        return 'POST_ACCEPTANCE'
    original = blob(c, state['baseline'], policy['module'])
    current = (c.root/policy['module']).read_bytes()
    history = state.get('executor_history', [])
    if not history:
        # Empty/reserved attempt directories are deliberately irrelevant. Any actual
        # invocation evidence or gate-owned Lean material forbids this branch.
        runs = c.runtime/'runs'/gate['id']
        need(not list(runs.rglob('*invocation*.json')), 'unrecorded invocation')
        need(not list(runs.rglob('executor_final.md')), 'unrecorded completion')
        need(not list(runs.rglob('shared_candidate.json')), 'unrecorded candidate')
        need(current == original, 'unauthorized semantic change before dispatch')
        need(not list((c.root/'Aiyagari1994/Analysis'/gate['id']).rglob('*.lean')),
             'candidate helpers before dispatch')
        need(all(not (c.root/(n.replace('.', '/')+'.lean')).exists() for n in policy['imports']),
             'candidate import before dispatch')
        return 'PRE_EXECUTOR'
    h = history[-1]
    need(h.get('gate_id') == gate['id'] and h.get('outcome') == 'COMPLETED',
         'incomplete executor is not a verified candidate')
    directory = c.attempt_directory(gate, h['attempt'])
    need(json.loads((directory/'executor_invocation.json').read_text()) == h,
         'invocation/state mismatch')
    r = json.loads((directory/'shared_candidate.json').read_text())
    need(r['gate'] == gate['id'] and r['baseline'] == state['baseline'] and r['invocation'] == h,
         'candidate identity')
    need(r['executor_final_sha256'] == sha((directory/'executor_final.md').read_bytes()),
         'completion hash')
    need(r['baseline_sha256'] == sha(original), 'candidate baseline hash')
    need(r['files'] == semantic_files(c, gate, policy), 'stale candidate hashes')
    need(current != original, 'completed executor produced no shared candidate')
    need(all((c.root/(n.replace('.', '/')+'.lean')).is_file() for n in policy['imports']),
         'candidate helpers missing')
    return 'POST_EXECUTOR'

def accepted_baseline(c, gate, state, module, current):
    """Validate the latest accepted chain, including fresh Lean fingerprints."""
    from shared_provenance import certify
    matches = [g for g in c.gates if POLICIES.get(g['id'], {}).get('module') == module
               and c.tracked(f"reviews/{g['id'].lower()}_acceptance.json")]
    need(bool(matches), 'missing accepted predecessor certificate')
    latest = matches[-1]
    if not c.tracked(f"reviews/{gate['id'].lower()}_acceptance.json"):
        need(c.gates.index(latest) < c.gates.index(gate), 'wrong accepted predecessor')
    cert = certify(c, latest)
    need(cert['source_sha256'] == sha(current), 'accepted candidate hash')
    need(cert['provenance_chain'][-1]['gate'] == latest['id'], 'wrong accepted predecessor')
    return cert

def context_preflight(c, gate, state):
    """Run even when an interface takes the unchanged-source fast path."""
    if gate['id'] not in POLICIES or state.get('gate') != gate['id']:
        return None
    lifecycle = phase(c, gate, state)
    policy = POLICIES[gate['id']]
    if lifecycle == 'PRE_EXECUTOR':
        matches = [g for g in c.gates if POLICIES.get(g['id'], {}).get('module') == policy['module']
                   and c.tracked(f"reviews/{g['id'].lower()}_acceptance.json")]
        if matches:
            accepted_baseline(c, gate, state, policy['module'], (c.root/policy['module']).read_bytes())
    return lifecycle

REPAIR_FILES = {
    'orchestration/shared_lifecycle.py', 'orchestration/context_shared.py',
    'orchestration/gate_context.py', 'orchestration/orchestrate.py',
    'orchestration/tests/test_context_shared.py',
    'orchestration/tests/test_shared_lifecycle.py',
    'reports/pre_executor_shared_provenance_repair.md',
    'reports/stage10a_np03_context_stop.md',
}

def eligible_repair(state):
    need(state['status'] == 'HUMAN_STOP' and state['gate'] in POLICIES,
         'not a stopped shared gate')
    need(state.get('diagnostic', '').endswith('shared certificate missing current certificate'),
         'different incident')
    need(state['attempt'] == 1 and state['revisions'] == 0
         and state['executor_effort_index'] == 0 and not state['executor_history'],
         'not first undispatched execution')
    need(not state.get('snapshot_sha256') and not state.get('reviewer_verdict')
         and not state.get('acceptance_committed'), 'review already reached')

def resume_predispatch(c, receipt_path, receipt_sha, expected_head):
    """Explicitly authorized incident reconciliation, preserving the empty reservation."""
    import copy
    from orchestrate import atomic_json
    with c.lock():
        path = Path(receipt_path); raw = path.read_bytes(); receipt = json.loads(raw)
        state = c.status(); eligible_repair(state)
        need(sha(raw) == receipt_sha and sha(c.state_path.read_bytes()) == receipt['state_sha256'],
             'receipt/state changed')
        head = c.git('rev-parse', 'HEAD').strip()
        need(head == expected_head, 'repair head')
        c.git('merge-base','--is-ancestor',receipt['head'],head)
        need(not c.git('rev-list','--merges',receipt['head']+'..'+head).strip(), 'repair history')
        prefix = c.git('rev-parse', '--show-prefix').strip()
        need(set(c.git('diff', '--name-only', receipt['head'], head).splitlines())
             == {prefix+n for n in REPAIR_FILES}, 'repair scope')
        need(not c.git('diff', '--cached', '--name-only').strip(), 'dirty index')
        files = c.project_files()
        select = lambda d: {n:h for n,h in d.items() if n not in REPAIR_FILES}
        need(select(files) == select(receipt['files']), 'mathematics or observation changed')
        for n in REPAIR_FILES:
            need(files[n] == sha(blob(c, head, n)), 'dirty infrastructure')
        for n,h in receipt['runtime_hashes'].items():
            need(sha(Path(n).read_bytes()) == h, 'original runtime evidence changed')
        gate = next(g for g in c.gates if g['id'] == state['gate'])
        need(context_preflight(c, gate, state) == 'PRE_EXECUTOR', 'candidate already exists')
        c.preserve()
        attempt = c.attempt_directory(gate, 1)
        need(str(attempt) == receipt['empty_attempt'] and attempt.is_dir()
             and not list(attempt.iterdir()), 'reservation is not empty')
        archived = path.parent/'preserved_empty_attempt_001'
        need(not archived.exists(), 'reservation already reconciled')
        candidate = copy.deepcopy(state)
        candidate.update(baseline=head, initial_files=files, initial_gate=gate['id'], owned_files=files)
        for k in ('diagnostic','stop_class','resume_phase','snapshot_path','snapshot_manifest_path',
                  'reviewer_history','reviewer_history_path','review_output_dir','review_attempt_dir'):
            candidate.pop(k, None)
        validate_precontracts(c,gate,candidate)
        atomic_json(path.parent/'reconciliation.json', {
            'classification':CLASSIFICATION, 'original_diagnostic':state['diagnostic'],
            'infrastructure_commit':head, 'receipt_sha256':receipt_sha,
            'model_calls':0, 'substantive_revisions':0, 'next_effort':'medium',
            'preserved_reservation':str(archived), 'accepted_math_unchanged':True})
        attempt.rename(archived)
        c.save(candidate, 'READY_TO_EXECUTE')
        return {'status':candidate['status'], 'gate':gate['id'], 'model_calls':0,
                'substantive_revisions':0, 'next_effort':'medium'}

def validate_precontracts(c, gate, state):
    """Pre-dispatch is neither review-ready nor accepted; freeze the exact baseline."""
    current=(c.root/'contracts/theorems.json').read_bytes()
    need(current==blob(c,state['baseline'],'contracts/theorems.json'), 'pre-dispatch contract mutation')
    ts={t['id']:t for t in json.loads(current)['theorems']}
    need(all(ts[cid]['status']=='UNFORMALIZED' for cid in gate['contracts']), 'pre-dispatch promotion')
