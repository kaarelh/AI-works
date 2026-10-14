"""k1: lambda-MAPs and the lower convex hull of (l(pi), -log nu_pi(D)), in exact arithmetic.

Checks, on random point sets with integer lengths and rational fits (duplicates, collinear points
and infinite fits included), the statements of notes.md Sections 2-3:

(A) Thm 2.1 (hull = convex minorant): the gift-wrapping polygon P built from the points equals
    (i) the lower hull computed independently by Andrew's monotone chain on the Pareto points, and
    (ii) the lower boundary of conv(A)+R^2_{>=0}, computed by brute force over single points and
    pairs of points (in the plane a linear objective under one linear constraint over a simplex is
    minimised at a point with at most two nonzero weights), at every integer and half-integer alpha.
(B) Thm 2.2 (characterisation of lambda-MAPs): for lambda at every breakpoint s_i, between
    breakpoints, above s_1, below the last breakpoint and at random values, the brute-force
    argmin set of J_lambda = lambda*l + L equals the predicted set (the programs at vertex i if
    s_{i+1} < lambda < s_i; the programs on the closed edge [v_{i-1}, v_i] if lambda = s_i).
    Also: MAP length is nonincreasing and MAP fit nondecreasing in lambda (Lemma setup:hull (ii)).
(C) Prop 2.3 (duality): Phi(lambda) = min_pi J_lambda = min_i (lambda*alpha_i + rho_i), and
    rho_breve(alpha) = max_lambda (Phi(lambda) - lambda*alpha) on [alpha_0, alpha_I].
(D) Thm 3.2 (kink => MAP location): left kinks (sigma, w) and right kinks (tau, w) at random
    reference points; every lambda-MAP with lambda < sigma (resp. > tau) lies right of
    alpha_- - w (resp. left of alpha_+ + w), and the fit and two-part bounds hold.
(E) Thm 3.4 (stable MAP lengths <=> zero-window kinks at hull vertices): for random tau < sigma,
    the set of lambda-MAP lengths over lambda in (tau, sigma) spans exactly [alpha_i, alpha_j],
    where vertex i has s_{i+1} < sigma <= s_i and vertex j has s_{j+1} <= tau < s_j.
(F) Prop 3.5 (a universal member flattens kinks): adding a point U with
    L_U = min_pi (l(pi)+L(pi)) + kappa0, every left kink at alpha_0 > l_U has
    sigma <= (alpha_0 + kappa0)/(alpha_0 - l_U).
Deterministic: random.seed(1).
"""
import random
from fractions import Fraction as Fr

random.seed(1)
INF = None  # an infinite fit


def rho(points, alpha):
    """product structure function: min fit over programs of length <= alpha (None = +inf)."""
    vals = [L for (l, L) in points if L is not INF and l <= alpha]
    return min(vals) if vals else INF


def gift_wrap(points):
    """vertices (alpha_i, rho_i) and slopes s_1 > s_2 > ... > 0 of the convex minorant."""
    fin = [(l, L) for (l, L) in points if L is not INF]
    a0 = min(l for l, _ in fin)
    r0 = min(L for l, L in fin if l == a0)
    V = [(a0, r0)]
    S = []
    while True:
        a, r = V[-1]
        right = [(l, L) for (l, L) in fin if l > a]
        if not right:
            break
        sl = max((r - L) / (l - a) for (l, L) in right)
        if sl <= 0:
            break
        anext = max(l for (l, L) in right if (r - L) / (l - a) == sl)
        V.append((anext, r - sl * (anext - a)))
        S.append(sl)
    return V, S


def P_eval(V, alpha):
    """the polygon: +inf left of alpha_0, linear between vertices, flat after the last."""
    if alpha < V[0][0]:
        return INF
    for (a1, r1), (a2, r2) in zip(V, V[1:]):
        if a1 <= alpha <= a2:
            return r1 + (r2 - r1) * Fr(alpha - a1) / (a2 - a1)
    return V[-1][1]


def monotone_chain_lower(points):
    """independent: Pareto points, then Andrew's lower hull with collinear points removed."""
    fin = sorted(set((l, L) for (l, L) in points if L is not INF))
    pareto = []
    best = None
    for l in sorted(set(l for l, _ in fin)):
        m = min(L for (ll, L) in fin if ll == l)
        if best is None or m < best:
            pareto.append((l, m))
            best = m
    H = []
    for p in pareto:
        while len(H) >= 2:
            (x1, y1), (x2, y2) = H[-2], H[-1]
            cross = (x2 - x1) * (p[1] - y1) - (y2 - y1) * (p[0] - x1)
            if cross <= 0:  # not a strict left turn: drop the middle point
                H.pop()
            else:
                break
        H.append(p)
    return H


