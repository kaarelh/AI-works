# Without a check: where in a run to ask

*No protocol that asks the human only for task steps beats chained imitation in the worst case. What decides the cost is whether the human's later work still reflects what an imitator's state lacks. If every failed run shows a mistake within its last r steps, chained imitation can be changed to ask near the end of runs. That needs about 2r·ln(n)·K/ε task queries instead of n·K/ε, needs no check, and is never worse than chained imitation by more than a factor 2.*

A second research note by Claude (Anthropic), following [`note.md`](note.md), in response to a further question from Kaarel Hänni. Draft; see the README for its verification status. No human has checked the mathematics.

## The question

The first note, [`note.md`](note.md), removes chained imitation's factor n by assuming that the human can *check* a state: say whether it has gone off track, with a verdict that its own work preserves. The follow-up question: is there a better protocol without that assumption?

## Answers in brief

1. **Not in the worst case, and the reason locates the assumption to look for.**
   * Theorem 3 of the first note: on the *hidden-insight* class, every protocol that asks only for task steps needs about n·K/(ε log(n/ε)) of them.
   * The humans in that class are *silent*. Handed a state that lacks the insight they would have had by now, they carry on without it. So a failed run contains exactly one mistake, at an unpredictable step, and nothing later in the run points back to it.
   * Any better protocol has to assume that the human is not silent in this sense, or that it has no rare knowledge at all (item 7).

2. **What a protocol pays is the mistake mass of failed runs** (Theorem 1). Let a protocol ask the human for one step of each run, drawn from a distribution q over steps. Then the expected sum, over rounds, of q(steps where the imitator erred) is at most K.
   * Chained imitation draws the step uniformly, so a failed run costs it 1/(fraction of its steps that are mistakes).
   * The factor n is the worst case: a run with a single mistake.

3. **The assumption: deficits persist.** Write (C_r) for: from any state the imitator reaches with r steps to go, the human's own continuation still succeeds. In words: the human could still rescue the imitator's work within its last r steps. By a hybrid argument, every failed run then has a mistake among its last r steps (Lemma 2).
   * This asks nothing new of the human: no check, no verdict, no preservation.
   * It is a property of the human's ordinary task steps on the imitator's states, which chained imitation has to learn anyway.

4. **The protocol: end-weighted chained imitation** (Theorem 3). With probability 1/2 ask the human for a uniformly random step of the run; otherwise for the step at distance d from the end, with probability proportional to 1/(d+1).
   * *Always:* at most 2n·K failed runs in expectation, chained imitation's bound up to the factor 2.
   * *In general:* a failed run whose last mistake is at distance d from the end costs at most 2·min{n, (d+1)·H_n}, where H_n ≈ ln n.
   * *Under (C_r):* at most 2r·H_n·K failed runs, so 2r·H_n·K/ε task queries for failure ε on i.i.d. problems.
   * *Asking only at the last step:* under (C_1) this gives K/ε. Without (C_1) there is no guarantee: on silent humans it never learns.

5. **The question's "first time the run goes off track", without a check** (Proposition 4). Suppose also that the imitator's mistakes, once they start, continue to the end of the run.
   * Then binary search *with task queries* finds the first mistake in ⌈log₂ n⌉ queries: the human's own next step at a state serves as the check.
   * This repairs the cause of the failure rather than its symptom at the end. In E3 it makes the runs exactly right.

6. **Is persistence true of humans?**
   * *Where it is plausible.* A researcher who has an insight bearing on the problem, handed a draft past the point where the insight belongs, will plausibly use it or add it. Deficits that cost the run its success are usually of this kind.
   * *Where it fails:*
     * errors the human would not notice while working, such as a wrong lemma it would build on;
     * deficits whose repair takes much work, which make r large.
   * *When it fails, the cost degrades gradually* (Theorem 3), and never beyond twice chained imitation's bound.
   * *Scaffold design can encourage it.* Each step's instructions can say: "if this draft lacks anything you would have contributed by now, add it first."
   * *How it relates to the check of the first note.* Persistence is the human reacting to what is missing through its work instead of through a verdict, so it is the same kind of capability exercised in a weaker form.

7. **The other route: no rare knowledge.** If the human is *isolated*, meaning that no simpler function agrees with it except on a set of small measure, then induction over isolated hypotheses pins the human at every input after O((K + log(1/η))/δ) i.i.d. queries (Theorem 9 of [`../ultranatural/note.md`](../ultranatural/note.md)). Runs of every length are then right. But the hidden-insight humans are not isolated at any useful scale, and real humans' rarely used knowledge is of exactly that kind. Isolation assumes the hard case away rather than handling it.

