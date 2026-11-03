# What DFG v1.3's parts do: the ablations and the core DFG (Part 11, Q5 and Q5b)

Analysis of the 12 pre-registered ablations of **DFG v1.3 run alone** (PROTOCOL.md, Q5) and of the post-hoc **core DFG**
(PROTOCOL.md, addendum of 3 November 2026). The object is the frozen file `part10/hyb_portfolio3/dfg13.py` (md5
`69cabe5c50345cb24079198ed52b562f`) run as `DFG(readout="logit", **kw).fit` inside `harness.Permuted`
(`part11/eval_dfg.py`); every ablation changes constructor arguments only. Written 3 November 2026. Not yet checked by an
independent verifier.

Labels: **Numerical** = computed from a file named next to it; **Heuristic** = my reading. **Post hoc** marks everything
that was not fixed by the protocol: the core run itself, the paired null, the leave-one-in runs, the refits and every
grouping by family. Counts carry their denominators.

**Files** (this folder). [`ablations.py`](ablations.py) computes every number below from the result files and writes
[`ablations.json`](ablations.json) and [`tables/by_family.md`](tables/by_family.md); [`families.py`](families.py) assigns
the 138 targets to the atlas's nine groups; [`perm_null.py`](perm_null.py) makes the paired null
(`results/toy__dfg13-reperm__<suite>.json`); [`leavein.py`](leavein.py) makes the leave-one-in runs from the core
(`results/leavein/`); [`refit.py`](refit.py) refits single cells and reads the model, with the class that admitted every
feature (`results/refits.json`). The pre-registered results are `part11/results/toy__dfg13-<tag>-perm__<suite>.json`
(Q5) and `toy__dfg13-core-perm__<suite>.json` (Q5b); `part11/compare_dfg.py` summarises them in RESULTS.md (Q5, Q5b).

## Short answer

- **Three parts carry DFG's results on the ablation suites, and the sum blocks carry most** (Numerical, §1). Removing the
  sum blocks raises n\* by a mean of +0.91 doublings over the 59 of 65 targets both learn (31 clearly higher, 2 lower)
  and loses 3 targets (band11, h6_01, f7_08): +2.78 on the symmetric targets (6 of 12 still learned, 9 higher) and
  +1.54 on the mixtures (21; 16 higher). The tests scaled to the residual (`labelnoise`, +0.14; 15 higher, 5 lower) and
  the small-n machinery (`nosmalln`, +0.12; 10 higher, 0 lower) come next, on formulas, compositions and mixtures.
- **Four parts are removable on these 65 targets, one more nearly so** (Numerical, §1). A paired null, DFG alone refitted
  on the same training sets with another column order and other folds (post hoc), moves 1 of 65 targets beyond ±0.25
  on seed 0 and 3 of 65 on seeds 0–1 (mean |ratio| 0.012 and 0.038). The eigenvector seeds (`noeig`: 1 target), the
  extension and local classes (`nocomp`: 4, two of which the null also moves), the weighted blocks (`noweighted`: 1) and
  the logistic refinement (`lsread`: 3) stay within or near that band; so does the degree-4 search (`K3`) except on the
  one pure 4-parity, par4 (+3.01). The unpaired seed-vs-seed null of RESULTS.md moves 23 of 65 and overstates the noise
  of a paired comparison about tenfold.
- **The test or the search** (§2). For parities the test sets the cost exactly: THEORY.md's P2 with δ moved predicts the
  measured n\* change under both settings to within 0.02 (par3 strict +0.98 against +1.00; par4 strict +0.20 against
  +0.21, lenient −0.79 against −0.79; par2 0, decided by the forced variant at n = 16). For other character targets a
  stricter test delays the first fit by about one grid step in 8 of 25 (as the +0.54 to +0.86 doublings of n_glob
  predict), but the lenient test is not its mirror: it raises n\* on 8 of 25, through the small-n variant choice. For the
  33 symmetric and mixture targets both settings leave n\* in place (means +0.04 and +0.05; 7 and 5 moved): where n\*
  lies a doubling or more beyond the n at which the true block would pass its test (7 targets), strict moves n\* by at
  most 0.05, although it moves the block threshold by +0.20 to +0.30 doublings; the search, not the test, is binding.
  Halfspaces gain from a stricter test (−0.23): fewer partial characters and a later linear block let the exact block in.
