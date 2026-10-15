"""c8: the single-shortest-program ("Kolmogorov") version K_F on small data sets
(notes-final.md Thm 4.7, Prop 4.9; referee item M1).

Nothing here computes a Kolmogorov complexity.  The script checks the finite combinatorics
and the arithmetic that the proofs use.

 (a) Pigeonhole step of Thm 4.7(i).  For g_n := ceil(log2(n / log2 3)) - 1 we need
       2^{g_n} * log2(3) < n   (so 3^{2^{g_n}} < 2^n)   and   g_n > log2(n) - 2.
     Checked with 60-digit decimal arithmetic for every n in [2, 200000] and for
     n = 2^j, 2^j - 1, 2^j + 1 (j <= 200).
 (b) Explicit two-point covering family (Kleitman-Spencer construction, used only as an
     upper bound): the floor(N/2)-subsets of {0..N-1} that contain 0, read as N-bit columns.
     Every ordered pair of distinct columns shows all four label patterns (00, 01, 10, 11),
     so these N functions cover every two-point binary data set on C(N-1, floor(N/2)-1) inputs.
     Checked exhaustively for N = 3..14.  Also: for N <= 6 an independent exhaustive search
     (branch and bound over all 2^N columns) finds the maximum number of inputs that N functions
     can 2-cover, to compare with the construction.
 (c) Prop 4.9 (covering bound): with N := floor(2^k k (n+2) ln 2) + 1 truth tables on
     {0,1}^{<=n}, the expected number of uncovered labelled k-subsets is < 1 (exact count),
     so a covering family exists.  Random families of that size (seed 20261012) are tested
     for n in {1,2,3}, k in {1,2,3}; and log2 N <= k + log2(k(n+2)) is checked.
 (d) The padded version: n' := 2^ceil(log2(n+2)) - 2 >= n and log2(n'+2) < log2(n+2) + 1.

Seeded (20261012).  Output: c8_kf_covering.out.txt
"""
import itertools
import math
import random
from decimal import Decimal, getcontext

getcontext().prec = 60
SEED = 20261012
out = []

# (a) pigeonhole arithmetic
LOG2_3 = Decimal(3).ln() / Decimal(2).ln()


def g_of(n):
    # ceil(log2(n / log2 3)) - 1, computed exactly enough with 60 digits
    v = (Decimal(n) / LOG2_3).ln() / Decimal(2).ln()
    c = int(v.to_integral_value(rounding="ROUND_CEILING"))
    return c - 1


bad = 0
cnt = 0
ns = list(range(2, 200001))
for j in range(2, 201):
    ns += [2 ** j - 1, 2 ** j, 2 ** j + 1]
for n in ns:
    g = g_of(n)
    cnt += 1
    lhs = (Decimal(2) ** g) * LOG2_3
    lg = Decimal(n).ln() / Decimal(2).ln()
    if not (lhs < n and Decimal(g) > lg - 2):
        bad += 1
out.append(f"(a) pigeonhole arithmetic: {cnt} values of n checked; failures of [2^g log2 3 < n and g > log2 n - 2] = {bad}")
out.append(f"    examples: n=2 -> g={g_of(2)}, n=16 -> g={g_of(16)}, n=1000 -> g={g_of(1000)}, n=10^6 -> g={g_of(10**6)}")


# (b) Kleitman-Spencer construction and a small exact search
def four_patterns(u, v):
    s = set(zip(u, v))
    return len(s) == 4


ks_ok = True
rows = []
for N in range(3, 15):
    h = N // 2
    cols = []
    for S in itertools.combinations(range(1, N), h - 1):
        sset = set(S) | {0}
        cols.append(tuple(1 if i in sset else 0 for i in range(N)))
    M = len(cols)
    assert M == math.comb(N - 1, h - 1)
    ok = all(four_patterns(cols[i], cols[j]) for i in range(M) for j in range(i + 1, M))
    ks_ok &= ok
    rows.append((N, M, ok))
