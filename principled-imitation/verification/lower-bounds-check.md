# Referee report, line by line: `research/prove/lower-bounds.md`

Part `lower-bounds`: what no protocol can do (note Section 4 and the lower bounds of Section 6; labels N1, N2, N3, N5, S2). Referee's role: check every proof, recompute every constant, test the edge cases, compare the words with what is proved. The checked file is not changed by this report.

## 0. What was checked, how, and the result

**Checked.** Every numbered statement of `research/prove/lower-bounds.md` (559 lines) with its proof; its summary table; its Sections 8 to 11. Section 4 of `note.md` (the lead's Theorems N1 and N2). The statements N1, N2, N3, N5, S2 and the "sharper form" of R3 in `research/candidate-theory.md`, about which the file makes claims.

**How.** Each proof was read line by line and each constant recomputed by hand. Three scripts were then written and run (Section 5 below; `verification/code/lower-bounds_*.py`, outputs `*.out`): they evaluate every chain of simplifications in its exact form on grids, compute exact minimax values in the range the corollaries talk about (the prover's enumeration stops at N₀ = 5), and simulate Protocol AB literally on classes and scaffolds other than the prover's. The prover's two scripts were rerun; they reproduce the output quoted in the file (32 s and 3 s, numpy 2.5.3, scipy 1.18.1).

**Result.** Every result of the file holds in the form in which it is used, and all its constants are confirmed. What has to be corrected:

1. One claim made in words has no proof in the file: that Protocol R (rehearsal with random questions) is *not optimal* (Corollary 3.4(5); Section 10, item 4). The file proves that the *bound* for Protocol R is not the minimax rate. A lower bound for Protocol R itself is missing. It is supplied here (Proposition A1, Section 4): on a class of K bits Protocol R needs at least 0.1·K·L/ε − 0.4 questions where K chosen questions suffice.
2. The display of Theorem 6.3 is false for part of its stated range (when both brackets of its last expression are negative). Its two consequences are correct.
3. The paragraph "In words" after Theorem 7.1, and the last paragraph of Section 4.2 of `note.md`, say more than is proved in three places.
4. Theorem 3.3 (Protocol AB) is correct and the count of questions holds. Its statement needs three clarifications (which inputs X₀ must contain; what the human is asked; what has to be computed).
5. Two items listed as open are not open: Protocol AB has a fault-tolerant version by its own proof (Proposition A2), and the question of Section 9, item 6 is settled by the counting theorem the file itself quotes.
6. Small points: hypotheses to add in Propositions 1.8 and 5.2 and Definition 1.1; Remark 3.5 is weaker than Proposition 5.4(a) of the same file gives.

Conventions are those of the file: log is log₂, ln is the natural logarithm; n is the (expected) number of questions put to the human; L is the horizon; δ or ε is the allowed failure probability; K = log(1/w(f)); "function" means a deterministic sampler. Verdicts: CORRECT; MINOR (correct after a small fix, given exactly); GAP (a step is missing; filled where possible); WRONG.

## 1. Verdicts, statement by statement

### Section 1 of the file (setting, N1)

**Definitions 1.1 to 1.4. MINOR.** Definition 1.1 fixes the number T of steps in advance. Protocol AB stops after a number of steps that depends on the data and, when K is not known, has no bound known in advance; so the file's own upper-bound protocol is not literally a protocol in the sense of its Definition 1.1. Fix: "a number of steps that is finite on every path (a stopping rule)". Every proof goes through unchanged: Lemma 1.5 is an induction over the steps; Lemma 1.10 uses only the path on which f₀ answers; the identity KL = E[N_i]·kl(θ) in Theorem 6.1 needs E[N_i] < ∞, which the hypothesis of that theorem gives.

**Lemma 1.5. CORRECT.** The coupling by a common seed and common uniform variables is valid: before the first step τ with a question outside A, questions and answers of the two interactions are equal by induction, and the question at step τ is a function of equal data. The hypotheses used are A1 (each answer is a fresh draw from P(·|x_t)) and A3 (the seed is independent of the human's coins). If samplers are semimeasures, the outcome ⊥ has to be added to the enumeration of Y; nothing else changes.

**Theorem 1.6 (N1). CORRECT.** (1) is data processing: ô is a function of (r, D, z, ρ, s), and (z, ρ, s) has the same law under P and P′ and is independent of (r, D). (2): Q̂_P(G) + Q̂_{P′}(G′) ≤ Q̂_P(G) + Q̂_P(G′) + γ ≤ 1 + γ. (3) is the triangle inequality. (4) is (3) and (2) for one call. Two remarks. The membership of P and P′ in H is not used in the proof; it is what makes the conclusion a statement about "every member of H". The hypothesis x ∉ A in (4) is not needed (for x ∈ A the first claim is empty and the second has no instance). The bound 1 − γ is attained (Remark 1.9(b), recomputed: failure 0 under f and 1 − γ under f′).

**Corollary 1.7. CORRECT.** Recomputed: s_f + s_{f′} = 2 − R(f(x)) − R(⊥) − R′(f′(x)) − R′(⊥); with R′(f′(x)) ≤ R(f′(x)) + γ and R(f(x)) + R(f′(x)) ≤ 1 − R(⊥) this is at least 1 − γ − R′(⊥), and by symmetry at least 1 − γ − R(⊥). The two inequalities of Theorem 1.6(4) and Corollary 1.7 were also tested on 200 000 random pairs of answer laws at their exact total variation.

**Proposition 1.8. MINOR.** The three claims are correct. Two hypotheses are used and not stated. In (1) the patch f_x(x′) := f(x′) followed by the symbol 1 needs Y to be closed under appending a symbol (true for Y = {0,1}*, which the universal class presupposes). In (2) Y must have at least N elements. Fix: state Y = {0,1}* in the proposition. Claim (3) is right and does refute the last sentence of the candidate's N1 for a sampler with P(y|x) > 0 for all y; for a function that sentence is correct, by (1). In (2) the index i of an answer with P(y_i|x) ≤ 1/N cannot in general be computed from programs for P and x, so it has to be coded; the term log N + 2 log log N is what this construction costs.

**Remark 1.9. CORRECT.**

**Lemma 1.10 (patch family). CORRECT.** Σ_i π_i ≤ n because the sets B_i are disjoint. (1): on the event {i ∉ hit(r), o_i ≠ o₀}, of probability (1 − π_i)Δ_i, the deployed outcome g₀ is the same under f₀ and f_i and differs from o₀ or from o_i. (2): the left side is at least E[(M·1[g₀ ≠ o₀] + V·1[g₀ = o₀])]/(N + M) ≥ E[min{M, V}]/(N + M) = E[V]/(N + M) since V ≤ M. The independence of r and (z, ρ), used for E[V] = Σ_i (1 − π_i)Δ_i, is part of Definition 1.2 (the questions are asked before the run is drawn); Remark 2.4(1) says so.

### Section 2 of the file (N2)

**Definition 2.0. CORRECT.** (L/N₀)(1 − L/(2N₀)) ≤ p ≤ L/N₀ (union bound and the second Bonferroni inequality); checked on 1 ≤ N₀ < 200, 1 ≤ L < 60.

**Theorem 2.1 (N2, exact form). CORRECT.** It is Lemma 1.10 with B_i = {i}, Δ_i = p and M = L. Independent check: by symmetry the exact minimax over all protocols with a given expected number of questions is a small linear programme (Section 5.1). On 42 parameter triples the exact value is never below the bound, and the bound is attained at (N₀, L, n) = (3, 2, 1) and (3, 2, 1.5).

**Corollary 2.2 (constants). CORRECT.** Recomputed. (1) With N₀ = L/(2δ): p ≥ 2δ(1 − δ), N₀ + L = N₀(1 + 2δ), so n ≥ N₀(1 − 4δ)/(2(1 − δ)) ≥ N₀(1 − 4δ)/2 = L/(4δ) − L for δ ≤ 1/4; for δ > 1/4 the right side is negative. (2) With N₀ = ⌈L/(2δ)⌉ and δ ≤ 1/6: δ(N₀ + L)/L < 1/2 + δ/L + δ ≤ 1/2 + 2δ and p ≥ (L/N₀)(1 − δ), so n ≥ N₀(1/2 − 3δ)/(1 − δ) ≥ L/(4δ) − 3L/2. (3) n ≥ N₀(3 − 3ε)/(4 − 2ε). K ≤ log(L/(2δ) + 2) is right. All three were also checked on grids in their exact form N₀ − δ(N₀ + L)/p.

**Proposition 2.3 (tightness). CORRECT.** The protocol's failure is (1 − n/N₀)p for every needle and 0 for f₀. The exact least expected number n*(δ) of questions, by linear programming, lies between the two bounds in all nine cases computed; for example (L, δ) = (4, 0.02): 46 ≤ 48.75 ≤ 50, and (2, 0.005): 98 ≤ 99.25 ≤ 100. In the nine cases n*(δ) = L/(4δ) − c·L with c between 0.28 and 0.50, so the constant 1/4 is exact for this class and the correction −L is of the right order.

**Remark 2.4. CORRECT.**

**Proposition 2.5 (the human available during the run). CORRECT.** E[V] ≥ E|set(z)| − E|S(r, z)| ≥ N₀p − n. For N₀ = ⌈L/√(2δ)⌉: N₀p ≥ L − L²/(2N₀) ≥ L − L√(2δ)/2 and δ(N₀ + L) ≤ L√(2δ)/2 + δ + δL, which give n ≥ L(1 − √(2δ) − δ) − δ. Checked on a grid (least slack 0.02).

### Section 3 of the file (the dependence on K)

**Theorem 3.1 (the factor K). CORRECT.** Step 1: (1/N)(Σ_{i ≤ k} i + (N − k)k) = k − k(k − 1)/(2N) ≥ N(κ − κ²/2) ≥ Nκ/2 (verified in exact arithmetic for N < 60). Step 2: for a_j ∉ S the transcript does not depend on a_j, and the number of values a_j ∉ S at which the common outcome is wrong is at least |set(z) ∖ S| when N − k ≥ 2L, whether the outcome is 0, 1 or ⊥. Step 4: with N = L/(2δ), n ≥ (mN/2)(1/2 − 5δ) = (1 − 10δ)·m·L/(8δ). Independent check: for one block the exact Bayes value as a function of the expected number x of questions is the lower convex envelope E₁(x) of finitely many points, and for m blocks and n questions it is E₁(n/m) (the prior is a product and E₁ is convex). The inequality p(1 − 2L/N − 2x/N) ≤ E₁(x) holds at all grid points for seven pairs (N, L). The exact least number of questions per block for failure δ is close to L/(8δ) (for (L, δ) = (2, 0.01): 25.12, against the bound 22.5 and Proposition 3.2's 25.25), so the constant 1/8 of the theorem is exact as δ tends to 0.

**Proposition 3.2 (tightness). CORRECT.** E min(a_j, N − 1) = (N − 1)(N + 2)/(2N) ≤ (N + 1)/2 (exact arithmetic); the failure is (1 − ⌈m/2⌉/m)·p ≤ p/2 ≤ δ.

**Theorem 3.3 (Protocol AB). MINOR: the proof is correct and the count of questions holds; the statement needs three clarifications.** See Section 2.1 below for the full discussion. Recomputed: (1) each question multiplies the consistent weight W by M_t(f(x)|x); the factor is at most 1 − γ at a step of type (A) and less than γ at a step of type (B) with a disagreement; W₁ ≤ 1 and W_t ≥ w(f), so a·ln(1/(1 − γ)) + b·ln(1/γ) ≤ K ln 2. (2) the first call j* of the run of h_t at whose input h_t and f differ exists whenever the two runs differ, the inputs up to j* are common, and J = j* has probability 1/L. (3) with u = log(L/ε) ≥ 4: γ = u·2^(−u) ≤ 1/4, log(1/γ) = u − log u ≥ u/2, and n_B + K ln 2/γ ≤ 1 + (u/(u − log u) + ln 2)·K·L/(ε·u), where u/(u − log u) + ln 2 ≤ 2 + ln 2 = 2.6932 (maximum at u = 4; limit 1 + ln 2 = 1.6931). Fixes:

* (a) Replace "a set that contains every input Π can produce" by "a set that contains every input that Π can produce when its calls are answered by arbitrary elements of Y". The run of h_t is not a run of f, and h_t must be defined at every input of its own run.
* (b) In (3) put n_B := max{1, ⌈L·K/(ε·(u − log u))⌉}. The maximum matters only for K = 0 (w(f) = 1, so the class is {f}), where the stated n_B is 0 and contradicts n_B ≥ 1. The bound is unchanged.
* (c) Add to the statement what Remarks 1, 3 and 4 say in passing: the human is asked single calls only; at steps of type (A) the input is chosen by the protocol where the posterior is split, it need not occur in any run of the human system, and A2 (f ∈ H as a function on all of X₀) is used there; A3 (fresh coins) is used only at steps of type (B). To decide whether a step is of type (A) the protocol must search all of X₀ for an input with a split posterior; this is a finite computation when X₀ and the class are finite and is not computable in general (for an infinite X₀ the statement "no input is split" is a universal statement).

**Corollary 3.4. Items 1 to 4 CORRECT; item 5 as used in Section 10 GAP (filled).** Items 1 and 2 restate Theorems 3.3 and 3.1. The VC dimension of the block class is m for N ≥ 2: the inputs (j, 1) are shattered (take a_j = 1 or 2), and two inputs of one block are never both answered 1. Item 3: K = m·log(L/(2δ)) ≤ d·log(L/δ), so 1 + 2.7·d·L/δ questions suffice for the block class. Item 4: the refutation of "every protocol needs c·K·L/ε" is valid for the reading "for all K, L, ε there is a class all of whose members have complexity K", since then K is known to the protocol. Item 5 says "Protocol R's bound … is not optimal: Protocol AB removes the logarithm", which is right as a statement about the bound. Section 10, item 4 goes further ("Protocol R is not optimal for functions"), and so does the description of this part given to the referees ("rehearsal with random questions is not optimal in K measured in bits"). What is proved is that the *guarantee* L·K ln 2/δ of Protocol R exceeds the minimax number of questions by a factor of order log(L/δ). That Protocol R itself needs that many questions on some class of K bits is not proved in the file, and the file's own hard instance does not show it: on the block class Protocol R needs between 3.4 and 3.8 times m·N questions in a simulation (Section 5.2, part D), which is of the order K·L/(δ·log(L/δ)), the order of the lower bound. The gap is filled by Proposition A1 (Section 4.1): on the rare-points class Protocol R needs at least 0.1·K·L/ε − 0.4 questions.

**Remark 3.5 (small K). MINOR.** Both numerical claims are right (checked). The exception "apart from the range 2^K = O(δL)" is not needed. For N₀ ≤ L use Lemma 1.10(1) in place of Lemma 1.10(2) (this is Proposition 5.4(a) of the file): failure ≤ δ for f₀ and f_i gives π_i ≥ 1 − 2δ/p, hence n ≥ Σ_i π_i ≥ N₀(1 − 2δ/p) ≥ N₀(1 − 3.2δ), because p ≥ 1 − 1/e. Together with the remark's bound N₀/2 for L ≤ N₀ ≤ L/(8δ) this gives: for every K with 2^K − 1 ≤ L/(8δ) the worst case is between (2^K − 1)·min{1 − 3.2δ, 1/2} and 2^K − 1, without exception. (For L/(8δ) < 2^K − 1 < L/(2δ) the needle class with ⌊L/(8δ)⌋ cells, which has fewer members, still gives a bound of order 2^K.)

**Remark 3.6. CORRECT.** For the two citations see Section 6.

### Section 4 of the file (N3, S2)

**Theorem 4.1 (N3, exact form). CORRECT.** (1) is Lemma 1.10(1) with Δ = D_i(Q_i) = 1. (2) follows: 2η ≤ π_i for every i and Σ_i π_i ≤ n. (3): the success probabilities of the protocol were recomputed exactly for all N ≤ 6 and all n: they are 1/2 + n/(2N) for f₀ and f_i under shift i, and at least that for f_j, j ≠ i. (4): the candidate's N3 ("being right with probability > 1/2 … needs a question in each Q_i") is indeed false for a randomised protocol: one question at a uniformly chosen region gives probability 1/2 + 1/(2N) everywhere. The correct statement is (2): n ≥ 2ηN, and n ≥ (1 − 2δ)N for success probability 1 − δ.

**Corollary 4.2 and the remark on the constant. CORRECT.** The counting statement used in the remark (the number of objects of prefix complexity at most j is 2^(j − K(j) + O(1))) is right; a short proof is in Section 4.4 below.

**Theorem 4.3 (N shifts, L critical calls). CORRECT.** The proof uses a refinement of Lemma 1.10 that the lemma does not state: Σ_c π_{i,c} ≤ n_i, with n_i the expected number of questions in region i. It holds by the same argument (the number of cells of region i that are hit is at most the number of questions in region i). Say so in the proof.

**Proposition 4.4 (S2). CORRECT.** (a) ξ ≥ π_i·D_i pointwise because Σ_i π_i ≤ 1. (b) is right. (c): a law sampled by an almost surely halting program is computable; the sequence z_j with ξ(z_j) < 4^(−j) is computable, and D(z_j) := 2^(−j) gives D(z_j)/ξ(z_j) > 2^j; the universal mixture dominates every samplable D with the factor 2^(K(D)) and is therefore not samplable by a halting procedure; it is computable relative to the halting problem. (d) is Theorem 4.3 against (a) with R2. One addition for the note: a rehearsal sampler that runs programs under a time bound, or dovetails them and takes the first outputs, dominates the laws sampled within its time bound and no others; so "unlimited ordinary compute" buys every fixed time bound, and it is the limit that needs the oracle.

**Remark 4.5. CORRECT.** Recomputed: the two silent-error probabilities sum to at least 1 − π_i − min{R(⊥), R′(⊥)}; with both at most σ the smaller abstention probability is at least 1 − π_i − 2σ.

### Section 5 of the file (N5)

**Definition 5.1 and Lemma 5.1′. CORRECT.** The least concave majorant of a nondecreasing function on [0, L] is nondecreasing (an affine majorant with negative slope can be replaced by the constant equal to its value at L). Lemma 5.1′ is the candidate's R1 for a function; the proof is right, including rounds in which no question is asked.

**Proposition 5.2 (upper bound through the robustness curve). MINOR.** Correct. For n < K ln 2 the argument L·K ln 2/n lies outside the domain [0, L] of the majorant. Fix: write δ̄_Π(min{L, L·K ln 2/n}); the proof gives this because β_T ≤ L always.

**Theorem 5.3 (N5). CORRECT.** (1) The 2m + 1 human answers of a block are equal, the inputs do not depend on the answers, and at most m answers of the block are replaced. (2) is Lemma 1.10(2) with M = B. (3) B/(4δ) − B = (1 − 4δ)·L/(4(2m + 1)δ) (exact arithmetic). (4) is Proposition 5.2 with δ₀ = 0. Note for the reader: a question anywhere in a region reveals the member on the whole region, so for this class the problem is exactly the needle problem with B calls; the 2m + 1 calls of a block are copies of one question.

**Proposition 5.4. CORRECT.** (a) is Lemma 1.10(1) averaged over i. (b): the argument is right. It also holds for tolerance in the candidate's weaker sense (rules that see only the history): let one rule replace, in the run of f₀, the answers at the 2nd, 4th, 6th, … call at which f₀ and f_i differ, and the other replace, in the run of f_i, the answers at the 1st, 3rd, 5th, … such call, each rule stopping after m replacements; when the two answer vectors differ in d ≤ 2m places both rules produce the same vector, with ⌊d/2⌋ and ⌈d/2⌉ replacements. (c) is right, also for unequal Δ_i (the questions go to the largest Δ_i, and the remaining ones have at most the average influence).

**Example 5.5. CORRECT.** 1 − (1 − β/L)^L ≥ β − β²/2 (checked), so δ_Π(β) ≥ β(1 − β/2) for β ≤ 1, while one question at x₀ gives failure 0 for every class. See Section 2.2 below.

### Section 6 of the file (stochastic humans)

**Theorem 6.1. CORRECT.** kl(θ) = 2θ·ln((1 + 2θ)/(1 − 2θ)) ≤ 16θ² on (0, 1/4] (checked on a grid); Pinsker gives TV ≤ θ·√(8·E[N_i]); the average over the 2^K sign vectors counts each pair twice. Consequence 1 equals √(K/n)/(16√2) exactly; consequence 2 has threshold K/(512ε′²) exactly. An abstaining deployed answer is covered, because TV(R, P_σ) ≥ |R(1|i) − P_σ(1|i)| holds for a law R on Y ∪ {⊥}.

**Lemma 6.2. CORRECT.** g′(p) = L·C(2j, j)·(p(1 − p))^j; C(2j, j)·4^(−j) ≥ 1/(2√j) (checked for j < 2000); L/(2√j) ≥ √(L/2). On a grid of 84 values of L and 399 values of θ the ratio TV/(θ√L(1 − 2Lθ²)) is at least √2.

**Theorem 6.3. MINOR: the second inequality of the display is false when 1 − θ·√(8n/K) < 0.** The first inequality, 2^(−K)·Σ_σ Err(P_σ) ≥ (τ_L(θ)/4)·(1 − θ√(8n/K)), is proved. The second multiplies τ_L(θ) ≥ θ√L(1 − 2Lθ²) by the factor 1 − θ√(8n/K), which reverses it when that factor is negative; and when 1 − 2Lθ² is negative as well, the last expression is positive and is not a lower bound. Example: K = 1, θ = 1/4, L = 16, n = 8: the last expression is 0.25, while the protocol that asks the one input eight times and deploys the more likely sign has Err = 0.068. Fix: "…≥ (τ_L(θ)/4)·(1 − θ√(8n/K)); and if θ√(8n/K) ≤ 1, the right side is at least (θ√L/4)·(1 − 2Lθ²)·(1 − θ√(8n/K))". Consequences 1 and 2 use θ√(8n/K) = 1/2 and θ√(8n/K) ≥ 1/2 with 2Lθ² ≤ 1/2, and are correct: 1 gives θ√L/16 = √(L·K/n)/(64√2); in 2 the bound is at least 2ε(1 − θ√(8n/K)), which exceeds ε unless n ≥ K/(32θ²) = L·K/(8192ε²).

### Section 7 of the file (the concluding theorem)

**Theorem 7.1. Parts (A) to (F) CORRECT; the wording of (D), (E) and of the paragraph "In words" MINOR.** See Section 2.3 below.

### Section 0 and Sections 8 to 11 of the file

**Section 0 (summary table). MINOR.** The rows agree with the statements. The row of Theorem 3.3 should carry its two conditions (L/ε ≥ 16; K known). The rows of Corollary 3.4 and of Proposition 5.4 change with corrections 1 and 5 of Section 7 below.

**Section 8 (numerical checks). CORRECT, with one slip in the notes.** Both scripts were rerun and reproduce every quoted line. The note to check (d) says that the smallest ratio √2 is "attained as t → 0 for L = 1". It is attained for L = 2: for L = 1 the total variation is 2θ and the ratio tends to 2; for L = 2 the total variation is again 2θ and the ratio to θ·√2·(1 − 4θ²) tends to √2. So the stronger bound θ·√(2L)·(1 − 2Lθ²), which the file proves for odd L and conjectures for even L, holds on the grid for even L as well and is attained in the limit at L = 2.

**Section 9 (open questions). MINOR.** Item 2, second clause ("a version whose guarantee uses fault tolerance (Theorem 3.3 … gains nothing from m > 0)"), is not open: Proposition A2 below. Item 6 is not open: Section 4.4 below.

**Section 10 (remarks on the candidate theory).** Items 1, 2, 3, 5, 6 are confirmed. Item 4 depends on the gap in Corollary 3.4(5) and is right once Proposition A1 is added. Item 7 must be revised: by Proposition A2 the function deployed by Protocol AB has, in expectation, at most L·K/(n_B·log(1/γ)) unfaithful calls per run, so a single deterministic function per run can be as good as the per-call mixture also for the *number* of unfaithful calls. The candidate's R5 can therefore hold only for rules that deploy a member of H drawn from the posterior after rehearsal questions; it should not say "every rule that deploys a single hypothesis per run".

**Section 11 (literature).** See Section 6 below.

### Edge cases examined

* *Horizon 1.* Theorem 2.1 and Corollary 2.2 with L = 1 are meaningful (exact values for L = 1 in Section 4.5: 4 ≤ 4.5 ≤ 5 at δ = 0.05). Theorem 3.3 with L = 1 needs ε ≤ 1/16 and is then a statement about learning a single call. Theorem 5.3 with B = 1 and Lemma 6.2 with L = 1 (total variation 2θ) are covered by their proofs. Remark A3 needs L ≥ 3.
* *One question, or fewer than one in expectation.* Theorem 4.1 with n = 1 (success probability 1/2 + 1/(2N)); Lemma 5.1′ with n = 1 (it gives β₁ ≤ L·K ln 2, which is right because 1 − M ≤ −ln M ≤ K ln 2 at every input); Theorem 2.1 with a non-integer expected n (linear programme).
* *Runs with no calls, or with fewer than J calls.* In Lemma 5.1′ and Theorem 3.3 such a round asks nothing and leaves the weights unchanged; the proofs count it correctly. A run with no calls is faithful.
* *Events of probability zero.* Theorem 1.6 with γ = 0; Theorem 4.1 (f_i ≠ f₀ at D_i-almost every x); Proposition 5.4(b) (equality of outcomes almost surely, which is what failure 0 gives). All handled.
* *Infinite divergences.* None occurs: in Section 6 the log-likelihood ratios are bounded by ln 3 because θ ≤ 1/4; in Lemma 5.1′ the mixture gives f(x) at least the posterior weight of f.
* *Semimeasures.* Weights of total less than 1 are covered (W₁ ≤ 1 is all that is used; the simulation of Protocol AB uses total weight 0.9). Samplers that are semimeasures need the outcome ⊥ in Lemma 1.5. Proposition 4.4 normalises ξ.
* *Ties.* Theorem 3.3 has none because γ < 1/2. Theorems 6.1 and 6.3 break ties towards +1, and the inequality used holds in both cases. In Theorem 3.1 the three possible deployed outcomes (0, 1, ⊥) are all counted.
* *Parameters at the border.* Corollary 2.2(1) for δ > 1/4 and Proposition 2.5 for δ ≥ 1/2 are vacuous, not wrong. Theorem 3.1 when fewer than 2L cells of a block are unasked is handled by the indicator in step 2. K = 0 in Theorem 3.3: fix (b). Theorem 6.3 outside θ·√(8n/K) ≤ 1: the display fails (see above).

## 2. The three points singled out by the task

### 2.1 Theorem 3.3: is Protocol AB well defined when only single calls on chosen inputs can be asked, and does the count hold?

Yes to both, in the model of the file (the human answers any single input, A1; f ∈ H, A2).

*Every question is a single call.* At a step of type (B) the protocol itself computes a run of the function h_t and asks the human the input of one call of it. At a step of type (A) it asks one input of X₀. The human never carries out a run and is never asked about a run.

*The steps are well defined.* W_t ≥ w(f) > 0 because f is consistent with its own answers. The members are total functions, so M_t(·|x) is a probability distribution on Y and its maximum is attained. Because γ < 1/2, an answer with weight above 1 − γ is unique. "The first such x" exists whenever some input is split. At a step of type (B) the function h_t is defined on all of X₀, and it has to be defined at every input of its own run; this is why X₀ must contain the inputs produced under arbitrary answers (fix (a) in Section 1). The protocol terminates: a ≤ K ln 2/γ on every path, so the n_B-th step of type (B) comes after at most n_B + K ln 2/γ steps.

*The count.* Each step asks at most one question, so the number of questions is at most n_B + a ≤ n_B + K ln 2/γ; with the parameters of (3) this is at most 1 + (u/(u − log u) + ln 2)·K·L/(ε·u) ≤ 1 + 2.6932·K·L/(ε·log(L/ε)). Checked on 20 000 random triples (L, ε, K), together with the failure bound L·K/(n_B·log(1/γ)) ≤ ε.

*Independent simulation.* Protocol AB was implemented literally (X₀ = X, steps exactly as stated, exact posterior) on five random classes with unequal weights of total 0.9, with scaffolds that are adaptive, have internal randomness and stop early, for three choices of the human each (15 instances, 150 to 300 runs each). The path inequality (1) held in every run; the average failure of the deployed h, computed exactly by enumerating (z, ρ), was below the bound of (2) in every instance; recipe (3) was run on three further instances and stayed within its count.

*What the statement has to say and now leaves to the remarks.* First, at steps of type (A) the human is asked inputs that are found by searching X₀ for a split posterior; such an input need not occur in any run of the scaffold, neither of the human system nor of an imitator. This is allowed by A1, but it is a different use of A2 from Protocol R's, whose questions are all calls of rehearsal runs, and the note should say so. Second, K must be known to choose n_B. Third, a step of type (A) requires a search over all of X₀. Remark A3 (Section 4.3) gives a variant in which every question is a call of the protocol's own rehearsal run, with no search over X₀ and no knowledge of K, at the price of a smaller saving.

*What is new.* The mechanism (a vote of the surviving members; questions where the vote is weakest; a disagreement with a strong vote removes most of the weight) is that of Hegedűs's algorithm for exact learning with membership queries (Section 6). The note should say so, and should call new only the use for runs of a scaffold with weights and random audits.

### 2.2 The claim that part of the "sharper form" of R3 is false

The candidate's sentence (tagged as a conjecture) has two halves. "Failure ≤ (concave majorant of δ_Π)(L·K ln 2/n)": correct for a deterministic human and the per-call mixture M^(T); this is Proposition 5.2. The proof needs the deployed imitator to be a sampler (a fresh draw at each call), because the supremum in δ_Π runs over samplers; it does not cover one hypothesis per run.

"For classes closed under patches about L/β questions are needed to get below δ_Π(β)": false as stated. Example 5.5 is a valid counterexample. Recomputed: with L calls at one input x₀, outcome the maximum of the answers, f₀ ≡ 0 and G = {outcome 0}, the sampler that answers 1 with probability β/L has β faults in expectation and leaves G with probability 1 − (1 − β/L)^L ≥ β − β²/2; so δ_Π(β) ≥ β(1 − β/2) > 0 for 0 < β ≤ 1, while one question at x₀ gives failure 0 for every class of functions, in particular for the class of all functions, which is closed under patches. The file names two things the candidate's statement lacks: a stochastic sampler can spread β faults thinly over repeated visits to one input, which a function cannot; and a lower bound needs many disjoint places where a patch has influence. The second is the general one and does not depend on repetition: a scaffold that can produce only N₀ different inputs is learned exactly with N₀ questions (Remark 2.4(3)), after which the deployed run is the run of the human system. So the sentence fails for every scaffold with fewer than L/β possible inputs, whenever δ_Π(β) exceeds the failure probability of the human system itself. The replacement proposed by the file is right: a lower bound needs many disjoint places at each of which a patch that is in the class changes the outcome with noticeable probability (Proposition 5.4(a)), and for members that tolerate m faults the method cannot give more than L/(4(2m + 1)δ) (Proposition 5.4(b), (c)).

### 2.3 The concluding theorem (Theorem 7.1)

Parts (A) to (F) follow from the results cited in their proofs; every number was recomputed.

* (A) L/(4δ) − L from Corollary 2.2(1); log(L/(2δ) + 1) ≤ log(L/δ); 1/(4δ) − 1 ≥ 4 for δ ≤ 1/20. To add: the number of questions is the expected number when the human is the zero function.
* (B) (1 − 10δ)·m·L/(8δ) from Theorem 3.1; the number is an expectation over a uniformly chosen member. "No faster" is Theorem 3.3 and needs K known.
* (C) Proposition 2.5; the saved fraction is at most √(2δ) + δ + δ/L.
* (D) Correct: if all r outcomes are right, so is their maximum, which is the outcome of one OR run with rL calls; a protocol that sees the inputs of all r runs before asking is at least as strong as one that sees them run by run. To add: the class depends on r (it has rL/(2ε) + 1 members). For a fixed needle class with N₀ cells, N₀ questions identify the human and every later run is right. "There is no amplification for any r" must be read as "for every r there is a class".
* (E) Correct. To add: "each run is faithful with probability at least 1 − δ" is a probability over the training and the run; the runs share one trained imitator and are not independent. Only the expected number δr of unfaithful runs is claimed, and that is right.
* (F) Correct for the block-majority scaffold. By Proposition A2 one can add that 1 + 2.7·K·L/((m + 1)δ·log(L/((m + 1)δ))) questions also suffice.

The paragraph "In words" says more than the theorem in three places.

1. "A protocol that must be right for every member of a class closed under patches has to have asked, with probability about 1 − δ/p, every place whose patch would change the outcome with probability p." What Lemma 1.10(1) gives is: with probability at least 1 − 2δ/p, for every place whose patch is in the class. (On average over the places, Lemma 1.10(2) gives 1 − δ(N + M)/(N·p).)
2. "For a run all of whose calls are critical there are about L/δ places that matter at level δ, and nothing is gained over letting the human do the run." This is true of the OR scaffold with L/(2δ) cells and the needle class. It is not true of every run all of whose calls are critical: in Example 5.5 all L calls are critical and one question suffices. The number that matters is the number of different places a critical call can fall on and the class can patch, not the number of critical calls.
3. "If the scaffold survives m faults the price drops by a factor between m + 1 and 2m + 1." Proved: the sufficient number of questions drops by the factor m + 1 for every human system that tolerates m faults (R3; also Proposition A2); and for the block-majority scaffold the necessary number is smaller than for the OR scaffold of the same length by the factor 2m + 1 (Theorem 5.3). That tolerance never lowers the price by more than 2m + 1 is not proved and is false in general (a tolerant scaffold with few possible inputs is cheap for the reason of point 2).

Replacement text for these three sentences: "A protocol whose failure is at most δ for every member has asked, with probability at least 1 − 2δ/p, every place whose patch is in the class and changes the outcome with probability p. In the OR scaffold with L/(2δ) cells every cell is such a place, with p close to 2δ, and about half of the cells must be asked: nothing is gained over letting the human do the run. This concerns runs whose critical calls fall on many different places; a run whose critical calls fall on few places is cheap. … If the human system survives m faults, the sufficient number of questions drops by the factor m + 1; in the block-majority example the necessary number drops by the factor 2m + 1."

## 3. Comparison with Section 4 of `note.md`

**Theorem N1 of the note. CORRECT.** The proof is right: restricted to the event E that no question lies in Q, the joint law of the data and of the deployed answer at x is the same under P and P′, and the two events "the answer is one this human gives" are disjoint. It is Theorem 1.6(2) of the file with γ = 1 − p. The file's theorem is more general in three ways that the note should take over: supports that overlap (the bound is then TV(P(·|x), P′(·|x)) − γ for the sum of the two distances, Theorem 1.6(4)); whole runs (Theorem 1.6(1), (3)); and deployed systems that see z and ρ.

**The paragraph after N1. One sentence WRONG.** "In the class of all programs such a P′ exists for every decidable Q and costs K(Q) + c bits more than P" is true for a deterministic human and false for a human whose answer at x has full support: then no sampler has an answer law at x with support disjoint from that of P(·|x) (Proposition 1.8(3)). Replacement (Proposition 1.8(1), (2)): "for a deterministic human such a P′ exists for every decidable Q at a cost of K(Q) + c bits; for a general human there is, for every N ≥ 2, a P′ whose answer law at x is at total variation at least 1 − 1/N from P(·|x), at a cost of K(Q) + log N + 2 log log N + c bits, and Theorem N1 then holds in its total-variation form."

**Theorem N2 of the note. CORRECT, with a constant that can be improved fourfold.** Every step of the proof was recomputed and checked on a grid (γ ≤ 1/16, L < 60): q ≥ 1 − e^(−u) ≥ u(1 − u/2) ≥ (3/4)·L/N for u = L/N ≤ 1/2; the average failure is at least (3/8)(L/N)(1 − n/N); 1 − n/N < 1/3 + 1/6; hence n > N/2 ≥ L/(16γ). K ≤ log(L/(4γ) + 2) is right for the prior of the proof. Exact values for the note's class (Section 5.1, table 4): with (L, γ) = (5, 1/40) the class has N = 25 cells and 22 questions are needed, against the claimed 12.5; Theorem 2.1 of the file gives about 7N/8 for this class. The file's choice N₀ = L/(2δ) forces L/(4δ) − L. The note should state N2 in the file's form: N₀ := ⌈L/(2δ)⌉ cells, δ ≤ 1/6, n ≥ L/(4δ) − 3L/2 (and L/(4δ) − L when L/(2δ) is an integer), n being the expected number of questions when the human is the zero function; ⌈N₀/2⌉ questions suffice for this class (the protocol of Proposition 2.3 has failure (1 − n/N₀)·p and p ≤ L/N₀ ≤ 2δ), which is ⌈L/(4δ)⌉ when L/(2δ) is an integer.

**The text after N2.** "The two bounds differ by the factor 16·K ln 2" becomes 4·K ln 2 with the file's constant. The sentence in brackets is replaced by the results of Section 3 of the file: the factor K is forced in the VC dimension; in bits the minimax number is of order K·L/(δ·log(L/δ)). The last paragraph has the two overstatements of Section 2.3: "one run of L critical calls" needs the hypothesis that the calls fall on at least L/(2δ) places which the class can patch; and "it saves work within a run exactly to the extent that the human system tolerates faults" is not proved ("exactly" should go; a scaffold with few possible inputs also saves work).

## 4. Additions by the referee

These statements are mine, with proofs, and are not refereed. A1 fills the gap in Corollary 3.4(5). A2 closes an item the file lists as open. A3 is a remark that bears on the first point of the task.

### 4.1 A lower bound for Protocol R itself

**Proposition A1 (the rare-points class).** Let d ≥ 1, L ≥ 1, 0 < ε ≤ 1/8 and q := 4ε/L. Let X := {x₀} ∪ [d] and Y := {0, 1}. Let H be the set of the 2^d functions g: X → {0, 1} with g(x₀) = 0, with equal weights, so that K = d for every member. Let the scaffold make exactly L calls whose inputs are independent draws from the law μ that gives x₀ probability 1 − q and each point of [d] probability q/d; the inputs are internal randomness of the scaffold and do not depend on the answers. The outcome is the list of the L answers.

(a) Let a protocol put to the human n inputs drawn independently from μ and independently of the human's answers, and then deploy any system (Definition 1.3 of the file). Then the average of Fail(f) over the 2^d members is at least 2ε(1 − 2ε)·(1 − q/d)^n. Hence failure at most ε for every member requires

  n ≥ ln(2(1 − 2ε))·(L·d/(4ε) − 1) ≥ 0.1·K·L/ε − 0.4.

(b) Protocol R is such a protocol with n its number of rounds, whatever it deploys: the question of a round is the input of call J of the rehearsal run, and since the inputs of a run do not depend on the answers and J is independent of the run, this is one draw from μ, independent of the past.

(c) The protocol that asks the inputs 1, …, d and deploys the function it has seen has failure 0 with d = K questions.

*Proof of (a).* Let f be uniform on H and independent of the questions, of the seed and of (z, ρ, s). Let U be the set of points of [d] that are not among the n questions; each point is in U with probability (1 − q/d)^n, so E|U| = d·(1 − q/d)^n. The transcript is a function of the questions and of the values of f at the asked points. Hence, given the seed, the transcript and the inputs of the run, the values of f on U are independent fair bits, and the deployed outcome does not depend on them. If the run has a call with input in U, the true outcome contains such a bit, so the deployed outcome is wrong with conditional probability at least 1/2. Given U, the run has a call in U with probability 1 − (1 − q|U|/d)^L ≥ (L·q·|U|/d)(1 − L·q·|U|/(2d)) ≥ (4ε|U|/d)(1 − 2ε), by 1 − (1 − x)^L ≥ Lx − (Lx)²/2 and L·q = 4ε. Taking expectations, the average failure is at least (1/2)·4ε(1 − 2ε)·E|U|/d = 2ε(1 − 2ε)(1 − q/d)^n. If every member has failure at most ε, then (1 − q/d)^n ≤ 1/(2(1 − 2ε)), so n ≥ ln(2(1 − 2ε))/ln(1/(1 − q/d)) ≥ ln(2(1 − 2ε))·(d/q − 1), because ln(1/(1 − x)) ≤ x/(1 − x). For ε ≤ 1/8, ln(2(1 − 2ε)) ≥ ln 1.5 > 0.4, and d/q = L·d/(4ε). ∎

*Consequences.* (i) By R1 (Lemma 5.1′ of the file) Protocol R reaches failure ε on this class with ⌈L·K ln 2/ε⌉ rounds. So R1 is sharp for Protocol R up to the factor ln 2/0.1 < 7. Exact computation (Section 5.2, part C): in six cases Protocol R needs between 0.35 and 0.39 times K·L/ε rounds. (ii) On this class Protocol R needs at least L/(10ε) − 0.4/K times the K questions of the protocol of (c). (iii) Protocol AB needs at most 1 + 2.7·K·L/(ε·log(L/ε)) questions on every class of K bits. So the worst case of Protocol R over classes of K bits exceeds the minimax number of questions by a factor that is at least log(L/ε)/27 in the limit of large K·L/ε. This is the proof that "Protocol R is not optimal for functions". The cause is the random choice of the question, not the mixture: (a) holds for every deployed system.

### 4.2 Protocol AB with fault tolerance

The file says that it is open whether Protocol AB has a fault-tolerant version (Section 5.3(i)), that Theorem 3.3 "bounds the probability of any unfaithful call, so it gains nothing from m > 0", and it asks whether K·L/((m + 1)·δ·log) questions can be reached by combining the per-call mixture with targeted questions (Section 9, item 2). The proof of Theorem 3.3(2) already gives that number, for the function that Protocol AB deploys; no mixture is needed.

**Proposition A2.** In the setting of Theorem 3.3 call a call of a run of a function h a *fault* if h differs from f at the input of that call (for a deterministic human these are the unfaithful calls of the note). For a step t of type (B) let v_t be the expected number of faults of the run of h_t, over (z, ρ), given the data before the step.

1. E[Σ v_t over the n_B steps of type (B)] = L·E[b] ≤ L·K/log(1/γ). So the run of the deployed function h has at most L·K/(n_B·log(1/γ)) faults in expectation.
2. If the human system of f tolerates m faults with failure δ₀ for a set G of runs (Definition 5.1 of the file; rules that see only the history suffice), then Pr[deployed run ∉ G] ≤ δ₀ + L·K/((m + 1)·n_B·log(1/γ)).
3. Let β > 0 with L/β ≥ 16, u := log(L/β), γ := u·β/L and n_B := max{1, ⌈L·K/(β·(u − log u))⌉}. Then the deployed run has at most β faults in expectation and at most 1 + 2.7·K·L/(β·log(L/β)) questions are asked. With β := (m + 1)·δ′ the failure is at most δ₀ + δ′.

*Proof.* (1) At a step of type (B) the audited call is call J of the run of h_t, with J uniform on [L] and independent of the run. The human's answer differs from that of h_t exactly when the run has a J-th call and that call is a fault. So the conditional probability that the step adds one to b is v_t/L. Whether a step is the i-th step of type (B) is determined by the data before it; summing over these steps gives E Σ v_t = L·E[b], and b ≤ K/log(1/γ) by Theorem 3.3(1). The deployed h is that of a uniformly chosen step of type (B). (2) The run of h is the run of the human system under the rule that replaces the human's answer f(x_j) by h(x_j) at every call where the two differ; the rule sees only the input of the call. The rule that does the same for its first m replacements and then replaces nothing is admissible, so its run is in G with probability at least 1 − δ₀. The two runs coincide unless the run of h has at least m + 1 faults, which by Markov's inequality has probability at most the expected number of faults divided by m + 1. (3) is the arithmetic of Theorem 3.3(3) with β in place of ε; that arithmetic does not use ε < 1. ∎

*Check.* In the simulation of Section 5.2, part A, the average number of faults of the deployed run was below the bound in all 15 instances, and the averages of Σ v_t/L and of b agreed within sampling error.

*Consequences for the file.* For the region class and the block-majority scaffold of Theorem 5.3, with L/((m + 1)δ) ≥ 16: K = log(L/(2(2m + 1)δ) + 1) ≤ log(L/((m + 1)δ)), so 1 + 2.7·L/((m + 1)δ) questions suffice (take β = (m + 1)δ and δ₀ = 0), against the necessary (1 − 4δ)·L/(4(2m + 1)δ). The ratio of the two is at most 10.8·(2m + 1)/((m + 1)(1 − 4δ)), below 22 for small δ: for this class the number of questions is now known up to a constant factor, not up to 4 ln 2·K·(2m + 1)/(m + 1). In Section 5.3 of the file, item (i) should say that the logarithm can be saved for every m. In Section 10, item 7 should be revised as said in Section 1.

### 4.3 A variant in which every question is a call of the protocol's own rehearsal run

**Remark A3.** Setting of Theorem 3.3, L ≥ 3. Fix γ := ln L/L. In round t = 1, …, n: let h_t(x) be an answer of largest posterior weight M_t(·|x) (the first one in a fixed order in case of a tie); call an input x *split* if max_y M_t(y|x) ≤ 1 − γ; draw (z, ρ) and run Π with h_t answering every call; if the run has a call with a split input, put the first such call to the human; otherwise draw J uniformly from [L] and, if the run has a J-th call, put it to the human. Deploy h_T for T uniform on [n]. Then, for every n,

  Pr[the deployed run differs from run_f(z, ρ)] ≤ K·L/(n·log(L/ln L)).

*Proof.* Let a be the number of rounds in which a split call was asked and b the number of other rounds in which the human's answer differed from h_t's. A split input multiplies the consistent weight by at most 1 − γ whatever the answer; a disagreement at an input that is not split multiplies it by less than γ. So a·ln(1/(1 − γ)) + b·ln(1/γ) ≤ K ln 2 on every path, and therefore a + L·b ≤ K ln 2·max{1/ln(1/(1 − γ)), L/ln(1/γ)}. Given the data before round t let α_t be the probability that the run of h_t has a split call and u_t the probability that it differs from the run of f. A split call is asked with probability α_t. On the event that the run has no split call and differs from the run of f, the first call at whose input h_t and f differ is audited with probability 1/L; so a disagreement of the second kind has probability at least (u_t − α_t)/L. Hence u_t ≤ E[1{split call asked in round t} + L·1{disagreement of the second kind in round t} | data], and E Σ_t u_t ≤ E[a + L·b]. The deployed failure is (1/n)·E Σ_t u_t. For γ = ln L/L and L ≥ 3: 1/ln(1/(1 − γ)) ≤ 1/γ = L/ln L ≤ L/(ln L − ln ln L) = L/ln(1/γ), so the maximum is L/ln(L/ln L), and K ln 2·L/ln(L/ln L) = K·L/log(L/ln L). ∎

What this gives: the bound of R2 for a function, L·K ln 2/n, is improved by the factor ln(L/ln L) (which exceeds 1 for every L ≥ 3 and is about 5 for L = 1000), by a protocol that asks only calls of its own rehearsal runs, examines only the inputs of the current run, and does not need K. It saves log L and not log(1/ε): Protocol AB's larger saving comes from the questions outside the runs. On the rare-points class of Proposition A1 this variant needs about 0.4·K/ε rounds where Protocol R needs about 0.37·K·L/ε (exact computation, Section 5.2, part C). The variant's guarantee is for the probability of a fully faithful run only; for the expected number of faults the same argument gives nothing better than Protocol R. Check: Section 5.2, part E (ten instances; the path inequality, the linear-programming step and the bound hold).

### 4.4 Section 9, item 6 is settled

The item asks whether 2^k disjoint decidable regions of prefix complexity at most k + c exist. For all k they exist only with K(k) added to the complexity, as in Corollary 4.2, and the remark after Corollary 4.2 already says why. In full: let N_j be the number of programs of length at most j in the domain of the prefix machine. Then Σ_j 2^(−j)·N_j = Σ_p Σ_{j ≥ |p|} 2^(−j) ≤ 2·Σ_p 2^(−|p|) ≤ 2, and N_j is lower semicomputable uniformly in j; so j ↦ 2^(−j)·N_j/2 is a lower semicomputable semimeasure and is at most 2^(−K(j) + O(1)) (coding theorem, Section 6). Hence at most 2^(j − K(j) + O(1)) different sets have a decider of complexity at most j. A family of 2^k different sets of complexity at most k + c therefore forces K(k) ≤ c + O(1). Conversely, the 2^(k − K(k) − c′) sets of strings that begin with a given word of length k − K(k) − c′ are disjoint, decidable and of complexity at most k. So the largest number of disjoint decidable regions of complexity at most k is 2^(k − K(k) + O(1)): the factor 2^k of N3 becomes 2^k up to a factor polynomial in k, as the file says, and nothing is open.

### 4.5 Exact values that the note can quote

*Needle class, N₀ = L/(2δ) cells (Corollary 2.2(1), Proposition 2.3).* Least expected number of questions with failure at most δ for every member, by linear programming:

| L | δ | L/(4δ) − L | exact | ⌈L/(4δ)⌉ |
|---|---|---|---|---|
| 1 | 0.05 | 4 | 4.50 | 5 |
| 2 | 0.025 | 18 | 19.25 | 20 |
| 4 | 0.05 | 16 | 18.75 | 20 |
| 4 | 0.02 | 46 | 48.75 | 50 |
| 8 | 0.05 | 32 | 37.74 | 40 |
| 2 | 0.005 | 98 | 99.25 | 100 |

*Block class, N = L/(2δ) (Theorem 3.1, Proposition 3.2).* Least expected number of questions per block with average failure at most δ:

| L | δ | (1 − 10δ)·L/(8δ) | exact | Proposition 3.2 with m even: (L/(4δ) + 1/2)/2 |
|---|---|---|---|---|
| 1 | 0.025 | 3.75 | 5.23 | 5.25 |
| 2 | 0.01 | 22.5 | 25.12 | 25.25 |
| 5 | 0.0125 | 43.75 | 49.74 | 50.25 |
| 8 | 0.025 | 30 | 39.36 | 40.25 |

So for the block class the least number of questions is m·L/(8δ) up to a factor 1 + O(δ): scanning half of the blocks completely is optimal up to rounding.

## 5. Numerical checks

All scripts are in `verification/code/`; each stops at the first failed assertion and ends with "all checks passed". Outputs are in the files `*.out` next to them. Python 3 with numpy 2.5.3 and scipy 1.18.1.

### 5.1 `lower-bounds_needle_exact.py` (2 s)

The minimax problem for the needle class is reduced by symmetry: averaging a protocol over a random permutation of the cells leaves Fail(f₀) unchanged and replaces every Fail(f_i) by their average, so an optimal protocol asks a uniformly random set of n cells and deploys an outcome that depends only on how many visited cells lie inside and outside that set. A protocol with a random number of questions is a mixture over n, so the exact minimax for a given expected number of questions is one linear programme.

1. For fixed n the values agree to six digits with the 16 values of the prover's enumeration (file, Section 8.1).
2. Theorem 2.1: bound ≤ exact minimax ≤ value of the protocol of Proposition 2.3 on 42 triples (N₀, L, n) with N₀ up to 60; the smallest ratio of exact value to bound is 1.0000.
3. Corollary 2.2(1) and Proposition 2.3: nine cases, table in Section 4.5. Corollary 2.2(2): seven cases in which L/(2δ) is not an integer; L/(4δ) − 3L/2 ≤ exact value ≤ ⌈N₀/2⌉ in all of them (for example (L, δ) = (6, 0.013): 106.4 ≤ 113.6 ≤ 116).
4. Theorem N2 of the note: six cases; the least number of questions always exceeds L/(16γ).
5. Theorem 3.1: the bound is below the exact single-block Bayes value at 41 grid points for each of seven pairs (N, L) (smallest ratio 1.11 where the bound is positive); six cases of the least number per block, table in Section 4.5.

### 5.2 `lower-bounds_ab_sim.py` (18 s)

* Part A. Protocol AB, literal implementation, 15 instances: claims (1) and (2) of Theorem 3.3 and claim (1) of Proposition A2.
* Part B. Recipe (3) of Theorem 3.3 on three instances.
* Part C. Proposition A1: exact failure of Protocol R on the rare-points class; least number of rounds for failure ε in six cases, for example (d, L, ε) = (16, 16, 1/16): Protocol R 1532 rounds (the bound of Proposition A1 gives 573, R1 gives 2839), the variant of Remark A3 104 rounds, chosen questions 16.
* Part D. Protocol R on the block class (three cases): between 3.4 and 3.8 times m·N rounds for failure δ, against the lower bound (1 − 10δ)·m·L/(8δ), which is about m·N/4.
* Part E. Remark A3 on ten instances: the path inequality, the linear-programming step and the bound.

### 5.3 `lower-bounds_constants.py` (2 s)

Every chain of simplifications in the file, evaluated in exact form on grids: Definition 2.0; Corollary 2.2(1) to (3); Propositions 2.3 and 2.5; steps 1 and 4 of Theorem 3.1 (step 1 in exact rational arithmetic); Proposition 3.2 (exact); Theorem 3.3(3); Remark 3.5; Theorem 4.1(3) (exact, N ≤ 6); Theorem 5.3(3) (exact); Example 5.5; Proposition 5.4(c); Theorem 6.1 (the bound on kl, both consequences); Lemma 6.2; Theorem 6.3 (both consequences, a comparison with a protocol, and the counterexample to the display); Theorem 7.1(A); every step of the note's proof of N2; Theorem 1.6(4) and Corollary 1.7 on random laws.

## 6. Literature

* **T. Hegedűs,** "Generalized teaching dimensions and the query complexity of learning", Proceedings of the 8th Conference on Computational Learning Theory (COLT 1995), pp. 108–117. The file quotes its main bound from memory. I did not read the paper. I read, in this session, the account of it in S. Hanneke and L. Yang, "Minimax Analysis of Active Learning", arXiv:1410.0996v1 (3 October 2014), Appendix B.1 (proof of Theorem 3, pp. 41–42 of that version). It gives the algorithm (there called MEMB-HALVING-2 and attributed to Hegedűs): keep the set V of consistent concepts; form the majority-vote classifier of V; take a minimal specifying set for it; query, one after another, the point of that set at which the fewest members of V agree with the vote; stop the inner loop when an answer disagrees with the vote; repeat. And it states (the display transcribed into one line): "Hegedüs (1995) proves that, letting XTD(C[U], U) = max_{h: X → Y} TD(h, C[U], U) (see Section 7.3), if n ≥ 2·(XTD(C[U], U)/(1 ∨ log₂(XTD(C[U], U))))·log₂(|C[U]|), then the classifier ĥ_n returned by MEMB-HALVING-2 satisfies ĥ_n = h*" (a footnote treats classes with one or two members). This confirms the file's statement "of order XTD(C)·log|C|/log XTD(C)" and shows that the mechanism of Protocol AB is that of this algorithm (Section 2.1).
* **A. Ehrenfeucht, D. Haussler, M. Kearns and L. Valiant,** "A general lower bound on the number of examples needed for learning", Information and Computation 82(3):247–261, 1989. Not read: the two hosts that carry the text (`www.cis.upenn.edu`, `mlanthology.org`) are outside the allowed network domains of this session. A search result summarised the abstract as a lower bound of order (1/ε)·ln(1/δ) + VCdim(C)/ε. The exact statement in the file ((d − 1)/(32ε) examples for ε ≤ 1/8, confidence 99%, d ≥ 2) agrees with my memory and remains unverified. It is used only in Remark 3.6, for the order d/ε.
* **Coding theorem** (used in Section 4.4): every lower semicomputable semimeasure μ on the integers satisfies μ(j) ≤ 2^(−K(j) + c_μ). From memory: L. A. Levin, "Laws of information conservation (non-growth) and aspects of the foundation of probability theory", Problems of Information Transmission 10(3):206–210, 1974; M. Li and P. Vitányi, *An Introduction to Kolmogorov Complexity and Its Applications*, Springer, the section on the coding theorem. The counting statement of the file (G. Chaitin 1975) follows from it as in Section 4.4.
* Pinsker's inequality and the two-point method are standard; the proofs of Theorems 6.1 and 6.3 are written out in full in the file and were checked as such.

## 7. Corrections to be made, ordered by importance

1. **Prove that Protocol R is not optimal, or do not say it.** Add Proposition A1 and reword Corollary 3.4(5), the summary row of Corollary 3.4 and Section 10, item 4: the minimax number of questions over classes of K bits is of order K·L/(δ·log(L/δ)) (Theorems 3.1 and 3.3); Protocol R needs at least 0.1·K·L/ε − 0.4 questions on the rare-points class, where K chosen questions suffice; so R1 is sharp for Protocol R up to a factor 7, and questions drawn at random from the runs are not optimal.
2. **Remove three overstatements from the conclusion** (file, "In words" after Theorem 7.1; note, last paragraph of Section 4.2), with the replacement text of Section 2.3: the probability 1 − 2δ/p; "L critical calls" needs "falling on at least L/(2δ) places that the class can patch"; the factor "between m + 1 and 2m + 1" is proved only as "m + 1 sufficient in general, 2m + 1 in the block-majority example"; "exactly to the extent" in the note is not proved. In Theorem 7.1(D) say that the class depends on r; in (E) say that the probability is over training and run.
3. **Correct the display of Theorem 6.3:** the second inequality holds if θ·√(8n/K) ≤ 1 and is false otherwise (Section 1).
4. **State Theorem 3.3 completely:** X₀ contains the inputs produced under arbitrary answers; n_B := max{1, ⌈·⌉}; the human is asked chosen inputs that need not occur in any run, A2 is used there, K must be known, and a step of type (A) is a search over X₀. Credit the mechanism to Hegedűs (1995).
5. **Replace two "open" items by results:** Protocol AB with fault tolerance (Proposition A2; update Section 5.3(i), Section 9 item 2, Section 10 item 7 and Theorem 7.1(F)); Section 9, item 6 (Section 4.4). If the note is to offer a protocol whose questions are all calls of rehearsal runs, Remark A3 gives one with the factor ln(L/ln L); it needs a second check.
6. **Correct the sentence after N1 in the note** (a patch with disjoint support does not exist for a human with full support at x; Section 3).
7. **State N2 in the note with the file's class and constant** (N₀ = ⌈L/(2δ)⌉, n ≥ L/(4δ) − 3L/2 for δ ≤ 1/6, or L/(4δ) − L when L/(2δ) is an integer; ⌈N₀/2⌉ questions suffice, because p ≤ L/N₀ ≤ 2δ), and replace "16·K ln 2" and the bracketed sentence.
8. **Small fixes:** Definition 1.1 (a stopping rule instead of a fixed number of steps); Proposition 1.8 (Y = {0,1}*); Remark 3.5 (no exceptional range, by Lemma 1.10(1)); Theorem 4.3 (say that Lemma 1.10 is used with the number of questions in one region); Proposition 5.2 (argument min{L, L·K ln 2/n}); Section 8, note to check (d) (the smallest ratio is at L = 2).
9. **Literature:** the statement of Ehrenfeucht, Haussler, Kearns and Valiant is still quoted from memory; either read it or cite only the order d/ε.

