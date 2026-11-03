# What DFG v1.3 alone learns: a structure atlas (Part 11, Q7)

## Verification

An independent agent verified this report against its tooling, stored fits, tables and Part 10's files
([`VERIFY_ATLAS.md`](VERIFY_ATLAS.md), [`VERIFY_ATLAS.json`](VERIFY_ATLAS.json)). It recomputed every count with its own
scripts, refitted 11 cells and 6 non-chosen variants through its own code path (all equal to the stored and merged
values), ran its own Walsh transforms and oracle fits, and found the stored specs (37/37) and categories (407/407) equal
to the current code's. It confirmed 39 of the 61 claims it checked, among them the identity check (517 + 66 cells), the
cross-validation counterfactual (18 of 222; 89 of 140; 0.2257 / 0.2319 / 0.2256 / 0.2111), the background-removal
counts (85 / 54 / 268), the 8 exact Fourier models at 16384, the 133 / 9 / 6 dictionary–readout split, the
spurious-product and duplicate-block counts, the 141 of 255 equal errors against Part 10 and the 15 equal n_struct,
and it found none of the corrections of Part 10's verifier reintroduced; 22 claims needed correcting. I checked every
correction against the stored files (and refitted f7_11 at n = 128) and applied all 22; none is declined, but items
5, 9 and 12 make the verifier's replacement more exact (5: one n fewer; 9: the exact value instead of an
approximation; 12: one share rounded from the stored value), as item 31 does for one share it quoted. Items 23–34
address the omissions it listed and its notes on confirmed claims; item 35 lists a few precision edits of my own from
the same re-check. Every changed or added number is recomputed from the stored files by
[`atlas_recheck.py`](atlas_recheck.py) (output: [`atlas_recheck.txt`](atlas_recheck.txt), with the f7_11 refit).
Tables regenerated with `atlas_make.py`: only `tables/atlas.md` changes (rf06's n\*_3 is now labelled a 2-seed mean);
the figures do not change (a re-run on the final files reproduces every table byte for byte, and both figures apart
from the PDF creation date).

Corrections applied (old → new; V*k* = the verifier's claim *k*):

1. (V4) Header: the 37 targets "cover every target family of the 11 suites" → come "from 9 of the 11 suites, covering
   the main families; §4 lists the sub-families with no atlas target" (also in the comment on the target list in
   `atlas_truth.py`).
2. (V2) §0.1: "about 23:33 UTC" → "about 23:30 UTC" (file time 23:30:33).
3. (V7) §0: "every representation is verified on all 2^k assignments" → character representations are; block
   representations only as "f is a function of the block statistics" (accept sets not checked; vacuous for the
   multiplexer address blocks); the spectral pair is not verified.
4. (V8) §0: character-group shares "exact for distinct characters, which are orthogonal" → approximate (orthogonal in
   expectation); the tables' character-group values are absolute sds, not fractions of the output sd (also in the
   docstring of `atlas_make.py`, the tables' key).
5. (V13) §1.2 heuristic: staircases "as characters only" → "mostly as characters (relevant blocks appear at stair5
   n = 256, 1024, 2048 and stair6 n ≥ 512)"; the verifier's "256–2048" without 512, where stair5 has no block.
6. (V15) §1.3 heuristic: "first fits one with blocks (one modulated block per data bit, partial)" → "mux11 first fits
   partial modulated address blocks (n = 512); mux6 goes through additive and weighted relevant blocks".
7. (V17) §1.4: the degree-1 representation "is complete from n = 64" → "complete at n = 64 (thrint loses it at 512)".
8. (V18) §1.4: thrint "reaches 0 at n = 1024 with weighted blocks" → "reaches 0 at n = 512 with a product of the
   {x4…x9} and {x1,x2,x3} blocks and two modulated folded blocks (all R); the weighted blocks come later (+2x1 from
   1024, +3x1 from 4096)".
