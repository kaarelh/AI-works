"""p6_revision.py -- track `purpose`, revision after referees A and B (2026-10-18).

Seed 20261018 (randomness in parts D and F only).  Writes p6_revision.out next to itself.  Run time: about 1 minute.

  A. Fixed against randomised question families on the author's example (referee B, M1), and the graded
     coefficient of near-point misses under the dithered grid with its exact decomposition (T1.5(d); referee B, m12).
  B. Under log loss a miss is priced by the forecaster's own error model (referee B, M2): Gaussian and Laplace
     forecasts scored on a FIXED grid and on the dithered grid; the price of a miss grows like the forecaster's
     -log density, without bound, whatever the question family.
  C. T3.3(b) beyond bounded densities (referee A, m1; referee B, m11): the arcsine law (unbounded density, finite
     entropy) converges to the fine limit h(e) - log Delta, slowly; a singular (Cantor) law has rate -> infinity
     with r(Delta) - log(1/Delta) -> -infinity; the concentration-function lower bound r >= -log Q(Delta).
  D. T4(a) as ideal forecasts on non-nested information (referee A, M5; referee B, M3): an explicit model on a
     circle in which law A's error is independent of A's prediction, law B's error is independent of B's prediction,
     each calibrated forecast is therefore the conditional law of q given that law's own prediction, and the pair
     of predictions determines q.  Log score on dithered cells and CRPS rank the two ideal forecasts oppositely.
  E. Mixability of square loss on [-1, 1]: which two-point pools bind (referee B, m5).  Largest feasible eta per pool.
  F. T1.5(e) for sub-probabilities of total mass m < 1 (referee A, m13): exact dither integral against the formula
     (1/Delta) * int_J (-log side mass) dt + (1 - |J|/Delta) * (-log m).
All logarithms base 2 (bits) unless stated.
"""
import math
import os

import numpy as np
from scipy import integrate, special

SEED = 20261018
HERE = os.path.dirname(os.path.abspath(__file__))
OUT = []
LN2 = math.log(2.0)


def out(s=""):
    OUT.append(s)
    print(s, flush=True)


# ---------------------------------------------------------------- shared: exact dither integrals for atomic forecasts
def dithered_cell_losses(points, weights, x, Delta):
    """Cell [a, a+Delta) containing x, a uniform on (x - Delta, x].  Returns (lengths/Delta, losses in bits) of the
    pieces on which the cell's forecast mass is constant (exact)."""
    points = np.asarray(points, float)
    weights = np.asarray(weights, float)
    lo, hi = x - Delta, x
    bps = np.concatenate([points, points - Delta])
    bps = bps[(bps > lo) & (bps < hi)]
    edges = np.unique(np.concatenate([[lo, hi], bps]))
    mids = 0.5 * (edges[:-1] + edges[1:])
    lens = np.diff(edges) / Delta
    mass = np.array([weights[(points >= a) & (points < a + Delta)].sum() for a in mids])
    with np.errstate(divide="ignore"):
        loss = -np.log2(mass)
    return lens, loss


