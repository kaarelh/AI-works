#!/usr/bin/env python3
"""Exhaustive finite-radius audit of the actual 512-input Boolean domain."""
import os
os.environ['OPENBLAS_NUM_THREADS']='1'
os.environ['OMP_NUM_THREADS']='1'
from pathlib import Path
import argparse,json,sys,time
import numpy as np
import train,attacks
ROOT=Path(__file__).resolve().parent
sys.path.insert(0,str(ROOT.parent/'certificates'))
from finite_tube import Prepared,clipped_change

def run(path):
    rec=json.loads(path.read_text());c=rec['config'];p=attacks.load_model(c);prep=Prepared(p)
    index=np.arange(512);x=(2*((index[:,None]>>np.arange(9))&1)-1).astype(np.float64)
    y=np.sign(x.sum(axis=1)) if c['task']=='majority9' else np.sign(np.sign(x.reshape(-1,3,3).sum(axis=2)).sum(axis=1))
    trainidx=np.load(ROOT/'models'/f"{c['id']}.npz")['train_original_indices'];istrain=np.isin(index,trainidx)
    z=train.predict(p,x);suffix=1.;total=1.
    for norm in reversed(prep.norms):suffix*=norm*norm;total+=suffix
    gain=float(np.sqrt((1+prep.Ev*total)/(1+prep.H*prep.Ev)))
    constants=sorted(set([.001,.003,.01,.03,.0625,.001/c['hidden_depth']]),reverse=True)
    rows=[];start=time.monotonic()
    for j,xx in enumerate(x):
        clean=None;larger_good=None;byc={}
        for const in constants:
            if larger_good is not None:
                bound=dict(larger_good);bound['c']=const;bound['method']='reuse certificate from larger noise ball'
            else:
                bound=dict(c=const,clean_output=float(z[j]),lower=float(z[j]-const*gain),upper=float(z[j]+const*gain),
                           source_c=const,method='global spectral bound plus clipping')
                if clipped_change(bound,.5)>1/16:
                    if clean is None:clean=prep.clean(xx)
                    local=prep.certify(xx,const,clean);local.pop('per_layer_tube_norms',None)
                    if clipped_change(local,.5)<clipped_change(bound,.5):
                        bound=local;bound.update(source_c=const,method='finite-tube local bound')
            bound['clipped_change_bound']=clipped_change(bound,.5);bound['certified']=bound['clipped_change_bound']<=1/16
            byc[str(const)]=bound
            if bound['certified']:larger_good=bound
        rows.append(dict(input_index=j,training_input=bool(istrain[j]),target=int(y[j]),clean_output=float(z[j]),by_c=byc))
        if (j+1)%128==0:print(json.dumps(dict(model=c['id'],completed_inputs=j+1,seconds=time.monotonic()-start)),flush=True)
    summaries=[]
    for const in constants:
        passed=sum(r['by_c'][str(const)]['certified'] for r in rows)
        summaries.append(dict(c=const,calibration='inverse-depth' if const==.001/c['hidden_depth'] else 'original-fixed',
            input_count=512,certified=passed,all_boolean_inputs_certified=passed==512,
            global_sufficient=const*gain<=1/16,global_raw_change_bound=const*gain,
            unresolved_indices=[r['input_index'] for r in rows if not r['by_c'][str(const)]['certified']]))
    output=dict(config=c,train=rec['train'],test=rec['test'],global_gain_ratio=gain,
                global_sufficient_by_c={str(a):a*gain<=1/16 for a in constants},summaries=summaries,rows=rows,
                full_cube_accuracy=float(np.mean(y*z>0)),full_cube_minimum_signed_margin=float(np.min(y*z)),
                elapsed_seconds=time.monotonic()-start,
                qualification='All512 Boolean inputs are enumerated, so domain coverage is exhaustive. Finite-radius sufficient inequalities are evaluated in float64, not outward interval arithmetic. Exact selected verifications are separate; unresolved does not mean false.')
    dest=ROOT/'full-cube';dest.mkdir(exist_ok=True);(dest/path.name).write_text(json.dumps(output,indent=2)+'\n')
    print(json.dumps(dict(model=c['id'],summary=summaries,seconds=output['elapsed_seconds'])),flush=True)

def main():
    ap=argparse.ArgumentParser();ap.add_argument('--watch-seconds',type=int,default=0);args=ap.parse_args();deadline=time.monotonic()+args.watch_seconds
    while True:
        for path in sorted((ROOT/'records').glob('50[0-5]-*.json')):
            if not (ROOT/'full-cube'/path.name).exists():run(path)
        if time.monotonic()>=deadline:break
        time.sleep(10)

if __name__=='__main__':main()
