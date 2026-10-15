"""c10: GP paths under the two-layer bias-free ReLU NNGP / NTK kernels are orthogonal to odd parities of
degree >= 3 (notes-final.md, Remark 4.8(b); referee m10).  Hence a GP-classification prior (sign or
margin likelihood) gives probability 0 to the event "sign(z) = chi_S on the whole cube".

On {+-1}^d with d = 8 (256 points): build the kernel matrices, compute chi_S^T K chi_S / 256^2
(= variance of <z, chi_S> under z ~ GP(0, K), inner product averaged over the cube) for all S with
|S| = 3, 4, 5, sample 2000 GP paths (seed 10) and report max |<z, chi_S>| and the agreement of sign(z)
with chi_S.  For contrast, the same with a bias term (rho -> (rho + 1)/2) and the three-layer NNGP.
"""
import itertools
import numpy as np

rng = np.random.default_rng(10)
d = 8
X = np.array(list(itertools.product([-1, 1], repeat=d)), dtype=float)
N = len(X)
rho = np.clip(X @ X.T / d, -1, 1)


def k1(r):
    return (np.sqrt(np.clip(1 - r ** 2, 0, None)) + r * (np.pi - np.arccos(r))) / np.pi


def k0(r):
    return (np.pi - np.arccos(r)) / np.pi


kernels = {
    "NNGP 2-layer, no bias": k1(rho),
    "NTK 2-layer, no bias": k1(rho) + rho * k0(rho),
    "NNGP 2-layer, with bias": k1(np.clip((rho + 1) / 2, -1, 1)),
    "NNGP 3-layer, no bias": k1(np.clip(k1(rho), -1, 1)),
}
out = []


def P(s):
    print(s)
    out.append(s)


for name, K in kernels.items():
    lam, V = np.linalg.eigh(K)
    Z = (V * np.sqrt(np.clip(lam, 0, None))) @ rng.standard_normal((N, 2000))  # 2000 GP paths
    P(f"{name}:")
    for k in (3, 4, 5):
        var = []; mx = []; agree = []
        for S in itertools.combinations(range(d), k):
            chi = np.prod(X[:, S], axis=1)
            var.append(chi @ K @ chi / N ** 2)
            ip = chi @ Z / N
            mx.append(np.max(np.abs(ip)))
            agree.append(np.max(np.mean(np.sign(Z) == chi[:, None], axis=0)))
        P(f"  |S|={k}: max Var<z,chi_S> = {max(var):.2e}; max over S and paths of |<z,chi_S>| = {max(mx):.2e}; "
          f"best fraction of the cube where sign(z) = chi_S = {max(agree):.3f}")

with open(__file__.replace(".py", "_output.txt"), "w") as fh:
    fh.write("\n".join(out) + "\n")
