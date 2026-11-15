"""Recheck, with a larger proof bound, the identity sets that fit a target on 0, 1, 2 and prove a
wrong value at some x <= 7.

The bounded closure of eq_unary.c can miss an inconsistency whose proof passes through long
terms. This script takes the listing produced by `eq_unary CAP L dump` (lines starting with D),
selects for each target the sets that fit its values at 0, 1, 2 and prove a wrong value, and
runs `eq_unary 0 L2 check` on them with a larger bound L2.

Usage: python3 eq_unary_recheck.py DUMP.txt L2
"""
import subprocess
import sys

from eq_unary_analyze import TARGETS

L2 = sys.argv[2]
sets = []
for line in open(sys.argv[1]):
    if not line.startswith("D "):
        continue
    head, prof, ids = line[2:].split("|")
    w, size = head.split()
    sets.append((float(w), int(size), tuple(int(v) for v in prof.split()), ids.strip()))
print(f"{len(sets)} sets determine f at 0, 1 and 2 (first bound); rechecking with bound {L2}")

for name, g in TARGETS.items():
    fit = [s for s in sets if all(s[2][x] == g(x) for x in range(3))]
    dev = [s for s in fit if any(s[2][x] not in (-1, g(x)) for x in range(8))]
    if not fit:
        print(f"\n== {name}: no fitting set ==")
        continue
    M = sum(s[0] for s in fit)
    out = subprocess.run(["./eq_unary", "0", L2, "check"], input="\n".join(s[3] for s in dev) + "\n",
                         capture_output=True, text=True).stdout.split("\n") if dev else []
    still = []
    for s, res in zip(dev, out):
        if res.startswith("consistent"):
            prof = tuple(int(v) for v in res.split()[1:])
            if all(prof[x] == g(x) for x in range(3)) and any(prof[x] not in (-1, g(x)) for x in range(8)):
                still.append((s, prof))
    gone = sum(s[0] for s in dev) - sum(s[0] for s, _ in still)
    print(f"\n== {name}: {len(fit)} sets fit the values at 0, 1, 2 (weight {M:.3e}); {len(dev)} of them prove a wrong "
          f"value (share {sum(s[0] for s in dev) / M:.2e}) ==")
    print(f"   after the recheck {len(still)} remain (share {sum(s[0] for s, _ in still) / (M - gone):.2e})")
    for s, prof in sorted(still, key=lambda t: t[0][1])[:6]:
        print(f"      size {s[1]:2d}  {s[3]:28s} proves {list(prof)}")
