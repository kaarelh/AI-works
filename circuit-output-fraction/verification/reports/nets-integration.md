# Trained networks: integration, referees and fixes

## Code owner: lower

I applied the synthesis's code recommendations to code/rareprob/nets_lower.py and turned every red-team counterexample into a regression test that now passes (code/tests/test_nets_lower.py, 34 tests). I then reran the method on everything requested with the final code: the d <= 28 exact suite, the suite's d = 64/128 nets (including bce_d64_w64_s100), and this lane's own nets, now renamed. The results are in experiments/nets_lower/results/ (summary.txt, plus tables.json for the paper's tables), and experiments/nets_lower/README.md describes the scripts and lists the corrected numbers.

The full test suite passes: 405 tests.

Every cost is reported both in forward-pass equivalents (fpe) and in wall-clock seconds. The machine is a shared 4-core machine; other agents' jobs pushed the load average to 7-9 during the runs, so the seconds are noisy.

One process slip: I accidentally ran `git rm --cached experiments/nets_lower/run_proposals.py`, which staged a deletion. I immediately ran `git restore --staged` on that one path, so the index is exactly as it was and nothing is staged. I then deleted the file with a plain `rm`; its content now lives in ablation.py. No other git command changed anything.

- forward_error_bound now computes Higham's bound in exact rationals with an underflow term of (2n+2)*2^-1075 per dot product, and rounds the result up. It covers every float64 evaluation built from correctly rounded additions, multiplications or FMAs, in any order, with gradual underflow. Fixes red-team attack_underflow nets A and B, the visible ball at d = 14/40/64, and attack_fma: the old code certified 0.97, 0.07, 9.3e-9 and 0.96 at exact p = 0; all now give 0.
- New hole found and closed: overflow. With the bound computed exactly, a net whose partial sums overflow (numpy itself returns a finite but wrong output, 0 against an exact 1.7e8) would have been certified. The bound is now refused (E* = inf, every bound 0) whenever any layer's bound H_l exceeds the largest float. NaN or inf weights or threshold are also undecided. Regression tests cover both.
- Non-finite scores are treated as undecided: the replicate is flagged and the input is never a witness. t_cert is now the largest float64 at or below t* - E*, computed exactly, replacing the old assert-based margin.
- Flagging now uses |s - t| < E* (strict), and t_cert sits at least E* below t*, so outputs exactly at the threshold are no longer flagged. On the red team's threshold_ties_bce net (p = 0.25) the old code got L = 0.046 (witnesses only); the new code gets 0.19 with 0 flagged replicates.
- Levels are now placed at 0.382 of the gap between neighbouring outputs instead of the midpoint. On lattice-valued nets (integer weights, the decoy) the midpoint was often itself an output value, which flagged 27-29% of replicates; now 0%. Any level placement is sound.
- Z is computed as the exact rational prod(c_k)/N^K and rounded down, replacing exp(sum of logs) times (1 - 1e-10). A flagged replicate now stops at its first flag.
- Kept in the library: lower_bound, run_smc, metropolis, pilot_plan, betting_lower, Witnesses, sequential mode, stratification, forward_error_bound. Moved to experiments/nets_lower/ablation.py: block Gibbs, pooled selection, soft levels, ARLogistic/KernelMixture proposals, and the clipped-KL and min-Markov rules, each with experiments comparing it to the method. In ablation.py's 20,000-replicate checks (one d = 12 net, exact target, nine configurations including 0-step Metropolis), every configuration's mean matches the exact target (|z| <= 1.2).
- mc_lower_samples now passes rel_err=0.0 explicitly (its mean is hypothetical, not a measured sum). This fixes test_final_callers.py, which was already failing at HEAD; behaviour is unchanged.
- Renamed this lane's nets to smc_* and smc2_* so they no longer collide with suite names. results/scaling_nets/index.json maps each to its old name with provenance. Two architectures were retrained bit-for-bit to recover their settings: bce 64x64 with lr 3e-4 and seed 4357; mse 32x32 with lr 1e-3 and seed 4356.
- Restructured the experiment scripts: common.py (shared helpers, fpe and wall-clock costs, parallel runner), run_scaling.py (now also runs the suite's d = 64/128 nets), adversarial_nets.py and run_adversarial.py (the red-team float attacks and its coverage campaign), mc_blocks.py (the red team's independent block Monte Carlo, with its 3 records), train_scaling_nets.py, and summarize.py (writes summary.txt and tables.json with headline numbers computed from the data).
- Corrected the misquoted numbers in README.md and in the computed headlines. Mean Z/p is 0.913-1.029 in this rerun (the design-round table had 0.926-1.139, not 0.93-1.01). For the d = 128, p = 2.9e-15 net: 0.821 at 6.9e6 in the old table, not 0.85; this rerun gives 0.854 at 6.8e6 and 0.940 at budget L. The 'polylogarithmic' cost claim is restated as cost linear in log(1/p) at fixed budget, valid only against p_ref and away from the far tail.

## Code owner: prover

I rewrote the verifier's SAFE/FAIL leaf checks in code/rareprob/nets_prover.py to use outward-rounded interval arithmetic. Every red-team attack is now caught and is a regression test, and the full suite was re-run. 

**Verifier.** Soundness no longer depends on the old fixed 2^-30 rounding budget. It rests on two facts about float64, both of which cover subnormal numbers and overflow:
- one rounded operation is enclosed by the `nextafter` values on either side of its result;
- a matrix product in any summation order (with or without FMA) errs by at most gamma_n |A||B| + n·2^-1074.

Each product's error is enclosed where it happens and carried through the later products. Non-finite values make a leaf undecided.

**Tests.** code/tests/test_nets_prover.py has 44 tests and runs in about 25 s. Against the previous verifier, 13 of them fail; all pass now.

**Suite results (d <= 28).** All 21 nets with exact p are certified exactly, and every count matches the suite's fail_count.
- Logistic-loss d = 28 nets give real wins:
  - p = 7.45e-9: 4.2 s end to end, against 69 s for enumeration and about 18.6 h for Monte Carlo.
  - p = 0 (bce_d28_w32_s150): certified in 1.4 s.
- Squared-loss d = 24 nets: the certificate wins over Monte Carlo in fpe for p <= 4e-4. End to end in wall-clock it wins only for p <~ 1e-5, and plain enumeration (5 to 6 s) beats prover plus verifier on every one of these nets.
- Two-hidden-layer nets: the prover's plan estimates the certificate at 1.2 to 2.3 times enumeration, so the argument is enumeration (200 to 500 s each).

**d = 64 attempt (bce_d64_w64_s1000, 111 minutes).** The full p = 0 certificate was not finished in the budget:
- 691 of 1024 pieces (67.5% of the cube) are certified exactly, all with 0 failing points.
- That took 2.99e7 nodes and 5.96e7 verifier fpe.
- Extrapolated, the whole certificate is 4.4e7 ± 0.1e7 nodes and 8.8e7 fpe. The remaining third needs about another hour of proving on 4 idle cores.

All times are from a shared 4-core machine with other CPU-bound jobs running.

**Full test suite.** `cd code && python3 -m pytest -q tests` gives 404 passed and 1 failed. The failure is `tests/test_final_callers.py::test_every_kl_interval_call_passes_rel_err`, which flags a `kl_interval` call without `rel_err` at `nets_lower.py:505`. That file belongs to another workstream and I did not touch it; the call in nets_prover.py passes `rel_err`.

