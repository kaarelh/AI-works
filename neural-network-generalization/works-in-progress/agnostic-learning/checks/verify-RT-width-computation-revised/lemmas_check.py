"""Lemmas A, D, E and Remark 6(b) of RT-width.fixed.md, independently.

(A) cloning: adversarial competitors (all weights +-B, aligned signs) at the worst widths N = 2m-1 (ratio
    ceil/floor = 2) and N = m, m+1; exactness of the clone, kappa_N(clone)/E_*; also the per-layer bounds.
(D) grid: |T| = ceil(2R/eta)+1 <= 2 + 2R/eta; every point of [-R,R] within eta/2 of T (exact arithmetic with
    fractions on random R/eta ratios).
(E) Bernstein (Lemma E(ii)) vs exact binomial tail for {0,b} losses (the extremal law for a given mean and
    range) on a fine grid, including tiny mu and n; and Hoeffding (Lemma E(i)).
(6b) Remark 6(b) competitor: exact binomial quantile of hat L(g) - L_D(g) vs (G+1)/sqrt n and the withdrawn rate.
"""
import numpy as np
from fractions import Fraction
from scipy import stats
import math
rng = np.random.default_rng(3)

def forward(W1, Ws, v, X):
    Xb = np.hstack([np.ones((X.shape[0], 1)), X]); h = np.tanh(Xb @ W1.T)
    for W in Ws: h = np.tanh(h @ W.T)
    return h @ v

def energy_parts(W1, Ws, v, d, N):
    return [d/N*np.sum(W1**2)] + [np.sum(W**2) for W in Ws] + [N*np.sum(v**2)]

# (A)
worst_ratio = 0; worst_err = 0; worst_layer = [0, 0, 0]; cnt = 0
for trial in range(600):
    H = int(rng.integers(1, 5)); d = int(rng.integers(1, 6)); m = int(rng.integers(1, 9)); B = float(rng.choice([0.3, 1.0, 2.5]))
    mode = trial % 3
    if mode == 0:
        U1 = B*rng.choice([-1, 1], (m, d+1)); Us = [B*rng.choice([-1, 1], (m, m)) for _ in range(H-1)]; u = B*rng.choice([-1, 1], m)
    elif mode == 1:
        U1 = np.full((m, d+1), B); Us = [np.full((m, m), B) for _ in range(H-1)]; u = np.full(m, B)
    else:
        U1 = rng.uniform(-B, B, (m, d+1)); Us = [rng.uniform(-B, B, (m, m)) for _ in range(H-1)]; u = rng.uniform(-B, B, m)
    for N in sorted({m, m+1, 2*m-1, 2*m, 3*m-1, 7*m+3}):
        if N < m: continue
        k = np.array([N//m + (1 if j < N % m else 0) for j in range(m)])
        assert k.sum() == N and k.min() >= 1 and k.max() <= 2*k.min()
        grp = np.repeat(np.arange(m), k)
        W1 = U1[grp]; Ws = [U[np.ix_(grp, grp)]/k[grp][None, :] for U in Us]; v = u[grp]/k[grp]
        X = rng.uniform(-1, 1, (100, d)); X[:10] = np.sign(X[:10])
        err = np.max(np.abs(forward(U1, Us, u, X) - forward(W1, Ws, v, X)))
        parts = energy_parts(W1, Ws, v, d, N)
        Estar = d*(d+1)*B**2 + 2*H*m**2*B**2
        worst_err = max(worst_err, err); worst_ratio = max(worst_ratio, sum(parts)/Estar)
        worst_layer[0] = max(worst_layer[0], parts[0]/(d*(d+1)*B**2))
        if H > 1: worst_layer[1] = max(worst_layer[1], max(parts[1:-1])/(2*m**2*B**2))
        worst_layer[2] = max(worst_layer[2], parts[-1]/(2*m**2*B**2))
        cnt += 1
print("(A) %d clones: max |clone-g| = %.1e; max kappa/E_* = %.4f; per-layer max ratios: first %.4f, internal %.4f, readout %.4f (all <= 1)"
      % (cnt, worst_err, worst_ratio, *worst_layer))

# (D) grid
bad = 0; worst_gap = Fraction(0)
for trial in range(4000):
    eta = Fraction(int(rng.integers(1, 1000)), int(rng.integers(1, 1000)))
    R = Fraction(int(rng.integers(1, 10**6)), int(rng.integers(1, 1000)))
    kmax = math.ceil(2*R/eta)
    size = kmax + 1
    if not (size <= 2 + 2*R/eta): bad += 1
    last = -R + kmax*eta
    if last < R: bad += 1
    # covering radius: points of [-R,R] at distance <= eta/2 (grid spacing eta, endpoints -R and >= R)
    # worst point is a midpoint between consecutive grid points, or R itself if R lies beyond the last midpoint
    for y in [R, -R, -R + eta/2, R - eta/3]:
        kk = (y + R)/eta; k0 = math.floor(kk); dist = min(abs(y - (-R + k0*eta)), abs(y - (-R + min(k0+1, kmax)*eta)))
        worst_gap = max(worst_gap, dist/eta)
print("(D) grid: violations of |T| <= 2+2R/eta or last >= R: %d; max (distance to grid)/eta = %s (must be <= 1/2)" % (bad, float(worst_gap)))

# (E) Bernstein and Hoeffding vs exact binomial tails for {0,b} losses
worstB = 0; wB = None; worstH = 0; cases = 0
for dp in [0.25, 0.05, 0.0125, 1e-3, 1e-6]:
    l = math.log(1/dp)
    for n in [1, 2, 3, 5, 10, 30, 100, 1000, 10**4, 10**6]:
        for b in [1.0, 4.0, 100.0, 1e6]:
            for mu in np.geomspace(1e-9*b, b*(1-1e-9), 120):
                p = mu/b
                t = math.sqrt(2*b*mu*l/n) + 2*b*l/(3*n)
                kmin = math.ceil(n*(mu + t)/b - 1e-12)
                tail = stats.binom.sf(kmin-1, n, p) if kmin <= n else 0.0
                tH = b*math.sqrt(l/(2*n)); kminH = math.ceil(n*(mu + tH)/b - 1e-12)
                tailH = stats.binom.sf(kminH-1, n, p) if kminH <= n else 0.0
                cases += 1
                if tail/dp > worstB: worstB, wB = tail/dp, (dp, n, b, mu)
                worstH = max(worstH, tailH/dp)
print("(E) %d cases: max exact tail/delta' for Bernstein threshold = %.4f at %s; for Hoeffding = %.4f (must be <= 1)" % (cases, worstB, wB, worstH))

# (6b)
print("(6b) Remark 6(b) competitor (d=1, L=3, m=ceil(n^a), B=n^a):")
for a in [0.1, 0.15, 0.2]:
    row = []
    for e in [8, 10, 12, 14]:
        n = 10**e; m = math.ceil(n**a); B = n**a
        G = m*B*math.tanh(m*B*math.tanh(B)); p = 1/(G+1)**2
        k = stats.binom.isf(0.05, n, p)
        q = (G+1)**2*k/n - 1
        rate = n**(4*a-1) + n**(a-0.5)*math.sqrt(math.log(n))
        row.append("n=1e%d: q/((G+1)/sqrt n)=%.3f q/rate=%.2f" % (e, q/((G+1)/math.sqrt(n)), q/rate))
    print("    a=%.2f  " % a + " | ".join(row))
