# Verification of ABLATIONS.md (Part 11, Q5 and Q5b: what DFG v1.3's parts do, and the core DFG)

This is an independent verification of `ABLATIONS.md`. It covers the report's records and scripts: `ablations.py`,
`families.py`, `perm_null.py`, `leavein.py`, `refit.py`, `ablations.json`, `results/` (the paired null, the
leave-one-in runs, `refits.json`, `refit_crosscheck.json`), and the Q5 and Q5b sections of `compare_dfg.py`,
`RESULTS.md` and `RESULTS.json`. Written 3 November 2026. The structured version is
[`VERIFY_ABLATIONS.json`](VERIFY_ABLATIONS.json): 75 claims, 10 omissions.

I did not edit `ABLATIONS.md` or the paper, and I committed nothing. Every computation ran single-threaded
(`OMP_NUM_THREADS=1`, `OPENBLAS_NUM_THREADS=1`).

## Verdict

**Mostly confirmed: 49 claims confirmed, 24 corrected, 2 unsupported, and 10 omissions.** None of the corrections
changes a headline conclusion. Several of them change a mechanism or a denominator that the paper repeats.

**What holds.** I recomputed the following with my own code from the result files and they reproduce:
- all 60 cells of the §1 table, all family and per-seed numbers, and every list of moved targets;
- the unpaired null and the paired null. I re-ran 33 cells of the paired null with the frozen module and the
  `[…, 77, 1]` stream, and all 33 are identical;
- the P2 parity predictions, the n_glob shifts, the linear block's thresholds and the re-thresholding of Part 10's
  block-power files (n_detect under the three δ, the gaps, the threshold shifts);
- the `nosmalln` and `nobg` identities with the atlas's counterfactuals (126 of 126 cells and 224 of 231). In all 7
  unequal cells the cross-validation switched to the forced variant, which I checked by refit;
- all `labelnoise` numbers;
- the core against DFG alone, against `nets_best` and against the paired null. I recomputed `nets_best` from the
  network `.npz` files, and it equals `RESULTS.json` on all 126 targets;
- the core's compute;
- every leave-one-in n\*.

I also made 94 refits with my own instrumented copy of the frozen file. They cover all 38 cells in `refits.json` and
56 more, and all 94 reproduce their result file's test error and FLOP count bit for bit. They confirm almost every
model description in the report.

**What needs correcting** (details in "Corrections" below):
- **Mechanisms read from refits:**
  - majpar at δ = 0.9: χ[x3,x4] does pass in round 1. The least-squares room is full.
  - f7_10 reaches 10% error through a modulated block at its n_detect, not "through characters before its block".
  - `strict` lowers one formula, not two.
  - rand1 has 5 relevant inputs, not one.
  - The characters attributed to the local class or to an extension also pass the global test.
- **Test arithmetic:**
  - K does not enter the linear or spectral block tests.
  - Under `labelnoise` the block test's effective threshold rises by 1/s² (1.98 for far9), not 1/s (1.4).
  - The P2 prediction rule uses a 0.45 floor, not "DFG alone's own error".
  - δ can change the cross-validation's choice at n = 16.
- **Denominators and scope:**
  - The `nosums` counts of 31 and 9 "higher" include the 3 lost targets.
  - The `nets_best` comparison is over 126 targets, not 138.
  - The 12 gains are not 12 formulas.
  - The unpaired null is 20–30 times the like-for-like paired null, not "about tenfold".
  - Under `lenient`, the targets whose n\* rises are first fitted at n = 32–256, not 32–64.
  - `refits.json` holds 38 refits, not 36.
  - par4 under `K3` is missed at 6 grid sizes, not 4.
  - The training sets do not come from the fit stream.
  - The list of post-hoc analyses is incomplete.

**Unsupported:**
- The "(paper, Table 1)" citation for h6_10.
- "loses exactly where a removed part has no substitute". Of the core's 26 clearly-higher targets, one part put back
  restores 13 and 2 in part. h5s2 is not restored by any part tried, and 10 were not tested.

## What I did (my own code paths; the scripts are listed at the end)

1. **Data and definitions.** I wrote my own n\* and ratio code, re-implementing `harness.nstar`. It equals the harness
   on every DFG-alone cell. I also wrote my own class, family and null summaries. I read the protocol's kwargs, seeds
   and target counts from all 71 Q5 and Q5b result files (12 ablations × 5 suites, and the core × 11).
