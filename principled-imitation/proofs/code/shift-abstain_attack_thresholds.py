"""Independent exact checks (written without looking at the prover's scripts):
(A) Theorem 3.3(a): N thresholds h_s(x)=1[x<=s], s in {0..N-1}, inputs 1..N-1 in increasing order,
    labels only on questions, at most Q questions. Exact minimum over deterministic learners of
    sum_s Sil(s) by dynamic programming over (position, consistent interval, questions left);
    abstaining is dominated by predicting (cost of an abstention = 1 >= cost of a prediction), so it is
    omitted. Compare with the bound (N^2/(Q+1) - (Q+1))/4 and with the learner of Theorem 3.3(c).
(B) Proposition 4.6: every label shown, adversarial order; largest number of thresholds a rule can
    handle with at most k wrong answers and at most m wrong-or-abstained rounds, by recursion over the
    number of consistent thresholds; compare with C(m+1, <=k+1) - 1."""
from functools import lru_cache
from math import comb
import sys
sys.setrecursionlimit(100000)
def exact_min(N, Q):
    @lru_cache(None)
    def V(x, lo, hi, q):
        if x > N-1: return 0
        n1 = sum(1 for s in range(lo, hi+1) if s >= x)   # members with label 1 at x
        n0 = (hi-lo+1) - n1
        best = min(n0, n1) + V(x+1, lo, hi, q)          # predict the majority-cost-minimising label
        best = min(best, n0 + V(x+1, lo, hi, q), n1 + V(x+1, lo, hi, q))
        if q > 0 and n0 > 0 and n1 > 0:
            best = min(best, V(x+1, max(lo, x), hi, q-1) + V(x+1, lo, min(hi, x-1), q-1))
        return best
    return V(1, 0, N-1, Q)
print("(A) Theorem 3.3(a): exact min of N*E[Sil] vs bound (N^2/(Q+1)-(Q+1))/4")
viol = 0
for N in (2, 3, 5, 8, 13, 20, 32, 48):
    row = []
    for Q in range(0, 6):
        if Q+1 > N: break
        v = exact_min(N, Q); b = (N*N/(Q+1) - (Q+1))/4
        if v < b - 1e-9: viol += 1
        row.append(f"Q={Q}: {v} (bnd {b:.2f})")
    print(f"  N={N:3d}  " + "; ".join(row))
print(f"  violations of the bound: {viol}")
print("  Theorem 3.3(c) learner, N divisible by Q+1: N*E[Sil] = N*(N/(Q+1)-1)/2")
for N, Q in ((12, 1), (12, 2), (12, 3), (48, 3), (48, 5)):
    print(f"  N={N} Q={Q}: formula {N*(N/(Q+1)-1)/2:.1f}, exact optimum {exact_min(N, Q)}")

print("(B) Proposition 4.6: largest N handled vs C(m+1,<=k+1)-1")
@lru_cache(None)
def win(n, k, m):
    # rule guarantees <=k wrong and <=m wrong-or-abstained rounds against n consistent thresholds
    if n <= 1: return True
    for n2 in range(1, n):          # adversary shows an input splitting n into n2 (label 0) / n1 (label 1)
        n1 = n - n2
        ok = False
        if m >= 1 and win(n1, k, m-1) and win(n2, k, m-1): ok = True                      # abstain
        if not ok and win(n1, k, m) and (n2 == 0 or (k >= 1 and m >= 1 and win(n2, k-1, m-1))): ok = True  # say 1
        if not ok and win(n2, k, m) and (k >= 1 and m >= 1 and win(n1, k-1, m-1)): ok = True  # say 0
        if not ok: return False
    return True
def F(k, m): return sum(comb(m+1, i) for i in range(0, k+2)) - 1
bad = 0
for k in range(0, 4):
    vals = []
    for m in range(0, 8):
        n = 1
        while win(n+1, k, m) and n < 200: n += 1
        vals.append(n)
        if n != F(k, m) and n < 200: bad += 1
    print(f"  k={k}: game {vals}  formula {[F(k,m) for m in range(8)]}")
print(f"  mismatches (below cap 200): {bad}")
