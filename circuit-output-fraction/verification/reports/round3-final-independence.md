# Final referee report: independence

**Verdict.** sound with minor fixes. All 19 earlier findings for this topic are resolved. In the fresh review I found no mathematical error, no way to break soundness, and no overclaim in p1-indep.tex or in appendix.tex before the \input lines. My one new finding is a minor clarification about the top AND-tree of a DAG, which affects efficiency, not soundness.

**What was checked.** LENS A: line-by-line re-derivation by hand.

thm:janson-general:
- The polarity-propagation definition of unate, and the induction "reached only positively gives decreasing after flipping the positive variables". A gate reached with both polarities is constant. XOR gates pass both polarities. Negative weights flip the polarity.
- Sandwich: c_i <= b_i by Harris. The Boppana-Spencer split gives c_i >= Pr[B_iF_N|F_R] >= b_i-d_i. Also 1-b+d <= (1-b)e^{d/(1-b)}.
- (a) Pilot: Chernoff exp(-N_0 mu/8); the case mu<1 when N_0 mu < 8ln(4/delta).
- (b) Lower tail exp(-9 lambda/32) with 9*26/128 = 1.83 >= 1. Upper tail at 4 lambda' with exponent 1+4ln(4/e) = 2.545, and 26*2.545/64 = 1.034 >= 1. The mean-domination step lambda <= lambda' is valid through the MGF.
- (c) Hoeffding exp(-N/18) and m R exp(-N/72), with N >= 72 ln(4mR/delta).
- (d) Var Lambda = sum b_i/(N(1-b_i)) <= 2mu/N and E Q <= mu/N. The Taylor remainder |f''| <= 4 gives 2Y^2. The constants: 128 + 16 ln2 = 139.1 <= 140, and 140/560 = 1/4.
- The median step: rounds with F-and-bad are independent with probability <= 1/4 each, giving exp(-R/8). This handles the bias of conditioning on the gate b_hat <= 1/3, because the bound is unconditional.
- The final containment chain Mhat e^{-eps'/4} <= M <= p <= M e^{2 Delta} <= Mhat e^{3eps'/4}.
- Completeness with probability 1-delta/2. The output ratio e^{eps'} = 1+eps. E N, the cost formula, and mu <= -log M <= log(1/p) + Delta/(1-max b).
- Edge cases: p=0 under unateness forces some b_i=1, and then b_hat=1 deterministically gives [0,1]. With m=0 or all b_i=0 the output is [e^{-eps'/4}, 1], which contains p=1. Constant A_i with empty support are handled. Repeated A_i are sound.

thm:second-order (appendix):
- The formula for c_i via nu; each of (H1)-(H6), including R' = R cap Gamma(j) being exactly the earlier non-neighbours of i that meet S_i cup S_j.
- Both Bonferroni directions and both cases C_i >= Theta'_i and C_i < Theta'_i.
- Both sides of E_3: the upper factor is min{1, x_i+(Theta_i+beta_iC_i)/(1-beta_i)}; the lower factor is max{1-b_i, x_i - Theta'_i/(1-beta_i)}.
- The "each connected triple occurs exactly once" claim and the b_i=0 remark.

prop:pairwise-barrier:
- p_stars - p_triangles = q^3(1-q), and Delta = 3q^3 per copy.
- min f = 0.29391 at q = 0.2790; f(1/2) = 0.314, and f tends to 1/3 as q tends to 0.

Moebius expansion and prop:kp:
- kappa(T)=0 for disconnected T.
- The polymer representation; Finner with p_i=r.
- The KP sum <= (d+1)|gamma| e^2 beta sum 2^{1-s} <= (d+1)|gamma|/(ed) <= |gamma|.
- The cluster bound per vertex <= 1, Z_U >= e^{-|U|/e}, and the tail <= m e^{-s}.
- The count of (T,U) pairs: <= 2.23 m(2ed)^{s-1} <= m(2ed)^s.
- The width bookkeeping eps'/2 + 2*eps'/4 = eps', and the sample counts.

Interface DP: conditional independence given x_Z, nonnegative-coefficient multilinearity (so per-entry ratio e^{eps'/m} gives e^{eps'}), and the per-entry cost.

Citations: Boppana-Spencer 1989 JCTA, Finner 1992 Ann. Probab., Kotecky-Preiss 1986 CMP (its theorem includes the decay function d), MNPS 2020 Ann. Probab., Harris 1960, Janson 1990, and Alon-Spencer Thm 8.1.1 are all correctly attributed. I did a web search on wangyin2024 for the 4.82 exponent in the LLL remark. A later paper attributes 4.82 to the Boolean-domain exponent in a condition p(Delta+1)^{4.82}, and the remark's conclusion ("fails") holds under any reading (D = 3(N-3) ~ 3e4 and r = N-2 ~ 1e4 versus ~80).

Numbers (all deterministic except the chain): I read experiments/check_independence_numbers.py line by line, including the closed-form triple counts (common-edge, K4, path), the order-free Theta and beta C bounds, and the logM2 range. results/independence_numbers.json matches every number in the text:
- Delta = 0.02299 at mu=10.
- At mu=100: Delta/(1-b) = 1.067, E3 <= 0.018377, logM2 = -98.9339 for every order.
- e b (d+1) = 4.89e-5 and b^{-1/4.82} = 81.9.
- Barrier: 0.29391 at q = 0.27900.
- Chain: log p = -263.71 (p = 2.95e-115), gap 63.89; certified widths 7.297 (1e5 samples) and 0.0730 (1e9 samples, simulated as Binomial hit counts, which have the same distribution); all intervals contain p.
- results/second_order_check.json: 382 instances, 0 violations, median 0.0637.

LENS B: scripts in /tmp/claude-0/-home-user-AI-works/02f29707-9759-5ff3-9757-46e1f8b0fdfe/scratchpad/indep_final.
- unate_sandwich.py: 10,000 random circuits with AND, OR, NOT, XOR, THR (weights -3..5, including 0, and repeated inputs) and CONST gates, under product distributions with marginals in {0, 1, 1/2, 1/1000, 999/1000, random}, in exact Fraction arithmetic, using the paper's polarity rule.
  - 4,880 circuits were unate: 0 monotonicity violations after the flip, 0 violations of M <= p <= prod(1-b_i+d_i) for random orders.
  - On the 2,373 of these with every beta_i < 1: 0 violations of thm:second-order (both product bounds and |log p - log M2| <= E3).
  - About 720 non-unate circuits had p < M, which confirms the check is needed. The earlier XOR and negative-weight counterexamples are now rejected as non-unate.
- minmatters.py: on 1,467 random monotone instances, the lower product without the min exceeded p in 40 of them, each with >= 2 negative factors. This confirms the appendix remark.
- kp.py: on 200 non-monotone chain instances at the threshold b = (2e^3 d)^{-r} (d=2, r=2), the tail and Z_U bounds hold (worst ratio 3e-4), and kappa(T)=0 for disconnected T.
- janson_code.py and janson_chain.py test code/rareprob/janson.py (thm:janson, the only implemented independence procedure; thm:janson-general is not implemented and the README does not claim it is) against exact Fraction ground truth on 4,500 instances, with 0 misses. The instances include:
  - 4,000 random unate CNFs with marginals 0, 1, 1e-300, 5e-324, 2^-53 and 1-2^-53, repeated literals, repeated clauses and m = 0;
  - 300 disjoint-clause CNFs with up to 3,000 clauses and tiny p;
  - 200 sliding-window CNFs (k = 1..4, m up to 400) with exact transfer-matrix p.
- The existing janson tests pass.
- Floating-point analysis of janson_interval: the absolute slack 2^-36(m+2) covers pairwise-summation and log1p errors. For b near 1, the subtraction error in d_hi - b_lo is absorbed by the relative slack w in b_lo. The subnormal ranges are handled by exp_down and exp_up.

Experiment-dependent claims in my files (for regeneration): the chain numbers at p1-indep.tex l.170-172, from check_independence_numbers.py (seeded), and the 382 instances / median E3 = 0.064 at appendix.tex l.78-81, from check_second_order.py. Both match the current results. All other numbers in these files are deterministic closed forms.

## Audit of earlier findings

resolved: 19

- [resolved] (major) proof#1 unate definition ignores XOR/threshold gates: p1-indep.tex l.8-21 now defines unateness by top-down polarity propagation. XOR passes both polarities, a negative threshold weight flips the polarity, and any other gate disqualifies C. The text also says that a gate reached with both polarities is constant. The old counterexample A_2=[-x>=0] OR y' is now non-unate: x is reached positively via A_1 and negatively via the weight. Brute force on 4,880 random unate circuits with XOR, THR and CONST gates found 0 monotonicity or sandwich violations.
- [resolved] (major) proof#2 mu undefined/unknown, N depends on it: l.4 defines mu = sum_i b_i. Step (2) adds a pilot with N_0 = ceil(8ln(4/delta)) and mu_hat_0, and step (4) sets N = ceil(560(2mu_hat_0+1)/eps'^2 + 72ln(4mR/delta)). Proof (a) shows mu <= 2mu_hat_0+1 except with probability delta/4, and proof (d) uses N >= 560mu/eps'^2. I re-derived the constants: 139.1 <= 140, and 140/560 = 1/4.
- [resolved] (major) proof#3 Kotecky-Preiss FPRAS asserted without proof: prop:kp (l.182-226) now has a proof sketch: the polymer representation, Finner's inequality giving |w(gamma)| <= beta^{|gamma|}, the KP condition with a=|gamma| and decay |gamma| (left side <= (d+1)/(ed)|gamma|), clusters identified with kappa(T), the tail m e^{-s}, Z_U >= e^{-|U|/e}, the count of (T,U) pairs <= m(2ed)^s, and the sample counts. d and r are now defined as maxima. I checked every step; I also checked numerically at the threshold on 200 instances.
- [resolved] (minor) proof#4 triangle-freeness numbers wrong / mixed Delta conventions / no script: The text now reads: mu=10, Delta=0.023, window [M, Me^{0.023}]; mu=100, first-order window e^{1.07}, E_3 <= 0.0184 for every order, log p = -98.93 +- 0.02. All of these match experiments/check_independence_numbers.py and its JSON, and the closed forms are brute-force checked for N=8,9,10. thm:janson (sec-envelopes l.296-300) now uses unordered pairs and e^{Delta/(1-eps_0)}.
- [resolved] (minor) proof#5 output ratio e^eps > 1+eps: The procedure runs with eps' = ln(1+eps) >= eps ln2, so the output ratio is e^{eps'} = 1+eps (l.32, 47, 69).
- [resolved] (minor) proof#6 Delta estimator unspecified; cost unit: Step (3) specifies N_Delta = ceil(26ln(4/delta)/eps') samples per edge, Delta_hat as the sum of the frequencies, and rejection when Delta_hat > eps'/16. Proof (b) gives Chernoff bounds for both directions with correct constants (1.83 and 1.034 >= 1). The cost is now stated in gate operations, with a deg_G(i) eps^{-1} log(1/delta) term.
- [resolved] (minor) proof#7 orientation slip (flipping negative variables): l.16-19 now say: flip the variables that occur positively; every A_i is then decreasing and every B_i increasing. The note that Harris needs only a common direction was added.
- [resolved] (minor) proof#8 beta_i<1 hypothesis and E_3 formula missing from main text: l.118-121 now state 'when max_i b_i<1 and every beta_i<1' and give E_3 explicitly with the denominators (1-beta_i)(1-b_i).
- [resolved] (minor) proof#9 interface DP: no completeness/cost, no chain script: l.165-172 now state the per-entry ratio e^{eps'/m}, the per-entry cost O(m^2 eps^-2 log(sum 2^{|I_i|}/delta)/a_i(y)), and completeness when all entries are >= 1/poly and the widths are O(log|C|). The chain experiment is in check_independence_numbers.py (chain()), and its output matches the text (7.3 and 0.073).
- [resolved] (minor) proof#10 intro 'within e^Delta' and 'additive estimates' overstatement: sec-intro.tex l.92-96 now say e^{Delta/(1-max_i b_i)}, with sampling cost linear in sum_i b_i <= log(1/p)+Delta/(1-max b) and independent of 1/p. The README line 17 matches.
- [resolved] (major) counterexample#1 unate definition admits XOR/threshold (threshold counterexample): The same fix as proof#1. In A1=[-x-y>=-1], A2=[x-z>=0], x is reached negatively through A1 and positively through A2, so C is not unate and the output is [0,1].
- [resolved] (major) counterexample#2 mu unknown; log(1-b_hat) = -inf: The pilot stage fixes the first part, as in proof#2. The gate b_hat <= 1/3 makes every logarithm finite, and the analysis in (d) is done on the event F with an unconditional bound on Pr[F and bad], followed by a union bound over the four events (a)-(d) at delta/4 each.
- [resolved] (minor) counterexample#3 ratio e^eps and U>1: eps' = ln(1+eps), and the output's upper end is min{1, Mhat e^{3eps'/4}} (l.47).
- [resolved] (minor) counterexample#4 orientation of flip: The same fix as proof#7.
- [resolved] (minor) counterexample#5 triangle windows off by factor 2; 0.055 is the 3x overcount; no scripts: The text now uses e^{0.023} and e^{1.07}. The E_3 figure is now the tight order-free bound 0.0184 (the script also reports the 3x overcount, 0.0550, separately). There is one Delta convention throughout, and the scripts exist.
- [resolved] (minor) counterexample#6 b_i=1, b_i=0 and beta_i<1 edge cases: thm:janson-general now assumes max b_i<1, with a parenthetical noting p=M=0 otherwise. The proof notes that b_i=0 makes the factors 1. The appendix (l.22-24) handles b_i=0 before conditioning on B_i. beta_i<1 is stated in the main text and in the appendix.
- [resolved] (minor) counterexample#7 cost 'independent of p' and 'evaluations': The text now says the cost is linear in mu, hence in log(1/p) on the complete class, with no dependence on 1/p, and counts gate operations.
- [resolved] (minor) counterexample#8 KP claim unproved; d, r loose; Z_U>0 not stated: prop:kp states Z_U >= e^{-|U|/e}, defines d as the maximum degree and r as the maximum number of supports containing a variable, and gives the full sketch (see proof#3).
- [resolved] (minor) counterexample#9 vague LLL claim; intro e^Delta: l.127-132 now say the symmetric LLL holds (e b (d+1) ~ 5e-5) but the counting conditions of the sec:modules LLL module (about 80 events per variable) fail, as does the condition of prop:kp (r=N-2). The intro is fixed as in proof#10.

## New findings

### 1. [minor] paper/p1-indep.tex l.3-5 ('Let C=AND_{i=1}^m A_i be the top AND-tree of C'), used by thm:janson-general and prop:kp

**Problem.** C is a DAG, so the AND gates below the output can be shared, and 'top AND-tree' does not say whether the A_i are the distinct non-AND gates reached through AND gates or the leaves of the tree unfolding, taken with multiplicity. With multiplicity, m can be exponential in |C|: a ladder of shared binary ANDs gives 2^depth leaves. The cost O(sum_i |A_i| ...) and the polynomial-time claim of thm:meta, which runs thm:janson-general as a module, would then fail. Duplicate copies also add D(B_iB_j) = b_i to Delta, which needlessly shrinks the complete class. Soundness is unaffected: duplicates keep the sandwich valid, as the brute-force check confirms. The CNF code (meta.as_cnf) already deduplicates repeated clauses.

**Proposed fix.** Add one sentence: 'the A_i are the distinct gates that are not AND gates and are reached from the output through AND gates only (AND is idempotent, so repeats are dropped); hence m <= |C|'. Optionally say 'top AND-layer' instead of 'tree'.

