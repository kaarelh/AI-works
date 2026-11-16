# Imitating a human inside a computation we can run in advance

A protocol, its theorems and its limits. Research note, November 2026.

*Status.* Every numbered statement says whether it is proved here, standard, or open. The proofs are in `proofs/`, one file for each part of the note. Each proof file was examined by a referee who went through it line by line and by a second who tried to break it; their reports and the reports on this text are in `verification/`. The last section of each proof file lists every finding and what was done about it, and names the statements that only one checker has seen.

## 0. The question, and the answers in brief

**The question.** A human is modelled as a sampler P: given an input string x, the human returns a random string y drawn from P(·|x), afresh each time. We may put questions to the human for a while. Then the human leaves, and a sampler built from the answers takes the human's place inside a larger computation: a *scaffold* that splits a task into pieces and calls the human many times, writing later inputs from earlier answers. Compute is free; answers from the human are not. We want a protocol, and a theorem saying that the computation behaves with the imitator as it would with the human, although the imitator's inputs are then written by the imitator itself; or at least that it fails only in ways that show.

**The answers.**

1. **A protocol with a theorem exists for computations that can be run in advance** (Sections 2 and 3). *Rehearse:* run the scaffold with the current Bayes mixture giving every answer; choose one call of that run uniformly at random and put it to the human; update the mixture; after n rounds deploy the mixture of a uniformly chosen round. This is the idea of asking the human again, with some probability, on the inputs that task decomposition produces. If the human is in the class with prior weight 2^(−K) and a run makes at most L calls, then the divergence between human and mixture, added up along the mixture's own run and then over all rounds, is at most L·K ln 2 in expectation (Theorem R1). So for a human who always gives the same answer to the same question, the deployed run is exactly the run the human would have produced, except with probability L·K ln 2/n; and for any human the law of the deployed run is within √(2·L·K ln 2/n) of the human system's in total variation, in expectation (Theorem R2). The human answers n single questions and is not needed again. For a finite class and a deterministic human, protocol and bound are known: it is the algorithm "Stagger" of Li and Zhang (2025), an instance of the reduction of Ross, Gordon and Bagnell (2011). The note adds the human who varies, two checks, and the limits.

2. **Two checks assume nothing about the class or the prior** (Section 3). *Coverage* (R7): for any region of inputs fixed in advance, the deployed run enters the region without the human ever having been asked a question in it with probability at most L/n, whatever the human is. *Certificate* (V1): freeze the imitator and compare it with the human on m further calls drawn from its own runs. If no disagreement is recorded then, at confidence 1 − δ, a run of the imitator has at most L·ln(1/δ)/m unfaithful calls in expectation. Such a certificate can only be obtained when the human is nearly deterministic on those inputs. For a human who varies, what can be certified without assumptions is the frequency of each test from a weighted family and, with questions put twice, a squared distance between answer distributions (Pr7, Section 8.7).

3. **When no single answer is critical, the price does not grow with the computation** (Section 3). If the human system reaches a good outcome even when any θL of its answers are replaced, then n = K ln 2/(θδ) questions keep the added failure probability below δ for a deterministic human, whatever L is. For a human who varies the bound is √(K ln 2/(2n))/θ, and an example needs of the order of K/θ² questions.

4. **In general nothing does better, and these are theorems as well** (Sections 4, 6 and 7).
   * Where no question was asked and the answers elsewhere do not settle the matter, every behaviour is consistent with the data (N1).
   * If each of L calls can decide the outcome, there is a class of candidates of log₂(L/2δ) bits for which every protocol needs at least L/(4δ) − L questions to keep the failure probability of a run below δ (N2). For one such run it is cheaper to let the human make the L calls. What imitation buys is reuse: the questions are paid once, and the imitator can then be run any number of times.
   * Inputs from outside the rehearsed law cost the density ratio; N possible shifts cost a factor N; all shifts describable in ℓ bits cost 2^ℓ (S1 to S3, N3).
   * A rule that is never silently wrong must ask or abstain wherever two candidates that fit the answers so far differ; for some classes that is every new input (N4). The abstaining rules, with a parameter that makes their soundness a theorem, refuse every new input that a test of fewer than about K bits separates from the asked ones; with a milder parameter the same rules are whitelists, sound under an assumption that the data cannot confirm (Section 7).
   * In an open system the human cannot leave early: on a class of 2^K thresholds, the expected number of silent errors and abstentions, multiplied by the number of questions plus one, is at least 3·2^K/16; a deterministic human can leave after about 2^K questions (N7).

5. **The property idea gives a second guarantee, cheaper and weaker** (Section 8). Call a property a *test*: a set of (question, answer) pairs, taken from a family with weights π. An imitator can be built from the tests alone, with no class of hypotheses (Theorem Pr5): on every sequence of questions, whatever the human is, its count of answers in each test B stays within √((n + 1)(2 ln(1/π(B)) + ln(n + 1) + 1.39)) of the human's, and a kind of answer that the human never gives is given at most log₂(1/π(B)) + 2 times in total. A property costs its own complexity, not the human's. Under rehearsal, a property that the human always satisfies is violated at no more than L·(log₂(1/π(B)) + 2)/n calls of a deployed run, in expectation (Pr6). This is the exact sense in which "the imitator keeps the properties the data had" can be had with no assumption about the human. It is not imitation: a fair coin matches every test frequency that a sample can resolve and is far from a deterministic human; tests of single answers do not control whole runs; properties outside the family are not kept (Section 8.5). And Solomonoff induction on ordinary data need not keep even a simple property: in a class with memorisers the mixture violates one with probability above 1/2 for about K divided by the bits per pair questions (Pr2).

6. **Solomonoff induction is enough only together with rehearsal** (Sections 5 and 11). On questions drawn from a fixed law the mixture stays free on the inputs that decomposition produces. In the toy system of Section 11 it is wrong in 35% to 100% of the runs after 10,000 ordinary questions, while 6400 rehearsal questions bring the rate below half a percent. One program in place of the mixture is possible for a deterministic human: a single posterior draw at the end has an unfaithful run with probability below 2L(K ln 2 + ln(1/δ))/n (R6). It is not possible for a human who varies, unless whole runs of the human system are recorded (R4, H1).

7. **What this does not give** (Sections 9 and 10). Every bound is in K, and for a person under a generic prior K is of the order of 10⁹ bits or more. There the bounds are empty: at an hour per answer a working life pays for about 1.4·10³ bits at θ = δ = 0.1, and if one answer is a year of work it pays for less than one bit. The factor K cannot be removed in general (N2b in Section 4, N8 in Section 9). So the protocol works where the prior is already within an affordable K of the human, K being the bits it still lacks; or for properties, at their own price; or as a check of an imitator obtained in any way. It imitates behaviour on the inputs of one closed system and says nothing about the same human elsewhere; it is not a copy of the person. A faster route is a bet: if the human is separated from every other member of a class without patches, the posterior concentrates exponentially fast (I1), and if the human is not in such a class the error is silent.

The sections follow the order of these answers. Each numbered statement says whether it is proved here, standard, or open. Full proofs are in `proofs/`, and the reports of the independent checks of each proof are in `verification/`.

## 1. The model

**The human.** X and Y are countable sets of input and answer strings. A *sampler* S gives every input x a probability distribution S(·|x) on Y. Assumption **A1**: the human is a sampler P, and a question x put to the human is answered by a draw from P(·|x), whatever was realised before. If every P(·|x) is a point mass, the human is *deterministic* and f denotes the function.

**The class.** H is a countable set of *hypotheses* ν with weights w(ν) > 0 of total at most 1. (A hypothesis may be a program that sometimes gives no answer; that counts as one more answer.) Assumption **A2**: P is in H. We write K := log₂(1/w(P)); in Sections 3.1 to 3.4 only the human's answers to inputs that the scaffold can produce count towards it (`proofs/rehearsal-core.md`, Remark 4.4). After data D the posterior weight of ν is proportional to w(ν) times the probability that ν gives to the recorded answers, and the *mixture* M_D(y|x) := Σ_ν (posterior weight of ν)·ν(y|x) answers every question with a hypothesis drawn afresh from the posterior. For the class of all programs it is Solomonoff's predictor for question–answer pairs (2008, equation (10)).

**The scaffold.** A *scaffold* Π draws a top-level input z from a law D₀ and random bits ρ, then computes each question x_j from z, ρ and the answers so far, or stops, after at most L questions (the *horizon*). One execution is a *run*; its questions are its *calls*. An *answerer* A gives the law A_j(·|h_j) of the j-th answer given the history h_j = (z, ρ, y₁, …, y_{j−1}); a sampler looks at x_j only. Q_A is the law of the run answered by A, and Q_P, the *human system*, is what is to be imitated.

**Unfaithful calls.** Couple a run of an imitator A with the human: at each call, A's answer y_j and a *shadow* answer y′_j from P(·|x_j) are drawn jointly so that they differ with the least possible probability, TV(A_j(·|h_j), P(·|x_j)), and the run continues with y_j. The call is *unfaithful* if y_j ≠ y′_j; β(A) is the expected number of unfaithful calls of a run. The run of A is thus a run of the human system in which a rule that sees the human's answer has replaced the answers at the unfaithful calls (`proofs/rehearsal-core.md`, Lemma 3.2 and Proposition 3.4). For a deterministic human a call is unfaithful exactly if y_j ≠ f(x_j), and a run without such calls is the human system's run on the same z and ρ.

**The protocol's coins.** Assumption **A3** has five parts. (i) The call put to the human is drawn uniformly after the run, independently of it. (ii) The round T is drawn independently of everything else, and the run that counts uses a fresh z and ρ and fresh draws of the imitator. (iii) Class and weights are fixed before any coin is drawn. (iv) The human is shown the string that the imitator was shown, and nothing marks it as a question of the protocol. (v) Every rehearsal and validation run uses fresh coins.

**Closed deployment.** A deployment is *closed* if: (C1) given all that the protocol saw and did, the z and ρ of the run that counts are a fresh draw from the scaffold's laws; (C2) the runs of rehearsal and validation were generated by the protocol on fresh draws from the same laws; (C3) the answers of the run that counts depend on its history and the imitator's coins alone: no clock, no mark that this run is the real one, no state of the world. A fixed question worked on by a tree of calls is closed; a service answering questions from a changing world is not (Section 6).

**Caveats on the assumptions.** Numbers refer to `proofs/assumptions.md`.

*A1.* The protocol's data cannot show that A1 fails. If the human answers the second call of a run from memory of the first, single calls put in separate sittings are answered as by a human without memory; every theorem holds for the system of such humans, which can be at total variation 1/2 from the real one (Example 1.1). If the human is reset between *episodes* and remembers inside them, R1, R3 and V1(a) hold for a deterministic human with whole episodes as the unit asked (E1, Section 9). One person who answers n questions remembers them; A1 for the rehearsal then needs a fresh person per question, and what is imitated is a pool (Remark 1.1a). A human who answers differently because no run depends on the answer is imitated as such (Proposition 1.15).

*A2.* Without it R1 is an oracle inequality (standard; Barron and Cover 1991): for every ν in H the bound is L·ln(1/w(ν))/n plus the divergence of ν from the human, summed along the *mixtures'* runs, not the human system's, and averaged over the rounds (Theorem 2.1). In a class of two hypotheses, one of which has exactly the human system's runs, that one is refuted with probability 0.44, at an input that only wrong answers reach, and the imitator then fails half the time for ever (Example 2.3).

*A3.* If the asked call is computed from the run with a seed of ℓ bits, a hypothesis that holds the seed is never refuted, and the deployed run has at least (L−1)/(2^ℓ+1) unfaithful calls in expectation for every n, in a class with K = 1 (Example 3.3). Rehearsal runs taken from a generator leave a like floor (Example 3.3a). A prior that has seen the rehearsal data memorises them (Example 3.6).

## 2. The protocol: rehearse, validate, deploy

**Rehearse.** For t = 1, …, n:

1. Let M^(t) be the mixture given the questions answered so far.
2. Run the scaffold to the end with M^(t) answering every call.
3. Draw J uniformly from {1, …, L}. If the run made at least J calls, put its J-th question to the human and add question and answer to the data.

**Validate.** Freeze an imitator A: fix it, and let it answer every run with fresh coins. For i = 1, …, m: run the scaffold with A, draw J as before, and if the run made at least J calls put its J-th question to the human; record the human's answer next to the answer that A gave in the run.

**Deploy.** Run the scaffold with the validated imitator. Without validation: for each run draw T uniformly from {1, …, n}, and let M^(T) answer the whole run.

The human answers at most n + m single calls, taken from the imitator's own runs at every depth of a decomposition, and never carries out a run.

**Compute.** If the hypotheses are programs that always halt, for instance programs that carry their own time bound, and the weights are 2^(−length) in a decidable prefix-free code, a posterior draw can be made by rejection: read a program from coin flips, run it with fresh coins on the recorded questions, and keep it if it reproduces the recorded answers. A kept program has exactly the posterior law. The expected number of trials is at most 2^K divided by the probability that the human gives the recorded answers; this is the "very much compute" of the question. For the class of all programs a trial may not halt; the theorems then concern the mixture as a mathematical object, which can only be approximated from below.

None of this is new. Training a learner without regret on the inputs that its own behaviour produces is the reduction of Ross, Gordon and Bagnell (2011, Theorem 4.1); their algorithm returns the best iterate on validation, and they note that the guarantee also holds for one uniformly chosen iterate run for a whole episode. With logarithmic loss, a finite class and a deterministic expert, the protocol is "Stagger" of Li and Zhang (2025). The note adds a prior on a countable class (bounds in K), a human who is not deterministic, and the uses and limits below.

## 3. What rehearsal guarantees

