"""p7_kepler_effects.py -- track `purpose`, revision (referee A, M6; referee B, m1, m2): effect sizes and estimator
dependence of the T4(b) findings on the real Kepler residual series.

Seed 20261019 (random half-samples for the standard errors; nothing else is random).  Reads p4_allfits.npz (four
fits F3, L2, L1, Linf of one fixed Kepler ellipse, 39 body-window series, 8000 uniform times each, longitude errors in
arcmin; written by p4_allfits.py).  Writes p7_kepler_effects.out next to itself.  Run time: about 2 minutes.

Estimator (independent of the developer's SH machine and of referee A's bootstrap):
  r(D)  = exact rate of the CALIBRATED completion for the empirical error law at cell width D, i.e.
          H(C_U(e) | U) = h(e + V_D) - log D (Lemma T3.2) computed exactly for the atomic empirical law by a sweep;
          in the coarse regime (D >= range of e) it equals (1/D) * int H2(F_emp) = Dcal / D.
  SE    = half-sampling (delete-n/2 jackknife) standard error of the paired difference between two fits: the standard
          deviation of the difference over K = 40 random halves of the times (the same halves for all fits).
  A pair is DECIDED at D if |difference| > 2 SE (a stability heuristic, not a test).  A (series, D) cell is RELIABLE
  if there are at least 20 samples per cell width over the range of the errors (referee A's rule).
Relative effect: difference / mean of the two rates.  In the coarse regime r = Dcal/D, so the relative effect is the
relative difference in the dispersion Dcal = int H2(F), whatever D is.
"""
import itertools
import math
import os

import numpy as np

SEED = 20261019
HERE = os.path.dirname(os.path.abspath(__file__))
OUT = []
DELTAS = [0.1, 1.0, 10.0, 60.0, 1800.0]
FITS = ["F3", "L2", "L1", "Linf"]
K = 40


def out(s=""):
    OUT.append(s)
    print(s, flush=True)


def rate(e, D):
    """exact H(C_U(e)|U) in bits for the empirical law of e (equal weights), cell width D"""
    n = e.size
    ev = np.concatenate([e, e + D])
    dw = np.concatenate([np.ones(n), -np.ones(n)])
    o = np.argsort(ev, kind="mergesort")
    ev, dw = ev[o], dw[o]
    c = np.cumsum(dw)[:-1] / n
    seg = np.diff(ev)
    m = c > 0.5 / n
    return float(np.sum(seg[m] * c[m] * np.log2(1.0 / c[m]))) / D