- **Without the degree-4 search, par4 is found only when the block search stumbles on its 4 inputs** (Numerical, refits;
  §3): the folded block |±x1±x2±x3±x4| passes at 9 to 71 times its threshold at n = 512, 2048 and 4096 (seed 0) and is
  never proposed at 256, 1024, 8192 or 16384. On the other degree-4 targets (mux, andxor) blocks and composition give
  the same errors at every n. K also enters every test's union bound, so `K3` is also 0.29 nats more lenient everywhere.
- **The small-n machinery and the background are the atlas's counterfactuals, run** (Numerical, §4): `nosmalln`'s errors
  equal the atlas's always-default refits in 126 of 126 cells; `nobg`'s equal the fitted models without their
  background in 224 of 231 cells, and the other 7 are cells where the background changed the cross-validation's choice.
  The background helps at n = 16–32 and costs at 64–512, where most n\* lie (−0.10).
- **The residual scaling of the tests** (§5) is needed by the features admitted after the first round and by targets with
  biased labels (round 0's residual variance is 1 − ȳ²): with tests scaled to the labels, rand3 stops after its first
  character at n = 128 (error 0.317 against 0.049) and far9 admits nothing (0.181 against 0.006). Formulas +0.33,
  mixtures +0.15, halfspaces −0.17.
- **The core DFG (post hoc) keeps DFG's results except where a removed part has no substitute** (§6; to be completed
  below).

## 0. What was compared, and how

**Pairing** (PROTOCOL.md, Q5). An ablation runs on the training sets, column permutations and cross-validation folds of
DFG alone (all three come from the fit rng `default_rng([fn_seed(t), seed, n, 77])`), and its n\* is compared with DFG
alone's n\* from the same seeds of DFG alone's own runs: seeds 0 and 1 for `nosums`, `strict`, `lenient`, `noeig`,
`noblocks`, `nocomp` (and the core), seed 0 for the other six. Ratio = log2(n\*_ablation / n\*_DFG alone): negative when
the ablation needs less data, +inf when it never reaches 10% test error where DFG alone does. 'Lower' / 'higher' = beyond
∓0.25. Means are over the targets both reach. The five ablation suites hold 65 targets: `designed` (21), `dlsymdev` (8),
`dlfamdev`, `dlheld6`, `dlheld7` (12 each); only `dlheld7` is held out for v1.3.

**Two nulls.**
- *Unpaired* (RESULTS.md, Q5): DFG alone's seed 1 against its seed 0, i.e. other training sets. It moves 23 of 65
  targets (13 lower, 10 higher), seed 2 against 0 moves 26.
- *Paired* (post hoc; `perm_null.py`): DFG alone refitted on the same training sets and test sets, with the fit rng
  `default_rng([fn_seed(t), seed, n, 77, 1])`, so with another column order and other folds and nothing else. The
  column order is irrelevant to the target and to DFG's tests (THEORY.md P2); it can matter through tie-breaking, the
  block search's orders and the folds. This is the comparison an ablation's difference should be read against: a
  change that does nothing to DFG's decisions still moves its path somewhere. On the 65 targets (Numerical,
  `ablations.json` `nulls`): seed 0, mean +0.00, 1 moved (dlist5 +0.39), 10 of 65 ratios nonzero, mean |ratio| 0.012;
  seeds 0–1, mean −0.02, 3 moved (andxor −0.69, thrsum −0.66, h6_07 +0.40), 19 nonzero, mean |ratio| 0.038. The check
  that the loop is the evaluation's: with the original stream it reproduces 3 of 3 cells of the result file in test
  error and FLOPs.

**Families** (post hoc; `families.py`). Every target is assigned by hand, from its definition in `boolfuncs.py`, to one of
the atlas's nine groups (ATLAS.md §1), and to three coarse classes: *character targets* (parities, staircases, address /
data multiplexers, compositions of parities and majorities and polynomial thresholds, DNF / CNF / decision lists /
read-once formulas, random formulas; 71 of 138, 25 of the 65), *halfspaces* (majorities and thresholds of a weighted
sum, including the dictator, AND of 3 and an AND of two halfspaces; 13 and 7), and *symmetric and mixture targets* (a
function of one signed sum, alone or combined with a parity, a gate, a second sum or an inner term; 54 and 33). The
last class differs from the paper's 54 "sum-structured targets" by two in each direction: it adds sym8 and sym9, and
counts f7_01 and fd_01 (thresholds of an unsigned sum, as the atlas counts f7_01) as halfspaces.

**Refits** (`refit.py`). A refit is the evaluation's fit of that cell, made with `calib/dfg13_instr.py` (the frozen file
with read-only recorder calls added; CALIB.md §0), so that every feature carries the class that admitted it and its
round. All 31 refits quoted here reproduce their run's result file exactly in test error and FLOP count (asserted).

