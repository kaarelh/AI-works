import numpy as np, mpmath as mp, time
from myspec import *
mp.mp.dps = 40
s2 = 1.0
c, v = coeffs_tanh(4001, s2)
print("v=", v, "sum c =", c.sum(), "1-sum=", 1-c.sum())
for m in [1,3,5,21,101,501,2001]:
    f = lambda w: w**m*mp.e**(-w**2/2)/mp.sinh(mp.pi*w/2)
    sm = mp.sqrt(m)
    I = mp.quad(f, [0, sm/4, sm/2, sm, 2*sm+10, mp.inf])
    vm = mp.quad(lambda x: mp.tanh(x)**2*mp.e**(-x**2/2), [-mp.inf, 0, mp.inf])/mp.sqrt(2*mp.pi)
    cm = I**2/(mp.factorial(m)*vm)
    print(m, "rel err", float(c[m]/cm-1))
