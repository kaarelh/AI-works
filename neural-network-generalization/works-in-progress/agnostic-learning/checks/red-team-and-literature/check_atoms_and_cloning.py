"""(i) Atom constant of Claim A vs Cover's k-NN formula R*(1+1/k).
    With Var(y|x)=1, eta=0, a predictor equal to the mean of the K training labels
    at the test atom (0 if K=0) has test MSE 1 + E[1/K; K>=1]  (Cover 1968: R*(1+1/k)).
    K ~ Bin(n, 2^-d) ~ Poisson(lam), lam = n / 2^d.
(ii) Norm-based capacity measures under balanced cloning of a width-1 tanh network.
    Repo energy kappa_N = (d/N)|W1|_F^2 + sum_internal |Wl|_F^2 + N|v|^2.
    BFT spectral complexity (definition as recalled, M_i = 0):
        R_A = (prod_i |A_i|_sigma) * (sum_i (|A_i^T|_{2,1} / |A_i|_sigma)^{2/3})^{3/2},
    |A^T|_{2,1} = sum of Euclidean norms of the rows of A.
(iii) Lip(z_w) <= sqrt(prod_l kappa_l / d) <= (K/L)^{L/2}/sqrt(d) on random nets.
"""
import numpy as np
from scipy import stats, optimize

# ---------- (i) ----------
def f_pois(lam, kmax=200):
    k = np.arange(1, kmax)
    return float(np.sum(stats.poisson.pmf(k, lam) / k))

def f_binom(n, q):
    k = np.arange(1, min(n, 200) + 1)
    return float(np.sum(stats.binom.pmf(k, n, q) / k))

print("E[1/K;K>=1], Poisson(1):", round(f_pois(1.0), 6), "-> test MSE", round(1 + f_pois(1.0), 6))
res = optimize.minimize_scalar(lambda l: -f_pois(l), bounds=(0.1, 5), method="bounded")
print("max over lam: lam* =", round(res.x, 4), " value =", round(-res.fun, 6),
      "-> test MSE", round(1 - res.fun, 6))
for d in [10, 20, 30]:
    n = 2 ** d
    print(f"d={d}: Binomial(2^d,2^-d): {f_binom(n, 2.0 ** -d):.6f};  "
          f"n=round(1.5*2^d): {f_binom(int(round(1.5 * n)), 2.0 ** -d):.6f}")
for lam in [0.01, 0.1, 1, 10, 100]:
    print(f"lam={lam}: E[1/K;K>=1] = {f_pois(lam, kmax=2000):.5f}")

# ---------- (ii) ----------
def spec(A): return np.linalg.norm(A, 2)
def r21(A): return np.linalg.norm(A, axis=1).sum()

d = 3
u = np.array([0.3, 1.0, -0.5, 0.8])          # first-layer row on xbar=(1,x), length d+1
alpha, beta = 1.7, 2.0
print("\n N   kappa_N   prod|.|_F   prod|.|_sigma   R_A(BFT)   R_A/sqrt(N)")
for N in [1, 4, 16, 64, 256, 1024]:
    W1 = np.tile(u, (N, 1))                    # N x (d+1), all rows = u
    W2 = np.full((N, N), alpha / N)            # internal layer: mean then scale
    v = np.full((1, N), beta / N)              # readout
    layers = [W1, W2, v]
    kappa = (d / N) * np.sum(W1 ** 2) + np.sum(W2 ** 2) + N * np.sum(v ** 2)
    pF = np.prod([np.linalg.norm(A) for A in layers])
    pS = np.prod([spec(A) for A in layers])
    RA = pS * np.sum([(r21(A) / spec(A)) ** (2 / 3) for A in layers]) ** 1.5
    print(f"{N:5d} {kappa:9.4f} {pF:10.4f} {pS:12.4f} {RA:12.3f} {RA/np.sqrt(N):10.4f}")
# the cloned network computes beta*tanh(alpha*tanh(u.xbar)) at every N (check one input)
x = np.array([1.0, 0.2, -0.4, 0.1])
for N in [1, 64]:
    W1 = np.tile(u, (N, 1)); W2 = np.full((N, N), alpha / N); v = np.full(N, beta / N)
    print(f"N={N}: z(x) = {v @ np.tanh(W2 @ np.tanh(W1 @ x)):.6f}")

# ---------- (iii) ----------
rng = np.random.default_rng(2)
worst = 0.0
for trial in range(300):
    L = rng.integers(2, 5); N = rng.integers(2, 40); dd = rng.integers(1, 6)
    Ws = [rng.normal(size=(N, dd + 1)) * rng.uniform(0.1, 3)]
    Ws += [rng.normal(size=(N, N)) * rng.uniform(0.01, 1) for _ in range(L - 2)]
    v = rng.normal(size=N) * rng.uniform(0.01, 1)
    kap = [(dd / N) * np.sum(Ws[0] ** 2)] + [np.sum(A ** 2) for A in Ws[1:]] + [N * np.sum(v ** 2)]
    K = sum(kap)
    bound_prod = np.sqrt(np.prod(kap) / dd)
    bound_amgm = (K / L) ** (L / 2) / np.sqrt(dd)
    # empirical Lipschitz lower estimate: max gradient norm over random inputs in [-1,1]^d
    best = 0.0
    for _ in range(200):
        xx = rng.uniform(-1, 1, size=dd); h = np.concatenate([[1.0], xx]); J = np.eye(dd + 1)[:, 1:]
        for A in Ws:
            pre = A @ h; h = np.tanh(pre); J = (1 - h ** 2)[:, None] * (A @ J)
        best = max(best, np.linalg.norm(v @ J))
    assert bound_prod <= bound_amgm * (1 + 1e-12) and best <= bound_prod * (1 + 1e-9)
    worst = max(worst, best / bound_prod)
print("\nLipschitz check passed on 300 random nets; max (empirical grad)/(sqrt(prod kappa/d)) =",
      round(worst, 4))