## 1. Which parts carry the results

Numerical (`ablations.json` `ablations`, `nulls`; the pooled rows equal RESULTS.md Q5). Cells: mean (lower / higher)
[both reach].

| run | seeds | all 65 | character (25) | halfspaces (7) | symmetric and mixtures (33) | newly never |
|---|---|---|---|---|---|---|
| `nosums` | 0, 1 | +0.91 (2/31) [59] | +0.16 (1/5) [25] | +0.05 (0/1) [7] | +1.82 (1/25) [27] | band11, h6_01, f7_08 |
| `strict` | 0, 1 | +0.06 (9/14) [62] | +0.17 (3/8) [25] | −0.23 (4/1) [7] | +0.04 (2/5) [30] | – |
| `lenient` | 0, 1 | +0.07 (5/13) [62] | +0.12 (2/8) [25] | −0.04 (2/1) [7] | +0.05 (1/4) [30] | – |
| `noeig` | 0, 1 | +0.03 (0/1) [62] | +0.00 (0/0) [25] | +0.00 (0/0) [7] | +0.05 (0/1) [30] | – |
| `noblocks` | 0, 1 | −0.02 (6/4) [62] | −0.03 (2/1) [25] | −0.19 (3/0) [7] | +0.02 (1/3) [30] | – |
| `nocomp` | 0, 1 | +0.00 (2/2) [62] | +0.02 (1/2) [25] | +0.00 (0/0) [7] | −0.02 (1/0) [30] | – |
| `noweighted` | 0 | +0.02 (0/1) [62] | +0.01 (0/0) [25] | +0.00 (0/0) [7] | +0.03 (0/1) [30] | – |
| `nosmalln` | 0 | +0.12 (0/10) [62] | +0.22 (0/8) [25] | −0.03 (0/0) [7] | +0.07 (0/2) [30] | – |
| `nobg` | 0 | −0.10 (7/3) [62] | −0.07 (3/2) [25] | −0.09 (1/0) [7] | −0.12 (3/1) [30] | – |
| `lsread` | 0 | −0.01 (2/1) [62] | −0.01 (2/1) [25] | +0.00 (0/0) [7] | −0.02 (0/0) [30] | – |
| `K3` | 0 | +0.02 (2/1) [62] | +0.08 (1/1) [25] | −0.05 (1/0) [7] | −0.01 (0/0) [30] | – |
| `labelnoise` | 0 | +0.14 (5/15) [62] | +0.23 (2/9) [25] | −0.17 (2/0) [7] | +0.14 (1/6) [30] | – |
| paired null | 0 | +0.00 (0/1) [62] | +0.00 (0/1) [25] | +0.00 (0/0) [7] | −0.00 (0/0) [30] | – |
| paired null | 0, 1 | −0.02 (2/1) [62] | −0.02 (1/0) [25] | +0.00 (0/0) [7] | −0.02 (1/1) [30] | – |
| unpaired null | 1 vs 0 | −0.04 (13/10) [62] | −0.02 (5/4) [25] | −0.17 (2/1) [7] | −0.04 (6/5) [30] | – |

