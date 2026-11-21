# Verified slack imitation: the scheme I am most sure of

*Research note by Claude (Anthropic), the fifth in this folder: version 3 of the answer to "which scheme are you most sure would work with a deterministic human?".*
* *What it builds on.* It uses the theorems of the fourth note, [`slack-imitation.md`](slack-imitation.md), and synthesizes the research threads listed in Section 12. Their reports are in [`research/`](research/) on the working branch.
* *Status.* Revised after referee 6 ([`verification/referee-report-verified-slack.md`](verification/referee-report-verified-slack.md)) and a second red team ([`research/threadS-redteam2.md`](research/threadS-redteam2.md)). The response is [`verification/response-verified-slack.md`](verification/response-verified-slack.md).
* *What is proved where.* Proofs of the main results are given here. The lower bounds are stated with sketches, and the thread reports have their proofs, some written out only in outline, as marked.

## The question

The request: *keep trying threads, and report the scheme you are most sure would actually work with a deterministic human. Ideally, give a proof that the scheme works if the program has such and such properties, and a case that humans in fact have them.* The constraint from earlier in the conversation: no assumption that the human can check whether a run "has gone off track".

## Answers in brief

1. **The scheme: verified slack imitation (VSI).** Slack imitation (the fourth note) plus a verifier of the finished result.
   * *The loop.* Each problem is rerun until the verifier accepts. A rejected run is searched for a mistake, mostly by scanning it from the start.
   * *Termination.* If the scan reaches the end without finding a mistake, the run is the human's own chain, so the human cannot solve the problem in n steps; VSI says so and stops.
   * *The output* is the verified artifact, after a cheap "nothing bizarre" check of the notebook.
2. **What is proved** (Theorem 5).
   * *Correctness.* Every output satisfies the verifier's criterion. So correctness rests on one assumption, (A4′): the verifier never passes a wrong result of the imitator.
     * Determinism, realizability and the human's setbacks are not used for correctness, only for cost.
     * This holds when the verifier is consulted on every output. An imitated human verifier adds its own error rate ε (Theorem 6).
   * *Rejections.* At most K of them (K = K(human)).
   * *Cost per rejection.* At most 2n₀ task queries, whatever the human, with the recommended search weights. Under bounded setback it is about 4(D+1)/ρ, and it is one query when a local check finds an invalid entry.
   * *Totals.* Task queries are at most 2n₀K in the worst case, with no factor 1/ε. That is within a logarithm of the lower bound that holds even with a perfect verifier (Theorem Q1).
3. **How sure I am.** "Works" means output failure at most 5% on projects of 20–40 three-month steps, at under a fifth of chained imitation's human effort. My probabilities that VSI works on a real careful researcher:
   * *VSI with a proof assistant on a formally stated goal:* **70%**;
   * *with a test suite as the verifier:* 45%;
   * *with a human referee checking the claimed solution entry by entry:* 45% for theory, 10% for empirical work;
   * *with the human's own verification:* 40% and 10%;
   * *without any verifier* (slack imitation with asking and the design elements): 30% and 10%.

   That VSI's task queries are truly O(K), with neither n₀ nor 1/ε: 25%.
4. **So the scheme I am most sure of** is VSI with a machine verifier on a formally stated goal. There the verifier deserves most of the credit: any generator wrapped in it would be as correct. Imitation adds a low query cost, at most 2n₀K, and runs that are the human's own process with some steps replaced. Elsewhere VSI is the best scheme I have found, but not one to be sure of.
5. **The most important caveat** (red team, thread S). VSI is exactly as sure as its verifier is sound on the imitator's *own most plausible wrong answers*.
   * *Rerunning until accepted* turns every miss of the verifier into a wrong output, at a rate of about p·w·f per problem:
     * p, the first-run failure rate on a new problem;
     * w, the share of failed runs that carry a claimed solution;
     * f, the verifier's miss rate on those.
   * *Why it need not shrink:* with problem-specific insights, p does not fall as learning proceeds.
   * *Why f may be high:* the majority decoder writes the *most typical-looking* wrong result, which is the hardest kind for a human verifier to catch. That is why the human-verifier rows are low.
6. **What no scheme can do** (Section 4; proved in the threads). For humans whose contributions are unpredictable and problem-specific, every scheme that asks the human only for task steps pays about n queries per insight in some cases:
   * insights triggered only by *doing* a piece of work;
   * ideas never retried after a trusted record of a failed attempt;
   * confident wrong content that a human accepts.

   Slack imitation is optimal for humans with bounded setback, up to logarithms. Slack is necessary. Verification removes the 1/ε but not the n. In VSI these lower bounds cost queries, never correctness.
