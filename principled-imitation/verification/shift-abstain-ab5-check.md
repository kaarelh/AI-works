# Referee report on Ab5 (Theorem 7.6 of `proofs/shift-abstain.md`)

**Who wrote what.** The object of this report was written by the lead of the project after the five referees had read the assembled note. It consists of Section 7.4 of `proofs/shift-abstain.md` (Setting 7.6, the rule Bat_ε, Theorem 7.6 with items 1 to 6, Corollary 7.7, Remark 7.8, Example 7.9, Remark 7.10), Section 8.6 of that file with the script `proofs/code/shift-abstain_batch_rule.py` and its output, the rows 48 and 49 of the table of Section 0.1, item 9 of Section 9 and the entry on Goldwasser, Kalai, Kalai and Montasser in Section 11, and the block at the end of Section 7.4 of the note's source `research/sections/shift-abstain.md` ("Between the rock and the bet: batches", Proposition Ab5, its proof, the paragraph on the price, "What it does not say" (i) to (v)). I did not write any of it. I wrote this report and the script `verification/code/shift-abstain_ab5_check.py` with its output `verification/code/shift-abstain_ab5_check.out`. I changed no other file.

**What I did.** (a) I checked every statement and every step of every proof of Section 7.4 of the proof file. (b) I wrote my own script, without using the lead's, and ran it; I re-ran the lead's script and compared its output with the saved one. (c) I compared the note's block sentence by sentence with the proof file. (d) I read the source, arXiv:2007.05145.

**What I did not do.** I did not check the rest of `proofs/shift-abstain.md`, nor the statements of other sections that Section 7.4 cites (Proposition 6.1, Corollary 3.6, Proposition 7.5, Theorem 5.6); I used them as stated there. I did not read the proofs of the source's lemmas in Appendix E (Lemma A.1, Lemma B.3), nor its lower-bound proofs. In the working tree there is an untracked script `proofs/code/shift-abstain_batch_runs.py` (dated 28 November) that refers to a "Theorem 7.11" and a statement "Ab6"; neither is in the proof file or the section source that I read (both dated 16 November). It is not part of the object and I did not review it.

## 1. Summary

The mathematics is right. Every item of Theorem 7.6 is correct as stated, with the hypotheses it states, and every proof step checks. My exhaustive check found no violation of items 1, 2, 3 and 6(b): 7.3 million exact cases for items 1 and 2, 1.04 million for item 3, and the exact computation for item 4. Twelve findings concern wording, a missing hypothesis or the account of the source; none of them is a counterexample to a stated claim. The four that matter most:

* **N1 (note, (iii), and Remark 7.10(a)).** "(b) applies to them" is right for the first claim of (b) and wrong, if read for the second claim, for a batch made of the calls of runs. The calls of one run are not independent. I give a computed counterexample, and the correct form with the number of runs r in the place of the number of calls m, with its proof.
* **N2 (the source, Remark 7.8(i)).** Item 3 bounds the P-mass of the refused set. Its counterpart in the source is eq. (15) of Theorem A.5, not Theorem A.2. Eq. (13) of Theorem A.2 bounds the rejection rate on a fresh sample. The source's loop takes the maximiser and counts against all n test inputs, not "a fraction of the test inputs not yet rejected".
* **N3 (note, the price paragraph).** "a whitelist" and "a rock" are used without the hypotheses under which Proposition 7.5 gives them meaning. "of the order of 2^K rounds" drops the factor L·K. The comparison with N7(b) compares guarantees of different kinds without saying so.
* **N4 (Corollary 7.7).** The balanced choice ε = √γ lies in (0, 1] only if n ≥ 2b ln 2 + ln(1/δ).

The account of the source is otherwise accurate. This covers the setting, the algorithm, the numbers of the theorems and the bounds as quoted (Section 5).

## 2. Verdicts on the proof file, Section 7.4

Throughout, f is the human, H_b is finite (|H_b| ≤ 2^b because the weights sum to at most 1), f ∈ H_b because K ≤ b, and V ∋ f.

**Setting 7.6 and the rule. CORRECT.** The order of H_b is used only to fix h (the first member of V) and the member c taken at each step. No item uses it. Items 1 to 6 hold for every h ∈ V and every choice among the members above the threshold, because their proofs use only h ∈ V, f ∈ V and the threshold ε·m. My script checks this in part (1), with every member of V as h and with three choices of c (first, last, largest count): 3.5 million cases and no violation. Finding N9 suggests saying so.

**Item 1. CORRECT.** Each step removes more than ε·m ≥ 0 indices, hence at least one, so the loop ends. At the end f ∈ V has at most ε·m indices of S in Δ(f), and h(z_j) is wrong exactly at those indices. For ε·m < 1, "more than ε·m" is "at least one". So at the end no member of V differs from h on S, and an index where V is unanimous lies in no Δ(c). S is therefore the unanimity set, and the rule is enumeration with budget b (Proposition 7.5(2)), frozen. Hypotheses: none on P; it holds for every D and every batch, whoever chose it and with whatever knowledge. Checked exhaustively in part (1). The largest observed ratio of wrong answers to ε·m is 1.0000, so the bound is attained.

