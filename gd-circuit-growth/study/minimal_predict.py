"""Analytic sample-complexity predictor for the minimal model (models/minimal.py), from the target alone.

Everything is computed exactly in population on the cube of the target's relevant variables (at most 10 of them, so at
most 1024 points); the input dimension d enters only through the noise law N(k) and the Hebbian noise.

predict_curve(fn, c, a, d)   the minimal model's noiseless run at each n on a fine grid ("population greedy path"):
    * order-1 unit: the Hebbian feature h.x with h = E[y x] (population), with its sampling noise: the
      fitted readout F(x) is perturbed by a Gaussian of variance  a_h^2 d Var(y) / (n |h|^2)  (a_h = the readout
      weight of the standardised Hebbian feature), so the predicted test error is  E_x Phi(-y(x) F(x) / sigma_n);
    * literals are active once  n rho(y, x_i)^2 > c d;
    * stage after stage, the candidate gate with the largest  rho^2 / N(k)  is accepted if  n rho^2 / N(k) > c,
      with population correlations rho and the model's noise law N(k); least-squares readout in population.
    Returns the predicted test-error curve and n* (the n at which it crosses 0.1, log-interpolated as in common.py).

bottleneck(fn, c, a, d)      the closed form: on the greedy path at n just above the predicted n*, with i* the first
    stage whose population error is <= 0.1,
        n*_closed = max( n_Hebb , c * max_{i <= i*} N(k_i) / rho_i^2 ),
    where n_Hebb solves the Hebbian noise equation E_x Phi(-y F_{i*}(x) / sigma_n) = 0.1 for the readout F_{i*} of that
    stage.  It reproduces the curve's n* (up to the grid) and names the binding term: the Hebbian noise or one move.
"""
import os, sys, math, itertools
import numpy as np
from scipy.stats import norm

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from models.minimal import search, moments, noise_count, n_candidates, _gate_out, F32
from boolfuncs import make_suite

_CUBES = {}


def relevant_cube(fn, d=30, suite=None):
    """(Xr, y, rel): the uniform cube on the exactly relevant variables of target fn (all targets use only x_1..x_10)."""
    key = (fn, d)
    if key in _CUBES:
        return _CUBES[key]
    S = suite or make_suite(d)
    f = S[fn]["fn"]
    m = min(10, d)
    Z = np.array(list(itertools.product([-1.0, 1.0], repeat=m)))
    X = np.ones((len(Z), d)); X[:, :m] = Z
    y = f(X)
    rel = []
    for i in range(m):
        Xf = X.copy(); Xf[:, i] *= -1
        if np.any(f(Xf) != y):
            rel.append(i)
    Zr = np.array(list(itertools.product([-1.0, 1.0], repeat=len(rel)))) if rel else np.zeros((1, 0))
    Xr = np.ones((len(Zr), d)); Xr[:, rel] = Zr
    yr = f(Xr)
    out = (Zr.astype(F32), yr.astype(np.float64), rel)
    _CUBES[key] = out
    return out


def _ls(F, y):
    F1 = np.concatenate([np.ones((len(y), 1)), F], 1)
    w = np.linalg.lstsq(F1, y, rcond=None)[0]
    return w, F1 @ w


