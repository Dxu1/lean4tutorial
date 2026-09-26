"""Explicit one-shot A03 post-acceptance repair, isolated from historical Stage-06 runs."""
import json,re,subprocess,shutil
from pathlib import Path
from orchestrate import Controller,PROJECT,Stop,read_json,atomic_json,digest
BASE='f6761a7e0ae0d6d5404598cd7331db85a943d647'
REG='reviews/a03_repair_registration.json'
MODULE='Aiyagari1994/Aggregate/ParameterContinuity.lean'
AUTHORITY='''User-authorized same-contract A03 completion only. Expose genuine joint continuity on ImpatientPrices m × Real with independent normalized price and debt-shift coordinates, for the actual stationaryAssetSupply integral. Reuse the accepted stationaryMeanShiftedAssets_continuous and integrability/decomposition proofs byte-for-byte. Preserve the existing graph theorem; add an audited graph corollary by composition if useful. Add only append-only declarations to the A03 public module, reopening its namespace as necessary. Do not change any other accepted Lean body, contract semantics, or Stage-07 work. Update only the A03 ledger section plus generated status overview. Explain zero-net-rate nonidentification concisely, and retain economic normalization/nonnegative-debt qualifications. The previous graph-only coverage acceptance is historical and superseded for interface coverage by this explicit request; all other predecessor qualifications remain operative. Review independently whether joint (q, phi) variation is now covered throughout the strictly impatient region. No preference for any historical reviewer verdict is prescribed. Include the unchanged contract anchor and every new export in the exact signature probe. Synchronize the global ledger status overview. Use exact ledger status line **Status:** REVIEW_READY. (including the period).'''

def ledger_status(text,status,contracts):
    pat=r'(^## A03\b[^\n]*\n)(.*?)(?=^## |\Z)'
    def change(m):
        body,n=re.subn(r'^\*\*Status:\*\*[^\n]*',f'**Status:** {status}. **Scope:** core. **Milestone:** 06. **Gate:** M06DR.',m[2],count=1,flags=re.M)
        if n!=1:raise Stop('REPAIR_LEDGER_STATUS_AMBIGUOUS')
        return m[1]+body
    text,n=re.subn(pat,change,text,flags=re.M|re.S)
    if n!=1:raise Stop('REPAIR_LEDGER_SECTION_AMBIGUOUS')
    statuses={status:[t['id'] for t in contracts['theorems'] if t['status']==status] for status in ('GREEN','IN_PROGRESS','REVIEW_READY','UNFORMALIZED')}
    overview='**Economic status:** '+ '; '.join(', '.join(ids)+' are **'+status+'**' for status,ids in statuses.items() if ids)+'. M00 bootstrap acceptance remains infrastructure only. Exact acceptance records are in `reviews/`. Proposed proof plans remain proposed until checked.'
    text,n=re.subn(r'^\*\*Economic status:\*\*[^\n]*',lambda _:overview,text,count=1,flags=re.M)
    if n!=1:raise Stop('REPAIR_OVERVIEW_AMBIGUOUS')
    return text

class RepairController(Controller):
    repair_authority=AUTHORITY
    repair_export='Aiyagari1994.stationaryAssetSupply_jointly_continuous'
    def __init__(self,root=PROJECT):
        super().__init__(root)
        self.runtime=self.root/'tmp_orchestration/a03_repair';self.state_path=self.runtime/'state.json'
        g=dict(self.gates[-1]);g.update(id='M06DR',signature_probe='Probes/M06DRSignatures.lean',report='reports/m06dr_milestone.md',analytical_audit='reports/m06dr_analytical_audit.md')
        self.gates=self.gates[:-1]+[g]
    def usage_report_path(self,gate):return 'reports/stage06_a03_repair_usage_metrics.json'
    def gate_prompt(self,gate,state):return super().gate_prompt(gate,state)+'\n'+AUTHORITY+'\n'
    def _semantic_scope(self,gate,state,initial,ready=True,ignored=()):
        result=super()._semantic_scope(gate,state,initial,ready,ignored)
        self.preserve_predecessors()
        return result
    def preserve_predecessors(self):
        reg=read_json(self.root/REG)
        for n,h in reg['protected_files'].items():
            if not (self.root/n).is_file() or digest((self.root/n).read_bytes())!=h:raise Stop('REPAIR_PREDECESSOR_CHANGED: '+n)
        # The mean-continuity proof and all accepted helper modules are protected above.
        prefix=self.git('rev-parse','--show-prefix').strip()
        old=self.git('show',BASE+':'+prefix+'docs/proof_ledger.md');new=(self.root/'docs/proof_ledger.md').read_text()
        def strip(s):
            s=re.sub(r'^\*\*Economic status:\*\*[^\n]*','',s,flags=re.M)
            return re.sub(r'^## A03\b.*?(?=^## |\Z)','',s,flags=re.M|re.S)
        if strip(old)!=strip(new):raise Stop('REPAIR_UNRELATED_LEDGER_CHANGED')
    def finish_stage(self,state):
        self.preserve_predecessors()
        from stage06 import integration
        integration(self,state)
        self.save(state,self.checkpoint)
        return state

