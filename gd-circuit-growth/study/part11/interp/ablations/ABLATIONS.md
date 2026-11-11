# What DFG v1.3's parts do: the ablations and the core DFG (Part 11, Q5 and Q5b)

Analysis of the 12 pre-registered ablations of **DFG v1.3 run alone** (PROTOCOL.md, Q5) and of the post-hoc **core DFG**
(PROTOCOL.md, addendum of 3 November 2026). The object is the frozen file `part10/hyb_portfolio3/dfg13.py` (md5
`69cabe5c50345cb24079198ed52b562f`) run as `DFG(readout="logit", **kw).fit` inside `harness.Permuted`
(`part11/eval_dfg.py`); every ablation changes constructor arguments only. Written 3 November 2026. Checked by an
independent verifier the same day; its corrections are applied below, and the next section lists them.

Labels: **Numerical** = computed from a file named next to it; **Heuristic** = my reading. A reading of numerical counts
against a null ("carry", "removable") is Heuristic: no significance test is made (§1). **Post hoc** marks everything
that was not fixed by the protocol: the core run itself, the paired null, the leave-one-in runs, the refits, every
grouping by family, the P2 predictions of §2 (with their 0.45 floor and their n = 16 rule), the re-thresholding of Part
10's block statistics, the per-seed agreement and the errors-by-n tables. Counts carry their denominators.

**Files** (this folder). [`ablations.py`](ablations.py) computes every number below from the result files and writes
[`ablations.json`](ablations.json) and [`tables/by_family.md`](tables/by_family.md); [`families.py`](families.py) assigns
the 138 targets to the atlas's nine groups; [`perm_null.py`](perm_null.py) makes the paired null
(`results/toy__dfg13-reperm__<suite>.json`); [`leavein.py`](leavein.py) makes the leave-one-in runs from the core
(`results/leavein/`); [`refit.py`](refit.py) refits single cells and reads the model, with the class that admitted every
feature (`results/refits.json`; the refits made when the verification was applied are in `results/refits_verif.json`,
16 pairs of them by [`lenient_first_fits.py`](lenient_first_fits.py), summary `results/lenient_first_fits.json`). The
pre-registered results are `part11/results/toy__dfg13-<tag>-perm__<suite>.json` (Q5) and
`toy__dfg13-core-perm__<suite>.json` (Q5b); `part11/compare_dfg.py` summarises them in RESULTS.md (Q5, Q5b).

## Verification

An independent agent verified this report on 3 November 2026: [`VERIFY_ABLATIONS.md`](VERIFY_ABLATIONS.md), structured
as [`VERIFY_ABLATIONS.json`](VERIFY_ABLATIONS.json). It checked 75 claims (49 confirmed, 24 corrected, 2 unsupported)
and listed 10 omissions, with its own code throughout: its own n\* (equal to `harness.nstar` on every DFG-alone cell),
ratio, class and null code; P2 per seed; Part 10's power files re-thresholded; the atlas counterfactual files compared
cell by cell; `nets_best` recomputed from the network `.npz` files (equal to RESULTS.json on all 126 targets); 33
paired-null cells and 3 original-stream cells re-run with the frozen module (all identical); and 94 refits with its own
instrumented copy of `dfg13.py` (all 38 cells of `refits.json` and 56 more), every one equal to its result file in test
error and FLOPs. Its verdict: no correction changes a headline conclusion; several change a mechanism or a denominator
that the paper repeats.

How the corrections were applied. Each was checked against the stored files, the code of `dfg13.py` or a refit before
it was applied. The numbers they add are computed by the re-run `ablations.py`, under the new key `verification` of
`ablations.json` (every earlier value of `ablations.json` and `tables/by_family.md` is unchanged), and by 42 new refits
in `results/refits_verif.json`, all equal to their result files in test error and FLOP count: DFG alone and `lenient`
at the 16 first fits of the 8 character targets `lenient` raises (`lenient_first_fits.py`), par4 under `K3` at n = 64
and 128, the first fits of fd_08, fd_11 and f7_10 (seeds 0, 1), and par4 at n = 16, seed 1, for DFG alone and
`lenient`. Where a number is my recomputation and not the verifier's, the item says so.

**Confirmed, unchanged** (49 claims): the object, the kwargs, the seeds and the 65 targets; the unpaired null and the
paired null on 65 and on 138 targets, and the original-stream check; the family and class counts and the difference
from the 54 sum-structured targets; every cell of §1's table, every family and per-seed number and every value in the
moved lists; "single grid steps on a single seed"; P2's n_thr and its shifts, the parities' predicted and measured
ratios and first-pass grid sizes; the n_glob multipliers; the `strict` and `lenient` counts on the character targets,
the stair5, rand3 and sparsepoly cells, andxor's seed-1 errors, the majpar refits at δ = 0.1 and 10⁻⁴ and every detail
of the f7_02 refits; the linear block's thresholds; the errors by n; the halfspace numbers and the f7_01 refits; the
block-power threshold shifts, the class means, the targets whose n_detect moves and the 7 targets a doubling or more
beyond n_detect; the TOY_INTERP.md citation; the par4 errors and models under `K3`, χ[x1..x4] passing at n = 64 with the
degree-4 search, mux and andxor; the rand1 models and their reading; the `nosmalln` and `nobg` identities (126 of 126,
224 of 231; in all 7 unequal cells the cross-validation switched to the forced variant), the lost first fits, the atlas
means and the f7_11 refit; every `labelnoise` number and the rand3 and far9 refits; the THEORY.md and ORDER.md
citations; the core's definition, its numbers against DFG alone, against the paired null and against `nets_best`, its
compute, every leave-one-in n\*, the par4 and par5 cells and refits, the thr30, h6_10 and sym8 refits and the gains'
attributions; the ablation suites' one 4-parity and largest halfspace (13 inputs).

**Corrections applied** (old → new; "claim" and "omission" number VERIFY_ABLATIONS.json's lists from 1):
1. Pairing (§0; claim 2). "all three come from the fit rng default_rng([fn_seed(t), seed, n, 77])" → the training sets
   come from `harness.train_data`, default_rng([fn_seed(t), seed]); the column permutation (`Permuted`) and then the
   folds (rng.permutation(n) % F, dfg13.py line 559) come from the fit rng. All three are still shared with DFG alone.
   (`perm_null.py`'s docstring said the same and is corrected.)
2. The paired null's rationale (§0; claim 6). "a change that does nothing to DFG's decisions still moves its path
   somewhere" → a change that alters no decision gives a ratio of exactly 0; a change with no systematic effect still
   perturbs DFG's path once it alters any decision, and the paired null measures how far an arbitrary perturbation
   (another column order, other folds) moves n\*: a proxy for the noise part of an ablation's effect, not a derivation.
3. Refits (§0; claim 8). "All 36 refits … (36 of 36)" → 38 of 38 (the two core par5 cells were added after the count
   was written); with `refits_verif.json`, 80 of 80.
4. `nosums` in the short answer (claim 17). "+0.91 … over the 59 … (31 clearly higher, 2 lower)" → 28 of the 59 are
   clearly higher (2 lower), and 3 more are never learned, 31 clearly higher in all; "symmetric targets (6 of 12 still
   learned, 9 higher)" → DFG alone learns 9 of the 12 (the other 3 are residue classes mod 3, which neither DFG alone
   nor any ablation learns);
   `nosums` keeps 6 of the 9, all 6 clearly higher, and loses 3 (`verification.higher_finite`, `nosums_symmetric`).
5. The next parts in the short answer (claim 18). "come next, on formulas, compositions and mixtures" → `labelnoise`
   mainly on formulas (+0.33) and mixtures (+0.15); `nosmalln` on compositions and formulas (3 targets each) and on one
   target each of four other families (par2, rand2, fd_04, sym7); its mixture mean is +0.05.
6. The unpaired null in the short answer (claim 19). "overstates the noise of a paired comparison about tenfold" →
   about 20–30-fold against the like-for-like one-seed paired null (23 targets moved against 1; mean |ratio| 0.339
   against 0.012, 28 times), and 8–9-fold against the two-seed one (23 against 3; 0.339 against 0.038, 8.8 times)
   (`verification.null_ratio`).
7. What `nosums` moves (§1; claim 14). "all 25 symmetric and mixture targets that move, and rand3 … thrsum −0.66. The
   character targets that move are of the kinds …: parmaj, formulas, maj9" → 26 symmetric and mixture targets move (25
   up; thrsum, a mixture, down), maj9 (+0.28) is a halfspace, and the six character targets that move are rand3,
   parmaj, h6_05, fd_07, dnf3 (up) and sparsepoly (down). The largest, rand3, is a random formula, a kind the sentence
   did not name; the atlas found random formulas, too, encoded in part by blocks (ATLAS.md §1.7), and rand3's model at
   n = 128 holds five modulated blocks (§5).
8. The h6_10 citation (§1; claim 15, unsupported). "(paper, Table 1)" → the paper's status table (`tab:status`,
   paper_dfg/sections/protocol.tex: "weighted blocks were designed after v2's failure on h6_10").