2. **Refits.**
   - `make_myinstr.py` builds an instrumented copy of the md5-checked `dfg13.py`. It adds read-only recorder lines at
     fixed anchors (each asserted unique). They record, per round:
     - the noise level s;
     - every passing candidate and the first class whose test it passed;
     - the forced guess;
     - the linear block's T₁ and threshold;
     - the least-squares room;
     - every block search's T, threshold, projected statistic and acceptance.
     They also wrap `_block_search` to log its returns.
   - `myrefit.py` runs the evaluation's exact fit: `harness.train_data` and `test_data`, the fit stream
     `[fn_seed, seed, n, 77]`, `Permuted(DFG(readout="logit", **kw))`. It checks error and FLOPs against the result
     file. It reads the final model from the closure (features, weights, blocks, background), and computes each term's
     sd on the test set in original coordinates.
   - 94 distinct cells were refitted, and all 94 are identical to their result file. The paired-null check used the
     unmodified frozen module through `eval_dfg.make_learner`.
3. **Independent recomputations.**
   - P2 per seed, from each training set's ȳ.
   - Part 10's power files re-thresholded for each δ.
   - The atlas counterfactual files compared cell by cell.
   - `nets_best` from the network `.npz` files.
   - The core's FLOP and CPU figures.
   - The n\* of every leave-one-in file, after checking that each file's kwargs equal the core's kwargs plus the part
     put back.
   - `families.py` checked against `boolfuncs.py`, and the 54 sum-structured targets rebuilt from the suites and
     their 14 controls.
   - Fourier coefficients of rand1, mux, andxor and h6_10 by exhaustive enumeration.

## Findings by section

### §0 What was compared

- Confirmed:
  - the object, the kwargs and the seeds;
  - the 65 targets;
  - the paired null's numbers (seed 0: 1 moved, 10 nonzero, mean |ratio| 0.012; seeds 0–1: 3 moved, 19 nonzero,
    0.038);
  - the unpaired null (23 moved, 13 lower and 10 higher; seed 2 against seed 0 moves 26);
  - the original-stream check (I checked 3 other cells; 3 of 3 identical);
  - the family and class counts, and the difference from the 54 sum-structured targets (sym8 and sym9 in, f7_01 and
    fd_01 out).
- **Corrected:**
  - "all three come from the fit rng". The training sets come from `default_rng([fn_seed(t), seed])`.
  - "All 36 refits (36 of 36)" should be **38 of 38**.
  - "a change that does nothing to DFG's decisions still moves its path somewhere". A change that alters no decision
    gives a ratio of exactly 0. The null measures how far an arbitrary perturbation of the path moves n\*.

### §1 Which parts carry the results

- Confirmed: every table cell, every family value, the per-seed agreement (`nosums` 27/0/12 with seed means +0.91
  and +0.97; `strict` 4/1/24; `lenient` 3/1/22; `noblocks` 3/0/12; `noeig` 1/0/2; `nocomp` 0/0/5) and every value in
  the moved lists.
- Confirmed: "single grid steps on a single seed". Among the targets the δ-ablations move, the first grid size with
  error ≤ 0.1 moves by at most one step in every seed cell but one (lenient, +2).
- **Corrected (wording):**
  - Under `nosums`, 26 symmetric and mixture targets move (25 up, and thrsum down, a mixture).
  - The other 8 targets listed include maj9 (a halfspace) and thrsum. The character targets that move are rand3,
    parmaj, h6_05, fd_07, dnf3 and sparsepoly. The largest of them, rand3, is a random formula, a kind the sentence
    does not name.
- **Unsupported:** "(paper, Table 1)". In `paper_dfg` Table 1 is the dictionary, and in the Part 10 paper it is the
  headline table. The h6_10 fact is in `paper_dfg`'s Table 4 (`tab:status`, protocol.tex).

### Short answer

- **Corrected:** `nosums` "+0.91 over the 59 … (31 clearly higher, 2 lower)". 28 of the 59 are clearly higher; the 3
  newly never learned make it 31. "6 of 12 still learned, 9 higher": DFG alone learns 9 of the 12, so `nosums` keeps
  6 of 9, all 6 higher.
