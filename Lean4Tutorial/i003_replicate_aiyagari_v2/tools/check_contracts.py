#!/usr/bin/env python3
"""Structural metadata checks only; not a Lean or economic-adequacy verifier."""
from __future__ import annotations
import argparse
from collections import Counter
import json
from pathlib import Path
import sys

STATUSES = {'UNFORMALIZED','IN_PROGRESS','KERNEL_CHECKED','REVIEW_READY','GREEN','BLOCKED'}

def main() -> int:
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--release', choices=['core','extended'])
    args = p.parse_args()
    root = Path(__file__).resolve().parents[1]
    errors: list[str] = []
    try:
        data = json.loads((root/'contracts/theorems.json').read_text())
        ts = data['theorems']
        stages = json.loads((root/'contracts/milestones.json').read_text())['milestones']
        profiles = json.loads((root/'contracts/assumptions.json').read_text())['profiles']
        sources = json.loads((root/'contracts/source_manifest.json').read_text())['sources']
        coverage = json.loads((root/'contracts/source_coverage.json').read_text())['claims']
        ids = [t['id'] for t in ts]
        if len(set(ids)) != len(ids): errors.append('Duplicate theorem ID')
        names = [t['declaration'] for t in ts]
        if len(set(names)) != len(names): errors.append('Duplicate contract declaration')
        by_id = {t['id']: t for t in ts}
        stage_ids = {s['stage'] for s in stages}
        source_ids = {s['id'] for s in sources}
        for t in ts:
            if t['status'] not in STATUSES: errors.append(f'{t["id"]}: invalid status')
            if t['stage'] not in stage_ids: errors.append(f'{t["id"]}: missing stage')
            if not t['statement'].strip(): errors.append(f'{t["id"]}: empty statement')
            if not t['declaration'].startswith('Aiyagari1994.'): errors.append(f'{t["id"]}: wrong namespace')
            for dep in t['dependencies']:
                if dep not in by_id: errors.append(f'{t["id"]}: unknown dependency {dep}')
            for tag in t['assumptions']:
                if tag not in profiles: errors.append(f'{t["id"]}: unknown assumption profile {tag}')
            for sid in t['sources']:
                if sid not in source_ids: errors.append(f'{t["id"]}: unknown source {sid}')
        visited, active = set(), set()
        def visit(key: str) -> None:
            if key in active: raise ValueError(f'Dependency cycle at {key}')
            if key in visited or key not in by_id: return
            active.add(key)
            for d in by_id[key]['dependencies']: visit(d)
            active.remove(key); visited.add(key)
        for key in by_id: visit(key)
        for s in stages:
            if not (root/s['file']).is_file(): errors.append(f'Missing prompt: {s["file"]}')
            assigned = {t['id'] for t in ts if t['stage']==s['stage']}
            if assigned != set(s['contract_ids']): errors.append(f'Stage {s["stage"]}: contract assignment mismatch')
        for c in coverage:
            for key in c['theorem_ids']:
                if key not in by_id: errors.append(f'{c["id"]}: unknown coverage target {key}')
        ledger = (root/'docs/proof_ledger.md').read_text()
        for t in ts:
            if t['declaration'] not in ledger: errors.append(f'{t["id"]}: absent from readable ledger')
        if args.release:
            required_scopes = {'core','diagnostic'}
            if args.release == 'extended': required_scopes.add('extension')
            required = [t for t in ts if t['scope'] in required_scopes]
            approvals: set[str] = set()
            for path in (root/'reviews').glob('*.json'):
                r = json.loads(path.read_text())
                if r.get('accepted') is True and r.get('reviewer') and r.get('git_commit'):
                    evidence = r.get('evidence', [])
                    if not evidence or any(not (root/e).is_file() for e in evidence):
                        errors.append(f'{path.name}: missing approval evidence files')
                    else:
                        approvals.update(r.get('contract_ids',[]))
            for t in required:
                if t['status'] != 'GREEN': errors.append(f'{t["id"]}: required contract is {t["status"]}, not GREEN')
                if t['id'] not in approvals: errors.append(f'{t["id"]}: no recorded accepted adequacy review')
                if not (root/t['module']).is_file(): errors.append(f'{t["id"]}: missing implementation file')
            for name in ['lean-toolchain','All.lean','Audit.lean']:
                if not (root/name).is_file(): errors.append(f'Missing release file: {name}')
    except (OSError, KeyError, ValueError, TypeError, json.JSONDecodeError) as exc:
        errors.append(str(exc))
    if errors:
        for e in errors: print('FAIL:', e, file=sys.stderr)
        print(f'{len(errors)} structural/gate error(s). This check does not run Lean.', file=sys.stderr)
        return 1
    print(f'Structural checks passed: {len(ts)} contracts, {len(stages)} prompts, acyclic dependency graph.')
    print('Status counts:', dict(Counter(t['status'] for t in ts)))
    print('Scope counts:', dict(Counter(t['scope'] for t in ts)))
    print('Not a proof certificate: Lean builds, transitive-axiom audits and substantive review are separate obligations.')
    return 0

if __name__ == '__main__':
    raise SystemExit(main())
