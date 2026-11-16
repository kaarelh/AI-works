# Second check of the part lower-bounds

Reader: the second checker of this part (16 November 2026). Object: `proofs/lower-bounds.md` ("the file") and the text of this part in `note.md`: Section 4 (N1, N2, N2a, N2b, N2c, N5, N6, N2d) and, in Section 6.1, the paragraphs "Theorem N3" and "What S2 needs". The note is generated from `research/sections/lower-bounds.md` with the replacements of `research/orchestration/patches.py`; I compared the generated text (`note.md`, lines 174–247 and 352–356) with the source. Two patches touch this part: the R2 constant in Section 4.5 and the pointers in the Section 6.1 block. Nothing in `note.md`, the section source or the proof file was edited.

Scripts of my own, written from the statements in the file and not copied from `proofs/code/`:
* `verification/code/lower-bounds_second_exact.py` → `.out`: exact or rational computations for Propositions 3.7, 3.9, 3.10, 5.6, 5.7, the constant of Theorem 3.3(3), the example for Theorem 3.3(5), and the arithmetic of Proposition 7.2 and N2d (runs in 4 s).
* `verification/code/lower-bounds_second_ab.py` → `.out`: Protocol AB (Theorem 3.3), its fault count (Proposition 3.8) and the rehearsal-only variant (Proposition 3.9), implemented literally on 16 random small classes with scaffolds whose inputs depend on the answers. The training is simulated (300 runs per case); the failure and fault counts of each deployed function are computed exactly (10 s).
* `verification/code/lower-bounds_second_ab_rerun.py` → `.out`: a rerun with R = 20 000 of the one case whose z-score (3.28) looked high. It gave z = 1.55.

All assertions in all three scripts pass.

## 1. Statements examined line by line

Selection. From the summary table (Section 0) and Section 12.2 of the file, I took every statement that (a) the note uses or mentions and (b) was seen by its author plus at most one other reader, or was written or changed by the editor after verification. These are Propositions 3.7, 3.8, 3.9, 3.10, 4.6, 5.6, 5.7, 7.2, Remark 1.11, Proposition 1.8(4), the arithmetic of Remark 2.4(4), and Theorem 3.3 in its restated form with the example for its part (5). Propositions 3.8, 3.9, 5.7 and 1.8(4) and Remark 1.11 are not in the note's text; the section source lists them as left out. I checked them anyway, as the task asked.

### Theorem 3.3 (Protocol AB), restated form — CORRECT

* *Well defined.* W_t ≥ w(f) > 0. Members are total functions, so M_t(·|x) is a probability law. For γ < 1/2 an answer of weight above 1 − γ is unique. A step of type (A) never repeats an input, because at an asked input every consistent member agrees and the largest weight is 1. The stopping rule is finite on every path because a is bounded on every path.
* *(1).* W_{t+1} = W_t·M_t(f(x)|x) exactly. At a step of type (A) the factor is ≤ 1 − γ. At a step of type (B) whose audited input x ∈ X₀ is answered against h_t, the factor is ≤ 1 − M_t(h_t(x)|x) < γ. Since W_1 ≤ 1, the inequality a·ln(1/(1−γ)) + b·ln(1/γ) ≤ K ln 2 holds on every path. The question count n_B + K ln 2/γ uses ln(1/(1−γ)) ≥ γ. Verified.
* *(2).* If the run of h_t differs from run_f, the first call j* at which h_t and f disagree has the same input in both runs, because the earlier answers agree. That input therefore occurs in the run of the member f and lies in X₁ ⊆ X₀. P(J = j*) = 1/L, and the step then adds one to b. The steps are predictable and their number is bounded, so E Σ u_t ≤ L·E[b] ≤ L·K/log(1/γ). Verified. This is exactly the point that fails if b counts disagreements outside X₀; the restatement handles it correctly.
* *(3).* For u ≥ 4, γ = u·2^(−u) ≤ 1/4 and log(1/γ) = u − log u. The factor u/(u − log u) + ln 2 has its maximum 2 + ln 2 = 2.693 at u = 4 and decreases after that. Numerical check over u ∈ [4, 200): part C of the `.out`. The maximum with 1 in n_B matters only for K = 0. Verified.
* *(4).* Under L·γ < 1 the induction works: the members that agree with h_t at the first j ≤ L − 1 inputs have weight > 1 − jγ > 0, and such a member has the same next input. The base case holds because the first input does not depend on the answers. Verified.
* *(5), the example.* I replayed it with exact fractions (part G). The first step is of type (B). h_1(9) = 0 with weight 5/9. The audit at input 9 leaves {g₀, …, g₃}. Input 0 is then split 3/4 : 1/4. Then g₀ is identified. (7/8)(1/8) = 7/64 < 1/9. Verified.
* *Simulation.* In part 1 of `lower-bounds_second_ab.out` I ran 64 cases each for X₀ = X and X₀ = X₁. In every case the per-path potential stayed below K ln 2, the mean deployed failure stayed below L·K/(n_B log(1/γ)), and the sharper intermediate inequality E[Σ u_t − L·b] ≤ 0 held within noise (largest z-score +0.61). In these random instances X₁ came out as all of X, so the case X₁ ⊊ X₀ is covered only by the hand example of (5).

