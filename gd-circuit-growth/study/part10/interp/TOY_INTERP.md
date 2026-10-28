# What v3's DFG member learns on the toy targets (Part 10 interpretability, toy side)

Descriptive analysis of the best learner so far, v3 = `hyb_portfolio3` ([`../hyb_portfolio3/learner.py`](../hyb_portfolio3/learner.py),
md5 `b045fafe1e24418620bf8c503aa601c6`), on the study's Boolean toy suites. On toy inputs v3 is a stack of DFG v1.3
([`../hyb_portfolio3/dfg13.py`](../hyb_portfolio3/dfg13.py), md5 `69cabe5c50345cb24079198ed52b562f`; a default and, at
n <= 512, a 'forced' small-n variant), LightGBM, ExtraTrees, kNN and logistic regression; v2 = `hyb_portfolio2` is the same
stack with DFG v1.2. The questions: what structure DFG learns, at which n, and why it fails where it fails. This is
analysis, not evidence of superiority (PROTOCOL.md, "Interpretability").

Everything below is seed 0 (one training set per (target, n)) unless it says "3 seeds". Every number is computed from a
file named next to it; *Measured* marks what the files show, *Reading* marks my interpretation.

**Files.** Script: [`toy_interp.py`](toy_interp.py) (all tables and figures below; `INTERP_OUT=<live outputs> python
toy_interp.py`, or without `INTERP_OUT` from the copies in `results/toy_final/`). Inputs, copied to
[`results/toy_final/`](results/toy_final/): `v3/` and `v2/` (toy_structure.py, final matcher, one JSON per suite and
target), `power/` (toy_power.py), `toy_power_w/` (toy_power_w.py, weighted blocks), `toy_landscape/` (toy_landscape.py),
`toy_g/v3/` (toy_gfit.py). n\* files: `study/hybrid/results/toy__p10_sum-perm__<suite>.json` (v3; v3 = p10_sum on toy
inputs, PROTOCOL.md; dlheld5 from its per-target shards `__partNN.json`; dlheld4 not yet run, so 3-seed n\* of v3 is
missing there), `toy__hyb_portfolio2-perm__<suite>.json` / `toy__p9_sum-perm__<suite>.json` (v2). Tables:
[`tables/`](tables/); numbers quoted from `tables/toy_summary.json` are given with their key. Figures:
[`figures/fig_toy_*.pdf`](figures/).

## Short answer

- **What it learns** (*Measured*, `tables/toy_recovery_v3.md`). On the 54 sum-structured targets of the six
  sum-structured suites, v3's DFG model contains the target's exact structure (every signed-symmetry class of size >= 3
  as a block, a factor of a product block, or a modulator) at some analysed n for 49 targets; median first n 256
  (range 64–16384). The block is folded (|t|) for even accept sets and unfolded otherwise; parities enter as a
  character chi_P that then modulates a block; gates and multiplexer selectors enter as characters and, in v3, as the
  heavy inner literal of a weighted block (`s1 + 3 x11`); two sums enter as product blocks.
- **When** (*Measured*, `tables/toy_summary.json` `timing`). The true block passes DFG's own test at n = 128 for 43 of
  the 54 targets. The exact structure appears a median of one doubling later (log2(n_struct / n_detect): median 1.0,
  mean 1.04; 15 of 49 two or more doublings later), and the 10% error point n\* is at or before it (log2(n\* / n_struct):
  median −0.35, never above +0.5). The delay beyond detection tracks the share of the target's variance at Fourier
  degrees 1–2 (Spearman −0.86 over the 25 pure symmetric targets). *Reading:* the sample complexity is set by the
  search, not by the test and not by the readout.
- **Where it fails.** The three residue classes mod 3 of 10–14 inputs (fd_10, h6_00, f7_05) are never learned: the
  true block passes the test from n = 128 and is 134–155 times its threshold at n = 16384, but the targets have zero
  weight at degrees 1 and 2, no pair or single input inside the block carries any signal (0.12–0.25 of the threshold,
  the same as pairs outside it), and only candidates within about 3 errors of the truth are detectable: 34281
  candidates among 1.5·10^10–1.2·10^12 of the same size. The model stays at the constant plus the kernel background.
