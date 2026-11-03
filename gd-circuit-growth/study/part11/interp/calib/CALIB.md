# False admissions and where the compute goes: DFG v1.3 alone (Part 11, Q7)

Part 11, Q7 (PROTOCOL.md): "false admissions: DFG on labels independent of the inputs; where the compute goes". The
object is DFG v1.3 run alone: `part10/hyb_portfolio3/dfg13.py`, md5 `69cabe5c50345cb24079198ed52b562f`, as
`DFG(readout="logit").fit` (its own cross-validation at n ≤ 512, kernel background and budget), loaded by
`part11/eval_dfg.load_dfg13()` (md5 checked). Written 3 November 2026. The record-writing job was killed by a container
restart at about 01:09 UTC with A1 at d = 60 (8 of 220 fits), B (32 of 105 records) and the cascade check (0 of 800)
unfinished; they were resumed from the records (keys already written are skipped, so no cell was fitted twice), and
every table was regenerated from the complete records. Not yet checked by independent verifiers.

Labels: **Proved** (a proof is given), **Numerical** (measured; the source file is named), **Heuristic** (my reading).
Every count is given with its denominator; intervals are two-sided 95% Clopper–Pearson.

**Files** (all in this folder):
- [`make_instr.py`](make_instr.py) builds [`dfg13_instr.py`](dfg13_instr.py), a copy of `dfg13.py` with 64 lines
  added and none changed: calls into the recorder [`calib_rec.py`](calib_rec.py), which only read (the FLOP counter
  `fl[0]`, the process clock, statistics DFG has just computed) and append to their own lists. Rebuilding it gives the
  same file byte for byte (md5 `be56ce50…`).
- [`calib.py`](calib.py) runs everything: `audit`, `noise` (A1), `spur` (A2), `prof` (B), `cascade` (A1, §1.5).
  Records: `results/noise.jsonl` (one line per fit), `results/spur.jsonl`, `results/prof.jsonl`,
  `results/cascade.jsonl`. The full set is `audit; noise --d=30; noise --d=60; spur; prof --reps=0-2; cascade`.
- [`calib_summary.py`](calib_summary.py) (or `calib.py summarize`) turns the records and the evaluation's result files
  into [`calib.json`](calib.json) and [`calib_tables.txt`](calib_tables.txt). Every number below is printed in
  `calib_tables.txt`, including the ones derived by hand from the code (its first section, `derived()`).

## Short answer

- **The instrumented copy is the frozen learner** (Numerical, §0). Every fit made with it equals a fit of the frozen
  module on the same data, or the evaluation's result file, in test error and FLOP count: ⟦A1 frozen⟧ A1 fits, 451 of
  451 A2 fits, 35 of 35 B cells against the frozen module and 31 of 31 (93 of 93 records) against the result files.
- **On balanced labels independent of the inputs, nothing passes a test** at d = 30: 0 of 220 final fits (95% ≤ 0.017)
  have a test-passed feature; ⟦D60 short⟧. The round-0 character classes have level ≤ δ/(2K) = 0.0125 each
  (P-A, Proved); pooled over both label rates at d = 30 they fired in 2 of 2400 class searches (both degree 1, at
  P(y = 1) = 0.8), against ≈ 0.001 per class from an independent-Gaussian approximation.
- **On biased labels (P(y = 1) = 0.8) the two dense block tests fire at small n** (Numerical, §1.2, §1.4): 6 of 220
  final fits at d = 30 (0.010–0.058) admitted something: the linear block twice (n = 64, 128), the spectral block twice
  (n = 128) and a degree-1 character twice. ⟦MC short⟧
- **The forced variant is not calibrated after its forced characters** (Numerical, §1.5): in its fold fits the local
  class admits the product of the two forced characters. At P(y = 1) = 0.8, 238 of 900 forced fold fits (d = 30) hold
  a test-passed feature after the forced ones (205 of them local characters); in 400 fold-sized re-runs the local test
  after the second forced character passes in 244 of 334, and after two random characters of the same degrees in 0
  of 334. Every admitted local character has degree |A Δ B| for forced A, B, and where A and B are disjoint (190 of
  214) it is χ_A χ_B. The cross-validation never chose the forced variant at P(y = 1) = 0.8 (0 of 120) and chose it in 5
  of 120 balanced fits (two forced characters each, test error 0.491–0.500).
- **Test error on fresh noise** (Numerical, §1.2): balanced labels 0.497–0.504 by n (the test set has P(y = −1) =
  0.4895); biased labels 0.339 at n = 16, falling to the test minority rate 0.1946 from n = 1024 on. The excess is the
  kernel background's random direction, not admitted features: err = a + q(1 − 2a) (a = 0.1946, q = P(predict −1))
  reproduces the mean error at every n to within 0.001.
- **Spurious features on the designed and random targets** (Numerical, §2): of the 4499 terms admitted in 451 fits,
  1047 read an irrelevant input (0.233), and 961 of these are the linear block's degree-1 characters, which the block
  adds for every input not yet in the model. The others are 86 of 3364 terms (0.026). By n, the count share falls
  from 0.69 at n = 64 to 0.08 at 16384 (without the linear block's characters 0.044 → 0.005), and the spurious terms'
  share of the model's output from at most 0.86 (n = 64) to at most 0.086 from n = 2048 on, with median 0 at every n.
  Removing them lowers the mean test error by 0.020 at n = 64 and changes it by ≤ 0.0001 from n = 128 on. Only 2
  characters were admitted by their own test in round 0 while reading an irrelevant input (both wholly on irrelevant
  inputs), against 2.2 expected from the Gaussian approximation and at most 29.8 by P-A′ (Proved).
- **FLOPs are set by the fixed-share searches** (Proved by reading the counter, checked exactly on all 275 profiled
  `_fit` calls; §3.1–3.2): at d = 30 degrees 1–4 cost 768,390 FLOPs per training row and the degree-5 and degree-6
  subsample searches 0.030 of a network run each, so any fit costs 0.079 of a network run at n = 4096 and 0.137 at
  16384 before anything else; at n = 64 the degree-6 search is 50–64% of the FLOPs and the fold fits 27–43%. The
  largest fits (0.32–0.52 of a network run, n = 16384) are those with many features, where the logistic readout is
  41–47% of the FLOPs.
- **CPU time follows the sum-block search instead** (Numerical, §3.3): it runs at 0.75 GFLOP/s, against 17 for the
  character searches and 33 for the readout; inside the fold fits at n = 64 it takes 94–95% of the CPU time for 42–46%
  of the FLOPs. So in the result files the slowest fits are at n = 64–512 (suite medians 2.2–9.2 s at d ≥ 30, largest
  17.4 s), where the FLOP count is smallest.
- **Every suite** (Numerical, §3.4): no fit of the 4730 in the result files uses more than 0.519 of a network run
  (h5s5, n = 16384, seed 2); at d = 30 every fit at n ≤ 512 stays below 0.096. DFG's own cap (a round starts only below
  0.75 of the call's budget) stopped none of the 5715 recorded `_fit` calls; the largest spent 0.471 of its budget.

## 0. What was measured, and how

**The instrumented copy is the frozen learner** (Numerical, `calib.py audit`, `calib.json` `audit`, `B.checks`):
- `audit`: difflib between `dfg13.py` and `dfg13_instr.py` finds only inserted lines, all of the form `_P.<hook>(...)`
  or the recorder's import (64 lines; 878 → 942). The recorder's hooks return nothing and change no array DFG uses.
- Every fit made with the copy was checked, bit for bit, on test error and total FLOP count:
  - against the evaluation's merged result files (A2: all 451 seed-0 cells of the designed and random suites; B:
    every profiled cell of a suite, in each of its three records);
  - against a fit of the frozen module on the same data in the same process (B: every profiled cell; A1: seeds 0 and
    1 of every (d, p, n), ⟦A1 frozen⟧ fits).
  All checks are equal.

