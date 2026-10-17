"""l10_revision.py -- checks written for the revision of thread `laws` (notes-final.md), after referee
reports A and B.  Written from the statements of notes-final.md, independently of the referees' code
(referee_code/) and re-using none of it.

Seed 20261016.  Reads l4_residuals.npz (read only); writes l10_revision.out next to itself.

Parts
  A. Peakedness per fit (referee A M6, referee B 8): for each of the 39 body-window series, eps*, E|e| and
     pk = eps*/E|e| of the minimax fit and of the mean fit separately, and the cross ratio
     eps*(minimax)/E|e|(mean) that notes.md reported as "pk".  A local-parabola estimate of how far the
     sample maximum of |e| may lie below the window's true supremum.
  B. Band-confined completions (referee B 1; notes-final Def 3.6a, Prop 3.6a): per-straddle code-R costs
     c_G (bits) of the uniform band H, of HY(s) ("exact with probability s, else uniform in the band") at its
     best s, of SH (a smoothed 40-bin histogram of the band position fitted on a random half of the times,
     evaluated on the other half), and the empirical Gibbs bound int H2(F(V)) dV; the derivative criterion
     c'(0+) = E ln(1 + |e|/eps) + 1 - 2 ln 2 and the two peakedness bounds; synthetic and real errors.
  C. Rates under SAI's pricing on the real residuals, at 11 cell widths (coarse regime exact, fine regime by a
     256-point midpoint rule over the dither, H by its closed form): empty law 0, exact law with random
     whole-circle exceptions P (min over rho), H, HY*, SH.  Winner among {0,P,H} and among all five;
     sensitivity to inflating the band by kappa in {0, 0.01, 0.05}.
  D. Lemma 3.6 (exact fine-regime formula, bound log e, monotonicity in Delta), against quadrature.
  E. notes.md l8 A (the Moon inside a Kepler law) recomputed exactly; ties resolved by the three cases of
     Thm 3.8 (notes-final).
  F. notes.md l8 B (retention) recomputed with the exact fine-regime code-R cost; Delta* by bisection.
  G. Deterministic patch codes against random exceptions (referee A M1): per-exception cost of literal
     numerals, of an enumerative code of the patch set, and H2(p)/p.
  H. The phase sequence under SAI's pricing with exact theory-machine costs (distinct times): the exact law E,
     the exact law with Laplace-mixture random exceptions P, the uniform honest band H, a true theory N;
     sinusoidal error, Delta = 60', 400 runs.
  I. Prop 7.1 (notes-final Prop 7.1(d) and its reading; referees A M2, B 2), exact rationals.
  J. Prop 5.5(b) read literally (referee B 3): the hand counterexample and a random count.
"""
import math
import os
import sys
import time
from fractions import Fraction as Fr

import numpy as np
from scipy.special import gammaln

SEED = 20261016
OUT = []
RANGE = 21600.0
LN2 = math.log(2.0)
LOG2E = 1.0 / LN2


def out(s=""):
    OUT.append(s)
    print(s, flush=True)


def H2(x):
    x = np.clip(np.asarray(x, float), 1e-300, 1 - 1e-16)
    return -x * np.log2(x) - (1 - x) * np.log2(1 - x)


# ---------------------------------------------------------------------------------------------------------
# piecewise-linear CDFs on [0,1] (band coordinates) with possible jumps at knots
# G is given by knots v_0 = 0 < ... < v_m = 1, right values Gr[i] = G(v_i+) and left values Gl[i] = G(v_i-)
# (Gl[0] = 0, Gr[m] = 1).  On (v_i, v_{i+1}) G is linear from Gr[i] to Gl[i+1].

def Iint(a0, a1, al, be):
    """integral_{a0}^{a1} -log2(al*V + be) dV, elementwise; 0 where a1 <= a0.  al, be broadcastable."""
    a0 = np.asarray(a0, float)
    a1 = np.asarray(a1, float)
    al = np.asarray(al, float) + 0.0 * a0
    be = np.asarray(be, float) + 0.0 * a0
    ok = a1 > a0
    res = np.zeros(np.broadcast(a0, a1, al, be).shape)
    small = np.abs(al) < 1e-14

    def F(y):
        y = np.maximum(y, 1e-300)
        return y * np.log(y) - y
    with np.errstate(divide="ignore", invalid="ignore"):
        gen = -(F(al * a1 + be) - F(al * a0 + be)) / np.where(small, 1.0, al) / LN2
        cst = -(a1 - a0) * np.log2(np.maximum(be, 1e-300))
    res = np.where(small, cst, gen)
    return np.where(ok, res, 0.0)