By family (the atlas's groups; `tables/by_family.md`): `nosums` costs the symmetric targets +2.78 (0/9) [6 of 12] and the
mixtures +1.54 (1/16) [21], and less elsewhere: formulas +0.17 (0/3) [11], compositions +0.11 (1/1) [6], random formulas
+0.36 (0/1) [4], halfspaces +0.05 (0/1) [7], parities and the staircase 0. `labelnoise`: formulas +0.33 (1/6), the
staircase +0.70, mixtures +0.15 (1/5), random formulas +0.19, compositions +0.11, symmetric +0.10 (0/1), halfspaces
−0.17 (2/0), parities 0. `nosmalln`: compositions +0.38 (0/3), parities +0.26 (0/1), random formulas +0.22, formulas
+0.15 (0/3), symmetric +0.11, mixtures +0.05, halfspaces −0.03.

**Per seed** (the six two-seed ablations; `ablations.json` `seed_agreement`). `nosums` moves 27 targets up on both seeds
and none in opposite directions (12 on one seed only); its seed means are +0.91 and +0.97. For `strict` 4 targets move
the same way on both seeds, 1 in opposite directions, 24 on one seed only; for `lenient` 3, 1 and 22; for `noblocks` 3,
0 and 12; for `noeig` 1, 0 and 2; for `nocomp` 0, 0 and 5. Most of the δ-ablations' movements are single grid steps on
a single seed.

**What moved** (beyond ±0.25):
- `nosums` (33): all 25 symmetric and mixture targets that move, and rand3 +1.45, parmaj +1.00, h6_05 +0.73, fd_07 +0.56,
  dnf3 +0.28, maj9 +0.28, sparsepoly −0.33, thrsum −0.66. The character targets that need blocks are those the atlas
  found encoded by blocks before their characters are all detectable: parmaj's two folded blocks (ATLAS.md §1.5),
  clause and term blocks of formulas (§1.6), maj9's 9-input block (§1.4).
- `nosmalln` (10, all higher): majpar +0.97, mux +0.96, f7_02 +0.94, rand2 +0.90, par2 +0.79, dlist5 +0.39, sparsepoly
  +0.35, h6_03 +0.32, fd_04 +1.00, sym7 +1.00 (§4).
- `nobg` (10): f7_11 −2.17, h6_05 −1.41, fd_02 −0.94, fd_11 −0.90, rand0 −0.89, dict −0.64, andxor −0.38; higher fd_04
  +1.01, rand2 +0.91, fd_00 +0.51 (§4).
- `noblocks` (10): and3 −0.83, h6_09 −0.74, rand1 −0.49, maj3 −0.44, fd_01 −0.40, sparsepoly −0.35; higher f7_10 +0.76,
  h6_03 +0.54, thrsum +0.36, fd_11 +0.29.
- `nocomp` (4): thrsum −0.66, andxor −0.61, f7_02 +0.46, fd_00 +0.35; the paired null moves andxor (−0.69) and thrsum
  (−0.66) too.
- `noeig` and `noweighted` (1 each): h6_10, +1.08 and +0.94, the target v1.3's weighted blocks were designed for
  (PROTOCOL.md; paper Table 1).
- `lsread` (3): h6_05 −0.58, sparsepoly +0.32, h6_04 −0.31. `K3` (3): par4 +3.01, rand1 −1.06, f7_01 −0.32 (§3).

*Heuristic.* On the 65 targets of the ablation suites, DFG's results come from the sum blocks, with the residual scaling
of the tests and the small-n machinery as smaller contributors. The eigenvector seeds, the composition classes, the
weighted blocks, the logistic refinement and (but for one target) the degree-4 search can each be removed without a
change larger than an arbitrary perturbation of DFG's path produces. The δ-ablations, the background and the linear and
spectral blocks move many targets, in both directions. "Removable" holds for these suites' target mix, and for one part
at a time: the core DFG (§6) removes them together.

## 2. The test or the search

THEORY.md P2 (corrected by its verifier): a k-parity χ_S *passes round 0's global test* exactly when
n(1 − ȳ²) > n_thr(k, d) = 2c² ln(4K·C(d, k)/δ), on the degrees searched on all n rows (at d = 30: degrees 1–2 at every
grid n, degrees 3–4 from n = 32); whether the final model holds χ_S also depends on the forced variant at small n. The
strict and lenient ablations move ln(1/δ) by +6.91 and −2.20 nats, so n_thr moves by +13.8 and −4.4 rows: at d = 30,
from 22.30 / 26.77 / 30.59 (k = 2, 3, 4) to 36.12 / 40.58 / 44.40 (strict) and 17.91 / 22.37 / 26.19 (lenient)
(`ablations.json` `parity_P2`).

**Parities: the test sets the cost, exactly** (Numerical). The prediction is P2 per seed with each training set's own ȳ
(error 0 where the test passes; DFG alone's own error where it fails; at n = 16 DFG alone's measured cell, since n_thr >
16 for every δ here and the cross-validation's choice of the forced variant does not depend on δ):

| target | δ = 0.1: n\* (seeds 0, 1) | strict: predicted / measured ratio | lenient: predicted / measured ratio |
|---|---|---|---|
| par2 | 16.0 (forced variant at n = 16) | +0.00 / +0.00 | +0.00 / +0.00 |
| par3 | 27.8 (both seeds pass at 32) | +0.98 / +1.00 (both pass first at 64) | +0.00 / +0.00 |
| par4 | 48.2 (seed 0 passes at 64, seed 1 at 32) | +0.20 / +0.21 (both at 64) | −0.79 / −0.79 (both at 32) |

**Other character targets: one grid step, when the test binds** (Numerical). In round 0 a character's first-order
detection size n_glob = 2c² ln(4K·C(d, |S|)/δ)(1 − ŷ₀²)/ŷ_S² (THEORY.md P3b) is proportional to the log term, so
strict multiplies it by 1.81, 1.62, 1.52, 1.45 (+0.86, +0.70, +0.60, +0.54 doublings for degrees 1–4) and lenient by
0.74, 0.80, 0.84, 0.86 (−0.43, −0.32, −0.26, −0.22). On the 25 character targets:
- `strict` raises n\* beyond +0.25 on 8: par3 +1.00, stair5 +0.83, rand3 +0.72, rand2 +0.71, majpar +0.70, sparsepoly
  +0.65, h6_03 +0.54, h6_05 +0.30; class mean +0.17, 3 lower (f7_02 −0.72, andxor −0.57, mux −0.31). In the result
  files the first fit moves one grid step: stair5 has error 0 at n = 128 on both seeds with δ = 0.1 and 0.309 / 0.184
  with δ = 10⁻⁴; rand3 0.049 / 0.000 against 0.210 / 0.234; sparsepoly 0.129 / 0.023 at 64 / 128 (seed 0) against
  0.225 / 0.202.
- `lenient` is not the mirror image: 2 lower (par4 −0.79, rand2 −0.69), 8 higher (andxor +0.87, majpar +0.75, fd_00
  +0.62, mux +0.59, fd_07 +0.53, dlist5 +0.31, h6_05 +0.30, f7_02 +0.26), mean +0.12. The higher ones are first fitted
  at n = 32–64, where DFG alone's first fit is often the forced variant's, and the most δ-sensitive test is the linear
  block's: its threshold on 30 inputs is 51.2 at δ = 0.1, 33.8 at 0.9 and 81.7 at 10⁻⁴ (`linear_block_thr`). Refits
  of majpar at n = 64 (seed 0): with δ = 0.1 nothing passes in round 0, the forced variant adds χ[x1, x2] and then
  χ[x3, x4], and χ[x5, x6] passes its own test in round 2: error 0.067 (cross-validation 32 / 4 for forced). With
  δ = 0.9, χ[x1, x2] passes in round 0 and the linear block enters with 30 degree-1 characters, none of which is in
  majpar's Fourier support; nothing passes in round 1: error 0.341. With δ = 10⁻⁴ the forced pairs are the same, but
  χ[x5, x6] does not pass: error 0.269. andxor's seed-1 errors at n = 32 / 64 are 0.245 / 0.290 under lenient against
  0 / 0.
- The same machinery lowers n\* under strict on two formulas. f7_02 (a DNF of three terms; seed 1, n = 128): with
  δ = 0.1 the linear block enters in round 0 and the default variant is kept, error 0.202; with δ = 10⁻⁴ nothing passes,
  the forced variant guesses the blocks (x2 − x6 − x8) and (−x3 + x5 + x7), two of the DNF's terms, a third term's block
  (−x1 + x2 + x4 + x5) then passes its test, and the cross-validation takes the forced variant (35 / 17): error 0
  (refits).
- By n (65 targets, seed 0; `errs_by_n`): `strict` raises the mean test error most at n = 32 (+0.015; 9 cells higher,
  2 lower by more than 0.02) and 128 (+0.011; 11 / 4); `lenient` lowers it at 16–32 (−0.006, −0.012) and raises it at
  64 (+0.017; 9 higher, 0 lower) and 128 (+0.005; 9 / 3). Nothing differs by more than 0.005 in the mean from n = 1024 on.

**Halfspaces: a stricter test helps** (Numerical). `strict` −0.23 (4 lower: and3 −0.61, f7_01 −0.57, maj3 −0.45, fd_01
−0.40; 1 higher, dict +0.29); `noblocks` −0.19 (and3 −0.83, maj3 −0.44, fd_01 −0.40) and `labelnoise` −0.17 point the
same way. The linear block's threshold on 30 inputs is 51.2 at δ = 0.1, 81.7 at 10⁻⁴ and 33.8 at 0.9. Refit of f7_01
(seed 1; `refits.json`): with δ = 0.1 the model at n = 128 is χ[x7], admitted by its own test, and the linear block (30
degree-1 characters), error 0.091; with δ = 10⁻⁴ no character passes on its own in round 0, and the exact 13-input block
(x1 + … + x13) is admitted next to the linear block, error 0. A block is accepted only if it also passes on the
residual projected off the round's admitted characters (dfg13.py docstring), so a degree-1 character that passes
first takes part of the block's signal. At n = 64 the strict fit is the constant and the background (0.214 against
0.124).

**Symmetric and mixture targets: the search sets the cost** (Numerical; Part 10's block-power files
`part10/interp/results/toy_final/power/`, re-thresholded in `block_power`). Part 10 applied DFG's block test to each
target's true block, as if proposed in round 0, on the seed-0 training rows at every grid n (unfolded, folded,
modulated by the best character of the other relevant inputs; the weighted block for weighted targets). The statistic
does not depend on δ, so n_detect under each δ follows from the stored statistics with the threshold
m + 2√(mt) + 2t recomputed for t + ln(0.1/δ) (the modulated entries, stored as ratios only, rescaled with the unfolded
block's m: approximate). At the default n_detect the threshold moves by +0.20 to +0.30 doublings of n under strict
(median +0.26) and −0.07 to −0.11 under lenient, over the 33 targets.
- Both settings leave n\* in place on the class: means +0.04 (2 lower / 5 higher) and +0.05 (1 / 4) over 30 learned
  targets; dlsymdev's 8 move by at most 0.02 under strict.
- Under strict the true block's n_detect moves one grid step later on 8 of the 33 (h6_00, h6_07, h6_10, f7_00, f7_03,
  f7_05, f7_07, f7_11). Two are never learned; of the other 6, n\* moves beyond 0.25 on one (h6_07, +0.33) and by
  −0.11 to +0.02 on the rest.
