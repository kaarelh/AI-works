# Without a check: where in a run to ask

*Without some assumption, no protocol that asks the human only for task steps beats chained imitation by more than a factor O(log(n/ε)) in the worst case. One assumption that suffices, and needs no check: whenever a run fails, the imitator has made a mistake within the last r steps. That holds when the human, working on the imitator's states, would still repair what is missing within its last r steps. Then asking near the end of runs gives a guarantee of about 2r·ln(n)·K/ε task queries, instead of chained imitation's n·K/ε, and the guarantee is never worse than chained imitation's by more than a factor 2.*

A second research note by Claude (Anthropic), following [`note.md`](note.md), in response to a further question from Kaarel Hänni. Draft. One independent AI referee checked every statement and re-ran the experiment; its report and the response are in [`verification/`](verification/). No human has checked the mathematics.

## The question

The first note, [`note.md`](note.md), removes chained imitation's factor n by assuming that the human can *check* a state: say whether it has gone off track, with a verdict that its own work preserves. The follow-up question: is there a better protocol without that assumption?

## Answers in brief

1. **Not without some assumption, and the hard case says which kinds would do.**
   * Theorem 3 of the first note: on the *hidden-insight* class, every protocol that asks only for task steps needs about n·K/(ε log(n/ε)) of them. The class depends on ε.
   * Its humans combine three features. Their knowledge is problem-specific. Their insights come at unpredictable steps. And they are *silent*: handed a state that lacks the insight they would have had by now, they carry on without it. So a failed run contains exactly one mistake, at an unpredictable step, and nothing later in the run points back to it.
   * A better protocol has to assume something that excludes this class. The options:
     * insights at predictable steps (a silent class whose insights all come at step 0 is learned with K/ε task queries);
     * knowledge shared across problems;
     * a check (the first note);
     * isolation (item 7);
     * or persistence (this note).

2. **What a protocol is charged for is the mistake mass of failed runs** (Theorem 1). Let a protocol ask the human for one step of each run, drawn from a distribution q over steps. Then the expected sum, over rounds, of q(steps where the imitator erred) is at most K.
   * In the resulting upper bound, chained imitation's uniform q charges a failed run 1/(fraction of its steps that are mistakes).
   * The factor n of chained imitation's bound comes from failed runs with a single mistake.

3. **The assumption: deficits persist.**
   * *The condition.* Write (C_r) for: in every round, from the state the imitator reaches with r steps to go, the human's own continuation still succeeds. In words: the human could still repair the imitator's work within the last r steps.
   * *What it gives.* By a hybrid argument, every failed run then has a mistake among its last r steps (Lemma 2).
   * *What it asks of the human.* No new *kind* of query: no check, no verdict, no preservation. But it is a substantive assumption about how the human works on the imitator's states. The human must notice what is missing and repair it within r steps.
   * *Relative to the learner.* Whether it holds depends also on the learner, because it is about the states the learner's decoder reaches (Lemma 5).

4. **The protocol: end-weighted chained imitation** (Theorem 3). With probability 1/2, ask the human for a uniformly random step of the run. Otherwise ask for the step at distance d from the end, with probability proportional to 1/(d+1).
   * *Always*, assuming only that the human's own runs succeed: at most 2n·K failed runs in expectation. That is chained imitation's bound up to the factor 2.
   * *Per failed run:* the charge is at most 2·min{n, (d+1)·H_n}, where d is the distance of its last mistake from the end and H_n ≈ ln n.
   * *Under (C_r):* at most 2r·H_n·K failed runs, so 2r·H_n·K/ε task queries for failure ε on i.i.d. problems.
   * *Knowing r:* replacing the harmonic half by the last r steps gives 2r·K, and keeps the 2n·K worst case.
   * *Only the last step:* asking only at the last step gives at most K failed runs under (C_1). Without (C_1) it learns only insights that come at the last step.
   * *On a particular human* end-weighting can do worse than chained imitation by more than a factor 2. In an example of the referee's the ratio tends to 4. Only the guarantees compare by a factor 2.

5. **The question's "first time the run goes off track", without a check** (Proposition 4). Hold the decoder fixed, and suppose its mistakes, once they start, continue to the end of its run.
   * Then binary search *with task queries* finds the first mistake in ⌈log₂ n⌉ queries. The human's own next step at a state serves as the check.
   * In E3 this makes the runs exactly right.

