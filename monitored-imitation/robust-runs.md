# Which properties of the human's runs does chained imitation keep?

*Chained imitation's run is the human's own process with the steps it gets wrong replaced by its guesses. At every other step it does what the human would do from the state it is in. So it keeps every property of the human's runs that survives those replaced steps.*
* *If a property survives any ⌊ρn⌋ replaced steps, at most n⌊K⌋/(⌊ρn⌋+1) ≤ K/ρ rounds lose it, in expectation, for all such properties at once. That has no factor n for fixed ρ.*
* *But no property of a run's outcome survives arbitrary replaced steps: replacing the last step always spoils it. So conditions on the human alone, with arbitrary replacements, give this only for counting properties such as "most steps are what the human would have done".*
* *For "a nice run that solves the problem", a usable condition has to restrict the replacements to the guesses an imitator actually makes, and that brings the learner back in. I know of no such condition that I would be sure of for real research, because the obstacle, decisive knowledge that the human shows only rarely, plausibly exists there.*

A third research note by Claude (Anthropic), following [`note.md`](note.md) and [`without-a-check.md`](without-a-check.md), in response to a further question from Kaarel Hänni. Draft. One independent AI referee checked every statement and re-ran the experiment; its report and the response are in [`verification/`](verification/). No human has checked the mathematics.

## The question

The second note's condition (C_r) asks, relative to the learner, whether the human could still repair the imitator's state in the last r steps. Hänni found it hard to think about, and asked two things:
* conditions that give the result and that one can be pretty sure are true of humans;
* as intermediate progress, a scheme that in some sense preserves most properties of the human's task-decomposition runs, so that to the extent that "is a nice run that solves the problem" is generic, we should be happy.

## Answers in brief

1. **The scheme is chained imitation itself, read correctly** (Observation, Theorem 1).
   * *The observation.* The majority decoder's run is the human's process with the decoder's mistaken steps replaced by its guesses. At every other step it does exactly what the human would do from the current state, even if that state contains earlier replaced steps.
   * *Robust properties are kept.* Call a property of runs ρ-robust if it survives any ⌊ρn⌋ replaced steps. Chained imitation's runs lose some ρ-robust property that the human's run has in at most n⌊K⌋/(⌊ρn⌋+1) ≤ K/ρ rounds in expectation, over any sequence of problems.
   * *What it does not cover.* The bound has no factor n *for a fixed fraction ρ*. For a property that survives only a fixed *number* j of replaced steps, it is n·K/(j+1).
   * *Which imitators it covers.* It holds for the majority decoder, and for the per-step sampler of the talk with a factor ln 2. It does not hold for an imitator that samples one hypothesis per run: that imitator's mistakes are correlated along the run.

2. **The per-step question.** Slide 30 asks whether 99.9% per step is enough. It bounds the failure of every ρ-robust property by 0.1%/ρ: for example, at most 1% for properties that survive 10% of replaced steps.

3. **The limit: outcomes are never robust to arbitrary replacements** (Lemma 2).
   * Replacing the last step by any output spoils any non-trivial property of the final state. Earlier steps can spoil it too: a careful human can be misled by plausible false content.
   * So the properties that are robust whatever the replacements are essentially counting properties: "at most ⌊ρn⌋ steps differ from what the human would have done", which is the strongest one. Chained imitation keeps those, without the factor n.
   * There is no condition about the human alone, with arbitrary replacements, under which "solves the problem" is robust.

4. **What a usable condition must say.** The decoder's replacements are not arbitrary. They are its best guesses at what the human would do, placed where the data do not determine the human.
   * *When robustness against those guesses is believable:*
     * the guesses fall at effectively random places, as when the decoder lacks knowledge about content that turns up throughout the runs;
     * or they are inconsequential idiosyncrasies: a different notation, another reasonable route.
   * *When it fails:* the guesses fall at a decisive step where the human uses knowledge it shows rarely. That is the hidden-insight class of the first note, where the guess at the insight step is "no insight", and one such guess spoils the run.
   * *It depends on the learner.* Any condition of this kind is relative to the learner, like (C_r), because it is about the decoder's guesses. I know of none I would be sure of for real research.

5. **E4.** The rule-based human of E2, with 40 humans × 5 query seeds per n.
   * *Theorem 1's own quantity.* The expected number of rounds whose run loses the property grows with n for the fragile property "every step right" (121, 287, 575 at n = 16, 64, 256). For "at most 20% of steps wrong" it stays flat (13.2, 13.2, 13.0).
   * *The fragile cost.* The number of task queries until the fragile failure probability reaches 2% does not grow with n here: the target requires every rule at every n tested, and the queried contents are uniform at every n.
   * *Caveat.* E2 is the favourable case of item 4: its mistakes never change the run and are placed by the content sequence, not by the decoder.

