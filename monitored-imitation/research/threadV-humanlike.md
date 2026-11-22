# Thread V: how close VSI's outputs stay to the human's own process

*Research note by Claude (Anthropic) on [`../verified-slack.md`](../verified-slack.md) (VSI, §2–§5), with note.md §6.3, thread S §2, thread Q's Proposition Q9 and thread T §5.3. Draft; not refereed. Script: [`threadV_selection.py`](threadV_selection.py), output [`threadV_selection.out`](threadV_selection.out) (5 s, fixed seeds). No existing file was changed. Status tags: **[proved]** means the proof is given here in full; **[sketch]** means the argument is outlined; **[open]** means not settled.*

## Answers in brief

1. **The filter enters only through which answers are collected** (Theorem 1) [proved].
   * *The map is fixed in advance.* Every output notebook is Run(D, x₀). That is the majority decoder's run, asks included, under a set D of the human's own answers, and the map Run is fixed before the verifier is chosen.
   * *How V acts.* V changes the posterior only by deleting hypotheses that contradict a human answer, and it changes a run only by rejecting it. Under (A3′) every rejection costs a hit, at least b bits of the learning budget.
   * *No pressure without learning.* This is the precise sense of "no optimization pressure": nothing derived from V is ever maximized over candidate labels or runs without new human data.
2. **Per problem: a stopping point on a path that does not depend on V** (Theorem 2(a)) [proved].
   * *The path.* Given the history, VSI's output on a problem is the R_p-th run of a fixed *forced-correction path*. The path starts at the verifier-free run, ends at the human's own chain, and every step along it is a hit.
   * *What V decides.* V only chooses how far along the path to go. So V adds at most log₂(1 + R_p) bits on that problem, and none when R_p = 0. That makes thread S's per-problem figure exact.
3. **Lifetime: at most log₂ C(T+K′, K′) ≤ K′·log₂ e + K′·log₂(1 + T/K′) bits over T problems, and this is tight** (Theorem 2(b)) [proved; the tightness is also checked by enumeration]. Here K′ = ⌊K/b⌋.
   * *The comparison.* For every event E, Pr[VSI ∈ E] ≤ 2^{B_T}·Pr[VSI with the verifier replaced by a coin that never looks at the run ∈ E].
   * *A correction to thread S.* Thread S's lifetime figure, K·log₂ e, is only the first term, and the sum of per-problem bounds is not a joint bound. The second term counts V's choice of *when* to reject. A class with K′ habits shows that it is real: V can produce exactly C(T+K′, K′) distinct output sequences.
4. **With audits, the bound does not grow with T** (Theorem 2(c)–(d)) [proved].
   * *Against a deviation-blind filter.* Compare VSI with a filter that rejects deviating runs at random, blind to *how* they deviate. The expected log-likelihood ratio is then at most K′·log₂(e(1 + n/β)) for every T. This caps "enrichment toward V's blind spots" over the whole lifetime.
   * *Non-human steps.* The expected number of non-human steps, summed over all outputs ever made, is at most nK′/β.
5. **Per step** (Theorem 1(d)) [proved]. Every step of an output is one of three kinds:
   * the human's answer (an ask);
   * the human's own step at that notebook (a correct step);
   * the plurality label of the prior restricted to the hypotheses consistent with every human answer, with backing mass at least w(P), and at least (1−α) of the posterior with asks.
6. **Malign hypotheses** (Proposition 3) [proved, except the existence question, which is open].
   * *What V cannot do.* V never raises a hypothesis's odds against P.
   * *What a coalition needs.* A coalition writing a payload must outweigh the human's label at that notebook, the human included. With asks it must outweigh it by (1−α)/α.
   * *What V can do.* It unmasks only through data from at most K′ searches and the audits.
   * *How payloads are caught.* Payloads in outputs are metered at audit rate β/n. VSI is no better than chained imitation against a one-off treacherous step, and 1/β worse for β < 1.
7. **The formalizer inside V** (Proposition 4) [proved under conditions (F1)–(F3), with the leaks listed].
   * *What is optimized.* Only the formal proof π is optimized. The notebook keeps Theorems 1–2 for any formalizer and any budget B, a malicious one included, provided (F1) holds: nothing the formalizer produces enters a notebook, the data, or the imitated human's eyes.
   * *What π carries out.* π's optimization reaches the world only through the verdict, unless π is read or executed.