6. **Is persistence true of humans?** These are conjectures, not shown.
   * *Where it is plausible.* A researcher who has an insight bearing on the problem, handed a draft past the point where the insight belongs, will plausibly use or add it, quickly if the insight is the only thing missing.
   * *Where it fails:*
     * errors the human would not notice while working;
     * deficits whose repair takes much work, such as a direction noticed late, which make r large.
   * *When it fails,* the guarantee degrades gradually (Theorem 3), and never beyond twice chained imitation's.
   * *Persistence and checks are different assumptions.* A silent human can have a preserved check, and a persistent human need not give consistent verdicts. Persistence asks for repair through work; a check asks for a verdict.

7. **The other route: no rare knowledge, at a cost.**
   * *What isolation gives.* If the human is *δ-isolated*, meaning no function at most as complex differs from it only on a set of measure less than δ, then a different learner pins the human on the support of a fixed distribution μ. That learner restricts its prior to isolated hypotheses, and needs O((K + log(1/β))/δ) i.i.d. queries from μ for failure probability β (Theorem 9 of [`../ultranatural/note.md`](../ultranatural/note.md)).
   * *What it costs.*
     * The queries must be i.i.d. from μ. If μ is the distribution of states on the human's runs, each sample costs up to n task queries.
     * Runs are right only where they stay in μ's support.
     * If the human is not isolated, that learner fails outright.
   * *It does not cover the hard class.* The hidden-insight humans are not isolated beyond the measure of a single insight state. It is plausible, but not shown, that real humans' rarely used knowledge is of the same kind. So isolation assumes the hard case away.

8. **Experiment E3** (Section 6) uses the hidden-insight class with m = 100 problems and a 2% target on final states. It compares silent humans with *catch-up* humans, who write their insight at any later step at which the state lacks it.
   * *Silent humans,* 10 per n:
     * chained imitation needs 5,000 to 316,000 task queries, in proportion to n;
     * end-weighting needs 1.2 to 1.5 times that;
     * asking only at the last step learns only the insights at the last step.
   * *Catch-up humans,* 200 per n:
     * asking at the last step needs about 300 task queries at every n, and end-weighting 540 to 650;
     * chained imitation needs 1,300 to 2,500, rising with n and heavy-tailed: its medians are 1,200 to 1,850;
     * bisection with task queries makes the runs exactly right, with 490 to 770.

9. **All protocols in both notes.** The rows bound different things.
   * *Failure events.* Row 1 bounds runs that differ from the human's. Rows 2 and 3 bound bad final states; for row 2's lower bound and row 3, bad means a final state other than the human's. Rows 4 and 5 bound runs that fail the check.
   * *Kinds of guarantee.* Rows 1 to 3 hold in expectation with a random stopping round. Rows 4 and 5 hold with probability 1 − δ.
   * *Learners.* Row 6 uses a different learner, and queries i.i.d. from μ.
   * *Row 3 is not an improvement in every respect.* Its runs still differ from the human's along the way, on about half the problems in E3.

   | the human is asked for | assumption about the human | task queries | other queries |
   |---|---|---|---|
   | task steps (chained imitation) | the human's runs succeed | n·K/ε; Ω(n·K/(ε log(n/ε))) needed on a hard class | none |
   | task steps, end-weighted (this note) | the human's runs succeed / and (C_r) | 2n·K/ε / 2r·H_n·K/ε | none |
   | task steps at the last step (this note) | (C₁) | K/ε | none |
   | task steps, and a check of final states | the human's runs pass the check | n·K | O(K log(K/δ)/ε) looks |
   | task steps, and a check of any state | the check is preserved | K | O(K log(K/δ)/ε) looks, O(K log(n/ε)) bisection checks |
   | task steps i.i.d. from μ, a different learner | δ-isolation | O((K + log(1/β))/δ) | none |

## 1. Setting

Everything is as in Section 1 of [`note.md`](note.md):
* a deterministic human P;
* runs x₀, …, xₙ;
* a prior w with K(P) = log₂(1/w(P));
* the majority decoder G_D;
* Lemma 1 there: at most ⌊K(P)⌋ task queries ever land on a mistake of the current decoder.

