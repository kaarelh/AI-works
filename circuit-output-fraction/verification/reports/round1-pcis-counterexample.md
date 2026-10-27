# Round 1 referee report: pcis (counterexample lens)

**Verdict.** Contains false statements. The integer-weight threshold example claims K=O(sqrt n), and that claim is false. The union-bound adaptivity argument of thm:pcis-sound is correct. The identity in thm:sis(a)/(b) is correct, and so are the [0.58,1.70] constants. Still, thm:pcis-sound holds only if three rules are fixed: the exact rule (d-DNNF determinism cannot be checked), the thm:sis node (estimate vs. sound interval) and the proposal rule (the seed sampler cannot be checked). thm:certenv's class R is larger than its proof covers. These need major fixes.

**What was checked.** Read all of sec-part2.tex in full, plus sec-setting.tex, sec-envelopes.tex, sec-limits.tex and the relevant parts of sec-part1.tex. Experiments, all in /tmp/claude-0/-home-user-AI-works/02f29707-9759-5ff3-9757-46e1f8b0fdfe/scratchpad:
(1) sis_check.py, exact rational enumeration. It checks the Knuth-style sequential sampler of thm:sis(b) on 180 random instances (n<=6, random rational marginals). Counter outputs were exact, arbitrary, or dependent on the history. E[C w]=D(C and E) held exactly in every case, so (b) is correct up to the edge cases in finding 6. Weight range: ((1-eta)/(1+eta))^n to ((1+eta)/(1-eta))^n with eta=1/(4n) gives [0.600,1.667] for all n<=1e5. The per-step bound e^{+-2.1/(4n)} gives [0.5916,1.690]. Both lie inside the claimed [0.58,1.70], so the constants are right.
(2) comparator.py: the comparator substitution of thm:sis(a) gives #E'=prod b_i * D(E)=51 with smoothing and 88 without. The claim is correct, and smoothing is necessary.
(3) misc_checks.py: the relative-variance formula and the (10/9)^m factor for AND(x_i or y_i). The minimum over every reweighting is exactly 10/9 per block, so this is correct. It also runs the planted-unions counterexample (finding 10), the fake d-DNNF count (finding 2), and a random test of prop:calculus on 20000 sum/split/prod trees with no violations. The proof of prop:calculus is correct apart from the hypotheses in finding 7.
(4) tilt_int.py: exact log-space DP for K=min_beta Z_beta/p with integer weights (finding 1).
(5) sis_clip.py: clipping bias in thm:sis(c) (finding 3).
Checked by hand: the inductive soundness of the sandwich rules for AND, OR and NOT (correct), and its sample count O(D(U\L)/(p eps^2) log(1/delta)) (correct). The KLM proof in thm:certenv is correct for exact pieces. The hidden-trigger K and Monte Carlo costs are correct under uniform D. The adaptivity/union-bound argument of thm:pcis-sound, including the summable schedule and downgraded nodes, is correct given valid per-node guarantees. The bib entries for knuth1975, klm1989 and dklr2000 are correct. I could not verify the venue and pages of meel2026dnnf (SODA 2026, pp. 5978-6010): this turn's web search budget was used up. While checking speedup.json I also noticed that the repo's n=800 threshold run reports [6.89e-27, 7.55e-27], which misses the exact p=7.79e-27. That is plausibly the expected delta=0.05 failure (1 of 22 rows).

## Findings

### 1. [critical] sec-part2.tex, examples after thm:certenv, bullet 'Thresholds with side conditions' ('give K=O(sqrt n) (prop:tilting); numerically K=37 at n=800, p=4e-125')

**Problem.** prop:tilting covers only S = sum of {0,1}-valued blocks with unit weights. For integer weights w the claim K=O(sqrt n) is false, even with the optimal beta. Counterexample A (uniform D): w=(W,...,W) with W=1000 and theta=W(n-1)+1, so the event is all ones. Exact DP gives K = 66, 134, 269, 539, 1080 for n = 25, 50, 100, 200, 400, i.e. K ~ e*n. At n=400 the prop:tilting bound is 54.7. Counterexample B (product D with rational marginals): one heavy bit of weight n+1 and marginal 2^-n, plus n uniform unit bits, theta=n+1, so p=2^-n. The best soft envelope has K ~ 1.29*1.5^n (n=80: 1.5e14; n=160: 1.8e28), which is exponential. Further problems with the bullet: (i) K ignores the side condition; the correct value is K_threshold / Pr[G | w.x >= theta]. (ii) The soft envelope beta^{w.x-theta} is not an envelope under def:envelope (constants must be 0 or 1). The envelope rule's certificate 'C_v |-_P supp Phi' is vacuous for it, because its support is everything, so def:pcis has no rule this argument instantiates. (iii) For weights written in binary, the exact mass needs beta^{w_i}, which has exponentially many bits. (iv) The numbers K=37, n=800, p=4e-125 do not appear in any experiment in the repo: the n=800 threshold run has p=7.79e-27 and K about 17.