**Item 2. CORRECT.** The sets removed are disjoint, and each has more than ε·m elements, so T·ε·m < m and T < 1/ε. T ≤ m. A member is not taken twice, and h is never taken (Δ(h) = ∅), so T ≤ |V| − 1. The refused indices are those in R(z), by the argument given. For ε = 1 the loop never makes a step. Checked in part (1).

**Item 3. CORRECT.** For c ≠ c′ with p := P(c ≠ c′) > γ, each round puts a question in that set with probability p, also when P is a sub-probability. So Pr[they agree at all questions] = (1 − p)^n ≤ e^(−pn) < e^(−γn) = 2^(−2b)·δ. The number of unordered pairs is at most 2^b(2^b − 1)/2 < 2^(2b)/2, so Pr[not 𝓔] < δ/2 (it is 0 if there is no such pair). On 𝓔 each c ∈ V agrees with h at the questions, so P(Δ(c)) ≤ γ, and P(R(z)) ≤ T·γ < γ/ε by item 2. The second inequality needs γ > 0, which holds. If γ ≥ 1 the event 𝓔 is certain, and P(R(z)) ≤ T·γ still holds (it is 0 for T = 0 and at least 1 otherwise). The event depends on the questions only, so the batch may be chosen with knowledge of D, f and the rule. The final sentence ("given D on 𝓔, an input drawn from P independently of the batch …") is right because R(z) is a function of (D, z). Checked exactly in part (2): 120 instances (38 with a sub-probability, 85 with γ < 1), the probability of the complement of 𝓔 computed exactly by inclusion–exclusion over the set of asked inputs, and its largest ratio to δ was 0.112. Then every asked set in 𝓔, every batch of length up to 5 and nine values of ε: no violation of P(R) ≤ T·γ < γ/ε.

*An observation, not a correction.* The term ln(1/δ) is divided by ε because each of the fewer than 1/ε sets is bounded separately, as Remark 7.8(i) says. A union bound over the tuples (h, c_1, …, c_T), as in the source's Lemma A.1, removes this. With T_max := ⌈1/ε⌉ − 1 and b ≥ 1 there are at most 2·2^(b(T_max+1)) tuples, and the union of their disagreement sets contains no question. So with probability at least 1 − δ, P(R(z)) ≤ (⌈1/ε⌉·b ln 2 + ln(2/δ))/n for every batch. That is about half the b-term of γ/ε, with ln(2/δ) not divided by ε. This is my derivation; I did not check it numerically, and nothing in the object depends on it.

**Item 4. CORRECT.** The hypotheses are needed and are stated: P a probability law, a batch independent of the questions, ε ≥ e²·γ, and ε·m ≥ b ln 2 + ln(1/δ′). On 𝓔, p_c ≤ γ ≤ ε/e² < ε. The Chernoff bound Pr[N_c ≥ εm] ≤ exp(−m·kl(ε ‖ p_c)) applies. The step ln((1 − p)/(1 − ε)) ≤ (ε − p)/(1 − ε) is ln u ≤ u − 1, so kl ≥ ε·(ln(ε/p) − 1) ≥ ε. The members other than h number at most 2^b − 1, so Pr[T ≥ 1] < 2^b·e^(−εm) ≤ δ′. For ε = 1 the event is empty. The statement is conditional on the questions, for each D on 𝓔, which is what the proof gives. Checked exactly in part (3). For three choices of (P, ε, δ′) and two lengths m, Pr[T ≥ 1] was at most 5.3·10⁻³, against δ′ ≥ 0.05, and every single-member probability was below e^(−εm). Without ε ≥ e²·p_c (for example p_c = ε/2) the probability is governed by m·kl(ε ‖ p_c), not by ε·m: at m = 60, Pr[T ≥ 1] = 0.030 although e^(−εm) = 0.0025. So the hypothesis is not idle.

**Item 5. CORRECT.** Items 1 and 2 are deterministic, and the event of item 3 does not depend on any batch. Batches chosen in sequence, each with knowledge of the rule's earlier outputs, are therefore covered.

**Item 6. CORRECT.** (a) is item 1 with S = {1, …, m}. (b): let c ∈ H_b be wrong at more than ε·m indices. Then a uniform index hits one of them with probability more than ε, and c survives q independent indices with probability < (1 − ε)^q ≤ e^(−εq) ≤ 2^(−b)·δ″. At most 2^b − 1 members differ from f. The indices must be drawn after the batch is fixed; the statement says "further questions", which I read in that sense. Checked exactly in part (4): 400 random instances, with the probability that some such member survives computed by inclusion–exclusion. The largest ratio to δ″ was 0.267.

