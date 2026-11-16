## 8. The property idea

The researcher proposed that a good imitator keeps the properties the answers had so far, and objected: at a new input some such property must break. This section says what survives.

### 8.1 All properties at once

**Pr1** (a definition). TV(Q_A, Q_P) ≤ ε holds exactly when every event of runs has, with A answering, a probability within ε of its probability in the human system. Keeping every property up to a small error is thus closeness in total variation, not a weaker goal. Under A2 its price is K, times the horizon L under rehearsal: for a deterministic human the deployed run is a run of the human system with probability at least 1 − L·K ln 2/n (R1); in general E TV ≤ 2√(L·K ln 2/n) (R2); from N recorded runs of the human system, E TV ≤ √(K ln 2/(2N)) (H1). For a person, with K of the order of 10⁹ bits under a generic prior, these bounds are empty.

*Not said.* The error is additive: an event of probability below ε in the human system, such as a rare bad one, is not controlled.

### 8.2 One property at a time

A *test* is a set B of runs (a set of pairs (x, y), for a one-call scaffold). Fix in advance countably many tests with weights π(B) of total at most 1; Λ(B) := ln(1/π(B)) is the *price* of B. With π(B) = 2^(−length of a program for B), in a prefix-free language whose programs all halt, cheap tests are simple properties.

