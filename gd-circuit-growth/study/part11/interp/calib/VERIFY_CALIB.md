# Verification of CALIB.md (Part 11, Q7: false admissions and where the compute goes)

Independent verification of `CALIB.md` and its records (`results/{noise,spur,prof,cascade}.jsonl`, `calib.json`,
`calib_tables.txt`), the instrumented copy `dfg13_instr.py` and the scripts `make_instr.py`, `calib.py`, `calib_rec.py`
and `calib_summary.py`. Written 3 November 2026. The structured version is in [`VERIFY_CALIB.json`](VERIFY_CALIB.json).
I did not edit the report or commit anything. Every computation ran single-threaded, one at a time, next to the
evaluation workers.

## Verdict

**Mostly confirmed, with 12 corrections and 1 important omission.**
- **What holds:**
  - The instrumented copy is the frozen learner.
  - Every headline count of A1, A2 and B reproduces from the raw records with my own code (I did not use
    `calib_summary.py`).
  - 17 independent refits of the frozen module equal the records or result files bit for bit. Each used my own data
    and test-set generation and read the model from the fit's closure. They are 8 A1 cells (7 of them never checked by
    the report), 7 A2 cells, and the largest-FLOP fit h5s5 at seeds 0 and 2.
  - P-A and P-A′ hold as stated.
  - The round-0 FLOP formula is exact on all 825 recorded `_fit` calls.
- **What needs correcting:** wording ("every fit was checked", "exactly the χ²_d tail", "after the forced ones", "the
  sum-block tests never passed"), a few numbers (spectral rates, a binomial tail, an error change, a readout share,
  one subsample size, one cascade count), the scope of a GFLOP/s rate, and one step of P-A's proof.
- **The omission:** the spectral block's null pass rate on biased labels near n = 4d rises steeply with d and with
  label bias. It reaches 99% at d = 120 (n = 512, P(y = 1) = 0.8) and 39% at d = 30 with P(y = 1) = 0.9. The report
  measured only d ∈ {30, 60} and P(y = 1) ∈ {0.5, 0.8}.

## What I did (own code paths; scripts listed at the end)

1. **Instrumented copy.**
   - Rebuilt it with a scratch copy of `make_instr.py`, with only the output path changed: the result is
     byte-identical (md5 `be56ce50963f2f7fc513ab82616cbcc7`).
   - `diff` against `dfg13.py` shows 64 added lines and none removed or changed.
   - AST check: deleting the 65 `_P.*` expression statements (on 64 lines; one line holds two) and the recorder import
     leaves an AST identical to `dfg13.py`'s. So no inserted line changes block structure, and the hook arguments call
     only `len`.
   - I read `calib_rec.Rec` in full: it reads `fl[0]`, the clock and its arguments, and writes only to its own
     dicts and lists.
2. **A1.**
   - Regenerated the training and test data from the harness recipe with my own code.
   - Recomputed the round-0 g1/g2/linear/spectral statistics for 46 records: they agree to 1e-5. The one exception is
     explained: DFG zeroes a passing degree-2 pair before the eigendecomposition.
   - Recomputed every A1 count, interval and table from the records.
   - Paired each forced fold fit with the default fold fit on the same rows.
   - Ran my own null Monte Carlo of the round-0 tests, mirroring `_fit`.
   - Computed the degree-1 class's null pass probability exactly for every (p, n), by a binomial convolution
     conditional on the labels, and validated it against simulation within 1 SE.
3. **A2.**
   - Read `boolfuncs.py` and recomputed all 41 relevant sets by exhaustive enumeration.
   - Recomputed every A2 table from `spur.jsonl`.
   - Refitted 7 cells with my own term decomposition from the model's closure and `Permuted`'s `pi`.
4. **B.**
   - Re-derived each FLOP-counter increment from `dfg13.py` and checked my own formula against the recorded g1–g6
     regions of all 825 recorded calls (0 mismatches).
   - Recomputed the FLOP and CPU shares, rates and variation statistics, both with the report's method and with
     alternatives.
   - Recomputed all §3.4 tables from the 14 result files.
   - Checked the budget cap over all 6786 calls.
   - Refitted the largest-FLOP fit.

## Claims

### §0 The instrumented copy

