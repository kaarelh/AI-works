# Final referee report: envelopes

**Verdict.** Paper: sound with minor fixes. Every earlier finding for envelopes, boxes and tilting is resolved in the current text and code. Code: one new critical soundness bug, narrow in scope and about 1e-12 in relative size. tilted_estimate does not dominate C when the threshold t lies in (m, m+1e-12] for an integer m, so tilted_estimate and meta_estimate return intervals that exclude p deterministically. The fix is about one line. The other new findings are minor.

**What was checked.** LENS A (re-derived by hand).
- def:envelope and derivations: tree-unfolding semantics, the "visits each nonempty-support node at most once" argument, the fold requirement, and the DNF/DNNF envelopes.
- lem:envmass: choice probabilities telescope to w(T)/Z_v through Sum, Prod and leaf nodes. The conditional density is D(x)1[x|=T]c(T)/w(T). The bit-length argument holds (product of denominators raised to at most |Phi|).
- Floating-point paragraph: log-domain telescoping. For numpy's cumsum-based categorical draw, the per-category error equals the local rounding error r_j, so tau ~ (n + sum of fan-ins)2^-52 covers it.
- KL interval: validity from Hoeffding 1963 Thm 1, with the orientation KL(muhat||m).
- thm:envelope (i)-(iii): checked, including (iii) for integer and for real phi.
- thm:envelope (iv): KL(a||b) >= (a-b)^2/(2max). The quadratic solve gives d <= a + sqrt(a muhat). The bound (1+e/4)/(1-e/4) <= 1+e holds for e <= 2. j* = O(log K) given N_0 = c log(2/delta_1)/eps^2, since log(2/delta_j)/log(2/delta_1) <= 1 + 1.7 log j. The union bound works because stage sizes are deterministic.
- lem:K identity checked, and K <= m for DNFs.
- Variance: rho = (Z/p)E[1/phi|C] - 1 <= K-1. Exact enumeration at m=3 gives K = 2.370370 = (4/3)^3 and rho = 0.371742 = (10/9)^3 - 1. The per-clause factor (2/9)((a+b)^2/ab+1) is >= 10/9, with equality at a=b. The DKLR AA cost Theta((rho + eps K)log(1/delta)/eps^2) matches.
- Surprise identity checked.
- thm:boxes: Qhat(x) = D(x)/Zhat * sum_T rho(T). Zhat E W is an average of rho, also with constants as a weighted average. The min/max-product DP is valid. (1+e/8L)^{2L} <= e^{e/4}, and (1+e/4)e^{e/4} <= 1+e on (0,1] (the derivative is negative). E W >= e^{-e/4}/K. The cost terms and the k-blocks corollary check out.
- prop:tilting: theta exists by the intermediate value theorem. Darroch's rule as restated, including the perturbed-mean intervals and degenerate p_j in {0,1}. Chebyshev window of at most 4sigma+1 integers. p >= Z Q(S=t).
- "Unit weights matter": optimal Chernoff K = 2^25.74 at k=20 (also 2^52.1 at k=40 and 2^131.4 at k=100).
- thm:janson: the flip-positive convention gives up-sets. Harris lower bound; Boppana-Spencer c_i >= b_i - d_i. Convention matches Alon-Spencer Thm 8.1.1 (Delta_ord/2 = Delta_unord). Cost <= 2 sum |cl_i|^2 d. The eps_0 <= 1/2 geometric-mean remark holds.
- Citations: Hoeffding Thm 1, Darroch 1964, Siegmund 1976, Alon-Spencer Thm 8.1.1 and Harris 1960 are correct. For GKM/GKMSVV I read the FOCS'11 paper text: Sec. 3.2 / Thm 3.6 covers small-space sources and says it counts knapsack solutions 'with respect to all symmetric and product distributions'. The attribution holds.

