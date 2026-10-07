import time
from dtrc.syntax import *
from dtrc.schemas import *
from dtrc.refute import TemplateRefuter
R = TemplateRefuter('PA')
for s in ['(?A & forall x. (?P(x) -> ?Q(x))) -> forall x. ?P(x)', '?P', 'forall x. ?P(x)', '?t+0=?t', '?t+?u=?v', 'forall x. ?f(x)=?g(x)',
          '(?P(0) & forall x. (?P(x) -> ?P(Sx))) -> forall x. ?P(x)', '(?f(0)=?f(0) & forall x. (?f(x)=x -> ?f(Sx)=Sx)) -> forall x. ?f(x)=x',
          '(0=0 & forall x. (?f(x)=x -> ?f(Sx)=Sx)) -> forall x. ?f(x)=x', '?A -> forall x. ?P(x)', '(?P(0) & ?B) -> forall x. ?P(x)', '(?A & forall x. (?P(x) -> ?P(Sx))) -> ?C',
          '?t*0=0', '0+?t=?t', '?t+0=?u']:
    t=time.time(); T=parse(s); r=R.refuted(T); w=R.witness(T)
    print('%-5s %.3fs %s   %s' % (r, time.time()-t, s, pp(w) if w else ''))
print(R.stats())
Z = TemplateRefuter('ZF')
for s in ['forall a. ?P(a)', 'forall a. exists b. forall x. (x in b <-> ?P(x, a))', '?P', 'forall a. exists b. forall x. (x in b <-> (x in a & ?P(x,a)))',
          '(forall x. ((forall y. (y in x -> ?P(y))) -> ?P(x))) -> forall x. ?P(x)', 'forall a. exists b. forall x. (x in b <-> (?P(x,a) & ?Q(x,a)))',
          'forall a. exists b. forall x. (x in b <-> (x in a & ?P(x,a,b)))']:
    t=time.time(); T=parse(s); r=Z.refuted(T); w=Z.witness(T)
    print('%-5s %.3fs %s   %s' % (r, time.time()-t, s, pp(w) if w else ''))
t=time.time(); r = Z.refuted(T_REP); print('Rep', r, time.time()-t)
print(Z.stats())
