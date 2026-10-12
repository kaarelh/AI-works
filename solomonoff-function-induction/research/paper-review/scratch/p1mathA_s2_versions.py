"""Independent checks for Paper 1, Section 3 (versions) and Appendix B.

Reviewer p1-math-A. Deterministic.
Checks:
  (1) ell_d := ceil(log2(d/log2 3)) - 1 is the largest ell with 3^(2^ell) < 2^d (exact integer test,
      d <= 4000), and g = ell_d >= log2 d - log2 log2 3 - 1 > log2 d - 2 for d >= 2.
  (2) Covering bound arithmetic of prop:versions:covering: s, d', N_cov; d'+2 < 2(d+2); count bound
      C(2^{d'+1}-1,k) 2^k <= 2^{k(d'+2)}; (1-2^-k)^N < e^{-N 2^-k} <= 2^{-k(d'+2)};
      log2 N_cov <= k + log2(k(d+2)) + 1 (d <= 2000, k <= 40).
  (3) Exact minimal k-covering families on {0,1}^{<=d} for tiny (d,k) by brute force versus N_cov,
      and the Kleitman-Spencer two-point construction for N <= 12.
  (4) Hashing (rem:versions:hashing): for q in {2,3}, k in {1,2,3}, x -> lowest bit of sum s_i z_x^i
      with z_x = element with coefficient vector 1x; uniformity of lowest bits on every
      set of j <= k distinct inputs of length <= q-1.
  (5) Tape-length (b): j(x) <= 2^{d+1}-2 for |x| <= d; lookup machine F(x)=omega_{j(x)+1}
      gives every binary-labelled D probability 2^-|D| and certificates inside 2^{d+1}-1 bits.
  (6) Shared-coin proof (prop:versions:shared): sum over non-constant b of gamma*nu_len(D_b) =
      gamma(1-2^{1-k}); prod_j(1+e'2^-j)-1 <= e^{e'}-1 <= 2e' for e' <= 1.
  (7) g(N) := h(max(0, floor(log2 N)-1)) satisfies g(2^{d+1}) = h(d) (rem:versions:Wrate).
  (8) Two-point rates: lower and upper bounds of cor:versions:twopoint are consistent for the
      arithmetic parts (log d - 4 - c vs log(d+2)+3+...).
"""
import math, itertools
from math import comb

print("(1) ell_d")
bad = 0
for d in range(1, 4001):
    l = math.ceil(math.log2(d / math.log2(3))) - 1
    # exact: largest ell with 3^(2^ell) < 2^d ; compare 2^ell*ln3 < d ln2 via integers 3^(2^ell) < 2^d
    best = -1
    ell = 0
    while True:
        if 3 ** (2 ** ell) < 2 ** d:
            best = ell; ell += 1
        else:
            break
    if d >= 2 and best != l:
        bad += 1
    if d >= 2 and not (best >= math.log2(d) - math.log2(math.log2(3)) - 1 > math.log2(d) - 2):
        bad += 1
print("   d in [2,4000]: failures", bad)

print("(2) covering arithmetic")
bad = 0
for d in range(0, 2001):
    s = math.ceil(math.log2(d + 2)); dp = 2 ** s - 2
    if not (dp >= d and dp + 2 < 2 * (d + 2)):
        bad += 1
    for k in range(1, 41):
        Ncov = math.floor(2 ** k * k * (dp + 2) * math.log(2)) + 1
        if not (math.log2(Ncov) <= k + math.log2(k * (d + 2)) + 1 + 1e-12):
            bad += 1
        # (1-2^-k)^N < exp(-N 2^-k) <= 2^{-k(d'+2)}  (log form)
        lhs = Ncov * math.log1p(-2.0 ** (-k))
        mid = -Ncov * 2.0 ** (-k)
        rhs = -k * (dp + 2) * math.log(2)
        if not (lhs < mid <= rhs + 1e-9):
            bad += 1
        if d <= 6 and k <= 6:
            M = 2 ** (dp + 1) - 1
            if comb(M, k) * 2 ** k > 2 ** (k * (dp + 2)):
                bad += 1
print("   failures:", bad)

print("(3) exact minimal covering families (total truth tables) on {0,1}^{<=d}")
def min_cover(M, k):
    # minimal number of functions {0..M-1}->{0,1} such that every k-subset with every labelling is matched
    funcs = list(range(2 ** M))
    targets = []
    for S in itertools.combinations(range(M), k):
        for lab in itertools.product((0, 1), repeat=k):
            targets.append((S, lab))
    def covers(f, t):
        S, lab = t
        return all(((f >> x) & 1) == y for x, y in zip(S, lab))
    cov = [frozenset(i for i, t in enumerate(targets) if covers(f, t)) for f in funcs]
    allT = frozenset(range(len(targets)))
    for N in range(1, 12):
        for fam in itertools.combinations(range(len(funcs)), N):
            u = frozenset()
            for i in fam:
                u |= cov[i]
            if u == allT:
                return N
    return None
for d in (0, 1):
    M = 2 ** (d + 1) - 1
    for k in (1, 2):
        if k > M:
            continue
        s = math.ceil(math.log2(d + 2)); dp = 2 ** s - 2
        Ncov = math.floor(2 ** k * k * (dp + 2) * math.log(2)) + 1
        print("   d=%d (M=%d inputs) k=%d: exact minimum %s ; N_cov (on d'=%d) = %d" % (d, M, k, min_cover(M, k), dp, Ncov))
