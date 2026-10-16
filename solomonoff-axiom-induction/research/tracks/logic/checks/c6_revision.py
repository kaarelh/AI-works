"""c6_revision.py -- checks written for the revision of thread `logic` (notes-final.md), after the
referee reports referee-A.md and referee-B.md.  Independent of the referees' scripts.

Seed 20261016 (R1, R2, R3 use randomness).  Exact rational arithmetic wherever a probability or a
bound is compared.  Output: c6_revision.out (stdout).

R1  Remark 3.4 as revised (index the threshold sets by the PAIR (j, L), not by the rational
    j/2^L).  For random intervals (a, b) of length >= 2^-k: the number of multiples of 2^-L in
    (a, b) is >= 2^(L-k-1) for every L >= k+1, so the pair-indexed sum
    S_pair := sum_{L>=k+1} #multiples(L) * g(L)  is >= the displayed bound
    2^(-k-1) sum_{L>=k+1} g(L),  with stand-in weights g(L) = 2^(-L-K'(L)),
    K'(L) = 2 ceil(log2(L+1)) + 1.  Also reported: the sum with ONE index per rational
    (exact level, odd numerator) can be smaller than S_pair -- the double count that referee A
    (m6) found in the development round's proof step.
R2  Theorem 4.4's prefix facts with a NON-dyadic inconsistency mass (weights k/3^8, as Inc_0 is
    irrational, so 0.w = Inc never happens): U_w := {S : U(O_S) > 0.w} is consistent iff
    0.w > Inc (strict); the prefixes with 0.w > Inc form a final segment of the prefixes of r;
    A_r := {S : U(O_S) > r} is contained in every U_w; and for every finite set of prefixes
    with longest member w*, either all U_{w_i} are inconsistent (0.w* < Inc) or U_{w*} is
    consistent and contained in every U_{w_i}.
R3  Proposition 3.11 (normalised convention for Kgt_m(x); referee B, issue 1): bookkeeping in a
    finite model.  P programs; a consistent theory over B >= PA claims at most one output per
    program (PA proves uniqueness of outputs) and must claim every true output (Sigma_1
    completeness); it refutes Kgt(x) iff it claims some program outputs x, and proves Kgt(x)
    for every unclaimed x iff it settles every program.  Checked: every consistent theory
    refutes at most P strings; sum_x Bel0(not Kgt(x)) <= P * (consistent mass); and the Markov
    count of strings with Dis/Bel > 2^-j is at most P / (2^-j * min Bel).
R4  Theorem 6.1's exponent (referee B, issue 5), re-certified with independent code: for the
    14-symbol Polish syntax of c5, with V = x/(1-x), the term and formula generating functions
    satisfy T = x + V + xT + 2xT^2 and F = 2xT^2 + xF + 3xF^2 + 2xVF.  An exact rational
    super-solution at x0 = 1000/5385 is found by exact bisection; then
    #formulas of length <= L  <=  F*/(1 - x0) * 5.385^L  for every L, and
    delta >= 1/(5 log2 5.385).  The bound is compared with exact counts for L <= 300.
R5  The non-degenerate line-budget example (Example 5.5; referee B, issue 7): model check of the
    countermodel {0,1,2,a}, S(0)=1, S(1)=2, S(2)=2, S(a)=0, R = {0,1,2}: psi_1 :=
    Ax(phi(x) -> R(x)) with phi(x) := x=0 v Ey x=Sy holds, every R(S^n 0) holds, Ax R(x) fails;
    and the one-point structure with R empty refutes R(0) (the data are not valid).
R6  Prop 2.3's threshold is exact for the argument (referee B, issue 8): with one minimal
    inconsistent set of size s, inconsistent mass a and mass (1-a)/s on each "all but phi_i"
    type, the majority set at threshold 1-eps contains the whole inconsistent set while the
    consistent mass exceeds 1-eps iff 1 - s*eps < a < eps, which is feasible iff eps > 1/(s+1).
"""
import random
from fractions import Fraction
from math import ceil, log2

SEED = 20261016
rng = random.Random(SEED)


# ------------------------------------------------------------------ R1
def kprime(L):
    return 2 * ceil(log2(L + 1)) + 1


def g(L):
    return Fraction(1, 2 ** (L + kprime(L)))


def multiples_in(a, b, L):
    """number of j >= 0 with a < j/2^L < b (a, b rationals, 0 <= a < b <= 1)."""
    N = 2 ** L
    lo = (a * N).__floor__() + 1
    hi = (b * N).__ceil__() - 1
    return max(0, hi - lo + 1)


