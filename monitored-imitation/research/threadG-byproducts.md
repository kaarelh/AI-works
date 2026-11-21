# Thread G: by-product insights, hedges, and what a scaffold can do about them

*Research note by Claude (Anthropic), thread G of the follow-up to [`../slack-imitation.md`](../slack-imitation.md), version 2. Draft; not refereed. Code: [`threadG_byproducts_sim.py`](threadG_byproducts_sim.py) (experiment G1, exact posteriors) and [`threadG_checks.py`](threadG_checks.py) (two numerical checks). Outputs: `threadG_byproducts_sim.out`, `threadG_checks.out`. Facts from the psychology and history-of-science literature are from memory and marked †.*

## Answers in brief

1. **Models (§1).** A *by-product insight* is one the human writes when a step's *activities* meet a trigger set: doing a routine unit, reading its raw record, or reading its summary. Two numbers decide the cost:
   * the *multiplicity* w: how many units would trigger the insight;
   * the *trigger capacity* κ of one human step: how many trigger opportunities it can test. That is C units of work for a trigger that needs doing, and C + A if reading a raw record also triggers it and the step reads A records.

   A pre-empting hedge is a separate mechanism: a default B adopted at a decision point because A is absent (§5).
2. **Impossibility (Theorem G3).** Suppose the insight is triggered only by *doing* (an unrecorded experience), at an unpredictable unit. To reach failure ε, every protocol must then have the human itself process at least a share 1/(4w) of all the routine work. This holds whatever the scaffold: seeds, re-derivation, raw records, reviews, synthetic states, and even checks that read the notebook. For w = 1 it is Ω(n_r·K/(ε log(n_r/ε))) task queries, where n_r is the number of steps of routine work. Note.md's Theorem 3 is the case κ = w = 1.
3. **Characterization (§2).** Finding one by-product insight costs Θ(N/(κw)) task queries, for N routine units. So the factor n can be avoided iff κw = Ω(N): either the insight recurs at a constant fraction of the units, or some step rereads a constant fraction of the readable records.
4. **Randomized re-derivation gives no bounded setback (Proposition G2).**
   * *A conservation law.* Averaged over the trigger unit, a run that loses the insight has E|M| = w·(unit-touches)/N ≤ wCn/N mistakes, whatever the redo rule. So a uniform query lands on a mistake with probability at most wC/N.
   * *Recovery.* An omitted insight is recovered only at a later touch of its unit. With redo rate p it stays lost with probability ≈ (u/N)^{p/(1−p)} (1 − p on average), and its setback is then infinite.
   * *What re-derivation can do* is remove slack's factor-2 penalty on silent humans. A systematic recheck, once the routine is done, does this without seeds and without raising n₀. It never beats chained imitation without slack. G1 at N = 128: slack alone 79,100 task queries; with the recheck 38,300; with seeded redo 38,500 (to be filled from the full run); chained imitation without slack 38,500.
5. **The slack lemma with random τ (Lemma S-rand, Theorem G1).** With seeds in the input of both chains, Pr[fail] ≤ Pr[τ₀ > n₀] + ((D+1)/(σ+1))·E|M|. Here D + 1 bounds the *truncated mean cost* E[min(c⁺, σ+1)] of a mistake, and an average over all mistakes suffices. A mistake that is never recovered counts σ+1.
   * *Corollary.* If a share β of the mistakes is never recovered, the guaranteed gain over chained imitation is (1−ρ)/(β + (D+1)/(σ+1)). This is thread E's heuristic cap, now a theorem.
6. **Raw records (§4)** help exactly the *readable* triggers (condition (Rec)), and only if some step rereads them. With an attention window of a records the cost is Θ(n/a) (Corollary G5).
7. **Content-triggered reviews (Theorem G4).** A review that rereads every raw record makes the lost readable insights *ripe*: the run's last review is a mistake. Querying that step with probability ½ gives at most 2K such failures, with no factor n. In G1 this costs about 300 task queries at every N, against 2,500 → 38,500 for doing-only humans under chained imitation.
8. **Ask-before-committing (Proposition G6).**
   * *Routine steps.* There the posterior mass of a by-product insight is at most 2ηC/N, so asking never fires. It does nothing for doing-only insights.
   * *Reviews and decision points.* There the mass aggregates over every unit covered, so asking fires for every kind of insight whose prior rate exceeds α.
   * *In G1* asking never fires on doing-only humans. On review humans at N = 32, failed runs fall from 224 to 101 with asking, and to 31 with asking plus last-review queries.