6. **A Bayesian reading of "generic"** (Proposition 3). An imitator that samples one hypothesis per run produces runs with a property Φ exactly as often as the learner believes the human's run has Φ.
   * Averaged over humans drawn from the prior, this matches the truth, for properties and problems that do not depend on the human.
   * But that imitator does not have Theorem 1's guarantee. Neither imitator in this note has both.

7. **Bottom line for the two questions.**
   * *A scheme that keeps most properties.* Chained imitation, as it stands, keeps every property that survives its mistakes. It keeps every counting property without the factor n.
   * *Conditions one can be sure of.* For counting properties, none are needed. For "a nice run that solves the problem" I cannot offer one: it has to say that the imitator's guesses fall where they do not matter. That fails exactly for decisive, rarely shown knowledge, which I expect real research sometimes has.

## 1. The observation

Use the setting of [`note.md`](note.md), Section 1: a deterministic human P, runs of n steps, prior w with K(P) = log₂(1/w(P)), and the majority decoder G_D. Lemma 1 there says that at most ⌊K(P)⌋ task queries ever land on a mistake of the current decoder.

A *corrupted run* from x₀ with j replaced steps is a sequence x₀, …, xₙ in which x_{k+1} ≠ P(x_k) for exactly j steps k; at those steps the content is arbitrary.

**Observation.** The decoder's run x′₀, …, x′ₙ is a corrupted run whose replaced steps are exactly the decoder's mistake set M = {k : G_D(x′_k) ≠ P(x′_k)}, with the decoder's guesses as their content. At every other step x′_{k+1} = P(x′_k).

The first note's Proposition 2 used only that a failed run has |M| ≥ 1. That is the right count for properties that one replaced step can spoil, and too pessimistic for the rest.

## 2. Robust properties are kept

**Definition.**
* *ρ-robust.* A property Φ of runs is *ρ-robust for P* if, for every problem x₀ whose human run has Φ, every corrupted run from x₀ with at most ⌊ρn⌋ replaced steps also has Φ.
* *Closure.* ρ-robust properties are closed under conjunctions and disjunctions.
* *The strongest one.* The strongest ρ-robust property is Ψ_ρ = "at most ⌊ρn⌋ steps k have x_{k+1} ≠ P(x_k)". Every ρ-robust property that the human's run has is implied by it.

**Theorem 1.** Run chained imitation with the majority decoder: in round t, a problem x₀ᵗ is chosen in any way, possibly by an adversary that has seen everything before round t but not round t's coin. The current decoder runs on it, and a uniformly random step of its run is task-queried. Let B_t be the event that the decoder's run loses some ρ-robust property that the human's run on x₀ᵗ has, equivalently |M_t| > ⌊ρn⌋. Then

  E Σ_t 1[B_t] ≤ n⌊K(P)⌋ / (⌊ρn⌋ + 1) ≤ K(P)/ρ.

The left-hand bound is n⌊K(P)⌋ for ρ < 1/n, the fragile case. On i.i.d. problems, stopping at a uniformly random round among the first N gives a decoder whose run loses some ρ-robust property of the human's with expected probability at most K(P)/(ρN).

*Proof.* On B_t, |M_t| ≥ ⌊ρn⌋ + 1. Given the past and x₀ᵗ, the query lands on a mistake with probability |M_t|/n ≥ (⌊ρn⌋+1)/n. Lemma 1 bounds the expected number of queries that land on mistakes by ⌊K(P)⌋. The i.i.d. statement follows as in the first note's Proposition 2. ∎

**Which imitators.**
* *The per-step sampler.* For the talk's per-step sampler, Theorem 1 holds with an extra factor ln 2: its expected number of mistakes at a state is 1 − ξ(P(x) | x) ≤ ln 2 · log₂(1/ξ(P(x) | x)).
* *The per-run sampler fails.* It does not hold for an imitator that samples one hypothesis from the posterior per run. The referee's counterexample has K(P) = 1 bit and about 0.37·n bad rounds: once a rare hypothesis is drawn, its mistakes fill the whole run, and catching it removes only its own small mass ([`verification/referee3_theory_checks.out`](verification/referee3_theory_checks.out), §2).

