# The learning theory of imitation with compounding errors and interaction: what is proved, and what it gives for a sampler inside a scaffold

*A digest for the "principled human imitation" problem. Questions asked of this digest: how the distance between the trajectory laws (or the performance) of an expert and of a learned policy scales with the horizon and the per-step error, for behaviour cloning under 0-1 loss and under log loss and for interactive methods; what the no-regret guarantee of DAgger says and what it requires; and what a Bayesian learner with cumulative log-loss regret at most K gives when it is used as the no-regret learner in a DAgger-style loop over a task decomposition with L calls, including the number of questions to the human and lower bounds.*

## 0. Access, sources, tags, conventions

**Web access was partial.** Web search worked. Direct download worked for `arxiv.org` (API and TeX sources) and `proceedings.mlr.press`. Not reachable from this session: `papers.neurips.cc`, `proceedings.neurips.cc`, `neurips.cc`, `openreview.net` (browser check; its API is blocked), `people.eecs.berkeley.edu`, `par.nsf.gov`, `rlseminar.github.io`. Consequences:

* Papers with an arXiv version were read in the **arXiv TeX source** (identifier given with each citation). Statements tagged **[read]** are transcribed from that source. Theorem numbers are given only where the source or a citing paper that I read fixes them; otherwise I name the statement.
* Ross and Bagnell (2010) was read in the PMLR PDF (main text; the supplementary material with the proofs was not read). Judah, Fern and Dietterich (2012) was read in the arXiv PDF.
* **Not read:** Rajaraman, Han, Yang, Liu, Jiao and Ramchandran, "On the Value of Interaction and Function Approximation in Imitation Learning" (NeurIPS 2021). I found no arXiv version, and every host that carries it was blocked. It is reported from a search-result snippet of its abstract and from the way two papers that I did read (Foster, Block and Misra; Li and Zhang) describe it. Also not opened: Syed and Schapire (2010), Kääriäinen (2006), Daumé, Langford and Marcu (2009), Joulani, György and Szepesvári (2013); they appear only as described in papers I read, or from memory, and are tagged so.

**Tags.** [read] = read in the source in this session. [read, as described in X] = I read X, and X says this about the cited work. [snippet] = seen only in a search-result snippet. [mem] = from memory, not checked. [own] = my own derivation, a few lines each, unrefereed; the two numerical facts used were checked by a short script.

**Conventions.**

* Project notation (from `research/outline.md`): X, Y countable sets of strings; the human is a sampler P (a function f when deterministic); H a countable class of samplers with weights w, K := log₂(1/w(P)); M_D the mixture after data D; a scaffold Π with horizon L (the largest number of calls in a run; the task text calls it N); Q_A the law of a run answered by A; n the number of questions put to the human in rehearsal; TV total variation; KL in nats; **H² := 1 − Σ√(pq)**.
* The imitation-learning papers write T or H for the horizon, N or n for the number of expert trajectories or of iterations, s (or x) for states, a for actions, π* for the expert, J for expected total cost or reward. I keep their letters inside quotations of their theorems and say which is which. Their Hellinger distance is **D²_H := ∫(√dP − √dQ)² = 2H²**; I write D²_H for theirs and H² for the project's.
* A **label** (or query, or question) is one answer of the expert at one state. A **trajectory-wise annotation** is the expert's answers at all states of one trajectory. This distinction decides most comparisons below.
* "Off-policy" = an error measured on the states the expert visits. "On-policy" = measured on the states the learner itself visits.

---

## 1. Bottom line

1. **Whole-run deviation does not compound.** For two samplers answering the same scaffold, the probability that coupled runs ever differ is at most the expected sum of the per-call total variations, and the expectation may be taken on either sampler's own inputs (§4.1, F1). The quadratic bound T²ε of Ross and Bagnell (2010) arises only when (i) performance is a sum of per-step costs, so that a deviation at step t can cost T − t, and (ii) the per-step error is measured off-policy. With on-policy error and an expert that recovers from one wrong action at cost u, the bound is uTε (Ross, Gordon and Bagnell 2011, Theorem 2.2) [read].
2. **Under log loss the run law is the thing estimated, and the statistical rate has no horizon factor.** The log loss of a whole trajectory is the sum of the per-step log losses, so maximum likelihood over n expert trajectories gives D²_H(P^π̂, P^π*) ≤ 2 log(|Π|/δ)/n with no horizon factor, and for a deterministic expert J(π*) − J(π̂) ≤ 4R·D²_H, where R is the range of the total reward (Foster, Block and Misra 2024) [read]. The unit of data is a recorded trajectory of the expert, that is, in the project's terms, a run of the human system.
3. **Interaction does not improve these rates in general.** For a class of two policies, every algorithm, offline or interactive, even with known dynamics and a recoverable expert, has regret at least c·H/n (deterministic expert) and at least c·√(σ²/n) with constant probability (stochastic expert), n being the number of trajectories or interactive episodes (Foster, Block and Misra 2024) [read]. Interaction is known to help in two cases: classes without parameter sharing under recoverability (tabular: μ|S|H/N against |S|H²/N; Rajaraman and co-authors 2020 [read], 2021 [snippet]) and when cost is counted per label and the expert recovers cheaply (Li and Zhang 2025) (§3.3–§3.5).
4. **What DAgger's theorem says.** If the sequence of policies is produced by a no-regret online learner fed with the losses on the states each policy itself visits, then the average on-policy loss of the sequence is at most the loss of the best fixed policy in hindsight on those states, plus the average regret (Theorem 4.1 of Ross, Gordon and Bagnell 2011) [read]. It needs an expert who labels states the learner visits, the ability to run the learner's policy, a no-regret learner, and a class that contains a policy good on every distribution the iterates induce. Every state of every sampled trajectory is labelled; the stated iteration counts are Õ(T) with infinitely many samples per iteration and O(T² log(1/δ)) with O(1) trajectories per iteration (§3.2).
5. **The project's rehearsal protocol has a published special case.** Li and Zhang, "Interactive and Hybrid Imitation Learning: Provably Beating Behavior Cloning" (NeurIPS 2025, arXiv:2412.07057), analyse "Stagger": DAgger with exponential weights under log loss, **one state sampled from each rollout** put to the expert, output a uniformly chosen iterate. Their theorem, for a deterministic expert in a finite class of size B: J(π^E) − J(π̂) ≤ μH·(log B + 2 log(1/δ))/N with N labels [read]. Protocol R of `candidate-theory.md` is this algorithm with a prior on a countable class in place of the uniform prior, and Theorem R1 extends the statement to stochastic humans. The note should cite it (§3.5, §6).
6. **What a learner with log-loss regret at most K gives in the loop (Theorem D, §5.2).** With one uniformly chosen call per rehearsal run put to the human and the mixture frozen during a run: the sum over n rounds of the expected per-run sum of KL(P ‖ M) on the imitator's own inputs is at most L·K ln 2. For a uniformly chosen round this gives: deterministic human, the run is a run of the human system with probability at least 1 − L·K ln 2/n; stochastic human, expected total variation between run laws at most √(7·L·K ln 2/n). So **L·K ln 2/ε questions (deterministic) and 7·L·K ln 2/ε² questions (stochastic) suffice for run-level total variation ε**. The same counts of answers are needed by behaviour cloning from recorded runs of the human system (K ln 2/ε runs of up to L calls each); the difference is that rehearsal asks for single calls.
7. **Lower bounds (§5.4).** Deterministic: for a class of L/ε + 1 functions every protocol needs at least 2L/(3ε) questions to make the run faithful with probability 1 − ε/8 (this is N2 of the candidate; I re-derived it), and for a class with K ≈ d·log₂(L/ε) it needs at least 2dL/(7ε) [own], so L·K/ε is tight up to a factor log(L/ε). Stochastic: for a class of two samplers every protocol needs at least (L − 1)/(2048·ε²) questions [own]. In the literature the nearest statements are the c·H/n bounds of Foster, Block and Misra and the remark of Li and Zhang that a general lower bound for per-state annotation is open.
8. **Labelling every call of a rollout with one shared learner costs a factor L per label.** A frozen mixture updated once per rollout is a learner with delayed feedback. For a deterministic human the per-run sum of log losses is at most L times the joint log loss (Hölder), and for a stochastic human the per-run sum of squared Hellinger distances is at most L/2 times the joint KL (data processing) [own]. Foster, Block and Misra's log-loss DAgger has this factor ("spurious dependence on H" for stationary classes, their words) [read]. One audited call per run avoids it.
9. **What interaction buys in a closed system** is not a better rate. It is (a) that the human answers single calls and never carries out a run, and (b) control of the expected *number* of unfaithful calls in the imitator's own run, which recorded runs do not give, and which is what a recoverability or low-stakes argument consumes: expected outcome loss at most μ·L·K ln 2/n, where μ is the largest loss caused by one replaced answer when the human answers all later calls (§5.6, §5.7).
10. **For a stochastic human two criteria differ** (§5.8): the expected distance between the run law of the trained imitator and the human system (rate 1/√n, and this is forced), and the distance of the run law averaged over the training randomness (which can be of order 1/n in examples). The literature has the same split: 1/N in expectation for tabular stochastic experts (Rajaraman and co-authors 2020) against 1/√n with constant probability (Foster, Block and Misra 2024) [read].
11. **Corrections and pointers for the candidate theory** (§6): the constant 7 in the Hellinger subadditivity lemma is from Foster, Han, Qian and Rakhlin (2024), not from Foster, Kakade, Qian and Rakhlin (2021), whose lemma has 10²·log n; Theorem R4 covers a combination (per-state audit with one hypothesis per run) that Li and Zhang list as open; the recoverability form of "low stakes" is the standard one and is worth stating next to R3.

---

## 2. Summary table

Horizon is written L in every row. "ε" is the per-step error in the sense of the row. "Gap" is expert performance minus learner performance; "additive" means total cost in [0, L] with per-step costs in [0, 1]; "R" means total reward in [0, R].

| work | expert, class | per-step error is measured | what is bounded | dependence on L | expert labels |
|---|---|---|---|---|---|
| Ross–Bagnell 2010, Thm 2.1 | deterministic | 0-1, off-policy | additive gap ≤ L²ε, tight | quadratic | recorded trajectories |
| Ross–Bagnell 2010, forward training | deterministic, one policy per step | 0-1, on-policy | additive gap ≤ Σ_i ε_i u_i, u_i ≤ L − i + 1 | linear if u_i = O(1) | one step per sampled trajectory, L iterations |
| Ross–Gordon–Bagnell 2011 (DAgger), Thms 2.2, 3.1–3.4, 4.1–4.2 | any; surrogate loss ℓ ≥ 0-1; no-regret learner | on-policy, best in hindsight ε_N plus regret γ_N | on-policy loss ≤ ε_N + γ_N + …; additive gap ≤ uLε_N + O(1) | linear if u = O(1) | all states of all trajectories; Õ(L) iterations (infinite sample), O(L² log(1/δ)) iterations with O(1) trajectories |
| Rajaraman et al. 2020 | tabular, non-stationary | — | additive gap ≍ \|S\|L²/N without interaction and with active queries; ≲ \|S\|L^{3/2}/N with known transitions | quadratic; 3/2 with known transitions | N trajectories |
| Rajaraman et al. 2021 (NeurIPS) | tabular, μ-recoverable | — | Õ(μ\|S\|L/N) interactive; ≳ \|S\|L²/N offline | linear against quadratic | N interactive episodes |
| Foster–Block–Misra 2024 | finite class, realisable, stochastic allowed | log loss on whole trajectories | D²_H(run laws) ≤ 2 log(\|Π\|/δ)/n; gap ≤ 4R·D²_H (deterministic); ≲ √(σ²·D²_H) + R·D²_H (stochastic) | none beyond R and log\|Π\| | n trajectories |
| same, lower bounds | \|Π\| = 2 | — | gap ≥ c·L/n (R = L); ≥ c√(σ²/n) w.p. 1/8; offline or online | — | n trajectories or episodes |
| same, log-loss DAgger | finite class, layer-wise learners | Hellinger, on-policy | Σ_h E D²_H ≤ (2/n)Σ_h log(\|Π_h\|L/δ); gap ≲ μ·that (deterministic) | factor L for shared parameters | n rollouts, every state labelled |
| Li–Zhang 2025 (Stagger) | deterministic, finite class of size B, μ-recoverable | Hellinger, on-policy | gap ≤ μL(log B + 2 log(1/δ))/N | linear, with μ | N single states, one per rollout |
| Swamy et al. 2021 | moment classes | moment-matching error ε per step | gap O(εL) reward moments; O(εL²) off-policy Q-moments; O(εHL) on-policy Q-moments, H-recoverable | as stated; each tight or Ω(εL) | none / recorded / interactive |
| Xu–Li–Yu 2020 | discounted, 1/(1−γ) as horizon | per-state KL, off-policy | gap ≤ 2√2·R_max·√ε/(1−γ)² (BC); O(√ε/(1−γ)) for occupancy divergence ε | quadratic against linear | recorded |
| Sun et al. 2019 (FAIL) | observations only; discriminators F | IPM per step | gap ≤ L²(ε′_be + ε) | quadratic | Õ(L·K_A·log(\|Π\|\|F\|/δ)/ε²) trajectories (K_A actions) |
| Judah–Fern–Dietterich 2012 | deterministic, realisable, simulator | 0-1, on-policy, active learner | gap ≤ L³ε (stationary, RAIL); label complexity L·N_a(ε/L³, δ/L) | — | chosen single states |