**Proposed fix.** Restrict the claim to C=[sum_j g_j >= t] AND G with {0,1}-valued blocks and unit weights, under the hypotheses of prop:tilting. Then K <= (4/3)(2 sqrt k+1) / Pr[G | S>=t]. For general integer weights, say that no polynomial bound holds, citing counterexamples A and B. Add to def:pcis a 'soft envelope' rule whose certificate is a P-proof of C_v => [w.x >= theta]. Its mass should be computed with certified upper rounding rather than exact rationals. Either cite the source of 'K=37, n=800, p=4e-125' or replace it with the repo's own numbers.

### 2. [major] sec-part2.tex, def:pcis rule exact ('C_v is (or P-provably equivalent to) a d-DNNF, OBDD or SDD R, so q_v=D(R) exactly'); also thm:certenv, class R ('d-DNNFs') and 'Without the proof the same samples still certify a lower bound'

**Problem.** Determinism is a semantic property, and the verifier cannot check it in polynomial time; deciding it is coNP-hard. Reduction: for a CNF F, let alpha be the read-once CNF over occurrence-copies of the variables (a DNNF), and let beta be the DNNF AND_i(all copies of x_i are 0, or all are 1). Then alpha OR beta is a DNNF, and it is deterministic iff F is unsatisfiable. If the verifier accepts a claimed d-DNNF without checking, soundness fails deterministically. For x1 OR x2, the d-DNNF counting pass gives 1, but the true value is 3/4. For AND_{i<=m}(x_i OR y_i) it gives 1 versus (3/4)^m. Inside thm:certenv's KLM estimator, a fake d-DNNF piece makes the top-down sampler draw from D*phi/Z instead of D*cov/Lambda. Then E W = sum_x D(x)C(x)sum_j phi_j(x)/cov(x) >= p; in the x1 OR x2 example W is 1 always, against p=3/4. So the lower bound claimed to hold without the proof is also unsound.

**Proposed fix.** Require determinism certificates: a P-refutation of c_i AND c_j for each pair of children of every OR-node, as the sum rule already requires. Alternatively, accept only forms whose determinism is syntactic: decision-DNNF, OBDD, or SDD with the vtree and prime partition checked. Unverified 'd-DNNFs' would then be treated as plain DNNFs and estimated through thm:sis.

### 3. [major] sec-part2.tex, thm:sis(c) ('clipping at 3 hat D(E) and running the stopping rule gives a (1 +- eps) estimate'), used by thm:pcis-sound ('Pr[B_v | history] <= delta_v by ... thm:sis')

**Problem.** Part (c) gives a point estimate, but thm:pcis-sound needs an interval that is valid with probability 1-delta_v. Two gaps follow. (i) Clipping lowers the mean, and the proof only bounds the drop: E[min(Cw, 3 hat D)] is somewhere in [(1-eps/8)q, q]. An interval for the clipped mean therefore has no valid upper end. Since the prover writes the sample size, it can force a tight interval that sits below q. Simulation (sis_clip.py): n=1, eps=0.5, E a tautology, C=x1, q=1/2. The counter fails with the allowed probability eps/16 and returns 1e-6. The clipped mean is 0.4842, and the KL interval from 2e6 samples at delta=0.01 is [0.4817, 0.4868], which misses q=0.5. (ii) hat D(E) is never defined. If it is one counter call with confidence eps/(16n), it underestimates D(E) with a probability tied to eps rather than delta_v. Clipping at a too-small level then has unbounded downward bias.

**Proposed fix.** Report [3 hat D * l, 3 hat D * u / (1 - eps/8)]. Compute hat D(E) with one FPRAS call at accuracy 1/(4n) and confidence delta_v/2, and charge that to delta_v. Then hat D >= 0.57 D(E), so good paths are never clipped. Alternatively, run every counter call at confidence delta_v/(4n N_max). Then, with probability 1-delta_v/2, no call fails, no clipping occurs, and the KL interval is valid on that event. State (c) as an interval guarantee and cite it as such in thm:pcis-sound.

