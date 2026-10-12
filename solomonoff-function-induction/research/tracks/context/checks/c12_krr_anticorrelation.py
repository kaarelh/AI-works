"""c12: kernel predictors are anti-correlated with odd parities on unseen points (notes-final.md, Remark 4.8(c);
referee m11).

Bias-free two-layer ReLU NNGP kernel kappa_1(rho) and NTK kappa_1(rho) + rho kappa_0(rho), rho = <x,x'>/d, on the
cube {-1,1}^d with d = 10.  For |S| odd and >= 3 the eigenvalue of chi_S is 0 (Remark 4.8(a)), so every function
in V = span{k(x_i, .)} is orthogonal to chi_S on the whole cube.  Remark 4.8(c) [proved]:
  * identity:   sum_{unseen} g chi_S = - sum_{train} g chi_S   for every g in V;
  * KRR / GP posterior mean with ridge lam > 0: sum_{train} g chi_S = y^T K (K + lam I)^{-1} y >= 0, so the
    unseen sum is <= 0.
This script checks the identity and the sign of the training sum to machine precision, and reports the mean
product (1/#unseen) sum_unseen g chi_S and the sign accuracy on unseen points (a computed quantity, not a theorem),
for |S| in {3, 5} (odd, eigenvalue 0) and, as controls, |S| = 4 (even) and the three-layer NNGP (|S| = 3).
Targets: 10 random S per cell; training inputs: n distinct uniform points; ridge lam = 1e-3 * mean diag(K_n).
Seeded (SEED = 12).
"""
import math
import numpy as np

SEED = 12
rng = np.random.default_rng(SEED)
d = 10
NP = 2 ** d
X = np.array([[1 - 2 * ((i >> j) & 1) for j in range(d)] for i in range(NP)], dtype=float)
G = X @ X.T / d


def k1(r):
    r = np.clip(r, -1.0, 1.0)
    return (np.sqrt(1 - r ** 2) + (math.pi - np.arccos(r)) * r) / math.pi


def k0(r):
    r = np.clip(r, -1.0, 1.0)
    return (math.pi - np.arccos(r)) / math.pi


kernels = {
    "NNGP-2layer": k1(G),
    "NTK-2layer": k1(G) + G * k0(G),
    "NNGP-3layer (control)": k1(k1(G)),
}

out = []


def P(s):
    print(s)
    out.append(s)


P(f"d = {d}; 10 random targets chi_S per cell; ridge 1e-3 * mean diag")
P("kernel                 |S|    n   max|identity residual|  min train sum   mean unseen product   unseen sign acc. (mean, min..max)")
for name, K in kernels.items():
    for k in (3, 5, 4):
        if name.startswith("NNGP-3") and k != 3:
            continue
        for n in (100, 300, 640, 900):
            res_max, train_min, prods, accs = 0.0, np.inf, [], []
            for _ in range(10):
                S = rng.choice(d, size=k, replace=False)
                chi = np.prod(X[:, S], axis=1)
                tr = rng.choice(NP, size=n, replace=False)
                un = np.setdiff1d(np.arange(NP), tr)
                Kn = K[np.ix_(tr, tr)]
                lam = 1e-3 * np.mean(np.diag(Kn))
                alpha = np.linalg.solve(Kn + lam * np.eye(n), chi[tr])
                g = K[:, tr] @ alpha
                s_tr = float(g[tr] @ chi[tr])
                s_un = float(g[un] @ chi[un])
                scale = max(1.0, abs(s_tr))
                res_max = max(res_max, abs(s_tr + s_un) / scale)
                train_min = min(train_min, s_tr)
                prods.append(s_un / len(un))
                accs.append(float(np.mean(np.sign(g[un]) == chi[un])))
            P(f"{name:22s} {k:3d} {n:4d}   {res_max:20.2e}  {train_min:13.3f}   {np.mean(prods):19.3f}   "
              f"{np.mean(accs):.3f} ({min(accs):.3f}..{max(accs):.3f})")

P("Reading: for odd |S| >= 3 under the two bias-free two-layer kernels the identity holds to rounding error and the")
P("training sum is >= 0, so the unseen mean product is <= 0 (anti-correlation), as Remark 4.8(c) proves.  The sign")
P("accuracies are computed, not proved.  Controls (|S| = 4; three-layer NNGP) have nonzero eigenvalue and no identity.")

with open(__file__.replace(".py", "_output.txt"), "w") as fh:
    fh.write("\n".join(out) + "\n")