# ---------------------------------------------------------------- A
def part_A():
    out("== A. fixed against randomised question families (author's example, truth x = 0)")
    near = np.arange(-2, 3, dtype=float)
    scat = np.array([-20.0, -10.0, 0.0, 10.0, 20.0])
    w = np.full(5, 0.2)
    out("   Delta | near: dithered  fixed-centred  fixed-best  fixed-worst | scattered: dithered  fixed-worst  fixed-best"
        " | every fixed grid ranks near <= scattered?")
    for D in [1.0, 2.0, 3.0, 5.0, 10.0, 40.0, 100.0]:
        ln, lo = dithered_cell_losses(near, w, 0.0, D)
        ls, so = dithered_cell_losses(scat, w, 0.0, D)
        # fixed grid with cell [-D/2, D/2): a = -D/2
        def at(points, a):
            m = w[(points >= a) & (points < a + D)].sum()
            return -math.log2(m)
        # common refinement of offsets for the 'every grid' check
        edges = np.unique(np.concatenate([[-D, 0.0],
                                          [b for b in np.concatenate([near, near - D, scat, scat - D]) if -D < b < 0]]))
        mids = 0.5 * (edges[:-1] + edges[1:])
        every = all(at(near, a) <= at(scat, a) + 1e-12 for a in mids)
        out("   %5.0f | %8.4f  %8.4f  %8.4f  %8.4f | %8.4f  %8.4f  %8.4f | %s" % (
            D, float(np.dot(ln, lo)), at(near, -D / 2), lo.min(), lo.max(), float(np.dot(ls, so)), so.max(), so.min(),
            "yes" if every else "NO"))
    out("   -> at cell width 5 or more EVERY fixed grid ranks the near forecast better: a fixed family encodes 'good")
    out("      enough at resolution Delta', and the dithered loss is the offset-average of fixed-grid losses.")
    out("")
    out("   near-point forecasts P = (1-s) delta_y + s Unif(circle of length Rc), truth 0, Rc = 1000 Delta, s = 1e-6:")
    out("   exact: S = sigma * log(Rc/(s Delta)) + (1 - sigma) * (-log(1 - s + s Delta/Rc)), sigma = min(|y|/Delta, 1)")
    D, s = 1.0, 1e-6
    Rc = 1000.0 * D
    big = -math.log2(s * D / Rc)
    small = -math.log2(1 - s + s * D / Rc)
    for y in [0.0, 0.1, 0.25, 0.5, 0.75, 1.0, 2.0, 10.0]:
        sig = min(abs(y) / D, 1.0)
        exact = sig * big + (1 - sig) * small
        # direct dither integral (two atoms: y with 1-s, and a continuous floor s*Delta/Rc everywhere)
        a = np.linspace(-D, 0.0, 200001)[1:] - 0.5 * D / 200000
        m = (1 - s) * ((y >= a) & (y < a + D)) + s * D / Rc
        direct = float(np.mean(-np.log2(m)))
        out("     y/Delta = %5.2f: sigma %.3f | S exact %9.4f, by quadrature over the dither %9.4f | fixed grids give"
            " only %.6f or %.4f" % (y / D, sig, exact, direct, small, big))
    out("   -> a fixed grid grades a near-point miss by one cut (0 or 1); the dither grades it by sigma = min(|y|/Delta,1),")
    out("      bounded and constant beyond one cell width.  S/log(1/s) -> sigma slowly; quote the decomposition.")
    out("")


# ---------------------------------------------------------------- B
def log2_cell_gauss(a, b, y, sig=1.0):
    """log2 of N(y, sig^2) mass of [a, b), stable in the tails"""
    lo, hi = (a - y) / sig, (b - y) / sig
    if lo > 0:  # use symmetry so both arguments are <= 0
        lo, hi = -hi, -lo
    lb, la = special.log_ndtr(hi), special.log_ndtr(lo)
    return (lb + np.log1p(-np.exp(la - lb))) / LN2


def log2_cell_laplace(a, b, y, scale=1.0):
    lo, hi = (a - y) / scale, (b - y) / scale
    if lo > 0:
        lo, hi = -hi, -lo
    # both <= 0 or straddling: F(z) = 0.5 e^z for z <= 0
    if hi <= 0:
        return (math.log(0.5) + hi + math.log1p(-math.exp(lo - hi))) / LN2
    return math.log2(1 - 0.5 * math.exp(-hi) - 0.5 * math.exp(lo))


def part_B():
    out("== B. the price of a miss is set by the forecaster's own error model (truth x = 0, forecast centred at y)")
    for name, f, ref, reflabel in [
            ("Gaussian N(y,1)", log2_cell_gauss, lambda y: y * y / (2 * LN2), "y^2/(2 ln2)"),
            ("Laplace(y,1)", log2_cell_laplace, lambda y: abs(y) / LN2, "|y|/ln2")]:
        out("   %s forecasts; extra price S(y) - S(0) in bits, against %s" % (name, reflabel))
        for D in [0.1, 1.0, 4.0]:
            A = np.linspace(-D, 0.0, 4001)[1:] - 0.5 * D / 4000  # dither offsets a: cell [a, a+D) contains 0
            def S_dith(y):
                return float(np.mean([-f(a, a + D, y) for a in A]))
            def S_fix(y):
                return -f(-D / 2, D / 2, y)
            s0d, s0f = S_dith(0.0), S_fix(0.0)
            row = []
            for y in [1.0, 2.0, 4.0, 6.0, 10.0]:
                row.append("y=%g: fixed %.3f, dithered %.3f [%.3f]" % (y, S_fix(y) - s0f, S_dith(y) - s0d, ref(y)))
            out("     Delta %4.1f | %s" % (D, "; ".join(row)))
    out("   -> on a FIXED partition too, the Gaussian forecaster pays ~ y^2/(2 ln 2) bits for a miss of y and the Laplace")
    out("      forecaster ~ |y|/ln 2: how much a miss costs is chosen by each hypothesis's error model, without bound;")
    out("      the uniform-on-5 forecasts of part A pay the same for every miss beyond their support of the true cell.")
    out("      The question family sets only the resolution (and, randomised, a bounded smoothing up to one cell width).")
    out("")


