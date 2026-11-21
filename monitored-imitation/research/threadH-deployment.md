# Thread H: deploying an imitator that asks, and learners other than Solomonoff

*Working note by Claude (Anthropic), for version 3 of [`../slack-imitation.md`](../slack-imitation.md). Draft; not refereed.*

## Answers in brief

1. **A deployment theorem for ask-before-committing (Theorem H1).** Run the epochs of SI-PAC, but end an epoch also at the first *unconfident* step of any run (top label mass below 1 − α), asking the human there.
   * With probability 1 − δ, the output is a frozen imitator for which a fresh problem's run is unconfident somewhere, fails the check, or fails, with probability at most ε.
   * Deployed, it outputs the runs that are confident throughout (failure probability ≤ ε) and flags or asks on the rest (≤ ε of problems).
   * Bounded setback is needed only at confident mistakes.
   * The cost is O((K/α + K)·(D+1)·log(K/(αδ))/(ρε)) task queries, a factor about 1/α more than SI-PAC, because every ask ends an epoch.
2. **Other learners (Proposition H2).** Every result of slack-imitation.md except Proposition 5 holds for any online learner whose log-loss regret against P is at most R on every adaptively chosen sequence, with K replaced by R, decoding by the learner's mode. Proposition 5 also needs the learner's predictions to depend only on the set of data. Bayes mixtures over any hypothesis class containing P have both properties, with R = log₂(1/w(P)) in that class. So "K" can be the description length of the human in whatever class the learner uses, provided the class contains the human exactly.
3. **What does not generalize.** If no hypothesis computes P exactly, the regret against a deterministic P is unbounded, and nothing here applies. This is the realizability assumption of all the notes.

## H1. Deploying an imitator that asks

**Protocol SI-ABC-PAC(ε, δ, α).**
* *Epochs.* The data D_i are frozen within epoch i = 1, 2, …, and G_i is their majority decoder. Let γ = max{1, (σ+1)/(D+1)}/n ≥ ρ/(D+1) and m_i = ⌈ln(i(i+1)/δ)/(γε)⌉.
* *Rounds.* In each round, draw a problem and run G_i on it.
  1. If at some step k the top label's mass under D_i is below 1 − α, stop the run, ask the human at x′_k, and add the answer to the data. This ends the epoch.
  2. Otherwise, if the check is used and the final notebook fails it, bisect to the flip and task-query it.
  3. Otherwise, task-query a uniformly random step.

  The round is a *hit* if the queried step is a mistake. A hit adds its answer first and the epoch's other answers after it, and ends the epoch.
* *Stopping.* After m_i consecutive rounds with neither an ask nor a hit, stop and output G_i.
* *Deployment.* On a new problem, run the output imitator.
  * If every step is confident (top mass ≥ 1 − α), output the run.
  * Otherwise flag the problem, or ask the human at the unconfident steps.

**Theorem H1.** Let problems be i.i.d., with τ(x₀) ≤ n₀ almost surely, and (M1), (M2), (M-prefix) if the check is used. Assume (B_D) at the confident mistakes of runs that pass the check. Then:
* (a) on every path, the protocol asks at most K/log₂(1/(1−α)) times, has at most K/max{1, log₂(1/α)} hits, and so runs at most E_max := K/log₂(1/(1−α)) + K/max{1, log₂(1/α)} + 1 epochs;
* (b) with probability at least 1 − δ, the output imitator's run on a fresh problem has an unconfident step, fails the check, or fails S, with probability at most ε;
* (c) the number of rounds, each with at most one task query, is at most Σ_{i ≤ E_max} m_i ≤ E_max·⌈(D+1)·ln(E_max(E_max+1)/δ)/(ρε)⌉.

*Proof.*
* *(a).*
  * *Asks.* An ask's answer had mass below 1 − α under the data at the time, so it lowers the potential Φ (slack-imitation.md §1) by more than log₂(1/(1−α)).
  * *Hits.* A hit happens only in a round with no ask, so every step of that run was confident under D_i, with top mass ≥ 1 − α. A mistake there has ξ_{D_i}(P(x)) ≤ min{α, ½}, so the hit's answer, added first, lowers Φ by at least max{1, log₂(1/α)}. This includes the flip of a run that fails the check, which by (M2) is a mistake.
  * *The count.* The epoch's other answers come after it and never raise Φ. Since Φ starts at most K and stays ≥ 0, both counts follow. Every epoch but the last ends with an ask or a hit.
