#!/usr/bin/env python3
"""Copy only approved primary-source PDFs; never extract the old implementation."""
from __future__ import annotations
import argparse
import hashlib
import json
from pathlib import Path
import sys
import zipfile

def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--aiyagari', type=Path, required=True)
    parser.add_argument('--citations', type=Path, required=True)
    parser.add_argument('--output', type=Path, default=Path('sources/papers'))
    args = parser.parse_args()
    root = Path(__file__).resolve().parents[1]
    manifest = json.loads((root/'contracts/source_manifest.json').read_text())
    archives = {'i003_replicate_aiyagari.zip': args.aiyagari, 'citations.zip': args.citations}
    verified: list[tuple[dict, bytes]] = []
    try:
        for item in manifest['sources']:
            name = item['local_name']
            if Path(name).name != name or not name.lower().endswith('.pdf'):
                raise ValueError(f'Unsafe or non-PDF output name: {name!r}')
            archive_path = archives[item['archive']]
            with zipfile.ZipFile(archive_path) as archive:
                info = archive.getinfo(item['member'])
                if info.file_size != item['bytes']:
                    raise ValueError(f'Size mismatch for {item["id"]}; expected the approved source version.')
                data = archive.read(item['member'])
            actual = hashlib.sha256(data).hexdigest()
            if actual != item['sha256']:
                raise ValueError(f'SHA-256 mismatch for {item["id"]}; do not substitute a different version silently.')
            dest = args.output/name
            if dest.exists() and hashlib.sha256(dest.read_bytes()).hexdigest() != actual:
                raise ValueError(f'Refusing to overwrite different existing file: {dest}')
            verified.append((item, data))
        # Commit output only after every input has passed verification.
        args.output.mkdir(parents=True, exist_ok=True)
        report = []
        for item, data in verified:
            dest = args.output/item['local_name']
            if not dest.exists():
                dest.write_bytes(data)
            report.append({'id': item['id'], 'file': item['local_name'], 'sha256': item['sha256']})
            print(f'VERIFIED {item["id"]:5s} {item["local_name"]}')
        (args.output/'extraction_report.json').write_text(json.dumps(report, indent=2)+'\n')
    except (OSError, ValueError, KeyError, zipfile.BadZipFile, RuntimeError) as exc:
        print(f'Extraction failed: {exc}', file=sys.stderr)
        return 1
    print(f'Copied/verified {len(verified)} approved PDFs. No code or previous proof documents extracted.')
    return 0

if __name__ == '__main__':
    raise SystemExit(main())
