"""rB1 (referee B): exact checks of notes.md Sections 2-3 on finite point sets.

Independent of checks/k1_hull.py: the hull vertices are found by an O(n^3) extreme-point test on the
Pareto points ("a Pareto point is a vertex iff it lies strictly below every chord of two Pareto points
that straddle it"), not by gift wrapping or a monotone chain; the notes' own gift-wrapping rule is
implemented literally from the text of Thm 2.1 and compared with it.

All arithmetic is exact (fractions.Fraction); an infinite fit is None.

Tests
  T1  Thm 2.1: vertices = literal gift wrapping; attained at exact length; slopes strictly decreasing;
      polygon = lower boundary of conv(A)+R^2_{>=0} (brute force over points and straddling pairs).
  T2  Thm 2.2(i)-(iv): brute-force argmin of lambda*l+L equals the predicted vertex / closed edge set
      at every breakpoint, between breakpoints, above and below; (iii) unique-on-an-interval <=> vertex.
  T3  Prop 2.3: Phi formula, derivative = MAP length, Fenchel recovery.
  T4  Thm 3.2(a)-(c) at random reference points and windows, for lambda strictly inside, and the
      boundary case lambda = sigma (is strictness needed?).
  T5  Thm 3.2(d): zero-window (sigma, tau)-kinks versus vertices, INCLUDING tau >= sigma.
  T6  Thm 3.4: (1) <=> (2), via the extreme MAP lengths on (tau, sigma) and the extreme kink points.
  T7  Prop 3.5 (universal member) and the length cap claimed after it.
  T8  Cor 3.3 in class form (K := min two-part length of the finite class, kappa = 0).
  T9  Remark 2.5 in class form.
  T10 The remarks after Def 3.1 (window absorption of b_1; converse of the right-kink reformulation).
Deterministic: random.Random(20261013).
"""
import random
from fractions import Fraction as F
from itertools import combinations

R = random.Random(20261013)
COUNT = {}


def bump(k, v=1):
    COUNT[k] = COUNT.get(k, 0) + v


def fin(P):
    return [(l, L) for (l, L) in P if L is not None]


def rho(P, a):
    v = [L for (l, L) in fin(P) if l <= a]
    return min(v) if v else None


def conv_lower(P, a):
    """lower boundary of conv(A)+R^2_{>=0} at abscissa a, by brute force over points and pairs."""
    pts = fin(P)
    best = None
    for (l, L) in pts:
        if l <= a and (best is None or L < best):
            best = L
    for (l1, L1), (l2, L2) in combinations(pts, 2):
        if l1 > l2:
            l1, L1, l2, L2 = l2, L2, l1, L1
        if l1 < a < l2:
            v = L1 + (L2 - L1) * F(a - l1) / (l2 - l1)
            if best is None or v < best:
                best = v
    return best


def pareto(P):
    pts = sorted(set(fin(P)))
    out = []
    for (l, L) in pts:
        if any((l2 <= l and L2 <= L and (l2, L2) != (l, L)) for (l2, L2) in pts):
            continue
        out.append((l, L))
    return sorted(out)


def vertices_extreme(P):
    """independent: Pareto point v is a vertex iff v is strictly below every chord of two Pareto points
    p, q with l_p < l_v < l_q."""
    Q = pareto(P)
    V = []
    for v in Q:
        ok = True
        for p in Q:
            if p[0] >= v[0]:
                continue
            for q in Q:
                if q[0] <= v[0]:
                    continue
                chord = p[1] + (q[1] - p[1]) * F(v[0] - p[0]) / (q[0] - p[0])
                if not v[1] < chord:
                    ok = False
                    break
            if not ok:
                break
        if ok:
            V.append(v)
    return V


def gift_wrap_literal(P):
    """the rule of Thm 2.1 as written in the notes."""
    A = fin(P)
    a0 = min(l for l, _ in A)
    V = [(a0, rho(P, a0))]
    S = []
    while True:
        ai, ri = V[-1]
        right = [(l, L) for (l, L) in A if l > ai]
        if not right:
            break
        s = max((ri - L) / F(l - ai) for (l, L) in right)
        if s <= 0:
            break
        an = max(l for (l, L) in right if (ri - L) / F(l - ai) == s)
        V.append((an, ri - s * (an - ai)))
        S.append(s)
    return V, S


def slopes(V):
    return [(V[i - 1][1] - V[i][1]) / F(V[i][0] - V[i - 1][0]) for i in range(1, len(V))]