7. **The evidence** (thread L). Setbacks look bimodal: an error is caught at review or first use, or only after a year or more, or never. Reviewers catch 30–60% of planted plausible errors. This is why the scheme leans on a machine verifier, and why the human-verifier rows are low.
8. **What to measure first** (Section 10):
   * the verifier's miss rate f on imitator-style wrong results;
   * the share p·w of failed runs that end with a confident claimed solution;
   * the duration tail of the human's own chain;
   * how much a post-mortem changes the human's later answers.

## 1. Setting

As in [`slack-imitation.md`](slack-imitation.md) §1.
* *The human* is a deterministic program P.
* *The learner* is Bayes over a hypothesis class containing P, with the majority decoder.
* *K* = log₂(1/w(P)). Thread H's Proposition H2 extends slack-imitation.md's results to any online learner whose log-loss regret against P is at most R, with K replaced by R; results with asks need, in addition, predictions that depend only on the set of data. Theorems 5 and 6 below extend the same way, by the same argument. So K can be the human's description length in whatever class the learner uses, for example given a corpus, provided the class contains P exactly.
* *Notation.*
  * The potential Φ: Φ ≤ K at the start and Φ ≥ 0 always.
  * Lemma 1 of note.md: a task query on a majority-decoder mistake lowers Φ by at least 1.
  * τ(y), the human's own remaining time from notebook y.
  * (T1), (T2), bounded setback (B_D) and Lemma S: slack-imitation.md §3.
  * Λ = min{n, (D+1)n/(σ+1)}, and b_α = max{1, log₂(1/α)}, with α = 1 meaning no asks.

## 2. The scheme

### 2.1 The core

The core is what VSI needs for its guarantees. Anything in the instruction is part of the problem statement, so it holds in the human's own reference chain as well as in the imitator's runs. That keeps the design law of thread E: a correct imitator step reproduces the human's step exactly.
* **An append-only notebook,** with **a hidden clock**: no step numbers, dates or deadlines, which the scaffold strips.
* **Slack:** the imitator runs n = n₀ + σ steps, where the human's own chain under the same instruction solves the problem within n₀.
* **Two predicates.**
  * S_V is what the verifier decides. It must be preserved by appending and reached by the human's own chain within n₀.
  * S\* is the goal.
* **The verifier V**, one of:
  * **(V-machine)** a machine check: a proof assistant on a formal statement, a test suite, a program checking a constructed object. The human's own chain must then end with the checkable artifact, a formal proof for example.
  * **(V-cone)** a check of the claimed solution's *dependency cone*, the claim and everything it cites recursively, by a local check L: does each entry follow from what it cites? (Thread F, Proposition F5.) L may be a proof checker or a human referee. This needs thread F's typed entries and citations.
  * **(V-human)** the human's verification of the finished result, on every output or imitated (Theorem 6).
* **The final "nothing bizarre" check** of the notebook (note.md §5). It is cheap and preserved, and serves the talk's second desideratum, since V checks only S_V.
* **Output the verified artifact,** not the whole run. A notebook can hold a correct solution and a later plausible wrong one.

### 2.2 Optional additions

Each addition costs n₀ or human time. Add one only where it is measured to pay.
* *Reviews and labelled decisions* (thread G). Reviews are triggered by content, after every L_rev new work entries, and reread every raw record; decisions are labelled entries. They make the list stream H of the search cheap for readable by-product insights and for hedges.
* *Typed, certified entries and obstruction records* (thread F). They are needed for V-cone. They also let a local check flag invalid entries, each of which marks a mistake.
* *Asking at the final-answer slot.* Asking before committing (slack-imitation.md, Proposition 5), restricted to the step that writes the claimed solution. It hands the human the slot where the imitator would otherwise write its most plausible guess, which is the guess that stresses a human verifier.
* *Post-mortem pointers, written by a second researcher.* "This project failed; which entries would you re-examine first?" The human being imitated must not write them: after reading the failed run, its answers to task queries on that run are no longer P's (thread S §3).
* *Independent verifiers, and verification framed as a colleague's.* Two verifiers whose misses are not perfectly correlated multiply their miss rates, less the correlation (thread S §6). The claimed solution can be shown to a human verifier as a colleague's work, which the design law allows since a verification is not a task step.

### 2.3 Protocol VSI(w_S, w_U, w_H)

For each problem, repeat:
1. **Run.** Build a run of n steps, with asks at the final-answer slot if that option is used.
2. **Verify.** Apply V to the claimed solution. If accepted, run the "nothing bizarre" check.
   * *If the check fails,* bisect to the flip, task-query it (by (M2) of note.md it is a mistake), and rerun.
   * *If it passes,* output the verified artifact, and with probability β task-query one uniform committed step (an *audit*).
