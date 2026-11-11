# Part 8 audit, lens: compute accounting

**Scope.** This audit covers code and process only. It checks the frozen `hyb_stage`, `hyb_union` and `hyb_portfolio`
learners (md5 checked against PROTOCOL.md: 75bbfc08…, d780099c…, 063bcd91…), plus `common.py`,
`standard_tasks/harness.py`, `mlp.py` and `discrete_learner/dfg.py`. **No held-out result file was read.**

**Method.**
- Line-by-line review of every fit-time operation.
- A derivation of the work LightGBM does per tree, from its algorithm.
- Measurements, all `nice -n 19` with single-threaded BLAS: about 3.5 CPU-min in total, under 1.5 GB.

**Data used for the measurements.**
- Dev data: optdigits, satimage, magic, and the toy `designed` suite (maj9, par3).
- For LightGBM bin and tree-shape counts only: the first training rows of MNIST, Fashion-MNIST and texture. Labels
  were used only to grow trees; no prediction or error was computed.
- For the projection table: shapes, column types and column s.d. of all held-out datasets. No fits were run.

**Scripts and outputs.** All in `/tmp/claude-0/-home-user-AI-works/addd33f6-5c52-5bee-997e-3f98d4e90609/scratchpad/hybrid/audit/compute_work/`:
`blas.py`, `lgb_count.py`, `lgb_small.py`, `lr_iters.py`, `stage_trees.py`, `toy_port.py`, `project.py` →
`project.json`.

## 1. Verdict per design (after corrections)

| design | toy fits (budget: 1 network run, 1.62e11) | real fits (budget: 3 MLP runs) | within budget? | prediction FLOPs per query, worst vs MLP's 2P |
|---|---|---|---|---|
| hyb_portfolio | 0.59 measured (dev maj9, n = 16384); 0.56 of it is DFG (exact count). Not capped by construction: the worst-case bound is ≈ 1.1 (F5) | **0.74** at Fashion-MNIST n = 3000 (range 0.58–0.90; its own count ≈ 0.54). MNIST n = 3000 ≈ 0.41; images at n = 60000 ≈ 0.31. Every other held-out cell is ≤ 0.15, except the DFG cells (mushroom, kr_vs_kp), which are exactly counted and bounded by construction at ≤ ~0.75 | yes | **350×** at MNIST / Fashion n = 60000 (1.9e8 per query). The 10000 test points cost 1.9e12, which is 0.30 of the fit budget and 0.91 of one MLP run |
| hyb_stage | 0.59 on dev (dominated by exactly counted search, LS and Newton). No guard on the readout (F5) | 0.36 on dev. Trees are ≤ 0.7% of the budget in all 3 instrumented dev fits, so correcting them adds ≤ 0.01. On images, ≤ ~0.5 even if early stopping never fires | yes (on evidence; no guard) | 12× (6.4e6 per query on images); ≤ 4% of the fit budget per test set |
| hyb_union | 0.24 on dev | 0.088 on dev; 0.18 on images (stopped by the time limit) | yes (guarded at 0.9 of a count that overstates trees and ExtraTrees) | 36× (adult, n = 38842: 6.4e6 per query); ≤ 6% of the fit budget per test set |

**No blocker.** No design's counted or corrected compute exceeds its budget anywhere I could check or bound.

There are two major items, both on hyb_portfolio:
- its LightGBM charge understates the work on high-cardinality image inputs at n ≈ 1000–10000 (F1);
- its kNN prediction cost must be disclosed (F2).

## 2. Findings (most severe first)

### F1 — major — hyb_portfolio: the LightGBM formula is off by 0.05–1.7×. The cost of the largest image cells is understated

**Where.** `hyb_portfolio/learner.py:121` (charge) and `:129-131` (projection, used by the skip guard at `:349-350`).

**What the code charges per tree:** `10·n·d + 8·31·d·255`.
- The first term is histograms: "≤ 5 levels with the subtraction trick, 2 FLOPs per row-feature".
- The second is the split search: 248 FLOPs per (feature, bin), with 255 bins assumed for every feature.

