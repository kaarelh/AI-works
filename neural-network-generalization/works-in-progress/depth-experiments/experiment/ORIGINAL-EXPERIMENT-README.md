# Gradient-trained image networks and internal-noise robustness

This directory contains reproducible experiments for the October 17–18, 2026
research round. All model weights are retained, including classifiers that
failed to fit the training data. The experiments concern a proposed support
condition for a neural-network prior; they do not sample from that prior or
measure the posterior's sample complexity.

The primary score is `clip(z, -0.5, 0.5)`. The proposed condition bounds its
change by `1/16` under every simultaneous hidden-postactivation and scalar-output
perturbation whose squared norm is

```
sum(hidden_noise[layer]**2)/width + output_noise**2
```

and whose radius is `c/sqrt(1 + hidden_depth * readout_energy)`, where
`readout_energy = width * sum(readout_weight**2)`. We audit the fixed grid
`c = 0.001, 0.003, 0.01, 0.03, 0.0625`; `0.001` is the primary constant.
The cap `1` is a secondary comparison. Raw trained weights and outputs are used
throughout: there is no post-training output rescaling.

The main comparison is mixed. Some saved SGD image classifiers have exact
global certificates. Other classifiers fit every training margin and achieve
about 99% test accuracy, yet have exact-budget, interval-verified violations
on constructed pixel inputs. The same examples can pass a weaker, explicitly
exploratory calibration `c_H = 0.001/H`. The six small Boolean-domain models
permit exhaustive audits, with separate exact verifications of selected
results. The paper distinguishes these global claims from ordinary numerical
certificates on held-out images.

## Cohorts and selection

Every cohort has a timestamped protocol written before that cohort was run.
Later cohorts were motivated by earlier results and are exploratory; the entire
sequence was not preregistered before the research session.

* `predeclared-protocol.json`: 36 plain tanh networks on MNIST 3-versus-8 and
  Fashion-MNIST 0-versus-6, widths 128/256, hidden depths 4/16/32, vanilla
  minibatch SGD and Adam, two seeds in the primary comparisons. Eight networks
  use Boolean thresholded pixels; the others use normalized intensity values.
* `predeclared-extension.json`: 12 further networks, including width 512 tanh
  networks; four tanh networks on all 60,000 MNIST training images with the
  even-versus-odd target; and four ReLU comparisons. ReLU is outside the tanh
  theorem and is reported separately.
* `predeclared-projected.json`: four tanh networks with a fixed explicit training
  intervention: project every hidden-to-hidden matrix to operator norm at most
  0.99 after each epoch, including the last. A fifth run supplies a previously
  missing unconstrained reference. Each projected run has the same initialization,
  minibatch order, data, SGD steps, and learning rates as its designated
  unconstrained counterpart. This intervention is evidence about a constrained
  training procedure, not about ordinary unconstrained SGD.
* `predeclared-continuation.json`: both depth-32 MNIST SGD seeds receive 180
  additional epochs at a fixed lower learning-rate schedule. The original two
  models and their failed-fit outcomes remain in the record. Both seeds were
  continued; neither a seed nor a favorable checkpoint was selected.
* `predeclared-deep-extension.json`: four further plain-SGD runs at depths
  64/128 and width 128, with fixed initialization gains 1.0 and 1.1. These
  explore a separately labeled, post-hoc polynomial-depth calibration
  `c_H = 0.001/H`; all failures are retained. Finite-depth observations do not
  establish an asymptotic polynomial law.
* `predeclared-boolean-extension.json` and its depth addendum: six networks
  on the exact nine-bit Boolean domain, learning majority of nine bits or
  recursive majority of three groups of three. Depths are 4/16/64, width 64,
  and the fixed split is 400 training inputs and 112 test inputs. A separate
  audit enumerates all 512 inputs, covering the entire Boolean domain.

* `predeclared-projected-continuation.json`: one separately retained 240-epoch
  continuation of the projected full-MNIST depth-16 model, with the original
  underfit retained, a fixed lower learning-rate schedule, and no output
  rescaling or test-based tuning.
* `predeclared-deep-continuation.json`: all four depth-64/128 runs receive a
  separately declared 180-epoch lower-rate continuation. The original fixed
  60-epoch outcomes remain in the record. This follow-up was motivated by
  failure to fit the training margins, and continues both depths and both
  gains without selection by test accuracy or robustness.

The total declared cohort is 70 parameterizations. Unless a protocol explicitly says
otherwise, training uses 60 epochs, batch size 128, logistic loss, weight decay
`1e-6`, and the schedule in `train.py`. Plain SGD has no momentum. Adam and
the separately declared ReLU momentum-SGD runs are labeled explicitly.

The training likelihood used by the mathematical result requires **every**
training signed output to exceed 0.5. The `training_eligible` columns test this
condition independently of classification accuracy and robustness. A constant
or underfit classifier can be robust, so robust failed fits must not be counted
as successful examples of learning under the theorem's likelihood.
These columns originate from float64 evaluations. Model 105 separately has
an exact verification of all 60,000 training signed margins above 4.48157
and pointwise clipped-score stability on those inputs at `c=.001`:
`../certificates/all-training-verified-105/certificate.json`. Selected
exhaustive Boolean certificates also verify their 400 training margins.
The separate `../certificates/model105-exact-dataset-label-audit.json`
also verifies model 105's 9,892 correct and 108 incorrect test predictions,
with no ambiguous labels; other image-model accuracy entries remain numerical.

## Data and exact input convention

`data/source-manifest.json` gives the original public dataset URLs and SHA-256
hashes. Original gzip IDX files and parsed arrays are retained. The official
train/test split is used; full MNIST even-versus-odd uses all 60,000/10,000
examples. Two-class tasks retain all examples of their designated classes.

