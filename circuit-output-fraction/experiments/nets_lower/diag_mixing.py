"""Mixing diagnostics: per-level Metropolis acceptance and flip sizes chosen by
the pilot, and the number of distinct points among the final particles, for
nets of increasing d (writes results/mixing.txt)."""

import os

from common import RES, get_net
import numpy as np  # noqa: E402  (after common, which sets OMP_NUM_THREADS=1)
from rareprob.nets_lower import Evaluator, pack, pilot_plan, run_smc  # noqa: E402

NETS = ["mse_d24_w32_s2000", "bce_d28_w32_s100", "mse_d28_w64_s1000", "smc_mse_d32_w64_s600", "smc_mse_d64_w64_s1500",
        "smc_mse_d128_w64_s600", "bce_d64_w64_s100", "bce_d128_w128x128_s100"]


def main():
    rng = np.random.default_rng(8)
    lines = []
    for name in NETS:
        net = get_net(name)
        ev = Evaluator(net)
        pil = pilot_plan(ev, 1000, 0.2, 10, rng)
        fin = [run_smc(ev, pil.plan, rng, keep_final=True).final_X for _ in range(4)]
        distinct = [len(set(pack(X))) if X is not None and len(X) else 0 for X in fin]
        line = (f"{name:24s} d={net.d:3d} K={len(pil.plan.levels):2d} flips={pil.plan.flips} "
                f"acceptance={np.round(pil.accept, 2).tolist()} distinct final particles (of the survivors "
                f"among 1000) per run={distinct}")
        print(line, flush=True)
        lines.append(line)
    open(os.path.join(RES, "mixing.txt"), "w").write("\n".join(lines) + "\n")


if __name__ == "__main__":
    main()
