#!/usr/bin/env python3
"""Referee's independent check of Section 2 and Theorem 3.1 of
research/prove/lower-bounds.md, and of Theorem N2 in note.md.

The prover's script (research/prove/code/lower-bounds_lp.py) enumerates all pure
protocols, which limits it to N0 <= 5.  Here the problem is first reduced by
symmetry, which gives exact values for the parameter range the corollaries
talk about (N0 = L/(2 delta)).

Needle class {f_0, f_1..f_N0}, OR scaffold with L uniform calls.
A protocol is, on the all-zero path, a set S of asked cells and a deployed
outcome g0 (a randomised function of the run's inputs).  Averaging a protocol
over a uniformly random permutation of the cells leaves Fail(f_0) unchanged
and replaces every Fail(f_i) by their average, so the minimax value is
attained by a symmetric protocol: S a uniformly random n-subset, and
q(a, b) = Pr[g0 = 1 | a = |U & S|, b = |U - S|], U = set(z).  Then
    Fail(f_0) = E q(a, b),
    Fail(f_i) = (1/N0) E[ b (1 - q) + (N0 - n - b) q ]   for every i >= 1.
A protocol whose number n of questions (on the f_0-path) is random is a
mixture over n; the failures are linear in the mixture, so the exact minimax
for a given EXPECTED number of questions is one linear programme.
"""
import math
from fractions import Fraction
import numpy as np
from scipy.optimize import linprog


def law_ab(N0, L, n):
    """Exact law of (a, b) = (#distinct visited cells in S, outside S), |S| = n."""
    law = {(0, 0): Fraction(1)}
    for _ in range(L):
        new = {}
        for (a, b), pr in law.items():
            for (da, db, w) in ((0, 0, a + b), (1, 0, n - a), (0, 1, N0 - n - b)):
                if w > 0:
                    key = (a + da, b + db)
                    new[key] = new.get(key, 0) + pr * Fraction(w, N0)
        law = new
    return law


def v_fixed(N0, L, n):
    """Exact minimax failure with exactly n questions (worst case over members)."""
    law = law_ab(N0, L, n)
    keys = list(law)
    k = len(keys)
    # variables q_0..q_{k-1}, v ; minimise v
    c = np.zeros(k + 1); c[-1] = 1
    A = np.zeros((2, k + 1)); b_ub = np.zeros(2)
    for j, (a, b) in enumerate(keys):
        pr = float(law[(a, b)])
        A[0, j] = pr                                   # Fail(f_0)
        A[1, j] = pr * (N0 - n - 2 * b) / N0           # Fail(f_i), q-part
        b_ub[1] -= pr * b / N0                          # constant part moved right
    A[:, -1] = -1
    res = linprog(c, A_ub=A, b_ub=b_ub, bounds=[(0, 1)] * k + [(None, None)], method="highs")
    assert res.status == 0
    return res.fun


def lp_expected(N0, L, nbar=None, delta=None):
    """If nbar is given: exact minimax failure over protocols with E n <= nbar.
    If delta is given: least expected number of questions with all failures <= delta."""
    laws = [law_ab(N0, L, n) for n in range(N0 + 1)]
    idx = []                                            # (n, a, b) for r-variables
    for n, law in enumerate(laws):
        for key in law:
            idx.append((n,) + key)
    nr = len(idx); nl = N0 + 1
    nv = nr + nl + 1                                    # r, lambda, v
    F0 = np.zeros(nv); F1 = np.zeros(nv)
    rows = []; rhs = []
    for j, (n, a, b) in enumerate(idx):
        pr = float(laws[n][(a, b)])
        F0[j] = pr
        F1[j] = pr * (N0 - n - 2 * b) / N0
        F1[nr + n] += pr * b / N0                       # b * lambda_n
        row = np.zeros(nv); row[j] = 1; row[nr + n] = -1   # r <= lambda_n
        rows.append(row); rhs.append(0.0)
    A_eq = np.zeros((1, nv)); A_eq[0, nr:nr + nl] = 1
    nvec = np.zeros(nv); nvec[nr:nr + nl] = np.arange(nl)
    bounds = [(0, None)] * (nr + nl) + [(None, None)]
    if nbar is not None:
        c = np.zeros(nv); c[-1] = 1
        r0 = F0.copy(); r0[-1] = -1
        r1 = F1.copy(); r1[-1] = -1
        A_ub = np.vstack(rows + [r0, r1, nvec]); b_ub = np.array(rhs + [0, 0, nbar])
    else:
        c = nvec
        A_ub = np.vstack(rows + [F0, F1]); b_ub = np.array(rhs + [delta, delta])
        bounds[-1] = (0, 0)
    res = linprog(c, A_ub=A_ub, b_ub=b_ub, A_eq=A_eq, b_eq=[1.0], bounds=bounds, method="highs")
    assert res.status == 0, res.message
    return res.fun


