# Ordinary gradient training from the mean-field Gaussian initialization

This small exploratory cohort tests whether starting at the theorem's prior
scale yields trained networks for which population averaging is a genuine
restriction. It does not sample a Bayesian posterior or test the statistical
learning theorem.

Before running these new models, `protocol.json` fixed the full grid of 16
configurations: majority of the first five bits or parity of the first three;
width 32 or 64; Adam or vanilla full-batch SGD; two random seeds. Every model
has four tanh hidden layers, an input constant coordinate, no hidden biases,
and a scalar linear readout. The data are the dimension-eight Boolean cube,
with 128 uniformly selected distinct training inputs and the complementary
128 test inputs.

All weight coordinates are initially independent centered Gaussians, with
variances `1/d`, `1/N`, and `1/N^2` in the first, later hidden, and output
layers respectively. These are the theorem's mean-field raw prior variances
at `t=1`. The first variance is `1/d`, including the constant-coordinate
weights; it is not `1/(d+1)`.

Training uses ordinary parameter gradients of MSE/2 plus ordinary
`1e-6 * sum(weights^2)/2` regularization. There is no layerwise gradient
rescaling or prior-weighted penalty. Adam uses learning rate .003 and SGD .05;
both run 4000 steps, with the rate multiplied by .3 for the final 20%.
All outcomes and original weights are retained, without output rescaling or
selection based on accuracy. This protocol was declared after inspection of
the older cohorts and should be described as an exploratory follow-up, not
an independently preregistered test of the entire research hypothesis.

## Results before testing compression

All 16 models finish normally, interpolate all training signs with signed
margin above .95, and classify all 256 cube inputs correctly. Twelve have
signed margin above .5 on the entire cube; four parity models have some
held-out margins below .5. These margin evaluations use float64 arithmetic.

The population energy is `Ev=N*||v||^2`. The exact largest permitted population
count is `min(N,floor(1+Ev))`, evaluated with rational arithmetic on the stored
binary floats. Twelve models require real compression; four allow the
identity choice `q=N`.

| Target | Optimizer | Width | Seed | Ev | Largest allowed q | Test accuracy |
|---|---|---:|---:|---:|---:|---:|
| majority5 | Adam | 32 | 0 | 3.534 | 4 | 100% |
| majority5 | Adam | 32 | 1 | 2.859 | 3 | 100% |
| majority5 | SGD | 32 | 0 | 23.991 | 24 | 100% |
| majority5 | SGD | 32 | 1 | 14.030 | 15 | 100% |
| majority5 | Adam | 64 | 0 | 3.593 | 4 | 100% |
| majority5 | Adam | 64 | 1 | 2.985 | 3 | 100% |
| majority5 | SGD | 64 | 0 | 26.869 | 27 | 100% |
| majority5 | SGD | 64 | 1 | 25.365 | 26 | 100% |
| parity3 | Adam | 32 | 0 | 11.088 | 12 | 100% |
| parity3 | Adam | 32 | 1 | 10.406 | 11 | 100% |
| parity3 | SGD | 32 | 0 | 34.960 | 32, identity allowed | 100% |
| parity3 | SGD | 32 | 1 | 66.838 | 32, identity allowed | 100% |
| parity3 | Adam | 64 | 0 | 13.189 | 14 | 100% |
| parity3 | Adam | 64 | 1 | 8.007 | 9 | 100% |
| parity3 | SGD | 64 | 0 | 81.536 | 64, identity allowed | 100% |
| parity3 | SGD | 64 | 1 | 91.205 | 64, identity allowed | 100% |

Thus the mean-field initialization removes the vacuity concern for these
eight Adam runs and four majority SGD runs. It does not by itself establish
population-averaging stability. That requires a separate search for balanced
partitions and evaluation of the compressed network. Differences between
Adam and SGD in this small fixed grid should not be extrapolated into a
general optimizer claim.

## Replay and files

`train.py` is standalone NumPy code. `protocol.json` records versions, seeds,
initialization, optimization, and every configuration. `initial-models/` and
`models/` contain every initial and final weight array; `records/` contains
per-model training histories, final metrics, exact energy fractions, and
checkpoint hashes. `summary.json` collects the final metrics. No model is
discarded. The source refuses to overwrite an existing declaration or result
cohort; replay in a clean copy of this directory with output files removed.

```
python train.py --declare
python train.py --run
```

The run uses at most two worker processes, each restricted to one BLAS thread.
The matrices use row-batched propagation `h @ w`, so shapes are `(d+1,N)`,
three `(N,N)` matrices, and `(N,)` for `w0,...,w4`. Final archives additionally
store target labels, training indices, and test indices in the lexicographic
cube ordering. Labels are not supplied to the subsequent grouping search.

`gradient-check.json` records a central finite-difference check in one random
normalized direction involving every layer: the discrepancy from the
implemented ordinary parameter gradient is about `2.5e-12`. This checks the
gradient arithmetic, not convergence or generalization.
