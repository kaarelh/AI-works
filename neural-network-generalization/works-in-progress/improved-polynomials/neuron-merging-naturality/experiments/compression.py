#!/usr/bin/env python3
"""Exploratory balanced neuron clustering; no labels used to choose groups.

Original unsigned projections and signed (gauge-invariant alternative) are
reported separately. Full small-cube evaluation is float64, not a certificate.
Raw saved weights and rescaled-readout diagnostics are never pooled.
"""
import os
os.environ['OPENBLAS_NUM_THREADS']='1'
os.environ['OMP_NUM_THREADS']='1'
import argparse, concurrent.futures, hashlib, json, time
from pathlib import Path
import numpy as np
from scipy.optimize import linear_sum_assignment

ROOT=Path(__file__).resolve().parent
ROUND2=None # Omitted historical archives are enumerated in dataset-manifest.json
PUBLIC=None

def cube(d, ordering='lexicographic'):
    shifts=np.arange(d-1,-1,-1) if ordering=='lexicographic' else np.arange(d)
    return (2*((np.arange(2**d)[:,None]>>shifts)&1)-1).astype(float)

def forward(weights,x,cache=False):
    h=np.column_stack((x,np.ones(len(x)))); hs=[]
    for w in weights[:-1]:
        h=np.tanh(h@w);hs.append(h)
    z=h@weights[-1]
    return (z,hs) if cache else z