- **Corrected:** `nosmalln` is not mainly "on mixtures". Only one mixture moves (fd_04), and the family mean is +0.05.
  Its 10 movers are 3 compositions, 3 formulas, par2, rand2, fd_04 and sym7.
- **Corrected:** "about tenfold". The unpaired null is single-seed against single-seed. Like for like (one seed), it
  moves 23 targets against 1, with mean |ratio| 0.339 against 0.012, about 20–30 times. Against the two-seed paired
  null the factor is 8–9.
- The reading "removable" is labelled Numerical. The counts are numerical, the reading is Heuristic. Mean |ratio| of
  `noeig`, `nocomp`, `noweighted`, `lsread` and `K3`: 0.026, 0.043, 0.020, 0.032, 0.075.

### §2 The test or the search

- **Parities.** Confirmed: n_thr and its shifts, and the predicted against measured ratios (+0.980/+1.004,
  +0.196/+0.208, −0.789/−0.792, 0/0). Two corrections:
  - **The rule.** Where the test fails, the code predicts max(DFG alone's error, 0.45), not "DFG alone's own error".
    Applied as written, the rule predicts 0 for par3 and par4 under `strict`. With 0.5 in place of 0.45 the
    predictions are +1.00 and +0.20.
  - **The n = 16 cells.** δ can change the cross-validation's choice there. For par4, seed 1, `lenient` takes the
    forced variant (held-out errors 8/2) where DFG alone keeps the default (7/2). The error is 0.498 against 0.515,
    so n\* is unaffected.
- **Other character targets.**
  - Confirmed: the n_glob multipliers; the 8 targets that `strict` raises, the 3 it lowers and the class mean; the
    stair5, rand3 and sparsepoly cells; the `lenient` counts; the linear block's thresholds; the errors-by-n figures.
  - Confirmed: the majpar refits at δ = 0.1 and 10⁻⁴, the andxor seed-1 errors, and every detail of the f7_02 refits.
  - The `lenient` mechanism is confirmed by 16 more refits. The linear block enters under δ = 0.9 but not under 0.1 in
    mux, fd_00, dlist5, h6_05 and majpar. andxor and f7_02 change through the choice of variant.
  - **Corrected:** majpar at δ = 0.9. χ[x3,x4] *passes* the round-1 global test (z = 1.03). The fit stops because
    least squares is limited to min(256, n/2) = 32 features. The constant, χ[x1,x2] and the linear block's 30
    characters already fill them.
  - **Corrected:** "first fitted at n = 32–64". The first fits are at 32–256: 8 of the 16 seed cells at 32–64, 5 at
    128 and 3 at 256. They are the forced variant's in 11 of 16.
  - **Corrected:** "lowers n\* under strict on two formulas". Only f7_02 is a formula. The other two character targets
    `strict` lowers are compositions (andxor, mux), and they were not refitted.
- **Halfspaces.** Confirmed, and the refits show the projection rule at work. At δ = 0.1 the exact 13-input block of
  f7_01 is found in round 0 at T/thr = 1.16. Once χ[x7] has passed, it fails the projected test (107.3 < 110.4). One
  detail: at δ = 0.1 the linear block adds the other 29 inputs.
- **Symmetric and mixture targets.**
  - Confirmed: the threshold shifts (+0.197 to +0.295, median +0.255; −0.069 to −0.110), the class means, the 8
    targets whose n_detect moves, the 7 gaps ≥ 1 with their n\* changes, the 23/18/−0.20 split and "all but 5".
  - **Corrected:** "Their 10% point is reached at the first grid point where the block passes or earlier". That holds
    for the 18 with n\* ≤ n_detect, not for h6_07, h6_10, h6_11, f7_07 and f7_09, which lie 0.36–0.80 doublings
    beyond n_detect.
  - **Corrected:** "fd_08, fd_11 and f7_10 reach 10% error through characters before their block". Refits at each
    seed's first fit:
    - fd_08 (its gate characters, or the 2-input gate block (x12+x13)) and fd_11 (χ[x10] with spectral features) do.
    - f7_10 does not. At n = 128, its n_detect, both seeds hold the modulated block χ[x6]·|x1+…+x5| (0.64 of the
      model's sd), as ATLAS.md §1.9 also says.
  - **Corrected (evidence):** the heuristic that the block is admitted far above its threshold cites par4 under `K3`,
    a parity. The sum targets' own figure is Part 10's: a median of 2.3 times the threshold at n_struct, range
    0.89–74.

### §3 The degree-4 search

- **Confirmed:**
  - every par4 error by n and the three fitted models (T/thr 9.004, 34.468 and 70.937; shares 0.609 and 0.404);
  - the four empty cells' 0.13–0.45;
  - mux and andxor (the same errors at every n, the same models at n = 64, the structure at n = 256);
  - the rand1 models and their reading ("K, not the degree-4 search": χ[x1] has z = 1.01 at K = 3 and about 0.99 at
    K = 4).
- **Corrected (the K arithmetic):** "K enters every test". It enters the character and sum-block thresholds. The linear
  block's χ² test and the spectral edge use ln(1/δ) only, so they do not change under `K3`. In the core both blocks
  are absent, so there the statement holds.
- **Corrected (where the search misses):** par4 is also missed at n = 64 and 128. The true folded block on a parity's
  inputs has T = n against a threshold of 56.9, so it would pass from n = 64 on; the search finds it at 3 of those 9
  grid sizes.
- **Corrected (the rand1 inputs):** "(30 degree-1 characters, one relevant)". rand1 has 5 relevant inputs, 3 of them
  with degree-1 weight (x1, x3, x5, ±0.375).
- **Corrected (attribution):** the refits name the class whose test gave the largest score as "the class that admitted
  it". In both mux refits at n = 256, χ[x1,x2,x3] and χ[x3,x4] also pass the round-1 global test. So "from the local
  class" and "from the two-input extension of χ[x1]" do not show that composition is needed.

### §4 Small-n machinery and background

- Confirmed: every number, the list of lost first fits, the atlas means, and the f7_11 refit.
- For `nobg`, own refits show that in all 7 unequal cells `nobg` takes the forced variant where DFG alone keeps the
  default.
- 47 of DFG alone's 62 seed-0 n\* lie in [64, 512].
- Detail: at n ≤ 512 the always-default counterfactual and `nosmalln` differ only in the degree-6 subsample (73 against
  min(n, 147) rows).

### §5 Tests scaled to the residual

- Confirmed: all numbers, and the rand3 and far9 refits.
- **Corrected:** with s = 1, the character and spectral thresholds are 1/s = 1.41 times higher for far9. But far9's
  block is admitted by the block test, whose statistic is divided by s², so its effective threshold rises 1/0.711² =
  1.98 times (T/thr goes from 1.52 to 0.77). "Sets s = 1 in every threshold" should say that s also normalises the
  block and linear-block statistics.
- Confirmed: the THEORY P3c citation (class medians 3.25, 3.27, 4.98 and 19.2) and the ORDER.md citation.

### §6 The core DFG

- Confirmed: the definition, every number against DFG alone, the 54 targets moved against the null's 8, every number
  against `nets_best`, the compute (0.0935, 0.1498 and 0.4999; 2302 s and 9058 s), every leave-one-in n\*, the par4
  and par5 learned cells and refits, and the thr30, h6_10 and sym8 refits.
- Details: with K = 4 back, fd_11 goes from 61 to 62. DFG alone's thr30 model also holds χ[x3,x19,x22].
- **Corrected:** "Over the 138 targets … −1.74 against nets_best". That comparison is over the 126 targets with
  network runs (122 both reach).
- **Corrected:** "12 small formulas learned at n = 16–64". 8 of them are formulas. and3 is a halfspace, and f7_11,
  fd_02 and fd_11 are mixtures. The core learns h5rf0 at n\* = 164.
- **Unsupported:** "loses exactly where a removed part has no substitute". Of the 26 targets clearly higher in the
  core:
  - **Restored by one part put back (13):** par4, rf17, poly4 and par5; thr20, maj15, maj21, maj9, thr10 and f7_01;
    h6_10 and f7_09; sym8.
  - **Restored in part (2):** thr30 (192 against 158) and h5t0 (146 against 112).
  - **Not restored by any part tried (1):** h5s2.
  - **Not tested (10):** h5rf1 +0.60, h6_03 +0.59, rf01 +0.51, mux11 +0.42, rf19 +0.39, h6_07 +0.35, rmaj9 +0.32,
    thrsum +0.32, fd_00 +0.29, rand3 +0.26.

  Two of the core's moves are at the paired null's level: h6_07 moves +0.40 and sym8 +0.69 in the null.

### Labels (post hoc)

The protocol fixes the 12 runs, their pooled comparison and the test-or-search question. These were also chosen after
the results were read, and are not on the report's post-hoc list:
- the P2 predictions, including the 0.45 floor and the n = 16 rule;
- the block-power re-thresholding;
- the per-seed agreement;
- the errors-by-n tables.

## Corrections (proposed replacement text)

1. §0 Pairing: "The training sets come from `default_rng([fn_seed(t), seed])` (`harness.train_data`); the column
   permutation and the folds come from the fit rng `default_rng([fn_seed(t), seed, n, 77])`."
2. §0 Two nulls: "A change with no systematic effect still perturbs DFG's path once it alters any decision; the paired
   null measures how far such a perturbation moves n\*."
3. §0 Refits: "All 38 refits … (38 of 38)."
4. Short answer, `nosums`: "+0.91 over the 59 both learn (28 clearly higher, 2 lower), and 3 more never reach 10%
   (31 clearly higher in all); symmetric targets +2.78 over the 6 still learned (of the 9 DFG alone learns; all 6
   clearly higher)."
5. Short answer, next parts: "`labelnoise` mainly on formulas and mixtures, `nosmalln` on compositions and formulas (3
   targets each) and single targets of four other families."
6. Short answer, null: "… overstates it about 20–30-fold against the like-for-like one-seed paired null (23 against 1
   target moved; mean |ratio| 0.339 against 0.012), 8–9-fold against the two-seed paired null."