- Underflow in the 'lin' check: subnormal products such as G*lambda used to round to zero and were then multiplied by first-layer weights near 1e289. Every matrix product is now enclosed as fl(AB) ± up(gamma_n·fl(|A||B|)(1+2 gamma_n) + 3n·2^-1074), and that uncertainty is carried through every later product. Regression tests: the hand-built net (true p = 1/2, which the old verifier reported as [0,0], exact) and random subnormal power-of-two rescalings (6 seeds).
- Underflow in the 'quad' check: G*kap rounding to zero used to drop the majorant term. Now G*kap, G*bet and G*gam are interval products, M is enclosed entrywise by interval-times-interval matrix products, and the PSD test covers every symmetric matrix in that enclosure. That test rescales exactly by a power of two, runs Cholesky of mid - cI, applies Higham's Theorem 10.3 with the underflow of products and divisions added, and then checks that c exceeds backward error + rounding of the shift + Frobenius norm of the radius, all rounded up. Regression tests: the three hand-built majorant nets, the malicious-theta minorant at output scale 2^-53 (old verifier certified 0.5475 S against a true minimum of 0.3 S), and random quad_sub rescalings (6 seeds), all attacked with the largest shift the verifier accepts, found by bisection.
- Drop rule: the side on which an unstable ReLU is relaxed is now chosen from the enclosure [G_lo, G_hi] of its exact backward coefficient. If the sign is not certain the unit is dropped and charged dn(G_lo * U), which is valid because 0 <= h <= U, so the rounding of G is covered. Regression test: the red team's two-hidden-layer net with t at the certified bound, plus its 40 ulp-neighbours.
- Quadratic pieces: kap and bet come from the prover's theta, and validity is proved by interval evaluation of the defining inequalities, with gam chosen as the best value the proof allows. The fallbacks are 0 from below and an exact chord from above. Every piece is checked in exact rational arithmetic in the tests.
- Chord slopes are now computed as up(U / dn(U - L)), valid by construction, so the old re-check against a rounding budget is gone.
- Non-finite values are treated as undecided: a certificate whose bound is not finite is rejected and the leaf is demoted. Points whose float value is NaN or infinite go to exact rational evaluation. Nets whose bounds overflow are no longer refused; the old 1e290 guard and the operation-count guard were removed. Subcube vectors are validated to lie in {-1,0,1}^d, which the layer-1 error bound needs.
- Point tolerance tau is now a layer-by-layer forward error bound (gamma terms plus the underflow of every product, propagated through |W|) with no absolute 2^-30 floor, so it scales with the net. Before, at output scale 2^-40 every point went to exact evaluation. Regression test: tau scales exactly with the output, and at most 2 exact evaluations are needed.
- Prover robustness: it no longer crashes on huge weights. Non-finite inputs are filtered before eigh and in the slope optimisation, and overflow warnings are silenced. Regression test: prover on first-layer rescalings by 2^450 to 2^1000, and on weights near 1e308.
- Prover/verifier agreement, found by my own soundness campaign: a quad certificate checked on batched enclosures was demoted by the verifier's single-subcube recomputation, giving a sound but non-exact answer. The prover now checks quad certificates exactly as the verifier does and accepts a leaf only if its bound clears t by 2^-30 |f|_abs (`cert_margin`). Regression test: test_prover_certificates_are_accepted_as_checked.
- Cost model: fpe now counts the flops the verifier actually performs, which is 2 to 4 times more per leaf than the old model of an incremental verifier that was never implemented. VerifyResult also reports wall-clock seconds and the number of exact rational re-evaluations (`exact_evals`).
- Prover speed: per node it is 2 to 10 times faster than before (0.3 ms/node at d = 64 in an uncontended test, against about 1.9 ms). This comes from early stopping in the slope ascent, prover-side floating-point strong branching with first-layer intervals updated incrementally for the children, and an optional warm start (off by default). The verifier went from 0.13 to about 0.02 ms/node.

## Code owner: verify-analytic

I fixed every soundness hole the adversarial review found in nets_verify.py and nets_analytic.py. Each red-team counterexample is now a regression test, and all of them pass: `cd code && python3 -m pytest -q tests` gives 459 passed (54 of them are new, 29 in test_nets_verify.py and 25 in test_nets_analytic.py). I trimmed nets_analytic.py to the agreed scope, ran the barrier table on all 30 suite nets, re-ran the p = 0 frequency/cost study, and corrected the overstated claims in the READMEs. All costs are given in forward-pass equivalents (fpe) and in wall-clock seconds; the machine is a shared 4-core machine, so the seconds are indicative only.

**nets_verify.py**
- bab (the engine without a prover) and milp_min (the witness finder) are kept.
- Overflow in the backward pass can no longer certify anything: a non-finite CROWN quantity now leaves the subcube undecided.
- The sampling stage now starts from the rounded-down count.
- r_enum < 0 and every former assert now raise explicit exceptions, so `python -O` no longer changes behaviour.
- New method Bounder.affine_lower(): an affine lower bound on f with a proved rounding margin. nets_analytic now uses it for its two-layer tilt.
- Docstrings now say that max_fpe is a conservative projection: a run can stop far below it, and res.fpe and res.seconds record what was actually spent.

**nets_analytic.py**
- Kept: the barrier diagnostics (symmetric gap / cube barrier, decoupling floor with chernoff_holder, box tilt), the sign-pattern envelope, the cube tilt and perturb-and-MAP. Also kept, with the requested fixes: mcdiarmid, small_width_interval and fails_exact.
- Removed: the group-DP envelope with its tilted dynamic program and sampler, best_tilt_oracle and the moment bounds (both moved into oracle.py), the independent-units heuristic, and the few-forms ceiling.
- The earlier group-DP measurements on the suite nets are kept, labelled, in results/group_dp_earlier.json.

**Runs on the final code (one caveat on the barrier table)**
- Re-run: both soundness campaigns, the barrier table, exp_zero (p = 0 study), exp_large, the new wallclock.py, and narrow.py.
- Caveat: one of the two processes that built the barrier table (the d <= 28 nets) started before my last edits to nets_analytic.py. Those edits only touch overflow handling and small_width_interval, which no suite net reaches; the 21 enumerated failure counts match suite.json.
- Not re-run, for time: exp_suite, the other nets_verify experiments, oracle, perturb_map, cube_tilt and signpattern. They are from the code before the fixes, which change nothing on these nets; the READMEs say this.

