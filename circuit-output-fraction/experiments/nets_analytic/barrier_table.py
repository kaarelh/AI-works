"""Barrier diagnostics on every net of experiments/nets/suite.json: why
upper bounds by relaxation, tilting and decoupling fail on these nets.

Per net (fields of results/barrier_table.json):
  f0_minus_t      F(0) - t, exact (rational arithmetic). < 0: the point 0 of
                  the box fails, so no bound valid on the box [-1,1]^d
                  certifies the root, and every positive mixture of
                  full-support tilts proved on the box has Z >= 1 (box
                  barrier).
  box_min         the smallest f found at a real point of the box: HiGHS MILP
                  over the box (rareprob.nets_verify.milp_min, integer=False,
                  time limit 120 s) and projected gradient descent
                  (nets_verify.box_search); the points are re-evaluated, so
                  box_min < t - tau is a checked witness that no box method
                  certifies the root. box_milp_status 'optimal' (the
                  solver's floating-point claim) or 'time limit';
                  box_milp_dual is the solver's lower bound (floating point,
                  NOT certified).
  cube_min        min of f over the cube (d <= 28, enumeration; float values).
  s_star_minus_t  min_x (F(x) + F(-x))/2 - t: exact enumeration for d <= 28
                  (float values; tau ~ 1e-13 here); for d > 28 an upper bound
                  from local search (s_star_exact = false). < 0 bars every tilt
                  envelope from an affine minorant valid on the cube, however
                  certified (cube barrier).
  floor1, floor2  decoupling floors (even form; singletons / greedy pairs, one
                  hidden layer): lower limits of every Hoelder, tree-reweighted,
                  Brascamp-Lieb or Finner-type Chernoff bound with these parts.
  holder_best     the best certified Chernoff-Hoelder bound (relu or even form,
                  singletons or greedy pairs; holder_which) and mcdiarmid.
  box_tilt_logZ   log mass of the best box-relaxed tilt envelope (per-unit
                  relaxations for one hidden layer, the CROWN minorant of
                  nets_verify for two); sign_pattern_logZ the same for the
                  sign-pattern envelope (one hidden layer). >= 0: no gain over
                  Monte Carlo.
  gap_r8, margin_r8   medians over 100 random subcubes with r = 8 free
                  coordinates of (cube min - CROWN lower bound) and of
                  (cube min - t): a subcube is certified only when gap < margin.
  r_star          CROWN r50: the largest r at which at least half of 500
                  random subcubes with r free coordinates are certified safe
                  (0: none at r = 2).
  level1_weight   sum_i fhat(i)^2 / Var f, fhat(i) = E f(x) x_i: exact for
                  d <= 28 (from the row and column sums of the enumerated
                  table); for d > 28 a Monte Carlo estimate (2^20 samples,
                  bias-corrected; level1_exact = false).
  seconds         wall-clock seconds per part (shared 4-core machine, so
                  indicative only).

Usage: python3 barrier_table.py [--out=FILE] [names...]   (default: all
suite nets; results/barrier_table.json, or results/FILE, is updated net by
net, keeping the nets already there).
"""

import json
import math
import os
import sys
import time
import zlib
from fractions import Fraction

import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "..", "..", "code"))
from rareprob.nets import load_net, _half_inputs  # noqa: E402
from rareprob import nets_analytic as na  # noqa: E402
from rareprob.nets_verify import Bounder, box_search, milp_min  # noqa: E402

NETS = os.path.join(HERE, "..", "nets")
OUT = os.path.join(HERE, "results", "barrier_table.json")
MILP_TIME = 120.0


