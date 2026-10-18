#!/usr/bin/env python3
"""Exploratory linear sensitivity at the formal all-zero hidden trajectory.

This is not a finite-radius certificate or counterexample. In particular, no
claim is made that a Boolean or pixel-grid input realizes this trajectory.
"""
import os
os.environ['OPENBLAS_NUM_THREADS']='1'
from pathlib import Path
import json
import numpy as np

ROOT=Path(__file__).resolve().parent

def main():
    rows=[]
    for path in sorted((ROOT/'records').glob('*.json')):
        r=json.loads(path.read_text());c=r['config']
        if c.get('activation','tanh')!='tanh' or c['input_mode']=='enumerated_boolean':continue
        m=np.load(ROOT/'models'/f"{c['id']}.npz");n=c['width'];h=c['hidden_depth']
        v=m[f'w{h}'].astype(np.float64);ev=n*np.dot(v,v);q=v.copy();total=1+n*np.dot(q,q)
        for j in range(h-1,0,-1):
            q=m[f'w{j}'].astype(np.float64)@q;total+=n*np.dot(q,q)
        gain=float(np.sqrt(total/(1+h*ev)))
        rows.append(dict(config=c,training_eligible=r['train']['all_margins_above_half'],
                         normalized_linear_gain=gain,linear_scale_at_fixed_c001=.001*gain,
                         linear_scale_at_inverse_depth_c001=.001*gain/h))
    (ROOT/'zero-state-diagnostic.json').write_text(json.dumps(dict(
        status='Exploratory diagnostic added after observed depth-calibration outcomes.',
        qualification='At a formally zero hidden trajectory tanh derivative is one, so the reverse product computes the differential noise gain. It is not a finite-radius result, and the input trajectory may not be realized on the prescribed domain. All retained tanh image models are included.',
        rows=rows),indent=2)+'\n')
    print('Saved formal zero-state diagnostics for',len(rows),'tanh image models')

if __name__=='__main__':main()
