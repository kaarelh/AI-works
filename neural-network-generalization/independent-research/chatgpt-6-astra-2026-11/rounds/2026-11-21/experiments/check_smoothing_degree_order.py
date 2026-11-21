"""Positive quadrature and independent ReLU checks for normalized degree ordering.

These floating-point checks are not interval certificates. The manuscript gives
an analytic likelihood-ratio/association proof for every dimension and scale.
"""
import os
for key in ('OPENBLAS_NUM_THREADS','OMP_NUM_THREADS','VECLIB_MAXIMUM_THREADS'):
    os.environ[key]='1'
import json,math
from pathlib import Path
import mpmath as mp
import numpy as np
from scipy.special import roots_legendre
from check_smoothing_moment_order import log_multiplier
ROOT=Path(__file__).resolve().parents[1]
mp.mp.dps=80

def relu_eigenvalues(d):
    q=mp.mpf(d+1)
    def kernel(j):
        c=q-2*j
        return (mp.sqrt(q*q-c*c)+c*(mp.pi-mp.acos(c/q)))/(2*mp.pi)
    return [float(sum((-1)**l*mp.binomial(p,l)*mp.binomial(d-p,h)*kernel(l+h)
                for l in range(p+1) for h in range(d-p+1))/2**d)
            for p in range(1,d+1)]

def eigenvalues(d,n,betas):
    nodes,weights=roots_legendre(n);z=(nodes+1)/2;w=weights/2
    y=z/(1-z);wy=w/(1-z)**2
    v=z*9/math.sqrt(d+1);wv=w*9/math.sqrt(d+1)
    u=v[:,None]+y[None,:];delta=u*u-v[:,None]**2
    em=np.exp(-delta);sm=-np.expm1(-delta)
    base=np.exp(-(d+1)*v[:,None]**2)*(sm/delta)**2*wv[:,None]*wy[None,:]
    t=(u+v[:,None])/math.sqrt(2);s=(u-v[:,None])/math.sqrt(2)
    terms=[base*sm**(2*j-2)*(1+em)**(d+1-2*j)
           for j in range(1,(d+1)//2+1)]
    ans=[]
    for beta in betas:
        mult=1 if beta is None else np.exp(log_multiplier(t,beta)+log_multiplier(s,beta))
        L=[float(np.sum(term*mult))*2.**(2-d)/math.pi**2 for term in terms]
        lam=np.array([L[(p+1)//2-1]+(.25 if p==1 else 0.) for p in range(1,d+1)])
        mass=lam*np.array([math.comb(d,p) for p in range(1,d+1)])
        ans.append(dict(beta=beta,eigenvalues=lam.tolist(),total_variance=float(mass.sum()),
                        upper_degree_tails=(np.cumsum(mass[::-1])[::-1]/mass.sum()).tolist()))
    return ans

def main():
    rows=[];ratio_checks=tail_checks=0;max_arc_error=0.;max_quad_error=0.
    betas=(.125,.5,1.,2.,8.,None)
    for d in range(2,13):
        low=eigenvalues(d,256,betas);high=eigenvalues(d,512,betas)
        arc=relu_eigenvalues(d)
        err=max(abs(a/b-1) for a,b in zip(high[-1]['eigenvalues'],arc))
        max_arc_error=max(max_arc_error,err);assert err<2e-8,(d,err)
        qerr=max(abs(a/b-1) for l,h in zip(low,high) for a,b in zip(l['eigenvalues'],h['eigenvalues']))
        max_quad_error=max(max_quad_error,qerr);assert qerr<2e-7,(d,qerr)
        for old,new in zip(high,high[1:]):
            a=np.array(old['eigenvalues']);b=np.array(new['eigenvalues'])
            for p in range(1,d+1):
                for q in range(p+1,d+1):
                    same=p>=2 and (p+1)//2==(q+1)//2
                    diff=b[q-1]/b[p-1]-a[q-1]/a[p-1]
                    assert abs(diff)<1e-14 if same else diff>0,(d,p,q,diff)
                    ratio_checks+=1
            assert all(x>y for x,y in zip(new['upper_degree_tails'][1:],old['upper_degree_tails'][1:]))
            tail_checks+=d-1
        rows.append(dict(dimension=d,independent_relu_eigenvalues=arc,quadrature_comparison_error=qerr,scales=high))
    record=dict(status='PASS',scope=__doc__.strip(),dimensions=rows,ratio_checks=ratio_checks,
                tail_checks=tail_checks,max_arc_cosine_relative_error=max_arc_error,
                max_256_to_512_node_relative_error=max_quad_error)
    (ROOT/'results/smoothing_degree_order_checks.json').write_text(json.dumps(record,indent=2)+'\n')
    print(json.dumps({k:v for k,v in record.items() if k not in ('dimensions','scope')}))
if __name__=='__main__':main()
