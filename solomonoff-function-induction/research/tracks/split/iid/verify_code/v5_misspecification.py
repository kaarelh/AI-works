"""v5: independent checks for iid notes-final Prop 7.3(iii') and (v) (misspecification, PQ).  Written for
verify-iid.md; it does not import or read any record script.  Both statements are almost-sure limit statements;
the simulations illustrate them.

(A) Prop 7.3(iii'): with i.i.d. inputs from an atomic mu and fresh labels from nu = f xor Bern(p), the first time T
    at which some input has received both labels.  After T every deterministic program has likelihood 0, so the
    coin (the unique KL-projection in the class of 7.3(iii)) is the unique lambda-MAP for every lambda > 0.
    mu(x) = 2^-(x+1) on {0, 1, 2, ...}; p in {0.01, 0.1, 0.25}; 10^4 runs each (seed 4501).
(B) Prop 7.3(v): the record's example: truth = fair coin; pi1 = Bern(1/4), l = 2; pi2 = Bern(3/4), l = 5; both are
    KL-projections (D = (1/2) log2(4/3)), P0 = {pi1}.  W_n = log2(nu_pi2(h_n)/nu_pi1(h_n)) is a simple random walk
    with steps +-sigma, sigma = log2 3; pi2 is the unique lambda_n-MAP iff W_n > 3 lambda_n.  The LIL threshold
    for lambda_n = C sqrt(n ln ln n) is C* = sigma sqrt(2)/3 = 0.747.  For each schedule, 60 runs of 10^7 steps
    (seed 4502): the fraction of runs in which pi2 is the unique MAP at some n in (10^5, 10^7], and at some n in
    (10^6, 10^7].
"""
import math

import numpy as np

print("=" * 100)
print("(A) Prop 7.3(iii'): time until some input has received both labels")
rng = np.random.default_rng(4501)
for p in (0.01, 0.1, 0.25):
    R = 10000
    T = np.empty(R, int)
    for r in range(R):
        seen = {}
        n = 0
        while True:
            n += 1
            x = int(rng.geometric(0.5)) - 1
            f = x & 1
            y = f ^ int(rng.random() < p)
            s = seen.setdefault(x, set())
            s.add(y)
            if len(s) == 2:
                T[r] = n
                break
    q = np.quantile(T, [0.5, 0.9, 0.99, 1.0])
    print(f"  p={p}: all {R} runs finite; T quantiles (50%, 90%, 99%, max) = {[int(v) for v in q]}")

print("=" * 100)
print("(B) Prop 7.3(v): two projections, pi2 (longer) unique MAP iff W_n > 3 lambda_n")
SIG = math.log2(3)
H = 10_000_000
n = np.arange(1, H + 1, dtype=np.float64)
lnln = np.log(np.log(np.maximum(n, 16.0)))
scheds = {
    "fixed lambda = 2": np.full(H, 2.0),
    "sqrt(n)": np.sqrt(n),
    "0.4 sqrt(n lnln n)": 0.4 * np.sqrt(n * lnln),
    "0.6 sqrt(n lnln n)": 0.6 * np.sqrt(n * lnln),
    "0.9 sqrt(n lnln n)": 0.9 * np.sqrt(n * lnln),
    "1.5 sqrt(n lnln n)": 1.5 * np.sqrt(n * lnln),
    "n^0.6": n ** 0.6,
}
thr = {k: 3 * v / SIG for k, v in scheds.items()}       # pi2 unique MAP iff S_n > thr, S_n simple walk
del n, lnln
print(f"  C* = sigma sqrt(2)/3 = {SIG * math.sqrt(2) / 3:.3f}")
rngB = np.random.default_rng(4502)
R = 60
late5 = {k: 0 for k in scheds}
late6 = {k: 0 for k in scheds}
for r in range(R):
    S = np.cumsum(rngB.integers(0, 2, size=H, dtype=np.int8) * 2 - 1, dtype=np.int32)
    for k in scheds:
        win = S > thr[k]
        late5[k] += bool(win[100_000:].any())
        late6[k] += bool(win[1_000_000:].any())
    del S
for k in scheds:
    print(f"  {k:>20}: pi2 unique MAP at some n in (1e5, 1e7]: {late5[k]}/{R}; in (1e6, 1e7]: {late6[k]}/{R}")
print("done")
