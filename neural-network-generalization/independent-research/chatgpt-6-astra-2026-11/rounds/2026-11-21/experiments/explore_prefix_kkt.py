"""Search the unresolved positive-margin prefix KKT conjecture.

This is not a proof checker for a claimed theorem. It searches positive
increasing radial spectra and records the smallest normalized interpolation
multiplier. Floating-point negatives must be independently verified before
being called counterexamples. The recursive inverse formula is cross-checked
against direct finite matrix solves first.
"""
import os
for key in ('OPENBLAS_NUM_THREADS','OMP_NUM_THREADS','VECLIB_MAXIMUM_THREADS'):os.environ[key]='1'
import argparse,datetime,json,math,time
from pathlib import Path
import numpy as np
ROOT=Path(__file__).resolve().parents[1]

def fwht(v):
    a=np.asarray(v,dtype=float).copy();size=1
    while size<len(a):
        b=a.reshape(-1,2*size);left=b[:,:size].copy();right=b[:,size:].copy()
        b[:,:size]=left+right;b[:,size:]=left-right;size*=2
    return a

COUNTS={n:np.array([j.bit_count() for j in range(2**n)]) for n in range(13)}
def dual(mu,h):
    n=len(mu)-1;M=2**n
    if not h:return np.empty(0)
    if h==M:return np.full(M,1/mu[0])
    half=M//2;a=(mu[:-1]+mu[1:])/2
    if h<=half:return dual(a,h)
    r=(mu[:-1]-mu[1:])/(mu[:-1]+mu[1:]);s=2*mu[:-1]*mu[1:]/(mu[:-1]+mu[1:])
    second=(1-r[0])*dual(s,h-half);padded=np.zeros(half);padded[:h-half]=second
    first=1/a[0]-fwht(fwht(padded)*r[COUNTS[n-1]])/half
    return np.r_[first,second]

def crosscheck(rng):
    err=0.
    for d in range(2,7):
        M=2**d;W=np.array([[(-1)**((i&j).bit_count()) for j in range(M)] for i in range(M)])
        for _ in range(10):
            mu=np.exp(np.r_[0,np.cumsum(rng.uniform(0,1,d))]);C=(W*mu[COUNTS[d]])@W.T/M
            h=int(rng.integers(1,M));a=dual(mu,h);b=np.linalg.solve(C[:h,:h],np.ones(h))
            err=max(err,float(np.max(abs(a-b))/np.max(abs(b))))
    assert err<1e-9,err
    return err

def main():
    ap=argparse.ArgumentParser();ap.add_argument('--stop-utc',required=True);ap.add_argument('--seed',type=int,default=2026112402);ap.add_argument('--trials',type=int,default=1000000);args=ap.parse_args()
    deadline=datetime.datetime.fromisoformat(args.stop_utc);assert deadline.tzinfo is not None
    rng=np.random.default_rng(args.seed);start=time.monotonic();err=crosscheck(rng)
    worst=None;candidate=[];counts={str(d):0 for d in range(3,13)};n=0;roundoff=0
    out=dict(status='in_progress',seed=args.seed,scope=__doc__.strip(),crosscheck_max_relative_error=err,
        started_utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),stop_utc=args.stop_utc)
    path=ROOT/'results/prefix_kkt_exploration.json'
    while n<args.trials and datetime.datetime.now(datetime.timezone.utc)<deadline:
        d=int(rng.integers(3,13));gaps=rng.exponential(1,d)
        if n%3==0:gaps[rng.random(d)<.65]=0
        gaps*=rng.uniform(.1,28)/max(gaps.sum(),1e-15);mu=np.exp(np.r_[0,np.cumsum(gaps)])
        h=int(rng.integers(1,2**d));v=dual(mu,h);ratio=float(v.min()/np.max(abs(v)))
        row=dict(dimension=d,prefix=h,spectrum=mu.tolist(),minimum_normalized_multiplier=ratio,
                 index=int(v.argmin()),trial=n)
        if worst is None or ratio<worst['minimum_normalized_multiplier']:worst=row
        if ratio<0:roundoff+=1
        if ratio < -1e-7:candidate.append(row)
        n+=1;counts[str(d)]+=1
        if n%1000==0 or candidate:
            out.update(trials=n,counts=counts,worst=worst,negative_float_rows=roundoff,candidate_counterexamples=candidate,seconds=time.monotonic()-start)
            path.write_text(json.dumps(out,indent=2)+'\n')
        if candidate:break
    out.update(status='candidate_requires_verification' if candidate else ('complete' if n==args.trials else 'deadline_partial'),trials=n,counts=counts,worst=worst,negative_float_rows=roundoff,candidate_counterexamples=candidate,seconds=time.monotonic()-start,finished_utc=datetime.datetime.now(datetime.timezone.utc).isoformat())
    path.write_text(json.dumps(out,indent=2)+'\n');print(json.dumps({k:out[k] for k in ['status','trials','negative_float_rows','candidate_counterexamples','seconds']}),flush=True)
if __name__=='__main__':main()
