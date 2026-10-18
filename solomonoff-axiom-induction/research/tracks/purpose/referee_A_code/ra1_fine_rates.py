"""ra1_fine_rates.py -- referee A, track `purpose`: is the T4(b) ranking of Kepler fits by "SAI's pricing" a property of
SAI's ideal rate (notes Thm T3.3) or of the 40-bin band machine SH used to approximate it?

Seed 20261018 (paired bootstrap over the 8000 sample times; nothing else is random).  Reads ../checks/p4_allfits.npz
(the developer's four fits F3, L2, L1, Linf per body and window, 8000 uniform times each); writes ra1_fine_rates.out.

For each fit's error sample e (arcmin) we compute, with no fit-dependent band and no fixed bin count:
  r(D)  = E_u H(cell of e in the grid {kD - u}) in bits, the ideal rate of Thm T3.3 for the empirical law of e(t),
          t uniform in the window, computed exactly through the identity of Lemma T3.2 (h(e+V) - log2 D, the
          density of e+V being piecewise constant for the empirical law).  No bias correction: the plug-in rate of an
          empirical law is biased low when a cell holds few samples, so a (series, D) is flagged UNRELIABLE when
          N D / (2 max|e|) < 20 samples per cell, and unreliable cells are excluded from every count below.
          (Version 1 of this script averaged over 64 midpoint dithers, which misses narrow supports at coarse D:
          its output is kept as ra1_fine_rates_v1_midpoint_BUG.out and is not used.)
  hKL   = Kozachenko-Leonenko differential entropy estimate (k = 4), bits; the fine-limit rate is hKL - log2 D.
  h40, h160, h640 = plug-in histogram differential entropies on [-max, max] with 40, 160, 640 bins (h40 is the
          quantity the developer reports SH agrees with at 0.1').
Decisions between two fits use a paired bootstrap (B = 100 resamples of the time indices, shared by all fits):
a sign counts only if |difference| > 2 bootstrap SE.  The developer's SH winners are read from
../checks/p4_kepler_allfits.out and compared with the ideal-rate winners at 0.1' and 1800'.
"""
import itertools
import math
import os

import numpy as np
from scipy.special import digamma

SEED = 20261018
HERE = os.path.dirname(os.path.abspath(__file__))
OUT = []
DELTAS = [0.1, 0.3, 1.0, 3.0, 10.0, 30.0, 60.0, 120.0, 300.0, 600.0, 1800.0]
BOOT_D = [0.1, 1.0, 10.0, 60.0, 1800.0]
MINCELL = 20.0
NB = 100
FITS = ["F3", "L2", "L1", "Linf"]


def out(s=""):
    OUT.append(s)
    print(s, flush=True)


def rate(e, D, mm=False):
    """E_u H(cell | u) in bits for the empirical law of e, grid of width D shifted by a uniform dither u.
    Exact, by the identity of Lemma T3.2: H(C_U(e) | U) = h(e + V) - log2 D, where for the empirical law e + V has
    the piecewise-constant density f(y) = #{i : y - D <= e_i < y} / (N D); integrate -f log2 f over its pieces."""
    N = e.size
    pts = np.concatenate([e, e + D])
    inc = np.concatenate([np.ones(N), -np.ones(N)])
    o = np.argsort(pts, kind="mergesort")
    pts, inc = pts[o], inc[o]
    cnt = np.cumsum(inc)[:-1]
    ln = np.diff(pts)
    ok = (cnt > 0) & (ln > 0)
    f = cnt[ok] / (N * D)
    h = float(np.sum(-ln[ok] * f * np.log2(f)))
    return h - math.log2(D)


def h_hist(e, nb):
    m = float(np.max(np.abs(e)))
    cnt, edges = np.histogram(e, bins=nb, range=(-m, m))
    p = cnt[cnt > 0] / cnt.sum()
    return float(-np.sum(p * np.log2(p))) + math.log2(edges[1] - edges[0])