# Kleitman-Spencer construction
okKS = True
for N in range(3, 13):
    h = N // 2
    inputs = [S for S in itertools.combinations(range(N), h) if 0 in S]
    if len(inputs) != comb(N - 1, h - 1):
        okKS = False
    for S, T in itertools.combinations(inputs, 2):
        pats = {(int(i in S), int(i in T)) for i in range(N)}
        if pats != {(0, 0), (0, 1), (1, 0), (1, 1)}:
            okKS = False
print("   Kleitman-Spencer family 2-covers C(N-1,floor(N/2)-1) inputs for N=3..12:", okKS)

print("(4) hashing over GF(2^q)")
IRRED = {2: 0b111, 3: 0b1011, 4: 0b10011}
def gf_mul(a, b, q):
    r = 0
    while b:
        if b & 1:
            r ^= a
        b >>= 1
        a <<= 1
        if a >> q:
            a ^= IRRED[q]
    return r
def gf_pow(a, e, q):
    r = 1
    for _ in range(e):
        r = gf_mul(r, a, q)
    return r
bad = 0; checked = 0
for q in (2, 3):
    dd = q - 1
    xs = [format(i, 'b')[1:] for i in range(1, 2 ** (dd + 1))]  # strings of length <= dd via 1x
    zs = [int('1' + x, 2) for x in xs]
    for k in (1, 2, 3):
        if k > len(zs):
            continue
        seeds = list(itertools.product(range(2 ** q), repeat=k))
        vals = {}
        for s in seeds:
            vals[s] = [sum_ for sum_ in []]
        for j in range(1, k + 1):
            for pts in itertools.combinations(range(len(zs)), j):
                counts = {}
                for s in seeds:
                    bits = []
                    for p in pts:
                        acc = 0
                        for i in range(k):
                            acc ^= gf_mul(s[i], gf_pow(zs[p], i, q), q)
                        bits.append(acc & 1)
                    counts[tuple(bits)] = counts.get(tuple(bits), 0) + 1
                checked += 1
                if len(counts) != 2 ** j or len(set(counts.values())) != 1:
                    bad += 1
print("   point sets checked:", checked, " non-uniform:", bad)

print("(5) lookup machine")
def jidx(x):
    return (1 << len(x)) - 1 + (int(x, 2) if x else 0)
ok = True
for d in range(0, 8):
    strs = [''.join(t) for L in range(d + 1) for t in itertools.product('01', repeat=L)]
    if max(jidx(x) for x in strs) != 2 ** (d + 1) - 2 or len({jidx(x) for x in strs}) != len(strs):
        ok = False
print("   j(x) is a bijection onto [0, 2^{d+1}-2] on {0,1}^{<=d}, d<=7:", ok)
ok = True
for d in range(0, 3):
    strs = [''.join(t) for L in range(d + 1) for t in itertools.product('01', repeat=L)]
    L = 2 ** (d + 1) - 1
    for k in range(1, len(strs) + 1):
        for S in itertools.combinations(strs, k):
            for lab in itertools.product((0, 1), repeat=k):
                cnt = sum(1 for w in range(2 ** L)
                          if all(((w >> (L - 1 - jidx(x))) & 1) == y for x, y in zip(S, lab)))
                if cnt * 2 ** k != 2 ** L:
                    ok = False
print("   Pr_w[phi_w extends D] = 2^-|D| for all binary D on {0,1}^{<=d}, d<=2:", ok)

print("(6) shared-coin counting")
ok = True
for k in range(2, 30):
    tot = sum(2.0 ** (-k) for b in range(2 ** k) if b not in (0, 2 ** k - 1)) if k <= 20 else (2 ** k - 2) * 2.0 ** (-k)
    if abs(tot - (1 - 2.0 ** (1 - k))) > 1e-12 or tot < 0.5:
        ok = False
for ep in [i / 100 for i in range(1, 101)]:
    prod = 1.0
    for j in range(1, 200):
        prod *= 1 + ep * 2.0 ** (-j)
    if not (prod - 1 <= math.exp(ep) - 1 <= 2 * ep + 1e-12):
        ok = False
print("   identities hold:", ok)

print("(7) padding function for rem:versions:Wrate")
ok = True
for h in (lambda m: m, lambda m: int(math.isqrt(m)), lambda m: m * m):
    for d in range(0, 60):
        N = 2 ** (d + 1)
        g = h(max(0, int(math.floor(math.log2(N))) - 1))
        if g != h(d):
            ok = False
print("   g(2^{d+1}) = h(d):", ok)

print("(8) two-point rate arithmetic")
for d in (2, 16, 1000, 10 ** 6):
    s = math.ceil(math.log2(d + 2))
    lower = math.log2(d) - 2 - 2   # K_F >= log d - 2 ; L_SFI <= 2 + c (c dropped)
    upper = 2 + math.log2(2 * (d + 2))  # + K(s,2) + O(1)
    print("   d=%-8d log d=%.3f  lower(no c)=%.3f  upper(no K,c)=%.3f  s=%d" % (d, math.log2(d), lower, upper, s))
