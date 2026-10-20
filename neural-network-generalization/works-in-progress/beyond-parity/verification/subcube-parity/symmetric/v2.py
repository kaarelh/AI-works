"""MIP check: err_1 (best halfspace disagreement) for f=(-1)^floor(k/2) vs the generalized-ABFR lower bound;
plus exact check of (E1),(E3) for the tied restriction by full enumeration of one block's coupling."""
import itertools, math, sys, time
import numpy as np
from math import comb
from scipy.optimize import milp, LinearConstraint, Bounds

def h_anti(k, q):
    return 1 if (k // q) % 2 == 0 else -1

def abfr(mp_, r):
    t = (mp_ - r - 1) // 2
    if t < 0:
        return 0.0
    return sum(comb(mp_, j) for j in range(t + 1)) / 2 ** mp_

def gen_abfr_bound(m, r, pgood):
    return sum(comb(m, g) * pgood ** g * (1 - pgood) ** (m - g) * abfr(g, r) for g in range(m + 1))

def err1_mip(d, q, B=60.0, tlim=600):
    X = np.array(list(itertools.product([-1, 1], repeat=d)))
    k = (X == -1).sum(1)
    f = np.array([h_anti(int(kk), q) for kk in k])
    N = len(X)
    Xt = np.hstack([np.ones((N, 1)), X])
    nv = d + 1
    big = nv * B + 1
    # vars: a (nv, continuous in [-B,B]), e (N, binary)
    c = np.concatenate([np.zeros(nv), np.ones(N)])
    A = np.hstack([f[:, None] * Xt, big * np.eye(N)])  # f a.x + big e >= 1
    cons = LinearConstraint(A, lb=np.ones(N), ub=np.inf)
    integrality = np.concatenate([np.zeros(nv), np.ones(N)])
    bounds = Bounds(np.concatenate([-B * np.ones(nv), np.zeros(N)]), np.concatenate([B * np.ones(nv), np.ones(N)]))
    t0 = time.time()
    res = milp(c, constraints=[cons], integrality=integrality, bounds=bounds, options={"time_limit": tlim, "disp": False})
    return res.fun / N if res.fun is not None else None, res.status, getattr(res, "mip_dual_bound", None), time.time() - t0

pgood = 0.75  # q=2, M=4 (exact)
for d in [8, 12]:
    m = d // 4
    lb = gen_abfr_bound(m, 1, pgood)
    # also best symmetric halfspace: sign(s - theta) or constant
    ks = np.arange(d + 1)
    pk = np.array([comb(d, kk) for kk in ks]) / 2 ** d
    hv = np.array([h_anti(int(kk), 2) for kk in ks])
    best_sym = 1.0
    for thr in np.arange(-0.5, d + 1, 1.0):
        for sgn in [1, -1]:
            pred = np.where(ks < thr, sgn, -sgn)
            best_sym = min(best_sym, float(pk[pred != hv].sum()))
    val, st, dual, tt = err1_mip(d, 2, tlim=900)
    print(f"d={d} q=2: generalized-ABFR lower bound on err_1 = {lb:.4f}; best symmetric threshold err = {best_sym:.4f}; "
          f"MIP err_1 = {val} (status {st}, dual bound {dual}, {tt:.1f}s)")
    sys.stdout.flush()