def p_hit(L, N):
    return 1 - (1 - 1 / N) ** L


def check_against_prover_lp():
    print("1. Fixed n: symmetric value v(n) against the prover's enumeration (lower-bounds.md, 8.1)")
    quoted = {(3, 2): [0.416667, 0.222222, 0.138889],
              (4, 2): [0.437500, 0.262500, 0.156250, 0.087500],
              (5, 2): [0.360000, 0.288000, 0.180000, 0.112000, 0.060000],
              (4, 3): [0.390625, 0.309375, 0.192708, 0.115625]}
    for (N0, L), vals in quoted.items():
        mine = [v_fixed(N0, L, n) for n in range(len(vals))]
        ok = all(abs(x - y) < 2e-6 for x, y in zip(mine, vals))
        print(f"   N0={N0} L={L}: " + " ".join(f"{x:.6f}" for x in mine) + f"   agrees with the quoted table: {ok}")
        assert ok
    print()


def check_theorem_2_1():
    print("2. Theorem 2.1 against the exact minimax for an EXPECTED number of questions")
    print("    N0   L   nbar   bound (N0-n)p/(N0+L)   exact minimax   Prop 2.3 protocol (N0-n)p/N0")
    worst = 1e9
    for N0, L in ((3, 2), (5, 2), (8, 3), (20, 2), (20, 5), (40, 4), (60, 3)):
        p = p_hit(L, N0)
        for frac in (0.0, 0.1, 0.25, 0.5, 0.75, 0.9):
            nbar = frac * N0
            lo = (N0 - nbar) * p / (N0 + L)
            v = lp_expected(N0, L, nbar=nbar)
            up = (N0 - nbar) * p / N0
            assert lo <= v + 1e-9, (N0, L, nbar, lo, v)
            assert v <= up + 1e-9
            if lo > 0:
                worst = min(worst, v / lo)
            if frac in (0.25, 0.5):
                print(f"   {N0:4d} {L:3d} {nbar:6.2f}   {lo:.6f}               {v:.6f}        {up:.6f}")
    print(f"   smallest ratio exact/bound over all rows computed: {worst:.4f} (must be >= 1)")
    print()


def check_corollary_2_2():
    print("3. Corollary 2.2(1) and Proposition 2.3: least expected number of questions with failure <= delta,")
    print("   needle class with N0 = L/(2 delta)")
    print("     L   delta    N0   L/(4delta)-L   exact n*(delta)   ceil(L/(4delta))   exact/(L/(4delta))")
    for L, inv2d in ((1, 10), (1, 40), (2, 20), (3, 20), (4, 10), (4, 25), (5, 16), (8, 10), (2, 100)):
        N0 = L * inv2d                       # delta = 1/(2 inv2d)
        delta = 1 / (2 * inv2d)
        nstar = lp_expected(N0, L, delta=delta)
        lo = L / (4 * delta) - L
        up = math.ceil(L / (4 * delta))
        assert lo <= nstar + 1e-7 <= up + 2e-7, (L, delta, lo, nstar, up)
        print(f"   {L:3d}  {delta:.4f}  {N0:4d}   {lo:10.2f}   {nstar:13.3f}   {up:10d}          {nstar / (L / (4 * delta)):.4f}")
    print()


def check_corollary_2_2_item2():
    print("3b. Corollary 2.2(2): any delta <= 1/6, N0 = ceil(L/(2 delta)); claim L/(4delta) - 3L/2 <= n*(delta);")
    print("    and ceil(N0/2) questions suffice (protocol of Proposition 2.3, since p <= L/N0 <= 2 delta)")
    print("     L   delta    N0   L/(4delta)-3L/2   exact n*(delta)   ceil(N0/2)")
    for L, delta in ((1, 0.07), (2, 0.03), (3, 0.11), (4, 0.045), (5, 1 / 6), (7, 0.09), (6, 0.013)):
        N0 = math.ceil(L / (2 * delta) - 1e-12)
        nstar = lp_expected(N0, L, delta=delta)
        lo = L / (4 * delta) - 1.5 * L
        up = math.ceil(N0 / 2)
        assert lo <= nstar + 1e-7 <= up + 2e-7, (L, delta, lo, nstar, up)
        assert (1 - up / N0) * p_hit(L, N0) <= delta + 1e-12
        print(f"   {L:3d}  {delta:.4f}  {N0:4d}   {lo:12.2f}   {nstar:13.3f}   {up:10d}")
    print()