9. (V20) §1.4: degree-1 characters "(group share 0.72–0.85)" → "0.76–0.91 of the output sd (0.72–0.85 as the tables'
   unnormalised root-sum-square)". The verifier's "0.75–0.93 of the output sd" is that root-sum-square divided by the
   output sd; the sd of the summed contribution itself (§0's group share), recomputed from the stored weights on the
   4096 test inputs, is 0.855, 0.757, 0.906, 0.797 of the output sd (maj9, thrint, thr30, f7_01).
10. (V23) §1.5: "majxor all 25 at 4096" → "at 2048".
11. (V24) §1.5: "the folded blocks stay at shares ≈ 0.2" → "majxor keeps both (≈ 0.2); parmaj keeps only |t_A + t_B|
    (0.17)".
12. (V25) §1.5: "the product block and the spectral pair never appear" → "the product block never appears; the spectral
    pair appears once, at majxor n = 512 (shares 0.33 and 0.23, with 0.895 and 0.863 of |u|² on its inputs); at 256
    and 1024 the spectral features carry 0.73–0.84 and count as spurious". The verifier gives the shares as 0.33 / 0.24
    and the mass as 86–90%; the stored shares are 0.3266 and 0.2347, so the second rounds to 0.23, and the mass is
    quoted as the stored fractions (the verifier's own values).
13. (V28) §1.6: cnf3's inner term holds "the third clause's literals" → "two of the first clause's literals (negated)".
14. (V31) §1.8: sym9 "at 4096–16384 the block plus 36 degree-2 characters" → "the block, its 36 degree-2 characters and
    up to 28 degree-4 characters (plus the spurious product at 8192–16384)".
15. (V37) Short answer: symand's "s ± 3 AND(¬x7,¬x8)" → "s − 3·AND(¬x7,¬x8) and s + 2·AND(¬x7,¬x8)"; also f7_03's
    "s1 ± 3 x11" → "s1 − 3 x11 and s2 − 3 x11", as the verifier's evidence for this claim gives it (also §1.9).
16. (V39) Short answer, §2.1: "the two largest gaps (andxor, majpar at 64) are caused by the kernel background" → "the
    largest gaps are andxor@64 (0.092) and thrint@256 (0.071), then majpar@64 (0.067); andxor's and majpar's vanish
    without the background, thrint's is a readout gap".
17. (V44) Short answer, §2.2: removing the spurious terms changes the first-fit error "by at most 0.036" → "0.035"
    (145/4096).
18. (V45) Short answer: "spurious terms are rare once the target is fitted" → "rare at n = 16384 (1 of 37 targets above
    0.1); at the first fit 13 of 35 are above 0.1".
19. (V49) Short answer, §2.3: below the structure "78 [hold] a true character" → "87".
20. (V57) Short answer, §3: the small-n differences are "mostly through the variant", and v3 had no final DFG fit "in 4
    cells" → about half are the variant; most of the rest are cells where v3's stacker gave DFG no weight, so Part 10
    summarised an out-of-fold fit (45 of the 114 differing cells).
21. (V59) §3: "for 4 more, alone has it after v3's run had stopped (rf06, majmaj5, cnf3, hrf0)" → for 3 (rf06; cnf3,
    hrf0); majmaj5 has it at 2048, the last n of v3's run, where v3's member (same error 0) lacks one of the three
    classes.
22. (V60) Short answer, §3: the mod-3 failures are "the same: constant only" → like v3's member at n ≥ 1024, alone is
    constant + background; alone is constant at every n, v3's member was not at small n.

Points declined: none.

Omissions and notes on confirmed claims, now in the text:

23. f7_09, the other parity mixture, does not have its partner character first (§1.9).
24. Non-monotone cells: stair5@256, thrint@512, dlist8@256 and @16384, f7_07 and f7_09 (complete only at 256), f7_03
    (only at 512), and the test-error rises with n (§2.5; also §1.2, §1.6).
25. The oracle's features exclude the kernel background: in 27 of the 133 dictionary-limited cells DFG's own error is
    more than 0.05 below the oracle's (short answer, §2.1).
26. §3: 45 of the 114 differing cells are against v3 out-of-fold fits; against a final v3 member alone is lower in 41 of
    69; maj9@64 is against an out-of-fold fit; the v3 members at f7_06@64 and mux6@128 are not "one or two characters".
27. mux6 never holds a modulated address block (§1.3, with item 6).
28. "Complete" for f7_03, f7_11 and symand checks only the branch or class blocks, not the selector modulation or the
    gate characters (§1.9).
29. n\*_3 of rf06 is a 2-seed mean (§0, `tables/atlas.md`).
30. majmaj5 also holds degree-7 characters from 2048 on (§1.5); sym9's degree-4 characters (item 14).
31. More spurious blocks at the first n of a block: f7_06@128, f7_03@256, symand@128, rf06@128–256 (§2.2; f7_03's
    share is 0.3248, so 0.32, not the verifier's 0.33).
32. Notes on confirmed claims: par5's held-out errors are high, not "at chance" (21 of 64 at n = 64; §1.1); mux11's "17
    characters" are 17 of its 64 Fourier characters, 41 characters in all (§1.3); thr30 has one weighted block and a
    product containing it (§1.4); dlist8's halfspace form is lost at 256 and 16384, and f7_06's block form holds its
    block only inside a relevant product (§1.6); rf06's exact fit is at 256, hrf0's at 128 (§1.7); f7_11's errors at
    128 lie almost only (63 of 64, confirmed by a refit) where branch 2 is selected and |s₂| = 6 (§1.9).
33. Further notes: the linear block also entered at 64 in thr30, which has no irrelevant input, and h5s7's S-lin 0.035
    at 16384 is an upper bound (§2.2); DFG's choice equals always-forced to 3 decimals (0.2257 against 0.2256) and is
    0.0146 above the better variant (short answer); at f7_05@16 the background helps (§2.4); h6_10's inner term is a
    literal (§4); stair5 also holds a spurious product at 1024 (S 0.03; §1.2); f7_00, which has no partner, holds a
    weighted block whose inner term takes two inputs of its other sum (short answer, §1.9); v3's h6_00 member at 64 is
    an out-of-fold fit (§3); par4's 10-fold fits at 32 have 28–29 rows, not 29 (§2.3); that every file was refitted
    after the late representations cannot be told from the files (§4).
34. Two additions, recomputed from the stored files: in all 27 cells of item 25, DFG without the background is no longer
    more than 0.05 below the oracle; majxor's two spectral features at 1024 have cos 0.87 with 1_A ± 1_B, just below the
    0.9 needed for a target term (§1.5, §2.1).
35. Precision edits of my own, from the same re-check: thrint's model at 512 also holds (x1+x2+x3) (0.10), and thr30's
    at 16384 three small modulated blocks (shares ≤ 0.01) besides its weighted block and the product (§1.4); §2.2 says
    which relevant inputs the other spurious blocks hold and adds rf06's spurious product at 256 (0.09); §3 says that
    the 45 out-of-fold comparisons are 45 of the 114 differing cells (not of the 72 where alone is lower) and that the
    64 cells that differ through the variant are at n ≤ 512 (40 of them at n ≤ 64); the two short-answer bullets on
    mod 3 and on v3 now carry their label (Numerical).

---

Descriptive analysis of the Part 11 object, **DFG v1.3 run alone** (`part10/hyb_portfolio3/dfg13.py`, md5
`69cabe5c50345cb24079198ed52b562f`, as `DFG(readout="logit")` inside `harness.Permuted`; PROTOCOL.md), on 37 Boolean
toy targets from 9 of the 11 suites, covering the main target families (§4 lists the sub-families with no atlas
target). Seed 0 throughout; one training set per (target, n).
Nothing here is an ablation or a test of a design: it says what the fitted models contain, not why DFG does well or
badly. Verified independently: see Verification above.

Every number is computed from a file named next to it. **Numerical** marks what the files show; **Heuristic** marks
my reading of it. Shares, categories and "complete" are defined in §0.

**Files.** Tooling: [`dfg_hooks.py`](dfg_hooks.py) (instrumented fits), [`atlas_truth.py`](atlas_truth.py) (each
target's own representation in DFG's dictionary), [`atlas_run.py`](atlas_run.py) (the fits and their description),
[`identity_run.py`](identity_run.py), [`identity_dscale.py`](identity_dscale.py) (identity samples), [`cv_counterfactual.py`](cv_counterfactual.py) (the variant
DFG did not choose), [`atlas_make.py`](atlas_make.py) (tables and figures), [`atlas_recheck.py`](atlas_recheck.py)
(the numbers changed or added after verification). Fits: `results/atlas/<suite>__<target>.json`
(407 cells, every term of every model), `results/identity/`, `results/cv/`. Tables: [`tables/atlas_summary.md`](tables/atlas_summary.md)
(one row per target), [`tables/atlas.md`](tables/atlas.md) (the selected n of every target, one model line each),
[`tables/atlas_cells.csv`](tables/atlas_cells.csv) (all 407 cells), [`tables/atlas_targets.csv`](tables/atlas_targets.csv),
[`tables/atlas.json`](tables/atlas.json), [`tables/atlas_family.json`](tables/atlas_family.json),
[`tables/atlas_below.csv`](tables/atlas_below.csv), [`tables/atlas_quirks.json`](tables/atlas_quirks.json),
[`tables/p10_compare.md`](tables/p10_compare.md) / `.csv`, [`tables/identity.md`](tables/identity.md) / `.json`.
Figures: [`figures/fig_atlas_grid.pdf`](figures/fig_atlas_grid.pdf), [`figures/fig_atlas_p10.pdf`](figures/fig_atlas_p10.pdf).

## Short answer

- **The refits are the evaluation's fits** (Numerical, `tables/identity.md`). 517 seed-0 cells (47 targets, all 11
  suites, every n of the grid) were refitted with the internals recorded; test error and FLOP count equal the merged
  evaluation files `part11/results/toy__dfg13-perm__<suite>.json` bit for bit in all 517, and in the 66 cells of a
  6-target sample of the d = 15, 60, 120 runs (`designed_d<d>`).
- **DFG alone learns each target in the dictionary form that is cheapest to detect, and with more data moves to the
  target's exact Fourier expansion when that is small** (Numerical, §1; Heuristic, the summary). Parities are one
  character from the first n that fits them (3/3). Staircases, majorities of parities, multiplexers and small random
  formulas are mostly their characters (multiplexers and random formulas after transient block encodings of a branch
  or a term; the staircases also hold relevant blocks at some n, stair6 at every n ≥ 512); at n = 16384, 8 of the 37
  models are exactly the target's Fourier expansion with nothing else but the constant and the kernel background
  (par2, par4, par5, stair5, andxor, mux6, mux11, hrf0). Symmetric targets and signed sums are their sum block (sym9
  at 128, band11 at 1024, f7_08 at 512; h5s7 at 2048 as a product of two factors that partition its class), and
  halfspaces are degree-1 characters plus, where one exists, a block.
- **Mixtures are represented in forms the targets' definitions do not suggest** (Numerical, §1.9). The parity of two
  majorities is first two folded blocks over the union, |t_A + t_B| and |t_A − t_B| (parmaj at 128, majxor at 256;
  sign(|t_A+t_B|² − |t_A−t_B|²) = sign(t_A t_B)); a parity, gate or selector partner ends up as the inner term of a
  weighted block next to characters (at n = 16384 in 5 of the 6 mixtures without a true weighted block: s ± 3 x13,
  s ± 3 x11x12, s − 3·AND(¬x7,¬x8) and s + 2·AND(¬x7,¬x8), s1 − 3 x11 and s2 − 3 x11, s2 ± 3 x11; the sixth,
  f7_00, has no partner, and its weighted block takes two inputs of its other sum as inner term). At n = 16384
  only 1 of the 7 signed-sum mixtures (f7_10) still holds its compact representation, while all 7 have test error 0
  and 5 of them span R² ≥ 0.998.
- **Where DFG is above 10% error, the dictionary is what is missing, not the readout** (Numerical, §2.1): in 133 of
  the 148 cells with test error > 0.1 the learned features cannot express the target (the best logistic weights on
  them, fitted on test inputs, err > 0.1; these features exclude the kernel background, which in 27 of the 133 cells
  brings DFG's own error more than 0.05 below the oracle's); in 9 cells they can (oracle error ≤ 0.02) and only DFG's
  own weights fall short. Those 9 are threshold-like targets at n = 64–128 just after the linear block entered (maj9,
  thrint, thr30, f7_01, dlist8, f7_10). At the first n with error ≤ 0.1, DFG's error is within 0.0005 of the oracle's
  for the median target; the largest gaps are andxor at 64 (0.092) and thrint at 256 (0.071), then majpar at 64
  (0.067): andxor's and majpar's vanish without the kernel background (§2.4), thrint's is a readout gap (0.071 with or
  without the background, oracle error 0).
