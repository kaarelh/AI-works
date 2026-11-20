# Referee report: *Monitored imitation*

Version reviewed: `note.md` at commit `1915959e` (line numbers below refer to it), with `code/` and `results/` at the same commit. Background: `../ultranatural/note.md`, sections 1–2 and Proposition 4.

**What I re-ran or recomputed** (all in this folder):

* `referee_rerun/`: both experiments re-run in full from the unmodified code, and `make_figures.py` run on the re-run outputs. `hidden_insights_summary.json`, `property_rules_summary.json`, `property_rules.out` and `tables.md` are byte-identical to `results/`. All 18 table rows in `tables.md` appear verbatim in the note.
* `referee_e1_checks.py` → `.out`:
  * replays CS and MB in E1 from the seeds;
  * computes the class posterior exactly for small n and q;
  * compares E1 with Theorem 3's bound;
  * Monte Carlo check of Theorem 3's bound at η = 8ε, q = 2.
* `referee_e2_checks.py` → `.out`:
  * recomputes the novelty table independently, by a subcube method;
  * runs MB and CS with reruns, as Protocol MB is written;
  * tracks how many rules each MB query reveals;
  * runs CI with 40 humans per n.
* `referee_theory_checks.py` → `.out`:
  * checks the E[K] bound of Theorem 3;
  * finds the m needed by the "fixed humans" remark;
  * computes Theorem 7's query counts and the number of results the human actually inspects.

**Statements checked line by line and found correct** (possibly with minor remarks in (D)):

* Lemma 1:
  * the telescoping;
  * W(D_{T+1}) ≥ w(P);
  * the "≤ 1/2 at a mistake" step, which also holds for defective ξ (Remark 1.2);
  * pathwise validity for adaptive, randomized queries.
* Remark 1.1:
  * the greedy-decoding property, given an end-of-string symbol;
  * the sampler deviation bound 1 − u ≤ ln(1/u);
  * Proposition 2 for samplers. With ln(1/u) ≤ ln 2 · log₂(1/u) the factor is ln 2 < 1, as stated.
* Observation (first divergence).
* Proposition 2 (a) and (b). (a) holds for adaptive and adversarial problem sequences, provided the adversary picks x₀ᵗ before k_t is drawn. That is how the protocol is written.
* Theorem 3, all six steps:
  * the conditional law of (t_p, k_p) given the history: the likelihood is an indicator of consistency times protocol coins that do not depend on θ, and it factorizes over problems;
  * the per-probe hit bound (η/n)/(1 − η|S|/n) < 2η/n. I verified it exactly in `referee_e1_checks.out` §2;
  * uniformity of k_p given the transcript, on {t_p < n, p not hit};
  * the arithmetic down to Q ≥ n·E[K]/(32 ε log₂(en/(4ε))). It is checked numerically in `referee_theory_checks.out` §1.
* The "fixed humans" remark:
  * failure > 3ε for Q < nm/8;
  * removing a set of θ of prior mass ≤ ε leaves conditional mean failure ≥ 2ε;
  * the m it needs is computed in `referee_theory_checks.out` §2.
* Proposition 4. The bound is correct, but weaker than necessary; see D3.
* Lemma 5 and its proof. (M2) is used but not stated in the lemma; see D1.
* Theorem 6 (a)–(c).
* The Example in §5.2. Both (M1) and (M2) hold, in every case including t_p = ∞ and j = n.
* Theorem 7 (a)–(c):
  * the per-epoch bound (1−F)^{B m_i} ≤ e^{−εBm_i} ≤ δ/(i(i+1)), conditional on the history up to the start of the epoch;
  * the union bound over epochs, which sums to δ;
  * the batch-check count.
* Proposition 8 (CS). The first-divergence argument is correct, and the n·K(P) count is correct.
* Corollary 12. The descent is correct: by (T1) a failing leaf is a mistake; by (T2) a failing node whose children all pass has a mistaken combine call; otherwise halving finds a failing child. The count is d·(1 + ⌈log₂ b⌉), counting batch checks.
* Proposition 9: the case analysis and all three bullets.
* Proposition 11 as stated. Also the arithmetic a → a/(1−b). The conclusion drawn from it is wrong; see A1.

**Statements with errors or gaps:**

