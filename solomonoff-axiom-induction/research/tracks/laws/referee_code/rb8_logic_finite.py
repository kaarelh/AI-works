"""rb8_logic_finite.py -- Referee B, thread `laws`: section 1 claims on exactly enumerable propositional
fragments, and a direct simulation of the random-completion machine of Prop 1.8.

Propositional setting: atoms p1..p4, valuations V = {0,1}^4 (16 points), B = {} (every valuation a model).
A theory is represented by its model set M_T (subset of V); T |- phi iff M_T is inside M_phi.  A question is a
partition of V into nonempty blocks (its answers' model sets); gamma(Q) = log2 |Q|.
A. Def 1.1: for consistent T, T proves (Q, a) iff A_T(Q) = {a} (A_T = answers not refuted by T); all theories
   and random questions.
B. Prop 1.10(ii): P_T(D) := 2^{-Exc^Q_D(T)} [T u D consistent] is a weak function semimeasure:
   sum_{a in Q} P_T(D + (Q,a)) <= P_T(D) for every Q not in dom D (exact rationals; random T, D, Q).
C. Prop 1.11(a): w_T(a|Q) = 1/2 [a is the first answer provable from T] + 1/(2|Q|) sums to <= 1, and
   -log2 prod_j w_T(y_j|Q_j) <= n + Exc^Q_D(T) whenever T u D is consistent (exact).
D. Prop 2.1 (monotonicity): if M_T is inside M_T' (T at least as strong), T consistent and T' compatible with D
   (consistent and proving every datum), then T is compatible with D.  All pairs on random D.
E. Prop 1.8(a): simulate the theory machine G_T (it reads tape bits for time t and emits ever finer dyadic
   sub-intervals of [l(t), u(t)]) to depth 40 bits and estimate Pr[the random theory proves every interval datum];
   compare with P^R_T(D) = prod_t |C_t & [l,u]| / (u - l).  Also: P^R_T is a measure in the answer of a further
   question at an already-asked time (cells intersected, Def 1.7), exactly.
Seed 20261016.  Writes rb8_logic_finite.out next to itself.
"""
import itertools
import math
import os
import random
import sys
import time
from fractions import Fraction as Fr

SEED = 20261016
OUT = []
HERE = os.path.dirname(os.path.abspath(__file__))
NV = 16
FULL = frozenset(range(NV))


def out(s=""):
    OUT.append(s)
    print(s, flush=True)


def rand_partition(rng, k):
    lab = [rng.randrange(k) for _ in range(NV)]
    blocks = [frozenset(v for v in range(NV) if lab[v] == i) for i in range(k)]
    return [b for b in blocks if b]


def proves(MT, Ma):
    return MT <= Ma


