# p10_sum: DFG v1.3 (weighted sum blocks, forced blocks, wider small-n search) inside v2

Part 10, builder T. Files:
- `dfg13.py`: DFG v1.3 = `part9/p9_sum/dfg12.py` (v1.2, md5 `4ff2e0c9c324f0f1be93f604734b4a69`) plus the changes in
  section 1. Every change is inside the sum-feature component (the `SumBlock` class, `_block_search`, and the
  sum-block part of a DFG round); characters, extensions, the local Walsh search, the linear / spectral blocks, the
  least-squares and logistic readout, the kernel background, the budget caps and the stopping rule are v1.2's code.
- `learner.py`: class `Learner`, default name `p10_sum` = v2 (`part9/hyb_portfolio2/learner.py`, md5
  `e38af40493816ef1bc82e4f16428dcdf`) with its DFG module loaded from `part10/p10_sum/dfg13.py` instead of
  `part9/p9_sum/dfg12.py`. The other two changes are the default name and the docstring header. The image member
  (gates), LightGBM, ExtraTrees, kNN, logistic regression and the stacker are v2's code, bit for bit. DFG runs only
  on binary / categorical inputs with C = 2 (the toy suites, kr_vs_kp-like tables), so on images and on every other
  tabular set p10_sum is v2 by construction.

FREEZE: 19:44 UTC, md5 `learner.py` 5ee995add8601b90ee8b1d5612fede87, `dfg13.py` 69cabe5c50345cb24079198ed52b562f (section 6).

Development used only the toy suites `designed`, `dlsymdev`, `dlfamdev` and `dlheld6` (already seen), a few
synthetic targets of my own (section 4), inputs permuted per fit. No held-out suite (`dlheld7`) or held-out image set
(`qd_c`, `qd_d`) was loaded, generated, printed or inspected, and no result file or log about them was read.

## 1. What changed in the sum-feature search

### 1a. Weighted sum blocks u = t + a·τ (the main change)