**Audit count per tree** (LightGBM leaf-wise growth, num_leaves L = 31, from the training loop and `FeatureHistogram::FindBestThresholdSequentially`):

  F_tree ≈ 2·d_u·ρ·(n_bag + Σ_splits min(n_left, n_right)) + c_bin·B_u·(2L − 3) + 2·B_u·(L − 2) + ~22·n

The terms are:
- **Histograms.** These are built for the root and the smaller child of each split, at 2 adds per stored row-feature
  entry. ρ is the share of entries outside the most frequent bin, which sparse and multi-value bins skip. The measured
  Σ min / n is 0.36–2.2.
- **Split finding.** There are 2L − 3 = 59 leaf evaluations per tree. Each scans every bin of every used feature, at
  c_bin ≈ 12 FP ops per bin: 3 accumulations, the count conversion, 3 left = total − right, 2 ε-adds, and 2 × (mul, add,
  div) for the gains. A defensible range for c_bin is 8–16.
- **Histogram subtraction.** For the larger child: 2·B_u per split.
- **The rest.** Gradients and hessians, partition, and the score update.

B_u is the number of bins actually used (measured from `Dataset.feature_num_bin`). So the split term is ≈ 766·B_u,
against the code's 63,240·d. They are equal only when the mean bins per feature is ≈ 83.

**Measured.** Portfolio settings, LightGBM 4.7.0, single thread. CPU time excludes binning, except for the rows
marked *, whose time includes the Dataset construction.

| inputs | n_tr | d_used | mean bins | mean leaves | ms per tree | code formula per tree | audit per tree | audit / code | GFLOP/s by code | GFLOP/s by audit |
|---|---|---|---|---|---|---|---|---|---|---|
| toy maj9 / par3 (C = 2) | 13108 | 30 | 3 | 31 | 3.7 – 3.8 | 5.8e6 | 1.3e6 – 2.9e6 | 0.22 – 0.50 | 1.5 – 1.6 | 0.4 – 0.8 |
| optdigits | 2400 | 56 | 15 | 29 | 1.8* | 5.6e6 | 1.25e6 | 0.22 | 3.0 | 0.7 |
| texture (C = 11) | 2400 | 40 | 255 | 14 | 2.3 | 3.5e6 | 4.4e6 | 1.27 | 1.5 | 1.9 |
| MNIST | 90 / 270 / 800 / 2400 / 8000 | 260 – 556 | 13 – 150 | 21 – 31 | 2 – 61 | 5.0e7 – 1.1e8 | 2.3e6 – 8.0e7 | **0.05 / 0.11 / 0.34 / 0.69 / 0.71** | 25 → 1.8 | 1.2 – 1.9 |
| MNIST, rs 0.5, cs 0.25 | 27000 | 607 | 165 | 31 | 93 | 3.9e7 | 2.7e7 | 0.71 | 0.4 | 0.3 |
| Fashion-MNIST | 90 / 270 / 800 / 2400 / 8000 | 587 – 781 | 19 – 199 | 21 – 31 | 5 – 168* | 5.0e7 – 1.1e8 | 7.5e6 – 1.5e8 | **0.15 / 0.36 / 1.04 / 1.68 / 1.32** | 9 → 0.7 | 0.9 – 1.5 |
| Fashion-MNIST, rs 0.5, cs 0.25 | 27000 | 783 | 212 | 31 | 487* (1 round, mostly binning) | 3.9e7 | 4.2e7 | 1.08 | – | – |

**The audit count tracks CPU time.**
- By the audit count, all 15 unsubsampled configurations run at 0.4–1.9 GFLOP/s, over 90–13108 rows, 3–255 bins and
  30–784 features. The 0.4–0.8 values are the small toy and optdigits trees, where fixed per-tree overheads dominate.
- The code's formula gives implied rates from 0.67 to 25 GFLOP/s.
- So it is the formula, not the machine, that varies: it overcounts at small n and on low-cardinality inputs, and
  undercounts on Fashion at n_tr ≈ 800–27000.

