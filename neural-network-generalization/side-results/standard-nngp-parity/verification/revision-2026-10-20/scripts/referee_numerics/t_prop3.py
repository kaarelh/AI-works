# Test Proposition 3's probability bound against a GHK estimate of P(B), B={y_i G(X_i) > a for all i},
# using the sample's actual coercivity constant (estimated from above by local minimization),
# eps^2(S), V=y'Q y, Lambda=||Q_SS||. With kappa in place of 1/4: s = n kappa a^2/(4 eps^2).
import numpy as np, itertools
from math import comb, log
from scipy.stats import norm
from scipy.optimize import minimize
from scipy.special import logsumexp
rng = np.random.default_rng(11)
d = 12; lam = np.load(f"lam_d{d}.npy"); M = 2**d
def Kdist(lamv):
    return np.array([sum(lamv[q]*sum((-1)**j*comb(k,j)*comb(d-k,q-j) for j in range(0,min(k,q)+1) if q-j<=d-k) for q in range(d+1)) for k in range(d+1)])
Kk = Kdist(lam)
def chars_upto(X, r):
    cols = []
    for q in range(r+1):
        for U in itertools.combinations(range(d), q):
            cols.append(np.prod(X[:, list(U)], axis=1) if q else np.ones(len(X)))
    return np.array(cols).T
def ghk_logp(Sig, a, N=4000):
    n = len(Sig); L = np.linalg.cholesky(Sig + 1e-14*np.eye(n))
    logw = np.zeros(N); E = np.zeros((N, n))
    for i in range(n):
        mu = E[:, :i] @ L[i, :i]
        lo = (a - mu)/L[i, i]
        ls = norm.logsf(lo); logw += ls
        u = rng.random(N)
        E[:, i] = norm.isf(np.clip(u*np.exp(ls), 1e-300, None))
    m = logsumexp(logw) - np.log(N)
    w = np.exp(logw - logw.max()); ess = w.sum()**2/(w**2).sum()
    return m, ess
def kappa_hat(Phi, y, tries=60):
    n, Dr = Phi.shape; A = y[:, None]*Phi
    f = lambda u: np.sum(np.minimum(A@u, 0)**2)/n/np.dot(u, u)
    best = np.inf
    for t in range(tries):
        u0 = rng.standard_normal(Dr)
        res = minimize(f, u0, method="BFGS")
        best = min(best, res.fun)
    return best
print("d=12; columns: r n a | kappa_hat eps2 V/(n tau) Lam/tau | logP(B) GHK (ess) | log bound(Prop3) | bound terms")
for r in [1, 3]:
    lamt = np.array([lam[q] if q > r else 0.0 for q in range(d+1)]); Qk = Kdist(lamt); tau = Qk[0]
    Dr = sum(comb(d, q) for q in range(r+1))
    for n in ([30, 60, 120, 250] if r == 1 else [120, 250, 400]):
        idx = rng.choice(M, size=n, replace=False)
        X = 1 - 2*((idx[:, None] >> np.arange(d)) & 1); y = np.prod(X, axis=1)
        H = np.bitwise_count(idx[:, None] ^ idx[None, :]).astype(int)
        KSS = Kk[H]; QSS = Qk[H]
        Phi = chars_upto(X, r)
        eps2 = np.sum((Phi.T @ y / n)**2)
        V = y @ QSS @ y; Lam = np.linalg.eigvalsh(QSS)[-1]; tr = n*tau
        kap = kappa_hat(Phi, y)
        Sig = (y[:, None]*KSS)*y[None, :]
        for a in [0.02, 0.05, 0.1, 0.2]:
            s = n*kap*a*a/(4*eps2)
            t1 = -n*n*a*a/(8*V)
            t2 = -(s - 2*log(2)*tr)/(4*Lam) if s > 2*log(2)*tr else 0.0
            lb = np.logaddexp(t1, t2)
            lp, ess = ghk_logp(Sig, a)
            flag = "VIOLATION" if lp > lb + 0.5 else ""
            print(f"r={r} n={n:4d} a={a:4.2f} | kap={kap:.3f} eps2={eps2:.3f} V/ntau={V/tr:.3f} Lam/tau={Lam/tau:.2f} | logP={lp:9.2f} (ess {ess:7.1f}) | logbound={lb:9.3f} | t1={t1:.2f} t2={t2:.2f} {flag}")
