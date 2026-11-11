"""Explicit construction of the memorizing network of Lemma 2.1 (A.md, Section 2) for small d,
followed by a forward pass with dense weight matrices and an exact energy computation.

Steps (as in the proof):
 1. sample n = lam*2^d inputs uniformly with replacement, fair +-1 labels; r(x) = ybar_x on seen atoms, 0 elsewhere;
 2. Fourier coefficients rhat(S); exact affine-tanh expansion r = sum beta_{S,u} phi_{S,u}  (checked to 1e-12);
 3. total coefficient A = sum |beta| (checked <= 2 sqrt(2d) ||r||_2 <= sqrt(8 d s));
 4. sample m features iid with prob |beta|/A, g = (A/m) sum xi_t; the Hoeffding m of the lemma is reported,
    but a smaller m may be used here (we then only REPORT the realized sup error |g-r|);
 5. depth-(H+1) network at width N >= m: first layer = balanced copies of the sampled rows, layer 2 weights
    A/(m k_t R^{H-1}), layers 3..H weights R/N, readout R/N; dense matrices, plain forward pass;
 6. energy kappa_N computed from the dense matrices; compared with the bound d(d+1)alpha_d^2 + 2A^2/R^{2H-2} + (H-1)R^2
    and with K_mem = d(d+1)alpha_d^2 + (H+1) max{(8ds)^{1/H}, 9/(2a)}.
Usage: python3 check_memorizer.py d H a m_override N seed
"""
import sys, itertools, math
import numpy as np

d = int(sys.argv[1]); H = int(sys.argv[2]); a = float(sys.argv[3])
m_over = int(sys.argv[4]); N = int(sys.argv[5]); seed = int(sys.argv[6])
rng = np.random.default_rng(seed)
M = 2 ** d; n = M
X = np.array(list(itertools.product([-1.0, 1.0], repeat=d)))           # M x d
Xbar = np.hstack([np.ones((M, 1)), X])
idx = rng.integers(0, M, size=n); y = rng.choice([-1.0, 1.0], size=n)
k = np.bincount(idx, minlength=M); S = np.bincount(idx, weights=y, minlength=M)
seen = k > 0; r = np.zeros(M); r[seen] = S[seen] / k[seen]
s = int(seen.sum()); Q = float(np.sum(r ** 2))
alpha = 0.5 * math.log(4 * math.sqrt(2 * d))

# Fourier coefficients
subsets = [tuple(c) for kk in range(d + 1) for c in itertools.combinations(range(d), kk)]
chi = np.array([[np.prod(x[list(Sset)]) if Sset else 1.0 for Sset in subsets] for x in X])  # M x 2^d
rhat = chi.T @ r / M
assert np.allclose(chi @ rhat, r)

def bk(kk): return 0 if kk % 2 == 1 else 1

# exact affine-tanh expansion
rows, betas = [], []
for j, Sset in enumerate(subsets):
    if abs(rhat[j]) < 1e-15:
        continue
    kk = len(Sset)
    if kk == 0:
        row = np.zeros(d + 1); row[0] = 1.0
        rows.append(row); betas.append(rhat[j] / math.tanh(1.0)); continue
    b = bk(kk)
    c = np.mean([np.prod(v) * math.tanh(alpha * (sum(v) - b)) for v in itertools.product([-1, 1], repeat=kk)])
    for u in itertools.product([-1, 1], repeat=kk):
        row = np.zeros(d + 1); row[0] = -alpha * b
        for jj, coord in enumerate(Sset):
            row[1 + coord] = alpha * u[jj]
        rows.append(row); betas.append(rhat[j] * np.prod(u) / (c * 2 ** kk))
rows = np.array(rows); betas = np.array(betas)
recon = np.tanh(Xbar @ rows.T) @ betas
A = float(np.sum(np.abs(betas)))
print(f"d={d} H={H} a={a} n={n} s={s} Q=sum r^2={Q:.3f}  exact expansion error={np.max(np.abs(recon - r)):.2e}")
print(f"  A={A:.3f} <= 2sqrt(2d)||r||_2={2*math.sqrt(2*d*Q):.3f} <= sqrt(8ds)={math.sqrt(8*d*s):.3f}; "
      f"max row norm^2={np.max(np.sum(rows**2,1)):.3f} <= (d+1)alpha_d^2={(d+1)*alpha**2:.3f}")

# sampling
m_hoeff = math.floor(8 * A ** 2 * (d + 1) * math.log(2) / a ** 2) + 1
m = m_over if m_over > 0 else m_hoeff
assert N >= m
p = np.abs(betas) / A
pick = rng.choice(len(betas), size=m, p=p)
sampled_rows = rows[pick] * np.sign(betas[pick])[:, None]       # sign absorbed (tanh odd)
g = (A / m) * np.tanh(Xbar @ sampled_rows.T).sum(1)
print(f"  Hoeffding m={m_hoeff}, used m={m}, realized max|g-r|={np.max(np.abs(g-r)):.4f} (target a/2={a/2})")

# network at width N
R = max(A ** (1.0 / H), math.sqrt(9 / (2 * a)))
kt = np.full(m, N // m); kt[: N - m * (N // m)] += 1
assert kt.sum() == N and kt.min() >= 1
groups = np.repeat(np.arange(m), kt)
W1 = sampled_rows[groups]                                          # N x (d+1)
W2 = np.tile((A / (m * kt[groups] * R ** (H - 1)))[None, :], (N, 1)) # N x N
mids = [W2] + [np.full((N, N), R / N) for _ in range(H - 2)]
v = np.full(N, R / N)
h = np.tanh(Xbar @ W1.T)
for Wl in mids:
    h = np.tanh(h @ Wl.T)
z = h @ v
kappa = (d / N) * np.sum(W1 ** 2) + sum(np.sum(Wl ** 2) for Wl in mids) + N * np.sum(v ** 2)
first = (d / N) * np.sum(W1 ** 2)
bound_detail = d * (d + 1) * alpha ** 2 + 2 * A ** 2 / R ** (2 * H - 2) + (H - 1) * R ** 2
Kmem = d * (d + 1) * alpha ** 2 + (H + 1) * max((8 * d * s) ** (1.0 / H), 9 / (2 * a))
chain_pred = (np.max(np.abs(g)) ** 3 / 3) * sum(R ** (-2 * i) for i in range(1, H))
print(f"  width N={N}, R={R:.3f}: max|z-g|={np.max(np.abs(z-g)):.2e} (chain bound {chain_pred:.2e}), "
      f"max|z-r|={np.max(np.abs(z-r)):.4f} (a={a})")
print(f"  kappa_N={kappa:.3f} [first layer {first:.3f}] <= detailed bound {bound_detail:.3f} <= K_mem={Kmem:.3f}")
print(f"  test-MSE excess of this memorizer (fair labels): (1/M) sum z^2 = {np.mean(z**2):.4f} vs Q/M={Q/M:.4f}")