def poly(V, a):
    if a < V[0][0]:
        return None
    for (a1, r1), (a2, r2) in zip(V, V[1:]):
        if a1 <= a <= a2:
            return r1 + (r2 - r1) * F(a - a1) / (a2 - a1)
    return V[-1][1]


def J(lam, l, L):
    return lam * l + L


def argmin_pts(P, lam):
    A = fin(P)
    m = min(J(lam, l, L) for (l, L) in A)
    return sorted(i for i, (l, L) in enumerate(P) if L is not None and J(lam, l, L) == m), m


def predicted(P, V, S, lam):
    """Thm 2.2(ii): sigma_0 = inf, sigma_{q+1} = 0."""
    sig = [None] + S + [F(0)]  # sig[i] = sigma_i for i>=1; sig[0] = +inf
    q = len(V) - 1
    for i in range(q + 1):
        hi = sig[i]  # sigma_i (None = inf)
        lo = sig[i + 1]
        if lo < lam and (hi is None or lam < hi):
            return sorted(k for k, (l, L) in enumerate(P) if (l, L) == V[i])
    for i in range(1, q + 1):
        if lam == sig[i]:
            (a1, r1), (a2, r2) = V[i - 1], V[i]
            out = []
            for k, (l, L) in enumerate(P):
                if L is None or not (a1 <= l <= a2):
                    continue
                if L == r1 + (r2 - r1) * F(l - a1) / (a2 - a1):
                    out.append(k)
            return sorted(out)
    raise AssertionError("lambda not classified")


def rand_frac(lo, hi):
    den = R.choice([1, 1, 2, 3, 4, 6])
    return F(R.randint(lo * den, hi * den), den)


def random_set():
    kind = R.random()
    if kind < 0.05:
        return [(R.randint(0, 10), rand_frac(0, 50))]
    n = R.randint(2, 22)
    P = []
    for _ in range(n):
        l = R.randint(0, 20)
        L = None if R.random() < 0.08 else rand_frac(0, 70)
        P.append((l, L))
    if R.random() < 0.3:  # duplicates
        for _ in range(R.randint(1, 4)):
            P.append(R.choice(P))
    if R.random() < 0.5:  # collinear injections on chords of the current hull
        Fp = [p for p in P if p[1] is not None]
        if len(Fp) >= 2:
            V = vertices_extreme(P)
            for (a1, r1), (a2, r2) in zip(V, V[1:]):
                if a2 - a1 >= 2 and R.random() < 0.7:
                    l = R.randint(a1 + 1, a2 - 1)
                    P.append((l, r1 + (r2 - r1) * F(l - a1) / (a2 - a1)))
    if R.random() < 0.1:  # equal fits
        c = rand_frac(0, 30)
        P += [(R.randint(0, 20), c) for _ in range(3)]
    if all(L is None for _, L in P):
        P.append((R.randint(0, 20), rand_frac(0, 50)))
    return P


def test_lams(S):
    lams = set()
    pts = [F(0)] + sorted(S) + [max(S) * 2 + 1 if S else F(5)]
    for s in S:
        lams.add(s)
        for e in (F(1, 10 ** 9), F(1, 1000)):
            if s - e > 0:
                lams.add(s - e)
            lams.add(s + e)
    for a, b in zip(pts, pts[1:]):
        if b > a:
            lams.add((a + b) / 2)
    lams |= {F(1, 10 ** 6), F(1), F(3, 2), F(2), F(10 ** 6)}
    for _ in range(5):
        lams.add(rand_frac(0, 40) + F(1, 7))
    return sorted(x for x in lams if x > 0)


