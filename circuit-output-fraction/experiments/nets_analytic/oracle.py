"""Exhaustive (oracle) diagnostics for the nets with d <= 28: what the best
conceivable analytic bound or envelope of each family could achieve if the
hard quantities were known exactly. None of these is a method.

Per net:
  chernoff_exact   min_theta e^{theta t} E e^{-theta f} with the exact law of f
                   (bin minima of a 2e5-bin histogram: an upper bound on the
                   exact value). It is the mass of the ideal Chernoff envelope
                   exp(theta (t - f)), so K_ideal = chernoff_exact / p.
  theta_star       its optimal tilt; dobrushin_alpha at theta_star (needed < 1
                   for a certified Gibbs sampler of that envelope).
  var_f, R_holder, R_indep_1, R_indep_2
                   (sum_k sd F_k)^2 / Var f and sum_k Var F_k / Var f for the
                   even-form groups (singletons + linear part; greedy pairs +
                   linear part): the factors by which Hoelder (comonotone)
                   and perfect independence inflate the variance; in the
                   Gaussian heuristic log(bound) ~ log(p) / R.
  cap_K[k]         K = Z/p of the smallest ellipsoidal cap {sum_{i<=k}
                   (lambda_i - 1)(u_i.x)^2 >= tau} containing every failing
                   input, u_i the top eigenvectors of E[x x^T | fail] (chosen
                   with hindsight): a lower bound on K for every envelope of
                   this shape, certified or not.
  quad_minorant_mass  Pr[q(x) < t] for the per-unit quadratic minorant q <= f
                   (relu(z) >= z(z-l)/(u-l) for a_j > 0, relu(z) <= (z+s)^2/(4s)
                   for a_j < 0, s optimised over a grid), estimated by sampling;
                   the event of every quadratic/sphere-cap certificate built on q
                   contains {q < t}.

Usage: python3 oracle.py [names...]   (default: all one-hidden-layer nets with
d <= 28, and the two-hidden-layer nets of width 32)."""

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


