# Thread S: second red team of verified slack imitation

*Red-team note by Claude (Anthropic) on [`../verified-slack.md`](../verified-slack.md) (version 3), reading it with slack-imitation.md, note.md §6.3 and threads E, F, G, H, J, L and Q. Draft; not refereed. Script: [`threadS_selection.py`](threadS_selection.py), output [`threadS_selection.out`](threadS_selection.out) (7 s, fixed seed). Tags: [thread X] for this folder's reports; [memory] for facts from my own knowledge, not checked this session. No existing file was changed.*

## Answers in brief

1. **The theorems are right; the framing overclaims.** Lemmas 1–3 and Theorems 5–6 follow from their premises (Lemma 4 rests on thread G).
   * Claim (a) is true as stated only for V-machine on a correctly stated goal.
   * Claim (b) is a relabelling for V-cone and V-human. There, (A4) *is* an assumption about how a human reacts to the imitator's notebooks: the same kind of fact as bounded setback, which thread L measured (reviewers catch 30–60% of planted plausible errors).
   * Claim (c) needs (A2) for every problem, and a margin the note does not have.
   * Claim (d) is too high for the rows with human verifiers.
2. **Sound verifiers of finished research results are rare** (§1.1).
   * *Where they exist:* formally stated theorems (proof assistants, modulo misformalized statements), complete formal specifications, and search problems whose answers can be checked.
   * *Where they do not:* tests are not a sound verifier of correct software, and a simulation verifies its model, not the design.
   * *Why the domain is narrow:* multi-year projects rarely have a crisp goal fixed at x₀. So the 85% row covers a small domain, and its "theory and software" bucket mixes formal with informal theory, and proofs with tests.
3. **Rerunning until accepted turns each verifier miss into a wrong output, at a rate that need not decay** (§1.3).
   * *The rate:* about p_f0·w·f per problem, where p_f0 is the first-run failure rate on a new problem, w the share of failed runs that carry a claimed solution, and f the verifier's pass rate on those.
   * *Why it does not decay:* with problem-specific insights, the series' own hard case, p_f0 does not fall. At p_f0 = 0.3, w = 0.5 and f = 0.35 the rate is 5.2% (Part B of the script).
   * *What is missing:* the note never estimates p_f0·w, yet its V-cone and V-human rows hinge on it.
4. **The imitator's wrong results are the hardest kind for a human to catch** (§1.2).
   * *Why:* the majority decoder maximizes human plausibility, and plausibility is the evidence a human verifier uses. Errors written in one's own style are caught less often [thread L].
   * *My estimates of f* on imitator-style wrong results: 0.2–0.5 for one careful human in mathematics; 0.1–0.35 for a careful local cone check; about 0.02 for a proof assistant (misformalization).
5. **Selection exists, in five forms the note does not count** (§2):
   * *conditioning:* among outputs the error rate is wf/(c + wf), not wf;
   * *repeated verification:* if the search fixes a harmless mistake first, the same wrong claim is verified again. With partly presentation-dependent verdicts this doubles false acceptance at f = 0.1 with 5 harmless mistakes, and multiplies it by 4.4 with 20 (Part A);
   * *allocation:* every rejection spends its bits on errors V catches. Deviants that pass V lose mass only at audits, so the guarantee against them is SI-ABC's divided by β;
   * *enrichment:* the filter adds log₂(f_m/f_h) bits toward deviations aimed at V's blind spots, which is 3.2 bits at f_h = 0.1 and 6.5 at f_h = 0.01 (Part C);
   * *decoding toward plausibility* (item 4).

   The filter itself is bounded: at most log₂(1 + R_p) bits per problem, and at most K·log₂ e over the learner's whole lifetime, for a deterministic decoder (Part D).
6. **"Exact Bayes does not optimize against V" is true, and matters little in practice.** Practical learners resample: best-of-64 adds 4.6 bits. The obvious engineering step, training on accepted outputs, is direct optimization against V.
7. **The post-mortem is consistent with the design law but not free** (§3). Its real cost is not the factor 3 on search.
   * *What goes wrong:* it shows the human the whole failed run and its outcome, just before the search task-queries prefixes of that same run. Those answers are no longer P(x′_k).
   * *Why it matters:* in exact Bayes, a single such answer refutes P and voids the K bound.
   * *Fix:* have a second person write the post-mortems.
