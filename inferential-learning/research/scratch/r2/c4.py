from sympy import symbols, discriminant, factor_list, Poly, real_roots, nroots, QQ, CRootOf, minimal_polynomial, factor, sqrt, expand
x=symbols('x')
f=x**3-4*x+1
print("disc",discriminant(f,x))
print("irreducible over Q:", Poly(f,x).is_irreducible)
print("roots", [r.evalf(6) for r in real_roots(f)])
r=CRootOf(f,2)
print("factor over Q(r):", factor(f, extension=[r]) if False else "skip")
# Use algebraic field via sympy's factor with extension on an explicit root expression
from sympy import solve, nsimplify
from sympy.polys.domains import AlgebraicField
K=QQ.algebraic_field(CRootOf(f,0))
print(Poly(f,x,domain=K).factor_list())
# x^2=2 test: no integer poly squared is 2: trivial
