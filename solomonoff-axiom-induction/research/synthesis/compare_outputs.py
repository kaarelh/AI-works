#!/usr/bin/env python3
"""Synthesis check (2026-10-16, deterministic): classify the differences reported by rerun_checks.py.

For every line of a rerun log that says DIFFERS and whose script exited 0, diff the regenerated output in the
scratch copy against the saved output in research/tracks/ and report whether every differing line is a timing
line (a line reporting elapsed seconds, e.g. "# done in 29.4s", "# runtime 199 s", "(84 s)").  Failed or
timed-out runs are listed with their status; they are not comparisons.
Usage: python3 compare_outputs.py <scratch-copy-root> <rerun-log> [<rerun-log> ...]
"""
import difflib
import re
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent / "tracks"
TIMING = re.compile(r"(done in\s*[\d.]+\s*s|runtime\s*[\d.]+\s*s|elapsed|\(\s*[\d.]+\s*s\)|[\d.]+\s*s\s*$|time[: ]\s*[\d.]+\s*s)", re.I)


def classify(old, new):
    a, b = old.splitlines(), new.splitlines()
    if len(a) != len(b):
        return "DIFFERENT CONTENT (line counts differ)", []
    bad = [(i, x, y) for i, (x, y) in enumerate(zip(a, b)) if x != y]
    if all(TIMING.search(x) and TIMING.search(y) and re.sub(r"[\d.]+", "#", x) == re.sub(r"[\d.]+", "#", y) for _, x, y in bad):
        return f"identical apart from {len(bad)} timing line(s)", bad
    return "DIFFERENT CONTENT", bad


def main():
    root = Path(sys.argv[1])
    for log in sys.argv[2:]:
        for line in Path(log).read_text().splitlines():
            m = re.match(r"(\w+)/(\S+)\.py: (.*?), .*compared (file|stdout): (.*)", line)
            if not m:
                print(line)
                continue
            t, name, status, src, verdict = m.groups()
            if verdict.startswith("IDENTICAL"):
                print(f"{t}/{name}.py: byte-identical")
                continue
            if status != "exit 0":
                print(f"{t}/{name}.py: NOT COMPARED ({status})")
                continue
            new = (root / t / "checks" / f"{name}.out").read_text()
            old = (REPO / t / "checks" / f"{name}.out").read_text()
            verdict2, bad = classify(old, new)
            print(f"{t}/{name}.py: {verdict2}")
            for i, x, y in bad[:3]:
                print(f"    line {i+1}: saved {x.strip()!r} | new {y.strip()!r}")


if __name__ == "__main__":
    main()
