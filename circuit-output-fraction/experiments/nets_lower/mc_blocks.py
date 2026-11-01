"""Near-i.i.d. Monte Carlo for d = 64 nets, an independent check of the SMC
reference estimates (written for the red-team review of the design round).

Batches of P i.i.d. uniform (d - 10)-bit prefixes, each with all 2^10
suffixes (first layer by a table of the suffix contributions). Outputs are
screened in float32, and every input whose float32 output is within 1e-3 of
the threshold is re-evaluated in float64 by net.forward (a practical, not a
certified, screen: the float32 error of these nets is far below 1e-3). The
estimate is unbiased, with a standard error from the per-prefix counts
(prefixes are i.i.d.; failures cluster, so the Poisson s.e. is too small).

usage: python3 mc_blocks.py <name> <samples> <seed> [--jobs J]   (appends to results/mc_blocks.jsonl)
"""

import math
import os
import sys
import time

from common import RES, append_row, get_net, jobs_arg
import numpy as np  # noqa: E402  (after common, which sets OMP_NUM_THREADS=1)

KS, P = 10, 32


def run(args):
    name, nsamp, seed = args
    net = get_net(name)
    d, thr = net.d, net.threshold
    W, b = net.Ws[0], net.bs[0]
    kp, m = d - KS, W.shape[0]
    idx = np.arange(1 << KS, dtype=np.int64)
    Vs = np.where((idx[:, None] >> np.arange(KS)) & 1, 1.0, -1.0)
    B = (Vs @ W[:, kp:].T).astype(np.float32)
    Ws32 = [(Wl.T.astype(np.float32), bl.astype(np.float32)) for Wl, bl in zip(net.Ws[1:-1], net.bs[1:-1])]
    a32, c = net.Ws[-1][0].astype(np.float32), float(net.bs[-1][0])
    rng = np.random.default_rng(seed)
    nb = int(nsamp / (P << KS))
    counts = np.zeros(nb * P, np.int64)
    rechecked = 0
    for t in range(nb):
        U = np.where(rng.random((P, kp)) < 0.5, -1.0, 1.0)
        h = ((U @ W[:, :kp].T + b).astype(np.float32)[:, None, :] + B[None, :, :]).reshape(-1, m)
        np.maximum(h, 0, out=h)
        for Wt, bl in Ws32:
            h = h @ Wt
            h += bl
            np.maximum(h, 0, out=h)
        f = (h @ a32 + c).reshape(P, -1)
        fail = f < thr - 1e-3
        near = np.argwhere(np.abs(f - thr) <= 1e-3)
        if len(near):
            rechecked += len(near)
            X = np.empty((len(near), d))
            X[:, :kp] = U[near[:, 0]]
            X[:, kp:] = Vs[near[:, 1]]
            fail[near[:, 0], near[:, 1]] = net.forward(X) < thr
        counts[t * P:(t + 1) * P] = fail.sum(axis=1)
    return counts, rechecked


def main():
    args = sys.argv[1:]
    n_jobs = jobs_arg(args, default=4)
    name, nsamp, seed0 = args[0], float(args[1]), int(args[2])
    t = time.time()
    jobs = [(name, nsamp / n_jobs, seed0 + i) for i in range(n_jobs)]
    if n_jobs > 1:
        from multiprocessing import Pool
        with Pool(n_jobs) as pool:
            res = pool.map(run, jobs)
    else:
        res = [run(j) for j in jobs]
    cc = np.concatenate([r[0] for r in res]).astype(float)
    out = dict(name=name, prefixes=len(cc), samples=len(cc) * 2 ** KS, hits=int(cc.sum()),
               prefixes_with_hits=int((cc > 0).sum()), max_per_prefix=int(cc.max()), p_hat=cc.mean() / 2 ** KS,
               se=cc.std(ddof=1) / math.sqrt(len(cc)) / 2 ** KS, poisson_se=math.sqrt(cc.sum()) / len(cc) / 2 ** KS,
               rechecked=int(sum(r[1] for r in res)), seconds=round(time.time() - t, 1), seed=seed0)
    print(out)
    append_row(os.path.join(RES, "mc_blocks.jsonl"), out)


if __name__ == "__main__":
    main()
