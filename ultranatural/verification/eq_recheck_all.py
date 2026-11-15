"""Referee: recheck with a larger proof bound ALL the sets that fit a target at 0, 1, 2 (not only
those that already prove a wrong value, which is what code/eq_unary_recheck.py does).

A set that proves no wrong value within the first bound may prove one within a larger bound, and
a set counted as fitting may be inconsistent by a longer proof; code/eq_unary_recheck.py tests
neither for the sets that do not deviate at the first bound.

Usage: python3 eq_recheck_all.py DUMP.txt L2 PATH_TO_eq_unary
       DUMP.txt is the output of `eq_unary CAP L dump` (lines starting with D)
"""
import subprocess
import sys

TARGETS = {
    "successor": lambda x: x + 1,
    "identity": lambda x: x,
    "x+2": lambda x: x + 2,
    "constant 1": lambda x: 1,
    "predecessor": lambda x: max(x - 1, 0),
    "double": lambda x: 2 * x,
    "[x > 0]": lambda x: int(x > 0),
    "min(x+1, 2)": lambda x: min(x + 1, 2),
    "successor, but 0 at 0": lambda x: 0 if x == 0 else x + 1,
}

dump, L2, binary = sys.argv[1], sys.argv[2], sys.argv[3]
sets = []
for line in open(dump):
    if line.startswith("D "):
        head, prof, ids = line[2:].split("|")
        w, size = head.split()
        sets.append((float(w), int(size), tuple(int(v) for v in prof.split()), ids.strip()))
print(f"{len(sets)} sets in the dump (they determine f at 0, 1, 2 within the first bound); second bound {L2}")
for name, g in TARGETS.items():
    fit = [s for s in sets if all(s[2][x] == g(x) for x in range(3))]
    if not fit:
        print(f"{name}: no fitting set")
        continue
    out = subprocess.run([binary, "0", L2, "check"], input="\n".join(s[3] for s in fit) + "\n",
                         capture_output=True, text=True).stdout.split("\n")
    M = sum(s[0] for s in fit)
    incons = changed = 0
    w_incons = 0.0
    dev1 = [s for s in fit if any(s[2][x] not in (-1, g(x)) for x in range(8))]
    dev2, newdev = [], []
    for s, res in zip(fit, out):
        if res.startswith("inconsistent"):
            incons += 1
            w_incons += s[0]
            continue
        prof = tuple(int(v) for v in res.split()[1:])
        if prof != s[2]:
            changed += 1
        if any(prof[x] not in (-1, g(x)) for x in range(8)):
            dev2.append((s, prof))
            if s not in dev1:
                newdev.append((s, prof))
    print(f"{name}: {len(fit)} fitting sets (weight {M:.4e}); proving a wrong value at the first bound: {len(dev1)} "
          f"(share {sum(s[0] for s in dev1) / M:.2e})")
    print(f"     at bound {L2}: inconsistent {incons} (share {w_incons / M:.2e}); consistent with a changed profile {changed}; "
          f"proving a wrong value {len(dev2)} (share {sum(s[0] for s, _ in dev2) / (M - w_incons):.2e}); of these new {len(newdev)}")
    for s, prof in newdev[:4]:
        print(f"        new: size {s[1]} {s[3]}  proves {list(prof)}")
