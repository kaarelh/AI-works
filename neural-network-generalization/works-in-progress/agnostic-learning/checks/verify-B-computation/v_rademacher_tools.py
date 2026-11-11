"""Exact-enumeration checks of B.md Lemma 5.1 (ii)-(v) and of the first-layer step of Lemma 5.2.
Rad(A) = E_eps sup_{a in A} (1/n) sum eps_i a_i, computed exactly by enumerating all 2^n sign vectors."""
import itertools, math
import numpy as np
rng = np.random.default_rng(11)

def rad(A):                      # A: (k, n) array
    n = A.shape[1]
    E = np.array(list(itertools.product([-1.0, 1.0], repeat=n)))
    return np.mean(np.max(E @ A.T, axis=1)) / n

def clipt(u, t): return np.clip(u, -t, t)

worst = dict(massart=0.0, contraction=-1e9, clip=-1e9)
for trial in range(400):
    n = int(rng.integers(2, 11)); k = int(rng.integers(1, 9))
    A = rng.uniform(-1.3, 1.3, size=(k, n)) * rng.choice([0.2, 1.0, 3.0])
    # (ii) Massart: Rad(A) <= R sqrt(2 ln|A|)/n
    R = np.max(np.linalg.norm(A, axis=1))
    if k > 1: worst['massart'] = max(worst['massart'], rad(A) / (R * math.sqrt(2 * math.log(k)) / n))
    # (iii) contraction with random 1-Lipschitz maps phi_i(u) = s_i |u - c_i| or s_i * tanh-like
    c = rng.uniform(-1, 1, n); s = rng.choice([-1, 1], n)
    Phi = s * np.abs(A - c) * rng.uniform(0, 1, n)   # each coordinate map is (<=1)-Lipschitz
    worst['contraction'] = max(worst['contraction'], rad(Phi) - rad(A))
    # (iv) clipping: Rad(Clip A) <= Rad(A) + 1/(2 sqrt n), with t on a fine grid in [0,1]
    Ab = np.clip(A, -1, 1)
    ts = np.linspace(0, 1, 41)
    CA = np.vstack([clipt(Ab, t) for t in ts])
    worst['clip'] = max(worst['clip'], rad(CA) - rad(Ab) - 1 / (2 * math.sqrt(n)))
print("(ii)  max Rad(A)/[R sqrt(2 ln|A|)/n]           :", round(worst['massart'], 4), "(<= 1)")
print("(iii) max Rad(phi(A)) - Rad(A)                  :", f"{worst['contraction']:.3e}", "(<= 0)")
print("(iv)  max Rad(Clip A) - Rad(A) - 1/(2 sqrt n)   :", f"{worst['clip']:.3e}", "(<= 0)")

# tightness of (iv): A = {0}; Rad(Clip{0}) = Rad({0}) = 0, so the 1/(2 sqrt n) slack is only an upper bound.
# A = {+-1 vector constant}: check how close to the bound it gets
for n in [4, 8, 12]:
    A = np.vstack([np.ones(n), -np.ones(n)])
    CA = np.vstack([clipt(A, t) for t in np.linspace(0, 1, 101)])
    print(f"   n={n}: Rad(Clip A)-Rad(A) = {rad(CA)-rad(A):.4f}  vs 1/(2 sqrt n) = {1/(2*math.sqrt(n)):.4f}")

# (v) clip-mixture identity, quadrature
from scipy.integrate import quad
mx = 0
for _ in range(200):
    r = 10 ** rng.uniform(-2, 1.5); u = rng.uniform(-1, 1)
    w = lambda t: 2 * r * math.tanh(r * t) / math.cosh(r * t) ** 2
    val = quad(lambda t: max(-t, min(t, u)) * w(t), 0, 1, points=[abs(u)], limit=200)[0] + max(-1, min(1, u)) / math.cosh(r) ** 2
    mx = max(mx, abs(val - math.tanh(r * u) / r))
print("(v)   clip-mixture identity max error:", f"{mx:.2e}")

# First layer of Lemma 5.2: Rad(conv D_S) <= sqrt(2(d+1) ln(n+1)/n), D_S = sign patterns of affine halfspaces.
# Enumerate the dichotomies of n random points in R^d by sampling many random affine functions (gives a subset of D_S,
# hence a LOWER estimate of |D_S| and of Rad); compare |D_S| with sum_{k<=d+1} C(n,k) and (n+1)^{d+1}.
for (n, d) in [(8, 1), (10, 1), (10, 2), (12, 2), (12, 3)]:
    X = rng.uniform(-1, 1, size=(n, d)); Xb = np.hstack([np.ones((n, 1)), X])
    W = rng.standard_normal((400000, d + 1)); W[:, 0] *= 3
    P = np.sign(Xb @ W.T).T
    D = np.unique(P[np.all(P != 0, axis=1)], axis=0)
    ss = sum(math.comb(n, j) for j in range(d + 2))
    print(f"   n={n} d={d}: |D_S| found {len(D)} <= Sauer sum {ss} <= (n+1)^(d+1) = {(n+1)**(d+1)};"
          f"  Rad(D_S) = {rad(D):.4f} <= sqrt(2(d+1)ln(n+1)/n) = {math.sqrt(2*(d+1)*math.log(n+1)/n):.4f}")
