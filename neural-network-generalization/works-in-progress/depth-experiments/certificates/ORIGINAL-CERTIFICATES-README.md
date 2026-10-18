# Trained-network stability certificates and counterexamples

The main score is `clip(z, -.5, .5)`. Allowed joint disturbances satisfy
`sum_s ||eta_s||²/N + xi² <= c²/(1 + H Ev)`, where `Ev = N ||v||²`.
The primary constants were fixed as `.001, .003, .01, .03, .0625`.
Cap1 is a secondary comparison. The optional margin-band score and the
inverse-depth calibration are explicitly later exploratory comparisons.

## Archive scope

The report’s round3 claims use the self-contained local verifiers and the
sibling `experiment/` directory. The two retained historical search scripts
`zero_state_attacks.py` and `new_zero_state_attacks.py` depend on the previous
round2 workspace and are **excluded from round3 reproduction requirements**.
They preserve their original search semantics; their exploratory continuous
inputs are not the reported finite-grid counterexamples. No current claim
requires rerunning either script. Current saved witnesses are rechecked by
`verify_witness.py`, which has no round2 dependency.

## Distinct evidence levels

* `model-certificates/`: float64 evaluations of mathematical finite-radius
  sufficient inequalities. They are **not** outward-rounded interval proofs.
* `refined-model-certificates/`: the same records and inputs, with stronger
  asymmetric clean-transfer intervals intersected with the previous bounds.
  Prefer this record when available, otherwise use the base record.
* `global-verified-*.json`: selected all-real-input certificates using exact
  dyadic Gram entries, outward interval LDL, and a rational final inequality.
* `global-exact-verified-*.json`: selected all-real-input certificates using
  exact integer/rational matrix residuals and Gram norms. Approximate SVD
  factors are proposals only; their accuracy is not trusted. Saved factors
  under `exact-global-factors/` permit independent replay.
* `pointwise-verified-008-uniform3-c.0625/`: an outward-interval and exact-rational
  reachable-tube proof for one actual held-out image, quantifying over every
  allowed internal disturbance. This is not a global input-domain claim.
* Selected attack JSONs contain exact rational budget checks and 100-decimal
  outward interval network evaluations. A successful optimization alone is
  never labeled an interval-verified counterexample.

None of these numerical verifiers is a Lean formalization. Interval claims
trust mpmath; exact matrix norm claims use Python integer arithmetic and the
mathematical inequalities stated in `reachable-tube-certificate.tex`.
Image training/test accuracies are empirical float64 measurements. Training
eligibility is also numerical except where explicitly upgraded: the selected
exhaustive Boolean-domain proofs verify every400 training margin, and model105
has a separate exact fixed-point proof of every60,000 training margin. Their
records explicitly mark these stronger conclusions.
Model105's later exact output-label audit also resolves all10,000 test signs:
9,892 correct,108 incorrect,0 ambiguous. This additional exact confirmation is
specific to that model, not a blanket upgrade of every reported accuracy.

## Main independently checked examples

* `global-exact-verified-104.json`: full-MNIST even/odd, depth4 width256 SGD;
  global raw-score change at most .032296 at c=.003.
* `global-verified-005.json`, `global-verified-029.json`: depth16 width128 SGD
  examples with numerically positive training margins, globally certified
  at c=.001. Model029 has independently verified Boolean-input failures
  at c=.01 (`boolean-verified-029-*.json`).
* `lowink-zero-105.{json,npz}`: depth16 width256 full-MNIST SGD model, with
  all60000 training margins exactly verified above4.4815762, fails the primary global
  condition at c=.001 on a valid synthetic eight-bit low-ink black-border
  image. The verified score change exceeds.15333, and every disturbed
  hidden coordinate remains in[-1,1]. The image has no assigned digit label.
* `margin-band-target-105.{json,npz}`: explicitly postprotocol targeted
  counterexample for the optional margin-band score, also at c=.001.
  Verified band/primary score change exceeds.13714. This is a separate
  exploratory search, not part of the original score comparison.
* `confident-target-105.{json,npz}`: a later fixed-budget check starts from
  clean output .539345 and reaches .386611 using hidden noise only at c=.001.
  It violates even the one-sided preservation implication for clean outputs
  above .5. All disturbed hidden states remain in[-1,1]. The exact budget and
  both rational-pixel/original-float32 output intervals were independently
  replayed in `confident-target-105-independent-replay.json`.