def activate(c):
    with c.lock():
        c.ensure_clean()
        if (c.root/REG).exists():raise Stop('A03_REPAIR_ALREADY_REGISTERED')
        old=c.status()
        if old['status']!='STAGE06_COMPLETE_HUMAN_CHECKPOINT' or old['accepted']!=c.reconstruct_accepted():raise Stop('A03_REPAIR_CHECKPOINT_REQUIRED')
        if c.git('branch','--show-current').strip()!='issue3':raise Stop('A03_REPAIR_BRANCH')
        c.git('merge-base','--is-ancestor',BASE,'HEAD')
        if read_json(c.root/'reports/stage06_integration_audit.json')['result']!='PASS':raise Stop('A03_REPAIR_INTEGRATION_REQUIRED')
        files=c.project_files();protected={n:h for n,h in files.items() if (n.endswith('.lean') and n not in (MODULE,'Audit.lean','All.lean')) or n.startswith('reviews/') or n.startswith('reports/logs/') or n in ('reports/stage06_usage_metrics.json','reports/stage06_usage_report.md','contracts/assumptions.json','contracts/milestones.json','contracts/source_manifest.json','docs/architecture.md','docs/lean_interfaces.md')}
        record=c.acceptance_record(c.gates[-1]);contracts=read_json(c.root/'contracts/theorems.json');target=next(t for t in contracts['theorems'] if t['id']=='A03')
        if target['status']!='GREEN':raise Stop('A03_REPAIR_ACCEPTED_TARGET_REQUIRED')
        rc=RepairController(c.root);rc.runtime.mkdir(parents=True,exist_ok=True)
        if (c.runtime/'preflight.json').exists():shutil.copyfile(c.runtime/'preflight.json',rc.runtime/'preflight.json')
        atomic_json(rc.runtime/'original_state.json',old);atomic_json(rc.runtime/'original_files.json',files)
        for n in ('contracts/theorems.json','docs/proof_ledger.md','docs/proof_ledger.tex','docs/proof_ledger.pdf'):
            p=rc.runtime/'activation_backup'/n;p.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(c.root/n,p)
        atomic_json(c.root/REG,{'kind':'A03_SAME_CONTRACT_REPAIR','historical_acceptance':record,'historical_checkpoint':BASE,'activation_parent':c.git('rev-parse','HEAD').strip(),'protected_files':protected,'authority':AUTHORITY,'new_gate':'M06DR','new_acceptance_path':'reviews/m06dr_acceptance.json','stop_checkpoint':c.checkpoint})
        target['status']='IN_PROGRESS';(c.root/'contracts/theorems.json').write_text(json.dumps(contracts,indent=2,ensure_ascii=False)+'\n')
        p=c.root/'docs/proof_ledger.md';p.write_text(ledger_status(p.read_text(),'IN_PROGRESS',contracts))
        result=subprocess.run(['bash','tools/build_docs.sh','proof_ledger'],cwd=c.root,text=True,capture_output=True)
        (rc.runtime/'activation_documentation.log').write_text(result.stdout+result.stderr)
        if result.returncode:raise Stop('A03_REPAIR_ACTIVATION_DOCUMENTATION')
        c.git('add','--',REG,'contracts/theorems.json','docs/proof_ledger.md','docs/proof_ledger.tex','docs/proof_ledger.pdf');c.git('commit','-m','Register A03 joint-continuity repair and reopen review status')
        state={'status':'READY_TO_EXECUTE','gate':'M06DR','attempt':1,'baseline':c.git('rev-parse','HEAD').strip(),'accepted':old['accepted'][:-1],'snapshot_sha256':None,'reviewer_verdict':None,'acceptance_committed':False,'revisions':0,'executor_effort_index':0,'executor_invocation_reason':'INITIAL','executor_history':[]}
        rc.save(state,'READY_TO_EXECUTE');rc.preserve_predecessors();return state