**Corrections to earlier findings that whoever writes the paper section should know**
- **Wall-clock cost:** in this session one B&B fpe cost 1.0–2.0x the wall-clock time of one Monte Carlo sample (the red team measured about 2.2x under heavier load). So, for example, F = 163 gives a 48x speed-up in fpe but 36x in seconds.
- **Large d:** the runs given max_fpe = 1e7 actually stopped after 3.3e4 fpe (0.8–2.1 s) at d = 64 and 6.1e5 fpe (8.7–9.8 s) at d = 128. The [0, 1] conclusion rests on CROWN r50 (4–24), not on the budget.
- **Box minimum:** bce_d64_w64_s1000 is the one suite net whose box minimum is above t (by +0.114, the solver's uncertified optimum).
- **Structure lane at d = 128:** after re-running heuristics_ref.py against the SMC lane's renamed nets, the earlier d = 128 comparison at p_ref = 2e-30 no longer exists, because the SMC reference for that net is now 0.

- nets_verify, overflow at depth >= 3: an overflowing CROWN product (|W3||W2| beyond float range while rho <= 1e300) used to become a NaN interval that was read as a dead unit, certifying p = 0 for a net with p = 1. Now every backward pass checks that its coefficients and offsets are finite; a non-finite CROWN interval falls back to its interval-arithmetic bound, a non-finite bound on f becomes -inf/+inf (undecided), _relax refuses non-finite intervals, and alpha/phase iterates and the branching score are sanitised. Tests: test_overflow_in_backward_pass_is_not_a_certificate, test_overflow_depth_two, test_backward_pass_overflow_gives_no_information, test_affine_lower_on_the_overflow_net.
- nets_verify, sampling stage: estimate_undecided now starts lo at res.lo, and F/2^d and U/2^d are dyadic numbers rounded outwards. Previously lo was 1 ulp above p at d = 57. Test: test_estimate_undecided_starts_from_rounded_down_count.
- nets_verify, parameter checks: r_enum must be an int >= 0 (ValueError otherwise); the mass-balance assert, the n_ops assert, the subcube-dimension assert and the phase_bound assert are now explicit exceptions; batch >= 1 is checked. Tests: test_negative_or_invalid_r_enum_is_rejected, test_r_enum_rejected_under_python_O (runs in a python -O subprocess), test_guards_are_explicit_exceptions.
- nets_verify, NaN values: evaluated points that are neither definitely failing nor definitely safe, NaN included, are counted as ambiguous in both enumeration and sampling, never as safe. Test: test_nan_values_are_ambiguous_not_safe.
- nets_verify, budget claims: the module docstring, bab docstring, exp_large.py, exp_milp.py, summarize.py and README now say that max_fpe is a projection assuming every node of the level is bounded, and record the fpe, seconds and stop reason actually spent. Test: test_budget_is_a_conservative_projection.
- nets_verify: new Bounder.affine_lower() returns (h, g, tau) with f >= h + g.x - tau exactly on the box. Test: test_affine_lower_is_a_minorant_on_the_cube.
- nets_analytic, mcdiarmid: now computed through s/||c||_2 with a scaled norm, so s*s can no longer overflow (it used to certify U = 0 for p = 11/1024). Non-finite inputs give the trivial bound, and c = 0 no longer raises ZeroDivisionError. Tests: test_mcdiarmid_square_overflow, test_mcdiarmid_constant_nets, test_mcdiarmid_extreme_scales_never_nan.
- nets_analytic, small_width_interval: cells whose value is undefined (NaN) are always counted in hi and never in lo (before, [0,0] was returned for p = 1). For d > 53 the interval is widened by the proved relative error of the dynamic program, dp_rel(d) = gamma(d+1), with fsum and outward rounding; form_dp refuses d > 1000; the interval now also covers float64 evaluation (threshold t -+ tau). _down_vec/_up_vec map overflow to safe bounds, and grid_for refuses overflow with ValueError. Tests: test_small_width_interval_overflow_cells, test_small_width_interval_beyond_53_inputs[54,68,82,120], test_small_width_interval_exact_up_to_53_inputs, test_form_dp_limits, test_small_width_interval_random_nets.
- nets_analytic, fails_exact: every row with ~(|f - t| > tau), NaN included, is rechecked in rational arithmetic (it used to report p = 0.75 for p = 1); forward_error_bound returns inf on overflow. Tests: test_fails_exact_nan_rows, test_fails_exact_matches_rational_arithmetic.
- nets_analytic, box-barrier docstring: narrowed to positive mixtures of full-support exponential tilts whose domination is proved on the box. Group-DP/cell envelopes are explicitly excluded (on the small-ball net |sum x| a cell envelope reaches Z = 0.597 < 1 while F(0) - t = -1). The SignPatternEnvelope docstring now says domination holds on the box, not on R^d. Tests: test_box_barrier_does_not_cover_cell_envelopes, test_box_barrier_holds_for_tilt_mixtures.
- nets_analytic, few-forms ceiling: the claim (K* >= 843) is dropped from the docstring and README, and few_forms.py with its results is deleted. Test: test_few_form_ceiling_claim_dropped.
- nets_analytic, review nits: the CROWN tilt minorant now comes from nets_verify.Bounder.affine_lower with a proved margin (replacing the heuristic 1e-10 allowance); perturb_map_bound bounds Pr[F < t + tau] and returns the trivial bound instead of NaN on overflow; EnumMAPOracle refuses non-finite tables; the sign-pattern interval is widened by the total variation of the float coin probabilities (coin_tv) and of the mixture weights; the tilt interval accounts for log-weight rounding (log_weight_err); chernoff_holder returns the trivial bound when forms cannot be quantised; non-finite envelope masses are refused. Tests: test_deep_tilt_minorant_is_certified, test_perturb_map_threshold_and_overflow, test_map_oracle_refuses_overflowing_tables, test_chernoff_holder_overflow_is_trivial, test_sign_pattern_identity_and_domination, test_sign_pattern_interval_large_margin, test_tilt_identity_and_interval, test_cube_tilt_envelope.
- nets_analytic trim: removed GroupTiltEnvelope/group_tilt_envelope, the tilted form_dp branch and sample_backward, independent_units_chernoff, best_tilt_oracle, moment_bounds, enumerate_outputs, output_histogram and oracle_chernoff (the oracle-only ceilings moved into experiments/nets_analytic/oracle.py). run_suite.py and results/suite.json are superseded by the new barrier_table.py; the earlier group-DP values are kept in results/group_dp_earlier.json.
- Experiments: nets_verify/check_soundness.py gained an overflow-window family; nets_analytic/check_soundness.py was rewritten with independent exact-integer ground truth, an overflow family, the group-DP code removed, and refusals recorded. New: nets_analytic/barrier_table.py, nets_verify/wallclock.py, and exp_zero.py summarize() writing zero_summary.json. New nets_analytic/README.md; nets_verify and nets_structure READMEs updated (nets_structure scripts left unchanged).

## Writing

I wrote the new section, "Case study: networks trained to output a constant" (Section 8), and the general splitting theorem (Section 6.5). The paper builds cleanly in a scratch copy, and the new main.pdf (106 pages) is copied to paper/main.pdf. I made no state-changing git commands.

**Where the numbers come from.** Every number in the new text comes from a macro that `experiments/make_nets_tables.py` writes to `paper/tables/nets_numbers.tex` (320 macros). The script reads only the results files of `nets/`, `nets_lower/`, `nets_prover/`, `nets_verify/`, `nets_analytic/` and `nets_structure/`. It also writes 8 tables and 3 figures, and rerunning it reproduces the tables and macros byte for byte. `main.tex` loads the macros next to the preamble, so the abstract and introduction can use them.

**Theory.** Each item has a full proof, re-derived here.
- **Section 6.5 (splitting theorem, in `p2-lower.tex`).** Fixed-level multilevel splitting with any kernels that leave D restricted to each level set invariant has E Z = D(A_K) ≤ p, on every circuit. This needs no mixing; reporting Z = 0 on a floating-point flag only lowers the mean. A corollary gives sound lower bounds. A remark computes the variance under exact sampling, which is what mixing buys.
- **Lemma 8.1 (certified evaluation).** A floating-point error bound that includes gradual underflow, holds for any summation order with or without fused multiply–add, and excludes overflow. I added the assumption that every fan-in is at most 2^52.
- **Proposition 8.2.** A 3-CNF encodes as a one-hidden-layer net. Any net can be planted with a subcube of mass 2^-k, so the black-box upper-bound barrier and the planted-subcube lower-bound barrier hold around every trained net.
- **Proposition 8.3 (betting bound).** Anytime-valid via Ville's inequality. Completeness is proved for a dyadic λ grid with explicit constants; the code's grid {0.1, …, 0.95, 1} is covered by the soundness part only, and the text says so.
- **Corollary 8.4.** The full lower-bound procedure is sound on every net.
- **Proposition 8.5 (certified partitions).** Soundness, as a PCIS argument. An ideal pure tree with at most 2F(d − ⌊log₂F⌋ + 1) nodes always exists. The CROWN gap bound on a subcube is Σ over unstable units of c_j |a_j| ‖w_{j,R}‖₁.
- **Propositions 8.6 to 8.8.** The box, cube and decoupling barriers.

I weakened three statements where the data or the proof did not support the stronger form:
- **Convex hull of the failures:** 0 lies in it for all 20 width-≥32 one-hidden-layer squared-loss nets examined, but not for some width-8 and width-16 nets.
- **Decoupling barrier:** it covers Hölder- and Finner-type bounds only; I dropped the claim about tree-reweighted bounds.
- **Perturb-and-MAP:** it certifies U = p^c with c between 0.38 and 0.74, not "about p^(1/2)".

**Bottom line, as the section states it.** Splitting with the betting bound reaches L/p of 0.920–0.942 on the exact suite (p ≥ 1e-5). At d = 32–128 it reaches 0.865–0.973 of a reference estimate p_ref (the mean of 100 splitting runs, not an exact value), down to p_ref = 5.2e-21, at 4.1e6–5.7e7 fpe (19–550 s). Exact counts or certificates of p = 0 work at d ≲ 30 or with large margins:
- all 21 suite nets with d ≤ 28 are counted exactly;
- 98 of 107 long-trained nets are certified to have p = 0;
- at d = 64, 67.5% of one net's cube was certified failure-free in 110 minutes, so that certificate is not complete.

For squared-loss nets with p > 0 at d ≥ 40, nothing sound and two-sided beats Monte Carlo, and the barriers say why. Open questions are listed at the end of the section. Costs are given in fpe and wall-clock seconds, and the text says the machine was a shared 4-core machine.

**Edits elsewhere.**
- **`p1-tail.tex`:** splitting's reliance on mixing is now restricted to upper bounds and two-sided intervals.
- **`sec-discussion.tex`:** open problem 2 is corrected the same way, and open problem 7 is answered for trained nets.
- **`main.tex`:** the new section is input after `sec-experiments`, the abstract gains one sentence, and the macros are loaded.
- **`sec-intro.tex`:** one new Results paragraph.
- **`refs.bib`:** 9 new entries. I could check them only through search results, because the publisher sites are blocked from this session. The Hazan–Jaakkola ICML 2012 entry therefore has no page numbers.
- **`README.md`:**
  - a new "Trained networks" bullet in the short answer;
  - new entries in the contents list for the nets code and experiment folders and `make_nets_tables.py`;
  - `make_nets_tables.py` added to the reproduce command;
  - the status lines updated;
  - the paths that stay on the working branch, which the line previously said did not exist: `nets_lower/results/logs/`, `nets_structure/cache/` and `logs/`, `nets_prover/results/*_log*.txt`, and `__pycache__/`.

**Caveats.**
- **Older verifier results:** Figure 5 (left and middle panels: the relaxation-gap scan) and Figure 6 (whole-certificate cost against d) use results from the certified-partition verifier's previous version, and their captions say so.
- **Unverified references:** p_ref values below about 6e-9 have not been checked independently, and the far-tail references are uncertain; the text marks both.
- **Pre-existing warnings:** the remaining LaTeX warnings were already there before my changes. The HEAD paper also has 9 font-shape warnings, and every float triggers a duplicate-hyperref-destination warning. That comes from the preamble, which I don't own, so my 11 new floats add 11 more of the same.

## Referee (proof lens)

**Verdict.** The proofs are correct, but the text overclaims in places. I re-derived every proof in paper/sec-nets.tex and the new splitting theorem in paper/p2-lower.tex, and none has a mathematical error: Lemma 8.1, Propositions 8.2, 8.3 (with its constants) and 8.5–8.8, Corollary 8.4, Theorem 6.10, Corollary 6.11 and the variance remark all hold as stated. Rerunning experiments/make_nets_tables.py into a scratch folder reproduces all 320 macros and the 8 tables byte for byte, and the numbers I traced back to the results files agree. There are two major problems. The first is how strongly the text states the lower-bound and mixing results at large d, where p_ref is unverified and comes from the same estimator. The second is that sec-discussion claims to have "answered" open problem 7 with evidence that is partly empirical. Eleven minor problems follow: statement and proof versus the actual verifier checks, how some numbers are defined (mixing loss families, two different enumeration costs, percentile ranges), one wrong sentence about completeness, the Monte Carlo yardstick, and wording. Nothing critical.

### 1. [major] sec-nets.tex lines 7-12 (bullet 1), 437-445 (Wall clock and mixing), 845-848 (Bottom line), 863-865 (open problem 2); sec-intro.tex new paragraph ('for $p$ down to \nnBigPref'); main.tex abstract

**Problem.** The claims that sound lower bounds 'work very well, at every d' and that 'the level sets of trained nets mix well at large d / stay connected under bit flips' are stated as findings, but the large-d evidence cannot support them. For d ≥ 64 with p_ref below 6.3e-9 (the lowest Monte Carlo check), the ratio is L over p_ref, and p_ref is the mean of 100 more replicates of the same splitting estimator, whose mean is D(A_K) ≤ p. A mode the chains never reach is missing from both L and p_ref, so L/p_ref ≈ 0.9 cannot detect it. Sec. 8.2's own planted net shows exactly this: L = 0 and point estimate 0 in all 5 runs while p = 1.6e-8. The 'mixing' evidence is an acceptance rate of at least 0.10 and 201–338 distinct final particles on 4 nets. Those are necessary for mixing but not sufficient, and the nets with the smallest p_ref (5.2e-21) are not among the 4. The intro also says 'for p down to 5.2e-21' where the value is p_ref, unverified below 6.3e-9.

**Proposed fix.** 1. Qualify bullet 1 and the bottom line: 'work very well wherever p could be checked (exact at d ≤ 32, independent Monte Carlo down to 6e-9). Below that, the ratio is to the mean of the same estimator, which cannot reveal a missed mode (Sec. 8.2's planted net).'
2. In sec-intro.tex, write 'for p_ref down to', and add 'unverified below 6e-9'.
3. Change 'in high dimension the level sets of trained nets stay connected under bit flips' to 'the chains appear to mix: late-level acceptance ≥0.10 and 200–340 distinct final particles on the 4 nets examined'.
4. Reword open problem 2 as 'why the chains appear to mix', not as a fact to be explained.
5. In the abstract, keep 'reference estimates', and consider adding 'unverified below 6e-9'.