# ---------------------------------------------------------------- C
def arcsine_rate(D):
    """r(D) = -int f log2(f D) dy, f(y) = (F(y) - F(y - D))/D, F the arcsine cdf on [-1, 1] (exact up to quadrature)"""
    def cellp(y):
        """P(y - D <= e < y) = (asin(a) - asin(b))/pi, a = min(y, 1), b = max(y - D, -1), without cancellation"""
        a, b = min(y, 1.0), max(y - D, -1.0)
        if a <= b:
            return 0.0
        if a * b > 0:  # same sign: sin(asin a - asin b) = (a - b)(a + b)/(a sqrt(1-b^2) + b sqrt(1-a^2))
            s = (a - b) * (a + b) / (a * math.sqrt(max(0.0, 1 - b * b)) + b * math.sqrt(max(0.0, 1 - a * a)))
            return math.asin(min(1.0, max(-1.0, s))) / math.pi
        return (math.asin(a) - math.asin(b)) / math.pi

    def g(y):
        p = cellp(y)  # = f(y) * D, the cell probability
        if p <= 0:
            return 0.0
        return -(p / D) * math.log2(p)
    pts = sorted({-1.0, -1.0 + D, 1.0, 1.0 + D})
    tot = 0.0
    for lo, hi in zip(pts[:-1], pts[1:]):
        # subdivide geometrically towards both ends (the integrand varies on scale D near the support's edges)
        L = hi - lo
        cuts = [lo, hi]
        k = 1
        while L * 2.0 ** (-k) > D / 64 and k < 60:
            cuts += [lo + L * 2.0 ** (-k), hi - L * 2.0 ** (-k)]
            k += 1
        cuts = sorted(set(cuts))
        for a, b in zip(cuts[:-1], cuts[1:]):
            v, _ = integrate.quad(g, a, b, limit=200, epsabs=1e-13, epsrel=1e-12)
            tot += v
    return tot


def atomic_rate(x, w, D):
    """exact r(D) = H(C_U(e) | U) for an atomic law (atoms x, weights w), by the sweep of T3.2:
    r = (1/D) int c(y) log2(1/c(y)) dy with c(y) = P(y - D <= e < y)."""
    ev = np.concatenate([x, x + D])
    dw = np.concatenate([w, -w])
    o = np.argsort(ev, kind="mergesort")
    ev, dw = ev[o], dw[o]
    c = np.cumsum(dw)
    seg = np.diff(ev)
    cc = c[:-1]
    m = cc > 1e-15
    r = float(np.sum(seg[m] * cc[m] * np.log2(1.0 / cc[m]))) / D
    Q = float(cc.max())
    return r, Q