### 4. [major] sec-part2.tex, thm:certenv, definition of R ('closure under decomposable products and finite unions of subcubes, OBDDs, SDDs, d-DNNFs and ... affine subspaces, together with DNNFs via thm:sis') and its proof

**Problem.** The proof samples j proportional to D(E_j) and x ~ D|E_j, so it needs exact masses and exact samplers for each E_j. The closure as stated contains elements where neither is available. A finite union of subcubes taken as a single E_j is a DNF, whose exact mass is #P-hard. A product of unions of affine subspaces, or affine x DNNF on disjoint blocks, has no exact mass, no polynomial flattening (s^t pieces), and no DNNF form, so thm:sis does not apply either. DNNF pieces have only FPRAS masses and weighted samples, so 'x has density D(x)cov(x)/Lambda' and '0 <= W <= Lambda' fail. The phrase '(plus FPRAS overhead)' does not repair this. The time bound also drops the log log K term of thm:envelope(iv). The hypotheses 'D product with rational marginals' and 'D uniform for affine pieces' are left implicit.

**Proposed fix.** Define R as decomposable products of atoms: subcubes, OBDDs, SDDs, certified d-DNNFs, and affine subspaces under uniform D. Allow unions only at the top-level OR_j E_j. For DNNF pieces use a weighted KLM: precompute hat Lambda_j, draw j with probability hat Lambda_j / hat Lambda, get (x, w_j) from thm:sis, and set W = C(x) w_j hat Lambda / (hat Lambda_j cov(x)). By thm:sis(b), E W = D(C AND union E_j) exactly. On the good event W <= ~3 hat Lambda, so apply the bias-corrected interval of the previous finding. Add the log log K term and state the distribution hypotheses.

### 5. [major] sec-part2.tex, def:pcis rule proposal / prop:proposal ('a seed law P_R on {0,1}^r with computable pmf and an exact sampler'), cited by thm:pcis-sound

**Problem.** Soundness needs the sampler's law to equal the stated pmf, and a polynomial-time verifier cannot check this when both are supplied as programs. Take C with a unique satisfying x*, so p=D(x*)=2^-n. Let r=n, psi=phi=id, and tau=1. The pmf claims P_R is uniform, but the 'sampler' always outputs x*. Then W = min(D(x*) 2^n, 1) = 1 on every draw, and the certified lower bound is about 1, far above p. thm:pcis-sound says it holds 'for every string pi', so it fails for the system as defined.

**Proposed fix.** Require P_R in a format from which the verifier itself derives both the pmf and the sampler. Examples: product distributions, autoregressive tables or models run by the verifier, and smooth, decomposable, deterministic probabilistic circuits with ancestral sampling. Equivalently, quantify 'every choice of the other objects' only over (psi, phi, tau).

### 6. [minor] sec-part2.tex, thm:sis(b) ('zero iff E|rho,x_i=c is unsatisfiable'; 'multiply the weight w by S/A_{x_i}')

**Problem.** The walk is undefined when S=0. This happens at the root when E is unsatisfiable. It can also happen at a reachable prefix when some marginals are 0 or 1: with q=(1/2,0) and E=x_2, step 1 proceeds because E|x_1 is satisfiable, and at step 2 S = 0*A_1 = 0. The text does not say what to do if the counter returns 0 on a satisfiable branch. 'Every law of the counter's errors' also needs a causality condition: the counter output at step i must not depend on the walk's coins from step i onward. Pre-drawing all outputs, as the proof does, assumes this. The identity itself was verified exactly, including history-dependent counters.

**Proposed fix.** Set w=0 and stop when S=0; this keeps E[C w]=D(C AND E) exact. Replace a zero output on a satisfiable branch with any positive value. Substitute constants for variables with q_i in {0,1}. State the conditional-independence assumption on the counter.

### 7. [minor] sec-part2.tex, prop:calculus

**Problem.** The hypotheses are incomplete. The mono rule, proposal leaves and downgraded nodes return intervals with lower end 0 or upper end +infinity, so they must not occur on any derivation. A statistical leaf with q_v=0 can only return an infinite-ratio [0,u], and the ratio of [0,0] (from refute or exact zeros) is undefined. Otherwise the proof is correct: a sum or convex combination has ratio at most the maximum of its children's ratios, and products multiply ratios. A random test on 20000 trees found no violations, and (1+eps/(2d))^d <= e^{eps/2} <= 1+eps for eps<=1.

**Proposed fix.** Add the hypotheses: every derivation uses only sum, split and prod nodes; deductive leaves are exact; statistical leaves have q_v>0; and the ratio of [0,0] is defined as 1.

