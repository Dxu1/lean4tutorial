"""Exact, provenance-bound context selection. No model calls or contract writes.
Unknown routes, missing signatures/sources and incomplete snapshots fail closed.
"""
from pathlib import Path
import json,re,hashlib,subprocess,sys,shutil
from axiom_records import parse_axiom_records
from review_evidence import required_sources

def canonical(x):return json.dumps(x,sort_keys=True,separators=(',',':'),ensure_ascii=False).encode()
def sha(b):return hashlib.sha256(b).hexdigest()
def read(p):return json.loads(Path(p).read_text())
def write(p,x):
    p=Path(p);p.parent.mkdir(parents=True,exist_ok=True);p.write_bytes(canonical(x)+b'\n')
def require(ok,msg):
    if not ok:raise ValueError('REVIEW_CONTEXT_INCOMPLETE: '+msg)

def section(text,heading):
    lines=text.splitlines(keepends=True);matches=[i for i,l in enumerate(lines) if l.rstrip()==heading]
    require(len(matches)==1,'ambiguous/missing heading '+heading);i=matches[0];level=len(heading)-len(heading.lstrip('#'));j=i+1
    while j<len(lines):
        m=re.match(r'^(#+) ',lines[j])
        if m and len(m[1])<=level:break
        j+=1
    return ''.join(lines[i:j]),i+1,j

def signatures(audit,names):
    result={};lines=audit.splitlines(keepends=True)
    for name in names:
        starts=[i for i,l in enumerate(lines) if re.match(r'^'+re.escape(name)+r'(?:\s|:|\{)',l)]
        require(len(starts)==1,'signature missing/duplicate '+name);i=starts[0];j=i+1
        while j<len(lines) and (lines[j].startswith((' ','\t')) or not lines[j].strip()):j+=1
        value=''.join(lines[i:j]).rstrip();require(':' in value,'signature truncated '+name);result[name]=value
    return result

ROUTES={
 'H07':('## 4. Policy shape, right marginals, and the envelope theorem',1),
 'H08':('## 4. Policy shape, right marginals, and the envelope theorem',2),
 'H09':('### 4.1 A marginal inequality valid before imposing impatience',3),
 'H10':('### 4.2 Consumption positivity in the impatient region',4),
 'H11':('### 4.3 Envelope and Euler conditions',5),
 'H12':('### 4.3 Envelope and Euler conditions',6),
 'H13':('### 5.1 A positive binding interval',7),
 'H14':('### 5.2 A sufficient condition for never binding',8),
 'D01':('### 5.3 Exact continuous-state counterexample to the unqualified note','## Exact diagnostic D01'),
 'H06':('### 6.1 Continuity before stationarity','## Joint continuity'),
 'D02':('### 6.2 A locally uniform version of Proposition 4','## Uniform drift construction to implement'),
 'D03':('### 6.2 A locally uniform version of Proposition 4','## Uniform drift construction to implement'),
}

def extract(root,path,heading=None,number=None):
    data=(root/path).read_bytes();text=data.decode()
    if number:
        lines=text.splitlines(keepends=True);hits=[i for i,l in enumerate(lines) if l.startswith(str(number)+'. ')];require(len(hits)==1,'numbered proof route');i=hits[0];j=i+1
        while j<len(lines) and lines[j].strip() and not re.match(r'^\d+\. |^#',lines[j]):j+=1
        selected=''.join(lines[i:j]);first,last=i+1,j
    else:selected,first,last=section(text,heading)
    return {'text':selected,'provenance':{'source_file':path,'heading':heading,'numbered_step':number,'first_line':first,'last_line':last,'source_sha256':sha(data)}}