* Proposition 10's proof (A3).
* Remark 1.1's claim about Proposition 10 (A4).
* The "Consequence" and the "both directions" claim in §4.2 (A2).
* The selection argument of §6.3 (A1).

The experiments reproduce exactly, and every quoted number matches the saved outputs. The code departs from Protocol MB in one respect (C1), and this does not change any conclusion.

---

## (A) Errors in statements or proofs

### A1. §6.3, lines 348–350 (also Answers item 6, line 49; §7, lines 374–378): the contrast between MB and rejection sampling does not hold in the note's own model

**What the note says.** Rejection sampling "multiplies the output distribution by the monitor's verdict and favours exactly the deviations it cannot see", raising the silent share from a to a/(1−b), while MB "never selects".

**Why the contrast fails.**
* *Rejection sampling preserves the ratio that Proposition 11 is about.* With a binary verdict, conditioning on V = 1 multiplies the mass of *every* passing run by the same factor 1/(1−b). That includes correct runs and silent failures alike. So the ratio silent : correct stays at a : (1−a−b). This is the output-level analogue of Proposition 11's invariant: "never favoured relative to the human". The silent share rises only because visible failures are removed. The correct share rises by the same factor.
* *MB's learning does the same.* Suppose MB's queries refute exactly the hypotheses whose deviations are visible, which is what MB is designed to do. Then the posterior's silent share after learning is also a/(a + (1−a−b)) = a/(1−b).

  Toy example: hypotheses P, H_vis and H_sil, with prior weights w₀, w_v and w_s. MB's bisection query refutes H_vis. Afterwards the decoder follows H_sil iff w_s > w₀. That is exactly the majority decoder conditioned on the run passing.
* *What follows.* The a → a/(1−b) computation applies equally to both procedures. "Learning, not selection" (line 348) is a statement about mechanism. It is not shown to make any difference to the silent-failure rate of outputs.

**Real differences that could be argued instead.**
* MB's refutations persist and generalize across problems.
* MB can incidentally refute silent deviants that disagree with P at a flip state.
* Rejection sampling can condition on events of tiny posterior probability at no cost to the human.
* Selection by a *graded or manipulable* judgment (best-of-k on a score, persuasion) does favour silent failures. But that is outside the binary-V model.

**Suggested fix.** Either drop the a → a/(1−b) contrast, or present it as applying to both procedures and state which of the differences above is meant. "Persuasive states" (§7) belong to the graded or manipulable case and need a separate argument. Answers item 6 ("would favour exactly those") should be rephrased to match.

### A2. §4.2 "Consequence" (line 179) and Answers item 3 (line 26): "once the learner has paid for most of P", and the two-sided margin claim

**The quantifier "most" is wrong.** The bound is ξ_D(y|x) ≥ 2^{−sep(x;A|P) − K(y) − c − (K(P) − L(D))}. The deficit K(P) − L(D) enters additively in the exponent.
* "Most of P" — say 99% of K(P) — leaves a deficit of 0.01·K(P). With the talk's K(human) ~ 10¹⁶ bits, the bound is then vacuous for any s of interest.
* The correct condition is that K(P) − L(D) is O(s): the learner has paid all but O(s) bits of K(P). Whether that ever happens is itself unclear. L(D) < K(P) always, because patches of P on sets disjoint from A keep W(D) above w(P).

**The "both directions" sentence is mis-cited and gives no information at small s.** The sentence is "the margin at x equals sep(x; A | P) up to K(P) + c in both directions (ultranatural, Theorem 1)".
1. *Wrong citation.* In `../ultranatural/note.md` this is the remark after Theorem 1 ("The window is SOI's margin") and Proposition 4(1), not Theorem 1 itself.
2. *Wrong function.* There it is stated for f = the simplest total function consistent with D (the Kolmogorov prediction), with slack K(f) + c. With P in place of f, the slack is K(P) + c only once the simplest consistent function is P. In general it is about 2K(P) + c.
3. *No information at small s.* A two-sided equivalence "up to K(P) + c" says nothing about novelty of complexity s ≪ K(P). For s ≪ K(P), the converse "uncertain ⇒ novel at level ≈ s" is not established at all.

