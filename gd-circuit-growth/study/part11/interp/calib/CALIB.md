# False admissions and where the compute goes: DFG v1.3 alone (Part 11, Q7)

Part 11, Q7 (PROTOCOL.md): "false admissions: DFG on labels independent of the inputs; where the compute goes". The
object is DFG v1.3 run alone: `part10/hyb_portfolio3/dfg13.py`, md5 `69cabe5c50345cb24079198ed52b562f`, as
`DFG(readout="logit").fit` (its own cross-validation at n ≤ 512, kernel background and budget), loaded by
`part11/eval_dfg.load_dfg13()` (md5 checked). Written 3 November 2026. The record-writing job was killed by a container
restart at about 01:09 UTC with A1 at d = 60 at 8 of 220 fits and B at 32 of 105 records, and the cascade check of
§1.5 written but not yet run; they were completed from the records (keys already written are skipped, so no cell was
fitted twice), and every table was regenerated from the complete records. Checked by an independent verifier the same
day; its corrections are applied below, and the next section lists them.

## Verification

An independent agent verified this report on 3 November 2026: [`VERIFY_CALIB.md`](VERIFY_CALIB.md), structured as
[`VERIFY_CALIB.json`](VERIFY_CALIB.json). It checked 28 claims (16 confirmed, 12 corrected) and listed 8 omissions,
with its own code throughout: it rebuilt the instrumented copy and compared its syntax tree with `dfg13.py`'s,
recomputed every headline count of A1, A2 and B from the raw records, refitted 17 cells with the frozen module (8 A1,
7 A2, and the largest-FLOP fit at seeds 0 and 2; all equal to the records or result files), ran its own null Monte
Carlo of the round-0 tests, computed the degree-1 class's null rate exactly, checked P-A and P-A′ line by line against
`dfg13.py`, and checked the round-0 FLOP formula on all 825 recorded `_fit` calls. Every changed number below is
reproduced by the re-run `calib_summary.py` (the last section of `calib_tables.txt`, "Checks added after the
independent verification", and new keys of `calib.json`; all earlier values are unchanged), and the largest fit by the
new `calib.py largest`. Where a number is my recomputation and not the verifier's value, the item says so.

**Confirmed, unchanged:** the instrumented copy (64 inserted lines, none changed, byte-identical rebuild, read-only
hooks); P-A′; the A1 counts, intervals and ratios of §1.2 and §1.6 and the refit cells; §1.3's test counts, later
rounds and max-ratios; the error identity err = a + q(1 − 2a), the Φ predictions and the Marchenko–Pastur ratios;
every A2 table and term detail of §2, the exact relevant sets and the bounds 29.8 and 2.2; the FLOP derivation of §3.1;
the FLOP and CPU shares of §3.2–3.3 and the CPU variation of §3.0; the result-file tables of §3.4; the budget cap over
the 6786 recorded calls; the Part 6 comparisons.

**Corrections applied** (old → new; "claim" and "omission" number VERIFY_CALIB.json's lists from 1):
1. Identity checks (Short answer, §0; claim 2, omission 3). "Every fit made with it equals a fit of the frozen module …
   or the result file" / "Every fit made with the copy was checked" → every *checked* fit is equal: 88 of the 660 A1
   fits, all 451 A2 fits, all 35 B cells; the other 572 A1 fits and the 800 cascade re-runs were not checked, and are
   the frozen learner's by construction: the copy's syntax tree without its 64 hook calls (on 63 lines) and its
   recorder import equals `dfg13.py`'s, the hooks' arguments call only `len`, the recorder only reads
   (`calib.audit_ast`, new).
2. P-A's proof (§1.1; claim 3, omission 4). "S passes iff |Σ r_i χ_S(x_i)| > c √(2L Σ r_i²)" and "(If s < 10⁻⁶ the loop
   stops before any test.)" → s = max(rms(r), 10⁻⁶) and that exit never fires (`sqrt(1e-12)` is exactly 1e-6); for
   m = n the pass event is contained in the one with s = rms(r), for m < n the threshold uses rms(r₁..ₘ) exactly, so
   S passes *only if* |Σ r_i χ_S(x_i)| > c √(2L Σ r_i²), in every case. The statement of P-A is unchanged. All labels
   are equal in 2 A1 final fits (d = 30, P(y = 1) = 0.8, n = 16, seeds 14 and 19) and in 24 fold training sets (48
   fold fits), all at that (d, P(y = 1), n) (recomputed from the data and folds; the verifier wrote "n = 16 and 32").
3. §1.3's table header "degree 6 (m = min(n, 147))" → "m = min(n, 147); 73 at n = 128–512" (claim 8; the final fit
   has half the budget at n ≤ 512).
4. Degree 1 against the Gaussian approximation (§1.3; claim 9). "5 of 6 classes are compatible with the ~0.001 … (degree
   1: 2/440 where 0.5 is expected)" → all 6 are (degree 1's interval 0.0006–0.016 contains 0.0012). "2 or more
   degree-1 passes in 440 tests has probability 0.082" → with the exact per-(P(y = 1), n) null rates (0 at n = 16 up to
   0.11% at large n, `g1_check`; my code reproduces the verifier's) 0.37 passes are expected and P(X ≥ 2) = 0.053 if the
   tests were independent, the verifier's value. Added by me: the samples of one seed are nested in n, so its 11 tests
   are positively dependent; a simulation of the nested tests, exact in distribution, gives P(X ≥ 2) = 0.063.
5. Linear block (Short answer, §1.4; claim 10, omission 6). "passes at the exact χ²_d tail of its Laurent–Massart
   threshold" / "level is the χ²_d tail" → close to the χ²_d tail (0.84% against 0.92% at d = 30, 1.04% against 1.05%
   at d = 60), a little below it: all 108000 null draws at d = 30 pool to 0.85% (95% CI 0.79–0.90%), which excludes
   0.92%, because the statistic is a sum of squared weighted Rademacher sums (fourth moment 3 − 2Σr⁴/(Σr²)² < 3).
   Added by me (`lin_check`): from that exact law the null rate is 0.73–0.92% at d = 30, depending on n and P(y = 1),
   and 0.89% weighted as the Monte Carlo's draws (which are 1.5 standard errors low), 1.032% at d = 60.
6. Spectral rates (Short answer, §1.4, §1.6; claim 11). 5.7% (d = 30, n = 128) and 48% (d = 60, n = 256), the 2000-
   and 1000-draw estimates → ≈ 5.4% and ≈ 47%. Recomputed, not the verifier's ≈ 5.3% and ≈ 47%: with 100000 new draws
   at each cell (`mc_spectral`), all the check script's draws pool to 5.38% (95% CI 5.26–5.51%; 6569 of 122000) and
   46.6% (56420 of 121000); the verifier's 5.3% pooled its own 10000 draws (5.0%) with the report's 20000 and lies
   within the error. Consequently §1.4's P(X ≥ obs.) at the pooled rates: 0.31 → 0.29, 0.58 → 0.54. "Not
   conservative" now says against what: the ≈ 1% of the linear block and the 1.25% of P-A; above the δ = 0.1 of its
   own margin factor only from d = 60 on.
7. Sum blocks (Short answer, §1.4; claim 12, omission 2). "The sum-block tests never passed" → never in the final
   fits; in the fold fits the default variant admitted an additive block in round 0 twice (d = 30, P(y = 1) = 0.8:
   n = 64 seed 17 fold 7, n = 128 seed 19 fold 4), and forced fold fits admitted test-passed sum blocks after a forced
   feature in 22 (d = 30) and 7 (d = 60) fits (the verifier's 24 at d = 30 includes the 2 above); no null Monte Carlo
   of their statistic was run.
8. Forced fold fits (Short answer, §1.5, §1.6; claim 13, omission 5). "238/900 (205 local)", "12/900", "150/450" and
   "14/450 … with a test-passed feature after the forced ones" → admitted after a forced one: 229/900 (205 local),
   10/900, 143/450 (132 local), 12/450 (12 local); 9, 2, 7 and 2 forced fold fits hold only admissions that the default
   fold fit on the same rows also made, before any forcing (the two variants run identically until nothing passes;
   `folds_paired`). By n at d = 30, P(y = 1) = 0.8: 121, 73 → 72, 28 → 25, 15 → 11, 1 → 0; kinds and intervals
   recomputed. The fold records keep neither rounds nor sets, so "χ_A χ_B" rests on degrees: 185 of the 205 local
   characters are provably χ_A χ_B, the other 20 have degrees consistent with |A Δ B| for overlapping A, B.
9. Cascade (Short answer, §1.5; claim 14). "Every local character … came after two forced characters A, B and has
   degree |A Δ B| (4/4, 2/2, 116/116, 98/98)" → in 220 of the 221 re-runs that admitted one (214 of 215 at
   P(y = 1) = 0.8; 4/4, 2/2, 116/116, 98/99): DFG admitted a local character in 99, not 98, of the 200 re-runs at
   P(y = 1) = 0.8, n = 58, and in 30:0.8:58:34 it followed one forced character, a forced sum block and a test-passed
   degree-1 character.
10. Spurious terms removed (Short answer, §2.1; claim 19). "changes it by ≤ 0.0001 from n = 128 on" → ≤ 0.0002
    (+0.00018, +0.00011, −0.00015 at n = 128, 256, 512; 0 from 1024 on).
11. Readout in the largest fits (Short answer, §3.2; claim 23). "The largest fits (0.32–0.52 …) … the logistic readout
    is 41–47%" → 41–47% in the three profiled largest-FLOP cells (seed 0, 0.32–0.47), 37% (37.1%) in the largest fit of
    all, h5s5 at seed 2 (0.519, 250 features). Recomputed by an instrumented fit of that cell (`calib.py largest`, equal
    to the frozen module and the result file), whose recorded readout region equals the verifier's formula value.
12. Sum-block rate (Short answer, §3.3; claim 24). "0.75 GFLOP/s (all profile fits pooled)" → the rates pool the final
    fits' regions; inside the fold fits the sum-block search runs at 0.27 GFLOP/s (0.39 over every call and repeat;
    `B.rate_sum_folds`).
13. §1.6 (a remark in confirmed claim 15): the biased test error reaches the minority rate 0.2002 "from n = 2048 on" →
    from n = 4096 on (0.2003 at n = 2048).
14. §3.4 (claim 26): "The *median* fit at d = 30 is the same in every suite" → nearly the same up to n = 4096; at
    n = 16384 the suite medians range 0.138–0.182.
15. §3.4 (claim 27): "at n ≤ 512 the whole fit stays below 0.096" → below 0.096 at d = 30 and below 0.137 at every d
    (designed_d60: 0.136).
16. The spectral block beyond A1's settings (Short answer, §1.4, §2.2, §4; omission 1). New null Monte Carlo
    (`mc_spectral`): at P(y = 1) = 0.8 and the first grid n ≥ 4d the pass rate is 5.4%, 47% and 99.4% at d = 30, 60,
    120; at d = 120 it is 69%, 9% and 0.4% at n = 1024, 2048, 4096 (balanced: 1 of 2000 at n = 512); at P(y = 1) = 0.9,
    39%, 9.9%, 1.4%, 0.1% at n = 128–1024 (d = 30) and 98%, 69%, 19% at n = 256–1024 (d = 60). The verifier's 397/400,
    202/300, 39% and 11% agree within their sampling error; I quote my larger samples. "Falling to 0 by n = 1024
    (d = 30) and 4096 (d = 60)" is now restricted to the settings measured, and §2.2 connects the 15 spurious spectral
    features at n = 128–256 to this effect (Heuristic).
