#!/usr/bin/env python3
"""Real shuffled minibatch training; every fixed-protocol run is retained."""
import os
os.environ['OPENBLAS_NUM_THREADS']='1'
os.environ['OMP_NUM_THREADS']='1'
import argparse,concurrent.futures,json,time,traceback
from pathlib import Path
import numpy as np

ROOT=Path(__file__).resolve().parent

def dataset(c,dtype=np.float32):
    if c['input_mode']=='enumerated_boolean':
        d=c['dimension'];indices=np.arange(2**d)
        cube=(2*((indices[:,None]>>np.arange(d))&1)-1).astype(np.float32)
        label=(np.sign(cube.sum(axis=1)) if c['task']=='majority9'
               else np.sign(np.sign(cube.reshape(-1,3,3).sum(axis=2)).sum(axis=1))).astype(np.float32)
        split=np.random.default_rng(c['split_seed']).permutation(len(cube));result=[]
        for selected in [split[:c['training_cube_count']],split[c['training_cube_count']:]]:
            result.extend([cube[selected].astype(dtype),label[selected].astype(dtype),selected])
        return tuple(result)
    name='mnist' if c['task'].startswith('mnist') else 'fashion'
    labels=[3,8] if name=='mnist' else [0,6]
    saved=np.load(ROOT/'data'/f'{name}.npz');result=[]
    for split in ['train','test']:
        original=np.arange(len(saved[split+'_labels'])) if c['task'].endswith('evenodd') else np.flatnonzero(np.isin(saved[split+'_labels'],labels))
        raw=saved[split+'_images'][original].reshape(len(original),-1)
        # Freeze the actual float32 training feature map, then change arithmetic
        # precision without changing the represented input values.
        x=(np.where(raw>=128,1.,-1.).astype(np.float32) if c['input_mode']=='boolean'
           else raw.astype(np.float32)/np.float32(127.5)-np.float32(1)).astype(dtype)
        yy=saved[split+'_labels'][original]
        y=np.where(yy%2==0,1.,-1.).astype(dtype) if c['task'].endswith('evenodd') else np.where(yy==labels[1],1.,-1.).astype(dtype)
        result.extend([x,y,original])
    return tuple(result)

def forward(p,x,eta=None,output_noise=None,cache=False,activation='tanh'):
    h=np.empty((len(x),x.shape[1]+1),dtype=x.dtype);h[:,:-1]=x;h[:,-1]=1
    hs=[h];ts=[]
    for j,w in enumerate(p[:-1]):
        a=h@w;t=np.tanh(a) if activation=='tanh' else np.maximum(a,0);h=t if eta is None else t+eta[j]
        hs.append(h);ts.append(t)
    z=h@p[-1]
    if output_noise is not None:z=z+output_noise
    return (z,hs,ts) if cache else z

def predict(p,x,batch_size=512,activation='tanh'):
    return np.concatenate([forward(p,x[i:i+batch_size],activation=activation) for i in range(0,len(x),batch_size)])

def initial(c):
    rng=np.random.default_rng(10000+c['seed']);n=c['width'];h=c['hidden_depth']
    p=[rng.normal(size=(c['dimension']+1,n))*np.sqrt(2 if c.get('activation')=='relu' else 1)/np.sqrt(c['dimension']+1)]
    for j in range(h-1):
        q,r=np.linalg.qr(rng.normal(size=(n,n)));p.append(c['initial_gain']*q*np.sign(np.diag(r))[None,:])
    p.append(rng.normal(size=n)/np.sqrt(n))
    return [w.astype(np.float32) for w in p]

def evaluate(p,x,y,activation='tanh'):
    z=predict(p,x,activation=activation);signed=y*z
    return dict(count=len(y),errors=int(np.sum(signed<=0)),accuracy=float(np.mean(signed>0)),
                minimum_signed_margin=float(np.min(signed)),fraction_margin_above_half=float(np.mean(signed>.5)),
                all_margins_above_half=bool(np.all(signed>.5)),
                logistic_loss=float(np.mean(np.logaddexp(0,-signed))),
                absolute_output_quantiles=np.quantile(np.abs(z),[0,.01,.05,.1,.5,.9,1]).tolist()),z