| claim | status | evidence / correction |
|---|---|---|
| 64 lines added, none changed; rebuild byte-identical (md5 `be56ce50…`); hooks only read | **confirmed** | Rebuild, `diff` and the AST equivalence above; `calib_rec` reviewed. |
| "Every fit made with it equals a fit of the frozen module … or the evaluation's result file": 88/88 A1, 451/451 A2, 35/35 B against the frozen module; 31 cells (93/93 records) against the files | **corrected** | The counts are right. My 8 A1 refits are all equal, 7 of them in cells the report never checked (30:0.8:64:7, 30:0.8:16384:18, 30:0.5:256:13, 60:0.5:512:5, 60:0.8:256:5, 30:0.5:4096:11, 60:0.5:8192:4). **Correction:** 572 of the 660 A1 fits and all 800 cascade fits have no identity check, so say "every *checked* fit". The claim holds for all fits because of the AST equivalence and the read-only hooks, not because of the checks. |

### §1 (A1) False admissions on labels independent of the inputs

| claim | status | evidence / correction |
|---|---|---|
| **P-A** (Proved): each round-0 global class has level ≤ δ/(2K) = 0.0125 | **corrected (proof only)** | **Statement:** checked line by line against `dfg13.py`, and it holds. The checks: `lsfit`'s ridge is zero on the constant; `thr` uses `self.K` = 4 in every round; the degree-3/4 loops (a < d−2; pairs with b < d−2) cover all C(d,3) and C(d,4) subsets; the degree-5/6 entries over disjoint pairs equal mean(r χ_{T1∪T2}); `thr_m` reduces to c·rms(r₁..ₘ)·√(2L/m); Hoeffding plus the union bound give 2N e^{−L} = δ/(2K). The bound also covers fold fits and both CV variants. **Proof gap:** `s = sqrt(max(mean r², 1e-12))` is never < 1e−6, because `sqrt(1e-12)` is exactly `1e-06`. So "(if s < 10⁻⁶ the loop stops before any test)" is vacuous. With all labels equal, the m = n tests run with s = 1e−6 > rms(r) and the claimed "iff" fails. This happens in 2 A1 final fits, 30:0.8:16:14 and :19, whose recorded s is 1e−06. **Fix:** with s = max(rms r, 1e−6) ≥ rms r, the m = n pass event is contained in the event with s = rms r, and the m < n tests use rms(r₁..ₘ) exactly, so the bound holds in every case. |
| **P-A′** (Proved): (N_irr/N)·δ/(2K) for characters reading an irrelevant input | **confirmed** | Each step checked. Like P-A, it needs iid uniform rows (true of the harness data) and holds in learner coordinates under `Permuted`. |
| d = 30, p = 0.5: 0/220 test-passed (≤ 0.017). 5/220 with features, all forced (5/120 CV), errors 0.491–0.500. 215 fits stop in round 0 | **confirmed** | Recomputed. Refit of 30:0.5:256:13 reproduces it. |
| d = 30, p = 0.8: 6/220 (0.010–0.058). Linear block 1.10 and 1.07 (errors 0.336, 0.283); spectral 1.011 and 1.054, second feature at 1.083 (0.234, 0.213); degree-1 characters (0.244, 0.195). CV forced 0/120 | **confirmed** | Recomputed: 1.1034, 1.0723, 1.0114, 1.0540, 1.0833. Refits of 30:0.8:128:0, 30:0.8:64:7 and 30:0.8:16384:18 reproduce them. |
| d = 60: 5/110 balanced (linear 3, degree-2 1, local product 1); 6/110 biased (spectral 5 at n = 256, linear 1); CV forced 2/60 and 0/60; the seed-5 product | **confirmed** | Refit of 60:0.5:512:5: forced characters {14,22,29,45} and {26,32,50}, then the local character {14,22,26,29,32,45,50}, exactly their product. |
| §1.3 per-class tests and passes (440/440/400/400/360/360 with 2/0/0/0/0/0; 220/220/200/200 with 0/1/0/0), later rounds, median max-ratios | **corrected (one header)** | Everything recomputes. **Correction:** the header "degree 6 (m = min(n, 147))" is wrong at n = 128–512. There the final fit has half the budget and the records show m₆ = 73. |
| "5 of 6 classes are compatible with ~0.001 (degree 1: 2/440 where 0.5 is expected)"; P(≥ 2 degree-1 passes in 440) = 0.082 | **corrected** | The exact degree-1 null rates are 0 at n = 16, 0.00004–0.00045 at n = 32, 0.0002–0.0008 at n = 64, and ≈ 0.00113 for large n. The report's 0.108% is consistent with the exact 0.094% averaged over its four MC cells. **Correction:** over the 440 tests the expected count is 0.37 and P(X ≥ 2) = **0.053**. Degree 1's CI (0.0006–0.016) contains 0.0012, so **all 6** classes are compatible. |
| Linear block: null rates 0.84% (d = 30) and 1.04% (d = 60); 2/360 and 4/160 observed; "passes at the exact χ²_d tail" | **corrected (wording)** | The numbers recompute. My MC gives 0.85% (28 000 draws) and 0.95%. **Correction:** at d = 30, the pooled 108 000 draws give 0.845% (CI 0.79–0.90%), which **excludes** the exact χ²₃₀ tail of 0.921%. The statistic, a sum of squared Rademacher sums, has a lighter tail than χ²_d. Say "close to the χ²_d tail (0.84% against 0.92%; 1.04% against 1.05%)". |
| Spectral block, biased labels, near n = 4d: 5.7% (d = 30, n = 128) and 48% (d = 60, n = 256); fits 2/20 and 5/10; balanced ≤ 3/20 000 | **corrected** | The 5.7% and 48% are the 2000- and 1000-draw estimates. The report's own 20 000-draw estimates are 5.39% and 46.8%; my MC gives 5.0% and 45.6%; pooled, **≈ 5.3% and ≈ 47%**. "Not conservative" is meant relative to the ≈ 1% of the other dense test. Against the δ = 0.1 in its own margin it fails only at d = 60, and more at larger d (omission 1). |
| "The sum-block tests never passed" (0/2000 round-0, 0/153 later; maxima 0.86, 0.93) | **corrected (scope)** | True for the 660 final fits (maxima 0.863 and 0.927 recompute). **Correction:** in the fold fits, which run the same round-0 search on noise, the *default* variant admitted sum blocks in round 0 twice: d = 30, p = 0.8, n = 64 seed 17 fold 7 and n = 128 seed 19 fold 4. Forced fold fits admitted test-passed sum blocks in 24 (d = 30) and 7 (d = 60) fits. |
| Forced fold fits with "a test-passed feature after the forced ones": 12/900, 238/900 (205 local); 14/450, 150/450 | **corrected** | All counts, by-n splits and kinds recompute. 185 of the 205 local characters (d = 30, p = 0.8) are provably χ_Aχ_B from the records: their degree is the sum of the two forced degrees and no other character is present. **Correction:** each forced fold fit pairs with the default fold fit on the same rows. Where that default fit admitted something, the forced fit made the same admission in round 0, *before* any forcing: 9 fits at d = 30, p = 0.8 (two forced nothing at all), 2 at p = 0.5, and 2 and 7 at d = 60. After a forced feature: **229/900, 10/900, 12/450, 143/450**. |
| Cascade: 244/334 against 0/334; every local admission after two forced A, B with degree \|A Δ B\| (4/4, 2/2, 116/116, 98/98); χ_Aχ_B where disjoint; 4 of 731 second forced characters local | **corrected (one count)** | The table recomputes, and `_local_test` matches DFG's local class. **Correction:** at p = 0.8, n = 58, DFG admitted a local character in 99 fits, not 98. In fit 30:0.8:58:34 the local character followed one forced character, one forced sum block and a test-passed degree-1 character. So "every … after two forced characters" holds in 220 of 221 fits. |
| Test error on noise; err = a + q(1 − 2a) within 0.001 (d = 30, p = 0.8); Φ predictions; the kernel background as the cause | **confirmed** | Recomputed with my own test sets: largest gap 0.0008; all Φ values recompute. The identity holds for any label-independent predictor. The attribution follows from the code: 214 of the 220 biased fits have no feature, so their decision value is exactly w₀ + x·bg. Minor: at d = 60, n = 2048 the mean error is 0.2003, not yet 0.2002. |
| Marchenko–Pastur heuristic ratios (0.99, 1.08, 0.89, 0.97, ≤ 0.74) | **confirmed** (heuristic) | Arithmetic recomputes. |

