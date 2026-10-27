# Round 1 referee report: boxes-tilting (proof lens)

**Verdict.** sound with minor fixes. I found no false theorem statement and no broken proof among the assigned results (thm:boxes, prop:tilting, thm:janson). The problems are constants, unstated cost terms or hypotheses, one wrong cross-reference, one false runtime claim in the text, and one overclaim in sec-part2 that cites prop:tilting.

**What was checked.** Line-by-line re-derivation, plus numerical checks in my scratch directory /tmp/claude-0/-home-user-AI-works/02f29707-9759-5ff3-9757-46e1f8b0fdfe/scratchpad (boxes.py, tilt2.py, darr.py, jan.py, jan2.py, jex.py).

thm:boxes:
(a) The sampler picks derivation T with probability ŵ(T)/Ẑ. The choice probabilities telescope through Sum and Prod gates, the same way as in lem:envmass. Given T, the density is D(x)1[x|=T]/w(T) with the true masses. This holds because any two leaves of a derivation have a Prod gate as their lowest common ancestor, so decomposability makes the conditionings independent, and rejection sampling is exact.
(b) Hence Q̂(x) = D(x)/Ẑ · Σ_{T∋x} ρ(T), and Ẑ·E W = Σ_x D(x)C(x)·(average of ρ over the φ(x) ≥ 1 satisfied derivations), which lies in [ρmin, ρmax]·p.
(c) ρ is monotone in each m_j, so its extremes are at the interval endpoints, and a max/min-product pass (tree unfolding) gives them. Since m̂_j ∈ [ℓ_j, u_j], we get ρmax ≥ 1 ≥ ρmin.
(d) The δ/2 + δ/2 union bound works because the importance-sampling stage is conditioned on the box estimates.
(e) The ratio bound (1+ε/(4L))^{2L} ≤ e^{ε/2} holds.
(f) Box-estimation cost: r · O(L² R log(r/δ)/ε²) is correct. Rejection-sampling cost per sample: at most L·R·max|B_j| in expectation.
(g) I checked the bias formula by simulating the actual top-down sampler exactly (density ratios G_v: Sum gives a mixture, Prod gives a product, a box gives B/m, a literal gives 1/D(ℓ)). This ran on 1486 random envelopes with box leaves, shared sub-DAGs and random [ℓ_j, u_j] intervals. There were 0 cases with Ẑ·E W / p outside [ρmin, ρmax].
(h) The closing remark (k dense blocks: K = 1, O(k³ R log(k/δ)/ε²) evaluations) matches the theorem with r = L = k.

prop:tilting:
(a) φ_θ ≥ 1[S ≥ t] for θ ≥ 0, and Z_θ is the Chernoff product.
(b) Q_θ makes the g_j independent Bernoulli(p_j e^θ/(1 − p_j + p_j e^θ)).
(c) θ exists: E_{Q_θ}S is continuous and nondecreasing, at most t at θ = 0, and tends to k_+ > t as θ → ∞.
(d) The Poisson-binomial distribution is log-concave. For an integer mean, the mode is t by Darroch's rule.
(e) Chebyshev, the count of at most 4σ+1 integers in the window, σ² ≤ k/4, and p ≥ Z_θ·Q_θ(S = t) are all correct, so K ≤ (4/3)(2√k + 1) holds.
(f) Numerically: 19,609 random instances (k up to 80, including p_j in {0, 1} and tiny p_j) gave a maximum K/bound of 0.38, and the mode was t in every case. For p_j = 1/2 the true worst case is K ≈ 0.75√k, so the bound is about 3.5 times loose but valid.
(g) Darroch's citation (Ann. Math. Statist. 35:1317–1321, 1964) is correct.

thm:janson:
(a) The Harris lower bound holds.
(b) The Boppana–Spencer derivation gives the factor exp(Σ_{j<i, j~i} P(B_i B_j)/(1−ε)) = exp(Δ/(2(1−ε))) when Δ is summed over ordered pairs, which matches Alon–Spencer Thm 8.1.1 and its convention.
(c) Exact enumeration on 3000 random small unate CNFs under random product distributions gave 0 violations. The worst case used 99.9% of the log-width of the interval. With a halved Δ (the unordered-pair sum plugged into the same formula), 591 of 3000 instances violate the bound, so the ordered-pair convention is needed and stated correctly.
(d) Complexity O(Σ|cl_i|² d) in arithmetic operations: each pair costs O(|cl_i| + |cl_j|), and summing symmetrically gives at most 2 Σ_i |cl_i|² d.
(e) The Riordan–Warnke extension is plausible: the one-line modification works for the M·exp form when j ≁ i means disjoint supports.
(f) The example values reproduce: M = 4.34e-7, Δ = 0.3086, interval ratio 1.1669.

Not verified (no network access): whether gkm2010 / gopalan2011fptas cover product distributions with real weights.

