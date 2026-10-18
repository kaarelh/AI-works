#!/usr/bin/env python3
import os
os.environ['OPENBLAS_NUM_THREADS']='1'
from pathlib import Path
from fractions import Fraction
import numpy as np,json,hashlib
from verify_witness import verify
r=Path(__file__).resolve().parent;model=next((r.parent/'experiment/models').glob('008-*.npz'));a=np.load(model);p=[a[k]for k in sorted([k for k in a.files if k.startswith('w') and k[1:].isdigit()],key=lambda k:int(k[1:]))]
rows=[]
for name in ['lowink-zero-008','pixel-grid-008-c0.001']:
 f=r/f'{name}.npz';a=np.load(f);pixels=a['pixels'];x=(2*pixels.astype(float)-255)/255
 v=verify(p,x,a['hidden_noise'],.001,float(a['output_noise']),[Fraction(int(2*int(b)-255),255)for b in pixels])
 rows.append(dict(witness=name,witness_sha256=hashlib.sha256(f.read_bytes()).hexdigest(),verification=v))
out=dict(scope='Optional postprotocol score transform applied to existing independently verified witnesses; no new search or training.',transform='U(z)=sign(z) min(1/4,(abs(z)-1/4)_+)',tolerance=1/16,rows=rows)
(r/'optional-margin-band-existing-witnesses.json').write_text(json.dumps(out,indent=2)+'\n')
for row in rows:print(row['witness'],row['verification']['optional_margin_band'],flush=True)
