# Attack on Ab5 (Theorem 7.6 of `proofs/shift-abstain.md` and Proposition Ab5 of the note)

Adversarial reading of the material that the lead added in answer to finding F4 of `verification/referee-reader.md`. These are: Section 7.4 of `proofs/shift-abstain.md` (Setting 7.6, the rule Bat_ε, Theorem 7.6 items 1 to 6 with its proof, Corollary 7.7, Remark 7.8, Example 7.9 (a) to (c), Remark 7.10); its Section 8.6; the rows for it in Section 0.1, item 9 of Section 9 and the entries of Section 11; and the block at the end of Section 7.4 of `research/sections/shift-abstain.md`, from "Between the rock and the bet: batches" to "What it does not say" (i) to (v).

I wrote my own script, `verification/code/shift-abstain_ab5_attack.py`, without reading the lead's script. Its output is `verification/code/shift-abstain_ab5_attack.out` (fixed seed, about 30 seconds, well under 1 GB). Section and part letters below refer to that output.

**Verdict.** I found no counterexample to any item of Theorem 7.6, to Corollary 7.7, or to the computations in Example 7.9 and Remark 7.10. Every probability statement holds as written, including for a sub-probability P and for duplicated members. No finding is FATAL or MAJOR. There are six MINOR findings and five WORDING findings. Most concern sentences that let the researcher read more into the result than it gives:

* the refused mass is a statement about a fresh input, not about the inputs of the batch;
* the comparison of prices puts guarantees of different kinds side by side;
* the rule keeps a rock, in the form of a rate;
* in the example that is meant to show that inputs arriving one at a time are hopeless, a better rule for one-at-a-time inputs exists.

One finding is an improvement, not an error: the factor 1/ε in front of ln(1/δ) can be removed.

## Findings

### MINOR 1. The refused mass concerns a fresh input; the inputs of the batch itself can be refused far more often, even when they are drawn from P

*Where.* Note, Ab5(b): "With probability at least 1 − δ over the questions, for every batch the refused inputs lie in a set of P-mass below γ/ε." The table of Section 0.1 of the proof file: "nothing is refused on a batch from that law". The price paragraph of the note: "refuses a set of mass below ε′ under the law of its questions".

*What is wrong.* The sentences are true, because R(z) has P-mass below γ/ε. But R(z) depends on the batch, so this bounds only the probability that an input drawn from P *independently of the batch* is refused. Theorem 7.6 item 3 says exactly this. The inputs of the batch are refused at the rate P(R(z)) only under the extra conditions of item 4 (ε ≥ e²γ and εm ≥ b ln 2 + ln(1/δ′)). Without those conditions, a batch drawn from P can be refused almost entirely. The row of Section 0.1 drops the conditions altogether.

*Computation (part E).* Take the point functions c_i = 1[x = i] on N = 2^20 − 1 inputs, with h ≡ 0 as the human (2^20 members, so b = 20), P uniform, n = 10⁴ and δ = 0.1. Then γ = 0.0030, and 𝓔 holds surely because every pair differs on mass at most 2/N. The results:

| batch | share of the batch refused | P(R(z)) | bound γ/ε |
|---|---|---|---|
| m = 1, ε = 0.5 | 0.995 to 1.000 | about 10⁻⁶ | 0.006 |
| m = 10, ε = 0.05 (so εm < 1) | 0.99 | about 10⁻⁵ | 0.06 |
| m = 1000, ε = 0.01 | 0 | 0 | 0.30 |

So for small batches drawn from P (the enumeration regime), the batch is refused almost entirely, while the refused set has negligible P-mass.

*Replacement.*

* In the note, Ab5(b), after "below γ/ε", insert: "(this is the probability that an input drawn from P independently of the batch is refused; the inputs of the batch themselves, even when drawn from P, can be refused almost all, for example when εm < 1; the next sentence gives the condition under which they are not)".
* In Section 0.1, replace "nothing is refused on a batch from that law" with "nothing is refused, with probability 1 − δ′, on a batch of m draws from that law if ε ≥ e²γ and εm ≥ b ln 2 + ln(1/δ′)".
* In the price sentence, replace "refuses a set of mass below ε′ under the law of its questions" with "refuses, with probability at least 1 − δ over the questions, a set of mass below ε′ under the law of its questions".

