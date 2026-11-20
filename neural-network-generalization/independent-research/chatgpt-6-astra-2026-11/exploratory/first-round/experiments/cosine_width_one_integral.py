"""Integrate phase exactly for the width-one sign-only cosine posterior.

Only d-dimensional Gaussian incoming weights remain. Independently scrambled
Sobol rules provide an external numerical check for the neural SMC sampler.
Readout sign is absorbed into the uniform phase; its magnitude is irrelevant.
"""
import argparse,itertools,json,math,time
from pathlib import Path
import numpy as np
from scipy.special import ndtri
from scipy.stats import qmc
ROOT=Path(__file__).resolve().parents[1]
ap=argparse.ArgumentParser();ap.add_argument('--d',type=int,default=4)
ap.add_argument('--sigma',type=float,default=math.sqrt(math.log(2)/2))
ap.add_argument('--power',type=int,default=22);ap.add_argument('--replicates',type=int,default=8)
args=ap.parse_args();d=args.d;X=np.array(list(itertools.product([1.,-1.],repeat=d)))
y=np.prod(X,axis=1);M=len(X);start=time.time();rows=[]
for seed in range(args.replicates):
 sob=qmc.Sobol(d,scramble=True,seed=seed);tot=np.zeros(M);tot2=np.zeros(M)
 batchpower=min(args.power,16)
 for j in range(2**(args.power-batchpower)):
  w=ndtri(sob.random(2**batchpower))*args.sigma
  centers=-w@(X-X[0]).T+np.pi*(y<0)
  centers=(centers+np.pi)%(2*np.pi)-np.pi
  lengths=np.maximum(0,np.pi-(np.maximum.accumulate(centers,axis=1)-np.minimum.accumulate(centers,axis=1)))
  probs=lengths/(2*np.pi);tot+=probs.sum(axis=0);tot2+=(probs*probs).sum(axis=0)
 z=tot/2**args.power;pred=z/np.r_[1.,z[:-1]]
 row=dict(d=d,sigma=args.sigma,power=args.power,seed=seed,evidence=z.tolist(),
          correct_probabilities=pred.tolist(),expected_mistakes=float(np.sum(1-pred)),seconds=time.time()-start)
 rows.append(row);print(json.dumps(row),flush=True)
(ROOT/'results'/f'cosine_width_one_d{d}_p{args.power}.json').write_text(json.dumps(rows,indent=2)+'\n')