def greedy_pairs(net, n=200000, seed=0):
    """Pair hidden units with the most negative covariance of their even parts
    (estimated by sampling; the choice of groups does not affect soundness)."""
    W, b, a, c = na.one_layer(net)
    rng = np.random.default_rng(seed)
    X = rng.choice([-1.0, 1.0], size=(n, net.d))
    E = 0.5 * np.abs(X @ W.T + b) * a
    C = np.cov(E.T)
    un = set(range(W.shape[0]))
    pairs = []
    while len(un) > 1:
        best = min(((C[i, j], i, j) for i in un for j in un if i < j))
        pairs.append([best[1], best[2]])
        un -= {best[1], best[2]}
    if un:
        pairs.append([un.pop()])
    return pairs


def dobrushin_alpha(net, theta):
    """Upper bound on Dobrushin's interdependence coefficient of the Gibbs
    measure pi(x) ~ exp(-theta F(x)) on the cube: flipping x_k changes the
    log-odds of x_i by theta |D_i D_k F| <= theta sum_j |a_j| 4 min(|w_ji|,|w_jk|)
    (second difference of relu), and the conditional of x_i moves by at most
    tanh(change / 4) in total variation. alpha < 1 is needed for a certified
    sampler of the ideal envelope exp(theta (t - F)) (used by oracle.py)."""
    W, b, a, c = na.one_layer(net)
    Aw = np.abs(W)
    d = net.d
    D = np.zeros((d, d))
    for j in range(W.shape[0]):
        D += abs(a[j]) * 4 * np.minimum(Aw[j][:, None], Aw[j][None, :])
    np.fill_diagonal(D, 0)
    return float(np.max(np.tanh(theta * D / 4).sum(axis=1)))


