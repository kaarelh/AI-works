import sys; sys.path.insert(0,'/home/user/AI-works/axiom-schemas/research/tracks/single')
from dtcore import *
from dtfeat import Prefix
from dtenum import enumerate_covering, minimal_elements
X=H(0)
D=[Ind(eq(X,X)), Ind(eq(Z,X))]
P=Prefix(D); mins,reps=P.minimal()
print([ (pp(m), size(m)) for m in mins])
E=enumerate_covering(D, 23, amax=2, arities_T=(0,1), arities_F=(0,1), consts=('0',), funcs=(('S',1),('add',2)))
m2,_=minimal_elements(E)
for m in m2:
    ab=[i for i,mm in enumerate(mins) if subsumes(m,mm)]
    print(pp(m), size(m), 'above sat-min #', ab, 'in Sat?', any(equivalent(m,r) for r in reps))
print('all enumerated above some sat-min:', all(any(subsumes(U,mm) for mm in mins) for U in E))
