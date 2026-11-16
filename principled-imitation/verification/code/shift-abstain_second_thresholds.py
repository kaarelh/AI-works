"""Second check, shift-abstain: Theorem 3.3(a),(c) and Corollary 3.6(a) (N7(a)).

Exact minimum of sum_s Sil(s) over deterministic learners without abstention
that ask at most Q questions on every run, N thresholds h_s(x)=1[x<=s],
s in {0..N-1}, inputs 1..N-1 in order (equivalently h+1 members on inputs 1..h).

Along the all-ones path the learner asks at q_1<...<q_m (m<=Q) and predicts
fixed labels in the gaps. After seeing a 0 it knows all later labels (0).
For a gap position x in block j (members q_{j-1}..q_j-1), predicting 1 is wrong
for the r members of the block below x; predicting 0 is wrong for the b_j - r
members of the block at or above x AND for all R_j members of later blocks
(they are still on the all-ones path at x).  So the exact cost of block j is
sum_{r=1}^{b_j-1} min(r, b_j - r + R_j).  We minimise over block partitions.
Abstentions can be replaced by predicting 1 (Step 0), and randomised learners
are mixtures of deterministic ones, so this minimum is the exact optimum of
N*E[Sil+Abs] for learners with Qu<=Q on every run.
"""
from functools import lru_cache
from fractions import Fraction as F

def block_cost(b, R):
    return sum(min(r, b - r + R) for r in range(1, b))

def table(N, Qmax):
    """T[q][start] = min cost for members start..N-1 with q questions left."""
    bc = [[block_cost(b, R) for R in range(N + 1)] for b in range(N + 1)]
    prev = [bc[N - st][0] for st in range(N + 1)]
    T = [prev]
    for q in range(1, Qmax + 1):
        cur = []
        for st in range(N + 1):
            rem = N - st
            best = bc[rem][0]
            for b in range(1, rem):
                c = bc[b][rem - b] + prev[st + b]
                if c < best:
                    best = c
            cur.append(best)
        T.append(cur)
        prev = cur
    return T

_cache = {}
def opt(N, Q):
    if N not in _cache:
        _cache[N] = table(N, N)
    return _cache[N][min(Q, N)][0]

bad = 0
rows = []
for N in range(2, 81):
    for Q in range(0, N // 2):
        v = F(opt(N, Q), N)  # = min E[Sil] (uniform s)
        lb = F(1, 4) * (F(N, Q + 1) - F(Q + 1, N))
        if v < lb:
            bad += 1
            print("VIOLATION (a)", N, Q, v, lb)
        if Q + 1 <= N / 2 and v * (Q + 1) < F(3 * N, 16):
            bad += 1
            print("VIOLATION product", N, Q)
        if N % (Q + 1) == 0:
            b = N // (Q + 1)
            cval = F(b - 1, 2)  # learner of (c)
            if v > cval:
                bad += 1
                print("VIOLATION (c) learner beats optimum?", N, Q)
            if cval >= F(N, 2 * (Q + 1)):
                bad += 1
                print("VIOLATION (c) strict", N, Q)
        if N in (16, 48, 80) and Q in (0, 1, 3, 7):
            rows.append((N, Q, float(v), float(lb), float(v * (Q + 1) / N)))
print("checked N=2..80, Q=0..N/2-1; violations:", bad)
print("N  Q  minE[Sil]  bound(a)  minE[Sil]*(Q+1)/N")
for r in rows:
    print("%3d %2d %9.4f %9.4f %8.4f" % r)
print("N=48,Q=3: optimum N*E[Sil] =", opt(48, 3), "; learner (c):", 48 * (48 // 4 - 1) // 2)

# Corollary 3.6(a) consequence: E[Sil+Abs]<=s for all members forces
# Q >= min{(h+1)/2, 3(h+1)/(16 s)} - 1.  Check: for every h, s on a grid,
# the least Q with opt(h+1,Q)/(h+1) <= s is at least that bound.
bad2 = 0
for h in range(1, 100):
    N = h + 1
    for s in [0.05, 0.1, 0.25, 0.5, 1, 2, 4, 8]:
        Qmin = next(Q for Q in range(0, N + 1) if opt(N, Q) <= s * N)
        bound = min((h + 1) / 2, 3 * (h + 1) / (16 * s)) - 1
        if Qmin < bound - 1e-12:
            bad2 += 1
            print("VIOLATION 3.6(a)", h, s, Qmin, bound)
print("Corollary 3.6(a) consequence, h=1..99, 8 values of s; violations:", bad2)
