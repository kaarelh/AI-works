"""rA_checks: referee A (proofs) probes of kink/notes.md.

(1) Cor 5.7 needs a non-atomic input law; on Paper 2's countable X = {0,1}^* every law is atomic.
    Two-program class, Kraft sum 1: pi* = fair coin (length 1), pi' = fair coin except label 0
    with probability 1 at the heaviest atom x1 (length 1). mu = geometric on inputs x1, x2, ...
    (a) frozen noise (one label per distinct input): exact probability that pi' beats pi* for all
        large n is 1/2 (pi' is non-equivalent, so Cor 5.7(c) fails);
    (b) per-query fresh noise: simulated; log2 Lambda_n(pi') -> -infinity, so pi* wins eventually.
(2) Thm 3.2(d) without tau < sigma: points (0,2),(1,1),(2,0); the middle point is a zero-window
    (1,1)-kink and is not a hull vertex.
(3) The sentence after Prop 3.5 ("lambda-MAPs for lambda > 1 stay below l_U + (l_U+kappa0)/eps"):
    a two-point configuration satisfying (Dom) with a lambda-MAP longer than that, lambda in (1, 1+eps).
(4) Cor 4.3 / k4(d): the constant 0.0188 for min (f_2 - H) on (0, 1/4].
(5) Summary item 4: the unconditional steepness bound (2 log e n gamma_- - 2 log(1/eps))/l0 versus
    Thm 5.4(i)'s profile minimum when A < 2 l0.
(6) Prop 4.2: is {lambda : C_t0(lambda)} an interval? Fine log-scan using k4's own Inst class.
(7) Lemma 5.1 (wor): E prod a(x_i) without replacement <= (E a)^n, exact enumeration on random
    small populations (some a(x) = 0 included).
(8) Prop 5.8: P[pi* is a lambda-MAP] <= (n Kbar + log e/e)/(lambda Delta), exact binomial,
    Bernoulli pairs as in k5.
(9) Thm 3.4, independent brute force (own code, not k1's): for random point sets and random
    tau < sigma, the extreme MAP lengths over (tau, sigma) equal the lengths of the hull vertices
    alpha_i, alpha_j named in the theorem.
(10) Kraft sum of k3's program class, from k3's code lengths (3-bit tag, families F0-F4).
Deterministic or seeded (random.Random(7), numpy default_rng(7)).
"""
import math
import random
from fractions import Fraction as Fr
from itertools import combinations

import numpy as np
from scipy.stats import binom

LOG2E = math.log2(math.e)
print("=" * 96)

# ---------------------------------------------------------------- (1)
print("(1) Cor 5.7 under an atomic input law")
r = Fr(1, 2)  # mu(x_k) = r^k, k >= 1
mu1 = r
# frozen: x1 appears eventually a.s.; its label is drawn once; y(x1) = 0 w.p. 1/2.
# Then Lambda_n(pi') = nu_pi'(D)/nu(D) = 1/(1/2) = 2 for all later n (other inputs: equal factors).
print("  (a) frozen noise: P[pi' is the unique lambda-MAP for all large n, every lambda] = "
      "P[x1 appears] * P[y(x1) = 0] = 1 * 1/2 = 0.5;")
print("      pi' is non-equivalent: Hel_mu(pi') = mu(x1) * (1 - sqrt(1/2)) =", float(mu1) * (1 - math.sqrt(0.5)))
rng = np.random.default_rng(7)
runs, n = 2000, 4000
ends_frozen, ends_fresh = [], []
for _ in range(runs):
    xs = rng.geometric(0.5, size=n)  # inputs 1, 2, ... with P(k) = 2^-k
    ys = rng.integers(0, 2, size=n)  # fresh labels per query
    # fresh (per-query) likelihood ratio of pi' to pi*: factor 2 at queries of x1 with y = 0, 0 if y = 1
    at1 = xs == 1
    fresh = -math.inf if np.any(ys[at1] == 1) else float(np.sum(at1))  # log2 Lambda_n
    # frozen: the label of x1 is the label at its first query
    first = np.argmax(at1) if np.any(at1) else None
    frozen = (1.0 if ys[first] == 0 else -math.inf) if first is not None else 0.0
    ends_frozen.append(frozen)
    ends_fresh.append(fresh)