### MINOR 2. The comparison of prices sets guarantees of different kinds side by side, and the cited bound does not say "needs"

*Where.* Note: "It is a whitelist whose soundness, up to the rate ε, is a theorem, at a price linear in b; enumeration needs up to 2^b − 1 answered abstentions (N7(b)), and the frozen minimum rule a rehearsal of the order of 2^K rounds (Ab2(d))." Remark 7.8(ii): "… where enumeration needs up to 2^b − 1 answered abstentions (Corollary 3.6(b)) and the frozen minimum rule a number of rehearsal rounds of the order of 2^K to abort rarely with a set that is certain to contain the human (Theorem 5.6 with α ≤ 2^(−K))."

*What is wrong.* There are three problems.

* **The guarantees differ in kind.** Enumeration is never wrong on any input sequence, and its abstentions are answered, so in the end nothing is refused. The minimum rule is never wrong and has a per-run abort bound on its closed system. Bat_ε allows εm silent errors per batch, and off P it may leave the whole batch refused and unanswered (Example 7.9(a)).
* **The linear price is not what is new.** Without any abstention the price on the law of the questions is already linear: a consistent h errs on P-mass ε after (b ln 2 + ln(1/δ))/ε questions, and the mixture without abstention has R1's L·K ln 2/n per run. What is new in Bat_ε is that the rate ε holds on *every* batch. The exponential prices of enumeration and of the minimum rule are the price of the per-input standard. The like-for-like comparison is enumeration frozen after n questions from P. Its refused mass is P(DIS(V)), which on the point functions above stays near 1 − n/N until n is of the order of 2^b.
* **Ab2(d) is an upper bound.** It says the abort probability is small after about L·(K ln 2 + ln(1/(αδ)))/α rounds. With α ≤ 2^(−K) for the top set that is about 2K·L·2^K rounds. For the ratio set of Theorem 5.6(a), where N_𝒞 ≤ 2^K/α, it is about 4^K. Neither shows that 2^K rounds are *needed*. A lower bound of order 2^K is Example 5.7(a), and only on the needle class.

*Replacement (note).* "It is a whitelist whose soundness, up to the rate ε on every batch, is a theorem, at a price linear in b. Without abstention, a price linear in b already buys an error rate ε on the law of the questions (and R1 per run); what the abstention buys here is that the rate holds on every batch. The rules that are never wrong pay exponentially: enumeration needs up to 2^b − 1 answered abstentions (N7(b)); frozen after n questions from P it refuses P{the members of V disagree}, which on the point functions stays near 1 − n/2^b; and the proved bound for the frozen minimum rule asks for about L·K·2^K rehearsal rounds (Ab2(d))."

Make the same change in Remark 7.8(ii): "the frozen minimum rule a number of rehearsal rounds for which the bound of Theorem 5.6 is small, of the order of L·K·2^K for the top set (Example 5.7(a): at least of the order of 2^K on the needle class)".

### MINOR 3. Bat_ε keeps the rock, as a rate; the text says only "off the law P the rule may refuse everything"

*Where.* The heading "Between the rock and the bet". The note's (ii): "Off the law P the rule may refuse everything." Remark 7.8(ii): "A member that differs from h at one input cannot make it refuse anything, unless that input fills more than a fraction ε of the batch."

*What is wrong.* Nothing in the text is false, but the rock is still there for novelty that is shared. Take a class with (P1). Let Q be a decidable set that contains no asked input and has K(Q) ≤ b − K_D − c₁. Then both patches h^{Q,b₀} and h^{Q,b₁} are in V. For every x ∈ Q at least one of them differs from h, and after the loop each has at most εm unrefused batch indices in its disagreement set. So **Bat_ε answers at most 2⌊εm⌋ of the batch inputs that lie in Q**, whatever their number. Example 7.9(b) is one instance, with Q a block. This is the rate form of Proposition 7.5(0): if more than a fraction 2ε of the calls of a batch share a property of fewer than b − K_D − c bits that no asked input has, all but 2εm of them are refused. That is exactly the task-decomposition worry of Section 7.3. The worry concerns inputs that *are* drawn from P but share a novel property. "Off the law P" therefore does not describe it.