class ContextBuilder:
    def __init__(self,c,root=None):
        self.cache_hits={};self.c=c;self.root=Path(root or c.root);self.contracts=read(self.root/'contracts/theorems.json')['theorems'];self.by={t['id']:t for t in self.contracts}
        self.catalog={s['id']:s for s in read(self.root/'contracts/source_manifest.json')['sources']}
    def qualifications(self):
        # Compact one-copy authority; each original entry and originating association retained.
        path=self.root/'reports/stage03_accepted_qualifications.json'
        if path.exists():
            records=read(path)['records']
        else:
            records=[]
            for p in sorted((self.root/'reviews').glob('*acceptance.json')):
                r=read(p)
                for kind in ('qualifications','nonblocking_findings'):
                    for text in r.get(kind,[]):records.append({'originating_gate':r['gate_id'],'originating_contracts':r.get('contract_ids',[]),'text':text,'category':kind,'acceptance_record':str(p.relative_to(self.root))})
        # Include later accepted records not represented by the frozen Stage-03 consolidation.
        known={r['acceptance_record'] for r in records}
        for p in sorted((self.root/'reviews').glob('*acceptance.json')):
            name=str(p.relative_to(self.root));r=read(p)
            if name in known:continue
            for kind in ('qualifications','nonblocking_findings'):
                for text in r.get(kind,[]):records.append({'originating_gate':r['gate_id'],'originating_contracts':r.get('contract_ids',[]),'text':text,'category':kind,'acceptance_record':name})
        return [{**r,'qualification_id':'q'+str(i+1),'applicability':'mandatory unless explicitly superseded by design authority'} for i,r in enumerate(records)]
    def acceptance(self,cid):
        t=self.by[cid];require(t['status']=='GREEN','unaccepted dependency '+cid)
        for p in sorted((self.root/'reviews').glob('*acceptance.json')):
            r=read(p)
            if cid in r.get('contract_ids',[]):
                commit=r.get('accepted_commit_sha') or self.c.git('log','-1','--diff-filter=A','--format=%H','--',str(p.relative_to(self.root))).strip()
                require(bool(commit) and r.get('final_verdict') in ('PASS','ACCEPT'),'dependency acceptance')
                return str(p.relative_to(self.root)),commit,r['snapshot_sha256'],r.get('qualifications',[])+r.get('nonblocking_findings',[])
        stage=t['stage'];name={'01':'01','02':'02a'}.get(stage)
        if cid=='H05':name='02b'
        require(bool(name),'missing acceptance '+cid);p='reviews/'+name+'_acceptance.md';data=(self.root/p).read_text();require('Decision: ACCEPT' in data,'human dependency acceptance')
        match=re.search(r'SHA-256:\s*`?([a-f0-9]{64})',data);require(match is not None,'acceptance archive hash')
        commit=self.c.git('log','-1','--diff-filter=A','--format=%H','--',p).strip()
        return p,commit,match[1],[data]  # Earlier human qualifications retained verbatim, never invented.
    def interface(self,cid):
        t=self.by[cid];record,commit,snapshot,qual=self.acceptance(cid);prefix=self.c.git('rev-parse','--show-prefix').strip()
        accepted=subprocess.check_output(['git','show',commit+':'+prefix+t['module']],cwd=self.c.root)
        require((self.root/t['module']).read_bytes().startswith(accepted),'accepted implementation changed '+cid)
        key={'contract':t,'acceptance_commit':commit,'snapshot_sha256':snapshot,'acceptance_record_sha256':sha((self.root/record).read_bytes()),'accepted_source_sha256':sha(accepted),'toolchain':(self.root/'lean-toolchain').read_text(),'mathlib_manifest_sha256':sha((self.root/'lake-manifest.json').read_bytes())}
        cache=self.c.runtime/'accepted_interfaces'/cid/(sha(canonical(key))+'.json')
        tracked=self.c.root/'reports/accepted_interfaces'/f'{cid}.json'
        for path in (tracked,cache):
            if path.exists():
                envelope=read(path);payload=envelope['payload'];require(sha(canonical(payload))==envelope['sha256'],'interface cache hash')
                if payload['cache_key']==key:
                    self.cache_hits[cid]=True;return payload
        # Reconstruct exact elaborated signature from accepted tracked source and pinned Lean.
        work=self.c.runtime/'interface_build';work.mkdir(parents=True,exist_ok=True);probe=work/(cid+'.lean')
        probe.write_text('import '+t['module'][:-5].replace('/','.')+'\n#check '+t['declaration']+'\n#print axioms '+t['declaration']+'\n')
        result=subprocess.run(['lake','env','lean',str(probe)],cwd=self.c.root,text=True,capture_output=True)
        require(result.returncode==0,'interface signature build '+cid);(work/(cid+'.log')).write_text(result.stdout+result.stderr)
        sig=signatures(result.stdout,[t['declaration']])[t['declaration']];ax=parse_axiom_records(result.stdout,[t['declaration']])[0]['axioms']
        payload={'contract_id':cid,'declaration':t['declaration'],'exact_elaborated_signature':sig,'assumptions':t['assumptions'],'dependencies':t['dependencies'],'accepted_status':'GREEN','acceptance_commit':commit,'acceptance_snapshot_sha256':snapshot,'qualifications':qual,'permitted_transitive_axioms':['propext','Classical.choice','Quot.sound'],'actual_transitive_axioms':ax,'implementation_source':t['module'],'acceptance_record':record,'cache_key':key,'producer':'pinned lake env lean #check/#print axioms of preserved accepted source','signature_log_sha256':sha(result.stdout.encode())}
        self.cache_hits[cid]=False
        write(cache,{'payload':payload,'sha256':sha(canonical(payload))});return payload
    def capsule(self,gate,baseline,preview=False):
        assigned=[self.by[x] for x in gate['contracts']];profiles=read(self.root/'contracts/assumptions.json')['profiles'];ex=[]
        for t in assigned:
            require(t['id'] in ROUTES,'no authorized extract mapping '+t['id']);heading,step=ROUTES[t['id']];prompt='prompts/'+('04_continuity_and_uniform_drift.md' if t['stage']=='04' else '03_household_analysis.md')
            ex.append(extract(self.root,'docs/architecture.md',heading=heading));ex.append(extract(self.root,prompt,number=step) if isinstance(step,int) else extract(self.root,prompt,heading=step))
        deps=sorted({d for t in assigned for d in t['dependencies']} - set(gate['contracts']));interfaces={cid:self.interface(cid) for cid in deps}
        data={'predecessor_statuses':{t['id']:t['status'] for t in self.contracts if t['status']=='GREEN'},'version':1,'gate_id':gate['id'],'preview_only':preview,'execution_authorized':False,'authorization_note':'Context only; execution requires explicit controller dispatch within authorized gates.','assigned_contracts':assigned,'assumption_profiles':{a:profiles[a] for t in assigned for a in t['assumptions']},'accepted_baseline':baseline,'dependencies':{d:self.by[d]['status'] for d in deps},'intra_gate_dependencies':sorted({d for t in assigned for d in t['dependencies']} & set(gate['contracts'])),'authorized_semantic_files':sorted({t['module'] for t in assigned}|{'All.lean','Audit.lean','docs/proof_ledger.md','docs/proof_ledger.tex','docs/proof_ledger.pdf','contracts/theorems.json'}|{gate[k] for k in ('signature_probe','report','analytical_audit') if k in gate}),'helper_directory':'Aiyagari1994/Analysis/'+gate['id']+'/','extracts':ex,'policy':{'executor':['medium','high','xhigh'],'reviewer':['high','xhigh'],'no_API_billing':True,'contract_freeze':'status only; never notes','predecessor_qualifications':'predecessor_qualifications.json','mandatory':True},'provenance':[{'source_file':'contracts/theorems.json','field':'theorems[id in '+','.join(gate['contracts'])+']','sha256':sha((self.root/'contracts/theorems.json').read_bytes())},{'source_file':'contracts/assumptions.json','field':'profiles[assigned assumptions]','sha256':sha((self.root/'contracts/assumptions.json').read_bytes())}]}
        return data,interfaces,self.qualifications()
    def write_capsule(self,gate,baseline,dest,preview=False):
        data,interfaces,quals=self.capsule(gate,baseline,preview);dest=Path(dest);dest.mkdir(parents=True,exist_ok=True);write(dest/'gate_context.json',data);write(dest/'contracts.json',data['assigned_contracts']);write(dest/'predecessor_qualifications.json',quals)
        for cid,interface in interfaces.items():write(dest/'dependencies'/f'{cid}.json',interface)
        for i,e in enumerate(data['extracts']):
            write(dest/'extracts'/f'{i+1}.json',e)
        if self.c.config.get('usage_telemetry_version')==1:write(self.c.runtime/'usage_cache'/(gate['id']+'.json'),self.cache_hits)
        return data,interfaces,quals

    def source_pages(self,assigned,dest):
        ids=sorted({sid for t in assigned for sid in required_sources(t,self.catalog)});out=[]
        try:from pypdf import PdfReader,PdfWriter
        except ImportError:PdfReader=PdfWriter=None
        for sid in ids:
            s=self.catalog[sid];data=(self.c.root/'sources/papers'/s['local_name']).read_bytes();require(sha(data)==s['sha256'],'source hash '+sid)
            locators=[t['source_locator'] for t in assigned if sid in required_sources(t,self.catalog)];pages=set();printed=[]
            for loc in locators:
                # Each semicolon-separated source clause binds its own PDF/printed locator.
                clauses=[x for x in loc.split(';') if re.search(r'\b'+re.escape(sid)+r'\b',x)]
                require(bool(clauses),'source locator clause '+sid)
                for clause in clauses:
                    m=re.search(r'PDF\s+p(?:p)?\.\s*(\d+)(?:\s*[-–]\s*(\d+))?',clause);require(m is not None,'source PDF pages '+sid)
                    pages.update(range(int(m[1]),int(m[2] or m[1])+1));printed.append(clause.strip())
            # D01 source-fidelity question requires maintained assumptions, not merely the note.
            if sid=='A93' and any(t['id']=='D01' for t in assigned):pages.update([11,12,13,14,38,39])
            require(all(1<=p<=s['pdf_pages'] for p in pages),'PDF page bounds')
            name=sid+'_pages.pdf';target=Path(dest)/name;target.parent.mkdir(parents=True,exist_ok=True)
            fallback=PdfReader is None
            if fallback:
                interpreters=sorted((Path.home()/'.cache/codex-runtimes').glob('*/dependencies/python/bin/python3'))
                for interpreter in interpreters:
                    result=subprocess.run([str(interpreter),str(self.c.o/'pdf_pages.py'),str(self.c.root/'sources/papers'/s['local_name']),str(target),s['sha256'],json.dumps(sorted(pages))],capture_output=True)
                    if result.returncode==0:fallback=False;break
            if not fallback and PdfReader is not None:
                import io
                try:
                    reader=PdfReader(io.BytesIO(data));writer=PdfWriter()
                    for p in sorted(pages):writer.add_page(reader.pages[p-1])
                    writer.write(target);require(len(PdfReader(target).pages)==len(pages),'extracted page count')
                except Exception:
                    # Do not use a damaged/partial extract. Exact approved original is the safe fallback.
                    fallback=True
            if fallback:target.write_bytes(data)
            out.append({'source_id':sid,'file':name,'original_filename':s['local_name'],'original_sha256':s['sha256'],'artifact_sha256':sha(target.read_bytes()),'original_pdf_pages':sorted(pages),'printed_locators':printed,'contract_locators':locators,'full_pdf_fallback':fallback,'extra_context':('D01 maintained assumptions, printed 10–13/PDF 11–14 and appendix 37–38/PDF 38–39' if sid=='A93' and any(t['id']=='D01' for t in assigned) else None)})
        write(Path(dest)/'index.json',out);return out

