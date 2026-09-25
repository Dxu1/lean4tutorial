"""No-model historical comparison and explicitly non-executable M04 preview."""
import json,shutil
from pathlib import Path
from orchestrate import Controller,canonical,digest
from gate_context import ContextBuilder,build_snapshot,executor_prompt,read,write

def size(root,prompt,executor):
    files=[p for p in root.rglob('*') if p.is_file()]
    return {'files':len(files),'bytes':sum(p.stat().st_size for p in files),'reviewer_prompt_characters':len(prompt),'reviewer_prompt_bytes':len(prompt.encode()),'executor_prompt_characters':len(executor),'executor_prompt_bytes':len(executor.encode()),'source_evidence_bytes':sum(p.stat().st_size for p in files if 'source_evidence' in p.parts and p.suffix=='.pdf'),'deterministic_log_bytes':sum(p.stat().st_size for p in files if 'verification' in p.parts and p.suffix=='.log')}

def main():
    c=Controller();out=c.runtime/'token_efficiency_refactor';out.mkdir(exist_ok=True)
    historic=[p for p in (c.runtime/'review_snapshots').glob('M03C_attempt_001_*') if read(p/'snapshot_manifest.json').get('version')==1]
    if len(historic)!=1:raise ValueError('ambiguous historical H12 snapshot')
    old=historic[0];manifest=read(old/'snapshot_manifest.json');c.verify_snapshot({'snapshot_path':str(old),'snapshot_sha256':digest(canonical(manifest))})
    gate=next(g for g in c.gates if g['id']=='M03C');attempt=c.runtime/'runs/M03C/attempt_001'
    target=out/'H12_compact'
    if target.exists():shutil.rmtree(target)
    new,newsha=build_snapshot(ContextBuilder(c,old),gate,manifest['baseline'],old/'verification',target)
    prompt=(c.o/'prompts/compact_reviewer.md').read_text()+f"\nGate: M03C; assigned contracts: ['H12']; attempt: 1; snapshot_sha256: {newsha}\n"
    ep=executor_prompt(gate,Path('tmp_orchestration/contexts')/gate['id'])
    (out/'H12_executor_prompt.md').write_text(ep);(out/'H12_reviewer_prompt.md').write_text(prompt)
    before=size(old,(attempt/'review_prompt.md').read_text(),(attempt/'executor_prompt.md').read_text());after=size(new,prompt,ep)
    after['executor_context_bytes']=sum(p.stat().st_size for p in [new/'gate_context.json',new/'contracts.json',new/'predecessor_qualifications.json']+list((new/'dependencies').glob('*.json'))+list((new/'extracts').glob('*.json')))
    previewgate={'id':'M04_PREVIEW','contracts':['H06','D02','D03']}
    preview=out/'M04_preview'
    if preview.exists():shutil.rmtree(preview)
    build_snapshot(ContextBuilder(c),previewgate,c.git('rev-parse','HEAD').strip(),None,preview,True)
    pep='PREVIEW ONLY; DO NOT INVOKE AN EXECUTOR.\n'+executor_prompt(previewgate,Path('tmp_orchestration/contexts/M04_PREVIEW'));(out/'M04_preview_prompt.txt').write_text(pep)
    metrics={'no_model_calls':True,'historical_H12':{'original_snapshot_sha256':digest(canonical(manifest)),'optimized_snapshot_sha256':newsha,'old':before,'optimized':after,'reductions_percent':{k:round(100*(before[k]-after[k])/before[k],4) for k in before if before[k]}},'M04_preview':{'gate':previewgate,'execution_authorized':False,'review_ready':False,'gate_capsule_bytes':(preview/'gate_context.json').stat().st_size,'executor_prompt_characters':len(pep),'executor_prompt_bytes':len(pep.encode()),'executor_input_bytes':sum(p.stat().st_size for p in preview.rglob('*.json') if p.name!='snapshot_manifest.json')+len(pep.encode()),'semantic_snapshot':size(preview,'',pep),'accepted_dependency_interfaces':len(list((preview/'dependencies').glob('*.json')))},'units':'bytes and Unicode characters, NOT tokens'}
    write(out/'metrics.json',metrics)
    # Tracked interface derivatives make reconstruction independent of ignored caches.
    for directory in (new/'dependencies',preview/'dependencies'):
        for p in directory.glob('*.json'):
            payload=read(p);write(c.root/'reports/accepted_interfaces'/p.name,{'payload':payload,'sha256':digest(canonical(payload))})
    print(json.dumps(metrics,indent=2))
if __name__=='__main__':main()