*Check (part H).* In a class closed under patches on every set of one to three unasked inputs (5 inputs, 400 classes, 4000 batches, three values of ε), the number of answered inputs inside a patch set never exceeded 2⌊εm⌋.

*Replacement.* Add to the note's (ii): "More precisely, in the class of programs, if a set of fewer than b − K_D − c bits contains no asked input, the rule answers at most 2εm of the batch inputs in it: novelty that a short test describes is refused once it fills more than a fraction 2ε of the batch, as by the rocks of the table." Add the same sentence, with the proof above, to Remark 7.8(ii) after "unless that input fills more than a fraction ε of the batch".

### MINOR 4. The example meant to show that inputs arriving one at a time are hopeless admits a better rule for one-at-a-time inputs; the note's summary overstates it

*Where.* Note, (iii): "the obvious rule for inputs that arrive one at a time is led to refuse everything (Example 7.9 there)". The heading of Example 7.9(c) in the proof file: "*The batch must be known before any of it is answered.*"

*What is wrong.* The obvious rule does not refuse "everything". It answers the εm copies of 0 and the asked inputs, and refuses every later unasked input, a set of P-mass at least 1 − n/N.

More importantly, the example does not separate batches from inputs that arrive one at a time. Consider the rule that works one input at a time as follows: refuse x if two or more members of V differ from h at x; otherwise answer h(x) unless the single member that differs at x has already been counted ⌊εm⌋ times. This rule is sound up to ⌊εm⌋ for every human in V, because under human c a wrong answer is given only at inputs where c alone differs, and at most ⌊εm⌋ times. In Example 7.9(c) it refuses only the copies of 0, which have P-mass 0, and none of the draws.

*Computation (part F(c)).* With N = 1000, n = 100, m = 2000 and ε = 0.05, over three seeds:

| rule | what it refuses after 100 copies of 0 |
|---|---|
| the obvious rule | 1699 to 1742 of the 1900 draws (the lead reports 1712) |
| Bat_ε | one step: the 100 zeros and 1 to 5 draws (the lead reports 2) |
| the better input-by-input rule | the 100 zeros and no draw |

The proof file does say "It does not show that every such rule fails". But the heading and the note's sentence suggest that it does.

*Replacement.*

* In the note: "and the obvious rule for inputs that arrive one at a time can be led to refuse every unasked input (Example 7.9 there); whether some rule for such inputs has the guarantees of (a) and (b) is open."
* In the proof file, change the heading of 7.9(c) to "*The obvious rule for inputs that arrive one at a time fails.*" and add after "It does not show that every such rule fails": "In this example the rule that refuses an input at which two or more members of V differ from h, and otherwise answers until the one member that differs has been counted ⌊εm⌋ times, is as sound and refuses only the copies of 0, which have P-mass 0."

### MINOR 5. The per-run consequence is left out; Example 7.9(b) and the note's (i) suggest there is none

*Where.* Example 7.9(b): "It does not bound the probability that a given run contains a wrong answer." Note, (i): "ε is a fraction of the batch and not a bound for a run: … the ε·m wrong answers may all lie in the same runs."

*What is wrong.* For a batch made of the calls of r runs, the number of runs that contain a wrong answer is at most the number of wrong answers, which is at most εm ≤ εrL. So **a run chosen uniformly from the batch contains a wrong answer with probability at most εL**, whatever the batch. If the wrong answers lie in the same runs, as the text describes, fewer runs fail, not more. The worst case is one wrong answer in each of εm runs.

*Check (part H).* On 3000 batches of runs (up to 4 runs of up to 3 calls each, three values of ε), the runs with a wrong answer never exceeded εLr, and the bound was attained.

*Replacement.*

* Add to Example 7.9(b): "What it does bound is the share of the batch's runs that contain a wrong answer: at most εm/r ≤ εL, since each such run contains a wrong answer. So a run chosen uniformly from the batch is silently wrong with probability at most εL; a run singled out in advance is not covered."
* In the note's (i), replace "and the ε·m wrong answers may all lie in the same runs" with "although at most a fraction εL of the runs of the batch contain a wrong answer".

