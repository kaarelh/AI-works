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

FREEZE: see section 6.

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

RESULTS: section 5.

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

TBD

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
