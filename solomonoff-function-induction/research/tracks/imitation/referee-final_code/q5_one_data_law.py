#!/usr/bin/env python3
"""Referee check q5 (final referee of the imitation drafts, 2026-10-14).

Independent code; seeded with numpy.random.default_rng(9105).  Exact rational arithmetic (fractions) where it matters.

prop:imit:limits(a) (robust Prop 4.10(a2),(a1)):
 (A) the twin: in random feature-case worlds (several inputs per cell, random channel, |Sigma| in {2,3}), the world with
     Sigma' = {*}, rho'(*) = 1, h'(x,*) = h(x, beta(w)) has the same channel and exactly the same law of data pairs, and
     its person's kernel P* differs from nu_H at every input when |Sigma| >= 2 (and coincides with it when |Sigma| = 1);
 (B) N worlds with one data law and pairwise different persons, all built on one deterministic data table T in a
     4-cell feature world (rho = (3/4, 1/4) with each of its 4 couplings, and the twin);
     exhaustively over ALL deterministic procedures from samples of size n = 1 and over a large random set of
     procedures for n = 2, 3, the sum over worlds of Pr[procedure outputs a copy of that world's person] is at most 1,
     and the maximum is 1;
 (C) ties: persons with equal kernels but different response functions can have different data laws (the fair-coin
     person with h(x,b) = b against h(x,b) = 1 - b), and different couplings with the uniform coin law give one kernel;
 (D) in a latent-cause world P* is in general not the kernel of any person of def:imit:setting (its coin law would have
     to be the same at every input), so the twin of (a) is a feature-case construction, as the draft states.
"""
from fractions import Fraction as Fr
from itertools import product, combinations

import numpy as np

rng = np.random.default_rng(9105)


def data_law(W, mu, h, beta):
    """Exact law of (x, y): w uniform, x ~ mu(.|w), y = h(x, beta(w)).  mu: dict w -> dict x -> Fraction."""
    law = {}
    for w in range(W):
        for x, px in mu[w].items():
            y = h[(x, beta[w])]
            law[(x, y)] = law.get((x, y), Fr(0)) + Fr(1, W) * px
    return law


def kernel(rho, h, xs, Sigma):
    K = {}
    for x in xs:
        d = {}
        for b in Sigma:
            d[h[(x, b)]] = d.get(h[(x, b)], Fr(0)) + rho[b]
        K[x] = d
    return K


# ------------------------------------------------------------------------------------------------ (A)
print("(A) the twin with person P* (feature case)")
n_eq, n_diff_all, n_trials, n_ge2 = 0, 0, 0, 0
for trial in range(200):
    m = int(rng.integers(1, 4))
    W = 2 ** m
    nS = int(rng.integers(1, 4))
    if nS > W:
        nS = W
    nY = nS + int(rng.integers(0, 2))
    if nS == 1:
        counts = [W]
    else:
        cuts = sorted(rng.choice(np.arange(1, W), size=nS - 1, replace=False).tolist())
        counts = np.diff([0] + cuts + [W]).tolist()
    rho = {b: Fr(counts[b], W) for b in range(nS)}
    beta = rng.permutation(np.repeat(np.arange(nS), counts)).tolist()
    mu, xs, h = {}, [], {}
    for w in range(W):
        k = int(rng.integers(1, 4))
        wts = rng.integers(1, 5, size=k)
        mu[w] = {}
        for i in range(k):
            x = (w, i)                                   # the first m bits of x are w: the feature case
            mu[w][x] = Fr(int(wts[i]), int(wts.sum()))
            xs.append(x)
            perm = rng.permutation(nY)[:nS]
            for b in range(nS):
                h[(x, b)] = int(perm[b])
    law = data_law(W, mu, h, beta)
    # twin
    h2 = {(x, '*'): h[(x, beta[x[0]])] for x in xs}
    law2 = data_law(W, mu, h2, ['*'] * W)
    K1 = kernel(rho, h, xs, range(nS))
    K2 = kernel({'*': Fr(1)}, h2, xs, ['*'])
    n_trials += 1
    n_eq += int(law == law2)
    differ_everywhere = all(K1[x] != K2[x] for x in xs)
    if nS >= 2:
        n_ge2 += 1
        n_diff_all += int(differ_everywhere)
    else:
        assert all(K1[x] == K2[x] for x in xs)
print(f"  {n_trials} random worlds: data laws equal (exact) in {n_eq}; with |Sigma| >= 2 the kernels differ at every input"
      f" in {n_diff_all} of the {n_ge2} worlds with |Sigma| >= 2; with |Sigma| = 1 the twin is the person itself (asserted).")