### MINOR 6. The factor 1/ε in front of ln(1/δ) comes from the method of proof and can be removed; the price is about half

*Where.* Theorem 7.6 item 3 and Corollary 7.7. Remark 7.8(i): "the term ln(1/δ) is divided by ε here because item 3 bounds each of the fewer than 1/ε sets separately".

*What is wrong.* This is an improvement, not an error. Count tuples (h, c₁, …, c_T) of members with T ≤ ⌈1/ε⌉ − 1 instead of pairs. There are at most 2·2^(b⌈1/ε⌉) such tuples when b ≥ 1. If all members of a tuple agree with f at the questions, no question lies in the union of their disagreement sets, and this has probability below e^(−ρn) when that union has mass above ρ. So, with probability at least 1 − δ, for every batch P(R(z)) ≤ ρ := (⌈1/ε⌉·b ln 2 + ln(2/δ))/n. The digest already has this count (`research/understand/abstention-shift.md`, Section 7.2, "|C|^(T+1) ≤ 2^(2k/ε)").

*Check (part B2).* Over 600 exact checks on small instances, the probability that the joint bound fails was at most 0.016·δ. For b = 30, δ = 0.05 and ε′ = 0.01, the price of Corollary 7.7 becomes 1.8 to 2.1 times smaller (4458 → 2448 at ε = 1; 445,846 → 208,313 at ε = 0.01).

*Replacement.* Add to Remark 7.8(i): "Counting the tuples (h, c_1, …, c_T) instead of pairs, as in the digest (Section 7.2), gives P(R(z)) ≤ (⌈1/ε⌉·b ln 2 + ln(2/δ))/n with probability at least 1 − δ, for all batches; ln(1/δ) is then not divided by ε, and the price of Corollary 7.7 becomes about (b ln 2/ε + ln(2/δ))/ε′." Section 9, item 9 can keep the open question for the b/ε term only.

### WORDING 1. "With ε·m < 1 the rule is enumeration: never wrong, and a rock."

Proposition 7.5(2) and the note's own paragraph *Rocks* make enumeration a rock only below complexity b − K_D − c, and that radius shrinks as the data single out the human. Replace with: "With ε·m < 1 the rule is enumeration with budget b, frozen: never wrong, and a rock below complexity b − K_D − c (row 2 of the table)."

### WORDING 2. "(b) applies to them" in (iii); the second half of (b) does not apply to a batch made of runs

Note, (iii): "The calls of fresh runs are such a batch if the scaffold's questions do not depend on the answers; the questions of a rehearsal are then independent draws from one law, and (b) applies to them."

Remark 7.10(a) is right: the asked calls are independent draws from P_Π. Part G checks this exactly, for runs of lengths 1, 2 and 3. But P_Π is a sub-probability whenever runs are shorter than L, and the calls of a run are not independent draws. So only the first half of (b), the refused mass, applies. The second half ("nothing is refused" for m draws from P) does not apply as stated to a batch of runs.

Replace with: "…the questions of a rehearsal are then independent draws from one sub-probability, and the first claim of (b) applies: a fresh run, independent of the batch, has in expectation fewer than L·γ/ε calls in the refused set." In Remark 7.10(a), add "independent of the batch" after "a fresh run". Also add: "With the convention of this file (⊥ ends the run), Protocol R driven by the mixture qualifies only if the mixture never abstains, that is, if all hypotheses are samplers." Part G shows that an abstaining driver changes the law of the asked call: the input b gets mass 2/9 instead of 1/3.

### WORDING 3. "inputs of the batch, drawn uniformly" in Ab5(c)

Note, (c): "the human can instead answer (b ln 2 + ln(1/δ))/ε inputs of the batch, drawn uniformly and independently". The proof (item 6(b)) draws *indices* uniformly from {1, …, m}. Drawing uniformly among the distinct inputs of the batch breaks the guarantee.

*Computation (part D2).* Take a batch with one input 50 times and 50 other inputs once each, m = 100, ε = 0.1, b = 2, δ = 0.1, so q = 37. A member that differs from f only at the repeated input survives index draws with probability 7·10⁻¹², but survives draws of distinct inputs with probability 0.48 > δ.

