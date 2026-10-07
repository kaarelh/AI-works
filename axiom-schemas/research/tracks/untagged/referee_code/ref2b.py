import sys
sys.path.insert(0, '/home/user/AI-works/axiom-schemas/research/tracks/untagged/code'); sys.path.insert(0, '/home/user/AI-works/axiom-schemas/research/tracks/untagged/referee_code')
exec(open('/home/user/AI-works/axiom-schemas/research/tracks/untagged/referee_code/ref2_within_enum.py').read().split("SM = int")[0])
from practice import *
def motive_n(n):
    t = X
    for _ in range(n): t = S(t)
    return eq(add(num(n), X), t)
SM = int(sys.argv[1])
K0pair = [canon_params(Ind(motive_n(0))), canon_params(Ind(motive_n(1)))]
check('K0 pair', K0pair, SM, 'arith')
J0star = IMP(AND(eq(add(Z, Z), Z), ALL(IMP(eq(add(Z, V(0)), Z), eq(add(Z, S(V(0))), S(Z))))), ALL(eq(add(Z, V(0)), Z)))
check('Ind(0+x=x) + J*0', [canon_params(Ind(motive_n(0))), J0star], SM, 'arith')
check('J*0 + Ind(n<3)', [canon_params(Ind(motive_n(n))) for n in range(3)] + [J0star], SM, 'arith')
