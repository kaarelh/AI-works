"""Positive third-order normalizer coefficient from the boundary formula.

Block Monte Carlo standard errors are empirical, not interval enclosures.
"""
import argparse,json,time
from pathlib import Path
import critical_normalizer_smoothing as source
import numpy as np

def main():
    ap=argparse.ArgumentParser()
    ap.add_argument('--blocks',type=int,default=2400)
    ap.add_argument('--batch',type=int,default=16384)
    ap.add_argument('--shape',type=float,default=1.)
    ap.add_argument('--seed',type=int,default=2026112292)
    ap.add_argument('--output',type=Path,required=True)
    args=ap.parse_args();rng=np.random.default_rng(args.seed)
    values=[];start=time.monotonic()
    for i in range(args.blocks):
        values.append(source.batch(rng,args.batch,args.shape,include_third=True))
        if (i+1)%100==0 or i+1==args.blocks:
            v=np.array(values);means=v.mean(0);se=v.std(0,ddof=1)/np.sqrt(len(v))
            record=dict(status='complete' if i+1==args.blocks else 'in_progress',
                samples=len(v)*args.batch,seed=args.seed,shape=args.shape,seconds=time.monotonic()-start,
                normalizer_beta2_coefficient=float(means[0]),normalizer_beta3_coefficient=float(means[1]),
                block_standard_errors=se.tolist(),
                scope='Boundary-integral Monte Carlo. Signs are proved analytically in the paper; decimal coefficients and standard errors are not certified enclosures.')
            args.output.write_text(json.dumps(record,indent=2)+'\n')
            print(json.dumps(record),flush=True)
    np.savez_compressed(args.output.with_suffix('.npz'),block_means=np.array(values))

if __name__=='__main__':main()
