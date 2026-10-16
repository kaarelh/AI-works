"""rb1_formal.py -- referee B (formal accuracy) for thread `philosophy`: independent checks of the
small formal statements of notes.md.  Seed 20261016 (referee B).  Writes rb1_formal.out next to itself.

Written without reading the developer's c5/c6 code (only their saved outputs, for comparison).

Parts
  (1) Prop 2.2 (conservation world): per-step gains, shares, exact expectations at m = 12, N2's run.
  (2) Remark 4.4 of `laws` as quoted in notes.md 6.1: mean |random-sign walk| after 100 and 1000 steps.
  (3) Prop 2.3(a): exact minimax number of black-box queries needed to decide "pi preserves weight"
      for a permutation pi of {0,1}^m, by game-tree search over the explicit set of permutations (m=2,3),
      against the claimed value 2^m - C(m, floor(m/2)); and for maps (m=2).
  (4) Props 2.1 and 2.5(d) on random finite propositional "random theories" (partition identity,
      partial answers, Frechet bound, monotonicity under entailment).
  (5) Prop 3.1(b): least number of law instances, by exact rational linear algebra (own code).
  (6) Section 4.5 numbers: Jupiter two-body q, Saturn's ring estimate, Mercury arithmetic.
  (7) c7's crude bits-of-rho estimate from the most sensitive day.
"""
import itertools
import math
import random
import sys
from fractions import Fraction as Fr

SEED = 20261016
random.seed(SEED)
OUT = []


def out(*a):
    s = " ".join(str(x) for x in a)
    OUT.append(s)
    print(s, flush=True)


def log2binom(m, k):
    return (math.lgamma(m + 1) - math.lgamma(k + 1) - math.lgamma(m - k + 1)) / math.log(2)


