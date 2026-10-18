#!/usr/bin/env python3
"""Additional relevance cohort; fixed before its own training outcomes."""
from pathlib import Path
import datetime,json,math
ROOT=Path(__file__).resolve().parent

def main():
    cs=[]
    for task in ['mnist3vs8','fashion0vs6']:
        for opt in ['sgd','adam']:
            cs.append(dict(cohort='wide-tanh',task=task,width=512,hidden_depth=16,
                           optimizer=opt,activation='tanh',learning_rate=.05 if opt=='sgd' else .0001,initial_gain=1.1))
    for width in [256,512]:
        for depth in [4,16]:
            cs.append(dict(cohort='all-digit-parity',task='mnistevenodd',width=width,hidden_depth=depth,
                           optimizer='sgd',activation='tanh',learning_rate=.05,initial_gain=1.1))
    for task in ['mnistevenodd','fashion0vs6']:
        for depth in [4,16]:
            cs.append(dict(cohort='relu-comparison',task=task,width=256,hidden_depth=depth,
                           optimizer='momentum_sgd',activation='relu',learning_rate=.01,initial_gain=math.sqrt(2)))
    for i,c in enumerate(cs,100):
        c.update(index=i,id=f"{i:03d}-{c['task']}-{c['activation']}-H{c['hidden_depth']}-N{c['width']}-{c['optimizer']}-s0",
                 seed=0,input_mode='continuous',epochs=60,batch_size=128,weight_decay=1e-6,
                 loss='binary logistic',dimension=784,architecture='plain '+c['activation']+', input bias only, scalar linear readout',training_dtype='float32')
    p=dict(declared_at_utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),
           status='Additional exploratory cohort. Initial36 training/attack results partly visible, but all12 settings fixed before any extension model is trained.',
           purpose='More relevant full-size images, up to512hiddenunits, all60000MNISTtrainingexamples for even/odd, and explicit ReLU comparison beyond the tanh theorem.',
           data='Same standard official splits. MNISTeven/odd uses all10digits, evenpositive. No subsampling or test-driven tuning.',
           reason_for_small_adam_rate='Prior and initial deep-tanh Adam runs can fail atlargerrates. These are separately retained controls, never replacements of failed initialruns.',
           relu_scope='ReLU comparison is outside the bounded-tanh statistical theorem. Same additive normalized-noise condition can still be measured; no theorem extension is claimed.',
           fixed_audit_protocol='Same radiusgrid,scorecaps,inputselection,PGDsteps/restarts asprimary protocol. Positivecertificatecoverage may be limited by computationalcost; exactscope recorded.',
           configs=cs)
    path=ROOT/'predeclared-extension.json'
    if path.exists():raise RuntimeError('Extension already declared.')
    path.write_text(json.dumps(p,indent=2)+'\n');print(path)

if __name__=='__main__':main()