def population_run(Xr, y, n, c, a, d, law="search", fmax=4, gmax=48, dense2=True):
    """The minimal model's noiseless run at sample size n.  Returns dict(stages, F (cube values), a_h, hnorm2, vy)."""
    m, r_ = Xr.shape
    vy = float(np.var(y))
    stages = []
    if r_ == 0:
        return dict(stages=stages, F=np.full(m, y.mean()), a_h=0.0, hnorm2=0.0, vy=vy)
    Xs = Xr.astype(np.float64)
    h = Xs.T @ (y - y.mean()) / m
    hn2 = float(h @ h)
    cols = []
    hcol = (Xs @ h) / math.sqrt(hn2) if hn2 > 1e-12 else None
    _mc = {}

    def Mlit(order):
        if order not in _mc:
            _mc[order] = moments(Xr, np.ones(m, F32), order)
        return _mc[order]

    def refit():
        F = [hcol] if hcol is not None else []
        F = np.stack(F + cols, 1) if (F or cols) else np.zeros((m, 0))
        return _ls(F, y)

    w, F = refit()
    active = np.zeros(r_, bool)
    N1 = noise_count(1, d, a, 0, law, n_candidates(1, 0, d, 0, 1))
    if vy > 1e-12:
        active |= n * h ** 2 / vy / N1 > c
    GW = np.zeros((m, 0), F32)
    err = float(np.mean(np.where(F > 0, 1.0, -1.0) != y))
    while len(cols) < gmax and err > 0:
        r = y - F
        sr2 = float(np.var(r))
        if sr2 < 1e-12:
            break
        rho_l2 = ((Xs.T @ (r - r.mean())) / m) ** 2 / sr2
        active |= n * rho_l2 / N1 > c
        best = search(Xr, Mlit, r, active, GW, c, a, law, fmax, n_eff=n, d_count=d, dense2=dense2)
        if best is None or best["z2"] <= c:
            break
        g = dict(best, nwires=GW.shape[1])
        out, ind = _gate_out(Xr, GW, g)
        if out.std() < 1e-9:
            break
        cols.append((out - out.mean()) / out.std())
        if g["depth"] == 1:
            active[g["S"]] = True
            if 0 < ind.mean() < 1:
                GW = np.concatenate([GW, (2.0 * ind - 1.0).astype(F32)[:, None]], 1)
        w, F = refit()
        err = float(np.mean(np.where(F > 0, 1.0, -1.0) != y))
        stages.append(dict(depth=g["depth"], f=g["f"], k=g["k"], rho2=g["rho2"], N=g["N"], z2=g["z2"],
                           n_thr=c * g["N"] / g["rho2"], err=err, dense=bool(g.get("dense", False))))
    a_h = float(w[1]) if hcol is not None else 0.0
    return dict(stages=stages, F=F, a_h=a_h, hnorm2=hn2, vy=vy)


def noisy_error(run, y, n, d):
    """Predicted test error of the readout F with the Hebbian sampling noise."""
    F = run["F"]
    if run["a_h"] == 0.0 or run["hnorm2"] <= 1e-12:
        return float(np.mean(np.where(F > 0, 1.0, -1.0) != y))
    sig = abs(run["a_h"]) * math.sqrt(d * run["vy"] / (n * run["hnorm2"]))
    return float(np.mean(norm.cdf(-y * F / sig)))


def _crossing(ns, err, thr=0.1):
    ln = np.log2(ns)
    for i in range(len(err)):
        if err[i] <= thr:
            if i == 0:
                return float(ns[0])
            f = (err[i - 1] - thr) / max(err[i - 1] - err[i], 1e-12)
            return float(2 ** (ln[i - 1] + f * (ln[i] - ln[i - 1])))
    return np.inf


def predict_curve(fn, c, a, d=30, law="search", ns=None, fmax=4, suite=None, first_cross=False, dense2=True):
    """Predicted test-error curve on a grid of n (log2 step 1/8 from 2^3 to 2^17 by default) and its 0.1 crossing.
    first_cross: scan upward in steps of 1/4 and stop after the first crossing (refined to 1/16) -- for calibration."""
    Xr, y, rel = relevant_cube(fn, d, suite)
    run = lambda n: noisy_error(population_run(Xr, y, n, c, a, d, law, fmax, dense2=dense2), y, n, d)
    if first_cross:
        prev_n, prev_e = None, None
        for l in np.arange(3, 17.01, 0.25):
            e = run(2.0 ** l)
            if e <= 0.1:
                if prev_n is None:
                    return dict(nstar=2.0 ** l, rel=rel)
                grid = 2.0 ** np.arange(l - 0.25, l + 0.001, 0.0625)
                errs = [prev_e] + [run(n) for n in grid[1:]]
                return dict(nstar=_crossing(grid, np.array(errs)), rel=rel)
            prev_n, prev_e = 2.0 ** l, e
        return dict(nstar=np.inf, rel=rel)
    ns = np.array(ns if ns is not None else 2.0 ** np.arange(3, 17.01, 0.125))
    err = np.array([run(n) for n in ns])
    return dict(ns=ns, err=err, nstar=_crossing(ns, err), rel=rel)