def part_C():
    out("== C. the fine limit T3.3(b) beyond bounded densities")
    h_arc = math.log2(math.pi / 2)
    out("   arcsine law on [-1, 1] (density 1/(pi sqrt(1-x^2)), unbounded; h = log2(pi/2) = %.6f bits)" % h_arc)
    out("   coarse check (Delta >= 2): r = (1/Delta) int H2(F) dx")
    def H2(p):
        return 0.0 if p <= 0 or p >= 1 else -(p * math.log2(p) + (1 - p) * math.log2(1 - p))
    Icoarse, _ = integrate.quad(lambda x: H2(0.5 + math.asin(x) / math.pi), -1, 1, limit=200)
    for D in [2.0, 4.0]:
        out("     Delta %.1f: r %.8f, (1/Delta) int H2(F) %.8f" % (D, arcsine_rate(D), Icoarse / D))
    prev = None
    for D in [1.0, 0.3, 0.1, 0.05, 0.01, 1e-3, 1e-4, 1e-5, 1e-6]:
        r = arcsine_rate(D)
        gap = r - math.log2(1 / D) - h_arc
        extra = ""
        if prev is not None:
            extra = "; log10(gap ratio)/log10(Delta ratio) = %.3f" % (
                math.log10(prev[1] / gap) / math.log10(prev[0] / D))
        out("     Delta %8.1e: r %10.6f, r - log2(1/Delta) %9.6f, gap to h %.3e%s" % (
            D, r, r - math.log2(1 / D), gap, extra))
        prev = (D, gap)
    out("   uniform on [-1, 1] for comparison (bounded density): gap = Delta/(4 ln 2) exactly for Delta <= 2")
    out("   -> the arcsine rate converges to h - log Delta (gap -> 0, at about the rate sqrt(Delta) up to logarithms),")
    out("      as the general proof (lower semicontinuity of relative entropy) says; at 2.5%% of the range it is %.3f bits"
        % (arcsine_rate(0.05) - math.log2(1 / 0.05) - h_arc))
    out("      above it.")
    out("")
    k = 18
    n = 2 ** k
    idx = np.arange(n)
    x = np.zeros(n)
    for j in range(k):
        x += ((idx >> (k - 1 - j)) & 1) * 2.0 * 3.0 ** (-(j + 1))
    x = np.sort(x + 0.5 * 3.0 ** (-k))  # midpoints of the level-k intervals of the Cantor set in [0, 1]
    w = np.full(n, 1.0 / n)
    out("   Cantor law on [0, 1] (singular, no atoms; level-18 approximation, 2^18 atoms at interval midpoints)")
    for j in [1, 2, 4, 6, 8, 10]:
        D = 3.0 ** (-j)
        r, Q = atomic_rate(x, w, D)
        out("     Delta 3^-%-2d = %.3e: r %8.4f, -log2 Q(Delta) %8.4f (lower bound), r - log2(1/Delta) %8.4f"
            "  [j*(1 - log3 2)*log2 3 = %.4f]" % (j, D, r, -math.log2(Q), r - math.log2(1 / D),
                                                    -j * (1 - math.log(2) / math.log(3)) * math.log2(3)))
    out("   -> r -> infinity (no atoms: Q(Delta) -> 0 and r >= -log Q), while r - log2(1/Delta) -> -infinity (no density):")
    out("      the statement 'r(Delta) - log(1/Delta) -> h(e) in [-inf, inf)' covers every law with bounded support.")
    out("")