- **v3 against v2.** Weighted blocks change what is learned on h6_10 (n\* 702 → 206, 3 seeds) and on the multiplexers
  (selector as an inner literal); the small-n beam and forced blocks move the first exact block from n = 256 to 128
  (or 128 to 64) on 6 pure symmetric targets (sym7 n\* 110 → 55). On 20 of 68 targets the portfolio's test errors are
  identical at every analysed n.
- **Below the discovery n** the default DFG variant is mostly empty (constant + kernel background); the recorded
  forced variant holds 1–2 forced characters, mostly spurious. The stacker gives DFG a median weight share of 0.21
  there (kNN gets the largest mean share, 0.28), against 0.89 from n_struct on.

## 0. What was measured, and how

**Fits.** `toy_structure.py` reproduces the evaluation's toy fits (`eval_toy.py --perm`: the same training rows, column
permutation and rng) with the learner's internals recorded (`hooks.py`), seed 0, on the n grid 16, 32, …, 16384,
stopping after two consecutive n with test error <= 0.005. *Check:* the structure runs' test errors equal the seed-0
errors in the evaluation's result files at all 313 v3 cells and 477 v2 cells where both exist (`tables/toy_summary.json`,
`identity`).

**The model.** The final DFG member: the last DFG fit on all n rows. When the stacker keeps both DFG variants, that is
the forced variant (refitted after the default); when it keeps neither, the summary is of the last out-of-fold DFG fit
(fewer rows). Terms are given in original coordinates (x1..x30), each with its *share* = the standard deviation of its
contribution over the 4096 test inputs. `quad(m inputs)` is a spectral feature (u·x)² − |u|², `background` the kernel
background (one Hebbian step on the residual).

**Exact structure.** `hooks.symmetry_classes` finds the target's signed-symmetry classes (i ~ j if f is invariant under
swapping x_i, x_j, or under x_i → −x_j, x_j → −x_i). A class of size >= 3 is *matched exactly* when a sum block, a
factor of a product block or the modulator chi_M of a modulated block has the same set and the same signs up to a
global flip. `n_struct` = the first analysed n at which every class of size >= 3 is matched exactly in the same model;
`n_stable` = the first n from which this holds at every larger analysed n; `n_class_first` = the first n per class.
For a weighted target (u = s + a·tau) the class is the unit-weight part s; the inner term is checked separately (§1.3).
This criterion is strict: some models reach zero error with a different exact representation (§1.4).
`n_dfg01` = the first n at which the DFG member alone has test error <= 0.01.

**Detection.** `toy_power.py` applies DFG's own block test to the TRUE block (the largest class with its signs) as if it
were proposed in round 0, on the seed-0 training rows: T = |projection of the centred labels on the block's level
indicators|² / s², against the χ² threshold with DFG's union bound over every (S, s) of that size, both folds and every
size up to 24 (v1.2's bound for unweighted blocks, which v1.3 keeps). `n_detect` = the first grid n with
T / threshold > 1, unfolded, folded or modulated (the block on r·chi_M for the best M among the other relevant inputs).
For the five weighted targets the true block is the weighted one, tested with v1.3's larger threshold (+9.8 nats for the
inner terms) by `toy_power_w.py`; it is detectable at n = 128 for all five, the unit-weight part alone at 256–512
(`tables/toy_summary.json`, `power_w`). `n_reach5` = the first n at which the search's own orders (top-2 eigenvectors of
the residual pair matrix, or the degree-1 order) put the whole class within their first |S| + 5 inputs.

**n\*.** The 10% test-error point, log2-interpolated on the seed-mean error (the rule of `compare_hybrid.py`); `n*_3`
from the 3-seed result files, `n*_0` from the seed-0 structure runs (the same fits as n_struct).

## 1. Recovery: does the model contain the target's structure?

### 1.1 By suite and by kind of accept set

*Measured* (`tables/toy_recovery_by_suite.md`, `tables/toy_recovery_by_kind.md`; per target: `tables/toy_recovery_v3.md`):

