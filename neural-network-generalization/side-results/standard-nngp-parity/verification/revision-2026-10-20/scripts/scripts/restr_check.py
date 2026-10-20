# Exact check of the restriction lemma on {-1,1}^d:
# P_x(f h >= a) <= E_{m~Bin(d,p)} beta(j,m) + a^{-2} sum_U hhat(U)^2 P(Bin(|U|,p) > j),
# beta(j,m) = 1 - 2^{-m} sum_{i <= (m-j-1)/2} C(m,i).
import numpy as np, itertools, math
from scipy.stats import binom
rng = np.random.default_rng(1)
def setup(d):
    X = np.array(list(itertools.product([-1,1], repeat=d)))  # 2^d x d
    subsets = list(range(2**d))
    sizes = np.array([bin(U).count('1') for U in subsets])
    # character matrix: chi[x,U]
    chi = np.ones((2**d, 2**d))
    for U in subsets:
        idx = [i for i in range(d) if (U >> i) & 1]
        if idx: chi[:, U] = np.prod(X[:, idx], axis=1)
    f = np.prod(X, axis=1)
    return X, sizes, chi, f
def beta(j, m):
    if j >= m: return 1.0
    t = (m - j - 1)//2
    if t < 0: return 1.0
    return 1.0 - sum(math.comb(m, i) for i in range(t+1))/2**m
def rhs(hhat, sizes, d, p, j, a):
    Eb = sum(binom.pmf(m, d, p)*beta(j, m) for m in range(d+1))
    tail = sum(hhat[U]**2 * binom.sf(j, sizes[U], p) for U in range(len(hhat)))
    return Eb + tail/a**2
def check(d, trials=300):
    X, sizes, chi, f = setup(d)
    M = 2**d
    worst = 1e9; worst_info = None
    s = X.sum(axis=1)
    for t in range(trials):
        kind = rng.integers(0, 4)
        deg = rng.integers(1, d)
        if kind == 0:   # random low-degree polynomial
            hhat = rng.normal(size=M) * (sizes <= deg)
        elif kind == 1: # univariate in s: ABFR-like sign pattern of parity on middle levels times growth
            # build polynomial in s of degree deg with roots placed between levels near the middle
            levels = np.arange(-d, d+1, 2)
            mid = sorted(levels, key=lambda z: abs(z))[:deg+1]
            mid = sorted(mid)
            roots = [(mid[i]+mid[i+1])/2 for i in range(len(mid)-1)]
            vals = np.prod([s - r for r in roots], axis=0) if roots else np.ones(M)
            # align sign with parity at the middle level
            sgn = np.sign(np.mean(f[np.abs(s) == np.abs(mid[0])] * vals[np.abs(s) == np.abs(mid[0])])) or 1
            hv = sgn * vals * (1 + rng.random())
            hhat = chi.T @ hv / M
        elif kind == 2: # low-degree + high-degree noise
            hhat = rng.normal(size=M) * (sizes <= deg) + 0.3*rng.normal(size=M) * (sizes > deg)
        else:           # degree-limited sign approximations of parity of a sub-block
            k = rng.integers(1, d+1)
            hv = np.prod(X[:, :k], axis=1) * rng.random() + 0.5*rng.normal(size=M)
            hhat = chi.T @ hv / M
            hhat *= (sizes <= deg)
        h = chi @ hhat
        fh = f*h
        # choose a among quantiles of fh positive part
        pos = fh[fh > 0]
        if len(pos) == 0: continue
        for a in np.quantile(pos, [0.05, 0.3, 0.6, 0.9]):
            lhs = np.mean(fh >= a)
            best = 1e9
            for j in range(0, d):
                for p in [0.05, 0.1, 0.2, 0.3, 0.5, 0.7, 1.0]:
                    r = rhs(hhat, sizes, d, p, j, a)
                    best = min(best, r)
                    if lhs > r + 1e-12:
                        print("VIOLATION", d, kind, deg, a, j, p, lhs, r); return
            slack = best - lhs
            if slack < worst: worst = slack; worst_info = (kind, deg, a, lhs, best)
    print(f"d={d}: no violation; min slack (optimized over j,p) = {worst:.4f}; info={worst_info}")
for d in [6, 8, 10]:
    check(d, trials=150 if d == 10 else 300)
