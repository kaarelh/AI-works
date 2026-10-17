"""rb2_sai_pricing.py -- Referee B, thread `laws`: is the honest law (uniform random completion inside the band)
really what SAI's own pricing (R/rand) selects?  The record (notes section 3.2, 3.6, 9.1, 10.2) compares
four forms: 0, P (exact law; exceptions completed uniformly on the whole circle), H (band [f-eps*, f+eps*],
completed uniformly), and tolerance laws with whole-circle exceptions.  M_A mixes ALL theory machines, so we add
two band-confined randomised theories that are equally short (law + band + O(1) bits):

  HY(rho):  with probability 1-rho emit q_t = f(t) (the exact law), otherwise a uniform point of the band
            ("exact except in a share rho of cases, and then within eps*");
  SH:       a point of the band drawn from a fixed density shaped like the error distribution
            (40-bin histogram fitted on the even-indexed sample times, evaluated on the odd-indexed ones,
            mixed 0.99/0.01 with uniform so that no cell gets mass 0).

Exact facts used (coarse regime Delta >= 2 eps*, notes Lemma 3.2 / 3.6): a datum's band lies in q's cell
unless a cell boundary falls inside the band (probability 2 eps*/Delta), and then the boundary's relative
position V in the band is uniform on [0,1].  For a band-confined completion with CDF G (relative coordinates,
f at 1/2, q at x = (eps* - e)/(2 eps*)), the datum's cost is 0 without a straddle and
-log2 G(V) (x < V) or -log2(1 - G(V)) (x > V) with one.  So in the coarse regime every band-confined law has
rate (2 eps*/Delta) * c_straddle, and the ranking among them does not depend on Delta.  Analytic local test
(derived in referee-B.md, issue 1): HY(1 - s) improves on H for small s iff
        E ln(1 + |e|/eps*) < 2 ln 2 - 1 = 0.3863.
Fine regime (Delta < 2 eps*): the cell is [x - u d, x + (1-u) d) in band units, d = Delta/(2 eps*), u uniform;
we average over 64 stratified u per sample time (deterministic).

Parts:
  A. synthetic errors (sinusoid pk = pi/2; peaked +-A on 5%; |e| ~ U[0,1]; |e| ~ Beta(1,3)): per-straddle costs
     of H (closed form beta_e and numerical), HY at its best rho, SH; the local test; P under R/rand at Delta=60'.
  B. the real Kepler residuals (minimax-fit series of checks/l4_residuals.npz, read only): per-straddle costs,
     best rho, local test, and at Delta in {1', 10', 60', 600', 1800'} the rates of P (R/rand), H, HY*, SH.
Seed 20261016 (only used for synthetic samples).  Writes rb2_sai_pricing.out next to itself.
"""
import math
import os
import sys
import time
import numpy as np

SEED = 20261016
OUT = []
RANGE = 21600.0
LN2 = math.log(2.0)
HERE = os.path.dirname(os.path.abspath(__file__))
RES = os.path.join(HERE, "..", "checks", "l4_residuals.npz")
NV = 4000                      # V-grid (midpoints) for the straddle integral
VG = (np.arange(NV) + 0.5) / NV


def out(s=""):
    OUT.append(s)
    print(s, flush=True)


def H2(x):
    x = np.clip(np.asarray(x, float), 1e-300, 1 - 1e-16)
    return -x * np.log2(x) - (1 - x) * np.log2(1 - x)


def straddle_cost(x, Gv):
    """E over x (array of q-positions in [0,1]) and V uniform of -log2 of the mass on q's side.
    Gv = G(V) on the grid VG.  Uses sorting: for each V, cost is -log2 G(V) * #(x<V) + -log2(1-G(V)) * #(x>V)."""
    xs = np.sort(x)
    nleft = np.searchsorted(xs, VG, side="left")          # number of x < V
    n = xs.size
    gl = -np.log2(np.clip(Gv, 1e-300, 1.0))
    gr = -np.log2(np.clip(1.0 - Gv, 1e-300, 1.0))
    return float(np.mean((nleft * gl + (n - nleft) * gr) / n))


def G_uniform():
    return VG.copy()