9. "Numerical" on readings (short answer; claim 16, omission 9). "Three parts carry …" and "Four parts are removable …
   (Numerical)" → Heuristic readings of numerical counts; no test separates `lsread`'s or `K3`'s 3 moves on one seed
   from the one-seed null's 1 (omission 6). The removable parts' mean |ratio| is now given against the like-for-like
   null: 0.026 and 0.043 for the two-seed `noeig` and `nocomp` (null 0.038), 0.020, 0.032 and 0.075 for the one-seed
   `noweighted`, `lsread` and `K3` (null 0.012).
10. The P2 rule (§2; claim 22). "error 0 where the test passes; DFG alone's own error where it fails" → max(DFG alone's
    error, 0.45) where it fails, as `ablations.py` computes it (applied as written, the rule would predict +0.00 for
    par3 and par4 under `strict`, because DFG alone's error is 0 in the cells where only the stricter test fails; the
    docstring of `parity_prediction` is corrected).
11. The n = 16 cells (§2; claim 23). "the cross-validation's choice of the forced variant does not depend on δ" → it
    can: par4, seed 1, under `lenient` takes the forced variant (held-out errors 8 / 2) where DFG alone keeps the
    default (7 / 2), error 0.498 against 0.515 (refits, `refits_verif.json`); every n = 16 cell stays near 0.5 (0 for
    par2), so n\* does not move.
12. Where `lenient` raises n\* (§2; claim 26, and the details of claim 27). "first fitted at n = 32–64, where DFG alone's
    first fit is often the forced variant's" → first fitted at n = 32–256 (8 of the 16 seed cells at 32–64, 5 at 128,
    3 at 256), where DFG alone's first fit is the forced variant's in 11 of 16; under δ = 0.9 the linear block enters
    where it did not in 8 of the 16 cells (majpar, mux and dlist5 on both seeds, fd_00 seed 0, h6_05 seed 1) and the
    variant choice changes in 7; andxor and f7_02 move through the choice alone (`lenient_first_fits.json`; my 32
    refits reproduce the verifier's). "The most δ-sensitive test is the linear block's" now says: under `lenient`
    (threshold × 0.66, against × 0.74 for a degree-1 character); under `strict` a degree-1 character's test moves more
    (× 1.81 against × 1.59).
13. majpar at δ = 0.9 (§2; claim 29, omission 8). "nothing passes in round 1: error 0.341" → in round 1 χ[x3, x4]
    passes its test (z = 1.03), but the constant, χ[x1, x2] and the linear block's 30 characters already fill the 32
    features least squares allows at n = 64 (min(256, n/2)), so the fit stops (`refits.json` records the round: one
    candidate passed, room 0). §2 now names this second cost of the linear block at small n.
14. `strict` lowering n\* (§2; claim 31). "on two formulas" → on one formula, f7_02 (refitted), and on two compositions,
    andxor and mux (not refitted).
15. The f7_01 refit (§2; claim 34, a detail). "the linear block (30 degree-1 characters)" → the linear block on the
    other 29 inputs; the exact 13-input block is found in round 0 at 1.16 times its threshold and fails the projected
    test (0.97) once χ[x7] has passed.
16. Sum targets near n_detect (§2; claim 39). "Their 10% point is reached at the first grid point where the block passes
    or earlier" → for the 18 at or below n_detect; the other 5 (f7_07, h6_11, h6_07, h6_10, f7_09) lie 0.36–0.80
    doublings beyond it (`verification.block_gap_split`).
17. fd_08, fd_11, f7_10 (§2; claim 41). "reach 10% error through characters before their block" → fd_08 and fd_11 do
    (fd_08 at n = 64 through its two literals' characters, or the block (x12 + x13); fd_11 at n = 128 through χ[x10]
    and spectral features); f7_10 reaches it at n = 128, its n_detect, through χ[x6] and the modulated block
    χ[x6]·|x1 + … + x5| (0.64 of the model's sd; both seeds), as ATLAS.md §1.9 also says (6 refits).
18. The margin cited for the sum targets (§2 heuristic; claim 42). "(par4 under K3, §3: 9 to 71 times)", a parity's
    folded block → the sum targets' own margin: on the 22 pure symmetric targets found, Part 10 measured a median of 2.3
    times the threshold at n_struct (range 0.89–74).
19. K (§3, short answer, §6; claim 44). "K also enters every class's union bound …, so every test is 0.29 nats more
    lenient" → K enters the character tests (ln(4K·N/δ)) and the sum-block tests (4K in tk), which `K3` makes 0.29 nats
    more lenient; the linear block's χ² test and the spectral edge use ln(1/δ) only and do not change. In the core,
    which has neither, every test is 0.29 nats more lenient.
20. Where `K3` misses par4 (§3, short answer; claim 47, omission 3). "In the four empty cells (256, 1024, 8192, 16384)"
    / "not found at 256, 1024, 8192 or 16384" → also not found at n = 64 and 128 (best candidates 0.21–0.29 of their
    thresholds, two new refits), although the true folded block, whose statistic on the round-0 residual is T = n
    against a threshold of 56.9, would pass at every n ≥ 64: the search finds it at 3 of these 9 grid sizes. The
    "Heuristic" label on "would pass at every n ≥ 64" is now Numerical (the threshold is computed in §3).
21. The class "that admitted" a feature (§0, §3, §5; claim 50, omission 2). The refits record the class whose test gave
    a character its largest score in that round (DFG's own candidate dictionary keeps the largest z; the recorder keeps
    its class), not the first or only class to pass. χ[x1, x2, x3] and χ[x3, x4] in the mux refits at n = 256 (DFG
    alone: "local"; `K3`: χ[x1, x2, x3] from "the two-input extension") also pass that round's global test, as does
    χ[x5] in rand3's refit at n = 128. §0 states the convention; §3's reading no longer says that the composition
    classes are needed to reach mux's degree-4 structure.
22. rand1's inputs (§3; claim 51). "(30 degree-1 characters, one relevant)" → rand1 has 5 relevant inputs (x1, x3, x4,
    x5, x6), 3 of them with degree-1 weight (x1, x3, x5: ±0.375, by exact enumeration; my enumeration agrees).
23. `labelnoise` (§5; claim 57). "sets s = 1 in every threshold" → sets s = 1 in every test: s multiplies the character
    thresholds and the spectral edge (which rise by 1/s), and s² divides the block and linear-block statistics (whose
    effective thresholds rise by 1/s²).
24. far9 (§5; claim 60). "the thresholds are 1.4 times higher" → the character and spectral thresholds are 1/0.711 =
    1.41 times higher, and the block search's statistic is divided by 1 in place of s² = 0.51, so the folded block falls
    from 1.52 to 0.77 of its threshold (its projected test, in units of the projected residual's own variance, stays at
    1.52); nothing passes.
25. `nets_best` in the short answer (claim 66). "Over the 138 targets: … −1.74 against nets_best (111 better / 9
    worse)" → over the 126 targets with network runs (122 both reach; DFG alone 123).
26. The gains (short answer; claim 72). "12 small formulas learned at n = 16–64" → 12 targets: 8 small formulas (7
    random formulas and dlist8), and3 (a halfspace) and three mixtures (f7_11, fd_02, fd_11); the core learns 11 of them
    at n\* = 16–63 and h5rf0 at 164. Found while applying this: they are 12 of the core's 13 largest gains, not "the 12
    largest" (`leavein.py`'s comment): hrf0 (−0.75, the 11th) was not run and rand1 (the 13th) was
    (`verification.core_gains`).
27. "loses exactly where a removed part has no substitute" (short answer; claim 73, unsupported; omission 7) → its
    largest losses are where a removed part has no substitute: of the core's 26 clearly-higher targets, putting one part
    back (for h6_10 and f7_09, one pair) restores 13 and 2 in part (thr30, h5t0); no part tried restores h5s2, and 10
    were not tested (h5rf1, h6_03, rf01, mux11, rf19, h6_07, rmaj9, thrsum, fd_00, rand3; +0.26 to +0.60). Two of the
    core's moves are at the paired null's level (h6_07 +0.40, sym8 +0.69 in the null). §6 lists these
    (`verification.core_higher`).
28. Post hoc (labels; claim 75). Added to the list: the P2 predictions (with the 0.45 floor and the n = 16 rule), the
    block-power re-thresholding, the per-seed agreement and the errors-by-n tables.
29. f7_10's class (§0, §1, §2; omission 1). f7_10 = [x1 + … + x5 + 2x6 ≤ −1] is a halfspace by `families.py`'s own rule
    but is counted as a mixture, where the atlas puts it (§1.9). The grouping is kept, the exception is stated in
    `families.py` and §0, and the halfspace means it moves are given with it: with f7_10 counted as a halfspace,
    `strict` −0.23 → −0.17, `noblocks` −0.19 → −0.07, `labelnoise` −0.17 → −0.08, `nosums` +0.05 → +0.11; no other
    class mean moves by more than 0.05 (`verification.f7_10_as_halfspace`). So of the three halfspace gains only
    `strict`'s survives that choice.
30. h6_10's block (§6; omission 4). DFG alone's block at n = 256 is |s + 3x13| (s = x1 + … + x12), while the target is
    [|s − 3x13| > 1]: the relative sign is wrong. Recomputed by exact enumeration (2¹³ inputs): no function of
    |s + 3x13| has error below 156/8192 = 0.0190 (the verifier wrote 0.0195), and on the 4096 test inputs the best such
    function has exactly DFG alone's error, 0.0166. The leave-one-in conclusion is unaffected.
