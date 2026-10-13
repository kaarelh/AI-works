"""v1: independent check of kink/notes-final.md, Remark 3.2', Thm 3.2 (as used by Remark 3.2'),
Prop 3.5(ii) and the deterministic step of Cor 5.7(d).

Written for the verification `../../verify-kink.md`; shares no code with checks/k1-k8 or referee_code/.

Objects.  A "class" is a finite list of programs, each a point (l, F) with integer l >= 0 and F a
nonnegative Fraction or INF (several programs may share a point).  rho(a) = min{F : l <= a}.
J_lam(pi) = lam*l + F.  The lambda-MAPs are the exact argmin (Fractions throughout).

Vertex test (independent of every slope characterisation in the record): a finite point P is a vertex of
the lower boundary of conv(A) + R^2_{>=0} iff P is an extreme point of that set, iff no point q of
conv(A without the location P) satisfies q <= P componentwise.  Pareto-minimal points of a planar polytope
lie on segments between two of its points, so it suffices to test single points and pairs (an exact 1-D
feasibility problem in the mixing weight t).

Seeded: random.Random(5172).  Python 3.11, exact arithmetic (fractions.Fraction).
"""
import random
from fractions import Fraction as Fr

R = random.Random(5172)
INF = float("inf")  # infinite fit or infinite steepness (compared with ==)


def finite(pts):
    return [(l, f) for (l, f) in pts if f != INF]


def J(lam, P):
    return lam * P[0] + P[1]


def maps(pts, lam):
    """exact set of lambda-MAP programs (indices) over programs with finite fit."""
    fin = [(i, P) for i, P in enumerate(pts) if P[1] != INF]
    m = min(J(lam, P) for _, P in fin)
    return [i for i, P in fin if J(lam, P) == m]


def dominated_by_mix(P, Q1, Q2):
    """is there t in [0,1] with t*Q1 + (1-t)*Q2 <= P componentwise?"""
    lo, hi = Fr(0), Fr(1)
    for k in range(2):
        a, b, c = Fr(Q1[k]), Fr(Q2[k]), Fr(P[k])          # exact (lengths are ints)
        # t*a + (1-t)*b <= c  <=>  t*(a-b) <= c-b
        if a == b:
            if b > c:
                return False
        elif a > b:
            hi = min(hi, (c - b) / (a - b))
        else:
            lo = max(lo, (c - b) / (a - b))
    return lo <= hi


def is_extreme(pts, P):
    others = [Q for Q in set(finite(pts)) if Q != P]
    for Q in others:
        if Q[0] <= P[0] and Q[1] <= P[1]:
            return False
    for i in range(len(others)):
        for j in range(i + 1, len(others)):
            if dominated_by_mix(P, others[i], others[j]):
                return False
    return True


def rho(pts, a):
    fs = [f for l, f in finite(pts) if l <= a]
    return min(fs) if fs else INF


def left_kink_ok(pts, alpha, Fk, sigma, w):
    """Def 3.1, literally: rho(alpha) <= Fk and every program shorter than alpha - w has
    F >= Fk + sigma*(alpha - l) (sigma = INF: no such program has finite fit)."""
    r = rho(pts, alpha)
    if r == INF or r > Fk:
        return False
    for l, f in pts:
        if l < alpha - w:
            if sigma == INF:
                if f != INF:
                    return False
            elif f != INF and f < Fk + sigma * (alpha - l):
                return False
    return True


def right_kink_ok(pts, alpha, Fk, tau, w):
    r = rho(pts, alpha)
    if r == INF or r > Fk:
        return False
    for l, f in pts:
        if l > alpha + w and f != INF and f < Fk - tau * (l - alpha):
            return False
    return True


def best_sigma(pts, alpha, Fk, w):
    """largest sigma (possibly INF) for which a left kink (sigma, w) at (alpha, Fk) holds; None if none > 0."""
    sl = [(f - Fk) / (alpha - l) for l, f in finite(pts) if l < alpha - w]
    if not sl:
        return INF
    s = min(sl)
    return s if s > 0 else None


def best_tau(pts, alpha, Fk, w):
    sl = [(Fk - f) / (l - alpha) for l, f in finite(pts) if l > alpha + w]
    return max([Fr(0)] + sl)