* `original-preprocessing-105-verified.json`: both preceding witnesses also
  checked with exactly the float32 pixel normalization used in training.
  Their original witness records instead use exact rational pixel values;
  those admit the exact Boolean bit-decoding interpretation in the paper.
* `lowink-zero-008.*`, `pixel-grid-008.*`, and optional-band records preserve
  earlier counterexamples, including a depth32 model. Its three training
  errors are explicitly distinguished from model105's numerical eligibility.

All synthetic searches have saved fixed-budget protocols. They establish
existence, not frequency under the data distribution. No-found-attack is not
counted as a positive certificate. Low-ink witnesses remain synthetic even
though their background and mean ink are less atypical than gray images.

## Reproduction

Run from this directory with Python, NumPy, SciPy, mpmath, and Matplotlib,
and retain the sibling `experiment/` directory containing saved models.
Set `OPENBLAS_NUM_THREADS=1` for predictable CPU use.

```
python verify_global_exact.py --indices 104 --c .003 --replay
python verify_reachable_tube.py --index 8 --uniform-index 3 --c .0625
python verify_selected_boolean.py
python verify_original_preprocessing.py
python verify_optional_band.py
```

`verify_witness.verify` rechecks any saved input/noise pair directly. The
low-ink and pixel-grid scripts reproduce searches as well as verification;
there is no need to rerun a search to validate its saved witness. The exact
norm checker is independently usable as `exact_svd_bound.operator_square_upper`.

The main numerical audits are `audit_models.py` and `refine_models.py`.
Width512 uses only the first32 of the fixed uniform held-out sample;
depth64/128 uses first32 uniform, all16 boundary, and first32 cube inputs,
with no costly explicit-transfer refinement. These computational budgets
were fixed before the corresponding model outcomes. Fixed denominators in
paper figures include unassessed points as unresolved.

`legacy-float64-input-convention/` preserves preliminary continuous-input
records made before correcting normalization to the training pipeline's
float32-then-float64 convention. They are excluded from final tables.
The historical `zero_state_attacks.py` concerns previous-round models,
requires that previous archive, and its two zero-state inputs lie **outside**
the input box. These are not Boolean/box counterexamples and are superseded
by the valid finite-grid witnesses. `new_zero_state_attacks.py` is also an
older exploratory script with a previous-round attack-helper dependency;
its archived witnesses can be rechecked by the self-contained current verifier.

The exhaustive d=9 Boolean cohort has a separate predeclared exact-verification
selection in `exact-full-cube-protocol.json`. `exact_boolean_cube.py` evaluates
all512 clean trajectories with batched Python-integer interval matrix products
and outward interval tanh rounded to160-bit dyadic endpoints (320bits for deeper models). It verifies the
400 training margins as well as the selected clipped-score condition. Only a
record with `all_boolean_inputs_certified=true` proves the full finite-domain
condition; every unresolved vertex remains explicit.

All four projected-SGD models200–203 have exact global certificates atc=1/16,
but none satisfies every training margin. Continuation301 is training-eligible
and has a verified primary-radius low-ink counterexample; continuation300 still
has three training errors. Neither training outcome was discarded.
The projected continuation600 also has an exact global certificate atc=1/16
(raw-change bound .058086593), but retains154 training errors after its full
240 additional epochs. Its98.83% test accuracy does not make it eligible for
the exact interpolation likelihood. All five projected parameterizations and
their outcomes are retained.

`verify_flipped_continuation.py` negates the existing301 low-ink witness,
without optimization. It verifies a noisy output below-.32205 from clean-.00896,
so both the optional margin-band condition and later implication-only gap
condition fail. The latter condition requires for both y: clean yz>=1/2 implies
noisy yz>=7/16, and clean yz<=1/4 implies noisy yz<=5/16. This is a separate,
postprotocol variant check; the main experiment remains clipped score atcap1/2.

The frozen first-candidate exact proof is `full-cube-verified-500-c3_100/`;
all512 clipped scores are invariant and all400 training margins are verified.
The extra deeper check `full-cube-verified-501-c1_16/` has the same full-domain
conclusion atdepth16. `partition_exact_cube.py` uses shared derivative tubes
over finite groups of vertices to make the depth64 proof computationally feasible;
the partition changes only proof computation, never the domain being claimed.