### 2. [major] sec-discussion.tex, open problem 7 (new text: 'For ReLU networks trained to output a constant, \cref{sec:nets} answers this: for squared-loss training, no, because ...')

**Problem.** The text claims Section 8 settles an open problem negatively, but the evidence is partly empirical.
- Prop. 8.6 shows box-valid bounds fail at the root only when F(0)<t (or a box point with F<t exists). F(0)<t is observed on the 13 squared-loss nets with d ≤ 28, but not at d=64: mse_d64_w64_s3000 has F(0)−t = +0.114 in tab:nets-barriers. There the root fails only because a box witness exists, not because of 'the centre'.
- The growth 2^{(0.63–0.85)d} is a Knuth extrapolation, in the previous verifier's cost model, over four families up to d=64. It is not a consequence of Props. 8.6/8.7, which are the results cited for it.
- Partitioned or degree-2 sandwich certificates are not ruled out; sec-nets itself lists them as open (open problem 1).

**Proposed fix.** Rephrase along these lines: 'For squared-loss training, Section 8 gives a negative answer for bounds valid on the box. On every squared-loss suite net a box point with F<t exists, so such bounds fail at the root (Prop. 8.6). The certified partitions we could build grow empirically like 2^{(0.68–0.78)d} (Knuth estimates, Fig. 6). Whether case splits or certificates using x_i^2=1 escape this is open.' Cite Prop. 8.6 for the root failure only, not for the growth rate.

### 3. [minor] sec-nets.tex line 856 (bottom line) and sec-discussion.tex (\nnKnuthSlopes); experiments/make_nets_tables.py knuth_figure()

**Problem.** \nnKnuthSlopes = 0.63–0.85 is the range of fitted log2-slopes over all four families in Fig. 6. Both extremes are logistic families: 0.63 for 60 steps and 0.85 for 100 steps. The squared-loss families give 0.68 (1500 steps) and 0.78 (600 steps). The bottom line ('For squared-loss nets with p>0 ... the certified partitions grow like 2^{(0.63–0.85)d}') and the discussion attribute the whole range to squared loss. Only the figure caption says the costs use the previous verifier's cost model.

**Proposed fix.** Emit a separate macro for the squared-loss families (0.68–0.78) and use it in the bottom line and the discussion, or say 'over the four families of Fig. 6, both losses'. Add '(Knuth estimates; previous verifier's cost model)' where the rate is quoted in the text.

### 4. [minor] sec-nets.tex lines 321-322 ('heavy upper tails of Z cost nothing in validity; only the lower tail matters for completeness')

**Problem.** The second half of the sentence is wrong. Prop. 8.3(b) needs R ≳ (1+v)ε^{-2}log(|Λ|/δ) with v the relative variance of Z, and also needs λ* = a/(4σ²). Both are driven by the upper tail: rare large replicates carrying the mean make v large and delay completeness. The truncation in the proof handles the upper tail but pays for it through σ².

**Proposed fix.** Replace with: 'heavy upper tails of Z cost nothing in validity; completeness depends on the relative variance v of Z (Prop. 8.3(b)), that is, on how much of the mean is carried by rare large replicates.'

### 5. [minor] sec-nets.tex Prop. 8.5(a) proof, lines 549-560 (degree-2 certificates); also the statement at lines 497-499 and Prop. 8.5(c)