def main():
    nsets = 1500
    examples = {}
    for it in range(nsets):
        P = random_set()
        bump("sets")
        V = vertices_extreme(P)
        Vg, Sg = gift_wrap_literal(P)
        S = slopes(V)
        # ---------------- T1
        assert V == Vg, (P, V, Vg)
        assert S == Sg
        assert all(s > 0 for s in S) and all(S[i] > S[i + 1] for i in range(len(S) - 1))
        for (a, r) in V:
            assert any(l == a and L == r for (l, L) in P) and rho(P, a) == r
        lmax = max(l for l, _ in P)
        for k in range(-2, 2 * lmax + 6):
            a = F(k, 2)
            c = conv_lower(P, a)
            p = poly(V, a)
            assert c == p, (P, a, c, p)
            r = rho(P, a)
            if p is not None:
                assert r is not None and p <= r
        bump("T1_alpha_points", 2 * lmax + 8)
        # ---------------- T2, T3
        lams = test_lams(S)
        prevlen = None
        for lam in lams:
            got, m = argmin_pts(P, lam)
            pr = predicted(P, V, S, lam)
            assert got == pr, (P, lam, got, pr)
            bump("T2_lams")
            if lam in S:
                bump("T2_breakpoints")
                if len(set(P[k] for k in got)) > 2:
                    bump("T2_edges_with_interior_points")
            # Phi
            assert m == min(lam * a + r for (a, r) in V)
            # monotone MAP length
            lens = [P[k][0] for k in got]
            if prevlen is not None:
                assert max(lens) <= prevlen
            prevlen = min(lens)
        # derivative of Phi = MAP length on open intervals
        sig = [None] + S + [F(0)]
        for i in range(len(V)):
            lo, hi = sig[i + 1], sig[i]
            mid = (lo + (hi if hi is not None else lo + 2)) / 2
            h = (mid - lo) / 1000
            if mid - h <= 0:
                continue
            ph = argmin_pts(P, mid + h)[1]
            mh = argmin_pts(P, mid - h)[1]
            assert (ph - mh) / (2 * h) == V[i][0]
            bump("T3_derivative")
        # Fenchel recovery
        for k in range(2 * V[0][0], 2 * lmax + 5):
            a = F(k, 2)
            cand = [argmin_pts(P, lam)[1] - lam * a for lam in lams + [F(1, 10 ** 12)]]
            sup = max(cand)
            target = poly(V, a)
            if a <= V[-1][0]:
                assert sup == target, (P, a, sup, target)
            else:
                assert sup <= target and target - sup <= (a - V[-1][0]) * F(1, 10 ** 6) + F(1, 10 ** 9)
            bump("T3_fenchel")
        # (iii) unique-on-an-interval <=> vertex
        Q = pareto(P)
        for pt in Q:
            uniq = False
            for i in range(len(V)):
                lo, hi = sig[i + 1], sig[i]
                lam = (lo + hi) / 2 if hi is not None else lo + 1
                got, _ = argmin_pts(P, lam)
                if set(P[k] for k in got) == {pt}:
                    uniq = True
            assert uniq == (pt in V)
            bump("T2iii_points")
        # (v) lambda = 0
        Lmin = min(L for _, L in fin(P))
        assert Lmin == V[-1][1] and min(l for (l, L) in fin(P) if L == Lmin) == V[-1][0]
        # ---------------- T4: Thm 3.2(a)-(c)
        A = fin(P)
        for _ in range(6):
            a_ref = R.choice([l for l, _ in A] + [R.randint(0, lmax + 3)])
            r = rho(P, a_ref)
            if r is None:
                continue
            L_ref = r + R.choice([F(0), F(0), F(1, 2), F(3)])
            for w in (F(0), F(1, 2), F(1), F(2), F(37, 10)):
                # left kink: maximal steepness with this window
                sh = [(L - L_ref) / F(a_ref - l) for (l, L) in A if l < a_ref - w]
                sstar = min(sh) if sh else None  # None = vacuous (no constraint)
                if sstar is not None and sstar <= 0:
                    continue
                lam_list = [F(1, 3), F(1), F(3, 2), F(5)]
                if sstar is not None:
                    lam_list = [x for x in lam_list if x < sstar] + [sstar * F(999, 1000), sstar - F(1, 10 ** 9)]
                for lam in lam_list:
                    if lam <= 0:
                        continue
                    got, m = argmin_pts(P, lam)
                    for k in got:
                        l, L = P[k]
                        assert l >= a_ref - w, (P, a_ref, L_ref, w, lam)
                        assert L <= L_ref + lam * (a_ref - l) <= L_ref + lam * w if l <= a_ref else L <= L_ref + lam * (a_ref - l)
                        assert l + L <= a_ref + L_ref + (lam - 1) * (a_ref - l)
                        if lam >= 1:
                            assert l + L <= a_ref + L_ref + (lam - 1) * w
                    bump("T4_left_lams")
                if sstar is not None:
                    got, m = argmin_pts(P, sstar)
                    if any(P[k][0] < a_ref - w for k in got):
                        bump("T4_left_violated_at_lambda_equal_sigma")
                        examples.setdefault("left_eq", (P, a_ref, L_ref, w, sstar))
                # right kink
                th = [(L_ref - L) / F(l - a_ref) for (l, L) in A if l > a_ref + w]
                tstar = max([F(0)] + th)
                for lam in [tstar + F(1, 10 ** 9), tstar * F(1001, 1000) + F(1, 10 ** 6), tstar + 1, tstar + 7]:
                    got, m = argmin_pts(P, lam)
                    for k in got:
                        assert P[k][0] <= a_ref + w
                    bump("T4_right_lams")
                if tstar > 0:
                    got, m = argmin_pts(P, tstar)
                    if any(P[k][0] > a_ref + w for k in got):
                        bump("T4_right_violated_at_lambda_equal_tau")
        # ---------------- T5: zero-window kinks vs vertices
        for a in sorted(set(l for l, _ in A)):
            r = rho(P, a)
            # zero-window left steepness at (a, r): inf over shorter programs; right flatness: sup over longer
            sh = [(L - r) / F(a - l) for (l, L) in A if l < a]
            s0 = min(sh) if sh else None  # None = +inf
            th = [(r - L) / F(l - a) for (l, L) in A if l > a]
            t0 = max([F(0)] + th)
            is_kink_pair = (s0 is None or s0 > 0)  # a zero-window (s0, t0)-kink exists at (a, rho(a))
            if not is_kink_pair:
                continue
            isv = (a, r) in V
            if s0 is None or t0 < s0:
                assert isv, (P, a)
                bump("T5_kink_tau_lt_sigma_is_vertex")
            else:
                # tau >= sigma: Thm 3.2(d) as written (no tau < sigma) would call this a vertex
                bump("T5_zero_window_kink_with_tau_ge_sigma")
                if not isv:
                    bump("T5_counterexample_not_a_vertex")
                    examples.setdefault("T5", (sorted(set(A)), a, r, s0, t0))
        for i, (a, r) in enumerate(V):
            sh = [(L - r) / F(a - l) for (l, L) in A if l < a]
            th = [(r - L) / F(l - a) for (l, L) in A if l > a]
            s0 = min(sh) if sh else None
            t0 = max([F(0)] + th)
            assert (s0 is None and i == 0) or s0 == S[i - 1]
            assert t0 == (S[i] if i < len(S) else 0)
            bump("T5_vertices")
        # ---------------- T6: Thm 3.4
        bps = sorted(set(S))
        for _ in range(8):
            cands = [F(0)] + bps + [rand_frac(0, 30) for _ in range(3)] + [b + F(1, 10 ** 5) for b in bps]
            tau, sigma = sorted(R.sample(cands, 2))
            if R.random() < 0.15:
                sigma = None  # +inf
            if sigma is not None and not tau < sigma:
                continue
            sg = [None] + S + [F(0)]
            q = len(V) - 1
            i_idx = next(i for i in range(q + 1) if sg[i + 1] < (sigma if sigma is not None else 10 ** 30) and (sg[i] is None or (sigma is not None and sigma <= sg[i])))
            j_idx = [j for j in range(q + 1) if sg[j + 1] <= tau and (sg[j] is None or tau < sg[j])]
            # MAP lengths on (tau, sigma)
            upper = sigma if sigma is not None else (max(bps) * 2 + 10 if bps else F(10))
            grid = sorted(set([tau, upper] + [b for b in bps if tau < b < upper]))
            lam_pts = []
            for x, y in zip(grid, grid[1:]):
                lam_pts += [(x + y) / 2, x + (y - x) / 10 ** 6, y - (y - x) / 10 ** 6]
            lam_pts += [b for b in bps if tau < b < upper]
            if sigma is None:
                lam_pts.append(upper * 1000)
            lens = []
            for lam in lam_pts:
                if lam <= 0:
                    continue
                got, _ = argmin_pts(P, lam)
                lens += [P[k][0] for k in got]
            if tau == 0 and not j_idx:
                continue
            assert len(j_idx) == 1
            j_idx = j_idx[0]
            assert min(lens) == V[i_idx][0] and max(lens) == V[j_idx][0], (P, tau, sigma)
            # extreme kink points over all integer and half-integer alphas
            best_minus, best_plus = None, None
            for k in range(0, 2 * lmax + 6):
                a = F(k, 2)
                r = rho(P, a)
                if r is None:
                    continue
                sh = [(L - r) / F(a - l) for (l, L) in A if l < a]
                okL = all(x >= sigma for x in sh) if sigma is not None else (len(sh) == 0)
                th = [(r - L) / F(l - a) for (l, L) in A if l > a]
                okR = all(x <= tau for x in th)
                if okL and (best_minus is None or a > best_minus):
                    best_minus = a
                if okR and (best_plus is None or a < best_plus):
                    best_plus = a
            assert best_minus == V[i_idx][0] and best_plus == V[j_idx][0], (P, tau, sigma, best_minus, best_plus, V)
            bump("T6_cases")
        # ---------------- T7: Prop 3.5 + length cap
        K2 = min(l + L for (l, L) in A)
        for kappa0 in (F(0), F(2), F(13, 2)):
            lU = R.randint(0, 6)
            PU = P + [(lU, K2 + kappa0)]
            AU = fin(PU)
            for a in range(0, lmax + 4):
                r = rho(PU, a)
                if r is None:
                    continue
                for L0 in (r, r + 1):
                    for w in (F(0), F(1), F(5, 2)):
                        if not a - w > lU:
                            continue
                        sh = [(L - L0) / F(a - l) for (l, L) in AU if l < a - w]
                        sstar = min(sh)
                        assert sstar <= F(a + kappa0) / (a - lU), (PU, a, L0, w)
                        bump("T7_kinks")
            for lam in (F(11, 10), F(3, 2), F(2), F(5)):
                got, _ = argmin_pts(PU, lam)
                for k in got:
                    assert PU[k][0] <= lU + (lU + kappa0) / (lam - 1)
                bump("T7_cap")
        # ---------------- T8: Cor 3.3 in class form
        for (l0, L0) in set(A):
            b0 = l0 + L0 - K2
            for lam in (F(11, 10), F(3, 2), F(2), F(4)):
                got, _ = argmin_pts(P, lam)
                for k in got:
                    l, L = P[k]
                    assert l <= l0 + b0 / (lam - 1) and L >= L0 - lam * b0 / (lam - 1)
                bump("T8a")
            for w in (F(0), F(1), F(3)):
                sh = [(L - L0) / F(l0 - l) for (l, L) in A if l < l0 - w]
                sw = min(sh) if sh else None
                if sw is not None and sw <= 1:
                    continue
                lam_list = [F(11, 10), F(3, 2), F(2), F(4), F(9)]
                if sw is not None:
                    lam_list = [x for x in lam_list if x < sw] + [(1 + sw) / 2, sw - F(1, 10 ** 8)]
                for lam in lam_list:
                    if not lam > 1:
                        continue
                    got, _ = argmin_pts(P, lam)
                    for k in got:
                        l, L = P[k]
                        assert l0 - w <= l <= l0 + b0 / (lam - 1)
                        assert L0 - lam * b0 / (lam - 1) <= L <= L0 + lam * w
                        assert l + L - K2 <= b0 + (lam - 1) * w
                    bump("T8b")
        # ---------------- T9: Remark 2.5 (class form)
        for (l1, L1) in set(A):
            b = l1 + L1 - K2
            for k in range(1, 12):
                a = l1 + F(k, 2)
                pa = poly(V, a)
                assert (L1 - pa) <= (a - l1) + b
                bump("T9")
        # ---------------- T10: window absorption remark
        for (a_ref, L_ref) in set(A):
            sh_all = [(l, L) for (l, L) in A if l < a_ref]
            if not sh_all:
                continue
            sig = F(R.randint(1, 8))
            b1 = max([F(0)] + [L_ref + sig * (a_ref - l) - L for (l, L) in sh_all])
            for w in (F(1, 2), F(1), F(3)):
                for (l, L) in sh_all:
                    if l < a_ref - w:
                        assert L >= L_ref + (sig - b1 / w) * (a_ref - l)
                bump("T10")
    print("rB1: exact checks of notes.md Sections 2-3 (referee B)")
    for k in sorted(COUNT):
        print(f"  {k:45s} {COUNT[k]}")
    print("all assertions passed")
    print()
    print("Counterexample to Thm 3.2(d) / Summary item 2 without the hypothesis tau < sigma:")
    if "T5" in examples:
        pts, a, r, s0, t0 = examples["T5"]
        print(f"  first random instance: point (alpha, rho) = ({a}, {r}) has zero-window left steepness {s0}")
        print(f"  and right flatness {t0} >= {s0}, so it is a zero-window ({s0}, {t0})-kink, but it is not a vertex.")
    P = [(0, F(10)), (1, F(5)), (2, F(0))]
    V = vertices_extreme(P)
    print(f"  minimal instance: points {[(l, str(L)) for l, L in P]}; vertices {[(l, str(L)) for l, L in V]};")
    print("  (1, 5) is a zero-window (5, 5)-kink (left secant 5, right secant 5) but lies inside the edge.")
    print("  With tau < sigma required (as the proof uses), the forward direction holds in all tested cases.")
    print()
    print("Strictness in Thm 3.2(a)/(b): at lambda = sigma (resp. tau) exactly, a lambda-MAP can sit outside")
    print(f"  the window: observed {COUNT.get('T4_left_violated_at_lambda_equal_sigma', 0)} times (left) and "
          f"{COUNT.get('T4_right_violated_at_lambda_equal_tau', 0)} times (right); the theorem's strict inequalities are needed.")


if __name__ == "__main__":
    main()
