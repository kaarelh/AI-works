# Verified slack imitation: the scheme I am most sure of

*Research note by Claude (Anthropic), the fifth in this folder, version 3 of the answer to "which scheme are you most sure would work with a deterministic human?".*
* *What it builds on.* It uses the theorems of the fourth note, [`slack-imitation.md`](slack-imitation.md) (version 2), and synthesizes eleven research threads, listed in Section 10. Their reports are in [`research/`](research/) on the working branch.
* *Status.* Draft. The proofs of the main results are given here; the lower bounds are stated with sketches, and their full proofs are in the thread reports.

## The question

The request: *keep trying threads, and report the scheme you are most sure would actually work with a deterministic human. Ideally, give a proof that the scheme works if the program has such and such properties, and a case that humans in fact have them.* The constraint from earlier in the conversation: no assumption that the human can check whether a run "has gone off track".

## Answers in brief

1. **The scheme: verified slack imitation (VSI).** It is slack imitation, the fourth note's scheme, plus a verifier of the finished result. Each problem is rerun until its result is verified, and a rejected run is searched for a mistake by several sources at once.
   * *The scaffold.* An append-only notebook of typed entries, with a hidden clock and slack (n = n₀ + σ steps when the human needs n₀). The instruction, which is part of the reference chain too, asks for:
     * certified claims;
     * obstruction records instead of verdicts;
     * raw records;
     * content-triggered reviews;
     * labelled decisions.
   * *The questions to the human:*
     * task steps where the imitator is unsure (ask-before-committing, optional);
     * on a rejected run, task steps chosen by the search;
     * after a failure, a post-mortem list ("which entries would you re-examine first?"), used only as a hint;
     * the verification itself, if no machine can do it. The human's verdicts can be imitated, so that only about K_V/ε of them are needed.
2. **The main theorem** (Theorem 5).
   * *Correctness.* Assume the verifier never passes a wrong result. Then no failed run is ever output, whatever the human's setbacks. No assumption about how the human reacts to the imitator's notebooks is used for correctness.
   * *Rejections.* At most K of them (K = K(human)), on every path.
   * *The search.* Each rejection costs at most 3n₀ task queries whatever the human. It costs 1 if the cone check finds an invalid entry, and at most 3·(D+1)n/(σ+1) under bounded setback. It costs a small constant when the last review, a labelled decision or an early post-mortem entry is the mistake.
   * *Totals.* Task queries are at most 3n₀K in the worst case, and O(K) when setbacks are mostly bounded or the pointers work. Neither has a factor 1/ε, and neither depends on the number of problems, apart from the optional audits (β per problem), which only matter if the verifier may be unsound.
3. **Why this is the scheme I am most sure of.**
   * *Correctness rests on one judgment,* that of a finished product. With a machine verifier (a proof assistant, a test suite against a specification) there is no human judgment at all. With a referee it is a *local* check: does each entry of the claimed solution's dependency cone follow from what it cites? Neither is an on-track judgment.
   * *Every assumption about how humans react* to the imitator's notebooks (bounded setback, recovery at reviews, useful post-mortems) affects only the cost.
   * *The worst-case cost is near optimal.* 3n₀K is within a logarithm of the lower bound that holds even with a perfect verifier (Theorem Q1, Section 4).
4. **Without a verifier,** the best I have is slack imitation with ask-before-committing and the design elements (Proposition 7). Its guarantee needs bounded setback at confident, valid entries, recovery at reviews, and (A-pers) for retried approaches. I am much less sure of it.
5. **What no scheme can do** (Section 4; proved in the threads):
   * *Slack imitation is optimal* for humans with bounded setback, up to logarithms and a factor 1/(1−ρ), and slack is necessary (thread J).
   * *Verifying the result removes the 1/ε but not the n* on silent humans (thread Q).
   * *Insights triggered only by doing a piece of work oneself* cost every protocol about n per insight, whatever the scaffold (thread G).
   * *A trusted true record of a failed attempt* (thread F), *and a confident commission accepted by a fooled human* (thread J), cost every task-only protocol about n per occurrence.

   In VSI all of these cost only queries, never correctness.
