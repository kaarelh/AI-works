"""Referee B, thread `shape`: independent replication of the computed claim in Sec. 3.2
("on sparse random systems (row weights 3-4, k = m/2) unit propagation on the core answers fully 0.77-0.83 of
3,000 sampled questions"), with independently drawn systems and an independent question sampler.

Seed 20261016. Writes refB_misc_core.out next to itself.
A question here: a random subset S of the base variables (each variable in S with probability 1/2), the
values of a random point of the law on S, and all base literals entailed; "answered fully" = UP on the core
derives all of them. (The record does not specify its sampler precisely; the fractions depend on it.)
"""
import os, sys, random, time, math
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from refB_lib import *

SEED = 20261016
rng = random.Random(SEED)
OUT = []
T0 = time.time()


def P(*a):
    s = " ".join(str(x) for x in a)
    print(s, flush=True)
    OUT.append(s)


P("# refB_misc_core.py  seed=%d  python=%s" % (SEED, sys.version.split()[0]))
for m in (12, 16, 20):
    k = m // 2
    fr_q = []
    fr_l = []
    for sysno in range(3):
        while True:
            rows = []
            for _ in range(k):
                w = rng.choice([3, 4])
                rows.append(sum(1 << (v - 1) for v in rng.sample(range(1, m + 1), w)))
            if rank(rows) == k:
                break
        consts = [rng.randrange(2) for _ in range(k)]
        pts = affine_points(rows, consts, m)
        core = []
        for r, c in zip(rows, consts):
            core += eq_clauses(r, c, m)
        full = 0
        nl = dl = 0
        nq = 1000
        for _ in range(nq):
            x = rng.choice(pts)
            alpha = frozenset((v if bit(x, v) else -v) for v in range(1, m + 1) if rng.random() < 0.5)
            cons, ent = entailed(pts, m, alpha)
            res = up(core, alpha)
            assert res is not None
            got = ent & res
            full += (got == ent)
            nl += len(ent)
            dl += len(got)
        fr_q.append(full / nq)
        fr_l.append(dl / nl if nl else 1.0)
    P(f"  m={m} k={k}: fraction of questions answered fully by the core, 3 systems x 1000 questions: "
      f"{[round(f, 3) for f in fr_q]} (mean {sum(fr_q) / 3:.3f}); fraction of entailed literals: {sum(fr_l) / 3:.3f}")
P(f"# done in {time.time() - T0:.1f}s")
with open(os.path.join(os.path.dirname(os.path.abspath(__file__)), "refB_misc_core.out"), "w") as f:
    f.write("\n".join(OUT) + "\n")
