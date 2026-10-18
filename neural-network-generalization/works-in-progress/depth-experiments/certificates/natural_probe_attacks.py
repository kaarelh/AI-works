#!/usr/bin/env python3
import os
os.environ['OPENBLAS_NUM_THREADS']='1';os.environ['OMP_NUM_THREADS']='1'
import sys,json,time
from pathlib import Path
import numpy as np
ROOT=Path(__file__).resolve().parent;EXP=ROOT.parent/'experiment';sys.path.insert(0,str(EXP))
import train,attacks
from verify_witness import verify


def run(index):
 path=next((EXP/'records').glob(f'{index:03d}-*.json'));rec=json.loads(path.read_text());c=rec['config'];p=attacks.load_model(c)
 xx,yy,_,xt,yt,original=train.dataset(c,dtype=np.float64)
 prob=np.mean(xx>=0,axis=0);del xx,yy
 rng=np.random.default_rng(60000+index);meanmatched=np.where(rng.random((64,c['dimension']))<prob,1.,-1.)
 z=np.array(rec['per_test_output']);i0=np.flatnonzero((yt<0)&(z<0))[0];i1=np.flatnonzero((yt>0)&(z>0))[0]
 left=0.;right=1.
 for _ in range(60):
  t=(left+right)/2;mid=(1-t)*xt[i0]+t*xt[i1];value=float(train.forward(p,mid[None,:])[0])
  if value<0:left=t
  else:right=t
 t=(left+right)/2;mid=(1-t)*xt[i0]+t*xt[i1]
 points=np.concatenate((meanmatched,mid[None,:]));labels=np.array(['mean_matched_boolean']*64+['image_interpolation'])
 ev=c['width']*np.sum(p[-1]**2);records=[];verified_groups=set();begin=time.monotonic()
 out=dict(config=c,train=rec['train'],test=rec['test'],pixel_probability=prob.tolist(),
  interpolation=dict(first_negative_test_index=int(i0),first_positive_test_index=int(i1),negative_original_index=int(original[i0]),positive_original_index=int(original[i1]),mixing_t=float(t),clean_output=float(train.forward(p,mid[None,:])[0])),records=records)
 np.savez(ROOT/f'natural-probe-inputs-{index:03d}.npz',inputs=points,pixel_probabilities=prob,interpolation_endpoints=xt[[i0,i1]])
 for const in [.001,.003,.01]:
  radius=const/np.sqrt(1+c['hidden_depth']*ev);a=attacks.attack(p,points,radius,70000+1000*index+int(1e6*const))
  baseline=np.clip(a['clean'],-.5,.5);up=np.abs(np.clip(a['maximum'],-.5,.5)-baseline);down=np.abs(np.clip(a['minimum'],-.5,.5)-baseline);change=np.maximum(up,down)
  for group in ['mean_matched_boolean','image_interpolation']:
   ids=np.flatnonzero(labels==group);j=ids[np.argmax(change[ids])];choose=up[j]>down[j]
   eta=np.sqrt(c['width'])*(a['u_max'][:,j]if choose else a['u_min'][:,j]);output=a['v_max'][j]if choose else a['v_min'][j]
   row=dict(group=group,c=const,count=len(ids),numerical_violation_count=int(np.sum(change[ids]>1/16)),maximum_numerical_change=float(change[j]),local_witness_index=int(j),per_input_numerical_changes=change[ids].tolist())
   if change[j]>1/16:
    name=f'natural-probe-{index:03d}-{group}-c{const}'
    np.savez(ROOT/(name+'.npz'),input=points[j],hidden_noise=eta,output_noise=output)
    if group not in verified_groups:
     row['verification']=verify(p,points[j],eta,const,output)
     assert row['verification']['exact_rational_budget_pass']and row['verification']['clipped']['0.5']['violation']
     verified_groups.add(group)
   records.append(row);print(json.dumps(dict(model=c['id'],**row)),flush=True)
  out['elapsed_seconds']=time.monotonic()-begin
  (ROOT/f'natural-probe-{index:03d}.json').write_text(json.dumps(out,indent=2)+'\n')

if __name__=='__main__':
 for i in [4,16,28,32]:run(i)
