#!/usr/bin/env python3
"""c1_structure.py -- thread `fundamentals`, independent finite stand-in for the structure results.

Written from the definitions of notes.md (Sections 1-3), not from scout F's c1_toy.py.

Finite propositional stand-in.
* k propositional atoms; a valuation is an integer v in [0, 2^k); a proposition ("sentence content")
  is a bitmask over the 2^k valuations.  A *sentence* is a pair (sid, mask): distinct sentences may
  have the same mask (logically equivalent sentences), which tests that weights depend on Cn only.
* A theory is represented by its set of models, a bitmask M; M == 0 is the inconsistent theory.
  "T proves chi" iff M is a subset of chi (for M == 0 every chi is proved).
* A prior is a finite list of (M, w) with w > 0 and total weight <= 1 (the rest is "missing" mass,
  like the tapes with no program).  This is the law of a theory machine whose tape selects one of
  finitely many finite theories (dyadic weights are realisable exactly; we use rationals).
* The posterior after data D is the prior restricted to consistent theories proving psi_D.

Exact rational arithmetic (fractions.Fraction) is used for the identities; logs use floats.
Seed 20261016.  Output: c1_structure.out (written next to this script).

Items checked (labels as in notes.md):
  A1  semimeasure inequality, defect = three-valued mass = M(D)*Indep_D            (Prop 2.1(b),(f))
  A2  entailed data free, contradicting data fatal; equivalent sentences            (Prop 2.1(c))
  A3  order independence of the semimeasure-convention loss                         (Prop 2.1(d))
  A4  M3 additive                                                                    (Prop 2.1(f))
  A5  proof-requiring update = geometric conditioning of Bel_0                       (Prop 2.2(a))
  A6  total monotonicity of Bel_0 and Bel_D                                          (Prop 2.2(b))
  A7  coherent bracketing Bel <= P <= Pl via a selected completion                   (Prop 2.2(c))
  A8  consistency-requiring update = Dempster conditioning                           (Prop 2.3)
  A9  M^nc is a plausibility (sum over labels >= value), excess = undecided mass     (Prop 7.1(a))
  A10 M^nc >= weight of the empty theory on consistent data                          (Prop 7.1(b))
  A11 the decomposition of the CR predictor into PR + weak-theory part (N10)         (Prop 7.4)
  A12 graded CR: weak semimeasure, >= M, charges entailed data, not split-invariant  (Prop 7.3)
  A13 limit posterior: total variation <= delta_n / a_n                              (Prop 8.1)
  A14 incomplete truth: two-valued limit = prior on extensions; three-valued -> [T*] (Prop 8.3)
  A15 three-valued merging identity and bound                                       (Thm 5.4)
"""
import itertools
import math
import os
import random
from fractions import Fraction as Fr

SEED = 20261016
rng = random.Random(SEED)
OUT = []


def out(s=""):
    OUT.append(s)
    print(s)


# ---------------------------------------------------------------- universe
class Universe:
    def __init__(self, k):
        self.k = k
        self.nv = 1 << k
        self.FULL = (1 << self.nv) - 1

    def atom(self, i):
        m = 0
        for v in range(self.nv):
            if (v >> i) & 1:
                m |= 1 << v
        return m

    def neg(self, m):
        return self.FULL & ~m

    def rand_prop(self, nonempty=True, notfull=True):
        while True:
            m = rng.getrandbits(self.nv)
            if nonempty and m == 0:
                continue
            if notfull and m == self.FULL:
                continue
            return m


def subset(a, b):
    return a & ~b == 0


# ---------------------------------------------------------------- data and weights
# a datum is (sid, mask, label), label in {1, 0, 'i'}

def lit(U, mask, b):
    return mask if b == 1 else U.neg(mask)


def psi(U, D):
    m = U.FULL
    for (_, mask, b) in D:
        if b in (0, 1):
            m &= lit(U, mask, b)
    return m


def decides(U, M, mask):
    return subset(M, mask) or subset(M, U.neg(mask))