- On the 7 targets whose n\* (seeds 0, 1) lies a doubling or more beyond n_detect (band11 2.60 doublings, f7_08 1.80,
  h6_01 1.75, h6_02 1.70, h6_06 1.63, f7_03 1.46, h6_08 1.19), strict changes n\* by at most 0.05 in absolute value
  (lenient: h6_08 −0.56, h6_01 −0.24, the rest within 0.02).
- On the other 23 learned targets n\* lies below n_detect (median −0.20 doublings over the 30): their 10% point is
  reached at the first grid point where the block passes or earlier, through characters (fd_08 51 against n_detect
  512, as Part 10 found for gates and linear parts) or the forced variant's block (sym7 at n = 64, below the test).
  There the grid cannot separate test and search: the strict threshold leaves n_detect on the same grid point for all
  but 5 of them.
- The sum-target movements under `strict` (f7_09 +0.56, h6_09 −0.53, fd_11 +0.46, fd_08 +0.43, h6_07 +0.33, fd_05
  −0.30, f7_10 +0.26) are, but for h6_07, on targets whose true block's n_detect does not move; fd_08, fd_11 and f7_10
  reach 10% error through characters before their block (n\* 51, 109, 88).

*Heuristic.* Part 10 read the data cost of a block as set by the search (TOY_INTERP.md: the true block passes at n = 128
for 43 of 54 targets, the exact structure appears a median of one doubling later). The δ-ablations agree: where n\*
lies beyond n_detect, a test one quarter-doubling stricter changes nothing, because the block is admitted far above its
threshold once the search proposes it (par4 under `K3`, §3: 9 to 71 times). For character targets the round-0 test is
the binding constraint whenever the first fit comes from it (parities exactly, staircases and small formulas within a
grid step); where the first fit comes from the forced variant, δ acts through the cross-validation instead, and its
sign is not predictable from the test alone.

