# Part 9 protocol (written before any Part 9 design work)

Part 8 left two clear failures of the discrete portfolio `hyb_portfolio` against gradient-descent-trained networks:
1. **symmetric functions** (sym9 = [|x1 + ... + x9| <= 1]: 1229 samples against 350 for the best network) - its Fourier
   weight is spread over many characters, so a character search pays for each one;
2. **images at large n** (MNIST / Fashion-MNIST at n >= 30000: a regularized MLP ensemble wins clearly) - nearest
   neighbours and axis-aligned trees are the only image members.
Part 9 adds (a) *sum features* - discrete functions of signed sums of inputs, phi(x) = g(sum_{i in S} s_i x_i) with S a
subset, s_i in {-1, +1} and g an indicator of a value set of the integer sum - to the character search, and (b) discrete,
**pixel-permutation-invariant** image members (no use of pixel adjacency: the comparator is an MLP, which is invariant
to a fixed permutation of the inputs; a method using spatial structure would have to be compared with a CNN).

**Data access.**
- *Development:* toy `designed` (21) and the new symmetric dev suite `dlsymdev` (8 targets, boolfuncs.make_dl_symdev_suite);
  images MNIST, Fashion-MNIST (both already seen in Part 8) and the new `qd_dev` (QuickDraw, 10 categories); tabular DEV.
  Part 8's held-out results (dlheld3 including sym9, HELDOUT2, ...) are known and may be looked at, but are not evidence.
