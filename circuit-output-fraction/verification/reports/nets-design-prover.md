# Trained networks, design round: prover

I built a prover and verifier for a "certified partition" argument (code/rareprob/nets_prover.py; experiments, results and report in experiments/nets_prover/). The argument is a binary decision tree over input coordinates, so its leaves are subcubes. Each leaf is one of four kinds:
- SAFE(cert): the certificate shows f >= t on the whole subcube.
- FAIL(cert): the certificate shows f < t on the whole subcube.
- ENUM: the verifier enumerates the subcube by meet in the middle, with exact tie handling.
- OPEN: the subcube joins a union of subcubes with exact mass and an exact sampler, which the verifier samples; this is the paper's envelope estimator.

There are two certificate kinds:
- 'lin': linear bound propagation (CROWN-style) with slopes chosen by the prover. For one hidden layer, the best slopes give the LP relaxation over the subcube's box.
- 'quad': a degree-2 Shor / S-lemma certificate. It uses x_i^2 = 1, so it is not limited by the box relaxation, and the verifier checks it with one Cholesky factorisation using Higham's backward-error bound.

The verifier outputs p in [(F + Z l)/2^d, (F + Z u)/2^d]. With no open leaf this is exactly p, deterministically. It is sound for every net and every argument:
- A malformed tree gives [0,1]; a leaf whose certificate fails is demoted to sampling.
- All bounds carry rigorous floating-point error terms.
- Points within 2^-30 |f|_abs of t are re-evaluated in rational arithmetic.
- Its work is polynomial in the size of the argument.

Soundness tests on 24 nets checked against exact rational counts (random weights at scales 1e-6 to 1e6, exact ties, a point at f = t - 2^-60, trained nets):
- 15,084 bound checks: 0 bounds above the exact minimum.
- 120 exact certificates (72 of them on subcubes): 0 counts differing from the exact one.
- 528 dishonest or malformed arguments: 0 intervals missing p.
- 600 sampled runs at delta = 0.1: 7 misses.

Main findings:

(1) d <= 28, one hidden layer. The exact certificates reproduce every suite failure count.
- Squared loss, d = 24: verifier cost 1.1e5 to 1.1e6 forward-pass equivalents (fpe). That is 1.2 to 13 times cheaper than the verifier enumerating the whole cube.
- Against Monte Carlo the certificate is 9x cheaper at p = 3.6e-4, 640x at p = 9.7e-6 and 1.8e5x at p = 6e-8. It loses for p >= 8e-3.
- Logistic loss, d = 28: bce_d28_w32_s100 (p = 7.45e-9, two failing points) is certified exactly with 21,593 nodes and 1.6e4 fpe, against 1.5e11 for Monte Carlo and 1.85e7 for enumeration. bce_d28_w32_s150 is proved to have p = 0 with 2,305 nodes and 2.0e3 fpe.
- Two hidden layers: no certificate is cheaper than enumeration, because the intermediate bounds are loose; Monte Carlo wins there except at p = 0.

(2) Why squared-loss nets resist. Training kills the linear part: the level-1 Fourier weight is 0.3 to 1.8% of Var f (37 to 62% for the logistic nets). So failures are small-ball events of the even part.
- f(0) < t on all nine one-hidden-layer squared-loss nets with d <= 28 and on two of the d = 64 ones. So no relaxation over the box (LP, CROWN, MILP over the box) can certify the root of those nets.
- Below the root, the gap between the true minimum and the certified bound grows like r^1.5 to r^1.9 with the number r of free inputs, while the margin min f - t shrinks.
- Certified leaves therefore have only 6 or 7 free inputs at d = 24 and about 10 at d = 64.
- 'quad' removes 35-40% of the gap and makes trees 1.1 to 4.1 times smaller, but raises verifier cost 1.1 to 6.6 times.
- A SAFE leaf must have every point of its subcube at least G(r) above t, where G(r) is the measured median gap at r free inputs, so the certificate pays for every point within that distance of t, not only for the failing ones.

(3) Scaling with d (nets trained here). Certificate cost grows like 2^(0.6 to 0.9 d) at a fixed training recipe, while Monte Carlo's 1100/p does not grow with d. Rule of thumb from these runs: certificates beat sampling only when p is below about 2^(-0.75 d) * 1e3.

