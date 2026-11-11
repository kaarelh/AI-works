# Part 9 audit, lens: compute accounting

**Scope.** Code and process only, for:
- DFG v1.2 (`part9/p9_sum/dfg12.py`, diffed against `discrete_learner/dfg.py`);
- the gates member (`part9/p9_gates/learner.py`, inherited by `part9/hyb_portfolio2/learner.py`);
- `part9/p9_bank/learner.py`;
- `eval_cells.py` and `compare_part9.py`;
- the budgets (`hybrid/common.py`, `standard_tasks/harness.mlp_flops`);
- the builder prompt in the transcript `wf_65211ed2-329/agent-a8221d3409e741891.jsonl` (first user turn).

**No held-out result was read.** Nothing for hyb_portfolio2, p9_* or hyb_portfolio on qd_a, qd_b, dlheld4 or dlheld5, and no file under `p9/cells` or `p9/logs` for those sets. Dev result files read: `standard_tasks/results/{p9_gates-dev,p9_bank-dev,hyb_portfolio,mlp*}__{mnist,fashion_mnist,qd_dev}.json` and the p9_gates builder's dev logs (`scratchpad/p9_gates/dev_*.log`).

**Method.**
- Line-by-line review of every new fit-time operation.
- An instrumented **copy** of dfg12.py, with counters only and the arithmetic unchanged, run inside hyb_portfolio2 on 7 dev toy fits.
- Measurements of the LightGBM tree work for ggbt and for v1's gbt on the dev QuickDraw and Fashion training pools (the builder's caches). Labels were used only to grow trees, and nothing was predicted.
- Run settings: all `nice -n 19`, single-threaded BLAS, `python -B`. About 4.5 CPU-min in total, under 1.5 GB. Nothing was written under gd-circuit-growth/.

**Scripts and outputs.** In `scratchpad/p9/audit/compute_work/`: `dfg12_instr.py`, `toy_sum.py`, `ggbt_count.py`, `fractions.py`. Their outputs are quoted below.

**Budgets used.** Images (d = 784, C = 10): `budget_real` = 3 MLP runs.
- n ≤ 3000: 1.241e12. The step count S is at its floor of 2000, so n = 100, 300, 1000 and 3000 all have the *same* budget.
- n = 10000: 2.424e12.
- n ≥ 30000: 6.205e12.
- Toy: one network run, 1.624e11.

## 1. Verdict

**On FLOPs, the budget claims hold for every evidence cell. There is no blocker.**

| component | own count (largest) | corrected / bound | within budget? |
|---|---|---|---|
| DFG v1.2 (toy) | 0.548 (thr10, n = 16384, reproduced) | sum-block work is charged within 0.6–1.4×; at most +0.04 of a network run on any measured fit (§3, F4) | yes, by measurement. By construction the worst case rises from Part 8's ≈ 1.1 to ≈ 1.2 (F5) |
| p9_gates / hyb_portfolio2, dev image cells (n = 1000, 10000, 60000) | 0.458 (Fashion n = 60000) | ≤ 0.47 (Fashion n = 1000) | yes |
| hyb_portfolio2, QuickDraw-shape grid cells **not run on dev** (projection; no held-out file read) | n = 3000: ≈ 0.64 | **≈ 0.72 (0.69–0.81)**; every other n ≤ ~0.45 | yes |
| hyb_portfolio2 on Fashion-MNIST n = 3000 (a regression-check cell; projection) | ≈ 0.73 | **≈ 0.94 (0.77–1.12)** | borderline (F2) |
| p9_bank (dev) | 0.812 (Fashion n = 60000) | ≈ 0.83 at most (Fashion n = 10000, after the gbt correction) | yes |

**The CPU-time requirement fails** (F1):
- At n = 60000 the frozen gates member takes 1352 / 1657 / 1749 CPU-s per fit (MNIST / Fashion / qd_dev).
- The builder's task said "within ~15 min CPU per fit at n = 60000". These fits are 1.5–1.9× over that.
- They are 5.3–8.4× v1's CPU time and about 10–36× the recorded MLP reference times.

**Prediction** costs ≈ 2.75e8 FLOPs per query at n = 60000 (F3):
- 510× an MLP's 2P, and 170× mlp_strong's 3-network ensemble.
- A 10000-point test set costs 0.44 of the fit budget.

