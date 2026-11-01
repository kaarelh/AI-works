"""Can a small-ball inequality for the positive-weight units alone (Esseen /
Halasz / Littlewood-Offord type, characteristic functions prod_i cos((W^T t)_i),
or even the EXACT joint law of those units) bound p? (one hidden layer, d = 24,
exhaustive)

Write f = c' + L(x) + E+(x) + E-(x) (even form; E+ >= 0 from the units with
a_j > 0, E- <= 0 from the others). A failure means E+ < t - c' - L - E-. A
method that controls only the positive units must bound the right-hand side
over the cube: failure implies E+ <= R := max_x (t - c' - L(x) - E-(x)), so the
best it can certify is

    q+ = Pr_D[E+(x) <= R]     (computed exactly here).

Also reported: q+ with R replaced by the 99.99% quantile of t - c' - L - E-
(what one would get if the negative units could be controlled up to a 1e-4
failure probability), and the 1-dimensional Esseen concentration bound
(96/95)^2 r int_{|s| <= 1/r} |prod_i cos(s w_i)| ds for the most concentrated
single unit at r = its sd / 4, against its exact small-ball probability.

Output: results/smallball.json"""

import json
import math
import os
import sys

import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "..", "..", "code"))
from rareprob.nets import load_net, _half_inputs  # noqa: E402
from rareprob import nets_analytic as na  # noqa: E402

NETS = os.path.join(HERE, "..", "nets")


def run(name, p):
    net = load_net(os.path.join(NETS, name + ".npz"))
    W, b, a, c = na.one_layer(net)
    cp, lam, _ = na.linear_part(net)
    d = net.d
    k1 = d // 2
    HA, HB = _half_inputs(k1), _half_inputs(d - k1)
    ZA = HA @ W[:, :k1].T + b
    ZB = HB @ W[:, k1:].T
    LA, LB = HA @ lam[:k1], HB @ lam[k1:]
    pos, neg = a > 0, a < 0
    Ep_all, Rhs_all = [], []
    for s in range(0, ZA.shape[0], 64):
        Z = ZA[s:s + 64, None, :] + ZB[None, :, :]
        Ep = 0.5 * np.abs(Z[..., pos]) @ a[pos]
        Em = 0.5 * np.abs(Z[..., neg]) @ a[neg]
        L = LA[s:s + 64, None] + LB[None, :]
        Ep_all.append(Ep.ravel())
        Rhs_all.append((net.threshold - cp - L - Em).ravel())
    Ep = np.concatenate(Ep_all)
    Rhs = np.concatenate(Rhs_all)
    R = float(Rhs.max())
    R4 = float(np.quantile(Rhs, 1 - 1e-4))
    rec = {"name": name, "p": p, "Eplus_mean": float(Ep.mean()), "Eplus_sd": float(Ep.std()),
           "R_cube": R, "q_plus": float(np.mean(Ep <= R)), "R_9999": R4, "q_plus_9999": float(np.mean(Ep <= R4)),
           "rhs_mean": float(Rhs.mean())}
    # 1-d Esseen vs exact for the unit with the smallest ||w||_inf / ||w||_2
    j = int(np.argmin(np.abs(W).max(1) / np.linalg.norm(W, axis=1)))
    sd = float(np.linalg.norm(W[j]))
    r = sd / 4
    s = np.linspace(-1 / r, 1 / r, 200001)
    phi = np.abs(np.prod(np.cos(np.outer(s, W[j])), axis=1))
    esseen = (96 / 95) ** 2 * r * float(np.trapezoid(phi, s))
    zj = (HA @ W[j, :k1])[:, None] + (HB @ W[j, k1:])[None, :]
    # sup over centres y of Pr[|z - y| <= r] (grid of centres)
    zs = np.sort(zj.ravel())
    best = 0
    for y in np.linspace(-sd, sd, 401):
        best = max(best, int(np.searchsorted(zs, y + r, side="right") - np.searchsorted(zs, y - r, side="left")))
    rec["esseen_unit"] = {"unit": j, "r_over_sd": 0.25, "esseen_bound": esseen, "exact_sup": best / zs.size,
                          "gaussian": math.erf(0.25 / math.sqrt(2))}
    return rec


if __name__ == "__main__":
    suite = json.load(open(os.path.join(NETS, "suite.json")))
    names = sys.argv[1:] or [e["name"] for e in suite if e["d"] <= 24]
    out = {}
    for nm in names:
        e = next(x for x in suite if x["name"] == nm)
        out[nm] = run(nm, e.get("p_exact"))
        print(json.dumps(out[nm]), flush=True)
        with open(os.path.join(HERE, "results", "smallball.json"), "w") as f:
            json.dump(out, f, indent=1)