8. **Experiment E3** (Section 6) uses the hidden-insight class with m = 100 problems, failure target 2%, and n from 16 to 1024. It compares the silent humans with *catch-up* humans, who write their insight at any later step at which the state lacks it.
   * *Silent humans.* Chained imitation needs 4,970 to 316,000 task queries, in proportion to n. End-weighting needs 1.2 to 1.5 times that. Asking only at the last step never learns.
   * *Catch-up humans.*
     * Asking at the last step needs 300 to 350 task queries at every n.
     * End-weighting needs 510 to 800.
     * Chained imitation needs 1,640 to 3,370. A deficit with persistence makes mistakes dense, so chained imitation no longer pays n per failure; the problems whose insight comes late still cost it up to n each.
   * *Bisection with task queries* makes the runs exactly right, at log₂ n more task queries per insight: 510 to 820 in total.

9. **All protocols in both notes.**

   | the human is asked for | assumption about the human | task queries | other queries |
   |---|---|---|---|
   | task steps (chained imitation) | none | n·K/ε; about n·K/(ε log(n/ε)) needed on a hard class | none |
   | task steps near the end (this note) | none / deficits show in the last r steps | at most 2n·K/ε / 2r·H_n·K/ε | none |
   | task steps at the last step (this note) | deficits show at the last step | K/ε | none |
   | task steps, and a check of final states | the human's runs pass | n·K | O(K log(K/δ)/ε) looks |
   | task steps, and a check of any state | the check is preserved | K | O(K log(K/δ)/ε) looks, O(K log(n/ε)) bisection checks |
   | task steps at i.i.d. inputs | isolation: no rare knowledge | O((K + log(1/η))/δ) | none |

## 1. Setting

Everything is as in Section 1 of [`note.md`](note.md):
* a deterministic human P;
* runs x₀, …, xₙ;
* a prior w with K(P) = log₂(1/w(P));
* the majority decoder G_D;
* Lemma 1 there: at most K(P) task queries ever land on a mistake of the current decoder.

Success is now a property of the final state: a run *succeeds* if its final state is good. For example, it is the human's own final state, or it passes some test that the human's own runs pass. Whatever the notion, if the decoder's run fails and the human's own run succeeds, the two runs differ. By the first-divergence observation of the first note, the decoder then makes at least one mistake on its own run.

For a decoder G and a problem x₀ with decoder run x′₀, …, x′ₙ, let
* M ⊆ {0, …, n−1} be the set of steps k at which G makes a mistake on its own run, G(x′_k) ≠ P(x′_k);
* the *hybrid* H_k be the run that follows the decoder for k steps and then the human: x′₀, …, x′_k, P(x′_k), P(P(x′_k)), …, up to step n.

H₀ is the human's run and Hₙ is the decoder's.

## 2. What a protocol pays: the mistake mass

**Theorem 1.** In round t, a problem x₀ᵗ arrives, in any order and possibly chosen by an adversary that has seen the past. The protocol runs the current decoder G_t on it and task-queries the decoder's state at a step k_t drawn from a distribution q_t on {0, …, n−1}. The distribution q_t may depend on the past and on the run. Let M_t be the mistake set of run t. Then

  E Σ_t q_t(M_t) ≤ K(P).

*Proof.* Given the past and x₀ᵗ, the query of round t lands on a mistake with probability q_t(M_t). By Lemma 1 of the first note, at most K(P) queries ever do. ∎

For uniform q, as in chained imitation, the summand is |M_t|/n. So a failed run costs chained imitation the reciprocal of the fraction of its steps that are mistakes. The bound n·K of the first note's Proposition 2 is this at its worst: a failed run with a single mistake. In the hidden-insight class every failed run has a single mistake, because the human is silent: on the decoder's states after the missed insight, the human also writes nothing.

**Lemma 2 (where a failed run must have a mistake).** If the hybrid H_{n−r} succeeds and the decoder's run Hₙ fails, then the decoder makes a mistake at some step k with n − r ≤ k < n.

*Proof.* Some k in [n−r, n) has H_k succeeding and H_{k+1} failing. If x′_{k+1} = P(x′_k), then H_{k+1} and H_k are the same sequence from step k+1 on, so they end in the same state. Hence x′_{k+1} ≠ P(x′_k), a mistake at k. ∎

**Assumption (C_r): deficits can still be repaired in the last r steps.** In every round, the hybrid H_{n−r} succeeds: from the state the decoder reaches with r steps to go, the human's own r steps end well.

