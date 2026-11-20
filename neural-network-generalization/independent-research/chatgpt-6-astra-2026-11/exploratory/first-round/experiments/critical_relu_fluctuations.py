"""Critical mixed output/kernel moments for the proposed posterior CLT.
Same independently sampled importance proposal as critical_relu_covariance.py.
Finite numerical estimates; no interval certification.
"""
import os
for k in ['OPENBLAS_NUM_THREADS','OMP_NUM_THREADS','VECLIB_MAXIMUM_THREADS']:os.environ[k]='1'
import argparse,json,time,math
from pathlib import Path
import numpy as np
from scipy.special import ndtri,erfcx
ROOT=Path(__file__).resolve().parents[1]
def fwht(a):
 a=a.copy();n=a.shape[1];h=1
 while h<n:
  v=a.reshape(len(a),-1,2*h);left=v[:,:,:h].copy();right=v[:,:,h:].copy();v[:,:,:h]=left+right;v[:,:,h:]=left-right;h*=2
 return a/n
def run(d,seed,total,batch):
 assert d>=4 and d%2==0
 M=1<<d;X=np.array([[1 if (i>>j)&1 else -1 for j in range(d)] for i in range(M)],float);S=X.sum(1);base=fwht(np.maximum(S,0)[None,:])[0];g0=abs(base[-1]);sgn=np.sign(base[-1]);rho=g0/np.sqrt(d);c=np.sqrt(2/np.pi)
 # FWHT convention uses (-1)^bit, differing by a degree sign from X; squares are unchanged and even parity is unchanged.
 degrees=np.array([i.bit_count() for i in range(M)]);rng=np.random.default_rng(seed);names=['normalizer','mc_numerator','readout_energy_numerator','incoming_energy_numerator']+[f'kernel_degree_{k}_numerator' for k in range(d+1)]+[f'output_second_degree_{k}_numerator' for k in range(d+1)]
 even=np.array([i for i in range(M) if i.bit_count()%2==0]);single=np.array([1<<i for i in range(d)])
 mixed_classes=[(e,inside) for e in range(0,d+1,2) for inside in [0,1] if (e>0 or not inside) and (e<d or inside)]
 mixed_indices=[]
 for e,inside in mixed_classes:
  pairs=[(E,i) for E in even if E.bit_count()==e for i in range(d) if ((E>>i)&1)==inside]
  mixed_indices.append((np.array([E for E,i in pairs]),np.array([1<<i for E,i in pairs]),np.array([(M-1)^E^(1<<i) for E,i in pairs])))
 names+=['cross_kernel_second_trace']+[f'mixed_{e}_{inside}' for e,inside in mixed_classes]
 n=0;ss=np.zeros(len(names));ss2=np.zeros((len(names),len(names)));start=time.time();out=ROOT/'results'/f'critical_relu_fluctuations_d{d}_seed{seed}.jsonl'
 with out.open('w',buffering=1) as f:
  while n<total:
   B=min(batch,total-n);t=(1/rng.random(B)-1)/c;v=np.zeros((B,d));low=t<1
   if low.any():
    # Survival inverse of standard normal truncated below t; log-tail is unnecessary for t<1.
    from scipy.special import ndtr
    v[low,1:]=-ndtri(rng.random((low.sum(),d-1))*ndtr(-t[low,None]))-t[low,None]
   idx=np.where(~low)[0]
   if len(idx):
    vals=rng.exponential(size=(len(idx),d-1))/t[idx,None];bad=rng.random(vals.shape)>np.exp(-.5*vals*vals)
    while bad.any():
     rows,cols=np.where(bad);cand=rng.exponential(size=len(rows))/t[idx[rows]];vals[rows,cols]=cand;bad[rows,cols]=rng.random(len(rows))>np.exp(-.5*cand*cand)
    v[idx,1:]=vals
   cb=np.tan(np.pi*(rng.random(B)-.5));b=cb/(1+t)
   u=b[:,None]+v@X.T;delta=np.empty_like(u)
   pos=S>0;neg=S<0;zero=S==0
   delta[:,pos]=np.maximum(u[:,pos],-t[:,None]*S[pos]);delta[:,neg]=np.maximum(u[:,neg]+t[:,None]*S[neg],0);delta[:,zero]=np.maximum(u[:,zero],0)
   dh=fwht(delta);gh=sgn*dh[:,-1];G=g0*t+gh;d0=np.maximum(0.,-gh*(2*g0*t+gh)/(rho*rho))
   logA=.5*np.log(np.pi/2)+np.log(erfcx(t/np.sqrt(2)))
   logqt=np.log(c)-2*np.log1p(c*t);logratio_b=-.5*b*b-.5*np.log(2*np.pi)+np.log(np.pi)-np.log1p(t)+np.log1p(cb*cb)
   logweight=np.log(d)+d*np.log(c)+(d-1)*logA-logqt+logratio_b-.5*d0;weight=np.exp(logweight)
   hats=t[:,None]*base+dh;kernel=np.column_stack([np.mean(hats[:,degrees==k]**2,axis=1) for k in range(d+1)]);readout2=1+(G/rho)**2;incoming2=d*t*t+2*t*v.sum(1)+(v*v).sum(1)+b*b
   cross_trace=np.sum(hats[:,even]**2,axis=1)*np.sum(hats[:,single]**2,axis=1)
   mixed=np.column_stack([sgn*G/rho*np.mean(hats[:,E]*hats[:,i]*hats[:,v],axis=1) for E,i,v in mixed_indices])
   obs=np.column_stack([np.ones(B),G*G/rho,readout2,incoming2,kernel,readout2[:,None]*kernel,cross_trace,mixed]);vals=weight[:,None]*obs;ss+=vals.sum(0);ss2+=vals.T@vals;n+=B
   if n%max(batch,(1000000//batch)*batch)==0 or n==total:
    mean=ss/n;cov=ss2/n-np.outer(mean,mean);ratio=mean/mean[0];se=[]
    for k in range(len(names)):
     if k==0:se.append(math.sqrt(max(0,cov[0,0])/n))
     else:se.append(math.sqrt(max(0,cov[k,k]+ratio[k]**2*cov[0,0]-2*ratio[k]*cov[k,0])/n)/mean[0])
    row=dict(dimension=d,seed=seed,proposals=n,seconds=time.time()-start,rho=rho,normalizer=mean[0],normalizer_se=se[0],mc=ratio[1],mc_se=se[1],readout_energy=ratio[2],incoming_energy=ratio[3],kernel_eigenvalues=ratio[4:5+d].tolist(),kernel_se=se[4:5+d],output_second_moments=ratio[5+d:6+2*d].tolist(),output_second_se=se[5+d:6+2*d],output_covariance_eigenvalues=(M*(ratio[5+d:6+2*d]-np.eye(1,d+1,d)[0]*ratio[1]**2)).tolist(),cross_trace=float(ratio[6+2*d]),cross_trace_se=se[6+2*d],mixed_classes=mixed_classes,mixed_covariance=ratio[7+2*d:].tolist(),mixed_covariance_se=se[7+2*d:])
    f.write(json.dumps(row)+'\n');print(json.dumps(row),flush=True)
  np.savez_compressed(ROOT/'results'/f'critical_relu_fluctuations_d{d}_seed{seed}_moments.npz',sum=ss,sum_outer=ss2,n=n,names=names)
if __name__=='__main__':
 ap=argparse.ArgumentParser();ap.add_argument('--dimension',type=int,default=6);ap.add_argument('--seed',type=int,default=0);ap.add_argument('--samples',type=int,default=1000000);ap.add_argument('--batch',type=int,default=16384);a=ap.parse_args();run(a.dimension,a.seed,a.samples,a.batch)