**Regions** (B). `DFG._fit` is cut into consecutive regions by `REC.enter(name)`; the FLOP-counter increments and
CPU seconds between two marks go to the region entered first, so the regions of one `_fit` call add up to its FLOP
count (largest relative closure error 2.1·10⁻¹⁶ over the 35 cells) and its CPU time. The recorder's own detail work is
subtracted from the clock. Regions: the global character search by degree (`deg 1`: the vector X^T r / n; `deg 2`: the
residual pair matrix M, which the blocks reuse; `deg 3`, `deg 4`; `deg 5`, `deg 6`: the first-round subsample
search), extension (one and two inputs), local (the Walsh transform on the inputs in use), the linear block test, the
spectral block (eigendecomposition of M), the sum-block search (setup, additive, product, split, candidate-pair
products, modulated, products of accepted blocks), least squares, the logistic readout, and other (bookkeeping,
adding feature columns, the background, the training error). `DFG.fit`'s fold fits at n ≤ 512 are separate `_fit`
calls; what lies outside every `_fit` call (prediction on the held-out folds) is reported separately.

**Detail records** (A). Per round and candidate class: the number of distinct candidates that pass their test and
the largest ratio |statistic| / threshold (≥ 1 passes), mirroring DFG's `offer()` (a candidate counts only if it is
not yet in the model); for the subsampled degree-5/6 search, whose code offers only the passing candidates, the
largest ratio is computed from the coefficient matrix over the disjoint pairs. Also the linear block's χ² ratio, the
spectral block's top |eigenvalue| over its edge, every sum-block search's best T / threshold, every admission with
the class or code path that made it, and for every feature of the model its origin, aligned with DFG's feature list.
A character's class is the class whose test gave it the score DFG keeps (`cand[S]` keeps the largest).

## 1. (A1) False admissions on labels independent of the inputs

### 1.0 Data and fits

- d = 30: P(y = 1) = p ∈ {0.5, 0.8}, n ∈ {16, 32, …, 16384}, 20 seeds per (p, n): 440 fits.
- d = 60 (the smaller check): the same p and n, 10 seeds: 220 fits.
- Training data in the harness's style (`harness.train_data`): `rng = default_rng([fn_seed(name), seed])`,
  X = 16384 × d uniform ±1 (float32), y iid with P(y = 1) = p from the same rng, the first n rows (nested in n);
  name = `noise_p50_d30` etc. Test: 4096 fresh points from `default_rng([fn_seed(name), 10**6])`. Fit rng
  `default_rng([fn_seed(name), seed, n, 77])`, as the harness. DFG is fitted directly, without `Permuted` (the
  inputs are exchangeable).
- "Admitted feature" = a feature of the final model (the fit on all n rows that predicts). The cross-validation's
  fold fits are reported separately (§1.5), and so is a re-run of fold-sized forced fits (`cascade`: 200 draws for each
  P(y = 1) ∈ {0.5, 0.8} and n ∈ {29, 58}, the fold sizes at n = 32 and 64; `_fit(force=True, hi=False, scale=1/40)`
  exactly as `DFG.fit` runs them; d = 30).

### 1.1 What the tests promise

**P-A (Proved).** Let the rows of X be iid uniform on {±1}^d and y independent of X. In round 0 of any `_fit` call,
for each global character class of degree k searched on the first m rows (degrees 1–4; and 5–6 in the first-round
subsample search), P(at least one character of degree k passes its test) ≤ δ/(2K) = 0.0125 (δ = 0.1, K = 4, c = 1).
The six classes together: ≤ 0.075.

*Proof.* In round 0 the model is the constant alone: `lsfit` solves (n + 10⁻⁹) w = Σ y (the ridge term is zero on the
constant), so r = y − w depends on y only, and r is independent of X. The statistic of χ_S is v_S = (1/m) Σ_{i ≤ m}
r_i χ_S(x_i): for degree 1 and 2, `c1 = X^T r / n` and `M = (X r)^T X / n` (m = n); for degrees 3 and 4 the entries of
`Ma`, `Mab` on the first m rows; for degrees 5–6 the entries G[p, q] = mean(r χ_{T1} χ_{T2}) over disjoint T1, T2,
which equal mean(r χ_{T1 ∪ T2}) (overlapping pairs are skipped). The threshold is `thr(N)` = c s √(2L/n) with
s = rms(r) when m = n, and `thr_m(N, m)` = thr(N) √(n/m) rms(r_{1..m}) / s = c rms(r_{1..m}) √(2L/m) when m < n, with
L = ln(4KN/δ) and N = C(d, k); so in both cases S passes iff |Σ_{i≤m} r_i χ_S(x_i)| > c √(2L Σ_{i≤m} r_i²). (If
s < 10⁻⁶ the loop stops before any test.) Conditionally on y, for S ≠ ∅ the χ_S(x_i), i ≤ m, are iid uniform signs
independent of r, so by Hoeffding's inequality for weighted Rademacher sums the probability is ≤ 2 exp(−c²L) =
2δ/(4KN). A union bound over the N characters of the class gives δ/(2K), and over the six classes 6δ/(2K). ∎

**P-A′ (Proved; the same argument on any target).** Let y = f(x) depend only on a set R of inputs. In round 0 of any
`_fit` call, for each global class of degree k, P(some character χ_S with S ⊄ R passes) ≤ (N_irr/N) δ/(2K) ≤ δ/(2K),
N_irr = C(d, k) − C(|R|, k). *Proof.* r = y − w is a function of the rows' inputs in R. For S containing an input
j ∉ R, χ_S(x_i) = x_ij χ_{S∖j}(x_i), and conditionally on y and on all inputs but column j, the x_ij are iid uniform
signs; so Σ_i r_i χ_S(x_i) is a weighted Rademacher sum with Σ (weights)² = Σ r_i², and the bound of P-A holds for
each such S; the union is over N_irr of them. ∎ (§2.2 uses it.)

The bounds are not tight: for N independent Gaussian statistics at these thresholds the probability is
1 − (1 − 2Φ(−z))^N = 0.0008–0.0012 per class (z = √(2L) = 4.12 for degree 1 up to 6.06 for degree 6 at d = 30), about
10× below δ/(2K), because Hoeffding's bound has no Mills-ratio factor (Heuristic; the statistics are pairwise
uncorrelated and nearly Gaussian for m ≫ 1, and for N ≫ m dependent, which I expect lowers their maximum).

