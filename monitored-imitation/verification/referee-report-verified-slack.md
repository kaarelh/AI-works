# Referee report on `verified-slack.md` (the fifth note, "Verified slack imitation")

*Referee 6, an independent AI referee (Claude). 21 November 2026. I read the note against `slack-imitation.md` (version 2, §§1–3), `note.md` (Lemma 1, Theorem 3, Proposition 8, §6.3), `without-a-check.md` (Theorem 1) and the threads Q, F, G, J, H, N, L and E. Thread R's E7 placeholder is ignored, as instructed.*

*Scripts and outputs:*
* [`referee6_numbers.py`](referee6_numbers.py) → [`referee6_numbers.out`](referee6_numbers.out): every number in Section 7 and the answers in brief, checked against `threadQ_hints.json`, `threadG_byproducts_sim.out`, `threadF_certified.out`, `threadF_cbc.out` and E6's result files; the constants of thread J's class 𝒲; the effort arithmetic of Section 6; an imitated verifier on the hidden-insight class.
* [`referee6_theory.py`](referee6_theory.py) → [`referee6_theory.out`](referee6_theory.out): VSI run with exact Bayes on a toy class (two kinds of human: bounded setback with D = 0, and resetting humans with setback up to n₀), with asks (α ∈ {1, 0.5, 0.3, 0.15}), route (i) through a local check, and adversarial, good and empty H lists. Also checks Theorem 5(e) with an unsound verifier, and Theorem 6.

## Verdict

**The core of the note is correct. It needs a moderate revision: of how the three verifiers are covered by Theorem 5, of a few hypotheses, and of several quotations of the threads. No result needs to be withdrawn.**

**What I confirmed.**
* *Theorem 5(b).* Every hit is worth b_α bits, whichever route found it: the search streams, the H list, route (i) and audits. The ordering argument holds with asks.
* *Theorem 5(c).* The factor 3 is right. The 3n₀ bound holds surely, not only in expectation. The cases where H is empty or contains asked steps are harmless.
* *Lemma 1* holds with asks.
* *Theorems 5(d), 5(e) and 6(a)–(b)* are correct as stated.
* *The toy simulation* found no violation of Lemma 1, of the b_α value of a hit, of the counts in 5(b), or of the 3n₀ bound. It covered 1,600 paths and every combination above, and route (i) fired 800 times.

**What must change.**
1. *Correctness of the imitated human verifier.* The note defines V-human as the *imitated* verifier (§2.2), yet credits it with Theorem 5(a), "no failed run is ever output" (A1). For that variant, correctness rests on V_H's soundness *plus* Theorem 6's imitation error. That error is not small when verdicts need problem-specific knowledge (B2).
2. *Hypotheses.*
   * V-cone's S is defined so that (A4) holds vacuously; correctness then needs L's soundness (L2), which Theorem 5 does not assume (A2).
   * Proposition 7 needs (L2), through Theorem F4, and disjoint categories of failed runs. As stated, its inequality can fail (A3).
   * The Λ bounds need (B_D) at bizarre entries too (A4).
3. *Quotations of the threads.* Several are stronger than the threads' statements:
   * Theorem Q1 does not hold "with any number of verifications" (A5);
   * Theorem J4, not J3, gives the matching lower bound, and only on *faithful* hiding classes;
   * Theorem G3 does not cover verifiers;
   * Theorem G1's corollary gives a guaranteed gain, not a cap;
   * the trees lower bound T4 is written out only in outline, and Proposition T8 is a sketch (B3).
4. *Liveness.* "Rerun until accepted" never terminates on a problem whose rejected run has no committed mistake. That happens when τ(x₀) > n₀, when V is incomplete, or after an (L1) drop at route (i). A one-line stopping rule fixes it (B7).
5. *Numbers.* All but a few are accurate. EQ quotes the U+H column for fooled humans, whereas VSI's search is U+S+H, which gives 40 → 55 → 54 (C1). Some ranges need their qualifiers (C2–C7).

