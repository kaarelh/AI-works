"""Sequential Gaussian conditioning as an independent importance cross-check.

At each observed coordinate, draw the independent Cholesky normal truncated
at its exact conditional threshold. The product of the one-dimensional tail
probabilities is the importance weight. This is the standard chain-rule
construction, not a new sampling theorem. It checks the Gaussian-limit
posterior only. Low ESS makes a result inconclusive; no mixing claim is made.
"""
import os
for key in ('OPENBLAS_NUM_THREADS','OMP_NUM_THREADS','VECLIB_MAXIMUM_THREADS'):os.environ[key]='1'
import argparse,datetime,json,math,time
from pathlib import Path
import numpy as np
from scipy.special import log_ndtr,ndtri_exp,ndtr
ROOT=Path(__file__).resolve().parents[1]

def cholesky(d,sigma):
    M=2**d;r=math.exp(-2*sigma*sigma);bits=np.array([x.bit_count() for x in range(M)])
    h=bits[np.arange(M)[:,None]^np.arange(M)]
    C=sigma*sigma/2*(-1.)**h*(r**h+r**(d-h+1))
    return np.linalg.cholesky(C)

def run(L,h,rng,samples,deadline,batch=1024):
    start=time.monotonic();n=0;scale=-np.inf;sums=np.zeros(8);maxw=0.
    while n<samples and datetime.datetime.now(datetime.timezone.utc)<deadline:
        count=min(batch,samples-n);z=np.empty((count,h));logw=np.zeros(count)
        for i in range(h):
            mean=z[:,:i]@L[i,:i] if i else np.zeros(count)
            threshold=(.5-mean)/L[i,i];lp=log_ndtr(-threshold)
            z[:,i]=-ndtri_exp(lp+np.log(rng.random(count)))
            logw+=lp
        mean=z@L[h,:h];pc=ndtr(mean/L[h,h]);newscale=max(scale,float(logw.max()))
        factor=math.exp(scale-newscale) if np.isfinite(scale) else 0.
        sums[:3]*=factor;sums[3:]*=factor*factor;maxw*=factor;scale=newscale
        w=np.exp(logw-scale);maxw=max(maxw,float(w.max()))
        sums+=np.array([w.sum(),(w*pc).sum(),(w*mean).sum(),(w*w).sum(),
            ((w*pc)**2).sum(),((w*mean)**2).sum(),(w*w*pc).sum(),(w*w*mean).sum()])
        n+=count
    if not n:return dict(observed=h,samples=0,status='deadline_partial')
    p=sums[1]/sums[0];mean=sums[2]/sums[0]
    pvar=max(0,sums[4]-2*p*sums[6]+p*p*sums[3])
    mvar=max(0,sums[5]-2*mean*sums[7]+mean*mean*sums[3])
    unresolved=p==0 or (p>0 and sums[4]==0)
    ess=sums[0]**2/sums[3]
    return dict(observed=h,samples=n,status='complete' if n==samples else 'deadline_partial',
        correct_probability=float(p),correct_probability_empirical_se=None if unresolved else math.sqrt(pvar)/sums[0],
        posterior_mean=float(mean),posterior_mean_empirical_se=math.sqrt(mvar)/sums[0],
        probability_or_second_moment_underflow=bool(unresolved),importance_ess=float(ess),
        largest_normalized_weight=float(maxw/sums[0]),log_history_probability=float(scale+math.log(sums[0]/n)),
        seconds=time.monotonic()-start,inconclusive_low_ess=bool(ess<100),
        scope='Independent sequential importance sampling of a Gaussian posterior; empirical errors are not certified coverage.')

def main():
    ap=argparse.ArgumentParser();ap.add_argument('--stop-utc',required=True);ap.add_argument('--seed',type=int,default=2026112302)
    ap.add_argument('--samples',type=int,default=2000000);ap.add_argument('--output',type=Path,default=ROOT/'results/cosine_gaussian_sequential.json');args=ap.parse_args()
    deadline=datetime.datetime.fromisoformat(args.stop_utc);assert deadline.tzinfo is not None
    jobs=[(3,s,list(range(1,8))) for s in [.5,1.,2.]]
    jobs += [(5,s,list(range(1,32))) for s in [.7,1.,2.]]
    jobs += [(7,s,[1,2,4,8,16,32,64,96,120,127]) for s in [.7,1.,2.]]
    jobs += [(9,s,[1,16,64,128,256,384,511]) for s in [1.,2.]]
    jobs += [(11,s,[1,128,512,1024,2047]) for s in [1.,2.]]
    rng=np.random.default_rng(args.seed);out=dict(status='in_progress',seed=args.seed,samples_per_history=args.samples,
        started_utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),planned_jobs=len(jobs),jobs=[],
        scope='Exploration of whether the proven cold lexicographic path stays wrong at fixed Gaussian scale. Numerical evidence is not a proof of that stronger assertion.')
    for d,s,counts in jobs:
        if datetime.datetime.now(datetime.timezone.utc)>=deadline:break
        L=cholesky(d,s);job=dict(dimension=d,sigma=s,requested_histories=counts,rows=[]);out['jobs'].append(job)
        for h in counts:
            if datetime.datetime.now(datetime.timezone.utc)>=deadline:break
            row=run(L,h,rng,args.samples,deadline);job['rows'].append(row)
            print(json.dumps(dict(dimension=d,sigma=s,**row)),flush=True)
            args.output.write_text(json.dumps(out,indent=2)+'\n')
    out['status']='complete' if len(out['jobs'])==len(jobs) and len(out['jobs'][-1]['rows'])==len(jobs[-1][2]) and out['jobs'][-1]['rows'][-1]['status']=='complete' else 'deadline_partial'
    out['finished_utc']=datetime.datetime.now(datetime.timezone.utc).isoformat();args.output.write_text(json.dumps(out,indent=2)+'\n')
if __name__=='__main__':main()
