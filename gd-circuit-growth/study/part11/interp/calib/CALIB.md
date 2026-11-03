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
