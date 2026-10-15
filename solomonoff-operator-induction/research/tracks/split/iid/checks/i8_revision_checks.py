"""i8: checks added in the revision (notes-final Thm 4.1(iv'), Prop 3.4(b),(c), Prop 7.3(v), Cor 6.1(vi),
Remark 1.5, Lemma 8.1, Remark 8.2).  Seeded: numpy default_rng(8) (parts C, D, E); parts A, B, F, G are exact.

(A) Thm 4.1(iv'): the free-exponent bound  sum_{pi not in E} min_{0<s<=1} 2^{-s lambda (l(pi)-l0)} rho_s(pi)^n
    against the exact P[set of lambda-MAPs != E0] and the Renyi bound (s = 1/lambda), in the class of i1
    (exact enumeration over count vectors; two inputs; fresh labels per query).
(B) Prop 3.4: lambda_n = c n in the same class.  Exact P[set of cn-MAPs = E0] for c below and above
    c* = min_{l(pi) < l0} D(pi)/(l0 - l(pi)) = 0.1348, and the population minimiser set A_c of c l + R.
(C) Prop 7.3(v): two KL-projections (Bern(1/4), l=2; Bern(3/4), l=5) under fair-coin labels; schedules
    lambda_n in {2, sqrt(n), n^0.6, n^0.75, n/ln n}; 20 runs of 2*10^6 samples each: runs in which the longer
    projection is a lambda_n-MAP at some n > 10^5, and the last such n.  (Independent of referee B's rB5.)
(D) Cor 6.1(vi): frozen noise on the full table in the class of i4 (d = 6, 64 inputs, p = 1/8): Monte Carlo
    over 200000 tables of P[the lambda-MAP is not the truth (a*, 1/8)] and the selected rates, for
    lambda in {1, 1.5, 2, 4}; the exact contribution of the programs (a*, q) and the coin, which depends only on
    the number K ~ Bin(64, 1/8) of flipped inputs; and the proved lower bound (7/8)^64.
(E) Remark 1.5: the order of first appearance of i.i.d. uniform draws from a finite set is a uniformly random
    ordering (sampling without replacement).  X0 = {0,1,2,3}, 120000 runs, chi-square against uniform.
(F) Lemma 8.1(i),(ii) in the class of i1, exactly, at fixed n: P[some pi has L(pi) - S_n <= 2 log2(e) n Hel(pi)
    - 2 l(pi) - 2 log2(1/eps)] <= eps, and P[some pi has L(pi) - S_n <= -l(pi) - log2(1/eps)] <= eps.
(G) Lemma 8.1(iii) / Remark 8.2: in C_{k,M} at n = M - 5, a consistent parity gives the right-side excess
    rho(l0) - rho(alpha) - (alpha - l0) = k - 7 at alpha = M + 2; its probability, from the closed-form rank law.
"""
import math
from math import comb, log2, sqrt

import numpy as np
from scipy.special import gammaln

rng = np.random.default_rng(8)
LOG2E = 1 / math.log(2)

# ---------------------------------------------------------------- the class of i1
MU = {"a": 0.5, "b": 0.5}
NU = {"a": (0.9, 0.1), "b": (0.2, 0.8)}                 # nu(0|x), nu(1|x)
C = {
    "t5":   (5, {"a": (0.9, 0.1), "b": (0.2, 0.8)}),
    "t7":   (7, {"a": (0.9, 0.1), "b": (0.2, 0.8)}),
    "coin": (2, {"a": (0.5, 0.5), "b": (0.5, 0.5)}),
    "s3":   (3, {"a": (0.9, 0.1), "b": (0.9, 0.1)}),
    "near": (4, {"a": (0.9, 0.1), "b": (0.6, 0.4)}),
    "far6": (6, {"a": (0.5, 0.5), "b": (0.2, 0.8)}),
    "det":  (3, {"a": (1.0, 0.0), "b": (0.0, 1.0)}),
    "sub6": (6, {"a": (0.9, 0.1), "b": (0.1, 0.6)}),
}
E = {"t5", "t7"}
L0 = 5
assert sum(2.0 ** -l for l, _ in C.values()) <= 1
names = list(C)
CELLS = [("a", 0), ("a", 1), ("b", 0), ("b", 1)]
PCELL = np.array([MU[x] * NU[x][y] for x, y in CELLS])


def logk(name):
    """log2 nu_pi(y|x) per cell (-inf where 0)."""
    with np.errstate(divide="ignore"):
        return np.array([np.log2(C[name][1][x][y]) for x, y in CELLS])


