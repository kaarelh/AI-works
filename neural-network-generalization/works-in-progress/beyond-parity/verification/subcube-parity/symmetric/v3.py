import itertools, math
import numpy as np
from math import comb
rng = np.random.default_rng(1)

print("== S2: c_k = chi(w) gamma'_d and E_w[chi(w)ReLU(w.x)] = chi(x) gamma'_d (d=10, exact) ==")
d = 10
X = np.array(list(itertools.product([-1, 1], repeat=d)))
chi = X.prod(1)
gp = sum(comb(d, k) * (-1) ** k * max(d - 2 * k, 0) for k in range(d + 1)) / 2 ** d
for _ in range(3):
    w = rng.choice([-1, 1], d)
    ck = (chi * np.maximum(0, X @ w)).mean()
    print(" c_k=", ck, " chi(w)*gamma'=", w.prod() * gp)
Ew = (chi[:, None] * np.maximum(0, X @ X.T)).mean(0)  # E_w over rows w=X
print(" max |E_w chi(w)ReLU(w.x) - chi(x)gamma'| =", np.abs(Ew - chi * gp).max())
# population one-step readout with m features: sign check
for m in [200, 2000, 20000]:
    W = rng.choice([-1, 1], (m, d))
    Phi = np.maximum(0, X @ W.T)  # N x m
    c = W.prod(1) * gp
    Fpop = Phi @ c / m
    print(f" m={m}: population one-step F_pop sign errors over cube = {(np.sign(Fpop) != chi).mean():.4f}; "
          f"max |F_pop - gamma^2 chi|/gamma^2 = {np.abs(Fpop - gp**2*chi).max()/gp**2:.3f}")

print("\n== S1: triangle units on grid, one GD step; test err == unseen mass ==")
def S1(d, n, h):
    s_vals = np.arange(-d, d + 1, 2)
    p = np.array([comb(d, (d - v) // 2) for v in s_vals], float) / 2 ** d
    S = d - 2 * rng.binomial(d, 0.5, n)
    idx = (S + d) // 2
    phat = np.bincount(idx, minlength=d + 1) / n
    a = np.zeros(d + 1)
    eta = 1 / phat.max()
    hv = np.array([h(v) for v in s_vals])
    # explicit GD on triangle-unit network: features sigma(s - v) = 1[s=v]
    feats = lambda s: np.maximum(0, 1 - np.abs(s[:, None] - s_vals[None, :]) / 2)
    Phi = feats(S)
    y = hv[idx]
    grad = Phi.T @ (Phi @ a - y) / n
    a = a - eta * grad
    pred = np.sign(a)  # F(x)=a_{s(x)}
    err = float((p * (pred != hv)).sum())
    unseen = float(p[phat == 0].sum())
    return err, unseen
par = lambda v: 1  # placeholder
for d in [41, 101]:
    for name, h in [("parity", lambda v, d=d: (-1) ** ((d - v) // 2)),
                    ("q2", lambda v, d=d: (-1) ** (((d - v) // 2) // 2)),
                    ("maj", lambda v: 1 if v > 0 else -1)]:
        e, u = S1(d, 4 * d, h)
        print(f" d={d} {name}: one-step test err {e:.4f}, unseen mass {u:.4f}")