def rand_pts(k, lmax=20, fmax=300, p_inf=0.0, p_dup=0.15, p_col=0.25):
    pts = [(R.randint(0, lmax), Fr(R.randint(0, fmax), R.randint(1, 5))) for _ in range(k)]
    if R.random() < p_col and len(pts) >= 2:          # a collinear interior point on a random segment
        (l1, f1), (l2, f2) = sorted(R.sample(pts, 2))
        if l2 >= l1 + 2:
            lm = R.randint(l1 + 1, l2 - 1)
            pts.append((lm, f1 + (f2 - f1) * Fr(lm - l1, l2 - l1)))
    if R.random() < p_dup:                            # duplicate programs at one point
        pts.append(R.choice(pts))
    if p_inf and R.random() < p_inf:
        pts.append((R.randint(0, lmax), INF))
    return pts


def rationals_between(a, b, k=3):
    """k rationals strictly inside (a, b); b may be INF."""
    if b == INF:
        return [a + Fr(i, 2) for i in range(1, k + 1)] + [a + 1000]
    return [a + (b - a) * Fr(i, k + 1) for i in range(1, k + 1)]


out = []


def say(s=""):
    print(s)


say("=" * 100)
say("(A) Remark 3.2': the three-point example (0,10), (1,5), (2,0)")
pts = [(0, Fr(10)), (1, Fr(5)), (2, Fr(0))]
say(f"  zero-window left kink of steepness 5 at (1,5): {left_kink_ok(pts, 1, Fr(5), Fr(5), 0)}; "
    f"steepness 5+1/1000: {left_kink_ok(pts, 1, Fr(5), Fr(5) + Fr(1, 1000), 0)}")
say(f"  zero-window right kink of flatness 5 at (1,5): {right_kink_ok(pts, 1, Fr(5), Fr(5), 0)}; "
    f"flatness 5-1/1000: {right_kink_ok(pts, 1, Fr(5), Fr(5) - Fr(1, 1000), 0)}")
say(f"  (1,5) extreme point of conv + R^2_+ (i.e. a hull vertex): {is_extreme(pts, (1, Fr(5)))}; "
    f"(0,10): {is_extreme(pts, (0, Fr(10)))}; (2,0): {is_extreme(pts, (2, Fr(0)))}")
for lam in [Fr(4), Fr(9, 2), Fr(5), Fr(11, 2), Fr(6)]:
    say(f"  lambda = {str(lam):>4}: MAP points {[pts[i] for i in maps(pts, lam)]}")
assert left_kink_ok(pts, 1, Fr(5), Fr(5), 0) and right_kink_ok(pts, 1, Fr(5), Fr(5), 0)
assert not is_extreme(pts, (1, Fr(5)))
assert sorted(maps(pts, Fr(5))) == [0, 1, 2]

say("  strictness, explicit: left kink (5, w=0) at (2,0) of {(0,10),(2,0)}: MAP set at lambda = 5 is "
    f"{[[(0, Fr(10)), (2, Fr(0))][i] for i in maps([(0, Fr(10)), (2, Fr(0))], Fr(5))]} (a MAP of length 0 < 2)")
say("  strictness, explicit: right kink (5, w=0) at (0,10) of the same set: MAP set at lambda = 5 contains (2,0), "
    "length 2 > 0")
assert left_kink_ok([(0, Fr(10)), (2, Fr(0))], 2, Fr(0), Fr(5), 0)
assert right_kink_ok([(0, Fr(10)), (2, Fr(0))], 0, Fr(10), Fr(5), 0)

say("=" * 100)
say("(B) Thm 3.2(a)-(d) on random classes, windows included (exact); the counts behind Remark 3.2'")
cnt = dict(left=0, right=0, both=0, zero_lt=0, zero_lt_vertex=0, zero_eq=0, zero_eq_vertex=0,
           strict_left=0, strict_right=0, conv=0, conv_ok=0, two_part=0)
