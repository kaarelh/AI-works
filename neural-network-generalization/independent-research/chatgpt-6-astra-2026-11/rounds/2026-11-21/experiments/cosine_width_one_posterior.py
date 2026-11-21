"""Independent importance integration of the actual width-one cosine posterior.

The Gaussian readout is integrated analytically. Incoming weights are sampled
from their stated Gaussian prior, and reweighted by the exact positive-margin
history probability. Low ESS is explicitly inconclusive. This is not MCMC and
not a Gaussian-process posterior. Empirical errors are not certified coverage.
"""
import os
for k in ('OPENBLAS_NUM_THREADS','OMP_NUM_THREADS','VECLIB_MAXIMUM_THREADS'):os.environ[k]='1'
import argparse,datetime,itertools,json,math,time
from pathlib import Path
import numpy as np
from scipy.special import log_ndtr
ROOT=Path(__file__).resolve().parents[1]

def run(d,sigma,samples,seed,stop,save):
    X=np.array(list(itertools.product((1.,-1.),repeat=d)));chi=np.prod(X,axis=1);M=len(X)
    rng=np.random.default_rng(seed);maximum=np.full(M-1,-np.inf)
    sw=np.zeros(M-1);sw2=sw.copy();sc=sw.copy();sc2=sw.copy();sm=sw.copy();sm2=sw.copy();smw2=sw.copy()
    n=0;start=time.monotonic();report=None
    while n<samples and datetime.datetime.now(datetime.timezone.utc)<stop:
        count=min(8192,samples-n);incoming=rng.normal(0,sigma,(count,d+1))
        g=np.cos(incoming[:,0,None]+incoming[:,1:]@X.T)*chi
        signed=g*np.where(g[:,0]>=0,1.,-1.)[:,None]
        minimum=np.minimum.accumulate(signed,axis=1)[:,:-1]
        alive=minimum>0;z=np.zeros_like(minimum)
        np.divide(.5,sigma*minimum,out=z,where=alive)
        logw=np.where(alive,log_ndtr(-z),-np.inf)
        top=np.maximum(maximum,np.max(logw,axis=0));valid=np.isfinite(top)
        scale=np.zeros(M-1);np.exp(maximum-top,out=scale,where=valid)
        w=np.zeros_like(logw);np.exp(logw-top,out=w,where=alive&valid)
        sw*=scale;sc*=scale;sm*=scale
        sw2*=scale**2;sc2*=scale**2;sm2*=scale**2;smw2*=scale**2
        correct=signed[:,1:]>=0
        # Weighted first moment of the readout is sigma*phi(z), with its sign fixed.
        logmills=np.where(alive,-.5*z*z-.5*math.log(2*math.pi)-logw,0.)
        mills=np.exp(np.minimum(logmills,700))
        conditionalmean=sigma*mills*signed[:,1:]
        sw+=w.sum(axis=0);sw2+=(w*w).sum(axis=0)
        sc+=(w*correct).sum(axis=0);sc2+=(w*w*correct).sum(axis=0)
        sm+=(w*conditionalmean).sum(axis=0);smw2+=(w*w*conditionalmean).sum(axis=0)
        sm2+=((w*conditionalmean)**2).sum(axis=0)
        maximum=top;n+=count
        if n%1048576<count or n==samples:
            rows=[]
            for j in range(M-1):
                if sw[j]==0:
                    rows.append(dict(observed=j+1,status='unresolved_no_nonzero_weight'));continue
                prob=sc[j]/sw[j];mean=sm[j]/sw[j];ess=sw[j]**2/sw2[j]
                pse=math.sqrt(max(0.,sc2[j]*(1-2*prob)+prob*prob*sw2[j]))/sw[j]
                mse=math.sqrt(max(0.,sm2[j]-2*mean*smw2[j]+mean*mean*sw2[j]))/sw[j]
                rows.append(dict(observed=j+1,correct_probability=float(prob),correct_probability_empirical_se=pse,
                    posterior_mean=float(mean),posterior_mean_empirical_se=mse,importance_ess=float(ess),
                    log_history_probability=float(maximum[j]+math.log(sw[j])-math.log(n)),
                    inconclusive_low_ess=bool(ess<100),boundary_empirical_probability=bool(prob==0 or prob==1)))
            report=dict(dimension=d,sigma=sigma,seed=seed,samples=n,requested_samples=samples,
                seconds=time.monotonic()-start,status='complete' if n==samples else 'in_progress',rows=rows)
            save(report)
    if report is None:raise RuntimeError('No progress before deadline')
    report['status']='complete' if n==samples else 'partial_deadline'
    save(report);return report

def main():
    ap=argparse.ArgumentParser();ap.add_argument('--stop-utc',required=True);ap.add_argument('--samples',type=int,default=100_000_000);args=ap.parse_args()
    stop=datetime.datetime.fromisoformat(args.stop_utc);jobs=[];output=ROOT/'results/cosine_width_one_posterior.json'
    for index,(d,sigma) in enumerate([(3,.5),(3,1.),(3,2.),(5,1.),(5,2.),(7,2.)]):
        if datetime.datetime.now(datetime.timezone.utc)>=stop:break
        def save(job):
            payload=dict(status='in_progress',scope=__doc__.strip(),stop_utc=stop.isoformat(),jobs=jobs+[job])
            output.write_text(json.dumps(payload,indent=2)+'\n')
        job=run(d,sigma,args.samples,2026112300+index,stop,save);jobs.append(job)
        good=[r for r in job['rows'] if 'correct_probability' in r and not r['inconclusive_low_ess']]
        print(json.dumps(dict(dimension=d,sigma=sigma,samples=job['samples'],status=job['status'],resolved_histories=len(good),
            estimated_majority_errors=sum(r['correct_probability']<.5 for r in good),seconds=job['seconds'])),flush=True)
    output.write_text(json.dumps(dict(status='complete' if len(jobs)==6 and all(r['status']=='complete' for r in jobs) else 'partial_deadline',scope=__doc__.strip(),stop_utc=stop.isoformat(),jobs=jobs),indent=2)+'\n')
if __name__=='__main__':main()
