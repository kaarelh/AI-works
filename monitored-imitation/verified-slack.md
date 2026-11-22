# Verified slack imitation: the scheme I am most sure of

*Research note by Claude (Anthropic), the fifth in this folder: version 3 of the answer to "which scheme are you most sure would work with a deterministic human?".*
* *What it builds on.* It uses the theorems of the fourth note, [`slack-imitation.md`](slack-imitation.md), and synthesizes the research threads listed in Section 12. Their reports are in [`research/`](research/) on the working branch.
* *Status.* Revised three times:
  * after referee 6 ([`verification/referee-report-verified-slack.md`](verification/referee-report-verified-slack.md));
  * after a second red team ([`research/threadS-redteam2.md`](research/threadS-redteam2.md));
  * after referee 7's check of the revision ([`verification/referee-report-verified-slack-v2.md`](verification/referee-report-verified-slack-v2.md)).

  Experiment E7 (thread R) and thread T's calibration of the machine verifier were then added, and referee 8 checked the result ([`verification/referee-report-verified-slack-v3.md`](verification/referee-report-verified-slack-v3.md)). The responses are in [`verification/response-verified-slack.md`](verification/response-verified-slack.md).
* *What is proved where.* Proofs of the main results are given here. The lower bounds are stated with sketches, and the thread reports have their proofs, some written out only in outline, as marked.

## The question

The request: *keep trying threads, and report the scheme you are most sure would actually work with a deterministic human. Ideally, give a proof that the scheme works if the program has such and such properties, and a case that humans in fact have them.* The constraint from earlier in the conversation: no assumption that the human can check whether a run "has gone off track".

## Answers in brief

1. **The scheme: verified slack imitation (VSI).** Slack imitation (the fourth note) plus a verifier of the finished result.
   * *The loop.* Each problem is rerun until the verifier accepts. A rejected run is searched for a mistake, mostly by scanning it from the start.
   * *Termination.* If the scan reaches the end without finding a mistake, the run is the human's own chain, which does not reach a verifiable solution within n steps; VSI says so and stops.
   * *The output* is the verified artifact, optionally after a "nothing bizarre" check of the notebook by someone other than the imitated human.
2. **What is proved** (Theorem 5).
   * *Correctness.* Every output satisfies the verifier's criterion. So correctness rests on one assumption, (A4′): the verifier never passes a wrong result of the imitator.
     * Determinism, realizability and the human's setbacks are not used for correctness, only for cost.
     * This holds when the verifier is consulted on every output. An imitated human verifier adds its own error rate ε (Theorem 6).
   * *Rejections.* At most K of them (K = K(human)).
   * *Cost per rejection.* At most 2n₀ task queries, whatever the human, with the search schedule S, U, S, H. Under bounded setback it is about 4(D+1)/ρ, and it is one query when a local check finds an invalid entry.
   * *Totals.* Search task queries are at most 2n₀K in the worst case, with no factor 1/ε, plus β per problem for audits (β = 1 is recommended with a human verifier). That is within a logarithm of the lower bound that holds even with a perfect verifier (Theorem Q1).
