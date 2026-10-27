# Round 1 referee report: envelopes (counterexample lens)

**Verdict.** The mathematics is sound and needs only minor fixes. Lemma lem:envmass, Theorem thm:envelope (i)-(iv), Lemma lem:K and the variance formula are correct up to the edge cases, constants and wording listed below. Separately, the implementation has one major soundness gap: it computes the "exact mass Z" in float64, so it can return a confidently wrong interval such as [0,0] when p > 0.

**What was checked.** I read sec-envelopes.tex in full, plus sec-setting.tex, the thm:sis passage and the surprise subsection of sec-part2.tex, the intro bullets on envelopes, and the code in rareprob/stats.py, envelope.py and nnf.py. My scripts are in /tmp/claude-0/-home-user-AI-works/02f29707-9759-5ff3-9757-46e1f8b0fdfe/scratchpad (klcheck.py and exp1.py through exp6.py).

Checks by hand:
(1) Lemma lem:envmass. The bottom-up mass pass is correct by decomposability and the product form of D. The top-down sampler picks a derivation T with probability w(T)/Z (I checked the telescoping by induction over Sum, Prod and leaf nodes). Its output law is D(x)φ(x)/Z. The claim that each literal is set at most once is correct: two paths in one derivation can only split at a Prod gate. The same argument shows that a node with nonempty support is reached at most once per derivation, which gives the O(|Φ|) cost per sample.
(2) Theorem (i) and (ii). E W = p/Z, and W lies in [0,1] under domination. The KL interval is valid by Hoeffding 1963 Thm 1, and stats.py uses the correct orientation KL(mean||m).
(3) Theorem (iii) is correct for integer-valued φ.
(4) Theorem (iv). The inequality KL(a||b) ≥ (a-b)²/(2max(a,b)) holds: on a grid with b from 1e-12 to 1, and a including 0 and 1, the minimum of the difference is exactly 0. The bound u/ℓ ≤ (1+ε/4)/(1-ε/4) ≤ 1+ε holds for ε ≤ 2. The implicit step bounding max(m, μ̂) ≤ 2μ̂ goes through with c around 128. The levels δ_j sum to δ.
(5) Lemma lem:K. The identity is correct, and so are K ≤ m for DNFs and the formula relvar = (Z/p)E[1/φ|C=1] - 1 ≤ K - 1.

Numerical checks:
- The sampler's empirical law on a small DAG envelope (non-smooth sums, a repeated child, n=4, non-uniform q) matched D·φ/Z with total variation 0.0019 at 4e5 samples, and the bottom-up Z matched brute force (4.16).
- The relative variance of E = ⋀(x_i ∨ y_i), brute-forced at m=3, is 0.37174 = (10/9)³ - 1, with K = (4/3)^m.
- Optimising over ∨-weights shows that 10/9 per clause is the minimum, reached only at unit weights, and only for uniform D.
- The sequential KL procedure uses N·ε²/(K·log(1/δ)) of about 35 to 56 samples for K from 10 to 1e4, with no misses in 80 runs.
- With zero variance but K = k, the KL procedure still needs a number of samples linear in k.
- In the code, the envelope mass underflows or rounds down in float64, which breaks coverage.

## Findings

### 1. [major] code/rareprob/envelope.py: Envelope.masses and envelope_estimate (the implementation of Lemma lem:envmass / Theorem thm:envelope(ii), whose hypothesis is 'exact mass Z'); paper sec-experiments 'exactly as in the proofs'

**Problem.** Z is computed as a float64 product and sum, so 'exact mass' does not hold, and soundness fails deterministically, not with probability δ. Test 1: C = AND of 1100 variables, uniform D, envelope = Prod of the 1100 literals. Z = 2^-1100 underflows to 0.0, and envelope_estimate returns [0,0] ('envelope mass 0'), which excludes the true p > 0. Test 2: whenever W ≡ 1, the KL upper end is u = 1, so the output's upper end is Z_float itself; if Z rounds down, p lies outside the interval. With q = 0.3 the AND circuits at n = 600, 610 and 614 (subnormal range) all miss, and 1 of 25 AND circuits with n ≤ 80 (normal range) misses by about 1e-16 relative. The paper never states its arithmetic model.

**Proposed fix.** State in Lemma envmass and Theorem thm:envelope that Z and the Sum-gate choice probabilities are computed in exact rational arithmetic, or in the log domain with outward rounding. In the code: keep log-masses, inflate the output to [Zℓ(1-η), Zu(1+η)] with η ≈ |Φ|·2^-52, and output U = 0 only when Z is symbolically 0 (for example a ZERO root), never when it underflows.

### 2. [minor] sec-envelopes.tex, the derivation paragraph after Definition def:envelope ('A derivation of Φ is a subcircuit ...', 'φ(x) is the number of derivations'), together with Lemma lem:envmass ('one bottom-up pass') and thm:envelope(iv) ('each costing O(|C|+|Φ|) time')

