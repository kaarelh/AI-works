#!/usr/bin/env python3
"""Joint adversarial postactivation AND scalar-output perturbations.

Search both monotone raw-output directions, avoiding the artificial zero
gradient of a clipped score on a saturated clean output. Successful searches
are numerical witnesses until separately interval verified. Failed searches
never establish support membership.
"""
import os
os.environ['OPENBLAS_NUM_THREADS']='1'
os.environ['OMP_NUM_THREADS']='1'
import argparse,json,time
from pathlib import Path
import numpy as np
import train

ROOT=Path(__file__).resolve().parent

def load_model(c):
    a=np.load(ROOT/'models'/f"{c['id']}.npz")
    return [a[f'w{j}'].astype(np.float64) for j in range(c['hidden_depth']+1)]

def audit_inputs(c,rec):
    _,_,_,xt,yt,original=train.dataset(c,dtype=np.float64)
    uniform=np.random.default_rng(30000+c['seed']).choice(len(xt),min(128,len(xt)),replace=False)
    boundary=np.argsort(np.abs(rec['per_test_output']),kind='stable')[:16]
    cube=np.random.default_rng(40000+c['index']).choice([-1.,1.],size=(64,c['dimension']))
    return dict(heldout_uniform=(xt[uniform],yt[uniform],uniform,original[uniform]),
                heldout_boundary=(xt[boundary],yt[boundary],boundary,original[boundary]),
                random_cube=(cube,np.full(64,np.nan),np.arange(64),np.full(64,-1)))

def noise_gradient(p,x,hidden_noise,output_noise,activation='tanh'):
    z,_,ts=train.forward(p,x,hidden_noise,output_noise,cache=True,activation=activation)
    dh=np.broadcast_to(p[-1],(len(x),len(p[-1])));gs=[None]*len(ts)
    for j in reversed(range(len(ts))):
        gs[j]=dh
        if j:dh=(dh*(1-ts[j]*ts[j] if activation=='tanh' else ts[j]>0))@p[j].T
    return z,np.stack(gs)

def attack(p,x,radius,seed,activation='tanh'):
    h=len(p)-1;n=len(p[-1]);m=len(x);rng=np.random.default_rng(seed)
    clean=train.forward(p,x,activation=activation);budget=radius*(1-1e-7)
    # Store the two output extremes; either cap can then be evaluated exactly.
    minima=clean.copy();maxima=clean.copy();u_min=np.zeros((h,m,n));u_max=u_min.copy();v_min=np.zeros(m);v_max=np.zeros(m)
    for direction in [-1.,1.]:
        for restart in range(2):
            u=np.zeros((h,m,n)) if restart==0 else rng.normal(size=(h,m,n))
            v=np.zeros(m) if restart==0 else rng.normal(size=m)
            length=np.sqrt(np.sum(u*u,axis=(0,2))+v*v)
            factor=np.minimum(1,budget/np.maximum(length,1e-300));u*=factor[None,:,None];v*=factor
            for step in range(101):
                z,g=noise_gradient(p,x,np.sqrt(n)*u,v,activation=activation)
                smaller=z<minima;larger=z>maxima
                minima[smaller]=z[smaller];maxima[larger]=z[larger]
                u_min[:,smaller]=u[:,smaller];v_min[smaller]=v[smaller]
                u_max[:,larger]=u[:,larger];v_max[larger]=v[larger]
                if step==100:break
                gu=np.sqrt(n)*g;length=np.sqrt(np.sum(gu*gu,axis=(0,2))+1)
                u+=direction*.08*budget*gu/length[None,:,None];v+=direction*.08*budget/length
                length=np.sqrt(np.sum(u*u,axis=(0,2))+v*v)
                factor=np.minimum(1,budget/np.maximum(length,1e-300));u*=factor[None,:,None];v*=factor
    return dict(clean=clean,minimum=minima,maximum=maxima,u_min=u_min,u_max=u_max,v_min=v_min,v_max=v_max)

