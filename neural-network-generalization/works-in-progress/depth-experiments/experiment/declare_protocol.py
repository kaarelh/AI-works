#!/usr/bin/env python3
"""Freeze model configurations before any round-three training outcomes."""
from pathlib import Path
import json,datetime

ROOT=Path(__file__).resolve().parent

def configs():
    result=[]
    for task in ['mnist3vs8','fashion0vs6']:
        for depth in [4,16,32]:
            for opt in ['sgd','adam']:
                for seed in [0,1]:
                    result.append(dict(cohort='main-continuous',task=task,input_mode='continuous',
                                       hidden_depth=depth,width=128,optimizer=opt,seed=seed))
    for task in ['mnist3vs8','fashion0vs6']:
        for opt in ['sgd','adam']:
            result.append(dict(cohort='width-extension',task=task,input_mode='continuous',
                               hidden_depth=16,width=256,optimizer=opt,seed=0))
    for task in ['mnist3vs8','fashion0vs6']:
        for opt in ['sgd','adam']:
            for seed in [0,1]:
                result.append(dict(cohort='boolean-match',task=task,input_mode='boolean',
                                   hidden_depth=16,width=128,optimizer=opt,seed=seed))
    for i,c in enumerate(result):
        c.update(index=i,id=f"{i:03d}-{c['task']}-{c['input_mode']}-H{c['hidden_depth']}-N{c['width']}-{c['optimizer']}-s{c['seed']}",
                 epochs=60,batch_size=128,learning_rate=.05 if c['optimizer']=='sgd' else .001,
                 weight_decay=1e-6,initial_gain=1.1,loss='binary logistic',dimension=784,
                 architecture='plain tanh, input bias only, scalar linear readout',training_dtype='float32')
    return result

def main():
    protocol=dict(declared_at_utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),
       status='All configurations and radius/audit choices fixed before training any round-three model.',
       datasets='Official train/test splits, all examples of digits3/8 or Fashion labels0/6; no test-driven tuning.',
       features='Continuous pixel/127.5-1; Boolean pixel>=128 mapped to+1 else-1.',
       optimization='True shuffled minibatch SGD without momentum; or Adam(.9,.999). LR times.2 at epoch40, times.2 at epoch50. Fixed60epochs. All failures retained.',
       architecture='No hidden biases, no residual connections in this primary cohort. Gaussian first/readout; internal orthogonal times1.1. Raw weights; no post-training rescaling.',
       seeds='Initialization10000+seed; shuffle20000+seed. Official splits shared. Audit uniform selection30000+seed, cube40000+index.',
       radius_constants=[.001,.003,.01,.03,.0625],
       score='clip output to[-1,1]; correct condition is every simultaneous normalized postactivation+scalaroutput noise tuple changes score by<=1/16.',
       radius='c/sqrt(1+H*N*||v||²)',
       training_eligibility='Record fraction and minimum of signed training outputs>.5 separately. No all-input clean-margin requirement.',
       audits=dict(heldout_uniform_count=128,heldout_low_abs_output_count=16,random_boolean_count=64,
                   note='Boundary-focused points selected by clean |z| after training under this fixed selection rule; reported separately from uniform points. Global claims require a global certificate, never probes.',
                   attack_heldout_uniform_count=16,attack_heldout_boundary_count=16,attack_random_cube_count=16,
                   attack_steps=100,attack_restarts=2,attack_both_directions=True,
                   audit_arithmetic='Trainingfloat32weights stored exactly; certificates/attacks in float64, selected proofs intervalchecked. Certificate agent may add tighter valid inequalities without changing cases or dropping failures.'),
       compute_budget='Three training workers, one numerical certificate worker. Stop new training at90minutes if necessary; retain and report incomplete runs. No optional run selection by results.',
       configs=configs())
    dest=ROOT/'predeclared-protocol.json'
    if dest.exists():raise RuntimeError('Protocol already declared; do not silently replace it.')
    dest.write_text(json.dumps(protocol,indent=2)+'\n')
    print(dest)

if __name__=='__main__':main()