All rows [read] except the 2021 NeurIPS row [snippet; read, as described in Foster–Block–Misra and in Li–Zhang].

---

## 3. Paper by paper

### 3.1 Ross and Bagnell (2010): the quadratic bound and the first interactive reductions

**Citation.** Stéphane Ross, J. Andrew Bagnell. "Efficient Reductions for Imitation Learning." *Proceedings of the 13th International Conference on Artificial Intelligence and Statistics (AISTATS)*, PMLR 9:661–668, 2010. https://proceedings.mlr.press/v9/ross10a.html (PDF read; proofs are in a supplement that I did not read).

**Setting** [read]. Task horizon T. The expert π* is deterministic. C(s, a) ∈ [0, 1] is the immediate cost; e(s, a) = 1[a ≠ π*(s)]; d^i_π is the state distribution at step i under π and d_π = (1/T)Σ_i d^i_π; J(π) = T·E_{s∼d_π}[C_π(s)].

**Theorem 2.1** [read]. "Let π̂ be such that E_{s∼d_π*}[e_π̂(s)] ≤ ε. Then J(π̂) ≤ J(π*) + T²ε." The bound is tight: there is a system, a cost and a π̂ with 0-1 loss ε on d_π* whose cost is (1 − εT)·J(π*) + T²ε. The intuition given: "as soon as π̂ makes a mistake, it could end up in new states that were not visited by π*, and always incur maximal cost of 1 at each step from then on."

**Forward training** [read]. A non-stationary policy π₁, …, π_T is trained in T iterations; at iteration i, π_i is trained to mimic π* on the states at step i reached by π₁, …, π_{i−1}. With ε_i the 0-1 error of π_i on that distribution and u_i a bound on the increase of the expected cost-to-go when only the action at step i is changed and π* is followed afterwards: J(π^T) ≤ J(π*) + Σ_i ε_i·u_i. In the worst case u_i = T − i + 1 and this is the quadratic bound again; if the true cost is the imitation loss itself, u_i = 1. The expert is asked only at step i of the sampled trajectories of iteration i.

**SMILe** [read]. A stationary stochastic mixture: start with the policy that queries and executes the expert; at iteration n mix in a new policy π̂ⁿ trained on the states visited by the current mixture, with weight α(1 − α)^{n−1}; the expert is executed with probability (1 − α)ⁿ per step. Theorem 4.1: with α of order 1/(T²√(log T)) (the PDF text reads "α = √3/(T²√(log T))") and N = 2T²(ln T)^{3/2} iterations, J(π̃^N) ≤ J(π*) + O(T(Ã₁ + ε̃) + 1), where ε̃ is a weighted average of the on-policy errors and Ã₁ a weighted average of first-order "policy disadvantages". They note that SEARN needs O(T³ log T) iterations and O(m·A·k·T⁴ log T) expert queries.

**What the paper does not give.** A statement about the trajectory law itself, a rate in the number of labels, or anything under log loss.

### 3.2 Ross, Gordon and Bagnell (2011): DAgger

**Citation.** Stéphane Ross, Geoffrey J. Gordon, J. Andrew Bagnell. "A Reduction of Imitation Learning and Structured Prediction to No-Regret Online Learning." *AISTATS 2011*, PMLR 15:627–635 [pages: mem]. arXiv:1011.0686 (v3, read in TeX source).

**Setting** [read]. As above; ℓ(s, π) is a surrogate loss observed instead of C, for example the expected 0-1 loss of π against π* at s, or a hinge or squared loss. "Our goal is to find a policy π̂ which minimizes the observed surrogate loss under its induced distribution of states": π̂ = argmin_{π∈Π} E_{s∼d_π}[ℓ(s, π)].

**Theorem 2.2 (on-policy error and recoverability)** [read]. "Let π be such that E_{s∼d_π}[ℓ(s, π)] = ε, and Q^{π*}_{T−t+1}(s, a) − Q^{π*}_{T−t+1}(s, π*) ≤ u for all action a, t ∈ {1, 2, …, T}, d^t_π(s) > 0, then J(π) ≤ J(π*) + uTε." Here Q^{π′}_t(s, π) is the t-step cost of executing π at s and π′ afterwards, and ℓ is the 0-1 loss or an upper bound on it. The proof is the telescoping sum over "execute π for t steps, then π*" (the performance difference lemma). "In the worst case, u could be O(T)"; if C is the 0-1 loss against the expert, u ≤ 1.

**Algorithm** [read]. For i = 1, …, N: let π_i = β_i·π* + (1 − β_i)·π̂_i; sample T-step trajectories with π_i; label every visited state with the expert's action; add the labelled states to the data set D; train π̂_{i+1} on all of D. "Return best π̂_i on validation." β₁ = 1 is typical; "the simple, parameter-free version" is β_i = 1[i = 1]; the requirement is that the average of the β_i tends to 0.

**Theorems 3.1–3.4** [read]. Assume ℓ strongly convex and bounded over Π and β_i ≤ (1 − α)^{i−1} for a constant α. Let ε_N := min_{π∈Π} (1/N)Σ_i E_{s∼d_{π_i}}[ℓ(s, π)], "the true loss of the best policy in hindsight".

* Theorem 3.1 (infinitely many samples per iteration): "if N is Õ(T) there exists a policy π̂ ∈ π̂_{1:N} s.t. E_{s∼d_π̂}[ℓ(s, π̂)] ≤ ε_N + O(1/T)". A footnote adds that the same holds for the policy that picks one of π̂_{1:N} uniformly at random and executes it for T steps.
* Theorem 3.2: "if N is Õ(uT) there exists a policy π̂ ∈ π̂_{1:N} s.t. J(π̂) ≤ J(π*) + uTε_N + O(1)."
* Theorem 3.3 (m trajectories per iteration, ε̂_N the empirical analogue of ε_N): "if N is O(T² log(1/δ)) and m is O(1) then with probability at least 1 − δ there exists a policy π̂ ∈ π̂_{1:N} s.t. E_{s∼d_π̂}[ℓ(s, π̂)] ≤ ε̂_N + O(1/T)". They remark that strong convexity "may lead to" N of order Õ(T log(1/δ)).
* Theorem 3.4: the same with N = O(u²T² log(1/δ)) and J(π̂) ≤ J(π*) + uTε̂_N + O(1).

**Theorems 4.1 and 4.2 (any no-regret learner)** [read]. The online losses are ℓ_i(π) = E_{s∼d_{π_i}}[ℓ(s, π)], and γ_N is the average regret, (1/N)Σ_i ℓ_i(π_i) − min_π (1/N)Σ_i ℓ_i(π) ≤ γ_N. With n_β the largest n with β_n > 1/T and ℓ_max a bound on the loss:

> "For DAgger, there exists a policy π̂ ∈ π̂_{1:N} s.t. E_{s∼d_π̂}[ℓ(s, π̂)] ≤ ε_N + γ_N + (2ℓ_max/N)·[n_β + T·Σ_{i=n_β+1}^N β_i], for γ_N the average regret of π̂_{1:N}."

The finite-sample version adds ℓ_max·√(2 log(1/δ)/(mN)) by the Azuma–Hoeffding inequality.

**What the guarantee says.** The average over iterations of the on-policy loss of the iterates is at most the best fixed policy's loss on the aggregate of the distributions the iterates induced, plus the average regret, plus a term for the steps on which the expert was executed. Hence some iterate, and the uniformly random iterate in expectation, is good on its own state distribution.

**What it requires** [read, except the last item].

* An expert who can be asked for the action at any state the learner reaches ("the learner is allowed to interact with the system and can query the expert at any given state", in the words of the 2010 paper).
* The ability to execute the learner's own policy from the initial distribution, repeatedly.
* A no-regret online learner over Π for the surrogate loss; the paper uses Follow-the-Leader with strongly convex losses and treats "mini-batches of trajectories under a single policy as a single online-learning example".
* For the bound to be useful, ε_N must be small: the class must contain one policy that is good on the aggregate distribution. The paper states the corresponding "error reduction assumption that for any input distribution, there is some policy π ∈ Π that achieves surrogate loss of ε".
* For performance: ℓ dominates the 0-1 loss and the cost-to-go under the expert rises by at most u after one deviation.
* To *select* the good iterate one needs validation, which costs further expert labels [read, as described in Li and Zhang 2025: "performing such validation in an interactive setting often requires additional expert annotations"]; the uniformly random iterate avoids this.

**Number of expert queries.** Every state of every sampled trajectory is labelled: N·m·T labels. With Theorem 3.3's N = O(T² log(1/δ)) and m = O(1) this is O(T³ log(1/δ)) labels for an excess on-policy loss O(1/T) per step [own arithmetic from the stated theorem].

**Later facts about the loop.**

* *The last iterate need not be good.* Ching-An Cheng, Byron Boots, "Convergence of Value Aggregation for Imitation Learning", AISTATS 2018, arXiv:1801.07292 [read]: with θ the ratio of a smoothness constant of the dependence of the state distribution on the policy to the strong convexity constant, the last policy satisfies F(x_N, x_N) ≤ ε̃ + O(N^{2(θ−1)}), and "there is a problem such that running AggreVaTe for N iterations results in F(x_N, x_N) ≥ ε̃ + Ω(N^{2(θ−1)}). In particular, if θ > 1, the policy sequence and performance sequence diverge."
* *Proper learners can fail.* Yichen Li, Chicheng Zhang, "On Efficient Online Imitation Learning via Classification", NeurIPS 2022, arXiv:2209.12868 [read]: for every horizon at least 3 there are an MDP, a deterministic expert and a benchmark class B such that every learner that plays a sequence of policies *from B* has static regret Ω(N); their algorithms play mixtures.
* *Cost-to-go version.* Stéphane Ross, J. Andrew Bagnell, "Reinforcement and Imitation Learning via Interactive No-Regret Learning" (AggreVaTe), arXiv:1406.5979, 2014 [read]: J(π̂) ≤ J(π̄) ≤ J(π*) + T[ε_class + ε_regret] + O(Q_max·T·log T/(αN)); it needs the expert's cost-to-go, which a human demonstrator of answers does not supply.

### 3.3 Rajaraman, Yang, Jiao and Ramchandran (2020), and the follow-ups on interaction and known dynamics

**Citation.** Nived Rajaraman, Lin F. Yang, Jiantao Jiao, Kannan Ramchandran. "Toward the Fundamental Limits of Imitation Learning." *NeurIPS 2020* [venue: mem]. arXiv:2009.05990 (v1, read in TeX source).