ef, eq = np.array(ends_frozen), np.array(ends_fresh)
print(f"  simulated {runs} runs of n = {n}: frozen  P[log2 Lambda_n(pi') = +1, pi' wins] = {np.mean(ef == 1.0):.3f}")
print(f"                                   fresh   P[log2 Lambda_n(pi') > -inf]           = {np.mean(eq > -math.inf):.3g}")
print("  So Cor 5.7(c) is false for atomic mu with frozen noise; with per-query noise pi' dies at the first")
print("  label 1 at x1. Non-atomic mu does not exist on a countable X.")

# ---------------------------------------------------------------- (2)
print("=" * 96)
print("(2) Thm 3.2(d) with tau = sigma")
pts = [(0, Fr(2)), (1, Fr(1)), (2, Fr(0))]
a0, L0 = 1, Fr(1)
sig = min((L - L0) / (a0 - l) for l, L in pts if l < a0)
tau = max((L0 - L) / (l - a0) for l, L in pts if l > a0)
print(f"  middle point (1,1): zero-window left steepness {sig}, right flatness {tau}; it is a (1,1)-kink.")
lams = [Fr(1, 2), Fr(1), Fr(3, 2)]
for lam in lams:
    J = [lam * l + L for l, L in pts]
    m = min(J)
    print(f"  lambda={str(lam):>4}: MAP points {[pts[i] for i in range(3) if J[i] == m]}")
print("  (1,1) is a MAP point only at lambda = 1, together with both ends: it is not a vertex.")

# ---------------------------------------------------------------- (3)
print("=" * 96)
print("(3) After Prop 3.5: 'lambda-MAPs for lambda > 1 stay below l_U + (l_U+kappa0)/eps'")
U, A = (2, Fr(15)), (5, Fr(10))
k0 = 0
dom_ok = all(U[1] <= L + l + k0 for l, L in [U, A])
eps = 1
lam = Fr(3, 2)
JU, JA = lam * U[0] + U[1], lam * A[0] + A[1]
print(f"  (Dom) holds with kappa0 = 0: {dom_ok}; eps = 1, so the stated cap is {U[0] + (U[0] + k0) / eps}")
print(f"  lambda = 3/2: J(U) = {float(JU)}, J(A) = {float(JA)}; the lambda-MAP is A, of length {A[0]} > 4")
print(f"  correct cap (absorption): (lambda l_U + kappa0)/(lambda-1) = {float((lam * U[0] + k0) / (lam - 1))}; "
      "it is below l_U + (l_U+kappa0)/eps only for lambda >= 1 + eps")

# ---------------------------------------------------------------- (4)
print("=" * 96)
print("(4) The constant 0.0188 in Cor 4.3")


def H(q):
    return 0.0 if q in (0, 1) else -(q * math.log2(q) + (1 - q) * math.log2(1 - q))


f2 = lambda q: 1 - math.log2(1 + (1 - 2 * q) / 4)
print(f"  f_2(1/4) - H(1/4) = {f2(0.25) - H(0.25):.7f}  (< 0.0188)")
cells = 100000
worst = min(f2(k * 0.25 / cells) - H((k + 1) * 0.25 / cells) for k in range(cells))
print(f"  cell bound over {cells} cells: {worst:.7f}; k4 prints it as {worst:+.5f}")
grid = min(f2(q) - H(q) for q in np.linspace(1e-6, 0.25, 200001))
print(f"  grid minimum of f_2 - H on (0, 1/4]: {grid:.7f}; the true minimum is at p = 1/4")

# ---------------------------------------------------------------- (5)
print("=" * 96)
print("(5) Summary item 4: steepness >= (2 log e n gamma_- - 2 log(1/eps))/l0 without the condition A >= 2 l0")
l0, A = 10, 10.0  # A := 2 log e n gamma_- - 2 log(1/eps), with gamma(l) = gamma_- at every l < l0
prof = min((A - 2 * l) / (l0 - l) for l in range(l0))
print(f"  l0 = {l0}, A = {A}: Thm 5.4(i)'s profile minimum = {prof:.2f}, the unconditional formula = {A / l0:.2f}")

