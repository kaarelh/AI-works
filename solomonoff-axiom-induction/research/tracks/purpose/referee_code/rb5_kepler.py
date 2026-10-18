"""rb5_kepler.py -- referee B, track `purpose`, target T4(b) (independent code; no code copied from checks/).

Reads ../../laws/checks/l4_residuals.npz (two fits per series: least max = 'mm', least mean |e| = 'mn') and
../checks/p4_allfits.npz (four fits F3, L2, L1, Linf; written by the developer's p4_allfits.py, whose re-run is
compared separately).  Writes rb5_kepler.out next to itself; rb5_kepler_cache.npz is a restart cache (per-series
results), deleted at the end of a complete run (about 8 minutes from scratch).

Seeds: 20261018 + s (s = 0..4) for my own half splits; the developer's main split (seed 20261017) is also run once,
to compare my SH implementation with the developer's numbers.

Machines and criteria (errors e in arcmin; lower is better):
  max, rms, mae                         the classical criteria
  Dcal = int H2(F_hat(t)) dt            plug-in calibrated coarse cost (T3.3(a)): in the coarse regime the ideal
                                        (calibrated band-confined) rate is Dcal / Delta, so Dcal ranks fits there
  SH_B(Delta)                           a band-confined B-bin histogram machine: band [-eps, eps], eps = 1.01 max|e|
                                        (as in the paper), histogram fitted on the training half with add-1/2
                                        smoothing, CDF linear within bins; expected cost over the dither on the test
                                        half: exact-by-quadrature in the coarse regime (Delta >= 2 eps), midpoint rule
                                        with 200 dither points otherwise.  B = 40 (the paper's) and B = 160.
  CVH_B                                 held-out cross-entropy of the B-bin histogram density (the Delta -> 0 limit
                                        of SH_B + log2 Delta), B = 40, 160, 640.
Significance of an SH difference between two fits (as the developer's rule): |paired mean| > 2 paired SE on the
main split and the same sign on all 5 splits.
"""
import itertools
import math
import os
import sys
import time

import numpy as np

SEED = 20261018
DEV_SEED = 20261017
HERE = os.path.dirname(os.path.abspath(__file__))
LAWS = os.path.join(HERE, "..", "..", "laws", "checks", "l4_residuals.npz")
ALLF = os.path.join(HERE, "..", "checks", "p4_allfits.npz")
CACHE = os.path.join(HERE, "rb5_kepler_cache.npz")
DELTAS = [0.1, 0.3, 1.0, 3.0, 10.0, 30.0, 60.0, 120.0, 300.0, 600.0, 1800.0]
FITS = ["F3", "L2", "L1", "Linf"]
NSPLIT = 5
NR = 200
OUT = []


def out(s=""):
    OUT.append(s)
    print(s, flush=True)


def H2(p):
    p = np.asarray(p, float)
    with np.errstate(divide="ignore", invalid="ignore"):
        v = -p * np.log2(p) - (1 - p) * np.log2(1 - p)
    return np.where((p > 0) & (p < 1), v, 0.0)


def Dcal(e):
    x = np.sort(np.asarray(e, float))
    n = x.size
    return float(np.sum(np.diff(x) * H2(np.arange(1, n) / n)))