17. Provenance of the first 32 B records (§3.0; omission 7): written before the restart by an earlier `calib.py`,
    without the `rep` field; equal to the frozen module, the result files and the later repeats.
18. The Gaussian reference for degrees 5–6 (§1.3; omission 8): it says little there, as their N ≫ m statistics are
    strongly dependent.
19. Added by me (§4): the binomial tails of §1.3–1.4 treat the tests as independent although the n of one seed are
    nested (item 4).

**Declined:** none. Two details of VERIFY_CALIB.md differ from my recomputation and are not used: it counts "65 `_P.*`
expression statements (on 64 lines)" plus the import, where the copy has 64 hook calls on 63 lines plus the import (65
statements on the 64 inserted lines; the conclusion, an identical syntax tree, stands); and it places the all-equal
fold training sets at "n = 16 and 32", where all 24 are at n = 16.

**For the paper** (every statement of this report that changed, new form; the paper's checkers can match these against
`paper_dfg/sections/*.tex`, which quote this report through `make_interp.py`'s `VCALIB` and the text; line numbers as
of 03:10 UTC):
- Identity: "every checked fit is equal (88 of 660 A1 fits, all A2 and B fits); the 572 other A1 fits and the 800
  cascade re-runs are equal by the syntax-tree construction" (app_results.tex already says this).