**Problem.** The written soundness argument does not match the verifier's actual checks (code/rareprob/nets_prover.py, _quad_coeffs and _psd_box). The code is sound; the text is incomplete. Four gaps:
- 'q_j ≤ relu on [L_j,U_j] ... (checked at the endpoints and the vertex)' is not a sufficient check as written. For a concave minorant or a convex majorant, the extremum of q(z)−z on [0,U] lies at the vertex of q−id, not of q. The code avoids this by allowing only convex q (κ ≥ 0). It checks q(L)≤0, q(0)≤0 and q(U)≤U for minorants. For majorants it checks q(L)≥0 and q'(L)≥0, plus either [(q−z)(U)≥0, (q−z)'(U)≤0] or [(q−z)(0)≥0, (q−z)'(0)≥0].
- The text omits that layers ≥2 are relaxed linearly first, with G_j the backward coefficients, and that units whose G_j has uncertain sign get q=0 and the charge G_lo·U.
- The Cholesky step omits the rounding of forming A−cI; the code adds ed = 2u·max|A_ii|.
- Prop. 8.5(c) is exact-arithmetic. 'A SAFE certificate exists as soon as the margin exceeds the right-hand side' holds only up to the verifier's outward-rounding slack and the prover's 2^-30|f|_abs acceptance margin.

**Proposed fix.** 1. State the convexity restriction and the endpoint and derivative conditions above in place of 'endpoints and the vertex'.
2. Add one sentence: 'later layers are first relaxed linearly as in the linear certificate; G_j is the resulting coefficient of h_j = relu(z_j), and a unit whose G_j has uncertain sign gets q_j = 0 and the charge G_lo,j U_j'.
3. Add 'and the rounding of forming A−cI' next to 'plus underflow terms'.
4. In (c), write 'exceeds the right-hand side (plus the verifier's rounding slack)'.

### 6. [minor] sec-nets.tex Prop. 8.5(a), lines 505-510 ('It is a PCIS argument (\cref{def:pcis}) ... so \cref{thm:pcis-sound} applies')

**Problem.** This is not literally an instance of Def. 6.1 (def:pcis), so Theorem 6.3 (thm:pcis-sound) does not apply as stated. Def. 6.1 fixes a Cook–Reckhow propositional proof system P over Tseitin(C), and its statistical nodes are nodes of the argument DAG whose intervals are combined by the deductive rules. Here the refutations are linear or degree-2 certificates over the reals (or enumeration). The single ENVELOPE node samples the union U of OPEN leaves that sit in different branches of the SPLIT tree, and no rule of Def. 6.1 forms such a node. The direct proof given afterwards is complete on its own.

**Proposed fix.** Write: 'It has the structure of a PCIS argument (Def. 6.1): SPLIT nodes, deterministic leaves whose refutations are linear or degree-2 certificates or enumeration in place of P-refutations, and one envelope node φ = 1_U over the union of the open leaves. Soundness is proved directly below, and the sampled part costs what Theorem 4.3(iv) (thm:envelope) charges for the looseness |U|/(2^d D(C∧U)).'

### 7. [minor] sec-nets.tex lines 609-611 ('Branch and bound ... counts exactly at \nnBabEnumMse{} times the cost of enumeration ... and \nnBabEnumBce{}'); make_nets_tables.py exact_table()

**Problem.** The ratios 0.71–4.0 (squared) and 8e-3–0.5 (logistic) divide by nets_verify's full_enum_fpe (2.0e6 at d=24, 2.8e7 at d=28). Table tab:nets-exact, cited for these results, shows the prover's enumeration cost instead (1.3e6 and 1.9e7). A reader dividing the table's columns gets 1.1–5.6 (mse_d24_w32_s300: 7.3e6/1.3e6) and 0.012–0.78. Also, 'counts exactly' is applied to both range extremes, mse_d28_w64_s300 (4.0) and bce_d28_w32_s30 (0.52). These are exactly the two starred runs that ended with 9 and 1 undecided points.

**Proposed fix.** Compute both ratios against the enumeration cost shown in tab:nets-exact, or add B&B's own enumeration cost to the table. Reword as 'counts exactly on 11 of the 13 one-hidden-layer nets (the other two end with 9 and 1 undecided points, with intervals containing p), at X–Y times the cost of enumeration'.

### 8. [minor] sec-nets.tex lines 45-46; Table tab:nets-smc-suite caption (lines 451-452); fig_nets_smc legend (make_nets_tables.py smc_figure)

**Problem.** The text says 'Monte Carlo needs 3ln(2/δ)/(ε²p) samples for a two-sided ratio 1+ε'. That count is the multiplicative-Chernoff sufficient count for relative error ε. It yields an interval of ratio about (1+ε)/(1−ε) ≈ 1+2ε (about 1.22 at ε=0.1, not 1.1), and it is sufficient, not necessary. It also differs from the KL-interval yardstick of Sec. 7 (sec:experiments). The direction favours Monte Carlo, so no speed-up is inflated, but the statement is incorrect.

**Proposed fix.** Write 'Monte Carlo with 3ln(2/δ)/(ε²p) samples achieves relative error ε (an interval of ratio about 1+2ε) with probability 1−δ'. Make the same change in the table caption and the figure legend, or switch to the KL yardstick at ratio 1.1.

### 9. [minor] sec-nets.tex Lemma 8.1 statement lines 69-72, and Cor. 8.4 proof line 353

**Problem.** The lemma's decision rules leave t−e ≤ v < t+e undecided, but the text says 'Points with |v−t|<e ... are undecided', which omits v = t−e. That point is not decidable: it gives F ≤ t, not F < t. The lemma also says such points 'abort the run that met them (by the splitting procedure)'. In fact the procedure flags values within 2e of the level being tested and reports Z = 0 for that replicate. The corollary's coupling says 'until the first value within e of a level', which needs ≤ e. Soundness is unaffected because the flag uses 2e.

**Proposed fix.** Lemma 8.1: 'Points with t−e ≤ v < t+e, or with v not finite, are undecided; the verifiers re-evaluate them in exact rational arithmetic, and the splitting procedure, which flags every value within 2e of a level, reports Z=0 for that replicate.' Cor. 8.4 proof: 'until the first value within e (inclusive) of a level, or not finite; every such value is within 2e and raises the flag'.

### 10. [minor] sec-nets.tex lines 198-203 (planted net, d=40, k=26)

**Problem.** 'Sound, and exactly the behaviour that (c) forces on every evaluation-only method' overstates. Prop. 8.2(c) forces evaluation-only methods to miss the hidden 2^-26 subcube for most b, i.e. L ≲ p_visible. Here the runs also missed the visible failure set (p_visible = 7.5e-10, about 820 inputs at d=40; adversarial.jsonl), which (c) does not force. Note that (c)'s lower-bound part is stated for p(f) = 0, and this unplanted net has p(f) = p_visible > 0.

**Proposed fix.** Write: 'returned L=0 in all 5 runs: sound. The hidden subcube, which Prop. 8.2(c) shows no evaluation-only method can find with ≪2^26 evaluations for most b, was missed, and at this budget the visible part (p = 7.5·10^-10) was not reached either.' Add a macro for p_visible.

### 11. [minor] sec-nets.tex lines 601-603 vs Tables tab:nets-smc-suite and tab:nets-exact

**Problem.** The same Monte Carlo sample counts are given different wall-clock times in the two tables, because the per-sample time was measured in different processes on the shared machine (about 0.45 vs 1.0 μs):
- mse_d24_w32_s2000: 1.9e10 samples is 1.9e4 s in tab:nets-smc-suite but 7100 s in tab:nets-exact.
- bce_d28_w32_s100: 1.5e5 s against 6.7e4 s.
The text's 'about 19 hours' uses the smaller figure; the other table implies about 42 hours.

**Proposed fix.** Use one per-sample Monte Carlo time per net across both tables, for example the median of the measurements. Alternatively, state in both captions that Monte Carlo seconds are measured per experiment and differ by up to 2.7× between tables.

### 12. [minor] sec-nets.tex lines 588-592 (relaxation-gap heuristic) and line 861 (\nnQuadGapCut)

**Problem.** The heuristic predicts gap ∝ r^{3/2}, but the measured exponents, 1.7–1.9, are reported without comment. They lie much closer to the worst case r^2 of (c). They also come from gap_scan.json, computed with the previous verifier, which only the Fig. 5 caption mentions. Separately, 'Degree 2 removes only 17%–39% of the linear gap' (open problem 1, about squared-loss nets) is the 10th–90th percentile over (net, r) pairs pooled across both losses. The squared-loss one-hidden-layer values range over 4%–40%.

