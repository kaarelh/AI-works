"""E(f) = min_z z^T K^{-1} z  s.t.  f(x) z(x) >= 1 for all x in {-1,1}^d   (paper's E_K with margin 1, no 1/2).
For a k-junta f the minimiser can be taken to be a k-junta (average a minimiser over sign flips of the
irrelevant coordinates: feasible, and no larger energy by convexity), so with z = sum_S c_S chi_S (S in [k]),
E = sum_S c_S^2 / khat_{|S|}, khat_j = lambda_j / 2^d the per-character kernel Fourier coefficient.
Also reports the energy split by degree of the minimiser.  Writes min_energy.json."""
import json, os, sys
import numpy as np
from scipy.optimize import minimize
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from common import cube, kernel_spectrum, popcount
import targets as T


def min_energy(tab, k, khat):
    X = cube(k).astype(float)
    masks = list(range(2 ** k))
    Phi = np.stack([np.prod(X[:, [i for i in range(k) if (m >> i) & 1]], axis=1) if m else np.ones(2 ** k)
                    for m in masks], axis=1)
    w = np.array([1.0 / khat[popcount(m)] for m in masks])
    A = tab[:, None] * Phi
    # scale variables u = sqrt(w) c  ->  minimise |u|^2  s.t. A diag(1/sqrt w) u >= 1
    B = A / np.sqrt(w)[None, :]
    u0 = np.linalg.lstsq(B, np.ones(2 ** k) * 1.5, rcond=None)[0]
    res = minimize(lambda u: u @ u, u0, jac=lambda u: 2 * u, method="SLSQP",
                   constraints=[dict(type="ineq", fun=lambda u: B @ u - 1.0, jac=lambda u: B)],
                   options=dict(maxiter=2000, ftol=1e-12))
    u = res.x
    c = u / np.sqrt(w)
    E = float(u @ u)
    by_deg = np.zeros(k + 1)
    for m, ui in zip(masks, u):
        by_deg[popcount(m)] += ui ** 2
    return E, by_deg / E, float(np.min(A @ c)), res.success


out = {}
for d in (10, 12):
    for L in (2, 3):
        lam, kh = kernel_spectrum(d, L)
        for t in T.TARGETS:
            if t == "parity_full":
                E = float(1.0 / kh[d])  # z = f is optimal by symmetry (f z >= 1 and the chi_[d] coefficient >= 1)
                out[f"{t}@d{d}L{L}"] = dict(E=E, energy_share_by_degree="all at degree d")
                continue
            k, tab = T.junta(t, d)
            E, share, marg, ok = min_energy(tab.astype(float), k, kh)
            out[f"{t}@d{d}L{L}"] = dict(E=E, energy_share_by_degree=[round(float(s), 4) for s in share],
                                        min_margin=marg, solver_ok=bool(ok))
        print(f"d={d} L={L}: " + "  ".join(f"{t}={out[f'{t}@d{d}L{L}']['E']:.0f}" for t in T.TARGETS), flush=True)
json.dump(out, open(os.path.join(HERE, "min_energy.json"), "w"), indent=1)
for key in ("leap1_td3@d12L2", "stair5@d12L2", "stair4@d12L2", "rand4@d12L2", "maj7@d12L2"):
    print(key, out[key])


# ---- duality certificate: max_{alpha>=0} 1.alpha - |B^T alpha|^2/4 is a lower bound on E (strong duality)
from scipy.optimize import minimize as _min
def dual_bound(tab, k, khat):
    X = cube(k).astype(float)
    masks = list(range(2 ** k))
    Phi = np.stack([np.prod(X[:, [i for i in range(k) if (m >> i) & 1]], axis=1) if m else np.ones(2 ** k)
                    for m in masks], axis=1)
    w = np.array([1.0 / khat[popcount(m)] for m in masks])
    B = (tab[:, None] * Phi) / np.sqrt(w)[None, :]
    G = B @ B.T
    f = lambda a: -(a.sum() - a @ G @ a / 4)
    g = lambda a: -(np.ones_like(a) - G @ a / 2)
    r = _min(f, np.full(2 ** k, 1e-3), jac=g, method="L-BFGS-B", bounds=[(0, None)] * (2 ** k),
             options=dict(maxiter=20000, ftol=1e-15, gtol=1e-12))
    return -r.fun

cert = {}
for d in (10, 12):
    for L in (2, 3):
        lam, kh = kernel_spectrum(d, L)
        for t in T.TARGETS:
            if t == "parity_full":
                continue
            k, tab = T.junta(t, d)
            lb = dual_bound(tab.astype(float), k, kh)
            E = out[f"{t}@d{d}L{L}"]["E"]
            out[f"{t}@d{d}L{L}"]["dual_lower_bound"] = lb
            cert[f"{t}@d{d}L{L}"] = (E - lb) / E
print("max relative duality gap:", max(cert.values()), max(cert, key=cert.get))
json.dump(out, open(os.path.join(HERE, "min_energy.json"), "w"), indent=1)