- P-A's proof: s = max(rms(r), 10⁻⁶); the m = n test passes *only if* |Σ r χ_S| > c √(2L Σ r²); all-equal labels in
  2 final fits and 24 fold training sets, all at d = 30, P(y = 1) = 0.8, n = 16 (learner.tex:128 already notes
  s ≥ 10⁻⁶; any "iff" with s = rms(r) in the paper's own proof of P1 needs the same "only if").
- Degree 6 in the final fit's round 0 runs on 64 rows at n = 64, 73 at n = 128–512 and 147 from n = 1024 on.
- Degree 1: all six classes are compatible with the Gaussian approximation; 0.37 passes expected in the 440 tests;
  P(X ≥ 2) = 0.053 for independent tests, 0.063 with the nested samples (`VCALIB["deg1_p_at_least_2"]` stores 0.053).
- Linear block: close to (a little below) the χ²_d tail: 0.84% vs 0.92% (d = 30), 1.04% vs 1.05% (d = 60); exact rate
  0.89% at d = 30; lighter tail of squared Rademacher sums (interp.tex:106 and tab_interp_calib agree).
- Spectral, P(y = 1) = 0.8 at n = 4d: ≈ 5.4% (5.38%) at d = 30 and ≈ 47% at d = 60; P(X ≥ obs.) 0.29 and 0.54. The
  paper's "5.3%" (interp.tex:107, tab_interp_calib, `VCALIB["spectral_pooled"]`) is the verifier's pooled value; the
  report now gives 5.4%. At d = 120: 99% (99.4%) at n = 512, 69% at n = 1024 (the verifier's 67%), 9% at 2048; at
  P(y = 1) = 0.9: 39% (d = 30, n = 128), 9.9% at n = 256 (the verifier's 11%), 98% at d = 60, n = 256. "Not
  conservative" means far above the ≈ 1% of the other tests; above the δ = 0.1 of its margin only from d = 60 on. The
  fall to 0 with n holds only for the two settings measured in A1.
- Sum blocks: never passed in the final fits; 2 default fold fits admitted one in round 0 (d = 30, P(y = 1) = 0.8);
  22 (d = 30) and 7 (d = 60) forced fold fits admitted test-passed sum blocks after a forced feature; not calibrated
  by any Monte Carlo.
- Forced fold fits with a test-passed feature admitted after a forced one: 229/900 and 10/900 (d = 30), 143/450 and
  12/450 (d = 60); 185 of the 205 local characters provably χ_A χ_B (interp.tex:111 quotes 229).
- Cascade: 99 (not 98) re-runs at P(y = 1) = 0.8, n = 58 admitted a local character; 220 of 221 after two forced
  characters.
- Spurious terms removed: ≤ 0.0002 from n = 128 on (app_results.tex:19 and interp.tex:115 agree).
- Readout: 41–47% in the three profiled largest cells, 37% in the largest fit (h5s5, seed 2, 0.519); now reproduced by
  `calib.py largest` (`calib.json` `largest`), so interp_dyn.tex:133 need not rest on "the verifier's refit".
- Sum-block rate: 0.75 GFLOP/s in the final fits, 0.27 inside the fold fits, 0.39 over all calls (interp_dyn.tex:134
  agrees).
- d = 60 biased test error: the minority rate 0.2002 from n = 4096 on (0.2003 at n = 2048).
- §3.4: d = 30 medians nearly equal across suites up to n = 4096, 0.138–0.182 at n = 16384; at n ≤ 512 every fit
  below 0.096 at d = 30 and below 0.137 at every d.
- The first 32 B records lack the `rep` field (an earlier `calib.py`); the Gaussian reference says little for degrees
  5–6; the binomial tails assume independent tests.

Labels: **Proved** (a proof is given), **Numerical** (measured; the source file is named), **Heuristic** (my reading).
Every count is given with its denominator; intervals are two-sided 95% Clopper–Pearson.

**Files** (all in this folder):
- [`make_instr.py`](make_instr.py) builds [`dfg13_instr.py`](dfg13_instr.py), a copy of `dfg13.py` with 64 lines
  added and none changed: calls into the recorder [`calib_rec.py`](calib_rec.py), which only read (the FLOP counter
  `fl[0]`, the process clock, statistics DFG has just computed) and append to their own lists. Rebuilding it gives the
  same file byte for byte (md5 `be56ce50…`).
- [`calib.py`](calib.py) runs everything: `audit`, `noise` (A1), `spur` (A2), `prof` (B), `cascade` (A1, §1.5) and,
  added after the verification, `largest` (B, §3.2). Records: `results/noise.jsonl` (one line per fit),
  `results/spur.jsonl`, `results/prof.jsonl`, `results/cascade.jsonl`, `results/largest.jsonl`. The full set is
  `audit; noise --d=30; noise --d=60; spur; prof --reps=0-2; cascade; largest`.
- [`calib_summary.py`](calib_summary.py) (or `calib.py summarize`) turns the records and the evaluation's result files
  into [`calib.json`](calib.json) and [`calib_tables.txt`](calib_tables.txt). Every number below is printed in
  `calib_tables.txt`, including the ones derived by hand from the code (its first section, `derived()`). The numbers
  changed or added after the verification are in its last section, "Checks added after the independent verification"
  (`calib_summary.py` was re-run after the changes, single-threaded, in about 5 minutes; every value it wrote before
  is unchanged).

## Short answer

- **The instrumented copy is the frozen learner** (Numerical, §0). Every checked fit made with it equals a fit of the
  frozen module on the same data, or the evaluation's result file, in test error and FLOP count: 88 of the 660 A1 fits
  (seeds 0 and 1), all 451 A2 fits and all 35 B cells against the frozen module, and 31 of 31 cells (93 of 93 records)
  against the result files. The other 572 A1 fits and the 800 cascade re-runs were not checked. They are the frozen
  learner's by construction: deleting the copy's 64 hook calls and its recorder import leaves a syntax tree identical
  to `dfg13.py`'s, and the hooks only read.
- **The character tests hold their level on noise** (P-A, Proved; Numerical, §1.3, §1.6). Each round-0 class of
  characters has level ≤ δ/(2K) = 0.0125. In the final fits the classes passed in 2 of 2400 round-0 class searches at
  d = 30 and 1 of 840 at d = 60 (both label rates), against 0.07–0.11% per class in 80000-draw nulls of the degree-1
  and degree-2 classes, and ≈ 0.1% per class from an independent-Gaussian approximation.
- **On balanced labels nothing passes a test at d = 30**: 0 of 220 final fits (95% ≤ 0.017) have a test-passed
  feature. At d = 60, 5 of 110 (0.015–0.103): the linear block 3 times, a degree-2 character once, and once the product
  of the forced variant's two characters.
- **The false admissions are the dense block tests'** (Numerical, §1.2, §1.4, §1.6). The linear block passes close to
  the χ²_d tail of its Laurent–Massart threshold (0.84% against 0.92% at d = 30, 1.04% against 1.05% at d = 60 in
  80000-draw nulls; the statistic's exact law gives 0.89% at d = 30, slightly below the tail; 2 of 360 and 4 of 160
  round-0 tests in the fits), about a tenth of its nominal δ = 0.1. The spectral block's edge has no proved level: on
  balanced labels it never passed (at most 3 null passes in 20000 draws), but on biased labels near n = 4d, the
  smallest n at which it runs, its null pass rate is far above the ≈ 1% of the other tests and grows steeply with d and
  with the label bias: at P(y = 1) = 0.8 it is ≈ 5.4% at d = 30 (n = 128), ≈ 47% at d = 60 (n = 256) and 99% at
  d = 120 (n = 512); at P(y = 1) = 0.9, 39% at d = 30 (n = 128) and 98% at d = 60 (n = 256). It falls with n: at
  P(y = 1) = 0.8 to 0 by n = 1024 (d = 30) and 4096 (d = 60), but at d = 120 it is still 69% at n = 1024 and 9% at
  2048. The fits agree where measured (2 of 20 and 5 of 10). The two block tests made 4 of the 6 test-passed admissions
  among the 220 biased fits at d = 30 (the other two are degree-1 characters) and, at d = 60, all 6 biased ones and 3 of
  the 5 balanced ones. The sum-block tests never passed in the final fits (0 of 2000 round-0 searches, 0 of 153 later;
  largest T / threshold 0.93), but in the cross-validation's fold fits, which run the same round-0 search on noise, the
  default variant admitted a sum block twice (2 of 900 default fold fits at d = 30, P(y = 1) = 0.8); no null Monte
  Carlo of the sum-block statistic was run.
- **The forced variant is not calibrated after its forced characters** (Numerical, §1.5): in its fold fits the local
  class admits the product of the two forced characters. At P(y = 1) = 0.8, 229 of 900 forced fold fits (d = 30) hold
  a test-passed feature admitted after a forced one (205 of them local characters, 185 of these provably the product
  χ_A χ_B: the fold records keep degrees, not sets); in 400 fold-sized re-runs the local test after the second forced
  character passes in 244 of 334, and after two random characters of the same degrees in 0 of 334. In 214 of the 215
  re-runs at P(y = 1) = 0.8 that admitted a local character it came after two forced characters A, B and has degree
  |A Δ B|, and where A and B are disjoint (190 of 214) it is χ_A χ_B. The cross-validation never chose the forced
  variant at P(y = 1) = 0.8 (0 of 120 at d = 30, 0 of 60 at d = 60) and chose it in 5 of 120 balanced fits at d = 30
  (two forced characters each, test error 0.491–0.500) and 2 of 60 at d = 60, one of which then admitted the product.
- **Test error on fresh noise** (Numerical, §1.2): balanced labels 0.497–0.504 by n (the test set has P(y = −1) =
  0.4895); biased labels 0.339 at n = 16, falling to the test minority rate 0.1946 from n = 1024 on. The excess is the
  kernel background's random direction, not admitted features: err = a + q(1 − 2a) (a = 0.1946, q = P(predict −1))
  reproduces the mean error at every n to within 0.001.
- **Spurious features on the designed and random targets** (Numerical, §2): of the 4499 terms admitted in 451 fits,
  1047 read an irrelevant input (0.233), and 961 of these are the linear block's degree-1 characters, which the block
  adds for every input not yet in the model. The others are 86 of 3364 terms (0.026). By n, the count share falls
  from 0.69 at n = 64 to 0.08 at 16384 (without the linear block's characters 0.044 → 0.005), and the spurious terms'
  share of the model's output from at most 0.86 (n = 64) to at most 0.086 from n = 2048 on, with median 0 at every n.
  Removing them lowers the mean test error by 0.020 at n = 64 and changes it by ≤ 0.0002 from n = 128 on. Only 2
  characters were admitted by their own test in round 0 while reading an irrelevant input (both wholly on irrelevant
  inputs), against 2.2 expected from the Gaussian approximation and at most 29.8 by P-A′ (Proved).
- **FLOPs are set by the fixed-share searches** (Proved by reading the counter, checked exactly on all 275 profiled
  `_fit` calls; §3.1–3.2): at d = 30 degrees 1–4 cost 768,390 FLOPs per training row and the degree-5 and degree-6
  subsample searches 0.030 of a network run each, so any fit costs 0.079 of a network run at n = 4096 and 0.137 at
  16384 before anything else; at n = 64 the degree-6 search is 50–64% of the FLOPs and the fold fits 27–43%. The
  largest fits (0.32–0.52 of a network run, n = 16384) are those with many features: in the three profiled
  largest-FLOP cells (seed 0; 0.32–0.47) the logistic readout is 41–47% of the FLOPs, and in the largest fit of all
  (h5s5 at seed 2, 0.519, 250 features) it is 37%.
- **CPU time follows the sum-block search instead** (Numerical, §3.3): in the final fits it runs at 0.75 GFLOP/s,
  against 17 for the character searches and 33 for the readout, and inside the fold fits at 0.27; there, at n = 64, it
  takes 94–95% of the CPU time for 42–46% of the FLOPs. So in the result files the slowest fits are at n = 64–512
  (suite medians 2.2–9.2 s at d ≥ 30, largest 17.4 s), where the FLOP count is smallest.
- **Every suite** (Numerical, §3.4): no fit of the 4730 in the result files uses more than 0.519 of a network run
  (h5s5, n = 16384, seed 2); at d = 30 every fit at n ≤ 512 stays below 0.096. DFG's own cap (a round starts only below
  0.75 of the call's budget) stopped none of the 6786 recorded `_fit` calls; the largest spent 0.471 of its budget.

## 0. What was measured, and how

**The instrumented copy is the frozen learner** (Numerical, `calib.py audit`, `calib.json` `audit`, `B.checks`):
- `audit`: difflib between `dfg13.py` and `dfg13_instr.py` finds only inserted lines, all of the form `_P.<hook>(...)`
  or the recorder's import (64 lines; 878 → 942). The recorder's hooks return nothing and change no array DFG uses.
- Every A2 and B fit and 88 of the 660 A1 fits made with the copy were checked, bit for bit, on test error and total
  FLOP count:
  - against the evaluation's merged result files (A2: all 451 seed-0 cells of the designed and random suites; B:
    every profiled cell of a suite, in each of its three records, and the largest fit of §3.2);
  - against a fit of the frozen module on the same data in the same process (B: every profiled cell and the largest
    fit; A1: seeds 0 and 1 of every (d, p, n), 88 fits).
  All checks are equal. The other 572 A1 fits (seeds ≥ 2) and the 800 cascade re-runs of §1.5 were not checked.
- That every fit made with the copy, checked or not, is the frozen learner's follows from the construction
  (`calib.audit_ast`, `calib.json` `audit_ast`): deleting from `dfg13_instr.py`'s syntax tree its 64 hook calls (on 63
  lines; one line holds two) and the recorder's import leaves a tree identical to `dfg13.py`'s, so no inserted line
  changes the code around it; the hooks' arguments call nothing but `len`; and the recorder only reads its arguments,
  `fl[0]` and the clock, and writes to its own lists.

**Regions** (B). `DFG._fit` is cut into consecutive regions by `REC.enter(name)`; the FLOP-counter increments and
CPU seconds between two marks go to the region entered first, so the regions of one `_fit` call add up to its FLOP
count (largest relative closure error 2.1·10⁻¹⁶ over the 35 cells) and its CPU time. The recorder's own detail work is
subtracted from the clock. Regions: the global character search by degree (`deg 1`: the vector X^T r / n; `deg 2`: the
residual pair matrix M, which the blocks reuse; `deg 3`, `deg 4`; `deg 5`, `deg 6`: the first-round subsample
search), extension (one and two inputs), local (the Walsh transform on the inputs in use), the linear block test, the
spectral block (eigendecomposition of M), the sum-block search (setup, additive, product, split, candidate-pair
products, modulated, products of accepted blocks), least squares, the logistic readout, and other (bookkeeping,
adding feature columns, the background, the training error). `DFG.fit`'s fold fits at n ≤ 512 are separate `_fit`
calls; what lies outside every `_fit` call (prediction on the held-out folds) is reported separately.

**Detail records** (A). Per round and candidate class: the number of distinct candidates that pass their test and
the largest ratio |statistic| / threshold (≥ 1 passes), mirroring DFG's `offer()` (a candidate counts only if it is
not yet in the model); for the subsampled degree-5/6 search, whose code offers only the passing candidates, the
largest ratio is computed from the coefficient matrix over the disjoint pairs. Also the linear block's χ² ratio, the
spectral block's top |eigenvalue| over its edge, every sum-block search's best T / threshold, every admission with
the class or code path that made it, and for every feature of the model its origin, aligned with DFG's feature list.
A character's class is the class whose test gave it the score DFG keeps (`cand[S]` keeps the largest).

## 1. (A1) False admissions on labels independent of the inputs

### 1.0 Data and fits

- d = 30: P(y = 1) = p ∈ {0.5, 0.8}, n ∈ {16, 32, …, 16384}, 20 seeds per (p, n): 440 fits.
- d = 60 (the smaller check): the same p and n, 10 seeds: 220 fits.
- Training data in the harness's style (`harness.train_data`): `rng = default_rng([fn_seed(name), seed])`,
  X = 16384 × d uniform ±1 (float32), y iid with P(y = 1) = p from the same rng, the first n rows (nested in n);
  name = `noise_p50_d30` etc. Test: 4096 fresh points from `default_rng([fn_seed(name), 10**6])`. Fit rng
  `default_rng([fn_seed(name), seed, n, 77])`, as the harness. DFG is fitted directly, without `Permuted` (the
  inputs are exchangeable).
- "Admitted feature" = a feature of the final model (the fit on all n rows that predicts). The cross-validation's
  fold fits are reported separately (§1.5), and so is a re-run of fold-sized forced fits (`cascade`: 200 draws for each
  P(y = 1) ∈ {0.5, 0.8} and n ∈ {29, 58}, the fold sizes at n = 32 and 64; `_fit(force=True, hi=False, scale=1/40)`
  exactly as `DFG.fit` runs them; d = 30).

### 1.1 What the tests promise

**P-A (Proved).** Let the rows of X be iid uniform on {±1}^d and y independent of X. In round 0 of any `_fit` call,
for each global character class of degree k searched on the first m rows (degrees 1–4; and 5–6 in the first-round
subsample search), P(at least one character of degree k passes its test) ≤ δ/(2K) = 0.0125 (δ = 0.1, K = 4, c = 1).
The six classes together: ≤ 0.075.

*Proof.* In round 0 the model is the constant alone: `lsfit` solves (n + 10⁻⁹) w = Σ y (the ridge term is zero on the
constant), so r = y − w depends on y only, and r is independent of X. The statistic of χ_S is v_S = (1/m) Σ_{i ≤ m}
r_i χ_S(x_i): for degree 1 and 2, `c1 = X^T r / n` and `M = (X r)^T X / n` (m = n); for degrees 3 and 4 the entries of
`Ma`, `Mab` on the first m rows; for degrees 5–6 the entries G[p, q] = mean(r χ_{T1} χ_{T2}) over disjoint T1, T2,
which equal mean(r χ_{T1 ∪ T2}) (overlapping pairs are skipped). The threshold is `thr(N)` = c s √(2L/n) when m = n,
and `thr_m(N, m)` = thr(N) √(n/m) rms(r_{1..m}) / s = c rms(r_{1..m}) √(2L/m) when m < n, with L = ln(4KN/δ) and
N = C(d, k). Here s = `sqrt(max(mean r², 1e-12))` = max(rms(r), 10⁻⁶); the loop's exit `s < 1e-6` never fires,
because `sqrt(1e-12)` evaluates to exactly 1e-6. So for m = n, S passes iff |Σ_i r_i χ_S(x_i)| > c s √(2Ln), and as
s ≥ rms(r), only if |Σ_i r_i χ_S(x_i)| > c √(2L Σ_i r_i²) (the two events are equal when s = rms(r); s > rms(r) only
when all labels are equal, which happens in 2 A1 final fits, d = 30, P(y = 1) = 0.8, n = 16, and in 24 fold training
sets, all at that (d, P(y = 1), n)); for m < n the threshold is c rms(r_{1..m}) √(2L/m) exactly. In every case S passes
only if |Σ_{i≤m} r_i χ_S(x_i)| > c √(2L Σ_{i≤m} r_i²). Conditionally on y, for S ≠ ∅ the χ_S(x_i), i ≤ m, are iid
uniform signs independent of r, so by Hoeffding's inequality for weighted Rademacher sums the probability of that event
is ≤ 2 exp(−c²L) = 2δ/(4KN). A union bound over the N characters of the class gives δ/(2K), and over the six classes
6δ/(2K). ∎

**P-A′ (Proved; the same argument on any target).** Let y = f(x) depend only on a set R of inputs. In round 0 of any
`_fit` call, for each global class of degree k, P(some character χ_S with S ⊄ R passes) ≤ (N_irr/N) δ/(2K) ≤ δ/(2K),
N_irr = C(d, k) − C(|R|, k). *Proof.* r = y − w is a function of the rows' inputs in R. For S containing an input
j ∉ R, χ_S(x_i) = x_ij χ_{S∖j}(x_i), and conditionally on y and on all inputs but column j, the x_ij are iid uniform
signs; so Σ_i r_i χ_S(x_i) is a weighted Rademacher sum with Σ (weights)² = Σ r_i², and the bound of P-A holds for
each such S; the union is over N_irr of them. ∎ (§2.2 uses it.)

The bounds are not tight: for N independent Gaussian statistics at these thresholds the probability is
1 − (1 − 2Φ(−z))^N = 0.0008–0.0012 per class (z = √(2L) = 4.12 for degree 1 up to 6.06 for degree 6 at d = 30), about
10× below δ/(2K), because Hoeffding's bound has no Mills-ratio factor (Heuristic; the statistics are pairwise
uncorrelated and nearly Gaussian for m ≫ 1, and for N ≫ m dependent, which I expect lowers their maximum).