# ---------------------------------------------------------------- D
def part_D(rng):
    out("== D. T4(a) as ideal forecasts on non-nested information (explicit model on a circle)")
    n, Rc, M, rho = 400000, 1.0e4, 1000.0, 0.2
    Z = rng.uniform(0, Rc, n)
    eA = rng.uniform(-1, 1, n)
    eB = rng.choice([-M, 0.0, M], size=n, p=[rho / 2, 1 - rho, rho / 2])
    fA = Z
    q = np.mod(fA - eA, Rc)
    fB = np.mod(q + eB, Rc)
    # unwrapped coordinates for the scores (distances are what matter; the circle is needed only for independence)
    qL = fA - eA
    fBL = qL + eB
    out("   model: Z ~ U[0, %g) on a circle, f_A = Z, e_A ~ U[-1,1], q = f_A - e_A, e_B in {-M,0,M} w.p. {.1,.8,.1}"
        % Rc)
    out("          (M = %g), f_B = q + e_B; Z independent of (e_A, e_B), so f_B = Z - e_A + e_B is uniform and" % M)
    out("          independent of (e_A, e_B): e_A is independent of f_A and e_B of f_B (exactly).  n = %d" % n)

    def mi_plugin(a_lab, b_lab):
        ua, ia = np.unique(a_lab, return_inverse=True)
        ub, ib = np.unique(b_lab, return_inverse=True)
        J = np.zeros((len(ua), len(ub)))
        np.add.at(J, (ia, ib), 1)
        J /= J.sum()
        pa, pb = J.sum(1, keepdims=True), J.sum(0, keepdims=True)
        m = J > 0
        return float(np.sum(J[m] * np.log2(J[m] / (pa @ pb)[m])))
    binsB = np.floor(fB / Rc * 50).astype(int)
    binsA = np.floor(fA / Rc * 50).astype(int)
    eAbin = np.floor((eA + 1) * 5).astype(int)
    out("   plug-in mutual information (bits; bias ~ (cells-1)/(2 n ln2) ~ 1e-4): I(e_B; f_B in 50 bins) %.5f,"
        " I(e_A in 10 bins; f_A in 50 bins) %.5f" % (mi_plugin(eB, binsB), mi_plugin(eAbin, binsA)))
    d = np.mod(fA - fB + Rc / 2, Rc) - Rc / 2  # = e_A - e_B  (mod Rc, centred; |e_A - e_B| <= M + 1 < Rc/2)
    eB_dec = np.array([-M, 0.0, M])[np.argmin(np.abs(-d[:, None] - np.array([-M, 0.0, M])[None, :]), axis=1)]
    out("   the pair determines q: e_B decoded as the element of {-M,0,M} nearest to f_A - f_B on %d of %d data;"
        " I(e_B; f_A - f_B) = H(e_B) = %.5f" % (int(np.sum(eB_dec == eB)), n, mi_plugin(eB, np.round(d))))
    # log scores on dithered cells of width Delta (the dither is uniform and independent of everything)
    u = rng.uniform(0, 1, n)
    out("   expected log score (bits) of the two ideal forecasts on dithered cells of width Delta:")
    for D in [0.1, 1.0, 1.5, 1.6, 2.0, 10.0]:
        a = qL - np.mod(qL + u * D, D)  # left end of q's cell in the grid {k D - u D}
        b = a + D
        mA = (np.clip(b, fA - 1, fA + 1) - np.clip(a, fA - 1, fA + 1)) / 2.0  # U[fA-1, fA+1] mass of the cell
        # forecast B: atoms fB (0.8), fB - M (0.1), fB + M (0.1) (mod Rc); D < M, so only the true atom is in the cell
        mB = np.full(n, 0.0)
        for off, pr in [(0.0, 1 - rho), (-M, rho / 2), (M, rho / 2)]:
            at = fBL + off - a
            mB += pr * ((at >= 0) & (at < D))
        rA = float(np.mean(-np.log2(mA)))
        rB = float(np.mean(-np.log2(mB)))
        rA_cf = (1 + D / (4 * LN2) - math.log2(D)) if D <= 2 else (1 / LN2) / D
        HB = -(0.8 * math.log2(0.8) + 2 * 0.1 * math.log2(0.1))
        out("     Delta %6.4f: A %.4f (closed form %.4f) | B %.4f (H = %.4f) | log score prefers %s" % (
            D, rA, rA_cf, rB, HB, "B" if rB < rA else "A"))
    # CRPS of the ideal forecasts: E|X - x| - 0.5 E|X - X'|
    # forecast fA - V, V ~ U[-1,1]; truth q = fA - e_A; exact: E|X - x| for X = fA - V, V ~ U[-1,1], x = fA - e_A: E|V - e_A| given e_A, averaged
    crA = float(np.mean((1 + eA ** 2) / 2.0)) - 0.5 * (2.0 / 3.0)
    vals = np.array([-M, 0.0, M])
    pr = np.array([rho / 2, 1 - rho, rho / 2])
    EXX = float(np.sum(pr[:, None] * pr[None, :] * np.abs(vals[:, None] - vals[None, :])))
    crB = float(np.mean([np.sum(pr * np.abs(vals - e)) for e in eB[:20000]])) - 0.5 * EXX
    out("   CRPS of the two ideal forecasts: A %.4f (exact 1/3) | B %.2f (exact 180): CRPS prefers A at every Delta" % (
        crA, crB))
    out("   -> both forecasts are ideal (auto-calibrated: the conditional law of q given the law's own prediction); the")
    out("      information sets sigma(f_A), sigma(f_B) are not nested, and the strictly proper log score (at Delta below")
    out("      1.5585) and CRPS rank them oppositely.  The forecaster with sigma(f_A, f_B) is a point mass and beats both")
    out("      under every proper score (nested case).  No forecaster here is miscalibrated relative to its information.")
    out("")


# ---------------------------------------------------------------- E
def margin(points, probs, c, om=np.linspace(-1, 1, 20001)):
    """max_w (w - sqrt G(w)) - min_w (w + sqrt G(w)); > 0 means no gamma works (infeasible); square loss, B = 1, eta = c"""
    pts = np.asarray(points, float)[:, None]
    p = np.asarray(probs, float)[:, None]
    z = -c * (pts - om[None, :]) ** 2
    zmax = z.max(0)
    G = -(zmax + np.log(np.sum(p * np.exp(z - zmax[None, :]), 0))) / c
    G = np.maximum(G, 0.0)
    sq = np.sqrt(G)
    return float(np.max(om - sq) - np.min(om + sq))


