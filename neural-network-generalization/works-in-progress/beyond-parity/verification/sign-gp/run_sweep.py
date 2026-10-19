"""Main sweep for the sign-conditioned GP (gamma<0 learner) and the kernel-regression comparison.

For each (d, L, seed, n): draw n i.i.d. uniform training inputs (shared by all targets, common
random numbers), build K_XX on the distinct inputs, and for every target
  * run 2 exact-HMC chains on G_X | signs, compute q(x) on the whole cube for each chain and pooled,
  * record F = P_x{q<=2/3}, Gibbs error E_x[1-q], vote error P_x{q<=1/2}, chain diagnostics,
  * record kernel ('ridgeless' NNGP) regression on the +-1 labels: sign error, Phi(f m/s) confidence
    failure and Gibbs error, and L2 error.
Results are appended to results.jsonl (one line per (d,L,seed,n,target)); the run is resumable.

usage: python3 run_sweep.py [--workers 4] [--L 2 3] [--d 10 12] [--seeds 0 1 2] [--ngrid ...]
"""
import argparse, json, os, sys, time
os.environ.setdefault("OMP_NUM_THREADS", "1")
os.environ.setdefault("OPENBLAS_NUM_THREADS", "1")
os.environ.setdefault("MKL_NUM_THREADS", "1")
import numpy as np
from multiprocessing import Pool

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from common import cube, gram
from signgp import sample_signs, Predictor, summarize_q
import targets as T

OUT = os.path.join(HERE, "results.jsonl")


def train_inputs(d, n, seed):
    rng = np.random.default_rng([d, n, seed, 20261019])
    X = rng.integers(0, 2 ** d, size=n)
    return np.unique(X)


def job(args):
    d, L, seed, n, tnames, n_keep, burn = args
    t0 = time.time()
    Xc = cube(d)
    idx = train_inputs(d, n, seed)
    KXX = gram(Xc[idx], Xc[idx], d, L)
    Kcx = gram(Xc, Xc[idx], d, L)
    P = Predictor(Kcx, KXX, idx)
    eig_min = float(np.linalg.eigvalsh(KXX).min())
    rows = []
    for t in tnames:
        f = T.target_values(t, d)
        y = f[idx]
        rng = np.random.default_rng([d, L, seed, n, TARGET_ID[t], 777])
        ts = time.time()
        G, nb = sample_signs(KXX, y, n_keep=n_keep, burn=burn, n_chains=2, rng=rng)
        qa, ma = P.q_from_samples(G[0], f)
        qb, mb = P.q_from_samples(G[1], f)
        q = 0.5 * (qa + qb)
        mpost = 0.5 * (ma + mb)
        sA, sB, s = summarize_q(qa, f, P.unseen), summarize_q(qb, f, P.unseen), summarize_q(q, f, P.unseen)
        m, qreg = P.regression(y, f)
        u = P.unseen
        # effective-sample-size proxy: lag-k autocorrelation of mean z along chain A
        zm = (G[0] * y[None, :]).mean(1)
        zc = zm - zm.mean()
        ac = lambda lag: float((zc[:-lag] * zc[lag:]).mean() / max((zc * zc).mean(), 1e-300))
        row = dict(d=d, L=L, seed=seed, n=n, n_distinct=int(len(idx)), target=t,
                   F=s["F"], gibbs=s["gibbs"], vote_err=s["vote_err"], F_unseen=s["F_unseen"],
                   gibbs_unseen=s["gibbs_unseen"],
                   F_chainA=sA["F"], F_chainB=sB["F"], gibbs_chainA=sA["gibbs"], gibbs_chainB=sB["gibbs"],
                   max_abs_dq_chains=float(np.max(np.abs(qa - qb))),
                   mean_abs_dq_chains=float(np.mean(np.abs(qa - qb))),
                   frac_q_near_2_3=float(np.mean(np.abs(q - 2 / 3) < 0.02)),
                   postmean_sign_err=float(np.mean(np.sign(mpost) != f)),
                   ac1=ac(1), ac10=ac(10), bounces_per_iter=float(nb.mean()),
                   reg_sign_err=float(np.mean(np.sign(m) != f)),
                   reg_sign_err_unseen=float(np.mean(np.sign(m[u]) != f[u])),
                   reg_F=float(np.mean(qreg <= 2 / 3)), reg_gibbs=float(np.mean(1 - qreg)),
                   reg_l2_err=float(np.mean((m - f) ** 2)),
                   KXX_eig_min=eig_min, min_var_unseen=P.var_min_unseen,
                   n_keep=n_keep, burn=burn, seconds=time.time() - ts)
        rows.append(row)
    return rows, time.time() - t0


TARGET_ID = {t: i for i, t in enumerate(T.TARGETS)}


def done_keys():
    keys = set()
    if os.path.exists(OUT):
        for line in open(OUT):
            r = json.loads(line)
            keys.add((r["d"], r["L"], r["seed"], r["n"], r["target"]))
    return keys


if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("--workers", type=int, default=4)
    ap.add_argument("--L", type=int, nargs="+", default=[2])
    ap.add_argument("--d", type=int, nargs="+", default=[10, 12])
    ap.add_argument("--seeds", type=int, nargs="+", default=[0, 1, 2])
    ap.add_argument("--ngrid", type=int, nargs="+", default=[25, 50, 100, 200, 300, 400, 600])
    ap.add_argument("--targets", nargs="+", default=T.TARGETS)
    ap.add_argument("--n_keep", type=int, default=1000)
    ap.add_argument("--burn", type=int, default=200)
    a = ap.parse_args()
    have = done_keys()
    jobs = []
    for d in a.d:
        for L in a.L:
            for seed in a.seeds:
                for n in a.ngrid:
                    tn = [t for t in a.targets if (d, L, seed, n, t) not in have]
                    if tn:
                        jobs.append((d, L, seed, n, tn, a.n_keep, a.burn))
    jobs.sort(key=lambda j: -j[3] * (2 ** j[0]) ** 0.3)  # largest first
    print(f"{len(jobs)} jobs", flush=True)
    t0 = time.time()
    with Pool(a.workers) as pool:
        for rows, sec in pool.imap_unordered(job, jobs):
            with open(OUT, "a") as fh:
                for r in rows:
                    fh.write(json.dumps(r) + "\n")
            r0 = rows[0]
            print(f"[{time.time() - t0:7.1f}s] d={r0['d']} L={r0['L']} seed={r0['seed']} n={r0['n']} "
                  f"({len(rows)} targets, {sec:.1f}s) " +
                  " ".join(f"{r['target']}:F={r['F']:.2f}" for r in rows), flush=True)
    print("ALL DONE", time.time() - t0, flush=True)