### §2 (A2) Spurious features

| claim | status | evidence / correction |
|---|---|---|
| Relevant sets exact, equal to the suites' lists (41/41) | **confirmed** | From reading `boolfuncs.py` (every target reads only x[:, :10]) and my exhaustive enumeration. |
| 4499 terms, 1047 spurious (0.233), 961 linear-block characters, others 86/3364 (0.026); the §2.1 table | **confirmed** | Every column recomputes. |
| Spurious share of the output ≤ 0.086 from n = 2048 on (≤ 0.86 at n = 64); median 0 | **confirmed** | Recomputed. My 7 refits reproduce term counts, spurious counts and shares exactly: rf02@128 0.0632, rf04@4096 0.0099, rand0@2048 0.0857, rand1@64 0.8629, rand3@128 0.3711, par3@16384 0.0065, rand2@1024 0.1330. |
| Removing the spurious terms: −0.006, −0.002, −0.020 at n = 16–64; "≤ 0.0001 from n = 128 on" | **corrected** | The unrounded changes are +0.00018 (n = 128), +0.00011 (256), −0.00015 (512), then 0. **Correction:** ≤ 0.0002. |
| §2.2 details: linear-block entries and shares; 7/3029 tested characters spurious; P-A′ 29.8 against Gaussian 2.2 over 2460 searches, 2 observed; 20 spectral; 52 sum blocks; 14 at n ≥ 2048 (11 products); forced 6 + 1; 7 of 23 | **confirmed** | All recompute (29.77, 2.23). Every round-0 passing character was admitted in all 451 fits, so "2 occurred" counts exactly the class searches with an irrelevant pass. |