**Setting** [read]. Tabular episodic MDP, state space S, action space A, horizon H, time-dependent transitions and rewards r_t ∈ [0, 1] unknown to the learner; policies are non-stationary, π = (π₁, …, π_H). Three settings: (a) *no-interaction*: N trajectories of the expert; (b) *known-transition*: the same, and the learner knows the transitions and the initial distribution; (c) *active*: no data in advance, N episodes of interaction, and an oracle that returns the expert's action distribution at the learner's current state.

**Upper bounds** [read].

* Behaviour cloning, deterministic expert: any policy that copies the expert on the states seen has expected population 0-1 risk ≲ min{1, |S|/N}, hence, by Ross–Bagnell's Theorem 2.1, J(π*) − E[J(π̂)] ≲ min{H, |S|H²/N}; with probability 1 − δ, ≲ |S|H²/N + √|S|·H²·log(H/δ)/N.
* Reduction for stochastic experts: if the population TV risk (1/H)Σ_t E_{s_t∼f^t_π*}[TV(π̂_t(·|s_t), π*_t(·|s_t))] is at most ε, then J(π*) − J(π̂) ≤ min{H, H²ε}. They note that this route is loose for stochastic experts because the TV risk converges at rate √(|A|/N).
* Mimic-Emp (play the empirical action distribution where the state was seen, uniform elsewhere; this is empirical risk minimisation under log loss), stochastic expert: J(π*) − E[J(π̂)] ≲ min{H, |S|H² log N/N}. The proof couples the learner with the expert and bounds the probability that the learner reaches a state not in the data by ≲ |S|H log N/N.
* Known transitions, deterministic expert, Mimic-MD (copy the expert where seen; elsewhere choose the policy by a minimum-distance functional that matches the frequencies, estimated from the other half of the data, of trajectories that leave the seen states): expected gap ≲ min{H, √(|S|H²/N), |S|H^{3/2}/N}.

**Lower bounds** [read].

* For every learner there are an MDP and a deterministic expert with J(π*) − E[J(π̂)] ≳ min{H, |S|H²/N} in the no-interaction setting, and "this lower bound applies even when the learner operates in the active setting" (Theorem 6.1 in the numbering used by Swamy and co-authors 2022 [read]). In the construction every action other than the expert's leads to an absorbing state with no reward, and nothing can be learned there; so "the ability to actively query the expert does not improve the minimax expected suboptimality".
* Known transitions: gap ≳ min{H, |S|H/N}.

**Follow-ups.**

* Nived Rajaraman, Yanjun Han, Lin F. Yang, Kannan Ramchandran, Jiantao Jiao. "Provably Breaking the Quadratic Error Compounding Barrier in Imitation Learning, Optimally." arXiv:2102.12948, 2021 [read: abstract and introduction]. Known transitions, deterministic expert: the minimax gap is at least of order H^{3/2}/N when |S| ≥ 3, so Mimic-MD's H^{3/2} is the right power; for |S| = 2 the rate is H/N up to logarithms; if the expert is optimal for the true reward, an algorithm (Mimic-Mixture) attains O(1/N) on 3-state MDPs with terminal rewards.
* Nived Rajaraman, Yanjun Han, Lin Yang, Jingbo Liu, Jiantao Jiao, Kannan Ramchandran. "On the Value of Interaction and Function Approximation in Imitation Learning." *NeurIPS 2021* (Advances in Neural Information Processing Systems 34, pp. 1325–1336) [bibliographic data: snippet]. **Not read.** Its abstract, as returned by search [snippet]: under μ-recoverability, interacting with the MDP for N episodes gives a gap Õ(μ|S|H/N), "optimal up to log-factors", while "any algorithm which does not interact with the MDP and uses an offline dataset of N expert trajectories must incur suboptimality growing as ≳ |S|H²/N", a provable separation between the active and the no-interaction settings; with a linear expert and parameter sharing an offline bound Õ(dH/N). [read, as described in Foster–Block–Misra]: "proved a μH vs. H² gap between online and offline IL for the special case of non-stationary tabular policies (where Π is a product class with log|Π| ∝ H) under dense rewards", and, for deterministic linear policies with parameter sharing, an algorithm that minimises an empirical trajectory-wise distance with linear-in-H sample complexity.
* Gokul Swamy, Nived Rajaraman, Matthew Peng, Sanjiban Choudhury, J. Andrew Bagnell, Zhiwei Steven Wu, Jiantao Jiao, Kannan Ramchandran. "Minimax Optimal Online Imitation Learning via Replay Estimation." *NeurIPS 2022* [venue: mem]. arXiv:2205.15397 [read: abstract and main theorem; the last three authors from memory]. With recorded expert data and a simulator, replaying cached expert actions in the simulator smooths the estimate of the expert's visitation; in the tabular and linear cases the gap is Õ(min(H^{3/2}/N, H/√N)).

**Reading for the project** [own]. The model of the project's closed system is the *known-transition* setting (the scaffold can be simulated) plus single-call queries. The |S|H²/N active lower bound rests on unknown dynamics and does not transfer. The H^{3/2} improvements under known transitions concern additive rewards: they match per-step state–action frequencies, not the law of the whole trajectory, and they use recorded expert trajectories. For run-level total variation they give nothing beyond behaviour cloning (§5.6).

### 3.4 Foster, Block and Misra (2024): log loss, horizon-free bounds, and the limits of interaction

**Citation.** Dylan J. Foster, Adam Block, Dipendra Misra. "Is Behavior Cloning All You Need? Understanding Horizon in Imitation Learning." *NeurIPS 2024*. arXiv:2407.15007 (v2, read in TeX source). The numbers "Corollary 2.1", "Theorem 2.2", "Appendix C.2" and "Lemma D.2" below are those used by Li and Zhang (2025) when citing this paper [read].

**Setting** [read]. Episodic MDP with horizon H, states x_h, actions a_h, policies π = (π_h)_h possibly stochastic; total reward Σ_h r_h ∈ [0, R] ("sparse" R = O(1), "dense" R = H). The expert π* is arbitrary, not assumed optimal, and π* ∈ Π (realisability), Π finite. P^π is the law of a whole trajectory. Log-loss behaviour cloning: π̂ = argmin_{π∈Π} Σ_i Σ_h log(1/π_h(a^i_h | x^i_h)) over n expert trajectories; it "can be interpreted as performing maximum likelihood estimation over the set {P^π}".

**Statements** [read].