LENS B (numerics; scripts in /tmp/claude-0/-home-user-AI-works/02f29707-9759-5ff3-9757-46e1f8b0fdfe/scratchpad/final_env).
- envelope_estimate vs brute force, 960 runs: n <= 8, random decomposable envelopes with repeated Sum children and box leaves, marginals in {0,1}, ~1e-12 and 1-1e-12, sample caps 2000 and 2e5. 0 misses at delta=0.1.
- At delta=0.6, 600 runs including non-dominating C (thm (iii)): about 1% misses.
- Earlier underflow counterexamples (AND of 1100 at q=0.5; n=600..620 at q=0.3; 40 random n <= 80): all intervals contain the exact rational p.
- Edge cases p=0, p=1 and n=0 are fine.
- janson_interval: 3000 instances against exact Fraction enumeration (q down to 1e-310 and near 1) plus 4000 float instances (empty clauses, repeated literals, q in {0,1}): 0 violations.
- Product-form tightness: 8039 random instances.
- prop:tilting: 58,241 instances with exact or perturbed theta (|mu-t| up to 0.999/(k+2)) and p_j in {0,1} or tiny. Max K/bound = 0.416; the mode was t in every case.
- tilted_estimate vs exact Poisson-binomial on 400 random block thresholds: systematic failures only for t = m + 1e-13 (finding 1). One other miss was statistical: rerun 200 times it missed 2.5% at delta=0.1.
- Repo tests: 45 core tests and 53 fix tests pass.

Experiment-dependent claims in sec-envelopes: the Janson example after thm:janson ([4.33,5.07]e-7, ratio 1.17, about 30 s of pure Python). The analytic check M = (1-2^-12)^(6e4) ~ 4.34e-7 and Delta ~ 0.155 are consistent with it. It must be re-synced with the regenerated tables.

## Audit of earlier findings

resolved: 45

