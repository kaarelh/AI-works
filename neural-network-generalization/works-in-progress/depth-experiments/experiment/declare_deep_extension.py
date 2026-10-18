#!/usr/bin/env python3
"""Exploratory depth-64/128 test of polynomial radius calibration."""
from pathlib import Path
import datetime,json
ROOT=Path(__file__).resolve().parent
configs=[]
for h in [64,128]:
    for gain in [1.,1.1]:
        i=400+len(configs)
        configs.append(dict(index=i,id=f'{i:03d}-mnist3vs8-tanh-H{h}-N128-sgd-gain{gain:g}-s0',
            cohort='deep-calibration-extension',task='mnist3vs8',input_mode='continuous',activation='tanh',
            width=128,hidden_depth=h,optimizer='sgd',seed=0,epochs=60,batch_size=128,
            learning_rate=.01,learning_rate_schedule=[[40,.01],[50,.002],[60,.0004]],
            weight_decay=1e-6,initial_gain=gain,loss='binary logistic',dimension=784,
            architecture='plain tanh, input bias only, scalar linear readout',training_dtype='float32'))
protocol=dict(declared_at_utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),
    status='Fixed before any deep-extension training. Motivated by observed fixed-c failures and successful post-hoc c_H=.001/H global bounds in earlier SGD models.',
    purpose='Probe larger depths64/128 under two fixed orthogonal initialization gains. All failures retained; finite-depth results cannot establish an asymptotic polynomial calibration law.',
    comparison='At each depth, gains1.0/1.1 share random seed, first/readout weights, orthogonal factors, minibatch order, and schedule. Four runs only; no rescaling or outcome-based continuation.',
    primary_audit='Original cap-half/tolerance1/16 and five fixed constants remain unchanged; c_H=.001/H is an explicitly exploratory additional global-bound screen.',configs=configs)
p=ROOT/'predeclared-deep-extension.json'
if p.exists():raise RuntimeError('Already declared.')
p.write_text(json.dumps(protocol,indent=2)+'\n');print(p)