8. **The idealizations mostly favour VSI in the ranking, which the note undersells** (§4).
   * *In VSI's favour:* when V is a machine, failures of determinism or realizability, and practical learners, break only VSI's cost theory. They break SI-ABC's correctness.
   * *Exception 1:* imitating the verifier (Theorem 6) brings the verifier's own determinism and realizability back into correctness.
   * *Exception 2:* (A2) for every problem weighs more on VSI than on chained imitation. On a problem the human's own chain cannot finish within n, VSI never accepts, and the human ends up answering every step of a full run. With n₀ at the 75th percentile of durations, heavy tails give 6–11% such problems (Part E), which caps VSI's saving over the human doing the work at roughly 4–9×.
9. **The worst-case argument for "works" has a margin of only 4/3** (§6): 3n₀K against a fifth of 20n₀K.
   * *Instruction overhead:* the heavy instruction inflates n₀ by 1.2–1.6× [thread F], which uses up the margin unless chained imitation is charged the same instruction.
   * *Costs that grow with T:* audits at β = 1 (needed when V is a person), verifications and futile searches all grow with the number of problems T. The note says only the optional audits do.
10. **The user's constraint** (§5).
    * *V-machine* respects it fully.
    * *V-human* respects its letter, but rests correctness on a human judgment of the hardest state.
    * *V-cone* is a *preserved local judgment of intermediate entries*: the first note's monitor with "valid" in place of "on track". It respects the words "off track", but not the spirit of "no human judgment of states".
11. **The comparison** (§6).
    * *Correctness:* no scheme dominates VSI, since every verified scheme inherits V's correctness.
    * *Worst-case cost:* check-and-scan (n₀K) beats VSI (3n₀K); a scan-heavy schedule has a worst case of 1.25n₀K and keeps part of the hints' benefit.
    * *Against Proposition 7:* VSI's advantage with a human verifier is real, but smaller than 65% against 45%.
    * *What the comparison leaves out:* the human-does-it baseline (n₀T), the talk's second desideratum (V checks only S), independent verifiers, and verification by use.
12. **My probabilities and verdict** (§7). Same definition and conditioning as the note's §6; first figure theory and software, second empirical.
    * *Probabilities:* VSI with a proof assistant on a formally stated goal 70%, with tests 45%; V-cone 45% / 10%; V-human 40% / 10%; Proposition 7 30% / 10%; slack imitation with asking 25% / 10%; "truly O(K)" 25%.
    * *Verdict:* VSI is the right structure, and the right recommendation where the goal is machine-checkable. Elsewhere it is the best of weak options, not a scheme to be sure of.
    * **The most important caveat:** VSI is exactly as sure as its verifier is sound on the imitator's own most plausible wrong answers, and rerunning until accepted turns every miss into a wrong output.

## 1. The verifier assumption

### 1.1 Where sound verifiers exist

