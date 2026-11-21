# Thread Q: alternatives to slack imitation

*Research note by Claude (Anthropic) on [`../slack-imitation.md`](../slack-imitation.md), version 2. Draft; not refereed. Code: [`threadQ_hints.py`](threadQ_hints.py), which imports E6's class from [`../code/slack_imitation.py`](../code/slack_imitation.py) unchanged. Output: [`threadQ_hints.out`](threadQ_hints.out) and [`threadQ_hints.json`](threadQ_hints.json), about 10 minutes on 4 cores.*

Setting and notation are those of slack-imitation.md §1: a deterministic human P on append-only notebooks, the Bayes majority decoder G, K = K(P), the potential Φ, Lemma 1 of note.md (at most ⌊K⌋ task queries land on mistakes), success S preserved by appending, τ(x₀) ≤ n₀, runs of n = n₀ + σ steps, and (B_D) bounded setback. No assumption below is an "on track" judgment.

## Answers in brief

1. **Chained imitation's n₀K/ε is three factors, and each needs something different.**
   * *K* is what must be learned. Probes and a corpus reduce it (thread B).
   * *1/ε* is the cost of *finding* a failed run, since a random run fails with probability ε. Any yes/no answer that flags failed runs removes it. Call this **detection**.
   * *n₀* is the cost of *locating* the mistake on a failed run, since a point query hits it with probability |M|/n. Only **location** removes it. Its sources are recovery (slack under bounded setback), the human's hindsight, where mistakes sit, the imitator's doubt (asking), and state judgments, which are excluded here.
2. **Verifying the final result detects but does not locate (Theorem Q1).** On the silent hidden-insight class, with any number of final verifications, a protocol still needs Ω(nK/log(nq)) task queries, unless it spends about q verifications per insight guessing the insight's content. The 1/ε goes; the n stays. Check-and-scan meets the bound up to the log.
3. **Use human judgments as hints, never as certificates (Lemmas Q2, Q3).** On a rejected run, interleave uniform search with any pointer:
   * the human's post-mortem list ("this project failed; which entries would you re-examine first?");
   * "the first entry you would have done differently";
   * content features learned from earlier culprits;
   * a scan from step 0, which hits within n₀ queries because the first mistake of a rejected run comes before n₀.

   With r streams, the search costs at most r times the best stream's cost, and it never adds false data. A useless or adversarial pointer costs a factor r and nothing else, so no guarantee assumes the judgment is right.
4. **The candidate: VSP, verified slack imitation with post-mortem search (Theorem Q4).** It is slack imitation with a final verification by the human (or its imitation), and a three-stream search on rejected runs: uniform, scan, and post-mortem list. Asking before committing is optional.
   * *Correctness* rests on the verifier's soundness alone, not on bounded setback: no failed run is output.
   * *Cost per rejection* is at most 3n₀ search queries whatever the human, 3(D+1)n/(σ+1) under (B_D), and 3s when the post-mortem list holds a mistake.
   * *Rejections* number at most K/max{1, log₂(1/α)}, so task queries are O(K) when setbacks are bounded or post-mortems work, and O(n₀K) in the worst case, with no 1/ε either way.
   * *With audits* it keeps SI-ABC's guarantee for the failures the verifier misses, so it is never worse than SI-ABC.
5. **Imitating the verifier makes the number of problems drop out (Theorem Q5).** A verifier is a one-step function, so its imitation has no horizon and no location problem. K_V/ε human verifications give a false-accept rate ε relative to the human's verdicts, for any number of problems. Imitate judgments of finished products. Do not imitate the pointer: it is a function of the posterior and inherits its blind spots.
6. **What the verifier must satisfy: it never accepts an imitator notebook that fails S.**
   * Most weak-link failures (silent omissions, fooled commissions, confident dead ends) end with *no* result, which any verifier rejects. The risk is confident *wrong* results, and it multiplies with how often such failures occur. Audits bound what remains at SI-ABC's rate.
   * My estimate that soundness holds at the graded level: 85% for written mathematics and software, 40% for empirical work.
7. **Ensembles, query-by-committee and redundant runs cannot find confident silent omissions (Proposition Q6).**
   * At a step with top mass μ, a committee of k disagrees with probability at most k(1 − μ): this is asking before committing with randomness added.
   * At run level, a posterior sample writes the missing insight at a step drawn from the posterior of its time. Given the data that step is independent of the true time, so the hit rate equals a uniform probe's.
   * Doubt carries no location where the data carry none.
