# p10_hier: a max-pooling second level for v2's image booster (Part 10, image builder, angle "deeper discrete hierarchy")

Frozen code: `learner.py` (class `Learner`, default constructor, name `p10_hier`), md5
**`1da21bf797ca3f247103e31428d74fe5`** (also in `learner.md5`), frozen 27 October 2026 19:45 UTC after about 55 minutes of
development; the file was made read-only and not changed afterwards. Starting point: v2 = `part9/hyb_portfolio2/learner.py`
(md5 `e38af40493816ef1bc82e4f16428dcdf`).

Data access: development used only validation rows of the seed-0 training pools (train = pool[:n], validation =
pool[50000:60000]) of `qd_dev`, `qd_a`, `qd_b`, Fashion-MNIST, plus optdigits (tabular, identity check). No test row was
scored before the freeze. `qd_c`, `qd_d` and `dlheld7` were never loaded, generated, printed or inspected by this builder.

**Disclosure (after the freeze).** At about 20:00 UTC, 15 minutes after the freeze, while finding out why the n = 60000
dev cell was waiting for the shared lock, I printed the last 5 lines of the stdout log of the process holding it
(`scratchpad/p10/logs/mlp_qd_c.log`, the orchestrator's `mlp.py qd_c` reference run). Those lines are the baseline MLP's
`qd_c` test errors at n = 100 – 3000. Nothing about any discrete learner on `qd_c` was shown, nothing was loaded or run,
and the learner had been frozen and made read-only before; it cannot have influenced the design. No other held-out
file or log was opened.

## 1. What changed (and only this)

Everything is v2 except the image member's booster `ggbt` (the `gates` block, which runs only when every column is
continuous and d >= 256). On toy and tabular inputs the code path is v2's: optdigits n = 300 gives identical predictions
and an identical FLOP count (`check_same.py`). `gknn`, the Part 8 members, the stacker and the budgets are untouched.

**Level 1 (v2, unchanged).** Pooling sets S_i(k) = the k columns most correlated with column i (training rows only;
i first; ties by a column fingerprint), and the subset sums p_i^(k)(x) = sum_{j in S_i(k)} x_j at k = 4, 9, 16.

**Level 2 (new).** For (k, K) in {(4, 9), (9, 16), (16, 49)} and every non-constant column i,

    m_i^(k,K)(x) = max_{j in S_i(K)} p_j^(k)(x),

the maximum of the level-1 map over the K columns most correlated with i (the same ranking, read further down the list).
LightGBM thresholds every feature at histogram-bin boundaries, so a split [m_i^(k,K) > t] is exactly the OR over the K
recovered neighbours j of i of the level-1 gates [p_j^(k) > t]: "a blob of scale k brighter than t somewhere near i". In
CNN terms: a fixed box-filter layer on the data-recovered topology (v2), followed by max-pooling over a recovered
neighbourhood (new); the tree still chooses t, and the AND of such OR-gates along a root-to-leaf path is a part-based
detector that tolerates small shifts of each part.

**ggbt's bank** becomes [x, p^(4), p^(9), p^(16), m^(4,9), m^(9,16), m^(16,49)]: 784 + 6a columns (a = number of
non-constant pixels of the training rows, 676 on `qd_dev` and 784 on Fashion-MNIST at n = 10000: 4840 / 5488 columns,
against v2's 3112 / 3436).

**Other changes inside ggbt:**
- the 300 prototype-pair projections are dropped (no dev gain at n = 10000: `qd_dev` 0.1502 with, 0.1487 without;
  Fashion-MNIST 0.1070 / 0.1056; the Part 9 post-hoc ablation found −0.02 log2 at n = 60000);