class Hist:
    def __init__(self, etrain, eps, B):
        self.eps, self.B = eps, B
        self.edges = np.linspace(-eps, eps, B + 1)
        cnt, _ = np.histogram(etrain, bins=self.edges)
        p = (cnt + 0.5) / (cnt.sum() + 0.5 * B)
        self.p = p
        self.cum = np.concatenate([[0.0], np.cumsum(p)])
        self.cum[-1] = 1.0
        self.w = 2 * eps / B

    def G(self, x):
        return np.interp(x, self.edges, self.cum)

    def dens(self, x):
        i = np.clip(((x + self.eps) / self.w).astype(int), 0, self.B - 1)
        return self.p[i] / self.w

    def cost(self, etest, Delta):
        eps = self.eps
        if Delta >= 2 * eps:
            m = 20000
            t = -eps + (np.arange(m) + 0.5) * (2 * eps / m)
            G = self.G(t)
            a = -np.log2(np.maximum(1 - G, 1e-300))          # grid point below e: mass 1 - G(t)
            b = -np.log2(np.maximum(G, 1e-300))              # grid point above e: mass G(t)
            h = 2 * eps / m
            A = np.concatenate([[0.0], np.cumsum(a) * h])    # int_{-eps}^{t_k} a
            Bt = np.concatenate([[0.0], np.cumsum(b[::-1]) * h])[::-1]   # int_{t_k}^{eps} b
            grid = np.linspace(-eps, eps, m + 1)
            return (np.interp(etest, grid, A) + np.interp(etest, grid, Bt)) / Delta
        r = (np.arange(NR) + 0.5)[None, :] * (Delta / NR)
        lo = np.maximum(etest[:, None] - r, -eps)
        hi = np.minimum(etest[:, None] - r + Delta, eps)
        mass = self.G(hi) - self.G(lo)
        return np.mean(-np.log2(np.maximum(mass, 1e-300)), axis=1)


