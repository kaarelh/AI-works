"""Independent full-label ReLU posterior proposal, six input bits.

Floating-point implementation of the soft construction. Geometry-only
rejection is integrated out by enumerating all balanced orientations.
Importance diagnostics concern the canonical cone subset only and do not
certify omitted full-posterior mass or a total-variation error bound.
"""
import os
for key in ('OPENBLAS_NUM_THREADS','OMP_NUM_THREADS','VECLIB_MAXIMUM_THREADS'):
    os.environ[key]='1'
import argparse,json,math,time
from pathlib import Path
import numpy as np
from scipy.linalg import null_space
from scipy.special import erfcx,log_ndtr,ndtri_exp

ROOT=Path(__file__).resolve().parents[1]
PRIOR=Path(os.environ.get('NNBAYES_COLLECTION', str(ROOT.parents[1])))
R=6;M=64;K=32;NU=3.5
X=2*((np.arange(M)[:,None]>>np.arange(R))&1)-1
CHI=X.prod(axis=1);XBAR=np.column_stack([np.ones(M),X])
BASE=np.column_stack([np.ones(K),2*((np.arange(K)[:,None]>>np.arange(R-1))&1)-1])
SIGMA=BASE.prod(axis=1)
RHO=6/(32*math.sqrt(6));HALF=math.sqrt(2/math.pi)
E=abs(X@BASE.T)*SIGMA[None,:]/(2*math.sqrt(R))
GE=E.T@E;GEINV=np.linalg.inv(GE)
TBASE=np.zeros((R+1,R));TBASE[0,0]=1
TBASE[1:,1:]=null_space(np.ones((1,R)))
ZERO=X[X.sum(1)==0];ZERO_BAR=np.column_stack([np.ones(len(ZERO)),ZERO])
TRANSVERSE_ROWS=ZERO_BAR@TBASE
# sum |l_i t| >= sum(l_i t)^2 / max |l_i t|.
HLOW=float(np.linalg.eigvalsh(TRANSVERSE_ROWS.T@TRANSVERSE_ROWS).min())/(128*math.sqrt(R+1))

def geometry_table():
    path=ROOT/'results/orientation_geometry_d6.npz'
    if path.exists():return np.load(path)
    patterns=np.fromfile(PRIOR/'results/relu_balanced_orientations_d6.bin',dtype='<u4')
    weights=[]
    for first in range(0,len(patterns),4096):
        eps=2*((patterns[first:first+4096,None]>>np.arange(K,dtype=np.uint32))&1).astype(float)-1
        L=math.sqrt(M)/(2*math.sqrt(R))*BASE.T[None,:,:]*(eps*SIGMA)[:,None,:]
        small=np.eye(R)[None,:,:]+(L@GEINV)@L.transpose(0,2,1)
        sign,ld=np.linalg.slogdet(small);assert np.all(sign>0)
        weights.append(np.exp(-ld/2))
    weights=np.concatenate(weights);cdf=np.cumsum(weights);cdf/=cdf[-1]
    np.savez_compressed(path,patterns=patterns,weights=weights,cdf=cdf)
    return np.load(path)

def critical_bulk(rng,count):
    total=np.zeros(M);maxnorm2=0.;statistic=0.;accepted=0;proposals=0
    while accepted<count:
        size=min(16384,max(64,math.ceil((count-accepted)*1.6)));proposals+=size
        t=np.expm1(-np.log(rng.random(size))/(R-2))/HALF
        loga=.5*math.log(math.pi/2)+np.log(erfcx(t/math.sqrt(2)))
        keep=np.log(rng.random(size))<(R-1)*(math.log(HALF)+loga+np.log1p(HALF*t))
        t=t[keep];size=len(t)
        w=-ndtri_exp(log_ndtr(-t)[:,None]+np.log(rng.random((size,R))))
        w[:,0]=t;b=rng.normal(size=size)
        phi=np.maximum(b[:,None]+w@X.T,0);g=phi@CHI/M
        penalty=.5*(R*t*t-(g/RHO)**2)
        if len(penalty):assert penalty.min()>-1e-7
        keep=np.log(rng.random(size))<-np.maximum(penalty,0)
        w=w[keep];b=b[keep];g=g[keep];size=len(g)
        where=rng.integers(0,R,size);rows=np.arange(size);first=w[:,0].copy()
        w[:,0]=w[rows,where];w[rows,where]=first
        signs=2*rng.integers(0,2,(size,R))-1
        a=(g/RHO+rng.normal(size=size))*signs.prod(axis=1)
        w*=signs;g*=signs.prod(axis=1)
        take=min(size,count-accepted);w=w[:take];b=b[:take];a=a[:take];g=g[:take]
        total+=a@np.maximum(b[:,None]+w@X.T,0)
        statistic+=float(a@g)
        if take:maxnorm2=max(maxnorm2,float(np.max(a*a+b*b+np.sum(w*w,axis=1))))
        accepted+=take
    assert abs(total@CHI/M-statistic)<1e-7*(1+abs(statistic))
    return total,maxnorm2,proposals