def main():
    rng = np.random.default_rng(SEED)
    Z = np.load(os.path.join(HERE, "p4_allfits.npz"))
    order_b = ["Mercury", "Venus", "EMB", "Mars", "Jupiter", "Saturn", "Moon"]

    def sortkey(k):
        b, w = k.split("_")
        wv = {"1month": 1 / 12, "1year": 1.0, "18.6yr": 18.6}.get(w, None)
        return (order_b.index(b), float(w) if wv is None else wv)
    series = sorted({k[:-2] for k in Z.files if k.endswith("_t")}, key=sortkey)
    out("# p7_kepler_effects.py seed=%d numpy %s; %d series; fits %s; widths %s; K = %d half-samples" % (
        SEED, np.__version__, len(series), FITS, DELTAS, K))
    out("")
    res = {}
    for s in series:
        E = {f: np.asarray(Z["%s_%s" % (s, f)], float) for f in FITS}
        n = E["F3"].size
        halves = [rng.permutation(n)[: n // 2] for _ in range(K)]
        st = {}
        for f in FITS:
            e = E[f]
            st[f] = dict(max=float(np.max(np.abs(e))), rms=float(np.sqrt(np.mean(e * e))),
                         mae=float(np.mean(np.abs(e))), sd=float(np.std(e)), mean=float(np.mean(e)),
                         rng=float(np.ptp(e)),
                         r={D: rate(e, D) for D in DELTAS},
                         rh={D: np.array([rate(e[h], D) for h in halves]) for D in DELTAS})
        rel = {D: (n * D / max(st[f]["rng"] for f in FITS) >= 20) for D in DELTAS}
        res[s] = (st, rel)
    # ---------------------------------------------------------------- per-pair decisions
    pairs = []
    for s in series:
        st, rel = res[s]
        for f, g in itertools.combinations(FITS, 2):
            row = {"s": s, "f": f, "g": g}
            for D in DELTAS:
                d = st[f]["r"][D] - st[g]["r"][D]
                se = float(np.std(st[f]["rh"][D] - st[g]["rh"][D]))
                mean = 0.5 * (st[f]["r"][D] + st[g]["r"][D])
                dec = rel[D] and abs(d) > 2 * se
                row[D] = (d, se, d / mean if mean > 0 else 0.0, dec)
            pairs.append(row)
    out("== 1. reliability: series with fewer than 20 samples per cell at 0.1': %s" % ", ".join(
        s for s in series if not res[s][1][0.1]))
    out("   (all series are reliable at 1' and above)" if all(res[s][1][1.0] for s in series) else
        "   unreliable at 1': %s" % ", ".join(s for s in series if not res[s][1][1.0]))
    out("")
    out("== 2. fit pairs whose ranking by the calibrated rate reverses between two cell widths (both decided)")
    flips = []
    for p in pairs:
        dec = [(D, p[D]) for D in DELTAS if p[D][3]]
        signs = {np.sign(v[0]) for _, v in dec}
        if len(signs) == 2:
            flips.append(p)
    ends = [p for p in flips if p[0.1][3] and p[1800.0][3] and np.sign(p[0.1][0]) != np.sign(p[1800.0][0])]
    out("   reversal between any two of the widths %s: %d pairs; between 0.1' and 1800': %d pairs" % (
        DELTAS, len(flips), len(ends)))
    out("   %-13s %-4s %-4s | %s" % ("series", "f", "g", " | ".join("%7s: diff (rel) [2SE]" % ("%g'" % D)
                                                                for D in DELTAS)))
    for p in flips:
        cells = []
        for D in DELTAS:
            d, se, r_, dec = p[D]
            cells.append("%+9.5f (%+6.2f%%)%s" % (d, 100 * r_, "*" if dec else " "))
        out("   %-13s %-4s %-4s | %s" % (p["s"], p["f"], p["g"], " | ".join(cells)))
    out("   (* = decided; diff = r(f) - r(g) in bits per datum; rel = diff / mean rate)")
    for thr in [0.001, 0.01, 0.05]:
        k = sum(1 for p in flips if min(abs(p[D][2]) for D in DELTAS if p[D][3]) >= thr)
        out("   reversals whose every decided difference is at least %.1f%% of the rate: %d" % (100 * thr, k))
    out("")
    # ---------------------------------------------------------------- winners
    out("== 3. significantly best fit by the calibrated rate (decided against every other fit) vs classical winners")
    for D in [0.1, 1800.0]:
        cnt = dict(decided=0, mx=0, rms=0, mae=0, none=[])
        for s in series:
            st, rel = res[s]
            if not rel[D]:
                continue
            best = min(FITS, key=lambda f: st[f]["r"][D])
            ok = True
            for g in FITS:
                if g == best:
                    continue
                d = st[best]["r"][D] - st[g]["r"][D]
                se = float(np.std(st[best]["rh"][D] - st[g]["rh"][D]))
                if not (d < -2 * se):
                    ok = False
            if not ok:
                continue
            cnt["decided"] += 1
            wmax = min(FITS, key=lambda f: st[f]["max"])
            wrms = min(FITS, key=lambda f: st[f]["rms"])
            wmae = min(FITS, key=lambda f: st[f]["mae"])
            cnt["mx"] += best == wmax
            cnt["rms"] += best == wrms
            cnt["mae"] += best == wmae
            if best not in (wmax, wrms, wmae):
                second = sorted(FITS, key=lambda f: st[f]["r"][D])[1]
                cnt["none"].append("%s(%s; vs %s: rate %.5f vs %.5f, rel %.3f%%; RMS %.5f vs %.5f, rel %.3f%%)" % (
                    s, best, second, st[best]["r"][D], st[second]["r"][D],
                    100 * (st[second]["r"][D] - st[best]["r"][D]) / st[second]["r"][D],
                    st[best]["rms"], st[second]["rms"], 100 * (st[best]["rms"] - st[second]["rms"]) / st[second]["rms"]))
        out("   %g': decided %d | =max %d | =rms %d | =mae %d | none %d" % (
            D, cnt["decided"], cnt["mx"], cnt["rms"], cnt["mae"], len(cnt["none"])))
        for x in cnt["none"]:
            out("      none: %s" % x)
    out("")
    # ---------------------------------------------------------------- coarse dispersion vs RMS / SD / max
    out("== 4. the coarse calibrated ranking (Dcal = int H2(F_emp), decided at 1800') against error-size criteria")
    for crit in ["max", "rms", "sd", "mae"]:
        dis, gaps_d, gaps_a = 0, [], []
        for p in pairs:
            d, se, r_, dec = p[1800.0]
            if not dec:
                continue
            st = res[p["s"]][0]
            cf, cg = st[p["f"]][crit], st[p["g"]][crit]
            relgap = abs(cf - cg) / max(cf, cg)
            if np.sign(d) != np.sign(cf - cg):
                dis += 1
                gaps_d.append(relgap)
            else:
                gaps_a.append(relgap)
        ndec = len(gaps_d) + len(gaps_a)
        out("   %-4s: disagrees on %3d of %3d decided pairs; median relative %s gap: disagreeing %.2e, agreeing %.2e" % (
            crit, dis, ndec, crit, np.median(gaps_d) if gaps_d else float("nan"), np.median(gaps_a)))
    out("")
    # ---------------------------------------------------------------- referee numbers
    out("== 5. numbers quoted by the referees, recomputed")
    for s, fs in [("Mars_30", ["F3", "L2"]), ("Mercury_100", ["F3", "L2"]), ("Saturn_100", FITS),
                  ("Jupiter_12", ["F3", "L2", "L1"])]:
        st = res[s][0]
        for f in fs:
            out("   %-12s %-4s mean %+8.4f sd %9.5f rms %9.5f max %8.3f | r(0.1') %8.4f r(1') %8.4f r(10') %8.5f"
                " | Dcal = 1800' * r(1800') %9.5f" % (s, f, st[f]["mean"], st[f]["sd"], st[f]["rms"], st[f]["max"],
                                                    st[f]["r"][0.1], st[f]["r"][1.0], st[f]["r"][10.0],
                                                    1800.0 * st[f]["r"][1800.0]))
    out("")
    out("# done")
    with open(os.path.join(HERE, "p7_kepler_effects.out"), "w") as fh:
        fh.write("\n".join(OUT) + "\n")


if __name__ == "__main__":
    main()