def check_note_N2():
    print("4. note.md, Theorem N2: N = least integer >= L/(8 gamma); claim: failure <= gamma for all members")
    print("   forces n > L/(16 gamma) (n = worst-case number of questions)")
    print("     L   gamma     N   L/(16 gamma)   least integer n with v(n) <= gamma   least expected n")
    for L, gamma in ((1, 1 / 16), (2, 1 / 16), (4, 1 / 16), (3, 1 / 32), (5, 1 / 40), (2, 1 / 100)):
        N = math.ceil(L / (8 * gamma) - 1e-12)
        n_int = next(n for n in range(N + 1) if v_fixed(N, L, n) <= gamma + 1e-12)
        n_exp = lp_expected(N, L, delta=gamma)
        claim = L / (16 * gamma)
        assert n_int > claim and n_exp > claim - 1e-9
        print(f"   {L:3d}  {gamma:.4f}  {N:4d}   {claim:8.2f}       {n_int:6d}                               {n_exp:8.3f}")
    print("   (the claim holds.  For this N, Theorem 2.1 of lower-bounds.md gives about 7N/8 = 0.11 L/gamma, which is")
    print("    what the exact values show; the larger class N0 = L/(2 gamma) forces about L/(4 gamma), see table 3)")
    print()


# ---------------------------------------------------------------- Theorem 3.1
def single_block_points(N, L):
    """Block class with m = 1: {f_a : a in [N]}, exactly one needle.  A symmetric
    protocol scans k cells in random order (stopping at the needle), k <= N-1,
    and deploys q(a, b) after k zeros.  Returns the points
    (expected questions for uniform a, least average failure) for k = 0..N-1."""
    pts = []
    for k in range(N):
        law = law_ab(N, L, k)
        fail = sum(pr * min(b, N - k - b) for (a, b), pr in law.items()) / N
        nq = Fraction(k) - Fraction(k * (k - 1), 2 * N)
        pts.append((float(nq), float(fail)))
    return pts


def lower_envelope(pts):
    """Lower convex envelope of points sorted by x; returns a function."""
    pts = sorted(pts)
    hull = []
    for x, y in pts:
        while len(hull) >= 2:
            (x1, y1), (x2, y2) = hull[-2], hull[-1]
            if (y2 - y1) * (x - x1) >= (y - y1) * (x2 - x1):
                hull.pop()
            else:
                break
        hull.append((x, y))
    def env(x):
        if x <= hull[0][0]:
            return hull[0][1]
        for (x1, y1), (x2, y2) in zip(hull, hull[1:]):
            if x1 <= x <= x2:
                return y1 + (y2 - y1) * (x - x1) / (x2 - x1)
        return hull[-1][1]
    def inv(d):
        """least x with env(x) <= d"""
        if hull[0][1] <= d:
            return hull[0][0]
        for (x1, y1), (x2, y2) in zip(hull, hull[1:]):
            if y2 <= d <= y1:
                return x1 + (x2 - x1) * (y1 - d) / (y1 - y2)
        return float("inf")
    return env, inv


def check_theorem_3_1():
    print("5. Theorem 3.1 (block class).  Per block, the exact Bayes value as a function of the expected")
    print("   number x of questions in the block is the lower convex envelope E1(x) of the single-block points;")
    print("   for m blocks and n questions the uniform-prior Bayes value is E1(n/m) (blocks are independent")
    print("   under the prior, and E1 is convex).  Theorem 3.1 claims p(1 - 2L/N - 2x/N) <= E1(x).")
    worst = 1e9
    for N, L in ((6, 1), (10, 2), (20, 2), (40, 2), (40, 4), (100, 5), (160, 8)):
        p = p_hit(L, N)
        env, inv = lower_envelope(single_block_points(N, L))
        for i in range(0, 41):
            x = i / 40 * N / 2
            lb = p * (1 - 2 * L / N - 2 * x / N)
            assert lb <= env(x) + 1e-12, (N, L, x, lb, env(x))
            if lb > 1e-12:
                worst = min(worst, env(x) / lb)
    print(f"   inequality holds on all grid points; smallest ratio E1/bound where the bound is positive: {worst:.4f}")
    print("   Least expected questions per block for average failure <= delta, with N = L/(2 delta):")
    print("     L   delta     N   (1-10delta)L/(8delta)   exact x*   Prop 3.2: (L/(4delta)+1/2)/2")
    for L, inv2d in ((1, 20), (2, 20), (2, 50), (4, 25), (5, 40), (8, 20)):
        N = L * inv2d; delta = 1 / (2 * inv2d)
        env, inv = lower_envelope(single_block_points(N, L))
        xstar = inv(delta)
        lo = (1 - 10 * delta) * L / (8 * delta)
        up = (L / (4 * delta) + 0.5) / 2
        assert lo <= xstar + 1e-9 <= up + 1e-9, (L, delta, lo, xstar, up)
        print(f"   {L:3d}  {delta:.4f}  {N:4d}   {lo:12.2f}          {xstar:9.3f}   {up:10.2f}")
    print()


if __name__ == "__main__":
    check_against_prover_lp()
    check_theorem_2_1()
    check_corollary_2_2()
    check_corollary_2_2_item2()
    check_note_N2()
    check_theorem_3_1()
    print("all checks passed")
