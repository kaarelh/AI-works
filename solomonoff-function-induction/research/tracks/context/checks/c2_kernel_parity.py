"""c2: NNGP/NTK kernels on the Boolean cube vs a simplicity-prior mixture on sparse parities
(notes.md, section 4.4, Theorem 4.6 and Corollary 4.7).

Part A (diagonalization, Thm 4.6(a)): for kernels of the form k(x,x') = kappa(<x,x'>/d) on {-1,1}^d,
  every Walsh character chi_S is an eigenfunction of (T g)(x) = E_{x'} k(x,x') g(x'), with eigenvalue
  depending only on |S|.  Checked for: 2-layer ReLU NNGP (arc-cosine kernel of order 1), 2-layer ReLU NTK,
  3-layer ReLU NNGP, and a Gaussian (RBF) kernel.
Part B (lower bound, Thm 4.6(b)): kernel ridge regression / GP posterior mean (both lie in span{k(x_i,.)})
  on a uniformly random k-sparse parity: mean squared error over the cube, averaged over targets,
  is >= 1 - n / C(d,k).  We print the empirical error next to the bound.
Part C (SFI side, Cor 4.7): Bayes mixture over all 2^d parities with prefix-code prior
  w(S) = 2^{-l(S)}, l(S) = 1 + 2 log2(|S|+1) + log2 C(d,|S|): squared error and cumulative Gibbs mistakes
  (sum of posterior error probabilities along the training sequence) vs the proved bound ln2 * l(S).
Seeded.
"""
import math
import itertools
import numpy as np

SEED = 1
rng = np.random.default_rng(SEED)
d = 10
NP = 2 ** d
X = np.array([[1 - 2 * ((i >> j) & 1) for j in range(d)] for i in range(NP)], dtype=float)  # +-1 cube
G = X @ X.T / d  # rho

def k1(r):
    r = np.clip(r, -1.0, 1.0)
    return (np.sqrt(1 - r ** 2) + (math.pi - np.arccos(r)) * r) / math.pi

def k0(r):
    r = np.clip(r, -1.0, 1.0)
    return (math.pi - np.arccos(r)) / math.pi

kernels = {
    "NNGP-2layer-ReLU": k1(G),
    "NTK-2layer-ReLU": k1(G) + G * k0(G),
    "NNGP-3layer-ReLU": k1(k1(G)),
    "RBF": np.exp(-(d - X @ X.T) / d),  # = exp(-||x-x'||^2 / (2d))
}

# Walsh characters: chi_S(x) = prod_{j in S} x_j, S encoded as bitmask
masks = np.arange(NP)
sizes = np.array([bin(m).count("1") for m in masks])
H = np.ones((NP, NP))
for m in masks:
    for j in range(d):
        if (m >> j) & 1:
            H[:, m] *= X[:, j]

out = []
out.append(f"d = {d}, cube size {NP}")
out.append("Part A: Walsh characters as eigenfunctions of T = K / 2^d")
for name, K in kernels.items():
    T = K / NP
    TH = T @ H
    lam = (H * TH).sum(axis=0) / NP  # <chi_S, T chi_S> / <chi_S, chi_S>, both under uniform measure
    resid = np.abs(TH - H * lam).max()
    spread = max(np.ptp(lam[sizes == j]) for j in range(d + 1))
    lam_by_deg = [lam[sizes == j][0] for j in range(d + 1)]
    out.append(f"  {name:18s}: max residual {resid:.2e}; max spread of eigenvalue within a degree {spread:.2e}")
    out.append("     eigenvalue by degree 0..d: " + " ".join(f"{v:.3e}" for v in lam_by_deg))

# Part B and C
def krr_predict(K, tr, y, ridge=1e-8):
    Ktr = K[np.ix_(tr, tr)]
    alpha = np.linalg.solve(Ktr + ridge * np.trace(Ktr) / len(tr) * np.eye(len(tr)), y)
    return K[:, tr] @ alpha

def code_len(m):
    s = bin(m).count("1")
    return 1 + 2 * math.log2(s + 1) + math.log2(math.comb(d, s))

logw = -np.array([code_len(m) for m in masks]) * math.log(2)

def parity_bayes(tr, y):
    # posterior over all masks consistent with labels y on training inputs tr (deterministic likelihood)
    cons = np.all(H[tr, :] == y[:, None], axis=0)
    lw = np.where(cons, logw, -np.inf)
    lw -= lw.max()
    post = np.exp(lw); post /= post.sum()
    return H @ post, post

def gibbs_cumulative(order, ytrue):
    # sum over steps of posterior probability of the wrong label (normalized; parities are total)
    tot = 0.0
    lw = logw.copy()
    for t, i in enumerate(order):
        p = np.exp(lw - lw.max()); p /= p.sum()
        p_right = p[H[i, :] == ytrue[i]].sum()
        tot += 1 - p_right
        lw = np.where(H[i, :] == ytrue[i], lw, -np.inf)
    return tot

out.append("")
out.append("Part B/C: mean squared error over the whole cube (avg over targets and training sets)")
NREP = 20
for k in [2, 3, 5]:
    Ck = math.comb(d, k)
    out.append(f" k = {k}, C(d,k) = {Ck}; SFI-proxy code length l(S) = {code_len((1 << k) - 1):.2f} bits")
    for n in [10, 20, 40, 80, 160, 320, 640]:
        errs = {name: [] for name in kernels}
        errs_pb = []
        gibbs = []
        for rep in range(NREP):
            S = rng.choice(d, size=k, replace=False)
            m = int(sum(1 << int(j) for j in S))
            y_all = H[:, m]
            tr = rng.choice(NP, size=n, replace=False)
            for name, K in kernels.items():
                g = krr_predict(K, tr, y_all[tr])
                errs[name].append(np.mean((y_all - g) ** 2))
            gpb, post = parity_bayes(tr, y_all[tr])
            errs_pb.append(np.mean((y_all - gpb) ** 2))
            gibbs.append(gibbs_cumulative(tr, y_all))
        bound = max(0.0, 1 - n / Ck)
        line = f"  n={n:4d}: bound>= {bound:.3f} | " + " ".join(
            f"{name.split('-')[0]}{'-' + name.split('-')[1] if '-' in name else ''}={np.mean(v):.3f}" for name, v in errs.items())
        line += f" | parity-Bayes={np.mean(errs_pb):.3f}; cumulative Gibbs mistakes mean={np.mean(gibbs):.2f}, max={np.max(gibbs):.2f}"
        line += f" (bound ln2*l(S) = {math.log(2) * code_len((1 << k) - 1):.2f})"
        out.append(line)
        # the bound in Thm 4.6(b) concerns any fixed training set, averaged over S; check per kernel
        for name, v in errs.items():
            assert np.mean(v) >= bound - 0.05, (name, n, k, np.mean(v), bound)

txt = "\n".join(out)
print(txt)
with open(__file__.replace(".py", "_output.txt"), "w") as fh:
    fh.write(txt + "\n")
