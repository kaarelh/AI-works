"""Sign-only learner (paper, Section 3) for full parity at small d: tanh standard-scaling NNGP kernels
versus the arcsine kernel of the subcritical paper.  Illustration only (paper, Section 7).

Sampler: exact HMC for the orthant-truncated Gaussian on the distinct training inputs
(hmc_orthant.c, copied unchanged from works-in-progress/beyond-parity/verification/sign-gp, where it is
validated against exact orthant ratios and an independent Gibbs sampler).
Prediction: q(x) = E[Phi(f(x) mu(x)/s(x)) | signs] (Rao-Blackwellized), F = P_x{q <= 2/3} over the whole cube.
The kernel is normalized to unit diagonal; sign posteriors do not depend on the output scale A.

usage: python3 signgp_parity.py [--workers 4]   ->  signgp_parity.jsonl, signgp_parity.txt
"""
import argparse, ctypes, json, math, os, subprocess, sys, time
os.environ.setdefault("OMP_NUM_THREADS", "1"); os.environ.setdefault("OPENBLAS_NUM_THREADS", "1")
import numpy as np
from multiprocessing import Pool
from scipy.linalg import cho_factor, cho_solve, cholesky
from scipy.special import ndtr

HERE = os.path.dirname(os.path.abspath(__file__))
SO = os.path.join(HERE, "hmc_orthant.so")


def build():
    if not os.path.exists(SO):
        subprocess.check_call(["gcc", "-O3", "-shared", "-fPIC", "-o", SO, os.path.join(HERE, "hmc_orthant.c"), "-lm"])


def cube(d):
    idx = np.arange(2 ** d)
    return (1 - 2 * ((idx[:, None] >> np.arange(d)[None, :]) & 1)).astype(np.int8)


def tanh_profile(d, L, gain="unit", s1=1.0, s=1.0, deg=160):
    """Normalized output correlation kappa(h) at Hamming distance h (Gauss-Hermite layer recursion)."""
    x, w = np.polynomial.hermite_e.hermegauss(deg); w = w / w.sum()
    D = d + 1
    rho = np.array([(1.0 + d - 2 * h) / D for h in range(d + 1)])
    q = s1 ** 2
    for _ in range(L - 1):
        vals = []
        for r in rho:
            u = math.sqrt(q) * x[:, None]
            vv = math.sqrt(q) * (r * x[:, None] + math.sqrt(max(1 - r * r, 0.0)) * x[None, :])
            vals.append(float((w[:, None] * w[None, :] * np.tanh(u) * np.tanh(vv)).sum()))
        var = float((w * np.tanh(math.sqrt(q) * x) ** 2).sum())
        rho = np.clip(np.array(vals) / var, -1, 1)
        q = s ** 2 * var if gain == "unit" else 1.0
    return rho


def arcsine_profile(d, L):
    t = np.array([(1.0 + d - 2 * h) / (d + 1) for h in range(d + 1)])
    for _ in range(L - 1):
        t = 2 / np.pi * np.arcsin(np.clip(t, -1, 1))
    return t


def hmc(Sigma, z0, iters, rng, T=np.pi / 2):
    lib = ctypes.CDLL(SO); dp = ctypes.POINTER(ctypes.c_double)
    lib.hmc_orthant.restype = ctypes.c_long
    lib.hmc_orthant.argtypes = [ctypes.c_int, dp, dp, ctypes.c_int, dp, ctypes.c_double, dp, ctypes.c_int, ctypes.c_long]
    n = Sigma.shape[0]; C = cholesky(Sigma, lower=True)
    Sig = np.ascontiguousarray(Sigma); z = np.ascontiguousarray(z0, dtype=float).copy()
    out = np.zeros((iters, n)); done = 0
    while done < iters:
        m = min(500, iters - done)
        W = np.ascontiguousarray((C @ rng.standard_normal((n, m))).T)
        tmp = np.zeros((m, n))
        lib.hmc_orthant(n, Sig.ctypes.data_as(dp), z.ctypes.data_as(dp), m, W.ctypes.data_as(dp), T,
                        tmp.ctypes.data_as(dp), 1, 10 ** 8)
        out[done:done + m] = tmp; done += m
    return out