**Missed improvement.** The note's own Remark 1.2 says the slides use the mixture over all programs. For that mixture, `../ultranatural/note.md` Remark 1.1 gives the floor in relative form: W(D + (x,y)) ≥ 2^{−K(Q) − K(y) − c}·W(D). The patch map p ↦ "if x′ ∈ Q output y else run p" is injective on programs. Hence

  ξ_D(y|x) ≥ 2^{−sep(x;A) − K(y) − c}

with no deficit term at all. For W_tot one can at least replace K(P) − L(D) by K_tot(D) − L(D), by applying the floor with the simplest consistent f instead of P.

**Suggested fix.**
* Retitle §4.2 "a new simple property implies posterior doubt". The heading "In SOI the question's two signals are one" and Answers item 3 ("in Solomonoff induction they are one signal") claim an equivalence that is not proved.
* State the clean bound for the program mixture.
* For W_tot, state the condition as "K_tot(D) − L(D) = O(s)".
* Fix the citation, and drop or correct the "both directions" sentence.

### A3. Proposition 10 (lines 332–336): the proof does not handle a run that gets both an audit and a bisection query

**The ordering problem.** Lemma 1 counts a query as "landing on a mistake" only if the decoder *current at the time of the query* errs there. On a run that fails the check, MB+A makes two task queries: the bisection query and the audit. The protocol does not say which comes first.
* *Bisection answer added first.* The audit is then judged against the updated decoder, which may now be right at the audited step. So "the audits land on mistakes E Σ_t β·M_t/n times" is not justified for failed runs.
* *Audit added first.* The bisection step may no longer be a mistake of the current decoder. Then Theorem 6's count of ≤ K(P) visible failures breaks.

**Correct statement.** Restrict to *output* runs, i.e. runs that pass the check. These are the only runs that can carry silent deviations into the output. On them the audit is the only query, and the proof goes through verbatim: E Σ_{t output} M_t ≤ n·K(P)/β. Alternatively, audit before the update and then rerun the problem instead of bisecting the stale run. Or accept a factor 2: the pair of queries on one run teaches at least 1 bit if either query is at a mistake.

**Unstated assumptions.** The clause "failures the monitor can see are bounded by K(P) in total" needs (M1) and (M2), which Proposition 10 does not state.

### A4. Remark 1.1, line 75: "Propositions 2 and 10 … hold for samplers with an extra factor ln 2"

This is true for Proposition 2. For Proposition 10 it is true only of the audit bound: E Σ deviations ≤ n·ln2·K(P)/β, on output runs, after the fix in A3. It is false for the clause "failures the monitor can see are bounded by K(P) in total". The very next bullet of Remark 1.1 (line 76) explains why: with a sampler, a flip found by bisection can be a cheap low-probability draw.

**Suggested fix.** "Proposition 2 and the audit bound of Proposition 10 hold for samplers …".

---

## (B) Overclaims and unclear statements

### B1. Subtitle (line 3), Answers 4 (line 32), §8 (line 387): "about K·log(nK/εδ) quick checks", "logarithmic with batching"

Each batch check is one query in which the human inspects ⌈1/ε⌉ results. The number of results the human must actually look at is of order K·log(K/δ)/ε. Examples from `referee_theory_checks.out` §3:
* K = 1000, n = 1024, ε = 10⁻³, δ = 0.01: about 3.8·10⁴ queries, covering 2.7·10⁷ inspected results.
* K = 100, n = 64, ε = δ = 0.01: about 2.7·10³ queries, covering 2·10⁵ inspected results.

So the 1/ε has not left the human's workload. It has moved into the batch size. The subtitle does not mention batching at all.

**A hidden assumption.** Batch checks assume the human's verdict on a list is exactly the AND of its verdicts on the items: no misses when skimming 1/ε results. This should be stated as an explicit assumption next to (M1) and (M2).

**Also:** the subtitle, Answers item 4 and the table still write O(K(…)), while the body now has O((K+1)(…)).

### B2. Answers 2 (line 22) and §3 (line 134): "Chained imitation is optimal up to a logarithmic factor"

