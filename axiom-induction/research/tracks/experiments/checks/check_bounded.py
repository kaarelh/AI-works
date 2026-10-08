"""Check: which theories had their Dirichlet marginal replaced by bounds (DP too large) in E2 (and hence E7, same
pools and data), E3, E4(B, C) and E6, and the largest posterior mass they could have had.  Re-evaluates E2 for
all 25 seeds (causal and legacy pools), E3(a) and E3(b) for seed 0, E4(B, C) for seed 0, E6 for seed 0.
(E1 and E8 report this in their own results files.)  Revised version; the first version's output is kept as
check_bounded.v1.out.  Command: python3 check_bounded.py"""
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, '..', '..', '..', '..', 'code', 'experiments'))
import common  # noqa: E402,F401  (sets up paths)
import bai.posterior as BP  # noqa: E402

found = []
orig = BP.evaluate


def wrapped(*a, **k):
    out = orig(*a, **k)
    for r in out:
        if '_bounded' in r:
            found.append((tuple(r['_bounded']['names']), r['_bounded']['max_post']))
    return out


BP.evaluate = wrapped
import e2_pa  # noqa: E402
import e3_misspec  # noqa: E402
import e4_ville  # noqa: E402
import e6_equivalent  # noqa: E402
for m in (e2_pa, e3_misspec, e4_ville, e6_equivalent):
    m.evaluate = wrapped

for seed in range(25):
    e2_pa.run(seed)
print('E2 (25 seeds, causal and legacy pools): bounded cases', len(found), sorted(set(x[0] for x in found))[:6],
      'largest possible mass', max([x[1] for x in found] or [0]))
found.clear()
for g in ['heavy', 'numerals', 'small', 'skewQ']:
    for l in ['L0', 'L1']:
        e3_misspec.run_a((g, l, 0, [8, 32, 128, 512, 1024] if l == 'L0' else [8, 32, 128, 512]))
print('E3(a) (seed 0): bounded cases', len(found), sorted(set(x[0] for x in found)), max([x[1] for x in found] or [0]))
found.clear()
for g in ['dtrc-motive', 'root-skew', 'deep', 'atomic']:
    e3_misspec.run_b((g, 0, [16, 64, 256, 1024, 2048]))
print('E3(b) (seed 0): bounded cases', len(found), sorted(set(x[0] for x in found)), max([x[1] for x in found] or [0]))
found.clear()
for st in ['B', 'C1', 'C2', 'C3']:
    for l in ['L0', 'L1']:
        e4_ville.pool_trial((st, l, 0, 256))
print('E4 B/C (seed 0): bounded cases', len(found), sorted(set(x[0] for x in found)), max([x[1] for x in found] or [0]))
found.clear()
for g in ['A_xy', 'M_x', 'S_ab']:
    e6_equivalent.run((g, 0))
print('E6 (seed 0): bounded cases', len(found), sorted(set(x[0] for x in found)), max([x[1] for x in found] or [0]))
