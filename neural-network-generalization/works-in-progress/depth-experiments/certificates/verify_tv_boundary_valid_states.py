#!/usr/bin/env python3
import os
os.environ['OPENBLAS_NUM_THREADS']='1'
from pathlib import Path
from fractions import Fraction
import json,numpy as np
from verify_witness import verify
r=Path(__file__).resolve().parent;a=np.load(next((r.parent/'experiment/models').glob('105-*.npz')));p=[a[k].astype(float)for k in sorted([k for k in a.files if k.startswith('w')and k[1:].isdigit()],key=lambda k:int(k[1:]))]
rows=[]
for name in ['clip_half','margin_band']:
 f=r/f'tv-boundary-105-{name}-c0.01.npz';a=np.load(f);pixels=a['pixels'];x=(2*pixels.astype(float)-255)/255;eta=a['hidden_noise'].copy();original=eta.copy();h=np.r_[x,1.];zeroed=0
 for s,w in enumerate(p[:-1]):
  clean=np.tanh(h@w);bad=abs(clean+eta[s])>1-1e-10;zeroed+=int(np.sum(bad&(eta[s]!=0)));eta[s,bad]=0.;h=clean+eta[s]
 v=verify(p,x,eta,.01,float(a['output_noise']),[Fraction(int(2*int(q)-255),255)for q in pixels]);tv=int(abs(np.diff(pixels.astype(int).reshape(28,28),axis=0)).sum()+abs(np.diff(pixels.astype(int).reshape(28,28),axis=1)).sum());ink=int(pixels.sum());out=dict(transform=name,postprocessing='Causal removal (set tozero) ofnoise components whose proposedhiddenstate iswithin1e-10 of/outsideunitbox; no component magnitudeincreases.',zeroed_components=zeroed,componentwise_noise_magnitude_nonincrease=bool(np.all(abs(eta)<=abs(original))),exact_pixel_TV_numerator_over255=tv,exact_ink_numerator_over199920=ink,exact_TV_le150=bool(tv<=150*255),exact_ink_le_one_fifth=bool(5*ink<=784*255),verification=v)
 rows.append(out);np.savez(r/f'tv-boundary-105-{name}-validstates.npz',pixels=pixels,hidden_noise=eta,output_noise=a['output_noise']);print(name,zeroed,v['clipped']['0.5'],v['optional_margin_band'],v['hidden_state_diagnostics'],flush=True)
(r/'tv-boundary-105-validstates-verified.json').write_text(json.dumps(dict(scope='Deterministic postprocessing of existing saved witnesses; no new image/attack optimization.',rows=rows),indent=2)+'\n')
