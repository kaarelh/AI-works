"""k8: the smaller corrections of notes-final.md, Sections 3-5 (after referee-A.md issues 2, 3 and
referee-B.md issues 2, 3, 5).

(A) Thm 3.2(d) needs tau < sigma.  On random point sets (exact Fractions): at every attained point P, the
    zero-window left steepness sigma(P) (min left secant; +inf if no shorter point) and right flatness
    tau(P) (max(0, max right secant)).  P is a zero-window (sigma', tau')-kink iff sigma' <= sigma(P) and
    tau' >= tau(P).  Claim: P is a hull vertex iff tau(P) < sigma(P); collinear interior points have
    tau(P) = sigma(P) and are not vertices.  Also: at lambda = sigma(P) exactly a lambda-MAP may lie to the
    left of P (the strict inequality lambda < sigma in Thm 3.2(a) is needed).
(B) The cap after Prop 3.5.  Random point sets with a universal member U (F_U <= F + l + kappa0 for all
    points): every lambda-MAP has l <= (lambda l_U + kappa0)/(lambda - 1) for every lambda > 1 (the absorption
    bound); the cap l_U + (l_U + kappa0)/eps holds for lambda >= 1 + eps and can fail for lambda in (1, 1+eps).
(C) The lambda = 1 corollary (Cor 5.7(d)): whenever the 1-MAP point is unique, it is a vertex whose right
    slope is < 1 < its left steepness (Thm 2.2 read at lambda = 1).
(D) Set models on the full table of a noisy random parity: how the code for v decides the set hull near
    alpha = d (referee B issue 5).  Sets: all strings; A_v (parities agreeing with a on the first d-v
    coordinates, plus pN flips) for v = 0..d; partial memoriser sets.  Two prefix codes for v: fixed
    ceil(log2(d+1)) bits (as k2) and Elias gamma(v+1).  Reported: the lambda-range on which the
    parity-knowing set A_{v=0} is the set lambda-MAP, and Prop 4.4's class-form bound.
Seeded: random.Random(8).  Python 3.11.
"""
import math
import random
from fractions import Fraction as Fr

R = random.Random(8)


def lower_hull(pts):
    """vertices of the lower-left hull of conv(pts) + R^2_{>=0} (pts: list of (l, F) with finite F)."""
    pts = sorted(set(pts))
    # keep for each length the least fit, and only points strictly below all shorter ones
    best = {}
    for l, f in pts:
        if l not in best or f < best[l]:
            best[l] = f
    cand, cur = [], None
    for l in sorted(best):
        if cur is None or best[l] < cur:
            cand.append((l, best[l]))
            cur = best[l]
    hull = []
    for P in cand:
        while len(hull) >= 2:
            (x1, y1), (x2, y2) = hull[-2], hull[-1]
            # remove hull[-1] if it lies on or above the segment hull[-2] -> P
            if (y2 - y1) * (P[0] - x1) >= (P[1] - y1) * (x2 - x1):
                hull.pop()
            else:
                break
        hull.append(P)
    return hull


def map_points(pts, lam):
    J = [lam * l + f for l, f in pts]
    m = min(J)
    return sorted({pts[i] for i in range(len(pts)) if J[i] == m})