def split(n, seed):
    idx = np.random.default_rng(seed).permutation(n)
    return idx[: n // 2], idx[n // 2:]


def series_keys(Z):
    order_b = ["Mercury", "Venus", "EMB", "Mars", "Jupiter", "Saturn", "Moon"]
    def sk(k):
        b, w = k.split("_")
        wv = {"1month": 1 / 12, "1year": 1.0, "18.6yr": 18.6}.get(w)
        return (order_b.index(b), float(w) if wv is None else wv)
    return sorted({k[:-2] for k in Z.files if k.endswith("_t")}, key=sk)


def compute(A, L4, keys):
    """per series, per fit: classical criteria, Dcal, SH_40 and SH_160 per-test-point costs on 5 splits (stored as
    means and the main-split per-point arrays), CVH_B; plus SH_40 on the developer's split (means)."""
    res = {}
    if os.path.exists(CACHE):
        C = np.load(CACHE, allow_pickle=True)
        res = C["res"].item()
        out("   (restart: %d series restored from cache)" % len(res))
    t0 = time.time()
    for k in keys:
        if k in res:
            continue
        r = {}
        for f in FITS:
            e = A[k + "_" + f].astype(float)
            n = e.size
            m = float(np.max(np.abs(e)))
            eps = 1.01 * m
            d = {"max": m, "rms": float(np.sqrt(np.mean(e * e))), "mae": float(np.mean(np.abs(e))), "Dcal": Dcal(e)}
            for B in (40, 160):
                means = np.zeros((NSPLIT, len(DELTAS)))
                main = None
                for s in range(NSPLIT):
                    tr, te = split(n, SEED + s)
                    hst = Hist(e[tr], eps, B)
                    cs = [hst.cost(e[te], D) for D in DELTAS]
                    means[s] = [c.mean() for c in cs]
                    if s == 0:
                        main = np.array(cs, dtype=np.float32)
                d["SH%d" % B] = means
                d["SH%d_main" % B] = main
            tr, te = split(n, DEV_SEED)
            hst = Hist(e[tr], eps, 40)
            d["SH40_dev"] = np.array([hst.cost(e[te], D).mean() for D in DELTAS])
            tr, te = split(n, SEED)
            for B in (40, 160, 640):
                hst = Hist(e[tr], eps, B)
                d["CVH%d" % B] = float(np.mean(-np.log2(hst.dens(e[te]))))
            r[f] = d
        res[k] = r
        np.savez(CACHE, res=np.array(res, dtype=object))
        out("   %-14s done (%.0f s)" % (k, time.time() - t0))
    return res


def sig_sign(r, f, g, crit, i):
    """significant sign of SH difference f - g at cell width index i: +1 (f costlier), -1, or 0"""
    dd = r[f][crit + "_main"][i].astype(float) - r[g][crit + "_main"][i].astype(float)
    m, se = float(dd.mean()), float(dd.std(ddof=1) / math.sqrt(dd.size))
    same = all(np.sign(r[f][crit][s][i] - r[g][crit][s][i]) == np.sign(m) for s in range(NSPLIT))
    return int(np.sign(m)) if (abs(m) > 2 * se and same) else 0


def main():
    out("# rb5_kepler.py seed=%d (dev split %d) numpy %s; fits %s; deltas %s" % (SEED, DEV_SEED, np.__version__, FITS, DELTAS))
    L4 = np.load(LAWS)
    A = np.load(ALLF)
    keys = series_keys(L4)
    # ---- 0. identity of the saved two fits with the four-fit file, by my own selection rule
    out("\n== 0. l4_residuals.npz against p4_allfits.npz: the saved 'minimax' and 'mean' series are the four-fit")
    out("   series with least max |e| and least mean |e| (my selection)")
    sel = {}
    bad = 0
    for k in keys:
        es = {f: A[k + "_" + f] for f in FITS}
        fmm = min(FITS, key=lambda f: float(np.max(np.abs(es[f].astype(float)))))
        fmn = min(FITS, key=lambda f: float(np.mean(np.abs(es[f].astype(float)))))
        ok = np.array_equal(L4[k + "_e_max"], es[fmm]) and np.array_equal(L4[k + "_e_mean"], es[fmn])
        ok = ok and np.array_equal(L4[k + "_t"], A[k + "_t"])
        bad += (not ok)
        sel[k] = (fmm, fmn)
    out("   %d series; mismatches: %d; series where the two saved fits coincide: %s" % (
        len(keys), bad, ", ".join(k for k in keys if sel[k][0] == sel[k][1])))
    out("\n== computing (cached per series)")
    res = compute(A, L4, keys)

    # ---- 1. reproduction of the developer's SH numbers on the developer's split
    out("\n== 1. my SH_40 on the developer's split (seed %d) vs the developer's printed SH rates (p4_kepler_allfits.out)" % DEV_SEED)
    devout = os.path.join(HERE, "..", "checks", "p4_kepler_allfits.out")
    dev = {}
    cur = None
    for line in open(devout):
        s = line.strip()
        if s and s.split()[0] in keys and len(s.split()) == 1:
            cur = s.split()[0]
        elif cur and s.split() and s.split()[0] in FITS and "SH:" in s:
            dev[(cur, s.split()[0])] = [float(x) for x in s.split("SH:")[1].split()]
    diffs = [abs(res[k][f]["SH40_dev"][i] - dev[(k, f)][i]) for (k, f) in dev for i in range(len(DELTAS))]
    rel = [abs(res[k][f]["SH40_dev"][i] - dev[(k, f)][i]) / max(dev[(k, f)][i], 1e-9)
           for (k, f) in dev for i in range(len(DELTAS))]
    out("   %d (series, fit) rows parsed; max |mine - developer| = %.2e bits, max relative %.2e (dither quadrature 200 vs"
        " 256 points; coarse by quadrature vs closed form)" % (len(dev), max(diffs), max(rel)))

    # ---- 2. two-fit analysis (mm vs mn) with my splits
    out("\n== 2. two saved fits (minimax 'mm' vs mean 'mn'), my splits")
    nd, rms_mn = 0, 0
    tally = {D: {"mm": 0, "mn": 0, "und": 0, "agree_rms": 0} for D in (0.1, 1800.0)}
    flips40 = []
    for k in keys:
        fmm, fmn = sel[k]
        if fmm == fmn:
            continue
        nd += 1
        r = res[k]
        rms_mn += r[fmn]["rms"] < r[fmm]["rms"]
        for D in (0.1, 1800.0):
            i = DELTAS.index(D)
            sgn = sig_sign(r, fmm, fmn, "SH40", i)
            if sgn == 0:
                tally[D]["und"] += 1
            else:
                win = "mm" if sgn < 0 else "mn"
                tally[D][win] += 1
                rms_win = "mm" if r[fmm]["rms"] < r[fmn]["rms"] else "mn"
                tally[D]["agree_rms"] += (win == rms_win)
        sg = [sig_sign(r, fmm, fmn, "SH40", i) for i in range(len(DELTAS))]
        if len(set(x for x in sg if x != 0)) > 1:
            flips40.append((k, sg))
    out("   %d series with distinct fits; RMS prefers the mean fit in %d (developer: 24 of 37)" % (nd, rms_mn))
    for D in (0.1, 1800.0):
        t = tally[D]
        out("   SH40 at %g': decided %d (mm %d, mn %d), undecided %d; agrees with RMS in %d of the decided" % (
            D, t["mm"] + t["mn"], t["mm"], t["mn"], t["und"], t["agree_rms"]))
    out("   (developer: 0.1': 23 decided, mm 14, mn 9, agree RMS 15; 1800': 19 decided, 9 and 10, agree RMS 17)")
    out("   series whose SH40 ranking flips significantly with Delta: %s" % (
        "; ".join("%s %s" % (k, "".join({1: "+", -1: "-", 0: "."}[x] for x in sg)) for k, sg in flips40) or "none"))

    # ---- 3. four fits: disagreement matrix, including the calibrated coarse ranking Dcal and the 160-bin machine
    out("\n== 3. four fits: number of fit pairs on which two criteria disagree (SH: significant decisions only)")
    crits = ["max", "rms", "mae", "Dcal", "CVH40", "CVH160", "CVH640"]
    shc = [("SH40", 0.1), ("SH40", 10.0), ("SH40", 1800.0), ("SH160", 0.1), ("SH160", 10.0), ("SH160", 1800.0)]
    names = crits + ["%s@%g" % c for c in shc]
    signs = {nm: [] for nm in names}
    npairs = 0
    und = {c: 0 for c in shc}
    for k in keys:
        r = res[k]
        uniq = []
        for f in FITS:
            if not any(np.array_equal(A[k + "_" + f], A[k + "_" + g]) for g in uniq):
                uniq.append(f)
        for f, g in itertools.combinations(uniq, 2):
            npairs += 1
            for c in crits:
                signs[c].append(int(np.sign(r[f][c] - r[g][c])))
            for (c, D) in shc:
                s = sig_sign(r, f, g, c, DELTAS.index(D))
                und[(c, D)] += (s == 0)
                signs["%s@%g" % (c, D)].append(s)
    out("   %d fit pairs" % npairs)
    out("   %10s %s" % ("", " ".join("%10s" % nm for nm in names)))
    for a in names:
        row = []
        for b in names:
            if a == b:
                row.append("%10s" % "-")
            else:
                row.append("%10d" % sum(1 for x, y in zip(signs[a], signs[b]) if x != 0 and y != 0 and x != y))
        out("   %10s %s" % (a, " ".join(row)))
    out("   undecided SH comparisons: %s" % ", ".join("%s@%g: %d" % (c, D, und[(c, D)]) for (c, D) in shc))

    # ---- 4. the 40-bin artefact test: where SH40 and SH160 are both decided, how often do they disagree?
    out("\n== 4. bin-count sensitivity of SAI's (SH) ranking of fits, all 11 cell widths")
    tot_both, tot_dis, by_D = 0, 0, []
    for i, D in enumerate(DELTAS):
        both = dis = 0
        coarse_vs_D = [0, 0]
        for k in keys:
            r = res[k]
            for f, g in itertools.combinations(FITS, 2):
                if np.array_equal(A[k + "_" + f], A[k + "_" + g]):
                    continue
                s40, s160 = sig_sign(r, f, g, "SH40", i), sig_sign(r, f, g, "SH160", i)
                if s40 and s160:
                    both += 1
                    dis += (s40 != s160)
                if s40 and D >= 2.02 * max(r[f]["max"], r[g]["max"]):
                    coarse_vs_D[0] += 1
                    coarse_vs_D[1] += (s40 != int(np.sign(r[f]["Dcal"] - r[g]["Dcal"])))
        by_D.append((D, both, dis, coarse_vs_D))
        tot_both += both
        tot_dis += dis
    for D, both, dis, cvd in by_D:
        out("   Delta %7g': SH40 and SH160 both decided on %3d pairs, opposite on %3d | coarse pairs: SH40 decided %3d,"
            " opposite to the calibrated Dcal ranking on %3d" % (D, both, dis, cvd[0], cvd[1]))
    out("   total: both decided %d, opposite %d" % (tot_both, tot_dis))

    # ---- 5. flips with the cell width, for SH40 and SH160
    out("\n== 5. fit pairs whose SH ranking flips significantly with the cell width")
    for crit in ("SH40", "SH160"):
        fl = []
        for k in keys:
            r = res[k]
            for f, g in itertools.combinations(FITS, 2):
                if np.array_equal(A[k + "_" + f], A[k + "_" + g]):
                    continue
                sg = [sig_sign(r, f, g, crit, i) for i in range(len(DELTAS))]
                if len(set(x for x in sg if x != 0)) > 1:
                    fl.append((k, f, g, sg))
        out("   %s: %d pairs (developer, SH40 on its splits: 16)" % (crit, len(fl)))
        for k, f, g, sg in fl:
            out("      %-14s %-4s vs %-4s %s" % (k, f, g, "".join({1: "+", -1: "-", 0: "."}[x] for x in sg)))
    # flips under SH40 that SH160 does not confirm
    out("   (string: sign of SH(f) - SH(g) per cell width 0.1'..1800'; '.' undecided)")

    # ---- 6. winners: SH best fit equal to none of the classical winners
    out("\n== 6. SH winner (significantly better than every other fit) vs the classical winners, per cell width")
    for crit in ("SH40", "SH160"):
        for D in (0.1, 1800.0):
            i = DELTAS.index(D)
            dec = eqmax = eqrms = eqmae = none = 0
            nones = []
            for k in keys:
                r = res[k]
                uniq = []
                for f in FITS:
                    if not any(np.array_equal(A[k + "_" + f], A[k + "_" + g]) for g in uniq):
                        uniq.append(f)
                if len(uniq) < 2:
                    continue
                cand = min(uniq, key=lambda f: r[f][crit][0][i])
                if all(sig_sign(r, cand, g, crit, i) == -1 for g in uniq if g != cand):
                    dec += 1
                    w = {c: min(uniq, key=lambda f: r[f][c]) for c in ("max", "rms", "mae")}
                    eqmax += cand == w["max"]
                    eqrms += cand == w["rms"]
                    eqmae += cand == w["mae"]
                    if cand not in w.values():
                        none += 1
                        nones.append("%s(%s)" % (k, cand))
            out("   %s at %g': decided %d | =max %d | =rms %d | =mae %d | none %d: %s" % (
                crit, D, dec, eqmax, eqrms, eqmae, none, ", ".join(nones)))
    out("   (developer, SH40: 0.1': 15 decided, 6/3/6, none 4; 1800': 10 decided, 3/6/2, none 3)")

    # ---- 7. Dcal winner vs classical winners (the ideal calibrated coarse pricing, no histogram)
    out("\n== 7. calibrated coarse pricing (Dcal, plug-in on all 8000 times): winner vs classical winners")
    dec = eqmax = eqrms = eqmae = none = 0
    nones = []
    for k in keys:
        r = res[k]
        uniq = []
        for f in FITS:
            if not any(np.array_equal(A[k + "_" + f], A[k + "_" + g]) for g in uniq):
                uniq.append(f)
        if len(uniq) < 2:
            continue
        dec += 1
        cand = min(uniq, key=lambda f: r[f]["Dcal"])
        w = {c: min(uniq, key=lambda f: r[f][c]) for c in ("max", "rms", "mae")}
        eqmax += cand == w["max"]
        eqrms += cand == w["rms"]
        eqmae += cand == w["mae"]
        if cand not in w.values():
            none += 1
            nones.append("%s(%s)" % (k, cand))
    out("   %d series: Dcal winner = max winner %d, = rms winner %d, = mae winner %d, none %d: %s" % (
        dec, eqmax, eqrms, eqmae, none, ", ".join(nones)))
    # relative gaps: how different are the fits under Dcal?
    gaps = []
    for k in keys:
        v = sorted(res[k][f]["Dcal"] for f in FITS)
        if v[1] > v[0]:
            gaps.append((v[1] - v[0]) / v[0])
    out("   relative gap between the best and second-best Dcal per series: median %.4f, min %.2e, max %.4f" % (
        float(np.median(gaps)), min(gaps), max(gaps)))

    # ---- 8. is the disagreement bias absorption, or near-ties?  location-free dispersions and gap sizes
    out("\n== 8. calibrated coarse ranking (Dcal) against location-free dispersions, and the size of the disagreements")
    disp = {"sd": np.std, "mad_med": lambda e: np.mean(np.abs(e - np.median(e))),
            "halfrange": lambda e: (e.max() - e.min()) / 2,
            "rms": lambda e: np.sqrt(np.mean(e * e)), "mae": lambda e: np.mean(np.abs(e)), "max": lambda e: np.abs(e).max()}
    agree = {x: 0 for x in disp}
    gapstats = {"rms": ([], []), "max": ([], [])}
    npair = 0
    for k in keys:
        es = {f: A[k + "_" + f].astype(float) for f in FITS}
        for f, g in itertools.combinations(FITS, 2):
            if np.array_equal(es[f], es[g]):
                continue
            npair += 1
            d1, d2 = res[k][f]["Dcal"], res[k][g]["Dcal"]
            for x, fn in disp.items():
                v1, v2 = fn(es[f]), fn(es[g])
                same = np.sign(v1 - v2) == np.sign(d1 - d2)
                agree[x] += same
                if x in gapstats:
                    gapstats[x][0 if not same else 1].append(abs(v1 - v2) / min(v1, v2))
    out("   pairwise agreement of the Dcal ranking with: %s (of %d pairs)" % (
        ", ".join("%s %d" % (x, agree[x]) for x in disp), npair))
    for x in ("rms", "max"):
        dis, agr = gapstats[x]
        out("   vs %s: %d disagreeing pairs with relative %s gap median %.2e (max %.2e); agreeing pairs median %.2e" % (
            x, len(dis), x, float(np.median(dis)), max(dis), float(np.median(agr))))
    for k in ("Mercury_100", "Mars_30", "Jupiter_100", "Saturn_2000"):
        out("   %-12s (mean e, sd, Dcal) per fit: %s" % (k, "; ".join(
            "%s (%+.4f, %.4f, %.5f)" % (f, float(np.mean(A[k + "_" + f])), float(np.std(A[k + "_" + f].astype(float))),
                                        res[k][f]["Dcal"]) for f in FITS)))
    out("   -> not bias absorption (F3 and L2 both have mean error 0); against RMS the coarse pricing disagrees mainly on")
    out("      near-ties, against max error on substantial differences.")
    out("\n# done")
    with open(os.path.join(HERE, "rb5_kepler.out"), "w") as fo:
        fo.write("\n".join(OUT) + "\n")
    if os.path.exists(CACHE):
        os.remove(CACHE)


if __name__ == "__main__":
    main()