Replace with: "at least (b ln 2 + ln(1/δ))/ε positions of the batch, drawn uniformly and independently from 1, …, m (so that an input that occurs often is drawn often)".

### WORDING 4. What item 6(b) promises after the audit

Item 6(b) is correct. Part D checks it exactly in 1800 cases; the largest failure probability was 0.083·δ″. It promises that the *first consistent member answers the whole batch* with at most εm errors. It does not promise that Bat_ε, run again on the new data, refuses nothing.

*Counterexample (part D).* The class is (1,0,0,0), (1,1,1,0), (0,0,0,1), (1,1,0,0), with f = (1,1,0,0), the batch (3,1,2,2,2,1), ε = 1/2, and the audit asking input 3. After the audit every consistent member is within εm = 3 of f. Run again, Bat_ε answers only 1 of the 6 inputs. To pass the test again one needs 2ε, as the digest (Section 9.3) says.

Add to Remark 7.8(ii), after "(item 6(b))": "after the audit the batch is answered by the first consistent member, not by running Bat_ε again, which may still refuse (it passes with 2ε)."

### WORDING 5. Attribution and small points

* **Section 11 attribution.** "Theorem 7.6 is their Theorem A.2 for a finite set of functions" should be "Items 1 to 3 of Theorem 7.6 are their Theorem A.2 … (item 3 bounds the P-mass of the refused set, theirs the rejection rate of a sample from P); items 4 to 6 are not in their paper (item 6 is the digest's derivation, Section 9.3)". Remark 7.8(i) already says the first part.
* **Batches of one input.** Example 7.9(c), "With batches of one input, item 1 gives enumeration": this holds only for ε < 1. With ε = 1 and m = 1 the rule answers h and may be wrong. Add "for ε < 1".
* **Ties.** "h the heaviest of them" in the note: with ties, h is "the first of the heaviest, in a fixed order".

## What I attacked and could not break

* **Items 1, 2 and 6(a), exhaustively (part A).** I searched every ordered list V of 1 to 4 members on 4 inputs, with h first and duplicates and empty disagreement sets allowed, every human f in V, every batch of length up to 6 (as multiplicities; the rule depends on the batch only through them), and every threshold k = ⌊εm⌋ = 0, …, m. This covers every ε ∈ (0, 1], including ε = 1, every value with εm an integer, and every value below 1/m. That is 5,317,073 cases with no violation of:
  * wrong answers ≤ εm;
  * T < 1/ε for every ε with that floor;
  * T ≤ m and T ≤ |V| − 1, and T ≤ the number of distinct non-empty disagreement sets;
  * no member taken twice;
  * for εm < 1, answered exactly where V is unanimous.

  Item 1 is attained (1,518,335 cases with equality).

  The reduction to disagreement masks is exact. Run on 943,259 cases of real classes with 2 or 3 answers, real samples, ordered batch sequences and an exact grid of ε (Fractions, j/60 together with 1/m, 1/m − 1/1000 and every i/m), the separate index-level implementation (part A2) agreed with it in every case. It also confirmed that the refused indices are exactly those with z_j ∈ R(z).