**Corollary 7.7. MINOR.** γ/ε ≤ ε′ when n ≥ (2b ln 2 + ln(1/δ))/(εε′), and P(R(z)) < γ/ε ≤ ε′. The last sentence needs n ≥ 2b ln 2 + ln(1/δ): otherwise √γ > 1 lies outside the range (0, 1] of the rule (finding N4).

**Remark 7.8(i). MINOR.** The account is accurate in substance. Three corrections: the correspondence of item 3 (N2), the description of the loop (N5), and what was read (N6). Details in Section 5.

**Remark 7.8(ii). MINOR.** "it is a rock below complexity b − K_D − c" needs the class to have (P1) to (P3), the hypothesis of Proposition 7.5 (N7). "the frozen minimum rule a number of rehearsal rounds of the order of 2^K" should read L·K·2^K. At α ≤ 2^(−K) the term L·(K ln 2 + ln(1/(αδ)))/(α·n) of Theorem 5.6 (Ab2(d)) is small only for n of the order of 2L·K ln 2·2^K divided by the target (N3). The rest is correct: a member that differs from h at one input x is taken only if x fills more than ε·m indices, and the three outcomes for a batch are those of items 1, 2 and 6.

**Remark 7.8(iii). CORRECT.**

**Example 7.9(a). MINOR.** This is correct if H_b contains the thresholds i = N/2, …, N and N is even; neither is said (N8). Under those hypotheses I checked it exhaustively for N = 10, every human threshold above 5 and every sample of at most 4 questions from {1, …, 5}: V contained all thresholds 5 to 10 in all 3905 cases. Every batch of copies of an input z > 5 (m = 1, 3, 7; eight values of ε < 1) was refused entirely, in all 468,600 cases.

**Example 7.9(b). CORRECT.** P is the uniform law on X because each run makes its L calls at the L inputs of a uniformly chosen block. A one-run batch in an unasked block is refused entirely for ε < 1. A batch of r runs in which no block has more than ε·r runs gives N_{c_i} ≤ ε·r·L = ε·m for every i, so no step is made. Simulated in part (6) with a different instance from the lead's (300 blocks, L = 10, n = 60): 807 of 1000 one-run batches were refused, against a mean fraction of 0.818 of unasked blocks. A batch of 400 runs was answered entirely.

**Example 7.9(c). MINOR.** The construction is correct. The input-by-input rule answers at most ⌊ε·m⌋ inputs of Δ(f); checked exhaustively on all ordered streams of length up to 5 over 3 inputs, for 56 classes, with no violation in 731,808 cases. After ε·m copies of 0 every c_i ∈ V has reached its count, so every later unasked input is refused. The batch rule makes at most one step if no input other than 0 occurs more than ε·m times: after the first step the copies of 0 are gone, and each remaining c_j has only the copies of j. I re-implemented it with another seed: the input-by-input rule refused 1716 of the 1900 draws, all the unasked ones, and the batch rule made one step that refused 100 + 4 inputs. The last sentence, "With batches of one input, item 1 gives enumeration", needs ε < 1. For ε = 1 and m = 1, ε·m = 1 and the rule always answers h (N10).

**Remark 7.10(a). CORRECT; an addition is needed for the note (N1).** If the inputs and the length of a run depend only on (z, ρ), and the driver never abstains (an abstention ends the run), then the asked call of each round is a fresh draw from the sub-probability P_Π, independent across rounds. Simulated in part (7) for a scaffold with runs of variable length: the largest deviation of the empirical law from P_Π over 200,000 rounds was 0.0007. The statement about a *fresh* run, independent of the batch, is right. It says nothing about the runs that make up the batch, and item 4 does not carry over to them with m the number of calls (N1).

**Remark 7.10(b). CORRECT.** A wrong count on a stage is an integer at most ε·m_i, hence at most ⌊ε·m_i⌋. At ε·m_i < 1 the rule is enumeration.

**Remark 7.10(c). CORRECT.**

**Section 8.6. CORRECT; one label is stale.** I re-ran `proofs/code/shift-abstain_batch_rule.py` (42 seconds, at most 4 GB). Its output is identical to the saved file byte for byte (same MD5 hash, 5a71dc25…). The printed headings of parts (D) and (E), and the docstring, say "Example 7.8(a)" and "Example 7.8(b)" where the text has Example 7.9(c) and 7.9(b) (N11). The numbers quoted in Section 8.6 agree with the output.

**Table of Section 0.1, rows 48 and 49. MINOR (N12). Section 9, item 9. CORRECT.** The source's Theorem 5.4 with err ≤ ε gives a rejection rate of order √(d/n) at the balance point ε ≍ √(d/n), and there d/(nε) ≍ √(d/n). So the factor 1/ε is necessary in order of magnitude there, as item 9 says. **Section 11, the entry. MINOR (N6). Section 12.7. CORRECT.**

## 3. The note's block, compared with the proof file

