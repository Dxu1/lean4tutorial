"""Bounded structured reviews and restartable High -> XHigh adjudication.
No executor calls or executor-counter writes occur here.
"""
import json,re
from pathlib import Path
DIMENSIONS=tuple(f'D{i:02d}' for i in range(1,21))
SUBTLE={'D02','D03','D04','D09','D10','D11','D17'}
CORE={'D01','D02','D05','D06','D07','D13','D14','D15','D16','D17','D18','D19','D20'}

def dimensions(value, aliases=None):
    if not isinstance(value,dict):raise ValueError('review must be an object')
    items=value.get('dimension_assessments')
    if not isinstance(items,list) or len(items)!=20: raise ValueError('exactly twenty dimensions required')
    seen=set()
    for x in items:
        if not isinstance(x,dict) or set(x)!={'dimension_id','status','refs','summary'}:raise ValueError('compact dimension fields')
        did,status,refs,summary=(x[k] for k in ('dimension_id','status','refs','summary'))
        if did not in DIMENSIONS or did in seen:raise ValueError('duplicate/unknown dimension')
        seen.add(did)
        if status not in ('PASS','FAIL','UNCERTAIN','NOT_APPLICABLE'):raise ValueError('dimension status')
        if not isinstance(refs,list) or not 1<=len(refs)<=5 or not all(isinstance(r,str) and re.fullmatch(r'(contract|lean|dep|source|verify|ledger|context):[^\s]+',r) for r in refs):raise ValueError('evidence refs required')
        if aliases is not None and any(r not in aliases for r in refs):raise ValueError('unknown evidence reference')
        limit=(400 if did in SUBTLE else 240) if status=='PASS' else 1000
        if not isinstance(summary,str) or not 24<=len(summary)<=limit or len(summary.split())<4 or re.fullmatch(r'(?:all |the )?(?:checks |evidence |requirements |dimensions )?(?:pass|passed|correct|adequate|verified|satisfied)[.! ]*',summary,re.I):raise ValueError('generic or overlong summary')
        if status!='PASS' and (len(summary)<60 or len(summary.split())<9):raise ValueError('detailed non-PASS explanation required')
        if status=='NOT_APPLICABLE' and (did in CORE or not re.search(r'\b(because|since|does not|not required)\b',summary,re.I)):raise ValueError('applicability explanation required')
    for a in value.get('contract_assessments',[]):
        if len(a.get('assessment',''))> (1200 if value.get('verdict')=='PASS' else 4000):raise ValueError('overlong contract assessment')
    for kind in ('blocking_findings','nonblocking_findings'):
        for f in value.get(kind,[]):
            if not isinstance(f,str) or len(f)>1200 or not re.search(r'(contract|lean|dep|source|verify|ledger|context):\S+',f):raise ValueError('finding needs evidence reference')
    return value

def adjudicate(c,gate,state,attempt_dir,prompt,retry=False):
    """Journal completed calls before the controller interprets any operative verdict.
    Restart reuses completed immutable journal entries, never repeats High needlessly.
    Invalid/schema output gets one fresh retry per effort, then High escalates.
    Infrastructure/identity/mutation failures stop immediately; never launder them.
    """
    from orchestrate import atomic_json,read_json,decision,validate_review,digest,Stop
    sha=state['snapshot_sha256']; journal=attempt_dir/('review_history_'+sha+'.json')
    if journal.exists(): history=read_json(journal)
    else:history={'snapshot_sha256':sha,'initial':None,'adjudication':None,'operative':None}
    if history['snapshot_sha256']!=sha:raise Stop('REVIEW_IDENTITY_MISMATCH')
    aliases=read_json(Path(state['snapshot_path'])/'evidence_aliases.json')
    for phase,effort in [('initial','high'),('adjudication','xhigh')]:
        result=history[phase]
        if result is None:
            for schema_try in range(2):
                out=attempt_dir/f'reviewer_{sha[:12]}_{phase}_{schema_try+1}'
                out.mkdir(exist_ok=True)
                meta={'model':'gpt-6-astra','effort':effort,'phase':phase,'schema_attempt':schema_try+1,'snapshot_sha256':sha}
                atomic_json(out/'reviewer_invocation.json',meta)
                # No High verdict/prose enters the independent adjudicator's prompt.
                current_prompt=prompt+ ('\nReturn the required schema exactly; all twenty substantive dimensions are required.\n' if schema_try else '')
                (out/'review_prompt.md').write_text(current_prompt)
                c.verify_snapshot(state)
                if c.project_files()!=state['reviewed_files']:raise Stop('PROJECT_CHANGED_SINCE_REVIEW')
                final=out/'reviewer_final.json'
                if final.exists(): raw=final.read_text()
                else:raw=c.model_run('reviewer',current_prompt,Path(state['snapshot_path']),out);final.write_text(raw)
                c.verify_snapshot(state)
                if c.project_files()!=state['reviewed_files']:raise Stop('REVIEWER_PROJECT_MUTATION')
                error=None;verdict=None;action=None
                try:
                    verdict=json.loads(raw)
                    if isinstance(verdict,dict) and any(verdict.get(k)!=v for k,v in {'gate_id':gate['id'],'attempt':state['attempt'],'snapshot_sha256':sha}.items()):raise Stop('REVIEW_IDENTITY_MISMATCH')
                    validate_review(verdict);dimensions(verdict,aliases)
                    action=decision(verdict,gate,state['attempt'],sha,True,c.config['max_revisions'],state.get('revisions',0))
                except Stop as e:
                    if 'IDENTITY' in str(e):raise
                    error=str(e)
                except (ValueError,TypeError,KeyError) as e:error=str(e)
                atomic_json(out/'validation.json',{'error':error,'action':action,'raw_sha256':digest(raw.encode())})
                if error is None or schema_try==1:
                    result={**meta,'output_directory':str(out),'verdict':verdict if error is None else None,'validation_error':error,'action':action,'raw_sha256':digest(raw.encode())}
                    history[phase]=result;atomic_json(journal,history);break
        # Revalidate previously journaled output; never trust mutable runtime metadata alone.
        directory=Path(result['output_directory']);raw=(directory/'reviewer_final.json').read_text()
        if digest(raw.encode())!=result['raw_sha256']:raise Stop('REVIEW_JOURNAL_CHANGED')
        if not result['validation_error']:
            verdict=json.loads(raw);validate_review(verdict);dimensions(verdict,aliases)
            action=decision(verdict,gate,state['attempt'],sha,True,c.config['max_revisions'],state.get('revisions',0))
        else:action='HUMAN_STOP'
        if phase=='initial' and (result['validation_error'] or action!='ACCEPTANCE_RECORDING'):continue
        history['operative']=phase;atomic_json(journal,history)
        state['reviewer_history']=history;state['reviewer_history_path']=str(journal)
        state['operative_reviewer']={'model':'gpt-6-astra','effort':effort,'phase':phase}
        if result['validation_error']:raise Stop('MALFORMED_REVIEW_AFTER_SCHEMA_RETRY_AND_ADJUDICATION')
        return raw,directory
    raise Stop('REVIEW_ADJUDICATION_STATE_INVALID')
