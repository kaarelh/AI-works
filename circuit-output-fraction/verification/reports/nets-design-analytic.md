# Trained networks, design round: analytic

I added three new methods to code/rareprob/nets_analytic.py and re-ran everything against the exact p of the 21 suite nets with d <= 28, plus the d = 64/128 nets where the method can run there. The new methods are a sign-pattern (softplus) mixture envelope, a perturb-and-MAP upper bound, and a tilt envelope whose minorant is certified on the cube itself. Every method is sound for every net of the architecture: the net is read in exact real arithmetic on its float64 weights, with a certified forward-error allowance. Soundness was checked by brute force on 138 small adversarial nets (Gaussian, integer weights with exact ties, 3-CNF encodings, weight scales 1e-6 to 1e6, degenerate, trained, two hidden layers): 0 violations. 960 two-sided envelope intervals at delta = 0.1 had 0 misses.

Answer for squared-loss nets: no prover-free analytic or envelope method beats Monte Carlo, and three barriers explain why. Each is proved and confirmed by measurement.
(1) Decoupling floor. Every Hoelder / tree-reweighted / Brascamp-Lieb / Finner-type Chernoff bound with exponents >= 1 is at least the value it would have if the parts were independent. With hidden units as the parts, that value is 0.06-0.47 on the MSE nets, because the even parts of positive- and negative-weight units cancel (corr -0.75 to -0.84). Hoelder also inflates the variance a further 37-450x. The best certified decoupled bound is >= 0.94 on every MSE net (at most 0.09 of 4-24 bits explained) and >= 0.22 on every net.
(2) Box barrier. Every envelope whose sampler is a mixture of product measures (tilts, group-DP tilts, sign-pattern sums) has mass Z >= phi(0), because E prod cosh >= 1. When domination is proved by inequalities valid on R^d, phi(0) >= exp(theta (t - F(0))). F(0) < t on all 13 MSE nets with d <= 28: the origin is a failing point of the box, which is the small-ball structure. Measured: Z >= 1 for every such envelope on all 30 nets except one.
(3) Cube barrier. Even with an exact certificate on the cube, any affine-minorant tilt has Z >= 1 when min_x (F(x)+F(-x))/2 < t. That holds on 9 of the 10 MSE nets with p > 0 where it was computed. The exception is the 1-failure net (mse_d24_w32_s2000).
Two more limits: bounding the positive-weight units alone (Esseen, Halasz, or even their exact law) can certify only q+ >= 0.98, and the best hindsight envelope in 1-3 hidden forms has K* >= 843 for p <= 4e-4. The ideal Chernoff envelope has K = 2.1-10.6, so the obstacle is computing the partition function / MAP over the cube, not lack of information.

What works, and where:
(a) Methods that call an exact optimisation over the cube (a MAP oracle) escape the box barrier.
- Perturb-and-MAP certifies about half the log-rarity, for example U = 1.6e-3 at p = 9.7e-6, 5.5e-4 at 3.3e-7 and 1.8e-4 at 7.5e-9, using 380-1720 MAP calls. A toy analysis shows it is exact for subcubes, captures about 75% for halfspaces, and only O(1) nats for a small ball.
- The cube-certified tilt gives two-sided intervals with exact mass and sampler. It needs one certified MAP call, plus a few hundred to choose the tilt. On mse_d24_w32_s2000 (p = 6e-8) it has K = 221: 2.1e6 samples give [5.70e-8, 6.22e-8], against 1.9e10 for Monte Carlo. On bce_d28_w32_s100 (p = 7.5e-9) it needs 146x fewer samples than Monte Carlo at equal accuracy. It gives only 1.09x on bce_d28_w32_s60, which has 3543 failures.
- Each MAP call is NP-hard. HiGHS solves the perturbed MAP in 1-30 s for width 32 up to d = 64, and in 1-3.5 min for width 64 at d <= 48. On the suite's d = 64, width-64 nets it leaves 22-33-nat gaps after 300 s, and the min-f-type certification problem is unsolved in 300 s at d = 64. At d <= 28 enumeration is cheaper. So these are ceilings, not practical wins, on this suite.
(b) Large-margin regime, no oracle. When F(0) - t is large (long logistic training at d = 64), the sign-pattern envelope has Z = 4.9e-3 on bce_d64_w64_s1000. 2e7 samples give p <= 2.4e-9, against <= 1.8e-7 for Monte Carlo with the same samples. This regime does not occur at d <= 28, so it is not checked against an exact p.
(c) Nets with at most 3 hidden units: exact DP interval.