def run(path):
    rec=json.loads(path.read_text());c=rec['config'];p=load_model(c);inputs=audit_inputs(c,rec)
    groups=[];xs=[];targets=[];indices=[]
    for group,(x,y,idx,orig) in inputs.items():
        q=16;groups.extend([group]*q);xs.extend(x[:q]);targets.extend(y[:q]);indices.extend(idx[:q])
    x=np.array(xs);y=np.array(targets);groups=np.array(groups);indices=np.array(indices)
    ev=float(c['width']*np.sum(p[-1]**2));start=time.monotonic();records=[];witnesses=[]
    dest=ROOT/'attacks';dest.mkdir(exist_ok=True)
    for const in [.001,.003,.01,.03,.0625]:
        radius=const/np.sqrt(1+c['hidden_depth']*ev)
        result=attack(p,x,radius,60000+1000*c['index']+round(1000000*const),activation=c.get('activation','tanh'))
        for cap in [.5,1.]:
            base=np.clip(result['clean'],-cap,cap)
            down=np.abs(np.clip(result['minimum'],-cap,cap)-base)
            up=np.abs(np.clip(result['maximum'],-cap,cap)-base)
            choose_up=up>down;change=np.maximum(up,down)
            for group in ['heldout_uniform','heldout_boundary','random_cube']:
                mask=groups==group;where=np.flatnonzero(mask);j=where[np.argmax(change[mask])]
                row=dict(radius_constant=const,radius=radius,score_cap=cap,group=group,count=int(np.sum(mask)),
                         violations_found=int(np.sum(change[mask]>1/16+1e-10)),maximum_change=float(np.max(change[mask])),
                         input_indices=indices[mask].tolist(),per_input_change=change[mask].tolist())
                records.append(row)
                # Retain every observed violating tuple, so pointwise outcome
                # tables can be independently rechecked rather than inferring
                # failure from an unsuccessful sufficient certificate.
                for j in where[change[mask]>1/16+1e-10]:
                    hidden=np.sqrt(c['width'])*(result['u_max'][:,j] if choose_up[j] else result['u_min'][:,j])
                    out=result['v_max'][j] if choose_up[j] else result['v_min'][j]
                    noisy=train.forward(p,x[j:j+1],hidden[:,None,:],np.array([out]),activation=c.get('activation','tanh'))[0]
                    norm=float(np.sqrt(np.sum(hidden*hidden)/c['width']+out*out))
                    actual=float(abs(np.clip(noisy,-cap,cap)-np.clip(result['clean'][j],-cap,cap)))
                    verified=bool(norm<radius and actual>1/16+1e-10)
                    name=f"{c['id']}-c{const:g}-cap{cap:g}-{group}-i{indices[j]}"
                    np.savez_compressed(dest/(name+'.npz'),input=x[j],hidden_noise=hidden,output_noise=np.array(out))
                    witnesses.append(dict(name=name,radius_constant=const,score_cap=cap,group=group,
                                          input_index=int(indices[j]),target=float(y[j]) if np.isfinite(y[j]) else None,
                                          clean_output=float(result['clean'][j]),perturbed_output=float(noisy),
                                          clipped_change=actual,noise_norm=norm,required_radius=radius,
                                          float64_recheck_pass=verified))
        print(json.dumps(dict(id=c['id'],radius_constant=const,elapsed_seconds=time.monotonic()-start,
                              found_witnesses=len(witnesses))),flush=True)
    output=dict(config=c,training_eligible=rec['train']['all_margins_above_half'],test_accuracy=rec['test']['accuracy'],
                audit_protocol='16 uniform heldout +16 lowest-clean-|z| heldout +16 random Boolean inputs;100steps2restarts,both output directions,joint hidden/output noise.',
                records=records,witnesses=witnesses,witness_storage='Every observed pointwise violation has its own explicit saved perturbation and strict-budget recheck.',elapsed_seconds=time.monotonic()-start,
                qualification='Float64 strict-budget witnesses; designated examples require subsequent exact/interval verification. No attack found does not establish robustness.')
    (dest/f"{c['id']}.json").write_text(json.dumps(output,indent=2)+'\n')

def main():
    ap=argparse.ArgumentParser();ap.add_argument('--watch-seconds',type=int,default=0);ap.add_argument('--indices');args=ap.parse_args()
    deadline=time.monotonic()+args.watch_seconds;done=set()
    while True:
        files=sorted((ROOT/'records').glob('*.json'))
        if args.indices:
            chosen=set(map(int,args.indices.split(',')));files=[p for p in files if int(p.name[:3]) in chosen]
        for path in files:
            existing=ROOT/'attacks'/path.name
            if path.stem in done:continue
            if existing.exists() and 'witness_storage' in json.loads(existing.read_text()):continue
            run(path);done.add(path.stem)
        if time.monotonic()>=deadline:break
        time.sleep(10)

if __name__=='__main__':main()