def main():
    t0 = time.time()
    rng = random.Random(SEED)
    out("# rb8_logic_finite.py seed=%d python %s" % (SEED, sys.version.split()[0]))

    # ---------------- A
    out("\n== A. Def 1.1: for consistent T, T proves (Q,a) iff A_T(Q) = {a}")
    bad = cnt = 0
    for _ in range(300):
        Q = rand_partition(rng, rng.randint(2, 6))
        for _ in range(200):
            MT = frozenset(v for v in range(NV) if rng.random() < rng.choice([0.1, 0.3, 0.6]))
            if not MT:
                continue
            for a in Q:
                AT = [b for b in Q if b & MT]          # answers consistent with T, i.e. not refuted
                cnt += 1
                bad += proves(MT, a) != (AT == [a])
    out("   %d (T, Q, a) cases: mismatches %d" % (cnt, bad))

    # ---------------- B, C
    out("\n== B/C. Prop 1.10(ii) semimeasure property and Prop 1.11(a) bound (exact rationals)")
    badB = badC = badW = cnt = 0
    for _ in range(4000):
        nq = rng.randint(0, 4)
        Qs = [rand_partition(rng, rng.randint(2, 5)) for _ in range(nq + 1)]
        MT = frozenset(v for v in range(NV) if rng.random() < rng.choice([0.2, 0.5, 0.9]))
        D = [(Q, rng.choice(Q)) for Q in Qs[:-1]]
        Qn = Qs[-1]

        def PT(data):
            M = MT
            for _, a in data:
                M = M & a
            if not M:
                return Fr(0)
            val = Fr(1)
            for Q, a in data:
                if not proves(MT, a):
                    val /= len(Q)
            return val
        lhs = sum(PT(D + [(Qn, a)]) for a in Qn)
        cnt += 1
        badB += lhs > PT(D)
        # C: w_T
        if MT:
            for Q in Qs:
                prov = [a for a in Q if proves(MT, a)]
                first = prov[0] if prov else None
                tot = sum(Fr(1, 2) * (a == first) + Fr(1, 2 * len(Q)) for a in Q)
                badW += tot > 1
        if PT(D) > 0 and MT:
            prodw = Fr(1)
            exc = 0.0
            for Q, a in D:
                prov = [b for b in Q if proves(MT, b)]
                first = prov[0] if prov else None
                prodw *= Fr(1, 2) * (a == first) + Fr(1, 2 * len(Q))
                if not proves(MT, a):
                    exc += math.log2(len(Q))
            if D:
                badC += (-math.log2(prodw)) > len(D) + exc + 1e-9
    out("   %d random (T, D, Q): semimeasure violations %d; w_T sums > 1: %d; -log P'_T(y) > n + Exc^Q: %d" % (
        cnt, badB, badW, badC))

    # ---------------- D
    out("\n== D. Prop 2.1: stronger consistent theories inherit compatibility")
    bad = cnt = 0
    for _ in range(3000):
        Qs = [rand_partition(rng, rng.randint(2, 4)) for _ in range(rng.randint(1, 3))]
        truth = rng.randrange(NV)
        D = [(Q, next(a for a in Q if truth in a)) for Q in Qs]
        MTp = frozenset(v for v in range(NV) if rng.random() < 0.5) | {truth}
        MT = frozenset(v for v in MTp if rng.random() < 0.5)
        if not MT:
            continue
        compat_p = all(proves(MTp, a) for _, a in D)
        compat = all(proves(MT, a) for _, a in D)
        cnt += 1
        bad += compat_p and not compat
    out("   %d (T stronger than T', D): T' compatible but T not: %d" % (cnt, bad))

    # ---------------- E
    out("\n== E. Prop 1.8(a): simulated machine G_T vs P^R_T")
    nr = random.Random(SEED + 7)
    worst = 0.0
    for case in range(12):
        nt = nr.randint(1, 3)
        laws = []
        cells = []
        for _ in range(nt):
            l = Fr(nr.randint(0, 50), 10)
            u = l + Fr(nr.randint(1, 30), 10)
            laws.append((l, u))
            a = Fr(nr.randint(int(10 * l) - 10, int(10 * u)), 10)
            b = a + Fr(nr.randint(2, 25), 10)
            cells.append((a, b))
        PR = Fr(1)
        for (l, u), (a, b) in zip(laws, cells):
            PR *= max(Fr(0), min(b, u) - max(a, l)) / (u - l)
        # simulation: tape bits give U_i in [0,1); the machine emits [l + (u-l) m 2^-k, l + (u-l)(m+1) 2^-k];
        # the datum alpha <= q < beta is proved once an emitted closed interval lies inside (alpha, beta) (RCF proves
        # the inclusion); depth 40 bits.
        N = 40000
        hits = 0
        for _ in range(N):
            ok = True
            for (l, u), (a, b) in zip(laws, cells):
                bits = nr.getrandbits(40)
                proved = False
                for k in range(1, 41):
                    m = bits >> (40 - k)
                    lo = l + (u - l) * Fr(m, 2 ** k)
                    hi = l + (u - l) * Fr(m + 1, 2 ** k)
                    if a < lo and hi < b:
                        proved = True
                        break
                    if hi <= a or lo >= b:
                        break
                if not proved:
                    ok = False
                    break
            hits += ok
        est = hits / N
        se = math.sqrt(max(est * (1 - est), 1e-12) / N)
        worst = max(worst, abs(est - float(PR)) / max(se, 1e-9))
        if case < 6:
            out("   case %d: P^R_T = %.4f, simulated %.4f +- %.4f" % (case, float(PR), est, se))
    out("   largest |simulated - P^R_T| in standard errors over 12 cases: %.2f" % worst)
    # measure property at a repeated time
    bad = 0
    for _ in range(2000):
        l = Fr(nr.randint(0, 20), 4)
        u = l + Fr(nr.randint(1, 20), 4)
        a = Fr(nr.randint(-4, 30), 4)
        b = a + Fr(nr.randint(1, 20), 4)
        C = (max(a, l), min(b, u))
        if C[1] <= C[0]:
            continue
        PRD = (C[1] - C[0]) / (u - l)
        # second question at the same time: partition of the line into cells of width w starting at s
        w = Fr(nr.randint(1, 12), 4)
        s = Fr(nr.randint(-8, 8), 4)
        tot = Fr(0)
        j = math.floor((C[0] - s) / w) - 1
        while s + j * w < C[1] + w:
            c0, c1 = s + j * w, s + (j + 1) * w
            lo2, hi2 = max(C[0], c0), min(C[1], c1)
            if hi2 > lo2:
                tot += (hi2 - lo2) / (u - l)
            j += 1
        bad += tot != PRD
    out("   P^R_T summed over the answers of a further question at an asked time equals P^R_T(D): mismatches %d / 2000" % bad)

    out("\n# runtime %.0f s" % (time.time() - t0))
    out("# done")
    with open(os.path.join(HERE, "rb8_logic_finite.out"), "w") as fh:
        fh.write("\n".join(OUT) + "\n")


if __name__ == "__main__":
    main()
