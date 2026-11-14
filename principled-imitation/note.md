# Imitating a human inside a computation we can run in advance

*A protocol, its theorems and its limits. Draft in progress: Sections 1 to 3 are written; the other sections are being proved and checked (see `research/`).*

## 1. The model

**The human.** Inputs and answers are strings; X is the set of inputs and Y the set of answers, both countable. A *sampler* S assigns to every input x a probability distribution S(·|x) on Y. The human is a sampler P: each time a question x is put to the human, the answer is a fresh draw from P(·|x), independent of everything else given x. This is assumption **A1**. When P(·|x) is a point mass for every x we write f for the function it defines and call the human *deterministic*.

A1 says that the human has no memory from one question to the next. Whatever must be remembered travels in the input: a question may contain a notebook. One question may also stand for a long episode of work; nothing below depends on its length.

**The class.** H is a countable set of samplers, and w gives each ν in H a weight w(ν) > 0, with total weight at most 1. Assumption **A2**: the human P is in H. We write

  K := log₂(1/w(P)).

If H is the set of all samplers computable by a program and w(ν) = 2^(−length of the shortest program), then K is the description length of the human. All statements hold for every H and w; a class of programs with a time bound makes every object below computable.

After data D = ((x₁, y₁), …, (x_k, y_k)), the posterior weight of ν is proportional to w(ν)·ν(y₁|x₁)⋯ν(y_k|x_k), and the *mixture* is the sampler

  M_D(y|x) := Σ_ν (posterior weight of ν)·ν(y|x).

To answer a question with the mixture, draw a hypothesis from the posterior and let it answer; a fresh hypothesis is drawn at every question. On question–answer pairs with the class of all programs this is Solomonoff's per-query predictor.

**The scaffold.** A *scaffold* Π is a program that turns answers into further questions. It draws a top-level input z from a distribution D₀ and its own random bits ρ. Then, for j = 1, 2, …, it computes the next question x_j from z, ρ and the answers y₁, …, y_{j−1} received so far, or stops; it asks at most L questions (L is the *horizon*); at the end it computes an *outcome* from z, ρ and the answers. One execution is a *run*; the questions of a run are its *calls*. Task decomposition is a scaffold: a call may ask for a plan, later calls for the parts, later ones for a check or a summary. A single question is the scaffold with L = 1.

An *answerer* is whatever answers the calls. If the human answers every call we get the *human system*, and Q_P denotes the law of its runs. If a sampler S answers every call, Q_S is the law of the run. The human system is the thing to be imitated: we want the run of the imitator to be distributed like the run of the human system, or at least its outcome to be as good.

**Closed systems.** A scaffold is a *closed system* if we can sample z and ρ ourselves, so that we can run it with any answerer we have, as often as we like, before the run that counts. A fixed research question worked on by a tree of calls is a closed system. A service that answers questions arriving from a changing world is not: its top-level inputs come from outside (Section 6).

**Faithful calls.** To compare a run of an imitator A with the human system, draw, at each call, the imitator's answer y_j and a *shadow* answer y′_j ∼ P(·|x_j) jointly, so that they are equal with the largest possible probability, which is 1 − TV(A(·|x_j), P(·|x_j)). The run continues with y_j. A call is *unfaithful* if y_j ≠ y′_j. The run of the imitator is then a run of the human system in which the answers at the unfaithful calls were replaced. If no call is unfaithful, the run *is* a run of the human system. For a deterministic human a call is unfaithful exactly when the imitator's answer differs from f(x_j).

**The protocol's coins.** Assumption **A3**: the random choices of the protocol below (the bits of each run, and which call is put to the human) are fresh: independent of the human's coins and not predictable by any hypothesis. Physical randomness has this property.

## 2. The protocol: rehearse, validate, deploy

**Rehearse.** For t = 1, …, n:

1. Let M^(t) be the mixture given the questions answered so far.
2. Run the scaffold to the end with M^(t) answering every call. This uses computation only.
3. Choose J uniformly from {1, …, L}. If the run made at least J calls, put the J-th question of this run to the human and add the question and the answer to the data.

**Validate.** Freeze an imitator A (the last mixture, or anything else). For i = 1, …, m: run the scaffold with A, choose J as before, put the J-th question to the human, and record the human's answer next to the answer A gave in the run. Nothing is updated.

