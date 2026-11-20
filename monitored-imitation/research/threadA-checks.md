# Thread A: which check?

*A research report for [`../note.md`](../note.md), by Claude. Draft; no referee has checked it. Code: [`threadA_drops.py`](threadA_drops.py); output: [`threadA_drops.out`](threadA_drops.out) (seeded, about 90 s).*

## Answers in brief

1. **Preservation affects cost, not correctness** (Lemma A). Bisection on *any* yes/no judgment ends at a step that is a mistake of the decoder or identical to the human's own step. One task query tells which, and its answer is true data either way. So verdicts only decide where to ask: a wrong verdict wastes a query and never teaches anything false.
2. **No believable preserved check certifies outcomes** (Proposition B). A preserved check that implies "the run ends as well as the human's" passes only states from which the human's own continuation would succeed. That is the on-track judgment, which assumes foresight.
3. **Local judgments cannot localise** (Theorem C). A review of one step ("one I'd be happy with", "as good as mine") tells no more than a task query there.
   * On the hidden-insight class, task queries and step reviews together number Ω(n·K/(ε log(n/ε))).
   * Each of prefix endorsement's ⌈log₂ n⌉ checks contains up to n step reviews.
   * note.md's monitor gets its log n because one look judges an AND over the human's would-be past. A human can do that only for knowledge it already holds when it looks.
4. **Under Proposition 9, drops hide later mistakes; excuse lists fix this** (Theorem D, experiment A1).
   * *Without excuses:* A1 leaves 10–13% of problems wrong for ever.
   * *With them:* the human names what it sees wrong, and later checks ask "anything wrong that is not on the list?".
   * *Guarantee:* nothing the human can see is wrong in an output except listed items, and each item became visible at a step where the imitator did exactly what the human would have done.
5. **Drops cost task queries:** ⌊K⌋ plus the number of distinct drop states met. For a frozen imitator that is ⌊K⌋ + O(ē·K·log(K/δ)/ε), where ē is the expected number of drops per run.
   * O(K) needs ē ≲ ε.
   * Otherwise the saving over chained imitation's n·K/ε is a factor of order n/(ē·log(K/δ)).
   * Excused runs must be scored as passes. Otherwise a stopping rule can end up accepting only decoders that suppress the human's bad news (Observation E).
6. **Recommendation** (Section 5).
   * *The check:* "is anything in this state wrong that is not on the list?", asked as the first part of the human's own next step.
   * *The protocol:* MBX, with hindsight bisection and audits.
   * *Assumed:* verdicts are a fixed function of the state and the list; a longer list never makes a verdict stricter; once it has named what it sees, the human passes the state.
   * *Not assumed:* preservation, soundness.
7. **Not certified:** outcomes as good as the human's; the human's discoveries and repairs; errors that look right. Those are left to audits, at chained imitation's rate. note.md's Theorem 3 says that rate is optimal in the worst case.

## 1. Two jobs, three facts

Setting and notation are those of note.md §1 and §5.
* *Lemma 1 there:* at most ⌊K⌋ pairs (x, P(x)) added to the data are mistakes of the then-current decoder. Its proof uses only that the labels are P's.
* A *check* is any yes/no question about a state; f(x) = 1 means "fine".
* Drop_f := {x : f(x) = 1, f(P(x)) = 0}.

A check has two jobs:
* *localisation:* a 1→0 flip on an imitator run points at a step to task-query;
* *certification:* what passing tells us about the run.

Preservation serves localisation, soundness serves certification.

**Lemma A (any check localises).** Let f be any predicate, and x′ a run of the current decoder G with f(x′_a) = 1 and f(x′_b) = 0.
* Bisection with ⌈log₂(b−a)⌉ evaluations of f finds j with f(x′_j) = 1 and f(x′_{j+1}) = 0.
* Then either G(x′_j) ≠ P(x′_j), and adding the answer is one of Lemma 1's ⌊K⌋ mistakes; or x′_{j+1} = P(x′_j) and x′_j ∈ Drop_f.

*Proof.* Bisection as in note.md's Lemma 5. If G(x′_j) = P(x′_j), then f(P(x′_j)) = f(x′_{j+1}) = 0. ∎

