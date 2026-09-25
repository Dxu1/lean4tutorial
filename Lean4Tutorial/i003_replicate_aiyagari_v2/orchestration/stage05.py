"""Stage-05 boundary audit. No model calls or mathematical mutation."""
import json,subprocess,time
from pathlib import Path
BASE='0751120e622f8f1115a3c4fcd69e7bc6e7a319dc'
IDS=('S01','S02','S03','S04','S05')
def integration(c,state):
    from orchestrate import read_json,atomic_json,Stop,digest,canonical,decision
    c.ensure_clean()
    prefix=c.git('rev-parse','--show-prefix').strip()
    def old(n):return subprocess.check_output(['git','show',BASE+':'+prefix+n],cwd=c.root)
    expected=json.loads(old('contracts/theorems.json'))
    for t in expected['theorems']:
        if t['id'] in IDS:t['status']='GREEN'
    if read_json(c.root/'contracts/theorems.json')!=expected:raise Stop('STAGE05_CONTRACT_MUTATION')
    if state['accepted']!=c.reconstruct_accepted() or len(state['accepted'])!=len(c.gates):raise Stop('STAGE05_ACCEPTANCE_CHAIN')
    protected={}
    for n in c.git('ls-tree','-r','--name-only',BASE,'--','.').splitlines():
        if n.endswith('.lean') or n.startswith('contracts/') or n in ('docs/architecture.md','docs/lean_interfaces.md','docs/dependency_graph.md','lean-toolchain','lake-manifest.json'):
            if n=='contracts/theorems.json':continue
            before=old(n);after=(c.root/n).read_bytes()
            if (not after.startswith(before)) if n in ('All.lean','Audit.lean') else (after!=before):raise Stop('STAGE05_FROZEN_PREFIX: '+n)
            protected[n]=digest(after)
    for t in expected['theorems']:
        if t['stage']=='06' and (t['status']!='UNFORMALIZED' or (c.root/t['module']).exists()):raise Stop('STAGE06_LEAKAGE')
    acceptance={}
    for gate in c.gates[-5:]:
        rec=c.acceptance_record(gate);c.git('merge-base','--is-ancestor',rec['accepted_commit_sha'],'HEAD')
        d=c.root/rec['evidence_directory'];v=read_json(d/'reviewer_final.json')
        if digest(canonical(read_json(d/'snapshot_manifest.json')))!=rec['snapshot_sha256'] or decision(v,gate,v['attempt'],rec['snapshot_sha256'],True)!='ACCEPTANCE_RECORDING':raise Stop('STAGE05_ACCEPTANCE_EVIDENCE')
        acceptance[gate['id']]={k:rec[k] for k in ('accepted_commit_sha','snapshot_sha256','operative_reviewer','final_verdict')}
    directory=c.runtime/'stage05_integration'/str(time.time_ns());directory.mkdir(parents=True)
    c.checks(c.gates[-1],directory)
    for gate in c.gates[-5:]:
        p=subprocess.run(['lake','env','lean',gate['signature_probe']],cwd=c.root,text=True,capture_output=True)
        (directory/(gate['id']+'_signatures.log')).write_text(p.stdout+p.stderr)
        if p.returncode:raise Stop('STAGE05_SIGNATURE_CHECK_FAILED: '+gate['id'])
    report={'result':'PASS','baseline':BASE,'audited_head':c.git('rev-parse','HEAD').strip(),'acceptances':acceptance,'contracts_frozen_except_authorized_statuses':True,'accepted_prefix_preserved':protected,'no_stage06':True,'summary':read_json(directory/'deterministic_summary.json')}
    atomic_json(c.root/'reports/stage05_integration_audit.json',report)
    (c.root/'reports/stage05_integration_audit.md').write_text('# Stage-05 integration audit\n\nPASS. S01–S05 are independently accepted and GREEN. The acceptance chain is contiguous. All earlier accepted Lean modules and mathematical contracts remain frozen; only append-only root audit/import additions and authorized Stage-05 status promotions occurred. No Stage-06 promotion or implementation exists. Fresh full/targeted builds, all five signature probes, audit, no-sorry, axiom, prohibited-pattern, ledger, source and contract checks passed. Exact check producers, hashes and acceptance commits are in the accompanying JSON. Reviewer qualifications remain operative.\n')
    c.git('add','--','reports/stage05_integration_audit.json','reports/stage05_integration_audit.md')
    c.git('commit','-m','Record passing Stage 05 integration boundary audit')
    state['integration_report']='reports/stage05_integration_audit.json'
    state['integration_commit']=c.git('rev-parse','HEAD').strip()