3. **How sure I am.** "Works" means output failure at most 5% on projects of 20–40 three-month steps, at under a fifth of chained imitation's human effort. My probabilities that VSI works on a real careful researcher:
   * *VSI with a proof assistant on a formally stated goal,* with an independent statement review and hardened checking: **70%**. Thread T puts it at about 60% without them, and 77% with an AI formalizer inside the verifier, the human formalizing as a fallback, and thread T's halt rules;
   * *with a test suite as the verifier:* 43%;
   * *with a human referee checking the claimed solution entry by entry:* 45% for theory, 10% for empirical work;
   * *with a human verifier's check of the finished result:* 35% and 10%. This is thread S's figure for an imitated verifier, and the verifier should be someone other than the imitated human;
   * *with thread U's combined human verifier, fixed, with full audits:* 46% for informal theory, 60% for software without a full specification, 15% for empirical work and 20% for judgment work. The combination is a careful expert reader, verification by use, machine checks of every computation and citation, and AI critics whose located objections an expert judges;
   * *as VSI-R* (thread Q2, corrected by the paper's red team): about **50%** for informal theory and **60%** for software, 15% for empirical and 20% for judgment work. VSI-R assigns that combination's members at random per claim, verifies only each run's first claim, sends located objections at the human's own steps to a second judge, caches verdicts, and monitors with Theorem 6′. Thread Q2 had put it at 58% and 66% by using Theorem 6′ without its +1; with the +1 the gain over the fixed combination is within the noise. Theorem 6′ supplies monitoring, not sureness;
   * *without any verifier* (slack imitation with asking and the design elements): 30% and 10%.

   That VSI's task queries are truly O(K), with neither n₀ nor 1/ε, I put at 25%, thread S's figure (thread S §7). So the answer to the O(K) question is no in the worst case on chains: up to 2n₀K task queries of three months each. On a formal blueprint, though (thread Y, Section 9), the search costs at most (p·d + r₀)K/b task queries, independent of the size of the work, assuming only that the human's own blueprint succeeds; I put at about 45% that a real mathematician meets this within a factor 3.

   All these figures are conditional on determinism, realizability and a chain that finishes; without that conditioning the 70% row is about 40% (thread S).
4. **So the scheme I am most sure of** is VSI with a machine verifier on a formally stated, independently reviewed goal. Its domain is narrow: in ten months, working easiest first, experts stated about a quarter of recent Annals main theorems in Lean (thread T). There the verifier deserves most of the credit: any generator wrapped in it would be as correct. Imitation adds a low query cost, at most 2n₀K, and runs that are the human's own process with some steps replaced. Elsewhere VSI is the best scheme I have found, but not one to be sure of.
5. **The most important caveat** (red team, thread S). VSI is exactly as sure as its verifier is sound on the imitator's *own most plausible wrong answers*.
   * *Rerunning until accepted* turns every miss of the verifier into a wrong output, at a rate of about p·w·f_eff per problem:
     * p, the first-run failure rate on a new problem;
     * w, the share of failed runs that carry a claimed solution;
     * f_eff ≈ 1 − (1−f)^r, the verifier's miss rate f compounded over the r claim-carrying runs a problem may need.
   * *Why it need not shrink:* with problem-specific insights, p does not fall as learning proceeds.
   * *Why f may be high:* the majority decoder writes the *most typical-looking* wrong result, which is the hardest kind for a human verifier to catch. That is why the human-verifier rows are low.
   * *What it adds* (thread Q2, Theorem 6′). On i.i.d. problems, wrong outputs are paid for by rejections that end in a hit: at most (c+1)·K/b, if the verifier has no total blind spot at the states learning reaches. That gives a monitoring handle, but at realistic numbers of problems it adds little sureness, and it fails for follow-up problems, problem-specific knowledge, and blind spots within a kind.
6. **What no scheme can do** (Section 4; proved in the threads). For humans whose contributions are unpredictable and problem-specific, every scheme that asks the human only for task steps pays, in some cases, about n₀ queries per insight, or about the routine work per insight:
   * insights triggered only by *doing* a piece of work;
   * ideas never retried after a trusted record of a failed attempt;
   * confident wrong content that a human accepts.

   Slack imitation is optimal for humans with bounded setback, up to logarithms. Slack is necessary. Verification removes the 1/ε but not the n. In VSI these lower bounds cost queries, never correctness.
7. **The evidence** (thread L). Setbacks look bimodal: an error is caught at review or first use, or only after a year or more, or never. Reviewers catch 30–60% of planted plausible errors. This is why the scheme leans on a machine verifier, and why the human-verifier rows are low.
8. **What to measure first** (Section 10):
   * the verifier's miss rate f on imitator-style wrong results;
   * the share p·w of failed runs that end with a confident claimed solution;
   * the duration tail of the human's own chain;
   * how much reading a run (a post-mortem, a verification, a check) changes the human's later answers on it;
   * planted-culprit tests of post-mortems and of setbacks;
   * for formal verifiers, planted statement defects, the formalizer's false-rejection rate, and the cost of formal proof.

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
  * **(V-machine)** a machine check: a proof assistant on a formal statement, a test suite, a program checking a constructed object. For a proof assistant, thread T ([`research/threadT-formal.md`](research/threadT-formal.md)) makes two things mandatory:
    * *a statement protocol:* a second, independent formalizer, with a machine-checked equivalence of the two formalizations; at least two AI audits from different model families; test lemmas for new definitions; non-vacuity witnesses; automated attempts to prove and to disprove the statement; and human sign-off on the elaborated statement;
    * *hardened checking:* a pinned, patched kernel; a checker such as Comparator or SafeVerify; an axiom whitelist; no `native_decide`; and at least two kernels.

    Either the human's own chain ends with the formal proof, or (better) **the formalizer sits inside V**. Then the chain ends with a blueprint-quality informal proof, and V means: "an AI formalization agent, within budget B, produces a proof of the fixed formal statement that the hardened kernel accepts".
    * *What this changes.* Correctness still rests only on the statement and the checking pipeline. The output is the formalizer's formal proof, not the blueprint. The n₀ inflation shrinks to the cost of the blueprint.
    * *What (A2) and (A3′) then require of the formalizer F:*
      * F is deterministic: a fixed seed, a pinned model and a pinned toolchain;
      * F reads only the claim and what precedes it, so S_V stays preserved by appending;
      * F succeeds within B on the human's own blueprint.

      Thread T puts F's false-rejection rate on correct human blueprints at 5–30% by field. Each false rejection is an (A2) failure. VSI then abstains after a full scan, at about n task queries, unless it falls back to the human formalizing, as thread T's 77% assumes.
    * *F is an optimizer.* It makes the statement protocol and hardened checking mandatory (§5).
    * *Statement defects* (thread T §5.3), two rules that belong to the protocol (§2.3):
      * a STATEMENT-DEFECT entry, which the instruction lets the human write, halts the problem for review when it appears in any run;
      * an anomaly trigger: a proof much shorter or faster than expected, or one that bypasses the blueprint's milestones, sends the statement to review before output.
  * **(V-cone)** a check of the claimed solution's *dependency cone*, the claim and everything it cites recursively, by a local check L: does each entry follow from what it cites? (Thread F, Proposition F5.) L may be a proof checker or a human referee other than the imitated human. This needs thread F's typed entries and citations.
  * **(V-human)** a human verifier's check of the finished result, on every output or imitated (Theorem 6). The verifier should be someone other than the imitated human. The imitated human may verify only under §2.2's assumption that reading a run leaves its later answers unchanged.
* **The final "nothing bizarre" check** of the notebook (slack-imitation.md §2), optional.
  * *Its role.* It serves the talk's second desideratum, since V checks only S_V, and the cost. It is a human judgment of the final notebook, but correctness does not rest on it.
  * *Who does it.* Someone other than the imitated human, for the reason given for post-mortems below.
* **Output the verified artifact,** not the whole run. A notebook can hold a correct solution and a later plausible wrong one.

### 2.2 Optional additions

Each addition costs n₀ or human time. Add one only where it is measured to pay.
* *Reviews and labelled decisions* (thread G). Reviews are triggered by content, after every L_rev new work entries, and reread every raw record; decisions are labelled entries. They make the list stream H of the search cheap for readable by-product insights and for hedges.
* *Typed, certified entries and obstruction records* (thread F). They are needed for V-cone. They also let a local check flag invalid entries, each of which marks a mistake.
* *Asking at the final-answer slot.* Asking before committing (slack-imitation.md, Proposition 5), restricted to the step that writes the claimed solution. It hands the human the slot where the imitator would otherwise write its most plausible guess, which is the guess that stresses a human verifier.
* *Post-mortem pointers, written by a second researcher.* "This project failed; which entries would you re-examine first?" The human being imitated must not write them: after reading the failed run, its answers to task queries on that run are no longer P's (thread S §3).
  * *The same applies* to anyone who reads a run before it is searched or audited: a human verifier, a human referee doing the cone check, or the person doing the "nothing bizarre" check. They should all be someone other than the imitated human.
  * *Otherwise,* the cost theory assumes the human's answers are unchanged by having read the same run.
* *Independent verifiers, and verification framed as a colleague's.* Two verifiers have joint miss rate f₁f₂ + Cov(miss₁, miss₂), which is f₁f₂ for independent misses (thread S §6). The claimed solution can be shown to a human verifier as a colleague's work, which the design law allows since a verification is not a task step.

### 2.3 Protocol VSI

For each problem, repeat:
1. **Run.** Build a run of n steps. If final-answer asks are used, ask the human at every *final-answer slot*: a step at which some label of posterior mass at least α writes a claimed solution, while the top label's mass is below 1 − α.
2. **Verify.** V accepts if some claimed solution in the final notebook passes it, and the verified artifact is the first one that passes.
   * *If V accepts and the "nothing bizarre" check is used* (done by someone other than the imitated human):
     * if the check fails, bisect to the flip, task-query it, and rerun;
     * if it passes, output the verified artifact.
   * *Audits.* After an output, with probability β, task-query one uniform committed step and add the answer.
3. **If V rejects:**
   * *(i) Invalid entries.* If L flags invalid committed entries, task-query the flagged steps in turn until one is a mistake. A flagged step that turns out to be the human's own (an *excused* flag) costs one query and teaches nothing false. If every flag is excused, go on to (ii).
   * *(ii) Search.* Queries cycle through the streams in the fixed order **S, U, S, H**, over committed steps:
     * **S:** the next step of a scan from step 0;
     * **U:** a uniformly random step;
     * **H:** the next entry of a list fixed at the start of the search, made of the last review step, the labelled decision steps, and the second researcher's post-mortem entries. When the list is empty or exhausted, its turn goes to S.

     Stop at the first query that lands on a mistake. Add its answer first and the others after it, then rerun.
   * *(iii) Abstain.* If the scan reaches the end of the run without a mistake, the run is the human's own chain. Report "the human's own chain does not reach a verifiable solution within n steps", and stop.
4. **Halt for statement review** (machine verifiers with a formal statement). Halt the problem if any run contains a STATEMENT-DEFECT entry, or if an accepted proof triggers the anomaly rule of §2.1.

*The schedule.* S, U, S, H gives the scan half the queries, in an order that keeps the worst case at 2n₀. The order matters: U, H, S, S has the same frequencies but gives 2n₀ + 1. Raise H's share only once post-mortems have been measured to work. With a random schedule of the same frequencies, the bounds below hold in expectation only.

## 3. Theorems

**Assumptions.**
* **(A1)** P is deterministic, and the learner is Bayes over a class containing P.
* **(A2)** S_V is preserved by appending, and τ_V(x₀) ≤ n₀. Here τ_V is the human's own remaining time to S_V, and τ\* its remaining time to S\*.
* **(A3′) Completeness on the human's runs.** V accepts every extension of the human's own notebook at step n₀.
* **(A4′) Soundness, per claim.** Every claimed solution that V passes, in the final notebooks of the imitator's runs, satisfies the goal. S\*(x) denotes "the first claim in x that V passes satisfies the goal".
  * S\* is preserved by appending when V's verdict on a claim depends only on the claim and what precedes it.
  * For V-human, (A4′) asks the verifier to reject even claims that the human itself would later retract.
* **(M1), (M2), (M-prefix)**, only when the "nothing bizarre" check is used (slack-imitation.md §2; (M-prefix): every prefix of a passing notebook passes):
  * (M1): the start notebook passes;
  * (M2): the human never makes a passing notebook fail.
  If a second person does the check, (M2) is a condition on that person's verdicts about P's steps.
* **(L0), (L1)**, only when L is used:
  * (L0): L is a fixed function, whose verdict on an entry never changes once the entry is written;
  * (L1), self-validity: every entry the human appends passes L.

*b, the value of a hit.*
* With final-answer asks only, or none, put b = 1.
* With asks at every unconfident step (thread E's SI-ABC), put b = b_α.

**Lemma 1 (the first mistake comes early; thread Q, Lemma Q3).** Under (A1) and (A3′), every rejected run has a committed mistake at a step below n₀.

*Proof.* Asked steps and correct committed steps both append P's label. So if no committed step below n₀ is a mistake, the notebook at step n₀ is the human's own notebook c_{n₀}. The final notebook extends c_{n₀}, so V accepts it by (A3′). ∎

**Lemma 2 (every invalid entry is a mistake; thread F, Lemma F1).** Under (L0) and (L1), a committed step that appends an entry failing L is a mistake.

*Proof.* By (L1), every entry of the human's step passes L, and by (L0) the verdict on the entry is fixed. So the imitator's step differs from the human's. ∎

**Lemma 3 (weighted hints are free of risk; thread Q, Lemma Q2, with weights).**
* *The setting.* Fix a rejected run of a fixed decoder, with committed mistake set M ≠ ∅. Search it with streams served by a fixed schedule in which stream i is served at least ⌊w_i·t⌋ times among the first t queries, for every t. Each stream is either uniform over committed steps, drawn with replacement, or a list fixed when the search starts and written by anyone, an adversary included.
* *The claim.* Every answer added is the human's own step. A list stream's first mistake, at position j_i (counting from 0), is reached by query ⌈(j_i + 1)/w_i⌉, and

  E[queries] ≤ min{ (n/|M|)/w_U, (j_S + 1)/w_S, (j_H + 1)/w_H }.

* *The default.* For the schedule S, U, S, H the constants are exact: the scan's j-th step is query 2j − 1, list H's i-th entry is query 4i, and the uniform stream's k-th draw is query 4k − 2.

*Proof.*
* By the schedule's property, stream i has been served k times by query ⌈k/w_i⌉.
* The uniform stream's draws succeed independently with probability at least |M|/n.
* The search stops at the first hit of any stream.
* Not every periodic schedule with these frequencies has the property: H, U, S, S does not. For a general schedule of period p, add p to each term. ∎

**Lemma 4 (ripe failures; thread G, Theorem G4 and Proposition G7).**
* *Ripe failures.* Call a failed run *by-product-ripe* if two things hold:
  * at some step k before its last review, the imitator wrote exactly P(x′_k) minus a by-product insight I satisfying thread G's (Rec1)–(Rec3);
  * I is absent from the final notebook.

  Under thread G's review assumption (R-rev), the run's last review step is a mistake.
* *Hedges.* Call a failed run a *hedge failure* if, at a labelled decision, the imitator adopted a default where the human would have written its idea. Its decision step is a mistake.
* *In both cases* the step is committed: an asked step is the human's own, and the human would write I, or its idea, there.

*Proof.* See thread G §4–5. The human at the last review would write I, and the imitator does not, or I would be in the final notebook. The decision case holds by definition. ∎

**Theorem 5 (verified slack imitation).** Assume (A1), (A2) and (A3′); (M1) and (M2) if the check is used; (L0) and (L1) if L is used. The search uses the schedule S, U, S, H. For every sequence of problems, chosen adaptively:
* **(a) Correctness.** Every output satisfies S_V, and under (A4′) it satisfies S\*.
  * This uses no property of the human's task steps, and none of (A1)–(A3′).
  * But for V-human, and for V-cone with a human referee, (A4′) is itself an assumption about a human judgment.
* **(b) Counts.** Asks number at most K/log₂(1/(1−α)) on every path. Almost surely, rejections ending in a hit, failed "nothing bizarre" checks and audit hits together number at most K/b.
* **(c) Termination.** Every problem ends, with an output or an abstention.
  * Termination needs only (A1), and (M1) and (M2) if the check is used.
  * With a formal statement, a problem may also end with a halt for statement review (step 4).
  * Under (A2) and (A3′), the abstain rule never fires.
  * Without them, the number of rejections is at most K/b plus the number of abstentions.
* **(d) The cost of one rejection.**
  * *Route (i)* costs one query, plus one for each excused flag.
  * *Otherwise,* the search costs at most min{4n/|M|, 2n₀, 4(j_H + 1)} queries in expectation, and the 2n₀ holds surely. In particular, the cost is at most:
    * 2n₀, whatever the human;
    * 4Λ in expectation, under (B_D) in τ_V at committed mistakes, bizarre entries included;
    * 4, for a by-product-ripe failure under (R-rev);
    * 4(1 + d), for a hedge failure, where d is the run's number of labelled decisions;
    * 4(1 + d + i), if the i-th post-mortem entry is a mistake.
  * *On a problem that violates (A2) or (A3′),* Lemma 1 fails, and a search may cost up to 2n. Heavy tails and a formalizer's false rejections are two sources of such problems. An abstaining search costs at most 2n queries, or n distinct steps if answers are cached.
* **(e) Totals.**
  * *Task queries:* E[task queries] ≤ asks + (K/b)·min{2n₀, 4Λ} + β·T over T problems, plus up to 2n per rejection and per abstention on problems that violate (A2).
  * *Other human effort:*
    * one verification per claim checked, with a human verifier, or Theorem 6's count;
    * with a formal statement, writing and reviewing it, once per problem;
    * at most K/b post-mortems, read by the second researcher;
    * one "nothing bizarre" check per accepted run, plus ⌈log₂ n⌉ per failed check;
    * the local checks.
* **(f) If (A4′) fails.** The failed outputs are exactly the accepted runs that fail S\*.
  * *Assume also* that S\* is preserved by appending, that τ\*(x₀) ≤ n₀, and (B_D) in τ\* at the committed mistakes of accepted runs, bizarre entries included if the check is not used.
  * *τ\*(x₀) ≤ n₀ says,* in particular, that the human's own chain writes no claim that V passes but is wrong before its correct one.

  Then

  E[#failed outputs] ≤ K/(b·β·γ*), where γ* = max{1, (σ+1)/(D+1)}/n.

  So β = 1 is needed to keep slack imitation's own bound.

*Proof.*
* *(a).* V accepted every output, and (A4′) is exactly the step from S_V to S\*.
* *(b).*
  * *Asks:* as in slack-imitation.md, Proposition 5(a).
  * *Every search ends,* with a hit at a committed step or with the scan exhausted. A failed check's flip is a mistake by (M1) and (M2), slack-imitation.md §2.
  * *The hit's value.* List the round's data as: the asks before the hit's step k, then the hit, then the rest. W depends only on the set of data, so the order does not change the total.
    * The human's answer at a committed mistake has mass at most ½ (Lemma 1 of note.md), so the hit lowers Φ by at least 1.
    * With asks at every unconfident step, the decoder committed at k with top mass at least 1 − α under exactly the data before the hit. So the answer has mass at most min{α, ½}, and the hit is worth at least b_α.
    * With final-answer asks only, that holds only at final-answer slots, which is why b = 1.
  * *The count.* Φ ≤ K at the start and Φ ≥ 0.
* *(c).* A problem is rerun only after a hit, and hits are counted in (b). A failed check's flip is a hit by (M2). Under (A2) and (A3′), Lemma 1 guarantees a hit before the scan's end.
* *(d).*
  * Route (i) is Lemma 2.
  * Otherwise, Lemma 3 with the default constants. The scan's first mistake is below n₀ by Lemma 1, so it is reached by query 2n₀ − 1. Under (B_D), Lemma S gives |M| ≥ max{1, (σ+1)/(D+1)}, and Lemma 4 bounds j_H.
* *(e)* sums (b) and (d) by Wald's identity, since the number of searches is bounded.
* *(f).* An output passed the check, so with (M-prefix) none of its notebooks is bizarre, and Lemma S applies in τ\*. Without the check, assume (B_D) in τ\* for bizarre entries too. The run and V's verdict are fixed before the audit's coin, so an audit hits with probability at least γ\*. Every hit is counted in (b). ∎

**Proposition 5′ (a safety net for any learner; corrected after the paper's referee).** Run VSI without the local check and the bizarre check, with *cache-first decoding*, with answers cached so that no notebook is asked twice, and with no asks; the scan skips cached notebooks without using up its turn. Cache-first decoding means that at any notebook already asked about, the imitator outputs the human's recorded answer; elsewhere any learner may decide. Assume that P is deterministic (not realizability) and (A3′). Then, whatever the learner:
* (a) correctness is as in Theorem 5(a);
* (b) on any single problem, VSI makes at most 2n₀ task queries in total, over all its reruns, its audit included; without (A3′), at most 2n;
* (c) if the learner makes at most M̄ mistakes on the notebooks it predicts before being told their answers, there are at most M̄ rejections, and at most 2n₀M̄ + βT task queries in all. For exact Bayes, M̄ ≤ K.

*Proof.*
* *(b).* Fix a problem.
  * P is deterministic, so a cached answer is P's label there, and Lemma 1 applies. In any run, the steps before the first committed mistake follow the human's own chain, and the first mistake is below n₀.
  * A cached notebook cannot be a mistake. So the scan queries only uncached chain notebooks c_i, i < n₀, each at most once over all searches: at most n₀ scan queries. A scan query at c_{n₀−1} can only be a hit.
  * In the cycle S, U, S, H, a search's non-scan queries are at most its scan queries, and one fewer if it ends with a scan hit. So the searches make at most 2n₀ − 1 queries, and the one audit fits. Without (A3′), the scan's notebooks are the c_i with i < n.
* *(c).* Each rejection ends with a query at a notebook where the learner's earlier prediction was wrong, so there are at most M̄ rejections, each costing at most 2n₀ by (b); audits add βT. ∎

*With the local check or the bizarre check,* a route-(i) or flip query can land off the human's chain and use up no chain notebook; the paper's referee forced 200 queries on one problem this way. (b) is restored by making a scan query before each such query.

*When imitating the verifier pays.* It pays when verdicts are generic, such as a line-by-line proof check or a test suite, or when problems recur. On distinct research problems whose verification needs the problem's own insight, V′ is blind exactly where the imitator is (referee 6, B2). There, budget about one human verification per problem.

**Theorem 6′ (wrong outputs are paid for by rejections; thread Q2, Theorem Q2.1, restated after the paper's referee).** Call a rejection *informative* if the rejected run has a committed mistake; its search then ends in a hit. Assume (A1), with verdicts cached on claims; assume neither that V is sound nor (A2)–(A3′). Say V has *no total blind spot with constant c* if at every reachable state, with decoder G, problems from μ, and V's randomness,

  Pr[V accepts G's run, and its verified artifact fails the goal] ≤ c · Pr[V rejects G's run informatively].

* (a) If problems are i.i.d. from μ and V has no total blind spot with constant c, then for every T, and within every window of rounds, E[#wrong outputs] ≤ (c+1)·E[#informative rejections] ≤ (c+1)·K/b.
* (b) Suppose instead that V verifies only each run's first claim, that the human's own first claim satisfies the goal, and that each fresh verification passes a wrong claim with probability at most f̄ given the past (for example a pool assigned at random per claim). Then on every problem sequence the expected number of distinct wrong claims output is at most f̄·K/((1−f̄)·b).
* Rejections that are not informative cost a search of at most 2n and an abstention each, never a wrong output.

*Proof.*
* Informative rejections end in hits, so there are at most K/b of them.
* (a) The next problem is independent of the state, so the probability that a round's first run is accepted with a wrong artifact is at most c times the probability that it is rejected informatively. A problem is rerun only after an informative rejection and has one output. Summing, E[#wrong] ≤ c·E[#first-run informative rejections] + E[#problems with an informative rejection] ≤ (c+1)·E[#informative rejections].
* (b) A wrong first claim is not the human's, so its rejection is informative. With caching, each claim is verified once. If N wrong claims are verified fresh, at most f̄N pass and at least (1−f̄)N are informative rejections, in expectation. ∎

*Without the first-claim rule,* (b) fails: if V accepts when any of k wrong claims passes, the ratio f̄/(1−f̄) becomes (1−f̄)^(−k) − 1.

*What it gives, and what it does not.*
* *Monitoring:* within any window, wrong outputs are at most (c+1) times the informative rejections. But c must be estimated, and planted errors underestimate it; estimate it by independent re-solution of a sample of accepted outputs.
* *Kind by kind:* in product classes the bound is Σ_κ(c_κ+1)K_κ/b, and a kind with claim share w and miss rate f gives c = wf/(1−wf), about 0.35 for one careful reader in theory (w = 0.6, f = 0.43).
* *Little extra sureness:* (c+1)K/(bT) ≤ 5% needs T/K ≳ 25. With the +1, thread Q2's model of the human-verifier estimates gives about what it gives without the theorem (red team, [`verification/redteam-paper.md`](verification/redteam-paper.md)).
* *When it fails:* follow-up problems are not independent; problem-specific knowledge makes K grow with T; hits select hypotheses whose errors V passes, so the condition needs a product of kinds each learned as a unit. A deterministic verifier with a kind it always passes defeats it, and the hidden-insight price (Section 4) returns on that kind.
* *Resampling:* a learner that resamples on rejection can inflate c without bound, by about x^(−(k−1)) for k samples, x the rejection probability.

*Falsification by use* (thread Q2, Theorem Q2.3). Keep a library of the current imitator's outputs, recomputed after every hit, that later work cites. Assume (A1), and that the human's own chain reaches within n₀ a claim that V passes and that is never exposed. If every use that relies on a false claim yields a located, certified counterexample with probability at least e, and only false claims are exposed, then every exposure ends in a hit, and expected uses that rely on false outputs are at most K/(b·e), for ever. That bounds reliance, not each output; it reaches the verifier's blind spots wherever later use can expose them.

**Proposition 7 (without a verifier).** Each round runs the imitator, with asks at confidence below 1 − α. Then it queries:
* a step whose entry L flags as invalid, if there is one;
* otherwise, with probability ⅓ each: the last review step, a uniformly chosen labelled decision step, or a uniform committed step. If the run has no review or no decision, that third goes to the uniform query.

Assume (A1); S\* preserved by appending, with τ\*(x₀) ≤ n₀; (L0), (L1) and (L2) (L is sound); (R-rev); and the retry rule with (A-pers) (thread F, Theorem F4). Here τ is τ\*, since there is no verifier. Put each failed run in the first category that applies:
* *invalid:* it has an invalid committed entry;
* *ripe or hedge:* by-product-ripe or a hedge failure, as in Lemma 4;
* *other.*

Assume (B_D) in τ\* at the valid committed mistakes of the "other" runs, bizarre entries included, except at steps that set a live approach aside. Let c_r = min{max{1, (σ+1)/(D+1)}, r}, and let d_t be run t's number of labelled decisions. Then

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
  * *The matching lower bound* (J4) holds on *faithful* hiding product classes. Outside hiding classes there is no converse; for hiding classes that are not faithful, the question is open.
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

Located probes, which need foresight (thread B), and a "confession" state off the runs (thread J) are further sources. A human judgment of the run's states would be one more, and it is excluded here. VSI uses the first three, and pays 2n₀ only when none applies.

## 5. Selection: what "rerun until accepted" does

*What holds.* With exact Bayes and the majority decoder, the decoder is deterministic given the data, and the data change only through the human's answers. A yes/no filter cannot raise a hypothesis's posterior odds (note.md, Proposition 11). So VSI does not *optimize* against V.

*What happens anyway* (thread S §2):
* **Conditioning.** Among outputs, the error rate is (1−c)wf/(c + (1−c)wf), where c is the chance of a correct run. On a problem the imitator cannot yet solve, c is near 0, so a verifier miss becomes the output. That is the p·w·f_eff of answer 5.
* **Repeated verification.** If the search fixes a harmless mistake first, the rerun may carry the same wrong claim to the verifier again. If verdicts depend partly on presentation, each re-verification is a fresh chance to pass. Thread S's model gives ×2 to ×4.4 at f = 0.1 (ρ = ½, equal weights).
  * *Several claims in one notebook* are each a chance to pass. That is why V accepts on the first passing claim and outputs that artifact, with every verification counted.
  * *Mitigation:* cache verdicts on a canonical form of the claim, so the same claim is never verified twice.
* **Enrichment.** Accepted wrong results are enriched toward deviations aimed at V's blind spots, by log₂(f_aimed/f_honest) bits: 3.2 bits at f_honest = 0.1, with f_aimed = 0.9. The filter itself adds at most log₂(1 + R_p) bits per problem, where R_p is the problem's number of rejections.
* **Allocation.** Rejections teach the learner only about errors V catches. Errors V misses are found only by audits, hence the β in Theorem 5(f).
* **The formalizer inside V** (thread T §5.3). With a formalizer F inside V, a search for *any* accepted proof runs inside V, against the statement and the checker, which is exactly where soundness lives.
  * *Loopholes are hunted.* A weaker statement's loophole is hunted actively, not merely selected: thread T raises its exploitation rate from 0.3–0.5 for the imitator to 0.5–0.9.
  * *Checker exploits* become reachable.
  * *Each re-verification under a new seed is a fresh search.* Fixed seeds and cached verdicts close this.
  * *The bound log₂(1 + R_p)* does not cover F's internal search, whose size is set by its budget B.
* **Practical learners.** A learner that resamples is best-of-k, adding at most log₂ k bits per problem. Training on accepted outputs is outright optimization against V. The no-optimization argument holds only for the exact-Bayes, deterministic-decoder idealization.

*How much, exactly* (thread V, [`research/threadV-humanlike.md`](research/threadV-humanlike.md), proved for exact Bayes and any filter satisfying (A3′); K′ = ⌊K/b⌋):
* *No optimization pressure.* Every output notebook is the majority decoder's run under a set of the human's answers, by a map fixed before V is chosen. V changes runs only by rejecting them, and each rejection costs a hit.
* *Per problem.* V picks a stopping point on a path of runs that does not depend on V, from the verifier-free run to the human's own chain: log₂(1 + R_p) bits, and none without a rejection.
* *Lifetime.* At most log₂ C(T+K′, K′) ≤ K′·log₂ e + K′·log₂(1 + T/K′) bits against content-blind verdicts, and this is tight. Thread S's "K·log₂ e" is only the first term.
* *With audits.* At most K′·log₂(e(1 + n/β)) bits against a deviation-blind filter, for every T. The expected number of non-human steps in all outputs is at most nK′/β.
* *Several claims.* Choosing among an accepted notebook's claims adds up to log₂ c_p bits per problem. Verifying only the first claim removes this choice.
* *Isolation of a formalizer inside V.* The notebook is not optimized, for any formalizer, provided nothing it produces enters a notebook, the data, or the imitated human's view.

*What follows.*
* With V-machine on a formally stated goal, none of this matters for correctness.
* With a human verifier, it is why f on the imitator's outputs may exceed f on planted errors, and why I recommend β = 1, cached verdicts, verification by use (testing the result on cases) and two independent verifiers.

## 6. The case for humans, and for the verifier

**What correctness needs: (A4′).**
* *V-machine.* The formal statement or specification captures the goal.
  * *Proof assistants:* the residual risk is misformalization. Thread T finds it far commoner than the 2% assumed in this note's first draft, unless statements are independently reviewed; after review, 2% is about right as an effective rate.
    * *The evidence.* After an in-depth manual review of expert-written Lean statements of 50 Annals theorems, AI audits still found mistakes in 22% of them, of unreported severity. Benchmarks run 5–60% unfaithful; the upper end rests on search summaries only.
    * *Thread T's estimates for a research goal written by an expert:*
      * for goals that need new definitions, about 25% of statements are unfaithful without independent review, and about 10% have an exploitable weaker form; in vetted Mathlib vocabulary, 8% and 3%;
      * with the statement protocol, about 4% and 1.5%.
    * *Contribution to output failure:* about 0.5–1% with review and up to 5% without, with the human formalizing; 0.7–1.3% and 5–9% with the formalizer inside V.
    * *Optimizers exploit misreadings.* In DeepMind's Aletheia run on informal statements of Erdős problems, 50 of 63 "technically correct" solutions were vacuous misreadings (search summaries only). That is an optimizing prover, not an imitator's reruns, but a formalizer inside V is an optimizer.
    * *About half of misformalizations fail safe* (search summaries only): a false statement cannot be proved, so VSI abstains, at about n task queries.
    * *Kernels* are sound against honest proofs. Adversarial AI testing found several Lean and Rocq soundness bugs in 2026 (search summaries only), hence the hardened checking, which thread T puts at about 99.5% sound.
  * *Test suites:* not sound for correctness; thread S puts their miss rate at 0.1–0.4.
* *V-cone.* Three things: L is sound, (L2); the claimed solution's statement is the goal; and machine records and retrieved sources are correct (thread F, Lemma F0). With a proof checker, the first holds. A human referee misses a share of plausible local errors: thread L cites 25–55% detection for desk checks of code and 60–96% for formal inspection. Thread S puts f at 0.1–0.35 on imitator-style wrong steps.
* *V-human.* The human, checking a finished result, does not accept a plausible wrong one. Thread S estimates f at 0.2–0.5 for a careful human in mathematics on imitator-style wrong results, and above 0.5 for empirical claims judged by reading.
  * *Why imitator-style errors are hard:* the majority decoder maximizes plausibility, which is the human verifier's evidence; errors in one's own style are caught less often; and familiar patterns are checked less (thread L).
  * *Why they might be easier:* verification is a critical reading of a finished object; unconfident guesses often contradict nearby entries; and results can be tested by use, the strongest error-catcher in thread L.

**Verifiers without a machine** (thread U, [`research/threadU-nonformal.md`](research/threadU-nonformal.md)). Output failure is about (p·w·r̄)·f_V, where r̄ is the number of distinct wrong claims verified per failing problem. At central values, the 5% bar needs f_V ≤ 0.29 in theory, 0.23 in software, 0.17 in empirical work and 0.16 in judgment work. One careful reader gives about 0.43, 0.45, 0.70 and 0.64. What helps:
* *Different methods, not more readers.* Readers' misses correlate (fitted r ≈ 0.45–0.75), so a second reader leaves 0.24, not the 0.16 that independence would predict.
* *Verification by use* (examples, consequences, independent tests) catches different errors from reading. Reading plus use cuts misses by about 38%; in software, independent tests and fuzzing take f from 0.45 to 0.13.
* *Machine checks* of every computation and citation remove about 20% of misses.
* *AI critics* from several model families, with an expert other than the imitated human judging *located* objections. They are the largest single gain, 0.43 to 0.18 when added to a reader. They go beyond imitation, but a critic can only add rejections, so it cannot make a wrong result pass. False objections cost abstentions, so they need adjudication.
* *Located objections* are pointers for the search. A rejection that does not say where costs a full scan, about 1.5n₀; requiring located objections halves V-human's cost per problem.
* *Delayed checks by consequence* are the only remedy for empirical claims that are false in the world, at the price of provisional outputs.
* *Thread U's estimates for VSI with the best combination* (its model's figures, then its own):
  * informal theory: 62% and 50%;
  * software without a full specification: 73% and 60%;
  * empirical work: 23% and 15%, or 25% with the goal narrowed to "the claim follows from the data";
  * judgment work: 28% and 20%.

  Its inputs are mostly judgments, not measurements on an imitator's wrong results.
* *No total blind spot* (thread Q2, [`research/threadQ2-freshlook.md`](research/threadQ2-freshlook.md)). Theorem 6′ replaces a small miss rate by a weaker condition under i.i.d. problems, though at realistic scales it supplies monitoring rather than sureness. Planted-error studies find partial catch rates for reading, 30–60%, and rarely zero for a kind. Diverse methods make a shared total blind spot rarer, and a randomly assigned pool removes a fixed one. The threats: a misreading of the goal shared by the verifier and the imitator; empirical claims false in the world that follow from the data, which every reading method misses; and AI critics that share an AI imitator's blind spots. Thread Q2 puts the probability that a combined verifier has no total blind spot that matters at about 65% in theory, 70% in software, 25% in empirical and 30% in judgment work, and its estimates for VSI-R at 58–59%, 66%, 18% and 22%; the paper's red team found that these used Theorem 6′ without its +1, and with it they fall to about 50%, 60%, 15% and 20%. (Thread Q2 also found that thread U's model let the rejections exceed K; the corrected figures replace its model's.)
* *VSI-R* (thread Q2, as corrected in the paper). VSI with: verification of each run's first claim only; a second judge for objections located at steps that a task query shows to be the human's own (thread U's model gives the pool about 0.4 upheld false objections per correct theory claim without it); no caching of rejections whose search found no mistake; a pool assigned at random per claim (machine checks of every computation and citation; AI critics of at least three model families with hidden, rotated prompts; an expert reader, not the imitated human, judging located objections); verdicts cached on canonical claims; audits at β ≈ 0.1; outputs marked within the bound only while (ĉ+1) times the windowed rejection rate is at most 5%, with ĉ from per-kind planted-error tests; certification of a frozen deployment by independent solution of a random sample; and falsification by use wherever later work uses outputs.

**What only the cost needs.**
* **(A2)** for every problem. The human's own chain must finish within n₀ under the instruction.
  * *Heavy tails.* With n₀ at the 75th percentile of durations, (A2) fails on a quarter of problems. Of those, 6–11% of all problems are not finished even within n = 2n₀ (thread S, Part E), and VSI abstains on them. On the rest, searches may cost up to 2n each instead of 2n₀. Setting n₀ at a higher quantile, at a cost in compute, reduces both.
  * *The instruction's cost.* The heavy instruction (typed entries, reviews, decisions, the retry rule) inflates n₀ by about 1.2–1.6× (thread F). That is why it is optional, and the core keeps only what the verifier needs.
* **Bounded setback** (slack-imitation.md §3–4). It holds for the share of mistakes that fail loudly. What sets the cost is the share never recovered, β_nr: thread G's corollary turns it into a *guaranteed* gain over chained imitation of (1−ρ)/(β_nr + (D+1)/(σ+1)).
* **Recovery at reviews, (R-rev).** It holds for insights readable from raw records. It fails for insights that come only from doing (Theorem G3), and for readers with a hypothesis who miss planted anomalies (thread L).
* **Post-mortems.** Their value is measurable, and nothing rests on them. The second researcher writes them so that the imitated human's answers are not contaminated.
* **(L1).** A careful researcher's own entries follow from what they cite. A flagged step that is the human's own costs one query and teaches nothing false.

**The user's constraint.**
* *V-machine* rests correctness on no judgment of the runs. It rests on the fidelity of a statement fixed before any run, which experts and AI audits review. The optional "nothing bizarre" check is a human judgment of the final notebook, but it serves only the talk's second desideratum and the cost, and can be dropped.
* *V-human* assumes a check of the final state, which is a distinct, weaker assumption than an on-track check (note.md §5.4), but an assumption on which correctness rests.
* *V-cone with a human referee* uses a local, relative judgment of intermediate entries. It is not an on-track judgment, but its locating power comes from the human's own entries passing it, which is the first note's mechanism with "valid" in place of "fine" (thread S §5).

So the version that keeps both the letter and the spirit of the constraint is V-machine, and that is also the version I am most sure of.

## 7. How sure I am

"Works" means: on a real careful researcher, with projects of n₀ ≈ 20–40 steps, the output failure rate is at most 5%, and the total human effort is at most a fifth of chained imitation's. Effort counts task queries, verifications, post-mortems and audits, in task-step equivalents. The figures are conditional on the series' idealizations: determinism, a learner whose class contains the human, and a cold-start chain that succeeds within n₀. The first figure is for theory and software, the second for empirical work.

| scheme | correctness rests on | guarantee on task queries | draft | thread S | **final** |
|---|---|---|---|---|---|
| VSI, proof assistant on a formally stated goal, with the statement protocol and hardened checking | the reviewed statement and the checking pipeline | 2n₀K worst case | 85% | 70% | **70%** (thread T: about 60% without the protocol and hardening; 77% with the formalizer inside V, the human formalizing as a fallback, and the halt rules) |
| VSI, test suite | the tests | 2n₀K worst case | (85%) | 45% | **43%** (thread W) |
| VSI, referee cone check (V-cone) | L's soundness, the statement being the goal, correct records | 2n₀K, 1 per invalid cone entry | 70% / 30% | 45% / 10% | **45% / 10%** |
| VSI, human verifier (V-human) | the human's soundness, plus ε if imitated | 2n₀K, plus about one verification per problem | 65% / 30% | 40% / 10% | **35% / 10%** (thread W) |
| VSI, thread U's combined verifier (reader, use, machine checks, AI critics with located objections) | the combination's soundness; critics can only add rejections | 2n₀K, plus about 3 task steps of verification per problem in theory | – | – | **46%** informal theory (thread W); **60%** software without a full spec; **15% / 20%** empirical / judgment |
| VSI-R: a randomized pool, first-claim verification, a second judge, monitoring (thread Q2, corrected) | the pool's miss rate; Theorem 6′ adds monitoring | 2n₀K, plus about 3 task steps of verification per problem | – | – | **50%** informal theory; **60%** software; **15% / 20%** empirical / judgment |
| Proposition 7, no verifier | (B_D) at valid confident entries, (R-rev), (A-pers), (L2) | 3·max{d_max, n/c_r}·K/b_α failed runs online; with a retry rule of small r, that is about n per bit | 45% / 20% | 30% / 10% | **30% / 10%** |
| slack imitation with asking (fourth note) | (B_D) at confident steps | the same | 40% / 20% | 25% / 10% | **25% / 10%** |
| chained imitation (the talk) | nothing | n₀K/ε | baseline | baseline | baseline |

* *Why I adopted thread S's numbers.* Its arguments are the stronger ones:
  * human verifiers on the imitator's most plausible wrong answers;
  * p·w·f not decaying;
  * repeated verification;
  * the n₀ inflation from the instruction;
  * heavy tails.

  My draft compared bounds, not efforts, and left out verification and audit costs.
* *Worst-case effort.*
  * *Search queries.* With V-machine and no audits, VSI's guarantee is 2n₀K, against chained imitation's 20n₀K at ε = 5%: a factor 2 below the one-fifth bar.
  * *n₀ inflation.* The core's own inflation is modest. For the 70% row, thread T estimates that ending the chain with a formal proof has become much cheaper with AI formalization agents in 2025–26, for goals already statable.
    * *The factor-2 margin* is used up at a formal-proof multiplier ι = 2.
    * *Examples:* Fermat's Last Theorem was formalized in 11 days and sphere packing in about two weeks (thread T, from sources partly checked only through search summaries).
    * *Thread T's estimates* for mathematics, weighted by where goals are statable: P(the formal proof costs at most 1.5×, 2× or 3× the informal duration) ≈ 65%, 80% and 90%, varying by field.
    * *Counter-signals and selection.* The landmark cases are self-reported successes by well-resourced teams, formalizing decades-polished proofs, sometimes completing human projects. Only about 42% of some 720 AI-written manuscripts had Lean checks, and the best score on proving fresh research theorems was 17%.
  * *Per-problem statement writing* is another cost, from days with AI drafting to months (about 1.4 person-months each in the Annals effort). At the slower pace it caps T well below the search's bound.
    * *With the formalizer inside V,* most of this cost leaves the human's chain.
  * *With a human verifier,* audits at β = 1 and verifications add effort that grows with the number of problems T. VSI then meets the bar only for T up to about 40–55K (referee 7, Part 6), and for fewer with heavy tails.
* *The V-human row* uses thread S's figure for an *imitated* human verifier. A human verifying every output should be at least as sure, at about one verification per problem.
* *The human-does-it baseline.* For T distinct problems the human alone spends n₀T. VSI's worst case beats it only if 2K < T, that is, if the problems share most of what must be learned. That is the regime of the original question, "performance on lots and lots of problems".
* *Abstentions and heavy tails.* "Works" counts an abstention as effort, about n task queries, not as a failure. The conditioning on the human's chain succeeding within n₀ means the informal goal, so heavy tails and a formalizer's false rejections are counted as abstentions. The formalizer-inside-V figure assumes thread T's fallback to the human formalizing. Heavy tails lower the unconditioned figures.
* *Without the idealizations,* every row falls. VSI with a machine verifier falls least, because its correctness survives non-determinism and non-realizability. Only its cost theory breaks.

## 8. Experiments

All are exact-Bayes, on small classes, with 20–40 humans per cell. They test how cost scales with n and with the kind of human, not whether real humans have the properties.

* **E6** ([`slack-imitation.md`](slack-imitation.md) §6). Task queries until at most 2% of runs fail, on the same humans, for n₀ = 8 → 32 → 128:
  * *chained imitation:* 2,915 → 12,724 → 51,365 for noticing humans;
  * *slack imitation:* 160–490 at n₀ = 8, then 204–227;
  * *fooled humans:* 1,631 → 2,811 → 4,296;
  * *silent humans:* slack doubles the cost.

  With a verifier and uniform search, bounded-setback humans need 13–16 task queries for all 100 problems (38 for misled-8 at n₀ = 8).
* **EQ** (thread Q §8). The search on E6's humans, in total task queries for 100 problems:
  * *fooled humans:* 181 → 750 → 2,636 under uniform search; 40 → 55 → 54 with the three streams at equal weights; 53 → 73 → 72 with the default schedule S, U, S, H (referee 7's re-run, [`verification/referee7_eq_default.out`](verification/referee7_eq_default.out));
  * *silent humans:* 1,610 → 6,450 → 26,091; 663 → 2,497 → 9,734 at equal weights; 559 → 2,103 → 8,238 with the default schedule;
  * *the price of the sure 2n₀:*
    * bounded-setback humans pay up to 1.45× uniform search at equal weights, and up to 2.3× with the default schedule (25–44 task queries for 100 problems, against 13–38);
    * an adversarial list costs at most 1.64× at equal weights.
* **G1** (thread G §7). Doing-only by-product insights cost every protocol in proportion to the routine work, as Theorem G3 says. Readable insights with reviews and last-review queries cost 285–310 task queries at every size.
* **F1** (thread F §8):
  * *checkable wrong claims:* slack imitation and asking at α = 0.3 grow with n (260–300 → 1,200 failed runs); the local check stays at 9–11, and checking before committing at 0;
  * *false negatives followed by a valid weaker result:* they grow with n under every protocol at α = 0.3, and vanish at α = 0.05 at 7–16 asks per problem; the retry rule with r = 2 or 3 divides them by 3–4.
* **E7, composition** (thread R, [`research/threadR-compose.md`](research/threadR-compose.md)). Eight failure mechanisms, each one exact-Bayes class, at n₀ = 8 → 32 → 128 (routine length N for M4 and M5). Columns:
  * *SI* and *SI-ABC+D:* failed runs over 4·M·n online rounds;
  * *SI-V* and *VSI:* total task queries to solve all 100 problems, with every output correct.

  *How E7 differs from §2.3:*
  * VSI searches with equal weights over its three streams (thread Q's EQ), not with the default schedule;
  * its list holds verdict and claim entries, which stand in for a *perfect* second-researcher post-mortem;
  * SI-ABC+D asks at every unconfident step (α = 0.3) and queries the flagged entry, else the review or decision step with probability ½;
  * each class has M = 100 problems.

  | mechanism | SI: failed runs | SI-ABC+D: failed runs | SI-V: task queries | VSI: task queries |
  |---|---|---|---|---|
  | M1 persistent idea, noticing human | 12.5 → 14.5 → 14.3 | 1.7 → 0.8 → 0.3 | 13 → 14 → 14 | 15 → 20 → 20 |
  | M2 fooled commission at a verdict | 114 → 245 → 436 | 16 → 17 → 47 | 181 → 750 → 2,636 | 40 → 55 → 54 |
  | M3 silent human | 1,428 → 6,304 → 25,629 | 1,032 → 5,908 → 25,407 | 1,610 → 6,450 → 26,091 | 663 → 2,497 → 9,734 |
  | M4 readable by-product, with reviews | 227 → 309 → 331 | 0 → 32 → 36 | 221 → 288 → 338 | 122 → 129 → 137 |
  | M5 doing-only by-product | 979 → 3,930 → 15,622 | 1,662 → 6,957 → 28,603 | 1,029 → 3,795 → 16,127 | 424 → 1,528 → 6,246 |
  | M6 pre-empting hedge at a decision | 73 → 329 → 1,239 | 17 → 19 → 20 | 76 → 315 → 1,439 | 24 → 29 → 31 |
  | M7 invalid checkable claim | 139 → 693 → 2,635 | 9.5 → 10.8 → 10.2 | 136 → 582 → 2,868 | 10 → 11 → 10 |
  | M8 false negative as a valid obstruction | 139 → 693 → 2,635 | 152 → 710 → 2,408 | 136 → 582 → 2,868 | 34 → 33 → 31 |

  * *Each mechanism has its component.*
    * M1: slack;
    * M2: the verifier with the verdict-step pointer, or asking without a verifier, which E6's prior flatters;
    * M4: the last-review query;
    * M6: the decision-step query;
    * M7: the local check;
    * M8: only the verifier's pointer. Without a verifier nothing helps, as Theorem F3 says.
  * *M3 and M5 grow with n₀ under every protocol,* as the lower bounds say (Theorems 3 of note.md and G3). VSI cuts them by the scan, at about 0.8n₀ per rejection.
  * *Interference.*
    * VSI's extra streams cost M1 humans 1.2–1.4× at equal weights, and 2.0–2.3× with the default schedule.
    * Without a verifier (SI+D), the last-review query costs doing-only humans (M5) 1.7–2.1×, because there a review is never the mistake. Inside VSI it costs at most one query per search.
    * Asking on top of VSI costs 5–35× on M1, M2, M7 and M8, which is why asking is optional with a verifier.
  * *What is reproduced.* All 120 regenerable published numbers (E6, EQ, referee 5's online test, G1 and F1) match exactly.
  * *The caveat: the pointer.* M6's decision step is in §2.3's list, so M6 is genuinely covered. M2's and M8's pointers exist only through post-mortems.
  * *Without post-mortems.* Referee 8 re-ran VSI with the default schedule and §2.3's list without post-mortems ([`verification/referee8_e7_default.out`](verification/referee8_e7_default.out)):
    * M2 costs 89 → 427 → 1,442 and M8 51 → 452 → 2,350, growing roughly with n₀, though within the sure 2n₀ per rejection and still below SI-V;
    * the other mechanisms cost 1.3–1.6× E7's figures, except M3 and M5 (0.84×) and M7;
    * the scan cuts M3 and M5 at 0.64–0.70n₀ per rejection.

    So "M8: only the verifier's pointer" means a perfect post-mortem, which is the hindsight that Theorem F3 says is needed.
  * *Status.* E7, thread T and thread U are unrefereed drafts. Referee 8 checked every E7 number, and checked thread T as quoted here.

## 9. Trees

Thread N extends slack to decomposition trees: extra rounds per call, with setback measured in the parent's rounds.
* *Depth-weighted queries* give at most Ψ·K failed runs, with Ψ < 2((D+1)/ρ)^(d+1)·b^d for depth d and b subquestions per round, when b(D+1) ≥ 2ρ [proved].
* *The factor b^d* is necessary without more structure, since nothing in the run says which subanswer is wrong [proved by reduction, written out in outline].
* *Parents that name the subanswers they reject* remove it [sketch, checked numerically].
* *A verifier at every node* that is sound and complete gives at most K rejections, each found with at most 1 + min{r, (D+1)r/(s+1)} task queries in expectation; the second term needs bounded setback within a call. Here r is a call's number of rounds and s its slack. This does not depend on the tree's size [proved], but thread Y found that it needs thread N's (Budget) on corrupted transcripts.

**Formal blueprints (thread Y, [`research/threadY-formal-trees.md`](research/threadY-formal-trees.md)).** When the human works as a blueprint (isolated calls whose questions are Lean statements, with proof irrelevance: the parent sees only each lemma's record, proved, disproved or open), the kernel supplies a sound and complete verifier at every node.
* *Assumption* (A2-tree), about the human's own tree only: every call of it proves its statement within r₀ rounds.
* *Search:* at a failing call, scan its rounds from the start; after a round that posed a lemma not proved, descend into the first such lemma. A mistake-free prefix certifies that the lemma is the human's own.
* *Theorem Y1 [proved; referee 10 checked it].* At most K/b rejections, each costing surely at most Σ_ℓ π_ℓ + t* ≤ p·d + r₀ task queries, where π_ℓ is the round in which the human poses the path's next lemma, p the latest such round, and d the depth. For a human who plans first, d + r₀. This does not depend on slack, tree size or the number of problems. Correctness rests on the root statement, the kernel and a final check of the assembled development; misformalized intermediate lemmas cannot cause wrong outputs. Records must be produced by the same hardened check as the final one (the paper's second referee found that otherwise a final-check rejection need not end in a hit), and a final-check failure then halts for scaffold review. A query here is one round of work, about a working day, so K is the complexity of the round-level program.
* *Necessity [sketch].* Ω((p·d + r₀)K/log) task queries are needed on a class satisfying all these assumptions, even with zero setback inside calls.
* *Abandoned lemmas [proved].* With abandonment only by Lean disproof, the theorem holds verbatim with "decided" for "proved". With too-hard abandonment, add A, the human's own abandoned work off the search path; this needs that the run never proves a lemma the human abandons, and without that, interleaving with a depth-first scan caps the cost at twice the chain scan.
* *Numbers.* In a toy with exact Bayes, 6.7–17 task queries per rejection, against 120–351 for the chain scan. With a round of a working day, thread Y estimates p·d + r₀ ≈ 7–45 days per rejection for blueprints like Carleson's (179 lemmas, 28 contributors, statements formalized first, lemmas proved from local statements).
* *Probability* (thread Y): about 45% (55% and 31%, averaged and rounded up) that a careful mathematician following the blueprint instruction gets output failure ≤ 5% and at most 3(p·d + r₀)K task queries, conditional on the idealizations; 55% for formalization-style work, 35% for new research.

**Informal blueprints (thread Y2, [`research/threadY2-informal-blueprints.md`](research/threadY2-informal-blueprints.md)).** With a fallible node verifier N (for example a VSI-R pool), the blueprint search's cost bound survives if N's verdicts are a fixed function of the claim (cached, seeded by a hash of the claim) and the root verifier V names the claim it objects to. A *repair-first* rule (when V names a claim and a second judge upholds the objection, overwrite N's cached verdict with "fail" and rerun, with no task query) gives at most (p·d + r₀ + D·φ_max)·K/b task queries [proved], where φ counts N's false fails on the human's own claims in a call. In thread Y2's toy, 6.3–6.8 task queries per hit at node error rates of 0–30%, against 115–120 for the chain scan. Probability of meeting output failure ≤ 5% and ≤ 3(p·d + r₀)K in informal theory: about 15%; about 40% under the weaker "works", no better than chain VSI-R.

## 10. What to measure first

None of these needs a learner.
1. **The verifier's miss rate f** on imitator-style wrong claimed solutions:
   * in the researcher's own style, against a colleague's;
   * read, against used (tested on cases);
   * the same wrong claim re-verified under different presentations.

   For machine verifiers, measure the misformalization rate.
2. **p·w.** The share of an imitator's failed research runs that end with a confident claimed solution.
3. **The duration tail** of the human's own cold-start chain under the instruction.
4. **Contamination.** Task answers given right after a post-mortem, a verification or a check of the same run, against fresh answers, and answers to out-of-order queries.
5. **Post-mortem accuracy, by the second researcher, and setbacks** (slack-imitation.md §4): planted culprits, especially recorded dead ends.
6. **For formal verifiers** (thread T §5.4):
   * planted statement defects, run through the statement protocol;
   * the formalizer's false-rejection rate on correct human blueprints;
   * the formal-proof multiplier ι in the field at hand.

## 10b. Beyond the idealizations (paper §10)

* *Beyond realizability* (the paper's Proposition 10.1, my own, unrefereed except by the final read-through). With a weighted-majority learner (penalty β) in place of exact Bayes, and a deterministic human not necessarily in the class: if some hypothesis h mislabels at most a fraction ε_h of the notebooks VSI queries, the rejections number at most (K_h + ε_h·c₂·A)/(c₁ − 2n₀ε_h·c₂), with c₁ = log₂(2/(1+β)), c₂ = log₂(1/β) and A the audits. At β = ½ with no audits, R ≤ K_h/(0.41 − 2n₀ε_h), which needs ε_h < 0.2/n₀. Lemma 1 needs only determinism and (A3′), so each search still costs at most 2n₀.
* *Beyond determinism* (thread Z, [`research/threadZ-stochastic-human.md`](research/threadZ-stochastic-human.md)). Correctness is unchanged.
  * Stochastic style that canonicalization removes: everything transfers to the content map.
  * Occasional deviations at rate δ < ½: a disagreeing query is worth 1 − h(δ) bits in expectation; mode decoding with one ask at each of the run's first n₀ notebooks per rejection gives E[rejections] ≤ K/(1 − h(δ)). It needs memoryless re-asks and a dominant choice at each query.
  * No dominant choice: decoder-based protocols need Ω(T) queries or abstentions, and verified outputs carry Ω(T) bits of selection against the unconditioned human.
  * VSI-D: posterior-sample a whole hypothesis, run it up to m times, and on failure have the human work the problem (a demonstration). E[demonstrations] ≤ (ln 2/2)K/((1−θ)²s²) + Σ_t(1 − θs)^m, each at most n queries; an output raises any hypothesis's odds against the human's by at most 1/s.
  * Thread Z's estimate: about 45% unconditional for the formal row (against 40%), about 60% conditional on realizability alone.

## 11. Limits

* *Idealizations.* Determinism, exact Bayes over a class containing the human, and cold-start chains. Thread L finds experts noisy, with about 90% repeatability on categorical decisions and far less on open-ended work. VSI's correctness survives these with a machine verifier, but its cost theory does not.
* *The domain.* VSI needs a crisp success criterion S_V, fixed in advance and preserved by appending. Multi-year research often has no such goal: its value is a new question or definition found along the way. VSI imitates the well-posed part of research.
  * *How narrow, for mathematics.* In 10 months, working easiest first, experts stated 24% of recent Annals main theorems in Lean (thread T). Some areas were judged essentially impossible to state today.
  * *Overall.* Thread T guesses that 5–15% of multi-year mathematics projects are in the domain of the 70% row today, and a few percent of all valuable research.
  * *Software specifications misformalize too:* 80 of 161 reference specifications in one verified-code benchmark were arguably wrong.
* *Verification cost.* If verifying costs nearly as much as doing, VSI saves little over the human doing every problem.
* *Memory.* A real human remembers earlier queries.
  * *Out-of-order queries.* The scan queries in order, but the uniform stream and the list do not, so some "future" leaks into the human's answers.
  * *Reading the run first.* So does having verified, refereed or checked the run.
  * *Mitigations.* Every multi-query protocol shares this. It is the reason for the scan-heavy default, for having readers other than the imitated human, and for measurement 4.
* *Heavy-tailed research times.* They make (A2) fail on some problems; see Section 6.

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
| no optimization pressure, bits of selection, malign coalitions, formalizer isolation | thread V ([`research/threadV-humanlike.md`](research/threadV-humanlike.md)) |
| no total blind spot (Theorem 6′), falsification by use, VSI-R, corrected estimates for human verifiers | thread Q2 ([`research/threadQ2-freshlook.md`](research/threadQ2-freshlook.md)) |
| how often failed runs end with a confident claim (w) | thread W ([`research/threadW-confident-failures.md`](research/threadW-confident-failures.md)) |
| formal blueprint trees: own-tree search, (p·d + r₀)K/b | thread Y ([`research/threadY-formal-trees.md`](research/threadY-formal-trees.md)) |
| a non-deterministic human: canonical style, deviations, VSI-D | thread Z ([`research/threadZ-stochastic-human.md`](research/threadZ-stochastic-human.md)) |
| informal blueprints, fallible node verifiers, repair first | thread Y2 ([`research/threadY2-informal-blueprints.md`](research/threadY2-informal-blueprints.md)) |
| calibration of the machine verifier: misformalization, formalization cost, kernel soundness, domain | thread T ([`research/threadT-formal.md`](research/threadT-formal.md)) |
| verifiers without a machine: combined protocols, correlated misses, AI critics | thread U ([`research/threadU-nonformal.md`](research/threadU-nonformal.md)) |
| checks, literature, elicitation, persistence | threads A, D, B, C |

## 13. Open

1. A stochastic human: what replaces the bit per mistake of Lemma 1 of note.md, and "an empty step is a delay"?
2. An agnostic version, in which no hypothesis computes the human exactly.
3. The measurements of Section 10.
4. Whether the per-level factor ((D+1)/ρ)^d for trees is necessary (thread N).
5. Whether location protocols that achieve L (thread J) can be run without knowing the hypothesis class's mistake sets.
6. A deployment theorem for Proposition 7's query mixture.
