# Empirical investigation of population-averaging restrictions

This is exploratory evidence about the **support conditions** in the improved-polynomial learning results. It is not a Bayesian-inference experiment or a sample-complexity measurement. The main finding is mixed: signed populations remove a substantial representation artifact and admit some ordinary gradient-trained networks at very small population counts, but these experiments do not establish that the restriction generally holds for trained networks.

The strongest positive example is an ordinary Adam-trained four-hidden-layer network of width 32, initialized from the theorem's mean-field Gaussian prior. Its readout energy is 3.533674. A single signed population in each layer preserves its clipped output **exactly on all 256 Boolean inputs**. This statement has an exhaustive outward-rounded interval certificate. It concerns the signed variant, not the original unsigned condition.

## Conditions and measurements

For width `N`, let `Ev = N * ||v||_2^2` and let `T(z)` clip the scalar output to `[-1/2,1/2]`. The baseline condition asks for populations with `q <= 1 + Ev` such that the maximum, over the entire Boolean cube, of the change in `T(z)` is at most `1/16`.

We distinguish four classes: unsigned balanced populations (the original condition); signed balanced populations; unsigned populations with arbitrary nonzero group sizes; and signed populations with arbitrary nonzero group sizes. Signed averaging uses a sign for each neuron, equivalently a function-preserving tanh sign-gauge change followed by ordinary averaging. These are different support conditions. The signed or unbalanced search classes include every witness found by their more restrictive subclasses; counts below use this inclusion explicitly.

**Automatic cases are separated.** If `Ev >= N-1`, choose `q=N` and the identity projection. This proves population-support membership without any compression. It says nothing by itself about the optional internal-noise support condition or training fit.

We also test the two alternative budgets `q <= 1 + 4 Ev/M_infinity^2`, where `M_infinity = max_x |z(x)|`, and `q <= 1 + 4 Ev/||v||_1^2`. These leave the saved network unchanged. The first uses a float64 exhaustive estimate of the maximum on the small Boolean cube. A separate diagnostic scales the readout so that the full-cube output RMS becomes one. That diagnostic **changes the network**, its energy, and potentially its margin eligibility; it is not pooled with raw-weight results. A preliminary coefficient 16 budget is retained under an explicitly exploratory name.

## Existing checkpoints

An exact rational inventory covers 173 saved trained networks: 168 from the earlier round-two experiments and five published representatives. Of these, 103 satisfy the baseline condition automatically with `q=N`; 70 require actual compression. Every decision uses the exact stored binary weights. The two separately saved random teachers are excluded from the trained-network count.

Earlier protocols initialized the readout at standard deviation `1/sqrt(N)`, giving expected initial `Ev=N`. The theorem's mean-field readout has standard deviation `1/N`, giving expected initial `Ev=1`. Thus automatic successes in the earlier cohort are weak evidence about the low-energy networks relevant to the new restriction.

The exhaustive cube study includes 112 earlier Boolean networks and three public Boolean representatives. The other 58 inventoried models have image-sized domains and were not included in exhaustive compression tests. Among the 112 earlier Boolean networks, 51 are automatic and 61 have nontrivial caps. The activation-clustering search finds witnesses for 11/61 in the original unsigned balanced class, 16/61 in the signed balanced class, 19/61 in the unsigned unbalanced class, and 24/61 in the signed unbalanced class. Of those 61, 54 have every original training margin above 1/2. These heterogeneous historical runs were not selected to estimate a population frequency.

## Fresh mean-field-initialized training

All 40 new configurations are included, with every outcome retained. Inputs are Boolean; there are no internal biases; the first layer uses an appended constant input. Initialization has independent Gaussian variances `1/d`, `1/N`, and `1/N^2` in the first layer, subsequent hidden layers, and readout. No output rescaling is performed after training.

- Sixteen runs use `d=8`, four hidden layers, widths 32 or 64, majority-of-five or parity-of-three labels, SGD or Adam, and two seeds. They use 128 distinct training inputs, 4000 full-batch mean-square-error steps, ordinary weight decay `1e-6`, and a fixed learning-rate decay near the end.
- Twenty-four runs use `d=9`, two or three hidden layers, widths 32 or 64, majority-of-five, parity-of-three, or recursive-majority-of-nine labels, and two seeds. They use 128 distinct training inputs, 3000 Adam mean-square-error steps, and no weight decay.

These are ordinary parameter-gradient updates, without layerwise gradient rescaling or a population penalty. All 40 runs achieve every training margin above 1/2. Five satisfy the baseline population condition automatically; 35 require compression.

The frozen activation-clustering search (`results-v3`) uses at most 256 unlabelled input probes and two initializations per method and population count. Balanced assignments use a linear-assignment step; arbitrary-size assignments use nearest centers with nonempty-group repair. Every candidate is evaluated on the full cube. Target labels are used only to report the original training fit, after the grouping procedure.