def cube_pass(net, rows=8):
    """One enumeration of the cube (meet in the middle on the first layer),
    rows paired with their mirror images: the exact mean, variance, level-1
    Walsh coefficients, minimum, failure count and symmetric minimum
    min_x (f(x) + f(-x)) / 2 of the float values (d <= 28)."""
    d = net.d
    k1 = d // 2
    k2 = d - k1
    W, b = net.Ws[0], net.bs[0]
    HA, HB = _half_inputs(k1), _half_inputs(k2)
    A = HA @ W[:, :k1].T + b
    B = HB @ W[:, k1:].T
    n1, n2 = 1 << k1, 1 << k2
    t = float(net.threshold)

    def rows_f(idx):
        h = np.maximum(A[idx][:, None, :] + B[None, :, :], 0.0)
        for Wl, bl in zip(net.Ws[1:-1], net.bs[1:-1]):
            h = np.maximum(h @ Wl.T + bl, 0.0)
        return (h @ net.Ws[-1].T + net.bs[-1])[..., 0]

    row_sums = np.zeros(n1)
    col_sums = np.zeros(n2)
    sq = []
    fmin, sym, fails = math.inf, math.inf, 0
    for s in range(0, n1 // 2, rows):
        a = np.arange(s, min(s + rows, n1 // 2))
        abar = n1 - 1 - a  # the rows of -u
        Fa, Fb = rows_f(a), rows_f(abar)
        sym = min(sym, float((Fa + Fb[:, ::-1]).min()))  # f(u, v) + f(-u, -v)
        for idx, Fr in ((a, Fa), (abar, Fb)):
            row_sums[idx] = Fr.sum(1)
            col_sums += Fr.sum(0)
            sq.append(float((Fr * Fr).sum()))
            fmin = min(fmin, float(Fr.min()))
            fails += int((Fr < t).sum())
    N = float(n1) * n2
    mean = math.fsum(row_sums) / N
    var = math.fsum(sq) / N - mean * mean
    fhat = np.concatenate([HA.T @ row_sums, HB.T @ col_sums]) / N
    return dict(mean=mean, var=var, level1_weight=float(np.sum(fhat ** 2) / var), cube_min=fmin,
                s_star=0.5 * sym, fail_count=fails)


def sampled_pass(net, rng, n=1 << 20, chunk=1 << 16):
    """d > 28: Monte Carlo estimate of the level-1 weight (bias-corrected),
    and a local-search upper bound on min_x (f(x) + f(-x)) / 2."""
    d = net.d
    s1 = np.zeros(d)
    m1 = m2 = 0.0
    best_x, best_g = None, math.inf
    for s in range(0, n, chunk):
        X = rng.choice([-1.0, 1.0], size=(chunk, d))
        f = net.forward(X)
        g = f + net.forward(-X)
        i = int(np.argmin(g))
        if g[i] < best_g:
            best_g, best_x = float(g[i]), X[i].copy()
        s1 += f @ X
        m1 += float(f.sum())
        m2 += float((f * f).sum())
    mean, ex2 = m1 / n, m2 / n
    var = ex2 - mean * mean
    fhat = s1 / n
    level1 = float(np.sum(fhat ** 2 - (ex2 - fhat ** 2) / n) / var)
    # greedy single-flip descent on g(x) = f(x) + f(-x) from the best samples
    starts = [best_x] + [rng.choice([-1.0, 1.0], size=d) for _ in range(7)]
    for x in starts:
        x = x.copy()
        gx = float(net.forward(x[None])[0] + net.forward(-x[None])[0])
        while True:
            Y = np.repeat(x[None], d, 0)
            Y[np.arange(d), np.arange(d)] *= -1
            gy = net.forward(Y) + net.forward(-Y)
            j = int(np.argmin(gy))
            if gy[j] >= gx:
                break
            x, gx = Y[j], float(gy[j])
        best_g = min(best_g, gx)
    return dict(mean=mean, var=var, level1_weight=level1, s_star_upper=0.5 * best_g)


def subcubes(d, r, n, rng):
    X0 = rng.choice([-1, 1], size=(n, d)).astype(np.int8)
    for i in range(n):
        X0[i, rng.choice(d, r, replace=False)] = 0
    return X0


def crown_profile(net, rng, n_gap=100, n_rate=500):
    """CROWN looseness against the margin at r = 8, and CROWN r50."""
    bd = Bounder(net)
    d = bd.d
    X0 = subcubes(d, 8, n_gap, rng)
    lb = bd.bound(X0)[0]
    idx = np.arange(256)
    P = np.where((idx[:, None] >> np.arange(8)) & 1, 1.0, -1.0)
    cm = np.empty(n_gap)
    for i in range(n_gap):
        X = np.repeat(X0[i][None].astype(float), 256, 0)
        X[:, X0[i] == 0] = P
        cm[i] = bd.forward(X).min()
    rates = {}
    zeros = 0
    for r in [r for r in (2, 4, 6, 8, 10, 12, 14, 16, 20, 24, 32, 48, 64, 96, 128) if r <= d]:
        X0 = subcubes(d, r, n_rate, rng)
        lbr = np.concatenate([bd.bound(X0[s:s + 250])[0] for s in range(0, n_rate, 250)])
        rates[r] = float((lbr >= bd.thr_safe).mean())
        zeros = zeros + 1 if rates[r] == 0 else 0
        if zeros >= 2:
            break
    r50 = max([r for r, v in rates.items() if v >= 0.5], default=0)
    root_lb = float(bd.bound(np.zeros((1, d)))[0][0])
    return dict(gap_r8=float(np.median(cm - lb)), margin_r8=float(np.median(cm - bd.t)),
                certified_r8=float((lb >= bd.thr_safe).mean()), crown_rates=rates, r_star=r50,
                crown_root_lb_minus_t=root_lb - bd.t, bounder_tau=bd.tau)


def box_minimum(net, rng):
    bd = Bounder(net)
    d = bd.d
    info = milp_min(net, np.zeros(d), integer=False, time_limit=MILP_TIME, want_info=True)
    ls = float(box_search(net, np.zeros((1, d)), iters=300, starts=8, rng=rng)[0])
    vals = [v for v in (info["f_x"], ls) if v is not None and math.isfinite(v)]
    status = {0: "optimal", 1: "time limit"}.get(info["status"], info["message"])
    return dict(box_min=min(vals) if vals else None, box_min_milp=info["f_x"], box_min_local=ls,
                box_milp_status=status, box_milp_dual=info["dual_bound"],
                box_witness_below_t=bool(vals and min(vals) < bd.t - bd.tau))


def analyse(e):
    rng = np.random.default_rng(zlib.crc32(e["name"].encode()))
    net = load_net(os.path.join(NETS, e["name"] + ".npz"))
    d, t = net.d, float(net.threshold)
    one = len(net.Ws) == 2
    r = dict(name=e["name"], d=d, widths=e["widths"], loss=e["loss"], p=e.get("p_exact"), z=e["z"], t=t,
             tau=na.forward_error_bound(net), seconds={})
    r["f0_minus_t"] = float(na.exact_output(net, np.zeros(d)) - Fraction(t))

    t0 = time.time()
    r.update(box_minimum(net, rng))
    r["seconds"]["box_min"] = time.time() - t0

    t0 = time.time()
    if d <= 28:
        cp = cube_pass(net)
        r.update(cube_min=cp["cube_min"], s_star_minus_t=cp["s_star"] - t, s_star_exact=True,
                 level1_weight=cp["level1_weight"], level1_exact=True, mean=cp["mean"], var=cp["var"],
                 fail_count_check=cp["fail_count"])
    else:
        sp = sampled_pass(net, rng)
        r.update(cube_min=None, s_star_minus_t=sp["s_star_upper"] - t, s_star_exact=False,
                 level1_weight=sp["level1_weight"], level1_exact=False, mean=sp["mean"], var=sp["var"])
    r["seconds"]["cube_pass"] = time.time() - t0

    t0 = time.time()
    r.update(crown_profile(net, rng))
    r["seconds"]["crown_profile"] = time.time() - t0

    t0 = time.time()
    if one:
        pairs = greedy_pairs(net)
        ch = {"relu1": na.chernoff_holder(net, form="relu").log_value,
              "even1": na.chernoff_holder(net, form="even").log_value,
              "even2": na.chernoff_holder(net, pairs, form="even").log_value}
        k = min(ch, key=ch.get)
        r.update(holder_log=ch, holder_best=math.exp(min(ch[k], 0.0)), holder_which=k,
                 floor1=na.decoupling_floor(net, None, "even"), floor2=na.decoupling_floor(net, pairs, "even"),
                 mcdiarmid=na.mcdiarmid(net).value)
    r["seconds"]["decoupled_bounds"] = time.time() - t0

    t0 = time.time()
    try:
        env = na.tilt_envelope(net) if one else na.tilt_envelope_deep(net)
        r["box_tilt_logZ"] = env.logZ
    except ValueError as exc:
        r["box_tilt_logZ"], r["box_tilt_error"] = None, str(exc)
    r["seconds"]["box_tilt"] = time.time() - t0
    if one:
        t0 = time.time()
        spe = na.sign_pattern_envelope(net)
        r.update(sign_pattern_logZ=spe.logZ, sign_pattern_n_split=len(spe.N))
        r["seconds"]["sign_pattern"] = time.time() - t0
    return r


def main(names, out_path=OUT):
    suite = json.load(open(os.path.join(NETS, "suite.json")))
    out = {}
    for path in {OUT, out_path}:  # results already computed are kept
        if os.path.exists(path):
            out.update({r["name"]: r for r in json.load(open(path))})
    for e in suite:
        if names and e["name"] not in names:
            continue
        r = analyse(e)
        out[e["name"]] = r
        print(json.dumps(r), flush=True)
        order = [x["name"] for x in suite]
        with open(out_path, "w") as f:
            json.dump(sorted(out.values(), key=lambda q: order.index(q["name"])), f, indent=1)


if __name__ == "__main__":
    args = [a for a in sys.argv[1:] if not a.startswith("--out=")]
    outs = [a[6:] for a in sys.argv[1:] if a.startswith("--out=")]
    main(args, os.path.join(HERE, "results", outs[0]) if outs else OUT)
