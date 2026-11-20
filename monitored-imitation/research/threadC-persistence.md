# Thread C: persistence, a condition on the human alone

*Research note by Claude (Anthropic), thread C of the follow-up to [`../without-a-check.md`](../without-a-check.md). Draft; not refereed. Code: [`threadC_sim.py`](threadC_sim.py) (experiments CHAIN and COMMIT, exact posteriors), [`threadC_checks.py`](threadC_checks.py) (brute-force checks of Theorems A and B). Outputs: `threadC_sim.out`, `threadC_sim_summary.json`, `threadC_checks.out`.*

## Answers in brief

1. **Detection, not repair.** The second note's Theorem 3 uses (C_r) only to get (L_r): *every failed run has a mistake in its last r steps*. Over all decoders the two coincide (Proposition 1). So asking less than (C_r) has to use the failed run itself.
2. **X = persistence**, "the human uses what it knows whenever it becomes relevant". On append-only drafts, whatever the human would add to a draft, it would add to any later, larger draft that lacks it. This is a property of the human alone, on drafts of its own work or on all non-bizarre drafts.
3. **Theorem A.** Under persistence, a failed run has a mistake at its last step whenever something it lacks *fell due* somewhere on the run (a *ripe* failure). Its due steps form an interval ending at n−1, so bisection with task queries (BIS) finds where it first fell due.
4. **Theorem C.** Assume (X) persistence on non-bizarre drafts, with note.md's preserved "nothing bizarre" check, and (Y) append-only hypotheses. Let (Z) check the final draft: if it fails, bisect with checks; otherwise ask for the last step. Then bizarre runs plus ripe failures ≤ K(P) on every path, with one task query per run. On drafts of the human's own work, an imitator that only omits needs no check.
5. **Covered:**
   * omissions of anything the human would contribute, however much work depends on it;
   * commissions the human would notice and correct;
   * junk, through the check.
6. **Not covered:**
   * *unripe* failures, such as *lateness* (a key idea written too late for the work that depends on it) and detours;
   * *accepted* commissions, plausible guesses the human builds on instead of its own contribution ("fooled").
7. **Lateness** (Theorem B). Each mistake delays a persistent human's run by at most one step. With slack σ, half-last, half-uniform queries give at most 2·max(1, n/(σ+1))·K failed runs. In experiment CHAIN, without slack:
   * chained imitation and end-weighting pay a factor n;
   * the last step alone stalls at 25% failure;
   * BIS needs 480–680 task queries for n = 16 to 256.
8. **When the imitator commits** (Proposition 2). It writes an unconfirmed item only if Pr[due]·p_max > 1 − Pr[due]: obvious ideas, not rare ones. In experiment COMMIT the last step needs 100–125 task queries if the human corrects a wrong obvious idea, and stalls at 8% failure if it is fooled.
9. **Believability** (Section 7). Persistence is easy to believe for knowledge-type contributions on the human's own drafts. It fails for stage-specific choices, it is doubtful against plausible substitutes, and it does not prevent lateness.

## 1. Detection, not repair

**(L_r).** In every round, if the decoder's run fails, it has a mistake at some step in [n−r, n). Theorem 3(b), (c) of the second note hold verbatim with (L_r) in place of (C_r), because the proof uses (C_r) only through Lemma 2, to get d_t ≤ r−1. In particular, under (L₁), asking only at the last step has at most ⌊K(P)⌋ failed runs on every path.

**Proposition 1.** (C_r) implies (L_r). Conversely, fix a set 𝒮 of states at step n−r, and suppose the human's own continuation P^r(y) fails for some y ∈ 𝒮. Then some decoder whose run reaches y fails with no mistake in its last r steps.

*Proof.* The first part is Lemma 2 of the second note. For the second, take any decoder whose run reaches y and make it copy P at the states P^j(y), j < r. States carry the step, so this does not change its run before step n−r. ∎

So a condition that gives (L_r) for *every* decoder reaching 𝒮 is (C_r) on 𝒮. To ask less, one must use what the decoder's last steps leave out. Persistence uses the simplest such fact: if the final draft lacks an item, the decoder's last step did not write it.

## 2. Drafts, dues and kinds of mistake