**Graded version.** Let S be a score of runs. Suppose every corrupted run from x₀ with j replaced steps scores at least S(human run from x₀) − c·j/n. Then the expected sum over rounds of the score lost by the decoder's runs is at most c·⌊K(P)⌋.

*Proof.* The loss in round t is at most c·|M_t|/n, which is c times the probability that the query lands on a mistake. ∎

**The per-step question.** A per-step error rate e means E|M|/n = e. By Markov's inequality the run loses a ρ-robust property with probability at most e·n/(⌊ρn⌋+1) ≤ e/ρ. An error rate equal to ρ guarantees nothing: with n = 1000, |M| = 2 half the time and 0 otherwise gives e = 0.001 and fails half the runs at ρ = 0.001.

**"No factor n" needs a fixed fraction.** Theorem 1 removes the factor n for properties that survive a fixed *fraction* of replaced steps as n grows. Whether the number of botched steps a project can survive grows in proportion to its length is part of the hypothesis, not a consequence.

## 3. What is robust, and what is not

**Lemma 2 (outcomes are fragile under arbitrary replacements).** Let Φ depend on the run only through its final state, by a test that some final state fails, and let the human's run have Φ on some problem. Then Φ is not ρ-robust for any ρ ≥ 1/n.

*Proof.* Replace the last step by a final state that fails the test. ∎

The same is true of any property that a late step can spoil, and an append-only log does not change this: a replaced late step can append a plausible wrong conclusion. Earlier steps can spoil outcomes too. A replaced step can contain plausible false content, such as a fake lemma or a misleading result, and careful humans can be misled by it. So, against arbitrary replacements:
* *What is robust:* counting properties (Ψ_ρ and what it implies), and properties that only grow as the log grows, such as "a correct solution appears somewhere in the log". Those are useful only to a reader who can tell good entries from bad ones, which is a check.
* *What is not:* "a nice run that solves the problem", in the ordinary sense, is never robust against arbitrary replacements.

**The decoder's replacements are not arbitrary.** By the Observation, they are the decoder's guesses, at the states where the data do not determine the human. A condition restricted to such replacements is what one would actually need. Its content depends on where the guesses fall and what they are:

| what the decoder's guess is | example | survived? |
|---|---|---|
| an inconsequential idiosyncrasy | another notation, another reasonable route, at a step where nothing hangs on it | yes; projects survive this all the time |
| a plausible wrong result | a subtly false lemma the human would build on | only if later work catches it |
| a missing decisive step | ordinary work at the step where the human would have had the key idea | only if the human would still have it later |

Some remarks on this table.
* *No junk.* In the exact-Bayes model every mistake comes from the data not determining the human at that state. The majority decoder outputs the most probable continuation, so visible junk is its least likely kind of guess.
* *Placement matters as much as kind.* An idiosyncrasy at the decisive step is a missing decisive step.
* *Random placement.* If the guesses fall at effectively random places, as when the decoder lacks knowledge about content that turns up throughout the runs (E2, E4), robustness against randomly placed guesses is enough. That is much more believable for real projects than robustness against adversarial placement.
* *The decisive case.* If the guesses fall where the human uses decisive knowledge it rarely shows, robustness fails. The hidden-insight class of the first note is the clean example, and its lower bound shows that no task-only protocol avoids the cost there in the worst case.

**What one can be sure of.**
* Real projects survive occasional inconsequential idiosyncrasies at random places.
* Whether real research contains decisive knowledge that a human shows only at a few steps, so that an imitator's guesses would fall there, I cannot rule out, and I expect it sometimes does.

A condition that excludes it would be about the learner's guesses, as (C_r) is, and I do not have one I would vouch for.

**Persistence.** For any property, a failure caused by a deficit that persists from step s on has |M| ≥ n − s. So a uniform query catches it with probability at least (n − s)/n, and by the proof of Theorem 1 at most K/ρ rounds in expectation fail through deficits that start before step (1 − ρ)n. Only failures from deficits that are silent, or that start late, can have few mistakes. For the catch-up humans of the second note this is robustness against omissions only, with a problem-dependent ρ: the restricted, learner-relative kind.

## 4. A Bayesian reading of "generic"

**Proposition 3.** Let the imitator, for a problem x₀, sample one hypothesis ν from the posterior w(· | H_D) and output ν's run. Then for every property Φ and every data set D,

  Pr[the imitator's run on x₀ has Φ | D] = w({ν : ν's run on x₀ has Φ} | H_D),

