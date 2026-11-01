# Sound lower bounds by fixed-level splitting on nets trained to output 1

Experiments for `code/rareprob/nets_lower.py` (tests: `code/tests/test_nets_lower.py`):
a lower confidence bound on p = Pr[F(x) < t*] for ReLU MLPs (`code/rareprob/nets.py`)
on uniform {-1,+1}^d, sound for every net of the architecture and every float64
weight. F is the net in exact real arithmetic on its stored weights.

The method: a pilot run of adaptive multilevel splitting fixes levels t_1 > ... > t_K
= t_cert and per-level flip sizes; R independent fixed-plan SMC replicates (N
particles, resampling, Metropolis bit flips accepted iff the point stays below the
level) give Z_i with E Z_i = D(F < t_cert) <= p, whatever the mixing; a betting
e-value turns them into a (1 - delta) lower bound (also anytime-valid, for
sequential stopping); every certified failing input found anywhere gives an exact
witness bound. Floating point: a forward-error bound E* (Higham's model with an
underflow term, computed in exact rationals, refused if anything could overflow)
holds for every admissible float64 evaluation (any summation order, with or
without FMA); a replicate with a non-finite score or a decision within E* of a
level reports Z = 0; witnesses need f < t_cert <= t* - E*.

Costs are given in forward-pass equivalents (fpe: one evaluation of the net on
one input; every SMC evaluation and every Monte Carlo sample is one fpe) and in
wall-clock seconds on a shared 4-core machine (other jobs ran at the same time;
seconds are noisy). Each run is one process.

| script | what it does | output |
|---|---|---|
| `common.py` | paths, the three sets of nets, Monte Carlo timing, yardsticks, parallel runner | |
| `run_suite.py` | the exact suite (d <= 28, `experiments/nets`): 5 runs per net at budgets S (N 300, R 32), M (N 1000, R 32), L (N 3000, R 64) | `results/suite.jsonl` |
| `run_scaling.py` | d = 32...128: this lane's nets (`results/scaling_nets/smc_*`, `smc2_*`) and the suite's d = 64/128 nets; a reference p_ref (100 replicates, N 3000) with plain Monte Carlo where p_ref > 2e-6, then 3 runs per budget | `results/scaling.jsonl` |
| `run_sequential.py` | anytime-valid stopping at target ratios 0.8 / 0.9 | `results/sequential.jsonl` |
| `run_stratified.py` | witness stratification at small d | `results/stratified.jsonl` |
| `run_adversarial.py` | planted hidden failures, random untrained nets, the float64 attacks of the red-team review (underflow, FMA order, overflow) and its coverage campaign on 9 adversarial shapes | `results/adversarial.jsonl` |
| `adversarial_nets.py` | the nets of `run_adversarial.py` and exact-real p by enumeration with rational re-evaluation | |
| `ablation.py` | the variants moved out of the library (block Gibbs, pooled selection, soft levels, self-certifying proposals, clipped-KL and min-Markov rules) and the experiments that compare them with the method | `results/ablation_*.jsonl` |
| `check_nets_lower.py` | forward-error bound against rational arithmetic and three evaluation orders; unbiasedness with no mixing; coverage of the betting bound | `results/checks.txt` |
| `diag_mixing.py` | acceptance per level and distinct final particles | `results/mixing.txt` |
| `diag_failures.py` | structure of the failure sets of two small suite nets | `results/failures.txt` |
| `exact_d32.py` | exact count of the d = 32 net by enumeration (80 CPU minutes) | `results/exact_d32.json` |
| `mc_check.py`, `mc_blocks.py` | plain and near-i.i.d. block Monte Carlo checks of reference values | `results/mc_checks.jsonl`, `results/mc_blocks.jsonl` |
| `train_scaling_nets.py` | how this lane's nets are trained (`results/scaling_nets/index.json` records each net's provenance) | `results/scaling_nets/` |
| `summarize.py` | all tables, with headline numbers computed from the data | `results/summary.txt`, `results/tables.json` |

`results/tables.json` is the machine-readable form of the tables (Table N1: exact
suite; efficiency; Table N2: d >= 32; sequential; stratification; adversarial;
ablation; headlines).

`results/logs/` holds the console logs of the runs; it stays on the working branch.

Fixes from the last code review, each with its counterexample as a regression
test in `code/tests/test_nets_lower.py`: exact counts k / 2^d (witnesses, the
stratum, stratum + betting bound) are rounded down, not to nearest, which
rounded up in the subnormal range (d >= 1075); the end of `betting_lower`
subtracts two ulps when the result is subnormal, where its relative margin is
lost; bet sizes outside [0, 1] are rejected; and witnesses passed to
`lower_bound` are re-evaluated on the net in use (rows that are not cube
points are refused by `Witnesses.add`). None changes a number on a trained
net: `check_nets_lower.py` (147 s) and `run_stratified.py` (22 s), re-run on
the final code, give the same results (wall-clock on a shared 4-core machine).

Order: `run_scaling.py`, `run_suite.py`, `run_sequential.py` (needs the
references), then the others in any order, then `summarize.py`. Every run has a
fixed seed (`common.seed_of`).

## Nets

This lane's own nets were renamed `smc_<loss>_d<d>_w<widths>_s<step>` (and `smc2_`
for a second training run aimed at z in [6.5, 9]) because their former names
(`mse_d64_w64_s1000`, ...) collided with different nets of the suite
(`experiments/nets`). `results/scaling_nets/index.json` maps each new name to its
former name.

