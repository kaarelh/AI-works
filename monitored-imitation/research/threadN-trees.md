# Thread N: slack imitation for decomposition trees

*Working note by Claude (Anthropic), for [`../slack-imitation.md`](../slack-imitation.md) (version 2), §9 item 4. Draft; not refereed.*
* *Code:* [`threadN_trees.py`](threadN_trees.py); *output:* [`threadN_trees.out`](threadN_trees.out).
* *Status tags:* **[P]** proved here, **[S]** sketched, **[C]** conjectured, **[N]** checked numerically. The checks verify bookkeeping only; they cannot test any assumption about humans.

## Answers in brief

1. **Model** (§1). A *call* is the human given a question. It runs a fixed number of *rounds* on its own append-only transcript. In each round it writes entries and poses subquestions to fresh, isolated calls, whose answers are appended. A *mistake* is a round whose label (entries and subquestions) differs from the human's at that transcript. A wrong subanswer is not a mistake of the parent. A run is the whole tree for one root question, and it succeeds if the root's answer is good. A task query is one round of one call.
2. **Slack is extra rounds per call, and bounded setback is measured in the parent's rounds** (§2).
   * **(B-sub):** a wrong subanswer costs the parent at most D rounds besides its own round, and an empty one costs only the round.
   * **Lemma T1** [P]: a failed call has at least c = ⌈(s+1)/(D+1)⌉ bad rounds. This is Lemma S, call by call.
   * **Lemma T2** [P, N]: a failed root carries *weighted* mistake mass at least 1, where a round at depth i weighs c^−(i+1).
   * **Theorem T3** [P]: query one round with probability proportional to that weight. Then E[#failed runs] ≤ Φ·K, with Φ = Σ_rounds c^−(depth+1).
   * *Size of Φ.* For a balanced tree with b subquestions per round and depth d, Φ < 2·((D+1)/ρ)^(d+1)·b^d. This is independent of the rounds per call, just as the chain's charge (D+1)/ρ is independent of n. Each level of depth costs a factor b(D+1)/ρ.
3. **A uniformly random round or call is the wrong query** [P]. It guarantees only N_r/c, where N_r is the number of rounds in the tree, because c mistakes may sit in the root alone.
   * *Depth weighting* is the optimum among query laws that see only the tree's shape [P, N on balanced trees].
   * *A uniformly random depth, then a uniform round there,* is within a factor d+1 of Φ and needs no parameters [P].
4. **Where trees differ from chains** (§3).
   * *The b^d is unavoidable* [P]: on a class with D = 0 and unlimited slack, every task-only protocol needs Ω(b^d·K/(ε log(b^d/ε))) task queries. Slack multiplies mistakes along time, not across siblings: when one of b subanswers is wrong, nothing in the run says which.
   * *Fooled parents* (wrong subanswers pass upward unnoticed) [P]: the charge becomes N_r/c ≈ N·(D+1)/ρ, linear in the number of calls N. The whole depth discount comes from parents that absorb wrong subanswers.
   * *Silent humans* [P]: Ω(N_r⁰·K/(ε log(N_r⁰/ε))), where N_r⁰ is the number of rounds in the human's own tree. Chained imitation of that tree attains it, and per-call slack then costs (1−ρ)^−(d+1), against (1−ρ)^−1 in a chain.
   * *Isolation* helps the assumption and the bound, and hurts recovery (§3.3).
   * *Running the tree depth-first in one notebook* does transfer the chain theorems, but with setback counted in global steps, so a redone subanswer counts as a whole subtree. The charge is then about N_r/c, and the depth discount is lost [S].
5. **Asking and verifiers** (§4).
   * *Proposition 5 carries over* [P]: at most 0.69K/α asks, and Φ·K/log₂(1/α) failed runs.
     * But asking does not remove (B-sub): a confident wrong answer made deep down still reaches its parent.
     * It does remove guessed answers. A call's answer is the certainly-due slot par excellence.
   * *Proposition 4 carries over with a root verifier* [P]: Φ·K search queries.
   * *With a verifier at every node* [P]: at most K rejections, each found with at most 1 + min{r, (D+1)r/(s+1)} task queries, with no (B-sub) and no dependence on N. This is the strongest result here.
   * *Rejections* [S, N]: suppose the parent's next round names exactly the subanswers it rejects (**(B-notice)**). Then a walk that follows these rejections has charge at most 5·2^d·(D+1)/ρ, with no b^d. The b^d is the price of a parent whose reaction does not say *which* subanswer failed.
6. **Believability** (§5).
   * *(B-sub) is more natural than the chain's (B-commit) in one respect.* A subanswer really is a delegate's report, in the human's own tree too, so skepticism toward it does not break the design law.
   * *It is less natural in another.* The parent sees only the answer, not the work, and re-asking a deterministic imitator returns the same answer.
   * *Like a manager,* the parent catches wrong reports that conflict with something, or that make the plan built on them fail. It is fooled by plausible reports on matters it cannot check, and a Bayes imitator's wrong answer is its *most typical-looking* report.
   * *My guesses* that (B-sub) holds with D ≤ 2 (graded reading): 55% for mathematics with proofs required, 60% for software with tests, 25% for factual or empirical answers, 10% for judgments and negative results.

## 1. Model

* **Calls.** A question q carries a visible fuel h ∈ {0, …, d}. A call with fuel h may pose questions of fuel h−1, and none if h = 0. The call's transcript starts as y₀ = (q).
* **Rounds.** In round j the label is g = (e, Q′): entries e and a list Q′ of subquestions.
  * The scaffold runs a fresh call on each q′ ∈ Q′. The call sees only q′ (isolation).
  * Then y_j = y_{j−1} ∪ e ∪ Q′ ∪ A, where A is the list of their answers.
  * A call runs exactly r_h rounds, with a hidden clock within the call. It then returns ans(y_{r_h}), read out by a fixed scaffold rule. Under a hidden clock, an unfinished call therefore returns the empty answer ⊥.
* **Learning.** The human is one deterministic P, the same at every call, with P(y) a label. Data are pairs (y, P(y)), so slack-imitation §1 applies unchanged: the potential Φ(D), Lemma 1 of note.md, and Theorem 1 of without-a-check.md. A *task query* at round (u, j) shows the human call u's transcript y_{j−1} and records P(y_{j−1}): one round of one isolated call.
* **Runs.** The imitator's run on a root question is the whole tree, with the majority decoder G in place of P at every round. A *mistake* is a round ρ = (u, j) with G(y) ≠ P(y).
* **Success.** Each question q has a set Good(q) of answers. S_q(y) means ans(y) ∈ Good(q), and S_q is assumed preserved by appending. A call *fails* if its answer is not good; the run fails iff the root does.
* **Remaining rounds.** τ_q(y) is the *maximum*, over every way of supplying good answers to the human's future subquestions, of the number of the human's rounds from y until S_q (∞ if unbounded). It follows that:
  * **(T1′)** if τ(y) ≥ 1 and the round is *correct* (its label is P(y) and every subanswer is good), then τ(y′) ≤ τ(y) − 1, since this continuation is among those maximized over;
  * **(T2′)** if τ(y) = 0 then τ(y′) = 0.
* **Bad rounds.** A round is *bad* if its label is a mistake or some subanswer is not good.

**Assumptions.**
* **(Budget)** τ_q((q)) ≤ r₀(h) for the root, and for every question posed in a round whose label is the human's (a correct round, or an ask).
  * This is the analogue of τ(x₀) ≤ n₀.
  * It is quantified over what the human asks on the imitator's transcripts, so it is learner-relative, like (B_D).
* **(B^T_D) bounded setback** at every bad round. τ(y′) ≤ τ(y) + D, and τ(y′) ≤ τ(y) if the deviation is only an omission: the label is part of the human's, and every non-good subanswer is ⊥. It has two parts:
  * *within the call,* for label mistakes, which is (B_D) of the chain;
  * **(B-sub) at the parent,** for wrong subanswers.
* **Slack.** r_h = r₀(h) + s_h, ρ_h = s_h/r_h, and c_h = max{1, ⌈(s_h+1)/(D+1)⌉}. Below, c is uniform unless indexed.

## 2. Slack for trees

**Lemma T1 (per call)** [P]. If call u satisfies (Budget) and (B^T_D) holds at its bad rounds, then a failed u has at least c_u bad rounds.

*Proof.* Lemma S verbatim, with rounds for steps. τ falls by at least 1 at each correct round (T1′) and rises by at most D at each bad one, and success is preserved (T2′). So 1 ≤ r₀ − (r − #bad) + D·#bad. ∎

**Lemma T2 (failure certificates)** [P, N]. Let ω(u, j) = Π 1/c_w over the calls w on the path from the root to u, both ends included. If the root fails, then Σ_{ρ∈M} ω(ρ) ≥ 1.

*Proof.* Claim: for every failed call u that satisfies (Budget), Σ_{ρ∈M∩sub(u)} ω_u(ρ) ≥ 1, where ω_u is the same product starting at u. Induction on height.
* By Lemma T1, u has at least c_u bad rounds.
* *A bad round whose label is a mistake* contributes its own weight, 1/c_u.
* *Otherwise its label is the human's.* Then its subquestions satisfy (Budget), and some child k fails. By induction the child's subtree has Σ ω_k ≥ 1, and there ω_u = ω_k/c_u.
* Distinct bad rounds use disjoint rounds and subtrees, so the total is at least c_u·(1/c_u) = 1. ∎

Part 1 of the code checks this on 8,000 random trees, including children of mislabelled rounds with arbitrary τ (possibly ∞). The minimum mass found is exactly 1.

**Protocol TSI.** For each root question:
1. run the imitator's tree;
2. task-query one round ρ, drawn with probability ω(ρ)/Φ_t, where Φ_t = Σ_ρ ω(ρ) over this run's rounds;
3. add the answer to the data.

**Theorem T3 (online)** [P]. Assume (Budget) and (B^T_D) on every run, bizarre entries included. Then for every sequence of root questions, possibly adaptive,

  E Σ_t 1[run t fails]/Φ_t ≤ ⌊K⌋, so E[#failed runs] ≤ Φ_max·⌊K⌋.

*Proof.* q_t is chosen after the run is fixed, and by Lemma T2, q_t(M_t) ≥ 1[run t fails]/Φ_t. Apply Theorem 1 of without-a-check.md. ∎

**The size of Φ.** Φ = Σ_i R_i/Π_{j≤i} c_j, where R_i is the number of rounds at depth i.
* *Balanced tree* (r rounds per call, b subquestions per round, depth d; N ≈ (rb)^d calls, N_r = rN rounds):
  Φ = (r/c)·Σ_{i=0}^{d} (rb/c)^i ≈ N_r/c^(d+1).
* *A bound.* Since r/c < (D+1)/ρ, Φ < 2·((D+1)/ρ)^(d+1)·b^d whenever b(D+1) ≥ 2ρ.
* *Per level.* Each level costs b(D+1)/ρ, where the chain pays (D+1)/ρ once. With slack at every level, the gain over the uniform-round charge N_r/c is c^d.

**Remarks.**
1. **Uniform queries** [P]. A uniform round, or a uniform call and then a uniform round, guarantees only c/N_r, since the c mistakes may all be in the root. That charge, N_r/c, is often *worse* than chained imitation on the human's own tree (N_r⁰·K), because the slack tree is (r/r₀)^(d+1) times larger (§6).
2. **Level-uniform** [P]. Pick a depth uniformly from {0, …, d}, then a uniform round at that depth.
   * Its charge is (d+1)·max_i R_i/c^(i+1) ≤ (d+1)Φ.
   * It needs neither D nor s, as end-weighting did in without-a-check.md.
3. **Optimality** [P, N]. On balanced trees, no query law chosen from the tree's shape alone guarantees more than 1/Φ against every failure pattern that Lemma T1 allows.
   * *Proof.* Let V(u) be the adversary's best value inside sub(u), and m_u the mass there. By induction V(u) ≤ m_u/Φ(u):
     * a round's value is min(x_j, min_k V(k)) ≤ m_j/(1 + bΦ_child), with x_j its label mass and m_j its total mass;
     * the c cheapest rounds carry at most a c/r share of the sum.
   * Part 2 confirms this with Hedge against exact best responses: the value lies in [0.0998, 0.1013] against 1/Φ = 0.1000, and so on.
   * *On unbalanced trees* Φ is only an upper bound on the optimal charge. In one example of part 2, putting all mass on two childless rounds gives 1/2, against 1/Φ = 0.074.
4. **Graceful degradation** [P].
   * *If (B-sub) fails but within-call (B_D) holds,* every failed run has c label mistakes in a single call. TSI hits them with probability at least c^−d/Φ, so its charge is at most c^d·Φ ≈ N_r/c, which is optimal there (Theorem T3′).
   * *With no setback bound at all,* the charge is at most c^(d+1)·Φ ≤ N_r/(1 − c/(rb)): chained imitation on the slack tree.
   * So TSI is within a constant of the best guarantee known in each regime.
5. **Mixed parents** [P, same proof]. If only some calls absorb wrong subanswers, divide by c_w only at the ancestors w that absorb, and Lemma T2 holds. A wrong answer noticed one level up instead of at the parent loses one level of discount, not the guarantee.
6. **i.i.d. questions** [P]. The epochs of Corollary 3, with γ = 1/Φ_max, give O(Φ_max·K·log(K/δ)/ε) task queries.

**Other notions of slack.**
* *Pooled slack along the critical path* is the depth-first view of §3.4, and loses the discount.
* *Extra subcalls in the same rounds, or redundancy* (each subquestion posed k times, phrased differently) is neutral [P] for the depth-weighted guarantee.
  * This holds even granting that the parent can pick a good copy, which is itself a check.
  * A failed round then needs all k copies to fail, so its certificate mass is k times larger, but so is the tree at that level. The recursion for Φ is unchanged.
  * Redundancy's real use is as a *disagreement detector*: a free location signal, but only for errors the imitator makes inconsistently. A deterministic Bayes imitator errs consistently on a missing insight.

## 3. Where trees differ from chains

### 3.1 Lower bounds (analogues of note.md's Theorem 3)

**Theorem T4** [P, by the proof of Theorem 3 with "positions" redefined]. Fix a tree shape: r₀ rounds per call, b subquestions per round, depth d.
* **(a) Silent trees.** There is a class with unbounded setback on which every protocol that asks only task queries needs Q ≥ N_r⁰·E[K]/(32·ε·log₂(e·N_r⁰/(4ε))). Here N_r⁰ is the number of rounds in the human's own tree.
  * *The class.* Problem p has, with probability η, one insight k_p at a uniformly random round of a uniformly random call. A silent human writes it only at that round. Every answer is the set of insights in the call's subtree, so parents copy without judging.
  * *Why it is hard.* A task query is informative only at that call and round, on a transcript that lacks the insight. Steps 1–6 of Theorem 3 go through with n := N_r⁰.
  * *The matching upper bound.* Chained imitation of the depth-first order attains O(N_r⁰·K/ε). So for silent humans, trees are exactly as hard as chains of length N_r⁰.
* **(b) Bounded setback, D = 0, any slack.** There is a class satisfying (Budget) with r₀ = 1 and (B^T_0), both within calls and at parents, on which every task-only protocol needs Ω(b^d·K/(ε·log(b^d/ε))).
  * *The class.* With probability η, problem p has a hidden path of subquestions, uniform among the b^d paths, whose leaf needs insight k_p.
  * *The humans' behaviour.* Every internal call poses the same b subquestions in every round. Its answer collects the leaf values its children have returned. It succeeds once all b answers are good, so each round is a fresh attempt and the setback is 0. The hard leaf writes k_p, or corrects a wrong value, in its next round.
  * *Why it is hard.* Labels of internal calls do not depend on θ. Only a task query at the hard leaf is informative, so Theorem 3's proof works with n := b^d.
  * *Upper bound for this class.* Here c = s+1 = r, so Φ = Σ_{i≤d} b^i < 2b^d, and Theorem T3 is tight up to the logarithm and ε.
* **(c) Open.** I do not know whether the factor ((D+1)/ρ)^d is necessary.
  * A class that forced it would have to hide which c of a call's r rounds pose the subquestions that will be answered wrongly, while the imitator poses them correctly.
  * Hiding that costs about c^d·log₂ C(r, c) bits per problem, which inflates K by about the factor to be shown. My guess is that it is partly an artifact of query laws that ignore the run's content.

*What (b) says.* Slack multiplies a failure along *time*: a failed call has many bad rounds. Siblings are a second dimension, which slack does not touch.
* When a parent's reaction to a bad subanswer is the same whichever sibling produced it, as in (b), where it simply re-asks everything, nothing in the run locates the failed child, at any level.
* §4's rejections remove exactly this.

### 3.2 Wrong answers that propagate unnoticed

**Theorem T3′ (fooled parents)** [P, N]. Keep (Budget) and within-call (B_D), at label mistakes of rounds whose subanswers are all good, and drop (B-sub).
* *The certificate.* A failed call has c label mistakes, or a failed child posed in a correct round.
* *The charge.* With weight 1/c_u on each round of call u, the charge is Σ_u r_u/c_u = N_r/c ≈ N·(D+1)/ρ.
* *Optimality.* Some call has label mass at most 1/N, so no shape-only law beats this, and uniform rounds attain it.
* So the guarantee is linear in the number of calls. The depth discount of Theorem T3 is *entirely* the work of parents that absorb wrong subanswers.

*Per-call slack is expensive when setback is unbounded.*
* The slack tree has (1−ρ)^−(d+1) times as many rounds: 16× for ρ = ½ and d = 3, against 2× for a chain.
* So the fallback is that much worse than chained imitation of the human's own tree.
* *Put slack where setback is bounded.* Each level with slack trades a factor (D+1)/ρ_h in Φ against (1−ρ_h)^−1 in compute and in the fallback.

### 3.3 Isolation: better or worse?

* **Better for the assumption.** A commission can reach other calls only through its call's answer.
  * In a shared notebook, a later subcall reads earlier subcalls' entries, so (B_D) must hold *across* subcalls.
  * With isolation it is replaced by (B-sub) at the parent, and a mistake's blast radius is the answers of its ancestors.
  * A later subcall is not misled by an earlier one's confident commission.
* **Better for the bound.** Each call has its own τ, so a mistake is charged in its own call's rounds, not in global steps. That is what makes per-call slack and the depth discount possible.
* **Better for provenance.** In the human's own tree, too, a subanswer is a delegate's report. A parent may therefore treat subanswers skeptically, and the scaffold may label them as reports, without breaking (T1′). The design law of slack-imitation §4 forbids such labels in a chain, where imitator entries must pass as the human's own notes.
* **Worse for recovery.**
  * There is no lateral repair: a later sibling cannot fix an earlier sibling's mistake, only the parent can, and it sees the answer, not the work.
  * Re-asking the same question returns the same answer from a deterministic imitator. Recovery needs a changed question that states the doubt, or the parent's own work.
  * Slack cannot be pooled: a call with many mistakes cannot borrow its siblings' slack.
  * Siblings add the location problem of §3.1(b).

### 3.4 Depth-first in one notebook [S]

* *The transfer.* Run the tree depth-first in a single shared notebook. It is then a chain of n = N_r⁰ + σ steps, and Theorem 2 applies verbatim, with σ global slack and (B_D) measured in *global steps*.
* *What is lost:*
  * isolation, so (B_D) is needed across subcalls;
  * the reference itself: it becomes the human's own depth-first chain, a different computation from the tree, which must finish within n₀ steps;
  * the scale of setback. A wrong subanswer that the parent redoes costs the whole subtree, D_g ≈ D·N_r/r for a redo at the root, so the charge (D_g+1)/ρ ≈ N_r/c is the uniform-round rate. A chain analysis with uniform queries cannot tell depths apart, and depth weighting needs exactly the per-call accounting of §2.
* *What is gained:* pooled slack, and compute and fallback grow by (1−ρ)^−1 instead of (1−ρ)^−(d+1).

## 4. Asking before committing, and verifiers

**Proposition T5 (root verifier)** [P]. Run SI-V on trees: on a rejection, keep the imitator fixed and draw rounds from q = ω/Φ until one is a mistake. Then:
* no rejected run is output;
* at most ⌊K⌋ runs are rejected;
* under (Budget) and (B^T_D) for all entries, the expected number of search queries is at most Φ_max·⌊K⌋ (each search is geometric with success probability at least 1/Φ; Wald);
* without (B^T_D), it is at most N_r·K/(1 − c/(rb)).

**Proposition T6 (a verifier at every node)** [P].
* *The verifiers.* For subquestions V_q is sound: V_q(a) = 1 ⇒ a ∈ Good(q). V_root decides Good at the root.
* *The search,* after a rejection:
  * at the current failing call, verify its children's answers, and move to one that fails;
  * stop at a call u* whose children all pass;
  * task-query the round of its parent that posed u*'s question. If that round is a mistake, the search is done;
  * otherwise u* satisfies (Budget), and its children are good, so its bad rounds are all label mistakes. By Lemma T1 there are at least c of them (at least 1 without (B_D)). Sample u*'s rounds uniformly until a hit.
* *The result:*
  * at most ⌊K⌋ rejections;
  * per rejection, at most 1 + min{r, (D+1)r/(s+1)} task queries in expectation, and at most d·B_max verifier calls, where B_max is the most children a call has (d(1 + ⌈log₂ B_max⌉) with batch verification);
  * (B-sub) is never used.
* *Its ancestors.* This is note.md's Corollary 12, with machine verifiers in place of the human's check and Lemma S at the end. Where subanswers are verifiable (proofs, tests), trees are *easier* than chains: the cost does not depend on N, depth or b.

**Proposition T7 (ask before committing)** [P].
* *The protocol.* At every round, in execution order (say depth-first), ask the human instead of committing whenever the top label's mass is below 1 − α.
* *(a)* On every path there are at most K/log₂(1/(1−α)) asks. The proof is verbatim.
* *(b)* E Σ_t 1[run t fails]/Φ_t ≤ K/max{1, log₂(1/α)}.
  * This needs (B^T_D) at committed mistakes *and* at every round with a non-good subanswer, asked or not.
  * *Proof.* As Proposition 5, ordering the data A_{<ρ}, then h, then the rest. An asked round has the human's label, so in Lemma T2 it counts as a correct-label round, and its children satisfy (Budget).
* *(c)* The verifier versions follow as in Proposition 5(c).
* *What asking cannot do.* It does not remove (B-sub). A confident wrong answer created deep down reaches a parent whose own rounds are all asked or confident.
* *What it does.* A call's answer is a certainly-due slot (thread E §1): wherever the human would write its answer, the decoder writes its plurality guess unless it asks. Asking hands the answer-writing round to the human whenever that guess is unconfident, so asks should concentrate there.

**Proposition T8 (rejections)** [S, N].
* **(B-notice):** after round j of a call, the human's next label contains "REJECT q′" for *exactly* the non-good subanswers of round j.
* *The walk.* At call u:
  * with probability λ_h, query a uniform round of u;
  * otherwise pick a rejection in u's transcript uniformly. Query its round (¼), the round that posed the rejected question (¼), or move to the rejected child and repeat (½).
  * Here h is u's height. With no rejection, query a uniform round.
* *The claim.* If the root fails and c ≥ 2, the walk hits a mistake with probability at least f_d, where
  * f₀ = c/r, A = (c−1)/(4r), B_h = min{¼, f_{h−1}/2};
  * f_h = A·B_h/(A + B_h), with λ_h = B_h/(A + B_h).
  * So 1/f_d ≤ 2^d·5r/(c−1) ≈ 5·2^d·(D+1)/ρ.
* *Sketch.* Let a failed call u have a label mistakes, and let F count the rejections that appear in correct rounds of failed children posed in correct rounds.
  * Excluding the last round, its c−1 bad rounds give c − 1 ≤ 2a + F. A missed rejection is a mistake in the next round, so a label mistake can cover at most two bad rounds.
  * If a ≥ (c−1)/4, the label branch hits with probability at least λ(c−1)/(4r).
  * Otherwise F ≥ 1, and every rejection is worth at least B_h:
    * a spurious rejection sits in a mistaken round;
    * a rejection of a child posed in a mistaken round points to that round;
    * a rejection of a failed child under (Budget) leads to a child worth f_{h−1}, by induction.
* *The check.* Part 3 computes the exact hit probability on 6,000 random trees, where imitated rejections are exact in correct rounds and arbitrary in mistaken ones. The bound held with margin 3–16×.
* *What (B-notice) is.* It is a check of subanswers delivered as task output.
  * It needs no separate check queries.
  * An imitated judgment's errors are label mistakes at known positions: the round with the rejection, or the round right after the subanswer.
  * It is stronger than (B-sub), and plausible only for checkable answers.
  * More generally, the b^d disappears whenever the parent's reaction names the failed child, for example by re-asking only that subquestion.

## 5. Is bounded setback at the parent believable?

**The manager analogy.** A manager who gets a wrong report from a subordinate catches it when:
* it conflicts with another report or with what the manager knows;
* the plan built on it fails, which is a bounded setback whose size is the time until the failure shows;
* or an audit finds it.

The manager is fooled by plausible, confident reports on matters he cannot check cheaply. Organizations add redundancy, evidence requirements and spot audits for this reason. TSI's query is a spot audit, weighted towards the top.

**Three things make it worse here.**
* *The errors look normal.* A Bayes imitator's wrong answer is its plurality answer, the most typical-looking report, so the manager's plausibility filter, which catches *odd* reports, works against us.
* *The reference parent has no reason to doubt.* In the human's own tree, every subanswer comes from the human itself and is good, so its trust is calibrated to a reliable delegate. Skepticism must be put into the reference by instruction, which costs rounds: "check each subanswer's justification before relying on it; reject unsupported ones".
* *Re-asking does not help.* The same question returns the same answer, so the parent must state its doubt or do the work.

**One thing makes it better.** Provenance is genuine (§3.3). A parent that treats subanswers as fallible reports is an ordinary manager, not a researcher distrusting its own notebook, so the chain's worst case, a recorded dead end of one's *own* that one never revisits, is weaker here.
* But a subordinate's "approach A does not work" is still the worst case. The parent closes the branch and has no visible work to check.

**By kind of subanswer** (graded reading: the setback exceeds D = 2, or the parent is fooled, at no more than about 5% of the imitator's wrong subanswers). These are my guesses, with no data:

| subanswer | (B-sub), D ≤ 2 | (B-notice) |
|---|---|---|
| mathematics, answers must carry proofs | 55% | 40% |
| mathematics, bare claims | 30% | 15% |
| software, scaffold runs tests (better: use Proposition T6) | 60% | 45% |
| facts, lookups, empirical values | 25% | 10% |
| judgments, feasibility, negative results ("A fails") | 10% | 5% |

**Compared with the chain's (B-commit)** (35%, 40% and 15% without asking):
* higher for checkable answers, because of genuine provenance and the evidence requirement;
* lower for unverifiable ones, because the work is invisible.

**Mixed parents** (Remark 5) matter in practice. Errors usually get noticed somewhere up the hierarchy, not always at the parent, and each absorbing level still multiplies the protection by c.

## 6. Numbers

Charges per unit of K (expected failed runs ≤ charge × K) for balanced trees with r₀ = 10, from part 4 of the code. "Chained" is chained imitation of the human's own tree, without slack. The uniform-round charge equals the optimum for fooled parents.

| s | D | b | d | c | calls N | rounds N_r | chained, own tree | uniform round = fooled parents | depth-weighted Φ | level-uniform | rejection walk |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 10 | 1 | 1 | 2 | 6 | 421 | 8,420 | 1,110 | 1,403 | 52 | 111 | 61 |
| 10 | 1 | 2 | 2 | 6 | 1,641 | 32,820 | 4,210 | 5,470 | 174 | 444 | 61 |
| 10 | 1 | 2 | 3 | 6 | 65,641 | 1,312,820 | 84,210 | 218,803 | 1,161 | 3,951 | 139 |
| 10 | 2 | 2 | 3 | 4 | 65,641 | 1,312,820 | 84,210 | 328,205 | 5,555 | 20,000 | 227 |
| 10 | 1 | 4 | 2 | 6 | 6,481 | 129,620 | 16,410 | 21,603 | 640 | 1,778 | 61 |
| 30 | 1 | 2 | 3 | 16 | 518,481 | 20,739,240 | 84,210 | 1,296,202 | 390 | 1,250 | 95 |

**Reading.**
* *Depth weighting* gains 70–200× over chained imitation of the human's own tree at d = 3. Uniform queries on the slack tree *lose* to it.
* *D matters at every level.* D = 2 instead of 1 multiplies Φ by about 5 at d = 3.
* *Rejections* make the charge nearly independent of b, and grow only as 2^d.

## 7. Open

1. Is ((D+1)/ρ)^d necessary (T4(c)), or can a query law that reads the run's content avoid it?
2. Remove the 2^d of Proposition T8, and allow rejections that come up to D rounds late.
3. An exact-Bayes experiment on a tree class, the analogue of E6, with silent, fooled, absorbing and rejecting parents.
4. Round granularity. Posing one subquestion per round makes b = 1, which turns sibling ambiguity into round ambiguity, and slack handles the latter. It helps if setbacks are counted in re-asks, and not if they are counted in work, since D then grows by about b. Which is true of real delegation is an empirical question.
5. Planted wrong subanswers, the tree version of slack-imitation §4's test: give a researcher a plausible wrong report from a "collaborator", and measure the extra time until they notice, and whether they name it (B-notice).
