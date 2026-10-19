"""Shared utilities for the sign-conditioned GP experiments (label: sign-gp).

Kernel (confirmed in main-results/subcritical-exponential/source/width-limits.tex,
eq. (kernel), and subcritical-exponential.tex Sec. 2.1):
    Psi(t) = (2/pi) arcsin t,   K(x,y) = Psi^{o(L-1)}((1 + x.y)/(d+1)),  K(x,x)=1.
Learner at gamma<0 (gamma-negative.tex): G ~ N(0,K) on the cube conditioned on
f(X_i) G(X_i) > 0 for the training inputs; q_S(x) = P{f(x)G(x)>0 | signs};
F(S) = P_x{q_S(x) <= 2/3} over uniform x on the full cube (observed points included).
"""
import itertools
import numpy as np
from scipy.optimize import linprog
from scipy.special import comb


def cube(d):
    """All 2^d points of {-1,1}^d as an int8 array, row index = binary code."""
    idx = np.arange(2 ** d)
    bits = (idx[:, None] >> np.arange(d)[None, :]) & 1
    return (1 - 2 * bits).astype(np.int8)  # bit 0 -> +1, bit 1 -> -1


def psi_iter(t, L):
    t = np.asarray(t, dtype=float)
    for _ in range(L - 1):
        t = (2.0 / np.pi) * np.arcsin(np.clip(t, -1.0, 1.0))
    return t


def kernel_from_dot(dot, d, L):
    return psi_iter((1.0 + np.asarray(dot, dtype=float)) / (d + 1.0), L)


def gram(X, Y, d, L):
    return kernel_from_dot(X.astype(float) @ Y.astype(float).T, d, L)


def krawtchouk(j, h, d):
    return sum((-1) ** l * comb(h, l, exact=True) * comb(d - h, j - l, exact=True)
               for l in range(0, j + 1))


def kernel_spectrum(d, L):
    """Eigenvalue lam_j of the 2^d x 2^d cube Gram matrix on each degree-j character,
    and the per-character Fourier coefficient khat_j = lam_j / 2^d."""
    kap = [float(kernel_from_dot(d - 2 * h, d, L)) for h in range(d + 1)]
    # sum over y of kappa(1.y) chi_S(y) = sum_h kappa(d-2h) * K_j(h)   (|S| = j)
    lam = np.array([sum(kap[h] * comb(d, h, exact=True) * krawtchouk(j, h, d) for h in range(d + 1))
                    / comb(d, j, exact=True) for j in range(d + 1)])
    return lam, lam / 2 ** d


# ---------------------------------------------------------------- Fourier tools
def walsh(fvals):
    """Fourier coefficients fhat(S) for f on {-1,1}^k given in cube() order.
    Returns array indexed by subset bitmask S (bit i <-> coordinate i)."""
    a = np.array(fvals, dtype=float).copy()
    n = a.size
    h = 1
    while h < n:
        for i in range(0, n, 2 * h):
            x = a[i:i + h].copy()
            y = a[i + h:i + 2 * h].copy()
            a[i:i + h] = x + y
            a[i + h:i + 2 * h] = x - y
        h *= 2
    return a / n


def popcount(m):
    return bin(m).count("1")


def fourier_profile(fvals, k, tol=1e-12):
    c = walsh(fvals)
    supp = [m for m in range(2 ** k) if abs(c[m]) > tol]
    weight = np.zeros(k + 1)
    for m in supp:
        weight[popcount(m)] += c[m] ** 2
    deg = max((popcount(m) for m in supp), default=0)
    return c, supp, weight, deg


def leap(supp_masks):
    """Leap complexity (Abbe-Boix-Misiakiewicz): min over orderings of the support
    sets of max_i |S_i minus union_{j<i} S_j|.  For a fixed threshold l the greedy
    closure (repeatedly absorb any set with at most l new coordinates) is order
    independent, so leap = min l whose closure absorbs all sets."""
    sets = [m for m in supp_masks if m != 0]
    if not sets:
        return 0
    for l in range(0, max(popcount(m) for m in sets) + 1):
        U = 0
        remaining = list(sets)
        changed = True
        while changed and remaining:
            changed = False
            rest = []
            for m in remaining:
                if popcount(m & ~U) <= l:
                    U |= m
                    changed = True
                else:
                    rest.append(m)
            remaining = rest
        if not remaining:
            return l
    raise RuntimeError


def monomial_masks(k, r):
    return [m for m in range(2 ** k) if popcount(m) <= r]


def sign_rep_feasible(fvals, k, r):
    """LP feasibility: exists p of degree <= r with f(x) p(x) >= 1 for all x in {-1,1}^k."""
    X = cube(k).astype(float)
    masks = monomial_masks(k, r)
    Phi = np.stack([np.prod(X[:, [i for i in range(k) if (m >> i) & 1]], axis=1) if m else np.ones(2 ** k)
                    for m in masks], axis=1)
    f = np.asarray(fvals, dtype=float)
    A_ub = -(f[:, None] * Phi)
    b_ub = -np.ones(2 ** k)
    res = linprog(np.zeros(len(masks)), A_ub=A_ub, b_ub=b_ub, bounds=[(None, None)] * len(masks),
                  method="highs")
    return res.status == 0


def threshold_degree(fvals, k):
    for r in range(0, k + 1):
        if sign_rep_feasible(fvals, k, r):
            return r
    raise RuntimeError("degree k always suffices")


# ---------------------------------------------------------------- targets
def maj(Xj):
    s = Xj.sum(axis=1)
    assert np.all(s != 0)
    return np.sign(s).astype(int)


def stair_sum(Xj, m):
    terms = [np.prod(Xj[:, :i + 1], axis=1) for i in range(m)]
    return np.sum(terms, axis=0)
