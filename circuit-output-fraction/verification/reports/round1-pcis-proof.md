# Round 1 referee report: pcis (proof lens)

**Verdict.** Needs major fixes, and contains one false claim. The core soundness argument (thm:pcis-sound) and prop:calculus are correct, given that each node satisfies its own guarantee. Two such guarantees are missing: the verifier cannot check d-DNNF determinism in polynomial time, and thm:sis gives no valid interval. thm:certenv's class R is broader than its proof covers. The threshold example's K=O(sqrt n) is false as stated.

**What was checked.** I re-derived every step in sec-part2.tex lines 1-188, using the definitions in sec-setting.tex and sec-envelopes.tex.

**thm:pcis-sound.** The union bound over B_v with Pr[B_v | history] <= delta_v is valid. It also holds when nodes are created adaptively, provided the delta_v come from a fixed summable schedule. Interval arithmetic through SUM, PROD, SPLIT and MONO with nonnegative endpoints is inclusion-monotone. The downgrade-to-lower-bound argument is correct for thm:envelope, thm:boxes and prop:proposal nodes. For integer-valued phi, supp Phi = {phi >= 1}, so C_v |-_P supp Phi is exactly domination.

**prop:calculus.** Sums and convex combinations with exact weights never exceed the worst child ratio, and products multiply ratios. Induction over derivations gives (1+eta)^d, and (1+eps/(2d))^d <= e^{eps/2} <= 1+eps for eps <= 2.5.

**Variance formula and the (10/9)^m example.** The relative variance (D(E)/p)E[phi|E]E[1/phi|C]-1 matches (Z/p)E[1/phi|C]-1. For one block x v y with edge weights alpha, beta, the relative second moment is (2/9)(3 + r + 1/r) with r = beta/alpha. Its minimum is 10/9, at r = 1, so (10/9)^m-1 is optimal over reweightings.

**thm:sis(a).** #E' = (prod b_i)D(E) holds once smoothing and range-restricted comparators are used.

**thm:sis(b).** I checked exact unbiasedness by enumeration in Fractions: n=6, DNNF (x0 v x1)(x2 v x3)(x4 v x5), random rational marginals, a random C, and arbitrary adversarial positive counter outputs on satisfiable prefixes. E[Cw] equals D(C&E) exactly. A martingale argument shows the identity also holds against adaptive counters.

**thm:sis(c).** The per-step factor is in [(1-a)/(1+a), (1+a)/(1-a)] with a = 1/(4n). The product over n steps lies in [0.600, 1.667] for every n >= 1 (minimum and maximum at n=1). The paper's e^{±2.1a} per step gives e^{±0.525} = [0.5916, 1.6905], which is inside [0.58, 1.70]. The bad mass is 2n·eps/(16n) = eps/8, by applying (b) pathwise to f = C·1_bad. The clip 3·D̂ >= 2.25·D(E) exceeds 1.70·D(E). The range/mean of the clipped variable is O(K).

**thm:certenv.** The KLM identities hold for pieces with exact mass and an exact sampler: density D(x)cov(x)/Lambda, 0 <= W <= Lambda, and E[W] = D(C ∧ ∪E_j).

**Sandwich rules.** Induction for AND, OR and NOT (the L ⊆ g^{-1}(1) ⊆ U invariant) is correct. The sample bound is correct: relative accuracy eps·p/g on Pr[C | U\L] needs O(g·D(U\L)/(eps²p²)) <= O(D(U\L)/(p·eps²)) samples.

**Planted unions.** The bound holds once "overlap" is defined.