### Proposition 3.7 (the rare-points class) — CORRECT

* Given the seed, the transcript and the inputs of the run, the values of f on the unasked points are independent fair bits, and the deployed outcome does not depend on them. This uses the fact that the questions are drawn independently of the answers. A call in U therefore makes the outcome wrong with probability ≥ 1/2.
* P(the run hits U | U) ≥ Lx(1 − Lx/2) with Lx = 4ε|U|/d ≤ 4ε, which gives the factor 1 − 2ε. E|U| = d(1 − q/d)^n.
* The final chain: ln(2(1 − 2ε))·(Ld/(4ε) − 1) ≥ 0.1·K·L/ε − 0.4 is equivalent to (c − 0.4)(Ld/(4ε) − 1) ≥ 0 with c = ln(2(1 − 2ε)) ≥ ln 1.5 > 0.4. This holds because Ld/(4ε) ≥ 2 when ε ≤ 1/8. I first suspected that the additive constant should be −0.69 rather than −0.4; it should not, by this factorisation. The grid minimum of the difference is 0.0055 ≥ 0 (part B).
* Exact check (part B). In four cases I computed the exact Bayes failure of the best deployed system after n μ-distributed questions. It is never below 2ε(1 − 2ε)(1 − q/d)^n, and the least n that reaches failure ε is above the bound of (a).
* (b): the input of call J of a run whose inputs do not depend on the answers is a fresh μ-draw. Correct.
* ln 2/0.1 = 6.93 < 7. Correct.

### Proposition 3.8 (Protocol AB bounds the faults) — CORRECT

* (1): P(the step adds to b | past) = (1/L)·Σ_j P(the run has call j and it is a fault) = v_t/L, with equality. This needs the audited input to lie in X₀, which the hypothesis (the larger X₀, or L·γ < 1 through Theorem 3.3(4)) supplies.
* My simulation tests the identity E Σ v_t = L·E[b] for X₀ = X: 64 cases, largest |z| 3.28. The rerun of that case with R = 20 000 gave z = 1.55, so the identity holds within noise.
* (2): the replacement rule "replace f(x_j) by h(x_j) where they differ" sees only the input and its own count. Truncated after k replacements it is admissible. The run of h coincides with the truncated run unless h has at least k + 1 faults. Markov's inequality gives the bound, conditionally on h, and averaging over h finishes. Correct.
* (3): the arithmetic of Theorem 3.3(3) with β in place of ε. It does not need β < 1. Correct.
* The paragraph "Consequences": I checked K = log(L/(2(2m+1)δ) + 1) ≤ log(L/((m+1)δ)) under L/((m+1)δ) ≥ 16. It reduces to (L/δ)(3m+1)/(2(m+1)(2m+1)) ≥ 1, which holds with room to spare.

### Proposition 3.9 (rehearsal-only variant) — CORRECT

* A split input multiplies the weight by ≤ 1 − γ whatever the answer. A disagreement at an input that is not split multiplies it by < γ. These two facts give the per-path potential, and a + L·b ≤ K ln 2·max{1/ln(1/(1−γ)), L/ln(1/γ)}.
* u_t ≤ α_t + L·P(disagreement of the second kind). On the event "no split call and the runs differ", the first disagreeing call is in the run, is not split, and is audited with probability 1/L. No set X₀ is needed, because h_t is defined everywhere and "split" is defined at every input.
* Arithmetic: γ = ln L/L ≤ 1/e < 1/2, so the plurality answer is the unique answer of weight above 1 − γ. The maximum equals L/ln(L/ln L) for every L ≥ 3, and ln(L/ln L) = 1.0046 at L = 3 (part D), so "exceeds 1 for every L ≥ 3" is true, barely.
* Simulation (part 2 of the `.out`, 12 instances with L = 5): the potential stays below K ln 2 on every path, and the mean failure stays below K·L/(n log₂(L/ln L)).

