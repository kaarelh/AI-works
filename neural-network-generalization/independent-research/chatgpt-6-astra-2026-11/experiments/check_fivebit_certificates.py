"""Verify all five-bit mistake certificates by integer arithmetic only.

The independent activation enumeration checker is invoked first. No
optimization or floating-point comparisons are used for the conclusion.
"""
import json,math,hashlib
from fractions import Fraction
from pathlib import Path
import numpy as np
from check_fivebit_enumeration import verify as verify_enumeration
ROOT=Path(__file__).resolve().parents[1];OUT=ROOT/'results/fivebit_certificates'

def check(path,allpatterns):
    z=np.load(path);W=z['W'];signs=z['signs'];H=int(z['denominator']);alpha=z['alpha'];radius=int(z['radius'])
    X=np.array([[1]+[2*((i>>j)&1)-1 for j in range(5)] for i in range(32)],dtype=np.int64)
    target=np.prod(X[:,1:4],axis=1)*np.where(np.all(X[:,4:]==1,axis=1),1,-1)
    old=[15,14,13,11,10,9,7,6,3,5,2,8,1,12,4,0]
    rev=lambda q:sum(((q>>(3-j))&1)<<j for j in range(4))
    order=np.array([1+2*rev(q) for q in old]+[2*rev(q) for q in old])
    ids=z['ids'];prefix=len(ids)-1;labels=z['labels'];ds=z['patterns'];act=z['active'];q=z['multipliers']
    assert np.array_equal(z['order'],order) and np.array_equal(z['target'],target)
    assert np.array_equal(ids,order[:prefix+1]) and np.array_equal(labels,target[ids])
    assert np.array_equal(ds,np.unique(allpatterns[:,ids],axis=0))
    assert alpha.dtype.kind in 'iu' and len(alpha)==len(ids) and np.min(alpha)>=0
    assert np.max(alpha)<1000000000 and radius>0
    assert q.dtype.kind in 'iu' and np.min(q)>=0 and np.max(q)<1000000000
    assert q.shape==act.shape==(len(ds),2,6)
    assert np.all((act==255)|(act<len(ids))) and np.all(q[act==255]==0)
    xs=X[ids];gradient=(ds*(alpha*labels)[None,:])@xs
    # Integer entries and the explicit size checks below prevent overflow.
    maxsq=0
    for k,sign in enumerate((-1,1)):
        residual=sign*gradient.copy()
        for l in range(6):
            indices=act[:,k,l].astype(np.int64);safe=np.minimum(indices,len(ids)-1)
            signed_rows=(2*ds[np.arange(len(ds)),safe]-1)[:,None]*xs[safe]
            residual+=q[:,k,l,None]*signed_rows
        assert np.max(abs(residual))<1000000000
        squared=np.sum(residual*residual,axis=1)
        maxsq=max(maxsq,int(squared.max()))
        assert all(int(v)<=radius*radius for v in squared)
    assert W.dtype.kind in 'iu' and signs.dtype.kind in 'iu' and W.shape[1]==6
    assert np.all(abs(signs)==1) and np.max(abs(W))<1000000000 and len(W)<=32 and H>0
    outputs=np.maximum(X@W.T,0)@signs
    assert np.all(2*target[ids[:-1]]*outputs[ids[:-1]]>=H)
    upper_num=0
    for row in W:
        sq=sum(int(v)**2 for v in row);rt=math.isqrt(sq);upper_num+=rt+(rt*rt<sq)
    upper=Fraction(upper_num,H);lower=Fraction(sum(map(int,alpha[:-1])),2*radius)
    assert lower>upper,(prefix,lower,upper)
    # Seven scalar neuron coordinates: epsilon=.00001 and tau=.001.
    # log(100000)<12, so the cumulant penalty is below 42.
    rate_gap=1000000*(Fraction(99999,100000)*lower-upper)-42
    assert rate_gap>0,(prefix,rate_gap)
    return dict(prefix=prefix,query=int(order[prefix]),upper=str(upper),lower=str(lower),gap=str(lower-upper),gap_decimal=float(lower-upper),fixed_temperature_rate_gap=str(rate_gap),patterns=len(ds),primal_width=len(W),certificate_sha256=hashlib.sha256(path.read_bytes()).hexdigest())

def main():
    enumeration=verify_enumeration();patterns=np.load(ROOT/'results/fivebit_cones/activation_patterns.npz')['D']
    paths=sorted(OUT.glob('gate_recursive_prefix*.npz'),key=lambda p:int(p.stem.split('prefix')[-1]))
    rows=[check(p,patterns) for p in paths]
    result=dict(status='PASS',checks=rows,count=len(rows),enumeration=enumeration,qualification='All displayed gaps are exact rational inequalities, with complete activation-cone coverage. This is a finite five-bit result, not an asymptotic lower bound.')
    (OUT/'independent_verification.json').write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps(dict(status='PASS',count=len(rows),prefixes=[r['prefix'] for r in rows],smallest_gap=min(r['gap_decimal'] for r in rows),maximum_primal_width=max(r['primal_width'] for r in rows))))
if __name__=='__main__':main()