**Problem.** Decomposability allows a Prod gate to have repeated children with empty support. Example: h = Sum(1,1) and Φ = Prod(h, h, [x1]); the supports ∅, ∅, {1} are pairwise disjoint, so Φ is decomposable. Then φ = 4·[x1], but Φ has only 2 derivations in the stated 'subcircuit' sense. The count is right only on the tree unfolding. Chaining h_{k+1} = Prod(h_k, h_k) gives φ ≡ 2^{2^k} from a circuit of size O(k), so Z has 2^k bits. Then the bottom-up pass, evaluating φ(X), and the O(|C|+|Φ|) per-sample cost are not polynomial in the bit model.

**Proposed fix.** Define derivations as proof trees of the tree unfolding. Note that only empty-support nodes can be reached twice in one derivation. Require that every Prod child with empty support be a constant leaf; then φ ≤ 2^{|Φ|} and masses have poly(|Φ|, bits of q) bits. State the convention that a 0 leaf is never satisfied and a 1 leaf always is.

### 3. [minor] sec-envelopes.tex, Definition def:envelope (leaves 'constants 0,1') vs thm:envelope(iii) ('For real-valued φ clip W at 1') and sec:tilting (φ_θ = e^{θ(S-t)})

**Problem.** The definition allows only 0/1 constants and unweighted Sum gates, so φ is integer-valued. Yet the soft envelopes of sec:tilting need the real constants e^{-θt} and e^θ - 1, and (iii) refers to real-valued φ. For real φ, the clipped variable min(W,1) has mean ≤ Pr[C=1 ∧ φ>0]/Z, so only the lower end Zℓ remains valid; the claim in (iii) of 'a valid interval for Pr[C=1 ∧ φ>0]' fails at the upper end. A related point: the DNF envelope Σ_j Π_{ℓ∈T_j}[ℓ] is decomposable only if no term repeats a variable, so terms like x∧x must be deduplicated and x∧¬x dropped.

**Proposed fix.** Allow nonnegative rational constant leaves (weights). Lemma envmass is unchanged: constant leaves contribute their value to w(T) and set no variable. Restate (iii): for integer-valued φ, [Zℓ,Zu] is a valid interval for Pr[C=1 ∧ φ>0]; for general φ, Zℓ (from clipped W) is a valid lower bound on p, and Zu is valid only under domination. Require DNF terms to be consistent and free of duplicate literals.

### 4. [minor] sec-envelopes.tex, Theorem thm:envelope(iv) and its proof ('j = O(log K), whence the log log K term')

**Problem.** The starting sample size N_0 is unspecified (the code uses 16 or 1024). With a fixed N_0, the first good stage is j* ≈ log2 K + log2 log(1/δ) + 2·log2(1/ε) + O(1), not O(log K). So log(1/δ_{j*}) = log(1/δ) + O(log log K + log log(1/ε) + log log log(1/δ)), and the stated bound O(K(log(1/δ) + log log K)/ε²) omits a log log(1/ε) term; take K = 2, δ fixed and ε → 0. Also, 'stops in time' and 'all intervals valid' each hold with probability 1-δ, so jointly only 1-2δ. And ε ≤ 2 (in practice ε ≤ 1) is needed for (1+ε/4)/(1-ε/4) ≤ 1+ε but is not stated.

**Proposed fix.** Start the doubling at N_0 = ⌈c·log(2/δ_1)/ε²⌉. Then j* = O(log K) and the stated bound holds; otherwise add the log log(1/ε) term. Assume ε ≤ 1, and either run the stopping and validity parts at δ/2 each or say '1-2δ'.

### 5. [minor] sec-envelopes.tex, remark after Lemma lem:K: 'so what costs samples is the dispersion of the number of derivations, not its mean' (and its echo in sec-part2 before thm:sis)

**Problem.** The formula for the relative variance is correct, but the procedure of thm:envelope(iv) uses Hoeffding-KL intervals, which ignore the variance. Its cost is Θ(K·log(1/δ)/ε²) even when Var W = 0. Counterexample: Φ = Sum of k copies of the same term T, with C = T. Then W ≡ 1/k and the relative variance is 0, yet at ε = 0.1, δ = 0.05 the paper's KL procedure used 128, 32768, 131072, 1.05e6 and 4.19e6 samples for k = 1, 4, 16, 64 and 256. So within this paper, the mean (K) is what costs samples. Likewise, thm:sis removes the ambiguity factor E[φ|E] (its K' = D(E)/p), not just the dispersion.

**Proposed fix.** Rephrase along these lines: 'With the KL interval the cost is K. A variance-adaptive interval (empirical Bernstein, Maurer-Pontil 2009) costs O(relvar·log(1/δ)/ε² + K·log(1/δ)/ε), so only the dispersion enters the ε^-2 term. thm:sis removes the factor E[φ|E] altogether.'

### 6. [minor] sec-envelopes.tex, the example 'E = ⋀_{i≤m}(x_i ∨ y_i) ... has relative variance (10/9)^m - 1 under every reweighting of its ∨-edges'