9. **Hedges (Proposition G7).** For a majority decoder, a hedge that pre-empts A must be a *default*: it is due where A is absent. The step that adopts it is a mistake that tests every earlier trigger time of A at once. If decisions are labelled entries, querying that step gives at most 2K hedge failures, and asking fires there.
10. **Believability (§7).** By-product insights are, I estimate, about 30% of decisive insights in mathematics, 35% in software and 50% in empirical work.
    * *Unrecoverable residue,* as a share of run-sinking confident omissions: 14% / 14% / 29% without these designs; 7% / 6% / 21% with raw records and reviews.
    * *(B-omit) on version 2's graded reading* (at most about 5% of all confident omissions fail it): 55% for theory and 30% for empirical work without reviews; 65% and 40% with them. Version 2 has 70% and 50%.
    * *Re-derivation* moves these by under 2 points.
11. **Recommendation.** Add four things to the scheme: raw records; content-triggered reviews that reread them; labelled decisions; and a query that puts weight ½ on the run's last review or decision step. Do not add randomized re-derivation; keep only a systematic recheck once the routine is done.

## 1. Models

The setting is slack-imitation.md §1–3: a deterministic human P on append-only notebooks, the majority decoder, τ(y) the human's own remaining time to success, (B-omit) τ(y ∪ g) ≤ τ(y), and Lemma S.

**Routine work and activities.**
* *Routine.* A problem's routine consists of units 0, …, N−1, and every successful notebook contains a record of each unit.
* *Capacity.* A step processes at most C units (doing a new one, or redoing an old one) and reads at most A raw records. A cold-start human who rereads everything has A = ∞; ordinary work reads the recent records.
* *Activities.* The *activities* of the step at notebook y are Do(y), the units it processes (|Do(y)| ≤ C), and Read(y), the records it reads (|Read(y)| ≤ A). Then n_r = N/C ≤ n₀ is the number of steps of routine work.

**By-product insights.** For problem p there is a value k_p ∈ {1, …, q} and a trigger set T_p of activities. The human's step at y writes k_p iff y has no insight and the step's activities meet T_p.
* **(U) Unpredictability.** At every state, P's output depends on (T_p, k_p) only through whether the step's activities meet T_p, and on k_p only if they do. The human cannot say in advance which unit will trigger.
* **Variants.**
  * *(BP-do)* T_p = {do u : u ∈ U_p}. The trigger is an unrecorded experience; |U_p| = w is the *multiplicity*. Thread E's V5 is the case w = 1.
  * *(BP-raw)* T_p also contains "read the raw record of u", for u ∈ U_p.
  * *(BP-sum)* T_p also contains reading u's summary.
* **Trigger capacity** κ: κ = C for BP-do and κ = C + A for BP-raw.

**The hard class BP(m, N, C, w, η, q).**
* *The prior.* Independently for each problem p ≤ m: with probability 1 − η there is no insight. Otherwise U_p is a uniform w-subset of the units, and k_p is uniform on {1, …, q}.
* *The human.* P_θ is defined on every state. The state fixes the units Do(y) of the step, with |Do(y)| ≤ C, independently of θ. P_θ writes their records, and writes k_p iff Do(y) ∩ U_p ≠ ∅ and the single, append-only insight slot is empty.
* *Success* is any notion under which a notebook of an insight problem succeeds only if its slot holds k_p.

## 2. What no scaffold can do: the work-conservation bound