6. **How sure I am** (Section 6). Probability that the scheme *works* on a real careful researcher, meaning output failure at most 5% on projects of 20–40 steps, at under a fifth of chained imitation's human effort:
   * *VSI with a machine verifier of the actual goal:* 85% for theory and software;
   * *VSI with a referee checking the solution's cone:* 70%;
   * *VSI with a human verifier of the final result:* 65% for theory and software, 30% for empirical work;
   * *slack imitation with asking and the design elements, no verifier:* 45% for theory, 20% for empirical work.

   That task queries are truly O(K), with neither n₀ nor 1/ε, I put at about 45% for VSI in theoretical work. The worst case, 3n₀K, is a theorem.
7. **The evidence** (thread L): real setbacks look bimodal. An error is caught at review or first use, or only after a year or more, or never. So, without a verifier, what matters is the fraction of mistakes never recovered, not the size of D. That is the main reason the verifier version is the one I am sure of.
8. **What to measure first** (Section 9): the verifier's false acceptances on imitator-style wrong results; whether post-mortem lists contain planted culprits; and planted-entry setback tests, especially recorded dead ends.

## 1. Setting

As in [`slack-imitation.md`](slack-imitation.md) §1.
* *The human and the learner.* The human is a deterministic program P. The learner is Bayes over a hypothesis class containing P, with the majority decoder.
* *K.* K = log₂(1/w(P)). By thread H's Proposition H2, every result below except those involving asks also holds for any online learner whose log-loss regret against P is at most R, with K replaced by R; the results involving asks need, in addition, a learner whose predictions depend only on the set of data. So K can be the human's description length in whatever class the learner uses, for example given a corpus, provided the class contains P exactly.
* *Notation.*
  * Mistakes, the potential Φ (with Φ ≤ K at the start and Φ ≥ 0 always), Lemma 1 of note.md (a task query on a majority-decoder mistake lowers Φ by at least 1), and Theorem 1 of without-a-check.md: as there.
  * τ(y) is the human's own remaining time from notebook y.
  * (T1), (T2), bounded setback (B_D) and Lemma S are from slack-imitation.md §3.
  * Λ = min{n, (D+1)n/(σ+1)}.
  * b_α = max{1, log₂(1/α)}, with α = 1 meaning no asks.

## 2. The scheme

### 2.1 The notebook and the instruction

The instruction is part of the problem statement. So it holds in the human's own reference chain as well as in the imitator's runs, which keeps the design law of thread E: a correct imitator step reproduces the human's step exactly.

