#!/usr/bin/env python3
import os
os.environ['OPENBLAS_NUM_THREADS']='1'
from pathlib import Path
import json,time,numpy as np
from finite_tube import Prepared,clipped_change
from explicit_signed import certificate
r=Path(__file__).resolve().parent;a=np.load(next((r.parent/'experiment/models').glob('105-*.npz')));p=[a[k].astype(float)for k in sorted([k for k in a.files if k.startswith('w')and k[1:].isdigit()],key=lambda k:int(k[1:]))];a=np.load(r/'tv-boundary-105-candidates.npz');x=(2*a['pixels'].astype(float)-255)/255;prep=Prepared(p);start=time.monotonic();rows=[]
def band(z):return np.sign(z)*min(.25,max(abs(z)-.25,0))
def changes(rr):return dict(clip_half=clipped_change(rr,.5),margin_band=max(abs(band(rr['lower'])-band(rr['clean_output'])),abs(band(rr['upper'])-band(rr['clean_output']))))
for i,xx in enumerate(x):
 clean=prep.clean(xx);by={};larger=None
 for c in [.003,.001]:
  if larger is not None:rr=dict(larger);rr['requested_c']=c
  else:
   rr=prep.certify(xx,c,clean);rr.pop('per_layer_tube_norms',None)
   if any(v>1/16 for v in changes(rr).values()):
    new=certificate(p,xx,c);rr['lower']=max(rr['lower'],new['lower']);rr['upper']=min(rr['upper'],new['upper']);rr['explicit_refinement']=True
  bounds=changes(rr);rr['score_change_bounds']=bounds;rr['certified']={k:bool(v<=1/16)for k,v in bounds.items()};by[str(c)]=rr
  if all(rr['certified'].values()):larger=rr
 rows.append(dict(candidate_index=i,target=float(a['targets'][i]),by_c=by));print(i,{c:rr['score_change_bounds']for c,rr in by.items()},flush=True)
out=dict(scope='All64 fixed high-clean-gain interpolation candidates; no outcome exclusions.',qualification='Float64 evaluation of exact-real finite-radius sufficient inequalities, not an interval proof.',rows=rows,summary={str(c):{name:sum(row['by_c'][str(c)]['certified'][name]for row in rows)for name in ['clip_half','margin_band']}for c in [.001,.003]},elapsed_seconds=time.monotonic()-start)
(r/'tv-boundary-105-numerical-certificates.json').write_text(json.dumps(out,indent=2)+'\n');print('FINAL',out['summary'],flush=True)
