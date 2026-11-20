# Slack imitation: the scheme I am most sure of

*Research note by Claude (Anthropic), the fourth in this folder. It synthesizes the three earlier notes and four research threads ([`research/`](research/), working branch only). Draft. Code: [`code/slack_imitation.py`](code/slack_imitation.py), experiment E6. Output: [`results/slack_imitation.out`](results/slack_imitation.out), [`results/slack_imitation_summary.json`](results/slack_imitation_summary.json).*

## The question

The request: *try lots of threads and report back with the scheme you are most sure would actually work with a deterministic human. Ideally, give a proof that the scheme works if the program has such and such properties, and a case that humans in fact have them.*

## Answers in brief

1. **The scheme, slack imitation.** It is chained imitation, the talk's protocol, with four changes to the scaffold that cost no queries:
   * an append-only notebook;
   * a hidden clock;
   * more steps than the human needs (slack);
   * optionally, a "nothing bizarre" check on the final notebook.

   Each round, one task query at a uniformly random step of the imitator's run.
2. **The theorem.** Run the imitator for n = n₀ + σ steps, where the human's own chain solves the problem in n₀ steps, and let ρ = σ/n. Suppose the human has **bounded setback D**:
   * an entry of the notebook that the human would not have written costs it at most D steps of extra work to finish;
   * part of its own next step costs it none.

   Then, over any sequence of problems, the expected number of failed runs is at most **(D+1)·K/ρ**, where K = K(human) is the human's complexity. On i.i.d. problems, an imitator that fails with probability at most ε needs O((D+1)·K·log(K/δ)/(ρε)) task queries. Chained imitation needs n·K/ε, so the factor n is gone. This is the "O(K) reasonable queries" result asked for, conditional on bounded setback (Section 3).
3. **Why it works.** Slack turns "solves the problem" from a property that one wrong step can destroy into one that only many wrong steps can. A run fails only if it has at least (σ+1)/(D+1) wrong steps. A uniformly random query then finds one of them with probability at least ρ/(D+1), not 1/n. Each wrong step found costs the posterior at least a bit, and there are at most K bits.
4. **The case for humans** (Section 4).
   * *Certain by construction:* append-only, hidden clock, slack.
   * *Certain by determinism and the hidden clock:* a step on which the imitator writes nothing new delays the human by exactly one step. The human sees the same notebook one step later and does what it would have done.
   * *Very likely:* having part of its own next step already written does not slow the human down. The one exception I can find is insights that come only as a by-product of doing work that the imitator did instead.
   * *The weak link:* commissions, content the imitator writes that the human would not have written. The majority decoder writes such content only when it is the predictable continuation (thread C, Proposition 2), so the typical case is "the obvious idea where the human had a better one".
     * If the human would notice the problem, or a contradiction surfaces within D steps, the bound holds.
     * If the human builds on a plausible wrong result and never revisits it, D is unbounded, and that run is charged as in chained imitation.