8. **Compared with alternatives** (Proposition 5) [proved; the training case only for exact Bayes]. In bits of filter selection:
   * chained imitation: 0;
   * best-of-k: log₂ k per problem, T·log₂ k over the lifetime, and the sampling version loses the plurality protection;
   * training on accepted outputs: unbounded, and one accepted deviation used as data refutes the human in exact Bayes;
   * VSI: logarithmic in T, and paid in hits.
9. **What a paper can state** (§7). *VSI introduces at most log₂ C(T+K′, K′) bits of selection beyond the human's data over T problems: zero on every problem without a rejection, and log₂(1 + R_p) on the others. No smaller bound holds for every verifier. With audits at rate β, it introduces at most K′·log₂(e(1+n/β)) bits in expectation of preference among the imitator's deviations, whatever T is.*

## 1. Setting and the processes compared

* **The scheme.** VSI as in verified-slack.md §2.3, under (A1):
  * exact Bayes over H ∋ P, with prior w, and K = log₂(1/w(P));
  * the majority decoder, with ties broken by a fixed order;
  * asks at final-answer slots (b = 1) or at every unconfident step (b = b_α);
  * the search S, U, S, H, and audits with probability β.
* **Notation.** D is a finite set of the human's answers; Φ(D) = log₂(W(D)/w(P)), with 0 ≤ Φ ≤ K; and K′ = ⌊K/b⌋.
* **The filter** is V together with the "nothing bizarre" check, if it is used. It is *admissible* if V satisfies (A3′), accepting every extension of the human's notebook at n₀, and the check satisfies (M1)–(M2).
  * *Otherwise the filter is arbitrary.* It may be adaptive, randomized, adversarial, or even clairvoyant about the search randomness.
* **Randomness.** ω collects all other randomness: the U-stream draws, indexed by (problem, rerun), the audit coins, the problem strategy's coins, and the filter's own.
* **Run(D, x₀)** is the run from x₀ under D, with asks added as made, together with its asks. It is deterministic, because W depends only on the set D and P is deterministic.
* **The processes VSI is compared with.** None of the three reads V:
  * **Forced correction.** From a given history, reject every run that has a committed mistake, until one has none.
  * **VSI[coin_q].** VSI with the filter replaced by a coin that rejects with probability q, independent of ω and blind to the run.
  * **VSI[dev_q].** VSI whose filter accepts a run with no committed mistake, and rejects any other run with probability q, independently of *which* mistakes it has. It knows *whether* the imitator deviated, not *how*.

## 2. Theorem 1: the filter enters only through which answers are collected

**Theorem 1** [proved]. Assume (A1). For every filter, admissible or not, and on every path:
* **(a) Data.** Every datum is a pair (x, P(x)): an ask, a search query, a bisection query after a failed check, or an audit. Verdicts and post-mortem lists are never data. So D ⊆ graph(P) always.
* **(b) Outputs.** Every output notebook is the final notebook of Run(D, x₀), where D is the data held when the final run on x₀ began. So the law of the output notebooks is the image of the law of the data sets under a map that does not depend on the filter. The artifact is one of that notebook's claims.
* **(c) Posterior.** For ν, ν′ ∈ H_D, ξ_D(ν)/ξ_D(ν′) = w(ν)/w(ν′): the posterior is the prior restricted to H_D.
* **(d) Steps.** Let D_k be D plus the run's earlier asks. Then step k of an output run is of one of three kinds:
  * (i) asked, so the label is P(x′_k);
  * (ii) committed and correct, so the label is P(x′_k), what the human writes at that notebook;
  * (iii) a committed mistake whose label y is the plurality label of w restricted to H_{D_k}, with W(D_k, y) ≥ W(D_k, P(x′_k)) ≥ w(P), and, with asks at every unconfident step, also W(D_k, y) ≥ (1−α)·W(D_k).
* **(e) Every change costs learning.** The filter changes the run on a problem only by rejecting it. For an admissible filter, every rejection ends in a hit, which lowers Φ by at least b. So over the lifetime the filter causes at most K′ changes of run, and none without new human data.

