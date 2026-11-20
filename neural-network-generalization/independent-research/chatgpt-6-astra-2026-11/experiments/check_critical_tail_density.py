"""Full-support importance check of the d=r=4 critical local density.

The actual 16-input ReLU Fourier coefficient is used, including parameters
outside the critical cones. The importance density is a normalized mixture
on all incoming-parameter space. The unknown critical partition function
cancels from the ratio to the asserted density constant. This is Monte Carlo,
not an interval certificate or a conditional-limit proof.
"""
import os
for key in ('OPENBLAS_NUM_THREADS','OMP_NUM_THREADS','VECLIB_MAXIMUM_THREADS'):os.environ[key]='1'
import json,math,time
from pathlib import Path
import numpy as np
from scipy.special import logsumexp
ROOT=Path(__file__).resolve().parents[1];r=4;d=4;alpha=1.5;rho=.125
X=2*((np.arange(16)[:,None]>>np.arange(4))&1)-1;parity=np.prod(X,axis=1)
B=np.array([[1,1,-1,-1],[1,-1,1,-1],[1,-1,-1,1]],float)/2
Hvol=832/27;Cunn=(2*math.pi)**(-2.5)*rho**alpha/3*16*Hvol
mix=np.array([math.comb(3,j)*math.factorial(j)/3**(j+1) for j in range(4)]);mix/=mix.sum()

def draw_transverse(rng,n):
 shape=1+rng.choice(4,size=n,p=mix);t0=rng.gamma(shape,1/3);bias=(2*rng.integers(0,2,n)-1)*2*t0
 t=np.empty((n,3))
 for i in range(3):
  inner=rng.random(n)<t0/(1+t0);x=rng.uniform(-1,1,n)*t0
  tail=(2*rng.integers(0,2,n)-1)*(t0+rng.exponential(size=n))
  t[:,i]=np.where(inner,x,tail)
 return bias,t

def run(z,seed,samples=1<<20):
 rng=np.random.default_rng(seed);R0=math.sqrt(z/rho);sumw=sumw2=0.;n=0;maxw=0.;nonzero=0
 for first in range(0,samples,16384):
  size=min(16384,samples-first);bt,t=draw_transverse(rng,size);R=R0+.5*rng.normal(size=size);signs=X[rng.integers(0,16,size)]
  w=(R[:,None]/2+(t@B)/R0)*signs;b=bt/R0
  G=np.maximum(b[:,None]+w@X.T,0)@parity/16
  logs=[]
  for s in X:
   aligned=w*s;rs=aligned.sum(axis=1)/2;ts=R0*(aligned@B.T)
   h=np.maximum(abs(b*R0)[:,None]/2,abs(ts)).sum(axis=1)
   logs.append(-2*(rs-R0)**2-math.log(.5*math.sqrt(2*math.pi))+4*math.log(R0)-math.log(Hvol)-h)
  logq=logsumexp(np.stack(logs),axis=0)-math.log(16)
  weight=np.zeros(size);keep=abs(G)>1e-14
  aa=z/G[keep];energy=.5*(aa*aa+b[keep]**2+np.sum(w[keep]**2,axis=1))-z/rho
  logdensity=-3*math.log(2*math.pi)-np.log(abs(G[keep]))-energy
  weight[keep]=np.exp(logdensity-logq[keep])/(alpha*Cunn*z**(-alpha-1))
  sumw+=weight.sum();sumw2+=weight@weight;n+=size;maxw=max(maxw,float(weight.max()));nonzero+=int(keep.sum())
 mean=sumw/n;se=math.sqrt(max(0,sumw2/n-mean*mean)/(n-1))
 return dict(z=z,seed=seed,samples=n,density_ratio=mean,empirical_standard_error=se,maximum_importance_ratio=maxw,nonzero_coefficient_samples=nonzero)

if __name__=='__main__':
 started=time.monotonic();rows=[]
 for z in (1,2,4,8,16,32,64,128,256,512,1024,4096):
  for rep in range(3):
   row=run(z,202611184000+3*int(z)+rep);rows.append(row);print(json.dumps(row),flush=True)
   (ROOT/'results/critical_tail_density_checks.json').write_text(json.dumps(dict(status='in_progress',rows=rows),indent=2)+'\n')
 (ROOT/'results/critical_tail_density_checks.json').write_text(json.dumps(dict(status='complete',rows=rows,seconds=time.monotonic()-started,
   qualification='Full-support importance Monte Carlo of the actual ReLU coefficient. Empirical standard errors are diagnostic, not certified coverage; no posterior mixing claim.'),indent=2)+'\n')