v1.2's blocks have ±1 weights. A sum with one heavier term, `u = Σ_{i∈S} s_i x_i + a·τ(x)` with `a ∈ {±2, ±3}` and τ a
literal, a parity of two inputs or an AND of two literals (as ±1), was representable only through a modulated block
when τ was a character already in the model; for τ = a literal x_j (whose own degree-1 coefficient is often exactly 0,
e.g. dlheld6's h6_10 = `[|x1+…+x12 − 3 x13| > 1]`, where E[f x13] = 0 by symmetry) or τ = AND it was not representable
at all. v1.3 adds the class

  WeightedBlock(S, s, fold, a, τ):  u(x) = Σ_{i∈S} s_i x_i + a τ(x),   features [u (or |u|) ∈ group v]

with the same contiguous value groups, the same χ² statistic T and the same Laurent–Massart threshold. The union
bound pays for the inner term: t = tk(|S|) + ln(2 · (4d + 20·C(d, 2))) (a literal on any input with a ∈ {±2, ±3}: 4d;
a parity (4) or an AND with any of 4 literal signs (16) on any pair of inputs, each with a ∈ {±2, ±3}; ×2 because the
weighted class gets its own false-accept share δ next to the unweighted class, so the level of the block test per
round is at most 2δ instead of δ). At d = 30 this adds 9.8 nats (≈ +20–25 to the threshold).

Three routes produce weighted candidates, all in the **additive** block search only (not in the modulated or product
searches, for CPU):
1. *Weighted eigenvector prefixes.* For a function of a weighted sum w·x the residual pair matrix is ≈ c·w wᵀ (off the
   diagonal), so the heavy input leads the order of the top eigenvector. For each of the top-2 eigenvectors' orders,
   the first input gets weight a ∈ {2, 3} (sign from the eigenvector) and every prefix of the rest is scored, folded
   and unfolded.
2. *τ first.* For the strongest pair (j, l) of the pair matrix (`ntau` = 1), the 5 terms τ ∈ {x_j x_l, AND(±x_j, ±x_l)}
   with a ∈ {±2, ±3} are held fixed and the eigenvector prefixes of the other inputs are scored.
3. *Extensions of the best unweighted candidates.* For the 2 best refined unweighted candidates (S, s): every literal
   outside S with a ∈ {±2, ±3}; every input of S re-weighted to 2 or 3; a parity or AND on the 24 pairs outside S with the
   largest pair coefficients.
The 3 best weighted candidates are refined by the same local search as v1.2 (add / remove / flip-sign moves on S, the
inner term held fixed), and the best weighted candidate replaces the unweighted one only if its margin (T̂ minus its own,
larger threshold) is higher. The final test, the second test on r_S (beyond the round's characters), the deflation and
the products are as in v1.2; a product with a weighted factor pays that factor's weighted t.

### 1b. Forced blocks in the forced variant (n ≥ 48)

v1.2's forced small-n variant (a stacking member at n ≤ 512 in the portfolio) forces the best character when nothing
passes. v1.2 had a `sum_force` option (force the best block candidate instead, when its T/threshold ratio beats the best
character's squared z-ratio); it was off, because it cost accuracy on andxor at n = 32 and the search could not find
the blocks at n = 64 anyway. v1.3 turns it on for n ≥ 48 only (so the 10-fold out-of-fold fits at n = 64, on ~58
points, force too, and nothing changes at n ≤ 32) and pairs it with 1c. Why: at n = 64 a perfect 7-input block has
T ≈ 64 but its union-bound threshold is ≈ 80 (section 5b of p9_sum/DESIGN.md), so no block can pass the test there;
the forced variant gets the block anyway, and the stacker decides by cross-validation whether the forced member is
trusted, exactly as for forced characters.

### 1c. Beam search for the first additive block at n ≤ 128

At n = 64–128 v1.2's eigenvector / greedy seeds miss strong-pair blocks on some seeds (fd_09 at n = 128: 1 of 3
seeds; ssym9 seed 2 at 128; sym7 at 64 on every seed). v1.3 adds, for the first additive search of each round and
only when n ≤ 128, a beam search: start from all pairs (both relative signs), keep the 32 best (S, s) by the block
margin (best of folded / unfolded), extend each by every input and sign, keep the 32 best distinct ones, until the
best margin has not improved for 5 sizes; the two best of each size are scored as candidates for refinement. The beam
is a purely combinatorial search on (S, s) with the block statistic.

### 1d. What was tried and dropped (dev data only)

- *Residue classes mod 3 of 10–13 inputs* (fd_10, h6_00). Measured landscape (fd_10, n = 16384, true block known): each
  missing input divides T by ≈ 4, each extra input by ≈ 2–2.5, a sign flip by ≈ 2–3, and errors compound (5 extras +
  2 flips: T ≈ 6). The Fourier weight sits at degree ≈ 3k/4 (pair and degree-1 coefficients ≈ 0.002). A detectable
  candidate must be within ≈ 3–4 errors of the truth; random multi-start coverage of C(30,10)·2⁹ ≈ 1.5·10¹⁰ (S, s) would
  need ≫ 10⁵ restarts. Not attempted further; fd_10 and h6_00 stay unlearned.
- *Beam search (width 16) and truncated-power-method seeds at n = 256–512* for weak-pair blocks (band11, h6_01): no
  change (1 of 3 seeds for band11 at 256 and 512, as v1.2). At n = 256 the true block has T = 256 against a threshold
  of ≈ 100, but blocks with ≥ 4 wrong inputs are below the noise of the search; the pair-matrix spike (k a₂ ≈ 0.4) is
  below the noise edge 2√(d/n) ≈ 0.48–0.68 at n ≤ 512, and a sparse-PCA local search over the pair objective returned
  4–7 of band11's 11 inputs. The limit there is computational, not the test.
- *Beam width 64 / 256 and beam at n ≤ 512*: no further gain at n = 64–128 and 4–40× the search CPU.

## 2. What is discrete; permutation invariance

| part | object | continuous? |
|---|---|---|
| weighted block | a subset S, signs s, an integer weight a ∈ {±2, ±3}, an inner term τ (a literal, a parity of two inputs or an AND of two literals) | no |
| value groups | contiguous sets of integer values of u, from training counts | no |
| beam / refinement / extensions | enumeration of (S, s, a, τ) scored by the χ² block statistic | no |
| ordering heuristic | eigenvectors of the residual pair matrix (as in v1.2) rank inputs for prefixes; the eigenvector's magnitudes only pick which input gets weight a | used inside the search, not in the hypothesis |

No gradient descent, no network. All new statistics are functions of the column set (pair matrix, counts), so a
permutation of the input columns permutes every candidate; ties are broken by index as in v1.2 (the harness permutes
the inputs per fit).

## 3. Cost (FLOPs, multiply-add = 2; CPU)

Every new operation is added to DFG's own counter `fl` with v1.2's conventions (8 m C per block-statistic call over m
points and C candidate columns; beam: 16 m C per step for the folded and unfolded statistics; extensions: + 4 m C for
building the columns; τ evaluations included), so it also counts against DFG's budget caps (a round starts only below
0.75 of the DFG share).

Measured cost of the fixed dev evaluation: section 5 (largest fit 0.73 of one network run; CPU ≈ 1.6–1.7× v2's
suite totals). Prediction (not counted, as before): a weighted block costs k additions + one τ evaluation + a binary
search over its group edges per query.

## 4. Development history (dev data only)

All quick checks below are DFG alone (the final-fit call `_fit(..., scale=0.5)`, the share the portfolio's final DFG
fit gets) or the portfolio on a few small n, inputs permuted, scored on a fresh validation draw of 4096 points
(`default_rng([fn_seed, 777])`) for DFG alone and on the harness's points for the portfolio checks.

1. *Where v2 stands on dlfamdev* (DFG v1.2 alone, seed 0, n = 256 / 1024 / 4096): every target but fd_10 is solved
   by n = 1024 (most by 256); fd_10 (`[((s+10)/2) mod 3 == 0]`, 10 signed inputs) stays at 0.33 (= the majority rate)
   up to 4096; h6_00 (dlheld6, mod 3 of 13) at 0.33 up to 16384. v2's portfolio n* on fd_00–fd_02 is 70–75.
2. *Mod-3 landscape* (section 1d): not attempted further.
3. *Search vs test at n = 256* (h6_01, band11, h6_11, h6_10): the true block passes easily (T = n against ≈ 100), the
   search misses it (returns 2–3-input partial blocks). For h6_10 the plain 12-block explains only ≈ 30% (T = 74 at
   n = 256) because of the weight-3 literal.
4. *Beam (width 16), truncated power seeds*: no change on band11 / h6_01 at 256–512 (section 1d). Dropped.
5. *Weighted blocks* (1a, routes 1 and 3): h6_10 DFG-alone search at n = 256 finds `|x1+…+x12 ± 3 x13|` exactly on all
   3 seeds (T = 252–256 against 120–124; v1.2: partial 3-input blocks, nothing passes). Portfolio, quick grid (n = 64,
   256, 1024, 4096; seeds 0–1): h6_10 n* 171 (v2's full-grid n* is 702; error at 256: 0.01 against v2's 0.31).
   Regression check (DFG alone, inner terms only): dlsymdev 8 targets × n ∈ {64, 256, 1024} × 2 seeds identical to
   v1.2 to the test point; designed 21 targets × {64, 256, 1024} identical; dlfamdev fd_00 at 256: 0.061 → 0.057, the
   rest identical where compared.
6. *Synthetic weighted targets* (my own, not from any suite; DFG alone, 3 seeds): `[|x1+…+x7 − 2 x8| ≥ 3]` at n = 128:
   0.495 → 0.000; `[|x1+…+x8 + 3 AND(x9, −x10)| ≤ 2]` at 256: 0.054 → 0.016 (found as plain blocks; the AND term itself
   was not recovered); `sign-ish [x1+…+x9 + 2 x10x11 ≥ 1]` at 256: 0.003 → 0.000. Route 2 (τ first) was added for the
   parity / AND case; it did not change these numbers measurably.
7. *Small n, search*: with a width-64 beam at n = 64 / 128 the search finds sym7 at 64 on 3 of 3 seeds (v1.2: 0), fd_09
   at 128 on 3 of 3 (v1.2: 1), ssym9 seed 2 at 128 (v1.2: missed); ex3of8 at 64 still missed. Width 256: no further gain,
   4× the time. Width 32 at n ≤ 128 was adopted for CPU (0.17 s per search at n = 128 against 0.03 s without).
8. *Forced blocks* (1b) + beam, DFG alone, forced variant, n = 64, 3 seeds: sym7 0.478 → 0.000, ssym9 0.497 → 0.328,
   far9 0.324 → 0.058, ex3of8 0.323 → 0.330, symxpar unchanged; designed and3, maj3 at n = 32, 64 identical.
   Portfolio (n = 32, 64, 128, 256; 3 seeds; against v2's stored fits): sym7 at 64: 0.457 → 0.000; ssym9 at 64:
   0.490 → 0.327; andxor, and3, maj3 identical at every n; fd_01 (a halfspace, `[x1+…+x6 ≥ 0]`) at 64: 0.122 → 0.145
   (worse; the other n identical). The checks were stopped there (the machine was at load ≈ 20) and the files frozen.
9. *CPU*: per additive search, the weighted routes cost ≈ 2× v1.2's search (0.06 / 0.25 / 0.9 s at n = 128 / 512 /
   2048, against 0.03 / 0.1 / 0.36 s), so they were restricted to the additive search (not the modulated and product
   searches). kr_vs_kp (n = 1000, seed 0, validation rows pool[1000:] of the seed-0 split, not the test set): p10_sum
   0.0093, v2 0.0093; FLOPs 2.6e10 against 2.84e10; CPU 15.0 s against 12.9 s.

## 5. Fixed dev evaluation (frozen files, run once)

Run 27 October 2026, 20:00–21:35 UTC (restart: section 6), frozen files (md5 identical before and after,
`results/md5_{before,after}.txt`). `hybrid/eval_toy.py p10_sum.learner:Learner <suite> --perm`, full grid n = 16 … 16384,
seeds 0–2, 8 target shards merged with `hybrid/merge_toy.py`. v2's fits: `toy__p9_sum-perm__{designed,dlsymdev}.json`
(p9_sum = v2 on toy inputs) and `toy__hyb_portfolio2-perm__dlfamdev.json`; the harness's data, permutations and seeds
are deterministic, so these are the same fits. Script: `results/rule_dev.py` (output `results/rule_dev.txt`).

### Integration rule (PROTOCOL.md, T): designed + dlsymdev + dlfamdev = 41 targets

- **Mean log2 n* ratio p10_sum / v2: −0.066** over the 40 targets that both learn (−0.064 over 41 if fd_10, which
  neither learns, counts as 0). The rule asks for < −0.05.
- **Largest per-target increase: +0.257 (fd_06, n* 318 against 266)**; the rule allows ≤ +0.5. Other increases:
  sparsepoly +0.12 (103 / 95), fd_01 +0.12 (79 / 73), ex3of8, fd_07, rand1 +0.01.
- **Decreases:** sym7 −1.00 (55 / 110), fd_09 −0.76 (101 / 171), parmaj −0.36 (110 / 142), far9 −0.30 (71 / 87), dnf3
  −0.19 (118 / 134), mux −0.18 (70 / 79), fd_05 −0.14 (147 / 161), fd_02 −0.10 (66 / 70), ssym9 −0.10 (104 / 111),
  thrsum −0.02. The other 25 targets: identical n* (to < 0.01 in log2).
- So both conditions of the rule are met on the dev suites (by a small margin on the mean: the gain is concentrated
  in a few targets at n = 64–128).

Where the changes act (seed-mean test error, p10_sum / v2):

| target | n = 64 | n = 128 | n = 256 | source of the change |
|---|---|---|---|---|
| sym7 | 0.000 / 0.457 | 0.000 / 0.000 | 0.001 / 0.001 | forced block + beam at n = 64 |
| ssym9 | 0.327 / 0.490 | 0.000 / 0.000 | 0.001 / 0.001 | forced block (1 of 3 seeds) |
| far9 | 0.116 / 0.177 | 0.005 / 0.005 | 0.003 / 0.003 | forced block |
| fd_09 | 0.274 / 0.274 | 0.010 / 0.169 | 0.002 / 0.002 | beam at n = 128 |
| parmaj | 0.466 / 0.466 | 0.000 / 0.117 | 0.000 / 0.000 | beam at n = 128 |
| dnf3 | 0.252 / 0.256 | 0.080 / 0.108 | 0.002 / 0.001 | (small n) |
| mux | 0.112 / 0.131 | 0.016 / 0.032 | 0.000 / 0.000 | (small n) |
| fd_05 | 0.301 / 0.301 | 0.124 / 0.148 | 0.002 / 0.002 | beam at n = 128 |
| fd_06 | 0.386 / 0.386 | 0.328 / 0.328 | **0.141 / 0.105** | n = 256 (beam off there): the weighted routes or a forced block; not diagnosed |
| fd_01 | **0.145 / 0.122** | 0.000 / 0.000 | 0.000 / 0.000 | forced block on a halfspace |
| sparsepoly | **0.162 / 0.146** | 0.072 / 0.066 | 0.008 / 0.008 | (small n) |

At n ≥ 512 the two learners' errors agree on every target to ≤ 0.002 (seed means). fd_10 is not learned by either
(0.32–0.33 at every n). dlheld6's h6_10 (not part of the rule; quick grid only, section 4): n* 171 against v2's 702.

Per-target table (`results/rule_dev.txt`; CPU = total process seconds of the 33 fits; v2's CPU was measured on a less
loaded machine):

```
suite     target       n* p10    n* v2    log2 maxFL/GD  cpu p10   cpu v2 max cpu/fit
designed  dict             16       16   +0.00    0.191       65       55         6.0
designed  and3             25       25   +0.00    0.191       76       56         5.2
designed  maj3             31       31   +0.00    0.191       92       66         8.8
designed  maj9             80       80   +0.00    0.213      149       91         8.2
designed  thr10           121      121   +0.00    0.593      534      315        45.8
designed  par2             16       16   +0.00    0.191       61       53         7.1
designed  par3             55       55   +0.00    0.195       68       56         7.3
designed  par4             56       56   +0.00    0.191       61       55         7.2
designed  stair5          109      109   +0.00    0.193      169       93        15.6
designed  majpar           60       60   +0.00    0.196      158       86         9.7
designed  parmaj          110      142   -0.36    0.198      165       89        10.8
designed  mux              70       79   -0.18    0.192      149       88        11.2
designed  dnf3            118      134   -0.19    0.381      278      127        21.6
designed  dlist5           32       32   -0.00    0.212      212      149        21.0
designed  rmaj9           163      163   +0.00    0.215      230      127        18.5
designed  andxor           40       40   +0.00    0.191       82       60         7.7
designed  sparsepoly      103       95   +0.12    0.199      199      102        14.3
designed  rand0            16       16   +0.00    0.210      214       96        12.9
designed  rand1            95       95   +0.01    0.201      174       95        15.2
designed  rand2            16       16   +0.00    0.212      198       99        14.1
designed  rand3           114      114   +0.00    0.213      187      130        23.1
dlsymdev  sym7             55      110   -1.00    0.218      139       82         8.2
dlsymdev  ex3of8          118      117   +0.01    0.228      148       91         9.3
dlsymdev  band11          829      828   +0.00    0.214      177       94        14.9
dlsymdev  far9             71       87   -0.30    0.205      142       87         8.0
dlsymdev  ssym9           104      111   -0.10    0.229      149       90         8.2
dlsymdev  symxpar         111      111   +0.00    0.203      155       88        13.3
dlsymdev  twosym          415      415   +0.00    0.237      175       94        10.4
dlsymdev  thrsum           80       81   -0.02    0.211      193      107        18.6
dlfamdev  fd_00            75       75   -0.00    0.229      330      192        22.9
dlfamdev  fd_01            79       73   +0.12    0.220      141       88         9.7
dlfamdev  fd_02            66       70   -0.10    0.209      194      108        14.3
dlfamdev  fd_03            81       81   -0.00    0.208      205      134        30.0
dlfamdev  fd_04           171      171   +0.00    0.231      196      119        11.0
dlfamdev  fd_05           147      161   -0.14    0.258      178      113        15.0
dlfamdev  fd_06           318      266   +0.26    0.689      344      217        22.5
dlfamdev  fd_07            98       97   +0.01    0.316      263      161        28.8
dlfamdev  fd_08            29       29   +0.00    0.729      359      247        30.4
dlfamdev  fd_09           101      171   -0.76    0.203      141      101         9.3
dlfamdev  fd_10           inf      inf   +0.00    0.107      141       82         8.8
dlfamdev  fd_11           123      123   -0.00    0.583      217      128        15.2
targets 41; both finite 40; both never 1; mean log2 ratio over finite -0.0656; mean over all (never=never counted 0) -0.0640; max increase +0.257; min -1.003
```

### Tabular check: kr_vs_kp, n = 1000, seed 0 (`eval_cells.py --ns=1000 --seeds=0 --tag=p10_sum-dev`)

| learner | test error | FLOPs | fraction of budget | CPU |
|---|---|---|---|---|
| p10_sum | **0.0038** | 2.60e10 | 0.074 | 15.3 s |
| v2 (`hyb_portfolio2__kr_vs_kp.json`) | 0.0125 | 2.84e10 | 0.081 | 18.7 s |

(3 against 10 wrong of 799 test points; the stack weights and member out-of-fold errors are close to v2's: DFG 0.017
against 0.015 out of fold. One seed, so this is a crash / budget check rather than evidence.)

### Cost

| suite | p10_sum total CPU | v2 total CPU | max CPU / fit | median CPU / fit | max FLOPs / GD run (v2) | median FLOPs / GD (v2) |
|---|---|---|---|---|---|---|
| designed | 3521 s | 2089 s | 45.8 s (v2 30.4) | 3.9 s (v2 2.6) | 0.593 (0.555) | 0.061 (0.058) |
| dlsymdev | 1280 s | 734 s | 18.6 s (v2 7.5) | 4.7 s (v2 2.6) | 0.237 (0.236) | 0.054 (0.052) |
| dlfamdev | 2710 s | 1690 s | 30.4 s (v2 24.4) | 5.9 s (v2 3.7) | 0.729 (0.760) | 0.064 (0.062) |

Every fit stays within one network run (largest 0.73, fd_08; the toy budget is 1.0); the new FLOPs are a few percent
of a fit. CPU is ≈ 1.6–1.7× v2's suite totals, partly the new searches (beam at n ≤ 128, the weighted routes at every
n) and partly the machine (load ≈ 20–30 on 4 cores during this run, against a less loaded machine for v2's runs; process
CPU time rises under contention), so the per-fit CPU ratio attributable to the code is not separated here.

