# Trained networks: synthesis of the design round

## What works

Summary. Two things work well on constant-trained MLPs. First, a sound LOWER bound from fixed-level multilevel splitting (SMC), at every d. Second, EXACT or p = 0 certificates, but only at d up to about 30 or when the margin is large. A sound TWO-SIDED interval faster than Monte Carlo (MC) exists only in those exact, zero or large-margin regimes. MC yardstick: 3 ln(2/delta)/(eps^2 p), which is 1107/p at eps = 0.1, delta = 0.05. "fpe" means forward-pass equivalents. B&B costs about 2.2x more wall-clock per fpe than an MC sample.

A. Sound lower bound, any d, when p > 0 and the failure set is large or connected.
- Method: nets_lower.lower_bound. Levels F < t_k are fixed by an independent pilot. Each replicate runs N particles with indicator-Metropolis bit-flip moves and reports Z = prod (survivors/N). Replicates are combined by a betting e-value (lambda grid). A witness list is added, and a sequential version uses Ville's inequality.
- Guarantee: Pr[L > p] <= delta on EVERY net, with no mixing assumption, because E Z = D(A_K) by Feynman-Kac for any invariant kernel. Each step only lowers that mean: the final level t* - E* and the float flags.
- Validation: 0 misses in 300 suite runs and in 13,500 adversarial red-team runs. No bias in Z for 7 kernels.
- d = 24-28, exact p:
  - For p >= 1e-5, L/p = 0.85-0.89 at 1-4e6 evaluations and 0.92-0.94 at 1-2e7.
  - mse_d28_w64_s1000 (p = 3.3e-7): 0.91. mse_d24_w32_s2000 (p = 6e-8): 0.80. bce_d28_w32_s100 (p = 7.5e-9): 0.84. All at about 2e7 evaluations.
  - Speedup against an MC one-sided bound reaching the same ratio: 0.01-0.5 for p >~ 1e-3 (MC wins), 7-17 at 1e-5, about 100 at 6e-8 to 3.3e-7, about 1.3e3 at 7.5e-9. On the task yardstick (eps = 1 - L/p) these are about 14, 240 and 2.5e3.
  - kappa = relvar(Z) x cost per replicate, against MC's 1/p: 56 at p = 7e-2, 1e3 at 3.6e-4, 6e3 at 1e-5, 1.1e5 at 6e-8. So the gain over MC grows like p^-0.6.
