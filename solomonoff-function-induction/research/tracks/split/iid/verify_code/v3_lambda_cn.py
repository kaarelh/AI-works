"""v3: independent checks of iid notes-final Prop 3.4(b),(c) (lambda = c n, PQ).  Written for verify-iid.md; it does
not import or read any record script.

(A) Finite class (class A2 of v2, re-built here): c* = min_{l(pi) < l0} D(pi)/(l0 - l(pi)); the population
    minimiser set A_c of J_c = c l + R for c on both sides of c*; exact P[set of cn-MAPs = A_c] by enumeration of
    all count vectors (streamed), n up to 300.  Prop 3.4(b) predicts A_c = E0 for c < c*; (c) predicts
    P[cn-MAP set = A_c] -> 1 whenever A_c has one kernel.
(B) A countable misspecified Kraft class (nu not in the class): one input, nu = Bern(0.3); programs Bern(j/2^m) for
    odd j < 2^m, m >= 1, of length 2m + 1 (Kraft sum 1/4).  A_c is computed exactly from J_c(q) =
    c(2m+1) + H(0.3) + KL(0.3 || q); the cn-MAP at n is found exactly from the sufficient statistic (the fit is
    convex in q, so per m only the two odd grid points around the empirical rate can win; lengths are scanned until
    c n l exceeds the best objective found, which bounds every MAP's length).  200 runs (seed 4301), n up to 10^7.
"""
import math

import numpy as np
from scipy.special import gammaln

LOG2 = math.log2


def class_A2():
    nu = np.array([0.8, 0.2, 0.35, 0.65])
    C = {
        "t4": (4, nu.copy()), "t6": (6, nu.copy()), "t9": (9, nu.copy()),
        "coin": (2, np.array([0.5, 0.5, 0.5, 0.5])),
        "s2": (2, np.array([0.8, 0.2, 0.8, 0.2])),
        "n3": (3, np.array([0.55, 0.45, 0.35, 0.65])),
        "d3": (3, np.array([1.0, 0.0, 0.0, 1.0])),
        "n5": (5, np.array([0.8, 0.2, 0.75, 0.25])),
        "sub4": (4, 0.9 * nu),
        "z7": (7, np.array([1.0, 0.0, 0.35, 0.65])),
    }
    rng = np.random.default_rng(4201)
    for i in range(10):
        pa = rng.dirichlet([1, 1]) * rng.uniform(0.7, 1.0)
        pb = rng.dirichlet([1, 1]) * rng.uniform(0.7, 1.0)
        C[f"r8_{i}"] = (8, np.array([pa[0], pa[1], pb[0], pb[1]]))
    mu = np.array([0.3, 0.3, 0.7, 0.7])
    return mu, nu, C


def risk(mu, nu, ker):
    """R(pi) = E[-log2 nu_pi(y|x)] in bits (inf if nu_pi = 0 where nu > 0)."""
    tot = 0.0
    for m_, p_, k_ in zip(mu, nu, ker):
        if p_ > 0:
            if k_ == 0:
                return math.inf
            tot += m_ * p_ * -LOG2(k_)
    return tot


def exact_prob_mapset(mu, nu, C, n, lam, target, tol=1e-9):
    """exact P[set of lam-MAPs == target] with i.i.d. cells of probability mu*nu, streamed over the first count."""
    names = list(C)
    pc = mu * nu
    lk = np.array([[LOG2(v) if v > 0 else -np.inf for v in C[nm][1]] for nm in names])
    lens = np.array([C[nm][0] for nm in names], float)
    tmask = np.array([nm in target for nm in names])
    tot = 0.0
    mass = 0.0
    for c1 in range(n + 1):
        r = n - c1
        c2 = np.repeat(np.arange(r + 1), np.arange(r + 1, 0, -1))
        c3 = np.concatenate([np.arange(r - a + 1) for a in range(r + 1)])
        c4 = r - c2 - c3
        cv = np.stack([np.full_like(c2, c1), c2, c3, c4], 1)
        logp = gammaln(n + 1) - gammaln(cv + 1).sum(1) + (cv * np.log(pc)).sum(1)
        with np.errstate(invalid="ignore"):
            fit = -np.where(cv[:, None, :] > 0, cv[:, None, :] * lk[None], 0.0).sum(2)
        J = lam * lens[None] + fit
        jmin = J.min(1)
        ismap = J <= jmin[:, None] + tol
        ok = np.all(ismap == tmask[None], axis=1)
        p = np.exp(logp)
        tot += float(p[ok].sum())
        mass += float(p.sum())
    assert abs(mass - 1) < 1e-9
    return tot


print("=" * 100)
print("(A) finite class A2: c*, A_c and exact P[cn-MAP set = A_c]")
mu, nu, C = class_A2()
l0 = 4
E = {"t4", "t6", "t9"}
H = risk(mu, nu, nu)
R = {nm: risk(mu, nu, C[nm][1]) for nm in C}
D = {nm: R[nm] - H for nm in C}
short = [nm for nm in C if C[nm][0] < l0]
cstar = min(D[nm] / (l0 - C[nm][0]) for nm in short)
arg = min(short, key=lambda nm: D[nm] / (l0 - C[nm][0]))
print(f"  H_mu(nu) = {H:.5f} bits; c* = {cstar:.5f}, attained by {arg} (D = {D[arg]:.5f}, l = {C[arg][0]})")
for nm in short:
    print(f"    shorter program {nm:5s}: l = {C[nm][0]}, D = {D[nm]:.5f}, D/(l0-l) = {D[nm] / (l0 - C[nm][0]):.5f}")


