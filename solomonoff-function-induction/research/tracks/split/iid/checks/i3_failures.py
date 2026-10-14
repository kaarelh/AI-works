"""i3: what fails (notes-final Section 7).  Seeded: numpy default_rng(3).
[Labels updated to the notes-final numbering and notation (l0, E0) on 2026-10-13; computations unchanged.]

(A) Misspecification with two KL-projections (Prop 7.3(ii)).  Truth: fair-coin labels at every input.
    C = {q1: Bern(1/4), l = 2;  q3: Bern(3/4), l = 5}.  Both minimise E KL(nu || nu_pi).  With lambda = 2,
    q3 is the MAP iff S_n := log Lambda_n(q3)/Lambda_n(q1) > lambda (5 - 2) = 6 bits, i.e. iff
    #ones - #zeros >= 4.  S_n is a mean-zero random walk, so both are MAPs infinitely often.
    20 runs of 10^6 samples: fraction of time q3 is the MAP, number of switches, last switch.
(B) Misspecification with fill-ins (Prop 7.3(iii), frozen data on distinct inputs).  Truth nu = f xor Bern(p), p = 0.1, H(p) = 0.469;
    C = {deterministic programs} + {coin, l = 2}.  Distinct inputs of length d = 64.  The coin is the
    KL-projection.  Rigorous lower bound on every fill-in: l >= S_n - delta*, S_n = -log nu(D_n).
    Upper bound (Lemma 5.2, machine constant set to 0, an illustration): a fill-in of length
    k_nu + R + 3 log2(n+1) + 3 log2(d + 3) + 2 log2(R+1) + 4 with R = ceil(S_n), k_nu = 20.
    lambda in {1.5, 2.0, 2.3, 3.0} (threshold 1/H(p) = 2.13); one run per lambda, n up to 2*10^5.
(C) Frozen noise on a finite support (Prop 7.6(d)).  X = {0..9}, mu uniform; truth Bern(1/64) at every x;
    C = {t: nu, l = 5} + {e_j: nu except P(1|j) = 1, l = 9; j in X}.  With frozen noise an e_j with F(j) = 1
    gains 6 bits for 4*lambda bits of length, so for lambda < 1.5 the MAP is eventually some e_j with
    probability exactly 1 - (63/64)^10 = 0.1457.  With fresh per-query noise e_j dies at the first label 0
    at j.  10^4 runs each, n = 2000 queries.
(D) Non-i.i.d. inputs (Prop 7.2(b)).  Inputs x_j = 0^j (deterministic sequence).  Truth nu(1|0^j) =
    1/2 + 2^{-j/2-2}; C = {t: nu, l = 6; coin, l = 3}.  sum_j H^2 < infinity, so the coin is nu-equivalent on
    the run, and it differs from nu at every queried input.  lambda = 2; 2000 runs of n = 4000: fraction
    of runs whose MAP at n = 4000 is the coin.
"""
import numpy as np
from math import log2, sqrt

rng = np.random.default_rng(3)
H = lambda p: -p * log2(p) - (1 - p) * log2(1 - p)

print("=" * 78)
print("(A) two KL-projections: Bern(1/4) (l=2) and Bern(3/4) (l=5) under fair coins, lambda = 2")
N = 10 ** 6
for run in range(20):
    y = rng.integers(0, 2, size=N)
    walk = np.cumsum(2 * y - 1)                  # #ones - #zeros
    q3 = walk >= 4                                # S_n = walk * log2(3) > 6  <=>  walk >= 4
    sw = np.flatnonzero(q3[1:] != q3[:-1])
    last = int(sw[-1]) + 2 if len(sw) else 0
    late = int(np.sum(sw >= 10 ** 5))
    if run < 8 or run == 19:
        print(f"  run {run:2d}: fraction of n with MAP = q3: {q3.mean():.3f}; switches: {len(sw):5d}; "
              f"switches after n=1e5: {late:4d}; last switch at n = {last}")

print("=" * 78)
print("(B) fill-ins vs the KL-projection (coin); truth f xor Bern(0.1); threshold lambda = 1/H(p) = "
      f"{1/H(0.1):.3f}")