- d = 32-128 (the SMC lane's OWN nets):
  - L/p = 0.92-0.94 with 1.4-4.1e7 evaluations, for reference p from 7.5e-6 down to 7.2e-16.
  - The sequential version reaches a target of 0.9 with 5.4e6 evaluations at d64, p = 5.8e-9 (speedup 3.5e4), and with 7.6e6 at d128, p = 5.6e-11 (1.1e6).
  - Cost is almost flat in 1/p because level sets stay connected under bit flips: acceptance >= 10% and 200+ distinct final particles.
  - Reference p was checked by full enumeration at d = 32 (97 points, 2.26e-8 against 2.36e-8) and by independent MC down to 6e-9. Values below 1e-12 are unverified.
- By-products:
  - An unbiased point estimate, within 1-3% of exact or MC wherever checked. It is not an upper bound.
  - Witness lists give an exact, error-free lower bound. They recovered all 1, 2, 89, 97 and 163 failing points on the tiny-p nets, and 17 of about 20 at d = 64, z = 8.4.

B. Exact p at d <~ 30, one hidden layer.
- Method: certified-partition arguments (nets_prover). A decision tree over coordinates whose leaves are SAFE or FAIL (proved by linear bound propagation with prover slopes, or a degree-2 Shor/S-lemma certificate), ENUM (meet in the middle with rational re-evaluation), or OPEN (sampled). Without a prover, input B&B with CROWN (nets_verify.bab) does the same job.
- Guarantee: deterministic and exact, for every net, once the float fixes below are made.
- Verifier cost, mse_d24 (p from 7e-2 to 6e-8): 1.1e6 down to 1.1e5 fpe, 1.2-13x cheaper than enumeration (1.35e6). Against MC at eps = 0.1: 9x at p = 3.6e-4, 640x at 9.7e-6, 1.8e5x at 6e-8. It loses for p >= 8e-3.
- bce_d28: s60 costs 1.7e5 fpe (MC 8.4e7). s100 costs 1.6e4 (MC 1.5e11, enumeration 1.85e7). s150 is certified p = 0 in 2.0e3.
- No-prover search (B&B) costs 1.4-7.3e6 fpe at d = 24 squared loss (0.7-3.6x enumeration) and 0.008-0.5x enumeration for logistic loss. It beats MC only when there are fewer than about 2e3 failing points (wall-clock).
- On the tiny-p nets at d <= 28, exact methods are CHEAPER than SMC's lower bound. For example, mse_d24_w32_s2000 is exact for 1.1e5-1.4e6 fpe, while SMC needs 1.9e7 to reach L/p = 0.8.

C. Certifying p = 0 (long training, large margin).
- 98 of 107 moderately trained one-hidden-layer nets have p = 0, and all 98 are certified.
- Long-trained nets are certified at the root (about 5 fpe) up to d = 32-40.
- d = 48: 1.6-4.8e7 fpe. d = 64 at 16,000 steps: 3.7e7 fpe.
- Suite net bce_d64_w64_s1000: four verified pieces, each 1/256 of the cube, imply about 4e7 fpe for the whole cube.
- MC can never certify 0: 1e7 samples give only U = 3.7e-7.

D. Sound upper bound in the large-margin regime.
- The sign-pattern (softplus) mixture envelope on bce_d64_w64_s1000 (F(0) - t = 1.52) has Z = 4.9e-3.
- 2e7 samples give p <= 2.4e-9, against 1.8e-7 for MC with the same samples. The realised gain is 76-83x at equal N.
- It has not been checked against an exact p.

E. Two-sided intervals beyond enumeration: only in special cases.
- A cube-certified tilt needs one exact MAP/min certificate. On mse_d24_w32_s2000 it has K = 221: 2.1e6 samples give [5.70e-8, 6.22e-8], against 1.9e10 for MC. On bce_d28_w32_s100 it needs 146x fewer samples than MC.
- But the certificate is coNP-hard and was obtained by enumeration, so this is no practical gain.

F. Witness search.
- HiGHS MILP is a heuristic search, but each witness is rechecked exactly, so the bound it gives is sound.
- It found the suite d = 64 net bce_d64_w64_s100 failing at f = -1.09, which proves p >= 2^-64 > 0, where MC (1e7 samples) saw nothing.
- It also found failures on d = 48 nets that MC and B&B missed.

G. Heuristic estimates (UNSOUND, useful as pilots or priors).
- The 'select' estimator (minimum of a lower-tail fit to 1e5 MC samples and a sphere-input surrogate) is within 10x of exact p on 95% of 3075 (net, level) points. At the threshold it is within 10x on all 340 nets, and on 87% of points with p <= 1e-6. It predicts p = 0 correctly on 98% of nets.
- Adversarial nets of the same architecture break it.

I also checked two things myself:
- The SMC lane's d >= 32 nets are NOT the suite nets of the same names. experiments/nets_lower/results/scaling_nets/mse_d64_w64_s1000.npz and experiments/nets/mse_d64_w64_s1000.npz have different weights (z 4.24 against 4.35). The suite's d = 64/128 nets were never run through SMC.
- I re-ran two prover red-team scripts (listed under fails).

## What fails

1. Black-box upper bounds, so any two-sided interval from evaluations alone.
- The paper's black-box theorem (no certified upper bound below about 1/T from T evaluations) holds INSIDE this architecture. Add one hidden unit, f - B relu(sum_{i in I} b_i x_i - (k-1)). It equals 1 exactly on the subcube x_I = b and 0 elsewhere, so it plants 2^-k of mass into ANY net, trained ones included.
- Observed: on a planted d = 40 net (p = 1.6e-8), SMC's unbiased estimates were 0, 0, 0, 7.5e-9 and 1.2e-7. The SMC mean is therefore not an upper bound, and no evaluation-only method certifies U << 1/T.

2. Worst case.
- One hidden layer encodes 3-CNF: f = sum_j relu(l_j1 + l_j2 + l_j3 - 2) counts unsatisfied clauses, so [f < 1/2] is exactly the set of satisfying assignments (checked on 40 CNFs).
- So no procedure is complete on all nets, even for deciding p > 0, unless NP is in BPP. No complete upper-bound arguments exist unless coNP is in MA. Planted subcubes force about 2^k evaluations for lower bounds.
- Efficiency must therefore come from trained structure. Soundness cannot assume it.

3. Box barrier: the small ball sits at the origin.
- Squared-loss training cancels the linear part (sum_j a_j w_j about 0; level-1 Fourier weight 0.3-1.8%). The output is carried by the even part (1/2) sum_j a_j |z_j|, and failures are a joint small-ball event of the positive-weight units.
- On the box [-1,1]^d the extreme small-ball point is x = 0: F(0) = c + sum_j a_j relu(b_j) < t on all 13 squared-loss nets with d <= 28 (f(0) = 0.10-0.48 against t = 0.5), and on 2 of the 3 squared-loss nets at d = 64.
- Hence any reasoning valid on the box cannot certify the root. That covers interval bounds, CROWN, alpha/beta-CROWN, the LP, MILP over the box, and tilts.
- Any coordinatewise-convex envelope proved on the box has Z >= Phi(0) >= 1, i.e. K >= 1/p. Measured: Z >= 1 on 29 of 30 nets.
- Group-DP envelopes are not covered by this argument; the red team found Z = 0.597 on a constructed small-ball net. Still, Z >= 1.00002 on the trained nets.

4. Cube barrier (antipodal symmetry).
- Squared-loss nets are nearly even: corr(f(x), f(-x)) is about 0.9.
- So min_x (F(x) + F(-x))/2 < t on 9 of 10 squared-loss nets with p > 0. Every certified affine-minorant tilt then has K >= 1/p, even with an exact cube certificate.

5. Decoupling: certified presumption of independence fails.
- Every Hoelder, tree-reweighted, Brascamp-Lieb or Finner bound is at least the Chernoff bound for independent parts. Positive and negative units' even parts cancel (corr -0.75 to -0.84), so that floor is 0.06-0.47.
- Best certified value: >= 0.94 on every squared-loss net.
- Other bounds: McDiarmid >= 0.90; Esseen/Halasz on the positive units >= 0.98; exact-moment bounds need order 16-42.
- The presumption-of-independence heuristic overestimates p by a median factor of 10^2.65.

6. Deduction by relaxation is exponential for squared loss and for two hidden layers.
- On an r-dimensional subcube the relaxation gap grows like r^1.5 to r^1.9 while the margin shrinks. The LP removes 20-55% of it, the degree-2 Shor certificate 35-40%, and the exact box minimum caps r at 8-20.
- So certified leaves have r* of about 4-12. The tree has about 2^(d - 6.5) nodes whatever p is, and certificate cost grows like 2^(0.6-0.9 d).
- d = 64 estimates: 1e13 to 2e17 fpe. d = 128: 1e35 fpe. Within budget, the intervals at d = 64/128 stay [0, 1].
- A perfect engine needs only about F(d - log2 F) nodes (10 to 4800x fewer). The bottleneck is deciding SAFE for a subcube, which is coNP-hard, not the length of the certificate.
- Two hidden layers: only 9-22% of the cube is certified, and nothing beats enumeration.
- B&B followed by sampling the undecided part gives K about 1/p, i.e. Monte Carlo.

7. Limits of SMC.
- MC is cheaper for p >~ 1e-3.
- At small d with tiny p, clusters isolate and the variance is 10-30x ideal. The witness list or exact methods cover this regime.
- Nets trained far into the tail fail (z >= 8.4, about 20 failures in 2^64): L/p = 0.05-0.3 at d = 64, and L = 0 in 8 of 9 runs at d = 128, z = 8.9. This is the lower-bound face of the planted-subcube barrier.
- Variants that gave no gain:
  - Clipped KL: 0.35-0.72 of p. Min-Markov: 0-0.87.
  - Soft tempered levels, block Gibbs and pooled selection.
  - Explicit proposals: an autoregressive logistic model reaches only 0.29-0.44 at p = 1e-9 to 1e-11 (SMC: 0.82-0.87); kernel mixtures reach about 0 at d >= 64.

8. Methods that need a MAP oracle.
- Perturb-and-MAP gives U of about p^0.5 (e.g. 1.6e-3 at p = 9.7e-6). The cube tilt is described above.
- Each oracle call is NP-hard. HiGHS leaves 22-33-nat gaps on the d = 64, width-64 suite nets, and its floating-point dual bounds are not certificates.

9. Floating-point soundness: every engine had edge-case holes.
- nets_lower (SMC): the forward-error bound has no underflow term. On nets whose exact-real p is 0, it certified L = 0.78-0.98. Fix: add (2n+2)2^-1075 per dot product and compute the bound in rationals.
- nets_verify (B&B):
  - At depth >= 3, a NaN from overflow made it certify p = 0 on a net with p = 1.
  - A 1-ulp error when d >= 54.
  - r_enum < 0 is accepted, which gives a wrong answer under python -O.
- nets_analytic:
  - McDiarmid overflow certifies U = 0 at p = 0.0107.
  - small_width_interval drops NaN cells, returning [0, 0] at p = 1, and misses p by 1 ulp for d > 53.
  - fails_exact mishandles NaN rows.
- nets_prover: its red-team report did not reach me. I re-ran two of the scripts left in the scratchpad attack/ folder:
  - underflow1.py: a subnormal output weight gives an 'exact' [0, 0] at p = 0.5.
  - dropcharge_explain.py: at NORMAL weight scales, with two hidden layers and a crafted cancellation, the drop-and-charge rule ignores the rounding of G and certifies 'exact' [0, 0] at p = 0.5.
  - campaign2.json: at subnormal scales, 35 of 80 crafted nets get lower bounds above the exact minimum.
- None of these affect the numbers on trained nets.

10. Claims that the red teams found overstated.
- 'Few-form K* >= 843' is an artifact of the grid: K* = 10-44 at a 2^20 grid.
- 'd = 64 runs after 1e7 fpe' actually stopped after 3.3e4 to 6.1e5 fpe.
- The sign-pattern gain is 76-83x, not 205.
- SMC misquotes: d128, p = 2.9e-15 gives 0.82 at 6.9e6 evaluations; the mean of Z/p ranges over 0.93-1.14.
- fpe hides a factor of about 2.2 in wall-clock time.

## Recommendation

1. What the paper should claim about constant-trained MLPs.

(a) Positive, general: fixed-level splitting plus betting e-values is a SOUND lower-bound procedure on every circuit, with no mixing certificate.
- This corrects the paper in two places. paper/p1-tail.tex (around line 115) says splitting's accuracy 'rests on the mixing of Markov chains'. Discussion open problem 2 in paper/sec-discussion.tex says certified mixing 'is what would make multilevel splitting sound'.
- Both should be restricted to the upper bound, i.e. to two-sided intervals: the lower half is already sound.

(b) Positive, regime-specific:
- Exact certified partitions at d <~ 30 with one hidden layer.
- Certificates of p = 0 for long-trained or large-margin nets up to d = 64.
- An upper-bound envelope in the large-margin regime.

(c) Negative, sharp:
- Inside the architecture, three barriers hold: worst-case hardness via the 3-CNF encoding, the black-box upper-bound barrier, and the lower-bound barrier on planted subcubes.
- On trained squared-loss nets, the small-ball structure explains why box-relaxation deduction and tilting fail: the box barrier, the cube/antipodal barrier and the decoupling floor.

(d) Honest bottom line: for d >= 40 and p > 0 on squared-loss nets, the only sound two-sided method found is Monte Carlo.
- That is provably unavoidable for evaluation-only verifiers.
- It is worst-case unavoidable for all verifiers.
- It is empirically hopeless for box-relaxation deduction (2^(0.6-0.9 d)).
- It remains open for cube-aware deduction (x_i^2 = 1 / SDP, exact MAP-based certificates).

(e) Report the heuristic estimators only as unsound comparators.

2. Code to keep (after fixes; add every red-team counterexample as a regression test).
- code/rareprob/nets.py: the test bed, unchanged.
- code/rareprob/nets_lower.py. Keep lower_bound, run_smc, metropolis, pilot_plan, betting_lower, Witnesses, the sequential mode and forward_error_bound. Make two fixes:
  - an underflow term, with the bound computed in exact rationals;
  - flag only |s - t| < E* at the final level, so exact ties are not flagged (otherwise L = 0 at p = 0.25).
  Move soft levels, block Gibbs, pooled selection, ARLogistic/KernelMixture and the clipped/min-Markov rules to an ablation script.
- code/rareprob/nets_prover.py: the argument language and verifier (verify, check_lin, check_quad, enum_count, _draw_open), plus the prover. Fixes:
  - an underflow term;
  - charge the rounding of G in the drop rule;
  - treat non-finite values as undecided;
  - better still, run the leaf checks in exact rational or outward-rounded interval arithmetic.
- code/rareprob/nets_verify.py: keep bab as the no-prover engine and milp_min as the witness finder. Fixes:
  - treat non-finite bounds as undecided;
  - initialise lo with res.lo;
  - reject r_enum < 0 with an explicit raise instead of an assert.
- code/rareprob/nets_analytic.py: trim it to the barrier diagnostics (symmetric gap, chernoff_holder floor, box tilt), the sign-pattern envelope, the cube tilt and perturb-and-MAP. Fixes:
  - mcdiarmid: compute in logs;
  - small_width_interval: handle NaN cells and refuse or widen when d > 53;
  - fails_exact: handle NaN rows;
  - narrow the box-barrier docstring so it excludes group-DP;
  - drop the few-forms ceiling claim.
- experiments/nets_structure/*.py: keep as analysis scripts. cache/ and logs/ stay on the working branch.

3. Before writing the section.
- Rename the SMC lane's own nets (for example smc_mse_d64_w64_s1000), because their names collide with different suite nets.
- Run SMC on the suite's d = 64/128 nets (run_scaling.py --suite), including bce_d64_w64_s100, where a witness exists.
- Complete the p = 0 certificate of bce_d64_w64_s1000 (about 5e7 nodes estimated), giving an exact data point at d = 64.
- Validate the sign-pattern regime against heavy MC at d of about 32-36.
- Report every cost both in fpe and in wall-clock time.
- Re-run all soundness campaigns after the fixes, including subnormal and overflow scales and crafted cancellation at depth >= 2.

4. Where it goes:
- a new file paper/sec-nets.tex, \input after sec-experiments;
- one new subsection in paper/p2-lower.tex holding the general splitting theorem;
- edits to p1-tail.tex (the splitting sentence) and sec-discussion.tex (open problems 2 and 7: answer 7 for trained nets).

Outline in the next field.

## Outline

NEW SECTION sec-nets.tex: 'Case study: networks trained to output a constant' (label sec:nets). It also adds one subsection to p2-lower.tex.

N.0 Setting and certified evaluation.
- f is a ReLU MLP with float64 weights. F is its exact-real semantics on those weights.
- C(x) = [F(x) < t], with t = 1/2 for squared loss and t = 0 on the logit for logistic loss. D is uniform on {+-1}^d.
- Lemma N.0 (certified evaluation). |f_fl(x) - F(x)| <= E(x)/2, where E = Higham's gamma_n term plus (2n+2)2^-1075 per dot product. E is computed in rationals, and any non-finite intermediate is treated as undecided. Points with |f_fl - t| <= E are re-evaluated in rationals.
  Proof: Higham's model with gradual underflow, fl(a op b) = (a op b)(1+e) + eta with |eta| <= 2^-1075, propagated layer by layer.
  Remark: list the red-team counterexamples (underflow, FMA order, NaN, drop-charge) as the reason this lemma is needed.

N.1 Proposition (the architecture is as hard as circuits).
(a) For a 3-CNF phi with m clauses, f_phi(x) = sum_j relu(l_j1 + l_j2 + l_j3 - 2), with literals +-x_i and -1 meaning true, has width m and integer weights, and f_phi(x) = #unsatisfied clauses. Hence [f_phi < 1/2] = SAT(phi), so prop:worstcase(a) and thm:ma hold for one-hidden-layer nets.
(b) Planting: for any net f, I with |I| = k, b in {+-1}^k and B >= max f - t + 1 (computable from the norms), f_{I,b} = f - B relu(sum_{i in I} b_i x_i - (k-1)) agrees with f off S = [x_I = b] and fails on S. For deeper nets, carry the unit through the layers with relu(h) = h for h >= 0. So thm:blackbox and thm:surprise(a) hold around every trained net, with p changing by at most 2^-k.
Proof: the sum equals k on S and is at most k-2 off S.

N.2 Structure of trained failure sets (empirical paragraph plus Table N0).
- Mean |x_i| over failures is 0.07-0.1. Pairwise Hamming distance is about d/2. The best halfspace containing all failures is 1e3-1e6 times too large.
- Squared loss: level-1 Fourier weight 0.3-1.8% (logistic: 37-62%); corr(f(x), f(-x)) about 0.9; the even part falls from 0.65 to 0.12.
- Failures are a joint small-ball event of the positive-weight units: f = c + L + (1/2) sum_j a_j |z_j|.
- p = 0 on 98 of 107 trained nets. Clusters under bit flips: 74 for mse_d24_w32_s1500.

N.3 [in p2-lower.tex] Theorem (multilevel splitting is sound for lower bounds without mixing).
Statement:
- Let s be any exactly decidable score, with levels t_1 > ... > t_K fixed independently of the run, A_k = {s < t_k} and A_K a subset of C^{-1}(1).
- Let each M_k be any kernel leaving D|A_k invariant: for example, flip a uniformly random r-set chosen independently of x and accept iff the new point lies in A_k; or heat bath on a block.
- Run N particles, resample uniformly among the survivors, and set Z = prod_k N_k/N.
- Then E Z = D(A_K) <= p for every C and every choice of kernels (including identity kernels).
Proof sketch: let gamma_k(phi) = E[Z_k eta_k(phi)]. Unbiased selection and mutation give gamma_k(phi) = gamma_{k-1}(1_{A_k} M_k phi). Invariance gives D(1_{A_k} M_k phi) = D(1_{A_k} phi), so by induction gamma_k(phi) = D(1_{A_k} phi). Put phi = 1.
Corollary: float flags (report Z = 0) only lower E Z.

N.4 Proposition (betting lower bound from nonnegative replicates).
Statement:
- Let Z_i >= 0 be i.i.d. with E Z_i <= p.
- E_R(p0) = |Lambda|^-1 sum_{lambda in Lambda} prod_{i <= R} (1 - lambda + lambda Z_i/p0) is decreasing in p0.
- L = sup{p0 : E_R(p0) >= 1/delta} satisfies Pr[sup_R L_R > p] <= delta (anytime-valid).
- Completeness: if E Z >= (1 - eps/2)p and E Z^2 <= (1 + v)(E Z)^2, then R = O((1 + v) eps^-2 log(|Lambda|/delta)) replicates give L >= (1 - eps)p with probability 1 - delta.
Proof sketch:
- Validity: each product is a nonnegative supermartingale, so Ville's inequality applies.
- Completeness: use log(1 + u) >= u - u^2/(2(1 - lambda)^2) for u >= -lambda, then a one-sided Bernstein bound for sums bounded below.
Remarks:
- No clipping is needed, unlike prop:proposal's KL route, and heavy upper tails are harmless.
- A witness list can be combined by taking the maximum.
- thm:surprise(a) still binds: the z >= 8.4 failures.

N.5 Results for SMC.
- Table N1, d <= 28 exact suite (21 nets). Columns: p, F, z; MC cost (1107/p); L/p at about 2e6 and about 1.5e7 evaluations; witness ratio; speedup on both yardsticks.
- Table N2, d = 32-128 (renamed nets). Columns: p_ref with its checks (exact d = 32, independent MC); L/p and evaluations; sequential cost; failure rows at z >= 8.4.
- Figure N1: cost versus p, log-log.
- One line on the efficiency kappa, about p^-0.4.
- One line on the mixing diagnostic: acceptance rate and distinct particles at small versus large d.

N.6 Proposition (certified partitions; instance of thm:certenv).
(a) Soundness: leaves partition the cube. SAFE/FAIL checks stay valid for any slopes clipped to [0,1] and for any Shor multipliers, with a PSD check by Cholesky with a backward-error margin. ENUM leaves are exact. OPEN leaves form an envelope with exact mass and sampler, so thm:envelope applies.
(b) Ideal size: a pure tree with at most 2F(d - floor(log2 F)) + 1 nodes always exists (trie argument). So thm:ma bites through leaf checking, which is coNP-complete by N.1(a) restricted to subcubes, not through length.
(c) Relaxation gap, one hidden layer: on a subcube with free set R, min_S F - lb_CROWN <= sum over units j unstable on S of c_j |a_j| ||w_{j,R}||_1, where c_j = 1 if a_j > 0 and 1/2 if a_j < 0. So a leaf is certified once its margin exceeds this.
Proof: the per-unit relaxation gap is at most min(u, -l) or -lu/(u - l), and an affine minorant has the same minimum on the box and on the cube.
Remark: Pr[unit unstable] is proportional to ||w_R||_2, which gives a gap of order r^1.5 (measured r^1.5 to r^1.9). Then r* = (margin/(kappa iota))^(1/2 to 2/3) and size is about 2^(d - r*).
Tables and figures:
- Table N3, exact certificates: verifier fpe, B&B fpe, enumeration fpe, MC fpe, for one-hidden-layer nets plus a row for two hidden layers.
- p = 0 frequency and cost by d.
- Figure N2: gap against r for lin, quad and the exact box minimum, compared with the margin.
- Figure N3: Knuth cost against d, with the d = 64 verified pieces.

N.7 Barriers for upper bounds on trained nets.
Proposition N.7 (box barrier):
(a) If F(0) < t, then every bound valid on [-1,1]^d is below t, so no box-based certificate decides the root.
(b) If Phi on the box is convex in each coordinate (for example a positive combination of exponentials of affine functions) and Phi >= 1 wherever F < t, then Z = E_U Phi >= Phi(0) >= 1, so K >= 1/p.
Proof: iterated Jensen, using that each x_i is +-1 with mean 0.
Remark: F(0) = c + sum_j a_j relu(b_j) is the small-ball extreme. Group-DP cell envelopes, enumeration, MAP oracles and x_i^2 = 1 reasoning escape the barrier.
Proposition N.8 (cube barrier):
- If g0 + gamma.x <= F on the cube, then g0 <= s* = min_x (F(x) + F(-x))/2.
- Hence the tilt has Z = e^{theta(t - g0)} prod cosh(theta gamma_i) >= e^{theta(t - s*)}.
Proof: add the inequalities at x and -x.
Proposition N.9 (decoupling floor):
- For F = sum_k F_k and Hoelder exponents with sum rho_k = 1, prod_k ||e^{-theta F_k}||_{1/rho_k} >= prod_k E e^{-theta F_k}.
- So every such bound is at least the independent-parts Chernoff bound.
- Relate this to thm:janson: the correlation is negative across units of opposite output sign.
Remark (oracle methods): perturb-and-MAP gives U of about p^(1/2); the cube tilt gives K = 221 when s* > t. Both need NP/coNP-hard calls.
Table N4, diagnostics: F(0) - t, box minimum, s* - t, decoupling floor, best Hoelder bound, box-tilt Z, gap and margin at r = 8, r*, and level-1 weight.

N.8 Regime map and heuristics.
- Table N5: rows are the regimes:
  - p >~ 1e-3;
  - d <~ 30;
  - d >= 40 with a large connected failure set;
  - p = 0 / large margin;
  - far tail (z >= 8.4).
  Columns: best sound two-sided method, best sound lower bound, exact or zero certificate, and cost relative to MC.
- Table N6: unsound estimators (select, mcfit, sphere, Gaussian, presumption of independence) against exact p, plus the adversarial nets (lattice small ball off by 10^15.7 at d = 400; planted subcube).
- One line listing methods tried with no gain:
  - soft levels, block Gibbs, pooled selection;
  - explicit proposals;
  - McDiarmid, Esseen, moment bounds;
  - few-form envelopes;
  - quadratic and LP-dual B&B prototypes.

Edits elsewhere:
- p1-tail.tex and sec-discussion.tex open problem 2: splitting is already sound for lower bounds; certified mixing is needed only for the upper half.
- Open problem 7: answer it for trained nets. Squared-loss nets: blocked by N.7-N.8. Large-margin logistic nets: positive.
- Intro: add one Results bullet.