---

## A. Errors

**A1. The imitated human verifier does not satisfy (A4), so Theorem 5(a) does not cover it.**
* *The definition.* §2.2 defines (V-human) as "the human's verification of the finished notebook, imitated as in Theorem 6". The verifier VSI then applies is the composite: V′, with V_H consulted on V′'s rejections and on a β-fraction of its acceptances.
* *Why (A4) fails.* Even if V_H never passes a wrong result, the composite does, whenever V′ accepts falsely and no audit follows. Theorem 6(b) bounds the expected number of such cases by (1−β)K_V/β, not by 0.
* *Where the note overclaims.* Answer 2 says "no failed run is ever output". The table of §6 says that correctness for this row rests on "(A4)". Answer 1 adds that only about K_V/ε verdicts are needed. Read together, these give no failures at K_V/ε verifications, which is not what is proved.
* *Fix.* State the guarantee for V-human imitated as follows. Expected failed outputs ≤ (1−β)K_V/β + (failures that V_H itself passes); with β = K_V/(εT), at most εT + (V_H's misses). In the §6 table, the "correctness rests on" entry for this row should read "V_H's soundness, and the imitation's ε". Keep "no failed output" for V-machine, and for V_H asked on every notebook.

**A2. V-cone: as S is defined, (A4) holds vacuously, and correctness needs (L2), which Theorem 5 does not assume.**
* *The definition.* §2.2 defines S, for V-cone, as "y contains a claimed solution whose dependency cone passes L".
* *The consequence.* V then decides S by definition, so (A3) and (A4) hold trivially. Theorem 5(a)'s "every output satisfies S" then says only that the cone passes L.
* *What correctness actually needs:*
  * L's soundness (thread F's (L2), via Lemma F0);
  * the claimed solution's statement being the goal;
  * machine records and retrieved sources being correct. Lemma F0's proof treats R entries as "correct by construction", which is an assumption for retrieved texts.

  §5 says some of this, but the theorem's list of assumptions does not.
* *The cleaner formulation is two predicates.*
  * S_V is what V decides. It must be preserved by appending and reached by the human's own chain within n₀; Lemma 1, Lemma S and τ use S_V.
  * S\* is the goal. Correctness is (A4′): S_V ⇒ S\* on imitator final notebooks.
  * Then (A4′) is "the specification captures the intent" for V-machine; (L2) with Lemma F0 for V-cone; and the human's soundness for V-human.
  * This also shows that (A3), as stated, is more than Lemma 1 uses. Lemma 1 needs only that V accepts every extension of the human's own notebook at step n₀.

**A3. Proposition 7 is missing (L2), and its inequality fails when categories overlap.**
* *The missing hypothesis.* The bound for "other failed runs" uses Theorem F4. F4's proof says: "By (L2), a valid certified obstruction is true, so it cannot set aside a live approach." F4's own statement omits (L2), and so does Proposition 7.
  * Without (L2), an obstruction that passes L but is false can set aside a live approach in one step, so |M| ≥ min{c, r} fails.
  * *Fix:* add (L2), and (L0), to Proposition 7. Also restore "or by a certified obstruction" in §2.1's paraphrase of the retry rule (Δ5_r); that clause is why (L2) is needed.