- [resolved] (major) env:proof#0 dispersion-not-mean claim (major): sec-envelopes l.137-151 now says the KL procedure pays Theta(K) whatever rho is, and a variance-adaptive interval pays O((rho/eps^2+K/eps)log(1/delta)). It adds that thm:sis removes the overcounting (looseness D(E)/p rather than E_D[phi]/p). p2-pcis l.147-154 now speaks of overcounting; 'dispersion' no longer appears there.
- [resolved] (minor) env:proof#1 (10/9)^m 'under every reweighting': The text now says 'under the uniform distribution ... at least (10/9)^m-1 under every reweighting ... (with equality for unit weights)'. p2-pcis l.153 also says 'at least'. I verified that the per-clause factor (2/9)((a+b)^2/ab+1) is >= 10/9.
- [resolved] (minor) env:proof#2 N_0 unspecified, eps<=2, quadratic solve: thm:envelope(iv) now has 0<eps<=1 and N_0=ceil(c log(2/delta_1)/eps^2). The proof contains the quadratic solve m-muhat <= a+sqrt(a muhat). With this N_0, j*=O(log K) holds.
- [resolved] (minor) env:proof#3 two senses of 'support': def:envelope defines sv(v) syntactically (variables at the leaves of the cone, sv(B) for boxes). lem:K uses 'positivity set {phi>0}'.
- [resolved] (minor) env:proof#4 derivations as sub-DAGs undercount: A derivation is now 'a proof tree of its tree unfolding', with 'visits each node of nonempty support at most once'. def:envelope also requires empty-support Prod children to be constant leaves.
- [resolved] (minor) env:proof#5 Z>0, p>0, Z>1, K>=1 unstated: def:envelope defines K only for p>0 and notes K>=1. lem:envmass assumes Z>0. thm:envelope outputs [0,0] if Z=0 and [Z l, min(Zu,1)]. The code still does not clip hi to 1 (new minor finding 3).
- [resolved] (minor) env:proof#6 thm:envelope for real phi / (iii): thm:envelope is now stated for any phi:{0,1}^n->R>=0 with exact Z and sampler. (iii) is split: an interval for Pr[C and phi>0] when phi is integer-valued, and only the lower end Z l (with clipped W) for general phi.
- [resolved] (minor) env:proof#7 Hoeffding-KL interval undefined: Defined before thm:envelope as {m: N KL(muhat||m) <= ln(2/delta)}, citing Hoeffding Thm 1. Checked.
- [resolved] (minor) env:proof#8 surprise paragraph: The paragraph now has 'with |Phi| possibly exponential in |C|', 'If Z>=1 ... replaced by phi=1', 'about K samples (up to eps^-2 log(1/delta) factors)', the description-length charge (zero for envelopes computed from C, |pi| for prover-supplied ones, thm:surprise), and 'once domination is certified'.
- [resolved] (minor) env:proof#9 'All our upper-bound-capable methods': Now 'Most ...', naming the exceptions: Janson/independence, the cftp product-of-ratios estimators, thm:sis, and the tilted Gibbs estimator.
- [resolved] (minor) env:proof#10 per-sample cost in bit model: (iv) now says 'arithmetic operations'. lem:envmass says O(|Phi|) operations on poly(|Phi|,b)-bit rationals (but see new minor finding 5 on the bit length of constants).
- [resolved] (major) env:cx#0 float64 mass underflow breaks soundness (major): envelope.py now uses log_masses with a max-sum rounding bound eta, an absolute tau, and _exp_up/_exp_down. A zero mass is reported only for an exact zero. I reran the cited cases (AND of 1100 vars at q=0.5; n=600, 610, 614, 615, 620 at q=0.3; 40 random AND circuits with n<=80): every interval contains the exact rational p. The paper paragraph after lem:envmass documents this.
- [resolved] (minor) env:cx#1 repeated empty-support Prod children / 2^{2^k} blowup: def:envelope now requires every Prod child with empty support to be a constant leaf ('fold constant subcircuits first'), and derivations are defined on the tree unfolding. The code still accepts Prod(Sum(1,1),Sum(1,1),lit), but its semantics are correct (unfolding); that is harmless.
- [resolved] (minor) env:cx#2 constants only 0/1; (iii) for real phi; DNF terms: Leaves now include 'nonnegative rational constants', (iii) is split as above, and the DNF envelope requires 'consistent, duplicate-free terms'. In the code, dnf_envelope raises ValueError on x and not-x, or on a repeated literal.
- [resolved] (minor) env:cx#3 N_0, loglog(1/eps), 1-2delta, eps<=2: N_0 = ceil(c log(2/delta_1)/eps^2), 0<eps<=1, and 'both hold with probability 1-2delta' are all stated now. (The code's sequential_mean starts at 1024 samples, which affects only the constants in the sample count.)
- [resolved] (minor) env:cx#4 dispersion remark: Same as env:proof#0.
- [resolved] (minor) env:cx#5 10/9 reweighting / uniform D: Same as env:proof#1.
- [resolved] (minor) env:cx#6 surprise paragraph (Z>1, |Phi|, description length, certified domination): All four points are addressed (see env:proof#8).
- [resolved] (minor) env:cx#7 'All our ...' overclaim: Now 'Most', with exceptions including the sec:cftp product-of-ratios estimators.
- [resolved] (minor) env:cx#8 lem:K wording; determinism undefined: lem:K now says 'For p>0', 'positivity set', and 'expected number of satisfied derivations of x~D|C=1'. sec-setting defines deterministic OR gates and d-DNNF. (Unit-constant caveat: new minor finding 8.)
- [resolved] (minor) env:cx#9 Z=0, p=0 non-halting, Zu>1, KL undefined, sampler cost: thm:envelope now covers Z=0 -> [0,0], a sample cap ('With a sample cap it always halts'), min(Zu,1), the KL definition, and 'with the sampler of lem:envmass'.
- [resolved] (minor) env:cx#10 NNF 'two copies' only for {and,or,not}: sec-setting now restricts the two-copies claim to {and,or,not}-circuits and covers XOR (O(k) per polarity), thresholds (sequential counter, O(kW) wires) and opaque gates.
- [resolved] (major) bt:proof#0 sec-part2 threshold-with-side-condition K=O(sqrt n) (major): p2-pcis l.367-379 now states K = K_tilt/Pr_D[H | w.x>=theta], gives K_tilt <= (4/3)(2sqrt n+1) only for unit weights via prop:tilting (rational beta by bisection), and says no such bound holds for general integer weights. Checked.
- [resolved] (minor) bt:proof#1 thm:boxes (1+eps/3)e^{eps/2} > 1+eps: Box widths are now u_j <= (1+eps/(8L))l_j with importance sampling to 1+eps/4. (1+eps/4)e^{eps/4} <= 1+eps on (0,1] (derivative < 0). The code matches: box_eps = eps/(8L), eps_is = eps/4.
- [resolved] (minor) bt:proof#2 loglogK dropped; mean under Qhat not argued: thm:boxes now states O(K(log(1/delta)+loglogK)/eps^2). The proof adds Zhat <= rho_max Z, hence E W >= e^{-eps/4}/K, and invokes (iv) for i.i.d. [0,1] samples.
- [resolved] (minor) bt:proof#3 per-sample cost misses sum|B_j|: The cost is now O(|C|+|Phi|+sum_j|B_j|+LR max_j|B_j|), and the proof explains the sum|B_j| term.
- [resolved] (minor) bt:proof#4 'relative width' undefined: Now stated as u_j <= (1+eps/(8L))l_j.
- [resolved] (minor) bt:proof#5 wrong cross-ref cor:dfsb: Now '... so K<=m by lem:K', with the positivity set = C^{-1}(1) and phi <= m argument.
- [resolved] (minor) bt:proof#6 prop:tilting: theta existence, irrational theta, p_j assumptions: The proof now argues existence via the intermediate value theorem on [E_D S, k_+). The statement allows any theta with |E_Q S - t| < 1/(k+2) (Darroch's refined intervals), so theta can be found by bisection with e^theta rational. The text before the proposition states the assumptions (exact p_j and conditional samplers, or boxes). Numerically confirmed on 58k instances. (The implementation's theta search does not follow this: new minor finding 2.)
- [resolved] (minor) bt:proof#7 'applies verbatim ... (boxes)': Now 'or boxes with min(p_j,1-p_j) >= 1/R, in which case thm:boxes applies with L=k (with weighted averages of rho)', and def:envelope allows rational constants.
- [resolved] (minor) bt:proof#8 Janson example 'in one second': Now 'certified interval p in [4.33,5.07]e-7 (ratio 1.17) in about 30 seconds of pure Python'. This is experiment-dependent and must be re-synced with the regenerated tables.
- [resolved] (minor) bt:proof#9 Janson: eps_0<1, O(eps) remark, flip sign, arithmetic ops: thm:janson now has eps_0 = max b_i < 1 and '(If some b_i=1 then p=M=0.)'. The remark requires eps_0 <= 1/2 and gives relative error e^Delta - 1, which I checked. The proof flips positively occurring variables, giving up-sets {y_{S_i}=1} (correct). The cost is stated in arithmetic operations.
- [resolved] (minor) bt:proof#10 derivations on tree unfolding: Same as env:proof#4.
- [resolved] (major) bt:cx#0 geometric-mean relative-error claim false as eps_0->1 (major): The remark is now restricted to eps_0 <= 1/2. The product form prod(1-b_i+d_i) is stated in thm:janson and used by janson.py with decreasing-b ordering. I confirmed the parenthetical 'stays tight' (proof sketch in new minor finding 6).
- [resolved] (major) bt:cx#1 integer-weight tilting claim in sec-part2 (major): Same as bt:proof#0. The counterexample is now in sec:tilting ('Unit weights matter'), and I reproduced K = 2^25.74 at k=20, p=2^-40.
- [resolved] (minor) bt:cx#2 thm:boxes eps split; code eps/2 mismatch: Paper and code now agree: boxes at eps/(8L), importance sampling at eps/4 (envelope.py l.409, l.437).
- [resolved] (minor) bt:cx#3 loglogK, sequential level, R known, 1-2delta: thm:boxes now says '[l,u] ... at total level delta/2 (fixed or sequential)', includes loglogK and says 'tight with probability 1-2delta'. The box cost O(rL^2R log(r/delta)/eps^2) implicitly takes R (from the hypothesis m_j >= 1/R) as known for fixed-size estimation; a sequential estimator would add only loglog terms. Acceptable.
- [resolved] (minor) bt:cx#4 per-sample cost sum|B_j|: Same as bt:proof#3.
- [resolved] (minor) bt:cx#5 approximate theta and unstated efficiency hypotheses: prop:tilting now covers |E_Q S - t| < 1/(k+2). The assumptions (exact p_j with enumerable blocks, or boxes with min(p_j,1-p_j) >= 1/R) are stated before the proposition.
- [resolved] (minor) bt:cx#6 flip sign convention (paper, sec-part1, janson.py): sec-envelopes, p1-indep (flip positively occurring variables, so A_i is decreasing and B_i increasing) and the janson.py docstring are now all correct.
- [resolved] (minor) bt:cx#7 eps_0=1 undefined: The hypothesis eps_0 < 1 is added, plus the b_i=1 => p=M=0 case. The code handles empty or always-false clauses (brute-force checked, 0 violations).
- [resolved] (minor) bt:cx#8 Janson example timing: Same as bt:proof#8 (experiment-dependent).
- [resolved] (minor) bt:cx#9 'not worked out the error budget' vs thm:janson-general: The last sentence now points to thm:janson-general for the sampled version.
- [resolved] (minor) bt:cx#10 pseudo-polynomial DP; FPTAS citation scope: The text says 'pseudo-polynomial in general weights'. I verified the FPTAS attribution from the GKMSVV FOCS'11 text: Thm 3.6 is stated for small-space sources, and Sec. 3.2 says it counts knapsack solutions 'with respect to all symmetric and product distributions'.
- [resolved] (minor) bt:cx#11 10/9 under every reweighting: Same as env:proof#1.

