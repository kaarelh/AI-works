"""Independent check of the explicit sample sizes of B.md Theorems 6.2, 6.3, 6.4 (all in log space, mpmath).

Thm 6.3:  Exc_n = (E*+1) n^-th + 8 (2/H)^{H/2} D_n n^{-(1-th H)/2} + (4+(U+1)^2) sqrt(ln(2/de)/(2n)),
          D_n = sqrt(2(d+1) ln(n+1)) + (H-1)/2;  n0 = max of 4 entries (3rd omitted if H=1).
Thm 6.4:  Exc' = (E*+1) n^-th + 4(1+sqrt2)(2/H)^{H/2} D_n n^{-(1-th L)/2} + [(1+sqrt2)^2 n^th + (U+1)^2] sqrt(ln(2/de)/(2n)).
Thm 6.2:  Exc = (E*+1) n^-th + eps/4 + 4 sqrt((ln|H_{K,a}| + ln(2/de))/(2n)) + (U+1)^2 sqrt(ln(2/de)/(2n)),
          K = n^th + 1, a = eps/32, exact cover count from paper.tex; n1 = max{...} as in B.md.
For random parameters we check Exc <= eps at n = n0 * {1, 1.0001, 2, 1e3, 1e30} (it must hold for all n >= n0)."""
import math, random
import mpmath as mp
mp.mp.dps = 50
from v_lemma42 import exact as cover_exact   # exact cover count (paper.tex parameters)

def Dn(n, d, H):
    return mp.sqrt(2 * (d + 1) * mp.log(n + 1)) + mp.mpf(H - 1) / 2

def exc63(n, th, H, d, Es, U, de):
    return ((Es + 1) * n ** (-th) + 8 * (mp.mpf(2) / H) ** (mp.mpf(H) / 2) * Dn(n, d, H) * n ** (-(1 - th * H) / 2)
            + (4 + (U + 1) ** 2) * mp.sqrt(mp.log(2 / de) / (2 * n)))

def exc63_sharp(n, th, H, d, Es, U, de):   # with (K/H)^{H/2}, K = n^th + 1 (the bound before K <= 2 n^th)
    K = n ** th + 1
    return ((Es + 1) * n ** (-th) + 8 * (K / H) ** (mp.mpf(H) / 2) * Dn(n, d, H) / mp.sqrt(n)
            + (4 + (U + 1) ** 2) * mp.sqrt(mp.log(2 / de) / (2 * n)))

def n0_63(th, H, d, Es, U, de, eps):
    g = 1 - th * H; c2 = (mp.mpf(2) / H) ** (mp.mpf(H) / 2)
    e = [(3 * (Es + 1) / eps) ** (1 / th),
         (48 * c2 / eps * mp.sqrt(4 * (d + 1) / g)) ** (4 / g),
         9 * (4 + (U + 1) ** 2) ** 2 * mp.log(2 / de) / (2 * eps ** 2)]
    if H > 1: e.append((24 * c2 * (H - 1) / eps) ** (2 / g))
    return max(e)

def exc64(n, th, H, d, Es, U, de):
    L = H + 1; s2 = 1 + mp.sqrt(2)
    return ((Es + 1) * n ** (-th) + 4 * s2 * (mp.mpf(2) / H) ** (mp.mpf(H) / 2) * Dn(n, d, H) * n ** (-(1 - th * L) / 2)
            + (s2 ** 2 * n ** th + (U + 1) ** 2) * mp.sqrt(mp.log(2 / de) / (2 * n)))

def n0_64(th, H, d, Es, U, de, eps):
    L = H + 1; g = 1 - th * L; s2 = 1 + mp.sqrt(2); c2 = (mp.mpf(2) / H) ** (mp.mpf(H) / 2)
    e = [(3 * (Es + 1) / eps) ** (1 / th),
         (24 * s2 * c2 / eps * mp.sqrt(4 * (d + 1) / g)) ** (4 / g),
         (6 * s2 ** 2 * mp.sqrt(mp.log(2 / de) / 2) / eps) ** (2 / (1 - 2 * th)),
         18 * (U + 1) ** 4 * mp.log(2 / de) / eps ** 2]
    if H > 1: e.append((12 * s2 * c2 * (H - 1) / eps) ** (2 / g))
    return max(e)

random.seed(1)
bad63 = bad64 = 0; trials = 0; tight63 = []; tight64 = []
for _ in range(3000):
    H = random.choice([1, 2, 3, 4, 6]); L = H + 1
    d = random.choice([1, 2, 5, 10, 100, 1000]); m = random.choice([1, 2, 10, 100]); B = random.choice([0.1, 1, 3, 30])
    eps = mp.mpf(10) ** random.uniform(-4, -0.01); de = mp.mpf(10) ** random.uniform(-8, -0.01)
    Es = d * (d + 1) * B ** 2 + 2 * (L - 1) * m ** 2 * B ** 2; U = m * B
    th = mp.mpf(random.uniform(0.02, 0.98)) / H
    n0 = n0_63(th, H, d, Es, U, de, eps)
    vals = [exc63(n0 * f, th, H, d, Es, U, de) for f in (1, mp.mpf('1.0001'), 2, 1e3, 1e30)]
    trials += 1
    if max(vals) > eps: bad63 += 1
    tight63.append(float(vals[0] / eps))
    th4 = mp.mpf(random.uniform(0.02, 0.98)) / L
    n4 = n0_64(th4, H, d, Es, U, de, eps)
    v4 = [exc64(n4 * f, th4, H, d, Es, U, de) for f in (1, 2, 1e3, 1e30)]
    if max(v4) > eps: bad64 += 1
    tight64.append(float(v4[0] / eps))
