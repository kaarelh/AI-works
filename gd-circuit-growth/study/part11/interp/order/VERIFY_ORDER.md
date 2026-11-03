# Verification of ORDER.md (Part 11, Q7 'order')

Independent verification, 3 November 2026. The object is [`ORDER.md`](ORDER.md) and its scripts and outputs: `order_fit.py`, `order_analysis.py`, `order_report.py`, `order_validate.py`, `tables/*`, `results/order_summary.json.gz` and `results/cells/*`.

## Method

Everything was recomputed by my own code (scripts listed at the end), single-threaded, one process at a time, without touching the running ablation queue.

- **Refits.** 12 cells were refitted through a separate path (`eval_dfg.make_learner`, harness data, my own wrappers of `DFG._fit` and `numpy.linalg.solve`).
- **Round-0 z-scores.** All 23,727 were recomputed from the raw training rows, with my own implementation of dfg13.py's round-0 test.
- **Network onsets.** These were re-derived from `trajectories/results` under four conventions:
  - the seed-mean curve, interpolated;
  - the seed-mean curve, not interpolated (stages.py's literal rule);
  - the geometric mean of the per-seed onsets;
  - the arithmetic mean of the per-seed onsets.
- **Orders and taus.** These were recomputed for all 11 targets with my own Kendall tau-b, onset rules, pair counter, route reader and n_glob.

Claims checked: 60. Confirmed 41, corrected 19, unsupported 0.

## Verdict

Numerically sound: 41 of the 60 claims checked are confirmed. The other 19 need correction, mostly of wording or of descriptive detail, and there is one important omission. Reproduced by my own code: (1) all 363 cells equal toy__dfg13-perm__designed.json in test error and FLOP count, and 12 independent refits (eval_dfg.make_learner, harness data, my own wrappers of DFG._fit and numpy.linalg.solve) also reproduce the rounds, the feature counts, the logged s and n_new, and every replayed mean(r chi_S) to 5e-7; (2) all 23,727 round-0 z-scores, recomputed from the raw training rows, match to 5e-7; (3) the decision tally 3217 / 13 / 29890 / 17 holds with nothing unexplained, including the stopping rounds that order_validate.py skips; (4) every tau-b, pair count, route count, route median, endpoint share, data-cost count and non-monotone count in the tables, including 32/33, 30/33 and 24/33, the round-0 priority (44/44 positive), the n-axis taus (0.09-0.71, median 0.40), the like-for-like taus (0.17-0.67) and mux's x1x2x3x4 (first by z0 in 30/30 fits, n_glob 54 vs 271); (5) the network onsets: seed-mean, interpolated, e.g. mux 60-66 / 169-176 / 430 / 452. The taus move by at most 0.05 under the per-seed geometric mean. The n_glob formula matches thr(N) (K = self.K = 4, c = 1, delta = 0.1) and the round-0 residual y - mean(y). Needs correction (19 claims): (a) the headline 'never negatively': per fit, 3 of 69 multi-round round-order taus are negative (mux at n = 64: -0.48, -0.05; rmaj9 at 512: -0.01); (b) the onset rule is analyze_traj's interpolated crossing, not stages.py's rule; stages.py's literal rule gives mux +0.21, not +0.09; (c) the dnf3 x1..x9 geometric mean is 2115, not 2117, and the conventions differ by more than 10% for 143 characters, not one; (d) 'Mux, the lowest' is false at n = 16384 and 512 (dnf3 is lower); (e) majpar's 'n_glob 147 = the cap': the cap is 73 rows at n <= 512, and nglob() ignores this; (f) parmaj's pairs and degree-4 terms do not 'come by global tests' at the onset n = 128: no test admits any character there, and 42 of 45 character-seeds are block-carried; (g) rmaj9's degree-5 and degree-7 terms are carried at 512-4096 and dropped, not 'never carried'; (h) slips in sec. 4.3: stair5's 'one place', andxor seed 2, dlist5's 'of higher degree' (25 of 33), rmaj9's network range, dnf3's size ranges, mux's seed-2 forced pick; (i) the 5.3-doublings median is quoted for degree 6-9 characters, which have no n_glob; (j) 'all or nothing: passes a test or not': 1134 of the 1497 carried character-seeds are block-carried; (k) two generalisations: 'bundles cut by coefficient size, not by construction' (equal-coefficient characters are split by degree on sparsepoly and majpar) and 'within degree <= 4 a large coefficient is first whatever its degree' (5 of 8 targets). Main omission: the networks' n-axis estimator, a 4096-point test-set mean, cannot resolve small coefficients. Its sampling sd on phi is 0.0156/|yhat|: 4.0 for dnf3's 0.0039-characters, and a network equal to the target would score phi from -9.9 to +9.6 on them. Hence the following are noise-dominated: dnf3's like-for-like tau of 0.17 (0.56 on its 21 resolvable characters), its net-time-vs-net-n tau of 0.19 (0.87), 218 of the networks' 223 'dropped' characters, and 255 of the 349 'small' data-cost characters. The pooled route medians are dominated by dnf3: outside it, block-carried characters sit 2.7 doublings below n_glob, not 5.3. None of Part 10's corrections is reintroduced.

## Claims

**1. [confirmed]** Sec. 1.5 Identity: all 363 refits equal part11/results/toy__dfg13-perm__designed.json exactly, in test error and FLOP count.

- *Evidence:* v_cells.py: 363/363 cells have err and flops == the result file (exact float equality); grid complete (11 targets x 11 n x 3 seeds). Independently, v_refit.py refits 12 cells through a separate code path (eval_dfg.make_learner + harness.train_data/test_data + rng default_rng([fn_seed, seed, n, 77]) + my own wrappers of DFG._fit and numpy.linalg.solve): mux 128/0, andxor 32/1, parmaj 512/1, majpar 256/0, rmaj9 512/0, rand3 128/1, stair5 128/1, dnf3 2048/0, mux 64/2, dlist5 128/2, dnf3 16384/1, rand1 512/0. All reproduce err, flops, rounds, p_j, the logged s and n_new of every round. md5 of dfg13.py = 69cabe5c50345cb24079198ed52b562f. As in Part 10's C0 note, the identity check itself compares two scalars per cell, not predictions; the refits add the round logs.

**2. [confirmed]** Sec. 1.5 Residual replay: rms of the residual rebuilt from the recorded weights matches DFG's round log to 4 decimals in all 363 final fits.

- *Evidence:* s_check true in 363/363 cells; my refits rebuild the same residuals from my own recorded solves (replayed mean(r chi_S) to < 5e-7 in 12 cells, 3,682 values) and my round-0 residual y - sum(y)/(n + 1e-9) gives the stored s_replay[0] in all 363 cells.

**3. [confirmed]** Sec. 1.5 Test replay: 3217 test admissions with z > 1; 13 admissions with z <= 1, all forced picks; 29890 non-admissions with z <= 1; 17 non-admissions with z > 1, all in rounds that hit the 64-per-round cap or the p <= n/2 room; none unexplained.

- *Evidence:* My recount (v_cells.py): 3217 / 13 / 29890 / 17, 0 unexplained. The 13 z <= 1 admissions are all in variant-1 fits, in rounds with n_new = 1 and no block, and no other target character exceeds z = 1 in those rounds (consistent with dfg13's forced rule). All 17 capped rejections are one round (dnf3 n = 16384 seed 1, round 1, n_new = 64): the 64-per-round cap, none the room. order_validate.py does not test the stopping round; I did: 192 stopping rounds contain a target character with z > 1, all of them sign-rule stops (DFG breaks before testing), and none of the 90 'nothing passed/budget/room' stops has one. Round-0 z-scores recomputed from the raw training rows with my own implementation (v_z0.py: thr(N) = s sqrt(2 ln(4*4*N/0.1)/n), degree 3-4 only if n >= 32, degree 5-6 on min(n, cap) rows with cap 1374/147 at scale 1 and 687/73 at scale 0.5 for n <= 512) match all 23,727 stored values to 5e-7. Precision: the 17 are all the 64-cap, none the room.

**4. [confirmed]** Sec. 1.5 Compute: 17.8 CPU-minutes in all, longest fit 13.9 s, single-threaded.

- *Evidence:* Sum of cpu_seconds over the 363 cells = 17.83 min; max 13.88 s (dlist5 n = 128 s2).

**5. [confirmed]** Sec. 1.3/Header: the fits are bit for bit eval_dfg.py's fit of the md5-checked frozen dfg13.py.

- *Evidence:* md5 checked; identity of err/flops in 363 cells and of the full round logs in 12 independent refits (see above).

**6. [confirmed]** Sec. 1.1: the 11 Part 5 targets have 3 (andxor) to 511 (dnf3) non-constant characters, 719 in all; DFG at (n, seed) sees exactly the training set of the network at (n, seed) in Part 5's fixed conditions and in the fixed-n study.

- *Evidence:* Counts from the cells: 7, 16, 8, 4, 76, 3, 31, 16, 511, 15, 32 = 719. harness.train_data = default_rng([fn_seed, seed]), first n of 16384 rows; nn_train.make_data is identical and run_traj.py (fixed) calls T.make_data(fn, s, max(ns) = 16384).

**7. [corrected]** Sec. 1.2: 'I use the onset of the seed-mean phi curve (the stages.py convention)'.

- *Evidence:* order_analysis.first_cross is analyze_traj.first_cross (log-interpolated between checkpoints) applied to the seed-mean curve. stages.py averages the seeds too but takes the first checkpoint with phi >= 1/2 staying >= 0.4, without interpolation. My recomputation with stages.py's literal rule (v_net_onsets.py, convention B) puts mux's three linear onsets all at 66 and x1x2x3 and x1x2x3x4 both at 463. It changes tau(net time, DFG n) for mux from +0.09 to +0.21 and for rmaj9 from +0.68 to +0.83, and tau(net time, net n) for majpar from +0.82 to +0.50. The per-seed geometric mean (convention G) changes every reported tau by at most 0.05.
- *Correction:* Say 'the seed-mean phi curve with analyze_traj's log-interpolated first crossing'. stages.py's own rule, which does not interpolate, gives somewhat different taus (mux +0.21).

**8. [confirmed]** Sec. 1.2: the onsets reproduce TRAJECTORIES.md sec. 2.2 to within about 10% for most characters; mux: linear 60-66, x_i x4 169-176, x1x2x3 430, x1x2x3x4 452.

- *Evidence:* Seed-mean interpolated onsets (my code): mux x3 60.1, x1 62.3, x2 65.5; x3x4 168.8, x2x4 171.7, x1x4 176.5; x1x2x3 429.5; x1x2x3x4 452.0. Against the per-seed geometric mean (what sec. 2.2 uses), 576 of 719 characters are within 10% (500 within 5%).

**9. [corrected]** Sec. 1.2: 'One exception: sec. 2.2 evidently uses the geometric mean of per-seed onsets. dnf3's x1..x9 has per-seed onsets 504, 3209 and 5858 (geometric mean 2117; sec. 2.2 gives 2115), while its seed-mean curve crosses 1/2 at 3598.'

- *Evidence:* Sec. 2.2 does use the per-seed geometric mean. Its stage values are geometric means of the characters' per-seed geometric means, e.g. sparsepoly x2x3 297.0 (seed-mean curve 299.0), the x4x5x6 stage 1389, mux 63 / 172 / 437. The stored per-seed onsets are 3209.1, 5857.6 and 503.6, whose geometric mean is 2115.4. Rounding the seeds first gives 2116.6. The seed-mean crossing is 3598.1 (confirmed). The conventions differ by more than 10% for 143 characters: 142 on dnf3 (e.g. x2x7 228 vs 178, x1x4x7 789 vs 996), plus stair5's x1x2x4 (703 vs 588).
- *Correction:* Geometric mean 2115 (identical to sec. 2.2). The convention difference exceeds 10% for 143 characters (142 of them dnf3's), not only x1..x9.

**10. [confirmed]** Sec. 1.2: network n onset = smallest grid n whose network at step 20000 has phi >= 1/2 with phi >= 0.4 at every larger n; coef = test-set mean of f chi_S for |S| <= 4.

- *Evidence:* nn_train.make_eval: coef = fte @ chi / 4096, char_sets kmax = 4; order_analysis.net_n uses coef[-1] (step 20000) and first_good.

**11. [confirmed]** Short answer 1 / sec. 1.4 / sec. 2: at n = 16384, 2048 and 512 DFG's carried target characters enter in a single round in 32, 30 and 24 of the 33 fits; it then stops because every training sign is right; one round in 86 of the 99 fits at Part 5's n.

- *Evidence:* My recount from phi_ls (v_orders.py): fits with >= 2 entry rounds 1, 3, 9 at 16384, 2048, 512; rounds_n = 1 in 32 + 30 + 24 = 86; stop = all-training-signs-right in 99/99.

**12. [confirmed]** Sec. 2 table: fits with >= 2 entry rounds 0, 2, 11, 24, 12, 9, 2, 3, 4, 1, 1 (n = 16..16384); mean tau(network onset online, DFG half-round order) -, 0.77, 0.44, 0.44, 0.30, 0.25, 0.18, 0.15, 0.22, 0.12, 0.10; positive -, 2, 9, 24, 11, 8, 2, 3, 4, 1, 1.

- *Evidence:* Recomputed exactly with my own tau-b and round onsets (v_orders.py).

**13. [confirmed]** Sec. 2: at n = 128 the forced variant is chosen in 15 of 33 fits (14 of the 24 multi-round ones) and the round order agrees with the networks' in every multi-round fit (tau 0.08-0.93).

- *Evidence:* 15/33 variant = 1 at n = 128; 14 of the 24 multi-round; tau_half range 0.08 (mux s0) to 0.93 (sparsepoly s2).

**14. [confirmed]** Sec. 2: multi-round fits at n = 512: rmaj9 (3 seeds), dlist5 (2), dnf3 (2), parmaj (1), rand1 (1); at 2048 rmaj9 s2, dnf3 s0 and s2; at 16384 dnf3 s1. All 99 fits end by the sign rule; test error 0 in 97, the exceptions dnf3 at n = 512 (0.006, 0.017).

- *Evidence:* dlist5 s1, s2; dnf3 s1, s2; parmaj s1; rand1 s0. Errors 0.00635 (dnf3 s0) and 0.01733 (dnf3 s2).

**15. [confirmed]** Sec. 2: rmaj9 at n = 16384 gives tau 0.59-0.71 (one-round fits; DFG omits the degree-5 and -7 terms).

- *Evidence:* Round-order tau against the online seed-mean onsets: 0.59, 0.71, 0.71 (against the seed-matched n = 16384 networks: 0.65, 0.70, 0.71).

**16. [confirmed]** Sec. 2: rmaj9 seed 0 at n = 512 (round 0: 9 linear, x1x2x3, x7x8x9 and the full-sum block carrying x1..x9; rounds 1-3 modulated blocks such as chi[x7,x8,x9]*|x1+x2+x3-x4-x5-x6| carrying degrees 3, 5, 7) and parmaj seed 1 at n = 512 (round 0: 8 of 9 cross pairs, 4 of 6 degree-4 terms, x1..x6 by |-x1-x2-x3+x4+x5+x6|; round 1: x3x4 and the other 2 degree-4 terms).

- *Evidence:* Cells as described (v_cells2.py); after round 1 of rmaj9 s0 phi >= 1/2 for 9 degree-5 and 6 degree-7 characters, after round 2 for all 27 and 9. Round 3 also adds unmodulated blocks, and rounds 1-2 also admit explicit characters (x4x5x6 local, x3x6x8, x2x4x9, x1x5x7).

**17. [corrected]** Short answer 2 heading: 'Where it exists, it agrees with the networks' order moderately, never negatively.'

- *Evidence:* True for every per-target aggregate (z0 means, n-axis taus). Per fit it is false. The round-order (half-round) taus are negative in 3 of the 69 multi-round fits: mux n = 64 seed 2 -0.48, mux n = 64 seed 1 -0.05, rmaj9 n = 512 seed 0 -0.01. They are 0.00 in one more (sparsepoly n = 256 s1). Per seed, 131 of 132 z0 taus are positive and one is 0.00 (mux n = 2048 s2). The sec. 2 table does show 9/11, 11/12 and 8/9 positive.
- *Correction:* '... never negatively in the per-target summaries; per fit the round order is negative in 3 of 69 multi-round fits (mux at n = 64: -0.48, -0.05).'

**18. [confirmed]** Short answer 2 / sec. 3: inside round 0 at n = 16384 DFG's priority is positively rank-correlated with the networks' onsets on all 11 targets (tau 0.22-0.81, median 0.54); all 44 per-condition entries positive.

- *Evidence:* Recomputed (network seed s vs DFG seed s): 16384 row 0.81, 0.52, 0.31, 0.67, 0.56, 0.33, 0.54, 0.54, 0.22, 0.65, 0.58 (median 0.54); online, 2048 and 512 rows exactly as tabulated; 44/44 means positive. Note the 'online' row uses the networks' seed-mean onset for all three DFG seeds, not seed-matched networks; seed-matched online values are 0.20-0.81, all positive.

**19. [confirmed]** Sec. 3: z0 ~ |yhat_S| sqrt(n) / (s sqrt(2 ln(4K C(30,|S|)/delta))) for |S| <= 4 at d = 30; degrees 5 and 6 on budget-capped subsamples (m <= 1374 and <= 147 rows); degree >= 7 z0 = 0.

- *Evidence:* Matches dfg13.py: the degree-3/4 subsample caps are 87,307 and 29,627 rows (> 16384), so m = n. The caps are 1374/147 at scale 1 and 687/73 rows for the final fit at n <= 512 (scale 0.5). Degree 3-4 are searched only if n >= 32. Check: mux x1x2x3x4 at n = 16384 predicted sqrt(16384/54.4) = 17.35, observed 17.05-17.51.

**20. [confirmed]** Sec. 3: mux: 6 of its 21 network-ordered pairs are inverted, all involving x1x2x3x4; x1x2x3x4 has the highest z0 in every fit at n >= 64 (30) and in 2 of 3 at n = 32; at n = 16384 its z0 is 17.1-17.5 against 6.1-8.3.

- *Evidence:* 6/21 inverted in each seed, all (other, x1x2x3x4); strictly highest z0 in 30/30 at n >= 64 and 2/3 at n = 32; 17.05-17.51 vs 6.11-8.26.

**21. [corrected]** Sec. 3: 'Mux, the lowest.'

- *Evidence:* Mux is lowest in the online row (0.24 vs dnf3 0.25) and at n = 2048 (0.10). In the n = 16384 row that the section tabulates, dnf3 (0.22) is below mux (0.31), and at n = 512 dnf3 (0.09) is below mux (0.19).
- *Correction:* 'Mux, among the lowest (lowest online and at n = 2048; dnf3 is lower at 16384 and 512).'

**22. [confirmed]** Short answer 2 / sec. 4.1: tau(networks' time, DFG n) 0.09 (mux) to 0.71 (majpar), median 0.40 on 9 targets; andxor and parmaj all tied; pairs c/t/i per target; over the 10 targets other than dnf3 1170 / 359 / 119 (1648).

- *Evidence:* Every entry of the sec. 4.1 table recomputed exactly with my own tau-b and pair counter (v_orders.py), including dnf3 34171 / 8989 / 13265.

**23. [confirmed]** Short answer 2 / sec. 4.1: like for like, tau(networks' n, DFG n) 0.17-0.67, median 0.40; the networks' time and n orders agree with each other at tau 0.19-0.95, median 0.75.

- *Evidence:* Recomputed exactly. But see omission 1: dnf3's values (0.17 and 0.19) rest mostly on its 234 characters with |yhat| = 0.0039 or 0.027. For these the networks' n-axis phi has a test-set sampling sd of about 4.0 and 0.57. On dnf3's 21 resolvable characters (|yhat| = 0.19, sd 0.08) the two taus are 0.56 and 0.87; with those, the networks' self-agreement ranges 0.55-0.95 (median 0.82).

**24. [corrected]** Sec. 1.4: 'networks' n order vs DFG's n order: like for like, yes, in data and criterion'.

- *Evidence:* Same training sets, grid and rule, confirmed. But the criterion is applied to estimators with very different noise. The networks' phi is a 4096-point test-set mean of f chi_S. Even for a network equal to the target it ranges from -9.9 to +9.6 on dnf3's |yhat| = 0.0039 characters (45 of 108 below 0.5), from -0.52 to 2.57 on its 0.027-characters, and from 0.42 to 1.54 on rmaj9's 0.0625-characters. DFG's phi is a cube average; my M = 1024 probe changes its classification for at most 2 of 511 dnf3 characters.
- *Correction:* Like for like in data and rule; not in estimator precision for |yhat| well below 0.1 (dnf3, and partly rmaj9 and dlist5).

**25. [confirmed]** Short answer 4 / sec. 4.2: for the 64 characters of degree <= 4 with |yhat| >= 0.25 DFG needs less data for 46, equal 11, more 7, median log2 ratio -2.0; for the 349 smaller ones 147 / 64 / 138, median 0 (234 finite).

- *Evidence:* Recomputed exactly (v_misc2.py). Composition: 255 of the 349 'small' characters are dnf3's, mostly unresolvable on the network side (omission 1). Without dnf3 the small row is 47 / 15 / 32 (94 characters), median 0.

**26. [confirmed]** Sec. 4.2 examples: mux x1x2x3x4 DFG 64 vs networks 2048; majpar pairs 32-64 vs 512-1024; andxor all 3 at 64 vs 512-1024; parmaj's 15 degree <= 4 characters at 128 vs 512-2048.

- *Evidence:* Network n onsets mux x1x2x3x4 2048/2048/2048; majpar pairs 512-1024; andxor 512/512/512 and 1024 x3; parmaj medians 512 and 2048.

**27. [corrected]** Sec. 4.2: rmaj9's 27 cross-block degree-3 characters need 2048-16384 for DFG against 128-4096 for the networks; DFG needs more data for 27 of 39.

- *Evidence:* DFG per seed 2048-16384 (medians 4096-16384), confirmed. Networks per seed 64-4096 with 2 'never' (medians 256-4096 with 1 'never'). 27 of 39 is confirmed. The networks' 'never' character, x2x5x8, scores phi = 0.42 on the test set even for the exact target, so it is an estimator artefact.
- *Correction:* Networks 64-4096 per seed (256-4096 by median), one character never (an estimator artefact).

**28. [confirmed]** Sec. 4.3 sparsepoly: networks 56 / 299 / 532 / 1234-1542; DFG 64 / 128 / 256 / 512 / 1024 / 4096; one inversion x1x2x3 vs x4x5x6 (same |yhat|, degree, n_glob 402); x1x2x3 through the local class in 2 of 3 seeds; x2x3x4x5x6 by the degree-5 subsample (n_glob 508); x1..x6 only through product blocks at 2048-4096, never in seed 2.

- *Evidence:* All reproduced. n_glob 401.5 and 508.3. x1..x6 is carried by |-x5-x6| x (x1-x4+3 x2x3) (s1, 2048) and |x4-x5| x (x1-x6+3 x3x2) (s0, 4096). In seed 2 the product blocks include an irrelevant input and leave phi at 0.48.

**29. [confirmed]** Sec. 4.3 stair5: DFG takes the six 0.375-characters at n = 128 and the -0.125 ones at 512-4096; networks x1 (65) -> four x1 x_j (188-234) -> degree 3 (341-462) -> degrees 4 and 5; 18 inverted pairs, 15 with a -0.125 network-first character before a 0.375 one, 3 pairing two -0.125; n_glob 159 vs 1427, ratio 9; x1x2x3x4x5 by ext1/ext2 in rounds 1-3 at 128 in all seeds.

- *Evidence:* All counts reproduce (15 + 3; ext1 round 2 s0, ext2 round 3 s1, ext2 round 1 s2). Imprecise: the degree-3 onsets span 341-703 and are interleaved with degrees 4-5 (485-768); they are not a stage at 341-462.

**30. [corrected]** Sec. 4.3 stair5: 'That is a construction order, and it is the one place on this target where DFG builds like the networks.'

- *Evidence:* At n = 128 x1x2x3x4 also enters by extension: ext2 in round 1 in s0, ext1 in round 1 in s2. x1 itself enters through the local class in all three seeds, after a higher-degree character was admitted first (x1x2 in s0, x1x3x5 in s1, x1x2x3 in s2), which is the reverse of the networks' order. 'One place' does not hold, and in round order DFG's first character is never the networks' first.
- *Correction:* x1x2x3x4x5 by extension is one of several construction-order entries at n = 128: x1x2x3x4 also enters by extension (2 seeds), and x1 by the local class after higher-degree characters, which is the reverse of the networks' order.

**31. [corrected]** Sec. 4.3 mux: networks linear (60-66) -> x_i x4 (169-176) -> x1x2x3 (430), x1x2x3x4 (452); DFG 64: x1x2x3x4, x2, x3, x2x4 -> 128: x1, x1x4, x3x4, x1x2x3; x1x2x3x4 admitted by the global degree-4 test or carried by a block such as (-x1-x2-x3+x4); the rest via the local class, the same blocks, or (seed 2) the global test in round 1.

- *Evidence:* The stages are confirmed, and so is the s0 block (-x1-x2-x3+x4). At n = 64 in seed 2, x1x2x3x4 is a forced pick of the forced variant (z0 = 0.95 < 1): it did not pass the global test. The route list also omits the linear block, which carries x3 in seeds 1-2 and x1 in seed 2 at their n onsets.
- *Correction:* Add: 'or (seed 2) a forced pick (z = 0.95)'. The linear terms also enter through the linear block in seeds 1-2.

**32. [confirmed]** Sec. 4.3 majpar: networks pairs (189-210) -> x1..x6 (1164); DFG pairs (32-64) -> x1..x6 (256, all seeds) through round-0 weighted blocks or products with one ((x3+x4-x5-x6+3 x1x2) s2, |x3+x4| x (x5+x6+3 x1x2) s0), tested on the residual after the pairs.

- *Evidence:* Cells at n = 256 as described (s1: |x1-x2| x (-x5+x6+3 x3x4)).

**33. [corrected]** Sec. 4.3 majpar: 'Its n_glob is 147, exactly the degree-6 subsample cap (m = 147). That is DFG's version of the degree-6 term comes after the pairs.'

- *Evidence:* The formula gives 146.95, and the 147-row cap is right for fits at n > 512. At n <= 512 the final fit after cross-validation has half the budget, so degree 6 is searched on min(n, 73) rows. The global degree-6 test therefore cannot admit x1..x6 at any n <= 512, and at n = 1024 its expected z is about 1.0. order_analysis.nglob's docstring mentions the halving, but the code does not apply it. Only majpar's x1..x6 is affected (sparsepoly's 508 and stair5's 241 fit under the 687-row degree-5 cap).
- *Correction:* Within the 147-row cap only for n > 512; below that the cap is 73 rows, so the global route opens at n = 1024 (marginally). x1..x6 enters by blocks at 256.

**34. [confirmed]** Sec. 4.3 rmaj9: DFG linear (64) -> within-block degree 3 (256) -> x1..x9 by the full-sum block (512) -> cross-block degree 3 (4096-16384); degrees 5, 7 never (median seed; seed 0 carries 7 degree-7 from 16384); networks 47 -> 796 -> 1081.

- *Evidence:* Stages reproduce (my median-seed n onsets). 'Never' is the for-good rule; see the rmaj9 degree-5/7 correction below.

**35. [corrected]** Sec. 4.3 andxor: DFG ties everything at 64 (median); 'In every seed the product x1x2x3x4 still comes after the pairs': seeds 1 and 2 in round order (local, round 2, n = 32; ext2, round 1, n = 64), seed 0 in n (block at 128 vs pairs at 64).

- *Evidence:* Seeds 1 and 0 are as stated. In seed 2 at n = 64, x3x4 enters in round 0 and x1x2 and x1x2x3x4 together in round 1, so the product comes after only one pair and ties with the other.
- *Correction:* In seed 2 the product comes after x3x4 but in the same round as x1x2.

**36. [corrected]** Sec. 4.3 dlist5: networks' five linear terms first (49-64); DFG x1, x2, x3, x1x2 at 64; x4, x5 at 128-512 (median 512) via the linear block; all 45 inverted pairs have a 0.0625 network-first character (8 linear, 32 pairs, 5 triples); in 33 the DFG-first character is also 0.0625, 'of higher degree and carried by a block'; in 12 a larger one (x1x2, x1x3, x2x3, x1x2x3).

- *Evidence:* All counts are confirmed (8/32/5; 33 vs 12; the four larger characters). Of the 33, 25 are of higher degree and 8 of the same degree (6 pair-pair, 2 triple-triple). All 33 are block-carried at their onsets.
- *Correction:* 'In 33 ... also a 0.0625-character carried by a block, of higher degree in 25 of them.'

**37. [corrected]** Sec. 4.3 parmaj: DFG ties everything at n = 128; x1..x6 carried by folded blocks; 'The pairs and degree-4 terms (all |yhat| = 0.25) come by global tests, at z only 1.17x apart'; networks pairs (168) -> x1..x6 (280) -> degree 4 (543).

- *Evidence:* The tie at 128 is confirmed (first n = 128 for all 16 characters in all seeds; seed 2's x2x4, x2x4x5x6 and x3x4x5x6 are 'for good' only from 1024). The folded blocks are confirmed. The 1.17 ratio is sqrt(15.29/11.15), confirmed as arithmetic. But at n = 128 no test admits any character in any seed: n_new = 0 in every round. Round 0 adds a folded block (|x1+..+x6| or |-x1-x2-x3+x4+x5+x6|) and round 1 a second one (s0 also the linear block). At their n onsets 42 of the 45 pair and degree-4 character-seeds are block-carried; the other 3 are global admissions at 1024 in seed 2. Global tests admit the pairs and degree-4 terms only at larger n (e.g. n = 512, seed 1, sec. 2).
- *Correction:* At DFG's n onset (128) the pairs and degree-4 terms are carried by the two folded blocks, not admitted by tests. Global tests take them at larger n, where their z-scores are 1.17x apart.

**38. [corrected]** Sec. 4.3 dnf3: DFG ranks by size: 0.19-characters (9, 9, 3) at 128-256; 0.027-characters at 512 (degrees 2-3) up to 16384 or never (degrees 4-5); 0.0039-characters at 8192-16384 or never; networks linear (53), then about 500 characters of degree 2-8 from 228 to 1084, x1..x9 at 3598.

- *Evidence:* 0.19-characters at 128-256 is confirmed. The 0.027 degree-2/3 characters span 256-2048 (11 at 256, 49 at 512, 9 at 1024, 11 at 2048, 1 at 16384). 33 of the 343 0.0039-characters enter at 1024-4096 (median seed): 20 degree-6, 6 degree-7, 4 degree-3, 2 degree-5 and 1 degree-8, carried by blocks. Their onsets are earlier than those of many 0.027 degree-4/5 characters (4096-never), which contradicts a pure size ranking. The networks also have 11 degree-5 onsets at 1474-2005.
- *Correction:* 0.0039-characters from 1024 (mostly degrees 6-7, via blocks) to never; 0.027 degree-2/3 at 256-2048.

**39. [confirmed]** Sec. 4.3 rand1 and rand3: rand1 DFG linear (64) -> x3x5, x4x6, x1x4x6 (128) -> 0.125-characters (256-1024); rand3 at n = 128 first the four {x4,x5,x6} characters containing x5 by tests about one per round, then blocks on (-x1+x2+x3) modulated by them; 84 of 96 character-seeds block-carried at onset; 18 characters at 128 and 14 (all containing x6) at 256.

- *Evidence:* Reproduced (e.g. rand3 s1: x4x5, x5, x5x6, x4x5x6 in rounds 0-3, then chi[x5]*(-x1+x2+x3+x4) etc.). The route label is 'block' for any block, so '84 carried by such (modulated) blocks' is really '84 carried by blocks'. Some, e.g. (-x1+x2+x3+x5+x6), are unmodulated.

**40. [confirmed]** Short answer 3 / sec. 5.1: DFG's linear terms strictly first in 6, tied in 12, not first in 6 of 24 target-seed cases (sparsepoly s1-2, rmaj9 s1-2, rand1 s1-2 strict; mux s1-2, dlist5 x3, dnf3 s1 not); the networks first on all 8 targets with linear terms; ln(4KN/delta) 8.5 / 11.2 / 13.4 / 15.3; 1.34x.

- *Evidence:* All reproduced (8.48, 11.15, 13.38, 15.29; sqrt(15.29/8.48) = 1.34). Wording: 'Mux's 0.75 at degree 4 beats 0.25 at degree 1 by 3x' is the coefficient ratio; the z-ratio is 2.24 and the n_glob ratio 271/54 = 5.0.

**41. [confirmed]** Sec. 5.2 bundle table (split / kept): stair5 32/7, rmaj9 1294/790, dlist5 63/60, rand1 16/18, rand3 110/108, dnf3 57018/16862, parmaj 0/51, majpar 0/3, andxor 0/1; parmaj and andxor tie 69 of 69 and 2 of 2 cross-stage pairs.

- *Evidence:* Reproduced exactly; the table leaves out sparsepoly (6 split / 0 kept) and mux (5 / 2) - see omissions.

**42. [confirmed]** Short answer 3 bundles: parmaj's 16 characters all enter at n = 128; stair5's x1x3, x1x4, x1x5 (-0.125) arrive with x1x2 (0.375) in the networks at 188-234 steps, while DFG takes them at n = 512-2048 against 128 for x1x2.

- *Evidence:* parmaj: first n = 128 for all 16 characters in every seed (for good in seeds 0-1; in seed 2 three only from 1024). stair5 network onsets x1x4 188, x1x2 196, x1x5 209, x1x3 234; DFG medians x1x4 512, x1x3 1024, x1x5 2048, x1x2 128.

**43. [confirmed]** Short answer 3 mux: x1x2x3x4 (0.75) is the networks' last character and DFG's first (highest round-0 z in all 30 fits with n >= 64; in the model from n = 64 in all 3 seeds); the networks need n = 2048; n_glob 54 vs 271 for the linear terms.

- *Evidence:* Network online onsets x1x2x3x4 452.0 > x1x2x3 429.5 (per-seed geometric mean 447.5 > 426.3); DFG n onset 64/64/64; network n onset 2048/2048/2048; n_glob 54.4 and 271.2. On DFG's n axis it ties at 64 with x2, x3, x2x4 (median), and in seed 2 it is a forced pick.

**44. [corrected]** Short answer 3 / sec. 5.2: 'DFG has bundles, but they are cut by coefficient size, not by construction.'

- *Evidence:* This is an over-general reading. DFG splits characters of equal coefficient by degree or route. sparsepoly's six 0.25-characters enter at 128 (x2x3, x4x5x6), 256, 512, 1024 and 4096. majpar's 0.5 pairs enter at 32-64 and its 0.5 degree-6 term at 256. rand3's DFG stage at 128 mixes four 0.375- and fourteen 0.125-characters and is separated from the 256 stage by whether a character contains x6, not by size. Size explains the stair5 and dnf3 splits; construction (degree, blocks) explains these.
- *Correction:* DFG's bundles are cut by detectability: mainly coefficient size, but also degree (through the union bound and the degree-5/6 caps) and the block that carries them. So equal-coefficient characters are split (sparsepoly, majpar), and one DFG stage can mix sizes (rand3).

**45. [confirmed]** Short answer 3 / sec. 5.3 degree-size table (44 taus) and: networks' time order follows degree more than size on 7 of 8 targets whose sizes differ ('dnf3 is a tie'; sec. 5.3 'dnf3: 0.25 against 0.27'); their n order on all 8; DFG's n order follows 1/|yhat| more on 5 of 8 (stair5, mux, dlist5, dnf3, rand1).

- *Evidence:* Every tau reproduced exactly (v_orders.py). Wording: dnf3 favours size slightly (0.27 vs 0.25), so it is a near-tie in the other direction, not a tie.

**46. [corrected]** Short answer 3 / sec. 5.3: 'the reverse holds for DFG at degree <= 4'; 'Within degree <= 4, a large coefficient is admitted first whatever its degree.'

- *Evidence:* On the |S| <= 4 subsets, DFG's n order follows 1/|yhat| more than degree on 5 of 8 targets: stair5 0.77 vs 0.27, mux 0.38 vs 0.11, rmaj9 0.75 vs 0.68, dlist5 0.77 vs 0.37 and rand1 0.82 vs 0.46. It follows degree more on 3: sparsepoly 0.89 vs 0.67, dnf3 0.68 vs 0.66 and rand3 0.45 vs 0.31. These columns are in order_degree_size.md but are not quoted.
- *Correction:* A tendency (5 of 8 targets at |S| <= 4), not a rule.

**47. [confirmed]** Short answer 3 / sec. 5.3: above degree 4 characters enter through sum blocks (473 of the 490 character-seeds that ever enter), the local and extension classes (14 = 11 + 3) or the degree-5 subsample (3); majpar's degree-6 term and stair5's x1x2x3x4x5 come after the lower terms they build on.

- *Evidence:* Route counts by degree reproduce (degree >= 5: block 473, local 11, ext 3, global 3, never 428). They partition the character-seeds with no double count.

**48. [corrected]** Sec. 5.3: 'rmaj9: degrees 5 and 7 have no route but blocks, and are never carried.'

- *Evidence:* Every degree-5 and degree-7 character-seed is carried at some n: 72 of the 108 at n = 512 (two seeds), 36 at 2048 and 45 at 4096, by modulated blocks (e.g. chi[x7,x8,x9]*|x1+x2+x3-x4-x5-x6|). Each is then dropped at a larger n. Only under the 'for good' rule are they never carried, with 7 degree-7 exceptions in seed 0. This is the non-monotonicity of sec. 5.4 (159 rmaj9 drops).
- *Correction:* '... carried only by blocks, at n = 512-4096, and dropped at larger n (never for good).'

**49. [confirmed]** Short answer 3 / sec. 5.4: endpoints: networks learned 0.36 / 0.84 / 1.00 and partial 0.30 / 0.16 / 0.00 at n = 512 / 2048 / 16384; DFG 0.80 / 0.88 / 0.92 and 0.07 / 0.06 / 0.04; sparsepoly at 2048 0.78 / 0.66 / 0.18, DFG 6-7 of 7; rmaj9 40-47 of 76 at 16384 with error 0; dnf3 232-497 of 511.

- *Evidence:* Reproduced exactly. My larger probe (M = 1024) gives dnf3 232 / 499 / 240, within 2 characters. Wording: 'learned' (phi >= 1/2) and 'partial' (0.25 <= phi < 0.75) overlap. 18% of the networks' characters at n = 512 are in both, so '36% learned and 30% partially' must not be added up.

**50. [corrected]** Sec. 5.4: 'DFG is all or nothing. A character either passes a test, and its least-squares coefficient is then nearly yhat_S, or it does not.'

- *Evidence:* The small partial share (4-7%) is confirmed. But 1134 of the 1497 character-seeds that DFG carries for good are not explicit features: they are carried only by sum blocks or spectral features, so they never pass a test of their own.
- *Correction:* 'Nearly all or nothing: a character is either fitted (by its own test, or, in most cases, as part of a block) or absent.'

**51. [confirmed]** Sec. 5.4: non-monotone: DFG drops 1139 of 2157 character-seeds (945 dnf3, 159 rmaj9, 35 of 396 on the other 9); networks 223 of 1239 (218 dnf3).

- *Evidence:* Reproduced exactly. The networks' dnf3 drops are largely test-set estimator noise (omission 1). The explanation 'round 0 already gets the signs right with fewer features' fits rmaj9: at n = 512 seed 0, four rounds carry all 76 characters; at 16384 one round carries 47.

**52. [confirmed]** Short answer 5 / sec. 6: n_glob = 2 ln(4K C(30,|S|)/delta)(1 - yhat_0^2)/yhat_S^2 is where a character passes DFG's round-0 global test.

- *Evidence:* dfg13.py accepts S when |mean(r chi_S)| > c s sqrt(2 ln(4 K N/delta)/n), with K = self.K = 4 in every round (the round's K_later only limits the degree), c = 1, delta = 0.1 and N = C(30,|S|). The round-0 residual is r = y - mean(y), since lsfit on the constant gives w = sum(y)/(n + 1e-9), so s^2 = 1 - mean(y)^2 and n_glob follows. Approximations: population yhat replaces the sample estimates, and the test passes 'in expectation' (z0 ~ sqrt(n/n_glob), checked on mux). Degrees 3-4 need n >= 32; degrees 5-6 need the subsample caps (1374/147 rows, 687/73 at n <= 512). n_glob values quoted: mux 54.4 vs 271.2, stair5 158.6 vs 1427.3 (ratio 9.0), sparsepoly 401.5 and 508.3, all confirmed.

**53. [confirmed]** Short answer 5: the networks' order is, by Part 5's own model, set by how many inputs a new feature must coordinate (cost ~ e^2) and only weakly by size (~ rho^{-1/2}).

- *Evidence:* A faithful summary of TRAJECTORIES.md sec. 4 (labelled Heuristic there; e^2 at d = 30, doubled when built on a feature and for odd degree >= 3, rho^{-1/2} under Adam).

**54. [confirmed]** Sec. 6 route table at the DFG n onset (2157 character-seeds): block/spectral 1134, global 154, local 96, linear block 73, ext 29 (18 + 11), forced 11, never 660.

- *Evidence:* Recomputed from the cells' explicit records at each seed's n onset (v_misc.py).

**55. [confirmed]** Short answer 5 / sec. 6: log2(DFG n onset / n_glob), degree <= 4, 1007 character-seeds: median -3.1; global +0.26 (151), local -1.74 (85), ext1 -1.34 (17), ext2 -2.42 (9), linear block -1.68 (73), forced -1.48 (11), sum block -5.33 (661); 'composition classes enter 1.3-2.4 doublings below n_glob'.

- *Evidence:* All medians and counts reproduced. Composition: dnf3 supplies 445 of the 661 block, 38 of the 85 local and 19 of the 151 global character-seeds. Without dnf3: block -2.72 (216), local -0.74 (47), ext1 -0.76 (15), ext2 -2.42 (9), global +0.26 (132), so the composition classes sit 0.7-2.4 doublings below n_glob outside dnf3.

**56. [confirmed]** Sec. 6: tau(n_glob, DFG n onset) 0.40 (dnf3) to 1.00 (majpar) where defined; tau(n_glob, networks' onset) 0.28 (dnf3) to 0.88 (sparsepoly), mux 0.32; orders agree on sparsepoly, majpar, rmaj9 (tau 0.68-0.71).

- *Evidence:* Reproduced with my own n_glob and tau-b.

**57. [corrected]** Sec. 6 step 3: 'So blocks carry characters 5.3 doublings below their individual detectability: rmaj9's x1..x9, parmaj's x1..x6, dnf3's degree-6 to degree-9 terms.'

- *Evidence:* The 5.3 is the median over block-carried characters of degree <= 4 (661 character-seeds, 445 of them dnf3's). The named characters have no finite n_glob: degree >= 7 has no global route, and parmaj's x1..x6 would need 588 rows against a 147-row cap. So the number does not describe them, and outside dnf3 the block median is 2.7 doublings.
- *Correction:* Quote 5.3 (2.7 outside dnf3) for degree <= 4 block-carried characters; the degree 6-9 examples have no global route at all.

**58. [corrected]** Short answer 5 / sec. 6 step 2: composition (falling s, small classes) 'is why local and extension admissions sit 1.3-2.4 doublings below n_glob'; Short answer 5 'Mechanism (Heuristic, quantified by an exact replay of DFG's tests)'.

- *Evidence:* This is a causal reading, labelled Heuristic in sec. 6. It is partly true by construction: a character whose n onset is below its n_glob cannot have passed the round-0 global test in expectation, so it must have entered by another route. Part 10's verifiers asked that mechanism labels be kept descriptive. The replay is exact for the character tests on target characters (verified). The route that carries 1134 of the 2157 character-seeds ('block') is not replayed; it only means 'not an explicit feature'.
- *Correction:* 'quantified by an exact replay of DFG's character tests (block tests not replayed)'; descriptive, not causal, until the nocomp/nosums ablations are in.

**59. [confirmed]** Sec. 7: the fixed-n study recorded |S| <= 4 only (255 of dnf3's 511, 39 of rmaj9's 76); network phi noise sd(f)/64 ~ 0.016 on c_S, i.e. 0.06 on phi for |yhat| = 0.25; mux n = 128 s0 phi_final 0.31 for the x_i x4 terms vs least-squares 0.98; ties 359 of 1648; sparsepoly x4x5x6 at 64 / 1024 / 128.

- *Evidence:* All reproduced. The noise statement is correct for |yhat| = 0.25 but omits the small coefficients (omission 1).

**60. [confirmed]** Figure: coinciding points offset by up to +-0.26 doublings.

- *Evidence:* At most 4 points share a (log10 x to 2 decimals, y) bucket (parmaj DFG at 128), so the largest offset is 0.13*2 = 0.26 doublings.

## Omissions and selective reporting

1. The estimator behind the networks' n axis cannot resolve small coefficients. The networks' phi there is a 4096-point test-set mean of f chi_S. A network equal to the target would score phi between -9.9 and +9.6 on dnf3's |yhat| = 0.0039 characters (45 of 108 below 0.5, 55 above 1.5), between -0.52 and 2.57 on its 0.027-characters (25 of 126 below 0.5), and between 0.42 and 1.54 on rmaj9's 0.0625-characters. rmaj9's only network 'never' on the n axis, x2x5x8, is this artefact (0.42). 19 of dnf3's 0.0039-characters have network n onsets <= 32. Affected: dnf3's like-for-like tau 0.17 (0.56 on its 21 resolvable |yhat| = 0.19 characters), its net-time-vs-net-n tau 0.19 (0.87 on those), the networks' non-monotone count (218 of 223 on dnf3), the dnf3 entries of the degree-size table's 'net n' columns, and the data-cost 'small' row (255 of 349 characters are dnf3's). Sec. 7 gives the noise only for |yhat| = 0.25.
2. The pooled route medians of sec. 6 are dominated by one target. dnf3 supplies 445 of 661 block-carried, 38 of 85 local and 19 of 151 global character-seeds. Outside dnf3 the block median is -2.7 doublings (not -5.3) and the local -0.7 (not -1.7).
3. The sec. 5.2 bundle table lists 9 of the 11 targets. It leaves out sparsepoly (6 split, 0 kept) and mux (5 split, 2 kept), both cases where DFG splits network bundles.
4. The headline 'never negatively' hides per-fit negatives: mux at n = 64, round-order tau -0.48 (seed 2) and -0.05 (seed 1). Mux is the target whose inversion the report emphasises.
5. order_validate.py does not check the stopping round. I checked it; no case is unexplained, but the report's 'none is unexplained' rested on rounds 0..R-1 only.
6. The 'online' rows (priority taus, tau(net time, ...)) use the networks' seed-mean onsets against each DFG seed, while the fixed-n rows are seed-matched. The text says 'network seed s against DFG seed s'. Seed-matched online priority taus are 0.20-0.81, all positive, so nothing changes qualitatively.
7. nglob() ignores the halved small-n budget for degrees 5-6. Its docstring says the cap is halved at n <= 512, but the code does not apply it; this affects majpar's x1..x6 only.
8. The report does not say that in stair5 at n = 128 DFG's first admitted character is never x1, the networks' first. It is x1x2, x1x3x5 or x1x2x3, and x1 follows by the local class, a reverse construction.
9. Not tested by me (plausible): Part 5's own time-axis estimator (32 completions per pattern) has phi noise of roughly 0.2-0.25 on dnf3's 0.0039-characters near their onsets. The online networks' irrelevant-input variance is about 0.015 at step 500, which gives sd(c_S) of about 0.001. The networks' time order for dnf3's smallest characters may therefore also be partly noise.

## Part 10's corrections

- **Mechanism labels are heuristic.** The sec. 7 'Labels' caveat matches Part 10's correction. Two phrases lean causal and are corrected above: 'quantified by an exact replay' and 'it is why ...'.
- **Modulated block statistic.** ORDER.md recomputes no block statistic. Its character replay uses DFG's own residual, deflated by the current features, and I verified it to 5e-7 in 12 refits. The Part 10 error is not reintroduced.
- **Double counts.** The route counts partition the 2157 character-seeds. Above degree 4 they add up as 473 + 11 + 3 + 3 = 490. No double count.

## Scripts (verifier's own, in the session scratchpad)

- `/tmp/claude-0/-home-user-AI-works/addd33f6-5c52-5bee-997e-3f98d4e90609/scratchpad/verify_order/v_net_onsets.py`
- `/tmp/claude-0/-home-user-AI-works/addd33f6-5c52-5bee-997e-3f98d4e90609/scratchpad/verify_order/v_cells.py`
- `/tmp/claude-0/-home-user-AI-works/addd33f6-5c52-5bee-997e-3f98d4e90609/scratchpad/verify_order/v_orders.py`
- `/tmp/claude-0/-home-user-AI-works/addd33f6-5c52-5bee-997e-3f98d4e90609/scratchpad/verify_order/v_misc.py`
- `/tmp/claude-0/-home-user-AI-works/addd33f6-5c52-5bee-997e-3f98d4e90609/scratchpad/verify_order/v_misc2.py`
- `/tmp/claude-0/-home-user-AI-works/addd33f6-5c52-5bee-997e-3f98d4e90609/scratchpad/verify_order/v_misc3.py`
- `/tmp/claude-0/-home-user-AI-works/addd33f6-5c52-5bee-997e-3f98d4e90609/scratchpad/verify_order/v_cells2.py`
- `/tmp/claude-0/-home-user-AI-works/addd33f6-5c52-5bee-997e-3f98d4e90609/scratchpad/verify_order/v_pairs.py`
- `/tmp/claude-0/-home-user-AI-works/addd33f6-5c52-5bee-997e-3f98d4e90609/scratchpad/verify_order/v_z0.py`
- `/tmp/claude-0/-home-user-AI-works/addd33f6-5c52-5bee-997e-3f98d4e90609/scratchpad/verify_order/v_refit.py`
- `/tmp/claude-0/-home-user-AI-works/addd33f6-5c52-5bee-997e-3f98d4e90609/scratchpad/verify_order/v_dnf3_phi.py`
- `/tmp/claude-0/-home-user-AI-works/addd33f6-5c52-5bee-997e-3f98d4e90609/scratchpad/verify_order/write_report.py`