What P-A does not cover:
- **later rounds**: once a feature is in the model, the residual depends on X through it;
- **the linear block**: n |X^T r / n|² / s² against k + 2√(kt) + 2t, t = ln(1/δ), Laurent–Massart's bound for a
  Gaussian χ²_k at level δ = 0.1; the exact χ²₃₀ tail at that threshold (51.23) is 0.0092, the χ²₆₀ tail at 88.11 is
  0.0105 (on noise the statistic's own null rate is a little lower, §1.4);
- **the spectral block**: the top |eigenvalue| of the residual pair matrix (diagonal removed) against the Wigner
  edge 2s√(d/n)·(1 + √(2 ln(1/δ)/d)), for n ≥ 4d; no level is proved for it;
- **the sum-block tests**: T = |projection of r onto a block's level indicators|² / s² against Laurent–Massart's
  χ²_m bound at exp(−t_k), t_k = ln(4K·C(d,k)·2^{k−1}·2·n_mod·24/δ). If each T were exactly χ²_m, the union bound over
  every (S, s) of every size k = 2 … 24, both folds and the n_mod modulators would give 23δ/(4K·24) = 0.0060 ≤ δ/(4K)
  for all additive blocks together (weighted blocks have their own, half as large share); the block is searched on
  the residual and must also pass on the residual projected off the round's new characters; no null Monte Carlo of
  this statistic was run here (§1.4 gives its pass counts on noise);
- **the forced variant** (n ≤ 512): when nothing passes it takes the best-scoring candidate character (in the re-run
  of §1.5 a global one, except 4 of the 731 second forced characters, which came from the local class), or, at
  n ≥ 48, the best sum block if its T / threshold exceeds the square of the best character's ratio; at most twice. It
  is used only if the paired cross-validation test prefers it.

### 1.2 What was admitted, d = 30

(Numerical, `results/noise.jsonl`, `calib.json` `A1.by_cell`, `A1.totals`; full table `calib_tables.txt`.) 20 fits
per cell.

| n | p = 0.5: fits with any feature | of which CV chose forced | test-passed | test error (mean) | p = 0.8: fits with a test-passed feature (what) | CV chose forced | test error (mean) | P(predict −1) |
|---|---|---|---|---|---|---|---|---|
| 16 | 2 | 2 | 0 | 0.500 | 0 | 0 | 0.339 | 0.234 |
| 32 | 1 | 1 | 0 | 0.504 | 0 | 0 | 0.319 | 0.203 |
| 64 | 1 | 1 | 0 | 0.500 | 1 (linear block, 30 characters) | 0 | 0.274 | 0.130 |
| 128 | 0 | 0 | 0 | 0.502 | 3 (linear block 1; spectral block 2) | 0 | 0.232 | 0.060 |
| 256 | 1 | 1 | 0 | 0.502 | 1 (a degree-1 character) | 0 | 0.206 | 0.018 |
| 512 | 0 | 0 | 0 | 0.502 | 0 | 0 | 0.196 | 0.003 |
| 1024–8192 | 0 | – | 0 | 0.497–0.501 | 0 | – | 0.195 | 0 |
| 16384 | 0 | – | 0 | 0.499 | 1 (a degree-1 character) | – | 0.195 | 0 |
| all | 5/220 | 5/120 (n ≤ 512) | **0/220** (95% ≤ 0.017) | | **6/220** (0.010–0.058) | 0/120 | | |

- **Balanced labels: nothing passes a test** (0 of 220 fits, every n). The only features are the forced variant's,
  in the 5 of 120 fits at n ≤ 512 where DFG's paired cross-validation chose it: two forced characters each (degrees
  1–4). Their test errors (0.491–0.500) are those of the fits without features. 215 fits stopped in round 0 with
  nothing passed, the other 5 after their two forced rounds.
- **Biased labels: 6 false admissions in 220 fits, at n = 64–256 and once at 16384**: the linear block twice
  (n = 64, 128; T at 1.10 and 1.07 times its threshold 51.23), adding all 30 inputs (test error 0.336
  and 0.283 against 0.195); the spectral block twice at n = 128 (eigenvalue ratio 1.011 and 1.054; in the first fit a
  second spectral feature entered in round 1 at ratio 1.083, after the first had lowered s; test error 0.234, 0.213);
  a degree-1 character twice (n = 256: test error 0.244; n = 16384: 0.195). In 5 of the 6 nothing further entered.
  The cross-validation never chose the forced variant at p = 0.8 (0/120).
- **Test error on fresh noise** (Numerical; the mechanism Heuristic). p = 0.5: 0.497–0.504 by n (the test set has
  P(y = −1) = 0.4895). p = 0.8: 0.339 at n = 16, falling to 0.1946 = the test set's minority rate from n = 1024 on.
  The excess at small n is the kernel background, not admitted features (at n = 16 and 32 no fit has a feature):
  the model is sign(w₀ + x·b) with w₀ = ȳ and b = X^T r / n, whose d coordinates are each ≈ N(0, s²/n), s² = 1 − ȳ²,
  so a test point is predicted −1 with probability ≈ Φ(−w₀√n / (s√d)). With w₀ = 0.6, s = 0.8 this is 0.29, 0.14,
  0.014 at n = 16, 64, 256; with each fit's own ȳ (fits without features) 0.224, 0.124, 0.012; measured 0.234, 0.130,
  0.018. Since the predictions do not depend on the test labels, the error is a + q(1 − 2a) = 0.1946 + 0.6108 q
  (q = P(predict −1)), which gives 0.3378, 0.2741, 0.2055 at n = 16, 64, 256 against the measured 0.3386, 0.2738,
  0.2056 (within 0.001 at every n). Part 6's remark that at n = 16–64 "both learners are near the constant predictor's
  error (DFG sometimes above it)" (`discrete_learner/DISCRETE-LEARNER.md`) fits this: on such data the Hebbian
  background carries no information and costs up to 0.144 in error on biased labels.

### 1.3 Per class, against the nominal levels

(Numerical, `calib.json` `A1.by_class`, `A1.by_class_pooled`, `nominal`; Gaussian reference Heuristic.) Round 0 of
the final fit, d = 30, both p, all n where the class runs (degrees 3–4 need m ≥ 32 rows, degrees 5–6 m ≥ 64):

| class | N | round-0 tests | fits with ≥ 1 pass | bound δ/(2K) (P-A) | independent-Gaussian approx. | median max-ratio, p = 0.5: range over n ≥ 128 | Gaussian reference |
|---|---|---|---|---|---|---|---|
| degree 1 | 30 | 440 | 2 (0.0006–0.016) | 0.0125 | 0.0012 | 0.524–0.603 | 0.553 |
| degree 2 | 435 | 440 | 0 (≤ 0.0083) | 0.0125 | 0.0010 | 0.633–0.681 | 0.669 |
| degree 3 | 4060 | 400 | 0 (≤ 0.0092) | 0.0125 | 0.0009 | 0.695–0.741 | 0.727 |
| degree 4 | 27405 | 400 | 0 (≤ 0.0092) | 0.0125 | 0.0009 | 0.746–0.773 | 0.762 |
| degree 5 (m = min(n, 1374)) | 142506 | 360 | 0 (≤ 0.010) | 0.0125 | 0.0008 | 0.774–0.790 | 0.785 |
| degree 6 (m = min(n, 147); 73 at n = 128–512) | 593775 | 360 | 0 (≤ 0.010) | 0.0125 | 0.0008 | 0.791–0.803 | 0.802 |

(The "max-ratio" is the largest |statistic| / threshold in the class; the reference is the median of max |Z|/z over N
independent N(0, 1). For degrees 5 and 6 the reference says little: on m = 64–147 rows their N = 142506 and 593775
statistics are strongly dependent.) Both degree-1 passes are at p = 0.8. The later rounds of the final fits (after a
forced or a false feature) ran 14, 16 and 13 tests of degrees 1, 2, 3, 13 one-input and 10 two-input extension tests
and 9 local tests, with no pass. Against the task's nominal "δ = 0.1 per class per round" every class is far below;
against the sharper δ/(2K) = 0.0125 of P-A every rate is compatible with it, and so is every rate with the ~0.001 of
the Gaussian approximation (degree 1's interval, 0.0006–0.016, contains its 0.0012). A null Monte Carlo of the
degree-1 and degree-2 classes (20000 draws at each of n = 128, 1024 and p = 0.5, 0.8, computed as `_fit` computes them;
`calib.json` `mc_big`, `consistency`) gives 0.108% and 0.068% per test at d = 30 (86 and 54 of 80000). The degree-1
class's null rate can also be computed exactly (`calib.json` `g1_check`: conditionally on the labels each column's
statistic is a sum of two weighted binomials, independent over the columns): 0 at n = 16, 0.004–0.045% at n = 32,
0.02–0.08% at n = 64 and 0.11% at large n (0.094% on average over the Monte Carlo's four cells). Over the 440 tests
0.37 passes are expected, and 2 or more have probability 0.053 if the tests are independent. They are not quite: the
samples of one seed are nested in n, so its 11 tests share rows, and a simulation of the nested tests (exact in
distribution) gives 0.063.

### 1.4 The block tests

(Numerical, `calib.json` `A1.blocks`, `mc`, `mc_big`, `consistency`, `lin_check`, `mc_spectral`, `spectral_pooled`; the
reading of the spectral block Heuristic.) Round 0 of the final fits, against a null Monte Carlo of the same round-0
statistics computed as `_fit` computes them (r = y − ȳ on fresh noise; 2000 draws per n at d = 30 and 1000 at d = 60,
and 20000 at each of n = 128, 1024 (d = 30) and n = 256, 1024 (d = 60) for each p; for the spectral block 100000 more
at its two biased cells, `mc_spectral`, which mirrors `_fit` also in setting a passing degree-2 pair to 0 before the
eigendecomposition). The last column is P(X ≥ observed) for X ~ Binomial(tests, null rate): the linear rows at the
80000-draw rate, the spectral rows at the pooled rate.

| test | runs at | round-0 passes in the final fits: p = 0.5; p = 0.8 | null pass rate | P(X ≥ obs.) |
|---|---|---|---|---|
| linear block, d = 30 | n ≥ 2(d + 1) | 0/180; 2/180 (n = 64, 128) | 674/80000 = 0.84% (all 108000 draws: 0.85%, 95% CI 0.79–0.90%; exact rate 0.89%; χ²₃₀ tail at the threshold: 0.92%) | 0.81 |
| linear block, d = 60 | n ≥ 2(d + 1) | 3/80 (n = 1024, 2048, 8192); 1/80 (n = 2048) | 833/80000 = 1.04% (all 92000 draws: 1.025%; exact rate 1.032%; χ²₆₀ tail: 1.05%) | 0.087 |
| spectral block, p = 0.5 | n ≥ 4d | 0/160 (d = 30); 0/70 (d = 60) | 3/20000 at d = 30, n = 128; 2/20000 at d = 60, n = 256; 0 at every other n | – |
| spectral block, d = 30, p = 0.8 | n ≥ 4d | 2/20 at n = 128, 0/140 at n ≥ 256 | 5.4% at n = 128 (6569/122000 pooled: 113/2000, 1078/20000, 5378/100000), 0.4% at 256, 0.05% at 512, 0 from 1024 | 0.29 |
| spectral block, d = 60, p = 0.8 | n ≥ 4d | 5/10 at n = 256, 0/60 at n ≥ 512 | 47% at n = 256 (56420/121000 pooled: 483/1000, 9356/20000, 46581/100000), 9.0% at 512, 0.2% at 1024 (103/20000 = 0.5%), 0 from 4096 | 0.54 |
| spectral block, beyond A1's settings (null only) | n ≥ 4d | no fits | d = 120, p = 0.8: 99.4% at n = 512, 69% at 1024, 9% at 2048, 0.4% at 4096; p = 0.5: 1/2000 at 512. p = 0.9: 39%, 9.9%, 1.4%, 0.1% at n = 128–1024 (d = 30); 98%, 69%, 19% at n = 256–1024 (d = 60) | – |
| sum blocks (additive, product, split; all d, p) | n ≥ 32 | 0 of 2000 searches (0 of 153 in later rounds); in the fold fits, 2 of 900 default fold fits at d = 30, p = 0.8 | not measured | – |

- **The linear block's level is close to the χ²_d tail at its threshold, ≈ 1%, not δ = 0.1.** The Laurent–Massart
  bound is conservative for a Gaussian χ²_d, and n |X^T r / n|² / s² is close to χ²_d here: its null median over the
  threshold is 0.565–0.579 at d = 30 and 0.670–0.680 at d = 60 in every run, against the χ²_d median over the
  threshold, 0.573 and 0.673. Its upper tail is a little lighter: at d = 30 all 108000 null draws pool to 0.85% (95% CI
  0.79–0.90%), which excludes the χ²₃₀ tail of 0.92%. Conditionally on the labels the statistic is Σ_j Z_j² over the
  d inputs, with Z_j = Σ_i r_i x_ij / ‖r‖ iid weighted Rademacher sums whose fourth moment, 3 − 2 Σ r_i⁴ / (Σ r_i²)²,
  is below the Gaussian 3. Computed from this exact law (`lin_check`: the law of one Z_j² exactly, its d-fold
  convolution on a grid of step 0.002), the null rate at d = 30 is 0.73% at n = 64 and 0.83% at n = 128 for
  P(y = 1) = 0.8 (0.86% and 0.89% for 0.5) and reaches the χ²₃₀ tail as n grows; weighted as the Monte Carlo's draws
  it is 0.89%, so the pooled 0.85% is 1.5 standard errors low. At d = 60: 1.025% measured (92000 draws), 1.032% exact,
  1.05% for χ²₆₀. Every observed count is what that rate predicts. When it passes it adds all d inputs (§1.2).
- **The spectral block is conservative on balanced labels and not on biased ones near n = 4d**, the smallest n at
  which it runs: there its null pass rate is far above the ≈ 1% of the linear block and the 1.25% per-class level of
  P-A, and at d ≥ 60 above even the δ = 0.1 in its own margin factor. A reading (Heuristic; `calib_tables.txt`,
  "Spectral block, a heuristic"): the edge 2s√(d/n) is the semicircle edge of a matrix with iid entries, but the pair
  matrix is a weighted sum of n rank-one matrices x_i x_iᵀ with weights r_i. With P(y = 1) = 0.8 the 20% minority rows
  carry weight r ≈ −1.6 (the others +0.4); their part is −1.6·0.2·(W − I) for the Gram matrix W of those 0.2n rows (W
  has unit diagonal), whose Marchenko–Pastur edge puts its most negative eigenvalue near
  −1.6·0.2·((1 + √(d/(0.2n)))² − 1). This is 0.99 of DFG's edge (margin factor
  included) at d = 30, n = 128 and 1.08 at d = 60, n = 256, where the null pass rates are ≈ 5.4% and ≈ 47%; 0.89 and
  0.97 at the next n (0.4% and 9.0%); and at most 0.74 with balanced labels (0 passes). DFG's margin factor 1 + √(2
  ln(1/δ)/d) is 1.39 at d = 30 and 1.28 at d = 60.