## Findings

### 1. [major] sec-part2.tex, 'Thresholds with side conditions' item (cites prop:tilting): 'C=[w·x>=θ]∧G with integer w ... give K=O(√n)'

**Problem.** This is a claim stronger than anything proved. (1) prop:tilting covers only C = [S ≥ t] with unit weights. The mode-at-t and window-counting steps use the unit lattice and do not extend directly to integer weights w. (2) With a side condition G, p = Pr[S ≥ t ∧ G], so K = Z/p = K_tilt · Pr[S ≥ t]/Pr[S ≥ t ∧ G] = K_tilt / Pr[G | S ≥ t]. This is unbounded for arbitrary G; for example, take G an independent rare event. (3) With rational β, θ = log β is not the exact tilt, and the proposition as stated needs the mean to be exactly t (see the prop:tilting finding below).

**Proposed fix.** State the result as K ≤ K_tilt / Pr_D[G | w·x ≥ θ], with K_tilt = O(√n) proved only for unit weights (or prove an integer-weight version separately). Add the hypothesis Pr[G | w·x ≥ θ] ≥ 1/poly(n), and choose rational β with |E_{Q_β}S − t| < 1/(k+2).

### 2. [minor] sec-envelopes.tex, thm:boxes, cost claim and last line of proof: 'relative width at most ε/(4L) ... tight ... thm:envelope(iv) applies ... with ε/3'

**Problem.** The output ratio is (u/ℓ)(ρmax/ρmin) ≤ (1+ε/3)e^{ε/2}. This is at most 1+ε only for ε ≤ 0.5109 (the root of (1+ε/3)e^{ε/2} = 1+ε). At ε = 1 it equals 2.198 > 2. Nothing in the paper restricts ε ≤ 1/2.

**Proposed fix.** Either require ε ≤ 1/2, or use box widths ε/(8L). Then ρmax/ρmin ≤ e^{ε/4}, and (1+ε/3)e^{ε/4} ≤ 1+ε for all ε ∈ (0,1]. The box-estimation cost becomes O(r L² R log(r/δ)/ε²) with a larger constant.

### 3. [minor] sec-envelopes.tex, thm:boxes: 'tight after O(K log(1/δ)/ε²) samples of Q̂'; proof: 'thm:envelope(iv) applies'

**Problem.** thm:envelope(iv) gives N = O(K(log(1/δ) + log log K)/ε²); the log log K term is dropped here. The proof also skips the step showing that the mean of W under Q̂ is still about 1/K. thm:envelope(iv) is stated for an exact sampler of Q_φ, but Q̂ is biased.

**Proposed fix.** Add the log log K term. Add one line: Ẑ = Σ_T ρ(T) w(T) ≤ ρmax·Z, so E_Q̂ W ≥ ρmin p/(ρmax Z) ≥ e^{-ε/2}/K. Then (iv), which only needs i.i.d. [0,1] samples with that mean, applies.

### 4. [minor] sec-envelopes.tex, thm:boxes: 'each costing O(|C|+|Φ|+LR max_j|B_j|) in expectation'

**Problem.** Computing W = C(X)/φ(X) requires evaluating every box leaf at X, not only the at most L boxes in the chosen derivation. That costs Σ_j |B_j|, up to r·max|B_j|, which can far exceed L·R·max|B_j| (for example a DNF of r single-box terms, where L = 1). The stated bound is correct only if |Φ| is understood to include the box circuits, and this is never said.

**Proposed fix.** Write the per-sample cost as O(|C| + |Φ| + Σ_j|B_j| + L·R·max_j|B_j|), or define |Φ| to include the sizes of the box circuits. If the boxes are gates of C, say that they are evaluated together with C in O(|C|).

### 5. [minor] sec-envelopes.tex, thm:boxes: 'If each [ℓ_j,u_j] has relative width at most ε/(4L)'

**Problem.** 'Relative width' is undefined. The bound (1+ε/(4L))^{2L} needs u_j ≤ (1+ε/(4L))ℓ_j. If it is read as (u_j − ℓ_j)/m̂_j ≤ ε/(4L), the factor becomes ((1+η)/(1−η))^L > (1+η)^{2L}, and the stated inequality fails slightly.

**Proposed fix.** Define it as u_j ≤ (1+ε/(4L))ℓ_j, matching the tightness notion in def:sound.

### 6. [minor] sec-envelopes.tex, after thm:boxes: 'a DNF whose terms are products of dense blocks has K≤m (\cref{cor:dfsb})'

**Problem.** Wrong cross-reference. cor:dfsb (component-dense circuits, backbones, cutsets, global variables) does not contain this statement. The DNF's top ∨ is a non-decomposable leaf of probability p, so (a) does not apply. The claim itself is true, by the lem:K argument.