5. **Some assumption of this kind is necessary.** The first note's lower bound (Theorem 3) is attained by *silent* humans: a missed insight is never recovered, which is unbounded setback from an omission. Every way round the factor n that the threads found uses some human signal that a contribution is missing. Here the signal is that the human still makes the contribution later, on a notebook that lacks it.
6. **If the result can be verified** (a proof checker, a test suite, the human checking a finished result), no failed run is ever output. Then (B_D) affects only the cost: at most (D+1)K/ρ task queries in expectation in total, and n·K without it (Proposition 4). This is the version I am most sure of, for problems where it applies.
7. **When the assumption fails, the guarantee falls back to chained imitation's.** Slack imitation is chained imitation plus spare steps. Its worst-case guarantee is chained imitation's n·K failed runs, and every failed run with many wrong steps is still caught at the better rate. (This compares guarantees, not humans: as the second note's referee showed, a query can make the majority decoder worse on a particular human.)
8. **Experiment E6** (exact Bayes, 40 humans per cell). It uses a class with an obvious idea and a problem-specific one, and dependent work. The task queries needed until at most 2% of runs fail, for n = 16 → 64 → 256, with ρ = ½ for slack imitation:
   * *bounded-setback humans* (D = 0, 2, 8): 160–490 at n = 16, and 200–230 at n = 64 and 256;
   * *the same humans without slack:* 6,000 → 25,000 → 97,000;
   * *fooled humans:* 1,600 → 2,800 → 4,300;
   * *silent humans:* 4,500 → 22,000 → 93,000. Slack does not help them at all; they are the lower-bound class.

   With a verifier, bounded-setback humans need about 14 task queries for all 100 problems at every n, with every output correct.

## 1. Setting

As in [`note.md`](note.md) and [`without-a-check.md`](without-a-check.md).
* *The human* is a deterministic program P. One step of P is one task query, three months of work.
* *The learner* is Bayes (Solomonoff) function induction with prior w, and K = K(P) = log₂(1/w(P)).
* *The imitator* is the majority decoder G: at every state, the output of largest posterior mass.
* *A run* starts at x₀ and applies G at each step.
* *A mistake* of run t is a step k at which G(x′_k) ≠ P(x′_k). M_t is the set of mistakes.

Two facts from the earlier notes carry the proofs.
* **Lemma 1 of note.md.** On every path, at most ⌊K⌋ task queries land on a mistake of the decoder in use. Each such query halves the posterior mass of the hypotheses consistent with the data. Adding further correctly labelled data in between never hurts.
* **Theorem 1 of without-a-check.md.** Suppose that in round t the protocol task-queries a step drawn from a distribution q_t on the steps of run t, chosen after the problem is fixed. Then E Σ_t q_t(M_t) ≤ ⌊K⌋.

## 2. The scheme

**The notebook.** A state is a notebook y: the problem x₀ and a finite list of *entries*.
* Each step appends entries: the human's step is y ↦ P(y) with P(y) ⊇ y, and so is the imitator's.
* Nothing is ever deleted. A revision is an entry ("Lemma 3 is wrong because …; use Lemma 3′"), as in a lab notebook.
* The scaffold enforces this by construction, by appending whatever a step outputs.

**The hidden clock.** The human is not told the step number or the deadline. Every step gets the same instruction, "continue this project for three months; record everything in the notebook". So P is a function of the notebook alone.

**Slack.** Let n₀ be a number of steps in which the human's own chain solves the problem (the talk's premise). The imitator runs for n = n₀ + σ steps, σ = ρn, for example ρ = ½. This costs compute, not queries. Since the clock is hidden, the human's own chain run for n steps contains its own n₀-step notebook.

**Success** is any property S of the final notebook that appending entries preserves. "The notebook contains a correct design" is an example; "the last entry is the answer" is not. Remark 3 below discusses read-out.

**The optional check.** At the end of a run the human checks whether the notebook contains anything bizarre (note.md, Section 5). The check must satisfy:
* (M1) the empty notebook passes;
* (M2) the human never makes a passing notebook fail;
* (M3) if a notebook passes, so does every notebook obtained by deleting entries from its end.

If bizarreness is a property of single entries, (M3) is automatic. In a run whose final notebook passes, every notebook on the run then passes.

**Protocol SI** (online). In each round t:
1. Take the next problem x₀ᵗ and run the current imitator for n steps.
2. If the check is used and the final notebook fails it, find the first step whose entry made it fail. Use bisection with checks (⌈log₂ n⌉ of them), or read entries in order if bizarreness is a property of entries. Task-query that step.
3. Otherwise task-query a uniformly random step k ∈ {0, …, n−1} of the run: give the human the imitator's notebook x′_k and record its step P(x′_k).
4. Add the answer to the data.

**Protocol SI-PAC(ε, δ)** (i.i.d. problems; the epoch structure of MB-PAC in note.md).
* *Epochs.* The imitator is frozen within epoch i = 1, 2, …. Let γ = ρ/(D+1) and m_i = ⌈ln(i(i+1)/δ)/(γε)⌉.
* *Rounds.* In each round, draw a problem and do steps 1–3 with the frozen imitator. Call the round a *hit* if the queried step is a mistake, that is, the human's answer differs from the imitator's output there.
* *After a hit,* add the hit's answer to the data first and the epoch's other answers after it, then start a new epoch.
* *Stopping.* After m_i rounds without a hit, stop and output the frozen imitator.

## 3. The theorem

