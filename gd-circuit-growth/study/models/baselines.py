"""Reference learners for the behavioural comparison.

NNGPKernel  -- kernel regression with the infinite-width NNGP kernel of the networks' architecture at init
               (two ReLU hidden layers, W1 ~ N(0,1/d), W2 ~ N(0,1/N), zero biases): the lazy/kernel analogue,
               and the gamma<1 analogue in the NNBayes project.
OccamJunta  -- smallest k <= kmax such that some k-subset of coordinates is consistent with the training data,
               predicting by its truth table (unseen cells -> majority label); if none is consistent, the k = kmax
               subset with the fewest training mistakes.  An Occam learner over juntas (statistically efficient,
               computationally brute force).
"""
import itertools, numpy as np
from scipy.linalg import cho_factor, cho_solve


def _relu_cov(rho, var):
    """E[relu(u) relu(v)] for (u, v) centred Gaussian, Var = var, correlation rho."""
    rho = np.clip(rho, -1.0, 1.0)
    return var / (2 * np.pi) * (np.sqrt(1 - rho ** 2) + (np.pi - np.arccos(rho)) * rho)


def nngp_table(d):
    rho0 = np.linspace(-1, 1, d + 1)          # x.x'/d for Hamming distance (d - k) ... 0
    k1 = _relu_cov(rho0, 1.0)                 # layer-2 preactivation covariance
    k2 = _relu_cov(k1 / k1[-1], k1[-1])       # covariance of h2
    return k2


class NNGPKernel:
    name = "nngp-kernel"

    def __init__(self, ridge=1e-4, max_n=8192):
        self.ridge, self.max_n = ridge, max_n

    def fit(self, X, y, rng):
        n, d = X.shape
        table = nngp_table(d)
        if n > self.max_n:
            return dict(predict=lambda Z: np.full(len(Z), np.nan), time=np.nan, size=n)
        def gram(A, B):
            dots = (A @ B.T).astype(np.int64)            # in [-d, d]
            return table[(dots + d) // 2].astype(np.float64)
        K = gram(X, X)
        lam = self.ridge * np.trace(K) / n
        c = cho_solve(cho_factor(K + lam * np.eye(n)), y.astype(np.float64))
        return dict(predict=lambda Z: np.sign(gram(Z, X) @ c + 1e-12), time=0.0, size=n)


class OccamJunta:
    name = "occam-junta"

    def __init__(self, kmax=4):
        self.kmax = kmax

    def fit(self, X, y, rng):
        n, d = X.shape
        B = (X > 0).astype(np.int64)
        yb = (y > 0).astype(np.int64)
        maj = 1.0 if y.mean() >= 0 else -1.0
        best = None
        for k in range(0, self.kmax + 1):
            subsets = np.array(list(itertools.combinations(range(d), k)), dtype=np.int64).reshape(-1, k) if k else np.zeros((1, 0), dtype=np.int64)
            w = 2 ** np.arange(k)
            ncell = 2 ** k
            for chunk in np.array_split(subsets, max(1, len(subsets) * n // 4_000_000 + 1)):
                S_ = len(chunk)
                cells = (B[:, chunk] * w).sum(-1).T if k else np.zeros((S_, n), dtype=np.int64)  # (S_, n)
                flat = (np.arange(S_)[:, None] * ncell + cells).ravel()
                tot = np.bincount(flat, minlength=S_ * ncell).reshape(S_, ncell)
                pos = np.bincount(flat, weights=np.tile(yb, S_), minlength=S_ * ncell).reshape(S_, ncell)
                mistakes = np.minimum(pos, tot - pos).sum(1)
                j = int(np.argmin(mistakes))
                if best is None or mistakes[j] < best[0]:
                    table = np.where(tot[j] > 0, np.where(2 * pos[j] >= tot[j], 1.0, -1.0), maj)
                    best = (mistakes[j], chunk[j], table, k)
            if best[0] == 0:
                break
        _, S, table, k = best
        w = 2 ** np.arange(k)
        def predict(Z):
            if k == 0:
                return np.full(len(Z), table[0])
            return table[((Z[:, S] > 0).astype(np.int64) * w).sum(-1)]
        return dict(predict=predict, time=float(k), size=int(k))