## 2. Findings (most severe first)

### F1 — major (disclosure / process) — the gates member misses the CPU-time requirement at n = 60000 by 1.5–1.9×, and the known fix was not applied at integration

**Evidence.**
- The builder prompt (`agent-a8221d3409e741891.jsonl`, line 2) says: "It must fit within budget and within ~15 min CPU per fit at n = 60000."
- The dev results (`p9_gates-dev__*.json`, `cpu_seconds`) at n = 60000:

  | | MNIST | Fashion-MNIST | qd_dev |
  |---|---|---|---|
  | p9_gates (CPU-s per fit) | 1352 | 1657 | 1749 |
  | v1 (`hyb_portfolio__*.json`, seed 0) | 237 | 314 | 209 |
  | p9_bank | 191 | 258 | 237 |
  | mlp_strong, recorded (amortized over vectorized seeds, so only indicative) | 118 | 103 | 48 |
  | mlp, recorded | 137 | 118 | 67 |

- Part 8's estimate for the 3 MLP runs the budget corresponds to is 124–194 s.
- Implied rates:
  - the whole fit runs at 1.5–2.0 GFLOP/s by its own count;
  - the gates block runs at 0.55–0.97 GFLOP/s (gates FLOPs / (fit CPU − v1 CPU)).

**Root cause, confirmed** (`ggbt_count.py`, qd_dev, n_fit = 21600, bagging 0.5):
- With LightGBM's automatic layout, ggbt takes **258.6 ms per tree**. With `force_col_wise=True` it takes **90.8 ms**: 2.85× less, for the same tree count.
- The extra time is the per-tree copy of the sampled columns of the row-wise multi-value bin (the builder's diagnosis, p9_gates/DESIGN.md:166-177). It is data movement, which the FLOP convention does not charge.
- `fit_ggbt`'s parameters (p9_gates/learner.py:310-312 = hyb_portfolio2/learner.py:316-318) still lack `force_col_wise`. The PROTOCOL.md freeze section does not mention the CPU overrun or the unapplied fix.
- Peak RSS at n = 60000 is ≈ 6 GB, which caused 3 OOM kills on dev (DESIGN.md:179).

**Consequence.**
- "Within the networks' compute" holds in FLOPs only.
- The held-out qd_a / qd_b fits will take ≈ 25–30 CPU-min at n = 60000 (and roughly 10–15 at n = 30000). That is about an order of magnitude more CPU time than the MLP references for a comparable or smaller error.
- The integration rule weighs accuracy only, so the member that won the rule (p9_gates) is also the one that is ~7× slower than the alternative (p9_bank), although p9_bank uses 1.7× the FLOPs.

**Fix.**
1. In the Part 9 write-up, report CPU-s per image fit next to the FLOP fraction, and state the missed 15-min criterion.
2. Add `cpu_seconds` to `compare_part9.py`'s image tables.
3. For any rerun, apply `force_col_wise=True` as a recorded deviation, after re-checking bit-identical predictions on a dev cell. The builder already showed max |ΔP| = 0 on qd_dev n = 8000 after 40 rounds.

### F2 — major (conditional) — Fashion-MNIST at n = 3000 projects to ≈ 0.94 of the budget (up to 1.12), and the skip guard cannot see it; the dev run never tried n = 3000

**Evidence.**
- The dev evaluation covered n ∈ {1000, 10000, 60000} only. Yet n = 3000 is where the portfolio is costliest relative to the budget:
  - the budget is the same as at n = 1000, but there are 3× the rows;
  - each of the 6 ggbt fits in the k-fold regime runs 100 rounds × 10 classes.
- Gates block at n = 3000, own count (`fractions.py`; per-tree counts measured):

  | part | own count | measured basis |
  |---|---|---|
  | ggbt | ≈ 1.98e11 | 2.18e7 per tree on qd_dev, 2.45e7 on Fashion, at n_fit = 2400 |
  | gknn (leave-one-out) | 1.2e10 | – |
  | pooling | 5.9e9 | – |
  | **total** | **≈ 0.174 of the budget** (Fashion ≈ 0.197, its bank being larger: F = 3433) | – |

- The skip guards compare *own* counts with 0.9 × budget (p9_gates/learner.py:533, 545). On Fashion the guard's total is v1's own 0.54 + 0.20 ≈ 0.73, so ggbt runs.
- v1's `gbt` charge (`10 n d + 8·31·d·255` per tree, :143) is still uncorrected. The Part 8 audit put v1's corrected Fashion n = 3000 total at 0.74 (0.58–0.90). Adding the gates block (count ratio 0.94–1.19, below) gives **≈ 0.94, with a range of 0.77–1.12** for the per-bin cost c_bin = 8–16.
- QuickDraw, the actual Q2 evidence: v1's own count on qd_dev at n = 3000 is 0.463.
  - Measured gbt correction at n_tr = 2400: 1.14–1.46 × (the gbt share is 0.334).
  - ggbt correction: 0.96–1.20 ×.
  - Result: **hyb_portfolio2 ≈ 0.72 (0.69–0.81)**, within budget.

**Consequence.** Part 9's protocol lists MNIST and Fashion-MNIST as regression checks. If hyb_portfolio2 is run on the Fashion grid, its n = 3000 cell can exceed the budget under the upper per-bin constant without any guard or reported number showing it. The headroom Part 8 had (0.74) shrinks to about 0.06.

**Fix.**
- Report the projection now.
- If the Fashion (or MNIST) regression grid is run, recount v1's gbt on that cell from `Dataset.feature_num_bin`, as ggbt already does. One way is to refit one seed's boosters with `lgb_tree_flops`. Report the corrected fraction.
- In future, charge `gbt` with `lgb_tree_flops` as well, so the guards see the corrected count.

### F3 — minor (carry the disclosure into the write-up) — prediction is a lazy-learner cost: ≈ 2.75e8 FLOPs per query at n = 60000

**Evidence** (upper bound: all three kNN scans kept by the stacker; `fractions.py`). The terms per query:
- v1's std and raw scans: 2 × 2·n·d = 1.88e8;
- gknn's scan of all n pooled rows: 2·n·a = 8.1e7, with a = 676;
- the dense 0/1 pooling product: 2·d·a = 1.06e6;
- ggbt's projections: 2·d·(3a + 300) = 3.65e6;
- trees: ≈ 4e4.

| n | per query | × MLP 2P (5.39e5) | × mlp_strong (3 nets) | 10000 test points / fit budget |
|---|---|---|---|---|
| 1000 | 9.3e6 | 17 | 6 | 0.075 |
| 3000 | 1.8e7 | 34 | 11 | 0.15 |
| 10000 | 5.0e7 | 92 | 31 | 0.21 |
| 30000 | 1.4e8 | 259 | 86 | 0.23 |
| 60000 | 2.75e8 | 510 | 170 | 0.44 (= 1.33 MLP training runs) |

- With prediction charged, n = 60000 is ≈ 0.43 + 0.44 ≈ 0.87 of the budget, so still within it.
- At small n the dense pooling and projection matmuls dominate. Sparse sums would cost ≈ 6e3 and ≈ 5e5.
- Memory: v1's two copies of the training rows (≈ 0.38 GB) plus the pooled rows (≈ 0.16 GB float32).
- DESIGN.md §4 already states ≈ 2.8e8, ≈ 500× and 0.45, so the numbers are right. But `compare_part9.py` reports nothing about image compute.

**Fix.** Put this table in the Part 9 write-up, next to Part 8's 350×.

### F4 — minor — DFG v1.2: the sum-block search is charged correctly to within about ±40%, but it is not "a few percent of a fit" on every fit

**Evidence** (instrumented copy inside hyb_portfolio2, dev toy, seed 0, inputs permuted; `toy_sum.py`):

| cell | fit / GD | DFG / GD | sum section / GD | share of fit FLOPs | CPU s (sum section) | DFG fits / rounds |
|---|---|---|---|---|---|---|
| dlsymdev sym7, n = 128 | 0.031 | 0.019 | 0.0012 | 3.7% | 2.9 (1.4) | 22 / 22 |
| dlsymdev twosym, n = 512 | 0.061 | 0.054 | 0.0048 | 7.9% | 7.8 (2.4) | 11 / 21 |
| dlsymdev twosym, n = 2048 | 0.106 | 0.096 | 0.0061 | 5.7% | 8.5 (2.3) | 6 / 6 |
| **designed thr10, n = 2048** | 0.307 | 0.296 | **0.1025** | **33.4%** | **43.2 (38.5)** | 6 / 47 |
| dlsymdev band11, n = 4096 | 0.083 | 0.077 | 0.0018 | 2.2% | 3.8 (0.7) | 2 / 2 |
| dlsymdev twosym, n = 16384 | 0.236 | 0.206 | 0.0050 | 2.1% | 9.7 (1.3) | 2 / 2 |
| designed thr10, n = 16384 (the dev maximum) | **0.548** | 0.518 | 0.0248 | 4.5% | 19.8 (7.4) | 2 / 6 |

- The thr10 n = 16384 row reproduces the builder's maximum (DESIGN.md:129-131).
- **Charged items**, with their lines in dfg12.py:
  - block statistics: prefixes 8·mg·K (:187), greedy steps (:225), refinement moves (:262);
  - eigendecompositions: 10 d³ per search (:199);
  - degree-1 coefficients;
  - final tests: 2nk + 4n (:283);
  - the r_S projection (:509-510);
  - tS (:515);
  - deflations: 2nd² (:532);
  - modulated pair matrices (:572);
  - product tests and column building;
  - the larger least-squares and logistic fits, through v1.1's counters.
- **Measured charge per `_multi_T` element: 8.04** (thr10 n = 2048: 1.665e10 charged over 2.07e9 elements). The actual work per element is:
  - building the candidate column: 1–3 FP ops;
  - the `rint` index: 3 FP ops;
  - the weighted bincount: 1 FP op;
  - in all, **5–7 FP ops, plus about 3 integer index ops**.
- **Uncounted items:**
  - refinement's `cur = Xg[:, S] @ sg` recompute (:249): ≤ 10% of a refinement step;
  - the group-table arithmetic in `_multi_T`: ≤ 0.5 op per element;
  - the product base index `gbg·L + I` (:170): 2 integer ops per element;
  - `SumBlock.stat` calls in tS, the deflations and the product and split setup: measured ≤ 1.5e-4 GD per fit;
  - `np.unique` and `searchsorted` comparisons: not FLOPs.
- So the true work of the sum section is **0.6–1.4× its charge** (FP only to all-in).

**Consequence.**
- The largest error on any measured fit is ≤ +0.04 GD (thr10 n = 2048: 0.31 → ≤ 0.35). On the largest fit it is ≤ +0.01 (0.548 → ≤ 0.56). No toy budget verdict changes.
- DESIGN.md:129 ("a few percent of a fit") is wrong for thr10 at n = 2048: there the sum search is 33% of the FLOPs and 89% of the CPU.
- The section runs at only 0.3–0.6 GFLOP/s by its own count, against DFG v1.1's ≈ 10. Python and bincount overhead explain this, and it is not a sign of undercounting.

**Fix.** Correct the sentence, with this table. It is also the quantitative backing for the "1.5–3× v1.1 CPU" caveat.

### F5 — minor — DFG v1.2: the sum search is not scaled by DFG's budget share, so the by-construction toy bound rises to ≈ 1.2

**Evidence.**
- The only cap is the round-start test `fl > 0.75·GD` (dfg12.py:379).
- v1.1's searches are scaled by budget shares. The sum section instead runs a fixed number of searches per round: 2 additive, 1 conditional product, 1 split and 4 modulated, with mg = min(n, 2048) and k_max = 24.
- Worst case per round at d = 30: ≈ 2.55e9 + 1.8e4·n ≈ **2.6–2.9e9 FLOPs (≈ 0.016–0.018 of a network run)**. The terms per search:
  - prefixes: ≈ 2.1e3·mg;
  - greedy growth: 5.0e4·mg;
  - refinement: 1.04e5·mg;
  - plus 2nd² terms.
- For a fold fit at n ≈ 2000–3000 (fold GD = 0.07 × 1.624e11 = 1.14e10), one round can therefore add **≈ 0.23 of that fit's own GD** after the cap was last checked.
- The measured maximum was 0.038 of the fit's GD per round, and the loop ended at ≤ 0.54 of the fit's GD.
- On binary tabular data (mushroom, d ≈ 117) a round costs ≤ ~1.3e10, which is ≤ 6% of a DFG fit's GD share there.

**Consequence.**
- Part 8's worst-case bound (F5 there, ≈ 1.1) gains about 6 fits × 0.016 ≈ +0.1 at n ≈ 2000–3000, giving **≈ 1.2**, and about +0.035 at n = 16384, giving ≈ 1.14.
- The measured dev maximum stays 0.548. The held-out toy maxima are unknown to me.
- Toy compute remains bounded by measurement, not by construction.

**Fix.** Read "largest FLOPs per fit / one network run", which `compare_part9.py` prints for dlheld4 and dlheld5, and disclose any value > 1 as an overrun. For future versions, count the sum search against a share, as v1.1's searches are.

### F6 — minor — ggbt's analytic tree count is right; v1's gbt formula is off on QuickDraw too

**ggbt** (`lgb_tree_flops` at p9_gates/learner.py:267-272; trees = `bst.num_trees()`, so the early-stopping patience rounds are charged):

| data | n_fit (bag) | F | mean bins | ρ bank / pixels | Σ min / n_bag | ms per tree | code count | audit count, c_bin 12 (dense–sparse) / c_bin 16 | audit / code | GFLOP/s by code |
|---|---|---|---|---|---|---|---|---|---|---|
| qd_dev | 2400 (1.0) | 3112 | 59.6 | 0.60 / 0.29 | 1.07 | 37.8 | 2.18e7 | 2.08–2.17e7 / 2.61e7 | 0.96–1.20 | 0.57 |
| Fashion | 2400 (1.0) | 3433 | 61.3 | 0.69 / 0.49 | 1.00 | 43.2 | 2.45e7 | 2.32–2.47e7 / 2.91e7 | 0.94–1.19 | 0.57 |
| qd_dev | 7200 (1.0) | 3112 | 60.3 | 0.60 / 0.29 | 0.88 | 83.7 | 3.14e7 | 2.53–2.75e7 / 3.28e7 | 0.81–1.05 | 0.37 |
| qd_dev | 21600 (0.5) | 3112 | 60.4 | 0.60 / 0.29 | 0.75 | 258.6 (auto) / 90.8 (col-wise) | 3.87e7 | 2.78–3.19e7 / 3.72e7 | 0.72–0.96 | 0.15 / 0.43 |

- At small n the split search is 82% of the tree work. The count is at most 20% low there, and conservative at large n. At the n = 60000 shape (n_bag ≈ 24500) it is ≈ 1.3–1.8× high.
- The implied rate of 0.12–0.57 GFLOP/s is below the 0.4–1.9 that Part 8 measured for LightGBM. This points to uncharged data movement (F1), not missing arithmetic.
- The other gates charges check out:
  - pooling-set correlation 2·r·a² (r ≤ 20000): measured 7–15 GFLOP/s, a slight overcount if numpy uses syrk;
  - pooled features 2·n·d·a;
  - projections 2·n·d·m (21 GFLOP/s);
  - binning 16·n·F (nominal: binning is sort- and compare-bound, e.g. 1.5 s for 1.2e8 charged);
  - gknn leave-one-out 2·h·n·a + 3·h·n;
  - out-of-fold traversal 10 per tree per row;
  - validation scoring 20 per row per tree;
  - refits, charged through `fit_ggbt`.
- Uncharged: validation-set binning and array copies, both negligible.

**v1's `gbt` on QuickDraw** (new data, raw pixels, max_bin 255):

| n_tr | mean bins | ms per tree | code count | audit / code (c_bin 12–16) |
|---|---|---|---|---|
| 800 | 63 | 17.2 | 5.59e7 | 0.57–0.73 |
| 2400 | 138 | 57.6 | 6.84e7 | **1.14–1.46** |
| 8000 | 196 | 105.9 | 1.12e8 | **1.09–1.37** |

**Consequence.** These are the corrections behind F2's QuickDraw number. In the dev cells they add ≤ 0.04 (n = 10000) and lower n = 1000. Corrected dev maxima:
- Fashion n = 1000: ≈ 0.47;
- qd_dev n = 1000: ≈ 0.25–0.30;
- qd_dev n = 10000: ≈ 0.26–0.29;
- n = 60000: ≤ 0.46.

**Fix.** Report the corrected maxima, and note that ggbt's own count is already audit-style.

### F7 — minor — the Part 9 tables report no compute for images

**Evidence.** `compare_part9.py` prints "largest FLOPs per fit / one network run" for the toy suites only (:57-61). `img_part()` (:72-101) has no FLOP fraction, no `cpu_seconds` and no prediction cost. Part 8's audit fixes F2 and F3 asked for these, and they were adopted in HYBRID.md §6.

**Consequence.** RESULTS.md cannot show F1–F3.

**Fix.** Add a per-image-cell "FLOPs / budget_real" column (own count; the corrected maxima from F2 and F6 in the text), CPU-s per fit, and the per-query prediction table. (The definitions are at compare_part9.py:57 for the toy line and :67 for `img_part`.)

### F8 — minor — grid cells never run with the frozen member; post-freeze change

**Evidence.**
- n = 100, 300, 3000 and 30000 of the held-out grid were never run with the frozen member before the held-out runs. At n_fit < 500 the frozen code fails: LightGBM rejects min_data_in_leaf < 20 after feature pre-filtering.
- `hyb_portfolio2/learner.py` carries a post-freeze fix, `feature_pre_filter=False` when mcs < 20 (:319-322). Its md5 is now **e38af404…**. The fix was committed and recorded during this audit (commit 37763afa; PROTOCOL.md:78-85, "Post-freeze crash fix").
- Compute-wise the fix can only raise the bin count `nb`, which is read from the Dataset and charged.
- Projected own counts:
  - n = 100 and 300: v1 0.45–0.47 (overcounted; Part 8 corrected these to ≤ 0.2), plus gates ≤ 0.16 (an upper bound, at 60 bins per feature);
  - n = 30000: ≈ 0.22.

**Consequence.** These cells are within budget by projection, but their first execution is the held-out run.

**Fix.** Disclose that the small-n and n = 3000 / 30000 compute fractions are first observed in the held-out run. The crash fix itself is now recorded. Add the projected fractions to the write-up and check the actual ones in the held-out result files.

## 3. Checked and correct (no finding)

- **p9_bank.**
  - Dev own counts: 0.67 / 0.71 / 0.73 (MNIST, n = 1000 / 10000 / 60000), 0.70 / 0.80 / 0.81 (Fashion), 0.68 / 0.72 / 0.74 (qd_dev).
  - The count is dominated by the exactly charged Gram matrix 2·N·F² (float32 BLAS), plus pairs, quantiles, screening and the ridge solves (p9_bank/learner.py, `fit_bank`, `bank_cost`).
  - F is sized against min(0.6·B, 0.9·B − spent − 0.7·gbt charge), which reserves the Part 8 gbt correction. Corrected maximum ≈ 0.83.
  - CPU at n = 60000: 191–258 s, within the 15-min guide.
  - It lost the integration rule and is not in hyb_portfolio2.
- **p9_gates dev fits, own count** (`p9_gates-dev__*.json`):

  | dataset | n = 1000 | n = 10000 | n = 60000 |
  |---|---|---|---|
  | MNIST | 0.373 | 0.257 | 0.433 |
  | Fashion-MNIST | 0.442 | 0.376 | 0.458 |
  | qd_dev | 0.355 | 0.251 | 0.433 |

  - The gates block (p9_gates − v1, seed 0) is 0.69–1.5e11 at n = 1000, 2.0–3.3e11 at n = 10000 and 0.74–1.08e12 at n = 60000.
  - These agree with my formula projection: 1.05e12 at n = 60000, an upper bound at 400 rounds.
- **Budgets** and the image rule `is_image` (d ≥ 256, all columns continuous) are unchanged, so toy and tabular budgets are Part 8's. On toy data hyb_portfolio2 = p9_sum: the gates code is skipped.
- **DFG v1.2 on binary tabular data** (kr_vs_kp, mushroom): the per-round sum search is ≤ ~6% of a DFG fit's share (F5). The builder's kr_vs_kp n = 1000 fit used 0.080 of the budget, against v1's 0.063.
- **Unchanged Part 8 items:** logistic regression charge ≈ 0.87× true, ExtraTrees within ~2×, LU p³/3, and uncharged out-of-fold predictions. None of them matters at the Part 9 sizes.
