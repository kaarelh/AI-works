"""Symbolic identities for E-finite-prior-scale.md Lemma 4.1 (third-derivative bounds; cosh y <= exp(y^2/2))
and Lemma 4.2(b) (1 - tanh y = 2/(1+e^{2y}))."""
import sympy as sp
y = sp.symbols('y', real=True)
t = sp.tanh(y)
print("tanh''' =", sp.simplify(sp.diff(t, y, 3) - (-2*(1-t**2)*(1-3*t**2))))
print("(sech^2)'' =", sp.simplify(sp.diff(1-t**2, y, 2) - 2*(1-t**2)*(3*t**2-1)))
print("(tanh^2)'' =", sp.simplify(sp.diff(t**2, y, 2) - 2*(1-t**2)*(1-3*t**2)))
# max over u=tanh^2 in [0,1] of |(1-u)(1-3u)| and |(1-u)(3u-1)|
u = sp.symbols('u')
f = (1-u)*(1-3*u)
crit = sp.solve(sp.diff(f,u),u)
print("max |(1-u)(1-3u)| on [0,1]:", max([abs(f.subs(u,v)) for v in [0,1]+[c for c in crit if 0<=c<=1]]))
# 1 - tanh(y) <= 2 e^{-2y}: equivalent to 1/(1+e^{2y}) <= e^{-2y}
print("1-tanh(y) - 2/(1+e^{2y}) =", sp.simplify((1-sp.tanh(y) - 2/(1+sp.exp(2*y))).rewrite(sp.exp)))
# cosh(y) <= exp(y^2/2) coefficientwise: (2k)! >= 2^k k!
print(all(sp.factorial(2*k) >= 2**k*sp.factorial(k) for k in range(0,40)))