**Problem.** The value (10/9)^m - 1 is reached only by the unweighted envelope; every other reweighting is strictly worse. Per clause, with weights a = 1 and b = t, the factor is (2/9)(2 + t + 1/t) + 2/9 ≥ 10/9. The value also holds only for uniform D, which the remark never states. For q_i = q the per-clause factor is 2(2 - 1.5q)/(2 - q)², for example 1.0249 at q = 0.1 and 1.0744 at q = 0.9.

**Proposed fix.** Write: 'under uniform D, the relative variance is at least (10/9)^m - 1 under every reweighting of its ∨-edges, with equality for unit weights (while K = (4/3)^m).'

### 7. [minor] sec-envelopes.tex, surprise-accounting paragraph ('explains log2(1/Z) bits ... at polynomial cost ... exact computation explains everything, possibly at exponential cost in |Φ|')

**Problem.** (a) Z can exceed 1, for example a DNF with many overlapping terms. Then log2(1/Z) < 0, K > 1/p, and the envelope is worse than Monte Carlo. (b) Exact computation costs time linear in |Φ|; what can be exponential is |Φ| relative to |C|. (c) Hilton's surprise accounting charges the explanation's own description length. This paragraph does not charge |Φ| (sec-part2 does charge |π|), so the attribution overstates the match. (d) 'At polynomial cost' assumes domination has already been established; checking domination in general is coNP-hard.

**Proposed fix.** Assume Z ≤ 1 without loss of generality by falling back to φ ≡ 1 (the 'anything ↦ 1' rule), so the cost is min(K, 1/p). Write 'with |Φ| possibly exponential in |C|'. Write 'in the spirit of surprise accounting', or add the |Φ| (or |π|) term. Say 'once domination is certified (syntactically or by proof)'.

### 8. [minor] sec-envelopes.tex, first sentence: 'All our upper-bound-capable methods, with and without a prover, are instances of one estimator.'

**Problem.** Overclaim. The Harris-Janson sandwich (thm:janson, in this same section) is deterministic and not an importance sampler. thm:sis is a Knuth-style sequential sampler steered by FPRAS outputs; it is not W = C/φ with an exact Q_φ. The annealing estimators with Las Vegas samplers (in the abstract) are product-of-ratios estimators.

**Proposed fix.** Write 'Most of our upper-bound-capable methods are instances of one estimator' and name the exceptions (Janson, thm:sis, annealing).

### 9. [minor] sec-envelopes.tex, Lemma lem:K and the sentence before it ('when C is itself a deterministic DNNF')

**Problem.** 'Support' means a variable set (sv) in Definition def:envelope but the set {φ>0} in Lemma lem:K. 'Number of derivations' should be 'number of derivations satisfied by x'. 'Random accepted input' must mean x ~ D conditioned on C=1, not uniform over accepted inputs, and the lemma needs p > 0. 'Deterministic DNNF' is used without being defined; sec-setting defines DNNF but not determinism.

**Proposed fix.** Write 'whose positivity set {φ>0} equals C^{-1}(1)', 'the expected number of satisfied derivations of x ~ D|C=1', add the hypothesis p > 0, and define determinism (children of ∨ pairwise inconsistent) in sec-setting.

### 10. [minor] sec-envelopes.tex, thm:envelope(ii) and (iv) and Definition def:envelope (edge cases Z = 0 and p = 0; the undefined 'Hoeffding-KL interval')

**Problem.** If Z = 0, Q_φ is undefined; under domination this forces p = 0, but the theorem does not say what to output. If p = 0 < Z, then K = ∞ and the doubling procedure of (iv) never halts, so as stated it is not an efficient procedure in the sense of def:sound. Zu can exceed 1. The 'Hoeffding-KL interval' is defined nowhere in the paper. The cost O(|C|+|Φ|) per sample assumes the sampler of Lemma envmass (plus O(n) to fill unset variables), not an arbitrary 'exact sampler'.

**Proposed fix.** Add: if Z = 0, output [0,0]. Run (iv) with a sample cap and return the current (still valid) interval when the cap is reached. Clip to [0,1]. Define [ℓ,u] = {m ∈ [0,1] : N·KL(μ̂||m) ≤ log(2/δ)}, valid for independent [0,1] variables by Hoeffding 1963 Thm 1. Write 'using the sampler of Lemma envmass' in (iv).

### 11. [minor] sec-setting.tex, 'Pushing negations to the inputs gives the negation normal form (NNF) of C: an {∧,∨}-circuit over literals, with at most two copies of every gate'

**Problem.** This holds only for {∧,∨,¬} circuits. A ⊕ gate of fan-in k needs Θ(k) ∧/∨ gates per polarity. Threshold gates with large weights have no small NNF; the project's own nnf.py keeps them as opaque 'X' nodes. The envelope section's references to DNNFs and supports rely on this definition.

**Proposed fix.** Restrict the 'at most two copies' claim to {∧,∨,¬}. Say that ⊕ expands to O(fan-in) gates, that thresholds with polynomially bounded integer weights expand via a counter DP, and that other gates stay opaque (and can be handled as boxes).

