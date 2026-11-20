# Slack imitation: the scheme I am most sure of

*Research note by Claude (Anthropic), the fourth in this folder, version 2. It synthesizes the three earlier notes and five research threads ([`research/`](research/), working branch only).*
* *The changes from version 1* come from referee 4 ([`verification/referee-report-slack-imitation.md`](verification/referee-report-slack-imitation.md)) and from the red team of thread E ([`research/threadE-redteam.md`](research/threadE-redteam.md)). The response, item by item, is [`verification/response-slack-imitation.md`](verification/response-slack-imitation.md).
* *Code:* [`code/slack_imitation.py`](code/slack_imitation.py), experiment E6. *Tables:* [`results/slack_imitation_table.md`](results/slack_imitation_table.md).

## The question

The request: *try lots of threads and report back with the scheme you are most sure would actually work with a deterministic human. Ideally, give a proof that the scheme works if the program has such and such properties, and a case that humans in fact have them.*

## Answers in brief

1. **The scheme: slack imitation with ask-before-committing.** Start from chained imitation, the talk's protocol, and change the scaffold:
   * an append-only notebook;
   * a hidden clock: no step numbers, dates or deadlines;
   * more steps than the human needs (slack σ = ρn, for example ρ = ½).

   Then two kinds of task query:
   * **ask before committing:** during a run, wherever the imitator's top output has posterior mass below 1 − α, ask the human for that step instead of guessing. This is the first optimization in the original question, made safe by slack;
   * **after the run,** one task query at a uniformly random step.

   An optional "nothing bizarre" check catches junk. **Where results can be verified** (a proof checker, a test suite), rerun each problem until its result is verified.
2. **The theorems** (Section 3). The assumption is **bounded setback D** at the imitator's confident mistakes: an entry the human would not have written costs it at most D extra steps to finish, and part of its own next step costs it none.
   * *Slack imitation* (Theorem 2): the expected number of failed runs, over any sequence of problems, is at most min{n, (D+1)n/(σ+1)}·K ≤ (D+1)K/ρ, where K = K(human).
   * *With ask-before-committing* (Proposition 5): the asks number at most K/log₂(1/(1−α)) ≈ 0.69K/α on every path. Failed runs are at most (D+1)K/(ρ·log₂(1/α)), and bounded setback is needed only at confident steps.
   * *With a verifier* (Propositions 4 and 5): no failed run is ever output. At most K runs are rejected, and the expected number of task queries is at most min{n, (D+1)n/(σ+1)}·K.
   * *On i.i.d. problems* (Corollary 3): O((D+1)·K·log(K/δ)/(ρε)) task queries for failure probability ε. Chained imitation needs n·K/ε.

   So this is "O(K) reasonable queries" for fixed ε, δ, D and ρ, and truly O(K) task queries with a verifier.
3. **Why it works.** Slack turns a single wrong step into many: a run fails only if it has at least (σ+1)/(D+1) wrong steps, so a uniform query finds one with probability at least ρ/(D+1), not 1/n. Asking before committing removes the mistakes the imitator itself is unsure of. Each mistake found, and each ask, costs the posterior at least a fixed number of bits, and there are K bits in all.
4. **What it needs from the human** (Section 4). The useful distinction is between *confident* and *unconfident* steps, not between omissions and commissions.
   * *Unconfident steps* need nothing: the human answers them. Thread E showed that these include most of the imitator's commissions: guesses in slots the human would certainly fill, such as results, verdicts and plans.
   * *Confident omissions*, typically a rare insight left out, need the human to recover the insight later. Slack then absorbs the delay. This fails for insights that arise only while doing a piece of work the imitator did instead, and for ideas pre-empted by a hedge.
   * *Confident commissions* need the human not to be fooled for long. The worst case is a confident negative result, "tried A; it fails", where A is what would have worked, since researchers rarely redo their own recorded dead ends.

   Failures of these last two kinds are charged at chained imitation's rate.
5. **How sure I am** (Section 4, graded):
   * that bounded setback holds at all but about 5% of the imitator's confident omissions: 70% for theoretical work, 50% for empirical work;
   * that it holds at confident commissions with D ≤ 2: 55% for mathematics, 60% for software, 30% for empirical or judgment work;
   * that the scheme beats chained imitation by at least 2× on a real deterministic human with n₀ ≈ 20–40: 70%; by at least 5×: 50%.

   **With a verifier** none of this affects correctness, only cost. That is the version I am most sure of.
6. **Some assumption of this kind is necessary** for unpredictable, problem-specific insights. The first note's lower bound (Theorem 3) is proved on *silent* humans, who never recover a missed insight, which is unbounded setback.
7. **When the assumption fails,** the guarantee is chained imitation's on a run of n = n₀/(1−ρ) steps: n₀K/(1−ρ), twice chained imitation's for ρ = ½. E6 shows this factor 2 on silent humans. The asks are bounded by 0.69K/α whatever the human.
8. **Experiment E6** (exact Bayes, 40 humans per cell, the same humans in every row; Section 6). Task queries until at most 2% of runs fail, for horizons n₀ = 8 → 32 → 128:
   * *chained imitation without slack:* 2,900 → 12,700 → 51,300 for the bounded-setback humans;
   * *slack imitation* (n = 2n₀): 160–490 → 200–230 → about 205 for the same humans;
   * *fooled humans:* 1,600 → 2,800 → 4,300 with slack;
   * *silent humans:* slack doubles the cost, 2,200 → 4,500 at n₀ = 8.

   With a verifier, bounded-setback humans need 13–16 task queries for all 100 problems (38 for misled-8 at n₀ = 8), and every output is correct. Adding ask-before-committing (α = 0.3) makes fooled humans flat, 240 → 320 → 360 queries. Bounded-setback humans then cost 220–320 instead of 14, the price of asking at every uncertain step.
9. **What is new here, and what is not.**
   * The case D = 0 is thread C's Corollary (slack), for persistent humans.
   * The counting is the third note's Theorem 1, applied to robustness against the imitator's *actual* replacements. The third note (answer 4) said a usable outcome condition would have to be restricted in exactly this way.
   * Ask-before-committing and its proof are from thread E.
   * New here: setback measured by the human's remaining time, which covers commissions and makes success an outcome rather than containment of the human's own result; the verifier version; and the combination.