def enum_blocks(net, rows_per_block=1 << 18):
    """Yield (X, f) over all of {-1,+1}^d by meet in the middle on layer 1."""
    d = net.d
    k1 = d // 2
    k2 = d - k1
    W, b = net.Ws[0], net.bs[0]
    HA, HB = _half_inputs(k1), _half_inputs(k2)
    A = HA @ W[:, :k1].T + b
    B = HB @ W[:, k1:].T
    rows = max(1, rows_per_block // B.shape[0])
    for s in range(0, A.shape[0], rows):
        Z = (A[s:s + rows, None, :] + B[None, :, :]).reshape(-1, W.shape[0])
        h = np.maximum(Z, 0.0)
        for Wl, bl in zip(net.Ws[1:-1], net.bs[1:-1]):
            h = np.maximum(h @ Wl.T + bl, 0.0)
        f = (h @ net.Ws[-1].T + net.bs[-1])[:, 0]
        yield (s, rows, HA, HB), f


def xs_of(idx_info, mask):
    (s, rows, HA, HB) = idx_info
    ii = np.nonzero(mask)[0]
    a = s + ii // HB.shape[0]
    bb = ii % HB.shape[0]
    return np.concatenate([HA[a], HB[bb]], axis=1)


def oracle(name, caps=True):
    net = load_net(os.path.join(NETS, name + ".npz"))
    d, t = net.d, float(net.threshold)
    r = {"name": name}
    t0 = time.time()
    edges = np.linspace(-60, 60, 400001)
    cnt = np.zeros(400000)
    mn = np.full(400000, np.inf)
    fails = []
    for info, f in enum_blocks(net):
        ix = np.clip(np.searchsorted(edges, f, side="right") - 1, 0, 399999)
        cnt += np.bincount(ix, minlength=400000)
        np.minimum.at(mn, ix, f)
        m = f < t
        if m.any() and sum(len(x) for x in fails) < 200000:
            fails.append(xs_of(info, m))
    ok = cnt > 0
    P = cnt[ok] / 2.0 ** d
    v = mn[ok]
    from scipy.optimize import minimize_scalar

    def lb(lt):
        th = math.exp(lt)
        return th * t + na._lse(-th * v, P)

    best = min((minimize_scalar(lb, bounds=(lo, lo + 3), method="bounded") for lo in range(-6, 9, 2)),
               key=lambda q: q.fun)
    r["chernoff_exact"] = math.exp(min(best.fun, 0.0))
    r["theta_star"] = math.exp(best.x)
    r["p_enum"] = float(cnt[edges[:-1][ok] < t].sum() / 2.0 ** d) if False else None
    r["var_f"] = float(np.dot(P, v ** 2) - np.dot(P, v) ** 2)
    r["enum_seconds"] = time.time() - t0
    F = np.concatenate(fails) if fails else np.zeros((0, d))
    r["n_fail_collected"] = int(len(F))
    if len(net.Ws) == 2:
        W, b, a, c = na.one_layer(net)
        r["dobrushin_alpha_theta_star"] = dobrushin_alpha(net, r["theta_star"])
        rng = np.random.default_rng(1)
        X = rng.choice([-1.0, 1.0], size=(200000, d))
        Z = X @ W.T + b
        E = 0.5 * np.abs(Z) * a
        cp, lam, _ = na.linear_part(net)
        L = X @ lam
        fv = net.forward(X)
        vf = fv.var()
        sds = list(E.std(0)) + [L.std()]
        r["R_holder_1"] = float(sum(sds) ** 2 / vf)
        r["R_indep_1"] = float((E.var(0).sum() + L.var()) / vf)
        pairs = greedy_pairs(net)
        Gs = [E[:, G].sum(1) for G in pairs] + [L]
        r["R_holder_2"] = float(sum(g.std() for g in Gs) ** 2 / vf)
        r["R_indep_2"] = float(sum(g.var() for g in Gs) / vf)
        # quadratic minorant mass
        lo, hi = na.box_bounds(net)[0]
        Pm = a > 0
        best_q = 1.0
        for sc in [0.25, 0.5, 1, 2, 4, 8, 16]:
            s = sc * np.ones((~Pm).sum())
            q = c + (Z[:, Pm] * (Z[:, Pm] - lo[Pm]) / (hi[Pm] - lo[Pm])) @ a[Pm] \
                + ((Z[:, ~Pm] + s) ** 2 / (4 * s)) @ a[~Pm]
            best_q = min(best_q, float((q < t).mean()))
        r["quad_minorant_mass"] = best_q
    if caps and len(F) > 0:
        S = F.T @ F / len(F)
        ev, Uv = np.linalg.eigh(S)
        ev, Uv = ev[::-1], Uv[:, ::-1]
        kmax = 4
        wts = ev[:kmax] - 1.0
        qa_f = [((F @ Uv[:, :k]) ** 2) @ wts[:k] for k in range(1, kmax + 1)]
        taus = [x.min() for x in qa_f]
        hits = np.zeros(kmax)
        for info, f in enum_blocks(net):
            X = xs_of(info, np.ones(f.shape[0], dtype=bool))
            Pj = (X @ Uv[:, :kmax]) ** 2
            for k in range(1, kmax + 1):
                hits[k - 1] += float(((Pj[:, :k] @ wts[:k]) >= taus[k - 1] - 1e-9).sum())
        r["cap_Z"] = [h / 2.0 ** d for h in hits]
        r["fail_cov_top_eigs"] = [float(x) for x in ev[:4]]
    r["seconds"] = time.time() - t0
    return r


if __name__ == "__main__":
    suite = json.load(open(os.path.join(NETS, "suite.json")))
    names = sys.argv[1:] or [e["name"] for e in suite if e["d"] <= 28 and
                             (len(e["widths"]) == 1 or e["widths"][0] <= 32)]
    out_path = os.path.join(HERE, "results", "oracle.json")
    res = json.load(open(out_path)) if os.path.exists(out_path) else {}
    for nm in names:
        e = next(x for x in suite if x["name"] == nm)
        r = oracle(nm, caps=(e["d"] <= 24 or len(e["widths"]) == 1))
        r["p"] = e.get("p_exact")
        res[nm] = r
        print(json.dumps(r), flush=True)
        with open(out_path, "w") as f:
            json.dump(res, f, indent=1)
