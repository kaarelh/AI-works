"""Why perturb-and-MAP captures large deviations but not small balls (toy
events on the uniform cube, exact).

With single-coordinate Gumbel perturbations and phi = log 1_C, the bound of
rareprob.nets_analytic.perturb_map_samples reads

    log Pr[x in C] <= -E dist_l(xhat, C),

xhat uniform on the cube and dist_l the Hamming distance weighted by i.i.d.
|Logistic| weights l_i (the gap between the two Gumbels of coordinate i;
mean 2 ln 2). Computed here by sampling (exact minimisation by sorting) for

  subcube   C = {x_1 = ... = x_k = 1}               (k = d/4)
  halfspace C = {sum_i x_i >= s}                     (s = 2 sqrt(d), 3 sqrt(d))
  small ball C = {|sum_i x_i| <= r}                  (r = 0 or 1, by parity)

against the exact log Pr[C] (binomial). Output: results/pmap_toy.json"""

import json
import math
import os

import numpy as np
from scipy.stats import binom

HERE = os.path.dirname(os.path.abspath(__file__))


def run(d, n=20000, seed=0):
    rng = np.random.default_rng(seed)
    xh = rng.choice([-1, 1], size=(n, d))
    ell = np.abs(rng.logistic(size=(n, d)))
    S = xh.sum(1)
    out = {}
    # subcube
    k = d // 4
    dist = np.where(xh[:, :k] == 1, 0.0, ell[:, :k]).sum(1)
    out["subcube"] = {"log_p": -k * math.log(2), "bound": -float(dist.mean())}
    for c in (2, 3):
        s = int(math.ceil(c * math.sqrt(d)))
        s += (s - d) % 2  # parity of sum_i x_i is that of d
        need = np.maximum(0, np.ceil((s - S) / 2)).astype(int)
        cand = np.where(xh == -1, ell, np.inf)
        cand.sort(axis=1)
        cs = np.concatenate([np.zeros((n, 1)), np.cumsum(cand, axis=1)], axis=1)
        dist = cs[np.arange(n), need]
        logp = float(binom.logsf((s + d) // 2 - 1, d, 0.5))
        out[f"halfspace_{c}sqrtd"] = {"s": s, "log_p": logp, "bound": -float(dist.mean())}
    r = d % 2
    need = np.maximum(0, np.ceil((np.abs(S) - r) / 2)).astype(int)
    maj = np.where(S[:, None] >= 0, xh == 1, xh == -1)
    cand = np.where(maj, ell, np.inf)
    cand.sort(axis=1)
    cs = np.concatenate([np.zeros((n, 1)), np.cumsum(cand, axis=1)], axis=1)
    dist = cs[np.arange(n), need]
    lp = float(np.log(sum(binom.pmf(j, d, 0.5) for j in range(d + 1) if abs(2 * j - d) <= r)))
    out["small_ball"] = {"r": r, "log_p": lp, "bound": -float(dist.mean())}
    return out


if __name__ == "__main__":
    res = {d: run(d) for d in (24, 100, 400, 1600)}
    for d, r in res.items():
        print(d, json.dumps(r))
    with open(os.path.join(HERE, "results", "pmap_toy.json"), "w") as f:
        json.dump(res, f, indent=1)
