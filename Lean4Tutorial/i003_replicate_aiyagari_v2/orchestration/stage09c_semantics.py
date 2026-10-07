"""Fingerprint unchanged G01 constructors/definitions in the actual gate environment."""
import json,subprocess,tempfile
from pathlib import Path
from orchestrate import Stop,atomic_json,digest,canonical,clean_environment
BASE='ca1bd0748618cc64a4dac64865c1cfc4cdd1baf5'

def collect(c,module):
    prefix=c.git('rev-parse','--show-prefix').strip()
    for n in ('Aiyagari1994/Equilibrium/Definition.lean','Aiyagari1994/Analysis/M09A2/EquilibriumDefinition.lean'):
        if (c.root/n).read_bytes()!=subprocess.check_output(['git','show',BASE+':'+prefix+n],cwd=c.root):raise Stop('G01_SOURCE_CHANGED')
    c.command_log('targeted_build',['lake','build',module],c.runtime/'g01_fingerprints'/str(__import__('time').time_ns()))
    with tempfile.TemporaryDirectory(prefix='g01-fingerprint-') as tmp:
        p=Path(tmp)/'Fingerprint.lean';p.write_text('import '+module+'\nimport Aiyagari1994.Equilibrium.Definition\nimport Lean\n'+(c.root/'orchestration/g01_fingerprint.txt').read_text())
        r=subprocess.run(['lake','env','lean',str(p)],cwd=c.root,env=clean_environment(),capture_output=True,text=True)
        if r.returncode:raise Stop('G01_FINGERPRINT_FAILED: '+r.stdout[-1000:]+r.stderr[-500:])
        records=json.loads(r.stdout)
    if len(records)!=7 or any(x['unsafe'] or not set(x['axioms'])<={'propext','Classical.choice','Quot.sound'} for x in records):raise Stop('G01_FINGERPRINT_INCOMPLETE')
    return records

def initialize_g01(c):
    p=c.runtime/'g01_fingerprints/baseline.json'
    if p.exists():raise Stop('G01_BASELINE_ALREADY_EXISTS')
    records=collect(c,'Aiyagari1994.Equilibrium.Definition');atomic_json(p,records)
    existence=collect_existence(c)
    old=json.loads((c.root/'reports/stage09b_integration_audit.json').read_text())['G02_semantic_fingerprint']
    raw=(Path(old['evidence_directory'])/'candidate_raw.json').read_bytes()
    if digest(raw)!=old['artifacts']['candidate_raw.json'] or json.loads(raw)!=existence:raise Stop('STAGE09B_EXISTENCE_SEMANTICS_CHANGED')
    atomic_json(c.runtime/'g01_fingerprints/existence_baseline.json',existence)
    return {'G01':digest(canonical(records)),'G02_G03':digest(canonical(existence))}

def certify_g01(c,gate):
    baseline=c.runtime/'g01_fingerprints/baseline.json'
    accepted=json.loads(baseline.read_text())
    reg=json.loads((c.root/'reviews/stage09c_authorization.json').read_text())
    if digest(canonical(accepted))!=reg['G01_baseline_sha256']:raise Stop('G01_BASELINE_FINGERPRINT_CHANGED')
    current=collect(c,gate['module'][:-5].replace('/','.'))
    if current!=accepted:raise Stop('G01_ELABORATED_SEMANTICS_CHANGED')
    return {'result':'PASS','accepted_baseline':BASE,'baseline_sha256':digest(canonical(accepted)),
        'candidate_sha256':digest(canonical(current)),'source_unchanged':True,
        'method':'Lean environment exact structural type/value of G01 core/constructors/definition; no source-only fallback',
        'declarations':current,'unrestricted_definition_preserved':True}


def collect_existence(c):
    c.command_log('targeted_build',['lake','build','Aiyagari1994.Equilibrium.Existence'],c.runtime/'g01_fingerprints'/str(__import__('time').time_ns()))
    with tempfile.TemporaryDirectory(prefix='existence-fingerprint-') as tmp:
        p=Path(tmp)/'Fingerprint.lean';p.write_text('import Aiyagari1994.Equilibrium.Existence\nimport Lean\n'+(c.root/'orchestration/semantic_fingerprint.txt').read_text())
        r=subprocess.run(['lake','env','lean',str(p)],cwd=c.root,env=clean_environment(),capture_output=True,text=True)
        if r.returncode:raise Stop('EXISTENCE_FINGERPRINT_FAILED: '+r.stdout[-1000:]+r.stderr[-500:])
        return json.loads(r.stdout)

def certify_existence(c):
    baseline=json.loads((c.runtime/'g01_fingerprints/existence_baseline.json').read_text())
    reg=json.loads((c.root/'reviews/stage09c_authorization.json').read_text())
    if digest(canonical(baseline))!=reg['G02_G03_baseline_sha256']:raise Stop('EXISTENCE_BASELINE_CHANGED')
    current=collect_existence(c)
    if current!=baseline:raise Stop('G02_G03_ELABORATED_SEMANTICS_CHANGED')
    return {'result':'PASS','baseline_sha256':digest(canonical(baseline)),'candidate_sha256':digest(canonical(current)),
        'accepted_declarations':[r['name'] for r in current],'method':'Exact Lean type/value/metadata/project dependency/axiom equality against Stage09b acceptance'}