**Deploy.** Run the scaffold with the validated imitator. If validation is skipped, draw T uniformly from {1, …, n} and deploy M^(T).

The human answers n + m single calls and never has to carry out a run. The questions come from the imitator's own runs, at every depth, so the inputs that task decomposition produces are put to the human during rehearsal with the frequency with which they occur. Rehearsal with a mixture is the method of Ross, Gordon and Bagnell (2011) for imitation learning, a learner without regret trained on the inputs that its own behaviour produces, with the Bayes mixture as the learner and one question per run.

## 3. What the protocol guarantees

### 3.1 Each call

**Theorem R1 (per-call closeness on the imitator's own inputs).** Assume A1 to A3. Write KL_t(x) for the divergence KL(P(·|x) ‖ M^(t)(·|x)) in nats. Then

  Σ_{t=1}^{n} E[ Σ_{calls x of the run of round t} KL_t(x) ] ≤ L·K ln 2.

So the imitator M^(T) of a uniformly chosen round satisfies E[Σ_{calls x of its run} KL(P(·|x) ‖ M^(T)(·|x))] ≤ L·K ln 2 / n. For a deterministic human, the expected number of unfaithful calls, summed over all n rehearsal runs, is at most L·K ln 2; the run of M^(T) has at most L·K ln 2/n unfaithful calls in expectation and is a run of the human system with probability at least 1 − L·K ln 2/n.

*Proof.* Let (x_t, y_t) be the question and answer of round t, if there is one. For every hypothesis ν the posterior weight after k pairs is w(ν)·Π_{i≤k} ν(y_i|x_i) divided by Σ_ν′ w(ν′)·Π_{i≤k} ν′(y_i|x_i), so the product of the mixture's predictive probabilities telescopes: Π_t M^(t)(y_t|x_t) = Σ_ν w(ν)·Π_t ν(y_t|x_t) ≥ w(P)·Π_t P(y_t|x_t). Hence Σ_t ln(P(y_t|x_t)/M^(t)(y_t|x_t)) ≤ ln(1/w(P)) on every path. The question x_t is a function of the earlier data and of fresh randomness (the run of round t and the index J), and y_t is then drawn from P(·|x_t) by A1 and A3; so the conditional expectation of the t-th summand given everything before y_t is drawn is KL_t(x_t) ≥ 0, which is finite because M^(t) ≥ (posterior weight of P)·P. Taking expectations gives Σ_t E[KL_t(x_t)·1{a question was asked in round t}] ≤ K ln 2. Since J is uniform on {1, …, L} and independent of the run, the t-th term equals (1/L)·E[Σ_{calls x of the run of round t} KL_t(x)]. This is the first claim; the second is its average over t. For a deterministic human, a call x is unfaithful with probability e = 1 − M^(t)(f(x)|x) given the run so far, and KL_t(x) = −ln(1 − e) ≥ e. ∎

The inequality used is the standard regret bound for Bayes mixtures (Solomonoff 1978 for sequences; for question–answer pairs with adaptively chosen questions see Paper 1 of this repository, Theorem 5.3 and Proposition 5.7). What the protocol adds is that the bound is spent on the distribution that matters: the divergence is measured at the calls of the imitator's own runs.

Three remarks. First, the bound holds for every class and every prior. A hypothesis that models the world, or the way the data were collected, or the reader, is one more sampler: if it answers the calls of the imitator's runs differently from the human with frequency ρ per call, each question lowers its weight relative to the human's by an expected factor that depends on ρ only, and the theorem bounds the total effect of all such hypotheses by K. Second, the reference machine enters only through K. Third, no property separates the questions of the deployed run from the questions put to the human: they have the same distribution. A hypothesis of the form "the human, except that on inputs with property Q it does something else" is refuted at a rate equal to the frequency of Q among the calls. The depth of a call in a decomposition is not such a property, because rehearsal runs go to full depth.

### 3.2 Low stakes

A run of L calls is entirely faithful with probability 1 − L·K ln 2/n, which needs more questions than the run has calls. Section 4 shows that no protocol avoids this when every call is critical. It can be avoided when the human system itself does not depend on every call.

**Definition.** Fix a set G of good runs. The human system *tolerates m faults with failure δ* if the following holds for every rule that, at each call, sees the run so far and the human's answer and may replace that answer by any other: if the rule replaces at most m answers in any run, the run is in G with probability at least 1 − δ.

**Theorem R3 (low stakes).** Let A be an imitator whose run has β unfaithful calls in expectation. If the human system tolerates m faults with failure δ, the run of A is in G with probability at least 1 − δ − β/(m + 1). For M^(T) and a deterministic human, β ≤ L·K ln 2/n; so if a fraction θ of the calls may be replaced (m = θL), the failure probability is at most

  δ + K ln 2/(θ·n),

whatever the horizon L.

*Proof.* By Section 1 the run of A is a run of the human system with the answers at the unfaithful calls replaced by a rule that sees the human's (shadow) answer. Change the rule so that it stops replacing after m replacements. The changed rule is admissible, so its run is in G with probability at least 1 − δ. The two runs coincide unless the run of A has more than m unfaithful calls, and by Markov's inequality this has probability at most β/(m + 1). ∎

For a human who is not deterministic, Theorem R1 and Pinsker's inequality give β ≤ L·√(K ln 2/(2n)), and the failure probability is at most δ + √(K ln 2/(2n))/θ.

A sufficient condition for tolerance is that no single call can do much damage and that the human makes progress from wherever the run stands.

**Proposition R3a (bounded damage).** Let the scaffold be sequential with a state s_j after call j, and let φ be a real function of the state. Suppose that from every state, a call answered by the human raises φ by at least μ > 0 in expectation and changes it by at most 1; and that from every state, a call answered in any way lowers φ by at most D. Call a run good if φ rises by at least (1 − η)·μL over the run. Then the human system tolerates m faults with failure δ whenever m·(1 + D) + √(8L ln(1/δ)) ≤ η·μL.

*Proof.* Let Δ′_j be the change of φ that the human's shadow answer would have caused at call j, and Δ_j the actual change. Then Δ_j = Δ′_j at faithful calls and Δ_j ≥ −D ≥ Δ′_j − (1 + D) at the others, so the total rise is at least Σ_j Δ′_j − m(1 + D). The Δ′_j have conditional mean at least μ given the past and lie in [−1, 1], so by the Azuma–Hoeffding inequality Σ_j Δ′_j ≥ μL − √(8L ln(1/δ)) with probability at least 1 − δ. ∎

With m proportional to L the number of questions needed, K ln 2·L/((m + 1)·δ′) for an additional failure probability δ′, is about K ln 2·(1 + D)/(η·μ·δ′): it does not grow with the length of the run. A chain in which one wrong step spoils everything has D of the order of L and tolerates nothing.

### 3.3 The certificate

**Theorem V1 (validation).** Let A be any answerer, however it was obtained, and let the human be any process that answers single calls with fresh coins. Run the validation phase with m questions.

(a) Let the human be deterministic, and let ρ be the expected number of unfaithful calls in a run of A, divided by L. The recorded pairs disagree with probability ρ, independently. If no pair disagrees, then with confidence 1 − δ we have ρ ≤ ln(1/δ)/m: the run of A has at most L·ln(1/δ)/m unfaithful calls in expectation, and Theorem R3 applies with β = L·ln(1/δ)/m.

(b) In general, let 𝓑 be a countable family of sets B of pairs (question, answer), with weights π(B) of total at most 1, fixed before validation. For B in 𝓑 let Δ(B) be the expected number of calls of a run of A whose answer lies in B, minus the expected number of those calls at which the human's answer would lie in B, divided by L. With confidence 1 − δ, simultaneously for all B in 𝓑, Δ(B) is within √(2 ln(2/(π(B)·δ))/m) of the difference of the two recorded frequencies.

*Proof.* The m validation rounds are independent and identically distributed because A is frozen. In (a) the recorded pair of one round disagrees with probability (1/L)·E[number of unfaithful calls of the run], which is ρ; if ρ > ln(1/δ)/m, the probability of no disagreement in m rounds is (1 − ρ)^m < δ. In (b) the difference of the two indicators of B in one round lies in [−1, 1] and has mean Δ(B); apply Hoeffding's inequality with failure probability π(B)·δ and sum over B. ∎

Part (a) needs neither A2 nor any property of the learning method: in a closed system, how well an imitator imitates on its own deployment distribution can be measured. Theorem R1 says how many questions an ideal learner needs before the measurement comes out well. Part (b) is what can be measured when the human is not deterministic. No number of single answers at inputs that never repeat reveals the distribution P(·|x) at any one input; only frequencies of tests can be estimated. Section 8 returns to this.