# ---------------------------------------------------------------- (6)
print("=" * 96)
print("(6) Prop 4.2: interval structure of {lambda : C_t0(lambda)}, k4's own Inst class, fine log scan")
import os
src = open(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "checks", "k4_parity_numbers.py")).read()
src = src.split('print("=" * 100)\nprint("(a)')[0]
ns = {}
exec(compile(src, "k4_parity_numbers.py", "exec"), ns)
Inst = ns["Inst"]
for (d, p, kap, t0) in [(20, 1 / 16, 0, 1), (20, 15 / 64, 30, 2), (20, 7 / 32, 0, 2), (20, 1 / 8, 30, 2),
                        (30, 15 / 64, 30, 2)]:
    I = Inst(d, p, kap, 0)
    lo, hi = I.lam_range(t0)
    xs_ = np.exp(np.linspace(math.log(max(lo - 1, 1e-9) * 0.5), math.log(hi - 1) + 0.05, 6000))
    oks = [I.ok(t0, 1 + x) for x in xs_]
    runs_ = sum(1 for i in range(1, len(oks)) if oks[i] != oks[i - 1])
    print(f"  d={d} p={p:.4f} kappa={kap} t0={t0}: k4 range ({lo:.6g}, {hi:.4g}); "
          f"switches of C along 6000 points = {runs_} (2 means one interval)")

# ---------------------------------------------------------------- (7)
print("=" * 96)
print("(7) Lemma 5.1 (wor): E prod_{i<=n} a(x_i) without replacement <= (mean a)^n")
rr = random.Random(7)
worst_ratio, tests = 0.0, 0
for _ in range(300):
    M = rr.randint(2, 7)
    a = [0.0 if rr.random() < 0.15 else rr.random() for _ in range(M)]
    for nn in range(1, M + 1):
        wor = np.mean([np.prod([a[i] for i in c]) for c in combinations(range(M), nn)])
        wr = (sum(a) / M) ** nn
        tests += 1
        if wr > 0:
            worst_ratio = max(worst_ratio, wor / wr)
        else:
            assert wor == 0
print(f"  {tests} (population, n) cases; max ratio wor/wr = {worst_ratio:.6f} (must be <= 1)")

# ---------------------------------------------------------------- (8)
print("=" * 96)
print("(8) Prop 5.8: P[pi* (length l0) is a lambda-MAP against pi1 (length l0 - Delta)] <= (n Kbar + log e/e)/(lambda Delta)")


def KL(p, q):
    return p * math.log2(p / q) + (1 - p) * math.log2((1 - p) / (1 - q))


def p_map(n, p, q, Delta, lam):
    # pi* is a MAP iff L(pi1) - L(pi*) >= lam*Delta, L(pi1)-L(pi*) = k a + (n-k) b
    a, b = math.log2(p / q), math.log2((1 - p) / (1 - q))
    ks = np.arange(n + 1)
    X = ks * a + (n - ks) * b
    return float(np.sum(binom.pmf(ks, n, p)[X >= lam * Delta - 1e-12]))


viol, cnt, tight = 0, 0, math.inf
for (p, q) in [(1 / 8, 1 / 4), (1 / 8, 3 / 16), (1 / 4, 1 / 2), (0.1, 0.11), (0.3, 0.1)]:
    for Delta in [1, 3, 10]:
        for lam in [1.0, 1.5, 2, 8]:
            for n in [1, 2, 5, 10, 30, 100, 300, 1000, 3000]:
                bound = (n * KL(p, q) + LOG2E / math.e) / (lam * Delta)
                pm = p_map(n, p, q, Delta, lam)
                cnt += 1
                if pm > bound + 1e-12:
                    viol += 1
                if bound < 1:
                    tight = min(tight, bound - pm)
print(f"  {cnt} cases, violations: {viol}; least slack (bound - probability) where bound < 1: {tight:.4f}")

# ---------------------------------------------------------------- (9)
print("=" * 96)
print("(9) Thm 3.4, independent brute force")