**Proposed fix.** After the measured exponents add: 'between the heuristic 3/2 and the worst case 2; gap scan computed with the previous verifier (Fig. 5)'. In open problem 1 write 'removes 17%–39% of the linear gap (10th–90th percentile over subcube dimensions and one-hidden-layer nets)', or compute the range for squared loss only.

### 13. [minor] sec-nets.tex lines 236-238 and 623-626

**Problem.** Line 236 says 'trained to moderate length' and line 623 'moderately trained'. The study's regime is 'long' (at least 1000 squared-loss or 300 logistic-loss steps, as the table caption says), and line 626 says 'Long training'. 'Of 107 ..., 98 have p=0' also reads as exact. In fact 98 are certified p=0, 5 have exact p>0, and 4 are open, so at least 98 have p=0.

**Proposed fix.** Use 'trained for at least 1000 (squared) or 300 (logistic) steps' consistently. Write '98 are certified to have p=0, 5 have p>0 (counted exactly) and 4 remain open'.

### 14. [minor] p2-lower.tex variance remark after Cor. 6.11 ('at a cost of NK=O(log^2(1/p)) draws per replicate for fixed ρ')

**Problem.** ρ_k ≥ ρ alone does not bound K. Levels with ρ_k close to 1 can make K arbitrarily large, so NK = K²/ρ = O(log²(1/p)) also needs K = O(log(1/p)).

**Proposed fix.** Add the condition: 'with K = O(log(1/p)) levels (e.g. ρ ≤ ρ_k ≤ 1/2, so K ≤ log₂(1/p) when A_K = C^{-1}(1))'.

## Referee (code lens)

**Verdict.** I found one new deterministic soundness break at float64 extremes, in nets_prover, and one in nets_lower. Everything else that claims soundness held up under my attacks.

1. **nets_prover (verify):** a point whose float output overflows to +inf is classed as "surely safe". On a hand-built d = 1 net, verify reports the exact interval [0.5, 0.5] when the true p = 1.
2. **nets_lower:** the count |S|/2^d is rounded to nearest. When that value is subnormal (d >= 1075) the witness bound rounds up, giving 4·2^-1075 when p = 3·2^-1075.

The other six findings are malformed-argument or robustness defects:
- unvalidated bet sizes (lams) in betting_lower;
- witnesses passed to lower_bound are trusted without re-checking;
- `first < 0` in estimate_undecided;
- a bounder for one net silently used for another in bab;
- root cast to int8 before it is validated in verify;
- a crash in CertNet when the threshold is the largest float.

Five of these six produce wrong intervals or bounds (each demonstrated); the CertNet one is a crash only. None of the eight affects any trained-suite number.

Every attack found in the earlier red-team round has a regression test, and all pass:
- 132 nets tests in 50.6 s;
- 459 tests (the whole suite) in 112 s, on a shared 4-core machine.

A fuzz of 197 deep nets (3 to 5 hidden layers) found 0 violations.

### 1. [major] code/rareprob/nets_prover.py:425-430 (CertNet._ambiguous; used by classify, enum_count, verify's sampling and witness_lower_bound)

**Problem.** Non-finite float values are not always re-evaluated, although the docstring says they are.

If tau_pt = inf (any net whose forward bound overflows), then pt_safe = +inf, and a float output of +inf passes `fvals >= self.pt_safe` (inf >= inf). The point is counted as surely safe, with no exact evaluation, even when the exact f is below t.

Counterexample (d = 1, t = 0):
- W1 = [[2^1023], [2^1023 - 2^971]], b1 = [2^1023, 2^1023], W2 = [[1, -1]], b2 = [-2^972].
- At x = +1, h1 overflows: its exact value is 2^1024 and its float value is inf. h2 = FMAX exactly, so f_float = +inf while the exact f = -2^971 < 0.
- At x = -1 the point fails in both.
- So p = 1, but verify(net, {'tree': [('enum',)], 'samples': 0}) returns exact = True, [lo, hi] = [0.5, 0.5].
- With an open leaf and 4000 samples at delta = 1e-6, it returns [0.450, 0.535], which also misses p = 1.

The miss is deterministic. The other three modules handle this net soundly.

**Proposed fix.** Require finiteness on both sides of the decision:
`fin = np.isfinite(fvals); sure_fail = fin & (fvals < self.pt_fail); sure_safe = fin & (fvals >= self.pt_safe)`.
Non-finite points then go to exact_f, which is correct for any weights.

Add the net above as a regression test in test_nets_prover.py:
- the ENUM leaf must give F == 2 and [1, 1];
- an OPEN leaf with samples must contain 1;
- the mirrored net (output weights and bias negated, t = -FMAX) must also come out exact.

### 2. [major] code/rareprob/nets_lower.py:227-228 (Witnesses.lower), :580 and :603 (base and base + L_smc in lower_bound), :492 (end of betting_lower)

**Problem.** The exact counts |S|/2^d are converted with math.ldexp, which rounds to nearest. In the subnormal range (count·2^-d < 2^-1022, so d >= 1075) this rounds UP.

Counterexample: net with fail iff x_1..x_{d-2} = +1 and not (x_{d-1} = x_d = +1), exactly 3 failing points.
- d = 1075: Witnesses.lower() = 4·2^-1075 > p = 3·2^-1075.
- d = 1076: the bound is 4·2^-1076 > p = 3·2^-1076.
- lower_bound(net, witnesses=W), and lower_bound with stratify=True (whose base is rounded the same way), both report the same too-large value.

The miss is deterministic. The float addition `base + L_smc` can also round up for d > 53.

betting_lower ends with `math.exp(lo) * (1 - 1e-12)`. In the subnormal range the 1e-12 margin is lost: for 64 replicates Z = 3·2^-1074 it returns p0 = 3·2^-1074, where E(p0) = 1 < 1/delta. That p0 lies outside its own confidence set.

Reaching this through the default driver needs the pilot to find the witnesses, which I could not do on a needle net. The documented witnesses= and stratify paths do reach it.

**Proposed fix.** Round every exact rational down with the module's _float_down:
- `Witnesses.lower`: `return _float_down(Fraction(len(self.codes), 1 << self.ev.d))`.
- In lower_bound, `base_q = Fraction(len(S_fixed), 1 << ev.d)` and `lower = max(_float_down(base_q + Fraction(L_smc)), wl)`, with `notes['stratum'] = _float_down(base_q)`.
- In betting_lower: `v = math.exp(lo) * (1 - 1e-12)`; then `if v < sys.float_info.min: v = max(0.0, v - 2 * 2.0 ** -1074)`. This covers up to one ulp of error in exp and the rounding of the product.

Add the d = 1075 and 1076 three-point nets as regression tests, asserting Fraction(bound) <= p for W.lower(), for lower_bound with witnesses=, and for stratify=True. Also assert betting_lower(np.full(64, 3 * 2.0 ** -1074), 0.05) < 3 * 2.0 ** -1074.

### 3. [minor] code/rareprob/nets_lower.py:444-457 (betting_lower, the lams argument)

**Problem.** The bet sizes are never validated (the weights are).

- If lam > 1, a factor 1 - lam + lam·Z/p0 can be negative, so the mixture is not a nonnegative e-value and Markov's inequality does not apply.
- If lam < 0, the mean of the factor is at least 1, so the product is not a supermartingale.

Demonstration: i.i.d. Z = p/q with probability q = 2.5·delta, else 0, so E Z = p; R = 1, lams = (3.0,). Then Pr[L > p] = 0.128 against delta = 0.05 (4000 runs). The default lams give 0.002 on a comparable law.

**Proposed fix.** Right after `lams = np.asarray(lams, dtype=float)`, add:
`if lams.ndim != 1 or lams.size == 0 or not np.isfinite(lams).all() or lams.min() < 0 or lams.max() > 1: raise ValueError('betting_lower: every lambda must lie in [0, 1]')`

Add a test asserting that lams = (3.0,) and lams = (-0.5,) raise.

### 4. [minor] code/rareprob/nets_lower.py:574 (lower_bound(witnesses=...)) and :218-225 (Witnesses.add)