def compatible_pr(U, M, D):
    """M consistent, proves the two-valued literals, decides no iota-labelled sentence."""
    if M == 0:
        return False
    if not subset(M, psi(U, D)):
        return False
    for (_, mask, b) in D:
        if b == 'i' and decides(U, M, mask):
            return False
    return True


def weight(U, prior, D):
    return sum((w for (M, w) in prior if compatible_pr(U, M, D)), Fr(0))


def bel0(U, prior, chi):
    return sum((w for (M, w) in prior if M != 0 and subset(M, chi)), Fr(0))


def posterior(U, prior, D):
    Z = weight(U, prior, D)
    return [(M, w / Z) for (M, w) in prior if compatible_pr(U, M, D)], Z


def tri_from_post(U, post, mask):
    b = sum((w for (M, w) in post if subset(M, mask)), Fr(0))
    d = sum((w for (M, w) in post if subset(M, U.neg(mask))), Fr(0))
    return b, d, 1 - b - d


def mnc(U, prior, D):
    p = psi(U, D)
    return sum((w for (M, w) in prior if M & p != 0), Fr(0))


def bel_nc(U, prior, D, chi):
    p = psi(U, D)
    Z = mnc(U, prior, D)
    num = sum((w for (M, w) in prior if (M & p) != 0 and subset(M & p, chi)), Fr(0))
    return num / Z


def nu_half(U, M, D):
    p = psi(U, D)
    if M == 0 or (M & p) == 0:
        return Fr(0)
    val = Fr(1)
    for (_, mask, b) in D:
        if b in (0, 1) and not subset(M, lit(U, mask, b)):
            val /= 2
    return val


def m_half(U, prior, D):
    return sum((w * nu_half(U, M, D) for (M, w) in prior if M != 0), Fr(0))


def rand_prior(U, n=6, p_inc=0.3, total=None, with_empty=True):
    """random finite prior; optionally includes the inconsistent theory and the empty theory."""
    thetas = [U.rand_prop(nonempty=True, notfull=False) for _ in range(n)]
    if with_empty:
        thetas.append(U.FULL)
    if rng.random() < p_inc:
        thetas.append(0)
    raw = [Fr(rng.randint(1, 20)) for _ in thetas]
    if total is None:
        total = Fr(rng.randint(5, 10), 10)
    s = sum(raw)
    return [(M, total * r / s) for (M, r) in zip(thetas, raw)]


def rand_data(U, n, sid0=0):
    """labels from a random valuation with probability 0.8 (consistent data), else fair coins."""
    if rng.random() < 0.8:
        v = rng.randrange(U.nv)
        D = []
        for j in range(n):
            m = U.rand_prop()
            D.append((sid0 + j, m, (m >> v) & 1))
        return D
    return [(sid0 + j, U.rand_prop(), rng.randint(0, 1)) for j in range(n)]


def lg(x):
    return math.log2(x)


