"""Sign-conditioned GP (gamma<0 learner) and kernel-regression comparison.

sample_signs(): exact-HMC draws of G_X ~ N(0, K_XX) | y_i G_i > 0 (distinct inputs).
predict():      q(x) = E[ Phi(f(x) mu(x)/s(x)) | signs ],  mu(x) = k_x^T K_XX^{-1} G_X,
                s(x)^2 = K(x,x) - k_x^T K_XX^{-1} k_x  (Rao-Blackwellised over G(x) | G_X).
"""
import ctypes, os
import numpy as np
from scipy.linalg import cho_factor, cho_solve, cholesky
from scipy.special import ndtr

HERE = os.path.dirname(os.path.abspath(__file__))
_lib = ctypes.CDLL(os.path.join(HERE, "hmc_orthant.so"))
_dp = ctypes.POINTER(ctypes.c_double)
_lib.hmc_orthant.restype = ctypes.c_long
_lib.hmc_orthant.argtypes = [ctypes.c_int, _dp, _dp, ctypes.c_int, _dp, ctypes.c_double, _dp,
                             ctypes.c_int, ctypes.c_long]


def _ptr(a):
    return a.ctypes.data_as(_dp)


def hmc_chain(Sigma, z0, iters, rng, T=np.pi / 2, store_every=1, chol=None, max_b=10 ** 8):
    """Run one exact-HMC chain targeting N(0,Sigma) restricted to z>0. Returns (samples, bounces)."""
    n = Sigma.shape[0]
    C = chol if chol is not None else cholesky(Sigma, lower=True)
    Sig = np.ascontiguousarray(Sigma, dtype=float)
    z = np.ascontiguousarray(z0, dtype=float).copy()
    out = np.zeros((iters // store_every, n))
    nb_total = 0
    block = 500
    done = 0
    o = 0
    while done < iters:
        m = min(block, iters - done)
        W = np.ascontiguousarray((C @ rng.standard_normal((n, m))).T)
        tmp = np.zeros((m // store_every if store_every == 1 else m, n))
        nb = _lib.hmc_orthant(n, _ptr(Sig), _ptr(z), m, _ptr(W), T, _ptr(tmp), store_every, max_b)
        nb_total += nb
        k = m // store_every
        out[o:o + k] = tmp[:k]
        o += k
        done += m
    return out[:o], nb_total


def sample_signs(KXX, y, n_keep, burn, n_chains, rng, T=np.pi / 2):
    """Draws of G_X | signs for each chain: array (n_chains, n_keep, n)."""
    n = KXX.shape[0]
    Sigma = KXX * np.outer(y, y)  # covariance of z = y * G
    C = cholesky(Sigma, lower=True)
    chains, bounces = [], []
    for c in range(n_chains):
        # overdispersed feasible start: |prior draw| (component-wise), scaled up for odd chains
        z0 = np.abs(C @ rng.standard_normal(n)) * (1.0 if c % 2 == 0 else 2.0) + 1e-3
        s, nb = hmc_chain(Sigma, z0, burn + n_keep, rng, T=T, chol=C)
        chains.append(s[burn:] * y[None, :])  # back to G_X = y * z
        bounces.append(nb / (burn + n_keep))
    return np.stack(chains), np.array(bounces)


class Predictor:
    """Precomputes A = K_{cube,X} K_XX^{-1} and s(x) for a fixed training input set."""

    def __init__(self, Kcx, KXX, train_idx, jitter=0.0):
        self.KXX = KXX
        self.cf = cho_factor(KXX + jitter * np.eye(KXX.shape[0]), lower=True)
        self.A = cho_solve(self.cf, Kcx.T).T  # (2^d, n)
        var = 1.0 - np.einsum("ij,ij->i", self.A, Kcx)
        var[train_idx] = 0.0
        self.var_min_unseen = float(np.min(np.delete(var, train_idx))) if var.size > len(train_idx) else np.nan
        self.s = np.sqrt(np.clip(var, 0.0, None))
        self.train_idx = train_idx
        self.unseen = np.ones(Kcx.shape[0], bool)
        self.unseen[train_idx] = False

    def q_from_samples(self, G, f, chunk=500):
        """G: (S, n) samples of G_X.  Returns q(x) for all cube points (Rao-Blackwellised)."""
        M = self.A.shape[0]
        acc = np.zeros(M)
        mu_sum = np.zeros(M)
        u = self.unseen
        for i in range(0, G.shape[0], chunk):
            mu = G[i:i + chunk] @ self.A.T  # (s, M)
            mu_sum += mu.sum(0)
            z = np.zeros_like(mu)
            z[:, u] = f[None, u] * mu[:, u] / self.s[None, u]
            acc += ndtr(z).sum(0)
        q = acc / G.shape[0]
        q[~u] = 1.0
        return q, mu_sum / G.shape[0]

    def regression(self, yX, f):
        """Kernel ('ridgeless' NNGP) regression on the +-1 labels."""
        m = self.A @ yX
        z = np.zeros_like(m)
        u = self.unseen
        z[u] = f[u] * m[u] / self.s[u]
        qreg = ndtr(z)
        qreg[~u] = 1.0
        return m, qreg


def summarize_q(q, f, unseen):
    """Confidence-failure fraction F = P_x{q<=2/3}, Gibbs error E_x[1-q], majority-vote error P{q<=1/2}."""
    return dict(F=float(np.mean(q <= 2 / 3)), gibbs=float(np.mean(1 - q)), vote_err=float(np.mean(q <= 0.5)),
                F_unseen=float(np.mean(q[unseen] <= 2 / 3)), gibbs_unseen=float(np.mean(1 - q[unseen])))