**Standing assumption (S).** A run's success is a deterministic predicate of the run (for example, of the problem and the final state), and the human's own run succeeds on every problem.

The example used below: success means the final state is the human's own final state. If the decoder's run fails, it then differs from the human's run, and by the first-divergence observation of the first note the decoder makes at least one mistake on its own run.

For a decoder G and a problem x₀ with decoder run x′₀, …, x′ₙ:
* M ⊆ {0, …, n−1} is the set of steps k at which G makes a mistake on its own run, G(x′_k) ≠ P(x′_k);
* the *hybrid* H_k is the run that follows the decoder for k steps and then the human: x′₀, …, x′_k, P(x′_k), P(P(x′_k)), …, up to step n.

H₀ is the human's run and Hₙ is the decoder's.

## 2. What a protocol is charged for: the mistake mass

**Theorem 1.** In round t, a problem x₀ᵗ arrives, in any order, possibly chosen by an adversary that has seen everything before round t. The protocol runs the current decoder G_t on it. It then task-queries the decoder's state at a step k_t drawn, after x₀ᵗ is fixed, from a distribution q_t on {0, …, n−1}; q_t may depend on the past and on the run. Let M_t be the mistake set of run t. Then

  E Σ_t q_t(M_t) ≤ ⌊K(P)⌋.

*Proof.* M_t is fixed by the past and x₀ᵗ, so given them the query of round t lands on a mistake with probability q_t(M_t). By Lemma 1 of the first note, at most ⌊K(P)⌋ queries ever do. ∎

**Chained imitation's charge.** For uniform q the summand is |M_t|/n. Since a failed run has at least one mistake under (S), chained imitation's upper bound charges a failed run at most n, and the first note's Proposition 2 bound n·K comes from failed runs with a single mistake. In the hidden-insight class, every failed run of the class-prior decoder has a single mistake. The human is silent: on the decoder's states after the missed insight, it also writes nothing.

**Lemma 2 (where a failed run must have a mistake).** Let success be any deterministic predicate of the run. If some hybrid H_{k₀} with k₀ ≥ n − r succeeds and the decoder's run Hₙ fails, then the decoder makes a mistake at some step k with k₀ ≤ k < n.

*Proof.* Some k in [k₀, n) has H_k succeeding and H_{k+1} failing. If x′_{k+1} = P(x′_k), then H_{k+1} and H_k are the same sequence, so they cannot differ in success. Hence x′_{k+1} ≠ P(x′_k), a mistake at k. ∎

**Assumption (C_r): deficits can still be repaired in the last r steps.** In every round, the hybrid H_{n−r} succeeds: from the state the decoder reaches with r steps to go, the human's own r steps end well.

By Lemma 2, under (C_r) every failed run has a mistake among its last r steps.
* *Relative to the learner.* (C_r) quantifies over the decoder's states, so it is a joint property of the human and the learner. It is in the spirit of DAgger's recoverability (Ross, Gordon and Bagnell 2011), whose constant instead bounds how much one deviation can raise the expert's cost-to-go.
* *A sufficient condition on the human alone:* from *every* state with r steps to go, its continuation ends well. That is reasonable only if r steps of work are enough to finish from any draft.
* *The intended reading* is in between. The decoder's states contain most of the right work, and what they lack is something the human would contribute within r steps once it is working on the state.

## 3. End-weighted chained imitation

**Protocol EW.** Chained imitation with the step drawn from

  q_EW(k) = (1/2)·(1/n) + (1/2)·1/((n − k)·H_n),  k = 0, …, n−1,

where H_n = 1 + 1/2 + … + 1/n. The weights sum to 1, every step has probability at least 1/(2n), and the step at distance d from the end (k = n−1−d) has probability at least 1/(2(d+1)H_n).

**Theorem 3.** Assume (S). For every sequence of problems, with d_t the distance from the end of the last mistake of run t when run t fails,

  E Σ_t 1[run t fails] · max{ 1/(2n), 1/(2(d_t+1)·H_n) } ≤ ⌊K(P)⌋.

