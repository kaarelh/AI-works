"""Finite exact radial-order and floating tangent-kernel spectral checks.

Integer minors and coefficient cross products are exact. Quadratures and the
independent 80-digit arc-cosine formula are not interval enclosures.
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
ROOT=Path(__file__).resolve().parents[1];mp.mp.dps=80

def exact_radial_orders():
    minors=orders=0
    for q in range(3,34):
        levels=list(range(0,q+1,2));m=len(levels)
        T=[[0]*m for _ in levels]
        for i,p in enumerate(levels):
            T[i][i]=q+2*p*(q-p)
            if i+1<m:T[i][i+1]=(q-p)*(q-p-1)
            if i:T[i][i-1]=p*(p-1)
        for a in range(m):
            for b in range(a+1,m):
                for j in range(m):
                    for k in range(j+1,m):
                        assert T[a][j]*T[b][k]>=T[a][k]*T[b][j]
                        minors+=1
        v=[1]+[0]*(m-1)
        for n in range(48):
            w=[sum(v[i]*T[i][j] for i in range(m)) for j in range(m)]
            for i in range(m):
                for j in range(i+1,m):
                    assert v[i]*w[j]>=v[j]*w[i]
                    orders+=1
            v=w
    return dict(dimensions=31,two_by_two_minors=minors,coefficient_cross_products=orders)

def exact_relu(d):
    q=mp.mpf(d+1)
    def ker(h):
        c=q-2*h;return (mp.sqrt(q*q-c*c)+2*c*(mp.pi-mp.acos(c/q)))/(2*mp.pi)
    return [float(sum((-1)**l*mp.binomial(p,l)*mp.binomial(d-p,h)*ker(l+h)
              for l in range(p+1) for h in range(d-p+1))/2**d) for p in range(1,d+1)]

def quadrature(d,n,betas):
    nodes,weights=roots_legendre(n);z=(nodes+1)/2;w=weights/2
    y=z/(1-z);wy=w/(1-z)**2
    v=z*9/math.sqrt(d+1);wv=w*9/math.sqrt(d+1)
    u=v[:,None]+y[None,:];delta=u*u-v[:,None]**2
    em=np.exp(-delta);sm=-np.expm1(-delta)
    base=np.exp(-(d+1)*v[:,None]**2)*(sm/delta)**2*wv[:,None]*wy[None,:]
    t=(u+v[:,None])/math.sqrt(2);s=(u-v[:,None])/math.sqrt(2)
    terms=[]
    for j in range(1,(d+1)//2+1):
        factor=1+delta/2*(2*j*(1+em)/sm+(d+1-2*j)*sm/(1+em))
        terms.append(base*sm**(2*j-2)*(1+em)**(d+1-2*j)*factor)
    ans=[]
    for beta in betas:
        mult=1 if beta is None else np.exp(log_multiplier(t,beta)+log_multiplier(s,beta))
        L=[float(np.sum(term*mult))*2.**(2-d)/math.pi**2 for term in terms]
        lam=np.array([L[(p+1)//2-1]+(.5 if p==1 else 0.) for p in range(1,d+1)])
        mass=lam*np.array([math.comb(d,p) for p in range(1,d+1)])
        ans.append(dict(beta=beta,eigenvalues=lam.tolist(),total_variance=float(mass.sum()),
                        upper_degree_tails=(np.cumsum(mass[::-1])[::-1]/mass.sum()).tolist()))
    return ans

def main():
    exact=exact_radial_orders();rows=[];ratios=tails=0;maxarc=maxquad=0.
    for d in range(2,15):
        low=quadrature(d,256,(.125,.5,1.,2.,8.,None));high=quadrature(d,512,(.125,.5,1.,2.,8.,None))
        arc=exact_relu(d);err=max(abs(a/b-1) for a,b in zip(high[-1]['eigenvalues'],arc));maxarc=max(maxarc,err);assert err<2e-8,(d,err)
        err=max(abs(a/b-1) for l,h in zip(low,high) for a,b in zip(l['eigenvalues'],h['eigenvalues']));maxquad=max(maxquad,err);assert err<2e-7,(d,err)
        for old,new in zip(high,high[1:]):
            a=old['eigenvalues'];b=new['eigenvalues']
            for p in range(1,d+1):
                for q in range(p+1,d+1):
                    diff=b[q-1]/b[p-1]-a[q-1]/a[p-1]
                    same=p>=2 and (p+1)//2==(q+1)//2
                    assert abs(diff)<1e-14 if same else diff>0,(d,p,q,diff)
                    ratios+=1
            assert all(x>y for x,y in zip(new['upper_degree_tails'][1:],old['upper_degree_tails'][1:]));tails+=d-1
        rows.append(dict(dimension=d,independent_relu_eigenvalues=arc,scales=high))
    record=dict(status='PASS',scope=__doc__.strip(),exact_radial_order=exact,dimensions=rows,
                ratio_checks=ratios,tail_checks=tails,max_arc_cosine_relative_error=maxarc,
                max_256_to_512_node_relative_error=maxquad)
    (ROOT/'results/tangent_degree_order_checks.json').write_text(json.dumps(record,indent=2)+'\n')
    print(json.dumps({k:v for k,v in record.items() if k not in ('dimensions','scope')}))
if __name__=='__main__':main()