* **Append-only, typed entries** (thread F, §1):
  * *C, a certified claim:* a statement with a proof, or code with its machine record, citing the entries it relies on;
  * *O, an obstruction record:* "attempt at A: partial work; stopped at gap Z", never a verdict "A fails";
  * *S, a suggestion:* plans and judgments, marked as such;
  * *R, a machine record:* output of code or of a proof checker, or a retrieved source, appended by the scaffold in both chains.

  Later work may rely only on C, R and partial work (thread F's discipline Δ).
* **Raw records** rather than summaries, for anything computed or observed (thread G, §4).
* **Content-triggered reviews.** After every L_rev work steps, reread every raw record and record anything surprising (thread G, Theorem G4).
* **Labelled decisions.** Choices of direction or default are separate, labelled entries (thread G, Proposition G7).
* **Optional retry rule.** An approach may be set aside only after r obstruction records written at different steps (thread F, Theorem F4).
* **The hidden clock.** No step numbers, dates or deadlines appear in the notebook, and the scaffold strips them.
* **Slack.** The imitator runs n = n₀ + σ steps, where n₀ is a number of steps in which the human's own chain, under this instruction, solves the problem.

### 2.2 The verifier

Success S is a property of the final notebook that appending preserves. A verifier V decides it, in one of three ways:
* **(V-machine)** a machine check of the actual goal: a proof assistant on the claimed theorem, a test suite against a specification;
* **(V-cone)** the *cone check* of thread F's Proposition F5. S(y) means that y contains a claimed solution whose dependency cone (the claim and, recursively, everything it cites) passes a local check L: does each entry follow from what it cites? L may be a proof checker, or a referee checking one entry at a time;
* **(V-human)** the human's verification of the finished notebook ("does this solve the problem?"), imitated as in Theorem 6.

### 2.3 Protocol VSI(α, β, s)

For each problem, repeat until the problem's run is accepted:
1. **Run.** Build a run of n steps. Wherever the imitator's top label has posterior mass below 1 − α, ask the human for that step instead, and add the answer to the data at once.
2. **Verify.** Apply V to the final notebook.
3. **If accepted,** output the run. With probability β, also task-query one uniformly chosen committed step (an *audit*) and add the answer.
4. **If rejected,** look for a mistake:
   * *(i) An invalid entry.* If L flags an invalid committed entry (with V-cone, or if L is available), task-query that step.
   * *(ii) Otherwise, search.* Take queries from three streams in turn, each over committed steps, until one lands on a mistake:
     * **U:** a uniformly random committed step;
     * **S:** the next committed step in a scan from step 0;
     * **H:** the next entry of a list fixed at the start of the search: the last review step, then the labelled decision steps, then the steps of the entries in the human's post-mortem list of at most s entries ("this project failed; here is a colleague's notebook; which entries would you re-examine first?").
   * *Data.* Add the hit's answer first and the others after it, then rerun.

## 3. Theorems

**Assumptions.**
* **(A1)** P is deterministic, and the learner is Bayes over a class containing P.
* **(A2)** S is preserved by appending, and τ(x₀) ≤ n₀ for every problem.
* **(A3) Completeness.** V accepts every final notebook that satisfies S.
* **(A4) Soundness.** V accepts no final notebook of an imitator run that fails S.
* **(L1) Self-validity**, needed only when L is used. Every entry the human appends passes L.

**Lemma 1 (the first mistake comes early; thread Q, Lemma Q3).** Under (A2) and (A3), every rejected run has a committed mistake at a step below n₀.

*Proof.* If every committed step below n₀ is correct, then every step below n₀ appends the human's own entries, since asked steps are the human's. So the notebook at n₀ is the human's own, which satisfies S by (A2). Appending preserves S, so the final notebook satisfies S, and V accepts it by (A3). ∎

**Lemma 2 (every invalid entry is a mistake; thread F, Lemma F1).** Under (L1), a committed step that appends an entry failing L is a mistake.

*Proof.* By (L1) every entry of the human's step passes L, so the two steps differ. ∎

**Lemma 3 (hints are free of risk; thread Q, Lemma Q2).** Fix a rejected run with committed mistake set M ≠ ∅. Search it with r streams in turn. Each stream is either uniform over committed steps, drawn with replacement, or a list fixed when the search starts, written by anyone, adversaries included. Then:
* every answer added is the human's own step;
* E[queries] ≤ r·min{n/|M|, j₁, j₂, …}, where j_i is the position of the first mistake in list i (∞ if none).

*Proof.* Each stream is served at least once in every r queries. A list stream reaches its first mistake within r·j_i queries. The uniform stream's draws succeed independently with probability at least |M|/n. The search stops at the first hit of any stream, and E[min(a, rG)] ≤ min(a, r·E[G]) for G geometric. ∎

**Lemma 4 (ripe failures; thread G, Theorem G4 and Proposition G7).**
* *A by-product-ripe failure* is a failed run that lost a by-product insight satisfying thread G's (Rec1)–(Rec3) before its last review. Under the review assumption (R-rev) of thread G (a review that rereads the raw records recovers such an insight), its last review step is a mistake.
* *A hedge failure* is one in which a default was adopted at a labelled decision while the human's idea was available. Its decision step is a mistake.

*Proof.* See thread G §4–5. At the last review the human would write the insight and the imitator does not, or it would be in the final notebook. At the decision step the human would write its idea and the imitator writes the default. ∎

**Theorem 5 (verified slack imitation).** Assume (A1)–(A3), and (L1) if L is used. For every sequence of problems, chosen adaptively:
* **(a) Correctness.** Under (A4), every output satisfies S.
* **(b) Counts.** On every path there are at most K/log₂(1/(1−α)) asks. Almost surely, rejections and audit hits together number at most K/b_α.
* **(c) The cost of one rejection.** If L flags an invalid committed entry, the rejection costs one task query. Otherwise its expected number of search queries is at most 3·min{n/|M|, n₀, j_H}, where j_H is the position in list H of the first mistake. In particular it is at most:
  * 3n₀, always;
  * 3Λ, under (B_D) at committed mistakes;
  * 3, for a by-product-ripe failure under (R-rev);
  * 3·(1 + d), for a hedge failure, where d is the number of labelled decisions;
  * 3·(1 + d + i), if the i-th post-mortem entry is a mistake.
* **(d) Totals.** E[task queries] ≤ K/log₂(1/(1−α)) + (K/b_α)·3·min{n₀, Λ} + β·(number of problems), and better when the cheaper cases of (c) apply.
* **(e) Without (A4).** The failed outputs are exactly the failed runs that V accepts. Under (B_D) at their committed mistakes, E[#failed outputs] ≤ K/(b_α·β·γ), with γ = max{1, (σ+1)/(D+1)}/n.

*Proof.*
* *(a)* is immediate from (A4).
* *(b).*
  * *Asks:* as in slack-imitation.md, Proposition 5(a).
  * *A rejected run has a committed mistake,* by Lemma 1. So the search ends almost surely, with a hit at a committed step k.
  * *The hit's value.* List the data of the round as: the asks before k, then the hit, then everything else. W depends only on the set of data, so this order gives the same total. The imitator committed at step k with top mass at least 1 − α under exactly the data before the hit. So the human's answer has mass at most min{α, ½}, and the hit lowers Φ by at least b_α. Audit hits are the same.
  * *The count.* Φ ≤ K at the start and Φ ≥ 0, which gives the bound.
* *(c).* An invalid committed entry marks a mistake by Lemma 2. Otherwise apply Lemma 3 with r = 3:
  * the scan's first mistake is below n₀ by Lemma 1;
  * the uniform stream gives n/|M|, and |M| ≥ max{1, (σ+1)/(D+1)} under (B_D) by Lemma S;
  * list H gives j_H, which Lemma 4 bounds for ripe and hedge failures.
* *(d)* sums (b) and (c) by Wald's identity, since the number of searches is bounded on every path.
* *(e).* The run and V's verdict are fixed before the audit's coin. An audit of a failed accepted run hits with probability at least γ by Lemma S, and each hit is counted in (b). ∎

**Remarks on Theorem 5.**
* *What moved.* In slack imitation without a verifier, confident commissions, lost insights and trusted dead ends decide correctness. In VSI they decide only cost: at most 3n₀ per rejection, and at most K rejections.
* *Asks are optional.* With a verifier, asking changes only the cost. In E6 it multiplied the cost for bounded-setback humans by 6–23 (referee 5), while the H stream handled fooled commissions more cheaply (thread Q's EQ). So the default is α = 1, no asks, and asking is turned on only if pointers prove poor.
* *What the post-mortem asks of the human.* Hindsight on a notebook framed as a colleague's, knowing it failed. It is a hint: its answers are never added as data, and a useless or adversarial list costs at most a factor 3 (Lemma 3).

**Theorem 6 (imitating the verifier; thread Q, Theorem Q5).** Let V_H be the human's verification, a one-step deterministic function on final notebooks, and K_V its code length (or its residual after the task data).
* *Protocol.* Keep a Bayes posterior over V_H, and let V′ be its majority decoder. On each final notebook y:
  * if V′ rejects, ask V_H(y);
  * if V′ accepts, ask V_H(y) with probability β.

  Add every answer to the verifier's data. A notebook counts as accepted if V_H accepted it, or if V′ accepted it and V_H was not asked.

Then, for any T notebooks chosen adaptively:
* (a) V′ disagrees with an asked V_H at most K_V times;
* (b) the expected number of notebooks accepted by V′ unasked that V_H would reject is at most (1−β)K_V/β;
* (c) the human verifies at most βT + R + K_V notebooks, where R is the number of true rejections.

With β = K_V/(εT), this means about K_V/ε + R + K_V verifications, for any number of problems.

*Proof.*
* (a) is Lemma 1 for a one-step function.
* (b) On a false acceptance by V′, an audit lands on a mistake of V′, and by (a) there are at most K_V such hits. So β·E[#false acceptances] ≤ K_V.
* (c) A rejection by V′ is either a true rejection or a mistake of V′. ∎

*Why the verifier can be imitated and the search cannot.* A verifier judges the object it is shown, so learning it has horizon 1: no compounding and no location problem. A pointer is useful exactly where it knows what the posterior does not. An imitated pointer is a task-only rule, and the lower bounds of Section 4 apply to it.

**Proposition 7 (without a verifier: slack imitation with the design elements).** Each round runs the imitator with asks, then queries:
* any step whose entry L flags as invalid, if there is one;
* otherwise, with probability ⅓ each: the last review step, a uniformly chosen labelled decision step, or a uniform committed step.

If a run has no review, or no labelled decision, that third goes to the uniform query. Assume (A1), (A2), (L1), (R-rev), the retry rule with (A-pers) (thread F, Theorem F4), and (B_D) at committed, valid mistakes elsewhere. Write c_r = min{max{1, (σ+1)/(D+1)}, r}. Then

  E[#runs with an invalid entry] + ⅓·E[#ripe failures] + (1/(3d))·E[#hedge failures] + (c_r/(3n))·E[#other failed runs] ≤ K/b_α.

*Proof.* Each kind of failed run has a mistake that the round's query distribution finds with the stated probability:
* an invalid run, by Lemma 2;
* a ripe or hedge failure, by Lemma 4;
* any other failure, by Lemma S and Theorem F4, with at least c_r mistakes.

Then apply the counting of (b) above, which is the argument of Theorem 1 of without-a-check.md with each hit worth b_α. ∎

*Deployment.* Thread H's Theorem H1 gives the i.i.d. version for an imitator that asks: end an epoch also at the first unconfident step of a run. The frozen output's runs are confident throughout and successful with probability at least 1 − ε, at O((K/α + K)·(D+1)·log(K/(αδ))/(ρε)) task queries.

## 4. What no scheme can do

Each statement is a theorem in the thread named, with the proof sketched here. "Task-only" means asking the human only for task steps, at any states, synthetic ones included, adaptively. Every lower bound below also covers asks.

* **Slack imitation is optimal for bounded-setback humans** (thread J, Theorem J1).
  * *The result.* For all n, ρ, D ≤ n₀/2 and ε, there is a class whose humans have setback exactly D on every notebook. On it every task-only protocol needs Ω((1−ρ)·Λ·K/(ε log(n/ε))) task queries, and Ω((1−ρ)ΛK/log n) failed runs online.
  * *The sketch.* A missed insight wastes its own step and the next D, and leaves no trace. A query reveals it only inside a window of D+1 steps, so each query is a point query on about n/(D+1) candidate windows.
* **Slack is necessary** (thread J, Corollary J2). The same class with σ = 0 and D = 0 still forces the factor n.
* **Location numbers** (thread J, Theorem J3).
  * *The upper bound.* Querying steps by an optimal fractional hitting set of the failing hypotheses' mistake sets gives at most L·K failed runs, where L is the hitting set's size.
  * *Where it is small.* On thread C's CHAIN class L = 1, even without slack.
  * *The matching lower bound* holds on hiding product classes. The "iff" uses L, not mistake mass.
* **Verification removes the 1/ε, not the n** (thread Q, Theorem Q1). On the silent hidden-insight class, with any number of verifications, a protocol needs Ω(nK/log(nq)) task queries. The sketch: a verification says *whether* a problem hides an insight, not *where*. So VSI's worst case, 3n₀K, is optimal up to the logarithm and the constant.
* **Insights triggered by doing** (thread G, Theorem G3). Suppose an insight is triggered only by doing one particular unit of routine work, chosen unpredictably. Then every protocol, under any scaffold, must have the human itself process about a quarter of all the routine work. Each human step can test at most the units it processes.
* **Trusted true records** (thread F, Theorem F3). Suppose the humans recover from every omission and every invalid entry, and only never retry an approach with a recorded obstruction. Then every protocol using task queries and local checks needs Ω(n₀K/(ε log(n₀/ε))).
* **Fooled confident commissions** (thread J, Theorem J6). Confident commissions accepted by a fooled human at unpredictable steps cost every task-only protocol Ω(n) queries per deviation.
* **Committees, redundant runs and posterior sampling** (thread Q, Proposition Q6) are task-only rules. At a confident step they disagree with probability at most k times the doubt, so they are a noisy form of asking and cannot find confident silent omissions.

**What this says.** For unpredictable, problem-specific contributions, location comes from four places only:
* the human's recovery (slack under bounded setback);
* the human's hindsight (post-mortems);
* structure: the first mistake comes early, every invalid entry is a mistake, and reviews and decisions are mistakes in ripe and hedge failures;
* the imitator's doubt (asks).

A judgment of the run's states would be a fifth, and it is excluded here. VSI uses all four, and pays n₀ only when none applies.

## 5. The case for humans

**What correctness needs: (A4), the verifier's soundness on the imitator's finished notebooks.**
* *V-machine.* It needs only that the machine check captures the goal: the formal statement says what is wanted, the specification is complete. No property of the human is involved.
* *V-cone.* It needs L to be sound: a cone that passes contains only true claims (thread F, Lemma F0).
  * With a proof checker this holds.
  * A human referee misses some plausible errors. Thread L cites detection rates of 25–55% for desk checks of code and 60–96% for formal inspection. Those misses become failed outputs, bounded by the audits of Theorem 5(e).
* *V-human.* It needs the human, verifying a finished result with full attention, not to accept a plausible wrong one. Thread Q's estimate is that soundness holds at the graded level with 85% for written mathematics and software, and 40% for empirical work.

Two things help:
* *How failed runs end.* Most weak-link failures (lost insights, trusted dead ends, plans kept too long) end with *no* claimed solution, which any verifier rejects. The danger is confident wrong results, and asking or the cone check removes many of those.
* *No selection pressure.* "Rerun until accepted" is a yes/no filter on posteriors built only from the human's answers, so it does not select for runs that fool the verifier (note.md §6.3; thread Q §3.2). The imitator is not optimizing against V.

**What only the cost needs.**
* **Bounded setback** (slack-imitation.md §3–4).
  * *The evidence* (thread L) says setbacks are bimodal. Errors that conflict with something or fail on use are caught within one or two steps. Plausible errors and recorded dead ends can persist for years.
  * *Choice blindness:* people accept altered records of their own choices 69–92% of the time, and act on them.
  * *So* (B_D) is believable for the share of mistakes that fail loudly. The share that never recovers is what sets the cost, Theorem G1's corollary: gain at most (1−ρ)/(β + (D+1)/(σ+1)) for a never-recovered share β.
* **Recovery at reviews (R-rev).** It holds for insights readable from raw records: the anomaly is in the data. It fails for insights that come only from doing (Theorem G3) and for hypothesis-driven readers who miss planted anomalies (thread L: radiologists, data "gorillas").
* **Pointers.** A post-mortem by a careful researcher looks first at recorded claims, verdicts and dead ends, which are where thread E's weak links sit. Nothing rests on it, and it is measurable.
* **The local check (L1).** A careful researcher's own entries follow from what they cite. Where they do not, the flagged step is the human's own, costs one query, and teaches nothing false (thread F, Remark on drops).

## 6. How sure I am

"Works" means: on a real careful researcher, with projects of n₀ ≈ 20–40 steps, the output failure rate is at most 5%, and the total human effort, in task-step equivalents, is at most a fifth of chained imitation's. All figures are conditional on the series' idealizations: determinism, a learner whose class contains the human, and a cold-start chain that succeeds within n₀.

| scheme | correctness rests on | worst-case task queries | works: theory, software | works: empirical, judgment |
|---|---|---|---|---|
| VSI with a machine verifier of the actual goal | the check matching the intent | 3n₀K | 85% | – (rarely available) |
| VSI with a referee checking the cone (V-cone) | soundness of L | 3n₀K, 1 per invalid cone | 70% | 30% |
| VSI with a human verifier, imitated (V-human) | (A4) | 3n₀K, plus K_V/ε verifications | 65% | 30% |
| slack imitation with asking and the design elements (Proposition 7) | (B_D) at confident valid entries, (R-rev), (A-pers) | O((D+1)K log K/(ρε)) | 45% | 20% |
| slack imitation with asking (fourth note) | (B_D) at confident steps | same | 40% | 20% |
| chained imitation (the talk) | nothing | n₀K/ε | the baseline | the baseline |

* *Why the verifier rows are high.* At ε = 5%, chained imitation pays 20n₀K task queries, and VSI pays at most 3n₀K. So VSI "works" by this definition in the worst case, whatever the human, provided the verifier is sound and cheap enough. The remaining doubt is in the idealizations, the verifier's coverage of the goal, and its cost.
* *That VSI's task queries are truly O(K),* with neither n₀ nor 1/ε: about 45% for theoretical work. It needs bounded setback or good post-mortems for most rejections.
* *How the numbers were set.* They are my synthesis of:
  * thread E's red team (50% for slack imitation with asking, theory);
  * thread L's evidence (35% for a 5× gain);
  * thread F (55–65% for bounded setback at valid entries in mathematics and software);
  * thread G (55–65% for (B-omit) with reviews);
  * thread Q (85 / 70 / 65 / 50% for the four main schemes).

  The no-verifier rows are lower than version 2's, after threads G and L.

## 7. Experiments

All are exact-Bayes, on small classes, with 20–40 humans per cell. They test how cost scales with n and with the kind of human, not whether real humans have the properties.

* **E6** ([`slack-imitation.md`](slack-imitation.md) §6). Task queries until at most 2% of runs fail, on the same humans, for n₀ = 8 → 32 → 128:
  * *chained imitation:* 2,900 → 12,700 → 51,300;
  * *slack imitation:* about 200 at every n₀ for bounded-setback humans;
  * *fooled humans:* 1,600 → 4,300;
  * *silent humans:* slack doubles the cost.

  With a verifier and uniform search, about 14 task queries for all 100 problems.
* **EQ** (thread Q §8). VSI's search on E6's humans, total task queries for 100 problems:
  * *fooled humans:* 181 → 750 → 2,636 under uniform search, and 28 → 37 → 36 with the H stream (verdict steps);
  * *silent humans:* 1,610 → 6,450 → 26,091, and 663 → 2,497 → 9,734 with the scan;
  * *the cost of the extra streams:* bounded-setback humans pay at most 1.5×, and an adversarial list at most 1.6×.
* **G1** (thread G §7). Doing-only by-product insights cost every protocol in proportion to the routine work, as Theorem G3 says. Readable insights with reviews and last-review queries cost about 300 task queries at every size.
* **F1** (thread F §8):
  * *checkable wrong claims:* slack imitation and asking grow with n (about 260 → 1,200 failed runs); the local check stays at 9–11, and checking before committing at 0;
  * *trusted false negatives:* they grow with n under every protocol, and the retry rule with r = 2 or 3 divides them by 3–4.
* **E7, composition** (thread R). E7_PLACEHOLDER

## 8. Trees

Thread N extends slack to decomposition trees: extra rounds per call, with setback measured in the parent's rounds.
* *Depth-weighted queries* give at most Φ·K failed runs, with Φ < 2((D+1)/ρ)^(d+1)·b^d for depth d and b subquestions per round.
* *The factor b^d is necessary* without more structure: when one of b subanswers is wrong, nothing in the run says which.
* *Parents that name the subanswers they reject* remove it.
* *A verifier at every node* gives at most K rejections, each found with a constant number of task queries, with no assumption about parents and no dependence on the tree's size.

So for trees, too, verification is what makes the scheme sure.

## 9. What to measure first

None of these needs a learner.
1. **Verifier soundness.** Give researchers imitator-style wrong results in their own field and style, framed as finished solutions, and measure false acceptances. This is (A4), the only assumption VSI's correctness rests on.
2. **Post-mortem accuracy.** Plant culprits in researchers' own notebooks, tell them the project failed, and count how often the culprit is among their top s entries. The culprits: a fabricated value, "tried A; it fails" where A worked, and a dropped anomaly.
3. **Setback tests,** as in slack-imitation.md §4. Plant entries in researchers' own notebooks and measure the fraction never recovered within the project, especially for recorded dead ends. Thread L's design 3, planted negatives in problems with known solutions, is the cheapest.
4. **Reading against doing.** Do researchers find the anomaly in a full raw record as often as when they do the computation? This bounds what reviews can recover (thread G's (Rec1)).

## 10. Where the parts come from

| part | source |
|---|---|
| slack, Lemma S, bounded setback, Theorem 2 | [`slack-imitation.md`](slack-imitation.md), building on thread C's slack Corollary and the third note's Theorem 1 ([`robust-runs.md`](robust-runs.md)) |
| ask-before-committing (Proposition 5) | thread E ([`research/threadE-redteam.md`](research/threadE-redteam.md)) |
| verifier, uniform search (Proposition 4); check-and-scan | slack-imitation.md; note.md, Proposition 8 |
| first mistake before n₀, hints, VSP, imitated verifier, verification does not locate | thread Q ([`research/threadQ-alternatives.md`](research/threadQ-alternatives.md)) |
| certified notebook, local check, cone verifier, retry rule, trusted records | thread F ([`research/threadF-certified.md`](research/threadF-certified.md)) |
| reviews, decisions, the doing-trigger lower bound, random τ | thread G ([`research/threadG-byproducts.md`](research/threadG-byproducts.md)) |
| optimality, necessity of slack, location numbers, fooled commissions | thread J ([`research/threadJ-optimality.md`](research/threadJ-optimality.md)) |
| deployment with asks, other learners | thread H ([`research/threadH-deployment.md`](research/threadH-deployment.md)) |
| trees | thread N ([`research/threadN-trees.md`](research/threadN-trees.md)) |
| evidence on researchers | thread L ([`research/threadL-evidence.md`](research/threadL-evidence.md)) |
| composition experiment | thread R ([`research/threadR-compose.md`](research/threadR-compose.md)) |
| checks, literature, elicitation, persistence | threads A, D, B, C |

## 11. Limits

* *Idealizations.* Determinism, exact Bayes over a class containing the human, and cold-start chains (slack-imitation.md §8). Thread L finds experts noisy: about 90% repeatability on categorical decisions. So the deterministic model is an approximation, and its stochastic version is open.
* *The verifier.* VSI is only as good as V. For research without crisp success criteria, much empirical and judgment work, no sound verifier exists. Proposition 7 is then the fallback, and I am not sure of it.
* *Verification cost.* One verification per problem, or about K_V/ε with an imitated verifier. If verifying is nearly as hard as doing, VSI saves little over the human doing the work.
* *Selection.* VSI outputs a human-like run that passes V, so V must capture the goal. If V has exploitable gaps, a learner that is not exact Bayes might find them. Exact Bayes with the majority decoder does not optimize against V.

## 12. Open

1. A stochastic human: what replaces Lemma 1's bit per mistake, and "an empty step is a delay"?
2. An agnostic version, in which no hypothesis computes the human exactly.
3. The measurements of Section 9.
4. Whether the per-level factor ((D+1)/ρ)^d for trees is necessary (thread N).
5. Whether L-optimal location protocols (thread J's LOC) can be run without knowing the hypothesis class's mistake sets.