the learner's posterior probability that the human's run on x₀ has Φ.

Suppose further that the human is drawn from the normalised prior w, and that the data are its answers to any query rule, even an adaptive one. Then, averaged over humans, the imitator's runs have Φ exactly as often as the human's, for every property Φ and test problem x₀ fixed independently of the human.

*Proof.* The first identity is the definition. For the second, the query rule's probabilities do not depend on the hypothesis, so given the data the human and the sampled hypothesis have the same law, the posterior. ∎

**What this says.**
* The imitator's run is nice exactly as often as the learner, from what it has seen, believes the human's run is nice. This is the Bayesian version of "niceness is generic".
* It does not apply to properties that mention the human itself, such as "the run is the human's run", for which the imitator falls short.
* It is a statement about averages over humans. The per-run sampler it concerns does not satisfy Theorem 1 (Section 2), so neither imitator in this note has both guarantees.

## 5. Experiment E4

Code: [`code/robust_runs.py`](code/robust_runs.py); outputs: [`results/robust_runs_summary.json`](results/robust_runs_summary.json), [`results/robust_runs.out`](results/robust_runs.out).

**Setup.**
* *The human* is E2's: two rules of each size 1, …, 9 on a 12-bit content. The same 40 humans are used at every n, each with 5 query seeds.
* *Training.* Chained imitation with one uniform-step query per run and no check, until every rule is known.
* *Measurement.* After each run, the exact failure probability over all 4,096 problems under Ψ₀ ("every step right"), Ψ_0.05 and Ψ_0.2. These are the strongest ρ-robust properties, so each row measures all ρ-robust properties at once.
* *Two quantities:*
  * Theorem 1's own: the expected number of rounds, on i.i.d. problems, whose run loses the property;
  * the number of task queries until the failure probability first reaches 2%, an oracle stopping rule.
* *Errors* are standard errors over the 200 runs.

| property | quantity | n = 16 | n = 64 | n = 256 |
|---|---|---|---|---|
| every step right (Ψ₀) | expected bad rounds | 120.8 ± 2.5 | 287.3 ± 7.5 | 575.3 ± 20.8 |
| | task queries to 2% (median) | 807 ± 31 (688) | 833 ± 35 (704) | 891 ± 38 (804) |
| at most 5% of steps wrong (Ψ_0.05) | expected bad rounds | 120.8 ± 2.5 | 54.5 ± 1.5 | 56.5 ± 1.5 |
| | task queries to 2% (median) | 807 ± 31 (688) | 141 ± 5 (130) | 91 ± 3 (80) |
| at most 20% of steps wrong (Ψ_0.2) | expected bad rounds | 13.2 ± 0.3 | 13.2 ± 0.4 | 13.0 ± 0.5 |
| | task queries to 2% (median) | 36 ± 1 (34) | 24 ± 1 (22) | 18 ± 1 (15) |

At n = 16, ⌊0.05·16⌋ = 0, so Ψ_0.05 is the fragile property there.

**What the numbers show.**
* *The fragile property gets worse with n.* Its expected number of bad rounds grows with n: the rarest rules fire in about one step of a run in which they fire at all, so such a run has a single mistake.
* *The robust properties do not.* Their bad rounds stay flat or fall. Their first-passage cost falls with n, because the fraction of a run's wrong steps concentrates around the decoder's per-step error rate.
* *The fragile first-passage cost is about the same at every n.* At every n tested the 2% target needs all 18 rules, and the queried contents are uniform at every n. The referee computed its exact expectation, 851.8 queries.
* *K/ρ is loose here.* K(P) is about 247 bits under E2's prior, but each mistake query reveals a whole rule. So about 15 queries ever land on mistakes, and K/ρ overstates the bad rounds by about a factor 100. E4 does not test the size of the bound.
* *E2 is the favourable case.* Mistakes never change the content sequence, and they are placed by it, not by the decoder: the random-placement regime of Section 3.

## 6. Open

1. **A learner-relative condition for outcomes that one would believe.** Robustness against the decoder's guesses, at the places it makes them, in terms one can check against how research is done.
2. **Random versus decisive placement.** When are an imitator's mistakes effectively randomly placed? A natural guess is "when the human's knowledge is used across many problems and steps". Making that precise, in the spirit of the frequency of display, is open.
3. **An imitator with both guarantees.** Is there one with Theorem 1's bound and Proposition 3's identity?
4. **The empirical question.** How robust real research projects are to inconsequential and to wrong steps at random places, and at decisive places.
