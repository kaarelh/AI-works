"""Long fixed-width independent-proposal run with an absolute stop time."""
import os
for key in ('OPENBLAS_NUM_THREADS','OMP_NUM_THREADS','VECLIB_MAXIMUM_THREADS'):os.environ[key]='1'
import argparse,datetime,json,math,time
from pathlib import Path
import numpy as np
import full_label_independent as f

def constants(rows,n):
    lw=np.array([row['logweight'] for row in rows if row['accepted']])
    if len(lw)<3:return {}
    weights=np.exp(lw-lw.max());weights/=weights.mean()
    L=np.sort(math.sqrt(n)*(weights-1));count=len(L)
    sums=np.r_[0.,np.cumsum(L)[:-1]];squares=np.r_[0.,np.cumsum(L*L)[:-1]]
    g=(L*L*np.arange(count)-2*L*sums+squares)/count-np.mean(L*L)
    return dict(empirical_C0=float(np.mean(abs(L))/2),empirical_C1=float(np.mean(abs(g))/2),
                scaled_weight_variance=float(np.mean(L*L)),maximum_scaled_weight=float(L[-1]))

def main():
    ap=argparse.ArgumentParser();ap.add_argument('--width',type=int,default=16777216)
    ap.add_argument('--loss',choices=['square','logistic'],required=True);ap.add_argument('--seed',type=int,required=True)
    ap.add_argument('--proposals',type=int,default=10000);ap.add_argument('--stop-utc',required=True);ap.add_argument('--output',type=Path,required=True)
    args=ap.parse_args();stop=datetime.datetime.fromisoformat(args.stop_utc).timestamp()
    rng=np.random.default_rng(args.seed);table=f.geometry_table();rows=[];start=time.monotonic()
    args.output.parent.mkdir(parents=True,exist_ok=True)
    with args.output.with_suffix('.jsonl').open('w',buffering=1) as stream:
        while len(rows)<args.proposals and time.time()<stop:
            row=f.proposal(rng,args.width,.5,args.loss,table);rows.append(row);stream.write(json.dumps(row)+'\n')
            if len(rows)%25==0:
                result=f.summarize(rows,args.width,.5,args.loss,args.seed,time.monotonic()-start)
                result.update(constants(rows,args.width));result['status']='in_progress';result['stop_utc']=args.stop_utc
                args.output.write_text(json.dumps(result,indent=2)+'\n')
                print(json.dumps({k:result.get(k) for k in ['width','loss','proposals','accepted','seconds','empirical_C0','empirical_C1']}),flush=True)
    result=f.summarize(rows,args.width,.5,args.loss,args.seed,time.monotonic()-start)
    result.update(constants(rows,args.width));result['status']='complete' if len(rows)==args.proposals else 'time_limit'
    result['stop_utc']=args.stop_utc;args.output.write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps({k:result.get(k) for k in ['status','width','loss','proposals','accepted','seconds','empirical_C0','empirical_C1']}),flush=True)
if __name__=='__main__':main()
