# Trained networks, design round: lower

I built a sound lower-bound procedure for p = Pr_{x~U{+1,-1}^d}[F(x) < t*], where F is the MLP evaluated in exact real arithmetic, and tested it on the trained-net suite and on nets of my own. It is in /home/user/AI-works/circuit-output-fraction/code/rareprob/nets_lower.py; the scripts and results are in experiments/nets_lower/. results/summary.txt holds every table. I edited no existing file, ran no git command and did not publish to main.

How the procedure works:
- A pilot run of adaptive multilevel splitting fixes a plan: levels t_1 > ... > t_K = t* - E* (near the 20% quantile of the particles' outputs, placed in gaps between observed outputs) and a bit-flip size for each level.
- R independent replicates then run fixed-level SMC. Each replicate starts N particles from D. At level k it keeps the particles with f < t_k, resamples N of them uniformly, and applies 10 Metropolis steps. A step flips r random coordinates and is accepted if and only if f < t_k still holds. The replicate reports Z = product over levels of (survivors / N).
- A betting e-value bound combines the replicates: L = the largest p0 with (1/11) sum_lambda prod_i (1 - lambda + lambda Z_i/p0) >= 1/delta, over lambda in {0.1, ..., 0.95, 1}. It needs no clipping. There is also an anytime-valid version that keeps adding replicates until the bound is good enough.
- Every certified failing input found anywhere goes into a witness list, which gives the exact bound |S|/2^d with no error probability. The reported bound is the larger of the two.

Soundness holds on every net (argued in the method entries and checked numerically):
- A forward-error bound E* is checked against rational arithmetic.
- Unbiasedness of the SMC estimate was checked on a d=12 net with exact p, including a variant with no mixing at all: |z| < 1.1 over 20,000 replicates for each of 5 kernels.
- On the suite: 300 runs on 20 nets with exact p (including 2 nets with p = 0), and the bound never exceeded p.
- On untrained random nets: 0 of 200 runs exceeded p at delta = 0.05, and 2 of 200 at delta = 0.3.
- On synthetic heavy-tailed laws every miss rate stayed below delta.

How tight it is on the exact-p suite (d = 24 and 28; 1 or 2 hidden layers; squared and logistic loss):
- With about 1-4e6 evaluations (N = 1000, R = 32), L/p is 0.85-0.89 for every net with p >= 1e-5. It is 0.71 at p = 3.3e-7 (89 failing inputs) and 0.62 at p = 6e-8 and 7.5e-9 (1 and 2 failing inputs).
- With about 1-2e7 evaluations, L/p is 0.92-0.94 for p >= 1e-5, and 0.91, 0.80 and 0.84 for those three small-p nets.
- Against Monte Carlo reaching the same ratio, the speedup is below 1 for p >~ 1e-3, about 10 at p = 1e-5, about 100 at p = 3e-7 to 6e-8, and about 1300 at 7.5e-9.
- On the tiny-p small-d nets the witness list is exact: all 1, 2, 89 and 163 failing points were found.

SMC gets better as d grows, because the failure set grows large and stays connected under bit flips:
- d = 64, p = 5.8e-9: L/p = 0.94 with 2.2e7 evaluations, about 1.2e4 times fewer than Monte Carlo. The sequential version reaches 0.92 with 5.4e6.
- d = 64, p = 7.7e-13: 0.91 with 3.3e7.
- d = 128, p = 5.6e-11: 0.87 with 4.8e6 evaluations (about 1e6 times fewer than Monte Carlo).
- d = 128, p = 2.9e-15: 0.85 with 7e6.
- d = 64, logistic loss, 64x64 hidden layers, p = 7.2e-16: 0.92 with 4.1e7.
- For d > 28 the "p" here is a reference estimate: the mean of 100 SMC replicates. I checked it three ways. At d = 32, exact enumeration of all 2^32 inputs gives 97 failing inputs, p = 2.26e-8, against the reference 2.36e-8 +- 0.08e-8. Monte Carlo agrees at p ~ 1e-5 for d = 64 and 128 and for a two-layer net (1e8 samples: 2.91e-5 against 2.94e-5).

A mixing diagnostic explains the difference between small and large d:
- At d = 24-32, the acceptance rate at the last levels falls to 0-5% and the final particles collapse onto 1-33 distinct points. The spread of Z is 10-30 times what ideal mixing would give.
- At d = 64 and 128, acceptance stays above 10% and the final particles hold 200-260 distinct points.
- What matters is the number of failing inputs p*2^d and how they cluster, not p alone.

I confirmed the earlier observations about the failure set on the d=24 nets:
- The mean failing input is about 0.07-0.1 per coordinate.
- The median Hamming distance between failing inputs is d/2.
- The even part of the output falls from about 0.65 to about 0.12-0.14 on failing inputs.
- |sum_j a_j w_j| is about 0.07, against sum_j |a_j| |w_j| of about 5.
- One addition: failures form clusters under single bit flips. For s1500 there are 74 clusters, the largest of 25 points, plus 55 isolated points.

Where it stops working, and what is impossible:
- On nets trained far into the tail (z >= 8.4), SMC breaks down. At d = 64 with p about 1e-18 (about 20 failing inputs), L/p is 0.05-0.3, but the witness list certifies 17 of them (0.81 of the reference). At d = 128 with z = 8.9, the bound is 0 in 8 of 9 runs and even the reference estimate is unreliable.
- On nets with p = 0 the bound is 0, which is correct.
- Two-sided intervals are not possible from this kind of sampler, which only evaluates the net. On a planted net at d = 40 with exact p = 1.6e-8, the unbiased SMC point estimates were 0, 0, 0, 7.5e-9 and 1.2e-7. That is the paper's black-box barrier: no upper bound below about 1/T.
- A deductive upper bound would have to certify a joint small-ball event of many hidden units; see the last method entry.

## Methods

### Fixed-level SMC (multilevel splitting) with a betting (e-value) lower bound: the main method (nets_lower.lower_bound) (lower bound)

**Soundness.** Ideal run (exact real F):
- The levels A_k = {F < t_k} are nested, ending at A_K = {F < t* - E*}.
- Each Metropolis step flips a coordinate set chosen independently of x, so the proposal is symmetric. It is accepted if and only if the new point is in A_k, so detailed balance for D|A_k holds exactly; no floating-point acceptance ratio is involved.
- Del Moral's Feynman-Kac unbiasedness then gives E[Z] = D(A_K) <= p, however badly the chain mixes. With one particle this is the AIS identity.

Floating point:
- forward_error_bound gives E*/2 >= |f_fl - F| for every input and every float64 summation order (Higham's dot-product bound, propagated layer by layer).
- Any decision with |f_fl - t_k| <= E* flags the replicate, which then reports Z = 0. Coupled on the same random numbers, the real run equals the ideal run until the first flag, so Z_reported <= Z_ideal on every run.
- Z = exp(sum log(c_k/N)) is shrunk by a factor (1 - 1e-10).
- The final level t* - E* makes the bound hold both for exact p and for p computed in any float order, including the suite's p_exact.

Adaptivity: the levels, N, step counts and flip sizes come from a pilot whose randomness is independent of the final replicates.

Combining the replicates:
- For each lambda, the product prod_i (1 - lambda + lambda Z_i/p) has expectation <= 1, because the replicates are independent with E Z_i <= p. An average of these over a fixed lambda grid does too.
- By Markov, Pr[E(p) >= 1/delta] <= delta. E(p0) decreases in p0, so the largest rejected p0 is a lower bound with probability >= 1 - delta. The computation keeps a 1e-9 margin for rounding.
- Each product is a nonnegative supermartingale in the number of replicates, so by Ville's inequality replicates may be added until a target is met, and the running maximum stays valid.
- Witness lists add a bound that holds surely, so max(L, witness bound) keeps level delta.

Randomness is treated as ideal, as in the paper; all resampling and coordinate draws use integer draws.

Numerical checks (results/checks.txt):
- The forward-error bound holds against Fraction arithmetic on all inputs of three small nets (including weights from 1e-9 to 1e9) and on suite nets.
- On a d=12 net with exact p, the mean of 20,000 replicates matches p (|z| < 1.1) for 2-step and 0-step Metropolis, 3-bit flips, block Gibbs and pooled selection.
- The betting bound misses at most 0.012 at delta = 0.1 on two-point, lognormal and exponential laws, and the sequential running maximum at most 0.075.
- Suite: 300 runs, 0 misses. Random untrained nets: 0/200 misses at delta = 0.05, 2/200 at delta = 0.3.

**Results.** Budgets: S = N 300, R 32; M = N 1000, R 32; L = N 3000, R 64; delta = 0.05; 5 trials per net and budget. Each entry gives L/p at M and at L, with the evaluations used (pilot included). The speedup is the Monte Carlo samples that a one-sided KL bound needs for the same ratio, at empirical mean exactly p (which favours Monte Carlo), divided by those evaluations.

Exact p, d = 24 and 28:
- mse_d24 s300-s1000 (p = 7e-2 to 3.6e-4): 0.86-0.88 at M; 0.93-0.94 at 2-8e6 evaluations. Monte Carlo is cheaper here (speedup 0.01-0.5).
- mse_d24 s1500 (p = 9.7e-6): 0.85 at 2.4e6; 0.92 at 1.4e7 (speedup 7-17).
- mse_d24 s2000 (p = 6e-8, one failing input): 0.62 at 3.6e6; 0.80 at 1.9e7 (speedup about 100).
- mse_d28_w64 s600 (p = 6e-5): 0.88 / 0.93 (speedup 1.6-3).
- mse_d28_w64 s1000 (p = 3.3e-7): 0.71 at 2.9e6; 0.91 at 1.7e7 (speedup 54-120).
- mse_d28_w32x32 (2 hidden layers, p = 6e-2 to 1.3e-4): 0.88 / 0.93.
- bce_d28_w32 s60 (p = 1.3e-5): 0.87 / 0.94 (speedup 8-12).
- bce_d28_w32 s100 (p = 7.5e-9, two failing inputs): 0.62 at 3.7e6; 0.84 at 2.2e7 (speedup about 1300).
- bce_d28_w64x64 (p = 9.3e-2 to 1.9e-5): 0.87-0.88 / 0.93-0.94.
- The two nets with p = 0: always L = 0.
- Across 160-320 replicates per net, the mean of Z/p is 0.93-1.01, an empirical check of unbiasedness on trained nets.
- Efficiency kappa = (relative variance of Z) x (cost per replicate): 56 at p = 7e-2, 345 at 8e-3, 1e3 at 3.6e-4, 6e3 at 1e-5, 2.6e4 at 3.3e-7, 1.1e5 at 6e-8, 8e4 at 7.5e-9. Monte Carlo's is 1/p. So the gain grows roughly like p^-0.6 at fixed small d.

Reference p (d >= 32): the S/M/L ratio, the evaluations at L, and the speedup.
- d32 (p_ref = 2.36e-8; exact 2.26e-8): 0.66 / 0.70 / 0.86 relative to p_ref, which is 0.69 / 0.73 / 0.90 relative to the exact p; 2.1e7 evaluations; speedup about 500.
- d64 (7.5e-6, Monte Carlo agrees): 0.81 / 0.87 / 0.93.
- d64 (5.8e-9): 0.77 / 0.82 / 0.94 at 2.2e7 (speedup 1.2e4).
- d64 (7.7e-13): 0.58 / 0.84 / 0.91 at 3.3e7 (speedup 3e7).
- d128 (1.9e-5, Monte Carlo agrees): 0.84 / 0.90 / 0.93.
- d128 (5.6e-11): 0.75 / 0.87 / 0.92 at 2.8e7 (speedup about 6e5).
- d128 (2.9e-15): 0.77 at S, 0.82 at M, 0.86 at L (3.9e7 evaluations).
- d64 mse 32x32 (2.9e-5 and 3.3e-8): L budget 0.92 / 0.93.
- d64 bce 64x64 (7.2e-16): 0.55 / 0.83 / 0.92 at 4.1e7.
- Failures: d64 z = 8.4 (p about 1e-18, about 20 failing inputs) gives 0.006 / 0.05 / 0.29; d128 z = 8.9 gives 0 in 8 of 9 runs.

Training time: within a training run, L/p at fixed budget stays at 0.85-0.94 while p falls from 1e-2 to 1e-5, then drops to 0.6-0.8 at p <= 1e-7 for d <= 28. Meanwhile the speedup over Monte Carlo grows from 0.01 to about 1e3.
Loss and depth: squared and logistic loss behave the same at equal p. Logistic tails are much thinner at equal z (z = 4 gives p = 7.5e-9 at d=28). Two hidden layers behave the same as one.

**Verdict.** Works well on trained nets whenever the failure set has many points (p*2^d >~ 1e4), which is the case for every d = 64 and 128 net down to p about 1e-15. It reaches L/p of 0.9-0.94 with 1e7 to 4e7 evaluations, against 1e8 to 2e18 for Monte Carlo, and the cost grows only polylogarithmically in 1/p there.

The weaker regime is small d at tiny p. There the failure set is a handful of isolated points or clusters, the late levels stop mixing, and the variance is 10-30 times ideal. That is exactly the regime where the witness list is exact.

It breaks down on nets trained far into the tail (z >= 8.4). The levels then funnel into a few points that most replicates miss. The bound stays sound but becomes about 0.

It loses to plain Monte Carlo for p >~ 1e-3.

### Witness lists and witness stratification (Witnesses; lower_bound(..., stratify=True)) (lower bound (exact, no error probability))

**Soundness.** A witness is any evaluated input with f_fl(x) < t* - E*. Every such input satisfies F(x) < t* and f < t* in any float evaluation order. So |distinct witnesses| / 2^d <= p always, whatever randomness or adaptivity found them.

With stratification, the pilot's witness set S is fixed before the final batch, and the last SMC level becomes A_K minus S. Then |S|/2^d + D(A_K minus S) <= p, because the two parts are disjoint failure sets.

**Results.** Witness lists are free, as a by-product of SMC exploration. They are exact or nearly so on every small-d tiny-p net:
- d24 s1500: all 163 failing inputs found.
- d24 s2000: 1 of 1. bce_d28 s100: 2 of 2. d28_w64 s1000: 89 of 89.
- d32: 97 of 97, confirmed by exact enumeration of 2^32 inputs.
- d64 with about 20 failing inputs: 17 certified (0.81 of the reference), where the SMC bound reached only 0.29.
- They are useless when p*2^d is large: d64 p = 5.8e-9 gives 1.2e-6 of p; d128 gives 1e-23.

Stratification (4 nets, 3 trials each, same budget) improves the SMC part by 0-10%. For example, d28_w64 s1000 goes from 0.71-0.81 to 0.77-0.86, and s600 from 0.84 to 0.84-0.89.

**Verdict.** Complements SMC exactly where SMC is weakest: few failing inputs. There it gives exact, error-free certificates. Not scalable once p*2^d is large.

### Anytime-valid sequential stopping (lower_bound(..., target_ratio=...), run_sequential.py) (lower bound)

**Soundness.** The lambda-mixture e-value is a nonnegative supermartingale in the number of replicates for every p0. By Ville's inequality, Pr[some running bound > p] <= delta. So the run may stop when the bound reaches the target times the running mean, and report the running maximum.

The clipped and min-Markov alternatives are not anytime-valid, so they are not reported in this mode. The synthetic check gives a running-maximum miss rate of at most 0.075 at delta = 0.1.

**Results.** Target 0.9; achieved L/p and the evaluations used:
- d24 s1500: 0.91 with 3.8e6.
- d28_w64 s1000: 0.90 with 1.0e7 (speedup 337).
- bce_d28 s100: 0.94 with 4.7e7. This is cheaper than enumerating all 2^28 inputs, but the witnesses were exact anyway.
- d64 p = 5.8e-9: 0.92 with 5.4e6 (speedup 3.5e4).
- d64 p = 7.7e-13: 0.94 with 3.3e7.
- d128 p = 5.6e-11: 0.89 with 7.6e6 (speedup 1.1e6).
- d128 p = 2.9e-15: 0.90 with 2.2e7.
- d64 bce 64x64 p = 7.2e-16: 0.96 with 8.5e7.

At d = 24 and tiny p it took 3.5e7 evaluations, more than enumerating all 2^24 inputs.

**Verdict.** Works well. It turns a target ratio into a cost automatically and keeps the guarantee.

### Alternative rules for combining replicates: clipped KL (M = 2 x pilot estimate) and min-Markov (delta^(1/R) min Z_i) (lower bound)

**Soundness.** Clipped KL: E min(Z, M) <= p, and the Hoeffding-KL lower end applies to min(Z, M)/M. M is fixed before the batch.
Min-Markov: Pr[Z_i > p/alpha] <= alpha for each replicate, so Pr[delta^(1/R) min_i Z_i > p] <= delta.
Both are sound alone; they are never combined with the betting bound by taking a maximum.

**Results.** On the same replicates as the main method: clipped KL gives 0.35-0.72 of p and min-Markov 0-0.87, against betting at 0.62-0.94. Min-Markov collapses whenever some replicate is small, which is typical at small p.

**Verdict.** Hopeless compared with betting. Clipping wastes the replicates' concentration, and the minimum is ruined by their lower tail.

### Single-particle AIS with hard levels, and soft (tempered) SMC levels with weights 2^-ceil(theta (F - t*)_+) (run_soft_smc, pilot_soft) (lower bound)

**Soundness.** Hard levels with one particle: the AIS weight is 1 exactly when the chain stays inside each next level. Its mean is p, but it is a 0/1 variable, so it is Monte Carlo in disguise. Resampling is essential.

Soft levels:
- Integer exponents make the incremental weights exact powers of two.
- The Metropolis acceptance 2^-(n(y) - n(x)) is drawn exactly with integer coin flips.
- Resampling is exact by rejection.
- A weight that underflows only lowers the potential, which lowers E Z.
- The ideal energy is matched by flagging any theta (f - t*) within theta E* of an integer. Temperatures are placed mid-step, so these flags are rare.

**Results.** On d28_w64 s1000, kappa = relvar x cost is 3e4 for hard levels, against 1.0e5 to 3.4e5 for the soft variants. The betting bound with R = 40 is 0.83 for hard levels and 0.19-0.61 for soft levels. Soft levels leave mass just above the threshold, so the final hard cut is small and noisy.

**Verdict.** Hard-level SMC dominates on these nets. Soft tempering does not help mixing across clusters.

### Kernel and selection variants: block-Gibbs moves (2^r - 1 evaluations per step) and selection pooled over Metropolis trajectories (lower bound)

**Soundness.** Block Gibbs: a coordinate block is chosen independently of x and resampled uniformly among the assignments that stay inside the level set (exact integer choice), so the conditional law is exact.

Pooled selection: this is SMC with the averaged kernel (1/(m+1)) sum_j M^j, which is also invariant, Rao-Blackwellised over the choice of j. The Feynman-Kac recursion gamma_k(f) = gamma_{k-1}(Kbar(G_k f)) holds, so Z stays unbiased. Checked numerically: |z| < 1.1.

**Results.** On d28 s1000, kappa is 1.7e5 for block Gibbs (r = 3), against 3-4e4 for Metropolis. Pooling gives no consistent gain (relvar 0.52 against 0.22 in one comparison). Adaptive step counts targeting 3 accepted moves per level give relvar 0.13 at 3.5 times the cost: the same kappa. Changing N (300-3000) or rho (0.1-0.5) changes kappa by at most 2 times; rho = 0.05 is 5 times worse.

**Verdict.** No gain over plain Metropolis with flip sizes tuned per level.

### Self-certifying proposals (prop:proposal): autoregressive logistic law, or a mixture of product kernels around witnesses, both fitted to SMC samples (ARLogistic, KernelMixture, proposal_lower) (lower bound)

**Soundness.** Sampler and pmf come from the same dyadic integers k/2^32, so they agree by construction, and sampling is exact.

The weight W = 1[certified] 2^-d/Q(x) is rounded down: a 1e-9 relative margin covers the rounding of log Q. So E W <= p for every net and every proposal.

The proposal is fitted on SMC runs independent of the final batch. The 3e6 weights are split into 32 batch means, which go to the betting bound; heavy tails are allowed.

**Results.** Each entry: L/p, per-sample relative variance, then the SMC result at a similar cost.
- d24 s1000: 0.85; relvar 350; SMC 0.87.
- d28_w64 s600: 0.80; relvar 1.7e3; SMC 0.88.
- d28_w64 s1000: 0.63; relvar 8e3; SMC 0.71.
- bce s60: 0.88; relvar 76; SMC 0.87.
- d64 p = 7.5e-6: 0.88; relvar 2.4e5.
- d64 2-layer: 0.91 and 0.84.
- d128 p = 1.9e-5: 0.73.
- d64 p = 5.8e-9: 0.29; SMC 0.82.
- d128 p = 5.6e-11: 0.44; SMC 0.87.

Kernel mixtures behave like witness lists. They give 0.86 at d24 s1500 (163 failing inputs), but L/p is 1e-17 to 1e-3 at d >= 64. Failing inputs are about d/2 apart, so product kernels cannot cover them.

**Verdict.** Works in a regime: competitive with SMC at d <= 28 and at moderate p in high d. It degrades steadily as p shrinks (per-sample variance 1e4-4e5) and always needs SMC samples to fit. Kernel mixtures are hopeless beyond tiny failure sets. No compact explicit model of D restricted to the failure set (a joint small-ball event of many hidden projections) beats the net-driven SMC.

### Two-sided intervals and upper bounds: the SMC point estimate as an upper bound, and interval-bound branch-and-bound (two-sided (assessment))

**Soundness.** Not sound with black-box SMC.

The SMC replicate mean is unbiased, but its upper tail cannot be controlled on every net. On the planted net at d = 40, exact p = 1.6e-8 consists of 821 'visible' points near a gradient plus a hidden codimension-26 subcube. Five runs gave point estimates 0, 0, 0, 7.5e-9 and 1.2e-7. Any upper confidence bound from these runs would be wrong on such nets.

This is the paper's black-box barrier (thm:blackbox): with T evaluations no upper bound below about 1/T can be certified.

Lower bounds also have a worst-case limit. Deciding p > 0 is NP-hard already for one hidden layer: the net sum_j relu(l_j1 + l_j2 + l_j3 - 2), with literals in {+1,-1} and value -1 meaning true, is < 1/2 exactly on satisfying assignments of a 3-CNF. So no efficient procedure is complete for lower bounds on all nets unless NP is in BPP. On planted subcubes, black-box procedures need about 2^k evaluations (thm:surprise(a)). Our needle nets give L = 0, soundly.

Certified upper bounds need a deductive argument. Complete arguments for all nets would put coNP inside MA.

**Results.** Exact enumeration is the only two-sided method here, and it is feasible only for d <~ 32-34: about 80 minutes of CPU for d = 32 on this shared machine, which confirmed the SMC reference.

A quick interval-bound branch-and-bound (prune subcubes where the lower bound on f is >= t*) recovered the exact count of 163 at d = 24, but it left 2.7e6 of 1.7e7 leaves unpruned. At d = 28 it exhausted memory. Interval bounds cannot see the small-ball structure.

At d >= 64 a subcube envelope would need roughly one cell per scattered failing input (1e11 or more of them), so it is hopeless. A certificate would have to bound a joint small-ball probability for many hidden units with dense weights. Littlewood-Offord-type bounds lose constant factors per unit, so they would be loose by exponential factors.

**Verdict.** Impossible black-box. Two-sided intervals are feasible only by enumeration at d <~ 32. For d >= 64 a sound two-sided procedure looks hopeless with known certificates.

What this work provides there is a sound lower bound plus an uncertified point estimate, which is empirically accurate on trained nets: replicate means within 1-3% of exact p or Monte Carlo wherever these could be checked.

## Adversarial soundness check

**Verdict.** The statistical core is sound. That covers fixed-plan SMC unbiasedness, the betting e-value bound, Ville sequential stopping, min-Markov, clipped KL with M fixed by the pilot, witness lists and stratification. It survived everything I tried: 13,500 low-budget runs on 9 adversarial nets with no coverage violation, and no detectable bias in Z for any of the 7 kernel variants.

The floating-point layer is NOT sound for every net. forward_error_bound uses Higham's model, which has no underflow term. Its own computation also rounds to nearest and can itself underflow. As a result:
- Nets whose hidden products are subnormal and are then amplified by large downstream weights make |f_fl - F| exceed E*/2 by up to about 1e15.
- lower_bound then certifies positive bounds (0.97, 0.78, 9.3e-9, 1.5e-15) on nets whose exact-real p is 0.
- An FMA-versus-plain evaluation of a subnormal tie breaks the "any float order" claim: a certified witness is not a failure under FMA evaluation.

None of this affects any reported number: trained weights are nowhere near the subnormal range. A corrected bound fixes all three counterexamples. It adds an absolute (2n+2)·2^-1075 per dot product and is computed in exact rationals.

Other findings:
- Efficiency numbers reproduce with fresh seeds on 8 suite nets.
- The d=64 SMC reference values are confirmed by independent near-i.i.d. Monte Carlo on two nets.
- One completeness defect: any output exactly at the threshold flags every replicate, giving L = 0 even at p = 0.25.
- A few headline numbers are misquoted.

All scripts and outputs are in /tmp/claude-0/-home-user-AI-works/02f29707-9759-5ff3-9757-46e1f8b0fdfe/scratchpad/break/.

- [soundness broken] attack_underflow.py and attack_underflow2.py: hand-built 2-hidden-layer nets.MLP nets with float64 weights; exact F computed in Fraction arithmetic; then lower_bound and exact_failure_count were run on them.

Net A (squared loss, threshold 0.5): h1 = 2^-537; h2_j = relu(2^-538 h1), whose exact value 2^-1075 rounds to 0 by ties-to-even; output weights about 2^1024 over 8 units; output bias 0.5 - 3·2^-50.

Net B (logistic loss, threshold 0): the term 2^1000·(2^-540·2^-540) is dropped in float. A linear 'ball' unit is scaled by 2^-83, so float fails iff Hamming distance to u is at most 3, while exact F >= 2^-83 > 0 everywhere.: Gradual underflow against forward_error_bound. Higham's bound has no underflow term, and the bound computation itself rounds to nearest and underflows. Breaks the claim E*/2 >= |f_fl - F| for every input, which underlies witnesses, SMC flagging and t_cert, i.e. soundness w.r.t. p = Pr[F(x) < t*]. Result: The bound is violated.
- Net A: max |f_fl - F| = 3.55e-15 against E*/2 = 5e-16. f_fl = 0.5 - 2.7e-15 < t_cert, but F = 0.5 + 8.9e-16, so it is not a failure. Exact-real p = 0; numpy-float p = 1.
- Net A, lower_bound: d=10 gives lower = 0.975 (witness list). d=40 gives lower = smc = 0.778, clipped 0.44, min-Markov 0.83, all with exact p = 0.
- Net B: |f_fl - F| = 8.3e-25 against E*/2 = 8.8e-40.
- Visible-ball net, d=40 (2 trials): lower = 9.35e-9 both times; SMC betting bound 7.5e-9 and 8.1e-9.
- Visible-ball net, d=64: lower = 1.5e-15 and 1.75e-15 (SMC part).
- Exact-real p = 0 throughout.

The colleague's own error-bound check used weights only from 1e-9 to 1e9, which cannot reach the subnormal range. Trained nets are not affected.

Fix (fixed_bound.py): add (2n+2)·2^-1075 absolute error per dot product and compute the bound in exact rationals. The fixed E then covers all three counterexamples (e.g. 1.47e-14 >= 3.55e-15 on net A).
- [soundness broken] attack_fma.py. A net in which w·h = 2^-1075 is a tie and the bias is 2^-1074:
- numpy (product rounded, then bias added) gives 2^-1074;
- the valid FMA order acc = fma(w, h, acc) (math.fma) gives 2^-1073;
- the exact value is 1.5·2^-1074.
This is amplified by 2^1023 over 16 units, with output bias 0.5 - 24·2^-51.: The claim that 'the final level t* - E* makes the bound hold for p computed in any float order (with or without FMA), including the suite's p_exact'. In code terms: f_fl < t_cert should imply f'_fl < t* for every float64 evaluation f'. Result: - numpy: f = 0.5 - 3.55e-15 < t_cert = 0.5 - 1.89e-15, so the input is certified as a witness.
- FMA evaluation: f = 0.5 + 3.55e-15, so it is not a failure.
- Exact: F = 0.5, so it is not a failure.
- |f_np - f_fma| = 7.1e-15 against the claimed bound E* = 1.9e-15.
- lower_bound reports 0.963, while exact p and FMA-order p are both 0 (numpy-order p = 1).

The corrected bound (previous entry) gives E = 3.0e-14 and covers this case too.
- [holds] unbiased.py and rerun_unb.py. Nine adversarial nets (advnets.py), exact D(A_K) by enumeration (d = 12-16):
- decoy funnel with a non-failing basin at 0.535;
- single needle with flat output;
- first-layer weights scaled by e^±12, second by e^±6;
- depth-2 random net;
- 24 of 32 units dead;
- integer weights with many ties;
- p = 1;
- p = 0 with a 1e-12 margin;
- outputs exactly at the logistic threshold.
For each net: pilot plan, then 3000 fixed-plan replicates (N = 30) for each of 7 variants. The variants are tuned-flip MH, 0-step MH, 1-step 3-flip MH, block Gibbs r = 2, pooled selection, last-level exclusion of half the failures (stratification), and soft dyadic levels. 20,000 replicates were used for borderline cells.: Feynman-Kac unbiasedness 'however badly the chain mixes', for every kernel variant, on nets built to make Z heavy-tailed or degenerate. Also a look for an implementation bug (resampling, exclusion codes, pooled normalisation, soft-level dyadic weights, int64 overflow in _n_level). Result: No bias detected.
- All 49 informative cells had |z| <= 2.4 at 3000 replicates.
- The four borderline cells rerun at 20,000 replicates gave ratios 1.003, 1.005, 0.991 and 1.024, all with |z| < 1.
- p = 1 gives Z = 1 - 1e-10, as designed.
- Reviewing the soft levels: the int64 overflow in _n_level when θ(s - t*) >= 2^63 corrupts the weights. It cannot be exploited, because any r >= 2^53 is integral in float and is therefore flagged (Z = 0), and r = inf requires |f| >~ 1e296, which makes E* astronomically large.
- [holds] coverage.py. 9 adversarial nets × 5 configurations × δ in {0.2, 0.5} × 150 independent lower_bound runs = 13,500 runs, with tiny budgets to maximise misses. The configurations were R=4/N=50; R=2/N=30; R=8/N=100 with stratify=True; R=8/N=50 with block Gibbs; and sequential target_ratio=0.9 with min_R=2, R <= 64. In every run, lower, the SMC part, clipped KL, min-Markov and the witness bound were each compared with exact p.: Whether each reported bound exceeds p in at most a δ fraction of runs on any net. This exercises pilot adaptivity, the betting grid, the anytime running maximum, the stratum add-back, clip levels and witness counting. Result: Every miss rate was at most δ.
- Worst cells: sequential mode at δ = 0.5 with miss rates 0.29, 0.26, 0.26 and 0.24; at δ = 0.2, at most 0.093.
- Fixed-R betting: at most 0.12 at δ = 0.5 and at most 0.053 at δ = 0.2.
- Clipped KL: at most 0.013. Min-Markov: at most 0.027.
- Witness bound: never above p.
- The p = 0 net (1e-12 margin): always 0. The p = 1 net: never above 1.

I also recounted the colleague's own files: 0/300 suite misses, and 0/200 (δ = 0.05) and 2/200 (δ = 0.3) on random nets.
- [holds] Line-by-line review of nets_lower.py: betting_lower, clipped_kl_lower, min_markov_lower, lower_bound, run_smc, metropolis, block_gibbs, pilot_plan, _split_level, Witnesses, proposal_weights and the samplers, plus stats.kl_interval.: Adaptivity and clip levels, the monotonicity used for inversion, Ville's inequality, the stratification algebra, levels strictly decreasing (nestedness), kernel invariance, numerical margins, and the exactness of the proposal pmf and sampler. Result: All correct apart from the floating-point bound covered above.
- The plan, flips, step counts and M = 2·(pilot Z - base) use only pilot randomness. The final replicates are i.i.d. given the plan.
- E(p0) is a fixed-weight mixture of products of nonnegative factors that decrease in p0. The bisection always returns a rejected point, and clipping at 700 is conservative.
- Ville applies, because each λ-product is a nonnegative supermartingale under independence.
- Levels are strictly decreasing, so the level sets are nested.
- The MH proposal (a uniform r-subset, independent of x) is symmetric, with hard accept/reject. Block Gibbs is a heat bath. The pooled population is conditionally unbiased.
- The stratum S is frozen before the batch and is disjoint from A_K minus S.
- The proposal integers k/2^32 are the same in the sampler and in the pmf, and the margins exceed rounding error.
- Remaining gap: unbiasedness only gives E Z <= D({F < t_cert}), so everything also inherits the forward-error flaw.
- [holds] advnets.threshold_ties_bce: logistic threshold 0, f = relu(x1) + relu(x2) - 1, so f = 0 exactly on half the cube and p = 0.25. Run through unbiased.py and coverage.py.: Completeness on outputs that tie exactly at the threshold. Evaluator.ambiguous flags |s - t| <= E*, and t_cert = t* - E*, so s = t* is always at distance exactly E* and gets flagged, even though such an input is unambiguously not a failure. Result: Every replicate was flagged (3000 of 3000), and the bound was L = 0 in all runs at every budget, although p = 0.25 and plain Monte Carlo would succeed trivially.

This is sound but a silent completeness failure for nets with exact ties, for example dead-ReLU regions with output bias equal to the threshold. Flagging only when |s - t| <= E*/2 at the final level, or using a strict inequality, would be enough to fix it. Trained suite nets are not affected (0 flags).
- [holds] reproduce.py. Fresh seeds (not the colleague's) on 8 suite nets with exact p: 5 runs at budget M (N=1000, R=32) and 3 at budget L (N=3000, R=64), δ = 0.05. Speedup was computed both with their one-sided KL Monte Carlo yardstick and with the task's 3 ln(2/δ)/(ε²p), taking ε = 1 - ratio.: Whether the suite efficiency numbers (L/p, cost and speedup over Monte Carlo) reproduce. Result: They reproduce within run-to-run noise; mean r_bet, mine against theirs:
- mse_d24_w32_s1500: M 0.838 vs 0.854; L 0.931 vs 0.923.
- mse_d24_w32_s2000: M 0.706 vs 0.616; L 0.807 vs 0.797, about 120x the KL Monte Carlo cost.
- mse_d28_w64_s1000: M 0.750 vs 0.713; L 0.861 vs 0.906.
- bce_d28_w32_s100: M 0.651 vs 0.616; L 0.852 vs 0.837, at 2.2e7 evaluations; speedup 1.06e3 (KL) and 2.2e3 (task yardstick).
- bce_d28_w32_s60: M 0.861 vs 0.865.
- mse_d28_w64_s600 and mse_d28_w32x32_s500: within 0.02.
- 0 misses in 64 runs.

Context: on the tiny-p d <= 28 nets the witness list already makes the reported bound exact (r_wit = 1.000). Exhaustive enumeration (2.7e8 evaluations at d = 28) is only about 12x the SMC cost, so Monte Carlo is a weak baseline there.
- [holds] mc_iid.py. An independent unbiased Monte Carlo: i.i.d. uniform 54-bit prefixes, each with all 2^10 suffixes enumerated through a first-layer table; float32 screening, with every output within 1e-3 of the threshold rechecked in float64 by net.forward; per-prefix standard errors. Validated against exact p on mse_d28_w32x32_s500 (z = -0.09) and mse_d24_w32_s1000 (|z| <= 1.3). I also recomputed the SMC reference with fresh seeds (smc_ref.py).: The d >= 32 ratios and speedups are measured against p_ref, the mean of 100 replicates from the same SMC. A shared bias (an unvisited failure mode, or an implementation bug) would inflate L/p and the speedups of 1e3 to 1e6. Result: The references are confirmed on both nets checked.
- mse_d64_w64_s1500: Monte Carlo 6.27e-9 ± 1.24e-9 (1.5e10 samples, 94 hits) against p_ref 5.82e-9 ± 0.11e-9.
- mse_d64_w32x32_s600: Monte Carlo 2.57e-8 ± 0.40e-8 on 6e9 samples, then 3.20e-8 ± 0.30e-8 on 2.4e10 samples (767 hits). Pooled about 3.07e-8 ± 0.25e-8, against p_ref 3.29e-8 and my SMC recomputations of 3.40e-8 (10 moves) and 3.55e-8 (30 moves).
- A first design with 22-bit suffix blocks gave 9.7e-9, with all hits in 10 prefixes. That is the skew of a clustered design, not a bias: failures cluster strongly, with a maximum of 33 per 1024-input block.
- The d = 128 and p <~ 1e-12 references remain unverifiable independently.
- [claim overstated] Cross-checked the report text against results/summary.txt and suite.jsonl.: Accuracy of the quoted headline numbers. Result: Minor misquotes:
- 'Mean of Z/p is 0.93-1.01 across replicates': the table has 1.139 for mse_d24_w32_s2000 at budget M (160 replicates) and 0.926 for bce_d28_w32_s100.
- 'd = 128, p = 2.9e-15: 0.85 with 7e6': the table gives 0.821 at 6.9e6. The 0.90 figure needs 2.2e7 evaluations in sequential mode.
- The method entry says '0.86 at L' for the same net, while the table mean is 0.888 (0.862 is the minimum).
- 'Cost grows only polylogarithmically in 1/p' rests on 3 nets per d, measured against self-referential p_ref values (two confirmed above), and it fails at z >= 8.4 (acknowledged).

The rest of the quoted suite and scaling numbers match the tables.
- [holds] Compared the report's impossibility statement with the paper's barriers (sec-limits) and with the colleague's planted d = 40 example.: The claim that two-sided intervals are impossible from an evaluation-only sampler. Result: Correctly scoped. It is the black-box barrier (no upper bound below about 1/T from evaluations), illustrated by unbiased point estimates of 0, 0, 0, 7.5e-9 and 1.2e-7 against p = 1.6e-8 on the planted net. It does not claim that white-box upper bounds are impossible on trained nets; the coNP-versus-MA barrier is worst-case only.