**Problem.** A caller-supplied Witnesses object is trusted. Its codes are never re-checked against `net`, and Witnesses.add packs rows that are not cube points to the cube point X > 0, which was never evaluated.

Demonstrations (d = 8, both nets have p = 0):
- Witnesses collected on another net (one that fails everywhere), passed to lower_bound for a net with p = 0: lower = 0.516.
- For f = |x_0| with t = 0.5 (p = 0 on the cube), adding the non-cube point x_0 = 0 gives W.lower() = lower_bound(...).lower = 2^-8.

**Proposed fix.** Make lower_bound reject witnesses built for another net with `if witnesses is not None and witnesses.ev.net is not net: raise ValueError`. Better still, re-certify every code before use: `X = unpack(list(W.codes), d); keep = ev.certified(ev.score(X))`. That costs one forward pass per witness.

In Witnesses.add, raise ValueError unless every entry of X is exactly +1 or -1.

Add both demonstrations as regression tests.

### 5. [minor] code/rareprob/nets_verify.py:815-866 (estimate_undecided, the `first` argument; underlying cause in stats.kl_interval, which accepts N < 0)

**Problem.** `first` is not validated.
- first = -1: the sample count N becomes negative and no sample is drawn. kl_interval at N < 0 has a negative KL radius and collapses the undecided part to about [0, 0]. The loop then stops because hi <= (1 + eps)·lo.
- On f = 1 + 2·x_0 - relu(sum_{i>=1} x_i - 6) with t = 0.5 and d = 10 (p = 513/1024), bab(r_enum=0, max_nodes=3) gives F = 512 and U = 512. estimate_undecided(..., first=-1) then returns [0.5, 0.5000000000000004], deterministically missing p. With first = 1024 the interval contains p.
- first = 0 crashes with ZeroDivisionError.

**Proposed fix.** At the top of estimate_undecided add:
`if isinstance(first, bool) or not isinstance(first, (int, np.integer)) or first < 1: raise ValueError('first must be an integer >= 1')`
Apply the same check to max_samples, requiring an integer >= 0.

In stats.kl_interval, raise ValueError when N < 0.

Add the net above with first = -1 and first = 0 as a regression test that expects ValueError.

### 6. [minor] code/rareprob/nets_verify.py:664 (bab: `bd = bounder or Bounder(net)`) and :827-839 (estimate_undecided: bounder and res)

**Problem.** When a bounder is passed, bab ignores `net` and silently certifies the bounder's net. estimate_undecided likewise trusts any BabResult and bounder, including ones from another net or with inconsistent undecided_cubes.

Demonstration: bab(net, r_enum=4, bounder=Bounder(other)), where `other` is the same weights with t = -10, returns exact = True with [0, 0] for a net whose p = 513/1024.

A BabResult whose undecided_cubes have mixed sizes would make the sampler non-uniform.

**Proposed fix.** Have Bounder store a fingerprint of the net it was built from: a hash of the weight and bias bytes and of float(threshold). BabResult should copy that fingerprint.
- In bab and estimate_undecided, raise ValueError if the fingerprints do not match `net`. Alternatively, take either a net or a bounder, not both.
- In estimate_undecided, also check that every row of res.undecided_cubes is in {-1, 0, 1}^d, that all rows have the same number r of free coordinates, and that rows·2^r == res.undecided.

### 7. [minor] code/rareprob/nets_prover.py:887 (verify) and :1465 (prove), handling of `root`

**Problem.** The root is cast to int8 BEFORE it is validated, so non-integer entries are truncated without any error.

On f = relu(x_0), t = 0.5 (fails iff x_0 = -1):
- root (0.6, 0, 0, 0) is read as the whole cube and returns the exact interval [0.5, 0.5], instead of rejecting the root.
- root (1.9, 0, 0, 0) is read as (1, 0, 0, 0) and returns [0, 0].

The interval returned is for a different subcube than the one requested.

**Proposed fix.** Validate before casting:
`r = np.asarray(root, dtype=np.float64); if r.shape != (d,) or not np.all((r == -1) | (r == 0) | (r == 1)): raise ValueError(...); root = r.astype(np.int8)`
Do the same in prove.

Add a test that roots (0.6, 0, 0, 0) and (1.9, 0, 0, 0) raise ValueError.

### 8. [minor] code/rareprob/nets_prover.py:248-267 (_round_down, _round_up; called in CertNet.__init__)

**Problem.** This is a robustness bug, not a soundness bug: CertNet crashes on valid float64 thresholds near ±FMAX.

When T + tau is slightly above FMAX, float(q) returns FMAX. The loop then steps to inf, and Fraction(inf) raises OverflowError. For example, MLP([ones((1, 3)), ones((1, 1))], [zeros(1), zeros(1)], threshold=sys.float_info.max) makes CertNet raise 'cannot convert Infinity to integer ratio'.

**Proposed fix.** Stop stepping once the value is infinite: `while math.isfinite(x) and Fraction(x) < q: x = math.nextafter(x, math.inf)` in _round_up, and the mirror in _round_down. An infinite result is the correct outward rounding there.

Add a test that builds CertNet with threshold ±FMAX and checks verify against the exact count.

## Fixes

All 22 referee findings (14 from the proof review, 8 from the code review) are addressed. 21 are fully fixed; the code review's extra request to change the shared stats.kl_interval is not done, because stats.py is not mine (the nets-side fix is in place). Most of the work had already been done by the earlier attempt and was committed in HEAD (a5c32b0c). I checked each of its fixes against the finding and the code, made the remaining edits, and ran the reruns, the table regeneration and the paper build that the earlier attempt never reached.

**Code.** I confirmed all eight code fixes by rerunning the reviewer's own attack scripts (scratchpad/ref/atk_*.py) against the current code. Each now gives a sound interval or raises ValueError. Each counterexample is a regression test, and they all pass.

**Paper.** I checked every proof-review finding against the text in /home/user/AI-works/circuit-output-fraction/paper/sec-nets.tex, sec-intro.tex, main.tex, sec-discussion.tex, p2-lower.tex and experiments/make_nets_tables.py. Each fix holds against the data; for example, every squared-loss suite net does have a re-evaluated box point with F<t. My own edits:
- **Planted net:** "missed, as it must be" overstated things. At 6.1e6 evaluations per run, the chance of hitting a 2^-26 subcube is up to 0.09, so the text now says "as expected", with a new computed macro \nnPlantedHit.
- **Discussion:** added the cost-model caveat ("Knuth estimates in the previous verifier's cost model") and "on the nets we tried" to the logistic-loss claim. Added the same caveat to the README.
- **sec-nets:** listed the two new holes (an output overflowing to +inf; subnormal counts rounded up) among the floating-point holes, and stated that |W|/2^d is rounded down, supplied witnesses are re-evaluated, and the betting grid is checked to lie in [0,1].
- **Experiment READMEs** (nets_lower, nets_verify, nets_prover): described the fixes and the reruns.

**Reruns on the final code.** All give the same results. Times are wall-clock on a shared 4-core machine:
- prover soundness campaign: 37,553 bound checks, 260 exact runs, 1,144 tampered arguments, 13 of 1,300 coverage misses — identical counts, 427 s;
- branch-and-bound checks: identical, 6.2 s;
- splitting checks (check_nets_lower.py): checks.txt byte-identical, 147 s;
- stratified runs: identical except timings, 22 s;
- both summarize.py scripts: identical except the campaign's run time.

The planted runs the paper cites cost 6.1e6 fpe and 6.1 s each. make_nets_tables.py regenerates every table and figure. The tables are byte-identical except for the one new macro; the figure PDFs differ only in their embedded creation dates.

**Paper build** in /tmp/claude-0/-home-user-AI-works/02f29707-9759-5ff3-9757-46e1f8b0fdfe/scratchpad/build_ri2_final: 107 pages, no undefined references or citations, no overfull boxes. Copied to /home/user/AI-works/circuit-output-fraction/paper/main.pdf.

No git state was changed.