# ---------------------------------------------------------------- Part A
def part_A():
    out("=== Part A: identities on random finite instances (k = 3 atoms, 8 valuations) ===")
    U = Universe(3)
    T = 400
    worst = {key: Fr(0) for key in ["A1sum", "A1defect", "A1indep", "A4", "A5", "A8", "A9", "A11", "A12weak"]}
    worst_f = {"A3": 0.0, "A6": Fr(0), "A7": Fr(0)}
    cnt = {"A2": 0, "A9strict": 0, "A10": 0, "A12ge": 0, "A12charge": 0, "consistentD": 0}
    for _ in range(T):
        prior = rand_prior(U)
        D = rand_data(U, rng.randint(0, 3))
        phi = (100, U.rand_prop(), None)
        MD = weight(U, prior, D)
        if MD == 0:
            continue
        cnt["consistentD"] += 1
        D1 = D + [(phi[0], phi[1], 1)]
        D0 = D + [(phi[0], phi[1], 0)]
        Di = D + [(phi[0], phi[1], 'i')]
        m1, m0, mi = weight(U, prior, D1), weight(U, prior, D0), weight(U, prior, Di)
        # A1
        worst["A1sum"] = max(worst["A1sum"], m1 + m0 - MD)          # must be <= 0
        worst["A1defect"] = max(worst["A1defect"], abs((MD - m1 - m0) - mi))
        post, _ = posterior(U, prior, D)
        b, d, ind = tri_from_post(U, post, phi[1])
        worst["A1indep"] = max(worst["A1indep"], abs((MD - m1 - m0) / MD - ind))
        # A4 additivity of M3 on a three-valued base (add one iota datum to D first)
        psi_extra = (200, U.rand_prop(), 'i')
        Dbase = D + [psi_extra]
        if weight(U, prior, Dbase) > 0:
            tot = sum(weight(U, prior, Dbase + [(phi[0], phi[1], y)]) for y in (1, 0, 'i'))
            worst["A4"] = max(worst["A4"], abs(tot - weight(U, prior, Dbase)))
        # A2 entailed datum (a new sentence equivalent to a weakening of psi_D), contradicting datum
        p = psi(U, D)
        ent = p | U.rand_prop(nonempty=False, notfull=False)   # psi_D entails ent
        ok = (weight(U, prior, D + [(300, ent, 1)]) == MD and weight(U, prior, D + [(300, ent, 0)]) == 0)
        # a logically equivalent copy of phi labelled like phi
        ok2 = weight(U, prior, D1 + [(301, phi[1], 1)]) == m1 and weight(U, prior, D1 + [(301, phi[1], 0)]) == 0
        cnt["A2"] += int(ok and ok2)
        # A5 geometric conditioning
        geo = bel0(U, prior, p & phi[1]) / bel0(U, prior, p)
        worst["A5"] = max(worst["A5"], abs(geo - b))
        # A8 Dempster conditioning for the CR predictor
        if mnc(U, prior, D) > 0:
            bnc = bel_nc(U, prior, D, phi[1])
            top = bel0(U, prior, U.FULL)
            dem = (bel0(U, prior, phi[1] | U.neg(p)) - bel0(U, prior, U.neg(p))) / (top - bel0(U, prior, U.neg(p)))
            worst["A8"] = max(worst["A8"], abs(bnc - dem))
            # A9: plausibility
            s = mnc(U, prior, D1) + mnc(U, prior, D0)
            und = sum((w for (M, w) in prior if (M & p) != 0 and not decides(U, M & p, phi[1])), Fr(0))
            worst["A9"] = max(worst["A9"], abs(s - mnc(U, prior, D) - und))
            cnt["A9strict"] += int(s > mnc(U, prior, D))
            # A10
            wempty = sum((w for (M, w) in prior if M == U.FULL), Fr(0))
            cnt["A10"] += int(mnc(U, prior, D) >= wempty)
            # A11 decomposition
            lhs = mnc(U, prior, D) * bnc
            weakpart = sum((w for (M, w) in prior
                            if M != 0 and (M & p) != 0 and not subset(M, p) and subset(M & p, phi[1])), Fr(0))
            rhs = MD * b + weakpart
            worst["A11"] = max(worst["A11"], abs(lhs - rhs))
        # A12 graded
        sh = m_half(U, prior, D1) + m_half(U, prior, D0) - m_half(U, prior, D)
        worst["A12weak"] = max(worst["A12weak"], sh)
        cnt["A12ge"] += int(m_half(U, prior, D) >= MD)
        if any(M == U.FULL for (M, _) in prior) and (p != U.FULL) and len(D) > 0:
            # an entailed datum that the empty theory does not prove: ent strictly weaker than p
            ent2 = p | (U.neg(p) & U.rand_prop(nonempty=False, notfull=False))
            if ent2 != U.FULL:
                cnt["A12charge"] += int(m_half(U, prior, D + [(302, ent2, 1)]) < m_half(U, prior, D))
        # A3 order independence (semimeasure convention) on a sequence of up to 4 data
        seq = D + [(phi[0], phi[1], rng.randint(0, 1))]
        if weight(U, prior, seq) > 0:
            target = -lg(weight(U, prior, seq)) + lg(weight(U, prior, []))
            for perm in itertools.permutations(seq):
                L = 0.0
                for t in range(len(perm)):
                    L += -lg(weight(U, prior, list(perm[:t + 1])) / weight(U, prior, list(perm[:t])))
                worst_f["A3"] = max(worst_f["A3"], abs(L - target))
        # A6 total monotonicity for 4 random propositions, prior and posterior
        props = [U.rand_prop() for _ in range(4)]
        for bel in (lambda c: bel0(U, prior, c) / bel0(U, prior, U.FULL),
                    lambda c: sum((w for (M, w) in post if subset(M, c)), Fr(0))):
            union = 0
            for c in props:
                union |= c
            rhs = Fr(0)
            for r in range(1, 5):
                for I in itertools.combinations(range(4), r):
                    inter = U.FULL
                    for i in I:
                        inter &= props[i]
                    rhs += (-1) ** (r + 1) * bel(inter)
            worst_f["A6"] = max(worst_f["A6"], rhs - bel(union))        # must be <= 0
        # A7 bracketing: completion = least valuation in each model set
        P = {}
        for (M, w) in post:
            v = (M & -M).bit_length() - 1
            P[v] = P.get(v, Fr(0)) + w
        for c in props + [phi[1]]:
            Pc = sum((w for v, w in P.items() if (c >> v) & 1), Fr(0))
            bc, dc, _ = tri_from_post(U, post, c)
            worst_f["A7"] = max(worst_f["A7"], bc - Pc, Pc - (1 - dc))   # must be <= 0
    out(f"trials: {T}; trials with M(D) > 0 (D consistent and proved by some theory of the finite prior): {cnt['consistentD']}")
    out(f"(A1) max of M(D+(phi,1)) + M(D+(phi,0)) - M(D)            [<= 0]: {float(worst['A1sum']):.3e}")
    out(f"(A1) max |defect - M3(D+(phi,iota))|                       [= 0]: {float(worst['A1defect']):.3e}  (exact)")
    out(f"(A1) max |defect/M(D) - Indep_D(phi) from posterior|       [= 0]: {float(worst['A1indep']):.3e}  (exact)")
    out(f"(A2) entailed datum free, contradicting datum fatal, equivalent copy free: {cnt['A2']} of {cnt['consistentD']}")
    out(f"(A3) max |loss over every permutation - (-log M(D_n) + log M(empty))| [= 0]: {worst_f['A3']:.3e}")
    out(f"(A4) max |sum_y M3(D+(phi,y)) - M3(D)|                     [= 0]: {float(worst['A4']):.3e}  (exact)")
    out(f"(A5) max |Bel_0(psi & phi)/Bel_0(psi) - posterior Bel|     [= 0]: {float(worst['A5']):.3e}  (exact)")
    out(f"(A6) max of inclusion-exclusion sum - Bel(union), 4 props  [<= 0]: {float(worst_f['A6']):.3e}")
    out(f"(A7) max of Bel - P and P - Pl for the selected completion [<= 0]: {float(worst_f['A7']):.3e}")
    out(f"(A8) max |CR posterior Bel^nc - Dempster formula|          [= 0]: {float(worst['A8']):.3e}  (exact)")
    out(f"(A9) max |M^nc(D+1)+M^nc(D+0)-M^nc(D) - undecided mass|   [= 0]: {float(worst['A9']):.3e}; strict excess in {cnt['A9strict']} trials")
    out(f"(A10) M^nc(D) >= weight of the empty theory: {cnt['A10']} trials (of those with M^nc>0)")
    out(f"(A11) max |M^nc Bel^nc - (M Bel + weak-theory part)|        [= 0]: {float(worst['A11']):.3e}  (exact)")
    out(f"(A12) max of M_half(D+1)+M_half(D+0)-M_half(D)              [<= 0]: {float(worst['A12weak']):.3e}")
    out(f"(A12) M_half(D) >= M(D) in {cnt['A12ge']} of {cnt['consistentD']} trials; "
        f"M_half strictly smaller after an entailed datum in {cnt['A12charge']} trials (M unchanged, A2)")
    # A12 split non-invariance, by hand: empty theory alone
    U2 = Universe(2)
    a, b = U2.atom(0), U2.atom(1)
    prior = [(U2.FULL, Fr(1, 2)), (a & b, Fr(1, 2))]
    one = m_half(U2, prior, [(0, a & b, 1)])
    two = m_half(U2, prior, [(0, a, 1), (1, b, 1)])
    out(f"(A12) split non-invariance, prior 1/2 empty theory + 1/2 theory {{a&b}}: M_half({{(a&b,1)}}) = {one}, M_half({{(a,1),(b,1)}}) = {two}; "
        f"PR weights {weight(U2, prior, [(0, a & b, 1)])}, {weight(U2, prior, [(0, a, 1), (1, b, 1)])}")
    out()