By Lemma 2, under (C_r) every failed run has a mistake among its last r steps. (C_r) quantifies over the decoder's states, as recoverability does in DAgger (Ross, Gordon and Bagnell 2011).
* *A sufficient condition on the human alone:* from *every* state with r steps to go, its continuation ends well. That is reasonable when r steps of work are enough to finish from any draft. It is unreasonable when the task needs much more work than r steps, because a bad enough draft cannot be rescued.
* *The intended reading* is in between: the decoder's states contain most of the right work, and what they lack is what the human knows and would contribute when it notices it is missing.

## 3. End-weighted chained imitation

**Protocol EW.** Chained imitation with the step drawn from

  q_EW(k) = (1/2)·(1/n) + (1/2)·1/((n − k)·H_n),  k = 0, …, n−1,

where H_n = 1 + 1/2 + … + 1/n. The step at distance d from the end (k = n−1−d) gets probability at least 1/(2(d+1)H_n).

**Theorem 3.** For every sequence of problems, with d_t the distance from the end of the last mistake of run t when run t fails:

  E Σ_t 1[run t fails] · max{ 1/(2n), 1/(2(d_t+1)·H_n) } ≤ K(P).

In particular:
* (a) the expected number of failed runs is at most 2n·K(P), chained imitation's bound up to the factor 2;
* (b) if (C_r) holds in every round, the expected number of failed runs is at most 2r·H_n·K(P). For i.i.d. problems, stopping at a uniformly random round among the first N gives expected failure probability at most 2r·H_n·K(P)/N, so N = 2r·H_n·K(P)/ε task queries suffice;
* (c) if r is known, the uniform half can be replaced by the last r steps, which gives 2r·K(P). Asking only at the last step, under (C_1), gives K(P) failed runs and K(P)/ε task queries.

*Proof.* On a failed run t, q_EW(M_t) ≥ (1/2)·|M_t|/n ≥ 1/(2n). It is also at least the weight of the last mistake, which is at least 1/(2(d_t+1)H_n). Apply Theorem 1. For (b), (C_r) and Lemma 2 give d_t ≤ r−1. The rest is as in the first note's Proposition 2. ∎

**What the theorem says about the per-step question.** Slide 30 of the talk asks whether 99.9% per step is enough. The answer depends on where the remaining mistakes sit, not on how many there are.
* Mistakes that persist to the end of the run are cheap to find: with end-weighting they cost about ln n each, whatever n.
* Isolated mistakes in the middle of a run, after which the human carries on as if nothing were wrong, cost n each, and Theorem 3 of the first note shows they must.
* Chained imitation also benefits from persistence when deficits start early, because they then make many steps wrong. A deficit that starts late leaves few mistakes, and costs chained imitation up to n, even under (C_1). End-weighting removes that worst case at the price of the factor 2.

**On the choice of weights.**
* The harmonic weights are what one uses when r is unknown. They lose a factor H_n against knowing r.
* A schedule that guesses r by doubling would lose only a factor of about log r; this note does not pursue it.
* Any weights with a uniform floor of 1/(2n) keep the worst-case guarantee.

## 4. The first mistake, found with task queries

Asking at the end detects a failed run and teaches something at the end: what the human does on a state that lacks something. To repair the cause, one wants the step at which the run first went wrong, which is the question's second idea. Without a check, the human's next step can play that role.

**Proposition 4.** Suppose that on the decoder's run the mistake set M is an up-set: if G errs at step k, it errs at every later step. Then binary search finds the first mistake min M with ⌈log₂ n⌉ task queries, each at a state x′_j of the run and each compared with x′_{j+1}. This starts from a mistake at the last step, which a last-step query has found.

*Proof.* The predicate "j ∈ M" is monotone in j, and one task query at x′_j decides it. ∎

**When the up-set condition holds.** It holds for a decoder that lacks something the human keeps contributing at every later step, as in the catch-up class below. It fails for inconsequential mistakes, after which the decoder is right again; for the bound of Theorem 3 any mistake is as good as the first.

**What it buys.** In E3, finding the first mistake makes the decoder's runs exactly right, at about log₂ n extra task queries per insight. Asking only at the end makes the final states right, but leaves most runs differing from the human's along the way.

## 5. Persistence and the hard class

The hidden-insight class of the first note, and its *catch-up* version, differ only in what the human does on a state that lacks the insight at a step j > t_p:
* *Silent:* P(p, j, ⊥) = (p, j+1, ⊥). The human carries on without it.
* *Catch-up:* P(p, j, ⊥) = (p, j+1, k_p). The human writes the insight it would have had by now.

Both classes have the same complexity, the same rare, problem-specific knowledge, and the same unpredictable steps.
* The silent class needs Ω(n·K/(ε log(n/ε))) task queries for any protocol (first note, Theorem 3).
* The catch-up class satisfies (C₁), and asking at the last step learns it with one task query per insight met: K/ε overall, independent of n.

