"""Critical mean boundary coefficient; non-interval importance Monte Carlo."""
import argparse,json,math,time
from pathlib import Path
import numpy as np
from critical_normalizer_smoothing import batch
import full_label_independent as f

def main():
 ap=argparse.ArgumentParser();ap.add_argument('--blocks',type=int,default=2400);ap.add_argument('--batch',type=int,default=16384)
 ap.add_argument('--shape',type=float,default=1.);ap.add_argument('--seed',type=int,required=True);ap.add_argument('--output',type=Path,required=True)
 args=ap.parse_args();assert 0<args.shape<2,'Finite-variance mean-coefficient proposal requires shape below two.'
 ref=json.loads((f.ROOT/'results/critical_moments_reference.json').read_text());rng=np.random.default_rng(args.seed);vals=[];start=time.monotonic()
 for i in range(args.blocks):
  vals.append(batch(rng,args.batch,args.shape,True))
  if (i+1)%100==0 or i+1==args.blocks:
   arr=np.array(vals);mu=arr.mean(0);se=arr.std(0,ddof=1)/math.sqrt(len(arr));mc=ref['critical_mean'] if 'critical_mean' in ref else ref['mc']
   normalized=(arr[:,1]-mc*arr[:,0])/ref['Mstar']
   out=dict(status='complete' if i+1==args.blocks else 'in_progress',samples=len(vals)*args.batch,seed=args.seed,shape=args.shape,
       seconds=time.monotonic()-start,normalizer_beta2_coefficient=float(mu[0]),mean_numerator_beta2_coefficient=float(mu[1]),
       block_standard_errors=se.tolist(),normalized_mean_beta2_coefficient=float(normalized.mean()),
       normalized_mean_conditional_se=float(normalized.std(ddof=1)/math.sqrt(len(normalized))),
       scope='Boundary-integral Monte Carlo. Normalized mean uncertainty conditions on separately estimated ReLU moments; not an interval enclosure.')
   args.output.write_text(json.dumps(out,indent=2)+'\n');print(json.dumps(out),flush=True)
 np.savez_compressed(args.output.with_suffix('.npz'),block_means=np.array(vals))
if __name__=='__main__':main()
