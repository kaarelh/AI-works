"""p4_kepler.py -- track `purpose`, target T4(b): do maximum error, RMS error, mean absolute error and SAI's pricing
(the rate of a 40-bin band-confined histogram completion, the paper's machine SH) rank the available Kepler fits the
same way, on the real residual series?

Seed 20261017 (the random half split of the times into a fitting half and a scoring half; one split per series,
shared by all fits of that series).  Usage:
    python3 p4_kepler.py            reads ../../laws/checks/l4_residuals.npz (2 fits: minimax 'mm', mean 'mn'),
                                    writes p4_kepler.out
    python3 p4_kepler.py --all      reads p4_allfits.npz (4 fits: F3, L2, L1, Linf; written by p4_allfits.py),
                                    writes p4_kepler_allfits.out
Residuals are longitude errors in arcmin (model minus truth) at 8000 uniform times per body and window.

Criteria per fit (lower is better):
    max   = max |e|            (uniform error model with fitted half-width; Kepler-style tolerance)
    rms   = sqrt(mean e^2)     (Gaussian error model with fitted scale, location fixed at 0)
    mae   = mean |e|           (Laplace error model with fitted scale, location fixed at 0)
    h40   = H(40-bin histogram of e on [-max, max]) + log2(bin width)   (plug-in differential entropy, bits; the
            fine-Delta limit of SAI's rate is h - log2 Delta)
    SH(D) = rate of the band-confined 40-bin histogram completion (as in laws/checks/l10_revision.py part C:
            band eps = (1 + kappa) max|e| of THIS fit, kappa = 0.01, histogram of the band position fitted on one half
            of the times with add-1/2 smoothing, cost averaged over the other half; coarse regime exact, fine regime
            by a 256-point midpoint rule over the dither), bits per datum, at the 11 cell widths of the paper.
The CDF machinery below is copied from laws/checks/l10_revision.py (functions Iint, CDF, cdf_hist).
"""
import itertools
import math
import os
import sys

import numpy as np

SEED = 20261017
HERE = os.path.dirname(os.path.abspath(__file__))
OUT = []
LN2 = math.log(2.0)
DELTAS = [0.1, 0.3, 1.0, 3.0, 10.0, 30.0, 60.0, 120.0, 300.0, 600.0, 1800.0]
KAPPA = 0.01


def out(s=""):
    OUT.append(s)
    print(s, flush=True)


# ------------------------------- copied from laws/checks/l10_revision.py -------------------------------
def Iint(a0, a1, al, be):
    a0 = np.asarray(a0, float)
    a1 = np.asarray(a1, float)
    al = np.asarray(al, float) + 0.0 * a0
    be = np.asarray(be, float) + 0.0 * a0
    ok = a1 > a0
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
        y = np.asarray(y, float)
        i = np.clip(np.searchsorted(self.v, y, side="left") - 1, 0, len(self.v) - 2)
        val = self.icpt[i] + self.slope[i] * y
        val = np.where(y <= 0, 0.0, val)
        val = np.where(y >= 1, 1.0, val)
        return val

    def coarse_cost(self, x):
        x = np.asarray(x, float)[:, None]
        a, b = self.v[:-1][None, :], self.v[1:][None, :]
        al, be = self.slope[None, :], self.icpt[None, :]
        right = Iint(np.maximum(a, x), b, al, be)
        left = Iint(a, np.minimum(b, x), -al, 1.0 - be)
        return (right + left).sum(axis=1)

    def fine_cost(self, x, r, M=256):
        x = np.asarray(x, float)[:, None]
        u = (np.arange(M) + 0.5)[None, :] / M
        lo = np.maximum(0.0, x - u * r)
        hi = np.minimum(1.0, x + (1 - u) * r)
        mass = self.left(hi) - self.left(lo)
        return np.mean(-np.log2(np.maximum(mass, 1e-300)), axis=1)


def cdf_hist(xtrain, B=40):
    cnt, edges = np.histogram(xtrain, bins=B, range=(0.0, 1.0))
    pr = (cnt + 0.5) / (cnt.sum() + 0.5 * B)
    G = np.concatenate([[0.0], np.cumsum(pr)])
    G[-1] = 1.0
    return CDF(edges, G, G)
# --------------------------------------------------------------------------------------------------------


def sh_costs(e, tr, te):
    """per-test-point expected costs (bits) of the SH machine at each cell width: a list of arrays"""
    eps = (1 + KAPPA) * float(np.max(np.abs(e)))
    x = (eps - e) / (2 * eps)
    G = cdf_hist(x[tr])
    xs = x[te]
    costs = []
    cc = None
    for D in DELTAS:
        r = D / (2 * eps)
        if r >= 1:
            if cc is None:
                cc = G.coarse_cost(xs)
            costs.append(cc / r)
        else:
            costs.append(G.fine_cost(xs, r))
    return costs


NSPLIT = 5