### Proposition 3.10 (rehearsal on the block class; the editor's, seen by no verifier) — CORRECT

* Every run of the block scaffold has exactly L calls, and its inputs do not depend on the answers. So the question of a round is uniform over the m·N cells and independent of the past. The prior is a product over blocks, and each answer concerns one block, so the posterior is a product too.
* If a_j was asked, the mixture is exact on block j. If not, the posterior is uniform on the N − k unasked cells. A call then makes the mixture answer 1 with probability (N − k)/N·1/(N − k) = 1/N. The failure event is contained in {the run visits the needle} ∪ {the mixture answers 1 somewhere}, which has probability ≤ 2L/N = 4δ.
* P(a_j not asked before round t) = (1 − 1/(mN))^(t−1). Averaging gives ≤ 4δ·mN/n.
* 2mL/δ ÷ (1 − 10δ)mL/(8δ) = 16/(1 − 10δ).
* Independent exact computation (part A). Given k, the failure has the closed form 2[(1 − 1/N)^L − c₀^L] with c₀ = k/N + (N − k − 1)²/(N(N − k)). The chain over k is exact. In seven cases the failure at n = 4mN is ≤ δ, and the least n with failure ≤ δ is 2.40 to 3.65 times mN. For (m, N, L) = (16, 128, 4) this gives 7 480 rounds, the number the file quotes. The worst conditional failure given "unasked" is below 2L/N in every case.

### Proposition 4.6 (S2 with ordinary compute) — CORRECT

* The weights 2^(−2|p|−1) sum to Σ_ℓ 2^ℓ·2^(−2ℓ−1) = 1.
* ξ^(t) ≥ π_{p_D}·D^(t), where D^(t) is the law of the output within b(t) steps; this works because the program runs on fresh coins.
* The potential argument of Lemma 5.1′ gives Σ_t E Σ_z ξ^(t)(z)β_t(z) ≤ L·K ln 2. In rounds that produce no z nothing is asked and the potential is unchanged.
* u_t ≤ min{1, β_t} and mass(D − D^(t)) = τ_D(b(t)) give the display. The Cesàro mean of τ_D(b(t)) tends to 0 when b(t) → ∞. Correct.
* One gap is outside the proposition. The paragraph "What S2 should say" asserts that the additive term "is not uniform over the samplable laws, and by (c) it cannot be". The first half is true of the term in the bound: for each n, a program that idles for b(n) + 1 steps makes the term equal to 1. The second half, that no protocol with ordinary compute can have a uniform rate, is not proved. Proposition 4.4(c) is a statement about domination of laws, not about failure probabilities, and a law whose sampler is slow may also be produced quickly by another program. See finding N-4 for the note's sentence. **GAP** (in that sentence of the paragraph; not in Proposition 4.6).

### Proposition 5.6 (the factor is k + 1) — CORRECT

* (a): the rule applied to f_i ("replace by f₀'s answer at inputs of D_i, at most m times") sees only the input and its own count. If the run of f₀ has at most m calls in D_i, induction shows that the replaced run is the run of f₀. Before each call in D_i the count is at most m − 1. Outside D_i, f_i and f₀ agree. Tolerance of f_i then forces out_{f_i} = out_{f₀}. Markov's inequality and Σ_i c_i ≤ L follow, since the c_i are counted on the one run of f₀. The maximum of N − δN²/B′ is B′/(4δ). Correct. Only the tolerance of the f_i is used, not that of f₀.
* (b)(1): with k_b replacements in block b, Σ k_b ≤ m, at most k_b answers of the block differ from v_b; answers ⊥ count for no value. The block therefore ends with v_b after at most m + 1 + k_b ≤ 2m + 1 calls, the total is ≤ B(m + 1) + m = L, and the run is never cut off. Correct.
* (2) and (3): Lemma 1.10(2) with Δ = p(B, N₀) and M = B. Then B/(4δ) − B = (1 − 4δ)(L − m)/(4(m + 1)δ). Correct.
* I recomputed the table of Section 5.4 (part E): all five rows agree, including the column for R3.