| suite | sum-structured targets | exact structure at some n | median n_struct | n_struct <= 128 | <= 512 | never |
|---|---|---|---|---|---|---|
| dlsymdev | 8 | 8 | 128 | 5 | 7 | – |
| dlfamdev | 9 | 8 | 192 | 4 | 7 | fd_10 |
| dlheld7 | 9 | 7 | 256 | 1 | 7 | f7_05, f7_11 |
| dlheld6 | 9 | 7 | 512 | 1 | 6 | h6_00, h6_02 |
| dlheld5 | 10 | 10 | 512 | 0 | 6 | – |
| dlheld4 | 9 | 9 | 256 | 4 | 8 | – |

| accept set / mixture | targets | exact at some n | median n_struct | never |
|---|---|---|---|---|
| threshold | 11 | 11 | 256 | – |
| band | 20 | 19 | 256 | f7_11 |
| interval | 11 | 10 | 256 | h6_02 |
| arbitrary | 16 | 15 | 512 | f7_11 |
| modular | 5 | 2 | 768 | fd_10, f7_05, h6_00 |
| pure | 25 | 22 | 256 | fd_10, f7_05, h6_00 |
| with a parity | 9 | 8 | 256 | h6_02 |
| with a gate | 5 | 5 | 256 | – |
| multiplexer | 4 | 3 | 512 | f7_11 |
| two sums | 5 | 5 | 256 | – |
| weighted sum | 6 | 6 | 256 | – |

(A two-block target counts under both of its accept kinds.) The two modular blocks that are learned are 6-input
sub-blocks of multiplexers (h6_08's mod 3 at n = 1024, f7_03's mod 4 at n = 512); the three pure mod-3 counts on 10, 13
and 14 inputs are never learned (§4). Arbitrary accept sets need the most data (median 512; h5s7 8192, h5s1 16384).

### 1.2 What the model looks like when it has the structure

*Measured* (leading terms at the largest analysed n, `tables/toy_recovery_v3.md` column `lead`; earlier n in the
per-target JSONs). The recurring forms:

- **Pure symmetric, even accept set** (bands, |s| ∈ A): one folded block, usually with share 0.3–0.97 of the model,
  often next to a spectral feature on the same inputs: band11 `|x1+…+x11|` (0.97), far9 `|x1+…+x9|` (0.43) +
  `quad(21 inputs)` (0.26), tail13 at n = 128, sym11 at 128, ssym9 `|x1−x2+x3−x4+x5+x6−x7+x8+x9|` with its signs.
- **Pure, other accept sets** (intervals, arbitrary sets): one unfolded block with its signs: ex3of8 `(x1+…+x8)` (0.80),
  h6_11 `(x1+…+x7)`, h6_01 `(−x1+x2−x3+x4+x5+x6−x7−x8−x9)` (0.91), h5s2 (0.92), f7_08 (1.01).
- **Thresholds** (halfspaces) are carried by degree-1 characters as much as by the block: fd_01 `chi[x5], chi[x2],
  chi[x4]` (0.28–0.29 each), f7_01 the 13-input block (0.26) next to `chi[x4], chi[x1]` (0.19 each).
- **With a parity** chi_P: the parity is found first as a character (its coefficient is E[g(s)]), then a block
  modulated by it: fd_02 `chi[x9,x10]` (0.87) + `chi[x9,x10]*|−x1+x2+…+x7−x8|` (0.41); fd_04
  `chi[x7,x8,x9]*|x1+…+x6|` (1.06); f7_09 `chi[x11,x12]*(x1−x2+…+x10)` at n = 256. Or, in v3, a weighted block with the
  parity as its inner term: symxpar `(−x1−…−x6 + 3 x7x8)` (0.73), h6_06 `(x1+…+x6 ∓ 3 x7x8)`, f7_07 `(s ± 3 x13)`.
- **With a gate** (AND / OR / MAJ with literals): the literals as characters plus the block or a block modulated or
  weighted by them: majsym `chi[x8], chi[x6,x7]` + `chi[x6,x7]*(−x1−…−x5+x8)`; fd_11 `chi[x10]` (0.74) + `|x1+…+x9| x
  (x10−x14)`; h5s4 `chi[x6]` + `(−x1−x2−x3+x4+x5 − 3 x6)`; symand `(−x1−…−x6 + 3 AND(−x8,−x7))`.