def hull(points):
    """lower hull vertices of conv(points)+R^2_{>=0} (points: list of (l, L)), left to right, with slopes."""
    P = sorted(set(points))
    # Pareto: keep for each l the least L, then those with L below all shorter ones
    best = {}
    for l, L in P:
        best[l] = min(best.get(l, L), L)
    par, cur = [], None
    for l in sorted(best):
        if cur is None or best[l] < cur:
            par.append((l, best[l]))
            cur = best[l]
    V = []
    for pt in par:
        while len(V) >= 2:
            (x1, y1), (x2, y2) = V[-2], V[-1]
            if (y2 - y1) * (pt[0] - x1) >= (pt[1] - y1) * (x2 - x1):  # V[-1] not strictly below chord
                V.pop()
            else:
                break
        V.append(pt)
    sl = [Fr(V[i - 1][1] - V[i][1]) / (V[i][0] - V[i - 1][0]) for i in range(1, len(V))]
    return V, sl  # sl[i-1] = sigma_i


rr = random.Random(11)
checked, bad = 0, 0
for _ in range(400):
    k = rr.randint(2, 12)
    pts9 = [(rr.randint(0, 15), Fr(rr.randint(0, 60), rr.randint(1, 4))) for _ in range(k)]
    V, sl = hull(pts9)
    sigs = [math.inf] + [s for s in sl] + [Fr(0)]  # sigma_0 .. sigma_{q+1}
    q = len(V) - 1
    cand = sorted(set([Fr(0)] + sl + [Fr(rr.randint(0, 80), rr.randint(1, 8)) for _ in range(6)]))
    for tau_, sig_ in combinations(cand, 2):
        if not tau_ < sig_:
            continue
        i = next(ii for ii in range(q + 1) if sigs[ii + 1] < sig_ <= sigs[ii])
        j = next(jj for jj in range(q + 1) if sigs[jj + 1] <= tau_ < sigs[jj])
        # brute force over lambda in (tau, sigma): breakpoints inside, midpoints, and near the ends
        brk = sorted(set([s for s in sl if tau_ < s < sig_]))
        grid9 = brk + [tau_ + (sig_ - tau_) * Fr(m, 97) for m in range(1, 97)]
        grid9 += [tau_ + Fr(1, 10 ** 6), sig_ - Fr(1, 10 ** 6)]
        grid9 = [g for g in grid9 if tau_ < g < sig_ and g > 0]
        lens = []
        for lam in grid9:
            J = [lam * l + L for l, L in pts9]
            m = min(J)
            lens += [pts9[t][0] for t in range(len(pts9)) if J[t] == m]
        checked += 1
        if min(lens) != V[i][0] or max(lens) != V[j][0]:
            bad += 1
print(f"  {checked} (point set, tau, sigma) cases; mismatches with [alpha_i, alpha_j]: {bad}")
print("=" * 96)

# ---------------------------------------------------------------- (10)
print("(10) Kraft sum of k3's class")


def gam3(k):
    return 2 * int(math.floor(math.log2(k + 1))) + 1


d3, M3 = 16, 2 ** 16
rate = sum(2 ** (b - 1) * 2.0 ** -(1 + gam3(b) + b - 1) for b in range(1, 13))
fam = {"F0": 2 * 2.0 ** -2 + rate, "F1": 2.0 ** -1 + rate,
       "F2": sum(2.0 ** -gam3(v) * (2.0 ** -1 + rate) for v in range(1, d3 + 1)),
       "F3": sum(2.0 ** -gam3(j) * math.comb(M3, j) * 2.0 ** -math.ceil(
           (math.lgamma(M3 + 1) - math.lgamma(j + 1) - math.lgamma(M3 - j + 1)) / math.log(2)) * (2.0 ** -1 + rate)
                 for j in range(1, 40)),
       "F4": 2.0 ** -(gam3(d3) + M3)}
print("  per family (after the tag): " + ", ".join(f"{k} {v:.4f}" for k, v in fam.items()))
print(f"  total Kraft sum = {sum(fam.values()) / 8:.4f} (<= 1)")
print("=" * 96)

