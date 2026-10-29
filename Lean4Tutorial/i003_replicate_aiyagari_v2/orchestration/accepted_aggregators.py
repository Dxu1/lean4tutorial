"""Post-acceptance root validation replays certified history, never C -> C deltas."""
import json
from pathlib import Path
from orchestrate import digest,canonical
from root_aggregators import need,REGISTRY,CONTRACTS,ACCEPTED_COUNTS,accepted_provenance,graph_check,compare_fingerprints
CLASSIFICATION='POST_ACCEPTANCE_ROOT_AGGREGATOR_PROVENANCE_REPLAY_ERROR'

def certify(c,gate,name='All.lean'):
    need(name in REGISTRY and gate['id'] in REGISTRY[name],'UNREGISTERED_AGGREGATOR_GATE')
    need(gate['contracts']==[CONTRACTS[gate['id']]] and gate['module']==REGISTRY[name][gate['id']][0].replace('.','/')+'.lean','AGGREGATOR_WRONG_GATE')
    need(c.tracked(f"reviews/{gate['id'].lower()}_acceptance.json"),'AGGREGATOR_ACCEPTANCE_MISSING')
    chain=accepted_provenance(c)
    matches=[n for n in chain['chain'] if n['certificate']['gate']==gate['id']]
    need(len(matches)==1,'AGGREGATOR_ACCEPTANCE_MISSING')
    # Every historical comparison remains B -> C, pinned by its accepted snapshot.
    for node in chain['chain']:
        cert=node['certificate'];d=Path(cert['evidence_directory'])
        names=cert['accepted_declarations']
        need(len(names)==ACCEPTED_COUNTS[cert['gate']] and cert['accepted_declaration_count']==len(names),'AGGREGATOR_ACCEPTED_INVENTORY')
        need(set(cert['artifacts'])=={'baseline_fingerprints.json','candidate_fingerprints.json'},'AGGREGATOR_ARTIFACT_INVENTORY')
        for n,h in cert['artifacts'].items():
            need((d/n).is_file() and digest((d/n).read_bytes())==h,'AGGREGATOR_ARTIFACT_CHANGED')
        before=json.loads((d/'baseline_fingerprints.json').read_text());after=json.loads((d/'candidate_fingerprints.json').read_text())
        compare_fingerprints(before,after,names)
        need(digest(canonical(before))==cert['baseline_fingerprints_sha256'] and digest(canonical(after))==cert['candidate_fingerprints_sha256'],'AGGREGATOR_FINGERPRINT_BINDING')
    # Inspect today's complete project graph too: history cannot authorize a new
    # reverse import, cycle, missing project module or a silently altered source.
    prefix=c.git('rev-parse','--show-prefix').strip()
    paths=[n for n in c.project_files() if n.endswith('.lean') and (n in ('All.lean','Audit.lean','Aiyagari1994.lean') or n.startswith(('Aiyagari1994/','Probes/')))]
    sources={n:(c.root/n).read_bytes() for n in paths}
    for n,raw in sources.items():
        need(c.tracked(n) and c.git('show','HEAD:'+prefix+n).encode()==raw,'AGGREGATOR_CHANGED_AFTER_ACCEPTANCE: '+n)
    graph=graph_check(sources,sources,gate,[])
    return {'result':'PASS','classification':CLASSIFICATION,'phase':'POST_ACCEPTANCE',
            'gate':gate['id'],'contract':CONTRACTS[gate['id']],'aggregator':name,
            'current_sha256':digest((c.root/name).read_bytes()),
            'terminal_accepted_sha256':chain['certificate']['candidate_sha256'],
            'accepted_chain':chain,'graph':graph,'model_calls':0,'substantive_revisions':0}
