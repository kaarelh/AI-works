"""d1: lambda = c n is not Bayesian MAP for any fixed prior (sub-track "decay", target I2).

Deterministic or seeded (numpy default_rng with the seeds printed). Python 3.11, NumPy.
Output: d1_no_fixed_prior.out (same folder).

Parts
 (A) Duplication. In random finite classes, the cn-MAP set on the sample h repeated r times
     equals the c n0-MAP set on h for every r; the MAP set of a fixed prior w > 0 on h^(r)
     is, for all large r, contained in the maximum-likelihood set of h. Counts the samples on
     which no c n0-MAP is a maximum-likelihood program, and checks that on exactly those the
     two rules disagree for all large r (notes Prop 2.2).
 (B) The two-program example (coin of length 1 against a deterministic f of length 1+k) on
     f-labelled data: the cn-MAP is the coin at every n iff c k > 1; the fixed-lambda MAP
     switches to f once n > lambda k (notes Example 2.4). Exact integer arithmetic.
 (C) Per-query simulation in a small class with a sampler: cn-MAPs against MAPs of fixed
     summable priors, for c below and above c* (notes Prop 2.3, Prop 3.1).
 (D) The tempered posterior with learning rate 1/(cn) converges to the fixed Gibbs measure
     2^{-l - R/c}/Z; the power-prior posterior Pi_{cn} concentrates on argmin(c l + R)
     (notes Remark 1.3).
 (E) The per-sample recursion Pi_{cn}(.|h_n) propto Pi_{c(n-1)}(.|h_{n-1}) nu(y_n|x_n) 2^{-c l}
     (notes Remark 1.2), checked numerically.
"""
import math
from fractions import Fraction

import numpy as np

LOG2 = np.log2
TOL = 1e-9


def argmin_set(vals, tol=TOL):
    m = np.min(vals)
    scale = max(1.0, abs(m))
    return frozenset(np.flatnonzero(vals <= m + tol * scale).tolist())


# ----------------------------------------------------------------------------------------------
print("=" * 100)
print("(A) Duplication: the cn-MAP depends only on the empirical distribution; fixed priors tend to ML")
print("=" * 100)
rng = np.random.default_rng(20261014)
X, Y = 3, 2
trials = 2000
valid = 0
n_noML = 0
n_dup_invariant = 0
n_disagree_beyond = 0
n_inside_ML = 0
n_agree_when_ml = 0
n_ml_cases = 0
rth_max = 0.0
c_values = [0.02, 0.05, 0.1, 0.3]
for t in range(trials):
    K = int(rng.integers(3, 9))
    lengths = rng.integers(1, 13, size=K).astype(float)
    # kernels nu_pi(1|x) in (0.02, 0.98); with prob 0.2 a program is deterministic at every input
    P1 = rng.uniform(0.02, 0.98, size=(K, X))
    det = rng.random(K) < 0.2
    P1[det] = rng.integers(0, 2, size=(det.sum(), X)).astype(float)
    n0 = int(rng.integers(1, 12))
    xs = rng.integers(0, X, size=n0)
    ys = rng.integers(0, Y, size=n0)
    c = c_values[t % len(c_values)]
    w = 2.0 ** (-lengths) * rng.uniform(0.1, 10.0, size=K)  # a fixed prior, positive everywhere
    probs = np.where(ys[None, :] == 1, P1[:, xs], 1.0 - P1[:, xs])  # K x n0
    with np.errstate(divide="ignore"):
        L = -np.sum(LOG2(probs), axis=1)  # fit on h, in bits (inf allowed)
    if not np.isfinite(L).any():
        continue  # no program has positive likelihood: skipped (not counted)
    valid += 1
    J0 = c * n0 * lengths + L
    map0 = argmin_set(J0)
    ML = argmin_set(L)
    # duplication invariance, computed from the replicated sample itself (not from r * L)
    inv = True
    for r in [2, 3, 7, 50]:
        xr, yr = np.tile(xs, r), np.tile(ys, r)
        pr = np.where(yr[None, :] == 1, P1[:, xr], 1.0 - P1[:, xr])
        with np.errstate(divide="ignore"):
            Lr = -np.sum(LOG2(pr), axis=1)
        if argmin_set(c * (r * n0) * lengths + Lr) != map0:
            inv = False
    n_dup_invariant += inv
    # fixed prior on h^(r): minimise -log w + r L. Exact threshold beyond which no c n0-MAP that is not
    # ML can be a w-MAP: r > r_th := max over pi in map0 \ ML of (log w(pi) - log w(pi*)) / (L(pi) - L(pi*)),
    # with pi* the ML program of largest w.
    pstar = max(ML, key=lambda i: w[i])
    rth = 0.0
    for i in map0 - ML:
        rth = max(rth, (LOG2(w[i]) - LOG2(w[pstar])) / (L[i] - L[pstar]) if np.isfinite(L[i]) else 0.0)
    rth_max = max(rth_max, rth)
    r_check = int(math.floor(rth)) + 1
    with np.errstate(divide="ignore"):
        wmap = argmin_set(-LOG2(w) + r_check * L)
    if len(map0 & ML) == 0:
        n_noML += 1
        n_disagree_beyond += len(wmap & map0) == 0
        n_inside_ML += wmap <= ML
    else:
        n_ml_cases += 1