The separate `q1-output-results` follow-up initializes neuron signs by correlation with the network's own outputs and then greedily flips signs to reduce the clipped-output discrepancy. It uses no target labels. This small additional search finds 11 signed balanced `q=1` witnesses among the 40 fresh networks: all eight shallower majority networks and three of the four-layer Adam-majority networks. It materially changes the conclusion relative to activation clustering alone.

| Budget, fresh 40 networks | Automatic `q=N` | Nontrivial cases | Signed balanced witnesses, clustering only | Signed unbalanced witnesses, clustering only | Signed balanced witnesses after the `q=1` follow-up |
|---|---:|---:|---:|---:|---:|
| `q <= 1 + Ev` |5|35|5|6|14|
| `q <= 1 + 4 Ev/M_infinity^2` |19|21|10|10|13|
| `q <= 1 + 4 Ev/l1(v)^2` |0|40|4|6|12|

The original unsigned balanced activation search finds 0/35 witnesses among the nontrivial fresh baseline cases. This is **not a proof that those networks fail the condition**. The success of the additional sign search illustrates how incomplete the clustering procedure is. Likewise, the better totals for the output-normalized budget must be read alongside its larger number of automatic cases.

The six nontrivial baseline successes from activation clustering alone are `fresh-002`, `fresh-003`, `freshH23-000`, `freshH23-001`, `freshH23-003`, and `freshH23-009`; complete names and witnesses are retained in the records. The follow-up adds eight new nontrivial successes. All 14 combined nontrivial successes have a signed balanced witness, so arbitrary group sizes are unnecessary for these particular combined successes.

`compression-curves.pdf` shows activation-clustering curves only, explicitly excluding the later output-aware search. `energy-versus-compression.pdf` includes that follow-up. The smallest passing population count shown is the smallest one **found by the finite search**, not a lower bound on the optimal count.

## Three exhaustive interval certificates

The independent audit verifies projection formulas, group-size constraints, readout-energy budgets, and absence of target-label use. It then evaluates original and exactly projected networks using exact rational sums of the stored weights and outward-rounded 50-decimal interval arithmetic:

| Saved network | Population witness | Certified result on all 256 inputs |
|---|---|---|
| `round2-000-heldout8-majority5-H4-adam-s0-g1.1` | Original unsigned balanced, `q=28<N=32` | Clipped outputs agree exactly; both absolute outputs exceed 0.61609. |
| `fresh-002-majority5-H4-N32-sgd-s0` | Signed unbalanced, `q=24<N=32` | Clipped outputs agree exactly; both absolute outputs exceed 0.80876. |
| `fresh-000-majority5-H4-N32-adam-s0` | Signed balanced, `q=1<N=32` | Clipped outputs agree exactly; both absolute outputs exceed 0.535955. |

These are numerical interval proofs relying on the arithmetic library, not Lean proofs. Other positive witnesses are exhaustive float64 checks. No failed search is reported as a counterexample to an existential support condition. Optional internal-noise robustness is not inferred from population membership.

For these three witnesses, a simple operator-norm sufficient route from internal-noise robustness requires calibration constants approximately 19.28, 20.28, and 10.22. Those conservative values are much larger than the small calibrations used in the previous robustness experiments. The failure of this sufficient route does not contradict their directly certified population stability.

## Replay and contents

Install NumPy, SciPy, and mpmath, then run:

```sh
python replay.py --interval
```

This verifies the hashes of the 44 included checkpoints, re-evaluates the selected eligible witnesses from the included frozen records in float64, and independently reruns the three interval certificates. Without `--interval`, it performs only the faster numerical replay. `replay-results.json` records the publication preparation check.

The package includes all 40 fresh final checkpoints, all 155 exhaustive compression records as JSON gzip files, every fresh training protocol and outcome, all 40 output-aware follow-up records, the selected old certified checkpoint, and the three public Boolean checkpoints. It deliberately omits 111 other historical Boolean checkpoints and the 58 image checkpoints; their hashes and outcomes remain in the inventory and record collection. The frozen numerical records for omitted checkpoints are not presented as independently replayable from this package alone. The full original initial-weight snapshots are omitted; fixed seeds and training code permit regeneration. No failed fresh run was omitted—there were no optimization or nonfinite failures in either fixed fresh cohort.

`compression.py --workers 3` reruns the activation-clustering search for included checkpoints into a separate `recomputed-results` folder. The training scripts are portable: to retrain, copy either `training-h4/train.py` or `training-h23/train.py` into its own empty directory and run `python train.py --declare --run`. The scripts refuse to overwrite an existing declared cohort. Changing NumPy/BLAS versions may change optimization trajectories; the saved weights are the fixed reference for witness replay.

`original-source-snapshots` and the independent audit records preserve the source versions and hashes used during research; their original workspace paths are historical provenance. `replay.py` and `dataset-manifest.json` provide portable paths. This package reports exploratory research, including unsuccessful searches and changes of search method, rather than a preregistered estimate of how often practical neural networks satisfy the condition.
