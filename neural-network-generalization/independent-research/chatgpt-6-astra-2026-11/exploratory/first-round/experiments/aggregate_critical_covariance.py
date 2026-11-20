import os
for k in ['OPENBLAS_NUM_THREADS','OMP_NUM_THREADS','VECLIB_MAXIMUM_THREADS']:os.environ[k]='1'
import numpy as np,json,math
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1];r=6;files=[ROOT/f'results/critical_relu_covariance_d6_seed{i}_moments.npz' for i in [1,2,3,4]];arr=[np.load(p) for p in files];n=sum(int(a['n']) for a in arr);ss=sum(a['sum'] for a in arr);ss2=sum(a['sum_outer'] for a in arr);mean=ss/n;cov=ss2/n-np.outer(mean,mean);ratio=mean/mean[0];se=[]
for k in range(len(mean)):
 if k==0:se.append(math.sqrt(cov[0,0]/n))
 else:se.append(math.sqrt(max(0,cov[k,k]+ratio[k]**2*cov[0,0]-2*ratio[k]*cov[k,0])/n)/mean[0])
rho=math.comb(r-2,(r-2)//2)/(2**(r-1)*math.sqrt(r));row=dict(dimension=r,proposals=n,seeds=4,rho=rho,normalizer=float(mean[0]),normalizer_se=se[0],mc=float(ratio[1]),mc_se=se[1],readout_energy=float(ratio[2]),readout_energy_se=se[2],incoming_energy=float(ratio[3]),incoming_energy_se=se[3],kernel_eigenvalues=ratio[4:5+r].tolist(),kernel_se=se[4:5+r],output_second_moments=ratio[5+r:].tolist(),output_second_se=se[5+r:],output_covariance_eigenvalues=(64*(ratio[5+r:]-np.eye(1,r+1,r)[0]*ratio[1]**2)).tolist(),sources=[str(p.relative_to(ROOT)) for p in files]);(ROOT/'results/critical_relu_covariance_aggregate.json').write_text(json.dumps(row)+'\n');print(json.dumps(row,indent=2))