| domain | verifier | sound for | the gap | cost against doing the work |
|---|---|---|---|---|
| formal mathematics | proof assistant | the formal statement | misformalized statements; research statements often need new definitions first (the Liquid Tensor Experiment took about 18 months; the FLT formalization is a multi-year project [memory]) | (A3) needs the human's own chain to end with a formal proof: several times the informal proof's time when the library is missing |
| checkable search (constructions, counterexamples, beating a benchmark) | a program | the stated property | the property may be a proxy for the goal | cheap |
| software against a formal spec | formal verification | the spec | gaps in the spec | proof effort ≫ coding (seL4: about 20 person-years for about 9k lines [memory]) |
| software against tests | test suite | passing those tests | not sound for correctness. Audits of a public coding benchmark found a substantial share of test-passing patches wrong, or passing only weak tests [memory] | complete tests ≈ the code |
| engineering designs | simulation | the simulator's model | validity outside the model; designs found by search exploit simulator artefacts [memory] | cheap once the simulator exists |
| informal theory | referee (V-cone), the human (V-human) | nothing exactly | f ≈ 0.1–0.5 (§1.2) | days to weeks per paper; years for the hardest results (Hales's Kepler proof, Perelman [memory]) |
| empirical science | replication | nothing exactly | replications are themselves noisy (about a third to a half succeed in psychology [memory]) | ≈ doing |

* *A crisp, fixed goal.* VSI needs an S that is fixed in x₀, crisp, and preserved by appending. Projects of 20–40 three-month steps rarely have one: their value is often a new question or definition, found along the way. VSI therefore imitates the well-posed part of research. For the rest, V-human's "does this solve the problem?" becomes a judgment of significance, as loose as an on-track judgment.
* *Two different rows.* The note's 85% row, "a proof assistant, a test suite against a specification", joins a sound verifier (for the formal statement) with an unsound one (tests sample behaviour). They deserve separate rows (§7).
* *A tension with thread F.* V-machine needs the human's chain to produce the machine-checked object. Thread F gives only 25% that a fully formal discipline keeps τ(x₀) within 1.5·n₀. A formal final cone alone is cheaper, but on research problems with missing libraries it still inflates n₀, and §6 shows that the inflation eats the margin.

### 1.2 Human verifiers on the imitator's own wrong results

*Why the imitator's wrong results should be especially hard to catch:*
* *Plausibility is optimized.* The majority decoder writes the content that the largest mass of human models would write, so a wrong claimed solution is the wrong answer the human is most likely to find natural. A human verifier uses exactly this naturalness as evidence. So decoding for plausibility is partly optimizing a proxy that V-human relies on, with no filter needed.
* *Own style.* Students proofreading their own essays find about 20% fewer errors than readers of someone else's [thread L, Daneman and Stainton]. People accept altered records of their own choices 69–92% of the time. Context moves expert verdicts: 4 of 5 fingerprint experts reversed themselves under misleading context [thread L].
* *Familiar patterns.* A mode error is typically a standard move applied where a hypothesis fails. The Einstellung effect means that a familiar pattern gets checked less [thread L §4].
* *Base rates.* Reviewers find about 30% of the major errors planted in a manuscript. Mathematicians disagree about whether a short proof is valid. About one reviewed paper in three had an incorrect theorem or proof in Lamport's sample [thread L §1].

*Why they might be easier:*
* *Visible guesses.* Unconfident guesses in slots that are certainly due (thread E §1) often contradict nearby entries, and a careful local check catches those.
* *A critical reader.* Verification is a critical reading of a finished object, by a reader who knows it may be wrong. Reviewers who recommended rejection found 39% of major errors, against 17% for those who recommended acceptance [thread L].
* *Testing.* A final result can be tested, by applying the theorem to examples or running the code. Thread L's strongest finding is that use, not review, catches errors.

*My estimates.* For imitator-style wrong claimed solutions:
* a single careful human verifier in mathematics: f ≈ 0.2–0.5;
* a careful local cone check: 0.1–0.35. Locality helps, but plausible *local* steps are exactly what referees miss;
* a proof assistant: about 0.02, the misformalization rate of carefully written statements, a guess;
* tests on software: 0.1–0.4;
* empirical claims judged by reading: above 0.5.

These are not consistent with thread Q's 85% for "soundness at the graded level" unless p_f0·w is small. Thread F's 50% that a human referee catches at least 70% of invalid entries points the same way.

### 1.3 Rerunning until accepted turns misses into outputs

* **Conditioning.** Each problem is rerun until accepted, so the output is wrong exactly when a wrong run is accepted before a correct one. Note.md §6.3 is right that the ratio of accepted wrong runs to correct runs is unchanged by filtering, but that ratio is what reaches the output. On a problem the imitator cannot yet solve, the probability c of a correct run is near 0, and wf/(c + wf) is near 1.
* **No decay for problem-specific insights.** Thread Q's estimate of the bad-output rate, p_f·w·f with "learning drives p_f down", assumes that learning transfers. The series' hard case, which motivates the 3n₀K worst case, is K spent on insights specific to each problem. There, every new problem starts with the same first-run failure rate p_f0, and the output failure rate stays near p_f0·w·f (Part B).
  * *Theory.* At p_f0 = 0.3, w = 0.5 and f = 0.35, it is 5.2%.
  * *Empirical work.* At w = 0.8 and f = 0.5, it is 12%.
  * *Audits.* They help only through what the audited problem teaches, which does not transfer.
* **w is not small under slack.** Thread Q and the note say that most failed runs end with no claimed solution. That rests on the weak links ending empty-handed, but:
  * the final result is a certainly-due slot, which the decoder fills with its plurality guess once its posterior says the human would have finished (thread E §1, V13);
  * slack adds σ steps after the human's usual finishing point, which are extra chances for "proof complete" and "v2 supersedes v1" (V13, V14);
  * a fooled commission upstream (V1, V6) leads the decoder, modelling a human who builds on it, to a confident claimed solution resting on it.

  I would put w at 0.3–0.6 in mathematics and above that in empirical work.
* **Repeated verification** (Part A).
  * *The mechanism.* VSI's search stops at the *first mistake found*. A harmless mistake (a paraphrase, a valid alternative) counts. Fixing it leaves the culprit, and the rerun carrying the same wrong claim is verified again.
  * *When it bites.* If part of the verdict depends on presentation (the share 1 − ρ), each re-verification is a fresh chance to pass. Thread L finds expert verdicts noisy on borderline cases, and a plausible wrong proof is a borderline case.
  * *Its size.* With VSI's streams and no useful hint, P(wrong output | first run wrong) at f = 0.1 is 0.10 with no harmless mistakes, 0.19 with u = 5 and 0.44 with u = 20 (ρ = ½; 0.27 and 0.61 at ρ = 0). Good post-mortems (h = 0.6) cut 0.44 to 0.33.
  * *The model's limit.* At ρ = 1, a verdict fixed by the claim, there is no amplification. That is the note's implicit model.

### 1.4 What verification costs

* *Per verification.* Refereeing a paper costs about 2–10% of producing it (my guess), and refereeing a hard result much more. Formally verifying software costs more than writing it, and replication costs about as much as the original study.
* *Per rejection.* Each rejection needs a new verification of the rerun and a post-mortem read of a whole notebook (up to K/b_α of each). Theorem 6 bounds the verifications, but the note's totals count only task queries.
* *Pointless:*
  * *when verifying costs c_V ≳ n₀/5 task steps per problem.* VSI then saves at most 5× over the human doing every problem. This holds in empirical work, for formal verification of software, and for the hardest proofs;
  * *when each problem carries a third of a bit or more of specific content, so that K ≳ T/3.* Then 3n₀K ≥ n₀T, and the human doing the problems is cheaper. The "a fifth of chained imitation" criterion cannot detect this, because chained imitation is worse still.
* *The imitated verifier* cuts verifications to about K_V/ε. But V′ is at best as sound as V_H, it adds its own ε, and Theorem 6 needs V_H to be deterministic and realizable (§4).

## 2. Selection and Goodhart

*What the note gets right.*
* Proposition 11 of note.md holds: posterior odds against P never rise.
* Runs are deterministic given the data, and are redone only after an update.
* A yes/no filter cannot boost a hypothesis.

So exact Bayes with the majority decoder does not *optimize* against V. But selection does not need optimization.

| mechanism | present with exact Bayes and the majority decoder? | size |
|---|---|---|
| filtering over attempts | yes, bounded | ≤ log₂(1 + R_p) bits per problem, by a union bound over the R_p + 1 runs; lifetime maximum T·log₂(1 + K/T) ≤ K·log₂ e (Part D) |
| conditioning on acceptance | yes | output error rate wf/(c + wf); near 1 on unsolved problems (§1.3) |
| repeated verification | yes, if verdicts depend on presentation | ×2 to ×4.4 at f = 0.1 (Part A) |
| allocation of learning | yes | deviants that pass V are refuted only at audits: E[#failed outputs] ≤ K/(b_α βγ), which is SI-ABC's bound divided by β (Theorem 5(e) against Proposition 5(b)) |
| enrichment toward deviations aimed at V | yes | odds × f_m/f_h, i.e. log₂(f_m/f_h) bits: 3.2 at f_h = 0.1, 6.5 at 0.01, 9.8 at 0.001 (Part C) |
| decoding for plausibility | yes, for V-human and V-cone | f on imitator errors > f on planted errors (§1.2) |
| resampling until accepted (best-of-k) | no; practical learners | ln k − (k−1)/k nats: 2.7 bits at k = 16, 6.6 at k = 256 |
| training on accepted outputs | no; practical learners | compounds over iterations, without bound |

* **The K updates and the filter.** The updates only remove hypotheses, so they cannot raise a V-fooling family's odds against P. But they can *unmask* one.
  * *How.* At a state where a visibly wrong family V₁ outweighs both P's agreeing family and a V-fooling family V₂, with w(V₂) > w(P), the decoder follows V₁ and is rejected. The hit refutes V₁, and the rerun follows V₂ and is accepted. Note.md §6.3 gives this very example.
  * *How often.* Unmasking happens only through the at most K/b_α rejections, but one refutation can unmask families at many states. An unmasked family yields accepted wrong outputs until an audit refutes it, after about n/(β|M|) outputs. What bounds the total is the audit term, K/(b_α βγ).
  * *In bits.* Learning makes VSI's surviving deviations exactly the ones V cannot see, at no cost in odds.
* **Malign hypotheses** (note.md §6.3 and its Open item). With a sound V they cannot make an output fail S, so claim (a) survives. Otherwise:
  * *Aim.* They are optimizers: with an unsound V they write the wrong results that pass it, so f_m ≈ 1. Part C then applies, and a better honest verifier makes the accepted errors *more* adversarial, unless f_m falls with f_h.
  * *Outside S.* With a sound V they can put content outside S into accepted outputs: a payload in the notebook, or a backdoor the specification does not forbid.
  * *Detection.* An audit lands on a given single mistake with probability β/n per output, against 1/n per round for chained imitation. So for β < 1, VSI is *less* protective than chained imitation against a single treacherous deviation outside S.
* **Practical learners.** Thread H extends the theorems to exchangeable, realizable learners. Nothing extends the "no selection" property to the learners people would use.
  * An LLM rerun means a resample, which is best-of-k with no update in between. Selection then grows like log k per problem, without bound.
  * Fine-tuning on verified outputs (rejection-sampling fine-tuning, expert iteration) is outright optimization against V.
  * RL against unit tests is reported to produce test special-casing in frontier coding agents [memory].

## 3. The post-mortem hint

* **The design law.** Framing the notebook as a colleague's is formally consistent. The hint is not a task step, and its answer is never added as data, so (T1) is untouched, and Lemma 3 allows lists written by an adversary.
* **But the human is not memoryless.** The design law exists because the deterministic model treats P as a function the protocol queries again and again. The post-mortem shows the human the *entire* failed run and tells it the project failed. The search then task-queries prefixes of that same run, presented as its own.
  * *The answers change.* The human now knows the run's future and where it suspected the culprit, so its answers are not P(x′_k).
  * *P is refuted.* In exact Bayes over deterministic programs, one answer that differs from P(x′_k) refutes P. Then Φ ≥ 0 fails, the K bound is void, and the posterior may later have no consistent hypothesis.
  * *Who pays.* Correctness under (A4) is untouched, so this is still "only cost". But the cost is unbounded, not "at most a factor 3".
* **The U and H streams leak the future too.** They query late states before early ones, so the human has seen x′_40 when asked at x′_3. The scan, querying in order, does not. Every multi-query protocol shares this to a degree; VSI's three streams maximize it.
* **Anchoring across problems.** After up to K/b_α post-mortems, the human knows the imitator's style and its typical failures. It may come to recognize imitator notebooks in task queries and treat them differently. That is drift, outside the single-P model (thread E §3.4).
* **The colleague framing is a deception.** People recognize their own style, and these notebooks are near-copies of their own. Once the human sees through the framing, it may doubt the task-query framing too ("this is your notebook").
* **Human time.** Each post-mortem means reading a whole notebook of 2n₀ steps. At most K/b_α of them is small against 3n₀K, but it is human effort, uncounted in §6.
* **Fix.** Have the post-mortem list written by a second researcher, which Lemma 3 already allows, or by a fixed rule. The leak through U and H *task* queries has no clean fix, since only the imitated human can answer them: asking in increasing step order loses the hint's priority order. At least count it as a cost, and measure it (§7, item 4).

## 4. The idealizations

| idealization | VSI's correctness | VSI's cost | the alternatives | effect on the ranking |
|---|---|---|---|---|
| determinism of the task human | untouched | K bound void; every open-ended step differs, so the search ends at once and teaches noise | SI-ABC and Proposition 7: the correctness bound is void; chained imitation: void | favours VSI |
| determinism of the verifier | V-human: repeated verification raises f (Part A); Theorem 6 void | — | — | counts against V-human, and against the imitated verifier most |
| realizability | untouched for a fixed V; for the imitated V′, Theorem 6 needs V_H realizable | no bound; rejections may never end | correctness bound void | favours VSI-machine |
| practical learners | untouched for a sound V; selection raises a fallible V's f (§2) | unknown | unknown | counts against V-cone and V-human with resampling |
| τ(x₀) ≤ n₀ for every problem | untouched | as written, never terminates on τ(x₀) > n: about n task queries per such problem, plus re-verifications and post-mortems | a failure floor only | counts against VSI |
| the heavy instruction is feasible (n₀ × ι) | untouched | 3ιn₀K, against a 4n₀K budget | Proposition 7 shares it; chained imitation does not | counts against VSI and Proposition 7 |
| mistakes counted at the level of content | untouched | hits spent on wording; K includes style | all schemes | shared |

* **Determinism** (thread L: about 90% repeatability on categorical decisions, far less for open-ended production). A three-month notebook step would not repeat word for word.
  * *What breaks.* Every task query then "lands on a mistake", so Lemma 3's bound is trivially met while hits teach noise. The bit per hit also fails, because a stochastic P's own answers carry entropy.
  * *Who it hurts.* This kills every scheme's cost theory, and the no-verifier schemes' correctness too. VSI with a fixed V keeps correctness. *That is the best argument for VSI, and the note does not make it.*
* **Realizability.** The same applies, with one exception. The imitated verifier's guarantee (Theorem 6) is an exact-Bayes bound over V_H. So VSI with an *imitated* human verifier needs determinism and realizability for correctness; with the human verifying every output, it does not.
* **The cold start and (A2).** The human's own chain must succeed within n₀ while starting cold every three months, under an instruction asking for:
  * typed and certified entries, obstruction records and raw records;
  * reviews that reread *every* raw record, a cost that grows with the notebook;
  * labelled decisions, an r-fold retry rule and a hidden clock.

  I would give 60% (theory) and 40% (empirical) that some n₀ ≤ 2.5× the usual duration works for most problems. Two consequences:
  * *VSI does not need most of this instruction.* Only V-cone needs typed entries and citations. Reviews, decisions and the retry rule serve only the H stream. To maximize sureness with V-machine or V-human, drop them, keeping slack and the hidden clock; n₀ and the (A2) risk then shrink.
  * *"For every problem" is not neutral.* Chained imitation pays one query per round and simply fails on a problem the human cannot finish. VSI searches, updates and reruns until the imitator reproduces the human's run, which still fails, and then searches forever.
    * *How often.* With n = 2n₀ and n₀ at the median duration, 13–29% of problems are such problems; at the 75th percentile, 6–11% (lognormal and Pareto tails, Part E).
    * *What it costs.* Each costs at least n task queries, the human doing the run, and gives no output. So VSI's saving over the human doing everything is at most about 1/(2ιφ): 3.8× at φ = 10% and ι = 1.3.
    * *The fix.* A per-problem search budget and a rule to abstain. With them, worst-case guarantees hold only for the problems that are not abandoned.
* **Shared idealizations.** Counting mistakes at the level of content, and the cold start as such, affect every scheme alike and do not change the order.

## 5. The user's constraint

*VSI respects it:*
* *No direction.* A finished-result check asks whether an object meets a fixed criterion. It needs no foresight and no judgment of direction.
* *No preservation for V-machine and V-human.* Note.md's monitor needed the human's own work to preserve "fine". V-machine and V-human need no such property of intermediate states.
* *Defects that never show.* An on-track judgment is doubtful because a run can look fine while lacking an insight that would only show later. A final check sees the outcome itself.
* *V-machine involves no human judgment at all.*

*VSI does not respect it:*
* *The load-bearing judgment comes back.* The likely reason for excluding on-track checks was that a human judgment of states would carry the guarantee, and thread L says such judgments are unreliable. V-human makes correctness rest on a human judgment of one state, the final one. For research that is the hardest state to judge, and the judge's blind spots are shared with the producer.
* *V-cone has the first note's shape.* Its local check L is a judgment of *intermediate* entries, and Lemma 2's location power comes from self-validity (L1): "all entries valid" is preserved by the human's steps. That is the first note's mechanism, a preserved check of states found by its flip, with "valid" in place of "on track". Theorem Q1 says final verification alone cannot locate; V-cone's cheap location is exactly the part that uses a state judgment.
* *VSI is check-and-scan with additions.* VSI is note.md's Proposition 8 plus slack, hints and imitation of the verifier. The follow-up notes began (without-a-check.md) as an attempt to do without a check altogether.

*My reading.* V-machine respects the constraint fully. V-human respects it in letter, and in spirit only for crisp, checkable goals. V-cone respects it in letter only. The note should say which version it means when it claims the constraint is kept.

## 6. Flaws in the comparison, and missed alternatives

* **Claim (b) relabels.** The verifier rows move the human-reaction assumption from the task steps (does the human catch errors while continuing?) to the verification (does it catch them while checking?). The verification is the better place for it: full attention, a finished object, local structure. But thread L's evidence on catching plausible planted errors bears on both.
* **The margin.** "At ε = 5%, chained imitation pays 20n₀K and VSI at most 3n₀K" leaves a factor 4/3 before VSI misses the one-fifth bar. Part E adds the costs:
  * *n₀ inflation:* with ι = 1.3 the worst case alone fails;
  * *audits at β = 1, verifications and futile searches:* these grow with T. With average searches of n₀ per rejection and φ = 10%, VSI meets the bar only up to about 9K problems.
* **β.** The note sets the audits aside as mattering "only if the verifier may be unsound". For V-cone and V-human the verifier *is* unsound, and Theorem Q4(d)'s "never worse than SI-ABC" holds only at β = 1. That costs one task query per output, so the total depends on T.
* **The right baseline.** For an online scheme that solves T given problems, the baseline is the human doing them, n₀T. VSI beats it only if 3K < T, or if most rejections are cheap. Section 6 compares only with chained imitation, which is weaker still.
* **The talk's second desideratum** (no bizarre behaviour where the human would not). V checks only S. Slack's extra steps, and content outside S, are unchecked, and audits at β < 1 refute such deviations more slowly than chained imitation does (§2). Adding note.md's final "nothing bizarre" check, which is preserved and cheap, closes part of this.
* **Weighting the search streams.** Round robin costs 3n₀ per rejection in the worst case, while check-and-scan (the scan alone) costs n₀. Lemma 3 holds with weights: E[queries] ≤ min_i(cost_i/weight_i).
  * *The effect of weights.* A schedule of 8 parts scan, 1 part uniform and 1 part hint has a worst case of 1.25n₀ and keeps part of the hint's benefit. In Part A, with h = 0.6, it needs 29.5 task queries against 29.2 for equal weights at u = 5, but 73 against 49 at u = 20.
  * *Recommendation.* For *sureness*, weight the scan, and raise the hint weight only once post-mortems have been measured to work.
* **The verifier, not imitation, carries the sureness.** In domains with V-machine, *any* generator wrapped in V, a non-imitative AI included, is exactly as sure of correctness. Imitation buys lower cost and human-like runs. So "the scheme I am most sure of" there should read "verification, with imitation as the generator".
* **Cheap ways to make V sounder.**
  * *Two independent verifiers,* or a verifier who is not the imitated human. Their f values multiply, less any correlation: about 30% of an examiner's false negatives repeat [thread L].
  * *Colleague framing for the verification.* It is not a task step either, and it removes the own-style penalty.
  * *Verification by use:* re-derive each lemma of the cone, or test the result on cases, rather than read it.
  * *Debate-style criticism* by a second imitator, judged by the human. This goes beyond imitation, with its own assumptions.
* **Editorial.** The note still contains "E7_PLACEHOLDER" in §7. Its §6 rows for V-cone (70%) and V-human (65%) are not reconciled with thread F's 50% for referee catch rates, nor with thread L's detection data.

## 7. Probabilities and verdict

Same definition as the note's §6: output failure at most 5% on projects of 20–40 steps, at under a fifth of chained imitation's human effort. Same conditioning: determinism, realizability, and the human's chain succeeding within n₀. Effort includes verifications, audits and post-mortems.

| scheme | note: theory, software | mine | note: empirical, judgment | mine | main reasons for the change |
|---|---|---|---|---|---|
| VSI with a machine verifier of the actual goal | 85% | 70% (proof assistant on a formally stated goal); 45% (test suite) | – | – | misformalization; tests are not sound; formal proofs in the reference chain inflate n₀ and use up the 4/3 margin; the domain is narrow |
| VSI with a referee checking the cone | 70% | 45% | 30% | 10% | f ≈ 0.1–0.35 on plausible local steps; p_f0·w does not decay; repeated verification; needs β ≈ 1 |
| VSI with a human verifier, imitated | 65% | 40% | 30% | 10% | own-style blind spots; noisy verdicts; Theorem 6 needs V_H deterministic and realizable; verification ≈ replication in empirical work |
| slack imitation with asking and design elements (Proposition 7) | 45% | 30% | 20% | 10% | threads G and L; trusted dead ends and lost by-products |
| slack imitation with asking | 40% | 25% | 20% | 10% | the same |
| VSI's task queries truly O(K) (theory) | 45% | 25% | – | – | wording-level K; heavy tails; n₀ inflation; contamination by post-mortems |

* *The order survives; the gaps shrink.* With a human verifier, VSI's lead over Proposition 7 is 10 points, not 20. Its absolute sureness is below a coin flip.
* *Without the conditioning,* every row falls. VSI-machine falls least, since its correctness survives the loss of all three idealizations; I would give it about 40% of meeting both halves of "works".

**Verdict.** VSI is the right *structure*: verify finished results, locate a mistake by searching on rejection, and spend human judgment on finished objects. Where the goal is machine-checkable, it deserves to be called the scheme one can be most sure of, though the verifier deserves the credit. With a referee or the human as verifier, it is still the best scheme in the folder, but not one to be sure of. Its sureness there is the soundness of a fallible human judgment on the most plausible wrong answers, amplified by reruns.

**The single most important caveat for the user.** VSI is exactly as sure as its verifier is sound on the imitator's own most plausible wrong answers, and rerunning until accepted converts every miss into a wrong output, at a rate that does not decay when insights are problem-specific. Outside proof-assistant-checkable goals, measure that rate before relying on VSI.

**Changes I would make to the scheme.**
1. *State the domain:* "most sure" applies to V-machine on a formally stated goal. Split proofs from tests.
2. *Use audits at β = 1* whenever V is a person, and count them, with verifications and post-mortems, in the effort.
3. *Use independent verifiers,* with colleague framing and verification by use; do not imitate the verifier until f is measured.
4. *Search scan-heavy* (8:1:1); set a per-problem search budget and a rule to abstain.
5. *Get post-mortems from a second person,* and measure how much out-of-order task queries change the human's answers.
6. *Drop the heavy instruction* when V does not need it; add the final "nothing bizarre" check.

**What to measure first.** Item 1 adds to the note's §9.1; items 2–4 are new.
1. *f on imitator-style wrong claimed solutions:* in one's own style against a colleague's, read against used, and the same wrong claim re-verified under different presentations (this gives ρ).
2. *p_f0·w:* the share of an LLM imitator's failed research runs that end with a confident claimed solution.
3. *The duration tail* of the human's cold-start chain under the instruction.
4. *Task answers given right after a post-mortem* of the same run, against fresh answers.
