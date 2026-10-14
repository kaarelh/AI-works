"""[Revision copy of checks/r4_*.py for notes-final.md: identical except that every code length
ceil(log2 C(N, t)) is computed exactly in integers (function clc), fixing the floating-point bug B9 of
referee B; docstring typos corrected.]

r4: behavioural non-identifiability, exact finite-n selection with environment-coupled coins, and partial
fill-ins per query against frozen labels (notes Proposition 3.1, Example 3.2, Corollary 4.8, Proposition 4.9(a),
Remark 3.4).  (A) seeded default_rng(41); (B) exact enumeration; (C) exact formula plus seeded default_rng(43).

(A) Two programs with the same kernel on the support.  Inputs w uniform on {0,1}^6.  The "human" computes
    y = parity(all bits of w) XOR Bern(1/8) by a long-winded procedure (length 40); the "alien" computes
    y = parity(first 6 bits of w) XOR Bern(1/8) directly (length 20).  On {0,1}^6 the kernels coincide; on
    inputs of length 7 (never queried) they differ.  Fits are equal at every n; the lambda-MAP is the alien
    for every lambda >= 1; the power-posterior odds are 2^(-lambda*20) at every n.

(B) The coin-flipping human with environment-driven coins, exactly.  Inputs z uniform on 16 cells; the human
    says y = 1 with probability 1/8 (private coin); in the world y = 1_S(z), |S| = 2.  Class: coin (l = 2);
    H(q): y ~ Bern(q), q in {j/8} (l = 5); S-cell aliens A(q,T): y = 1 on the cells of T, Bern(q) elsewhere
    (l = 5 + gamma(t) + ceil(log2 C(16, t))).  Population window (s_plus, s_minus) computed below.
    Exact P_n[MAP = human H(1/8)] and P_n[MAP = full memoriser] by enumerating all count vectors of the two
    S-cells (the other cells enter only through their total).  Twin-world reading: in the world W' whose human
    IS the deterministic program y = 1_S(z), the data law is identical, so P_W'[copy of W''s human] equals
    P_W[MAP has W''s kernel], and the two success probabilities sum to at most 1.

(C) "The sampler with some bits specified": Paper 2's class (mu uniform on {0..9}; nu = Bern(1/64), l = 5;
    e_j = nu except e_j(1|j) = 1, l = 9; lambda < 1.5).  Frozen labels: some e_j is eventually the MAP with
    probability exactly 1 - (63/64)^10.  Per query: e_j has finite likelihood only while every query at j
    returned 1, so P_n[some e_j is a lambda-MAP] <= 10 ((9/10 + 1/640)^n - (9/10)^n) -> 0.
"""
import itertools
from math import factorial
from math import comb, lgamma, log, log2, floor, ceil
import numpy as np

LN2 = log(2.0)


def lc(n, k):
    return (lgamma(n + 1) - lgamma(k + 1) - lgamma(n - k + 1)) / LN2


def clc(n, k):
    """Exact ceil(log2 C(n, k)) in integers (revision fix of referee B's B9: ceil of the float lc
    is one bit too long when C(n, k) is a power of two)."""
    return (comb(n, k) - 1).bit_length()


def H2(p):
    return 0.0 if p <= 0 or p >= 1 else -p * log2(p) - (1 - p) * log2(1 - p)


# ---------------------------------------------------------------- (A)
print("(A) Behaviourally equivalent programs of different lengths")
rng = np.random.default_rng(41)
d, q = 6, 1 / 8
lH, lA = 40, 20
for n in (10, 100, 1000, 10000):
    w = rng.integers(0, 2, size=(n, d))
    y = (w.sum(axis=1) % 2) ^ (rng.random(n) < q)
    ph = w.sum(axis=1) % 2                     # human's mode: parity of all bits (here all bits = first 6)
    pa = w[:, :d].sum(axis=1) % 2              # alien's mode: parity of the first 6 bits
    LH = np.where(y == ph, -log2(1 - q), -log2(q)).sum()
    LA = np.where(y == pa, -log2(1 - q), -log2(q)).sum()
    assert LH == LA
    for lam in (1.0, 2.0):
        JH, JA = lam * lH + LH, lam * lA + LA
        print(f"  n={n:6d} lambda={lam}: L(human) = L(alien) = {LH:9.2f};  J(human) - J(alien) = {JH-JA:5.1f}"
              f" = lambda*20;  log2 posterior odds human:alien = {-(JH-JA):.1f}")
x7 = np.array([1, 0, 0, 0, 0, 0, 1])           # an input of length 7, outside the support
print(f"  off the support, input {x7.tolist()}: human predicts mode {x7.sum() % 2}, alien predicts mode"
      f" {x7[:d].sum() % 2}  (they differ; the MAP's extrapolation is the alien's)")

# ---------------------------------------------------------------- (B)
print("\n(B) Coin-flipping human, coins driven by z (16 cells, |S| = 2), exact")
NC, SN, QB = 16, 2, [j / 8 for j in range(8)]
p = SN / NC


def gam(t):
    return 2 * floor(log2(t + 1)) + 1


LENA = [5] + [5 + gam(t) + clc(NC, t) for t in range(1, SN + 1)]


def CEs(D, A, qq):
    with np.errstate(divide="ignore", invalid="ignore"):
        v = D * (-np.log2(qq)) + A * (-np.log2(1 - qq))
    return np.where(np.isnan(v), 0.0, v)


# population hull
pts = [(2, 1.0, "coin")]
for qq in QB:
    pts.append((5, (p * -log2(qq) if qq > 0 else float("inf")) + (1 - p) * -log2(1 - qq) if qq > 0
                else float("inf"), f"H({qq})"))
