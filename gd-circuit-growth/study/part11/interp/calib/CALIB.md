# False admissions and where the compute goes: DFG v1.3 alone (Part 11, Q7)

Part 11, Q7 (PROTOCOL.md): "false admissions: DFG on labels independent of the inputs; where the compute goes". The
object is DFG v1.3 run alone: `part10/hyb_portfolio3/dfg13.py`, md5 `69cabe5c50345cb24079198ed52b562f`, as
`DFG(readout="logit").fit` (its own cross-validation at n ≤ 512, kernel background and budget), loaded by
`part11/eval_dfg.load_dfg13()` (md5 checked). Written 3 November 2026. Not yet checked by independent verifiers.

Labels: **Proved** (a proof is given), **Numerical** (measured; the source file is named), **Heuristic** (my reading).
Every count is given with its denominator; intervals are two-sided 95% Clopper–Pearson.

**Files** (all in this folder):
- [`make_instr.py`](make_instr.py) builds [`dfg13_instr.py`](dfg13_instr.py), a copy of `dfg13.py` with 64 lines
  added and none changed: calls into the recorder [`calib_rec.py`](calib_rec.py), which only read (the FLOP counter
  `fl[0]`, the process clock, statistics DFG has just computed) and append to their own lists.
- [`calib.py`](calib.py) runs everything: `audit`, `noise` (A1), `spur` (A2), `prof` (B). Records:
  `results/noise.jsonl` (one line per fit), `results/spur.jsonl`, `results/prof.jsonl`.
- [`calib_summary.py`](calib_summary.py) turns the records and the evaluation's result files into
  [`calib.json`](calib.json) (every number below) and [`calib_tables.txt`](calib_tables.txt) (the full tables).

## 0. What was measured, and how

**The instrumented copy is the frozen learner** (Numerical, `calib.py audit`, `calib.json`):
- `audit`: difflib between `dfg13.py` and `dfg13_instr.py` finds only inserted lines, all of the form `_P.<hook>(...)`
  or the recorder's import (64 lines; 878 → 942). The recorder's hooks return nothing and change no array DFG uses.
- Every fit made with the copy was checked, bit for bit, on test error and total FLOP count:
  - against the evaluation's merged result files (A2: all 451 seed-0 cells of the designed and random suites;
    B: every profiled cell of a suite);
  - against a fit of the frozen module on the same data in the same process (B: every profiled cell; A1: seeds 0
    and 1 of every (d, p, n)).
  All checks are equal (counts in §1–§3).

**Regions** (B). `DFG._fit` is cut into consecutive regions by `REC.enter(name)`; the FLOP-counter increments and
CPU seconds between two marks go to the region entered first, so the regions of one `_fit` call add up to its FLOP
count (closure error ≤ 2·10⁻¹⁶ relative) and its CPU time. The recorder's own detail work is subtracted from the
clock. Regions: the global character search by degree (`deg 1`: the vector X^T r / n; `deg 2`: the residual pair
matrix M, which the blocks reuse; `deg 3`, `deg 4`; `deg 5`, `deg 6`: the first-round subsample search), extension
(one and two inputs), local (the Walsh transform on the inputs in use), the linear block test, the spectral block
(eigendecomposition of M), the sum-block search (setup, additive, product, split, candidate-pair products,
modulated, products of accepted blocks), least squares, the logistic readout, and other (bookkeeping, adding
feature columns, the background, the training error). `DFG.fit`'s fold fits at n ≤ 512 are separate `_fit` calls;
what lies outside every `_fit` call (prediction on the held-out folds) is reported separately.

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
  fold fits are reported separately (§1.5).

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

The bound is not tight: for N independent Gaussian statistics at these thresholds the probability is 1 − (1 − 2Φ(−z))^N
= 0.0008–0.0012 per class (z = √(2L) = 4.12 for degree 1 up to 6.06 for degree 6 at d = 30), about 10× below
δ/(2K), because Hoeffding's bound has no Mills-ratio factor (Heuristic; the statistics are pairwise uncorrelated and
nearly Gaussian for m ≫ 1, and for N ≫ m dependent, which only lowers their maximum).

