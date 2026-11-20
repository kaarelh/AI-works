# Which properties of the human's runs does chained imitation keep?

*Chained imitation's run is the human's own process with the steps it gets wrong replaced: at every other step it does what the human would do from the state it is in. So it keeps every property of the human's runs that survives a small fraction of replaced steps. If a property survives any ρ fraction of replaced steps, chained imitation's runs lack it in at most K/ρ rounds in total, for every such property at once and with no factor n. "Is a nice run that solves the problem" is such a property for some tasks and not for others, and which is a question about the human and the task alone. The part of that question one can be sure of covers replaced steps that are junk or a harmless variation. The part one cannot be sure of is replaced steps placed exactly where the human knew something the data never showed.*

A third research note by Claude (Anthropic), following [`note.md`](note.md) and [`without-a-check.md`](without-a-check.md), in response to a further question from Kaarel Hänni. Draft; see the README for verification status. No human has checked the mathematics.

## The question

The second note's condition (C_r) asks, relative to the learner, whether the human could still repair the imitator's state in the last r steps. Hänni found it hard to think about, and asked two things:
* conditions that give the result and that one can be pretty sure are true of humans;
* as intermediate progress, a scheme that in some sense preserves most properties of the human's task-decomposition runs, so that to the extent that "is a nice run that solves the problem" is generic, we should be happy.

## Answers in brief

1. **The scheme is chained imitation itself, read correctly.**
   * The decoder's run is the human's process with some steps replaced. At a step where the decoder makes no mistake it does exactly what the human would do from the current state, even if that state already contains earlier replaced steps.
   * So any property that survives a few replaced steps carries over from the human's runs to the decoder's, as long as the decoder makes few mistakes per run. Chained imitation's per-step guarantee is exactly a guarantee on mistakes per run.

2. **Theorem 1: robust properties are kept, without a factor n.**
   * *Definition.* A property Φ of runs is *ρ-robust* if, whenever the human's run on a problem has Φ, so does every run of the human's process on that problem in which at most ρn steps are replaced by arbitrary outputs, chosen adaptively.
   * *Bound.* Chained imitation's runs lack some ρ-robust property that the human's run has in at most K/ρ rounds, in expectation over any sequence of problems. This holds simultaneously for all ρ-robust properties, and gives failure probability at most K/(ρN) after N queries on i.i.d. problems.
   * *Graded version.* For a score that loses at most c/n per replaced step, the expected losses add up to at most c·K.
   * *Fragile properties.* A property that one replaced step can destroy has ρ < 1/n, and the bound becomes the familiar n·K.
   * *The per-step question.* Slide 30 asks whether 99.9% per step is enough. It is enough for exactly the properties that survive 0.1% of replaced steps.

3. **E4: the same runs, judged by a fragile and by robust properties.** The human is E2's rule-based human, with 40 humans per n and target 2%.
   * *Every step right* (fragile): chained imitation needs 810, 843 and 1,104 task queries at n = 16, 64 and 256.
   * *At most 20% of steps wrong:* 38, 22 and 17.
   * *At most 5% of steps wrong:* 142 and 93 at n = 64 and 256. At n = 16, 5% of a run is less than one step, so this is the fragile case.
   * Robust properties get *cheaper* as runs get longer, because the fraction of wrong steps concentrates.

4. **The question is now about the human and the task, not the learner.** Whether "a nice run that solves the problem" is ρ-robust does not mention the imitator. It can be thought about directly ("would this project survive if 2% of its work packages were botched?"), and measured, by replacing a fraction of the work packages of real research projects.