**What it changes.** The table below is hyb_portfolio's own-count projection for the image cells, recomputed from the
code's formulas (`project.py`), then corrected with the ratios above. The logistic-regression charge is scaled by the
measured true / charged ratio of 0.87, and both C values hit max_iter = 200 on Fashion (§4).

| n | own count: kNN + GBT + LR (upper) ≈ total | corrected, Fashion | corrected, MNIST |
|---|---|---|---|
| 100 | 0.000 + 0.446 + 0.013 ≈ 0.46 | 0.08 | 0.03 |
| 300 | 0.000 + 0.458 + 0.038 ≈ 0.50 | 0.20 | 0.08 |
| 1000 | 0.003 + 0.270 + 0.061 ≈ 0.33 | 0.34 | 0.15 |
| **3000** | 0.023 + 0.331 + 0.182 ≈ **0.54** | **0.74** (0.58–0.90 for c_bin 8–16) | 0.41 |
| 10000 | 0.026 + 0.093 + 0.104 ≈ 0.22 | 0.24 | 0.18 |
| 30000 | 0.091 + 0.006 + 0.061 ≈ 0.16 | 0.15 | 0.15 |
| 60000 | 0.182 + 0.011 + 0.137 ≈ 0.33 | 0.31 | 0.31 |

- **The guard does not protect against this.** The skip guard compares the same formula with 0.9 × budget. A larger
  GBT share on high-cardinality data could therefore have overrun unnoticed. The largest own GBT share on such data is
  0.33 (Fashion n = 3000), so no cell actually overruns.
- **Tabular held-out cells are far from the line.** The largest own GBT share among them is texture n = 3000 at 0.063,
  which becomes 0.08 after correction.
- **Toy cells are overcounted** (audit / code = 0.22–0.50).

**Proposed fix (no rerun needed).**
1. In HYBRID.md and in `compare_hybrid.py`'s "largest FLOPs / budget", replace the GBT charge on the MNIST and
   Fashion-MNIST cells with the audit count. One option is to multiply by the factors above, taking the n_tr each fit
   used. Another is to compute F_tree from `lgb.Dataset(X_train).construct()` bin counts with L = 31 and
   Σ min ≤ 1.6·n, deterministically, from training inputs only.
2. Report the held-out image maximum as ≈ 0.74, not the own count of ≈ 0.54.
3. For future learners, charge boosters from their dump, as `lgb_count.py` does.

### F2 — major (disclosure) — hyb_portfolio's prediction is a full kNN scan: up to 350× an MLP per query

**Where.** `hyb_portfolio/learner.py:401-407`. The final kNN members score every query against all n training points,
under each kept metric. Prediction is not counted (`:25`, as in the protocol), and the networks' prediction cost is
2P per query.

**Size.** Upper bound with both metrics kept, as the builder's MNIST-shape check kept them (`knn_raw_27`, `knn_std_1`).

| cell | per query | × MLP 2P | test set | / fit budget | / one MLP run |
|---|---|---|---|---|---|
| MNIST / Fashion, n = 60000 | 1.89e8 | 350 | 1.89e12 (10000 points) | 0.30 | 0.91 |
| n = 30000 | 9.4e7 | 175 | 9.4e11 | 0.15 | 0.46 |
| n = 10000 | 3.1e7 | 58 | 3.1e11 | 0.13 | 0.39 |
| connect_4 57557 / sleep 95908 / adult 38842 | – | 74 / 49 / 47 | 10000 points each | 0.064 / 0.042 / 0.041 | – |
| toy, n = 16384 (kNN kept on maj9) | 1.0e6 | 25 | 4.2e9 (4096 points) | 0.026 | – |

**Other designs.**
- hyb_stage scores against ≤ 4096 prototypes: ≤ 12× per query (learner.py:640, `_nn_prep` P cap).
- hyb_union scores against ≤ nref references and ≤ 128 dimensions once capped: ≤ 36× (adult), and 26× at images
  n = 10000 (learner.py:692).
- For a full test set, both stay at ≤ 4% and ≤ 6% of the fit budget respectively.

