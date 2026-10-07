import sympy as sp, numpy as np
from scipy.integrate import solve_ivp
G,m,r0,x=sp.symbols('G m r0 x',positive=True)
# exact radial free fall from rest at r0 under GM/r^2: time to reach r=x r0
t_exact = sp.sqrt(r0**3/(2*G*m))*(sp.sqrt(x*(1-x))+sp.acos(sp.sqrt(x)))
t_constg = sp.sqrt(2*(1-x)*r0/(G*m/r0**2))
v=float((t_exact/sp.sqrt(r0**3/(G*m))).subs(x,0.95)); u=float((t_constg/sp.sqrt(r0**3/(G*m))).subs(x,0.95))
print("t2 exact %.5f, const-g %.5f, rel err %.4f" % (v,u,(u-v)/v))
print("collapse time exact limit x->0:", sp.simplify(sp.limit(t_exact,x,0)), " vs Kepler pi*sqrt(r0^3/(8Gm)):", sp.simplify(sp.pi*sp.sqrt(r0**3/(8*G*m))))
# numeric ODE check with G=m=r0=1
sol=solve_ivp(lambda t,y:[y[1],-1/y[0]**2],[0,2],[1,0],events=lambda t,y:y[0]-1e-4,rtol=1e-11,atol=1e-13)
print("numerical collapse time", sol.t_events[0][0], " pi/sqrt(8)=", np.pi/np.sqrt(8))
# isothermal then adiabatic estimate
R,T0,mu,r3,r4,gam=sp.symbols('R T0 mu r3 r4 gamma',positive=True)
T4 = T0*(r3/r4)**(3*gam-3)
sol4=sp.solve(sp.Eq(R*T4/mu, G*m/r4), r4)
print("r4 =", [sp.simplify(s) for s in sol4])
# gas pressure vs gravity scaling: p ~ r^{-3 gamma}, gravitational 'pressure' ~ G m^2/r^4
print("collapse halts iff 3*gamma>4 i.e. gamma>4/3")
