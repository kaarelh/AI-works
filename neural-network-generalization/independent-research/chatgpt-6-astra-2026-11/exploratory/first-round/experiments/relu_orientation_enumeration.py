"""Exhaustive r=6 balanced orientation enumeration; covariance input is numerical.
Exact integer enumeration count; determinant weights are floating-point estimates.
"""
import os
for k in ['OPENBLAS_NUM_THREADS','OMP_NUM_THREADS','VECLIB_MAXIMUM_THREADS']:os.environ[k]='1'
from pathlib import Path
from itertools import combinations
from collections import defaultdict
import numpy as np,json,argparse,time
from critical_relu_covariance import fwht
ROOT=Path(__file__).resolve().parents[1]
def enumerate_patterns(covariance_file,output):
 info=json.loads(Path(covariance_file).read_text().splitlines()[-1]);lam=np.array(info['output_covariance_eigenvalues']);rho=info['rho'];mc=info['mc'];r=6;K=32
 X4=np.array([[1 if i>>j&1 else -1 for j in range(4)]for i in range(16)],dtype=np.int8)
 groups=defaultdict(list)
 for pos in combinations(range(16),8):
  g=-np.ones(16,dtype=np.int8);g[list(pos)]=1;groups[tuple((g@X4).tolist())].append(g)
 count=sum(len(v)*len(groups[tuple(-x for x in key)]) for key,v in groups.items());print('exact_count',count,'groups',len(groups),flush=True)
 X5=np.array([[1 if i>>j&1 else -1 for j in range(5)]for i in range(32)],dtype=np.int8);chi5=X5.prod(1);Z=np.c_[np.ones(32),X5].T;degrees=np.array([i.bit_count() for i in range(32)]);even_degree=2*((degrees+1)//2)
 X6=np.array([[1 if i>>j&1 else -1 for j in range(6)]for i in range(64)]);base=fwht(np.maximum(X6.sum(1),0)[None,:]/np.sqrt(6))[0];hat=np.array([base[(1<<k)-1] for k in even_degree]);D=lam[even_degree]/hat**2
 stats=dict(count=0,weight=0.,weight2=0.,min_weight=np.inf,max_weight=0.,hemisphere_weight=0.,hemisphere_count=0,degree_count=[0]*4,degree_weight=[0.]*4,degree_spectrum_weight=np.zeros(6),cross_norm_squared_weight=0.)
 best=[];worst=[];start=time.time()
 for key,arr in groups.items():
  left=np.array(arr);right=np.array(groups[tuple(-x for x in key)])
  for i in range(len(left)):
   g=np.c_[np.repeat(left[i:i+1],len(right),axis=0),right];eps=g*chi5
   assert np.all(g.sum(1)==0) and np.all(g@X5==0)
   F=fwht((eps[:,None,:]*Z[None,:,:]).reshape(-1,32)).reshape(-1,6,32)
   B=np.einsum('bia,a,bja->bij',F,D,F,optimize=True)/(24*lam[1]);B+=np.eye(6)[None,:,:]
   sg,logdet=np.linalg.slogdet(B);assert np.all(sg>0);weight=np.exp(-.5*logdet)
   eh=fwht(eps);spectrum=np.column_stack([np.sum(eh[:,degrees==j]**2,axis=1) for j in range(6)]);assert np.max(spectrum[:,4:])==0
   degree=np.max(np.where(spectrum[:,:4]>0,np.arange(4),0),axis=1);hemi=(spectrum[:,0]+spectrum[:,1])==1
   # Boolean degree <=1 consists exactly of constants and signed coordinates.
   cross=(.5-mc)**2/(24*rho*rho)*np.einsum('bia,a->b',F*F,hat*hat)
   stats['count']+=len(weight);stats['weight']+=weight.sum();stats['weight2']+=(weight*weight).sum();stats['min_weight']=min(stats['min_weight'],weight.min());stats['max_weight']=max(stats['max_weight'],weight.max());stats['hemisphere_weight']+=weight[hemi].sum();stats['hemisphere_count']+=hemi.sum();stats['degree_spectrum_weight']+=weight@spectrum;stats['cross_norm_squared_weight']+=weight@cross
   for j in range(4):stats['degree_count'][j]+=int(np.sum(degree==j));stats['degree_weight'][j]+=weight[degree==j].sum()
   for loc in [np.argmin(weight),np.argmax(weight)]:
    item=dict(weight=float(weight[loc]),eps=eps[loc].tolist(),spectrum=spectrum[loc].tolist(),cross_norm_squared=float(cross[loc]));best.append(item);worst.append(item)
   best=sorted(best,key=lambda a:-a['weight'])[:8];worst=sorted(worst,key=lambda a:a['weight'])[:8]
 result=dict(covariance_source=str(covariance_file),exact_count=int(count),enumerated=int(stats['count']),groups=len(groups),total_weight=float(stats['weight']),min_weight=float(stats['min_weight']),max_weight=float(stats['max_weight']),hemisphere_count=int(stats['hemisphere_count']),hemisphere_probability=float(stats['hemisphere_weight']/stats['weight']),uniform_hemisphere_probability=float(stats['hemisphere_count']/count),degree_counts=stats['degree_count'],degree_probabilities=(np.array(stats['degree_weight'])/stats['weight']).tolist(),mean_degree_spectrum=(stats['degree_spectrum_weight']/stats['weight']).tolist(),mean_cross_norm_squared=float(stats['cross_norm_squared_weight']/stats['weight']),effective_patterns=float(stats['weight']**2/stats['weight2']),best=best,worst=worst,seconds=time.time()-start)
 Path(output).write_text(json.dumps(result,indent=2));print(json.dumps({k:v for k,v in result.items() if k not in ['best','worst']}),flush=True)
if __name__=='__main__':
 ap=argparse.ArgumentParser();ap.add_argument('--covariance',default=str(ROOT/'results/critical_relu_covariance_d6_seed0.jsonl'));ap.add_argument('--output',default=str(ROOT/'results/relu_orientation_enumeration.json'));a=ap.parse_args();enumerate_patterns(a.covariance,a.output)