So f may be anything the human can answer: a check against an excuse list, a hindsight check, a question about the step counter. Preservation (Drop_f = ∅) only makes every flip a mistake. note.md's Proposition 9 is the case f = V.

**Proposition B (outcome certificates need foresight).** Let states record r(x), the number of steps still to go, and let Succ be a predicate on final states (r = 0). Write V*(x) := Succ(P^{r(x)}(x)): "the human's own continuation from x succeeds". Call V *final-sound* if V(x) = 1 and r(x) = 0 imply Succ(x).
* (a) If V is final-sound and V(x) = 1, then V*(x) = 1, unless the human's continuation from x meets Drop_V.
* (b) So a preserved, final-sound V satisfies V ≤ V*.
* (c) V* is itself preserved and final-sound, so it is the largest such check.

*Proof.* (a) Along x, P(x), …, P^{r(x)}(x), V stays 1 unless it meets Drop_V; then use final soundness. (c) P^{r(x)−1}(P(x)) = P^{r(x)}(x). ∎

With Succ = "as good as the human's own result on this problem", a preserved check that certifies Succ passes only states from which the human can tell it would still reach its own standard: the on-track judgment.

A cheap, believably preserved check certifies only a Succ that the human's continuation keeps from every passing state. "Contains no junk" is the clear example.

**Theorem C (local judgments cannot localise).** Call a check rule *s-local* if each answer equals c(query, P(z₁), …, P(z_s)), for a fixed function c and states z_i determined by the query.
* A step review E(x, y) = e(x, y, P(x)) is 1-local. Reviewing a prefix of L steps is L-local.
* On the hidden-insight class of note.md §3, with any s-local review rule, let a protocol make Q task queries and checks of total locality S (adaptively, possibly at random). Then it fails with probability at least (1−1/q)·η·(1 − 2(Q+S)/(nm)).
* So for ε ≤ 1/16, Q + S ≥ nm/4 ≥ n·E[K]/(32·ε·log₂(en/(4ε))).

*Proof.* Replace each check by task queries at z₁, …, z_s and evaluate c. The result is a task-only protocol with Q + S queries (in expectation, which Theorem 3 allows) and the same output law. Apply note.md's Theorem 3. ∎

**What this says about note.md's monitor.** In that class, the monitor of note.md §5.2 at step j is j-local. On the class-prior decoder's runs, which write an insight only at its confirmed step, it equals the AND of the exact endorsements [x′_{i+1} = P(x′_i)] over i < j.
* So "the human can see that the run has gone off track" means: j step reviews, answered in one look.
* That is believable for knowledge the human holds when it looks, such as a known technique that plainly belongs in the draft.
* It is not believable for what the human would find only by working. There, reviews cost as much as task queries.