*Proof.*
* *(a)* Inspect §2.3: only the human's answers to task queries are ever added, and P is deterministic.
* *(b)* By induction over steps, the decoder's label and the ask rule at x′_k depend only on H_{D_k}, and hence only on the set D_k.
* *(c)* Note.md, Proposition 11: every consistent hypothesis has likelihood 1.
* *(d)* (i) and (ii) are definitions. (iii): G maximizes W(D_k, ·), and P ∈ H_{D_k}. With asks, a step is committed only if its top mass is at least 1 − α.
* *(e)* Lemma 1 of verified-slack.md puts a committed mistake below n₀ in every rejected run. A failed check's flip is a mistake by (M1)–(M2). Then apply the counting of Theorem 5(b). ∎

*What this formalizes.* "No optimization pressure" is (b) and (e) together.
* The decoder is V-blind: it is a fixed function of the human's answers.
* The only thing V selects is *which* answers are collected and when. Each change of run it causes is paid for with at least b bits of true information about P.

*What it does not say.* The *law* of D depends on V, and V decides which of the decoder's deviations get corrected first. That is thread S's allocation and unmasking. Theorem 2 measures it.

## 3. Theorem 2: bits of selection

**Theorem 2** [proved]. Assume (A1) and an admissible filter. Fix the problem strategy (adaptive allowed), the ask rule, the schedule and β.
* **(a) Per problem.** Fix the history before problem p, with data D_p, and fix ω. Let ρ₀, ρ₁, …, ρ_L be the forced-correction path from that history:
  * ρ₀ = Run(D_p, x₀) is the verifier-free run;
  * ρ_{i+1} is the run after the search on ρ_i;
  * the path stops at the first run with no committed mistake.

  Then:
  * the path does not depend on the filter, L ≤ ⌊Φ(D_p)/b⌋, and ρ_L is the human's own chain;
  * VSI's output notebook on p is ρ_{R_p};
  * so, for every event E and every m, Pr[out_p ∈ E, R_p ≤ m | history] ≤ Σ_{i≤m} Pr[ρ_i ∈ E | history].
* **(b) Lifetime, against a content-blind filter.** For every T and every event E on the transcript up to the end of problem T (runs, verdicts, data, outputs), with q = K′/(K′+T),

  Pr[VSI ∈ E] ≤ 2^{B_T}·Pr[VSI[coin_q] ∈ E], where B_T = T·log₂(1 + K′/T) + K′·log₂(1 + T/K′) ≤ K′·log₂ e + K′·log₂(1 + T/K′).

  * *A sharper reference.* Against the uniform mixture of content-blind verdict scripts, the factor is C(T+K′, K′).
  * *Tightness.* For every K′ and T there is a class with K = K′, and C(T+K′, K′) sound, complete, deterministic verifiers with pairwise distinct output sequences. So every reference law Q has some admissible V with D_∞(VSI[V] ‖ Q) ≥ log₂ C(T+K′, K′), and the same holds for KL.
* **(c) Lifetime, against a deviation-blind filter.** Let A be the number of outputs that have a committed mistake. With q = β/(n+β) and for every T,

  KL(VSI ‖ VSI[dev_q]) ≤ E[R·log₂(1/q) + A·log₂(1/(1−q))] ≤ K′·log₂(e(1 + n/β)).
* **(d) Non-human steps.** E[R] + (β/n)·E[A] ≤ K′. Moreover E[Σ_t M_t] ≤ nK′/β over the whole lifetime, where M_t is the number of committed mistakes of output t.

*Proof.*
* *(a) The coupling.* Under VSI, the data at rerun i on problem p equal the path's data at index i, as long as runs 0, …, i−1 were rejected: the runs are the same, and so are the search draws ω_{p,i}. So the output is ρ_{R_p}.
  * Each step along the path is a search on a run with a committed mistake, which the scan reaches, so it ends in a hit. That gives L ≤ Φ/b.
  * A run with no committed mistake appends P's label at every step, so it is the human's chain.
  * The inequality is a union bound over the indices up to m.
