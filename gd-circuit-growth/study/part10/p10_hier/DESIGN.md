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

RESULTS_PLACEHOLDER

## 6. Weaknesses

WEAKNESS_PLACEHOLDER
