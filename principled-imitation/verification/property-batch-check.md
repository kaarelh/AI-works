# Line-by-line check of `research/prove-c/property-batch.md` (key: property-batch)

Referee's report. Checked file: `research/prove-c/property-batch.md` as it stood on 15 November, 22:49 UTC (788 lines, md5 `d38ce00b…`; it did not change during the check), with its scripts `research/prove-c/code/property-batch_*.py`; and, against it, Sections 8.1, 8.2 and 8.5 of `note.md`. The file was not changed. Labels covered: Pr1 to Pr4, and the certificate V1(b).

The report has eight parts: (I) what was done and the result in brief; (II) one entry per statement; (III) the corrections that must be made, ordered by importance; (IV) Sections 8.1, 8.2 and 8.5 of the note; (V) edge cases and hypotheses; (VI) the numerical checks; (VII) the literature that was checked in a source; (VIII) what was not checked.

Verdicts: **CORRECT**; **MINOR** (correct after a small fix, which is given); **GAP** (a step is missing; it is named and, where possible, filled); **WRONG**.

---

## I. What was done, and the result in brief

**Done.** Every numbered statement was read line by line and every constant was recomputed by hand. The five scripts of the prover were run again; each reproduces its saved output exactly (compared with `diff`). The three scripts of the earlier worker in `research/prove-b/code/` also run without error and agree. Five new scripts were written from the definitions, without use of the prover's code (`verification/code/property-batch_check_*.py`, outputs next to them). They use exact rational arithmetic and full enumeration wherever the sample space is small, so that failure probabilities are exact numbers and not frequencies. Three sources were consulted in this session for the literature of Section 3.6: two were read in the PDF, one was seen through a summary of its page (Part VII).

**Result.**

1. **No statement is wrong.** All theorems, propositions, corollaries and examples hold as stated, with the constants stated. This includes the main results: Theorem 2.3 with Corollaries 2.4 and 2.6 (Pr3); Theorem 3.3, Theorem 3.6 with the factor 3 and the term √((2K(ν) ln 2 + 2 ln(2/δ))/N), Proposition 3.8, Theorem 3.10 (Pr4); Theorems 4.2, 4.5, 4.7 and 4.11 (Pr2); Proposition 5.2; Theorems 6.1 and 6.2.
2. **One gap, in the use made of Theorem 4.11 (Pr2(c)), not in its statement.** On the machine U′ that the file constructs, the property R is not cheap: a program that decides R is a program of U behind the prefix 1^c, so K_{U′}(R) ≥ c + 1, and the constant with which the class of all programs of U′ is closed under conditioning on R is at least 2^(c−1). The phenomenon of the theorem lasts (c − 4)/(d + 2) questions, which is fewer than K_{U′}(R). So U′ does not separate the price K from the price K(R) measured on the same machine, and the sentences "K cannot be replaced by a function of R" (after Proposition 4.9), 4.13 items 3 and 4, and the placeholder of `note.md`, Section 8.5 ("not bounded in terms of K(R)") are not yet supported for the class of all programs. The gap is filled in Part II (entry for Theorem 4.11) by a variant U″ of the machine: one more program of 6 bits that decides R, and the conditioned memorisers at four more bits. Then K_{U″}(R) ≤ 6 and the closure constant is at most max{17, 2^(K_U(R)+c_U)}, both independent of c, and the mixture still violates R at a fresh input with probability above 0.51 for all n ≤ min{u/4, (c − 5)/(d + 2)}. The variant was checked by enumeration.
3. **Small corrections** (Part III): a convention 0·∞ = 0 in Theorems 4.2 and 4.7(b); "attained" for a floor that is only approached (Corollary 4.6); one line missing in Proposition 4.8(d); the conclusion of Theorem 6.2(d) is one-sided, and the summary says more; the attribution to Bousquet, Kane and Moran needs its exact quantifiers (read in the source: Part VII); the remark that the counterexample to the draft's Pr3 "needs δ close to 1" is not exact (δ = 0.34 is enough); Remark 2.7(4) is "not used below" but Section 5.1 rests on it; three letters are used twice.
4. **`note.md`.** Section 8.1 is correct and should say what closeness in total variation does not control. Section 8.2 has two sentences that say more than is proved ("nothing is assumed about the human"; "each input is seen once"). The placeholder of Section 8.5 joins two statements that hold in different classes; the exact replacement is in Part IV.

---

## II. One entry per statement

Notation as in the file. "Recomputed" means that the constant was derived again from the previous line of the proof.

### Section 1

**Lemma 1.1 (likelihood of a run). CORRECT.** The leaves of the tree of answer sequences have probabilities Π_j ν(y_j|x_j) that sum to 1 because the depth is at most L and ν(·|x) is a probability on Y ∪ {⊥}. Runs with no call (next_1 = STOP) have L_ν = 1 and are covered by the empty product. Checked exactly on 300 random scaffolds of horizon 3 with STOP at any step, adaptive inputs and semimeasure samplers (script `sec2`, block 1). The lemma tacitly assumes that the maps next_j are measurable; for a scaffold that is a program this is so.

### Section 2 (Pr1, Pr3)

**Statement 2.0 (Pr1). CORRECT.** It is the definition of total variation as a supremum over events. The last clause ("properties of probability below ε are not controlled") is the caveat that Section 8.1 of the note lacks.

**Lemma 2.1 (Chernoff bound in divergence form). CORRECT.** Recomputed: e^(−λx)(1 − q + qe^λ) = (q/x)^x((1 − q)/(1 − x))^(1−x). The cases q ∈ {0, 1}, x = q and x = 1 are treated. Exact binomial check for N from 1 to 300 and q on a grid that contains 0 and 1: the largest ratio of a tail to its bound is 1.000000 (equality at x = 1), of Pr[kl > a] to 2e^(−Na) is 0.746.

**Lemma 2.2. CORRECT.** (i) g′(q) = (q − p)(1/(q(1 − q)) − 4); (ii) both integrals recomputed; (iii) trivial. No violation on a 201 × 201 grid that includes the end points.

**Theorem 2.3 (Pr3, divergence form). CORRECT.** Union bound over Lemma 2.1 with 2e^(−N·a_N(R)) = π(R)δ. The only hypothesis is (IID), and it is used (N·Q̂_N(R) is binomial). The tag "NEW" means "not in the candidate theory" (the file says so); the statement itself is the Chernoff bound in relative-entropy form with a weighted union bound, which is standard in the learning literature under the name "Occam's razor bound" (J. Langford, "Tutorial on practical prediction theory for classification", *JMLR* 6 (2005) 273–306; quoted from memory, not checked in this session). The final text should call it standard.

**Corollary 2.4. CORRECT.** Recomputed: (b) from q − p̂ ≤ √(2aq): √q ≤ (√(2a) + √(2a + 4p̂))/2, so q ≤ p̂ + a + √(a² + 2ap̂) ≤ p̂ + 2a + √(2ap̂); and √p̂ ≤ √q + √(2a). (c) q ≤ 1 − e^(−a) ≤ a. Checked at the end points of {q : kl(p̂‖q) ≤ a} for 20000 random (p̂, a), including p̂ ∈ {0, 1}: no violation.