What P-A does not cover:
- **later rounds**: once a feature is in the model, the residual depends on X through it;
- **the linear block**: n |X^T r / n|² / s² against k + 2√(kt) + 2t, t = ln(1/δ), Laurent–Massart's bound for a
  Gaussian χ²_k at level δ = 0.1; the exact χ²₃₀ tail at that threshold (51.23) is 0.0092;
- **the spectral block**: the top |eigenvalue| of the residual pair matrix (diagonal removed) against the Wigner
  edge 2s√(d/n)·(1 + √(2 ln(1/δ)/d)), for n ≥ 4d; no level is proved for it;
- **the sum-block tests**: T = |projection of r onto a block's level indicators|² / s² against Laurent–Massart's
  χ²_m bound at exp(−t_k), t_k = ln(4K·C(d,k)·2^{k−1}·2·n_mod·24/δ). If each T were exactly χ²_m, the union bound over
  every (S, s) of every size k ≤ 24, both folds and the n_mod modulators would give ≤ δ/(4K) = 0.00625 for all
  additive blocks together (weighted blocks have their own, smaller share); the block is searched on the residual and
  must also pass on the residual projected off the round's new characters;
- **the forced variant** (n ≤ 512): it takes the best-scoring candidate when nothing passes, at most twice; it is
  used only if the paired cross-validation test prefers it.

### 1.2 What was admitted, d = 30

(Numerical, `results/noise.jsonl`, `calib.json` `A1.by_cell`; full table `calib_tables.txt`.) 20 fits per cell.

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
  1–4). Their test errors (0.491–0.500) are those of the fits without features. Every fit stopped with "nothing
  passed" (215) or after its two forced rounds.
- **Biased labels: 6 false admissions in 220 fits, at n = 64–256 and once at 16384**: the linear block twice
  (n = 64, 128; χ² ratio 1.10 and 1.07, i.e. T = 56.5 and 54.9 against 51.23), adding all 30 inputs (test error 0.336
  and 0.283 against 0.195); the spectral block twice at n = 128 (eigenvalue ratio 1.011 and 1.054; in the first fit a
  second spectral feature entered in round 1 at ratio 1.083, after the first had lowered s; test error 0.234, 0.213);
  a degree-1 character twice (n = 256: test error 0.244; n = 16384: 0.195). In 5 of the 6 nothing further entered.
  The cross-validation never chose the forced variant at p = 0.8 (0/120).
- **Test error on fresh noise** (Numerical; reading Heuristic). p = 0.5: 0.497–0.504 by n (the test set has
  P(y = −1) = 0.4895). p = 0.8: 0.339 at n = 16, falling to 0.1946 = the test set's minority rate from n = 1024 on.
  The excess at small n is the kernel background, not admitted features (at n = 16 and 32 no fit has a feature):
  the model is sign(w₀ + x·b) with b = X^T r / n, whose d coordinates are each ~N(0, s²/n), so a test point is
  predicted −1 with probability ≈ Φ(−w₀√n / (s√d)) = 0.29, 0.14, 0.014 at n = 16, 64, 256 (w₀ ≈ 0.6, s ≈ 0.8),
  against the measured 0.234, 0.130, 0.018; the error is then 0.1946 + 0.611·P(predict −1) (0.338 at n = 16 against
  the measured 0.339). Part 6's remark that DFG is "sometimes above the constant predictor's error" at n = 16–64 fits
  this: the Hebbian background carries no information on such data and costs up to 0.14 in error on biased labels.

### 1.3 Per class, against the nominal levels

(Numerical, `calib.json` `A1.by_class`, `nominal`; Gaussian reference Heuristic.) Round 0 of the final fit, d = 30,
both p, all n where the class runs (degrees 3–4 need m ≥ 32 rows, degrees 5–6 m ≥ 64):

