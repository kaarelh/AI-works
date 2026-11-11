"""Claim C, Theorem C.1 (progressive-mixture oracle inequality) and Theorems C.6/C.7 (high probability),
Monte Carlo on a finite dictionary with exact population losses.

D: x uniform on 40 fixed points of [-1,1]; y = clip(sin 3x) w.p. 0.6, else y ~ U[-1,1] (labels in [-1,1]).
Prior: a non-uniform probability vector mu over K random clipped tanh functions.
Checks:
 (i)  per-sequence inequality  sum_{t=0}^{n} (fhat_t(x_{t+1})-y_{t+1})^2 <= -(1/eta) log W_{n+1}  (deterministic);
 (ii) E L_D(fbar_n) <= inf_Q [Q L_D + KL(Q||mu)/(eta(n+1))] = -(1/(eta(n+1))) log sum_j mu_j exp(-eta(n+1) L_j);
 (iii) Theorem C.6: P[ L_D(ftilde_n) > L_{j*} + log(1/mu_{j*})/(eta n) + 4 sqrt(2 log(1/delta)/n) ] <= 2 delta;
 (iv) Theorem C.7: P[ Gibbs risk > L_{j*} + 4 eta + (log(1/mu_{j*}) + 2 log(1/delta))/(eta n) ] <= 2 delta.
"""
import numpy as np
rng = np.random.default_rng(1)
M = 40
xs = np.sort(rng.uniform(-1, 1, M))
fstar = np.clip(np.sin(3 * xs), -1, 1)
pclean = 0.6
# exact conditional moments of y given x: y = fstar w.p. pclean, else U[-1,1] (mean 0, E y^2 = 1/3)
Ey = pclean * fstar
Ey2 = pclean * fstar ** 2 + (1 - pclean) / 3.0
def LD(f):  # f: (..., M) values on support; exact population loss
    return np.mean(f ** 2 - 2 * f * Ey + Ey2, axis=-1)

K = 300
a = rng.uniform(-2, 2, K); b = rng.uniform(-4, 4, K); c = rng.uniform(-2, 2, K)
H = np.clip(a[:, None] * np.tanh(b[:, None] * xs[None, :] + c[:, None]), -1, 1)  # K x M
mu = rng.dirichlet(np.ones(K) * 0.5)
Lj = LD(H)
eta = 0.125
delta = 0.05

def sample(n):
    idx = rng.integers(0, M, n)
    clean = rng.uniform(size=n) < pclean
    y = np.where(clean, fstar[idx], rng.uniform(-1, 1, n))
    return idx, y

def run(n, R=3000):
    viol_seq = 0; risks = []; risk_last = []; gibbs = []; viol_hp = 0; viol_gibbs = 0
    # competitor for (iii)/(iv): the single dictionary element minimising L_j + log(1/mu_j)/(eta n); Q = point mass
    jbest = np.argmin(Lj + np.log(1 / mu) / (eta * n))
    for _ in range(R):
        idx, y = sample(n + 1)  # the last pair is the ghost sample (analysis only)
        logw = np.log(mu).copy()  # log of the unnormalised posterior weights; log W_0 = 0
        online = 0.0
        fhats = []
        for t in range(n + 1):
            w = np.exp(logw - logw.max()); w /= w.sum()
            fh = w @ H          # posterior mean of clipped outputs after t samples
            fhats.append(fh)
            online += (fh[idx[t]] - y[t]) ** 2
            logw = logw - eta * (H[:, idx[t]] - y[t]) ** 2
        m2 = logw.max(); logW_n1 = np.log(np.sum(np.exp(logw - m2))) + m2   # log W_{n+1}
        if online > -logW_n1 / eta + 1e-9:
            viol_seq += 1
        fhats = np.array(fhats)
        fbar = fhats.mean(0)                    # average over t = 0..n (uses the n observed pairs only)
        risks.append(LD(fbar))
        risk_last.append(LD(fhats[-1]))         # final posterior mean (not covered by Theorem C.1)
        ftilde = fhats[:n].mean(0)              # average over t = 0..n-1
        bound_hp = Lj[jbest] + np.log(1 / mu[jbest]) / (eta * n) + 4 * np.sqrt(2 * np.log(1 / delta) / n)
        if LD(ftilde) > bound_hp:
            viol_hp += 1
        logp = np.log(mu) - eta * ((H[:, idx[:n]] - y[None, :n]) ** 2).sum(1)   # posterior after n samples
        wpost = np.exp(logp - logp.max()); wpost /= wpost.sum()
        g = wpost @ Lj                          # Gibbs risk
        gibbs.append(g)
        bound_g = Lj[jbest] + 4 * eta + (np.log(1 / mu[jbest]) + 2 * np.log(1 / delta)) / (eta * n)
        if g > bound_g:
            viol_gibbs += 1
    lse = -np.log(np.sum(mu * np.exp(-eta * (n + 1) * (Lj - Lj.min())))) / (eta * (n + 1)) + Lj.min()
    risks = np.array(risks)
    print(f"n={n:4d}: E L(fbar)={risks.mean():.4f} (+-{2*risks.std()/np.sqrt(R):.4f})  inf_Q bound={lse:.4f}  holds={risks.mean() <= lse}"
          f" | E L(final post. mean)={np.mean(risk_last):.4f}  E Gibbs={np.mean(gibbs):.4f}  min_j L_j={Lj.min():.4f}"
          f" | per-seq violations={viol_seq} | ThmC.6 viol. freq={viol_hp/R:.3f}  ThmC.7 viol. freq={viol_gibbs/R:.3f} (allowed {2*delta})")

print(f"K={K}, eta={eta}, Bayes risk (E Var(y|x))={np.mean(Ey2-Ey**2):.4f}, min_j L_j={Lj.min():.4f}, L(0)={LD(np.zeros(M)):.4f}")
for n in [5, 20, 80, 320]:
    run(n)
