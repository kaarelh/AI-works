"""Phase-transition window on the noisy cube family (x uniform on {-1,1}^d, y fair sign, n = M = 2^d), zero competitor.
Negative side (Prop. 7.3): excess >= (sqrt(1/e - M^{-1/3}) - sqrt(R/M))_+^2 with R = c(K_mem(t)+1) + 9 n t^2,
   K_mem(t) = beta^2 d^3 + (H+1) max{2, 9/(4t), ((d+1)^2 n)^{1/H}},  beta = max{1, ln(2(d+1)sqrt(n)/t)/2}  (t optimized).
Positive side (the bound of Thm 7.4(a), for general c: Prop. 6.1 through Remark 6.5 with w' = 0, and Lemma 5.3(a)
   with K = n/c + 1): excess <= c/n + 8((n/c+1)/H)^{H/2} D_n/sqrt(n) + 5 sqrt(ln(2/delta)/(2n)),  delta = 0.05.
c_neg = largest c certified to give excess >= 0.2;  c_pos = smallest c certified to give excess <= 0.1.
Both log_n(c) should tend to 1 - 1/H, with c_neg < c_pos (the window is polylogarithmic)."""
import math
import numpy as np

def neg_bound(c, d, H):
    n = M = 2.0 ** d
    best = 0.0
    for t in np.logspace(-8, math.log10(0.25), 200):
        beta = max(1.0, 0.5 * math.log(2 * (d + 1) * math.sqrt(n) / t))
        Kmem = beta ** 2 * d ** 3 + (H + 1) * max(2.0, 9 / (4 * t), ((d + 1) ** 2 * n) ** (1 / H))
        R = c * (Kmem + 1) + 9 * n * t ** 2
        q = 1 / math.e - M ** (-1 / 3)
        best = max(best, max(0.0, math.sqrt(max(q, 0)) - math.sqrt(R / M)) ** 2)
    return best

def pos_bound(c, d, H, delta=0.05):
    n = 2.0 ** d
    Dn = math.sqrt(2 * (d + 1) * math.log(n + 1)) + (H - 1) / 2
    return c / n + 8 * ((n / c + 1) / H) ** (H / 2) * Dn / math.sqrt(n) + 5 * math.sqrt(math.log(2 / delta) / (2 * n))

def bisect_logc(f, lo, hi, want_true_at_lo):
    for _ in range(100):
        mid = (lo + hi) / 2
        if f(mid) == want_true_at_lo: lo = mid
        else: hi = mid
    return lo

print(" H    d    log_n(c_neg)  log_n(c_pos)   1-1/H   c_pos/c_neg")
for H in [2, 3]:
    for d in [40, 60, 80, 120, 200, 400]:
        n = 2.0 ** d; ln_n = d * math.log(2)
        lcn = bisect_logc(lambda lc: neg_bound(math.exp(lc), d, H) >= 0.2, 0.0, ln_n, True)
        lcp = bisect_logc(lambda lc: pos_bound(math.exp(lc), d, H) <= 0.1, ln_n, 0.0, True)
        print(f" {H}  {d:4d}     {lcn/ln_n:7.4f}      {lcp/ln_n:7.4f}     {1-1/H:6.4f}   {math.exp(lcp-lcn):10.3e}")
