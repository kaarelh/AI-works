"""Independent softplus sector proposal with a truncated supercritical bulk tilt.

Uses one independent critical pilot to set the proposal constants. The exact
importance ratio is conditional on that pilot. Diagnostics concern only the
explicit canonical subset; no full-posterior TV certification is claimed.
"""
import os
for key in ('OPENBLAS_NUM_THREADS','OMP_NUM_THREADS','VECLIB_MAXIMUM_THREADS'):os.environ[key]='1'
import argparse,json,math,time
from pathlib import Path
import numpy as np
from scipy.special import erfcx,log_ndtr,ndtri_exp
import full_label_independent as f

BETA=1.;P0=len(f.ZERO)/f.M;KAPPA=P0*math.log(2)/(BETA*f.RHO);NU=(f.R+2)/4
Q=f.TBASE.T@(f.ZERO_BAR.T@f.ZERO_BAR/f.M)@f.TBASE
TCOV=4*f.RHO/BETA*np.linalg.inv(Q);TCHOL=np.linalg.cholesky(TCOV)

def bulk(rng,count,width=None,tau=0.,cutoff=.1):
    total=np.zeros(f.M);maximum=0.;statistic=0.;accepted=0;proposals=0
    eps=0. if width is None else tau/math.sqrt(width)
    cap=np.inf if width is None else cutoff*math.sqrt(width)
    bound=0. if width is None else (eps+eps*eps/2)*cap
    while accepted<count:
        size=min(8192,max(64,math.ceil((count-accepted)*2.5)));proposals+=size
        t=np.expm1(-np.log(rng.random(size))/(f.R-2))/f.HALF
        loga=.5*math.log(math.pi/2)+np.log(erfcx(t/math.sqrt(2)))
        keep=np.log(rng.random(size))<(f.R-1)*(math.log(f.HALF)+loga+np.log1p(f.HALF*t))
        t=t[keep];size=len(t)
        w=-ndtri_exp(log_ndtr(-t)[:,None]+np.log(rng.random((size,f.R))))
        w[:,0]=t;b=rng.normal(size=size);norm=b*b+np.sum(w*w,axis=1)
        keep=norm<=cap;t=t[keep];w=w[keep];b=b[keep];norm=norm[keep]
        phi=np.logaddexp(0,BETA*(b[:,None]+w@f.X.T))/BETA;g=phi@f.CHI/f.M
        logaccept=-.5*(f.R*t*t-(g/f.RHO)**2)+(eps+eps*eps/2)*(g/f.RHO)**2-bound
        if len(logaccept):assert logaccept.max()<1e-7
        keep=np.log(rng.random(len(g)))<np.minimum(logaccept,0)
        w=w[keep];b=b[keep];g=g[keep];norm=norm[keep]
        a=(1+eps)*g/f.RHO+rng.normal(size=len(g));fullnorm=norm+a*a
        keep=fullnorm<=cap;w=w[keep];b=b[keep];g=g[keep];a=a[keep];fullnorm=fullnorm[keep]
        size=len(g);where=rng.integers(0,f.R,size);rows=np.arange(size);first=w[:,0].copy()
        w[:,0]=w[rows,where];w[rows,where]=first
        signs=2*rng.integers(0,2,(size,f.R))-1;a*=signs.prod(axis=1);w*=signs;g*=signs.prod(axis=1)
        take=min(size,count-accepted);w=w[:take];b=b[:take];a=a[:take];g=g[:take];fullnorm=fullnorm[:take]
        total+=a@np.logaddexp(0,BETA*(b[:,None]+w@f.X.T))/BETA
        statistic+=float(a@g)
        if take:maximum=max(maximum,float(fullnorm.max()))
        accepted+=take
    assert abs(total@f.CHI/f.M-statistic)<1e-7*(1+abs(statistic))
    return total,maximum,proposals

