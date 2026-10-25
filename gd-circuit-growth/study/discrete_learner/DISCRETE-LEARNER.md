# DFG: a discrete learner that matches or beats gradient descent on the toy Boolean suite

**Question (from the user).** Use the picture of what gradient descent does (Parts 1–5 of this study) to build a *more
discrete* learner that, with similar compute and data, gets test performance at least as good as gradient descent's,
at least on the toy problems where gradient descent does well.

**Answer in one paragraph.** *Discrete feature growth* (DFG, `dfg.py`) keeps the networks' strategy and replaces their
search. Like the networks, it grows features greedily, cheapest first, against the noise of the current residual. A
feature on inputs it already uses is cheaper to find. It fits all linear directions as a background. It predicts with
the sign of a least-squares fit on what it has grown. Unlike the networks, it finds features by exhaustive enumeration
of Fourier characters, tested by explicit union-bound tests, instead of by noisy local search in weight space. Every
search runs on a subsample sized so that the whole fit stays within a fixed fraction of one network run's FLOPs.

On every suite DFG needs less data than the networks on nearly every target, using under a quarter of one network
run's compute; the numbers are in the results summary below. The cells where it is worse are almost all at n = 16–64,
where both learners are near chance. The suites are:
- the 21 designed targets;
- 20 random formulas;
- a held-out stress suite of 12 targets, fixed before the learner was frozen;
- the parity, majority and multiplexer targets at d = 15, 60, 120.

The gap is mostly the price of searching in weight space. Gradient descent pays for search in *samples*: its cost law
d·max(1, d/a)^{k−2}/ρ² from Part 2. DFG pays for search in *compute*, N candidates per degree, and only ln N in samples.

[RESULTS-SUMMARY]

## 1. The learner, and where each piece comes from

| what the networks were seen to do (study Parts 1–5) | DFG's discrete counterpart |
|---|---|
| Features are grown greedily, in order of detectability, one or a few at a time (plateaus and drops; Part 1, trajectories Part 5) | rounds of exhaustive search; everything that passes the test this round is added |
| The cost of a feature is set by its correlation with the **residual** against the noise of competing directions ("noise-limited greedy growth", Part 2) | test \|mean(r χ_S)\| > c · s · sqrt(2 ln(4 K N/δ) / n), with s = rms(residual), N = size of the candidate class; s falls as features are fit, so weaker features become detectable later |
| Composition: intermediate features on a term's own inputs make that term cheaper (the user's x1x2, x3x4 → x1x2x3x4 prediction, confirmed in Part 4) | smaller candidate classes, hence lower thresholds, for (a) extensions S ∪ {j}, S ∪ {j, l} of current features and (b) every subset of the inputs already in use (a Walsh transform on V, up to junta completion) |
| A kernel background plus a few grown features (Part 3) | a linear block (all d inputs at once when a χ²_d test says the linear part carries signal) and a final Hebbian step on the residual over all inputs |
| Dense targets: one direction is grown from many weak correlations; spiked-estimation shrinkage 1 − N/(nρ²) | a spectral block: eigen-directions of the residual pair matrix above the noise edge 2 s sqrt(d/n), with the standard shrinkage of a spiked eigenvalue; features (u·x)² |
| At every plateau the network computes the sign of a truncated Fourier expansion (Part 5) | readout: sign of the least-squares fit on the grown features (plus the background) |

The rest is engineering:
- Exact stopping: stop when nothing passes, or when every training sign is right.
- Least squares is kept to p ≤ n/2 features.
- For n ≤ 512, cross-validation decides with a paired test whether to take a "forced" best guess when nothing passes.
  At n = 16 even a perfect single-input target fails the union bound.
- The compute budget, described next.

**Compute budget.** Each exhaustive search runs on the first m training points. m is chosen so that the search stays
within a fixed fraction of one network run, `harness.gd_flops(d)` = 6P·64·20000 + 10P·20000 (1.62·10¹¹ FLOPs at d = 30):
- degree ≤ 4: 25%;
- degree 3, per round: 3%;
- degrees 5 and 6, first round only: 3% each, computed as products of character tables;
- two-input extensions, per round: 3%.

At d = 30 the budget binds only for degrees 5–6, where m is about 1400 and 150. At d = 60 and 120 it binds for degree 4
too. A parity needs only about 2 ln N/ρ² points to be found, so a small subsample loses little.

**What is discrete.** The hypothesis is a set of Boolean features: parities χ_S and, for dense targets, a few quadratic
forms. They are found by enumeration and accepted by explicit tests. The only continuous parts are the least-squares
weights of the readout and of the background.

## 2. Protocol

- **Same data as the networks.** `harness.train_data` reproduces `nn_train.make_data` row for row, with the same seeds
  and the nested training sets. The test set is the same 4096 points. DFG sees only (X, y) and an rng.
- **Network reference.** The networks' final test error at each (n, seed): fixed training set, Adam, 20000 steps.
- **Compute.** Every FLOP DFG spends is counted (multiply-add = 2), including the cross-validation fits. Prediction is
  not counted for either side. The budget per fit is one network run, which is what each (n, seed) network costs.
- **Development and freeze.** DFG was developed on the designed suite only. The random-formula suite (seen in earlier
  parts of the study, never during DFG's development) was evaluated with the final version.

  The held-out stress suite (`boolfuncs.make_dl_heldout_suite`, commit 805bff0e) was defined and its networks trained
  before DFG was frozen at commit 359a6b61. DFG was evaluated on it only after the freeze.

  One disclosure: the degree-5/6 subsampled search was added before the freeze, knowing that par5 was in the held-out
  set. The argument for it is general — a compute budget left unspent on high degrees — but it was not blind.

[RESULTS]

## Reproduce

```
cd study/discrete_learner
python run_eval.py dfg:DFG designed        # also: random, dlheld, designed_d15 / _d60 / _d120
./run_ablations.sh; python make_tables.py  # RESULTS.md
```
The network reference files are the study's `fixed_adam_<fn>.npz` (Part 1; the held-out ones from
`SUITE=dlheld python nn_train.py --fns all --out <dir>`).