- **Spurious terms are rare at n = 16384 (1 of 37 targets has a spurious share above 0.1), less so at the first fit
  (13 of 35), and of three kinds** (Numerical, §2.2): the irrelevant degree-1 characters of the linear block (share
  0.40–0.78 at n = 64 in the 8 targets with irrelevant inputs whose linear block entered there; at most 0.035 at
  n = 16384), products of a true block with a factor of irrelevant inputs (9 cells, 4 targets, shares 0.07–0.41, test
  error ≤ 0.0083), and blocks contaminated by irrelevant inputs at the first n where a block appears. At the first n
  with test error ≤ 0.1 the spurious share is ≤ 0.1 for 22 of 35 targets (median 0.01, largest 0.36, dlist8); at
  16384 for 36 of 37 (largest 0.21, a spurious product of sym9).
- **The two residue classes mod 3 are never learned** (Numerical, §1.8, §3): f7_05 and h6_00 are the constant (plus the kernel background)
  at every n, test error = the minority rate (0.3245, 0.3430) from n = 2048 on. Part 10 found the same failure for
  v3's member, constant + background at every n ≥ 1024; at smaller n v3's member was not constant-only (§3).
- **DFG's own cross-validation keeps the default variant** in 204 of the 222 cells at n ≤ 512 and chooses the forced
  one in 18 (Numerical, §2.3). Refitting the variant it did not choose on the same rows: the two differ in test error
  in 140 cells; the forced one would have been better in 48 of the 204 default cells (par4 at 32: 0 instead of 0.488)
  and the choice made is better in 89 of the 140. Its mean test error over the 222 cells, 0.2257, equals that of
  always taking the forced variant to 3 decimals (0.2256) and is 0.0146 above the better of the two in each cell
  (0.2111). Below the n at which a compact representation is complete, 108 of 198 models are the constant alone.
- **Against v3's DFG member** (Numerical; Part 10, same targets and rows; §3): the DFG test error is identical in 141 of the 255
  common cells, in all 15 cells at n ≥ 4096 and in 28 of 32 at n = 1024–2048. At n ≤ 64 about half of the 80
  differing cells differ through the variant (40: v3's stacker kept the forced member, alone's paired test the
  default; the stacker kept the forced member in 51 of its 110 cells at n ≤ 64, DFG alone's paired test in 7 of 111),
  and the forced member's terms are often true ones (rf06 at 16: 0.032 against alone's 0.280); most of the rest
  (36) are cells where the stacker gave DFG no weight, so that Part 10 summarised an out-of-fold fit (45 of all 114
  differing cells). Part 10's exact-structure size n_struct is the same for all 15 targets where both have one.

## 0. What was measured, and how

**The fits** (`dfg_hooks.fit_toy_dfg(suite, target, n, seed, kw)`). For target t, seed s and size n: the training rows
of `harness.train_data`, the rng `default_rng([fn_seed(t), s, n, 77])` from which `Permuted` draws the column order pi
before DFG sees `X[:, pi]`, the 4096 test inputs of `harness.test_data`, the learner from `eval_dfg.make_learner`
(md5 checked at every load) and its constructor arguments. `DFG._fit` of the freshly loaded module is wrapped for the
duration of one fit, nothing else changes, and every call is recorded: at n ≤ 512 the out-of-fold fits of the
cross-validation (10 folds at n ≤ 64, else 5, for each variant), then the final fit on all n rows, which is the model
that predicts (the function asserts that the recorded model reproduces the prediction and that it saw `X[:, pi]`).
Recorded: the variant the cross-validation chose (default or forced) and its held-out error counts [default, forced],
the final fit's round log (residual rms, accepted characters, accepted block moves), features, readout weights, sum
blocks and kernel background, its FLOPs and training error. Single-threaded BLAS, as the evaluation queue runs.

**The model as terms** (`dfg_hooks.model_terms`), in original coordinates x1 … x30: the constant; each character
χ_S; each spectral feature (u·x)² − |u|² (support: |u_i| > 0.1 max|u|); each sum block with all its level indicators
as one term (set, signs, fold |t|, modulator χ_M, inner term a·τ, product factors, level weights); the kernel
background (one Hebbian step on the final residual). A term's **share** is the standard deviation of its
contribution to the model's output over the 4096 test inputs (an absolute sd); a group's share is that of the summed
contribution of its terms, over that of the whole output (a fraction: the category shares T / R / S, S-lin and
background of the tables). (Parts that partly cancel can each exceed 1. For groups of characters the model
descriptions in the tables give the square root of the sum of the terms' squared shares: an approximation to the sd of
their sum, since distinct characters are orthogonal in expectation but not exactly on the 4096 test inputs, and an
absolute sd, not a fraction of the output's sd.)

**The target's own representation** (`atlas_truth.spec`), derived from the definition in `boolfuncs.py` (and for the
heldout6-family suites from the expression tree of `part9/heldout6/suite.py`, read from the target's closure). DFG
predicts sign(Σ w_t φ_t(x)), so a target is exactly representable when a short list of dictionary features has a
linear combination with the target's sign. The atlas records, per target, the compact representations that exist:
a polynomial threshold function of a few characters (parity, staircase, majority of parities, halfspace, DNF / CNF /
decision list by the standard constructions), the exact Fourier expansion (multiplexers, random and read-once
formulas), and sum blocks on the target's signed-sum classes (additive, modulated by χ_P, weighted u = t + a·τ, or
a product; AND / OR / MAJ of block functions and literals are signs of sums of additive features). Character
representations (the polynomial threshold functions and Fourier expansions) are verified on all 2^k assignments of
the k relevant inputs (thr30, k = 30, is not enumerated). Block representations are checked only as "f is a function
of the block statistics and the coupling inputs": the check does not test the accept sets, and it is vacuous for the
multiplexer address blocks, whose statistics and modulators determine every relevant input (f7_06's
block-plus-characters form is checked this way only). The spectral pair (parmaj, majxor) is not verified. Also:
the exact Fourier coefficients (Walsh transform over the same 2^k inputs) and Part 10's signed-symmetry classes.

**Term categories** (`atlas_run.classify`):
- **T, target term**: a character in the target's Fourier support (f̂(S) ≠ 0) or in one of its compact
  representations; a sum block every factor of which has a true block's input set and signs (up to a global flip;
  folded only if the true accept set is symmetric under t → −t), or a product whose factors partition a true block;
  a spectral feature within cos ≥ 0.9 of 1_A ± 1_B (parmaj, majxor). `~` marks a coupled block: the class is exact
  but the block also carries an inner term or modulator on relevant inputs that the truth does not have (e.g. a
  multiplexer branch with the selector as inner literal).
- **R, relevant non-target term**: every input it reads is relevant but it is not a target term (characters with
  f̂(S) = 0, partial or wrong-sign blocks, products with a non-exact factor, spectral features with ≥ 90% of |u|² on
  relevant inputs).