**What it changes.** The FLOP verdict is unchanged: even with prediction charged, hyb_portfolio stays within budget
(at MNIST n = 60000, fit ≈ 0.31 plus test set 0.30 ≈ 0.6). But its compute profile is lazy-learner-like. Per test
point it is 2–3 orders of magnitude costlier than the networks, and it stores all n training rows twice (≈ 0.38 GB
float32 at n = 60000, against the MLP's 0.27 M parameters).

**Fix.** State the per-query and per-test-set prediction FLOPs for each design in HYBRID.md, next to the fit
fraction. Optionally add a "fit + prediction / budget" column for the image cells, where both sides are charged
(the networks' 2P·n_test is ≤ 5.4e9, which is negligible).

### F3 — minor — at equal FLOPs, the tree-heavy fits cost far more CPU time than the MLPs

The protocol's measure is FLOPs, so this is not an accounting error. But "within the networks' compute" reads
differently in CPU time.

**Measured rates.**

| work | GFLOP/s |
|---|---|
| LightGBM (audit count) | 0.4–1.9 |
| ExtraTrees (its count) | 0.11–0.15 |
| kNN at d = 30 (selection-bound) | 1.2 |
| numpy float64 / float32 BLAS here | 57 / 111 |
| DFG | 10.4 |
| study's networks (prior audit) | 32–50 |

**Example.** On Fashion-MNIST at n = 3000, hyb_portfolio fits 6 × 1000 LightGBM trees at ≈ 82 ms each, which is
≈ 8 CPU-min, plus 12 LR fits at 2.4 s. That is ≈ 9 single-core CPU-min for ≈ 0.74 of the FLOP budget. Three MLP runs
(1.24e12 FLOPs) at 32–50 GFLOP/s take ≈ 25–40 s.

On dev the designs' per-fit CPU times (≤ 30 s) are comparable to the MLP's. The gap is specific to the images.

**Fix.** Report CPU-seconds per fit next to the FLOP fraction for the image cells, and add one sentence of caveat.

### F4 — minor — hyb_stage: the LightGBM split term is undercounted on high-cardinality inputs; trees and readouts have no budget guard

**Where.** `hyb_stage/learner.py:402-405`. Per tree it charges `2·n·bf·d·ff·⌈log2 L⌉ + 4·max_bin·d·L`.

**How far off.**
- The split term is 124 per (feature, bin), against the audit's ≈ 766·ff. With d ≤ 100 (ff = 0.8, max_bin = 255)
  this is ≈ 4.9× under per bin; the histogram term is ≈ 2.5× over.
- With d > 200 (max_bin = 63, ff = 0.3) the two roughly cancel: ≈ 1.1× on Fashion-shape inputs, from
  F_tree(max_bin 63) on texture 1.36e6 against the formula's 1.27e6.

**Instrumented dev fits** (`stage_trees.py`, every `lgb.train` recorded):

| fit | trees, own count | trees, audit | share of budget | whole fit |
|---|---|---|---|---|
| satimage n = 1000 | 2.4e9 | 1.0e9 | 0.007 → 0.003 | 0.068 |
| satimage n = 3000 | 7.9e8 | 6.3e8 | 0.002 | 0.125 |
| magic n = 1000 (bins 227) | 9.5e7 | 3.3e8 | 0.0003 → 0.001 | 0.052 |

In these fits early stopping held trees to ≈ 50 rounds per call.

**Worst case if early stopping never fired.** Taking 600 rounds × 7 calls × C on texture (n = 1000, C = 11), trees
would be 0.17 by the own count and ≤ 0.57 by the audit. This is not realistic, but nothing in the code prevents it:
there is no budget guard on trees (`:591-606`) or on the softmax and Newton readouts (`:569-571`).

**Fix.** Disclose. Read held-out maxima from the result files (the readouts dominate and are exactly counted). If any
stage cell's own fraction is > 0.5, recount its trees by refitting one seed with `stage_trees.py`.

### F5 — minor — toy compute for hyb_portfolio and hyb_stage is bounded by measurement, not by construction

**hyb_portfolio.** DFG's budget share bounds only the search loop, which stops starting rounds at 0.75·GD
(`dfg.py:142`). After the loop come:
- the final LS fit;
- the 15-step logistic readout (`dfg.py:274-280`), costing 15 × 2·n·p² with p ≤ max_feats + linear block ≈ 290.

At n = 16384 these add ≈ 3.4e10 (out-of-fold fit) + 4.2e10 (final fit) ≈ 0.47 of a GD run on top of the shares.
The worst case is ≈ 0.51 (out-of-fold) + 0.03 (other members) + 0.60 (final) ≈ **1.1**.

Measured, maj9 at n = 16384 used 0.592:

| part | FLOPs | CPU s | GFLOP/s |
|---|---|---|---|
| DFG | 9.12e10 | 8.7 | 10.4 |
| kNN | 3.4e9 | – | – |
| GBT | 1.3e9 | – | – |
| ExtraTrees | 2.2e8 | – | – |

**hyb_stage.** The damped-Newton readout (up to 40 steps per λ, 4 λ × 2 NN options, plus the final fit;
`learner.py:350-361`) is likewise unguarded.

Both are counted exactly, so an overrun on the held-out dense-halfspace targets (thr30, maj15, maj21, thr20) would
show up in the harness's "max FLOPs / GD".

**Fix.** Check "Largest compute used" in the held-out toy reports, and disclose any value > 1 as an overrun.

### F6 — minor — hyb_union's wall-clock stop makes large fits load-dependent

**Where.** `hyb_union/learner.py:495` stops boosting after `time.time() - t_start > 480`.

**Effect.** In the builder's MNIST-shape check, with 2 jobs on 2 cores, this allowed 51 rounds at 0.18 of the budget.
In the current held-out run (4 jobs on 4 cores at nice 5, load ≈ 5) the image fits will get a load-dependent number
of rounds. This does not threaten the budget, since the design uses less compute. But those results are not
reproducible from the seed.

**Fix.** Record `info["rounds"]` and the stop reason per image fit and disclose them. For a rerun, use a FLOP or round
cap or `process_time`.

### F7 — minor — ExtraTrees count (hyb_portfolio) is plausible within about 2×, and its size is negligible

**Where.** `hyb_portfolio/learner.py:144-148` charges 4·mtry·Σ over internal nodes of n_node_samples, measured from
each fitted tree. (n_node_samples counts the unique bootstrap samples, which is what the splitter loops over.)

**What it misses.**
- sklearn's RandomSplitter redraws features until it has visited mtry *non-constant* ones. Each constant feature
  costs a gather plus a min/max over the node's samples.
- The final partition and criterion initialisation per node (≈ 2·n_node).
- The out-of-bag predictions.

**Plausible undercount.** 1.2–2× on dense continuous data; up to ≈ 3–4× on binary or sparse inputs (toy, MNIST
borders).

**Size.** ExtraTrees is ≤ 0.3% of the budget in every regime: 2.15e8 (0.13%) on toy maj9 at n = 16384, 1.2e10 (0.2%)
at MNIST-shape n = 60000. Even a CPU-time ceiling of 2 FLOP/cycle × 2.8 GHz bounds it at ≤ 7%.

hyb_union's ExtraTrees formula (`:396`, n·log2(n)² × trees) overstates the cost.

**Fix.** None needed beyond one line of disclosure.

### F8 — minor — small uncounted or approximated items, < 2% of the budget anywhere

- **LU solves.** Charged p³/3 instead of 2p³/3: stage `:131`, union `:577`, dfg `:134`. This is largest in union's
  per-round linear block at small n, where it is ≤ 2%.
- **Stage's training-row margins.** Computed for every λ (`:574`) and not charged: 2·n·p·C per fit, under 1% of the
  softmax fit.
- **Stage's kNN argpartition.** Not charged (`:487`): ≈ 3·n·P comparisons, against the charged 2·n·P·d. That is
  ≤ 1/(2d) relative, on a term that is ≤ 0.1% of the budget.
- **Out-of-fold predictions.** The members' out-of-fold predictions on held-out folds (portfolio `:292`) are not
  charged.
- **Binning and gradients.** Stage does not charge LightGBM binning. LightGBM's gradient and score-update work is
  ≈ 22·n per tree; it is not charged in any design, but is included in my audit count.
- **Encodings.** These are O(n·d_enc).

### Checked and correct (no finding)

- **Logistic regression (portfolio `:92`).** It charges 5·n·p·k·n_iter. Measured nfev / nit is 1.07–1.10. True
  (4npk + 12nk per evaluation) / charged is 0.86–0.88 on Fashion n_tr = 2400 (both C hit max_iter = 200) and 0.95 on
  satimage. Stage and union charge function evaluations exactly.
- **kNN distances.** 2·q·n·d plus 3·q·n for selection (portfolio `:190`; union `:373-375`; stage `:509,517`) is exact
  for the BLAS product, and the selection is about right. Leave-one-out costs are charged against all n.
- **DFG and the character searches.** The searches in `dfg.py`, stage `_grow` and union `char_search` / `walsh_local`
  / pool rescoring charge every matrix product. Implied rates are 10.4 GFLOP/s (portfolio DFG) and 3.1–3.2 GFLOP/s
  (whole stage fits). Both are far below the 57 GFLOP/s float64 BLAS peak, so there is no undercount signal.
- **Stacker (portfolio `:214`).** 6·h·M·C·(nit + nfev) is about 2–3× the true cost, and negligible in size.
- **Refits.** Cross-validation refits and final refits are charged in all three designs.
- **Budgets.** `common.toy_budget(30)` = `harness.gd_flops(30)` = 1.624e11. `budget_real` = 3 × `mlp_flops`
  (6P·128·S) = the baseline MLP's 2 lr runs on 90% + retrain.
  - `budget_real` takes d_enc from the categories seen in the training subset, while the MLP one-hot encodes the full
    code domain. At small n on categorical sets the budget is therefore slightly below the MLP's true cost, which is
    conservative.
  - The MLP's 40 validation evaluations (≤ 6% of a run at n = 60000) are outside its count, which is negligible. Its
    test-set checkpoint evaluations are reporting, and rightly excluded.

## 3. Measured machine rates (single thread, nice 19, under load ≈ 5)

| item | rate |
|---|---|
| numpy float64 matmul 2048³ | 57 GFLOP/s |
| numpy float32 matmul 2048³ | 111 GFLOP/s |
| float32 (2000 × 784) @ (784 × 6000), kNN-shaped | 77 GFLOP/s |
| `np.bincount` with weights (scalar scatter-add) | 0.31 G adds/s |
| LightGBM, audit count | 0.4–1.9 GFLOP/s (0.3 for the bagged and feature-subsampled MNIST booster) |
| sklearn LR, lbfgs (Fashion, 2400 × 784 × 10) | 7.8 GFLOP/s by its charge |

An implied rate above BLAS peak would mean undercounting, and no member shows one.

For scalar library code this test is weak, because any count below peak looks plausible. So the LightGBM conclusion
rests on two things instead:
- the algorithmic count;
- the fact that its implied rate stays within 0.4–1.9 GFLOP/s across 15 configurations, while the code's formula
  implies 0.67–25 GFLOP/s.

## 4. Prediction cost per design (per query, worst cell; MLP: 2P = 5.4e5 on images, 4.1e4 on toy)

| design | images n = 60000 | images n = 10000 | worst tabular | toy n = 16384 |
|---|---|---|---|---|
| hyb_portfolio (kNN, all n, ≤ 2 metrics) | 1.9e8 (350×) | 3.1e7 (58×) | connect_4 74× | 1.0e6 (25×) |
| hyb_stage (kNN, ≤ 4096 prototypes) | 6.4e6 (12×) | 6.4e6 (12×) | clean2 6× | 2.5e5 (6×) |
| hyb_union (kNN, nref × ≤ 128 dims once capped) | 4.2e6 (8×) | 1.4e7 (26×) | adult 36× | 8.8e5 (21×) |

Trees, characters and linear readouts add ≤ 1e4–1e5 per query in every design.
