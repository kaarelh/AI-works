"""Where the failures come from (one hidden layer, exhaustive, d <= 28).

f = c' + L(x) + E+(x) + E-(x) with L = lam.x (lam = (1/2) sum_j a_j w_j),
E+ = sum_{a_j > 0} (a_j/2)|z_j| and E- = sum_{a_j < 0} (a_j/2)|z_j|. For each part:
mean and sd under D (400000 samples), mean over the failing inputs
(exhaustive), and the shift in sd units; also the correlation of E+ and E-
under D, and the mean |z_j| / sd(z_j) at the failures for the positive and
the negative units. Output: results/decompose.json."""

import json
import os
import sys

import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "..", "..", "code"))
from rareprob.nets import load_net, _half_inputs  # noqa: E402
from rareprob import nets_analytic as na  # noqa: E402

names = sys.argv[1:] or ["mse_d24_w32_s1000", "mse_d24_w32_s1500", "mse_d28_w64_s600", "bce_d28_w32_s60",
                         "bce_d28_w32_s100"]
out = {}
for name in names:
    net = load_net(os.path.join(HERE, "..", "nets", name + ".npz"))
    W, b, a, c = na.one_layer(net)
    cp, lam, _ = na.linear_part(net)
    orc = na.EnumMAPOracle(net, np.float64 if net.d <= 24 else np.float32)
    ia, ib = np.nonzero(orc.F < net.threshold)
    F = np.concatenate([_half_inputs(orc.k1)[ia], _half_inputs(orc.k2)[ib]], axis=1)
    F = F[net.forward(F) < net.threshold]  # recheck in float64
    del orc
    X = np.random.default_rng(0).choice([-1.0, 1.0], size=(400000, net.d))

    def parts(X):
        Z = X @ W.T + b
        return {"lin": X @ lam, "even": 0.5 * np.abs(Z) @ a,
                "even+": 0.5 * np.abs(Z[:, a > 0]) @ a[a > 0], "even-": 0.5 * np.abs(Z[:, a < 0]) @ a[a < 0]}

    R, Fp = parts(X), parts(F)
    sdz = np.abs(X @ W.T + b).std(0)
    zf = np.abs(F @ W.T + b) / np.sqrt(((X @ W.T + b) ** 2).mean(0))
    zr = np.abs(X @ W.T + b) / np.sqrt(((X @ W.T + b) ** 2).mean(0))
    rec = {"n_fail": int(len(F)), "c_prime": cp, "t": net.threshold,
           "corr_even+_even-": float(np.corrcoef(R["even+"], R["even-"])[0, 1]),
           "rms_ratio_|z|_pos_fail_vs_all": float(zf[:, a > 0].mean() / zr[:, a > 0].mean()),
           "rms_ratio_|z|_neg_fail_vs_all": float(zf[:, a < 0].mean() / zr[:, a < 0].mean())}
    for k in R:
        rec[k] = {"mean": float(R[k].mean()), "sd": float(R[k].std()), "mean_at_fail": float(Fp[k].mean()),
                  "shift_sd": float((Fp[k].mean() - R[k].mean()) / R[k].std())}
    out[name] = rec
    print(name, json.dumps(rec), flush=True)
json.dump(out, open(os.path.join(HERE, "results", "decompose.json"), "w"), indent=1)
