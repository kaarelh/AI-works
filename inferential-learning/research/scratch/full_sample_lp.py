# Independent check: LP over FULL samples (tag, instance), not tag sequences, to confirm sufficiency.
import itertools, math, numpy as np
from scipy.optimize import linprog
def opt(Pb,Pg,t,delta):
    atoms=sorted(set(Pb)|set(Pg))
    seqs=list(itertools.product(atoms,repeat=t))
    pb=np.array([math.prod(Pb.get(a,0) for a in x) for x in seqs]); pg=np.array([math.prod(Pg.get(a,0) for a in x) for x in seqs])
    r=linprog(-pg,A_ub=[pb],b_ub=[delta],bounds=[(0,1)]*len(seqs),method='highs'); return -r.fun
bad=0
for pi in (0.2,0.45):
  for delta in (0.0,0.03,0.3):
    for t in (1,2,3,4):
      # per-tag instance laws: sigma has instances a(0.3)/b(0.7), noise n(0.1 of tau); tau has c/d; mu has e/f
      lam={'s':{'a':.3,'b':.7},'t':{'c':.5,'d':.4,'n':.1},'m':{'e':.6,'f':.4}}
      qs=.4
      P1={('s',k):(1-pi)*qs*v for k,v in lam['s'].items()}
      P1.update({('t',k):(1-pi)*(1-qs)*v for k,v in lam['t'].items()})
      P1.update({('m',k):pi*v for k,v in lam['m'].items()})
      P2={('s',k):qs*v for k,v in lam['s'].items()}; P2.update({('t',k):(1-qs)*v for k,v in lam['t'].items()})
      a=opt(P1,P2,t,delta); ca=min(1,delta*(1-pi)**-t)
      b=opt(P2,P1,t,delta); cb=1-(1-delta)*(1-pi)**t
      if abs(a-ca)>1e-7 or abs(b-cb)>1e-7: bad+=1; print(pi,delta,t,a,ca,b,cb)
print('mismatches',bad)