### Proposition 5.7 (robustness curve, human not deterministic) — CORRECT, given Theorem R1

* The bound follows from Pinsker's inequality, the Cauchy–Schwarz inequality over at most L calls, Jensen's inequality twice, and Theorem R1. R1 is needed in the form "expected summed KL along the run of M^(t)". This is the form the note states (Section 3.1: the run of round t is a run of M^(t)), so the use is correct. I did not re-check R1 itself beyond reading its proof in the note.
* The counterexample: δ_Π(β) = min{1, 1/2 − θ + β}, which is concave. The excess failure equals 2θ·(1/n)Σ_t E[w_t].
* My own computation (part F) reproduces the five rows of the table (0.04572, 0.03887, 0.04509 in exact rationals; 0.00343 and 0.00500 in floats). It also shows that for θ = 1/(2√n) the ratio to ln 2/n equals 0.486·√n for n = 100 to 6 400, so it is unbounded. The bound √(ln 2/(2n)) holds in every row.

### Proposition 7.2 (amplification against the failure budget) — CORRECT

* (a), the reduction. Draw k uniformly from [r], simulate z₁, …, z_{k−1} and the scaffold's coins, run the given system, and output its last outcome. This is a deployed system in the sense of Definition 1.3, and its failure is the average over k, which is ≤ F/r.
* Corollary 2.2(1) gives n ≥ L(1 − 4δ)/(4δ) and A ≤ 4F/(1 − 4δ). The case δ = 1/4 gives no bound, which is harmless.
* (b): Theorem 3.1. Note that there n is the expected number under a uniformly chosen member, whereas in (a) it is the number under f₀; A is defined with whichever n the part uses.
* (c): rL/(LK ln 2/δ + 1) = F/(K ln 2 + δ/L); identity checked in part H. The expected number of failed runs is ≤ rδ whether T is drawn afresh for each run or kept.
* (d): checked, under tolerance with failure 0.
* The numbers for L = 1000, δ = 0.01, K = 10⁹ (6.93·10¹³ and 6.93·10⁸; 1.63·10¹³; 7.21·10¹¹ and 7.21·10⁶; 24 000 and 0.24) are reproduced in part H.

### Remark 1.11 (a protocol without coins) — CORRECT

With no seed and f₀ answering, there is one path, and the stopping rule is finite on it, so S is finite. f′ is computable by running Λ against f₀, and K(f′) ≤ K(f₀) + K(Λ) + c. Lemma 1.10(1) with B = X ∖ S and π = 0 applies. When the outcome is the list of answers, the outcomes differ exactly when the run of f₀ leaves S. Correct.

### Proposition 1.8(4) — CORRECT

The patch runs P outside Q and does not halt on Q, so K ≤ K(P) + sep(x; A) + c. TV(δ_⊥, P(·|x)) = 1 − P(⊥|x), and the two laws are mutually singular exactly when P(⊥|x) = 0.

### Remark 2.4(4), the editor's arithmetic — CORRECT

With N₀ = L/(2δ) (and also with ⌈L/(2δ)⌉), p ≤ L/N₀ ≤ 2δ, so the Bayes failure η′p of deploying f₀ unasked is ≤ 2η′δ < δ when η′ < 1/2. The quantity is an average over the prior; see finding N-3.

### Other statements read, not re-derived

I read the proofs of Lemmas 1.5 and 1.10, Theorem 1.6, Corollaries 1.7 and 2.2, Proposition 2.3, Proposition 2.5, Theorem 3.1, Proposition 3.2, Theorems 4.1 and 4.3, Proposition 4.4, Theorem 5.3, Proposition 5.4, Theorems 6.1 and 6.3, and Theorem 7.1. I found nothing wrong, but I did not re-check them as a referee; each was checked by both verifiers. I recomputed only the arithmetic the note quotes from them: Corollary 2.2, Theorem 3.1 Step 4, Theorem 6.1(2) and Theorem 6.3(2).

## 2. Findings on the note's text