`full-cube-partition-verified-504-c1_1000/` is the completed depth64 certificate:
all512 Boolean inputs have exactly invariant clipped scores; all400 training
margins are interval-verified. The global raw bound13.4145 is insufficient;
52 shared reachable-state tubes prove the claim. The exact label audit gives
511 correct,1 incorrect,0 ambiguous vertices (the error is heldout). The
smallest group saturation surplus exceeds1.4077. Verifier sources are hashed
in `exact-full-cube-verifier-source-hashes.json`, and every saved factor has its
own SHA256. Recompute from scratch with:

```
python partition_exact_cube.py --index 504 --c 1/1000 --time-limit 2400
python audit_exact_cube_labels.py
```

Do not pass `--reuse-clean-cache` for an independent reproduction: the default
regenerates all512 interval trajectories. The ephemeral `/tmp` cache is only a
computational convenience and is not part of the distributed proof artifact.

`full-cube-composite-505-c1_1000.json` certifies the recursive-majority depth64
network on all512 Boolean inputs. Its first component, the original shared-tube
certificate, retains exactly one unresolved vertex325; the second component
`point-covariance-state-verified-505-v325-c1_1000/certificate.json` proves the
same vertex using the clean-response covariance and exact nonlinear remainder
bounds. The composition changes no inputs and checks matching model/radius
hashes. All400 training margins exceed7.47388 and every all-cube absolute clean
output exceeds2.40649, both interval-verified. Accuracy is504/512 over the full
cube and104/112 on held-out inputs; the eight errors remain in the domain.

```
python partition_exact_cube.py --index 505 --c 1/1000 --time-limit 2400
python exact_covariance_state_point.py --index 505 --vertex 325 --c 1/1000
python compose_full_cube_505.py
python audit_exact_cube_labels.py
python replay_confident_target.py
```

These commands regenerate their local output artifacts. The independent audit
drivers at the archive root instead replay saved factors into temporary folders
and record source/model hashes. Saved metadata may describe the original
absolute workspace path, but the verifiers locate models and factors relative
to their own extracted directory. No reported round3 proof depends on an old
workspace path or ephemeral clean-trajectory cache.

## Exact complete-dataset verification for model105

`all-heldout-verified-105-c1_1000/certificate.json` proves stability at every one
of the10,000 official test images, using the original float32 feature map, at
**c=.001 only**, cap.5. The global component proves9,988 cases; the12 remaining
indices remain explicit and receive exact local signed-remainder/tube proofs.
The maximum certified score change is .017652163. This does not prove stability
on every possible image, and this same model has exact synthetic counterexamples.
The c=.003 complete-test-set result remains a float64 sufficient test.

`all-training-verified-105/certificate.json` verifies all60,000 signed training
margins above4.4815762 and stability at those training inputs atc=.001. Separate
directories preserve the heldout and training table/input artifacts. The method
uses guarded integer products, a rigorously enclosed piecewise-linear tanh table,
exact quantization-error propagation, and already exact matrix norm bounds.
See `fixedpoint-clean-enclosures.tex` for the proof.
`audit_105_dataset_labels.py` checks every archived label against the exact
output intervals and reproduces both the60k training guarantee and98.92% test
accuracy; its result is `model105-exact-dataset-label-audit.json`.

The single complete replay entry below recomputes all15 inherited global matrix
bounds, all10,000 heldout clean rows, all60,000 training rows, all12 local proofs,
and label comparisons. It verifies model/input/source hashes and checks that
all canonical tables, factors and certificate artifacts remain byte-for-byte
unchanged. All generated files go into temporary directories; no dataset
download is needed. The run takes several minutes on one or two CPU cores.

```
python replay_model105_70000.py --output /tmp/model105-70000-replay.json
```

For separate component replays using the same archived inputs:

```
python replay_fixedpoint_dataset.py --split test --output /tmp/test-replay.json
python replay_fixedpoint_dataset.py --split training --output /tmp/train-replay.json
```

The test command reproduces the global component; `exact_heldout_105_local.py`
reproduces the12 local proofs, and `compose_heldout_105.py` checks their complete
coverage and all model/input/source hashes. The original global unresolved rows
are retained, rather than relabeled as if the global bound had proved them.
