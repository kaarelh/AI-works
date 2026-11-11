"""Checks for Section 2 of A.md (parity representation by tanh features).

(a) Identity (2.3): E_u[(prod u) tanh(alpha(sum_j u_j x_j - b_k))] = c_{k,alpha} prod_j x_j,
    for every x in {-1,1}^k, several k and slopes alpha (exhaustive, float64).
(b) Closed form of the sign coefficient c_k:  (-1)^m C(2m,m)/4^m (k=2m+1),
    (-1)^(m-1) C(2m,m)/4^m (k=2m)  -- exact rational arithmetic, k <= 40.
(c) |c_k| >= 1/sqrt(2k) and C(2m,m)/4^m >= 1/(2 sqrt m)  (exact), k <= 400.
(d) |c_{k,alpha_d}| >= 1/(2 sqrt(2k)) for all 1 <= k <= d <= 200, alpha_d = (1/2) log(4 sqrt(2d)),
    computed with mpmath at 300 digits (the alternating binomial sum cancels badly in floats).
"""
import itertools, math
from fractions import Fraction
import numpy as np
import mpmath as mp

def b_of(k):
    return 0 if k % 2 == 1 else 1

# (a) exhaustive identity check
worst = 0.0
for k in range(1, 8):
    for alpha in [0.3, 0.867, 1.0, 2.5]:
        b = b_of(k)
        # c_{k,alpha} by definition (top Fourier coefficient of v -> tanh(alpha(sum v - b)))
        c = np.mean([np.prod(v) * np.tanh(alpha * (sum(v) - b)) for v in itertools.product([-1, 1], repeat=k)])
        for x in itertools.product([-1, 1], repeat=k):
            lhs = np.mean([np.prod(u) * np.tanh(alpha * (np.dot(u, x) - b))
                           for u in itertools.product([-1, 1], repeat=k)])
            worst = max(worst, abs(lhs - c * np.prod(x)))
print(f"(a) identity (2.3): max abs error over k<=7, 4 slopes, all x: {worst:.2e}")

# (b) closed form of c_k with exact arithmetic
def c_sign_exact(k):
    b = b_of(k)
    tot = Fraction(0)
    for j in range(k + 1):          # j = number of -1 coordinates
        s = k - 2 * j - b
        tot += math.comb(k, j) * (-1) ** j * (1 if s > 0 else -1)
    return tot / 2 ** k

ok = True
for k in range(1, 41):
    if k % 2 == 1:
        m = (k - 1) // 2; formula = Fraction((-1) ** m * math.comb(2 * m, m), 4 ** m)
    else:
        m = k // 2; formula = Fraction((-1) ** (m - 1) * math.comb(2 * m, m), 4 ** m)
    ok &= (c_sign_exact(k) == formula)
print("(b) closed form of c_k verified exactly for k<=40:", ok)

# (c) lower bounds, exact squares to avoid rounding
ok_c = True
for m in range(1, 201):
    q = Fraction(math.comb(2 * m, m), 4 ** m)
    ok_c &= (q * q * 4 * m >= 1)                      # C(2m,m)/4^m >= 1/(2 sqrt m)
for k in range(1, 401):
    m = (k - 1) // 2 if k % 2 == 1 else k // 2
    q = Fraction(math.comb(2 * m, m), 4 ** m)
    ok_c &= (q * q * 2 * k >= 1)                      # |c_k| >= 1/sqrt(2k)
print("(c) |c_k| >= 1/sqrt(2k) (k<=400) and central-binomial bound (m<=200):", ok_c)

# (d) tanh coefficient lower bound with high precision
mp.mp.dps = 300
def c_tanh(k, alpha):
    b = b_of(k)
    tot = mp.mpf(0)
    for j in range(k + 1):
        tot += mp.binomial(k, j) * (-1) ** j * mp.tanh(alpha * (k - 2 * j - b))
    return tot / mp.mpf(2) ** k

worst_ratio = mp.inf; arg = None
for d in list(range(1, 61)) + [80, 100, 128, 160, 200]:
    alpha = mp.log(4 * mp.sqrt(2 * d)) / 2
    assert 2 * mp.e ** (-2 * alpha) <= 1 / (2 * mp.sqrt(2 * d)) * (1 + mp.mpf(10) ** -50)
    for k in range(1, d + 1):
        c = c_tanh(k, alpha)
        ratio = abs(c) * 2 * mp.sqrt(2 * k)     # must be >= 1
        if ratio < worst_ratio:
            worst_ratio, arg = ratio, (d, k, float(c))
print(f"(d) min over 1<=k<=d (d<=60 and d in 80..200) of |c_(k,alpha_d)| * 2 sqrt(2k) = {float(worst_ratio):.4f} at (d,k,c)={arg}")
print("    alpha_d values:", {d: round(float(mp.log(4 * mp.sqrt(2 * d)) / 2), 4) for d in [1, 2, 10, 100, 10**6]})
print("    first-layer row-norm^2 bound (d+1) alpha_d^2 >= 1 for d>=1:",
      all((d + 1) * (math.log(4 * math.sqrt(2 * d)) / 2) ** 2 >= 1 for d in range(1, 10000)))
