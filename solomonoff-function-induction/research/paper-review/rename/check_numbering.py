"""Compare label numbers before and after the renaming edit.

Usage: python3 check_numbering.py <before.aux> <after.aux>
Prints every label whose printed number changed, appeared or disappeared (page numbers are ignored).
Exit status 0 if none, 1 otherwise.
"""
import re
import sys

PAT = re.compile(r'^\\newlabel\{([^}]*)\}\{\{([^}]*)\}')


def numbers(path):
    out = {}
    with open(path, encoding='utf-8', errors='replace') as f:
        for line in f:
            m = PAT.match(line)
            if m and not m.group(1).endswith('@cref'):
                out[m.group(1)] = m.group(2)
    return out


before, after = numbers(sys.argv[1]), numbers(sys.argv[2])
bad = 0
for k in sorted(set(before) | set(after)):
    if before.get(k) != after.get(k):
        print(f'{k}: {before.get(k)} -> {after.get(k)}')
        bad += 1
print(f'{len(before)} labels before, {len(after)} after, {bad} differ')
sys.exit(1 if bad else 0)
