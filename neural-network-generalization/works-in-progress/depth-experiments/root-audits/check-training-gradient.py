"""Independent complex-step check of the experiment's tanh backpropagation.

The small deterministic example is an implementation check, not evidence
about the statistical theorem or about the trained networks' stability.
"""
import os
os.environ['OPENBLAS_NUM_THREADS'] = '1'
from pathlib import Path
import importlib.util
import json
import numpy as np

root = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location('training', root/'experiment/train.py')
training = importlib.util.module_from_spec(spec)
spec.loader.exec_module(training)
rng = np.random.default_rng(928142)
x = rng.normal(size=(7, 4))
y = rng.choice([-1., 1.], size=7)
parameters = [rng.normal(scale=.3, size=(5, 3)),
              rng.normal(scale=.3, size=(3, 3)),
              rng.normal(scale=.3, size=(3, 3)),
              rng.normal(scale=.3, size=3)]
decay = 1e-6
z, hs, ts = training.forward(parameters, x, cache=True)
a = -y*z
dz = -y*np.exp(-np.logaddexp(0, -a))/len(y)
grads = [None]*len(parameters)
grads[-1] = hs[-1].T@dz + decay*parameters[-1]
dh = dz[:, None]*parameters[-1]
for j in reversed(range(len(parameters)-1)):
    da = dh*(1-ts[j]*ts[j])
    grads[j] = hs[j].T@da + decay*parameters[j]
    if j:
        dh = da@parameters[j].T

def analytic_loss(ps):
    outputs = training.forward(ps, x.astype(np.complex128))
    return np.mean(np.log(1+np.exp(-y*outputs))) + .5*decay*sum(np.sum(w*w) for w in ps)

errors = []
relative = []
for layer, w in enumerate(parameters):
    for index in np.ndindex(w.shape):
        perturbed = [p.astype(np.complex128) for p in parameters]
        perturbed[layer][index] += 1e-20j
        expected = analytic_loss(perturbed).imag/1e-20
        actual = grads[layer][index]
        errors.append(abs(actual-expected))
        relative.append(abs(actual-expected)/max(1e-12, abs(expected)))
result = dict(status='PASS' if max(errors)<1e-12 else 'FAIL',
              checked_parameters=len(errors),
              max_absolute_error=max(errors), max_relative_error=max(relative),
              method='Independent complex-step differentiation of logistic loss plus L2 regularizer',
              architecture='3 tanh hidden layers; input bias only; scalar linear readout',
              scope='Checks the equations used by training, not every optimizer trajectory or theorems')
(root/'root-audits/training-gradient.json').write_text(json.dumps(result, indent=2)+'\n')
print(json.dumps(result))
assert result['status']=='PASS'