| sentence of the note | verdict |
|---|---|
| "The rules above are never silently wrong, or they count their silent errors on asked inputs only." | MINOR: the paragraph just before it names the exception, Thr_η per run on the system it rehearsed (N13). |
| "If the inputs … a small *rate* of silent errors can be bought at a price that is linear in a bound on K." | CORRECT. |
| Status line: "the algorithm and its guarantee are those of Goldwasser, Kalai, Kalai and Montasser 2020, who treat classes of finite VC dimension with two answers; proved here for a countable class with any answers" | CORRECT (two answers: Y = {0, 1} in the source's Figure 2 and Section 4.1). |
| "Let the human be a function of weight at least 2^(−b) … h the heaviest of them." | MINOR: "the heaviest" is ambiguous under ties, and the choice does not matter (N9). |
| The description of Bat_ε | CORRECT: "batch inputs" counts indices with multiplicity, as in the proof file. |
| (a) | CORRECT: item 1. |
| (b), first sentence: probability at least 1 − δ, mass below γ/ε | CORRECT: weaker than item 3 (more than 1 − δ/2). |
| (b), second sentence: "ε ≥ 7.4·γ and ε·m ≥ b ln 2 + ln(1/δ)", probability at least 1 − δ over the batch | CORRECT: item 4 with δ′ = δ; 7.4 > e² = 7.389; "a law" and "further draws" give a probability law and independence. |
| (c) | CORRECT: item 6. |
| Proof of (a) | CORRECT. |
| Proof of (b): "both fit n independent questions … so each step refuses a set of mass at most γ" | MINOR: "both fit" should be "agree with each other at"; the summation over the steps is left implicit (N14). |
| "So n = … questions buy a rule that is silently wrong on at most a fraction ε of any batch and refuses a set of mass below ε′ under the law of its questions." | MINOR: the second part holds with probability at least 1 − δ only (N15). |
| "It is a whitelist whose soundness, up to the rate ε, is a theorem, at a price linear in b; enumeration needs up to 2^b − 1 answered abstentions (N7(b)), and the frozen minimum rule a rehearsal of the order of 2^K rounds (Ab2(d))." | MINOR (N3). |
| "With ε·m < 1 the rule is enumeration: never wrong, and a rock." | MINOR: enumeration is a rock only while b − K_D exceeds the complexity of the inputs; the note's own paragraph *Rocks* says so (N7). |
| (i) | CORRECT: Example 7.9(b). |
| (ii) | CORRECT: Example 7.9(a). |
| (iii), "The batch must be known before any of it is answered." | CORRECT as a statement of the hypothesis. |
| (iii), "the questions of a rehearsal are then independent draws from one law, and (b) applies to them" | MINOR, with a counterexample for one reading (N1). |
| (iii), "For questions that depend on the answers there is only a form by stages (Theorem 7.6, item 5)" | CORRECT. |
| (iii), "the obvious rule … is led to refuse everything (Example 7.9 there)" | MINOR: it refuses every later *unasked* input, of P-mass at least 1 − n/N, not everything; and the example is 7.9(c) (N16). |
| (iv) | CORRECT. |
| (v) | CORRECT: for a run of L calls that must be right, ε < 1/L, and the price is of the order of b·L/ε′ questions, as R1 needs about L·K/δ. |

## 4. Findings, with exact old and new sentences

**N1 (MINOR; note (iii), and the proof file's Remark 7.10(a)).** A batch made of the calls of r fresh runs does not consist of independent draws from P_Π, and item 4 fails for it with m the number of calls. Counterexample, computed exactly in part (7) of my script. Let one member c ∈ V have P_Π(Δ(c)) = γ = 0.002 (allowed on 𝓔), let each run put all its L = 20 calls in Δ(c) or none of them, and let ε = e²·γ = 0.0148, δ′ = 0.01, b = 1 and r = 33 runs. Then ε·m = ε·r·L = 9.8 ≥ b ln 2 + ln(1/δ′) = 5.30, but some index is refused with probability 1 − (1 − γ)^r = 0.064 > δ′. The correct form, supplied here: if every run has exactly L calls, then P_Π is a probability law, and item 4 holds for a batch of r fresh runs with ε·r ≥ b ln 2 + ln(1/δ′) in the place of ε·m. *Proof.* Let Y_k be the number of calls of run k in Δ(c), divided by L. The Y_k are independent, take values in [0, 1] and have mean P_Π(Δ(c)) ≤ γ ≤ ε/e². Hoeffding's form of the Chernoff bound gives Pr[Σ_k Y_k ≥ ε·r] ≤ exp(−r·kl(ε ‖ γ)) ≤ e^(−ε·r), by the inequality kl ≥ ε of item 4. Then take a union over the fewer than 2^b members. In the same computation, r = 359 runs give a probability of 1.0·10⁻⁴.

* Note, old: "The calls of fresh runs are such a batch if the scaffold's questions do not depend on the answers; the questions of a rehearsal are then independent draws from one law, and (b) applies to them."
* Note, new: "The calls of fresh runs are such a batch if the scaffold's questions do not depend on the answers; the questions of a rehearsal whose driver never abstains are then independent draws from one law, that of a uniformly chosen call, and the first claim of (b) holds for that law: a run drawn afresh, independently of the batch, has in expectation fewer than L·γ/ε calls in the refused set. The second claim needs independent draws; for a batch of r runs of L calls each it holds with ε·r in the place of ε·m."
* Proof file, Remark 7.10(a), old: "So Theorem 7.6 applies with n the number of rounds and P = P_Π, and item 3 reads: on 𝓔, for every batch z, a fresh run has in expectation fewer than L·γ/ε calls in R(z). Example 7.9(b) is of this kind."
* Proof file, new: "So Theorem 7.6 applies with n the number of rounds and P = P_Π, and item 3 reads: on 𝓔, for every batch z, a fresh run, independent of z, has in expectation fewer than L·γ/ε calls in R(z). Item 4 does not apply to a batch of m calls of runs, because the calls of a run are not independent: if Δ(c) has P_Π-mass γ and receives all L calls of a run or none, ε = e²·γ and ε·r < 1, a batch of r runs is refused in part with probability 1 − (1 − γ)^r, which can exceed δ′ while ε·r·L ≥ b ln 2 + ln(1/δ′) (`verification/code/shift-abstain_ab5_check.py`, part 7). If every run has exactly L calls, item 4 holds for r fresh runs with ε·r ≥ b ln 2 + ln(1/δ′) in the place of ε·m: the numbers of calls in Δ(c), divided by L, are r independent variables in [0, 1] with mean at most γ, and Hoeffding's form of the Chernoff bound gives probability at most exp(−r·kl(ε ‖ γ)) ≤ e^(−ε·r). Example 7.9(b) is of this kind."

**N2 (MINOR; Remark 7.8(i), the correspondence with the source).** Eq. (13) of Theorem A.2 bounds the rejection rate on a fresh sample z ~ Pⁿ. The bound on the rejection rate on P itself, which is what item 3 bounds, is eq. (15) of Theorem A.5: (2/n)·((2d/ε)·log 2n + log(2/δ)). The bound T ≤ ⌊1/ε⌋ is Lemma 5.1.

* Old: "Items 1 to 3 of Theorem 7.6 are their Theorem A.2 for a finite set of functions with any number of answers."
* New: "For a finite set of functions with any number of answers, item 1 of Theorem 7.6 is eq. (12) of their Theorem A.2, item 2 is their Lemma 5.1, and item 3 is the counterpart of eq. (15) of their Theorem A.5, which bounds the rejection rate on P by (2/n)·((2d/ε)·log 2n + log(2/δ)) for all test inputs at once; eq. (13) of their Theorem A.2 is the same kind of bound for the rejection rate on a fresh sample from P."

**N3 (MINOR; note, the price paragraph, and Remark 7.8(ii)).** "Whitelist" is defined (Definition 7.4) for rules frozen at D and refers to sep. What can be said is this: R(z) lies in the region where two members of V differ, which in a class with (P1) to (P3) is contained in {sep(x; A) ≤ 2b + c₂} (the argument of Proposition 7.5(2)). N7(b) is an upper bound for a rule that is never wrong. The factor L·K is missing in front of 2^K.

* Note, old: "It is a whitelist whose soundness, up to the rate ε, is a theorem, at a price linear in b; enumeration needs up to 2^b − 1 answered abstentions (N7(b)), and the frozen minimum rule a rehearsal of the order of 2^K rounds (Ab2(d))."
* Note, new: "It refuses only where two functions of weight at least 2^(−b) that fit the answers differ, which in the class of all programs means only inputs with sep(x; A) ≤ 2b + c, like enumeration, and on the law of its questions it refuses little; its soundness up to the rate ε is a theorem, at a price linear in b. The other guarantees are of another kind: enumeration is never wrong on any input and asks at most 2^b − 1 questions (N7(b)), and the frozen minimum rule with a set certain to contain the human needs a rehearsal of the order of L·K·2^K rounds to abort rarely (Ab2(d))."
* Proof file, Remark 7.8(ii), old: "and the frozen minimum rule a number of rehearsal rounds of the order of 2^K to abort rarely with a set that is certain to contain the human (Theorem 5.6 with α ≤ 2^(−K))."
* Proof file, new: "and the frozen minimum rule a number of rehearsal rounds of the order of L·K·2^K to abort rarely with a set that is certain to contain the human (Theorem 5.6 with α ≤ 2^(−K), whose term L·(K ln 2 + ln(1/(αδ)))/(α·n) is then about 2L·K ln 2·2^K/n)."

**N4 (MINOR; Corollary 7.7).**

* Old: "With ε = ε′ = √((2b ln 2 + ln(1/δ))/n) both hold."
* New: "If n ≥ 2b ln 2 + ln(1/δ), the choice ε = ε′ = √((2b ln 2 + ln(1/δ))/n) lies in (0, 1], and both hold."

**N5 (MINOR; Remark 7.8(i), the loop).** The source's Figure 2 maximises s_t(c) = err_x̃(h|S_t, c) − Λ·err_x(h, c) with Λ = n + 1, and stops when s_t(c_t) ≤ ε. Here err_x̃ is normalised by all n test inputs (eq. (5); eq. (9)).

* Old: "it repeatedly looks for a member of C that fits the examples and differs from h at more than a fraction ε of the test inputs not yet rejected, and rejects the region where the two differ. This is the loop of Bat_ε, with a search of V in the place of their empirical risk minimiser."
* New: "it repeatedly takes a member c of C that maximises the fraction of all n test inputs that are not yet rejected and at which c differs from h, minus n + 1 times the fraction of the training examples at which c differs from h (one call to an empirical risk minimiser, their Lemma 5.1); if this exceeds ε it rejects the region where c and h differ, and otherwise it stops. With realizable labels the maximiser fits the examples, so this is the loop of Bat_ε, except that Bat_ε takes the first member of V above the threshold ε·m and not the maximiser; the guarantees do not depend on that choice."

**N6 (MINOR; Remark 7.8(i) and Section 11, what was read).** The reader's report (`verification/referee-reader.md`, line 168) says that its author read pages 1 to 10, including Lemma 4.1. This referee read the source too (Section 5). The lower bounds are bounds in expectation.

* Old (Remark 7.8(i)): "and for some class of VC dimension d every learner has error plus rejection of at least a constant times √(d/n) (Theorems 5.4 and 5.5). The reader of the assembled note read Definition 1.1 and Theorems 5.2 to 5.5 in the source again (`verification/referee-reader.md`, finding F4)."
* New: "and for some class of VC dimension d every learner has, for some target, expected error on Q plus rejection rate on P of at least a constant times √(d/n) when n ≥ 2d (Theorem 5.4), and in the transductive model with m test inputs at least a constant times √(d/min{m, n}) (Theorem 5.5). The reader of the assembled note read Definition 1.1, Lemma 4.1 and Theorems 5.2 to 5.5 in the source again (`verification/referee-reader.md`, finding F4), and the referee of this section read Figure 2, Lemma 5.1, Theorems 5.2 to 5.5, A.2 and A.5 in arXiv:2007.05145v3 (`verification/shift-abstain-ab5-check.md`)."
* Section 11, old: "Definition 1.1 and Theorems 5.2 to 5.5 were read in the source again by the reader of the assembled note, `verification/referee-reader.md`, finding F4.]"
* Section 11, new: "Definition 1.1, Lemma 4.1 and Theorems 5.2 to 5.5 were read in the source again by the reader of the assembled note, `verification/referee-reader.md`, finding F4; Figure 2, Lemma 5.1 and Theorems 5.2 to 5.5, A.2 and A.5 by the referee of Section 7.4, `verification/shift-abstain-ab5-check.md`.]"

**N7 (MINOR; Remark 7.8(ii) and the note).** "Rock" (Definition 7.4, Proposition 7.5) needs the class to have (P1) to (P3), and for enumeration it holds only while b − K_D exceeds the complexity of the inputs.

* Proof file, old: "With ε·m < 1 the rule is enumeration: it is never wrong, and by Proposition 7.5(2) it is a rock below complexity b − K_D − c."
* Proof file, new: "With ε·m < 1 the rule is enumeration: it is never wrong, and in a class with (P1) to (P3), such as the programs of total functions, it refuses with certainty every input of the batch with sep(x; A) ≤ b − K_D − c₁, so by Proposition 7.5(2) it is a rock below complexity b − K_D − c₁ − c₃."
* Note, old: "With ε·m < 1 the rule is enumeration: never wrong, and a rock."
* Note, new: "With ε·m < 1 the rule is enumeration: never wrong, and refusing what enumeration refuses, every input that a test of about b − K_D bits separates from A."

**N8 (MINOR; Example 7.9(a)).**

* Old: "For the thresholds x ↦ 1[x ≤ i] on {1, …, N}, questions from the uniform law on {1, …, N/2} and a human with threshold above N/2, V contains every threshold from N/2 to N."
* New: "Let N be even and let H_b contain the thresholds x ↦ 1[x ≤ i] on {1, …, N} for i = N/2, …, N. With questions from the uniform law on {1, …, N/2} and a human with threshold above N/2, V contains every threshold from N/2 to N."

**N9 (nit; Setting 7.6 and the note).** The order of H_b is not used by any item (checked in part (1)).

* Proof file, Setting 7.6, old: "V := V(D) is the set of the members of H_b that agree with f at X_1, …, X_n, and h := h(D) is its first member."
* Proof file, new: "V := V(D) is the set of the members of H_b that agree with f at X_1, …, X_n, and h := h(D) is its first member. (The order only makes the rule deterministic: Theorem 7.6 holds for every choice of h in V and of the member taken at each step.)"
* Note, old: "Let V be the set of functions of weight at least 2^(−b) that fit the answers, and h the heaviest of them."
* Note, new: "Let V be the set of the functions of the class of weight at least 2^(−b) that fit the answers, and h one of them (for definiteness the first in a fixed order by non-increasing weight; the statements hold for any choice)."

**N10 (MINOR; Example 7.9(c), last sentences).**

* Old: "With batches of one input, item 1 gives enumeration."
* New: "With batches of one input and ε < 1, item 1 gives enumeration (with ε = 1 a batch of one input is always answered with h)."

**N11 (nit; the lead's script and its output).** In `proofs/code/shift-abstain_batch_rule.py`, the strings "Example 7.8(a)" and "Example 7.8(b)" (docstring lines 19 and 21, and the printed headings of parts (D) and (E)) should read "Example 7.9(c)" and "Example 7.9(b)". The saved output would then have to be regenerated; the numbers do not change.

**N12 (MINOR; table of Section 0.1, row 48).**

* Old: "the refused set has mass below (2b ln 2 + ln(1/δ))/(ε·n) under the law of the questions; nothing is refused on a batch from that law;"
* New: "with probability more than 1 − δ/2 over the questions the refused set has mass below (2b ln 2 + ln(1/δ))/(ε·n) under the law of the questions; if ε ≥ e² times that mass bound and the batch is long enough, with high probability nothing is refused on a batch of independent draws from that law;"

**N13 (MINOR; the first sentence of Section 7.4 and of the note's block).**

* Proof file, old: "The rules of Sections 4 to 6 are either never silently wrong, or they count their silent errors on asked inputs only."
* Proof file, new: "The rules of Sections 4 to 6 are either never silently wrong, or they count their silent errors on asked inputs only, or, like Thr_η on the closed system that it has rehearsed (Theorem 4.4), in expectation per run of that system."
* Note, old: "The rules above are never silently wrong, or they count their silent errors on asked inputs only."
* Note, new: "The rules above are never silently wrong, or they count their silent errors on asked inputs only, or, like Thr_η on the system it rehearsed, per run of that system."

**N14 (MINOR; the note's proof of (b)).**

* Old: "Two functions that differ on a set of P-mass above γ both fit n independent questions with probability below 2^(−2b)·δ, and there are fewer than 2^(2b) pairs; so each step refuses a set of mass at most γ."
* New: "Two functions that differ on a set of P-mass above γ agree with each other at all n independent questions with probability below 2^(−2b)·δ, and there are fewer than 2^(2b) pairs of functions of weight at least 2^(−b); so with probability at least 1 − δ every member of V differs from h, which agrees with it at the questions, on a set of mass at most γ, and the fewer than 1/ε steps refuse a set of mass below γ/ε."

**N15 (MINOR; the note, the price).**

* Old: "So n = (2b ln 2 + ln(1/δ))/(ε·ε′) questions buy a rule that is silently wrong on at most a fraction ε of any batch and refuses a set of mass below ε′ under the law of its questions."
* New: "So n = (2b ln 2 + ln(1/δ))/(ε·ε′) questions buy a rule that is silently wrong on at most a fraction ε of any batch, with certainty, and that, with probability at least 1 − δ over the questions, refuses on every batch a set of mass below ε′ under the law of its questions."

**N16 (MINOR; the note, (iii), last clause).**

* Old: "and the obvious rule for inputs that arrive one at a time is led to refuse everything (Example 7.9 there)."
* New: "and the obvious rule for inputs that arrive one at a time can be led, by ε·m copies of one input, to refuse every later input that was not asked (Example 7.9(c) there); whether another rule for such inputs works is open."

## 5. The source

**What I read.** I downloaded https://arxiv.org/pdf/2007.05145 (version 3, dated 30 September 2020 on its first page) and extracted its text with `pdftotext`. I also fetched the abstract page https://arxiv.org/abs/2007.05145 and read its metadata: title "Beyond Perturbations: Learning Guarantees with Arbitrary Adversarial Test Examples"; authors Shafi Goldwasser, Adam Tauman Kalai, Yael Tauman Kalai, Omar Montasser; submitted 10 July 2020, versions v1 to v3; and the abstract. In the paper I read the abstract, Definition 1.1 with eqs. (1) and (2), the paragraph introducing Rejectron, Section 4.1 with Lemma 4.1, Claim 4.2, Section 4.2 with eqs. (5) to (8), Figure 2, Lemma 5.1 with its proof, Theorems 5.2 to 5.5 and the remarks between them, the overview at the start of Appendix A, Lemma A.1 (the statement only), Theorem A.2 with its proof, the proof of Theorem 5.3, and the statement and proof of Theorem A.5. I did not read the appendices with the proofs of Lemma A.1 or the lower bounds. No project text went into any request: the two URLs were the only network requests.

**What the source says, against the account.**

* *Setting.* Two values: labels in {0, 1} (Figure 2 takes y ∈ Yⁿ; the definition of Rejectron uses 1 − h(x̃_i)). A class C of VC dimension d. n labelled training examples x ~ Pⁿ with labels f(x), f ∈ C. n unlabelled test examples x̃, in the PQ model drawn from Qⁿ, in the transductive model arbitrary and chosen by a white-box adversary who knows x, a true test sample z ~ Pⁿ, f, h and the learner. **Confirmed.**
* *The algorithm.* As in N5: h := ERM(x, y); S_t := {x : h(x) = c_1(x) = … = c_{t−1}(x)}; c_t maximises s_t(c) = err_x̃(h|S_t, c) − Λ·err_x(h, c) with Λ = n + 1; it stops when s_t(c_t) ≤ ε. The fraction is over all n test inputs. Lemma 5.1: T ≤ ⌊1/ε⌋. **Confirmed, with the correction N5.**
* *Theorem A.2.* Eq. (12): for all x, x̃ ∈ Xⁿ, err_x̃(h|S, f) ≤ ε, with certainty. Eq. (13): Pr_{x,z~Pⁿ}[∀x̃ ∈ Xⁿ : rej_z(S) ≤ (1/n)((2d/ε) log(2n) + log(1/δ))] ≥ 1 − δ. **The quotation is confirmed**, including "for all test inputs at once" and "a fresh sample from P". The correspondence with item 3 needs N2.
* *Theorem 5.3.* ε* = √((2d/n)·log 2n) + (1/n)·log(1/δ); with probability at least 1 − δ over x, z ~ Pⁿ, for every x̃, err_x̃ ≤ ε* and rej_z ≤ ε*. **Confirmed.**
* *Theorem 5.2.* ε* = √(8d·ln 2n/n) + 8·ln(16/δ)/n; Pr[err_Q ≤ 2ε* and rej_P ≤ ε*] ≥ 1 − δ. **Confirmed.**
* *Theorems 5.4 and 5.5.* There is a constant K > 0 such that for every d ≥ 1 there are a class of VC dimension d and laws P, Q with E[rej_P + err_Q] ≥ K·√(d/n) for every learner, some f, and every n ≥ 2d. In the transductive model, for m, n ≥ 4d, there are a law P and an adversary such that E[rej_z + err_x̃] ≥ K·√(d/min{m, n}). **Confirmed**; the account should say "in expectation" (N6).
* *Lemma 4.1*, cited by the task and by the reader, not by Section 7.4: rej_Q(S) ≤ rej_P(S) + |P − Q|_TV, and Pr_{x~Q}[x ∉ S and Q(x) ≤ Λ·P(x)] ≤ Λ·rej_P(S). **The digest's Section 5.1 quotes it correctly.**
* *Theorem A.5*, not quoted in Section 7.4 but the right counterpart of item 3: for ε ≥ √(8d ln 2n/n) + 8 ln(8/δ)/n, err_Q ≤ 2ε with probability 1 − δ (eq. (14)); and for every ε ≥ 0, Pr_{x~Pⁿ}[∀x̃ : rej_P ≤ (2/n)((2d/ε) log 2n + log(2/δ))] ≥ 1 − δ (eq. (15)). The digest's Section 5.1 quotes it correctly.

The status line of Ab5 in the note ("the algorithm and its guarantee are those of …, who treat classes of finite VC dimension with two answers") is **confirmed**. "2b replaces 2d·log 2n" is right as an analogy: in the source the term d·(T + 1)·log 2n of Lemma A.1, with T + 1 ≤ 2/ε, gives (2d/ε)·log 2n; here 2b ln 2 per pair, times T < 1/ε, gives (2b ln 2)/ε.

## 6. Scripts

**Mine:** `verification/code/shift-abstain_ab5_check.py`, output `shift-abstain_ab5_check.out`. It ran in 153 seconds under a 4 GB limit, with fixed seeds. It uses exact fractions for ε·m. Parts:

1. Items 1 and 2, exhaustively over every class of 2 to 4 functions among the 8 binary functions on 3 inputs and the 9 ternary functions on 2 inputs, every human, every asked set, every batch up to length 6 and nine values of ε (7.3 million cases, among them 2.2 million with ε·m < 1, and 3.5 million with another h or another choice of c). No violation.
2. Item 3, exactly (see Section 2). No violation; the largest Pr[not 𝓔]/δ was 0.112.
3. Item 4, exactly; and the case with the hypothesis dropped.
4. Item 6(b), exactly: the largest ratio to δ″ was 0.267.
5. Corollary 7.7 arithmetic.
6. Example 7.9 (a) exhaustively, (b) by simulation, (c) exactly, with soundness of the input-by-input rule checked on all short ordered streams.
7. Remark 7.10(a) and the counterexample of N1.

**The lead's:** re-run, identical output (Section 2, Section 8.6). The lead's script checks items 1 and 2 on random instances and random batches; mine covers all batches up to length 6 on the smallest classes. The lead's part (B) enumerates all samples as sequences for 40 instances; mine uses the exact law of the asked set for 120 instances, sub-probabilities included. Neither script checks item 5, which needs no check. Mine checks item 6(b), which the lead's does not.
