import os
for key in ['OPENBLAS_NUM_THREADS','OMP_NUM_THREADS','VECLIB_MAXIMUM_THREADS']:
    os.environ[key]='1'
from pathlib import Path
import json
from functools import lru_cache
import numpy as np

ROOT=Path(__file__).resolve().parents[1]
files=[ROOT/f'results/critical_relu_fluctuations_d6_seed{i}_moments.npz' for i in [1,2,3,4]]
arrays=[np.load(p) for p in files]
n=sum(int(a['n']) for a in arrays)
total=sum(a['sum'] for a in arrays)
mean=total/n
ratio=mean/mean[0]
names=arrays[0]['names'].tolist()
moments=dict(zip(names,ratio.tolist()))
critical=json.loads((ROOT/'results/critical_relu_covariance_aggregate.json').read_text())
r=6;M=64;K=32;rho=critical['rho'];mc=critical['mc'];alpha=(.5-mc)/(K*rho)
cube=np.array([[1 if x>>i&1 else -1 for i in range(r)] for x in range(M)])
walsh=np.column_stack([np.prod(cube[:,[i for i in range(r) if t>>i&1]],axis=1) for t in range(M)])
even=[t for t in range(M) if t.bit_count()%2==0]
rows=[(E,i) for i in range(r) for E in even]
v=np.array([critical['output_covariance_eigenvalues'][t.bit_count()]/M for t in range(M)])
C=np.zeros((len(rows),M))
for j,(E,i) in enumerate(rows):
    T=(M-1)^E^(1<<i)
    C[j,T]=moments[f'mixed_{E.bit_count()}_{(E>>i)&1}']
residual_trace=moments['cross_kernel_second_trace']-np.sum(C*C/v[None,:])
canonical=cube[1::2]

@lru_cache(maxsize=None)
def predict(mask):
    eps=np.array([1 if mask>>j&1 else -1 for j in range(K)])
    z=canonical*eps[:,None]
    H=np.maximum(cube@z.T/np.sqrt(r),0)
    hats=walsh.T@H/M
    A=hats*np.prod(z,axis=1)[None,:]
    B=np.array([hats[E]*hats[1<<i] for E,i in rows])
    precision=A.T@(A/v[:,None])
    D=B-C@(A/v[:,None])
    factor=np.linalg.cholesky(precision)
    projected=np.linalg.solve(factor,D.T)
    amplitude=float(np.sum(projected*projected))
    gauge=float(alpha*np.sum(B*B))
    trace=residual_trace+amplitude+gauge
    weight=float(np.exp(-np.log(np.diag(factor)).sum()))
    return dict(trace=trace,ordinary=residual_trace,amplitude=amplitude,gauge=gauge,weight=weight)

rng=np.random.default_rng(718)
patterns=np.fromfile(ROOT/'results/relu_balanced_orientations_d6.bin',dtype=np.uint32)
sample=rng.choice(patterns,size=10000,replace=False)
pp=[predict(int(mask)) for mask in sample]
ww=np.array([p['weight'] for p in pp]);ww/=ww.sum()
limiting={key:float(np.dot(ww,[p[key] for p in pp])) for key in ['trace','ordinary','amplitude','gauge']}
runs=[]
for path in sorted((ROOT/'results/parity_relu_orientation').glob('d*.jsonl')):
    data=[json.loads(line) for line in path.read_text().splitlines() if line.strip()]
    if not data or data[-1]['sweep']<10000:
        continue
    last=data[-1]
    kept=[a for a in data if a['sweep']>last['sweep']//2 and 'cross_residual_norm_squared' in a]
    if not kept:
        continue
    width=last['width']
    empirical=width*np.array([a['cross_residual_norm_squared'] for a in kept])
    predicted=np.array([predict(int(a['orientation_mask']))['trace'] for a in kept])
    projection=2*width*np.array([a['cross_residual_projection'] for a in kept])
    def stats(values):
        blocks=np.array([b.mean() for b in np.array_split(values,20)])
        return dict(mean=float(values.mean()),block_se=float(blocks.std(ddof=1)/np.sqrt(20)))
    runs.append(dict(width=width,seed=last['seed'],sweeps=last['sweep'],records=len(kept),
                     scaled_residual=stats(empirical),predicted_trace=stats(predicted),
                     centered_difference=stats(empirical-predicted),scaled_projection=stats(projection)))
out=dict(status='distributional CLT covariance prediction; finite-width moment convergence not proved',
         proposals=n,mixed_moments=moments,limiting_weighted_trace=limiting,
         orientation_sample=10000,runs=runs)
(ROOT/'results/kernel_fluctuations_analysis.json').write_text(json.dumps(out,indent=2))
print(json.dumps(out,indent=2))