LOGK = {nm: logk(nm) for nm in names}


def rho(name, s):
    tot = 0.0
    for x in ("a", "b"):
        for y in (0, 1):
            if NU[x][y] > 0:
                tot += MU[x] * NU[x][y] ** (1 - s) * C[name][1][x][y] ** s
    return tot


def hel(name):
    return 1 - rho(name, 0.5)


def count_vectors(n):
    """All (c0,c1,c2,c3) >= 0 with sum n, and their multinomial probabilities."""
    a = np.arange(n + 1)
    c0, c1, c2 = np.meshgrid(a, a, a, indexing="ij")
    c0, c1, c2 = c0.ravel(), c1.ravel(), c2.ravel()
    keep = c0 + c1 + c2 <= n
    c0, c1, c2 = c0[keep], c1[keep], c2[keep]
    c3 = n - c0 - c1 - c2
    cnt = np.stack([c0, c1, c2, c3], axis=1).astype(np.float64)
    logp = gammaln(n + 1) - gammaln(cnt + 1).sum(1) + (cnt * np.log(PCELL)).sum(1)
    return cnt, np.exp(logp)


def loglik(cnt, name):
    lk = LOGK[name]
    out = np.zeros(cnt.shape[0])
    for j in range(4):
        term = np.where(cnt[:, j] > 0, cnt[:, j] * lk[j], 0.0)
        out = out + term
    return out                                            # -inf where a zero-probability cell is hit


print("=" * 78)
print("(A) Thm 4.1(iv'): exact <= free-exponent bound <= Renyi bound (class of i1)")
SGRID = np.concatenate([np.linspace(0.01, 1.0, 100)])
viol = 0
for lam in (1.0, 1.5, 2.0, 3.0):
    for n in (20, 40, 80, 160):
        cnt, p = count_vectors(n)
        J = {nm: lam * C[nm][0] - loglik(cnt, nm) for nm in names}
        Jt = J["t5"]
        bad = np.zeros(len(p), bool)
        for nm in names:
            if nm in E:
                continue
            bad |= J[nm] <= Jt + 1e-9
        exact = float(p[bad].sum())
        BR = sum(2.0 ** (L0 - C[nm][0]) * rho(nm, 1 / lam) ** n for nm in names if nm not in E)
        BF = 0.0
        for nm in names:
            if nm in E:
                continue
            grid = np.unique(np.concatenate([SGRID, [1 / lam]]))
            vals = [2.0 ** (-s * lam * (C[nm][0] - L0)) * rho(nm, s) ** n for s in grid]
            BF += min(vals)
        ok = exact <= BF * (1 + 1e-9) and BF <= BR * (1 + 1e-9)
        viol += not ok
        print(f"  lambda={lam:3.1f} n={n:4d}: exact {exact:.3e}   free-exponent {BF:.3e}   Renyi {BR:.3e}   ratio Renyi/free {BR / BF:6.2f}")
print(f"  order violations: {viol} (must be 0)")

print("=" * 78)
print("(B) Prop 3.4: lambda_n = c n.  Exact P[set of cn-MAPs = E0] (class of i1)")
H = -sum(MU[x] * sum(q * log2(q) for q in NU[x] if q > 0) for x in ("a", "b"))


def risk(nm):
    r = 0.0
    for (x, y), pc in zip(CELLS, PCELL):
        if pc > 0:
            q = C[nm][1][x][y]
            r += pc * (-log2(q) if q > 0 else math.inf)
    return r


Dv = {nm: risk(nm) - H for nm in names}
cstar = min(Dv[nm] / (L0 - C[nm][0]) for nm in names if C[nm][0] < L0)
print(f"  c* = {cstar:.4f}")
for c in (0.05, 0.10, 0.12, 0.15, 0.20, 0.40):
    Jc = {nm: c * C[nm][0] + risk(nm) for nm in names}
    mn = min(Jc.values())
    Ac = sorted(nm for nm in names if Jc[nm] <= mn + 1e-12)
    row = []
    for n in (25, 50, 100, 200, 400):
        cnt, p = count_vectors(n)
        J = {nm: c * n * C[nm][0] - loglik(cnt, nm) for nm in names}
        Jt = J["t5"]
        good = np.ones(len(p), bool)
        for nm in names:
            if nm == "t5":
                continue
            good &= J[nm] > Jt + 1e-9
        row.append(float(p[good].sum()))
    print(f"  c={c:.2f} (c {'<' if c < cstar else '>'} c*): population minimisers A_c = {Ac};  "
          f"P[cn-MAPs = E0] at n=25,50,100,200,400: " + ", ".join(f"{v:.4f}" for v in row))

