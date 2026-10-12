"""s1 (referee, second report): the conjectured bound of notes.md Q2,

    L_F(D) <= L_xi(D_sigma) + I(x_sigma : y_sigma) + O(log),

is refuted by the notes' own Prop. 4.5(i) construction (referee.md, issue M3).

Construction.  S = n distinct strings; A a subset of S of size floor(n/2); order sigma puts the
elements of A at the even positions; labels y_i = [i even], so y_sigma = 0101... and
D = {(x,1): x in A} u {(x,0): x in S \\ A}.
  * xi (history-aware): the predictor "y_i = [i even]" has loss 0, so L_xi <= c.
  * I(x_sigma : y_sigma) <= K(y_sigma) + c <= K(n) + c, because y_sigma is computable from n.
  * SFI: the events {U^omega extends D_A}, A ranging over the floor(n/2)-subsets of S, are disjoint
    (they prescribe different labels somewhere), so sum_A M_F(D_A) <= 1.  Hence
      - for uniformly random A: E_A[L_F(D_A)] >= H(A) = log2 C(n, floor(n/2))   (Gibbs; no constant);
      - for every fixed S, at least half of the A have L_F >= log2 C(n, floor(n/2)) - 1  (Markov).
So the gap L_F - L_xi - I(x_sigma:y_sigma) is at least log2 C(n, n/2) - K(n) - c, which is linear in n.

This script checks the finite, constant-free parts exactly:
  (1) for n = 2..14 and every distribution G over labellings of S that we test (uniform over
      balanced labellings, random Dirichlet laws, and point masses), sum over balanced A of
      G(D_A) <= 1, and E_A[-log2 G(D_A)] >= log2 C(n, floor(n/2)) for uniform A;
  (2) the bound log2 C(n, floor(n/2)) >= n - log2(n+1) for 2 <= n <= 4096;
  (3) the gap lower bound log2 C(n, floor(n/2)) - L(n) with L(n) the Elias-delta length of n (a
      computable upper bound on K(n) up to an additive constant), for n up to 2^20.
Seed 31415.  Output: s1_q2_counterexample.out
"""
import itertools
from math import comb, log2
import numpy as np

SEED = 31415
rng = np.random.default_rng(SEED)


def len_delta(N):
    k = N.bit_length() - 1
    return k + 2 * ((k + 1).bit_length() - 1) + 1


# (1) exact finite check over labellings of an n-set (labels in {0,1})
print("(1) disjointness / Gibbs check over all labellings of an n-set")
for n in range(2, 15):
    labs = list(itertools.product((0, 1), repeat=n))
    idx_bal = [i for i, l in enumerate(labs) if sum(l) == n // 2]
    H = log2(comb(n, n // 2))
    laws = {"uniform-balanced": np.array([1.0 / len(idx_bal) if i in set(idx_bal) else 0.0 for i in range(len(labs))])}
    for t in range(3):
        laws[f"dirichlet{t}"] = rng.dirichlet(np.ones(len(labs)) * 0.3)
    laws["point-mass"] = np.eye(len(labs))[idx_bal[0]]
    worst_sum, worst_gibbs = -1.0, float("inf")
    for name, G in laws.items():
        s = float(G[idx_bal].sum())
        worst_sum = max(worst_sum, s)
        with np.errstate(divide="ignore"):
            e = float(np.mean(-np.log2(G[idx_bal])))
        worst_gibbs = min(worst_gibbs, e - H)
    assert worst_sum <= 1 + 1e-12 and worst_gibbs >= -1e-9
    print(f"    n={n:2d}: max_G sum_A G(D_A) = {worst_sum:.6f} <= 1;  min_G (E_A[-log2 G(D_A)] - log2 C) = {worst_gibbs:+.6f} >= 0;  log2 C = {H:.3f}")

# (2) binomial bound
bad = [n for n in range(2, 4097) if log2(comb(n, n // 2)) < n - log2(n + 1) - 1e-12]
assert not bad, bad[:5]
print("(2) log2 C(n, floor(n/2)) >= n - log2(n+1) holds for all 2 <= n <= 4096")

# (3) gap table
print("(3) lower bound on L_F - L_xi - I(x:y) (up to an additive constant c):  log2 C(n, n/2) - len_delta(n)")
for e in (3, 5, 8, 10, 12, 16, 20):
    n = 1 << e
    H = log2(comb(n, n // 2))
    print(f"    n = 2^{e:<2d}: log2 C = {H:12.2f}   len_delta(n) = {len_delta(n):3d}   gap >= {H - len_delta(n):12.2f} - c")
print("RESULT: E_A[L_F] >= log2 C(n, n/2) ~ n, while L_xi <= c and I(x_sigma : y_sigma) <= K(n) + c.")
print("        The conjectured bound of Q2 fails by a margin linear in n.")
