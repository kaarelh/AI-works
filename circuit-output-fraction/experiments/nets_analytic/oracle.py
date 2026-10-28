"""Exhaustive (oracle) diagnostics for the nets with d <= 28: what the best
conceivable member of each family of analytic bounds / envelopes could achieve
if the hard quantities (partition functions, MAP, cube minima) were known
exactly. None of these is a method; they are ceilings and explanations.

The whole cube is tabulated once per net (rareprob.nets_analytic._half_table;
float64 for d <= 24, float32 for d = 28, whose rounding, below 1e-6 here, is
irrelevant at the precision reported). Per net:

  f0_minus_t       F(0) - t (box barrier: if < 0, every positive mixture of
                   tilts whose domination holds on R^d has mass >= 1)
  sym_gap          min_x (F(x) + F(-x))/2 - t (cube barrier: if < 0, every
                   tilt envelope from ANY affine minorant valid on the cube
                   has mass >= 1)
  best_tilt_logZ   log mass of the best tilt envelope with exact cube
                   domination (only computed when sym_gap > 0)
  fmin, fmax       min and max of f over the cube
  chernoff_exact   min_theta e^{theta t} E e^{-theta f} (exact partition
                   function, from a 4e5-bin histogram of the table with bin
                   minima: an upper bound tight to the bin width): the mass
                   of the ideal Chernoff envelope, so K_ideal =
                   chernoff_exact / p; theta_star its tilt
  moment_best, moment_order   min_k E (f - mu)^{2k} / (mu - t)^{2k} and the
                   order 2k attaining it (exact moments for d = 24; from the
                   histogram, bin minima, for d = 28)
  pmap             perturb-and-MAP: mean and standard error of R = M - S
                   (n samples, exact MAP by enumeration) for a few (theta,
                   block size), and the implied Chernoff value
                   theta t + E R (an estimate of the bound, not certified;
                   see perturb_map.py for the certified version)
  dobrushin_alpha_theta_star, R_holder_*, R_indep_*, quad_minorant_mass
                   (one hidden layer) as in the previous version: Dobrushin
                   coefficient bound at theta*, comonotone/independent
                   variance inflation of the even-form decompositions, mass
                   of the per-unit quadratic minorant event
  cap_Z            (d = 24 only) mass of the smallest ellipsoidal cap in the
                   top k = 1..4 eigen-directions of E[x x^T | fail]
                   containing every failure

Usage: python3 oracle.py [--out=FILE] [names...]   (default: all nets with
d <= 28, results/oracle.json; summarize.py merges every results/oracle*.json)."""

import json
import math
import os
import sys
import time

import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "..", "..", "code"))
sys.path.insert(0, HERE)
from rareprob.nets import load_net, _half_inputs  # noqa: E402
from rareprob import nets_analytic as na  # noqa: E402
from run_suite import greedy_pairs, dobrushin_alpha  # noqa: E402

NETS = os.path.join(HERE, "..", "nets")


def histogram(F, bins=400000, rows=512):
    """Counts of the table values in fine bins and the smallest value in each
    bin (so sums over bins with the bin minima bound sums of decreasing
    functions of f from above)."""
    lo, hi = float(F.min()), float(F.max())
    edges = np.linspace(lo, hi + 1e-12 * (1 + abs(hi)), bins + 1)
    cnt = np.zeros(bins)
    mn = np.full(bins, np.inf)
    for s in range(0, F.shape[0], rows):
        v = F[s:s + rows].astype(np.float64).ravel()
        ix = np.clip(np.searchsorted(edges, v, side="right") - 1, 0, bins - 1)
        cnt += np.bincount(ix, minlength=bins)
        np.minimum.at(mn, ix, v)
    ok = cnt > 0
    return cnt[ok] / F.size, mn[ok]


def lse_hist(P, v, th):
    """log E exp(-th f) from the histogram with bin minima (an upper bound on
    the exact value, tight to the bin width)."""
    m = float((-th * v).max())
    return m + math.log(float(np.dot(P, np.exp(-th * v - m))))