def exact_level(q):
    """level of a dyadic rational q in (0,1): least L with q*2^L integer."""
    L = 0
    while (q * 2 ** L).denominator != 1:
        L += 1
    return L


def R1():
    span = 9
    fails_count = fails_bound = dist_smaller = 0
    n_int = 0
    min_ratio = None
    for k in range(0, 9):
        for _ in range(60):
            length = Fraction(1, 2 ** k) * (1 + Fraction(rng.randint(0, 999), 1000))
            if length > 1:
                length = Fraction(1)
            a = Fraction(rng.randint(0, 10 ** 6), 10 ** 6) * (1 - length)
            b = a + length
            n_int += 1
            S_pair = Fraction(0)
            bound = Fraction(0)
            for L in range(k + 1, k + 1 + span):
                c = multiples_in(a, b, L)
                if c < 2 ** (L - k - 1):
                    fails_count += 1
                S_pair += c * g(L)
                bound += Fraction(2 ** (L - k - 1)) * g(L)
            if S_pair < bound:
                fails_bound += 1
            # one index per rational: each dyadic q in (a,b) of exact level in [k+1, k+span]
            S_dist = Fraction(0)
            seen = set()
            for L in range(k + 1, k + 1 + span):
                N = 2 ** L
                lo = (a * N).__floor__() + 1
                hi = (b * N).__ceil__() - 1
                for j in range(lo, hi + 1):
                    q = Fraction(j, N)
                    if q in seen:
                        continue
                    seen.add(q)
                    lev = exact_level(q)
                    if k + 1 <= lev:
                        S_dist += g(lev)
            if S_dist < S_pair:
                dist_smaller += 1
                r = S_dist / S_pair
                min_ratio = r if min_ratio is None or r < min_ratio else min_ratio
    print(f"R1 Remark 3.4 (pair indexing): {n_int} intervals, k = 0..8, levels k+1..k+{span}")
    print(f"   per-level count of multiples >= 2^(L-k-1): failures {fails_count}")
    print(f"   pair-indexed sum >= displayed bound 2^(-k-1) sum g(L): failures {fails_bound}")
    print(f"   one-index-per-rational sum below the pair sum (the development round's double count): "
          f"{dist_smaller} intervals; min ratio {float(min_ratio):.4f}" if min_ratio is not None
          else "   one-index-per-rational sum never below the pair sum")
    assert fails_count == 0 and fails_bound == 0


# ------------------------------------------------------------------ R2
def nondyadic_weights(m, Z):
    cuts = sorted(rng.sample(range(1, Z), m - 1))
    pts = [0] + cuts + [Z]
    return [Fraction(pts[i + 1] - pts[i], Z) for i in range(m)]


def R2():
    Z = 3 ** 8
    checks = viol = boundary = 0
    for _ in range(300):
        n_true, n_false = rng.randint(3, 8), rng.randint(1, 4)
        atoms = [("t", i) for i in range(n_true)] + [("f", i) for i in range(n_false)]
        m = rng.randint(6, 30)
        ws = nondyadic_weights(m, Z)
        tapes = []
        for _ in range(m):
            if rng.random() < rng.choice([0.1, 0.3, 0.5]):
                tapes.append(None)
            else:
                q = rng.random()
                tapes.append(frozenset(x for x in atoms if x[0] == "t" and rng.random() < q))
        inc = sum(w for w, t in zip(ws, tapes) if t is None)
        if inc == 0 or inc == 1:
            continue
        # sentences: single atoms suffice for U_w membership (conjunctions have U = min over atoms
        # up to the joint event; consistency of U_w depends on whether a false atom is in it)
        def U(S):
            return sum(w for w, t in zip(ws, tapes) if t is None or S <= t)
        Uat = {x: U(frozenset([x])) for x in atoms}
        for _ in range(5):
            # random non-dyadic r in (inc, 1)
            r = inc + (1 - inc) * Fraction(rng.randint(1, 3 ** 10 - 1), 3 ** 10)
            if r.denominator & (r.denominator - 1) == 0:
                continue
            bits = []
            x = r
            for _ in range(40):
                x *= 2
                b = 1 if x >= 1 else 0
                bits.append(b)
                x -= b
            prefixes = []
            for n in range(41):
                val = sum(Fraction(bits[i], 2 ** (i + 1)) for i in range(n))
                prefixes.append(val)
            A_r = {x for x in atoms if Uat[x] > r}
            cons_flags = []
            for val in prefixes:
                checks += 1
                if val == inc:
                    boundary += 1
                Uw = {x for x in atoms if Uat[x] > val}
                consistent = not any(x[0] == "f" for x in Uw)
                cons_flags.append(consistent)
                if consistent != (val > inc):
                    viol += 1
                if not A_r <= Uw:
                    viol += 1
            # final segment
            first = next((i for i, f in enumerate(cons_flags) if f), None)
            if first is None or not all(cons_flags[first:]):
                viol += 1
            # longest-prefix analysis on random finite sets of prefixes
            for _ in range(5):
                idx = sorted(rng.sample(range(41), rng.randint(1, 5)))
                wstar = idx[-1]
                Ustar = {x for x in atoms if Uat[x] > prefixes[wstar]}
                if prefixes[wstar] < inc:
                    ok = all(any(x[0] == "f" for x in {y for y in atoms if Uat[y] > prefixes[i]})
                             for i in idx)
                else:
                    ok = (not any(x[0] == "f" for x in Ustar)) and all(
                        Ustar <= {y for y in atoms if Uat[y] > prefixes[i]} for i in idx)
                checks += 1
                if not ok:
                    viol += 1
    print(f"R2 Thm 4.4 prefix facts, non-dyadic weights (k/3^8): {checks} checks, "
          f"violations {viol}, boundary cases 0.w = Inc: {boundary}")
    assert viol == 0 and boundary == 0