**Citation.** The Meel–de Colnet entry is correct: SODA 2026, pp. 5978–6010, arXiv:2406.18224 (https://arxiv.org/pdf/2406.18224, https://www.cs.toronto.edu/~meel/publications/b2hd-MdC26.html).

**Tilting numerics.** I computed exact DP tails and optimised theta. With unit weights, uniform D and n=800, p≈3e-125 gives K≈19.3. With random integer weights in [1,10], K≈32. I also built an integer-weight family with K = Theta(n).

**Repository check.** experiments/ contains no arguments table, proof-size figure or arguments.json, and nothing produces "K=37, p=4e-125".

All scratch scripts are in /tmp/claude-0/-home-user-AI-works/02f29707-9759-5ff3-9757-46e1f8b0fdfe/scratchpad (tilt.py, tilt4.py, tilt5.py, sis.py).

## Findings

### 1. [major] sec-part2.tex, def:pcis rule EXACT ("C_v is (or P-provably equivalent to) a d-DNNF"); same issue for "d-DNNFs" in the class R of thm:certenv

**Problem.** "Checked by the verifier" is impossible in polynomial time for d-DNNF. Determinism (the children of every OR gate are pairwise inconsistent) is a semantic property. Checking it is coNP-hard: two children that are OBDDs over different variable orders already make it so. If the verifier takes the d-DNNF claim on trust, soundness fails. Example: D uniform, C = x1, R = (x1 AND x2) OR (x1 AND x3). R is decomposable and P-trivially equivalent to C AND (x2 OR x3); take C_v equal to that circuit. The d-DNNF formula gives 1/4 + 1/4 = 1/2, while the true value is 3/8, so [1/2, 1/2] misses q_v with probability 1. Even simpler: R = x1 OR x1 gives 1 instead of 1/2. In thm:certenv, the sampler for D|E_j and the mass D(E_j) of such a piece are likewise wrong. E[W] can then exceed p, which makes the lower bound unsound.

**Proposed fix.** Choose one of three repairs. (1) Restrict EXACT and R to syntactically deterministic forms: decision-DNNF, OBDDs, and SDDs whose prime partitions the verifier checks with SDD apply. (2) Require, for every OR gate of a claimed d-DNNF, P-refutations C_a AND C_b |-_P bottom for each pair of children. This amounts to unfolding the d-DNNF through the SUM rule. (3) For envelope use, replace cov(x) and the exact conditional sampler by the derivation count phi and Q_phi from thm:envelope. That estimator is unbiased without determinism, with K := Z/p instead of D(E)/p.

### 2. [major] sec-part2.tex, thm:sis(c) as used in the proof of thm:pcis-sound ("Pr[B_v|history] <= delta_v by ... thm:sis")

**Problem.** thm:sis(c) states only an accuracy (completeness) guarantee: "a (1±eps) estimate". thm:pcis-sound needs an interval that contains D(C∧E) with probability ≥ 1−delta_v for every C and every error behaviour the FPRAS guarantee allows. Clipping at 3·D̂(E) lowers the mean by up to (eps/8)·D(C∧E). A KL or stopping-rule interval for the clipped mean therefore bounds E[clipped], not D(C∧E). Its upper end falls below the target with probability tending to 1 as N grows, whenever the bias is realized. The bias may be realized because the paper allows any counter error law consistent with the FPRAS guarantee. In addition, the event that D̂(E) is accurate, which justifies the clip level, is not charged to delta_v. D̂(E) is never defined.

**Proposed fix.** Add an explicit soundness clause to thm:sis. Define D̂(E) as an FPRAS call with accuracy 1/4 and confidence delta_r. Let η = 2n·(per-call failure probability), which equals eps/8 with the paper's parameters. Run a level-delta_s KL interval [ℓ, u] on W' = C·min(w, 3D̂)/(3D̂) ∈ [0, 1]. Output [3D̂·ℓ, 3D̂·u/(1−η)]. This contains D(C∧E) with probability ≥ 1 − delta_r − delta_s, for every C and every counter error law that respects the FPRAS guarantee per call. Set delta_v = delta_r + delta_s. When domination is not proved, the lower end 3D̂·ℓ remains valid without the inflation.

### 3. [major] sec-part2.tex, examples after thm:certenv, "Thresholds with side conditions ... give K=O(sqrt n) (prop:tilting)"

**Problem.** The claim is false as stated, for two reasons. (i) It omits the side condition: K = Z_theta/p = (Z_theta/D(w·x ≥ θ)) · (1/Pr_D[G | w·x ≥ θ]). For any G that is rare given the threshold event, for instance G = x_{n+1} AND ... AND x_{n+r} on fresh variables, K grows by 2^r. (ii) prop:tilting is proved only for S = sum of {0,1}-valued blocks, that is unit weights with integer t. For general integer weights the bound fails. Counterexample: D uniform, m variables of weight 1, m variables of weight W = 10m, n = 2m, θ = W(m−1) + m + 1. The event is exactly "all heavy variables are 1", so p = 2^{-m}. The optimal tilt gives K = 56, 110, 214, 415 for n = 50, 100, 200, 400. That is K = Theta(n), above (4/3)(2·sqrt n + 1) = 20, 28, 39, 55. (iii) prop:tilting requires the exact tilt with E_Q S = t, which is generally irrational. The text instead uses a rational β with no perturbation argument. (iv) Exact computation of Z requires β^{w_i}, whose bit length is polynomial only for polynomially bounded weights.

**Proposed fix.** Restate for unit weights, or {0,1} blocks: K <= e^{1/8}·(4/3)(2·sqrt n + 1) / Pr_D[G | S >= t]. Here β is any rational with |log β − θ*| <= 1/sqrt n. The perturbation adds at most a factor e^{1/8}, since log Z is convex with second derivative at most n/4. Require t integer and E_D S <= t < k_+. For general integer weights, either drop the √n claim or prove a weight-dependent bound. K = Theta(n) already occurs with weights <= 5n. Require weights in unary for exact Z.

### 4. [major] sec-part2.tex, def:pcis rule ENVELOPE ("an envelope Phi (def:envelope) with C_v |-_P supp Phi"), together with the thresholds example

**Problem.** def:envelope allows only literal, 0/1-constant and box leaves, so every admissible phi is integer-valued and C ⇒ supp Phi is the right domination certificate. The thresholds example instead uses the soft envelope beta^{w·x−θ}. That envelope is not representable under def:envelope: it needs rational constants beta^{w_i}. For such a phi, supp Phi is the whole cube, so C ⇒ supp Phi certifies nothing. The correct certificate is C ⇒ [phi >= 1], here C ⇒ [w·x >= θ]. As written, the example is not an instance of def:pcis, and naively extending the rule to real-valued phi would be unsound for upper bounds (thm:envelope(iii) gives only a lower bound).

**Proposed fix.** Extend def:envelope with nonnegative rational constant leaves, or with a product-form exponential leaf. Make the ENVELOPE rule require a P-proof C_v |-_P [phi >= 1]. For integer-valued phi this is the same as supp Phi. For the tilted envelope it reduces to C |-_P [w·x >= θ], which is the cutting-planes proof the example mentions. Add the tilted envelope (with exact Z and its sampler) to the list of estimators in the rule.

### 5. [major] sec-part2.tex, thm:certenv, definition of R ("closure under decomposable products and finite unions of ...") and its proof ("sample j ∝ D(E_j), x ~ D|E_j")

**Problem.** The proof needs exact D(E_j) and an exact sampler for D|E_j for every piece. R, being closed under unions, contains DNFs, for which exact D(E_j) is #P-hard. It also contains unions of affine subspaces, and products of unions with affine leaves, for which neither an exact mass nor the thm:sis route exists. The DNNF-representable members can go through thm:sis, but then only approximate masses D̂(E_j) are available. The proof never explains how to choose j or compute Lambda in that case; "plus FPRAS overhead" does not cover it. So completeness on K_P(m,K), with K defined through the true D(E_j), is not proved for the class as defined. If nested unions are handled by derivation counting instead, the cost is governed by Z(E_j) >= D(E_j), which can be exponentially larger. Example: AND_{i<=m}(x_i OR y_i) has Z = 1 but D = (3/4)^m.

**Proposed fix.** Define R_0 as decomposable products of base pieces with exact mass and an exact conditional sampler: subcubes, OBDDs, SDDs, certified d-DNNFs, and affine subspaces when D is uniform on their variables. Allow unions only at the top level, which KLM handles. Treat DNNF pieces with this estimator: choose j with probability D̂_j/Λ̂; draw (x, w) from the thm:sis walk on E_j; set Y = C(x)·w·Λ̂/(D̂_j·cov(x)). By thm:sis(b) applied to f = C/cov, E[Y] = D(C ∧ ∪_j E_j) exactly. On the good event Y <= (1.70/0.75)·Λ̂, so clipping and inflating as in the thm:sis fix gives completeness with K ≈ Λ/p. For nested unions with non-DNNF leaves, use the derivation-count envelope and define K := Z/p.

### 6. [minor] sec-part2.tex, thm:certenv vs def:pcis (affine pieces, KLM estimator) and the hidden-triggers remark "an affine envelope handles them"

**Problem.** Affine-subspace pieces and the cov-based KLM estimator are not among def:pcis's statistical rules, because def:envelope leaves are only literals, constants and boxes. So "the PCIS verifier" as defined cannot run thm:certenv's procedure with affine pieces.

**Proposed fix.** Add "exact leaves" to def:envelope: any piece with an exactly computable mass and an exact sampler for D conditioned on it, for example affine subspaces under uniform D. With such leaves, phi = sum_j 1_{E_j} = cov reproduces KLM, and the rest of the theory goes through unchanged.

### 7. [minor] sec-part2.tex, thm:certenv running time "O(K log(1/δ)/ε^2)·(|C|+m) (plus FPRAS overhead for DNNF pieces)"

**Problem.** The bound cites thm:envelope, but thm:envelope(iv) gives O(K(log(1/δ) + log log K)/ε²). The FPRAS overhead is multiplicative, not additive: each sample landing in a DNNF piece costs 2n FPRAS calls, each at accuracy 1/(4n) and confidence ε/(16n).

**Proposed fix.** Either include the log log K term or cite the DKLR stopping rule, which avoids it. Write the DNNF cost as O(K log(1/δ)/ε²)·(|C| + m + 2n·T_FPRAS(|E|, 4n, 16n/ε)).

### 8. [minor] sec-part2.tex, thm:sis(a) ("replacing each literal by a comparator on ⌈log2 b_i⌉ fresh bits")

**Problem.** #E' = (prod_i b_i)·D(E) holds only under two conditions. First, the fresh bits y_i must belong to the variable, shared by every occurrence of x_i and ¬x_i, not be fresh per occurrence. Second, both polarities must exclude the out-of-range values [b_i, 2^{⌈log2 b_i⌉}). If ¬x_i is mapped to the plain negated comparator [y_i >= a_i], the out-of-range strings are counted and #E' is wrong whenever b_i is not a power of two.

**Proposed fix.** Specify x_i ↦ [y_i < a_i] and ¬x_i ↦ [a_i <= y_i < b_i] over one shared block y_i per variable, each an OBDD of size O(log b_i). Smoothing then guarantees that every model of E' has every y_i < b_i, which gives (prod b_i)·D(x) preimages per x.

### 9. [minor] sec-part2.tex, thm:sis(b) ("zero iff E|ρ,x_i=c is unsatisfiable")

**Problem.** With rational marginals in {0,1} the walk can divide 0 by 0. Example: E = x1 AND x2 with q_2 = 0. Then E|x1=1 is satisfiable, so A_1 > 0 is forced at step 1 even though its true value is 0. At step 2, S = D_2(1)·A_1 + D_2(0)·A_0 = 0·A_1 + 1·0 = 0. The positivity condition should concern D-positive extensions, not satisfiability of E.

**Proposed fix.** Require A_c = 0 if and only if E'|ρ, x_i=c is unsatisfiable, where E' is the comparator-substituted DNNF (equivalently, D(E|ρ, x_i=c) = 0), which is still linear-time decidable. Alternatively, first substitute the constants for variables with q_i ∈ {0,1}.

### 10. [minor] sec-part2.tex, paragraph before thm:sis ("The Meel–de Colnet FPRAS ... removes the dispersion, through a Knuth-style sequential sampler") and the proof of (b)

**Problem.** The sentence reads as if the sequential sampler comes from the FPRAS paper. In fact the counting-to-sampling reduction for self-reducible problems is Jerrum–Valiant–Vazirani, and the unbiasing weight correction is standard sequential importance sampling. The citation of meel2026dnnf itself is correct (SODA 2026, pp. 5978–6010).

**Proposed fix.** Write "combining the Meel–de Colnet FPRAS with the self-reducibility sampler of [jvv1986], made exactly unbiased by Knuth-style weights [knuth1975]". jvv1986 is already in refs.bib.

### 11. [minor] sec-part2.tex, examples, "Hidden triggers" ("Resolution needs exponential size for dense linear hashes ... (sec:experiments)")

**Problem.** This is stated as a theorem but backed only by a pointer to experiments, and that evidence does not exist in the repository: tables/arguments.tex, figures/fig_proofs.pdf and experiments/results/arguments.json are absent (the LaTeX shows "table pending"). In any case, the growth of DRUP proofs produced by a CDCL solver is not a resolution lower bound. The known lower bounds (Urquhart, Ben-Sasson–Wigderson, Ben-Sasson–Impagliazzo for random k-XOR) concern sparse expanding systems. The BSW size–width tradeoff exp(Ω((w−w0)²/N)) gives nothing here, because the Tseitin encoding of dense rows introduces N = Theta(k²) auxiliary variables. Smaller issues: "Monte Carlo 2^{|A|}K/ε²" assumes uniform D. "Two differently built ⊕-trees for the same parities" does not say what the test is. Multiplier-based tests are notoriously hard for CDCL solvers, so "a SAT solver produces a refutation" is optimistic there.

**Proposed fix.** Soften to: "In our runs, CDCL/DRUP proofs grow exponentially in k; we expect resolution to need exponential size". Either cite an applicable lower bound or state it as a conjecture, and add the missing experiment output. Replace 2^{|A|} by 1/D(x_A = a), and spell out the ⊕-tree test.

### 12. [minor] sec-part2.tex, examples, "numerically K=37 at n=800, p=4·10^{-125}"

**Problem.** No script or result file in experiments/ produces this number. The only n=800 threshold run (speedup.json) has p = 7.8e-27 and K ≈ 17.5, and its interval misses p ("contains": false; possible at delta = 0.05, but worth a look). For unit weights, uniform D and n = 800, optimal tilting at p ≈ 3e-125 gives K ≈ 19.3. With random integer weights in [1,10], it gives K ≈ 32. So 37 is plausible for some weighted instance but cannot be reproduced.

**Proposed fix.** Add the script and state the weights, the distribution and θ, or remove the number. Separately, re-check the n=800 tilting run that misses p.

### 13. [minor] sec-part2.tex, examples, "Planted unions ... K <= (overlap)/min_j Pr[G_j|T_j]"

**Problem.** "Overlap" is never defined. With the natural definition the bound is correct: sum_j D(T_j) <= sum_j D(T_j ∧ G_j) / min_j Pr[G_j | T_j] = overlap·p / min_j Pr[G_j | T_j].

**Proposed fix.** Define overlap := sum_j D(T_j ∧ G_j)/p = E_D[#{j : x ∈ T_j ∧ G_j} | C = 1], which is at most the maximum multiplicity.

### 14. [minor] sec-part2.tex, paragraph "Sandwiches"

**Problem.** The gate-by-gate induction is correct for binary AND, OR and NOT, and the sample bound O(D(U\L)/(p·ε²)·log(1/δ)) is correct. Three gaps remain. (i) The base case is missing: L = U = x_i at inputs, and constants. (ii) sec-setting allows ⊕ and threshold gates, which have no rules here. (iii) sec-setting allows unbounded fan-in. For a k-ary AND, checking (AND_i U_{a_i}) ⇒ U_g is a conjunction of k same-order OBDDs. That check is coNP-hard in general, since clauses are linear-size OBDDs in any order, so it is not "an OBDD operation". The notation also switches between U_out \ L_out and U \ L.

**Proposed fix.** State the base case. Binarize the circuit, or have the certificate supply OBDDs for intermediate partial conjunctions, so that each check is a two- or three-operand apply. Add ⊕ rules: L_{a⊕b} ⇒ (L_a ∧ ¬U_b) ∨ (¬U_a ∧ L_b) and (U_a ∧ ¬L_b) ∨ (¬L_a ∧ U_b) ⇒ U_{a⊕b}. Otherwise restrict the paragraph to {∧, ∨, ¬}-circuits.

### 15. [minor] sec-part2.tex, def:pcis rules SPLIT/PROD/notation and prop:calculus

**Problem.** Several unstated conventions and requirements. (i) The literal form of SPLIT, "C_v ⇒ ℓ gives q_v = D(ℓ)·q_{v|ℓ}", needs a P-proof C_v |-_P ℓ, and the verifier must check that each child circuit is the restriction C_v|_{x=c}. (ii) q_x, the marginal, clashes with q_v, the node target. (iii) F |-_P G needs the Tseitin auxiliary variables of F and G to be disjoint. (iv) PROD needs C_v = C_1 ∧ C_2 syntactically. The "Hidden independence" example therefore has to pass through a one-child SUM node (a P-proof of C ⇔ AND_j C_j) before PROD. It is expressible, but should be said. (v) prop:calculus is correct, but MONO, PROPOSAL and downgraded nodes have ratio ∞, so the hypothesis implicitly excludes them from root derivations; REFUTE leaves [0,0] count as tight; e^{ε/2} <= 1+ε needs ε <= 2.5.

**Proposed fix.** Add "with a P-proof C_v |-_P ℓ" and "the verifier forms the restrictions itself". Rename the marginal to q_i or D(x=1). Note the auxiliary-variable convention. Say that equivalence is applied through a one-child SUM. In prop:calculus, add "no MONO, PROPOSAL or downgraded node on any derivation; [0,0] is tight; ε <= 1". Optionally, let a node intersect the intervals from several rules, so that a MONO upper bound and a PROPOSAL lower bound can be combined soundly by a union bound.

### 16. [minor] sec-part2.tex, section opening ("complete exactly when the rarity of C(x)=1 has a short explanation")

**Problem.** Only the "if" direction is proved (thm:certenv). Nothing shows that every circuit on which PCIS is complete has a short envelope-style explanation, and arguments built from SUM, SPLIT and PROD trees need not take that form.

**Proposed fix.** Replace "complete exactly when" with "complete whenever".