31. "Share" (§3, §6; claim 70, omission 5). A term's share is the sd of its contribution on the 4096 test inputs (the
    atlas's definition); mux's 0.51 and par4's 0.61 are such sds, h6_10's "0.96" was a fraction of the model's sd → sd
    0.85 (0.96 of the model's 0.88). Fractions are now marked as such.
32. Details inside confirmed claims: DFG alone's thr30 model at n = 512 also holds χ[x3, x19, x22] (claim 70); with
    K = 4 back fd_11 goes 61 → 62, not "unchanged" (claim 68); the background removes rf06's and f7_11's gains to within
    0.25, not wholly (27 against 31, 54 against 63; claim 71); rand3's DFG-alone fit also adds a spectral feature in
    round 4 (claim 59); `nosmalln` and the atlas's always-default refit differ at n ≤ 512 only in the degree-6
    subsample (73 against min(n, 147) rows).
33. The paper (omission 10): the flagged wordings of `paper_dfg/sections/ablations.tex` (the null's rationale, majpar's
    "then nothing passes", "every test becomes 0.29 nats more lenient", rand3's "two local characters", far9's
    "thresholds are 1.4 times higher") and the other statements above are changed in the paper (see "For the paper").

**Declined:** none. One value of VERIFY_ABLATIONS.md differs from my recomputation and is not used: the floor of a
function of h6_10's mis-signed block is 156/8192 = 0.0190, not 0.0195 (item 30).

**For the paper** (statements of this report that changed, in their new form; `paper_dfg/sections/ablations.tex` unless
named):
- Pairing: training sets from default_rng([fn_seed(t), seed]); column order and folds from the fit stream. The paired
  null measures how far an arbitrary perturbation (column order, folds) moves n\*.
- Refits: 38 in `refits.json`, 42 more in `refits_verif.json`, all equal to their result files.
- `nosums`: +0.91 over 59 (28 higher, 2 lower) and 3 lost; symmetric +2.78 over the 6 of DFG alone's 9 it keeps (all
  6 higher); the character targets that move up are rand3, parmaj, h6_05, fd_07, dnf3.
- `labelnoise` mainly on formulas and mixtures; `nosmalln` on compositions and formulas.
- The unpaired null: 20–30 times the one-seed paired null, 8–9 times the two-seed one (interp_dyn.tex says "about
  tenfold").
- "Removable": a Heuristic reading; one-seed runs against the one-seed null, two-seed against two-seed; no test.
- P2: n = 16 cells can change with δ but stay near 0.5.
- `lenient`: first fits at n = 32–256, forced in 11 of 16; the linear block enters in 8 of 16 cells; it is the most
  δ-sensitive test under `lenient` only (also interp_dyn.tex: "first fitted at n = 32–64").
- majpar at δ = 0.9: χ[x3, x4] passes in round 1 but the least-squares room is full.
- f7_01: the linear block on the other 29 inputs.
- Sum targets: the 10% point at or before the block's first passing grid point for the 18 at or below n_detect; fd_08
  and fd_11 through characters, f7_10 through its modulated block at n_detect.
- The block's margin once proposed: Part 10's median 2.3 times at n_struct, not par4's 9–71.
- `K3`: the character and sum-block tests are 0.29 nats more lenient; the linear and spectral ones do not depend on K.
- par4 under `K3`: missed at 64, 128, 256, 1024, 8192, 16384 although its block would pass from 64.
- mux: the extension's and local class's characters also pass the global test.
- rand1: 5 relevant inputs, 3 with degree-1 weight.
- `labelnoise`: s = 1 in every test; far9's block statistic is halved (1.52 → 0.77), the other thresholds × 1.41;
  rand3's round-2 characters (χ[x5], χ[x4, x5]) named.
- f7_10's class and the halfspace means with it counted as a halfspace.
- The core: −1.74 against `nets_best` over 126 targets (intro.tex, tab_headline); "largest losses" where a part has no
  substitute, 13 of 26 restored, 2 in part, h5s2 not, 10 untested (intro.tex, discussion.tex); the gains are 8
  formulas, and3 and 3 mixtures, 12 of the 13 largest; h6_10's share 0.85 and its mis-signed block.
- The verification status (discussion.tex, app_provenance.tex).

## Short answer

- **Three parts carry DFG's results on the ablation suites, and the sum blocks carry most** (Numerical counts, §1; the
  reading is Heuristic). Removing the sum blocks raises n\* by a mean of +0.91 doublings over the 59 of 65 targets both
  learn (28 of them clearly higher, 2 lower) and loses 3 more targets (band11, h6_01, f7_08; 31 clearly higher in
  all): on the symmetric targets +2.78 over the 6 it still learns of the 9 DFG alone learns (all 6 clearly higher, the
  other 3 lost), and +1.54 on the mixtures (21; 16 higher). The tests scaled to the residual (`labelnoise`, +0.14; 15
  higher, 5 lower; mainly formulas, +0.33, and mixtures, +0.15) and the small-n machinery (`nosmalln`, +0.12; 10
  higher, 0 lower; 3 compositions, 3 formulas and one target each of four other families) come next.
- **Four parts are removable on these 65 targets, one more nearly so** (a Heuristic reading of numerical counts, §1). A
  paired null, DFG alone refitted on the same training sets with another column order and other folds (post hoc),
  moves 1 of 65 targets beyond ±0.25 on seed 0 and 3 of 65 on seeds 0–1 (mean |ratio| 0.012 and 0.038). The
  eigenvector seeds (`noeig`: 1 target), the extension and local classes (`nocomp`: 4, two of which the null also
  moves), the weighted blocks (`noweighted`: 1) and the logistic refinement (`lsread`: 3) stay within or near that
  band; so does the degree-4 search (`K3`) except on the one pure 4-parity, par4 (+3.01). These are counts against one
  replicate of the null: no test separates the 3 moves of `lsread` or `K3` on one seed from the one-seed null's 1. The
  unpaired seed-vs-seed null of RESULTS.md moves 23 of 65 and overstates the noise of a paired comparison about 20–30
  times against the like-for-like one-seed paired null (23 targets moved against 1; mean |ratio| 0.339 against 0.012),
  8–9 times against the two-seed one (23 against 3; 0.339 against 0.038).
- **The test or the search** (§2). For parities the test sets the cost exactly: THEORY.md's P2 with δ moved predicts the
  measured n\* change under both settings to within 0.03 (par3 strict +0.98 against +1.00; par4 strict +0.20 against
  +0.21, lenient −0.79 against −0.79; par2 0, decided by the forced variant at n = 16). For other character targets a
  stricter test delays the first fit by about one grid step in 8 of 25 (as the +0.54 to +0.86 doublings of n_glob
  predict), but the lenient test is not its mirror: it raises n\* on 8 of 25, first fitted at n = 32–256 and in 11 of
  their 16 seed cells by the forced variant, through the linear block's lower threshold (33.8 against 51.2 on 30
  inputs; under δ = 0.9 it enters 8 of the 16 first fits that lacked it under δ = 0.1, and at n = 64 it can fill the
  least-squares room) and the small-n variant choice (changed in 7 of the 16). For the 33 symmetric and mixture
  targets both settings leave n\* in place (means +0.04 and +0.05; 7 and 5 moved): where n\* lies a doubling or more
  beyond the n at which the true block would pass its test (7 targets),
  strict moves n\* by at most 0.05, although it moves the block threshold by +0.20 to +0.30 doublings; the search, not
  the test, is binding. Halfspaces gain from a stricter test (−0.23; −0.17 if f7_10, a weighted threshold the atlas
  groups with the mixtures, is counted with them): fewer partial characters and a later linear block let the exact
  block in.
- **Without the degree-4 search, par4 is found only when the block search stumbles on its 4 inputs** (Numerical, refits;
  §3): the folded block |±x1±x2±x3±x4| passes at 9 to 71 times its threshold at n = 512, 2048 and 4096 (seed 0) and is
  not found at 64, 128, 256, 1024, 8192 or 16384, although the true folded block would pass its test at every n ≥ 64:
  the search finds it at 3 of these 9 grid sizes. On the other degree-4 targets (mux, andxor) blocks and lower-degree
  characters give the same errors at every n. K also enters the union bound of the character and sum-block tests, so
  `K3` also makes those 0.29 nats more lenient; the linear and spectral block tests do not depend on K.
- **The small-n machinery and the background are the atlas's counterfactuals, run** (Numerical, §4): `nosmalln`'s errors
  equal the atlas's always-default refits in 126 of 126 cells; `nobg`'s equal the fitted models without their
  background in 224 of 231 cells, and the other 7 are cells where the background changed the cross-validation's choice.
  The background helps at n = 16–32 and costs at 64–512, where most n\* lie (−0.10).