* **Drafts.** A state is a draft y = (x₀, k, c): the problem, the step, and a finite set c of *items*. The human is *append-only*: P(y) = (x₀, k+1, E(y)) with E(y) ⊇ c. A revision is an item ("replace a by b"), as in a lab notebook. Every hypothesis is append-only too, and so then is the majority decoder.
* **Notation.**
  * d(y) = E(y) ∖ c are the items *due* at y.
  * y ⪯ y′ means: the same problem, step(y) ≤ step(y′), and c ⊆ c′.
  * c₀, …, cₙ are the human's own drafts.
* **Success.** The final draft is not bizarre (below) and contains S(x₀) ⊆ cₙ, the items that matter (the result; S = cₙ asks for everything the human had). Extra non-bizarre content is not counted as failure; Section 5 says what that leaves out.
* **Mistakes.** Let the decoder output g at its draft y.
  * It makes an *omission* if d(y) ⊄ g, and a *commission* if g ⊄ d(y).
  * A commission is *junk* if it makes the draft bizarre.
  * It is *noticed* if it makes a repair item due, so that the human would correct it.
  * Otherwise it is *accepted*.
* **The check** is note.md's "nothing bizarre" check V, with (M1) start drafts pass and (M2) the human never makes a passing draft fail. Add (M3): if y ⪯ y′ and y′ passes, so does y. Junk, once in an append-only draft, stays.
* **Domains** (neither depends on the learner):
  * 𝒩 is the non-bizarre drafts;
  * 𝒪 is the *own-work drafts*, reachable from x₀ by steps z ↦ z′ with z ⊆ z′ ⊆ E(z). These are the human's own work with some of its contributions left out. By (M1)–(M3), 𝒪 ⊆ 𝒩.
* **Persistence (P_r) on a domain 𝒟.** For y ⪯ y′ in 𝒟, every item of d(y) ∩ S is in y′ or in the human's draft r steps on from y′.
  * (P₁) reads d(y) ∩ S ⊆ y′ ∪ d(y′): "once due, due until written".
  * (P₁) for all items, not only S, says that E is monotone on 𝒟.

## 3. Ripe failures are caught at the end

A failed run is *ripe* if some item of S(x₀) missing from its final draft was due at a draft x′_t of the run with t ≤ n−r. Otherwise it is *unripe*.

**Theorem A.** Let the decoder's drafts lie in 𝒟, and assume (P_r) on 𝒟. Then every ripe failed run has a mistake in its last r steps. For r = 1, if i ∈ S is missing at the end, the steps t with i ∈ d(x′_t) form an interval {s, …, n−1}, possibly empty.

*Proof.* Let i ∈ S ∖ x′ₙ be due at x′_t with t ≤ n−r.
* The run is append-only, so x′_t ⪯ x′_{n−r} and i ∉ x′_{n−r} ⊆ x′ₙ.
* By (P_r), i is in the final draft of the hybrid H_{n−r}, which follows the decoder for n−r steps and then the human. It is not in the decoder's final draft.
* Lemma 2 of the second note, with success "the final draft contains i", gives a mistake in [n−r, n).
* For the interval: if t ≤ t′ ≤ n−1, then x′_t ⪯ x′_{t′} and i ∉ x′_{t′}, so i ∈ d(x′_t) implies i ∈ d(x′_{t′}). ∎

Theorem A uses nothing about how the decoder chooses its steps, beyond append-only drafts that stay in 𝒟. So persistence is a repair condition only for the one-step repair "write the missing item". It does not ask the human to finish what depends on that item. In the CHAIN class below, (C_r) fails for every r < n − t_p, while every failure of a decoder that lacks the insight has a mistake at the last step.

**Protocol Z.** In each round, run the decoder and check its final draft.
* If the draft is bizarre, bisect with checks for the step where it first becomes bizarre, and task-query that step (note.md, Lemma 5).
* Otherwise task-query the last step.
* *BIS option.* If the last-step answer contains an item the run never wrote, binary-search this fixed run with task queries for the first step at which that item is due. Add those answers after the search.

**Theorem C.** Assume append-only hypotheses, (M1)–(M3), and (P₁) on 𝒩 (for all items, if BIS is used). Then for every sequence of problems, on every path:

  (number of bizarre runs) + (number of ripe failed runs) ≤ ⌊K(P)⌋.