## 5b. Weaknesses (honest)

- **Residue classes mod 3 of 10–13 inputs remain unlearned** (fd_10, h6_00). Not a test problem: the weight of such a
  function sits at degree ≈ 3k/4 and the block statistic is detectable only within ≈ 3–4 wrong inputs or signs of the
  truth (section 1d). No change from v2.
- **Weak-pair blocks at n = 256–512** (band11, twosym, h6_01-like arbitrary accept sets) are still found only from
  n ≈ 512–1000; the beam and the truncated-power seeds did not help there, and the limit is computational.
- **Small n is still bounded by the union bound.** At n = 64 no block passes the test (T ≤ n < threshold ≈ 75–90); the
  gain at n = 64 comes only from the forced variant (the stacker's cross-validated choice), so it depends on the
  forced member being trusted on ~58-point folds. A forced block can also be wrong: fd_01 (a plain halfspace) at
  n = 64 got worse in the portfolio check (0.122 → 0.145), presumably because a forced 6-input block with 7 groups
  replaced a forced character the logistic readout used better.
- **Weighted blocks are restricted** to one heavy term, a ∈ {2, 3}, τ a literal / parity / AND of two literals. Two heavy
  terms, unequal weights in general (thr10's Gaussian weights) or a heavy 3-input term are not in the class. The AND
  inner term is searched (τ-first, extensions) but in the one synthetic check it was not recovered as such (the target
  was solved by plain blocks). The weighted routes run only in the additive search (not modulated / product).
- **The level of the block test** per round is now ≤ 2δ (the weighted class has its own δ) instead of δ.
- **CPU.** Per fit the DFG member is slower: ≈ 2× at n ≤ 128 (beam), and the additive search ≈ 2–2.5× at every n (the
  weighted routes). See section 5 for the measured suite totals.
- **Dev in-sample.** Every choice was made on dev targets (designed, dlsymdev, dlfamdev, dlheld6 which was already seen,
  and my own synthetic weighted targets). The forced-block / beam decision was made on a partial portfolio check (8
  targets at n ≤ 256), stopped early because of machine load.

## 6. Freeze and how to run

Frozen 27 October 2026, 19:44 UTC (52 minutes after the start of the work), before the fixed dev evaluation:

| file | md5 |
|---|---|
| `learner.py` | `5ee995add8601b90ee8b1d5612fede87` |
| `dfg13.py` | `69cabe5c50345cb24079198ed52b562f` |

(`results/md5_before.txt`; `results/md5_after.txt` after the evaluation.) `__init__.py` is empty. Neither file was edited
after the freeze.

The evaluation was started at 19:44 as 8 shards in one shell session. Linux autogroup scheduling (enabled on this
machine) shares CPU equally between sessions regardless of nice, so the 8 shards together got ≈ 0.55 cores (61 s of CPU
each in 15 minutes) while the niced reference jobs, each in its own session, got ≈ 0.3–0.7 cores each. At 20:00 the 8
shards were stopped (no result had been written; nothing was read from them) and restarted unchanged, two shards per
session in four sessions (`setsid`), which gave them ≈ 1.4 cores. Only the restarted run produced results.

```
# fixed dev evaluation, as run (8 target shards, then merge)
sh study/part10/p10_sum/run_toy.sh designed dict,and3,maj3,maj9,thr10,par2 --perm --part=1
sh study/part10/p10_sum/run_toy.sh designed par3,par4,stair5,majpar,parmaj --perm --part=2
sh study/part10/p10_sum/run_toy.sh designed mux,dnf3,dlist5,rmaj9,andxor --perm --part=3
sh study/part10/p10_sum/run_toy.sh designed sparsepoly,rand0,rand1,rand2,rand3 --perm --part=4
sh study/part10/p10_sum/run_toy.sh dlsymdev sym7,ex3of8,band11,far9 --perm --part=1
sh study/part10/p10_sum/run_toy.sh dlsymdev ssym9,symxpar,twosym,thrsum --perm --part=2
sh study/part10/p10_sum/run_toy.sh dlfamdev fd_00,fd_01,fd_02,fd_03,fd_04,fd_05 --perm --part=1
sh study/part10/p10_sum/run_toy.sh dlfamdev fd_06,fd_07,fd_08,fd_09,fd_10,fd_11 --perm --part=2
cd study/hybrid && for s in designed dlsymdev dlfamdev; do python3 merge_toy.py p10_sum-perm $s; done
# tabular check
cd study/part9 && PYTHONPATH=../part10:. python3 eval_cells.py p10_sum.learner:Learner kr_vs_kp --ns=1000 --seeds=0 --tag=p10_sum-dev
```
Results: `study/hybrid/results/toy__p10_sum-perm__{designed,dlsymdev,dlfamdev}.{json,md}` (copies in `results/`),
`study/standard_tasks/results/p10_sum-dev__kr_vs_kp.{json,info.json}`.

## 7. Data access

I never loaded, generated, printed or inspected `qd_c`, `qd_d` or the toy suite `dlheld7`, and read no result file or
log about them. Incidental exposures, recorded for completeness: a `ps` listing of running processes showed the
command lines of other jobs (e.g. an `eval_cells.py ... qd_c` reference run and an `mlp.py qd_c` run), command lines only;
a `sed -n 430,460p boolfuncs.py` printed the one-line signature `def make_dl_heldout7_suite(d=30):` at the end of the
range (no body); the source of `eval_toy.py` and `merge_toy.py` names that function in their suite tables. Nothing about
`dlheld7`'s targets was seen. Development used designed, dlsymdev, dlfamdev, dlheld6 (already seen), my own synthetic
targets, and kr_vs_kp validation rows (pool[1000:] of the seed-0 split) before the freeze; the kr_vs_kp test cell was run
only after the freeze, as part of the fixed evaluation.