5. **What one can be sure of, and what not.** The replaced steps of a decoder are of four kinds.
   * *(a) Junk:* text that is visibly not work on the problem. I am confident that a careful human, given an append-only log with some slack in the budget, ignores it, and that each such step costs at most one step of the budget. Here *append-only* means steps add to a log and cannot delete, and *slack* means more steps than the human needs.
   * *(b) Different but fine:* another reasonable approach or presentation. I am fairly confident that research processes survive a few of these; collaborators supply them all the time.
   * *(c) Plausible but wrong:* a subtly false lemma, or a misleading result. Survived only if later work catches it or routes around it. Not something I am sure of; it depends on how much cross-checking the task decomposition has.
   * *(d) A missing decisive step:* the step where the human would have had the key idea, replaced by ordinary work. Survived only if the human would still have the idea later. This is the hard class of the first note.

6. **The catch: where the replacements fall.**
   * A decoder's replaced steps are not placed at random. They fall exactly where the human knows something that the data have not shown, which is where kinds (c) and (d) live.
   * So the robustness needed is against *adversarially placed* replacements, and that is the part I cannot vouch for.
   * Robustness to (a) and (b) is what I can be confident of, and it buys the theorem only for mistakes of those kinds. Those come from noise and superficial overfitting, not from missing knowledge.
   * Missing knowledge that is rarely displayed and decisive remains the obstacle, as Theorem 3 of the first note shows. I know of no condition that rules it out and that I would be sure of for real research.

7. **Persistence helps here too.** A deficit that persists makes the decoder wrong at every later step. Its replaced steps are then dense, so a ρ-robust property survives only if the deficit starts in the last ρn steps. The rounds where it does not survive have many mistakes, and Theorem 1 charges them at most 1/ρ each. Only deficits that are decisive and silent, or that start late, produce failures with few mistakes.

8. **A Bayesian reading of "generic"** (Proposition 2). Suppose the imitator samples one hypothesis from the posterior per run. Then the probability that its run has a property Φ equals the learner's own posterior probability that the human's run has Φ, for every Φ, given the data.
   * So the imitator's run is nice exactly as often as the learner, from what it has seen, believes the human's run is nice.
   * Averaged over humans drawn from the prior, this matches the true frequency.
   * For a particular human it falls short exactly when the human's niceness depends on something the human has not shown.

## 1. The observation

Use the setting of [`note.md`](note.md), Section 1: a deterministic human P, runs of n steps, prior w with K(P) = log₂(1/w(P)), and the majority decoder G_D. Lemma 1 there says that at most ⌊K(P)⌋ task queries ever land on a mistake of the current decoder.

A *replacement pattern* chooses, at each step of a run, adaptively, whether to replace the human's output there by an arbitrary output. A *corrupted run* is a run of the human's process under such a pattern: at unreplaced steps the next state is P(current state), and at replaced steps it is whatever the pattern chooses.

**Observation.** The decoder's run x′₀, …, x′ₙ is the corrupted run whose replaced steps are exactly the decoder's mistake set M = {k : G_D(x′_k) ≠ P(x′_k)}. At every other step x′_{k+1} = G_D(x′_k) = P(x′_k).

So the decoder's run is the human's process with |M| replaced steps. The first note's Proposition 2 used only that a failed run has |M| ≥ 1. That is the right count for properties that one replaced step can destroy, and too pessimistic for the rest.

## 2. Robust properties are kept

**Definition.** A property Φ of runs (a predicate on a problem and a run) is *ρ-robust for P* if, for every problem x₀ whose human run has Φ, every corrupted run from x₀ with at most ⌊ρn⌋ replaced steps also has Φ. ρ-robust properties are closed under conjunction.

**Theorem 1.** Run chained imitation: in each round t, on a problem x₀ᵗ chosen in any way, possibly by an adversary that has seen the past, run the current decoder and task-query a uniformly random step of its run. Let B_t be the event that the decoder's run on x₀ᵗ lacks some ρ-robust property that the human's run on x₀ᵗ has. Then

  E Σ_t 1[B_t] ≤ K(P)/ρ.

On i.i.d. problems, stopping at a uniformly random round among the first N gives a decoder that loses some ρ-robust property of the human's runs with expected probability at most K(P)/(ρN).

