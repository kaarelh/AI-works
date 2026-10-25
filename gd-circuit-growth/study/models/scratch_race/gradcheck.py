import sys; sys.path.insert(0, '.')
import numpy as np
from models.race import _order_k_grad, _esym
rng = np.random.default_rng(0)
n, D, P = 200, 7, 3
U = rng.choice([-1.0, 1.0], size=(n, D)); r = rng.standard_normal(n)
V = rng.standard_normal((D, P))
h = U.T @ r / n
import itertools
for k in range(1, 5):
    Uk, G = _order_k_grad(U, r, V, k, h)
    # brute force e_k
    def ek(V):
        out = np.zeros(V.shape[1])
        for T in itertools.combinations(range(D), k):
            out += (r[:, None] * np.prod(U[:, T][:, :, None] * V[T, :][None], axis=1)).mean(0)
        return out
    print(k, np.allclose(Uk, ek(V)), end=' ')
    eps = 1e-6; Gn = np.zeros_like(V)
    for i in range(D):
        Vp = V.copy(); Vp[i] += eps; Vm = V.copy(); Vm[i] -= eps
        Gn[i] = (ek(Vp) - ek(Vm)) / (2 * eps)
    print(np.abs(G - Gn).max())
