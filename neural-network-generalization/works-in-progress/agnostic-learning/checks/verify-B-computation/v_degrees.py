"""Degree of the closed-form n0 of Thm 6.3 in d, m, B and 1/eps (log-log slopes at large arguments)."""
import mpmath as mp
from v_samples import n0_63
def slope(f, x, h=mp.mpf(1)):
    return float((mp.log(f(x * mp.e ** h)) - mp.log(f(x))) / h)
for H, th in [(2, mp.mpf(1) / 4), (2, mp.mpf('0.45')), (1, mp.mpf('0.8')), (3, mp.mpf('0.3'))]:
    L = H + 1
    def n0(d=10, m=1, B=1, eps=mp.mpf('0.1')):
        Es = d * (d + 1) * B ** 2 + 2 * (L - 1) * m ** 2 * B ** 2
        return n0_63(th, H, d, Es, m * B, mp.mpf('0.05'), eps)
    sd = slope(lambda d: n0(d=d), mp.mpf(10) ** 8)
    sm = slope(lambda m: n0(m=m), mp.mpf(10) ** 8)
    se = slope(lambda e: n0(eps=1 / e), mp.mpf(10) ** 8)
    print(f"H={H} theta={float(th):.3f}: slope in d = {sd:.3f}  (2/theta={float(2/th):.3f}, 2/(1-theta H)={float(2/(1-th*H)):.3f});"
          f"  slope in m = {sm:.3f} (2/theta={float(2/th):.3f}, 4);  slope in 1/eps = {se:.3f} (max(1/theta,4/(1-theta H))={float(max(1/th, 4/(1-th*H))):.3f})")
