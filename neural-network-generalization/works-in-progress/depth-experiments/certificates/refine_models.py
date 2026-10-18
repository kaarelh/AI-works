#!/usr/bin/env python3
import os
os.environ['OPENBLAS_NUM_THREADS']='1';os.environ['OMP_NUM_THREADS']='1'
import sys,json,time,argparse
from pathlib import Path
import numpy as np
ROOT=Path(__file__).resolve().parent;EXP=ROOT.parent/'experiment';sys.path.insert(0,str(EXP))
import attacks
from explicit_signed import certificate
from finite_tube import clipped_change
C_VALUES=[.001,.003,.01,.03,.0625];CAPS=[.5,1.]


def one(path):
 dest=ROOT/'refined-model-certificates';dest.mkdir(exist_ok=True);target=dest/path.name
 if target.exists():return
 base=json.loads(path.read_text());c=base['config']
 if c.get('input_mode')=='enumerated_boolean':return
 p=attacks.load_model(c);rec=json.loads((EXP/'records'/path.name).read_text());inputs=attacks.audit_inputs(c,rec)
 start=time.monotonic();calls=0
 for group,data in base['groups'].items():
  x=inputs[group][0]
  for row in data['rows']:
   latest=None
   for v in reversed(C_VALUES):
    rr=row['by_c'][str(v)]
    if latest is not None:
     rr['lower']=max(rr['lower'],latest['lower']);rr['upper']=min(rr['upper'],latest['upper']);rr['explicit_refinement_source_c']=latest['c']
    if not all(clipped_change(rr,cap)<=1/16 for cap in CAPS):
     # The large-width refinement budget was fixed before those models finish.
     if c['hidden_depth']>=64:continue
     if c['width']>=512 and c['hidden_depth']>=16 and v>.01:continue
     new=certificate(p,x[row['local_index']],v);calls+=1
     rr['lower']=max(rr['lower'],new['lower']);rr['upper']=min(rr['upper'],new['upper'])
     rr['explicit_refinement_source_c']=v
     if all(clipped_change(rr,cap)<=1/16 for cap in CAPS):latest=dict(new)
    rr['clipped_change_bounds']={str(cap):clipped_change(rr,cap)for cap in CAPS}
    rr['certified']={str(cap):rr['clipped_change_bounds'][str(cap)]<=1/16 for cap in CAPS}
  data['summary']={str(v):{str(cap):sum(row['by_c'][str(v)]['certified'][str(cap)]for row in data['rows'])for cap in CAPS}for v in C_VALUES}
  print(json.dumps(dict(model=c['id'],group=group,summary=data['summary'],explicit_calls=calls,elapsed_seconds=time.monotonic()-start)),flush=True)
 base['explicit_refinement']=dict(calls=calls,elapsed_seconds=time.monotonic()-start,method='Full clean transfers, signed asymmetric scalar remainder ranges, intersections with previous bounds; float64 sufficient tests.')
 target.write_text(json.dumps(base,indent=2)+'\n')


def main():
 ap=argparse.ArgumentParser();ap.add_argument('--watch-seconds',type=int,default=0);args=ap.parse_args();deadline=time.monotonic()+args.watch_seconds
 while True:
  for path in sorted((ROOT/'model-certificates').glob('*.json')):
   if '.partial.'not in path.name:one(path)
  if time.monotonic()>=deadline:break
  time.sleep(10)

if __name__=='__main__':main()