- **So the spectral block's false admissions grow with d and with the label bias** (Numerical, `mc_spectral`; the
  reading Heuristic). At n = 4d the minority edge is fixed relative to the semicircle edge, while the margin factor
  shrinks with d (1.20 at d = 120). At d = 120 and P(y = 1) = 0.8 the minority edge is 1.15 of DFG's edge at n = 512,
  the first grid n ≥ 4d, and the null pass rate is 99.4% (3976 of 4000 draws); at n = 1024, 2048 and 4096 the ratio is
  1.03, 0.95 and 0.89 and the rate 69%, 9% and 0.4%; with balanced labels 1 of 2000 at n = 512. A stronger bias does
  the same: with P(y = 1) = 0.9 (minority edge 1.20 of DFG's edge at d = 30, n = 128, and 1.31 at d = 60, n = 256) the
  rate is 39%, 9.9%, 1.4% and 0.1% at n = 128–1024 for d = 30, and 98%, 69% and 19% at n = 256–1024 for d = 60. So the
  fall to 0 by n = 1024 (d = 30) and 4096 (d = 60) holds for the two settings A1 measured, not beyond them: not for the
  `designed_d120` suite, and not necessarily for strongly biased targets such as and3 (P(y = 1) = 1/8, the same as 7/8
  for this test, which reads only |eigenvalues|).
- **The sum-block tests never passed in the final fits on noise**: the largest T / threshold over all searches is 0.86
  in round 0 and 0.93 in a later round (p = 0.8, d = 30, the first additive block). But the fold fits run the same
  round-0 search on noise, and there the default variant admitted an additive block in round 0 twice (d = 30,
  P(y = 1) = 0.8: n = 64, seed 17, fold 7; n = 128, seed 19, fold 4, which added a second block in round 1), in 2 of
  the 900 default fold fits at that (d, P(y = 1)) and in none of the other 1800; after a forced feature the forced fold
  fits admitted test-passed sum blocks in 22 fits at d = 30 and 7 at d = 60 (§1.5). No null Monte Carlo of the
  sum-block statistic was run, so its level on noise is known only from these counts.

### 1.5 The forced variant and the cross-validation's fold fits

(Numerical, `calib.json` `A1.folds`, `A1.folds_total`, `folds_paired`, `cascade`; mechanism Heuristic.) At n ≤ 512 every
fit also runs 2F fold fits (F = 10 at n ≤ 64, else 5): F of the default variant and F of the forced one, on (F−1)/F of
the rows, without the degree-5/6 search and with 1/(4F) of the budget each.

| d = 30 | default fold fits with an admitted feature | forced fold fits with a test-passed feature admitted after a forced one |
|---|---|---|
| p = 0.5 | 2/900 (a degree-1 character; the linear block) | 10/900 (0.0053–0.020): the local class in 9 fits; linear block 1, two-input extension 1 |
| p = 0.8 | 9/900 (linear block 3, spectral 3, sum blocks 2, degree 1) | **229/900** (0.226–0.284; n = 32: 121/200; 64: 72/200; 128: 25/100; 256: 11/100; 512: 0/100): the local class in 205, sum blocks in 22, one-input extension 2, spectral 1 |

Each forced fold fit runs on the same rows as a default fold fit, and the two variants run identically until the first
round in which nothing passes (`_fit` is deterministic and forces only then), so a forced fold fit's test-passed
features minus its default fold fit's admissions are exactly those admitted after a forced one (`calib.json`
`folds_paired`). 12 (p = 0.5) and 238 (p = 0.8) forced fold fits hold some test-passed feature; in 2 and 9 of them each
such feature was also admitted by the default fold fit, before any forcing (2 of the 9 forced nothing at all). The fold
records keep each admission's kind and degree but neither its round nor its set, so this pairing is how "after a
forced one" is decided, and "χ_A χ_B" is decided by degrees: of the 205 local characters at p = 0.8, 185 have the
degree of the two forced characters together, with no other character in the model, so A and B are disjoint and the
character is χ_A χ_B; the other 20 have degrees consistent with |A Δ B| for overlapping A and B.

The forced fold fits forced a character in 900 of 900 (p = 0.5) and 813 of 900 (p = 0.8), a sum block in 11 and 179.

**What the local class admits after two forced characters** (`results/cascade.jsonl`; `calib.json` `cascade`). The
re-run records, for each fold-sized forced fit, DFG's own admissions and, after the first and after the second forced
character, DFG's local test recomputed twice: on V = the inputs of the forced characters, and on V = the inputs of
random characters of the same degrees (least squares on the constant and those characters, then every subset of V not
in the model against `thr(C(|V|, |T|))`, as `_fit` does):

| P(y=1) | n | DFG: fits with a local pass | after the 1st forced character: forced V | random V | after the 2nd: forced V (median max-ratio) | random V (median) |
|---|---|---|---|---|---|---|
| 0.5 | 29 | 4/200 | 0/166 | 0/166 | 4/200 (0.51) | 1/200 (0.49) |
| 0.5 | 58 | 2/200 | 0/189 | 0/189 | 2/197 (0.61) | 1/197 (0.64) |
| 0.8 | 29 | 116/200 | 0/147 | 0/147 | **146/199** (1.17) | **0/199** (0.48) |
| 0.8 | 58 | 99/200 | 0/133 | 0/133 | **98/135** (1.16) | **0/135** (0.61) |

- In 220 of the 221 re-runs in which DFG admitted a local character it came after two forced characters A, B and has
  degree |A Δ B| (4/4, 2/2, 116/116, 98/99); the exception (p = 0.8, n = 58, seed 34) forced one character and one sum
  block, and its degree-4 local character followed a test-passed degree-1 character. Where A and B are disjoint (4/4,
  2/2, 114/116, 76/98 of the fits with two forced characters) the only subset of V = A ∪ B of that degree is V itself,
  so the admitted character is exactly χ_A χ_B. (At n = 58 and p = 0.8, 64 of the 200 fits forced a sum block instead
  of one or both characters.)
- So at p = 0.8 the local test passes after selected characters (244 of 334) and not after random ones of the same
  degrees (0 of 334): the excess comes from the selection. A reading (Heuristic): with P(y = 1) = 0.8 the residual's
  large entries are the minority rows (r ≈ −1.6 against +0.4), and the character that best correlates with it is one
  that is nearly constant on those rows; so is the second, and then so is their product, which least squares on {1,
  χ_A, χ_B} leaves in the residual and which the local class tests with N = 1 (threshold z = √(2 ln 160) = 3.19 when
  A, B are disjoint). With balanced labels a character aligned with the residual is aligned with y, and the product of
  two such characters with y² = 1, the constant.
- The paired test protects the final fit: at p = 0.8 the cross-validation chose the forced variant in 0 of 120 fits.
  At d = 60 the forced fold fits held a test-passed feature admitted after a forced one in 12 of 450 (p = 0.5; all 12
  local characters) and 143 of 450 (p = 0.8; 132 local), and in one final fit, where the paired test had chosen the
  forced variant, the local class admitted the product of the two forced characters (§1.6).

### 1.6 d = 60 (the smaller check)

(Numerical, `results/noise.jsonl`, `calib.json` `A1.by_cell`, `A1.totals`, `A1.by_class_pooled`, `A1.folds_total`;
full tables `calib_tables.txt`.) 10 fits per (p, n), 220 in all; the frozen module was refitted for seeds 0 and 1 of
every cell (44 of 44 equal).

