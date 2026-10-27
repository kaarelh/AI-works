"""Self-certifying proposals (prop:proposal) fitted to SMC samples, versus SMC.

For each net: 8 fixed-plan SMC runs (N = 1000) give samples of D restricted
to the failure set; on them we fit (i) an autoregressive logistic proposal
and (ii) a mixture of product kernels around the distinct samples (eta =
0.02; at most 500 centres). Each proposal then gets n = 3e6 samples in 32 batches, and the batch
means go to the betting bound. Fitting uses runs independent of the final
batch, so the bound is sound for every net.

usage: python3 run_proposals.py [--scaling]   (appends to results/proposals.jsonl)
"""

import json
import os
import sys
import time

os.environ.setdefault("OMP_NUM_THREADS", "1")
import numpy as np  # noqa: E402

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "..", "..", "code"))
from rareprob.nets import load_net  # noqa: E402
from rareprob.nets_lower import (ARLogistic, Evaluator, KernelMixture, pack, pilot_plan,  # noqa: E402
                                 proposal_lower, run_smc, unpack)

OUT = os.path.join(HERE, "results")
NETS = os.path.join(HERE, "..", "nets")
NAMES = ["mse_d24_w32_s1000", "mse_d24_w32_s1500", "mse_d28_w64_s600", "mse_d28_w64_s1000",
         "mse_d28_w32x32_s500", "bce_d28_w32_s60"]
N_PROP = 3_000_000


def targets():
    """(name, net file, p, kind): suite nets with exact p, or (with --scaling)
    the scaling nets with their reference estimate p_ref."""
    if sys.argv[1:] == ["--scaling"]:
        for line in open(os.path.join(OUT, "scaling.jsonl")):
            r = json.loads(line)
            if r["kind"] == "ref" and r["p_ref"] > 0 and not r["name"].startswith("suite_"):
                yield r["name"], os.path.join(OUT, "scaling_nets", r["name"] + ".npz"), r["p_ref"], "ref"
        return
    suite = {r["name"]: r for r in json.load(open(os.path.join(NETS, "suite.json")))}
    for name in NAMES:
        if name in suite:
            yield name, os.path.join(NETS, name + ".npz"), suite[name]["p_exact"], "exact"


def main():
    rng = np.random.default_rng(5 if not sys.argv[1:] else 6)
    path = os.path.join(OUT, "proposals.jsonl")
    for name, f, p, pkind in targets():
        net = load_net(f)
        ev = Evaluator(net)
        t = time.time()
        pil = pilot_plan(ev, 1000, 0.2, 10, rng)
        S = np.concatenate([run_smc(ev, pil.plan, rng, keep_final=True).final_X for _ in range(8)])
        fit_evals = ev.evals
        codes = sorted(set(pack(S)))
        C = unpack(codes, net.d)
        if len(C) > 500:  # at most 500 kernel centres (cost of the pmf)
            C = C[rng.choice(len(C), 500, replace=False)]
        for kind in ("ar", "kernel"):
            ev.evals = 0
            Q = ARLogistic(net.d).fit(S, l2=1.0) if kind == "ar" else KernelMixture(C, 0.02)
            L, means, mean = proposal_lower(ev, Q, N_PROP, 32, rng)
            row = dict(name=name, d=net.d, p_exact=p, p_kind=pkind, proposal=kind, samples_fit=len(S), distinct_fit=len(codes),
                       fit_evals=fit_evals, n=N_PROP, L=L, ratio=L / p, mean_over_p=mean / p,
                       batch_relvar=float(means.var() / max(means.mean(), 1e-300) ** 2),
                       per_sample_relvar=float(means.var() / max(means.mean(), 1e-300) ** 2 * (N_PROP // 32)),
                       seconds=round(time.time() - t, 1))
            print(json.dumps(row), flush=True)
            with open(path, "a") as f:
                f.write(json.dumps(row) + "\n")


if __name__ == "__main__":
    main()
