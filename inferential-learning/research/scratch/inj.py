import sympy as sp, numpy as np
x,y,t1,t2,a = sp.symbols('x y t1 t2 a', real=True)
e = lambda ang: sp.Matrix([sp.cos(ang), sp.sin(ang)])
L1 = t1*e(2*x) + a*sp.cos(x)*e(2*x+sp.pi/2)
L2 = t2*e(2*y) + a*sp.cos(y)*e(2*y+sp.pi/2)
sol = sp.solve(list(L1-L2), [t1,t2], dict=True)[0]
d = y - x
T1 = a*(sp.cos(x)*sp.cos(2*d) - sp.cos(y))/sp.sin(2*d)
T2 = a*(sp.cos(x) - sp.cos(y)*sp.cos(2*d))/sp.sin(2*d)
import random
for _ in range(5):
    vals = {x: random.uniform(0,3), y: random.uniform(0,3), a: 1.3}
    print(float(sol[t1].subs(vals)) - float(T1.subs(vals)), float(sol[t2].subs(vals)) - float(T2.subs(vals)))
# brute force independent: random pairs (psi, s) -> P, check for collisions via nearest neighbour
def P(psi, s, a=1.0):
    th = (psi+np.pi)/2
    return np.stack([a*np.cos(th) + s*np.cos(psi), a*np.sin(th) + s*np.sin(psi)], -1)
# direct: solve P(psi1,s1)=P(psi2,s2) for given psi1,psi2 via linear solve for s1,s2 and check s>=0
rng = np.random.default_rng(7)
N = 3_000_000
p1 = rng.uniform(0, 2*np.pi, N); p2 = rng.uniform(0, 2*np.pi, N)
A0 = 1.0
th1 = (p1+np.pi)/2; th2 = (p2+np.pi)/2
# s1 e(p1) - s2 e(p2) = a(e(th2) - e(th1))
M11 = np.cos(p1); M12 = -np.cos(p2); M21 = np.sin(p1); M22 = -np.sin(p2)
det = M11*M22 - M12*M21
bx = A0*(np.cos(th2)-np.cos(th1)); by = A0*(np.sin(th2)-np.sin(th1))
ok = np.abs(det) > 1e-9
s1 = (bx*M22 - M12*by)/np.where(ok, det, 1); s2 = (M11*by - bx*M21)/np.where(ok, det, 1)
bad = ok & (s1 >= -1e-12) & (s2 >= -1e-12) & (np.abs(p1-p2) > 1e-6)
print("pairs:", ok.sum(), "forward intersections:", bad.sum())
if bad.sum(): 
    i = np.where(bad)[0][:5]; print(p1[i], p2[i], s1[i], s2[i])