- **Multiplexers**: the selector x11 as a character and as the heavy inner literal of a weighted block on one branch:
  h6_07 `(x1−x2−…−x6 + 3 x11)` (0.40), h6_08 `(x5+x6−x7+x8−x9+x10 − 3 x11)` (0.30), f7_03 `(x1+…+x6 + 3 x11)` (0.24).
- **Two sums**: a product block over the joint cells, or a block over the union with one side's signs flipped
  (the 'split' move): twosym `|x1+…+x5| x |x6+…+x10|` (0.72) + `|x1+…+x5 − x6−…−x10|` (0.36); f7_00
  `(x5+x6+x7−x8−…−x11) x |x1+x2−x3−x4|` (0.69); fd_06 two blocks over all 11 inputs with opposite relative signs.

*Measured, a quirk:* 14 cells (14 targets) carry a product of the true block with a 2-input factor made only of
irrelevant inputs, e.g. sym7 at n = 128 `|x1+…+x7| x |x15−x16|` (share 0.40), h6_07 at 512 (0.52); their test error is
at or near 0 (per-target JSONs). *Reading:* the product test scores the whole joint partition, which contains the true
block's partition, not the increment over it, so a strong block drags an irrelevant factor through the test.

### 1.3 Weighted targets: is the inner term right?

*Measured* (`tables/toy_recovery_v3.csv`, columns `inner_by_n`, `n_inner_exact`):

| target | truth | inner term in the model, by n |
|---|---|---|
| h6_10 | \|s − 3 x13\| > 1, s = x1+…+x12 | 256: `\|s + 3 x13\|` (weight right, relative sign wrong; DFG error 0.017); 512 and 1024: `\|−s + 3 x13\|` = exact |
| f7_10 | s + 2 x6 <= −1, s = x1+…+x5 | 128: `chi[x6]*\|s\|` (modulator); 256: `(s + 2 x6)` exact |
| h5t0 | sign(s + 2 x8x9 + 1/2) | 256: `s x \|x8+x9\|` (product factor); 512: `(s + 2 x9x8)` exact |
| thrsum | sign(x1+…+x6 + 3 x7x8 + 1/2) | 256, 512: `(x1+…+x6) x \|x7−x8\|` (product factor) |
| h5t1 | sign(s + 2 x6x7 + 1/2) | 512: `(s + 3 x6x7) x \|−x6+x7\|` (weight 3, not 2, inside a product with the parity's factor) |
| sumpar | sign(x1+…+x5 + 2 x6x7 + 2 x8x9x10) | degree-3 inner term not representable; the model is `chi[x8,x9,x10]`, `chi[x6,x7]`, `chi[x1..x5]` and degree-1 terms |

A product with `|x_j ± x_l|` or a modulator by tau represents every function of (s, tau), so all six are represented
exactly at the largest n except h6_10 at 256. h6_10 at 256 is an aliasing case: [|s + 3 x13| ∉ {5, 7}] equals the target
except where |s| >= 8, which explains its 1.7% error (§3).

### 1.4 Exact representations the matcher does not count

*Measured* (per-target JSONs): f7_11 (a multiplexer between a 4-input and a 6-input block) has each class exactly at
some n (4-input at 128, 6-input at 2048) but never both in one model; its 4-input branch [s1 ∈ {±4}] is carried by
characters of degree <= 4 instead (n\*_3 55). h6_02 = [1 <= s <= 5]·x10·x11 is fitted to DFG error 0.002 at n = 512 by
`chi[x1,x10,x11]*|x2+…+x9|` plus characters x_j·x10·x11, and at 1024 by the degree-11 character on x1..x11 (share 0.55)
plus degree-3 characters. v2's h6_10 at n >= 512 uses two folded 13-input blocks `|s + x13|`, `|s − x13|`, which
together determine (|s|, sign(s·x13)) and hence f (error 0.000 at 1024, `results/toy_final/v2/dlheld6__h6_10__s0.json`).
The DFG member reaches error <= 0.01 before n_struct on f7_11, h6_02, h5t1 and sumpar (`tables/toy_timing.csv`,
`n_dfg01`).

### 1.5 Non-sum suites (designed, random, dlheld–dlheld3)

PENDING_NONSUM

## 2. Timing: detection, search and readout

*Measured* (`tables/toy_timing.csv`; summary `tables/toy_summary.json` `timing`; figure
[`figures/fig_toy_timing.pdf`](figures/fig_toy_timing.pdf)). For the 54 sum-structured targets:

- **Detection is cheap.** The true block (weighted block for the five weighted targets) passes DFG's test at n = 128 for
  43 targets, 256 for 6, 512 for 3 and 1024 for 2 (twosym, fd_06: one block of a two-sum target explains only part of
  it). For 9 targets (all mixtures with a parity) only the modulated statistic passes; the plain block never does.
- **The exact structure comes later.** Of the 49 targets found, n_struct is before n_detect for 5 (sym7, majsym and three
  two-sum targets, where the test on the largest block alone is too strict), equal for 16, one doubling later for 13,
  two or more for 15 (band11, f7_03, f7_08, h6_01, h6_08, h5s1, h5s2, h5s3, h5s5, h5s6, h5s7, h5t1, band10, sumpar,
  symxor). log2(n_struct / n_detect): median 1.0, mean 1.04.
- **The readout is not the bottleneck.** log2(n\*_0 / n_struct): median −0.35, mean −0.64; within ±0.5 for 34, below
  −0.5 for 15 (thresholds and gate targets whose linear part or literals give 10% error before the block is exact, e.g.
  fd_08 n\*_0 26 against n_struct 1024), above +0.5 for none. With the 3-seed n\* (38 targets): median −0.31.
- **What sets the delay.** log2(n_struct / n_detect) (never found: n_struct := 2^15) against the share of Var f at
  degrees 1–2, (W1 + W2) / (1 − W0) from the power files: Spearman −0.44 over all 54 (p = 0.001), −0.86 over the 25 pure
  symmetric targets (p = 3·10⁻⁸). The 12 targets with share < 0.05 include all three never-learned mod-3 counts and the
  late h5s1, h5s2, h5s3, h5s7, band11.
- **Search orders.** n_struct is before n_reach5 for 22 targets, equal for 11, after for 8; for 8 the orders never reach
  S on the plain residual (the parity mixtures). The search finds blocks before its spectral order lists them (greedy
  growth from pairs, local refinement and, at n <= 128, the beam repair a partial order).

*Reading.* The data cost of a block is set by the search, not by the test: the test would accept the true block at
n ≈ 128 almost always, the model is right as soon as the block is in it, and the extra data the search needs grows as
the target's low-degree (degree 1–2) signal shrinks, because every seed of the search (eigenvector prefixes of the pair
matrix, the degree-1 order, greedy growth from the strongest pairs) reads the block's inputs off those coefficients.