print(f"valid trials (some program with finite fit): {valid} of {trials}; c cycles through {c_values}")
print(f"cn-MAP set on the replicated sample h^(r), r = 2,3,7,50, equal to the c n0-MAP set on h: {n_dup_invariant} of {valid}")
print(f"samples with no c n0-MAP among the ML programs: {n_noML}")
print(f"  of these, at r = floor(r_th)+1 the w-MAP set is disjoint from the cn-MAP set (the claim): {n_disagree_beyond}")
print(f"  (at that r the w-MAP set already lies inside the ML set in {n_inside_ML}; not claimed, other programs may need larger r)")
print(f"  largest r_th = {rth_max:.1f}")
print(f"samples where some c n0-MAP is an ML program (no contradiction from duplication): {n_ml_cases}")

# ----------------------------------------------------------------------------------------------
print()
print("=" * 100)
print("(B) Two programs: coin (length 1) against a deterministic f (length 1+k), data labelled by f")
print("=" * 100)
k = 10
print(f"k = {k}. J_cn(coin) = c n + n, J_cn(f) = c n (1+k); J_lam(coin) = lam + n, J_lam(f) = lam (1+k).")
print(f"{'c':>8} {'cn-MAP at n=1,10,1e3,1e6':>34}   predicted: coin iff c k > 1")
for c in [Fraction(1, 20), Fraction(1, 10), Fraction(1, 5)]:
    out = []
    for n in [1, 10, 1000, 10**6]:
        Jc = c * n + n
        Jf = c * n * (1 + k)
        out.append("coin" if Jc < Jf else ("tie" if Jc == Jf else "f"))
    print(f"{str(c):>8} {', '.join(out):>34}   c k = {c * k}")
print(f"{'lambda':>8} {'least n with f the unique lambda-MAP':>40}   predicted: n > lambda k")
for lam in [1, 2, 5]:
    n = 1
    while not (lam * (1 + k) < lam + n):
        n += 1
    print(f"{lam:>8} {n:>40}   lambda k = {lam * k}")
print("So for c > 1/k the cn-MAP keeps the coin (0-1 error 1/2 on f-labelled data) at every n,")
print("while every fixed lambda (prior 2^{-lambda l}) switches to f (error 0) after lambda k samples.")

# ----------------------------------------------------------------------------------------------
print()
print("=" * 100)
print("(C) Per query: cn-MAPs against MAPs of fixed summable priors, c below and above c*")
print("=" * 100)
# inputs uniform on 8 points; sampler: f(x) flipped with prob p
Xn = 8
p = 0.1
f = np.array([0, 1, 1, 0, 1, 0, 0, 1])
fprime = f.copy()
fprime[3] ^= 1


def kernel(func, q):
    # returns nu(1|x) for x = 0..7
    return np.where(func == 1, 1.0 - q, q)


progs = [
    ("pi0=(f,p)", 10, kernel(f, p), True),
    ("pi0'=(f,p) long", 14, kernel(f, p), True),
    ("(f,1/8)", 9, kernel(f, 0.125), False),
    ("(f',p)", 6, kernel(fprime, p), False),
    ("coin", 2, np.full(Xn, 0.5), False),
]
names = [q[0] for q in progs]
lens = np.array([q[1] for q in progs], dtype=float)
K1 = np.array([q[2] for q in progs])  # nu(1|x)
inE = np.array([q[3] for q in progs])
nu1 = kernel(f, p)


def cross_entropy(k1):
    return np.mean(-(nu1 * LOG2(k1) + (1 - nu1) * LOG2(1 - k1)))


R = np.array([cross_entropy(K1[i]) for i in range(len(progs))])
H = R[0]
KL = R - H
ell0 = 10
cstar = min(KL[i] / (ell0 - lens[i]) for i in range(len(progs)) if lens[i] < ell0)
print("programs: " + "; ".join(f"{names[i]} l={lens[i]:.0f} R={R[i]:.5f} KL={KL[i]:.5f}" for i in range(len(progs))))
err01 = [np.mean(np.where(K1[i] >= 0.5, 1 - nu1, nu1)) for i in range(len(progs))]
print("0-1 error against the sampler's labels: " + "; ".join(f"{names[i]}: {err01[i]:.3f}" for i in range(len(progs))))
print(f"H(nu) = {H:.5f} bits; c* = min KL/(l0 - l) over shorter programs = {cstar:.5f}")
for c in [0.003, 0.02, 0.1]:
    Jc = c * lens + R
    print(f"  c = {c}: population argmin of c l + R: {names[int(np.argmin(Jc))]} (J_c = {', '.join(f'{v:.4f}' for v in Jc)})")