- LightGBM runs with `force_col_wise=True` (Part 9 found bit-identical models and 2.2–2.7x less CPU);
- the bank is freed as soon as LightGBM has binned it (memory; the model is unchanged);
- rounds: early-stopping cap 400 -> 600 (training sets >= 5000; the early-stopping rule itself is v2's); fixed rounds
  below 5000 points 100 -> 150 (k-fold regime, n <= 3000; the refit on all n uses the same count).

## 2. Discreteness and permutation invariance of the new features

- **Discrete.** m_i^(k,K) has no parameter: a max over a set chosen by a data statistic (correlation ranking) of subset
  sums with weights in {0, 1}. Its gates are ORs of level-1 gates at a data-quantile threshold. Nothing continuous is
  fitted: as in v2, only boosting's Newton leaf values and the stacker's convex weights are. Removing the prototype pairs
  also removes v2's one borderline ingredient in this member (continuous oblique directions x_a − x_b, discreteness audit
  D2).
- **Permutation invariant.** The neighbour lists are v2's ranking (exactly equivariant: correlations rounded to 1e-9,
  ties by fingerprint), read to depth 49. `test_perm.py` (dev data, n = 2000, three random column permutations each):
  identical neighbour lists for every pixel, the pixel block identical, every pooled and level-2 column equal up to
  float32 summation order (max |diff| 1.9e-6 – 2.9e-6 on `qd_dev`, 3.8e-6 on Fashion-MNIST): PASS on both. LightGBM's
  per-tree column sampling draws by column index, so ggbt (as v2's ggbt, gbt, et) is invariant in distribution only.
- **What it is in spirit.** The pooling sets recover the pixel grid (discreteness audit D1), and max-pooling over
  recovered neighbourhoods is the CNN's translation-tolerance mechanism. So the member moves further towards "a fixed,
  untrained CNN-like feature hierarchy on a recovered layout, read out by boosted trees". It still never uses the layout
  itself, learns no filter, and has no continuous feature direction.

## 3. Development (validation rows only; ggbt alone unless stated)

LightGBM as in ggbt (31 leaves, lr 0.1, 63 bins, 12% of columns per tree, col-wise), trained on pool[:n], error on the
10000 validation rows after R rounds. Scripts and logs: `dev/` (copies of the scratchpad `p10_hier/` files `feats.py`,
`exp1.py`, `exp2.py`, `exp_knn.py`, `timing.py`, `*.log`).

| set, n | bank | R = 100 | R = 300 | best (round) |
|---|---|---|---|---|
| qd_dev 10000 | v2's bank [x, p4, p9, p16, 300 pairs] | 0.1624 | 0.1502 | 0.1502 (300) |
| | [x, p4, p9, p16] (no pairs) | 0.1581 | 0.1487 | 0.1483 (293) |
| | + p25, p49 (larger level-1 scales) | 0.1571 | 0.1498 | 0.1494 |
| | + counts of [p4 > t] over S_i(16), t at the 50% / 80% quantile of positive p4 | 0.1569 | 0.1469 | 0.1468 |
| | + m(4,9), m(9,16) | 0.1493 | 0.1378 | 0.1376 |
| | + m(4,16), m(9,25), m(16,49) | 0.1475 | 0.1383 | 0.1380 |
| | **+ m(4,9), m(9,16), m(16,49)** (frozen) | 0.1447 | **0.1361** | 0.1359 (273) |
| | + the same + sum over S_i(9) of m(4,9) (a third level) | 0.1482 | 0.1360 | 0.1360 |
| qd_a 10000 | [x, p4, p9, p16] | 0.1654 | 0.1505 | 0.1498 |
| | + m(4,9), m(9,16) | 0.1553 | 0.1426 | 0.1421 |
| | + m(1,9) (max of raw pixels), m(4,9), m(9,16) | 0.1518 | 0.1420 | 0.1420 |
| | **+ m(4,9), m(9,16), m(16,49)** | 0.1510 | **0.1379** | 0.1379 (300) |
| Fashion 10000 | v2's bank | 0.1114 | 0.1075 | 0.1070 |
| | [x, p4, p9, p16] | 0.1133 | 0.1065 | 0.1056 |
| | + m(4,9), m(9,16) | 0.1125 | 0.1078 | 0.1073 |
| | **+ m(4,9), m(9,16), m(16,49)** | 0.1136 | **0.1069** | 0.1069 |

Small n (the k-fold regime fits ggbt on 80% of n with fixed rounds), error at 100 / 150 rounds:

| set, n | [x, p4, p9, p16] | + m(4,9), m(9,16), m(16,49) |
|---|---|---|
| qd_dev 800 | 0.2629 / 0.2632 | 0.2452 / 0.2417 |
| Fashion 800 | 0.1899 / 0.1887 | 0.1872 / 0.1873 |
| qd_b 2400 | 0.2486 / 0.2475 | 0.2312 / 0.2274 |

Reading: on QuickDraw the level-2 OR-gates are worth −0.10 to −0.14 in log2 for the booster alone at every size tried,
against v2's bank; Fashion-MNIST (centred, aligned objects) neither gains nor loses. The gain is the max (OR) nonlinearity,
not a larger receptive field (larger level-1 scales: nothing) and not counting (count-pooling of thresholded gates:
almost nothing). A third level (sum over a neighbourhood of a max-pooled map) added nothing; neither did max-pooled raw
pixels. With the level-2 bank, 150 rounds beat 100 at n = 800 and 2400 (−0.02 log2), which v2's bank did not.

**gknn unchanged.** kNN on max-pooled maps was worse than on v2's p^(9) (`qd_dev` n = 10000, 5000 validation rows,
1/3/9/27-NN): p9 0.2022 / 0.1942 / 0.1910 / 0.2094; m(4,9) 0.2162 / 0.2032 / 0.2018 / 0.2148; m(9,9) 0.2052 / 0.1996 /
0.1950 / 0.2132; [p9, m(4,9)] 0.2000 / 0.1922 / 0.1894 / 0.2044; m(4,16) 0.2348 / 0.2284 / 0.2228 / 0.2444.