def largest_c(points, probs, lo=0.2, hi=2.0, tol=1e-6):
    if margin(points, probs, hi) <= 1e-12:
        return float("inf")
    while hi - lo > tol:
        mid = 0.5 * (lo + hi)
        if margin(points, probs, mid) <= 1e-12:
            lo = mid
        else:
            hi = mid
    return lo


def part_E(rng):
    out("== E. square loss on [-1, 1] (B = 1): largest eta for which a pool is dominated (bisection, 20001 outcomes)")
    out("   two endpoints {-1, 1}:")
    for p in [0.5, 0.3, 0.1, 0.01]:
        out("     p(-1) = %.2f: largest eta %.5f" % (p, largest_c([-1.0, 1.0], [p, 1 - p])))
    out("   central pairs {-a, a}, p = 1/2:")
    for a in [1.0, 0.5, 0.2, 0.1, 0.05, 0.01]:
        out("     a = %.2f: largest eta %.5f" % (a, largest_c([-a, a], [0.5, 0.5])))
    out("   asymmetric pairs:")
    for (g1, g2, p) in [(-1.0, 0.0, 0.5), (0.0, 0.1, 0.5), (0.9, 1.0, 0.5), (-0.05, 0.05, 0.2)]:
        c_ = largest_c([g1, g2], [p, 1 - p]); out("     {%.2f, %.2f}, p = %.1f: largest eta %s" % (g1, g2, p, "> 2 (dominated at every eta tried)" if c_ == float("inf") else "%.5f" % c_))
    worst = (None, -1.0)
    for _ in range(3000):
        k = rng.integers(2, 5)
        pts = rng.uniform(-1, 1, k)
        pr = rng.dirichlet(np.ones(k))
        mg = margin(pts, pr, 0.505, om=np.linspace(-1, 1, 2001))
        if mg > worst[1]:
            worst = ((np.round(pts, 3), np.round(pr, 3)), mg)
    out("   3000 random pools of 2-4 points at eta = 0.505: largest infeasibility margin %.3e at %s" % (
        worst[1], worst[0]))
    out("   -> the threshold 1/(2B^2) is approached by narrow pools near the centre (a -> 0), not by the endpoint pool,")
    out("      which stays dominated up to eta ~ 0.609 when p = 1/2 (cosh(2 eta) <= e^eta).")
    out("")


# ---------------------------------------------------------------- F
def part_F(rng):
    out("== F. T1.5(e) for sub-probabilities: forecast of total mass m on J = [0, L], L <= Delta, truth at an atom")
    worst = 0.0
    for trial in range(200):
        D = 1.0
        L = rng.uniform(0.2, 1.0)
        k = rng.integers(2, 9)
        pts = np.sort(rng.uniform(0, L, k))
        pts[0], pts[-1] = 0.0, L  # J = [0, L] exactly
        m = rng.uniform(0.05, 1.0)
        wts = rng.dirichlet(np.ones(k)) * m
        i0 = rng.integers(0, k)
        x = pts[i0]
        lens, loss = dithered_cell_losses(pts, wts, x, D)
        exact = float(np.dot(lens, loss))
        # formula: integral over t in (0, L] of the side mass, plus the no-grid-point term
        ts = np.concatenate([[0.0], pts[pts > 0]])
        integ = 0.0
        for a, b in zip(ts[:-1], ts[1:]):
            t = 0.5 * (a + b)  # side masses are constant for t in (a, b)
            side = wts[pts >= t].sum() if x >= t else wts[pts < t].sum()
            integ += (b - a) * (-math.log2(side))
        formula = integ / D + (1 - L / D) * (-math.log2(m))
        worst = max(worst, abs(exact - formula))
        if trial < 3:
            out("     trial %d: m = %.3f, L = %.3f: exact dither integral %.10f, formula %.10f" % (
                trial, m, L, exact, formula))
    out("   200 random forecasts: max |exact - formula| = %.2e bits" % worst)
    out("   -> with m < 1 the no-grid-point case costs -log m, not 0; for m = 1 the formula is CRIGN/Delta.")
    out("")


def main():
    rng = np.random.default_rng(SEED)
    out("# p6_revision.py seed=%d numpy %s" % (SEED, np.__version__))
    out("")
    part_A()
    part_B()
    part_C()
    part_D(rng)
    part_E(rng)
    part_F(rng)
    out("# done")
    with open(os.path.join(HERE, "p6_revision.out"), "w") as fh:
        fh.write("\n".join(OUT) + "\n")


if __name__ == "__main__":
    main()