## Main results (from `results/summary.txt`; delta = 0.05; costs include the pilot)

* Exact suite (21 nets, d = 24 and 28): 315 runs, no bound above p, no flagged
  replicate. For p >= 1e-5 the mean L/p is 0.860-0.900 at budget M (3.7e5-2.1e6
  fpe) and 0.920-0.942 at budget L (2.2e6-1.4e7 fpe). The four nets with
  p < 1e-5 (1, 2, 89 and 163 failing inputs) reach 0.784-0.924 at budget L, and
  their witness lists are exact (all failing inputs found). Monte Carlo is
  cheaper for p >~ 1e-3.
* Efficiency kappa = relvar(Z) x cost per replicate grows like (1/p)^0.44 over
  the 26 (net, budget) rows with p <= 1e-2, against Monte Carlo's 1/p: the gain
  grows like (1/p)^0.56.
* d = 32 ... 128 (15 nets with p_ref > 0 and reference relative variance <= 1,
  p_ref from 4e-2 down to 5.2e-21): mean L/p_ref at budget L is 0.865-0.973, at
  4.1e6-5.7e7 fpe (19-546 s). This includes the suite's nets: bce_d64_w64_s100
  (p_ref = 2.29e-8, the net with a known witness; 0.919, with up to 2.5e5
  certified witnesses per run), mse_d64_w64_s1000 (0.940), bce_d128_w128x128_s100
  (p_ref = 9.1e-12; 0.928) and bce_d128_w128x128_s300 (p_ref = 5.2e-21; 0.865).
* Far tail: smc2_mse_d64_w64_s2000 (z = 8.40) and bce_d128_w128x128_s1000
  (z = 7.81, p_ref = 2.6e-37 +- 1.6e-37) give betting ratios 0.17 and 0.18 at
  budget L; the witness lists (19 and 55 certified failing inputs) lift the
  reported bound to 0.42 and 0.47 of p_ref. On five nets (z = 6.1 ... 10.0;
  among them the suite's mse_d64_w64_s3000, bce_d64_w64_s300 and
  bce_d64_w64_s1000) no reference replicate reached the last level: every
  bound is 0, which is sound and says nothing about p.
* Wall clock: one SMC evaluation costs a median 0.96 times one batched Monte
  Carlo sample measured in the same process (10-90% range 0.67-1.58 over 114
  (net, budget) cells; up to 3.4 for the sub-second runs at d = 24, where the
  Python overhead of batches of 300 particles dominates), so speedups in
  seconds are close to the speedups in fpe; both are in the tables.
* Soundness campaigns on the final code: the red-team float64 attacks all give
  L = 0 (exact p = 0, or 1/2 for the overflow net); the coverage campaign (9
  adversarial shapes x 5 tiny-budget configurations x 150 runs) has worst miss
  rates 0.127 at delta = 0.2 and 0.287 at delta = 0.5, no witness bound above p,
  and no flagged replicate; random untrained nets miss 0/200 at delta = 0.05 and
  4/200 at delta = 0.3.

## Corrections to the design-round report

The red-team review found these numbers misquoted; the design-round tables and
this rerun (final code, new seeds) give:

* "Across 160-320 replicates per net, the mean of Z/p is 0.93-1.01." The
  design-round table had 0.926 (bce_d28_w32_s100, budget M) to 1.139
  (mse_d24_w32_s2000, budget M, 160 replicates). This rerun: 0.913 +- 0.060
  (bce_d28_w32_s100, M) to 1.029 +- 0.011 (mse_d28_w32x32_s300, M).
* "d = 128, p = 2.9e-15: 0.85 with 7e6" (the net is now smc2_mse_d128_w64_s1000).
  The design-round table gave 0.821 at 6.9e6 (budget M); 0.90 needed 2.2e7 fpe
  in sequential mode. This rerun (p_ref = 2.82e-15): 0.854 [min 0.811] at 6.8e6
  fpe (39 s) at budget M; 0.940 [min 0.932] at 3.9e7 fpe (304 s) at budget L;
  sequential with target 0.9: 0.880 at 1.5e7 fpe (55 s).
* "0.86 at L" for the same net: the design-round table mean was 0.888 (0.862 was
  the minimum); this rerun 0.940 (min 0.932).
* "The cost grows only polylogarithmically in 1/p." What the data show: at a
  fixed budget the cost is N R (1 + 10 (K - 1)) fpe with K ~ log(1/p)/log 5
  levels (K = 3 at p = 4e-2, K = 30 at p = 5e-21), so linear in log(1/p), and
  the ratio at budget L stays 0.865-0.973 on 15 nets with p_ref down to
  5.2e-21. But p_ref is an SMC estimate, checked independently only at d = 32
  (exact enumeration: 97 failing inputs, p = 2.26e-8 against p_ref = 2.21e-8 +-
  0.07e-8) and by Monte Carlo down to p ~ 6e-9 (`mc_blocks.jsonl`); and the
  claim fails in the far tail (z >= 7.8, previous item) and wherever no
  replicate reaches the last level.
* The design round's d >= 32 numbers refer to this lane's nets under their
  former names, which collided with different suite nets (for example
  mse_d64_w64_s1000: z = 4.24 for the lane's net, now smc_mse_d64_w64_s1000,
  and 4.35 for the suite's). The suite's own d = 64/128 nets are reported here
  for the first time.