## 3. The degree-4 search (`K3`)

`K3` = `{"K": 3, "K_hi": 3}`: the global search stops at degree 3 and the degree-5/6 subsample search is off. K also
enters every class's union bound (thresholds use ln(4K·N/δ)), so every test is 0.29 nats more lenient (δ effectively
0.133). Numerical: +0.02 pooled (2 lower / 1 higher) [62/65]; par4 +3.01, rand1 −1.06, f7_01 −0.32 (seed 0).

**par4** (refits, seed 0; `refits.json`, every refit equal to the result file). Errors by n under `K3`: 0.49–0.50 at
16–256, **0 at 512**, 0.499 at 1024, **0 at 2048 and 4096**, 0.495 at 8192, 0.500 at 16384. In the three fitted cells
the model is the folded block on the parity's four inputs, admitted in round 0 by an additive block search:
|−x1−x2−x3−x4| at 512 (statistic / threshold 9.0, share 0.61, with a spurious product of it), |x1−x2+x3+x4| at 2048
(34.5) and |x1−x2−x3+x4| at 4096 (70.9). A k-parity is a function of any signed sum of its k inputs, so one folded
block with three groups represents it exactly (THEORY.md P4a). In the four empty cells (256, 1024, 8192, 16384) the
best candidates of the round-0 block searches stand at 0.13–0.45 of their thresholds, nothing is admitted, and the model
is the constant and the background. With the degree-4 search, χ[x1, x2, x3, x4] passes its round-0 test at n = 64 on
both seeds (P2). *Heuristic:* the true block would pass its test at every n ≥ 64 (its statistic grows with n; 9 times
the threshold at 512), but the block search's seeds read degree-1 and degree-2 statistics (THEORY.md P4f), which are
zero for a parity of degree 4; whether the greedy growth and local refinement reach the 4-set is luck.