(4) d = 64 and d = 128. I built and verified real certificates of random pieces of the cube (each piece reached by following the prover's own splits).
- bce_d64_w64_s1000: four pieces, each 1/256 of the cube, certified exactly with no failing point, about 2e5 nodes each. A whole-cube proof is estimated at about 5e7 nodes, roughly the work of 4e7 Monte Carlo samples, which could only show p <= 1e-7.
- Whole-certificate estimates for the other nets: about 1e10 fpe (bce s300), 1.8e12 to 1.5e13 (bce s100), 2.6e13 to 5e13 (mse s3000), 1e16 (mse s1000), 2e17 (mse s300), and 1e35 to 1e36 for the d = 128 two-layer nets.
- With a budget of 2e5 nodes nothing at d = 64 is certified, so the interval is just Monte Carlo's.

Answer to the question. Short certificates plausibly exist exactly when the margin min f - t exceeds the deductive gap at large subcube dimension. In this suite those are the logistic nets trained well past p = 0. For squared-loss nets with p > 0, and for two-hidden-layer nets, the certificates are exponential in d. At d = 64 with p > 0, Monte Carlo is the only practical sound two-sided method. This is consistent with the paper's coNP-in-MA barrier: a one-hidden-layer ReLU net encodes any 3-CNF, one unit per clause, so no system can be complete on all nets of this architecture.

## Methods

### Certified partition with 'lin' leaf certificates + ENUM leaves (exact certificate) (exact (two-sided, deterministic when no OPEN leaf))

**Soundness.** The verifier parses the decision tree itself: a split must be on a free coordinate and must have both children, so the leaves partition the cube or the given subcube; leaf sizes are summed in Python integers, and a malformed tree gives [0,1]. Each SAFE/FAIL 'lin' leaf is rechecked from the net. The verifier recomputes the intervals and chord slopes itself (chord slopes are inflated by 2^-26 and re-checked, replaced by 1 if the check fails); the prover's slopes are clipped to [0,1], where every value is valid. The bound is a straight-line program carried together with an absolute-value shadow computation, and the verifier subtracts 2^-30 of the shadow; this covers rounding in any evaluation order for chains under 2^20 operations (Higham). Units whose backward coefficient has uncertain sign are dropped and charged. ENUM leaves are counted by meet in the middle; points within tau = 2^-30(|f|_abs + 1) of t are re-evaluated in exact rational arithmetic, so the counts are exact for the exact-arithmetic net. A leaf whose certificate fails is demoted to OPEN (sampled), so a bad certificate costs time but never validity. None of this uses training. Tests: 15,084 bound checks, 120 exact certificates and 528 tampered arguments, with 0 failures.

**Results.** Exact counts equal the suite's fail_count on all 9 nets run.
- Squared loss, d = 24, s300 to s2000 (p from 7.1e-2 down to 6e-8): verifier cost 1.1e6, 7.5e5, 3.5e5, 1.8e5, 1.1e5 fpe. Monte Carlo needs 1.6e4, 1.3e5, 3.1e6, 1.1e8, 1.9e10, so the certificate wins by 9x, 640x and 1.8e5x for p <= 3.6e-4. Enumerating the cube costs 1.35e6 (1.2 to 13 times more).
- Logistic loss, d = 28: s60 (p = 1.3e-5): 1.7e5 fpe vs Monte Carlo 8.4e7. s100 (p = 7.45e-9): 1.6e4 fpe and 21,593 nodes vs Monte Carlo 1.5e11 and enumeration 1.85e7. s150 (p = 0): 2.0e3 fpe and 2,305 nodes, where Monte Carlo cannot certify 0. s30 (p = 1.9e-3): 3.2e6 vs Monte Carlo 5.9e5.
- Squared loss, d = 28, width 64 (Knuth estimates only): 4.6e6 fpe at p = 3.3e-7, 2.7e6 at p = 0, vs enumeration 1.85e7.
- Two hidden layers: the certificate costs at least as much as enumeration (1.5e8 to 1.9e8 fpe).
- Arguments are 0.29 to 50 MB, mostly slopes; each verification took at most 36 s.

**Verdict.** Works well for one-hidden-layer nets whose margin exceeds the relaxation gap at large subcube dimension (logistic loss trained to large logits): exact p, or a proof that p = 0, for orders of magnitude less than Monte Carlo or enumeration. For squared-loss nets it works only in a regime: cheaper than Monte Carlo when p is below about 1e-3 at d = 24-28, but only 1.2 to 13 times cheaper than enumeration, and the cost grows like 2^(0.6 to 0.9 d). Hopeless for two hidden layers (loose intermediate bounds) and for p > 0 nets at d = 64 (estimated 1e13 to 1e17 fpe).

### 'quad' leaf certificate (degree-2 Shor / S-lemma, PSD check by Cholesky) (deductive bound on a subcube (component of the exact or upper-bound certificate))

**Soundness.** The verifier builds a valid quadratic minorant (or majorant) of relu for each first-layer unit on its padded interval, from the prover's theta clipped to [0,1]^2. The constant is moved by a margin, and the conditions q(L), q(0), q(U) and the slopes are checked rigorously; if they fail, a fallback relaxation (0 from below, z - L + margin from above) is used. This gives f >= Y^T M Y on the subcube, with an entrywise rounding bound on M. The verifier then runs its own textbook Cholesky factorisation on fl(M - diag(mu) - s I - c I), with c = 3(gamma_{2n+4} tr/(1 - gamma) + ||E||_F). By Higham Thm 10.3, lambda_min(A_f) >= -gamma tr(A_f)/(1 - gamma), so the exact matrix M - diag(mu) - s I is PSD; then x_i^2 = 1 gives f >= sum(mu) + (r+1)s. Tested with random parameters and with the prover's shift increased by 1e-12 to 1e-3: never a certified bound above the exact minimum.

**Results.** It removes 35-40% of the LP gap at every subcube dimension r. Example: mse_d24_w32_s1500 at r = 8, gap 0.68 becomes 0.43; mse_d64_w64_s1000 at r = 10, 25% of subcubes certified becomes 75%. In Knuth estimates over the 17 one-hidden-layer suite nets, trees are 1.1 to 4.1 times smaller, but verifier cost is 1.1 to 6.6 times higher, because one quad check costs 10-30 lin checks. It does not help with two hidden layers.

**Verdict.** Works in a regime: it gives the smallest arguments but not the cheapest verification. Degree-2 reasoning on |z| loses a factor of about sqrt(r) on exactly the small-ball term, so it does not change the exponential scaling for squared-loss nets.

### Hybrid argument: certified partition plus OPEN leaves sampled by the envelope estimator (two-sided (statistical, level delta))

**Soundness.** The OPEN union is an envelope with exactly computable mass Z (sum of 2^r over open leaves) and an exact uniform sampler: an exact uniform integer below Z, then the leaf containing it, then the bits of its offset. The failure indicator is evaluated exactly (rational re-evaluation near t). The Hoeffding-KL interval at level delta is the only randomness, so Pr[p not in output] <= delta for every net and every argument. The deterministic part F is exact. Coverage test: 7 misses in 600 runs at delta = 0.1.

**Results.** The sample count is sized for ratio 1.1, including the no-hit term 3 ln(2/delta) Z / (eps F). On the suite every interval contained exact p, with ratios 1.08-1.10. Costs: mse_d24_w32_s300 5.0e4 fpe (exact certificate 1.1e6, Monte Carlo 1.6e4); s600 4.3e5 (exact 7.5e5, Monte Carlo 1.3e5); bce_d28_w32_s30 1.9e6 (exact 3.2e6, Monte Carlo 5.9e5). With few failures the prover leaves nothing open and the argument equals the exact certificate. At d = 64, with 2e5 nodes, the certified mass is 0, so the open part is the whole cube and the interval is Monte Carlo's (e.g. [1.8e-6, 5.2e-5] for mse_d64_w64_s1000 from 2e5 samples).

**Verdict.** Hopeless as a speed-up on these nets. Sampling an open leaf costs a full evaluation while enumerating it costs about 2/d of one, so the hybrid only pays when failures are many, and then plain Monte Carlo is cheaper still. A partial certificate certifies no mass until the tree reaches the depth of its leaves (22 to 57 at d = 64).

### Witness lists (lower bounds) (lower bound)

**Soundness.** The verifier keeps distinct {+-1} points of the list, evaluates them with exact tie handling, and returns (number of failing points)/2^d rounded down. This is a special case of the paper's self-certifying proposals, and needs no deduction. 24 tests with duplicates, non-failing and malformed points mixed in gave 0 errors.

**Results.** The exact lower bound costs one evaluation per listed point. For example, the 163 failing points of mse_d24_w32_s1500 give p >= 9.7e-6 for 163 fpe, while Monte Carlo needs about 1e8 samples for a 10% lower bound.

**Verdict.** Works whenever the prover can find the failing points and they are not too many; it gives no upper bound.

### Knuth / partial-backtracking estimates of certificate size (prover-side analysis) (heuristic (estimates the cost of a certificate; not an interval for p))

**Soundness.** Not a bound on p. It is an unbiased estimate (Knuth 1975) of the node count and verifier cost of the prover's uncollapsed tree, from random root-to-leaf probes that follow the prover's own rule. The d = 64 piece runs are real certificates: each piece was verified exactly with verify(root=...), and the whole-cube cost is extrapolated as 2^k times the piece cost.

**Results.** Within 5% of the two real uncollapsed suite trees built for this check; Knuth / real ratio between 0.72 and 1.43 over the collapsed certificates of 48 trained nets.
- d = 64 whole-certificate estimates: bce s1000 2.1e7 fpe (verified pieces: 3.9e7, about 5e7 nodes); bce s300 9e9 (pieces: 2.4e10); bce s100 1.5e13 (pieces: 1.8e12); mse s3000 5e13 (pieces: 2.6e13); mse s1000 1e16 (pieces: 1.2e16); mse s300 2.2e17.
- d = 128, two hidden layers: 1e35 to 1e36 fpe.
- Scaling fits of log2(cost) per input: 0.68 (squared loss, 1500 steps), 0.78 (600 steps), 0.85 and 0.63 (logistic, 100 and 60 steps).

**Verdict.** Works well as a planning and analysis tool: it predicted real certificate costs to within a factor 1.5 at d <= 24 and within a factor 8 of the verified pieces at d = 64. It is how the scaling with d was measured.

## Adversarial soundness check

**Verdict.** I broke the colleague's soundness claim ("sound for every net and every argument") in two independent ways. In both, verify returns a deterministic, "exact" wrong value of p: it reports [0, 0] when the true p is 1/2.

(a) **Gradual underflow.** The rounding-error budget adds only an absolute 2^-1000 for underflow. But subnormal products such as G·λ (lin) and G·κ (quad) are then multiplied by first-layer quantities, which the verifier allows up to 1e290. So underflow errors of 2^-1075 grow to anywhere from 1e-34 to O(1) times the scale of f. This is triggered by exact power-of-two ReLU rescalings of ordinary nets, which leave p unchanged:
- a hand-built lin case, which the honest prover also produces;
- random rescalings: `quad` bounds exceed the true minimum on 29 of 40 nets (by up to 54%), and 1 of 40 honest lin runs gave a wrong exact count;
- a malicious-θ quad certificate at output scale 2^-53, with the threshold at a normal relative position.

(b) **Normal scales, no underflow.** A unit whose coefficient G has uncertain sign is dropped and charged 5·REL·|G|_abs·U. That charge leaves out G's own rounding error, and the dropped unit also leaves the absolute-value shadow, so nothing covers it. A two-hidden-layer, d = 1 net with O(1) weights gets the exact interval [0, 0] while p = 1/2. The margin is thin (9e-18, with t placed at the bound), but the error is deterministic.

The colleague's tests used weight scales 1e-6 to 1e6, which never produce subnormal products and never put G exactly at the drop threshold. Both bugs are easy to fix:
- rescale hidden units and the output by exact powers of two, or reject subnormal products;
- charge at least (5·REL + γ_D)·|G|_abs·U, for example 6·REL.

Everything else held up:
- tree parsing and demotion of failed certificates;
- exact tie handling;
- the Higham/Cholesky PSD argument (in the absence of underflow);
- the exact uniform sampler, including the Z ≥ 2^62 path;
- the KL interval and hybrid coverage.

That covers 216 random and adversarial nets, 130 of them with two hidden layers, including ties, dead units, p = 0, p = 1 and exact rescalings up to 2^±450. There were 0 wrong exact verdicts in 384 prove/verify runs and 0 violations in about 19,000 adversarial lin/quad bound checks.

**Efficiency.** The numbers reproduce exactly in the colleague's own units, forward-pass equivalents (fpe): same failure counts, node counts and fpe on 5 suite nets. But the fpe metric:
- excludes the prover, which costs 10-30 times the verifier's wall-clock;
- models an incremental verifier that was never implemented; the numpy verifier runs about 20-90 times slower per fpe than numpy Monte Carlo.

End to end at d = 24:
- Plain exact enumeration of the cube (7-8 s) beats prover plus verifier (23-240 s) on every squared-loss net.
- At p = 3.6e-4, where the report claims 9x, Monte Carlo (3-9 s) is about as fast as the verifier alone (7.9 s).
- At p = 9.7e-6, where the report claims 640x, the verifier alone is about 26x faster than Monte Carlo, and prover plus verifier only about 2.7x.

The genuine wins are the d = 28 logistic nets: s100 takes 8.5 s and s150 takes 0.8 s, against 226 s for enumeration and about 41 hours for Monte Carlo.

**Other claims.** The two-hidden-layer verdict holds: LP-optimal intermediate bounds shrink the gap only 22-25%, so the colleague's attribution to the verifier's default-slope intermediate bounds is mostly wrong. The f(0) < t and level-1 Fourier claims hold, except that "37-62% for logistic nets" fails at d = 64.

All my scripts are in /tmp/claude-0/-home-user-AI-works/02f29707-9759-5ff3-9757-46e1f8b0fdfe/scratchpad/attack/ (underflow1.py, underflow_quad.py, quad_maxscale.py, campaign2.py, dropcharge2.py, dropcharge_explain.py, campaign.py, exact.py, sampling_checks.py, bigZ.py, lp2.py, struct_claims.py, repro.py, mc_time.py, enum_time.py, timing2.py, slowpath.py).

- [soundness broken] Certified partition, 'lin' leaf check (CertNet.check_lin / _relax / _backward): Underflow in the chord-slope coefficient. Net (d=1): f(x) = c + a·relu(w·x1 + b) with a = -2^-1074, w = 4e289, b = -1e289, c = 1.2e-34, t = 0 (scratchpad/attack/underflow1.py). The chord slope λ = 3/8 < 1/2, so fl(G·λ) rounds to -0. The verifier then uses the upper bound h <= -λL, which is wrong for z > 0. The missing term λ·G·z ~ 1e-34 is far larger than the slack: REL·vabs ~ 1e-43 and TINY = 2^-1000. The rho guard only rejects |W1| above 1e290. Result: check_lin certifies f >= 2.7e-35 on the whole cube, but the exact f(+1) = -2.8e-35 < t. verify returns [0.0, 0.0] marked exact while the true p = 1/2. The honest prover emits this same SAFE leaf. A random family (exact ReLU rescalings of ordinary nets with hidden x2^(900..960), output x2^-(e1+e2), campaign2.py) gave 1 of 40 honest prove+verify runs with a wrong exact count (2 failing points reported instead of 3, d = 7) and lin bound violations on 5 of 40 nets. The written argument ('plus 2^-1000 for underflow') overlooks that underflowed coefficients are later multiplied by large W1 and c.
- [soundness broken] 'quad' leaf certificate (quad_matrix / check_quad): Underflow in G·κ inside M = (Vt^T·(G·κ))·Vt. For a majorant (G < 0), when G·κ rounds to 0 the verifier silently drops the term G·κ·z², which is the part that makes q >= relu valid. For a minorant (G > 0), a malicious prover tunes θ so that G·κ lands in (0.5, 1)·2^-1074 and rounds up. Nets used: f = c - g·relu(λx) with λ = 1e150 and g = 1e-174 (f ~ 1e-24), the same with λ = 2^400 (f ~ 1e-91), and a minorant net at output scale 2^-53 with λ = 2^510 and t at 0.5 of the scale (underflow_quad.py, quad_maxscale.py). Also tested random exact rescalings (campaign2.py 'quad_sub'), with the largest accepted shift found by bisection. Result: All three hand-built certificates pass Cholesky, and verify returns [0, 0] marked exact while the true p = 1/2. At scale 2^-53 the certified bound is 0.5475·S against a true minimum of 0.3·S. On random rescalings, 29 of 40 nets have quad lower bounds above the exact minimum: 220 violations, median excess 4%, maximum 54%. The largest output scale at which this works with O(1) relative error is about 2^-53, because squaring an endpoint overflows when |L| > 2^511, and the verifier then rejects the minorant. With smaller relative errors (subnormal values above 2^-1074), output scales up to about 1e-8 are vulnerable in principle.
- [soundness broken] Uncertain-sign rule in _relax and _quad_coeffs (drop unit, charge 5·REL·|G|_abs·max(U, 0)): Two hidden layers, d = 1, ordinary weights, no underflow (dropcharge2.py, dropcharge_explain.py). h1 = relu(x1 - 0.5). Two stably active layer-2 units have slopes a1 = 1.1287 and a2 = 1.3762 and biases about 2^-28. Output weights (1.6979, -1.3925) are tuned ulp by ulp so that the computed G on h1 sits exactly at the threshold 5·REL·|G|_abs. The charge omits the rounding error of G itself, and because the dropped unit's slope is 0 it also leaves the absolute-value shadow vabs, so nothing covers that error. Result: Computed G = -1.784755847e-8; exact G = -1.784755857e-8. The exact |G| exceeds the charge base by 9.5e-17. With t set to the certified bound (-8.9237792777e-9), verify returns [0, 0] marked exact while the true p = 1/2: the exact minimum is 9.07e-18 below t. The violation is thin but deterministic and at normal scale, so it contradicts the written claim that rounding is covered in any evaluation order. Fix: charge (5·REL + γ_D)·|G|_abs·U, for example 6·REL.
- [holds] Whole verifier at ordinary and moderately extreme scales (parse, demotion, lin/quad checks, ENUM with exact ties, witness lists): My own campaign of 216 nets (campaign.py with the exact big-integer evaluator exact.py), d = 5-9, 130 of them with two hidden layers. Families:
- Gaussian weights at scales 1e-6 to 1e6 per layer;
- exact power-of-two rescalings of hidden units by up to 2^±450;
- output and threshold scaled by 2^(-1000..900);
- integer weights with many exact ties;
- 40% dead units plus duplicated units;
- p = 0 and p = 1.
For each net: honest prove+verify (lin, and lin+quad) against the exact count. On 6 random subcubes per net and both signs: lin with random, subnormal, all-0, all-1 and optimized slopes, and quad with random, rho = 1, s = 1e-310 and constant θ, using the largest shift that passes Cholesky (bisection). Result: 0 wrong exact verdicts in 384 prove+verify runs, and 0 bound violations in about 19,000 adversarial checks. Reading the code line by line confirmed the tree parse, the treatment of malformed certificates as demotion to OPEN, slope clipping, the checks that make chord slopes valid, act/ina decisions made on padded bounds, the strict FAIL test (f < t), and the Higham Thm 10.3 margin of the PSD check. All are correct when there is no underflow and no unit at the drop threshold. The prover, not the verifier, crashes (eigh on NaN) on 20 of 24 nets with huge first-layer weights. That is a robustness bug only.
- [holds] Hybrid argument: sampled OPEN leaves (_draw_open, kl_interval): Uniformity tests:
- chi-square on an open union of subcubes of sizes 1, 2, 8 and 32 (2e6 draws);
- the Z >= 2^62 branch at d = 64 with Z = 3·2^62.
Coverage tests:
- honest hybrid trees on a trained d = 12 net, every ENUM leaf turned OPEN, N = 1, 10, 100, 1000, 400 repetitions each at δ = 0.1;
- kl_interval coverage by direct simulation at q = 1e-3 to 0.3.
I also checked that N is fixed before the verifier's coins are drawn, so the prover cannot adapt to them. Result: The sampler is exactly uniform: chi² = 41.9 on 42 degrees of freedom, all 43 points hit. In the big-Z branch, P[x0 = -1] = 0.669 (expected 2/3), and the top coordinate is used. Hybrid misses were 0, 1, 5 and 4 out of 400 at δ = 0.1. kl_interval miss rates were 0.001 to 0.026 at δ = 0.1, so it is conservative. The point indicator is exact (rational re-evaluation near t), and the absolute 2^-30 floor in τ also absorbs underflow in the forward pass.
- [claim overstated] Reported efficiency: exact certificates against Monte Carlo and enumeration (run_suite.py numbers): Re-ran prove+verify ('lin', r_leaf = 5) on bce_d28_w32_s150, bce_d28_w32_s100, mse_d24_w32_s2000, mse_d24_w32_s1500 and mse_d24_w32_s1000 (repro.py). Timed:
- prover and verifier wall-clock;
- numpy Monte Carlo at the sample counts the report uses for ratio 1.1 (mc_time.py, timing2.py);
- full exact enumeration by the verifier's own enum_count (enum_time.py, timing2.py). Result: F, node counts and fpe reproduce exactly (for example 163 failing points, 287,323 nodes and 1.79e5 fpe for s1500). But the fpe metric excludes the prover and models an incremental verifier that was never implemented. In wall-clock, the verifier costs about 23-26 µs per fpe at d = 24 and about 190 µs per fpe on the d = 64 piece, against about 1-3 µs per Monte Carlo sample.
- s1000 (claimed 9x faster than Monte Carlo): Monte Carlo 3-9 s, verifier alone 7.9 s, prover 232 s.
- s1500 (claimed 640x): verifier 4.6 s against Monte Carlo about 120 s (about 26x); prover plus verifier 45 s (about 2.7x).
- d = 24 overall: exact enumeration takes 7-8 s, faster than prover plus verifier (23-240 s) on every squared-loss net.
- d = 64 pieces: one 1/256 piece of bce_d64_w64_s1000 took 510 s to prove and 35 s to verify. The 'about 4e7 Monte Carlo samples' equivalence (about 1-2 min) is really about 2.5 h of verification and about 36 h of proving.
Genuine wins remain: bce_d28_w32_s100 takes 8.5 s end to end (enumeration 226 s, Monte Carlo about 41 h) and bce_d28_w32_s150 takes 0.8 s.
- [claim overstated] Verifier cost model: points near t re-evaluated in exact rational arithmetic: τ = REL·(|f|_abs + 1) has an absolute floor of 2^-30. I scaled the output layer and threshold of a trained d = 14 net by 2^-40, which leaves p unchanged (slowpath.py). Result: All 16,384 points went through Fraction evaluation. Wall-clock rose from 0.00 s to 7.6 s, while the reported fpe stayed the same (2.3e3). Soundness is unaffected, but the cost accounting ignores exact re-evaluations and is not scale-invariant. With the 2^-30 floor, every enumerated or sampled point is re-evaluated whenever the output scale is below about 1e-9.
- [holds] Definition of p: exact-arithmetic net (verifier) against float evaluation (test bed): The colleague's tiny-gap net: f = 1/2 - 2^-60·relu(x1) + 1e-3·relu(x2), t = 1/2, d = 8. I compared nets.exact_failure_count, which evaluates f in float64, with the verifier (sampling_checks.py). Result: The float count is 0, the exact count is 64, and verify returns p = 1/4. The verifier is consistent with its documented convention (weights are exact binary values and f is evaluated in exact arithmetic), and the counts match the suite's fail_count on all trained nets. But 'measured against exact p' means the float-defined p only for nets without near-ties, so this convention should be stated next to the suite's p_exact.
- [holds] Two hidden layers: claim that no certificate is cheaper than enumeration because the intermediate bounds are loose: Replaced the verifier's default-slope intermediate bounds with LP-optimal ones (scipy HiGHS: triangle relaxation, 2·m2 intermediate LPs, then the final LP). Ran on 6 random subcubes at each of r = 8, 10, 12, 16 for bce_d28_w64x64_s100 and mse_d28_w32x32_s500 (lp2.py). Result: The gap shrinks only 22-25%, for example from 5.08 to 3.91 at r = 10 against a margin of 1.73 for bce s100, and from 1.85 to 1.43 against 0.21 for mse s500. No subcube with r >= 10 becomes certifiable. The verdict that box-relaxation certificates are hopeless for these two-layer nets is robust. The stated cause (the verifier's loose default-slope intermediate bounds) is mostly wrong: even optimal intermediate bounds leave the gap large.
- [holds] Structural claims: f(0) < t blocks every box relaxation at the root; level-1 Fourier weight: Computed f(0) - t, and the level-1 weight of Var f from 4e5 samples, for all 29 suite nets (struct_claims.py). Result: f(0) < t holds on all 9 one-hidden-layer squared-loss nets with d <= 28 (-0.02 to -0.33) and on mse_d64 s300 and s1000. The argument is valid: the centre of the box lies inside every box relaxation. The level-1 weight is 0.31-0.83% on those nets (0.8-1.6% at d = 64) and 37.6-62% on the d = 28 logistic nets. The summary's '37 to 62% for the logistic nets' fails at d = 64: bce_d64_w64_s300 has 12% and bce_d64_w64_s1000 has 1.7%. The README limits the claim to nets trained for <= 100 steps. The net with the shortest d = 64 certificate is nearly even, and certifies because of its margin (f(0) - t = 1.52), not because it is linear.
