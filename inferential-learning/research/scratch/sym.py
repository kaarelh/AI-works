import sympy as sp
a,h,al,th,I = sp.symbols('a h alpha theta I', positive=True)
# 3D: incoming direction d, normal n at (a cos th, a sin th, h)
d = sp.Matrix([sp.sin(al),0,-sp.cos(al)])
n = sp.Matrix([sp.cos(th), sp.sin(th), 0])
dp = d - 2*(d.dot(n))*n
X0 = sp.Matrix([a*sp.cos(th), a*sp.sin(th), h])
t = h/sp.cos(al)          # since dp_z = -cos(al)
P3 = X0 + t*dp
print("z at floor:", sp.simplify(P3[2]))
Px, Py = sp.simplify(P3[0]), sp.simplify(P3[1])
# Jacobian w.r.t. (theta, h)
Jh = sp.simplify(sp.Matrix([Px,Py]).jacobian([th,h]).det())
print("det dP/d(theta,h) =", sp.factor(sp.simplify(sp.trigsimp(Jh))))
# irradiance on surface: I*|d.n| ; area a dth dh
dn = sp.simplify(d.dot(n))
print("d.n =", dn)
# E = I*(-d.n)*a / |Jh|  (on lit side cos th<0)
s = sp.Symbol('s', positive=True)
E = sp.simplify(I*(-dn)*a/(-Jh))
E_s = sp.simplify(E.subs(h, s/sp.tan(al)))
print("E(theta,s) =", sp.simplify(E_s))
I0 = sp.Symbol('I0', positive=True)
E_I0 = sp.simplify(E_s.subs(I, I0/sp.cos(al)))
print("E in terms of I0:", E_I0, " d/dalpha:", sp.simplify(sp.diff(E_I0, al)))
# compare to claimed I0 a c/(2 s + a c), c = -cos th
c = -sp.cos(th)
print("diff from claim:", sp.simplify(E_I0 - I0*a*c/(2*s + a*c)))
# P in terms of s: 
Ps = sp.Matrix([Px,Py]).subs(h, s/sp.tan(al))
print("P(theta,s) =", sp.simplify(Ps.T))
# check Jacobian in (theta,s)
Js = sp.simplify(Ps.jacobian([th,s]).det())
print("det dP/d(theta,s) =", sp.simplify(sp.trigsimp(Js)))
