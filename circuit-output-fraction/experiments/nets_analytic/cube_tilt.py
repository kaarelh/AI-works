"""Cube-certified tilt envelopes (rareprob.nets_analytic.cube_tilt_envelope):
an exponential tilt exp(theta (t' - g0 - gam.x)) whose affine minorant
g0 + gam.x <= F is certified on the CUBE by an exact minimisation (here the
enumeration table: one MAP call for the final g0, a few hundred for choosing
(theta, gam); the d = 24 run used 3 optimiser starts, later runs 1), then used as the envelope of the paper's envelope estimator
for a two-sided interval (eps = 0.1, delta = 0.05).

Possible only on nets with symmetric_gap > 0 (the cube barrier); the script
skips the others (reported as barred). Cost accounting: samples of the
envelope estimator (one forward pass each) against Monte Carlo's
3 ln(2/delta) / (eps^2 p), plus the MAP calls, each of which is an exact
optimisation over the cube (verification-hard; see map_cost.py).

Usage: python3 cube_tilt.py names...   Output: results/cube_tilt.json"""

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


def run(name, p, max_samples=5_000_000):
    net = load_net(os.path.join(NETS, name + ".npz"))
    t0 = time.time()
    orc = na.EnumMAPOracle(net, np.float64 if net.d <= 24 else np.float32)
    rec = {"name": name, "p": p, "d": net.d, "sym_gap": na.symmetric_gap(orc.F, net.threshold),
           "seconds_table": time.time() - t0}
    if rec["sym_gap"] <= 0:
        rec["barred"] = True
        return rec
    t1 = time.time()
    env = na.cube_tilt_envelope(net, orc, starts=1)
    rec.update({"barred": False, "Z": math.exp(env.logZ), "K": math.exp(env.logZ) / p if p else None,
                "note": env.note, "seconds_envelope": time.time() - t1})
    if p and env.logZ < 0:
        t2 = time.time()
        est = na.envelope_interval(env, eps=EPS, delta=DELTA, max_samples=max_samples, rng=np.random.default_rng(1))
        rec.update({"lo": est.lo, "hi": est.hi, "value": est.value, "samples": est.samples,
                    "covers": bool(est.lo <= p <= est.hi), "N_MC": 3 * math.log(2 / DELTA) / (EPS ** 2 * p),
                    "seconds_sampling": time.time() - t2})
        rec["speedup_samples"] = rec["N_MC"] / est.samples
        rec["reached_eps"] = bool(est.hi <= (1 + EPS) * est.lo)
    # at equal accuracy the envelope estimator needs about Z times Monte Carlo's samples
    rec["speedup_at_equal_accuracy"] = 1.0 / rec["Z"]
    return rec


if __name__ == "__main__":
    suite = json.load(open(os.path.join(NETS, "suite.json")))
    out_path = os.path.join(HERE, "results", "cube_tilt.json")
    res = json.load(open(out_path)) if os.path.exists(out_path) else {}
    for nm in sys.argv[1:]:
        e = next(x for x in suite if x["name"] == nm)
        r = run(nm, e.get("p_exact"))
        res[nm] = r
        print(json.dumps(r), flush=True)
        with open(out_path, "w") as f:
            json.dump(res, f, indent=1)