8. **Granularity is a wash in the worst case (Proposition Q7).** In human time, chained imitation's bound and Theorem 3's lower bound do not depend on the step length. Finer steps help slack imitation only when setbacks are short in absolute time, and they strain the cold-start model.
9. **Short questions and probes.**
   * Single-step reviews and "the first entry you would have done differently" are point queries in the worst case (thread A's Theorem C). They cut the time per question, not the factor n.
   * "What are the key ideas?" gives content, not location. Under slack, content suffices for humans whose contributions stay due, not for silent ones.
   * Located probes need foresight (thread B). The post-mortem list needs only hindsight, which is why I prefer it.
10. **By-product insights are confident omissions only when they are rare at recognizable stages (Proposition Q8).** If the human's contributions occur at a recognizable kind of state with posterior rate above α, asking catches each of them, at about one ask per occurrence of that state.
    * Making insight-prone activities explicit stages, with outcome slots that are certainly due and diffuse, converts part of thread E's V5 into asks.
    * Rare insights at frequent stages remain the irreducible case.
11. **The human's own runs** cost n₀ each and find the current imitator's first divergence with certainty. Their best use is calibration: the search's feature weights (thread D's Scheme D, moved inside the search), and measurements of setback, verifier soundness and post-mortem accuracy.
12. **Experiment EQ** (E6's humans and seeds; total task queries for 100 problems at n = 16 → 64 → 256). E6's uniform search (SI-V) is reproduced exactly.
    * *Hinted search for fooled humans:* 181 → 750 → 2,636 become 28 → 37 → TBD with a structural hint, against 236 → 318 → 360 for SI-V with asking.
    * *Scan for silent humans:* 1,610 → 6,450 → 26,091 become 663 → 2,497 → TBD.
    * *Bounded-setback humans* pay at most 1.5× for the extra streams.
    * *An adversarial pointer* costs at most 1.6×, within Lemma Q2's factor 2.
13. **Ranking** (Section 9, P(works) for theory and software / for empirical work):
    * VSP with a machine verifier: 85% / –;
    * VSP with a human verifier: 70% / 30%;
    * SI-V with a human verifier and uniform search: 65% / 25%;
    * SI-ABC, the current recommendation: 50% / 25%;
    * every alternative without a verifier: 25% or less.
14. **Verdict.** Nothing dominates slack imitation as the engine of *location*: Theorem Q1, Proposition Q6 and thread A's Theorem C rule out verification, ensembles and short reviews as replacements. What dominates SI-ABC *in sureness* is an addition, a final verification by the human with hints in the search. Where finished results cannot be verified soundly, as in much empirical and judgment work, I found nothing that dominates SI-ABC.

## 1. Detection and location

In note.md's Proposition 2 the uniform query hits with probability |M_t|/n. Successful runs cost a query and teach nothing, which is the 1/ε. Failed runs with few mistakes are the n.

| source | what it needs | what it removes | here |
|---|---|---|---|
| final verification | soundness on imitator notebooks | 1/ε | Theorem Q1, Theorem Q4 |
| recovery (slack) | bounded setback | n → (D+1)/ρ | slack-imitation.md, Theorem 2 |
| hindsight (post-mortem list) | nothing for safety; accuracy for gain | n → s | Lemma Q2 |
| first divergence | completeness of the verifier | n → n₀ (by scanning) | Lemma Q3 |
| position, feature or trigger laws | concentration | n → (Σ√π)² | Scheme D, Proposition Q8 |
| the imitator's doubt | nothing | unconfident mistakes | slack-imitation.md, Proposition 5 |
| a state judgment | preservation (excluded here) | n → log n | note.md |

Thread D's point/threshold/group frame applies to location. Detection is a group query over the whole run that answers *whether* but not *where*.

## 2. Questions to the human

### 2.1 Verify the final result

**Theorem Q1 (verification detects but does not locate).** Take note.md's hidden-insight class with q ≥ 4.
* *Queries.* A protocol makes, adaptively and possibly at random:
  * Q task queries at any states;
  * V verifications Ver(p, a), "is (p, n, a) your final state on problem p?", for any a ∈ {⊥, 1, …, q};
  * any s-local reviews (thread A), each counted as s task queries in Q.
* *Output.* A decoder Ĝ.
* *The bound.* For θ from the prior and a fresh uniform problem p,

  Pr[Ĝ's run on p does not end at the human's final state] ≥ (1 − 2/q)·η − 4Q/(nm) − 4V/(qm).

*Consequence.* Let q ≥ 8. Failure at most η/4 needs Q ≥ ηnm/16 or V ≥ ηqm/16. Since E[K] ≤ ηm·log₂(e·nq/η), this means Q ≥ n·E[K]/(16·log₂(enq/η)).
* *ε.* With η = 4ε, a target ε needs Ω(nK/log(nq/ε)) task queries: the factor n, but no 1/ε.
* *Tightness.* Check-and-scan (note.md, Proposition 8) uses at most nK, and Lemma Q3's scan at most n₀K.

*Proof.*
1. *Reviews.* They reduce to task queries (thread A, Theorem C).
2. *Hits.* A query about p is informative only if it probes (p, j, ⊥) or verifies p, and Ver(p, ⊥) reveals only whether p has an insight. Say p is *hit* when a probe at t_p, or a verification at k_p, is answered.
3. *Conditional laws.* Given p has an insight and the history, (t_p, k_p) are independent and uniform on the steps not yet probed and the values not yet excluded. So the i-th distinct probe of p hits with probability at most 1/(n − i + 1), which is at most 2/n while i ≤ n/2. Likewise a verification hits with probability at most 2/q while fewer than q/2 values have been tried.
4. *Heavy problems.* At most 2Q/n problems get more than n/2 probes, and at most 2V/q get more than q/2 verifications; count all of these as hit.
5. *The count.* The expected number of hit problems with an insight is at most 4Q/n + 4V/q.
6. *The fresh problem.* p is uniform, so Pr[p has an insight and is not hit] ≥ η − 4Q/(nm) − 4V/(qm). On that event k_p is uniform on at least q/2 values given the transcript, and Ĝ ends at k_p with probability at most 2/q. ∎

*Reading.* Detection tells the learner *which* problems hide something, the "presence" location of thread B's E5, worth a constant. It does not tell *where in the run*. Guessing content by verification is generate-and-test (Section 7), which needs the posterior to put real mass on the right idea. Free probes with recall φ multiply Q's term by 1/(1 − φ), as in thread B's Theorem 4.

### 2.2 Hints: post-mortems, a colleague's notebook, scans

**Lemma Q2 (hints are free of risk).** Fix a rejected run of a frozen decoder, and let M ≠ ∅ be its committed mistakes.
* *The search.* It task-queries states of the run until one lands in M, and adds the answers afterwards, the hit first.
* *Its streams.* It takes queries from r streams in round robin, skipping any stream with nothing left. A stream is either a uniform committed step, drawn with replacement, or the next unasked entry of a list fixed when the search starts. Anyone may write the list: the human, the protocol, or an adversary who knows M.

Then:
* (a) every answer added is P's, and the hit lowers Φ by at least 1, or by at least log₂(1/α) under asking (data ordered as in slack-imitation.md, Proposition 5);
* (b) E[queries] ≤ r·min{n/|M|, j₁, j₂, …}, where j_i is the position of the first element of M in list i (∞ if none).

*Proof.* (a) is the argument of Propositions 4 and 5 there: the hit is a committed mistake of the decoder that made the run. (b) Each stream is served at least once in every r queries.
* A list stream reaches its first mistake within r·j_i queries. Entries skipped because another stream asked them only shorten this.
* The uniform stream's draws are independent and succeed with probability at least |M|/n, so it hits within r·G queries, with G geometric of mean at most n/|M|.
* The search stops at the first hit of any stream, and E[min(a, rG)] ≤ min(a, r·E[G]). ∎

**Lemma Q3 (the first mistake comes early).** Suppose V decides S on final notebooks, S is preserved by appending, and τ(x₀) ≤ n₀. Then every rejected run has a committed mistake at a step below n₀, so a scan from step 0 hits within n₀ queries.

*Proof.* Suppose steps 0, …, n₀−1 are all asked or correctly committed. Then the notebook at n₀ is the human's own, so it satisfies S. Appending preserves S, so the final notebook satisfies it too, and V accepts it. ∎

This scan removes slack's doubling of the cost of silent humans (slack-imitation.md, Remark 2) in the worst case: n₀ per rejection, not n = n₀/(1−ρ).

**Which pointer.** The *post-mortem list* asks: "This project failed. Here is the notebook, written by a colleague. List up to s entries you would re-examine first, most suspicious first."
* *What it needs.* Hindsight and the knowledge that the project failed, not foresight. Framing the notebook as a colleague's removes the trust in one's own notebook that thread E blames for V2. That framing is allowed in the hint, since the hint is not a task step and (T1) does not apply to it.
* *Cost.* One read per rejection, so at most K/b_α reads.
* *Where it should work.* The weak links are mostly *recorded claims*: "tried A; it fails" (V2), fabricated values (V1), unverified load-bearing claims (V6). A post-mortem by a careful researcher looks exactly there.
* *Where it should not.* A lost by-product insight (V5) leaves nothing to point at.
* *Other pointers.* "The first entry you would have done differently" is the strict version with s = 1. It is n-local, so in the worst case it is worth n task queries (Theorem C), and it reads more slowly. Learned content features (Section 6) need no human.

### 2.3 Short questions and probes

* **Reviews of single steps** are 1-local, so by Theorem C they carry no more location than task queries. They change the time per question by a factor c, the ratio of review time to task-step time, and not the number of points probed.
* **"What are the key ideas?" (content).** Under slack the outcome needs the content, not its timing, but only if the decoder writes it.
  * By thread C's Proposition 2, once the content is known the majority decoder writes it when Pr[due by now] > ½. For persistent humans that happens at the posterior median of the due time, which slack absorbs if σ ≥ n₀/2.
  * For a silent human, "due" holds at one step only, of posterior mass about 1/n, so the decoder does not write the content until queries pin that step down.
  * So content probes help exactly the humans that slack already helps.
* **Located probes** ("where will the crux be?") remove n under thread B's (Loc_s), which needs foresight; the post-mortem is their hindsight version.
* **Threshold or group structure without an on-track judgment** comes from four places:
  * verification: a group query, which only detects;
  * the post-mortem list: a group hint;
  * first divergence: a threshold the protocol gets free (Lemma Q3);
  * triggers (Proposition Q8).

  None of them locates a silent by-product insight that the human cannot point to in hindsight.

## 3. The candidate: verified slack imitation with post-mortem search (VSP)

**Protocol VSP(α, β, s).** For each problem:
1. Build a run of n = n₀ + σ steps as in SI-ABC. Take α = 1 for no asks.
2. Have the final notebook verified, by the human or by the imitated verifier of Theorem Q5.
3. *If accepted,* output it. With probability β, task-query one uniform committed step (an audit), and add the answer.
4. *If rejected,* ask the human for a post-mortem list of at most s entries. Search by Lemma Q2 with three streams: uniform committed steps, a scan from step 0, and the list. Add the hit first and the rest after it. Rerun the same problem.

**Assumptions.**
* (A1) determinism, with a hypothesis class that contains P;
* (A2) S is preserved by appending, and τ(x₀) ≤ n₀;
* (A3) completeness: V accepts every final notebook that satisfies S;
* (A4) soundness: V accepts no final notebook of an imitator run that fails S.

**Theorem Q4.** Assume (A1)–(A4), and write b_α = max{1, log₂(1/α)}, with b = 1 when nothing is asked. For every sequence of problems:
* (a) every output satisfies S;
* (b) on every path there are at most K/log₂(1/(1−α)) asks, and at most K/b_α rejections and audit hits together;
* (c) E[search queries] ≤ 3·E Σ_r min{n/|M_r|, n₀, j_r} ≤ (3K/b_α)·min{n₀, (D+1)n/(σ+1), s}. The second term needs (B_D) at committed mistakes, the third needs every post-mortem list to contain a mistake, and the sum over r runs over rejections;
* (d) without (A4), the failed outputs are exactly the failed runs that V accepts, and under (B_D) at their committed mistakes E[#failed outputs] ≤ K/(b_α·β·γ), with γ = max{1, (σ+1)/(D+1)}/n. For β = 1 this is slack-imitation.md's Proposition 5(b) bound for SI-ABC;
* (e) the human's effort is one verification per run (Theorem Q5 replaces most of them), at most K/b_α post-mortem reads, and task queries for asks, searches and about β·T audits.

*Proof.*
* (a) holds by construction and (A4).
* (b) *Asks:* Proposition 5(a). *Rejections:* by (A3) and (A2), a run with no committed mistake is the human's own and is accepted, so a rejected run has one, and the search ends almost surely with a hit at a committed step k. List the asks before k, then the hit, then everything else: the hit lowers Φ by at least b_α (Proposition 5's proof, with Lemma 1 for α ≥ ½). Audit hits are counted in the same way, and Φ ≤ K.
* (c) Lemma Q2 with r = 3, Lemma Q3, and Lemma S for |M_r| ≥ (σ+1)/(D+1). Wald's identity applies, since the number of searches is bounded on every path.
* (d) As in Proposition 5(b): the run and V's verdict are fixed before the audit's coin.
* (e) Bookkeeping. ∎

**Remarks.**
* *What moved.* In SI-ABC, confident commissions and lost insights decide *correctness*. In VSP they decide only *cost*, which is at most 3n₀ per rejection whatever the human, and K/b_α rejections in all.
* *The task queries do not depend on ε or on the number of problems.* The 1/ε moves into verifications (Theorem Q5).
* *Asks are optional with a verifier.* Referee 5 found that asking multiplies SI-V's cost 6–23× for bounded-setback humans in E6. The post-mortem stream treats fooled commissions more cheaply in search (EQ), so ask only if pointers turn out poor.
* *Compared with SI-V* (slack-imitation.md, Proposition 4): VSP is SI-V with a human verifier, and with the scan and the list added to its uniform search. The extra streams cost at most a factor 3, and Lemma Q3 caps the worst case at n₀ per rejection.

### 3.1 Imitating the verifier

**Theorem Q5 (imitated verifier).**
* *The verifier.* V_H is a one-step deterministic function on final notebooks, and the learner holds a Bayes posterior over it, jointly with P or separately. K_V is its code length, or its residual after the task data (thread B, Theorem 1).
* *Protocol IV(β).* Let V′ be the majority decoder of the verifier posterior. On each final notebook y:
  * if V′ rejects, ask V_H(y);
  * if V′ accepts, ask V_H(y) with probability β.

  Add every answer to the verifier data. Treat y as accepted if V_H accepted it, or if V′ accepted it and V_H was not asked.

For every sequence of T notebooks, chosen adaptively (by VSP, for instance):
* (a) V′ disagrees with an asked V_H at most K_V times, on every path;
* (b) the expected number of notebooks that V′ accepted, that V_H was not asked about, and that V_H would reject is at most (1−β)·K_V/β;
* (c) the human verifies at most βT + R + K_V notebooks, where R is the number of true rejections;
* (d) taking β = K_V/(ε_V·T) gives at most ε_V·T bad acceptances in expectation, with about K_V/ε_V + R + K_V human verifications, independent of T. A frozen V′ on i.i.d. notebooks needs O(K_V·log(K_V/δ)/ε_V) verifications (the epochs of MB-PAC).

*Proof.*
* (a) is Lemma 1 for a one-step function.
* (b) Given the past and y, the audit's coin is independent of everything else. On a false acceptance by V′, an audit is a hit at a mistake of V′, and by (a) there are at most K_V such hits. So β·E[#false acceptances] ≤ K_V. The unaudited ones are a fraction 1 − β of them in expectation.
* (c) A rejection by V′ is either a true rejection or a mistake of V′.
* (d) is arithmetic. ∎

*Why this works for the verifier and not for location.* A verifier judges the object it is shown, so learning it has horizon 1, with no compounding and no location problem. A pointer is valuable exactly where it knows what the posterior does not. An imitated pointer is a function of the posterior, so it is a task-only rule and Theorem 3 applies to it. It can still learn generic heuristics ("negative results are suspect"): the feature stream of Section 6.

### 3.2 Soundness against plausible wrong results

* *How failures end.* A failed run either has no claimed solution, a partial result, or a dead end, which any verifier rejects; or it has a confident *wrong* claimed solution. Thread E's weak links (V2, V3, V5, hedges) mostly produce the first kind. Its V1, V6, V9 and V13 can produce the second.
* *The rate of bad outputs.* It is about p_f·w·f, where p_f is the imitator's failure rate before verification, w the share of failures with a wrong claimed result, and f the verifier's miss rate on those. Learning drives p_f down, asking removes unconfident wrong claims, and audits bound the rest (Theorem Q4(d)).
* *No selection for fooling.* Rerun-until-accepted is a yes/no filter on posteriors built only from the human's answers. As in note.md §6.3, it does not raise the ratio of accepted wrong runs to correct ones.
* *Machine checks help verification more than they help notebooks.* In mathematics, a written proof checked line by line by a careful referee is fairly sound, and a proof assistant makes it sound. In software, tests and review do the same.
* *Empirical work.* Verification is replication, unless the scaffold reruns the key experiments. Here (A4) is weak, and VSP falls back to SI-ABC's guarantee through audits.
* *What S must be.* VSP needs a crisp yes/no S. A graded "good progress" judgment would turn the filter into selection on a score, which note.md §6.3 warns against.

## 4. Changing what is imitated

* **The verifier:** yes, Theorem Q5.
* **The checker or pointer:** only its generic heuristics transfer (§3.1).
* **The planner.** If the reference chain opens with a plan that names key ideas, query step 0 with probability ½. This is located probes with location "step 0", and it covers only insights the human has at the start.

**Proposition Q7 (granularity).** Let a step take Δ, and let T₀ = n₀Δ be the human's own project time. Measure the human's effort in time.
* (a) Chained imitation's PAC bound, n₀K/ε steps, is T₀K/ε. Theorem 3's bound is Ω(T₀K/(ε log(n/ε))). Neither depends on Δ, and refining can only raise K, since K(P_coarse) ≤ K(P_fine) + O(log n).
* (b) Slack imitation's i.i.d. bound is O((D_t + Δ)·K·log(K/δ)/(ρε)) in time, where D_t = DΔ is the setback measured in time. So finer steps help exactly when setbacks are short in absolute time, and do nothing for silent or fooled humans, whose D is infinite.
* (c) *The coarsest scheme,* n = 1: imitate whole projects and verify them. It fixes each of at most K rejections with one human project, about K·T₀ in all. That is VSP's worst case up to the factor 3.

So verification turns "K/ε human projects" into "K human projects" in the worst case. Slack and hints turn it into about K·(D+1)/ρ or K·s human *steps*.

*Proof.* Multiply the step counts by Δ, with n = T₀/Δ. P_coarse is P_fine iterated T₀/Δ times. ∎

* **Outcome-oriented decoding** (open). One could decode the posterior's belief about what the *final* notebook contains, writing content that the human will certainly add at some unknown time early. That repairs §2.3's silent case. But deliberate commissions break the bit per mistake of Lemma 1, since the posterior already knows the human would not write them now, and they need (B-commit) for premature correct content. Not worked out.

## 5. Redundancy and ensembles

**Proposition Q6.**
* (a) Any rule that chooses task queries from the posterior, from imitator runs, from posterior samples, or from runs under varied scaffolds is a task-only protocol, so Theorem 3 applies to it verbatim.
* (b) At a state whose top label has mass μ, k independent posterior samples disagree with it with probability 1 − μ^k, which lies between 1 − μ and k(1 − μ). At a confident step, μ ≥ 1 − α, that is at most kα. So committee disagreement is a randomized version of asking's threshold, at about α ≈ 1/k.
* (c) *Run level, on the hidden-insight class.* Let U_p be the unprobed steps of an unhit problem p. A posterior sample writes its insight, if it has one, at a step t̃ drawn from the posterior of t_p, which is uniform on U_p and independent of t_p given the transcript. So querying where the samples disagree hits with probability exactly 1/|U_p|, the same as a uniform probe of U_p.
* (d) *Varied scaffolds.* An omission caused by missing knowledge appears under every scaffold for which the posterior lacks the insight, so the runs agree on it. Errors that vary across framings are unconfident.

*Proof.* (a) As in Theorem 3, the only informative queries are probes, and the rule only decides where they go. (b) The probability that all k samples agree with the top label is μ^k, and 1 − μ^k ≤ k(1 − μ). (c) In Theorem 3's step 2, given the history, t_p is uniform on the unprobed steps. A sample's insight time has that law and is drawn independently of θ, so the hit probability is Σ_j π(j)·Pr[t_p = j] = 1/|U_p|. (d) The posterior given the data is the same whatever scaffold is run. ∎

*Why confident silent omissions are invisible to ensembles.* Ensembles measure how spread the posterior is. At a confident silent omission the posterior is concentrated on "no insight here", with mass at least 1 − 2η/n. Its remaining doubt is spread evenly over every unprobed step of the run, because the data say nothing about which step it is.

## 6. The human's own runs, positions and triggers

* **A full human run** on problem p costs n₀ task queries.
  * It finds the current imitator's first divergence on p with certainty, at its step (Lemma Q3).
  * It gives the learner's surprise profile, log₂ 1/ξ(P(x_k)|x_k), along the human's own run. Up to the first divergence the imitator's run is that run, so this is the right law for *first* mistakes.
  * It is also the vehicle for measuring n₀, setbacks (planted entries), verifier soundness and post-mortem accuracy.
  * Its cost is a constant overhead, a few runs, not O(K).
* **Feature-weighted search** (Scheme D inside Lemma Q2). Weight steps by features of their content (records an outcome, records a plan, routine computation), with weights estimated from earlier culprits and surprise profiles.
  * *Safety.* Mixed with uniform, any weights cost at most a factor 2.
  * *Gain.* If culprits concentrate on a feature class covering a fraction f of steps, single-mistake rejections cost about 2fn instead of n. With √π weights, Scheme D's (Σ√π)² is optimal among fixed weightings.
  * *No gain* when insight times are uniform.

**Proposition Q8 (when asking catches by-product insights; heuristic for product posteriors).**
* *Setup.* At a state x, let r(x) be the posterior probability that the human contributes something there, and let its content be diffuse enough that r(x)·p_max < 1 − r(x), where p_max is the largest conditional mass of a single content.
* (a) By thread C's Proposition 2, the top label is "routine continuation", with mass about 1 − r(x). Asking fires exactly when r(x) > α. So contributions at states with r > α are always asked, and only those at states with r ≤ α can be confident omissions.
* (b) *A shared trigger.* Suppose the human's contributions occur at a recognizable kind of state, "after the table of small cases is complete" for example, with rate r_T > α there. Once that is learned, every contribution at such a state is asked. The asks stay within Proposition 5(a)'s lifetime budget, (ln 2)K/α, which here pays for the problem-specific uncertainty at triggers: about one ask per trigger occurrence.
* (c) *The hidden-insight class.* There r(x) ≤ 2η/n at every unprobed state, so every insight is a confident omission (thread E, §1).

*Design.* Make insight-prone activities explicit stages whose outcome slot is certainly due and whose content is diffuse: "observations from these examples:", not an optional remark. The decoder's fill is then unconfident, and asking hands the slot to the human.
* *When it fails.* It fails when the slot's plurality fill is "nothing notable" with mass above 1 − α, that is, rare insights at frequent stages.
* *The irreducible case.* That remainder is where Theorem 3 lives, and only recovery, hindsight or n queries per insight reach it.

## 7. Other ideas

**Generate-and-test with the verifier (best-of-k).** For each problem, run the majority decoder under k harmless scaffold variations, or draw k per-run posterior samples. Verify each, and output the first accepted. If none is accepted, fall back to VSP's search.

**Proposition Q9.**
* (a) Under (A4) for every candidate, no failed run is output.
* (b) *Selection is bounded.* For any property Ψ of runs, Pr[the output has Ψ] ≤ Σ_i Pr[candidate i has Ψ]: at most log₂ k bits of selection. With per-run posterior samples, a malign hypothesis is drawn with its posterior mass, multiplied by k. The majority decoder lets it act only where it holds the majority.
* (c) *No worst-case gain.* On Theorem Q1's class this is guessing by verification.
* (d) It succeeds without task queries with probability 1 − (1 − p_s)^k, where p_s is the per-candidate probability of success.

*Proof.* (a) is (A4). (b) is a union bound over the candidates. (c) Each candidate's final value is a guess at k_p, tested by one verification. ∎

*Use.* A cheap pre-filter, preferably with majority-decoder runs under scaffold variations, which select without raising the exposure to malign hypotheses. It never hurts correctness under (A4), and it is the practical engine of current research agents. It goes beyond imitation: it outputs a human-like run that passes the verifier, not necessarily this human's.

**Recovery triggers for dead ends.** Add to the reference chain: "when three approaches in a row have failed, re-examine the recorded dead ends before trying new ones."
* *Validity.* The trigger is content, so the clock stays hidden and (T1) holds.
* *Effect.* It bounds V2's setback by the time to exhaust the alternatives plus one retry, and so turns V2 from ∞ into a finite setback that slack can absorb.
* *Cost.* The reference chain re-examines genuine dead ends, so n₀ grows a little.
* It complements the post-mortem stream.

## 8. Experiment EQ

* *Setup* ([`threadQ_hints.py`](threadQ_hints.py)). E6's class, humans, seeds and verifier, with slack σ = n/2 and each problem rerun until it succeeds (SI-V). Only the search on a rejected run changes. The streams, in round robin:
  * U: uniform with replacement, E6's own search;
  * S: a scan from step 0;
  * H: a structural hint, the steps at which the decoder wrote a value (its "verdict" entries), read off the run without the human, standing in for a post-mortem pointer at load-bearing claims;
  * A: an adversarial list of non-mistakes, which uses the truth on purpose.
* *Measurement.* 40 humans per cell. Entries are the mean total task queries for 100 problems, with queries per rejection in parentheses.

TABLE

**Reading.**
* *Reproduction.* U reproduces E6's SI-V column exactly (slack-imitation.md §6).
* *Fooled humans.* H finds the culprit at the first or second query, because every fooled failure here has a wrong value written at a verdict step. That is the best case for a post-mortem pointer; a real one will be weaker.
* *Silent humans.* There is nothing to point at, and H changes nothing. The scan stream cuts the cost by about 2.5×, because the single mistake sits at t_p < n₀ (Lemma Q3), while uniform search pays n = 2n₀.
* *Bounded-setback humans.* They pay up to 1.5× for the extra streams. With H the number of rejections also rises a little (10.5 → 13), because a hit at a verdict step can teach less than a hit later in the run.
* *The adversarial list* costs at most 1.6× U, within Lemma Q2's factor 2.
* *Compared with asking.* SI-V-ABC (α = 0.3) needs 236 → 318 → 360 for fooled humans and 223 → 285 → 319 for bounded-setback ones. USH needs about 40–60 and 15–30. With a verifier, hints beat asking in this class.

## 9. Ranking, recommendation, verdict

**What "works" means.** With a real careful researcher, it reaches output failure at most 5% on projects of n₀ ≈ 20–40 steps, with total human effort at most a fifth of chained imitation's. Effort counts every kind of question, in task-step equivalents. All figures are conditional on the series' shared idealizations: determinism, exact Bayes over a class that contains P, and a cold-start chain that succeeds within n₀. They are on the graded reading of every assumption.

| rank | candidate | correctness rests on | task queries (guarantee) | works: theory, software | works: empirical, judgment |
|---|---|---|---|---|---|
| 1 | VSP with a machine verifier of the actual goal | the checker matching the intent | ≤ 3n₀K; O(K) under (B_D) or good hints | 85% | – (rarely available) |
| 2 | **VSP with a human verifier, imitated (Theorems Q4, Q5)** | (A4) soundness | as row 1, plus K_V/ε verifications | **70%** | **30%** |
| 3 | SI-V with a human verifier and uniform search | (A4) | ≤ nK; (D+1)nK/(σ+1) under (B_D) | 65% | 25% |
| 4 | check-and-scan with a human verifier, no slack | (A4) | ≤ n₀K | 55% | 20% |
| 5 | SI-ABC (current recommendation) | (B_D) at confident steps | O((D+1)K log K/(ρε)) | 50% | 25% |
| 6 | SI | (B_D) at all mistakes | as row 5 | 40% | 15% |
| 7 | MB with an on-track check (excluded; for reference) | preservation | K | 30% | 15% |
| 8 | best-of-k with a verifier, alone (no learning) | (A4) under selection | 0 | 30% | 10% |
| 9 | the human as equivalence oracle, or "first entry you'd change" as a certificate | finding every difference | ≤ K counterexamples | 25% | 10% |
| 10 | located probes (thread B, Theorem 5(b)) | (Loc_s), foresight | 2sK/ε | 15% | 8% |
| 11 | feature- or position-weighted chained imitation | concentration | (Σ√π)²K/ε | 15% | 10% |
| 12 | endorsement-gated chained imitation, short reviews | lenient endorsement | nK/ε reviews | 15% | 10% |
| 13 | query-by-committee, redundant runs | nothing beyond asking | as chained imitation | 5% | 3% |
| – | finer granularity | an add-on (Proposition Q7) | – | – | – |
| – | chained imitation | nothing | n₀K/ε | baseline | baseline |

**Why the top rows are close.** At ε = 5%, chained imitation pays 20n₀K, while every verified scheme pays at most about n₀K task queries, so verification alone nearly meets the bar.
* Rows 2–4 differ mainly in how close they come to O(K). I give that, task queries O(K) with neither n₀ nor 1/ε, 45% for VSP, 35% for SI-V and 10% for check-and-scan in theory. SI-ABC cannot have it, because its i.i.d. bound carries 1/ε.
* Rows 2 and 5 differ in what correctness rests on: soundness of a check of a finished product (85% for theory), against bounded setback at confident commissions (55%).

**Recommendation.**
* *Where finished results can be verified by a person:* mathematics with written proofs, software against a specification, designs against explicit requirements. Use VSP:
  * slack imitation;
  * a final verification by the human, imitated per Theorem Q5 once its error rate is low;
  * on each rejection, a post-mortem list framed as a colleague's notebook, searched together with a scan and uniform steps;
  * asking only if post-mortems prove poor;
  * the dead-end trigger in the reference chain.
* *With a machine checker,* replace the human verifier with it.
* *Elsewhere,* use SI-ABC, and verify whatever parts of the result can be verified.
* *First measurements:*
  1. *Verifier soundness:* give researchers imitator-style wrong results in their own field and style, and measure false acceptances.
  2. *Post-mortem accuracy:* plant culprits (V1, V2, V5) in their own notebooks, tell them the project failed, and count how often the culprit is among their top s.
  3. *Setbacks:* slack-imitation.md §4's planted-entry tests.

**Verdict.**
* *Nothing replaces slack imitation as the source of location.* Location without a state judgment comes only from recovery, hindsight, structure or doubt. Theorem Q1 and Proposition Q6 rule out verification and ensembles as substitutes, and thread A's Theorem C rules out short reviews.
* *SI-ABC is dominated in sureness by an addition to it.* VSP's correctness rests on a check of finished products, not on bounded setback, and its guarantee is never worse than SI-ABC's.
* *The irreducible case remains* in every scheme: a silent, by-product insight, rare at its stage, that the human cannot point to even in hindsight. It costs n₀ queries per insight in VSP and is out of reach of everything else short of an on-track judgment.
* *Where results cannot be verified soundly,* I found nothing that dominates SI-ABC.