# ------------------------------------------------------------------ R3
def R3():
    viol = 0
    worst_ratio = Fraction(0)
    trials = 0
    for _ in range(200):
        P = rng.randint(3, 15)                    # programs of length <= m
        X = list(range(rng.randint(P + 5, 60)))   # strings of length n
        true_out = {p: rng.choice(X) for p in range(P) if rng.random() < 0.5}
        theories = []                              # (weight, claims dict p -> x, settles_all)
        for _ in range(rng.randint(5, 25)):
            claims = dict(true_out)               # Sigma_1 completeness: true outputs claimed
            for p in range(P):
                if p not in true_out and rng.random() < 0.3:
                    claims[p] = rng.choice(X)     # a false Sigma_1 claim (unsound, consistent)
            settles = rng.random() < 0.5
            theories.append((Fraction(rng.randint(1, 100)), claims, settles))
        tot = sum(w for w, _, _ in theories)
        theories = [(w / tot, c, s) for w, c, s in theories]
        # Bel0(not Kgt(x)) = mass refuting Kgt(x) = mass claiming some p outputs x
        dis = {x: sum(w for w, c, s in theories if x in c.values()) for x in X}
        bel = {x: sum(w for w, c, s in theories if s and x not in c.values()) for x in X}
        for w, c, s in theories:
            if len(set(c.values())) > P:
                viol += 1
        if sum(dis.values()) > P:
            viol += 1
        high_K = [x for x in X if x not in true_out.values()]
        pos = [x for x in high_K if bel[x] > 0]
        if not pos:
            continue
        bmin = min(bel[x] for x in pos)
        for j in range(0, 6):
            thr = Fraction(1, 2 ** j)
            count = sum(1 for x in pos if dis[x] > thr * bel[x])
            bound = P / (thr * bmin)
            trials += 1
            if count > bound:
                viol += 1
            if bound > 0:
                worst_ratio = max(worst_ratio, Fraction(count) / bound)
    print(f"R3 Prop 3.11 bookkeeping: 200 finite models; refuted strings per theory <= P, "
          f"sum_x Dis(x) <= P, Markov counts ({trials} cases): violations {viol}; "
          f"max count/bound = {float(worst_ratio):.4f}")
    assert viol == 0


# ------------------------------------------------------------------ R4
def series_counts(Lmax):
    T = [0] * (Lmax + 1)
    F = [0] * (Lmax + 1)
    Vc = [0] + [1] * Lmax
    for L in range(1, Lmax + 1):
        T[L] = (1 if L == 1 else 0) + Vc[L] + (T[L - 1] if L >= 2 else 0) \
            + 2 * sum(T[a] * T[L - 1 - a] for a in range(1, L - 1))
        F[L] = 2 * sum(T[a] * T[L - 1 - a] for a in range(1, L - 1)) + (F[L - 1] if L >= 2 else 0) \
            + 3 * sum(F[a] * F[L - 1 - a] for a in range(1, L - 1)) \
            + 2 * sum(Vc[lv] * F[L - 1 - lv] for lv in range(1, L - 1))
    return F


def least_root_up(a, b, c, iters=80):
    """for a>0, a z^2 + b z + c with real roots: return a rational z slightly above the smaller root
    with a z^2 + b z + c <= 0, by exact bisection between 0 and the vertex."""
    vertex = -b / (2 * a)
    if a * vertex * vertex + b * vertex + c > 0:
        return None
    lo, hi = Fraction(0), vertex                   # f(lo) = c > 0, f(hi) <= 0
    for _ in range(iters):
        mid = (lo + hi) / 2
        if a * mid * mid + b * mid + c <= 0:
            hi = mid
        else:
            lo = mid
    return hi


