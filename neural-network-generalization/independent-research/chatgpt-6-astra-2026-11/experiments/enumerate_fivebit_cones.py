"""Exact-certified enumeration of all affine five-bit threshold patterns.

Every affine threshold function becomes monotone after input sign flips.
All monotone tables are enumerated by the exact f0 <= f1 recursion. Cube
permutations and monotone duality reduce the feasibility problems. Each
representative receives an exact rational primal or Farkas certificate.
The LP solver only proposes certificates; rational arithmetic verifies them.
"""
import os
for key in ('OPENBLAS_NUM_THREADS','OMP_NUM_THREADS'):os.environ[key]='1'
import itertools,json,math,time
from fractions import Fraction
from pathlib import Path
import numpy as np
from scipy.optimize import linprog
ROOT=Path(__file__).resolve().parents[1];OUT=ROOT/'results/fivebit_cones';OUT.mkdir(exist_ok=True)
started=time.monotonic();r=5;M=1<<r
monotone=[0,1];counts=[2]
for dimension in range(1,r+1):
    half=1<<(dimension-1)
    monotone=sorted(a+(b<<half) for a in monotone for b in monotone if a&~b==0)
    counts.append(len(monotone))
assert counts==[2,3,6,20,168,7581],counts
bits=(np.arange(M)[:,None]>>np.arange(r))&1
X=np.column_stack([np.ones(M,dtype=int),2*bits-1]);powers=(1<<np.arange(M,dtype=np.uint64))
maps=np.array([bits[:,perm]@(1<<np.arange(r)) for perm in itertools.permutations(range(r))],dtype=np.uint64)
mask=(1<<M)-1

def orbit(code):
    codes=(((np.uint64(code)>>maps)&1)*powers[None,:]).sum(axis=1,dtype=np.uint64)
    # f -> 1-f(complement x) preserves monotonicity.
    dual=(((np.uint64(code)>>(mask_index-maps))&1)*powers[None,:]).sum(axis=1,dtype=np.uint64)
    return set(map(int,np.r_[codes,np.uint64(mask)-dual]))

mask_index=M-1;remaining=set(monotone);certs=[];feasible=set()
while remaining:
    code=min(remaining);orb=orbit(code);assert orb<=set(monotone);assert orb<=remaining
    remaining-=orb
    y=np.array([1 if code>>i&1 else -1 for i in range(M)])
    A=y[:,None]*X
    p=linprog(np.zeros(r+1),A_ub=-A,b_ub=-np.ones(M),bounds=[(None,None)]*(r+1),method='highs')
    row=dict(code=code,orbit_size=len(orb))
    if p.success:
        w=[Fraction(float(v)).limit_denominator(1000000) for v in p.x]
        margins=[sum(Fraction(int(a))*b for a,b in zip(arow,w)) for arow in A]
        assert min(margins)>0
        scale=min(margins);w=[v/scale for v in w]
        assert all(sum(Fraction(int(a))*b for a,b in zip(arow,w))>=1 for arow in A)
        row.update(feasible=True,w=list(map(str,w)));feasible|=orb
    else:
        assert p.status==2,(p.status,p.message)
        qsol=linprog(np.zeros(M),A_eq=np.vstack([A.T,np.ones(M)]),b_eq=np.r_[np.zeros(r+1),1.],bounds=(0,None),method='highs')
        assert qsol.success,qsol.message
        q=[Fraction(float(v)).limit_denominator(1000000) for v in qsol.x]
        assert min(q)>=0 and sum(q)==1
        assert all(sum(Fraction(int(a))*b for a,b in zip(col,q))==0 for col in A.T)
        row.update(feasible=False,q=list(map(str,q)))
    certs.append(row)
allcodes=set()
for code in feasible:
    for flip in range(M):
        allcodes.add(sum(((code>>(i^flip))&1)<<i for i in range(M)))
codes=np.array(sorted(allcodes),dtype=np.uint32)
D=((codes[:,None].astype(np.uint64)>>np.arange(M,dtype=np.uint64))&1).astype(np.int8)
np.savez_compressed(OUT/'activation_patterns.npz',X=X,D=D,codes=codes)
result=dict(status='PASS',dimension=r,monotone_counts=counts,monotone_thresholds=len(feasible),
    monotone_orbits=len(certs),feasible_monotone_orbits=sum(row['feasible'] for row in certs),
    affine_activation_patterns=len(codes),certificates=certs,seconds=time.monotonic()-started,
    qualification='All monotone cases and symmetry closure are exhaustive; LP outputs are accepted only after exact rational primal/Farkas verification.')
(OUT/'exact_enumeration.json').write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps({k:v for k,v in result.items() if k!='certificates'}))