## 1. Setting

As in [`note.md`](note.md) and [`without-a-check.md`](without-a-check.md).
* *The human* is a deterministic program P. One step of P is one task query, three months of work.
* *The learner* is Bayes (Solomonoff) function induction with prior w, and K = K(P) = log₂(1/w(P)).
* *Labels* are the lists of entries a step appends (thread C's assumption (Y)). So every hypothesis, and the imitator, is append-only.
* *The imitator* is the majority decoder G: at every state, the label of largest posterior mass.
* *A run* starts at x₀ and appends G's label at each step.
* *A mistake* of run t is a step k with G(x′_k) ≠ P(x′_k). M_t is the set of mistakes.

Three facts from the earlier notes carry the proofs.
* **The potential.** Let W(D) be the prior mass of the hypotheses consistent with data D, and Φ(D) = log₂(W(D)/w(P)).
  * Φ(∅) ≤ K and Φ ≥ 0 always.
  * W depends only on the *set* D.
  * Adding a correct label (x, P(x)) lowers Φ by log₂(1/ξ_D(P(x) | x)) ≥ 0, where ξ_D is the posterior predictive.
* **Lemma 1 of note.md.** A task query on a mistake of the majority decoder lowers Φ by at least 1, because then ξ_D(P(x) | x) ≤ ½. So, on every path, at most ⌊K⌋ task queries land on such mistakes.
* **Theorem 1 of without-a-check.md.** Suppose that in round t the protocol task-queries a step drawn from a distribution q_t on the steps of run t, chosen after the problem is fixed and possibly depending on the run. Then E Σ_t q_t(M_t) ≤ ⌊K⌋.

## 2. The scheme

**The notebook.** A state is a notebook y: the problem x₀ and a list of entries.
* Each step appends entries. A revision is an entry ("Lemma 3 is wrong because …; use Lemma 3′"), as in a lab notebook.
* The scaffold enforces append-only by construction. y ∪ g denotes y with the entries g appended.

**The hidden clock.** The human is not told the step number or a deadline, and every step gets the same instruction ("continue this project for three months; record everything in the notebook"). The scaffold strips dates and step markers from entries, and the instruction asks for no per-step headers.
* *What it achieves.* In the model, P becomes a function of the notebook alone. In reality the notebook's length still reveals roughly how long the project has run. So this removes *stated* deadlines, not every deadline effect.
* *A consequence.* A hidden-clock human must write something every step until it succeeds: if P(y) = y, then τ(y) below is 0 or ∞.

**Slack.** Let n₀ be a number of steps in which the human's own chain solves the problem (the talk's premise). The imitator runs for n = n₀ + σ steps, σ = ρn. This costs compute, not queries.

**Success** is any property S of the final notebook that appending entries preserves, such as "the notebook contains a correct design". Remark 3 discusses reading the answer out.

**The optional check** (note.md, Section 5): at the end of a run, the human checks whether the notebook contains anything bizarre. It must satisfy:
* (M1) the empty notebook passes;
* (M2) the human never makes a passing notebook fail;
* (M-prefix) if a notebook passes, so does every prefix of it.

(M-prefix) is not note.md's (M3), which is about batches. It holds automatically if bizarreness is a property of single entries. The check costs one human look per round, plus ⌈log₂ n⌉ for each run that fails it.

**Protocol SI** (online). In each round t:
1. Run the current imitator on the next problem x₀ᵗ for n steps.
2. If the check is used and the final notebook fails, find the first step whose entry made it fail, by bisection or by reading entries in order, and task-query that step.
3. Otherwise task-query a uniformly random step k of the run: give the human x′_k and record P(x′_k).
4. Add the answer to the data.

**Protocol SI-ABC** (ask before committing; thread E). Like SI, except during the run. At step k, let μ_k be the posterior mass of the top label at x′_k, under all data so far.
* If μ_k < 1 − α, task-query x′_k (an *ask*), append the human's step, and add it to the data at once.
* Otherwise append G(x′_k) (a *committed* step).

Asked steps are the human's own, so they are never mistakes. The human sees nothing new: every notebook it is shown is made of imitator labels and its own steps.

**Protocol SI-PAC(ε, δ)** (i.i.d. problems; the epochs of MB-PAC in note.md).
* *Epochs.* The imitator is frozen within epoch i = 1, 2, …. Let γ = ρ/(D+1) and m_i = ⌈ln(i(i+1)/δ)/(γε)⌉.
* *Rounds.* In each round, draw a problem and do steps 1–3 of SI with the frozen imitator. A round is a *hit* if the queried step is a mistake.
* *After a hit,* add the hit's answer first and the epoch's other answers after it, then start a new epoch.
* *Stopping.* After m_i rounds without a hit, stop and output the frozen imitator.

**Protocol SI-V** (with a verifier V of S).
* For each problem, run the current imitator and apply V.
* If V accepts, output the run.
* Otherwise, keep the imitator fixed and task-query independent uniform steps of this run until one lands on a mistake.
* Add that answer first, then the others, and rerun.

SI-V-ABC is the same, with every run built as in SI-ABC.

## 3. The theorems

**Remaining time.** For a notebook y, let τ(y) = min{m ≥ 0 : S(P^m(y))}, the number of the human's own steps from y to success (∞ if none). Since P is deterministic and a function of the notebook:
* (T1) if τ(y) ≥ 1 then τ(P(y)) = τ(y) − 1;
* (T2) if τ(y) = 0 then τ(y ∪ g) = 0, because S is preserved by appending.

**Assumption (B_D), bounded setback.** At every mistake on the imitator's runs (in SI-ABC, every committed mistake): the imitator appends g ≠ P(y)'s entries at a notebook y, and neither y nor y ∪ g is bizarre. Then:
* (B-omit) if g is part of the entries the human would have added (g = ∅ included), τ(y ∪ g) ≤ τ(y);
* (B-commit) otherwise, τ(y ∪ g) ≤ τ(y) + D.