def marks(rng,count):
    found=[];used=0;accepted=0
    while accepted<count:
        batch=max(1024,(count-accepted)*256);used+=batch
        directions=rng.normal(size=(batch,R));directions/=np.linalg.norm(directions,axis=1)[:,None]
        h=np.sum(abs(directions@TRANSVERSE_ROWS.T),axis=1)/128
        assert h.min()>HLOW*(1-1e-10)
        keep=np.log(rng.random(batch))<R*np.log(HLOW/h)
        directions=directions[keep];h=h[keep]
        radius=rng.gamma(R,size=len(h))*RHO/h
        take=min(len(h),count-accepted)
        found.append(directions[:take]*radius[:take,None]);accepted+=take
    t=np.concatenate(found)@TBASE.T
    return rng.normal(size=count),t,used

def proposal(rng,n,s,loss,table):
    ix=int(np.searchsorted(table['cdf'],rng.random()))
    pattern=table['patterns'][ix]
    eps=2*((pattern>>np.arange(K,dtype=np.uint32))&1).astype(float)-1
    z=eps[:,None]*BASE
    A=np.maximum(X@z.T,0)*SIGMA[None,:]/math.sqrt(R)
    gram=A.T@A;chol=np.linalg.cholesky(gram)
    plus=np.linalg.solve(gram,A.T)
    if loss=='square':lam=1/(RHO*(1-s));gamma=lam/M
    else:lam=(1+math.exp(s))/RHO;gamma=lam*math.exp(s)/(1+math.exp(s))**2/M
    Y,maxbulk,used=critical_bulk(rng,n-K)
    residual=Y-A@(plus@Y)
    logaccept=-gamma*float(residual@residual)/(2*n)
    row=dict(accepted_bulk=False,accepted=False,critical_proposals=used,mark_proposals=0,log_bulk_acceptance=logaccept)
    if math.log(rng.random())>=logaccept:return row
    row['accepted_bulk']=True
    eta=np.linalg.solve(chol.T,rng.normal(size=K))/math.sqrt(gamma)
    c=n*s/(K*RHO)-plus@Y+math.sqrt(n)*eta
    if np.min(c)<=0:return row
    v,t,markused=marks(rng,K);row['mark_proposals']=markused
    root=np.sqrt(v*v+4*c);readout=(root+v)/2;radial=(root-v)/2
    # The base transverse marks are carried by coordinate sign changes.
    incoming=np.column_stack([t[:,0]/np.sqrt(c),radial[:,None]*z/math.sqrt(R)+t[:,1:]*z/np.sqrt(c)[:,None]])
    biga=SIGMA*readout
    big=np.maximum(incoming@XBAR.T,0)*biga[:,None]
    linear=c[:,None]*A.T
    tnorm2=np.sum(t*t,axis=1);norm2=readout**2+np.sum(incoming**2,axis=1)
    # A sufficient fixed cone: all nonzero ray activation signs unchanged,
    # incoming transverse norm small, and balanced layer ratio bounded.
    eta_cone=1/(4*math.sqrt(R*(R+1)))
    good=(readout/radial>=.5)&(readout/radial<=2)&(np.sqrt(tnorm2/c)<=eta_cone*radial)&(norm2>maxbulk)
    if not np.all(good):return row
    ideal=Y+A@c;actual=Y+big.sum(axis=0)
    h=np.sum(abs(t@ZERO_BAR.T),axis=1)/128
    q=readout/np.sqrt(c)
    logdensity=np.sum(math.log(2)-R/2*np.log(c/n)-np.log(root/math.sqrt(n))-tnorm2/(2*c)-(q-1)*h/RHO)
    idealresidual=ideal-n*s*CHI
    logquad=-gamma*float(idealresidual@idealresidual)/(2*n)
    signed=CHI*actual/n
    if loss=='square':g=signed/RHO+lam*(1-signed)**2/2;gs=s/RHO+lam*(1-s)**2/2
    else:g=signed/RHO+lam*np.logaddexp(0,-signed);gs=s/RHO+lam*np.logaddexp(0,-s)
    logactual=-n*float(np.mean(g-gs))
    # All missing factors are common to samples at this N and cancel in
    # self-normalized diagnostics on the restricted canonical cone subset.
    row.update(accepted=True,logweight=float(logdensity+logactual-logquad),
        minimum_margin=float(signed.min()),mean_margin=float(signed.mean()),
        min_amplitude_over_width=float(c.min()/n),max_amplitude_over_width=float(c.max()/n),
        largest_bulk_norm_over_sqrt_width=math.sqrt(maxbulk/n),
        maximum_transverse_output=float(np.max(abs(big-linear))),
        pattern=int(pattern),signed_output=signed.tolist())
    return row