What is proved is a *minimax* statement: for each ε ≤ 1/16 and n, there is a class of humans, depending on ε (η = 8ε), with E[K] ≈ 8εm·log₂(en/(4ε)), on which every task-only protocol needs Q ≥ n·E[K]/(32 ε log₂(en/(4ε))) on average over the prior.
* The fixed-human version needs complexity up to 2E[K], gives failure 2ε rather than ε, and needs m of order ln(1/ε)/η (`referee_theory_checks.out` §2).
* Nothing is shown about CI's optimality on any particular human or natural class.
* The gap 32·log₂(en/(4ε)) is not shown to be necessary on either side.

E1 also shows that on this very class, a task-only protocol (the low-threshold uncertainty scan) uses 4× fewer task queries than CI at every n (`referee_e1_checks.out` §3).

**Suggested wording:** "in the worst case over humans of complexity K, chained imitation is within a factor O(log(n/ε)) of every task-only protocol".

### B3. Answers 3 heading and §4.2 heading: "in Solomonoff induction they are one signal"

See A2. Only "new simple property ⇒ doubt" is shown. It holds cleanly for the program mixture. For W_tot it holds only under a strong condition on the unpaid part of K(P).

### B4. Answers 5 table (lines 37–42)

The rows bound different things.
* *Different events.* Rows 1–2 bound the probability that the run *differs from the human's*. Rows 3–4 bound the probability that the final state *fails the human's check*. Rows 3–4 therefore say nothing about deviations the check cannot see; that is Proposition 10.
* *Different kinds of bound.* Rows 1–2 are bounds in expectation, with a random stopping time in row 1. Rows 3–4 hold with probability 1−δ.
* *What the subtitle claims.* "At most K task queries suffice" (line 3) likewise means: suffice to never output a run that fails the check.

**Suggested fix.** State in the table caption and the subtitle what "failure" means in each row.

### B5. Answers 6 (line 48) and Proposition 10 (line 334): "MB+A is never worse than chained imitation"

What is shown is that MB+A with β = 1 satisfies chained imitation's *upper bound* on output runs that deviate, which needs the A3 fix. It does not dominate CI run by run or human by human. The two protocols make different queries, and adding true data can flip a correct majority vote elsewhere.

**Suggested wording:** "has the same guarantee as chained imitation for deviations the monitor cannot see".

### B6. Answers 5 (line 44) and §7 (line 354): "no test computed from the imitator's beliefs can flag it"; "In E2 and in Theorem 3's class, every such signal is blind"

Both are false as stated.
* *Some mistakes are flagged by beliefs.* At a mistake, ξ(P(x)|x) ≤ 1/2, and when the doubt is high, uncertainty sampling flags the step. In E2, US(0.001) reached the target in 25 of 30 cases.
* *What is true.* No signal computed from beliefs can tell a confident mistake from a confident correct prediction. In Theorem 3's class it cannot tell the insight step from the other steps of the run.

**Suggested fix.** Say "cannot locate confident mistakes" or "is uninformative about *where* the mistakes are".

### B7. Experiments (§10; Answers 8): the monitor in both experiments is a perfect "is this state on the human's run" oracle

* *E1.* V(p, j, a) = 1 exactly when (p, j, a) is the human's j-th state on p.
* *E2.* V = 1 exactly when the notes equal the human's notes after j steps. For a real human this check costs as much as redoing j steps of work. That contradicts the framing that "a check … is usually much quicker than a step of work" (line 63).

So the experiments show the bookkeeping of MB under the strongest possible monitor. They are not evidence that cheap, weak monitors (§7, "nothing bizarre") would do the same. That is fine for a demonstration, but §10 and Answers item 8 should say so.

### B8. Answers 4, "Many bits per query … typically many" (line 33), and §5.2 "Bits per task query" (line 235)

"Typically many" is not shown. Part of the large per-query information is the checks' information, credited to the task query, because the posterior ignores the check answers. In E1, bisection locates t_p with log₂ n checks, and the following task query is then charged about log₂(nq/η) bits.

"If mistakes typically carry b bits, there are at most K(P)/b task queries" needs "every mistake carries at least b bits".

### B9. Answers 7 (line 52) and §7 (line 361): "That monitor already covers the talk's second desideratum (no bizarre behaviour …)"

MB checks only *final* states. (M2) constrains the human, not the imitator. So an output run can pass through bizarre intermediate states that the decoder later repairs: G may map a state with V = 0 to one with V = 1. If intermediate behaviour matters, for example a run that acts in the world, the guarantee does not cover it.