7. §1 What moved, `nosums`: "the 25 symmetric and mixture targets that go up, thrsum (−0.66, a mixture), maj9 (+0.28,
   a halfspace) and six character targets: rand3, parmaj, h6_05, fd_07, dnf3, sparsepoly."
8. §1: replace "(paper, Table 1)" with the status table (paper Table 4) or PROTOCOL.md.
9. §2 P2 rule: "error 0 where the test passes, max(DFG alone's error, 0.45) where it fails."
10. §2 n = 16: "The n = 16 cells can change with δ (par4, seed 1, `lenient`), but they stay at about 0.5 error (0 for
    par2), so they do not move n\*."
11. §2 `lenient`: "The higher ones are first fitted at n = 32–256 (half of the seed cells at 32–64), where DFG alone's
    first fit is the forced variant's in 11 of 16."
12. §2 majpar at δ = 0.9: "In round 1 χ[x3, x4] passes its test, but the constant, χ[x1, x2] and the linear block's 30
    characters already fill the n/2 = 32 features least squares allows, so the fit stops: error 0.341."
13. §2: "The same machinery lowers n\* under `strict` on one formula, f7_02 (and on two compositions, andxor and mux,
    not refitted)."
14. §2 f7_01: "χ[x7], admitted by its own test, and the linear block on the other 29 inputs."
15. §2 sum targets: "For the 18 at or below n_detect, the 10% point is reached …"; and "fd_08 and fd_11 reach 10% error
    through the gates' characters before their block; f7_10 reaches it at its n_detect, through χ[x6] and the
    modulated block χ[x6]·|s|."