# ---------------------------------------------------------------- Part B: limits
def part_B():
    out("=== Part B: limit posterior in total variation (A13) and incomplete truth (A14) ===")
    U = Universe(3)
    worst = 0.0
    for _ in range(300):
        prior = rand_prior(U, n=10)
        # a consistent stream: literals true in a random valuation, in random order, over random sentences
        v0 = rng.randrange(U.nv)
        seq = []
        for j in range(8):
            m = U.rand_prop()
            seq.append((j, m, 1 if (m >> v0) & 1 else 0))
        a_inf = weight(U, prior, seq)
        if a_inf == 0:
            continue
        post_inf, _ = posterior(U, prior, seq)
        pinf = {}
        for (M, w) in post_inf:
            pinf[M] = pinf.get(M, Fr(0)) + w
        for n in range(len(seq) + 1):
            a_n = weight(U, prior, seq[:n])
            post_n, _ = posterior(U, prior, seq[:n])
            pn = {}
            for (M, w) in post_n:
                pn[M] = pn.get(M, Fr(0)) + w
            keys = set(pn) | set(pinf)
            tv = sum(abs(pn.get(x, Fr(0)) - pinf.get(x, Fr(0))) for x in keys) / 2
            bound = (a_n - a_inf) / a_n
            worst = max(worst, float(tv - bound))
    out(f"(A13) max over 300 streams and prefixes of TV(P_n, P_inf) - (a_n - a_inf)/a_n   [<= 0]: {worst:.3e}")
    # A14: T* with two models among 8 valuations; theories = all nonempty model sets with random weights
    v1, v2 = 1, 6
    Tstar = (1 << v1) | (1 << v2)
    thetas = list(range(1, 1 << U.nv))
    raw = [Fr(rng.randint(1, 9)) for _ in thetas]
    s = sum(raw)
    prior = [(M, r / s) for M, r in zip(thetas, raw)]
    # two-valued presentation: every proposition decided by T*, labelled
    two = []
    three = []
    for j, m in enumerate(range(1, U.FULL)):
        if subset(Tstar, m):
            two.append((j, m, 1)); three.append((j, m, 1))
        elif subset(Tstar, U.neg(m)):
            two.append((j, m, 0)); three.append((j, m, 0))
        else:
            three.append((j, m, 'i'))
    comp2 = sorted({M for (M, w) in prior if compatible_pr(U, M, two)})
    comp3 = sorted({M for (M, w) in prior if compatible_pr(U, M, three)})
    out(f"(A14) T* model set {bin(Tstar)}; two-valued limit leaves the theories {[bin(M) for M in comp2]} "
        f"(T* and its two completions)")
    post2, _ = posterior(U, prior, two)
    indep = 1 << v1                      # true only at v1: independent of T*
    b, d, ind = tri_from_post(U, post2, indep)
    wsh = {M: w for (M, w) in prior}
    tot = wsh[Tstar] + wsh[1 << v1] + wsh[1 << v2]
    out(f"(A14) limit trichotomy of a T*-independent sentence: Bel={float(b):.4f} Dis={float(d):.4f} Indep={float(ind):.4f}; "
        f"prior shares {float(wsh[1 << v1] / tot):.4f}, {float(wsh[1 << v2] / tot):.4f}, {float(wsh[Tstar] / tot):.4f}")
    out(f"(A14) three-valued limit leaves {[bin(M) for M in comp3]} (only [T*])")
    out()


