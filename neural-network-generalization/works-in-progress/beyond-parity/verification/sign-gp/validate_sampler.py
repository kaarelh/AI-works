"""Validate the exact-HMC sign posterior.
(1) small n: q(x) from HMC vs quasi-exact ratio of Gaussian orthant probabilities (Genz, scipy).
(2) moderate n: HMC vs an independent coordinatewise Gibbs sampler on the truncated normal.
Writes validate_sampler.json."""
import json, sys, time
import numpy as np
from scipy.stats import multivariate_normal
from scipy.special import ndtr, ndtri
sys.path.insert(0, __file__.rsplit("/", 1)[0])
from common import cube, gram
from signgp import sample_signs, Predictor, summarize_q
import targets as T

res = {}
rng = np.random.default_rng(7)
d, L = 10, 2
Xc = cube(d)

# ---------------- (1) small-n exact check
for tname in ["parity_full", "maj7"]:
    f = T.target_values(tname, d)
    n = 8
    idx = np.unique(rng.choice(2 ** d, n, replace=False))
    KXX = gram(Xc[idx], Xc[idx], d, L)
    Kcx = gram(Xc, Xc[idx], d, L)
    y = f[idx]
    t0 = time.time()
    G, nb = sample_signs(KXX, y, n_keep=20000, burn=500, n_chains=2, rng=rng)
    P = Predictor(Kcx, KXX, idx)
    q, _ = P.q_from_samples(G.reshape(-1, len(idx)), f)
    t_hmc = time.time() - t0
    test = rng.choice(np.setdiff1d(np.arange(2 ** d), idx), 12, replace=False)
    Sig = KXX * np.outer(y, y)
    p0 = multivariate_normal.cdf(np.zeros(n), np.zeros(n), Sig, abseps=1e-10, releps=1e-7, maxpts=5_000_000)
    rows = []
    for x in test:
        kx = Kcx[x] * y * f[x]
        S2 = np.block([[Sig, kx[:, None]], [kx[None, :], np.ones((1, 1))]])
        p1 = multivariate_normal.cdf(np.zeros(n + 1), np.zeros(n + 1), S2, abseps=1e-10, releps=1e-7,
                                     maxpts=5_000_000)
        rows.append(dict(x=int(x), q_exact=float(p1 / p0), q_hmc=float(q[x])))
    err = max(abs(r["q_exact"] - r["q_hmc"]) for r in rows)
    res[f"small_n_{tname}"] = dict(n=n, orthant_prob=float(p0), max_abs_err=float(err), rows=rows,
                                   bounces_per_iter=nb.tolist(), seconds=t_hmc)
    print(tname, "small-n max |q_hmc - q_exact| =", err, "P(orthant)=", p0, flush=True)


# ---------------- (2) Gibbs vs HMC at moderate n
def gibbs_trunc(Sigma, n_sweeps, rng, z0):
    """Coordinatewise Gibbs for N(0,Sigma) on z>0 (precision form)."""
    Pm = np.linalg.inv(Sigma)
    n = Sigma.shape[0]
    z = z0.copy()
    out = np.zeros((n_sweeps, n))
    dP = np.diag(Pm).copy()
    sd = 1 / np.sqrt(dP)
    for s in range(n_sweeps):
        U = rng.random(n)
        for i in range(n):
            m = -(Pm[i] @ z - dP[i] * z[i]) / dP[i]
            alpha = -m / sd[i]  # lower bound in standard units
            # upper-tail inverse cdf: X = -ndtri(U * Phi(-alpha)) is >= alpha
            tail = ndtr(-alpha)
            if tail > 1e-300:
                e = -ndtri(U[i] * tail)
            else:  # far tail: exponential approx
                e = alpha + rng.exponential() / alpha
            z[i] = m + sd[i] * max(e, alpha)
        out[s] = z
    return out


for tname, n in [("parity_full", 150), ("maj7", 150), ("parity3", 300)]:
    f = T.target_values(tname, d)
    idx = np.unique(rng.choice(2 ** d, n, replace=True))
    KXX = gram(Xc[idx], Xc[idx], d, L)
    Kcx = gram(Xc, Xc[idx], d, L)
    y = f[idx]
    P = Predictor(Kcx, KXX, idx)
    t0 = time.time()
    G, nb = sample_signs(KXX, y, n_keep=3000, burn=300, n_chains=2, rng=rng)
    t_h = time.time() - t0
    qa, _ = P.q_from_samples(G[0], f)
    qb, _ = P.q_from_samples(G[1], f)
    t0 = time.time()
    Sig = KXX * np.outer(y, y)
    Zg = gibbs_trunc(Sig, 6000, rng, np.ones(len(idx)) * 0.5)[1000:]
    t_g = time.time() - t0
    qg, _ = P.q_from_samples(Zg * y[None, :], f)
    sa, sb, sg = summarize_q(qa, f, P.unseen), summarize_q(qb, f, P.unseen), summarize_q(qg, f, P.unseen)
    # lag-1 autocorrelation of a summary statistic (mean of z) for each sampler
    def ac(x, lag=1):
        x = x - x.mean()
        return float((x[:-lag] * x[lag:]).mean() / (x * x).mean())
    zm_h = (G[0] * y[None, :]).mean(1)
    zm_g = Zg.mean(1)
    res[f"gibbs_vs_hmc_{tname}_n{n}"] = dict(
        n_distinct=int(len(idx)), hmc_chainA=sa, hmc_chainB=sb, gibbs=sg,
        max_abs_q_diff_hmcA_hmcB=float(np.max(np.abs(qa - qb))),
        max_abs_q_diff_hmc_gibbs=float(np.max(np.abs(0.5 * (qa + qb) - qg))),
        ac1_meanz_hmc=ac(zm_h), ac10_meanz_hmc=ac(zm_h, 10), ac1_meanz_gibbs=ac(zm_g), ac10_meanz_gibbs=ac(zm_g, 10),
        bounces_per_iter=nb.tolist(), sec_hmc=t_h, sec_gibbs=t_g)
    print(tname, n, json.dumps(res[f"gibbs_vs_hmc_{tname}_n{n}"], indent=None), flush=True)

json.dump(res, open(__file__.rsplit("/", 1)[0] + "/validate_sampler.json", "w"), indent=1)