**mux and andxor** (degree-4 coefficient 0.75 and 0.5) have the same test error under `K3` as DFG alone at every n
(seed 0), with other models:
- mux at n = 64: the same model in both (forced variant, CV 22 / 3 and 22 / 4): a forced block (−x1−x2−x3+x4) and a
  forced χ[x4], error 0.0066. At 256: DFG alone holds χ[x1, x2, x3, x4] from the degree-4 test (round 0, share 0.51,
  the largest term), next to lower-degree characters (χ[x1, x2, x3] and χ[x3, x4] from the local class in round 1) and
  blocks; `K3` holds the blocks (−x1−x2−x3+x4) (round 0) and (x1+x2+x3 + 3·x4) (round 1) and χ[x1, x2, x3] from the
  two-input extension of χ[x1] (round 1), and no degree-4 character; error 0 in both.
- andxor at 256: DFG alone holds its exact expansion χ[x1, x2], χ[x3, x4], χ[x1, x2, x3, x4] (the last by the degree-4
  test); `K3` holds the two pair characters and the weighted block (x1 + x2 − 3·x3x4); error 0 in both.

**rand1** (−1.06): refit at n = 64. With K = 4, round 0 admits the linear block (30 degree-1 characters, one relevant)
and the forced variant then guesses χ[x4, x12, x17]: error 0.412. With K = 3, χ[x1] passes its own (0.29 nats more
lenient) test in round 0, so the linear block does not enter; the forced guess is χ[x1, x4, x6], the local class adds
χ[x4, x6] and a block (x3 − x5) follows: error 0. The difference is the union bound's K, not the degree-4 search.

*Heuristic.* The degree-4 search is redundant wherever a target's degree-4 characters share inputs with lower-degree
structure: blocks on the same inputs (a parity of k inputs is a function of their signed sum) and the composition
classes reach them. It is indispensable for a parity of degree 4 with no lower-degree footprint, which the ablation
suites contain once (par4); the core run (§6) adds rf17 (a 4-parity by its gates), poly4 and par5.

## 4. The small-n machinery and the background, against the atlas's counterfactuals

**`nosmalln`** = `{"small_n": false}`: at n ≤ 512 no forced variant and no cross-validation; the default variant is fitted
on all n rows with the whole budget. The atlas refitted the variant DFG did not choose, as DFG.fit's final fit (half the
budget; ATLAS.md §2.3, `results/cv/forced_vs_default.json`), on 21 targets the ablation suites share with the atlas. At
d = 30 the two can differ only in the degree-5/6 subsample sizes (THEORY.md P5). Numerical (`atlas_counterfactuals`):
`nosmalln`'s seed-0 test error equals the atlas's always-default error in **126 of 126** cells (n ≤ 512); on those cells
its mean error is 0.2345 against DFG alone's 0.2242 (higher in 5 cells, lower in 2). Over all 65 targets (seed 0) the
mean error rises by 0.012, 0.007, 0.022, 0.009 and 0.004 at n = 16, 32, 64, 128, 256 and by nothing from 512 on. n\*:
+0.12, 10 higher, none lower. Since `nosmalln` is the default variant, a cell where DFG alone's error is lower is one
where DFG alone kept the forced variant; the lost first fits are par2 and rand2 at n = 16, majpar at 32–64, mux and sym7
at 64, fd_04 at 128 and f7_02 at 256 (seed 0, result files), each recovered one grid step later. The atlas's mean over its 222 cells: DFG's choice 0.2257, always default 0.2319, always
forced 0.2256, the better of the two per cell 0.2111.

