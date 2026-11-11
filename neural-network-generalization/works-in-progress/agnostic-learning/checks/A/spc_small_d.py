"""Small-d illustration of Theorem 4.1 (A.md): L-BFGS on F_c(w) = kappa_N(w) + (1/c) sum_i (z_w(x_i) - y_i)^2
for the cube example (x uniform on {-1,1}^d with replacement, fair +-1 labels, n = 2^d).

Reported: s (#seen atoms), Q/M, kappa and Delta = sum_x k_x (z(x)-ybar_x)^2 of the best point found, and its test
excess (1/M) sum_x z(x)^2 (exact, since L_D(f) = 1 + (1/M) sum_x f(x)^2).
Rigorous by-product (Lemma 4.2 with the found network as comparator): every w' with F_c(w') <= inf F_c + t has
   Delta(w') <= c (kappa_found + t) + Delta_found,  hence excess(w') >= (1/M)(sqrt(Q) - sqrt(that))_+^2.
(Floating-point evaluation of the found network; this is a numerical certificate, not a formal proof.)
Usage: python3 spc_small_d.py d H N c seed restarts
"""
import sys, itertools, math
import numpy as np
from scipy.optimize import minimize

d, H, N, c, seed, restarts = int(sys.argv[1]), int(sys.argv[2]), int(sys.argv[3]), float(sys.argv[4]), int(sys.argv[5]), int(sys.argv[6])
rng = np.random.default_rng(seed)
M = 2 ** d; n = M
X = np.array(list(itertools.product([-1.0, 1.0], repeat=d)))
Xb = np.hstack([np.ones((M, 1)), X])
idx = rng.integers(0, M, size=n); ys = rng.choice([-1.0, 1.0], size=n)
k = np.bincount(idx, minlength=M).astype(float); S = np.bincount(idx, weights=ys, minlength=M)
seen = k > 0; ybar = np.zeros(M); ybar[seen] = S[seen] / k[seen]
Q = float(np.sum(ybar ** 2)); s = int(seen.sum())
shapes = [(N, d + 1)] + [(N, N)] * (H - 1) + [(N,)]
sizes = [int(np.prod(sh)) for sh in shapes]

def unpack(p):
    out, o = [], 0
    for sh, sz in zip(shapes, sizes):
        out.append(p[o:o + sz].reshape(sh)); o += sz
    return out

def fg(p):
    Ws = unpack(p); W1, mids, v = Ws[0], Ws[1:-1], Ws[-1]
    hs = [Xb]; h = np.tanh(Xb @ W1.T); hs.append(h)
    for Wl in mids:
        h = np.tanh(h @ Wl.T); hs.append(h)
    z = h @ v; r = z - ybar
    kap = (d / N) * np.sum(W1 ** 2) + sum(np.sum(Wl ** 2) for Wl in mids) + N * np.sum(v ** 2)
    F = kap + np.sum(k * r ** 2) / c          # F_c minus the constant W/c
    dz = 2 * k * r / c
    gv = hs[-1].T @ dz + 2 * N * v
    delta = np.outer(dz, v) * (1 - hs[-1] ** 2)
    gm = []
    for li in range(len(mids) - 1, -1, -1):
        hprev = hs[li + 1]
        gm.insert(0, delta.T @ hprev + 2 * mids[li])
        delta = (delta @ mids[li]) * (1 - hprev ** 2)
    gW1 = delta.T @ Xb + 2 * (d / N) * W1
    return F, np.concatenate([gW1.ravel()] + [x.ravel() for x in gm] + [gv]), z, kap

best = None
for _ in range(restarts):
    p0 = np.concatenate([rng.normal(0, 1.0, size=(N, d + 1)).ravel()] +
                        [rng.normal(0, 1 / math.sqrt(N), size=(N, N)).ravel() for _ in range(H - 1)] +
                        [rng.normal(0, 1 / N, size=N)])
    res = minimize(lambda p: fg(p)[:2], p0, jac=True, method="L-BFGS-B", options={"maxiter": 30000, "maxfun": 60000})
    F, _, z, kap = fg(res.x)
    if best is None or F < best[0]:
        best = (F, z, kap)
F, z, kap = best
Delta = float(np.sum(k * (z - ybar) ** 2)); G = float(np.sum(k * ybar ** 2))
t = 1.0
budget = c * (kap + t) + Delta
lb = max(0.0, math.sqrt(Q) - math.sqrt(budget)) ** 2 / M
print(f"d={d} H={H} N={N} c={c:g} seed={seed}: s={s} Q/M={Q/M:.4f} | found: kappa={kap:.1f} Delta={Delta:.2f} "
      f"(zero net: F={G/c:.1f}, found F={F:.1f}) | test excess of found net = {np.mean(z**2):.4f} "
      f"[seen {np.sum(z[seen]**2)/M:.4f}, unseen {np.sum(z[~seen]**2)/M:.4f}] | certified LB for all near-minimizers = {lb:.4f}")
