"""Independently certify completeness of all 1882 d4 affine sign cones.

Rebuild the 222 cube-isometry/output-sign orbits. Each orbit representative
gets an exact rational separating vector or an exact rational Farkas witness.
"""
import os
os.environ.setdefault('OPENBLAS_NUM_THREADS','1')
import itertools,json
from pathlib import Path
from fractions import Fraction as F
import numpy as np
from scipy.optimize import linprog
ROOT=Path(__file__).resolve().parent.parent

def run():
    a=np.load(ROOT/'d4_certificate_input.npz');X=a['X'].astype(int);D=a['D'].astype(int)
    maps=[]
    for perm in itertools.permutations(range(4)):
        for flip in itertools.product((-1,1),repeat=4):
            z=X[:,1:][:,perm]*flip
            maps.append(((z+1)//2)@np.array([8,4,2,1]))
    maps=np.array(maps);weights=2**np.arange(16,dtype=np.int64)
    canonical=np.full(1<<16,-1,dtype=int);expected=set();certificates=[]
    for code in range(1<<16):
        if canonical[code]>=0:continue
        orbit=((code>>maps)&1)@weights;orbit=np.unique(np.r_[orbit,65535-orbit]);canonical[orbit]=code
        y=np.array([1 if code>>i&1 else -1 for i in range(16)]);A=y[:,None]*X
        lp=linprog(np.zeros(5),A_ub=-A,b_ub=-np.ones(16),bounds=[(None,None)]*5,method='highs')
        if lp.success:
            w=np.array([F(float(v)).limit_denominator(1000000)for v in lp.x],dtype=object)
            assert all(v>=1 for v in A@w)
            expected.update(map(int,orbit));certificates.append(dict(code=code,size=len(orbit),feasible=True,w=list(map(str,w))))
        else:
            eq=np.r_[A.T,np.ones((1,16),dtype=int)];rhs=np.r_[np.zeros(5),1.]
            fp=linprog(np.zeros(16),A_eq=eq,b_eq=rhs,bounds=(0,None),method='highs');assert fp.success
            q=np.array([F(float(v)).limit_denominator(1000000)for v in fp.x],dtype=object)
            assert all(v>=0 for v in q) and sum(q)==1 and all(v==0 for v in A.T@q)
            certificates.append(dict(code=code,size=len(orbit),feasible=False,q=list(map(str,q))))
    actual=set(map(int,D@weights))
    assert expected==actual
    assert np.array_equal(canonical,a['canonical'])
    out=dict(orbits=len(certificates),feasible_orbits=sum(c['feasible']for c in certificates),affine_chambers=len(expected),cube_patterns=len(canonical),all_checks_exact=True,certificates=certificates)
    (ROOT/'d4_exact_cone_completeness.json').write_text(json.dumps(out,indent=2));print(json.dumps({k:v for k,v in out.items()if k!='certificates'}))

if __name__=='__main__':run()