class CDF:
    def __init__(self, v, Gr, Gl):
        self.v = np.asarray(v, float)
        self.Gr = np.asarray(Gr, float)
        self.Gl = np.asarray(Gl, float)
        self.slope = (self.Gl[1:] - self.Gr[:-1]) / (self.v[1:] - self.v[:-1])
        self.icpt = self.Gr[:-1] - self.slope * self.v[:-1]

    def left(self, y):
        """G(y-) = mass of [0, y); G(1-) := 1 at y >= 1 (endpoint of measure zero for continuous parts)."""
        y = np.asarray(y, float)
        i = np.clip(np.searchsorted(self.v, y, side="left") - 1, 0, len(self.v) - 2)
        val = self.icpt[i] + self.slope[i] * y
        atknot = np.isclose(y, self.v[np.clip(i + 1, 0, len(self.v) - 1)], atol=0) & (y < 1)
        val = np.where(y <= 0, 0.0, val)
        val = np.where(y >= 1, 1.0, val)
        return val

    def coarse_cost(self, x):
        """per-straddle cost E_V[ [V<x](-log2(1-G(V))) + [V>x](-log2 G(V)) ] for each x (V uniform on [0,1])."""
        x = np.asarray(x, float)[:, None]
        a, b = self.v[:-1][None, :], self.v[1:][None, :]
        al, be = self.slope[None, :], self.icpt[None, :]
        right = Iint(np.maximum(a, x), b, al, be)          # V > x : -log2 G(V)
        left = Iint(a, np.minimum(b, x), -al, 1.0 - be)     # V < x : -log2(1 - G(V))
        return (right + left).sum(axis=1)

    def fine_cost(self, x, r, M=256):
        """cell width r (band units, r < 1 or any): E_u[-log2 G-mass of the cell of x], midpoint rule in u."""
        x = np.asarray(x, float)[:, None]
        u = (np.arange(M) + 0.5)[None, :] / M
        lo = np.maximum(0.0, x - u * r)
        hi = np.minimum(1.0, x + (1 - u) * r)
        mass = self.left(hi) - self.left(lo)
        # a cell [lo, hi) contains a jump at knot v iff lo <= v < hi: left() at hi excludes v only if hi == v;
        # with midpoints u, hi == v has probability 0.
        return np.mean(-np.log2(np.maximum(mass, 1e-300)), axis=1)


def cdf_uniform():
    return CDF([0.0, 1.0], [0.0, 1.0], [0.0, 1.0])


def cdf_hy(s):
    return CDF([0.0, 0.5, 1.0], [0.0, s + (1 - s) * 0.5, 1.0], [0.0, (1 - s) * 0.5, 1.0])


def cdf_hist(xtrain, B=40):
    cnt, edges = np.histogram(xtrain, bins=B, range=(0.0, 1.0))
    pr = (cnt + 0.5) / (cnt.sum() + 0.5 * B)
    G = np.concatenate([[0.0], np.cumsum(pr)])
    G[-1] = 1.0
    return CDF(edges, G, G)


def gibbs_emp(x):
    """int_0^1 H2(F(V)) dV for the empirical CDF F of the sample x (bits)."""
    xs = np.sort(np.asarray(x, float))
    n = xs.size
    pts = np.concatenate([[0.0], xs, [1.0]])
    k = np.arange(n + 1) / n
    return float(np.sum(np.diff(pts) * H2(k)))


def golden(f, a, b, it=60):
    gr = (math.sqrt(5) - 1) / 2
    c, d = b - gr * (b - a), a + gr * (b - a)
    fc, fd = f(c), f(d)
    for _ in range(it):
        if fc < fd:
            b, d, fd = d, c, fc
            c = b - gr * (b - a)
            fc = f(c)
        else:
            a, c, fc = c, d, fd
            d = a + gr * (b - a)
            fd = f(d)
    xm = (a + b) / 2
    return xm, f(xm)


def hy_best_coarse(x):
    """best s in [0,1) for HY(s) on the sample x, coarse regime; returns (s*, cost, cost at s=0)."""
    def f(s):
        return float(np.mean(cdf_hy(s).coarse_cost(x)))
    c0 = f(0.0)
    s, cs = golden(f, 0.0, 1.0 - 1e-9)
    if c0 <= cs:
        return 0.0, c0, c0
    return s, cs, c0


def honest_fine_closed(x, r):
    """closed form (notes-final Lemma 3.6) of the expected code-R cost of the uniform band at cell width r = Delta/L
    (band units), any r > 0: fine (r < 1): log2(1/r) + [phi(x/r) + phi((1-x)/r)] log2 e; coarse: r^-1 (log2 e - H2(x))."""
    x = np.asarray(x, float)
    if r >= 1:
        return (1.0 / r) * (LOG2E - H2(x))

    def phi(z):
        z = np.minimum(z, 1.0)
        with np.errstate(divide="ignore", invalid="ignore"):
            v = 1 - z + np.where(z > 0, z * np.log(np.maximum(z, 1e-300)), 0.0)
        return v
    return math.log2(1.0 / r) + (phi(x / r) + phi((1 - x) / r)) * LOG2E


def p_rand_rate(p, g):
    """exact law with random whole-circle exceptions (R/rand and Q/rand coincide for P): min over rho of
    (1-p)(-log2(1 - rho + rho 2^-g)) + p(g - log2 rho)."""
    if p <= 0:
        return 0.0
    s = 2.0 ** (-g)

    def f(lr):
        rho = 10.0 ** lr
        return (1 - p) * (-math.log2(1 - rho + rho * s)) + p * (g - math.log2(rho))
    _, v = golden(f, -12.0, 0.0)
    return min(v, f(0.0))