| class | N | round-0 tests | fits with ≥ 1 pass | bound δ/(2K) (P-A) | independent-Gaussian approx. | median max-ratio, p = 0.5, n ≥ 128 | Gaussian reference |
|---|---|---|---|---|---|---|---|
| degree 1 | 30 | 440 | 2 (0.0006–0.016) | 0.0125 | 0.0012 | 0.52–0.60 | 0.553 |
| degree 2 | 435 | 440 | 0 (≤ 0.008) | 0.0125 | 0.0010 | 0.63–0.68 | 0.669 |
| degree 3 | 4060 | 400 | 0 (≤ 0.009) | 0.0125 | 0.0009 | 0.69–0.74 | 0.727 |
| degree 4 | 27405 | 400 | 0 (≤ 0.009) | 0.0125 | 0.0009 | 0.75–0.77 | 0.762 |
| degree 5 (m = min(n, 1374)) | 142506 | 360 | 0 (≤ 0.010) | 0.0125 | 0.0008 | 0.77–0.79 | 0.785 |
| degree 6 (m = min(n, 147)) | 593775 | 360 | 0 (≤ 0.010) | 0.0125 | 0.0008 | 0.79–0.80 | 0.802 |

(The "max-ratio" is the largest |statistic| / threshold in the class; the reference is the median of max |Z|/z over N
independent N(0, 1).) Both degree-1 passes are at p = 0.8. The later rounds of the final fits (after a forced or a
false feature) ran 13–16 tests of each degree 1–3, 13 one-input and 10 two-input extension tests and 9 local tests,
with no pass. Against the task's nominal
"δ = 0.1 per class per round" every class is far below; against the sharper δ/(2K) = 0.0125 of P-A every rate is
compatible with it, and 5 of 6 classes are compatible with the ~0.001 of the Gaussian approximation (degree 1: 2/440
where 0.5 is expected; a 20000-draw check is in §1.4).

### 1.4 The block tests

(Numerical, `calib.json` `A1.blocks`, `mc`, `mc_big`.)

<!-- A1 BLOCKS -->

### 1.5 The forced variant and the cross-validation's fold fits

(Numerical, `calib.json` `A1.folds`.) At n ≤ 512 every fit also runs 2F fold fits (F = 10 at n ≤ 64, else 5): F of the
default variant and F of the forced one, on (F−1)/F of the rows, without the degree-5/6 search and with 1/(4F) of the
budget each.

| d = 30 | default fold fits with an admitted feature | forced fold fits with a test-passed feature after the forced ones |
|---|---|---|
| p = 0.5 | 2/900 (a degree-1 character; the linear block) | 12/900 (mostly the local class: 9 fits; linear block 2, two-input extension, degree 1) |
| p = 0.8 | 9/900 (linear block 3, spectral 3, sum blocks 2, degree 1) | **238/900** (n = 32: 121/200; 64: 73/200; 128: 28/100; 256: 15/100; 512: 1/100): the local class in 205, sum blocks in 24, the linear block 3, spectral 4, one-input extension 2, degree 1 1 |

<!-- A1 CASCADE -->

<!-- A1 D60 -->

## 2. (A2) Spurious features on the designed and random targets

### 2.0 Fits and definitions

- The 21 designed and 20 random targets at d = 30, seed 0, every n of the grid (16 … 16384): 451 fits, each exactly
  as `eval_dfg.py` makes it (`harness.train_data` / `test_data`, fit rng `default_rng([fn_seed(t), 0, n, 77])`, the
  column permutation that `Permuted` draws from it, `DFG(readout="logit")`). The permutation is undone through the
  `pi` that `Permuted` stores in its prediction function: learner column j is original input pi[j].
- **Relevant set**: the inputs the target depends on, computed exactly. Every designed and random target reads only
  x[:, :k] with k ≤ 10 (`boolfuncs.py`: explicit indices below 10; `_random_formula(rng, k, ·)` reads x[:, :k],
  k ≤ 8), so enumerating all 2¹² assignments of the first 12 inputs (the others +1) decides, for each of them,
  whether flipping it ever changes f; flipping each input 12–29 was also checked on 20000 random points (never).
  The exact sets equal the suites' `relevant` lists for all 41 targets (Numerical, `calib.json` `A2.relevant`).
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

<!-- A2 RESULTS -->

## 3. (B) Where the compute goes

### 3.0 Fits

