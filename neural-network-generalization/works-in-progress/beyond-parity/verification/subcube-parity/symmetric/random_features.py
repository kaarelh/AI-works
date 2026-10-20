"""Second-layer gradient descent on two-layer ReLU networks with frozen first layers.

S1: all-ones first layer (each hidden unit sees s = sum x_i), biases on the grid.
    Plain GD on squared loss from zero; checks every symmetric target.
S2: iid Rademacher first layer vs iid Gaussian first layer (random features),
    second layer trained by GD on squared loss with small ridge (we use the closed form,
    which is the limit of GD with weight decay). Target: full parity and q=2 symmetric bent.
"""
import numpy as np, math, time
rng = np.random.default_rng(1)

def h_anti(k, q):
    return np.where((k // q) % 2 == 0, 1.0, -1.0)

def target(X, name):
    k = (X == -1).sum(1)
    if name == "parity": return h_anti(k, 1)
    if name == "anti_q2": return h_anti(k, 2)
    if name == "anti_q3": return h_anti(k, 3)
    if name == "majority": return np.where(X.sum(1) > 0, 1.0, -1.0)
    raise ValueError

# ---------------- S1 ----------------
print("== S1: all-ones first layer, ReLU(s - t) with t on the grid, plain GD on 2nd layer ==")
def s1(d, n, ntest, name, steps):
    X = rng.choice([-1, 1], size=(n, d)); Xt = rng.choice([-1, 1], size=(ntest, d))
    y = target(X, name); yt = target(Xt, name)
    grid = np.arange(-d, d + 1, 2)            # values of s
    t = grid - 2                               # hinge just below each grid value
    phi = lambda Z: np.maximum(Z.sum(1)[:, None] - t[None, :], 0.0)
    F, Ft = phi(X), phi(Xt)
    a = np.zeros(F.shape[1])
    # step size 1/lambda_max of the empirical Gram
    lam = np.linalg.eigvalsh(F.T @ F / n).max()
    for it in range(steps):
        a -= (1.0 / lam) * F.T @ (F @ a - y) / n
    tr = np.mean(np.sign(F @ a) != y); te = np.mean(np.sign(Ft @ a) != yt)
    seen = set(X.sum(1)); unseen = np.mean([s not in seen for s in Xt.sum(1)])
    return tr, te, unseen
for d in [41, 101]:
    for name in ["parity", "anti_q2", "anti_q3"]:
        t0 = time.time()
        tr, te, un = s1(d, 4 * d, 4000, name, steps=20000)
        print(f"d={d} n={4*d} {name:8s}: train err {tr:.3f}  test err {te:.3f}  (test mass on unseen s-values {un:.3f})  [{time.time()-t0:.1f}s]")

# ---------------- S2 ----------------
print("\n== S2: random-feature first layer (frozen), ridge least squares on 2nd layer ==")
def s2(d, m, n, ntest, init, name, ridge=1e-3):
    X = rng.choice([-1, 1], size=(n, d)).astype(np.float32)
    Xt = rng.choice([-1, 1], size=(ntest, d)).astype(np.float32)
    y = target(X, name); yt = target(Xt, name)
    if init == "rademacher":
        W = rng.choice([-1, 1], size=(d, m)).astype(np.float32)
    else:
        W = rng.standard_normal((d, m)).astype(np.float32)
    b = rng.choice([-2.0, 0.0, 2.0], size=m).astype(np.float32)
    F = np.maximum(X @ W + b, 0); Ft = np.maximum(Xt @ W + b, 0)
    F -= F.mean(0); Ft -= F.mean(0) * 0  # keep simple: center training features only for conditioning
    G = F.T @ F / n + ridge * np.eye(m, dtype=np.float32)
    a = np.linalg.solve(G, F.T @ y / n)
    Ft = np.maximum(Xt @ W + b, 0) - np.maximum(X @ W + b, 0).mean(0)
    return np.mean(np.sign(F @ a) != y), np.mean(np.sign(Ft @ a) != yt)
d = 16
for init in ["rademacher", "gaussian"]:
    for name in ["parity", "anti_q2", "majority"]:
        t0 = time.time()
        tr, te = s2(d, m=3000, n=6000, ntest=4000, init=init, name=name)
        print(f"d={d} {init:10s} {name:8s}: train err {tr:.3f} test err {te:.3f} [{time.time()-t0:.1f}s]")