* **Item 3 (part B).** I computed the probability of the complement of 𝓔 exactly over all samples, on 260 instances × 4 values of δ. The instances had 2 to 4 inputs, 2 or 3 answers, 2 to 4 members (duplicates in about 30%), probability and sub-probability P (total mass 0.4, 0.7 or 1), and n = 2 to 6. That probability was never at least δ/2; the largest ratio was 0.34. On 𝓔, P(R(z)) ≤ Tγ < γ/ε held for every human, batch and threshold. The reading "an input drawn from P independently of the batch, given D" is correct: then Pr = E[P(R(z)) | D]. The count "fewer than 2^(2b)/2 unordered pairs" is right, because |H_b| ≤ 2^b. Two members that are the same function contribute no pair of positive mass.
* **Item 4 (part C).** The exact binomial tails at the worst case p = ε/e² stay below e^(−εm) (largest ratio 0.36), for m up to 400 and eight values of ε. The kl inequality in the proof is correct. A multinomial instance with three members gives Pr[T > 0] = 0.014 < δ′ = 0.3. 7.4 ≥ e² = 7.389. h depending on the questions is harmless, since given the questions h is fixed and the batch is independent. "Fewer than 2^b members of V differ from h" is right (at most 2^b − 1).
* **Item 5.** Follows, since 𝓔 depends on the questions only.
* **Item 6(b) (part D).** I checked exact failure probabilities in 1800 cases (4 inputs, 2 or 3 answers, 4 members, m ≤ 6, q ≤ 4). The count "fewer than 2^b members differ from f" is right.
* **Corollary 7.7.** γ ≤ εε′ gives γ/ε ≤ ε′, with strict inequality from T < 1/ε.
* **Example 7.9(a) (part F).** Checked exactly for N = 8: every human above N/2, every set of asked inputs in {1, …, N/2}, and batches of copies of z > N/2.
* **Example 7.9(b).** The blocks without a question were 0.816 and 0.818 of the total, and 1624 and 1681 of 2000 one-run batches were refused (the lead reports 1626). The batch of 400 runs was never refused; the largest block had 4 or 5 runs, against the threshold of 40.
* **Example 7.9(c).** The P-masses (1 − n/N and 1/N) are right. "At most one step" holds in general, also when 0 occurs more than εm times. I checked it exhaustively for N = 4, all batches with m ≤ 6, εm an integer, and no other input more than εm times.
* **Remark 7.10(a) (part G).** For a scaffold whose inputs depend on (z, ρ) only, with runs of different lengths (1, 2, 3; L = 3), the law of the asked call is exactly P_Π (total mass 2/3, the rest being "no question"). It is the same in every round. Rounds are independent because (z_t, ρ_t, J_t) are fresh in each round. Different lengths are handled by J_t > ℓ_t.
* **Remark 7.10(b) (part H).** The stage count Σ_i ⌊εm_i⌋ held in 3000 two-stage instances in which the inputs of stage 2 depend on the rule's answers at stage 1. "Fewer than 1/ε calls ⇒ enumeration" is right.
* **Consistency with the rest of the file.**
  * With εm < 1, Bat_ε abstains exactly where two members of V differ, as Proposition 7.1 (N4) forces.
  * R(z) ⊆ DIS(V), so Bat_ε never refuses more than frozen enumeration. By (P2) its refused inputs have sep ≤ 2b + c₂, the whitelist width of row 2 of the table "Rocks and whitelists".
  * Proposition 7.5(0) does not apply for εm ≥ 1, as Remark 7.8(ii) says. Its rate form is MINOR 3.

  No contradiction with Proposition 7.5 or with the table.
* **The note's proof of Ab5(a) and (b).** Correct. The note weakens 1 − δ/2 to 1 − δ, which is consistent.
* **Remark 7.8(iii) and the note's (iv), (v).** Correct as stated.

## What I did not look at

* **The source.** I did not open Goldwasser, Kalai, Kalai and Montasser (2020). The statements of their Theorems A.2, 5.2 to 5.5 in Remark 7.8(i), and the claim in Section 9 that they show the factor 1/ε to be necessary when balanced, are unchecked by me. So is the mention of Goel, Hanneke, Moran and Shetty (2023).
* **The lead's script and the other check.** I did not read the lead's script `proofs/code/shift-abstain_batch_rule.py` or the other check report `verification/shift-abstain-ab5-check.md`. I compared only the numbers that Section 8.6 quotes.
* **General instances of (P1) to (P3).** The statements in the class of all programs (rock radius b − K_D − c, width 2b + c₂, and MINOR 3) were checked only by the argument from (P1) and (P2) and on a finite class closed under patches. They were not checked for programs.
* **Rules for inputs that arrive one at a time.** I did not try to decide whether such a rule with the guarantees of items 1 and 3 exists in general. MINOR 4 shows only that Example 7.9(c) does not separate.
* **A run-level form of item 4.** For a batch of r runs, a Chernoff bound for [0, 1]-valued counts per run would give "nothing refused" when ε·μ is large compared with γ, μ being the mean run length divided by L. I sketched this but neither proved it in full nor checked it numerically; it is not used above.
* **The assembled note.** I did not open note.md; I read only the section source.
