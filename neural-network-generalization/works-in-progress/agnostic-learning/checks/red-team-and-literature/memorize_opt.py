"""Upper-bound inf F_c on the cube example by L-BFGS, depth 2 or 3.
F_c(w) - W/c = kappa_N(w) + (1/c) sum_x k_x (z(x) - ybar_x)^2 ; zero network gives G/c.
Any w found gives an upper bound on inf F_c, hence (Lemma in redteam.md) a lower bound
on the noise captured by EVERY near-minimizer.  Usage: memorize_opt.py d L N c seed
"""
import sys, numpy as np, itertools
from scipy.optimize import minimize
d, L, N, c, seed = int(sys.argv[1]), int(sys.argv[2]), int(sys.argv[3]), float(sys.argv[4]), int(sys.argv[5])
rng = np.random.default_rng(seed)
M = 2**d; n = M
X = np.array(list(itertools.product([-1.0, 1.0], repeat=d)))
Xb = np.hstack([np.ones((M, 1)), X])
idx = rng.integers(0, M, size=n); ys = rng.choice([-1.0, 1.0], size=n)
k = np.bincount(idx, minlength=M).astype(float); S = np.bincount(idx, weights=ys, minlength=M)
seen = k > 0; ybar = np.zeros(M); ybar[seen] = S[seen]/k[seen]
G = float(np.sum(k[seen]*ybar[seen]**2)); Q = float(np.sum(ybar**2)); V = float(np.sum(S**2)); s = int(seen.sum())
shapes = [(N, d+1)] + [(N, N)]*(L-2) + [(N,)]
sizes = [int(np.prod(sh)) for sh in shapes]
def unpack(p):
    out, o = [], 0
    for sh, sz in zip(shapes, sizes):
        out.append(p[o:o+sz].reshape(sh)); o += sz
    return out
def fg(p):
    Ws = unpack(p); W1, mids, v = Ws[0], Ws[1:-1], Ws[-1]
    hs = [Xb]; pre = Xb @ W1.T; h = np.tanh(pre); hs.append(h)
    for Wl in mids:
        h = np.tanh(h @ Wl.T); hs.append(h)
    z = h @ v
    r = z - ybar
    kap = (d/N)*np.sum(W1**2) + sum(np.sum(Wl**2) for Wl in mids) + N*np.sum(v**2)
    F = kap + np.sum(k*r**2)/c
    dz = 2*k*r/c
    gv = h.T @ dz + 2*N*v
    delta = np.outer(dz, v)*(1-h**2)
    gmids = []
    for li in range(len(mids)-1, -1, -1):
        Wl = mids[li]; hprev = hs[li+1]
        gmids.insert(0, delta.T @ hprev + 2*Wl)
        delta = (delta @ Wl)*(1-hprev**2)
    gW1 = delta.T @ Xb + 2*(d/N)*W1
    g = np.concatenate([gW1.ravel()] + [gm.ravel() for gm in gmids] + [gv.ravel()])
    return F, g, z, kap
best = None
for rs in range(3):
    p0 = []
    p0.append(rng.normal(0, 1/np.sqrt(d+1), size=(N, d+1)).ravel()*1.0)
    for _ in range(L-2): p0.append(rng.normal(0, 1/np.sqrt(N), size=(N, N)).ravel())
    p0.append(rng.normal(0, 1/N, size=N))
    p0 = np.concatenate(p0)
    res = minimize(lambda p: fg(p)[:2], p0, jac=True, method='L-BFGS-B', options={'maxiter': 20000, 'maxfun': 40000})
    F, g, z, kap = fg(res.x)
    if best is None or F < best[0]: best = (F, z, kap)
F, z, kap = best
Rres = float(np.sum(k*(z-ybar)**2))
theta = 1 - c*F/G   # c*(F - W/c) = c*kappa + R ; compare with zero network value G
excess = float(np.mean(z**2)); excess_seen = float(np.sum(z[seen]**2))/M
lb = max(theta*G, 0)**2/(4*M*V)
print(f"d={d} L={L} N={N} c={c} seed={seed} | s={s} G={G:.1f} Q/M={Q/M:.4f} | F-W/c={F:.2f} kappa={kap:.2f} R={Rres:.2f} | capture theta={theta:.3f} | excess(found w)={excess:.4f} (seen part {excess_seen:.4f}) | rigorous near-min excess LB={lb:.4f}")