- **The residual scaling of the tests** (§5) is needed by the features admitted after the first round and by targets with
  biased labels (round 0's residual variance is 1 − ȳ²): with tests scaled to the labels, rand3 stops after its first
  character at n = 128 (error 0.317 against 0.049) and far9 admits nothing (0.181 against 0.006). Formulas +0.33,
  mixtures +0.15, halfspaces −0.17 (−0.08 with f7_10 counted as a halfspace).
- **The core DFG (post hoc) keeps DFG alone's results on these suites at a tenth of its FLOPs; its largest losses are
  where a removed part has no substitute** (§6). Over the 138 targets: +0.07 against DFG alone on the same seeds (28
  lower, 26 higher; par5 lost). Over the 126 targets with network runs: −1.74 against nets_best (122 both reach; 111
  better / 9 worse), where DFG alone is at −1.88 (123; 117 / 5). On the held-out dlheld7: −0.03 against DFG alone and
  −1.30 against nets_best. Leave-one-in runs restore 13 of the core's 26 clearly-higher targets and 2 in part: the
  degree-4 to 6 searches for parities with no lower-degree footprint (par4, rf17, poly4, par5; composition does not
  substitute), the linear block for dense halfspaces (thr20, maj15, maj21, maj9, thr10, f7_01; thr30 in part),
  weighted blocks and eigenvector seeds together for h6_10 and f7_09, the background for sym8 (through the
  cross-validation) and in part for h5t0. No part tried restores h5s2, and 10 of the 26 were not tested. The gains
  examined (12 of the 13 largest: 8 small formulas, and3 and three mixtures; 11 learned by the core at n\* = 16–63)
  come mostly from dropping the background (5 of the 12 fully, 3 in part), from dropping the linear block (and3; with
  the background, h4rf1) and from K = 3 without the degree-4 to 6 searches (h5rf0); two (h3rf0, dlist8) sit near 10%
  error over several doublings, where no single part decides.

## 0. What was compared, and how

**Pairing** (PROTOCOL.md, Q5). An ablation runs on the training sets of DFG alone (`harness.train_data`:
`default_rng([fn_seed(t), seed])`, first n rows) with DFG alone's fit rng `default_rng([fn_seed(t), seed, n, 77])`, from
which `harness.Permuted` draws the column permutation and DFG then the cross-validation folds; so the training sets,
column permutations and folds are DFG alone's. Its n\* is compared with DFG alone's n\* from the same seeds of DFG
alone's own runs: seeds 0 and 1 for `nosums`, `strict`, `lenient`, `noeig`, `noblocks`, `nocomp` (and the core), seed 0
for the other six. Ratio = log2(n\*_ablation / n\*_DFG alone): negative when the ablation needs less data, +inf when it
never reaches 10% test error where DFG alone does. 'Lower' / 'higher' = beyond ∓0.25, the infinite ratios included.
Means are over the targets both reach. The five ablation suites hold 65 targets: `designed` (21), `dlsymdev` (8),
`dlfamdev`, `dlheld6`, `dlheld7` (12 each); only `dlheld7` is held out for v1.3.

**Two nulls.**
- *Unpaired* (RESULTS.md, Q5): DFG alone's seed 1 against its seed 0, i.e. other training sets. It moves 23 of 65
  targets (13 lower, 10 higher), seed 2 against 0 moves 26.
- *Paired* (post hoc; `perm_null.py`): DFG alone refitted on the same training sets and test sets, with the fit rng
  `default_rng([fn_seed(t), seed, n, 77, 1])`, so with another column order and other folds and nothing else. The
  column order is irrelevant to the target and to DFG's tests (THEORY.md P2); it can matter through tie-breaking, the
  block search's orders and the folds. This is the comparison an ablation's difference should be read against. A change
  that alters no decision gives a ratio of exactly 0; a change with no systematic effect still perturbs DFG's path once
  it alters any decision, and the paired null measures how far such an arbitrary perturbation moves n\*: a proxy for
  the noise part of an ablation's effect, not a derivation of it. On the 65 targets (Numerical, `ablations.json`
  `nulls`): seed 0, mean +0.00, 1 moved (dlist5 +0.39), 10 of 65 ratios nonzero, mean |ratio| 0.012; seeds 0–1, mean
  −0.02, 3 moved (andxor −0.69, thrsum −0.66, h6_07 +0.40), 19 nonzero, mean |ratio| 0.038. The check that the loop is
  the evaluation's: with the original stream it reproduces 3 of 3 cells of the result file in test error and FLOPs.

**Families** (post hoc; `families.py`). Every target is assigned by hand, from its definition in `boolfuncs.py`, to one of
the atlas's nine groups (ATLAS.md §1), and to three coarse classes: *character targets* (parities, staircases, address /
data multiplexers, compositions of parities and majorities and polynomial thresholds, DNF / CNF / decision lists /
read-once formulas, random formulas; 71 of 138, 25 of the 65), *halfspaces* (majorities and thresholds of a weighted
sum, including the dictator, AND of 3 and an AND of two halfspaces; 13 and 7), and *symmetric and mixture targets* (a
function of one signed sum, alone or combined with a parity, a gate, a second sum or an inner term; 54 and 33). The
last class differs from the paper's 54 "sum-structured targets" by two in each direction: it adds sym8 and sym9, and
counts f7_01 and fd_01 (thresholds of an unsigned sum, as the atlas counts f7_01) as halfspaces. One target breaks the
stated rule: f7_10 = [x1 + … + x5 + 2x6 ≤ −1], a threshold of a weighted sum and so a halfspace by `families.py`'s rule,
is counted as a mixture, where the atlas puts it (§1.9; the blind family writes it as s + 2τ with a literal inner term).
Counted as a halfspace it would move four class means by more than 0.05, all of them the halfspaces': under `strict`
from −0.23 to −0.17, under `noblocks` from −0.19 to −0.07, under `labelnoise` from −0.17 to −0.08 and under `nosums`
from +0.05 to +0.11 (`verification.f7_10_as_halfspace` gives every cell; no other class mean moves by more than 0.05).

**Refits** (`refit.py`). A refit is the evaluation's fit of that cell, made with `calib/dfg13_instr.py` (the frozen file
with read-only recorder calls added; CALIB.md §0), so that every feature carries the class that admitted it and its
round. "The class that admitted it" is the class whose test gave the character its largest score in that round (DFG's
own candidate dictionary keeps the largest z, and the recorder keeps that z's class), not the first or only class it
passed: a character attributed to an extension or the local class can also pass the round's global test (χ[x1, x2, x3]
and χ[x3, x4] in the mux refits at n = 256, χ[x5] in rand3's at n = 128, §3 and §5). A term's *share* is the standard
deviation of its contribution to the model's output on the 4096 test inputs (the atlas's definition); a fraction of the
model's own sd is marked as such. All 38 refits in `results/refits.json` reproduce their run's result file exactly in
test error and FLOP count (38 of 38; asserted), and so do the 42 made when the verification was applied
(`results/refits_verif.json`, 42 of 42). In 4 cells (K3 par4 at 512, core thr30 at 512, core h6_10 at 256, DFG alone
mux at 256) the same fit made through `dfg_hooks.fit_toy_dfg` (`eval_dfg.make_learner` on the md5-checked frozen module)
gives the same test error, FLOP count and terms with the same shares (`results/refit_crosscheck.json`).

## 1. Which parts carry the results

Numerical (`ablations.json` `ablations`, `nulls`; the pooled rows equal RESULTS.md Q5). Cells: mean (lower / higher)
[both reach]; 'higher' includes the targets newly never learned.

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
+0.36 (0/1) [4], halfspaces +0.05 (0/1) [7], parities and the staircase 0. Of the symmetric group's 12, DFG alone learns
9 (the other 3 are the residue classes mod 3, which neither DFG alone nor any ablation or the core learns); `nosums` keeps 6 of the 9, all 6 clearly higher, and
loses band11, h6_01 and f7_08, so the 9 'higher' are those 6 and the 3 lost (`verification.nosums_symmetric`). Over all
65 targets the 31 'higher' are 28 of the 59 both learn and the 3 lost. `labelnoise`: formulas +0.33 (1/6), the
staircase +0.70, mixtures +0.15 (1/5), random formulas +0.19, compositions +0.11, symmetric +0.10 (0/1), halfspaces
−0.17 (2/0), parities 0. `nosmalln`: compositions +0.38 (0/3), parities +0.26 (0/1), random formulas +0.22, formulas
+0.15 (0/3), symmetric +0.11, mixtures +0.05, halfspaces −0.03.

**Per seed** (the six two-seed ablations; `ablations.json` `seed_agreement`). `nosums` moves 27 targets up on both seeds
and none in opposite directions (12 on one seed only); its seed means are +0.91 and +0.97. For `strict` 4 targets move
the same way on both seeds, 1 in opposite directions, 24 on one seed only; for `lenient` 3, 1 and 22; for `noblocks` 3,
0 and 12; for `noeig` 1, 0 and 2; for `nocomp` 0, 0 and 5. Most of the δ-ablations' movements are single grid steps on
a single seed.

**What moved** (beyond ±0.25):
- `nosums` (33): the 25 symmetric and mixture targets that go up (three of them, band11, h6_01 and f7_08, to never) and
  thrsum −0.66 (a mixture), maj9 +0.28 (a halfspace) and six character targets: rand3 +1.45, parmaj +1.00, h6_05 +0.73,
  fd_07 +0.56, dnf3 +0.28, sparsepoly −0.33. The character targets that go up and maj9 are of the kinds the atlas found
  encoded in part by blocks before their characters are all detectable: parmaj itself (two folded blocks, ATLAS.md
  §1.5), the formulas h6_05, fd_07 and dnf3 (the blocks of a clause or term, §1.6), rand3, a random formula (block
  encodings of the inputs after its first characters, §1.7; its model at n = 128 holds five modulated blocks, §5), and
  maj9 itself (its 9-input block, §1.4).