**Theorem 2.5 (Pr3 as the draft states it). CORRECT, with a MINOR point in the remark after the counterexample.**
(a), (b): correct. (c): the case distinction (q ≤ q_R; q > t; q_R < q ≤ t) is exhaustive and gives 3π(R)δ/2. The counterexample (N = 1, δ = 0.905, Q(R) = 0.2) is correct: tol = 0.6297, ln(1/δ) = 0.0998, the joint statement fails with probability 1.
*Minor.* The file says "The example needs δ close to 1." This is not so. With one test of weight 1, N = 4, δ = 0.34 and Q(R) just above ln(1/δ)/N = 0.2697: tol = 0.4706; R never occurs with probability 0.2844 (then the one-sided claim fails); R occurs three or four times with probability 0.0626 (then |Q̂ − Q| ≥ 0.4803 > tol); the total is 0.3470 > δ. On a grid (N ≤ 200) the joint statement of the draft fails for π(R)δ = 0.34 and for most larger values, and the exact failure probability stays below π(R)δ for π(R)δ ≤ 0.32 (largest ratio 0.9967; not proved). The largest ratio found anywhere is 1.3441, below the proved 1.5 (scripts `joint25c` and `sec2`, block 5). Fix: replace the sentence by "Counterexamples exist for π(R)δ as small as 0.34 (N = 4); for π(R)δ ≤ 0.32 none was found on a grid, and no proof is given." The recommendation of the file stands: the note should state Pr3 in the form (G), which gives both halves at confidence 1 − δ with ln(2/(π(R)δ)) in the one-sided bound.

**Corollary 2.6. CORRECT.** Recomputed: the interval of 2.4(b) has length 2√(2ap̂) + 2a ≤ 2√(2a·Q(R)) + 6a; the complement gives the form with q̄. For Q(R) and Q′(R) anywhere in {q : kl(p̂‖q) ≤ a}: no violation in 100000 cases; the largest ratio of |Q′ − Q| to the bound is 1.0000, so the bound is reached in the limit (for p̂ near 1/2 and small a the interval has length close to √(2a)). The sentence "the price of a property is its own complexity" needs the attribution of `outline.md`, Addendum 2, item 5 (outcome indistinguishability and multicalibration) in the final text; the proof file does not carry it.

**Remarks 2.7. CORRECT; item 4 MINOR.** Items 1, 2, 3, 5 are correct. Item 4 is "quoted without proof; it is not used below", but Section 5.1 uses it for "neither price can be lowered". Fix: either say in 5.1 that the lower bound for the second price is a standard fact that is not proved here, or add the proof, which is short: for one event of probability 1/2 and an integer k ≥ N/2, Pr[S = k] = C(N, k)·2^(−N) ≥ e^(−N·kl(k/N‖1/2))/(N + 1) (the standard lower bound for a binomial coefficient by the method of types) and kl(1/2 + t‖1/2) ≤ 4t² for 0 ≤ t ≤ 1/2; so for M independent events the largest deviation is at least t with probability at least 1 − exp(−M·e^(−4N(t + 1/N)²)/(N + 1)), which is at least 1 − e^(−(N+1)) for t = ½·√(ln(M/(N + 1)²)/N) − 1/N when (N + 1)³ ≤ M and ln M ≤ N; for such M this t is at least ½·√(ln M/(3N)) − 1/N. Exact values (script `sec2`, block 6): for N = 400 and M = 10⁴ the largest deviation is at least ½√(ln M/N) = 0.076 with probability 1.000000, and exceeds tol_N = 0.1235 (π = 1/M, δ = 0.1) with probability 0.0065. The parenthesis in item 2 about martingales is vague ("survives") and unproved; it is marked as such and nothing rests on it.

### Section 3 (Pr4)

**Definition 3.1, Lemma 3.2. CORRECT.** (a) Scheffé's identity; it also holds when two indices name the same law (both sides are 0) and with ties added to the set (checked exactly for run laws of random scaffolds, 219 of 300 trials with ties). (c) recomputed: r² + s² = (K ln 2 + max{κ, ln(2/δ)})/(2N).