- Proof review, major: lower-bound and mixing results overclaimed at large d (bullet 1, wall clock and mixing, bottom line, open problem 2, intro, abstract): Checked the earlier attempt's rewording in all six places. Bullet 1 and the bottom line now say 'wherever p could be checked' (exact at d<=32, Monte Carlo down to 6.3e-9) and that the reference cannot reveal a missed mode (planted net). The mixing paragraph says 'the chains appear to mix' on the 4 nets examined, which is necessary but not sufficient. Open problem 2 is now 'why the chains appear to mix'. The intro says 'for p_ref down to 5.2e-21' and that the reference is checked on 8 of 15 nets. The abstract says 'references checked independently only down to p≈6.3e-9'.
- Proof review, major: sec-discussion claimed to have answered open problem 7: Rephrased to 'a partial answer'. Negative for bounds valid on the box: a box point with F<t exists on every squared-loss suite net (I checked the barrier table, including mse_d64_w64_s3000 with F(0)-t=+0.114 and box minimum -0.133), citing Prop. 8.6(a) only for the root failure. Growth is quoted as empirical: Knuth estimates for the squared-loss families, in the previous verifier's cost model. Case splits and x_i^2=1 certificates stated as open. I added the cost-model caveat and 'on the nets we tried' for logistic loss.
- Proof review: Knuth slopes 0.63-0.85 attributed to squared loss: make_nets_tables.py emits \nnKnuthSlopesMse (0.68-0.78) and \nnKnuthSlopesBce (0.63-0.85). The bottom line and discussion use the squared-loss macro, with the cost-model caveat (I added it in the discussion and the README); the Fig. 6 caption gives both.
- Proof review: 'only the lower tail matters for completeness' is wrong: Replaced by the referee's wording: completeness depends on the relative variance v of Z, that is, on how much of the mean is carried by rare large replicates.
- Proof review: Prop. 8.5(a) proof did not match the verifier's degree-2 checks: Checked the new text against _quad_coeffs and _psd_box in nets_prover.py; it matches. Only convex q is allowed; the minorant checks q(L)<=0, q(0)<=0, q(U)<=U; the majorant checks q(L)>=0 and q'(L)>=0 plus one of the two (q-z) conditions. Later layers are relaxed linearly first, and units with uncertain-sign G get q=0 and the charge G_lo U. The rounding of forming A-cI (2u max|A_ii|) is included, and (c) now mentions the verifier's rounding slack and the prover's 2^-30 acceptance margin.
- Proof review: the certified partition is not literally a PCIS instance: Now reads 'has the structure of a PCIS argument': no rule of Def. 6.1 forms the envelope node over the union of open leaves, so Thm 6.3 does not apply literally. Soundness is proved directly, with the sampled cost per Thm 4.3(iv).
- Proof review: B&B/enumeration ratios used a different cost model and included the two starred runs: Ratios are now computed only over the 11 runs that counted exactly (squared 0.71-3.6, logistic 8.3e-3-0.12). The text says 'counts exactly on 11 of the 13 one-hidden-layer nets (the other two end with 9 and 1 undecided points, intervals contain p)'. It states that the ratios are in branch and bound's own cost model (enumeration 2e6 fpe at d=24, 2.8e7 at d=28), unlike the table's enumeration column. This is the referee's second option, given in the text rather than as a new table column.
- Proof review: the Monte Carlo yardstick misstated as 'two-sided ratio 1+eps': Text, table caption and figure legend now say: relative error eps (multiplicative Chernoff), an interval of ratio about 1+2eps (1.22 at eps=0.1), sufficient not necessary, favouring Monte Carlo.
- Proof review: Lemma 8.1 undecided band and Cor. 8.4 coupling inequality: Lemma 8.1 now says t-e<=v<t+e or non-finite is undecided: re-evaluated exactly by the verifiers, Z=0 under the 2e flag. The Cor. 8.4 proof says 'within e (inclusive) ... raises the flag'.
- Proof review: the planted d=40 net overstated what Prop. 8.2(c) forces: Earlier attempt: added \nnPlantedPvis (7.5e-10, 821 inputs) and noted that missing the visible part is not forced by (c). I also replaced 'as it must be' with 'as expected', and added the bound T*2^-26 <= 0.09 per run as a new computed macro, \nnPlantedHit.
- Proof review: the same Monte Carlo samples had different seconds in the two tables: make_nets_tables.py uses one per-net Monte Carlo time (mc_time: median of the measurements) in every table and number. I checked that mse_d24_w32_s2000 and bce_d28_w32_s100 now show the same seconds in both tables. The text and captions state the spread (up to 2.7x), and the d=28 example is '33 hours'.
- Proof review: gap exponent 1.7-1.9 not commented; the 17-39% range pooled both losses: The text says the exponent lies between the heuristic 3/2 and the worst case 2, nearer 2, and that the gap scan used the previous verifier. Open problem 1 uses \nnQuadGapCutMse (15%-39%, 10th-90th percentile over the 27 pairs of one-hidden-layer squared-loss net and subcube dimension).
- Proof review: 'moderately trained' wording and '98 have p=0': Both places now say 'trained for at least 1000 (squared) or 300 (logistic) steps' and '98 are certified to have p=0, 5 have p>0 (counted exactly), 4 remain open'.
- Proof review: p2-lower variance remark needs K=O(log 1/p): Added the condition and an example (rho<=rho_k<=1/2 with A_K=C^-1(1) gives K<=log2(1/p)), and noted that rho_k>=rho alone does not bound K.
- Code review, major: nets_prover counted a +inf float output as surely safe: CertNet._ambiguous requires finiteness for both sure_fail and sure_safe. Regression test test_regression_overflow_to_inf_is_not_surely_safe uses the referee's d=1 net (ENUM gives exactly [1,1], OPEN with 4000 samples covers p=1) and the mirrored net. Verified by atk_prover_inf.py.
- Code review, major: nets_lower rounded subnormal counts up; betting_lower lost its margin when the result is subnormal: Witnesses.lower, the stratum and stratum+L_smc use _float_down on exact Fractions. betting_lower subtracts two ulps when the result is subnormal. Regression tests at d=1075 and 1076 (witnesses=, stratify) and for 64 replicates Z=3*2^-1074. Verified by atk_lower_subnormal.py.
- Code review: betting_lower bet sizes not validated: Rejects any lambda outside [0,1], NaN, empty or non-1-D input. The regression test covers (3,), (-0.5,), (0.5,1.5), (), (nan,) and [[0.5]]. atk_betting_lams.py now raises ValueError.
- Code review: supplied witnesses trusted; non-cube rows packed as cube points: lower_bound re-evaluates supplied witnesses on the net (counted in pilot evaluations) and drops forged or wrong-length codes. Witnesses.add refuses non-cube rows. The regression test covers both referee demonstrations and checks that genuine witnesses survive.
- Code review: estimate_undecided accepted first<=0: first must be an integer >=1 and max_samples an integer >=0, else ValueError. The regression test covers first in {-1, 0, 1.5, True, '8'} and max_samples=-1 on the referee's p=513/1024 net.
- Code review: bab/estimate_undecided used a bounder or result built for another net: Bounder and BabResult carry a SHA-256 fingerprint of the weights, biases and threshold; mismatches raise ValueError. estimate_undecided also checks the undecided cubes: entries in {-1,0,1}, one dimension r, and rows*2^r == undecided. Regression test included.
- Code review: root cast to int8 before validation in verify and prove: _subcube validates in float64 before the cast. The regression test checks that (0.6,0,0,0), (1.9,...), (-0.9,...), NaN, a wrong length and 2 all raise in both verify and prove.
- Code review: CertNet crashed at threshold ±FMAX: _round_up and _round_down stop once the value is infinite. test_threshold_at_the_largest_float checks verify and prove against the exact count for both signs.
- not done: Code review's extra suggestion: make stats.kl_interval raise ValueError when N < 0: stats.py is outside this integration's files and others may be editing it. Every nets caller validates N before calling it: estimate_undecided rejects first<1 and max_samples<0, the prover's verify clamps N>=0, and nets_lower starts N at 1. So the nets code is protected, but the shared function still accepts N<0.
- not done: Duplicate PDF hyperlink anchors for every table and figure (pdfTeX 'destination with the same identifier', 22 warnings) and 5 underfull boxes: Not required by the task (no undefined references or citations and no overfull boxes holds). Both predate this round: the build before the nets section had 11 duplicate warnings (one per float) and the same 5 underfull boxes. The aux labels are unique, so the duplicates come from the shared preamble, which I don't own.