## 3. The learned function of the block statistic

*Measured* ([`figures/fig_toy_g.pdf`](figures/fig_toy_g.pdf)): mean target E[f | t] against the mean DFG value at each value
of the true signed sum t, over the 4096 test inputs; top row from the stored `g` lists of the structure runs, bottom row
split by the second term tau from refits (`toy_gfit.py`, which reproduce the structure runs' cells; files
`results/toy_final/toy_g/v3/`). "agree" = the share of test points at whose t (or (t, tau)) the mean DFG value has the
sign of E[f | ·].

| panel | n | DFG test error | agree | model |
|---|---|---|---|---|
| tail13, band \|s\| >= 5 | 256 | 0.005 | 1.00 | `quad(24)` 0.41, `\|x1+…+x13\|` 0.34, product with `\|x16+x20\|` 0.19 |
| h6_11, interval s = 1 | 128 | 0 | 1.00 | `(x1+…+x7)` 0.86 |
| h6_01, arbitrary, signed | 512 | 0 | 1.00 | `(−x1+x2−x3+x4+x5+x6−x7−x8−x9)` 0.91 |
| f7_01, threshold s <= 1 | 256 | 0 | 1.00 | `(x1+…+x13)` 0.47, product with `\|x21−x27\|` 0.24 |
| h6_10, by (t, x13) | 256 | 0.017 | 0.98 | `\|x1+…+x12 + 3 x13\|` 0.85 |
| h6_10, by (t, x13) | 512 | 0 | 1.00 | `\|−x1−…−x12 + 3 x13\|` 0.84 |
| f7_10, by (t, x6) | 256 | 0 | 1.00 | `(x1+…+x5 + 2 x6)` 0.57, `chi[x6]` 0.43 |
| f7_09, by (t, x11x12) | 256 | 0.0005 | 1.00 | `chi[x11,x12]*(x1−x2+…+x10)` 0.72, `chi[x11,x12]` 0.54 |

