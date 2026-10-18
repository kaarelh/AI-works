#!/usr/bin/env python3
"""Practical activation-rounding diagnostics, not adversarial certificates."""
import os
os.environ['OPENBLAS_NUM_THREADS']='1'
import argparse,datetime,json,time
import numpy as np
import train,attacks
ROOT=train.ROOT

def rounded(x,kind):
    if kind=='float16':return x.astype(np.float16).astype(np.float64)
    y=x.astype(np.float32);bits=y.view(np.uint32)
    return ((bits+np.uint32(0x7fff)+((bits>>16)&1))&np.uint32(0xffff0000)).view(np.float32).astype(np.float64)

def run(path):
    rec=json.loads(path.read_text());c=rec['config'];p=attacks.load_model(c)
    _,_,_,x,y,indices=train.dataset(c,dtype=np.float64);clean=np.array(rec['per_test_output']);ev=rec['readout_energy'];rows=[]
    for kind in ['float16','bfloat16']:
        raw_outputs=[];quant_outputs=[];hidden_norms=[];full_norms=[]
        for offset in range(0,len(x),256):
            xx=x[offset:offset+256];h=np.column_stack((xx,np.ones(len(xx))));sq=np.zeros(len(xx))
            for w in p[:-1]:
                a=h@w;t=np.tanh(a) if c.get('activation','tanh')=='tanh' else np.maximum(a,0)
                h=rounded(t,kind);sq+=np.sum((h-t)**2,axis=1)/c['width']
            z=h@p[-1];q=rounded(z,kind)
            raw_outputs.extend(z);quant_outputs.extend(q);hidden_norms.extend(np.sqrt(sq));full_norms.extend(np.sqrt(sq+(q-z)**2))
        for mode,z,norms in [('hidden_only',np.array(raw_outputs),np.array(hidden_norms)),('hidden_and_output',np.array(quant_outputs),np.array(full_norms))]:
            row=dict(format=kind,mode=mode,count=len(x),nonfinite_count=int(np.sum(~np.isfinite(z))),
                     clean_errors=rec['test']['errors'],perturbed_errors=int(np.sum(y*z<=0)),
                     sign_changes=int(np.sum((clean>0)!=(z>0))),zero_outputs=int(np.sum(z==0)),
                     maximum_required_radius_constant=float(np.max(norms)*np.sqrt(1+c['hidden_depth']*ev)),
                     norm_quantiles=np.quantile(norms,[0,.5,.9,.99,1]).tolist(),
                     radius_grid_fractions={str(a):float(np.mean(norms<=a/np.sqrt(1+c['hidden_depth']*ev))) for a in [.001,.003,.01,.03,.0625]})
            for cap in [.5,1.]:
                delta=np.abs(np.clip(z,-cap,cap)-np.clip(clean,-cap,cap))
                row[f'cap{cap:g}_max_change']=float(np.max(delta));row[f'cap{cap:g}_violations']=int(np.sum(delta>1/16))
            rows.append(row)
    out=dict(config=c,training_eligible=rec['train']['all_margins_above_half'],rows=rows,
             qualification='One deterministic perturbation map performat, evaluated onallheldoutinputs. Weightsunchanged. Successfulrounding is not a proof for all allowed perturbations. Realizednoise budgets explicitlyrecorded.')
    dest=ROOT/'quantization';dest.mkdir(exist_ok=True);(dest/path.name).write_text(json.dumps(out,indent=2)+'\n')
    print(json.dumps(dict(id=c['id'],rows=rows)),flush=True)

def main():
    ap=argparse.ArgumentParser();ap.add_argument('--declare',action='store_true');ap.add_argument('--watch-seconds',type=int,default=0);args=ap.parse_args()
    if args.declare:
        p=ROOT/'quantization-protocol.json'
        if p.exists():raise RuntimeError('Alreadydeclared')
        p.write_text(json.dumps(dict(at_utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),status='Declared before any round3 quantization results; training/adversarialmetrics partly visible.',formats=['IEEEfloat16','bfloat16'],modes=['hiddenactivationsonly','hiddenactivationsandfinalrawoutput'],weights='unchanged exactsavedweights',arithmetic='Float64matmul/tanh thennearestformatrounding; bfloat16viafloat32ties-to-evenbitrounding.',scope='Allofficialheldouttestexamples for each retained model. No retraining orbitsselection byoutcome. Compareactualnormalizednoisetoallfivefixedradii.',interpretation='Deterministicrounding is not an adversarial certificate.'),indent=2)+'\n');print(p);return
    assert (ROOT/'quantization-protocol.json').exists();deadline=time.monotonic()+args.watch_seconds
    while True:
        for path in sorted((ROOT/'records').glob('*.json')):
            if not (ROOT/'quantization'/path.name).exists():run(path)
        if time.monotonic()>=deadline:break
        time.sleep(10)

if __name__=='__main__':main()