Method. For each statement of Section 4 and of the Section 6.1 block I compared hypotheses, constants and quantifiers with the file, checked that each pointer exists and says what the note says, and compared the status words with Section 12 of the file.

All pointers exist and say what the note says: Corollary 2.2, Proposition 2.5, Theorem 3.1, Theorem 3.3, Propositions 3.7 and 3.10, Proposition 5.6, Theorems 6.1 and 6.3, Proposition 7.2, Theorems 4.1 and 4.3, Propositions 4.4 and 4.6. Every constant in the displays matches the file.

Status. Section 12 marks Proposition 3.10, on which the last sentence of the N2c paragraph rests, as checked by the editor only. It has now been checked by me (above). Section 12.2 of the file could record that; the note needs no status change. The other status words agree with Section 12.

Findings, most important first.

**N-1 (prose claims more than is proved).** Section 4.3, after N2c:
> "Random questions cannot match this everywhere: on a class with K rare informative inputs, random calls of runs need n ≥ 0.1·K·L/ε−0.4 for failure ε, a seventh of what R1 guarantees, where K chosen questions suffice (Proposition 3.7 there; found and checked by the two verifiers)."

"This" refers to the guarantee of N2c, 1 + 2.7·K·L/(ε·log₂(L/ε)). Proposition 3.7 exceeds that guarantee only when 0.1 > 2.7/log₂(L/ε), that is when L/ε > 2^27. The file says so itself (Consequences (iii) of Proposition 3.7). Protocol AB as specified does not reach K questions on that class either: it asks the n_B audits after identifying the human (Remark 8 on Theorem 3.3). Two smaller points: the hypothesis ε ≤ 1/8 is missing, and 0.1/ln 2 = 0.144 is more than a seventh, not a seventh. Proposed replacement (with the letter δ of finding N-2):
> "Random questions are not optimal on every class: on a class with K rare informative inputs, random calls of runs need n ≥ 0.1·K·L/δ−0.4 for failure δ ≤ 1/8, more than a seventh of what R1 guarantees, where K chosen questions suffice (Proposition 3.7 there; found and checked by the two verifiers). With the constants proved, this exceeds the bound of N2c only when L/δ > 2^27."

**N-2 (letters, Addendum 3).** Addendum 3 fixes δ for a failure probability and ε for accuracy in total variation. N2c and the sentence after it use ε for the probability of an unfaithful run, while the sentence just before N2c ("in bits like K·L/(δ·log₂(L/δ))"), N2b and N2d use δ for the same kind of quantity. Proposed replacements in the N2c paragraph:
* "and L/ε ≥ 16" → "and L/δ ≥ 16";
* "above 1−ε·log₂(L/ε)/L" → "above 1−δ·log₂(L/δ)/L";
* "unfaithful with probability at most ε after at most 1 + 2.7·K·L/(ε·log₂(L/ε)) questions" → "unfaithful with probability at most δ after at most 1 + 2.7·K·L/(δ·log₂(L/δ)) questions";
* the next paragraph as in N-1.

**N-3 (Bayes risk; quantifier).** Section 4.2:
> "N2 does not bound a Bayes risk: if the prior gives the f_i together under half the weight, deploying f₀ unasked fails with probability below δ."

As written, the sentence can be read as failure below δ for every member, which is false: under each f_i the failure is p ≈ 2δ. Replacement:
> "N2 does not bound a Bayes risk: if the prior gives the f_i together under half the weight, deploying f₀ unasked fails with probability below δ on average over the prior."

**N-4 (S2, uniformity).** Section 6.1, "What S2 needs":
> "this tends to 0 at a rate depending on D, never uniformly."

The term is not uniform over D: for every n, a slow program makes it 1. The file's stronger claim, that no protocol with ordinary compute could have a uniform rate ("by (c) it cannot be"), is not proved; see the GAP under Proposition 4.6. Also, the rate depends on the program p_D, not only on D. Replacement:
> "this term tends to 0 for every such D, at a rate that depends on p_D and is not uniform over all such laws."

**N-5 (tolerance needs failure 0).** Section 4.6, N2d (c):
> "under tolerance of k faults K ln 2 becomes K ln 2/(k+1)."

Proposition 7.2(d) and Proposition 5.2 give exactly this with failure δ₀ = 0. With δ₀ > 0 the failure has the additive term δ₀. Replacement:
> "under tolerance of k faults with failure 0, K ln 2 becomes K ln 2/(k+1)."