def G_hybrid(rho):
    return rho * VG + (1 - rho) * (VG > 0.5)


def hist_cdf(xfit, bins=40, mix=0.01):
    h, edges = np.histogram(xfit, bins=bins, range=(0.0, 1.0))
    dens = h / h.sum() * bins
    dens = (1 - mix) * dens + mix
    cdf_at_edges = np.concatenate([[0.0], np.cumsum(dens) / bins])
    cdf_at_edges = cdf_at_edges / cdf_at_edges[-1]
    dens = dens / (cdf_at_edges[-1] if cdf_at_edges[-1] > 0 else 1.0)

    def G(v):
        v = np.clip(np.asarray(v, float), 0.0, 1.0)
        i = np.minimum((v * bins).astype(int), bins - 1)
        return cdf_at_edges[i] + dens[i] * (v - i / bins)
    return G


def best_hybrid(x):
    """golden section on rho in [1e-6, 1]; also returns the rho = 1 (pure H) value."""
    def f(r):
        return straddle_cost(x, G_hybrid(r))
    a, b = 0.0, 1.0
    gr = (math.sqrt(5) - 1) / 2
    c, d = b - gr * (b - a), a + gr * (b - a)
    fc, fd = f(c), f(d)
    for _ in range(40):
        if fc < fd:
            b, d, fd = d, c, fc
            c = b - gr * (b - a)
            fc = f(c)
        else:
            a, c, fc = c, d, fd
            d = a + gr * (b - a)
            fd = f(d)
    r = (a + b) / 2
    vals = [(f(r), r), (f(1.0), 1.0)]
    return min(vals)


def local_test(e_over_eps):
    return float(np.mean(np.log(1 + np.abs(e_over_eps))))


def fine_rates(x, d, rho_list, Gsh, f_pos=0.5, nu=64):
    """fine/general regime, band units: cell [x - u d, x + (1-u) d), u stratified.  Returns dict of rates
    (bits per datum) for H (uniform), HY(rho) for rho in rho_list, SH (shape)."""
    u = (np.arange(nu) + 0.5) / nu
    X = x[:, None]
    lo = X - u[None, :] * d
    hi = X + (1 - u[None, :]) * d
    a, b = np.clip(lo, 0, 1), np.clip(hi, 0, 1)
    ov = np.maximum(b - a, 0.0)                            # uniform mass of the band inside q's cell
    fin = (lo <= f_pos) & (f_pos < hi)                     # f inside q's cell
    res = {"H": float(np.mean(-np.log2(np.maximum(ov, 1e-300))))}
    for r in rho_list:
        res[("HY", r)] = float(np.mean(-np.log2(np.maximum(r * ov + (1 - r) * fin, 1e-300))))
    res["SH"] = float(np.mean(-np.log2(np.clip(Gsh(b) - Gsh(a), 1e-300, 1.0))))
    return res


def P_randrate(x, d, g, nu=None):
    """exact law with uniform whole-circle exceptions (R/rand), best rho; band units as above (f at 1/2).
    Exact over the dither: Pr[f in q's cell | x] = max(0, 1 - |x - 1/2|/d); the cost is -log2(1-rho+rho s)
    if f is in q's cell and -log2(rho s) otherwise (s = 2^-gamma)."""
    pin = float(np.mean(np.maximum(0.0, 1.0 - np.abs(x - 0.5) / d)))
    s = 2.0 ** (-g)
    best = (math.inf, None)
    for lr in np.linspace(-9, 0, 901):
        r = 10.0 ** lr
        c = -pin * math.log2(1 - r + r * s) - (1 - pin) * math.log2(r * s)
        best = min(best, (c, r))
    return best