# ---------------------------------------------------------------------------------------------------------
def main():
    t0 = time.time()
    rng = np.random.default_rng(SEED)
    here = os.path.dirname(os.path.abspath(__file__))
    Z = np.load(os.path.join(here, "l4_residuals.npz"), allow_pickle=False)
    out("# l10_revision.py seed=%d python %s numpy %s; input l4_residuals.npz (%d arrays)" % (
        SEED, sys.version.split()[0], np.__version__, len(Z.files)))
    order_b = ["Mercury", "Venus", "EMB", "Mars", "Jupiter", "Saturn", "Moon"]

    def sortkey(k):
        b, w = k.split("_")
        wv = {"1month": 1 / 12, "1year": 1.0, "18.6yr": 18.6}.get(w, None)
        return (order_b.index(b), float(w) if wv is None else wv)
    rows = sorted({k[:-2] for k in Z.files if k.endswith("_t")}, key=sortkey)

    # ------------------------------------------------------------------ A
    out("\n== A. peakedness per fit (arcmin).  mm = minimax fit (least max|e|), mean = least-mean fit; "
        "cross = eps*_mm / E|e|_mean (notes.md's 'pk')")
    out("   'sup+' = local-parabola estimate of (true sup - sample max)/sample max for the mm series (3 samples around"
        " the max, time-sorted; '-' if the vertex falls outside them)")
    out("   %-8s %7s | %8s %8s %6s | %8s %8s %6s | %6s | %7s" % (
        "body", "window", "eps*_mm", "E|e|_mm", "pk_mm", "eps*_mn", "E|e|_mn", "pk_mn", "cross", "sup+"))
    pk_mm, pk_mn, cross, supx = [], [], [], []
    for k in rows:
        b, w = k.split("_")
        t = Z[k + "_t"].astype(float)
        emm = Z[k + "_e_max"].astype(float)
        emn = Z[k + "_e_mean"].astype(float)
        a1, a2 = float(np.max(np.abs(emm))), float(np.mean(np.abs(emm)))
        b1, b2 = float(np.max(np.abs(emn))), float(np.mean(np.abs(emn)))
        pk_mm.append(a1 / a2)
        pk_mn.append(b1 / b2)
        cross.append(a1 / b2)
        o = np.argsort(t)
        ts, es = t[o], np.abs(emm[o])
        i = int(np.argmax(es))
        sx = "-"
        if 0 < i < len(ts) - 1:
            X = ts[i - 1:i + 2] - ts[i]
            Y = es[i - 1:i + 2]
            cA = np.polyfit(X, Y, 2)
            if cA[0] < 0:
                xv = -cA[1] / (2 * cA[0])
                if X[0] <= xv <= X[2]:
                    yv = np.polyval(cA, xv)
                    supx.append((yv - es[i]) / es[i])
                    sx = "%.1e" % ((yv - es[i]) / es[i])
        out("   %-8s %7s | %8.3f %8.3f %6.2f | %8.3f %8.3f %6.2f | %6.2f | %7s" % (
            b, w, a1, a2, a1 / a2, b1, b2, b1 / b2, a1 / b2, sx))
    out("   ranges: pk_mm %.2f-%.2f, pk_mean %.2f-%.2f, cross %.2f-%.2f; parabola excess: %d series estimated, max %.1e,"
        " median %.1e" % (min(pk_mm), max(pk_mm), min(pk_mn), max(pk_mn), min(cross), max(cross), len(supx),
                          max(supx) if supx else float("nan"), float(np.median(supx)) if supx else float("nan")))

    # ------------------------------------------------------------------ B
    out("\n== B. band-confined completions, coarse regime: per-straddle costs c_G in bits (rate = (2 eps/Delta) c_G)")
    out("   criterion (F2): some HY(s), s > 0, beats H iff  E ln(1+|e|/eps) < 2 ln 2 - 1 = %.4f;" % (2 * LN2 - 1))
    out("   necessary pk > ln2/(2ln2-1) = %.4f; sufficient pk > e/(4-e) = %.4f  (pk = eps / E|e| with the band's eps)" % (
        LN2 / (2 * LN2 - 1), math.e / (4 - math.e)))

    def band_row(name, e, eps, split_rng):
        x = (eps - e) / (2 * eps)
        cH = float(np.mean(cdf_uniform().coarse_cost(x)))
        cH_closed = float(np.mean(LOG2E - H2(x)))
        s, cHY, _ = hy_best_coarse(x)
        crit = float(np.mean(np.log1p(np.abs(e) / eps))) + 1 - 2 * LN2
        pk = eps / float(np.mean(np.abs(e)))
        idx = split_rng.permutation(x.size)
        tr, te = idx[: x.size // 2], idx[x.size // 2:]
        G = cdf_hist(x[tr])
        cSH = float(np.mean(G.coarse_cost(x[te])))
        cH_te = float(np.mean(cdf_uniform().coarse_cost(x[te])))
        gib = gibbs_emp(x[te])
        return dict(name=name, cH=cH, cHc=cH_closed, s=s, cHY=cHY, crit=crit, pk=pk, cSH=cSH, cHte=cH_te, gib=gib,
                    x=x, G=G)

    out("   %-24s | %6s | %7s %7s | %7s %6s | %7s %7s %7s | %8s %s" % (
        "error", "pk", "H", "H(cf)", "HY*", "s*", "SH(te)", "H(te)", "Gibbs", "c'(0+)", "HY wins? / crit / bounds"))
    srng = np.random.default_rng(SEED + 1)
    n = 200000
    ph = rng.random(n)
    synth = [("sinusoid", np.sin(2 * math.pi * ph), 1.0),
             ("peaked +-1 on 5%", np.where(rng.random(n) < 0.05, np.where(rng.random(n) < 0.5, -1.0, 1.0), 0.0), 1.0),
             ("|e| uniform", rng.random(n) * np.where(rng.random(n) < 0.5, -1.0, 1.0), 1.0),
             ("two-level 0.25/1 (90/10)", np.where(rng.random(n) < 0.9, 0.25, 1.0) * np.where(rng.random(n) < 0.5, -1, 1), 1.0)]
    for name, e, eps in synth:
        r = band_row(name, e, eps, srng)
        wins = r["cHY"] < r["cH"] - 1e-9
        out("   %-24s | %6.2f | %7.4f %7.4f | %7.4f %6.3f | %7.4f %7.4f %7.4f | %8.4f %s / %s / %s" % (
            name, r["pk"], r["cH"], r["cHc"], r["cHY"], r["s"], r["cSH"], r["cHte"], r["gib"], r["crit"],
            "yes" if wins else "no", "yes" if r["crit"] < 0 else "no",
            "pk>2.12" if r["pk"] > math.e / (4 - math.e) else ("pk<=1.79" if r["pk"] <= LN2 / (2 * LN2 - 1) else "between")))

    out("\n   real residuals, minimax fit, band eps = 1.01 * sample max:")
    real = {}
    n_hy, n_sh, n_crit_agree, n_bound_viol, n_sh_gib = 0, 0, 0, 0, 0
    for k in rows:
        emm = Z[k + "_e_max"].astype(float)
        eps = 1.01 * float(np.max(np.abs(emm)))
        r = band_row(k, emm, eps, srng)
        real[k] = (emm, eps, r)
        wins = r["cHY"] < r["cH"] - 1e-9
        n_hy += wins
        n_sh += r["cSH"] < r["cHte"]
        n_crit_agree += (wins == (r["crit"] < 0))
        n_sh_gib += r["cSH"] >= r["gib"] - 1e-12
        if r["pk"] > math.e / (4 - math.e) and not wins:
            n_bound_viol += 1
        if r["pk"] <= LN2 / (2 * LN2 - 1) and wins:
            n_bound_viol += 1
        out("   %-24s | %6.2f | %7.4f %7.4f | %7.4f %6.3f | %7.4f %7.4f %7.4f | %8.4f %s / %s" % (
            k, r["pk"], r["cH"], r["cHc"], r["cHY"], r["s"], r["cSH"], r["cHte"], r["gib"], r["crit"],
            "yes" if wins else "no", "yes" if r["crit"] < 0 else "no"))
    out("   summary (39 pairs): HY* < H in %d; SH < H (test half) in %d; criterion agrees with the optimum in %d;"
        " peakedness-bound violations %d; SH >= Gibbs bound in %d" % (n_hy, n_sh, n_crit_agree, n_bound_viol, n_sh_gib))

    # ------------------------------------------------------------------ C
    out("\n== C. per-datum rates under SAI's pricing (bits/datum), real residuals; band eps = (1+kappa) * sample max of the")
    out("   minimax fit; P uses the mean fit (exact law, random whole-circle exceptions, best rho). Coarse regime exact;")
    out("   fine regime: H closed form, HY/SH by a 256-point midpoint rule over the dither (HY's s re-optimised per Delta).")
    DELTAS = [0.1, 0.3, 1.0, 3.0, 10.0, 30.0, 60.0, 120.0, 300.0, 600.0, 1800.0]
    cnt = {}
    worst_gain = []
    lines = []
    for kappa in (0.0, 0.01, 0.05):
        n_cells, n_H3, n_SH5, n_HY_lt_H, changed = 0, 0, 0, 0, 0
        for k in rows:
            emm = Z[k + "_e_max"].astype(float)
            emn = Z[k + "_e_mean"].astype(float)
            eps = (1 + kappa) * float(np.max(np.abs(emm)))
            x = (eps - emm) / (2 * eps)
            idx = np.random.default_rng(SEED + 7).permutation(x.size)
            tr, te = idx[: x.size // 2], idx[x.size // 2:]
            G = cdf_hist(x[tr])
            xs = x[te]
            for D in DELTAS:
                g = math.log2(RANGE / D)
                p = float(np.mean(np.minimum(np.abs(emn) / D, 1.0)))
                rP = p_rand_rate(p, g)
                r = D / (2 * eps)
                rH = float(np.mean(honest_fine_closed(xs, r)))
                if r >= 1:
                    q = 1.0 / r
                    rSH = q * float(np.mean(G.coarse_cost(xs)))
                    s, cHY, _ = hy_best_coarse(xs)
                    rHY = q * cHY
                else:
                    rSH = float(np.mean(G.fine_cost(xs, r)))
                    sub = xs[::8]

                    def fhy(s):
                        return float(np.mean(cdf_hy(s).fine_cost(sub, r, M=128)))
                    s, _ = golden(fhy, 0.0, 1.0 - 1e-6, it=30)
                    rHY = min(float(np.mean(cdf_hy(s).fine_cost(xs, r))), rH)
                rates3 = {"0": g, "P": rP, "H": rH}
                rates5 = dict(rates3, HY=rHY, SH=rSH)
                w3 = min(rates3, key=rates3.get)
                w5 = min(rates5, key=rates5.get)
                n_cells += 1
                n_H3 += (w3 == "H")
                n_SH5 += (w5 == "SH")
                n_HY_lt_H += (rHY < rH - 1e-9)
                changed += (w3 != w5)
                if kappa == 0.01:
                    worst_gain.append((rH - rSH) / rH)
                    lines.append((k, D, g, rP, rH, rHY, rSH, w3, w5))
        out("   kappa=%.2f: %d cells; winner among {0,P,H} is H in %d; among {0,P,H,HY,SH}: SH in %d, HY* < H in %d,"
            " winner changed in %d" % (kappa, n_cells, n_H3, n_SH5, n_HY_lt_H, changed))
    out("   kappa=0.01: SH's rate below H's by %.1f%% to %.1f%% (median %.1f%%)" % (
        100 * min(worst_gain), 100 * max(worst_gain), 100 * float(np.median(worst_gain))))
    out("   selected cells (kappa = 0.01):")
    out("   %-14s %6s | %6s | %8s %8s %8s %8s | %s / %s" % ("series", "Delta", "gamma", "P", "H", "HY*", "SH", "w3", "w5"))
    for (k, D, g, rP, rH, rHY, rSH, w3, w5) in lines:
        if k in ("Mars_12", "EMB_300", "EMB_100", "Jupiter_30", "Moon_1year") and D in (1.0, 10.0, 60.0, 600.0, 1800.0):
            out("   %-14s %6g | %6.2f | %8.4f %8.4f %8.4f %8.4f | %s / %s" % (k, D, g, rP, rH, rHY, rSH, w3, w5))

    # ------------------------------------------------------------------ D
    out("\n== D. Lemma 3.6: expected code-R cost of the uniform band, closed form against quadrature (5000-point midpoint")
    out("   rule over the dither), excess over log2(L/Delta) in the fine regime, monotonicity in Delta")
    ws = np.linspace(0.0, 1.0, 401)
    rs = np.concatenate([np.linspace(0.02, 1.0, 50), np.linspace(1.0, 5.0, 41)[1:]])   # r = Delta/L
    maxerr, maxexc, viol = 0.0, 0.0, 0
    U = cdf_uniform()
    prev = None
    for r in rs:
        num = U.fine_cost(ws, r, M=5000) if r < 1 else (1.0 / r) * U.coarse_cost(ws)
        cf = honest_fine_closed(ws, r)
        maxerr = max(maxerr, float(np.max(np.abs(num - cf))))
        if r < 1:
            maxexc = max(maxexc, float(np.max(cf - math.log2(1.0 / r))))
        if prev is not None:
            viol += int(np.sum(cf > prev + 1e-12))
        prev = cf
    out("   max |closed - quadrature| = %.2e bits over %d (w, Delta/L) cells; max fine-regime excess = %.6f bits"
        " (log2 e = %.6f); increases of the cost with Delta: %d" % (maxerr, ws.size * rs.size, maxexc, LOG2E, viol))
    out("   continuity at Delta = L: closed fine form at r = 1-1e-9 vs coarse form at r = 1: max diff %.2e" % float(
        np.max(np.abs(honest_fine_closed(ws, 1 - 1e-9) - honest_fine_closed(ws, 1.0)))))
    out("   constant of Props 3.7, 6.1(c): R/(2e) = %.0f' = %.1f deg (notes.md: R/(2e^2) = %.0f' = %.1f deg)" % (
        RANGE / (2 * math.e), RANGE / (2 * math.e) / 60, RANGE / (2 * math.e ** 2), RANGE / (2 * math.e ** 2) / 60))

    # ------------------------------------------------------------------ E
    out("\n== E. notes.md l8 A recomputed exactly: the Moon (one fixed ellipse, one year) inside a Kepler law")
    em, ex = Z["Moon_1year_e_mean"].astype(float), Z["Moon_1year_e_max"].astype(float)
    pic = math.log2(365.25) + 2
    kM, hM, dom = 60.0, 20.0, 4.0
    epsM = float(np.max(np.abs(ex)))
    xM = (epsM - ex) / (2 * epsM)
    out("   eps*_Moon = %.2f', E|e|(mean fit) = %.2f', pi_c = %.2f, k = %g, h = %g, |Dom| = %g" % (
        epsM, float(np.mean(np.abs(em))), pic, kM, hM, dom))
    out("   winner: least rate; on an exact tie with a.s. constant difference the constants decide (Thm 3.8(ii))")
    out("   %6s %4s | %7s | %9s %9s %9s | %9s %9s | Q / R" % ("Delta", "lam", "gamma", "P(Q)", "H(Q)", "X", "P(R)", "H(R)"))
    for D in (10.0, 60.0, 300.0, 600.0, 1800.0):
        g = math.log2(RANGE / D)
        p = float(np.mean(np.minimum(np.abs(em) / D, 1.0)))
        qH = min(2 * epsM / D, 1.0)
        for lam in (1.0, 2.0):
            PQ = p * (lam * pic + g)
            HQ = qH * g          # exact: silent w.p. 2eps/Delta (coarse) or always (fine), cost gamma when silent
            PR = min(PQ, p_rand_rate(p, g))
            HR = float(np.mean(honest_fine_closed(xM, D / (2 * epsM))))
            fixed = {"P": lam * kM, "H": lam * (kM + hM), "X": lam * dom}
            res = []
            for (rP_, rH_) in ((PQ, HQ), (PR, HR)):
                rate = {"P": rP_, "H": rH_, "X": g}
                best = min(rate.values())
                tied = [f for f in rate if abs(rate[f] - best) < 1e-12]
                w = min(tied, key=lambda f: fixed[f])
                res.append(w + ("(tie)" if len(tied) > 1 else ""))
            out("   %6g %4g | %7.3f | %9.5f %9.5f %9.5f | %9.5f %9.5f | %s / %s" % (
                D, lam, g, PQ, HQ, g, PR, HR, res[0], res[1]))

    # ------------------------------------------------------------------ F
    out("\n== F. notes.md l8 B recomputed: least cell width Delta* at which the honest Kepler law K is retained against N")
    out("   (c_K = c_N/1000, assumed), code-R silence cost exact (closed form), Delta* by bisection on [0.01', 10800']")
    out("   %-8s %7s | %8s | %10s %10s %10s | %10s %10s %10s" % ("body", "window", "eps*", "Q .01", "Q .1", "Q 1",
                                                             "R .01", "R .1", "R 1"))
    for body, W in (("Mercury", "100"), ("Mars", "12"), ("Mars", "2000"), ("Jupiter", "100"), ("Saturn", "2000"),
                    ("Moon", "1month")):
        e = Z["%s_%s_e_max" % (body, W)].astype(float)
        eps = float(np.max(np.abs(e)))
        x = (eps - e) / (2 * eps)
        cells = []
        for code in ("Q", "R"):
            for cN in (0.01, 0.1, 1.0):
                cK = cN / 1000

                def rateK(D):
                    q = min(2 * eps / D, 1.0)
                    g = math.log2(RANGE / D)
                    if code == "Q":
                        return q * g + (1 - q) * cK
                    tot = float(np.mean(honest_fine_closed(x, D / (2 * eps))))   # E cost = q * gamma_si
                    return tot + (1 - q) * cK

                lo, hi = 0.01, 10800.0
                if rateK(hi) >= cN:
                    cells.append("-")
                    continue
                if rateK(lo) < cN:
                    cells.append("<0.01'")
                    continue
                for _ in range(60):
                    mid = math.sqrt(lo * hi)
                    if rateK(mid) < cN:
                        hi = mid
                    else:
                        lo = mid
                cells.append("%.4g'" % hi)
        out("   %-8s %7s | %7.2f' | %s" % (body, W, eps, " ".join("%10s" % c for c in cells)))
    # monotonicity of K's code-R rate (Prop 6.2(c))
    nviol = 0
    for body, W in (("Mars", "12"), ("Moon", "1month"), ("Saturn", "2000")):
        e = Z["%s_%s_e_max" % (body, W)].astype(float)
        eps = float(np.max(np.abs(e)))
        x = (eps - e) / (2 * eps)
        vals = [float(np.mean(honest_fine_closed(x, D / (2 * eps)))) for D in np.logspace(-2, 4, 300)]
        nviol += int(np.sum(np.diff(vals) > 1e-12))
    out("   code-R expected cost of K non-increasing in Delta on a 300-point grid for 3 series: increases found = %d" % nviol)

    # ------------------------------------------------------------------ G
    out("\n== G. deterministic patches against random exceptions: bits per exception (distinct times t_j = j)")
    out("   literal: Elias-delta numeral of each patched index (mean over a Bernoulli(p) patch set of [1,n]);")
    out("   enumerative: log2(n+1) + log2 C(n,k) for the set; random: H2(p)/p (rate of the flag code)")
    out("   %8s %10s | %10s %12s %10s" % ("p", "n", "literal", "enumerative", "H2(p)/p"))
    for p in (0.1, 0.01, 0.001):
        for nn in (10 ** 3, 10 ** 5, 10 ** 7):
            js = np.nonzero(rng.random(nn) < p)[0] + 1
            k = js.size
            if k == 0:
                continue
            L = np.floor(np.log2(js)).astype(int)
            delta = L + 2 * np.floor(np.log2(L + 1)).astype(int) + 1
            enum = (math.log2(nn + 1) + (math.lgamma(nn + 1) - math.lgamma(k + 1) - math.lgamma(nn - k + 1)) / LN2) / k
            out("   %8g %10d | %10.2f %12.2f %10.2f" % (p, nn, float(np.mean(delta)), enum, float(H2(p)) / p))

    # ------------------------------------------------------------------ H
    out("\n== H. phases under SAI's pricing, exact theory-machine costs, distinct times; sinusoid eps*=1', Delta=60'")
    D, epsS = 60.0, 1.0
    g = math.log2(RANGE / D)
    l0, h, hN, lam = 200.0, 20.0, 2000.0, 1.0
    p = (2 / math.pi) * epsS / D
    qS = 2 * epsS / D
    betaS = LOG2E - float(np.mean(H2((1 - np.sin(2 * math.pi * rng.random(400000))) / 2)))
    mH = qS * betaS
    mP = float(H2(p)) + p * g
    out("   rates: m_0 = %.4f, m_P = H2(p) + p*gamma = %.4f (p = %.5f, 1/p = %.2f), m_H = q*beta = %.5f, m_N = 0" % (
        g, mP, p, 1 / p, mH))
    out("   predicted switch points: 0->E at lam*l0/gamma = %.1f; E->P at first refutation (mean %.1f); "
        "P->H near lam*h/(m_P - m_H) = %.0f; H->N near lam*(hN-h)/m_H = %.0f" % (
            lam * l0 / g, 1 / p, lam * h / (mP - mH), lam * (hN - h) / mH))
    nrun, nmax = 400, 120000
    seqs = {}
    tPH, tHN, tref = [], [], []
    hrng = np.random.default_rng(SEED + 11)
    for run in range(nrun):
        e = np.sin(2 * math.pi * hrng.random(nmax)) * epsS
        u = hrng.random(nmax)
        lo, hi = -u * D, (1 - u) * D               # cell of q (q at 0) in q-centred coordinates; f = q + e
        ref = ~((e >= lo) & (e < hi))             # exact law refutes
        blo, bhi = e - epsS, e + epsS
        ov = np.clip(np.minimum(hi, bhi) - np.maximum(lo, blo), 0, None)
        cH = -np.log2(np.maximum(ov / (2 * epsS), 1e-300))
        cH = np.where((blo >= lo) & (bhi < hi), 0.0, cH)
        n_ = np.arange(1, nmax + 1)
        k_ = np.cumsum(ref)
        J0 = g * n_
        JE = np.where(k_ == 0, lam * l0, np.inf)
        # Laplace mixture over the withdrawal rate: -log2 [ k!(n-k)!/(n+1)! ] + k*gamma, plus one bit in the law part
        JP = lam * (l0 + 1) + (gammaln(n_ + 2) - gammaln(k_ + 1) - gammaln(n_ - k_ + 1)) / LN2 + k_ * g
        JH = lam * (l0 + h) + np.cumsum(cH)
        JN = np.full(nmax, lam * (l0 + hN))
        Js = np.vstack([J0, JE, JP, JH, JN])
        names = np.array(["0", "E", "P", "H", "N"])
        win = names[np.argmin(Js, axis=0)]
        chg = np.nonzero(win[1:] != win[:-1])[0] + 1
        seq = "".join([win[0]] + [win[i] for i in chg])
        seqs[seq] = seqs.get(seq, 0) + 1
        fr = int(np.argmax(ref)) + 1 if ref.any() else None
        tref.append(fr)
        hidx = np.nonzero(win == "H")[0]
        if hidx.size:
            tPH.append(int(hidx[0]) + 1)
        nidx = np.nonzero(win == "N")[0]
        if nidx.size:
            tHN.append(int(nidx[0]) + 1)
    top = sorted(seqs.items(), key=lambda z: -z[1])[:6]
    out("   %d runs to n = %d; most frequent MAP sequences: %s" % (nrun, nmax, ", ".join("%s (%d)" % s for s in top)))
    out("   mean first refutation %.1f (1/p = %.1f); mean first time H is the MAP %.1f; mean first time N is the MAP"
        " %.0f (%d of %d runs reach N)" % (float(np.mean([t for t in tref if t])), 1 / p, float(np.mean(tPH)),
                                          float(np.mean(tHN)) if tHN else float("nan"), len(tHN), nrun))

    # ------------------------------------------------------------------ I
    out("\n== I. Prop 7.1 (exact rationals): R = rotation (3/5, 4/5), P = JR, eta = 1/100, A = R + eta P, a = (1, 0)")

    def mat(a, b, c, d):
        return ((Fr(a), Fr(b)), (Fr(c), Fr(d)))

    def mv(M, v):
        return (M[0][0] * v[0] + M[0][1] * v[1], M[1][0] * v[0] + M[1][1] * v[1])

    def mm(M, N):
        return tuple(tuple(sum(M[i][k] * N[k][j] for k in range(2)) for j in range(2)) for i in range(2))

    Rm = mat(Fr(3, 5), Fr(-4, 5), Fr(4, 5), Fr(3, 5))
    Jm = mat(0, -1, 1, 0)
    Pm = mm(Jm, Rm)
    eta = Fr(1, 100)
    Am = tuple(tuple(Rm[i][j] + eta * Pm[i][j] for j in range(2)) for i in range(2))
    a0 = (Fr(1), Fr(0))
    for W in (10, 100):
        xa, xr = a0, a0
        e2 = []
        for t in range(W + 1):
            d = (xa[0] - xr[0], xa[1] - xr[1])
            e2.append(d[0] ** 2 + d[1] ** 2)
            xa, xr = mv(Am, xa), mv(Rm, xr)
        emin2 = max(e2)
        tdep_mean = float(np.mean([math.sqrt(float(v)) for v in e2]))
        out("   W=%d: eps_min(W) = %.5f; time-dependent tolerances eps_t = |A^t a - R^t a|: eps_1 = %.5f, mean %.5f;"
            " ratio eps_min / mean eps_t = %.2f" % (W, math.sqrt(float(emin2)), math.sqrt(float(e2[1])), tdep_mean,
                                                    math.sqrt(float(emin2)) / tdep_mean))
        # point satisfying H^{eps_min} but violating the time-dependent law at t = 1
        Ra = mv(Rm, a0)
        shift = Fr(1, 2) * (Fr(int(math.isqrt(int(emin2 * 10 ** 12))), 10 ** 6))   # about eps_min/2, rational
        x1 = (Ra[0] + shift, Ra[1])
        in_H = (x1[0] - Ra[0]) ** 2 + (x1[1] - Ra[1]) ** 2 <= emin2
        in_tdep = (x1[0] - Ra[0]) ** 2 + (x1[1] - Ra[1]) ** 2 <= e2[1]
        out("     x_1 = R a + (%s, 0): satisfies H^eps_min at t=1: %s; satisfies the time-dependent bound at t=1: %s" % (
            shift, in_H, in_tdep))
    # model of H^{eps_min} that is a model of neither theory (W = 10): x_t = R^t a + (1/10^4, 0)
    W = 10
    xr, ok_H, eq_T0, eq_TN = a0, True, True, True
    xa = a0
    emin2 = Fr(0)
    pts = []
    for t in range(W + 1):
        d = (xa[0] - xr[0], xa[1] - xr[1])
        emin2 = max(emin2, d[0] ** 2 + d[1] ** 2)
        pts.append((xr, xa))
        xa, xr = mv(Am, xa), mv(Rm, xr)
    sh = (Fr(1, 10 ** 4), Fr(0))
    for (r_, a_) in pts:
        y = (r_[0] + sh[0], r_[1] + sh[1])
        ok_H &= (sh[0] ** 2 + sh[1] ** 2) <= emin2
        eq_T0 &= (y == r_)
        eq_TN &= (y == a_)
    out("   W=10: x_t = R^t a + (1/10^4, 0) satisfies H^eps_min: %s; is the T_0 trajectory: %s; is the T_N trajectory: %s"
        % (ok_H, eq_T0, eq_TN))

    # ------------------------------------------------------------------ J
    out("\n== J. Prop 5.5(b) read literally: 'K3 enters' as a comparison of law choices vs 'K3 is in the lambda-MAP'")

    def Jstar(ns, c, L, L3, k, s, lam, which):
        if which == "0":
            return c * sum(ns)
        kk = k if which == "L" else k - s
        base = lam * L + (lam * L3 if which == "L3" else 0.0)
        return base + sum(min(c * nb, lam * kk) for nb in ns)
    ns, c, L, L3, k, s, lam = [1, 1], 10.0, 1000.0, 1.0, 5.0, 4.0, 1.0
    out("   hand case (2 bodies, 1 obs each, c=10, L=1000, L3=1, k=5, s=4, lam=1): J*_0 = %g, J*_L = %g, J*_L+K3 = %g" % (
        Jstar(ns, c, L, L3, k, s, lam, "0"), Jstar(ns, c, L, L3, k, s, lam, "L"), Jstar(ns, c, L, L3, k, s, lam, "L3")))
    jr = np.random.default_rng(SEED + 5)
    same, cond_ok, lit_fail = 0, 0, 0
    for _ in range(20000):
        m = int(jr.integers(1, 7))
        ns = [int(v) for v in jr.integers(1, 60, size=m)]
        c = float(jr.uniform(1, 15))
        L = float(jr.uniform(10, 2000))
        L3 = float(jr.uniform(1, 300))
        k = float(jr.uniform(5, 120))
        s = float(jr.uniform(0.5, k - 0.5))
        lam = float(jr.choice([1.0, 1.5, 2.0, 4.0]))
        S1 = {b for b, nb in enumerate(ns) if c * nb > lam * k}
        S2 = {b for b, nb in enumerate(ns) if c * nb > lam * (k - s)}
        if S1 != S2:
            continue
        same += 1
        JL, JL3, J0 = Jstar(ns, c, L, L3, k, s, lam, "L"), Jstar(ns, c, L, L3, k, s, lam, "L3"), Jstar(
            ns, c, L, L3, k, s, lam, "0")
        pred = s * len(S1) > L3
        cond_ok += (pred == (JL3 < JL))
        if pred and not (JL3 < min(JL, J0)):
            lit_fail += 1
    out("   random cases with the same S under both law choices: %d; 'J*_L+K3 < J*_L iff s|S| > L3' holds in %d;"
        " cases with s|S| > L3 but K3 not in the lambda-MAP (the empty theory wins): %d" % (same, cond_ok, lit_fail))

    out("\n# runtime %.0f s" % (time.time() - t0))
    out("# done")
    with open(os.path.join(here, "l10_revision.out"), "w") as fh:
        fh.write("\n".join(OUT) + "\n")


if __name__ == "__main__":
    main()
