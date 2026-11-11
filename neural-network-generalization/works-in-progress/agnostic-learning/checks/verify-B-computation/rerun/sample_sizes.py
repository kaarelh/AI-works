"""Explicit sample sizes, clipped outputs (all in log space).
Route 2 (Theorem 6.2):  Exc2(n) = (E*+1) n^-theta + 8 (K/H)^{H/2} D_n / sqrt(n) + (4+(U+1)^2) sqrt(ln(2/delta)/(2n)),
   K = n^theta + 1, D_n = sqrt(2(d+1) ln(n+1)) + (H-1)/2.
   Closed-form sufficient n0 (Theorem 6.2):
   n0 = max{ (3(E*+1)/eps)^{1/theta}, (48 (2/H)^{H/2} sqrt(4(d+1)/(1-theta H))/eps)^{4/(1-theta H)},
             (24 (2/H)^{H/2} (H-1)/eps)^{2/(1-theta H)},  9(4+(U+1)^2)^2 ln(2/delta)/(2 eps^2) }.
Route 1 (Theorem 6.1): Exc1(n) = (E*+1) n^-theta + 8a + 4 sqrt((ln|H_{K,a}| + ln(2/delta))/(2n)) + (U+1)^2 sqrt(ln(2/delta)/(2n)),
   a = eps/32, ln|H_{K,a}| from paper.tex (cover_degree.log_lnH)."""
import math
import numpy as np
from cover_degree import log_lnH

def exc2(t, th, H, d, Es, U, dl):          # t = ln n
    lnK = float(np.logaddexp(th * t, 0.0))
    Dn = math.sqrt(2 * (d + 1) * float(np.logaddexp(t, 0.0))) + (H - 1) / 2
    return ((Es + 1) * math.exp(-th * t) + 8 * math.exp((H / 2) * (lnK - math.log(H)) - t / 2) * Dn
            + (4 + (U + 1) ** 2) * math.sqrt(math.log(2 / dl) / 2) * math.exp(-t / 2))

def exc1(t, th, L, d, Es, U, dl, eps):
    a = eps / 32; lnK = float(np.logaddexp(th * t, 0.0))
    llH = log_lnH(lnK, math.log(a), d, L)
    dev = 4 * math.exp(0.5 * (float(np.logaddexp(llH, math.log(math.log(2 / dl)))) - math.log(2) - t))
    return (Es + 1) * math.exp(-th * t) + 8 * a + dev + (U + 1) ** 2 * math.sqrt(math.log(2 / dl) / 2) * math.exp(-t / 2)

def least(f, lo, hi):
    if f(hi) > 0: return math.inf
    for _ in range(200):
        mid = (lo + hi) / 2
        if f(mid) <= 0: hi = mid
        else: lo = mid
    return hi

def log10_n0_closed(th, H, d, Es, U, dl, eps):
    g = 1 - th * H; c2 = (2 / H) ** (H / 2)
    terms = [(1 / th) * math.log10(3 * (Es + 1) / eps),
             (4 / g) * math.log10(48 * c2 * math.sqrt(4 * (d + 1) / g) / eps),
             math.log10(9 * (4 + (U + 1) ** 2) ** 2 * math.log(2 / dl) / (2 * eps ** 2))]
    if H > 1: terms.append((2 / g) * math.log10(24 * c2 * (H - 1) / eps))
    return max(terms)

dl = 0.05
print("Route 2 (Rademacher), clipped, theta = 1/(H+2):  least n with bound <= eps, and closed-form n0 (log10)")
print("  L    d   m  B   eps   log10(least n)   log10(n0 closed form)")
for (L, d, m, B) in [(2, 10, 1, 1), (3, 10, 1, 1), (3, 10, 4, 2), (4, 10, 4, 2), (3, 100, 4, 2)]:
    H = L - 1; th = 1 / (H + 2)
    Es = d * (d + 1) * B ** 2 + 2 * (L - 1) * m ** 2 * B ** 2; U = m * B
    for eps in [0.1, 0.01]:
        t = least(lambda t: exc2(t, th, H, d, Es, U, dl) - eps, 0.0, 2000.0)
        print(f"  {L}  {d:4d} {m:2d} {B:2d}  {eps:5.2f}      {t/math.log(10):8.2f}          {log10_n0_closed(th, H, d, Es, U, dl, eps):8.2f}")

print("\nRoute 1 (energy cover), clipped:  least n with bound <= eps (log10)")
for (L, d, m, B, th) in [(2, 10, 1, 1, 0.25), (3, 10, 1, 1, 1 / 16), (3, 10, 1, 1, 1 / 32)]:
    Es = d * (d + 1) * B ** 2 + 2 * (L - 1) * m ** 2 * B ** 2; U = m * B
    for eps in [0.1]:
        t = least(lambda t: exc1(t, th, L, d, Es, U, dl, eps) - eps, 0.0, 600000.0)
        print(f"  L={L} d={d} m={m} B={B} theta={th:.4f} eps={eps}:  log10(least n) = {t/math.log(10):.1f}")
