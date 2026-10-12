"""List the files that stay on the working branch when the project is published to `main`.

Run from the project folder. Prints one path per line, relative to it, chosen from `git ls-files`:

    python3 src/s2_branch_only.py | xargs git rm -q -f

Excluded:
  * study 1 scratch: pilots, job files, logs, texts;
  * study 2 job files, logs and failure logs;
  * as pre-registered in study2/DESIGN2.md §8, the raw texts of the fraud, payday-loan and anti-vaccination
    responses, of every petition review and of the false-myth calibrator. That covers the Claude records in
    runs2/ and the GPT records in astra_out/, whose opaque ids are mapped to units through the keymaps in
    study2/astra_keymap_*.json. For GPT, it also covers the CLI event streams and stderr of those calls,
    and the streams of any call no saved record points to (unit unknown). Every audit file (counts, no text) stays.
"""
import glob
import json
import os
import re
import subprocess
import sys

RAW_UNITS = re.compile(r'^(analysis__(fraud_illegal|disreputable_legal|disfavoured_adv)__|petition__|petition_cyber__|'
                       r'fidelity__agency__F__|realism__petition|identity__petition)')
CAPTURE = re.compile(r'"capture_id": "(ps_job_[A-Za-z0-9_\-]+)"')


def files(prefix):
    out = subprocess.run(['git', 'ls-files', prefix], capture_output=True, text=True, check=True).stdout
    return out.split()


def study1():
    rx = re.compile(r'^runs/(pilot0_contaminated_raw/|pilot0_scored\.jsonl|pilot1_|loop_pilot_|texts/|'
                    r'qual_args\.json|pairs_manifest\.json)|^runs/[^/]+(_jobs\.jsonl|\.log)$')
    return [f for f in files('runs') if rx.search(f)]


def study2_claude():
    out = []
    for f in files('runs2'):
        if re.search(r'^runs2/main/jobs/|^runs2/main/batch[0-9]*\.jsonl$|^runs2/pilot/[^/]+\.jsonl$|\.log$', f):
            out.append(f)
        elif re.search(r'^runs2/pilot/(blocktest_cyber|blocktest_agent|fallback_old)/', f):
            out.append(f)
        elif '/raw/' in f and RAW_UNITS.search(os.path.basename(f)):
            out.append(f)
    return out


def astra():
    units = {}
    for k in glob.glob('study2/astra_keymap_*.json'):
        for i, v in json.load(open(k))['ids'].items():
            units[i] = v['unit']
    tracked = files('astra_out')
    out, keep_captures, drop_captures = [], set(), set()
    for f in tracked:
        m = re.match(r'^astra_out/([^_/][^/]*)/([a-z0-9]+_\d{6})\.json$', f)
        if not m:
            continue
        model, rid = m.groups()
        if rid not in units:
            sys.exit(f'{f}: id not in any keymap')
        tail = (json.load(open(f)).get('raw_response') or {}).get('stdout_tail') or ''
        caps = {(model, c) for c in CAPTURE.findall(tail)}
        if RAW_UNITS.search(units[rid]):
            out.append(f)
            drop_captures |= caps
        else:
            keep_captures |= caps
    for f in tracked:
        m = re.match(r'^astra_out/_events/([^/]+)/(ps_job_[A-Za-z0-9_\-]+)\.(jsonl|stderr\.log)$', f)
        if m and ((m[1], m[2]) in drop_captures or (m[1], m[2]) not in keep_captures):
            out.append(f)
        elif re.search(r'^astra_out/_logs/device_login', f):
            out.append(f)
    return out


if __name__ == '__main__':
    paths = sorted(set(study1() + study2_claude() + astra()))
    print('\n'.join(paths))
