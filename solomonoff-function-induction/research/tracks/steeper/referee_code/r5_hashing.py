"""Referee check r5: notes Lemma 3.2 (derandomising a sampler by N-wise independent hashing).

(a) Exact check in a case c4(B) does not cover: q = 5 (GF(32), modulus x^5+x^2+1), inputs from
    {0,1}^3 embedded injectively (n = 3 < q), r = 2 random bits per input (r < q, "first r bits").
    For every set of N <= 3 distinct inputs and every labelling, P_seed[phi_s agrees with D] = nu(D).
(b) Collisions: distinct seeds s can give the SAME deterministic function phi_s on all of X.
    Then "the class has one program of length <= K(f)+kappa per function f" (notes Def 1.3's notion
    of universality) does not by itself give W_det(D) >= sum_s 2^{-len(s)} [phi_s extends D]:
    the per-seed sum double-counts functions.  We count distinct functions among seeds.
Seeded: numpy default_rng(14) (only for choosing the sampler table).
"""
import itertools
import numpy as np

rng = np.random.default_rng(14)
Q = 5
MOD = 0b100101  # x^5 + x^2 + 1, irreducible over GF(2)


def gmul(a, b):
    res = 0
    for _ in range(Q):
        if b & 1:
            res ^= a
        b >>= 1
        a <<= 1
        if a & (1 << Q):
            a ^= MOD
    return res


def peval(coef, x):
    acc = 0
    for cf in reversed(coef):
        acc = gmul(acc, x) ^ cf
    return acc


# irreducibility sanity: x^(2^5) = x and no proper subfield root
def gpow(a, e):
    r = 1
    for _ in range(e):
        r = gmul(r, a)
    return r


assert all(gpow(a, 32) == a for a in range(32)), "not a field"
n_bits, r_bits = 3, 2
Xs = list(range(2 ** n_bits))
emb = {x: (x << 1) | 1 for x in Xs}              # injective into GF(32)
g = {x: int(rng.integers(0, 2 ** r_bits + 1)) for x in Xs}   # nu(1|x) = g(x)/4


def sampler(x, h):
    bits = h >> (Q - r_bits)                      # first r bits (high bits) of the q-bit hash
    return 1 if bits < g[x] else 0


worst, cnt = 0.0, 0
for N in [1, 2, 3]:
    for xs in itertools.combinations(Xs, N):
        seeds = list(itertools.product(range(2 ** Q), repeat=N))
        vals = np.array([[sampler(x, peval(s, emb[x])) for x in xs] for s in seeds])
        for ys in itertools.product([0, 1], repeat=N):
            nuD = np.prod([g[x] / 4 if y else 1 - g[x] / 4 for x, y in zip(xs, ys)])
            frac = np.mean(np.all(vals == np.array(ys), axis=1))
            worst = max(worst, abs(frac - nuD))
            cnt += 1
print(f"(a) GF(32), n=3, r=2: {cnt} (domain, labelling) pairs; max |P_seed[agree] - nu(D)| = {worst:.2e}")

for N in [1, 2]:
    seeds = list(itertools.product(range(2 ** Q), repeat=N))
    funcs = {}
    for s in seeds:
        f = tuple(sampler(x, peval(s, emb[x])) for x in Xs)
        funcs[f] = funcs.get(f, 0) + 1
    mult = sorted(funcs.values(), reverse=True)
    print(f"(b) N={N}: {len(seeds)} seeds give {len(funcs)} distinct functions on X; "
          f"largest multiplicity {mult[0]} (so per-seed weights must be counted per program, not per function)")