**Easy fix.** Define success as "every state of the run passes" and use prefix batch checks ("do states 0..j all pass?"). The prefix property is monotone in j. Bisection then costs the same ⌈log₂ n⌉ batch checks, and Lemma 5 still applies at the first failing state.

### B10. Answers 3, third bullet (line 27): "the new-property rule at sizes 3 and 6 usually stops before learning the rarer rules: it reached the target in 0 and 16 of 30 cases"

16 of 30 is more than half, so "usually" is false for s = 6. The same phrase appears in §10 (line 446) as "16 of 30 *humans*". There are only 10 distinct humans: `World(seed=100+s)` draws the same permutation and rules for every n. So it should read "16 of 30 cases".

### B11. §4.1, line 163: "That is the cheating protocol, with n task queries per insight"

The scan costs (t_p+1) per problem with an insight, which averages (n+1)/2. It also costs n per insight-free problem met, because the threshold keeps firing as S grows. In E1 this comes to about 1.5n task queries per insight found, for example 1,173/48.6 ≈ 24 at n = 16. This is a minor imprecision.

### B12. §6.1, line 328: "A monitor that wrongly flags good states adds to Drop and costs only queries"

It also produces "marked" failing outputs (Proposition 9, first bullet). A false flag on a start state violates (M1), which Proposition 9 assumes.

Proposition 9 covers only *systematic* failures of (M2). Inconsistent or noisy verdicts (V differing between two asks about the same state) break bisection differently. They are not covered and are not mentioned. An implicit assumption throughout §5 is that V is a fixed function of the state.

### B13. §5.2 Example (lines 237–250): "MB learns this class with one task query per insight it meets"

This holds for a learner using the class prior; verified exactly in `referee_e1_checks.out` §2. For a Solomonoff learner, only the general bound of at most K(P_θ) task queries is guaranteed. Say which prior is meant.

### B14. Answers 1 and Proposition 2(b) (line 103): "n·K(P)/ε task queries give run failure ε"

This holds in expectation and with a uniformly random stopping time, which the answers omit. It also requires K(P) to be known in order to set N.

---

## (C) Experiment and code issues; number checks

### C0. Numbers

Every number quoted in the note matches the saved outputs, and the saved outputs reproduce exactly (`referee_rerun/`). Checked:
* the E1 and E2 tables;
* Answers 3, 8 and §4.1–4.2: 0 and 16 of 30; 1 of 30; 25 of 30; 95%/82%/20%; 322–663 vs 313–951; 95% and 16% at n = 64; 4,970/18,100/77,000/316,000; about 48; 500 to 820; about 15; about 110.

The novelty table was recomputed by an independent method: a content has a new property of size s iff, for some set T of 12−s bits, no queried content agrees with it outside T. The two computations agree in every cell (`referee_e2_checks.out` §1).

### C1. MB and CS in both experiments do not rerun the problem after the task query, contrary to Protocol MB step 3 (line 220)

After the task query the code moves on to a fresh problem. It counts one final check per problem plus ⌈log₂ n⌉ per failure. Under Theorem 6's accounting, each failure costs one more check: the rerun's final check.
* **E1.** The check counts would be 554 / 645 / 770 / 864, instead of the 506 / 595 / 721 / 817 in the table and the "500 to 820" in Answers 8 (`referee_e1_checks.out` §1). The note's sentence "one per run … plus ⌈log₂ n⌉ per insight" describes the code, not the protocol.
* **E2.** With reruns, MB needs 13.6 / 14.5 / 14.4 task queries and 127 / 117 / 113 checks, against the code's 13.6 / 14.9 / 14.9 and 116 / 112 / 114 (`referee_e2_checks.out` §2).
* **Conclusion.** Nothing changes qualitatively.

**Suggested fix.** Either implement the rerun, or say that the experiments use the variant "one bisection per problem" and count checks accordingly.

### C2. CS as literally described re-asks states already in D

Protocol CS says to "task-query the run's states in order x′₀, x′₁, …". On reruns this re-scans from x′₀ and asks again at states whose answers are already in D. With reruns at n = 64:
* scanning literally costs 324 task queries;
* skipping states already in D costs 187;
* the table reports 186 (`referee_e2_checks.out` §2).