* *Proposition (supervised learning guarantee).* "For any (potentially stochastic) expert π* ∈ Π, the LogLossBC algorithm ensures that with probability at least 1 − δ, D²_H(P^π̂, P^π*) ≤ 2 log(|Π|δ^{−1})/n." Their appendix has versions with covering numbers and with misspecification measured by χ².
* *Theorem (horizon-independent regret decomposition, deterministic case).* "For any deterministic policy π* and potentially stochastic policy π̂, J(π*) − J(π̂) ≤ 4R·D²_H(P^π̂, P^π*)." Corollary 2.1: J(π*) − J(π̂) ≤ 8R·log(2|Π|δ^{−1})/n with probability 1 − δ.
* *How the proof avoids amplification.* With ρ(π ‖ π′) := E^π E_{a′_{1:H}∼π′(x_{1:H})}[1{∃h: a_h ≠ a′_h}]: (i) J(π) − J(π′) ≤ R·ρ(π ‖ π′) for all policies (Lemma D.2); (ii) ρ(π ‖ π′) = ρ(π′ ‖ π); (iii) for deterministic π*, (1/4)·ρ(π* ‖ π) ≤ D²_H(P^π, P^π*) ≤ 2·ρ(π* ‖ π). "By considering trajectory-level errors, we can switch from the state distribution induced by π̂ to that of π* for free." (A direct computation gives ρ ≤ D²_H in (iii): with g the probability, given the environment's randomness, that π reproduces the π*-trajectory, ρ = 1 − E g and D²_H = 2(1 − E√g) [own].)
* *Theorem 2.2 (lower bound, deterministic experts).* "For any n ∈ ℕ and H ∈ ℕ, there exists a (reward-free) MDP M* with |X| = |A| = 2, a class of reward functions R with |R| = 2, and a class of deterministic policies Π with |Π| = 2 with the following property. For any (online or offline) imitation learning algorithm, there exists a deterministic reward function r = {r_h} with r_h ∈ [0, 1] (in particular, R ≤ H) and (optimal) expert policy π* ∈ Π with μ = 1 such that E[J(π*) − J(π̂)] ≥ c·H/n for an absolute constant c > 0. In addition, the dynamics, rewards, and expert policies are stationary." The text adds that this holds "even with online access, recoverability, and known dynamics", so "without further assumptions on Π, online imitation learning cannot improve upon offline imitation learning in the realizable setting".
* *Theorem (stochastic experts).* With σ²_π* := Σ_h E^{π*}[(Q*_h(x_h, π*_h(x_h)) − Q*_h(x_h, a_h))²] ≤ Var^{π*}[Σ_h r_h] ≤ R², and R ≥ 1: for any pair of policies and ε ∈ (0, 1/e), J(π*) − J(π̂) ≤ √(6σ²_π*·D²_H) + O(R log(R/ε))·D²_H + ε. Hence for log-loss BC: ≲ √(σ²_π* log(|Π|/δ)/n) + R log(n)·log(|Π|/δ)/n.
* *Theorem (lower bound, stochastic experts).* Dense rewards, |X| = 3, |A| = 2, |Π| = 2, any σ² ∈ [H, H²]: for any online or offline algorithm there are a reward and an expert with σ²_π* ≤ σ² such that P(J(π*) − J(π̂) ≥ c·√(σ²/n)) ≥ 1/8. A footnote contrasts this with the 1/N rate *in expectation* of Rajaraman and co-authors for tabular stochastic experts, which rests on an unbiased estimate of π*: "such a result cannot hold with even constant probability".
* *Lower bound in an active framework* (their additional lower bounds). Count only the episodes in which the learner chooses to query. For every m there are an MDP with m self-looping states (m + 1 in the statement, m in the proof), uniform initial state, and a class with log|Π| = log m such that every algorithm with at most c·m queried episodes in expectation has expected gap at least c·H/m.
* *Converse.* For every pair of policies and every R there is a (non-Markovian) reward with total in [0, R] such that J(π*) − J(π̂) ≥ (R/6)·D²_H(P^π̂, P^π*). So the Hellinger distance of the run laws is, up to constants, the worst-case performance gap.
* *Log-loss DAgger* (Appendix C.2). In each of n episodes the learner executes π̂^i and *every* visited state is annotated with a draw a*_h ∼ π*(x_h). For each layer h separately, exponential weights over Π_h := {π_h : π ∈ Π} under log loss; output the uniform mixture of the iterates. With Est := (1/n)Σ_i Σ_h E^{π̂^i}[D²_H(π̂^i_h(x_h), π*(x_h))]:
  - "When π* ∈ Π, the log-loss exponential weights algorithm ensures that with probability at least 1 − δ, Est ≤ (2/n)·Σ_h log(|Π_h|·H·δ^{−1})."
  - For any online learner, J(π*) − J(π̂) ≲ √(σ̄²·Est) + μ̃·Est, and for a deterministic expert J(π*) − J(π̂) ≲ μ·Est. Here μ := max (Q*_h(x, π*_h(x)) − Q*_h(x, a))₊ is the recoverability parameter, μ̃ the same with absolute values ("signed"), and σ̄² := sup_π Σ_h E^{π∘_h π*}[(Q*_h(x_h, a_h) − V*_h(x_h))²], which is 0 for a deterministic expert.
  - Their comment: "for stationary policies, [this] has spurious dependence on H". With shared parameters Σ_h log|Π_h| = H·log|Π|, so the deterministic bound is μH log|Π|/n per rollout of H labels, "which does not improve over [log-loss BC] unless μ ≪ 1".
* *Autoregressive models.* Next-token prediction is log-loss BC in a token-level MDP whose state is the prompt and the tokens so far; "as long as the cumulative reward for the task is bounded by R = O(1) … the rollout performance has no explicit dependence on the sequence length, except through the generalization error".

**Two tools used there and in the project.**

* Dylan J. Foster, Sham M. Kakade, Jian Qian, Alexander Rakhlin. "The Statistical Complexity of Interactive Decision Making." arXiv:2112.13487 (v3, read in TeX source). **Lemma A.14** [read]: in online conditional density estimation where y^t ∼ g*(·|x^t) given x^t and the history, any algorithm with predictions ĝ^t and log-loss regret Reg against g* satisfies E[Σ_t E_{t−1} D²_H(ĝ^t(x^t), g*(x^t))] ≤ E[Reg], and with probability at least 1 − δ, Σ_t E_{t−1} D²_H(ĝ^t(x^t), g*(x^t)) ≤ Reg + 2 log(1/δ). **Lemma A.13** [read]: for laws P, Q of a sequence X₁, …, X_n built from kernels, D²_H(P, Q) ≤ 10²·log(n)·E_P[Σ_i D²_H(P^(i)(·|X_{1:i−1}), Q^(i)(·|X_{1:i−1}))], or 3 log(V) in place of 10² log n when the conditional density ratios are bounded by V ≥ e.
* Dylan J. Foster, Yanjun Han, Jian Qian, Alexander Rakhlin. "Online Estimation via Offline Estimation: An Information-Theoretic Framework." arXiv:2404.10122 (v1, read in TeX source; appendix "Technical Tools"). **Subadditivity for squared Hellinger distance** [read], stated as "an improvement to Lemma A.13 of [the 2021 paper] that removes a logarithmic factor": D²_H(P, Q) ≤ 7·E_P[Σ_i D²_H(P^(i)(·|X_{1:i−1}), Q^(i)(·|X_{1:i−1}))]. The proof uses the cut-and-paste property of Jayram (2009). The inequality is homogeneous, so it holds for H² as well. The constant cannot be 1: a two-step example gives a ratio 1 + √2/2 ≈ 1.707 [own, checked numerically].

**Under misspecification the picture changes.** Dhruv Rohatgi, Adam Block, Audrey Huang, Akshay Krishnamurthy, Dylan J. Foster. "Computational-Statistical Tradeoffs at the Next-Token Prediction Barrier: Autoregressive and Imitation Learning under Misspecification." COLT 2025 (PMLR 291, extended abstract) [venue: snippet]; arXiv:2502.12465 (read in TeX source: abstract and main statements). If π* ∉ Π and the aim is C_apx·min_{π∈Π} D²_H(P^π, P^π*) plus a statistical term: a ρ-estimator on whole trajectories attains D²_H(P^π̂, P^π*) ≲ log(|Π|/δ)/n + min_π D²_H(P^π, P^π*), that is C_apx = O(1), with no interaction; log-loss BC attains C_apx of order H·log(density bound)/δ; and "any next-token prediction-style objective must suffer C_apx = Ω(H)" (their theorem is for layer-wise iterative learners and classes without parameter sharing, with exponentially small misspecification). So the horizon-free statements are statements about the realisable case.

### 3.5 Li and Zhang (2025): one label per rollout

**Citation.** Yichen Li, Chicheng Zhang. "Interactive and Hybrid Imitation Learning: Provably Beating Behavior Cloning." *NeurIPS 2025*. arXiv:2412.07057 (v3 of January 2026, read in TeX source; v1 was titled "A Note on Sample Complexity of Interactive Imitation Learning with Log Loss" [snippet]).

**Setting** [read]. Episodic MDP with stationary dynamics (a step index can be put into the state), horizon H, total reward in [0, R]; a finite class B of stationary policies, |B| = B; the expert π^E is deterministic and in B ("deterministic realizability"); (M, π^E) is μ-recoverable: Q^{π^E}_h(s, a) − V^{π^E}_h(s) ≤ μ for all h, s, a (their sign convention). Two oracles: trajectory-wise (given s_{1:H}, return π^E(s_h) for all h) and **state-wise** (given one state, return π^E(s)). Cost model: one state-wise query costs C ≥ 1 offline state–action pairs.

**Algorithm (Stagger)** [read]. For n = 1, …, N: get π^n from an online learner; "execute π^n and sample s^n ∼ d^{π^n}"; query the state-wise oracle for a^{*,n} = π^E(s^n); update the learner with the loss ℓ^n(π) = log(1/π(a^{*,n} | s^n)). Output "a first-step uniform mixture of {π^n}", that is, draw one π^n uniformly and execute it for the episode. The learner is exponential weights over B, played as the *each-step* mixture π̄_u(a|s) = Σ_π u(π)·π(a|s).

**Theorem** [read]. Under the assumptions above, with probability at least 1 − δ,

  J(π^E) − J(π̂) ≤ μH·(log B + 2 log(1/δ))/N.

Proof as given: exponential weights has log-loss regret at most log B; Lemma A.14 of Foster, Kakade, Qian and Rakhlin turns it into Σ_n E_{s∼d^{π^n}}[D²_H(π^n(·|s), π^E(·|s))] ≤ log B + 2 log(1/δ); for a point mass q, ½‖p − q‖₁ ≤ D²_H(p, q); the performance difference lemma under μ-recoverability gives J(π^E) − J(π) ≤ μ·E^π[#{h : a_h ≠ π^E(s_h)}]. Comparison they draw: N state-wise labels cost as much as C·N/H offline trajectories, for which log-loss BC gives O(R·H·log B/(C·N)); so Stagger wins when C ≪ R/μ.

**Trajectory-wise variant (Tragger)** [read]. Each round draws one policy from the current weights, executes it for the whole episode (first-step mixing), has the whole state sequence annotated, and updates with the log loss of the whole annotated sequence. With probability 1 − δ, J(π^E) − J(π̂) ≤ 2R·(log B + 2 log(1/δ))/N for N annotated trajectories: interactive learning "has a trajectory-wise sample complexity matching that of behavior cloning", without recoverability.

**Remarks of theirs that bear on the project** [read].

* "For trajectory-wise annotation with each-step mixing, naively learning a parameter-sharing policy may encounter a batch-summed log loss, introducing an (undesirable) additional H factor to the sample complexity" (they cite Joulani, György and Szepesvári 2013 on delayed feedback).
* "Analyzing state-wise annotation with first-step mixing remains an open question."
* On lower bounds: the proof of Theorem 2.2 of Foster, Block and Misra "also implicitly implies a Ω(H/ε) sample complexity lower bound for the state-wise annotation setting", because in an MDP of self-absorbing states one state carries the information of a trajectory; "obtaining lower bounds for state-wise sample complexity for general MDPs, policy classes, and general recoverability constants remains an open question."
* A one-sample-per-iteration version of AggreVaTe is analysed in Agarwal, Jiang, Kakade and Sun, *Reinforcement Learning: Theory and Algorithms*, Section 15.5 [read, as described there].
* A hybrid algorithm (warm start on offline data, then Stagger) has gap O(min(R·log(B̃/δ)/N_off, μH·log(B_bc/δ)/N_on)), and there is an MDP in which it needs far fewer labels than either source alone.

### 3.6 Distribution matching: Ho and Ermon, Ke and co-authors, Xu, Li and Yu, Swamy and co-authors, Sun and co-authors

* **Jonathan Ho, Stefano Ermon. "Generative Adversarial Imitation Learning." NIPS 2016. arXiv:1606.03476** [read]. With ρ_π the occupancy measure of π, H(π) the causal entropy and ψ a convex cost regulariser: RL∘IRL_ψ(π_E) = argmin_π −H(π) + ψ*(ρ_π − ρ_{π_E}) (the second proposition of their Section 3); with constant ψ the recovered policy matches the expert's occupancy measure exactly; for the regulariser ψ_GA, ψ*_GA(ρ_π − ρ_{π_E}) = max_D E_π[log D(s, a)] + E_{π_E}[log(1 − D(s, a))], a Jensen–Shannon divergence between occupancy measures up to constants. There is no sample-complexity or horizon statement. The algorithm needs rollouts of the learner and recorded expert data, and never asks the expert.
* **Liyiming Ke, Sanjiban Choudhury, Matt Barnes, Wen Sun, Gilwoo Lee, Siddhartha Srinivasa. "Imitation Learning as f-Divergence Minimization." WAFR 2020 [venue: mem]. arXiv:1905.12888** [read]. Theorem: for every f-divergence, D_f(trajectory laws) ≥ D_f(average state–action distributions) (data processing). Appendix theorem: for f-divergences "that satisfy the triangle inequality", D_f(ρ_{π*}(τ), ρ_π(τ)) ≤ T·E_{s∼ρ_π}[D_f(π*(·|s), π(·|s))], which needs the expert at the learner's states. They name total variation and squared Hellinger distance as examples. For total variation this is F1 of §4.1. **Squared Hellinger distance does not satisfy the triangle inequality** (δ₀, the uniform law on {0, 1}, δ₁), and the stated bound with constant 1 is false for it [own: the two-step example of §3.4]; the correct form has the constant 7. They read behaviour cloning as minimising KL(expert ‖ learner), GAIL as Jensen–Shannon and DAgger as total variation.
* **Tian Xu, Ziniu Li, Yang Yu. "Error Bounds of Imitating Policies and Environments." NeurIPS 2020. arXiv:2010.11876** [read]. Discounted setting. Theorem 1: if E_{s∼d_{π_E}}[KL(π_E(·|s), π_BC(·|s))] ≤ ε then V_{π_E} − V_{π_BC} ≤ 2√2·R_max·√ε/(1 − γ)². Corollary: deterministic and realisable, V_{π_E} − V_{π_BC} ≤ (2R_max/(1 − γ)²)·(log|Π| + log(1/δ))/m with m expert samples. Lemma: if D_f(ρ_{π_GA}, ρ_{π_E}) ≤ ε then the gap is O(√ε/(1 − γ)). Their BC bound applies Pinsker's inequality per state and then sums; applying the chain rule first gives a bound smaller by the square root of the effective horizon (§4.3) [own].
* **Gokul Swamy, Sanjiban Choudhury, J. Andrew Bagnell, Zhiwei Steven Wu. "Of Moments and Matching: A Game-Theoretic Framework for Closing the Imitation Gap." ICML 2021 [venue: mem]. arXiv:2103.03236** [read]. Horizon T, rewards in [−1, 1]. The learner plays a game against a discriminator f; three payoffs, each normalised by 1/T: U₁ (on-policy reward moments: E_π Σ_t f − E_{π_E} Σ_t f), U₂ (off-policy Q-moments: on expert states, compare f at the learner's and at the expert's action), U₃ (on-policy Q-moments: on learner states, compare f at the learner's action and at the queried expert's action). For a policy that is an ε-approximate equilibrium of the game: reward moments, J(π_E) − J(π) ≤ O(εT), and there is an MDP with ≥ Ω(εT); off-policy Q, ≤ O(εT²) and ≥ Ω(εT²) on an example; on-policy Q with an H-recoverable pair (π_E, F_{Q_E}) (meaning |f(s, a) − E_{a′∼π_E(s)} f(s, a′)| < H for all f in the class of expert Q-functions), ≤ O(εHT) and ≥ Ω(εT). Requirements: reward moments need rollouts of the learner and no expert queries; off-policy Q needs neither; on-policy Q needs both. A lemma: for expert–reward pairs that are not H-recoverable for any H < T, a classification error κ at a single state can give a gap Ω(κT²) even with an interactive expert. "Neither on-Q nor reward moment matching is a silver bullet."
* **Wen Sun, Anirudh Vemula, Byron Boots, J. Andrew Bagnell. "Provably Efficient Imitation Learning from Observation Alone." ICML 2019 [venue: mem]. arXiv:1905.10948** [read]. The expert supplies observation sequences without actions; K actions; policy classes Π_h and discriminator classes F_h per step. FAIL learns π_h one step at a time by solving a min–max game that matches, in the integral probability metric of F_{h+1}, the learner's next-observation distribution to the expert's. Theorem: under realisability, with probability 1 − δ, J(π) − J(π*) ≤ H²ε′_be + H²ε using Õ(HK·log(|Π||F|/δ)/ε²) trajectories, ε′_be being an average inherent Bellman error of the discriminator classes. A theorem shows that discriminators of unlimited capacity (total variation) do not generalise from samples: with M = O(log|X|) samples the empirical distributions of the expert and of two different policies are pairwise disjoint with probability tending to 1. A proposition separates observation-only imitation from reinforcement learning exponentially in H.

**Reading for the project** [own]. The distribution-matching view replaces "agree with the expert call by call" by "produce runs that no test in a class can tell from the expert's". It needs recorded expert runs to compare against; it needs the learner's rollouts (free in a closed system); it never asks the expert about a learner-generated input. It is the published counterpart of the candidate's test-matching statements Pr3 and Pr4, and FAIL's non-generalisation theorem is the reason those statements restrict the family of tests.

### 3.7 Choosing the states to ask: Judah, Fern and Dietterich; Sekhari and co-authors

* **Kshitij Judah, Alan P. Fern, Thomas G. Dietterich. "Active Imitation Learning via Reduction to I.I.D. Active Learning." UAI 2012. arXiv:1210.4876** [read]. The learner has "a simulator of the MDP" (given a policy and a horizon it returns a state trajectory, no reward) and may ask the expert for the action at any single state. Let N_p(ε, δ) and N_a(ε, δ) be the label complexities of passive and active PAC learning for the class. Passive imitation with non-stationary policies costs T·N_p(ε/T², δ/T) labels for regret ε (using Lemma 3 of Syed and Schapire 2010: per-step error ε gives V(π̂) ≥ V(π*) − T²ε [read, as described here]). Proposition 1: forward training with an active learner at each step returns, with probability 1 − δ, a policy with V(π̂) ≥ V(π*) − T²ε; label complexity T·N_a(ε/T², δ/T). Theorem 1 (RAIL, stationary policies; iteration t+1 runs the active learner on the state distribution of the previous policy): V(π̂^T) ≥ V(π*) − T³ε; label complexity T·N_a(ε/T³, δ/T) against the passive T·N_p(ε/T², δ). In the realisable case this is T·O(log(T³/ε)) against T·O(T²/ε), *for classes where active learning gives the logarithmic rate*.
* **Ayush Sekhari, Karthik Sridharan, Wen Sun, Runzhe Wu. "Selective Sampling and Imitation Learning via Online Regression." NeurIPS 2023 [venue: mem]. arXiv:2307.04998** [read: abstract]. Queries to a noisy expert chosen by selective sampling with an online regression oracle; regret bounded by the oracle's regret, number of queries also by the eluder dimension of the model class. The companion digest `ask-for-help.md` covers it.

**Reading for the project** [own]. Choosing the questions helps only for classes with a small disagreement region. In a class closed under patches every unasked input is a point of disagreement, and the lower bound of §5.4 holds for adaptive protocols.

### 3.8 Two further sources

* **Max Simchowitz, Daniel Pfrommer, Ali Jadbabaie. "The Pitfalls of Imitation Learning when Actions are Continuous." arXiv:2503.09722, 2025** [read: abstract]. In continuous state and action control, even with exponentially stable dynamics and a smooth deterministic expert, "any smooth, deterministic imitator policy necessarily suffers error on execution that is exponentially larger, as a function of problem horizon, than the error under the distribution of expert training data", for any algorithm that learns from expert data alone, unless the policy is non-smooth, non-Markovian or strongly stochastic, or the expert data are spread. The horizon-free results above concern exact agreement of discrete answers in a realisable class; they do not say that small errors in a metric stay small.
* **Paul Christiano, Buck Shlegeris, Dario Amodei. "Supervising strong learners by amplifying weak experts." arXiv:1810.08575, 2018** [read: the training section and the appendix on task distributions]. The scaffold of the project in practice. A human H answers a question by asking sub-questions of the current agent X; a "human predictor" H′ is trained on the recorded decisions of H. "Note that H′ needs to predict how H will respond to subanswers provided by X. Because X is changing, this distribution is non-stationary, and so we need to continuously update H′ throughout the training process." The human is therefore asked on inputs produced with the current learner, as in DAgger. On the choice of the top-level distribution: "We selected these distributions D to ensure that every subquestion of a question draw[n] from D is also given reasonable probability under D." This is the density-ratio route (S1 and S2 of the candidate) as an alternative to rehearsal.

---

## 4. How the distance scales with the horizon and the per-step error

This section restates the literature in the project's notation, for a scaffold with at most L calls and samplers S (the imitator) and P (the human). Runs are padded to length L. ε_j(x) denotes a per-call error at input x in the sense of each line.

### 4.1 Four facts

**F1 (coupling; no compounding at run level)** [own; standard: it is the argument behind Ross–Bagnell's Theorem 2.1 and the symmetry of ρ in Foster–Block–Misra]. Draw the two answers at each call from a maximal coupling while the runs agree. The runs agree up to the first call at which the answers differ, so

  TV(Q_S, Q_P) ≤ Pr[some call differs] ≤ min{ E_{Q_S} Σ_j TV(S(·|x_j), P(·|x_j)), E_{Q_P} Σ_j TV(S(·|x_j), P(·|x_j)) }.

For a deterministic human f, TV(Q_S, Q_f) = Pr[the run of S has a call answered differently from f] exactly.

**F2 (chain rule for KL)** [standard]. KL(Q_P ‖ Q_S) = E_{Q_P} Σ_j KL(P(·|x_j) ‖ S(·|x_j)). The outer expectation is under the first argument.

**F3 (subadditivity of H²)** [read: Foster, Han, Qian and Rakhlin 2024]. H²(Q_S, Q_P) ≤ 7·E_{Q_S} Σ_j H²(S(·|x_j), P(·|x_j)), and the same with E_{Q_P}. Together with H² ≤ TV ≤ √(2H²) and H² ≤ KL/2.

**F4 (performance difference)** [standard; Ross, Gordon and Bagnell 2011, proof of Theorem 2.2; Li and Zhang 2025, auxiliary lemma]. Let the outcome have expectation J(·). For a partial run h (everything before call j is answered) and an answer y let Q^P(h, y) be the expected outcome when call j is answered y and the human answers all later calls, and V^P(h) := E_{y∼P(·|x_j)} Q^P(h, y). Then

  J(P) − J(S) = E_{Q_S} Σ_j [V^P(h_j) − Q^P(h_j, y_j)].

Define μ := sup_{h,y} (V^P(h) − Q^P(h, y))₊ and μ̃ := sup_{h,y,y′} |Q^P(h, y) − Q^P(h, y′)|. Then J(P) − J(S) ≤ μ̃·E_{Q_S} Σ_j TV(S(·|x_j), P(·|x_j)), and for a deterministic human J(f) − J(S) ≤ μ·E_{Q_S}[number of calls answered differently from f].

### 4.2 0-1 loss and total variation

| per-call error ε_j is | measured under | run-level distance | outcome in [0, 1] | additive score in [0, L] |
|---|---|---|---|---|
| Pr[S answers ≠ f(x)], or TV(S, P) | Q_P (off-policy; behaviour cloning) | TV(Q_S, Q_P) ≤ Σ_j E ε_j = L·ε̄ (F1) | gap ≤ L·ε̄ | gap ≤ L²·ε̄; tight (Ross–Bagnell Thm 2.1; Rajaraman et al.: min{L, L²ε̄}) |
| the same | Q_S (on-policy; forward training, SMILe, DAgger) | TV(Q_S, Q_P) ≤ L·ε̄ (F1) | gap ≤ μ̃·L·ε̄ (F4) | gap ≤ u·L·ε̄ with u ≤ L (Ross–Gordon–Bagnell Thm 2.2) |

The first two columns of results do not distinguish the two rows. The rows differ in what is known after the first deviation: off-policy error says nothing about the calls that follow it, so the expected *number* of deviating calls can be L times the probability of a deviation, which is L²ε̄; on-policy error bounds that number by L·ε̄ directly. Additive scores and recoverability arguments consume the number, not the probability [own].

### 4.3 Log loss

| per-call error ε_j is | measured under | run-level distance | performance |
|---|---|---|---|
| KL(P(·\|x) ‖ S(·\|x)) | Q_P | KL(Q_P ‖ Q_S) = L·ε̄ exactly (F2); TV ≤ √(L·ε̄/2); H² ≤ L·ε̄/2; deterministic human: TV ≤ L·ε̄ | deterministic: gap ≤ R·TV ≤ R·L·ε̄; in general ≤ R·√(L·ε̄/2), refined to √(6σ²·D²_H) + … by Foster–Block–Misra |
| KL(P(·\|x) ‖ S(·\|x)) | Q_S | H²(Q_S, Q_P) ≤ 3.5·L·ε̄ (F3); TV ≤ √(7·L·ε̄); deterministic human: TV ≤ L·ε̄ (F1) | deterministic: gap ≤ μ·L·ε̄ (F4); in general ≲ √(σ̄²·Est) + μ̃·Est, where Est ≤ L·ε̄ is the on-policy sum of D²_H (Foster–Block–Misra; §5.2(f)) |
| statistical: n recorded runs, maximum likelihood, finite class | — | D²_H(Q_Ŝ, Q_P) ≤ 2 log(\|Π\|/δ)/n | 8R·log(2\|Π\|/δ)/n (deterministic) |

Three remarks [own].

* *Why "horizon-free".* In the first row L·ε̄ is the expected log loss of *one run*. A learner whose data are whole runs has regret per run, not per call, so the product L·ε̄ is what is small, about K ln 2/n after n runs, whatever L is. The horizon re-enters only when data are counted in calls (n runs are up to n·L answers) or when performance is additive (R = L).
* *Order of operations.* Applying Pinsker's inequality at each call and then summing gives L·√(ε̄/2); applying the chain rule first gives √(L·ε̄/2). The second is smaller by √L. On-policy, where F2 is not available in the needed direction, F3 gives the same order with the constant 7. The behaviour-cloning bound of Xu, Li and Yu (2020) is of the first kind.
* *The on-policy KL is not a KL between run laws.* E_{Q_S} Σ_j KL(P ‖ S)(x_j) has the human as first argument inside and the imitator's law outside. It bounds neither KL(Q_S ‖ Q_P) nor KL(Q_P ‖ Q_S). Squared Hellinger distance is symmetric, which is why F3 is the tool.

### 4.4 Interactive methods, in one sentence each

* Forward training and SMILe: on-policy 0-1 error, one policy per step or a slowly changing mixture; gap linear in L under recoverability; Õ(L²) iterations for SMILe.
* DAgger: the average on-policy loss of the iterates is at most best-in-hindsight plus average regret; all visited states labelled.
* Log-loss DAgger (Foster–Block–Misra): on-policy Hellinger error at most (2/n)Σ_h log(|Π_h|L/δ) per rollout; a factor L for shared parameters.
* Stagger (Li–Zhang): on-policy Hellinger error summed over N single-label rounds at most log B + 2 log(1/δ); gap μL(log B + 2 log(1/δ))/N.
* Lower bounds: no interactive method beats c·L/n (R = L) or c·√(σ²/n) for all classes of two policies.

---

## 5. The researcher's setting

### 5.1 Dictionary

| imitation learning | here |
|---|---|
| state s (or x_h) | the input x_j of a call, with everything the scaffold passes in it |
| action a | the answer y_j, a string |
| expert policy π*, stochastic | the human sampler P; deterministic expert = a function f |
| stationary class with shared parameters; log\|Π\| | class H of samplers, one sampler answers every call; K ln 2 = ln(1/w(P)) |
| dynamics and initial distribution | the scaffold Π and the law D₀ of the top-level input |
| known transitions, or a simulator | closed system: z and ρ can be sampled, the scaffold can be run with any answerer |
| horizon T or H | L, the largest number of calls in a run; for a decomposition tree, the number of nodes, not the depth |
| trajectory law P^π | run law Q_S |
| total reward in [0, R] | an outcome in [0, 1] has R = 1 ("sparse"); a sum of L per-call scores has R = L ("dense") |
| trajectory-wise annotation; recorded expert trajectory | the human answers all calls of one run; a run of the human system |
| state-wise annotation | one question to the human |
| recoverability μ | the largest loss of expected outcome caused by replacing one answer when the human answers all later calls (F4) |
| first-step mixing; each-step mixing | one hypothesis drawn per run; a fresh hypothesis drawn at every call (the mixture M) |

Differences that matter [own]. (i) Answers are strings, so classification theory with a finite action set and VC-type dimensions does not apply as it stands; the log-loss statements need only countability. (ii) The human is stochastic. (iii) The inputs of later calls contain the imitator's own earlier answers, as in the token-level MDP of Foster, Block and Misra; a tree only fixes which earlier answers enter which input. (iv) There is one outcome per run, so R = 1 and the trajectory-level statements are the relevant ones.

### 5.2 Theorem D: a learner with log-loss regret at most K inside the loop

**Assumptions.** A1 (the human is a stateless sampler P) and A3 (the protocol's coins are fresh), as in `note.md`. A learner that maps data D to a sampler M_D such that on every sequence of pairs

  Σ_t [ln P(y_t|x_t) − ln M_{D_{t−1}}(y_t|x_t)] ≤ K ln 2.   (Reg)

That is: cumulative log-loss regret against the human of at most K bits, on every sequence, with adaptively chosen inputs. The Bayes mixture over a countable class containing P with w(P) = 2^{−K} satisfies (Reg) (the telescoping identity in the proof of Theorem R1 of `note.md`; for finite classes Proposition 3.1 of Cesa-Bianchi and Lugosi 2006 [read, as quoted in Li–Zhang]). Nothing else about the learner is used.

**Protocol R** (as in `note.md`). For t = 1, …, n: freeze M^(t) := M_{D_{t−1}}; run the scaffold with M^(t) answering every call; draw J uniformly from {1, …, L}; if the run has a J-th call, put its input x_J to the human and append the pair to the data. Deploy M^(T) for T uniform on {1, …, n}.

Write KL_t(x) := KL(P(·|x) ‖ M^(t)(·|x)), D²_t(x) := D²_H(P(·|x), M^(t)(·|x)) = 2H²(…), and Σ_run for the sum over the calls of the run of round t; E_{t−1} is the expectation given the data before round t.

**Statements.**

(a) *Per call, in expectation.* Σ_{t=1}^n E[Σ_run KL_t(x_j)] ≤ L·K ln 2. [own; this is Theorem R1 of the note]

(b) *Per call, with high probability.* With probability at least 1 − δ over the rehearsal, Σ_{t=1}^n E_{t−1}[Σ_run D²_t(x_j)] ≤ L·(K ln 2 + 2 ln(1/δ)). [own, by Lemma A.14 of Foster, Kakade, Qian and Rakhlin; for finite classes and a deterministic expert this is the first display of Li and Zhang's theorem]

(c) *Deterministic human.* Let β_t be the expected number of unfaithful calls in the run of round t given the data. Then Σ_t E β_t ≤ L·K ln 2, and with probability 1 − δ, Σ_t β_t ≤ L·(K ln 2 + 2 ln(1/δ)). The deployed run is a run of the human system on the same (z, ρ) with probability at least 1 − L·K ln 2/n. [own; = R1 and R2 of the candidate for functions]

(d) *Stochastic human, whole runs.* E[H²(Q_{M^(T)}, Q_P)] ≤ 7·L·K ln 2/(2n) and E[TV(Q_{M^(T)}, Q_P)] ≤ √(7·L·K ln 2/n). With probability 1 − δ over the rehearsal, (1/n)Σ_t H²(Q_{M^(t)}, Q_P) ≤ 7·L·(K ln 2/2 + ln(1/δ))/n. [own, by F3; = R2 of the candidate with c₀ = 7]

(e) *Stochastic human, number of unfaithful calls.* E β_T ≤ L·√(K ln 2/(2n)). [own; as in the note after Theorem R3]

(f) *Outcome under recoverability.* For an outcome with F4's constants: deterministic human, J(f) − E J(M^(T)) ≤ μ·L·K ln 2/n; stochastic human, J(P) − E J(M^(T)) ≤ μ̃·L·√(K ln 2/(2n)), and by the proposition of Foster, Block and Misra for any on-policy estimation error, J(P) − E J(M^(T)) ≲ √(σ̄²·Est) + μ̃·Est with E Est ≤ L·K ln 2/n in D²_H units. [own from F4; the last clause read]

(g) *Without realisability.* If the learner's regret bound holds against every ν in the class with ln(1/w(ν)) in place of K ln 2 (the Bayes mixture), then for every ν: Σ_t E[Σ_run KL_t(x_j)] ≤ L·ln(1/w(ν)) + Σ_t E[Σ_run KL(P ‖ ν)(x_j)]. The second term is the loss of the comparator *on the inputs the iterates induced*: this is DAgger's ε_N, and the first is its regret term. [own]

**Proofs.** (a) By (Reg) the sum over rounds of ln(P/M^(t)) at the asked pair is at most K ln 2 on every path. Given the past and the asked input x_t, the answer is a draw from P(·|x_t) by A1 and A3, so the conditional expectation of the t-th term is KL_t(x_t); and because J is uniform and independent of the run, E_{t−1}[KL_t(x_t)·1{asked}] = (1/L)·E_{t−1}[Σ_run KL_t(x_j)]. (b) Lemma A.14 applied to the sequence of asked pairs, with a null input when nothing is asked: Σ_t E_{t−1}[D²_t(x_t)] ≤ Reg + 2 ln(1/δ), and E_{t−1}[D²_t(x_t)] = (1/L)·E_{t−1}[Σ_run D²_t(x_j)]. (c) For a point mass at f(x), the probability that a draw from M^(t)(·|x) differs from f(x) is 1 − M^(t)(f(x)|x) ≤ −ln M^(t)(f(x)|x) = KL_t(x), and also ≤ D²_t(x) = 2(1 − √M^(t)(f(x)|x)); sum over the run, use (a) and (b), then F1 and the uniform choice of T. (d) Given the data, M^(t) is a fixed sampler, so F3 gives H²(Q_{M^(t)}, Q_P) ≤ 7·E_{t−1}[Σ_run H²_t(x_j)] ≤ (7/2)·E_{t−1}[Σ_run KL_t(x_j)]; average over t with (a); TV ≤ √(2H²) and Jensen's inequality. (e) F1's sum of total variations, Pinsker's inequality per call, and the Cauchy–Schwarz inequality over the L calls. (f) F4 with (c) or (e). (g) The same computation as (a) with ν as comparator: E ln(P/M^(t)) = E ln(P/ν) + E ln(ν/M^(t)). ∎

**Remarks.**

* Statement (b) with a finite class, a deterministic expert and the conversion (f) *is* the theorem of Li and Zhang (2025); (a) is its form in expectation. The additions here are the prior on a countable class, stochastic humans, and the run-level statement (d). I did not find (d) in the papers I read.
* The deployed object is the each-step mixture of a uniformly chosen round. The DAgger literature's alternatives are the best iterate on validation (extra labels; this is the candidate's V1) and the last iterate (no guarantee in general, §3.2).
* The audit index J must be drawn independently of the run (A3). The literature assumes the same when it writes s^n ∼ d^{π^n}. It becomes a substantive assumption only for classes, such as all programs, that contain hypotheses able to compute a pseudo-random choice from the input.

### 5.3 Number of questions for run-level total variation at most ε

| human | criterion | protocol | questions to the human | source |
|---|---|---|---|---|
| deterministic | the deployed run is a run of the human system with probability ≥ 1 − ε | Protocol R | L·K ln 2/ε single calls | D(c) |
| deterministic | the same | Bayes on recorded runs of the human system, one posterior draw per run | K ln 2/ε runs, up to L·K ln 2/ε answers, given in whole runs | candidate Theorem A; with maximum likelihood on a finite class, 2 log(\|Π\|/δ)/ε-type bounds by Foster–Block–Misra |
| stochastic | E TV(Q_{M^(T)}, Q_P) ≤ ε | Protocol R | 7·L·K ln 2/ε² single calls | D(d) |
| stochastic | E TV ≤ ε | recorded runs, posterior draw per run | K ln 2/(2ε²) runs, up to L·K ln 2/(2ε²) answers | candidate Theorem A and Pinsker |
| deterministic, outcome in [0, 1], μ-recoverable | expected outcome loss ≤ ε | Protocol R | μ·L·K ln 2/ε | D(f); Li–Zhang |
| deterministic, tolerates θL faults with failure δ₀ | failure ≤ δ₀ + ε | Protocol R | K ln 2/(θ·ε) | candidate R3 |

All rows [own] given the cited statements. For a decomposition tree, L is the number of calls in the tree; in the letters of the task text (a tree with N calls) the first and third rows read N·K ln 2/ε and 7·N·K ln 2/ε². If one replaced answer costs at most c/L of the outcome (μ = c/L), the fifth row is c·K ln 2/ε, independent of L.

### 5.4 Lower bounds

**Known in the literature** (all [read] unless tagged).

* Deterministic expert, |Π| = 2, n trajectories or interactive episodes with every state labelled, known dynamics, μ = 1: expected gap ≥ c·L/n when R = L (Foster–Block–Misra, Theorem 2.2). Normalised to an outcome in [0, 1] this is c/n: one needs of order 1/ε episodes. The construction has self-looping states, so an episode carries the information of one label (Li and Zhang's remark).
* Active framework, a class with log|Π| = log m: with at most c·m queried episodes the gap is at least c·L/m (Foster–Block–Misra).
* Stochastic expert, |Π| = 2: gap at least c·√(σ²/n) with probability 1/8, offline or online (Foster–Block–Misra).
* Tabular, non-stationary, unknown dynamics, N episodes with or without active queries: gap ≳ min{L, |S|L²/N} (Rajaraman and co-authors 2020). Normalised: failure ≳ |S|L/N, that is N ≳ |S|L/ε episodes of L labels each. The class has log|Π| ≈ |S|·L·log|A|, so in the project's units this reads (number of labels) ≳ K·L/(ε·log|A|). It depends on unknown dynamics.
* A lower bound for per-state annotation with general classes and recoverability constants "remains an open question" (Li and Zhang 2025).

**For the closed system with single-call questions** [own; the first is N2 of the candidate, which I re-derived; none is refereed].

*LB1 (deterministic, every call critical).* Let L ≥ 1 and ε ∈ (0, 1/2]. Scaffold: L calls on independent uniform inputs, the run records all answers. Class: the zero function and the indicators of N₀ = L/ε disjoint cells of probability ε/L each. For every protocol with n single-call questions, adaptive or not, and every deployed answerer, some member has

  TV(deployed run law, Q_f) ≥ (ε/2)·(1 − ε/2)·(1 − n·ε/L).

So total variation at most ε/8 for every member needs n ≥ 2L/(3ε), while K ≤ log₂(L/ε + 1). *Proof.* Put prior ½ on the zero function and ½ uniformly on the cells. While all answers are 0 the protocol asks a fixed sequence of inputs, covering at most n cells; for a member whose cell is not among them the transcript is the same as for the zero function, hence so is the deployed answerer A. Let F₀ be the probability that A answers 1 somewhere in a run and p_c the probability that the run has a call in cell c answered 1; the cells are disjoint, so Σ_c p_c ≤ E[number of calls answered 1] ≤ L·F₀. Under the zero function the distance is at least F₀. Under the indicator of an unasked cell c it is at least Pr[a call falls in c] − p_c ≥ ε − ε²/2 − p_c. Averaging: ½F₀ + ½(1 − nε/L)(ε − ε²/2) − ½·L·F₀·ε/L ≥ (ε/2)(1 − ε/2)(1 − nε/L). ∎

*LB2 (the factor K).* Let d ≥ 1, L ≥ 16, ε ≤ 1/4. Split the input space into d blocks of probability 1/d, each into N₁ = L/ε cells of probability ε/(dL). Class: all functions that are the indicator of a union of at most one cell per block; (L/ε + 1)^d members, so K ≤ d·log₂(L/ε + 1) with uniform weights. Same scaffold. For every protocol with n questions, some member has Pr[deployed run not faithful] ≥ ε·[(1 − ε/2)(½ − n·ε/(dL)) − 1/L]; hence failure at most ε/8 for every member needs n ≥ 2dL/(7ε). *Sketch.* Prior: independently per block, no cell with probability ½, otherwise a uniform cell. Given any history, an unasked cell of an unresolved block is special with probability at most 1/N₁, so each question finds a special cell with probability at most 1/N₁, and the expected number m of special cells never asked is at least d/2 − nε/L. A run hits one of them with probability at least (mε/d)(1 − ε/2). At such a call the answerer does not know the cell is special; answering 1 at an unasked cell is right with probability at most 1/N₁ = ε/L. ∎ So for classes with K ≈ d·log₂(L/ε), the bound L·K ln 2/ε of D(c) is tight up to a factor of order log(L/ε), for every protocol.

*LB3 (stochastic).* Let L ≥ 3 be odd and ε ≤ 1/23. Class of two samplers: P₊ and P₋ answer every input with a Bernoulli(½ + a) and a Bernoulli(½ − a) bit. Scaffold: L calls, the run records the answers. If a protocol with q questions returns, under each of the two, with probability at least ¾, an answerer whose run law is within 4ε of the human system in total variation (in particular if its expected total variation is at most ε), then q ≥ (L − 1)/(2048·ε²). *Proof.* (i) TV(Q₊, Q₋) ≥ a·√((L − 1)/2) when a² ≤ 1/(4(L − 1)): with L = 2r + 1 and g(p) the probability that a Binomial(L, p) exceeds r, g′(p) = (2r + 1)·C(2r, r)·(p(1 − p))^r ≥ √r·(1 − 4(p − ½)²)^r, using C(2r, r) ≥ 4^r/(2√r); so g(½ + a) − g(½ − a) ≥ 2a√r·(1 − 4a²r) ≥ a√r (checked numerically for L up to 401). (ii) Choose a slightly above 8ε·√(2/(L − 1)), so that TV(Q₊, Q₋) > 8ε; then the events "within 4ε of Q₊" and "within 4ε of Q₋" are disjoint, the transcript distinguishes the two hypotheses with both error probabilities at most ¼, and the total variation between the two transcript laws is at least ½. (iii) Every answer is a Bernoulli(½ ± a) bit whatever is asked, so the squared Hellinger distance (1 − Σ√) between the transcript laws is at most 1 − (1 − 4a²)^{q/2} ≤ 2a²q and their total variation at most 2a√q. Hence q ≥ 1/(16a²). ∎ Compare D(d): 7·L·K ln 2/ε² with K = 1.

**Reading.** In a closed system with single-call questions, run-level total variation ε costs Θ(L/ε) questions for a deterministic human and Θ(L/ε²) for a stochastic one, up to the factor K (which LB2 shows to be needed up to a logarithm in the deterministic case) and constants. Every call that can spoil the run must be paid for.

### 5.5 Variants of the loop

**All calls of a rollout labelled, one shared mixture frozen during the rollout** [own]. Let M^(t) be the posterior mixture after t − 1 fully labelled rollouts. Given the rollout, its labels are independent draws from P(·|x_j), because in DAgger the labels do not steer the run. The Bayes regret over batches gives Σ_t E KL(⊗_j P(·|x_j) ‖ M^(t)_joint) ≤ K ln 2, where M^(t)_joint := Σ_ν w_t(ν)·Π_j ν(·|x_j). The per-call mixture M^(t)(·|x_j) is the j-th marginal of M^(t)_joint, so:

* by data processing, H²(P(·|x_j), M^(t)(·|x_j)) ≤ H²(⊗P, M^(t)_joint) ≤ ½·KL(⊗P ‖ M^(t)_joint) for each j, hence Σ_t E Σ_run H²_t(x_j) ≤ L·K ln 2/2;
* for a deterministic human, by Hölder's inequality Π_j M^(t)(f(x_j)|x_j) ≥ (M^(t)_joint(f-labels))^L, hence Σ_t E Σ_run (−ln M^(t)(f(x_j)|x_j)) ≤ L·K ln 2;
* the corresponding statement for KL with a stochastic human is false in general: the per-call sum of KL can exceed the joint KL by the entropies of the labels (the error recorded in Section 12 of `candidate-theory.md`).

So n fully labelled rollouts, n·L questions, give the per-run bound L·K ln 2/n that Protocol R gets from n questions. This is the delayed-feedback factor (regret multiplied by the batch length: Joulani, György and Szepesvári, "Online Learning under Delayed Feedback", ICML 2013 [mem]; Weinberger and Ordentlich, "On delayed prediction of individual sequences", IEEE Transactions on Information Theory 2002 [mem]), and it is the "spurious H" of log-loss DAgger. Extra labels are harmless as data but the worst-case bound per label is L times worse.

**One hypothesis per run** (first-step mixing). With whole-run annotation this is Tragger, 2R(log B + 2 log(1/δ))/N for N annotated runs (Li–Zhang) [read]. With one audited call per run it is R4 of the candidate, Σ_t Pr[run of round t is not a run of the human system] ≤ 2L·K ln 2 for a deterministic human. I re-derived R4: for independent posterior draws g, g′ and the first index j*(h) at which h leaves the f-run, the event {j*(g′) ≤ j*(g), j*(g′) < ∞, J = j*(g′)} has probability at least (1/(2L))·Pr[g-run unfaithful] and on it g′ is refuted, so the expected posterior mass removed per round is at least that, and the total of −ln(1 − removed mass) is at most ln(1/w(f)) [own]. Li and Zhang list "state-wise annotation with first-step mixing" as open. R4 gives the run-level bound for it; it does not give a bound on the number of unfaithful calls, so no μ-version follows.

**Executing the human's answer with some probability during rehearsal** (the β_i of DAgger and SMILe). Each executed human answer is a question. Theorem 4.1 of DAgger charges 2ℓ_max·min(1, Lβ_i) per round for the difference between the mixed policy's inputs and the learner's own. In a closed system where questions are the only cost, β = 0 is the natural choice, and Protocol R uses it [own]. The lower bounds of Foster, Block and Misra hold when the learner may choose its actions after seeing the expert's annotation at training time [read: a footnote of theirs].

**Auditing during deployment with probability p per call** (the human stays). The regret bound gives, for a deterministic human, at most K ln 2/p expected unaudited unfaithful calls over the whole deployment, at p·(number of calls) questions; this is the label-efficient trade-off treated in `ask-for-help.md`, §3.4. Rehearsal is the version in which all audits happen before the run that counts.

**Choosing the question.** With unbounded compute and a closed system the learner can search its rollouts for inputs on which the posterior disagrees. For a finite class of functions this identifies the human on the reachable inputs with at most |H| − 1 questions (each question at a point of disagreement refutes at least one member); with a prior, "ask where the leading hypotheses disagree" is sound only if the truth is among the leaders, which costs a number of questions of order 1/w(P) (the top-set results in `ask-for-help.md`). LB1 and LB2 hold for adaptive protocols. Active selection therefore helps on classes with few patches and not in the worst case [own].

### 5.6 What interaction buys in a closed system, and what it does not

[own, from §3–§5.]

* **Not a better rate for whole-run fidelity.** Recorded runs of the human system and rehearsal need the same number of human answers, L·K ln 2/ε for a deterministic human; for a stochastic human rehearsal's bound is 14 times larger (the constant 7 of F3 against the exact chain rule F2). This agrees with the lower bounds of Foster, Block and Misra: for general classes interaction does not help.
* **Single calls instead of runs.** To record a run of the human system the human must answer every call of it, in the order the scaffold fixes, with later inputs built from the human's own earlier answers. Rehearsal never asks for this. Without recorded runs, inputs with the deployment distribution can be sampled only from imitator-driven runs; any other source of questions (random prompts, a broad prior over tasks) pays a density-ratio factor (S1 and S2 of the candidate). A DAgger-style loop is the direct way to put the human's answers on the deployment distribution. In the literature this is the difference between trajectory-wise and state-wise annotation; Li and Zhang note that in practice one interactive label is expected to cost more than one offline pair (their factor C).
* **The number of unfaithful calls.** F1 bounds the probability of a first deviation on either distribution, but after a deviation an imitator trained on the human system's inputs is on inputs it was never trained on. Recorded runs give β ≤ L·TV only. Rehearsal gives β ≤ L·K ln 2/n directly, and μ·β is the outcome loss under recoverability. This is where the factor R/μ of Li and Zhang, and the factor θL of the candidate's R3, come from.
* **A certificate.** DAgger "returns the best π̂_i on validation"; with one audited call per validation run the validation set is an i.i.d. sample of the deployed imitator's per-call disagreement, which is the candidate's V1.
* **Known dynamics** help in the literature by matching the expert's state–action frequencies beyond the seen states (Mimic-MD, replay estimation, moment matching). That improves additive performance from L² to L^{3/2} or L and needs recorded runs. For the law of the whole run it gives no improvement that I know of.

### 5.7 Recoverability as the standard form of "low stakes"

The imitation-learning literature states the low-stakes condition as recoverability: one wrong action followed by the expert costs at most μ (Ross, Gordon and Bagnell's u; the μ of Rajaraman and co-authors, Foster and co-authors, Li and Zhang; the H of Swamy and co-authors). In the project's terms: for every partial run and every replaced answer, the expected outcome with the human answering all later calls falls by at most μ. Then D(f) gives an expected outcome loss of at most μ·L·K ln 2/n for a deterministic human, with no further assumption on the scaffold [own from F4].

Relation to the candidate's R3 [own]. "Tolerates m faults with failure δ" asks the human system to survive m replaced answers chosen adversarially with knowledge of the human's answer. Recoverability asks only about one replaced answer followed by the human, and then pays μ for every unfaithful call in expectation. For a deterministic human and the outcome 1[run is good], μ-recoverability implies tolerance of m faults with failure δ₀ + m·μ, where δ₀ is the failure probability of the human system itself: apply F4 to the replacement rule, whose only non-zero terms are at the at most m replaced calls. The converse fails, because μ is a supremum over all partial runs and tolerance is a statement about probability from the start of the run. So the two conditions are not equivalent, and the bounds differ: R3 applied to the implied tolerance gives δ₀ + m·μ + β/(m + 1), of order δ₀ + √(μβ) at the best m, while F4 applied directly gives δ₀ + μ·β. The recoverability form has two further advantages: the human system's own runs can estimate μ at sampled partial runs (replace one answer, let the human finish), and its conclusion needs no Markov step. If μ ≈ c/L the number of questions does not depend on L; for a chain in which one wrong step spoils everything μ = 1 and the bound is the union bound again. For stochastic humans the signed constant μ̃ appears, and Foster, Block and Misra ask whether μ can replace it [read].

### 5.8 Two criteria for a stochastic human

[own.] D(d) bounds E_data[TV(Q_{M^(T)}, Q_P)]: the trained imitator's run law is close to the human system's. A weaker criterion is TV(E_data[Q_{M^(T)}], Q_P): one deployed run, averaged over the training randomness, is distributed nearly as a run of the human system. They can differ by a square. Example: the human answers every call with a Bernoulli(θ) bit; after q answers the plug-in imitator uses θ̂ with |θ̂ − θ| ≈ 1/√q, so its run law is at distance about √(L/q) from the human system's; but the law averaged over θ̂ is only overdispersed, the count of ones has variance (L/4)(1 + L/q) in place of L/4, and its distance is of order L/q. LB3 concerns the first criterion.

Which criterion is right depends on use. If the trained imitator is run once, the second describes that run. If it is run many times, the runs share the training error and the first criterion is the relevant one. The literature has both: Rajaraman and co-authors (2020) prove a 1/N rate *in expectation* for stochastic tabular experts by a coupling with an unbiased estimate; Foster, Block and Misra (2024) prove that with constant probability the rate is 1/√n and call the 1/N rate "an artifact of the tabular setting" [read]. Whether a bound of order L·K/ε holds for the averaged criterion with a general class is not settled by anything I read.

---

## 6. Relation to `candidate-theory.md` (version 2) and `note.md`

[own assessments; the citations are [read] unless tagged.]

| statement there | status in the literature |
|---|---|
| L1 (chain rule), L2 (coupling) | standard. L2 is the argument of Ross–Bagnell's Theorem 2.1 and the symmetric trajectory metric ρ of Foster–Block–Misra. |
| L3 (Bayes regret on adaptive questions) | standard; the conversion to on-policy estimation error, with a high-probability form, is Lemma A.14 of Foster, Kakade, Qian and Rakhlin (2021). |
| L4 (Hellinger subadditivity, c₀ = 7) | **the constant 7 is the lemma of Foster, Han, Qian and Rakhlin (2024, arXiv:2404.10122, appendix "Technical Tools")**. Lemma A.13 of Foster, Kakade, Qian and Rakhlin (2021) has 10²·log(n). The expectation may be under either law. A self-contained proof is not needed. |
| Protocol R, Theorem R1 | for a deterministic human and a finite class this is Stagger and its theorem (Li and Zhang, NeurIPS 2025). New relative to it: prior on a countable class, stochastic humans, assumption A3. Earlier relatives: forward training asks one step per trajectory (Ross–Bagnell 2010); RAIL asks single states on the previous policy's distribution (Judah–Fern–Dietterich 2012). |
| Theorem R2 (whole runs) | deterministic case: Li–Zhang's proof contains it (their λ(π ‖ π^E) bounds the deviation probability). Stochastic case, √(7LK ln 2/n): Lemma A.14 plus the 2024 subadditivity lemma; I did not find it stated. |
| Theorem R3 (fault tolerance) | the literature's form is recoverability (§5.7). Suggest stating the μ-form beside R3. |
| Theorem R4 (one hypothesis per run, one audited call) | whole-run annotation: Tragger. Single-call audit: listed as open by Li and Zhang; R4's argument is correct as far as I can check and gives the run-level bound. |
| R5, R6 (committee or one mind; no MAP in the loop) | compare: proper learners cannot have sublinear regret in classification-based online imitation in general (Li–Zhang 2022, non-realisable); the last iterate can diverge (Cheng–Boots 2018). When every call is critical the roles reverse: a hypothesis of posterior weight w that is wrong at every call of some kind of run spoils such a run with probability w under one draw per run and with probability about min(1, L·w) under a fresh draw per call [own]. |
| Theorem A (posterior draw per run from recorded runs) | the Bayes form of Foster–Block–Misra's supervised-learning proposition for log-loss BC. |
| N2 (critical steps are not amplified) | L = 1 analogues: Theorem 2.2 and the active lower bound of Foster–Block–Misra. The L-call version addresses, in the non-recoverable regime, what Li and Zhang call open. LB2 above adds the factor K up to a logarithm; LB3 adds the stochastic case. |
| V1 (validation) | DAgger's "return best π̂_i on validation"; the note that validation needs extra labels is in Li–Zhang 2025. |
| S1, S2 (density ratio; closure of the task distribution) | Christiano, Shlegeris and Amodei (2018) chose task distributions so that sub-questions are in distribution. |
| Pr3, Pr4 (test matching) | the moment-matching and IPM literature (Swamy et al. 2021; Sun et al. 2019, including the theorem that unrestricted discriminators do not generalise); for misspecified classes, the ρ-estimator bound of Rohatgi and co-authors (2025), D²_H ≲ log(\|Π\|/δ)/n + min_π D²_H, is an oracle inequality with constant approximation factor on whole runs. |

**Points to carry into the note.**

1. Cite Li and Zhang (2025) for the protocol and Foster, Block and Misra (2024) for the horizon-free log-loss analysis and the lower bounds; cite Foster, Han, Qian and Rakhlin (2024) for the constant 7.
2. Say where the horizon enters: not in the run-level statistics (per run), but in the count of answers (L per run) and in the count of unfaithful calls.
3. State what rehearsal adds over recorded runs (§5.6) in those terms; the claim "interaction helps" without them contradicts the published lower bounds.
4. Keep one audited call per rehearsal run; note the factor L for full annotation.
5. Add the recoverability form of low stakes.
6. For stochastic humans say which criterion (§5.8) each theorem controls.
7. The realisability assumption A2 carries the horizon-free claims; under misspecification log-loss imitation can amplify error by a factor of order L (Rohatgi and co-authors 2025).

---

## 7. What I could not verify, and cautions

* Rajaraman, Han, Yang, Liu, Jiao and Ramchandran (NeurIPS 2021) was not read; its bounds are from a snippet and from two papers' descriptions. The proceedings PDF is at `proceedings.neurips.cc/paper/2021/file/09dbc1177211571ef3e1ca961cc39363-Paper.pdf` (host blocked here).
* Ross and Bagnell (2010): proofs and the tightness example are in a supplement I did not read; the SMILe parameter α was read from garbled PDF text.
* Theorem numbers of Rajaraman and co-authors (2020) and of Foster, Block and Misra (2024) are given only where a citing paper fixes them.
* Venues tagged [mem] were not checked against proceedings.
* Everything tagged [own] is unrefereed. LB2 is a sketch. LB3's constant is crude. F3 is applied to runs padded to length L with the scaffold's deterministic steps as identical kernels under both laws; I see no difficulty but did not write out measurability.
* The statements for deterministic humans treat "the answer" as exactly reproducible. For long string answers a human is not a function; the stochastic statements are then the relevant ones, with their 1/ε² rate.
* All bounds contain K. For a person K is not a number anyone can evaluate, and the literature's log|Π| has the same status for large models. The comparisons above (who pays the factor L, what interaction changes) do not depend on its size.

---

## 8. References

Read in this session unless marked.

* Ching-An Cheng, Byron Boots. "Convergence of Value Aggregation for Imitation Learning." AISTATS 2018. arXiv:1801.07292.
* Paul Christiano, Buck Shlegeris, Dario Amodei. "Supervising strong learners by amplifying weak experts." arXiv:1810.08575, 2018.
* Dylan J. Foster, Adam Block, Dipendra Misra. "Is Behavior Cloning All You Need? Understanding Horizon in Imitation Learning." NeurIPS 2024. arXiv:2407.15007.
* Dylan J. Foster, Yanjun Han, Jian Qian, Alexander Rakhlin. "Online Estimation via Offline Estimation: An Information-Theoretic Framework." arXiv:2404.10122, 2024.
* Dylan J. Foster, Sham M. Kakade, Jian Qian, Alexander Rakhlin. "The Statistical Complexity of Interactive Decision Making." arXiv:2112.13487, 2021 (v3, 2023).
* Jonathan Ho, Stefano Ermon. "Generative Adversarial Imitation Learning." NIPS 2016. arXiv:1606.03476.
* Kshitij Judah, Alan P. Fern, Thomas G. Dietterich. "Active Imitation Learning via Reduction to I.I.D. Active Learning." UAI 2012. arXiv:1210.4876.
* Liyiming Ke, Sanjiban Choudhury, Matt Barnes, Wen Sun, Gilwoo Lee, Siddhartha Srinivasa. "Imitation Learning as f-Divergence Minimization." WAFR 2020 [venue: mem]. arXiv:1905.12888.
* Yichen Li, Chicheng Zhang. "On Efficient Online Imitation Learning via Classification." NeurIPS 2022. arXiv:2209.12868.
* Yichen Li, Chicheng Zhang. "Interactive and Hybrid Imitation Learning: Provably Beating Behavior Cloning." NeurIPS 2025. arXiv:2412.07057.
* Nived Rajaraman, Lin F. Yang, Jiantao Jiao, Kannan Ramchandran. "Toward the Fundamental Limits of Imitation Learning." NeurIPS 2020 [venue: mem]. arXiv:2009.05990.
* Nived Rajaraman, Yanjun Han, Lin F. Yang, Kannan Ramchandran, Jiantao Jiao. "Provably Breaking the Quadratic Error Compounding Barrier in Imitation Learning, Optimally." arXiv:2102.12948, 2021.
* Nived Rajaraman, Yanjun Han, Lin Yang, Jingbo Liu, Jiantao Jiao, Kannan Ramchandran. "On the Value of Interaction and Function Approximation in Imitation Learning." NeurIPS 2021, pp. 1325–1336. **Not read.**
* Dhruv Rohatgi, Adam Block, Audrey Huang, Akshay Krishnamurthy, Dylan J. Foster. "Computational-Statistical Tradeoffs at the Next-Token Prediction Barrier: Autoregressive and Imitation Learning under Misspecification." COLT 2025 (PMLR 291). arXiv:2502.12465.
* Stéphane Ross, J. Andrew Bagnell. "Efficient Reductions for Imitation Learning." AISTATS 2010, PMLR 9:661–668.
* Stéphane Ross, J. Andrew Bagnell. "Reinforcement and Imitation Learning via Interactive No-Regret Learning." arXiv:1406.5979, 2014.
* Stéphane Ross, Geoffrey J. Gordon, J. Andrew Bagnell. "A Reduction of Imitation Learning and Structured Prediction to No-Regret Online Learning." AISTATS 2011. arXiv:1011.0686.
* Ayush Sekhari, Karthik Sridharan, Wen Sun, Runzhe Wu. "Selective Sampling and Imitation Learning via Online Regression." NeurIPS 2023 [venue: mem]. arXiv:2307.04998 (abstract).
* Max Simchowitz, Daniel Pfrommer, Ali Jadbabaie. "The Pitfalls of Imitation Learning when Actions are Continuous." arXiv:2503.09722, 2025 (abstract).
* Wen Sun, Anirudh Vemula, Byron Boots, J. Andrew Bagnell. "Provably Efficient Imitation Learning from Observation Alone." ICML 2019 [venue: mem]. arXiv:1905.10948.
* Gokul Swamy, Sanjiban Choudhury, J. Andrew Bagnell, Zhiwei Steven Wu. "Of Moments and Matching: A Game-Theoretic Framework for Closing the Imitation Gap." ICML 2021 [venue: mem]. arXiv:2103.03236.
* Gokul Swamy, Nived Rajaraman, Matthew Peng, Sanjiban Choudhury, J. Andrew Bagnell, Zhiwei Steven Wu, Jiantao Jiao, Kannan Ramchandran. "Minimax Optimal Online Imitation Learning via Replay Estimation." NeurIPS 2022 [venue: mem]. arXiv:2205.15397 (abstract and main theorem).
* Tian Xu, Ziniu Li, Yang Yu. "Error Bounds of Imitating Policies and Environments." NeurIPS 2020. arXiv:2010.11876.

Cited as described in the above, or from memory, not opened: Umar Syed, Robert E. Schapire, "A Reduction from Apprenticeship Learning to Classification", NIPS 2010; Matti Kääriäinen, "Lower bounds for reductions", 2006; Hal Daumé III, John Langford, Daniel Marcu, "Search-based structured prediction", Machine Learning 2009; Pooria Joulani, András György, Csaba Szepesvári, "Online Learning under Delayed Feedback", ICML 2013; Marcelo J. Weinberger, Erik Ordentlich, "On delayed prediction of individual sequences", IEEE Transactions on Information Theory 2002; Nicolò Cesa-Bianchi, Gábor Lugosi, *Prediction, Learning, and Games*, 2006; Alekh Agarwal, Nan Jiang, Sham M. Kakade, Wen Sun, *Reinforcement Learning: Theory and Algorithms*; T. S. Jayram, "Hellinger strikes back", 2009.