### 8. [minor] sec-part2.tex, def:pcis ('a confidence budget delta_v and a sample size written in the argument'; envelope via thm:boxes; 'checks every certificate')

**Problem.** The verifier is not polynomial-time against adversarial arguments. A sample size written in binary can be exponential in |pi|. Sequential stopping has no cap. Rejection sampling inside a box that has zero or tiny mass, with an estimated mass that happens to be positive, does not terminate in polynomial time. The definition also never says what happens when a deductive certificate fails; only failed domination proofs are covered. In split, 'C_v => l' should be a checked P-proof.

**Proposed fix.** Write sample sizes in unary, or impose a global budget T=poly(|pi|,|C|). Cap stopping and rejection loops, and give the node [0,+inf) on timeout, which is sound. A failed deductive certificate should make its node [0,+inf) or make the verifier output [0,1]. In split, write C_v |-_P l.

### 9. [minor] sec-part2.tex, paragraph 'Sandwiches' ('for every gate g ... checked gate by gate ..., each check an OBDD operation')

**Problem.** The setting allows unbounded fan-in AND/OR gates as well as XOR and threshold gates. For fan-in k, the check U_{a1} AND ... AND U_{ak} => U_g is coNP-hard even with a common variable order: take each U_{ai} to be a clause OBDD and U_g empty, which decides CNF unsatisfiability. No rules are given for XOR or threshold gates, and the base case for input gates is not stated. The inductive soundness for AND, OR and NOT is correct, and so is the gap-sampling cost.

**Proposed fix.** Binarize the circuit first, so that the prover supplies OBDDs for the intermediate gates. Add XOR rules: L_{a xor b} => (L_a AND not U_b) OR (not U_a AND L_b), and (U_a AND not L_b) OR (not L_a AND U_b) => U_{a xor b}. Handle threshold gates through binarized adders or sequential counters. State L_{x_i} = U_{x_i} = x_i.

### 10. [minor] sec-part2.tex, bullet 'Planted unions' ('K <= (overlap)/min_j Pr[G_j|T_j]')

**Problem.** 'Overlap' is never defined. Under the natural average reading, Lambda/D(union T_j), the bound is false. Counterexample (checked exactly with codimension 8): T_1 = {x_A = 1}, T_2 = {x_A' = 1} with |A \ A'| = |A' \ A| = 1, G_1 = [x_u' = 1], G_2 = [x_u = 1], where u' is the variable in A' \ A and u the one in A \ A'. Both conditional probabilities are 1/2 and K=4, but the average overlap divided by 1/2 is 8/3.

**Proposed fix.** Define overlap as c_max = max_x |{j : x in T_j}|. Then p >= (min_j g_j) * Lambda / c_max, so K <= c_max / min_j g_j, which is tight in the example.

### 11. [minor] sec-part2.tex, bullet 'Hidden triggers'

**Problem.** 'Resolution needs exponential size for dense linear hashes' is stated as a fact, but the cited section only shows that the DRUP proofs found by Glucose grow. That is not a resolution lower bound. 'Through two differently built XOR-trees for the same parities' does not say what the test compares. The Monte Carlo cost 2^{|A|} K / eps^2 assumes uniform D; in general it is K / (D(x_A=a) eps^2). For the multiplier variant, 'a SAT solver produces a refutation' is optimistic, since CDCL is notoriously weak on multiplier miters.

**Proposed fix.** Cite a resolution lower bound under stated hypotheses (for example a width-based bound for sparse expanding M), or write 'empirically, CDCL proof size grows exponentially'. Spell out the XOR-tree test. Give the cost for a general product D.

### 12. [minor] sec-part2.tex, section opening ('complete exactly when the rarity ... has a short explanation') and the paragraph before thm:sis ('The Meel--de Colnet FPRAS ... removes the dispersion, through a Knuth-style sequential sampler')

**Problem.** 'Exactly when' claims a characterization, but no converse is proved. PCIS is also complete through prod plus mc leaves on syntactically decomposed products, without any R-envelope of small K. The sequential sampler is the standard Jerrum-Valiant-Vazirani counting-to-sampling reduction combined with Knuth's weighting. It is not part of [meel2026dnnf], and the wording suggests it is.

**Proposed fix.** Replace 'exactly when' with 'whenever' and point to thm:certenv. Reword the attribution: 'combined with the self-reducibility sampler (JVV) with Knuth-style weights [knuth1975], the FPRAS of [meel2026dnnf] removes the dispersion'.

