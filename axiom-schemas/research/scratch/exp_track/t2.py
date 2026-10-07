import time
from dtrc.syntax import *
from dtrc.schemas import *
from dtrc.oracle_pa import PAEval
from dtrc.oracle_zf import ZFEval
pa = PAEval()
for s in list(Q_AXIOMS.values()) + ['(0=0 & forall x. (x=x -> Sx=Sx)) -> forall x. x=0', 'forall x. x=0', 'forall x. 0+x=x',
          '(0=0 & forall x. (x=0 -> x=0)) -> forall x. x=0', 'forall x. forall y. x+y=y+x', 'S0+0=S0', 'w+0=w', 'w*0=S0', 'forall x. x<Sx',
          'forall x. exists y. x<y', 'exists y. forall x. x<y', '(0+0=0 & forall x. (x+0=x -> Sx+0=Sx)) -> forall x. x+0=x', 'forall x. (x=0 | ~x=0)',
          'forall x. (x<0 -> 0=S0)']:
    t=time.time(); r = pa.truth(parse(s)); print('PA', r, '%.4f'%(time.time()-t), s)
zf = ZFEval()
for s in list(ZF_AXIOMS.values()) + ['forall a. exists b. forall x. (x in b <-> x=x)', 'forall a. exists b. forall x. (x in b <-> ~x in x)',
     'forall a. exists b. forall x. (x in b <-> ~x in a)', 'forall a. exists b. forall x. (x in b <-> a in x)', 'forall x. x in x', 'forall x. forall y. x in y',
     'exists x. forall y. ~y in x', 'forall x. exists y. x in y', 'forall a. exists b. forall x. (x in b <-> (x in a & ~x in b))',
     'forall a. exists b. forall x. (x in b <-> (x in a & x=x))', '(forall x. ((forall y. (y in x -> ~exists w. w in y)) -> ~exists w. w in x)) -> forall x. ~exists w. w in x',
     '(forall x. ((forall y. (y in x -> ~y in y)) -> ~x in x)) -> forall x. ~x in x', 'forall x. forall y. ((forall z. (z in x -> z in y)) -> x=y)']:
    t=time.time(); r = zf.truth(parse(s)); print('ZF', r, '%.4f'%(time.time()-t), zf.steps, s)
