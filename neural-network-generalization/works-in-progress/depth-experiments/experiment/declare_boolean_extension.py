#!/usr/bin/env python3
"""Small exact Boolean domains, all inputs enumerated in the final audit."""
from pathlib import Path
import datetime,json
ROOT=Path(__file__).resolve().parent
configs=[]
for task in ['majority9','recursive_majority9']:
    for h in [4,16]:
        i=500+len(configs)
        configs.append(dict(index=i,id=f'{i:03d}-{task}-tanh-H{h}-N64-sgd-s0',
            cohort='boolean-domain-extension',task=task,input_mode='enumerated_boolean',activation='tanh',
            width=64,hidden_depth=h,optimizer='sgd',seed=0,epochs=500,batch_size=128,
            learning_rate=.05,learning_rate_schedule=[[300,.05],[450,.01],[500,.002]],
            weight_decay=1e-6,initial_gain=1.1,loss='binary logistic',dimension=9,
            architecture='plain tanh, input bias only, scalar linear readout',training_dtype='float32',
            split_seed=70000,training_cube_count=400))
protocol=dict(declared_at_utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),
    status='Fixed before any Boolean-extension training; previous image-cohort results visible.',
    targets='majority9=sign(sum x_i); recursive_majority9=sign(sign(x0+x1+x2)+sign(x3+x4+x5)+sign(x6+x7+x8)). No ties are possible.',
    dataset='All512inputs of{-1,+1}^9, coordinate0 is the least-significant bit of the integer index. Shared default_rng(70000) permutation: first400train, remaining112test. Same split across targets/depths.',
    evaluation='Retain every run. Original sampled audits apply with uniformheldout count min(128,112). Additionally enumerate ALL512domain inputs for finite-radius certificates at the original five constants and at exploratoryc_H=.001/H. Image figures exclude this separate domain cohort.',
    scope='An all512point certificate covers the entire Boolean target domain, but numerical evaluation is float64 unless separately exact/interval verified.',configs=configs)
p=ROOT/'predeclared-boolean-extension.json'
if p.exists():raise RuntimeError('Already declared.')
p.write_text(json.dumps(protocol,indent=2)+'\n');print(p)