Throughout, A1 to A3 hold and the deployment is closed. Numbers refer to `proofs/rehearsal-core.md`.

### 3.1 Each call

**Theorem R1 (proved here; for a finite class and a deterministic human it is in Li and Zhang 2025).** Write KL_t(x) for KL(P(·|x) ‖ M^(t)(·|x)) in nats. Then

  Σ_{t=1}^{n} E[ Σ_{calls x of the run of round t} KL_t(x) ] ≤ L·K ln 2.

So the run of M^(T) has E[Σ_{calls x} KL(P(·|x) ‖ M^(T)(·|x))] ≤ L·K ln 2/n, and for a deterministic human E[β(M^(T))] ≤ L·K ln 2/n.

*Proof.* Let (x_i, y_i) be the pairs put to the human and ξ_i := Σ_ν w(ν)·ν(y₁|x₁)⋯ν(y_i|x_i), so ξ₀ ≤ 1. The mixture gives the answer it is about to see the probability M(y_i|x_i) = ξ_i/ξ_{i−1}, and the product of these over all pairs is at least w(P)·Π_i P(y_i|x_i); so Σ_i ln(P(y_i|x_i)/M(y_i|x_i)) ≤ K ln 2 almost surely. By A1 the answer of round t is a draw from P(·|x_t) given the past, so the summand of round t has conditional mean KL_t(x_t) ≥ 0 (finite and integrable: Lemma 4.1). Hence Σ_t E[KL_t(x_t)·1{round t asks}] ≤ K ln 2. By A3(i) and (v) the run of round t is a run of M^(t), and J is uniform and independent of it; so the term of round t is (1/L)·E[Σ_{calls x of that run} KL_t(x)]. By A3(ii) the second claim is the average over t. For a deterministic human a call at x is unfaithful with probability e := 1 − M^(t)(f(x)|x), and KL_t(x) = −ln(1 − e) ≥ e. ∎

The inequality is the standard regret bound for Bayes mixtures (Hutter 2003, Theorem 1; Solomonoff 2008 for question–answer pairs; Paper 1 of this repository, Proposition 5.7(b), for questions chosen from earlier pairs).

*What it does not say.* It averages over runs: an input reached with probability below about L·K ln 2/n may be answered in any way (Theorem N1). It is empty for n below L·K ln 2, and K for a person under a generic prior is of the order of 10⁹ bits (Section 9): at one hour per answer, L = 10 and 0.1 unfaithful calls per run cost 350 years already for K = 10⁴. And a fixed number of questions buys a constant rate of unfaithful calls, not a bounded number.

* *Equality* is attained for the divergence and approached for the unfaithful calls (Theorem 5.1(d)).
* *The round.* T is drawn afresh for every run. One T kept for good exceeds the bound by the factor 1/δ with probability at most δ, and for δ ≤ 0.63 a factor 0.45/δ is needed (Proposition 5.2).
* *The last round* cannot replace M^(T) in general: in an example the mixture after all n answers has a summed divergence of at least (L − 1)/8 times L·K ln 2/n (Proposition 6.2). It can for a deterministic human on a scaffold whose questions do not depend on the answers, with at most L·(K ln 2 + 1)/n unfaithful calls in expectation (Proposition 6.1).
* *A new round at every call* is a different imitator and is not covered: for a deterministic human its run is unfaithful at most L times as often, and about L/4 times as often in an example, "the ladder" (Proposition 5.5).
* *More questions per run* do not improve the bound (Proposition 5.3).

### 3.2 Whole runs

For a deterministic human Theorem R1 settles whole runs: the run of M^(T) is the human system's run on the same (z, ρ), except with probability L·K ln 2/n (`proofs/rehearsal-core.md`, Theorem 7.1). For a human who varies, the laws of the runs are compared.

**Lemma L4 (from calls to runs).** Let A and B be answerers on a scaffold, let h_j be the squared Hellinger distance between the distributions from which they draw the answer of call j, given the run so far, and σ := E_{Q_A}[Σ_j h_j]. Then

(a) H²(Q_A, Q_B) ≤ 4σ;
(b) TV(Q_A, Q_B) ≤ min{1, σ + √(σ² + 2σ)} ≤ 2√σ;
(c) Q_A(G) ≤ 2·Q_B(G) + 4σ for every set G of runs, and Q_A(G) ≤ 2σ if Q_B(G) = 0.

Proved here; (a) is standard with the constant 7 (Foster, Han, Qian and Rakhlin 2024, Lemma D.2; Foster, Kakade, Qian and Rakhlin 2021, Lemma A.13, have 10²·log n). *Idea.* Along a run of A, a quadratic function of the root likelihood ratio of B to A rises by at most a constant times h_j at call j, in expectation. Proof: `proofs/hellinger-runs.md`, Theorem 2.1 and Lemma 2.10. In (a) the constant can be 2.9642 and cannot be below 2.9639 (Theorem 2.7 and Example 2.8 there). Parts (b) and (c), added during verification and checked by the editor, have the constants of a single call. Close runs do not make single calls close, except with a factor L.

**Theorem R2 (whole runs; proved here).** Assume A1 to A3 and put s := L·K ln 2/(2n). In expectation over the rehearsal and T:

(a) H²(Q_{M^(T)}, Q_P) ≤ 2·L·K ln 2/n;
(b) TV(Q_{M^(T)}, Q_P) ≤ min{1, s + √(s² + 2s)} ≤ √(2·L·K ln 2/n), which is at most ε after (1 + ε)·L·K ln 2/ε² rounds;
(c) Q_{M^(T)}(G) ≤ 2·Q_P(G) + 2·L·K ln 2/n for each set G of runs fixed in advance, and Q_{M^(T)}(G) ≤ L·K ln 2/n if the human system never produces a run in G.

If neither the questions of the scaffold nor their number depend on the answers, then KL(Q_P ‖ Q_{M^(T)}) ≤ L·K ln 2/n and TV(Q_{M^(T)}, Q_P) ≤ √(L·K ln 2/(2n)).

*Proof.* By Theorem R1 and H² ≤ KL/2, the σ of Lemma L4 with A = M^(T) and B = P has expectation at most s. In the last case the questions have the same law under every answerer; use the chain rule for KL and Pinsker's inequality. Details: `proofs/hellinger-runs.md`, Theorem 3.1.

R2 bounds expectations: for one imitator kept for good, confidence 1 − δ costs the factor 1/δ. It concerns one run; r runs of one imitator are within √(2r·L·K ln 2/n) of r runs of the human system. For a person, with K near 10⁹ bits, it is empty.

**The factor L under the root is necessary** (N6, Section 4; proved here). Let K ≥ 8, L a multiple of K with L ≥ 4K, and ε ≤ 1/65. For some class of 2^K samplers with equal weights and some scaffold of L calls, every protocol needs more than L·K/(8·10⁴·ε²) answers before the run law of its imitator is within ε of Q_P in expected total variation for every member; two samplers need L/(740·ε²) (L odd, ε ≤ 1/12). A run of L calls is a sample of size L from the human and shows a difference of order 1/√L per call. Proof: `proofs/hellinger-runs.md`, Propositions 3.4 and 3.5.

### 3.3 Coverage

**Theorem R7 (coverage; proved here).** Let Q be a set of inputs fixed before the protocol starts. The probability that the deployed run of M^(T) makes a call in Q although no question of rounds 1, …, T − 1 lay in Q is at most L/n; for N such sets it is at most N·L/n. Nothing is assumed about the human or the class; of A3 only (i), (ii) and (v) are used.

*Proof.* If the run of round t has a call in Q, the question of round t lies in Q with probability at least 1/L, because J is uniform given the run. The events "the first question in Q is asked in round t" are disjoint for different t. So the probabilities that the run of round t enters Q before any question lay in Q add up to at most L. Given the data before round t, the deployed run for T = t has the law of the run of round t; average over T. ∎

*What it does not say.* It holds for each fixed set, not for all sets at once: when inputs seldom repeat, the deployed run enters the set of inputs not yet asked with probability near 1.

### 3.4 Low stakes

Fix a set G of good runs. The human system *tolerates k faults with failure δ* if, for every rule, randomised or not, that at each call sees the run so far and the human's answer and may replace that answer, and that replaces at most k answers in any run, the run is in G with probability at least 1 − δ. ("Low stakes" is Christiano's term.)

**Theorem R3 (proved here).** If the human system tolerates k faults with failure δ, the run of an imitator A is in G with probability at least 1 − δ − β(A)/(k + 1). For M^(T), a deterministic human and k + 1 ≥ θL, the failure probability is at most δ + K ln 2/(θ·n), whatever L.

*Proof.* Stop the replacing rule of Section 1 after k replacements. The stopped rule is admissible, so its run is in G with probability at least 1 − δ. The two runs coincide unless the run of A has more than k unfaithful calls, which has probability at most β(A)/(k + 1) by Markov's inequality. ∎

*What it does not say.* Nothing, unless the human system itself tolerates faults. And the rule must see the human's answer: a system can survive 399 blindly replaced answers with failure 0.0007 and fail with probability 1 under an imitator for which δ + β/(k + 1) is 0.021 (Example 8.5(d)).

In the recoverable form (standard: Ross, Gordon and Bagnell 2011, Theorem 2.2), one replaced answer followed by the human raises the expected cost by at most μ, and the run of A then costs, in expectation, at most μ·β(A) more than the human system's (Theorem 8.6).

For a human who is not deterministic, E[β(M^(T))] ≤ L·√(K ln 2/(2n)) (Proposition 9.1), so the failure probability is at most δ + √(K ln 2/(2n))/θ. The rate is right: every protocol has at least 0.088·L·√(K/n) unfaithful calls in expectation for some member of a class of K bits (Theorem 9.2), and in an example failure γ ≤ ½ needs K·(1 − 2γ)²/(32θ²) questions (Proposition 9.3). The order is K/θ², against K/θ for a deterministic human.

**Proposition R3a (bounded damage; proved here).** Let every run have exactly L calls, and let Φ be a real function of the history. Suppose that from every history, also those reached only after replaced answers, an answer of the human raises Φ by at least a > 0 in expectation and changes it by at most 1, and no answer lowers Φ by more than D. Call a run good if Φ rises by at least (1 − σ)·a·L. Then the human system tolerates k faults with failure δ whenever

  k·(1 + D) + √(2L·ln(1/δ)) ≤ σ·a·L,

and, for a deterministic human, with failure 0 whenever k·(1 + D) ≤ σ·a·L.

Each replacement costs at most 1 + D, and the Azuma–Hoeffding inequality controls the steps that the human's answers would have caused (Proposition 12.2, where a and σ are μ and η). So K ln 2·(1 + D)/(σ·a·δ′) questions give an excess failure δ′ for a deterministic human, whatever L. Without "exactly L calls" the statement is false: if a wrong answer can stop the run, one fault spoils it.

### 3.5 The certificate

**Theorem V1 (validation; proved here from standard inequalities).** Let A be a frozen answerer, however obtained. Assume A1 for the validation questions; A2 is not assumed. Validation has m rounds.

(a) Let ρ be the probability that a round records a disagreement, and s the expected sum of 1 − Σ_y P(y|x)² over the calls x of a run of A, divided by L. Then β(A)/L ≤ ρ ≤ β(A)/L + s, for every human. So the rule "if no round records a disagreement, certify β(A) ≤ L·ln(1/δ)/m" certifies an imitator for which this is false with probability less than δ. With ρ̂ the recorded rate of disagreement, β(A)/L ≤ ρ̂ + √(2ρ̂·ln(1/δ)/m) + 2·ln(1/δ)/m with probability at least 1 − δ. Theorem R3 applies with the certified β.

(b) A *test* is a set B of pairs (question, answer). Fix, before validation, countably many tests with weights π(B) of total at most 1, and put Λ(B) := ln(1/π(B)). Let Δ(B) be the expected number of calls of a run of A whose answer lies in B, minus the expected number of its calls at which the human's answer would lie in B, divided by L. With probability at least 1 − δ, for all B at once, Δ(B) is within √(2·(Λ(B) + ln(2/δ))/m) of the difference of the two recorded frequencies.

(c) Under A2, for a sampler A and K ≤ K₀: with probability at least 1 − δ, β(A)/L is at most √(2·(K₀ ln 2 + ln(1/δ))/m) plus the largest recorded difference among the tests {(x, y) : A(y|x) > ν(y|x)} with w(ν) ≥ 2^(−K₀).

*Proof.* Theorem 13.1. For (a): the two recorded answers are independent with laws a and p, and differ with probability 1 − Σ_y a(y)p(y), which lies between TV(a, p) and TV(a, p) + 1 − Σ_y p(y)². For (b): Hoeffding's inequality and a union bound. ∎

*What it does not say.* The certificate of (a) is valid for every human, but it is issued with probability at most exp(−m·s/2): only if the human is nearly deterministic on the inputs visited. The exact imitator of a human who varies fails it. For such a human, without A2, one answer per input cannot certify that a randomised imitator has few unfaithful calls (Proposition 13.4); what can be certified is (b) and, with questions put twice, a squared distance of answer laws (Pr7, Section 8). A test costs Λ(B), whatever its complexity; this is the point of outcome indistinguishability and multicalibration (Dwork et al. 2021; Hébert-Johnson et al. 2018). Each further attempt at validation adds δ.

For a deterministic human in the class, validation of M^(T) records no disagreement with probability at least 1 − m·K ln 2/n (Corollary 13.2). The certificate does not contain K: 300 rounds certify an excess failure 0.1 under θ = 0.1 at δ = 0.05. It certifies an imitator; it does not produce one.

### 3.6 Asking while the system runs

