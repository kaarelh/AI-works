#!/usr/bin/env python3
"""Matched explicit spectral-projection intervention; no silent retuning."""
from pathlib import Path
import datetime,json
ROOT=Path(__file__).resolve().parent

def main():
    cs=[]
    for i,task,h,reference in [(200,'mnistevenodd',4,104),(201,'mnistevenodd',16,105),
                               (202,'fashion0vs6',4,204),(203,'fashion0vs6',16,26),
                               (204,'fashion0vs6',4,None)]:
        projected=i!=204
        cs.append(dict(index=i,id=f"{i:03d}-{task}-tanh-H{h}-N256-{'projected' if projected else 'reference'}sgd-s0",
                       cohort='projected-sgd' if projected else 'projection-reference',task=task,
                       input_mode='continuous',activation='tanh',width=256,hidden_depth=h,
                       optimizer='sgd',seed=0,epochs=60,batch_size=128,learning_rate=.05,
                       weight_decay=1e-6,initial_gain=1.1,loss='binary logistic',dimension=784,
                       architecture='plain tanh, input bias only, scalar linear readout',training_dtype='float32',
                       internal_spectral_projection=.99 if projected else None,
                       matched_unconstrained_index=reference))
    protocol=dict(declared_at_utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),
       status='Fixed before any projected-cohort training or outcomes. Earlier unconstrained initial-cohort outcomes visible.',
       intervention='After EACH epoch, includingafterfinalupdate, SVDprojecteveryhidden-to-hiddenmatrix tooperatornorm<=.99. Firstlayer/readoutunchanged. Rawfinalmodelreported; no additional posthoc rescaling.',
       comparison='Same initializationseed, dataset, widths/depths, minibatchorder,SGDsteps andlearningrates asdesignatedunconstrainedcounterpart. Fourprojectedmodels plusonepreviouslymissingFashionH4N256unconstrainedreference.',
       purpose='Tests whethera standardexplicit spectralnormconstraint can preserve taskperformance. This is NOT evidence thatunconstrainedgradientdescent automatically enforcesrobustness.',
       audits='Unchanged primarycap.5,tolerance1/16,fiveradiusconstants,inputsubsetseeds,PGDprotocol. Exactglobalnormchecksrequestedseparately.',configs=cs)
    p=ROOT/'predeclared-projected.json'
    if p.exists():raise RuntimeError('Alreadydeclared')
    p.write_text(json.dumps(protocol,indent=2)+'\n');print(p)

if __name__=='__main__':main()
