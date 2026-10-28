"""Why relaxations of the input domain are blind to the small-ball failures.

The cube is the intersection of the box [-1,1]^d and the sphere |x|^2 = d.
A certificate that p = 0 (or that a subcube holds no failure) obtained from a
relaxation of the input domain can only succeed if f >= t on the relaxed set.
For each net we exhibit points (local search, so these are UPPER bounds on the
relaxed minima, hence rigorous witnesses that the relaxation fails when < t):

  box_min     min of f over [-1,1]^d found by projected gradient descent
              (every convex relaxation of the cube contains the box),
  sphere_min  min of f over the sphere of radius sqrt(d) (spectral / norm-based
              arguments see only the sphere),
  f_center    f(0),
and the exact cube minimum (from enumerate.py, d <= 28). For one hidden layer
also: m+ (units with a_j > 0), rank of W+ (the positive units' weights), the
dimension of the null space of W+ (if m+ < d the sphere meets it, where all
positive units vanish up to their biases), and the smallest singular value of
W+ relative to the median.

usage: python3 geometry.py [name ...]
"""

import json
import os
import sys

import numpy as np

from common import RES, suite, suite_net


def grad_f(net, X):
    """f and df/dx for a batch."""
    f, pre = net.forward(X, keep=True)
    delta = np.ones((X.shape[0], 1)) * net.Ws[-1]  # (N, width_last)
    for k in range(len(net.Ws) - 1, 0, -1):
        delta = (delta * (pre[k - 1] > 0)) @ net.Ws[k - 1]
    return f, delta


def local_min(net, d, rng, domain, starts=256, iters=600, lr=0.05):
    X = rng.uniform(-1, 1, size=(starts, d))
    if domain == "sphere":
        X = rng.standard_normal((starts, d))
        X *= np.sqrt(d) / np.linalg.norm(X, axis=1, keepdims=True)
    else:
        X[0] = 0.0
    best = np.inf
    for it in range(iters):
        f, g = grad_f(net, X)
        best = min(best, float(f.min()))
        step = lr * (1 - it / iters) + 1e-3
        if domain == "sphere":
            g = g - (np.sum(g * X, axis=1, keepdims=True) / d) * X
            X = X - step * np.sqrt(d) * g / (np.linalg.norm(g, axis=1, keepdims=True) + 1e-12)
            X *= np.sqrt(d) / np.linalg.norm(X, axis=1, keepdims=True)
        else:
            X = np.clip(X - step * g / (np.abs(g).max(axis=1, keepdims=True) + 1e-12), -1, 1)
    f = net.forward(X)
    return min(best, float(f.min()))


def main():
    names = sys.argv[1:] or [r["name"] for r in suite()]
    rng = np.random.default_rng(13)
    rows = []
    for name in names:
        net = suite_net(name)
        d, t = net.d, net.threshold
        o = dict(name=name, d=d, widths=net.widths, loss=net.loss, threshold=t)
        ep = os.path.join(RES, "enum", name + ".json")
        if os.path.exists(ep):
            e = json.load(open(ep))
            o["cube_min"], o["p"] = e["fmin"], e["p_exact"]
        o["f_center"] = float(net.forward(np.zeros((1, d)))[0])
        o["box_min"] = local_min(net, d, rng, "box")
        o["sphere_min"] = local_min(net, d, rng, "sphere")
        if len(net.Ws) == 2:
            W, a = net.Ws[0], net.Ws[1][0]
            Wp = W[a > 0]
            s = np.linalg.svd(Wp, compute_uv=False)
            o["m_pos"], o["m_neg"] = int((a > 0).sum()), int((a <= 0).sum())
            o["rank_pos"] = int(np.linalg.matrix_rank(Wp))
            o["null_dim_pos"] = d - o["rank_pos"]
            o["smin_rel_pos"] = float(s[-1] / np.median(s)) if len(s) >= d else 0.0
        rows.append(o)
        print({k: (round(v, 4) if isinstance(v, float) else v) for k, v in o.items()}, flush=True)
        with open(os.path.join(RES, "geometry.json"), "w") as fh:
            json.dump(rows, fh, indent=1)


if __name__ == "__main__":
    main()