p, d, k_nu, l_coin = 0.1, 64, 20, 2
Nb = 2 * 10 ** 5
flips = rng.random(Nb) < p
S = np.cumsum(np.where(flips, -log2(p), -log2(1 - p)))       # sampled randomness S_n
n = np.arange(1, Nb + 1)
R = np.ceil(S)
fill_up = k_nu + R + 3 * np.log2(n + 1) + 3 * log2(d + 3) + 2 * np.log2(R + 1) + 4
for lam in [1.5, 2.0, 2.3, 3.0]:
    J_coin = lam * l_coin + n                            # -log 2^{-n} = n
    J_fill_up = lam * fill_up                            # an upper bound on the best fill-in (kappa = 0)
    J_fill_lo = lam * (S - 5)                            # lower bound with delta* = 5 (prob >= 1 - 2^-5)
    fill_wins = J_fill_up < J_coin                       # then the MAP is a fill-in
    coin_wins = J_coin < J_fill_lo                       # then the MAP is the coin (if delta* <= 5)
    def last_false(mask):
        idx = np.flatnonzero(~mask)
        return int(idx[-1]) + 2 if len(idx) else 1
    print(f"  lambda={lam}: MAP is a fill-in for all n >= {last_false(fill_wins) if fill_wins[-1] else 'never (on this range)'};"
          f"  MAP is the coin for all n >= {last_false(coin_wins) if coin_wins[-1] else 'never (on this range)'};"
          f"  per-sample: lambda*S_n/n = {lam * S[-1] / Nb:.3f} vs coin 1")

print("=" * 78)
print("(C) frozen vs fresh noise, exceptions e_j; truth Bern(1/64) on X = {0..9}")
p_c = 1 / 64
exact = 1 - (1 - p_c) ** 10
for lam in [1.0, 1.25, 1.75]:
    runs, nq = 10000, 2000
    bad_frozen = bad_fresh = 0
    for r in range(runs):
        xs = rng.integers(0, 10, size=nq)
        # frozen: one label per input; fresh: one label per query
        F = rng.random(10) < p_c
        seen = np.zeros(10, bool); seen[xs] = True
        # frozen likelihoods (distinct inputs): Lambda(e_j) = 64 if seen[j] and F[j] else 0
        best_e = min((lam * 9 - 6) if (seen[j] and F[j]) else float("inf") for j in range(10))
        bad_frozen += best_e <= lam * 5
        yq = rng.random(nq) < p_c
        # fresh: e_j consistent iff every query at j got label 1; gain 6 bits per such query
        ok = []
        for j in range(10):
            at = yq[xs == j]
            if len(at) and at.all():
                ok.append(lam * 9 - 6 * len(at))
        bad_fresh += bool(ok) and min(ok) <= lam * 5
    print(f"  lambda={lam}: frozen P[MAP != t at n=2000] = {bad_frozen/runs:.4f} "
          f"(exact {'%.4f' % exact if lam < 1.5 else '0'}); fresh = {bad_fresh/runs:.4f}")

print("=" * 78)
print("(D) non-i.i.d. inputs 0^j; truth 1/2 + 2^{-j/2-2}; coin (l=3) vs t (l=6), lambda = 2")
nD, runs = 4000, 2000
j = np.arange(1, nD + 1)
q = 0.5 + 2.0 ** (-j / 2 - 2)
h2 = 1 - np.sqrt(0.5 * q) - np.sqrt(0.5 * (1 - q))
print(f"  sum_j H^2(nu(.|0^j), coin) = {h2.sum():.5f} (finite: the coin is nu-equivalent on the run)")
coin_final = 0
for r in range(runs):
    y = rng.random(nD) < q
    logLam = np.sum(np.where(y, np.log2(0.5 / q), np.log2(0.5 / (1 - q))))   # log Lambda_n(coin)
    coin_final += (2 * 3 - logLam) < 2 * 6
print(f"  fraction of runs whose lambda-MAP at n = {nD} is the coin: {coin_final/runs:.4f}")
