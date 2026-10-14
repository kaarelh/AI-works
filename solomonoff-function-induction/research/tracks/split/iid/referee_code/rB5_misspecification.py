"""rB5 (referee B): misspecification (notes Section 7.4, Prop 7.3(ii) and (iii)).  Seeded: default_rng(51).

(A) Prop 7.3(ii) is stated for FIXED lambda.  Same example as the notes: fair-coin labels,
    pi_1 = Bern(1/4) (l = 2), pi_2 = Bern(3/4) (l = 5), both KL-projections with different kernels.
    pi_2 is the unique MAP iff (#ones - #zeros) log2(3) > lambda_n * 3.
    Schedules: lambda = 2 (fixed), lambda_n = n^{0.5}, n^{0.6}, n^{0.75}, n/log2(n) (all o(n)).
    For lambda_n / sqrt(n log log n) -> infinity the law of the iterated logarithm makes the shortest
    projection pi_1 the MAP for all large n: the KL-projection conjecture HOLDS for such schedules in
    every finite class whose projections' log-likelihood ratios have finite variance.
    20 runs of 2*10^6 samples per schedule: switches after n = 10^5 and the last switch.
(B) Prop 7.3(iii) with an EXPLICIT memoriser class (no machine constant set to 0).
    Distinct inputs x_i = i (stamped queries).  Truth: y_i = f(i) xor Bern(p), f computable.
    Class: the coin (l_c = 2), and for every (m, k, r) the deterministic program "f xor 1_S", S the r-th
    k-subset of {1..m} in a fixed enumeration, of length
        l(m, k, r) = 10 + c(m) + c(k) + ceil(log2 binom(m, k)),   c(j) := 2 ceil(log2(j+1)) + 1,
    a prefix code: the Kraft sum is at most 2^-10 (sum_j 2^-c(j))^2 + 1/4 < 1.  nu is not in the class,
    the coin is the unique KL-projection (every deterministic program has D = infinity).
    The cheapest consistent memoriser at n uses m = n and S = the flips so far.  lambda-MAP at n:
    the coin iff lambda*2 + n < lambda*l(n, K_n, .), a memoriser iff the reverse.
    Threshold lambda = 1/H(p).  One run of n = 10^6 per (p, lambda): the last n at which the MAP type
    differs from its type at n = 10^6.
"""
import numpy as np
from math import log2, ceil, log
from scipy.special import gammaln

rng = np.random.default_rng(51)

print("=" * 78)
print("(A) two KL-projections, schedules lambda_n; 20 runs of 2*10^6 samples each")
N = 2 * 10 ** 6
n = np.arange(1, N + 1, dtype=float)
scheds = {
    "fixed 2": np.full(N, 2.0),
    "n^0.5": n ** 0.5,
    "n^0.6": n ** 0.6,
    "n^0.75": n ** 0.75,
    "n/log2 n": n / np.maximum(np.log2(n), 1.0),
}
stats = {k: [] for k in scheds}
for run in range(20):
    y = rng.integers(0, 2, size=N, dtype=np.int8)
    walk = np.cumsum(2 * y.astype(np.int64) - 1)
    for name, lam in scheds.items():
        q3 = walk * log2(3) > 3 * lam                 # pi_2 (Bern 3/4) is the unique MAP
        sw = np.flatnonzero(q3[1:] != q3[:-1])
        late = int(np.sum(sw >= 10 ** 5))
        last = int(sw[-1]) + 2 if len(sw) else 0
        stats[name].append((late, last, bool(q3[-1])))
for name in scheds:
    late = [s[0] for s in stats[name]]; last = [s[1] for s in stats[name]]
    endq3 = sum(s[2] for s in stats[name])
    print(f"  {name:9s}: runs with switches after 1e5: {sum(1 for v in late if v > 0):2d}/20; "
          f"median last switch {int(np.median(last)):8d}; max last switch {max(last):8d}; "
          f"runs ending with the longer projection as MAP: {endq3}")

print("=" * 78)
print("(B) explicit memoriser class vs the coin (the unique KL-projection)")


def c(j):
    return 2 * np.ceil(np.log2(j + 1)) + 1


Nb = 10 ** 6
nn = np.arange(1, Nb + 1, dtype=float)
kraft_codes = sum(2.0 ** -(2 * ceil(log2(j + 1)) + 1) for j in range(0, 10 ** 6))
print(f"  sum_j 2^-c(j) = {kraft_codes:.4f}; class Kraft sum <= 2^-10 * {kraft_codes ** 2:.4f} + 1/4 < 1")
for p in [0.1, 0.25]:
    H = -p * log2(p) - (1 - p) * log2(1 - p)
    flips = rng.random(Nb) < p
    K = np.cumsum(flips).astype(float)
    logbinom = (gammaln(nn + 1) - gammaln(K + 1) - gammaln(nn - K + 1)) / log(2)
    lmem = 10 + c(nn) + c(K) + np.ceil(logbinom - 1e-9)
    S = np.where(flips, -log2(p), -log2(1 - p)).cumsum()      # sampled randomness -log nu(D_n)
    print(f"  p = {p}: 1/H(p) = {1 / H:.4f};  min_n (l_mem - S_n) = {np.min(lmem - S):.2f} "
          f"(Ville: >= -delta*, and P[delta* >= j] <= 2^-j)")
    for lam in [1.5, 0.9 / H, 0.97 / H, 1.03 / H, 1.1 / H, 3.0]:
        coin_wins = lam * 2 + nn < lam * lmem
        final = coin_wins[-1]
        diff = np.flatnonzero(coin_wins != final)
        last = int(diff[-1]) + 1 if len(diff) else 0
        print(f"    lambda = {lam:.4f} (lambda H = {lam * H:.3f}): MAP at n = 1e6 is the "
              f"{'coin' if final else 'memoriser'}; last n with the other type: {last}")