**Endorsement-gated chained imitation** meets the bound up to the log. Review one uniform step per run, and task-query it only if it is unendorsed. Assume self-endorsement, E(x, P(x)) = 1 for every x. Then:
* every task query lands on a mistake, so there are at most ⌊K⌋;
* the expected number of runs with an unendorsed step is at most n·⌊K⌋ (the proof of note.md's Proposition 2).

So reviews take the factor n/ε away from the task queries, but do not remove it.

## 2. Excuse lists: drops without blind spots

**Why Proposition 9 is not enough.** After a drop, a plain check stays 0 at every later state. An imitator mistake after the drop then makes no flip, and bisection lands on the drop. In A1 (Section 4) this leaves η₁η₂·Pr[t₂ ≥ t₁+2] ≈ 10–13% of problems wrong for ever.

**Checks with a list.** A list L is a set of written descriptions of problems. The human answers:
* V(x; L): "is anything wrong in x that is not on L?" (1 means no);
* N(x; L): "name what is wrong in x and not on L".

Assume:
* **(X0)** V and N are fixed functions, as P is;
* **(X1)** L ⊆ L′ implies V(x; L) ≤ V(x; L′);
* **(X2)** V(x; L ∪ N(x; L)) = 1.

**Protocol MBX.** Keep D (answers at mistakes) and a side table S (answers at drop states). For each problem x₀:
1. Set L := N(x₀; ∅), normally empty, and a := 0. Run G_D from x₀.
2. If V(x′ₙ; L) = 1, output (x′, L).
3. Otherwise, bisect [a, n] with f = V(·; L) to a flip j. Look up P(x′_j) in D ∪ S, or task-query it.
4. If G(x′_j) ≠ P(x′_j), add the answer to D and go to 1.
5. Otherwise, add it to S, set L := L ∪ N(x′_{j+1}; L) and a := j+1, and go to 2.

**Theorem D.** Assume (X0)–(X2), but not preservation. For every sequence of problems:
* (a) every output (x′, L) has V(x′ₙ; L) = 1;
* (b) every item of L \ L₀ was named at x′_{j+1} = P(x′_j), with V(x′_j; L_before) = 1. It became visible at a step where the imitator did exactly what the human would have done from that state;
* (c) at most ⌊K⌋ runs are rerun, and there are at most ⌊K⌋ + |S| task queries;
* (d) a run with e drops costs at most (e+1)(1+⌈log₂ n⌉) checks and e naming queries;
* (e) if every V(·; L) is preserved, then S = ∅ and MBX is MB, with note.md's Theorem 6.

*Proof.*
* (a) and (b) hold by construction. (X2) keeps f(x′_a) = 1.
* D changes only in step 4, which reruns. So each addition is a mistake of the decoder that made the run, and Lemma 1 gives (c).
* Each drop increases a, so a run has at most n drops and ends in an output or a rerun.
* (d) Each pass through steps 2–3 costs 1 + ⌈log₂ n⌉ checks.
* (e) is Lemma A. ∎

**Corollary (attribution).** Suppose also that there is a set Prob(x) of visible problems with:
* V(x; L) = [Prob(x) ⊆ cov(L)];
* N naming exactly Prob(x) \ cov(L);
* cov(L₀) = Prob(x₀).

Then Prob(x′ₙ) ⊆ Prob(x₀) ∪ ⋃ᵢ (Prob(P(x′_{jᵢ})) \ Prob(x′_{jᵢ})). Every visible problem of an output was in the problem statement or was created by a step identical to the human's.

*Proof.* Prob(x′_{jᵢ}) ⊆ cov(L_{i−1}). So the items named at x′_{jᵢ+1} lie in Prob(P(x′_{jᵢ})) \ Prob(x′_{jᵢ}). ∎

**Extensions.**
* *Hindsight bisection.* Suppose an item π named at step j was already present in x′_j, for example a lemma now found false. Bisect [0, j] with h_π(x) = "x does not contain π", a very easy check.
  * By Lemma A the flip found is either an imitator mistake, which is then learned, or a human-identical step that introduced π.
  * Cost: at most ⌈log₂ n⌉ checks and one task query per item.
  * Errors that were invisible when made, but are revealed later by human-like work, are then localised too.
* *Audits compose* (note.md's Proposition 10, same proof). After each output, with probability β, task-query a uniform step. Then E Σ_t M_t ≤ n·⌊K⌋/β, where M_t counts all mistakes on output run t, visible or not. Audits share the ⌊K⌋ budget.
* *Sampled excuses.* Task-query only a fraction α of drops, and excuse the rest unchecked. Then at most ⌊K⌋/α mistake-flips are excused unchecked, in expectation. Their defects are still listed, so outputs stay honest; only attribution is lost.
* *Frozen imitator.* Run MB-PAC (note.md's Theorem 7, with B = 1) with excuse answers kept in S, so the decoder is fixed within each epoch. Say a run *fails* if MBX's processing finds a mistake.
  * The epoch count and Theorem 7(c) hold verbatim. Under the Corollary's assumptions, every run ending with a visible problem the imitator created fails.
  * Task queries are at most ⌊K⌋ + |S|, with E|S| ≤ ē·N. Here N = O((K+1)·log((K+1)/δ)/ε) is the number of runs examined, and ē bounds the expected number of new drop states per run.
  * Bounding ē on imitator runs by the human's rate is note.md's open problem 6.

**Observation E (scoring drops as failures favours ignorance).** Let P and H be the only hypotheses left. They agree except at a state z reached by a fraction e > ε of problems, where P drops (for example, it retracts a lemma) and H does not.
* If w(H) > w(P), the decoder follows H at z. Its runs pass the check, no flip ever points at z, and it is silently wrong on a fraction e of problems.
* If w(P) > w(H), the decoder is right at z, and a fraction e of its runs fail the plain check. Every bisection lands on z, where it is already right, so the decoder never changes.
* So MB-PAC scored by the plain check can stop only with the decoder that suppresses the bad news.
* Scoring excused runs as passes accepts both decoders; only audits find z.
* On-track checks drop at every piece of bad news, so they always face this.

## 3. The candidates

A *look* is one check of a state; a *step review* judges one step in its context. "Excused" refers to Theorem D(b).

| check | an output is certified to… | human cost per output / per failure | preservation fails when… | blind to |
|---|---|---|---|---|
| V_bizarre: nothing I'd recognise as junk, sabotage or non-work | contain no junk, except excused junk | 1 skim / ⌈log₂ n⌉ skims; batching (M3) plausible | handed a corrupted state, the human abandons the task: rare | almost all of the majority decoder's mistakes, which are its best guesses at the human |
| prefix endorsement E(x, y) | have every step endorsed or human-identical | n step reviews / fewer than n more (none if the reviewer names the failing step) | the reviewer catches the author's own error; the bar set is the human's best work, not its typical work | subtle errors, dead ends, discoveries the reviewer hasn't made |
| on track: "I could still finish from here" | succeed, if the judgment is calibrated (Prop. B) | 1 look / ⌈log₂ n⌉ looks | at each piece of bad news from the human's own work: plausibly O(1) per research run | failures to discover bad news, which it favours (Obs. E) |
| sign-off, matching: "as far along as I'd be" | about the same as on track | 1 / ⌈log₂ n⌉ | the human's own progress falls short of its forecast | states that overstate their progress, which pass |
| flag in the human's step | whatever the flag covers | a partial task query | as for its content | as for its content |
| comparison of outputs: "is A better than B?" | nothing; it selects on a graded judgment (note.md §6.3) | — | — | favours outputs that look better without being better |
| **defect check with an excuse list** (= sign-off at the floor: "I'd put my name to this") | have nothing visibly wrong except listed items, each first visible at a human-identical step | 1 look / (e+1)(1+⌈log₂ n⌉) looks | a fresh read finds something wrong in the human's own step, or the human retracts its own earlier claim | errors that look right; discoveries; listed items the human would later have repaired |

**V_bizarre** is the most believable check and nearly useless for quality.
* In exact Bayes the decoder's mistakes are its most probable continuations (robust-runs.md §3), so they are rarely junk.
* It catches odd or malign hypotheses that win the vote (note.md's P ≠ NP example). Keep it as the floor of the defect check.

**Prefix endorsement.**
* *Strength.* It is local, so a drop at one step can be excused without hiding the others. Every step of an output is then endorsed or human-identical. That is robust-runs.md's corrupted runs with replacements restricted to *endorsed* ones: a condition on the human alone.
* *Outcomes.* It certifies outcomes only if E(x, y) = 1 ⇒ V*(y) ≥ V*(P(x)) (then V* never decreases along the run). That is foresight again, false for a plausible lemma with a subtle error.
* *Cost.* It needs n step reviews per output, and Theorem C shows the cost is intrinsic.
* *Bisection over prefixes.* It needs fewer than 2n step reviews if each probe reviews only the new steps, and n⌈log₂ n⌉ if every probe rereads its whole prefix.
* *Reading volume.* If states are full logs, a look at x_k also reads k steps. A state check then saves the *kind* of judgment (one verdict on the whole, not k counterfactual ones), not the volume read. Its log n gain in reading needs compact states, such as the current draft.

**On track and matching sign-off** are where outcome certification lives (Proposition B). But their drops are the human's discoveries of bad news, and these are frequent in research.
* With MBX they become usable: drops are excused and attributed, and hindsight locates the step that committed to the dead end.
* Their cost is O(ē·K·log(K/δ)/ε) task queries, with ē plausibly of order 1.

**Flags in the human's step.** Let P(x) = (R(x), W(x)), where R(x) is what the human writes first: "before continuing, what is wrong with this draft?". A check asks for R(x) alone. Two consequences:
* *Checks become training data.* Decode R first, by its marginal majority, and add each answer R(x) after the run's processing. A review that differs from the imitator's predicted one has posterior mass at most 1/2, so it costs a bit of K: Lemma 1's telescoping does not need full labels.
  * Hence these disagreeing reviews and the task queries at mistakes together number at most ⌊K⌋.
  * The imitator learns to review its own states (note.md's open problem 3).
* *Preservation by construction, of honesty only.* Close every step with a fresh call "list what is wrong in your output", appended to the state. With memoryless, deterministic calls, the human's own steps then pass any check that ignores acknowledged problems.
  * But that check certifies only honesty. An imitator that creates a problem and then acknowledges it passes, and its culprit step is never located.
  * So the recommended check counts acknowledged problems too, and only the protocol's excuse list excuses anything. A retraction by a human-identical step is then a drop, and hindsight finds where the retracted claim came from.

**Comparisons.**
* The useful comparative form is incremental: "anything wrong in x that was not wrong in b?", a review of a cumulative diff. That is the excuse-list check.
* Comparing candidate outputs is selection on a graded judgment.
* "Is y at least as good as x?" cannot see missing progress: a run that does nothing passes.

## 4. Experiment A1: drops, excuses and endorsement

**The class.** The hidden-insight class with three independent insights per problem.
* Their probabilities are (0.5, 0.5, 0.2), at uniform steps; m = 100, q large, and the human is silent.
* Insights 1 and 2 are visible: missing them is an omission the human sees, by note.md §5.2's timing. Insight 3 is invisible.
* One step after insight 1, the human writes a persistent note, "having insight 1, I see the earlier approach was flawed". The rule is generic, and every decoder knows it.
* V_strict counts the note as a defect. V_ack does not, and is preserved. V_strict with the list {note} is V_ack.

**Measurement.** Posteriors are exact.
* F_vis is the probability that the decoder's final state misses a visible insight; F_diff, that its run differs from the human's.
* Entries are means over 10 humans: task queries, and checks or step reviews, when F_vis first reaches 2%. The last column is the final F_vis.
* The caps are 4,000 runs, and 40,000 for CI, RG and MBX+A.

| protocol | n = 16 | n = 64 | n = 256 | final F_vis (n = 16 / 64 / 256) |
|---|---|---|---|---|
| CI | 1,863 task | 7,600 | not reached by 40,000 | 0.02 / 0.02 / 0.21 |
| RG (endorsement-gated CI) | 98 task + 5,386 reviews | 100 + 23,564 | not reached | 0 / 0 / 0.21 |
| PE (prefix endorsement) | 97 task + 6,611 reviews | 99 + 24,478 | 97 + 109,893 | 0 |
| MB + Prop. 9, V_strict | never | never | never | 0.098 / 0.122 / 0.126 |
| **MBX**, V_strict + excuses | 141 task + 1,714 checks | 148 + 2,301 | 146 + 3,086 | 0 |
| MB, V_ack (preserved) | 97 task + 847 checks | 99 + 1,028 | 97 + 1,252 | 0 |

**Results.**
* *Proposition 9's blind spot.* MB with Proposition 9 is stuck at the predicted η₁η₂·Pr[t₂ ≥ t₁+2], and half of its outputs are marked.
* *Excuses.*
  * MBX reaches the target. Its 45–50 extra task queries are the distinct drop states, one per problem whose insight 1 is learned.
  * Here problems recur, so each drop state is queried once. If no problem recurred, every excused run (about 1,850–2,000 per 4,000) would cost a task query. That is the ē·N term.
* *Endorsement.* Step reviews grow in proportion to n; MB's checks grow like log n (Theorem C).
* *Silent failures.*
  * Every check-only protocol ends with F_diff at 0.18–0.21, the invisible insight 3.
  * MBX with audits (β = 1) reaches F_diff ≤ 2% with 1,434 and 5,764 task queries at n = 16 and 64, and for 4 of 10 humans at n = 256 (18,886). CI needs 1,881 and 7,642.

## 5. Recommendation

**The check.** "Is anything in this state wrong that is not on the list?" Here *wrong* means:
* junk, sabotage, or text that is not an honest attempt at the task;
* a claim the human believes false or unjustified, unless it was stated as a conjecture or as unverified. A claim the text later retracts still counts;
* a problem the human sees that the text hides or glosses over;
* an omission: something the human already knows that plainly bears on what the state does, which the state neither uses nor sets aside.
  * This is what sees deficits of held knowledge, as in note.md §5.2.
  * It drops when the human's own process would use that knowledge later than the check expects.
  * "I'd have proved more by now" is a forecast, not an omission.

Honestly reported dead ends, open questions and conjectures are not wrong.

Ask it as the first part of the human's own next step, so that the verdict and the naming are one act and can train the imitator's reviews (Section 3).

**The protocol.** MBX with hindsight bisection, plus audits at rate β on output runs.
* For a frozen imitator, use MB-PAC with excused runs scored as passes.
* If intermediate states matter, check prefixes, at the reading cost of Section 3.

**Its guarantee** (Theorem D, its Corollary, hindsight, audits). For every sequence of problems:
* *The list.* Every output carries a list, and on the human's careful read nothing in its final state is wrong except listed items.
* *Attribution.* Each item became visible at a step where the imitator did exactly what the human would have done from that state. With hindsight, the item was also introduced at such a step.
  * So no output contains a defect that was visible when the imitator created it by deviating from the human.
  * Nor, with hindsight, one that a human-identical step later reveals.
* *Task queries.* At most ⌊K⌋ runs are rerun, and there are at most ⌊K⌋ + |S| task queries. Hindsight adds at most one per listed item.
* *Checks.* A run with e drops costs at most (e+1)(1+⌈log₂ n⌉) checks, plus ⌈log₂ n⌉ per listed item for hindsight.
* *Audits.* Output runs contain at most n·⌊K⌋/β mistakes of any kind, in expectation.

**Its assumptions, and how believable they are.**
* **(X1)** A longer list never makes a verdict stricter: near-tautological.
* **(X2)** The human can say what it sees wrong, and then passes the state with those items listed. True of careful people; vague unease can be listed as such.
* **(X0)** Verdicts are a fixed function of the state and the list. This is the model's idealisation, as for P.
  * Real verdicts are noisy. A noisy flip costs a task query and excuses a real problem, but never puts a false label into the data (Lemma A).
  * Noise does weaken the Corollary's attribution, which also needs "the same problem" to be identified consistently across queries.
* **Efficiency.** The cost is O(K) only if ē is small: below ε for a frozen imitator, below K/T over T problems online.
  * Here ē is about the number of times per run that the human's own step holds something wrong its own fresh read would catch: a slip, an overclaim, an unflagged gap, a retraction of its own earlier claim.
  * A closing self-review in each step lowers ē.
  * ē can be measured: give researchers their own earlier outputs to re-read cold.
  * If ē is not small, the protocol stays correct, and costs ⌊K⌋ + O(ē·K·log(K/δ)/ε) task queries.
* **(M3)** Batching is needed only for batched checks, and is believable only for salient defects such as junk.

**What it does not guarantee.**
1. *Outcomes as good as the human's* (Proposition B). An on-track tier can be added through MBX, at the price of Observation E's drops.
2. *Discoveries,* and anything else the human would find only by working (Theorem C, and note.md's Theorem 3). Only audits, at chained imitation's rate, or persistence (without-a-check.md) reach them.
3. *Errors that look right* to a careful reader.
4. *Repairs.* A listed item the human would later have fixed, but the imitator does not, stays in the output, though it is listed.
5. *The drop rate on imitator runs* compared with the human's.
6. *Persuasion.* MBX never selects outputs by the verdict, but nothing stops a state from talking the reader past a defect.
7. *Stochastic humans,* and the reading cost of very large states.