The learned g follows the truth level by level, including the non-convex accept sets (h6_01's
{−9, −7, −5, −1, 1, 7, 9}) and the two branches of a weighted or modulated target. The values are not ±1: the logistic
readout rescales them and overshoots at rare levels (tail13 at |t| = 11, f7_01 at t = 13). h6_10 at n = 256 shows the
aliasing of §1.3: right at every frequent level, wrong at |t| >= 8 with one sign of x13. Below the discovery n the same
plot is flat: h6_10 at n = 128 (`results/toy_final/toy_g/v3/dlheld6__h6_10__n128.json`) has DFG error 0.39 and agrees
on 0.70 of the points, the majority rate.

## 4. Failures and late targets

*Measured* (`tables/toy_failures.md`, `tables/toy_landscape.md`; figure
[`figures/fig_toy_failures.pdf`](figures/fig_toy_failures.pdf): the test on the true block, the search's reach and the
Fourier weight by degree).

**The residue classes mod 3** (fd_10 = [B mod 3 = 0] on 10 signed inputs, h6_00 = [B mod 3 ≠ 1] on 13, f7_05 =
[B mod 3 ≠ 0] on 14):
- *What the model contains:* nothing but the constant and the kernel background at every n >= 1024 (DFG error = the
  minority rate, 0.32 / 0.34 / 0.32 at n = 16384). At smaller n the forced variant adds 1–2 spurious characters or a
  spurious partial block (h6_00 at 256: `|−x4+x12−x22−x23|`, 2 of 4 inputs in S).
- *Is the block detectable?* Yes, from n = 128 unfolded (512 folded); at n = 16384 the true block is at 155 / 139 / 134
  times DFG's threshold (`power/` files, `ratio_unfold_max`).
- *Low-degree signal:* W1 = 0 and W2 <= 0.0002 for all three; the Fourier weight peaks at degree 7, 9 and 11.
- *Why the search cannot reach it:* at n = 16384 the statistic of the true block falls by about 4× per missing input
  (drop 1: 41 / 36 / 35; drop 2: 11 / 9.4 / 9.2; drop 3: 2.9 / 2.5 / 2.4; drop 4: 0.84 / 0.73 / 0.65 times the
  threshold) and by 3–4× per wrong sign or extra input; every candidate with 3 errors of mixed kinds still passes (the
  fraction above threshold is 1.00), with 4 missing inputs none does at the median. But no 1- or 2-input piece of the
  block carries signal: the best pair inside S is at 0.15 / 0.25 / 0.12 of its threshold, the best pair among 12 inputs
  outside S at 0.33 / 0.20 / 0.20, random blocks of the true size at 0.07. The search's orders reach S no better than
  chance (eigenvector prefix 0.50 / 0.54 / 0.57 of S against |S|/30 = 0.33 / 0.43 / 0.47). Within 3 errors of the
  truth there are Σ_{t<=3} 2^t C(30, t) = 34281 candidates (the same for every k), against C(30, k)·2^{k−1} = 1.5·10^10 /
  4.9·10^11 / 1.2·10^12 candidates of the true size.
- *Reading:* a residue class mod 3 of k inputs is a needle: detectable when it is found, invisible from every
  low-order foothold the search has. Larger n does not help, because the pair and single statistics are zero in
  expectation, not just noisy. (Of the network variants, only the most regularized learns h6_00, at n\* = 12304;
  `tables/toy_recovery_v3.csv`, `nets_best`.)

**Late targets** (n_struct >= 1024): the same mechanism, weaker.
- band11 = [|x1+…+x11| ∈ {3, 5}] (W1 = 0, W2 = 0.047): detectable at n = 128, found at 1024, when the top eigenvector
  of the pair matrix first lists all 11 inputs within |S| + 5 (reach 0.82 at |S|; `power/dlsymdev__band11.json`). At
  n = 512 the basin is narrow: one sign flip already drops the statistic to 0.61 of the threshold, and pairs inside S
  are at noise (0.27).