print("=" * 100)
print("(A) zero-window kinks and hull vertices (exact)")
n_vertex_ok = n_nonvertex_eq = n_lt_not_vertex = n_strict = 0
n_sets = 1200
minimal = [(0, Fr(10)), (1, Fr(5)), (2, Fr(0))]
for s in range(n_sets):
    k = R.randint(2, 14)
    pts = [(R.randint(0, 25), Fr(R.randint(0, 400), R.randint(1, 4))) for _ in range(k)]
    if s % 5 == 0:                                         # add collinear points on a random segment
        (l1, f1), (l2, f2) = sorted(R.sample(pts, 2))
        if l2 > l1 + 1:
            lm = R.randint(l1 + 1, l2 - 1)
            pts.append((lm, f1 + (f2 - f1) * Fr(lm - l1, l2 - l1)))
    if s == 0:
        pts = minimal
    pts = sorted(set(pts))
    hull = set(lower_hull(pts))
    for P in pts:
        l0, f0 = P
        if any(l <= l0 and f < f0 for l, f in pts if (l, f) != P) or any(l < l0 and f <= f0 for l, f in pts):
            continue                                        # not the structure-function point at l0
        left = [(f - f0) / (l0 - l) for l, f in pts if l < l0]
        right = [(f0 - f) / (l - l0) for l, f in pts if l > l0]
        sig = min(left) if left else math.inf
        tau = max([Fr(0)] + right)
        if tau < sig:
            n_vertex_ok += P in hull
            n_lt_not_vertex += P not in hull
            # strictness: at lambda = sigma (finite), is some MAP to the left of P?
            if sig != math.inf and any(l < l0 for l, f in map_points(pts, sig)):
                n_strict += 1
        elif tau == sig and sig != math.inf:
            n_nonvertex_eq += P not in hull
            assert P not in hull
print(f"  {n_sets} point sets: zero-window kinks with tau < sigma: {n_vertex_ok} are vertices, {n_lt_not_vertex} are not (0 required)")
print(f"  zero-window kinks with tau = sigma (collinear interior points): {n_nonvertex_eq}, none a vertex")
print(f"  minimal instance {[(l, str(f)) for l, f in minimal]}: (1, 5) has sigma = tau = 5 and is not a vertex")
print(f"  at lambda = sigma exactly, a lambda-MAP lies left of the kink point in {n_strict} cases (strict lambda < sigma needed)")
assert n_lt_not_vertex == 0

print("=" * 100)
print("(B) the cap after Prop 3.5 (exact)")
viol_abs = viol_eps_hi = viol_eps_lo = checks = 0
example = None
for s in range(3000):
    k = R.randint(2, 12)
    pts = [(R.randint(0, 30), Fr(R.randint(0, 300), R.randint(1, 3))) for _ in range(k)]
    lU = R.randint(0, 10)
    kappa0 = R.randint(0, 4)
    FU = min(f + l for l, f in pts) + kappa0             # (Dom): F_U <= F + l + kappa0 for every point
    FU = FU - Fr(R.randint(0, 3))                         # possibly a better U
    FU = max(FU, Fr(0))
    pts.append((lU, FU))
    for eps_ in [Fr(1, 2), Fr(1), Fr(2)]:
        for lam in [Fr(11, 10), Fr(5, 4), Fr(3, 2), Fr(2), Fr(3), Fr(5)]:
            maps = map_points(pts, lam)
            Lmax = max(l for l, f in maps)
            checks += 1
            if Lmax > (lam * lU + kappa0) / (lam - 1):
                viol_abs += 1
            cap = lU + (lU + kappa0) / eps_
            if lam >= 1 + eps_ and Lmax > cap:
                viol_eps_hi += 1
            if lam < 1 + eps_ and Lmax > cap:
                viol_eps_lo += 1
                if example is None:
                    example = (lU, FU, kappa0, eps_, lam, maps)
print(f"  {checks} (point set, U, kappa0, eps, lambda) cases")
print(f"  absorption bound l <= (lambda l_U + kappa0)/(lambda - 1): violations {viol_abs} (0 required)")
print(f"  cap l_U + (l_U + kappa0)/eps for lambda >= 1 + eps: violations {viol_eps_hi} (0 required)")
print(f"  the same cap for lambda in (1, 1 + eps): violated in {viol_eps_lo} cases; first: l_U={example[0]}, kappa0={example[2]}, "
      f"eps={example[3]}, lambda={example[4]}, MAP points {[(l, str(f)) for l, f in example[5]]}")
assert viol_abs == 0 and viol_eps_hi == 0
# referee A's instance
pts = [(2, Fr(15)), (5, Fr(10))]
print(f"  referee A's instance U=(2,15), A=(5,10), kappa0=0, eps=1: lambda=3/2 MAP points {map_points(pts, Fr(3, 2))}; "
      f"cap l_U+(l_U+kappa0)/eps = 4; absorption bound (lambda l_U + kappa0)/(lambda-1) = 6")