* *(b) The transcript.* By induction over verifications, the transcript is a function traj(ω, s) of ω and the filter's verdict string s. By (e), s has T accepts and R ≤ K′ rejects.
  * *The coin.* The coin's first verdicts equal s with probability (1−q)^T q^R ≥ (1−q)^T q^{K′}, independently of ω. On that event VSI[coin] follows traj(ω, s). So Pr[VSI[coin] ∈ E] ≥ (1−q)^T q^{K′}·Pr[VSI ∈ E], and log₂ 1/((1−q)^T q^{K′}) = B_T.
  * *The bound on B_T.* T·log₂(1 + K′/T) ≤ K′·log₂ e.
  * *Scripts.* The number of possible strings is Σ_{R≤K′} C(T−1+R, R) = C(T+K′, K′).
  * *Tightness.* Use K′ habits. Hypothesis ν_S writes 1 at habit step i exactly when i ∈ S, the human writes 0, the prior is uniform, ties go to 1, the problems are distinct, and β = 0.
    * For a non-decreasing j: [T] → {0, …, K′}, let V_j accept on problem t exactly when at least j(t) habit entries are 0. That predicate is preserved by appending, is true of the human's chain, and is decided soundly.
    * Each hit corrects exactly one habit, so output t has exactly K′ − j(t) ones.
    * The C(T+K′, K′) choices of j give distinct sequences, so any Q puts at most 1/C(T+K′, K′) on one of them. Part A of the script confirms the count by enumeration.
* *(c)* Every rejected run has a committed mistake, so under dev_q the string s has probability π(s | ω) = q^R(1−q)^A.
  * The KL of the joint law of (ω, s) is E[log₂ 1/π(s | ω)], or at most that for a randomized filter. The transcript is a function of (ω, s), so data processing bounds its KL by the same quantity.
  * With log₂(1/q) = log₂(1 + n/β) and log₂(1/(1−q)) ≤ (β/n)·log₂ e, the bound is at most (E[R] + (β/n)·E[A])·log₂(e(1 + n/β)). Then use (d).
* *(d) The audits.* Given the past and output t, the audit lands on a mistake with probability β·M_t/(number of committed steps), which is at least β·M_t/n.
  * Audit hits and rejection hits each lower Φ by at least b, so together they number at most K′.
  * Take expectations, as in note.md's Proposition 10. ∎