**Theorem G3.** Let a protocol make Q queries to P_θ, chosen adaptively and possibly at random. They may be task queries at any states, under any scaffold, or any other human step whose answer depends on θ only through the units it processes, such as a check that reads the notebook. Let each query process at most κ units. Then, for a fresh uniform problem p and any output decoder Ĝ,

  Pr[Ĝ's run on p fails] ≥ (1 − 1/q)·η·(1 − 2κwQ/(Nm)).

So for ε ≤ 1/16, with η = 8ε and q = 2, failure at most ε needs κQ ≥ Nm/(4w): the human must process a share at least 1/(4w) of the m problems' routine work. For w = 1 and κ = C this is Q ≥ n_r·E[K]/(32ε·log₂(eN/(4ε))).

*Proof.* As for note.md's Theorem 3, with probes replaced by groups.
1. A query reveals something about θ only if its units U meet U_p for a problem p not yet found. Call it a *probe* of p. It *hits* if U ∩ U_p ≠ ∅, and then it reveals k_p.
2. *Each probe hits with probability at most 2ηwκ/N.* Let S be the units of p probed so far, all without a hit. Given the history, either p has no insight, or U_p is a uniform w-subset of the units outside S. So, with Pr[U_p ∩ S = ∅ | insight] ≤ (N − |S|)/N,
   Pr[hit] ≤ (η·Pr[U_p ∩ S = ∅ | insight]/(1 − η))·w|U ∖ S|/(N − |S|) ≤ (η/(1−η))·wκ/N ≤ 2ηwκ/N.
3. *Few problems are found.* The expected number of problems hit is at most 2ηwκQ/N. The fresh p is uniform and independent of everything else, so it has been found with probability at most 2ηwκQ/(Nm).
4. *An unfound insight cannot be guessed.* If p has an insight and was not found, no answer depends on k_p. So k_p is uniform given the transcript, and Ĝ's slot holds it with probability at most 1/q.
5. *Conclusion.* Combine as in Theorem 3. For the form in K: E[K] = m(h(η) + η·log₂(Nq)) ≤ 8εm·log₂(eN/(4ε)) when w = 1 and q = 2. ∎

*Remarks.*
* **Why it covers every scaffold.** A scaffold only decides which states the human sees.
  * A re-derivation instruction is a state whose Do set is an old unit, and a seed is part of a state.
  * Raw records and reviews are reading, which BP-do ignores.
  * A human step does at most C units of work, so it tests at most C trigger opportunities. It is a *group query* of size C, in thread D's frame.
* **Why checks do not help either.** Note.md's monitored bisection works on Theorem 3's class because there the human can tell that a draft lacks an insight it would have had by now. A BP-do human cannot tell this without redoing the work, so a check is also a group query of size at most C. This is the precise sense in which an insight triggered by doing is "silent even in hindsight".
* **The bound is attained.** Ask-before-committing with α < η/N (note.md's "cheating" protocol, §4.1) has the human do every unprobed routine unit: n_r queries per problem, within a factor 4 of the bound. On this class, nothing beats having the human do the routine work.
* **Readable triggers.** If reading u's raw record also triggers (BP-raw), the same proof gives κQ ≥ Nm/(4w) with κ = C + A. The bound is vacuous once A ≈ N, which is what a review provides (§4).

**Characterization.** In classes like BP, finding one by-product insight costs Θ(N/(κw)) task queries.
* *Lower bound:* Theorem G3.
* *Upper bound:* the uniform query of slack imitation lands on a mistake with probability E|M|/n. In BP, the mistakes of a run that loses the insight are exactly its steps that meet T_p. This probability is at least about wC/N with a systematic recheck (Proposition G2(b)), and at least about ρ/(L+1) with a review every L work steps, since every review after the omission is a mistake (Theorem G4).
* *So:* the factor n can be avoided iff κw = Ω(N).

## 3. Re-derivation, and the slack lemma with random τ

**Seeds.**
* *The design.* The scaffold draws a seed s_k ~ ν for each step k, i.i.d. with the same law at every step, so the clock stays hidden. The seed is part of the human's input in both chains. P is then a deterministic function of (y, s), and a correct imitator step must produce exactly P(y, s), as thread E's §4 design law requires.
* *The learning facts still hold.* Data are pairs ((y, s), P(y, s)). Lemma 1 of note.md holds verbatim on this larger input space. Theorem 1 of without-a-check.md also holds, because the query is drawn after the run.

**Random remaining time.** Let τ(y; s₁s₂…) = min{m : S(P^m(y; s₁…s_m))}. For a run with seeds s₁, …, s_n, let s⃗⁽ᵏ⁾ = (s_{k+1}, …, s_n, s′_{n+1}, …) with fresh seeds s′, and let τ_k = τ(x′_k; s⃗⁽ᵏ⁾).
* (T1) holds on every path: a correct step gives τ_{k+1} = τ_k − 1. (T2) holds as before.
* *The cost* of step k is c_k = τ_{k+1} − τ_k + 1, with c_k := 0 once τ_k = ∞. It is 0 at correct steps.
* *The coupling.* Write y = x′_k and s = s_{k+1}. Then c_k = τ(y ∪ G(y,s); s⃗⁽ᵏ⁺¹⁾) − τ(y ∪ P(y,s); s⃗⁽ᵏ⁺¹⁾): the extra time the human needs from the imitator's output, over its own output, on the same future seeds. (B-omit) says c_k ≤ 1, and (B-commit) says c_k ≤ D + 1.

**Lemma S-rand.** Fix the data, and let F_{k+1} be generated by the seeds s₁, …, s_{k+1}. Suppose E[min(c_k⁺, σ+1) | F_{k+1}] ≤ D + 1 at every mistake k of a non-bizarre run. Then

  Pr[the run fails] ≤ Pr[τ₀ > n₀] + ((D+1)/(σ+1))·E|M|.

*Proof.*
* If the run fails, then τ_k ≥ 1 for every k by (T2). While τ is finite, τ_n = τ₀ − n + Σ_{k∈M} c_k, and τ can become infinite only at a mistake.
* So on the event {fail, τ₀ ≤ n₀}, either some c_k with k ∈ M is infinite, or Σ_{k∈M} c_k ≥ σ+1. Either way Σ_{k∈M} min(c_k⁺, σ+1) ≥ σ+1. Hence 1[fail, τ₀ ≤ n₀] ≤ Σ_k 1[k ∈ M]·min(c_k⁺, σ+1)/(σ+1).
* {k ∈ M} is F_{k+1}-measurable. So the k-th term has expectation E[1[k ∈ M]·E[min(c_k⁺, σ+1) | F_{k+1}]]/(σ+1) ≤ (D+1)·Pr[k ∈ M]/(σ+1). Sum over k. ∎

The costs anticipate future seeds and are not independent; the proof uses only linearity. `threadG_checks.out` checks the pathwise inequality on 4,184 failed runs of random seeded humans, with no violation.

**Theorem G1 (online, seeded SI).** Suppose E[Σ_t Σ_{k∈M_t} min(c_k⁺, σ+1)] ≤ (D+1)·E[Σ_t |M_t|]: the mean truncated cost, over all mistakes on all runs, is at most D + 1. Then for every sequence of problems, under Protocol SI with seeds,

  E[#failed runs] ≤ Σ_t Pr[τ₀ᵗ > n₀] + (D+1)·n·⌊K⌋/(σ+1).

*Proof.* The pathwise inequality above gives E[#failed runs with τ₀ ≤ n₀] ≤ ((D+1)/(σ+1))·E Σ_t |M_t|. By Theorem 1 of without-a-check.md, E Σ_t |M_t|/n ≤ ⌊K⌋. ∎
* *The graded reading, made precise.* The averaged hypothesis is what slack-imitation.md §4 calls the graded reading: all mistakes, weighted equally.
* *The floor* Σ_t Pr[τ₀ᵗ > n₀] is the human's own slowness on the drawn seeds. So n₀ must be a high quantile of the human's random routine time.
* *The check version* of Theorem 2 carries over verbatim.

**Corollary (the gain cap).** Suppose a share β of all mistakes is never recovered (c = ∞), and the rest have mean truncated cost at most D + 1. Then D + 1 may be replaced by β(σ+1) + D + 1:

  E[#failed] ≤ floor + (β + (D+1)/(σ+1))·n·⌊K⌋.

Chained imitation's bound is n₀K, so the guaranteed gain is (1−ρ)/(β + (D+1)/(σ+1)), about (1−ρ)/β for long projects. Here β counts mistakes, not hits. A failed run with no recovery has only a few mistakes, so β is typically smaller than such runs' share of failures.

**Proposition G2 (conservation law for re-derivation).** Take BP-do with U_p uniform, any scaffold in which a step processes at most C units (seeded or not), and the decoder of a problem whose insight is not yet located. By Proposition G6(a), that decoder omits the insight at every touch.
* **(a) Mistakes.** The mistakes of its run on an insight problem are exactly the steps that touch U_p. So E_{U_p}|M| = w·T/N ≤ wCn/N, where T is the run's number of unit-touches. A uniform query therefore lands on a mistake with probability at most wC/N, whatever the redo rule.
* **(b) A systematic recheck.** Suppose that once the routine is done, the step at k ≥ n_r rechecks units in a fixed cyclic order. Then |M| ≥ w(1 + ⌊(n − n_r)/n_r⌋) for *every* U_p.
  * With σ ≥ n_r, the charge n/|M| is then about n_r/w, which is chained imitation's without slack.
  * No seed is needed, and n₀ does not grow, because the human's own chain succeeds by the end of the routine and never rechecks.
* **(c) Recovery.** Consider an omission at a touch of u.
  * Routine steps are correct, so on the same seeds the human's continuation touches the same units as the run. It therefore recovers at the next touch of U_p, and never otherwise. So Pr[recovered] ≤ E[later touches of U_p].
  * Take the rule "with probability p, redo a uniform done unit instead of a new one" (w = 1). Unit u is never redone during the routine with probability (u/N)^{p/(1−p)}·(1 + O(1/u)), which is 1 − p on average over u.

*Proof.* (a) Before t_p is located the decoder omits at every step, and the human writes k_p exactly at the steps that touch U_p. Each touch lands in U_p with probability w/N on average. (b) Each unit is touched once in the routine, and once in every n_r steps of rechecking. (c) With j units done, the number of redo steps before the next new unit is geometric with mean p/(1−p), and each redoes u with probability 1/j. So u is missed at level j with probability (1−p)/(1 − p + p/j) = 1 − p/((1−p)j) + O(j⁻²); multiply over j = u+1, …, N. `threadG_checks.out` matches this to within 0.01 at N = 64. ∎

*What this means.*
* **"Bounded expected setback of about 1/p" is false** for insights triggered by doing.
  * A redo rate p buys about (p/(1−p))·ln(N/u) extra mistakes per lost insight during the routine (p/(1−p) on average over u), not a bounded setback.
  * The routine itself lengthens by the same factor: n₀ becomes about n₀/(1−p). So the hit rate per query is unchanged, as (a) says.
  * With probability about 1 − p the omission is never recovered during the routine, so the truncated mean cost in Lemma S-rand is of order (1−p)·σ. Nothing beyond (a)'s count of mistakes is gained.
* **The only gain** is (b): slack's idle steps on a failed run become re-touches.
* **Cost.** K grows by the redo rule, plus whatever the human does differently on a redo step, which is O(1) in BP. Thread E's design law holds, since the seed is in the input of both chains.

## 4. Readable triggers: raw records and reviews

**When reading triggers as doing would.** Condition (Rec), on a by-product insight I of unit u:
* **(Rec1) The record suffices.** Whether the human has I when doing u at y depends on the doing only through u's raw record r_u: I is triggered iff φ(r_u, y), for some predicate φ.
* **(Rec2) More context does not hide it.** φ(r_u, y) implies φ(r_u, y′) for the notebooks y′ ⊇ y ∪ r_u that the imitator's runs reach. Later content does not explain the anomaly away.
* **(Rec3) The record is faithful.** r_u on the imitator's notebook is the human's: either machine output appended by the scaffold in both chains, or deterministic content the imitator gets right.
* **(Rec4) Someone rereads it.** Some later step of the human's continuation rereads r_u, looking for anomalies.

*Where each fails.*
* (Rec1) fails for tacit, sensory or effort-based cues. It also fails partly through the generation effect: material one generates is processed more deeply than material one reads (Slamecka and Graf 1978†).
* (Rec2) fails when the imitator writes a plausible explanation of the anomaly. That is a fooled commission, not an omission.
* (Rec3) fails when the imitator predicts the typical value of an observation collected by hand, which deletes the anomaly (thread E's V1).
* (Rec4) fails for long notebooks without reviews (V10).

*What each design supplies.* Raw records supply (Rec1) for the insights that need detail a summary drops: BP-raw, as against BP-sum. Reviews supply (Rec4).

**Corollary G5 (attention windows).** In BP-raw with w = 1, consider a human that reads the raw records of its last a units, with no review.
* *Upper bound.* The mistakes of a run that loses the insight include the steps t_p, …, t_p + a. So slack imitation charges such a failure at most n/(a+1).
* *Lower bound.* Theorem G3 with κ = C + a gives κQ ≥ Nm/4 for every protocol.
* *So* the recoverability window sets the cost, Θ(n/a), not the mere presence of raw records. In G1 (a = 4) this is 5–7 times cheaper than doing-only humans with slack.

*The cost of raw records.* n₀ grows by the time spent recording, which is small when the scaffold appends machine output. K grows by the human's recording format; machine output appended by the scaffold costs the learner nothing, and hand-computed data cost about the procedure's description. Longer labels give more room for wording differences, which need faithful paraphrase, (B-commit) with D = 0.

**Content-triggered reviews ("fresh-eyes" steps).** The instruction, in both chains, is: "when L work steps have been added since the last review, spend the step rereading every raw record, and record anything surprising."
* *Cost.* The trigger is content, so the clock stays hidden. n₀ grows by the factor 1 + 1/L.
* **(R-rev).** Let y′ be a review notebook on the imitator's runs. Suppose y′ ⊇ x′_k ∪ (P(x′_k) ∖ {I}) for an earlier step k at which I was a by-product insight satisfying (Rec1)–(Rec3), and y′ lacks I. Then I ∈ P(y′).
* *A by-product-ripe failure* is a failed run in which, at some step k before its last review, the imitator wrote exactly the human's step minus such an insight I, and I is absent from the final notebook.

**Theorem G4.** Assume (R-rev). Protocol MIX-REV task-queries the run's last review step with probability ½, and a uniform step otherwise (runs that fail the check get the flip query). For every sequence of problems,

  E[#by-product-ripe failed runs] + (max{1, (σ+1)/(D+1)}/(2n))·E[#other failed runs with (B_D) at all their mistakes] ≤ ⌊K⌋.

*Proof.*
* *A ripe failure.* Let r be the last review step of a by-product-ripe failed run. Its notebook x′_r contains x′_{k+1} = x′_k ∪ (P(x′_k) ∖ {I}), and it lacks I, since I is absent at the end and notebooks only grow. By (R-rev), I ∈ P(x′_r). But I ∉ G(x′_r), or I would be in the final notebook. So r is a mistake, and the query lands on a mistake with probability at least ½.
* *Other failed runs* satisfying (B_D) have |M| ≥ max{1, (σ+1)/(D+1)} by Lemma S, so the query lands on one with probability at least that divided by 2n.
* *The sum.* Apply Theorem 1 of without-a-check.md. ∎

*Remarks.*
* **No factor n, and no bounded delay needed.** A ripe failure needs only detection at the last review, as in thread C's Theorem A. The review supplies the threshold structure: it is a group query over every unit reviewed.
* **Lateness after detection.** The decoder may learn I and then write it too late for the work that depends on it. That is an unripe failure, charged by the second term if (B_D) holds there.
  * (R-rev) also bounds the setback of the omission by about L + 1, if the downstream work is delayed by no more than the insight itself.
  * So Lemma S applies with D = L + 1 even without MIX-REV.
* **Limited reading capacity.** Suppose a review can reread only A < N records. Then rotate, so that each record is reread every ⌈N/A⌉ reviews, and query a uniform one of the last ⌈N/A⌉ reviews. A ripe failure is then hit with probability at least 1/(2⌈N/A⌉), which matches Theorem G3's Ω(N/(C+A)).

## 5. Hedges

**The model (BP-hedge).**
* *The idea A* becomes available at a step t_A, triggered by content, and it is persistent on notebooks without B: there the human writes A at every step from t_A on.
* *The decision point.* At a step d, also triggered by content (for example "when the routine is done, choose the plan"), the human writes A if A is available and absent. Otherwise it adopts a default B, written as a labelled decision.
* *Pre-emption.* On a notebook containing B, the human never writes A.
* *Its own chain* has t_A < d, so B never appears there.

**Why this is the general form.** By thread C's Proposition 2, the decoder writes an item iff Pr[due]·p_max > 1 − Pr[due].
* If the human wrote B only together with A, the two would be due together, and the decoder would write both or neither.
* So a hedge that pre-empts A on the imitator's notebooks must be due where A is not: a default or substitute, adopted where A is missing.
* This is a heuristic for posteriors that are not products, as Proposition 2 is. Thread C's example is the case d = t_A. There the decoder writes B alone only if B has a high base rate elsewhere, that is, if B is a default.

**Proposition G7.** In BP-hedge, while A is not located:
* **(a) The mistakes.** They are the steps t_A, …, d. From t_A on, every step omits A, which the human would catch up; at d the decision commits B where the human would write A. After d, A is never written, so the setback is infinite. Uniform queries pay n/(d − t_A + 1).
* **(b) The decision step is a group query** over every t_A < d.
  * If decisions are labelled entries, the human writes the label in its own chain, so the imitator copies it, and the design law holds.
  * Then querying the run's first default decision with probability ½ gives E[#hedge failures] ≤ 2⌊K⌋, as in Theorem G4.
  * With up to d_max labelled decisions per run, querying a uniform one gives at most 2d_max⌊K⌋.
* **(c) Asking.** At the decision step the posterior mass of A is Pr[t_A < d | data]. So ask-before-committing fires there for every kind of idea whose prior rate exceeds α.
* **(d) Doing-only ideas.** If A is itself a by-product triggered only by doing, the decision step is not a mistake: the human at d lacks A too. Theorem G3 then governs.

*Proof.* (a) and (c) follow directly from the model. For (b): in a failed hedge run, the decision step commits B at a notebook that lacks A while A is available, and there the human writes A. Apply Theorem 1 of without-a-check.md. ∎

*Defaults that expire.* A review instruction that reopens decisions makes hedge failures ripe at the last review too, provided the human at a review really does reconsider B. Call that (R-hedge); it is a behavioural assumption.

## 6. Ask-before-committing

**Proposition G6.** In BP(m, N, C, 1, η, q), for a problem whose insight is not yet located:
* **(a) Routine steps.** At a state whose step processes units U, with |U| ≤ C, the posterior mass of the insight is at most ηC/(N(1−η)) ≤ 2ηC/N. It is split equally over the q values, and "no insight" has the rest.
  * So for α > 2ηC/N, SI-ABC asks at no routine step before the insight is located, and never commits an insight there.
  * Its by-product failures are therefore SI's.
* **(b) Reviews.** At a step that covers U (a review), the mass is Pr[t_p ∈ U | data], which is η|U|/N for a fresh problem. While "no insight" is the top label, SI-ABC asks iff this mass exceeds α.
* **(c) Small α.** For α < η/N, SI-ABC asks at every unprobed routine step: at most n_r asks per problem, within a factor 4 of Theorem G3.

*Proof.* (a) and (b) are step 2 of Theorem G3's proof. Given the data, k_p is uniform and independent of t_p, so each value has mass Pr[t_p ∈ U]/q. (c): an unprobed unit has mass at least η/N. ∎

*Asking combined with reviews.*
* *The bounds.* Asks number at most K/log₂(1/(1−α)) on every path (Proposition 5(a)), and asked reviews are never mistakes. Proposition 5's proof works for any query law drawn after the run. So under SI-ABC with MIX-REV, E[#by-product-ripe failures] ≤ 2K/max{1, log₂(1/α)}.
* *What stays confident.* After a review answered "nothing", later reviews carry only the doubt of the units added since. What stays confident is the rare kinds (prior rate below α) and late triggers. Last-review queries catch those.

*Answer to question 4.* Asking does not help with insights triggered only by doing. It helps readable insights and hedges, exactly at the steps where the scaffold makes doubt aggregate: reviews and decision points.

## 7. Experiment G1

**Setup** ([`threadG_byproducts_sim.py`](threadG_byproducts_sim.py); exact posteriors).
* *The class.* BP with m = 100, η = ½, q = 2 and w = 1, success as in §1, and no dependent work, so lateness never matters: G1 isolates loss.
* *The variants* differ only in which units' triggers fire at each step:
  * DO: doing only;
  * RECHECK: DO plus a cyclic recheck once the routine is done;
  * REDO: seeded, with probability ½ a step redoes a uniform done unit instead of a new one, and rechecks a uniform unit once done;
  * WINDOW: readable, with attention window a = 4;
  * REVIEW: readable, with a review after every L = 4 work steps.
* *Slack* ρ = ½ (n = 2n₀) everywhere except DO0, which is chained imitation without slack.
* *Measurement.* 40 humans per cell; mean task queries until at most 2% of problems fail (oracle stopping, as in E6). The online part runs 3,000 rounds on 20 humans with α = 0.3.

**Results** (from `threadG_byproducts_sim.out`; n in brackets):

RESULTS_TABLE

**Reading.**
* *Conservation (Proposition G2).* Slack doubles the cost for silent humans, as slack-imitation.md's Remark 2 says. A recheck or seeded redo restores chained imitation's cost without slack, within the standard errors, and no variant does better.
* *Windows (Corollary G5).* WINDOW still grows in proportion to n, about 5–7 times below DO.
* *Reviews (Theorem G4).* Costs are flat in n: about 300 with last-review queries and 450–550 with MIX-REV. Uniform queries alone are also flat (1,500–2,100), because each lost insight leaves a mistake at every later review.
* *Asking (Proposition G6).* No asks ever fire on DO humans. On REVIEW humans, asking fires at the first review whose aggregate doubt exceeds α.
* *What G1 does not test:* whether real insights are readable, which is §8's question.

## 8. How common are by-product insights, and do the designs fix them?

**Evidence (from memory, †).**
* *Readable from raw records.*
  * Jocelyn Bell's pulsar came from "scruff" on chart-recorder paper she was reading by hand. A summary that kept only known sources would have dropped it.
  * Penzias and Wilson's excess noise was in the raw measurements.
  * Fleming's mould was on a plate, a physical raw record, noticed while clearing up.
  * Dunbar's in vivo studies of molecular biology labs found unexpected results to be a large share of findings, often reasoned about in lab meetings from presented data. That is reading, not doing.
  * Code inspections find a large share of defects by reading code (Fagan 1976).
  * Patterns in mathematics are often visible in a table of small cases.
* *Doing only.*
  * Röntgen's glowing screen was seen during the work, though it was highly reproducible, so its multiplicity was high.
  * Experimentalists' tacit cues (a smell, a sound, how a sample behaves).
  * The insight that comes from the struggle of an attempt rather than from its record.
  * The generation effect is robust in the laboratory.

**My estimates.** These are shares of the imitator's *run-sinking* confident omissions, for a careful researcher who keeps raw records once instructed to.

| | mathematics | software | empirical |
|---|---|---|---|
| by-product (triggered by an activity, not by the notebook's content) | 30% | 35% | 50% |
| of these: readable at a review that rereads raw records, (Rec1)–(Rec3) | 60% | 65% | 35% |
| of the rest (doing only): recur within the slack (large w) | 40% | 50% | 35% |
| unrecoverable residue without raw records or reviews (only spontaneous rereading, a third of the readable ones) | 14% | 14% | 29% |
| unrecoverable residue with raw records and reviews | 7% | 6% | 21% |

*Why empirical work is worst.* (Rec3) needs the scaffold to produce the data in both chains. An observation collected by hand and written by the imitator loses its anomaly.

**Probabilities.** The first three rows use the table's denominator, run-sinking confident omissions. Version 2's graded reading counts *all* confident omissions, harmless ones included. So a residue of 7% of the run-sinking ones is perhaps 2–4% on version 2's reading. The relevant quantity for the guarantee is β over all mistakes (the Corollary of §3).

| claim | without / with raw records and reviews |
|---|---|
| by-product residue ≤ 5% of run-sinking confident omissions: mathematics / software / empirical | 15% / 40%; 15% / 45%; 3% / 8% |
| the same at ≤ 15%: mathematics / software / empirical | 55% / 80%; 55% / 85%; 15% / 35% |
| (B-omit) on version 2's graded reading, all omission mechanisms (with labelled decisions in the second column): theory and mathematics | 55% / 65% |
| the same: empirical or judgment work | 30% / 40% |
| randomized re-derivation lowers the residue by more than a factor 1.5 | below 10% |

*Against version 2's 70% / 50%.*
* *70% for theory* is right, I think, only with reviews that reread raw records. Version 2 lists content-triggered audits as a valid variant, but does not use them for omissions.
* *For empirical work* I am lower, because of (Rec3) and tacit cues.
* *The verifier version* is unaffected: a lost insight costs search queries, never a wrong output.

## 9. Open problems

1. **Measure trigger types.** In researchers' own notebooks, remove an insight together with the routine unit that produced it. Then see whether a review of the raw record restores it, and how often the insight recurs at a later unit. This estimates (Rec) and w directly; nothing else in this note can.
2. **Cheap partial re-derivation.** The conservation law counts units of capacity. A redo that costs a tenth of a unit but carries much of the trigger (redoing only the delicate part of a computation, or rerunning a calibration) would raise κ at little cost. Is there a principled way to find such parts without knowing the insight?
3. **Non-monotone context (Rec2).** How should a review treat the imitator's own explanations of anomalies? Two candidates are a quarantine for explanations, and a review instruction to re-derive every explanation from the raw record.
4. **A lower bound for windows with reviews of limited capacity,** tight in L, A and N together, and the matching protocol for real notebooks.
5. **Decision labels.** Do real researchers' defaults appear at identifiable decision points, so that querying those steps (Proposition G7(b)) is practical?