def h_kl(e, k=4):
    x = np.sort(e)
    N = x.size
    # k-th nearest neighbour distance in 1-D via sorted array
    idx = np.arange(N)
    dists = np.full(N, np.inf)
    # candidate neighbours within k positions on each side
    cand = []
    for j in range(-k, k + 1):
        if j == 0:
            continue
        jj = np.clip(idx + j, 0, N - 1)
        d = np.abs(x[jj] - x)
        d[(idx + j < 0) | (idx + j > N - 1)] = np.inf
        cand.append(d)
    cand = np.sort(np.stack(cand, axis=1), axis=1)
    eps = cand[:, k - 1]
    eps = np.maximum(eps, 1e-12)
    # h = psi(N) - psi(k) + log(c_d) + d/N sum log eps, d = 1, c_1 = 2 (unit ball volume for max-norm/euclid in 1-D)
    h_nats = digamma(N) - digamma(k) + math.log(2.0) + float(np.mean(np.log(eps)))
    return h_nats / math.log(2)


def main():
    Z = np.load(os.path.join(HERE, "..", "checks", "p4_allfits.npz"))
    rows = sorted({k[:-2] for k in Z.files if k.endswith("_t")})
    rng = np.random.default_rng(SEED)
    out("# ra1_fine_rates.py seed=%d numpy %s; %d series; exact dither integral; min samples per cell %g; bootstrap %d" % (
        SEED, np.__version__, len(rows), MINCELL, NB))
    out("# r(D): ideal SAI rate (Thm T3.3) of the empirical error law, exact, bits per datum")

    shw = {}
    txt = open(os.path.join(HERE, "..", "checks", "p4_kepler_allfits.out")).read().split("== winners")[1]
    for line in txt.splitlines():
        parts = line.split()
        if len(parts) == 16 and parts[4] == "|":
            shw[parts[0]] = {"SH0.1": parts[5], "SH1800": parts[15]}
    agree = {"h40_vs_r0.1": [0, 0], "h40_vs_hKL": [0, 0], "h40_vs_h640": [0, 0], "r0.1_vs_hKL": [0, 0]}
    flips = []
    winners = []
    n_pairs = 0
    for kser in rows:
        es = {f: Z[kser + "_" + f].astype(float) for f in FITS}
        uniq = []
        for f in FITS:
            if not any(np.array_equal(es[f], es[g]) for g in uniq):
                uniq.append(f)
        N = es[uniq[0]].size
        crit = {}
        for f in uniq:
            e = es[f]
            crit[f] = {"max": float(np.max(np.abs(e))), "rms": float(np.sqrt(np.mean(e * e))),
                       "mae": float(np.mean(np.abs(e))), "h40": h_hist(e, 40), "h160": h_hist(e, 160),
                       "h640": h_hist(e, 640), "hKL": h_kl(e)}
            for D in DELTAS:
                crit[f]["r%g" % D] = rate(e, D)
        # paired bootstrap
        boot = {f: {D: [] for D in BOOT_D} for f in uniq}
        bootkl = {f: [] for f in uniq}
        for b in range(NB):
            ii = rng.integers(0, N, N)
            for f in uniq:
                eb = es[f][ii]
                for D in BOOT_D:
                    boot[f][D].append(rate(eb, D))
                bootkl[f].append(h_kl(eb))
        span = 2 * max(crit[f]["max"] for f in uniq)
        rel = {D: (N * D / span >= MINCELL) or (D >= span) for D in DELTAS}
        out("\n   %s  (N = %d; samples per 0.1' cell over the range: %.1f)" % (kser, N, N * 0.1 / span))
        for f in uniq:
            c = crit[f]
            out("      %-4s max %8.3f rms %8.3f mae %8.3f | h40 %7.4f h160 %7.4f h640 %7.4f hKL %7.4f | r(0.1') %7.4f"
                " r(1') %7.4f r(10') %7.4f r(60') %7.4f r(1800') %8.5f" % (
                    f, c["max"], c["rms"], c["mae"], c["h40"], c["h160"], c["h640"], c["hKL"], c["r0.1"],
                    c["r1"], c["r10"], c["r60"], c["r1800"]))

        def sig(f, g, D):
            d = crit[f]["r%g" % D] - crit[g]["r%g" % D]
            sd = float(np.std(np.array(boot[f][D]) - np.array(boot[g][D]), ddof=1))
            return (np.sign(d) if abs(d) > 2 * sd else 0), d, sd

        def sigkl(f, g):
            d = crit[f]["hKL"] - crit[g]["hKL"]
            sd = float(np.std(np.array(bootkl[f]) - np.array(bootkl[g]), ddof=1))
            return (np.sign(d) if abs(d) > 2 * sd else 0), d, sd
        if len(uniq) < 2:
            continue
        for f, g in itertools.combinations(uniq, 2):
            n_pairs += 1
            s40 = np.sign(crit[f]["h40"] - crit[g]["h40"])
            s640 = np.sign(crit[f]["h640"] - crit[g]["h640"])
            sr, _, _ = sig(f, g, 0.1) if rel[0.1] else (0, 0, 0)
            sk, _, _ = sigkl(f, g)
            for key, a, b in (("h40_vs_r0.1", s40, sr), ("h40_vs_hKL", s40, sk), ("h40_vs_h640", s40, s640),
                              ("r0.1_vs_hKL", sr, sk)):
                if a != 0 and b != 0:
                    agree[key][1] += 1
                    if a != b:
                        agree[key][0] += 1
            s_lo, d_lo, sd_lo = sig(f, g, 0.1)
            s_hi, d_hi, sd_hi = sig(f, g, 1800.0)
            if rel[0.1] and s_lo != 0 and s_hi != 0 and s_lo != s_hi:
                flips.append((kser, f, g, d_lo, sd_lo, d_hi, sd_hi))
        w = {"max": min(uniq, key=lambda f: crit[f]["max"]), "rms": min(uniq, key=lambda f: crit[f]["rms"]),
             "mae": min(uniq, key=lambda f: crit[f]["mae"])}
        for D in (0.1, 1800.0):
            cand = min(uniq, key=lambda f: crit[f]["r%g" % D])
            ok = rel[D] and all(sig(cand, g, D)[0] == -1 for g in uniq if g != cand)
            w["r%g" % D] = cand if ok else ("?" if rel[D] else "unrel")
        w["SH0.1"] = shw.get(kser, {}).get("SH0.1", "-")
        w["SH1800"] = shw.get(kser, {}).get("SH1800", "-")
        winners.append((kser, w))

    out("\n== summary over %d fit pairs" % n_pairs)
    for key, (dis, tot) in agree.items():
        out("   %-12s: decided on both %3d pairs, opposite signs on %3d" % (key, tot, dis))
    out("\n   pairs whose ideal-rate ranking changes significantly between 0.1' and 1800': %d" % len(flips))
    for (k, f, g, dl, sl, dh, sh) in flips:
        out("      %-13s %s vs %s: r(0.1') diff %+.4f [2SE %.4f]; r(1800') diff %+.5f [2SE %.5f]" % (
            k, f, g, dl, 2 * sl, dh, 2 * sh))
    out("\n== winners by the ideal rate (significantly best against every other fit, else '?')")
    out("   %-13s %5s %5s %5s | %6s %6s | developer's SH: %6s %6s" % ("series", "max", "rms", "mae", "r0.1", "r1800",
                                                                   "SH0.1", "SH1800"))
    for k, w in winners:
        out("   %-13s %5s %5s %5s | %6s %6s |                 %6s %6s" % (k, w["max"], w["rms"], w["mae"], w["r0.1"],
                                                                        w["r1800"], w["SH0.1"], w["SH1800"]))
    for D in ("r0.1", "r1800"):
        dec = [w for _, w in winners if w[D] not in ("?", "unrel")]
        out("   %-6s decided %2d | =max %2d | =rms %2d | =mae %2d | none %2d" % (
            D, len(dec), sum(w[D] == w["max"] for w in dec), sum(w[D] == w["rms"] for w in dec),
            sum(w[D] == w["mae"] for w in dec), sum(w[D] not in (w["max"], w["rms"], w["mae"]) for w in dec)))
    for D, S in (("r0.1", "SH0.1"), ("r1800", "SH1800")):
        both = [w for _, w in winners if w[D] not in ("?", "unrel") and w[S] not in ("?", "-")]
        shonly = [w for _, w in winners if w[S] not in ("?", "-")]
        out("   %-6s vs developer's %-6s: SH decided in %2d series; of these, ideal rate unreliable in %2d, undecided in %2d,"
            " decided in %2d (same winner in %2d)" % (D, S, len(shonly), sum(w[D] == "unrel" for w in shonly),
                                                     sum(w[D] == "?" for w in shonly), len(both),
                                                     sum(w[D] == w[S] for w in both)))
    out("\n# done")
    with open(os.path.join(HERE, "ra1_fine_rates.out"), "w") as fo:
        fo.write("\n".join(OUT) + "\n")


if __name__ == "__main__":
    main()