def compact_evidence(root,verification,new_names,dest):
    """Use hash-verified controller output, never executor-authored report summaries."""
    verification=Path(verification);summary=read(verification/'deterministic_summary.json');records=summary['checks']
    needed={'targeted_build','full_build','audit','contracts','signatures','documentation','transitive_axioms','assert_no_sorry','prohibited_patterns','export_inventory','source_validation','frozen_scope','git_diff_check','new_file_diff_check'}
    require(needed<=set(records),'missing deterministic producer')
    for k,v in records.items():
        artifact=verification/Path(v['path']).name
        require(v['exit_code']==0 and artifact.is_file() and sha(artifact.read_bytes())==v['sha256'],'deterministic artifact '+k)
    audit=(verification/'audit.log').read_text();all_names=re.findall(r'^#print axioms (\S+)\s*$',(Path(root)/'Audit.lean').read_text(),re.M)
    axioms=parse_axiom_records(audit,all_names);sigs=signatures(audit,new_names)
    ax={x['declaration']:x['axioms'] for x in axioms}
    result={'version':1,'producer':'controller verified process exit codes, hashes, exact signature and complete-record axiom parsing','checks':{k:{'result':'PASS','producer':v['producer'],'runtime_path':v['path'],'sha256':v['sha256']} for k,v in records.items()},'no_sorry_declaration_count':len(all_names),'axiom_record_count':len(axioms),'axiom_union':sorted({a for x in axioms for a in x['axioms']}),'signature_export_count':len(new_names),'unexpected_exports':[],'source_integrity':'PASS','scope':'PASS','raw_logs_packaged':False}
    write(Path(dest)/'deterministic_summary.json',result);write(Path(dest)/'new_exports.json',new_names);write(Path(dest)/'signatures_summary.json',sigs);write(Path(dest)/'axioms_summary.json',{'new_exports':{n:ax[n] for n in new_names},'all_declaration_count':len(axioms),'union':result['axiom_union']})
    return result

