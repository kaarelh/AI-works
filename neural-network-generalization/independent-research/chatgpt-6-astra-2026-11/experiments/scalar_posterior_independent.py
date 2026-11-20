"""Independent scalar-conditioned posterior proposals in dimension four.

The critical bulk uses the derived rejection envelope. The exceptional
mark is drawn from its limiting density and reconstructed at the required
statistic. Finite-width importance diagnostics concern the portion with
the largest neuron inside the specified critical cones; they do not
certify the omitted mass or total variation for the full posterior.
All numerical operations are floating point, not exact real arithmetic.
"""
import os
for key in ('OPENBLAS_NUM_THREADS','OMP_NUM_THREADS','VECLIB_MAXIMUM_THREADS'):os.environ[key]='1'
import argparse,json,math,time
from pathlib import Path
import numpy as np
from scipy.special import erfcx,log_ndtr,ndtri_exp
from check_critical_tail_density import draw_transverse,B,X,parity

ROOT=Path(__file__).resolve().parents[1]
RHO=.125;ALPHA=1.5;HALF=math.sqrt(2/math.pi);ETA=RHO/(2*math.sqrt(5))

def critical_neurons(rng,count):
    chunks=[];accepted=0;proposals=0
    while accepted<count:
        size=min(32768,max(256,math.ceil((count-accepted)*1.8)))
        proposals+=size
        t=np.expm1(-np.log(rng.random(size))/2)/HALF
        loga=.5*math.log(math.pi/2)+np.log(erfcx(t/math.sqrt(2)))
        keep=np.log(rng.random(size)) < 3*(math.log(HALF)+loga+np.log1p(HALF*t))
        t=t[keep];size=len(t)
        w=-ndtri_exp(log_ndtr(-t)[:,None]+np.log(rng.random((size,4))))
        w[:,0]=t
        b=rng.normal(size=size)
        g=np.maximum(b[:,None]+w@X.T,0)@parity/16
        penalty=.5*(4*t*t-(g/RHO)**2)
        if len(penalty):assert penalty.min()>-1e-7
        keep=np.log(rng.random(size)) < -np.maximum(penalty,0)
        w=w[keep];b=b[keep];g=g[keep];size=len(g)
        # The other excess magnitudes are exchangeable, so a random
        # swap restores the uniformly chosen minimum coordinate.
        where=rng.integers(0,4,size);rows=np.arange(size);first=w[:,0].copy()
        w[:,0]=w[rows,where];w[rows,where]=first
        signs=2*rng.integers(0,2,(size,4))-1
        a=(g/RHO+rng.normal(size=size))*np.prod(signs,axis=1)
        w*=signs;g*=np.prod(signs,axis=1)
        take=min(size,count-accepted)
        chunks.append((a[:take],b[:take],w[:take],g[:take]))
        accepted+=take
    return tuple(np.concatenate([c[j] for c in chunks]) for j in range(4)),proposals

def proposal_batch(rng,n,s,batch):
    (a,b,w,g),used=critical_neurons(rng,(n-1)*batch)
    zbulk=(a*g).reshape(batch,n-1)
    bulk_sum=zbulk.sum(axis=1);bulk_max=zbulk.max(axis=1)
    bulk_norm=np.sqrt(a*a+b*b+np.sum(w*w,axis=1)).reshape(batch,n-1).max(axis=1)
    outputs=np.empty((len(a),16))
    for first in range(0,len(a),32768):
        stop=min(first+32768,len(a))
        outputs[first:stop]=a[first:stop,None]*np.maximum(b[first:stop,None]+w[first:stop]@X.T,0)
    if batch*n<10000:
        assert np.max(abs(outputs@parity/16-a*g))<1e-8
    bulk_output=outputs.reshape(batch,n-1,16).sum(axis=1)
    overshoot=rng.exponential(RHO,size=batch)
    z=n*s-bulk_sum+overshoot
    bt,t=draw_transverse(rng,batch);normt2=bt*bt+np.sum(t*t,axis=1)
    H=RHO*np.maximum(abs(bt)[:,None]/2,abs(t)).sum(axis=1)
    v=rng.normal(size=batch);safez=np.maximum(z,1e-12)
    low=safez/RHO
    high=low+H/RHO*(1+abs(v)/np.sqrt(low))+1
    for iteration in range(56):
        c=(low+high)/2
        root=np.sqrt(v*v+4*c);A=(root+v)/2;q=A/np.sqrt(c)
        value=RHO*c-q*H
        low=np.where(value<safez,c,low);high=np.where(value<safez,high,c)
    c=(low+high)/2;root=np.sqrt(v*v+4*c);A=(root+v)/2;R=(root-v)/2;q=A/np.sqrt(c)
    signs=X[rng.integers(0,16,batch)]
    bigw=(R[:,None]/2+(t@B)/np.sqrt(c)[:,None])*signs
    bigb=bt/np.sqrt(c);biga=-np.prod(signs,axis=1)*A
    big_output=biga[:,None]*np.maximum(bigb[:,None]+bigw@X.T,0)
    actualz=big_output@parity/16
    cone=(A/R>=.5)&(A/R<=2)&(np.sqrt(normt2/c)<=ETA*R)
    good=(z>0)&(z>bulk_max)&cone
    defect=np.max(np.where(good,abs(actualz-z)/(1+abs(z)),0))
    assert defect<1e-8,defect
    dzdc=RHO+H*q*v/(2*c*root)
    logweight=math.log(2)+(ALPHA+1)*math.log(n*s)-ALPHA*math.log(RHO)-2*np.log(c)-np.log(root)-np.log(dzdc)-normt2/(2*c)-(q-1)*H/RHO
    weight=np.where(good,np.exp(np.minimum(logweight,700)),0)
    prediction=(bulk_output+big_output)/n
    error=np.mean(prediction*parity[None,:]<=0,axis=1)
    energy=(biga*biga+bigb*bigb+np.sum(bigw*bigw,axis=1))/n
    return dict(weight=weight,accepted=good,classification_error=error,
        overshoot=overshoot,exceptional_statistic=z/n,exceptional_norm_squared=energy,
        largest_bulk_norm_over_sqrt_width=bulk_norm/math.sqrt(n),bulk_statistic=bulk_sum/n,
        statistic_relative_error=np.full(batch,defect),predictions=prediction,
        critical_proposals=used)

