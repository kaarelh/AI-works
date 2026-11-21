"""Independent finite and quadrature checks of the positive moment formula.

No interval enclosure or proof of the analytic integral interchange is claimed.
The second-moment response is compared with an independent arc-cosine formula.
"""
import os
for key in ('OPENBLAS_NUM_THREADS','OMP_NUM_THREADS','VECLIB_MAXIMUM_THREADS'):
    os.environ[key]='1'
import itertools,json,math
from pathlib import Path
import mpmath as mp
import numpy as np
from scipy.special import roots_hermitenorm,roots_legendre

ROOT=Path(__file__).resolve().parents[1]
mp.mp.dps=80

def radical_response(r):
    q=mp.mpf(r+1)
    return -mp.pi/(6*2**r)*sum((-1)**j*mp.binomial(r,j)*
        mp.sqrt(1-((q-2*j)/q)**2) for j in range(r+1))

def exact_relu_variance(r):
    q=mp.mpf(r+1)
    def kernel(j):
        c=q-2*j
        return (mp.sqrt(q*q-c*c)+c*(mp.pi-mp.acos(c/q)))/(2*mp.pi)
    return sum((-1)**j*mp.binomial(r,j)*kernel(j) for j in range(r+1))/2**r

def log_multiplier(t,beta):
    x=math.pi*t/beta
    ans=np.empty_like(x);small=x<.01
    y=x[small]**2
    ans[small]=-y/6+y*y/180-y*y*y/2835+y**4/37800
    z=x[~small]
    ans[~small]=np.log(2*z)-z-np.log(-np.expm1(-2*z))
    return ans

def quadrature(r,n,betas):
    node,weight=roots_legendre(n)
    z=(node+1)/2;wz=weight/2
    y=z/(1-z);wy=wz/(1-z)**2
    vmax=9/math.sqrt(r+1)
    v=z*vmax;wv=wz*vmax
    u=v[:,None]+y[None,:]
    delta=u*u-v[:,None]**2
    ratio=-np.expm1(-delta)/delta
    base=np.exp(-(r+1)*v[:,None]**2)*(1+np.exp(-delta))*ratio**2
    if r>2:base*=(-np.expm1(-delta))**(r-2)
    measure=wv[:,None]*wy[None,:]
    variance=float(np.sum(base*measure))*2.**(2-r)/math.pi**2
    response=float(np.sum(base*(u*u+v[:,None]**2)*measure))*2.**(1-r)/3
    t=(u+v[:,None])/math.sqrt(2);s=(u-v[:,None])/math.sqrt(2)
    differences={}
    for beta in betas:
        gap=-np.expm1(log_multiplier(t,beta)+log_multiplier(s,beta))
        differences[str(beta)]=float(np.sum(base*gap*measure))*2.**(2-r)/math.pi**2
    return dict(nodes=n,variance=variance,response=response,differences=differences)

def finite_gaussian_product_checks():
    rng=np.random.default_rng(2026112291)
    nodes,weights=roots_hermitenorm(160);weights/=math.sqrt(2*math.pi)
    largest=0.;checks=0
    for j in range(1,5):
        signs=np.array(list(itertools.product((-1,1),repeat=2*j)))
        for _ in range(12):
            t=rng.uniform(.02,1.1,2*j)
            exps=np.exp(-.5*(signs@t)**2)
            C=exps.mean()
            S=(-1)**j*np.mean(np.prod(signs,axis=1)*exps)
            Cquad=np.dot(weights,np.prod(np.cos(nodes[:,None]*t),axis=1))
            Squad=np.dot(weights,np.prod(np.sin(nodes[:,None]*t),axis=1))
            err=max(abs(C-Cquad),abs(S-Squad));largest=max(largest,float(err))
            assert C>0 and err<2e-13
            for r in (2,4,6,8):assert C*S**r>=0
            checks+=1
    return dict(cases=checks,max_absolute_error=largest)

def main():
    rows=[]
    for r in (2,4,6,8,10,12):
        exactD=radical_response(r);exactV=exact_relu_variance(r)
        q=[quadrature(r,n,(1,4,16,64,256,1024)) for n in (128,256,512)]
        assert abs(q[-1]['response']/float(exactD)-1)<2e-8
        assert abs(q[-1]['variance']/float(exactV)-1)<2e-8
        differences=list(q[-1]['differences'].values())
        assert all(a>b>0 for a,b in zip(differences,differences[1:]))
        rho=mp.binomial(r-2,(r-2)//2)/(2**(r-1)*mp.sqrt(r))
        rows.append(dict(dimension=r,radical_response=str(exactD),
            relu_variance=str(exactV),normalizer_negative_coefficient_lower_bound=str(exactD/(2*rho*rho)),
            quadratures=q))
    record=dict(status='PASS',scope='Floating-point and 80-digit scalar checks, not interval enclosures. Analytic positivity and moment ordering are proved in the manuscript.',
        gaussian_products=finite_gaussian_product_checks(),dimensions=rows)
    (ROOT/'results/smoothing_moment_order_checks.json').write_text(json.dumps(record,indent=2)+'\n')
    print(json.dumps(dict(status='PASS',dimensions=len(rows),gaussian_products=record['gaussian_products'])))

if __name__=='__main__':main()
