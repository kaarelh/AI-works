"""Exhaustive six-bit orientation diagnostics for raw exceptional features.

The orientation list is exact. Projection, covariance weighting, and error
statistics are floating-point diagnostics, not formal/asymptotic certificates.
The covariance input comes from the first round's independent importance run.
"""
import os
for key in ('OPENBLAS_NUM_THREADS','OMP_NUM_THREADS','VECLIB_MAXIMUM_THREADS'):os.environ[key]='1'
import json,math,time
from pathlib import Path
import numpy as np
ROOT=Path(__file__).resolve().parents[1];start=time.monotonic()
r=6;K=32;M=64
patterns=np.fromfile(ROOT/'results/relu_balanced_orientations_d6.bin',dtype='<u4')
cov=json.loads((ROOT/'results/critical_relu_covariance_aggregate.json').read_text());lam=np.array(cov['output_covariance_eigenvalues'])
X=2*((np.arange(M)[:,None]>>np.arange(r))&1)-1
U=2*((np.arange(K)[:,None]>>np.arange(r-1))&1)-1
base=np.column_stack([np.ones(K,dtype=int),U])
masks=np.arange(K);degrees=np.array([i.bit_count() for i in masks]);even_degrees=degrees+(degrees%2)
W=np.stack([np.prod(U[:,[i for i in range(r-1) if mask>>i&1]],axis=1) for mask in masks],axis=1)
fullmasks=(masks<<1)+(degrees%2)
WX=np.stack([np.prod(X[:,[i for i in range(r) if mask>>i&1]],axis=1) for mask in fullmasks],axis=1)
beta=np.array([15/16 if j==0 else 3/16 if j in (2,6) else -1/16 for j in even_degrees])
# The full-parity sign is positive at r=6; beta_0=(r-1)*beta_6.
shifts=np.array([0,1,2,4,8,16]);indices=shifts[:,None]^masks[None,:]
target_index=7;target=WX[:,target_index];assert fullmasks[target_index]==15
count_hist=np.zeros(129,dtype=np.int64);weight_hist=np.zeros(129);q_hist={};max_hist={}
total_weight=0.;weighted_mse=0.;sum_mse=0.;sufficient_count=0;sufficient_weight=0.;max_direct_error=0.
for first in range(0,len(patterns),4096):
 eps=2*((patterns[first:first+4096,None]>>np.arange(K,dtype=np.uint32))&1).astype(np.int64)-1
 eh=eps@W/K
 assert np.max(np.abs(eh[:,degrees>=4]))==0
 L=eh[:,indices]/(2*beta[None,None,:])
 A=np.eye(r)[None,:,:]+L@L.transpose(0,2,1)
 rhs=L[:,:,target_index];solution=np.linalg.solve(A,rhs[:,:,None])[:,:,0]
 ecoeff=-np.einsum('bir,bi->br',L,solution);ecoeff[:,target_index]+=1
 pred=ecoeff@WX.T+solution@X.T
 mse=np.mean((pred-target[None,:])**2,axis=1)
 assert np.max(np.abs(mse-np.sum(rhs*solution,axis=1)))<1e-10
 signed=pred*target[None,:]
 twice_errors=2*np.sum(signed < -1e-9,axis=1)+np.sum(np.abs(signed)<=1e-9,axis=1)
 B=np.eye(r)[None,:,:]+np.einsum('bik,k,bjk->bij',L,lam[even_degrees]/lam[1],L,optimize=True)
 sign,logdet=np.linalg.slogdet(B);assert np.all(sign>0);weights=np.exp(-.5*logdet)
 count_hist+=np.bincount(twice_errors,minlength=129)
 weight_hist+=np.bincount(twice_errors,weights=weights,minlength=129)
 q_l1=np.sum(np.abs(rhs),axis=1);sufficient=q_l1<1-1e-12
 sufficient_count+=int(sufficient.sum());sufficient_weight+=float(weights@sufficient)
 for v,c in zip(*np.unique(np.rint(16*q_l1).astype(int),return_counts=True)):q_hist[int(v)]=q_hist.get(int(v),0)+int(c)
 for v,c in zip(*np.unique(np.rint(32*np.max(np.abs(eh),axis=1)).astype(int),return_counts=True)):max_hist[int(v)]=max_hist.get(int(v),0)+int(c)
 total_weight+=float(weights.sum());weighted_mse+=float(weights@mse);sum_mse+=float(mse.sum())
 if first==0:
  for i in range(6):
   Z=eps[i,:,None]*base;H=np.maximum(Z@X.T,0).T/np.sqrt(r)
   direct=H@np.linalg.lstsq(H,target,rcond=None)[0]
   err=float(np.max(np.abs(direct-pred[i])));max_direct_error=max(max_direct_error,err);assert err<1e-10
 if first%65536==0:print(json.dumps(dict(processed=min(first+4096,len(patterns)),seconds=time.monotonic()-start)),flush=True)
result=dict(dimension=r,patterns=len(patterns),target='first four coordinates',
 pure_exceptional_population_projection_uniform_mean_mse=sum_mse/len(patterns),
 pure_exceptional_population_projection_posterior_weighted_mean_mse=weighted_mse/total_weight,
 classification_histogram=[dict(error=i/128,count=int(c),posterior_weighted_probability=float(weight_hist[i]/total_weight)) for i,c in enumerate(count_hist) if c],
 explicit_comparator_positive_margin_count=sufficient_count,explicit_comparator_positive_margin_posterior_probability=sufficient_weight/total_weight,
 comparator_l1_histogram=[dict(linear_l1=v/16,count=c) for v,c in sorted(q_hist.items())],
 maximum_walsh_histogram=[dict(maximum=v/32,count=c) for v,c in sorted(max_hist.items())],
 maximum_direct_least_squares_difference=max_direct_error,total_unnormalized_weight=total_weight,seconds=time.monotonic()-start,
 qualification='Exact orientation list; floating-point exhaustive projection and estimated posterior weights. This does not test the large-dimension theorem at its asymptotic threshold.')
(ROOT/'results/orientation_raw_transfer_d6.json').write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps({k:v for k,v in result.items() if not isinstance(v,list)}),flush=True)
