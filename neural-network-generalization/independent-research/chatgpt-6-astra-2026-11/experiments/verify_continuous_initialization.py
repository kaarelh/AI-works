"""Independent numerical formulations of the smoothing and Fourier bounds.

The Hamming-level Gaussian expectation is compared with a positive integral.
These are high-precision diagnostics, not interval-certified numerical proofs.
Monte Carlo rows are labeled as estimates and do not certify expectation bounds.
"""
import json, math, os, itertools
from pathlib import Path
import mpmath as mp
import numpy as np
ROOT=Path(__file__).resolve().parents[1]
mp.mp.dps=100

def hamming_mean(r, sigma):
    sigma=mp.mpf(str(sigma)); v=sigma*mp.sqrt(r)
    if not v:
        return mp.mpf(math.comb(r-2,(r-2)//2))/2**(r-1)
    vals=[]
    for k in range(r+1):
        t=mp.mpf(2*k-r)
        smooth=v*mp.exp(-t*t/(2*v*v))/mp.sqrt(2*mp.pi)+t*mp.erfc(-t/(v*mp.sqrt(2)))/2
        vals.append(mp.mpf(math.comb(r,k))*(-1)**(r-k)*smooth)
    return abs(mp.fsum(vals)/2**r)

def integral_mean(r,sigma):
    a=mp.mpf(str(sigma))**2*r/2
    cutoff=mp.sqrt(160/a)
    end=int(mp.ceil(cutoff/mp.pi))
    f=lambda t: mp.exp(-a*t*t)*mp.sin(t)**r/(mp.pi*t*t) if t else mp.mpf(0)
    vals=[mp.quad(f,[i*mp.pi,(i+mp.mpf('0.5'))*mp.pi,(i+1)*mp.pi]) for i in range(end)]
    tail=mp.exp(-a*(end*mp.pi)**2)/(mp.pi*end*mp.pi)
    return mp.fsum(vals),tail

rows=[]
for r in (6,8,12,20,40,80):
    for sigma in (0.05,0.1,0.2,0.5,1.0):
        hm=hamming_mean(r,sigma)
        integ,tail=integral_mean(r,sigma)
        err=abs(hm-integ)
        assert err <= max(mp.mpf('1e-55')*hm,tail*2), (r,sigma,str(err/hm),str(tail))
        lower=2/(mp.pi**3*mp.sqrt(r))*mp.exp(-mp.pi**2*mp.mpf(str(sigma))**2*r/8)
        assert hm>=lower
        rows.append(dict(r=r,sigma=sigma,mean=str(hm),positive_integral=str(integ),
            relative_difference=str(err/hm),tail_upper=str(tail),lower_bound=str(lower)))
        print(json.dumps(dict(r=r,sigma=sigma,relative_difference=float(err/hm))),flush=True)

rng=np.random.default_rng(2026111807)
mc=[]
for r in (6,8,10,12):
    x=np.array(list(itertools.product((-1.,1.),repeat=r)))
    chi=np.prod(x,axis=1)
    for sigma in (0.,0.05,0.2,0.5,1.):
        samples=20000
        total=total2=total4=0.
        for start in range(0,samples,100):
            count=min(100,samples-start)
            signs=rng.choice((-1.,1.),size=(count,r))
            w=signs+sigma*rng.normal(size=(count,r))
            g=np.maximum(x@w.T,0).T@chi/len(x)
            aligned=g*np.prod(signs,axis=1)*(-1)**(r//2+1)
            total+=aligned.sum();total2+=np.dot(g,g);total4+=np.dot(g*g,g*g)
        est=total2/samples
        se=math.sqrt(max(0,total4/samples-est*est)/samples)
        hm=float(hamming_mean(r,sigma))
        c0=(1-math.exp(-math.pi**2/8))/2
        upper=(1+sigma*sigma)/math.pi**2*(r/(r-1))**2*math.exp(-c0*sigma*sigma*(r-1))
        mc.append(dict(r=r,sigma=sigma,samples=samples,aligned_mean_estimate=total/samples,
            exact_aligned_mean=hm,kernel_estimate=est,kernel_standard_error=se,
            rigorous_lower=hm*hm,rigorous_upper=upper))
        # Sanity check with a deliberately broad statistical allowance.
        assert hm*hm <= est+10*se+1e-10, (r,sigma,'lower',est,se,hm)
        assert est <= upper+10*se, (r,sigma,'upper',est,se,upper)

result=dict(status='PASS',precision_decimal_digits=mp.mp.dps,
    integral_checks=rows,monte_carlo_diagnostics=mc,
    qualification='High-precision and Monte Carlo checks; not interval proofs or independent review.')
(ROOT/'results/continuous_initialization_checks.json').write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps(dict(status='PASS',integral_cases=len(rows),monte_carlo_cases=len(mc))),flush=True)