The E1 code does skip such states, through `excluded`. The protocol text should say "skipping states whose answer is already in D".

### C3. E1 against simple expectations (`referee_e1_checks.out` §1)

All of the following hold:
* *MB task queries.* In every one of the 40 runs, MB's task queries equal (number of problems with an insight) − 2. The stopping rule is "at most 2 of 100 unfound".
* *CS task queries.* CS's task queries equal Σ(t_p + 1) over the problems found, exactly: 8.8 / 32.6 / 128.8 / 523.9 per insight, against (n+1)/2 = 8.5 / 32.5 / 128.5 / 512.5.
* *MB checks.* MB's checks equal runs + found·log₂ n exactly.
* *CI.* CI's mean is close to the coupon-collector estimate mn(H₅₀ − H₂) ≈ 3.0·mn.
* *Against Theorem 3.* With q → ∞, the theorem requires Q ≥ 0.48·nm for failure ≤ 2%. CI is at 5.9–6.5× this bound, and the low-threshold uncertainty scan at 1.5×.
* *Exact posterior.* The class posterior was computed exactly for n ≤ 8 and q ≤ 3. It confirms the per-step formula, and that the majority label is always "no insight". So `failure = n_unfound/m` is the exact failure of the majority decoder.
* *Monte Carlo.* At η = 8ε, q = 2, a scanning protocol stays at or above Theorem 3's bound in all 8 settings (§3).

### C4. E2 table caption (line 431)

The caption says entries are task queries and checks "until the decoder's failure probability is at most 2%". For humans that did not reach the target, the code averages the values at the cap. This affects US(0.01), US(0.001), NOV(3) and NOV(6), so those means mix two different quantities. Say so in the caption, or report the reaching humans separately.

### C5. "Fewer than the 18 rules because one query can settle several" (line 444)

At n = 16 and 64 this is confirmed. All 18 rules are learned, and on average 2.2 of MB's queries reveal two or more new rules each.

At n = 4 there is a second reason: on average only 16.7 rules are learned. The size-9 rules fire on about 0.8% of runs each, so the target can be met without them (`referee_e2_checks.out` §3).

### C6. "The chained-imitation numbers are not monotone in n … noisy" (line 448)

Confirmed. With 40 humans the CI means are 370 / 810 / 843 (standard errors 29 / 67 / 90): monotone, and nearly flat between n = 16 and 64 (`referee_e2_checks.out` §4). Consider using more humans for CI, which is cheap.

### C7. `make_figures.novelty_curve` computes "an unsettled property of size *exactly* s", while the table says "size ≤ s"

The two are equivalent, so the numbers are right. An unsettled property of size r < s at c extends to an unsettled one of size s by adding literals that agree with c. The code comment should say so.

### C8. Smaller code points

* `hidden_insights.py`'s `K_bits_expected` omits η·log₂ q. q is "large" and never modelled. The quantity is not quoted in the note, but it is not K(P_θ).
* `property_rules.png`, right panel: Q = 0 is plotted at x = 1 on a log axis without saying so.
* E1 uses η = 1/2 and a 2% target, outside Theorem 3's η = 8ε regime. The note does not claim otherwise. Adding the 0.48·nm lower bound to the E1 table would make the comparison with Theorem 3 concrete.

---

## (D) Minor issues

* **D1.** Lemma 5 uses (M2) in its proof but does not list it as a hypothesis. Add "Assume (M2)". Also note that (M1) and (M2) are sufficient, not exactly necessary:
  * (M2) is used only at imitator-reachable states with V = 1;
  * (a) of Theorem 6 holds by construction whenever MB terminates;
  * (M2) is what makes MB terminate. Without it, MB can loop forever on a Drop state, which is why Proposition 9 changes the protocol.
