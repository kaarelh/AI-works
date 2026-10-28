"""The regime where analytic DP is exact: nets with at most 3 hidden units
(rareprob.nets_analytic.small_width_interval: deterministic interval from the
exact joint law of all quantised pre-activations, however rare the event).

Own nets trained here (train_constant, one hidden layer of width 1, 2, 3;
squared loss 300 / 1500 steps and logistic loss 100 steps; d = 24 with the
exact p by enumeration, and d = 64). Output: results/narrow.json"""

import json
import os
import sys
import time

import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "..", "..", "code"))
from rareprob.nets import train_constant, exact_failure_prob  # noqa: E402
from rareprob import nets_analytic as na  # noqa: E402

out = []
for d in (24, 64):
    for w in (1, 2, 3):
        for loss, steps in (("mse", 300), ("mse", 1500), ("bce", 100)):
            net, _ = train_constant(d, [w], steps, np.random.default_rng(w * 100 + steps), loss=loss)
            t0 = time.time()
            lo, hi = na.small_width_interval(net)
            r = {"d": d, "width": w, "loss": loss, "steps": steps, "lo": lo, "hi": hi, "seconds": time.time() - t0,
                 "p_exact": exact_failure_prob(net) if d <= 24 else None}
            if r["p_exact"] is not None:
                r["covers"] = bool(lo <= r["p_exact"] <= hi)
            out.append(r)
            print(json.dumps(r), flush=True)
            with open(os.path.join(HERE, "results", "narrow.json"), "w") as f:
                json.dump(out, f, indent=1)