- *Held out (fixed now, before any design):* toy suite `dlheld4` (12 targets: 9 symmetric / signed-sum targets of new
  sizes and accept-sets, mixtures with parities and gates, and 3 non-symmetric controls) and the QuickDraw sets `qd_a`,
  `qd_b` (10 categories each, disjoint from `qd_dev`; 60000 / 10000; columns permuted by one fixed permutation, as are
  `qd_dev`'s). Category lists: data.py and the cache.
- Regression checks (not evidence; already seen): toy `dlheld3`, tabular DEV and HELDOUT2, MNIST / Fashion-MNIST.

**Budgets** as in Part 8: one network training run per toy fit; 3 MLP training runs per real fit (common.budget_real);
everything counted; prediction cost reported separately.

**References.** Toy (`dlsymdev`, `dlheld4`): `nets`, `nets_wd` (decoupled weight decay 0.1), `nets_cewd` (logistic loss
+ weight decay 0.1), `nets_best` (per-target best, hindsight), plus `lin` and the Part 8 learner `hyb_portfolio` (v1).
Images (`qd_dev`, `qd_a`, `qd_b`): `mlp`, `mlp_l2unit`, `mlp_strong` (and its single network `mlp_strong1`), `mlp_best`
(per-cell hindsight best), `hgb`, and `hyb_portfolio` v1. Seed 0 only at n >= 30000 for every learner (memory, compute);
3 seeds below.

**Design.** Builders work on development data only, freeze, and run a full dev evaluation once:
- S: DFG v1.2 = DFG v1.1 + sum-feature blocks; delivered as a replacement of the portfolio's DFG member.
- I1, I2: two independent discrete, permutation-invariant image members (different angles), each delivered as a member
  added to the portfolio.
**Integration rule (fixed now).** `hyb_portfolio2` = `hyb_portfolio` with (i) DFG v1.2 in place of DFG v1.1 if, on the dev
toy suites (`designed` + `dlsymdev`, permuted inputs, against `nets_best`), the S variant's mean log2 n* ratio is lower than
v1's and no dev target gets worse by more than 0.5 in log2; and (ii) the image member (I1 or I2) whose portfolio
variant has the lower mean log2(err / mlp_best err) over the dev image cells (MNIST, Fashion-MNIST, qd_dev; all n), if
that mean is lower than v1's on the same cells. The image member runs only on inputs that are all continuous with d >= 256
(images), so tabular results are unchanged by construction. `hyb_portfolio2` is frozen before any held-out Part 9 run.

**Evaluation and verdicts** (as in Part 8; `compare_hybrid.py` rules): toy - n* per target, permuted inputs, against each
network reference; images - per-cell verdicts and mean log2 ratios against each MLP reference, by n range.
Pre-registered questions:
- Q1 (sum features): on `dlheld4`, is `hyb_portfolio2`'s mean log2 n* ratio against `nets_best` below 0 with more
  clearly-better than clearly-worse targets, and is it below v1's on the symmetric targets?
- Q2 (images at large n): on `qd_a` and `qd_b`, at n >= 10000, is `hyb_portfolio2`'s mean log2(err / ref err) below 0
  against `mlp_strong` and against `mlp_best`, and below v1's?

**Amendment (before any design work, for compute):** the dev image cells of the integration rule are MNIST,
Fashion-MNIST and `qd_dev` at n in {1000, 10000, 60000}, seed 0 (9 cells); the references there are the existing / queued
result files. The S builder's dev evaluation is the full toy grid (3 seeds) on `designed` and `dlsymdev`, inputs permuted.

**Amendment 2 (26 October, 23:08 UTC, commit 7449313e; after the sum-feature builder froze, before any held-out Part 9 run).** The S
builder reports that an over-long text search printed the *source code* of `make_dl_heldout4_suite` (the target
definitions) at the start of its work; no dlheld4 data or results were touched. So `dlheld4` is not blind for the sum-feature
component. A fifth suite, `dlheld5` (boolfuncs.make_dl_heldout5_suite, seed 9393), was generated now by rejection sampling
from a fixed random family of signed-sum targets (plus two random-formula controls), not hand-picked, after the S design
was frozen; nobody has seen its targets' behaviour. Q1 is answered on both suites; `dlheld5` is the clean test, `dlheld4`
is reported with the exposure noted. Networks (nets, nets_wd, nets_cewd), lin, hgb and v1 are run on dlheld5 as on dlheld4.

## Integration and freeze (27 October 2026, 02:11 UTC, commit a2489545, before any held-out run of hyb_portfolio2)

- (i) Sum features: on `designed` + `dlsymdev` (permuted, against `nets_best`), p9_sum's mean log2 n* ratio is -2.30
  (29 better / 0 worse) against v1's -1.71 (23 / 5; v1 never learns band11); no dev target is worse than v1 by more than
  0.5 in log2 (largest +0.05, mux). Met: DFG v1.2 is used.
- (ii) Image member, mean log2(err / mlp_best err) over the 9 dev image cells (seed 0; mlp_best = per-cell best seed-mean
  of all MLP variants): **p9_gates -0.105**, p9_bank -0.007, v1 +0.046 (study/part9/RESULTS.md, "Integration rule").
  p9_gates is used. (p9_bank's builder session was killed by a container restart and resumed by a new agent from its
  partial files; p9_gates's last dev cell was rerun after an out-of-memory kill and a restart, with the frozen file.)
- `hyb_portfolio2/learner.py` = `p9_gates/learner.py` with the DFG module path switched to `p9_sum/dfg12.py` and the
  name changed (make_v2.py); **md5 6837fa52627c588318cce10f0c47ac8f**. Equivalence checks: identical predictions to
  p9_sum on 3 toy fits (sym7 n=256, par3 n=64, thrsum n=512), to p9_gates on qd_dev n=1000, to v1 on satimage n=300.
- Already run before this freeze, with frozen components whose inclusion did not depend on them: p9_sum (identical to
  hyb_portfolio2 on toy inputs) on dlheld4 and dlheld5. The headline toy rows are hyb_portfolio2's own runs.
- (Added after the audit.) Before this freeze the orchestrator saw three held-out log lines printed by progress monitors:
  the last line of v1's qd_a and qd_b logs, and one p9_sum dlheld5 line (h5t0: 10% test error at n = 104, networks 770).
  Both rule parts were mechanical and reproduce exactly from dev files, so no integration decision depended on them.

**Post-freeze crash fix (27 October; made 02:14 UTC, committed 02:24, commits 1a99637a and 37763afa).** The frozen hyb_portfolio2 crashed at its first held-out image cell
(qd_a and qd_b, n = 100, seed 0) before producing any result: the gates booster lowers LightGBM's `min_data_in_leaf`
below the Dataset's construction value (20) when a member's training set has fewer than 500 points, which LightGBM refuses
with feature pre-filtering on. The gates dev evaluation never covered n < 1000, so it was not seen. Fix: pre-filtering is
switched off only when `min_data_in_leaf` < 20 (one line in fit_ggbt). Verified: identical predictions to the unfixed
p9_gates at qd_dev n = 1000 (and the fix cannot act at n_fit >= 500, i.e. on every dev cell and every image cell with
n >= 1000); runs at n = 100 and 300. New md5 **e38af40493816ef1bc82e4f16428dcdf**. No held-out result existed when the fix was
made. The toy runs are unaffected (the gates member never runs on toy inputs); some toy shards ran before, some after.