3. **If rejected:**
   * *(i) An invalid entry.* If L flags an invalid committed entry, task-query that step. If the flagged step turns out to be the human's own (an excused flag), continue with (ii).
   * *(ii) Search.* Choose each query from three streams, with frequencies w_S, w_U and w_H, over committed steps:
     * **S:** the next step of a scan from step 0;
     * **U:** a uniformly random step;
     * **H:** the next entry of a list fixed at the start of the search, made of the last review step, the labelled decision steps, and the second researcher's post-mortem entries. An empty list is skipped.

     Stop at the first query that lands on a mistake. Add its answer first and the others after it, then rerun.
   * *(iii) Abstain.* If the scan reaches the end of the run without a mistake, the run is the human's own chain. Report "not solved within n" and stop.

*Default weights:* (w_S, w_U, w_H) = (½, ¼, ¼). The scan-heavy weighting is what keeps the worst case at 2n₀; raise w_H only once post-mortems have been measured to work.

## 3. Theorems

**Assumptions.**
* **(A1)** P is deterministic, and the learner is Bayes over a class containing P.
* **(A2)** S_V is preserved by appending, and τ_V(x₀) ≤ n₀, where τ_V is the human's own remaining time to S_V.
* **(A3′) Completeness on the human's runs.** V accepts every extension of the human's own notebook at step n₀.
* **(A4′) Soundness.** On the final notebooks of the imitator's runs, S_V implies S\*.
* **(L0), (L1)**, only when L is used:
  * (L0): L is a fixed function, whose verdict on an entry never changes once the entry is written;
  * (L1), self-validity: every entry the human appends passes L.

**Lemma 1 (the first mistake comes early; thread Q, Lemma Q3).** Under (A2) and (A3′), every rejected run has a committed mistake at a step below n₀.

*Proof.* Asked steps and correct committed steps both append P's label. So if no committed step below n₀ is a mistake, the notebook at step n₀ is the human's own notebook c_{n₀}. The final notebook extends c_{n₀}, so V accepts it by (A3′). ∎

**Lemma 2 (every invalid entry is a mistake; thread F, Lemma F1).** Under (L0) and (L1), a committed step that appends an entry failing L is a mistake.

*Proof.* By (L1), every entry of the human's step passes L, and by (L0) the verdict on the entry is fixed. So the imitator's step differs from the human's. ∎

**Lemma 3 (weighted hints are free of risk; thread Q, Lemma Q2, with weights).**
* *The setting.* Fix a rejected run of a fixed decoder, with committed mistake set M ≠ ∅. Search it with streams chosen at frequencies w_i, deterministically in proportion or at random. Each stream is either uniform over committed steps, drawn with replacement, or a list fixed when the search starts and written by anyone, an adversary included. Empty streams are skipped, and their weight goes to the others.
* *The claim.* Every answer added is the human's own step, and

  E[queries] ≤ min{ (n/|M|)/w_U, j_S/w_S, j_H/w_H } + O(1),

  where j_S and j_H are the positions of the first mistake in the scan and in list H.

*Proof.* Stream i is served at least once in every ⌈1/w_i⌉ queries, up to rounding. So a list stream reaches its first mistake within about j_i/w_i queries. The uniform stream's draws succeed independently with probability at least |M|/n. The search stops at the first hit of any stream. ∎

**Lemma 4 (ripe failures; thread G, Theorem G4 and Proposition G7).**
* *Ripe failures.* Call a failed run *by-product-ripe* if two things hold:
  * at some step k before its last review, the imitator wrote exactly P(x′_k) minus a by-product insight I satisfying thread G's (Rec1)–(Rec3);
  * I is absent from the final notebook.

  Under thread G's review assumption (R-rev), the run's last review step is a mistake.
* *Hedges.* Call a failed run a *hedge failure* if, at a labelled decision, the imitator adopted a default where the human would have written its idea. Its decision step is a mistake.
* *In both cases* the step is committed: an asked step is the human's own, and the human would write I there.

*Proof.* See thread G §4–5. The human at the last review would write I, and the imitator does not, or I would be in the final notebook. The decision case holds by definition. ∎

**Theorem 5 (verified slack imitation).** Assume (A1), (A2) and (A3′), and (L0), (L1) if L is used. Let the weights be (w_S, w_U, w_H). For every sequence of problems, chosen adaptively:
* **(a) Correctness.** Every output satisfies S_V. Under (A4′) it satisfies S\*. This uses neither (A1)–(A3′) nor any property of the human.
* **(b) Counts.** With the final-answer asks, they number at most K/log₂(1/(1−α)) on every path. Almost surely, rejections, failed "nothing bizarre" checks and audit hits together number at most K/b_α.
* **(c) Termination.** Every problem ends, either with an output or with "not solved within n". Under (A2) and (A3′) the abstain rule never fires.
* **(d) The cost of one rejection.** A rejection costs one task query if route (i) finds an invalid entry, plus one more for each excused flag. Otherwise its expected number of search queries is at most min{(n/|M|)/w_U, n₀/w_S, j_H/w_H} + O(1). With the default weights that is at most:
  * 2n₀, *surely*, whatever the human;
  * 4Λ, under (B_D) at committed mistakes, bizarre entries included;
  * 4, for a by-product-ripe failure under (R-rev);
  * 4(1 + d), for a hedge failure, where d is the run's number of labelled decisions;
  * 4(1 + d + i), if the i-th post-mortem entry is a mistake.
