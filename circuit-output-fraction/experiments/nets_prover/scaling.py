"""Certificate cost versus input dimension d, on nets trained here with
rareprob.nets.train_constant (one hidden layer of width 32; squared loss for
1500 steps and logistic loss for 100 steps, three seeds each).

For every net: the exact p (verifier's own meet-in-the-middle count) when
d <= 26, otherwise a Monte Carlo estimate (10^6 samples, information only);
Knuth estimates (128 probes) of the prover's tree with 'lin' certificates
(r_leaf = 5): nodes and verifier cost in forward-pass equivalents; the cost
of enumerating the cube; Monte Carlo's cost 3 ln(2/delta) / (eps^2 p) for
eps = 0.1, delta = 0.05. For d <= 24 also the real prover + verifier
(exact certificate, collapsed), to calibrate the estimates.

Usage: python3 scaling.py  -> results/scaling.json
"""
import json
import math
import os
import sys
import time

import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "..", "..", "code"))
from rareprob.nets import train_constant  # noqa: E402
from rareprob.nets_prover import CertNet, ProverConfig, knuth_estimate, prove, verify  # noqa: E402

EPS, DELTA = 0.1, 0.05
DS = [12, 16, 20, 24, 28, 32, 40, 48, 64]
FAMILIES = [("mse", 1500), ("bce", 100), ("mse", 600), ("bce", 60)]


def main():
    out_path = os.path.join(HERE, "results", "scaling.json")
    out = json.load(open(out_path)) if os.path.exists(out_path) else {}
    for loss, steps in FAMILIES:
        for d in DS:
            for seed in range(3):
                key = f"{loss}_d{d}_s{steps}_seed{seed}"
                if key in out or (steps in (600, 60) and d > 32):
                    continue
                rng = np.random.default_rng(1000 * d + seed + (0 if loss == "mse" else 7))
                net, _ = train_constant(d, [32], steps, rng, loss=loss)
                cn = CertNet(net)
                rec = {"loss": loss, "d": d, "steps": steps, "seed": seed}
                Xs = rng.choice([-1.0, 1.0], size=(200000, d))
                fv = cn.forward(Xs)
                rec["mean"], rec["std"] = float(fv.mean()), float(fv.std())
                rec["z"] = (rec["mean"] - cn.t) / rec["std"]
                t0 = time.time()
                if d <= 26:
                    F = cn.enum_count(np.zeros(d))
                    rec["F"], rec["p"] = F, F / 2 ** d
                else:
                    mc = sum(int((cn.forward(rng.choice([-1.0, 1.0], size=(100000, d))) < cn.t).sum())
                             for _ in range(10))
                    rec["p_mc_1e6"] = mc / 1e6
                rec["enum_full_fpe"] = cn.flops_enum(d) / cn.fpe_flops
                p = rec.get("p")
                rec["mc_fpe"] = 3 * math.log(2 / DELTA) / (EPS ** 2 * p) if p else None
                k = knuth_estimate(cn, ProverConfig(kinds=("lin",), r_leaf=5), probes=128, seed=seed)
                rec["knuth"] = k
                if d <= 24:
                    arg, info = prove(cn, ProverConfig(kinds=("lin",), r_leaf=5, node_budget=1_500_000))
                    res = verify(cn, arg, rng=rng)
                    rec["cert"] = {"F": res.F, "exact": res.exact, "fpe": res.fpe, "nodes": info.nodes,
                                   "leaves": res.leaves, "bytes": res.arg_bytes, "budget_hit": info.budget_hit,
                                   "prover_seconds": info.seconds}
                    if "F" in rec:
                        rec["cert"]["match"] = res.F == rec["F"]
                rec["seconds"] = time.time() - t0
                out[key] = rec
                json.dump(out, open(out_path, "w"), indent=1, default=float)
                cert = rec.get("cert", {})
                print(f"{key:24s} z={rec['z']:.2f} p={p if p is not None else rec.get('p_mc_1e6')} "
                      f"knuth nodes {k['nodes']:.3g} fpe {k['fpe']:.3g} | cert fpe {cert.get('fpe', float('nan')):.3g} "
                      f"| enum {rec['enum_full_fpe']:.3g} MC {rec['mc_fpe'] if rec['mc_fpe'] else float('nan'):.3g} "
                      f"({rec['seconds']:.0f}s)", flush=True)


if __name__ == "__main__":
    main()