def train_one(c):
    start=time.monotonic();x,y,tri,xt,yt,tei=dataset(c);p=initial(c)
    if c.get('initial_model_id') is not None:
        warm=np.load(ROOT/'models'/f"{c['initial_model_id']}.npz")
        p=[warm[f'w{j}'].copy() for j in range(c['hidden_depth']+1)]
    moms=[np.zeros_like(w) for w in p];vars_=[np.zeros_like(w) for w in p]
    rng=np.random.default_rng(20000+c['seed']);step=0;history=[];failure=None;activation=c.get('activation','tanh')
    for _ in range(c.get('shuffle_skip_epochs',0)):rng.permutation(len(x))
    progress=ROOT/'progress'/f"{c['id']}.jsonl";progress.parent.mkdir(exist_ok=True)
    for epoch in range(1,c['epochs']+1):
        idx=rng.permutation(len(x));lr=c['learning_rate']*(1 if epoch<=40 else (.2 if epoch<=50 else .04))
        if c.get('learning_rate_schedule') is not None:
            lr=next(rate for through,rate in c['learning_rate_schedule'] if epoch<=through)
        for offset in range(0,len(x),c['batch_size']):
            ii=idx[offset:offset+c['batch_size']];xb=x[ii];yb=y[ii];z,hs,ts=forward(p,xb,cache=True,activation=activation)
            a=-yb*z;sigmoid=np.exp(-np.logaddexp(0,-a));dz=-yb*sigmoid/len(ii)
            grads=[None]*len(p);grads[-1]=hs[-1].T@dz+c['weight_decay']*p[-1]
            dh=dz[:,None]*p[-1]
            for j in reversed(range(c['hidden_depth'])):
                derivative=1-ts[j]*ts[j] if activation=='tanh' else ts[j]>0
                da=dh*derivative;grads[j]=hs[j].T@da+c['weight_decay']*p[j]
                if j:dh=da@p[j].T
            step+=1
            for j,g in enumerate(grads):
                if c['optimizer']=='adam':
                    moms[j]*=.9;moms[j]+=.1*g;vars_[j]*=.999;vars_[j]+=.001*g*g
                    p[j]-=lr*(moms[j]/(1-.9**step))/(np.sqrt(vars_[j]/(1-.999**step))+1e-8)
                elif c['optimizer']=='momentum_sgd':moms[j]*=.9;moms[j]+=g;p[j]-=lr*moms[j]
                else:p[j]-=lr*g
            if not np.isfinite(z).all():failure='Nonfinite training forward evaluation';break
        if c.get('internal_spectral_projection') is not None and failure is None:
            # An explicit training intervention, fixed in its own protocol.
            # The first layer and readout are not projected. This runs after
            # every epoch, including after the final gradient update.
            for j in range(1,c['hidden_depth']):
                u,s,vt=np.linalg.svd(p[j],full_matrices=False)
                p[j]=((u*np.minimum(s,c['internal_spectral_projection']))@vt).astype(np.float32)
        metric=dict(epoch=epoch,steps=step,elapsed_seconds=time.monotonic()-start,
                    last_batch_loss=float(np.mean(np.logaddexp(0,-yb*z))),failure=failure)
        with progress.open('a') as f:f.write(json.dumps(metric)+'\n')
        if epoch in [1,10,30,60,120,180] or epoch==c['epochs'] or failure:
            trainmetric,_=evaluate(p,x,y,activation=activation);history.append(dict(epoch=epoch,train=trainmetric,elapsed_seconds=time.monotonic()-start))
        if failure:break
    train_seconds=time.monotonic()-start
    (ROOT/'models').mkdir(exist_ok=True);(ROOT/'records').mkdir(exist_ok=True)
    np.savez_compressed(ROOT/'models'/f"{c['id']}.npz",**{f'w{j}':w for j,w in enumerate(p)},train_original_indices=tri,test_original_indices=tei)
    p64=[w.astype(np.float64) for w in p];trainmetric,z=evaluate(p64,x.astype(np.float64),y.astype(np.float64),activation=activation);testmetric,zt=evaluate(p64,xt.astype(np.float64),yt.astype(np.float64),activation=activation)
    rec=dict(config=c,history=history,train=trainmetric,test=testmetric,training_failure=failure,
             readout_energy=float(c['width']*np.sum(p64[-1]**2)),train_elapsed_seconds=train_seconds,
             total_elapsed_seconds=time.monotonic()-start,per_train_output=z.tolist(),per_test_output=zt.tolist(),
             qualification='True minibatch optimization, float32 trained weights saved exactly; final reported predictions evaluated in float64. No rescaling. No test tuning.')
    target=ROOT/'records'/f"{c['id']}.json";target.write_text(json.dumps(rec,indent=2)+'\n')
    return {k:rec[k] for k in ['config','train','test','training_failure','readout_energy','train_elapsed_seconds','total_elapsed_seconds']}

def main():
    ap=argparse.ArgumentParser();ap.add_argument('--workers',type=int,default=3);ap.add_argument('--indices');ap.add_argument('--protocol',default='predeclared-protocol.json');args=ap.parse_args()
    cs=json.loads((ROOT/args.protocol).read_text())['configs']
    if args.indices:
        selected=set(map(int,args.indices.split(',')));cs=[c for c in cs if c['index'] in selected]
    cs=[c for c in cs if not (ROOT/'records'/f"{c['id']}.json").exists()]
    # Interleave datasets while preserving all fixed runs; this affects scheduling only.
    cs.sort(key=lambda c:(c['cohort'],c['hidden_depth'],c['optimizer'],c['seed'],c['task']))
    with concurrent.futures.ProcessPoolExecutor(max_workers=args.workers) as pool:
        fs={pool.submit(train_one,c):c for c in cs}
        for future in concurrent.futures.as_completed(fs):
            c=fs[future]
            try:print(json.dumps(future.result()),flush=True)
            except Exception:
                (ROOT/'failures').mkdir(exist_ok=True)
                (ROOT/'failures'/f"{c['id']}.txt").write_text(traceback.format_exc());raise

if __name__=='__main__':main()
