# Referee report on `verified-slack.md`, version 3 (the fifth note, "Verified slack imitation")

*Referee 7, an independent AI referee (Claude). 21 November 2026. I read the revised note against `slack-imitation.md` §1–3 (Lemma S, Theorem 2, Propositions 4 and 5), `note.md` (Lemma 1, Proposition 8, Proposition 11, §5, §6.3), `without-a-check.md` (Theorem 1), threads Q, F, G, J, H, N and S, referee 6's report and the author's response. Section 8's E7 entry is a placeholder and is ignored.*

*Scripts and outputs (all in `verification/`):*
* [`referee7_theory.py`](referee7_theory.py) → [`referee7_theory.out`](referee7_theory.out). Part 1 checks the search schedules: Lemma 3 with weights and the default-weight bounds of Theorem 5(d). Part 2 tests the hit value b_α when asks are made at the final-answer slot only, with a closed-form product class and an exact-Bayes toy VSI on referee 6's class. Part 3 runs the "nothing bizarre" check without (M2), and Part 4 gives Theorem 5(f) a counterexample. Parts 5–7 cover the heavy-tail arithmetic, the effort arithmetic and Proposition 7's hit rate.
* [`referee7_numbers.py`](referee7_numbers.py) → [`referee7_numbers.out`](referee7_numbers.out): every number in Sections 5–8 (not E7), checked against the result files and against thread S.
* [`referee7_eq_default.py`](referee7_eq_default.py) → [`referee7_eq_default.out`](referee7_eq_default.out): thread Q's experiment EQ re-run with the *recommended* weights (½, ¼, ¼), both as the deterministic schedule S, U, S, H and as a random draw. It uses thread Q's own code, the same humans and the same seeds, and reproduces thread Q's U+S+H column exactly.

## Verdict

**The revision is good. It answers almost every point of referee 6 and thread S, and the new framing (two predicates, (A4′), Theorem 6, the abstain rule, the narrowed recommendation) is right. But the changes to Theorem 5 introduced four errors, which need a short further revision. None of them touches the headline. Correctness of outputs still rests on (A4′) alone, and the 2n₀K worst case stands once the schedule is fixed and the bit count corrected.**

**What I confirmed.**
* *Lemma 3* holds with weights, with the "+ O(1)" right in general. For the default weights with the schedule S, U, S, H the constants are exact.
* *The default-weight bounds,* for the deterministic schedule S, U, S, H:
  * 2n₀ holds surely (worst observed 2n₀ − 1);
  * 4Λ holds in expectation (4n/|M| − 2);
  * 4, 4(1 + d) and 4(1 + d + i) hold surely.
* *Lemma 1* holds with asks: there were no failures in 919 toy rejections.
* *Lemma 2* and *Lemma 4* are correct as stated.
* *Theorem 5(a)* is correct.
* *Theorem 6(a)–(c)* is correct, as is the composition with VSI: every VSI rejection is a V_H rejection, so Lemma 1 applies to V_H.
* *Proposition 7's coefficients* are right, and its categories are now disjoint.
* *The thread quotations* in Section 4 now match the threads.
* *The numbers.* All of Section 8 matches its sources, with the qualifications C1, C2 and C7. The §7 table reproduces thread S §7 exactly.

**What must change.**
1. *b_α with final-answer asks (A1).* The revision restricted asking to the final-answer slot but kept b_α = max{1, log₂(1/α)} in Theorem 5(b), (e) and (f). A hit at a committed step outside that slot is worth only one bit. A three-line counterexample breaks 5(b).
2. *The "nothing bizarre" check (A2).* It is now in the core, and 5(b) counts its failures as hits, but (M1) and (M2) are not assumed. Without (M2), VSI loops forever.
3. *Theorem 5(f) (A3)* applies Lemma S to the goal S\* without assuming anything about S\*. A one-hypothesis class breaks it.
4. *"2n₀, surely" (A4)* holds only for a deterministic schedule. Lemma 3 also allows a random one, and §2.3 fixes neither.
5. *Contamination (B1).* Thread S's argument was applied to post-mortems only. It applies equally to the imitated human verifying a run, refereeing its cone, or checking it for bizarre content, before that same run is searched or audited.
6. *Effort and heavy tails (B3, B4).* The "factor 2" effort margin omits the β = 1 audits the note recommends and the cost of problems that violate (A2). The heavy-tail sentence also confuses (A2)'s n₀ with n.