for s in range(1500):
    pts = rand_pts(R.randint(2, 12), p_inf=0.3, p_col=0.7)
    fin = finite(pts)
    if not fin:
        continue
    lens = sorted({l for l, _ in fin})
    for _ in range(4):
        alpha = R.choice(lens + [R.randint(0, 22)])
        r = rho(pts, alpha)
        if r == INF:
            continue
        Fk = r + (0 if R.random() < 0.6 else Fr(R.randint(0, 20), R.randint(1, 3)))
        w = 0 if R.random() < 0.5 else R.randint(1, 4)
        sig = best_sigma(pts, alpha, Fk, w)
        tau = best_tau(pts, alpha, Fk, w)
        if sig is not None:
            assert left_kink_ok(pts, alpha, Fk, sig, w)
            cnt["left"] += 1
            lam_list = rationals_between(Fr(0), sig) + ([Fr(1)] if (sig == INF or sig > 1) else [])
            for lam in lam_list:
                for i in maps(pts, lam):
                    l, f = pts[i]
                    assert l >= alpha - w, ("Thm 3.2(a) length", pts, alpha, Fk, sig, w, lam)
                    assert f <= Fk + lam * (alpha - l) and f <= Fk + lam * w, "Thm 3.2(a) fit"
                    if lam >= 1:
                        assert l + f <= alpha + Fk + (lam - 1) * w, "Thm 3.2(a) two-part"
                        cnt["two_part"] += 1
            if sig != INF and any(pts[i][0] < alpha - w for i in maps(pts, sig)):
                cnt["strict_left"] += 1
        assert right_kink_ok(pts, alpha, Fk, tau, w)
        cnt["right"] += 1
        for lam in [tau + Fr(1, 7), tau + 1, tau + 10]:
            for i in maps(pts, lam):
                assert pts[i][0] <= alpha + w, ("Thm 3.2(b)", pts, alpha, Fk, tau, w, lam)
        if tau > 0 and any(pts[i][0] > alpha + w for i in maps(pts, tau)):
            cnt["strict_right"] += 1
        if w == 0 and sig is not None:
            cnt["both"] += 1
            P = (alpha, rho(pts, alpha))
            if sig == INF or tau < sig:
                cnt["zero_lt"] += 1
                # rho(alpha) attained at length exactly alpha; vertex; MAPs on (tau, sig) are the programs at P
                assert any(l == alpha and f == P[1] for l, f in fin), "Thm 3.2(d): attained at alpha"
                assert is_extreme(pts, P), ("Thm 3.2(d): vertex", pts, alpha, Fk)
                cnt["zero_lt_vertex"] += 1
                atP = sorted(i for i, Q in enumerate(pts) if Q == P)
                for lam in rationals_between(tau, sig):
                    assert sorted(maps(pts, lam)) == atP, "Thm 3.2(d): MAPs are the programs at the vertex"
            elif tau == sig and Fk == P[1]:
                cnt["zero_eq"] += 1
                cnt["zero_eq_vertex"] += is_extreme(pts, P)
    # converse of (d): every vertex is a zero-window (sigma_i, sigma_{i+1})-kink with sigma_{i+1} < sigma_i
    for P in set(fin):
        if is_extreme(pts, P):
            cnt["conv"] += 1
            sig = best_sigma(pts, P[0], P[1], 0)
            tau = best_tau(pts, P[0], P[1], 0)
            if sig is not None and (sig == INF or tau < sig):
                cnt["conv_ok"] += 1
say(f"  left kinks tested: {cnt['left']} (two-part bound checked {cnt['two_part']} times); right kinks: {cnt['right']}; "
    "no violation of (a), (b) (asserted)")
say(f"  zero-window kinks with tau < sigma: {cnt['zero_lt']}, all vertices with the MAP set as stated (asserted)")
say(f"  zero-window kinks at (alpha, rho(alpha)) with tau = sigma (best constants): {cnt['zero_eq']}, "
    f"of which vertices: {cnt['zero_eq_vertex']}")
say(f"  at lambda = sigma a MAP lies left of alpha - w in {cnt['strict_left']} cases; "
    f"at lambda = tau a MAP lies right of alpha + w in {cnt['strict_right']} cases")
say(f"  vertices: {cnt['conv']}; zero-window kinks with tau < sigma there: {cnt['conv_ok']} (converse of (d))")
assert cnt["zero_eq_vertex"] == 0 and cnt["conv"] == cnt["conv_ok"]