print("=" * 100)
print("(C) a unique 1-MAP point is a vertex with right slope < 1 < left steepness (exact)")
n_unique = n_ok = 0
for s in range(3000):
    k = R.randint(1, 14)
    pts = sorted(set((R.randint(0, 25), Fr(R.randint(0, 200), R.randint(1, 3))) for _ in range(k)))
    maps = map_points(pts, Fr(1))
    if len(maps) != 1:
        continue
    n_unique += 1
    l0, f0 = maps[0]
    left = [(f - f0) / (l0 - l) for l, f in pts if l < l0]
    right = [(f0 - f) / (l - l0) for l, f in pts if l > l0]
    sig = min(left) if left else math.inf
    tau = max([Fr(0)] + right)
    n_ok += (maps[0] in set(lower_hull(pts))) and tau < 1 < sig
print(f"  {n_unique} point sets with a unique 1-MAP point; vertex with tau < 1 < sigma in {n_ok} (all required)")
assert n_ok == n_unique

print("=" * 100)
print("(D) set models on the full noisy-parity table: the code for v decides the set hull near alpha = d")


def log2binom(n, k):
    return (math.lgamma(n + 1) - math.lgamma(k + 1) - math.lgamma(n - k + 1)) / math.log(2)


def gam(k):
    """length of the Elias gamma code of k + 1 (k >= 0), as in k2-k4."""
    return 2 * int(math.floor(math.log2(k + 1))) + 1


TAG = 3
for d in [8, 10, 12, 16, 20, 24, 30]:
    N = 2 ** d
    r = 4
    p = 2.0 ** -r
    s0 = N // 2 ** r
    LE = log2binom(N, s0)
    Lp = gam(r)
    for code in ["fixed", "gamma"]:
        cv = (lambda v: math.ceil(math.log2(d + 1))) if code == "fixed" else (lambda v: gam(v))   # gam(v) = Elias gamma of v+1
        pts = {"all strings": (TAG, float(N))}
        for v in range(0, d + 1):
            pts[f"A_v v={v}"] = (TAG + Lp + cv(v) + (d - v), v + LE)
        for j in range(1, s0 + 1, max(1, s0 // 64)):
            pts[f"memo j={j}"] = (TAG + Lp + d + gam(j) + math.ceil(log2binom(N, j)), log2binom(N - j, s0 - j))
        pts["memo j=all"] = (TAG + Lp + d + gam(s0) + math.ceil(LE), 0.0)
        names = list(pts)
        # lambda-interval on which A_{v=0} is the unique MAP: max over others of the lower/upper constraints
        K0, L0 = pts["A_v v=0"]
        lo, hi = 0.0, math.inf
        for nm in names:
            if nm == "A_v v=0":
                continue
            K, L = pts[nm]
            if K < K0:                                     # shorter: need lambda < (L - L0)/(K0 - K)
                hi = min(hi, (L - L0) / (K0 - K))
            elif K > K0:                                   # longer: need lambda > (L0 - L)/(K - K0)
                lo = max(lo, (L0 - L) / (K - K0))
            elif L <= L0:
                lo, hi = math.inf, 0.0
        # Prop 4.4 class form: sigma <= 1 + def0/(alpha0 - k0), k0 = K(A_{v=d}), def0 = two-part(A_{v=d}) - min two-part
        k0, l_ad = pts[f"A_v v={d}"]
        Kmin = min(K + L for K, L in pts.values())
        def0 = k0 + l_ad - Kmin
        bound = 1 + def0 / (K0 - k0)
        knows = [lam for lam in [1.01, 1.1, 1.5, 2.0] if lo < lam < hi]
        assert hi <= bound + 1e-9, "Prop 4.4 (class form) violated"
        print(f"  d={d:2d} p=1/16 code={code:5s}: A_(v=0) is the set lambda-MAP for lambda in "
              + (f"({lo:.4f}, {hi:.4f})" if lo < hi else "an empty set")
              + f"; set lambda-MAP knows the parity at lambda in {knows}; Prop 4.4 class-form bound on its left steepness: {bound:.3f} (holds)")
