"""Referee 5: SI-ABC without a verifier (Proposition 5(b)), which E6 does not run.

Online comparison of SI and SI-ABC on E6's humans (same seeds and problem draws as the SI cells,
sigma = n/2), over a fixed number R of rounds with no stopping rule. Each round picks a uniformly
random problem among the 100, builds its run, records whether the run fails, and task-queries one
uniformly random step of the run. Under SI-ABC the run is built by run_abc of
code/slack_imitation.py: asks are added to the data at once and counted as task queries; a
uniform query that falls on an asked step teaches nothing but is still counted. With
alpha = None the loop is plain SI, and its first rounds coincide with E6's one_human.

(An oracle stopping rule like E6's is not meaningful for SI-ABC: the run whose failure it measures
asks the human, so an imitator with no training already "succeeds" if those asks are free.)

Reported per cell: failed runs during the R rounds (the quantity Proposition 5(b) bounds), asks,
total task queries (R + asks), and failed runs in the last R/2 rounds.
Usage: python3 referee5_si_abc_online.py
"""

import os
import sys
import time
from multiprocessing import Pool

sys.dont_write_bytecode = True
HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
sys.path.insert(0, os.path.join(ROOT, "code"))
import slack_imitation as si  # noqa: E402

import numpy as np  # noqa: E402


def build(pr, tp, kp, alpha):
    """Build the current run; returns the number of asks (0 for plain SI)."""
    if alpha is None:
        pr.asked = [False] * pr.n      # pr.run / pr.codes are kept current by recompute()
        return 0
    return si.run_abc(pr, tp, kp, alpha)


def one(args):
    kind, n, seed, alpha, R = args
    sigma = n // 2
    persistent, D = si.KINDS[kind]
    n0 = n - sigma
    rng = np.random.default_rng(seed)
    tp = rng.integers(0, n0, size=si.M)
    kp = np.where(rng.random(si.M) < si.PI, 1, 2)
    probs = [si.Problem(n, n0, persistent, D) for _ in range(si.M)]
    rng2 = np.random.default_rng(seed + 10**8)
    queries = asks = failed = failed_late = hits = 0
    for r in range(R):
        p = int(rng2.integers(si.M))
        pr = probs[p]
        q = build(pr, tp[p], kp[p], alpha)
        asks += q
        queries += q
        f = int(not pr.success(tp[p], kp[p]))
        failed += f
        failed_late += f if r >= R // 2 else 0
        j = int(rng2.integers(n))
        queries += 1
        if alpha is None:
            hits += pr.query(j, tp[p], kp[p])
        elif not pr.asked[j]:
            a, u = pr.run[j]
            hum = pr.human_step(j, tp[p], kp[p])
            hits += int(hum != pr.decoder_step(j))
            idx = np.flatnonzero(pr.alive)
            out = pr.outputs(j, a, u, pr.t[idx], pr.k[idx])
            pr.alive[idx[out != hum]] = False
    return dict(queries=queries, asks=asks, failed=failed, failed_late=failed_late, hits=hits)


def main():
    t0 = time.time()
    plan = [(16, 40, list(si.KINDS), 3000), (64, 20, ["noticing", "misled-8", "fooled"], 3000)]
    out = {}
    with Pool(4) as pool:
        for n, H, kinds, R in plan:
            for kind in kinds:
                for alpha in (None, 0.3, 0.1):
                    rows = pool.map(one, [(kind, n, 1000 * n + s, alpha, R) for s in range(H)])
                    f = np.array([r["failed"] for r in rows], dtype=float)
                    cell = dict(kind=kind, n=n, alpha=alpha, humans=H, rounds=R,
                                failed_mean=float(f.mean()),
                                failed_sem=float(f.std(ddof=1) / np.sqrt(H)),
                                failed_late_mean=float(np.mean([r["failed_late"] for r in rows])),
                                asks_mean=float(np.mean([r["asks"] for r in rows])),
                                queries_mean=float(np.mean([r["queries"] for r in rows])),
                                hits_mean=float(np.mean([r["hits"] for r in rows])))
                    key = f"{kind}_n{n}_alpha{alpha}"
                    out[key] = cell
                    print(f"{key:24s} humans {H:2d}, {R} rounds: failed runs {cell['failed_mean']:7.1f} ± "
                          f"{cell['failed_sem']:5.1f} (last half {cell['failed_late_mean']:6.1f}); asks "
                          f"{cell['asks_mean']:6.1f}; task queries {cell['queries_mean']:7.1f}; hits "
                          f"{cell['hits_mean']:5.1f}  [{time.time() - t0:.0f}s]")
                    sys.stdout.flush()


if __name__ == "__main__":
    main()