print("=" * 78)
print("(C) Prop 7.3(v): two KL-projections under schedules (20 runs x 2*10^6 samples)")
N = 2 * 10 ** 6
nn = np.arange(1, N + 1, dtype=np.float64)
SCHED = {"2": np.full(N, 2.0), "sqrt(n)": np.sqrt(nn), "n^0.6": nn ** 0.6, "n^0.75": nn ** 0.75,
         "n/ln n": nn / np.log(np.maximum(nn, 2.0))}
late = {s: 0 for s in SCHED}
lastn = {s: 0 for s in SCHED}
for run in range(20):
    walk = np.cumsum(2 * rng.integers(0, 2, size=N, dtype=np.int8).astype(np.int64) - 1)
    S = walk * log2(3)                                   # log2 nu_{3/4}(h_n) - log2 nu_{1/4}(h_n)
    for s, lamn in SCHED.items():
        is2 = S >= 3 * lamn                              # Bern(3/4) (l=5) is a MAP iff S_n >= lambda_n (5-2)
        idx = np.flatnonzero(is2)
        if len(idx):
            lastn[s] = max(lastn[s], int(idx[-1]) + 1)
            late[s] += int(idx[-1]) + 1 > 10 ** 5
for s in SCHED:
    print(f"  lambda_n = {s:8s}: runs with the longer projection a MAP at some n > 10^5: {late[s]:2d}/20;"
          f"  last such n over all runs: {lastn[s]}")

print("=" * 78)
print("(D) Cor 6.1(vi): frozen noise on the full table, class of i4 (d = 6, p = 1/8, truth (a*, 1/8), l0 = 10)")
d = 6
X = np.arange(2 ** d)
RATES = [0.0, 1 / 4, 1 / 8, 1 / 16, 3 / 16, 5 / 16, 3 / 8, 7 / 16]
LRATE = [2, 2, 3, 4, 5, 6, 7, 7]
astar, pstar = 0b101101, 1 / 8
PAR = np.array([[bin(a & x).count("1") & 1 for x in X] for a in X], dtype=np.int8)
lens = np.array([[1 + d + LRATE[qi] for qi in range(len(RATES))] for a in X], float)   # (64, 8)
assert 64 * sum(2.0 ** -(1 + d + l) for l in LRATE) + 2 ** -2 <= 1
iq = RATES.index(pstar)
with np.errstate(divide="ignore"):
    LQ = np.array([-log2(q) if q > 0 else np.inf for q in RATES])
    L1Q = np.array([-log2(1 - q) for q in RATES])
NX = 2 ** d


def fits(mis):
    """mis: (..., 64) mismatch counts; returns fits (..., 64, 8) in bits."""
    m = mis[..., None].astype(float)
    with np.errstate(invalid="ignore"):
        f = np.where(m > 0, m * LQ, 0.0) + (NX - m) * L1Q
    return f


print("  exact part (programs (a*, q) and the coin; depends only on K):")
for lam in (1.0, 1.5, 2.0, 4.0):
    pfail = 0.0
    for K in range(NX + 1):
        f = fits(np.array([K]))[0]                       # (8,)
        J = lam * (1 + d + np.array(LRATE)) + f
        Jt = J[iq]
        others = np.delete(J, iq)
        Jcoin = lam * 2 + NX
        if np.any(others <= Jt + 1e-9) or Jcoin <= Jt + 1e-9:
            pfail += comb(NX, K) * pstar ** K * (1 - pstar) ** (NX - K)
    print(f"    lambda={lam:3.1f}: P[some (a*, q != 1/8) or the coin has J <= J(truth)] = {pfail:.4f}")