def moments_table(F, t, kmax=60, rows=256):
    mu = float(F.astype(np.float64).mean()) if F.size <= 1 << 24 else \
        sum(float(F[s:s + rows].astype(np.float64).sum()) for s in range(0, F.shape[0], rows)) / F.size
    if mu <= t:
        return {"best": 1.0, "order": 0}
    acc = np.zeros(kmax // 2)
    ks = np.arange(2, kmax + 1, 2)
    for s in range(0, F.shape[0], rows):
        y = (F[s:s + rows].astype(np.float64).ravel() - mu) / (mu - t)
        y2 = y * y
        p = np.ones_like(y)
        for i in range(len(ks)):
            p = p * y2
            acc[i] += float(p.sum())
    acc /= F.size
    i = int(np.argmin(acc))
    return {"best": float(min(1.0, acc[i])), "order": int(ks[i]), "mu": mu,
            "by_order": {int(k): float(v) for k, v in zip(ks, acc)}}


def pmap_oracle(oracle, th, block, n, rng):
    R = na.perturb_map_samples(oracle, th, block, n, rng)
    return {"theta": th, "block": block, "n": n, "R_mean": float(R.mean()), "R_se": float(R.std(ddof=1) / math.sqrt(n)),
            "R_sd": float(R.std(ddof=1)), "log_bound_est": float(th * oracle.net.threshold + R.mean())}


def caps(net, F_table, k1, k2, t, kmax=4):
    HA, HB = _half_inputs(k1), _half_inputs(k2)
    ia, ib = np.nonzero(F_table < t)
    Fx = np.concatenate([HA[ia], HB[ib]], axis=1)
    if len(Fx) == 0:
        return None, None
    S = Fx.T @ Fx / len(Fx)
    ev, Uv = np.linalg.eigh(S)
    ev, Uv = ev[::-1], Uv[:, ::-1]
    wts = ev[:kmax] - 1.0
    taus = [(((Fx @ Uv[:, :k]) ** 2) @ wts[:k]).min() for k in range(1, kmax + 1)]
    hits = np.zeros(kmax)
    PA = HA @ Uv[:k1, :kmax]
    PB = HB @ Uv[k1:, :kmax]
    for s in range(0, PA.shape[0], 64):
        Pj = (PA[s:s + 64, None, :] + PB[None, :, :]) ** 2
        for k in range(1, kmax + 1):
            hits[k - 1] += float(((Pj[..., :k] @ wts[:k]) >= taus[k - 1] - 1e-9).sum())
    return [h / F_table.size for h in hits], [float(x) for x in ev[:kmax]]


def oracle(name, p):
    net = load_net(os.path.join(NETS, name + ".npz"))
    d, t = net.d, float(net.threshold)
    r = {"name": name, "p": p}
    t0 = time.time()
    orc = na.EnumMAPOracle(net, np.float64 if d <= 24 else np.float32)
    F = orc.F
    r["table_seconds"] = time.time() - t0
    r["f0_minus_t"] = float(net.forward(np.zeros((1, d)))[0]) - t
    r["fmin"], r["fmax"] = float(F.min()), float(F.max())
    r["sym_gap"] = na.symmetric_gap(F, t)
    if r["sym_gap"] > 0:
        bt = na.best_tilt_oracle(F, t)
        r["best_tilt_logZ"] = bt["logZ"]
    else:
        r["best_tilt_logZ"] = 0.0  # barred: Z >= 1 for every affine minorant on the cube
    # exact Chernoff
    from scipy.optimize import minimize_scalar
    P, v = histogram(F)
    best = min((minimize_scalar(lambda lt: math.exp(lt) * t + lse_hist(P, v, math.exp(lt)), bounds=(lo, lo + 3),
                                method="bounded") for lo in range(-4, 9, 2)), key=lambda q: q.fun)
    r["chernoff_exact"] = math.exp(min(best.fun, 0.0))
    r["log_chernoff_exact"] = float(best.fun)
    r["theta_star"] = math.exp(best.x)
    mb = moments_table(F, t) if d <= 24 else na.moment_bounds(P, v, t)
    r["moment_best"], r["moment_order"] = mb["best"], mb["order"]
    r["moment_by_order"] = {k: v for k, v in mb.get("by_order", {}).items() if k in (2, 4, 6, 8, 12, 20, 30, 40)}
    # perturb-and-MAP (exact MAP by enumeration), a few configurations
    rng = np.random.default_rng(7)
    ths = sorted(set([min(80.0, max(2.0, round(r["theta_star"] / 2, 1))), min(80.0, max(2.0, round(r["theta_star"], 1)))]))
    n = 60 if d <= 24 else 24
    r["pmap"] = [pmap_oracle(orc, th, blk, n, rng) for th in ths for blk in (1, 4)]
    r["pmap_seconds"] = time.time() - t0
    if len(net.Ws) == 2:
        W, b, a, c = na.one_layer(net)
        r["dobrushin_alpha_theta_star"] = dobrushin_alpha(net, r["theta_star"])
        X = rng.choice([-1.0, 1.0], size=(200000, d))
        Z = X @ W.T + b
        E = 0.5 * np.abs(Z) * a
        cp, lam, _ = na.linear_part(net)
        L = X @ lam
        vf = net.forward(X).var()
        sds = list(E.std(0)) + [L.std()]
        r["R_holder_1"] = float(sum(sds) ** 2 / vf)
        r["R_indep_1"] = float((E.var(0).sum() + L.var()) / vf)
        pairs = greedy_pairs(net)
        Gs = [E[:, G].sum(1) for G in pairs] + [L]
        r["R_holder_2"] = float(sum(g.std() for g in Gs) ** 2 / vf)
        r["R_indep_2"] = float(sum(g.var() for g in Gs) / vf)
        lo, hi = na.box_bounds(net)[0]
        Pm = a > 0
        best_q = 1.0
        for sc in [0.25, 0.5, 1, 2, 4, 8, 16]:
            s = sc * np.ones((~Pm).sum())
            q = c + (Z[:, Pm] * (Z[:, Pm] - lo[Pm]) / (hi[Pm] - lo[Pm])) @ a[Pm] \
                + ((Z[:, ~Pm] + s) ** 2 / (4 * s)) @ a[~Pm]
            best_q = min(best_q, float((q < t).mean()))
        r["quad_minorant_mass"] = best_q
    if d <= 24:
        r["cap_Z"], r["fail_cov_top_eigs"] = caps(net, F, orc.k1, orc.k2, t)
    r["seconds"] = time.time() - t0
    return r


if __name__ == "__main__":
    suite = json.load(open(os.path.join(NETS, "suite.json")))
    args = [a for a in sys.argv[1:] if not a.startswith("--out=")]
    outs = [a[6:] for a in sys.argv[1:] if a.startswith("--out=")]
    names = args or [e["name"] for e in suite if e["d"] <= 28]
    out_path = os.path.join(HERE, "results", outs[0] if outs else "oracle.json")
    res = json.load(open(out_path)) if os.path.exists(out_path) and args else {}
    for nm in names:
        e = next(x for x in suite if x["name"] == nm)
        r = oracle(nm, e.get("p_exact"))
        res[nm] = r
        print(json.dumps(r), flush=True)
        with open(out_path, "w") as f:
            json.dump(res, f, indent=1)