- **S, spurious**: it reads an irrelevant input. **S-lin**: irrelevant degree-1 characters that entered with the
  linear block (which adds every input not yet in the model; identified as degree-1 characters absent from the round
  log's lists of individually accepted characters).

A compact representation is **complete** when all its characters are present, or every true block is a factor of a
sum term with the true statistic (the true inner term for a weighted target and no inner term otherwise; the true
modulator for a modulated target), or a product's factors partition it (for f7_03, f7_11 and symand, whose
specifications give the blocks no modulator or gate characters, only the blocks are checked; §1.9). Also per cell:
the test error with only the target terms (`err_T_only`) and without the spurious terms (`err_no_S`); the Fourier
weight of the characters present; and what the learned feature set can express whatever DFG's weights: the held-out
R² of f on its span, and the **oracle error**, the test error of a lightly regularised logistic fit of f on the same
features (fitted on 2048 of the test inputs, scored on the other 2048; the kernel background is not among these
features, §2.1).

**Which cells.** Seed 0 on the whole grid n = 16 … 16384 for all 37 targets (407 cells; the tables pick the grid point
just below and the first one at test error ≤ 0.1, the one nearest 4·n\*_0, and 16384; 256, 1024, 4096 and 16384 where
the error never reaches 0.1). n\*_0 = seed-0 10% point (log-interpolated, `harness.nstar`); n\*_3 = the same on the
3-seed mean of the merged evaluation file (for rf06 a 2-seed mean: the random suite was run with seeds 0 and 1).

### 0.1 Identity check

(Numerical, `tables/identity.md`, `tables/identity.json`.) Every refitted cell is compared with the merged evaluation
file of its suite, seed-0 column: the atlas cells (37 targets × 11 n) and an identity sample of 10 further targets
(`identity_run.py`: dlheld2 maj21, sym8, xmaj; dlfamdev fd_09, fd_10; random rf11; dlsymdev sym7; dlheld4 symxor;
dlheld5 h5t0; dlheld6 h6_10), every n; and for the d-scaling runs (`identity_dscale.py`) two designed targets at each
of d = 15 (maj9, mux), 60 (majpar, stair5) and 120 (par3, mux), every n, seed 0.

| suite | targets refitted (of) | cells compared | test error equal | FLOPs equal |
|---|---|---|---|---|
| designed | 7 (21) | 77 | 77 | 77 |
| random | 2 (20) | 22 | 22 | 22 |
| dlheld | 8 (12) | 88 | 88 | 88 |
| dlheld2 | 3 (7) | 33 | 33 | 33 |
| dlheld3 | 5 (10) | 55 | 55 | 55 |
| dlsymdev | 2 (8) | 22 | 22 | 22 |
| dlheld4 | 2 (12) | 22 | 22 | 22 |
| dlheld5 | 2 (12) | 22 | 22 | 22 |
| dlheld6 | 2 (12) | 22 | 22 | 22 |
| dlfamdev | 2 (12) | 22 | 22 | 22 |
| dlheld7 | 12 (12) | 132 | 132 | 132 |
| **all 11 suites** | **47 (138)** | **517** | **517** | **517** |
| designed_d15 | 2 (7) | 22 | 22 | 22 |
| designed_d60 | 2 (7) | 22 | 22 | 22 |
| designed_d120 | 2 (4) | 22 | 22 | 22 |

All 11 merged files (and the three d-scaling files) existed when the tables were made (the last of the 11, `random`,
landed at about 23:30 UTC). Equal FLOP
counts (to the last bit of a float sum over the fit's searches) are a strong fingerprint of the same code path; the
comparison is of test error and FLOPs, not of the models themselves, which the evaluation does not store.

## 1. The families

The per-target rows behind each paragraph are in [`tables/atlas_summary.md`](tables/atlas_summary.md) (the first n with
test error ≤ 0.1 and n = 16384) and [`tables/atlas.md`](tables/atlas.md) (the selected n, with the round log in
`tables/atlas.json`). "first fit" = the first grid n with test error ≤ 0.1. [`figures/fig_atlas_grid.pdf`](figures/fig_atlas_grid.pdf)
shows all 407 cells.

### 1.1 Parities (par2, par4, par5; degrees 2, 4, 5)

*Representation:* the single character χ_S.
*Numerical:* from the first fit on (n = 16 for par2, 64 for par4 and par5) every model is the constant plus exactly
that character with share 0.98–1.00, at every n to 16384 (size 2: no other term, no block, spurious share 0). Before
it the models are the constant and the background (default variant). par2 at n = 16 needs the forced variant (CV
held-out errors 7 default / 0 forced): at n = 16 no character passes the union-bound test. par5 is found at n = 64 by
the final fit's subsampled degree-5 search; the cross-validation folds skip that search (dfg13.py docstring), so their
held-out errors are high and nearly equal in both variants (21 / 21 of the 64 held-out rows at n = 64, 117 / 114 of
256 at 256) and the cross-validation cannot see what the final fit will find.
*Heuristic:* for parities the dictionary is the target class; DFG either has the character or nothing.

### 1.2 Staircases (stair5, stair6)

*Representation:* the prefix characters x1, x1x2, … in a sign readout (5 or 6 characters; stair6 with a constant).
*Numerical:* the compact representation is complete at the first fit, with error 0 (stair5 at n = 128, forced
variant, CV 47 / 4; stair6 at 256), plus one extra Fourier character each (χ[x1,x3,x5]; χ[x2,x4,x6]); no blocks, no
spurious terms. With more data the rest of the Fourier expansion is filled in: at 16384 stair5's model is exactly its
16 Fourier characters (size 17), stair6's 57 of its 63 non-constant characters plus two relevant blocks. stair6 loses its
degree-6 prefix character from n = 512 on (error ≤ 0.0007 throughout); stair5 loses its degree-5 prefix character at
n = 256 only (regained at 512). After the first fit the models also hold relevant blocks: stair5 at 256 (R 0.22),
1024 and 2048 (R ≤ 0.10; at 1024 also a spurious product, (x5+x13) × (x2−x3−x4 + 3x1), S 0.03), stair6 at every
n ≥ 512 (R 0.21–0.29).
*Heuristic:* staircases are learned mostly as characters (relevant blocks appear at stair5 n = 256, 1024, 2048 and
stair6 n ≥ 512): first the prefix terms, each detectable on its own residual, then the remaining Fourier terms as the
residual shrinks.

### 1.3 Multiplexers with address and data bits (mux6, mux11)

*Representation:* the exact Fourier expansion (16 and 64 characters, degree ≤ 3 and ≤ 4), or Σ_d x_d·[address = a_d]:
one block on the address bits per data bit, with the address's sign pattern, modulated by that data bit.
*Numerical:* at the first fit the models mix the two: mux6 at n = 256 (forced; error 0.002) has 10 of its 16
characters and two relevant blocks on two address bits and one data bit, (x1+x2−x3) and (x1+x2−x6), with S-lin 0.16;
mux11 at n = 512 (error 0) has 4 of its 8 modulated address blocks, e.g. χ[x5]·(−x1−x2+x3), next to weighted blocks
on the address and two data bits (x1+x2+x3+x11 − 3x4) (R, 0.43) and 17 of its 64 Fourier characters (41 characters
in all, 19 of them irrelevant degree-1 characters from the linear block, S-lin 0.02). mux6 never holds a modulated
address block (its blocks are additive at 256 and weighted, (x1+x5 − 3·AND(¬x2,¬x3)), at 512). From n = 1024 (mux6)
and 4096 (mux11) on, the models are the complete Fourier expansion and nothing else (n = 16384: sizes 17 and 65).
*Heuristic:* DFG has two exact dictionaries for a multiplexer. Before the characters take over, mux11 first fits
partial modulated address blocks (n = 512: 4 of the 8, one per data bit), while mux6 goes through additive and
weighted relevant blocks; with more data the characters (coefficients ±1/4 and ±1/8) all pass their tests and take
over.

### 1.4 Majorities and halfspaces (maj9, thrint, thr30, f7_01)

*Representation:* degree-1 characters with the target's weights in the sign readout; for maj9 and f7_01 (s ≤ 1 on 13
inputs) also one block on all relevant inputs.
*Numerical:* in all four the linear block enters at n = 64 and puts all 30 degree-1 characters in the model, so the
degree-1 representation is complete at n = 64 (thrint loses it at 512, with 6 of 9, and has it again from 1024) and
the oracle error there is ≤ 0.007; but DFG's own error at n = 64 is 0.17–0.20 and the 17–21 irrelevant degree-1
characters have S-lin share 0.45–0.56 (thr30 has no irrelevant input). The error falls when a block arrives: maj9's (x1+…+x9) at n = 128 (error 0, S-lin 0.01), f7_01's 13-input block
at 256 (error 0). thrint has no single exact block; it reaches 0 at n = 512 with a product of the {x4…x9} and
{x1,x2,x3} blocks, (x4+…+x9) × (x1+x2+x3) (0.27), and two modulated folded blocks, χ[x3]·|−x2+x4+…+x9| (0.24) and
χ[x2]·|−x3+x4+…+x9| (0.22), next to (x1+x2+x3) (0.10), all R; the weighted blocks that put the heavy input in the
inner term, (x2+…+x9 + 2x1) (from 1024) and (x2+x3−x4−…−x9 + 3x1) (from 4096), come later (R). thr30 (Gaussian
weights on all 30 inputs) is never fitted exactly: 0.009 error at 16384, with 59 characters and a weighted block
(x4+x5−x7−… + 3x3), a ±1 quantisation of w with its largest weight as inner literal (R, 0.10; also a factor of a
product, 0.03), beside three small modulated blocks (shares ≤ 0.01). At 16384 the leading terms are the degree-1
characters (their summed contribution has 0.76–0.91 of the output's sd; the tables' unnormalised root-sum-square
values are 0.72–0.85), the block (maj9 0.29, f7_01 0.29) and, for f7_01, a spectral feature on its inputs (0.28).
*Heuristic:* for threshold functions DFG's dictionary is complete almost at once and what remains is to learn the
weights; the logistic readout of 30 noisy degree-1 coefficients does that slowly, one block whose levels encode the
threshold does it at once.

