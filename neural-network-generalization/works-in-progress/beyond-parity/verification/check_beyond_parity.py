"""Exact checks for the FAQ section on targets other than parity.

Run from any directory:  python3 check_beyond_parity.py
Requires numpy, scipy (HiGHS linear programming) and mpmath.

1. Walsh spectrum of the gamma<1 limiting kernel
   K(x,y) = Psi^{o(L-1)}((1+x.y)/(d+1)),  Psi(t) = (2/pi) arcsin t:
   the pairing lambda_{2i} = lambda_{2i+1} and the scaling lambda_j ~ d^{-j*},
   j* = 2*floor(j/2)+1.
2. The regression identity: for a kernel depending only on Hamming distance and
   training sets drawn uniformly without replacement, E||f - P_S f||^2 depends on
   f only through its Fourier weight by degree.  Checked exactly at d=5, n=4 by
   showing that E[(I-P_S)^T (I-P_S)] is diagonal in the Walsh basis with entries
   depending only on degree.
3. Fourier degree, leap, threshold degree and the distance err_v from degree-v
   threshold functions for the example targets, by exact linear programming.
4. Leap(f) <= threshold degree(f) for all 2^16 Boolean functions of four bits,
   and the threshold degrees of the leap-1 functions depending on all four bits.
5. A kernel-regression illustration at d=12: majority keeps a large squared error
   while its sign is learned, and a leap-1 target of threshold degree 3 is slower
   than three-bit parity.

Usage: python3 check_beyond_parity.py [section numbers]; with no arguments all run.
"""
import itertools
import math
import sys

import mpmath as mp
import numpy as np
from scipy.optimize import linprog

mp.mp.dps = 80


# ---------------------------------------------------------------- 1. spectrum
def psi_iter(t, L):
    for _ in range(L - 1):
        t = 2 / mp.pi * mp.asin(t)
    return t


def walsh_eigenvalues(d, L):
    """Normalized eigenvalue lambda_j of a single degree-j character."""
    kern = [psi_iter(mp.mpf(1 + d - 2 * h) / (d + 1), L) for h in range(d + 1)]
    lam = []
    for j in range(d + 1):
        s = mp.mpf(0)
        for h in range(d + 1):
            kraw = sum((-1) ** i * math.comb(h, i) * math.comb(d - h, j - i)
                       for i in range(0, min(h, j) + 1))
            s += math.comb(d, h) * kern[h] * kraw
        lam.append(s / (mp.mpf(2) ** d * math.comb(d, j)))
    return lam