- f7_08 (arbitrary set on 11 inputs; W1 = 0.024, W2 = 0.054): detectable at 128, found at 512; at 256 the true block is
  2.37× the threshold but one missing input drops it to 0.52.
- h5s7 (arbitrary set on 13 signed inputs; W1 = 0.006, W2 = 0.009): detectable at 128, found at 8192, when the top
  eigenvector reaches 0.92 of S (1.0 within |S| + 5). At n = 2048 the true block is 18.6× the threshold, but 3 mixed
  errors pass only 12% of the time.
- h5s1 = [s ∈ {−9, −5, −1, 3, 9}] xor x10x11 (9 signed inputs): 92% of its variance is on the single degree-11
  character x1⋯x11 (coefficient 0.961; `results/toy_final/v3/dlheld5__h5s1__s0.json`, `fourier_top`). The plain block has
  no signal (0.04 of the threshold at 16384); the modulated block passes from n = 128 but needs chi[x10,x11] in the
  model first, whose coefficient is −0.031 (W2 = 0.001). It is found at n = 16384 (seed 0; n\*_3 never).
- h5s2, h5s3 (arbitrary; W1 + W2 = 0.007 and 0.03): found at 1024 and 2048.

## 5. v3 (DFG v1.3) against v2 (DFG v1.2)

*Measured* (`tables/toy_v2_v3.md`; summary `tables/toy_summary.json` `v2v3`; figure
[`figures/fig_toy_v2v3.pdf`](figures/fig_toy_v2v3.pdf)). On the six sum-structured suites (68 targets including the
controls): mean log2 n\* ratio v3 / v2 −0.097 over the 49 targets with 3-seed n\* for both (dlheld4 has no v3 3-seed run
yet), −0.106 over 65 targets with seed-0 n\* for both. On 20 targets the portfolio's test error is identical at every
analysed n.

| change | targets: n_struct v2 → v3 (seed 0); n\* v2 → v3 (3 seeds, else seed 0) |
|---|---|
| **weighted blocks** change what is learned | h6_10: never → 256 (weighted `\|s ± 3 x13\|`; exact sign from 512); n\*_3 702 → 206. h6_07: never → 512 (`s1 + 3 x11` with the selector as inner literal); n\*_3 678 → 447. h6_08: never → 1024 (`s2 − 3 x11`, products with `s1 + 3 x11`); n\*_3 446 → 449. f7_10: same n (128), but at 256 the model is the exact `(x1+…+x5 + 2 x6)` where v2 keeps `chi[x6]*\|s\|`; n\*_3 82 → 82. symxpar, h6_06, f7_07: the parity partner as inner term, same n_struct and n\* |
| **small-n beam + forced blocks** (n <= 128) | sym7 128 → 64 (forced variant only; at 64 the true block is at 0.89 of the threshold, so it was forced, not accepted), n\*_3 110 → 55. fd_09 256 → 128 (passes the test at 128: 1.62), n\*_3 171 → 101. h6_11 256 → 128, n\*_0 212 → 100 (n\*_3 208 → 184). tail13, sym11, majsym 256 → 128, n\*_0 199 → 100, 219 → 110, 188 → 91 |
| later in v3 | h5t1 256 → 512 (portfolio errors identical at every n) |
| lost | f7_11: v2 has both classes at 2048, v3 never in one model (n\*_3 55 both) |
| nothing | 41 targets have the same n_struct, among them the three mod-3 counts, band11, all of dlheld5's arbitrary sets except h5t1, ex3of8, twosym |

*Measured, where weighted blocks appear in v3's models* (`tables/toy_weighted_blocks_v3.md`): 26 targets have a
weighted block with share >= 20% of the largest term at some n. Its inner term is a true weighted term (h6_10, f7_10,
h5t0, h5t1), a parity partner (symxpar, h6_06, f7_07), a multiplexer selector (h6_07, h6_08, f7_03), a gate literal or
AND of two literals (h5s4, symand, symxor, majsym) — and in 9 controls (decision lists, DNFs, read-once formulas) an
AND of two literals inside a weighted threshold, e.g. h6_04 `(x1+x2 − 3 AND(x4,−x3))`.