This fits the paper's barriers. One-hidden-layer nets of this architecture encode 3-CNF, so a sound method that is fast on all of them would decide SAT. On trained nets the hardness shows up concretely as the box barrier, and the only escape found is exact (NP/coNP-oracle) reasoning about the discrete cube.

## Methods

### Chernoff-Hoelder (tree-reweighted) bound with exact DP group MGFs (chernoff_holder; relu or even form; units singly, greedy pairs, triples in tests) (upper bound)

**Soundness.** Markov on exp(theta (t' - F)) with t' = t + tau, then Hoelder over the parts F_k with sum rho_k = 1 (the tree-reweighted convex upper bound on the log-partition function). Each part's MGF is bounded using the exact DP law of its quantised forms, with each cell given the part's smallest value on that cell (rounding resolved outward); the linear part is exact via prod cosh. Valid for any theta and rho on any net. 0 violations in 696 brute-force checks.

**Results.** Best certified U per net: 0.939-0.980 on all 9 one-hidden-layer MSE nets with d <= 28 (0.03-0.09 bits of 3.8-24); 0.317-0.759 on BCE d=28; 0.22-0.99 on d=64. Monte Carlo certifies the same U with about ln(1/delta)/U < 15 samples. Decoupling floor (independent parts, a lower limit for every Hoelder/BL/Finner bound with these parts): 0.06-0.47 with single units and 2e-6 to 0.065 with greedy pairs on MSE nets, versus p = 6e-8 to 7e-2. Comonotone variance inflation R_holder 37-450 (MSE) and 13-17 (BCE).

**Verdict.** Hopeless on every trained net. The decoupling floor lemma explains MSE: units cancel, corr(E+,E-) about -0.8. Hoelder's comonotone loss explains BCE, where the floor is small but R_holder is about 15. On the cube, Brascamp-Lieb exponents below Hoelder's are not available because of lattice dependence.

### McDiarmid with certified mean (upper bound)

**Soundness.** Bounded differences c_i = 2 sum_j |a_j||w_ji|; the mean is bounded below by exact per-unit DP laws.

**Results.** U >= 0.90 on all nets.

**Verdict.** Hopeless: sum c_i^2 is 1000x Var f.

### Box-relaxed exponential-tilt envelope (per-unit relaxations; CROWN for two layers) used in the envelope estimator (two-sided)

**Soundness.** Affine g <= F on the box (relu(z) >= s z; chord over the exact box range for negative output weights; float rounding allowance). phi = exp(theta (t' - g)) >= 1 on failures. Exact mass prod cosh, exact product sampler, E_Q W = p/Z; KL sequential interval. Checked by enumeration on 138 nets; 0 coverage misses.

**Results.** Z >= 1 on all 30 nets (the optimiser drives theta to 0, i.e. it reduces to Monte Carlo); K = Z/p >= 1/p.

**Verdict.** Hopeless. Box barrier: Z >= phi(0) >= exp(theta (t - F(0))), and F(0) < t on every MSE net with d <= 28. Even with an exact cube certificate, the cube barrier applies wherever min_x (F(x)+F(-x))/2 < t.

### Group-DP tilt envelope (keep 2 units exactly by DP over quantised forms; tilt the rest) (two-sided)

**Soundness.** Cell-wise pessimistic values of the kept units plus an affine relaxation of the others. Mass by DP under the tilted measure with a certified error bar; backward-DP sampler (chi-square tested).

**Results.** Z >= 1 on every net. Hindsight ceiling for any envelope in 1-3 quantised hidden forms: K* = 843-2992 for p = 3.6e-4 to 6e-8 (Z* = 0.3 down to 2e-4).

**Verdict.** Hopeless. Per-unit lifts on failures are only 1.2-2.9, the rarity is spread over about 16-32 units, and certifying the rest with box relaxations hits the box barrier.

### Sign-pattern (softplus) mixture envelope (new): phi = exp(theta (t' - g)) prod_{j in N} (1 + e^{alpha_j z_j}) over up to 16 negative-weight units (two-sided)

**Soundness.** exp(theta |a| relu z) <= 1 + e^{alpha z} for alpha >= theta |a|, together with box-valid affine relaxations, gives domination on all of R^d. Exact mass as a sum over 2^|N| sign patterns of prod cosh; exact sampler: pick a pattern, then exact coins (dist._bernoulli). Interval widened by the total variation of the float categorical draw. Checks: domination and exact mass on 89 nets, sampler chi-square on 22, barrier Z >= exp(theta (t - F(0))) on all, coverage 0 misses.

**Results.** Z = 1 (barred) on every net with d <= 28 and on 5 of 6 d=64 nets. bce_d64_w64_s1000 (F(0) - t = 1.52): Z = 4.9e-3 (n_split 12); 2e7 samples give p in [0, 2.4e-9], versus a Monte Carlo upper bound of 1.8e-7 with the same samples (speed-up 1/Z = 205 at equal accuracy).

**Verdict.** Works in a regime: large margin at the origin (long logistic training, d = 64), where failures need negative units to push f far below F(0). Hopeless whenever F(0) < t (all MSE nets). Not validated against exact p: at d <= 28, F(0) lies below the 1e-6 quantile of f, and shifted-threshold variants are all barred.

### Cube-certified tilt envelope (new; cube_tilt_envelope) (two-sided (needs a MAP oracle))

**Soundness.** The affine minorant g0 + gam.x <= F is certified on the cube by an upper bound on max_x (gam.x - F(x)) from a MAP oracle (here enumeration with the forward-error slack tau). Then exact tilt mass and sampler as for tilts. Any (theta, gam) is valid; only the final g0 must be certified. Checked on 68 nets: domination and E_Q W = p/Z exact.

**Results.** Exists only when the symmetric gap is positive: MSE s2000 (0.011), the p=0 net, and the BCE nets s60/s100/s150. mse_d24_w32_s2000 (p = 6e-8): Z = 1.3e-5, K = 221; 2.1e6 samples give [5.70e-8, 6.22e-8], against 1.9e10 Monte Carlo samples; 405 MAP calls. bce_d28_w32_s100 (p = 7.5e-9): Z = 6.9e-3 (146x fewer samples than Monte Carlo at equal accuracy); 5e6 samples give [3.3e-10, 2.9e-8], which contains p; 523 MAP calls. bce_d28_w32_s60 (3543 failures): Z = 0.91. Barred on the other MSE nets.

**Verdict.** Works in a regime (late training, few one-sided failures) given exact MAP. The certification is a min-f-type verification problem: HiGHS leaves it unsolved after 300 s at d = 64 for width 32 and 64, and at d <= 28 enumeration is cheaper. Not a practical win on this suite.

### Perturb-and-MAP Chernoff bound (new; Hazan-Jaakkola with block Gumbel perturbations, empirical Bernstein) (upper bound (needs a MAP oracle))

**Soundness.** log sum_x e^{-theta F} <= E max_x [-theta F + sum_b gamma_b(x_b)] (induction over blocks), E S = d log 2 exactly, and R = M - S lies in [-theta Fmax, -theta Fmin]. Maurer-Pontil one-sided bound on E R from n oracle upper bounds; theta and block are chosen on independent pilot samples. Valid for any net given oracle upper bounds. Bound >= p in all 552 small-net runs, and the Hazan-Jaakkola inequality was checked statistically.

**Results.** Certified at delta = 0.05: d=24 MSE U/p = 13, 31, 96, 168, 81 (U = 1.6e-3 at p = 9.7e-6; 4.8e-6 at 6e-8; 9.3/16.7 and 17.7/24 bits); d=28: mse_w64_s600 405, mse_w64_s1000 1655 (10.8/21.5 bits), bce_w32_s60 952, bce_w32_s100 23753 (12.5/27 bits; the uncertified estimate was 1.5e-5, the gap is due to n = 300 and the wide range of f), two-layer w32x32_s500 384; p=0 net U = 1.6e-6. 1720 (d=24) or 380 (d=28) MAP calls. Toy events: exact for subcubes; about 70-75% of log p for halfspaces; constant -0.49 for a small ball where log p is -1.8 to -3.9.

**Verdict.** The only nontrivial certified upper bound found on MSE nets (U about p^0.5). Each sample is an NP-hard MAP call: HiGHS takes 1-30 s for width 32 up to d = 64 and 1-3.5 min for width 64 at d <= 48, but on the suite's d=64 width-64 nets it leaves 22-33-nat gaps after 300 s (bound trivial). Monte Carlo certifies the same U with about 3/U samples, so there is no practical win on this suite. Useful only if MAP is cheap and p is astronomically small.

### Exact DP interval for nets with <= 3 hidden units (small_width_interval) (two-sided (deterministic))

**Soundness.** Exact joint DP law of all quantised pre-activations; cells are classified by the outward-rounded min and max of F on each cell. 0 violations on 224 random small nets (scratch test) and 24 nets in check_soundness.

**Results.** Trained width 1-3 nets at d=24 and d=64 (MSE 300/1500 steps, BCE 100): certifies p = 0 or p = 1 exactly where true; width <= 2 is tight (e.g. [0.163, 0.181] around 0.173); width 3 is loose when p > 0 (e.g. [0.465, 0.746]). At most 80 s.

**Verdict.** Works in a narrow regime (rank <= 3 first layer), regardless of how rare the event is; irrelevant for widths 32-128.

### Esseen / Halasz-type small-ball inequalities on the positive-weight units (characteristic functions prod_i cos((W^T t)_i)) (upper bound (assessed via oracle))

**Soundness.** Any such bound must cover the failure set by E+ <= R with R = max over the cube of (t - c' - L - E-), so its best possible value is q+ = Pr[E+ <= R] (computed exactly).

**Results.** q+ = 0.983-0.995 on the d=24 nets; 0.92-0.94 even if the negative units were controlled to their 1e-4 quantile. The 1-d Esseen bound at r = sd/4 is 0.63 against an exact 0.19 (the DP law dominates it).

**Verdict.** Hopeless: the rarity lives in the joint (E+, E-) cancellation, not in the positive units alone. In many dimensions Esseen is not computable rigorously, and on the cube its aliasing scale equals the spread of one pre-activation.

### Exact-moment (polynomial / SOS-type) Markov bounds (upper bound (oracle ceiling))

**Soundness.** Markov on (f - mu)^{2k} with exact moments from enumeration.

**Results.** Order 4 gives 4e-3 to 8e-3, order 6 gives 7e-4 to 2e-3 at p = 6e-8 to 1e-5. Reaching the Chernoff level needs order 2k = 16-42 (e.g. 1.3e-4 at order 18 for p = 9.7e-6).

**Verdict.** Hopeless: exact moments of order 2k need 2k-wise joint unit laws; DP is feasible only up to 3.

### Ideal Chernoff envelope exp(theta (t - f)) (oracle ceiling) (two-sided if its mass and sampler were available)

**Soundness.** Exact partition function by enumeration (bin minima, so an upper bound).

**Results.** K = Z/p = 2.1-10.6 on all nets with p > 0. The Dobrushin coefficient bound at theta* is 23-27 (needs < 1 for a certified Gibbs sampler).

**Verdict.** Shows the obstacle is computational: a #P-hard partition function and NP-hard MAP, not lack of information.

## Adversarial soundness check

**Verdict.** In the normal regime (no floating-point overflow, d <= 53) I could not break any soundness claim, and the headline numbers reproduce. That regime was tested with 517 adversarial nets in 11 families, checked against exact rational p, with 0 violations other than McDiarmid returning NaN. Also clean: 750 interval runs in the rare regime (p from 1.4e-5 to 1.9e-4) with 0 misses, large-sample bias tests of all four envelope samplers (|z| < 1.5), coverage of the Maurer-Pontil step, and CROWN rounding.

The blanket claim "sound for every net of the architecture" is false at the edges of float64:
- **mcdiarmid** certifies U = 0 when the true p = 11/1024. The term s*s overflows to inf even though the net's own forward pass is finite (|f| <= 3.4e154).
- **small_width_interval** returns [0, 0] when p = 1 or p = 0.5. Cells whose value becomes NaN (inf - inf in _down_vec) are silently dropped. For d > 53 it misses the exact p by about 1 ulp in 92 of 161 cases.
- **fails_exact** gives the wrong "exact" indicator on NaN float outputs (p = 0.75 reported, true p = 1). Their checker shares this blind spot, and its weight scales (1e-6 to 1e6) never reach overflow.

Two explanatory claims are wrong or overstated:
- **Box barrier.** It does not cover group-DP tilts. A small-ball net with F(0) - t = -1 gets group-DP mass Z = 0.597 < 1, while phi(0) >= 1.81. That envelope is valid: 0/200 misses, bias z = 1.5.
- **Few-form hindsight ceiling (K* >= 843).** This is an artifact of coarse grids and a search over only the top-8 positive units. On mse_d24_w32_s1500 one form at a 2^20 grid gives K* = 37, and a pair at budget 2000 gives K* = 24.8; one form at 2^20 gives 43.6 on s1000 and 10 on s2000.

So "no prover-free analytic or envelope method beats Monte Carlo on squared-loss nets" is established only for the families the barriers actually cover. The measured Z >= 1 on the trained nets does hold: I re-ran group-DP with failure-informed units and got Z = 1.00002.

Defect locations in code/rareprob/nets_analytic.py:
- mcdiarmid: `lb = -2*s*s/V` (~line 681).
- _down_vec: `inf - inf` (line 424).
- small_width_interval: comparisons at lines 1046-1047 drop NaN cells, and law.rel is never used for d > 53.
- fails_exact: the ambiguity band at line 224 excludes NaN rows.

Scripts are in /tmp/claude-0/-home-user-AI-works/02f29707-9759-5ff3-9757-46e1f8b0fdfe/scratchpad/attack/analytic_rt/: breaks.py (all counterexamples in one run), bias.py, rare_cov.py, group_trained.py, sp64.py. The sweep and other checks are one level up in /tmp/claude-0/-home-user-AI-works/02f29707-9759-5ff3-9757-46e1f8b0fdfe/scratchpad/attack/: sweep.py with results sweep_11.json, sweep_12.json, sweep_13.json; fewforms_attack.py and fewforms_single.py; sw_bigd.py, crown_cancel.py, pmap_cov.py, repro1.py, repro2.py, repro3.py, mcd_overflow.py, overflow.py, overflow2.py, groupbarrier.py. Another agent is writing unrelated files into the same attack/ directory.

- [soundness broken] mcdiarmid (McDiarmid with certified mean): Float overflow inside the bound only. Net: d = 10, one always-active unit with w_i = 2e53, b = 2.2e54, a = 1e100, c = -8e153, t = 0.5, so F = 2e153*sum(x) + ~1.4e154. The forward pass is finite (max|f| = 3.4e154, tau = 6e139). Margin s = 1.4e154, so s*s overflows to inf while V = sum c_i^2 = 1.6e308 stays finite. Also covered: the 'scales' family of the random sweep (weights up to 1e+-100). Result: The certified value is U = 0.0 (log = -inf), but the exact rational p = 11/1024 = 0.0107; computed exactly, McDiarmid would give 0.087. In 12 of 517 sweep nets mcdiarmid returns U = NaN (inf/inf), which is not a valid upper bound. With W = 0 it raises ZeroDivisionError. Fix: compute -2(s/sqrt(V))^2, or work in logs.
- [soundness broken] small_width_interval (exact DP interval, <= 3 hidden units): overflow: Two cancelling huge units: W = 0, b = 1e150, a = (+1e160, -1e160), c = 0, t = 1/2, so F == 0 exactly and p = 1. A variant with an extra unit computes F = relu(x_1) exactly (p = 0.5). Here a*relu(z) overflows to +-inf, and _down_vec(inf) = inf - inf = NaN; NaN cells fail both comparisons at lines 1046-1047 and are silently left out of hi. Result: It returns [0.0, 0.0] for the p = 1 net and [0.0, 0.0] for the p = 0.5 net (ground truth from rational exact_output). The deterministic 'interval containing p' is violated by the whole of p. Reproduced in analytic_rt/breaks.py.
- [soundness broken] small_width_interval for d > 53: F = relu(sum x) - relu(-sum x) = sum x exactly, d = 54..500, thresholds at many levels, budget = d (quantisation exact). Exact p from binomial sums as Fractions. The docstring says the DP is exact only for d <= 53, but the function neither refuses larger d nor widens by law.rel, and Table H reports d = 64 intervals as deterministic. Result: 92 of 161 intervals exclude the exact p, all by about 1 ulp. Examples: d = 54, p = 1 gives [0.9999999999999998, 0.9999999999999998]; d = 82, p = 1 gives lo = 1.0000000000000002 > p; d = 68, p = 0.5482013271582438 gives [..439, ..439]. Harmless in magnitude, but the stated deterministic guarantee fails.
- [soundness broken] fails_exact / forward_error_bound (exact indicator [F(x) < t]; ground truth of envelope weights and of check_soundness): d = 4, two units with first-layer row (1e308, 1e308, 0, 0), b = 0, a = (1, -1), t = 0.5, so F == 0 exactly and p = 1. The pre-activation overflows to inf when x1 = x2 = 1, giving f_fl = inf - inf = NaN and tau = inf. NaN rows fail |f - t| <= tau, so they are never rechecked in rational arithmetic, and NaN < t is False. Result: fails_exact reports p = 0.75 against a true p = 1.0; the repository's exact_failure_count also says 0.75. No envelope produced a false interval on such nets, because the builders raise (fsum overflow) or yield NaN logZ, which later fails in sampling. Still, the 'exact indicator' claim is false, and check_soundness uses the same function as ground truth, so it cannot detect this class. Its extreme family only reaches scales of 1e-6 to 1e6.
- [claim overstated] Box barrier claim: 'every envelope whose sampler is a mixture of product measures (tilts, group-DP tilts, sign-pattern sums) has Z >= phi(0)': Small-ball net F = relu(sum x) + relu(-sum x) = |sum x|, t = 1, d = 16. Failure means sum x = 0, so p = 0.196, and F(0) - t = -1. Ran group_tilt_envelope keeping both units (budget 4d). Checked domination and mass by enumeration, ran 200 envelope_interval runs at delta = 0.1, and did a 4e6-sample bias test. Result: Group-DP mass Z = 0.597 (d = 24: 0.504), while phi(0) >= exp(theta (t - F(0))) = 1.81 and the plain tilt has Z = 1. K = 3.0, valid domination, 0/200 misses, bias z = 1.50. The barrier holds for positive mixtures of full-support exponential tilts (tilt, sign-pattern), but not for group-DP tilts: e^{-theta H} is a function of cells, not log-linear. Read literally, 'mixtures of product measures' also includes subcube and point masses, for which it fails too. On trained nets group-DP does give Z >= 1: on s1500 with units [30], [15], [2,26], [30,15] I got Z = 1.00002. So the measurement stands, but the explanation is wrong.
- [claim overstated] Few-form hindsight ceiling (few_forms.py): 'best envelope in 1-3 hidden forms has K* >= 843 for p <= 4e-4': Recomputed Z* (mass of the quantised cells containing a failure) over all 32 hidden units instead of the top-8-lift positive units, and at finer grids than budgets 4096/300/60. The single-form DP at 2^20 cells costs a few seconds. Result: mse_d24_w32_s1500 (reported K*_1/2/3 = 12122/2916/2219): single form gives 8195 at budget 4096, 570 at 65536 and 37 at 2^20; a pair over all units gives 1043 at budget 300 and 24.8 at budget 2000. s1000 (reported 2146/1049/843): single form gives 43.6 at 2^20. s2000 (reported 14803/3364/2992): single form gives 10 at 2^20. The ceiling comes from the grid and the search, not from the family; the real obstacle is certifying which cells are empty (a verification problem). That in turn weakens 'no prover-free analytic or envelope method beats MC on squared-loss nets': the three barriers do not cover group-DP or cell-based envelopes.
- [holds] chernoff_holder (Markov + Hoelder / TRW with exact DP group MGFs), decoupling floor: 517-net random sweep against exact rational p, 11 families:
- Gaussian, and wide (m up to 40)
- per-entry scales 1e+-100, and subnormal weights
- integer weights with exact ties
- cancelling duplicate units, and dead / always-on / zero units
- AND-of-halfspace point failures, and small balls
- float-band nets (2^-53 to 2^-60 parts, thresholds at exact output values and +-1 ulp)
- 2-3 hidden layers

The sweep had 139 nets with p = 0 and 46 with p = 1. Settings: relu and even forms, random groups of size 1-3, budgets down to 2. Overflow nets were tried separately. I also checked the Hoelder parametrisation, cell pessimism, quantize exactness (Sterbenz) and the rounding margins line by line. Result: 0 violations. Overflow nets give the trivial bound 1, thanks to the isfinite guard. The z_lo/z_hi rounding near cancellation is covered by the 2^-50 inflation of e. Reproduced CH_even1 = 0.959/0.951/0.939 and floor1 = 0.308/0.240/0.178 on mse_d24 s1000/s1500/s2000, matching Table A/B. The decoupling-floor lemma (||Y||_p >= E Y) is correct.
- [holds] Tilt envelopes (box relaxation; CROWN for deep nets) + envelope_interval: Domination and exact identity E_Q W * Z = p by enumeration on all sweep nets. 300 deep nets with heavy cancellation in W2 @ W1 and weights up to 1e12, comparing max_x[g_fl(x) - err - F(x)] in exact arithmetic with tau. Bias test with 4e6 samples at d = 16. 100 rare-regime intervals (p = 1.4e-5 to 1.9e-4, d = 20). Result: 0 violations. CROWN's err = 1e-10(...) is heuristic, not derived, but the minorant was never violated, even before adding tau. Bias z = -0.01 (tilt) and -0.67 (CROWN). 0 misses. Formal nit: the 'relative weight error below 1e-12' claim is unproven for very large d*max|alpha| (it matters only for d of order 1e3 or more). Table A Z >= 1 reproduces (logZ ~ +2e-5).
- [holds] Group-DP tilt envelope (soundness): Random S, budgets 3/10/30 in the sweep (domination on failures, mass within logZ_err). Bias tests on the small-ball net and on a kinked net. Coverage on the small-ball net (200 runs) and in the rare regime (150 runs). Line-by-line check of sample_backward's TV accounting. Result: 0 violations; bias z = 1.50 and 0.59; 0 misses. Formal nit: eta counts d*2^-52 for the backward Bernoulli draws, but the DP-table relative error gamma(3d+3) per step gives a total variation of about 6d^2 u. In practice the #cells term dominates.
- [holds] Sign-pattern (softplus mixture) envelope: Sweep: domination and mass on every net with negative units, n_split random. Bias test with 4e6 samples. 200 rare-regime intervals. Re-ran bce_d64_w64_s1000 with n_split = 12 and sampled it. Result: 0 violations; bias z = -1.37; 0 misses. Reproduced Z = 0.004872107088132248 (identical to the report) and theta = 22.65. 2e6 samples give [0, 2.23e-8], against an MC bound of 1.84e-6 with the same N; plain MC found 0 failures in 2e6, min f = 3.90. The realised gain at equal N is 76-83x rather than the quoted 1/Z = 205, because the sequential union bound costs about 2.6x. Nits: (1) eta omits float coin error, and beta is not capped, so coins can round to exactly 0 or 1; negligible unless K >~ 1e14. (2) The docstring says domination holds on R^d, but the chord relaxations hold only on the box; the barrier is unaffected because 0 is in the box.
- [holds] Perturb-and-MAP Chernoff bound (Hazan-Jaakkola + Maurer-Pontil): Checked line by line: block-Gumbel induction, E S = d log 2, the range of R, clipping, float32-table allowance, and independence of the pilot and final RNG. Sweep: bound >= p for theta in {0.3, 1, 5, 30}, block 1-3, n = 5/50. Statistical test of the MP step: 6 nets x 4 (theta, block) x 1000 runs, delta = 0.2, d = 8, E R from 2e5 samples. Reproduced s1500 (theta 40, block 6, n 1000). Result: 0 violations in 517 nets. MP miss rate 0 at delta = 0.2. The Hazan-Jaakkola gap is >= -0.9 standard errors, consistent with tightness when the MAP dominates. Reproduced U = 1.80e-3 on s1500 (reported 1.63e-3). Nits: (1) it bounds Pr[F < t] with t, not t + tau, so it does not cover float-evaluated p in every summation order as the module docstring claims for 'every bound'. (2) It returns NaN instead of 1 when theta*Fmax overflows.
- [holds] Cube-certified tilt envelope: Sweep: whenever symmetric_gap > 0, domination and exact mass by enumeration. Reproduced mse_d24_w32_s2000, then ran 40 repeated intervals at delta = 0.1 and a 2e7-sample bias test. 200 rare-regime intervals on 4 nets. Result: 0 violations. Z = 1.3155e-5 and K = 220.7 reproduce exactly. The first interval [5.73e-8, 6.23e-8] from 2,097,152 samples matches the reported [5.70e-8, 6.22e-8]. 0/40 and 0/200 misses; bias z = 0.24. As the report says, the certificate needs the full table plus hundreds of MAP calls, so here it costs more than computing p exactly.
- [claim overstated] MAP-cost / efficiency claims (HiGHS timings, speed-ups vs Monte Carlo): Spot-checked map_milp on mse_d24_w32_s1500 (theta = 20) by importing their function without running their script. Compared the Gumbel block size of the timed MILP with the block size of the certified bounds in Table C, using their own pilot data. Result: Timings reproduce: 12.9 s and 6.7 s, gaps 0 and 9e-5 nats; the enumeration agrees to 1e-14. However, map_milp encodes per-coordinate (block-1) Gumbels, while the certified bounds use blocks of 6 or 7. In their own pilot, block 1 is about 2 nats worse (s1500: log U -4.46 vs -6.43; s2000: -10.07 vs -11.75). The cost of the block-6/7 MAP calls actually needed for the reported U was never measured. HiGHS's floating-point dual bound is not a certificate; the code admits this, the report does not.
- [holds] Reported suite numbers and the cube / decoupling barriers: Re-enumerated mse_d24_w32_s1000/s1500/s2000. Recomputed F(0) - t, symmetric_gap and tilt logZ. Checked the cube-barrier proof (g0 <= (F(x) + F(-x))/2, prod cosh >= 1) and the 3-CNF encoding. Result: Failure counts 6012/163/1 match. F(0) - t = -0.108/-0.064/-0.022 and symmetric gaps -0.240/-0.090/+0.011 match Table B. The cube barrier and the 3-CNF reduction are correct. The authors' coverage claim (960 intervals, 0 misses) is accurate but used only p in {0.1, 0.01} at d = 10; my 750 runs in the rare regime confirm it.