def changed_lean(builder,baseline):
    prefix=builder.c.git('rev-parse','--show-prefix').strip();changed=[]
    candidates=list(builder.root.glob('*.lean'))
    for directory in ('Aiyagari1994','Probes'):candidates.extend((builder.root/directory).rglob('*.lean'))
    for p in sorted(candidates):
        n=str(p.relative_to(builder.root))
        if not (n.startswith(('Aiyagari1994/','Probes/')) or n in ('All.lean','Audit.lean','Aiyagari1994.lean')):continue
        old=subprocess.run(['git','show',baseline+':'+prefix+n],cwd=builder.c.root,capture_output=True)
        if old.returncode or old.stdout!=p.read_bytes():changed.append(n)
    return changed

def support_sources(builder,changed,interfaces):
    """Conservative identifier-reference closure; exact accepted theorem references
    terminate at certified interfaces. Internal definitions/helpers retain source.
    Merely importing an accepted module does not copy its whole historical closure.
    """
    from orchestrate import strip_lean_comments
    texts={str(p.relative_to(builder.root)):strip_lean_comments(p.read_text()) for p in (builder.root/'Aiyagari1994').rglob('*.lean')}
    definitions={}
    for n,text in texts.items():
        for d in re.findall(r'^\s*(?:(?:private|protected|noncomputable)\s+)*(?:def|abbrev|theorem|lemma|structure|class)\s+([\w.]+)',text,re.M):definitions.setdefault(d.split('.')[-1],set()).add(n)
    certified={v['declaration'].split('.')[-1] for v in interfaces.values()};selected={n for n in changed if n in texts};reasons={}
    queue=list(selected)
    while queue:
        n=queue.pop();tokens=set(re.findall(r'\b\w+\b',texts[n]))-certified
        for token in tokens:
            for target in definitions.get(token,set()):
                if target==n:continue
                reasons.setdefault(target,set()).add(n+'#'+token)
                if target not in selected:selected.add(target);queue.append(target)
    return {n:sorted(reasons.get(n,[])) for n in sorted(selected-set(changed))}

