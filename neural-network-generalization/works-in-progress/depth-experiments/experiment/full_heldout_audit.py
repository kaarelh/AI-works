#!/usr/bin/env python3
"""Complete official held-out coverage for a fixed exploratory model cohort."""
import os
os.environ['OPENBLAS_NUM_THREADS']='1'
os.environ['OMP_NUM_THREADS']='1'
from pathlib import Path
import datetime,json,sys,time
import numpy as np
import train,attacks
ROOT=Path(__file__).resolve().parent
sys.path.insert(0,str(ROOT.parent/'certificates'))
from finite_tube import Prepared,clipped_change

def main():
    protocol=ROOT/'full-heldout-protocol.json'
    if not protocol.exists():
        protocol.write_text(json.dumps(dict(declared_at_utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),
            status='Exploratory follow-up after sampled-point results and global counterexamples were known. Existing global saturation counts were inspected; additional local results were not.',
            models=[8,9,105,107],constants=[.001,.003],score_cap=.5,tolerance=1/16,
            scope='EVERY official held-out image for each selected model. Models008/009 are both original deep-SGD seeds;105/107 are both H16 fullMNIST even/odd widths. No replacement or outcome-based omission.',
            method='Apply existing global raw-output bound and clipping first, then reuse matching saved pointwise enclosures, then evaluate the finite-tube certificate for remaining points. All inconclusive points retained. Float64 sufficient checks; no global-support inference from a finite test set.'),indent=2)+'\n')
    outdir=ROOT/'full-heldout';outdir.mkdir(exist_ok=True)
    for index in [5,8,9,29,105,107]:
        paths=list((ROOT/'records').glob(f'{index:03d}-*.json'))
        if not paths:continue
        rec=json.loads(paths[0].read_text());c=rec['config'];ident=c['id'];dest=outdir/f'{ident}.json'
        if dest.exists():continue
        certpath=ROOT.parent/'certificates'/'model-certificates'/f'{ident}.json'
        p=attacks.load_model(c);prep=Prepared(p)
        suffix=1.;total=1.
        for norm in reversed(prep.norms):suffix*=norm*norm;total+=suffix
        gain=float(np.sqrt((1+prep.Ev*total)/(1+prep.H*prep.Ev)))
        cert=dict(global_gain_ratio=gain,groups={})
        if certpath.exists():cert=json.loads(certpath.read_text())
        refined=ROOT.parent/'certificates'/'refined-model-certificates'/certpath.name
        if refined.exists():cert=json.loads(refined.read_text())
        saved={point['source_index']:point for group in ['heldout_uniform','heldout_boundary'] for point in cert['groups'].get(group,{}).get('rows',[])}
        _,_,_,x,y,original=train.dataset(c,dtype=np.float64)
        z=np.array(rec['per_test_output']);rows=[];start=time.monotonic()
        for const in [.001,.003]:
            bound=const*cert['global_gain_ratio'];lo=z-bound;hi=z+bound
            globalchange=np.maximum(np.abs(np.clip(lo,-.5,.5)-np.clip(z,-.5,.5)),np.abs(np.clip(hi,-.5,.5)-np.clip(z,-.5,.5)))
            points=[]
            for j in range(len(x)):
                change=float(globalchange[j]);method='global raw bound plus clipping';lower=float(lo[j]);upper=float(hi[j])
                if change>1/16:
                    candidate=saved.get(j,{}).get('by_c',{}).get(str(const))
                    if candidate is None or not candidate['certified']['0.5']:
                        candidate=prep.certify(x[j],const,prep.clean(x[j]));method='new finite-tube bound'
                    else:method='reused saved pointwise bound'
                    candidatechange=clipped_change(candidate,cap=.5)
                    if candidatechange<change:
                        change=float(candidatechange);lower=float(candidate['lower']);upper=float(candidate['upper'])
                    else:method='global raw bound plus clipping'
                points.append(dict(index=j,original_index=int(original[j]),clean_output=float(z[j]),lower=lower,upper=upper,
                                   score_change_bound=change,certified=change<=1/16,method=method))
            rows.append(dict(c=const,count=len(points),certified=sum(q['certified'] for q in points),
                             methods={k:sum(q['method']==k for q in points) for k in sorted({q['method'] for q in points})},
                             unresolved_indices=[q['index'] for q in points if not q['certified']],points=points))
        result=dict(config=c,train=rec['train'],test=rec['test'],rows=rows,elapsed_seconds=time.monotonic()-start,
                    qualification='Float64 sufficient inequalities on the complete finite held-out set. No inference of robustness at every input. Selected exact global/negative proofs are separate.')
        dest.write_text(json.dumps(result,indent=2)+'\n')
        print(json.dumps(dict(model=ident,rows=[{k:v for k,v in row.items() if k!='points'} for row in rows],seconds=result['elapsed_seconds'])),flush=True)

if __name__=='__main__':main()
