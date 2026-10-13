"""i4: noisy computable functions (notes-final Cor 6.1, Thm 4.1(iv)): explicit margin and sample size, and simulation.
[Labels updated to the notes-final numbering and notation (l0, E0) on 2026-10-13; computations unchanged.]

Class.  Inputs uniform on {0,1}^6, labels fresh per query.  Programs:
  * (a, q): label = <a, x> mod 2, flipped with probability q, for a in {0,1}^6 and q in the rate list
    RATES = [0, 1/4, 1/8, 1/16, 3/16, 5/16, 3/8, 7/16] with rate-code lengths [2,2,3,4,5,6,7,7];
    l(a, q) = 1 + 6 + l_rate(q).  (q = 0 gives the deterministic parities.)
  * coin: Bern(1/2) labels, l = 2.
  Kraft sum = 64 * 2^-7 * 0.75 + 2^-2 = 0.625.
Truth: (a*, 1/8), a* = 101101, so l0 = 10 and E = E0 = {(a*, 1/8)} (no other program has the same kernel).
Shorter competitors: (a*, 0) and (a*, 1/4) (l = 9), (a, 0) and (a, 1/4) for a != a* (l = 9), the coin (l = 2).

(A) Margin: gamma = min over non-E programs of E_mu H^2(nu, nu_pi), computed exactly from the closed forms
    h_eq(p,q) = 1 - sqrt(pq) - sqrt((1-p)(1-q)) (same parity) and
    h_ne(p,q) = 1 - sqrt(p(1-q)) - sqrt((1-p)q) (on the half of the inputs where two parities differ).
    The explicit sample size of Thm 4.1(iv), n(lambda, l0, gamma, eps) =
    lambda (l0 + log2(2/eps)) ln 2 / (2 min(1, lambda-1) gamma), here with the finite-class form
    (no length tail is needed: the class has no programs longer than 14 bits).
(B) Simulation, 2000 runs, seed 4: empirical P[lambda-MAP != (a*, 1/8) at n] on a grid of n, against the
    Renyi bound sum_{pi not in E} 2^{l0 - l(pi)} rho_{1/lambda}(pi)^n and the margin bound
    2^{l0} exp(-2 min(1, lambda-1) gamma n / lambda); lambda in {1, 1.5, 2, 4}.
"""
import numpy as np
from math import sqrt, log2, exp, log

rng = np.random.default_rng(4)
d = 6
X = np.arange(2 ** d)
RATES = [0.0, 1 / 4, 1 / 8, 1 / 16, 3 / 16, 5 / 16, 3 / 8, 7 / 16]
LRATE = [2, 2, 3, 4, 5, 6, 7, 7]
astar, pstar = 0b101101, 1 / 8
LSTAR = 1 + d + LRATE[RATES.index(pstar)]
popcount = np.vectorize(lambda v: bin(int(v)).count("1"))
PAR = popcount(np.bitwise_and(X[:, None], X[None, :])) % 2      # PAR[a, x] = <a, x> mod 2

progs = [(a, qi) for a in range(2 ** d) for qi in range(len(RATES))]
lens = np.array([1 + d + LRATE[qi] for a, qi in progs] + [2])
assert (2.0 ** -lens).sum() <= 1
names = progs + ["coin"]
istar = names.index((astar, RATES.index(pstar)))

def kernel(i):
    """P(label 1 | x) for program i, as an array over x."""
    if names[i] == "coin":
        return np.full(2 ** d, 0.5)
    a, qi = names[i]
    q = RATES[qi]
    return np.where(PAR[a] == 1, 1 - q, q)

nu1 = kernel(istar)
K1 = np.stack([kernel(i) for i in range(len(names))])          # (programs, x)

def rho(i, s):
    p1, q1 = nu1, K1[i]
    t = np.zeros(2 ** d)
    for P, Q in ((p1, q1), (1 - p1, 1 - q1)):
        m = (P > 0) & (Q > 0)
        t[m] += P[m] ** (1 - s) * Q[m] ** s
    return t.mean()

nonE = [i for i in range(len(names)) if i != istar]
gaps = np.array([1 - rho(i, 0.5) for i in nonE])
gamma = gaps.min()
iw = nonE[int(gaps.argmin())]
heq = lambda p, q: 1 - sqrt(p * q) - sqrt((1 - p) * (1 - q))
hne = lambda p, q: 1 - sqrt(p * (1 - q)) - sqrt((1 - p) * q)
print("=" * 78)
print(f"(A) l0 = {LSTAR}; gamma = {gamma:.6f}, attained by {names[iw]} (closed form h_eq(1/8, 3/16) = "
      f"{heq(1/8, 3/16):.6f}, h_eq(1/8, 1/16) = {heq(1/8, 1/16):.6f})")
print(f"    a wrong parity with rate q has gap (h_eq + h_ne)/2; smallest over q: "
      f"{min((heq(pstar, q) + hne(pstar, q)) / 2 for q in RATES):.4f}")
for lam in [1.5, 2.0, 4.0]:
    for eps in [0.05, 0.01]:
        nexp = lam * (LSTAR + log2(2 / eps)) * log(2) / (2 * min(1, lam - 1) * gamma)
        print(f"    lambda={lam}, eps={eps}: n(lambda, l0, gamma, eps) = {nexp:.0f}")

print("=" * 78)
print("(B) simulation: empirical P[lambda-MAP != truth at n] (2000 runs) vs Renyi and margin bounds")
NS = [25, 50, 100, 200, 400, 800, 1600, 3200]
runs = 2000
LAMS = [1.0, 1.5, 2.0, 4.0]
bad = {lam: np.zeros(len(NS)) for lam in LAMS}
logK1 = np.where(K1 > 0, np.log2(np.where(K1 > 0, K1, 1)), -np.inf)
logK0 = np.where(K1 < 1, np.log2(np.where(K1 < 1, 1 - K1, 1)), -np.inf)
for r in range(runs):
    xs = rng.integers(0, 2 ** d, size=NS[-1])
    ys = (rng.random(NS[-1]) < nu1[xs]).astype(int)
    for t, n in enumerate(NS):
        c1 = np.bincount(xs[:n][ys[:n] == 1], minlength=2 ** d)
        c0 = np.bincount(xs[:n][ys[:n] == 0], minlength=2 ** d)
        with np.errstate(invalid="ignore"):
            L = np.where(c1[None, :] > 0, c1[None, :] * logK1, 0).sum(1) + \
                np.where(c0[None, :] > 0, c0[None, :] * logK0, 0).sum(1)
        for lam in LAMS:
            J = lam * lens - L
            m = J[istar]
            others = np.delete(J, istar)
            bad[lam][t] += np.any(others <= m + 1e-9)
for lam in LAMS:
    print(f"  lambda = {lam}")
    s = 1 / lam
    rhos = np.array([rho(i, s) for i in nonE])
    for t, n in enumerate(NS):
        BR = float(np.sum(2.0 ** (LSTAR - lens[nonE]) * rhos ** n))
        BH = 2.0 ** LSTAR * exp(-2 * min(1, lam - 1) * gamma * n / lam) if lam > 1 else float("inf")
        print(f"    n={n:5d}  empirical={bad[lam][t]/runs:.4f}  Renyi={min(BR, 99):.4g}  margin={min(BH, 99):.4g}")