# ------------------------------------------------------------------------------------------------ (B)
print()
print("(B) N worlds with one data law: sum_i Pr_i[copy of person i] <= 1 for every procedure")
W = 4
T = [0, 1, 1, 0]                                     # the deterministic data table, x = w (one input per cell)
worlds = []                                           # (label, kernel as tuple over x of (P(y=0), P(y=1)))
for counts in ([3, 1],):        # (1,3) would repeat these kernels with the complementary coupling
    rho = (Fr(counts[0], W), Fr(counts[1], W))
    for S in combinations(range(W), counts[1]):
        beta = [1 if w in S else 0 for w in range(W)]
        # response h(x,b) = T(x) xor b xor beta(x): the coin beta(x) gives T(x)
        ker = []
        for x in range(W):
            p = [Fr(0), Fr(0)]
            for b in (0, 1):
                p[T[x] ^ b ^ beta[x]] += rho[b]
            ker.append(tuple(p))
        worlds.append((f"rho={counts}, beta={beta}", tuple(ker)))
worlds.append(("twin (deterministic T)", tuple((Fr(1 - T[x]), Fr(T[x])) for x in range(W))))
kers = [k for _, k in worlds]
assert len(set(kers)) == len(kers), "kernels must differ pairwise"
print(f"  {len(worlds)} worlds share the data law (x uniform, y = T(x)) and have pairwise different persons")
# programs: one copy per world plus a few non-copies; a procedure maps a sample to a program index
menu = list(range(len(worlds))) + [len(worlds), len(worlds) + 1]      # last two: uniform kernel, something else
samples1 = [((x, T[x]),) for x in range(W)]                        # n = 1: four equally likely samples
best = 0
count = 0
for assignment in product(menu, repeat=len(samples1)):
    count += 1
    tot = Fr(0)
    for s, prog in zip(samples1, assignment):
        # the sample has probability 1/4 in every world; the output copies world i iff prog == i
        if prog < len(worlds):
            tot += Fr(1, W)
    best = max(best, tot)
    assert tot <= 1
print(f"  n = 1: all {count} deterministic procedures: max sum_i Pr_i[copy_i] = {best}")
for n in (2, 3):
    samples = list(product(range(W), repeat=n))
    best = Fr(0)
    for t in range(3000):
        assign = rng.integers(0, len(menu), size=len(samples))
        tot = sum(Fr(1, W ** n) for prog in assign if prog < len(worlds))
        assert tot <= 1
        best = max(best, tot)
    print(f"  n = {n}: 3000 random deterministic procedures: max sum = {best} (<= 1)")
print("  (a randomised procedure is a mixture of deterministic ones, so its sum is a mixture of these sums)")

# ------------------------------------------------------------------------------------------------ (C)
print()
print("(C) ties in rho")
W = 4
beta = [0, 1, 1, 0]
mu = {w: {(w, 0): Fr(1)} for w in range(W)}
xs = [(w, 0) for w in range(W)]
hA = {(x, b): b for x in xs for b in (0, 1)}
hB = {(x, b): 1 - b for x in xs for b in (0, 1)}
rho = {0: Fr(1, 2), 1: Fr(1, 2)}
print(f"  fair coin, h = b vs h = 1-b: kernels equal: {kernel(rho, hA, xs, (0, 1)) == kernel(rho, hB, xs, (0, 1))};"
      f" data laws equal: {data_law(W, mu, hA, beta) == data_law(W, mu, hB, beta)}")
print("  so 'equal kernels give equal data laws' fails with ties; the draft's wording after the proposition (same response"
      " function and coin law) is the correct one.")

# ------------------------------------------------------------------------------------------------ (D)
print()
print("(D) latent-cause channel: is P* the kernel of some person (a fixed coin law, injective response)?")
n_not = 0
for trial in range(200):
    W = 4
    nX = 3
    mu = {w: {} for w in range(W)}
    for w in range(W):
        wts = rng.integers(1, 4, size=nX)
        for x in range(nX):
            mu[w][x] = Fr(int(wts[x]), int(wts.sum()))
    beta = rng.permutation([0, 0, 0, 1]).tolist()
    h = {(x, b): (b + x) % 2 for x in range(nX) for b in (0, 1)}
    law = data_law(W, mu, h, beta)
    Pstar = []
    for x in range(nX):
        px = sum(v for (xx, y), v in law.items() if xx == x)
        Pstar.append(sorted([law.get((x, y), Fr(0)) / px for y in (0, 1)], reverse=True))
    # a person's kernel has the same multiset of positive masses (its coin law) at every input
    n_not += int(len({tuple(p) for p in Pstar}) > 1)
print(f"  200 random latent-cause worlds: P* has input-dependent mass profiles (so no person has kernel P*) in {n_not}")