*Proof.* By the Observation, on B_t the decoder's run is a corrupted run with more than ρn replaced steps, so |M_t| > ρn. Given the past and x₀ᵗ, the query lands on a mistake with probability |M_t|/n > ρ. Lemma 1 bounds the expected number of queries landing on mistakes by K(P). Hence ρ·E Σ_t 1[B_t] ≤ K(P). The i.i.d. statement follows as in the first note's Proposition 2. ∎

**Graded version.** Let S be a score of runs in [0, 1]. Suppose every corrupted run from x₀ with j replaced steps scores at least S(human run from x₀) − c·j/n. Then the expected sum over rounds of the score lost by the decoder's runs is at most c·K(P).

*Proof.* The loss in round t is at most c·|M_t|/n, which is c times the probability that the query lands on a mistake. ∎

**Remarks.**
* *Robust over all replacements.* Robustness is required against every replacement pattern, because Theorem 1 holds for every decoder. A weaker robustness, against the replacements a particular learner can make, suffices for that learner; but describing those replacements is the hard part (Section 3).
* *Fragile properties.* For a property that one replaced step can destroy, ρ must be below 1/n and the bound is n·K(P). On the hidden-insight class, "ends with the right insight" is such a property: replacing the single step where the insight comes destroys it.
* *Relation to the second note.* The second note's condition (C_r) controls *where* a failed run's mistakes are. Robustness controls *how many* there must be. Robustness is a property of the human and the task alone, and it needs no change to the protocol.

## 3. Is "a nice run" robust? What one can be sure of

Whether Φ = "a nice run that solves the problem" is ρ-robust, and for what ρ, is a question about the human's process: would the project survive if a ρ fraction of its steps, chosen by an adversary, were replaced? The replaced steps of a decoder are of four kinds:

| kind of replaced step | example | survived by a careful human? |
|---|---|---|
| (a) junk | text that is visibly not work on the problem | yes, given an append-only log and slack in the budget: ignored, at the cost of one step |
| (b) different but fine | another reasonable approach, other notation | very likely: collaborators supply such steps all the time |
| (c) plausible but wrong | a subtly false lemma, a misleading result | only if later work catches it or routes around it |
| (d) missing decisive step | the step of the key idea, replaced by ordinary work | only if the human would still have the idea later |

**What I am confident of.**
* With a scaffold that appends to a log (nothing can be deleted) and gives the human more steps than it needs, (a) is survived: a human ignores visible junk.
* So is (b), for a ρ well below the slack.

**What I am not confident of.** The difficulty is not the kinds of replacement but where they fall.
* Theorem 1 needs robustness against adversarially placed replacements, because a decoder's mistakes fall exactly where the human knows something the data have not shown. That is where (c) and (d) live: a wrong lemma at the one place it matters, a missing idea at the step where it would have come.
* Robustness against *randomly* placed replacements of any kind is much more plausible for research projects, but it is not what Theorem 1 uses.
* A decoder's mistakes are randomly placed only when they come from noise or superficial overfitting, not from missing knowledge.

**The remaining obstacle.** Knowledge that is decisive for a run and rarely displayed is what makes the first note's lower bound work. I do not know a condition that excludes it which I would be sure of for real research.

**Persistence, again.** If the human, working on a state that lacks something it would have done by now, does it (the catch-up humans of the second note), then a missing decisive step makes the decoder wrong at every later step: dense replacements. Those rounds have |M_t| ≥ ρn unless the deficit starts in the last ρn steps, and Theorem 1 charges them at most 1/ρ each. Only deficits that are decisive and silent, or late, produce failures with few mistakes.

**Measuring it.** Unlike (C_r), robustness can be measured on people without any imitator. Take research projects done in steps; replace a fraction of the steps by another competent person's work, or by deliberately subtly wrong work, or by blanks; let the original team continue; compare outcomes. Which kinds and fractions a project survives is exactly what Theorem 1 needs.