Continuous inputs are computed in float32 as `pixel / 127.5 - 1`; Boolean
inputs are `+1` when `pixel >= 128` and `-1` otherwise. Training is float32.
Final metrics, certificates, and attacks use those **same stored float32 input
values** cast to float64, and the exact stored float32 weights cast to float64.
An early exploratory audit instead normalized the pixels directly in float64.
Its outputs and source are retained under
`preliminary-direct-float64-feature-audit/`, and the auditor's corresponding
files are under `../certificates/legacy-float64-input-convention/`. They are
excluded from final tables and figures. See `feature-map-consistency-note.json`.

Continuous image inputs are not Boolean vertices. A certificate valid for all
real inputs also covers the Boolean cube. A counterexample at a continuous
input is not, by itself, a counterexample on the 784-dimensional Boolean cube.
The separate pixel-bit embedding and interval witnesses in the certificate
directory make any additional Boolean-domain claims explicit.

## What each audit establishes

`../certificates/` contains global operator-norm certificates, finite-radius
pointwise certificates, exact-rational checks, and selected outward-interval
verification. Its records distinguish these scopes.

* A global sufficient certificate covers **all real inputs**, hence also every
  Boolean input. Exact-rational operator bounds and outward interval arithmetic
  are separately labeled. These are mathematical/numerical certificates, not
  Lean formalizations.
* Finite-radius pointwise certificates cover only their enumerated inputs.
  Ordinary float64 evaluation of a valid sufficient inequality is distinguished
  from a fully outward-rounded or exact-rational proof.
* Projected gradient attacks optimize both raw-output directions over all hidden
  layers and the scalar output simultaneously. Every reported violating tuple
  is saved and re-evaluated inside a strictly smaller radius. Selected witnesses
  receive independent exact-budget and outward-interval verification. Failure
  to find an attack establishes nothing by itself. The main attack subset is
  the first 16 uniform images, all 16 boundary images, and first 16 Boolean
  probes per model; the positive-certificate and plotted subsets are larger.
* Held-out images, the 16 held-out images with smallest absolute clean output,
  and uniformly random Boolean inputs are separate groups. Boundary selection
  is a fixed rule, not a representative random sample of test images.
* `full-heldout/` covers every official held-out image for a separately
  declared six-model image subset. `full-cube/` enumerates every input of each
  nine-bit Boolean target. Complete finite-domain coverage is distinguished
  from the arithmetic qualification: these sufficient inequalities still use
  float64 unless explicitly verified with exact or interval arithmetic.
  Model 105 has a separate exact upgrade for all 10,000 official test inputs
  at primary `c=.001`, preserving the original float32 input convention:
  `../certificates/all-heldout-verified-105-c1_1000/certificate.json`.
  Its `c=.003` result and the other whole-pool image audits remain numerical.
* The float16/bfloat16 experiment in `quantization.py` rounds hidden activations
  while leaving weights fixed. It is one deterministic perturbation map, not a
  worst-case robustness certificate. Its actual accumulated joint noise norm
  and membership in each tested radius are reported separately.

Pooled counts refer to **input/model pairs**. Models share data, and some input
groups overlap; these counts are not independent statistical observations.
All model-training failures and uncertified points remain visible.

## Files and replay

* `models/`: raw float32 parameter arrays and original dataset indices.
* `records/`: full configurations, training history, raw final outputs, training
  eligibility, and test metrics.
* `progress/`: every training epoch, including unsuccessful runs.
* `attacks/`: aggregate PGD outcomes and every observed violating tuple.
* `quantization/`: deterministic reduced-precision activation diagnostics.
* `*-summary.csv`, `summary.json`: generated descriptive tables.
* `figure-protocol.json`, `make_figures.py`: fixed-subset plots with certified,
  witnessed-violation, and unresolved categories. The main plot uses the first
  32 uniform held-out inputs, 16 boundary inputs, and first 32 Boolean probes
  per model at every radius. A companion plot restricts to training-eligible
  models. Projected SGD is compared separately.

Run from this directory with NumPy, SciPy, and Matplotlib available:

```sh
python train.py --protocol predeclared-protocol.json --workers 3
python train.py --protocol predeclared-extension.json --workers 3
python train.py --protocol predeclared-projected.json --workers 3
python train.py --protocol predeclared-continuation.json --workers 2
python train.py --protocol predeclared-deep-extension.json --workers 2
python train.py --protocol predeclared-boolean-extension.json --workers 2
python train.py --protocol predeclared-boolean-deep-extension.json --workers 2
python train.py --protocol predeclared-projected-continuation.json --workers 1
python train.py --protocol predeclared-deep-continuation.json --workers 2
python attacks.py
python quantization.py
python summarize.py
python make_figures.py
python make_figures.py --eligible-only
python polynomial_depth_calibration.py
python margin_band_audit.py
python full_heldout_audit.py
python full_cube_audit.py
python generate_results_tables.py
python generate_boolean_table.py
python generate_quantization_table.py
python plot_depth_calibration.py
```

Existing finished training runs are skipped. Continuations require their
original saved models. Certificate replay commands and exact-factor metadata
are in `../certificates/`. Random seeds, learning rates, point-selection rules,
noise radii, and numerical qualifications are stored in the corresponding
protocols and per-model JSON files.

`environment.json` records library versions and arithmetic conventions.
Retraining on a different BLAS implementation may change floating-point
rounding and hence the final optimizer trajectory. The archived raw weights
and saved exact proof factors allow the stated certificate results to be
replayed independently of reproducing the training trajectory bit for bit.
Files ending in `.partial.json` are intermediate certificate checkpoints;
the summary and figure scripts exclude them. A complete refined certificate
supersedes the corresponding complete base certificate in aggregate results.
