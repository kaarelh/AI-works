"""Propose integer certificates for numerical five-bit cost gaps.

NNLS proposes polar multipliers. A separate checker verifies all bounds
using integer arithmetic and never invokes an optimizer.
"""
import os
os.environ['OPENBLAS_NUM_THREADS']='1';os.environ['OMP_NUM_THREADS']='1'
import argparse,json,math,time
from pathlib import Path
import numpy as np
from scipy.optimize import nnls
ROOT=Path(__file__).resolve().parents[1];OUT=ROOT/'results/fivebit_certificates';OUT.mkdir(exist_ok=True)
cones=np.load(ROOT/'results/fivebit_cones/activation_patterns.npz');X=cones['X'].astype(np.int64);D=cones['D']

def build(prefix,scale=10000000):
    first=time.monotonic();base=ROOT/'results/fivebit_variation';stem=f'gate_recursive_prefix{prefix}'
    history=np.load(base/(stem+'_history.npz'));correct=np.load(base/(stem+'_correct.npz'))
    co=history['coefficients'];nonzero=np.flatnonzero(abs(co)>1e-10)
    W=np.rint(history['V'][nonzero]*abs(co[nonzero,None])*100000000).astype(np.int64)
    signs=np.sign(co[nonzero]).astype(np.int64)
    integer_output=np.maximum(X@W.T,0)@signs
    hids=history['ids'];target=history['target'].astype(np.int64)
    minmargin=int(np.min(target[hids]*integer_output[hids]));assert minmargin>0
    denominator=2*minmargin
    upper_num=sum(math.isqrt(sum(int(v)**2 for v in row))+(math.isqrt(sum(int(v)**2 for v in row))**2<sum(int(v)**2 for v in row)) for row in W)
    ids=correct['ids'];labels=correct['labels'].astype(np.int64);alpha=np.maximum(0,np.rint(correct['alpha']*scale)).astype(np.int64)
    ds=np.unique(D[:,ids],axis=0);xs=X[ids]
    gradient=(ds*(alpha*labels)[None,:])@xs
    floating_gradient=(ds*(correct['alpha']*labels)[None,:])@xs
    # At most six positive coefficients suffice for NNLS in R^6.
    active=np.full((len(ds),2,6),255,dtype=np.uint8);multipliers=np.zeros((len(ds),2,6),dtype=np.int64)
    maxsq=0
    for j,d in enumerate(ds):
        cone=(2*d.astype(np.int64)-1)[:,None]*xs
        for k,sign in enumerate((-1,1)):
            g=sign*gradient[j];q,_=nnls(cone.T.astype(float),-sign*floating_gradient[j],maxiter=300)
            qi=np.maximum(0,np.rint(q*scale)).astype(np.int64);nz=np.flatnonzero(qi)
            assert len(nz)<=6
            active[j,k,:len(nz)]=nz;multipliers[j,k,:len(nz)]=qi[nz]
            residual=g+cone.T@qi
            sq=sum(int(v)**2 for v in residual);maxsq=max(maxsq,sq)
    radius=math.isqrt(maxsq)+(math.isqrt(maxsq)**2<maxsq)
    lower_num=int(alpha[:-1].sum());lower_den=2*radius
    assert lower_num*denominator>upper_num*lower_den,(prefix,lower_num/lower_den,upper_num/denominator)
    np.savez_compressed(OUT/(stem+'.npz'),W=W,signs=signs,denominator=denominator,ids=ids,labels=labels,alpha=alpha,patterns=ds,active=active,multipliers=multipliers,radius=radius,order=history['order'],target=target)
    row=dict(prefix=prefix,upper_numerator=upper_num,upper_denominator=denominator,lower_numerator=lower_num,lower_denominator=lower_den,gap=lower_num/lower_den-upper_num/denominator,patterns=len(ds),primal_width=len(W),seconds=time.monotonic()-first)
    print(json.dumps(row),flush=True);return row

def main():
    ap=argparse.ArgumentParser();ap.add_argument('--prefix',type=int);args=ap.parse_args()
    if args.prefix is None:
        campaign=json.loads((ROOT/'results/fivebit_variation/recursive_campaign.json').read_text());prefixes=[r['prefix'] for r in campaign['rows'] if r.get('gap',0)>1e-4]
    else:prefixes=[args.prefix]
    rows=[build(i) for i in prefixes];(OUT/'proposals.json').write_text(json.dumps(rows,indent=2)+'\n')
if __name__=='__main__':main()