def summarize(rows,n,s,loss,seed,seconds):
    accepted=[r for r in rows if r['accepted']]
    out=dict(width=n,margin=s,loss=loss,seed=seed,proposals=len(rows),accepted_bulk=sum(r['accepted_bulk'] for r in rows),accepted=len(accepted),seconds=seconds,
        critical_proposals=sum(r['critical_proposals'] for r in rows),mark_proposals=sum(r['mark_proposals'] for r in rows),
        scope='Floating-point independent proposals; weight comparison only on canonical cone subset, not certified full-posterior TV.')
    if accepted:
        lw=np.array([r['logweight'] for r in accepted]);w=np.exp(lw-lw.max());w/=w.sum()
        out['effective_importance_samples']=float(1/(w@w))
        out['restricted_weight_discrepancy']=float(np.mean(abs(w*len(w)-1))/2)
        out['log_mean_weight']=float(lw.max()+math.log(np.exp(lw-lw.max()).mean()))
        for key in ['minimum_margin','mean_margin','min_amplitude_over_width','max_amplitude_over_width','largest_bulk_norm_over_sqrt_width','maximum_transverse_output']:
            vals=np.array([r[key] for r in accepted]);out[key]=dict(mean=float(vals.mean()),weighted_mean=float(w@vals),quantiles=np.quantile(vals,[.05,.5,.95]).tolist())
    return out

def main():
    ap=argparse.ArgumentParser();ap.add_argument('--width',type=int,default=1024);ap.add_argument('--margin',type=float,default=.5)
    ap.add_argument('--loss',choices=['square','logistic'],default='square');ap.add_argument('--seed',type=int,default=2026112001)
    ap.add_argument('--proposals',type=int,default=1000);ap.add_argument('--output',type=Path,required=True)
    args=ap.parse_args();assert args.width>M
    table=geometry_table();rng=np.random.default_rng(args.seed);rows=[];start=time.monotonic()
    args.output.parent.mkdir(parents=True,exist_ok=True)
    with args.output.with_suffix('.jsonl').open('w',buffering=1) as f:
        for j in range(args.proposals):
            row=proposal(rng,args.width,args.margin,args.loss,table);rows.append(row);f.write(json.dumps(row)+'\n')
            if (j+1)%100==0 or j+1==args.proposals:
                result=summarize(rows,args.width,args.margin,args.loss,args.seed,time.monotonic()-start)
                result['status']='complete' if j+1==args.proposals else 'in_progress'
                args.output.write_text(json.dumps(result,indent=2)+'\n')
                print(json.dumps({k:result[k] for k in ['width','loss','proposals','accepted','seconds']}),flush=True)
if __name__=='__main__':main()
