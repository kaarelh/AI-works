"""Blank the evidence quotes in study-2 judge and coder outputs whose unit stays off `main` (DESIGN2.md section 8).

usage: python3 src/s2_redact_quotes.py [--check]

Run from the project folder, on the `main` checkout, after the branch-only paths are removed (see the README). For
every tracked JSON file under runs2/**/coding/, runs2/pilot/judge/ and runs2/pilot/code_*/ whose unit matches
s2_branch_only.RAW_UNITS (fraud, payday-loan and anti-vaccination analyses, petition reviews, the false-myth
calibrator), every string field whose key ends in "quote" is set to "", at the top level and inside the coder's raw
JSON reply. Codes, counts and refusal labels stay. --check reports how many files would change without writing.
"""
import json
import os
import re
import subprocess
import sys

sys.path.insert(0, os.path.dirname(__file__))
from s2_branch_only import RAW_UNITS  # noqa: E402

QUOTE_RX = re.compile(r'("[A-Za-z_]*quote"\s*:\s*)"(?:[^"\\]|\\.)*"')


def blank(o):
    if isinstance(o, dict):
        return {k: ("" if k.endswith("quote") and isinstance(v, str) else blank(v)) for k, v in o.items()}
    if isinstance(o, list):
        return [blank(v) for v in o]
    return o


def redact(d):
    d = blank(d)
    raw = d.get("raw")
    if isinstance(raw, str):
        try:
            d["raw"] = json.dumps(blank(json.loads(raw)))
        except ValueError:
            d["raw"] = QUOTE_RX.sub(r'\1""', raw)
    return d


def main():
    check = "--check" in sys.argv
    files = subprocess.run(["git", "ls-files", "runs2"], capture_output=True, text=True, check=True).stdout.split()
    rx = re.compile(r"^runs2/(main|astra)/coding/|^runs2/pilot/(judge|code_[^/]+)/")
    n = changed = 0
    for f in files:
        if not (rx.search(f) and f.endswith(".json")):
            continue
        d = json.load(open(f))
        unit = d.get("unit") or os.path.basename(f)
        if not (isinstance(d, dict) and RAW_UNITS.search(str(unit))):
            continue
        n += 1
        new = redact(d)
        if new != d:
            changed += 1
            if not check:
                json.dump(new, open(f, "w"))
    print(f"{n} judge/coder files for branch-only units; {changed} {'would change' if check else 'redacted'}")


if __name__ == "__main__":
    main()
