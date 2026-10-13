"""i5: the single short fill-in (notes-final Lemma 5.2).  Seeded: numpy default_rng(5).
[Labels updated to the notes-final numbering and notation (l0, E0) on 2026-10-13; computations unchanged.]

(A) The probabilistic-method step on tiny instances.  Inputs {0,1}^{<=d}, labels {0,1}, a sampler nu.
    Let D_R be the data sets with n distinct inputs and nu(D) >= 2^{-R-2}.  Draw M i.i.d. random total
    functions f_j ~ nu (one label per input), M = floor(2^{R+2} n (d+1+log2|Y|)) + 1.  The lemma needs:
    with positive probability every D in D_R is extended by some f_j.  We estimate that probability, and
    the least M (on a doubling grid) at which it exceeds 1/2, to see how loose the union bound is.
(B) Sizes.  The lemma's overhead over l(pi_nu) - log nu(D):
    3 log2(n+1) + 3 log2(d + 2 + log2|Y|) + 2 log2(R+1) + 4 bits (machine constant excluded),
    at realistic sizes, next to the total-weight cost 2 log2(t_D + 1) of the stream lemma.
"""
import itertools
import numpy as np
from math import log2, ceil, floor

rng = np.random.default_rng(5)

def inputs(d):
    out = [""]
    for L in range(1, d + 1):
        out += ["".join(b) for b in itertools.product("01", repeat=L)]
    return out

def run(d, n, R, nu1, trials=400):
    X = inputs(d)
    p1 = np.array([nu1(x) for x in X])
    DR = []
    for S in itertools.combinations(range(len(X)), n):
        for lab in itertools.product((0, 1), repeat=n):
            v = np.prod([p1[i] if y else 1 - p1[i] for i, y in zip(S, lab)])
            if v >= 2.0 ** (-R - 2):
                DR.append((np.array(S), np.array(lab)))
    M = floor(2 ** (R + 2) * n * (d + 1 + 1)) + 1
    def cover_prob(M):
        ok = 0
        for _ in range(trials):
            F = (rng.random((M, len(X))) < p1[None, :]).astype(int)
            good = all(np.any(np.all(F[:, S] == lab[None, :], axis=1)) for S, lab in DR)
            ok += good
        return ok / trials
    pM = cover_prob(M)
    m = 1
    while cover_prob(m) < 0.5:
        m *= 2
    return len(X), len(DR), M, pM, m

print("=" * 78)
print("(A) covering families of random functions drawn from nu")
cases = [
    (1, 2, 3, lambda x: 0.5),
    (1, 2, 4, lambda x: 0.25),
    (2, 2, 5, lambda x: 0.25 if x.endswith("0") else 0.75),
    (2, 3, 6, lambda x: 0.5),
]
for d, n, R, f in cases:
    nX, nD, M, pM, m = run(d, n, R, f)
    print(f"  d={d} |X|={nX} n={n} R={R}: |D_R|={nD}, lemma's M={M}, P[cover] at M = {pM:.3f}; "
          f"least M on doubling grid with P[cover] >= 1/2: {m}")

print("=" * 78)
print("(B) overhead of the single fill-in vs the stream lemma's total-weight cost")
def t_D(n, d, beta):
    iD = ceil(log2(6 * n / beta))
    return ceil(log2(2 * d + 2 + 2 * log2(iD + 1)))
for n, d, H in [(10 ** 3, 20, 0.5), (10 ** 6, 100, 0.5), (10 ** 9, 1000, 0.1), (10 ** 12, 1000, 1.0)]:
    R = ceil(n * H) + 1
    single = 3 * log2(n + 1) + 3 * log2(d + 3) + 2 * log2(R + 1) + 4
    stream = 2 * log2(t_D(n, d, 1 / 3) + 1)
    print(f"  n={n:.0e} d={d} R~{R:.2e}: single fill-in overhead = {single:6.1f} bits;"
          f"  stream lemma (total weight, beta=1/3) = {stream:.1f} bits")