**CPU per tree** (`timing.py`, `qd_dev` n = 20000, 15 rounds, one shared core): v2's bank with LightGBM's automatic
(row-wise) layout 159 ms; v2's bank col-wise 69 ms; the frozen bank col-wise 100.5 ms (0.63x v2's per-tree time with
1.56x the columns).

Not tried for lack of time: consistent orientations (oriented edge maps that could be max-pooled need a consistent
direction across positions, which the correlation ranking does not give), lower feature fractions for the larger bank,
other level-2 scale sets on Fashion-MNIST.

## 4. FLOP accounting (multiply-add = 2)

Everything is counted as in v2, plus:
- level-2 maps: (K − 1) comparisons per output entry, n · a · (8 + 15 + 48) per fit for the training rows, the same per
  out-of-fold row (`l2_flops`); the neighbour lists come from v2's ranking (its a² log a sort is already charged);
- ggbt's binning (16 per row per column) and trees (the compute audit's per-tree formula, with the bins actually built)
  now over the larger bank; no pair projections;
- the budget guard uses the larger bank, 600 / 150 rounds.

## 5. Fixed dev evaluation (frozen code, run once)

`eval_cells.py p10_hier.learner:Learner <ds> --ns=... --seeds=0 --tag=p10_hier-dev`: test error, seed 0, the same splits
and per-fit rng as v2's files (`p9_gates-dev__{qd_dev,fashion_mnist}`, `hyb_portfolio2__{qd_a,qd_b}`).

Run 27 October 19:45–21:35 UTC (four processes at once on the shared, heavily loaded machine; load average 20–26 on
4 cores, so CPU seconds are inflated relative to an idle machine, as v2's own were; the n = 60000 cell ran last, under the
shared lock, on a less loaded machine). Every cell records the learner md5
`1da21bf7…`. The `qd_dev` process was OOM-killed once by the shared memory cgroup (about 20:29, during its n = 10000 fit; total
cgroup memory, not this fit alone) and restarted; the cell is resumable, so the n = 1000 cell was kept and n = 10000
refitted from scratch with the same rng. Earlier, at about 20:13, the same cgroup limit had OOM-killed the
orchestrator's reference job `mlp.py qd_c` (pid 760, 1.9 GB) while my four dev processes (1–1.8 GB each) were running;
my processes contributed to that memory pressure. Total wall time of this builder: 18:52–21:36 UTC (freeze at 53 min;
the rest is the evaluation on the loaded machine and 1 h 28 min of waiting for the lock).