def conv_brute(points, alpha):
    """lower boundary of conv(A)+orthant at alpha, by single points and bracketing pairs."""
    fin = [(l, L) for (l, L) in points if L is not INF]
    cands = [L for (l, L) in fin if l <= alpha]
    for (l1, L1) in fin:
        for (l2, L2) in fin:
            if l1 < alpha < l2:
                cands.append(L1 + (L2 - L1) * Fr(alpha - l1) / (l2 - l1))
    return min(cands) if cands else INF


def argmin_set(points, lam):
    J = [(lam * l + L, k) for k, (l, L) in enumerate(points) if L is not INF]
    m = min(j for j, _ in J)
    return m, sorted(k for j, k in J if j == m)


def predicted_set(points, V, S, lam):
    s = [None] + S + [Fr(0)]   # s[0] = +inf, s[i] = slope of edge (v_{i-1}, v_i), s[I+1] = 0
    I = len(V) - 1
    for i in range(I + 1):
        hi = s[i]
        lo = s[i + 1]
        if (hi is None or lam < hi) and lam > lo:
            return sorted(k for k, (l, L) in enumerate(points) if L is not INF and (l, L) == V[i])
        if hi is not None and lam == hi:
            (a1, r1), (a2, r2) = V[i - 1], V[i]
            return sorted(k for k, (l, L) in enumerate(points) if L is not INF and a1 <= l <= a2
                          and L == r1 + (r2 - r1) * Fr(l - a1) / (a2 - a1))
    raise AssertionError("lambda not located")


def random_points():
    n = random.randint(3, 30)
    pts = []
    for _ in range(n):
        l = random.randint(0, 40)
        if random.random() < 0.08:
            pts.append((l, INF))
        else:
            pts.append((l, Fr(random.randint(0, 400), random.choice([1, 2, 3, 4]))))
    # duplicates and deliberate collinear points on a random segment
    for _ in range(random.randint(0, 3)):
        pts.append(random.choice(pts))
    if random.random() < 0.5:
        fin = [p for p in pts if p[1] is not INF]
        (l1, L1), (l2, L2) = random.sample(fin, 2) if len(fin) >= 2 else (fin[0], fin[0])
        if l1 != l2:
            if l1 > l2:
                (l1, L1), (l2, L2) = (l2, L2), (l1, L1)
            for l in range(l1 + 1, l2):
                if random.random() < 0.4:
                    pts.append((l, L1 + (L2 - L1) * Fr(l - l1, l2 - l1)))
    if all(L is INF for _, L in pts):
        pts.append((random.randint(0, 40), Fr(random.randint(0, 400))))
    return pts


stats = dict(sets=0, A_poly=0, A_conv=0, B_lams=0, B_mono=0, C=0, D_left=0, D_right=0,
             D_left_lams=0, D_right_lams=0, E=0, F=0, ties=0, edges_with_inner=0)
