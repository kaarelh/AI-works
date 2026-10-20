"""Sanity checks for the subcube-localized lower bound (../../subcube-parity.md, Section 1).

(1) Localized squared balance and clipped parity on a subcube, for chi_R with |R| < d,
    exhaustively over the d-cube, for random and adversarial low-degree polynomials
    obtained by restricting polynomials on the (d+k)-cube.
(2) Spectral bookkeeping on the (d+k)-cube: r*binom(d+1,r+2)*lambda_{r+1}/tau_r stays
    bounded (the spectral bookkeeping of the proof), and D_r(d+k) <= 2^k D_r(d).
(3) Two-head decoupling: covariance of a.h(x)+z b.h(x) vanishes across z values.
"""
import itertools, math
import numpy as np
import mpmath as mp

rng = np.random.default_rng(0)

def cube(n):
    return np.array(list(itertools.product([-1, 1], repeat=n)), dtype=float)

def chars_upto(X, r):
    n = X.shape[1]
    cols, sets = [], []
    for j in range(r + 1):
        for U in itertools.combinations(range(n), j):
            cols.append(np.prod(X[:, list(U)], axis=1) if U else np.ones(len(X)))
            sets.append(U)
    return np.array(cols).T, sets

print("== (1) localized squared balance / clipped parity ==")
d, k = 10, 2
W = cube(d + k)            # ambient points w=(x,z), z = last k coords
z0 = np.array([-1.0, 1.0])
mask = np.all(W[:, d:] == z0, axis=1)
X0 = W[mask][:, :d]        # the subcube, as x in {-1,1}^d
worst_bal, worst_clip = np.inf, -np.inf
for R in [tuple(range(d)), tuple(range(7)), (0, 2, 4, 6, 8, 9)]:
    chiR = np.prod(X0[:, list(R)], axis=1)
    for r in [1, 2, 3]:
        Phi, sets = chars_upto(W, r)
        for trial in range(300):
            if trial % 3 == 0:
                coef = rng.standard_normal(Phi.shape[1])
            elif trial % 3 == 1:   # sparse heavy-tailed coefficients
                coef = rng.standard_cauchy(Phi.shape[1]) * (rng.random(Phi.shape[1]) < 0.2)
            else:                  # polynomial in the z-coordinates times low-degree x part
                coef = rng.standard_normal(Phi.shape[1]) * np.array([1.0 if any(i >= d for i in U) else 0.1 for U in sets])
            P = Phi @ coef
            P0 = P[mask]
            nrm2 = np.mean(P0 ** 2)
            if nrm2 < 1e-12:
                continue
            q = chiR * P0
            bal = np.mean(np.minimum(q, 0) ** 2) / nrm2
            bound = 0.5 - math.sqrt(r / len(R))
            worst_bal = min(worst_bal, bal - bound)
            # Delta_R P0
            DeltaP = np.zeros_like(P0)
            idx = {tuple(x): i for i, x in enumerate(X0)}
            for j in R:
                Xf = X0.copy(); Xf[:, j] *= -1
                perm = np.array([idx[tuple(x)] for x in Xf])
                DeltaP += (P0 - P0[perm]) / 2
            for b in [0.1, 0.5, 1.0, 3.0]:
                b = b * math.sqrt(nrm2)
                lhs = abs(np.mean(chiR * np.clip(P0 / b, -1, 1)))
                rhs = np.mean(np.abs(DeltaP)) / (b * len(R))
                worst_clip = max(worst_clip, lhs - rhs)
print(f"min over trials of [E(chi_R P0)_-^2/||P0||^2 - (1/2 - sqrt(r/|R|))] = {worst_bal:.4f}  (must be >= 0)")
print(f"max over trials of [|E chi_R clip(P0/b)| - ||Delta_R P0||_1/(b|R|)] = {worst_clip:.2e}  (must be <= 0)")

print("== (2) spectral bookkeeping on the (d+k)-cube ==")
mp.mp.dps = 120
def Psi(t):
    return 2 / mp.pi * mp.asin(t)
def eigs(dd, L):
    # normalized eigenvalue at each degree j on the dd-cube
    Kh = []
    for h in range(dd + 1):
        t = mp.mpf(1 + dd - 2 * h) / (dd + 1)
        for _ in range(L - 1):
            t = Psi(t)
        Kh.append(t)
    lam = []  # lam[j] = E_w K(w,1) chi_U(w), |U|=j
    for j in range(dd + 1):
        s = mp.mpf(0)
        for h in range(dd + 1):
            kr = sum((-1) ** i * math.comb(h, i) * math.comb(dd - h, j - i) for i in range(0, min(h, j) + 1))
            s += Kh[h] * math.comb(dd, h) * kr   # sum_{|w|=h} chi_U(w) = C(dd,h) K_j(h) / C(dd,j)
        lam.append(s / (mp.mpf(2) ** dd * math.comb(dd, j)))
    return lam
for L in [2, 3]:
    for d in [24, 48, 72]:
        for k in [0, 1, 3]:
            dd = d + k
            lam = eigs(dd, L)
            vals = []
            for r in range(1, (d + 1) // 8 + 1, 2):
                tau = sum(math.comb(dd, j) * lam[j] for j in range(r + 1, dd + 1))
                ell = lam[r + 1]
                vals.append(float(r * math.comb(d + 1, r + 2) * ell / tau))
            Dr_ok = all(sum(math.comb(dd, j) for j in range(r + 1)) <= 2 ** k * sum(math.comb(d, j) for j in range(r + 1)) for r in range(d + 1))
            print(f"L={L} d={d} k={k}: r*C(d+1,r+2)*l_r/tau_r over odd r<=(d+1)/8: min {min(vals):.3f} max {max(vals):.3f};  D_r(d+k)<=2^k D_r(d): {Dr_ok}")

print("== (3) two-head decoupling ==")
# a.h(x) + z b.h(x), a,b iid N(0,I/N): Cov((x,z),(y,z')) = Q(x,y)(1+z z')/N
Nw, dim = 50, 6
H = np.tanh(rng.standard_normal((2 ** dim, Nw)))
Q = H @ H.T / Nw
zz = np.array([1, -1])
C = np.einsum('xy,ab->xayb', Q, 1 + np.outer(zz, zz)).reshape(2 ** dim * 2, 2 ** dim * 2)
print("max |cov| across z=+1 / z=-1 blocks:", np.abs(C.reshape(2 ** dim, 2, 2 ** dim, 2)[:, 0, :, 1]).max())
# consistency: sum_U lambda_|U| = K(x,x) = 1
lam = eigs(20, 2)
print("trace check (should be 1):", float(sum(math.comb(20, j) * lam[j] for j in range(21))))
print("pairing check lambda_{2i}=lambda_{2i+1} (d=20,L=2):", [round(float(lam[2*i]/lam[2*i+1]), 6) for i in range(5)])