**Theorem 3.3 (Pr4 in the class, the draft's estimator). CORRECT.** Recomputed: Σ_{ν≠ν′} w(ν)w(ν′) ≤ 1; with π*(A) = w(ν̂)w(ν₀)/2 ≥ 2^(−2K)/2, 2·tol* = √((4K ln 2 + 2 ln(4/δ))/N); without a family 𝓣, √((4K ln 2 + 2 ln(2/δ))/N), which is the draft's constant; (iii) 2·tol*_N(R) = √(2 ln(4/(π(R)δ))/N). A matching index of largest weight exists because at most 1/w(ν₀) indices have weight ≥ w(ν₀). Exact multinomial check on 1500 random classes, with ties, duplicate laws, weights of total below 1, with and without tests: the largest failure probability is 0.049·δ; the check requires the claims for every matching index of the largest weight. The hypothesis "Q = Q_ν₀" is about run laws, as the table of Section 7 says. In the summary table the row for this theorem says "within 2·tol"; it is 2·tol*, with π(R)/2.

**Definition 3.4, Lemma 3.5. CORRECT.** (b) r_N(ν′) ≥ 1 iff w(ν′) ≤ e^(κ−2N). (c) every ε-minimiser has r_N ≤ 1 + r_N(ν₁) + ε. Checked on 2000 random instances.

**Theorem 3.6 (oracle inequality). CORRECT.** Every line of Steps 1 to 3 was recomputed:
U_N(ν*, ν′) ≤ TV* + r_N(ν′) + s on E₁, so c_N(ν*) ≤ TV* + s + r_N(ν*);
TV(Q_ν̂, Q_ν*) = U_N(ν̂, ν*) + [Q̂_N(A) − Q(A)] + [Q(A) − Q_ν*(A)] ≤ (Δ_N(ν̂) + r_N(ν*)) + (r_N(ν̂) + s) + TV* = c_N(ν̂) + r_N(ν*) + s + TV*;
with c_N(ν̂) ≤ c_N(ν*) + ε this is 2·TV* + 2r_N(ν*) + 2s + ε, and the triangle inequality gives the factor 3.
The union bound is over single weights w(ν′) because ν* does not depend on the data; E₂ is stated for all ν′ ≠ ν*, so it may be used at the data-dependent index ν̂. The minimiser ν* of g exists by Lemma 3.5(c). Choice 1: 2r_N(ν) = √((2K(ν) ln 2 + 2 ln(2/δ))/N). Choice 2: √(2K(ν) ln 2/N) + √(2 ln(2/δ)/N). The answer to the question of the task ("in the exact form you can prove") is therefore: factor 3, C = √2 in front of √((K(ν) ln 2 + ln(2/δ))/N), for every ν at once, for every law Q of independent runs.
Numerical: on 2600 random classes (exact multinomial sums) the events E₁ and E₂ fail with probability at most 0.28·δ, and on E₁ ∩ E₂ the inequality (O) held for every ε-minimiser in every sample (0 violations), which checks the proof and not only the conclusion. In the regime where distances in the class are of the order of the bound (indices Bern(p_i), N up to 400, exact binomial sums) the largest failure probability is 0.117·δ (script `sec3`, blocks 1 and 11).

**Corollary 3.7. CORRECT.** (c) recomputed: ∫₀^∞ 2e^(−Nt²/2) dt = √(2π/N). Exact expectations on 400 random classes: largest E TV/bound = 0.46.

**Proposition 3.8. CORRECT.** Recomputed: E₁ fails with probability at most Σ_{ν′} min{w(ν₀), w(ν′)}δ′/2 ≤ δ′/2; E₂ at most Σ_{ν : w(ν) ≥ w(ν₀)} w(ν₀)δ′/2 ≤ δ′/2; with G′ the total is 2δ′ = δ. TV = U_N(ν̂, ν₀) + [Q̂_N(A) − Q(A)] ≤ max{r_N(ν̂), r_N(ν₀)} + r_N(ν₀) = 2r_N(ν₀), because w(ν̂) ≥ w(ν₀). Exact check: largest failure probability 0.069·δ.

**Proposition 3.9. CORRECT.** Checked as a deterministic implication on the event of Theorem 2.5(a): 6223 samples, 0 violations, for every ε-minimiser.

**Section 3.5, (C1) to (C4). CORRECT.** The three requirements are the right ones: a list of the indices of weight above a threshold; exact comparison of two likelihoods on a recorded run; the numbers Q_ν(A_νν′), for which D₀ and Λ must be known or sampled (a closed system). Two small remarks. In (C4) the count "fewer than (δ/2)e^(2N) tests matter" is for tol_N; for the tolerances tol* of Theorem 3.3 and tol′ of Proposition 3.8 the count is (δ/4)e^(2N). And (C1) could say that the list is finite but of length up to about e^(2N(1+r_N(ν₁)+ε)²−κ); nothing in the file claims that it is short.

**Theorem 3.10 (simulated runs). CORRECT.** The four events fail with probability at most δ/2 each; the chain of inequalities was recomputed with r̃ = r_N + r_{N_s}. Independence between the simulations of different indices, and between the simulations and the data, is not needed, as the file says. Exact sums over the data and both simulated samples for two indices in the critical regime: largest failure probability 0.0015·(2δ). *Minor:* the sentence "for N_s → ∞ the bound becomes that of Theorem 3.6" should add "at confidence 1 − 2δ" (or the two failure probabilities should carry separate names).

**Examples 3.11. (a) CORRECT, with a MINOR point in the attribution; (b), (c), (d), (e) CORRECT.**
(a) Recomputed: A_ν₁ν₂ = {2, 3}, A_ν₂ν₁ = {1, 4}, both masses 3/4 + ε₀, TV(Q_ν₁, Q) = 3/4 − ε₀, TV(Q_ν₂, Q) = 1/4 + ε₀, ratio 3 − 16ε₀/(1 + 4ε₀). Exact binomial sum: for odd N with r_N < 1/4 (N ≥ 31 at δ = 0.1) the estimate is ν₁ with probability exactly 0.500000 and there is no tie; for N = 5 (r_N = 0.61) the two criteria tie with probability 0.9375, so the condition r_N < 1/4 is needed, as stated. The example agrees with Lemma 11 of Mahalanabis and Štefankovič (read in the source, Part VII).
*Minor.* "That no estimator which must return a member of the class can have a factor below 3 is Theorem 2 of Bousquet, Kane and Moran" is true only with their quantifiers, which the file asks to have checked. Read in the source (Part VII): the statement is about a number of samples that does not depend on the domain. Exactly: on an infinite domain, for arbitrarily small β there are two densities such that every proper algorithm, with every number of samples, returns for some target with opt = β/2 a member with TV > (3 − 6β)·opt + β², with probability at least 1/3 (their Theorem 19); on a domain of M points the same holds as long as the number of samples is below a bound of the order of √M that depends on β (their Theorem 21; the exact expression should be copied from the source, the text extraction used here does not show whether β is under the root). On a fixed finite domain the factor 1 is reached with enough samples, for instance in Example 3.11(a) itself by the member closest to the empirical law. Fix: quote Theorem 19 and say "with a number of runs that does not depend on the size of the space of runs".
(b) Recomputed and enumerated for u = 7, N = 3: without a penalty the replay is the only minimiser for each of the 35 samples of distinct answers; U_N(Q, Q_S) = 1 − N/u. (c) Exact: no index matches with probability 0.9648 at N = 100 and 1.000000 at N = 1000.

**The literature paragraph of 3.6. CORRECT** as far as it could be checked; see Part VII.

### Section 4 (Pr2)

**Definition 4.1 and (Cl_R). CORRECT.** ν^R is a semimeasure; (ν^R)^R = ν^R; C_R ≥ 1 follows from Σ_ν w(ν) ≤ C_R·Σ_{ν′∈φ(H)} w(ν′). The closure assumption of the task is made exact, and "abiding" is rightly read as "not violating".

**Theorem 4.2 (hindsight; Pr2(a)). MINOR.** The proof is correct. The statement sums over all ν, and for an index with ν(D_n) = 0 and v_ν(x_i) = 1 at a seen input the term is 0·∞. Fix: add "(the sum runs over the indices of positive posterior weight; for the others the term is 0)". In the random closed classes of the check such indices occurred 10309 times. Otherwise: 51592 abiding data sets in 400 random classes closed under conditioning, 0 violations, largest ratio of the left side to C_R 0.9992.

**Corollary 4.3. CORRECT.** (a) Jensen for the logarithm and v ≤ ln(1/(1 − v)); (b) Markov; (c) recomputed. No violation in the same enumeration; the smallest value of C_R times the posterior weight of the never-violators is 1.000000, so (c) is attained in some classes.

**Remark 4.4. CORRECT** as a statement of standard facts (not proved in the file, and not proved here). Note for the entry on Theorem 4.11: in this remark K(R) and the constant c belong to the same language as the class.

**Theorem 4.5 (memorisers; Pr2(b)). CORRECT.** Recomputed: Σ_T (4u)^(−|T|) = (1 + 1/(2u))^u; consistent memorisers have weight (1 − 2^(−K))(4u + 2)^(−k); (b) and (c) follow; (d) 2^(−2)/(1 − 2^(−2)) = 1/3 and (3/4)(10/11)(3/4) = 0.5114; (e) V ≤ (2^K − 1)/(4u + 2)^k. All formulas agree with the enumeration of all 3^u tables for u from 1 to 5 in exact rationals, also for data with repeated inputs. (d) was checked on 316 triples (u, K, k) up to u = 2²⁰, K = 1000; the smallest value found is 0.68. The numbers quoted for u = 2²⁰, K = 1000 were recomputed: β = 22.0000007, (K − 2)/β = 45.36, V = 1, 0.99999, 0.999971, 0.999958, 0.998981, 0.000244, 5.8·10⁻¹¹, 1.4·10⁻¹⁷. This answers item 2(b) of the task; the class is finite, the human is in it, R = "the answer is not b" and μ is uniform.

**Corollary 4.6. MINOR.** The construction and the formula are correct (enumerated for u from 2 to 4 and C ∈ {1/2, 1, 4}: the weights sum to 1, φ names the conditioned kernels, C_R = C + 1). But the floor is not attained: the value is (1 − 1/C_R)·(2u/(2u + 1))/(1 + (4u + 2)^k/(2^K − 1)) < 1 − 1/C_R in every case (for C_R = 2, u = 2²⁰, K = 1000, k = 10: 0.49999976). Fix: in the title, in the summary table and in the sentence "The bound of Corollary 4.3(c) cannot be improved" write "is approached (it is the supremum over u and K)".

**Theorem 4.7 (foresight). CORRECT; MINOR as for Theorem 4.2.** (a) The supermartingale step was recomputed, including the case V_ν = 1 (then ζ_n = 0 for n ≥ 1 almost surely, and ζ₀ = 1 with 0⁰ = 1). (b) Ville. (c) Jensen for t ↦ (1 − t)^(−n) and 1 − e^(−a) ≤ a. (d) to (g) recomputed. In (b) the sum over ν needs the same convention 0·∞ = 0. In the summary table the row says "in any class … so V(D_n) ≤ (K ln 2 + ln(1/δ))/n"; the second half needs the human in the class (it is (d)). Exact enumeration on 120 random instances (inputs of μ-probability 0, semimeasure classes with and without the human, indices with V_ν = 1): E[Z_(n+1) | D_n] ≤ Z_n on every path; Pr[some Z_n ≥ 1/δ] ≤ 0.80·δ; no violation of (b) to (g) on the complementary event.

**Proposition 4.8 (recognisers). MINOR.** (a), (b), (c) are correct (enumeration over all subsets for u ∈ {3, 4, 6, 8}; (c) and the numerical claims on 728 further cases; σ = 1/4 gives V ≥ 2/3 for k ≤ min{(K − 5)/2, √(u/4)} because (3/4)/(1 + 2^(−3)) = 2/3). In (d) the file writes "Theorem 4.7(c) … gives 1 − V(D) ≥ (δ·M(D))^(1/k)" for a fixed data set. Theorem 4.7(c) holds on an event of probability 1 − δ over random inputs, so one line is missing. Fill: in this class the inequality holds for every data set, even with δ = 1. Indeed, with a := 2^(−K), M = a + (1 − a)ω_k and 1 − V = (a + σ(1 − a)ω_k)/M; by Jensen's inequality M^(1+1/k) ≤ a + (1 − a)ω_k^(1+1/k), and ω_k^(1/k) ≤ σ; so M^(1+1/k) ≤ a + σ(1 − a)ω_k, that is, 1 − V(D) ≥ M(D)^(1/k) ≥ (δM(D))^(1/k). Checked on all cases above.

**Proposition 4.9 (rehearsal). CORRECT, given Theorem R1 of `note.md`** (which belongs to the part rehearsal-core). The log-sum step KL(p‖q) ≥ ln(1/(1 − v_q(x))) is correct for a semimeasure q. The step of R1 that is used was checked here with exact expectations on a scaffold of horizon 2 with runs of variable length, 200 random classes, n ∈ {1, 3, 6}: Σ_t E[Σ_calls KL_t] ≤ 0.997·L·K ln 2, and the expected number of violating calls of the run of M^(T) is at most 0.55·L·K ln 2/n.

**Proposition 4.10 (memorisers and a coin). CORRECT.** Enumerated for u from 2 to 4 with data of up to 3 pairs with repeats; the quoted values 1.00, 0.33, 2.4·10⁻⁷, 1.1·10⁻¹³ were recomputed. The reading (4.7(g) with M ≥ w(S)·S(D_n)) was recomputed: (1 − v)^n = 2^(−nℓ_S − nη).

**Theorem 4.11 (Pr2(c)). The statement is CORRECT; its reading has a GAP, which is filled here.**
*The statement.* Recomputed: Σ w ≤ 2^(−c) + (1/4)(1 + 1/(2u))^u < 0.5 + 0.413; W_m ≥ (4u)^(−k)/4; M_D(b|x) ≥ (2u/(2u + 1))/(1 + 2^(−c)/W_m); with k·log₂(4u) ≤ c − 4 the last denominator is at most 5/4, and (3/4)(10/11)(4/5) = 0.5455. Enumerated with random semimeasures as H₀ for u ∈ {2, 3, 5, 8}. The code of U′ was generated for d = 1, 2, 3: lengths 2 + |T|(d + 2), prefix-free, Kraft sum (1/4)(1 + 1/(2u))^u, no codeword begins with 1. The parenthesis (h_T at four more bits: constant 17, factor 16/17, 0.5134) is correct.
*The gap.* The file reads the theorem as showing that for a universal class the price K "cannot be replaced by a function of R" (sentence after Proposition 4.9), that "universality of the machine gives nothing more" (4.13, item 3), and that a bound C·(K(R) + log n)/n for natural machines "would need a definition of natural that excludes the machines of Theorem 4.11" (4.13, item 4). The summary table calls R "a constant-length property". But the complexity of R that matters here is its complexity on the machine of the class (Remark 4.4 takes the decider r from the same language). On U′ every program that decides R has the form 1^c r with r a program of U, so K_{U′}(R) = c + K_U(R) ≥ c + 1. The conditioned memorisers h_T are also programs of U behind 1^c, so the constant C_R of (Cl_R) for the class of all programs of U′ is at least 2^(c−1): the memoriser with the empty table has weight 1/4, and its conditioning, the sampler that never answers, is named only by programs 1^c p, of weight at most 2^(−c−1). The phenomenon lasts for n ≤ (c − 4)/(d + 2) < K_{U′}(R). So on U′ a bound such as V(D_n) ≤ (K(R)·ln 2 + ln(1/δ))/n is not contradicted (at n = (c − 4)/(d + 2) its right side exceeds (d + 2)·ln 2 > 1), and neither is a bound in terms of log₂ C_R. Theorem 4.11 as constructed does not separate the two prices on one machine.
*The fill.* Let U be a universal prefix machine, d ≥ 3, u = 2^d, X = {0, 1}^d, c ≥ 5. Define U″ by

 U″(1^c p) := U(p);
 U″(00 q) := g_T, with q the code of the table T as in the file;
 U″(010000) := the program that, given the code of a pair (x, y), answers 1 if y ≠ b and 0 if y = b, and gives no answer at every other input, in particular at every x ∈ X (codes of pairs are taken outside {0, 1}^d);
 U″(011000 q) := h_T, the memoriser that answers T(x) on dom T and gives no answer elsewhere.

The programs form a prefix-free set. The weights are 2^(−c)·2^(−ℓ(p)), (1/8)(4u)^(−|T|), 2^(−6) and (1/128)(4u)^(−|T|); their sum is below 2^(−c) + 0.22 + 0.02 < 1. Then:
(1) K_{U″} ≤ K_U + c, and K_{U″}(R) ≤ 6 for every c.
(2) The class of all programs of U″ satisfies (Cl_R) with C_R = max{17, 2^(K_U(R)+c_U)}, where c_U is the constant of Remark 4.4 for U; C_R does not depend on c. (Map 1^c p to 1^c φ_r^U(p); map 00q and 011000q to 011000q, where (1/8 + 1/128)/(1/128) = 17; map 010000 to itself, since it never answers b.)
(3) For every f: X → {0, 1}, every data set D of pairs (x, f(x)) with k distinct inputs and every x not among them, with W := (1/8)(4u)^(−k)(1 + 1/(2u))^(u−k) ≥ (4u)^(−k)/8: the consistent g_T have total weight W, those with x ∉ dom T have weight W·2u/(2u + 1), the consistent h_T have weight W/16, the decider has likelihood 0 if k ≥ 1, and all other programs have weight at most 2^(−c). So for k ≥ 1

 M_D(b|x) ≥ (16/17)·(2u/(2u + 1)) / (1 + 2^(3−c)·(4u)^k),

and V(D_n) ≥ (3/4)(16/17)(10/11)(4/5) = 0.5134 for every data set of 1 ≤ n ≤ min{u/4, (c − 5)/(d + 2)} pairs. For n = 0, V ≥ W₀·(10/11)/((17/16)·W₀ + 2^(−5) + 2^(−6)) ≥ 0.70 with W₀ = (1/8)(1 + 1/(2u))^u ≥ 0.2013.
Checked by enumeration for u = 8 and c ∈ {10, 15, 20} with random semimeasures in place of U (V = 0.82, 0.77, 0.66 for k = 0, 1, 2 at c = 15), and in closed form for 3 ≤ d ≤ 20 and c from 5 to 1000 (script `sec4`, block 9).
*What may then be said.* For every universal machine U there are universal machines, as far from U as one likes, on which the property "the answer is not b" has a program of 6 bits and the class is closed under conditioning on it with a constant that does not grow, and on which the mixture violates the property at a fresh input with probability above 1/2 for (c − 5)/(d + 2) questions. So neither K(R) nor C_R, measured on the machine of the class, bounds the violation probability at a fresh input. With this the three sentences named above are supported.
*What every machine does give (an addition, proved by Theorem 4.7(c)).* If the class contains the fair coin on {0, 1} with weight 2^(−k_c), then for every human f: X → {0, 1}, whatever its complexity, with probability 1 − δ over the inputs and for all n: 1 − V(D_n) ≥ ½·(δ·2^(−k_c))^(1/n), hence V(D_n) ≤ ½ + (k_c ln 2 + ln(1/δ))/(2n). (P(D_n) = 1 and M(D_n) ≥ 2^(−k_c)·2^(−n).) So on a machine with a cheap coin a level above 1/2 cannot be held for long by any human with binary answers; on U′ and U″ the coin costs about c bits, in agreement with the theorem. This does not bring the level below 1/2; that needs a cheap hypothesis that predicts the answers nearly as well as the human does (K*, item 2 of 4.13).

**Proposition 4.12. CORRECT.** The key step (the data before the first repetition have the same law for a random function F ∼ S as for the sampler S) was checked exactly: for three classes the law of max_n V(D_n) over the distinct prefix is identical in the two experiments. The bound itself is far from tight in classes small enough to enumerate (failure probability 0 in all cases tried).

**4.13. Items 1 and 2 CORRECT.** Items 3 and 4 hold after the fill above; item 4 should add the sentence on the coin, and should say that a bound which also involves the composition constant of the machine is not excluded by these machines (on U′ and U″ that constant is about c).

### Section 5 (the two prices)

**Table 5.1. CORRECT.** Theorem A is quoted correctly (E TV ≤ √(K ln 2/(2N)); `verification/hellinger-runs-check.md` has it as CORRECT). "Says nothing when N ≤ K ln 2/2" and "K(R) ln 2 + ln(2/δ) ≥ N/2" were recomputed. The lower bound for the first price is Theorems 6.1 and 6.3 of `research/prove/lower-bounds.md`; the check of that file has 6.1 as correct and the two consequences of 6.3 as correct. For the second price see the entry on Remark 2.7(4).

**Proposition 5.2. CORRECT.** (a) Hoeffding with summands in [0, μ(x)]: 2exp(−2t²/coll(μ)) = π(R)η for the stated t. (b) is exact. Enumeration of all functions F (u ∈ {7, 10, 12}, uniform and non-uniform μ, the coin and other samplers, 1 or 12 weighted tests): E_F Q_F(R) = Q_{P₀}(R) exactly, and the probability that some test deviates by more than its bound is at most 0.24·η. Consequence: √(ln(2/(πδ))/(2u)) = √(N/u)·tol_N(R), and (δ/2)e^(2N)/2^(3N) < 2^(−N/10) because e²/8 = 0.9236 < 2^(−1/10) = 0.9330. The file is careful here: it says that the coin meets the guarantee |Q′(R) − Q(R)| ≤ 2·tol_N(R), not that the coin lies in 𝓜_N; the latter holds with tolerance (1 + √(N/u))·tol_N.

**Example 5.3. CORRECT.** Enumerated for u = 8 and all 256 functions g.

**5.3 (summary). CORRECT.**

### Section 6 (the certificate)

**Theorem 6.1 (V1(b)). CORRECT.** (a) Hoeffding for variables in [−1, 1]: 2e^(−mt²/2) = π(B)δ for t = √(2 ln(2/(π(B)δ))/m), which is the tolerance of the note. (b) Lemma 2.1; the tolerance √(ln(2/(π(B)δ))/(2m)) is exactly half of that of (a). (c) The derived scaffold is correct; empty rounds (J > len(τ)) are runs with no call. Exact multinomial sums over m ≤ 7 rounds for a stateful answerer on a scaffold with runs of 1 or 2 calls: the means of the indicators equal a(B) and h(B); (b) fails with probability at most 0.20·δ. The theorem needs A1 for the answers to the probes (the rounds must be identically distributed); the table of Section 7 says so.

**Theorem 6.2. CORRECT; MINOR in the wording of the summary.** (a), (b) trivial or Proposition 5.2(a). (c) The coupling is correct; the event "no question is repeated" is the same in both experiments. (d) E[a_F·1_G] ≥ a₀ − ξ − η; correct. Enumeration over all functions for 120 random adaptive procedures with internal randomness, non-uniform P₀ and two or three answers: (c) holds with equality when no question is repeated, and (d) holds.
*Minor.* The conclusion of (d) is one-sided (the far human is accepted at least as often, up to ξ + η). The summary table says that the procedure "cannot tell" the two humans apart. A two-sided statement for one function is false: for the procedure "ask input 0 once and accept iff the answer is 0" (ξ = 0) the coin is accepted with probability 1/2 and every function with probability 0 or 1. What is exactly indistinguishable from P₀ is the random function F (statement (c)). The one-sided form is what the reading needs (a far human passes), and the reading states it correctly. Fix: in the summary table and in "In brief (5)" write "against whom the procedure accepts at least as often as against the stochastic human, up to the probability of a repeated input".
This is the precise version asked for in item 4 of the task. The order of quantifiers ("for every procedure there is a human") cannot be reversed, as the file notes.

**Example 6.3. CORRECT.** Checked for all tests that ignore one input bit, d = 1, 2, 3 (4, 32 and 768 tests): equal frequencies; the test "y = parity" has frequency 1 against 1/2.

### Sections 7 to 10

**Table of Section 7. CORRECT.**
**Section 8.2 (remarks on other files). CORRECT;** each of its nine items was compared with the file it concerns. Item 3 should be extended by the point of the entry on Theorem 4.11.
**Section 9. CORRECT.** All five outputs are reproduced exactly by the scripts.

---

## III. Corrections that must be made, ordered by importance

1. **Theorem 4.11 and what is concluded from it (GAP, filled).** State on which machine the complexity of R is measured. On U′ as constructed, K_{U′}(R) ≥ c + 1 and the closure constant is at least 2^(c−1), so the theorem does not show that the violation probability at a fresh input is "not bounded in terms of K(R)" for a universal class. Replace U′ by the variant U″ of Part II (a 6-bit program that decides R; g_T at 3 + |T|(d + 2) bits; h_T at four more bits), and state three facts in the theorem: K_{U″}(R) ≤ 6; C_R ≤ max{17, 2^(K_U(R)+c_U)}; V(D_n) > 0.51 for all n ≤ min{u/4, (c − 5)/(d + 2)}. Then correct the places that depend on it: the row of the summary table ("a constant-length property": constant on which machine); the sentence after Proposition 4.9; 4.13, items 3 and 4; Section 8.2, item 3; and Section 8.5 of the note. Add to 4.13 the bound that holds on every machine with a cheap coin (V ≤ ½ + (k_c ln 2 + ln(1/δ))/(2n) for humans with binary answers), and say that a bound which involves the composition constant of the machine is not excluded by these machines.
2. **`note.md`, Section 8.5** (Part IV, with the replacement). The two halves of the placeholder hold in different classes; "abiding" must read "not violating"; and the section must say what does hold at a fresh input (Theorem 4.7(d), Proposition 4.9).
3. **`note.md`, Section 8.2** (Part IV). "Nothing is assumed about the human" and "each input is seen once" say more than is proved; state Theorem 6.2 with its provisos; add the caveat of Proposition 5.2 and Example 5.3.
4. **Theorem 6.2(d), summary table and "In brief (5)".** The conclusion is one-sided. Write "is accepted at least as often, up to the probability of a repeated input", not "cannot tell". Keep statement (c) as the exact indistinguishability (of the random function F from P₀).
5. **Example 3.11(a), the sentence on Bousquet, Kane and Moran.** Give the quantifiers of their Theorem 19 (infinite domain: any number of samples) and Theorem 21 (domain of M points: of the order of √M samples), and cite version 5 of the arXiv paper (14 December 2025), which corrects the proof of the lower bound (their Remark 1). Without the quantifier the sentence is false on a finite space of runs.
6. **Theorems 4.2 and 4.7(b): the convention 0·∞ = 0**, or "the sum runs over the indices of positive posterior weight". In the summary row of Theorem 4.7, the bound (K ln 2 + ln(1/δ))/n needs the human in the class.
7. **Corollary 4.6: "attained" must read "approached".** Three places: title, summary table, last sentence of the statement.
8. **Proposition 4.8(d): add the missing line**, best in the direct form 1 − V(D) ≥ M(D)^(1/k) for every data set (proof in Part II).
9. **Theorem 2.5, remark after the counterexample:** counterexamples exist for π(R)δ = 0.34 (N = 4), not only for δ close to 1. In the note, state Pr3 in the divergence form (G), as the file recommends.
10. **Remark 2.7(4) and Section 5.1:** the remark is used; mark the lower bound for the second price as standard and unproved, or add the proof sketched in Part II.
11. **Attributions in the final proof file.** Theorem 2.3 is standard (relative-entropy Chernoff bound with a weighted union bound); the tag "NEW", which in the file means "not in the candidate theory", must not reach the note as a claim. Corollary 2.6 ("the price of a property is its own complexity") needs the attribution of `outline.md`, Addendum 2, item 5. Theorem 6.2 uses the lazy sampling of a random function, a standard device; say so.
12. **Small points of wording.** Theorem 3.10: "for N_s → ∞ the bound becomes that of Theorem 3.6" at confidence 1 − 2δ. (C4): the count of tests that matter is (δ/4)e^(2N) for the tolerances tol* and tol′. Summary row of Theorem 3.3: "2·tol*".
13. **Letters used twice.** T is the deployed round in `outline.md` and in Proposition 4.9, and a table in Theorems 4.5, 4.11 and Corollaries 4.6, 4.10; η is a probability in Proposition 5.2 and Theorem 6.2 and an indicator η_i(B) in Theorem 6.1; S is a sampler, a set of inputs and a set of recognised inputs in Section 4. The final text should give the tables another letter at least.

None of these changes a theorem. Items 1 to 3 change what the note may say.

---

## IV. `note.md`, Sections 8.1, 8.2 and 8.5 against the proof file

### Section 8.1 (all properties at once). MINOR.

The section is correct (Statement 2.0). Three additions are needed for it to say no more and no less than what is proved.

* The error is additive. A property that the human system has with probability below ε is not controlled by TV ≤ ε, in particular a rare bad event. (For events that never occurred the test-matching guarantee is of the first order in 1/N: Corollary 2.6(iii).)
* "Theorems R1 and R2 give this at the price K": R1 gives closeness of whole runs only for a deterministic human (the run is a run of the human system with probability 1 − L·K ln 2/n); for a human who is not deterministic it is R2. For recorded runs of the human system it is Theorem A in expectation and Corollary 3.7(a) with probability 1 − δ, at √((2K ln 2 + 2 ln(2/δ))/N).
* Outside the class the batch estimator still gives every property up to three times the distance of the best member plus √((2K(ν) ln 2 + 2 ln(2/δ))/N) (Theorem 3.6, Corollary 3.7(b)); the estimator needs recorded runs of the human system, exact comparison of likelihoods and a closed system (Section 3.5).

### Section 8.2 (one property at a time). MINOR: two sentences say more than is proved.

* "Theorem V1(b) says … with error √(2 ln(2/(π(B)δ))/m)": correct (Theorem 6.1(a)). It may be added that the human's frequency alone is certified to half this error, and that a test which the human's answers never met in m probes has human frequency at most ln(2/(π(B)δ))/m (Theorem 6.1(b)).
* "nothing is assumed about the human": not exact. Theorem V1 assumes that each probe is answered by a fresh draw from P(·|x) (A1 for the probes); otherwise the rounds are not identically distributed and h(B) is not defined. Write "no class, no computability; only A1 for the probes". The statement with no assumption beyond independent runs is the batch form (Theorem 2.3), which needs recorded runs.
* "For a human who is not deterministic this is also all that can be checked: each input is seen once, so P(·|x) is not observable at any single x, and only frequencies of tests can be estimated." This is an assertion, and "each input is seen once" is a proviso, not a fact (a validator may repeat a question, and then P(·|x) can be estimated there). `outline.md`, Addendum 2, item 5, asks that the sentence rest on a stated bound. Replace it by Theorem 6.2: for every procedure with m single answers that accepts a perfect imitator with probability 1 − α there is a deterministic human, at total variation at least 1 − max_y A(y|x) from the imitator A at every input, with the imitator's frequencies on every test of the family up to √(coll(μ)·ln(2/(π(B)η))/2), against whom the procedure accepts with probability at least 1 − α − η − ξ, where ξ is the probability that the procedure puts some input to the human twice (at most C(m, 2)·coll(μ) when the questions are independent draws from μ). The quantifiers are "for every procedure there is a human".
* The second paragraph (the conflict between properties disappears) is correct and is Corollary 2.6(i): the set of laws that match all tests is not empty, because it contains the human system.
* Missing caveat, which the proof file supplies: matching the tests is not imitation. A fair coin meets, for every test of a family, the guarantee that N runs can certify, and differs from a typical human f at every call with probability 1/2 (Proposition 5.2); and per-call tests do not see how the calls of a run hang together (Example 5.3, which is the exact form of the second bullet of Section 8.4).
* Attribution as in Addendum 2, item 5.

### Section 8.5 (the mixture does not give the per-property price). MINOR: the placeholder must be replaced; its two halves hold in different classes, and it leaves out what does hold.

What must change in the sentence: (i) the hindsight bound holds for a class that is closed under conditioning on R, with the closure constant C_R in the place of 2^(K(R)+c), and with "abiding" read as "not violating"; (ii) "it stays near 1" is true in the memoriser class H_mem, which is not closed under conditioning; in a class that is closed the violation probability at every input is at most 1 − 1/C_R, and this value is approached (Corollaries 4.3(c), 4.6); (iii) "is not bounded in terms of K(R)" is proved for classes with designed weights (Theorem 4.5) and, for the class of all programs, only after the correction of item 1 of Part III; (iv) the section must say what does hold.

Content that the checked proofs support, for the editor:

1. *Hindsight (Theorem 4.2, Corollary 4.3).* If the class is closed under conditioning on R with constant C_R (for all programs of a universal language and a decidable R, C_R = 2^(K(R)+c)), then on any data that do not violate R the posterior mean of the inverse of the probability that a hypothesis gave to not violating R at the inputs seen is at most C_R. So the inputs seen, asked again, would give at most ln C_R violations in expectation, and at every input the mixture violates R with probability at most 1 − 1/C_R.
2. *At a fresh input the mixture pays K (Theorem 4.7(d), Proposition 4.9).* If the human is in the class and never violates R, then with probability 1 − δ, for all n, the mixture after n questions drawn from μ violates R at a fresh input from μ with probability at most (K ln 2 + ln(1/δ))/n; under rehearsal a deployed run has at most L·K ln 2/n violating calls in expectation.
3. *K cannot be replaced by the price of R (Theorem 4.5, Corollary 4.6, Theorem 4.11 as corrected).* In a class of memorisers the probability is above 0.51 for all n ≤ min{u/4, (K − 2)/log₂(4u + 2)}; in the same class made closed under conditioning (Corollary 4.6) the value is multiplied by 1 − 1/C_R; and for every universal machine there is a universal machine on which R has a program of 6 bits and the probability is above 1/2 for (c − 5)/(d + 2) questions, c arbitrary.
4. *What ends the phenomenon (Propositions 4.10, 4.12; Theorem 4.7(e)).* One cheap hypothesis in the class that never violates R and predicts the answers nearly as well as the human does. The violation level v can be held only while the mixture loses log₂(1/(1 − v)) bits per pair against the human (Theorem 4.7(f)), and this is attained (Proposition 4.8).

### One sentence of the candidate theory that the editor should not carry over

Pr4 of `candidate-theory.md` ends: "One learner, no prior belief needed, both regimes; and robust when the human is not a stateless sampler." What is proved: both prices at once only for a human system in the class (Theorem 3.3, Proposition 3.8); outside the class the estimate of the draft may be undefined, the penalised estimate has the oracle inequality for total variation, and the per-test guarantee is available for near-minimisers of the test discrepancy (Proposition 3.9), which is a different selection rule. No single rule is shown to have both outside the class.

---

## V. Edge cases and hypotheses

| case | where it arises | finding |
|---|---|---|
| horizon 1 | derived scaffold of Theorem 6.1(c); Examples 3.11(a) to (c); Proposition 5.2 | correct |
| one run, one question, one probe (N, n, m = 1) | Theorems 2.3, 2.5, 3.6, 4.7, 6.1 | valid and mostly empty (for K(ν) ≥ 1, 2r_1(ν) ≥ √(2 ln 2) > 1); the counterexample to the draft's Pr3 in the file is at N = 1 |
| runs with no calls | Lemma 1.1 (empty product, L_ν = 1); empty validation rounds | covered; checked on random scaffolds |
| events of probability zero | Lemma 2.1 for q ∈ {0, 1}; indices of likelihood 0 in Theorems 4.2, 4.7(b); "M(D_n) = 0 or" in 4.7(b); inputs of μ-probability 0 in 4.7 | one convention missing (Part III, item 6); the rest is treated |
| infinite divergences | kl(p‖q) = ∞ for q ∈ {0, 1} ≠ p in Lemma 2.2 and in 𝓜_N; KL in Proposition 4.9 is finite because M^(t) ≥ (posterior weight of P)·P | correct |
| semimeasures | "no answer" ends a run (Section 1); "no answer is not a violation" (Definition 4.1); ν^R is a semimeasure; Theorem 4.7 asks for a human who always answers | correct; the choice in Remark 4.4 ("not violating") is the one that makes the class of all programs closed |
| ties | A_νν′ is strict, and any set between the strict and the non-strict one may be used (checked exactly); all ε-minimisers are covered by Theorem 3.6; ties in weight in Theorem 3.3 and Proposition 3.8 (every index of largest weight was required to satisfy the claims in the check); Example 3.11(a) uses odd N and needs r_N < 1/4 | correct |
| two indices for one law | Section 1; Theorems 3.3, 3.6 | correct; included in the checks |
| weights of total below 1 | every union bound uses Σ w ≤ 1 in the right direction; posteriors are normalised | correct |
| k = 0, k = u, u = 1 | Theorem 4.5 | formulas hold (enumerated) |
| n = 0 | Theorem 4.2 (left side 1), Theorem 4.7(b) (Z₀ ≤ 1 < 1/δ) | correct |

**Hypotheses.** Each stated hypothesis is used, and for each the file names an example that shows it is needed (table of Section 7, which was checked row by row). (IID): binomial law of N·Q̂_N(R). Σ π ≤ 1 and tests fixed in advance: union bound. Q = Q_ν₀ in Theorem 3.3 and Proposition 3.8: ν₀ matches. Σ w ≤ 1 in Theorem 3.6: the two union bounds around ν*. (Cl_R) and abiding data in Theorem 4.2: ν^R(D_n) = ν(D_n)·Π(1 − v_ν(x_i))^(−1) and the sum over preimages. Independent inputs from μ and a human who never violates R on the support of μ in Theorem 4.7: the supermartingale step; A2 only in (d). A frozen and A1 for the probes in Theorem 6.1. No missing hypothesis was found. Decidability of R enters only Remark 4.4 and (C4), as the file says.

---

## VI. Numerical checks

Prover's scripts (run again; outputs identical to the saved ones): `property-batch_pr3.py`, `_pr4.py`, `_pr2.py`, `_prices.py`, `_cert.py` in `research/prove-c/code/`.

Referee's scripts, in `verification/code/`, each with its output `*.out` (run as `python3 NAME.py > NAME.out`; block 12 of `sec3` uses numpy, everything else is pure Python; the longest takes 40 seconds):

| script | what it checks | result |
|---|---|---|
| `property-batch_check_sec2.py` | Lemma 1.1 and Scheffé's identity on random scaffolds (exact); Lemmas 2.1, 2.2; Corollaries 2.4, 2.6; Theorem 2.5 with exact binomials; Remark 2.7(4) | no violation; joint statement of the draft: ratio up to 1.34 |
| `property-batch_check_joint25c.py` | for which π(R)δ the joint statement of the draft fails (one test) | fails from 0.34 on; below 1 for π(R)δ ≤ 0.32 on the grid |
| `property-batch_check_sec3.py` | Theorems 3.3, 3.6, 3.10, Corollary 3.7(c), Propositions 3.8, 3.9, Lemma 3.5, Examples 3.11(a) to (c); exact multinomial or binomial sums; the events E₁, E₂ of the proof of Theorem 3.6 | no violation; largest failure probability 0.12·δ (Theorem 3.6), 0.05·δ (3.3), 0.07·δ (3.8), 0.0015·2δ (3.10) |
| `property-batch_check_sec4.py` | Theorem 4.2 and Corollary 4.3 on random closed classes; Theorem 4.5, Corollary 4.6, Propositions 4.8, 4.10, Theorem 4.11 by enumeration of the whole class in exact rationals; Theorem 4.7 by enumeration of all paths; Proposition 4.9 with exact expectations under rehearsal; the coupling of Proposition 4.12; the variant U″ | no violation; all closed forms exact |
| `property-batch_check_sec56.py` | Proposition 5.2 (all functions enumerated), Example 5.3, Theorem 6.1 (exact multinomial sums, stateful answerer, runs of variable length), Theorem 6.2 (all functions, adaptive procedures), Example 6.3 (all tests that ignore a bit) | no violation; the one-sidedness of 6.2(d) is exhibited |

Two of the referee's own blocks are weak and are named as such: block 6 of `sec3` (Theorem 3.10 for N ≤ 12) has no case with positive failure probability and is superseded by block 12; block 8 of `sec4` finds failure probability 0 for the bound of Proposition 4.12, which is far from tight in small classes, so the step of the proof was checked instead.

---

## VII. Literature checked in a source in this session

* **S. Mahalanabis and D. Štefankovič, "Density estimation in linear time", arXiv:0712.2869v1 (18 December 2007).** Read in this session (the PDF, Sections 1, 2.1 and 4). The file's account is exact. Theorem 2 ([DL01], Theorem 6.2): the Scheffé tournament winner f₁ has ‖f₁ − g‖₁ ≤ 9·d₁(g, F) + 8Δ. Theorem 3 ([DL01], Theorem 6.3): the minimum distance estimate, which minimises max{|(f − h)·T_ij| ; f_i, f_j ∈ F}, has ‖f₁ − g‖₁ ≤ 3·d₁(g, F) + 2Δ. Theorem 4: the modified minimum distance estimate, which minimises max{|(f_i − h)·T_ij| ; f_j ∈ F} over i, has the same bound. Here T_ij = sgn(f_i − f_j) and Δ = max_T (g − h)·T over the test functions; Remark 1: this Δ is at most twice that of Devroye and Lugosi. Remark 5: g and h need to be close only on the test functions of the best member. Lemma 11 with Corollary 12: the four-atom example f₁ = (0, 1/4 + ε, 1/2, 1/4 − ε), f₂ = (1/2 + ε, 1/4 − ε, 0, 1/4), g = h = (1/2, 1/2, 0, 0), for "any deterministic test-function based algorithm". This is Example 3.11(a).
* **O. Bousquet, D. Kane and S. Moran, "The optimal approximation factor in density estimation", arXiv:1902.05876v5 (14 December 2025).** Read in this session (the PDF, Sections 1.5 to 1.7 and the statements of Section 5). Definition (1.5): Q is α-learnable if there is an algorithm such that for every ε, δ there is a sample size m(ε, δ) with TV(p, q) ≤ α·opt + ε with probability 1 − δ for every target p; properly, if the output is always in Q; and "when X is finite, we consider Q to be α-learnable only if its sample complexity depends efficiently on |X|, namely poly log(|X|)". Theorem 1: "Every finite class of distributions Q is α-learnable with α = 2." Theorem 2: "For every α < 3 there is a class Q of size 2 that is not properly α-learnable." Theorem 19 is the form for infinite domains quoted in Part II; Theorem 21 the form for a domain of M points. Remark 1 of the paper: a gap in the original proof of the lower bound was found by Aamand, Aliakbarpour, Chen and Silwal (2025) and is corrected in this version. So the file's theorem numbers are right, and the missing piece is the dependence on the domain.
* **S. Compton and J. Li, "Density estimation for Hellinger via minimum-distance estimators: mixtures of Gaussians, log-concave, and more", arXiv:2606.11469v1 (9 June 2026).** Seen in this session through an automatic summary of the arXiv HTML page only: Section 1.5, Lemma 5, states E[TV(f, f̂_n)] ≤ 3·inf_θ TV(f, f_θ) + O(√(VC(𝒜)/n)) for the Yatracos class 𝒜 and attributes it to Devroye and Lugosi (2001), with the estimator traced to Yatracos (1985). This agrees with the file.
* **Not read:** Yatracos (1985); Devroye and Lugosi (2001), known here only through the restatement above; Hoeffding (1963) and Ville (1939), whose statements are standard and are proved or used in the standard form; Barron and Cover (1991); Trevisan, Tulsiani and Vadhan (2009). The reference to Langford (2005) in Part II is the referee's, from memory.

---

## VIII. What was not checked

* Theorem R1 of `note.md`, on which Proposition 4.9 rests, belongs to the part rehearsal-core. Only the step that is used was checked here, numerically.
* Theorems 6.1 and 6.3 of `research/prove/lower-bounds.md` (the lower bound for the first price) were not read; the verdicts of `verification/lower-bounds-check.md` were taken over.
* The standard facts of Remark 4.4 about a prefix-free universal language (composition at a constant cost, lower semicomputability of ν^R) were not proved.
* The statement that the joint form of the draft's Pr3 holds for π(R)δ ≤ 0.32 is numerical, on a grid.
* The digests in `research/understand/` that the file cites (Trevisan, Tulsiani and Vadhan; Lemma I1a; Proposition I5) were looked up for consistency only.
* The other verification report on this part was not read, so that the two reports stay independent.