What P-A does not cover:
- **later rounds**: once a feature is in the model, the residual depends on X through it;
- **the linear block**: n |X^T r / n|² / s² against k + 2√(kt) + 2t, t = ln(1/δ), Laurent–Massart's bound for a
  Gaussian χ²_k at level δ = 0.1; the exact χ²₃₀ tail at that threshold (51.23) is 0.0092, the χ²₆₀ tail at 88.11 is
  0.0105;
- **the spectral block**: the top |eigenvalue| of the residual pair matrix (diagonal removed) against the Wigner
  edge 2s√(d/n)·(1 + √(2 ln(1/δ)/d)), for n ≥ 4d; no level is proved for it;
- **the sum-block tests**: T = |projection of r onto a block's level indicators|² / s² against Laurent–Massart's
  χ²_m bound at exp(−t_k), t_k = ln(4K·C(d,k)·2^{k−1}·2·n_mod·24/δ). If each T were exactly χ²_m, the union bound over
  every (S, s) of every size k = 2 … 24, both folds and the n_mod modulators would give 23δ/(4K·24) = 0.0060 ≤ δ/(4K)
  for all additive blocks together (weighted blocks have their own, half as large share); the block is searched on
  the residual and must also pass on the residual projected off the round's new characters;
- **the forced variant** (n ≤ 512): when nothing passes it takes the best-scoring candidate character (in the re-run
  of §1.5 a global one, except 4 of the 734 second forced characters, which came from the local class), or, at
  n ≥ 48, the best sum block if its T / threshold exceeds the square of the best character's ratio; at most twice. It
  is used only if the paired cross-validation test prefers it.

### 1.2 What was admitted, d = 30

(Numerical, `results/noise.jsonl`, `calib.json` `A1.by_cell`, `A1.totals`; full table `calib_tables.txt`.) 20 fits
per cell.

| n | p = 0.5: fits with any feature | of which CV chose forced | test-passed | test error (mean) | p = 0.8: fits with a test-passed feature (what) | CV chose forced | test error (mean) | P(predict −1) |
|---|---|---|---|---|---|---|---|---|
| 16 | 2 | 2 | 0 | 0.500 | 0 | 0 | 0.339 | 0.234 |
| 32 | 1 | 1 | 0 | 0.504 | 0 | 0 | 0.319 | 0.203 |
| 64 | 1 | 1 | 0 | 0.500 | 1 (linear block, 30 characters) | 0 | 0.274 | 0.130 |
| 128 | 0 | 0 | 0 | 0.502 | 3 (linear block 1; spectral block 2) | 0 | 0.232 | 0.060 |
| 256 | 1 | 1 | 0 | 0.502 | 1 (a degree-1 character) | 0 | 0.206 | 0.018 |
| 512 | 0 | 0 | 0 | 0.502 | 0 | 0 | 0.196 | 0.003 |
| 1024–8192 | 0 | – | 0 | 0.497–0.501 | 0 | – | 0.195 | 0 |
| 16384 | 0 | – | 0 | 0.499 | 1 (a degree-1 character) | – | 0.195 | 0 |
| all | 5/220 | 5/120 (n ≤ 512) | **0/220** (95% ≤ 0.017) | | **6/220** (0.010–0.058) | 0/120 | | |

- **Balanced labels: nothing passes a test** (0 of 220 fits, every n). The only features are the forced variant's,
  in the 5 of 120 fits at n ≤ 512 where DFG's paired cross-validation chose it: two forced characters each (degrees
  1–4). Their test errors (0.491–0.500) are those of the fits without features. 215 fits stopped in round 0 with
  nothing passed, the other 5 after their two forced rounds.
- **Biased labels: 6 false admissions in 220 fits, at n = 64–256 and once at 16384**: the linear block twice
  (n = 64, 128; χ² ratio 1.10 and 1.07, i.e. T = 56.5 and 54.9 against 51.23), adding all 30 inputs (test error 0.336
  and 0.283 against 0.195); the spectral block twice at n = 128 (eigenvalue ratio 1.011 and 1.054; in the first fit a
  second spectral feature entered in round 1 at ratio 1.083, after the first had lowered s; test error 0.234, 0.213);
  a degree-1 character twice (n = 256: test error 0.244; n = 16384: 0.195). In 5 of the 6 nothing further entered.
  The cross-validation never chose the forced variant at p = 0.8 (0/120).
- **Test error on fresh noise** (Numerical; the mechanism Heuristic). p = 0.5: 0.497–0.504 by n (the test set has
  P(y = −1) = 0.4895). p = 0.8: 0.339 at n = 16, falling to 0.1946 = the test set's minority rate from n = 1024 on.
  The excess at small n is the kernel background, not admitted features (at n = 16 and 32 no fit has a feature):
  the model is sign(w₀ + x·b) with w₀ = ȳ and b = X^T r / n, whose d coordinates are each ≈ N(0, s²/n), s² = 1 − ȳ²,
  so a test point is predicted −1 with probability ≈ Φ(−w₀√n / (s√d)). With w₀ = 0.6, s = 0.8 this is 0.29, 0.14,
  0.014 at n = 16, 64, 256; with each fit's own ȳ (fits without features) 0.224, 0.124, 0.012; measured 0.234, 0.130,
  0.018. Since the predictions do not depend on the test labels, the error is a + q(1 − 2a) = 0.1946 + 0.6108 q
  (q = P(predict −1)), which gives 0.3378, 0.2741, 0.2055 at n = 16, 64, 256 against the measured 0.3386, 0.2738,
  0.2056 (within 0.001 at every n). Part 6's remark that DFG is "sometimes above the constant predictor's error" at
  n = 16–64 (`discrete_learner/DISCRETE-LEARNER.md`) fits this: on such data the Hebbian background carries no
  information and costs up to 0.144 in error on biased labels.

### 1.3 Per class, against the nominal levels

(Numerical, `calib.json` `A1.by_class`, `A1.by_class_pooled`, `nominal`; Gaussian reference Heuristic.) Round 0 of
the final fit, d = 30, both p, all n where the class runs (degrees 3–4 need m ≥ 32 rows, degrees 5–6 m ≥ 64):

| class | N | round-0 tests | fits with ≥ 1 pass | bound δ/(2K) (P-A) | independent-Gaussian approx. | median max-ratio, p = 0.5, n ≥ 128 | Gaussian reference |
|---|---|---|---|---|---|---|---|
| degree 1 | 30 | 440 | 2 (0.0006–0.016) | 0.0125 | 0.0012 | 0.524–0.603 | 0.553 |
| degree 2 | 435 | 440 | 0 (≤ 0.0083) | 0.0125 | 0.0010 | 0.633–0.681 | 0.669 |
| degree 3 | 4060 | 400 | 0 (≤ 0.0092) | 0.0125 | 0.0009 | 0.695–0.741 | 0.727 |
| degree 4 | 27405 | 400 | 0 (≤ 0.0092) | 0.0125 | 0.0009 | 0.746–0.773 | 0.762 |
| degree 5 (m = min(n, 1374)) | 142506 | 360 | 0 (≤ 0.010) | 0.0125 | 0.0008 | 0.774–0.790 | 0.785 |
| degree 6 (m = min(n, 147)) | 593775 | 360 | 0 (≤ 0.010) | 0.0125 | 0.0008 | 0.791–0.803 | 0.802 |