def h40(e):
    m = float(np.max(np.abs(e)))
    cnt, edges = np.histogram(e, bins=40, range=(-m, m))
    p = cnt[cnt > 0] / cnt.sum()
    return float(-np.sum(p * np.log2(p))) + math.log2(edges[1] - edges[0])


def order_str(vals, names):
    o = sorted(range(len(names)), key=lambda i: vals[i])
    return "<".join(names[i] for i in o)


def main():
    allfits = "--all" in sys.argv
    if allfits:
        Z = np.load(os.path.join(HERE, "p4_allfits.npz"))
        fitnames = ["F3", "L2", "L1", "Linf"]
        keyfor = {f: f for f in fitnames}
        outname = "p4_kepler_allfits.out"
    else:
        Z = np.load(os.path.join(HERE, "..", "..", "laws", "checks", "l4_residuals.npz"))
        fitnames = ["mm", "mn"]
        keyfor = {"mm": "e_max", "mn": "e_mean"}
        outname = "p4_kepler.out"
    order_b = ["Mercury", "Venus", "EMB", "Mars", "Jupiter", "Saturn", "Moon"]

    def sortkey(k):
        b, w = k.split("_")
        wv = {"1month": 1 / 12, "1year": 1.0, "18.6yr": 18.6}.get(w, None)
        return (order_b.index(b), float(w) if wv is None else wv)
    rows = sorted({k[:-2] for k in Z.files if k.endswith("_t")}, key=sortkey)
    out("# p4_kepler.py seed=%d numpy %s; input %s; fits %s; kappa=%.2f; cell widths (arcmin) %s" % (
        SEED, np.__version__, "p4_allfits.npz" if allfits else "l4_residuals.npz", fitnames, KAPPA, DELTAS))
    crit_names = ["max", "rms", "mae", "h40"] + ["SH%g" % D for D in DELTAS]
    n_series, n_ident = 0, 0
    pair_disagree = {}       # (critA, critB) -> count of (series, fit pair) disagreements
    pair_total = 0
    examples = []
    sh_flip_series = []
    table = []
    se_store = {}
    n_undec = [0, 0]
    winners = []
    for k in rows:
        es = {f: Z[k + "_" + keyfor[f]].astype(float) for f in fitnames}
        n = es[fitnames[0]].size
        rng = np.random.default_rng(SEED)
        idx = rng.permutation(n)
        tr, te = idx[: n // 2], idx[n // 2:]
        # identical series (the same fit was both minimax and mean) are reported and skipped
        uniq = []
        for f in fitnames:
            if not any(np.array_equal(es[f], es[g]) for g in uniq):
                uniq.append(f)
        if len(uniq) < len(fitnames):
            n_ident += 1
        crit, costs = {}, {}
        for f in uniq:
            e = es[f]
            v = [float(np.max(np.abs(e))), float(np.sqrt(np.mean(e * e))), float(np.mean(np.abs(e))), h40(e)]
            costs[f] = sh_costs(e, tr, te)
            v += [float(np.mean(c)) for c in costs[f]]
            crit[f] = v
        # further random splits, for the stability of the sign of SH differences
        extra = {f: [] for f in uniq}
        for sp in range(1, NSPLIT):
            idx2 = np.random.default_rng(SEED + sp).permutation(n)
            tr2, te2 = idx2[: n // 2], idx2[n // 2:]
            for f in uniq:
                extra[f].append([float(np.mean(c)) for c in sh_costs(es[f], tr2, te2)])
        table.append((k, uniq, crit))
        n_series += 1
        if len(uniq) < 2:
            continue
        # winners: classical criteria by value; SH at each cell width only if significantly best against every other fit
        wrow = {"max": min(uniq, key=lambda f: crit[f][0]), "rms": min(uniq, key=lambda f: crit[f][1]),
                "mae": min(uniq, key=lambda f: crit[f][2])}
        for i, D in enumerate(DELTAS):
            cand = min(uniq, key=lambda f: crit[f][4 + i])
            ok = True
            for g in uniq:
                if g == cand:
                    continue
                dd = costs[cand][i] - costs[g][i]
                m, se = float(np.mean(dd)), float(np.std(dd, ddof=1) / math.sqrt(dd.size))
                same = all(np.sign(extra[cand][sp][i] - extra[g][sp][i]) == np.sign(m) for sp in range(NSPLIT - 1))
                if not (m < -2 * se and same):
                    ok = False
            wrow["SH%g" % D] = cand if ok else "?"
        winners.append((k, wrow))
        for f, g in itertools.combinations(uniq, 2):
            pair_total += 1
            signs = [np.sign(crit[f][i] - crit[g][i]) for i in range(4)]
            # SH differences count only if significant: |paired mean| > 2 paired SE on the main split and the same sign
            # on all NSPLIT splits; otherwise the sign is 0 (undecided)
            for i in range(len(DELTAS)):
                dd = costs[f][i] - costs[g][i]
                m, se = float(np.mean(dd)), float(np.std(dd, ddof=1) / math.sqrt(dd.size))
                same = all(np.sign(extra[f][sp][i] - extra[g][sp][i]) == np.sign(m) for sp in range(NSPLIT - 1))
                signs.append(np.sign(m) if (abs(m) > 2 * se and same) else 0)
                se_store[(k, f, g, i)] = (m, se, same)
            for i, j in itertools.combinations(range(len(crit_names)), 2):
                if signs[i] != 0 and signs[j] != 0 and signs[i] != signs[j]:
                    pair_disagree[(crit_names[i], crit_names[j])] = pair_disagree.get((crit_names[i], crit_names[j]), 0) + 1
            sh_signs = signs[4:]
            if len(set(s for s in sh_signs if s != 0)) > 1:
                sh_flip_series.append((k, f, g, [se_store[(k, f, g, i)] for i in range(len(DELTAS))]))
            n_undec[0] += sum(1 for x in sh_signs if x == 0)
            n_undec[1] += len(sh_signs)

    out("\n== per series: criteria per fit (arcmin for max/rms/mae; bits for h40 and SH rates)")
    for k, uniq, crit in table:
        out("   %s%s" % (k, "   (fits identical: %s)" % "/".join(uniq) if len(uniq) < len(fitnames) else ""))
        for f in uniq:
            v = crit[f]
            out("      %-4s max %8.3f rms %8.3f mae %8.3f h40 %7.3f | SH: %s" % (
                f, v[0], v[1], v[2], v[3], " ".join("%.4f" % x for x in v[4:])))
        if len(uniq) >= 2:
            orders = [order_str([crit[f][i] for f in uniq], uniq) for i in range(len(crit_names))]
            out("      orders: max %s | rms %s | mae %s | h40 %s | SH(0.1') %s | SH(10') %s | SH(1800') %s" % (
                orders[0], orders[1], orders[2], orders[3], orders[4], orders[8], orders[14]))

    out("\n== summary over %d series (%d with coinciding fits), %d fit pairs" % (n_series, n_ident, pair_total))
    base = ["max", "rms", "mae", "h40", "SH0.1", "SH1", "SH10", "SH60", "SH600", "SH1800"]
    out("   number of fit pairs on which two criteria disagree (rows/cols):")
    out("   %8s %s" % ("", " ".join("%7s" % c for c in base)))
    for a in base:
        rowv = []
        for b in base:
            if a == b:
                rowv.append("      -")
            else:
                i, j = crit_names.index(a), crit_names.index(b)
                key = (crit_names[min(i, j)], crit_names[max(i, j)])
                rowv.append("%7d" % pair_disagree.get(key, 0))
        out("   %8s %s" % (a, " ".join(rowv)))
    out("   (SH differences are counted only where significant: |paired mean difference| > 2 paired standard errors on")
    out("    the main split and the same sign on all %d random splits; %d of %d (pair, cell width) SH comparisons undecided)"
        % (NSPLIT, n_undec[0], n_undec[1]))
    out("\n   fit pairs whose SAI ranking (SH rate) changes significantly with the cell width: %d" % len(sh_flip_series))
    for (k, f, g, d) in sh_flip_series:
        out("      %-14s %s vs %s: SH(%s) - SH(%s) [2 SE] by cell width:" % (k, f, g, f, g))
        out("         %s" % "  ".join("%g':%+.4f[%.4f]%s" % (D, m, 2 * se, "" if same else "*")
                                      for D, (m, se, same) in zip(DELTAS, d)))
    out("      (* = sign not the same on all splits)")
    out("\n== winners (best fit per criterion; SH winner only if significantly better than every other fit, else '?')")
    out("   %-14s %5s %5s %5s | %s" % ("series", "max", "rms", "mae", " ".join("%6s" % ("SH%g" % D) for D in DELTAS)))
    for k, wr in winners:
        out("   %-14s %5s %5s %5s | %s" % (k, wr["max"], wr["rms"], wr["mae"],
                                         " ".join("%6s" % wr["SH%g" % D] for D in DELTAS)))
    out("   counts over %d series, per cell width: SH winner decided; = max winner; = rms winner; = mae winner;"
        " equal to none of the three" % len(winners))
    for D in DELTAS:
        c = "SH%g" % D
        dec = [wr for _, wr in winners if wr[c] != "?"]
        out("   %7g': decided %2d | =max %2d | =rms %2d | =mae %2d | none %2d" % (
            D, len(dec), sum(wr[c] == wr["max"] for wr in dec), sum(wr[c] == wr["rms"] for wr in dec),
            sum(wr[c] == wr["mae"] for wr in dec),
            sum(wr[c] not in (wr["max"], wr["rms"], wr["mae"]) for wr in dec)))
    out("\n# done")
    with open(os.path.join(HERE, outname), "w") as fo:
        fo.write("\n".join(OUT) + "\n")


if __name__ == "__main__":
    main()
