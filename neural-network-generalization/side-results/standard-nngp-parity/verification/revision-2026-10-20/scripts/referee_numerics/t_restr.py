# Restriction lemma (exploration): P_x(f h >= a) <= E_{m~Bin(d,p)} beta(j,m) + a^-2 sum_U hhat(U)^2 P(Bin(|U|,p) > j)
import numpy as np
from math import comb
from scipy.stats import binom
from scipy.linalg import hadamard
rng = np.random.default_rng(3)
def beta(j, m):
    t = (m-j-1)//2 if m-j-1 >= 0 else -1
    return 1 - sum(comb(m, i) for i in range(0, t+1))/2**m
worst = np.inf; wcase = None
for d in [10, 12]:
    M = 2**d; Hm = hadamard(M).astype(float)
    deg = np.bitwise_count(np.arange(M)); X = 1-2*((np.arange(M)[:, None] >> np.arange(d)) & 1)
    f = np.prod(X, axis=1); ssum = X.sum(1)
    funcs = []
    for k in range(1, d+1):   # univariate PTFs in sum: h = prod_{t}(s - t) over sign-change points restricted
        # polynomial in s of degree k agreeing in sign with parity on as many levels as possible
        roots = np.linspace(-k+1, k-1, k)  # centered roots at odd/even interleaving
        h = np.prod([ssum - r0 for r0 in roots], axis=0).astype(float)
        if np.mean(np.sign(h) == f) < 0.5: h = -h
        funcs.append(("ptf%d" % k, h))
    for q in [1, 2, 3, 5, 8, d]:
        for t in range(10):
            coef = rng.standard_normal(M)*(deg <= q)*(rng.random(M) < 0.3)
            h = Hm @ coef
            funcs.append((f"rand_deg{q}", h))
            funcs.append((f"rand_deg{q}+par", h/np.std(h) + 3*f))
    funcs.append(("parity", f.copy()))
    funcs.append(("parity+const", f + 5.0))
    for name, h in funcs:
        hhat = Hm @ h / M
        for a in np.quantile(np.abs(h), [0.05, 0.3, 0.6, 0.9]):
            if a <= 0: continue
            lhs = np.mean(f*h >= a)
            for p in [0.05, 0.1, 0.2, 0.35, 0.5, 0.8, 1.0]:
                pm = binom.pmf(np.arange(d+1), d, p)
                for j in range(0, d+1):
                    Eb = sum(pm[m]*beta(j, m) for m in range(d+1))
                    tailq = np.array([binom.sf(j, q, p) for q in range(d+1)])
                    rhs = Eb + np.sum(hhat**2*tailq[deg])/a**2
                    if rhs - lhs < worst:
                        worst = rhs-lhs; wcase = (d, name, a, p, j, lhs, rhs)
print("min slack rhs-lhs:", worst, "at", wcase)