(The "max-ratio" is the largest |statistic| / threshold in the class; the reference is the median of max |Z|/z over N
independent N(0, 1).) Both degree-1 passes are at p = 0.8. The later rounds of the final fits (after a forced or a
false feature) ran 14, 16 and 13 tests of degrees 1, 2, 3, 13 one-input and 10 two-input extension tests and 9 local
tests, with no pass. Against the task's nominal "δ = 0.1 per class per round" every class is far below; against the
sharper δ/(2K) = 0.0125 of P-A every rate is compatible with it, and 5 of 6 classes are compatible with the ~0.001 of
the Gaussian approximation (degree 1: 2/440 where 0.5 is expected; ⟦MC g1⟧).

### 1.4 The block tests

(Numerical, `calib.json` `A1.blocks`, `mc`, `mc_big`.) ⟦BLOCKS⟧

### 1.5 The forced variant and the cross-validation's fold fits

(Numerical, `calib.json` `A1.folds`, `A1.folds_total`, `cascade`; mechanism Heuristic.) At n ≤ 512 every fit also runs
2F fold fits (F = 10 at n ≤ 64, else 5): F of the default variant and F of the forced one, on (F−1)/F of the rows,
without the degree-5/6 search and with 1/(4F) of the budget each.

| d = 30 | default fold fits with an admitted feature | forced fold fits with a test-passed feature after the forced ones |
|---|---|---|
| p = 0.5 | 2/900 (a degree-1 character; the linear block) | 12/900 (0.007–0.023): the local class in 9 fits; linear block 2, two-input extension 1, degree 1 1 |
| p = 0.8 | 9/900 (linear block 3, spectral 3, sum blocks 2, degree 1) | **238/900** (0.236–0.295; n = 32: 121/200; 64: 73/200; 128: 28/100; 256: 15/100; 512: 1/100): the local class in 205, sum blocks in 24, the linear block 3, spectral 4, one-input extension 2, degree 1 1 |

The forced fold fits forced a character in 900 of 900 (p = 0.5) and 813 of 900 (p = 0.8), a sum block in 11 and 179.

**What the local class admits after two forced characters** (`results/cascade.jsonl`; `calib.json` `cascade`). The
re-run records, for each fold-sized forced fit, DFG's own admissions and, after the first and after the second forced
character, DFG's local test recomputed twice: on V = the inputs of the forced characters, and on V = the inputs of
random characters of the same degrees (least squares on the constant and those characters, then every subset of V not
in the model against `thr(C(|V|, |T|))`, as `_fit` does):

| P(y=1) | n | DFG: fits with a local pass | after the 1st forced character: forced V / random V | after the 2nd: forced V (median max-ratio) | random V (median) |
|---|---|---|---|---|---|
| 0.5 | 29 | 4/200 | 0/166 / 0/166 | 4/200 (0.51) | 1/200 (0.49) |
| 0.5 | 58 | 2/200 | 0/189 / 0/189 | 2/197 (0.61) | 1/197 (0.64) |
| 0.8 | 29 | 116/200 | 0/147 / 0/147 | **146/199** (1.17) | **0/199** (0.48) |
| 0.8 | 58 | 99/200 | 0/133 / 0/133 | **98/135** (1.16) | **0/135** (0.61) |

- Every local character DFG admitted in these fits came after two forced characters A, B and has degree |A Δ B|
  (4/4, 2/2, 116/116, 98/98); where A and B are disjoint (4/4, 2/2, 114/116, 76/98 of those fits) the only subset of
  V = A ∪ B of that degree is V itself, so the admitted character is exactly χ_A χ_B. (At n = 58 and p = 0.8, 64 of
  the 200 fits forced a sum block instead of one or both characters.)
- So at p = 0.8 the local test passes after selected characters (244 of 334) and not after random ones of the same
  degrees (0 of 334): the excess comes from the selection. A reading (Heuristic): with P(y = 1) = 0.8 the residual's large entries are the minority rows (r ≈ −1.6 against +0.4),
  and the character that best correlates with it is one that is nearly constant on those rows; so is the second, and
  then so is their product, which least squares on {1, χ_A, χ_B} leaves in the residual and which the local class tests
  with N = 1 (threshold z = √(2 ln 160) = 3.19 when A, B are disjoint). With balanced labels a character aligned with
  the residual is aligned with y, and the product of two such characters with y² = 1, the constant.
- The paired test protects the final fit: at p = 0.8 the cross-validation chose the forced variant in 0 of 120 fits.
  ⟦D60 forced⟧

⟦D60 SECTION⟧

## 2. (A2) Spurious features on the designed and random targets

### 2.0 Fits and definitions

- The 21 designed and 20 random targets at d = 30, seed 0, every n of the grid (16 … 16384): 451 fits, each exactly
  as `eval_dfg.py` makes it (`harness.train_data` / `test_data`, fit rng `default_rng([fn_seed(t), 0, n, 77])`, the
  column permutation that `Permuted` draws from it, `DFG(readout="logit")`). The permutation is undone through the
  `pi` that `Permuted` stores in its prediction function: learner column j is original input pi[j]. All 451 equal the
  evaluation's result files in test error and FLOPs.
- **Relevant set**: the inputs the target depends on, computed exactly. Every designed and random target reads only
  x[:, :k] with k ≤ 10 (`boolfuncs.py`: explicit indices below 10; `_random_formula(rng, k, ·)` reads x[:, :k],
  k ≤ 8), so enumerating all 2¹² assignments of the first 12 inputs (the others +1) decides, for each of them,
  whether flipping it ever changes f; flipping each input 12–29 was also checked on 20000 random points (never).
  The exact sets equal the suites' `relevant` lists for all 41 targets (Numerical, `calib.json` `A2.relevant`); their
  sizes are 1–10, so every target has 20–29 irrelevant inputs.
- **Terms**: the final model as terms in original coordinates (as `part10/interp/hooks.dfg_terms` and
  `dfg_hooks.model_terms`): each character χ_S; each sum block with all its level indicators as one term (support =
  its set, modulator, inner term and product factors); each spectral feature (u·x)² − |u|²; the kernel background is
  not an admitted feature and is left out. A term is **spurious** if it reads an irrelevant input; a spectral feature
  if less than 90% of |u|² lies on relevant inputs (the atlas's rule; its support, |u_i| > 0.1 max|u|, is recorded
  too).