def main():
    t0 = time.time()
    rng = np.random.default_rng(SEED)
    out("# rb2_sai_pricing.py seed=%d python %s numpy %s" % (SEED, sys.version.split()[0], np.__version__))

    # ---------------- A
    out("\n== A. synthetic errors: per-straddle cost (bits) of band-confined completions, coarse regime")
    out("   H = uniform in band (the record's honest law); HY* = exact w.p. 1-rho else uniform in band, best rho;")
    out("   SH = completion shaped like the error distribution (split sample).  local test: HY beats H near rho=1")
    out("   iff E ln(1+|e|/eps*) < 2 ln 2 - 1 = %.4f" % (2 * LN2 - 1))
    m = 200_000
    t = rng.random(m)
    synth = {
        "sinusoid (pk=pi/2)": np.sin(2 * np.pi * t),
        "peaked +-1 on 5% (pk=20)": np.where(t < 0.025, 1.0, np.where((t >= 0.5) & (t < 0.525), -1.0, 0.0)),
        "|e|~U[0,1], random sign (pk=2)": (2 * rng.random(m) - 1),
        "|e|~Beta(1,3), random sign (pk=4)": rng.beta(1, 3, m) * rng.choice([-1, 1], m),
    }
    for name, e in synth.items():
        eps = float(np.max(np.abs(e)))
        x = (eps - e) / (2 * eps)
        beta_closed = math.log2(math.e) - float(np.mean(H2(x)))
        cH = straddle_cost(x, G_uniform())
        cHY, rho = best_hybrid(x)
        Gsh = hist_cdf(x[0::2])
        cSH = straddle_cost(x[1::2], Gsh(VG))
        lt = local_test(e / eps)
        out("   %-34s pk=%5.2f | H %.4f (closed form %.4f) | HY* %.4f at rho=%.3f | SH %.4f | E ln(1+|e|/eps*)=%.4f -> %s" % (
            name, eps / float(np.mean(np.abs(e))), cH, beta_closed, cHY, rho, cSH, lt,
            "HY improves" if lt < 2 * LN2 - 1 else "no local gain"))
    out("\n   rates at Delta = 60' (coarse), eps* = 1': P (R/rand, best rho) against H, HY*, SH (bits/datum)")
    D = 60.0
    g = math.log2(RANGE / D)
    for name, e in synth.items():
        eps = float(np.max(np.abs(e)))
        x = (eps - e) / (2 * eps)
        cP, rP = P_randrate(x[:50_000], D / (2 * eps), g, nu=256)
        q = 2 * eps / D
        cH = q * straddle_cost(x, G_uniform())
        cHY, rho = best_hybrid(x)
        Gsh = hist_cdf(x[0::2])
        cSH = q * straddle_cost(x[1::2], Gsh(VG))
        best = min((cP, "P"), (cH, "H"), (q * cHY, "HY*"), (cSH, "SH"))
        out("   %-34s P %.4f (rho=%.1e) | H %.4f | HY* %.4f | SH %.4f -> least: %s;  among the record's {P,H}: %s" % (
            name, cP, rP, cH, q * cHY, cSH, best[1], "H" if cH < cP else "P"))

    # ---------------- B
    out("\n== B. real Kepler residuals (checks/l4_residuals.npz, minimax fit, read only)")
    Z = np.load(RES, allow_pickle=False)
    order_b = ["Mercury", "Venus", "EMB", "Mars", "Jupiter", "Saturn", "Moon"]

    def sortkey(k):
        b, w = k.split("_")
        wv = {"1month": 1 / 12, "1year": 1.0, "18.6yr": 18.6}.get(w, None)
        return (order_b.index(b), float(w) if wv is None else wv)
    rows = sorted({k[:-2] for k in Z.files if k.endswith("_t")}, key=sortkey)
    out("   per-straddle costs (bits; coarse regime, ranking independent of Delta):")
    out("   %-8s %7s | %6s %6s | %7s %7s %6s %7s | %7s | %s" % ("body", "window", "eps*", "pk_mm", "H", "HY*", "rho*",
                                                              "SH", "Eln(1+)", "least"))
    nHY = nSH = 0
    summary = []
    for k in rows:
        b, w = k.split("_")
        e = Z[k + "_e_max"].astype(float)
        eps = float(np.max(np.abs(e)))
        x = (eps - e) / (2 * eps)
        cH = straddle_cost(x, G_uniform())
        cHY, rho = best_hybrid(x)
        Gsh = hist_cdf(x[0::2])
        cSH = straddle_cost(x[1::2], Gsh(VG))
        cH_odd = straddle_cost(x[1::2], G_uniform())
        lt = local_test(e / eps)
        nHY += cHY < cH - 1e-9
        nSH += cSH < cH_odd - 1e-9
        least = min((cH, "H"), (cHY, "HY*"), (cSH, "SH"))[1]
        summary.append((k, eps, x, e, Gsh, rho))
        out("   %-8s %7s | %6.2f %6.2f | %7.4f %7.4f %6.3f %7.4f | %7.4f | %s" % (
            b, w, eps, eps / float(np.mean(np.abs(e))), cH, cHY, rho, cSH, lt, least))
    out("   HY* strictly below H in %d of %d body-window pairs; SH below H (both on the odd half) in %d of %d" % (
        nHY, len(rows), nSH, len(rows)))
    # exact criterion (c(s) convex in s, so the local test at rho = 1 is global) and its Jensen corollary
    thr = 2 * LN2 - 1
    pk_thr = math.e / (4 - math.e)
    crit_bad = jensen_bad = 0
    for (k, eps, x, e, Gsh, rho) in summary:
        cH = straddle_cost(x, G_uniform())
        cHY, _ = best_hybrid(x)
        beats = cHY < cH - 1e-7
        lt = local_test(e / eps)
        crit_bad += beats != (lt < thr)
        pkmm = eps / float(np.mean(np.abs(e)))
        jensen_bad += (pkmm > pk_thr) and not beats
    out("   criterion 'HY(rho) beats H for some rho < 1 iff E ln(1+|e|/eps*) < 2 ln 2 - 1': mismatches %d of %d;"
        " Jensen corollary 'pk > e/(4-e) = %.4f implies HY beats H': violations %d" % (
            crit_bad, len(summary), pk_thr, jensen_bad))

    out("\n   rates (bits/datum) at several Delta: P = exact law with whole-circle random exceptions (R/rand, best rho),")
    out("   H, HY* (rho re-optimised per Delta over a grid), SH.  'rec' = winner among the record's {0, P, H};")
    out("   'all' = winner when HY and SH are added.")
    DELTAS = [1.0, 10.0, 60.0, 600.0, 1800.0]
    RHOS = [1.0, 0.95, 0.9, 0.8, 0.7, 0.6, 0.5, 0.4, 0.3, 0.2, 0.1, 0.05, 0.02, 0.01]
    flips = tot = 0
    for (k, eps, x, e, Gsh, rho) in summary:
        b, w = k.split("_")
        cells = []
        xs = x[1::2]
        cH_s = straddle_cost(xs, G_uniform())
        cHY_s = min(straddle_cost(xs, G_hybrid(rr)) for rr in RHOS)
        cSH_s = straddle_cost(xs, Gsh(VG))
        for D in DELTAS:
            g = math.log2(RANGE / D)
            d = D / (2 * eps)
            cP, _ = P_randrate(xs, d, g)
            if d >= 1.0:          # coarse regime: exact, rate = (2 eps*/Delta) * per-straddle cost
                q = 1.0 / d
                rH, hy, rSH, how = q * cH_s, q * cHY_s, q * cSH_s, "exact"
            else:                 # fine regime: 256 stratified dithers per sample time
                r = fine_rates(xs, d, RHOS, Gsh, nu=256)
                rH, hy, rSH, how = r["H"], min(r[("HY", rr)] for rr in RHOS), r["SH"], "strat"
            rec = min((g, "0"), (cP, "P"), (rH, "H"))[1]
            allw = min((g, "0"), (cP, "P"), (rH, "H"), (hy, "HY"), (rSH, "SH"))
            tot += 1
            flips += allw[1] != rec
            cells.append("D=%-4g %s H %.4f HY %.4f SH %.4f: %s->%s" % (D, how[0], rH, hy, rSH, rec, allw[1]))
        out("   %-8s %7s | " % (b, w) + " | ".join(cells))
    out("   cells where adding HY/SH changes the winner: %d of %d" % (flips, tot))

    out("\n# runtime %.0f s" % (time.time() - t0))
    out("# done")
    with open(os.path.join(HERE, "rb2_sai_pricing.out"), "w") as fh:
        fh.write("\n".join(OUT) + "\n")


if __name__ == "__main__":
    main()
