# Fresh mean-field-initialized training: two and three hidden layers

This exploratory cohort tests whether the population-averaging support restriction resembles a property of ordinary trained networks. It does not sample a Bayesian posterior and does not test the NNBayes sample-complexity theorem.

The fixed protocol was written before running these configurations, after examining earlier cohorts. All 24 specified runs and their initial/final checkpoints are retained. The complementary four-hidden-layer cohort belongs to a separate directory and uses different optimization settings; the cohorts should not be silently pooled.

## Protocol

- Domain: all 512 inputs in the nine-dimensional Boolean cube, in lexicographic order, with 128 uniformly sampled distinct training inputs and the complementary 384 test inputs.
- Targets: majority of the first five bits, parity of the first three bits, and majority of three disjoint three-bit majorities.
- Architectures: two or three tanh hidden layers; width 32 or 64; only the first layer has a constant input coordinate; linear readout.
- Two seeds per target/architecture. Initial coordinates are independent Gaussians with variance `1/d` in the first layer, `1/N` internally, and `1/N²` at the readout: the mean-field scaling used in the theorem.
- Ordinary full-batch Adam, learning rate 0.003, 3,000 steps, half mean squared loss, no weight decay, no layerwise learning-rate rescaling, no early stopping, and no output rescaling after training.
- No global margin or robustness condition is imposed at initialization or during training.
- All computation uses float64. Readout energy and its integer population cap are also calculated exactly as rational numbers from the stored float64 coordinates.

## Training results

All 24 runs finished without nonfinite values or optimization failure. All fit every training label with signed output strictly greater than 1/2; the smallest training margin among all runs is approximately 0.982.

| Target | Runs | Mean test sign accuracy | Readout-energy range | Runs allowing the trivial q=N partition |
|---|---:|---:|---:|---:|
| Majority5 | 8 | 1.0000 | 3.918–13.448 | 0 |
| Parity3 | 8 | 0.9984 | 13.747–37.158 | 1 |
| Recursive majority9 | 8 | 0.9199 | 6.992–27.997 | 0 |

The population cap is `min(N,floor(1+E_v))`, where `E_v=N sum(v_i²)`. It is strictly less than N in 23 of 24 runs. This establishes that those 23 runs provide nontrivial test cases for the clustering condition; it does not establish that any of them satisfies it. Compression searches and exhaustive clipped-output comparisons are reported by the separate clustering experiment.

The test accuracies here are context for the trained models, not evidence for a Bayesian sample-complexity guarantee. In particular, recursive-majority fits the training set but has appreciable held-out error under this protocol.

## Files and reproduction

- `protocol.json`: full configurations and declaration timestamp.
- `train.py`: complete NumPy implementation, adapted from the sibling fresh-training cohort's implementation.
- `gradient-check.json`: central finite-difference checks of backpropagation; maximum absolute discrepancy about `2.1e-10`.
- `initial-models/` and `models/`: all initial and final arrays; final arrays also store targets and training/test indices.
- `records/`: initial/final metrics, optimization checkpoints, exact readout energies, and checkpoint hashes for every run.
- `summary.json`, `metrics.csv`, `run.log`: aggregate and per-run outcomes.
- `manifest.json`: SHA-256 hashes of the experiment outputs.

To reproduce in a new empty destination, copy `train.py`, run `python train.py --declare`, then `python train.py --run`. The script refuses to overwrite an existing cohort. It uses two worker processes and one BLAS thread per process. The training data and every source of random initialization are seeded in the recorded configuration.