## 4. A Bayesian reading of "generic"

**Proposition 2.** Let the imitator, for a problem x₀, sample one hypothesis ν from the posterior ξ_D and output ν's run. Then for every property Φ and every data set D,

  Pr[the imitator's run on x₀ has Φ | D] = ξ_D({ν : ν's run on x₀ has Φ}),

the learner's posterior probability that the human's run on x₀ has Φ. If the human is drawn from the prior w and the data are its answers to any query rule, then averaged over humans the imitator's runs have Φ exactly as often as the human's.

*Proof.* The first identity is the definition of posterior sampling. For the second, given the data the human's parameter and the sampled hypothesis have the same law, the posterior. ∎

So the imitator's run is nice exactly as often as the learner, from what it has seen, believes the human's run is nice. "Niceness is generic" in this reading means: niceness is implied by what the human has displayed, so that most hypotheses consistent with the data are nice. For a particular human, the imitator falls short exactly when the human's niceness rests on something it has not displayed: rarely shown, decisive knowledge, again. Proposition 2 adds no protection against that; it only says the imitator is no less nice than the learner's own beliefs about the human.

## 5. Experiment E4

**Setup.**
* *Code and outputs.* [`code/robust_runs.py`](code/robust_runs.py); outputs in [`results/robust_runs_summary.json`](results/robust_runs_summary.json) and [`results/robust_runs.out`](results/robust_runs.out).
* *The human.* The rule-based human of E2 in the first note: two rules of each size 1, …, 9 on a 12-bit content. No check is used.
* *Training.* Chained imitation, one task query at a random step per run, with 40 humans per n.
* *Measurement.* After each run, the exact failure probability over all 4,096 problems under three properties of the same runs: every step right (ρ = 0), at most 5% of steps wrong (ρ = 0.05), and at most 20% wrong (ρ = 0.2).
* *Stopping.* Each count is the number of task queries until that failure probability first reaches 2%. This is an oracle stopping rule that measures cost.
* *The properties are the simplest robust ones.* "At most ρn steps differ from the human's" is ρ-robust by definition, so E4 shows the mechanism of Theorem 1, not that any particular notion of niceness is robust.

| property | n = 16 | n = 64 | n = 256 |
|---|---|---|---|
| every step right | 810 ± 67 (median 703) | 843 ± 90 (649) | 1,104 ± 106 (995) |
| at most 5% of steps wrong | 810 ± 67 (703) (⌊0.05·16⌋ = 0: same as above) | 142 ± 11 (146) | 93 ± 8 (82) |
| at most 20% of steps wrong | 38 ± 3 (35) | 22 ± 2 (21) | 17 ± 1 (15) |

**What the numbers show.**
* *The fragile property gets more expensive with n.* The rarest rules fire at about one step per run, so a failed run has a single mistake.
* *The robust properties get cheaper with n.* The fraction of a run's steps that are wrong concentrates around the decoder's per-step error rate. Once that rate is below ρ, almost every run keeps the property.
* *Caveat: E2's mistakes are favourable.* They are missing tokens, not misleading content. And E2's rules are reused across problems, so its rare knowledge is not decisive in the way the hidden insights of the first note are. On that class, "ends with the right insight" is fragile, and no ρ > 0 helps.

## 6. Open

1. **Robustness against restricted replacements.** Which replacements a given learner can actually make? If they could be shown to be "human-like" (kinds (a) and (b)), robustness against those alone would suffice, and that is more believable. The KWIK lower bounds suggest this cannot be guaranteed cheaply in general.
2. **Scaffolds that make niceness robust against adversarial placement.** Independent re-derivation of key results and comparison of the two is the natural candidate. It defeats placement only if the imitator's errors in the two derivations are not the same, and errors from missing knowledge usually are.
3. **The empirical question of Section 3:** how robust real research projects are to each kind of replaced step, at what fractions, and with what placement.
