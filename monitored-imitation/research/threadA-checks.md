# Thread A: which check?

*A research report for [`../note.md`](../note.md), by Claude. Draft; no referee has checked it. Code: [`threadA_drops.py`](threadA_drops.py), output [`threadA_drops.out`](threadA_drops.out) (seeded, about 90 s).*

## Answers in brief

1. **Preservation affects the cost, not correctness** (Lemma A). Bisection on *any* yes/no judgment of states ends at a step that is either a mistake of the decoder or a step identical to the human's own. One task query tells which, and its answer is true data either way. So the human's verdicts only decide where to ask: a wrong verdict wastes a query and never teaches anything false.
2. **No believable preserved check certifies outcomes** (Proposition B). A check that is preserved and implies "the run ends as well as the human's" passes only states from which the human's own continuation would succeed. That is the on-track judgment, or something stronger.
3. **Local judgments cannot localise** (Theorem C). A review of one step ("a step I'd be happy with", "as good as mine") tells no more than a task query at that step.
   * On the hidden-insight class, any mix of task queries and step reviews needs Ω(n·K/(ε log(n/ε))) of them.
   * Prefix endorsement's ⌈log₂ n⌉ checks each contain up to n step reviews.
   * note.md's monitor gets its log n because one look judges an AND over the human's would-be past ("what I'd have by now"). A human can do that only for knowledge it already holds when it looks.
4. **Under Proposition 9, drops hide later mistakes; excuse lists fix this** (Theorem D, E5).
   * *The problem.* After a drop, a plain check stays failed, so the imitator's later mistakes are invisible. In E5, 10–13% of problems stay wrong for ever.
   * *The fix.* The human names what it sees wrong, and later checks ask "anything wrong that is not on the list?". Bisection then continues past the drop.
   * *Guarantee.* Nothing the human can see is wrong in an output except listed items. Each listed item became visible at a step where the imitator did exactly what the human would have done.
5. **What drops cost.** Task queries are at most ⌊K⌋ plus the number of distinct drop states met. For a frozen imitator that is ⌊K⌋ + O(ē·K·log(K/δ)/ε), where ē is the expected number of drops per run.
   * O(K) needs ē ≲ ε.
   * Otherwise the saving over chained imitation's n·K/ε is a factor of order n/(ē·log(K/δ)).
6. **Score excused runs as passes** (Observation E). If drops count as failures, a stopping rule can only accept decoders that suppress the human's bad news. On-track checks have this problem built in.
7. **Recommendation** (Section 5). Use a *defect check with an excuse list*: "is anything in this state wrong that is not on the list?".
   * *What counts as wrong:* junk, sabotage or non-work; claims the human thinks false or unjustified, unless stated as conjectures (a claim the text later retracts still counts); and problems the text hides.
   * *How it is asked:* as the first part of the human's own next step.
   * *Protocol:* MBX, with hindsight bisection and audits.
   * *Assumed:* verdicts are a fixed function of the state and the list; a longer list never makes a verdict stricter; after naming what it sees, the human passes the state.
   * *Not assumed:* preservation, soundness.
8. **It does not certify:**
   * that outcomes are as good as the human's;
   * that the imitator makes the human's discoveries or repairs what the human would repair;
   * anything about errors that look right.

   Those are left to audits, at chained imitation's rate. Theorem 3 of note.md says that rate cannot be beaten in the worst case without further structure.

## 1. Two jobs, three facts

