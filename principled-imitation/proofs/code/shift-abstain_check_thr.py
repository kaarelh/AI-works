# Referee check of Theorem 3.3(a),(c): exact minimum over deterministic learners of sum_s Sil(s)
# for N thresholds h_s(x)=1[x<=s], s in {0..N-1}, inputs 1..N-1 in order, at most Q questions.
from functools import lru_cache
import sys
sys.setrecursionlimit(10000)
def solve(N, Q):
    @lru_cache(None)
    def f(x, lo, hi, q):
        if x > N-1 or lo > hi: return 0
        # predict p
        ones = max(0, hi - max(lo, x) + 1)   # s>=x -> label 1
        zeros = (hi - lo + 1) - ones
        best = min(zeros, ones) + f(x+1, lo, hi, q)  # predict 1 wrong on zeros; predict 0 wrong on ones
        if q > 0:
            best = min(best, f(x+1, max(lo, x), hi, q-1) + f(x+1, lo, min(hi, x-1), q-1))
        return best
    return f(1, 0, N-1, Q)
bad = 0
for N in range(2, 41):
    for Q in range(0, 8):
        opt = solve(N, Q)
        lb = (N*N/(Q+1) - (Q+1))/4
        if opt < lb - 1e-9: bad += 1; print("VIOLATION", N, Q, opt, lb)
        if (Q+1) <= N/2 and opt*(Q+1)/N < 3/16 - 1e-9: bad += 1; print("VIOL 3/16", N, Q)
        if N % (Q+1) == 0:
            b = N//(Q+1); cval = N*(b-1)/2
            if opt > cval + 1e-9: bad += 1; print("(c) learner beats optimum?", N, Q)
print("violations:", bad)
for N, Q in [(240, 0), (240, 1), (240, 11)]:
    print(N, Q, "E[Sil](Q+1)/N =", round(solve(N, Q)/N*(Q+1)/N, 4))
