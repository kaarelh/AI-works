"""Simulation of the greedy layerwise learner of ../../subcube-parity.md, Section 3
(layerwise greedy product-unit trunk on x, two heads {1, z}):
Stage 1: n1 = ceil(256 (d-1) ln(4 d (1+128(d-1))/delta)) samples; Phi={0}; add U^{i} if max_h |E_hat[f h chi_U x_i]| > tau = m1/4.
Stage 2: perceptron on features (chi_U, z chi_U)_{U in Phi} with n2 fresh samples (SGD on max(0,-y<w,phi>), step 1).
Targets: fstar, ctrl, f1 (sign staircase alone, heads {1} only).
Usage: python3 -I greedy_learner.py [d ...]   (default: 31 63; d=127 takes well over an hour)."""
import numpy as np, math, sys, time
rng = np.random.default_rng(0)
delta = 0.1
def sample(n, d): return rng.choice(np.array([-1, 1], dtype=np.int8), size=(n, d + 1))
def target(name, X, d):
    x = X[:, :d].astype(np.int32); z = X[:, d]
    Y = np.cumprod(x, axis=1)
    if name == "fstar": return np.where(z > 0, np.sign(Y.sum(1)), Y[:, -1]).astype(np.float32)
    if name == "ctrl": return np.where(z > 0, x[:, 0], Y[:, -1]).astype(np.float32)
    if name == "f1": return np.sign(Y.sum(1)).astype(np.float32)
def chi(X, U):
    return np.prod(X[:, sorted(U)].astype(np.int32), axis=1).astype(np.float32) if U else np.ones(len(X), np.float32)
for d in ([int(v) for v in sys.argv[1:]] or [31, 63]):
    m1 = math.comb(d - 1, (d - 1) // 2) / 2 ** (d - 1); tau = m1 / 4
    n1 = math.ceil(256 * (d - 1) * math.log(4 * d * (1 + 128 * (d - 1)) / delta))
    for name in ["fstar", "ctrl", "f1"]:
        t0 = time.time()
        X1 = sample(n1, d); y1 = target(name, X1, d); xf = X1[:, :d].astype(np.float32); z1 = X1[:, d].astype(np.float32)
        heads = [np.ones(n1, np.float32), z1] if name != "f1" else [np.ones(n1, np.float32)]
        Phi = [frozenset()]; seen = {frozenset()}; changed = True
        while changed:
            changed = False
            for U in list(Phi):
                base = chi(X1, U) * y1
                est = np.max(np.stack([np.abs((base * h) @ xf) / n1 for h in heads]), axis=0)
                for i in np.flatnonzero(est > tau):
                    V = U ^ {int(i)}
                    if V not in seen: seen.add(V); Phi.append(V); changed = True
        prefixes = sum(1 for U in Phi if U and U == frozenset(range(len(U))))
        # stage 2: perceptron
        n2 = 10 * (d + 1) ** 2
        X2 = sample(n2, d); y2 = target(name, X2, d)
        def feats(X):
            C = np.stack([chi(X, U) for U in Phi], axis=1)
            return np.concatenate([C, C * X[:, d:d + 1].astype(np.float32)], axis=1) if name != "f1" else C
        F2 = feats(X2); w = np.zeros(F2.shape[1], np.float32); mistakes = 0
        for j in range(n2):
            if y2[j] * (F2[j] @ w) <= 0: w += y2[j] * F2[j]; mistakes += 1
        Xt = sample(20000, d); yt = target(name, Xt, d); pt = np.sign(feats(Xt) @ w); h = Xt[:, d] < 0
        print(f"d={d} {name}: n1={n1}, |Phi|={len(Phi)} (prefix sets {prefixes}, other {len(Phi)-1-prefixes}); perceptron n2={n2}, mistakes={mistakes} "
              f"(bound (d+1)^2={(d+1)**2}); final test err {np.mean(pt != yt):.4f} (z=-1 half {np.mean(pt[h] != yt[h]):.4f}); {time.time()-t0:.0f}s", flush=True)
