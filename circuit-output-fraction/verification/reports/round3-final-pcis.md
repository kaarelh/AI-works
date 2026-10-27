# Final referee report: pcis

**Verdict.** sound with minor fixes

**What was checked.** I read all of paper/p2-pcis.tex, plus sec-setting.tex, sec-envelopes.tex (def:envelope, lem:envmass, thm:envelope, lem:K, thm:boxes, sec:tilting, prop:tilting), sec-limits.tex (thm:blackbox, thm:ma), p2-lower.tex (prop:proposal) and the cross-references in the intro, discussion and p2-xpt. On the code side I read rareprob/argument.py, envelope.py, rup.py, stats.py, the tseitin function in cnf.py, binarize in ve.py, circuit.py, dist.py and tests/test_fix_pcis.py. Tests pass: test_fix_pcis 50/50, test_core plus test_fix_code 48/48.

LENS A (line by line):
- **thm:pcis-sound.** Union bound with Pr[B_v | history] <= delta_v. Inclusion-monotone interval arithmetic for SUM, SPLIT (literal form as well), PROD and MONO. A failed certificate gives [0,1]. The cap/truncation argument holds: a truncated run agrees with the untruncated one until it stops, and on stopping it returns [0,1].
- **Hardness of checking determinism.** R1 v R2 is deterministic iff F is unsatisfiable. Correct.
- **Checked-deterministic forms.** OBDD, decision-DNNF and SDD (pairwise prime checks via conjoin plus a DNNF SAT test; conjoin needs no negation, so it is valid without the partition property). For certified d-DNNF, pairwise exclusivity at every OR gate gives phi = 1_R.
- **prop:calculus.** A sum or convex combination has ratio at most the max of its children's ratios; products multiply ratios; (1+eps/(2d))^d <= e^{eps/2} <= 1+eps holds for eps <= 2.5.
- **thm:sis(a).** Smoothing plus shared y_i blocks gives #E' = (prod b_i) D(E), and conditioning keeps it.
- **thm:sis(b).** Martingale M_i = w_i F(rho_i), under the stated causality condition.
- **thm:sis(c).** Proof of (*): E[f w 1_{B_i}] = E[1_{B_i} M_{i-1}] <= 2 gamma E M_{i-1}. The weight range ((1+a)/(1-a))^n decreases from 5/3 to e^{1/2}, and the lower factor is >= 3/5 (numerically, n <= 1e5). M = 3 D_hat >= 9/4 D(E) > 5/3 D(E) on A. The conditional MGF bound for adapted [0,1] sequences uses mu_+ for lambda >= 0 and mu_- for lambda <= 0. The interval is [M l, M u/(1-eta)], and the lower end is valid for every D_hat.
- **thm:sis(d).** mu_- >= (7/8)/(15/4)/K > 1/(5K). Only the lower tail of the empirical mean is used in thm:envelope(iv). (1+eps/2)/(1-eps/8) <= 1+eps.
- **thm:certenv.** E Y = D(C and union E_j) via f = C/cov. Y <= 20/9 Lambda_hat < 3 Lambda_hat on A and the good walk event. The clip loss is <= eta D(...). The completeness constant is 7/30 > 1/5. The KLM special case matches. The affine atom has mass 2^{-rank A}, and the pivot re-solve sampler is exact. The time bound includes log log K and n T.
- **Examples.**
  - Hidden-trigger K and MC cost for general D.
  - Planted unions: K <= omega/min Pr[H_j|T_j], and omega = E[#j | C] <= max coverage. On the earlier referee's counterexample this gives exactly 4.
  - Tilted envelope as an envelope circuit with constant leaves.
  - K = K_tilt / Pr[H | thr].
  - Heavy-coordinate example: K = 2^{25.74} at k=20, p = 2^{-40}, exponent about 0.64 (tilt_heavy.py).
  - (10/9)^m second moment: (2/9)(3 + r + 1/r), minimized at r = 1.
  - Sandwich rules for AND, OR, NOT and XOR, base cases, and the gap-sampling cost O(D(U\L)/(p eps^2) log(1/delta)).
- **Citations.** I checked the refs.bib entries for meel2026dnnf (SODA 2026, #CFG and #DNNF admit FPRAS, as verified by the round-1 referee), jvv1986, knuth1975, klm1989, darwiche2001dnnf (smoothing) and darroch1964, and they match their attributions.

LENS B (code and counterexamples, scripts in /tmp/claude-0/-home-user-AI-works/02f29707-9759-5ff3-9757-46e1f8b0fdfe/scratchpad/final_pcis/):
- **sis_exact.py.** 300 random instances, exact Fraction enumeration of the thm:sis walk with adversarial, history-dependent counters (failure probability gamma < 1/(2n), arbitrary or nonpositive outputs, accurate outputs at the extremes 1 +- alpha, D_hat at 3/4, 1 and 5/4 of D(E)). E[C w] = D(C and E) holds exactly, and E[C min(w,M)/M] lies in [(1-eta) mu_+, mu_+] in every case.
- **certenv_exact.py.** 300 instances mixing exact and DNNF pieces, with lambda_j at the extremes. E Y equals the target exactly, and the clipped mean lies in [(1-eta) target, target].
- **fuzz_verify.py.** 900 random arguments against exact rational p. Envelopes include SUM duplicates and PROD children with constant support; marginals include 0, 1, 1e-300, 5e-324 and 1-1e-12; proofs are honest or absent. There were 0 intervals missing p.
- **fuzz_rup.py.** 2480 bogus refutations of satisfiable CNFs (solver proofs of strengthened formulas, prepended extras, random lemma lists). All were rejected.
- **edge.py.** n=0, p=0, p=1, q in {0,1}, and p below the double range. All intervals are valid.
- **huge_mass.py and nan_case.py.** These found the crash reported below. It is a robustness problem, not unsoundness.

Claims that depend on experiment numbers: p2-pcis.tex lines 355-356, "DRUP proofs ... grow rapidly with |A| in our runs (tab:arguments)", which depends on tables/arguments.tex (being regenerated). I did not judge the numbers. Nothing else in p2-pcis.tex cites experiment numbers; the old K=37 claim is gone.

## Audit of earlier findings

resolved: 27, superseded (text removed): 1

- [resolved] (major) proof#1: EXACT/R accept unchecked d-DNNF (determinism coNP-hard): Lines 21-38 now define checked-deterministic as OBDD, decision-DNNF, SDD with checked vtree and pairwise-inconsistent primes, or certified d-DNNF with P-refutations for every pair of OR-children. The coNP-hardness reduction is in the text and is correct. EXACT (lines 48-49) and the certenv atoms (line 265) require checked-deterministic R. A DNNF without such a check enters only through ENVELOPE or thm:sis. The code has no EXACT rule at all (argument.py docstring).
- [resolved] (major) proof#2: thm:sis gives no valid interval (clipping bias, D_hat undefined): thm:sis(c) (lines 185-197) now defines D_hat as one counter call (accuracy 1/4, failure delta_r), outputs [0,1] if D_hat <= 0, sets M = 3 D_hat, clips W' = C min(w,M)/M, and outputs [M l, M u/(1-eta)] with error <= delta_r + delta_s. The lower end is valid for every D_hat. The proof (lines 228-254) is correct, and I confirmed it by exact enumeration with adversarial counters. thm:pcis-sound cites thm:sis(c) as an interval guarantee.
- [resolved] (major) proof#3: thresholds example K=O(sqrt n) false (side condition, integer weights, irrational tilt, binary weights): Lines 367-379: K = K_tilt/Pr_D[H | w.x >= theta]. The sqrt-n bound is restricted to unit weights with E_D[sum x_i] <= theta < |{i: q_i > 0}|. A rational beta comes from bisection via the |E_Q S - t| < 1/(k+2) clause of prop:tilting. The text says no such bound holds for general integer weights (p^{-Theta(1)}; I recomputed the sec:tilting example: 2^{25.74} at k=20). Weights are in unary.
- [resolved] (major) proof#4: ENVELOPE rule certificate supp Phi vacuous for soft envelope: def:envelope now allows nonnegative rational constants. The ENVELOPE rule (lines 63-72) uses G = supp Phi only when all constants are nonnegative integers, and G = [w.x >= theta] for the tilted envelope beta^{w.x-theta}. The verifier always clips W at 1 for the tilted envelope, so the downgraded lower end is valid (thm:envelope(iii)). One residual: clipping is not stated for other non-integer Phi; see the new finding on def:pcis malformed/clip handling.
- [resolved] (major) proof#5: certenv class R broader than proof (DNFs, nested unions, approximate DNNF masses): R_0 is now decomposable products of atoms (subcube, checked-deterministic R, affine atom on q_i = 1/2 coordinates). Unions are allowed only at the top (lines 333-343, which also explain derivation-count use for nested pieces, with the Z vs D(E) gap). DNNF pieces use the weighted KLM estimator Y = C w_j Lambda_hat/(lambda_j cov) with clipping at 3 Lambda_hat and the 1/(1-eta) inflation (lines 287-331). I verified it by exact enumeration.
- [resolved] (minor) proof#6: affine pieces / KLM not among def:pcis rules: The ENVELOPE rule (lines 63-76) now allows the certenv atoms as leaves (exact mass and conditional sampler) and names the weighted KLM estimator of thm:certenv for phi = sum_j 1_{E_j}.
- [resolved] (minor) proof#7: certenv running time missing loglogK, FPRAS overhead additive: The time is now poly(m,|C|,log 1/delta) + O(K(log(1/delta)+loglogK)/eps^2)(|C|+m+n^2+nT), with T the cost of one counter call at accuracy 1/(4n) and failure eps/(16n), so the overhead is multiplicative (lines 279-283).
- [resolved] (minor) proof#8: sis(a) comparator substitution details: Lines 169-174: one shared block y_i of ceil(log2 b_i) bits per variable, x_i -> [y_i < a_i], not x_i -> [a_i <= y_i < b_i], and smoothing first. The proof (lines 207-214) handles out-of-range y_i.
- [resolved] (minor) proof#9: sis(b) 0/0 with marginals in {0,1}: Line 165: variables with q_i in {0,1} are first replaced by constants. A_c = 0 exactly on unsatisfiable branches, and a nonpositive output on a satisfiable branch is replaced by 1 (lines 178-180).
- [resolved] (minor) proof#10: sequential sampler attributed to FPRAS paper: Lines 155-157 now credit the Meel-de Colnet FPRAS, the JVV self-reducibility sampler and Knuth-style weights separately.
- [resolved] (minor) proof#11: hidden triggers 'resolution needs exponential size', missing evidence, uniform-D cost: Lines 354-360: 'this is evidence, not a lower bound, and we conjecture that resolution needs exponential size'. The MC cost is Theta(K log(1/delta)/(D(x_A=a) eps^2)) for general D. The XOR-tree phrase is gone, and a caveat on multiplier tests was added. tab:arguments now exists, and its numbers are being regenerated.
- [superseded (text removed)] (minor) proof#12: unreproducible K=37, n=800, p=4e-125: The thresholds bullet no longer contains any numbers.
- [resolved] (minor) proof#13: planted unions 'overlap' undefined: Lines 361-366 define omega = sum_j D(T_j and H_j)/p = E[#{j: x in T_j and H_j} | C], bounded by the max coverage, and K <= omega/min_j Pr[H_j|T_j]. Checked: correct.
- [resolved] (minor) proof#14: sandwiches base case, XOR/threshold gates, unbounded fan-in: Lines 386-403: binarize first, with thresholds expanded to counters or adder trees. Base cases L = U = x_i and constants are stated. NOT and XOR rules are given (I checked both); each check is a constant number of applies.
- [resolved] (minor) proof#15: SPLIT/PROD conventions, q_x clash, aux variables, hidden independence, calculus hypotheses: Literal SPLIT now needs a P-proof C_v |-_P l, and the verifier forms the restrictions. Marginals are q_i. Tseitin auxiliary variables are disjoint (line 19). PROD is syntactic, and hidden independence goes through a one-child SUM. prop:calculus now restricts to SUM, SPLIT and PROD with valid certificates, sets ratio([0,0]) = 1 and assumes eps <= 1.
- [resolved] (minor) proof#16: 'complete exactly when': Line 8 now reads 'complete whenever ... (thm:certenv)'.
- [resolved] (critical) cx#1: integer-weight K=O(sqrt n) false; soft envelope not an envelope; binary weights; K=37: Same as proof#3, proof#4 and proof#12. The bound is restricted to unit weights, with the general-weight failure acknowledged. The tilted envelope is an envelope circuit with rational constants and certificate G = [w.x >= theta]. Weights are in unary. The numbers are removed.
- [resolved] (major) cx#2: unchecked d-DNNF in EXACT/R, fake d-DNNF piece breaks lower bound: Same as proof#1. Pieces are now checked-deterministic atoms or DNNFs handled by the thm:sis walk, which is exactly unbiased without determinism.
- [resolved] (major) cx#3: sis(c) point estimate vs interval; D_hat undefined: Same as proof#2. The fix the referee suggested ([3 D_hat l, 3 D_hat u/(1-eps/8)] with D_hat charged to delta_r) is what the text now does.
- [resolved] (major) cx#4: certenv class R / time / hypotheses: Same as proof#5 and proof#7. The rational-marginal and uniform-on-affine-coordinates hypotheses are now explicit (lines 264-267).
- [resolved] (major) cx#5: proposal pmf and sampler supplied separately: In p2-lower.tex prop:proposal the seed law must now be self-certifying (autoregressive rational circuits, a smooth decomposable PC, or an envelope law), sampled and evaluated by the verifier from one object. Lines 51-54 explicitly forbid a separately supplied pmf and sampler. Residual: normalization of PC weights is not specified; see the new finding.
- [resolved] (minor) cx#6: sis(b) S=0, zero output on satisfiable branch, causality: 0/1 marginals are substituted first, nonpositive outputs are replaced by 1, and the causality condition ('may depend on the history but not on the coins of steps >= i') is stated in (b).
- [resolved] (minor) cx#7: prop:calculus hypotheses: MONO, PROPOSAL and downgraded nodes are excluded, since only SUM, SPLIT and PROD with valid certificates are allowed, and leaves need ratio <= 1+eta. [0,0] has ratio 1, and eps <= 1.
- [resolved] (minor) cx#8: binary sample sizes, no caps, rejection loops, failed deductive certificates, SPLIT proof: Lines 61-62 and 85-92: sample caps are in unary. A failed deductive certificate gives [0,1]. A cap reached during sequential stopping returns the current valid interval, and a cap reached inside a rejection loop gives [0,1]. Literal SPLIT needs C_v |-_P l.
- [resolved] (minor) cx#9: sandwiches fan-in/XOR/threshold/base case: Same as proof#14.
- [resolved] (minor) cx#10: planted unions overlap (average reading false): omega is now defined as the conditional expected number of satisfied j, not the average coverage. On the referee's counterexample omega/min = 2/(1/2) = 4 = K, so the bound is tight.
- [resolved] (minor) cx#11: hidden triggers lower-bound claim, XOR-tree test, uniform-D cost, multiplier optimism: Same as proof#11.
- [resolved] (minor) cx#12: 'exactly when' and sampler attribution: Same as proof#16 and proof#10.

## New findings

### 1. [minor] paper/p2-pcis.tex, def:pcis lines 63-92 (ENVELOPE rule and failure handling)

**Problem.** The definition never says what happens when the envelope object itself is malformed, as opposed to its domination proof being missing or wrong. Examples: a Prod that is not decomposable with respect to recomputed supports, an 'atom' that fails its determinism, vtree or q_i = 1/2 check, constants that are neither integers nor of the tilted form, or beta < 1. For such Phi the bottom-up mass and sampler are wrong, so 'downgraded to its lower end' is not valid; the round-1 tests show lied-about supports yielding a lower end above p. Second, W is clipped at 1 only for the tilted envelope. A Phi with a non-integer constant (e.g. 1/2) submitted without a proof has W = C/phi in [0,2], so the KL interval for [0,1]-valued samples is invalid. The definition also leaves open what happens if sum_v delta_v > delta.

**Proposed fix.** Add: "The verifier first checks the structure of every statistical node's object (decomposability with supports it recomputes, the atom checks, constants that are nonnegative integers or of the tilted form with rational beta >= 1). A node that fails gets [0,1], as does the whole argument if sum_v delta_v > delta. W is clipped at 1 whenever Phi has a non-integer constant." argument.py already returns [0,1] for a malformed envelope.

### 2. [minor] paper/p2-pcis.tex, proof of thm:pcis-sound lines 113-115; sec-envelopes.tex thm:boxes

**Problem.** The downgrade sentence justifies the lower end of a node without a domination proof by thm:envelope(iii), thm:sis(c) and thm:certenv. The ENVELOPE rule also uses thm:boxes, whose statement assumes domination and never says its lower end survives without it. The fact is true: for integer-valued Phi, W <= 1 on supp Q_hat and Z_hat E W lies in [rho_min, rho_max] * Pr[C and phi>0], so Z_hat l/rho_max <= p. But it is neither stated nor cited.

**Proposed fix.** Add thm:boxes to the list with this one-line argument, or add a clause (iii') to thm:boxes: "if Phi (integer constants) does not dominate C, Z_hat l/rho_max is still a lower bound on p with probability >= 1-delta".

### 3. [minor] paper/p2-pcis.tex, lines 345-346 ('lifts every tractable counting class from syntactic envelopes (sec:part1) to provable ones')

**Problem.** Overclaim. thm:certenv lifts only R_0 (decomposable products of subcubes, checked-deterministic circuits and affine atoms on uniform coordinates) and DNNF pieces. The paragraph just above (lines 333-343) says a DNNF with affine leaves falls outside these rules. Likewise the XOR-DNNF envelopes of prop:xordnnf (direct-sum rather than disjoint-support products) and the other Part-1 tractable classes (tilted Glauber, telescoping) are not lifted with D(E)/p looseness.

**Proposed fix.** Write: "thm:certenv lifts the tractable classes it admits as pieces (subcubes, OBDDs/SDDs/certified d-DNNFs, affine atoms, DNNFs via the FPRAS) from syntactic envelopes to provable ones."

### 4. [minor] paper/p2-pcis.tex, lines 3-5 ('by thm:ma no argument system does so for every circuit')

**Problem.** thm:ma is conditional: complete upper-bound arguments for all 3-CNFs imply coNP subset of MA. The sentence states the impossibility unconditionally.

**Proposed fix.** Write "... and by thm:ma no argument system does so for every circuit unless coNP is contained in MA".

### 5. [minor] paper/p2-pcis.tex, lines 14-19 (choice of P and the Tseitin translation)

**Problem.** (i) 'resolution with RUP/DRAT/LRAT certificates' mislabels DRAT and LRAT. Their RAT steps p-simulate extended resolution, so they are not resolution certificates; only RUP/DRUP is, and that is all the code checks. (ii) Tseitin(F) is not defined for threshold gates, which sec-setting allows with arbitrary weights. Soundness holds for any correct encoding, or for a relaxation that leaves threshold outputs unconstrained (what cnf.tseitin does), but the definition should say which.

**Proposed fix.** Write "resolution (RUP/DRUP certificates), DRAT/LRAT (which p-simulate extended resolution), cutting planes, Frege, extended Frege". Add: "threshold gates are Tseitin-encoded through the counter or adder expansion of sec:setting, or left unconstrained, which is a sound relaxation".

### 6. [minor] paper/p2-lower.tex, prop:proposal lines 4-9 (PROPOSAL rule of def:pcis)

**Problem.** The phrase 'a smooth decomposable probabilistic circuit with rational weights ... sampler and pmf agree by construction' holds only if the verifier fixes the normalization. Suppose sum-node weights are not normalized, e.g. one sum node over leaves [r=0] and [r=1] with weights 1/1000 each. Then the natural ancestral sampler (child proportional to weight) and the bottom-up evaluation of P_R(r) differ by a factor 500. W = D(x)/P_R(R) is then inflated, and tau*l can exceed p (with tau = 1000, C = x_1, D uniform: tau*E[W/tau] = 250 > p = 1/2). The autoregressive form is safe, since out-of-range q_i only overstate the pmf.

**Proposed fix.** Add: "the verifier normalizes the circuit itself (computes its partition function and samples a sum child c with probability proportional to w_c Z_c, as in lem:envmass), or rejects it unless every sum node's weights are nonnegative and sum to 1 and the leaves are normalized".

### 7. [minor] paper/p2-pcis.tex, paragraph 'Sandwiches' lines 386-403

**Problem.** The sandwich certificate is presented inside the PCIS section, but it is not one of the rules of def:pcis. thm:pcis-sound therefore does not formally cover it, or its composition with other nodes, e.g. as a leaf under SUM or PROD. Its own soundness (gate induction plus a KL interval for Pr[C | U\L]) is correct.

**Proposed fix.** Either add it to def:pcis as a rule (deductive OBDD checks, then a statistical node sampling D | (U_out \ L_out) with interval D(L) + D(U\L)[l,u]), or state it as a separate certificate with its own one-line soundness claim.

### 8. [minor] code/rareprob/argument.py verify() lines 300-303; code/rareprob/envelope.py envelope_estimate lines 445-453 and evaluate lines 270-278

**Problem.** An adversarial but well-formed envelope makes the verifier raise an exception instead of returning an interval. (a) With mass above e^709, e.g. 1100 nested SUM(c,c) nodes over ONE (phi = 2^1101 everywhere; a domination proof is trivial), _exp_up raises OverflowError (huge_mass.py). (b) With a derivation count that overflows to inf in evaluate, inf*0 = NaN: root SUM(PROD(BIG, [x0=1]), [x0=0]) with BIG = 2^1024, q0 = 5e-324, C = not x0. W becomes NaN, and sequential_mean raises ValueError (nan_case.py). No unsound interval is produced. But def:pcis says the verifier outputs an interval for every argument, and the soundness tests only cover arguments that do not crash.

**Proposed fix.** In verify(), wrap envelope_estimate in try/except (OverflowError, ValueError, FloatingPointError) and return [0, 1] with proof_ok = False. Alternatively, reject envelopes whose log mass or log max derivation count exceeds about 700, and compute hi in the log domain, capped at 1 before exponentiating. Also align the docstring with the paper (upper end inf vs 1, and the log log K term in the completeness bound).