def build_snapshot(builder,gate,baseline,verification,dest,preview=False):
    dest=Path(dest);require(not dest.exists(),'snapshot destination already exists');dest.mkdir(parents=True)
    context,interfaces,quals=builder.write_capsule(gate,baseline,dest,preview)
    changed=[] if preview else changed_lean(builder,baseline)
    if not preview:
        require(all(t['module'] in changed for t in context['assigned_contracts']),'assigned implementation unchanged/missing')
    supports=support_sources(builder,changed,interfaces) if not preview else {}
    for n in changed+list(supports):
        target=dest/n;target.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(builder.root/n,target)
    # A semantic diff includes only selected current-gate Lean files and exact current contract.
    prefix=builder.c.git('rev-parse','--show-prefix').strip();import difflib
    diff=[]
    for n in changed:
        before=subprocess.run(['git','show',baseline+':'+prefix+n],cwd=builder.c.root,capture_output=True)
        diff.extend(difflib.unified_diff(before.stdout.decode().splitlines(True) if before.returncode==0 else [],(builder.root/n).read_text().splitlines(True),fromfile='a/'+n,tofile='b/'+n))
    (dest/'semantic_diff.patch').write_text(''.join(diff));write(dest/'changed_files.json',changed);write(dest/'support_source_reasons.json',supports)
    ledger=(builder.root/'docs/proof_ledger.md').read_text();selected=[]
    for t in context['assigned_contracts']:
        match=re.search(r'^## '+re.escape(t['id'])+r'\b[^\n]*',ledger,re.M);require(match is not None,'ledger section')
        entry,_,_=section(ledger,match[0]);require('**Status:** '+t['status'] in entry,'ledger status');selected.append(entry)
    (dest/'ledger.md').write_text('\n'.join(selected))
    old_ledger=subprocess.run(['git','show',baseline+':'+prefix+'docs/proof_ledger.md'],cwd=builder.c.root,capture_output=True).stdout.decode()
    for t,entry in zip(context['assigned_contracts'],selected):
        hit=re.search(r'^## '+re.escape(t['id'])+r'\b[^\n]*',old_ledger,re.M)
        before=section(old_ledger,hit[0])[0] if hit else ''
        diff.extend(difflib.unified_diff(before.splitlines(True),entry.splitlines(True),fromfile='a/docs/proof_ledger.md#'+t['id'],tofile='b/docs/proof_ledger.md#'+t['id']))
    (dest/'semantic_diff.patch').write_text(''.join(diff))
    sources=builder.source_pages(context['assigned_contracts'],dest/'source_evidence')
    if not preview:
        previous=subprocess.check_output(['git','show',baseline+':'+prefix+'Audit.lean'],cwd=builder.c.root).decode()
        old=set(re.findall(r'^#print axioms (\S+)\s*$',previous,re.M));names=re.findall(r'^#print axioms (\S+)\s*$',(builder.root/'Audit.lean').read_text(),re.M);new=[n for n in names if n not in old]
        require(bool(new) and all(t['declaration'] in new for t in context['assigned_contracts']),'new contract export coverage')
        # Every top-level named public declaration in newly introduced modules must be audited.
        for n in changed:
            if not n.startswith('Aiyagari1994/'):continue
            oldfile=subprocess.run(['git','show',baseline+':'+prefix+n],cwd=builder.c.root,capture_output=True)
            if oldfile.returncode:body=(builder.root/n).read_text()
            else:
                require((builder.root/n).read_text().startswith(oldfile.stdout.decode()),'accepted source prefix changed');body=(builder.root/n).read_text()[len(oldfile.stdout.decode()):]
            for d in re.findall(r'^\s*(?:(?:noncomputable|protected)\s+)*(?:theorem|lemma|def|abbrev)\s+([\w.]+)',body,re.M):
                require(any(x==d or x.endswith('.'+d) for x in new),'unaudited new export '+d)
        compact_evidence(builder.root,verification,new,dest/'verification')
    else:
        new=[];write(dest/'verification/preview.json',{'not_review_ready':True,'execution_authorized':False,'missing':'No M04 implementation, build evidence or review exists; this context preview cannot pass REVIEW_CONTEXT_COMPLETE.'})
    aliases={'context:gate':'gate_context.json','context:diff':'semantic_diff.patch','context:qualifications':'predecessor_qualifications.json'}
    for t in context['assigned_contracts']:aliases['contract:'+t['id']]='contracts.json#'+t['id'];aliases['ledger:'+t['id']]='ledger.md#'+t['id']
    for cid in interfaces:aliases['dep:'+cid]='dependencies/'+cid+'.json'
    for n in changed+list(supports):aliases['lean:'+n]=n
    for name in new:aliases['lean:'+name]='verification/signatures_summary.json#'+name
    for x in sources:aliases['source:'+x['source_id']]='source_evidence/'+x['file']
    for k in ['axioms','signatures','build','audit','scope','sources','documentation','no_sorry']:aliases['verify:'+k]='verification/deterministic_summary.json'
    write(dest/'evidence_aliases.json',aliases)
    shutil.copyfile(builder.c.o/'schemas/compact_review.schema.json',dest/'review.schema.json');shutil.copyfile(builder.c.o/'prompts/compact_reviewer.md',dest/'review_instructions.md')
    (dest/'REVIEW_INDEX.md').write_text('# '+gate['id']+' review index\n\n'+('PREVIEW ONLY — not review-ready or execution authorization.\n\n' if preview else '')+'Begin with gate_context.json and contracts.json. Inspect additional packaged files only as needed to substantiate D01–D20; do not mechanically read every file.\n\n- Current implementation: changed_files.json; exact changes: semantic_diff.patch.\n- Accepted interfaces: dependencies/.\n- All predecessor_qualifications.json entries are mandatory unless explicitly superseded by user/design authority.\n- Internal definitions/helper source selected by identifier use: support_source_reasons.json.\n- Controller verification: verification/deterministic_summary.json, new_exports.json, signatures_summary.json, axioms_summary.json (real submission only).\n- Exact selected proof routes and architecture: extracts/.\n- Ledger: ledger.md. Approved pages and original hashes: source_evidence/index.json.\n- Unambiguous evidence reference IDs: evidence_aliases.json. Use its exact keys as refs.\n- Review instructions: review_instructions.md; schema: review.schema.json. Raw logs remain hash-bound outside this read-only snapshot. Missing substantive evidence must be reported, never guessed.\n')
    files={str(p.relative_to(dest)):sha(p.read_bytes()) for p in sorted(dest.rglob('*')) if p.is_file()}
    manifest={'version':2,'gate':gate['id'],'baseline':baseline,'preview_only':preview,'files':files};write(dest/'snapshot_manifest.json',manifest)
    validate_context(dest,builder,gate,baseline,preview=preview,verification=verification)
    return dest,sha(canonical(manifest))