*Reading.* The weighted class is used far more widely than for the one target it was built for (h6_10): any function of
a block and one more ±1 term that the block's partition cannot separate (a parity partner, a selector, a gate) can be
partly or wholly written as a function of s + a·tau, and the search finds these because the extra term is usually a
strong pair or single input. Where v2 already had the structure at the same n (41 targets), v1.3 changes nothing
measurable.

## 6. Below the discovery n

*Measured* (`tables/toy_below_discovery.csv`; summary `tables/toy_summary.json` `below`; figure
[`figures/fig_toy_wdfg.pdf`](figures/fig_toy_wdfg.pdf)). 216 cells of the 49 found targets have n < n_struct, 123 have
n >= n_struct, and the 5 never-found targets add 49 cells.

- **Contents.** Of the 216 cells below n_struct, the summarised model is the forced variant in 177 and the default in
  39. The default variant is empty (constant + kernel background only) in 26 of its 39 cells; its other cells hold a
  few true degree-1 characters (thresholds) or the linear block. The forced variant holds 1–2 forced characters of
  degree 1–4 (degree up to 7 from the subsampled high-degree search) that are spurious (not inside the relevant set)
  in 152 of 177 cells; 87 of 177 also hold a true character (a parity partner, a gate literal, a threshold's input).
  Partial blocks (a sum block that does not match exactly) appear in 21 cells, 14 of them one doubling before n_struct.
- **Error.** Median DFG test error 0.41 below n_struct (the portfolio's 0.37), 0.0 from n_struct on.
- **Stack weights.** The DFG members' share of the stack weight: median 0.21 (mean 0.33) below n_struct, 0.89 (mean
  0.87) from n_struct on, 0.20 on never-found targets. Below n_struct the stack's total weight is small (median 0.35,
  against 1.52 from n_struct on), so the stack is close to its bias, a constant predictor; the members' mean shares
  there: kNN 0.28, dfg_forced 0.22, LightGBM 0.13, logistic regression 0.12, dfg 0.11, ExtraTrees 0.05. By
  log2(n / n_struct): the median DFG share is 0.03 at −3, 0.21 at −2, 0.44 at −1, 0.87 at 0, 0.92 at +1.
- **By n** (all 54 targets, `by_n`): the mean DFG share rises from 0.27–0.30 at n = 16–64 to 0.52 at 128, 0.72 at 256
  and 0.79 at 512; above 512 the cells thin out (the runs stop after two cells with error <= 0.005) and the remainder
  are the hard targets.

*Reading.* Below the discovery n DFG contributes almost nothing and is mostly switched off by the stacker; the forced
variant's spurious characters do not hurt because they get little weight. The portfolio's small-n error on these
targets is carried by kNN, trees and the bias, and stays near the majority rate until the block appears. The jump in
DFG's weight is abrupt: one doubling of n takes the median share from 0.44 to 0.87.

## 7. Caveats

- Seed 0 only for the structure analysis; n_struct, n_detect and model contents can differ on other seeds (the
  3-seed n\* is quoted where it exists).
- The exact-structure criterion is strict (§1.4) and depends on `hooks.symmetry_classes`, which finds classes from 4096
  random inputs; a control can have a small class (fd_07, h5rf0, h5rf1, h4rf0, f7_04, f7_06, h6_05, dnf3x3); controls
  are excluded from every summary of sum-structured targets.
- n_detect is the test on the largest class alone in round 0 (`toy_power.py`), with v1.2's union bound for one
  modulator count; in a later round the residual and the modulator count differ. For multi-block targets the largest
  block alone can be undetectable when the pair is (twosym, fd_05, fd_06).
- The search-reach measure covers the eigenvector and degree-1 orders only, not greedy growth, refinement or the beam.
- The network n\* (`nets_best`) on dlheld7 uses the variants present when the tables were made: `nets_wd` for all 12
  targets, `nets_cewd0.3` / `nets_cewd1.0` only for f7_00–f7_05 (runs in progress). dlfamdev has no network runs.
- v3's 3-seed n\* on dlheld4 was not yet available; dlheld4 rows use seed 0 only.