- `nosmalln` (10, all higher): majpar +0.97, mux +0.96, f7_02 +0.94, rand2 +0.90, par2 +0.79, dlist5 +0.39, sparsepoly
  +0.35, h6_03 +0.32, fd_04 +1.00, sym7 +1.00 (§4): 3 compositions (majpar, mux, sparsepoly), 3 formulas (f7_02,
  dlist5, h6_03) and par2, rand2, fd_04 and sym7.
- `nobg` (10): f7_11 −2.17, h6_05 −1.41, fd_02 −0.94, fd_11 −0.90, rand0 −0.89, dict −0.64, andxor −0.38; higher fd_04
  +1.01, rand2 +0.91, fd_00 +0.51 (§4).
- `noblocks` (10): and3 −0.83, h6_09 −0.74, rand1 −0.49, maj3 −0.44, fd_01 −0.40, sparsepoly −0.35; higher f7_10 +0.76,
  h6_03 +0.54, thrsum +0.36, fd_11 +0.29.
- `nocomp` (4): thrsum −0.66, andxor −0.61, f7_02 +0.46, fd_00 +0.35; the paired null moves andxor (−0.69) and thrsum
  (−0.66) too.
- `noeig` and `noweighted` (1 each): h6_10, +1.08 and +0.94, the target v1.3's weighted blocks were designed after (the
  paper's status table, `tab:status`; PROTOCOL.md).
- `lsread` (3): h6_05 −0.58, sparsepoly +0.32, h6_04 −0.31. `K3` (3): par4 +3.01, rand1 −1.06, f7_01 −0.32 (§3).

*Heuristic.* On the 65 targets of the ablation suites, DFG's results come from the sum blocks, with the residual scaling
of the tests and the small-n machinery as smaller contributors. The eigenvector seeds, the composition classes, the
weighted blocks, the logistic refinement and (but for one target) the degree-4 search can each be removed without a
change larger than an arbitrary perturbation of DFG's path produces, as far as counts against one replicate of the null
can tell. Read like for like, the two-seed `noeig` and `nocomp` have mean |ratio| 0.026 and 0.043 against the two-seed
null's 0.038, and the one-seed `noweighted`, `lsread` and `K3` 0.020, 0.032 and 0.075 against the one-seed null's 0.012
(`verification.mean_abs`); `lsread`'s and `K3`'s 3 moves cannot be told from the null's 1, while `nosums`' 33 (and the
core's 54 of 138 against the null's 8, §6) are clearly beyond it. The δ-ablations, the background and the linear and
spectral blocks move many targets, in both directions. "Removable" holds for these suites' target mix, and for one part
at a time: the core DFG (§6) removes them together.

## 2. The test or the search

THEORY.md P2 (corrected by its verifier): a k-parity χ_S *passes round 0's global test* exactly when
n(1 − ȳ²) > n_thr(k, d) = 2c² ln(4K·C(d, k)/δ), on the degrees searched on all n rows (at d = 30: degrees 1–2 at every
grid n, degrees 3–4 from n = 32); whether the final model holds χ_S also depends on the forced variant at small n. The
strict and lenient ablations move ln(1/δ) by +6.91 and −2.20 nats, so n_thr moves by +13.8 and −4.4 rows: at d = 30,
from 22.30 / 26.77 / 30.59 (k = 2, 3, 4) to 36.12 / 40.58 / 44.40 (strict) and 17.91 / 22.37 / 26.19 (lenient)
(`ablations.json` `parity_P2`).

**Parities: the test sets the cost, exactly** (Numerical; the prediction rule is post hoc). The prediction is P2 per
seed with each training set's own ȳ: error 0 where the test passes; max(DFG alone's own error, 0.45) where it fails (in
the cells where only the stricter test fails DFG alone's own error is 0, so the floor stands for the ~0.5 error of a
model without the parity: with no floor the rule would predict +0.00 for par3 and par4 under strict, with 0.5 in place
of 0.45 it predicts +1.00 and +0.20 under strict and −0.80 for par4 under lenient); at n = 16 DFG alone's measured
cell, since n_thr > 16 for every δ here. The n = 16 cells can change with δ: par4, seed 1, under `lenient` takes the
forced variant (held-out errors 8 / 2) where DFG alone keeps the default (7 / 2), error 0.498 against 0.515 (refits,
`refits_verif.json`); but every n = 16 cell stays near 0.5 (0 for par2), so they do not move n\*.

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
  at n = 32–256 (DFG alone's first grid n with error ≤ 0.1: 8 of the 16 seed cells at 32–64, 5 at 128, 3 at 256), and
  DFG alone's first fit is the forced variant's in 11 of the 16 (refits; `lenient_first_fits.json`). Under a more
  lenient δ the most sensitive test is the linear block's: its threshold on 30 inputs is 51.2 at δ = 0.1, 33.8 at 0.9
  and 81.7 at 10⁻⁴ (`linear_block_thr`), so lenient multiplies it by 0.66 against 0.74 for a degree-1 character
  (strict by 1.59, against a degree-1 character's 1.81). Refitted at the 16 first fits, the linear block enters under
  δ = 0.9 where it did not under 0.1 in 8 cells (majpar, mux and dlist5 on both seeds, fd_00 seed 0, h6_05 seed 1), and
  the cross-validation's choice of variant changes in 7 (majpar seed 1, andxor and f7_02 on both seeds, fd_00 and fd_07
  seed 1); andxor and f7_02 move through that choice alone. Refits of majpar at n = 64 (seed 0): with δ = 0.1 nothing
  passes in round 0, the forced variant adds χ[x1, x2] and then χ[x3, x4], and χ[x5, x6] passes its own test in round
  2: error 0.067 (cross-validation 32 / 4 for forced). With δ = 0.9, χ[x1, x2] passes in round 0 and the linear block
  enters with 30 degree-1 characters, none of which is in majpar's Fourier support. In round 1 χ[x3, x4] passes its
  test (z = 1.03), but the constant, χ[x1, x2] and the linear block's 30 characters already fill the 32 features least
  squares allows at n = 64 (min(256, n/2)), so the fit stops: error 0.341. This is a second cost of the linear block at
  small n: its characters take the room a later character needs. With δ = 10⁻⁴ the forced pairs are the same, but
  χ[x5, x6] does not pass: error 0.269. andxor's seed-1 errors at n = 32 / 64 are 0.245 / 0.290 under lenient against
  0 / 0; at n = 32 lenient keeps the default variant (held-out errors 5 / 2) where DFG alone takes the forced one
  (16 / 2).
- The same machinery lowers n\* under strict on one formula, f7_02 (and on two compositions, andxor and mux, not
  refitted). f7_02 (a DNF of three terms; seed 1, n = 128): with δ = 0.1 the linear block enters in round 0 and the
  default variant is kept, error 0.202; with δ = 10⁻⁴ nothing passes, the forced variant guesses the blocks
  (x2 − x6 − x8) and (−x3 + x5 + x7), two of the DNF's terms, a third term's block (−x1 + x2 + x4 + x5) then passes its
  test, and the cross-validation takes the forced variant (35 / 17): error 0 (refits).
- By n (65 targets, seed 0; `errs_by_n`): `strict` raises the mean test error most at n = 32 (+0.015; 9 cells higher,
  2 lower by more than 0.02) and 128 (+0.011; 11 / 4); `lenient` lowers it at 16–32 (−0.006, −0.012) and raises it at
  64 (+0.017; 9 higher, 0 lower) and 128 (+0.005; 9 / 3). Nothing differs by more than 0.005 in the mean from n = 1024 on.

**Halfspaces: a stricter test helps** (Numerical). `strict` −0.23 (4 lower: and3 −0.61, f7_01 −0.57, maj3 −0.45, fd_01
−0.40; 1 higher, dict +0.29); `noblocks` −0.19 (and3 −0.83, maj3 −0.44, fd_01 −0.40) and `labelnoise` −0.17 point the
same way. With f7_10 counted as a halfspace (§0) the three means are −0.17, −0.07 and −0.08: only `strict`'s gain is
robust to that choice. The linear block's threshold on 30 inputs is 51.2 at δ = 0.1, 81.7 at 10⁻⁴ and 33.8 at 0.9.
Refit of f7_01 (seed 1; `refits.json`): with δ = 0.1 the model at n = 128 is χ[x7], admitted by its own test, and the
linear block on the other 29 inputs, error 0.091; with δ = 10⁻⁴ no character passes on its own in round 0, and the exact
13-input block (x1 + … + x13) is admitted next to the linear block, error 0. A block is accepted only if it also passes
on the residual projected off the round's admitted characters (dfg13.py docstring), so a degree-1 character that passes
first takes part of the block's signal: with δ = 0.1 the exact block is found in round 0 at 1.16 times its threshold
and fails the projected test (0.97) once χ[x7] has passed. At n = 64 the strict fit is the constant and the background
(0.214 against 0.124).

**Symmetric and mixture targets: the search sets the cost** (Numerical; Part 10's block-power files
`part10/interp/results/toy_final/power/`, re-thresholded in `block_power`, post hoc). Part 10 applied DFG's block test to
each target's true block, as if proposed in round 0, on the seed-0 training rows at every grid n (unfolded, folded,
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
- On the other 23 learned targets n\* lies less than a doubling beyond n_detect, and for 18 of them at or below it
  (median over the 30: −0.20 doublings). For those 18 the 10% point is reached at the first grid point where the block
  passes or earlier, through characters (fd_08: n\* 51 against n_detect 512, as Part 10 found for gates and linear
  parts) or the forced variant's block (sym7 at n = 64, below the test); the other 5 (f7_07, h6_11, h6_07, h6_10,
  f7_09) lie 0.36–0.80 doublings beyond it (`verification.block_gap_split`). There the grid cannot separate test and
  search: the strict threshold leaves n_detect on the same grid point for all but 5 of the 23 (f7_00, f7_07, f7_11,
  h6_07, h6_10).
