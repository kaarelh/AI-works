"""i1: exact enumeration in a small product class with i.i.d. per-query data (notes-final Lemma 2.1(c),(d), Thm 3.2, Prop 3.4(a), Thm 4.1(iv)).
[Labels updated to the notes-final numbering and notation (l0, E0) on 2026-10-13; computations unchanged.]

Setting.  X = {a, b}, mu(a) = mu(b) = 1/2.  Truth nu(1|a) = 0.1, nu(1|b) = 0.8.  Labels are drawn
fresh at every query (per-query likelihood), so the counts (n_a0, n_a1, n_b0, n_b1) are sufficient and
the law of the data is a multinomial.  The class C below has Kraft sum < 1.  E = programs whose kernel
equals nu mu-a.e. = {t5, t7}; E0 = {t5}; l0 = 5.

(A) Exact P[set of lambda-MAPs != E0] at n for lambda in {1, 1.25, 1.5, 2, 3}, against
    (i)  the Renyi bound   B_R(n) = sum_{pi not in E} 2^{l0 - l(pi)} rho_{1/lambda}(pi)^n   (Thm 4.1(iv)),
    (ii) the margin bound  B_H(n) = 2^{l0} exp(-2 min(1, lambda-1) gamma n / lambda)       (Thm 4.1(iv)),
    with gamma = min_{pi not in E} E_mu H^2(nu, nu_pi) (the class is finite, so no length tail).
(B) The Hoelder inequality rho_s <= rho_{1/2}^{2 min(s, 1-s)} for every program and s on a grid, and
    E[Lambda_n^s] = rho_s^n checked by exact enumeration at n = 6.
(C) Posterior: exact E[Pi_lambda(E | D_n)] and E[Pi_lambda(E0 | D_n)] against the limits 1 and
    w_lambda = 2^{-5 lambda} / (2^{-5 lambda} + 2^{-7 lambda}) (Thm 3.2); the same for the tempered posterior.
(D) lambda_n = c n: the per-sample objective c l + R; for c above c* = min over shorter programs of
    D(pi)/(l0 - l(pi)) a shorter wrong program minimises it, so lambda = c n does not recover E0.
Deterministic (no randomness).  The enumeration over count vectors is vectorised with numpy.
"""
from math import lgamma, log2, exp, log, sqrt
import numpy as np
from scipy.special import gammaln

MU = {"a": 0.5, "b": 0.5}
NU = {"a": 0.1, "b": 0.8}                        # nu(1|x)
# name: (length, {x: (P(0|x), P(1|x))})  -- sub-probabilities allowed
C = {
    "t5":   (5, {"a": (0.9, 0.1), "b": (0.2, 0.8)}),   # shortest program for nu  (E0)
    "t7":   (7, {"a": (0.9, 0.1), "b": (0.2, 0.8)}),   # longer program for nu    (E \ E0)
    "coin": (2, {"a": (0.5, 0.5), "b": (0.5, 0.5)}),
    "s3":   (3, {"a": (0.9, 0.1), "b": (0.9, 0.1)}),   # wrong on b, shorter than l0
    "near": (4, {"a": (0.9, 0.1), "b": (0.6, 0.4)}),   # wrong on b, shorter than l0
    "far6": (6, {"a": (0.5, 0.5), "b": (0.2, 0.8)}),   # wrong on a, longer than l0
    "det":  (3, {"a": (1.0, 0.0), "b": (0.0, 1.0)}),   # deterministic majority labels
    "sub6": (6, {"a": (0.9, 0.1), "b": (0.1, 0.6)}),   # a sub-probability, longer
}
E = {"t5", "t7"}; ESTAR = {"t5"}; LSTAR = 5
kraft = sum(2.0 ** -l for l, _ in C.values())
assert kraft <= 1, kraft
print(f"Kraft sum of C = {kraft:.4f}")

def nu_xy(x, y):
    return NU[x] if y == 1 else 1 - NU[x]

def rho(name, s):
    _, k = C[name]
    tot = 0.0
    for x in "ab":
        for y in (0, 1):
            p, q = nu_xy(x, y), k[x][y]
            if p > 0 and q > 0:
                tot += MU[x] * p ** (1 - s) * q ** s
    return tot

def hel(name):
    return 1 - rho(name, 0.5)