**Proposed fix.** Cite lem:K / prop:dnnf-env instead. For the envelope Σ_j Π_{boxes in term j}, the support of φ is exactly C^{-1}(1) and φ ≤ m, so K = E[φ | C=1] ≤ m.

### 7. [minor] sec-envelopes.tex, prop:tilting statement and proof ('choose θ≥0 with E_{Q_θ}S=t')

**Problem.** Three gaps. (1) The existence of θ is not argued. (2) θ is generally irrational, so Z_θ cannot be computed exactly for the exact tilt. Practical versions use rational β = e^θ (as in sec-part2), but the proof needs the mean to be exactly t. (3) The proposition, and the phrase 'sampled block by block', implicitly assume that the p_j are known exactly and that D conditioned on g_j = b can be sampled.

**Proposed fix.** (1) Add: θ ↦ Σ_j p_j^θ is continuous and nondecreasing, at most t at θ = 0 (since E_D S ≤ t), and tends to k_+ > t, so the intermediate value theorem gives θ. (2) Note the robust version: any θ ≥ 0 with |E_{Q_θ}S − t| < 1/(k+2) still has mode t by Darroch's full rule (I checked this numerically on 20,000 random instances with no failures). Chebyshev centred at the mean then gives the same bound, so rational β suffices. (3) State the assumptions on p_j and conditional samplers explicitly.

### 8. [minor] sec-envelopes.tex, after prop:tilting: 'The same estimator applies verbatim when the p_j are estimated (boxes)'

**Problem.** 'Verbatim' overstates it. φ_θ uses a real constant e^θ, which def:envelope (constants 0 and 1 only) does not allow. Each block needs two boxes, [g_j=1] and [g_j=0], so both p_j and 1−p_j must be at least 1/R, and L = k. The proof of thm:boxes must average ρ with weights instead of counting derivations.

**Proposed fix.** Say 'applies with the bias analysis of thm:boxes': write φ_θ = e^{−θt} Π_j([g_j=0] + e^θ[g_j=1]), require min(p_j, 1−p_j) ≥ 1/R, and use per-box relative width ε/(4k). The weighted average of ρ still lies in [ρmin, ρmax]. Allow nonnegative real constants in def:envelope.

### 9. [minor] sec-envelopes.tex, after thm:janson: 'give p≈4.7·10^{-7} and an interval of ratio 1.17 in one second'

**Problem.** This is false as stated. tables/janson.tex reports 30.8 s for exactly this instance (n = 2·10^5, 6·10^4 clauses, width 12). My rerun of rareprob.janson took 32 s. Also, 4.7·10^{-7} is the geometric-mean estimate, not a known value of p. The certified interval is [4.34, 5.06]·10^{-7}.

**Proposed fix.** Replace with: '...give the certified interval p ∈ [4.34, 5.06]·10^{-7} (ratio 1.17) in about 30 seconds of pure Python'.

### 10. [minor] sec-envelopes.tex, thm:janson statement, proof, and the following remark

**Problem.** (1) The upper bound needs ε_0 < 1; if some D(B_i) = 1 the right-hand side has a division by zero (then M = p = 0 trivially). The code's janson_interval also overflows when ε_0 is near 1. (2) The remark 'relative error O(ε)' for the geometric-mean estimate needs ε_0 ≤ 1 − Ω(1); otherwise Δ/(2(1−ε_0)) is not O(Δ). (3) The proof says 'Flip the variables that occur negatively; then every B_i is a principal up-set {x : x_{S_i} = 1}'. Flipping the negatively occurring variables makes every clause monotone, so B_i = {y_{S_i} = 0}, a principal down-set. This is harmless by symmetry, but wrong as written. (4) 'Computable exactly in time O(Σ|cl_i|² d)' is a count of arithmetic operations; exact rational arithmetic has growing bit lengths.

**Proposed fix.** (1) Add the hypothesis ε_0 < 1. (2) Add 'with ε_0 ≤ 1/2' to the remark. (3) Flip the variables that occur positively instead (then B_i = {y_{S_i} = 1} is an up-set), or complement all coordinates. (4) Say 'arithmetic operations', or 'to any fixed relative precision in floating point'.

### 11. [minor] sec-envelopes.tex, def:envelope / derivations paragraph / lem:envmass, used in the proof of thm:boxes ('φ(x) is the number of derivations satisfied by x')

**Problem.** If a derivation is a sub-DAG ('keeping one child of every Sum gate reached'), the counting identity fails for shared constant-only nodes. Example: Prod(S, S) with S = Sum(1, 1) is vacuously decomposable and computes 4, but has only 2 sub-DAG derivations. A sampler that memoises S would also choose its child only once. Nodes with nonempty support cannot be reached twice, so this is an edge case only.

**Proposed fix.** Define derivations on the tree unfolding of Φ (each occurrence chooses independently), or require Prod children to have nonempty support, after folding constant subcircuits into a single constant leaf.

