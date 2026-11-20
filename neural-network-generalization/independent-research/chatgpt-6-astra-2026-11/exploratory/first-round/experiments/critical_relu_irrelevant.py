"""IID importance sampler for fixed core parity plus irrelevant Boolean inputs."""
import os
for k in ['OPENBLAS_NUM_THREADS','OMP_NUM_THREADS','VECLIB_MAXIMUM_THREADS']:os.environ[k]='1'
import argparse,numpy as np,json,math,time
from scipy.special import ndtri,ndtr,erfcx
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
def run(d,r,seed,total,batch):
 assert r%2==0 and d>=r and d>=4
 M=1<<d
 if r==2:
  Xextra=np.array([[1 if i>>j&1 else -1 for j in range(d-r)]for i in range(1<<(d-r))],float);g0=.5;sgn=1.
 else:
  X=np.array([[1 if i>>j&1 else -1 for j in range(d)]for i in range(M)],float);S=X[:,:r].sum(1);chi=X[:,:r].prod(1);baseG=np.maximum(S,0)@chi/M;g0=abs(baseG);sgn=np.sign(baseG)
 rho=g0/np.sqrt(r);c=np.sqrt(2/np.pi);rng=np.random.default_rng(seed);n=0;ss=np.zeros(5);ss2=np.zeros((5,5));start=time.time()
 out=ROOT/'results'/f'critical_irrelevant_r{r}_d{d}_seed{seed}.jsonl'
 with out.open('w',buffering=1) as f:
  while n<total:
   B=min(batch,total-n);t=(1/rng.random(B)-1)/c;v=np.zeros((B,d));low=t<1
   if low.any():v[low,1:r]=-ndtri(rng.random((low.sum(),r-1))*ndtr(-t[low,None]))-t[low,None]
   idx=np.where(~low)[0]
   if len(idx):
    vals=rng.exponential(size=(len(idx),r-1))/t[idx,None];bad=rng.random(vals.shape)>np.exp(-.5*vals*vals)
    while bad.any():
     rows,cols=np.where(bad);cand=rng.exponential(size=len(rows))/t[idx[rows]];vals[rows,cols]=cand;bad[rows,cols]=rng.random(len(rows))>np.exp(-.5*cand*cand)
    v[idx,1:r]=vals
   cb=np.tan(np.pi*(rng.random((B,d-r+1))-.5));extras=cb/(1+t[:,None]);b=extras[:,0];v[:,r:]=extras[:,1:]
   if r==2:
    Bshift=b[:,None]+v[:,r:]@Xextra.T;dg=-.25*np.minimum(np.maximum(np.abs(Bshift)-v[:,1,None],0),2*t[:,None]).mean(1)
   else:
    u=b[:,None]+v@X.T;delta=np.empty_like(u);pos=S>0;neg=S<0;zero=S==0
    delta[:,pos]=np.maximum(u[:,pos],-t[:,None]*S[pos]);delta[:,neg]=np.maximum(u[:,neg]+t[:,None]*S[neg],0);delta[:,zero]=np.maximum(u[:,zero],0);dg=sgn*(delta@chi/M)
   G=g0*t+dg;d0=np.maximum(0,-dg*(2*g0*t+dg)/rho**2)
   logA=.5*np.log(np.pi/2)+np.log(erfcx(t/np.sqrt(2)));logqt=np.log(c)-2*np.log1p(c*t)
   ratioextras=np.sum(-.5*extras*extras-.5*np.log(2*np.pi)+np.log(np.pi)-np.log1p(t[:,None])+np.log1p(cb*cb),axis=1)
   logw=np.log(r)+r*np.log(c)+(r-1)*logA-logqt+ratioextras-.5*d0;w=np.exp(logw)
   U2=r*t*t+2*t*v[:,:r].sum(1)+(v*v).sum(1)+b*b;obs=np.column_stack([np.ones(B),G*G/rho,1+(G/rho)**2,U2,G*G]);val=w[:,None]*obs;ss+=val.sum(0);ss2+=val.T@val;n+=B
   if n%max(batch,(1000000//batch)*batch)==0 or n==total:
    mean=ss/n;cov=ss2/n-np.outer(mean,mean);ratio=mean/mean[0];se=[math.sqrt(cov[0,0]/n)]+[math.sqrt(max(0,cov[k,k]+ratio[k]**2*cov[0,0]-2*ratio[k]*cov[k,0])/n)/mean[0]for k in range(1,5)]
    row=dict(dimension=d,core=r,seed=seed,proposals=n,seconds=time.time()-start,rho=rho,normalizer=mean[0],normalizer_se=se[0],mc=ratio[1],mc_se=se[1],readout_energy=ratio[2],incoming_energy=ratio[3],incoming_energy_se=se[3],parity_kernel=ratio[4]);f.write(json.dumps(row)+'\n');print(json.dumps(row),flush=True)
if __name__=='__main__':
 ap=argparse.ArgumentParser();ap.add_argument('--dimension',type=int,default=6);ap.add_argument('--core',type=int,default=2);ap.add_argument('--seed',type=int,default=0);ap.add_argument('--samples',type=int,default=10000000);ap.add_argument('--batch',type=int,default=8192);a=ap.parse_args();run(a.dimension,a.core,a.seed,a.samples,a.batch)