alien_pop = []
for t in range(1, SN + 1):
    pt = (SN - t) / (NC - t)
    best = min(((1 - t / NC) * ((pt * -log2(qq) if pt > 0 else 0.0) + (1 - pt) * -log2(1 - qq)) if qq > 0
                else ((1 - t / NC) * 0.0 if pt == 0 else float("inf"))) for qq in QB)
    alien_pop.append((LENA[t], best, f"A(t={t})"))
RH = H2(p)
sp = max((RH - r) / (l - 5) for (l, r, _) in alien_pop)
sm = (1 - RH) / (5 - 2)
print(f"  human: l = 5, R = H(1/8) = {RH:.4f}; aliens (l, R): "
      + ", ".join(f"({l}, {r:.4f})" for (l, r, _) in alien_pop))
print(f"  population window (s_plus, s_minus) = ({sp:.4f}, {sm:.4f})")


_TUPLES = {}


def sorted_tuples(n):
    """All sorted count vectors k1 >= ... >= k_SN >= 0 (SN = |S| = 2 here) with sum <= n, with the number of
    their distinct orderings."""
    if n not in _TUPLES:
        K = np.array([c[::-1] for c in itertools.combinations_with_replacement(range(n + 1), SN)
                      if sum(c) <= n], np.int64)
        mult = np.array([factorial(SN) // np.prod([factorial(list(r).count(v)) for v in set(r)]) for r in K],
                        float)
        _TUPLES[n] = (K, mult)
    return _TUPLES[n]


def exact_probs(n, lam):
    """Exact P[MAP = human H(p)], P[MAP = H(other q)], P[MAP = alien with t cells], P[coin]."""
    K, mult = sorted_tuples(n)
    sk = K.sum(axis=1)
    rest = n - sk
    lg = np.vectorize(lgamma)
    logp = (lgamma(n + 1) - lg(K + 1).sum(axis=1) - lg(rest + 1) + sk * log(1 / NC)
            + rest * log((NC - SN) / NC))
    prob = mult * np.exp(logp)
    QQ = np.array(QB)
    cum = np.concatenate([np.zeros((len(K), 1), np.int64), np.cumsum(K, axis=1)], axis=1)   # K sorted desc
    nhit = (K > 0).sum(axis=1)
    bestJ = np.full(len(K), 2 * lam + float(n))
    label = np.full(len(K), "coin", dtype=object)
    for t in range(SN + 1):
        ok = nhit >= t                               # t cells can be memorised only if t S-cells were hit
        v = CEs((sk - cum[:, t])[:, None], rest[:, None], QQ[None, :])
        j = np.argmin(v, axis=1)
        J = lam * LENA[t] + v[np.arange(len(K)), j]
        better = ok & (J < bestJ - 1e-9)
        bestJ = np.where(better, J, bestJ)
        if t == 0:
            lab = np.where(QQ[j] == p, "human", "H(other q)")
        else:
            lab = np.full(len(K), f"alien t={t}", dtype=object)
        label = np.where(better, lab, label)
    out = {}
    for lab in np.unique(label):
        out[str(lab)] = float(prob[label == lab].sum())
    return out


print("  exact selection probabilities (sum over all count vectors; 'alien t=2' = full memoriser = the kernel of")
print("  the twin world's human):")
for c in (0.03, sp * 1.05, (sp * sm) ** 0.5, sm * 0.95, 0.25):
    for n in (16, 64, 256, 1024):
        pr = exact_probs(n, c * n)
        tot = sum(pr.values())
        txt = ", ".join(f"{k}: {v:.4f}" for k, v in sorted(pr.items(), key=lambda kv: -kv[1]))
        print(f"    c={c:.4f} n={n:3d}: {txt}   (total {tot:.6f})")
for lam in (2.0,):
    for n in (16, 64, 256, 1024):
        pr = exact_probs(n, lam)
        txt = ", ".join(f"{k}: {v:.4f}" for k, v in sorted(pr.items(), key=lambda kv: -kv[1]))
        print(f"    lambda={lam} n={n:3d}: {txt}")

# ---------------------------------------------------------------- (C)
print("\n(C) Partial fill-ins ('the sampler with some bits specified'), Paper 2's class, lambda = 1.2")
print(f"  frozen labels: P[some e_j is eventually the MAP] = 1 - (63/64)^10 = {1 - (63/64)**10:.4f}")
for n in (10, 50, 100, 200, 400):
    ub = 10 * ((0.9 + 1 / 640) ** n - 0.9 ** n)
    print(f"  per query, n={n:4d}: P[some e_j is a lambda-MAP] <= {ub:.3e}")
rng = np.random.default_rng(43)
runs, n = 20000, 400
last = np.zeros(runs, int)
for r in range(runs):
    x = rng.integers(0, 10, n)
    y = rng.random(n) < 1 / 64
    # e_j beats nu at time i iff every query at j up to i returned 1 and at least one did (6k > 4*1.2)
    alive = np.ones(10, bool)
    cnt = np.zeros(10, int)
    for i in range(n):
        j = x[i]
        if alive[j]:
            if y[i]:
                cnt[j] += 1
            else:
                alive[j] = False
        if (alive & (cnt >= 1)).any():
            last[r] = i + 1
print(f"  per query, simulation ({runs} runs, n = {n}): fraction of runs in which some e_j is a MAP at some"
      f" time = {np.mean(last > 0):.4f}; at time > 100: {np.mean(last > 100):.4f}; at time > 300:"
      f" {np.mean(last > 300):.4f}; latest such time over all runs = {last.max()}")