- par4, maj9, mux, stair5 (designed), f7_07 (a modulated signed-sum target, `[−2 ≤ s ≤ 8]·x13`), f7_08 (a symmetric
  target, `[s ∈ {−11, −9, −3, 1, 9, 11}]`), f7_05 (mod 3, never learned) and pure noise (p = 0.5), at n = 64, 512, 4096
  and 16384, seed 0, as the evaluation fits them; and the seed-0 n = 16384 fit of the target with the largest FLOP
  count in three suites (h5s5 of dlheld5, fd_08 of dlfamdev, thr10 of designed).
- Each cell: one fit of the frozen module, then the instrumented fit (test error and FLOPs equal to the frozen fit's
  and to the result file's in every cell), then two more instrumented repeats for the CPU time. CPU seconds are
  process time on a 4-core machine shared with 4 evaluation workers; single fits of the same cell vary by up to
  2.5× (frozen against instrumented: median ratio 1.00, range 0.50–2.52 over 32 cells), so CPU figures are medians
  of the three instrumented repeats. FLOPs are DFG's own counter (multiply-add = 2), deterministic.

### 3.1 FLOPs: the fixed-share searches set the count

**The round-0 global search, d = 30 (Proved, by reading the counter increments of `_fit`; Numerical check: equal to
the recorded deg 1–6 regions in all 16 profiled cells with n ≥ 4096, `results/prof.jsonl`).** With the whole budget
(n > 512, scale 1) round 0 adds exactly
- degrees 1–4 on all n rows: 2d + (2d² + d) + 28·(2d² + 2d) + 378·(2d² + 3d) = 768 390 FLOPs per row (the degree-4
  loop visits the 378 pairs (a, b) with b < d − 2; at d = 30 its budget share of 15% would bind only at m = 29 627 > 16384);
- degree 5 on m₅ = 1374 rows and degree 6 on m₆ = 147 rows: 4.871·10⁹ and 4.850·10⁹ FLOPs, 3.0% of one network run
  (1.624·10¹¹ at d = 30) each, whatever n.

So before anything else a fit costs 0.079 of a network run at n = 4096 and 0.137 at n = 16384, on any target; at
n ≤ 512 the final fit gets half the budget (m₅ = 687, m₆ = 73) and the 2F fold fits (hi = False: no degree 5–6) the
other half.

<!-- B TABLE FLOPS -->

<!-- B RESULTS -->

### 3.4 Every suite, from the result files

(Numerical, `part11/results/toy__dfg13-perm__<suite>.json`, all 4730 fits of the 14 files; `calib.json` `files`.)
FLOPs are those the evaluation recorded; one network run is `harness.gd_flops(d)` (1.47·10¹¹, 1.62·10¹¹, 1.93·10¹¹
and 5.06·10¹¹ FLOPs at d = 15, 30, 60, 120; 40000 steps at d = 120).

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
  n ≤ 512 stays below 0.096. The protocol's cap (a round starts only below 0.75 of the budget) never binds.
- The *median* fit at d = 30 is the same in every suite: 0.025–0.026 at n = 64, 0.079–0.085 at n = 4096, 0.138–0.182
  at n = 16384 (`calib.json`), i.e. the fixed-share searches of §3.1; the largest fits are the targets with many
  features (§3.2).
- At d = 60 and 120 the count is flatter in n (0.15–0.18 from n = 2048 on) because the degree-4 search is
  subsampled (m₄ = 2212 and 364 rows) and the degree-5/6 search is skipped (its budgeted m is 47 and 3 rows, below
  64); at d = 15 it is 0.067 at most.

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

- CPU time does not follow FLOPs: the slowest fits are at n = 64–512 (medians 2.2–9.2 s at d ≥ 30; largest 17.4 s), where the
  FLOP count is smallest, because of the cross-validation's fold fits and their sum-block searches (§3.2); at
  n = 1024 (no cross-validation) the median drops to 0.04–3.0 s and then grows slowly with n.
- For scale (Heuristic, not re-measured here): Part 6's audit timed the networks at 32–50 GFLOP/s (float32 under
  XLA), i.e. 3.2–5.1 CPU s for one network run at d = 30; DFG's medians at d = 30 are 0.4–2.5 of that at n = 64–512
  and 0.1–0.9 of it from n = 1024 on. The networks' CPU time is not in the result files.
