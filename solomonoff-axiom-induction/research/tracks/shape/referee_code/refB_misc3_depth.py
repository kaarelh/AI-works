"""Referee B, thread `shape`: how many propagation rounds do the intermediate-concept encodings of one parity law
need? (Bears on the record's reading that intermediate concepts make a law usable "by the weakest reasoner",
Prop 3.1 and Thm 4.3(4), and on the depth dependence of the vocabulary separation.)

For x_1 + ... + x_m = 0 we compute the least k such that the encoding is UP_k-usable (all base partial
assignments, exhaustive), for the chain encoding of Prop 3.1 and for a balanced-tree encoding.
Seed-free (deterministic). Writes refB_misc3_depth.out next to itself.
"""
import os, sys, time, math
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from refB_lib import *

OUT = []
T0 = time.time()


def P(*a):
    s = " ".join(str(x) for x in a)
    print(s, flush=True)
    OUT.append(s)


def tree_encoding(vs, c, nxt):
    """Balanced XOR tree: pair up nodes level by level with fresh variables; last two nodes a + b = c."""
    F = []
    level = list(vs)
    while len(level) > 2:
        new = []
        for i in range(0, len(level) - 1, 2):
            y = nxt
            nxt += 1
            F += xor_clauses([level[i], level[i + 1], y], 0)
            new.append(y)
        if len(level) % 2:
            new.append(level[-1])
        level = new
    F += xor_clauses(level, c)
    return F, nxt


def least_rounds(F, S, m, kmax=40):
    for k in range(1, kmax + 1):
        ok, _, _ = usable(F, max(abs(L) for C in F for L in C), S, m, rounds=k, check_proj=False)
        if ok:
            return k
    return None


P("# refB_misc3_depth.py  (deterministic)  python=%s" % sys.version.split()[0])
P("   m | PI over X: clauses, rounds | chain (Prop 3.1): clauses, aux, rounds | balanced tree: clauses, aux, rounds | 2 ceil(log2 m)")
for m in range(3, 11):
    S = [x for x in range(1 << m) if popcount(x) % 2 == 0]
    vs = list(range(1, m + 1))
    pi = xor_clauses(vs, 0)
    kpi = least_rounds(pi, S, m)
    Fc, nc = chain_encoding(vs, 0, m + 1)
    kc = least_rounds(Fc, S, m)
    Ft, nt = tree_encoding(vs, 0, m + 1)
    kt = least_rounds(Ft, S, m)
    P(f"  {m:2d} | {len(pi)}, {kpi} | {len(Fc)}, {nc - 1 - m}, {kc} | {len(Ft)}, {nt - 1 - m}, {kt} | {2 * math.ceil(math.log2(m))}")
P(f"# done in {time.time() - T0:.1f}s")
with open(os.path.join(os.path.dirname(os.path.abspath(__file__)), "refB_misc3_depth.out"), "w") as f:
    f.write("\n".join(OUT) + "\n")