def proposal(rng,N,s,loss,table,alpha_hat,mc_hat,cutoff=.1,transverse_cut=.5):
    tau=KAPPA/(2*math.sqrt(alpha_hat))
    lam=1/(f.RHO*(1-s)) if loss=='square' else (1+math.exp(s))/f.RHO
    gamma=lam/f.M if loss=='square' else lam*math.exp(s)/(1+math.exp(s))**2/f.M
    pat=table['patterns'][int(np.searchsorted(table['cdf'],rng.random()))]
    eps=2*((pat>>np.arange(f.K,dtype=np.uint32))&1).astype(float)-1;z=eps[:,None]*f.BASE
    dots=z@f.X.T;A=np.maximum(dots.T,0)*f.SIGMA[None,:]/math.sqrt(f.R)
    gram=A.T@A;chol=np.linalg.cholesky(gram);Ap=np.linalg.solve(gram,A.T)
    Y,maxbulk,used=bulk(rng,N-f.K,N,tau,cutoff);PY=Y-A@(Ap@Y)
    logaccept=-gamma*float(PY@PY)/(2*N)
    row=dict(accepted_bulk=False,accepted=False,critical_proposals=used,mark_proposals=0,log_bulk_acceptance=logaccept)
    if math.log(rng.random())>=logaccept:return row
    row['accepted_bulk']=True
    mu=-tau/(gamma*f.K*f.M*f.RHO**2)
    eta=mu+np.linalg.solve(chol.T,rng.normal(size=f.K))/math.sqrt(gamma)
    c=N*s/(f.K*f.RHO)-Ap@Y+math.sqrt(N)*(KAPPA*math.sqrt(alpha_hat)+eta)
    alo=(s-.375)/(2*f.K*f.RHO);ahi=2*s/(f.K*f.RHO)
    if np.any(c<alo*N) or np.any(c>ahi*N):return row
    v=rng.normal(-KAPPA/2,1,size=f.K);tc=rng.normal(size=(f.K,f.R))@TCHOL.T;t=tc@f.TBASE.T
    root=np.sqrt(v*v+4*c);read=(root+v)/2;rad=(root-v)/2
    rotated=np.column_stack([t[:,0],t[:,1:]*z]);u=rotated/c[:,None]**.25
    incoming=np.column_stack([np.zeros(f.K),rad[:,None]*z/math.sqrt(f.R)])+u
    pre=incoming@f.XBAR.T
    good=(read/rad>=.5)&(read/rad<=2)&(np.linalg.norm(u,axis=1)<=transverse_cut)
    good&=np.max(abs(u@f.XBAR.T),axis=1)<rad/math.sqrt(f.R)
    if not np.all(good):return row
    big=np.sum((f.SIGMA*read)[:,None]*np.logaddexp(0,BETA*pre)/BETA,axis=0)
    actual=Y+big;signed=f.CHI*actual/N
    if loss=='logistic' and np.max(abs(signed-s))>.1:return row
    zero=(t/c[:,None]**.25)@f.ZERO_BAR.T
    hdiff=np.logaddexp(BETA*zero/2,-BETA*zero/2).sum(axis=1)/(BETA*f.M)-P0*math.log(2)/BETA
    quadratic=BETA/(8*f.RHO)*np.sum((tc@Q)*tc,axis=1)
    delta=np.sum(f.CHI[None,:]*f.SIGMA[:,None]*np.logaddexp(0,-BETA*abs(pre))*(dots!=0),axis=1)/(BETA*f.M)
    rem=v*v/(2*(root+2*np.sqrt(c)))
    corner=-.5*np.log1p(v*v/(4*c))-.5*np.sum(u*u,axis=1)-KAPPA*rem-read/f.RHO*hdiff+quadratic+read/f.RHO*delta
    logmacro=-NU*np.log(c/N).sum()-KAPPA*np.sum((c-N*alpha_hat)/(np.sqrt(c)+math.sqrt(N*alpha_hat)))+corner.sum()
    ordinary=-tau/(f.RHO*math.sqrt(N))*(Y@f.CHI/f.M-(N-f.K)*mc_hat)
    proxy=gamma*float(PY@PY)/(2*N)+gamma*float((A@(eta-mu))@(A@(eta-mu)))/2
    if loss=='square':logactual=-gamma*float((actual-N*s*f.CHI)@(actual-N*s*f.CHI))/(2*N)
    else:
        g=signed/f.RHO+lam*np.logaddexp(0,-signed);gs=s/f.RHO+lam*np.logaddexp(0,-s)
        logactual=-N*float(np.mean(g-gs))
    row.update(accepted=True,logweight=float(logmacro+ordinary+logactual+proxy),
               minimum_margin=float(signed.min()),mean_margin=float(signed.mean()),
               min_amplitude_over_width=float(c.min()/N),max_amplitude_over_width=float(c.max()/N),
               largest_bulk_norm_over_sqrt_width=math.sqrt(maxbulk/N),
               maximum_transverse_output=float(np.max(abs(big-A@c))),pattern=int(pat),signed_output=signed.tolist())
    return row

def main():
    ap=argparse.ArgumentParser();ap.add_argument('--width',type=int,required=True);ap.add_argument('--proposals',type=int,default=1000)
    ap.add_argument('--loss',choices=['square','logistic'],default='square');ap.add_argument('--seed',type=int,required=True)
    ap.add_argument('--output',type=Path,required=True);ap.add_argument('--cutoff',type=float,default=.1)
    args=ap.parse_args();N=args.width;s=.5;rng=np.random.default_rng(args.seed);start=time.monotonic()
    pilot,_,pilotused=bulk(rng,N);mc_hat=float(pilot@f.CHI/f.M/N)
    alo=(s-.375)/(2*f.K*f.RHO);ahi=2*s/(f.K*f.RHO);alpha_hat=float(np.clip((s-mc_hat)/(f.K*f.RHO),alo,ahi))
    table=f.geometry_table();rows=[];args.output.parent.mkdir(parents=True,exist_ok=True)
    with args.output.with_suffix('.jsonl').open('w',buffering=1) as stream:
        for i in range(args.proposals):
            row=proposal(rng,N,s,args.loss,table,alpha_hat,mc_hat,args.cutoff);rows.append(row);stream.write(json.dumps(row)+'\n')
            if (i+1)%25==0 or i+1==args.proposals:
                out=f.summarize(rows,N,s,args.loss,args.seed,time.monotonic()-start)
                out.update(activation='softplus',beta=BETA,pilot_samples=N,pilot_mean=mc_hat,pilot_alpha=alpha_hat,pilot_critical_proposals=pilotused,
                           ordinary_squared_norm_cutoff=args.cutoff*math.sqrt(N),physical_transverse_cutoff=.5,
                           status='complete' if i+1==args.proposals else 'in_progress',
                           scope='Conditional-pilot canonical-subset importance diagnostics; no certified full-posterior TV or practical worst-case runtime guarantee.')
                args.output.write_text(json.dumps(out,indent=2)+'\n');print(json.dumps({k:out[k] for k in ['width','proposals','accepted','seconds']}),flush=True)
if __name__=='__main__':main()