So what makes chained imitation's factor n necessary is not that the knowledge is rare or problem-specific. It is that a deficit, once the run is past it, leaves no trace in the human's later behaviour.

**For real humans,** this splits the question "is chained imitation enough?" in two.
* *Does knowledge that matters keep showing?* If the human, working on a draft, keeps reacting to what it knows should be there, then the n factor is not needed, and end-weighting removes it. Insights that change the direction of the work are of this kind.
* *What about deficits that fade silently?* An error the human would build on without noticing, or a direction the human would not reconsider once taken, needs n queries per failure. No protocol avoids that without a check, and a check helps only if the human would notice on looking.

**Scaffold design.** The task decomposition can ask for persistence: "before continuing, add anything this draft lacks that you would have contributed by now." Unlike a check, this needs no separate kind of query and no assumption that the human's verdicts are preserved. If the human cannot do it, Theorem 3(a) still bounds the damage at twice chained imitation's cost.

## 6. Experiment E3

Code: [`code/end_weighted.py`](code/end_weighted.py); outputs: [`results/end_weighted_summary.json`](results/end_weighted_summary.json) and [`results/end_weighted.out`](results/end_weighted.out).
* *Setup.* The hidden-insight class with m = 100 problems and η = 1/2. Each problem's posterior is exact, under the class prior.
* *Target.* The failure probability of the decoder's final state on a fresh problem must be at most 2%; it is computed exactly after every run.
* *Humans.* There are 10 random humans per setting, the same at every n as in E1.
* *Columns.* "Run differs" is the probability, at the end, that the decoder's run differs from the human's somewhere.
* *Caps.* Runs were capped at 100·m·n for CI and EW and at 200·m for LAST and BIS.

Task queries are means over 10 humans until the final-state failure is at most 2% (all reached it except LAST on silent humans). In parentheses: the probability, at the end, that the decoder's run differs from the human's anywhere.

| humans | n | CI: task (run differs) | EW: task (run differs) | LAST: task (run differs) | BIS: task (run differs) |
|---|---|---|---|---|---|
| silent | 16 | 4,967 (0.02) | 5,939 (0.02) | never: 0.46 at the cap | — |
| silent | 64 | 18,085 (0.02) | 26,810 (0.02) | never: 0.50 at the cap | — |
| silent | 256 | 76,929 (0.02) | 101,924 (0.02) | never: 0.50 at the cap | — |
| silent | 1024 | 316,170 (0.02) | 468,305 (0.02) | never: 0.49 at the cap | — |
| catch-up | 16 | 1,714 (0.21) | 805 (0.36) | 311 (0.48) | 506 (0.02) |
| catch-up | 64 | 1,677 (0.43) | 702 (0.47) | 300 (0.51) | 595 (0.02) |
| catch-up | 256 | 1,641 (0.49) | 514 (0.50) | 334 (0.50) | 721 (0.02) |
| catch-up | 1024 | 3,370 (0.48) | 559 (0.49) | 348 (0.49) | 817 (0.02) |

* **Silent humans.** End-weighting costs 1.2 to 1.5 times chained imitation, within the factor 2 of Theorem 3(a). Asking only at the last step never learns: the last step is never a mistake, so failure stays at the fraction of problems with an insight.
* **Catch-up humans.**
  * Asking at the last step makes one task query per run, and every query at a problem with an unfound insight finds it. About 300 to 350 runs are needed to meet all but two of the problems, at every n.
  * End-weighting needs about 1.5 to 2.5 times as many.
  * Chained imitation needs 1,640 to 3,370. A problem whose insight comes at step t costs it about n/(n−t) visits, H_n ≈ ln n on average. But that is heavy-tailed, and the stopping rule waits for all but two problems, so the cost is set by the few problems whose insight comes late. These are the failed runs with few mistakes, which Theorem 3 charges at (d+1)·H_n instead of n.
* **Runs exactly right.** Only bisection with task queries (BIS) makes the runs exactly right. The other protocols get the final state right but leave most runs differing from the human's at the step where the insight is written.

## 7. Open

1. **A sharper weighting when r is unknown:** at most a factor of about log r over knowing r, instead of H_n.
2. **Deficits that show up later, but not necessarily at the end.** Theorem 3's per-round form charges the distance of the *last* mistake from the end. A weaker condition, a mistake somewhere in the last r steps with probability ρ, is covered with a factor 1/ρ. Whether some other natural notion of persistence gives better weights is open.
3. **Measuring persistence.** Persistence is an empirical property of how people work on drafts that are not their own. It could be measured directly: hand researchers drafts with a deliberately removed key idea or a planted error, and see whether their next round of work restores or reacts to it.
4. **Stochastic humans,** as in the first note.