print(f"  proved lower bound for every lambda (no flip; (a*, 0) has length 9 < 10): (7/8)^64 = {(7 / 8) ** 64:.3e}")
print("  Monte Carlo over all 513 programs (200000 tables, seed 8):")
B = 10000
fstar = PAR[astar]
res = {lam: {"fail": 0, "rates": {}} for lam in (1.0, 1.5, 2.0, 4.0)}
for _ in range(20):
    flips = (rng.random((B, NX)) < pstar).astype(np.int8)
    F = fstar[None, :] ^ flips
    mis = (PAR[None, :, :] != F[:, None, :]).sum(-1)     # (B, 64)
    f = fits(mis)                                        # (B, 64, 8)
    for lam in res:
        J = lam * lens[None] + f
        Jflat = J.reshape(B, -1)
        Jt = J[:, astar, iq]
        Jcoin = lam * 2 + NX
        Jflat_others = Jflat.copy()
        Jflat_others[:, astar * len(RATES) + iq] = np.inf
        fail = (Jflat_others.min(1) <= Jt + 1e-9) | (Jcoin <= Jt + 1e-9)
        res[lam]["fail"] += int(fail.sum())
        best = np.argmin(Jflat, axis=1)
        coinwin = Jcoin < Jflat.min(1)
        for b in np.flatnonzero(fail):
            if coinwin[b]:
                key = "coin"
            else:
                a, qi = divmod(int(best[b]), len(RATES))
                key = f"rate {RATES[qi]:.4g}" + ("" if a == astar else " (wrong parity)")
            res[lam]["rates"][key] = res[lam]["rates"].get(key, 0) + 1
TOT = 20 * B
for lam in res:
    se = sqrt(res[lam]["fail"] / TOT * (1 - res[lam]["fail"] / TOT) / TOT)
    top = sorted(res[lam]["rates"].items(), key=lambda kv: -kv[1])[:4]
    print(f"    lambda={lam:3.1f}: P[frozen lambda-MAP != truth] = {res[lam]['fail'] / TOT:.4f} (se {se:.4f});"
          f" selected instead: " + ", ".join(f"{k}: {v / TOT:.4f}" for k, v in top))

print("=" * 78)
print("(E) Remark 1.5: first-appearance order of i.i.d. uniform draws from {0,1,2,3}")
R = 120000
counts = {}
for _ in range(R):
    seen = []
    while len(seen) < 4:
        x = int(rng.integers(0, 4))
        if x not in seen:
            seen.append(x)
    counts[tuple(seen)] = counts.get(tuple(seen), 0) + 1
exp_ = R / 24
chi2 = sum((v - exp_) ** 2 / exp_ for v in counts.values()) + (24 - len(counts)) * exp_
from scipy.stats import chi2 as CHI2
print(f"  orderings seen: {len(counts)}/24; chi-square = {chi2:.1f} on 23 df; p-value = {CHI2.sf(chi2, 23):.3f}")

print("=" * 78)
print("(F) Lemma 8.1(i),(ii) exactly in the class of i1, per-query data")
for n in (25, 50, 100, 200):
    cnt, p = count_vectors(n)
    llnu = loglik(cnt, "t5")                             # = log2 nu(h_n) on the support
    for eps in (0.1, 0.01):
        badH = np.zeros(len(p), bool)
        badV = np.zeros(len(p), bool)
        for nm in names:
            Lm = -loglik(cnt, nm)
            diff = Lm - (-llnu)                          # L(pi) - S_n
            aH = 2 * LOG2E * n * hel(nm) - 2 * C[nm][0] - 2 * log2(1 / eps)
            badH |= diff <= aH
            badV |= diff <= -C[nm][0] - log2(1 / eps)
        print(f"  n={n:3d} eps={eps:4.2f}: P[Hellinger event fails] = {p[badH].sum():.2e}   P[Ville event fails] = {p[badV].sum():.2e}   (both must be <= eps)")

print("=" * 78)
print("(G) the right side of the sample kink needs l0 + delta*: C_{k,M} at n = M - 5")
QT = np.zeros(401)
for a in range(1, 401):
    QT[a] = QT[a - 1] + math.log2(1.0 - 2.0 ** (-a))


def p_span(n, m, W=48):
    tot = 0.0
    for j in range(W):
        r = min(n, m) - j
        if r < 0:
            break
        q = lambda v: QT[min(v, 400)]
        tot += 2.0 ** (-(n - r) * (m - r) + q(n) - q(n - r) + q(m) - q(m - r) - q(r) + (r - n))
    return tot


for k in (16, 24, 32):
    for M in (k + 6, k + 20, 4 * k):
        n = M - 5
        pc = p_span(n, M)
        print(f"  k={k} M={M} n={n}: P[a parity is consistent] = {pc:.4f};  on that event the excess is k - 7 = {k - 7} bits,"
              f" so P[excess > delta*] >= {pc - 2.0 ** (-(k - 7)):.4f}")
