import sys, io, contextlib, numpy as np, sympy as sp
sys.path.insert(0, '/home/user/AI-works/inferential-learning/research/theory/T3-checks')
with contextlib.redirect_stdout(io.StringIO()):
    import sps_checker as S
a, r, phi, I0, alpha = S.a, S.r, S.phi, S.I0, S.alpha
thin = a*I0/2*sp.sin(phi/2)/r
A1 = {**S.honest, 'answer': sp.Rational(23,20)*thin*sp.cos(alpha)**sp.Rational(1,50)}
A2 = {**S.honest, 'answer': sp.Rational(3,2)*thin*sp.exp(alpha/1000)}
A3 = {**S.honest, 'answer': 2*thin*sp.cos(alpha)**sp.Rational(1,1000)}
for name, sps in [('A1: (23/20) thin cos(alpha)^(1/50)', A1), ('A2: 1.5 thin exp(alpha/1000)', A2), ('A3: 2 thin cos(alpha)^(1/1000)', A3)]:
    ok, rep = S.check(sps); print(name, '->', ok, rep)
print("A3 ratio to thin over alpha range:", [float(2*np.cos(x)**0.001) for x in np.radians([30,60])])
