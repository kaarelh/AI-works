#!/usr/bin/env python3
import os
os.environ['OPENBLAS_NUM_THREADS']='1'
from pathlib import Path
import json,numpy as np
from verify_witness import verify
r=Path(__file__).resolve().parent.parent
p0=next((r/'experiment/models').glob('029-*.npz'));a=np.load(p0);p=[a[k]for k in sorted([k for k in a.files if k.startswith('w') and k[1:].isdigit()],key=lambda k:int(k[1:]))]
for group in ['random_cube','heldout_boundary']:
 f=sorted((r/'experiment/attacks').glob(f'029*c0.01-cap0.5-{group}-i*.npz'))[0];a=np.load(f);v=verify(p,a['input'],a['hidden_noise'],.01,float(a['output_noise']))
 out=dict(model=p0.stem,witness=str(f),selection='Lexicographically first saved main-cap violation in each requested group.',group=group,c=.01,verification=v)
 (r/'certificates'/f'boolean-verified-029-{group}-c0.01.json').write_text(json.dumps(out,indent=2)+'\n');print(group,v['exact_rational_budget_pass'],v['clipped']['0.5'],flush=True)