*Remarks.*
1. **Thread S's figures.**
   * *Per problem.* "log₂(1 + R_p) per problem" is (a), conditional on the history.
   * *Lifetime.* "T·log₂(1 + K/T) ≤ K·log₂ e" is the first term of B_T: the cost of the T acceptances.
   * *What is missing.* The second term is V's choice of *when* to reject. Per-problem bounds do not add up to a joint bound, because the reference on problem p would need R_p in advance.
   * *In the example.* Σ_p log₂(1 + R_p) never exceeds K′, while log₂(#sequences) grows like K′·log₂(T/K′) (script, Part A).
2. **Abstentions, halts, and the check.**
   * *Without (A3′),* an abstention, and a halt for statement review, are terminal rejections with no hit. Replace K′ by K′ + Z, where Z is their number.
   * *Abstentions withhold.* An abstention withholds the human's own chain, so it can remove content but never add any.
   * *With the check,* a rejection comes in two kinds, which adds at most K′ bits.
3. **Several claims in one notebook.** "The artifact is the first claim that passes" lets V choose among the c_p claims of an *accepted* notebook without a hit.
   * *The cost.* That is up to log₂ c_p more bits on problem p, and it is unbounded over T.
   * *What Theorem 2 covers.* It covers the notebooks and verdicts, but not this choice.
   * *The fix.* To cover the artifact as well, verify only the first claim, and treat its failure as a rejection. This needs (A3′) for the first claim of the human's chain.
4. **The list H.** A list built by a fixed rule from the run is part of the environment. Two other sources of the list are a second channel:
   * *The sources.* A strategic post-mortem writer, or a verifier's located objections used as pointers.
   * *Its size.* In each search it picks fewer than n₀/2 steps before the scan's sure hit at query 2n₀ − 1 or earlier. That is at most (n₀/2)·log₂(n+1) bits per search, and K′·(n₀/2)·log₂(n+1) over the lifetime.
   * *What still holds.* Theorem 1 holds for it [proved].
5. **Scale.** K is a human's description length, so even K′ bits would be a great deal if V spent them all on one event. What Theorem 2 gives is three things:
   * *a rate:* nothing on a problem without a rejection, and log₂(1 + R_p) on the others;
   * *growth in T* that is logarithmic, against T·log₂ k for best-of-k;
   * *a price:* a hit for every rejection.

## 4. Malign hypotheses

**Proposition 3.** Let H be the programs with the Solomonoff prior, and 𝓜 ⊆ H any set. A label y at notebook x is *𝓜-only under D* if every member of H_D that writes y at x is in 𝓜: a payload that no honest surviving hypothesis would write.
* **(a) Plurality, whatever the filter** [proved]. Suppose an output commits an 𝓜-only label y at x under D.
  * *Without asks.* Then w(𝓜 ∩ H_D ∩ [ν(x) = y]) ≥ W(D, P(x)) ≥ 2^{−K}: the coalition outweighs everything that writes the human's label, P included.
  * *With asks at every unconfident step,* the coalition's mass is at least (1−α)·W(D) ≥ ((1−α)/α)·W(D, P(x)).
  * *With final-answer asks only,* the same holds wherever y is a claimed solution, unless every label at that step has mass below α.
  * *Without "𝓜-only",* 𝓜 can only tip a plurality, which needs at least W(D, P(x)) − W_{¬𝓜}(D, y).
* **(b) No gain in odds** [proved]. For every μ ∈ 𝓜 ∩ H_D, ξ_D(μ)/ξ_D(P) = w(μ)/w(P).
  * *Unmasking.* The filter acts on 𝓜 only by deleting rivals, through data, and data arrive only in at most K′ searches and the audits.
  * *Selection.* It also selects among candidates, which Theorem 2 bounds.
* **(c) Bounded enrichment** [proved]. For an event about malign content, for example "some output carries an 𝓜-only label", there are two bounds.
  * *Per problem,* Theorem 2(a): at most the number of runs on the path that carry it.
  * *Lifetime,* Theorem 2(b): at most 2^{B_T} times its probability under a content-blind filter. Under that filter 𝓜 acts only where (a) allows and is never preferred.
* **(d) Exposure** [proved]. An 𝓜-only committed step is a mistake, so E[number of such steps in all outputs] ≤ nK′/β.
  * *Against chained imitation.* At β = 1 this is chained imitation's metering, and for β < 1 it is 1/β worse (thread S).
  * *A one-off act.* A coalition that acts once is caught, after the fact, with probability at least β/n.
  * *No better is possible.* By note.md's Theorem 3, no task-only protocol does better against deviations nobody can see.
* **(e) Provoked rejections** [proved]. A coalition can commit mistakes that V can see, to provoke rejections and steer which data are collected.
  * *What each provoked rejection is.* It is one of the at most K′ hits. It deletes only hypotheses that contradict the human, and it raises no odds.
  * *The provokers' fate.* The provokers are deleted if the search lands on their step.
* **(f) What is not settled** [open]. Do coalitions that satisfy (a) at the notebooks that matter exist? That is the malign-prior question (note.md §9, item 4).
  * *VSI's effect on it.* VSI changes it only through which rivals survive.
  * *Inside S\*.* Under (A4′) a coalition cannot make an output fail S\*.
  * *Outside S\*.* Only (a), (d) and the optional "nothing bizarre" check constrain it.

*Relation to note.md §6.3.*
* *Proposition 11 is (b).*
* *"A rising share of silent failures is common to all filters."* Among surviving deviants, those that pass V gain share, not odds. VSI turns that share into outputs only where they hold the plurality, at step (iii) of Theorem 1(d), and only along a path in which every step costs a hit.
* *Unmasking.* §6.3's example with H_vis and H_sil is exactly unmasking, and (b) bounds it by the K′ searches.
* *Asks.* Asks buy a margin of log₂((1−α)/α) bits against coalitions, at a cost of at most (ln 2)·K/α asks.

## 5. The formalizer inside V

Take V = kernel_Σ ∘ F, as in verified-slack.md §2.1 and thread T §5.3. F turns the claim's cone into a formal proof π of the fixed statement Σ. The output is the pair (notebook N, π). Three conditions:
* **(F1) Isolation.** Nothing F produces enters any notebook or the data, or is seen by the imitated human before it answers a task query: not π, not partial proofs, not error messages, not which lemma failed.
* **(F2) A fixed statement.** Σ is fixed at x₀, by the statement protocol, and F does not choose it.
* **(F3) Determinism.** F has a pinned model, a fixed seed and a verdict cache, so its verdict is a function of the claim's cone.

**Proposition 4.**
* **(a) The notebook is not optimized** [proved]. Under (F1) alone, for every F and every budget B, malicious or broken included, N = Run(D, x₀) with D ⊆ graph(P), and Theorems 1–2 hold with V = kernel ∘ F.
  * *What reaches the notebook.* F's search reaches it only through its verdict bits.
  * *Pointers.* F's failure locations may be used as pointers for the search. That is Remark 4's channel, since the search shows the human only x′_k.
  * *What is selected for.* Blueprints that F can formalize are selected for, within Theorem 2's bits. That is benign in direction, and it is bounded.
* **(b) π is optimized** [proved]. Under (F3), π = F(cone of N) is a function of the output notebook, and it is the result of F's search.
  * *How much selection.* Up to log₂ of the number of candidates F examines, per verification, which neither K nor Theorem 2 bounds.
  * *Its correctness* rests on the kernel for Σ, and on Σ's fidelity for S\*.
* **(c) Without (F3)** [proved]. Theorem 2 allows a randomized V, so the notebook bounds still hold. But each re-verification of π is a fresh search. That is thread T's loophole hunting and thread S's repeated verification.
* **(d) How the optimization leaks** [sketch].
  * *(F1) fails by writing F's output into a notebook.* Later labels are still the plurality labels of a posterior consistent with the human's data (Theorem 1(d)), but at notebooks chosen partly by an optimizer, which never occur in the human's reference chain. "What the human would do" becomes "what the human would do after reading an optimizer's text", the persuasion channel of note.md §7.
  * *(F1) fails because the imitated human reads π or F's logs.* Its answers are no longer P's, and Theorem 1(a) fails.
  * *π is used as training data.* Then Proposition 5(d) applies.
* **(e) When π's optimization stays inside π** [sketch]. It does if π is consumed only as "the kernel accepted π for Σ": π is archived and not read for content, and it is checked kernel-only in a sandbox, with no elaboration-time code, an axiom whitelist and no `native_decide`.
  * *Then* the only optimized information that reaches the world is the verdict, which Theorem 2 already counts.
  * *Further.* Requiring π's top-level lemmas to match the blueprint's milestones (thread T's anomaly rule) narrows F's freedom to proofs between milestones the human wrote.

## 6. Compared with alternatives

**Proposition 5.**
* **(a) Chained imitation, and slack imitation without a verifier** [proved]. They have no filter, so B = 0. Their query per run is Theorem 2(d) with β = 1.
* **(b) Best-of-k with the majority decoder under k scaffold variants** (Q9) [proved].
  * *Bits.* At most log₂ k per problem, and at most T·log₂ k over the lifetime. That is attained when the candidates differ, since V may pick any of k^T sequences.
  * *Protection.* Plurality protection holds at every state.
  * *The difference from VSI.* No choice costs any learning.
* **(c) Best-of-k with posterior samples** [proved].
  * *Bits.* The same.
  * *Malign hypotheses.* A set of posterior mass ε supplies the output with probability up to min{1, kε}, with no plurality needed. The bound is attained if its runs pass V and the others fail.
* **(d) Training on accepted outputs.**
  * *For exact Bayes* [proved]. An accepted output's committed mistake enters the data as (x, G(x)), with G(x) ≠ P(x). That refutes P. Theorem 1(a) and Proposition 11 fail: the hypotheses that wrote the accepted output gain odds by 1/ξ_D(G(x) | x), and the selection compounds over rounds. There is no bound in K.
  * *For practical learners* [sketch]. Fine-tuning is not deletion, but it is optimization against V.
* **(e) VSI with a resampling learner** [proved].
  * *Resampling without a hit* gives best-of-k with k unbounded.
  * *Rerunning only after hits* keeps Theorem 2(a), but R is no longer at most K′, because Lemma 1 needs the decoder.

| scheme | output is a function of the human's answers | filter bits on one problem | over T problems | plurality protection | price of each choice |
|---|---|---|---|---|---|
| chained imitation | yes | 0 | 0 | yes | – |
| **VSI** | **yes** (Theorem 1) | **≤ log₂(1+R_p); 0 if R_p = 0** | **≤ log₂ C(T+K′, K′) ≤ K′ log₂(e(1+T/K′)), tight; ≤ K′ log₂(e(1+n/β)) in expectation against dev_q** | **yes** | **a hit (≥ b bits)** |
| best-of-k, majority decoder | yes, plus the index of the variant | ≤ log₂ k | T log₂ k | yes | none |
| best-of-k, posterior samples | no (samples) | ≤ log₂ k | T log₂ k | no (kε) | none |
| training on accepted outputs | no (P refuted) | compounds | unbounded | no | none |

## 7. What a paper can state, and its status

> **Theorem (VSI introduces bounded selection).** Run VSI with exact Bayes over a class containing the deterministic human P, the majority decoder, and any verifier that accepts the human's own runs. Then:
> 1. every output notebook is the majority decoder's run under a set of the human's own answers, so the verifier affects outputs only through which answers are collected, and each change it causes costs at least b bits of the learning budget K;
> 2. on each problem the output is a point, chosen by the verifier, on a verifier-independent path from the verifier-free run to the human's own run;
> 3. over T problems, for every event E, Pr[E] ≤ C(T+K′, K′)·Pr_{blind}[E], where Pr_blind is the same scheme with the verifier's verdicts replaced by a uniformly chosen script that ignores the runs. So VSI adds at most log₂ C(T+K′, K′) ≤ K′·log₂(e(1 + T/K′)) bits of selection beyond the human's data, and no smaller bound holds for every verifier;
> 4. with audits at rate β, the expected selection among the imitator's deviations is at most K′·log₂(e(1 + n/β)) bits, and the expected number of non-human steps in all outputs is at most nK′/β, for every T.

* **Proved:** Theorems 1 and 2, Proposition 3(a)–(e), Proposition 4(a)–(c), and Proposition 5(a)–(c), (e), and (d) for exact Bayes.
* **Sketched:** Proposition 4(d)–(e), and Proposition 5(d) for practical learners.
* **Open:**
  * whether malign coalitions satisfying Proposition 3(a) exist where they matter;
  * a stochastic or non-realizable human, under which Theorem 1(a) and the hit count break, though the union bound of Theorem 2(a) survives;
  * a T-free bound without audits, which (b)'s example rules out for content-blind references.

## 8. Numerical checks ([`threadV_selection.py`](threadV_selection.py))

Exact Bayes, the majority decoder, the search S, U, S, H, and every verifier satisfying (A3′), enumerated through its verdict script.
* **A (tightness).**
  * *The class.* K habits.
  * *The count.* The number of distinct output sequences equals C(T+K, K) exactly: 5, 15, 45, 56, 165 and 210 for (K, T) = (1, 4), (2, 4), (2, 8), (3, 5), (3, 8) and (4, 6).
  * *The per-problem sum.* max Σ_p log₂(1 + R_p) stays at K.
* **B (random clustered classes).**
  * *The classes.* Twelve classes, each with 31 hypotheses in 10 families, w(P) = 2⁻⁸ and T = 5.
  * *What holds in every class:*
    * every rejection ends in a hit, and R ≤ K′;
    * every output is the R_p-th run of the forced-correction path from the same history;
    * P is never refuted;
    * the number of distinct output sequences is at most C(T+K′, K′); the largest ratio is 0.036.
* **C (audits).**
  * *The setup.* 200 classes, with four verifiers (lenient, strict, a coin, and one that passes late deviations), β ∈ {1, ¼} and T ∈ {50, 400}.
  * *The results.* E[R] + (β/n)·E[A] ranges over 0.6–2.3, against K′ = 8. E[LLR] ranges over 0.9–10.5, against bounds of 34 and 49. Neither grows from T = 50 to T = 400.