def A_c(c):
    Jc = {nm: c * C[nm][0] + R[nm] for nm in C}
    m = min(Jc.values())
    return {nm for nm in C if Jc[nm] <= m + 1e-12}, m


for fac in (0.5, 0.8, 1.25, 2.0, 4.0):
    c = fac * cstar
    Ac, m = A_c(c)
    kernels = {tuple(np.round(C[nm][1], 12)) for nm in Ac}
    row = []
    for n in (25, 50, 100, 200, 300):
        row.append(f"n={n}: {exact_prob_mapset(mu, nu, C, n, c * n, Ac):.4f}")
    print(f"  c = {fac:4.2f} c* = {c:.5f}: A_c = {sorted(Ac)} (one kernel: {len(kernels) == 1}; = E0: {Ac == {'t4'}})")
    print("     exact P[cn-MAP set = A_c]: " + ", ".join(row))

print("=" * 100)
print("(B) countable misspecified class: Bern(j/2^m), odd j, l = 2m+1; nu = Bern(0.3) (not in the class)")
P0 = 0.3
H0 = -(P0 * LOG2(P0) + (1 - P0) * LOG2(1 - P0))


def kl(p, q):
    return p * LOG2(p / q) + (1 - p) * LOG2((1 - p) / (1 - q))


def neighbours(g, m):
    jlo = int(math.floor(g))
    return {j for j in range(jlo - 3, jlo + 4) if 1 <= j < 2 ** m and j % 2 == 1}


def pop_argmin(c):
    """argmin of J_c(q) = c(2m+1) + H0 + KL(P0||q); KL is convex in q, so per m only the odd neighbours of
    P0 2^m can win; every program of length 2m+1 has J_c >= c(2m+1) + H0, which ends the scan."""
    best = math.inf
    arg = []
    m = 1
    while c * (2 * m + 1) + H0 <= best + 1e-12:
        for j in neighbours(P0 * 2 ** m, m):
            v = c * (2 * m + 1) + H0 + kl(P0, j / 2 ** m)
            if v < best - 1e-12:
                best, arg = v, [(m, j)]
            elif abs(v - best) <= 1e-12:
                arg.append((m, j))
        m += 1
        if m > 48:
            raise RuntimeError("population scan too long for double precision")
    return arg, best


def emp_map(K, n, c):
    """exact set of cn-MAPs given K ones in n draws (ties within 1e-9 relative).  The fit is convex in q, so per m
    only the odd neighbours of the empirical rate can win; every program of length 2m+1 has
    J >= c n (2m+1) + n h(K/n) (h = binary entropy, the least possible fit), which ends the scan."""
    qh = K / n
    hmin = 0.0 if K in (0, n) else -(K * LOG2(qh) + (n - K) * LOG2(1 - qh))
    best = math.inf
    arg = []
    m = 1
    while c * n * (2 * m + 1) + hmin <= best * (1 + 1e-12):
        for j in neighbours(qh * 2 ** m, m):
            q = j / 2 ** m
            fit = -(K * LOG2(q) + (n - K) * LOG2(1 - q))
            v = c * n * (2 * m + 1) + fit
            if best == math.inf or v < best - 1e-9 * max(1.0, abs(best)):
                best, arg = v, [(m, j)]
            elif abs(v - best) <= 1e-9 * max(1.0, abs(best)):
                arg.append((m, j))
        m += 1
        if m > 48:
            raise RuntimeError("length scan too long for double precision")
    return arg


# sanity: the two-neighbour shortcut against brute force over all odd j, small m
rs = np.random.default_rng(4300)
nchecked = 0
for _ in range(300):
    n = int(rs.integers(5, 400))
    K = int(rs.binomial(n, P0))
    c = float(rs.choice([0.3, 0.1, 0.03]))
    best = math.inf
    arg = []
    for m in range(1, 13):
        for j in range(1, 2 ** m, 2):
            q = j / 2 ** m
            v = c * n * (2 * m + 1) - (K * LOG2(q) + (n - K) * LOG2(1 - q))
            if best == math.inf or v < best - 1e-9 * max(1, abs(best)):
                best, arg = v, [(m, j)]
            elif abs(v - best) <= 1e-9 * max(1, abs(best)):
                arg.append((m, j))
    assert best < math.inf
    if c * n * 27 > best:          # brute force range covers every possible MAP
        assert sorted(arg) == sorted(emp_map(K, n, c)), (n, K, c)
        nchecked += 1
print(f"  {nchecked} cases fully covered by the brute-force range;")
print("  shortcut (two odd neighbours per m, length scan) agrees with brute force on 300 random small cases")
rng = np.random.default_rng(4301)
NS = [10 ** 3, 10 ** 4, 10 ** 5, 10 ** 6, 10 ** 7]
for c in (0.1, 0.02, 0.005, 0.001):
    Ac, best = pop_argmin(c)
    hits = np.zeros(len(NS), int)
    runs = 200
    for r in range(runs):
        K = 0
        prev = 0
        for t, n in enumerate(NS):
            K += int(rng.binomial(n - prev, P0))
            prev = n
            mp_ = emp_map(K, n, c)
            hits[t] += set(mp_) <= set(Ac)
    print(f"  c = {c}: A_c = {[(m, j, round(j / 2 ** m, 5)) for m, j in Ac]} (J_c = {best:.5f}); "
          f"fraction of runs with every cn-MAP in A_c at n = 1e3..1e7: {[round(float(v), 3) for v in hits / runs]}")
print("done")
