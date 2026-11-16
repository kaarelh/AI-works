# Second check of the part property-batch

Second checker of `proofs/property-batch.md` (the final proof file, with its Section 11 "Checking") and of the note's text for this part: Sections 8.1, 8.2, 8.3, 8.6 and 8.7 of `note.md` (source `research/sections/property-batch.md`, where they are numbered 8.1, 8.2, 8.2a, 8.5, 8.6). Nothing in `note.md`, the section source or the proof file was edited. Nothing was committed.

Scripts written for this check, with their saved outputs (written independently of the editor's `proofs/code/property-batch_editor.py` and of the verifiers' scripts, which I did not reuse):

* `verification/code/property-batch_second_a.py` → `property-batch_second_a.out`: blocks (A) Lemma 2.8, (B) the human who repeats a fair bit, (C) remark (3) after Theorem 4.5, (D) Remark 4.14, (E) Theorem 4.11(B), (F) Proposition 4.15.
* `verification/code/property-batch_second_b.py` → `property-batch_second_b.out`: blocks (G) Proposition 5.4, (H) Proposition 6.4, (I) Proposition 6.5, (J) and (K) Theorem 6.6.

All computations in exact rational arithmetic unless the block says otherwise.

## 1. The statements examined, with verdicts

Selection. From the summary table and Section 11.3 of the proof file I took every statement that is marked as seen by its author only, by the editor only, or by one checker besides its author, and every statement that the editor says was written or changed after verification (Section 11.1, 11.2, 11.3 and the editor's notes, last paragraph). The middle column says whether the note's text uses it.

| id | statement | in the note's text | seen before me by | my verdict |
|---|---|---|---|---|
| L2.8 | Lemma 2.8 (the price of a test cannot be removed) | no (editor's notes only) | editor (check report sketched it) | CORRECT |
| R4.4 | Remark 4.4 (all programs: (Cl_R) with C_R = 2^(K(R)+c)) | yes, Pr2(a); and through (B2) in Pr2(c) | no one | CORRECT under a stated formalism; proof given in 1.2 below; what remains assumed is listed |
| T4.11B | Theorem 4.11(B), with "What (B) shows" | yes, Pr2(c) | check, attack, editor | CORRECT (one MINOR omission in "What (B) shows") |
| T4.11U′ | the paragraph on the machine U′ (why (A) is not enough) | no | check, attack, editor | CORRECT |
| R4.5(3) | remark (3) after Theorem 4.5 (the level is a parameter of the prior) | yes, Pr2(b), last sentence | attack, editor | CORRECT |
| R4.14 | Remark 4.14 (silence in the floor; numbers 0.7111, 0.1778, 0.1111) | yes, Pr2(a) | attack, editor | CORRECT |
| P4.15 | Proposition 4.15 (a conditioning that always answers) | yes, pointer in Pr2(a) | attack, editor | CORRECT |
| I4.13.4 | 4.13 item 4 (open question; the bound c_U″ ≥ 0.74·n₀ − 1.45·ln(1/δ) − 6) | yes, "Open" in Pr2(c) | open; the constant by the editor | CORRECT as an open question; MINOR in the constant 0.74 |
| I4.13.5 | 4.13 item 5 (cheap coin: V ≤ ½ + (k_c ln 2 + ln(1/δ))/(2n)) | no | check, editor | CORRECT |
| I4.13.6 | 4.13 item 6 (memorisers lose to the coin after (c + k_c)/(d + 1) questions) | no | attack, editor | CORRECT |
| P4.8d | Proposition 4.8(d), the fill 1 − V(D) ≥ M(D)^(1/k) | no | check, editor | CORRECT |
| T2.5r | remark after Theorem 2.5 (δ = 0.332, N = 4) | no | both reports, editor | CORRECT |
| R2.7.6-7 | Remark 2.7(6) (replay in 𝓜_N) and 2.7(7) (filter versus list) | no | attack, editor | CORRECT |
| I3.7.3 | item (3) after Corollary 3.7 (the human who repeats a fair bit; √2 − 1) | yes, 8.3 "Not said" | attack, editor | CORRECT |
| P5.4 | Proposition 5.4 (the coin is a member of 𝓜_N) | no | attack, editor | CORRECT |
| P6.4 | Proposition 6.4 (two answers per probe; the collision statistic) | yes, 8.7 last paragraph | attack, editor | CORRECT |
| P6.5 | Proposition 6.5 (two-sided form; one function for a family of rules) | no | attack, editor | CORRECT |
| T6.6 | Theorem 6.6 (Pr7(b): answers from a large set) | yes, Pr7(b) | editor only | CORRECT |

Reasons follow, statement by statement.

### 1.1 Lemma 2.8 (L2.8): CORRECT

Checked line by line.

* Independence. The N·M indicators 1[τ_i ∈ R_j] are independent fair bits: across runs by (IID), within a run because the events are independent under Q. This needs *mutual* independence of R_1, …, R_M (pairwise is not enough for the product (1 − p)^M); "independent" in the statement must be read so. Not an error.
* Case t* < 0. Pr[S_j ≥ N/2] ≥ 1/2 by symmetry, so no j reaches Q̂ ≥ 1/2 > 1/2 + t* with probability at most 2^(−M), and 2^(−M) ≤ e^(−(N+1)) needs M ≥ (N + 1)/ln 2, which follows from M ≥ (N + 1)² for every N ≥ 1. Correct.
* Case t* ≥ 0. k := ⌈N(1/2 + t*)⌉ gives t′ = k/N − 1/2 ∈ [t*, t* + 1/N). The claim t* + 1/N ≤ 1/2 is equivalent to ln(M/(N + 1)²) ≤ N, which holds because M ≤ e^N (indeed ln(M/(N + 1)²) ≤ N − 2 ln(N + 1)). So k ≤ N.
* For p = k/N the binomial (N, p) law has a mode at k, and the largest of N + 1 point probabilities is at least 1/(N + 1). The identity (k/N)^k (1 − k/N)^(N−k) = e^(−N·h(k/N)) and kl(x‖1/2) = ln 2 − h(x) give C(N, k)2^(−N) ≥ e^(−N·kl(k/N‖1/2))/(N + 1). Correct.
* kl(1/2 + t‖1/2) ≤ 4t² for 0 ≤ t ≤ 1/2: ln(1 + 2t) ≤ 2t, ln(1 − 2t) ≤ −2t and (1/2 − t) ≥ 0. Correct. Monotonicity in t′ gives e^(−N·kl) ≥ e^(−4N(t* + 1/N)²), and 4N(t* + 1/N)² = ln(M/(N + 1)²) by the definition of t*. Hence p ≥ (N + 1)/M and (1 − p)^M ≤ e^(−(N+1)).
* Cube form: M ≥ (N + 1)³ gives ln(M/(N + 1)²) ≥ (1/3) ln M. Correct.

Numerically (block (A)): every step and the conclusion, exactly, for N ∈ {3, 5, 8, 12, 20, 40, 100, 300} and M at the lower end (N + 1)², just above it (t* < 0), at (N + 1)³, at e^(N/2) and at e^N. The hypothesis (N + 1)² ≤ M ≤ e^N is satisfiable only for N ≥ 3, and (N + 1)³ ≤ e^N only for N ≥ 6; for smaller N the lemma is vacuous, which is harmless.

The reading ("up to a constant factor, √6 in the tolerance") is correct: √(ln M/(2N)) against ½√(ln M/(3N)) = √(ln M/(12N)), ratio √6, ignoring ln(2/δ) and the term 1/N.

### 1.2 Remark 4.4 (R4.4): the standard facts proved under a stated formalism

Remark 4.4 asserts: (i) the procedure "draw from p until the answer does not violate R" is a program φ_r(p) of length ℓ(p) + ℓ(r) + c, with c depending on the language only; (ii) φ_r is injective; hence (iii) (Cl_R) holds with C_R = 2^(ℓ(r)+c), and with C_R = 2^(K(R)+c) for a shortest decider; (iv) ν(y|x)·1[(x, y) ∈ R]/(1 − v_ν(x)) is lower semicomputable, while conditioning on "answers and abides" is not a lower semicomputable operation. No file proves these. Here is a proof, and what it assumes.

*Formalism (this is the assumption).* U is a universal prefix machine in the sense of Li and Vitányi: dom U is prefix-free, and there is a prefix-free set of codes ⟨M⟩ of prefix machines M with U(⟨M⟩q) = M(q) for all q. (Standard; I did not open the book in this session.) The hypotheses are the strings p ∈ dom U; U(p) halts and outputs the code of a probabilistic machine S_p, which on input x reads random bits and either halts with an answer or runs for ever; ν_p(y|x) := Pr[S_p halts on x with answer y]. w(p) := 2^(−ℓ(p)), and Σ w ≤ 1 by Kraft's inequality. A *decider* of R is a string d ∈ dom U such that U(d) is the code of a machine that halts on every (code of a) pair and outputs 1[(x, y) ∈ R]; K(R) := min ℓ(d). (A program that "draws random bits" can be any program of this form; the point of the formalism is that where the description p ends does not depend on the input x or on the random bits. In a formalism in which the sampler reads its own program tape while it computes on x, the extent of p may depend on x and the class "all programs with weight 2^(−length)" needs a separate definition; there the facts below are not proved by this argument.)

*(i), (ii).* Let M be the prefix machine that on input d p: simulates U on d until it halts (U reads exactly the bits of d, because dom U is prefix-free and U(d) does not depend on anything else), simulates U on p in the same way, and outputs the code of the probabilistic machine S′ that on input x repeats: run S_p on x with fresh random bits; if it halts with y, run the decider U(d) on (x, y); if the answer is 1, halt with y; otherwise repeat. Put φ_d(p) := ⟨M⟩ d p. Then φ_d(p) ∈ dom U, ℓ(φ_d(p)) = ℓ(p) + ℓ(d) + c with c := ℓ(⟨M⟩), and p is read off φ_d(p) after the fixed prefix ⟨M⟩d, so φ_d is injective.

*The image names ν_p^R.* One round of S′ halts with an abiding y with probability ν_p(y|x)·1[(x, y) ∈ R], restarts with probability v(x) := Σ_{y∉R_x} ν_p(y|x), and runs for ever (a draw of S_p that never halts) with the remaining probability. If v(x) < 1, the probability of answering y is ν_p(y|x)1_R/(1 − v(x)) (geometric series). If v(x) = 1, every halting draw violates, the loop never halts with probability 1, and S′ never answers. This is Definition 4.1 in both cases, including "a draw that gives no answer ends the procedure with no answer".

*(iii).* With φ := φ_d: every index has at most one preimage, and w(φ(p)) = 2^(−ℓ(d)−c)·w(p), so Σ_{φ(p)=p′} w(p) ≤ 2^(ℓ(d)+c)·w(p′). With ℓ(d) = K(R): C_R = 2^(K(R)+c). Correct.

*(iv).* v_ν(x) = Σ_{y∉R_x} ν(y|x) is lower semicomputable (R decidable, ν lower semicomputable), hence so is 1/(1 − v_ν(x)) where v_ν(x) < 1, and so is the product with ν(y|x)·1_R (nonnegative factors). For the negative claim, a counterexample to lower semicomputability of the operation "condition on answering and abiding": let ν(y₀|x) = 1/2 and ν(y₁|x) = (1/4)·1[the machine with index x halts], with y₀, y₁ ∈ R_x. ν is lower semicomputable. Its normalisation over abiding answers gives y₀ the probability 1 if machine x does not halt and 2/3 if it halts; a lower approximation of this number would eventually exceed 2/3 exactly when machine x does not halt, so the complement of the halting problem would be recursively enumerable. Hence the normalised semimeasure is not lower semicomputable, and the class of all programs is not closed under that conditioning. The remark's claim is correct.

*What remains assumed.* The formalism above (descriptions that halt and output a sampler; deciders as total programs of the same language) and the standard existence of a universal prefix machine with U(⟨M⟩q) = M(q). Nothing else. The same argument gives the claim after Proposition 4.15 (C = 2^(K(R)+K(G)+c)), with a machine M that reads three descriptions. In (B2) of Theorem 4.11 the assumption "ℓ(φ_r(p)) = ℓ(p) + K_U(R) + c_U" is exactly (i) for the base machine U in this formalism, so (B2) is proved for every U of this kind.

### 1.3 Theorem 4.11(B) (T4.11B): CORRECT, one MINOR omission

(B1). Lengths: 00q(T) has 3 + |T|(d + 2) bits, 011000q(T) has 7 + |T|(d + 2), and 2^(d+2) = 4u, so the weights are (1/8)(4u)^(−|T|) and (1/128)(4u)^(−|T|); 010000 has weight 1/64. Σ_T (4u)^(−|T|) = (1 + 1/(2u))^u < e^(1/2), so the non-U part weighs at most (17/128)e^(1/2) + 1/64 = 0.2346 < 0.24. Prefix-freeness: the four kinds of code word are separated by their first bits (1; 00; 010000; 011000), q(T) is self-delimiting (entries of d + 2 bits beginning with 1, terminated by 0), and 1^c p inherit prefix-freeness from dom U. Checked by hand and on 605 sample code words, block (E). U″ is universal with K_{U″} ≤ K_U + c, and 010000 names r₀, which on every pair code answers 1[y ≠ b] deterministically, so it is a 6-bit decider of R in the sense of 1.2.

(B2). The map φ of the proof names the conditioned sampler in each case (g_T^R = h_T; h_T, r₀ are their own conditionings since they never answer b; 1^c p ↦ 1^c φ_r(p) by the assumption). Preimage weights: 011000q(T) receives (1/8 + 1/128)(4u)^(−|T|) = 17·(1/128)(4u)^(−|T|); 1^c p′ receives at most one preimage, of weight 2^(K_U(R)+c_U) times its own; 010000 itself only; 00q nothing. So C_R = max{17, 2^(K_U(R)+c_U)}. Correct; given 1.2 the assumption of (B2) holds.

(B3). The consistent g_T have weight W = (1/8)(4u)^(−k)(1 + 1/(2u))^(u−k) ≥ (4u)^(−k)/8; the fraction 2u/(2u + 1) of it has x ∉ dom T and answers b with probability 1; the consistent h_T weigh W/16 and never answer b; r₀ has likelihood 0 once k ≥ 1 (it is silent on X_d); the U-part weighs at most 2^(−c) with likelihood at most 1. Hence M_D(b|x) ≥ (16/17)(2u/(2u + 1))/(1 + 2^(3−c)(4u)^k). If k(d + 2) ≤ c − 5 the term 2^(3−c)(4u)^k is at most 1/4, and with (u − k)/u ≥ 3/4, 2u/(2u + 1) ≥ 16/17 ≥ 10/11 (d ≥ 3), V ≥ (3/4)(16/17)(10/11)(4/5) = 0.51337 > 0.51. Empty data: W₀ = (1/8)(1 + 1/(2u))^u ≥ 0.2030 for u ≥ 8 (the file's 0.2013 is a safe lower value), and V ≥ 0.70 since the ratio increases in W₀. Checked by exact enumeration of all 3^8 tables for d = 3 with the worst case for the U-part (all of 2^(−c) on one hypothesis that fits the data and never answers b) for c = 5, 10, 15, 20 and k = 0, 1, 2, and with random U-parts, block (E): every bound holds; e.g. c = 15, k = 2: M_D(b|x) = 0.7613 ≥ 0.7087, V = 0.5710 > 0.51.

"What (B) shows". The argument (fix δ, C₀; choose n*, then d, then c) is correct, with one omission: d must also satisfy d ≥ 3, and n* ≥ 1 (B3 needs k ≥ 1, though for n = 0 the bound 0.70 covers it). MINOR fix: "then d ≥ 3 with 2^d ≥ 4n*". The remark "K := K_{U″}(f) ≤ k₀ + c, so the statement covers n ≤ min{u/4, (K − k₀ − 5)/(d + 2)}" is correct (it is weaker than n ≤ (c − 5)/(d + 2)).

The paragraph on U′ (T4.11U′): every decider and every conditioned memoriser of U′ is a program 1^c p (the programs 0q name memorisers g_T, which are neither), so K_{U′}(R) ≥ c + 1; the empty-table memoriser has weight 2^(−2) = 1/4 and its conditioning can be named only by programs of weight at most 2^(−c−1), so C_R ≥ 2^(c−1); at n = (c − 4)/(d + 2) the bound (K_{U′}(R) ln 2 + ln(1/δ))/n exceeds (d + 2) ln 2 > 1. Correct.

### 1.4 Remark (3) after Theorem 4.5 (R4.5(3)): CORRECT

Both versions of each memoriser fit the same data, so M(D) and the posterior split of the consistent memorisers are unchanged; at an unseen x only the λ-version with x ∉ dom T answers b. So M_D(b|x) = λ·(value of 4.5(b)). Exact enumeration for u = 4, K = 30, one pair seen gives 0.888889, 0.444444, 0.017778 for λ = 1, 1/2, 1/50, equal as rationals to λ·(8/9)/(1 + 18/(2^30 − 1)), block (C).

### 1.5 Remark 4.14 (R4.14): CORRECT

Exact enumeration of the closed class of Corollary 4.6 (u = 4, K = 30, one pair seen), block (D): for C_R = 5, violating 0.7111, silent 0.1778, abiding 0.1111, normalised violation 0.8649; for C_R = 100, 0.8800, 0.0089, 0.1111 and 0.8879. The violating value equals the formula of Corollary 4.6 exactly. Part (ii) (a class of samplers that always answer and contains a ν with v_ν(x) = 1 is not closed for any constant) is immediate from Definition 4.1: ν^R gives no answer at x, so it is not in such a class. Correct.

### 1.6 Proposition 4.15 (P4.15): CORRECT

The formula is the geometric series of the procedure (abiding answer ν(y|x)1_R; violation then G with probability θ; restart with probability (1 − θ)v; no answer with probability 1 − Σν); its denominator is at least θ > 0. For Σ_y ν(y|x) = 1 the numerators sum to 1 − (1 − θ)v. Lower bound for pairs in R: drop the G term. (a): φ(ν)(D_n) ≥ ν(D_n)Π_i(1 − (1 − θ)v_ν(x_i))^(−1) for abiding data; grouping by image gives ≤ C·M(D_n); Jensen for the logarithm and ln(1/(1 − (1 − θ)v)) ≥ (1 − θ)v give the count. (b): as Corollary 4.3(c). In a class of samplers that always answer every image always answers and never violates, so the mixture gives an abiding answer with probability at least the posterior weight of φ(H) ≥ 1/C. All of this was checked on 300 random finite classes (886 data sets; random R, G, θ ∈ {1, 1/2, 1/5, 9/10}; samplers that always answer and semimeasures) in exact rationals, including that ν ↦ ν^{R,θ} is idempotent (so a class made of base samplers and their images is closed), block (F).

### 1.7 4.13 items 4, 5, 6 (I4.13.4, I4.13.5, I4.13.6)

Item 4 is correctly stated as open; I have neither a proof nor a counterexample. The derived constant: V > 0.51 at n₀ together with V ≤ ((c_U + 6) ln 2 + ln(1/δ))/n₀ gives c_U > 0.51·n₀/ln 2 − ln(1/δ)/ln 2 − 6 = 0.7358·n₀ − 1.4427·ln(1/δ) − 6. The file writes 0.74·n₀, which is true only through the sharper value V ≥ 0.51337 of (B3) (0.51337/ln 2 = 0.7406). MINOR: write "c_{U″} > 0.74·n₀ − 1.45·ln(1/δ) − 6 (using V ≥ 0.5133 from (B3))", or use 0.73.

Item 5: Theorem 4.7(c) with P(D_n) = 1 (a deterministic human satisfies A1 with P(y|x) = 1[y = f(x)]), M(D_n) ≥ 2^(−k_c)2^(−n), and 1 − ½e^(−a/n) ≤ ½ + a/(2n). CORRECT.

Item 6: the consistent memorisers weigh at most (1/4)e^(1/2)(4u)^(−n) = 0.412·2^(−n(d+2)) on U′ and (17/128)e^(1/2)(4u)^(−n) = 0.219·2^(−n(d+2)) on U″; dividing by the coin's 2^(−c−k_c)2^(−n) gives the share ≤ 0.42·2^(c+k_c−n(d+1)). CORRECT.

### 1.8 Proposition 4.8(d), the fill (P4.8d): CORRECT

With a = 2^(−K), M = a + (1 − a)ω_k, and from (b) 1 − V(D) = (a + σ(1 − a)ω_k)/M. Jensen for t ↦ t^(1+1/k) at the points 1 and ω_k with weights a, 1 − a gives M^(1+1/k) ≤ a + (1 − a)ω_k^(1+1/k) ≤ a + σ(1 − a)ω_k because ω_k^(1/k) ≤ σ. So 1 − V(D) ≥ M^(1/k). Under (c), ω_k ≥ σ^k/2 and 1 − a ≥ 1/2 give M ≥ σ^k/4. Checked by hand.

### 1.9 The remark after Theorem 2.5 (T2.5r): CORRECT

Recomputed by hand: N = 4, δ = 0.332: ln(1/δ)/4 = 0.27566, tol_4 = √(ln(2/0.332)/8) = 0.47378, (1 − q)^4 = 0.2753, Pr[S ≥ 3] = 0.0665 with |0.75 − q| = 0.4743 > tol; total 0.3418 > δ. At δ = 0.3315: tol = 0.47398 > 0.75 − 0.27603 = 0.47397, failure probability 0.2747 + 0.0058 = 0.2805 < δ. The statements about the grids were not recomputed (not checked).

### 1.10 Remark 2.7(6), (7) (R2.7.6-7): CORRECT

(6)(i): Q̂_N is the run law of the replaying answerer when a run is determined by its answers; kl(Q̂_N(R)‖Q̂_N(R)) = 0, so it lies in 𝓜_N and has d_N = 0. (6)(ii) is Proposition 5.4. (7) is a remark without a mathematical claim beyond Definition 4.1 and Corollary 2.6(iii). Checked by hand.

### 1.11 Item (3) after Corollary 3.7 (I3.7.3): CORRECT

TV between (p², p(1 − p), (1 − p)p, (1 − p)²) and (1/2, 0, 0, 1/2) is 2p(1 − p) for 1 − 1/√2 ≤ p ≤ 1/√2 and ½(4p − 1 − 2p²) for p ≥ 1/√2 (increasing there), minimum √2 − 1 = 0.414214 at p = 1/√2 and its mirror image; 3(√2 − 1) = 1.2426 > 1. Block (B): grid minimum 0.414215, closed form agrees with the direct value to 1.1·10⁻¹⁶.

### 1.12 Proposition 5.4 (P5.4): CORRECT

The argument is a coupling: draw the inputs once; answer with F (lazily) or with fresh draws from P₀; on the event that the inputs are distinct the two transcripts can be taken equal, so Pr[Q_{P₀} ∉ 𝓜_N] ≤ Pr[a repetition] + Pr[Q_{P₀} ∉ 𝓜_N for N runs of P₀] ≤ C(N, 2)·coll(μ) + δ (union bound over pairs; Theorem 2.3 applied with Q = Q_{P₀}). The proof's wording ("same conditional law ... on the event") is exact once read as this coupling. Block (G): exact probabilities for four small cases (u ≤ 10, N ≤ 3, four tests) are 0.948 to 0.995, above the bound in each case (the bound is weak there; this is a consistency check only).

### 1.13 Proposition 6.4 (P6.4): CORRECT

E[s | x*] = Σ P² − 2Σ PA + Σ A² = d(x*)², and the probe being the J-th call with J uniform gives E s = D₂. Range: y₁ = y₂ = y gives s = 1 − 2A(y) + ΣA² ≥ (1 − A(y))² ≥ 0 and ≤ 2; y₁ ≠ y₂ gives s ≥ a² − a + b² − b ≥ −1/2 and s ≤ ΣA² ≤ 1; the extremes −1/2 and 2 are attained or approached. (b) is one-sided Hoeffding on an interval of length 5/2. (c): TV ≤ (√q/2)d(x) by Cauchy–Schwarz on q points; in the coupling a call is unfaithful with probability TV; Cauchy–Schwarz over (run, call) gives E Σ_j d(x_j) ≤ √(E len)·√(E Σ_j d(x_j)²) ≤ √L·√(L·D₂). Binary answers: Σ(P − A)² = 2TV². Block (H): max |E[s|x] − d²| = 6.7·10⁻¹⁶ over 2000 random pairs of laws; range respected; coverage failure of (b) 0/3000 at δ = 0.1, m = 150; (c) holds on random toy scaffolds. The pointer "Theorem R3 of the note applies with β ≤ …" was not checked against R3 (another part).

### 1.14 Proposition 6.5 (P6.5): CORRECT

The mean is handled by Theorem 6.2(c) (independent probes: ξ ≤ C(m, 2)coll(μ)). Changing F at x₀ changes a_F(D) by at most Pr[x₀ is among the probes] ≤ m_D·μ(x₀), because D ∈ [0, 1] and the transcript changes only if x₀ is probed; Σ c_x² = m_D²·coll(μ); the bounded-differences inequality (McDiarmid, quoted from memory in the file; I did not open it; it is standard) with t = m_D√(coll(μ)ln(2/(π_D η))/2) gives π_D·η; the union bound over D. For infinite X the limit argument is needed and is indicated. Block (I): three rules (agreement of two answers; "answer is 0"; a parity rule) for the coin, u = 16 exactly over all 65 536 functions and u = 400 by sampling: the fraction of functions for which some rule exceeds its bound is 0.004 and 0.003 (≤ η), and |E_F a_F − a₀| ≤ C(m, 2)/u in each case.

### 1.15 Theorem 6.6 (T6.6): CORRECT

(a): P_H gives 2/s to s/2 answers, P₀ gives 1/s to each; TV = (s/2)(1/s) = 1/2.

(b): The posterior of H given the procedure's randomness and transcript factorises over inputs, with H_x uniform among the (s/2)-subsets containing the set V of j distinct answers seen at x (the likelihood is Π(2/s)1[a ∈ H_x′]). For v ∈ Y_x∖V, Pr[v ∈ H_x] = C(s − j − 1, s/2 − j − 1)/C(s − j, s/2 − j) = (s/2 − j)/(s − j). The next answer equals v ∈ V with probability 2/s and v ∉ V with probability (s − 2j)/(s(s − j)) ≤ 1/s; against the uniform law the total variation is j/s ≤ (t − 1)/s. The sequential maximal coupling, which keeps the procedure's randomness common, gives Pr[transcripts differ] ≤ Σ_t (t − 1)/s = C(m, 2)/s, and the acceptance probabilities differ by no more. Every step correct.

(c): Hoeffding with summands in [0, μ(x)] and mean μ(x)|B_x ∩ Y_x|/s = μ(x)P₀(B_x|x). (d): as Theorem 6.2(d).

Numbers of the "Reading" (block (J)): exact TV of r answers to one input, computed in exact rationals through the number of distinct values (Stirling numbers): (256, 2): 0.00391 = 1/s; (256, 8): 0.09543 against 0.10938; (65 536, 128): 0.10322 against 0.12402. All three agree with the file. Small exhaustive case (block (K)): s = 4, two inputs, m = 2: the maximal advantage over all 32 deterministic adaptive procedures is 1/4 = C(2, 2)/s (the bound is attained); m = 3: the largest advantage over 401 procedures is 0.375 ≤ 0.75.

The proof of Theorem 6.6 had been seen by the editor only. I have now read it line by line and checked it numerically as above; the note's mark "not independently checked" may be replaced by a statement that it was checked by one second reader (this report).

## 2. The note's text for this part, statement by statement

I read Sections 8.1, 8.2, 8.3, 8.6 and 8.7 of `note.md` (as assembled, lines 448–493 and 539–567) against the proof file. Statements that agree with the proof file in hypotheses, constants and quantifiers, with correct pointers and status, are listed briefly; then the findings, each with the exact sentence and a proposed replacement. Replacements are to be made in `research/sections/property-batch.md` (the section numbers there are 8.1, 8.2, 8.2a, 8.5, 8.6).

### 2.1 What agrees

* 8.1, Pr1: Statement 2.0, a definition; the caveat on additive error. Agrees. The three bounds R1, R2 and H1 belong to other parts and were not checked here (see Section 3; note that the assembled 8.1 reads "E TV ≤ √(2·L·K ln 2/n) (R2)" while the section source reads "E TV ≤ 2√(L·K ln 2/n)"; the difference comes from `research/orchestration/patches.py` and is a matter for the part that owns R2).
* 8.2, the definition of a test and of Λ(B), "in a prefix-free language whose programs all halt": agrees with Section 1.3 and (C4) (attack Finding m6).
* 8.2, Theorem Pr3: a(B) = (Λ(B) + ln(2/δ))/N = a_N(B); the divergence form is Theorem 2.3; |Q̂ − Q| ≤ √(a/2) is Corollary 2.4(a); Q(B) ≤ a(B) for a test that never occurred is 2.4(c); |Q′(B) − Q(B)| ≤ √(2a(B)) and Q′(B) ≤ a(B) for a matching law Q′ are Corollary 2.6(ii), (iii). Status "standard: the Occam's razor bound; Langford 2005, quoted from memory" agrees with the proof file. The hypothesis "independent runs with one law Q" is (IID).
* 8.2, V1(b) as Pr3 for the derived one-call scaffold: Theorem 6.1(c), with A1 for the probes.
* 8.2, the two bullets: the coin bullet is Proposition 5.2 with η = δ and coll(μ) = 1/u, constants identical; the bullet "the same question twice" is Example 5.3 (for a uniformly random g, by Proposition 5.2(a)). "Neither guarantee contains the other at its own price" is 5.3 of the proof file.
* 8.3, Theorem Pr4: r(ν) is r_N(ν) with κ = ln(2/δ); the displayed criterion is c_N of Definition 3.4 (a minimiser exists by Lemma 3.5); the bound is choice 1 of Theorem 3.6 with ε = 0. Status "proved here" agrees. "To compute it" agrees with (C1) to (C3) and Theorem 3.10. "Not said" agrees with item (3) after Corollary 3.7 (checked above, I3.7.3) and item (4).
* 8.6, Pr2(a): (Cl_R) as stated; Theorem 4.2; Corollary 4.3(a), (c); Remark 4.14 numbers (checked above); the pointer to Proposition 4.15. The clause "C_R = 2^(K(R)+c) (standard facts, not proved here, not independently checked)" agrees with the proof file; this report now supplies a proof under a stated formalism (1.2), so the lead may change it to "standard facts; proved in `verification/property-batch-second.md` for programs that are self-delimiting descriptions of samplers".
* 8.6, Pr2(b): the formula is Theorem 4.5(c) with k = n distinct inputs; the threshold n ≤ min{u/4, (K − 2)/log₂(4u + 2)} with u ≥ 5, K ≥ 2 is 4.5(d) (valid for any data set of n pairs); "closing the class … multiplies the value by 1 − 1/C_R" is Corollary 4.6; the last sentence is remark (3) after Theorem 4.5.
* 8.6, "What holds": Theorem 4.7(d) (under A1 and A2, inputs i.i.d. from the law of the fresh input, the human never violating R) and Proposition 4.9 (deployed run = run of M^(T), T uniform). Agrees.
* 8.6, Pr2(c): the constants c ≥ 5, d ≥ 3, u = 2^d, 6-bit program, C_R independent of c, 0.51, n ≤ min{u/4, (c − 5)/(d + 2)} are those of Theorem 4.11(B); "no bound in the price of R and C_R holds on all universal machines" is "What (B) shows"; "Open" is 4.13 item 4.
* 8.7, Pr7(a): Theorem 6.2(a), (c), (b) with η = δ, constants identical; the adaptive procedure and "up to the probability that it puts some input twice" are 6.2(c). Pr7(b): Theorem 6.6(a), (b), with C(m, 2)/s ≤ m²/(2s); "on average over the halves" is the right quantifier. The pointer "Theorems 6.2, 6.6" exists. The last paragraph agrees with Proposition 6.4 (statistic, mean, the q-answer bound, the rate m^(−1/4)); the attributions to Goldreich and Ron and to Batu et al. agree with the proof file (the editor read Batu et al.; Goldreich and Ron was not opened by anyone).

### 2.2 Findings

**N1 (8.6 and 8.7; pointers are ambiguous after 8.4 and 8.5).** Section 8.2 says "numbers cited below refer to that file" (`proofs/property-batch.md`), but Sections 8.4 and 8.5, which come from the part property-online and stand between 8.3 and 8.6 in the assembled note, cite "Proposition 3.5", "Proposition 3.6", "Proposition 3.9", "Corollary 3.4", "Theorem 3.3" of `proofs/property-online.md`. A reader of 8.6 meets "Theorem 4.2", "Proposition 4.15", "Theorem 4.5", "Theorem 4.7, Proposition 4.9", "Theorem 4.11" with no file named. All these pointers are correct for `proofs/property-batch.md`, and 8.7 names the file in its proof line.
* In 8.2, replace "numbers cited below refer to that file" by "numbers cited in Sections 8.2, 8.3, 8.6 and 8.7 refer to that file".
* In 8.6, replace "**Pr2(a), hindsight** (proved here; Theorem 4.2)." by "**Pr2(a), hindsight** (proved here; `proofs/property-batch.md`, Theorem 4.2, whose numbers this section uses)."

**N2 (8.2; claims more than is proved).** Sentence: "On inputs rarer than the tolerance a matching imitator may do anything." This is item (v) of 5.3 of the proof file, which is stated there without proof. For the matching set of Pr3 (the divergence form) a test that never occurred is held to a(B), which is much smaller than the tolerance √(a(B)/2); misbehaviour on a kind of input of frequency between a(B) and √(a(B)/2) that a cheap test B describes would take the imitator out of the matching set. Replacement: "A matching imitator may still give a test that never occurred a probability up to a(B), so misbehaviour confined to kinds of input rarer than that is not excluded."

**N3 (8.3; quantifiers of the optimality of the factor 3).** Sentence: "The estimate is the modified minimum-distance estimate of Mahalanabis and Štefankovič (2008), with weights; it attains the factor 3, which is optimal for rules that return a member and whose number of runs does not grow with the space of runs (Bousquet, Kane and Moran 2019, Theorem 19)." The proof file (Example 3.11(a), "What is known for other estimators") gives the true form: no factor below 3 for rules that return a member, with a number of runs that does not depend on the size of the space of runs, *and for guarantees that hold with probability above 2/3* (their Theorem 19 and Corollary 20, arXiv version 5); the estimate of Definition 3.4 also differs from that of Mahalanabis and Štefankovič by one-sided statistics. The editor's notes ask for the same quantifier in Section 12. Replacement: "The estimate is the modified minimum-distance estimate of Mahalanabis and Štefankovič (2008), with weights and one-sided statistics; it attains the factor 3, and no rule that returns a member does better with a number of runs that does not grow with the space of runs, for guarantees that hold with probability above 2/3 (Bousquet, Kane and Moran 2019, arXiv version 5, Theorem 19 and Corollary 20)."

**N4 (8.6, Pr2(c); status not marked).** Sentence: "**Pr2(c), the machine** (proved here; Theorem 4.11)." Part (B2), "C_R does not depend on c", rests on the standard facts of Remark 4.4 for the base machine U (proof file, 11.3, row Theorem 4.11(B)); the editor's notes say so ("the same facts enter Pr2(c)"), but the text marks the clause only in Pr2(a). Replacement: "**Pr2(c), the machine** (proved here, given the standard facts on all programs used in Pr2(a); Theorem 4.11(B))." If the lead adopts the proof of Section 1.2 of this report, the mark may name it instead.

**N5 (8.6, Pr2(b) and Pr2(c); "fresh input").** Sentences: "After n questions at distinct inputs the mixture answers b at a fresh uniform input with probability ((u − n)/u)·…" and, in Pr2(c), "the mixture violates R at a fresh input with probability above 0.51". The formula with the factor (u − n)/u, and the 0.51 of Theorem 4.11(B), are for an input drawn uniformly and independently of the data (Theorem 4.5(c), V(D)), which may be one already seen; at an unseen input the probability is the formula without the factor (u − n)/u (Theorem 4.5(b)). Replacement in Pr2(b): "at an input drawn uniformly, independently of the data, with probability …"; in Pr2(c): "at an input drawn uniformly from the u inputs, independently of the data, with probability above 0.51". (Section 8.6, "What holds", uses "the law of the fresh input" correctly.)

**N6 (8.6, Pr2(b); normalisation).** Sentence: "and all memorisers (a table on some inputs, the answer b elsewhere) with weights proportional to (4u)^(−size)." The exact formula needs the memorisers' total weight to be 1 − 2^(−K) (Theorem 4.5, c₀). Replacement: "… with weights proportional to (4u)^(−size) and of total weight 1 − 2^(−K)." And "Closing the class under conditioning multiplies the value by 1 − 1/C_R." holds for the particular closure of Corollary 4.6. Replacement: "Closing the class under conditioning as in Corollary 4.6 (each memoriser shares its weight with a copy that is silent off its table) multiplies the value by 1 − 1/C_R."

**N7 (8.6, Pr2(a); attribution to the researcher's notes).** Sentence: "So the inputs seen, asked again, give at most ln C_R expected violations, and, as the researcher's notes claim, the mixture violates R with probability at most 1 − 1/C_R at every input." The researcher's notes claim that "the probability of P-abiding generalization is at least 2^{−C(P)}" (`research/understand/notes.md`, Q5), which is a statement about abiding answers; what is proved is the weaker "not violating", and the next sentence of the note says that the difference may be silence. Replacement: "… and the mixture violates R with probability at most 1 − 1/C_R at every input: the researcher's claim that abiding has probability at least 2^(−C(R)), with 'abiding' read as 'not violating'."

**N8 (8.7; the summarising sentence claims more than Pr7(b)).** Sentence: "So with one answer per input, or with long strings as answers, test frequencies are all that can be certified about a human who may vary." Theorem 6.6 is a statement about one pair of humans (uniform on s answers against uniform on a random half), so it shows that no procedure certifies a distance for *every* human whose answers are long strings; it does not show it for a given human with long-string answers (a human who is nearly deterministic on long strings is caught by a repeated question). "All that can be certified" is also a reading, not a theorem: what is proved is that a bound on the distance between answer laws cannot be certified. Correction 4 of Addendum 3 asks for the quantifier. Replacement: "So no procedure certifies, for every human who may vary, a bound on the distance between the imitator's and the human's answer laws: not with one answer per input (Pr7(a)), and not with repeated questions when the human may spread his answers over many more than m² possible strings (Pr7(b)). What such answers estimate are test frequencies."

**N9 (8.7, Pr7(b); status).** "(not independently checked)" was right when written. This report checks Theorem 6.6 line by line and numerically (1.15). The lead may write "(checked by one second reader)" or keep the mark; either agrees with the proof file once this report is added to its Section 11.

**N10 (statuses that the note does not need to change).** The note gives no special mark to Remark 4.14, Proposition 4.15, Proposition 6.4 or item (3) after Corollary 3.7, which had been examined by the attack report and the editor; this agrees with the convention that only statements seen by the editor alone are marked. I have now checked these too (Section 1).

### 2.3 Outside this part's sections (noticed in passing, not part of the assignment)

* Section 12 of the note: "the factor 3 is optimal for such rules (Bousquet, Kane and Moran 2019)" lacks the quantifiers of N3; the editor's notes of this part already ask the part related-work for them.
* Section 0, item 2, and Section 3.3 (other parts) cite Pr7 correctly as "with questions put twice, a squared distance between answer distributions".

## 3. What I did not check

* The statements that both verifiers had found correct and that no finding touched, and that are not in the list of Section 1: Lemmas 1.1, 2.1, 2.2, 3.2, 3.5; Theorems 2.3, 3.3, 3.6, 3.10; Corollaries 2.4, 2.6, 3.7; Propositions 3.8, 3.9, 4.10, 4.12; Theorems 4.2, 4.5, 4.7; Corollaries 4.3, 4.6; Proposition 5.2; Example 5.3; Theorems 6.1, 6.2; Example 6.3; Theorem 4.11(A). I read the statements of those that the note uses and compared them with the note (Section 2.1); I also re-read the proofs of Theorem 4.2, Corollary 4.3, Theorem 4.5(a)–(d), Corollary 4.6, Theorem 4.7(a)–(d), Theorem 6.2(c), (d) and Proposition 5.2 while checking statements that depend on them and found nothing wrong, but I did not recompute them constant by constant, and they are reported here as not checked by me.
* The grid statements in the remark after Theorem 2.5 (no failure below π(R)δ = 0.332 on the grids; the ratio 1.3441).
* Theorem R1 (used by Proposition 4.9), Theorem R3 (named after Proposition 6.4), H1, R1 and R2 as quoted in 8.1, and the lower bounds of `proofs/lower-bounds.md` named in Section 5.1 of the proof file: they belong to other parts. In particular the assembled 8.1 has "E TV ≤ √(2·L·K ln 2/n)" where the section source has "2√(L·K ln 2/n)" (a patch); I did not check which is right.
* 4.13 item 4 (open) and Section 8.1 of the proof file (open questions): not attempted.
* The literature. I did not open any source in this session: not Li and Vitányi (for the universal prefix machine used in 1.2), not McDiarmid (Proposition 6.5), not Hoeffding, not Bousquet, Kane and Moran (N3 relies on the proof file's quotation of version 5, read there by both verifiers and the editor), not Mahalanabis and Štefankovič, not Dwork et al., not Batu et al., not Goldreich and Ron, not Langford. I did not search the web.
* The numerical checks of Section 1 are checks of instances, not proofs; the proofs are the line-by-line readings given with each verdict. Block (G) (Proposition 5.4) and block (K) for m = 3 (Theorem 6.6, a sample of procedures) are weak checks; the verdicts on these statements rest on the readings.