* *(b).* Fix an epoch whose frozen imitator has p := Pr[unconfident step, or fails the check, or fails S] > ε. Split p as p_u + p_c + p_s, by the first of the three that applies: unconfident somewhere; confident throughout and failing the check; confident throughout, passing the check and failing S.
  * An unconfident run ends the epoch with certainty.
  * A confident run that fails the check is a hit with certainty.
  * A confident run that passes the check and fails S has all its notebooks passing and all its steps committed. (B_D) at its confident mistakes and Lemma S give at least max{1, (σ+1)/(D+1)} mistakes, so the uniform query hits with probability at least γ.

  Each round therefore ends the epoch with probability at least p_u + p_c + γp_s ≥ γp > γε, independently given the frozen imitator. The epoch survives m_i rounds with probability at most (1−γε)^{m_i} ≤ δ/(i(i+1)). A union bound over epochs gives δ.
* *(c)* follows from (a) and the definition of m_i. ∎

**Remarks.**
* *What is gained over SI-PAC* (Corollary 3 of slack-imitation.md). Bounded setback is needed only at confident mistakes, where the unconfident guesses of thread E's §1 (results, verdicts, plans) do not occur. Each hit is worth log₂(1/α) bits.
* *What it costs.*
  * The epoch count grows from K + 1 to about (ln 2)K/α + K/log₂(1/α) + 1, because every ask ends an epoch and restarts the count.
  * An asker that keeps learning during deployment needs no such restart, but has no PAC theorem here: the majority vote is not monotone in the data, so new answers can make later runs worse (the second note's referee).
* *What deployment does with an unconfident run.* The theorem bounds the probability that one occurs by ε. Flagging it is safe. Asking at it costs at most n task queries per flagged problem, so at most ε·n per problem in expectation, and the answers may be discarded.

## H2. Learners other than Solomonoff

**What the proofs use.** The proofs in slack-imitation.md use the learner only through two facts.
* **(L1) Bounded regret.** For every sequence of correctly labelled data, chosen adaptively, the cumulative log loss Σ_i log₂(1/ξ_i(P(x_i) | x_i)) is at most R. Here ξ_i is the learner's predictive distribution after the first i − 1 data.
* **(L2) Mode decoding.** The imitator outputs a label of largest ξ-mass. So at a mistake, ξ(P(x) | x) ≤ ½.

For the Bayes mixture, (L1) holds with R = K, because the cumulative log loss is log₂(W(∅)/W(D)) ≤ log₂(1/w(P)). (L2) is the majority decoder.

**Proposition H2.** Let the learner satisfy (L1) and (L2). Then:
* note.md's Lemma 1, without-a-check.md's Theorem 1, and slack-imitation.md's Lemma S, Theorem 2, Corollary 3 and Proposition 4 hold with K replaced by R;
* if moreover ξ after data D depends only on the set D (an *exchangeable* learner), Proposition 5 and Theorem H1 hold with K replaced by R.

*Proof.*
* Lemma S does not involve the learner.
* *Lemma 1, Theorem 1, Theorem 2, Corollary 3, Proposition 4.* In each, the data are added in the order the proofs describe: in rounds, a hit first and the other answers after it. Every task query on a mistake contributes at least 1 to the cumulative log loss by (L2), and every other datum contributes at least 0. So (L1) bounds the number of such queries, or its expectation, by R, exactly where the original proofs used K.
* *Proposition 5 and H1.* Their proofs evaluate the hit's loss under the data before the run's later asks, while those asks enter the learner earlier. For an exchangeable learner, the cumulative log loss of a set of data does not depend on the order, so one may list the data in the order the proof needs: asks before the hit, then the hit, then the rest. For a learner that is not exchangeable this step fails, and I do not know whether the result survives. ∎

**Examples.**
* *Bayes mixtures over any class containing P.* They are exchangeable, and R is P's prior code length in that class. For example, a prior over the weights of a fixed network architecture, if some setting of the weights computes P exactly.
* *Mixtures of experts with fixed-share or switching priors.* (L1) holds relative to the best sequence of experts, but such learners are not exchangeable.

**The realizability caveat.** For a deterministic P, a hypothesis that computes P only approximately pays infinite log loss on the first point where it errs. So R is finite only if some hypothesis computes P exactly on every state the protocol visits. All the notes assume this. An agnostic version, with a hypothesis that agrees with P except on a small set of states, would need an analysis in which the imitator's runs visit that set rarely; it is not attempted here.
