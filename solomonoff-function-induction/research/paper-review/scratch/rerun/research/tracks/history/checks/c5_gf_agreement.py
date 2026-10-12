"""c5: the counting bound behind Thm 5.4 and Lemma 5.5 (the 'ab' example).

F = GF(2^m).  For a function G: F -> F let
    N(G) = #{ (a,b) in F x F : a != b, G(a) + G(b) = a*b }.
Claim used in notes.md: N(G) <= 2^m + 2^{3m/2} for every G (character-sum bound; the
matrix H_u[a][b] = (-1)^{Tr(u a b)} satisfies H_u H_u^T = 2^m I for u != 0).
Consequences: sum over triples (a,b,r), a != b, of M_F({(a,r),(b,r+ab)}) <= max_G N(G), so for
uniform triples E[L_F] >= log2(#triples) - log2(max_G N(G)) >= 3m/2 - 2.

This script
 (1) verifies H_u H_u^T = 2^m I for m = 2..6 and all u != 0;
 (2) computes max_G N(G) exactly for m = 2 (all 4^4 functions) and m = 3 (all 8^7 functions with
     G(0) = 0, which is w.l.o.g. since adding a constant to G does not change N);
 (3) for m = 4..7 runs seeded local search (lower estimates of max N) and evaluates N on random G;
 (4) compares with the bound and prints the implied expected-loss lower bound.
Seed 5.  Output saved to c5_gf_agreement.out.
"""
import itertools, math, random
import numpy as np

SEED = 5
random.seed(SEED)
np_rng = np.random.default_rng(SEED)
IRRED = {2: 0b111, 3: 0b1011, 4: 0b10011, 5: 0b100101, 6: 0b1000011, 7: 0b10000011, 8: 0b100011011}

def gf_mul(a, b, m):
    poly = IRRED[m]
    r = 0
    while b:
        if b & 1:
            r ^= a
        b >>= 1
        a <<= 1
        if a >> m:
            a ^= poly
    return r

def mul_table(m):
    q = 1 << m
    return np.array([[gf_mul(a, b, m) for b in range(q)] for a in range(q)], dtype=np.int64)

def trace(x, m):
    t, y = 0, x
    for _ in range(m):
        t ^= y
        y = gf_mul(y, y, m)
    assert t in (0, 1)
    return t

# (1)
for m in range(2, 7):
    q = 1 << m
    MT = mul_table(m)
    tr = np.array([trace(x, m) for x in range(q)])
    for u in range(1, q):
        H = np.where(tr[MT[u][MT]] == 1, -1, 1)  # H[a][b] = (-1)^Tr(u*a*b)
        assert np.array_equal(H @ H.T, q * np.eye(q, dtype=np.int64)), (m, u)
print("(1) H_u H_u^T = 2^m I verified for m = 2..6, all u != 0")

def N_of(G, MT):
    q = len(G)
    A = (G[:, None] ^ G[None, :]) == MT
    np.fill_diagonal(A, False)
    return int(A.sum())

results = {}
# (2) exact for m = 2, 3
for m in (2, 3):
    q = 1 << m
    MT = mul_table(m)
    best = 0
    # enumerate G with G(0) = 0 in chunks
    rest = q - 1
    total = q ** rest
    chunk = 1 << 16
    pairs = [(a, b) for a in range(q) for b in range(q) if a != b]
    pa = np.array([p[0] for p in pairs]); pb = np.array([p[1] for p in pairs])
    target = MT[pa, pb]
    for start in range(0, total, chunk):
        idx = np.arange(start, min(start + chunk, total), dtype=np.int64)
        G = np.zeros((len(idx), q), dtype=np.int64)
        v = idx.copy()
        for j in range(1, q):
            G[:, j] = v % q
            v //= q
        cnt = ((G[:, pa] ^ G[:, pb]) == target[None, :]).sum(axis=1)
        best = max(best, int(cnt.max()))
    bound = q + q ** 1.5
    triples = q * (q - 1) * q
    results[m] = (best, bound)
    print(f"(2) m={m}: exact max_G N(G) = {best}; bound 2^m + 2^(3m/2) = {bound:.1f}; "
          f"E[L_F] >= log2(#triples/maxN) = {math.log2(triples / best):.3f} bits vs xi-loss m = {m}")

# (3) local search for m = 4..7
def local_search(m, iters, restarts):
    q = 1 << m
    MT = mul_table(m)
    best = 0
    for r in range(restarts):
        G = np_rng.integers(0, q, size=q)
        cur = N_of(G, MT)
        for it in range(iters):
            a = random.randrange(q)
            old = G[a]
            # best value for G[a] given the others: count b != a with G[a] = G[b] ^ a*b
            vals = (G ^ MT[a]); vals[a] = -1
            counts = np.bincount(vals[vals >= 0], minlength=q)
            newv = int(np.argmax(counts))
            G[a] = newv
            cur = N_of(G, MT)
        best = max(best, cur)
    return best

for m in range(4, 8):
    q = 1 << m
    MT = mul_table(m)
    rand_vals = [N_of(np_rng.integers(0, q, size=q), MT) for _ in range(200)]
    ls = local_search(m, iters=20 * q, restarts=10)
    bound = q + q ** 1.5
    triples = q * (q - 1) * q
    print(f"(3) m={m}: random G mean N = {np.mean(rand_vals):.1f} (~2^m = {q}); local-search max N = {ls}; "
          f"bound = {bound:.1f}; implied E[L_F] >= {math.log2(triples / bound):.2f} (from bound) vs m = {m}")
    assert ls <= bound
for m, (best, bound) in results.items():
    assert best <= bound
print("ALL CHECKS PASSED")
