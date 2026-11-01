"""Why CROWN certifies only small subcubes: its looseness grows with the
number r of free coordinates, while the margin min f - t does not.

For random subcubes with r free coordinates (fixed coordinates uniform), the
medians over 100 subcubes of
  margin        cube min - t (exact, by enumerating the subcube),
  crown_gap     cube min - CROWN lower bound,
  alpha_gap     cube min - lower bound with optimised slopes (one hidden
                layer; close to the LP / triangle relaxation),
  centre_gap    cube min - f(box centre): a LOWER bound on the gap of every
                bound that is valid on the subcube's box (the centre, free
                coordinates 0, is a point of the box),
and the fraction certified by CROWN and by optimised slopes. A subcube can
be certified only if gap < margin. Also the mean per-coordinate influence
iota = mean_i sum_j |a_j| |W_ji| (one hidden layer). Writes results/gap.json.
"""

import json
import os
import sys

import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "..", "..", "code"))
from rareprob.nets import load_net  # noqa: E402
from rareprob.nets_verify import Bounder  # noqa: E402

NETS = os.path.join(HERE, "..", "nets")
OUT = os.path.join(HERE, "results")

NAMES = ["mse_d24_w32_s1000", "mse_d24_w32_s1500", "mse_d24_w32_s2000", "mse_d28_w64_s600", "mse_d28_w64_s1000",
         "mse_d28_w64_s1500", "bce_d28_w32_s60", "bce_d28_w32_s100", "bce_d28_w32_s150",
         "own_mse_d16_w32_s1500", "own_mse_d24_w32_s3000", "own_mse_d32_w32_s1500", "own_mse_d32_w32_s3000",
         "own_mse_d48_w32_s1500", "own_mse_d48_w32_s3000", "own_mse_d64_w32_s1500", "own_mse_d64_w32_s3000"]


def main(n=100, rs=(2, 4, 6, 8, 10, 12, 14)):
    out = []
    for name in NAMES:
        f = os.path.join(OUT if name.startswith("own") else NETS, name + ".npz")
        if not os.path.exists(f):
            continue
        net = load_net(f)
        bd = Bounder(net)
        d = bd.d
        rng = np.random.default_rng(0)
        iota = float((np.abs(bd.Ws[1][0]) @ bd.absW[0]).mean()) if bd.L == 1 else None
        rows = []
        for r in rs:
            X0 = rng.choice([-1, 1], size=(n, d)).astype(np.int8)
            for b in range(n):
                X0[b, rng.choice(d, r, replace=False)] = 0
            lb, _, _ = bd.bound(X0)
            la = np.maximum(lb, bd.alpha_bound(X0, 50)) if bd.L == 1 else lb
            idx = np.arange(1 << r)
            P = np.where((idx[:, None] >> np.arange(r)) & 1, 1.0, -1.0)
            cm = np.empty(n)
            for b in range(n):
                fr = np.nonzero(X0[b] == 0)[0]
                X = np.repeat(X0[b][None].astype(float), len(P), 0)
                X[:, fr] = P
                cm[b] = bd.forward(X).min()
            fc = bd.forward(X0.astype(float))
            rows.append(dict(r=r, margin=float(np.median(cm - bd.t)), crown_gap=float(np.median(cm - lb)),
                             alpha_gap=float(np.median(cm - la)), centre_gap=float(np.median(cm - np.minimum(fc, cm))),
                             crown_cert=float((lb >= bd.thr_safe).mean()), alpha_cert=float((la >= bd.thr_safe).mean()),
                             cube_safe=float((cm >= bd.t).mean()), centre_fails=float((fc < bd.t).mean())))
        o = dict(name=name, d=d, widths=bd.widths, loss=net.loss, iota=iota, rows=rows)
        print(json.dumps(o), flush=True)
        out.append(o)
        json.dump(out, open(os.path.join(OUT, "gap.json"), "w"), indent=1)


if __name__ == "__main__":
    main()