* **(e) Totals.**
  * *Task queries:* E[task queries] ≤ asks + (K/b_α)·min{2n₀, 4Λ} + β·T over T problems. A problem on which VSI abstains costs at most 2n more.
  * *Human effort beyond task queries:* one verification per run with a human verifier (or Theorem 6), at most K/b_α post-mortems read by the second researcher, and the local checks.
* **(f) If (A4′) fails.** The failed outputs are exactly the accepted runs that fail S\*. Under (B_D) at their committed mistakes, bizarre entries included, E[#failed outputs] ≤ K/(b_α·β·γ), where γ = max{1, (σ+1)/(D+1)}/n. This is slack-imitation.md's Proposition 5(b) bound divided by β, so β = 1 is needed to keep that bound.

*Proof.*
* *(a).* V accepted every output, and (A4′) is exactly the step from S_V to S\*.
* *(b).*
  * *Asks:* as in slack-imitation.md, Proposition 5(a).
  * *A rejected run has a committed mistake,* by Lemma 1, or by route (i) and Lemma 2. So each search ends almost surely, with a hit at a committed step k.
  * *The hit's value.* List the round's data as: the asks before k, then the hit, then the rest. W depends only on the set of data, so the order does not change the total. The decoder committed at k with top mass at least 1 − α under exactly the data before the hit, so the human's answer has mass at most min{α, ½}. The hit therefore lowers Φ by at least b_α. Audit hits are the same.
  * *The count.* Φ ≤ K at the start and Φ ≥ 0.
* *(c).* Each search ends with a hit, or the scan exhausts the run and the problem is abandoned. Each hit is counted in (b), so a problem is rerun finitely often. Under (A2) and (A3′), Lemma 1 guarantees a hit before the scan's end.
* *(d).*
  * Route (i) is Lemma 2.
  * Otherwise, Lemma 3: the scan's first mistake is below n₀ by Lemma 1, so the scan stream gives n₀/w_S surely; |M| ≥ max{1, (σ+1)/(D+1)} under (B_D) by Lemma S; and Lemma 4 bounds j_H.
* *(e)* sums (b) and (d) by Wald's identity, since the number of searches is bounded.
* *(f).* The run and V's verdict are fixed before the audit's coin. An audit of a failed accepted run hits with probability at least γ by Lemma S, and every hit is counted in (b). ∎

**Theorem 6 (imitating the verifier; thread Q, Theorem Q5).** Let V_H be the human's verification, a one-step deterministic function, and K_V its code length or its residual after the task data.
* *Protocol.* Keep a Bayes posterior over V_H, and let V′ be its majority decoder. On each claimed solution y:
  * if V′ rejects, ask V_H(y);
  * if V′ accepts, ask V_H(y) with probability β_V.

  Add every answer to the verifier's data.

Then, for any T claimed solutions chosen adaptively:
* (a) V′ disagrees with an asked V_H at most K_V times;
* (b) the expected number of solutions accepted by V′, not asked, and rejected by V_H would be is at most (1−β_V)K_V/β_V;
* (c) in expectation, V_H is asked at most β_V·T + R + K_V times, where R is the number of true rejections.

So, with an imitated verifier, the expected number of failed outputs is at most (1−β_V)K_V/β_V plus the failures V_H itself passes. With β_V = K_V/(εT), which needs T or a doubling schedule, that is at most εT plus V_H's misses.

*Proof.*
* (a) is Lemma 1 for a one-step function.
* (b) On a false acceptance by V′, an audit lands on a mistake of V′, and by (a) there are at most K_V such hits. So β_V·E[#false acceptances] ≤ K_V.
* (c) A rejection by V′ is a true rejection or a mistake of V′. ∎

*When imitating the verifier pays.* It pays when verdicts are generic, such as a line-by-line proof check or a test suite, or when problems recur. On distinct research problems whose verification needs the problem's own insight, V′ is blind exactly where the imitator is (referee 6, B2). There, budget about one human verification per problem.

**Proposition 7 (without a verifier).** Each round runs the imitator, with asks at confidence below 1 − α. Then it queries:
* a step whose entry L flags as invalid, if there is one;
* otherwise, with probability ⅓ each: the last review step, a uniformly chosen labelled decision step, or a uniform committed step. If the run has no review or no decision, that third goes to the uniform query.

Assume (A1), (A2), (L0), (L1), (L2) (L is sound), (R-rev), and the retry rule with (A-pers) (thread F, Theorem F4). Put each failed run in the first category that applies:
* *invalid:* it has an invalid committed entry;
* *ripe or hedge:* by-product-ripe or a hedge failure, as in Lemma 4;
* *other.*

Assume (B_D) at the valid committed mistakes of the "other" runs, except at steps that set a live approach aside. Let c_r = min{max{1, (σ+1)/(D+1)}, r}, and let d_t be run t's number of labelled decisions. Then

  E[#invalid] + ⅓·E[#ripe] + E Σ_{hedge t} 1/(3d_t) + (c_r/(3n))·E[#other] ≤ K/b_α.

*Proof.*
* *The hit probabilities.* An invalid run is hit with certainty, by Lemma 2. A ripe run is hit with probability at least ⅓, and a hedge run at least 1/(3d_t), by Lemma 4. Any other failed run has at least c_r mistakes by Lemma S and Theorem F4 (which uses (L2)), so it is hit with probability at least c_r/(3n).
* *Disjointness.* The categories are disjoint, so each run is counted once.
* *The count.* Apply the counting of Theorem 5(b). ∎

*Deployment.* Thread H's Theorem H1 is the i.i.d. version for slack imitation with asking and a uniform query. End an epoch also at the first unconfident step of a run. With probability at least 1 − δ, the frozen output's runs are then confident throughout and successful with probability at least 1 − ε. The cost is O((K/α + K)·(D+1)·log(K/(αδ))/(ρε)) task queries. The same proof should cover Proposition 7's query mixture, with γ replaced by min{⅓, 1/(3d_max), c_r/(3n)}, but that is not written out.

## 4. What no scheme can do

Each statement is proved in the thread named, and sketched here. "Task-only" means asking the human only for task steps, at any states, synthetic ones included, adaptively; asks are included.

* **Slack imitation is optimal for bounded-setback humans** (thread J, Theorem J1).
  * *The result.* For all n, ρ, D ≤ n₀/2 and ε there is a class whose humans have setback at most D on every notebook. On it, every task-only protocol needs Ω((1−ρ)·Λ·K/(ε log(n/ε))) task queries. Every protocol with at most a constant number of queries per round, all made after the run, has Ω((1−ρ)ΛK/log n) failed runs.
  * *The sketch.* The insight must appear at s = ⌈(σ+1)/(D+1)⌉ positions of a window, with N possible offsets. A query position lies in at most s of the windows, so each query is a point query among about N/s ≈ Λ candidates.
* **Slack is necessary** (thread J, Corollary J2). The same class with σ = 0 and D = 0 still forces the factor n.
* **Location numbers** (thread J, Theorems J3 and J4).
  * *The upper bound* (J3). Querying by an optimal fractional hitting set of the failing hypotheses' mistake sets gives at most L·K failed runs, where L is the location number.
  * *The matching lower bound* (J4) holds on *faithful* hiding product classes. Outside such classes there is no converse.
* **Verification removes the 1/ε, not the n** (thread Q, Theorem Q1).
  * *The result.* On the silent hidden-insight class, a protocol using fewer than about q/16 verifications per insight problem needs Ω(nK/log(nq/ε)) task queries. VSI uses about one per problem, and Q1's verifications of arbitrary candidates are stronger than VSI's.
  * *The sketch.* A verification says *whether* a problem hides an insight, not *where*.
  * *So* VSI's worst case, 2n₀K, is optimal up to the logarithm and the constant.
* **Insights triggered by doing** (thread G, Theorem G3). Suppose an insight is triggered only by doing one particular unit of routine work, chosen unpredictably. Then every protocol of task queries, and of other human steps whose answers depend only on the units they process, must have the human itself process about a quarter of all the routine work. Each human step can test only the units it processes.
* **Trusted true records** (thread F, Theorem F3). Some humans recover from every omission and every invalid entry, and only never retry an approach with a recorded obstruction. On them, task queries plus single-entry checks need Ω(n₀K/(ε log(n₀/ε))), under the theorem's conditions (q ≥ 4n/n₀, and an output imitator that appends at most one entry per step).
* **Fooled confident commissions** (thread J, Theorem J6). Confident commissions accepted by a fooled human at unpredictable steps cost every task-only protocol Ω(n) queries per deviation.
* **Committees, redundant runs and posterior sampling** (thread Q, Proposition Q6) are task-only rules, and a noisy form of asking. They cannot find confident silent omissions.

**What this says.** In these threads, location for unpredictable, problem-specific contributions came from:
* the human's recovery (slack, under bounded setback);
* hindsight (post-mortems);
* structure: the first mistake comes early, every invalid entry is a mistake, and reviews and decisions are mistakes in ripe and hedge failures;
* concentration of the positions where contributions occur (thread D);
* the imitator's own doubt (asks).

A human judgment of the run's states would be one more source, and it is excluded here. VSI uses the first three, and pays n₀ only when none applies.

## 5. Selection: what "rerun until accepted" does

*What holds.* With exact Bayes and the majority decoder, the decoder is deterministic given the data, and the data change only through the human's answers. A yes/no filter cannot raise a hypothesis's posterior odds (note.md, Proposition 11). So VSI does not *optimize* against V.

*What happens anyway* (thread S §2):
* **Conditioning.** Among outputs, the error rate is wf/(c + wf), where c is the chance of a correct run. On a problem the imitator cannot yet solve, c is near 0, so a verifier miss becomes the output. That is the p·w·f of answer 5.
* **Repeated verification.** If the search fixes a harmless mistake first, the rerun may carry the same wrong claim to the verifier again. If verdicts depend partly on presentation, each re-verification is a fresh chance to pass. Thread S's model gives ×2 to ×4.4 at f = 0.1.
  * *Mitigation:* cache verdicts on a canonical form of the claim, so the same claim is never verified twice.
* **Enrichment.** Accepted wrong results are enriched toward deviations aimed at V's blind spots, by log₂(f_aimed/f_honest) bits: 3.2 bits at f = 0.1. The filter itself adds at most log₂(1 + R_p) bits per problem, where R_p is the problem's number of rejections.
* **Allocation.** Rejections teach the learner only about errors V catches. Errors V misses are found only by audits, hence the β in Theorem 5(f).
* **Practical learners.** A learner that resamples is best-of-k, adding about log₂ k bits per problem. Training on accepted outputs is outright optimization against V. The no-optimization argument holds only for the exact-Bayes, deterministic-decoder idealization.

*What follows.*
* With V-machine on a formally stated goal, none of this matters for correctness.
* With a human verifier, it is why f on the imitator's outputs may exceed f on planted errors, and why I recommend β = 1, cached verdicts, verification by use (testing the result on cases) and two independent verifiers.

## 6. The case for humans, and for the verifier

**What correctness needs: (A4′).**
* *V-machine.* The formal statement or specification captures the goal.
  * *Proof assistants:* the residual risk is misformalization, perhaps 2% of carefully written statements (a guess).
  * *Test suites:* not sound for correctness; thread S puts their miss rate at 0.1–0.4.
* *V-cone.* L is sound, (L2): with a proof checker, yes. A human referee misses a share of plausible local errors: thread L cites 25–55% detection for desk checks of code and 60–96% for formal inspection. Thread S puts f at 0.1–0.35 on imitator-style wrong steps.
* *V-human.* The human, checking a finished result, does not accept a plausible wrong one. Thread S estimates f at 0.2–0.5 for a careful human in mathematics on imitator-style wrong results, and above 0.5 for empirical claims judged by reading.
  * *Why imitator-style errors are hard:* the majority decoder maximizes plausibility, which is the human verifier's evidence; errors in one's own style are caught less often; and familiar patterns are checked less (thread L).
  * *Why they might be easier:* verification is a critical reading of a finished object; unconfident guesses often contradict nearby entries; and results can be tested by use, the strongest error-catcher in thread L.

**What only the cost needs.**
* **(A2)** for every problem. The human's own chain must finish within n₀ under the instruction.
  * *Heavy tails.* With n₀ at the 75th percentile of durations, 6–11% of problems are not finished (thread S, Part E). VSI abstains on them, at most 2n task queries each.
  * *The instruction's cost.* The heavy instruction (typed entries, reviews, decisions, the retry rule) inflates n₀ by about 1.2–1.6× (thread F). That is why it is optional, and the core keeps only what the verifier needs.
* **Bounded setback** (slack-imitation.md §3–4). It holds for the share of mistakes that fail loudly. What sets the cost is the share never recovered, β_nr: thread G's corollary turns it into a *guaranteed* gain over chained imitation of (1−ρ)/(β_nr + (D+1)/(σ+1)).
* **Recovery at reviews, (R-rev).** It holds for insights readable from raw records. It fails for insights that come only from doing (Theorem G3), and for readers with a hypothesis who miss planted anomalies (thread L).
* **Post-mortems.** Their value is measurable, and nothing rests on them. The second researcher writes them so that the imitated human's answers are not contaminated.
* **(L1).** A careful researcher's own entries follow from what they cite. A flagged step that is the human's own costs one query and teaches nothing false.

**The user's constraint.**
* *V-machine* respects it fully: no human judgment at all.
* *V-human* assumes a check of the final state, which is a distinct, weaker assumption than an on-track check (note.md §5.4), but an assumption on which correctness rests.
* *V-cone with a human referee* uses a local, relative judgment of intermediate entries. It is not an on-track judgment, but its locating power comes from the human's own entries passing it, which is the first note's mechanism with "valid" in place of "fine" (thread S §5).

So the version that keeps both the letter and the spirit of the constraint is V-machine, and that is also the version I am most sure of.

## 7. How sure I am

"Works" means: on a real careful researcher, with projects of n₀ ≈ 20–40 steps, the output failure rate is at most 5%, and the total human effort is at most a fifth of chained imitation's. Effort counts task queries, verifications, post-mortems and audits, in task-step equivalents. The figures are conditional on the series' idealizations: determinism, a learner whose class contains the human, and a cold-start chain that succeeds within n₀. The first figure is for theory and software, the second for empirical work.

| scheme | correctness rests on | guarantee on task queries | draft | thread S | **final** |
|---|---|---|---|---|---|
| VSI, proof assistant on a formally stated goal | the formalization | 2n₀K worst case | 85% | 70% | **70%** |
| VSI, test suite | the tests | 2n₀K worst case | (85%) | 45% | **45%** |
| VSI, referee cone check (V-cone) | L's soundness | 2n₀K, 1 per invalid cone entry | 70% / 30% | 45% / 10% | **45% / 10%** |
| VSI, human verifier (V-human) | the human's soundness, plus ε if imitated | 2n₀K, plus about one verification per problem | 65% / 30% | 40% / 10% | **40% / 10%** |
| Proposition 7, no verifier | (B_D) at valid confident entries, (R-rev), (A-pers), (L2) | O((K/α + K)·(D+1)·log(K/(αδ))/(ρε)) (Theorem H1, for asking) | 45% / 20% | 30% / 10% | **30% / 10%** |
| slack imitation with asking (fourth note) | (B_D) at confident steps | the same | 40% / 20% | 25% / 10% | **25% / 10%** |
| chained imitation (the talk) | nothing | n₀K/ε | baseline | baseline | baseline |

* *Why I adopted thread S's numbers.* Its arguments are the stronger ones:
  * human verifiers on the imitator's most plausible wrong answers;
  * p·w·f not decaying;
  * repeated verification;
  * the n₀ inflation from the instruction;
  * heavy tails.

  My draft compared bounds, not efforts, and left out verification and audit costs.
* *Worst-case effort.* With the default weights, VSI's guarantee is 2n₀K task queries, against chained imitation's 20n₀K guarantee at ε = 5%. That leaves a factor 2 before the one-fifth bar, which the core's modest n₀ inflation does not use up. Verification costs come on top: with a human verifier, about one per problem.
* *The human-does-it baseline.* For T distinct problems the human alone spends n₀T. VSI's worst case beats it only if 2K < T, that is, if the problems share most of what must be learned. That is the regime of the original question, "performance on lots and lots of problems".
* *Without the idealizations,* every row falls. VSI with a machine verifier falls least, because its correctness survives non-determinism and non-realizability. Only its cost theory breaks.

## 8. Experiments

All are exact-Bayes, on small classes, with 20–40 humans per cell. They test how cost scales with n and with the kind of human, not whether real humans have the properties.

* **E6** ([`slack-imitation.md`](slack-imitation.md) §6). Task queries until at most 2% of runs fail, on the same humans, for n₀ = 8 → 32 → 128:
  * *chained imitation:* 2,915 → 12,724 → 51,365 for noticing humans;
  * *slack imitation:* 160–490 at n₀ = 8, then about 205;
  * *fooled humans:* 1,631 → 2,811 → 4,296;
  * *silent humans:* slack doubles the cost.

  With a verifier and uniform search, bounded-setback humans need 13–16 task queries for all 100 problems (38 for misled-8 at n₀ = 8).
* **EQ** (thread Q §8). The search on E6's humans, in total task queries for 100 problems:
  * *fooled humans:* 181 → 750 → 2,636 under uniform search, and 40 → 55 → 54 with the full three streams (U+S+H, equal weights);
  * *silent humans:* 1,610 → 6,450 → 26,091, and 663 → 2,497 → 9,734 with the scan;
  * *extra streams:* bounded-setback humans pay at most 1.45×, and an adversarial list at most 1.64×.
* **G1** (thread G §7). Doing-only by-product insights cost every protocol in proportion to the routine work, as Theorem G3 says. Readable insights with reviews and last-review queries cost 285–310 task queries at every size.
* **F1** (thread F §8):
  * *checkable wrong claims:* slack imitation and asking at α = 0.3 grow with n (about 260 → 1,200 failed runs); the local check stays at 9–11, and checking before committing at 0;
  * *false negatives followed by a valid weaker result:* they grow with n under every protocol at α = 0.3, and vanish at α = 0.05 at 7–16 asks per problem; the retry rule with r = 2 or 3 divides them by 3–4.
* **E7, composition** (thread R). E7_PLACEHOLDER

## 9. Trees

Thread N extends slack to decomposition trees: extra rounds per call, with setback measured in the parent's rounds.
* *Depth-weighted queries* give at most Φ·K failed runs, with Φ < 2((D+1)/ρ)^(d+1)·b^d for depth d and b subquestions per round [proved].
* *The factor b^d* is necessary without more structure, since nothing in the run says which subanswer is wrong [proved by reduction, written out in outline].
* *Parents that name the subanswers they reject* remove it [sketch, checked numerically].
* *A verifier at every node* that is sound and complete gives at most K rejections, each found with at most 1 + min{r, (D+1)r/(s+1)} task queries. Here r is a call's number of rounds and s its slack. This needs no assumption about parents and does not depend on the tree's size [proved].

## 10. What to measure first

None of these needs a learner.
1. **The verifier's miss rate f** on imitator-style wrong claimed solutions:
   * in the researcher's own style, against a colleague's;
   * read, against used (tested on cases);
   * the same wrong claim re-verified under different presentations.

   For machine verifiers, measure the misformalization rate.
2. **p·w.** The share of an imitator's failed research runs that end with a confident claimed solution.
3. **The duration tail** of the human's own cold-start chain under the instruction.
4. **Contamination.** Task answers given right after a post-mortem of the same run, against fresh answers, and answers to out-of-order queries.
5. **Post-mortem accuracy, by the second researcher, and setbacks** (slack-imitation.md §4): planted culprits, especially recorded dead ends.

## 11. Limits

* *Idealizations.* Determinism, exact Bayes over a class containing the human, and cold-start chains. Thread L finds experts noisy, with about 90% repeatability on categorical decisions and far less on open-ended work. VSI's correctness survives these with a machine verifier, but its cost theory does not.
* *The domain.* VSI needs a crisp success criterion S_V, fixed in advance and preserved by appending. Multi-year research often has no such goal: its value is a new question or definition found along the way. VSI imitates the well-posed part of research.
* *Verification cost.* If verifying costs nearly as much as doing, VSI saves little over the human doing every problem.
* *Memory.* A real human remembers earlier queries. The scan queries in order, but the uniform stream and the list do not, so some "future" leaks into the human's answers. Every multi-query protocol shares this; it is the reason for the scan-heavy default and for measurement 4.

## 12. Where the parts come from

| part | source |
|---|---|
| slack, Lemma S, bounded setback, Theorem 2, the verifier with uniform search (Proposition 4) | [`slack-imitation.md`](slack-imitation.md), building on thread C's slack Corollary and the third note's Theorem 1 ([`robust-runs.md`](robust-runs.md)) |
| check-and-scan, selection | note.md, Proposition 8 and §6.3 |
| ask-before-committing | thread E ([`research/threadE-redteam.md`](research/threadE-redteam.md)) |
| first mistake before n₀, hints, VSP, imitated verifier, verification does not locate | thread Q ([`research/threadQ-alternatives.md`](research/threadQ-alternatives.md)) |
| certified notebook, local check, cone verifier, retry rule, trusted records | thread F ([`research/threadF-certified.md`](research/threadF-certified.md)) |
| reviews, decisions, the doing-trigger bound, random τ | thread G ([`research/threadG-byproducts.md`](research/threadG-byproducts.md)) |
| optimality, necessity of slack, location numbers, fooled commissions | thread J ([`research/threadJ-optimality.md`](research/threadJ-optimality.md)) |
| deployment with asks, other learners | thread H ([`research/threadH-deployment.md`](research/threadH-deployment.md)) |
| trees | thread N ([`research/threadN-trees.md`](research/threadN-trees.md)) |
| evidence on researchers | thread L ([`research/threadL-evidence.md`](research/threadL-evidence.md)) |
| composition experiment | thread R ([`research/threadR-compose.md`](research/threadR-compose.md)) |
| second red team: selection, post-mortem contamination, verifier soundness, scan-heavy search | thread S ([`research/threadS-redteam2.md`](research/threadS-redteam2.md)) |
| checks, literature, elicitation, persistence | threads A, D, B, C |

## 13. Open

1. A stochastic human: what replaces the bit per mistake of Lemma 1 of note.md, and "an empty step is a delay"?
2. An agnostic version, in which no hypothesis computes the human exactly.
3. The measurements of Section 10.
4. Whether the per-level factor ((D+1)/ρ)^d for trees is necessary (thread N).
5. Whether location protocols that achieve L (thread J) can be run without knowing the hypothesis class's mistake sets.
6. A deployment theorem for Proposition 7's query mixture.