- **Kinds**: `chi_test` (a character admitted by its own test: global degree k, extension, local), `chi_lin` (a
  degree-1 character that entered with the linear block, which adds every input not yet in the model), `chi_forced`
  (the forced variant's best guess), `quad`, `sum` (by the code path that accepted it), `sum_forced`.
- **Share** of a term: the standard deviation of its contribution w·φ(x) over the 4096 test inputs; the spurious
  share of a fit is the sd of the summed contribution of its spurious terms over the sd of the model's output
  (background included). Also the test error of the model with the spurious terms' contributions removed.

### 2.1 By n

(Numerical, `results/spur.jsonl`, `calib.json` `A2.by_n`; full tables in `calib_tables.txt`.) 41 fits per n.

| n | fits with test error ≤ 0.1 | admitted terms | read an irrelevant input (share of terms) | of which linear-block characters | the others (share of the other terms) | fits with another spurious term | spurious share of the output, mean / max | max without the linear block's characters (upper bound) | test error with / without the spurious terms (mean) |
|---|---|---|---|---|---|---|---|---|---|
| 16 | 2 | 5 | 1 (0.200) | 0 | 1/5 | 1 | 0.024 / 1.000 | 1.000 | 0.3713 / 0.3654 |
| 32 | 7 | 18 | 3 (0.167) | 0 | 3/18 | 2 | 0.033 / 0.752 | 0.752 | 0.2818 / 0.2800 |
| 64 | 22 | 362 | 250 (0.691) | 247 | 3/68 (0.044) | 3 | 0.136 / 0.863 | 0.413 | 0.1158 / 0.0958 |
| 128 | 38 | 399 | 204 (0.511) | 185 | 19/164 (0.116) | 11 | 0.063 / 0.493 | 0.373 | 0.0190 / 0.0191 |
| 256 | 41 | 405 | 174 (0.430) | 159 | 15/212 (0.071) | 5 | 0.025 / 0.170 | 0.213 | 0.0027 / 0.0028 |
| 512 | 41 | 403 | 103 (0.256) | 92 | 11/300 (0.037) | 5 | 0.016 / 0.111 | 0.112 | 0.0007 / 0.0006 |
| 1024 | 41 | 408 | 96 (0.235) | 76 | 20/323 (0.062) | 5 | 0.012 / 0.148 | 0.159 | 0.0002 / 0.0002 |
| 2048 | 41 | 519 | 53 (0.102) | 50 | 3/464 (0.006) | 2 | 0.003 / 0.086 | 0.082 | 0 / 0 |
| 4096 | 41 | 681 | 56 (0.082) | 50 | 6/625 (0.010) | 5 | 0.006 / 0.067 | 0.066 | 0 / 0 |
| 8192 | 41 | 608 | 52 (0.086) | 50 | 2/553 (0.004) | 2 | 0.003 / 0.055 | 0.055 | 0 / 0 |
| 16384 | 41 | 691 | 55 (0.080) | 52 | 3/632 (0.005) | 3 | 0.003 / 0.060 | 0.060 | 0 / 0 |
| all | | 4499 | 1047 (0.233) | 961 | 86/3364 (0.026) | | | | |

- The median fit has spurious share 0 at every n. Fits with a spurious share above 0.1: 1, 2, 11, 8, 6, 3, 2 at
  n = 16 … 1024 and none from n = 2048 on; without the linear block's characters (upper bound: the sum of the other
  kinds' shares) 1, 2, 3, 4, 3, 2, 2 and none from 2048 on.
- Removing the spurious terms lowers the mean test error at n = 16–64 (by 0.006, 0.002 and 0.020; better in 1, 2 and
  10 fits, worse in 0, 0 and 1), mostly the linear block's characters at n = 64, and changes it by ≤ 0.0001 from
  n = 128 on (better in 4, 1, 1 fits at n = 128–512, worse in 4, 2, 0; no change from 1024 on).
- The atlas's statement for the families (ATLAS.md §2.2: spurious shares ≤ 0.1 at n = 16384 for 36 of 37 targets)
  holds here for all 41 targets from n = 2048 on.

### 2.2 What they are

(Numerical, `calib.json` `A2.top_terms`, `A2.spur_excl_lin_by_cat_round`, `A2.r0_chi_test_spur`, `A2.r0_class_searches`;
the term lists in `calib_tables.txt`.)
- **The linear block's characters: 961 of the 1047** spurious terms. The block tests the whole degree-1 vector at once
  and then adds every input not yet in the model, so a target with any degree-1 weight brings in its 20–29
  irrelevant inputs. It entered in 10 fits at n = 64, 8 at 128, 7 at 256, 4 at 512, 3 at 1024 and 2 at each n from
  2048 on. Its share is at most 0.80 at n = 64 (rand1; and3 0.715, maj3 0.536, rmaj9 0.501, thr10 0.459, maj9 0.442,
  dlist5 0.441, rf15 0.441, rf08 0.425, rf13 0.001) and at most 0.031 from n = 2048 on. Once it entered on a target
  with no degree-1 weight at all: par3 at n = 16384, in round 0 next to the parity character, at ratio 1.04 (share
  0.0065), an event of the kind §1.4 measures on noise.
- **Characters admitted by their own test: 7 of the 3029.** Two in round 0, each wholly on irrelevant inputs: rf02 at
  n = 128 (χ{x22, x28}, share 0.063) and rf04 at n = 4096 (χ{x15, x21, x28}, share 0.010). P-A′ bounds this event per
  fit and class: over the 2460 round-0 class searches of these fits the expected number is ≤ 29.8 by the bound and
  2.2 under the independent-Gaussian approximation; 2 occurred. The other five are in round 1 of rand2 at n = 1024,
  each containing input 8, which a product block admitted in round 0 had brought into the model (shares ≤ 0.007): once
  a spurious term is in the model, its residual correlates with characters on its irrelevant inputs. In 7 of the 23
  fits with a spurious term (other than the linear block's) admitted after round 0, an earlier round had admitted a
  spurious term.
- **Spectral features: 20** (1 in round 0, 19 later; 15 of them at n = 128–256), with 15–59% of |u|² on relevant
  inputs (dnf3 at 16384: 89%), shares ≤ 0.17 (rf00 at 128) and ≤ 0.033 from n = 512 on.
- **Sum blocks: 52** (19 in round 0, 33 later): 21 modulated blocks at n = 128–1024 whose sum or modulator includes
  irrelevant inputs (largest share 0.244, rand3 at 128; test error 0.049), 6 additive blocks at 256–1024, and 25
  products (product, candidate-pair and split moves) at every n ≥ 256 in which one factor reads irrelevant inputs. From
  n = 2048 on, 11 of the 14 spurious terms other than the linear block's characters are such products (the others:
  rf04's degree-3 character, and dnf3's spectral features at 4096 and 16384): rand0's product reading input 29 at
  every n from 2048 (shares 0.082, 0.066, 0.055, 0.060), rf06's at 4096–16384 (0.062, 0.037, 0.029), thr10's two at
  2048 (0.008, 0.013), dnf3's and rmaj9's at 4096 (0.010, 0.043). All have test error 0. This is the spurious-product
  quirk of the atlas (ATLAS.md §2.2) and of Part 10's v3 member.
- **Forced: 6 characters and 1 sum block** at n ≤ 64, in the fits where the cross-validation chose the forced variant:
  they carry the largest shares (rf09 at 16: 1.00; rf14 at 32: 0.61; stair5 at 32: 0.58 and 0.49; sparsepoly at 64:
  0.41; rf03 at 64: 0.36; rand1 at 64: 0.34), in fits with test error 0.129–0.498.

## 3. (B) Where the compute goes

### 3.0 Fits

- par4, maj9, mux, stair5 (designed), f7_07 (a modulated signed-sum target, `[−2 ≤ s ≤ 8]·x13`), f7_08 (a symmetric
  target, `[s ∈ {−11, −9, −3, 1, 9, 11}]`), f7_05 (mod 3, never learned) and pure noise (p = 0.5), at n = 64, 512, 4096
  and 16384, seed 0, as the evaluation fits them; and the seed-0 n = 16384 fit of the target with the largest FLOP
  count in three suites (h5s5 of dlheld5, fd_08 of dlfamdev, thr10 of designed): 35 cells.
- Each cell: one fit of the frozen module, then the instrumented fit (test error and FLOPs equal to the frozen fit's
  and to the result file's in every cell), then two more instrumented repeats for the CPU time (105 records; the
  repeats also equal the result files). CPU seconds are process time on a 4-core machine shared with 3–4 evaluation
  workers at nice 10. Repeats of the same cell vary by up to 2.6× (largest / smallest of the three: median 1.44,
  range 1.06–2.56 over the 35 cells; the instrumented against the frozen fit of rep 0: median ratio 1.00, range
  0.50–2.52), so CPU figures are medians of the three instrumented repeats; against the evaluation's recorded CPU of
  the same cells they are 0.44–1.40× (median 0.78). FLOPs are DFG's own counter (multiply-add = 2), deterministic.

### 3.1 FLOPs: the fixed-share searches set the count

**The round-0 global search, d = 30 (Proved, by reading the counter increments of `_fit`; Numerical check:
`round0_flops` in `calib_summary.py` equals the recorded deg 1–6 regions of all 275 `_fit` calls of the profile
(35 final fits and 240 fold fits), degrees 1–3 counted once per round that ran the search).** With the whole budget
(n > 512, scale 1) a search round adds exactly
- degrees 1–4 on all n rows: 2d + (2d² + d) + 28·(2d² + 2d) + 378·(2d² + 3d) = 768 390 FLOPs per row (the degree-3 loop
  visits a < d − 2, the degree-4 loop the 378 pairs (a, b) with b < d − 2; at d = 30 the budget shares of 3% and 15%
  would bind only at m = 87 307 and 29 627 rows, above 16384); degrees 1–3 (53 970 per row) again in every later
  round;
- in round 0, degree 5 on m₅ = min(n, 1374) rows and degree 6 on m₆ = min(n, 147) rows: 4.871·10⁹ and 4.850·10⁹ FLOPs
  at n ≥ 1374, each 0.030 of one network run (1.624·10¹¹ at d = 30).

So before anything else a fit costs 0.0571 of a network run at n = 1024 (m₅ = 1024), 0.079 at n = 4096 and 0.137 at
n = 16384, on any target; at n ≤ 512 the final fit gets half the budget (m₅ = 687, m₆ = 73: 0.0147 at n = 64, 0.0284 at
512) and the 2F fold fits (hi = False: no degree 5–6) the other half, of which they spend little (§3.4).

### 3.2 FLOPs by component

(Numerical, `results/prof.jsonl`, `calib.json` `B.cells`, `B.by_n`; per-cell tables in `calib_tables.txt`.) Percent of
the fit's FLOPs, range over the 8 profiled cells at each n (par4, maj9, mux, stair5, f7_07, f7_08, f7_05, noise):

| component | n = 64 | 512 | 4096 | 16384 |
|---|---|---|---|---|
| FLOPs / one network run | 0.020–0.026 | 0.048–0.063 | 0.079–0.109 | 0.137–0.166 |
| degrees 1–2 | 0.0 | 0.0 | 0.1 | 0.1 |
| degree 3 | 0.1–0.2 | 0.3–0.5 | 1.6–2.4 | 3.2–3.8 |
| degree 4 | 1.1–1.4 | 3.6–4.7 | 16.5–22.7 | 43.4–52.4 |
| degree 5 (subsample) | 5.4–6.9 | 17.9–23.4 | 27.4–37.8 | 18.1–21.8 |
| degree 6 (subsample) | 49.8–64.4 | 23.7–31.0 | 27.3–37.7 | 18.0–21.7 |
| extension and local | 0.0 | 0.0–0.3 | 0.0–1.3 | 0.0 |
| linear and spectral blocks | 0.0 | 0.0 | 0.0 | 0.0 |
| sum blocks | 0.0–0.9 | 0.0–2.0 | 0.0–5.7 | 0.0–1.8 |
| least squares | 0.0 | 0.0 | 0.0–1.3 | 0.0–0.9 |
| logistic readout | 0.0 | 0.0–0.4 | 0.0–18.0 | 0.0–14.5 |
| cross-validation fold fits | 27.2–42.6 | 40.6–52.0 | – | – |

- At n ≤ 512 the subsampled degree-5/6 search of the final fit and the fold fits are nearly all of it; from n = 4096 on
  the degree-4 search grows with n while degrees 5–6 stay fixed. On these 8 cells the target changes the count by at
  most 0.03 of a network run (f7_08 at 4096: 0.109, its readout 18%).
- **The largest fits are the ones with many features**: the three largest-FLOP cells (n = 16384) cost 0.431 (h5s5),
  0.471 (fd_08) and 0.323 (thr10) of a network run, of which the logistic readout is 46.9%, 42.9% and 41.4% (15 Newton
  steps at 2np² + p³/3 + 8np each, p features), degree 4 16.7%, 15.3%, 22.3%, least squares 7.6%, 9.6%, 4.4%, the sum
  blocks 6.1%, 6.1%, 4.6%, extensions 2.4%, 6.4%, 3.7%, and degrees 5 and 6 together 13.9%, 12.7%, 18.5%.

### 3.3 CPU time by component

(Numerical, as §3.2; CPU shares are medians over the three repeats.) Percent of the fit's CPU time, range over the
same 8 cells:

| component | n = 64 | 512 | 4096 | 16384 |
|---|---|---|---|---|
| CPU seconds per fit | 0.83–5.26 | 0.54–4.67 | 0.86–2.37 | 1.43–2.65 |
| degree 4 | 0.2–1.0 | 0.5–3.9 | 7.6–22.2 | 25.9–46.2 |
| degree 5 (subsample) | 0.4–2.8 | 2.7–19.2 | 10.4–31.4 | 10.5–20.5 |
| degree 6 (subsample) | 4.0–60.5 | 9.5–31.7 | 12.2–49.3 | 16.7–46.2 |
| sum blocks (final fit) | 0.0–4.1 | 0.0–8.4 | 0.0–67.2 | 0.0–25.0 |
| logistic readout | 0.0 | 0.0–0.1 | 0.1–4.1 | 0.1–6.3 |
| cross-validation fold fits | 24.9–91.4 | 38.4–82.9 | – | – |

- **The fold fits' CPU is the sum-block search.** Without par4 (its parity passes in round 0 of the final and of every
  fold fit; the round's character then explains the residual and no block search runs: 0.83 s at n = 64), the fold
  fits take 79.4–91.4% of the CPU at n = 64 and 52.4–82.9% at 512, and inside them the sum-block search takes 94.2–94.7%
  of the CPU for 41.6–46.0% of the FLOPs at n = 64 (85.1–93.2% for 13.7–29.0% at 512), while the degree-4 search takes
  3.9–4.4% of the CPU for 45.6–50.0% of the FLOPs (5.0–12.8% for 56.0–79.4%). In the final fit at n ≥ 4096 the
  sum-block search is up to 67% of the CPU (f7_08 at 4096) for at most 5.7% of the FLOPs.
- **Rates** (all profile fits pooled, `calib.json` `B.rate`): the character searches of degrees 3–5 and the extensions
  run at 16.5–17.6 GFLOP/s, degree 6 at 7.8, least squares and the logistic readout at 32 and 33, the sum-block search
  at 0.75 and the fold fits as a whole at 0.97 GFLOP/s.
- **The three largest-FLOP cells** take 7.82 s (h5s5), 9.08 s (fd_08) and 5.06 s (thr10): the sum-block search 63.8%,
  61.2% and 53.5% of it for 4.6–6.1% of the FLOPs, the logistic readout 11.1–11.7% for 41–47% of the FLOPs.

### 3.4 Every suite, from the result files

(Numerical, `part11/results/toy__dfg13-perm__<suite>.json`, all 4730 fits of the 14 files; `calib.json` `files`,
`files_summary`.) FLOPs are those the evaluation recorded; one network run is `harness.gd_flops(d)` (1.47·10¹¹,
1.62·10¹¹, 1.93·10¹¹ and 5.06·10¹¹ FLOPs at d = 15, 30, 60, 120; 40000 steps at d = 120).

**Largest FLOPs per fit, as a fraction of one network run**, by n:

| suite (d; targets × seeds) | 16 | 32 | 64 | 128 | 256 | 512 | 1024 | 2048 | 4096 | 8192 | 16384 | largest (target) |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| designed (30; 21 × 3) | 0.000 | 0.000 | 0.031 | 0.039 | 0.050 | 0.090 | 0.077 | 0.137 | 0.167 | 0.204 | 0.372 | 0.372 (thr10) |
| random (30; 20 × 2) | 0.000 | 0.001 | 0.031 | 0.034 | 0.037 | 0.059 | 0.059 | 0.073 | 0.084 | 0.105 | 0.154 | 0.154 (rf06) |
| dlheld (30; 12 × 3) | 0.000 | 0.000 | 0.030 | 0.035 | 0.049 | 0.085 | 0.068 | 0.114 | 0.175 | 0.246 | 0.420 | 0.420 (inter2) |
| dlheld2 (30; 7 × 3) | 0.000 | 0.000 | 0.029 | 0.037 | 0.048 | 0.080 | 0.064 | 0.093 | 0.133 | 0.203 | 0.307 | 0.307 (thr20) |
| dlheld3 (30; 10 × 3) | 0.000 | 0.000 | 0.032 | 0.034 | 0.048 | 0.096 | 0.066 | 0.094 | 0.131 | 0.208 | 0.275 | 0.275 (dlist8) |
| dlsymdev (30; 8 × 3) | 0.000 | 0.000 | 0.029 | 0.033 | 0.039 | 0.058 | 0.059 | 0.072 | 0.083 | 0.112 | 0.163 | 0.163 (twosym) |
| dlheld4 (30; 12 × 3) | 0.000 | 0.001 | 0.032 | 0.035 | 0.048 | 0.080 | 0.062 | 0.083 | 0.085 | 0.111 | 0.162 | 0.162 (symand) |
| dlheld5 (30; 12 × 3) | 0.000 | 0.000 | 0.033 | 0.035 | 0.048 | 0.069 | 0.063 | 0.094 | 0.198 | 0.302 | 0.519 | 0.519 (h5s5) |
| dlheld6 (30; 12 × 3) | 0.000 | 0.000 | 0.029 | 0.034 | 0.045 | 0.078 | 0.066 | 0.112 | 0.177 | 0.232 | 0.420 | 0.420 (h6_09) |
| dlfamdev (30; 12 × 3) | 0.000 | 0.000 | 0.030 | 0.037 | 0.048 | 0.085 | 0.064 | 0.112 | 0.200 | 0.312 | 0.471 | 0.471 (fd_08) |
| dlheld7 (30; 12 × 3) | 0.000 | 0.000 | 0.033 | 0.035 | 0.046 | 0.069 | 0.067 | 0.110 | 0.166 | 0.263 | 0.380 | 0.380 (f7_04) |
| designed_d15 (15; 7 × 2) | 0.000 | 0.000 | 0.004 | 0.005 | 0.004 | 0.006 | 0.004 | 0.010 | 0.017 | 0.036 | 0.067 | 0.067 (maj9) |
| designed_d60 (60; 7 × 2) | 0.000 | 0.003 | 0.093 | 0.102 | 0.105 | 0.136 | 0.069 | 0.137 | 0.152 | 0.164 | 0.177 | 0.177 (maj9) |
| designed_d120 (120; 4 × 2) | 0.001 | 0.015 | 0.057 | 0.089 | 0.112 | 0.111 | 0.153 | 0.161 | 0.175 | 0.178 | 0.179 | 0.179 (maj9) |

- No fit uses more than 0.519 of a network run (dlheld5's h5s5 at n = 16384, seed 2); at d = 30 every fit at
  n ≤ 512 stays below 0.096. Every largest-FLOP cell is at n = 16384.
- DFG's own cap (a round starts only while a `_fit` call has spent ≤ 0.75 of its budget, `gd_flops(d)` × scale) never
  binds where it was recorded: no stop by it in any of the 5715 recorded `_fit` calls (A1: ⟦A1 calls⟧ final and fold
  fits; A2: 451 final fits; B: 275), and the largest share of its own budget any of them spent is 0.471 (fd_08, a final
  fit) and 0.312 for a fold fit (`calib.json` `budget_cap`). For the result files' fits at n > 512 (one `_fit` call
  each, ≤ 0.519 of a network run) it cannot bind; at n ≤ 512 the final fit's budget is 0.5 of a network run and every
  fit stays below 0.096 in all, while the fold fits' calls are not in the result files.
- The *median* fit at d = 30 is the same in every suite: 0.025–0.026 at n = 64, 0.079–0.085 at n = 4096, 0.138–0.182
  at n = 16384 (`calib_tables.txt`, median table), i.e. the fixed-share searches of §3.1; the largest fits are the
  targets with many features (§3.2).
- At d = 60 and 120 the count is flatter in n (largest fit 0.14–0.18 from n = 2048 on) because the degree-4 search is
  subsampled (m₄ = 2212 and 364 rows) and the degree-5/6 search is skipped (its budgeted m is 47 and 3 rows for degree
  5, below 64); at d = 15 it is 0.067 at most.

**CPU seconds per fit** (harness: process time around `fit`, recorded under the evaluation's 4-worker load), median
(largest), by n:

| suite (d) | 16 | 32 | 64 | 128 | 256 | 512 | 1024 | 2048 | 4096 | 8192 | 16384 | largest |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| designed (30) | 0.02 (0.0) | 0.16 (0.6) | 7.13 (15.2) | 4.72 (11.8) | 3.40 (9.8) | 3.43 (15.5) | 0.89 (5.1) | 1.38 (9.6) | 1.50 (7.4) | 1.75 (6.3) | 2.25 (6.4) | 15.5 |
| random (30) | 0.02 (0.0) | 0.17 (0.7) | 7.88 (13.6) | 3.82 (8.9) | 2.20 (5.3) | 2.30 (5.6) | 0.66 (1.6) | 0.76 (1.6) | 0.91 (2.0) | 1.26 (2.1) | 1.67 (2.3) | 13.6 |
| dlheld (30) | 0.02 (0.0) | 0.17 (0.9) | 6.77 (11.0) | 6.06 (8.9) | 6.08 (9.6) | 5.09 (13.2) | 1.24 (3.3) | 1.59 (8.1) | 1.70 (7.1) | 1.95 (6.9) | 2.39 (10.2) | 13.2 |
| dlheld2 (30) | 0.02 (0.0) | 0.15 (0.4) | 7.39 (12.0) | 6.28 (9.8) | 6.01 (9.8) | 5.96 (11.8) | 1.44 (2.9) | 1.63 (4.5) | 1.63 (5.6) | 1.73 (6.5) | 2.50 (11.1) | 12.0 |
| dlheld3 (30) | 0.02 (0.0) | 0.16 (0.5) | 7.96 (13.4) | 6.28 (8.9) | 6.59 (10.9) | 6.58 (17.4) | 1.36 (2.7) | 2.09 (3.2) | 2.04 (4.0) | 1.83 (4.4) | 2.50 (4.0) | 17.4 |
| dlsymdev (30) | 0.02 (0.0) | 0.15 (0.3) | 7.07 (11.6) | 4.21 (7.8) | 2.87 (5.9) | 3.59 (6.9) | 0.94 (2.2) | 1.53 (2.4) | 1.72 (2.7) | 1.90 (2.7) | 2.70 (3.6) | 11.6 |
| dlheld4 (30) | 0.02 (0.0) | 0.16 (0.7) | 7.31 (14.7) | 5.29 (8.4) | 4.28 (8.6) | 3.79 (12.6) | 1.23 (2.3) | 1.42 (2.4) | 1.55 (3.0) | 1.77 (2.5) | 2.47 (3.2) | 14.7 |
| dlheld5 (30) | 0.02 (0.0) | 0.15 (0.5) | 7.35 (13.8) | 5.02 (9.4) | 4.43 (9.8) | 5.01 (8.2) | 1.33 (2.1) | 1.75 (3.9) | 2.09 (11.3) | 2.38 (10.8) | 2.81 (15.5) | 15.5 |
| dlheld6 (30) | 0.02 (0.0) | 0.16 (0.5) | 7.31 (11.1) | 5.00 (9.7) | 5.43 (8.2) | 5.70 (13.5) | 1.85 (3.1) | 2.04 (5.4) | 1.94 (9.4) | 2.31 (5.7) | 2.70 (8.6) | 13.5 |
| dlfamdev (30) | 0.02 (0.0) | 0.15 (0.4) | 7.48 (12.9) | 5.79 (10.0) | 4.85 (9.3) | 4.45 (14.7) | 1.40 (2.4) | 1.72 (4.1) | 1.90 (11.3) | 2.30 (13.0) | 2.68 (11.6) | 14.7 |
| dlheld7 (30) | 0.02 (0.0) | 0.16 (0.4) | 7.81 (16.6) | 6.31 (10.9) | 4.54 (9.2) | 5.78 (10.6) | 1.38 (2.9) | 2.13 (5.8) | 1.85 (7.8) | 1.92 (8.5) | 2.30 (6.1) | 16.6 |
| designed_d15 (15) | 0.01 (0.0) | 0.08 (0.5) | 2.42 (4.5) | 1.26 (4.2) | 0.88 (2.1) | 0.96 (1.6) | 0.04 (0.3) | 0.08 (0.5) | 0.13 (0.4) | 0.34 (1.0) | 0.66 (1.0) | 4.5 |
| designed_d60 (60) | 0.03 (0.0) | 0.26 (0.4) | 9.18 (12.4) | 5.52 (13.1) | 3.36 (6.5) | 4.12 (8.2) | 0.83 (1.4) | 1.30 (2.5) | 1.54 (2.6) | 1.56 (2.5) | 1.62 (2.8) | 13.1 |
| designed_d120 (120) | 0.04 (0.1) | 1.23 (1.5) | 8.05 (15.3) | 6.41 (16.2) | 3.50 (7.8) | 4.44 (10.0) | 3.00 (4.0) | 3.27 (5.4) | 3.37 (6.0) | 3.31 (5.9) | 3.39 (5.5) | 16.2 |

- CPU time does not follow FLOPs: the slowest fits are at n = 64–512 (suite medians 2.2–9.2 s at d ≥ 30; largest
  17.4 s), where the FLOP count is smallest, because of the fold fits' sum-block searches (§3.3); at n = 1024 (no
  cross-validation) the median drops to 0.66–3.0 s at d ≥ 30 (0.04 s at d = 15) and then grows slowly with n.
- For scale (Heuristic, not re-measured here): Part 6 (`discrete_learner/DISCRETE-LEARNER.md`) reports the networks at
  32–50 GFLOP/s (float32 under XLA; an audit timing), i.e. 3.2–5.1 CPU s for one network run at d = 30; DFG's medians
  at d = 30 are 0.43–2.45 of that at n = 64–512 and 0.13–0.87 of it from n = 1024 on. The networks' CPU time is not in
  the result files.

## 4. Caveats

- A1 measures the frozen learner on two label rates and two dimensions; the rates of rare events have wide
  intervals (0/220: ≤ 0.017). The level bounds P-A and P-A′ cover only round 0 of the global character classes.
- A2 counts terms, not columns: a sum block is one term however many level indicators it has. The spurious share
  without the linear block's characters is bracketed (largest kind's share, sum of the kinds' shares), because the
  records keep each kind's summed contribution but not every term's.
- B's CPU times come from a shared machine and vary by up to 2.6× between repeats; the FLOP shares are exact.
- The cascade re-run (§1.5) emulates the fold fits (n = 29 and 58, scale 1/40, the forced variant) on fresh noise; it
  is not the evaluation's own fold fits, which the records of §1.5 count directly.