### 1.5 Compositions (majpar, majpar5, parmaj, majxor, majmaj5, andxor)

*Representations:* majpar, majpar5: the 3 or 5 pair characters in the sign readout; parmaj (MAJ3 xor MAJ3), majxor
(MAJ5 xor MAJ5): the product block of the two majorities, the 9 or 25 cross-pair characters (sign(t_A t_B)), the
spectral pair (u₊·x)² − (u₋·x)², or two folded blocks |t_A + t_B|, |t_A − t_B|; majmaj5: three additive 5-input blocks
(sign(g₁ + g₂ + g₃)); andxor: its 3-character Fourier expansion.
*Numerical:*
- majpar, majpar5: the pair characters, complete at the first fit (n = 64, forced, error 0.067; n = 256, error
  0.011); at 16384 the same characters (shares 0.40–0.55) plus one relevant weighted or product block.
- parmaj, majxor: first fitted (parmaj at 128, forced, error 0; majxor at 256, error 0.0005) by the two folded
  blocks over the union, shares 0.56–0.77, and next to nothing else (parmaj: degree-1 characters of share ≤ 0.003;
  majxor: a partly spurious spectral feature, 0.09). With more data the cross-pair characters come in: parmaj has all 9 at
  1024 (with its 6 degree-4 characters; 15 of its 16 Fourier characters at 16384), majxor all 25 at 2048. majxor keeps
  both folded blocks (shares 0.21–0.24 from 2048 on); parmaj keeps only |t_A + t_B| (0.17) from 1024 on, so its
  folded-pair representation is incomplete from there. The product block never appears; the spectral pair appears
  once, at majxor n = 512 (two spectral features with cos 0.94 and 0.91 to 1_A + 1_B and 1_A − 1_B and opposite
  weights, shares 0.33 and 0.23, with 0.895 and 0.863 of |u|² on its inputs; error 0.0081). At 256 and 1024 majxor's
  spectral features carry only 0.73–0.84 of |u|² on its inputs and count as spurious (at 1024 the two have cos 0.87
  with 1_A ± 1_B, just below the 0.9 needed for a target term).
- majmaj5: no compact representation is complete at any n. At the first fit (n = 512, error 0.023) the model has
  4-input pieces of a majority modulated by its fifth input, χ[x7]·(x6+x8+x9+x10) (R, 0.40); at 1024–16384 one or
  two of the three 5-blocks at a time, blocks over unions of majorities, and degree-1, 3 and 5 characters (degree 7
  too from 2048 on); error 0.0007 at 1024 and 0 from 2048, with 256 features at 16384 (DFG's cap, max_feats = 256).
- andxor: the two pair characters at n = 64 (forced, error 0.092), a folded block |−x1−x2+x3+x4| at 128 (R; error 0),
  the full expansion (3 characters, size 4) from 256 on.
*Heuristic:* compositions of parities are their characters; a parity of two majorities is first a pair of folded
blocks — the block analogue of the spectral pair the quadratic block was built for — and then its degree-2
characters; the nested majority is fitted to error 0 without ever holding its compact form.

### 1.6 DNF, CNF, decision lists, read-once formulas (cnf3, f7_02, dlist8, f7_04, f7_06)

*Representations:* cnf3 = sign(c₁ + c₂ + c₃ − 2) and f7_02 = sign(Σ T_i + 2): the characters inside each clause or
term (21 and 27), or one additive block per clause / term on its literals; dlist8: a halfspace in its 8 literals
(weights halving); f7_04 (rules of 1–2 literals): 11 characters of degree ≤ 2; f7_06 = OR(AND of 5 literals,
AND(OR(¬x6,x7),x8)): a block on the 5 literals plus the 7 characters of the second term, or the 255-character
Fourier expansion.
*Numerical:* at the first fit the models are characters of degree 1–3 plus blocks that encode a clause, a term or a
rule: cnf3 at 256 (forced; error 0.004) has one of its three clause blocks exactly, (−x7+x8−x9), a second clause's
block with two of the first clause's literals (negated) as inner term, (−x4+x5+x6 − 3·AND(¬x1,¬x2)) (T~, share
0.49), and 10 of its 21 clause characters; f7_02 at 256
(forced; error 0) has the block of its 4-literal term (−x1+x2+x4+x5) and 14 of 27 term characters; f7_06 at 128 (error
0.024) has (x6−x7+x8) (R, 0.50). The decision lists are first their degree-1 characters through the linear block
(dlist8 from 64, error 0.11 → 0.049 at 128; f7_04 error 0.021 at 128 with 10 of 11). The character representations
are complete later: cnf3 at 1024, f7_02 at 2048, f7_06's block-plus-characters form at 2048 (its 5-literal block as
a factor of a relevant product, (−x1+x2−x3+x4−x5) × (−x6+x7+2x8)), f7_04 at 4096. dlist8's halfspace representation
is complete at 64–128 and 512–8192 but not at 256 (2 of its 8 literal characters) or 16384 (7 of 8; error 0).
Spurious terms are larger here than in the other families at the first fit (S share 0.09–0.36, median 0.24; dlist8's
(x1−x2+x3−x4+x9) 0.33 at 128) and ≤ 0.10 at 16384.
*Heuristic:* formulas are learned as their low-degree characters; blocks, often weighted with an AND of two literals
as inner term, are DFG's encoding of a whole clause or term before its characters are all detectable.

### 1.7 Random formulas (rf06, hrf0)