* *The overlap.* The left side adds E[#runs with an invalid entry] and ⅓·E[#ripe failures], but a ripe failure can also contain an invalid entry. The invalid-entry route then gives q_t(M_t) = 1, while the left side counts 1 + ⅓.
  * *A counterexample.* Take two hypotheses P and P′ of prior ½ each, so K = 1, and α ≥ ½, so b_α = 1 and no asks fire at the tie. At an earlier step P′ omits a readable insight I that P writes. At the last review, P (by (R-rev)) writes I in a valid entry, while P′ writes an invalid entry without I. With ties broken towards P′, the first run is a ripe failure with an invalid entry. Its query refutes P′, so every later run succeeds. Then the left side is 1 + ⅓ = 4/3 > K/b_α = 1.
  * *Fix:* make the categories disjoint: invalid; else ripe or hedge; else other. Runs that are both ripe and hedge are fine, since their review and decision steps differ and q_t(M_t) ≥ ⅓ + 1/(3d) covers both terms.
* *Per-run d.* d varies from run to run. Write E Σ_t 1[hedge_t]/(3d_t), or use d_max.
* *"Elsewhere".* "(B_D) at committed, valid mistakes elsewhere" should say exactly where (B_D) is assumed: at every valid committed mistake of runs in the "other" category, except steps that set aside a live approach.

**A4. The Λ bounds of Theorem 5(c)–(e) need (B_D) at bizarre entries too.**
* *The issue.* Lemma S, as imported from slack-imitation.md §3, applies only to "runs whose notebooks are not bizarre", and (B_D) there is stated only for non-bizarre y and y ∪ g. VSI has no bizarreness check.
* *What thread Q says.* Theorem Q4(c) says so explicitly: "needs (B_D) at committed mistakes, for all entries as in Proposition 4(c), since VSP has no bizarreness check". The note dropped the clause.
* *Fix.* Write "(B_D) at committed mistakes, bizarre entries included" in 5(c) and 5(e).

**A5. Theorem Q1 is misquoted: it does not hold "with any number of verifications".**
* *What the note says.* §4: "with any number of verifications, a protocol needs Ω(nK/log(nq)) task queries".
* *What Q1 says.* Its bound is (1 − 2/q)η − 4Q/(nm) − 4V/(qm), which is void once V ≳ ηqm/16. Thread Q itself adds: "unless it spends about q verifications per insight guessing the insight's content".
* *A counterexample to the quoted version.* With q + 1 verifications per problem, a protocol learns whether p has an insight and its value k_p. Since Q1 allows any output decoder, a decoder that writes k_p at step 0 then fails on no problem, with zero task queries.
* *The right reading.* The log is log(nq/ε), not log(nq). VSI uses only about m + K verifications, so Q1 does apply to VSI once q ≥ 32/η. With q polynomial in n, the log stays O(log(n/ε)).
* *Fix.* Write: "with fewer than about ηqm/16 verifications (q/16 per insight problem; VSI uses about one per problem), Ω(nK/log(nq/ε)) task queries".

**A6. Theorem 6(c) and the choice of β.**
* *In expectation only.* "The human verifies at most βT + R + K_V notebooks" holds only in expectation, since the number of audits is random. Thread Q has the same wording.
* *β needs T.* Setting β = K_V/(εT) needs T, or a bound on it, in advance; otherwise use a doubling schedule.
* *Fix.* Say "in expectation", and add the remark on T.

**A7. The sketch of Theorem J1 describes the wrong count.**
* *What the note says.* §4: "A query reveals it only inside a window of D+1 steps, so each query is a point query on about n/(D+1) candidate windows."
* *What the class is.* In thread J's class 𝒲, the insight must appear at the s = ⌈(σ+1)/(D+1)⌉ positions of a window W_t, spaced D+1 apart, with N = n − s(D+1) + 1 possible offsets. A query hits only if its length lies in W_{t_p}, so the effective number of candidates is N/s, which lies between about (1−ρ)Λ/4 and Λ.
* *Numbers.* For n = 64, σ = 32 and D = 0, N/s = 0.97 and Λ = 1.94, against n/(D+1) = 64 (`referee6_numbers.out` §5).
* *Fix.* Write: "each query position lies in at most s of the N windows, so it is a point query among about N/s ≈ Λ candidates".

---

## B. Overclaims and inconsistencies

**B1. "Correctness rests only on the verifier's soundness" is true for outputs, under (A4) alone. Several qualifiers are missing.**
* *What is right.* Theorem 5(a) uses only (A4). Determinism, (A2) and (A3) are not needed for the correctness of outputs, which is worth saying as a strength.
* *What is wrong.* Answer 2 says "No assumption about how the human reacts to the imitator's notebooks is used for correctness", and answer 3 says "every assumption about how humans react … affects only the cost". Both are false for V-human: (A4) for V-human *is* an assumption about how the human reacts to imitator notebooks, finished ones. It is also false for V-cone with a human referee (L2), and for the imitated verifier (A1).
* *Liveness.* (A2), (A3) and (L1) are needed for VSI to terminate on every problem (B7).
* *Read-out.* VSI "outputs the run". If a final notebook holds a correct solution and a later plausible wrong one, which slack invites (slack-imitation.md, Remark 3), the delivered answer must be the artifact V verified, not "the run".
* *Fix.* Say: "correctness of outputs uses only the soundness of the verifier actually applied". List what that means for each of the three verifiers, and output the verified artifact.

**B2. The case for imitating the verifier omits that V_H's verdicts encode problem-specific knowledge.**
* *The note's argument.* "A verifier judges the object it is shown, so learning it has horizon 1." That is true. But on a failed run, V_H's verdict is exactly the knowledge the imitator lacks: that something is missing. So V′ is blind where the imitator is.
* *An example.* In the hidden-insight class with each problem seen once, V′ accepts every failed run of an unlocated insight problem, since its posterior that the problem has an insight is η < ½.
  * Output failure ≤ ε then needs β ≥ 1 − ε/η: 80–95% of notebooks verified for η = 0.1–0.2 and ε = 1–2%. K_V/ε is 9–72 m, more than verifying all T = m (`referee6_numbers.out` §7).
  * Theorem 6 is not contradicted, because K_V ≥ m·h(η) grows with the number of distinct problems. But "about K_V/ε verifications, for any number of problems" saves nothing here.
* *Fix.* Say that imitation pays when verdicts are generic (a line-by-line proof check, a test suite), or when problems recur. For distinct research problems whose verification needs the insight, budget about one human verification per problem. Make the §6 table and Answers 1 and 6 consistent with this.

**B3. Quotations of the threads that overstate them.**
* *Location numbers* (§4).
  * The "matching lower bound" and the "iff" are Theorem J4, not J3.
  * They hold for *faithful* hiding classes (Definition 4: revealing, on-run, homogeneous), not for all hiding product classes.
  * Thread J also shows that outside hiding classes no converse holds (the "confession" state).
* *Theorem G3* (§4, Answer 5).
  * Thread G covers task queries and "any other human step whose answer depends on θ only through the units it processes". A verifier that knows k_p is not such a step.
  * In G3's instance, q = 2, so two verifications reveal the content. G3 therefore does not say that "every protocol" with a verifier pays this cost.
  * *Fix:* qualify it as "task queries and checks that depend only on the work processed", or combine it with Q1's argument at q ≥ 8.
* *Theorem G1's corollary* (§5).
  * The note says "gain at most (1−ρ)/(β + (D+1)/(σ+1))". The corollary is an *upper bound on failures*, so it gives a *guaranteed* gain of that size, the ratio of two upper bounds. It does not cap the actual gain.
  * Thread G's own "thread E's heuristic cap, now a theorem" invites the same misreading.
  * *Fix:* write "guaranteed gain (1−ρ)/(β + …)".
* *Trees* (§8).
  * "The factor b^d is necessary" rests on Theorem T4(b), which thread N marks "[P, by reduction …, written out only in outline]".
  * "Parents that name the subanswers they reject remove it" is Proposition T8, marked **[S, N]**, a sketch with numerical checks.
  * The status line, "full proofs are in the thread reports", is not true for these two.
  * "A verifier at every node … each found with a constant number of task queries" is in fact at most 1 + min{r, (D+1)r/(s+1)}. That is r without within-call (B_D), so independent of N, d and b, but not a constant.
  * Proposition T6's walk also needs *complete* node verifiers. With only sound ones, as stated there, a good child can fail its check and send the search into a call with no mistake.
* *Theorem J1.* The class has setback *at most* D on every notebook, not "exactly D". The online bound is for protocols with at most c queries per round, all made after the run.
* *Theorem F3.* The bound counts task queries *plus* single-entry checks (Q + C). It needs q ≥ 4n/n₀, and an output imitator that appends at most one entry per step. It is Ω(n₀K/…), so "about n per occurrence" (Answer 5) should read "n₀".
* *The deployment remark.* Theorem H1 is for SI-ABC with uniform queries (and the check), with (B_D) at confident mistakes.
  * Placed after Proposition 7, it reads as the deployment of Proposition 7, whose query mixture drops (B_D) for ripe and hedge failures. That extension is plausible by the same proof, with γ replaced by min{⅓, 1/(3d), c_r/(3n)}, but it is not in thread H.
  * Also add "with probability at least 1 − δ".
* *"Location comes from four places only"* (§4). This is not a theorem.
  * Thread Q's own table lists position, feature and trigger laws (concentration) as a further source.
  * Thread J's located probe, or "confession" state, is another, outside hiding classes.
  * *Fix:* say "the sources found in these threads".

**B4. The probability table.**
* *The column "worst-case task queries".* For the two no-verifier rows it shows O((D+1)K log K/(ρε)). That is not a worst case, since it assumes (B_D) and the rest. It also omits the 1/α of Theorem H1, O((K/α + K)·(D+1)·log(K/(αδ))/(ρε)), which applies to any scheme with asking. Rename the column to "guarantee" and add the 1/α.
* *V-machine, 85% for "theory and software".*
  * Lemma 1 and (A3) need the human's *own* chain to end with a machine-checkable artifact: a formal proof of the claimed theorem, or code that passes the suite.
  * Thread F (§9) gives 25% that a *fully formal* mathematical notebook keeps n₀ within 1.5×.
  * Either explain that only the final theorem needs formalizing, and at what cost, or split mathematics from software.
* *V-cone (70%) above V-human (65%).* The threads' soundness estimates point the other way: thread F gives 75% for the correctness of CSI-V outputs with a human referee in mathematics, and thread Q gives 85% for V-human's soundness. The ordering may still be right because of V-cone's cheaper location, but give the reason. Also, the 30% for empirical V-cone has no thread behind it; thread F has "–" there.
* *"Thread G (55–65% for (B-omit) with reviews)".* Thread G gives 65% *with* reviews and 55% *without*, for theory; for empirical work, 40% / 30%.

**B5. "VSI 'works' by this definition in the worst case, whatever the human" (§6) compares bounds, not efforts.**
* *Bounds, not costs.* 3n₀K against 20n₀K is a ratio of upper bounds. Chained imitation's actual cost on a given human can be far below n₀K/ε.
* *Effort left out.* "Works" counts all human effort, but 3n₀K omits:
  * verifications;
  * post-mortem reads (at most K/b_α);
  * audits.
* *What the effort count requires.* With an imitated verifier at ε = 5%, VSI stays under a fifth of 20n₀K only if c_V·K_V ≲ n₀K/20, where c_V is the cost of one verification in task steps. For n₀ = 20 and K_V = K, that means c_V ≤ 1 task step. And with B2, verification may cost about one per problem.
* *Fix.* Say "VSI's guarantee is below a fifth of chained imitation's guarantee", and state the condition on verification cost.

**B6. "Most weak-link failures end with *no* claimed solution" (§5) is unsupported, and in tension with thread E.**
* *Thread E §1.* By the reading of Proposition 2 there, slots that are certainly due get filled with the plurality guess at any confidence. A final result is due once the posterior believes the human would have finished, which happens near the end of a slack run.
* *The default makes it worse.* With the recommended default α = 1, no ask hands that slot to the human. So confident *default* answers ("the conjecture holds", "approach A works") may be common in exactly the recommended configuration, and they are what stresses (A4).
* *Selection.* Note.md §6.3 says that filtering keeps the ratio of verifier-fooling failures to correct runs unchanged, but *raises their share* among the failures that remain. Quote that alongside "no selection pressure".
* *Fix.* Soften "most", and note that asking at the final-answer slot (an α < 1 only there) is a cheap guard for V-human.

**B7. Liveness: VSI can loop forever on a problem.**
* *Why.* Lemma 1 guarantees a committed mistake only under (A2) and (A3). If τ(x₀) > n₀, or V rejects a correct notebook, a rejected run may have no committed mistake. Thread L §7 says heavy tails make the first case real. Then the uniform stream never hits, and the problem is rerun forever.
* *The (L1) drop case.* §5 relies on thread F's remark on drops ("the flagged step is the human's own, costs one query"). But §2.3's protocol, after an excused flag, does not go on to (ii), so the identical run is rerun.
* *Fix.* Add two rules:
  * Stop the search when the scan stream has exhausted the committed steps. That is a certificate that the run is the human's own chain, so either τ(x₀) > n or V is incomplete. Report the problem as unsolved within n, at most 3n task queries, rather than rerunning.
  * After an excused flag, continue with (ii).
* *Mention it in §11* as the cost of heavy-tailed research times.

**B8. The user's constraint.**
* *The letter is respected.* No on-track judgment is assumed.
  * Post-mortems are hints that are never added as data, and Lemma 3 makes them safe.
  * L is local and relative.
  * (L1) affects only cost and liveness.
* *V-human assumes a check of final states.* Note.md §5.4 and without-a-check.md's table treat that as a distinct, weaker assumption than an on-track check, not as none. The note should say so explicitly, and should not describe V-human as resting on "no assumption about how the human reacts to the imitator's notebooks" (B1).
* *The local check.* A human referee as L judges intermediate entries. It is not an on-track judgment, but it is a check whose soundness correctness relies on.

---

## C. Numbers

All the figures were rechecked with `referee6_numbers.py`. The ones not listed are correct.

**C1. EQ, fooled humans.** "28 → 37 → 36 with the H stream" is the **U+H** column. VSI's search is U+S+H, which gives **40 → 55 → 54**, still about 50× below U at n₀ = 128. Quote U+S+H, or say "U+H".

**C2. EQ, the cost of the extra streams.**
* *Bounded-setback humans:* the maximum U+S+H/U ratio is 1.45, at misled-8 with n₀ = 32, so "at most 1.5×" is right.
* *The adversarial list:* the maximum U+A/U is **1.64**, at misled-8 with n₀ = 8. "At most 1.6×" rounds it down; write 1.64.
* *The scan on silent humans:* 2.4–2.7× ✓.

**C3. E6.**
* "Slack imitation: about 200 at every n₀ for bounded-setback humans": misled-8 at n₀ = 8 costs **485**. Write "160–490 at n₀ = 8, then about 205".
* "Fooled humans: 1,600 → 4,300" is fine (1,631 → 2,811 → 4,296).
* "About 14 task queries" with a verifier holds for bounded-setback humans, except misled-8 at n₀ = 8, which costs 38.
* Chained imitation, 2,915 → 12,724 → 51,365: "51,300" should be 51,400 for noticing humans; 51,340 for misled ones.

**C4. "Asking multiplied the cost for bounded-setback humans by 6–23."** The exact range is 6.1–22.6, at **α = 0.3**. At α = 0.1 it is 11.6–61.9. Add "at α = 0.3".

**C5. F1.**
* *Correct:*
  * "about 260 → 1,200" (SI 295 → 693 → 1,224; SI-ABC 257 → 710 → 1,165);
  * the local check at 9–11 (9.4, 10.8, 9.7);
  * check-before-committing at 0;
  * the retry rule dividing by 2.9–3.1 (r = 2) and 3.8–4.3 (r = 3), so "3–4".
* *Wrong:* "trusted false negatives grow with n under every protocol". At α = 0.05, SI-ABC has 0 failures at every n, at 7–16 asks per problem (thread F's own table). Write "under every protocol at α = 0.3".
* *Precision:* type N (false negative, then a checkable fallback) is caught by CSI. Say "type W" or "followed by a valid weaker result".

**C6. G1.** "About 300 task queries at every size" is right: 310, 305 and 285, with last-review queries. MIX-REV costs 473–554.

**C7. Choice blindness, "69–92% of the time" (§5).** The 69% and 92% are shares of *participants who accepted at least one* of several manipulated answers, not per-record acceptance rates. Per item, at most 22% of manipulated political answers were detected. Thread L also reports 57–63% for symptom ratings. Write "69–92% of participants accepted at least one altered answer".

**C8. Smaller citation details.**
* Theorem Q1's log is log(nq/ε) (A5).
* Thread L's "design 3" is its "Study 3".
* "Synthesizes eleven research threads, listed in Section 10": §10 lists thirteen (A, B, C, D, E, F, G, H, J, L, N, Q and R).

**C9. Checked and correct.**
* EQ's silent humans: 1,610 → 6,450 → 26,091, and 663 → 2,497 → 9,734 with the scan.
* E6's silent humans: slack doubles the cost.
* §6's sources:
  * thread Q's 85 / 70 / 65 / 50%;
  * thread L's 35% for a gain of 5×;
  * thread F's 55–65% for (B^V_D) in mathematics and software;
  * thread E's 50%, which is its "≥ 5× with SI-ABC".
* Thread L's detection rates: 25–55% for desk checks and 60–96% for formal inspection.
* Thread L's figure of about 90% repeatability.
* Theorem H1's cost formula.
* Theorem 6's (1−β)K_V/β.
* Theorem 5(e)'s γ.

---

## D. Minor

1. **(L0).** Lemma 2 uses that L is a fixed function whose verdict on an entry never changes once it is written: thread F's (L0). Add it next to (L1).
2. **Ripe failures (Lemma 4).** Thread G's definition is stricter than the paraphrase. At some step k before the last review, the imitator wrote *exactly* P(x′_k) minus I, and I is absent from the final notebook. (R-rev)'s premise needs the first condition, and the proof needs the second. With asks, a ripe failure's last review is necessarily committed, which is worth one sentence.
3. **Hedges.** Define "the human's idea was available" as "the human, at the decision notebook, would write its idea A instead of the default". Lemma 4 is then definitional, which is fine; Proposition G7(d), on ideas triggered only by doing, is then excluded explicitly.
4. **Streams.**
   * Say that an exhausted or empty list stream is skipped, as Lemma Q2 does. With H empty the factor is then 2; the stated 3 is still valid.
   * Say that H skips asked steps; the positions j_H only shrink.
   * Note that the scan stream makes 3n₀ a sure bound, not only an expected one.
5. **Notation.** β is used for the audit probability in Theorem 5, for the verifier audit in Theorem 6, and for the never-recovered share in §5. Rename two of them.
6. **Content-triggered reviews.** "After every L_rev work steps" needs step boundaries. Thread F's design hides them from the human, and visible boundaries reveal the clock. Trigger by entries ("after every L_rev new work entries"), as thread E and slack-imitation.md §4 do.
7. **"A small constant" (Answer 2).** For labelled decisions the cost is 3(1 + d), so say "a constant times the number of decisions".
8. **Theorem 5(d)** counts task queries only. Add the at most K/b_α post-mortem reads and the verifications, since §6 counts all effort.
9. **Thread H's Proposition H2** (cited in §1). Its proof says that for an exchangeable learner "the cumulative log loss of a set of data does not depend on the order". That is false in general for learners whose predictions depend only on the set. The conclusion still holds, because the regret bound (L1) applies to the reordered sequence itself, whose predictions are those the imitator used. Worth a footnote, since the note relies on it.
10. **H2's scope.** H2 is stated for slack-imitation.md's results. That Theorems 5–6 and Proposition 7 inherit it is "by the same argument", not by H2 itself.
11. **The post-mortem's framing** ("a colleague's notebook"). The imitator writes in the human's style, so the human may recognize "its own" notebook, which undoes the framing. That is measurable in §9's study 2. Mention it.
12. **"At most K of them … on every path" (Answer 2).** It is K/b_α, almost surely, since searches end almost surely.
13. **Lemma 3** is stated without "frozen decoder" and the hit's value, which Lemma Q2 includes. Theorem 5(b) supplies the value, so this is only for completeness.
14. **Theorem Q1's verifications** are of arbitrary candidate final states, which is stronger than VSI's verifier. So the lower bound applies a fortiori, a point worth one clause.

---

## Answers to the specific questions

* **Theorem 5(b): is every hit worth b_α bits, including route (i) and the H list?** Yes.
  * Every hit is a committed step k at which the imitator's label differs from P(x′_k).
  * For route (i), this is by Lemma 2, under (L1) and (L0). For the H list and the other streams, the search stops only at such a step. For audits, by definition.
  * The decoder committed at k with top mass at least 1 − α under exactly D_t ∪ A_{<k}, because asks are added at once. So ξ(P(x′_k)) ≤ min{α, ½}.
  * List the round's data as A_{<k}, then the hit, then the rest. W depends only on the set, so the round's drop in Φ is at least b_α. Each round's drop telescopes into Φ ≤ K.
  * The ask count uses the natural order and the hit count the reordered one. They are two separate bounds, which is all 5(b) and 5(d) claim; no joint bound is claimed or needed.
  * In the toy run, the smallest hit value in each configuration was 1.00–1.47 times b_α, and none of the 800 route-(i) hits fell short.
* **Theorem 5(c): is the factor 3 right?** Yes. A list stream's j-th entry is queried by the 3j-th query, and the uniform stream's k-th draw by the 3k-th.
  * The scan's first mistake lies within the first n₀ committed steps, so every search ends within 3n₀ queries *surely*.
  * With H empty, the search is U and S only, and the bound is 2·min{n/|M|, n₀}.
  * With asked steps in H: if they are skipped, positions only shrink; if they are queried, they are counted in j_H. Either way the bound holds.
  * A ripe failure's last review, and a hedge's decision step, are always committed (D2), so the constants 3 and 3(1 + d) stand.
* **"The first mistake comes early" with asks.** Correct. Asked steps and correct committed steps both append P's label, so by induction x′_k = P^k(x₀) up to the first committed mistake. If there is none below n₀, the notebook at n₀ is P^{n₀}(x₀), which satisfies S by (T2).
* **Proposition 7's mixture.** The coefficients are right for each category: 1, ⅓, ⅓·(1/d_t) and ⅓·c_r/n. The proposition needs disjoint categories, (L2) and (L0), and a per-run d (A3).
* **Are (A1)–(A4) and (L1) exactly what the proofs use?**
  * (A1) is used for the bits, (A2) and (A3) for Lemma 1 and Lemma S, and (A4) for 5(a).
  * Missing: (L0) for Lemma 2; (B_D) at bizarre entries, for the Λ bounds; (L2) for V-cone's correctness and for Proposition 7.
  * Not needed: (A1)–(A3) are not needed for 5(a).
  * Stronger than needed: (A3), as stated (A2).
* **Is "correctness rests only on the verifier's soundness" true?** For outputs, yes, with (A4) alone. But "the verifier" must be the one actually applied. For V-human imitated, that adds Theorem 6's ε (A1, B2). For V-cone, it means (L2) and the correctness of R entries (A2). And liveness needs (A2), (A3) and (L1) (B7).
