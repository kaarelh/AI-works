"""Fixed-level SMC lower bounds on the exact-p suite (experiments/nets/).

For every net with p_exact and every budget, `trials` independent runs of
nets_lower.lower_bound (pilot + R fixed-plan replicates); records the
betting bound (the method's output), the alternatives computed on the same
replicates, the witness bound, the cost, and the Monte Carlo samples a
one-sided KL lower bound would need to reach the same ratio.

usage: python3 run_suite.py [name-substring ...]   (writes results/suite.jsonl)
"""

import json
import os
import sys
import time
import zlib

os.environ.setdefault("OMP_NUM_THREADS", "1")
import numpy as np  # noqa: E402

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "..", "..", "code"))
from rareprob.nets import load_net  # noqa: E402
from rareprob.nets_lower import lower_bound, mc_lower_samples  # noqa: E402

NETS = os.path.join(HERE, "..", "nets")
OUT = os.path.join(HERE, "results")
os.makedirs(OUT, exist_ok=True)

DELTA = 0.05
BUDGETS = {  # name: (N, R, moves, rho)
    "S": (300, 32, 10, 0.2),
    "M": (1000, 32, 10, 0.2),
    "L": (3000, 64, 10, 0.2),
}
TRIALS = 5


def done_keys(path):
    keys = set()
    if os.path.exists(path):
        for line in open(path):
            r = json.loads(line)
            keys.add((r["name"], r["budget"], r["trial"]))
    return keys


def main():
    suite = json.load(open(os.path.join(NETS, "suite.json")))
    pats = sys.argv[1:]
    path = os.path.join(OUT, "suite.jsonl")
    done = done_keys(path)
    for row in suite:
        if "p_exact" not in row or (pats and not any(q in row["name"] for q in pats)):
            continue
        p = row["p_exact"]
        net = load_net(os.path.join(NETS, row["name"] + ".npz"))
        for b, (N, R, moves, rho) in BUDGETS.items():
            for trial in range(TRIALS):
                if (row["name"], b, trial) in done:
                    continue
                seed = 1000 * trial + {"S": 1, "M": 2, "L": 3}[b] + zlib.crc32(row["name"].encode()) % 997
                rng = np.random.default_rng(seed)
                t = time.time()
                res = lower_bound(net, delta=DELTA, N=N, R=R, moves=moves, rho=rho, rng=rng)
                evals = res.evals_pilot + res.evals_final
                out = dict(name=row["name"], d=row["d"], widths=row["widths"], loss=row["loss"], step=row["step"],
                           p_exact=p, fail_count=row["fail_count"], budget=b, N=N, R=R, moves=moves, rho=rho,
                           trial=trial, seed=seed, K=len(res.plan.levels), flips=res.plan.flips,
                           evals_pilot=res.evals_pilot, evals_final=res.evals_final, evals=evals,
                           pilot_log10Z=res.pilot_log10Z, flagged=res.flagged,
                           L_bet=res.smc_lower, L_clip=res.clipped_lower, L_min=res.minmarkov_lower,
                           L_wit=res.witness_lower, L=res.lower,
                           Z=res.Z, seconds=round(time.time() - t, 2))
                if p > 0:
                    out.update(r_bet=res.smc_lower / p, r_clip=res.clipped_lower / p, r_min=res.minmarkov_lower / p,
                               r_wit=res.witness_lower / p, r=res.lower / p,
                               mc_samples_same_ratio=mc_lower_samples(p, min(res.smc_lower / p, 0.999), DELTA)
                               if res.smc_lower > 0 else 0.0)
                else:  # p = 0: every sound bound must be exactly 0
                    out.update(r_bet=float("nan"), r_clip=float("nan"), r_min=float("nan"), r_wit=float("nan"),
                               r=float("nan"), mc_samples_same_ratio=0.0)
                out["miss"] = bool(max(res.lower, res.clipped_lower, res.minmarkov_lower) > p)
                out["speedup_vs_mc"] = out["mc_samples_same_ratio"] / evals if evals else 0.0
                with open(path, "a") as f:
                    f.write(json.dumps(out) + "\n")
                print(f"{row['name']:22s} {b} t{trial} p={p:.3g} r_bet={out['r_bet']:.3f} r_clip={out['r_clip']:.3f} "
                      f"r_min={out['r_min']:.3f} r_wit={out['r_wit']:.3f} evals={evals:.3g} "
                      f"MC={out['mc_samples_same_ratio']:.3g} x{out['speedup_vs_mc']:.1f} {out['seconds']}s",
                      flush=True)


if __name__ == "__main__":
    main()