def R4():
    g = Fraction(5385, 1000)
    x0 = 1 / g
    V = x0 / (1 - x0)
    # T* >= x0 + V + x0 T + 2 x0 T^2  <=>  2x0 T^2 + (x0 - 1) T + (x0 + V) <= 0
    Ts = least_root_up(2 * x0, x0 - 1, x0 + V)
    assert Ts is not None
    okT = Ts >= x0 + V + x0 * Ts + 2 * x0 * Ts * Ts
    # F* >= 2x0 T*^2 + x0 F + 3 x0 F^2 + 2 x0 V F  <=>  3x0 F^2 + (x0 + 2x0V - 1) F + 2x0 T*^2 <= 0
    Fs = least_root_up(3 * x0, x0 + 2 * x0 * V - 1, 2 * x0 * Ts * Ts)
    assert Fs is not None
    okF = Fs >= 2 * x0 * Ts * Ts + x0 * Fs + 3 * x0 * Fs * Fs + 2 * x0 * V * Fs
    C = Fs / (1 - x0)
    F = series_counts(300)
    cum = 0
    okb = True
    for L in range(1, 301):
        cum += F[L]
        if Fraction(cum) > C * g ** L:
            okb = False
    delta = 1 / (5 * log2(float(g)))
    print(f"R4 certificate at gamma' = 5.385: T* = {float(Ts):.6f}, F* = {float(Fs):.6f}, "
          f"super-solution verified exactly: {okT and okF}")
    print(f"   #formulas of length <= L <= {float(C):.4f} * 5.385^L; checked against exact counts "
          f"L <= 300: {okb}; proved exponent delta >= 1/(5 log2 5.385) = {delta:.5f}")
    # the same at a value below the threshold must fail
    gb = Fraction(538, 100)
    xb = 1 / gb
    Vb = xb / (1 - xb)
    Tb = least_root_up(2 * xb, xb - 1, xb + Vb)
    Fb = None if Tb is None else least_root_up(3 * xb, xb + 2 * xb * Vb - 1, 2 * xb * Tb * Tb)
    print(f"   control at gamma' = 5.38 (below the growth rate ~5.383): certificate exists: {Fb is not None}")
    assert okT and okF and okb and Fb is None


# ------------------------------------------------------------------ R5
def R5():
    dom = ["0", "1", "2", "a"]
    Sf = {"0": "1", "1": "2", "2": "2", "a": "0"}
    R = {"0", "1", "2"}

    def phi(e):
        return e == "0" or any(Sf[y] == e for y in dom)

    psi1 = all((not phi(e)) or (e in R) for e in dom)
    data_ok = True
    e = "0"
    for n in range(0, 61):
        if e not in R:
            data_ok = False
        e = Sf[e]
    allR = all(e in R for e in dom)
    # one-point structure {o}, S(o)=o, 0 denotes o, R empty: the datum R(0) is false there
    dom1, S1, R1set = ["o"], {"o": "o"}, set()
    one_point_refutes = "o" not in R1set and all(S1[e] in dom1 for e in dom1)
    print(f"R5 countermodel: psi_1 true: {psi1}; R(S^n 0) true for n <= 60: {data_ok}; "
          f"Ax R(x) true: {allR}; data not valid (one-point model, R empty): {one_point_refutes}")
    assert psi1 and data_ok and not allR and one_point_refutes


# ------------------------------------------------------------------ R6
def R6():
    ok = True
    for s in range(1, 13):
        crit = Fraction(1, s + 1)
        for eps, expect in ((crit, False), (crit + Fraction(1, 10 ** 4), True)):
            lo, hi = 1 - s * eps, eps
            feasible = lo < hi and hi > 0
            if feasible:
                a = (max(lo, Fraction(0)) + hi) / 2
                pr_phi = a + (s - 1) * (1 - a) / s      # each phi_j: inconsistent + (s-1) types
                majority_has_all = pr_phi > 1 - eps
                cons_mass_ok = 1 - a > 1 - eps
                feasible = majority_has_all and cons_mass_ok
            if feasible != expect:
                ok = False
    print(f"R6 extremal family, s = 1..12: no violation at eps = 1/(s+1), a violation just above: {ok}")
    assert ok


def main():
    print(f"seed {SEED}")
    R1()
    R2()
    R3()
    R4()
    R5()
    R6()
    print("all assertions passed")


if __name__ == "__main__":
    main()