print(f"Thm 6.3: {trials} random settings, violations of Exc_n <= eps for n >= n0: {bad63};  max Exc_{{n0}}/eps = {max(tight63):.3f}")
print(f"Thm 6.4: {trials} random settings, violations of Exc'   <= eps for n >= n0': {bad64};  max Exc'/eps at n0' = {max(tight64):.3f}")

# The numerical example quoted after Thm 6.3: L=3, d=10, m=B=1, eps=0.1, delta=0.05, theta=1/4.
H, d, m, B, eps, de, th = 2, 10, 1, 1, mp.mpf('0.1'), mp.mpf('0.05'), mp.mpf(1) / 4
Es = d * (d + 1) * B ** 2 + 2 * 2 * m ** 2 * B ** 2; U = m * B
def least(f):
    lo, hi = mp.mpf(0), mp.mpf(200)
    for _ in range(200):
        mid = (lo + hi) / 2
        if f(mp.e ** mid) <= eps: hi = mid
        else: lo = mid
    return float(hi / mp.log(10))
print(f"Example L=3,d=10,m=B=1,eps=.1,delta=.05,theta=1/4:  E*={Es}")
print(f"  least n with Exc_n (as defined in Thm 6.3, (2/H)^(H/2) n^(theta H/2)) <= eps : 10^{least(lambda n: exc63(n, th, H, d, Es, U, de)):.2f}")
print(f"  least n with sharper (K/H)^(H/2), K = n^theta+1                            : 10^{least(lambda n: exc63_sharp(n, th, H, d, Es, U, de)):.2f}")
print(f"  closed-form n0                                                              : 10^{float(mp.log10(n0_63(th, H, d, Es, U, de, eps))):.2f}")
n = mp.mpf(10) ** mp.mpf('13.4')
print(f"  at n = 10^13.4: Exc_n = {float(exc63(n, th, H, d, Es, U, de)):.4f}, sharp form = {float(exc63_sharp(n, th, H, d, Es, U, de)):.4f}")

# Thm 6.2 (route 1): check n1 suffices, with the exact cover count, and the quoted least n.
def lnH_exact(K, a, d, L):
    return cover_exact(L, d, K, a)["lnH"]
def exc62(n, th, L, d, Es, U, de, eps):
    a = eps / 32; K = n ** th + 1
    lh = lnH_exact(K, a, d, L)
    return (Es + 1) * n ** (-th) + 8 * a + 4 * mp.sqrt((lh + mp.log(2 / de)) / (2 * n)) + (U + 1) ** 2 * mp.sqrt(mp.log(2 / de) / (2 * n))
def n1_62(th, L, d, Es, U, de, eps):
    CJ = 196609 * L * (L - 1) ** 4 * mp.mpf(16) ** L
    Clog = (2 * L + 1) * (mp.log(CJ) + 2 * L + 1) + L + 6
    lg = mp.log(1088 * d / eps)
    if L >= 3:
        rho = 1 - 4 * (L - 1) * th
        Cs = 256 * (L - 1) * CJ ** 2 * Clog * mp.mpf(2) ** (4 * (L - 1)) * mp.mpf(32) ** 8 * d ** 2 * eps ** -10
        ncov = max((8 * Cs * lg ** 3) ** (1 / rho), (8 * Cs * th ** 3 * (6 / (mp.e * rho)) ** 3) ** (2 / rho))
    else:
        rho = 1 - 2 * th
        Cs = 256 * 3 * CJ * Clog * 4 * mp.mpf(32) ** 4 * d ** 2 * eps ** -6
        ncov = max((4 * Cs * lg ** 2) ** (1 / rho), (4 * Cs * th ** 2 * (4 / (mp.e * rho)) ** 2) ** (2 / rho))
    return max((4 * (Es + 1) / eps) ** (1 / th), 8 * (U + 1) ** 4 * mp.log(2 / de) / eps ** 2, 256 * mp.log(2 / de) / eps ** 2, ncov), ncov
print("Thm 6.2 (route 1):")
for (L, d, m, B, th) in [(2, 10, 1, 1, mp.mpf(1) / 4), (3, 10, 1, 1, mp.mpf(1) / 16), (3, 10, 1, 1, mp.mpf(1) / 10), (4, 5, 2, 1, mp.mpf(1) / 20), (2, 3, 1, 1, mp.mpf(2) / 5)]:
    eps, de = mp.mpf('0.1'), mp.mpf('0.05')
    Es = d * (d + 1) * B ** 2 + 2 * (L - 1) * m ** 2 * B ** 2; U = m * B
    n1, ncov = n1_62(th, L, d, Es, U, de, eps)
    vals = [exc62(n1 * f, th, L, d, Es, U, de, eps) for f in (1, 10, mp.mpf(10) ** 50)]
    lo, hi = mp.mpf(0), mp.log(n1) * 2
    for _ in range(120):
        mid = (lo + hi) / 2
        if exc62(mp.e ** mid, th, L, d, Es, U, de, eps) <= eps: hi = mid
        else: lo = mid
    print(f"  L={L} d={d} m={m} B={B} theta={float(th):.4f}: log10 n1 = {float(mp.log10(n1)):.1f} (ncov 10^{float(mp.log10(ncov)):.1f});"
          f" Exc at n1,10n1,1e50n1 = {[round(float(v), 4) for v in vals]} (<= 0.1?); least n = 10^{float(hi / mp.log(10)):.1f}")