In particular:
* **(a)** the expected number of failed runs is at most 2n·K(P), chained imitation's bound up to the factor 2.
* **(b)** if (C_r) holds in every round, the expected number of failed runs is at most 2r·H_n·K(P). For i.i.d. problems, stopping at a uniformly random round among the first N gives expected failure probability at most 2r·H_n·K(P)/N. So N = 2r·H_n·K(P)/ε task queries suffice; choosing N this way needs bounds on K(P) and r.
* **(c)** if r is known:
  * replacing the *harmonic* half by the uniform distribution on the last r steps gives at most 2n·K(P) always, and 2r·K(P) under (C_r);
  * the last r steps alone give r·K(P) under (C_r), but no worst-case bound;
  * asking only at the last step, under (C₁), lands on a mistake in every failed run, so at most ⌊K(P)⌋ runs fail, on every path.

*Proof.* On a failed run t, (S) gives |M_t| ≥ 1, so q_EW(M_t) ≥ (1/2)·|M_t|/n ≥ 1/(2n). It is also at least the weight of the last mistake, which is at least 1/(2(d_t+1)H_n). Apply Theorem 1. For (b), (C_r) and Lemma 2 give d_t ≤ r−1; the rest is as in the first note's Proposition 2. (c) is the same computation with the other weights. ∎

**Comparisons are between guarantees, not humans.**
* (a) says that EW's guarantee is never worse than chained imitation's by more than a factor 2. It does not say that EW does at most twice as badly as chained imitation on a given human. A query can make the majority decoder worse, because the majority vote is not monotone in the data.
* The referee's example is a chain with three hypotheses: P, one that differs from P near the end, and one that differs at the start. Initially P and the first outvote the second, and the decoder is exact. A query near the end refutes the first, after which the second outvotes P at the start, and runs fail until the start itself is queried.
* EW asks near the end early and then hits the start at rate about 1/(2n). Its expected number of failed runs is 1.8 to 3.4 times chained imitation's for n = 4 to 256, tending to 4 ([`verification/referee2_theory_checks.out`](verification/referee2_theory_checks.out), §4).

**What the theorem says about the per-step question.** Slide 30 of the talk asks whether 99.9% per step is enough.
* *Whether a run succeeds* depends on how many mistakes it contains. *What it costs to find them* depends also on where they sit.
* With end-weighting, a failed run whose mistakes reach its last steps is charged about 2·ln n, whatever n.
* A failed run with a single mistake at an unpredictable step is charged n. Theorem 3 of the first note shows that, up to a factor log(n/ε), no task-only protocol avoids this on the hidden-insight class.
* Chained imitation also benefits from persistence when deficits start early, because they then make many steps wrong. A deficit that starts late leaves few mistakes, and chained imitation's charge for it can still be n, even under (C₁).

**On the choice of weights.**
* The harmonic weights are a choice for unknown r. They lose a factor H_n against knowing r.
* A schedule that adapts to unknown r with a smaller loss is left open. A bound C·r·log₂ r for all r ≤ n would need C to grow like log log n.

## 4. The first mistake, found with task queries

Asking at the end detects a failed run and teaches what the human does on a state that lacks something. To repair the cause, one wants the step at which the run first went wrong, which is the question's second idea.

**Proposition 4.** Fix a decoder G, and add the answers below to the data only after the search. Suppose that on G's run the mistake set M is an up-set: if G errs at step k, it errs at every later step. Then, starting from a mistake at the last step (which a last-step query has found), binary search finds the first mistake min M with ⌈log₂ n⌉ task queries. Each is a query at a state x′_j of G's run, compared with x′_{j+1}.

*Proof.* The predicate "j ∈ M" is monotone in j, and one task query at x′_j decides it. Knowing n−1 ∈ M leaves n candidates. ∎

**Conditions.**
* *The decoder must be held fixed.* Once the decoder is updated, its run changes and its mistake set need not be an up-set. In the catch-up class, a decoder that knows the insight's content but not its step writes it at the posterior median, and errs on an interval or at a single step.
* *Where the up-set condition holds.* It holds for a decoder that lacks something the human keeps contributing at every later step. Among the catch-up humans this is every decoder that has not yet learned the insight. It fails for inconsequential mistakes, after which the decoder is right again; for the bound of Theorem 3 any mistake serves as well as the first.

**What it buys.** In E3, finding the first mistake makes the decoder's runs exactly right, at log₂ n extra task queries per insight. Asking only at the end makes the final states right. It leaves the runs on problems with an insight differing from the human's at the step where the insight is written.