---

## A. Errors

**A1. With asks only at the final-answer slot, a hit is worth one bit, not b_α. Theorem 5(b), (e) and (f) overstate by a factor of up to log₂(1/α).**
* *Where.* §2.2 makes asking optional and "restricted to the step that writes the claimed solution", and §2.3 step 1 does the same. Yet Theorem 5(b) claims rejections, failed checks and audit hits number at most K/b_α. Its proof says: "The decoder committed at k with top mass at least 1 − α under exactly the data before the hit".
* *Why it fails.* That holds only at a step where an ask *could* have fired. At every other committed step the decoder commits at any confidence. So the human's label there has mass at most ½, and the hit lowers Φ by at least 1 bit, not log₂(1/α). Referee 6's confirmation that "every hit is worth b_α bits" was for draft 1, which asked at every step; the response still cites it under "What held".
* *Counterexample* (`referee7_theory.out`, Part 2(a)).
  * The setup: m problems. Step 0 writes a or b, with prior Pr[a] = 0.4 independently per problem. Step 1, the final-answer slot, writes the same claim under every hypothesis. The human writes a, and V accepts iff step 0 is a, so (A2) and (A3′) hold. Take α = 0.1.
  * What happens: no ask fires, since step 1 has top mass 1. Every problem is rejected once, and the hit at step 0 is worth log₂(1/0.4) = 1.32 bits.
  * The count: for m = 10, there are 10 rejections against K/b_α = 13.22/3.32 = 3.98.
  * With asks at every step, as in SI-ABC, the same class has 0 rejections and 10 asks, which is consistent with the theory.