say("=" * 100)
say("(C) Prop 3.5(ii): a universal member U (F_U <= F + l + kappa0 for every program) caps every lambda-MAP")
n_cases = n_viol = n_tight = n_iff = 0
for s in range(4000):
    pts = rand_pts(R.randint(1, 10), lmax=30, p_col=0.0)
    lU = R.randint(0, 8)
    kappa0 = Fr(R.randint(0, 6), R.randint(1, 2))
    FU = min(f + l for l, f in pts) + kappa0 - Fr(R.randint(0, 4))
    FU = max(FU, Fr(0))
    # (Dom) on this data set, including U itself: F_U <= F_U + l_U + kappa0 holds since l_U + kappa0 >= 0
    allpts = pts + [(lU, FU)]
    assert all(FU <= f + l + kappa0 for l, f in allpts)
    if R.random() < 0.3:                                  # a tight competitor: equality in (Dom)
        L = R.randint(lU + 1, lU + 40)
        allpts.append((L, FU - L - kappa0)) if FU - L - kappa0 >= 0 else None
    for lam in [Fr(R.randint(101, 400), 100) for _ in range(4)] + [Fr(3, 2), Fr(2), Fr(11, 10)]:
        bound = (lam * lU + kappa0) / (lam - 1)
        assert bound == lU + (lU + kappa0) / (lam - 1)
        Lmax = max(allpts[i][0] for i in maps(allpts, lam))
        n_cases += 1
        if Lmax > bound:
            n_viol += 1
        if Lmax == bound:
            n_tight += 1
        for eps in [Fr(1, 2), Fr(1), Fr(3)]:
            lhs = bound <= lU + (lU + kappa0) / eps
            if lU + kappa0 > 0:
                n_iff += 1
                assert lhs == (lam >= 1 + eps)
say(f"  {n_cases} (class, lambda) cases: violations of l(MAP) <= (lambda l_U + kappa0)/(lambda - 1): {n_viol} "
    f"(0 required); bound attained with equality in {n_tight} cases")
say(f"  'at most l_U + (l_U+kappa0)/eps exactly when lambda >= 1 + eps': checked in {n_iff} cases with l_U + kappa0 > 0")
# degenerate case l_U + kappa0 = 0: the 'exactly when' clause fails
lU, kappa0 = 0, Fr(0)
say(f"  degenerate case l_U = kappa0 = 0: the bound is {lU} for every lambda > 1, so 'at most l_U + 0/eps' holds also "
    f"for lambda < 1 + eps; the 'exactly when' clause needs l_U + kappa0 > 0")
# sharpness: U=(l_U,F_U), A=(L, F_U - L - kappa0) with L = (lambda l_U + kappa0)/(lambda - 1) an integer
lU, kappa0, lam = 3, Fr(1), Fr(2)
L = int((lam * lU + kappa0) / (lam - 1))
pts = [(lU, Fr(100)), (L, Fr(100) - L - kappa0)]
say(f"  sharpness: l_U=3, kappa0=1, lambda=2: bound 7; class {{(3,100), (7,92)}} satisfies (Dom); MAP points "
    f"{[pts[i] for i in maps(pts, lam)]}")
assert n_viol == 0

say("=" * 100)
say("(D) Cor 5.7(d), deterministic step: if the lambda-MAPs occupy a single point, it is a vertex v_i with")
say("    sigma_{i+1} < lambda < sigma_i; its largest right secant (floored at 0) equals the next edge slope")
n_single = n_ok = n_lam1 = 0
for s in range(4000):
    pts = rand_pts(R.randint(1, 12), p_inf=0.2)
    fin = finite(pts)
    if not fin:
        continue
    verts = sorted(P for P in set(fin) if is_extreme(pts, P))
    # edge slopes from the vertex list: sigma_i = (rho_{i-1} - rho_i)/(a_i - a_{i-1}); sigma_0 = INF; last next = 0
    slopes = {}
    for k, P in enumerate(verts):
        left = INF if k == 0 else (verts[k - 1][1] - P[1]) / (P[0] - verts[k - 1][0])
        right = Fr(0) if k == len(verts) - 1 else (P[1] - verts[k + 1][1]) / (verts[k + 1][0] - P[0])
        slopes[P] = (left, right)
    for lam in [Fr(1)] + [Fr(R.randint(1, 600), R.randint(1, 60)) for _ in range(3)]:
        M = maps(pts, lam)
        locs = {pts[i] for i in M}
        if len(locs) != 1:
            continue
        n_single += 1
        n_lam1 += lam == 1
        P = locs.pop()
        sl, sr = slopes.get(P, (None, None))
        s_minus = min([(f - P[1]) / (P[0] - l) for l, f in fin if l < P[0]], default=INF)
        s_plus = max([Fr(0)] + [(P[1] - f) / (l - P[0]) for l, f in fin if l > P[0]])
        ok = (P in slopes and s_plus == sr and sr < lam and (sl == INF or lam < sl)
              and (s_minus == INF or (sl != INF and s_minus >= sl)))
        n_ok += ok
        assert ok, (pts, lam, P)
say(f"  {n_single} (class, lambda) cases with a single MAP point ({n_lam1} at lambda = 1): all vertices with "
    f"s_+ = sigma_(i+1) < lambda < sigma_i <= s_- (asserted): {n_ok}")