**Remaining time.** For a notebook y, let τ(y) = min{m ≥ 0 : S(P^m(y))} be the number of the human's own steps from y to success (∞ if none). τ is defined by the human alone. Because P is deterministic and a function of the notebook:
* (T1) if τ(y) ≥ 1 then τ(P(y)) = τ(y) − 1;
* (T2) if τ(y) = 0 then τ(y ∪ g) = 0 for any appended entries g, because S is preserved by appending.

**Assumption (B_D), bounded setback.** Whenever the imitator, at a notebook y on one of its runs, appends entries g ≠ P(y) ∖ y, and neither y nor y ∪ g is bizarre:
* (B-omit) if g consists of some, not all, of the entries the human would have added (g = ∅ included), then τ(y ∪ g) ≤ τ(y);
* (B-commit) otherwise, τ(y ∪ g) ≤ τ(y) + D.

(B_D) mentions the imitator only through which notebooks and entries occur. The same inequalities for *every* non-bizarre y and g are a condition on the human alone, and imply (B_D). But that condition is too strong to believe, because it includes entries crafted to mislead, which the majority decoder does not write. Section 4 argues for (B_D) on the entries the decoder does write.

**Lemma S (slack turns one wrong step into many).** Suppose τ(x₀) ≤ n₀, every notebook on the run is non-bizarre, and (B_D) holds on the run. If the run fails, then |M| ≥ (σ+1)/(D+1).

*Proof.* Let τ_k = τ(x′_k). If the run fails, τ_n ≥ 1, so by (T2) τ_k ≥ 1 for every k ≤ n. By (T1), τ falls by exactly 1 at each of the n − |M| correct steps. By (B_D) it rises by at most D at each mistake, since (B-omit) is the case D = 0 of (B-commit). So 1 ≤ τ_n ≤ n₀ − (n − |M|) + D·|M| = (D+1)·|M| − σ. ∎

