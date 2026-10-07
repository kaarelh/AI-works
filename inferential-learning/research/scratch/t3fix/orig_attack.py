import sympy as sp, numpy as np
import sps_checker_orig as S
a,I0,phi,r,alpha=S.a,S.I0,S.phi,S.r,S.alpha
thin=a*I0/2*sp.sin(phi/2)/r
for name,v in [("V6",{**S.honest,'answer':2*thin*sp.cos(alpha)**sp.Rational(1,1000)}),
               ("V7",{**S.honest,'answer':sp.Rational(23,20)*thin*sp.cos(alpha)**sp.Rational(1,50)}),
               ("V8",{**S.honest,'answer':sp.Rational(3,2)*thin*sp.exp(alpha/1000)}),
               ("V9",{**S.honest,'domain':dict(r_min_over_a=1.05,r_max_over_a=34.0,sigma_min=1.0),'tol':0.7})]:
    print(name, S.check(v))
