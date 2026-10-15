"""r6: the steps of the alien coding lemma (notes Lemma 4.4, Lemma 4.5) on explicit finite instances, the type
class bounds, and the rate-separation arithmetic (notes Theorem 4.6(vi), Proposition 4.9(c),(d)).
Seeded: numpy default_rng(6), except (B) and (C), which are deterministic.

(A) Instance: coin set B = {0,1,2} with law rho = (1/2, 1/4, 1/4); coupling cells w in {0,1}^3 (8 cells, uniform);
    inputs x in {0,...,5} drawn from a fixed random kernel mu(x | w) (a latent shared cause seen through x), or
    x = (w, x') with x' uniform on 4 values (an observed feature); response y = h(x, b) = (g(x) + b) mod 3,
    injective in b.  The coupling beta: W -> B has exact type (4, 2, 2).  For random programs (random kernels
    nu_pi(y | x), some of them sub-probabilities) we check:
      sum_b q_w(b) <= 1, where q_w(b) := sum_x mu(x|w) nu_pi(h(x,b) | x);
      Q(beta') := prod_w q_w(beta'(w)) sums to at most 1 over all 3^8 couplings beta' (exact enumeration);
      -log2 Q(beta) <= 2^m R(pi), with R(pi) := E_w E_{x|w}[-log2 nu_pi(h(x, beta(w)) | x)]  (Jensen);
      the human's risk R(pi_H) = H(rho) exactly.
(B) Type class: L_beta = log2 multinomial(2^m; rho 2^m) lies in [2^m H(rho) - |B| log2(2^m + 1), 2^m H(rho)].
(C) The memoriser's rate H(rho)/(L_beta + 2 log2 m) against 2^-m: the lower end of the window is 2^-m (1 - o(1)).
(D) Rate separation: with a human of length l_H that explains E bits per sample more than the coin, a window needs
    2^m > (l_H - l_coin)/E (incompressible coupling) and, for a coupling with a short description of s bits,
    s > H(rho) (l_H - l_coin)/E, up to machine constants.
"""
from math import lgamma, log, log2
import itertools
import numpy as np

rng = np.random.default_rng(6)
LN2 = log(2.0)


def Hent(r):
    r = np.asarray(r, float)
    r = r[r > 0]
    return float(-(r * np.log2(r)).sum())


print("(A) The coding semimeasure, exact")
B = 3
rho = np.array([0.5, 0.25, 0.25])
m = 3
NW = 2 ** m
counts = (rho * NW).astype(int)
types = [b for b in range(B) for _ in range(counts[b])]
worst_sum, worst_jensen, worst_total = 0.0, -np.inf, 0.0
for case in ("latent", "feature"):
    if case == "latent":
        NX = 6
        mu = rng.dirichlet(np.ones(NX), size=NW)            # mu(x | w)
    else:
        NX = NW * 4
        mu = np.zeros((NW, NX))
        for w in range(NW):
            mu[w, w * 4:(w + 1) * 4] = 0.25                  # x = (w, x'), x' uniform
    g = rng.integers(0, 3, NX)
    hmap = (g[:, None] + np.arange(B)[None, :]) % 3          # h(x, b)
    for trial in range(300):
        beta = rng.permutation(types)                        # a coupling of exact type rho
        nu = rng.dirichlet(np.ones(3) * rng.choice([0.3, 1.0, 5.0]), size=NX)
        if trial % 3 == 0:
            nu = nu * rng.uniform(0.6, 1.0, size=(NX, 1))     # a sub-probability kernel
        q = np.einsum("wx,xb->wb", mu, nu[np.arange(NX)[:, None], hmap])     # q_w(b)
        worst_sum = max(worst_sum, q.sum(axis=1).max())
        # risk: E_w E_{x|w} -log2 nu(h(x, beta(w)) | x)
        lab = hmap[:, beta].T                                   # (NW, NX): label at (w, x)
        R = float((mu * -np.log2(nu[np.arange(NX)[None, :], lab])).sum() / NW)
        mlogQ = float(-np.log2(q[np.arange(NW), beta]).sum())
        worst_jensen = max(worst_jensen, mlogQ - NW * R)
        if trial < 20:
            tot = sum(np.prod(q[np.arange(NW), list(bp)]) for bp in itertools.product(range(B), repeat=NW))
            worst_total = max(worst_total, tot)
    # human: nu_H(h(x,b) | x) = rho(b)
    nuH = np.zeros((NX, 3))
    for x in range(NX):
        nuH[x, hmap[x]] = rho
    beta = rng.permutation(types)
    lab = hmap[:, beta].T
    RH = float((mu * -np.log2(nuH[np.arange(NX)[None, :], lab])).sum() / NW)
    print(f"  {case:8s}: R(pi_H) = {RH:.12f}, H(rho) = {Hent(rho):.12f}")
print(f"  max_w sum_b q_w(b) over all trials = {worst_sum:.12f} (must be <= 1)")
print(f"  max over 20 programs per case of sum over all 3^8 couplings of Q = {worst_total:.12f} (must be <= 1)")
print(f"  max of [-log2 Q(beta) - 2^m R(pi)] over 600 programs = {worst_jensen:.6f} (must be <= 0)")

print("\n(B) Type-class bounds  2^m H(rho) - |B| log2(2^m+1) <= L_beta <= 2^m H(rho)")
for rho_ in ([0.5, 0.5], [0.75, 0.25], [15 / 16, 1 / 16], [0.5, 0.25, 0.25], [0.25] * 4):
    for m_ in (4, 8, 12, 16, 20):
        n = 2 ** m_
        ks = [round(r * n) for r in rho_]
        L = (lgamma(n + 1) - sum(lgamma(k + 1) for k in ks)) / LN2
        up = n * Hent(rho_)
        lo = up - len(rho_) * log2(n + 1)
        assert lo <= L <= up + 1e-9
    print(f"  rho = {[round(r, 4) for r in rho_]}: holds for m = 4, 8, 12, 16, 20;"
          f" at m = 20: 2^m H - L_beta = {up - L:.2f} bits (bound {len(rho_) * log2(n + 1):.2f})")

print("\n(C) The memoriser's rate H(rho)/(L_beta + 2 log2 m), times 2^m")
for rho_ in ([15 / 16, 1 / 16], [0.5, 0.25, 0.25]):
    row = []
    for m_ in (6, 10, 14, 18, 22):
        n = 2 ** m_
        ks = [round(r * n) for r in rho_]
        L = (lgamma(n + 1) - sum(lgamma(k + 1) for k in ks)) / LN2
        row.append(f"m={m_}: {Hent(rho_) / (L + 2 * log2(m_)) * n:.4f}")
    print(f"  rho = {[round(r, 4) for r in rho_]}: " + ", ".join(row))

print("\n(D) Rate separation: cells and seed lengths needed for a window (machine constants set to 0, an illustration)")
for lH in (1e3, 1e6, 1e9, 1e12):
    for (Hr, E) in ((0.5, 0.5), (0.1, 0.9)):
        cells = (lH - 2) / E
        seed = Hr * (lH - 2) / E
        print(f"  l_H = {lH:8.0e}, H(rho) = {Hr}, E = {E}: incompressible coupling needs 2^m > {cells:.3e}"
              f" (m > {log2(cells):5.1f}); a coupling with an s-bit description needs s > {seed:.3e}")