def job(args):
    kname, d, L, seed, n, keep, burn = args
    t0 = time.time()
    X = cube(d); f = X.astype(np.int64).prod(1).astype(float)
    prof = tanh_profile(d, L) if kname == "tanh-unit" else (tanh_profile(d, L, gain="specified") if kname == "tanh-specified" else arcsine_profile(d, L))
    dist = lambda A, B: ((d - A.astype(float) @ B.astype(float).T) / 2).round().astype(int)
    rng = np.random.default_rng([d, n, seed, 20261019])
    idx = np.unique(rng.integers(0, 2 ** d, size=n))
    KXX = prof[dist(X[idx], X[idx])]; Kcx = prof[dist(X, X[idx])]
    cf = cho_factor(KXX, lower=True); Amat = cho_solve(cf, Kcx.T).T
    var = 1.0 - np.einsum("ij,ij->i", Amat, Kcx); var[idx] = 0.0
    s = np.sqrt(np.clip(var, 0, None)); unseen = np.ones(2 ** d, bool); unseen[idx] = False
    y = f[idx]; Sigma = KXX * np.outer(y, y); C = cholesky(Sigma, lower=True)
    qs = []
    srng = np.random.default_rng([d, L, seed, n, 4242])
    for c in range(2):
        z0 = np.abs(C @ srng.standard_normal(len(idx))) * (1.0 + c) + 1e-3
        G = hmc(Sigma, z0, burn + keep, srng)[burn:] * y[None, :]
        acc = np.zeros(2 ** d)
        for i in range(0, G.shape[0], 300):
            mu = G[i:i + 300] @ Amat.T
            z = np.zeros_like(mu); z[:, unseen] = f[None, unseen] * mu[:, unseen] / s[None, unseen]
            acc += ndtr(z).sum(0)
        q = acc / G.shape[0]; q[~unseen] = 1.0; qs.append(q)
    q = 0.5 * (qs[0] + qs[1])
    mreg = Amat @ y
    return dict(kernel=kname, d=d, L=L, seed=seed, n=n, n_distinct=int(len(idx)),
                F=float(np.mean(q <= 2 / 3)), F_unseen=float(np.mean(q[unseen] <= 2 / 3)),
                gibbs=float(np.mean(1 - q)), F_chain_diff=float(abs(np.mean(qs[0] <= 2 / 3) - np.mean(qs[1] <= 2 / 3))),
                max_dq_chains=float(np.max(np.abs(qs[0] - qs[1]))),
                regression_sign_err_unseen=float(np.mean(np.sign(mreg[unseen]) != f[unseen])),
                unseen_frac=float(unseen.mean()), seconds=time.time() - t0)


def main():
    ap = argparse.ArgumentParser(); ap.add_argument("--workers", type=int, default=4)
    a = ap.parse_args(); build()
    jobs = []
    for kname, L in [("tanh-unit", 2), ("tanh-unit", 3), ("tanh-specified", 3), ("arcsine", 2)]:
        for d, ngrid in [(10, [100, 200, 400, 800]), (12, [200, 400, 800, 1600])]:
            for n in ngrid:
                for seed in range(3):
                    jobs.append((kname, d, L, seed, n, 1500, 300))
    path = os.path.join(HERE, "signgp_parity.jsonl")
    done = set()
    if os.path.exists(path):  # resumable: skip completed (kernel, d, L, seed, n)
        for l in open(path):
            r = json.loads(l); done.add((r["kernel"], r["d"], r["L"], r["seed"], r["n"]))
    jobs = [j for j in jobs if j[:5] not in done]
    out = open(path, "a")
    with Pool(a.workers) as p:
        for row in p.imap_unordered(job, jobs):
            out.write(json.dumps(row) + "\n"); out.flush()
            print(row["kernel"], row["d"], row["L"], row["n"], row["seed"], round(row["F"], 3), round(row["seconds"]), flush=True)
    out.close()
    rows = [json.loads(l) for l in open(os.path.join(HERE, "signgp_parity.jsonl"))]
    lines = ["Sign-only learner, full parity: mean over 3 seeds of F=P_x{q<=2/3} (whole cube; observed inputs succeed)",
             "and, in brackets, F on unseen inputs only.  2 HMC chains x 1500 draws after 300 burn-in.", ""]
    for kname, L in [("tanh-unit", 2), ("tanh-unit", 3), ("tanh-specified", 3), ("arcsine", 2)]:
        for d in (10, 12):
            sel = [r for r in rows if r["kernel"] == kname and r["L"] == L and r["d"] == d]
            ns = sorted(set(r["n"] for r in sel))
            cells = []
            for n in ns:
                rr = [r for r in sel if r["n"] == n]
                cells.append(f"n={n}: {np.mean([r['F'] for r in rr]):.2f} [{np.mean([r['F_unseen'] for r in rr]):.2f}]")
            lines.append(f"{kname} L={L} d={d}: " + "; ".join(cells))
    lines.append("")
    lines.append(f"max |F(chain A) - F(chain B)| over all runs: {max(r['F_chain_diff'] for r in rows):.3f}")
    open(os.path.join(HERE, "signgp_parity.txt"), "w").write("\n".join(lines) + "\n")
    print("\n".join(lines))


if __name__ == "__main__":
    main()
