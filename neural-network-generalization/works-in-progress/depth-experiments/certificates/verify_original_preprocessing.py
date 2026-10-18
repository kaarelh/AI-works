#!/usr/bin/env python3
import os
os.environ['OPENBLAS_NUM_THREADS']='1'
import json,numpy as np
from pathlib import Path
from verify_witness import verify
r=Path(__file__).resolve().parent;model=next((r.parent/'experiment/models').glob('105-*.npz'));a=np.load(model);p=[a[k].astype(float)for k in sorted([k for k in a.files if k.startswith('w')and k[1:].isdigit()],key=lambda k:int(k[1:]))]
rows=[]
for name in ['lowink-zero-105','margin-band-target-105']:
 a=np.load(r/f'{name}.npz');x=(a['pixels'].astype(np.float32)/np.float32(127.5)-np.float32(1)).astype(float)
 v=verify(p,x,a['hidden_noise'],.001,float(a['output_noise']))
 rows.append(dict(witness=name,verification=v));print(name,v['clipped']['0.5'],v['optional_margin_band'],flush=True)
(r/'original-preprocessing-105-verified.json').write_text(json.dumps(dict(scope='Same valid8bitpixelwitnesses, now exactlytheoriginalfloat32pixelpreprocessing usedintraining andheldoutevaluation; rawsavedweights/noisefixed. Separatefromidealrationalpixeldecoderproof.',rows=rows),indent=2)+'\n')