| n | p = 0.5: fits with a test-passed feature (what) | CV chose forced | test error | p = 0.8: fits with a test-passed feature (what) | P(predict −1) | test error |
|---|---|---|---|---|---|---|
| 16–128 | 0 | 1/40 (n = 64) | 0.497–0.503 | 0 | 0.384 → 0.153 | 0.432 → 0.292 |
| 256 | 1 (a degree-2 character) | 0/10 | 0.500 | **5** (the spectral block, 1–3 features each) | 0.078 | 0.247 |
| 512 | 1 (a degree-7 local character: the two forced ones' product) | 1/10 | 0.502 | 0 | 0.016 | 0.209 |
| 1024 | 1 (linear block, 60 characters) | – | 0.496 | 0 | 0.002 | 0.201 |
| 2048 | 1 (linear block) | – | 0.496 | 1 (linear block) | 0 | 0.200 |
| 4096 | 0 | – | 0.497 | 0 | 0 | 0.200 |
| 8192 | 1 (linear block) | – | 0.497 | 0 | 0 | 0.200 |
| 16384 | 0 | – | 0.497 | 0 | 0 | 0.200 |
| all | **5/110** (0.015–0.103) | 2/60 | | **6/110** (0.020–0.115); CV chose forced 0/60 | | |

- **The character classes** (degrees 1–4; the degree-5/6 search does not run at d = 60, its budgeted m being at most
  47 and 2 rows) passed in round 0 in 1 of 840 class searches: 0/220 of degree 1, 1/220 of degree 2 (n = 256, p =
  0.5), 0/200 of degrees 3 and 4. The 80000-draw nulls give 0.096% and 0.072% per test for degrees 1 and 2 (P(X ≥ 1) =
  0.147 for the degree-2 pass). Later rounds ran 17, 21 and 21 tests of degrees 1–3, 10 one-input and 10 two-input
  extension tests and 6 local tests; the one pass is the local character below.
- **The block tests**: the linear block passed 4 times in 160 round-0 tests (ratios 1.01, 1.11, 1.04 at p = 0.5 and
  1.03 at p = 0.8), as its 1.04% null rate predicts (§1.4); the spectral block in 5 of the 10 biased fits at n = 256,
  the first n with n ≥ 4d, where its null rate is ≈ 47% (§1.4); 6 of the 12 later-round spectral tests at p = 0.8 passed
  too, all in those 5 fits (1–3 spectral features per fit).
- **The forced variant's product in a final fit**: at n = 512, p = 0.5, seed 5, the paired test chose the forced
  variant; its two forced characters (degrees 4 and 3) were followed in the next round by a local character of degree
  7, i.e. their product (§1.5), with test error 0.494.
- **Test error**: balanced 0.496–0.503 by n (the test set has P(y = −1) = 0.4995); biased 0.432 at n = 16, falling to
  the minority rate 0.2002 from n = 4096 on (0.2003 at n = 2048). The kernel background's excess is larger than at
  d = 30 (P(predict −1) 0.384 at n = 16 against 0.234), as Φ(−w₀√n/(s√d)) predicts.
- **Fold fits**: the default variant's fold fits admitted something in 2 of 450 (p = 0.5) and 8 of 450 (p = 0.8; 7 of
  them spectral features); the forced variant's held a test-passed feature admitted after a forced one in 12 of 450
  (0.014–0.046; 12 local characters) and 143 of 450 (0.275–0.363; 132 local, 7 sum blocks, 2 spectral, 2 two-input
  extensions); 2 and 7 more hold only admissions that their default fold fit made too, before any forcing (§1.5).

## 2. (A2) Spurious features on the designed and random targets

### 2.0 Fits and definitions

- The 21 designed and 20 random targets at d = 30, seed 0, every n of the grid (16 … 16384): 451 fits, each exactly
  as `eval_dfg.py` makes it (`harness.train_data` / `test_data`, fit rng `default_rng([fn_seed(t), 0, n, 77])`, the
  column permutation that `Permuted` draws from it, `DFG(readout="logit")`). The permutation is undone through the
  `pi` that `Permuted` stores in its prediction function: learner column j is original input pi[j]. All 451 equal the
  evaluation's result files in test error and FLOPs.
- **Relevant set**: the inputs the target depends on, computed exactly. Every designed and random target reads only
  x[:, :k] with k ≤ 10 (`boolfuncs.py`: explicit indices below 10; `_random_formula(rng, k, ·)` reads x[:, :k],
  k ≤ 8), so enumerating all 2¹² assignments of the first 12 inputs (the others +1) decides, for each of them,
  whether flipping it ever changes f; flipping each input 12–29 was also checked on 20000 random points (never).
  The exact sets equal the suites' `relevant` lists for all 41 targets (Numerical, `calib.json` `A2.relevant`); their
  sizes are 1–10, so every target has 20–29 irrelevant inputs.
- **Terms**: the final model as terms in original coordinates (as `part10/interp/hooks.dfg_terms` and
  `dfg_hooks.model_terms`): each character χ_S; each sum block with all its level indicators as one term (support =
  its set, modulator, inner term and product factors); each spectral feature (u·x)² − |u|²; the kernel background is
  not an admitted feature and is left out. A term is **spurious** if it reads an irrelevant input; a spectral feature
  if less than 90% of |u|² lies on relevant inputs (the atlas's rule; its support, |u_i| > 0.1 max|u|, is recorded
  too).