| set | n | v2 err | p10_hier err | log2 ratio | v2 CPU s | p10_hier CPU s | v2 budget | p10_hier budget | ggbt out-of-fold err | ggbt weight | ggbt rounds |
|---|---|---|---|---|---|---|---|---|---|---|---|
| qd_dev | 1000 | 0.2217 | **0.2101** | −0.078 | 132 | 201 | 0.36 | 0.48 | 0.266 | 0.30 | 150 (5 folds) |
| qd_dev | 10000 | 0.1467 | **0.1329** | −0.143 | 376 | 467 | 0.25 | 0.31 | 0.1445 | 0.35 | 214 |
| fashion_mnist | 1000 | **0.1805** | 0.1816 | +0.009 | 186 | 282 | 0.44 | 0.58 | 0.187 | 0.11 | 150 (5 folds) |
| fashion_mnist | 10000 | 0.1247 | **0.1234** | −0.015 | 457 | 466 | 0.38 | 0.38 | 0.1246 | 0.20 | 161 |
| qd_a | 3000 | 0.1875 | **0.1759** | −0.092 | 542 | 462 | 0.58 | 0.72 | 0.1887 | 0.32 | 150 (5 folds) |
| qd_a | 10000 | 0.1509 | **0.1456** | −0.052 | 606 | 307 | 0.28 | 0.22 | 0.1675 | 0.41 | 119 |
| qd_b | 3000 | 0.2238 | **0.2109** | −0.086 | 625 | 485 | 0.62 | 0.70 | 0.2177 | 0.31 | 150 (5 folds) |
| qd_b | 10000 | 0.1860 | **0.1748** | −0.090 | 563 | 447 | 0.25 | 0.29 | 0.182 | 0.32 | 170 |
| qd_a | 60000 | 0.1197 | **0.1108** | −0.111 | 1757 | 924 | 0.42 | 0.44 | 0.1152 | 0.51 | 327 |

(v2: `p9_gates-dev__{qd_dev,fashion_mnist}.json`, `hyb_portfolio2__{qd_a,qd_b}.json`, seed 0; budget = the fit's own
FLOP count / `common.budget_real` (3 MLP training runs); out-of-fold errors are on the fit's stacking rows. Table from
`compare_dev.py`.)

**Integration-rule numbers.**
- Mean log2(err / v2 err) over the 8 small cells: **−0.068** (threshold: below −0.05). 7 of 8 cells lower, Fashion-MNIST
  n = 1000 +0.009 (11 more errors among 10000 test points). QuickDraw cells alone: −0.090; Fashion-MNIST: −0.003.
- `qd_a` n = 60000: test error **0.1108** against v2's 0.1197 (log2 −0.111; the rule's limit is 0.1257); **924 CPU s**
  per fit against v2's 1757 (0.53x; the limit is 2636); own FLOP count **0.44 of the budget** (v2: 0.42). ggbt alone
  took 699 CPU s (v2's: 1473), early-stopped at 327 rounds (the 600 cap did not bind), out-of-fold error 0.1152 (v2's
  0.1267), stacking weight 0.51. Peak process RSS 6.5 GB (sampled every 5 s; `dev/rss_60000.log`), about v2's ~6 GB.
  The fit waited 1 h 28 min for the shared large-fit lock (held by reference MLP runs) and ran 21:13–21:35 UTC.
- Budget: every small cell within budget (largest 0.72, `qd_a` n = 3000).

**Reading.**
- The QuickDraw gains in the portfolio (−0.05 to −0.14) are about what the booster-alone dev runs predicted (−0.07 to
  −0.14), diluted where the stacker leans on other members (`qd_a` n = 10000: −0.052).