priors = {
    "2^-l": 2.0 ** (-lens),
    "2^-2l": 2.0 ** (-2 * lens),
    "random summable": 2.0 ** (-lens) * np.array([0.3, 5.0, 2.0, 0.7, 1.5]),
}
checkpoints = [100, 1000, 10000, 100000, 200000]
seeds = list(range(20))
res = {}
for seed in seeds:
    rg = np.random.default_rng(1000 + seed)
    nmax = checkpoints[-1]
    xs = rg.integers(0, Xn, size=nmax)
    ys = (rg.random(nmax) < nu1[xs]).astype(int)
    ll = np.where(ys[None, :] == 1, LOG2(K1[:, xs]), LOG2(1 - K1[:, xs]))  # K x nmax
    cum = np.cumsum(-ll, axis=1)
    for n in checkpoints:
        Ln = cum[:, n - 1]
        for c in [0.003, 0.02, 0.1]:
            mp = argmin_set(c * n * lens + Ln)
            res.setdefault(("cn", c, n), []).append(mp)
        for pn, w in priors.items():
            mp = argmin_set(-LOG2(w) + Ln)
            res.setdefault(("w", pn, n), []).append(mp)


def describe(sets):
    from collections import Counter
    cnt = Counter(tuple(sorted(s)) for s in sets)
    return ", ".join(f"{'+'.join(names[i] for i in k)}: {v}" for k, v in cnt.most_common())


for n in checkpoints:
    print(f" n = {n}:")
    for c in [0.003, 0.02, 0.1]:
        print(f"   cn-MAP, c = {c:<6}: {describe(res[('cn', c, n)])}")
    for pn in priors:
        print(f"   w-MAP, w = {pn:<16}: {describe(res[('w', pn, n)])}")

# ----------------------------------------------------------------------------------------------
print()
print("=" * 100)
print("(D) Tempered posterior with learning rate 1/(cn) -> Gibbs measure; power-prior posterior concentrates")
print("=" * 100)
for c in [0.02, 0.1]:
    gibbs = 2.0 ** (-lens - R / c)
    gibbs /= gibbs.sum()
    print(f" c = {c}: Gibbs limit 2^(-l - R/c)/Z = " + ", ".join(f"{names[i]}: {gibbs[i]:.4f}" for i in range(len(progs))))
    rg = np.random.default_rng(77)
    nmax = 200000
    xs = rg.integers(0, Xn, size=nmax)
    ys = (rg.random(nmax) < nu1[xs]).astype(int)
    ll = np.where(ys[None, :] == 1, LOG2(K1[:, xs]), LOG2(1 - K1[:, xs]))
    cum = np.cumsum(-ll, axis=1)
    amin = int(np.argmin(c * lens + R))
    for n in [100, 1000, 10000, 100000, 200000]:
        Rhat = cum[:, n - 1] / n
        temp = -lens - Rhat / c
        temp = 2.0 ** (temp - temp.max())
        temp /= temp.sum()
        tv = 0.5 * np.abs(temp - gibbs).sum()
        pw = -(c * n * lens + cum[:, n - 1])
        pw = 2.0 ** (pw - pw.max())
        pw /= pw.sum()
        print(f"   n = {n:>6}: TV(tempered, Gibbs) = {tv:.5f}; power-prior mass on argmin J_c ({names[amin]}) = {pw[amin]:.6f}")

# ----------------------------------------------------------------------------------------------
print()
print("=" * 100)
print("(E) Per-sample recursion of the power-prior posterior with lambda = cn")
print("=" * 100)
rg = np.random.default_rng(5)
c = 0.1
n = 50
xs = rg.integers(0, Xn, size=n)
ys = (rg.random(n) < nu1[xs]).astype(int)
ll = np.where(ys[None, :] == 1, LOG2(K1[:, xs]), LOG2(1 - K1[:, xs]))
maxdiff = 0.0
for m in range(1, n + 1):
    direct = -c * m * lens + ll[:, :m].sum(axis=1)
    direct -= direct.max()
    direct = 2.0 ** direct
    direct /= direct.sum()
    if m == 1:
        rec = 2.0 ** (-c * lens + ll[:, 0])
        rec /= rec.sum()
    else:
        rec = rec * 2.0 ** (ll[:, m - 1] - c * lens)
        rec /= rec.sum()
    maxdiff = max(maxdiff, np.abs(rec - direct).max())
print(f"max |recursive - direct| over n = 1..{n}: {maxdiff:.2e}")