def validate_context(dest,builder,gate,baseline,preview=False,verification=None):
    dest=Path(dest);m=read(dest/'snapshot_manifest.json');files={str(p.relative_to(dest)):sha(p.read_bytes()) for p in dest.rglob('*') if p.is_file() and p.name!='snapshot_manifest.json'}
    require(files==m['files'] and not any(p.is_symlink() for p in dest.rglob('*')),'snapshot hash coverage')
    require(m['gate']==gate['id'] and m['baseline']==baseline and m['preview_only']==preview,'snapshot identity')
    expected,interfaces,quals=builder.capsule(gate,baseline,preview);require(read(dest/'gate_context.json')==expected,'exact capsule/provenance');require(read(dest/'contracts.json')==expected['assigned_contracts'],'exact contracts');require(read(dest/'predecessor_qualifications.json')==quals,'mandatory qualifications')
    for cid,value in interfaces.items():require(read(dest/'dependencies'/f'{cid}.json')==value,'certified dependency '+cid)
    source_index=read(dest/'source_evidence/index.json');required={sid for t in expected['assigned_contracts'] for sid in required_sources(t,builder.catalog)};require({x['source_id'] for x in source_index}==required,'required source IDs')
    for x in source_index:
        require(x['original_sha256']==builder.catalog[x['source_id']]['sha256'] and sha((dest/'source_evidence'/x['file']).read_bytes())==x['artifact_sha256'],'source hash binding')
        require(x['contract_locators']==[t['source_locator'] for t in expected['assigned_contracts'] if x['source_id'] in required_sources(t,builder.catalog)],'source locator binding')
        pages=set()
        for loc in x['contract_locators']:
            for clause in loc.split(';'):
                if re.search(r'\b'+x['source_id']+r'\b',clause):
                    hit=re.search(r'PDF\s+p(?:p)?\.\s*(\d+)(?:\s*[-–]\s*(\d+))?',clause);require(hit is not None,'locator PDF pages');pages.update(range(int(hit[1]),int(hit[2] or hit[1])+1))
        if x['source_id']=='A93' and any(t['id']=='D01' for t in expected['assigned_contracts']):pages.update([11,12,13,14,38,39])
        require(set(x['original_pdf_pages'])==pages,'required source pages')
    ledger=(dest/'ledger.md').read_text()
    for t in expected['assigned_contracts']:require('## '+t['id']+' ' in ledger and '**Status:** '+t['status'] in ledger,'ledger section/status')
    if preview:return 'PREVIEW_CONTEXT_COMPLETE_NOT_REVIEW_READY'
    require(not expected['preview_only'],'preview cannot authorize review')
    changed=changed_lean(builder,baseline);require(read(dest/'changed_files.json')==changed,'changed semantic file inventory')
    for n in changed:require((dest/n).read_bytes()==(builder.root/n).read_bytes(),'changed Lean file '+n)
    supports=support_sources(builder,changed,interfaces);require(read(dest/'support_source_reasons.json')==supports,'internal dependency source selection')
    for n in supports:require((dest/n).read_bytes()==(builder.root/n).read_bytes(),'required helper source')
    summary=read(dest/'verification/deterministic_summary.json');names=read(dest/'verification/new_exports.json');sigs=read(dest/'verification/signatures_summary.json');ax=read(dest/'verification/axioms_summary.json')
    require(set(sigs)==set(names)==set(ax['new_exports']),'every new export has signature/axioms')
    require(all(t['declaration'] in sigs for t in expected['assigned_contracts']),'contract signature coverage')
    require(summary['signature_export_count']==len(names) and not summary['unexpected_exports'],'export counts')
    require(summary['axiom_record_count']==summary['no_sorry_declaration_count'] and set(summary['axiom_union'])<={'propext','Classical.choice','Quot.sound'},'axiom completeness')
    needed={'targeted_build','full_build','audit','contracts','signatures','documentation','transitive_axioms','assert_no_sorry','prohibited_patterns','export_inventory','source_validation','frozen_scope','git_diff_check','new_file_diff_check'}
    require(needed<=set(summary['checks']) and all(x['result']=='PASS' and x.get('producer') and re.fullmatch('[a-f0-9]{64}',x.get('sha256','')) for x in summary['checks'].values()),'deterministic summary complete')
    prefix=builder.c.git('rev-parse','--show-prefix').strip()
    old=subprocess.check_output(['git','show',baseline+':'+prefix+'Audit.lean'],cwd=builder.c.root).decode()
    previous=set(re.findall(r'^#print axioms (\S+)\s*$',old,re.M))
    current=re.findall(r'^#print axioms (\S+)\s*$',(builder.root/'Audit.lean').read_text(),re.M)
    require(names==[n for n in current if n not in previous],'exact new export inventory')
    require(summary['axiom_record_count']==len(current),'complete audit count')
    require(verification is not None,'missing controller verification directory')
    if verification is not None:
        import tempfile
        with tempfile.TemporaryDirectory() as temp:
            compact_evidence(builder.root,verification,names,Path(temp))
            for name in ('deterministic_summary.json','new_exports.json','signatures_summary.json','axioms_summary.json'):
                require(read(dest/'verification'/name)==read(Path(temp)/name),'controller-produced summary '+name)
    return 'REVIEW_CONTEXT_COMPLETE'


