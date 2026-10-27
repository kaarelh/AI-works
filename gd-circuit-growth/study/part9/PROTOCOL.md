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

**Amendment 3 (27 October, after the Part 9 protocol audit; before any run on the new suite, and before the orchestrator
had read any hyb_portfolio2 toy result).** The protocol audit (audit/protocol.md, M1 and M2) found that neither held-out
toy suite tests Q1 blind to the sum-feature design:
- `dlheld4`: builder S saw its source, the orchestrator's task prompt to S quoted a truncation of its target sumpar, and
  S's block-size and modulator parameters were set minutes after the exposure.
- `dlheld5`: blind to target identities, but its family was specified by the orchestrator 35 s after reading S's design
  summary, including S's list of unsupported forms. The family lies inside S's representable class and its accept sets
  are more oscillatory than any dev target's, which favours S over the networks and v1. "The clean test" (Amendment 2)
  is withdrawn.

A sixth suite, **`dlheld6`** (`part9/heldout6/`, `boolfuncs.make_dl_heldout6_suite`, seed 52817; 12 targets
h6_00 ... h6_11), was written by a fresh agent given only: the pre-registered description of the held-out suite ("9
symmetric / signed-sum targets of new sizes and accept-sets, mixtures with parities and gates, and 3 non-symmetric
controls"), the Part 9 question, sym9 as the motivating failure, the dev-suite format (three dlsymdev targets) and the
constraints (d = 30, 5-14 relevant inputs, P(+1) in [0.25, 0.75] as the only rejection rule, one seed). It was told not
to read anything under part9/ outside its own folder, boolfuncs.py, results, logs or git history; its tool calls
(transcript) touched only its folder and the scratchpad. It wrote the family (heldout6/FAMILY.md, sections 1-6) before
drawing once. Controls: h6_03, h6_04, h6_05 (Q1's sum-structured subset is the other 9).

**Q1 is answered on `dlheld6`** with the pre-registered criteria (mean log2 n* ratio against `nets_best` below 0 with
more clearly-better than clearly-worse targets; below v1's on the sum-structured targets). `dlheld5` and `dlheld4` are
reported as secondary evidence with their exposures. References on `dlheld6`: nets, nets_wd, nets_cewd (hence
nets_best), lin, hgb and v1; v2 (frozen, md5 e38af404...) is run per target with permuted inputs; on toy inputs it is
identical to p9_sum, which is not run separately. At this point the orchestrator had seen no hyb_portfolio2 toy result
(its dlheld5 shards are committed but unopened) and one p9_sum dlheld5 log line (h5t0; see the freeze section).

**Amendment 4 (27 October, ~03:10 UTC, after the four Part 9 audits; fixed before any hyb_portfolio2 held-out result was
read).** The fairness and discreteness audits (audit/fairness.md, audit/discreteness.md) found the references plausible
but not at the frontier, and the image gain unattributed. Added now, none of them tuned on held-out results:
- **R1 `mlp_wide` / `mlp_wide1`** (strengthening; fairness F1): the mlp_strong recipe at width 512, weight decay in
  {0.1, 1, 3} chosen on validation, an ensemble of 3 (`mlp_wide`, 6 runs of width 512) and its first network
  (`mlp_wide1`, one retrained network, about 0.8 of the 3-run budget; 4 runs counting selection). qd_a and qd_b, the
  full grid (3 seeds at n <= 10000, seed 0 at n >= 30000).
- **R2 `mlp_xl`** (CPU-matched; fairness F2): the same recipe at width 1024, an ensemble of 3; qd_a and qd_b at
  n = 10000 and 60000, seed 0. Its CPU time is of the order of hyb_portfolio2's at n = 60000; its FLOPs are far above
  the budget.
- **R3 `nets_cewd0.3`, `nets_cewd1.0`** (fairness F6): logistic loss with weight decay 0.3 and 1.0, on `dlheld6`.
- **C1 `mlp_pool`** (post-hoc control; discreteness D1, fairness F3): the mlp_strong recipe on [x, pooled sums at
  k = 4, 9, 16], the pooling sets computed by hyb_portfolio2's own `pool_sets` from each fit's training rows; qd_a and
  qd_b, n in {1000, 10000, 60000}, seed 0. It separates the representation from the learner.
- **C2 `cnn`** (context only; discreteness D1): a small CNN on the *unpermuted* pixels (it uses the layout, which the
  MLPs and the discrete learners do not), the mlp_strong recipe otherwise; qd_a and qd_b, n in {1000, 10000, 60000},
  seed 0. It is not a Q2 reference.
- **C3 attribution** (discreteness D3): from 03:0x UTC the evaluator also stores each fit's stack weights and per-member
  out-of-fold errors (training rows only); the remaining hyb_portfolio2 image cells record them. The learner is unchanged.
- **Reporting:** `mlp_reg` maps to `mlp_l2unit` on QuickDraw too (fairness F5, a table bug); CPU seconds per fit are
  reported next to FLOPs.

**Q2 is answered twice:** as pre-registered (against `mlp_strong` and the pre-registered `mlp_best`), and against
`mlp_best+` = the per-cell best of every MLP variant including R1 and R2 (hindsight; R2 is not FLOP-matched). **Q1** uses
`nets_best` over all network variants run on the suite (on `dlheld6`: nets, nets_wd, nets_cewd, nets_cewd0.3,
nets_cewd1.0).