def summarize(n,s,seed,parts,seconds):
    keys=[key for key in parts[0] if key!='critical_proposals']
    data={key:np.concatenate([p[key] for p in parts]) for key in keys}
    good=data['accepted'];w=data['weight'];total=len(good);accepted=int(good.sum())
    wn=w/w.sum() if w.sum() else np.zeros_like(w)
    summary=dict(width=n,margin=s,seed=seed,proposals=total,accepted=accepted,
        acceptance_fraction=accepted/total,weight_mean=float(w.mean()),
        weight_standard_error=float(w.std(ddof=1)/math.sqrt(total)),
        maximum_weight=float(w.max()),effective_importance_samples=float(1/(wn@wn)) if w.sum() else 0.,
        self_normalized_weight_discrepancy=float(np.mean(abs(w[good]/w[good].mean()-1))/2) if accepted else None,
        critical_elementary_proposals=sum(p['critical_proposals'] for p in parts),seconds=seconds,
        maximum_statistic_relative_error=float(data['statistic_relative_error'].max()))
    for key in ('classification_error','overshoot','exceptional_statistic','exceptional_norm_squared','largest_bulk_norm_over_sqrt_width','bulk_statistic'):
        values=data[key]
        summary[key]=dict(accepted_mean=float(values[good].mean()) if accepted else None,
            weighted_mean=float(wn@values),accepted_quantiles=np.quantile(values[good],[.05,.5,.95]).tolist() if accepted else [])
    summary['accepted_mean_predictions']=data['predictions'][good].mean(axis=0).tolist() if accepted else []
    summary['weighted_mean_predictions']=(wn@data['predictions']).tolist()
    return summary

def main():
    ap=argparse.ArgumentParser();ap.add_argument('--width',type=int,required=True);ap.add_argument('--margin',type=float,default=1)
    ap.add_argument('--seed',type=int,default=2026111901);ap.add_argument('--samples',type=int,default=4096)
    ap.add_argument('--output',type=Path,required=True);args=ap.parse_args()
    rng=np.random.default_rng(args.seed);started=time.monotonic();parts=[];count=0
    while count<args.samples:
        batch=min(args.samples-count,max(1,min(128,262144//args.width)))
        parts.append(proposal_batch(rng,args.width,args.margin,batch));count+=batch
        if count==args.samples or count%1024==0:
            result=summarize(args.width,args.margin,args.seed,parts,time.monotonic()-started)
            result['status']='complete' if count==args.samples else 'in_progress'
            result['qualification']='Independent floating-point proposal diagnostics. Weighted results omit posterior configurations outside the prescribed largest-neuron cones. The weight discrepancy is not a certified full-posterior total-variation bound.'
            args.output.parent.mkdir(parents=True,exist_ok=True);args.output.write_text(json.dumps(result,indent=2)+'\n')
            print(json.dumps({key:result[key] for key in ['status','width','margin','proposals','acceptance_fraction','weight_mean','self_normalized_weight_discrepancy','seconds']}),flush=True)

if __name__=='__main__':main()