### §3 (B) Compute

| claim | status | evidence / correction |
|---|---|---|
| (Proved) 768 390 FLOPs per row for degrees 1–4 at d = 30; 53 970 for degrees 1–3; binding m = 87 307 and 29 627; degrees 5/6 4.871e9 and 4.850e9 = 0.030 each at n ≥ 1374; 0.0571 / 0.079 / 0.137 at n = 1024 / 4096 / 16384; 0.0147 and 0.0284 at n = 64 and 512 | **confirmed** | Re-derived from the code. My formula matches all 825 recorded calls (0 mismatches); closure error ≤ 2.1e−16. |
| §3.2 FLOP-share table; the three largest cells (0.431, 0.471, 0.323; readout 46.9, 42.9, 41.4%) | **confirmed** | Every entry recomputes. |
| "The largest fits (0.32–0.52 …) … the logistic readout is 41–47%" | **corrected** | The 41–47% comes from the three profiled seed-0 cells (0.32–0.47). The largest fit, h5s5 seed 2 at 0.519, was not profiled. **Correction:** I refitted it (FLOPs equal the file, 250 features); its readout is **37.1%** by the code's formula, which gives 46.9% for the profiled seed-0 cell, matching the record. |
| Sum-block search "at 0.75 GFLOP/s (all profile fits pooled)"; other rates; CPU-share tables; fold-internal shares (94–95% of CPU for 42–46% of FLOPs) | **corrected (scope)** | Reproduced exactly with the report's method. **Correction:** that method pools only the *final* fits' regions. Inside the fold fits, where most sum-block CPU at n ≤ 512 is spent, the sum-block search runs at **0.27 GFLOP/s** (0.39 over all calls and repeats). |
| CPU variation (§3.0): 1.44 (1.06–2.56); 1.00 (0.50–2.52); 0.78 (0.44–1.40) | **confirmed** | Recomputed. |
| §3.4: 4730 fits, max 0.519 (h5s5, 16384, seed 2); d = 30, n ≤ 512 < 0.096; all FLOP and CPU tables | **confirmed** | Recomputed from the 14 files. Minor: "the median fit … is the same in every suite" overstates n = 16384, where the medians range 0.138–0.182. |
| The budget cap never binds in 6786 recorded calls; largest spend 0.471 (final) and 0.313 (fold) | **confirmed** | No call ends above 0.75 of its own budget, so the cap cannot have fired. The result-file argument holds for every d, but its "below 0.096" is the d = 30 figure (d = 60 reaches 0.136, still below 0.375). |
| CPU is highest at n = 64–512 because of the fold fits' sum-block searches; Part 6 comparisons | **confirmed** | The numbers recompute, and the quotes are in `DISCRETE-LEARNER.md` as cited. |

