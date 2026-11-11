"""Check Proposition 5.3 of redteam.md (Hadamard atoms, d = M, depth two).

Builds the explicit memorizer z(x) = eps^{-1} tanh(eps u.x) as a width-N network
(all N first-layer rows (0, eps*u), all readout weights 1/(N eps)), and checks
  * u.a_k = ybar_k 1_T(k), ||u||^2 = Q/M
  * kappa_N = (d/N)||W1||_F^2 + N||v||^2 = eps^2 Q + eps^-2 = 2 sqrt(Q) at eps^2 = Q^-1/2
  * |z(a_k) - ybar_k| <= eps^2/3 on seen atoms, z = 0 on unseen atoms
  * R(z) <= n/(9Q)
  * resulting near-minimizer bound R(z_w) <= c(2 sqrt Q + 1) + n/(9Q)
  * Lemma 1.2(a) excess lower bound (sqrt(Q) - sqrt(Rbound))_+^2 / M versus beta(lambda)
"""
import numpy as np
from scipy.linalg import hadamard

rng = np.random.default_rng(1)

def beta_pois(lam, kmax=200):
    from scipy import special
    k = np.arange(1, kmax)
    return float(np.sum(np.exp(-lam + k*np.log(lam) - special.gammaln(k+1))/k))

def stats_from_sample(idx, y, M):
    k = np.bincount(idx, minlength=M).astype(float)
    S = np.bincount(idx, weights=y, minlength=M)
    T = k > 0
    ybar = np.zeros(M); ybar[T] = S[T]/k[T]
    Q = float(np.sum(ybar[T]**2)); G = float(np.sum(k[T]*ybar[T]**2)); V = float(np.sum(S**2))
    W = float(np.sum((y - ybar[idx])**2))
    return k, S, T, ybar, Q, G, V, W

worst_err_ratio = 0.0
for M in [16, 64, 256, 1024, 4096]:
    A = hadamard(M).astype(float)          # rows a_j, a_j . a_k = M delta_jk
    assert np.allclose(A @ A.T, M*np.eye(M))
    d = M
    for lam in [1.0, 1.5]:
        n = int(np.ceil(lam*M))
        idx = rng.integers(0, M, size=n)
        y = rng.choice([-1.0, 1.0], size=n)
        k, S, T, ybar, Q, G, V, W = stats_from_sample(idx, y, M)
        u = (ybar[T] @ A[T]) / M
        assert np.allclose(A @ u, ybar*T), "u.a_k != ybar_k 1_T"
        assert np.isclose(u @ u, Q/M)
        eps = Q**(-0.25)
        for N in [1, 2, 7]:
            W1 = np.zeros((N, d+1)); W1[:, 1:] = eps*u   # bias column 0
            v = np.full(N, 1.0/(N*eps))
            kappa = (d/N)*np.sum(W1**2) + N*np.sum(v**2)
            assert np.isclose(kappa, eps**2*Q + eps**-2) and np.isclose(kappa, 2*np.sqrt(Q)), (kappa, 2*np.sqrt(Q))
            Xbar = np.hstack([np.ones((M, 1)), A])
            z = np.tanh(Xbar @ W1.T) @ v
            assert np.allclose(z, np.tanh(eps*(A @ u))/eps)
        err = np.abs(z[T] - ybar[T])
        worst_err_ratio = max(worst_err_ratio, float(np.max(err)/(eps**2/3)))
        assert np.all(err <= eps**2/3 + 1e-15)
        assert np.allclose(z[~T], 0.0)
        R = float(np.sum(k[T]*(z[T]-ybar[T])**2))
        assert R <= n/(9*Q) + 1e-12
        # F_c(w_u) and near-minimizer residual bound for c = 1
        for c in [1.0, np.sqrt(M)/10]:
            Rbound = c*(2*np.sqrt(Q)+1) + n/(9*Q)
            lb = max(0.0, np.sqrt(Q)-np.sqrt(Rbound))**2/M
            print(f"M=d={M:5d} lam={lam} n={n:5d} c={c:7.3f}: Q/M={Q/M:.4f} (beta={beta_pois(lam):.4f}) "
                  f"kappa=2sqrtQ={2*np.sqrt(Q):8.2f} R(mem)={R:.2e}<=n/9Q={n/(9*Q):.2e} "
                  f"near-min R bound={Rbound:9.2f} -> excess LB {lb:.4f}")
print("max |z-ybar| / (eps^2/3) over runs:", round(worst_err_ratio, 4), "(<=1 required)")