16. §2 heuristic: cite the sum targets' own margins (Part 10: a median of 2.3 times the threshold at n_struct, range
    0.89–74), not par4 under `K3`.
17. §3, the short answer and §6: "every character and sum-block test is 0.29 nats more lenient; the linear and spectral
    block tests do not depend on K." This holds unchanged for the core, which has neither block.
18. §3 par4: "is not found at 64, 128, 256, 1024, 8192 or 16384, although from n = 64 on it would pass."
19. §3 mux and §5 rand3: state the attribution convention ("the class whose test gave the largest score; the round's
    global test also admits χ[x1,x2,x3], χ[x3,x4] and χ[x5]").
20. §3 rand1: "(30 degree-1 characters; 5 of the inputs are relevant, 3 with degree-1 weight)."
21. §5: "With s = 1 the character and spectral thresholds are 1.4 times higher, and the block test's statistic falls by
    1/s² = 2 (far9's block: 1.52 → 0.77 of its threshold)."
22. Short answer §6: "… −1.74 against `nets_best` over the 126 targets with network runs (111 better / 9 worse, 122
    both reach) …"
23. Short answer §6: "The gains (12 targets: 8 small formulas, and3 and three mixtures; 11 learned by the core at
    n = 16–63) …"
24. Short answer §6: "The core's largest losses are where a removed part has no substitute: one part put back restores
    13 of its 26 clearly-higher targets and 2 in part; h5s2 is unexplained and 10 were not tested."