The setting is note.md §1: a deterministic human P, prior w, K = K(P), the majority decoder G_D, and Lemma 1 (at most ⌊K⌋ pairs (x, P(x)) added to the data are mistakes of the then-current decoder; the proof uses only that the labels are P's).
* A *check* is any yes/no question about a state that the human answers; f(x) = 1 means "fine".
* Drop_f := {x : f(x) = 1, f(P(x)) = 0}.

A check does two jobs:
* *localisation:* a 1→0 flip on an imitator run points at a step to task-query;
* *certification:* what passing tells us about the run.

Preservation serves the first job, soundness the second.

**Lemma A (any check localises).** Let f be any predicate, and x′ a run of the current decoder G with f(x′_a) = 1 and f(x′_b) = 0. Then:
* bisection with ⌈log₂(b−a)⌉ evaluations of f finds j ∈ [a, b) with f(x′_j) = 1 and f(x′_{j+1}) = 0;
* either G(x′_j) ≠ P(x′_j), and adding (x′_j, P(x′_j)) is one of Lemma 1's ⌊K⌋ mistakes, or x′_{j+1} = P(x′_j) and x′_j ∈ Drop_f.

*Proof.* Bisection as in note.md's Lemma 5. If G(x′_j) = P(x′_j), then f(x′_j) = 1 and f(P(x′_j)) = 0. ∎

So f can be anything the human can answer: a check with an excuse list, a hindsight check, a question about the step counter. Preservation (Drop_f = ∅) is needed only to make every flip a mistake. note.md's Proposition 9 is the case f = V.

**Proposition B (outcome certificates need foresight).** Let states record the number r(x) of steps still to go, and let Succ be a predicate on final states (r = 0). Write V*(x) := Succ(P^{r(x)}(x)): "the human's own continuation from x succeeds". Let V be final-sound: V(x) = 1 and r(x) = 0 imply Succ(x).
* (a) If V(x) = 1, then V*(x) = 1, unless the human's continuation from x passes through Drop_V.
* (b) Hence a preserved, final-sound check satisfies V ≤ V*.
* (c) V* is itself preserved and final-sound, so it is the largest such check.

*Proof.* (a) Along x, P(x), …, P^{r(x)}(x), V stays 1 unless some state is in Drop_V; at the end, final soundness gives Succ. (c) P^{r(P(x))}(P(x)) = P^{r(x)}(x) when r(x) ≥ 1. ∎

Take Succ = "as good as the human's own result on this problem". Then a preserved check that certifies Succ passes only states from which the human can tell its own continuation would still reach its usual standard. That is the "on track" judgment. Any cheap, preserved check certifies only a weaker Succ: one that the human's continuation keeps from every passing state. "No junk" is the clear case.

**Theorem C (local judgments cannot localise).** Call a check rule *s-local* if each answer is c(query, P(z₁), …, P(z_s)), for a fixed function c and states z₁, …, z_s determined by the query.
* A step review E(x, y) = e(x, y, P(x)) is 1-local; reviewing a prefix of L steps is L-local.
* On the hidden-insight class of note.md §3, with any s-local review rule, let a protocol make Q task queries and checks of total locality S, adaptively and possibly at random. Then its failure probability is at least (1−1/q)·η·(1 − 2(Q+S)/(nm)).
* So for ε ≤ 1/16: Q + S ≥ nm/4 ≥ n·E[K]/(32·ε·log₂(en/(4ε))).

*Proof.* Replace each check by task queries at z₁, …, z_s and evaluate c. The result is a task-only protocol with Q + S queries (in expectation, which Theorem 3 allows) and the same output distribution. Apply note.md's Theorem 3. ∎

**What this says about note.md's monitor.** In that class, the monitor V(p, j, a) of note.md §5.2 is j-local. On the runs of the class-prior decoder, which writes an insight only at its confirmed step, it equals the AND of the exact endorsements [x′_{i+1} = P(x′_i)] over i < j. So it is j step reviews answered in one look.
* That one look is what "the human can see that the run has gone off track" means.
* It is believable for knowledge the human holds when it looks: a known technique or result that should be in the draft by now.
* It is not believable for what the human would only find by doing the work. For that, Theorem C says reviews cost as much as task queries.

**Endorsement-gated chained imitation** meets this bound up to the log. Review one uniformly random step per run, and task-query it only if it is unendorsed. Assume self-endorsement, E(x, P(x)) = 1 for every x. Then:
* every task query lands on a mistake, so there are at most ⌊K⌋;
* the expected number of runs with an unendorsed step is at most n·⌊K⌋ (proof of note.md's Proposition 2).

So reviews take over the factor n/ε from task queries, but do not remove it.

## 2. Excuse lists: drops without blind spots

**The problem with Proposition 9.** Suppose the human's own step drops (for example, it records a flaw it has found), and the run fails. A plain check is 0 at every later state. So an imitator mistake after the drop makes no flip, and bisection lands on the drop. In E5, MB with Proposition 9 leaves 10–13% of problems permanently wrong, with half of all outputs marked. The predicted value is η₁η₂·Pr[t₂ ≥ t₁+2] ≈ 0.10–0.125.

**The checks.** A *list* L is a set of written descriptions of problems. The human answers two kinds of question:
* V(x; L): is anything wrong in x that is not on L? (1 means no);
* N(x; L): name what is wrong in x and not on L.

Assume:
* **(X0)** V and N are fixed functions, as P is;
* **(X1)** L ⊆ L′ implies V(x; L) ≤ V(x; L′);
* **(X2)** V(x; L ∪ N(x; L)) = 1.

**Protocol MBX.** D holds answers at mistakes; a side table S holds answers at drop states. For each problem x₀:
1. Set L := N(x₀; ∅), normally empty, and a := 0. Run G_D from x₀.
2. If V(x′ₙ; L) = 1, output (x′, L).
3. Otherwise, bisect [a, n] with f = V(·; L) to a flip j. Look up P(x′_j) in D ∪ S, or task-query it.
4. If G(x′_j) ≠ P(x′_j), add the answer to D and go to 1.
5. Otherwise, store it in S, set L := L ∪ N(x′_{j+1}; L) and a := j+1, and go to 2.

**Theorem D.** Assume (X0)–(X2); preservation is not assumed. For every sequence of T problems:
* **(a)** every output (x′, L) has V(x′ₙ; L) = 1;
* **(b)** every item added to L was named at x′_{j+1} = P(x′_j), where V(x′_j; L_before) = 1: it became visible at a step where the imitator did exactly what the human would have done from that state;
* **(c)** at most ⌊K⌋ runs are rerun, and there are at most ⌊K⌋ + |S| task queries;
* **(d)** a run with e drops costs at most (e+1)(1 + ⌈log₂ n⌉) checks and e naming queries (one more if x₀ has problems);
* **(e)** if V(·; L) is preserved for every L, then S is empty and MBX is MB, with Theorem 6's bounds.

*Proof.*
* (a) and (b) hold by construction. By (X2), f(x′_a) = 1 holds at every bisection.
* D changes only in step 4, which reruns the problem. So every addition to D is a mistake of the decoder that produced the run, and Lemma 1 gives (c).
* Within a run, a increases strictly, so there are at most n drops, and every run ends in an output or a rerun.
* Each pass through steps 2–3 costs 1 + ⌈log₂ n⌉ checks, which gives (d).
* (e): every flip of a preserved predicate is a mistake (Lemma A). ∎

**Corollary (attribution).** Suppose, in addition, that there is a set Prob(x) of visible problems such that V(x; L) = [Prob(x) ⊆ cov(L)], that N names exactly Prob(x) \ cov(L), and that cov(L₀) = Prob(x₀). Then

  Prob(x′ₙ) ⊆ Prob(x₀) ∪ ⋃ᵢ (Prob(P(x′_{jᵢ})) \ Prob(x′_{jᵢ})).

Every visible problem of an output was either in the problem statement or was created by a step identical to the human's. *Proof.* Prob(x′_{jᵢ}) ⊆ cov(L_{i−1}), so the items named at x′_{jᵢ+1} lie in Prob(P(x′_{jᵢ})) \ Prob(x′_{jᵢ}). ∎

**Extensions.**
* *Hindsight bisection (Lemma A again).* Suppose an item π, named at step j, was already present in x′_j: for example, a lemma found false. Then bisect [0, j] with h_π(x) = "x does not contain π", which is a very easy check.
  * The flip found is either an imitator mistake, which is learned, or a human-identical step that introduced π.
  * This costs at most ⌈log₂ n⌉ checks and one task query per item.
  * Errors invisible when made but revealed later by human-like work are then localised as well.
* *Audits compose* (note.md's Proposition 10, same proof). After each output, with probability β, task-query a uniform step of the output run. Then E Σ_t M_t ≤ n·⌊K⌋/β, where M_t counts all the decoder's mistakes on output run t. The audits share the ⌊K⌋ budget.
* *Sampling excuses.* Suppose only a fraction α of drops is checked by a task query, and the rest are excused unchecked. Then the expected number of mistake-flips excused unchecked is at most ⌊K⌋/α. Those defects still appear on the output's list, so outputs stay honest. Only their attribution is lost.
* *Frozen imitator.* Run MB-PAC (note.md's Theorem 7, with B = 1) with excuse answers kept in S. Then the decoder is fixed within an epoch, and a run "fails" if MBX's processing finds a mistake.
  * Theorem 7's bound on the number of epochs and its (c) hold verbatim. Under the Corollary's assumptions, a run fails whenever it ends with a visible problem the imitator created.
  * There are at most ⌊K⌋ + |S| task queries, with E|S| ≤ ē·N. Here N ≤ Σ_{i ≤ ⌊K⌋+1} m_i = O((K+1)·log((K+1)/δ)/ε) is the number of runs examined, and ē bounds the expected number of new drop states per run on the decoders reached.
  * Bounding ē on imitator runs by the human's own drop rate is note.md's open problem 6.

**Observation E (scoring drops as failures favours ignorance).** Let P and H be the only hypotheses left, agreeing except at a state z, which a fraction e > ε of problems reach. There P drops (it records bad news, for example a retracted lemma) and H does not.
* If w(H) > w(P), the decoder follows H at z. Its runs pass, no flip ever points at z, and it is silently wrong on a fraction e of problems.
* If w(P) > w(H), the decoder is right at z, and a fraction e of its runs fail the plain check. Every bisection then lands on z, where the decoder is right, so it never learns anything and never changes.
* So a stopping rule that counts drops as failures, such as MB-PAC with "passes the plain check", can accept only the decoder that suppresses the bad news.
* Counting excused runs as passes accepts both decoders. Only audits find z.

On-track checks drop at every piece of bad news, so they always face this.

## 3. The candidates

Notation: "look" is one check of a state; a "step review" judges one step in its context. In "certifies", *excused* refers to Theorem D(b).

| check | an output is certified to… | human cost per output / per failed run | preservation fails when… | invisible to it |
|---|---|---|---|---|
| V_bizarre ("nothing I'd recognise as junk, sabotage or non-work") | contain no visible junk, except excused junk | 1 skim / ⌈log₂ n⌉ skims; batching (M3) plausible, junk is salient | handed a corrupted state, the human abandons the task: rare | almost every mistake of the majority decoder, which is its best guess at the human |
| prefix endorsement E(x, y) | have every step endorsed or human-identical | n step reviews / up to n more (0 if the reviewer points to the failing step) | the reviewer catches the author's own error; the bar is the human's best work, not its typical work | subtle errors, dead ends, discoveries the reviewer hasn't made |
| on track ("I could still finish from here") | reach a good outcome, if the judgment is calibrated (Prop. B) | 1 look / ⌈log₂ n⌉ looks | every piece of bad news from the human's own work: plausibly O(1) times per research run | failures to discover bad news, which it favours (Obs. E) |
| sign-off, matching ("as far along as I'd be") | about the same as on track | 1 / ⌈log₂ n⌉ | the human's own progress falls short of its forecast | states that overstate their progress pass |
| sign-off, floor ("I'd put my name to this as work in progress") | = the defect check (last row) | | | |
| flag in the human's step | whatever the flag is asked to cover | one partial task query | as for the flag's content | as for the flag's content |
| comparison of two outputs ("is A better than B?") | nothing: it selects on a graded judgment (note.md §6.3) | | | favours outputs that look better without being better |
| **defect check with an excuse list (Section 5)** | have nothing visibly wrong except listed items, each first visible at a human-identical step | 1 look / (e+1)(1+⌈log₂ n⌉) looks | a fresh read finds something wrong in the human's own step after its self-review, or the human retracts its own earlier claim | errors that look right; discoveries; listed items the human would later have repaired |

**Notes.**
* **V_bizarre** is the most believable check, and nearly useless for quality.
  * In exact Bayes the decoder's mistakes are its most probable continuations (robust-runs.md §3), so they are rarely junk.
  * What it catches is odd or malign hypotheses that win the vote: note.md's P ≠ NP example, and visible takeovers.
  * Keep it as a floor inside the defect check.
* **Prefix endorsement.**
  * *Its strength.* It is local. A drop at one step is excused without hiding the others, so every step of an output is endorsed or human-identical. That is robust-runs.md's "corrupted runs" with the replacements restricted to *endorsed* ones: a condition on the human alone, which that note lacked.
  * *Outcomes.* It certifies outcomes only if endorsement is value-sound, E(x, y) = 1 ⇒ V*(y) ≥ V*(P(x)) (then V* is non-decreasing along the run: a hybrid argument). That is foresight again, false for a plausible lemma with a subtle error.
  * *Its weakness.* It costs n step reviews per output, and Theorem C shows this is no accident.
  * *Reading cost.* If states are compact drafts, looks cost O(1) each. If states are full logs, a look at x_k reads all k steps, and the advantage of a state check is in the *kind* of judgment (one verdict on the whole state, instead of k counterfactual ones), not in the amount read.
  * *Bisection over prefixes.* It costs fewer than 2n step reviews if each probe reviews only the new steps, and n⌈log₂ n⌉ if every prefix is reread.
* **On track and matching sign-off** are where certification of outcomes lives (Proposition B). In research both drop often, and their drops are exactly the human's discoveries of bad news (Observation E).
  * With MBX they become usable: excused, attributed, and with hindsight bisection, the step that committed to the dead end is also located.
  * But they cost O(ē·K·log(K/δ)/ε) task queries, with ē plausibly of order 1.
* **Flags in the human's step.** Write P(x) = (R(x), W(x)), where R(x) is the review the human writes first ("before continuing: what is wrong with this draft?"). A check query asks for R(x) alone. Two consequences:
  * *A learned monitor.* With the review decoded first, by its marginal majority, a review R(x) that differs from the decoder's predicted review has posterior mass at most 1/2. So added as a partial observation (after each run's processing, so that the decoder stays fixed during bisection) it costs at least one bit: Lemma 1's telescoping does not need full labels. At most ⌊K⌋ checks, together with task queries at mistakes, ever disagree with the imitator's own predicted reviews. The imitator learns to review its own states, which bears on note.md's open problem 3.
  * *Preservation by construction, but of honesty only.* End every step with a fresh call "list what is wrong in your output", whose answer is appended to the state. In the decomposition model, where calls are memoryless and deterministic, the human's own steps then pass any check that ignores problems the state acknowledges. But such a check certifies only honesty: an imitator that creates a problem and then acknowledges it passes, and the step that created it is never located. So the recommended check (§5) counts a problem even when the state acknowledges it; only the protocol's excuse list, written by the human at drops, excuses anything. Then a retraction made by a human-identical step is a drop, and hindsight bisection finds where the retracted claim came from.
* **Comparisons.** The useful comparative form is incremental: "anything wrong in x that was not wrong in b?", a code review of a cumulative diff. That is the excuse-list check. Comparing two candidate outputs is selection on a graded judgment, which note.md §6.3 warns against. A progress comparison, "is y at least as good as x?", cannot see missing progress: a run that does nothing passes.

## 4. Experiment E5: drops, excuses and endorsement

**The class.** The hidden-insight class with three independent insights per problem, with probabilities (0.5, 0.5, 0.2) and uniform steps (m = 100, q large, silent human).
* Insights 1 and 2 are visible to the check. Insight 3 is a discovery the check cannot see.
* One step after insight 1 is in the state, the human writes a persistent note: "having insight 1, I see the earlier approach was flawed". The rule is generic and known to every decoder.
* V_strict counts the note as a defect. V_ack does not, and is preserved. V_strict with the excuse list {note} is V_ack.

**Measurement.** Posteriors are exact. F_vis is the probability that the decoder's final state lacks a visible insight; F_diff, that its run differs from the human's. There are 10 humans per n, and the protocols cap at 4,000 runs (40,000 for CI, RG and MBX+A). Entries are means over the 10 humans:
* task queries, with checks or step reviews, when F_vis first reaches 2%;
* for CI, RG and MBX+A, the extra column is the task queries when F_diff first reaches 2% (n = 256: 4 of 10 humans for MBX+A; never for CI);
* final F_vis.

| protocol | n = 16 | n = 64 | n = 256 | final F_vis |
|---|---|---|---|---|
| CI | 1,863 task | 7,600 | not reached (F_vis 0.21 at 40,000) | 0.02 / 0.02 / 0.21 |
| RG (endorsement-gated CI) | 98 task, 5,386 reviews | 100, 23,564 reviews | not reached | 0 / 0 / 0.21 |
| PE (prefix endorsement) | 97 task, 6,611 reviews | 99, 24,478 | 97, 109,893 | 0 |
| MB + Prop. 9 (V_strict) | never | never | never | 0.098 / 0.122 / 0.126 |
| **MBX** (V_strict + excuse list) | 141 task, 1,714 checks | 148, 2,301 | 146, 3,086 | 0 |
| MB with V_ack (preserved) | 97 task, 847 checks | 99, 1,028 | 97, 1,252 | 0 |
| MBX + audits (β = 1) | F_diff ≤ 2% at 1,434 task | 5,764 | 18,886 (4/10 humans) | 0 |

* *Proposition 9's blind spot is real.* It never reaches 2%. Its stuck failure matches the prediction η₁η₂·Pr[t₂ ≥ t₁+2], and half of its outputs are marked.
* *Excuses close the gap.*
  * MBX reaches the target. Its 45–50 extra task queries are the distinct drop states, one per problem whose insight 1 is learned.
  * Problems recur here, so a drop is queried once. With fresh problems every drop would cost a query: about 1,850–2,000 per 4,000 runs (the "excused" column of the output). This is the ē·N term.
* *Endorsement costs grow with n.* PE's and RG's step reviews grow in proportion to n; MB's checks grow like log n. This is Theorem C.
* *Silent failures stay.* Every check-only protocol leaves F_diff at 0.18–0.21, the invisible insight 3. Audits remove it at a cost close to CI's: CI reaches F_diff ≤ 2% with 1,881 and 7,642 task queries at n = 16 and 64.

## 5. Recommendation

**The check.** "Is anything in this state wrong that is not on the list?"
* *Wrong* means:
  * junk, sabotage, or text that is not an honest attempt at the task;
  * a claim the human believes false or unjustified, unless it was stated as a conjecture or as unverified. A claim the text itself later retracts still counts: only the protocol's excuse list excuses anything (§3, flags);
  * a problem the human sees that the text hides or glosses over.
* Honestly reported dead ends, open questions and conjectures are not wrong.
* Missing knowledge counts only when the human already holds it and its absence makes a claim false. "I'd have proved more by now" does not count, because it is a forecast (sign-off, matching).
* Ask it as the first part of the human's own next step, "before continuing, what is wrong here?". Then the verdict and the naming come from the same act, and the answers can also train the imitator's own reviews (§3).

**The protocol.** MBX with hindsight bisection, plus audits at rate β on output runs. For a frozen imitator, use MB-PAC with excused runs counted as passes. If intermediate states matter, check prefixes, at the reading cost of §3.

**Its guarantee.** For every sequence of problems, by Theorem D, its Corollary, and the audit bound:
* every output carries a list. On the human's careful read, nothing in the final state is wrong except listed items.
* Each listed item became visible at a step where the imitator did exactly what the human would have done from that state. With hindsight, it was also introduced at such a step.
* So no output contains a defect that was visible when the imitator created it by deviating from the human. With hindsight bisection, the same holds for defects that a human-identical step later reveals.
* At most ⌊K⌋ runs are rerun. There are at most ⌊K⌋ + |S| task queries, where |S| is the number of distinct drop states met.
* A run with e drops costs at most (e+1)(1+⌈log₂ n⌉) checks, with up to ⌈log₂ n⌉ more and one task query per item for hindsight.
* In expectation, the output runs contain at most n·⌊K⌋/β mistakes of every kind, visible or not.

**Its assumptions, and how believable they are.**
* **(X1)** A longer list never makes a verdict stricter. Near-tautological.
* **(X2)** The human can say what it sees wrong, and then passes the state with those items listed. True of careful people, up to vague unease, which can be listed as such.
* **(X0)** Verdicts are a fixed function of the state and the list. This is the model's idealisation, the same as for P.
  * Real verdicts are noisy. But a noisy flip only costs a task query and excuses a real problem. It never puts a false label into the data, by Lemma A.
  * What noise weakens is the Corollary's attribution, which also needs "the same problem" to be identified consistently across queries.
* **Efficiency, not correctness.** The cost is O(K) only if ē, the rate at which the human's own steps contain something wrong that its own fresh read catches, is below the target ε.
  * Real scenarios: an arithmetic slip, an overclaimed lemma, an unflagged gap, and the human's own retractions of its earlier claims.
  * Each costs one task query, two with hindsight.
  * A closing self-review in each step lowers ē.
  * ē can be measured directly: give researchers their own earlier output to re-read cold.
  * If ē is not small, the protocol is still correct, and costs ⌊K⌋ + O(ē·K·log(K/δ)/ε) task queries.
* **Batching (M3)** is needed only for batched checks, and is believable only for salient defects. For defects that need a careful read, the reading grows with the batch.

**What it does not guarantee.**
1. *Outcomes as good as the human's.* Proposition B: no preserved check certifies them without foresight. An on-track tier can be added through MBX, at the cost of Observation E's drops.
2. *Discoveries,* and anything else the human would find only by working. Theorem C and note.md's Theorem 3 apply. Only audits, at chained imitation's rate, or a persistence assumption (without-a-check.md) reach these.
3. *Errors that look right* to a careful reader.
4. *Repairs.* A listed item that the human would later have fixed, but the imitator does not, stays in the output. It is listed there, not hidden.
5. *The imitator's drop rate* relative to the human's (ē is measured on imitator runs).
6. *Persuasion.* MBX never selects outputs by the verdict, but a state that talks the reader past a defect is not excluded.
7. *Stochastic humans,* and the reading cost of very large states.