**Theorem Pr3** (standard: the Occam's razor bound; Langford 2005, quoted from memory). Let τ₁, …, τ_N be independent runs with one law Q, Q̂(B) the fraction of them in B, and a(B) := (Λ(B) + ln(2/δ))/N. With probability at least 1 − δ, for all B at once, kl(Q̂(B) ‖ Q(B)) ≤ a(B), where kl(p ‖ q) is the divergence KL between coins of bias p and q. On this event |Q̂(B) − Q(B)| ≤ √(a(B)/2), and Q(B) ≤ a(B) if B never occurred; and every law Q′ that satisfies the same inequalities in the place of Q has |Q′(B) − Q(B)| ≤ √(2a(B)), and Q′(B) ≤ a(B) if B never occurred.

*Proof.* N·Q̂(B) is binomial; the Chernoff bound in divergence form gives Pr[kl(Q̂(B) ‖ Q(B)) > a(B)] ≤ 2e^(−N·a(B)) = π(B)·δ; sum over B. Pinsker's inequality and kl(0 ‖ q) ≥ q give the rest (`proofs/property-batch.md`, Theorem 2.3, Corollaries 2.4, 2.6; numbers cited below refer to that file). ∎

That a property costs its own complexity whatever the source, and that a model passing all tests need not be close to the source, are central points of outcome indistinguishability and multicalibration (Dwork et al. 2021; Hébert-Johnson et al. 2018). Q is arbitrary, but it must be the law of every run: the human must not change between runs.

Theorem V1(b) is Pr3, used to *check* a given imitator, for the one-call scaffold "a uniformly chosen call of the imitator's run" (Theorem 6.1): m single answers, no run of the human system, per-call tests only, A1 for the probes.

The researcher's conflict is thereby confined, not removed: two tests that held on all data and clash on a new kind of input need only keep the human's frequencies, as the human system does. On inputs rarer than the tolerance a matching imitator may do anything.

*Not said: that a matching imitator imitates* (proved here: Proposition 5.2, Example 5.3).
* *The coin.* One call at a uniform input among u; the human is a function f: X → {0, 1}, the imitator a fair coin. For all but a fraction δ of the functions, |Q_coin(B) − Q_f(B)| ≤ √((Λ(B) + ln(2/δ))/(2u)) for every test, yet the coin differs from f with probability 1/2 at every call.
* *The same question twice.* The scaffold puts one uniform input to the answerer twice; the human is a fair coin at each call, the imitator a function g. For most g every per-call test has the human's frequency, to the same error, while "the two answers agree" has probability 1 against 1/2.

For N recorded runs there are thus two prices: √(K/N) for all properties at once (H1), and √(Λ(B)/N) for each test. Neither guarantee contains the other.

### 8.2a The batch estimator

Let K(ν) := log₂(1/w(ν)). The likelihood of a run under ν is the product of ν(y_j | x_j) over its calls. For ν ≠ ν′ let A_νν′ be the set of runs more likely under ν than under ν′, and r(ν) := √((K(ν) ln 2 + ln(2/δ))/(2N)). From N recorded runs, the estimate ν̂ minimises

  r(ν) + sup_{ν′ ≠ ν} max{0, Q_ν(A_νν′) − Q̂(A_νν′) − r(ν′)}.

**Theorem Pr4** (proved here; minimum-distance estimation after Yatracos). For every law Q of independent runs, with probability at least 1 − δ, for every ν ∈ H:

  TV(Q_ν̂, Q) ≤ 3·TV(Q_ν, Q) + √((2K(ν) ln 2 + 2 ln(2/δ))/N).

*Idea.* TV(Q_ν, Q_ν′) = Q_ν(A_νν′) − Q_ν′(A_νν′), and Q̂ must be close to Q only on the sets involving the best ν. Proof: `proofs/property-batch.md`, Theorem 3.6. The estimate is the modified minimum-distance estimate of Mahalanabis and Štefankovič (2008), with weights; it attains the factor 3, which is optimal for rules that return a member and whose number of runs does not grow with the space of runs (Bousquet, Kane and Moran 2019, Theorem 19).

*To compute it* one needs a list of the hypotheses above a weight threshold (up to about e^(2N)); exact comparison of two likelihoods on a recorded run (possible for time-bounded programs, not for lower semicomputable ones); and the numbers Q_ν(A_νν′), hence a closed system or simulated runs (Theorem 3.10).

*Not said.* For a human with memory inside a run the bound can be empty: one who repeats a fair bit is at distance at least √2 − 1 from every sampler, and 3·(√2 − 1) > 1. And the human must carry out N whole runs.

### 8.5 The mixture need not give the per-property price

Let R be a set of pairs that the human never violates.

**Pr2(a), hindsight** (proved here; Theorem 4.2). Suppose that with each ν the class contains ν^R ("redraw until the answer does not violate R"; no answer is no violation), and that the hypotheses mapped to one member weigh at most C_R times that member. For all programs and decidable R, C_R = 2^(K(R)+c) (standard facts, not proved here). Then on any data that do not violate R, the posterior mean of 1/(probability the hypothesis gave to not violating R at the inputs seen) is at most C_R. So the inputs seen, asked again, give at most ln C_R expected violations, and, as the researcher's notes claim, the mixture violates R with probability at most 1 − 1/C_R at every input. *Not said:* that it answers well. The remaining 1/C_R may be silence (violating 0.71, silent 0.18, abiding 0.11 in one example with C_R = 5; for samplers that always answer see Proposition 4.15).

**Pr2(b), a fresh input** (proved here; Theorem 4.5). Let R now be "the answer is not b". Take u ≥ 5 inputs, a human f with answers in {0, 1} and weight 2^(−K), K ≥ 2, and all memorisers (a table on some inputs, the answer b elsewhere) with weights proportional to (4u)^(−size). After n questions at distinct inputs the mixture answers b at a fresh uniform input with probability ((u − n)/u)·(2u/(2u + 1))/(1 + (4u + 2)^n/(2^K − 1)), and with probability above 0.51 after any n ≤ min{u/4, (K − 2)/log₂(4u + 2)} questions. Closing the class under conditioning multiplies the value by 1 − 1/C_R. This level is the prior probability that a memoriser violates R off its table, here 1.

**What holds** (proved here; Theorem 4.7, Proposition 4.9). Under A2, with questions drawn independently from the law of the fresh input, with probability 1 − δ, for all n, the mixture violates R there with probability at most (K ln 2 + ln(1/δ))/n. Under rehearsal a deployed run has at most L·K ln 2/n violating calls in expectation.

**Pr2(c), the machine** (proved here; Theorem 4.11). For every universal machine U, c ≥ 5 and d ≥ 3 there is a universal machine, at most c bits from U, on which this R has a 6-bit program and C_R does not depend on c, while for every human with answers in {0, 1} on u = 2^d inputs the mixture violates R at a fresh input with probability above 0.51 after any n ≤ min{u/4, (c − 5)/(d + 2)} questions. So no bound in the price of R and C_R holds on all universal machines: a fact about the prior. *Open:* such a bound for one fixed machine, with a constant of that machine.

### 8.6 What the human's answers can certify

**Theorem Pr7** (proved here; the observation is Dwork et al.'s). Let P₀ be a sampler and F a random function with independent values F(x) ∼ P₀(· | x).
(a) *One answer per input.* F is at total variation 1 − P₀(F(x) | x) from P₀ at every x. A procedure that puts m questions to the human, adaptively, accepts F on average as often as P₀, up to the probability that it puts some input twice. For a law μ on inputs, all but a fraction δ of the functions have every test frequency within √(Σ_x μ(x)²·(Λ(B) + ln(2/δ))/2) of that of P₀.
(b) *Answers from a large set* (not independently checked). If P₀(· | x) is uniform on s answers, the human who answers uniformly on a random half of them is at total variation 1/2 at every input, and m answers, with any repetitions, tell the two apart with advantage at most m²/(2s), on average over the halves.

*Idea.* Answer a random function lazily: each first-time question gets a fresh draw from P₀. Proof: `proofs/property-batch.md`, Theorems 6.2, 6.6.

So with one answer per input, or with long strings as answers, test frequencies are all that can be certified about a human who may vary. *Not said:* the same for repeated questions with few possible answers, which A1 allows. Two answers y₁, y₂ to a probe x give the collision statistic 1[y₁ = y₂] − A(y₁ | x) − A(y₂ | x) + Σ_y A(y | x)², with mean Σ_y (P(y | x) − A(y | x))² (after Goldreich and Ron 2000; Batu et al. 2000); with at most q possible answers it bounds the expected number of unfaithful calls of a run, at the slow rate m^(−1/4) (Proposition 6.4).

## Editor's notes for the assembly (not text of the note)

**Placement and labels.** The part supplies Sections 8.1, 8.2 and 8.5, a subsection on the batch estimator, here numbered 8.2a (it belongs between 8.2 and the online imitator of 8.3), and a subsection 8.6 for Pr7, which the outline's title of Section 8 announces last ("what can be certified for a stochastic human"). The opening paragraph of Section 8 is the lead's, shortened. No label was invented: Pr1 to Pr4 and Pr7 are used as the outline and Addendum 3 assign them. Numbers such as "Theorem 6.1" in the text are those of `proofs/property-batch.md`; the text says so once, at the end of the proof of Pr3.

**Length.** Sections 8.1 to 8.6 have about 1300 words (1303 by a count of the alphabetic tokens of two or more letters, headings included, names of functions such as ln and TV excluded; 1768 whitespace-separated tokens with the opening paragraph, the difference being symbols of formulas and labels). The limit is 1300 words. To stay inside it, several proved statements appear only in the list below.

**What changed against the draft in `note.md`.**
1. 8.1: the price names the horizon and the three theorems; the caveat on additive error is added.
2. 8.2: Pr3 is stated (it was only referred to through V1(b)), in the divergence form and as a standard bound, with the attribution of Addendum 2, item 5. "Nothing is assumed about the human" became "Q is arbitrary, but it must be the law of every run" (and A1 for the probes of V1(b)). "This is also all that can be checked" was removed; Pr7 replaces it. The paragraph on the conflict between properties now says "confined, not removed". Two examples of what matching does not give were added.
3. Batch estimator: new subsection. The draft's Pr4 (candidate theory) was "the highest-weight sampler that matches all tests"; that estimator has both prices when the human system is in the class (proof file, Theorem 3.3 with 4K, Proposition 3.8 with 2K) and may be undefined outside it (Example 3.11(c)). The note states the penalised estimate, for which the oracle inequality holds in the form the candidate theory hoped for, with C = √2 in front of √((K(ν) ln 2 + ln(2/δ))/N). The sentence of the candidate theory "one learner, no prior belief needed, both regimes; and robust when the human is not a stateless sampler" is not carried over.
4. 8.5: the placeholder was replaced. The title says "need not". The two halves of the placeholder are kept apart (hindsight needs a closed class; "near 1" holds in the memoriser class, which is not closed; in a closed class the level is 1 − 1/C_R times as large).

**Sentences cut for length, which the lead may restore** (each is proved in the proof file):
* "The draft's joint form of Pr3 (the two-sided bound and the one-sided bound ln(1/(π(B)δ))/N at confidence 1 − δ) fails for one test with N = 4 and δ = 0.332; it holds at confidence 1 − 3δ/2." (Theorem 2.5.)
* "A replay of the recorded runs matches every test too." (Remark 2.7(6).) "One decidable property a filter can enforce; Pr3 covers all cheap ones at once, unnamed, with two-sided rates." (Remark 2.7(7).)
* "Per-call matching (V1(b), Pr5) does not see how the calls of a run hang together." (Example 5.3; it is the exact form of the second bullet of the draft's Section 8.4.) "Here being right has no cheap test." (after Proposition 5.2.)
* "If the human system is in the class, the heaviest hypothesis that passes one-sided tests has both prices at once (Proposition 3.8); outside the class no single rule is shown to have both."
* "A violation level v lasts only while the mixture loses log₂(1/(1 − v)) bits per pair to the human, and this is attained." (Theorem 4.7(f), Proposition 4.8.)
* "On every machine whose class contains the fair coin with weight 2^(−k_c), a human with binary answers has V ≤ ½ + (k_c ln 2 + ln(1/δ))/(2n)." (4.13, item 5.)
* "Neither price can be lowered in general." (Lemma 2.8 for tests; `proofs/lower-bounds.md`, Theorems 6.1 and 6.3, for total variation.)
* The budget in numbers, with δ = 0.05: "3835 runs before one 50-bit property that never failed is kept with frequency 0.99; 30 677 runs for a two-sided tolerance of 0.05 on one such test; 1.4·10⁸ runs for total variation 0.1 at K = 10⁶ bits." (Corollary 2.6(iii), Corollary 2.6(ii), Corollary 3.7(d); the paragraph after the table of Section 5.1 of the proof file.)
* "The union bound runs over single weights, which is why the constant is 2K where the candidate theory had 4K." (Remark after Theorem 3.6.)

**For other sections.**
* Section 3.3, V1(b) (rehearsal-core): the two recorded frequencies are counts divided by the number m of all rounds, a round whose run has fewer than J calls counting as zero for both; divided by the number of non-empty rounds they estimate Δ(B)·L/E[len] instead (proof file, after Theorem 6.1). The human's frequency alone is certified to half the stated tolerance, √(ln(2/(π(B)δ))/(2m)), and a test that the human's answers never met in m probes has human frequency at most ln(2/(π(B)δ))/m (Theorem 6.1(b)). V1 assumes A1 for the probes; "nothing is assumed about the human" is not exact. The sentence of 3.3 on single answers at inputs that never repeat is correct as it stands; Pr7 is its precise form.
* Section 10, machine test: Pr2(b) and Pr2(c) are facts about the prior, in both directions (the level is the prior probability that a memoriser violates the property off its table; on a fixed machine of the constructed kind the phenomenon ends after a number of questions that is a constant of the machine). Rock test: the floor 1/C_R of the hindsight bound may consist of silence. Copy test: test matching cannot tell a sampler from the sampler with its coins filled in (Pr7(a)); only the price K does. Budget: Pr3 in batch form and Pr4 need N whole runs of the human system.
* Section 12 (`related-work.md`): "the factor 3 is optimal for such rules (Bousquet, Kane and Moran 2019)" needs "with a number of samples that does not grow with the domain, and for guarantees with probability above 2/3" (their Theorem 19 and Corollary 20, arXiv:1902.05876v5, read in the source); on a fixed finite domain the factor 1 is reached with enough samples. The sentence that validation certifies tests and not total variation "is forced" should carry the quantifier of Pr7: one answer per input, or answers from a very large set; with few possible answers and repeated questions a squared distance can be certified.

**References that the text cites and that are not in the list of `related-work.md`.**
* J. Langford (2005). "Tutorial on practical prediction theory for classification." *Journal of Machine Learning Research* 6:273–306. Not opened (volume and pages confirmed by a search in the attack report); the Occam's razor bound is quoted from memory by both verification reports.
* S. Mahalanabis and D. Štefankovič (2008). "Density estimation in linear time." COLT 2008; arXiv:0712.2869v1. Read in the arXiv version by the prover and both verifiers (Theorem 4: the modified minimum-distance estimate; Remark 5; Lemma 11: the four-point example in which the factor 3 is attained). Conference pages not verified.
* O. Goldreich and D. Ron (2000). "On testing expansion in bounded-degree graphs." ECCC TR00-020. Not opened; cited as Batu et al. cite it for the collision count.
* T. Batu, L. Fortnow, R. Rubinfeld, W. D. Smith and P. White (2000). "Testing that distributions are close." FOCS 2000, pp. 259–269. Journal version "Testing closeness of discrete distributions", arXiv:1009.5397v2, read by the editor (Section 1.1; Theorem 2 with its test; the beginning of Section 2.1, where E[r − s] = m²·‖p − q‖₂² is stated for the collision statistics).
* In the proof file only: Blumer, Ehrenfeucht, Haussler and Warmuth (1987); McAllester (1999); Biau and Devroye (2005); McDiarmid (1989); none was opened (Section 10 of the proof file).
* "Bousquet, Kane and Moran 2019, Theorem 19" is the numbering of arXiv version 5 (14 December 2025), which also corrects the proof of the lower bound (their Remark 1).

**Marked in the text.** Pr7(b) is "not independently checked": it was added by the editor (proof file, Theorem 6.6) and checked by exact enumeration only. "C_R = 2^(K(R)+c) for all programs" rests on standard facts that the proof file does not prove (Remark 4.4); the same facts enter Pr2(c) through the closure constant of the base machine.

**Statements of the proof file that did not exist in the prover's file** (numbers for cross-references): Lemma 2.8; Theorem 4.11, part (B); items 5 and 6 of 4.13; Remark 4.14; Propositions 4.15, 5.4, 6.4, 6.5; Theorem 6.6.
