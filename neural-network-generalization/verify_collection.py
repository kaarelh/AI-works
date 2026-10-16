#!/usr/bin/env python3
"""Check the paper inventory, links, and optionally isolated LaTeX builds."""
import argparse
from concurrent.futures import ThreadPoolExecutor
import hashlib
import json
from pathlib import Path
import re
import shutil
import subprocess
import tempfile
from urllib.parse import unquote, urlsplit

ROOT = Path(__file__).resolve().parent


def text_of_pdf(path):
    raw = subprocess.check_output(['pdftotext', str(path), '-'], text=True)
    return re.sub(r'\s+', ' ', raw).strip()


def rebuild(paper):
    leaf = ROOT / paper['path']
    with tempfile.TemporaryDirectory(prefix='neural-paper-build-') as temp:
        out = Path(temp)
        shutil.copytree(leaf / 'source', out / 'source')
        shutil.copyfile(leaf / 'build.sh', out / 'build.sh')
        proc = subprocess.run(['bash', 'build.sh'], cwd=out, capture_output=True, text=True, errors='replace')
        result = {'paper': paper['slug'], 'build_passed': proc.returncode == 0}
        if proc.returncode:
            result['error'] = proc.stdout[-2500:] + proc.stderr[-1000:]
            return result
        result['pdf_text_matches'] = text_of_pdf(leaf / 'paper.pdf') == text_of_pdf(out / 'paper.pdf')
        log = (out / 'build/paper.log').read_text(errors='replace')
        result['unresolved_references'] = bool(re.search(r'There were undefined references|Reference .* undefined|Citation .* undefined', log))
        result['latex_warnings'] = re.findall(r'^LaTeX Warning:.*', log, re.M)
        return result


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--rebuild', action='store_true', help='Run two LaTeX passes per paper in temporary directories.')
    parser.add_argument('--jobs', type=int, default=4)
    args = parser.parse_args()
    catalog = json.loads((ROOT / 'catalog.json').read_text())
    failures = []
    for paper in catalog:
        leaf = ROOT / paper['path']
        pdf = leaf / 'paper.pdf'
        if not pdf.is_file() or hashlib.sha256(pdf.read_bytes()).hexdigest() != paper['pdf_sha256']:
            failures.append(f"PDF checksum mismatch: {paper['slug']}")
        for rel in ('README.md', 'build.sh', paper['source_entry']):
            if not (leaf / rel).is_file():
                failures.append(f'Missing file: {leaf / rel}')
    for readme in ROOT.rglob('*.md'):
        for link in re.findall(r'\]\(([^)]+)\)', readme.read_text()):
            parsed = urlsplit(link.strip('<>'))
            if parsed.scheme or not parsed.path:
                continue
            target = (readme.parent / unquote(parsed.path)).resolve()
            if not target.exists():
                failures.append(f'Broken local link in {readme.relative_to(ROOT)}: {link}')
    builds = []
    if args.rebuild:
        with ThreadPoolExecutor(max_workers=args.jobs) as executor:
            for result in executor.map(rebuild, catalog):
                builds.append(result)
                print(json.dumps(result), flush=True)
                if not result['build_passed'] or not result.get('pdf_text_matches') or result.get('unresolved_references'):
                    failures.append(f"Build failure: {result['paper']}")
    report = {'papers': len(catalog), 'failures': failures, 'builds': builds}
    print(json.dumps(report, indent=2))
    raise SystemExit(bool(failures))


if __name__ == '__main__':
    main()