* **D2.** Lemma 1: D₀ must be labelled by P (implicit in §1's definition of a data set). The count of mistake queries is at most ⌊log₂(W(D₀)/w(P))⌋.
* **D3.** Proposition 4: the min{1, ·} is unnecessary.
  * If P(x) ≠ G_D(x), then ξ(P(x)|x) ≤ ξ(G_D(x)|x) ≤ 1 − γ.
  * So every such query contributes at least log₂(1/(1−γ)) in both cases, and the count is at most K(P)/log₂(1/(1−γ)).
  * This also makes the "10% top mass gives at least log₂ 10 bits" remark (line 158) follow directly.
* **D4.** Line 158: "a sampler would deviate there with probability about γ": "less than γ".
* **D5.** Remark 1.1, greedy decoding:
  * The ≤ 1/2 argument needs an explicit end-of-string symbol.
  * Greedy decoding need not terminate. If the stop mass at each prefix is always smaller than the continuation mass (e.g. weights ∝ 1/k² on outputs 0^k), the greedy output is infinite and is not a state.
  * Add a length bound or a termination rule.
* **D6.** §3, Complexity: "K(P_θ) ≤ −log₂ prior(θ) + O(log mnq)" should also include K(η).
* **D7.** Theorem 3 holds with Q = the *expected* number of task queries, by the same per-query argument and summation. That matches Proposition 2(b)'s random stopping time, so the comparison becomes like for like.
* **D8.** Proposition 2(a): say explicitly that x₀ᵗ is fixed before k_t is drawn, so the adversary may see the past but not the current coin.
* **D9.** Corollary 12: the d·(1 + ⌈log₂ b⌉) checks include batch checks of up to b pairs. With single checks only, a level can cost up to b checks. Theorem 6 counts single checks, so say "batch checks" in the corollary.
* **D10.** §9 item 3 (line 395): "Θ(K/ε) checks before freezing (Theorem 7)". No lower bound is proved, and with B = 1 Theorem 7 gives O(K·log(K/δ)/ε). Use O(·) and keep the log.
* **D11.** Line 32: "fails on fewer than an ε fraction of all future problems" should read "fails on a fresh problem with probability less than ε".
* **D12.** §4.2 line 192: "With s = 6 it ends at 16% on average, reaching the target for 4 of 10 humans" refers to n = 64. Say so.
* **D13.** Answers 5, last sentence (line 44): "one task query per insight, against n·K/ε without it" compares a per-insight count with a total. Also, the lower bound is n·K/(ε log(n/ε)), not n·K/ε.
* **D14.** §7 (M2) discussion: (M2) is quantified over *all* states, including imitator-produced ones. The most plausible way the "nothing bizarre" monitor can violate it: the human, given a fine-looking but subtly corrupted state, discovers the corruption and abandons or flags the work. "An abandoned task" is in that monitor's list of off-track states. Proposition 9 covers this, but §7's "about as safe as assumptions about a careful researcher get" should mention it.
* **D15.** New text in §4.1 (lines 166–169), "maximizing uncertainty … picks inputs far from anything the human has seen, where the posterior is most diffuse". This is a heuristic and is consistent with the floor of §4.2: inputs with low sep(x; A) carry doubt of at least 2^{−sep}. Label it as a heuristic.

---

## Summary of the most important points

1. **§6.3 (A1).** The argument that rejection sampling "favours" monitor-silent deviations while MB does not fails in the note's own model. Both preserve the silent : correct ratio, and MB's learning produces the same a → a/(1−b) renormalization.
2. **§4.2 (A2, B3).**
   * "Once the learner has paid for most of P" should be "all but O(s) bits of K(P)".
   * The two-sided margin sentence is mis-cited and stated for P instead of the simplest consistent function.
   * "The two signals are one" is only one direction.
   * For the slides' program mixture, ultranatural's Remark 1.1 gives a clean bound with no deficit term, which the note should use.
3. **Proposition 10 (A3, A4).** The proof ignores the interaction between the audit and the bisection query on the same failed run. It is correct for output runs. The sampler claim in Remark 1.1 holds only for the audit bound.
4. **Headline claims (B1, B2, B4, B5).**
   * "Quick checks" are batch checks of ⌈1/ε⌉ results each.
   * "Optimal up to a log factor" is a minimax statement over an ε-dependent hard class.
   * The table and subtitle compare "differs from the human" with "fails the check".
   * "Never worse than chained imitation" means "has the same upper bound".
5. **Experiments (C1, B7).** They reproduce exactly and all numbers match. But MB and CS do not rerun the problem as Protocol MB says, so check counts are about 50 too low in E1. And the monitors are perfect "on the human's run" oracles, which is the best case for MB, not the cheap monitors the note argues for.