If every call, as it arrives, is put to the human with probability q and answered by the current mixture otherwise, the expected divergence between human and current mixture, summed over all calls, is at most K ln 2/q, however the questions arise (S5, Section 6.2). With q = 1/L in a closed system this is the price of R1, but the human stays in the loop for as long as the system runs.

## 4. What no protocol can do

A *protocol* is any adaptive, randomised way of choosing questions, followed by any deployed system, which may see the whole run and may decline. Questions come before the z and ρ of the deployed run; n is their expected number. A run *fails* if its outcome is declined or differs from the human system's on the same z and ρ. "There" means `proofs/lower-bounds.md`.

### 4.1 No coverage, no guarantee

**Theorem N1** (proved here; the standard two-point argument). Let samplers P and P′ agree outside a set Q, into which the protocol asks with probability γ (the same for both). Let R and R′ be the laws of the deployed answer at an input x, "declined" included, under P and P′. Then

  TV(R, P(·|x)) + TV(R′, P′(·|x)) ≥ TV(P(·|x), P′(·|x)) − γ.

For functions with f(x) ≠ f′(x), the probabilities of a wrong or declined answer at x under f and f′ sum to at least 1−γ. Whole deployed runs under P and P′ are within γ in total variation.

*Proof.* With the same coins the two interactions coincide until the first question in Q. So the data, and the deployed answer or run computed from them with fresh randomness, differ with probability at most γ; hence TV(R, R′) ≤ γ. The display is the triangle inequality; for functions use R(f(x)) + R(f′(x)) ≤ 1 and R′(f′(x)) ≤ R(f′(x)) + γ. ∎

Among all programs, P′ exists for every decidable Q containing x and no asked input, at K(Q)+c bits more for a deterministic human. A human who may answer any string at x has no partner with a disjoint answer law, only partners at total variation 1−1/N, for a further log₂N + 2·log₂log₂N bits (N ≥ 2). The mixture's weight on such partners was known (Paper 2, Proposition G.5; Cohen, Hutter, Bengio and Russell 2025); N1 covers every protocol.

N1 needs the pair in the class and concerns one input, which by R1 and R7 deployed runs rarely meet.

### 4.2 Critical calls are not amplified

**Theorem N2** (proved here). Let δ ≤ 1/6 and N := ⌈L/(2δ)⌉. The inputs are 1, …, N; the class is the zero function f₀ and the functions f_i that are 1 at i only. The scaffold draws L uniform inputs, asks each, and outputs 1 if some answer was 1. If the deployed run fails with probability at most δ for every member, then, counting n under f₀,

  n ≥ L/(4δ) − 3L/2, and n ≥ L/(4δ) − L if L/(2δ) is an integer.

A random half of the inputs suffices.

*Proof.* Weight f₀ by L/(N+L) and each f_i by 1/(N+L); fix the protocol's coins. Under f₀ it asks a set A; under f_i with i ∉ A it gets the same answers and deploys the same system. Let U count the distinct inputs of the deployed run outside A. If the output is not 0 the run fails under f₀; if it is 0 it fails under the U functions f_i met. As U ≤ L, the weighted average failure is at least E[U]/(N+L), and E[U] ≥ (N−n)·p, where p := 1−(1−1/N)^L is the chance that the run meets a given input. So n ≥ N−δ·(N+L)/p; the bounds follow (Corollary 2.2 there). For the converse deploy the function seen, else f₀: failure at most p/2 ≤ δ. ∎

Here K ≤ log₂(L/(2δ)+2); rehearsal reaches failure δ with L·K ln 2/δ questions (R1): the factor L/δ is forced, the factor 4·K ln 2 is left. For one call this is the star-number bound of active learning, with the same argument (Hanneke and Yang 2015, Theorem 3, crediting Dasgupta).

N2 does not bound a Bayes risk: if the prior gives the f_i together under half the weight, deploying f₀ unasked fails with probability below δ. Nor does it count critical calls: it counts the places they fall on that the class can change one at a time. Asking one input L times costs one question.

**Proposition N2a** (proved here: Proposition 2.5 there). With ⌈L/√(2δ)⌉ cells, even a protocol that sees z before asking needs n ≥ L·(1−√(2δ)−δ)−δ. N2's factor 1/(4δ) pays for preparing before the task is known.

### 4.3 The factor K; targeted questions

**Theorem N2b** (proved here: Theorem 3.1 there). Let δ ≤ 1/20 and N := L/(2δ) an integer. The inputs form d blocks of N cells; a member is 1 at one cell per block: 2^K members, K = d·log₂N, of VC dimension d. The scaffold draws a block and L uniform cells of it and outputs 1 if some answer was 1. Failure at most δ for every member needs, in expectation over a uniform member,

  n ≥ (1−10δ)·d·L/(8δ) = (1−10δ)·K·L/(8δ·log₂(L/(2δ))),

and ⌈d/2⌉·(L/(4δ)+1/2) suffice. The blocks are d separate searches; covering a fraction κ of one costs at least κ·N/2 questions.

So questions grow linearly in d; in bits like K·L/(δ·log₂(L/δ)), and no faster:

**Proposition N2c** (proved here: Theorem 3.3 there; a known algorithm). Let the human be a function in a class of functions, and L/ε ≥ 16. *Protocol AB:* while some input occurring in a run answered by a member has no answer of posterior weight above 1−ε·log₂(L/ε)/L, ask it. Otherwise let the weighted vote of the unrefuted members answer a rehearsal run, and ask one random call of it. Deploy the vote of a random such run. With their number chosen from K, the deployed run is unfaithful with probability at most ε after at most 1 + 2.7·K·L/(ε·log₂(L/ε)) questions. It is the membership-query algorithm of Hegedűs (1995) and Moshkov (1983), as in Bshouty (2017, Lemma 3), with prior weights and with audits of runs.

Random questions cannot match this everywhere: on a class with K rare informative inputs, random calls of runs need n ≥ 0.1·K·L/ε−0.4 for failure ε, a seventh of what R1 guarantees, where K chosen questions suffice (Proposition 3.7 there; found and checked by the two verifiers). On the classes of N2b rehearsal is within a constant factor of optimal (Proposition 3.10 there).

N2c has no version for a human who is not deterministic, and its chosen questions follow answers that the human perhaps never gives; A2 is used there.

### 4.4 What low stakes requires

**Theorem N5** (proved here: Proposition 5.6 there). Let N := g/(2δ) be an integer. There are N regions of 2k+1 inputs; the class is f₀ and the indicators of regions. The scaffold draws g regions, asks each region's inputs in turn until k+1 answers agree, and outputs 1 if some region gave 1; L = g·(k+1)+k. Each member's human system tolerates k faults with failure 0, yet failure at most δ for every member needs

  n ≥ (1−4δ)·(L−k)/(4·(k+1)·δ).

By R3, L·K ln 2/((k+1)·δ) questions suffice: tolerance divides the price by k+1 on both sides. What remains is the factor K (see N8) and constants. The example repeats one question to a deterministic human; that guards against the imitator's errors only.

### 4.5 A human who is not deterministic