def logpmf(counts, n):
    # multinomial over cells (a,0),(a,1),(b,0),(b,1)
    cells = [MU["a"] * (1 - NU["a"]), MU["a"] * NU["a"], MU["b"] * (1 - NU["b"]), MU["b"] * NU["b"]]
    lp = lgamma(n + 1)
    for c, p in zip(counts, cells):
        lp += -lgamma(c + 1) + c * log(p)
    return lp

def loglik(name, counts):
    _, k = C[name]
    cells = [k["a"][0], k["a"][1], k["b"][0], k["b"][1]]
    tot = 0.0
    for c, q in zip(counts, cells):
        if c == 0:
            continue
        if q == 0:
            return float("-inf")
        tot += c * log2(q)
    return tot

def compositions(n):
    for i in range(n + 1):
        for j in range(n + 1 - i):
            for k in range(n + 1 - i - j):
                yield (i, j, k, n - i - j - k)

def comp_array(n):
    """All count vectors (n_a0, n_a1, n_b0, n_b1) summing to n, as an int array of shape (M, 4)."""
    i, j, k = np.meshgrid(np.arange(n + 1), np.arange(n + 1), np.arange(n + 1), indexing="ij")
    m = (i + j + k) <= n
    i, j, k = i[m], j[m], k[m]
    return np.stack([i, j, k, n - i - j - k], axis=1)

CELLS_TRUE = np.array([MU["a"] * (1 - NU["a"]), MU["a"] * NU["a"], MU["b"] * (1 - NU["b"]), MU["b"] * NU["b"]])

def logpmf_vec(A, n):
    return gammaln(n + 1) + (A * np.log(CELLS_TRUE) - gammaln(A + 1)).sum(axis=1)

def loglik_vec(name, A):
    _, k = C[name]
    q = np.array([k["a"][0], k["a"][1], k["b"][0], k["b"][1]], dtype=float)
    with np.errstate(divide="ignore", invalid="ignore"):
        lq = np.where(q > 0, np.log2(np.where(q > 0, q, 1.0)), -np.inf)
        terms = np.where(A > 0, A * lq[None, :], 0.0)
    return terms.sum(axis=1)

nonE = [p for p in C if p not in E]
gamma = min(hel(p) for p in nonE)
print("\nSquared-Hellinger gaps E_mu H^2(nu, nu_pi) and Renyi affinities:")
for p in C:
    print(f"  {p:5s} l={C[p][0]}  H2-gap={hel(p):.5f}  rho_1/2={rho(p, .5):.5f}  rho_2/3={rho(p, 2/3):.5f}  rho_1={rho(p, 1.0):.5f}")
print(f"gamma = min over non-E programs = {gamma:.5f}")

print("\n" + "=" * 78)
print("(A) exact P[lambda-MAP set != E0] at n, against the Renyi bound B_R and the margin bound B_H")
LAMS = [1.0, 1.25, 1.5, 2.0, 3.0]
NS = [1, 5, 10, 20, 40, 80, 160, 240, 320, 400]
CACHE = {n: comp_array(n) for n in NS}
LL = {n: {p: loglik_vec(p, CACHE[n]) for p in C} for n in NS}
PMF = {n: np.exp(logpmf_vec(CACHE[n], n)) for n in NS}
for lam in LAMS:
    print(f"  lambda = {lam}")
    for n in NS:
        Jt5 = lam * C["t5"][0] - LL[n]["t5"]
        badmask = np.zeros(len(Jt5), dtype=bool)
        for p in C:
            if p == "t5":
                continue
            badmask |= (lam * C[p][0] - LL[n][p]) <= Jt5 + 1e-9
        bad = float(PMF[n][badmask].sum())
        BR = sum(2.0 ** (LSTAR - C[p][0]) * rho(p, 1 / lam) ** n for p in nonE)
        BH = 2.0 ** LSTAR * exp(-2 * min(1, lam - 1) * gamma * n / lam)
        flag = "" if bad <= BR + 1e-12 and BR <= BH + 1e-12 else "  VIOLATION"
        print(f"    n={n:4d}  exact={bad:.3e}  B_R={min(BR, 9.99):.3e}  B_H={min(BH, 9.99):.3e}{flag}")
print("  (B_R and B_H are capped at 9.99 for display; the order exact <= B_R <= B_H is checked at every row)")

