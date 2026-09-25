"""Observational CLI telemetry. No model calls, retries or prompt mutations.
Observed schema: turn.completed.usage in preserved installed-CLI JSONL.
"""
import json,hashlib,re
from pathlib import Path
from datetime import datetime,timezone
FIELDS=('input_tokens','cached_input_tokens','cache_write_input_tokens','output_tokens','reasoning_output_tokens')

def now():return datetime.now(timezone.utc).isoformat()
def read(p):return json.loads(Path(p).read_text())
def write(p,x):
    p=Path(p);p.parent.mkdir(parents=True,exist_ok=True);p.write_text(json.dumps(x,indent=2,sort_keys=True)+'\n')
def emitted_usage(path):
    records=[];bad=0
    if Path(path).exists():
        for line in Path(path).read_text().splitlines():
            try:event=json.loads(line)
            except ValueError:bad+=1;continue
            if not isinstance(event,dict) or event.get('type')!='turn.completed' or not isinstance(event.get('usage'),dict):continue
            usage={k:v for k,v in event['usage'].items() if re.fullmatch(r'[a-z][a-z0-9_]*',k) and (v is None or type(v) in (int,float))}
            records.append({'type':'turn.completed','usage':usage})
    return {'events':records,'actual_usage':{key:(sum(x['usage'][key] for x in records) if records and all(type(x['usage'].get(key)) in (int,float) for x in records) else None) for key in FIELDS},'availability':'emitted by installed Codex CLI' if records else 'not emitted by installed Codex CLI','malformed_jsonl_lines':bad}

def measure(directory):
    directory=Path(directory);files=[p for p in directory.rglob('*') if p.is_file()] if directory.exists() else []
    return {'bytes':sum(p.stat().st_size for p in files),'files':len(files),'source_evidence_bytes':sum(p.stat().st_size for p in files if 'source_evidence' in p.parts and p.suffix=='.pdf'),'capsule_bytes':(directory/'gate_context.json').stat().st_size if (directory/'gate_context.json').is_file() else None}

def begin(c,role,prompt,cwd,out,model,effort):
    """Failures return None: measurement must not invalidate execution."""
    try:
        meta=read(out/('executor_invocation.json' if role=='executor' else 'reviewer_invocation.json'))
        gate=meta.get('gate_id') or read(Path(cwd)/'gate_context.json')['gate_id']
        state=read(c.state_path) if c.state_path.exists() else {}
        label='executor' if role=='executor' else 'reviewer_'+effort
        directory=c.runtime/'usage'/gate;directory.mkdir(parents=True,exist_ok=True)
        number=max([int(p.stem.rsplit('_',1)[1]) for p in directory.glob(label+'_*.json')]+[0])+1
        context=measure(c.runtime/'contexts'/gate if role=='executor' else cwd)
        cachepath=c.runtime/'usage_cache'/(gate+'.json');cache=read(cachepath) if cachepath.exists() else None
        record={'stage':gate[1:3],'gate':gate,'role':label,'model':model,'reasoning_effort':effort,'invocation_number':number,'substantive_revision_number':state.get('revisions',0),'prompt_characters':len(prompt),'prompt_bytes':len(prompt.encode()),'gate_capsule_bytes':context['capsule_bytes'],'packaged_context_bytes':context['bytes'],'packaged_context_files':context['files'],'source_evidence_bytes':context['source_evidence_bytes'],'cached_accepted_interfaces_used':any(cache.values()) if cache is not None else None,'interface_cache_hits':cache,'started_at':now(),'finished_at':None,'exit_code':None,'raw_events_path':str(out/(role+'_events.jsonl')),'actual_usage':None,'availability':'invocation in progress'}
        path=directory/f'{label}_{number:03d}.json';write(path,record);return path,record
    except Exception:return None

def finish(observation,exit_code=None):
    if observation is None:return
    path,record=observation
    try:
        events=Path(record['raw_events_path']);record.update(emitted_usage(events));record.update(finished_at=now(),exit_code=exit_code,raw_events_sha256=hashlib.sha256(events.read_bytes()).hexdigest() if events.exists() else None);write(path,record)
    except Exception:
        try:record.update(finished_at=now(),actual_usage=None,availability='telemetry parsing failed; raw invocation evidence preserved');write(path,record)
        except Exception:pass

def ledger(c,accepted_gate=None):
    gates=[]
    stage=c.config['stage_checkpoint'][5:7]
    ids={g['id']:g['contracts'][0] for g in c.gates if g['id'].startswith('M'+stage)}
    for gate in ids:
        records=[read(p) for p in sorted((c.runtime/'usage'/gate).glob('*.json'))]
        if not records:continue
        exe=[x for x in records if x['role']=='executor'];reviews=[x for x in records if x['role'].startswith('reviewer_')]
        accepted=(c.root/f'reviews/{gate.lower()}_acceptance.json').exists() or gate==accepted_gate
        gates.append({'gate':gate,'contract':ids[gate],'accepted':accepted,'executor':{'model':'gpt-5.6-sol','efforts':[x['reasoning_effort'] for x in exe],'invocations':len(exe)},'review':{'initial_model':'gpt-6-astra','initial_effort':'high','high_invocations':sum(x['role']=='reviewer_high' for x in reviews),'xhigh_adjudication_used':any(x['role']=='reviewer_xhigh' for x in reviews)},'invocations':records})
    return {'usage_source':'Installed Codex CLI turn.completed.usage; exact fields, no character-based token estimates','gates':gates}

def smoke(c,directory,started,exit_code):
    try:
        directory=Path(directory);events=directory/'events.jsonl'
        prompt='Do not use any tools, read files, or perform mathematics. Reply exactly: ASTRA_SUBSCRIPTION_OK\n'
        record={'stage':c.config['stage_checkpoint'][5:7],'gate':'PREFLIGHT','role':'reviewer_high','purpose':'availability smoke, not mathematical review','model':c.config['reviewer_model'],'reasoning_effort':c.config['reviewer_reasoning'],'invocation_number':len(list((c.runtime/'usage/PREFLIGHT').glob('*.json')))+1,'substantive_revision_number':0,'prompt_characters':len(prompt),'gate_capsule_bytes':0,'packaged_context_bytes':0,'packaged_context_files':0,'source_evidence_bytes':0,'cached_accepted_interfaces_used':False,'started_at':started,'finished_at':now(),'exit_code':exit_code,'raw_events_path':str(events),'raw_events_sha256':hashlib.sha256(events.read_bytes()).hexdigest(),**emitted_usage(events)}
        write(c.runtime/'usage/PREFLIGHT'/f"reviewer_high_{record['invocation_number']:03d}.json",record)
    except Exception:pass