* *In a richer class* (Part 2(b), referee 6's exact-Bayes class).
  * With asks at every step, no hit fell below b_α.
  * With asks at the claim-writing slot only, 33 of 92 hits (α = 0.3) and 75 of 92 (α = 0.15) were worth less than b_α, down to 0.37·b_α ≈ 1 bit.
* *Fix.* Use b_α only when asks are made at every step. With final-answer asks only, take b = 1:
  * in 5(b): rejections + failed checks + audit hits ≤ K (or, more finely, #hits elsewhere + b_α·#hits at the slot ≤ K);
  * in 5(e): asks + K·min{2n₀, 4Λ} + βT;
  * in 5(f): K/(βγ).

  Proposition 7 asks at every step, so its K/b_α is correct.

**A2. The "nothing bizarre" check needs (M1) and (M2), which Theorem 5 does not assume. Without (M2), Theorem 5(b) and (c) fail.**
* *Where.* §2.3 step 2: "If the check fails, bisect to the flip, task-query it (by (M2) of note.md it is a mistake), and rerun." Theorem 5(b) counts failed checks as hits, and 5(c) claims every problem ends. Theorem 5's assumptions are (A1), (A2), (A3′), and (L0)–(L1) when L is used. Neither (M1) (the start notebook passes) nor (M2) (the human never makes a passing notebook fail) is among them.
* *Why it matters.*
  * Without (M2), the flip may be the human's own step. The query then returns the run's own label, the data do not change where all hypotheses agree, and the rerun repeats the run. It fails the check again, and VSI never terminates: there is no hit, no output and no abstention (Part 3: 1,000 reruns, 1,000 queries, no progress).
  * Without (M1) there is no flip at all.
* *Fix.* Either:
  * add (M1) and (M2) for the check (slack-imitation.md §2) to Theorem 5, saying that 5(b) and 5(c) use them; or
  * do as note.md's Proposition 9 does: if the flip's task query shows no mistake, output the verified artifact marked "flagged where the human would be".

  Correctness (5(a)) is unaffected either way.

**A3. Theorem 5(f) applies Lemma S to the goal S\*, but assumes nothing about S\*.**
* *The step.* "An audit of a failed accepted run hits with probability at least γ by Lemma S." An accepted run satisfies S_V, so a *failed* output fails S\*. For Lemma S to give |M| ≥ max{1, (σ+1)/(D+1)}, three things are needed:
  * S\* is preserved by appending;
  * the human's own chain reaches S\* within n₀ (τ\*(x₀) ≤ n₀);
  * (B_D) is measured in τ\*, the human's remaining time to S\*.

  (A2) and (B_D) as used in 5(d) are about S_V and τ_V.
* *Counterexample* (Part 4). Take the class {P}, so K = 0. V accepts P's chain, so S_V, (A2) and (A3′) hold, but the chain fails S\*. Every run is P's own and has no mistake, so it is output. The failed outputs number T, against the claimed bound 0.
* *Fix.* Add to (f): "Assume also that S\* is preserved by appending, that τ\*(x₀) ≤ n₀, and (B_D) in τ\* at the committed mistakes of accepted runs." Output runs pass the check, so by (M-prefix) none of their notebooks is bizarre, and "bizarre entries included" is not needed here (D6).

**A4. "2n₀, surely" holds only for a deterministic schedule, and the protocol does not fix one.**
* *Where.*
  * Lemma 3 allows streams "chosen at frequencies w_i, deterministically in proportion or at random".
  * §2.3 gives only the weights.
  * Theorem 5(d) says "2n₀, *surely*, whatever the human", and 5(e) says that an abstaining problem "costs at most 2n more". Answer 2 repeats the first claim.
* *What holds* (Part 1).
  * *Deterministic S, U, S, H* (an empty or exhausted list's turn passes on):
    * 2n₀ holds surely (worst 2n₀ − 1 over 20,000 searches at n₀ = 8, 9, 32 and 128);
    * 4, 4(1 + d) and 4(1 + d + i) hold surely;
    * 4Λ holds in expectation;
    * an abstaining search takes at most 2n queries.
  * *Random draws with the same weights.* All five bounds hold only in expectation. With the single mistake at scan position n₀, Pr[queries > 2n₀] is 0.29–0.37, and the worst case was 36 queries at n₀ = 8. For a ripe failure, Pr[queries > 4] = 0.31. In EQ with the random schedule, a silent human's search at n₀ = 8 took 18 queries, more than 2n₀ = 16 (`referee7_eq_default.out`).
  * *Other deterministic orders.* "Deterministically in proportion" is not enough: U, H, S, S has the same frequencies, and gives 2n₀ + 1 for odd n₀.
* *Fix.* In §2.3, fix the schedule: "queries cycle S, U, S, H". Then state 5(d) and 5(e) for that schedule, and say that with a random schedule the bounds hold in expectation.

**A5. Proposition 7 still lacks "bizarre entries included".**
* *The issue.* Proposition 7 has no bizarreness check, and its "other" runs are bounded by Lemma S, which slack-imitation.md states only for non-bizarre notebooks. Referee 6's A4 was fixed in Theorem 5(d) and (f) but not here.
* *Fix.* Write "(B_D) at the valid committed mistakes of the 'other' runs, bizarre entries included, except at steps that set a live approach aside". Theorem F4 inherits the same clause.

---

## B. Overclaims and inconsistencies

**B1. Post-mortem contamination was fixed; the same contamination through verification and the check was not.**
* *Thread S §3's argument.* Showing the imitated human a run and its outcome, just before task-querying prefixes of that run, makes its answers no longer P(x′_k). In exact Bayes one such answer refutes P and voids the K bound. The note accepts this and moves post-mortems to a second researcher (§2.2).
* *The same mechanism occurs three more times in VSI as specified.*
  * *V-human* ("the human's own verification", Answer 3). Every search follows the imitated human's own rejection of the run's claimed solution, and every audit follows its acceptance.
  * *V-cone with the imitated human as referee.* The referee reads the cone, often a large part of the run.
  * *The core's "nothing bizarre" check.* slack-imitation.md has "the human" read the whole final notebook, before the flip query and before every audit. This applies even with V-machine.
* *Fix.*
  * Say that verification and the check should be done by someone other than the imitated human, as post-mortems are. For the check, (M2) is then a condition on that person's verdicts about P's steps.
  * Otherwise, say that V-human's cost theory assumes the human's answers are unchanged by its own verification of the same run.
  * Add "answers after a verification or check of the same run" to measurement 4 in §10, and to §11's "Memory" item.

**B2. "V-machine respects [the user's constraint] fully: no human judgment at all" (§6) contradicts the core.**
* *The conflict.* §2.1 puts the final "nothing bizarre" check in the core. That check is a human judgment of the final notebook, with a preservation assumption (M2) of the first note's type. Correctness does not rest on it, so the letter of the constraint is kept, but "no human judgment at all" is false for VSI as specified.
* *Fix.* "V-machine rests correctness on no human judgment. The core's 'nothing bizarre' check is a human judgment of the final notebook, which serves only the talk's second desideratum and the cost, through (M2). It can be dropped or done by a second person."

**B3. Heavy tails. The 6–11% are problems not finished within n = 2n₀; (A2) fails on 25%.**
* *Where.* §6: "(A2) for every problem. … With n₀ at the 75th percentile of durations, 6–11% of problems are not finished (thread S, Part E). VSI abstains on them, at most 2n task queries each."
* *What thread S computes.* φ = Pr[τ > n] with n = 2n₀, so at the 75th percentile (A2) itself (τ ≤ n₀) fails on 25% of problems (Part 5 of `referee7_theory.out`).
  * *τ > 2n₀:* 5.5–11% of problems. VSI abstains on these.
  * *n₀ < τ ≤ 2n₀:* the other 14–20%. VSI does not abstain on these, but Lemma 1 fails: the first mistake may lie anywhere before n, so each rejection there can cost up to 2n = 4n₀, not 2n₀. Lemma S also guarantees fewer mistakes, with effective slack n − τ < σ.
* *The undercount.* "At most 2n each" counts only the final search on an abstaining problem. The rejections with hits on (A2)-violating problems are counted in K/b at 2n₀ each, but cost up to 2n.
* *Fix.*
  * Say "6–11% of problems are not finished within n = 2n₀, and (A2) fails on a quarter".
  * Add that on problems violating (A2), every search may cost up to 2n.
  * Or set n₀ at a high quantile and say which.

**B4. The "factor 2" effort margin (§7) omits the audits the note recommends, and costs that grow with T.**
* *The claim.* "VSI's guarantee is 2n₀K task queries, against chained imitation's 20n₀K … That leaves a factor 2 before the one-fifth bar, which the core's modest n₀ inflation does not use up. Verification costs come on top."
* *What it omits.*
  * *Audits.* §5 recommends β = 1 with human verifiers, which adds T task queries (Theorem 5(e)). Chained imitation's guarantee does not grow with T. Answer 2's "Task queries are at most 2n₀K" omits the βT as well.
  * *Its limit in T.* With β = 1 and verifications of 0.1–0.5 task steps, n₀ = 30 and no n₀ inflation, the bar holds only for T ≲ 40–55K (28–38K at ι = 1.3). Combined with the human-does-it baseline, T > 2K, the window is 2K < T ≲ 50K. (This is Part 6; at φ = 0 it reproduces thread S Part E's a = 2 rows.)
  * *Heavy tails.* With 5–10% of problems beyond n, which falls outside §7's conditioning, the window shrinks to T ≲ 4–15K. Thread S charges n per abstained problem, and Part 6 charges the note's 2n.
* *"Modest n₀ inflation".* For the 70% row, the human's own chain must end with a formal proof. Thread S §1.1 puts that at "several times the informal proof's time when the library is missing", and thread F §9 gives 25% that a fully formal discipline stays within 1.5×. So "modest" is not established for that row.
* *Fix.* Say that the factor-2 margin is for task queries in the search, with V-machine and β = 0. Add that with a human verifier, audits at β = 1 and verifications make the effort grow like T, so VSI meets the bar only for T up to about 40–55K (fewer with heavy tails). Also state the formalization cost as a condition of the 70% row.

**B5. The §7 table gives Proposition 7 the guarantee of Theorem H1, but Proposition 7's own hit rate is c_r/(3n).**
* *The rate.* In Proposition 7, c_r = min{(σ+1)/(D+1), r}. With the retry rule at r = 2 or 3, which is the case F1 tests, c_r ≤ 3, so "other" failures are charged about 3n/c_r ≈ n per bit. That is chained imitation's order, not (D+1)/ρ (Part 7).
* *Evidence.* F1 shows exactly this. W-trusting failures with r = 3 grow as 77 → 161 → 315, in proportion to n.
* *The table.* Its cell for the Proposition 7 row, "O((K/α + K)·(D+1)·log(K/(αδ))/(ρε)) (Theorem H1, for asking)", does not apply. Even the deployment paragraph's γ = min{⅓, 1/(3d_max), c_r/(3n)} gives a factor about n/c_r.
* *Fix.* Write the row's guarantee as O((K/α + K)·max{d_max, n/c_r}·log(…)/ε). Or split "other" runs into those that set a live approach aside (r mistakes) and the rest (c mistakes), which gives a sharper inequality.

**B6. Which claimed solution does V check? (A2) and (A3′) depend on the answer.**
* *The ambiguity.* §2.3 says "Apply V to the claimed solution", while §2.1 notes that "a notebook can hold a correct solution and a later plausible wrong one".
* *Why it matters.*
  * *If V checks the last claim only.* S_V is then not preserved by appending, and (A3′) fails on extensions of the human's notebook where the imitator appends a wrong "v2". Lemma 1 then fails, and the abstain rule can fire on solvable problems.
  * *If V accepts when any claim passes.* That is what (A2) and (A3′) need, but then each run may need several verifications, which is costly with V-human. Each wrong claim is also another chance to pass, which raises f for the slack runs.
* *Fix.* Specify that V accepts iff some claimed solution passes, and that the output is the first passing one. Count the verifications per run, and add the multiple-claims effect to §5.

**B7. "This uses neither (A1)–(A3′) nor any property of the human" (Theorem 5(a)).**
* *What holds.* The inference from acceptance to S_V, and then to S\*, uses no property of the task human.
* *What does not.* For V-human, and for V-cone with a human referee, (A4′) *is* a property of a human's judgment, as §6 itself says. Referee 6's B1 asked for this qualifier, and the response describes it as done.
* *Fix.* Write "uses no property of the human's task steps; for V-human and a human referee, (A4′) is itself an assumption about a human judgment".

**B8. p·w·f counts one look by the verifier.**
* *Answer 5's rate.* "about p·w·f per problem", with f "the verifier's miss rate on those".
* *Why one look is too few.* On a problem with a problem-specific insight, each rerun after a hit may end with a *different* wrong claim. Each one is another chance for V to miss it, and caching on a canonical form does not help, since the claims differ.
* *Thread S's own correction.* Part B of thread S uses f_eff, "the verifier pass rate after reruns".
* *Fix.* Write p·w·f_eff, with f_eff ≈ 1 − (1 − f)^{r}, where r is the number of claim-carrying runs per problem. Or say that p·w·f is a lower bound.

**B9. Which τ?**
* *The problem.* §1 introduces τ(y) and (B_D) without saying which predicate they refer to:
  * 5(d) needs τ_V;
  * 5(f) needs τ\* (A3);
  * Proposition 7, which has no verifier, needs the goal's τ.

  Yet Proposition 7 assumes "(A2)", which is defined through S_V and τ_V.
* *Fix.* Define τ_V and τ\* in §1. Restate Proposition 7's (A2) for the goal ("S\* preserved by appending, τ\*(x₀) ≤ n₀"), and say which τ each use of (B_D) refers to.

**B10. V-cone's (A4′) is stated as (L2) only.**
* *What (A4′) needs.* Referee 6's A2 listed three things:
  * L's soundness, (L2);
  * the claimed solution's statement being the goal;
  * machine records and retrieved sources (R entries) being correct, which Lemma F0's proof takes as "correct by construction".

  §6 now gives only the first, and the response says the point is done.
* *Fix.* Add the other two to §6's V-cone bullet.

**B11. "The human cannot solve the problem in n steps" (Answer 1).**
* *What abstention shows.* It shows only that the human's own n-step chain fails S_V, that is, V rejects it.
* *Why that is weaker.* With V-machine, S_V may require a formal artifact that the human's chain does not produce, even though it solves S\*.
* *Fix.* Write "the human's own chain does not reach a verifiable solution within n steps".

---

## C. Numbers

All figures were checked with `referee7_numbers.py`. Those not listed are correct:
* E6's chained, fooled, silent and SI-V figures;
* EQ's fooled and silent figures, and 1.45× and 1.64× (1.454 and 1.640);
* G1's 285–310;
* F1's 9–11, 0, 7–16 asks, and the retry rule's 3–4 (2.9–3.1 and 3.9–4.3);
* §5's log₂(1 + R_p);
* §6's 0.02, 0.1–0.4, 0.1–0.35, 0.2–0.5, above 0.5, 25–55% and 60–96%, and 1.2–1.6×;
* every probability in §7 and Answer 3, against thread S §7.

**C1. EQ's numbers are for equal weights. The recommended default costs more on bounded-setback and fooled humans.**
* *What §8 quotes.* "U+S+H, equal weights" for 40 → 55 → 54, and "extra streams: bounded-setback humans pay at most 1.45×". Both are measured with equal round robin, which the note no longer recommends.
* *The default weights* (½, ¼, ¼), with the same humans and seeds and schedule S, U, S, H (`referee7_eq_default.out`):

  | human | U | U+S+H, equal | S, U, S, H (default) |
  |---|---|---|---|
  | noticing | 13 → 14 → 14 | 15 → 20 → 20 | 25 → 32 → 32 |
  | misled-2 | 14 → 14 → 14 | 18 → 20 → 20 | 28 → 33 → 32 |
  | misled-8 | 38 → 16 → 14 | 32 → 23 → 20 | 44 → 35 → 33 |
  | fooled | 181 → 750 → 2,636 | 40 → 55 → 54 | 53 → 73 → 72 |
  | silent | 1,610 → 6,450 → 26,091 | 663 → 2,497 → 9,734 | 559 → 2,103 → 8,238 |

* *The trade-off.* Bounded-setback humans pay up to 2.3× U under the default, not 1.45×. Fooled humans pay 1.3× more than with equal weights, and silent humans 15% less. This is the price of the sure 2n₀, and §2.3 or §8 should state it.
* *Fix.* Quote the default-weight row, or both rows.

**C2. E6, "then about 205".** At n₀ = 32, misled-8 costs 227, and the bounded-setback range there is 204–227; at n₀ = 128 it is 204–205. Write "then 204–227".

**C3. §5, "×2 to ×4.4 at f = 0.1".**
* *What the figures are.* Equal weights at ρ = ½: 0.19/0.10 and 0.44/0.10. At ρ = 0 the factors are ×2.7 to ×6.1.
* *Under scan-heavy weights.* With 8:1:1 weights they are ×1.6 to ×3.4, and the default lies between the two.
* *Fix.* Add "(ρ = ½, equal weights)".

**C4. §5, "3.2 bits at f = 0.1".** Thread S's figure takes f_aimed = 0.9 (log₂ 9 = 3.17). With f_aimed = 1 it would be 3.32. Say "with f_aimed = 0.9".

**C5. §5, best-of-k "adds about log₂ k bits".** Thread S gives ln k − (k−1)/k nats, which is 4.6 bits at k = 64 against log₂ 64 = 6. Write "at most log₂ k".

**C6. §6's 6–11%.** See B3: these are problems not finished within 2n₀.

**C7. F1, "about 260 → 1,200".** SI goes 295 → 1,224 and SI-ABC 257 → 1,165. Write "260–300 → 1,200".

**C8. The §7 V-human row.** Thread S's 40% / 10% is for "VSI with a human verifier, *imitated*". The note applies it to V-human in general, including the human verifying every output, which should be at least as sure. Say so, or give that variant its own figure.

---

## D. Minor

1. **Lemma 3's proof.**
   * The step "stream i is served at least once in every ⌈1/w_i⌉ queries … so … within about j_i/w_i" does not follow when 1/w_i is not an integer. Its premise gives only j·⌈1/w_i⌉: 3j at w = 0.4, not 2.5j.
   * The conclusion is still true, for a different reason. A proportional schedule has bounded discrepancy, so the j-th service comes by position (j+1)/w_i (Part 1(d), w = (0.4, 0.3, 0.3)). Say that instead.
   * For the default weights, S, U, S, H is exact.
2. **Lemma 1** uses (A3′), and P's determinism through "the human's own notebook c_{n₀}". It does not use (A2), and (A3′) implies τ_V(x₀) ≤ n₀ anyway.
3. **Excused flags.** Theorem 5(d) says "plus one more for each excused flag", but §2.3(i) tries one flag and then goes to (ii). Under (L1) there are none. Make the two agree, for example "query each flagged step in turn; excused ones cost one query each".
4. **Theorem 6(b) is garbled:** "… not asked, and rejected by V_H would be is at most …". It should read "… not asked, and that V_H would reject, is at most …".
5. **Citations for the check.** The "nothing bizarre" check and its (M1), (M2) and (M-prefix) are from slack-imitation.md §2. note.md §5 and its (M2) concern the on-track monitor. Fix this in §2.1 and §2.3.
6. **Theorem 5(f)'s "bizarre entries included"** is stronger than needed: output runs pass the check, so with (M-prefix) none of their notebooks is bizarre.
7. **Theorem 5(e)'s human effort** omits the "nothing bizarre" checks: one per accepted run, plus ⌈log₂ n⌉ per failed check.
8. **The final-answer slot needs a definition,** for example "a step at which some label of posterior mass at least α writes a claimed solution". Otherwise a confident omission of the claim is never asked about.
9. **Answer 6, "about n queries per insight".** Theorem F3 gives n₀, and Theorem G3 the routine work, as §4 now says correctly. Referee 6's B3 asked for this.
10. **§4, "pays n₀ only when none applies".** With the default weights it is 2n₀ (n₀ scan steps).
11. **§9.** Proposition T6's bound is in expectation, and its (D+1)r/(s+1) term needs within-call (B_D). The bound on Φ also needs b(D+1) ≥ 2ρ.
12. **§4, Theorem J4: "outside such classes there is no converse".** Thread J shows that only outside *hiding* classes. For hiding classes that are not faithful, the question is open.
13. **§2.2, "multiply their miss rates, less the correlation".** The joint miss rate is f₁f₂ + Cov(miss₁, miss₂). It equals f₁f₂ only for independent misses.
14. **The abstention cost.** If answers are cached (the scan skips asked steps, and repeated draws are free), an abstaining search costs at most n distinct task queries, not 2n.
15. **§5, conditioning.** With w defined as a share of failed runs, the output error rate is (1−c)wf/(c + (1−c)wf). The note's wf/(c + wf) is right only near c = 0.
16. **Theorem 5(c) is stated under the theorem's assumptions,** which already include (A2) and (A3′). Say that termination needs only (A1) (and (M2), A2), and that without (A2) and (A3′) the number of rejections is at most K/b + #abstentions.
17. **§4's list of location sources** still omits located probes (thread B's (Loc_s), thread J's "confession" state), which need foresight. Referee 6's B3 suggested adding them.
18. **§11** does not mention heavy-tailed research times, as referee 6's B7 asked. It now appears in §6, which is acceptable.

---

## The response file, item by item

Every claimed fix is present, except as listed here.

| item | claimed | status |
|---|---|---|
| "What held": every hit is worth b_α | confirmed by referee 6 | **No longer true** after asks were restricted to the final-answer slot (A1). |
| A1 | 5(a) says V is consulted on every output | Present in Answer 2, but not in Theorem 5. Add it to the theorem's preamble. Theorem 6 and the table: correct. |
| A2 | two predicates; (A4′) for V-cone is (L2) | Present, but (A4′) for V-cone also needs the statement to be the goal and the R entries to be correct (B10). |
| A3 | Proposition 7: (L0)–(L2), disjoint categories, per-run d_t, where (B_D) holds | Present and correct, except "bizarre entries included" (A5) and the referent of (A2) (B9). |
| A4 | "bizarre entries included" in 5(d) and 5(f) | Present. Unnecessary in (f) (D6). |
| A5, A6, A7 | Q1, Theorem 6(c), the J1 sketch | Present and correct. |
| B1 | "uses neither determinism nor any property of the human" | The qualifier referee 6 asked for is missing for V-human and V-cone (B7). The rest is present. |
| B2 | when imitating the verifier pays | Present and correct. |
| B3 | thread quotations | Present and correct in §4 and §9. Answer 6 still says "about n" for F3 (D9). |
| B4 | the table | Present and correct, except the Proposition 7 guarantee (B5). |
| B5 | effort, factor 2, baseline | Present, but it omits audits at β = 1 and the limit in T (B4). |
| B6 | p·w·f, conditioning | Present. note.md §6.3's point that filtering raises the share of verifier-fooling failures is not cited explicitly (thread S's conditioning covers it). Also B8. |
| B7 | abstain rule, termination | Present for searches. Termination also needs (M2) for the check (A2). |
| B8 | the constraint per verifier | Present. The V-machine sentence contradicts the core's check (B2). |
| C1–C8 | numbers | All present and correct. |
| D1–D14 | minor | All present. D4's "the scan bound is sure" holds only for a deterministic schedule (A4). D12's K/b_α is now wrong with final-slot asks (A1). |
| Thread S: post-mortem contamination | second researcher | Fixed for post-mortems only (B1). |
| Thread S: the 4/3 margin | factor 2 with the default weights | Partial (B4). |
| Thread S: weighted streams | Lemma 3 with weights, default (½, ¼, ¼) | Adopted, but the schedule is not fixed (A4), and §8 quotes equal-weight results (C1). |
| Thread S: probabilities | adopted | Correct: the §7 table matches thread S §7 cell for cell (but see C8). |

## Sections 5–7: consistency

* **Section 5** is consistent with thread S §2, with C3–C5 and D15. It does not overclaim: it correctly confines "no optimization" to exact Bayes with a deterministic decoder.
* **Section 6** has three inconsistencies: the heavy-tail sentence (B3), the V-machine sentence (B2), and V-cone's (A4′) (B10).
* **Section 7.**
  * *Consistent with thread S:* the probabilities, and the reasons for adopting them.
  * *Inconsistent:* the conditioning includes "a cold-start chain that succeeds within n₀", yet "heavy tails" is listed among the reasons for lowering the figures. Under that conditioning, heavy tails cannot lower them. Say that they lower the unconditioned figure, or drop them from the list.
  * *The effort argument* has the omissions in B4.
