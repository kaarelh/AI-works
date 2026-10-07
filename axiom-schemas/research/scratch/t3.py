import sys; sys.path.insert(0,'/home/user/AI-works/axiom-schemas/research/tracks/single')
from dtcore import *
from dtfeat import Prefix
from dtwitness import events, anchor_by_features
from dtenum import enumerate_covering, minimal_elements
Ts = AND(ALL(ALL(eq(S(M('f',V(1),V(0))),Z))), ALL(ALL(eq(M('f',V(1),S(V(0))),Z))))
print(pp(Ts), is_DT0(Ts))
ths=[{'f':H(0)},{'f':H(1)},{'f':S(H(0))}]
ev,D=events(Ts,ths)
for d in D: print('  ',pp(d))
print({k:v for k,v in ev.items()})
ok,bad=anchor_by_features(Ts,D)
print('anchor by features', ok, [pp(b) for b in bad])
# certify non-anchor: an instance of T* outside the bad template
q=instantiate(Ts,{'f':Z}); print('q',pp(q), [covers(b,q) for b in bad], 'P.accepts', Prefix(D).accepts(q))
E=enumerate_covering(D,16,amax=2,arities_T=(0,1,2),arities_F=(0,),consts=('0',),funcs=(('S',1),))
m,_=minimal_elements(E)
print('enum covering', len(E), 'min:', [pp(x) for x in m], 'all >= T*?', all(subsumes(x,Ts) for x in E))
import time; t=time.time()
E=enumerate_covering(D,18,amax=2,arities_T=(0,1,2),arities_F=(0,),consts=('0',),funcs=(('S',1),))
m,_=minimal_elements(E)
print('smax18 enum covering', len(E), 'min:', [pp(x) for x in m], time.time()-t)
P=Prefix(D); mm,reps=P.minimal(); print('Sat-based min', [pp(x) for x in mm])
print('T* size', size(Ts))