25. Labels: add the P2 predictions, the block-power analysis, the seed agreement and the errors-by-n tables to the
    post-hoc list.

## Omissions

1. **f7_10.** f7_10 = [x1+…+x5 + 2x6 ≤ −1] is a halfspace by `families.py`'s own rule ("a threshold of an unweighted or
   weighted sum with one accept boundary"). It is classed as a mixture, following ATLAS.md §1.9. As a halfspace it
   would move `strict`'s halfspace mean from −0.23 to −0.17.
2. **The attribution convention** (largest score, not first or only passing class) is not stated. It matters for the
   reading that "the composition classes reach" degree-4 structure.
3. **par4 under `K3`.** It is also missed at n = 64 and 128, where it would pass: 3 of the 9 grid sizes from 64 on.
4. **h6_10.** DFG alone's block at n = 256 is |s + 3x13|, while the target is [|s − 3x13| > 1]: the relative sign is
   wrong. The best function of |s + 3x13| has error 0.0195 (exact), so the 0.017 is that block's irreducible error.
   Part 10's paper noted the same for v3's member. The leave-one-in conclusion is unaffected.
5. **"Share" is used two ways.** It is an absolute sd for mux (0.51) and par4 (0.61), but a fraction of the model's sd
   for h6_10 (0.96; absolute 0.85).
6. **No significance assessment.** The "removable" and "carry" readings are counts against a null that moves 1 target
   (one seed) or 3 (two seeds). So `lsread`'s and `K3`'s 3 moves on one seed cannot be told from the null. `nosums` and
   the core's 54 against 8 are clear.
7. **The core's untested losses.** §6 does not say that 10 of the core's 26 clearly-higher targets were not examined
   and that h5s2 is not restored by any part tried.
8. **A second cost of the linear block.** The majpar refit shows it: at small n, its 30 characters use up the n/2
   least-squares room, so a character that passes in the next round cannot enter.
9. **Status labels in the short answer.** Interpretive statements are labelled Numerical.
10. **The paper repeats several flagged wordings** (`paper_dfg/sections/ablations.tex`): line 7 (the null's
    rationale), line 70 (majpar at δ = 0.9: "then nothing passes"), line 81 ("every test becomes 0.29 nats more
    lenient"), line 113 (rand3's "two local characters") and line 114 (far9: "thresholds are 1.4 times higher").

## Reproduction

The scripts are in the session scratchpad,
`/tmp/claude-0/-home-user-AI-works/addd33f6-5c52-5bee-997e-3f98d4e90609/scratchpad/dfgpaper/verify_abl/`:

| script | what it does |
|---|---|
| `v_common.py` | Own n\* (checked against `harness.nstar`), ratio, summary and pairing code. |
| `v_sec1.py`, `v_seeds.py` | §1 table, classes, families, nulls, moved lists; per-seed agreement. |
| `v_p2.py` | P2 thresholds and the parity predictions under three δ (three failing-cell rules). |
| `v_block.py` | Part 10's power files re-thresholded: n_detect, gaps, threshold shifts. |
| `v_sec2_files.py`, `v_errsn.py` | §2 cells from the result files; errors by n for five ablations. |
| `v_sec4.py`, `v_variants.py` | Atlas counterfactual identities; variant chosen in the 7 `nobg` cells and in the `lenient` first fits. |
| `v_sec6.py`, `v_leavein.py` | Core against DFG alone, the paired null on 138, `nets_best` from the `.npz` files, compute; leave-one-in n\*. |
| `v_reperm.py` | 3 original-stream cells and 33 paired-null cells re-run with the frozen module. |
| `make_myinstr.py`, `myrefit.py`, `batch_refits.py` | Own instrumented copy, refit and model reader; 44 refits (log `batch_refits.log`). |
| `v_lenlin.py`, `v_misc.py` | Linear block in `lenient` cells; fd_08, fd_11 and f7_10 first fits; grid-step shifts; where n\* lies. |
| `write_json.py` | Writes `VERIFY_ABLATIONS.json`. |