**Theorem 2 (online).** Assume τ(x₀ᵗ) ≤ n₀ for every problem, and (B_D) on every run. Under Protocol SI with the check and (M1)–(M3), for every sequence of problems, possibly chosen adaptively:

  E[#runs that fail the check] + ((σ+1)/((D+1)·n)) · E[#failed runs that pass the check] ≤ ⌊K⌋.

In particular, E[#failed runs] ≤ (D+1)·K/ρ, since (σ+1)/n > ρ. Without the check, assume (B_D) for all entries the imitator writes; then E[#failed runs] ≤ (D+1)·K/ρ directly.

*Proof.*
* *A run that fails the check.* By (M3) and append-only notebooks, the verdict along the run is 1…1 0…0. The first failing step is a step at which the imitator appended something bizarre, and by (M2) the human would not have. So it is a mistake, and the query lands on it with probability 1.
* *A failed run that passes the check.* By (M3), every notebook on it passes. By Lemma S it has at least (σ+1)/(D+1) mistakes. The uniform query lands on one with probability at least (σ+1)/((D+1)n).
* *The sum.* Apply Theorem 1 of without-a-check.md: the left side is at most E Σ_t q_t(M_t) ≤ ⌊K⌋. ∎

**Corollary 3 (i.i.d. problems).** Let problems be i.i.d., and let (B_D) hold on every run. Then with probability at least 1 − δ, SI-PAC outputs an imitator whose runs fail with probability at most ε. It uses at most

  Σ_{i ≤ ⌊K⌋+1} m_i ≤ (⌊K⌋+1)·⌈(D+1)·ln((⌊K⌋+1)(⌊K⌋+2)/δ)/(ρε)⌉

rounds, each with one task query, plus checks. With the check, "fail" means failing the check or failing S.

*Proof.*
* *Epochs.* Every epoch but the last ends with a hit, which is a task query on a mistake of the decoder in use. The later answers of the epoch are correct labels added after it. By Lemma 1 of note.md there are at most ⌊K⌋ hits, hence at most ⌊K⌋+1 epochs.
* *Error.* Suppose the frozen imitator of epoch i fails with probability p > ε. By the two cases in the proof of Theorem 2, each round is then a hit with probability at least γp > γε, and the rounds are independent given the frozen imitator. So it survives m_i rounds without a hit with probability at most (1 − γε)^{m_i} ≤ δ/(i(i+1)). A union bound over epochs gives total probability at most δ. ∎

**Verifiable problems.** Sometimes success can be checked at the end of a run: by a proof checker, a test suite, or the human's own verification of a finished result. Then slack imitation never outputs a failed run, and its cost has no factor 1/ε.

**Proposition 4 (with a verifier).** Let S be decided by a verifier V on final notebooks. As above, S must be preserved by appending, and the human's own runs must satisfy it (τ(x₀) ≤ n₀). Consider Protocol SI-V:
* for each problem, run the current imitator and apply V to the final notebook;
* if V accepts, output the run and go to the next problem;
* otherwise, keep the imitator fixed and task-query independent uniform steps of this run until one lands on a mistake;
* add that answer to the data, then the others, and rerun.

Then, for every sequence of problems:
* (a) no run that V rejects is ever output;
* (b) on every path, at most ⌊K⌋ runs are rejected in total;
* (c) the expected number of task queries is at most ⌊K⌋·(D+1)·n/(σ+1) ≤ (D+1)K/ρ under (B_D), and at most n·⌊K⌋ without it;
* (d) V is applied once per problem, plus at most ⌊K⌋ times.

*Proof.*
* (a) holds by construction.
* *A rejected run has a mistake.* A run with no mistake is the human's own run for n ≥ n₀ steps, which satisfies S because S is preserved by appending. So the search ends, and it ends with a task query on a mistake of the decoder in use, with the other answers added after it. Lemma 1 of note.md gives (b), and (d) follows.
* (c): by Lemma S, a rejected run has at least (σ+1)/(D+1) mistakes under (B_D), and at least one in any case. Each search is geometric, with success probability |M|/n given the past. Summing over at most ⌊K⌋ searches gives the bound. ∎

Output runs are correct exactly to the extent that V is sound for the real goal. With a verifier, then, bounded setback is needed only for the cost, never for correctness. A fooled human costs at most n task queries per rejected run, and still at most ⌊K⌋ rejected runs. Verification costs no human time if V is a machine. This is the first note's monitored bisection with the "on track" check replaced by a verifier of the result, and bisection replaced by uniform search, which slack makes cheap.

**Remarks.**
1. *Comparison.*
   * Chained imitation is the case σ = 0, D unrestricted: its bound n·K comes from failed runs with a single mistake.
   * Slack imitation replaces the factor n by (D+1)/ρ, for example by 4 for ρ = ½ and D = 1.
   * K is not changed. Thread B's knowledge-base and probe results (Theorem 4 there) reduce K but not n; they compose with this.
2. *The fallback.* Without (B_D), Theorem 1 of the second note still charges every failed run at least 1/n. So E[#failed] ≤ n·K, chained imitation's guarantee. More finely, a run fails only if the setbacks of its mistakes add up past σ: Σ_{k∈M}(1 + D_k) ≥ σ+1, where D_k is the actual setback at mistake k. Runs that fail through many small setbacks are charged at the good rate; only runs sunk by a few huge setbacks are charged at the 1/n rate.
3. *Read-out.* If the answer must be extracted from the notebook by one more step of the human ("which entry is the solution?"), that step is a single step, and its failures are not protected by slack. Query the read-out step with probability ½ and a uniform step otherwise. Then read-out failures are charged ½ each and the others ρ/(2(D+1)), so all failures together are at most 2(D+1)K/ρ in expectation.
4. *The hidden clock is not used in the proofs.* If the human sees the step, make the step part of the state and define τ(y, k) from step k. Then (T1), (T2) and Lemma S hold verbatim, with (B_D) read as τ(y ∪ g, k+1) ≤ τ(y, k) + D. The hidden clock matters only in Section 4: it makes an empty step exactly a one-step delay, and it removes deadline effects. E6 uses a visible step, with humans whose idea, once available, stays available.
5. *Average setback.* Lemma S uses only the sum of the setbacks along the run. If on every failed run the mistakes' setbacks average at most D̄, Lemma S and Theorem 2 hold with D̄ in place of D.

## 4. The case that humans have bounded setback

**Which entries occur.** The majority decoder appends, at a notebook y, the output of largest posterior mass. Thread C's Proposition 2: if the posterior is a product over items, it writes an item only if Pr[due]·Pr[the value | due] > 1 − Pr[due]. So its mistakes are of three kinds.
1. **Omissions.** It writes nothing, or part of the human's step, leaving out what it is unsure of: a rare insight, the specific choice the human would make. This is the typical mistake. The hidden-insight class, the lower-bound class, consists only of these.
2. **Predictable commissions.** It writes the predictable continuation, "the obvious idea", where the human would have written something else.
3. **Junk.** Output that a careful reader recognizes as nonsense. It is rare for the majority decoder, and the check catches it.

*Paraphrase.* Entries are text, and the decoder's text is rarely the human's, word for word. Formally, then, almost every step is a commission, and (B-omit) applies only to literal omissions. A faithful paraphrase of the human's own content needs (B-commit) with D = 0: rewording what it would have written does not slow the human down. I treat this as part of the omission case below.

**Omissions: (B-omit), with high confidence.**
* *Empty steps are free by determinism.* If the imitator appends nothing at y, the next notebook is y again. The hidden clock makes P(y) the same as one step earlier, so τ is unchanged. No assumption about the human is needed: the human does at step k+1 exactly what it would have done at step k.
* *Partial steps.* If the imitator writes part of the human's step, (B-omit) says that having done part of its own next step never makes the human slower to finish. I believe this for almost all of research work: a computation already done, a case already handled, a literature search already written up.
* *The exception I can find: by-product insights.* Suppose the human's insight would have come while doing a computation, and the imitator wrote the computation's result without the anomaly the human would have noticed. Then the human may never notice it.
  * If the notebook records what the human would have seen (data, intermediate steps), the human can still notice it on reading, and this is a delay.
  * If the imitator summarized the result instead ("consistent with the hypothesis"), the summary is a predictable commission, case 2.
* *Silent humans violate (B-omit),* and this is exactly the first note's lower-bound class. Its humans have an insight only at one step, never later on a notebook that lacks it. For a real researcher, an idea it would have had at month 3k from notebook y, it would still have at month 3(k+1) from the same notebook y plus partial work. The opposite would mean the idea depends on the date, not on what the researcher knows.

**Predictable commissions: (B-commit), the weak link.** Sorted by how the human responds:
* **Wrong, and the human checks.** For example: a claimed lemma that is false, code that fails its tests, a calculation with an error. A careful researcher who verifies before building notices it, writes a correction, and loses at most the steps it spent building on it. D is then the verification lag.
  * Scaffold design can shorten it with a standing instruction, "entries may contain errors; verify before you rely on them". The instruction is part of the human's task, so it is also in the reference chain whose n₀ steps define success.
  * For mathematics, and for software with tests, I would vouch for D of one or two steps.
* **A valid alternative.** The obvious idea also works. The human builds on it, and τ may even fall. No harm, *provided success is about the result*, which is why S is a property of the final notebook and not "contains the human's own result".
* **A slower alternative** (stage-specific choices). The imitator commits to direction B where the human would have chosen A. The human, seeing B under way, continues B: sunk cost, and a careful researcher does not restart without reason. D is B's extra time. If B fails, it is the time until the human sees that and turns to A. Bounded if directions fail visibly; unbounded if B never finishes and never visibly fails.
* **Wrong, plausible, and unchecked** (fooled). A result the human has not worked out itself, takes on trust, and never revisits. Examples are an empirical claim it cannot test, or a summary that hides the anomaly. D is unbounded. **This is the case I am least sure of.**
  * For pure mathematics and software it seems rare to me, because wrong claims lead to contradictions or failing tests.
  * For judgment-heavy or empirical work it is common in human practice.

**Junk: the check.** (M2), "the human never writes something bizarre", and (M3), bizarreness is a property of entries, are the assumptions I am most confident of in this note. The check is a recognition task ("is this nonsense?"), not the "has this gone off track?" judgment the user did not want to assume.

**Overall confidence**, as rough subjective guesses:
* the theorem as stated: high; it is short and refereed below;
* (B-omit): 90% for a careful researcher on theoretical work;
* (B-commit) with D ≤ 2: 70% for mathematics and code, 40% for empirical or judgment-heavy work;
* the scheme beating chained imitation by a large factor on a real deterministic human: about 75%, since most of the imitator's mistakes are omissions and the scheme loses nothing on the others.

**How to test it** (on real researchers, without any learner):
* *Omission test.* Hand a researcher its own notebook with the last step's work partly removed, and measure how much later it finishes.
* *Commission test.* Insert a plausible wrong entry, either an "obvious idea" that is worse than the researcher's or a false lemma. Measure the extra time to finish, and how often it never recovers. The distribution of D is the quantity the theorem needs.
* *By-product test.* Compare the insights found when the researcher does a computation itself with those found when it reads the computation's full record, and with a summary.

**The two optimizations in the original question.**
* *Querying where the predictor is most uncertain* can be mixed in. If at least half of each round's query distribution stays uniform, Theorem 2 holds with ρ/(2(D+1)) in place of ρ/(D+1). Omissions are uncertain steps, so the uncertain half finds them faster. Confident commissions are found only by the uniform half.
* *Querying where the run first goes off track* is not needed. Slack imitation never asks whether a run is on track. The slack absorbs the deviations that the human would recover from, and the uniform query finds the runs that still fail.

## 5. Why something like bounded setback is needed

* *The lower bound.* The first note's Theorem 3 gives Ω(nK/(ε log(n/ε))) for every task-only protocol, on the hidden-insight class. Its humans are silent. In that class a failed run has a single mistake, and only a query at that step reveals it.
* *Point versus threshold.* Thread D's frame: a single wrong step is a "point" defect, and point queries locate one in about n tries. Every n-free route found uses a human signal that is a threshold or group test:
  * a check that sees a defect from later steps (the first note);
  * persistence, where the human still adds the missing piece later (thread C);
  * located probes or an honest prover (threads B and D).
* *What slack imitation uses.* Slack uses the cheapest such signal: the human keeps working towards the result on a notebook that lacks something. Then one missing piece is a delay, not a failure. No check, judgment or self-report of the human is needed. The human only has to do what it does anyway, on notebooks a little different from its own.
* *Why slack is needed in addition.* Thread C's CHAIN experiment and E6 below show it. Without slack, the delays themselves are failures. A key idea written a few steps late leaves too little time for the work that depends on it, and that failure again has a single mistake.

## 6. Experiment E6

**Setup** ([`code/slack_imitation.py`](code/slack_imitation.py); exact posteriors).
* *Problems.* 100 problems per human. Problem p has an idea of value k_p, 1 ("the obvious idea", probability 0.9) or 2 (problem-specific). The idea becomes available to the human at a step t_p, uniform on [0, n₀).
* *The human.* A notebook builds on at most one value, with u units of dependent work on it. The human writes its idea once available, adds one unit of work per step to a notebook that builds on its idea, and on a notebook that builds on the wrong value:
  * builds on it (u + 1), if its idea is not yet available or u < D;
  * otherwise writes the correction and restarts the dependent work.
* *Success.* The final notebook builds on k_p with at least as many units as the human's own notebook at step n₀.
* *Five kinds of human.*
  * *noticing* (D = 0), *misled-2* (D = 2) and *misled-8* (D = 8): bounded setback;
  * *fooled:* never corrects, so D = ∞ for commissions;
  * *silent:* writes its idea only at step t_p, so unbounded setback for omissions; the first note's class.
* *Learner and protocols.* Every hypothesis knows the human's kind; (t_p, k_p) are unknown. The imitator is the majority decoder of the exact posterior. For the persistent kinds, the decoder of the prior writes the value 1 at about 0.53·n₀. So it makes all three kinds of mistake: late, wrong and missing ideas. For silent humans it never writes anything until queries locate t_p.
  * *Setbacks.* In the sense of Section 3 (with the step in the state, Remark 4), the noticing kind has setback at most 0 at every mistake and misled-D at most D. Silent humans have unbounded setback at a missed idea; fooled humans at a wrong value.
  * Protocols: CI without slack (σ = 0, n₀ = n), and three with slack σ = n/2: slack imitation SI (uniform step), the last step only (LAST), and MIX (the last step with probability ½, else uniform).
  * Each cell has 40 humans, the same 40 for every protocol at a given n. The entry is the mean number of task queries until at most 2% of the 100 problems fail (oracle stopping). LAST is capped at 40,000 queries, the others at 4,000·n.

**Results.** Mean task queries ± standard error; "stalls at x%" means the cap was reached with failure x%.

| protocol | human | n = 16 | n = 64 | n = 256 |
|---|---|---|---|---|
| CI, no slack | noticing | 6,012 ± 117 | 25,256 ± 709 | 97,489 ± 2,711 |
| CI, no slack | misled-2 | 6,012 ± 117 | 25,256 ± 709 | 97,589 ± 2,718 |
| CI, no slack | misled-8 | 6,022 ± 115 | 25,256 ± 709 | 97,589 ± 2,718 |
| CI, no slack | fooled | 6,022 ± 115 | 25,208 ± 707 | 97,568 ± 2,720 |
| CI, no slack | silent | 5,088 ± 93 | 22,845 ± 481 | 93,399 ± 2,022 |
| SI: CI with slack n/2 | noticing | 160 ± 12 | 204 ± 14 | 204 ± 14 |
| SI: CI with slack n/2 | misled-2 | 186 ± 14 | 208 ± 14 | 204 ± 14 |
| SI: CI with slack n/2 | misled-8 | 485 ± 40 | 227 ± 14 | 205 ± 14 |
| SI: CI with slack n/2 | fooled | 1,631 ± 124 | 2,811 ± 287 | 4,296 ± 469 |
| SI: CI with slack n/2 | silent | 4,467 ± 107 | 21,964 ± 424 | 92,819 ± 2,130 |
| MIX with slack n/2 | noticing | 143 ± 10 | 169 ± 11 | 161 ± 11 |
| MIX with slack n/2 | misled-2 | 152 ± 14 | 172 ± 12 | 161 ± 11 |
| MIX with slack n/2 | misled-8 | 203 ± 19 | 180 ± 12 | 164 ± 10 |
| MIX with slack n/2 | fooled | 2,847 ± 202 | 7,130 ± 723 | 7,864 ± 982 |
| MIX with slack n/2 | silent | 9,271 ± 180 | 42,292 ± 841 | 178,644 ± 3,697 |
| LAST with slack n/2 | noticing | 123 ± 9 | 156 ± 10 | 142 ± 11 |
| LAST with slack n/2 | misled-2 | 123 ± 9 | 156 ± 10 | 142 ± 11 |
| LAST with slack n/2 | misled-8 | 123 ± 9 | 156 ± 10 | 142 ± 11 |
| LAST with slack n/2 | fooled | stalls at 10% | stalls at 10% | stalls at 10% |
| LAST with slack n/2 | silent | stalls at 100% | stalls at 100% | stalls at 100% |

The table is `results/slack_imitation_table.md`, written by `slack_imitation.py ../results --table`.

**Reading.**
* *Without slack, every kind pays in proportion to n,* as in thread C's CHAIN experiment. An idea written a little late leaves too little time for the work that depends on it, and such a failure has few mistakes.
* *With slack, the bounded-setback kinds cost about 200 task queries at every n.* About 20 of them land on mistakes, at every n. Misled-8 at n = 16 is the exception that fits the theorem: there σ = 8 = D, so Lemma S guarantees only one mistake per failed run, and it costs 485.
* *Fooled humans grow with n* (×2.6 over a 16-fold range), while the bounded-setback kinds do not. They grow more slowly than n only because of a feature of this class: a query before the decoder's guess, answered "nothing yet", reveals that t_p is later. Nothing in the theorem gives this.
* *Silent humans cost the same with and without slack,* in proportion to n: a missed idea is never recovered, however long the run.
* *Asking at the last step* is the cheapest protocol for the bounded-setback kinds, 120–160. Their failed runs end with a mistake: at the last step the human would still write or correct the idea (thread C's "ripe" failures). LAST has no guarantee, though. It stalls at 10% failure for fooled humans (the problems where the obvious idea was wrong) and at 100% for silent ones.
* *MIX,* half last step and half uniform, gets most of LAST's advantage on bounded-setback humans. On the others it costs about twice what slack imitation costs, because only half its queries are uniform. I recommend SI for its guarantee, and MIX where one expects most failures to be ripe.

**With a verifier (Proposition 4).** Protocol SI-V on the same humans, with slack n/2 (`slack_imitation.py ../results --verifier`). Each problem is rerun until its final notebook succeeds, so every output is correct. The entry is the total number of task queries for all 100 problems (± standard error over 40 humans), and in parentheses the number of task queries per rejected run.

| human | n = 16 | n = 64 | n = 256 |
|---|---|---|---|
| noticing | 13 ± 1 (1.3) | 14 ± 1 (1.4) | 14 ± 1 (1.4) |
| misled-2 | 14 ± 1 (1.4) | 14 ± 1 (1.4) | 14 ± 1 (1.4) |
| misled-8 | 38 ± 3 (3.6) | 16 ± 1 (1.5) | 14 ± 1 (1.4) |
| fooled | 181 ± 13 (12.4) | 750 ± 76 (39.0) | 2,636 ± 238 (143) |
| silent | 1,610 ± 24 (16.1) | 6,450 ± 111 (64.5) | 26,091 ± 385 (261) |

* *Bounded-setback humans* need about 14 task queries for all 100 problems, at every n. Only the ten or so problems whose idea is the specific one are ever rejected, and each rejected run has so many mistakes that the first query or two finds one.
* *Fooled and silent humans* cost about n/2 task queries per rejected run, as Proposition 4(c) allows. Their outputs are still all correct.
* Compared with SI without a verifier (about 200 task queries for 2% failure), the verifier removes the cost of *detecting* failures. That cost is the 1/ε factor.

**What E6 does not show.** The class is tiny, so K is small and the posterior exact; the point is the dependence on n and on the kind of human. It does not test whether real humans have bounded setback, which only the tests of Section 4 can.

## 7. How the alternatives compare

| scheme | what it asks of the human | failed runs or queries | my confidence it works |
|---|---|---|---|
| chained imitation (the talk) | nothing | n·K failed runs; n·K/ε queries | works, at the factor n |
| end-weighted (second note) | (C_r): from the imitator's state r steps before the end, the human's own r steps succeed | 2r·H_n·K failed runs under (C_r); 2n·K always | (C_r) is a condition on the imitator's states, hard to assess (the user's objection) |
| monitored bisection (first note) | a preserved "on track" check | ≤ K failed runs, K task queries plus checks | the check is the assumption the user did not want |
| nothing-bizarre check alone (thread A) | a preserved junk check | ≤ K junk runs; says nothing about other failures | high, but weak |
| last step + persistence, Protocol Z and BIS (thread C) | persistence (P₁) on non-bizarre notebooks | ≤ K ripe failures; late ideas not caught without slack | medium; BIS beyond toy classes not shown |
| **slack imitation (this note)** | **bounded setback D** | **(D+1)K/ρ failed runs; O((D+1)K log(K/δ)/(ρε)) queries** | **high for omissions, medium for commissions** |
| **slack imitation with a verifier (Proposition 4)** | **bounded setback, for the cost only** | **no failed run output; ≤ K rejected runs; (D+1)K/ρ task queries (n·K without (B_D))** | **high, where the result is verifiable** |
| probes / knowledge base (thread B) | answers to located questions | reduces K, not n | composes with any of the above |

## 8. Limits

* *Exact Bayes.* The theorem is about the Solomonoff majority decoder. A practical learner has no Lemma 1 of note.md. The earlier notes' caveat applies: these are statements about what the information in the queries allows.
* *Determinism.* A stochastic human breaks "an empty step is exactly a delay" (the human might not have the idea next time). It also breaks the charge of a bit per mistake in Lemma 1 of note.md.
* *The world.* If a step of the human involves experiments, the imitator must predict their outcomes. The notebook model covers thinking work.
* *Success must be preserved by appending,* and the human's chain must succeed within n₀ steps with the hidden clock. If the human only finishes because it knows the deadline, the hidden clock changes the reference.
* *The size of K.* "O(K) queries" is the request. Whether K(human), given a corpus, is small enough to make that practical is outside this note.

## 9. Open

1. Measure D on humans, with the tests of Section 4.
2. A commission-safe imitator. An imitator that writes only content the human would write (omissions only) would need only (B-omit). The majority decoder commits whenever the content is predictable. Abstaining below a confidence 1 − α costs a factor of about 1/α in Lemma 1 of note.md. Is there a better trade-off?
3. Composition with BIS. BIS (thread C) found the exact step of a missed insight in log₂ n queries in CHAIN, which removes lateness without slack. Does it carry over beyond such classes?
4. Trees. Slack for decomposition trees (time budget per subtask) should give the same theorem with the tree's critical path in place of n; not worked out.
