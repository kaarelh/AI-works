import sys, io, contextlib, numpy as np, sympy as sp
sys.path.insert(0, '/home/user/AI-works/inferential-learning/research/theory/T3-checks')
with contextlib.redirect_stdout(io.StringIO()):
    import sps_checker as S
a, r, phi, I0, alpha = S.a, S.r, S.phi, S.I0, S.alpha
thin = a*I0/2*sp.sin(phi/2)/r
A = {**S.honest, 'answer': thin*(sp.Rational(115,100) + sp.Rational(1,100)*sp.cos(alpha))}
B = {**S.honest, 'domain': dict(r_min_over_a=1.05, r_max_over_a=34.0, sigma_min=1.0), 'tol': 0.7}
C = {**S.honest, 'answer': thin*(1 + sp.Rational(9,100)*sp.cos(alpha)**0 + 0*alpha)}  # simplifies to 1.09*thin, should be rejected
D = {**S.honest, 'answer': thin*(sp.Rational(13,10) + sp.Rational(1,1000)*alpha)}
for name, sps in [('A: 1.15+0.01cos(alpha) factor', A), ('B: r_min=1.05a, phi=pi only, tol 0.7', B), ('C: constant 1.09 factor', C), ('D: 1.3 + 0.001*alpha factor', D)]:
    ok, rep = S.check(sps); print(name, ok, rep)
# true error for A over the accepted domain (point sun, use exact formula), alpha in [30,60]
from scipy.optimize import brentq
def ratio(rr, ph):
    f=lambda p: p+np.arctan2(np.cos(p/2), np.sqrt(rr*rr-np.cos(p/2)**2))-ph
    p=brentq(f,1e-13,2*np.pi-1e-13); u=np.sqrt(rr*rr-np.cos(p/2)**2); c=np.sin(p/2); s=u-c
    return (c/(2*s+c))/(abs(np.sin(ph/2))/(2*rr))
worst=0
for rr in np.linspace(20,34,15):
    for sg in np.linspace(0.5,1,11):
        ph=2*np.arcsin(sg); R=ratio(rr,ph)
        for al in np.radians(np.linspace(30,60,7)):
            worst=max(worst, abs(R/(1.15+0.01*np.cos(al))-1))
print("A: true max |E_true/answer - 1| on accepted domain (point sun):", round(worst,4), "claimed <= 0.0888, tol 0.10")
print("D: at r=20,phi=pi: |E/answer-1| =", abs(ratio(20,np.pi)/(1.3+0.001*np.radians(30))-1))
print("B: at r=1.05a, phi=pi: |E/E0 - 1| =", ratio(1.05,np.pi)-1, " exact 2r/(2r-a)-1 =", 2.1/1.1-1)
