"""Reviewer p1-math-A (run 2): independent checks for Paper 1, versions.tex / app-versions.tex.

 (1) ell_d = ceil(log2(d/log2 3)) - 1 is the largest ell with 3^(2^ell) < 2^d; g >= log d - 2 (thm:versions:nocoding(i)).
 (2) arithmetic of thm:versions:nocoding: log2 d <= K_F + 2  =>  ceil(log2(d+1)) <= K_F + 4.
 (3) prop:versions:covering arithmetic: d' = 2^s - 2 >= d, d'+2 < 2(d+2), count <= 2^{k(d'+2)},
     (1-2^-k)^N < 2^{-k(d'+2)}, log2 N <= k + log2(k(d+2)) + 1; also the constant in cor:versions:twopoint.
 (4) exact minimal size of a family of total truth tables on {0,1}^{<=d} covering all binary k-point data
     sets (tiny cases, brute force), compared with N_cov.
 (5) Kleitman-Spencer two-point covering: validity for N <= 12 and "at most d+6 functions for d <= 40".
 (6) k-wise independence of polynomial hashing over GF(2^q), lowest bit (rem:versions:hashing).
 (7) prop:versions:shared counting step: sum over non-constant b of prod_j s(n_j,b_j) <= prod(1+eps 2^-j) - 1 <= 2 eps.
 (8) j(x) <= 2^{d+1}-2 and the lookup machine F(x) = omega_{j(x)+1} gives 2^-|D|.
"""
from fractions import Fraction as Fr
from itertools import product, combinations
import math, random

random.seed(20261012)
L3 = math.log2(3)

print("(1) ell_d")
fails = 0
for d in range(2, 200001):
    ell = math.ceil(math.log2(d / L3)) - 1
    # largest ell with 2^ell * log2 3 < d, exact via integer comparison 3^(2^ell) < 2^d when small
    ok = (2 ** ell) * L3 < d and (2 ** (ell + 1)) * L3 >= d
    ok &= ell >= math.log2(d) - 2
    if not ok:
        fails += 1
print("   d in [2,200000]: failures", fails)
# exact integer check for small d
fails = 0
for d in range(2, 2000):
    ell = math.ceil(math.log2(d / L3)) - 1
    if ell >= 0:
        if not (3 ** (2 ** ell) < 2 ** d and 3 ** (2 ** (ell + 1)) >= 2 ** d):
            fails += 1
print("   exact integer check d<2000: failures", fails)

print("(2) nocoding last-claim arithmetic")
fails = 0
for d in range(2, 100000):
    KF_min = math.log2(d) - 2  # smallest K_F allowed by (i)
    KF = math.ceil(KF_min)
    if math.ceil(math.log2(d + 1)) > KF + 4:
        fails += 1
print("   failures:", fails)

print("(3) covering arithmetic")
fails = 0
worst = 0.0
for d in range(0, 3000):
    s = math.ceil(math.log2(d + 2)); dp = 2 ** s - 2
    if not (dp >= d and dp + 2 < 2 * (d + 2)):
        fails += 1
    for k in (1, 2, 3, 5, 10, 40):
        Ncov = math.floor(2 ** k * k * (dp + 2) * math.log(2)) + 1
        if not (math.log2(Ncov) <= k + math.log2(k * (d + 2)) + 1):
            fails += 1
        # (1-2^-k)^N < 2^{-k(d'+2)} in logs
        if not (Ncov * math.log1p(-2.0 ** -k) < -k * (dp + 2) * math.log(2)):
            fails += 1
for d in range(0, 6):
    s = math.ceil(math.log2(d + 2)); dp = 2 ** s - 2
    for k in range(1, 5):
        cnt = math.comb(2 ** (dp + 1) - 1, k) * 2 ** k
        if cnt > 2 ** (k * (dp + 2)):
            fails += 1
print("   failures:", fails)
# cor twopoint: K_F <= 2 + log2(2(d+2)) + K(...) = log2(d+2) + 3 + ... ; check log2(d+2)+3 <= log2 d + 4 for d>=2
print("   log2(d+2) <= log2 d + 1 for d>=2:", all(math.log2(d + 2) <= math.log2(d) + 1 for d in range(2, 10000)))

