#!/usr/bin/env python3
"""Exploratory check of negated existing noise; no new optimization."""
import os
os.environ['OPENBLAS_NUM_THREADS']='1'
from pathlib import Path
from fractions import Fraction
import numpy as np,json,hashlib
from verify_witness import verify
root=Path(__file__).resolve().parent;model=next((root.parent/'experiment/models').glob('301-*.npz'));saved=np.load(model);p=[saved[k]for k in sorted([k for k in saved.files if k.startswith('w')and k[1:].isdigit()],key=lambda k:int(k[1:]))]
source=root/'lowink-zero-301.npz';a=np.load(source);pixels=a['pixels'];x=(2*pixels.astype(float)-255)/255;eta=-a['hidden_noise'];xi=-float(a['output_noise'])
result=verify(p,x,eta,.001,xi,[Fraction(int(2*int(b)-255),255)for b in pixels])
np.savez_compressed(root/'lowink-zero-301-flipped.npz',pixels=pixels,hidden_noise=eta,output_noise=xi)
out=dict(model=model.stem,source_witness=source.name,source_sha256=hashlib.sha256(source.read_bytes()).hexdigest(),scope='Postprotocol exploratory optional one-sided gap condition; existing selected perturbation negated exactly, with no new optimization or input selection.',verification=result)
(root/'lowink-zero-301-flipped-verified.json').write_text(json.dumps(out,indent=2)+'\n');print(json.dumps(out),flush=True)