## New findings

### 1. [critical] code/rareprob/tilting.py, tilted_estimate (l.198-238 log_chernoff/draw: phi_theta = exp(theta(S-t)), W = [S >= t-1e-12] exp(-theta(S-t))); reached from code/rareprob/meta.py meta_estimate via as_block_threshold (l.90-109, l.176-180); enabled by stats.sequential_mean's silent clip of values in (1, 1+1e-9] (l.125-127)

**Problem.** Under the code's own threshold semantics (circuit.py l.173 fires at s >= t - 1e-12), phi_theta does not dominate C when t lies in (m, m+1e-12] for an integer m. At S=m the circuit fires but phi_theta = e^{-theta(t-m)} < 1. The weight W there is e^{theta(t-m)} > 1, and sequential_mean silently clips it to 1. Meanwhile the Chernoff mass Z_theta, computed at t, is below p. When K is about 1 (top threshold) the upper end is Z_theta * e^{eta} < p on every run, which is deterministic rather than probability <= delta. Reproduced cases:
- k=2 single-variable blocks, uniform D, t=2+1e-13: p=0.25 (exact_prob), interval [0.248980, 0.24999999999877].
- k=5, t=5+1e-13: p=0.03125, interval [0.031122, 0.03124999999985].
- meta_estimate on THR of 30 two-input OR blocks with t=30+1e-13 (VE declines, tilting is tight, so nothing else runs): p=0.75^30=1.7858209017001e-4 exactly, returned interval [1.77422e-4, 1.7858209016962e-4].
The miss is tiny (relative ~5e-12), but it is a deterministic soundness violation of the top-level procedure. Separately, sec-setting defines threshold gates exactly as [sum w_j y_j >= t], while circuit.py uses a 1e-12 tolerance that the paper never states. Under the paper's semantics the k=2 instance has p=0, and the interval is wrong by an unbounded factor. nnf.py, ve.py and affine.py already convert to ceil(t-1e-12); tilting.py is the only module that does not.