# ---------------------------------------------------------------------------------------------- (1)
def part1():
    out("== (1) Prop 2.2: conservation world")
    out("  m        g_0=log2(S/C)   1/2 log2(pi m/2)   share g_0/log2 S   max_{t<=C/2} g_t - log2(S/C) (m<=16)")
    for m in [8, 12, 16, 32, 64, 128, 1024, 10 ** 6]:
        lc = log2binom(m, m // 2)
        g0 = m - lc
        half = 0.5 * math.log2(math.pi * m / 2)
        extra = ""
        if m <= 16:
            C = math.comb(m, m // 2)
            S = 2 ** m
            gs = [math.log2((S - t) / (C - t)) for t in range(0, C // 2 + 1)]
            mono = all(gs[i] <= gs[i + 1] + 1e-15 for i in range(len(gs) - 1))
            extra = "%.4f (<= 1: %s; nondecreasing: %s)" % (max(gs) - g0, max(gs) - g0 <= 1, mono)
        out("  %-8d %12.4f %18.4f %18.4e   %s" % (m, g0, half, g0 / m, extra))
    # exact expectations at m = 12
    m = 12
    C = math.comb(m, 6)
    S = 2 ** m
    T = 300
    lawC = [math.log2(C - t) for t in range(C)]
    nolawS = [math.log2(S - t) for t in range(C)]
    cumL = [0.0]
    cumN = [0.0]
    for t in range(C):
        cumL.append(cumL[-1] + lawC[t])
        cumN.append(cumN[-1] + nolawS[t])

    def expect(Tmax):
        a_sum = b_sum = mix_sum = 0.0
        for ell in range(1, C + 1):
            k = ell if Tmax is None else min(ell, Tmax)
            a, b = cumL[k], cumN[k]
            mix = a + 1 - math.log2(1 + 2.0 ** (a - b))      # -log2(2^-a/2 + 2^-b/2)
            a_sum += a
            b_sum += b
            mix_sum += mix
        return a_sum / C, b_sum / C, mix_sum / C

    a, b, mx = expect(T)
    out("  m=12, C=%d, S=%d, cycle length uniform on 1..C" % (C, S))
    out("  T=300 steps: E raw loss law %.2f, no law %.2f, mixture %.2f, law's share %.4f" % (a, b, mx, (b - a) / b))
    a2, b2, mx2 = expect(None)
    out("  whole cycle: E raw loss law %.2f, no law %.2f, share %.4f; mean gain per pre-closure step %.4f"
        % (a2, b2, (b2 - a2) / b2, (b2 - a2) / ((C + 1) / 2)))
    q = math.log2(m + 1)
    out("  QA over 301 questions: law %.2f, no law %.2f, share %.4f" % (q, 301 * q, (301 * q - q) / (301 * q)))
    out("  N2's single run (cycle length 275, T=300): law %.1f, no law %.1f, share %.4f"
        % (cumL[275], cumN[275], (cumN[275] - cumL[275]) / cumN[275]))
    out("  notes.md quotes: 2415.6 / 3004.9 / 0.196; mixture 2416.6; whole cycle 0.232 and 2.75 bits/step;"
        " QA 3.70 / 1113.8 / 0.997; N2 run 2643.5 / 3286.4 / 0.1956")


# ---------------------------------------------------------------------------------------------- (2)
def part2():
    out("== (2) mean |sum of r independent +-eps steps| / eps")
    for r in [100, 1000]:
        tot = Fr(0)
        for k in range(r + 1):
            tot += math.comb(r, k) * abs(2 * k - r)
        val = tot / 2 ** r
        out("  r=%d: exact %.4f   r*C(r,r/2)/2^r = %.4f   sqrt(2r/pi) = %.4f"
            % (r, float(val), r * math.comb(r, r // 2) / 2 ** r, math.sqrt(2 * r / math.pi)))
    out("  notes.md 6.1 quotes 7.96 (r=100) and 25.2 (r=1000)")


# ---------------------------------------------------------------------------------------------- (3)
def part3():
    out("== (3) Prop 2.3(a): exact minimax query complexity of deciding weight preservation")

    def run(m, perms_only=True):
        n = 2 ** m
        w = [bin(x).count("1") for x in range(n)]
        if perms_only:
            objs = list(itertools.permutations(range(n)))
        else:
            objs = list(itertools.product(range(n), repeat=n))
        good = [all(w[o[x]] == w[x] for x in range(n)) for o in objs]
        allmask = (1 << len(objs)) - 1
        # index sets: sel[(x, y)] = bitmask of objects with o[x] = y
        sel = {}
        for x in range(n):
            for y in range(n):
                msk = 0
                for i, o in enumerate(objs):
                    if o[x] == y:
                        msk |= 1 << i
                sel[(x, y)] = msk
        goodmask = 0
        for i, g in enumerate(good):
            if g:
                goodmask |= 1 << i
        memo = {}

        def decided(S):
            return (S & goodmask) == 0 or (S & ~goodmask & allmask) == 0

        def value(S, queried):
            key = S
            if key in memo:
                return memo[key]
            if decided(S):
                memo[key] = 0
                return 0
            best = None
            for x in range(n):
                if x in queried:
                    continue
                branches = [S & sel[(x, y)] for y in range(n)]
                branches = [b for b in branches if b]
                if len(branches) == 1:          # o[x] already determined by S: a useless query
                    continue
                worst = 0
                for S2 in branches:
                    v = 1 + value(S2, queried | {x})
                    if v > worst:
                        worst = v
                    if best is not None and worst >= best:
                        break
                if best is None or worst < best:
                    best = worst
            memo[key] = best
            return best

        return value(allmask, frozenset()), len(objs), len(memo)

    for m in [2, 3]:
        v, no, nm = run(m, True)
        claim = 2 ** m - math.comb(m, m // 2)
        out("  permutations, m=%d: %d objects, %d states; minimax queries = %d; claimed 2^m - C(m,m/2) = %d; match: %s"
            % (m, no, nm, v, claim, v == claim))
    v, no, nm = run(2, False)
    out("  arbitrary maps, m=2: %d objects; minimax queries = %d; claimed 2^m = 4; match: %s" % (no, v, v == 4))


# ---------------------------------------------------------------------------------------------- (4)
def part4():
    out("== (4) Props 2.1 and 2.5(d) on random finite propositional random theories")
    natoms = 4
    vals = list(range(2 ** natoms))           # valuations
    full = (1 << len(vals)) - 1
    # a sentence is a set of valuations (bitmask); B = full (no background) or a random constraint
    rnd = random.Random(SEED + 4)
    worst = {"a": 0.0, "b": 0.0, "frechet": 0.0, "mono": 0.0}
    nq = 0
    for trial in range(300):
        Bmask = full if trial % 2 == 0 else (rnd.getrandbits(16) | rnd.getrandbits(16)) & full
        if Bmask == 0:
            continue
        # random theories: each is a set of models (bitmask), weight = random positive
        K = rnd.randint(5, 30)
        theories = []
        for _ in range(K):
            mods = rnd.getrandbits(16) & rnd.getrandbits(16) & full     # biased to strong theories
            theories.append((mods, rnd.random()))
        # data: a random literal set D, represented by its model set psiD
        psiD = full
        for _ in range(rnd.randint(0, 2)):
            psiD &= rnd.getrandbits(16) | rnd.getrandbits(16)
        cons = lambda mods: (mods & Bmask) != 0                       # noqa: E731
        proves = lambda mods, phi: (mods & Bmask & ~phi & full) == 0  # noqa: E731
        ED = [(mo, wt) for mo, wt in theories if cons(mo) and proves(mo, psiD)]
        Z = sum(wt for _, wt in ED)
        if Z == 0:
            continue
        Bel = lambda phi: sum(wt for mo, wt in ED if proves(mo, phi)) / Z  # noqa: E731
        # a random question: partition of the B-models into k cells (pairwise B-incompatible, B-exhaustive)
        k = rnd.randint(2, 5)
        cells = [0] * k
        for v in vals:
            cells[rnd.randrange(k)] |= 1 << v
        bels = [Bel(c) for c in cells]
        un = sum(wt for mo, wt in ED if not any(proves(mo, c) for c in cells)) / Z
        worst["a"] = max(worst["a"], abs(sum(bels) + un - 1))
        J = [i for i in range(k) if rnd.random() < 0.5]
        if J:
            disj = 0
            for i in J:
                disj |= cells[i]
            lhs = Bel(disj) - sum(bels[i] for i in J)
            part = sum(wt for mo, wt in ED if proves(mo, disj) and not any(proves(mo, cells[i]) for i in J)) / Z
            worst["b"] = max(worst["b"], abs(lhs - part))
        phi = rnd.getrandbits(16) & full
        psi = rnd.getrandbits(16) & full
        worst["frechet"] = max(worst["frechet"], Bel(phi) + Bel(psi) - 1 - Bel(phi & psi))
        psi2 = phi | (rnd.getrandbits(16) & full)        # phi entails psi2
        worst["mono"] = max(worst["mono"], Bel(phi) - Bel(psi2))
        nq += 1
    out("  %d random (background, theory pool, data, question) cases" % nq)
    out("  max |sum Bel + Un - 1| = %.2e (Prop 2.1(a));  max |gap - partial-answer mass| = %.2e (2.1(b))"
        % (worst["a"], worst["b"]))
    out("  max [Bel(phi)+Bel(psi)-1-Bel(phi&psi)] = %.2e (must be <= 0);  max [Bel(phi)-Bel(psi), phi |= psi] = %.2e"
        " (must be <= 0)" % (worst["frechet"], worst["mono"]))


# ---------------------------------------------------------------------------------------------- (5)
def rank_and_contains(rows, target):
    """rows, target: dicts var -> Fraction (with key 1 for the constant).  Return True iff the linear
    equation target = 0 is a rational linear combination of the equations rows = 0 (entailment for
    a consistent linear system over an ordered field)."""
    keys = sorted({k for r in rows for k in r} | set(target), key=str)
    M = [[r.get(k, Fr(0)) for k in keys] for r in rows]
    t = [target.get(k, Fr(0)) for k in keys]

    def rank(mat):
        mat = [row[:] for row in mat]
        rk = 0
        ncol = len(keys)
        for c in range(ncol):
            piv = None
            for i in range(rk, len(mat)):
                if mat[i][c] != 0:
                    piv = i
                    break
            if piv is None:
                continue
            mat[rk], mat[piv] = mat[piv], mat[rk]
            for i in range(len(mat)):
                if i != rk and mat[i][c] != 0:
                    f = mat[i][c] / mat[rk][c]
                    mat[i] = [a - f * b for a, b in zip(mat[i], mat[rk])]
            rk += 1
        return rk
    return rank(M) == rank(M + [t]) if M else all(x == 0 for x in t)


def part5():
    out("== (5) Prop 3.1(b): least number of universal-law instances (own exact linear algebra)")
    a = Fr(6)
    us = [Fr(1), Fr(2), Fr(3)]
    poles = ["p", "q"]

    def h(p):
        return ("h", p)

    def s(p, u):
        return ("s", p, u)

    def eq(lhs, rhs_const=Fr(0)):
        """lhs: dict var->coef ; equation sum = rhs_const  ->  row with constant key 1."""
        r = dict(lhs)
        r[1] = r.get(1, Fr(0)) - rhs_const
        return r

    # instance pools
    inst_h = {("Lh", p, u): eq({s(p, u): u, h(p): Fr(-1)}) for p in poles for u in us}
    inst_s = {}
    for p in poles:
        for u in us:
            inst_s[("Ls1", p, u)] = eq({s(p, u): u, s(p, Fr(1)): Fr(-1)})
        inst_s[("Ls2", p)] = eq({h(p): Fr(1), s(p, Fr(1)): Fr(-1)})
    init_H = [eq({h(p): Fr(1)}, a) for p in poles]
    init_S = [eq({s(p, Fr(1)): Fr(1)}, a) for p in poles]
    theories = {"T_H": (inst_h, init_H), "T_S": (inst_h, init_S), "T_H'": (inst_s, init_H), "T_S'": (inst_s, init_S)}
    data = {"shadow s(p,2)=a/2": eq({s("p", Fr(2)): Fr(1)}, a / 2),
            "shadow s(p,3)=a/3": eq({s("p", Fr(3)): Fr(1)}, a / 3),
            "reference s(p,1)=a": eq({s("p", Fr(1)): Fr(1)}, a),
            "height h(p)=a": eq({h("p"): Fr(1)}, a)}
    out("  datum                    " + "  ".join("%5s" % k for k in theories))
    for dn, d in data.items():
        row = []
        for tn, (pool, init) in theories.items():
            best = None
            keys = list(pool)
            for k in range(0, len(keys) + 1):
                for sub in itertools.combinations(keys, k):
                    if rank_and_contains(init + [pool[x] for x in sub], d):
                        best = k
                        break
                if best is not None:
                    break
            row.append(best)
        out("  %-24s " % dn + "  ".join("%5s" % x for x in row))
    out("  notes.md Prop 3.1(b): shadow u!=1: 1,2,2,1; height: 0,1,0,1; (c6: reference shadow 1,0,1,0)")
    # (c) interventional consequences (direct algebra)
    a1 = Fr(6)
    out("  (c) C_H: s_H(p,1,2a)=2a=%s; C_S: s_H(p,1,2a)=s(p,1)=a=%s; differ iff a!=0: %s" % (2 * a1, a1, 2 * a1 != a1))


# ---------------------------------------------------------------------------------------------- (6)
def part6():
    out("== (6) section 4.5 numbers")
    mJ = 1 / 1047.348644      # IAU 2015 nominal mass ratios (Sun/planet), as commonly tabulated
    mS = 1 / 3497.9018
    aJ, aS = 5.2026, 9.5549   # mean semi-major axes (AU)
    al = aJ / aS
    g = 0.0
    for n in range(0, 60):
        cn = math.comb(2 * n, n) / 4 ** n
        g += cn * cn * (2 * n + 1) * al ** (2 * n)
    out("  Jupiter two-body q = 1 + m_J/M = %.5f (notes: 1.00095)" % (1 + mJ))
    out("  Saturn two-body q = 1 + m_S/M = %.5f (notes: 1.00029)" % (1 + mS))
    out("  ring factor g(alpha=%.4f) = %.4f; Saturn ring estimate q = 1 + m_S/M + g m_J/M = %.5f; Jupiter part %.3e"
        " (notes: 1.00154, 1.25e-3)" % (al, g, 1 + mS + g * mJ, g * mJ))
    out("  Mercury: 5599.74 - 5025.6 = %.2f; 574.1 - 531.5 = %.1f; Clemence-style sum 5025.645 + 531.54 + 42.56 = %.3f"
        % (5599.74 - 5025.6, 574.1 - 531.5, 5025.645 + 531.54 + 42.56))


# ---------------------------------------------------------------------------------------------- (7)
def part7():
    out("== (7) c7's crude estimate: rho interval from the most sensitive day (3555'/unit rho)")
    for d in [8, 4, 2]:
        wdt = d / 3555.0
        out("  delta=%d': +-%.3e, bits log2(4/(2w)) = %.2f" % (d, wdt, math.log2(4 / (2 * wdt))))


if __name__ == "__main__":
    out("# rb1_formal.py  seed=%d  python %s" % (SEED, sys.version.split()[0]))
    part1()
    part2()
    part3()
    part4()
    part5()
    part6()
    part7()
    out("# done")
    with open(__file__.replace(".py", ".out"), "w") as f:
        f.write("\n".join(OUT) + "\n")