print("\n" + "=" * 78)
print("(B) Hoelder: rho_s <= rho_{1/2}^{2 min(s,1-s)}; and E[Lambda_n^s] = rho_s^n at n = 6 (exact)")
worst = -1.0
for p in C:
    for s in [i / 20 for i in range(1, 20)]:
        lhs, rhs = rho(p, s), rho(p, 0.5) ** (2 * min(s, 1 - s))
        worst = max(worst, lhs - rhs)
print(f"  max over programs and s of rho_s - rho_1/2^(2min(s,1-s)) = {worst:.3e} (must be <= 0)")
n = 6
maxerr = 0.0
for p in nonE:
    for s in [0.25, 0.5, 2 / 3, 0.8]:
        e = 0.0
        for cnt in compositions(n):
            ll = loglik(p, cnt) - sum(c * log2(q) for c, q in zip(cnt, [0.9, 0.1, 0.2, 0.8]))
            if ll > float("-inf"):
                e += exp(logpmf(cnt, n)) * 2.0 ** (s * ll)
        maxerr = max(maxerr, abs(e - rho(p, s) ** n))
print(f"  max |E Lambda_6^s - rho_s^6| over non-E programs, s in {{.25,.5,2/3,.8}} = {maxerr:.2e}")

print("\n" + "=" * 78)
print("(C) posterior: exact E[Pi(E|D_n)], E[Pi(E0|D_n)]; limits 1 and w")
for lam in [1.0, 1.5, 2.0]:
    w = 2.0 ** (-5 * lam) / (2.0 ** (-5 * lam) + 2.0 ** (-7 * lam))
    wt = 2.0 ** -5 / (2.0 ** -5 + 2.0 ** -7)
    line = f"  lambda={lam}: w_lambda={w:.4f}; tempered (eta=1/lambda) limit w_1={wt:.4f}\n"
    for n in [5, 40, 160, 400]:
        pr = PMF[n]
        lw = np.stack([-lam * C[p][0] + LL[n][p] for p in C], axis=1)
        tw = np.stack([-C[p][0] + LL[n][p] / lam for p in C], axis=1)
        names = list(C)
        iE = [names.index(p) for p in E]; iS = names.index("t5")
        res = []
        for W in (lw, tw):
            mx = W.max(axis=1, keepdims=True); Q = np.exp2(W - mx); Z = Q.sum(axis=1)
            res.append((float((pr * Q[:, iE].sum(axis=1) / Z).sum()), float((pr * Q[:, iS] / Z).sum())))
        (eE, eS), (tE, tS) = res
        line += f"    n={n:4d}  power: E[Pi(E)]={eE:.4f} E[Pi(E0)]={eS:.4f}   tempered: E[Pi(E)]={tE:.4f} E[Pi(E0)]={tS:.4f}\n"
    print(line, end="")

print("\n" + "=" * 78)
print("(D) lambda_n = c n: per-sample objective c*l + R(pi), R = E[-log nu_pi(y|x)] (bits)")
def risk(p):
    _, k = C[p]
    r = 0.0
    for x in "ab":
        for y in (0, 1):
            pr = MU[x] * nu_xy(x, y)
            if pr > 0:
                r += float("inf") if k[x][y] == 0 else -pr * log2(k[x][y])
    return r
shorter = [p for p in C if C[p][0] < LSTAR and p not in E]
cstar = min((risk(p) - risk("t5")) / (LSTAR - C[p][0]) for p in shorter)
for p in shorter:
    print(f"  {p:5s} l={C[p][0]}  D = R - R(t5) = {risk(p) - risk('t5'):.4f}  D/(l0-l) = {(risk(p) - risk('t5')) / (LSTAR - C[p][0]):.4f}")
print(f"  c* = min over shorter programs of D/(l0-l) = {cstar:.4f}: for c > c*, E0 is never the population minimiser")
for c in [0.05, 0.1, 0.2, 0.4, 0.6]:
    best = min(C, key=lambda p: c * C[p][0] + risk(p))
    vals = ", ".join(f"{p}:{c*C[p][0]+risk(p):.3f}" for p in ["t5", "s3", "coin", "near"])
    print(f"  c={c}: population minimiser = {best:5s}   ({vals})")