**Proposed fix.** In tilted_estimate (or in as_block_threshold), replace t by the evaluator's effective threshold. For unit or integer weights use t_eff = ceil(t - 1e-12), as nnf.py l.350/371 does. For real weights use t - 1e-12 in both log_chernoff and the weight, so that phi >= 1 wherever the circuit fires. In sequential_mean, raise on values > 1 (or widen hi by the clipped excess) instead of clipping silently. Add a regression test with t = k + 1e-13. State the 1e-12 tolerance convention in sec-setting, or make THR comparisons exact for rational weights.

### 2. [minor] code/rareprob/tilting.py, best_theta (l.209-217): minimize_scalar on bounds (0, 50)

**Problem.** This is a completeness gap between prop:tilting and the code. prop:tilting says to find theta by bisection on the tilted mean. The code minimises the Chernoff exponent over theta in [0,50] only, so when the mean-matching theta exceeds 50 the bound K <= (4/3)(2 sqrt k + 1) fails for the implementation. Example: k=10 single-variable blocks, q=1e-30, t=1. The mean-matching theta is 66.9 with K=2.58, but the code uses theta=50 with K=1.9e7, against a bound of 9.77. tilted_estimate then returns [0, 1.7e-27] for p=1e-29. The result is sound but not tight.

**Proposed fix.** Bisect theta on E_{Q_theta}S to within 1/(k+2) of t, with the upper bracket found by doubling and no fixed cap (or a cap derived from min p_j), as prop:tilting describes.

### 3. [minor] code/rareprob/envelope.py, envelope_estimate (l.448-452)

**Problem.** The upper end is never clipped to 1, although thm:envelope(ii) outputs [Z l, min(Zu,1)] and def:sound requires [L,U] within [0,1]. Example: a DNF of 12 single-literal terms over 6 variables (p=1) returns [0.965, 1.035]; the constant-1 circuit gives hi = 1.000000000000939. This does not affect soundness.

