"""Training of this lane's own nets at d = 32 ... 128 (results/scaling_nets/).

Nets are trained to output 1 with nets.train_constant (Adam, batch 256,
fresh uniform inputs) and snapshots at STEPS are kept when their failure
z-score (mean - t*)/sd of the output, from 2e5 samples, lies in a window:
  family A (prefix smc_):  z in [3.5, 6.5];
  family B (prefix smc2_): z in [6.5, 9.0], a second training run aimed at
                           the far tail.
Names are smc_<loss>_d<d>_w<widths>_s<step> (smc2_ for family B), distinct
from the suite's names in experiments/nets.

The stored nets were trained by an earlier version of run_scaling.py that
used ONE generator for all dimensions of a family and for the evaluation
runs in between, so only the two architectures trained alone, at d = 64,
are reproduced bit for bit by this script (bce 64x64, lr 3e-4, seed 4357;
mse 32x32, lr 1e-3, seed 4356); index.json records the provenance of each
net. This script never overwrites a stored net.

usage: python3 train_scaling_nets.py A|B loss:w1xw2:lr d [d ...]   e.g.  A mse:64:1e-3 32 64 128
"""

import os
import sys

from common import LANE
import numpy as np  # noqa: E402  (after common, which sets OMP_NUM_THREADS=1)
from rareprob.nets import train_constant  # noqa: E402
from rareprob.nets_lower import random_cube  # noqa: E402

STEPS = (300, 600, 1000, 1500, 2000, 3000, 4000)
WINDOWS = {"A": (3.5, 6.5), "B": (6.5, 9.0)}
PREFIX = {"A": "smc_", "B": "smc2_"}


def zscore(net, rng, n=200000):
    f = net.forward(random_cube(rng, n, net.d))
    return float((f.mean() - net.threshold) / f.std())


def save(net, path):
    np.savez(path, **{f"W{i}": W for i, W in enumerate(net.Ws)}, **{f"b{i}": b for i, b in enumerate(net.bs)},
             threshold=net.threshold, loss=net.loss)


def main():
    fam, arch, dims = sys.argv[1], sys.argv[2], [int(a) for a in sys.argv[3:]]
    loss, ws, lr = arch.split(":")
    widths = [int(w) for w in ws.split("x")]
    zmin, zmax = WINDOWS[fam]
    for d in dims:
        seed = (4242 if fam == "A" else 4243) + (0 if (loss, widths) == ("mse", [64]) else
                                                 100 + 7 * len(widths) + (loss == "bce"))
        rng = np.random.default_rng(seed)
        _, snaps = train_constant(d, widths, max(STEPS), rng, loss=loss, lr=float(lr), snapshots=STEPS)
        for st in STEPS:
            name = f"{PREFIX[fam]}{loss}_d{d}_w{'x'.join(map(str, widths))}_s{st}"
            z = zscore(snaps[st], rng)
            path = os.path.join(LANE, name + ".npz")
            keep = zmin <= z <= zmax and not os.path.exists(path)
            print(f"{name}: z = {z:.2f} {'saved' if keep else 'skipped'}", flush=True)
            if keep:
                save(snaps[st], path)


if __name__ == "__main__":
    main()
