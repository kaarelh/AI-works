#!/usr/bin/env python3
import os
os.environ['OPENBLAS_NUM_THREADS']='1';os.environ['OMP_NUM_THREADS']='1'
import sys,json,time,argparse
from pathlib import Path
import numpy as np
ROOT=Path(__file__).resolve().parent;EXPERIMENT=ROOT.parent/'experiment'
sys.path.insert(0,str(EXPERIMENT))
import attacks
from finite_tube import Prepared,clipped_change
C_VALUES=[.001,.003,.01,.03,.0625]
CAPS=[.5,1.]


def global_gain(prep):
 suffix=1.;total=1.
 for s in reversed(prep.norms):suffix*=s*s;total+=suffix
 return np.sqrt((1+prep.Ev*total)/(1+prep.H*prep.Ev))


def one(path):
 rec=json.loads(path.read_text());c=rec['config'];dest=ROOT/'model-certificates';dest.mkdir(exist_ok=True)
 if c.get('activation','tanh')!='tanh' or c.get('input_mode')=='enumerated_boolean':return
 target=dest/path.name
 if target.exists():return
 start=time.monotonic();p=attacks.load_model(c);prep=Prepared(p);gg=global_gain(prep)
 groups=attacks.audit_inputs(c,rec)
 out=dict(config=c,train=rec['train'],test=rec['test'],global_gain_ratio=float(gg),
  global_sufficient_by_c={str(v):bool(v*gg<=1/16)for v in C_VALUES},
  method='Clean reverse adjoints, exact scalar remainder extrema, forward nonlinear/tube L2 radius and coordinate enclosures; pointwise finite-noise bounds.',
  qualification='Float64 evaluation of exact-real sufficient inequalities, not interval-rounded. All cases retained. Maincap.5,comparisoncap1; global certificate distinguished from data/cube probes.',groups={})
 for group,(x,y,indices,original)in groups.items():
  if (c['width']>=512 and group=='heldout_uniform') or (c['hidden_depth']>=64 and group in ['heldout_uniform','random_cube']):
   x=x[:32];y=y[:32];indices=indices[:32];original=original[:32]
  rows=[]
  for j,xx in enumerate(x):
   # Saturated clipped outputs may be certified by a global raw-output bound
   # even when that bound is much larger than1/16. Delay local SVDs until needed.
   z=float(attacks.train.forward(p,xx[None,:])[0]);clean=None
   records={};last_good=None
   for v in reversed(C_VALUES):
    if last_good is not None:
     rr=dict(last_good);rr['c']=v;rr['source_radius_constant']=last_good.get('source_radius_constant',last_good['c'])
    else:
     rr=dict(clean_output=z,lower=z-gg*v,upper=z+gg*v,c=v,source_radius_constant=v,certificate_kind='global scalar spectral gain')
     if not all(clipped_change(rr,cap)<=1/16 for cap in CAPS):
      if clean is None:clean=prep.clean(xx)
      rr=prep.certify(xx,v,clean);rr['source_radius_constant']=v;rr.pop('per_layer_tube_norms',None)
    rr['clipped_change_bounds']={str(cap):clipped_change(rr,cap)for cap in CAPS}
    rr['certified']={str(cap):rr['clipped_change_bounds'][str(cap)]<=1/16 for cap in CAPS}
    records[str(v)]=rr
    if all(rr['certified'].values()):last_good=rr
   rows.append(dict(local_index=j,source_index=int(indices[j]),original_index=int(original[j]),
                    clean_output=z,correct_label=None if not np.isfinite(y[j]) else float(y[j]),by_c=records))
  out['groups'][group]=dict(count=len(rows),rows=rows,summary={str(v):{str(cap):sum(row['by_c'][str(v)]['certified'][str(cap)]for row in rows)for cap in CAPS}for v in C_VALUES})
  print(json.dumps(dict(model=c['id'],group=group,count=len(rows),summary=out['groups'][group]['summary'],elapsed_seconds=time.monotonic()-start)),flush=True)
  target.with_suffix('.partial.json').write_text(json.dumps(out,indent=2)+'\n')
 out['elapsed_seconds']=time.monotonic()-start
 target.write_text(json.dumps(out,indent=2)+'\n');target.with_suffix('.partial.json').unlink(missing_ok=True)


def main():
 ap=argparse.ArgumentParser();ap.add_argument('--indices');ap.add_argument('--watch-seconds',type=int,default=0);args=ap.parse_args();indices=None if not args.indices else set(map(int,args.indices.split(',')));deadline=time.monotonic()+args.watch_seconds
 while True:
  for path in sorted((EXPERIMENT/'records').glob('*.json')):
   if indices is None or int(path.name.split('-')[0])in indices:one(path)
  if time.monotonic()>=deadline:break
  time.sleep(10)

if __name__=='__main__':main()