# ---------------------------------------------------------------- Part C: three-valued merging identity
def part_C():
    out("=== Part C: three-valued merging (A15) ===")
    U = Universe(3)
    worst_id = 0.0
    worst_bd = -1e9
    cases = 0
    for trial in range(60):
        # nu: a law of an a.s. consistent random theory, finitely many outcomes
        nu_th = [U.rand_prop(nonempty=True, notfull=False) for _ in range(3)]
        raw = [rng.randint(1, 9) for _ in nu_th]
        nu = [(M, Fr(r, sum(raw))) for M, r in zip(nu_th, raw)]
        w = Fr(rng.randint(1, 6), 16)
        others = rand_prior(U, n=4, total=Fr(rng.randint(2, 8), 16))
        mix = [(M, w * x) for (M, x) in nu] + others
        n = 3
        cands = [U.rand_prop() for _ in range(6)]

        def rule(hist, xi):
            # question depends on the history (labels seen) and on independent randomness xi
            h = sum((1 + (0 if y == 'i' else y)) * 3 ** t for t, (_, _, y) in enumerate(hist))
            return (len(hist), cands[(h + 2 * xi + len(hist)) % len(cands)])

        def label(M, mask):
            if subset(M, mask):
                return 1
            if subset(M, U.neg(mask)):
                return 0
            return 'i'

        sum_Ed = 0.0
        E_logratio = 0.0
        for xis in itertools.product((0, 1), repeat=n):
            pxi = 0.5 ** n
            for (Mtrue, pt) in nu:
                hist = []
                for t in range(n):
                    sid, mask = rule(hist, xis[t])
                    if any(s == sid for (s, _, _) in hist):
                        continue
                    # one-step KL between nu3 and M3 conditionals
                    base_nu = weight(U, nu, hist)
                    base_m = weight(U, mix, hist)
                    d = 0.0
                    for y in (1, 0, 'i'):
                        pn = weight(U, nu, hist + [(sid, mask, y)]) / base_nu
                        pm = weight(U, mix, hist + [(sid, mask, y)]) / base_m
                        if pn > 0:
                            d += float(pn) * lg(pn / pm)
                    sum_Ed += pxi * float(pt) * d
                    hist.append((sid, mask, label(Mtrue, mask)))
                E_logratio += pxi * float(pt) * (lg(weight(U, nu, hist)) - lg(weight(U, mix, hist)))
        rhs = E_logratio + lg(weight(U, mix, []))
        worst_id = max(worst_id, abs(sum_Ed - rhs))
        worst_bd = max(worst_bd, sum_Ed - (-lg(w) + lg(weight(U, mix, []))))
        cases += 1
    out(f"(A15) {cases} instances, n = 3 questions, history- and coin-dependent question rule")
    out(f"(A15) max |sum_t E d_t - (E log nu3(D_n)/M3(D_n) + log M3(empty))|  [= 0]: {worst_id:.3e}")
    out(f"(A15) max of sum_t E d_t - (-log w + log M3(empty))                    [<= 0]: {worst_bd:.3e}")
    out()


if __name__ == "__main__":
    out(f"seed {SEED}")
    part_A()
    part_B()
    part_C()
    here = os.path.dirname(os.path.abspath(__file__))
    with open(os.path.join(here, "c1_structure.out"), "w") as f:
        f.write("\n".join(OUT) + "\n")