A mistake costs its step plus the setback, at most D + 1 steps of slack.

*How learner-relative this is.* (B_D) is quantified over the notebooks and entries the imitator produces. In this respect it is like the second note's (C_r), as the third note predicted any usable outcome condition would be. The same inequalities for every notebook and entry would be a condition on the human alone, but too strong to believe, since they include entries crafted to mislead.
* *Where it differs from (C_r).* It is *local*: one step, one entry, the human's own remaining time. It is *measurable* by planting entries in a researcher's notebook (Section 4). (C_r) instead asks the human to repair everything within r steps of the end.
* *How to read it.* (B_D) is meant to hold at most mistakes, not literally all. Remarks 2 and 5 give the version for actual, unequal setbacks.

**Lemma S (slack turns one wrong step into many).** Suppose τ(x₀) ≤ n₀, and (B_D) holds at the mistakes of a run whose notebooks are not bizarre. If the run fails, then |M| ≥ max{1, (σ+1)/(D+1)}.

*Proof.* Let τ_k = τ(x′_k). If the run fails, τ_n ≥ 1, so by (T2) τ_k ≥ 1 for every k. By (T1), τ falls by exactly 1 at each correct step. By (B_D) it rises by at most D at each mistake. So

  1 ≤ τ_n ≤ n₀ − (n − |M|) + D·|M| = (D+1)·|M| − σ.

A run with no mistake is the human's own run, which succeeds. ∎