print("(4) exact minimal covering families (brute force, tiny)")
def inputs_upto(d):
    return [t for L in range(d + 1) for t in product((0, 1), repeat=L)]
for d, k in ((0, 1), (1, 1), (1, 2), (2, 1)):
    xs = inputs_upto(d); M = len(xs)
    tables = list(product((0, 1), repeat=M))
    targets = [(S, lab) for S in combinations(range(M), k) for lab in product((0, 1), repeat=k)]
    best = None
    for size in range(1, 9):
        found = False
        for fam in combinations(range(len(tables)), size):
            if all(any(all(tables[f][i] == l for i, l in zip(S, lab)) for f in fam) for S, lab in targets):
                found = True; break
        if found:
            best = size; break
    s = math.ceil(math.log2(d + 2)); dp = 2 ** s - 2
    Ncov = math.floor(2 ** k * k * (dp + 2) * math.log(2)) + 1
    print(f"   d={d} k={k} M={M}: exact minimum {best}, N_cov={Ncov}")

print("(5) Kleitman-Spencer 2-covering")
ok = True
for N in range(3, 13):
    h = N // 2
    sets = [S for S in combinations(range(N), h) if 0 in S]
    for S, T in combinations(sets, 2):
        pats = {(int(i in S), int(i in T)) for i in range(N)}
        ok &= (len(pats) == 4)
    ok &= (len(sets) == math.comb(N - 1, h - 1))
print("   valid for N=3..12:", ok)
mx = 0
for d in range(1, 41):
    need = 2 ** (d + 1) - 1
    N = 3
    while math.comb(N - 1, N // 2 - 1) < need:
        N += 1
    mx = max(mx, N - d)
print("   max over d<=40 of (N needed - d):", mx)

print("(6) polynomial hashing over GF(2^q)")
IRRED = {3: 0b1011, 4: 0b10011}
def gfmul(a, b, q):
    r = 0
    while b:
        if b & 1:
            r ^= a
        b >>= 1
        a <<= 1
        if a >> q:
            a ^= IRRED[q]
    return r
bad = 0; checked = 0
for q, k in ((3, 2), (3, 3), (4, 2), (4, 3)):
    field = range(2 ** q)
    seeds = list(product(field, repeat=k))
    for j in range(1, k + 1):
        for pts in combinations(field, j):
            counts = {}
            for s in seeds:
                vals = []
                for z in pts:
                    acc = 0; zp = 1
                    for i in range(k):
                        acc ^= gfmul(s[i], zp, q); zp = gfmul(zp, z, q)
                    vals.append(acc & 1)
                counts[tuple(vals)] = counts.get(tuple(vals), 0) + 1
            checked += 1
            if len(counts) != 2 ** j or len(set(counts.values())) != 1:
                bad += 1
print(f"   point sets checked {checked}, non-uniform lowest-bit patterns {bad}")

print("(7) shared-coin counting step")
ok = True
for k in range(2, 12):
    for eps in (0.01, 0.1, 0.5):
        # worst case: s(n_j, y_i) = 1, s(n_j, 1-y_i) = eps 2^-j
        tot = 0.0
        for b in product((0, 1), repeat=k):
            if len(set(b)) == 1:
                continue
            p = 1.0
            for j, bj in enumerate(b, start=1):
                p *= (eps * 2 ** -j) if bj != 0 else 1.0
            tot += p
        bound = math.prod(1 + eps * 2 ** -j for j in range(1, k + 1)) - 1
        ok &= tot <= bound + 1e-15 and bound <= math.exp(eps) - 1 <= 2 * eps
print("   holds:", ok)

print("(8) lookup machine")
ok = True
for d in range(0, 8):
    xs = inputs_upto(d)
    # length-lexicographic order: by length then lexicographic -> index
    order = sorted(xs, key=lambda t: (len(t), t))
    ok &= max(order.index(x) for x in xs) == 2 ** (d + 1) - 2
print("   max j(x) on {0,1}^{<=d} equals 2^{d+1}-2 for d<=7:", ok)
