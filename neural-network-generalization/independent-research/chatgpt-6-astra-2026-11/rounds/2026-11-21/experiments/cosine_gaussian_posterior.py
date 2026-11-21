"""Independent bounded-weight diagnostics for the actual truncated GP posterior.

For an active prefix, write its signed scores as a*1+s, s>=0. If W is
the marginal precision and lambda=a*W*1>0, independent Exp(lambda_i)
proposals have exact weight exp(-s'W*s/2)<=1. The next coordinate is
integrated analytically using its conditional normal distribution.
This is a Gaussian-limit experiment, not a finite-neural-width experiment.
High-precision covariance preparation reduces cancellation, but is not
interval certified. Monte Carlo ratio errors are empirical diagnostics.
"""
import os
for key in ('OPENBLAS_NUM_THREADS','OMP_NUM_THREADS','VECLIB_MAXIMUM_THREADS'):os.environ[key]='1'
import argparse,datetime,json,math,time
from pathlib import Path
import mpmath as mp
import numpy as np
from scipy.special import ndtr
ROOT=Path(__file__).resolve().parents[1]

def prepare(d,sigma,counts,digits=70):
    mp.mp.dps=digits;s=mp.mpf(str(sigma));r=mp.exp(-2*s*s);M=2**d;a=mp.mpf('.5')
    rad=[s*s/2*(-1)**h*(r**h+r**(d-h+1)) for h in range(d+1)]
    cov=mp.matrix([[rad[(i^j).bit_count()] for j in range(M)] for i in range(M)])
    chol=mp.cholesky(cov)
    # Forward triangular inversion, avoiding a generic dense inverse.
    inv=mp.matrix(M)
    for i in range(M):
        inv[i,i]=1/chol[i,i]
        for j in range(i):
            inv[i,j]=-mp.fsum(chol[i,k]*inv[k,j] for k in range(j,i))/chol[i,i]
    rows=[]
    for h in counts:
        row_sums=[mp.fsum(inv[i,j] for j in range(i+1)) for i in range(h)]
        lam=[a*mp.fsum(inv[i,j]*row_sums[i] for i in range(j,h)) for j in range(h)]
        assert min(lam)>0
        coeff=[-chol[h,h]*inv[h,j] for j in range(h)]
        mode=a*mp.fsum(coeff)
        assert mode<=-a*r/(1+r+r*r)+mp.mpf(10)**(-digits//2)
        rows.append(dict(observed=h,lambda_=np.array([float(x) for x in lam]),
            inverse_cholesky=np.array([[float(inv[i,j]) for j in range(h)] for i in range(h)]),
            mean_coefficients=np.array([float(x) for x in coeff]),sd=float(chol[h,h]),
            mode=float(mode),rho=float(r),minimum_multiplier=float(min(lam))))
    return rows

def sample(row,rng,samples,batch,deadline):
    h=row['observed'];sums=np.zeros(7);n=0;blocks=[];start=time.monotonic()
    while n<samples and datetime.datetime.now(datetime.timezone.utc)<deadline:
        k=min(batch,samples-n);slack=rng.exponential(size=(k,h))/row['lambda_']
        transformed=slack@row['inverse_cholesky'].T
        w=np.exp(-.5*np.sum(transformed*transformed,axis=1))
        means=row['mode']+slack@row['mean_coefficients']
        pc=ndtr(means/row['sd'])
        values=np.array([w.sum(),(w*pc).sum(),(w*means).sum(),(w*w).sum(),
                         ((w*pc)**2).sum(),((w*means)**2).sum(),(w*w*pc).sum()])
        sums+=values;n+=k;blocks.append([k,float(w.sum()),float((w*pc).sum()),float((w*means).sum())])
    total=sums[0]
    if total==0:return dict(observed=h,samples=n,status='no_effective_weight',mode=row['mode'])
    p=sums[1]/total;mean=sums[2]/total
    se=math.sqrt(max(0,sums[4]-2*p*sums[6]+p*p*sums[3]))/total
    unresolved_probability = p == 0 or (p > 0 and sums[4] == 0)
    if unresolved_probability:se=None
    # Block ratio jackknife for the posterior mean; acceptances may be tiny.
    blocks=np.array(blocks);valid=total>blocks[:,1]
    leave=(sums[2]-blocks[valid,3])/(total-blocks[valid,1])
    mean_se=math.sqrt((len(leave)-1)/len(leave)*np.sum((leave-leave.mean())**2)) if len(leave)>1 else None
    return dict(observed=h,samples=n,status='complete' if n==samples else 'deadline_partial',
        mode=row['mode'],correct_probability=float(p),correct_probability_empirical_se=se,
        probability_or_second_moment_underflow=bool(unresolved_probability),
        posterior_mean=float(mean),posterior_mean_block_jackknife_se=mean_se,
        exponential_proposal_acceptance=float(total/n),importance_ess=float(total*total/sums[3]),
        minimum_multiplier=row['minimum_multiplier'],conditional_sd=row['sd'],seconds=time.monotonic()-start,
        uncertainty_scope='Independent bounded importance-ratio diagnostics; not interval arithmetic or certified probability coverage.')

def main():
    ap=argparse.ArgumentParser();ap.add_argument('--stop-utc',required=True);ap.add_argument('--seed',type=int,default=2026112301)
    ap.add_argument('--output',type=Path,default=ROOT/'results/cosine_gaussian_posterior.json');args=ap.parse_args()
    deadline=datetime.datetime.fromisoformat(args.stop_utc);assert deadline.tzinfo is not None
    jobs=[(3,s,list(range(1,8)),300000) for s in [.2,.35,.5,1.]]
    jobs += [(5,s,list(range(1,32)),200000) for s in [.2,.3,.4]]
    jobs += [(7,s,[1,2,4,8,16,32,64,96,120,127],500000) for s in [.2,.3]]
    jobs += [(9,.3,[1,16,64,128,256,384,511],1000000)]
    rng=np.random.default_rng(args.seed);result=dict(status='in_progress',seed=args.seed,started_utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),
        scope='Actual truncated Gaussian-process posterior, with only observed positive margins. No finite-neural-width posterior is sampled.',jobs=[])
    for d,sigma,counts,samples in jobs:
        if datetime.datetime.now(datetime.timezone.utc)>=deadline:break
        start=time.monotonic();prepared=prepare(d,sigma,counts);setup=time.monotonic()-start
        rows=[];job=dict(dimension=d,sigma=sigma,requested_histories=counts,samples_per_history=samples,setup_seconds=setup,rows=rows)
        result['jobs'].append(job)
        for row in prepared:
            if datetime.datetime.now(datetime.timezone.utc)>=deadline:break
            out=sample(row,rng,samples,1024,deadline);rows.append(out)
            print(json.dumps(dict(dimension=d,sigma=sigma,**out)),flush=True)
            args.output.write_text(json.dumps(result,indent=2)+'\n')
    result['status']='complete' if len(result['jobs'])==len(jobs) and len(result['jobs'][-1]['rows'])==len(jobs[-1][2]) else 'deadline_partial'
    result['finished_utc']=datetime.datetime.now(datetime.timezone.utc).isoformat();args.output.write_text(json.dumps(result,indent=2)+'\n')
if __name__=='__main__':main()
