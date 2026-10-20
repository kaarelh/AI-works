# Vectorized exact check of the restriction lemma:
# P_x(f h >= a) <= E_{m~Bin(d,p)} beta(j,m) + a^{-2} sum_q w_q(h) P(Bin(q,p) > j),  w_q = sum_{|U|=q} hhat(U)^2.
import numpy as np, itertools, math, sys
from scipy.stats import binom
rng = np.random.default_rng(int(sys.argv[2]) if len(sys.argv) > 2 else 1)
def walsh_matrix(d):
    H = np.array([[1.0]])
    for _ in range(d):
        H = np.block([[H, H], [H, -H]])
    return H  # H[x,U] = chi_U(x) with bit-encoded x (bit=1 means -1)
def beta(j, m):
    if j >= m: return 1.0
    t = (m - j - 1)//2
    return 1.0 - sum(math.comb(m, i) for i in range(t+1))/2**m
def run(d, trials):
    M = 2**d
    H = walsh_matrix(d)
    sizes = np.array([bin(U).count('1') for U in range(M)])
    xs = np.array([[1 - 2*((x >> i) & 1) for i in range(d)] for x in range(M)])
    f = np.prod(xs, axis=1).astype(float)
    s = xs.sum(axis=1)
    ps = np.linspace(0.02, 1.0, 50)
    Eb = np.array([[sum(binom.pmf(m, d, p)*beta(j, m) for m in range(d+1)) for p in ps] for j in range(d)])  # [j,p]
    tailw = np.array([[[binom.sf(j, q, p) for q in range(d+1)] for p in ps] for j in range(d)])  # [j,p,q]
    worst = 1e9; info = None
    for t in range(trials):
        kind = rng.integers(0, 5); deg = int(rng.integers(1, d))
        if kind == 0:
            hhat = rng.normal(size=M)*(sizes <= deg)
        elif kind == 1:
            levels = np.arange(-d, d+1, 2)
            mid = sorted(sorted(levels, key=lambda z: (abs(z), z))[:deg+1])
            roots = [(mid[i]+mid[i+1])/2 for i in range(len(mid)-1)]
            vals = np.prod([s - r for r in roots], axis=0) if roots else np.ones(M)
            z0 = mid[len(mid)//2]
            sg = np.sign(np.mean((f*vals)[s == z0])) or 1.0
            hhat = H.T @ (sg*vals) / M
        elif kind == 2:
            hhat = rng.normal(size=M)*(sizes <= deg) + 0.3*rng.normal(size=M)*(sizes > deg)
        elif kind == 3:
            k = int(rng.integers(1, d+1))
            hv = np.prod(xs[:, :k], axis=1)*rng.random() + 0.5*rng.normal(size=M)
            hhat = (H.T @ hv / M)*(sizes <= deg)
        else:
            # large constant + low-degree part (constant is free)
            hhat = rng.normal(size=M)*(sizes <= deg); hhat[0] += 10*rng.random()
        h = H @ hhat
        fh = f*h
        w = np.bincount(sizes, weights=hhat**2, minlength=d+1)
        pos = fh[fh > 0]
        if len(pos) == 0: continue
        for a in np.quantile(pos, [0.02, 0.1, 0.3, 0.6, 0.9]):
            lhs = np.mean(fh >= a)
            rhs = Eb + (tailw @ w)/a**2      # [j,p]
            best = rhs.min()
            if lhs > best + 1e-12:
                print("VIOLATION", d, kind, deg, a, lhs, best); return
            if best - lhs < worst:
                worst = best - lhs; jj, pp = np.unravel_index(np.argmin(rhs), rhs.shape); info = (kind, deg, round(float(a),3), lhs, round(float(best),4), jj, round(float(ps[pp]),2))
    print(f"d={d}: {trials} trials, no violation; min slack = {worst:.4f}; (kind,deg,a,lhs,rhs,j,p)={info}", flush=True)
d = int(sys.argv[1]); run(d, 400 if d <= 10 else 150)