*Representation:* the Fourier expansion (31 non-constant characters each); I know no shorter one (their signed-symmetry
classes have 3–4 inputs, x1+x2−x3+x4 for rf06 and x1+x3−x6 for hrf0, with the other inputs entering arbitrarily).
Both are dominated by one input (f̂(x5) = −0.94 for rf06, f̂(x4) = −0.81 for hrf0).
*Numerical:* the first models are that one character (n = 32–64; rf06's model at 64 is χ[x5] plus the background,
error 0.045, against 0.032 for χ[x5] alone); exact fits follow at 128–256 (hrf0 at 128; rf06 at 256, after 0.027 at
128) with relevant blocks on the other inputs (hrf0 at 128, forced: (−x1−x3−x4−x5+x6) R 0.35, error 0) and, for rf06,
spurious modulated blocks at 128–256 (S 0.16–0.17). At 16384 hrf0's model is exactly its 31-character expansion
(size 32) and rf06's has 30 of 31 characters plus one spurious product (S 0.03).
*Heuristic:* as for the other small juntas, characters by order of size, with transient block encodings of the rest.

### 1.8 Symmetric and pure signed-sum targets (sym9, band11, f7_08, h5s7; mod 3: f7_05, h6_00)

*Representation:* one block on the class with its signs (folded for even accept sets).
*Numerical:*
- sym9 (|s| ≤ 1, 9 inputs): the folded block alone at n = 128 (share 0.98, size 4, error 0). Later a spurious product
  with a two-input factor of irrelevant inputs (0.41 at 256, 0.20 at 16384) and, at 512–2048, a spectral feature on
  the relevant inputs (R 0.50–0.81); at 4096–16384 the block, its 36 degree-2 characters and up to 28 degree-4
  characters (1, 17 and 28 at 4096, 8192 and 16384; plus the spurious product at 8192–16384).
- band11 (|s| ∈ {3,5}, 11 inputs): constant only until 512, then the folded block alone at 1024 (share 0.99, size 5),
  kept to 16384 (0.94, with a spectral feature 0.12).
- f7_08 (arbitrary set, 11 inputs): the unfolded block at 512 (forced, CV 229 / 188; error 0.012, share 0.92), with
  contaminated copies (the class plus 4 irrelevant inputs; modulated by irrelevant characters) and, at 1024–4096,
  spurious products of the true block (S 0.20–0.26 at 512–1024, 0.01 at 16384) and the block twice (§2.5).
- h5s7 (arbitrary set, 13 signed inputs): constant only to 1024; at 2048 the exact split form, a product of two
  factors that partition the class with its signs, (−x1−x2+x3+x5−x7+x8+x9−x10−x11−x13) × (x4−x6−x12) (share 0.72,
  error 0.0007); at 4096 the constant only again (error 0.368); at 8192–16384 the exact block, twice (§2.5), with
  modulated and weighted relatives. n\*_0 = 1705 but n\*_3 = 6186.
- f7_05, h6_00 (residue classes mod 3 of 14 and 13 inputs): the constant (plus the background) at every n; the test
  error falls to the minority rate (0.3245, 0.3430) by n = 2048 and stays there; the oracle error of their empty
  dictionary is 0.33–0.34.
*Heuristic:* when DFG finds a symmetric target its model is the exact block, at first alone (sym9, band11) or next
to contaminated copies (f7_08); what varies is when the search finds it (band11 waits until 1024; h5s7 is found at
2048, lost at 4096, found again at 8192; the mod-3 counts never).

### 1.9 Signed-sum mixtures (f7_07, f7_09, symand, f7_10, f7_00, f7_03, f7_11)

