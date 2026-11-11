"""|c_{k,a_d}| * 2 sqrt(2k) >= 1 for all 1<=k<=d, d up to 300 (red-team checked d<=16, k<=14).
c_{k,a} = 2^{-k} sum_j C(k,j) (-1)^{k-j} tanh(a(2j-k-b_k)), exact with mpmath (high precision: heavy cancellation).
Also: sign-coefficient formula C(2m,m)/4^m, and row norm a_d^2(k+b_k^2) vs F_d and vs (d+1) a_d^2."""
import math
import mpmath as mp
mp.mp.dps = 120
def ad(d): return max(mp.mpf(1), mp.log(4*mp.sqrt(2*d))/2)
def coef(k, a):
    b = 0 if k % 2 else 1
    return sum(mp.binomial(k, j)*(-1)**(k-j)*mp.tanh(a*(2*j-k-b)) for j in range(k+1))/mp.mpf(2)**k
def coef_sign(k):
    b = 0 if k % 2 else 1
    return sum(mp.binomial(k, j)*(-1)**(k-j)*mp.sign(2*j-k-b) for j in range(k+1))/mp.mpf(2)**k
# sign coefficients vs C(2m,m)/4^m
for k in range(1, 41):
    m = (k-1)//2 if k % 2 else k//2
    assert abs(abs(coef_sign(k)) - mp.binomial(2*m, m)/mp.mpf(4)**m) < mp.mpf(10)**-80
print("sign-coefficient formula C(2m,m)/4^m verified for k=1..40")
worst = (10, None)
for d in list(range(1, 61)) + [80, 100, 150, 200, 300]:
    a = ad(d)
    for k in range(1, d+1):
        r = abs(coef(k, a))*2*mp.sqrt(2*k)
        if r < worst[0]: worst = (float(r), (d, k))
    assert worst[0] >= 1
print("min |c_{k,a_d}| 2 sqrt(2k) over 1<=k<=d, d in 1..60,80,100,150,200,300: %.4f at (d,k)=%s" % worst)
for d in [10, 30, 100, 1000]:
    a = float(ad(d))
    print("d=%d: a_d=%.3f, max row^2 <= (d+1) a_d^2 = %.1f  vs  F_d = %d" % (d, a, (d+1)*a*a, 1+(d+1)*(d+2)**2))
