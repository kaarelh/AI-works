# Reproduction report

Role: reproduction. Date of the runs: 2026-11-16. Machine: Linux, 4 cores, 15 GB of memory, Python 3.13.18, numpy, scipy 1.18.1, mpmath; sympy is **not installed**.

Method. Every script was run unchanged from its own directory with `python3 <script>` and no arguments (except where a docstring or the project README names an argument, as stated below), under `timeout 600` and `ulimit -v 4194304` (4 GB of virtual memory), with `PYTHONDONTWRITEBYTECODE=1` (so that nothing was written into the repository) and one BLAS thread. At most two scripts ran at a time. Standard output went to a scratch directory and was compared byte for byte (`cmp`, then `diff`) with the saved `.out` file of the same name. No script and no saved output was edited.

## 1. The three toy computations of Section 11

| script | command | time | result |
|---|---|---|---|
| `code/toy.py` | `python3 toy.py 60` | 163 s | ran; identical to `results/toy.out` |
| `code/toy_stakes.py` | `python3 toy_stakes.py` (no argument, as the docstring's "Usage" allows) | 40 s | ran; **different**: the default is 20 trials, the saved output says 40 trials, and the numbers differ |
| `code/toy_stakes.py` | `python3 toy_stakes.py 40` (the command in `README.md`, line 39) | 80 s | ran; identical to `results/toy_stakes.out` |
| `code/toy_property.py` | `python3 toy_property.py` | 27 s | ran; identical to `results/toy_property.out` |

So all three saved outputs reproduce exactly with fixed seeds. The only point to record is that `toy_stakes.py`'s docstring gives `[trials]` with a default of 20 and does not say that the saved output used 40; the README gives the right command. This is a documentation point, not a numerical mismatch.

### Every number of Section 11 of note.md against the outputs

Checked one by one against the reproduced outputs (which are identical to the saved ones).

| note.md, Section 11 | output | agrees |
|---|---|---|
| class of 1117 functions; K = 3.78 bits | toy.out line 1: 1117 functions, K = 3.78 bits | yes |
| f, two simpler functions, 90 guards, 1024 patches | not printed by the script; I counted the names returned by `toy.build_class()`: 1 f, "saturating", "small only", 90 guards, 1024 patches (1 + 2 + 90 + 1024 = 1117) | yes |
| posterior after 100 and 10,000 naive questions: 0.59 small only, 0.30 saturating, 0.07 f | toy.out naive block, both n | yes |
| unfaithful run in 35% (depth 2), 98% (depth 4), 100% (depth 6) | 0.347, 0.981, 1.000 at n = 10000 | yes (rounded) |
| rehearsal, summed unfaithful calls 2.3, 21.7, 91.8 | 2.28, 21.70, 91.78 at n = 6400 | yes |
| bounds L·K ln 2 = 7.9, 39.3, 165.0 | 7.9, 39.3, 165.0 | yes |
| average Pr[run unfaithful] 0.0004, 0.0025, 0.0043 | 0.0004, 0.0025, 0.0043 | yes |
| 60 repetitions | "trials per cell: 60" | yes |
| one-mind runs 1.6, 15.4, 22.3 | 1.57, 15.37, 22.30 | yes |
| R4 bounds 11.8, 73.7, 325 | 11.8, 73.7, 324.8 | yes |
| map runs 3.3, 21.1, 27.2 | 3.28, 21.07, 27.20 | yes |
| R6(a) bounds 6, 30, 126; "only two functions heavier than f" | 3 x 2, 15 x 2, 63 x 2 | yes |
| high stakes after 6400 questions: 0.1%, 1.2%, 11.9% for L = 16, 256, 4096 | 0.0011, 0.0117, 0.1187 | yes |
| low stakes: 0.11%, 0.03%, 0.03% | 0.0011, 0.0003, 0.0003 | yes |
| bound K ln 2/(θn) = 0.82% | 0.0082 | yes |
| certificate: n = 400, L = 256, m = 1000, 160 repetitions, no disagreement in 140 | fraction 0.875 and "0/140": 140/0.875 = 160 | yes |
| ln(20)/1000 = 0.003 | 0.00300 | yes |
| true rate 0.00014 on average, never above the bound | 0.00014; 0/140 | yes |
| property toy: mod 8, depth 3, 805 tests | toy_property.out line 1: 805 tests, 8x8 questions, depth 3 (L = 7) | yes |
| deterministic human: audited answers exact in every round of the second half | "exact sums among audited" 1.0000 at n = 1000, 8000, 64000 (rates over the last half of the rounds) | yes |
| noisy human: exact sums at rate 0.90, the human's rate | 0.8995 at n = 64000; human 0.9000 | yes |
| max |S_n(B)|/n = 0.0003 after 64,000 rounds; bound 0.024 | 0.0003; 0.0241 | yes |
| root exact in 62% against 48% for the human system | 0.6197; human 0.4773 | yes |
| 57% under Rule NH after 8000 rounds (`proofs/code/property-online_rehearsal.out`) | "n = 8000, rule NH ... root exact, deployed: 0.5710" | yes |

All numbers of Section 11 agree with the outputs.

## 2. The scripts of proofs/code

125 Python scripts; 125 saved outputs of the same name, plus one saved output without a script of that name, `property-online_attack_finite_BC.out` (parts (B) and (C) of `property-online_attack_finite.py`, according to `verification/property-online-attack.md`). Every script was run with no argument. "identical" means byte-identical standard output. "timing only" means that the only differing lines are a run time printed by the script (`time N s`) or the `real/user/sys` lines of the shell's `time` command, which the saved file contains and my capture does not. Time is wall-clock seconds on this machine, with another process sharing the CPUs.

| script | status | time (s) | comparison with the saved .out |
|---|---|---|---|
| `assumptions_attack_core.py` | ran | 30 | identical |
| `assumptions_attack_episodes.py` | ran | 25 | identical |
| `assumptions_attack_lower.py` | ran | 14 | identical |
| `assumptions_check_episodes.py` | ran | 34 | timing only (`real/user/sys` lines in the saved file) |
| `assumptions_check_exact.py` | ran | 8 | identical |
| `assumptions_check_numbers.py` | ran | 17 | timing only (`real/user/sys` lines in the saved file) |
| `assumptions_checks.py` | ran | 24 | identical |
| `assumptions_editor_checks.py` | ran | 7 | identical |
| `assumptions_episodes.py` | ran | 12 | identical |
| `hellinger-runs_attack_events.py` | ran | 98 | timing only (one line `time N s`) |
| `hellinger-runs_attack_l4.py` | ran | 283 | timing only (one line `time N s`) |
| `hellinger-runs_attack_lb.py` | ran | 89 | timing only (one line `time N s`) |
| `hellinger-runs_attack_misc.py` | ran | 2 | timing only (one line `time N s`) |
| `hellinger-runs_attack_r2.py` | ran | 6 | timing only (one line `time N s`) |
| `hellinger-runs_attack_recorded.py` | ran | 101 | identical |
| `hellinger-runs_editor_checks.py` | ran | 8 | identical |
| `hellinger-runs_ex48many.py` | ran | 72 | identical |
| `hellinger-runs_l4_check.py` | ran | 14 | identical |
| `hellinger-runs_l4_lp.py` | ran | 15 | different in content only because the saved file was made with the argument `fine` (two more LP rows). Re-run with `fine`: the row u = 1.025 is identical; the row u = 1.018 (2,667,126 constraints) failed with `MemoryError: std::bad_alloc` in scipy HiGHS under the 4 GB limit, so that one saved line (c_G = 2.90589) is **not reproduced** |
| `hellinger-runs_potentials.py` | ran | 139 | different in content only because the saved file was made with the argument `fine`; re-run with `fine` (154 s): identical |
| `hellinger-runs_r2_coins.py` | ran | 6 | identical |
| `hellinger-runs_sec3.py` | ran | 6 | identical |
| `hellinger-runs_sec45.py` | ran | 15 | identical |
| `hellinger-runs_symbolic.py` | failed | 0 | `ModuleNotFoundError: No module named 'sympy'`. Re-run with sympy 1.14.0 installed into a scratch directory (`pip install --target`, PYTHONPATH): ran in 2 s, identical |
| `hellinger-runs_thmA.py` | ran | 6 | identical |
| `hellinger-runs_thmB.py` | ran | 2 | identical |
| `lower-bounds_ab_sim.py` | ran | 18 | identical |
| `lower-bounds_attack_ab.py` | ran | 29 | timing only (`real/user/sys` lines in the saved file) |
| `lower-bounds_attack_budget.py` | ran | 7 | timing only (`real/user/sys` lines in the saved file) |
| `lower-bounds_attack_patch.py` | ran | 4 | timing only (`real/user/sys` lines in the saved file) |
| `lower-bounds_attack_sharper.py` | ran | 14 | timing only (`real/user/sys` lines in the saved file) |
| `lower-bounds_attack_tolerance.py` | ran | 0 | timing only (`real/user/sys` lines in the saved file) |
| `lower-bounds_constants.py` | ran | 2 | identical |
| `lower-bounds_editor_checks.py` | ran | 13 | identical |
| `lower-bounds_lp.py` | ran | 26 | identical |
| `lower-bounds_needle_exact.py` | ran | 3 | identical |
| `lower-bounds_sim.py` | ran | 3 | identical |
| `one-mind_attack_map.py` | ran | 0 | identical |
| `one-mind_attack_r4.py` | ran | 5 | identical |
| `one-mind_attack_r5.py` | ran | 2 | identical |
| `one-mind_attack_sharp.py` | ran | 1 | identical |
| `one-mind_check_codebook.py` | ran | 5 | identical |
| `one-mind_check_exact.py` | ran | 2 | identical |
| `one-mind_check_r6examples.py` | ran | 4 | identical |
| `one-mind_check_series.py` | ran | 2 | identical |
| `one-mind_check_stochastic.py` | ran | 17 | identical |
| `one-mind_check_traps.py` | ran | 3 | identical |
| `one-mind_editor_checks.py` | ran | 44 | identical |
| `one-mind_r4.py` | ran | 22 | identical |
| `one-mind_r5.py` | ran | 60 | identical |
| `one-mind_r6.py` | ran | 15 | identical |
| `one-mind_stochastic.py` | ran | 4 | identical |
| `property-batch_attack_pr2.py` | ran | 10 | identical |
| `property-batch_attack_pr4.py` | ran | 13 | identical |
| `property-batch_attack_sec2.py` | ran | 212 | identical |
| `property-batch_attack_sec56.py` | ran | 74 | identical |
| `property-batch_attack_twosided.py` | ran | 3 | identical |
| `property-batch_cert.py` | ran | 21 | identical |
| `property-batch_check_joint25c.py` | ran | 10 | identical |
| `property-batch_check_sec2.py` | ran | 38 | identical |
| `property-batch_check_sec3.py` | ran | 8 | identical |
| `property-batch_check_sec4.py` | ran | 14 | identical |
| `property-batch_check_sec56.py` | ran | 5 | identical |
| `property-batch_editor.py` | ran | 14 | identical |
| `property-batch_pr2.py` | ran | 1 | identical |
| `property-batch_pr3.py` | ran | 38 | identical |
| `property-batch_pr4.py` | ran | 41 | identical |
| `property-batch_prices.py` | ran | 20 | identical |
| `property-online_attack_core.py` | ran | 32 | identical |
| `property-online_attack_ex23rehearsal.py` | ran | 2 | identical |
| `property-online_attack_finite.py` | failed | 565 | `MemoryError` in `part_A` (`ledger_worst(inst, 400)`) after 565 s under the 4 GB limit; the standard output up to the failure is identical to the saved `.out` (which also contains part (A) only). Parts (B) and (C) were run separately through a small driver that imports the script unchanged and calls `part_B()` and `part_C()`: output identical to `property-online_attack_finite_BC.out` |
| `property-online_check2_misc.py` | ran | 0 | identical |
| `property-online_check_ex23.py` | ran | 15 | identical |
| `property-online_check_game.py` | timed out | 600 | killed at 600 s; the 27 lines printed are identical to the first 27 of the 77 saved lines; the remaining 50 lines not reproduced within the limit (see the longer run below) |
| `property-online_check_potentials.py` | ran | 49 | identical |
| `property-online_check_rehearsal.py` | ran | 60 | timing only (`real/user/sys` lines in the saved file) |
| `property-online_check_tilt.py` | ran | 89 | timing only (`real/user/sys` lines in the saved file) |
| `property-online_editor_checks.py` | ran | 17 | identical |
| `property-online_fastrate.py` | ran | 7 | identical |
| `property-online_interior.py` | ran | 160 | identical |
| `property-online_lower.py` | ran | 33 | identical |
| `property-online_mixture.py` | ran | 0 | identical |
| `property-online_potentials.py` | ran | 3 | identical |
| `property-online_rehearsal.py` | ran | 19 | identical |
| `property-online_rules.py` | ran | 11 | identical |
| `property-online_tilt.py` | ran | 141 | identical |
| `property-online_variants.py` | ran | 4 | identical |
| `rehearsal-core_attack_budget.py` | ran | 0 | identical |
| `rehearsal-core_attack_ladder.py` | ran | 126 | identical |
| `rehearsal-core_attack_lastgeneral.py` | ran | 75 | identical |
| `rehearsal-core_attack_lastround.py` | ran | 40 | identical |
| `rehearsal-core_attack_lowstakes.py` | ran | 3 | identical |
| `rehearsal-core_attack_online.py` | timed out | 600 | killed at 600 s; the 9 lines printed are identical to the first 9 of the 10 saved lines; the last line (L = 3, r = 4: 1.4416) not reproduced within the limit (see the longer run below) |
| `rehearsal-core_attack_online_l3.py` | ran | 398 | identical |
| `rehearsal-core_attack_r1.py` | ran | 13 | identical |
| `rehearsal-core_attack_r3.py` | ran | 1 | identical |
| `rehearsal-core_attack_v1.py` | ran | 1 | identical |
| `rehearsal-core_attack_weighted.py` | ran | 1 | identical |
| `rehearsal-core_check_blind.py` | ran | 1 | identical |
| `rehearsal-core_check_constants.py` | ran | 0 | identical |
| `rehearsal-core_check_ladder.py` | ran | 86 | identical |
| `rehearsal-core_check_lastround.py` | ran | 12 | identical |
| `rehearsal-core_check_lowstakes.py` | ran | 0 | identical |
| `rehearsal-core_check_online.py` | ran | 212 | identical |
| `rehearsal-core_check_r1.py` | ran | 0 | identical |
| `rehearsal-core_check_sweep.py` | ran | 14 | identical |
| `rehearsal-core_check_v1.py` | ran | 2 | identical |
| `rehearsal-core_checks.py` | ran | 92 | identical |
| `rehearsal-core_editor_checks.py` | ran | 0 | identical |
| `rehearsal-core_lastround.py` | ran | 3 | identical |
| `rehearsal-core_lastround_count.py` | ran | 142 | identical |
| `rehearsal-core_lastround_count_mc.py` | ran | 13 | identical |
| `rehearsal-core_online.py` | ran | 43 | identical |
| `rehearsal-core_percall_and_stochastic.py` | ran | 1 | identical |
| `rehearsal-core_r1_exact.py` | ran | 1 | identical |
| `shift-abstain_ab1.py` | ran | 33 | identical |
| `shift-abstain_ab2.py` | ran | 72 | identical |
| `shift-abstain_attack_closed.py` | ran | 0 | identical |
| `shift-abstain_attack_s1.py` | ran | 0 | identical |
| `shift-abstain_attack_stop.py` | ran | 34 | identical |
| `shift-abstain_attack_thresholds.py` | ran | 0 | identical |
| `shift-abstain_check_s1.py` | ran | 0 | identical |
| `shift-abstain_check_thr.py` | ran | 28 | identical |
| `shift-abstain_open.py` | ran | 84 | identical |
| `shift-abstain_s1.py` | ran | 3 | identical |

Summary of part 2: of 125 scripts, 105 ran and gave byte-identical output; 14 ran and differ from the saved output only in printed run times; 2 differ only because the saved file was made with the argument `fine` (`hellinger-runs_l4_lp`, `hellinger-runs_potentials`), and with that argument `hellinger-runs_potentials` is identical and `hellinger-runs_l4_lp` is identical except one line that needs more than 4 GB; 2 failed (`hellinger-runs_symbolic`: missing sympy, identical once sympy is installed in scratch; `property-online_attack_finite`: MemoryError under 4 GB in part (A), printed output identical, parts (B) and (C) identical when run alone); 2 timed out at 10 minutes with the printed prefix identical (`property-online_check_game`, `rehearsal-core_attack_online`). No script produced a different number on any line it printed.

**Longer runs of the two scripts that timed out** (outside the 10-minute rule, as supplementary evidence; limit 30 minutes, 4 GB, two at a time): `rehearsal-core_attack_online.py` finished in 673 s with output identical to the saved file; `property-online_check_game.py` finished in 870 s with output identical to the saved file. So every saved output of `proofs/code/` is reproduced exactly except one line of `hellinger-runs_l4_lp.out` (the `fine` row u = 1.018), which needs more than 4 GB of memory and was not run beyond that limit.

`rehearsal-core_lastround_count.py` also accepts the argument `big`; the saved file matches the run without it, so `big` was not run.

## 3. Numerical claims of note.md that rest on a script

I listed every decimal number, percentage and large integer of `note.md` outside Section 11 together with its context (a regular-expression pass), kept those that also occur in a `proofs/code/*.out` file or in `results/`, and dropped section and theorem numbers. Several numbers that look script-based are analytic and are not output by any script in the form quoted: 0.29 (H² = 1 − 1/√2, Example 5.4 of `proofs/hellinger-runs.md`), 0.98 (1 − e^(−4), Example 3.6 of `proofs/one-mind.md`; a simulation in `one-mind_check_codebook.out` gives 0.9805 to 0.985, consistent), 0.11·L/n (a proved lower bound; `one-mind_check_traps.out` computes the exact quantity, about 0.20, which is consistent with the bound). They are not counted below. Each output named below was reproduced in this session and is identical to the saved one (or differs in timing lines only).

| # | claim in note.md | where | output | agrees |
|---|---|---|---|---|
| 1 | toy system: wrong in 35% to 100% of the runs after 10,000 ordinary questions; 6400 rehearsal questions bring the rate below half a percent | Section 0, item 6, line 28 | `results/toy.out`: 0.347 to 1.000 at n = 10000; average over 6400 rounds of Pr[run unfaithful] at most 0.0043 | yes |
| 2 | constant of Lemma L4(a) "can be 2.9642 and cannot be below 2.9639"; "lies between 2.9639 and 2.9642" | Section 3.2, line 108; Section 13, item 11, line 715 | `hellinger-runs_attack_l4.out`: c* = 2.96414715730767803218 (50 digits); `hellinger-runs_l4_lp.out` and `hellinger-runs_potentials.out`: explicit strategy with ratio 2.96399241 | yes (2.9642 is c* rounded up, 2.9639 the example rounded down) |
| 2a | "The note proves c₀ = 4 and, by a longer argument, c₀ = 2.9641" | Section 12, line 689 (source: `research/sections/related-work.md`, line 17) | c* = 2.964147 | **no**: 2.9641 < c*, so c₀ = 2.9641 is not what is proved; Sections 3.2 and 13 say 2.9642. The editor of hellinger-runs already asked for this change (`research/sections/hellinger-runs.md`, line 98); it has not been made |
| 3 | a member exact on the human system is refuted with probability 0.44 | Section 1 (caveat A2), line 52 | `assumptions_check_numbers.out` line 3–4: 1 − product = 0.443519, backward recursion 0.443519; `assumptions_attack_core.out` line 41: 0.443519 | yes |
| 4 | "for δ ≤ 0.63 a factor 0.45/δ is needed (Proposition 5.2)" | Section 3.1, line 93 | `rehearsal-core_check_constants.out` lines 4–5: 1 − e^(−1) = 0.632121 ≥ 0.63; 0.63/(2 ln 2) = 0.454449 ≥ 0.45 | yes (the script recomputes the constants; it does not check the proposition) |
| 5 | "every protocol has at least 0.088·L·√(K/n) unfaithful calls" | Section 3.4, line 144 | `rehearsal-core_check_constants.out` line 66: 1/(8√2) = 0.0883883 ≥ 0.088; `lower-bounds_sim.out` line 46 | yes (constant only) |
| 6 | "399 blindly replaced answers with failure 0.0007 ... an imitator for which δ + β/(k+1) is 0.021 (Example 8.5(d))" | Section 3.4, line 140 | `rehearsal-core_editor_checks.out` line 15 and `rehearsal-core_attack_r3.out` line 12: L = 4000, k = 399, blind 0.0007, seeing the answer 1.0000, δ + β/(k+1) = 0.0207 | yes |
| 7 | "For L = 100, n = 10⁴ and a human of weight 1/L, a deployment that visits x₁ meets 0.4975 unfaithful calls in expectation where B alone would allow 0.0463" | Section 6.1, line 348 | `shift-abstain_check_s1.out`: E = 0.4975, claimed S1 bound 0.04628; `assumptions_check_numbers.out` line 18: 0.4975 | yes (0.0463 is 0.04628 rounded; `shift-abstain_attack_s1.out` gives a slightly different candidate bound 0.04652, which would round to 0.0465, for a variant of the candidate formula) |
| 8 | "violating 0.71, silent 0.18, abiding 0.11 in one example with C_R = 5" | Section 8.6, line 543 | `property-batch_editor.out` line 15: 0.7111, 0.1778, 0.1111 at C_R = 5 | yes |
| 9 | "with probability above 0.51 after any n ≤ min{u/4, (K − 2)/log₂(4u + 2)}" and the version (c − 5)/(d + 2) for machines | Section 8.6, line 545 and following | `property-batch_check_sec4.out` lines 6, 34, 45: constants 0.511364 and 0.5134, all computed values above 0.51; `property-batch_editor.out` line 21–22 | yes |
| 10 | table of Section 9.1: 10⁵ answers pay for 1443 bits; 50 answers for 0.72 bits; 2·10⁹ answers for 2.9·10⁷ bits (θ = δ = 0.1) | Section 9.1, lines 571–573 | `assumptions_editor_checks.out` lines 51–54 and `assumptions_checks.out` lines 119–126: 1443, 0.7213, 2.885e+07 | yes |
| 11 | "300 rounds certify an excess failure 0.1 under θ = 0.1 at δ = 0.05"; "300 short answers at θ = δ = 0.1 and confidence 0.95" | Section 3.5, line 168; Section 10, line 645 | `assumptions_check_numbers.out` line 53: ln 20/(θδ) = 299.6 | yes |
| 12 | rule with one rate: exact root in 62% of runs against 48% for the human system | Section 8.5, line 531 | `results/toy_property.out`: 0.6197 against 0.4773 | yes |

Of the twelve claims, eleven agree. Claim 2a is a disagreement between the note's Section 12 and both the script output and the note's own Sections 3.2 and 13.

## 4. Mismatches

1. **Section 12 of note.md (line 689; source `research/sections/related-work.md`, line 17) states "c₀ = 2.9641".** The computed constant is c* = 2.964147... (`hellinger-runs_attack_l4.out`, 50-digit arithmetic), so 2.9641 is below the constant actually proved; Section 3.2 (line 108) and Section 13, item 11 (line 715) correctly say 2.9642. The hellinger-runs editor had already asked for this change (`research/sections/hellinger-runs.md`, line 98). Fix: in `research/sections/related-work.md`, line 17, replace "c₀ = 2.9641" by "c₀ = 2.9642" (and in its line 86 the list "4, 2.9641 and 2.9639" by "4, 2.9642 and 2.9639"), then re-assemble.

No other mismatch was found: every number of Section 11 agrees with the toy outputs, and every saved output reproduces.

## 5. Points recorded as OK (not mismatches), for the record

* `code/toy_stakes.py`: its docstring says `Usage: python3 toy_stakes.py [trials]` with a default of 20; the saved output was made with 40 trials, as `README.md` line 39 says. Running with the default gives different numbers. Optional fix: say in the docstring that `results/toy_stakes.out` uses 40 trials.
* `hellinger-runs_l4_lp.out` and `hellinger-runs_potentials.out` were made with the argument `fine`, which their scripts accept but no comment in the saved file records. Optional fix: note the argument at the top of each saved output or in the proof file that cites them.
* `hellinger-runs_symbolic.py` needs sympy, which is not installed in this environment; with sympy 1.14.0 (installed in scratch only) the output is identical.
* `property-online_attack_finite.py` stops with a MemoryError in part (A) under a 4 GB limit; its saved output contains part (A) only and the output of parts (B), (C) is saved separately as `property-online_attack_finite_BC.out`, which has no script of its own name. Both reproduce. The memory needed for the full part (A) was not determined.
* `property-online_check_game.py` (870 s) and `rehearsal-core_attack_online.py` (673 s) exceed 10 minutes on this machine.

## 6. What was not checked

* The mathematics: I checked that numbers agree between the note and the outputs and that the outputs reproduce; I did not check that the scripts compute what the proofs say, nor the proofs.
* The analytic numbers listed at the start of Section 3 (0.29, 0.98, 0.11·L/n, and the arithmetic 3.5·10⁷ working years) were not checked against a script, since none prints them; I recomputed 3.5·10⁷ by hand (10⁹ · ln 2 / 0.01 hours / 2000 hours per year = 3.47·10⁷) and it agrees.
* No literature was consulted for this report.