**Proposed fix.** Set hi = min(hi, 1.0) before building the Estimate (z_upper can also exceed 1).

### 4. [minor] code/rareprob/envelope.py, envelope_estimate with boxes (tau l.441, eta l.442); estimate_boxes and _rejection_fill; paper sec-envelopes l.64-71 ('Our implementation does exactly this')

**Problem.** The outward-rounding argument does not cover the box path. Box intervals come from D.sample (53-bit grid), so they are valid for Dtilde(B_j); |Dtilde(B_j) - D(B_j)| can reach |sv(B_j)| 2^-53, i.e. relative |sv(B_j)| 2^-53/m_j. Rejection fills sample Dtilde(.|B_j), whose total-variation distance from D(.|B_j) is up to about 2|sv(B_j)|2^-53/m_j. Neither enters tau, which grows only linearly in n, or eta, which adds only 2^-45(L+1). The relative effect is about L n R 2^-53, roughly 1e-12, so it has no practical effect. Still, the claim that the implementation widens the interval by every rounding error is not literally true for box envelopes.

**Proposed fix.** Add a max-sum DP term sum over boxes on a derivation of |sv(B_j)| 2^-51/lo_j to eta. Add L * max_j(2|sv(B_j)|/lo_j) 2^-53 to tau. Or restrict the sentence in the paper to box-free envelopes.

### 5. [minor] paper/sec-envelopes.tex, lem:envmass (l.42-43, l.60-61): 'rationals of poly(|Phi|,b) bits (b the bit length of the marginals)'

**Problem.** def:envelope allows arbitrary nonnegative rational constant leaves, and constants enter every mass. The bit-length bound must therefore depend on the constants' bit lengths too, not only on the marginals and |Phi| (which counts wires).

**Proposed fix.** Write 'b the maximum bit length of the marginals and of the constants'. The proof's final sentence already sums products of 'constants and marginals'.

### 6. [minor] paper/sec-envelopes.tex l.320-321, parenthetical after thm:janson: 'the product form, with clauses ordered by decreasing b_i, stays tight'

**Problem.** The parenthetical is true but unproved, and the statement is used to justify the code's choice of ordering. I verified it numerically: on 8039 random instances with Delta <= 1/2, log(window) <= 0.61 * 2Delta/(1-Delta).

**Proposed fix.** Add one line: with decreasing order, any i with an earlier neighbour j has d_i >= D(B_i B_j) >= b_i + b_j - 1 >= 2b_i - 1. Hence 1 - b_i >= (1 - Delta)/2, and prod(1 - b_i + d_i) <= M exp(2Delta/(1 - Delta)) whatever eps_0 is.

### 7. [minor] paper/sec-intro.tex l.36-40: 'at cost O(K eps^-2 log(1/delta)) where K=Z/p (thm:envelope)'

**Problem.** The intro attributes a cost to thm:envelope that the theorem does not prove. thm:envelope(iv) proves O(K(log(1/delta)+loglogK)/eps^2) for the sequential procedure, which is needed because K is unknown.

**Proposed fix.** Write O(K(log(1/delta)+loglogK)eps^-2), or use Otilde and say so.

### 8. [minor] paper/sec-envelopes.tex lem:K (l.132-134): 'For an envelope with literal leaves whose positivity set ... K is the expected number of satisfied derivations'

**Problem.** def:envelope allows rational constants. With non-unit constants, phi(x) is a weighted count, and K = E[phi|C=1] is the expected weighted count, not the number of derivations.

**Proposed fix.** Write 'with literal leaves and unit constants' (as in the derivation paragraph l.32-33), or 'the expected (weighted) number of satisfied derivations'.

### 9. [minor] paper/sec-envelopes.tex l.322-324 (Janson example: [4.33,5.07]e-7, ratio 1.17, about 30 s of pure Python)

**Problem.** These numbers come from the experiments now being regenerated, and I did not judge them. As an analytic check, uniform D, m=6e4 and width 12 give M = (1-2^-12)^(6e4), about 4.34e-7, and Delta is about 0.155 (ratio about 1.167); both are consistent with the text.

**Proposed fix.** Re-sync the interval, ratio and runtime with the regenerated tables/janson output before publishing.

