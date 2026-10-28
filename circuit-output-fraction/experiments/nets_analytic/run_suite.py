"""Run the rigorous prover-free methods of rareprob.nets_analytic on every net
of experiments/nets/suite.json and compare with the exact failure probability.

Output: results/suite.json (one record per net) and a table on stdout.

Per net (one hidden layer):
  CH_relu1   Chernoff-Hoelder, relu form, singleton groups        (upper bound)
  CH_even1   Chernoff-Hoelder, even form, singleton groups + lin   (upper bound)
  CH_even2   Chernoff-Hoelder, even form, greedy pairs + lin       (upper bound)
  floor1     decoupling floor, even form, singletons (a LOWER bound on every
             Hoelder/BL/Finner-type decoupled Chernoff bound with these groups)
  floor2     the same for the greedy pairs
  mcd        McDiarmid with the certified mean                     (upper bound)
  tiltZ      mass of the best exponential-tilt envelope (K = Z/p)
  groupZ     mass of the tilt envelope keeping the top pair exactly
  (the sign-pattern envelopes are run by signpattern.py)
Two hidden layers: tiltZ from the CROWN affine minorant.
MC cost: 3 ln(2/delta) / (eps^2 p) samples with eps = 0.1, delta = 0.05; an
envelope of mass Z costs about Z times that (speed-up 1/Z); an upper bound U
is worth about ln(1/delta)/U Monte Carlo samples (one-sided).
"""

import json
import math
import os
import sys
import time

import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "..", "..", "code"))
from rareprob.nets import load_net  # noqa: E402
from rareprob import nets_analytic as na  # noqa: E402

NETS = os.path.join(HERE, "..", "nets")
EPS, DELTA = 0.1, 0.05


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
    sampler of the ideal envelope exp(theta (t - F))."""
    W, b, a, c = na.one_layer(net)
    Aw = np.abs(W)
    d = net.d
    D = np.zeros((d, d))
    for j in range(W.shape[0]):
        D += abs(a[j]) * 4 * np.minimum(Aw[j][:, None], Aw[j][None, :])
    np.fill_diagonal(D, 0)
    return float(np.max(np.tanh(theta * D / 4).sum(axis=1)))


def run(names=None):
    suite = json.load(open(os.path.join(NETS, "suite.json")))
    out = []
    for e in suite:
        if names and e["name"] not in names:
            continue
        net = load_net(os.path.join(NETS, e["name"] + ".npz"))
        p = e.get("p_exact")
        r = {"name": e["name"], "d": e["d"], "widths": e["widths"], "loss": e["loss"], "p": p,
             "z": e["z"], "f0": float(net.forward(np.zeros((1, net.d)))[0]), "t": net.threshold,
             "f0_minus_t": float(net.forward(np.zeros((1, net.d)))[0]) - net.threshold,
             "tau": na.forward_error_bound(net)}
        r["N_MC"] = 3 * math.log(2 / DELTA) / (EPS ** 2 * p) if p else None
        t0 = time.time()
        if len(net.Ws) == 2:
            r["CH_relu1"] = na.chernoff_holder(net, form="relu").log_value
            r["CH_even1"] = na.chernoff_holder(net, form="even").log_value
            pairs = greedy_pairs(net)
            r["CH_even2"] = na.chernoff_holder(net, pairs, form="even").log_value
            r["floor1"] = na.decoupling_floor(net, None, "even")
            r["floor2"] = na.decoupling_floor(net, pairs, "even")
            r["floor1_relu"] = na.decoupling_floor(net, None, "relu")
            m = na.mcdiarmid(net)
            r["mcd"] = m.log_value
            env = na.tilt_envelope(net)
            r["tilt_logZ"] = env.logZ
            W, b, a, c = na.one_layer(net)
            top = sorted(pairs, key=lambda G: -sum(abs(a[j]) * np.linalg.norm(W[j]) for j in G))[0]
            genv = na.group_tilt_envelope(net, top, budget=200, restarts=1)
            r["group_logZ"] = genv.logZ
            r["group_S"] = [int(j) for j in top]
            # Dobrushin coefficient at the Chernoff tilt of the floor (the
            # natural temperature of the ideal envelope)
            r["dobrushin_alpha_theta10"] = dobrushin_alpha(net, 10.0)
        else:
            env = na.tilt_envelope_deep(net)
            r["tilt_logZ"] = env.logZ
        r["seconds"] = time.time() - t0
        out.append(r)
        print(json.dumps(r), flush=True)
    return out


if __name__ == "__main__":
    res = run(sys.argv[1:] or None)
    with open(os.path.join(HERE, "results", "suite.json" if len(sys.argv) == 1 else "suite_partial.json"), "w") as f:
        json.dump(res, f, indent=1)