- The sum-target movements under `strict` (f7_09 +0.56, h6_09 −0.53, fd_11 +0.46, fd_08 +0.43, h6_07 +0.33, fd_05
  −0.30, f7_10 +0.26) are, but for h6_07, on targets whose true block's n_detect does not move. Refitted at their first
  fits (seeds 0, 1; `refits_verif.json`), fd_08 and fd_11 reach 10% error before their block enters the model: fd_08 =
  MAJ([−5 ≤ s ≤ 9], −x12, −x13) at n = 64 (n_detect 512) through its two literals' characters χ[x12], χ[x13],
  χ[x12, x13] (seed 1) or the block (x12 + x13) with χ[x12] (seed 0); fd_11 = OR([|s| > 3], x10) at n = 128, its
  n_detect, through χ[x10] and spectral features. f7_10 reaches 10% error at n = 128, its n_detect, through χ[x6] and the
  modulated block χ[x6]·|x1 + … + x5| (0.64 of the model's sd, both seeds), as ATLAS.md §1.9 also says. h6_07 is also
  one of the 3 targets the paired null moves (+0.40).

*Heuristic.* Part 10 read the data cost of a block as set by the search (TOY_INTERP.md: the true block passes at n = 128
for 43 of 54 targets, the exact structure appears a median of one doubling later). The δ-ablations agree: where n\*
lies beyond n_detect, a test one quarter-doubling stricter changes nothing, because the block is admitted far above its
threshold once the search proposes it (in Part 10's runs a median 2.3 times the threshold at n_struct over the 22 pure
symmetric targets found, range 0.89–74; `part10/interp/tables/toy_timing.csv`, as the paper's §"When the structure
appears" quotes it). For character targets the round-0 test is the binding constraint whenever the first fit comes from
it (parities exactly, staircases and small formulas within a grid step); where the first fit comes from the forced
variant, δ acts through the linear block and the cross-validation instead, and its sign is not predictable from the
test alone.

## 3. The degree-4 search (`K3`)

`K3` = `{"K": 3, "K_hi": 3}`: the global search stops at degree 3 and the degree-5/6 subsample search is off. K also
enters the union bound of every character class (thresholds use ln(4K·N/δ)) and of the sum-block tests (their
t = ln(4K·C(d, k)·2^(k−1)·2·(1 + #modulators)·k_max/δ)), so those tests are 0.29 nats more lenient (δ effectively 0.133).
The linear block's χ² test and the spectral edge use ln(1/δ) only (dfg13.py, block moves) and do not change under `K3`.
Numerical: +0.02 pooled (2 lower / 1 higher) [62/65]; par4 +3.01, rand1 −1.06, f7_01 −0.32 (seed 0).

**par4** (refits, seed 0; `refits.json` and, for n = 64 and 128, `refits_verif.json`, every refit equal to the result
file). Errors by n under `K3`: 0.49–0.50 at 16–256, **0 at 512**, 0.499 at 1024, **0 at 2048 and 4096**, 0.495 at
8192, 0.500 at 16384. In the three fitted cells the model is the folded block on the parity's four inputs, admitted in
round 0 by an additive block search: |−x1−x2−x3−x4| at 512 (statistic / threshold 9.0, share 0.61, with a spurious
product of it), |x1−x2+x3+x4| at 2048 (34.5) and |x1−x2−x3+x4| at 4096 (70.9). A k-parity is a function of any signed
sum of its k inputs, so one folded block with three groups represents it exactly (THEORY.md P4a). In the six empty cells
from n = 64 on (64, 128, 256, 1024, 8192, 16384) the best candidates of the round-0 block searches stand at 0.13–0.45 of
their thresholds (0.21–0.29 at 64 and 128), nothing is admitted, and the model is the constant and the background.
With the degree-4 search, χ[x1, x2, x3, x4] passes its round-0 test at n = 64 on both seeds (P2). The true block would
pass its test at every n ≥ 64: on the round-0 residual the statistic of a block that determines the labels is exactly
T = n (in units of s²), against a threshold of 56.9 (m = 2 groups − 1, t = ln(4·3·C(30, 4)·2³·2·24/0.1) = 20.96), so
the search finds it at 3 of the 9 grid sizes from 64 on. *Heuristic:* the block search's seeds read degree-1 and
degree-2 statistics (THEORY.md P4f), which are zero for a parity of degree 4; whether the greedy growth and local
refinement reach the 4-set is luck.

**mux and andxor** (degree-4 coefficient 0.75 and 0.5) have the same test error under `K3` as DFG alone at every n
(seed 0), with other models:
- mux at n = 64: the same model in both (forced variant, CV 22 / 3 and 22 / 4): a forced block (−x1−x2−x3+x4) and a
  forced χ[x4], error 0.0066. At 256: DFG alone holds χ[x1, x2, x3, x4] from the degree-4 test (round 0, share 0.51,
  the largest term), next to lower-degree characters (χ[x1, x2, x3] and χ[x3, x4], attributed to the local class in
  round 1, which the round's global tests also pass) and blocks; `K3` holds the blocks (−x1−x2−x3+x4) (round 0) and
  (x1+x2+x3 + 3·x4) (round 1) and χ[x1, x2, x3], attributed to the two-input extension of χ[x1] (round 1; the global
  degree-3 test also passes it), and no degree-4 character; error 0 in both.
- andxor at 256: DFG alone holds its exact expansion χ[x1, x2], χ[x3, x4], χ[x1, x2, x3, x4] (the last by the degree-4
  test); `K3` holds the two pair characters and the weighted block (x1 + x2 − 3·x3x4); error 0 in both.

**rand1** (−1.06): refit at n = 64. rand1 has 5 relevant inputs (x1, x3, x4, x5, x6), 3 of them with degree-1 weight
(x1, x3, x5: ±0.375, by exact enumeration). With K = 4, round 0 admits the linear block (30 degree-1 characters) and the
forced variant then guesses χ[x4, x12, x17]: error 0.412. With K = 3, χ[x1] passes its own (0.29 nats more lenient)
test in round 0 (z = 1.01, against 0.99 at K = 4), so the linear block does not enter; the forced guess is χ[x1, x4, x6],
the local class adds χ[x4, x6] and a block (x3 − x5) follows: error 0. The difference is the union bound's K, not the
degree-4 search.

*Heuristic.* The degree-4 search is redundant wherever a target's degree-4 characters share inputs with lower-degree
structure: blocks on the same inputs (a parity of k inputs is a function of their signed sum) and lower-degree
characters reach them. (In the mux refits the lower-degree characters attributed to the composition classes also pass
the global tests, so these refits do not show that the composition classes are needed.) It is indispensable for a
parity of degree 4 with no lower-degree footprint, which the ablation suites contain once (par4); the core run (§6) adds
rf17 (a 4-parity by its gates), poly4 and par5.

## 4. The small-n machinery and the background, against the atlas's counterfactuals

**`nosmalln`** = `{"small_n": false}`: at n ≤ 512 no forced variant and no cross-validation; the default variant is fitted
on all n rows with the whole budget. The atlas refitted the variant DFG did not choose, as DFG.fit's final fit (half the
budget; ATLAS.md §2.3, `results/cv/forced_vs_default.json`), on 21 targets the ablation suites share with the atlas. At
d = 30 the two can differ only in the degree-5/6 subsample sizes (THEORY.md P5; at n ≤ 512 only in the degree-6
subsample, 73 against min(n, 147) rows). Numerical (`atlas_counterfactuals`): `nosmalln`'s seed-0 test error equals the
atlas's always-default error in **126 of 126** cells (n ≤ 512); on those cells its mean error is 0.2345 against DFG
alone's 0.2242 (higher in 5 cells, lower in 2). Over all 65 targets (seed 0) the mean error rises by 0.012, 0.007,
0.022, 0.009 and 0.004 at n = 16, 32, 64, 128, 256 and by nothing from 512 on. n\*: +0.12, 10 higher, none lower. Since
`nosmalln` is the default variant, a cell where DFG alone's error is lower is one where DFG alone kept the forced
variant; the lost first fits are par2 and rand2 at n = 16, majpar at 32–64, mux and sym7 at 64, fd_04 at 128 and f7_02
at 256 (seed 0, result files), each recovered one grid step later. The atlas's mean over its 222 cells: DFG's choice
0.2257, always default 0.2319, always forced 0.2256, the better of the two per cell 0.2111.

**`nobg`** = `{"background": false}`. The background is added after the weights are fitted, so a fitted model without it
is exactly DFG's prediction without it for the same variant (ATLAS.md §2.4, `err_no_bg`); the ablation can differ from
that only where the cross-validation's choice changes, since the fold fits lose their background too. Numerical:
`nobg`'s seed-0 error equals the atlas's `err_no_bg` in **224 of 231** cells (21 targets, every n). The other 7 are all
at n ≤ 128, and since the same variant without its background gives exactly `err_no_bg`, in each of them the
cross-validation chose the other variant (the verifier's refits: in all 7 `nobg` takes the forced variant where DFG
alone keeps the default). Refitted: f7_11 at n = 16, where DFG alone keeps the default variant (held-out errors 6 / 3),
the constant plus the background, error 0.301; without the background the default's held-out errors rise to 13 and the
forced variant wins (13 / 3): χ[x11] and χ[x8], error 0.077. By n (65 targets): the mean error rises by 0.015 and 0.016
at n = 16 and 32 (29 and 25 cells higher, 18 and 21 lower) and falls by 0.009, 0.002, 0.003 and 0.002 at 64, 128, 256
and 512 (16 / 8, 11 / 4, 6 / 1, 4 / 0 cells lower / higher). n\*: −0.10 (7 lower, 3 higher): f7_11 −2.17, h6_05 −1.41,
fd_02 −0.94, fd_11 −0.90, rand0 −0.89, dict −0.64, andxor −0.38; fd_04 +1.01, rand2 +0.91, fd_00 +0.51.

*Heuristic.* The background is the networks-inspired kernel part (dfg13.py docstring): at n = 16–32, where the model
holds nothing else, it is a Hebbian classifier and helps on targets with a strong degree-1 part (ATLAS.md §2.4); from
n = 64 on it adds the noise of 30 residual correlations to a model that already fits, and through the cross-validation it
makes the default variant look better than it is, so the forced variant's correct guesses are kept less often. Most n\*
lie at 64–512 (47 of DFG alone's 62 seed-0 n\* on these suites), so on balance it costs data.

## 5. Tests scaled to the residual (`labelnoise`)

`{"noise": "label"}` sets s = 1 in every test (dfg13.py, `_fit`), in place of the residual's rms: s multiplies the
character thresholds and the spectral edge, which therefore rise by 1/s, and s² divides the block and linear-block
statistics, whose effective thresholds therefore rise by 1/s². In round 0 the residual is y − ȳ with variance 1 − ȳ²,
and after the first features fit it shrinks. (The subsampled searches keep the subsample's own rms; the sum blocks'
second test, on the residual projected off the round's characters, keeps its own variance.) THEORY.md P3c: the
composition classes and later-round global tests admit characters 1.4–3.7 doublings (medians) below n_glob, mainly
because the residual variance there is smaller (class medians 3.2–19.2 times).

Numerical: +0.14 (5 lower / 15 higher) [62/65]; character +0.23 (2/9), halfspaces −0.17 (2/0; −0.08 with f7_10 counted
as a halfspace), symmetric and mixtures +0.14 (1/6). By family: formulas +0.33 (1/6) [11], the staircase +0.70, random
formulas +0.19, mixtures +0.15 (1/5), compositions +0.11, symmetric +0.10, parities 0. By n: the mean error rises by
0.024 at n = 128 (18 cells higher, 2 lower) and 0.013 at 256 (11 / 0), and by at most 0.004 in absolute value elsewhere.
Moved: fd_11 +1.42, f7_02 +1.00, h6_07 +0.98, far9 +0.94, rand3 +0.81, majpar +0.80, fd_00 +0.71, stair5 +0.70, fd_07
+0.67, f7_06 +0.62, f7_10 +0.57, f7_04 +0.44, f7_11 +0.40, thrsum +0.39, h6_03 +0.32; lower h6_08 −0.91, and3 −0.86,
h6_04 −0.59, f7_01 −0.32, sparsepoly −0.27.

Refits (seed 0, n = 128):
- *rand3.* DFG alone: χ[x5, x6] in round 0 (s = 1.00), χ[x4, x5, x6] by the one-input extension in round 1 (s = 0.84),
  χ[x5] and χ[x4, x5] attributed to the local class in round 2 (s = 0.77; χ[x5] also passes the round's global degree-1
  test), five modulated blocks in rounds 3–4 and a spectral feature in round 4; error 0.049. With s = 1: χ[x5, x6] in
  round 0, then nothing passes in round 1 and the fit stops; error 0.317.
- *far9* (|x1 + … + x9| ≥ 5, biased labels: round 0's s = 0.711). DFG alone: the folded block |x1 + … + x9| and a
  spectral feature in round 0, error 0.006. With s = 1 the character and spectral thresholds are 1/0.711 = 1.41 times
  higher, and the block search's statistic is divided by 1 in place of s² = 0.51, so the folded block falls from 1.52 to
  0.77 of its threshold (its projected test stays at 1.52) and the spectral feature from 1.24 to 0.88; nothing passes:
  the constant and the background, error 0.181.

*Heuristic.* The residual scaling is what makes DFG's growth greedy in the sense of its docstring: each round's tests are
calibrated to the noise left after the last round's fit, so weaker features pass once stronger ones are in. Its cost to
the n\* of these targets is modest (+0.14) because the features that bring most targets below 10% error are admitted in
round 0 (ORDER.md: at n = 512, 2048 and 16384 DFG admits every target character it will carry in a single round in 24,
30 and 32 of 33 fits of the Part 5 targets); it is larger for formulas and staircases, whose later characters ride on
the first ones, and for targets with biased labels. Halfspaces gain (and3, f7_01), as under `strict`: a stricter round-0
test keeps partial characters out.

## 6. The core DFG (post hoc)

**What it is.** PROTOCOL.md's addendum (written after every pre-registered result had been read) defines `core` =
`{"readout": "ls", "sum_inner": false, "sum_seeds": [0, 3, 2], "blocks": false, "max_ext_bases": 0, "local_max": 0,
"K": 3, "K_hi": 3, "background": false}`: global characters of degree ≤ 3; unweighted signed-sum blocks searched from
pairs and single inputs (with modulated, product, split, beam and forced blocks); union-bound tests scaled to the
residual; least squares; the small-n cross-validation. Removed: the linear and spectral blocks, the extension and
local classes, the degree-4 to 6 searches, the weighted blocks, the eigenvector seeds, the logistic refinement, the
kernel background; and with K = 3 every test the core keeps (the character and sum-block tests) is 0.29 nats more
lenient. Seeds 0 and 1, all 11 suites (138 targets), the standard grid. Its definition used the ablations' results on
all five ablation suites, dlheld7 included: no suite is held out for it.

**Against DFG alone** (Numerical; RESULTS.md Q5b, `ablations.json` `core`). Same seeds and training sets. Pooled over
138 targets: +0.07, median −0.01, 28 lower / 26 higher, 133 both reach; newly never: par5; neither: h5s1, h6_00,
fd_10, f7_05. Per suite from −0.20 (dlheld4) to +0.46 (dlheld2); dlheld7 −0.03 (2 lower / 2 higher) [11/12]. On the 65
targets of the ablation suites +0.02 (16 / 12) [62]; on the other 73, +0.12 (12 / 14) [71] plus par5. By family (138):
parities +2.01 [3 of 4; par5 never], halfspaces +0.32 (3 / 7) [13], multiplexers +0.21 (0 / 1) [2], compositions +0.17
(4 / 2) [13], symmetric +0.06 (0 / 2) [22 of 25], mixtures −0.04 (7 / 5) [28 of 29], random formulas −0.07 (10 / 5)
[35], formulas −0.08 (4 / 2) [15], staircases −0.06 [2]. The core moves 54 of 138 targets beyond ±0.25; the paired null
on the same seeds and the same 138 targets moves 8 (5 lower, 3 higher; mean |ratio| 0.040; mean −0.01 over 134; RESULTS.md
Q5b): designed/andxor −0.69, dlheld/majpar5 −0.30, dlheld2/sym8 +0.69, dlheld2/h2rf1 −0.27, dlheld3/mixmaj +0.51,
dlsymdev/thrsum −0.66, dlheld5/h5t1 −0.26, dlheld6/h6_07 +0.40. On seed 0 alone it moves 8 as well.

**Against the networks** (Numerical; RESULTS.md Q5b). nets_best as in Q2, on the 126 targets with network runs
(`dlfamdev` has none). The core: −1.74 over the 122 of 126 targets both reach (111 better, 9 worse); DFG alone on the
same seeds: −1.88 (117 / 5) [123]; DFG alone on all its seeds −1.87 (117 / 2). On dlheld7: core −1.30 (9 / 1) [11/12],
DFG alone (seeds 0, 1) −1.27 (10 / 1). The core is clearly worse than nets_best on par4, par5, rf17, thr30, thr20,
h6_10, thrint, f7_01 and h6_00; DFG alone (seeds 0, 1) on thrint, f7_01, h6_00, h3rf0 and h3rf1, on the last two of
which the core is better than the networks. By family the core's largest loss against the networks is on parities
(−1.97 against DFG alone's −4.73) and halfspaces (−0.15 against −0.49).

**Compute** (Numerical; the result files, 3036 fits of seeds 0, 1). The core's FLOPs per fit are a median 0.094 of DFG
alone's on the same fit; its largest fit uses 0.150 of one network run (DFG alone 0.500); CPU time 2302 s against 9058
s in all (median 0.30 s against 2.01 s per fit; both measured with four workers on four CPUs, so rough).

**Leave one in** (post hoc; `leavein.py`, `results/leavein/`, `ablations.json` `leavein`). The core with one part put
back, as the evaluation runs it (seeds 0 and 1, every n), on the targets where the core moved most (chosen after
reading its results); n\* of DFG alone on the same seeds in brackets.
- *Degree-4/5 parities with no lower-degree footprint*: par4 (48), rf17 (49; its gates compute a 4-parity), poly4
  (161; the term x7x8x9x10) and par5 (56) are 3124, 3550, 3127 and never in the core. With the degree-4 to 6 searches
  back (K = 4, K_hi = 6): 48, 49, 151, 56. With the extension and local classes back: 3124, 3550, 3127, never. In the
  core par4 is learned at n = 512 and from 2048 on in seed 0, from 4096 in seed 1: the block search's luck (§3). par5
  is learned only at n = 16384 in seed 0; refit: a product block whose factors, (x1−x2−x4+x5) and a 10-input block
  holding x3 and nine irrelevant inputs, together cover the five inputs passes in round 0 at 6.66 times its threshold,
  and the exact block (x1+x2−x3+x4+x5) follows in round 1 (error 0); at n = 512 the round-0 searches' best candidates
  stand at 0.34–0.37 of their thresholds and the model is the constant (error 0.506).
- *Dense halfspaces*: thr30 (158 → core 623), thr20 (134 → 455), maj15 (122 → 206), maj21 (109 → 174), maj9 (84 → 110),
  f7_01 (156 → 195), thr10 (128 → 154). Linear and spectral blocks back: 192, 140, 122, 109, 84, 132, 128. Background
  back: 223, 249, 174, 136, 94, 161, 123. Logistic readout back: 483, 414, 207, 174, 110, 195, 136. Refit of thr30 at
  n = 512 (seed 0): the core's model holds the 5 degree-1 characters that pass their own tests, a 12-input signed block
  and a modulated 23-input block, error 0.108; DFG alone's the same 5 characters, the linear block's other 25,
  χ[x3, x19, x22] (round 1) and modulated blocks, error 0.034 (0.188 without the linear block's characters).
- *Mixtures*: h6_10 (215 → 649) and f7_09 (222 → 355): weighted blocks back 494 and 355, eigenvector seeds back 649 and
  355, both back 207 and 234. Refit of h6_10 at n = 256 (seed 0): DFG alone's model is the weighted folded block
  |x1 + … + x12 + 3·x13| (share 0.85, 0.96 of the model's sd; error 0.017); the core's the two pair characters
  χ[x1, x13], χ[x3, x13] (0.329). DFG alone's block has the wrong relative sign: the target is [|s − 3x13| > 1] with
  s = x1 + … + x12. No function of |s + 3x13| has error below 156/8192 = 0.019 (exact enumeration), and on the 4096 test
  inputs the best such function has DFG alone's error, 0.0166. h5t0 (112 → 185): background 146, weighted 185,
  eigenvector seeds 185, both 187. h5s2 (367 → 678; one grid step later on both seeds): background 713, weighted 678,
  eigenvector seeds 678, both 678.
- *sym8* (54 → 100): background back 54; linear block, weighted blocks, eigenvector seeds 100. Refit at n = 64 (seed 0):
  DFG alone keeps the forced variant (held-out errors 23 / 11), the forced block |x1 + … + x8|, error 0; the core keeps
  the default (16 / 12), the constant, error 0.281. sym8 is also one of the 8 targets the paired null moves (+0.69):
  its n\* hinges on that one cross-validation choice at n = 64.
- *What the runs cover* (`verification.core_higher`). Of the core's 26 clearly-higher targets, putting one part back
  (for h6_10 and f7_09, one pair of parts) returns n\* to within 0.25 of DFG alone's for 13 (par4, rf17, poly4, par5;
  thr20, maj15, maj21, maj9, thr10, f7_01; h6_10, f7_09; sym8), and part of the way for 2 (thr30: 192 against 158;
  h5t0: 146 against 112). No part tried restores h5s2. The other 10 were not tested: h5rf1 +0.60, h6_03 +0.59, rf01
  +0.51, mux11 +0.42, rf19 +0.39, h6_07 +0.35, rmaj9 +0.32, thrsum +0.32, fd_00 +0.29, rand3 +0.26. Two of the core's
  moves, h6_07's and sym8's, are also moves of the paired null (+0.40 and +0.69).
- *Gains* (DFG alone → core; 12 of the core's 13 largest gains, `verification.core_gains`: hrf0, −0.75, the 11th, was
  not run; 8 small formulas, 7 random formulas and dlist8, and3, a halfspace, and three mixtures, f7_11, fd_02 and
  fd_11; the core learns 11 of them at n\* = 16–63 and h5rf0 at 164): h3rf1 135 → 31, h3rf0 120 → 30, h4rf1 103 → 29,
  and3 78 → 37, f7_11 63 → 30, rf06 31 → 16, fd_02 58 → 31, dlist8 55 → 30, h5rf0 293 → 164, fd_11 109 → 61, rand0
  27 → 16, rand1 105 → 63. Background back: 52, 32, 59, 44, 54, 27, 42, 31, 166, 125, 26, 102. Linear block back: 31,
  30, 29, 78, 30, 16, 31, 30, 164, 68, 16, 68. Logistic readout back: no gain removed. K = 4 (with the degree-4 to 6
  searches) back: h5rf0 292, rand1 88, fd_11 62, the others unchanged. Composition back (h3rf0, h3rf1, dlist8, h4rf1,
  h5rf0, fd_02): 30, 31, 30, 29, 186, 31. Background and linear block back together (the same six): 32, 52, 31, 104,
  166, 42. So the background removes the gain on rand0, rand1, rf06, f7_11 and fd_11 (to within 0.25: rf06 27 against
  31, f7_11 54 against 63) and part of it on h3rf1, h4rf1 and fd_02; with the linear block, all of h4rf1's; the linear
  block alone and3's; K = 4 h5rf0's. On h3rf0 and dlist8 nothing tried removes the gain: in both learners the test
  error sits near 10% for several doublings (h3rf0 0.071–0.124 in the core and 0.074–0.198 in DFG alone at n = 32–256;
  dlist8 0.010–0.111), where small differences move the 10% point by one or two doublings.

*Heuristic.* On these suites a learner with characters of degree ≤ 3, unweighted signed-sum blocks, residual-scaled
tests, least squares and the small-n cross-validation keeps DFG alone's results against the networks, on the held-out
suite too, at a tenth of its FLOPs. Its largest losses are what the removed parts are for: the degree-4 to 6 searches
find parities with no lower-degree footprint, the linear block dense halfspaces, the weighted blocks with eigenvector
seeds sums with a heavy inner term; the leave-one-in runs show this for 13 of its 26 clearly-higher targets and in part
for 2, leave h5s2 unexplained and did not examine 10. The single ablations could not show the first two, because the
ablation suites hold one target of the first kind (par4) and no halfspace on more than 13 inputs. The background and
the linear block cost data at small n on formulas, which is what the core gains. A target mix richer in high-degree
parities or dense halfspaces would make the core worse than DFG alone.

## 7. What could not be checked, and caveats

- One or two seeds per ablation; n\* is a seed mean on a doubling grid, so a single training set's single grid step
  moves a 2-seed n\* by about 0.5 and a 1-seed n\* by about 1. The paired null calibrates this for column order and
  folds, not for the training sets.
- The paired null exists for seeds 0 and 1 only, on all 11 suites (RESULTS.md Q5b; `ablations.json` `nulls` for the
  65 ablation-suite targets, `core.paired_null_same_seeds` for all 138). It perturbs column order and folds, nothing
  else; it does not measure the effect of another training set. It is one replicate: "within the null" is a count
  against 1 (one seed) or 3 (two seeds) moved targets, with no significance level; `lsread`'s and `K3`'s 3 moves on one
  seed cannot be told from it, `nosums`' 33 and the core's 54 of 138 (against 8) can.
- Families, the paired null, the leave-one-in runs, the refits, the core itself, the P2 prediction rule, the
  block-power re-thresholding, the per-seed agreement and the errors-by-n tables are post hoc. The leave-one-in targets
  were chosen after reading the core's results (12 of its 13 largest gains, and not 10 of its 26 clearly-higher
  targets), and the two-part runs (weighted blocks with eigenvector seeds; background with the linear block) after
  reading the one-part runs. f7_10's class follows the atlas, not `families.py`'s own rule (§0).
- The n_detect shifts of §2 rescale Part 10's stored statistics; the modulated entries use the unmodulated block's
  number of groups (approximate). n_detect is computed on seed 0's rows, n\* from seeds 0 and 1.
- Mechanisms are read from single refits (seed 0 or 1, one n); they show what happened in that cell, not that it is the
  only route. A feature's class is the class with its largest score, not necessarily the only class that admits it.
- Checked by an independent verifier (VERIFY_ABLATIONS.md); its corrections are applied (Verification).
