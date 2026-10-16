"""Referee B, thread `shape`, target T4 (directed rules against clauses, Prop 4.2, Thm 4.3).

Independent of checks/. Seed 20261016. Writes refB_t4_rules.out next to itself.

Checks
 A  Prop 4.2(b): sound directed rules for one parity law, counted under three conventions
    (all sound rules with consistent premise; excluding trivial rules l in P; excluding rules whose premise
    mentions the conclusion's variable); the minimal usable rule sets (exhaustive for m = 3, deletion for m = 4, 5).
 B  Prop 4.2(a): FC_k with rules(F) against UP_k with F, round budgets 1..4 and unbounded, random theories
    with auxiliary variables and random (also inconsistent) antecedents.
 C  Prop 4.2(c): splitting wide clauses with fresh variables preserves UP-usability; rule-set written length
    against clausal written length (record: factor <= 9).
"""
import os, sys, random, time, math
from itertools import combinations, product
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


def rules_of(F):
    return [(frozenset(-L2 for L2 in C if L2 != L), L) for C in F for L in C]


def parity_pts(m, c=0):
    return [x for x in range(1 << m) if popcount(x) % 2 == c]


def fc_usable(R, S, m, rounds=None):
    for alpha in partial_assignments(range(1, m + 1)):
        cons, ent = entailed(S, m, alpha)
        if not cons:
            continue
        res = fc(R, alpha, rounds)
        if res is None:
            return False
        base = {L for L in res if abs(L) <= m}
        if not (ent <= base) or any(L not in alpha and L not in ent for L in base):
            return False
    return True


P("# refB_t4_rules.py  seed=%d  python=%s" % (SEED, sys.version.split()[0]))
P("== A: sound directed rules P => l for the parity law (P consistent with the law)")
for m in range(2, 7):
    S = parity_pts(m)
    lits = [v for v in range(1, m + 1)] + [-v for v in range(1, m + 1)]
    n_all = n_nontriv = n_novar = 0
    novar_rules = []
    for P_ in partial_assignments(range(1, m + 1)):
        cons, ent = entailed(S, m, P_)
        if not cons:
            continue
        for L in lits:
            sound = (L in P_) or (L in ent)
            if not sound:
                continue
            n_all += 1
            if L not in P_:
                n_nontriv += 1
            if abs(L) not in {abs(x) for x in P_}:
                n_novar += 1
                novar_rules.append((P_, L))
    P(f"  m={m}: all sound rules {n_all}; excluding l in P: {n_nontriv}; excluding var(l) in var(P): {n_novar}; "
      f"m 2^(m-1) = {m * 2 ** (m - 1)}")
    if m == 3:
        R0 = novar_rules
        usable_sets = []
        for mask in range(1 << len(R0)):
            R = [R0[i] for i in range(len(R0)) if mask >> i & 1]
            if fc_usable(R, S, m):
                usable_sets.append(mask)
        P(f"   m=3: subsets of the {len(R0)} non-trivial sound rules that are FC-usable: {len(usable_sets)} "
          f"(full set only: {usable_sets == [(1 << len(R0)) - 1]}); adding a trivial rule (x1 => x1) keeps usability: "
          f"{fc_usable(R0 + [(frozenset([1]), 1)], S, m)}")
    if m in (4, 5):
        R0 = novar_rules
        assert fc_usable(R0, S, m)
        brk = sum(1 for i in range(len(R0)) if not fc_usable(R0[:i] + R0[i + 1:], S, m))
        P(f"   m={m}: the {len(R0)} non-trivial sound rules are FC-usable; single deletions breaking usability: {brk}/{len(R0)}")

P("== B: FC_k on rules(F) against UP_k on F (same state or both conflict), random theories")
mism = runs = confl = 0
for trial in range(400):
    N = rng.choice([4, 5, 6, 7])
    F = []
    for _ in range(rng.randint(2, 12)):
        w = rng.randint(1, 4)
        vs = rng.sample(range(1, N + 1), min(w, N))
        F.append(frozenset(v if rng.random() < 0.5 else -v for v in vs))
    R = rules_of(F)
    for _ in range(10):
        alpha = frozenset(v if rng.random() < 0.5 else -v for v in range(1, N + 1) if rng.random() < 0.35)
        for k in (1, 2, 3, 4, None):
            a = up(F, alpha, k)
            b = fc(R, alpha, k)
            runs += 1
            confl += (a is None)
            if (a is None) != (b is None) or (a is not None and a != b):
                mism += 1
P(f"  {runs} runs ({confl} with conflicts): mismatches = {mism}")

P("== C: Prop 4.2(c): splitting clauses of width >= 4 with fresh variables; rules vs clauses written length")


def split(F, nxt):
    out = []
    for C in F:
        C = sorted(C, key=abs)
        w = len(C)
        if w <= 3:
            out.append(frozenset(C))
            continue
        z = nxt
        out.append(frozenset([C[0], C[1], z]))
        for t in range(2, w - 2):
            out.append(frozenset([-z, C[t], z + 1]))
            z += 1
        out.append(frozenset([-z, C[w - 2], C[w - 1]]))
        nxt = z + 1
    return out, nxt


for name, m, S, kk in [("parity m=5 (PI)", 5, parity_pts(5), 1), ("parity m=6 (PI)", 6, parity_pts(6), 1)] + \
        [(f"random law m={mm} k={kk}", mm, None, kk) for mm, kk in [(6, 2), (6, 3), (7, 3)]]:
    if S is None:
        while True:
            rows = [rng.randrange(1, 1 << m) for _ in range(kk)]
            if rank(rows) == kk:
                break
        S = affine_points(rows, [rng.randrange(2) for _ in range(kk)], m)
    F = prime_implicates(S, m)
    G, nxt = split(F, m + 1)
    N = nxt - 1
    okF, _, _ = usable(F, m, S, m)
    okG, _, _ = usable(G, N, S, m, check_proj=(N <= 18))
    R = rules_of(G)
    okR = fc_usable(R, S, m)
    lenF = sum(len(C) for C in F)
    lenR = sum(len(P_) + 1 for P_, L in R)
    P(f"  {name}: PI {len(F)} clauses (max width {max(len(C) for C in F)}, length {lenF}); split: {len(G)} clauses, "
      f"{N - m} aux, UP-usable {okG}; rules(split) {len(R)}, FC-usable {okR}, written length {lenR}; "
      f"ratio rules/PI length {lenR / lenF:.2f}")
P(f"# done in {time.time() - T0:.1f}s")
with open(os.path.join(os.path.dirname(os.path.abspath(__file__)), "refB_t4_rules.out"), "w") as f:
    f.write("\n".join(OUT) + "\n")