* *Task queries:* one per round, plus ⌈log₂ n⌉ per ripe failure under BIS.
* *Checks:* one per round, plus ⌈log₂ n⌉ per bizarre run.
* *The mixed query.* If the query is at the last step with probability ½ and at a uniform step otherwise, then

  E[#bizarre] + ½·E[#ripe] + (1/2n)·E Σ_{unripe failed t} |M_t| ≤ ⌊K(P)⌋.

*Proof.*
* *A bizarre run.* By (M3) and append-only drafts, the check's verdict along the run is 1…1 0…0. Bisection finds the flip, which is a mistake by (M2). The task query lands on it.
* *A non-bizarre run.* By (M3) every draft of the run is in 𝒩, so Theorem A applies. A ripe failure has a mistake at n−1, and the last-step query lands on it. Under BIS the searched item stays missing, so by Theorem A its due steps form an interval and ⌈log₂ n⌉ queries find its start.
* *The count.* Lemma 1 of note.md bounds, on every path, the number of task queries that land on a mistake of the current decoder by ⌊K⌋. The BIS answers are added after the round's main query. The mixed version is Theorem 1 of the second note; in a bizarre round the query lands on a mistake with certainty. ∎

*With latency r,* ask at a uniform step among the last r: then E[#bizarre] + E[#ripe]/r ≤ ⌊K⌋, by Theorem A and the same count.

**The own-work version.** Suppose the decoder only omits, g ⊆ d(y). Then its drafts stay in 𝒪 by induction. (P₁) is then needed only on 𝒪, and no check is needed. On i.i.d. problems with no unripe failures, the last step alone gives failure ε after K/ε task queries, as in Theorem 3(b) of the second note.

**Proposition 2 (when the majority decoder only omits).** Consider an item at draft y that is due with posterior probability π, and whose value, given that it is due, has largest posterior mass p_max. The majority decoder writes a value for it only if π·p_max > 1 − π. If the posterior is a product over items, the decoder decides item by item, because the mode of a product is the product of the modes.

*Proof.* Writing value v has mass π·Pr[v | due] ≤ π·p_max. Not writing has mass 1 − π, and ties go to not writing. ∎

* Lemma 5 of the second note is the case p_max = 1/q.
* Rare content of unpredictable value is omitted until a query confirms it.
* Predictable content, such as "the obvious idea", is written once its time looks likely. It is then a plausible commission whenever the human's own value differs.

## 4. Unripe failures: lateness

**Example (CHAIN).** The hidden-insight class (m = 100, η = ½), with dependent work.
* *The human.* On a draft that lacks k_p at a step j ≥ t_p it writes k_p (catch-up). On a draft that has k_p it writes the next unit of a chain of dependent work, one unit per step; every hypothesis knows the chain.
* *Success.* The final draft contains the human's draft from σ steps before the end.
* *Persistence.* E is monotone on all drafts, so (P₁) holds everywhere.
* *An unripe failure.* Once a last-step query has revealed k_p but not t_p, the decoder writes k_p at the posterior median w. If w > t_p + σ, the run fails because its chain is too short. Its mistakes are exactly the steps [t_p, w), and its last step is right.

**Theorem B (delay).** Assume (P₁) for all items, on a domain containing the human's and the decoder's drafts. Let δ_k = min{d : c_{k−d} ⊆ x′_k}. Then δ₀ = 0, and δ_{k+1} ≤ δ_k after a correct step and ≤ δ_k + 1 after a mistake. Hence x′ₙ ⊇ c_{n−|M|}.

*Proof.* x′_{k+1} ⊇ x′_k ⊇ c_{k−δ_k}. After a correct step, x′_{k+1} = E(x′_k) ⊇ E(c_{k−δ_k}) = c_{k−δ_k+1}, by monotonicity, since c_{k−δ_k} ⪯ x′_k. ∎

**Corollary (slack).** Assume (P₁) for all items on 𝒩, (M1)–(M3), and S(x₀) ⊆ c_{n−σ}. Then every failed non-bizarre run has at least σ+1 mistakes.
* With the mixed query of Theorem C: E[#failed runs] ≤ 2·max{1, n/(σ+1)}·K.
* With chained imitation and the check: E[#bizarre] + (σ+1)/n · E[#failed non-bizarre] ≤ K.

For σ = ⌊ρn⌋ this is an *outcome* property that chained imitation loses in at most n·K/(⌊ρn⌋+1) ≤ K/ρ rounds in expectation, with no factor n. The third note's Lemma 2 excludes this for arbitrary replacements. Here the replacements are append-only and non-bizarre, and the human is persistent on the drafts they produce.

**Results (CHAIN).** Mean task queries until the failure is at most 2%, oracle stopping, 100 humans per cell (standard errors in `threadC_sim.out`). LAST is capped at 20,000 runs; its failure there is shown.

| n | slack σ | CI | EW | LAST | BIS | MIX |
|---|---|---|---|---|---|---|
| 16 | 0 | 4,901 | 6,111 | stalls at 24% | 499 | 9,573 |
| 64 | 0 | 19,843 | 26,977 | stalls at 25% | 565 | 40,699 |
| 256 | 0 | 83,552 | 113,691 | stalls at 25% | 684 | 159,071 |
| 16 | 2 | 1,033 | 1,102 | stalls at 18% | 480 | 1,800 |
| 64 | 8 | 1,301 | 1,647 | stalls at 19% | 548 | 2,440 |
| 256 | 32 | 1,444 | 2,019 | stalls at 19% | 668 | 2,747 |

* *Without slack,* CI and EW pay in proportion to n, as for silent humans. The last failures have a single mistake, w = t_p + 1.
* *LAST* learns k_p and never t_p, so it stalls.
* *BIS* grows like log₂ n. At the first detection the fixed run lacks k_p at every step, and "the human writes k_p here" is a threshold in the step (Theorem A). So bisection finds t_p exactly, and the decoder writes k_p on time from then on.
* *With slack n/8,* CI grows only from 1,000 to 1,400 over a 16-fold increase in n. The Corollary charges each failure at most n/(σ+1) ≈ 8.
* *MIX* costs about twice CI here, where all failures are unripe once k_p is known. Where failures are ripe it is far cheaper: in E3's catch-up class, LAST needs about 300 and CI 1,300–2,500.

**BIS in general.** BIS records the human's step at the first draft where the item fell due. Whether the posterior carries that to later runs, whose earlier drafts may differ, is not shown beyond classes like CHAIN.

**Lower bounds.** Persistence breaks the proof of the first note's Theorem 3: a probe at any step ≥ t_p reveals the insight, so probes become threshold tests. CHAIN shows that chained imitation, end-weighting and the last step can still pay a factor n on persistent humans. I know of no lower bound of that order for *every* task-only protocol, and BIS avoids it in CHAIN.

## 5. Accepted commissions: being fooled

**Example (COMMIT).** The value k_p is 1, the obvious idea, with probability 0.9, and 2 otherwise; η = 0.8. By Proposition 2, the decoder writes the unconfirmed value 1 at about step 0.66n. A success needs the final draft to carry k_p, when there is an insight. There are two humans.
* *Noticing:* on a draft carrying a ≠ k_p at a step ≥ t_p, it writes k_p. Persistence holds.
* *Fooled:* it keeps whatever value the draft carries. Persistence fails at exactly those drafts.

| n | human | CI | EW | LAST |
|---|---|---|---|---|
| 16 | noticing (40) | 1,313 | 408 | 102 |
| 16 | fooled (40) | 1,938 | 884 | stalls at 8.0% |
| 64 | noticing (40) | 2,492 | 319 | 124 |
| 64 | fooled (40) | 3,197 | 1,070 | stalls at 8.3% |
| 256 | noticing (20) | 2,378 | 277 | 121 |
| 256 | fooled (20) | 3,483 | 1,235 | stalls at 8.5% |

* *Fooled humans.* The run on a problem with k_p = 2 ends with no mistake at the last step. The last-step query never learns, and failure stays at the fraction of such problems.
* *Noticing humans.* The last step makes 100–125 task queries.
* *CI and EW* reach 2% for both humans, and are cheaper when the human notices.
* *Single mistakes.* For the fooled human, a problem with t_p after the decoder's write has a single mistake, as with silent humans. With m = 100 there are only about three such problems.
* *No check helps.* A "nothing bizarre" check cannot catch the obvious idea. Uniform queries bound accepted commissions at chained imitation's rate.

## 6. The candidate conditions, and where the imitator's drafts drift

* **Out of 𝒪,** at any commission. Proposition 2 says when that happens: for predictable content.
* **Out of 𝒩,** at junk. The check finds every such run, and each costs one task query on a mistake, so at most K runs.
* **Into fooled drafts within 𝒩,** at accepted substitutes. No "nothing bizarre" check sees these; only a "looks right" check could.

| condition | as a statement | catches | misses; where the decoder's drafts leave its scope |
|---|---|---|---|
| (a) re-adds its own removed contributions within r steps | (C_r) on drafts c_k minus items | omissions that are quick to redo | not closed under the human's own steps, and needs repair, not just detection |
| (b) catches up from deficient, junk-free drafts | (C_r) on 𝒪 | omissions of content it can re-add at once | dependent work: in CHAIN, r ≥ n − t_p. Commissions leave 𝒪 |
| (c) uses what it knows whenever relevant | (P_r) on 𝒪 or 𝒩 | every ripe failure, whatever the work; noticed commissions | unripe failures; accepted commissions; junk on 𝒩 without the check |
| (d) repairs the deficits it would notice | (c) for repair items | noticed commissions | unnoticed ones |

On (a): drafts of the form "own draft minus items" are not closed under the human's own work.
* *The human.* On a draft lacking its idea A at a step after t_A it writes A and also a hedge B. On a draft that contains B it never writes A.
* *(a) holds with r = 1.* From c_k ∖ {A} the human re-adds A at once.
* *The decoder that knows B but not A* writes B and omits A. From then on its drafts contain B, so A is never due again.
* *The failure goes unseen.* The run fails with no mistake at the end, so (C₁) and (L₁) both fail.
* *(P₁) on 𝒪 fails here.* A is due at c_k ∖ {A} but not at the decoder's next draft, which is an own-work draft containing B.

So persistence has to be stated on all of 𝒪, which is what (c) does.

**Brute-force check** (`threadC_checks.out`) of Theorems A and B.
* *Persistent humans:* 1,500 random monotone rule systems, each with 20 arbitrary append-only decoders.
  * There were no violations.
  * 178 of the 1,703 failures were unripe.
* *Rule systems with inhibitors (substitutes):* 157 ripe failures had no last-step mistake, and there were 846 delay violations. All come from the humans that are not persistent.

## 7. How believable is persistence?

* **Where I would vouch for it.** On drafts of the human's own work, with a latency r for its capacity, for contributions of knowledge: an idea it has, a fact, a method, a case it knows must be handled, a correction of something it recognizes as wrong. These stay relevant as a draft grows towards its result. Near the deadline the human may only *mention* a missing idea, but any difference from the decoder's step is enough for detection.
* **Where it fails even on own-work drafts.**
  * *Stage-specific contributions,* such as the choice of a direction. Once the draft has gone another way, a careful researcher does not restart: sunk cost. Unless S is the result alone and the other way also reaches it, this is a violation.
  * *Large backlogs,* which raise r.
* **On drafts carrying the imitator's guesses.** "Not fooled" is believable for guesses that contradict what the human knows. It is not believable for plausible results the human has not itself worked out, which it would build on. Proposition 2 says when such guesses are made: where the content is predictable.
* **Persistence does not exclude lateness.** An imitator that has the key idea but uses it too late leaves an unripe failure. Slack, or BIS, deals with it. Slack is plausible for projects whose result is in hand before write-up; BIS needs no assumption beyond persistence, but its effect on later runs is shown only in CHAIN.
* **Testable.** Hand researchers their own drafts with a contribution removed, at various stages. Then measure whether, and how soon, they put it back (latency r), and whether they do so when a plausible substitute is present ("fooled").

## 8. Open

1. A general guarantee for BIS against lateness. Or a lower bound for persistent humans, of order n per unripe failure, for task-only protocols.
2. A check that catches accepted substitutes without being a full "looks right" check.
3. Theorem B with latency r > 1, where catching up competes with new work.