- **Kinds**: `chi_test` (a character admitted by its own test: global degree k, extension, local), `chi_lin` (a
  degree-1 character that entered with the linear block, which adds every input not yet in the model), `chi_forced`
  (the forced variant's best guess), `quad`, `sum` (by the code path that accepted it), `sum_forced`.
- **Share** of a term: the standard deviation of its contribution w·φ(x) over the 4096 test inputs; the spurious
  share of a fit is the sd of the summed contribution of its spurious terms over the sd of the model's output
  (background included). Also the test error of the model with the spurious terms' contributions removed.

### 2.1 By n

(Numerical, `results/spur.jsonl`, `calib.json` `A2.by_n`; full tables in `calib_tables.txt`.) 41 fits per n.

| n | fits with test error ≤ 0.1 | admitted terms | read an irrelevant input (share of terms) | of which linear-block characters | the others (share of the other terms) | fits with another spurious term | spurious share of the output, mean / max | max without the linear block's characters (upper bound) | test error with / without the spurious terms (mean) |
|---|---|---|---|---|---|---|---|---|---|
| 16 | 2 | 5 | 1 (0.200) | 0 | 1/5 | 1 | 0.024 / 1.000 | 1.000 | 0.3713 / 0.3654 |
| 32 | 7 | 18 | 3 (0.167) | 0 | 3/18 | 2 | 0.033 / 0.752 | 0.752 | 0.2818 / 0.2800 |
| 64 | 22 | 362 | 250 (0.691) | 247 | 3/68 (0.044) | 3 | 0.136 / 0.863 | 0.413 | 0.1158 / 0.0958 |
| 128 | 38 | 399 | 204 (0.511) | 185 | 19/164 (0.116) | 11 | 0.063 / 0.493 | 0.373 | 0.0190 / 0.0191 |
| 256 | 41 | 405 | 174 (0.430) | 159 | 15/212 (0.071) | 5 | 0.025 / 0.170 | 0.213 | 0.0027 / 0.0028 |
| 512 | 41 | 403 | 103 (0.256) | 92 | 11/300 (0.037) | 5 | 0.016 / 0.111 | 0.112 | 0.0007 / 0.0006 |
| 1024 | 41 | 408 | 96 (0.235) | 76 | 20/323 (0.062) | 5 | 0.012 / 0.148 | 0.159 | 0.0002 / 0.0002 |
| 2048 | 41 | 519 | 53 (0.102) | 50 | 3/464 (0.006) | 2 | 0.003 / 0.086 | 0.082 | 0 / 0 |
| 4096 | 41 | 681 | 56 (0.082) | 50 | 6/625 (0.010) | 5 | 0.006 / 0.067 | 0.066 | 0 / 0 |
| 8192 | 41 | 608 | 52 (0.086) | 50 | 2/553 (0.004) | 2 | 0.003 / 0.055 | 0.055 | 0 / 0 |
| 16384 | 41 | 691 | 55 (0.080) | 52 | 3/632 (0.005) | 3 | 0.003 / 0.060 | 0.060 | 0 / 0 |
| all | | 4499 | 1047 (0.233) | 961 | 86/3364 (0.026) | | | | |

- The median fit has spurious share 0 at every n. Fits with a spurious share above 0.1: 1, 2, 11, 8, 6, 3, 2 at
  n = 16 … 1024 and none from n = 2048 on; without the linear block's characters (upper bound: the sum of the other
  kinds' shares) 1, 2, 3, 4, 3, 2, 2 and none from 2048 on.
- Removing the spurious terms lowers the mean test error at n = 16–64 (by 0.006, 0.002 and 0.020; better in 1, 2 and
  10 fits, worse in 0, 0 and 1), mostly the linear block's characters at n = 64, and changes it by ≤ 0.0002 from
  n = 128 on (+0.00018, +0.00011 and −0.00015 at n = 128, 256 and 512, which the table's 4 decimals hide; better in 4,
  1, 1 fits at n = 128–512, worse in 4, 2, 0; no change from 1024 on).
- The atlas's statement for the families (ATLAS.md §2.2: spurious shares ≤ 0.1 at n = 16384 for 36 of 37 targets)
  holds here for all 41 targets from n = 2048 on.

### 2.2 What they are

(Numerical, `calib.json` `A2.top_terms`, `A2.spur_excl_lin_by_cat_round`, `A2.r0_chi_test_spur`, `A2.r0_class_searches`;
the term lists in `calib_tables.txt`.)
- **The linear block's characters: 961 of the 1047** spurious terms. The block tests the whole degree-1 vector at once
  and then adds every input not yet in the model, so whenever it passes, the target's 20–29 irrelevant inputs come in
  with its relevant ones. It entered in 10 fits at n = 64, 8 at 128, 7 at 256, 4 at 512, 3 at 1024 and 2 at each n
  from 2048 on. Its share is at most 0.80 at n = 64 (rand1; and3 0.715, maj3 0.536, rmaj9 0.501, thr10 0.459, maj9
  0.442, dlist5 0.441, rf15 0.441, rf08 0.425, rf13 0.001) and at most 0.031 from n = 2048 on. Once it entered on a
  target with no degree-1 weight at all: par3 at n = 16384, in round 0 next to the parity character, at ratio 1.04
  (share 0.0065), an event of the kind §1.4 measures on noise.
- **Characters admitted by their own test: 7 of the 3029.** Two in round 0, each wholly on irrelevant inputs: rf02 at
  n = 128 (χ{x22, x28}, share 0.063) and rf04 at n = 4096 (χ{x15, x21, x28}, share 0.010). P-A′ bounds this event per
  fit and class: over the 2460 round-0 class searches of these fits the expected number is ≤ 29.8 by the bound and
  2.2 under the independent-Gaussian approximation; 2 occurred. The other five are in round 1 of rand2 at n = 1024,
  each containing input 8, which a product block admitted in round 0 had brought into the model (shares ≤ 0.007): once
  a spurious term is in the model, its residual correlates with characters on its irrelevant inputs. In 7 of the 23
  fits with a spurious term (other than the linear block's) admitted after round 0, an earlier round had admitted a
  spurious term.
- **Spectral features: 20** (1 in round 0, 19 later; 15 of them at n = 128–256), with 7–59% of |u|² on relevant
  inputs (dnf3 at 16384: 89%), shares ≤ 0.17 (rf00 at 128) and ≤ 0.033 from n = 512 on. The 15 at n = 128–256 all
  entered after round 0, near n = 4d, where §1.4 finds the spectral edge too low for residuals whose large entries sit
  on a minority of the rows; after a partial fit the residual is concentrated on the rows the model still gets wrong,
  so they are plausibly the same effect (Heuristic; not tested here).
- **Sum blocks: 52** (19 in round 0, 33 later): 21 modulated blocks at n = 128–1024 whose sum or modulator includes
  irrelevant inputs (largest share 0.244, rand3 at 128; test error 0.049), 6 additive blocks at 256–1024, and 25
  products (product, candidate-pair and split moves) at every n ≥ 256 in which one factor reads irrelevant inputs. From
  n = 2048 on, 11 of the 14 spurious terms other than the linear block's characters are such products (the others:
  rf04's degree-3 character, and dnf3's spectral features at 4096 and 16384): rand0's product reading input 29 at
  every n from 2048 (shares 0.082, 0.066, 0.055, 0.060), rf06's at 4096–16384 (0.062, 0.037, 0.029), thr10's two at
  2048 (0.008, 0.013), dnf3's and rmaj9's at 4096 (0.010, 0.043). All have test error 0. This is the spurious-product
  quirk of the atlas (ATLAS.md §2.2) and of Part 10's v3 member.
- **Forced: 6 characters and 1 sum block** at n ≤ 64, in the fits where the cross-validation chose the forced variant:
  they carry the largest shares (rf09 at 16: 1.00; rf14 at 32: 0.61; stair5 at 32: 0.58 and 0.49; sparsepoly at 64:
  0.41; rf03 at 64: 0.36; rand1 at 64: 0.34), in fits with test error 0.129–0.498.

## 3. (B) Where the compute goes

### 3.0 Fits

- par4, maj9, mux, stair5 (designed), f7_07 (a modulated signed-sum target, `[−2 ≤ s ≤ 8]·x13`), f7_08 (a symmetric
  target, `[s ∈ {−11, −9, −3, 1, 9, 11}]`), f7_05 (mod 3, never learned) and pure noise (p = 0.5), at n = 64, 512, 4096
  and 16384, seed 0, as the evaluation fits them; and the seed-0 n = 16384 fit of the target with the largest FLOP
  count in three suites (h5s5 of dlheld5, fd_08 of dlfamdev, thr10 of designed): 35 cells. Added after the
  verification: the largest-FLOP fit of all the result files, h5s5 at n = 16384, seed 2 (`calib.py largest`,
  `results/largest.jsonl`; one record, made as rep 0 is).
- Each cell: one fit of the frozen module, then the instrumented fit (test error and FLOPs equal to the frozen fit's
  and to the result file's in every cell), then two more instrumented repeats for the CPU time (105 records; the
  repeats also equal the result files). The first 32 records (rep 0 of the first 32 cells) were written before the
  restart by an earlier version of `calib.py` that did not yet store the `rep` field; the summary reads a missing field
  as rep 0, and their FLOPs and test errors equal the frozen module's, the result files' and the later repeats'
  (`calib.json` `B.checks.records_without_rep`). CPU seconds are process time on a 4-core machine shared with 3–4
  evaluation workers at nice 10. Repeats of the same cell vary by up to 2.6× (largest / smallest of the three: median
  1.44, range 1.06–2.56 over the 35 cells; the instrumented against the frozen fit of rep 0: median ratio 1.00, range
  0.50–2.52), so CPU figures are medians of the three instrumented repeats; against the evaluation's recorded CPU of
  the same cells they are 0.44–1.40× (median 0.78). FLOPs are DFG's own counter (multiply-add = 2), deterministic.

### 3.1 FLOPs: the fixed-share searches set the count

**The round-0 global search, d = 30 (Proved, by reading the counter increments of `_fit`; Numerical check:
`round0_flops` in `calib_summary.py` equals the recorded deg 1–6 regions of all 275 `_fit` calls of the profile
(35 final fits and 240 fold fits), degrees 1–3 counted once per round that ran the search).** With the whole budget
(n > 512, scale 1) a search round adds exactly
- degrees 1–4 on all n rows: 2d + (2d² + d) + 28·(2d² + 2d) + 378·(2d² + 3d) = 768 390 FLOPs per row (the degree-3 loop
  visits a < d − 2, the degree-4 loop the 378 pairs (a, b) with b < d − 2; at d = 30 the budget shares of 3% and 15%
  would bind only at m = 87 307 and 29 627 rows, above 16384); degrees 1–3 (53 970 per row) again in every later
  round;
- in round 0, degree 5 on m₅ = min(n, 1374) rows and degree 6 on m₆ = min(n, 147) rows: 4.871·10⁹ and 4.850·10⁹ FLOPs
  at n ≥ 1374, each 0.030 of one network run (1.624·10¹¹ at d = 30).

So before anything else a fit costs 0.0571 of a network run at n = 1024 (m₅ = 1024), 0.079 at n = 4096 and 0.137 at
n = 16384, on any target; at n ≤ 512 the final fit gets half the budget (m₅ = 687, m₆ = 73: 0.0147 at n = 64, 0.0284 at
512) and the 2F fold fits (hi = False: no degree 5–6) the other half, of which they spend little (§3.4).

### 3.2 FLOPs by component

(Numerical, `results/prof.jsonl`, `calib.json` `B.cells`, `B.by_n`; per-cell tables in `calib_tables.txt`.) Percent of
the fit's FLOPs, range over the 8 profiled cells at each n (par4, maj9, mux, stair5, f7_07, f7_08, f7_05, noise):

| component | n = 64 | 512 | 4096 | 16384 |
|---|---|---|---|---|
| FLOPs / one network run | 0.020–0.026 | 0.048–0.063 | 0.079–0.109 | 0.137–0.166 |
| degrees 1–2 | 0.0 | 0.0 | 0.1 | 0.1 |
| degree 3 | 0.1–0.2 | 0.3–0.5 | 1.6–2.4 | 3.2–3.8 |
| degree 4 | 1.1–1.4 | 3.6–4.7 | 16.5–22.7 | 43.4–52.4 |
| degree 5 (subsample) | 5.4–6.9 | 17.9–23.4 | 27.4–37.8 | 18.1–21.8 |
| degree 6 (subsample) | 49.8–64.4 | 23.7–31.0 | 27.3–37.7 | 18.0–21.7 |
| extension and local | 0.0 | 0.0–0.3 | 0.0–1.3 | 0.0 |
| linear and spectral blocks | 0.0 | 0.0 | 0.0 | 0.0 |
| sum blocks | 0.0–0.9 | 0.0–2.0 | 0.0–5.7 | 0.0–1.8 |
| least squares | 0.0 | 0.0 | 0.0–1.3 | 0.0–0.9 |
| logistic readout | 0.0 | 0.0–0.4 | 0.0–18.0 | 0.0–14.5 |
| cross-validation fold fits | 27.2–42.6 | 40.6–52.0 | – | – |

- At n ≤ 512 the subsampled degree-5/6 search of the final fit and the fold fits are nearly all of it; from n = 4096 on
  the degree-4 search grows with n while degrees 5–6 stay fixed. On these 8 cells the target changes the count by at
  most 0.03 of a network run (f7_08 at 4096: 0.109, its readout 18%).
- **The largest fits are the ones with many features**: the three largest-FLOP cells (n = 16384) cost 0.431 (h5s5),
  0.471 (fd_08) and 0.323 (thr10) of a network run, of which the logistic readout is 46.9%, 42.9% and 41.4% (15 Newton
  steps at 2np² + p³/3 + 8np each, p features), degree 4 16.7%, 15.3%, 22.3%, least squares 7.6%, 9.6%, 4.4%, the sum
  blocks 6.1%, 6.1%, 4.6%, extensions 2.4%, 6.4%, 3.7%, and degrees 5 and 6 7.0% and 6.9%, 6.4% and 6.3%, 9.3% and
  9.2%. The largest fit of all, h5s5 at seed 2 (0.519 of a network run; 250 features, the constant included, after 7
  rounds; not a profiled cell, profiled after the verification, `calib.json` `largest`), spends less in the readout:
  37.1%, with degree 4 13.9%, least squares 12.9%, the sum blocks 8.6%, degree 3 8.1%, extensions 7.6%, and degrees 5
  and 6 5.8% each.

### 3.3 CPU time by component

(Numerical, as §3.2; CPU shares are medians over the three repeats.) Percent of the fit's CPU time, range over the
same 8 cells:

| component | n = 64 | 512 | 4096 | 16384 |
|---|---|---|---|---|
| CPU seconds per fit | 0.83–5.26 | 0.54–4.67 | 0.86–2.37 | 1.43–2.65 |
| degree 4 | 0.2–1.0 | 0.5–3.9 | 7.6–22.2 | 25.9–46.2 |
| degree 5 (subsample) | 0.4–2.8 | 2.7–19.2 | 10.4–31.4 | 10.5–20.5 |
| degree 6 (subsample) | 4.0–60.5 | 9.5–31.7 | 12.2–49.3 | 16.7–46.2 |
| sum blocks (final fit) | 0.0–4.1 | 0.0–8.4 | 0.0–67.2 | 0.0–25.0 |
| logistic readout | 0.0 | 0.0–0.1 | 0.1–4.1 | 0.1–6.3 |
| cross-validation fold fits | 24.9–91.4 | 38.4–82.9 | – | – |

- **The fold fits' CPU is the sum-block search.** Without par4 (its parity passes in round 0 of the final and of every
  fold fit; the round's character then explains the residual and no block search runs: 0.83 s at n = 64), the fold
  fits take 79.4–91.4% of the CPU at n = 64 and 52.4–82.9% at 512, and inside them the sum-block search takes 94.2–94.7%
  of the CPU for 41.6–46.0% of the FLOPs at n = 64 (85.1–93.2% for 13.7–29.0% at 512), while the degree-4 search takes
  3.9–4.4% of the CPU for 45.6–50.0% of the FLOPs (5.0–12.8% for 56.0–79.4%). In the final fit at n ≥ 4096 the
  sum-block search is up to 67% of the CPU (f7_08 at 4096) for at most 5.7% of the FLOPs.
- **Rates** (the final fits' regions pooled over the 35 cells, rep-0 FLOPs over the median CPU of the three repeats;
  `calib.json` `B.rate`): the character searches of degrees 3–5 and the extensions run at 16.5–17.6 GFLOP/s, degree 6
  at 7.8, least squares and the logistic readout at 32 and 33, the sum-block search at 0.75, and the fold fits as a
  whole at 0.97 GFLOP/s. Inside the fold fits, where most of the sum-block CPU at n ≤ 512 is spent, the sum-block
  search runs at 0.27 GFLOP/s with the same pooling (0.39 over every call and repeat; `B.rate_sum_folds`).
- **The three largest-FLOP cells** take 7.82 s (h5s5), 9.08 s (fd_08) and 5.06 s (thr10): the sum-block search 63.8%,
  61.2% and 53.5% of it for 4.6–6.1% of the FLOPs, the logistic readout 11.1–11.7% for 41–47% of the FLOPs.

### 3.4 Every suite, from the result files

(Numerical, `part11/results/toy__dfg13-perm__<suite>.json`, all 4730 fits of the 14 files; `calib.json` `files`,
`files_summary`.) FLOPs are those the evaluation recorded; one network run is `harness.gd_flops(d)` (1.47·10¹¹,
1.62·10¹¹, 1.93·10¹¹ and 5.06·10¹¹ FLOPs at d = 15, 30, 60, 120; 40000 steps at d = 120).

**Largest FLOPs per fit, as a fraction of one network run**, by n:

| suite (d; targets × seeds) | 16 | 32 | 64 | 128 | 256 | 512 | 1024 | 2048 | 4096 | 8192 | 16384 | largest (target) |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| designed (30; 21 × 3) | 0.000 | 0.000 | 0.031 | 0.039 | 0.050 | 0.090 | 0.077 | 0.137 | 0.167 | 0.204 | 0.372 | 0.372 (thr10) |
| random (30; 20 × 2) | 0.000 | 0.001 | 0.031 | 0.034 | 0.037 | 0.059 | 0.059 | 0.073 | 0.084 | 0.105 | 0.154 | 0.154 (rf06) |
| dlheld (30; 12 × 3) | 0.000 | 0.000 | 0.030 | 0.035 | 0.049 | 0.085 | 0.068 | 0.114 | 0.175 | 0.246 | 0.420 | 0.420 (inter2) |
| dlheld2 (30; 7 × 3) | 0.000 | 0.000 | 0.029 | 0.037 | 0.048 | 0.080 | 0.064 | 0.093 | 0.133 | 0.203 | 0.307 | 0.307 (thr20) |
| dlheld3 (30; 10 × 3) | 0.000 | 0.000 | 0.032 | 0.034 | 0.048 | 0.096 | 0.066 | 0.094 | 0.131 | 0.208 | 0.275 | 0.275 (dlist8) |
| dlsymdev (30; 8 × 3) | 0.000 | 0.000 | 0.029 | 0.033 | 0.039 | 0.058 | 0.059 | 0.072 | 0.083 | 0.112 | 0.163 | 0.163 (twosym) |
| dlheld4 (30; 12 × 3) | 0.000 | 0.001 | 0.032 | 0.035 | 0.048 | 0.080 | 0.062 | 0.083 | 0.085 | 0.111 | 0.162 | 0.162 (symand) |
| dlheld5 (30; 12 × 3) | 0.000 | 0.000 | 0.033 | 0.035 | 0.048 | 0.069 | 0.063 | 0.094 | 0.198 | 0.302 | 0.519 | 0.519 (h5s5) |
| dlheld6 (30; 12 × 3) | 0.000 | 0.000 | 0.029 | 0.034 | 0.045 | 0.078 | 0.066 | 0.112 | 0.177 | 0.232 | 0.420 | 0.420 (h6_09) |
| dlfamdev (30; 12 × 3) | 0.000 | 0.000 | 0.030 | 0.037 | 0.048 | 0.085 | 0.064 | 0.112 | 0.200 | 0.312 | 0.471 | 0.471 (fd_08) |
| dlheld7 (30; 12 × 3) | 0.000 | 0.000 | 0.033 | 0.035 | 0.046 | 0.069 | 0.067 | 0.110 | 0.166 | 0.263 | 0.380 | 0.380 (f7_04) |
| designed_d15 (15; 7 × 2) | 0.000 | 0.000 | 0.004 | 0.005 | 0.004 | 0.006 | 0.004 | 0.010 | 0.017 | 0.036 | 0.067 | 0.067 (maj9) |
| designed_d60 (60; 7 × 2) | 0.000 | 0.003 | 0.093 | 0.102 | 0.105 | 0.136 | 0.069 | 0.137 | 0.152 | 0.164 | 0.177 | 0.177 (maj9) |
| designed_d120 (120; 4 × 2) | 0.001 | 0.015 | 0.057 | 0.089 | 0.112 | 0.111 | 0.153 | 0.161 | 0.175 | 0.178 | 0.179 | 0.179 (maj9) |

- No fit uses more than 0.519 of a network run (dlheld5's h5s5 at n = 16384, seed 2); at d = 30 every fit at
  n ≤ 512 stays below 0.096. Every largest-FLOP cell is at n = 16384.
- DFG's own cap (a round starts only while a `_fit` call has spent ≤ 0.75 of its budget, `gd_flops(d)` × scale) never
  binds where it was recorded: no stop by it in any of the 6786 recorded `_fit` calls (A1: 660 final and 5400 fold
  fits; A2: 451 final fits; B: 35 final and 240 fold fits), and the largest share of its own budget any of them spent is
  0.471 (fd_08, a final fit) and 0.313 for a fold fit (`calib.json` `budget_cap`). In the result files it cannot have
  bound on a final fit: at n > 512 that is the fit's only call (≤ 0.519 of a network run against a cap of 0.75), and at
  n ≤ 512 the whole fit stays below 0.096 at d = 30 and below 0.137 at every d (designed_d60 reaches 0.136;
  `calib.json` `files_summary.max_n512_by_d`) against the final fit's cap of 0.375; the fold fits' calls are not
  recorded there.
- The *median* fit at d = 30 is nearly the same in every suite up to n = 4096 (0.025–0.026 at n = 64, 0.079–0.085 at
  n = 4096), i.e. the fixed-share searches of §3.1; at n = 16384 the suite medians spread more, 0.138–0.182
  (`calib_tables.txt`, median table). The largest fits are the targets with many features (§3.2).
- At d = 60 and 120 the count is flatter in n (largest fit 0.14–0.18 from n = 2048 on) because the degree-4 search is
  subsampled (m₄ = 2212 and 364 rows) and the degree-5/6 search is skipped (its budgeted m is 47 and 3 rows for degree
  5, below 64); at d = 15 it is 0.067 at most.

**CPU seconds per fit** (harness: process time around `fit`, recorded under the evaluation's 4-worker load), median
(largest), by n:

| suite (d) | 16 | 32 | 64 | 128 | 256 | 512 | 1024 | 2048 | 4096 | 8192 | 16384 | largest |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| designed (30) | 0.02 (0.0) | 0.16 (0.6) | 7.13 (15.2) | 4.72 (11.8) | 3.40 (9.8) | 3.43 (15.5) | 0.89 (5.1) | 1.38 (9.6) | 1.50 (7.4) | 1.75 (6.3) | 2.25 (6.4) | 15.5 |
| random (30) | 0.02 (0.0) | 0.17 (0.7) | 7.88 (13.6) | 3.82 (8.9) | 2.20 (5.3) | 2.30 (5.6) | 0.66 (1.6) | 0.76 (1.6) | 0.91 (2.0) | 1.26 (2.1) | 1.67 (2.3) | 13.6 |
| dlheld (30) | 0.02 (0.0) | 0.17 (0.9) | 6.77 (11.0) | 6.06 (8.9) | 6.08 (9.6) | 5.09 (13.2) | 1.24 (3.3) | 1.59 (8.1) | 1.70 (7.1) | 1.95 (6.9) | 2.39 (10.2) | 13.2 |
| dlheld2 (30) | 0.02 (0.0) | 0.15 (0.4) | 7.39 (12.0) | 6.28 (9.8) | 6.01 (9.8) | 5.96 (11.8) | 1.44 (2.9) | 1.63 (4.5) | 1.63 (5.6) | 1.73 (6.5) | 2.50 (11.1) | 12.0 |
| dlheld3 (30) | 0.02 (0.0) | 0.16 (0.5) | 7.96 (13.4) | 6.28 (8.9) | 6.59 (10.9) | 6.58 (17.4) | 1.36 (2.7) | 2.09 (3.2) | 2.04 (4.0) | 1.83 (4.4) | 2.50 (4.0) | 17.4 |
| dlsymdev (30) | 0.02 (0.0) | 0.15 (0.3) | 7.07 (11.6) | 4.21 (7.8) | 2.87 (5.9) | 3.59 (6.9) | 0.94 (2.2) | 1.53 (2.4) | 1.72 (2.7) | 1.90 (2.7) | 2.70 (3.6) | 11.6 |
| dlheld4 (30) | 0.02 (0.0) | 0.16 (0.7) | 7.31 (14.7) | 5.29 (8.4) | 4.28 (8.6) | 3.79 (12.6) | 1.23 (2.3) | 1.42 (2.4) | 1.55 (3.0) | 1.77 (2.5) | 2.47 (3.2) | 14.7 |
| dlheld5 (30) | 0.02 (0.0) | 0.15 (0.5) | 7.35 (13.8) | 5.02 (9.4) | 4.43 (9.8) | 5.01 (8.2) | 1.33 (2.1) | 1.75 (3.9) | 2.09 (11.3) | 2.38 (10.8) | 2.81 (15.5) | 15.5 |
| dlheld6 (30) | 0.02 (0.0) | 0.16 (0.5) | 7.31 (11.1) | 5.00 (9.7) | 5.43 (8.2) | 5.70 (13.5) | 1.85 (3.1) | 2.04 (5.4) | 1.94 (9.4) | 2.31 (5.7) | 2.70 (8.6) | 13.5 |
| dlfamdev (30) | 0.02 (0.0) | 0.15 (0.4) | 7.48 (12.9) | 5.79 (10.0) | 4.85 (9.3) | 4.45 (14.7) | 1.40 (2.4) | 1.72 (4.1) | 1.90 (11.3) | 2.30 (13.0) | 2.68 (11.6) | 14.7 |
| dlheld7 (30) | 0.02 (0.0) | 0.16 (0.4) | 7.81 (16.6) | 6.31 (10.9) | 4.54 (9.2) | 5.78 (10.6) | 1.38 (2.9) | 2.13 (5.8) | 1.85 (7.8) | 1.92 (8.5) | 2.30 (6.1) | 16.6 |
| designed_d15 (15) | 0.01 (0.0) | 0.08 (0.5) | 2.42 (4.5) | 1.26 (4.2) | 0.88 (2.1) | 0.96 (1.6) | 0.04 (0.3) | 0.08 (0.5) | 0.13 (0.4) | 0.34 (1.0) | 0.66 (1.0) | 4.5 |
| designed_d60 (60) | 0.03 (0.0) | 0.26 (0.4) | 9.18 (12.4) | 5.52 (13.1) | 3.36 (6.5) | 4.12 (8.2) | 0.83 (1.4) | 1.30 (2.5) | 1.54 (2.6) | 1.56 (2.5) | 1.62 (2.8) | 13.1 |
| designed_d120 (120) | 0.04 (0.1) | 1.23 (1.5) | 8.05 (15.3) | 6.41 (16.2) | 3.50 (7.8) | 4.44 (10.0) | 3.00 (4.0) | 3.27 (5.4) | 3.37 (6.0) | 3.31 (5.9) | 3.39 (5.5) | 16.2 |

- CPU time does not follow FLOPs: the slowest fits are at n = 64–512 (suite medians 2.2–9.2 s at d ≥ 30; largest
  17.4 s), where the FLOP count is smallest, because of the fold fits' sum-block searches (§3.3); at n = 1024 (no
  cross-validation) the median drops to 0.66–3.0 s at d ≥ 30 (0.04 s at d = 15) and then grows slowly with n.
- For scale (Heuristic, not re-measured here): Part 6 (`discrete_learner/DISCRETE-LEARNER.md`) reports the networks at
  32–50 GFLOP/s (float32 under XLA; an audit timing), i.e. 3.2–5.1 CPU s for one network run at d = 30; DFG's medians
  at d = 30 are 0.43–2.45 of that at n = 64–512 and 0.13–0.87 of it from n = 1024 on. The networks' CPU time is not in
  the result files.

## 4. Caveats

- A1 measures the frozen learner on two label rates and two dimensions, and the spectral block's false admissions
  depend strongly on both (§1.4: 99% of null draws at d = 120 near n = 4d); the rates of rare events have wide
  intervals (0/220: ≤ 0.017). The level bounds P-A and P-A′ cover only round 0 of the global character classes.
- The binomial tails of §1.3–1.4 treat the tests as independent, but the n of one seed share their rows, which makes
  that seed's tests positively dependent (for degree 1 this raises P(X ≥ 2) from 0.053 to 0.063, §1.3).
- The identity checks of §0 cover 88 of the 660 A1 fits and none of the 800 cascade re-runs; for those the argument is
  the syntax-tree comparison.
- The fold-fit records keep each admission's kind and degree, not its round or its set: "after a forced one" rests on
  the pairing with the default fold fit on the same rows (exact, as `_fit` is deterministic), and "χ_A χ_B" on degrees
  (185 of the 205 local characters at d = 30, P(y = 1) = 0.8 provably). The cascade re-run keeps the sets.
- A2 counts terms, not columns: a sum block is one term however many level indicators it has. The spurious share
  without the linear block's characters is bracketed (largest kind's share, sum of the kinds' shares), because the
  records keep each kind's summed contribution but not every term's.
- B's CPU times come from a shared machine and vary by up to 2.6× between repeats; the FLOP shares are exact.
- The cascade re-run (§1.5) emulates the fold fits (n = 29 and 58, scale 1/40, the forced variant) on fresh noise; it
  is not the evaluation's own fold fits, which the records of §1.5 count directly.
