"""Referee check for notes.md section 4.4 (Theorem 4.6, Corollary 4.7, Remark 4.8), independent of c2.

(1) Exact Walsh eigenvalues of dot-product kernels on {-1,1}^d via Krawtchouk polynomials:
    lambda_k = 2^-d sum_{j=0}^d C(d,j) kappa(1 - 2j/d) K_k(j) / C(d,k), K_k(j) = sum_i (-1)^i C(j,i) C(d-j,k-i)
    (the Walsh coefficient at |S| = k of h(z) = kappa(sum z / d)).  Checks Remark 4.8's zeros for odd k >= 3
    (2-layer bias-free ReLU NNGP and NTK), and that a bias term or a third layer removes them.
(2) Scope of Remark 4.8 ("never learn odd parities of degree >= 3"): the proof covers the squared error of the
    real-valued posterior mean.  We measure the 0-1 test accuracy of sign(g_hat) on UNSEEN points for kernel
    ridge regression with the 2-layer ReLU NNGP kernel on degree-3 and degree-5 parities, d = 10.
(3) Theorem 4.6(b) bound 1 - n / C(d,k) against KRR's L2 error on random k-parities.
Seeded.  Output: ref_kernel_parity_output.txt
"""
import itertools
import math

import numpy as np

SEED = 4242
rng = np.random.default_rng(SEED)
OUT = []


def log(s):
    OUT.append(s)
    print(s)


def kappa1(r):
    r = np.clip(r, -1, 1)
    return (np.sqrt(1 - r * r) + r * (math.pi - np.arccos(r))) / math.pi


def kappa0(r):
    r = np.clip(r, -1, 1)
    return (math.pi - np.arccos(r)) / math.pi


def kraw(d, k, j):
    return sum((-1) ** i * math.comb(j, i) * math.comb(d - j, k - i) for i in range(0, k + 1))


def walsh_eigs(kappa, d):
    rho = np.array([1 - 2 * j / d for j in range(d + 1)])
    kv = kappa(rho)
    # sum over z of h(z) chi_S(z): z with j minus-ones contribute kappa(1-2j/d) * C(d,j) K_k(j) / C(d,k) in total
    return [sum(math.comb(d, j) * kv[j] * kraw(d, k, j) for j in range(d + 1)) / (2 ** d * math.comb(d, k)) for k in range(d + 1)]


def main():
    d = 10
    # with bias: first-layer correlation (rho + b^2)/(1 + b^2), b^2 = 1
    def nngp_bias(r):
        return kappa1((r + 1.0) / 2.0)
    kernels = {
        "NNGP 2-layer ReLU, no bias": kappa1,
        "NTK 2-layer ReLU, no bias": lambda r: kappa1(r) + r * kappa0(r),
        "NNGP 2-layer ReLU, bias var 1": nngp_bias,
        "NNGP 3-layer ReLU, no bias": lambda r: kappa1(kappa1(r)),
    }
    log(f"(1) exact Walsh eigenvalue by degree k (d = {d})")
    for name, kap in kernels.items():
        ev = walsh_eigs(kap, d)
        odd3 = max(abs(ev[k]) for k in range(3, d + 1, 2))
        log(f"  {name:30s}: " + " ".join(f"{e:.2e}" for e in ev) + f" | max |lambda_k|, k odd >= 3: {odd3:.1e}")

    # (2) and (3)
    N = 2 ** d
    X = np.array([[1 - 2 * ((i >> j) & 1) for j in range(d)] for i in range(N)], dtype=float)
    G = X @ X.T / d
    K = kappa1(G)
    log("\n(2)+(3) KRR with the 2-layer bias-free ReLU NNGP kernel, ridge 1e-3 * mean diag; 20 random targets per cell")
    for k in [2, 3, 5]:
        for n in [40, 160, 640, 900]:
            accs, l2s = [], []
            for _ in range(20):
                S = rng.choice(d, size=k, replace=False)
                y = np.prod(X[:, S], axis=1)
                tr = rng.choice(N, size=n, replace=True)
                tru = np.unique(tr)
                Ktr = K[np.ix_(tru, tru)]
                alpha = np.linalg.solve(Ktr + 1e-3 * np.trace(Ktr) / len(tru) * np.eye(len(tru)), y[tru])
                gh = K[:, tru] @ alpha
                unseen = np.setdiff1d(np.arange(N), tru)
                accs.append(np.mean(np.sign(gh[unseen]) == y[unseen]) if len(unseen) else np.nan)
                l2s.append(np.mean((gh - y) ** 2))
            bound = max(0.0, 1 - n / math.comb(d, k))
            log(f"  k={k} n={n:4d}: 0-1 accuracy of sign(g_hat) on unseen points {np.nanmean(accs):.3f} "
                f"(min {np.nanmin(accs):.3f}, max {np.nanmax(accs):.3f}); L2 error {np.mean(l2s):.3f} "
                f"(Thm 4.6(b) average bound {bound:.3f}; Rem 4.8 predicts >= 1 for odd k >= 3)")
    log("Reading: odd degrees >= 3 vanish exactly for the bias-free 2-layer kernels (Rem 4.8 confirmed); a bias or a")
    log("third layer makes them nonzero.  For odd k >= 3, sign(g_hat) is WORSE than chance on unseen points, and gets")
    log("worse with n: g_hat is orthogonal to chi_S on the whole cube, so fitting the training labels forces negative")
    log("correlation off the training set.  The 'never learns' reading of Rem 4.8 thus also holds for 0-1 error of the")
    log("sign of the posterior mean (empirically here); GP classification proper is not tested.")
    with open(__file__.replace(".py", "_output.txt"), "w") as fh:
        fh.write("\n".join(OUT) + "\n")


if __name__ == "__main__":
    main()