**Theorem 2 (online).** Assume τ(x₀ᵗ) ≤ n₀ for every problem, and (B_D). Under Protocol SI with the check, for every sequence of problems, possibly chosen adaptively:

  E[#runs that fail the check] + (max{1, (σ+1)/(D+1)}/n)·E[#failed runs that pass the check] ≤ ⌊K⌋.

So E[#failed runs] ≤ min{n, (D+1)n/(σ+1)}·⌊K⌋ ≤ (D+1)K/ρ. Without the check, the same holds if (B_D) is assumed for all entries, bizarre ones included.

*Proof.*
* *A run that fails the check.* By (M-prefix) the verdict along the run is 1…1 0…0. At the flip the imitator appended an entry that made a passing notebook fail, which by (M2) the human would not have done. So the flip is a mistake, and the query lands on it with probability 1.
* *A failed run that passes the check.* Every notebook on it passes, so Lemma S applies, and the uniform query lands on a mistake with probability at least max{1, (σ+1)/(D+1)}/n.
* *The sum.* Apply Theorem 1 of without-a-check.md. ∎

**Corollary 3 (i.i.d. problems).** Let problems be i.i.d., with τ(x₀) ≤ n₀ almost surely; let (M1), (M2) and (M-prefix) hold; and let (B_D) hold on every run. Then with probability at least 1 − δ, SI-PAC outputs an imitator whose runs fail (fail the check, or fail S) with probability at most ε. It uses at most

  (⌊K⌋+1)·⌈(D+1)·ln((⌊K⌋+1)(⌊K⌋+2)/δ)/(ρε)⌉

rounds, each with one task query, plus checks.

*Proof.*
* *Epochs.* Every epoch but the last ends with a hit, a task query on a mistake of the decoder in use. The other answers are added after it. So Lemma 1 of note.md allows at most ⌊K⌋ hits, and there are at most ⌊K⌋+1 epochs.
* *Error.* If the frozen imitator of epoch i fails with probability p > ε, each round is a hit with probability at least γp, independently given the imitator. It survives m_i rounds with probability at most δ/(i(i+1)); sum over i. ∎

*If (B_D) fails,* γ is miscalibrated. The output's failure probability is then bounded only by about nρε/(D+1), chained imitation's rate up to logarithms.

**Proposition 4 (with a verifier).** Let V decide S on final notebooks, with S preserved by appending and τ(x₀) ≤ n₀. Under SI-V, for every sequence of problems:
* (a) no run that V rejects is ever output;
* (b) almost surely, at most ⌊K⌋ runs are rejected in total;
* (c) the expected number of task queries is at most ⌊K⌋·min{n, (D+1)n/(σ+1)}, under (B_D) for all entries (SI-V has no bizarreness check);
* (d) V is applied once per problem plus at most ⌊K⌋ times.

*Proof.*
* A rejected run has a mistake, because a run without one is the human's own run, which satisfies S. So each search ends almost surely, with a task query on a mistake of the decoder in use, and the other answers come after it. Lemma 1 of note.md gives (b), and (d) follows.
* (c): by Lemma S each rejected run has at least max{1, (σ+1)/(D+1)} mistakes. A search is geometric, with success probability |M|/n. Sum over at most ⌊K⌋ searches (Wald). ∎

Notes on Proposition 4.
* *Correctness.* Output runs are correct to the extent that V is sound for the real goal. With a verifier, bounded setback affects only the cost, never correctness.
* *Its ancestors.* It is the first note's check-and-scan (note.md, Proposition 8, whose bound n·K is (c) without (B_D)), with uniform search in place of the in-order scan; slack is what makes uniform search cheap. It is also thread D's Scheme B ([`research/threadD-literature.md`](research/threadD-literature.md) §3), with slack and (B_D) in place of (C_r), and uniform search in place of a scan of the last r steps. Thread D gives three reasons why (C_r) might hold, and each is an ingredient here:
  * "triggers do not expire" is (B-omit);
  * "the downstream work fits in r steps" is the slack;
  * "later entries do not mislead" is (B-commit).
* *Fine print.* V is an oracle whose calls are not counted as queries. The guarantee covers the verified problems only, not an imitator deployed without V. Sampling steps without replacement gives at most (n+1)/(|M|+1) queries per search.

**Proposition 5 (ask before committing; thread E).** Let α ≤ ½, τ(x₀ᵗ) ≤ n₀, and (M1), (M2), (M-prefix). Assume (B_D) only at the *committed* mistakes of non-bizarre runs. Then:
* (a) on every path, SI-ABC and SI-V-ABC make at most K/log₂(1/(1−α)) asks;
* (b) under SI-ABC, E[#runs that fail the check] + (max{1, (σ+1)/(D+1)}/n)·E[#failed runs that pass the check] ≤ K/log₂(1/α);
* (c) under SI-V-ABC, with (B_D) at committed mistakes for all entries: almost surely at most K/log₂(1/α) runs are rejected, and the expected number of search queries is at most (K/log₂(1/α))·min{n, (D+1)n/(σ+1)}.

*Proof.*
* *(a).* An ask at x′_k has μ_k < 1 − α, and μ_k is the largest label mass, so ξ(P(x′_k)) < 1 − α. The ask lowers Φ by more than log₂(1/(1−α)). Φ starts at most K and never goes below 0.
* *One round.* Fix a round. Let A be its asks in order, and h the answer of its uniform query (or flip query, or the hit of its search) at step k.
  * The round lowers Φ by Φ(D_t) − Φ(D_t ∪ A ∪ {h}). Since W depends only on the set of data, this can be computed in any order.
  * List A_{<k}, then h, then the rest. The imitator committed at step k using exactly the data D_t ∪ A_{<k}, because asks are added at once. Its label had mass μ_k ≥ 1 − α there.
  * So if k is a mistake, ξ(P(x′_k)) ≤ 1 − μ_k ≤ α, and h alone lowers Φ by at least log₂(1/α). Every other term is ≥ 0.
  * Hence Σ_rounds 1[hit] ≤ K/log₂(1/α) on every path.
* *(b).* The run, asks included, is fixed before the query's coin, so Pr[hit | past, run] = q_t(M_t). Taking expectations, E Σ_t q_t(M_t) ≤ K/log₂(1/α).
  * The flip of a run that fails the check is a committed step, since an asked step appends the human's own entries, which keep the notebook passing by (M2). So the flip is a mistake.
  * For a failed run that passes the check, asked steps are correct steps in Lemma S, which therefore gives |M_t| ≥ max{1, (σ+1)/(D+1)}.
* *(c).* Each rejection ends with a hit, so the per-round bound gives the number of rejections. Each search is geometric with success probability |M|/n, as in Proposition 4. ∎

Notes on Proposition 5.
* *Cost.* The asks are a lifetime budget of about 0.69K/α queries (for small α), not a per-run cost.
* *Deployment.* A frozen imitator deployed after a PAC phase must either keep asking, which stays within that budget, or abstain at unconfident steps. Abstaining costs the factor of about 1/α in Lemma 1 of note.md that Section 9 mentions.
* *What it needs in practice.* μ must measure confidence about content, not wording. Otherwise SI-ABC asks at every step until the human's style is learned. In the theory that cost is part of K.

**Remarks.**
1. *Comparison.* Chained imitation is the case σ = 0. Slack replaces its factor n₀ by (D+1)/ρ when D < σ. K is unchanged; thread B's knowledge-base and probe results reduce K but not n (its Theorems 3 and 4), and compose with this.
2. *Without (B_D).* Every failed run still has at least one mistake, so E[#failed] ≤ n·K = n₀K/(1−ρ): chained imitation's guarantee on the longer run, twice chained imitation's for ρ = ½.
   * *More finely,* a run fails only if Σ_{k∈M}(1 + D_k) ≥ σ+1, where D_k is the actual setback at mistake k.
   * So failures from many small setbacks are charged at the good rate, and only failures from a few huge setbacks at the 1/n rate.
3. *Read-out.* If the answer is read out by one more step of the human ("which entry is the solution?"), that step needs its own assumption:
   * **(R)** on every final notebook of the imitator's runs that satisfies S, the human's read-out is correct.

   *Why it is needed.* Without (R), a notebook that holds the correct design and a plausible wrong one can be read out wrongly with no mistake anywhere: the imitator copies the human's read-out. Slack makes (R) harder, since the σ steps after success are extra chances for a "v2 supersedes v1".

   *With (R),* query the read-out step with probability ½ and a uniform step otherwise; all failures together are then at most 2(D+1)K/ρ in expectation. A read-out that verifies its candidate makes (R) plausible for mathematics and software, and a machine verifier (Proposition 4) removes the issue.
4. *The hidden clock is not used in the proofs.* With a visible step, make the step part of the state and define τ(y, k). (T1), (T2) and Lemma S hold verbatim, with (B_D) read as τ(y ∪ g, k+1) ≤ τ(y, k) + D.
   * But (B-omit) for g = ∅ is then a real assumption, τ(y, k+1) ≤ τ(y, k): the human is not deadline-driven.
   * With a hidden clock it holds by definition, because the human is a function of the notebook.
   * E6 uses a visible step, because its humans' ideas arrive at a time t_p. Under a hidden clock, an idea can only arrive through something written in the notebook.
5. *Average setback.* Lemma S uses only the sum of the setbacks. If on every failed run the mistakes' setbacks average at most D̄, Lemma S and Theorem 2 hold with D̄ in place of D.

## 4. What the imitator writes, and the case for bounded setback

**Confident and unconfident steps.** Thread C's Proposition 2 is exact for posteriors that are products over items, and a heuristic otherwise. For an item that is due with probability π, and whose most likely value has conditional mass p_max, the decoder writes that value iff π·p_max > 1 − π. The output's mass is then π·p_max if it writes, and 1 − π if it omits. So (thread E §1):
* **Slots that are certainly due get filled with guesses.** At π ≈ 1 the decoder writes its plurality value at any confidence. Such slots are the result of a computation just set up, the outcome of an attempt, a "next steps" list, a verdict. "Predictable" in version 1 meant only "plurality".
* **Rare content is omitted confidently.** At small π the omission has mass about 1 − π. The lower-bound class consists of such omissions.
* **Empty steps essentially never occur.** Dates, headers and restated goals are written confidently, so the realistic omission is a *partial* step: routine work written, insight left out.
* **Paraphrase.** Strictly, almost every step is a commission, since the decoder's wording is not the human's. A faithful paraphrase needs (B-commit) with D = 0. A lossy one, which drops a hedge or a condition, can be a fooled commission.
* **Junk** is rare for the majority decoder, and the check catches it.

The axis that matters is confidence:
* *unconfident steps:* ask-before-committing hands them to the human, so no assumption is needed;
* *confident omissions:* (B-omit);
* *confident commissions:* (B-commit).

**Confident omissions: (B-omit).**
* *Why I expect recovery.* An insight the human would have had from notebook y comes from what is in y. A later notebook still contains y, plus partial work, so on reading it the human can still have the insight. Then the omission is a delay, which slack absorbs.
* *By-product insights: a silent human under a hidden clock* (thread E, V5). An insight can be tied to an *activity*, not to the date: a confound noticed while setting up the third run, a pattern noticed while computing small cases by hand. Let the state be (problem, j routine units done, insight or not), and let the human add the insight when it does unit j = t_p. This human is a function of the notebook alone, yet Theorem 3 of note.md applies to it verbatim. Version 1's argument that the opposite "would mean the idea depends on the date" was wrong. A partial mitigation: the instruction, also part of the reference chain, asks for raw intermediate data in the notebook rather than summaries.
* *Hedges and substitutes* (thread C §6). If the human writes idea A together with a hedge B, and never writes A on a notebook that already contains B, then the partial step {B} has unbounded setback.

**Confident commissions: (B-commit).**
* **Wrong and checkable** (a false lemma, failing code). The human verifies before building and loses at most the verification lag.
  * A standing instruction, "entries may contain errors; verify before you rely on them", shortens the lag. It is part of the reference chain, so n₀ grows a little.
  * Machine-checked entries make D ≈ 0 for executable claims. The scaffold runs the code or the proof checker and appends the output, also in the reference chain.
* **A valid alternative.** Harmless, because S is about the result.
* **A slower direction, kept by sunk cost.** D is the detour's extra time; slack absorbs single detours up to σ. Unbounded if the detour never visibly fails.
* **A confident negative result chosen by base rate** (thread E, V2): "tried A; it fails", where A is what would have worked. This is the most damaging mechanism.
  * A positive claim can be checked by reading its proof. A recorded dead end can be checked only by redoing the attempt, which researchers rarely do. It behaves like a silent human, reached through a commission.
  * *Mitigation:* an instruction to record where an attempt got stuck, not a verdict. When the imitator is unsure of the verdict, ask-before-committing applies.
* **Anchoring on a confident weaker result** (the Einstellung effect, which is robust in experts).
* **Laundered verification.** A "✓ checked numerically" next to a guess: any check the human records gets imitated too. Only records that certify themselves, such as machine output, help.

**The design law** (thread E §4). A correct imitator step must produce exactly P(y). So:
* anything the scaffold adds to imitator entries but not to the human's own (provenance tags, confidence scores) breaks (T1) or says nothing;
* anything the human itself writes ("high confidence", "verified") is imitated, so it does not certify.

The valid variants:
* the verify instruction;
* machine-checked entries;
* audits triggered by content ("after every 8 new entries, audit the load-bearing claims");
* a quarantine section for low-confidence content;
* stripping dates;
* ask-before-committing.

**The graded reading.** (B_D) at literally every mistake of every run is almost surely false for any real human. What matters is the share β of the learner's hits that concern behaviour whose mistakes sink a run alone. For bounded-setback failures the guaranteed gain over chained imitation is ρn₀/(D+1): 3 to 10 for n₀ = 16 to 40 (projects of 4 to 10 years in three-month steps) and D = 1 or 2. Heuristically, the realized gain is capped near (1−ρ)/β (thread E §3.6). E6 is kinder: fooled humans still gain, because their failed runs usually also carry omission mistakes.

**Probabilities.** These are for a careful researcher, on the graded reading: the assumption fails at no more than about 5% of the imitator's confident mistakes of that kind.

| claim | version 1 | thread E | version 2 (mine) |
|---|---|---|---|
| (B-omit), theory and mathematics | 90% | 70% | 70% |
| (B-omit), empirical or judgment work | – | 50% | 50% |
| (B-commit), D ≤ 2, mathematics, without / with ask-before-committing | 70% | 35% / 55% | 35% / 55% |
| (B-commit), D ≤ 2, software | 70% | 40% / 60% | 40% / 60% |
| (B-commit), D ≤ 2, empirical or judgment work | 40% | 15% / 30% | 15% / 30% |
| beats chained imitation by ≥ 2× (real human, n₀ ≈ 20–40, with ask-before-committing) | – | 70% | 70% |
| by ≥ 5× | 75% | 50% | 50% |

* *Why I moved.* Version 1 assumed that most of the imitator's mistakes are omissions and its commissions are "the obvious idea". Thread E's reading of Proposition 2 (guesses in certainly-due slots, base-rate negative results), and the by-product construction under a hidden clock, persuaded me otherwise.
* *What does not move.* The theorems, which two independent checks found correct, and the verifier version. There, correctness depends only on determinism, exact Bayes and V's soundness, and the cost is at most n₀K/(1−ρ) task queries plus 0.69K/α asks, whatever the human.

**How to test it** on real researchers, with no learner, by planting entries in their *own* notebooks and presenting them as their own:
* *Omissions.* Remove part of the last step's work, and part of a computation's raw record.
* *Commissions:*
  * "tried A; it fails", where A is the step that worked;
  * a plausible wrong value for a computation the researcher had set up;
  * a plausible plan that differs from its own;
  * a weaker "obvious" result.
* *Measure* the extra time to finish, and the fraction never recovered within the project. That fraction, set against (D+1)/(ρn₀), decides whether the scheme gains a large factor; the size of the finite setbacks matters less.

## 5. Why something like bounded setback is needed

* *The lower bound.* The first note's Theorem 3 gives Ω(nK/(ε log(n/ε))) for every task-only protocol. It is proved on the hidden-insight class, whose humans are silent; for the class-prior decoder, a failed run has a single mistake, and only a query at that step reveals it.
* *Other ways round the factor n* exist for other kinds of human: predictable steps, shared knowledge, δ-isolation (the second note, answer 1), complete elicitation or diagnostic probes (thread B), a concentrated position law (thread D). For unpredictable, problem-specific insights, each way round needs something that locates the defect.
* *Sources of location* (thread D's frame, extended by thread E):
  * a human judgment of states: a check, an endorsement, a verifier;
  * threshold or group structure, as with persistence;
  * an honest party, or white-box structure;
  * the imitator's own doubt, which ask-before-committing uses.
* *How slack works.* It is not a threshold signal. It *enlarges* the defect: a failed run must contain many mistakes, so point queries find one. This is the mistake-mass frame of without-a-check.md's Theorem 1, and the human contributes by recovering on its own, which bounded setback describes.
* *What escapes every source but a judgment.* A confident commission that a fooled human accepts escapes the imitator's doubt and the human's recovery. In a fooled class with problem-specific deviations of probability below α at a decision point, SI-ABC commits to the default, and the failures are single-mistake runs found at rate 1/n. Lowering α below the deviation rate costs about one ask per problem. So the honest trade is (B-commit) for confident commissions against a query cost of about 1/α (thread E §4).
* *Why slack is needed in addition.* Thread C's CHAIN experiment and E6 show it. Without slack, the delays themselves are failures: a key idea written a few steps late leaves too little time for the work that depends on it.

## 6. Experiment E6

**Setup** ([`code/slack_imitation.py`](code/slack_imitation.py); exact posteriors).
* *Problems.* 100 problems per human. Problem p has an idea of value k_p, 1 ("the obvious idea", probability 0.9) or 2 (problem-specific). The idea becomes available at a step t_p, uniform on [0, n₀).
* *The human.* A notebook builds on at most one value, with u units of dependent work on it. The human writes its idea once available. It adds one unit per step to a notebook that builds on its own value; this happens even before the idea is available to it, which is generous to the bounded-setback kinds. On a notebook that builds on the wrong value, it builds on it if its idea is not yet available or u < D; otherwise it writes the correction and restarts the dependent work.
* *Success.* The final notebook builds on k_p with at least as many units as the human's own notebook at step n₀.
  * This S is not preserved by appending, since a correction resets the work.
  * It is harmless on the runs that occur: referee 4 found no run that reached S and then lost it.
* *The kinds.*
  * *noticing* (D = 0), *misled-2* and *misled-8*: bounded setback;
  * *fooled:* never corrects;
  * *silent:* writes its idea only at step t_p, and never corrects a wrong value; the first note's class.
* *Setbacks.* On the decoder's runs, setbacks are at most 0 for noticing, 2 for misled-2 and 8 for misled-8 (referee 4, [`verification/referee4_setback_e6.out`](verification/referee4_setback_e6.out), over 91,000 runs). For the human alone they are not: overwriting a notebook that already builds on k_p would cost all its dependent work. The decoder never does that, because it never favours a value the data contradict.
* *The learner.* Every hypothesis knows the human's kind; (t_p, k_p) are unknown. The imitator is the majority decoder of the exact posterior.
  * *Ties* go to not writing and to continuing the current notebook, then to value 1.
  * *The prior decoder of the persistent kinds* writes value 1 at about 0.53·n₀, so its ideas are late or wrong, never missing.
  * *For silent humans* it writes nothing until queries locate t_p. It can then write the wrong value.
* *Protocols:*
  * CI without slack on the same humans (n = n₀);
  * with slack σ = n₀ (so n = 2n₀): SI (uniform step), LAST (last step) and MIX (last step with probability ½, else uniform);
  * the verifier versions SI-V and SI-V-ABC.

  The last row of the table is version 1's no-slack row, whose humans had horizon n, not n/2.
* *Measurement.* 40 humans per cell, the same 40 in every row at a given n. The entry is the mean task queries until at most 2% of the 100 problems fail (oracle stopping, which is in effect a success oracle used only to stop). For the verifier versions it is the total task queries for all 100 problems. LAST is capped at 40,000 queries, the others at 4,000·n.

**Results.** Columns are the slack runs' length n = 2n₀, so n₀ = 8, 32 and 128. Entries are mean ± standard error; "stalls at x%" means the cap was reached at failure x%.

*Without a verifier:*

| protocol | human | n = 16 | n = 64 | n = 256 |
|---|---|---|---|---|
| CI, no slack, same humans (n = n₀) | noticing | 2,915 ± 55 | 12,724 ± 297 | 51,365 ± 1,153 |
| CI, no slack, same humans (n = n₀) | misled-2 | 2,919 ± 55 | 12,724 ± 297 | 51,340 ± 1,151 |
| CI, no slack, same humans (n = n₀) | misled-8 | 2,919 ± 55 | 12,724 ± 297 | 51,340 ± 1,151 |
| CI, no slack, same humans (n = n₀) | fooled | 2,919 ± 55 | 12,729 ± 298 | 51,347 ± 1,159 |
| CI, no slack, same humans (n = n₀) | silent | 2,249 ± 48 | 10,873 ± 215 | 47,065 ± 1,017 |
| SI: CI with slack (n = 2n₀) | noticing | 160 ± 12 | 204 ± 14 | 204 ± 14 |
| SI: CI with slack (n = 2n₀) | misled-2 | 186 ± 14 | 208 ± 14 | 204 ± 14 |
| SI: CI with slack (n = 2n₀) | misled-8 | 485 ± 40 | 227 ± 14 | 205 ± 14 |
| SI: CI with slack (n = 2n₀) | fooled | 1,631 ± 124 | 2,811 ± 287 | 4,296 ± 469 |
| SI: CI with slack (n = 2n₀) | silent | 4,467 ± 107 | 21,964 ± 424 | 92,819 ± 2,130 |
| MIX with slack | noticing | 143 ± 10 | 169 ± 11 | 161 ± 11 |
| MIX with slack | misled-2 | 152 ± 14 | 172 ± 12 | 161 ± 11 |
| MIX with slack | misled-8 | 203 ± 19 | 180 ± 12 | 164 ± 10 |
| MIX with slack | fooled | 2,847 ± 202 | 7,130 ± 723 | 7,864 ± 982 |
| MIX with slack | silent | 9,271 ± 180 | 42,292 ± 841 | 178,644 ± 3,697 |
| LAST with slack | noticing | 123 ± 9 | 156 ± 10 | 142 ± 11 |
| LAST with slack | misled-2 | 123 ± 9 | 156 ± 10 | 142 ± 11 |
| LAST with slack | misled-8 | 123 ± 9 | 156 ± 10 | 142 ± 11 |
| LAST with slack | fooled | stalls at 10% | stalls at 10% | stalls at 10% |
| LAST with slack | silent | stalls at 100% | stalls at 100% | stalls at 100% |
| CI, no slack, n₀ = n (different humans) | noticing | 6,012 ± 117 | 25,256 ± 709 | 97,489 ± 2,711 |
| CI, no slack, n₀ = n (different humans) | misled-2 | 6,012 ± 117 | 25,256 ± 709 | 97,589 ± 2,718 |
| CI, no slack, n₀ = n (different humans) | misled-8 | 6,022 ± 115 | 25,256 ± 709 | 97,589 ± 2,718 |
| CI, no slack, n₀ = n (different humans) | fooled | 6,022 ± 115 | 25,208 ± 707 | 97,568 ± 2,720 |
| CI, no slack, n₀ = n (different humans) | silent | 5,088 ± 93 | 22,845 ± 481 | 93,399 ± 2,022 |

*With a verifier (SI-V), and with ask-before-committing (SI-V-ABC).* Entries are the total task queries for all 100 problems, with the asks and rejections per human in parentheses.

| protocol | human | n = 16 | n = 64 | n = 256 |
|---|---|---|---|---|
| SI-V | noticing | 13 ± 1 (9.9 rejected; 1 per rejection) | 14 ± 1 (10.4 rejected; 1 per rejection) | 14 ± 1 (10.1 rejected; 1 per rejection) |
| SI-V | misled-2 | 14 ± 1 (9.9 rejected; 1 per rejection) | 14 ± 1 (10.4 rejected; 1 per rejection) | 14 ± 1 (10.1 rejected; 1 per rejection) |
| SI-V | misled-8 | 38 ± 3 (10.8 rejected; 4 per rejection) | 16 ± 1 (10.4 rejected; 1 per rejection) | 14 ± 1 (10.1 rejected; 1 per rejection) |
| SI-V | fooled | 181 ± 13 (14.6 rejected; 12 per rejection) | 750 ± 76 (19.2 rejected; 39 per rejection) | 2,636 ± 238 (18.5 rejected; 142 per rejection) |
| SI-V | silent | 1,610 ± 24 (100.0 rejected; 16 per rejection) | 6,450 ± 111 (100.0 rejected; 65 per rejection) | 26,091 ± 385 (100.0 rejected; 261 per rejection) |
| SI-V-ABC, α = 0.3 | noticing | 223 ± 2 (221 asked; 1.1 rejected) | 285 ± 2 (284 asked; 0.5 rejected) | 319 ± 4 (318 asked; 0.1 rejected) |
| SI-V-ABC, α = 0.3 | misled-2 | 223 ± 2 (221 asked; 1.1 rejected) | 285 ± 2 (284 asked; 0.5 rejected) | 319 ± 4 (318 asked; 0.1 rejected) |
| SI-V-ABC, α = 0.3 | misled-8 | 236 ± 3 (221 asked; 1.1 rejected) | 285 ± 2 (284 asked; 0.5 rejected) | 319 ± 4 (318 asked; 0.1 rejected) |
| SI-V-ABC, α = 0.3 | fooled | 236 ± 3 (221 asked; 1.1 rejected) | 318 ± 13 (284 asked; 0.5 rejected) | 360 ± 19 (318 asked; 0.1 rejected) |
| SI-V-ABC, α = 0.3 | silent | 1,602 ± 22 (0 asked; 100.0 rejected) | 6,375 ± 79 (0 asked; 100.0 rejected) | 25,864 ± 441 (0 asked; 100.0 rejected) |
| SI-V-ABC, α = 0.1 | noticing | 434 ± 4 (432 asked; 1.1 rejected) | 708 ± 6 (707 asked; 0.5 rejected) | 874 ± 11 (874 asked; 0.1 rejected) |
| SI-V-ABC, α = 0.1 | misled-2 | 434 ± 4 (432 asked; 1.1 rejected) | 708 ± 6 (707 asked; 0.5 rejected) | 874 ± 11 (874 asked; 0.1 rejected) |
| SI-V-ABC, α = 0.1 | misled-8 | 447 ± 4 (432 asked; 1.1 rejected) | 708 ± 6 (707 asked; 0.5 rejected) | 874 ± 11 (874 asked; 0.1 rejected) |
| SI-V-ABC, α = 0.1 | fooled | 447 ± 4 (432 asked; 1.1 rejected) | 741 ± 15 (707 asked; 0.5 rejected) | 916 ± 21 (874 asked; 0.1 rejected) |
| SI-V-ABC, α = 0.1 | silent | 447 ± 4 (432 asked; 1.1 rejected) | 6,375 ± 79 (0 asked; 100.0 rejected) | 25,864 ± 441 (0 asked; 100.0 rejected) |

The tables are [`results/slack_imitation_table.md`](results/slack_imitation_table.md), written by `slack_imitation.py ../results --table`.

**Reading.**
* *On the same humans,* slack cuts the cost for bounded-setback humans from 2,915 → 12,724 → 51,365 (n₀ = 8 → 32 → 128) to about 200 at every horizon, a gain of 18× → 62× → 250× that grows with n₀. Misled-8 at n₀ = 8 costs 485, which fits the theorem: there σ = 8 = D, so Lemma S guarantees only one mistake per failed run.
* *Fooled humans* grow with n₀ under slack (1,631 → 2,811 → 4,296), while the bounded-setback kinds do not. They grow more slowly than n₀ only because, in this class, a "nothing yet" answer before the decoder's guess reveals that t_p is later; nothing in the theorem gives this.
* *Silent humans cost twice as much with slack* (2,249 → 4,467 at n₀ = 8), as Remark 2 predicts: the uniform query is spread over 2n₀ steps, and a missed idea is never recovered.
* *LAST* is the cheapest protocol for bounded-setback humans. Their failed runs end with a mistake, since at the last step the human would still write or correct the idea. But it has no guarantee: it stalls at 10% failure for fooled humans and 100% for silent ones. MIX gets most of its advantage, at about twice SI's cost on the others.
* *With a verifier,* bounded-setback humans need 13–16 task queries for all 100 problems (38 for misled-8 at n₀ = 8), and every output is correct. Only problems with k_p = 2 are ever rejected. A rejected run costs about n queries for silent humans (one mistake per run), and 0.56n–0.77n for fooled ones.
* *Ask-before-committing* removes the fooled humans' growth: 236 → 318 → 360 at α = 0.3, with almost no rejections. The price is asking at every uncertain step. Bounded-setback humans then cost 220–320 instead of 14, and α = 0.1 asks more (430–870). Silent humans' omissions are confident at n₀ ≥ 32, so asking does not help them, as Section 5 predicts. At n₀ = 8 with α = 0.1, every step is uncertain enough to ask.
* *Bookkeeping.* [`code/setback_check.py`](code/setback_check.py) is only an arithmetic sanity check of Lemma S's bookkeeping on random humans. It cannot test (B_D). The substantive run-level check is referee 4's.

**What E6 does not show.** The class is tiny, so K is small and the posterior exact. The point is how cost depends on n and on the kind of human. E6 does not test whether real humans have bounded setback; only tests like those of Section 4 can.

## 7. How the alternatives compare

| scheme | what it asks of the human | guarantee | my view |
|---|---|---|---|
| chained imitation (the talk) | nothing | n₀·K failed runs; n₀·K/ε queries | works, at the factor n₀ |
| end-weighted (second note) | (C_r): from the imitator's state r steps before the end, the human's own r steps succeed | 2r·H_n·K failed runs under (C_r); 2n·K always | learner-relative, and asks for repair within r steps |
| monitored bisection (first note) | a preserved "on track" check | ≤ K failed runs; K task queries plus checks | the check is the assumption the user did not want |
| check-and-scan (first note, Proposition 8) | a check of final results | ≤ K rejected runs; n·K task queries | the ancestor of Proposition 4 |
| nothing-bizarre check alone (thread A) | a preserved junk check | ≤ K junk runs; nothing about other failures | believable, but weak |
| persistence: Protocol Z, BIS (thread C) | persistence (P₁) on non-bizarre notebooks | ≤ K ripe failures; the slack Corollary is the case D = 0 of Theorem 2 | BIS beyond toy classes not shown |
| endorsed logs (thread D, Scheme A) | the human endorses each entry; every fully endorsed run ends well | ≤ K failed runs | a lenient endorsement passes runs that lack the insight; a strict one costs a task step per look |
| detect at the end, repair near the end (thread D, Scheme B) | an outcome check, and (C_r) | ≤ K rejected runs, ≤ r·K task queries | the closest ancestor of Proposition 4 |
| the human as equivalence oracle (thread D, Scheme C) | finds a mistake of the imitator whenever it fails often | ≤ K+1 requests; human effort (K+1)(c+1) | only for knowledge the human knows it has; c can be a whole run |
| probes and knowledge base (thread B) | answers to questions about what it knows | reduces K, not n; *located* probes remove n (Theorem 5(b)) | composes with all the above |
| **slack imitation (Theorem 2)** | **bounded setback on the imitator's notebooks: learner-relative, but local and measurable** | **min{n, (D+1)n/(σ+1)}·K failed runs** | **beats chained imitation where setbacks are mostly bounded** |
| **+ ask-before-committing (Proposition 5)** | **bounded setback at confident steps only** | **0.69K/α asks in total; (D+1)K/(ρ log₂(1/α)) failed runs** | **my recommended scheme without a verifier** |
| **+ a verifier (Propositions 4 and 5)** | **bounded setback, for the cost only** | **no failed output; ≤ K rejections; ≤ n·K task queries in the worst case** | **the version I am most sure of, where results are verifiable** |

## 8. Limits

* *Exact Bayes.* The theorems are about the Solomonoff majority decoder. A practical learner has no Lemma 1 of note.md. These are statements about what the information in the queries allows.
* *Determinism.* A stochastic human breaks "an empty step is a delay" and the bit per mistake of Lemma 1 of note.md. So do the human's drift over thousands of queries, its growing familiarity with the imitator's style, fatigue, and using many humans (thread E §3.4).
* *Cold starts.* P is a function of the notebook, so the reference chain is a chain of cold starts: a human who rereads its notebook every three months and keeps nothing unrecorded. For tacit, accumulated skill, τ(x₀) of that chain may be much larger than the person's normal time. This is shared with all chained imitation.
* *The world.* If a step involves experiments, the imitator must predict their outcomes. The notebook model covers thinking work, or experiments run by the scaffold in the reference chain too.
* *Success and read-out.* S must be preserved by appending, the read-out needs (R), and the human's chain must succeed within n₀ steps with the clock hidden. Research times are heavy-tailed, so a fixed n₀ leaves a floor of failures that no theorem charges.
* *The size of K.* Whether K(human), given a corpus, is small enough for "O(K) queries" to be practical is outside this note.

## 9. Open

1. Measure setbacks on humans with the planted-entry tests of Section 4, especially for recorded dead ends.
2. Confident commissions. Ask-before-committing removes the unconfident ones. Abstaining at confidence below 1 − α costs a factor of about 1/α in Lemma 1 of note.md. Is there a better trade-off for the confident ones, short of a check?
3. BIS (thread C) found the exact step of a missed insight in log₂ n queries in CHAIN, removing lateness without slack. Does it carry over beyond such classes, and does it compose with ask-before-committing?
4. Trees. Not worked out. Running a decomposition tree depth-first in one shared notebook makes it a chain, and the theorems apply. But then later subcalls see earlier subcalls' commissions, so (B_D) must hold across subcalls, and the isolation of subcalls is lost. A version with a slack budget per subtask, and setback measured at the parent, is the natural candidate.
