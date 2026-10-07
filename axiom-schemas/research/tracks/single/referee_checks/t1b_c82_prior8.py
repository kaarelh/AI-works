# Referee: the 8 templates reported by prior C8.2 versus the 4 DT° minimal templates.
from rc_core import *
x = V(0)
def T(a, prem, concl):
    return IMP(AND(a, ALL(prem)), ALL(concl))
f = lambda t: M('f', t)
g = lambda t: M('g', t)
P = lambda t: M('P', t)
prior8 = {
 '(f(0)=f(0) & Ax.(P(x)->P(Sx))) -> Ax.f(x)=x': T(EQ(f(Z), f(Z)), IMP(P(x), P(S(x))), EQ(f(x), x)),
 '(0=f(0) & Ax.(f(x)=x->f(Sx)=Sx)) -> Ax.f(x)=x': T(EQ(Z, f(Z)), IMP(EQ(f(x), x), EQ(f(S(x)), S(x))), EQ(f(x), x)),
 '(f(0)=0 & ...)': T(EQ(f(Z), Z), IMP(EQ(f(x), x), EQ(f(S(x)), S(x))), EQ(f(x), x)),
 '(f(0)=f(0) & Ax.(f(x)=x->P(Sx))) -> Ax.P(x)': T(EQ(f(Z), f(Z)), IMP(EQ(f(x), x), P(S(x))), P(x)),
 '(f(0)=f(0) & Ax.(f(x)=x->g(x)=Sx)) -> Ax.f(x)=x': T(EQ(f(Z), f(Z)), IMP(EQ(f(x), x), EQ(g(x), S(x))), EQ(f(x), x)),
 '(0=0 & ...)': T(EQ(Z, Z), IMP(EQ(f(x), x), EQ(f(S(x)), S(x))), EQ(f(x), x)),
 '(f(0)=f(0) & Ax.(P(x)->f(Sx)=Sx)) -> Ax.f(x)=x': T(EQ(f(Z), f(Z)), IMP(P(x), EQ(f(S(x)), S(x))), EQ(f(x), x)),
 '(f(0)=f(0) & Ax.(f(x)=x->f(Sx)=Sx)) -> Ax.P(x)': T(EQ(f(Z), f(Z)), IMP(EQ(f(x), x), EQ(f(S(x)), S(x))), P(x)),
}
T24 = T(EQ(f(Z), f(Z)), IMP(EQ(f(x), x), EQ(f(S(x)), S(x))), EQ(f(x), x))
D = [Ind(EQ(('z', 0), ('z', 0))), Ind(EQ(Z, ('z', 0)))]
for name, U in prior8.items():
    assert is_DT0(U) and covers(U, D), name
    above = geq(U, T24) and not geq(T24, U)
    print('%-55s size %d  strictly above size-24 template: %s' % (name, size(U), above))
print('size-24 template covers D:', covers(T24, D), ' size', size(T24))