def bottleneck(fn, c, a, d=30, law="search", fmax=4, suite=None, dense2=True):
    """Closed-form decomposition of the predicted n*: on the greedy path at n just above the predicted n*, with
    i* the first stage whose population error is <= 0.1,
        n*_closed = max( n_Hebb , max_{i <= i*} c N(k_i) / rho_i^2 ),
    n_Hebb solving E_x Phi(-y F_{i*}(x) / sigma_n) = 0.1 for the readout F_{i*} of that stage.  Returns the binding
    term ('hebb' or the bottleneck move) so that every n* can be read as one explicit formula."""
    p = predict_curve(fn, c, a, d, law, fmax=fmax, suite=suite, first_cross=True, dense2=dense2)
    if not np.isfinite(p["nstar"]):
        return dict(nstar=np.inf, n_hebb=np.inf, n_gate=np.inf, binding=None, stages=[], rel=p["rel"])
    Xr, y, rel = relevant_cube(fn, d, suite)
    n0 = 1.02 * p["nstar"]
    run = population_run(Xr, y, n0, c, a, d, law, fmax, dense2=dense2)
    st = run["stages"]
    base = population_run(Xr, y, n0, c, a, d, law, fmax, gmax=0, dense2=dense2)
    base_err = float(np.mean(np.where(base["F"] > 0, 1.0, -1.0) != y))
    i_star = -1 if base_err <= 0.1 else next((i for i, s in enumerate(st) if s["err"] <= 0.1), None)
    if i_star is None:
        i_star = len(st) - 1
    run_t = population_run(Xr, y, n0, c, a, d, law, fmax, gmax=i_star + 1, dense2=dense2)
    lo, hi = 1.0, 2.0 ** 30
    if noisy_error(run_t, y, hi, d) > 0.1:
        n_hebb = np.inf
    else:
        for _ in range(60):
            mid = math.sqrt(lo * hi)
            lo, hi = (mid, hi) if noisy_error(run_t, y, mid, d) > 0.1 else (lo, mid)
        n_hebb = hi if run_t["a_h"] != 0.0 else 0.0
    used = st[:i_star + 1]
    n_gate = max([s["n_thr"] for s in used], default=0.0)
    if n_hebb >= n_gate:
        binding = "hebb"
    else:
        s = max(used, key=lambda s: s["n_thr"])
        binding = f"{'spectral' if s.get('dense') else 'gate'} f={s['f']} k={s['k']} rho2={s['rho2']:.3f} N={s['N']:.1f}"
    return dict(nstar=max(n_hebb, n_gate), n_curve=p["nstar"], n_hebb=n_hebb, n_gate=n_gate, binding=binding,
                i_star=i_star, stages=used, rel=rel)


if __name__ == "__main__":
    import common as C
    c, a = float(sys.argv[1]), float(sys.argv[2])
    for fn in (sys.argv[3].split(",") if len(sys.argv) > 3 else C.FNS):
        p = predict_curve(fn, c, a, C.D)
        b = bottleneck(fn, c, a, C.D)
        print(f"{fn:11s} n*_curve={p['nstar']:8.0f}  n*_closed={b['nstar']:8.0f} (hebb {b['n_hebb']:.0f}, gates {b['n_gate']:.0f}) "
              f"binding: {b['binding']}  path: " + " ".join(f"[d{s['depth']}f{s['f']}k{s['k']} rho2={s['rho2']:.3f} N={s['N']:.0f} err={s['err']:.2f}]"
                                                    for s in b["stages"][:6]))