## Omissions

1. **The spectral block at larger d or stronger label bias.** This is the important one. My null MC mirrors `_fit`'s
   round 0 and gives:
   - d = 120, P(y = 1) = 0.8: 397 of 400 pass (99%) at n = 512, the first grid n ≥ 4d, and 202 of 300 (67%) at
     n = 1024. At P(y = 1) = 0.5: 0 of 300.
   - d = 30, P(y = 1) = 0.9: 39% at n = 128 and 11% at n = 256.

   The report's own Marchenko–Pastur reading predicts this: at n = 4d the minority edge is fixed, while DFG's margin
   factor 1 + √(2 ln 10 / d) shrinks with d. So "falling to 0 by n = 1024 (d = 30) and 4096 (d = 60)" does not carry
   over to `designed_d120` or to strongly biased targets such as and3 (P(y = 1) = 1/8). The 15 spurious spectral
   features at n = 128–256 in A2 are plausibly the same effect; the report does not connect them.
2. **The sum-block test on noise.** The report shows no calibration for it, and its summary omits the round-0 passes
   in the default fold fits (§1 above).
3. **Identity checks.** They cover 88 of 660 A1 fits and none of the 800 cascade fits. The AST argument should be
   stated as the reason the rest can be trusted.
4. **The s floor in P-A's proof.** The proof does not handle it, and the all-equal-labels case actually occurs: in 2
   A1 final fits, and in 24 fold training sets (48 fold fits, both variants) at P(y = 1) = 0.8 with n = 16 and 32.
5. **What the fold records lack.** They store neither each admission's round nor the characters' sets. So "after the
   forced ones" and "χ_Aχ_B" can be checked for the evaluation's own fold fits only indirectly.
6. **Why the linear block sits below the χ²_d tail.** The lighter tail of a sum of squared Rademacher sums explains it,
   but the report does not say so.
7. **Provenance of the first 32 B records.** They were written before the restart and lack the `rep` field that the
   current `calib.py` writes, so an earlier version produced them. Their FLOPs equal everything else, but the report
   does not mention it.
8. **The Gaussian reference for degrees 5–6.** It assumes N independent statistics, but at m = 73–147 rows these
   N ≫ m statistics are strongly dependent. It is labelled heuristic, but the comparison says little for those
   classes.

## Reproduction

The scripts are in the session scratchpad,
`/tmp/claude-0/-home-user-AI-works/addd33f6-5c52-5bee-997e-3f98d4e90609/scratchpad/verify_calib/`:

| script | what it does |
|---|---|
| `make_instr_scratch.py`, `ast_check.py` | Rebuild and AST equivalence of the instrumented copy. |
| `v_a1.py`, `v_a1b.py`, `v_a1c.py`, `v_a1d.py`, `v_r0.py` | A1 counts, per-n tables, ratios, per-class tests, round-0 statistics from regenerated data. |
| `v_refit_a1.py` | 8 frozen-module refits of A1 cells. |
| `v_mc.py`, `v_mc2.py` | Null Monte Carlo of the round-0 tests. |
| `v_exact_g1.py`, `v_exact_chk.py`, `v_exact_all.py` | Exact degree-1 class null rates, their validation, and P(X ≥ 2). |
| `v_folds.py`, `v_casc.py` | Fold-fit pairing and the cascade table. |
| `v_a2.py`, `v_a2b.py`, `v_a2c.py`, `v_rel.py`, `v_refit_a2.py` | A2 tables, term details, relevant sets, 7 refits. |
| `v_b1.py` – `v_b5.py`, `v_h5s5.py` | FLOP formula on 825 calls, shares, rates, result files, the largest fit. |
| `v_mc120.py` | Spectral-block null at d = 120 and P(y = 1) = 0.9. |
| `write_json.py` | Writes `VERIFY_CALIB.json`. |
