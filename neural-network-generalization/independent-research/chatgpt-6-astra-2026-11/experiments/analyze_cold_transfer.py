"""Recompute saved posterior observables and fit fresh Gaussian readouts.

This script only consumes completed chains. It is safe to rerun as more
chains finish. The posterior MCMC has no mixing certificate; readout fits
are deterministic linear algebra conditional on each saved feature map.
"""
import os
for key in ('OPENBLAS_NUM_THREADS','OMP_NUM_THREADS','VECLIB_MAXIMUM_THREADS'):
    os.environ.setdefault(key,'1')
import json, math, subprocess
from pathlib import Path
import numpy as np
from scipy.linalg import cho_factor, cho_solve

ROOT=Path(__file__).resolve().parents[1]
CAM=ROOT/'results/cold_transfer';OUT=ROOT/'results/cold_transfer_readouts';OUT.mkdir(exist_ok=True)
samples=(16,32,64,128,256,512,1024,2048,8192)
replicates=4
completed=[json.loads(x)['name'] for x in (CAM/'job_status.jsonl').read_text().splitlines()
           if json.loads(x)['status']=='complete']

def readout(K, target, counts):
    ids=np.flatnonzero(counts);root=np.sqrt(counts[ids])
    gram=K[np.ix_(ids,ids)]*root[:,None]*root[None,:]
    gram.flat[::len(ids)+1]+=1.
    alpha=root*cho_solve(cho_factor(gram,lower=True,check_finite=False),root*target[ids],check_finite=False)
    prediction=K[:,ids]@alpha
    norm=float(alpha@K[np.ix_(ids,ids)]@alpha)
    assert norm<=counts.sum()+1e-6*max(1,counts.sum())
    return dict(mse=float(np.mean((prediction-target)**2)),
                classification_error=float(np.mean(prediction*target<=0)),norm_squared=norm)

for name in completed:
    destination=OUT/(name+'.json')
    logs=[json.loads(x) for x in (CAM/(name+'.jsonl')).read_text().splitlines()]
    first=logs[0];r=first['dimension'];N=first['width'];M=2**r
    snapshot_indices=(0,50,150,300)
    compact=CAM/(name+'.snapshots.npz')
    if compact.exists():
        saved=np.load(compact)
        data={int(i):theta for i,theta in zip(saved['record_indices'],saved['theta'])}
        counts=saved['training_counts']
    else:
        raw=np.memmap(CAM/(name+'.jsonl.theta'),dtype='<f8',mode='r').reshape(-1,N,r+2)
        assert len(raw)==len(logs)
        data={i:np.array(raw[i]) for i in snapshot_indices}
        counts=np.array(json.loads(subprocess.check_output([str(ROOT/'tools/iid_cube_indices'),str(M),
            str(first['training_draws']),str(first['data_seed'])],text=True)))
        np.savez_compressed(compact,record_indices=np.array(snapshot_indices),
            theta=np.stack([data[i] for i in snapshot_indices]),training_counts=counts)
    if destination.exists():continue
    X=2*((np.arange(M)[:,None]>>np.arange(r))&1)-1
    source=np.prod(X,axis=1);near=np.prod(X[:,2:],axis=1)
    targets={'near_degree6':near,'middle_degree4':np.prod(X[:,4:],axis=1),
             'low_degree2':np.prod(X[:,:2],axis=1)}
    assert r==8,'Target labels below assume eight dimensions'
    assert np.count_nonzero(counts)==first['distinct_observations']
    records=[]
    for record_index in snapshot_indices:
        row=logs[record_index];theta=np.asarray(data[record_index]);a=theta[:,0];U=theta[:,1:]
        H=np.maximum(U[:,0,None]+U[:,1:]@X.T,0).T
        F=H@a/N;He=(H+H[::-1])/2
        energy=float(np.sum(theta*theta)/(2*N))
        source_quad=float(np.sum((source@H/M)**2)/N)
        near_quad=float(np.sum((near@H/M)**2)/N)
        q=-5/.5*(He@(a*np.prod(np.where(U[:,1:3]>=0,1.,-1.),axis=1)))/N
        values=dict(physical_energy=energy,parity_kernel=source_quad,nearby_parity_kernel=near_quad,
            min_margin=float(np.min((source*F)[counts>0])),uniform_error=float(np.mean(source*F<=0)),
            uniform_hinge=float(np.mean(np.maximum(.5-source*F,0))),
            transfer_comparator_l2=float(np.sqrt(np.mean((q-near)**2))),
            transfer_comparator_error=float(np.mean(q*near<=0)),
            transfer_comparator_hinge=float(np.mean(np.maximum(1-q*near,0))))
        errors={key:abs(value-row[key]) for key,value in values.items()}
        assert max(errors.values())<2e-8,(name,record_index,errors)
        assert values['min_margin']>=.5-1e-8
        rng=np.random.default_rng(2026111809+record_index)
        # Reuse each IID stream across kernels and targets.
        streams=[rng.integers(M,size=max(samples)) for _ in range(replicates)]
        trial_counts={n:[np.bincount(stream[:n],minlength=M) for stream in streams] for n in samples}
        fits=[];kernels={}
        for kind,features in (('raw',H),('even',He)):
            K=features@features.T/N
            kernels[kind]=dict(trace=float(np.trace(K)/M),radius_squared=float(np.max(np.diag(K))),
                target_quadratics={key:float(target@K@target/M**2) for key,target in targets.items()})
            for target_name,target in targets.items():
                for n in samples:
                    for replicate,c in enumerate(trial_counts[n]):
                        fits.append(dict(kernel=kind,target=target_name,n=n,replicate=replicate,
                                         **readout(K,target,c)))
        records.append(dict(sweep=row['sweep'],observables=values,maximum_recomputation_error=max(errors.values()),
                            kernel_diagnostics=kernels,readout_trials=fits))
    destination.write_text(json.dumps(dict(name=name,dimension=r,width=N,readout_prior_variance=1,
        readout_noise_variance=1,records=records,qualification='MCMC states without a mixing certificate; conditional exact Gaussian-readout formula.'),indent=2)+'\n')
    print(json.dumps(dict(name=name,status='PASS',snapshots=len(records),trials=sum(len(z['readout_trials']) for z in records))),flush=True)
