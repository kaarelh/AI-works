"""Independent check of the numbers that the abstract, introduction and discussion of Paper 1 repeat from the body."""
from math import log2, log, lgamma, pi, e, sqrt
H = lambda p: -p*log2(p)-(1-p)*log2(1-p)
print("H(1/3)/2 =", H(1/3)/2, "(paper: 0.4591479)")
a = 1.5*log2(3)-1
print("sigma^2 = 2/9 a^2 + 1/4 log2(3)^2 =", 2/9*a*a+0.25*log2(3)**2, "(paper: 1.0496602)")
print("log2 3 - 1/3 =", log2(3)-1/3, "(paper: 1.2516)")
th = sum(2/9*((2/3)**k*log2(1+2**-k)+(1/3)**k*log2(1+2**k)) for k in range(200))
print("vartheta =", th, " 3*vartheta =", 3*th, "(paper: 0.7995167, 2.39855; intro: 'at most 2.4 bits')")
for d in (4, 8, 12):
    N = 2**d; L = lgamma(N)/log(2)
    print(f"d={d}: log2((N-1)!)={L:.3f}  per pair={L/N:.3f}  d-log2 e={d-log2(e):.3f}  Stirling={(d-log2(e))*N-d/2+0.5*log2(2*pi):.3f}")
w = 1/16
r0 = -log2((1+w)/2); r1 = 0.5*log2((1+w)/(2*w))
print("prop:learn:curve w=1/16: r0=%.3f r1=%.3f (paper 0.912, 1.544)" % (r0, r1))
# (1+w)^3 > 8w for all w <= 1/5 ?
bad = [k/10000 for k in range(1, 2001) if not (1+k/10000)**3 > 8*k/10000]
print("w<=1/5 with (1+w)^3<=8w:", bad[:3], "(expect none)")
# no-coding theorem: ell_d and log d - 2
for d in (2, 10, 1000, 10**6):
    import math
    g = math.ceil(log2(d/log2(3)))-1
    print(f"d={d}: g=ell_d={g}, 3^(2^g) < 2^d: {2**g*log2(3) < d}, g > log d - 2: {g > log2(d)-2}")