*Representations:* f7_07 = [−2 ≤ s ≤ 8]·x13 and f7_09 = [s ≤ 0]·x11x12: the block modulated by the parity; symand =
[|s| ≤ 2] ∧ (x7 ∨ x8): the block plus the gate's characters; f7_10 = [s + 2x6 ≤ −1]: the weighted block; f7_00 =
OR of a 4-input and a 7-input sum: two additive blocks; f7_03, f7_11: multiplexers between two sums, both blocks
modulated by the selector x11. (For f7_03, f7_11 and symand, "complete" checks only that the branch or class blocks
appear as factors of some sum term, not the modulation by x11 or the gate's characters.)
*Numerical:*
- The partner character comes first in five of the six mixtures with a partner: χ[x13] (f7_07 from 128), χ[x11]
  (f7_03 from 32, f7_11 from 32), χ[x7] (symand at 64), χ[x6] (f7_10 from 32); the block follows one or more doublings
  later. Not in f7_09, the other parity mixture: its model at 128 is the constant, and χ[x11,x12] enters at 256
  together with the modulated block χ[x11,x12]·s (f7_00 has no partner).
- At the first fit the compact form is complete for f7_07 (256: χ[x13]·s, share 0.45, beside the weighted
  (s + 3x13)), f7_09 (256, forced: χ[x11,x12]·s, 0.72), f7_00 (256, forced: the product (s₂) × |s₁|, 0.80) and f7_03
  (512: branch 1 as χ[x11]·s₁, branch 2 as a factor of a product). It is not for f7_10 (128: error 0 with
  χ[x6]·|s| and the degree-1 characters; its exact weighted block (x1+…+x5 + 2x6) from 256 on), symand (256: the
  weighted (s + 3·AND(¬x7,¬x8)), share 0.83, error 0.012) or f7_11 (128: branch 1 |s₁| and χ[x11]·|s₁| exact; error
  0.016 because branch 2, [|s₂| ≤ 4], is wrong almost only where it is selected and |s₂| = 6, 1.6% of inputs: 63 of
  its 64 test errors, by a refit).
- With more data the compact forms give way to weighted blocks with the partner as inner term and to characters: at
  16384 f7_07 holds (±s − 3x13) twice and 63 characters through x13; f7_09 (s ± 3x11x12); symand (s − 3·AND) and
  (s + 2·AND) with 16 degree-2 characters; f7_03 (s₁ − 3x11), (s₂ − 3x11); f7_00 and f7_11 carry their 4-input branch
  as its characters (χ[x1,x2,x3,x4] 0.51 for f7_00); f7_00, which has no partner, also holds a weighted block whose
  inner term takes two inputs of its 7-input sum, (s₁ + 3·AND(¬x5,x11)) (T, 0.06). Only f7_10 still has its compact
  form at 16384. All seven have test error 0 there; span R² is 1.0 for f7_07, symand, f7_10 and f7_11, 0.998 for
  f7_09, 0.96 for f7_03 and 0.89 for f7_00 (oracle error 0 for all).
*Heuristic:* DFG treats a partner variable (parity, gate, selector) as a heavy input of the block rather than as a
modulator; weighted blocks with the partner as inner literal are found easily because the partner is a strong single
input or pair (though f7_09's pair enters only together with its modulated block), and two of them in opposite
orientations (or one plus characters) represent the target as well as the modulated block does.

## 2. Across families

### 2.1 Dictionary or readout?

(Numerical, `tables/atlas_family.json`, `limits`.) Of the 148 cells with test error > 0.1, the learned features cannot
express the target (oracle error > 0.1) in 133; in 9 they can (oracle ≤ 0.02): maj9, thrint, thr30 and f7_01 at
n = 64 (and thrint, thr30, f7_01 at 128), dlist8 and f7_10 at 64, all just after the linear block entered; 6 are in
between (rf06 and dlist8 at 32, hrf0 and f7_11 at 32 and 64, where one strong character is in the model).
The oracle's features exclude the kernel background, so "cannot express" concerns the learned features only: in 27 of
the 133 cells DFG's own error is more than 0.05 below the oracle's (e.g. maj9 and thr30 at 16–32, f7_10 and rf06 at
16), because the background carries the signal there; without the background none of the 27 is.
At the first fit DFG's own error is within 0.0005 of the oracle error for the median target. The largest gaps are
andxor at 64 (0.092 against 0) and thrint at 256 (0.071 against 0), then majpar at 64 (0.067 against 0); andxor's and
majpar's vanish without the kernel background (§2.4), while thrint's stays at 0.071 without it: a readout gap on a
complete degree-1 dictionary. The model with only its target terms has error 0 for 15 of the 35 targets.
*Heuristic:* outside threshold functions, DFG's data cost is the cost of putting the right features in the model;
once they are in, its least-squares-plus-logistic readout is close to the best weights for them.

### 2.2 Spurious terms

(Numerical, `tables/atlas_family.json`, `tables/atlas_quirks.json`.)
- *Linear block.* It entered in 83 of the 407 cells. Its irrelevant degree-1 characters carry S-lin share 0.40–0.78
  at n = 64 in the 8 targets with irrelevant inputs where it entered there (f7_09 0.78, f7_10 0.58, f7_01 0.56,
  thrint 0.51, majmaj5 0.50, f7_04 0.48, maj9 0.45, dlist8 0.40; 15–24 characters; it also entered at 64 in thr30,
  which has no irrelevant input), 0.08–0.25 at the first fit in 10 targets (largest f7_04 0.25, thrint 0.22, f7_06
  0.21) and at most 0.035 at n = 16384 (h5s7; an upper bound, since that cell is one of the 13 where a round accepted
  more than the 20 characters DFG logs, so the attribution to the linear block is uncertain). It drops fastest when a
  block takes over the residual (maj9: 0.45 at 64, 0.01 at 128).
- *Spurious products* (a true block times a factor reading only irrelevant inputs): 9 cells in 4 targets (sym9 at
  256, 2048, 8192, 16384; f7_01 at 256; f7_08 at 1024–4096; f7_10 at 8192), shares 0.07–0.41, test error ≤ 0.0083. This
  is the quirk Part 10 found in v3's member (its verifier: 15–16 cells in 13–14 targets of the sum suites).
- *Contaminated blocks* (a true class plus irrelevant inputs, or modulated by an irrelevant character) at the first n
  of a block: f7_08 at 512 (S 0.20), symand at 256 ((x1+…+x8 − x30) 0.15), dlist8 at 128–256, f7_04 at 256–512.
  Other spurious blocks at the first n of a block mix relevant inputs (part or all of a true class, a gate or selector
  input, a relevant modulator) with irrelevant ones (term shares): f7_06 at 128 ((x1+x3+x19+x23−x26) 0.26 and a copy
  modulated by χ[x24], 0.14), f7_03 at 256 (its s₂ class with the selector and x13, (x7+…+x10−x11+x13), 0.32), symand
  at 128 (the gate input x8 with four irrelevant inputs, |−x8+x11−x18−x24+x29|, 0.19) and rf06 at 128–256 (χ[x5]·|…|
  on irrelevant or partly relevant inputs, 0.14 and 0.12; at 256 also a relevant block times |−x8+x15|, 0.09).
- *Totals.* At the first fit the spurious share is ≤ 0.1 for 22 of 35 targets (median 0.01; largest dlist8 0.36,
  f7_06 0.28, f7_01 0.27); removing the spurious terms changes the test error by at most 0.035 there (dlist8: 0.049
  → 0.085). At 16384 it is ≤ 0.1 for 36 of 37 (sym9 0.21) and removing it leaves the error unchanged.

### 2.3 DFG's own choice of variant

(Numerical, `tables/atlas_cells.csv`, `results/cv/forced_vs_default.json`.) At n ≤ 512 the cross-validation compares
the default and the forced variant and takes the forced one only if it wins a paired test. It did so in 18 of the 222
cells (n = 16: 1, 32: 4, 64: 2, 128: 5, 256: 5, 512: 1); in these the forced model is often the target's first fit
(par2@16, andxor@64, majpar@64, stair5@128, parmaj@128, hrf0@128, cnf3@256, f7_00@256, f7_02@256, f7_09@256,
mux6@256, f7_08@512): 12 of 18.

*What the other variant would have given* (`cv_counterfactual.py`: the variant not chosen, refitted on the same n rows
exactly as DFG.fit runs the final fit; the chosen one reproduces every cell). The two variants have the same test
error in 82 of the 222 cells and differ in 140 (n = 16: 37 of 37, 32: 36, 64: 26, 128: 23, 256: 11, 512: 7). Where the
forced variant was chosen (18) it was better in 7, equal in 8 and worse in 3 (mean gain 0.076; par2 at 16: 0 against
0.487; majpar at 64: 0.067 against 0.509; f7_02 at 256: 0 against 0.184). Where the default was kept (204) it was
better in 82, equal in 74 and worse in 48; the largest misses are par4 at 32 (forced 0 against 0.488; the forced
character is right on all 32 rows but not in the 10-fold fits on 28–29 rows, CV errors 17 / 18), mux6 at 128 (0.097
against 0.366), rf06 at 16 (0.032 against 0.280), f7_00 at 128 (0.256 against 0.472) and andxor at 32 (0.155
against 0.365). Mean test error over the 222 cells: DFG's choice 0.2257, always default 0.2319, always forced 0.2256,
the better of the two in each cell 0.2111.
*Heuristic:* the paired test is conservative where the folds are too small for the forced guess to be right, which
is where the forced guess helps most; this is also where v3's stacker, which kept both variants, did better (§3).

*Below the structure.* Below the first n at which a compact representation is complete (198 cells in 36 targets, including all cells of the
6 targets that never get one), 187 models are the default variant and 11 the forced; 108 are the constant alone
(+ background), 29 contain the linear block, 87 a true character; median test error 0.31.

### 2.4 The kernel background

(Numerical, `tables/atlas_cells.csv`, `err_no_bg`.) The background (one Hebbian step on the final residual) is added
after the weights are fitted, so removing it from a fitted model is exactly DFG's prediction without it for the same
variant. Removed, the test error is lower in 85 of the 407 cells, higher in 54 and unchanged in 268. It helps most at
n = 16–32, where the model holds little else and the target has a strong degree-1 part (maj9, thrint, thr30, majmaj5,
symand, f7_04, f7_10, rf06: without it the error would be 0.19–0.27 higher, e.g. maj9 at 32 0.491 instead of 0.283);
it hurts most where the residual's degree-1
correlations are noise: the mod-3 counts at n = 16–32 (h6_00 at 16: 0.488 with it, 0.343 without; the exception is
f7_05 at 16, where it helps: 0.517 with it, 0.676 without), rf06 at 32 (0.157
against 0.032), andxor at 32 (0.365 against 0.245), f7_07 at 128 (0.302 against 0.201), and at the first fit andxor
at 64 and majpar at 64 (0.092 and 0.067 against 0).

### 2.5 Quirks

- *Duplicate blocks* (Numerical, `tables/atlas_quirks.json`): the same block admitted twice in one model (5 cells:
  f7_08 at 1024, 2048, 4096; h5s7 at 8192, 16384), the two copies with equal shares (0.23–0.41). *Heuristic, from
  dfg13.py:* `SumBlock.key()` normalises the global sign but keeps the order of the inputs, so a block found again with
  its inputs in another order is not recognised as present.
- *Non-monotone cells:* h5s7 is fitted at 2048 (0.0007), empty at 4096 (0.368) and fitted again from 8192. A
  compact representation is lost again at a larger n, with the error at or near 0, in stair5 (χ[x1…x5] missing at 256
  only), stair6 (its degree-6 prefix character from 512 on), thrint (6 of its 9 degree-1 characters at 512), dlist8
  (complete at 64–128 and 512–8192, not at 256 or 16384), f7_07 and f7_09 (complete only at 256), f7_03 (only at 512,
  error 0.0076; 0.0039 at 1024 and 0 from 2048) and f7_00 (from 4096 on, at error 0). The test error rises with n
  after the first fit in majxor (0.0005 at 256, 0.0081 at 512, 0.0037 at 1024), f7_02 (0 at 256, 0.0129 at 512),
  f7_06 (0 at 512, 0.0044 at 1024), f7_07 (0.0056 at 256, 0.0088 at 512), f7_08 (0.0059 at 1024, 0.0083 at 2048) and
  stair6 (0 at 256, 0.0007 at 512), and by at most 0.0013 in f7_04 and f7_11 (128 → 256) and h5s7 (8192 → 16384).
  These are single seed-0 training sets.

## 3. DFG alone against v3's DFG member (Part 10)

(Numerical, `tables/p10_compare.md`, `figures/fig_atlas_p10.pdf`; Part 10's per-target files
`part10/interp/results/toy_final/v3/`.) Part 10 ran the same code inside v3 as two stacked members (default and, at
n ≤ 512, forced) with a share of the budget, and summarised the final DFG member (the forced one when the stacker kept
both; an out-of-fold fit when it kept neither). Its runs stopped after two consecutive n with portfolio error
≤ 0.005, so the common cells are mostly at small n: 255 cells of the 37 targets.
- **Same error, mostly the same model, from n ≈ 1024.** The DFG test error is identical in 141 of the 255 cells: 4 of
  37 at n = 16, 10 of 37 at 32, 16 of 36 at 64, 20 of 36 at 128, 28 of 35 at 256, 20 of 27 at 512, 16 of 18 at 1024,
  12 of 14 at 2048 and all 15 at n ≥ 4096. Of the 4 cells that differ above n = 512, 3 are cells where v3's summary
  was an out-of-fold fit because the stacker gave DFG no weight (h5s7 at 2048: alone 0.0007, v3's out-of-fold fit on
  1639 rows 0.369; h6_00 at 1024 and 2048, both near the minority rate); the fourth is majmaj5 at 1024 (0.0007 against
  0.0046). The same happens at 512 for mux11 (alone 0, v3's out-of-fold fit 0.274).
- **At small n alone is often emptier.** At n ≤ 64 alone's cross-validation mostly keeps the default variant (empty
  or degree-1 characters; forced in 7 of its 111 cells there), while of v3's 110 cells at n ≤ 64 the stacker kept the
  forced member in 51 (alone in 25, with the default in 26; Part 10 then summarised the forced one), only the default
  in 23 and neither in 36 (`weights` in Part 10's files). The forced member's terms are often true ones: rf06 at 16
  (v3 χ[x5], 0.032; alone 0.280), f7_11 at 16 (χ[x11], 0.158 vs 0.301), andxor at 32 (both pair characters, 0.155 vs
  0.365), f7_06 at 64 (χ[x8] and the block (−x6+x7−x8), beside a spurious χ[x14,x19,x24]; 0.043 vs 0.136), mux6 at 128
  (9 characters and a block with an irrelevant input; 0.097 vs 0.366). The reverse also occurs (f7_11 at 32: alone
  0.126, v3 0.299; maj9 at 64: 0.171 vs 0.285, the latter an out-of-fold v3 fit on 57 rows). Over the 114 differing
  cells alone is lower in 72, but 45 of the 114 (36 at n ≤ 64, 6 at 128–512, 3 above 512) compare with out-of-fold fits
  that v3's stacker gave zero weight; against a final v3 member alone is lower in 41 of 69. Of the 80 differing cells
  at n ≤ 64, 40 differ through the variant (v3's forced member against alone's default), 36 are against out-of-fold
  fits and 4 have the default variant in both. The 40 show the same effect as §2.3: the forced guess helps at small n,
  and the stacker kept it more often than DFG's paired test does.
- **The exact structure arrives at the same n.** By Part 10's rule (every signed-symmetry class of size ≥ 3 matched
  exactly by a block factor or modulator), n_struct is the same for all 15 targets where both runs have one (maj9,
  sym9, f7_10 at 128; f7_00, f7_01, f7_06, f7_07, f7_09, symand at 256; thrint, f7_03, f7_08 at 512; band11 1024;
  f7_04 2048; h5s7 8192). For 3 more, alone has it after v3's run had stopped (rf06 512; cnf3 and hrf0 4096); for
  majmaj5 alone has it at 2048, the last n of v3's run, where v3's member (also error 0) lacks the {x6…x10} class. The
  mod-3 failures are the same from n = 1024 on: constant and background, the error falling to the minority rate
  (fd_10, the third, also in the identity sample: constant and background at every n,
  `results/identity/dlfamdev__fd_10.json`). At smaller n v3's member was not constant-only (h6_00: two characters at
  n ≤ 32 and in the out-of-fold fit at 64, a character and a sum block at 256–512; f7_05: one or two characters at
  16–128, all out-of-fold fits), while alone is the constant at every n.
- **The Part 10 findings that carry over unchanged**: exact signed blocks on the symmetric targets (sym9, band11, f7_08,
  h5s7) at v3's n_struct; parities, small juntas and staircases as characters; halfspaces as degree-1 characters through
  the linear block; mixtures with the partner as character and as inner term of a weighted block; spurious products of
  a strong block; mod 3 never. In these files the differences between DFG alone and v3's member come from which
  variant is kept at n ≤ 512 (64 of the 114 differing cells, 40 of them at n ≤ 64) and from cells where v3's stacker
  gave DFG no weight, so that Part 10 summarised an out-of-fold fit (45, 36 of them at n ≤ 64); 5 differ with the same
  (default) variant.

## 4. What I could not check, and caveats

- Seed 0 only; one training set per (target, n). The 3-seed n\* shows how much seeds matter (h5s7: n\*_0 1705, n\*_3
  6186; f7_08 448 vs 644; dlist8 71 vs 39).
- 37 of 138 targets. dlheld2 and dlfamdev are only in the identity sample (no atlas description), and some
  sub-families have no atlas target: dlheld5's thresholds with a character (h5t) and arbitrary sets with a parity or
  gate (h5s1, h5s4), the MAJ gate (fd_08), two sums under XOR (fd_06, h6_09), sym × parity with two blocks, weighted
  blocks with a parity or AND inner term (thrsum's is a parity; h6_10, only in the identity sample, has a literal
  inner term, as f7_10 does).
- The categories depend on the representations written down in `atlas_truth.py`. A model can be exact in a form not
  listed (the weighted pairs of §1.9, the folded pair of §1.5 until it was added after seeing the fits, the
  multiplexer's address blocks, the clause blocks): such terms count as R. The folded-pair, address-block, clause-block,
  f7_06 and auxiliary symmetry-class representations were added after the first fits had been looked at; the
  categories of every cell were then recomputed by refitting (identical fits). The verifier found the stored
  specifications and categories equal to what the current code gives (37 of 37 targets, 407 of 407 cells); that every
  file was refitted, rather than only reclassified, cannot be told from the files, and does not change the results.
- "Complete" checks the dictionary, not the weights; the oracle error and span R² are fitted on the test inputs (an
  idealised readout), so they say what the features could express, not what DFG's readout achieves.
- Category shares are standard deviations of parts of the model's real-valued output; parts that cancel can exceed 1,
  and S-lin uses the orthogonality approximation (it can exceed the exact S share slightly). Term shares and the
  tables' character-group values are absolute sds, not fractions of the output's sd (§0).
- The block representations are checked only for functional dependence (§0): accept sets are not checked, the check
  is vacuous for the multiplexer address blocks, and the spectral pair is not verified.
- The identity check compares test errors and FLOP counts, not models; the evaluation files store no models.
- thr30 (k = 30) has no exact Fourier table; its characters are classified by the parity of their degree (it is an odd
  function), and its representation is not verified by enumeration.
- Not done here (other Q7 parts): when a target's test would admit its block (Part 10's n_detect, with its verifier's
  corrections for mixtures), the order of admission against the Part 5 networks, false admissions on random labels,
  where the compute goes.