## 5. Persistence and the hard class

**The two classes.** The hidden-insight class of the first note and its *catch-up* version differ only in what the human does on a state that lacks the insight at a step t_p < j < n:
* *Silent:* P(p, j, ⊥) = (p, j+1, ⊥). The human carries on without it.
* *Catch-up:* P(p, j, ⊥) = (p, j+1, k_p). The human writes the insight it would have had by now.

They have the same rare, problem-specific knowledge, at the same unpredictable steps, and the same prior: t_p = ∞ with probability 1 − η, else uniform on {0, …, n−1}, and k_p uniform on q values. Success means ending in the human's own final state.

**Lemma 5.** Suppose η(n−1)/n ≤ q/(q+1), for instance η ≤ 2/3, with ties broken towards "no insight". Then the class-prior majority decoder never writes an insight value the data have not confirmed. Consequently (C₁) holds in every round for catch-up humans, and fails for silent humans whenever some insight with t_p < n−1 is unfound.

*Proof.*
* *What the data say before an insight is found.* Until an insight answer for p is seen, the data on p only say t_p > lo for some lo ≥ −1.
* *Each value of k_p is outweighed.* At step j, writing a particular value k has posterior mass η(j−lo)/(nq) / (1 − η(lo+1)/n), and "no insight" has (1 − η(j+1)/n) / (1 − η(lo+1)/n). For j ≤ n−2 and lo ≥ −1 the first is at most the second exactly when η(j−lo)/(nq) ≤ 1 − η(j+1)/n. That is hardest at lo = −1, j = n−2, where it reads η(n−1)/n ≤ q/(q+1). A write at the last step does not affect (C₁).
* *After an insight is found,* the decoder writes only the confirmed value.
* *The catch-up human finishes.* So the decoder's state at step n−1 either carries the right insight, or carries none. From either, the catch-up human's last step ends in its own final state.
* *The silent human does not.* From (p, n−1, ⊥) with t_p < n−1 it ends in (p, n, ⊥), which is wrong. ∎

**Consequences.**
* *Silent humans.* On the silent class, Theorem 3 of the first note applies to final-state failure as well as to runs that differ. Step 4 of its proof bounds the probability that the decoder's run ends in (p, n, k_p). That transfer is valid for success = "the final state is the human's", not for weaker tests.
* *Catch-up humans.* By Lemma 5 and Theorem 3(c), asking only at the last step makes at most one task query per insight that lands on a mistake. In E3 that is about 300 task queries at every n.

So *within the hidden-insight class*, what separates the hard version from an easy one is whether a deficit, once the run is past it, leaves a trace in the human's later work. This does not show that persistence decides the cost in general:
* silent humans with predictable insight steps are also easy (item 1);
* persistent humans with large r are still costly.

**For real humans** these are conjectures, not shown.
* An insight that the human has, and that a draft visibly lacks, is plausibly added quickly: small r.
* An error the human would build on without noticing, or a direction it would only abandon late, is not repaired in a few steps: large r, or none.

For the latter, Theorem 3 of the first note shows a cost of about n per failure *when such deficits occur at unpredictable steps of rare, problem-specific kinds*.

**Scaffold design.** One could ask for persistence in the task decomposition: "before continuing, add anything this draft lacks that you would have contributed by now."
* Such an instruction changes the human program P, and with it K(P) and the target of imitation.
* It asks the human to notice deficits, which is close to what a check asks.
* Nothing here tests whether it would produce (C_r) with small r. If it does not, Theorem 3(a) still bounds the guarantee at twice chained imitation's.

## 6. Experiment E3

Code: [`code/end_weighted.py`](code/end_weighted.py). Outputs: [`results/end_weighted_summary.json`](results/end_weighted_summary.json), [`results/end_weighted.out`](results/end_weighted.out) and [`results/end_weighted_table.md`](results/end_weighted_table.md).