- At n = 10000 v2's early-stopping rule (inner validation split of 10% = 800 points, error-based, patience 50, at least
  150 rounds) stopped the new booster at 119–214 rounds, while on 10000 validation rows the dev curves were still
  falling at 300 (§3). The 600-round cap therefore did not bind at n = 10000, and the n = 10000 cells were cheaper in
  CPU than v2's at `qd_a` / `qd_b` (column-wise histograms). The early-stopping rule is v2's and was not changed.
- Small n costs more: the k-fold regime fits the booster 6 times with 150 rounds on the larger bank (`qd_dev` n = 1000:
  201 CPU s against 132; Fashion-MNIST: 282 against 186).

## 6. Weaknesses

- **The gain is QuickDraw's.** On the dev validation rows the level-2 bank helps the booster on `qd_dev`, `qd_a`, `qd_b`
  (−0.07 to −0.14 log2 for ggbt alone) and does nothing on Fashion-MNIST (centred, aligned garments: translation
  tolerance has nothing to buy). MNIST was not used. The effect on the portfolio is diluted by the stacker (ggbt has
  0.11–0.41 of the weight on the dev cells) and by the members that did not change.
- **Closer to a CNN in spirit.** The pooling sets recover the pixel grid (Part 9 discreteness audit D1); a sum-pool
  followed by a max-pool over recovered neighbourhoods is a fixed (untrained) two-layer CNN-like feature hierarchy. It
  never uses the layout, learns no filter and has no continuous direction, but the comparison with permutation-invariant
  MLPs is even less information-matched than v2's; a CNN or a graph network on the recovered neighbourhoods is the fair
  comparator, and was not run.
- **No orientation.** Every level-1 and level-2 feature is isotropic (blob sums and their maxima). Oriented stroke
  detectors, the obvious next level for line drawings, need a consistent direction across positions, which the
  correlation ranking does not give; not attempted.
- **Chosen on few cells, one seed.** The scale set {(4, 9), (9, 16), (16, 49)}, the 600-round cap and the 150 small-n
  rounds were each chosen from one or two dev cells (booster alone, one LightGBM seed). Differences of 0.002–0.004 in the
  tables of §3 are within run-to-run noise; the level-2 gain (0.008–0.014) is not.
- **The 600-round cap and dropping the pairs were not tested at n = 60000 before the freeze.** In the one large-n dev
  cell the cap did not bind (early stop at 327 rounds), so the large-n gain (−0.111) comes from the bank, net of the
  pairs' −0.02 that the Part 9 post-hoc ablation measured; one cell, one seed.
- **Early stopping is noisy at n = 10000.** v2's rule (error on an 800-point inner split, patience 50) stopped the
  booster at 119–214 rounds, where the 10000-row dev curves were still falling at 300; a better stopping rule might be
  worth more than the cap, and was not tried (frozen).
- **CPU at small n goes up.** In the k-fold regime ggbt is fitted 6 times with 150 rounds on a bank 1.56x v2's, so
  fits at n <= 3000 cost more CPU than v2's (`qd_dev` n = 1000: 201 s against 132 s), even with the column-wise layout.
- **Budget use goes up** (`qd_dev` n = 1000: 0.48 of the budget against 0.36); still well inside, and the guard (skip
  ggbt if its projection takes the total above 0.9) never fired on dev.
- **Memory.** The bank is 1.56x v2's (4840 against 3112 columns on QuickDraw); it is now freed once binned, which v2 did
  not do. Peak process RSS at `qd_a` n = 60000 was 6.5 GB (v2: ~6 GB). At n ≤ 10000 a fit holds 1–1.8 GB; four such
  fits plus the other jobs filled the shared 14 GB cgroup once (§5).
- **Invariance in distribution only** for the booster (LightGBM samples columns by index), as in v2.
- **Prediction cost** per query is about v2's: the bank needs 2 · d · 3a ≈ 3.2e6 FLOPs (pooled sums) plus 71 a ≈ 5e4
  comparisons (v2: 3.7e6 with the pairs); ≤ 6000 trees at ~10 FLOPs; `gknn`'s scan of the n pooled training rows
  dominates as in v2.
