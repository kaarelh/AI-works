"""Shared helpers for the experiments of experiments/nets_lower: paths, the
three sets of nets, Monte Carlo timing, the Monte Carlo yardsticks, and a
small parallel job runner (rows are appended to JSON-lines files, so an
interrupted run resumes where it stopped).

The sets of nets:
  * the exact suite: experiments/nets with p_exact (d <= 28);
  * the large suite: experiments/nets without p_exact (d = 64 and 128);
  * this lane's own nets, results/scaling_nets/smc_*.npz and smc2_*.npz
    (index.json: metadata and provenance; d = 32 ... 128).

Costs are reported in forward-pass equivalents (fpe: one evaluation of the
net on one input; every SMC evaluation is one fpe, and so is every Monte
Carlo sample) and in wall-clock seconds. The machine is a shared 4-core
machine; other jobs ran at the same time, so the seconds are noisy. The
Monte Carlo seconds are the measured time of plain batched Monte Carlo
(2^15 inputs per batch, including drawing the inputs) on the same net,
measured inside the same job, times the number of samples it would need."""

import json
import math
import os
import sys
import time
import zlib

os.environ.setdefault("OMP_NUM_THREADS", "1")
import numpy as np  # noqa: E402

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "..", "..", "code"))
from rareprob.nets import load_net  # noqa: E402
from rareprob.nets_lower import mc_lower_samples, mc_two_sided_samples, random_cube  # noqa: E402

NETS = os.path.join(HERE, "..", "nets")
RES = os.path.join(HERE, "results")
LANE = os.path.join(RES, "scaling_nets")
LOGS = os.path.join(RES, "logs")
DELTA = 0.05
MOVES, RHO = 10, 0.2
BUDGETS = {"S": (300, 32), "M": (1000, 32), "L": (3000, 64)}  # (particles N, replicates R)
MACHINE = "a shared 4-core machine (other jobs ran concurrently; seconds are wall-clock and noisy)"


def suite_rows():
    return json.load(open(os.path.join(NETS, "suite.json")))


def exact_suite():
    return [r for r in suite_rows() if "p_exact" in r]


def large_suite():
    return [r for r in suite_rows() if "p_exact" not in r]


def lane_nets():
    return json.load(open(os.path.join(LANE, "index.json")))


def net_path(name: str) -> str:
    lane = os.path.join(LANE, name + ".npz")
    return lane if os.path.exists(lane) else os.path.join(NETS, name + ".npz")


def get_net(name: str):
    return load_net(net_path(name))


def seed_of(*parts) -> int:
    return zlib.crc32("/".join(map(str, parts)).encode())


def mc_seconds_per_sample(net, n: int = 1 << 15, reps: int = 5) -> float:
    """Wall-clock seconds per sample of plain batched Monte Carlo (median of reps)."""
    rng = np.random.default_rng(0)
    net.forward(random_cube(rng, 256, net.d))  # warm-up
    ts = []
    for _ in range(reps):
        t = time.perf_counter()
        int((net.forward(random_cube(rng, n, net.d)) < net.threshold).sum())
        ts.append(time.perf_counter() - t)
    return float(np.median(ts)) / n


def yardsticks(p: float, ratio: float, evals: float, seconds: float, mc_sec: float) -> dict:
    """Monte Carlo cost of the same ratio L/p, in samples (= fpe) and seconds:
    'kl' = the one-sided (1 - delta) KL lower end at empirical mean exactly p
    (which favours Monte Carlo) reaching ratio * p; 'task' = the task's
    3 ln(2/delta) / (eps^2 p) with eps = 1 - ratio. Speedups = Monte Carlo
    cost / SMC cost (pilot included)."""
    if not (p > 0 and ratio > 0):
        return dict(mc_kl_samples=0.0, mc_task_samples=0.0, speedup_kl_fpe=0.0, speedup_kl_sec=0.0,
                    speedup_task_fpe=0.0, speedup_task_sec=0.0)
    r = min(ratio, 0.999)
    kl = mc_lower_samples(p, r, DELTA)
    task = mc_two_sided_samples(p, 1 - r, DELTA)
    return dict(mc_kl_samples=kl, mc_task_samples=task, speedup_kl_fpe=kl / evals,
                speedup_kl_sec=kl * mc_sec / seconds, speedup_task_fpe=task / evals,
                speedup_task_sec=task * mc_sec / seconds)


def load_rows(path):
    return [json.loads(line) for line in open(path)] if os.path.exists(path) else []


def append_row(path, row):
    with open(path, "a") as f:
        f.write(json.dumps(row) + "\n")


def run_parallel(fn, jobs, path, n_jobs: int, show=None):
    """Run fn(job) for every job (in n_jobs processes), appending each
    returned row (or list of rows) to path as it arrives."""
    if not jobs:
        return
    if n_jobs <= 1:
        results = map(fn, jobs)
        pool = None
    else:
        from multiprocessing import Pool
        pool = Pool(n_jobs)
        results = pool.imap_unordered(fn, jobs)
    try:
        for out in results:
            for row in (out if isinstance(out, list) else [out]):
                append_row(path, row)
                print(show(row) if show else json.dumps(row)[:300], flush=True)
    finally:
        if pool is not None:
            pool.close()
            pool.join()


def jobs_arg(argv, default=3):
    """--jobs J from the argument list (removed from it)."""
    if "--jobs" in argv:
        i = argv.index("--jobs")
        n = int(argv[i + 1])
        del argv[i:i + 2]
        return n
    return default


def fmt(x, nd=3):
    if x is None or (isinstance(x, float) and (math.isnan(x) or math.isinf(x))):
        return "-"
    return f"{x:.{nd}g}"