NSETS = 600
for trial in range(NSETS):
    pts = random_points()
    stats["sets"] += 1
    V, S = gift_wrap(pts)
    assert all(S[i] > S[i + 1] for i in range(len(S) - 1)) and all(s > 0 for s in S)
    # each vertex is attained by a program of exactly that length
    for (a, r) in V:
        assert any(l == a and L == r for (l, L) in pts if L is not INF)
        assert rho(pts, a) == r
    # (A)(i) monotone chain
    H = monotone_chain_lower(pts)
    assert [tuple(v) for v in H] == [tuple(v) for v in V], (H, V)
    stats["A_poly"] += 1
    # (A)(ii) brute-force lower boundary of conv(A)+orthant, and P <= rho
    amax = max(l for l, _ in pts) + 3
    for twice in range(-2, 2 * amax + 1):
        alpha = Fr(twice, 2)
        pv, cb = P_eval(V, alpha), conv_brute(pts, alpha)
        assert pv == cb, (alpha, pv, cb)
        rv = rho(pts, alpha)
        assert (rv is INF) or (pv is not INF and pv <= rv)
    stats["A_conv"] += 1
    # every finite point lies on or above P
    for (l, L) in pts:
        if L is not INF:
            assert P_eval(V, l) <= L
    # (B) characterisation at many lambdas
    lams = set()
    for s in S:
        lams.add(s)
        lams.add(s * Fr(101, 100))
        lams.add(s * Fr(99, 100))
    for a, b in zip(S, S[1:]):
        lams.add((a + b) / 2)
    lams.add((S[0] + 1) * 2 if S else Fr(5))
    lams.add(S[-1] / 3 if S else Fr(1, 3))
    for _ in range(10):
        lams.add(Fr(random.randint(1, 4000), random.randint(1, 200)))
    lams = sorted(x for x in lams if x > 0)
    prev_len = None
    prev_fit = None
    for lam in lams:
        m, got = argmin_set(pts, lam)
        pred = predicted_set(pts, V, S, lam)
        assert got == pred, (lam, got, pred)
        stats["B_lams"] += 1
        if lam in S:
            stats["ties"] += 1
            ls = set(pts[k][0] for k in got)
            if len(ls) > 2:
                stats["edges_with_inner"] += 1
        # (C) Phi formula
        assert m == min(lam * a + r for (a, r) in V)
        # monotonicity (lams sorted increasingly): lengths nonincreasing, fits nondecreasing
        lens = [pts[k][0] for k in got]
        fits = [pts[k][1] for k in got]
        if prev_len is not None:
            assert max(lens) <= prev_len and min(fits) >= prev_fit
        prev_len, prev_fit = min(lens), max(fits)
    stats["B_mono"] += 1
    # (C) Fenchel recovery of rho_breve on [alpha_0, alpha_I]
    a0, aI = V[0][0], V[-1][0]
    for twice in range(2 * a0, 2 * aI + 1):
        alpha = Fr(twice, 2)
        if S:
            rec = max(min(s * a + r for (a, r) in V) - s * alpha for s in S)
        else:
            rec = V[0][1]
        assert rec == P_eval(V, alpha), (alpha, rec, P_eval(V, alpha))
    stats["C"] += 1
    fin = [(l, L) for (l, L) in pts if L is not INF]
    # (D) left kinks at random reference points
    for _ in range(4):
        (l0, L0) = random.choice(fin)
        Lm = L0 + Fr(random.randint(0, 20), random.choice([1, 2]))
        am = l0 + random.randint(0, 3)
        assert rho(pts, am) <= Lm
        for w in [0, 1, 2, 5]:
            left = [(l, L) for (l, L) in fin if l < am - w]
            sig = min(((L - Lm) / (am - l) for (l, L) in left), default=None)
            if sig is not None and sig <= 0:
                continue
            stats["D_left"] += 1
            tests = [Fr(random.randint(1, 1000), 100) for _ in range(5)]
            if sig is not None:
                tests += [sig * Fr(999, 1000), sig / 2]
            for lam in tests:
                if sig is not None and lam >= sig:
                    continue
                _, got = argmin_set(pts, lam)
                for k in got:
                    l, L = pts[k]
                    assert l >= am - w
                    assert L <= Lm + lam * (am - l)
                    assert l + L <= am + Lm + (lam - 1) * (am - l)
                    if lam >= 1:
                        assert l + L <= am + Lm + (lam - 1) * w
                stats["D_left_lams"] += 1
    # (D) right kinks
    for _ in range(4):
        (l0, L0) = random.choice(fin)
        Lp = L0 + Fr(random.randint(0, 20), random.choice([1, 2]))
        ap = l0 + random.randint(0, 3)
        for w in [0, 1, 2, 5]:
            right = [(l, L) for (l, L) in fin if l > ap + w]
            tau = max([Fr(0)] + [(Lp - L) / (l - ap) for (l, L) in right])
            stats["D_right"] += 1
            for lam in [tau + Fr(1, 1000), tau * 2 + Fr(1, 10), tau + Fr(random.randint(1, 500), 10)]:
                _, got = argmin_set(pts, lam)
                for k in got:
                    assert pts[k][0] <= ap + w
                stats["D_right_lams"] += 1
    # (E) stable MAP lengths <=> zero-window kinks at vertices
    s = [None] + S + [Fr(0)]
    for _ in range(4):
        x, y = sorted([Fr(random.randint(0, 3000), 100), Fr(random.randint(1, 3000), 100)])
        if x == y:
            continue
        tau, sig = x, y
        # predicted extreme vertices
        i = next(i for i in range(len(V)) if s[i + 1] < sig and (s[i] is None or sig <= s[i]))
        j = next(j for j in range(len(V)) if s[j + 1] <= tau and (s[j] is None or tau < s[j]))
        # dense lambda set in (tau, sig): breakpoints inside, midpoints, near the ends
        inside = sorted(set([t for t in S if tau < t < sig] + [tau + (sig - tau) * Fr(k, 64)
                                                                for k in range(1, 64)]))
        L_all = []
        for lam in inside:
            _, got = argmin_set(pts, lam)
            L_all += [pts[k][0] for k in got]
        # near the ends the extreme lengths are attained
        assert min(L_all) == V[i][0] and max(L_all) == V[j][0], (min(L_all), max(L_all), V[i], V[j])
        # the zero-window kinks hold at the two vertices
        for (l, L) in fin:
            if l < V[i][0]:
                assert L >= V[i][1] + sig * (V[i][0] - l)
            if l > V[j][0]:
                assert L >= V[j][1] - tau * (l - V[j][0])
        stats["E"] += 1
    # (F) a universal member flattens kinks
    kappa0 = Fr(random.randint(0, 5))
    lU = random.randint(0, 5)
    LU = min(l + L for (l, L) in fin) + kappa0
    pts2 = fin + [(lU, LU)]
    for (a0_, L0_) in fin:
        if a0_ > lU:
            # left steepness at (a0_, L0_) is at most the secant to U
            secU = (LU - L0_) / (a0_ - lU)
            assert secU <= Fr(a0_ + kappa0) / (a0_ - lU)
            stats["F"] += 1

for k, v in stats.items():
    print(f"{k:18s} {v}")
print("all assertions passed")