def balanced_cluster(features,q,signed,seed,iterations=12,balanced=True):
    n,dim=features.shape
    if q==n:return np.arange(n),np.ones(n),0.
    rng=np.random.default_rng(seed)
    norms=np.sum(features**2,axis=1)
    centers=[features[rng.integers(n)].copy()]
    for _ in range(1,q):
        dots=features@np.array(centers).T
        ds=norms[:,None]+np.sum(np.array(centers)**2,axis=1)[None,:]-2*(np.abs(dots) if signed else dots)
        nearest=np.maximum(0,ds.min(axis=1));total=nearest.sum()
        idx=rng.choice(n,p=nearest/total) if total>1e-24 else rng.integers(n)
        centers.append(features[idx].copy())
    centers=np.array(centers);sizes=np.full(q,n//q);sizes[:n%q]+=1
    slots=np.repeat(np.arange(q),sizes);previous=None
    for _ in range(iterations):
        dots=features@centers.T
        cost=norms[:,None]+np.sum(centers**2,axis=1)[None,:]-2*(np.abs(dots) if signed else dots)
        if balanced:
            rows,cols=linear_sum_assignment(cost[:,slots]);groups=np.empty(n,dtype=int);groups[rows]=slots[cols]
        else:
            groups=np.argmin(cost,axis=1)
            counts=np.bincount(groups,minlength=q)
            for empty in np.flatnonzero(counts==0):
                candidates=np.flatnonzero(counts[groups]>1)
                move=candidates[np.argmax(cost[candidates,groups[candidates]])]
                counts[groups[move]]-=1;groups[move]=empty;counts[empty]+=1
        signs=np.where(dots[np.arange(n),groups]>=0,1.,-1.) if signed else np.ones(n)
        state=(groups.tobytes(),signs.tobytes())
        centers=np.array([np.mean(features[groups==j]*signs[groups==j,None],axis=0) for j in range(q)])
        if state==previous:break
        previous=state
    error=float(np.sum((features-signs[:,None]*centers[groups])**2))
    return groups,signs,error

def compressed_weights(weights,partitions):
    q=int(partitions[0][0].max()+1);n=len(weights[-1]);bases=[];sizes=[]
    for groups,signs in partitions:
        basis=np.zeros((n,q));basis[np.arange(n),groups]=signs
        bases.append(basis);sizes.append(np.bincount(groups,minlength=q))
    out=[(weights[0]@bases[0])/sizes[0][None,:]]
    for s,w in enumerate(weights[1:-1],start=1):
        out.append((bases[s-1].T@w@bases[s])/sizes[s][None,:])
    out.append(bases[-1].T@weights[-1])
    return out

def model_paths():
    manifest=json.loads((ROOT/'dataset-manifest.json').read_text())
    return [(ROOT/item['checkpoint'],item['cohort']) for item in manifest if item['included']]


def run_model(item):
    path,cohort=item;start=time.monotonic();ident=next(m['id'] for m in json.loads((ROOT/'dataset-manifest.json').read_text()) if m['included'] and ROOT/m['checkpoint']==path)
    destination=ROOT/'recomputed-results'/f'{ident}.json'
    if destination.exists() and json.loads(destination.read_text()).get('schema_version',0)>=4:return {'model':ident,'cached':True}
    ar=np.load(path);keys=sorted([k for k in ar.files if k.startswith('w') and k[1:].isdigit()],key=lambda k:int(k[1:]))
    weights=[ar[k].astype(float) for k in keys];n=len(weights[-1]);d=weights[0].shape[0]-1
    x=cube(d,'lexicographic' if cohort in ('round2','fresh','freshH23') else 'little_endian');z,hs=forward(weights,x,True)
    probe=np.random.default_rng(9091).choice(len(x),size=min(256,len(x)),replace=False)
    ev=float(n*np.sum(weights[-1]**2));rms=float(np.sqrt(np.mean(z*z)));scale=1/rms if rms>1e-12 else 1.
    normev=ev*scale*scale;cap=min(n,int(np.floor(1+ev)));normcap=min(n,int(np.floor(1+normev)))
    maxout=float(np.max(np.abs(z)));readout_l1=float(np.abs(weights[-1]).sum())
    invariant_cap=min(n,int(np.floor(1+16*ev/maxout**2))) if maxout>1e-12 else n
    invariant4_cap=min(n,int(np.floor(1+4*ev/maxout**2))) if maxout>1e-12 else n
    l1_cap=min(n,int(np.floor(1+4*ev/readout_l1**2))) if readout_l1>1e-12 else n
    qs=sorted(set([1,2,4,8,16,32,64,n,cap,normcap,invariant_cap,invariant4_cap,l1_cap,max(1,n//4),max(1,n//2),max(1,3*n//4)])&set(range(1,n+1)))
    variants={'raw':{'scale':1.,'Ev':ev,'q_cap':cap,'trivial':cap==n},'rms_normalized_readout':{'scale':scale,'Ev':normev,'q_cap':normcap,'trivial':normcap==n},'scale_invariant_budget16_exploratory':{'scale':1.,'Ev':ev,'q_cap':invariant_cap,'trivial':invariant_cap==n,'M_infinity':maxout,'formula':'floor(1+16 Ev/M_infinity^2)'},'scale_invariant_budget4':{'scale':1.,'Ev':ev,'q_cap':invariant4_cap,'trivial':invariant4_cap==n,'M_infinity':maxout,'formula':'floor(1+4 Ev/M_infinity^2)'},'readout_l1_budget4':{'scale':1.,'Ev':ev,'q_cap':l1_cap,'trivial':l1_cap==n,'readout_l1':readout_l1,'formula':'floor(1+4 Ev/||v||_1^2)'}}
    trials=[];witnesses={};eligible_witnesses={}
    for q in qs:
      for balanced in (True,False):
        for signed in (False,True):
            for seed in ([0] if q==n else [0,1]):
                parts=[];objective=0.
                for layer,h in enumerate(hs):
                    groups,signs,error=balanced_cluster(h[probe].T,q,signed,seed*10000+layer,balanced=balanced)
                    parts.append((groups,signs));objective+=error
                cw=compressed_weights(weights,parts);zc=forward(cw,x)
                row={'q':q,'signed':signed,'balanced':balanced,'seed':seed,'clustering_squared_error':objective,'variants':{}}
                for name,variant in variants.items():
                    scaled=z*variant['scale'];other=zc*variant['scale'];diff=np.abs(np.clip(scaled,-.5,.5)-np.clip(other,-.5,.5))
                    score={'max_clipped_difference':float(diff.max()),'mean_clipped_difference':float(diff.mean()),'fraction_above_one_sixteenth':float(np.mean(diff>1/16)),'sign_disagreement_fraction':float(np.mean((scaled>0)!=(other>0))),'eligible_q':q<=variant['q_cap'],'passes_float64':bool(diff.max()<=1/16)}
                    row['variants'][name]=score
                    if q==variant['q_cap']:
                        key=name+('-signed' if signed else '-unsigned')+('-balanced' if balanced else '-unbalanced')
                        if key not in witnesses or score['max_clipped_difference']<witnesses[key]['max_clipped_difference']:
                            witnesses[key]={'q':q,'seed':seed,'signed':signed,'balanced':balanced,'scale':variant['scale'],'max_clipped_difference':score['max_clipped_difference'],'groups':[p[0].tolist() for p in parts],'signs':[p[1].tolist() for p in parts]}
                    if q<=variant['q_cap'] and score['passes_float64']:
                        key=name+('-signed' if signed else '-unsigned')+('-balanced' if balanced else '-unbalanced')
                        if key not in eligible_witnesses or q<eligible_witnesses[key]['q'] or (q==eligible_witnesses[key]['q'] and score['max_clipped_difference']<eligible_witnesses[key]['max_clipped_difference']):
                            eligible_witnesses[key]={'q':q,'seed':seed,'signed':signed,'balanced':balanced,'scale':variant['scale'],'max_clipped_difference':score['max_clipped_difference'],'groups':[p[0].tolist() for p in parts],'signs':[p[1].tolist() for p in parts]}
                trials.append(row)
    target=ar['target'] if 'target' in ar.files else (np.sign(x.sum(axis=1)) if '500-' in path.name or '504-' in path.name else np.sign(np.sign(x.reshape(-1,3,3).sum(axis=2)).sum(axis=1)))
    train=ar['train_indices'] if 'train_indices' in ar.files else ar['train_original_indices']
    trainmargin=target[train]*z[train]
    result={'schema_version':4,'id':ident,'checkpoint':str(path),'checkpoint_sha256':hashlib.sha256(path.read_bytes()).hexdigest(),'N':n,'d':d,'H':len(weights)-1,'domain_size':len(x),'grouping_probe_count':len(probe),'grouping_probe_indices':probe.tolist(),'evaluation':'exhaustive full Boolean cube, float64 only','label_usage':'Labels used only for reporting original training fit, never clustering or choosing compression witnesses.','training_minimum_signed_margin':float(trainmargin.min()),'training_sign_errors':int(np.sum(trainmargin<=0)),'training_all_margins_above_half':bool(np.all(trainmargin>.5)),'raw_output_rms':rms,'raw_absolute_output_quantiles':np.quantile(np.abs(z),[0,.01,.1,.5,.9,1]).tolist(),'variants':variants,'trials':trials,'cap_witnesses':witnesses,'eligible_witnesses':eligible_witnesses,'seconds':time.monotonic()-start}
    destination.parent.mkdir(exist_ok=True);destination.write_text(json.dumps(result,indent=2)+'\n')
    return {'model':ident,'N':n,'cap':cap,'normcap':normcap,'seconds':round(result['seconds'],2),'raw_best_at_cap':{k:v['max_clipped_difference'] for k,v in witnesses.items() if k.startswith('raw')}}

def main():
    parser=argparse.ArgumentParser();parser.add_argument('--workers',type=int,default=3);parser.add_argument('--limit',type=int);parser.add_argument('--match');args=parser.parse_args()
    paths=model_paths()
    if args.match:paths=[x for x in paths if args.match in x[0].name]
    if args.limit:paths=paths[:args.limit]
    with concurrent.futures.ProcessPoolExecutor(max_workers=args.workers) as pool:
        for result in pool.map(run_model,paths):print(json.dumps(result),flush=True)

if __name__=='__main__':main()