**N-6 (amplification prose; class quantifiers, Addendum 3, correction 3).** Section 4.6:
> "By (a), a guarantee for every member saves no human work unless failed runs are allowed: F < 1/4−δ gives amplification below 1. Imitation saves work across runs, at a price: by (c) rehearsal breaks even once K ln 2 failed runs are allowed, and by (b) no protocol does before (1−10δ)·K/(8·log₂(L/(2δ)))."

The arithmetic is right: 4F/(1 − 4δ) < 1 exactly when F < 1/4 − δ, and the break-even of (c) is at F = K ln 2 + δ/L. But the class should be named in each clause. Replacement:
> "By (a), for that class a guarantee for every member saves no human work unless at least 1/4−δ failed runs are allowed in expectation: F < 1/4−δ gives amplification below 1. Imitation saves work across runs, at a price: by (c) rehearsal breaks even once about K ln 2 failed runs are allowed, and by (b) no protocol does so on the classes of N2b before (1−10δ)·K/(8·log₂(L/(2δ)))."

**N-7 (N3, when 2aN questions suffice).** Section 6.1:
> "then n ≥ 2aN, counting n under the zero function; 2aN questions suffice."

Theorem 4.1(3) is for an integer number of questions n ≤ N. Replacement:
> "then n ≥ 2aN, counting n under the zero function; 2aN questions suffice when 2aN is an integer."

**N-8 (N1, class of all programs).** Section 4.1:
> "only partners at total variation 1−1/N, for a further log₂N + 2·log₂log₂N bits (N ≥ 2)."

Proposition 1.8(2) gives total variation at least 1 − 1/N, at log N + 2 log log N + c further bits. Replacement:
> "only partners at total variation at least 1−1/N, for a further log₂N + 2·log₂log₂N + c bits (N ≥ 2)."

**N-9 (optional; wording).** Section 4.3:
> "N2c has no version for a human who is not deterministic"

This can be read as an impossibility theorem. What the file supports is that the proof needs a deterministic human, and that for a human who is not deterministic there is no logarithm to save (N6 against R2; Remark 7 on Theorem 3.3; Section 9, item 2: "none is known"). Suggested:
> "N2c is for a deterministic human; for one who is not, there is no logarithm to save (N6)"

The rest of the sentence ("and its chosen questions …") would stay unchanged.

**N-10 (optional).** Section 4.4:
> "tolerance divides the price by k+1 on both sides"

This is right for the sufficient side in general (R3) and for the necessary side in this example. The file explicitly does not claim that tolerance never lowers the price by more than k + 1 for a given scaffold (end of Section 5.3). Suggested:
> "tolerance divides the price by k+1 on both sides in this example"

I found no other sentence that says more than the statement it cites. The quantifiers of N2, N2a, N2b, N5, N6 and N2d (a), (b) match the file. N2d states that the class grows with r and where (c) is empty, as Addendum 3 asks.

## 3. What I did not check

* Theorem R1 for a general human (part rehearsal-core) and the constant (1 + ε) of R2 (part hellinger-runs, introduced by a patch). I used them as stated in the note.
* R3, R7 and N8, which the note's text of this part cites.
* The reference "Paper 2, Proposition G.5" and the attribution to Cohen, Hutter, Bengio and Russell.
* The literature. I did not read Bshouty (arXiv:1706.03935), Hanneke and Yang (arXiv:1410.0996), Hegedűs, Moshkov or Dasgupta in this session. The attributions in N2 and N2c rest on the reading recorded in Section 11 of the file (by the attack report's author and the editor).
* The coding theorem and the count 2^(k − K(k) + O(1)) after Corollary 4.2. The note does not use the count.
* The statements listed under "Other statements read, not re-derived". They were read, not refereed.
* The proof file's own scripts. I did not rerun them; my scripts are independent re-implementations.
* The exact numbers quoted in the file from other scripts: "between 0.35 and 0.39 times K·L/ε" (Proposition 3.7), "about 0.4·K/ε" (after Proposition 3.9), and the 15-instance simulation after Proposition 3.8.
* In my simulation of Protocol AB, X₁ turned out to be all of X in the random instances. The case X₁ ⊊ X₀ with runs that leave X₁ is covered only by the hand-checked example of Theorem 3.3(5), not by a random test.
