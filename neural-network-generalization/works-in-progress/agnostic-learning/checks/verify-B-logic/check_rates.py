"""Referee checks for B.md (logic lens): sample-size claims and exponent bookkeeping.
(1) least n with the DISPLAYED Exc_n of Thm 6.3 (K <= 2 n^theta) <= eps, vs. the script's K = n^theta + 1 version;
(2) closed-form n0 of Thm 6.3 really implies displayed Exc_n <= eps (spot check on a grid of parameters);
(3) Cor 8.1 at H = 1: sign of beta across alpha in (0, 1/4);
(4) Prop 9.1(c) constant (1 + 5/(4L)) 4^{1/L} <= 3.25 and 2^{1/L}/sqrt(L) <= 1.
"""
import math

def D(n, d, H):
    return math.sqrt(2 * (d + 1) * math.log(n + 1)) + (H - 1) / 2

def exc_displayed(n, th, H, d, Es, U, dl):
    return ((Es + 1) * n ** (-th) + 8 * (2 / H) ** (H / 2) * D(n, d, H) * n ** (-(1 - th * H) / 2)
            + (4 + (U + 1) ** 2) * math.sqrt(math.log(2 / dl) / (2 * n)))

def exc_exactK(n, th, H, d, Es, U, dl):
    K = n ** th + 1
    return ((Es + 1) * n ** (-th) + 8 * (K / H) ** (H / 2) * D(n, d, H) / math.sqrt(n)
            + (4 + (U + 1) ** 2) * math.sqrt(math.log(2 / dl) / (2 * n)))

def least_log10(f, eps):
    lo, hi = 0.0, 300.0   # log10 n
    if f(10 ** hi) > eps: return float('inf')
    for _ in range(200):
        mid = (lo + hi) / 2
        if f(10 ** mid) <= eps: hi = mid
        else: lo = mid
    return hi

def n0_closed(th, H, d, Es, U, dl, eps):
    g = 1 - th * H; c2 = (2 / H) ** (H / 2)
    t = [(3 * (Es + 1) / eps) ** (1 / th),
         (48 * c2 / eps * math.sqrt(4 * (d + 1) / g)) ** (4 / g),
         9 * (4 + (U + 1) ** 2) ** 2 * math.log(2 / dl) / (2 * eps ** 2)]
    if H > 1: t.append((24 * c2 * (H - 1) / eps) ** (2 / g))
    return max(t)

print("(1) Thm 6.3 sample sizes, L=3 (H=2), d=10, m=B=1, theta=1/4, delta=0.05")
H, d, m, B, dl = 2, 10, 1, 1, 0.05
L = H + 1; Es = d * (d + 1) * B ** 2 + 2 * (L - 1) * m ** 2 * B ** 2; U = m * B
for eps in [0.1, 0.01]:
    a = least_log10(lambda n: exc_displayed(n, 0.25, H, d, Es, U, dl), eps)
    b = least_log10(lambda n: exc_exactK(n, 0.25, H, d, Es, U, dl), eps)
    print(f"   eps={eps}: displayed Exc_n first <= eps at 10^{a:.2f};  K=n^theta+1 version at 10^{b:.2f};"
          f"  closed-form n0 = 10^{math.log10(n0_closed(0.25, H, d, Es, U, dl, eps)):.2f}")
print("   value of displayed Exc_n at n=10^13.4:", round(exc_displayed(10 ** 13.4, 0.25, H, d, Es, U, dl), 4))

print("(2) closed-form n0 => displayed Exc_n <= eps, at n0 and at 10 n0, 1e3 n0 (grid)")
bad = 0; cnt = 0
for H in [1, 2, 3, 4]:
    L = H + 1
    for d in [1, 3, 10, 50]:
        for (m, B) in [(1, 1), (3, 0.5), (5, 2)]:
            Es = d * (d + 1) * B ** 2 + 2 * (L - 1) * m ** 2 * B ** 2; U = m * B
            for th in [0.05, 0.5 / H, 0.9 / H] if H > 1 else [0.05, 0.3, 0.6, 0.9]:
                for eps in [0.3, 0.05]:
                    for dl in [0.1, 1e-6]:
                        n0 = n0_closed(th, H, d, Es, U, dl, eps)
                        for f in [1, 10, 1000]:
                            n = n0 * f
                            if n > 1e300: continue
                            cnt += 1
                            if exc_displayed(n, th, H, d, Es, U, dl) > eps * (1 + 1e-12):
                                bad += 1; print("   VIOLATION", H, d, m, B, th, eps, dl, f)
print(f"   {cnt} cases, {bad} violations")

print("(3) Cor 8.1, H=1: beta = min{(1-4a)/3, 1/2-4a}")
for a in [0.05, 0.1, 0.12, 0.125, 0.15, 0.2, 0.24]:
    beta = min((1 - 4 * a) / 3, 0.5 - 4 * a)
    print(f"   alpha={a:.3f}: beta={beta:+.4f}")

print("(4) Prop 9.1(c) constants")
for L in range(2, 9):
    print(f"   L={L}: (1+5/(4L)) 4^(1/L) = {(1 + 5 / (4 * L)) * 4 ** (1 / L):.4f};  2^(1/L)/sqrt(L) = {2 ** (1 / L) / math.sqrt(L):.4f}")
