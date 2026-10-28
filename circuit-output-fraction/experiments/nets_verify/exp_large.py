"""Large d (no exact p): what input branch and bound can say at d = 32 ... 128.

For every suite net without an exact p, and for nets trained here at
d = 32, 48, 64 (one hidden layer of width 32, squared loss, 3000 steps):
  * f(0) - t: the centre of the cube lies in the root box; if f(0) < t no
    bound that is valid on the box can certify the root, whatever the method;
  * the fraction of random subcubes with r free coordinates certified by
    CROWN (r = 2 ... d), i.e. how deep the tree must go before anything is
    certified (r50: the largest r with at least half certified; the tree has
    about 2^(d - r50) leaves); when d - r50 <= 30, a full run (900 s limit)
    tries to certify p = 0;
  * the deterministic interval after a budget of 1e7 forward-pass
    equivalents (expected: [0, 1]);
  * Monte Carlo with the same budget (1e7 samples): the number of failures
    seen and the one-sided KL upper bound, for comparison.
Writes results/large.json.
"""

import json
import os
import sys

import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "..", "..", "code"))
from rareprob.nets import load_net, train_constant  # noqa: E402
from rareprob.nets_verify import Bounder, bab  # noqa: E402
from rareprob.stats import kl_interval  # noqa: E402

NETS = os.path.join(HERE, "..", "nets")
OUT = os.path.join(HERE, "results")
BUDGET = 1e7


def analyse(name, net, rng):
    bd = Bounder(net)
    d = bd.d
    o = dict(name=name, d=d, widths=bd.widths, loss=net.loss, t=bd.t, f0_minus_t=float(bd.forward(np.zeros((1, d)))[0] - bd.t))
    cert = {}
    for r in [r for r in [2, 4, 6, 8, 10, 12, 16, 20, 24, 32, 40, 48, 56, 64, 96, 128] if r <= d]:
        X0 = rng.choice([-1, 1], size=(2000, d)).astype(np.int8)
        for b in range(len(X0)):
            X0[b, rng.choice(d, r, replace=False)] = 0
        lb = np.concatenate([bd.bound(X0[s:s + 250])[0] for s in range(0, len(X0), 250)])
        cert[r] = float((lb >= bd.thr_safe).mean())
    o["crown_cert_rate"] = cert
    res = bab(net, r_enum=4, min_rate=0.01, max_fpe=BUDGET, bounder=bd, batch=256)
    o["bab_budget"] = dict(fpe=res.fpe, lo=res.lo, hi=res.hi, depth=res.max_depth, nodes_bounded=res.nodes_bounded,
                          certified_safe_nodes=res.certified_safe_nodes)
    # where would certification start? r50 = largest r with rate >= 1/2;
    # the tree then has at least about 2^(d - r50) leaves
    r50 = max([r for r, v in cert.items() if v >= 0.5], default=0)
    o["crown_r50"] = r50
    if d - r50 <= 30:
        # within reach: try to certify (time limit 900 s)
        full = bab(net, r_enum=6, min_rate=0.01, bounder=bd, batch=256, time_limit=900.0)
        o["bab_full"] = dict(fpe=full.fpe, lo=full.lo, hi=full.hi, exact=full.exact, fail=full.fail,
                             seconds=round(full.seconds, 1), depth=full.max_depth, stopped=full.stopped,
                             nodes_bounded=full.nodes_bounded)
    N = int(BUDGET)
    hits = 0
    for s in range(0, N, 1 << 18):
        X = rng.choice([-1.0, 1.0], size=(min(1 << 18, N - s), d))
        hits += int((bd.forward(X) < bd.t).sum())
    lo, hi = kl_interval(hits / N, N, 0.05)
    o["mc_same_budget"] = dict(samples=N, hits=hits, interval=[lo, hi])
    print(json.dumps(o), flush=True)
    return o


def main():
    rng = np.random.default_rng(64)
    out = []
    suite = json.load(open(os.path.join(NETS, "suite.json")))
    for row in suite:
        if "p_exact" in row:
            continue
        out.append(analyse(row["name"], load_net(os.path.join(NETS, row["name"] + ".npz")), rng))
        json.dump(out, open(os.path.join(OUT, "large.json"), "w"), indent=1)
    for d in [32, 48, 64]:
        net, _ = train_constant(d, [32], 3000, np.random.default_rng(5000 + d))
        # (seeds differ from exp_barrier.py's own_mse_d*_w32_s3000 nets: hence the suffix)
        out.append(analyse(f"own_mse_d{d}_w32_s3000_seedB", net, rng))
        json.dump(out, open(os.path.join(OUT, "large.json"), "w"), indent=1)


if __name__ == "__main__":
    main()
