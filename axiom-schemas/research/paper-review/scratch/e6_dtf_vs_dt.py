import sys
sys.path.insert(0, '/home/user/AI-works/axiom-schemas/code')
from dtrc.syntax import parse, pp
from dtrc.mincover import aligned_min, min_covering
from dtrc.templates import covers, is_DT0
from dtrc.refute import TemplateRefuter
d1 = parse('(0=0 & forall x. (x=x -> Sx=Sx)) -> forall x. x=x')
d2 = parse('(0+0=0 & forall x. (x+0=x -> Sx+0=Sx)) -> forall x. x+0=x')
q  = parse('(0*0=0 & forall x. (x*0=0 -> Sx*0=0)) -> forall x. x*0=0')
mins, _ = aligned_min([d1, d2])
R = TemplateRefuter('PA', budget=80)
print('DT_F minimal templates of {Ind(x=x), Ind(x+0=x)}:')
for T in mins:
    print('  ', pp(T), '| refuted:', R.refuted(T), '| covers q:', covers(T, q))
# a DT template with a unary term metavariable f
TD = parse('(?f(0)=0 & forall x. (?f(x)=x -> ?f(Sx)=Sx)) -> forall x. ?f(x)=x')
print('DT template', pp(TD), 'is DT0:', is_DT0(TD), 'covers d1,d2:', covers(TD, d1), covers(TD, d2), 'covers q:', covers(TD, q))