**`nobg`** = `{"background": false}`. The background is added after the weights are fitted, so a fitted model without it
is exactly DFG's prediction without it for the same variant (ATLAS.md §2.4, `err_no_bg`); the ablation can differ from
that only where the cross-validation's choice changes, since the fold fits lose their background too. Numerical:
`nobg`'s seed-0 error equals the atlas's `err_no_bg` in **224 of 231** cells (21 targets, every n). The other 7 are all
at n ≤ 128, and since the same variant without its background gives exactly `err_no_bg`, in each of them the
cross-validation chose the other variant. Refitted: f7_11 at n = 16, where DFG alone keeps the default variant
(held-out errors 6 / 3), the constant plus the background, error 0.301; without the background the default's held-out
errors rise to 13 and the forced variant wins (13 / 3): χ[x11] and χ[x8], error 0.077. By n (65 targets): the mean error rises by 0.015
and 0.016 at n = 16 and 32 (29 and 25 cells higher, 18 and 21 lower) and falls by 0.009, 0.002, 0.003 and 0.002 at
64, 128, 256 and 512 (16 / 8, 11 / 4, 6 / 1, 4 / 0 cells lower / higher). n\*: −0.10 (7 lower, 3 higher): f7_11 −2.17,
h6_05 −1.41, fd_02 −0.94, fd_11 −0.90, rand0 −0.89, dict −0.64, andxor −0.38; fd_04 +1.01, rand2 +0.91, fd_00 +0.51.

*Heuristic.* The background is the networks-inspired kernel part (dfg13.py docstring): at n = 16–32, where the model
holds nothing else, it is a Hebbian classifier and helps on targets with a strong degree-1 part (ATLAS.md §2.4); from
n = 64 on it adds the noise of 30 residual correlations to a model that already fits, and through the cross-validation it
makes the default variant look better than it is, so the forced variant's correct guesses are kept less often. Most n\*
lie at 64–512, so on balance it costs data.

## 5. Tests scaled to the residual (`labelnoise`)

`{"noise": "label"}` sets s = 1 in every threshold (dfg13.py, `_fit`), in place of the residual's rms: in round 0 the
residual is y − ȳ with variance 1 − ȳ², and after the first features fit it shrinks. (The subsampled searches keep the
subsample's own rms; the sum blocks' second test, on the residual projected off the round's characters, keeps its own
variance.) THEORY.md P3c: the composition classes and later-round global tests admit characters 1.4–3.7 doublings
(medians) below n_glob, mainly because the residual variance there is smaller (class medians 3.2–19.2 times).

Numerical: +0.14 (5 lower / 15 higher) [62/65]; character +0.23 (2/9), halfspaces −0.17 (2/0), symmetric and mixtures
+0.14 (1/6). By family: formulas +0.33 (1/6) [11], the staircase +0.70, random formulas +0.19, mixtures +0.15 (1/5),
compositions +0.11, symmetric +0.10, parities 0. By n: the mean error rises by 0.024 at n = 128 (18 cells higher, 2
lower) and 0.013 at 256 (11 / 0), and by at most 0.003 elsewhere. Moved: fd_11 +1.42, f7_02 +1.00, h6_07 +0.98, far9
+0.94, rand3 +0.81, majpar +0.80, fd_00 +0.71, stair5 +0.70, fd_07 +0.67, f7_06 +0.62, f7_10 +0.57, f7_04 +0.44,
f7_11 +0.40, thrsum +0.39, h6_03 +0.32; lower h6_08 −0.91, and3 −0.86, h6_04 −0.59, f7_01 −0.32, sparsepoly −0.27.

Refits (seed 0, n = 128):
- *rand3.* DFG alone: χ[x5, x6] in round 0 (s = 1.00), χ[x4, x5, x6] by the one-input extension in round 1 (s = 0.84),
  χ[x5] and χ[x4, x5] by the local class in round 2 (s = 0.77), modulated blocks in rounds 3–4; error 0.049. With
  s = 1: χ[x5, x6] in round 0, then nothing passes in round 1 and the fit stops; error 0.317.
- *far9* (|x1 + … + x9| ≥ 5, biased labels: round 0's s = 0.711). DFG alone: the folded block |x1 + … + x9| and a
  spectral feature in round 0, error 0.006. With s = 1 the thresholds are 1.4 times higher and nothing passes: the
  constant and the background, error 0.181.

*Heuristic.* The residual scaling is what makes DFG's growth greedy in the sense of its docstring: each round's tests are
calibrated to the noise left after the last round's fit, so weaker features pass once stronger ones are in. Its cost to
the n\* of these targets is modest (+0.14) because the features that bring most targets below 10% error are admitted in
round 0 (ORDER.md: at n = 512, 2048 and 16384 DFG admits every target character it will carry in a single round in 24,
30 and 32 of 33 fits of the Part 5 targets); it is larger for formulas and
staircases, whose later characters ride on the first ones, and for targets with biased labels. Halfspaces gain (and3,
f7_01), as under `strict`: a stricter round-0 test keeps partial characters out.
