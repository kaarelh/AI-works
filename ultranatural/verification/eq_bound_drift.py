"""Referee: how the profile table of code/eq_unary.c changes with the proof bound L.

A set can change between two bounds in two ways: (i) it is found inconsistent at the larger
bound (its weight leaves the table), or (ii) it stays consistent and proves more values at the
larger bound (its weight moves to a more determined profile).  The note mentions only (i).
The tables hold total weights per profile, so this script reports the net flows.

Usage: python3 eq_bound_drift.py TABLE_small_L TABLE_large_L
"""
import sys


def read(path):
    rows = {}
    for line in open(path):
        if line.startswith("#") or line.startswith("D "):
            continue
        parts = line.rstrip("\n").split("|")
        rows[tuple(int(v) for v in parts[0].split())] = float(parts[1])
    return rows


a, b = read(sys.argv[1]), read(sys.argv[2])
ta, tb = sum(a.values()), sum(b.values())
print(f"{sys.argv[1].split('/')[-1]} -> {sys.argv[2].split('/')[-1]}")
print(f"   weight of the consistent sets: {ta:.12g} -> {tb:.12g}   (lost to inconsistency: {ta - tb:.3e})")
gain = {p: b.get(p, 0) - a.get(p, 0) for p in set(a) | set(b) if b.get(p, 0) - a.get(p, 0) > 1e-15}
loss = {p: a.get(p, 0) - b.get(p, 0) for p in set(a) | set(b) if a.get(p, 0) - b.get(p, 0) > 1e-15}
print(f"   profiles that gained weight: {len(gain)}, total gain {sum(gain.values()):.3e}   <- sets that prove MORE at the larger bound")
print(f"   profiles that lost weight:   {len(loss)}, total loss {sum(loss.values()):.3e}")
und = tuple([-1] * 8)
print(f"   the all-undetermined profile: {a.get(und, 0):.12g} -> {b.get(und, 0):.12g}  (change {b.get(und, 0) - a.get(und, 0):+.3e})")
for x in (0, 7):
    ua = sum(w for p, w in a.items() if p[x] == -1) / ta
    ub = sum(w for p, w in b.items() if p[x] == -1) / tb
    print(f"   prior share of sets that leave f({x}) undetermined: {ua:.6f} -> {ub:.6f}")
print("   largest gains:")
for p, g in sorted(gain.items(), key=lambda t: -t[1])[:6]:
    print(f"      {p}  +{g:.3e}")
