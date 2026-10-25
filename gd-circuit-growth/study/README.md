# Study: rich-regime networks on Boolean functions, discrete models, certificates

Files in this folder; the findings are summarised in the [project README](../README.md#part-2-an-empirical-study-a-matched-discrete-model-and-generalization-bounds).

| file | contents |
|---|---|
| [`boolfuncs.py`](boolfuncs.py) | the 21 target functions on $\{-1,1\}^{30}$ |
| [`nn_train.py`](nn_train.py) | muP 2-hidden-layer ReLU MLP (width 128) in JAX: fixed-train-set and online protocols, diagnostics |
| [`run_all.sh`](run_all.sh), [`run_rest.sh`](run_rest.sh) | the sweep as launched (only its fixed-Adam pass ran) and the trimmed remainder (online Adam on six targets); SGD on the held-out targets was run directly with `nn_train.py --opt sgd --lr 0.2 --seeds 0,1` |
| [`common.py`](common.py) | shared data access (exactly the networks' training and test sets), model evaluation, behavioural comparison metrics, CALIB/HELDOUT split |
| [`models/baselines.py`](models/baselines.py) | NNGP kernel regression (lazy/kernel analogue) and an Occam learner over juntas |
| [`models/race.py`](models/race.py) | **the race model**: event-driven utility race of dormant units on a shared circuit; evaluated with `gate="relu"` (discrete ReLU gates; the docstring describes the threshold-gate default) (best match) |
| [`models/sswm.py`](models/sswm.py) | strong-selection/weak-mutation evolution of one shared fan-in-2 circuit |
| [`models/run_race_eval.py`](models/run_race_eval.py) | full-grid evaluation of the race model at its calibrated setting |
| [`judge_models.py`](judge_models.py) → [`MODEL-SCOREBOARD.md`](MODEL-SCOREBOARD.md) | scoreboard of models and baselines against the networks, held-out and calibration functions separately |
| [`analyze_nn.py`](analyze_nn.py) → [`NN-STUDY-TABLES.md`](NN-STUDY-TABLES.md) | sample complexities, timing, Fourier learning order, kernel ranks |
| [`certify.py`](certify.py), [`run_certify.py`](run_certify.py) → [`CERTIFICATES.md`](CERTIFICATES.md) | distillation certificates over training time |
| `models/scratch_*` | the model designers' calibration scripts and logs (kept for the record) |
| `figures/` | all figures |

Raw sweep outputs (per-checkpoint metrics, test-set predictions and final parameters, about 100 MB) were written to the
session scratchpad and are not in the repository; every table and figure here was generated from them by the scripts
above, and rerunning `run_all.sh`-style commands regenerates them (JAX on CPU, about 80 s per function per protocol on
an idle 4-core machine).

Status: **Numerical** throughout, at one width (128), one input dimension (30) and one learning rate per optimizer.