**Setup.**
* *The class.* Both versions of the hidden-insight class, with m = 100 problems and η = 1/2. Each problem's posterior is exact, under the class prior.
* *The decoder.* It writes no unconfirmed insight value, which holds for every q ≥ 2 by Lemma 5, so the code need not fix q.
* *Humans.* At each n they are E1's humans: seed 1000·n + s. There are 10 silent humans per n, because chained imitation on silent humans needs up to 3·10⁵ runs each, and 200 catch-up humans per n, because the cost there is heavy-tailed.
* *Stopping.* The failure of the decoder's final state on a fresh problem is computed exactly after every run, and the run stops the first time it is at most 2%. This oracle stopping rule measures cost; it is not Theorem 3(b)'s random stopping, which a learner could run.
* *Caps.* Runs are capped at 100·m·n for CI and EW and at 200·m for LAST and BIS.

**Results.** Entries are mean task queries (± standard error for the catch-up humans) and median. In parentheses: the probability, at the end, that the decoder's run differs from the human's anywhere.

| humans | n | CI | EW | LAST | BIS |
|---|---|---|---|---|---|
| silent (10) | 16 | 4,967; median 4,716 (0.02) | 5,939; median 5,803 (0.02) | never (failure 0.46 at the cap) | — |
| silent (10) | 64 | 18,085; median 17,636 (0.02) | 26,810; median 25,934 (0.02) | never (failure 0.50 at the cap) | — |
| silent (10) | 256 | 76,929; median 75,158 (0.02) | 101,924; median 102,031 (0.02) | never (failure 0.50 at the cap) | — |
| silent (10) | 1024 | 316,170; median 313,232 (0.02) | 468,305; median 458,750 (0.02) | never (failure 0.49 at the cap) | — |
| catch-up (200) | 16 | 1,318 ± 39; median 1,216 (0.25) | 648 ± 14; median 617 (0.37) | 295 ± 4; median 284 (0.47) | 488 ± 5; median 480 (0.02) |
| catch-up (200) | 64 | 1,871 ± 82; median 1,514 (0.40) | 626 ± 14; median 588 (0.46) | 298 ± 4; median 294 (0.49) | 584 ± 5; median 578 (0.02) |
| catch-up (200) | 256 | 2,225 ± 134; median 1,680 (0.48) | 581 ± 13; median 549 (0.50) | 299 ± 4; median 293 (0.50) | 687 ± 5; median 676 (0.02) |
| catch-up (200) | 1024 | 2,496 ± 146; median 1,848 (0.49) | 540 ± 10; median 528 (0.50) | 294 ± 4; median 282 (0.50) | 774 ± 5; median 776 (0.02) |

**Silent humans.**
* *End-weighting* costs 1.2 to 1.5 times chained imitation, within the factor 2 of Theorem 3(a)'s guarantees.
* *Asking only at the last step* learns exactly the insights with t_p = n−1: 4.4, 1.1, 0.1 and 0.1 per human. Failure stays near the fraction of problems with an insight before step n−1.

**Catch-up humans.**
* *Asking at the last step.* It makes one task query per run, and every query at a problem with an unfound insight finds it. So its cost is the time to meet all but two of the roughly 50 problems with an insight: about 300, as a coupon-collector count predicts, at every n.
* *End-weighting* needs 1.8 to 2.2 times as many.
* *Chained imitation* needs 1,300 to 2,500, rising with n, with medians 1,200 to 1,850. A problem whose insight comes at step t has mistakes at steps t to n−1, so chained imitation's query finds the insight with probability (n−t)/n per visit. That is heavy-tailed: problems with t near n cost it up to n visits. The stopping rule waits for all but two problems, so the cost is set by the latest insights. Theorem 3 charges every such failed run only 2H_n under end-weighting, because its last mistake is at the last step.
* *Runs exactly right.* Only bisection with task queries (BIS) makes the runs exactly right, at log₂ n extra task queries per insight. The others get the final state right and leave the runs on problems with an insight differing from the human's.

## 7. Open

1. **A weighting that adapts to unknown r** with less loss than H_n.
2. **Deficits that show up later, but not necessarily at the end.** Theorem 3 charges the distance of the *last* mistake from the end. Suppose that, conditional on the past, a failed run has a mistake in its last r steps with probability at least ρ over the draw of the problem. Then the same proof gives a factor 1/ρ. Whether another natural notion of persistence gives better weights is open.
3. **Measuring persistence.** Persistence is an empirical property of how people work on drafts that are not their own. It could be measured directly: hand researchers drafts with a key idea removed or an error planted, and see whether, and how fast, their next rounds of work restore it.
4. **Stochastic humans,** as in the first note.
