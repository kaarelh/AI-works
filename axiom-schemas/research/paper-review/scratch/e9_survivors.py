import sys
sys.path.insert(0, '/home/user/AI-works/axiom-schemas/code')
from dtrc.syntax import parse, pp
from dtrc.refute import TemplateRefuter, Oracle
T1 = parse('(forall x. (forall y. y in x -> forall z. z in y -> ?P0(z)) -> ?P1(x)) -> forall x. ?P1(x)')
T2 = parse('(forall x. (forall y. y in x -> forall z. z in y -> ?P0(z, y)) -> ?P1(x)) -> forall x. ?P1(x)')
for T in (T1, T2):
    for b in (80, 400, 2000):
        R = TemplateRefuter('ZF', budget=b)
        r = R.refuted(T)
        print(pp(T), b, r, R.phase(T), R.witness(T) and pp(R.witness(T)), R.stats())