out.append("(b) Kleitman-Spencer columns (N functions, M inputs, all ordered pairs show 00,01,10,11):")
out.append("    " + ", ".join(f"N={N}:M={M}:{'ok' if ok else 'FAIL'}" for N, M, ok in rows))


def max_cover(N):
    verts = list(itertools.product((0, 1), repeat=N))
    adj = {v: set(w for w in verts if w != v and four_patterns(v, w)) for v in verts}
    best = [0]

    def extend(clique, cand):
        if len(clique) + len(cand) <= best[0]:
            return
        if not cand:
            best[0] = max(best[0], len(clique))
            return
        cand = list(cand)
        while cand:
            if len(clique) + len(cand) <= best[0]:
                return
            v = cand.pop()
            extend(clique + [v], [w for w in cand if w in adj[v]])

    extend([], verts)
    return best[0]


exact = {N: max_cover(N) for N in range(2, 7)}
out.append("    exhaustive maximum number of inputs that N binary total functions 2-cover: "
           + ", ".join(f"N={N}:{m}" for N, m in exact.items())
           + "  (construction: " + ", ".join(f"N={N}:{math.comb(N-1, N//2-1) if N >= 2 else 0}" for N in range(2, 7)) + ")")
# smallest N covering all inputs {0,1}^{<=n} (2^{n+1}-1 inputs) by the construction
cov = []
for n in range(1, 41):
    Minp = 2 ** (n + 1) - 1
    N = 3
    while math.comb(N - 1, N // 2 - 1) < Minp:
        N += 1
    cov.append((n, N))
out.append("    construction size N needed for all inputs of length <= n (n: N, log2 N): "
           + ", ".join(f"{n}:{N}:{math.log2(N):.2f}" for n, N in cov if n in (1, 2, 4, 8, 16, 32, 40)))
out.append(f"    N - n stays small: max over n<=40 of N - n = {max(N - n for n, N in cov)}")

# (c) covering bound with random families
rng = random.Random(SEED)
out.append("(c) Prop 4.9 covering: n, k, #inputs, #labelled k-sets, N, E[#uncovered] (exact), log2 N <= k+log2(k(n+2)), random families covering / trials")
for n in (1, 2, 3):
    inputs = list(range(2 ** (n + 1) - 1))
    I = len(inputs)
    for k in (1, 2, 3):
        if k > I:
            continue
        N = math.floor(2 ** k * k * (n + 2) * math.log(2)) + 1
        nsets = math.comb(I, k) * 2 ** k
        expected = nsets * (1 - 2 ** (-k)) ** N
        arith = math.log2(N) <= k + math.log2(k * (n + 2))
        trials = 40 if I <= 7 else 15
        full = 0
        for _ in range(trials):
            fam = [[rng.randrange(2) for _ in inputs] for _ in range(N)]
            allc = True
            for S in itertools.combinations(inputs, k):
                pats = {tuple(f[s] for s in S) for f in fam}
                if len(pats) < 2 ** k:
                    allc = False
                    break
            full += allc
        out.append(f"    n={n} k={k} inputs={I} sets={nsets} N={N} E[uncovered]={expected:.4f} (<1: {expected < 1}) arith={arith} covering={full}/{trials}")

# (d) padding
padok = True
for n in range(0, 100000):
    s = math.ceil(math.log2(n + 2))
    npad = 2 ** s - 2
    if not (npad >= n and math.log2(npad + 2) < math.log2(n + 2) + 1):
        padok = False
out.append(f"(d) padding n' = 2^ceil(log2(n+2)) - 2: n' >= n and log2(n'+2) < log2(n+2)+1 for all n < 100000: {padok}")

text = "\n".join(out) + "\n"
print(text, end="")
with open(__file__.replace(".py", ".out.txt"), "w") as f:
    f.write(text)
