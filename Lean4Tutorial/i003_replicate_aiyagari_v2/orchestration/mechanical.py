"""Controller-owned mechanical evidence. No model calls or semantic writes."""
import errno
import hashlib
import json
import os
from pathlib import Path
import re
import subprocess


def sha(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def write_json(path, value):
    path=Path(path); path.parent.mkdir(parents=True,exist_ok=True)
    temp=path.with_suffix(path.suffix+'.tmp')
    temp.write_text(json.dumps(value,sort_keys=True,indent=2)+'\n'); os.replace(temp,path)


class MechanicalEvidence:
    def __init__(self, controller):
        self.c=controller
        self.registry=json.loads((controller.o/'artifacts.json').read_text())
        if self.registry.get('version')!=1: raise controller.error('INVALID_ARTIFACT_REGISTRY')
        self.types=self.registry['artifacts']
        for kind,definition in self.types.items():
            name=definition['filename']
            if Path(name).name!=name or definition['hygiene']!='raw' or not definition['hash_recorded']:
                raise controller.error('INVALID_ARTIFACT_REGISTRY: '+kind)

    def paths(self, gate, attempt):
        gid=gate['id'] if isinstance(gate,dict) else gate
        if gid not in {g['id'] for g in self.c.gates} or type(attempt)!=int or attempt<1:
            raise self.c.error('INVALID_ARTIFACT_IDENTITY')
        root=self.c.runtime/'runs'/gid/f'attempt_{attempt:03d}'
        return {'attempt':root,'checks':root/'checks','durable':f'reports/logs/{gid.lower()}/review'}

    def batch(self,gate,attempt,phase):
        if phase not in ('pre_review','acceptance'): raise self.c.error('UNKNOWN_CHECK_PHASE')
        root=self.paths(gate,attempt)['checks'];root.mkdir(parents=True,exist_ok=True)
        for number in range(1,100):
            path=root/f'{phase}_{number:03d}'
            if not path.exists(): path.mkdir(); return path
        raise self.c.error('CHECK_BATCH_LIMIT')

    def artifact(self,directory,kind):
        if kind not in self.types: raise self.c.error('UNKNOWN_MECHANICAL_ARTIFACT: '+kind)
        directory=Path(directory)
        if not directory.resolve().is_relative_to(self.c.runtime.resolve()): raise self.c.error('MECHANICAL_OUTPUT_OUTSIDE_RUNTIME')
        directory.mkdir(parents=True,exist_ok=True)
        return directory/self.types[kind]['filename']

    def capture(self,directory,kind,text,exit_code=0,producer=None):
        path=self.artifact(directory,kind)
        if path.exists(): raise self.c.error('MECHANICAL_OUTPUT_ALREADY_EXISTS: '+str(path))
        path.write_text(text)
        self.record(directory,kind,path,exit_code,producer or self.types[kind]['producer'])
        return path

    def record(self,directory,kind,path,exit_code,producer,retries=None):
        index=Path(directory)/'process_records.json'
        records=json.loads(index.read_text()) if index.exists() else {}
        records[kind]={'artifact_type':kind,'path':str(path),'sha256':sha(path),
                       'producer':producer,'exit_code':exit_code,'retries':retries or []}
        write_json(index,records)

    def command(self,name,args,directory,environment):
        path=self.artifact(directory,name)
        if path.exists(): raise self.c.error('MECHANICAL_OUTPUT_ALREADY_EXISTS: '+str(path))
        retries=[]
        retry_errnos={getattr(errno,n) for n in self.registry['transient_retry']['errno_names']}
        for retry in range(self.registry['transient_retry']['max_retries']+1):
            try:
                with path.open('w') as out:
                    out.write('Command: '+json.dumps(args)+'\n');out.flush()
                    result=subprocess.run(args,cwd=self.c.root,env=environment,stdout=out,stderr=subprocess.STDOUT,text=True)
                    out.write(f'\nExit: {result.returncode}\n')
                self.record(directory,name,path,result.returncode,args,retries)
                if result.returncode: raise self.c.error('DETERMINISTIC_CHECK_FAILED: '+name)
                return path.read_text()
            except OSError as error:
                if path.exists():
                    retained=path.with_name(path.name+f'.interrupted_{retry}');os.replace(path,retained)
                    retries.append({'outcome':'RETRY_INFRASTRUCTURE','errno':error.errno,'path':str(retained),'sha256':sha(retained)})
                write_json(Path(directory)/(name+'_retry.json'),retries)
                if error.errno not in retry_errnos or retry>=self.registry['transient_retry']['max_retries']:
                    raise self.c.error('INFRASTRUCTURE_CHECK_FAILURE: '+name) from error

    def summary(self,directory,counts,require_complete=False):
        records_path=Path(directory)/'process_records.json'
        records=json.loads(records_path.read_text()) if records_path.exists() else {}
        if require_complete and not {k for k,v in self.types.items() if v['mandatory']}<=set(records):
            raise self.c.error('MISSING_MANDATORY_MECHANICAL_CHECK')
        for entry in records.values():
            if sha(entry['path'])!=entry['sha256']: raise self.c.error('RAW_EVIDENCE_CHANGED')
            if entry['exit_code']!=0: raise self.c.error('FAILED_CHECK_IN_SUMMARY')
        summary={'passed':True,'counts':counts,'checks':records,
            'raw_files':{str(p):sha(p) for p in sorted(Path(directory).rglob('*')) if p.is_file()},
            'runtime_directory':str(directory)}
        write_json(Path(directory)/'deterministic_summary.json',summary)
        return summary

    def validate_runtime(self,gate,attempt):
        root=self.paths(gate,attempt)['checks']
        if not root.exists():return
        allowed=set()
        journal=root/'migration.json'
        if journal.exists():
            allowed.add(journal.resolve())
            migration=json.loads(journal.read_text())
            for entry in migration['files'].values():allowed.add(Path(entry['runtime_path']).resolve())
        for directory in root.iterdir():
            if not directory.is_dir() or not re.fullmatch(r'(pre_review|acceptance)_\d{3}',directory.name):continue
            record=directory/'process_records.json'
            if not record.exists():continue
            records=json.loads(record.read_text())
            allowed.add(record.resolve())
            for kind,entry in records.items():
                if kind not in self.types or Path(entry['path']).resolve()!=self.artifact(directory,kind).resolve():
                    raise self.c.error('HUMAN_REVIEW: INVALID_RUNTIME_ARTIFACT_RECORD')
                if sha(entry['path'])!=entry['sha256']:raise self.c.error('HUMAN_REVIEW: RUNTIME_ARTIFACT_HASH_MISMATCH')
                allowed.add(Path(entry['path']).resolve())
                for retry in entry['retries']:allowed.add(Path(retry['path']).resolve())
                allowed.add((directory/(kind+'_retry.json')).resolve())
            allowed.update((directory/n).resolve() for n in ('checks.json','deterministic_summary.json'))
        for path in root.rglob('*'):
            if path.is_symlink():raise self.c.error('HUMAN_REVIEW: RUNTIME_SYMLINK')
            if path.is_file() and path.resolve() not in allowed:raise self.c.error('HUMAN_REVIEW: UNREGISTERED_RUNTIME_EVIDENCE: '+str(path))

    def plan_legacy(self,gate,state,initial):
        """Legacy migration only: bounded paths, known process, unchanged semantics.

        A compound shell exit is provenance, not proof of individual tool success.
        The controller independently reruns all mandatory checks before review.
        """
        current=self.c.project_files(); candidates={}
        for kind,definition in self.types.items():
            name=definition.get('legacy_filename')
            if not name: continue
            for stem in (gate['id'].lower(),gate['id'][1:].lower()):
                path=f'reports/logs/{stem}/{name}'
                if path in current and path not in initial:
                    if self.c.tracked(path): raise self.c.error('HUMAN_REVIEW: TRACKED_MECHANICAL_MIGRATION')
                    candidates[path]=(kind,definition)
        if not candidates: return {}
        events_path=self.paths(gate,state['attempt'])['attempt']/'executor_events.jsonl'
        if not events_path.is_file(): raise self.c.error('HUMAN_REVIEW: AMBIGUOUS_ARTIFACT_PROVENANCE')
        events=[]
        for line in events_path.read_text().splitlines():
            try: event=json.loads(line)
            except ValueError: raise self.c.error('HUMAN_REVIEW: MALFORMED_PRODUCER_RECORD')
            item=event.get('item',{})
            if event.get('type')=='item.completed' and item.get('type')=='command_execution':events.append(item)
        plan={}
        for path,(kind,definition) in candidates.items():
            pattern=r'(?:>{1,2}\s*|\btee\s+(?:-a\s+)?)[\'"]?'+re.escape(path)+r'(?:[\'"\s;]|$)'
            writes=[e for e in events if re.search(pattern,e.get('command',''))]
            if not writes or writes[-1].get('exit_code')!=0 or not all(t in writes[-1].get('command','') for t in definition['legacy_producer_tokens']):
                raise self.c.error('HUMAN_REVIEW: AMBIGUOUS_ARTIFACT_PROVENANCE: '+path)
            text=(self.c.root/path).read_text()
            if kind=='frozen_scope':
                marker='Accepted substantive predecessor modules changed (expected empty):'
                if marker not in text or text.split(marker,1)[1].strip():
                    raise self.c.error('HUMAN_REVIEW: SCOPE_LOG_SIGNALS_MUTATION')
            plan[path]={'kind':kind,'sha256':current[path],'producer_event':writes[-1].get('id'),
                'producer_command':writes[-1]['command'],'process_exit':writes[-1]['exit_code'],
                'event_log_sha256':sha(events_path)}
        return plan

    def reconcile(self,gate,state,initial):
        # Finish a recorded copy/unlink transaction after a crash, verifying all bytes.
        base=self.paths(gate,state['attempt'])['checks']; journal=base/'migration.json'
        if journal.exists():
            saved=json.loads(journal.read_text())
            self._finish_migration(saved,journal)
        self.validate_runtime(gate,state['attempt'])
        plan=self.plan_legacy(gate,state,initial)
        self.c._semantic_scope(gate,state,initial,ignored=set(plan))
        if not plan: return self.c.project_files()
        if journal.exists(): raise self.c.error('HUMAN_REVIEW: REPEATED_LEGACY_ARTIFACT_DEVIATION')
        before=self.c.project_files();dest=base/'migrated_executor';dest.mkdir(parents=True,exist_ok=True)
        for name,entry in plan.items():
            target=dest/(name.replace('/','__'))
            if target.exists(): raise self.c.error('MIGRATION_DESTINATION_EXISTS')
            target.write_bytes((self.c.root/name).read_bytes())
            if sha(target)!=entry['sha256']: raise self.c.error('MIGRATION_COPY_MISMATCH')
            entry['runtime_path']=str(target)
            entry['snapshot_path']='legacy_executor_evidence/'+target.name
        saved={'outcome':'AUTO_RECONCILE','gate':gate['id'],'attempt':state['attempt'],
            'files':plan,'semantic_hashes':{n:h for n,h in before.items() if n not in plan},'complete':False}
        write_json(journal,saved)
        self._finish_migration(saved,journal)
        return self.c.project_files()

    def _finish_migration(self,saved,journal):
        files=self.c.project_files();migrated=saved['files']
        # A completed migration's semantics may later change by an authorized revision.
        # Never revisit/remove a reappearing artifact under that old journal.
        if saved.get('complete'):
            if any(n in files for n in migrated): raise self.c.error('HUMAN_REVIEW: REPEATED_LEGACY_ARTIFACT_DEVIATION')
            if any(sha(e['runtime_path'])!=e['sha256'] for e in migrated.values()):raise self.c.error('MIGRATED_EVIDENCE_CHANGED')
            return
        if {n:h for n,h in files.items() if n not in migrated}!=saved['semantic_hashes']:
            raise self.c.error('HUMAN_REVIEW: SEMANTIC_CHANGE_DURING_MIGRATION')
        for name,entry in migrated.items():
            if sha(entry['runtime_path'])!=entry['sha256']:raise self.c.error('MIGRATION_COPY_MISMATCH')
            source=self.c.root/name
            if source.exists():
                if self.c.tracked(name) or sha(source)!=entry['sha256']:raise self.c.error('MIGRATION_SOURCE_CHANGED')
        for name in migrated:
            source=self.c.root/name
            if source.exists():source.unlink()
        saved['complete']=True;write_json(journal,saved)
