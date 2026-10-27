"""Build the test suite of MLPs trained to output 1 (experiments/nets/).

Each net is trained on fresh uniform +-1 inputs with target 1 (squared loss:
rare event f(x) < 1/2; logistic loss: rare event logit < 0) and saved at
several training steps. For d <= 30 the exact failure probability is computed
by enumerating {-1,+1}^d. Writes nets/<name>.npz and nets/suite.json.
"""

import json
import os
import sys
import time

import numpy as np

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "code"))
from rareprob.nets import exact_failure_count, train_constant  # noqa: E402

OUT = os.path.join(os.path.dirname(__file__), "nets")
os.makedirs(OUT, exist_ok=True)

CONFIGS = [
    # (name, d, widths, loss, lr, snapshot steps, exact?)
    ("mse_d24_w32", 24, [32], "mse", 1e-3, (300, 600, 1000, 1500, 2000), True),
    ("mse_d28_w64", 28, [64], "mse", 1e-3, (300, 600, 1000, 1500), True),
    ("mse_d28_w32x32", 28, [32, 32], "mse", 1e-3, (100, 200, 300, 500), True),
    ("bce_d28_w32", 28, [32], "bce", 1e-3, (30, 60, 100, 150), True),
    ("bce_d28_w64x64", 28, [64, 64], "bce", 3e-4, (20, 40, 60, 100), True),
    ("mse_d64_w64", 64, [64], "mse", 1e-3, (300, 1000, 3000), False),
    ("bce_d64_w64", 64, [64], "bce", 1e-3, (100, 300, 1000), False),
    ("bce_d128_w128x128", 128, [128, 128], "bce", 3e-4, (100, 300, 1000), False),
]


def main():
    rng = np.random.default_rng(2027)
    suite = []
    for name, d, widths, loss, lr, steps, exact in CONFIGS:
        net, snaps = train_constant(d, widths, max(steps), rng, loss=loss, lr=lr, snapshots=steps)
        for s in steps:
            nt = snaps[s]
            X = rng.choice([-1.0, 1.0], size=(100000, d))
            f = nt.forward(X)
            row = dict(name=f"{name}_s{s}", d=d, widths=widths, loss=loss, step=s, threshold=nt.threshold,
                       mean=float(f.mean()), std=float(f.std()), z=float((f.mean() - nt.threshold) / f.std()))
            if exact:
                t = time.time()
                cnt = exact_failure_count(nt)
                row.update(fail_count=cnt, p_exact=cnt / float(1 << d), enum_seconds=round(time.time() - t, 1))
            np.savez(os.path.join(OUT, row["name"] + ".npz"), **{f"W{i}": W for i, W in enumerate(nt.Ws)},
                     **{f"b{i}": b for i, b in enumerate(nt.bs)}, threshold=nt.threshold, loss=loss)
            suite.append(row)
            print(json.dumps(row), flush=True)
            json.dump(suite, open(os.path.join(OUT, "suite.json"), "w"), indent=1)


if __name__ == "__main__":
    main()