**Theorem N6** (proved here by Assouad's method: Theorems 6.1, 6.3 there). Take the 2^K samplers on K inputs that answer 1 with probability 1/2±b at each input, and an imitator trained with n questions and then used; its error is the expected total variation between its law and the human's. Error at most ε for every member needs n ≥ K/(512·ε²) for one call at a uniform input (b = 4ε ≤ 1/4), and n ≥ L·K/(8192·ε²) for runs of L calls at one uniform input (b = 16ε/√L, ε ≤ 1/64).

By R1 and R2 rehearsal achieves these errors with K ln 2/(2ε²) and (1 + ε)·L·K ln 2/ε² questions: the rates are right, with no logarithm to save. For a single use, replaying a recorded answer is exact.

### 4.6 What imitation amplifies

**Corollary N2d** (proved here: Proposition 7.2 there). For a deterministic human, a protocol asks n questions, then answers r runs of horizon L; F bounds, for every member, the expected number of failed runs; δ := F/r. The *amplification* r·L/n is answers replaced per answer spent.

(a) Class of N2 with L/(2δ) cells, every protocol: r·L/n ≤ 4F/(1−4δ).
(b) Class of N2b, every protocol: r·L/n ≤ 8F·log₂(L/(2δ))/((1−10δ)·K).
(c) Rehearsal, every class, scaffold and member: r·L/n ≥ F/(K ln 2 + δ/L); under tolerance of k faults K ln 2 becomes K ln 2/(k+1).

(a) and (b) are worst cases over classes matched to L and δ = F/r: the class grows with r, and a fixed class never needs more questions than it has cells. By (a), a guarantee for every member saves no human work unless failed runs are allowed: F < 1/4−δ gives amplification below 1. Imitation saves work across runs, at a price: by (c) rehearsal breaks even once K ln 2 failed runs are allowed, and by (b) no protocol does before (1−10δ)·K/(8·log₂(L/(2δ))). For a person (K near 10⁹ bits under a generic prior) that is millions of failed runs: (c) is then empty.

## 5. One program or a committee

### 5.1 One program or a committee

The imitator of Section 2 is a *committee*: a fresh posterior draw at every call. The human is one program. Can a single *member* of H answer a whole run, or all runs? Every upper bound below is linear in K, hence empty for a person (K of the order of 10⁹ bits, Section 9); the content is the comparison.

**Theorem R4 (one posterior draw per run). Proved here.** Let the human be a function f ∈ H. Rehearse as in Section 2, but in each round let one hypothesis drawn from the posterior answer the whole run. Then

  Σ_t Pr[the run of round t is not the human system's run on the same (z, ρ)] ≤ (2L²/(L + 1))·K ln 2.

So the draw of a uniformly chosen round T ≤ n, taken afresh for each run, fails to reproduce the human system's run with probability at most 2L²·K ln 2/((L + 1)·n).

*Idea.* A run follows the human system's run up to its first wrong answer. If the draw's run has one with probability u, the round's question removes posterior mass at least u·(L + 1)/(2L²) in expectation, and at most K ln 2 can be removed in all. Proof: `proofs/one-mind.md`, Theorem 2.1. For K > 1 a very large class shows that the constant is exact up to the factor (1 − 1/L)(1 − 1/K) (Proposition 2.5).

*What it does not say.* Nothing about how many calls of a failed run are unfaithful (R5), and nothing for a human who is not deterministic, where no such bound exists. Let the scaffold draw one of N questions and put it three times (L = 3) to a human who errs with probability ε each time; let H contain the human with weight ½ (K = 1) and every function s of the question with weight ½·Π_z P(s(z)|z), the human with coins filled in. A question not asked before never moves the posterior. So until questions recur, after about √N rounds, a posterior draw's run stays at total variation close to (3/2)·ε(1 − ε) from the human system's, while the committee's is nearly exact (Example 3.1). Asking every call of the rehearsal runs does not help (Proposition 3.2); recorded runs of the human system do (H1).

**Proposition R5 (low stakes: a member against the committee or its vote). Proved here, by examples.** Take L calls on independent rare inputs and 0/1-valued "traps" that answer 1 at one input and at every later call. After n questions:

(a) K = 1, n ≥ 100, L ≤ √n: a posterior draw's run has at least L/4 unfaithful calls with probability at least 0.11·L/n; the committee's has more than k with probability at most (L/n)^(k+1)/(k + 1)!;

(b) K = log₂(2n), n ≥ 16, L ≤ n: for every protocol that deploys a member chosen without seeing the run's input, some human of the class gives at least L/4 unfaithful calls with probability at least L/(8n); the committee, and its plurality vote (one program, not a member), have more than k with probability at most L/(2n²) + (3L/(2n))^(k+1)/(k + 1)!, for every human of the class.

In (a), with the runs that have fewer than L/4 answers 1 as the good ones, the human system tolerates ⌈L/4⌉ − 1 faults; so the draw needs 0.11·L/δ questions for failure δ, where R3 gives the committee K ln 2/(θδ). With traps slightly heavier than the human (K about log₂(2n)) the highest-weight consistent member fails likewise, with probability at least (9/32)·L/n. Proof: `proofs/one-mind.md`, Propositions 4.2, 4.3, 4.6.

*What it does not say.* Nothing about classes in general. In (b) "unfaithful" means different from the human's answer: against good runs defined without reference to the human, a deployed member fails exactly as often as the human system of that member would. Whether the vote uses fault tolerance in general is open.

**Proposition R6 (which program, and when). Proved here; (c) not independently checked.** Let H be a class of functions and f ∈ H the human.

(a) *Not as the driver.* If each rehearsal run is answered by the highest-weight hypothesis consistent with the answers so far, at most L·(2^K − 1) of the rehearsal runs differ from the human system's in expectation, and exactly L² in a class of L + 1 functions, where the committee has at most L·ln(L + 1).

(b) *At the end.* After the n rounds of Section 2, with probability at least 1 − 2δ, every consistent g with w(g) ≥ w(f), and likewise one draw from the final posterior, has Pr[its own run is not the human system's] < 2L·(K ln 2 + ln(1/δ))/n.

(c) *A human who is not deterministic* (any class, P ∈ H). After the n rounds of Section 2 let ν̂ maximise w(ν)²·ν(D). With probability at least 1 − 2δ, H²(Q_ν̂, Q_P) < L·(28·K ln 2 + 40·ln(1/δ))/n.

*Ideas.* (a) A wrong driver hides the others' errors and is removed with probability 1/L per failed run. Without a scaffold this is the standard gap between an arbitrary consistent learner (up to |H| − 1 mistakes) and the halving algorithm (log₂|H|; Littlestone 1988). (b) An Occam bound in martingale form. (c) The same in Hellinger distance, the standard analysis of selection by description length with a doubled penalty (Barron and Cover 1991; Zhang 2006), with the subadditivity of H² along runs (Section 3). Proof: `proofs/one-mind.md`, Proposition 5.1, Example 5.2, Theorem 5.5, Corollary 5.6, Theorem 3.8.

*What it does not say.* Which member is selected (Section 9). In (c) the square is needed: a final posterior draw fails by the example above, and the member of largest posterior weight is, in a class with K = 4, a function at total variation 7/8 with probability about 0.98 (Example 3.6, after Zhang 2006). For such a human the committee must also answer the rehearsal runs: with posterior draws in its place, even the committee's runs are controlled only up to a factor 2^K (Proposition 3.5).

| | committee | member per run | member for good |
|---|---|---|---|
| deterministic human: Pr[a run is not the human system's] | L·K ln 2/n (R1) | 2L²·K ln 2/((L+1)n) (R4) | 2L·(K ln 2 + ln(1/δ))/n (R6b) |
| deterministic human, low stakes | K ln 2/(θn) (R3) | no gain in the examples (R5) | the same (R5) |
| human not deterministic | E TV ≤ √(2·L·K ln 2/n) (R2) | no bound; with recorded runs, H1 | squared weights: R6c; otherwise no bound; with recorded runs, H2 |

### 5.2 Recorded runs of the human system

If the human can carry out whole runs, N independent runs of the human system can be recorded; the posterior given the runs is the posterior given their question–answer pairs.

**Theorem H1 (a posterior draw for each run; standard).** Let the recorded runs be independent with a common law Q*; under A1, Q* = Q_P. To imitate a run, draw t uniformly from {1, …, N}, draw ν from the posterior given the first t − 1 runs, and let ν answer every call. Let Q̂ be the law of this run given the records. Then, for every ν in H,

  E[KL(Q* ‖ Q̂)] ≤ ln(1/w(ν))/N + KL(Q* ‖ Q_ν).

Under A1 and A2, E[KL(Q_P ‖ Q̂)] ≤ K ln 2/N and E[TV(Q̂, Q_P)] ≤ √(K ln 2/(2N)), and a set of runs that the human system never produces has expected probability at most K ln 2/N under Q̂.

This is the progressive mixture rule (Catoni 1997; Yang 2000) applied to runs: for M densities and n observations its expected divergence exceeds the best density's by at most (log M)/n (Juditsky, Rigollet and Tsybakov 2008, Corollary 5.4). The proof is the regret bound behind Theorem R1 with runs in place of pairs, then convexity and Pinsker's inequality: `proofs/hellinger-runs.md`, Theorem 4.2.

The imitator is not a sampler: one hypothesis answers every call of a run, so the calls must share a seed. The bound is for the random t; whether the last posterior alone satisfies it is open (Grünwald and Kotłowski 2011 pose the general question).

**The per-call mixture fails here** (proved here). If every call is answered by a fresh posterior draw, the statement of H1 is false. Let z be uniform on 2N values and let the L calls of a run be (z, 1), …, (z, L). Take f ≡ 0 with weight ½ and, for each value of z, with weight 1/(4N), the function that answers 1 at its L calls: K = 1, and whatever the records, the divergence of Q_P from the run law is at least L/(8N), against ln 2/N. A hypothesis that is wrong on a whole run spoils few runs when it is drawn once for the run, and about L times as many when it is drawn afresh at each call. The loss is at most the factor L for a deterministic human and when the questions do not depend on the answers; otherwise it is open (`proofs/hellinger-runs.md`, Section 4.3).

**Theorem H2 (one program for good; proved here).** Assume A1 and A2, let λ > 1, and compute the posterior from the N recorded runs with the weights w(ν)^λ. For 0 < ε ≤ 1 and every s in [1/λ, 1), the expected posterior weight of the hypotheses ν with H²(Q_ν, Q_P) ≥ ε² is at most

  2^(λsK)·(1 − ε²)^(2·min(s, 1−s)·N),

and so is the probability that such a ν has at least the posterior weight of P. With λ = 2 and s = ½: after (K ln 2 + ln(1/δ))/ε² runs, a program drawn once from the posterior, or the one of largest posterior weight, has TV(Q_ν, Q_P) < √2·ε with probability at least 1 − δ.

The proof bounds the posterior weight of ν by the s-th power of its odds against P and uses Hölder's inequality (`proofs/hellinger-runs.md`, Theorem 5.1). A rate in probability for λ > 1 is due to Barron and Cover (1991, Theorem 4, as Zhang 2006 reports it); for a finite class with equal weights the bound is Proposition 2.1 of Foster, Block and Misra (2024).

H2 makes the law of each single run on this scaffold close, and no more: single calls are close only up to the factor L, inputs that the human system never visits are free, and many runs together drift apart.

**At λ = 1 the statement fails.** Let the human be a fair coin with weight ½, let the class contain every table from {0,1}^d to {0,1} with weight 2^(−2^d−1), and let the scaffold ask one uniform input. Until an input repeats, the tables that fit the records together have the posterior weight of the coin; so a posterior draw is a table, at H² = 0.29 from the coin, with probability at least ¼ for all N ≤ 2^(d/2) (`proofs/hellinger-runs.md`, Example 5.4). A table is the human with the coins filled in. The phenomenon is known (Zhang 2006, Section 4.4, after Barron, Schervish and Wasserman 1999); H1 is not affected. Two forms hold in expectation, also outside the class: with the weights w and the likelihood raised to the power ½ (Zhang 2006, Theorem 5.1), or with the weights w² and the program of largest posterior weight (his Theorem 4.1), E[H²] ≤ ln(1/w(ν))/N + ½·KL(Q* ‖ Q_ν) for every ν (`proofs/hellinger-runs.md`, Theorems 5.5 and 5.7).

**Cost.** This route needs N whole runs carried out by the human: it suits small scaffolds only, and none when one answer is a year of work. It saves no answers: Theorem R2 with n = N·L rounds has the same bound when the questions do not depend on the answers, and twice it otherwise; N6 covers protocols that record runs. For a person both theorems are empty.

## 6. Inputs from outside

Rehearsal draws the top-level input z from D₀; deployment may draw it otherwise. Like R1, the bounds in K below are empty for a person under a generic prior; those in 2^K are empty for any human of interest. Statements cited by number are those of `proofs/shift-abstain.md`.

### 6.1 Shift

**Theorem S4 (three kinds of shift)** (proved here, from R1, S1, N1 and N3). Run Protocol R for n rounds with top-level law D₀ and deploy M^(T).

(i) *The shift that the system makes itself costs nothing.* For every set S of inputs, the probability that the question of round T lies in S is 1/L times the expected number of calls of the deployed run in S, whatever the scaffold does with the answers. So Theorem R1 needs no factor for shift.

(ii) *A shift of the top-level law to D₀′ ≤ B·D₀ costs the factor B* (S1). For N laws with disjoint supports there is a class on which every protocol pays the factor N, and all laws of ℓ bits cost about 2^ℓ (N3, S2).

(iii) *Any other shift has no guarantee:* where D₀ does not dominate D₀′ nothing was asked, and N1 applies.

*Proof.* (i) The asked index J is uniform and independent of the run, and the deployed run has the law of the run of round T. (ii), (iii): the cited statements (`proofs/shift-abstain.md`, Theorem 2.5). ∎

Part (i) is the reduction of Ross, Gordon and Bagnell (2011) as used by Li and Zhang (2025). *What it does not say:* (i) equates expected numbers of calls. A kind of call rarer than about one in n is probably never asked; there the prior fixes the answer.

**Proposition S1 (density ratio)** (proved here; (a) is the standard change of measure).

(a) Let E′ and E be expectations over a run with z drawn from D₀′ and from D₀. If D₀′ ≤ B·D₀, then E′[φ] ≤ B·E[φ] for an answerer fixed before the run and every function φ ≥ 0 of runs. So every bound of Section 3 on the deployed run (unfaithful calls, the distance of R2, a validated rate) holds with the factor B. Without domination, add sup φ·D₀′{z : D₀′(z) > B·D₀(z)}.

(b) The *visit measure* of an answerer gives each set of inputs the expected number of calls of its run in it. Let d̄ be the average of the visit measures of M^(1), …, M^(n), and d′ ≤ B·d̄ a measure on inputs. Then E ∫ TV(P, M^(T)) dd′ ≤ (2L − 1)·B·E β, where β is the expected number of unfaithful calls of the run of M^(T). The factor 2L − 1 cannot be lowered below L/2.

*Proof.* (a) The expectation of φ given z does not depend on the law of z. (b) `proofs/shift-abstain.md`, Proposition 2.3 and Example 2.2. ∎

In the example an early mixture errs at the first call, is thereby sent away from the input x₁ that the human system visits L − 1 times, and its error at x₁ never shows in its own runs. For L = 100, n = 10⁴ and a human of weight 1/L, a deployment that visits x₁ meets 0.4975 unfaithful calls in expectation where B alone would allow 0.0463. So for visit measures S1 fails with B alone, by the factor L/(2 ln L): the compounding of errors of Ross and Bagnell (2010). *What S1 does not say:* anything about tasks to which D₀ gives no mass.

**Proposition S3 (a property of tasks)** (proved here). Let Γ be a set of tasks with D₀(Γ) = p > 0. On a task in Γ the deployed run has at most L·K ln 2/(p·n) unfaithful calls in expectation, for a deterministic human. For protocols that take each question from a run on a task drawn from D₀ the factor 1/p is necessary: for some scaffold and class, failure probability at most δ ≤ 1/4 on Γ for every member needs n ≥ (L/(4δ) − L)/p. Proof: `proofs/shift-abstain.md`, Proposition 2.4. *What it does not say:* 1/p is the price of a property that was not singled out. A property named in advance costs nothing (rehearse on D₀ given Γ); N unknown disjoint ones cost the factor N (N3).

**Theorem N3** (proved here: `proofs/lower-bounds.md`, Theorem 4.1). Let Q₁, …, Q_N be disjoint sets of inputs; the class is the zero function and the indicators. Under *shift i* the task is one call at an input drawn from a law on Q_i. If the deployed answer is right with probability at least 1/2+a under every shift for every member, then n ≥ 2aN, counting n under the zero function; 2aN questions suffice.

One question in a random region gives 1/2 + 1/(2N) everywhere, so only protocols without coins need a question in every Q_i. There are 2^ℓ disjoint decidable sets of complexity at most ℓ+2·log₂ℓ+c, so robustness to all shifts of ℓ bits costs 2a·2^ℓ questions up to a factor polynomial in ℓ. With L critical calls per shift it is N·(L/(4δ)−3L/2) (`proofs/lower-bounds.md`, Theorem 4.3).

**What S2 needs** (proved here: `proofs/lower-bounds.md`, Propositions 4.4 and 4.6). If rehearsal draws z from a mixture Σ_i π_i·D_i of task laws, a bound β on the expectation over z of a nonnegative quantity becomes β/π_i under D_i (standard domination); for N disjoint laws the factor N is necessary (N3). The mixture must be sampled, which is possible for samplers given uniformly that halt, such as all programs p under a fixed time bound (π_p = 2^(−2|p|−1)). No sampler that halts with probability one dominates every law that such samplers produce; the universal mixture does, but no halting program samples it (a halting oracle suffices). With time bounds growing with the round, ordinary computation gives, for a deterministic human, every such law D, sampled by p_D, the factor 2^(2|p_D|+1) plus the average over rounds of the probability that p_D exceeds the bound; this tends to 0 at a rate depending on D, never uniformly.

### 6.2 Open systems

Now no scaffold can be run in advance, and inputs arrive in any way.

**Proposition S5 (asking at random, for ever)** (proved here; label-efficient prediction, Cesa-Bianchi, Lugosi and Stoltz 2005, applied to the regret bound of R1). After the input x_t is fixed, a coin decides with probability q that the human answers and the pair joins the data; otherwise the current mixture M^(t) answers. Then E Σ_t KL(P ‖ M^(t))(x_t) ≤ K ln 2/q over all steps. For a deterministic human the mixture gives at most (1 − q)·K ln 2/q wrong answers in expectation over the whole unbounded run; an example comes within the factor 2 ln 2. Proof: `proofs/shift-abstain.md`, Theorem 3.1. *What it does not say:* which steps are wrong. And the human never leaves.

**Theorem N7 (the asking cannot stop early)** (proved here). At each step a learner sees an input and asks the human, predicts, or abstains; it sees an answer only when it asks. Sil counts its wrong predictions, Abs its abstentions.

(a) Let the class contain the N thresholds x ↦ 1[x ≤ i], 0 ≤ i < N, and show the inputs 1, …, N − 1 in order. Every learner with at most Q ≤ N/2 − 1 questions has E[Sil + Abs]·(Q + 1) ≥ 3N/16 for a uniformly drawn threshold as the human, hence for some threshold; if Q + 1 divides N, a learner attains less than N/2.

(b) For every class of functions, every human f in it and every b ≥ K, *enumeration* (keep the hypotheses of weight at least 2^(−b) that fit the answers; ask where two of them differ) is never wrong and asks at most 2^b − 1 questions, on input sequences of any length.

Proof: `proofs/shift-abstain.md`, Theorem 3.3 and Corollary 3.6.

So a deterministic human can leave an open system: never later than after 2^b − 1 questions, but with 2^K equally weighted thresholds not before about 3·2^K/(16j) if j silent mistakes and unanswered abstentions are tolerated in expectation. Only in that sense can the asking not stop. *What it does not say.* (a) is a worst case over one class and one sequence. For a human who is not deterministic see Section 7.5.

## 7. Failing obviously

An imitator may *abstain*; a run halts at its first abstention and is then *aborted*. A *silent error* is an answer that is neither the human's nor an abstention. Until Section 7.5 the human is a function f; A is the set of asked inputs; c denotes constants of the reference machine.

### 7.1 The threshold rule

**Theorem Ab1** (proved here; the Bayes-mixture form of the trade-off of Sayedi, Zadimoghaddam and Blum 2010). For η < 1/2 the rule Thr_η answers y if M_D(y|x) ≥ 1 − η and abstains otherwise.

(a) On any sequence of asked inputs, apply the rule to each input before the human answers; let it be wrong u times and abstain v times. Then u·log₂(1/η) + v·log₂(1/(1 − η)) ≤ K. So u ≤ K/log₂(1/η) and v ≤ K ln 2/η; examples attain both up to rounding. If η < w(f) the rule is never wrong, at any input.

(b) Rehearse with Thr_η answering the calls and one uniformly chosen call of each run, the aborting one included, put to the human. The run of the rule of a uniformly chosen round has at most L·K/(n·log₂(1/η)) wrong answers in expectation and is aborted with probability at most L·K ln 2/(n·η).

*Proof.* (a) As in the proof of R1, the product over the asked rounds of M^(t)(f(x_t)|x_t) telescopes and is at least w(f). The factor is at most η at a wrong round and below 1 − η at an abstention round. If η < w(f), then M_D(f(x)|x) ≥ w(f) > η, and no other answer reaches 1 − η. (b) The asked call is a uniformly chosen one of the L call slots. So round t is a wrong round with probability 1/L times the expected number of wrong answers of its run, and an abstention round with probability 1/L times its abort probability. Take expectations in (a). ∎

*What it does not say.* The counts are over asked rounds; an unasked error teaches nothing. In (b) the rule itself must drive the rehearsal.

### 7.2 The minimum over a plausible set

For a set 𝒞 of hypotheses, Min_𝒞 answers y with probability min_{ν∈𝒞} ν(y|x) and abstains with the rest. Order the hypotheses by posterior weight. The *top set* keeps those whose weight is at least α times the total weight of those ranked no lower; it has at most 1/α members. The *ratio set* keeps those of weight at least α times the largest, and contains the top set.

**Theorem Ab2** (the rule, the top set and (b): Cohen, Hutter and Nanda 2022; (a), (c) and (d) proved here, (a) from their domination at a single step). The human may be any sampler.

(a) *Dominance.* If P ∈ 𝒞, then on every scaffold, with inputs from anywhere, the run of Min_𝒞 is, in a coupling, the human system's run or an initial part of it followed by an abort. So every set of complete runs has at most its probability under the human system.

(b) P stays in both sets for ever with probability at least 1 − α/w(P) (Ville's inequality); a deterministic human with certainty if α ≤ w(f).

(c) *Coverage.* In the class of all programs, Min over the ratio set abstains with certainty wherever sep(x; A) ≤ log₂(1/α) − c. For programs of total functions it answers f(x) wherever sep(x; A) > K + K_D + log₂(1/α) + c, where K_D is the length of the shortest program consistent with the data.

(d) *Abort after rehearsal.* After n rounds of Protocol R freeze the top set 𝒞 and deploy Min_𝒞 on the same scaffold. For a deterministic human the run is aborted with probability at most Pr[f ∉ 𝒞] + δ + L·(K ln 2 + ln(1/(αδ)))/(α·n) + L(L − 1)·K ln 2/n. For samplers it is at most α/w(P) + δ + (L/α)·√(2Γ/n) + L(L − 1)·√(K ln 2/(2n)), where Γ := ln S + ½·ln(1/(α·w(P))) + ln(1/δ) and S := Σ_ν √w(ν); the term ln S is needed.

Proof: `proofs/shift-abstain.md`, Theorems 5.1, 5.3, 5.6 and Proposition 5.2. For (a), keep each answer of the human's run with probability min/P. For (c), patch a plausible hypothesis on a simple set without asked inputs, with either of two answers.

*What it does not say.* P ∈ 𝒞 is a theorem only for α ≤ δ·w(P), or α ≤ w(f). Then by (c) the rule refuses every unasked input simpler than about K, and (d) needs n of order 2^K, for samplers 4^K: empty for a person. With a moderate α, that the human is within log₂(1/α) bits of the best explanation is an assumption which the data cannot confirm.

*Comparison.* Cohen, Hutter and Nanda keep the demonstrator, who may have memory, and query with the leftover probability. They bound the expected sum of cubed query probabilities by |𝒜|·α⁻³·(24/w + 12) (their Theorem 1; 𝒜 the actions, w the demonstrator's prior weight), and events unlikely under the demonstrator with factors that grow with time (their Theorem 5). Here the query is an abort, domination is exact for whole runs, and the price moves into (d).

### 7.3 The novelty rule

**Proposition Ab3** (proved here; Observation B of the researcher's notes). For programs of total functions, Nov_s asks, or abstains, at x if sep(x; A) < s, and otherwise answers as the shortest program consistent with the data. (a) It asks at most 2^s − 1 questions on any input sequence, whatever the human. (b) If s > 2K + c it is never wrong. (c) Frozen, it refuses exactly {x : sep(x; A) < s}, for ever: with the s of (b), every unasked input simpler than about 2K. With a smaller s nothing here guarantees its answers.

*Proof.* (a) Each question uses up a test of fewer than s bits. (b) If the shortest consistent program g is wrong at x, the set {g ≠ f} separates x from A and takes at most 2K + c bits. ∎

### 7.4 The trade-off, rocks and whitelists

**Proposition N4** (standard: the example of singletons for learners that may say "I don't know", Li, Littman and Walsh 2008). A learner that is never silently wrong for every member of a class asks or abstains wherever a member that agrees with the human on A differs from the human. With the zero function as the human and the 2^d point functions in the class, that is every new input. Proof: `proofs/shift-abstain.md`, Proposition 7.1.

**Theorem Ab4** (proved here; row 3 is Zhang and Chaudhuri 2016). For a deterministic human of K bits:

| setting | can be had | cannot be had |
|---|---|---|
| open system; Thr_η, audits at rate q, abstentions answered | E[Sil] ≤ ((1 − q)/q)·K/log₂(1/η), at most K ln 2/η abstentions | 2^K thresholds: E[Sil + Abs]·(questions + 1) ≥ 3·2^K/16 (N7) |
| open system, no silent error | 2^b − 1 questions (N7(b)) | point functions: every new input asked or refused (N4) |
| every answer shown, at most k wrong | about K ln 2·2^(K/(k+1)) abstentions | 2^K thresholds, rules without coins: (k + 1)·2^(K/(k+1))/e − k − 1 |
| closed system | Ab1(b) | a needle class with cells of equal mass: silent failure σ with abort probability a needs n ≥ (1 − a)²·L/(4σ) − L |

Proof: `proofs/shift-abstain.md`, Theorem 7.3. *What it does not say.* The last row is one closed system. Where the inputs that the questions missed are rare and recognisable, abstaining on them saves a factor of order a/σ in questions (Example 4.5a).

**Rocks and whitelists.** In the table the rules are frozen and sep stands for sep(x; A). The second column is forced: for programs of total functions, every rule that is never silently wrong for all hypotheses within r bits of the best explanation of the data refuses every x with sep(x; A) ≤ r − c (Proposition 7.5).

| rule | refuses at least | refuses at most | sound when |
|---|---|---|---|
| never silently wrong for all programs | all unasked inputs | | always |
| enumeration, budget b | sep ≤ b − K_D − c | sep ≤ 2b + c | b ≥ K |
| Thr_η, η = 2^(−r) | sep < r − c | unknown | posterior weight of f above η |
| Min, ratio set, α = 2^(−r) | sep ≤ r − c | sep ≤ K + K_D + r + c | f within r bits of the best explanation |
| Nov_r | sep < r | sep < r | r > 2K + c, or the shortest consistent program is right elsewhere |
| mixture | nothing | nothing | not guaranteed off A |

*Rocks.* With a parameter that makes soundness a theorem for all data (η < 2^(−K), α ≤ 2^(−K), r > 2K + c), rows 3 to 5 refuse every unasked input simpler than about K. One expects K for a person to exceed the complexity of every input ever written (this depends on the reference machine); then they are the rocks the researcher rejects, like row 1. Enumeration is sound once b ≥ K; its forced radius b − K_D shrinks as the data single out the human. *Whitelists.* With a moderate r the same rules refuse what a test of about r bits separates from A, and rows 4 and 5 nothing beyond the third column: the whitelists he accepts. Soundness is then the assumption in the last column, and its failure is silent, except for Thr_η on the system it rehearsed (Ab1(b); abort probability at most L·K ln 2·2^r/n). If the calls of a decomposition share a property of fewer than r − c bits that no asked input has, every abstaining row refuses them all; the mixture errs at each with probability at least 2^(−r−c). For the class of all programs no row is computable.

### 7.5 A human who is not deterministic

Dominance (Ab2(a)) holds as stated. The counts of Ab1 hold in expectation only if the human has everywhere a preferred answer of probability above 1 − η, and the rule then imitates that answer, not the distribution. No rule has both counts for all samplers: with a fair coin of weight 1/2 and the 2^N functions on N inputs, of weight 2^(−N−1) each, at most (N + 1)/4 expected silent errors against every function force at least (N − 1)/2 expected abstentions against the coin, which costs one bit (Propositions 4.7 and 4.8).

## 8. The property idea

The researcher proposed that a good imitator keeps the properties the answers had so far, and objected: at a new input some such property must break. This section says what survives.

### 8.1 All properties at once

**Pr1** (a definition). TV(Q_A, Q_P) ≤ ε holds exactly when every event of runs has, with A answering, a probability within ε of its probability in the human system. Keeping every property up to a small error is thus closeness in total variation, not a weaker goal. Under A2 its price is K, times the horizon L under rehearsal: for a deterministic human the deployed run is a run of the human system with probability at least 1 − L·K ln 2/n (R1); in general E TV ≤ √(2·L·K ln 2/n) (R2); from N recorded runs of the human system, E TV ≤ √(K ln 2/(2N)) (H1). For a person, with K of the order of 10⁹ bits under a generic prior, these bounds are empty.

*Not said.* The error is additive: an event of probability below ε in the human system, such as a rare bad one, is not controlled.

### 8.2 One property at a time

A *test* is a set B of runs (a set of pairs (x, y), for a one-call scaffold). Fix in advance countably many tests with weights π(B) of total at most 1; Λ(B) := ln(1/π(B)) is the *price* of B. With π(B) = 2^(−length of a program for B), in a prefix-free language whose programs all halt, cheap tests are simple properties.

**Theorem Pr3** (standard: the Occam's razor bound; Langford 2005, quoted from memory). Let τ₁, …, τ_N be independent runs with one law Q, Q̂(B) the fraction of them in B, and a(B) := (Λ(B) + ln(2/δ))/N. With probability at least 1 − δ, for all B at once, kl(Q̂(B) ‖ Q(B)) ≤ a(B), where kl(p ‖ q) is the divergence KL between coins of bias p and q. On this event |Q̂(B) − Q(B)| ≤ √(a(B)/2), and Q(B) ≤ a(B) if B never occurred; and every law Q′ that satisfies the same inequalities in the place of Q has |Q′(B) − Q(B)| ≤ √(2a(B)), and Q′(B) ≤ a(B) if B never occurred.

*Proof.* N·Q̂(B) is binomial; the Chernoff bound in divergence form gives Pr[kl(Q̂(B) ‖ Q(B)) > a(B)] ≤ 2e^(−N·a(B)) = π(B)·δ; sum over B. Pinsker's inequality and kl(0 ‖ q) ≥ q give the rest (`proofs/property-batch.md`, Theorem 2.3, Corollaries 2.4, 2.6; numbers cited below refer to that file). ∎

That a property costs its own complexity whatever the source, and that a model passing all tests need not be close to the source, are central points of outcome indistinguishability and multicalibration (Dwork et al. 2021; Hébert-Johnson et al. 2018). Q is arbitrary; but the human must not change between runs.

Theorem V1(b) is Pr3, used to *check* a given imitator, for the one-call scaffold "a uniformly chosen call of the imitator's run" (Theorem 6.1): m single answers, no run of the human system, per-call tests only, A1 for the probes.

The researcher's conflict is thereby confined, not removed: two tests that held on all data and clash on a new kind of input need only keep the human's frequencies, as the human system does. On inputs rarer than the tolerance a matching imitator may do anything.

*Not said: that a matching imitator imitates* (proved here: Proposition 5.2, Example 5.3).
* *The coin.* One call at a uniform input among u; the human is a function f: X → {0, 1}, the imitator a fair coin. For all but a fraction δ of the functions, |Q_coin(B) − Q_f(B)| ≤ √((Λ(B) + ln(2/δ))/(2u)) for every test, yet the coin differs from f with probability 1/2 at every call.
* *The same question twice.* The scaffold puts one uniform input to the answerer twice; the human is a fair coin at each call, the imitator a function g. For most g every per-call test has the human's frequency, to the same error, while "the two answers agree" has probability 1 against 1/2.

For N recorded runs there are thus two prices: errors of order √(K/N) for all properties at once (H1; Pr4 below), empty for a person, and of order √(Λ(B)/N) for each test. Neither guarantee contains the other at its own price.

### 8.3 The batch estimator

Let K(ν) := log₂(1/w(ν)). The likelihood of a run under ν is the product of ν(y_j | x_j) over its calls. For ν ≠ ν′ let A_νν′ be the set of runs more likely under ν than under ν′, and r(ν) := √((K(ν) ln 2 + ln(2/δ))/(2N)). From N recorded runs, the estimate ν̂ minimises

  r(ν) + sup_{ν′ ≠ ν} max{0, Q_ν(A_νν′) − Q̂(A_νν′) − r(ν′)}.

**Theorem Pr4** (proved here; minimum-distance estimation after Yatracos). For every law Q of independent runs, with probability at least 1 − δ, for every ν ∈ H:

  TV(Q_ν̂, Q) ≤ 3·TV(Q_ν, Q) + √((2K(ν) ln 2 + 2 ln(2/δ))/N).

*Idea.* TV(Q_ν, Q_ν′) = Q_ν(A_νν′) − Q_ν′(A_νν′), and Q̂ must be close to Q only on the sets involving the best ν. Proof: `proofs/property-batch.md`, Theorem 3.6. The estimate is the modified minimum-distance estimate of Mahalanabis and Štefankovič (2008), with weights; it attains the factor 3, which is optimal for rules that return a member and whose number of runs does not grow with the space of runs (Bousquet, Kane and Moran 2019, Theorem 19).

*To compute it* one needs a list of the hypotheses above a weight threshold (up to about e^(2N)); exact comparison of two likelihoods on a recorded run (possible for time-bounded programs, not for lower semicomputable ones); and the numbers Q_ν(A_νν′), hence a closed system or simulated runs (Theorem 3.10).

*Not said.* For a human with memory inside a run the bound can be empty: one who repeats a fair bit is at distance at least √2 − 1 from every sampler, and 3·(√2 − 1) > 1. And the human must carry out N whole runs.

### 8.4 An imitator built from tests alone

Tests are here sets B of pairs (question, answer), in a countable family 𝓑 fixed in advance, with weights π(B) > 0 of total at most 1 and prices Λ(B) = ln(1/π(B)) as in Section 8.2. In round t the imitator fixes a rule a_t: X → Y; then a question x_t and the human's answer y_t arrive, depending in any way on the past and on a_t. Let g_t(B) := 1[(x_t, a_t(x_t)) ∈ B] − 1[(x_t, y_t) ∈ B], let S_n(B) := Σ_{t≤n} g_t(B) be the *book* of B, and V_n(B) ≤ n the number of rounds t ≤ n with g_t(B) ≠ 0.

**Rule NH.** With G_v(s) := (v + 1)^(−1/2)·exp(s²/(2(v + 1))), a test with book S and count V before round t has the *slope* c_t(B) := ¼·(G_{V+1}(S + 1) − G_{V+1}(S − 1)) + σ·2^(V−2), the last term only if V ≥ 1 and all its non-zero increments had one sign σ. The rule a_t(x) is an answer y that minimises Σ_B π(B)·c_t(B)·1[(x, y) ∈ B].

**Theorem Pr5 (matching all tests on any sequence; proved here).** Let Y be finite. Under Rule NH, on every sequence, for every n and every test B:

(i) S_n(B)² ≤ (V_n(B) + 1)·(2Λ(B) + 1.39 + ln(V_n(B) + 1)), hence |S_n(B)| ≤ √((n + 1)·(2Λ(B) + 1.39 + ln(n + 1)));

(ii) if the human's answer was never in B, the imitator's was in B in at most log₂(1/π(B)) + 2 rounds; if it was always in B, the imitator's was outside B in at most as many.

*Idea of the proof.* Each test has a potential u ≥ 0, starting at 1, that grows in a round by at most slope times increment. The rule minimises the slope-weighted score over all answers, the human's among them; so Σ_B π(B)·u (absolutely convergent) never grows, and u ≤ 1/π(B). Half of u is G_V(S), giving (i); the other half doubles at each non-zero increment while all have one sign, giving (ii). Proof: `proofs/property-online.md`, Lemmas 1.3 and 1.4, Theorem 3.3.

Nothing is assumed about the human (not A1, not A2); no randomness is used. Nothing is said about tests outside the family, or about any single answer.

*Lower bounds (proved here).* (ii) is optimal up to the 2: among 2^r tests of weight 2^(−r), every rule gives, against some human, r answers in a test this human never satisfies (Proposition 3.5; standard). In (i), √n is forced in general: for some family of √n tests every rule lets a book reach (√2 − 1)·√n within n rounds (Proposition 3.6). For a fixed finite family it is not: another rule keeps the books bounded, exponentially in the family's size (Proposition 3.9). Whether the logarithms are needed is open.

*A class as tests.* Halve the weights and add, with weights w(ν)/2, the tests "the answer is not ν(x)" for the functions ν of a weighted class. If the human is one of them, (ii) gives at most K + 3 rounds with an answer other than the human's (Corollary 3.4). This is the halving algorithm (Littlestone 1988; standard); for a person the bound is empty, like that of Theorem R1.

*One rate.* The simplest instance minimises Σ_B π(B)·sinh(η·S_{t−1}(B))·1[(x, y) ∈ B] and has |S_n(B)| ≤ ln(2/π(B))/η + n·η/2 (potential cosh(η·S); Theorem 2.1), that is √n·(ln(2/π(B)) + 1/2) for η = 1/√n with n fixed in advance. It has no fast one-sided rate: however its ties are broken, some human never satisfies a test of weight 1/(2n) in which the rule gives at least ½·√n·ln n answers (Examples 2.3 and 2.5); Rule NH gives at most log₂ n + 3.

**Theorem Pr6 (rehearsal with this imitator; proved here).** Rehearse as in Section 2 with a_t of Rule NH in place of the mixture, and deploy, for each run afresh, the rule of a uniformly drawn round. Assume A3, and A1 at the asked calls. Let d_B(a) be the expected number of calls of a run of the rule a with answer in B, minus the expected number of those calls at which the human's answer would be in B; Δ_n(B) := (1/n)·Σ_{t≤n} d_B(a_t) is this difference for a deployed run, given the rehearsal. For every test B:

(a) |E Δ_n(B)| ≤ L·√((1 + 1/n)·(2Λ(B) + 1.39 + ln(n + 1))/n);

(b) if the human never gives an answer in B, a deployed run has in expectation at most L·(log₂(1/π(B)) + 2)/n calls with an answer in B;

(c) with probability at least 1 − δ, for all tests at once, |Δ_n(B)| ≤ (L/n)·(|S_n(B)| + √(2n·ln(2/(π(B)·δ)))), which can be read off the record.

*Proof.* The asked call is the J-th, with J uniform on {1, …, L} (a shorter run asks nothing), so it is each of the L positions with probability 1/L, and by A1 its answer is a draw from P; so E[g_t(B) | past] = d_B(a_t)/L and E S_n(B) = (n/L)·E Δ_n(B); (a) and (b) follow from Pr5. For (c), S_n(B) − (n/L)·Δ_n(B) is a martingale with increments in intervals of length 2; apply the Azuma–Hoeffding inequality (standard; Hoeffding 1963) with failure probability π(B)·δ and sum over B (Theorems 6.2 and 6.3). ∎

So if "y is a correct solution of x" is a test, the deployed answers are correct as often as the human's would be on the same questions, up to (a). A2 is not used; the comparison is on the imitator's own questions, not with the human system. To bring the bounds below γ calls per run takes n of order L²·(2Λ(B) + ln n)/γ² in (a) and L·(log₂(1/π(B)) + 2)/γ in (b). The bounds average over the rounds: against a fair coin every single rule, kept for good, is off by 1/2 (Example 6.5).

### 8.5 What the imitator built from tests does not give

* **Tests outside the family.** With the single test "the answer is 1", the human f(x) = x mod 2 and the questions 1, 2, 3, …, the rule (ties to the least answer) keeps its book within 1 and is wrong in every round (Example 7.1).
* **Runs.** If a scaffold puts one question twice to a fair coin, every rule answers twice alike: total variation at least 1/2 from the human system for every n, with all tests matched (Proposition 7.3). In the toy problem of Section 11 the rule with one rate has an exact root in 62% of the runs, against 48% in the human system.
* **A choice, not a sample.** The answer balances books; at a fixed question it need not resemble a draw from P(·|x). A randomised version tilts a base sampler, such as the mixture, by exp(−Σ_B λ_t(B)·1[(x, y) ∈ B]), with λ_t computed from the books; against answers drawn from P its expected books obey the one-rate bound plus the base's cumulative divergence from the human divided by β·η, β being the strength of the tilt (Theorem 7.6). Open: one imitator with the mixture's bound under A2 and the test bounds without it, for a human who varies.
* **Against the mixture.** Let the class contain the human at K bits and give half its weight to tables that hold each question with probability p, with one of A good answers, and answer badly elsewhere. The mixture gives the bad answer, which the human never gives, with probability at least (1 − p)/2 at each of the first (K − 1)/log₂(A/p) new questions; Rule NH with this test at weight 1/2 gives it at most 3 times, against every human who never gives it (Proposition 8.1). The mixture is better for tests nobody listed (in Example 7.1, with a class of two, it errs in half a round in expectation), for whole runs (Theorem R2), and as a sampler. For a human who varies, both match frequencies at order 1/√n, which no imitator built from n answers can beat (Proposition 6.7; Le Cam's two-point argument, standard); K ln 2/n is the mixture's rate for the divergence.
* **Computation.** The rule is computable for decidable tests, computable weights with a computable tail bound, and a known finite set of candidate answers for each question, such as answers of bounded length (Proposition 4.2); with an unbounded answer set no rule that always halts works, even for one decidable test (Proposition 4.4). Enumerable weights were not examined.
* **Outside the closed system** nothing (Theorem N1).

*Attribution.* The method is not new: the step is Blackwell's approachability condition (1956) with an exponential potential, and with two answers the game is Spencer's balancing game (1977). The nearest published forms are online multivalid prediction (Gupta et al. 2022, Theorem 3.2; its tests see the forecast), defensive forecasting (Vovk et al. 2005, Theorem 1) and, for finitely many tests and one rate, Lee et al. (2022, Theorem 2.1). Rule NH's potentials are of the kind used by expert algorithms without a learning rate (Chernov and Vovk 2010; Luo and Schapire 2015) and by halving. Sandroni et al. (2003) is asymptotic and its rules see the forecast; for rules that do not, the asymptotic statement is Lehrer's (2001). Blackwell, Spencer, Lehrer and Sandroni et al. are cited through Abernethy et al. (2011), Bárány (2024) and Perchet (2013, Theorem 3.2, Proposition 3.2), Littlestone from memory; the other statements were read in the sources. We found no published statement of Pr5 in this form.

### 8.6 The mixture need not give the per-property price

Let R be a set of pairs that the human never violates.

**Pr2(a), hindsight** (proved here; Theorem 4.2). Suppose that with each ν the class contains ν^R ("redraw until the answer does not violate R"; no answer is no violation), and that the hypotheses mapped to one member weigh at most C_R times that member. For all programs and decidable R, C_R = 2^(K(R)+c) (standard facts, not proved here, not independently checked). Then on any data that do not violate R, the posterior mean of 1/(probability the hypothesis gave to not violating R at the inputs seen) is at most C_R. So the inputs seen, asked again, give at most ln C_R expected violations, and, as the researcher's notes claim, the mixture violates R with probability at most 1 − 1/C_R at every input. *Not said:* that it answers well. The remaining 1/C_R may be silence (violating 0.71, silent 0.18, abiding 0.11 in one example with C_R = 5; for samplers that always answer see Proposition 4.15).

**Pr2(b), a fresh input** (proved here; Theorem 4.5). Let R now be "the answer is not b". Take u ≥ 5 inputs, a human f with answers in {0, 1} and weight 2^(−K), K ≥ 2, and all memorisers (a table on some inputs, the answer b elsewhere) with weights proportional to (4u)^(−size). After n questions at distinct inputs the mixture answers b at a fresh uniform input with probability ((u − n)/u)·(2u/(2u + 1))/(1 + (4u + 2)^n/(2^K − 1)), and with probability above 0.51 after any n ≤ min{u/4, (K − 2)/log₂(4u + 2)} questions. Closing the class under conditioning multiplies the value by 1 − 1/C_R. This level is the prior probability that a memoriser violates R off its table, here 1.

**What holds** (proved here; Theorem 4.7, Proposition 4.9). Under A2, with questions drawn independently from the law of the fresh input, with probability 1 − δ, for all n, the mixture violates R there with probability at most (K ln 2 + ln(1/δ))/n. Under rehearsal a deployed run has at most L·K ln 2/n violating calls in expectation.

**Pr2(c), the machine** (proved here; Theorem 4.11). For every universal machine U, c ≥ 5 and d ≥ 3 there is a universal machine, at most c bits from U, on which this R has a 6-bit program and C_R does not depend on c, while for every human with answers in {0, 1} on u = 2^d inputs the mixture violates R at a fresh input with probability above 0.51 after any n ≤ min{u/4, (c − 5)/(d + 2)} questions. So no bound in the price of R and C_R holds on all universal machines: a fact about the prior. *Open:* such a bound for one fixed machine, with a constant of that machine.

### 8.7 What the human's answers can certify

**Theorem Pr7** (proved here; the observation is Dwork et al.'s). Let P₀ be a sampler and F a random function with independent values F(x) ∼ P₀(· | x).
(a) *One answer per input.* F is at total variation 1 − P₀(F(x) | x) from P₀ at every x. A procedure that puts m questions to the human, adaptively, accepts F on average as often as P₀, up to the probability that it puts some input twice. For a law μ on inputs, all but a fraction δ of the functions have every test frequency within √(Σ_x μ(x)²·(Λ(B) + ln(2/δ))/2) of that of P₀.
(b) *Answers from a large set* (not independently checked). If P₀(· | x) is uniform on s answers, the human who answers uniformly on a random half of them is at total variation 1/2 at every input, and m answers, with any repetitions, tell the two apart with advantage at most m²/(2s), on average over the halves.

*Idea.* Answer a random function lazily: each first-time question gets a fresh draw from P₀. Proof: `proofs/property-batch.md`, Theorems 6.2, 6.6.

So with one answer per input, or with long strings as answers, test frequencies are all that can be certified about a human who may vary. *Not said:* the same for repeated questions with few possible answers, which A1 allows. Two answers y₁, y₂ to a probe x give the collision statistic 1[y₁ = y₂] − A(y₁ | x) − A(y₂ | x) + Σ_y A(y | x)², with mean Σ_y (P(y | x) − A(y | x))² (after Goldreich and Ron 2000; Batu et al. 2000); with at most q possible answers it bounds the expected number of unfaithful calls of a run, at the slow rate m^(−1/4) (Proposition 6.4).

## 9. What remains a bet

Numbers refer to `proofs/assumptions.md`. A closed deployment and A1 to A3 are assumed unless stated otherwise.

### 9.1 The budget

For an excess failure δ with a fraction θ of the calls replaceable, R3 needs n = K ln 2/(θδ) answers for a deterministic human and K ln 2/(2θ²δ²) otherwise. For the former and θ = δ = 0.1:

| human time | n | K paid for |
|---|---|---|
| a working life of 10⁵ hours, an hour per answer | 10⁵ | 1443 bits |
| 50 years, a year per answer | 50 | 0.72 bits |
| 10⁶ people for 2000 hours, an hour per answer | 2·10⁹ | 2.9·10⁷ bits |

K for a person is unknown; Landauer's estimate of the learned content of memory, about 10⁹ bits (1986; from secondary sources), suggests its order under a prior that knows nothing of the individual. At K = 10⁹ and an hour per answer the count is 3.5·10⁷ working years. With a year per answer, which the researcher thinks research may need, every bound here is empty: a certificate alone takes 300 years. More people help little: the last row imitates a pool, and the bound credits sequential batches, not answers, unless questions do not depend on answers (Propositions 6.3, 6.5).

**Theorem N8 (the factor K under low stakes; proved here).** Let δ < 1/10 and N := g/(2δ) an integer. The inputs are d blocks of N cells, each cell in 2k+1 copies; the class is the 2^K functions that are 1 on one cell per block, K = d·log₂N. The scaffold draws a block and g of its cells, asks every copy (L = g·(2k+1) calls) and outputs 1 if most copies of some cell answered 1. Every member's human system tolerates k faults with failure 0. Yet failure at most δ for every member needs, in expectation over a uniform member,

  n ≥ (1−10δ)·K·g/(8δ·log₂(g/(2δ))),

while 2g·K ln 2/δ + 1 questions suffice (R3).

*Idea.* The blocks are d separate searches, as in N2b; copies add calls, not information. Proof: Theorem 6.1. The count depends on L and k only through g, the number of independent critical units: "whatever L" in R3 does not amplify such work. For additive work (L calls at uniform inputs, any k errors harmless) every protocol needs (1−2k/L−2δ)·K answers on the class of all functions on K inputs (Proposition 6.4). *What this does not say:* both are worst cases over one family; whether additive work ever needs the factor 1/(θδ) is open.

### 9.2 Rare situations, and isolation

Inputs that runs meet with probability far below 1/n are probably never asked; there the imitator does what the prior says, and R1 holds for two priors that disagree (Proposition 7.1). Averaged over the prior, a posterior draw per run is exact with no question asked (Proposition 7.7; standard, Thompson 1933): the theorems are about a human who is not typical of the prior, and a rare situation is a bet on the prior. A universal prior keeps a doubt of at least 2^(−sep−c) at each new kind of input (Section 4.1). The patch-free prior of `ultranatural/note.md`, restricted to *isolated* hypotheses, removes it:

**Theorem I1 (proved here; Theorem 9 of that note, with runs for samples).** Let H consist of functions, D(g, g′) be the probability that g and g′ give different runs, and the human f be δ-*separated*: D(f, g) is 0 or at least δ for every member g. Rehearse as in Section 2, but with one posterior draw answering each run. After n rounds the expected posterior weight of the members whose runs differ from the human's is at most 2^K·(1−δ/(2L))^n.

Proof: Theorem 7.4. The *isolated* members (heavier than every member within distance δ) are separated from one another. *The price* (Proposition 7.5): a human who is an isolated member patched where runs go with probability ε is imitated wrongly with probability at least ε per run for every n; the posterior shows no doubt until a question lands on the patch. *What it does not say:* that a person is separated. Separation depends on the reference machine, and no data decide between the two bets.

### 9.3 Memory, and a human who changes

**Theorem E1 (proved here).** Let the human be reset between episodes, each answer being a function of the messages and answers of its own episode so far. In each rehearsal round the human carries out one uniformly chosen episode of the run, and the mixture conditions on the earlier answers of the current episode. With L_e the largest number of episodes of a run and K the weight of that function, the deployed run has at most L_e·K ln 2/n unfaithful episodes in expectation, and R3 and V1(a) hold with episodes for calls. Proof: Theorems 1.7, 1.8. *What it does not say:* n counts human episodes, however long, and single messages shown to a fresh reader do not replace them (Example 1.10). For a human who is not deterministic only weaker forms hold (Theorem 1.9).

**Theorem E2 (proved here from the standard regret bound).** Let the human P_t of round t depend on the past in any way. For every ν in H,

  E[Σ_x KL(P_T‖M^(T))(x)] ≤ L·ln(1/w(ν))/n + (1/n)·Σ_t E[Σ_x KL(P_t‖ν)(x)],

the sums over x running over the calls of the runs of rounds T and t. Proof: Theorem 1.11. *What it does not say:* anything about the human after the last question (Proposition 1.14); and under steady drift the last term grows with n, so that longer rehearsal can be worse (Corollary 1.12).

### 9.4 Copy or predictor

The data fix the human's kernel on the inputs that the scaffold can produce, and nothing else (Proposition 7.8). Under A1 no predictor, however it models the world, gains on the human in expected log-likelihood (Proposition 7.9; standard, Ville 1939): a better predictor is assumed away, not excluded. A sampler and the same sampler with coins fixed in advance differ only on questions put twice (Proposition 7.10). The deployed object is a committee, redrawn at every call, episode or run; nothing makes it resemble the human inside.

### 9.5 The objections

Section 8 of the proof file classes twenty-two objections to "rehearsal is a human-imitation protocol that works as far as any protocol can". Seven are fatal to part of it:

* *K* (9.1): to "works from a reasonable number of answers", for a person;
* *critical steps:* for some scaffolds and classes no protocol amplifies work whose single steps decide the result, replicated or not (N2, N8);
* *long episodes:* on the researcher's numbers, unless scaffolds of short calls do research;
* *not a person:* one computation fixed in advance is imitated; fatal to "upload";
* *silent failures:* to "fails only obviously" at an affordable price without a further assumption (Section 7);
* *the human reads what the prior wrote:* to a class of all programs with a large scaffold and a reader who must not be harmed;
* *the human is a sampler:* no certificate free of K then bounds the unfaithful calls (V1).

The others are answerable at a price (a pool of people; a late random round; physical coins) or lie outside the theorems: whether the human system does anything, and whether it tolerates faults, which R3 assumes and the protocol never tests.

*What survives.* For a computation that we can run in advance, a human without memory who is one of the weighted candidates, and fresh coins throughout: n answers to single calls of the imitator's own runs give, for the mixture of a uniformly random round, at most L·K ln 2/n unfaithful calls per run in expectation if the human is deterministic, and L·√(K ln 2/(2n)) otherwise. For some scaffolds and classes of 2^K candidates every protocol needs a constant times K·L/(δ·log₂(L/δ)) answers. An imitator of a deterministic human can be certified at a cost without K. Nothing is offered outside that computation, at rates below about 1/n, or for a human other than the one who answered.

## 10. The seven tests

The tests are those that the researcher's notes apply to any proposal. Verdicts are for the protocol of Section 2 in a closed deployment. Details: `proofs/assumptions.md`, Section 5.

| test | verdict |
|---|---|
| 1 guard | passed for each property fixed in advance; for all at once only at the price K |
| 2 machine | the rates are the scheme's; K, rare inputs and every route to a small K are the machine's |
| 3 referent | passed under A3, as far as R1 is not empty |
| 4 copy | not passed |
| 5 budget | not passed |
| 6 rock | not a rock; its failures are silent |
| 7 horizon | outside the theorems |

**1. Guard.** *What does the scheme do at an input with a property that no training input has, such as task decomposition creates?* For each property fixed in advance, the probability that the deployed run meets it although no question had it is at most L/n (R7); N properties cost the factor N. Decomposition creates none, since rehearsal runs go to full depth. The statement is false for all properties at once, and for a property chosen with the data in view; these are covered only by R1, at the price K. At an input of a new kind the answer is the prior's (N1). A last mixture kept for good is not covered in general.

**2. Machine.** *Is that a fact about the scheme, or about the reference machine?* The rate 1/n and R7 mention no machine; nor does the certificate V1(a), which can be issued for a deterministic human only. The constant K is the machine's. So is the behaviour at inputs met less than about once in n runs: on some machine a deviant answer there has probability at least one half (Paper 1, Proposition 8.2), and R1 holds for both machines. So is every route to a small K: a prior built from knowledge, or isolation (I1).

**3. Referent.** *Does a hypothesis that models how the data set was made do as well as the intended one?* Under the five parts of A3 the asked call is an unbiased sample of a fresh run. So such a hypothesis loses weight at the rate at which it deviates on the mixtures' runs, and a prior fixed first gives the hypothesis that knows the realised coins at most the probability of guessing them (Theorem 3.2). That weight must be set against the human's 2^(−K): tables of the data outweigh the human until the questions carry more than K bits, and until then the imitator answers unasked inputs as the tables do (Remark 3.2a). So the test is passed exactly as far as R1 is not empty.

**4. Copy.** *Does anything distinguish the sampler from a better predictor of it, or from the sampler with coins filled in?* No (Section 9.4). The deployed object is the Bayes predictor of the human.

**5. Budget.** *How many answers, of what length, on which questions?* Of the order of K/(θδ) single calls on the imitator's own runs, those of the early rounds being the prior's. K is forced in the worst case (N2b, N8) and for a person is out of reach at any length of answer (Section 9.1). Cheap is only the check of a given imitator of a deterministic human: 300 short answers at θ = δ = 0.1 and confidence 0.95. For a human who varies no such certificate exists, and a certificate does not produce an imitator.

**6. Rock.** *Does the scheme still act on the inputs that matter?* It acts everywhere in the closed system; its unfaithful calls are unmarked and must be taken as an adversary's. The theory has the opposite corner too: the minimum rule (Ab2) fails only visibly on any input, and where it is sound without an assumption it refuses every input of a new simple kind; with a moderate plausible set it is a whitelist whose soundness the data cannot confirm. Nothing here acts on new inputs, fails only visibly and needs no assumption.

**7. Horizon.** *Granting perfect per-call imitation, does the scaffold do anything?* No theorem about the learner can say. Three points weigh against. R3 needs a human system that survives arbitrarily replaced answers, which the protocol never tests. Where that tolerance comes from replication it buys no amplification (N8). And the budget is met only by short calls, while the researcher expects that an episode able to do research may take a year.

## 11. A toy closed system

The computations of this section illustrate the theorems on a problem small enough for the Bayes mixture to be computed exactly. They prove nothing. Scripts are in `code/`, outputs in `results/`.

**The system.** The human is the function f(a, b) = (a + b) mod 32. A task is a list of 2^h numbers below 4, and the scaffold adds them in a balanced binary tree, one call for each internal node, so L = 2^h − 1. Calls deep in the tree contain larger numbers than any task does: this is the shift that task decomposition produces. The class has 1117 functions with description-length weights: f; two functions that are simpler than f and agree with it on small numbers ("a + b if both are below 4, else 0", and addition that saturates at 31); 90 guards of the form "f, except another simple function where a simple condition on (a, b) holds"; and 1024 patches that change f at one input. Here K = 3.78 bits.

**Ordinary questions fail; rehearsal does not** (`toy.py`, `results/toy.out`). After 10,000 questions about pairs of numbers below 4, the posterior is where it was after 100: weight 0.59 on the first simpler function, 0.30 on the second, 0.07 on f. The questions cannot separate them. Deployed on the tree, the mixture then has an unfaithful call in 35% of the runs at depth 2, 98% at depth 4 and 100% at depth 6. With rehearsal, the number of unfaithful calls summed over all rehearsal runs stays below the bound L·K ln 2 of Theorem R1 (averages over 60 repetitions):

| depth | L | unfaithful calls, summed over 6400 rounds | bound L·K ln 2 | runs with an unfaithful call, average over 6400 rounds |
|---|---|---|---|---|
| 2 | 3 | 2.3 | 7.9 | 0.0004 |
| 4 | 15 | 21.7 | 39.3 | 0.0025 |
| 6 | 63 | 91.8 | 165.0 | 0.0043 |

With one posterior draw answering each run, the runs with an unfaithful call number 1.6, 15.4 and 22.3 in total, against the bound (2L²/(L + 1))·K ln 2 of Theorem R4 (11.8, 73.7, 325). When the heaviest function consistent with the answers so far answers the runs, they number 3.3, 21.1 and 27.2, against the bound of Proposition R6(a), L times the number of functions heavier than f (6, 30, 126). Only two functions are heavier than f here, so the driver that R6(a) warns against does little harm in this class.

**High stakes and low stakes** (`toy_stakes.py`, `results/toy_stakes.out`). Two systems ask L independent additions of uniform pairs. In the first a run is good only if every answer is the human's; in the second, if at most 5% of the answers differ. Both are answered by the same rehearsed mixture. After 6400 questions the first fails in 0.1%, 1.2% and 11.9% of the runs for L = 16, 256 and 4096; the second in 0.11%, 0.03% and 0.03%, below the bound K ln 2/(θn) = 0.82% of Theorem R3, which does not depend on L.

**The certificate** (same script). The mixture frozen after 400 rehearsal questions (L = 256) was put through validation with 1000 further questions, 160 times over. In 140 of the repetitions no recorded pair disagreed, and Theorem V1(a) then certifies a rate of unfaithful calls of at most ln(20)/1000 = 0.003 per call at confidence 95%. The true rate was 0.00014 on average and never above the certified bound.

**An imitator made of tests** (`toy_property.py`, `results/toy_property.out`). The rule with one rate of Section 8.4 was run on a smaller version of the problem (numbers mod 8, depth 3) with 805 tests such as "y − a − b = c", "y = c", "y is even", each also restricted to simple conditions on the input. It has no class of hypotheses. With the deterministic human its audited answers were exact sums in every round of the second half of each experiment. With a human who adds 1 too much with probability 0.1, its answers were exact sums at the rate 0.90, the human's rate, and the largest discrepancy over all tests, |S_n(B)|/n, was 0.0003 after 64,000 rounds (the bound for that test is 0.024). The root of the tree, a property of the whole run, was exact in 62% of its runs against 48% for the human system (57% under Rule NH after 8000 rounds; `proofs/code/property-online_rehearsal.out`): tests of single calls do not control what happens across calls.

## 12. Related work

Most statements of this note are instances or variants of published results.

**Bayes mixtures.** Theorem R1 rests on a standard inequality: on every sequence, the log loss of a Bayes mixture over a countable class exceeds that of a member ν by at most ln(1/w(ν)). Solomonoff (1978) proved its consequence for the universal mixture on binary sequences: the expected summed squared error is at most (k/2)·ln 2, k being the description length of the true measure. Hutter (2003, Theorem 1) has the form for countable classes, and Solomonoff (2008) the form for question–answer pairs with any given inputs. For inputs chosen from the earlier pairs it is Proposition 5.7(b) of Paper 1 and, in squared Hellinger distance, Lemma A.14 of Foster, Kakade et al. (2021).

**Imitation learning.** An error ε per step on the expert's states can cost T²ε in T steps (Ross and Bagnell 2010, Theorem 2.1), but at most uTε on the learner's own states, u being the cost of one deviation (Ross, Gordon and Bagnell 2011, Theorem 2.2). Their Theorem 4.1 is the reduction that rehearsal instantiates: a no-regret learner fed with the losses at the states its own policies visit yields a policy whose loss there is at most the best in hindsight plus the average regret. Li and Zhang (2025, Theorem 3) analyse the algorithm itself: exponential weights under log loss, one state of each rollout put to the expert, a uniformly chosen iterate deployed. For a deterministic expert in a finite class of size B, horizon H and cost μ of one deviation, the performance gap after N queries is at most μH·(log B + 2 log(1/δ))/N with probability 1 − δ. Protocol R is this algorithm with a prior on a countable class, and Theorem R1 for a deterministic human is the estimation step of their proof. The additions are stochastic humans, the whole-run bound R2 and assumption A3. Foster, Block and Misra (2024, Proposition 2.1) show that maximum likelihood on n recorded expert trajectories in a finite class Π gives, with probability 1 − δ, H² ≤ log(|Π|/δ)/n between trajectory laws, without a horizon factor. Their Theorem G.1 takes one policy that acts the same everywhere and m policies that each deviate at one of m self-looping states: fewer than cm queried episodes leave an expected gap of cH/m. Theorem B is Proposition 2.1 for a countable class, and Theorem A its Bayes form. Theorem N2 uses the class of Theorem G.1 and adds the factor L for L critical calls. We did not find that form; Li and Zhang call lower bounds for single-state queries open.

**Asking the demonstrator.** Cohen, Hutter and Nanda (2022) study, for a countable class of stochastic policies and without resets, an imitator that takes each action with the least probability that any model in a posterior top set gives it and asks the demonstrator with the rest. The demonstrator stays in the top set with probability at least 1 − α/w (Theorem 2); the imitator's own actions then have at most the demonstrator's probabilities; and the expected sum of the cubed query probabilities is at most |A|·α⁻³·(24/w+12) (Theorem 1). Rule Ab2 is this imitator with the demonstrator withdrawn: a query becomes an abstention. Cohen and Hutter (2020) and Kosoy (2019) prove safety bounds for reinforcement learners that defer to a mentor. In all three the price is polynomial in 1/w, hence exponential in K, and the human stays available. Plaut, Zhu and Russell (2025) get vanishing regret from sublinearly many queries for mentor classes of finite dimension and Lipschitz payoffs. The random audit of rehearsal is the device of Cesa-Bianchi, Lugosi and Stoltz (2005): with N experts, T rounds and m randomly queried labels the optimal regret is of order T·√(ln N/m). In the KWIK model (Li, Littman and Walsh 2008) a learner must be accurate or say "I don't know" and sees the label only then; |H| − 1 such answers suffice for a finite class H of functions. With k mistakes allowed and all labels revealed, (k+1)·|H|^(1/(k+1)) suffice (Sayedi, Zadimoghaddam and Blum 2010), which is tight for thresholds (Zhang and Chaudhuri 2016). Ab1 is the Bayes-mixture form of this trade-off, and N4 its standard example of singletons. A classifier that is never wrong may answer only where all consistent hypotheses agree (El-Yaniv and Wiener 2010, Theorem 7); for a class closed under exceptions this is the corollary of N1 on abstention. PQ-learning (Goldwasser et al. 2020, Theorem 5.2) gives, for deterministic binary labels and test inputs known in advance, error on an arbitrary test distribution and rejection rate on the training distribution of order √(d·ln n/n) for VC dimension d. The note has no counterpart.

**The floor at novel inputs.** Paper 1 (Proposition 8.1) shows that for every decidable set Q disjoint from the data and every computable behaviour b, the hypotheses that fit the data and behave like b on Q keep posterior mass at least 2^(−K(Q,b)−c), whatever the amount of data; the mass depends on the machine (Proposition 8.2; `ultranatural/note.md`, Theorem 3). Cohen, Hutter, Bengio and Russell (2025, Theorem 1) prove the analogue for a Bayesian imitator: after an unprecedented event E, some policy within KL divergence of about K(U) + K(E) from the imitator is nearly optimal for the utility U, however much demonstrator data there is. Theorem N1 extends the floor to every protocol by the usual two-hypothesis argument. The "malign prior" argument (Christiano 2016b; Xu 2020) claims more: the hypotheses that hold this mass are many and choose where they deviate. To our knowledge it is neither proved nor refuted. It leaves Theorem R1 intact and is the reason to treat unfaithful calls as adversarial, as Theorem R3 does.

**Low stakes, fault tolerance, scaffolds.** Christiano (2021) calls a setting low-stakes if no small number of decisions matters much, and argues informally that online training then suffices. Theorem R3 is this claim for the Bayes mixture, and Theorem N2 its high-stakes counterpart. Imitation learning uses recoverability (the u and μ above) where Theorem R3 uses tolerance of adversarially replaced answers. Von Neumann (1956) showed that components failing independently with probability below a threshold can be combined, by redundancy and majority votes, into a network that stays reliable however long the computation. The scaffold in the proof of N5 is the simplest such construction. The scaffolds in view are HCH (Christiano 2016a; a definition) and iterated amplification (Christiano, Shlegeris and Amodei 2018), which trains a predictor of the human's decisions on inputs made with the current model and has no theorem. Rehearsal is its on-policy part, without the distillation.

**Tests and indistinguishability.** Dwork et al. (2021) call a predictor of binary outcomes outcome-indistinguishable for a class A of tests if no test accepts Nature's outcomes and the predictor's with probabilities differing by more than ε; its two weakest forms are equivalent to multiaccuracy and multicalibration (Hébert-Johnson et al. 2018). Such a predictor can be learned whatever Nature is, from O(log|A|/ε²) samples for tests that do not see the predictor (Dwork et al. 2022), and it need not be close to Nature. Theorems V1(b) and Pr3 are this statement for string answers and weighted tests, on the imitator's own inputs and on recorded runs. Pr4 is minimum-distance estimation: by matching empirical frequencies on the sets {q_i > q_j}, Yatracos (1985) selects, from O(log|Q|/ε²) samples, a member of a finite class Q within 3·opt + ε of the target in total variation (see Devroye and Lugosi 2001); the factor 3 is optimal for such rules (Bousquet, Kane and Moran 2019). Theorem Pr5 is an approachability argument in the sense of Blackwell (1956), who proved that a closed convex set of vector payoffs is approachable in a repeated game exactly when every half-space that contains it can be forced in one step. The nearest published statements are forecasts that pass countably many checking rules (Sandroni, Smorodinsky and Vohra 2003), defensive forecasting (Vovk, Takemura and Shafer 2005), online multicalibration with an exponential potential (Gupta et al. 2022) and online outcome indistinguishability for generative models (Farina and Perdomo 2026). We did not find Pr5 itself and claim no new method. For a stochastic human, that validation certifies tests and not total variation is forced: deciding whether an unknown distribution on n points is uniform or ε-far from uniform takes of order √n/ε² samples (Paninski 2008; for two unknown distributions, Chan et al. 2014), and for long strings n exceeds any budget.

**Subadditivity of the squared Hellinger distance.** Theorem R2 uses H²(P,Q) ≤ c₀·E_P Σ_i H²(P_i,Q_i) for data generated step by step. Foster, Kakade et al. (2021, Lemma A.13) prove it with c₀ = 100·log n, and Foster, Han et al. (2024, Lemma D.2) with c₀ = 7, from the cut-and-paste property of Jayram (2009). The note proves c₀ = 4 and, by a longer argument, c₀ = 2.9641, and gives an example with ratio 2.9639, computed in floating point. We found no published constant below 7; the search was not exhaustive.

## 13. Open questions

The questions are ordered by how much an answer would change the conclusions of Section 0. Each proof file ends with a longer list for its part.

1. **A prior under which K is affordable.** Every positive result is in K, and the theorems hold for any prior fixed before the data. Nothing here says how to obtain a prior that puts weight 2^(−K) on a given person with K in the thousands and not in the billions, nor how to tell that one has it. With the certificate one can at least find out afterwards, for a human who is nearly deterministic on the inputs that matter.

2. **Classes without patches.** If the human is separated from every other member of a class, the posterior concentrates exponentially fast (I1), and the lower bounds of Section 4 do not apply, because they need a class that can change one place at a time. Is there a natural class of this kind that contains the humans one cares about? For functions on the integers the companion note on isolation (`ultranatural/note.md`) has candidates; for samplers, and with a prior to fall back on when the human is outside the class, nothing is proved.

3. **Both prices in one imitator, for a human who varies.** For a deterministic human, the imitator built from tests pays K + 3 disagreements if the human is in the class and log₂(1/π(B)) + 2 violations of each property otherwise (Pr5). For a human who varies, the tilted mixture trades the two against each other (Section 8.5). Is there one randomised imitator whose divergence from the human, summed over the questions, is of order K under A2, and whose books are of order √(n·(Λ(B) + ln n)) with no assumption?

4. **The factor K, exactly.** Over classes of K bits the least number of questions is of order K·L/(δ·log₂(L/δ)), reached by targeted questions that may lie off every run (N2c); rehearsal's own worst case is of order K·L/δ. A variant that asks only calls of its own runs and saves a logarithm is in the proof file with one check (`proofs/lower-bounds.md`, Proposition 3.9). Under low stakes with bounded damage the only lower bound that contains K is n ≥ (1 − 2θ − 2δ)·K; whether the factor 1/(θδ) of R3 is needed there is open.

5. **Low stakes for a human who varies.** R3 costs of the order of K/θ² questions in an example, against K/θ for a deterministic human. When is K/θ enough, and must the number of questions grow as the allowed excess failure shrinks?

6. **The last round.** All bounds are for the mixture of a uniformly chosen round. For a deterministic human on a scaffold whose questions depend on the answers, the mixture after all n answers is known to lose a factor between a constant and about L·ln n in the probability of an unfaithful run; for recorded runs (H1) the question whether the last posterior alone has the bound is posed in the literature (Grünwald and Kotłowski 2011).

7. **One program for a human who varies.** A member chosen by squared weights after rehearsal by the mixture has a bound (R6(c), checked by one reader besides its author). Whether a posterior draw for each run can be supported by fewer answers than whole recorded runs of the human system is open, and so is the general form of R5: does the plurality vote of the committee always inherit the fault tolerance that the committee uses?

8. **Abstention.** A bound on what the threshold rule refuses (its width as a whitelist); whether the novelty rule needs s > 2K or s > K suffices; rehearsal driven by the minimum rule, which would remove the term L(L − 1) from Ab2(d); what replaces the count of abstentions for samplers (Section 7.5); computable versions of sep and of the plausible sets under time bounds.

9. **The reference machine.** Whether the mixture keeps a simple property at a fresh input, at a price in the property's complexity, is false on some universal machines (Pr2(c)) and open for any fixed one that would be called natural. No definition of natural is known that makes the question precise.

10. **Episodes.** When the unit put to the human is an episode with memory inside it, R1 and V1 hold with episodes for calls (E1). For nested episodes and a human who varies the whole-run bound carries an extra factor, the smaller of four times the largest number of calls in one episode and half the number of episodes of a run; whether it is needed is open.

11. **Constants.** The best constant in Lemma L4(a) lies between 2.9639 and 2.9642. The constants of the lower bounds for a human who varies (N6) are about 10⁴ away from the upper bounds.

## References

(The list is being consolidated.)