def check_spectrum():
    print("1. Kernel spectrum")
    for L in (2, 3):
        lam = walsh_eigenvalues(12, L)
        pair = max(abs(lam[2 * i] - lam[2 * i + 1]) / lam[2 * i] for i in range(6))
        assert pair < mp.mpf(10) ** -60
        trace = sum(math.comb(12, j) * lam[j] for j in range(13))
        inv = " ".join(f"{float(1 / lam[j]):.4g}" for j in (0, 2, 4, 6, 12))
        print(f"   d=12 L={L}: max relative pairing gap {float(pair):.1e}, trace {float(trace):.12f}")
        print(f"            1/lambda_j for j = 0, 2, 4, 6, 12: {inv}")
        dec = all(lam[2 * i + 1] > lam[2 * i + 2] for i in range((len(lam) - 1) // 2))
        print(f"            strictly decreasing across pairs: {dec}")
    print("   lambda_j * (d+1)^{j*}, L=2 (bounded as d grows => lambda_j ~ d^{-j*}):")
    for j in range(6):
        js = 2 * (j // 2) + 1
        row = []
        for d in (40, 80, 160):
            lam = walsh_eigenvalues(d, 2)
            row.append(float(lam[j] * mp.mpf(d + 1) ** js))
        print(f"     j={j} (j*={js}): " + "  ".join(f"d={d}: {v:.4f}" for d, v in zip((40, 80, 160), row)))


# ---------------------------------------------------------------- 2. identity
def cube(d):
    return np.array(list(itertools.product([1, -1], repeat=d)), dtype=float)


def walsh_matrix(d):
    X = cube(d)
    subsets = [U for r in range(d + 1) for U in itertools.combinations(range(d), r)]
    H = np.array([[np.prod(x[list(U)]) for U in subsets] for x in X])
    return H, subsets


def check_identity(d=5, n=4, L=2):
    print("2. Regression identity (exact average over all training sets)")
    X = cube(d)
    M = len(X)
    G = X @ X.T
    lam = 2 / math.pi * np.arcsin((1 + G) / (d + 1))
    K = lam
    for _ in range(L - 2):
        K = 2 / math.pi * np.arcsin(K)
    A = np.zeros((M, M))
    count = 0
    for S in itertools.combinations(range(M), n):
        S = list(S)
        P = K[:, S] @ np.linalg.solve(K[np.ix_(S, S)], np.eye(M)[S])
        R = np.eye(M) - P
        A += R.T @ R
        count += 1
    A /= count * M  # normalized: E ||f - P_S f||^2_{L2(uniform)} = f^T A f
    H, subsets = walsh_matrix(d)
    B = H.T @ A @ H  # quadratic form in Walsh coordinates
    off = np.abs(B - np.diag(np.diag(B))).max()
    by_deg = {}
    for i, U in enumerate(subsets):
        by_deg.setdefault(len(U), []).append(B[i, i])
    spread = max(max(v) - min(v) for v in by_deg.values())
    print(f"   d={d}, n={n}, L={L}: {count} training sets; largest off-diagonal Walsh entry {off:.1e};")
    print(f"   largest spread of diagonal entries within one degree {spread:.1e}")
    print("   per-degree expected MSE of a single character: " +
          ", ".join(f"m_{k}={np.mean(v):.4f}" for k, v in sorted(by_deg.items())))


# ---------------------------------------------------------------- 3. targets
def fourier(f, d):
    H, subsets = walsh_matrix(d)
    coef = H.T @ f / len(f)
    return {U: c for U, c in zip(subsets, coef) if abs(c) > 1e-12}


def leap(support):
    covered, remaining, best = set(), [set(U) for U in support if U], 0
    while remaining:
        step = min(len(U - covered) for U in remaining)
        best = max(best, step)
        for U in remaining:
            if len(U - covered) == step:
                covered |= U
                break
        remaining = [U for U in remaining if not U <= covered]
    return best


def monomials(d, r):
    return [U for k in range(r + 1) for U in itertools.combinations(range(d), k)]


_FEATURES = {}


def features(d, r):
    """Values of all monomials of degree <= r at every point of the cube (cached)."""
    if (d, r) not in _FEATURES:
        X = cube(d)
        _FEATURES[(d, r)] = np.array([[np.prod(x[list(U)]) for U in monomials(d, r)] for x in X])
    return _FEATURES[(d, r)]


def ptf_feasible(f, d, r, keep=None):
    """Is there p of degree <= r with f(x) p(x) >= 1 on the kept points?"""
    Phi = features(d, r)
    idx = np.arange(len(Phi)) if keep is None else keep
    A = -(f[idx][:, None] * Phi[idx])
    res = linprog(np.zeros(Phi.shape[1]), A_ub=A, b_ub=-np.ones(len(idx)),
                  bounds=[(None, None)] * Phi.shape[1], method="highs")
    if res.status not in (0, 2):
        raise RuntimeError(res.message)
    return res.status == 0


def threshold_degree(f, d):
    for r in range(d + 1):
        if ptf_feasible(f, d, r):
            return r
    raise AssertionError


def err_v(f, d, v, max_m=4):
    """Exact min_{deg p <= v} Pr[f p <= 0], by searching removal sets of increasing size."""
    M = 2 ** d
    for m in range(max_m + 1):
        for drop in itertools.combinations(range(M), m):
            keep = np.array([i for i in range(M) if i not in drop])
            if ptf_feasible(f, d, v, keep):
                return f"{m}/{M}"
    return f">{max_m}/{M}"


def table(d, rule):
    return np.array([rule(x) for x in cube(d)], dtype=float)


def maj(xs):
    return 1.0 if sum(xs) > 0 else -1.0


TARGETS = [
    ("MAJ5", 5, lambda x: maj(x)),
    ("AND4 (+1 iff all bits are -1)", 4, lambda x: 1.0 if all(t == -1 for t in x) else -1.0),
    ("LTF sign(4x1+3x2+2x3+x4+x5)", 5, lambda x: maj([4 * x[0], 3 * x[1], 2 * x[2], x[3], x[4]])),
    ("XOR2", 2, lambda x: x[0] * x[1]),
    ("MUX x1 ? x2 : x3", 3, lambda x: x[1] if x[0] == 1 else x[2]),
    ("IP2 = AND(x1,x2) xor AND(x3,x4)", 4,
     lambda x: (-1.0 if x[0] == x[1] == -1 else 1.0) * (-1.0 if x[2] == x[3] == -1 else 1.0)),
    ("XOR3", 3, lambda x: x[0] * x[1] * x[2]),
    ("x4 ? x1x2x3 : MAJ(x1,x2,x3)", 4, lambda x: x[0] * x[1] * x[2] if x[3] == 1 else maj(x[:3])),
    ("XOR4", 4, lambda x: x[0] * x[1] * x[2] * x[3]),
    ("x5 ? x1x2x3x4 : sign(2x1+x2+x3+x4)", 5,
     lambda x: x[0] * x[1] * x[2] * x[3] if x[4] == 1 else maj([2 * x[0], x[1], x[2], x[3]])),
]


def check_targets():
    print("3. Example targets: Fourier degree, leap, threshold degree t, kappa = 2*floor(t/2)+1,")
    print("   and err_{kappa-2} (exact; only for t >= 2)")
    for name, d, rule in TARGETS:
        f = table(d, rule)
        F = fourier(f, d)
        deg = max(len(U) for U in F)
        lp = leap(F.keys())
        t = threshold_degree(f, d)
        kap = 2 * (t // 2) + 1
        e = err_v(f, d, kap - 2) if t >= 2 else "-"
        w = [sum(c * c for U, c in F.items() if len(U) == k) for k in range(d + 1)]
        print(f"   {name:36s} deg {deg}  leap {lp}  t {t}  kappa {kap}  err {e:6s}"
              f"  weights by degree {' '.join(f'{v:.3f}' for v in w)}")
        assert lp <= t <= deg


# ---------------------------------------------------------------- 4. census
def check_census(d=4):
    print(f"4. Census of all {2 ** 2 ** d} Boolean functions of {d} bits")
    H, subsets = walsh_matrix(d)
    counts, violations, hist = {}, 0, {}
    for bits in range(2 ** (2 ** d)):
        f = np.array([1.0 if (bits >> i) & 1 else -1.0 for i in range(2 ** d)])
        coef = H.T @ f / len(f)
        support = [subsets[i] for i in range(len(subsets)) if abs(coef[i]) > 1e-12]
        relevant = set().union(*[set(U) for U in support]) if support else set()
        lp = leap(support)
        deg = max((len(U) for U in support), default=0)
        t = 0
        while not ptf_feasible(f, d, t):
            t += 1
        if lp > t:
            violations += 1
        hist[(lp, t)] = hist.get((lp, t), 0) + 1
        if len(relevant) == d and lp == 1:
            counts[t] = counts.get(t, 0) + 1
        assert t <= deg
    print(f"   violations of leap <= threshold degree: {violations}")
    print("   (leap, threshold degree): number of functions")
    for key in sorted(hist):
        print(f"     {key}: {hist[key]}")
    total = sum(counts.values())
    print(f"   leap-1 functions depending on all {d} bits: {total}; by threshold degree: "
          + ", ".join(f"t={t}: {c}" for t, c in sorted(counts.items())))


# ---------------------------------------------------------------- 5. regression
def check_regression(d=12, L=2, seeds=4):
    print(f"5. Kernel regression (GP posterior mean on exact labels, no ridge), d={d}, L={L},")
    print(f"   n iid uniform draws with repeats removed, {seeds} seeds; squared error and sign error")
    X = cube(d)
    K = 2 / math.pi * np.arcsin((1 + X @ X.T) / (d + 1))
    for _ in range(L - 2):
        K = 2 / math.pi * np.arcsin(K)
    p3 = X[:, 0] * X[:, 1] * X[:, 2]
    targets = {
        "MAJ(x1..x7)": np.sign(X[:, :7].sum(1)),
        "x1x2x3": p3,
        "x4 ? x1x2x3 : MAJ3": np.where(X[:, 3] == 1, p3, np.sign(X[:, :3].sum(1))),
    }
    rng = np.random.default_rng(20261019)
    for n in (200, 800, 2400):
        acc = {k: [] for k in targets}
        for _ in range(seeds):
            S = np.unique(rng.integers(0, len(X), size=n))
            A = np.linalg.solve(K[np.ix_(S, S)], K[S]).T
            for k, f in targets.items():
                m = A @ f[S]
                acc[k].append((np.mean((m - f) ** 2), np.mean(np.sign(m) != f)))
        print(f"   n={n:5d}  " + "   ".join(
            f"{k}: {np.mean([a for a, _ in v]):.3f} / {np.mean([b for _, b in v]):.3f}" for k, v in acc.items()))


if __name__ == "__main__":
    which = sys.argv[1:] or ["1", "2", "3", "4", "5"]
    if "1" in which:
        check_spectrum()
    if "2" in which:
        check_identity()
    if "3" in which:
        check_targets()
    if "4" in which:
        check_census()
    if "5" in which:
        check_regression()