def executor_prompt(gate,directory,revision=None):
    text=f"""Assigned gate {gate['id']}, only contracts {gate['contracts']}. Start from {directory}/gate_context.json, contracts.json, extracts/, dependencies/ and predecessor_qualifications.json. Start from the supplied gate context. Read additional repository material only when needed for the assigned proof. Prefer exact declaration search and relevant sections over reading whole large documents.
All entries in predecessor_qualifications.json are mandatory unless explicitly superseded by user/design authority. Authoritative repository contracts and design remain authoritative. Preserve accepted proofs, assumptions, dependencies and declaration meaning. The capsule authorizes only this assigned gate, never advancement. No mathematical assumptions may be changed. No sorry, admit, project axioms, native_decide, unsafe bypass or numerical models.
The controller owns verification logs, export inventories and evidence under tmp_orchestration. Do not edit orchestration or runtime state. Update assigned report, analytical audit, signature probe and synchronized ledger Markdown/TeX/PDF. Audit every new public declaration with #check, assert_no_sorry and #print axioms. Use exact assigned ledger status **Status:** REVIEW_READY. Only assigned contract status may change; no other field. All new helpers belong to the capsule helper_directory. The controller owns review archives; do not create manual ZIPs. STOP at REVIEW_READY; never self-award GREEN.
"""
    if revision:text+='\nIndependent operative reviewer same-gate revision instruction:\n'+revision+'\n'
    return text
