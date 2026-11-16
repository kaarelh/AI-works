# The property idea in batch form: Pr1 to Pr4, the Bayes mixture and a simple property, the certificate (key: property-batch)

Final proof file of the part property-batch. It is the prover's file `research/prove-c/property-batch.md` (third round; its Sections 1 and 2 go back to the earlier worker's `research/prove-b/property-batch.md`), corrected in place by the editor after two verification reports: `research/verify/property-batch-check.md` (a line-by-line check, below "the check report") and `research/verify/property-batch-attack.md` (an adversary's report, below "the attack report"). Section 11, "Checking", lists every finding of the two reports and what was done about it, and says for each statement who checked its proof. Every statement is proved in this file unless it is tagged otherwise. "I" in Sections 1 to 10 is the prover; passages added by the editor say so. The scripts and their saved outputs are in `proofs/code/`: the prover's five scripts `property-batch_pr3.py`, `_pr4.py`, `_pr2.py`, `_prices.py`, `_cert.py` (quoted in Section 9), the verifiers' scripts `property-batch_check_*.py` and `property-batch_attack_*.py`, and the editor's `property-batch_editor.py`; each has its output next to it as `*.out`.

Tags: **PROVED** (complete proof below), **REFUTED** (counterexample below), **MODIFIED** (the draft's statement is changed, and the change is stated), **ADDED** (not in the lead's list of claims `research/candidate-theory.md`; proved below), **OPEN**. The tag ADDED says nothing about novelty. What is standard is called standard where it is stated, with the source; Sections 3.6 and 10 say how each source was accessed.

## Summary of the statements

N is the number of independent recorded runs of the human system, n a number of question–answer pairs, m a number of validation questions; K is the description length of the human, K(ν) that of a hypothesis, K(R) the price in bits of a test or property.

| no. | statement | tag |
|---|---|---|
| Lemma 1.1 | The law of a run answered by a sampler has the density Π_j ν(y_j\|x_j) with respect to one reference measure; it is read off the transcript. | PROVED |
| Statement 2.0 (**Pr1**) | TV ≤ ε is the same as "every event of runs within ε". | PROVED (definition) |
| Lemmas 2.1, 2.2 | Binomial tails in divergence form; three lower bounds on kl. | PROVED (standard) |
| Theorem 2.3, Corollary 2.4 (**Pr3**) | For a weighted family of tests of runs, with probability 1 − δ, kl(Q̂_N(R)‖Q(R)) ≤ ln(2/(π(R)δ))/N for all R; the Hoeffding form, a relative form, and Q(R) ≤ ln(2/(π(R)δ))/N for tests that never occurred. The only assumption is (IID): the N runs are independent and have one law, so the human does not change or remember from run to run. | PROVED; standard (the Occam's razor bound; sources after the theorem) |
| Theorem 2.5 (**Pr3** as drafted) | (a) \|Q̂_N(R) − Q(R)\| ≤ tol_N(R) for all R at confidence 1 − δ; (b) Q(R) ≤ ln(1/(π(R)δ))/N for all tests that never occurred, at confidence 1 − δ; (c) both together at confidence 1 − δ. | (a), (b) PROVED; (c) REFUTED (N = 1, one test), MODIFIED to confidence 1 − 3δ/2 and PROVED |
| Corollary 2.6 | Every imitator that matches the test frequencies is within √(2 ln(2/(π(R)δ))/N) of the human system on each test R, and gives a test that never occurred at most ln(2/(π(R)δ))/N. | PROVED |
| Lemma 2.8 | The price ln(1/π(R)) cannot be removed: for M independent tests of probability 1/2, (N + 1)³ ≤ M ≤ e^N, some test deviates by at least ½·√(ln M/(3N)) − 1/N, with probability 1 − e^(−(N+1)). | PROVED (added by the editor from the sketch in the check report; replaces the unproved Remark 2.7(4)) |
| Theorem 3.3 (**Pr4**, human system in the class) | The draft's estimator (highest-weight sampler matching all tests, Yatracos sets with weights w(ν)w(ν′)): TV ≤ √((4K ln 2 + 2 ln(2/δ))/N), and every test of the family within 2·tol* (the tolerance with the halved weight π(R)/2). | PROVED; MODIFIED: ln(4/δ) in place of ln(2/δ) when the sets are added to a family that already has weight 1 |
| Definition 3.4, Theorem 3.6 (**Pr4**, any human system) | Penalised one-sided minimum distance. With probability 1 − δ, for every ν in the class: TV(Q_ν̂, Q) ≤ 3·TV(Q_ν, Q) + √((2K(ν) ln 2 + 2 ln(2/δ))/N). A version whose estimator does not depend on δ. | PROVED (announced in the draft as "to be proved"; estimator designed here) |
| Corollary 3.7 | In the class: TV ≤ √((2K ln 2 + 2 ln(2/δ))/N) (2K in place of the draft's 4K). In expectation: E TV ≤ min_ν[3·TV(Q_ν, Q) + √(2K(ν) ln 2/N)] + √(2π/N). | PROVED |
| Proposition 3.8 | The highest-weight sampler that passes one-sided tests: both prices at once, with 2K. | ADDED, PROVED |
| Proposition 3.9 | Tests only, any set of candidates, no weights: every near-minimiser of the weighted test discrepancy is within 2·tol_N(R) plus the approximation error in the test seminorm. | ADDED, PROVED |
| Section 3.5, Theorem 3.10 | What must be computable: a list of the heavy indices (finite, but of length up to about e^(2N)); exact comparison of likelihoods on given runs; the numbers Q_ν(A_νν′), which need a closed system; tests from a language in which every program halts. A version with simulated runs: 2r_N + 2r_{N_s} in the bound, at confidence 1 − 2δ. | ADDED, PROVED |
| Examples 3.11 | The factor 3 is attained by the estimator; without a penalty the replay of the data wins; outside the class the draft's estimator may be undefined. | PROVED |
| Theorem 4.2, Corollary 4.3 (**Pr2(a)**) | Hindsight: on data that abide by R, the posterior mean of 1/(probability the hypothesis gave to not violating R so far) is at most C_R, for a class closed under conditioning on R with constant C_R (exact definition (Cl_R)). Hence at most ln C_R expected violations over the inputs seen, and never-violators keep posterior weight 1/C_R. The never-violators may be hypotheses that give no answer (Remark 4.14). | PROVED (closure made exact; "abiding" must mean "not violating") |
| Theorem 4.5 (**Pr2(b)**) | Memorisers: exact value of the mixture's violation probability at a fresh input; above 0.51 for all n ≤ min{u/4, (K − 2)/log₂(4u + 2)}; below 2^(−j) after (K + j)/log₂(4u + 2) distinct inputs. | PROVED |
| Corollary 4.6 | The memoriser class closed under conditioning: the violation probability is (1 − 1/C_R) times that of Theorem 4.5; the floor 1 − 1/C_R is approached (it is the supremum over u and K, and is not attained), and under closure alone no bound tends to 0 with n. | PROVED (MODIFIES the draft's "stays near 1": near 1 − 1/C_R in a closed class) |
| Theorem 4.7 | Foresight in any class: with probability 1 − δ, for all n, 1 − V(D_n) ≥ (δ·M(D_n)/P(D_n))^(1/n), and a violation level v needs log₂(1/(1 − v)) bits of regret per pair. If the human is in the class: V(D_n) ≤ (K ln 2 + ln(1/δ))/n. | ADDED, PROVED (a relative of the PAC-Bayesian bound for consistent hypotheses; see after the theorem) |
| Proposition 4.8 | Recognisers: the trade-off of Theorem 4.7 is attained (level 1 − σ for K/log₂(1/σ) pairs). | ADDED, PROVED |
| Proposition 4.9 | Rehearsal: the expected number of calls of a deployed run that violate R is at most L·K ln 2/n. | PROVED (from Theorem R1) |
| Proposition 4.10 | Memorisers and one fair coin: exact; the violation probability falls after log₂(1/γ)/log₂(2u + 1) questions. | ADDED, PROVED |
| Theorem 4.11 (**Pr2(c)**) | (A) For every class (H₀, w₀) and every c, adding memorisers of weight (1/4)·(4u)^(−size of the table) and scaling H₀ by 2^(−c) gives a class in which the mixture answers b with probability above 0.54 at fresh inputs for all n ≤ min{u/4, (c − 4)/log₂(4u)}, for every human f. (B) For every universal machine U, every c ≥ 5 and every d ≥ 3 (u = 2^d inputs) there is a universal machine U″ with K_{U″} ≤ K_U + c on which the property "the answer is not b" has a program of 6 bits, the class of all programs is closed under conditioning on it with a constant that does not depend on c, and the mixture violates the property with probability above 0.51 at fresh inputs for all n ≤ min{u/4, (c − 5)/(d + 2)}, for every human f. | (A) PROVED. (B) PROVED (added from the check report: on the machine U′ that the prover built from (A) the property costs more than c bits, so (A) alone does not separate the price K from the price of the property; the closure constant in (B) rests on the standard facts of Remark 4.4) |
| Proposition 4.12 | In any class: humans that are typical members of an abiding source S in the class are protected at the price K(S), as long as no input repeats. | ADDED, PROVED |
| 4.13 | What is proved about the class of all programs: the hindsight bound on every machine; the bound with the cost K* of the cheapest explanation; no bound in terms of the price of R and the closure constant that holds on all universal machines; on every machine with a cheap coin, V(D_n) ≤ ½ + (k_c ln 2 + ln(1/δ))/(2n) for humans with binary answers. | PROVED |
| 4.13, item 4 | For one fixed universal machine U: is there a constant c_U with V(D_n) ≤ ((c_U + K_U(R)) ln 2 + ln(1/δ))/n for every decidable R and every human in the class that never violates R? | OPEN (neither proved nor refuted for any machine; Theorem 4.11(B) shows that c_U is not bounded by the constants that govern hindsight) |
| Remark 4.14, Proposition 4.15 | The floor of Corollary 4.3(c) can consist of silence: in the closed memoriser class with C_R = 5 the mixture violates with probability 0.711, is silent with probability 0.178 and gives an abiding answer with probability 0.111. A conditioning that always answers (fall-back sampler G, parameter θ): the hindsight bound holds with 1/(1 − (1 − θ)v) in place of 1/(1 − v), and the mixture gives an abiding answer with probability at least 1/C at every input. | PROVED (added from the attack report, Finding m5 and Proposition X3; re-derived by the editor) |
| Proposition 5.2 | A coin matches every test of a family as well as N runs can certify and is at total variation 1/2 from a typical function f. | PROVED |
| Example 5.3 | All per-call tests matched, a constant-price test of runs off by 1/2. | PROVED |
| Proposition 5.4 | When the human is a typical function f, the coin is a member of the matching set 𝓜_N with probability at least 1 − δ − C(N, 2)·coll(μ). | PROVED (added from the attack report, Proposition X4; re-derived by the editor) |
| Theorem 6.1 (**V1(b)**) | The certificate; divergence form with half the tolerance of the note; it is Theorem 2.3 for a derived scaffold of horizon 1. The frequencies are counts divided by the number m of rounds. | PROVED (constant improved) |
| Theorem 6.2 (**Pr7**, first half) | Let F be a random function with independent values F(x) ∼ P₀(·\|x). (c) Every procedure with m questions accepts the deterministic human P_F, on average over F, as often as the stochastic human P₀, up to the probability ξ that it puts some input to the human twice. (d) For every procedure there is one deterministic human f, at total variation at least 1 − p_max(x) from P₀ at every input and with nearly the same test frequencies, whom the procedure accepts at least as often as P₀, up to ξ + η (a one-sided statement). | ADDED, PROVED (the observation is that of Dwork et al. 2021; see Section 6.2) |
| Example 6.3 | Parity against the coin: exactly equal frequencies on a large family of tests. It is not an example of indistinguishability: one question separates the two. | PROVED |
| Proposition 6.4 | Two answers per probe: an unbiased estimate of the mean of Σ_y (P(y\|x) − A(y\|x))² over the calls of the imitator's own runs (the collision estimator), and from it a bound on the expected number of unfaithful calls when the answers come from a set of at most q elements. | PROVED (added from the attack report, Proposition X1; re-derived by the editor) |
| Proposition 6.5 | A two-sided form of Theorem 6.2(d) for rules whose probes are independent draws: one function f for a whole weighted family of decision rules. | PROVED (added from the attack report, Proposition X2; re-derived by the editor) |
| Theorem 6.6 (**Pr7**, second half) | Answers from a set of s elements: the human who answers uniformly and the human who answers uniformly on a random half are at total variation 1/2 at every input, and no procedure with m questions, repeated or not, tells them apart with advantage above C(m, 2)/s. | PROVED (added by the editor; checked by exact enumeration, not examined by a verifier) |
| Section 8 | Open questions; remarks on other files. | OPEN |
| Section 11 | Checking: the findings of the two reports and what was done; who checked which proof. | — |

**In brief.** (1) Pr3 holds as a statement about any human system whose runs are independent and identically distributed; it is the Occam's razor bound, and the joint confidence claimed in the draft is 1 − 3δ/2, not 1 − δ. (2) Pr4 holds. In the class the draft's estimator has the stated bound; a one-sided estimator has √((2K ln 2 + 2 ln(2/δ))/N). Outside the class the draft's estimator may be undefined; the penalised minimum-distance estimator satisfies TV ≤ 3·TV(Q_ν, Q) + √((2K(ν) ln 2 + 2 ln(2/δ))/N) for every ν, and the factor 3 is attained by this estimator. To compute it one needs decidable comparisons of likelihoods and a closed system. For a human who keeps state within a run and a class of stateless samplers the inequality can be empty. (3) Pr2: the hindsight bound holds with the closure constant C_R, and its floor may consist of silence; at a fresh input the mixture pays the regret, hence K, and need not pay only the price of R; in a class of memorisers it violates a trivial property with probability above 1/2 for (K − 2)/(bits per pair) questions, and universal reference machines exist on which the property has a program of 6 bits and the same happens for as many questions as one likes; for one fixed machine the question is open. (4) The two prices are incomparable: a coin can satisfy every test-matching guarantee that N runs allow and be wrong at every call with probability 1/2. (5) The certificate V1(b) is Pr3 for single calls. With one answer per input, frequencies of tests are all that can be certified about a human who may be non-deterministic (Theorem 6.2); the same holds with repeated questions when the answers come from a very large set (Theorem 6.6); with a question put twice and answers from a small set, a mean squared distance of the answer laws can be certified (Proposition 6.4).

---

## 1. Setting and notation

The notation is that of `research/outline.md`. The following additions and changes are used throughout.

* **Hypotheses are indices.** The draft's A2 calls H "a countable class of samplers with weights". Two descriptions of the same kernel must be allowed to carry separate weights (this is so in the class of all programs), so here H is a countable index set, each ν ∈ H names a sampler (also written ν), and w(ν) > 0 with Σ_ν w(ν) ≤ 1. K(ν) := log₂(1/w(ν)).
* **Sample sizes.** N is the number of recorded runs of the human system (Sections 2, 3, 5). D_n is a data set of n question–answer pairs ((x_1, y_1), …, (x_n, y_n)) (Section 4). m is the number of validation questions (Section 6). In Section 4 the finite input set has u elements.
* **Semimeasures.** A semimeasure sampler (Σ_y ν(y|x) ≤ 1) is completed by the outcome ⊥ ("no answer") with ν(⊥|x) := 1 − Σ_y ν(y|x). Put Y⊥ := Y ∪ {⊥}. The draft does not say what a scaffold does after ⊥; here a run stops at the first call that is answered ⊥.
* **Letters.** len(τ) is the number of calls of the run τ (the outline keeps T for the deployed round). Γ is the reference measure on runs of Lemma 1.1. R denotes an event of runs (a *test*, Sections 2, 3, 5) or a set of pairs (a *property*, Section 4); B denotes a set of pairs used as a per-call test (Section 6), as in `note.md`. A pair (x, y) is a run of the scaffold that makes one call, so these uses agree. μ is a law on X (Sections 4 to 6) and coll(μ) := Σ_x μ(x)² its collision probability. All other letters are defined in the section that uses them.
* **Letters with two uses** (noted by the check report; the proof file keeps them, the section text of the note does not). T is a table in Theorems 4.5 and 4.11, Corollary 4.6 and Proposition 4.10, and the deployed round only in Proposition 4.9. η is a probability in Proposition 5.2, Theorem 6.2, Proposition 6.5 and Theorem 6.6, and η_i(B) is an indicator in Theorem 6.1. S is a sampler in Theorem 4.7(e) and Proposition 4.12, the set of inputs of a data set in the proof of Theorem 4.5, and a set of recognised inputs in Proposition 4.8.

**1.1 Runs.** A scaffold Π of horizon L consists of a law D₀ of the top-level input z ∈ Z, a law Λ of the internal randomness ρ (any measurable space), measurable maps next_j(z, ρ, y_1..y_{j−1}) ∈ X ∪ {STOP} for j ≤ L, and an outcome map. (Measurability holds for every scaffold that is a program; the check report notes that Lemma 1.1 uses it.) A *complete run* is τ = (z, ρ, y_1, …, y_len) with len ≤ L such that next_j ≠ STOP for all j ≤ len, y_j ≠ ⊥ for j < len, and (len = L or y_len = ⊥ or next_{len+1} = STOP). The inputs x_j(τ) := next_j(z, ρ, y_{<j}) are functions of τ, so they need not be listed. Ω is the set of complete runs, with the product σ-algebra 𝔉 (Y⊥ is countable and discrete). An *answerer* A is a probability kernel giving the law of y_j ∈ Y⊥ given the history h_j = (x_1, y_1, …, x_{j−1}, y_{j−1}, x_j); a *sampler* is an answerer that depends on x_j only. Q_A is the law of the complete run when z ∼ D₀, ρ ∼ Λ independently, and each answer is drawn from A.

**Lemma 1.1 (likelihood of a run). PROVED.** For a sampler ν put L_ν(τ) := Π_{j ≤ len(τ)} ν(y_j | x_j(τ)) (the empty product is 1). Let Γ be the measure on Ω that is D₀ ⊗ Λ on (z, ρ) times counting measure on the answer sequences. Then Γ is σ-finite and Q_ν(E) = ∫_E L_ν dΓ for every E ∈ 𝔉. The same holds for an answerer A with L_A(τ) := Π_j A(y_j | h_j(τ)).

*Proof.* Fix (z, ρ). The complete answer sequences for (z, ρ) are the leaves of a tree of depth at most L with countable branching: a node y_{<j} is a leaf iff it is complete. Drawing the answers one after another, the probability of reaching a given leaf y_{1:len} is Π_{j≤len} ν(y_j|x_j), and the leaf probabilities sum to 1 (induction on the depth: at each inner node the probabilities of the children sum to 1, because ν(·|x) is a probability on Y⊥). Hence, given (z, ρ), the conditional law of the answer sequence has the density L_ν with respect to counting measure on the leaves. Integrating over (z, ρ) ∼ D₀ ⊗ Λ gives the claim (Tonelli; all integrands are nonnegative). Γ is σ-finite because there are countably many answer sequences and D₀ ⊗ Λ is a probability. ∎

So all run laws Q_ν have densities with respect to one measure Γ, and **the density L_ν(τ) can be evaluated from the transcript of the run and the sampler alone, without knowing D₀ or Λ.**

**1.2 The human system and the data.** Q denotes the law of one run of the human system: *any* probability measure on (Ω, 𝔉). When the human is a stateless sampler P (assumption A1), Q = Q_P. Sections 2 and 3 do not need A1: the human may keep state inside a run, need not be computable, and need not be in any class. The only assumption on the data in Sections 2 and 3 is

 **(IID)** τ_1, …, τ_N are independent, each with law Q.

(IID) is an assumption about the human, although not about a single run: the same person must carry out N runs without memory of the earlier runs, without learning and without tiring, so that all runs have one law. A person who improves with practice gives runs that are not identically distributed; Q̂_N then estimates the average of N different laws. (Attack report, Finding m2.)

Q̂_N(E) := (1/N)·#{i ≤ N : τ_i ∈ E} is the empirical measure. TV(Q, Q′) := sup_{E∈𝔉} |Q(E) − Q′(E)|. Section 4 (the Bayes mixture) and Section 6 (validation) assume A1; each statement says what it assumes.

**1.3 Tests.** A *test family* is a countable family 𝓣 ⊆ 𝔉 with weights π(R) > 0, Σ_{R∈𝓣} π(R) ≤ 1, fixed before the data are seen. (It is an indexed family: the same event may occur twice with two weights.) For δ ∈ (0, 1):

 a_N(R) := ln(2/(π(R)·δ))/N,  tol_N(R) := √(a_N(R)/2) = √(ln(2/(π(R)δ))/(2N)) (the draft's tolerance).

For p, q ∈ [0, 1], kl(p‖q) := p·ln(p/q) + (1 − p)·ln((1 − p)/(1 − q)) is the divergence between Bernoulli laws (0·ln 0 = 0; the value is +∞ if q ∈ {0, 1} and p ≠ q). Note kl(1 − p‖1 − q) = kl(p‖q). When π(R) = 2^(−K(R)) with K(R) the length of a shortest program that decides R, the family consists of all decidable events and a_N(R) = (K(R)·ln 2 + ln(2/δ))/N; we call log₂(1/π(R)) the *price in bits* of R in every case. (The theorems of Section 2 are statements about probabilities and hold for this family. To *use* the family, for instance to find a member of the matching set of Corollary 2.6, one must decide for every test of a given price whether a recorded run lies in it. That needs a list of the programs that halt on every input, which no program produces, and K(R) itself is not computable; unlimited computation does not include a halting oracle. For use, take the programs of a language in which every program halts, for example programs with a time bound written into them, with the length in that language as the price. Attack report, Finding m6; see (C4) in Section 3.5.)

---

## 2. Pr1 and Pr3: matching the frequencies of tests

**Statement 2.0 (Pr1). PROVED** (it is the definition). TV(Q′, Q) ≤ ε holds iff |Q′(E) − Q(E)| ≤ ε for every event E ∈ 𝔉. So "every property of runs has probability within ε of its probability in the human system" is exactly TV(Q′, Q) ≤ ε, no more and no less; properties of probability below ε are not controlled by it.

**Lemma 2.1 (Chernoff bound in divergence form). PROVED.** Let S be binomial (N, q) and Q̂ = S/N. For x ∈ [q, 1]: Pr[Q̂ ≥ x] ≤ exp(−N·kl(x‖q)). For x ∈ [0, q]: Pr[Q̂ ≤ x] ≤ exp(−N·kl(x‖q)). Consequently, for every a > 0, Pr[kl(Q̂‖q) > a] ≤ 2e^{−Na}, and each of the events {Q̂ > q, kl(Q̂‖q) > a}, {Q̂ < q, kl(Q̂‖q) > a} has probability at most e^{−Na}.

*Proof.* Upper tail. If q ∈ {0, 1} or x = q the claim is trivial (the bound is 1, or Q̂ = q almost surely). Let 0 < q < x < 1 and λ := ln(x(1 − q)/(q(1 − x))) > 0. By Markov's inequality, Pr[S ≥ Nx] ≤ e^{−λNx}·E e^{λS} = (e^{−λx}(1 − q + qe^λ))^N, and e^{−λx}(1 − q + qe^λ) = (q(1 − x)/(x(1 − q)))^x·(1 − q)/(1 − x) = (q/x)^x((1 − q)/(1 − x))^{1−x} = e^{−kl(x‖q)}. For x = 1: Pr[S = N] = q^N = e^{−N·kl(1‖q)}. The lower tail follows by applying the upper tail to N − S, which is binomial (N, 1 − q), and kl(1 − x‖1 − q) = kl(x‖q).
For the consequence: if q ∈ {0, 1} then Q̂ = q almost surely and kl(Q̂‖q) = 0, so both events have probability 0. Let 0 < q < 1. Then u ↦ kl(u‖q) is continuous on [q, 1], zero at q and strictly increasing (its derivative ln(u(1 − q)/(q(1 − u))) is positive for u > q), with value ln(1/q) at 1. If a ≥ ln(1/q) the event {Q̂ > q, kl(Q̂‖q) > a} is empty. Otherwise let x_a ∈ (q, 1) be the point with kl(x_a‖q) = a; the event is {Q̂ > x_a} ⊆ {Q̂ ≥ x_a}, of probability at most e^{−Na}. The other side is symmetric. ∎

(This is Theorem 1 of W. Hoeffding, "Probability inequalities for sums of bounded random variables", *J. Amer. Statist. Assoc.* 58 (1963) 13–30, quoted from memory; the proof above is complete, so nothing rests on the citation.)

**Lemma 2.2 (three lower bounds on kl). PROVED.** For p, q ∈ [0, 1]:
(i) kl(p‖q) ≥ 2(p − q)² (Pinsker for Bernoulli laws);
(ii) kl(p‖q) ≥ (p − q)²/(2·max{p, q});
(iii) kl(0‖q) = ln(1/(1 − q)) ≥ q.

*Proof.* If q ∈ {0, 1} and p ≠ q the left sides are infinite; let 0 < q < 1. For fixed p, ∂/∂q kl(p‖q) = (q − p)/(q(1 − q)). (i) g(q) := kl(p‖q) − 2(p − q)² has g(p) = 0 and g′(q) = (q − p)(1/(q(1 − q)) − 4), which has the sign of q − p because q(1 − q) ≤ 1/4; so g ≥ 0. (ii) If p < q: kl(p‖q) = ∫_p^q (u − p)/(u(1 − u)) du ≥ ∫_p^q (u − p)/u du ≥ (1/q)∫_p^q (u − p) du = (q − p)²/(2q). If p > q: kl(p‖q) = ∫_q^p (p − u)/(u(1 − u)) du ≥ (1/p)∫_q^p (p − u) du = (p − q)²/(2p). (iii) is the definition and ln(1/(1 − q)) ≥ q. ∎

**Theorem 2.3 (Pr3, divergence form). PROVED.** Assume (IID); nothing else is assumed about Q. Let (𝓣, π) be a test family and δ ∈ (0, 1). With probability at least 1 − δ, simultaneously for all R ∈ 𝓣:

 kl(Q̂_N(R) ‖ Q(R)) ≤ a_N(R) = ln(2/(π(R)δ))/N.  (G)

*Proof.* For fixed R, N·Q̂_N(R) is binomial (N, Q(R)) by (IID). By Lemma 2.1 with a = a_N(R), the event that (G) fails for R has probability at most 2e^{−N·a_N(R)} = π(R)δ. Sum over the countably many R ∈ 𝓣. ∎

*What it is* (added by the editor; both reports ask for it). Theorem 2.3 is standard: a Chernoff bound in relative-entropy form with a union bound weighted by a prior over countably many events. In learning theory it is known as the Occam's razor bound: J. Langford, "Tutorial on practical prediction theory for classification", *J. Mach. Learn. Res.* 6 (2005) 273–306, where the events are "classifier c errs" and the conclusion is kl(empirical error ‖ true error) ≤ (ln(1/prior(c)) + ln(1/δ))/m; the one-sided bound for events that never occurred (Theorem 2.5(b) below) is the realisable form of A. Blumer, A. Ehrenfeucht, D. Haussler and M. K. Warmuth, "Occam's razor", *Inform. Process. Lett.* 24 (1987) 377–380. Both are quoted from memory by the two reports; neither paper was opened in this project (the attack report confirmed the bibliographic data of the first by a search). The proof above is complete, so nothing rests on these citations.

**Corollary 2.4 (readable forms). PROVED.** On the event (G), for every R ∈ 𝓣, writing a = a_N(R), q = Q(R), p̂ = Q̂_N(R):
(a) |p̂ − q| ≤ √(a/2) = tol_N(R) (Hoeffding form);
(b) |p̂ − q| ≤ √(2a·max{p̂, q}), hence p̂ − √(2a·p̂) ≤ q ≤ p̂ + √(2a·p̂) + 2a and √p̂ ≤ √q + √(2a) (relative, or Bernstein, form: for a rare event the error is of order √(aq) + a, not √a);
(c) if R never occurred (p̂ = 0): q ≤ 1 − e^{−a} ≤ a = ln(2/(π(R)δ))/N; if R always occurred: 1 − q ≤ a.
The same holds with R replaced by its complement (kl is symmetric under complementation), so in (b) max{p̂, q} may be replaced by max{1 − p̂, 1 − q}.

*Proof.* (a) Lemma 2.2(i). (b) Lemma 2.2(ii) gives (p̂ − q)² ≤ 2a·max{p̂, q}. If q > p̂: q − p̂ ≤ √(2aq), a quadratic inequality in √q whose solution is √q ≤ (√(2a) + √(2a + 4p̂))/2, that is q ≤ p̂ + a + √(a² + 2ap̂) ≤ p̂ + 2a + √(2ap̂). If q ≤ p̂: p̂ − q ≤ √(2ap̂) directly, and as a quadratic inequality in √p̂ it gives √p̂ ≤ (√(2a) + √(2a + 4q))/2 ≤ √(2a) + √q. (c) Lemma 2.2(iii), and the complement. ∎

**Theorem 2.5 (Pr3 as the draft states it). MODIFIED.** Assume (IID).
(a) With probability ≥ 1 − δ, for all R ∈ 𝓣: |Q̂_N(R) − Q(R)| ≤ tol_N(R). **PROVED** (Corollary 2.4(a)).
(b) With probability ≥ 1 − δ, every R ∈ 𝓣 that never occurred in the N runs has Q(R) ≤ ln(1/(π(R)δ))/N. **PROVED.**
(c) The draft claims (a) and (b) together with probability ≥ 1 − δ. This is **REFUTED** as stated; what holds is: (a) and (b) together with probability ≥ 1 − 3δ/2. **PROVED.** (Alternatively use (G), which contains (a) and a version of (b) with ln(2/(π(R)δ)) in place of ln(1/(π(R)δ)), at confidence 1 − δ.)

*Proof.* (b) Let q_R := ln(1/(π(R)δ))/N. If Q(R) > q_R then Pr[R never occurs] = (1 − Q(R))^N ≤ e^{−N·Q(R)} < π(R)δ. Sum over the R ∈ 𝓣 with Q(R) > q_R.
(c) Fix R and write q = Q(R), t = tol_N(R). The failure event for R is F_R = {Q̂ − q > t} ∪ {q − Q̂ > t} ∪ {Q̂ = 0, q > q_R}. The first event has probability ≤ e^{−2Nt²} = π(R)δ/2 (Lemmas 2.1, 2.2(i)). For the union of the other two: if q ≤ q_R it is {q − Q̂ > t}, of probability ≤ π(R)δ/2; if q > t it is again {q − Q̂ > t}, because Q̂ = 0 implies q − Q̂ > t; if q_R < q ≤ t it is {Q̂ = 0}, because q − Q̂ ≤ q ≤ t, and has probability < π(R)δ by (b). So Pr[F_R] ≤ (3/2)π(R)δ; sum over R.
*Counterexample to confidence 1 − δ.* N = 1, one test R with π(R) = 1, δ = 0.905, Q(R) = 0.2. Then tol_1(R) = √(ln(2/0.905)/2) = 0.6297… and ln(1/δ)/N = 0.0998…. If the single run is in R, then |Q̂ − Q| = 0.8 > tol and (a) fails. If it is not, R never occurred and Q(R) = 0.2 > 0.0998, so (b) fails. The joint statement fails with probability 1 > δ. ∎

*For which δ the draft's joint statement fails* (corrected after both reports; the prover had written "the example needs δ close to 1", which is not so). One test of weight 1, N = 4, δ = 0.332 and Q(R) just above ln(1/δ)/N = 0.27566: then tol_4(R) = 0.47378; the test never occurs with probability (1 − Q(R))⁴ = 0.2753, and then (b) fails; it occurs three or four times with probability 0.0665, and then |Q̂ − Q| ≥ 0.4743 > tol and (a) fails. The joint statement fails with probability 0.3417 > δ. At δ = 0.3315 three occurrences no longer exceed the tolerance and the failure probability is 0.2805 < δ. (The example with δ = 0.332 is the attack report's, Finding m1; the check report has δ = 0.34 with failure probability 0.3470; the editor recomputed both, `property-batch_editor.out`, block (E1).) On the grids of the two reports (every N ≤ 150 and multiples of 1/200 for π(R)δ; N ≤ 40 and steps of 0.0005 from 0.25) no failure was found for π(R)δ < 0.332, the set of values of π(R)δ with a failure is not an interval, and the largest ratio of the exact failure probability to π(R)δ found anywhere is 1.3441, below the proved 3/2. That the draft's joint statement holds for all π(R)δ below 0.33 is not proved. The note should state Pr3 in the form (G), which gives both halves at confidence 1 − δ.

**Corollary 2.6 (any test-matching imitator; the price of a property is its own complexity). PROVED.** Let 𝓜_N be the set of probability measures Q′ on (Ω, 𝔉) with kl(Q̂_N(R)‖Q′(R)) ≤ a_N(R) for all R ∈ 𝓣 ("Q′ matches the empirical frequencies of all tests"). On the event (G), which has probability ≥ 1 − δ:
(i) Q ∈ 𝓜_N; in particular, if the human system is the scaffold run with some answerer A (stateful or not), then 𝓜_N contains the run law Q_A of an answerer.
(ii) Every Q′ ∈ 𝓜_N satisfies, for every R ∈ 𝓣, with a = a_N(R) and q̄ := min{Q(R), 1 − Q(R)}:
 |Q′(R) − Q(R)| ≤ min{ √(2a) , 2√(2a·q̄) + 6a }.
(iii) If R ∈ 𝓣 never occurred in the data, every Q′ ∈ 𝓜_N has Q′(R) ≤ a, and Q(R) ≤ a.
With the draft's weaker matching condition |Q′(R) − Q̂_N(R)| ≤ tol_N(R), the conclusion is |Q′(R) − Q(R)| ≤ 2·tol_N(R) = √(2a), which is the draft's Pr3.

*Proof.* (i) is (G). (ii) By Corollary 2.4(a) applied to Q and to Q′ (the proof of 2.4 uses only the inequality kl(p̂‖·) ≤ a), both numbers are within √(a/2) of p̂. By 2.4(b) both lie in the interval [p̂ − √(2ap̂), p̂ + √(2ap̂) + 2a], of length 2√(2ap̂) + 2a, and √p̂ ≤ √(Q(R)) + √(2a), so the length is at most 2√(2a·Q(R)) + 6a. Apply the same to the complement of R. (iii) Corollary 2.4(c). The last sentence is the triangle inequality with Theorem 2.5(a). ∎

In the universal case (𝓣 = all decidable events, π(R) = 2^{−K(R)}): a = (K(R)·ln 2 + ln(2/δ))/N. A property R of complexity K(R) is preserved to within √(2a), and a property that the human system never violated in N runs is violated by a matching imitator with probability at most (K(R)·ln 2 + ln(2/δ))/N, whatever the complexity of the human.

*Attribution* (added by the editor; `research/outline.md`, Addendum 2, item 5, and both reports). That the price of a property is the complexity of the property, with nothing assumed about the source of the data, and that a model which passes all tests of a class need not be close to the source, are the central points of the work on outcome indistinguishability and multicalibration: C. Dwork, M. P. Kim, O. Reingold, G. N. Rothblum and G. Yona, "Outcome indistinguishability", arXiv:2011.13426v1 (2020; STOC 2021), and Ú. Hébert-Johnson, M. P. Kim, O. Reingold and G. N. Rothblum, "Multicalibration: calibration for the (computationally-identifiable) masses", ICML 2018. Read in the first paper by the editor in this session (the attack report read the same passages): the sample bound "applying Hoeffding's inequality, we can see that m_t ≥ Ω(log(|A|/δ)/ε²) labeled samples suffice to estimate Δ_A for each A ∈ A with probability at least 1 − δ" (Section 5.4, for one iteration of their learning algorithm), and the caveat "OI does not guarantee statistical closeness to Nature (it need not be the case that p* ≈ p̃). Thus, the feasibility results demonstrate the ability to learn an incorrect model that cannot be detected by efficient inspection" (Section 1.2, Discussion). The second paper was not opened; it is cited as `research/sections/related-work.md` cites it. Corollary 2.6 and Proposition 3.9 are this statement for events of runs and weighted tests.

**Remarks 2.7 (which hypotheses are needed).**
1. *Nothing about the human system is used except (IID).* Statefulness inside a run, non-computability and the absence of any class are all allowed. (IID) itself is an assumption about the human across runs: see Section 1.2.
2. *Independence is needed.* If the N recorded runs are one run copied N times, then Q̂_N(R) ∈ {0, 1}, and for a test with Q(R) = 1/2 the error is 1/2 for every N. (For runs that form a martingale-difference sequence, for instance top-level inputs chosen adaptively, Theorem 2.5(a) survives with Azuma's inequality in place of Lemma 2.1; not needed here and not proved here.)
3. *The tests must be fixed before the data, and an infinite family needs weights.* Let Q be non-atomic (for example ρ uniform on [0, 1]) and let 𝓣′ be the family of all finite sets of runs, which is uncountable. The data-dependent test R = {τ_1, …, τ_N} has Q̂_N(R) = 1 and Q(R) = 0. So no bound holds uniformly over 𝓣′ and none holds for tests chosen after the data.
4. *The price ln(1/π(R)) cannot be removed in general.* For M tests that are independent events of probability 1/2 under Q, the largest of the M deviations |Q̂_N(R) − 1/2| is of order √(ln M/N) for ln M ≤ N (the maximum of M independent binomial deviations). The prover quoted this standard fact without proof and wrote that it is not used; Section 5.1 uses it. Lemma 2.8 below proves the half that is used.
5. *Measurability is all the theorem asks of a test.* Whether tests must be decidable is a question about computing the estimator; see Section 3.5.
6. *The matching set contains things that are not imitations* (added by the editor from the attack report: Section 2, "referent", and Proposition X4). (i) Let the closed system have a fixed top-level input and no randomness of its own, so that a run is determined by its answers. The answerer "choose one of the N recorded runs at random and give its answers in order" has the run law Q̂_N. It lies in 𝓜_N, it minimises the discrepancy d_N of Proposition 3.9 with value 0, and Corollary 2.6 is true of it; it is a replay of N human runs. What excludes it lies outside Corollary 2.6: a top-level input whose law has no atoms together with tests that tie the answers to the input, or a penalty on the description length of the imitator, as in Section 3.3 (Example 3.11(b)). (ii) When the human is a typical function, the matching set contains the coin: Proposition 5.4.
7. *Matching the frequencies is not the same as enforcing a property* (added by the editor from the attack report, Section 2, "rock"). For one decidable property that the human never violates, an imitator with unlimited computation can be conditioned on the property (the map ν ↦ ν^R of Definition 4.1), which keeps it with certainty at every input, with no data and no theorem. What Corollary 2.6 adds to such a filter is the list: all tests of price at most k bits that never occurred in N runs occur again with probability at most (k·ln 2 + ln(2/δ))/N each, without anyone having named them, and the tests that occur sometimes keep their rates on both sides.

**Lemma 2.8 (the price of a test cannot be removed). PROVED** (added by the editor; the proof is the sketch of the check report, entry for Remarks 2.7, completed; checked numerically in `property-batch_editor.out`, block (E2)). Assume (IID). Let R_1, …, R_M be events of runs that are independent under Q and have Q(R_j) = 1/2, and let (N + 1)² ≤ M ≤ e^N. Put

 t* := ½·√(ln(M/(N + 1)²)/N) − 1/N.

Then with probability at least 1 − e^(−(N+1)) some j ≤ M has Q̂_N(R_j) − 1/2 ≥ t*. If M ≥ (N + 1)³, then t* ≥ ½·√(ln M/(3N)) − 1/N.

*Proof.* The N·M indicators 1[τ_i ∈ R_j] are independent fair bits, so the numbers S_j := N·Q̂_N(R_j), j ≤ M, are independent and binomial (N, 1/2). If t* < 0: Pr[S_j ≥ N/2] ≥ 1/2 by symmetry, so the probability that no j has Q̂_N(R_j) ≥ 1/2 is at most 2^(−M) ≤ e^(−(N+1)), because M ≥ (N + 1)² ≥ (N + 1)/ln 2. Let t* ≥ 0 and let k be the least integer with k ≥ N·(1/2 + t*). Then k/N = 1/2 + t′ with t* ≤ t′ < t* + 1/N ≤ 1/2; the last inequality is ln(M/(N + 1)²) ≤ N. For every integer 0 ≤ k ≤ N the binomial (N, k/N) law has a mode at k, so its largest point probability C(N, k)·(k/N)^k·(1 − k/N)^(N−k) = C(N, k)·e^(−N·h(k/N)) is at least 1/(N + 1); here h is the entropy function in nats. Since kl(x‖1/2) = ln 2 − h(x), this gives Pr[S_j = k] = C(N, k)·2^(−N) ≥ e^(−N·kl(k/N‖1/2))/(N + 1). Further, for 0 ≤ t ≤ 1/2, kl(1/2 + t‖1/2) = (1/2 + t)·ln(1 + 2t) + (1/2 − t)·ln(1 − 2t) ≤ (1/2 + t)·2t − (1/2 − t)·2t = 4t² (with 0·ln 0 = 0 at t = 1/2), and t′ < t* + 1/N. Hence

 p := Pr[Q̂_N(R_j) − 1/2 ≥ t*] ≥ Pr[S_j = k] ≥ e^(−4N·(t* + 1/N)²)/(N + 1) = (N + 1)/M,

because 4N·(t* + 1/N)² = ln(M/(N + 1)²). By independence the probability that no j deviates by t* is (1 − p)^M ≤ e^(−Mp) ≤ e^(−(N+1)). Finally, M ≥ (N + 1)³ gives (N + 1)² ≤ M^(2/3) and ln(M/(N + 1)²) ≥ (1/3)·ln M. ∎

*Reading.* Give M such tests the equal weights 1/M. Theorem 2.5(a) allows each a deviation of tol_N = √(ln(2M/δ)/(2N)), and by the lemma no tolerance below ½·√(ln M/(3N)) − 1/N holds for all M tests with probability above e^(−(N+1)). So the term ln(1/π(R)) in the tolerance is needed up to a constant factor (√6 in the tolerance). The lemma does not show that the constants of Theorem 2.3 are the best possible.

---

## 3. Pr4: the batch estimator (minimum distance with weighted Yatracos sets)

In this section (H, w) is a countable index set with weights as in Section 1, and each ν ∈ H names a probability measure Q_ν on (Ω, 𝔉) with a density L_ν with respect to Γ. For samplers this is Lemma 1.1. Nothing else about samplers is used, so every statement of this section also holds for a countable family of answerers. Q is the law of a run of the human system and the data satisfy (IID).

### 3.1 Yatracos sets

**Definition 3.1.** For ν ≠ ν′ in H,

 A_νν′ := {τ ∈ Ω : L_ν(τ) > L_ν′(τ)},

the set of runs to which ν gives a larger likelihood than ν′ does. For N ≥ 1 and a constant κ ≥ 0, which the user chooses (Theorem 3.6 says how),

 r_N(ν) := √((K(ν)·ln 2 + κ)/(2N)).

With κ = ln(2/δ) this is r_N(ν) = √(ln(2/(w(ν)δ))/(2N)), the tolerance tol_N of a test of weight w(ν).

**Lemma 3.2. PROVED** (standard).
(a) (Scheffé's identity.) For ν ≠ ν′: TV(Q_ν, Q_ν′) = Q_ν(A_νν′) − Q_ν′(A_νν′).
(b) Under (IID), for every E ∈ 𝔉 and t > 0: Pr[Q̂_N(E) − Q(E) > t] ≤ e^(−2Nt²) and Pr[Q(E) − Q̂_N(E) > t] ≤ e^(−2Nt²).
(c) Let δ ∈ (0, 1) and s := √((ln(2/δ) − κ)⁺/(2N)), where x⁺ := max{x, 0}. If t ≥ r_N(ν) + s, then e^(−2Nt²) ≤ w(ν)·δ/2.

*Proof.* (a) For E ∈ 𝔉, Q_ν(E) − Q_ν′(E) = ∫_E (L_ν − L_ν′) dΓ. The integrand is positive on A_νν′ and at most 0 outside it, so the integral is largest for E = A_νν′. And TV(Q_ν, Q_ν′) = sup_E |Q_ν(E) − Q_ν′(E)| = sup_E (Q_ν(E) − Q_ν′(E)), because E may be replaced by its complement. (b) N·Q̂_N(E) is binomial (N, Q(E)). If Q̂_N(E) − Q(E) > t, then Q̂_N(E) > Q(E) and kl(Q̂_N(E)‖Q(E)) ≥ 2(Q̂_N(E) − Q(E))² > 2t² by Lemma 2.2(i); by Lemma 2.1 with a = 2t² this event has probability at most e^(−2Nt²). The other side is the same. (c) t² ≥ r_N(ν)² + s² = (K(ν) ln 2 + κ + (ln(2/δ) − κ)⁺)/(2N) ≥ (K(ν) ln 2 + ln(2/δ))/(2N), so e^(−2Nt²) ≤ 2^(−K(ν))·δ/2. ∎

### 3.2 The human system in the class: the highest-weight sampler that matches all tests

**Theorem 3.3 (Pr4, first half, as the draft states it). PROVED; MODIFIED in one constant when the Yatracos sets are added to a family that already has weight 1.** Let (𝓣, π) be a test family, possibly empty. Let 𝓣* consist of the tests of 𝓣 and of the sets A_νν′ for all ordered pairs ν ≠ ν′ in H, with the weights π*(R) := π(R)/2 for R ∈ 𝓣 and π*(A_νν′) := w(ν)·w(ν′)/2. (If 𝓣 is empty, put π*(A_νν′) := w(ν)·w(ν′).) For δ ∈ (0, 1) let tol*_N(R) := √(ln(2/(π*(R)δ))/(2N)). Say that ν ∈ H *matches* if |Q_ν(R) − Q̂_N(R)| ≤ tol*_N(R) for every R ∈ 𝓣*, and let ν̂ be a matching index of the largest weight, if some index matches.

Assume (IID) and that the human system is in the class: Q = Q_ν₀ for some ν₀ ∈ H. Put K := K(ν₀). Then with probability at least 1 − δ:

(i) ν₀ matches; hence ν̂ exists, and w(ν̂) ≥ w(ν₀);
(ii) TV(Q_ν̂, Q) ≤ 2·tol*_N(A_ν̂ν₀) ≤ √((4K ln 2 + 2 ln(4/δ))/N); if 𝓣 is empty, TV(Q_ν̂, Q) ≤ √((4K ln 2 + 2 ln(2/δ))/N), which is the bound of the draft;
(iii) |Q_ν̂(R) − Q(R)| ≤ 2·tol*_N(R) = √(2 ln(4/(π(R)δ))/N) for every R ∈ 𝓣.

Statement (iii) holds, on the same event, for every matching index, also when the human system is not in the class.

*Proof.* Σ_{ν≠ν′} w(ν)w(ν′) ≤ (Σ_ν w(ν))² ≤ 1, so (𝓣*, π*) is a test family, and by Theorem 2.5(a) there is an event G* of probability at least 1 − δ on which |Q̂_N(R) − Q(R)| ≤ tol*_N(R) for all R ∈ 𝓣*. Work on G*. (i) Q_ν₀ = Q, so ν₀ matches. At most 1/w(ν₀) indices have weight at least w(ν₀), so among the matching indices there is one of largest weight, and its weight is at least w(ν₀). (ii) If ν̂ = ν₀ there is nothing to prove. Otherwise let A := A_ν̂ν₀. By Lemma 3.2(a), TV(Q_ν̂, Q) = Q_ν̂(A) − Q(A) ≤ |Q_ν̂(A) − Q̂_N(A)| + |Q̂_N(A) − Q(A)| ≤ 2·tol*_N(A), and π*(A) = w(ν̂)w(ν₀)/2 ≥ w(ν₀)²/2 = 2^(−2K)/2. (iii) is the triangle inequality. ∎

*What it says.* Both prices are paid by one estimate: (ii) is closeness for all events at the price K, and (iii) is closeness for each test of the family at the price of the test. When N is too small for (ii) to say anything (N below about K), (iii) still holds, and ν̂ is then some sampler of weight at least w(ν₀) that agrees with the human system on every test R up to 2·tol*_N(R).

*What it does not say.* Nothing when the human system is outside the class: then it can happen that no index matches (Example 3.11(c)), and the estimate is not defined. Subsection 3.3 gives an estimator that is always defined, proves the oracle inequality for it, and lowers 4K to 2K.

### 3.3 The human system outside the class: penalised minimum distance

**Definition 3.4 (the estimator).** Fix N ≥ 1 and κ ≥ 0. For ν ≠ ν′ in H put

 U_N(ν, ν′) := Q_ν(A_νν′) − Q̂_N(A_νν′),
 Δ_N(ν) := sup_{ν′ ∈ H, ν′ ≠ ν} (U_N(ν, ν′) − r_N(ν′))⁺ (and Δ_N(ν) := 0 if H = {ν}),
 c_N(ν) := Δ_N(ν) + r_N(ν).

For ε ≥ 0, an *ε-minimiser* is an index ν̂ with c_N(ν̂) ≤ inf_ν c_N(ν) + ε.

In words: U_N(ν, ν′) is the amount by which ν produces the runs of A_νν′ more often than the data show them. The index ν is charged r_N(ν) for its own description length, and it is charged the largest excess of U_N(ν, ν′) over the tolerance r_N(ν′) of the competitor. Only the sets A_νν′ in which ν itself takes part enter Δ_N(ν), and each enters on one side only.

**Lemma 3.5 (finitely many numbers decide). PROVED.** (a) 0 ≤ Δ_N(ν) ≤ 1. (b) In the supremum that defines Δ_N(ν), the indices ν′ with r_N(ν′) ≥ 1, that is with w(ν′) ≤ e^(κ−2N), contribute 0; fewer than e^(2N−κ) indices remain. (c) For every b the set {ν : r_N(ν) ≤ b} is finite. Consequently inf_ν c_N(ν) is attained, the set of ε-minimisers is finite for every ε, and every ε-minimiser ν̂ satisfies r_N(ν̂) ≤ 1 + r_N(ν₁) + ε, where ν₁ is an index of largest weight.

*Proof.* (a) U_N ≤ 1. (b) U_N(ν, ν′) − r_N(ν′) ≤ 1 − r_N(ν′) ≤ 0; and Σ w ≤ 1. (c) r_N(ν) ≤ b iff w(ν) ≥ e^(κ−2Nb²), and at most e^(2Nb²−κ) indices have this property. Since r_N(ν) ≤ c_N(ν) and c_N(ν₁) ≤ 1 + r_N(ν₁), the infimum of c_N is its minimum over the finite, non-empty set {ν : r_N(ν) ≤ 1 + r_N(ν₁)}. ∎

**Theorem 3.6 (oracle inequality; Pr4, second half). PROVED** (the draft announced it as "to be proved"; the estimator is that of Definition 3.4). Assume (IID); Q may be any probability measure on (Ω, 𝔉). Let κ ≥ 0, ε ≥ 0, δ ∈ (0, 1) and s := √((ln(2/δ) − κ)⁺/(2N)). There is an event of probability at least 1 − δ on which every ε-minimiser ν̂ of c_N satisfies

 TV(Q_ν̂, Q) ≤ 3·TV(Q_ν, Q) + 2·r_N(ν) + 2s + ε for every ν ∈ H.  (O)

Two choices of κ:

1. κ = ln(2/δ). Then s = 0 and (O) reads TV(Q_ν̂, Q) ≤ 3·TV(Q_ν, Q) + √((2K(ν) ln 2 + 2 ln(2/δ))/N) + ε.
2. κ = 0. Then the estimator does not depend on δ, and for every δ ∈ (0, 1), with probability at least 1 − δ, TV(Q_ν̂, Q) ≤ 3·TV(Q_ν, Q) + √(2K(ν) ln 2/N) + √(2 ln(2/δ)/N) + ε for every ν ∈ H.

*Proof.* Put g(ν) := 3·TV(Q_ν, Q) + 2r_N(ν). Since g(ν) ≥ 2r_N(ν), Lemma 3.5(c) shows that g attains its minimum at some ν* ∈ H. The index ν* does not depend on the data. The right side of (O) is at least g(ν*) + 2s + ε for every ν, so it suffices to prove (O) for ν = ν*.

Put t(ν′) := r_N(ν′) + s and consider the events

 E₁: Q(A_ν*ν′) − Q̂_N(A_ν*ν′) ≤ t(ν′) for all ν′ ≠ ν*,
 E₂: Q̂_N(A_ν′ν*) − Q(A_ν′ν*) ≤ t(ν′) for all ν′ ≠ ν*.

By Lemma 3.2(b) and (c), each single inequality fails with probability at most w(ν′)δ/2. So E₁ fails with probability at most (δ/2)·Σ_{ν′≠ν*} w(ν′) ≤ δ/2, and so does E₂. We work on E₁ ∩ E₂ and write TV* := TV(Q_ν*, Q).

*Step 1: c_N(ν*) is small.* For ν′ ≠ ν*, with A = A_ν*ν′,

 U_N(ν*, ν′) = [Q_ν*(A) − Q(A)] + [Q(A) − Q̂_N(A)] ≤ TV* + r_N(ν′) + s

by E₁. Hence Δ_N(ν*) ≤ TV* + s and c_N(ν*) ≤ TV* + s + r_N(ν*).

*Step 2: ν̂ is close to ν*.* Let ν̂ be an ε-minimiser. If ν̂ = ν*, (O) holds. Otherwise let A := A_ν̂ν*. By Lemma 3.2(a),

 TV(Q_ν̂, Q_ν*) = Q_ν̂(A) − Q_ν*(A) = U_N(ν̂, ν*) + [Q̂_N(A) − Q(A)] + [Q(A) − Q_ν*(A)].

The first term is at most Δ_N(ν̂) + r_N(ν*), by the definition of Δ_N(ν̂) (ν* is one of the indices ν′ in the supremum). The second is at most r_N(ν̂) + s by E₂ with ν′ = ν̂. The third is at most TV*. So

 TV(Q_ν̂, Q_ν*) ≤ c_N(ν̂) + r_N(ν*) + s + TV* ≤ c_N(ν*) + ε + r_N(ν*) + s + TV* ≤ 2·TV* + 2r_N(ν*) + 2s + ε,

where the second inequality is the choice of ν̂ and the third is Step 1.

*Step 3.* TV(Q_ν̂, Q) ≤ TV(Q_ν̂, Q_ν*) + TV*. ∎

*Remark on the union bound.* The proof needs the deviation of Q̂_N from Q only on the sets A_ν*ν′ and A_ν′ν* around the one fixed index ν*. The failure probabilities therefore add up to a sum of single weights w(ν′), not of products w(ν)w(ν′); this is why the constant is 2K and not 4K. The inequality nevertheless holds for all ν at once, because it holds for the ν that minimises its right-hand side. For a finite class without weights, the observation that only the sets around the best member matter is Remark 5 of Mahalanabis and Štefankovič (2008); see 3.6.

**Corollary 3.7. PROVED.** In the setting of Theorem 3.6:

(a) *In the class.* If Q = Q_ν₀, K := K(ν₀), κ = ln(2/δ) and ν̂ is a minimiser of c_N, then with probability at least 1 − δ: TV(Q_ν̂, Q) ≤ 2r_N(ν₀) = √((2K ln 2 + 2 ln(2/δ))/N).
(b) *Every event.* On the event of Theorem 3.6, |Q_ν̂(E) − Q(E)| ≤ min_ν [3·TV(Q_ν, Q) + 2r_N(ν)] + 2s + ε for all E ∈ 𝔉 simultaneously.
(c) *In expectation.* Let κ = 0 and let ν̂ be the first minimiser of c_N in a fixed enumeration of H. Then E[TV(Q_ν̂, Q)] ≤ min_ν [3·TV(Q_ν, Q) + √(2K(ν) ln 2/N)] + √(2π/N).
(d) *Sample size.* For TV(Q_ν̂, Q) ≤ 3·TV(Q_ν, Q) + η with probability at least 1 − δ it suffices that N ≥ (2K(ν) ln 2 + 2 ln(2/δ))/η².

*Proof.* (a) Take ν = ν₀ in (O). (b) is Statement 2.0. (c) Each c_N(ν) is a measurable function of the data (a countable supremum of measurable functions), so the first minimiser is a measurable choice. Let g₀ := min_ν [3·TV(Q_ν, Q) + √(2K(ν) ln 2/N)] and X := (TV(Q_ν̂, Q) − g₀)⁺. By choice 2 of the theorem with ε = 0, Pr[X > √(2 ln(2/δ)/N)] ≤ δ for every δ ∈ (0, 1); that is, Pr[X > t] ≤ 2e^(−Nt²/2) for every t > √(2 ln 2/N), and for smaller t the right side exceeds 1. Hence E X = ∫₀^∞ Pr[X > t] dt ≤ ∫₀^∞ 2e^(−Nt²/2) dt = √(2π/N). (d) Choice 1. ∎

*What Theorem 3.6 does not say.* (1) The factor 3 is not 1: the estimate may be three times as far from the human system as the best index of the class, and for this estimator the factor is attained (Example 3.11(a)). (2) The rate is √(K/N), not K/N, also when the human system is in the class. (3) The approximation term TV(Q_ν, Q) is a distance between laws of whole runs. If the human keeps state within a run, it is the distance to the best stateless imitation of the run, which may be large. It is large in the simplest case (attack report, Finding m3; recomputed by the editor, `property-batch_editor.out`, block (E3)): let the scaffold put the same question twice and let the human answer a fair bit and repeat it, so that the run is (0, 0) or (1, 1) with probability 1/2 each. A stateless sampler that answers 1 with probability p has the run law (p², p(1 − p), (1 − p)p, (1 − p)²), whose total variation from the human system is 2p(1 − p) for 1 − 1/√2 ≤ p ≤ 1/√2 and ½·(4p − 1 − 2p²) for p ≥ 1/√2 (symmetrically for p ≤ 1 − 1/√2); the least value, taken at p = 1/√2 and at p = 1 − 1/√2, is √2 − 1 = 0.4142. The right side of (O) is then at least 3·0.4142 > 1 for every class of samplers: the inequality says nothing. With the factor 3, (O) says something only if some member of the class is within 1/3 of the human system. So the sentence of the candidate theory "robust when the human is not a stateless sampler" must not be carried over; what is true is that this section holds for a countable class of answerers (first paragraph of Section 3), and that for a class of samplers the statelessness of the human enters through the approximation term. (4) N runs of the human system are up to N·L answers of the human, given in whole runs by a human who is the same in every run. (5) Whether the factor 3 is the best possible in the bound in expectation, Corollary 3.7(c), is not known to us: see the end of Example 3.11(a).

**Proposition 3.8 (the highest-weight sampler that passes one-sided tests; both prices, constant 2K). ADDED, PROVED.** Let (𝓣, π) be a test family, possibly empty, and δ ∈ (0, 1). Put δ′ := δ/2 if 𝓣 is not empty, and δ′ := δ if 𝓣 is empty. Let r_N be as in Definition 3.1 with κ = ln(2/δ′), and tol′_N(R) := √(ln(2/(π(R)δ′))/(2N)). Call ν ∈ H *admissible* if

 (1) U_N(ν, ν′) ≤ max{r_N(ν), r_N(ν′)} for every ν′ ≠ ν, and
 (2) |Q_ν(R) − Q̂_N(R)| ≤ tol′_N(R) for every R ∈ 𝓣,

and let ν̂ be an admissible index of the largest weight, if there is an admissible index. Assume (IID) and Q = Q_ν₀, K := K(ν₀). Then with probability at least 1 − δ: ν₀ is admissible, w(ν̂) ≥ w(ν₀),

 TV(Q_ν̂, Q) ≤ 2r_N(ν₀) = √((2K ln 2 + 2 ln(2/δ′))/N), and |Q_ν̂(R) − Q(R)| ≤ 2·tol′_N(R) for every R ∈ 𝓣.

*Proof.* Let G′ be the event of Theorem 2.5(a) for (𝓣, π) at level δ′ (if 𝓣 is empty, G′ is the sure event). Let E₁ be the event that Q(A_ν₀ν′) − Q̂_N(A_ν₀ν′) ≤ max{r_N(ν₀), r_N(ν′)} for all ν′ ≠ ν₀. By Lemma 3.2(b), and because e^(−2N·r_N(ν)²) = w(ν)δ′/2, the inequality for ν′ fails with probability at most min{w(ν₀), w(ν′)}·δ′/2 ≤ w(ν′)δ′/2; so E₁ fails with probability at most δ′/2. Let E₂ be the event that Q̂_N(A_νν₀) − Q(A_νν₀) ≤ r_N(ν₀) for all ν ≠ ν₀ with w(ν) ≥ w(ν₀). Each of these inequalities fails with probability at most w(ν₀)δ′/2 ≤ w(ν)δ′/2, so E₂ fails with probability at most δ′/2. Together G′ ∩ E₁ ∩ E₂ fails with probability at most 2δ′ = δ if 𝓣 is not empty, and at most δ′ = δ if 𝓣 is empty.

On this event ν₀ is admissible: (1) is E₁, because U_N(ν₀, ν′) = Q(A_ν₀ν′) − Q̂_N(A_ν₀ν′), and (2) is G′. As in Theorem 3.3, an admissible index ν̂ of largest weight exists and w(ν̂) ≥ w(ν₀), so r_N(ν̂) ≤ r_N(ν₀). If ν̂ ≠ ν₀, let A := A_ν̂ν₀; then TV(Q_ν̂, Q) = U_N(ν̂, ν₀) + [Q̂_N(A) − Q(A)] ≤ max{r_N(ν̂), r_N(ν₀)} + r_N(ν₀) = 2r_N(ν₀), by (1) for ν̂ and by E₂. The statement about tests is the triangle inequality. ∎

Proposition 3.8 is Theorem 3.3 with a better constant (2K in place of 4K) and with fewer conditions to check: for each index only the sets A_νν′ in which it takes part, each on one side. It keeps what Corollary 3.7(a) does not give: every test of 𝓣 is matched at its own price, whatever K is. Like Theorem 3.3 it is a statement for a human system in the class.

### 3.4 Tests only: the price of a test needs no class

**Proposition 3.9 (least weighted test discrepancy over any set of candidates). ADDED, PROVED.** Let 𝒞 be any set of probability measures on (Ω, 𝔉), for example the run laws of all samplers or of all answerers; 𝒞 need not be countable and carries no weights. Let (𝓣, π) be a test family, δ ∈ (0, 1), and for Q′ ∈ 𝒞

 d_N(Q′) := sup_{R ∈ 𝓣} (|Q′(R) − Q̂_N(R)| − tol_N(R))⁺.

Assume (IID). On the event of Theorem 2.5(a), which has probability at least 1 − δ, every Q′ ∈ 𝒞 with d_N(Q′) ≤ inf_𝒞 d_N + ε satisfies, for every R ∈ 𝓣,

 |Q′(R) − Q(R)| ≤ 2·tol_N(R) + inf_{Q″ ∈ 𝒞} sup_{R′ ∈ 𝓣} |Q″(R′) − Q(R′)| + ε.

If Q ∈ 𝒞 (for example: 𝒞 is the set of run laws of all answerers and the human system is the scaffold run with some answerer), the middle term is 0.

*Proof.* On the event, for Q″ ∈ 𝒞 and R′ ∈ 𝓣: |Q″(R′) − Q̂_N(R′)| − tol_N(R′) ≤ |Q″(R′) − Q(R′)|. So d_N(Q″) ≤ sup_{R′} |Q″(R′) − Q(R′)|, hence d_N(Q′) ≤ inf_{Q″} sup_{R′} |Q″(R′) − Q(R′)| + ε. And |Q′(R) − Q(R)| ≤ |Q′(R) − Q̂_N(R)| + tol_N(R) ≤ d_N(Q′) + 2·tol_N(R). ∎

This is Corollary 2.6 without the assumption that a matching candidate exists. The complexity of the candidates does not enter, because the deviation bound concerns the tests and not the candidates. What is lost is in the middle term and in the conclusion: both see the candidates only through the tests of 𝓣 (Section 5).

### 3.5 What must be computable for the estimators to be defined

As mathematical objects the estimators of this section are defined for every countable class with weights. To compute the estimate of Definition 3.4 one needs (C1) to (C3) below, and nothing else; the estimators that also use a test family need (C4) in addition.

**(C1) A finite list of candidates.** By Lemma 3.5 the set of ε-minimisers is determined by the indices of weight at least e^(κ−2N(1+r_N(ν₁)+ε)²): an index of smaller weight cannot be an ε-minimiser, and a competitor ν′ of weight at most e^(κ−2N) contributes nothing to any Δ_N(ν). One must be able to list the indices of weight above a given threshold. This is possible when w(ν) = 2^(−ℓ(ν)) for the lengths ℓ of programs in a prefix-free language. It is not possible when the weight is defined through the length of the *shortest* program for the kernel, which is not computable. The list is finite and not short: up to e^(2N(1+r_N(ν₁)+ε)²−κ) candidates, each compared with up to e^(2N−κ) competitors. For N = 3835 runs (the number at which a property of 50 bits that never failed is certified to hold with frequency 0.99 at δ = 0.05) that is of the order of e^7670 indices. The researcher allows unlimited computation, so this is not a defect of the statement; it is said here once (both reports ask for it).

**(C2) For every recorded run τ_i and every pair of candidates: is L_ν(τ_i) > L_ν′(τ_i)?** By Lemma 1.1 both sides are products of at most L numbers ν(y_j|x_j) that are read off the transcript; D₀ and Λ are not needed, and neither is ρ if the transcript lists the inputs. The comparison must be decided exactly. This is possible when the probabilities ν(y|x) are rational numbers computable from (ν, x, y), for example for programs with a time bound. For lower semicomputable semimeasures (the class of all programs) L_ν(τ) is only a limit from below, and in general neither "L_ν(τ) > L_ν′(τ)" nor its negation can be confirmed by a finite computation; the estimate is then defined but not computable. Ties are harmless: Lemma 3.2(a) and all proofs hold for any measurable set A with {L_ν > L_ν′} ⊆ A ⊆ {L_ν ≥ L_ν′} in place of A_νν′.

**(C3) The numbers Q_ν(A_νν′).** This is the probability that a run of the scaffold answered by ν lies in A_νν′: a property of the scaffold and of two hypotheses, in which the human does not occur. It needs the laws D₀ and Λ of the scaffold, that is, a closed system. If (z, ρ) takes finitely many values with known rational probabilities and Y is finite, it is a finite sum over the tree of runs. In general it can be replaced by a simulation:

**Theorem 3.10 (the estimator with simulated runs). ADDED, PROVED.** Let N_s ≥ 1. For each ν ∈ H let Q̃_ν be the empirical measure of N_s independent runs with law Q_ν (simulations of the scaffold with ν answering). Only this is used: the simulations of different indices may depend on each other, for example through a shared (z, ρ). Fix κ ≥ 0, put r̃(ν) := r_N(ν) + r_{N_s}(ν), and define Ũ(ν, ν′) := Q̃_ν(A_νν′) − Q̂_N(A_νν′), Δ̃(ν) := sup_{ν′≠ν} (Ũ(ν, ν′) − r̃(ν′))⁺ and c̃(ν) := Δ̃(ν) + r̃(ν). Assume (IID). Let δ ∈ (0, 1), s := √((ln(2/δ) − κ)⁺/(2N)) and s̃ := √((ln(2/δ) − κ)⁺/(2N_s)). There is an event of probability at least 1 − 2δ on which every ε-minimiser ν̂ of c̃ satisfies

 TV(Q_ν̂, Q) ≤ 3·TV(Q_ν, Q) + 2r_N(ν) + 2r_{N_s}(ν) + 2s + 2s̃ + ε for every ν ∈ H.

*Proof.* Let ν* minimise 3·TV(Q_ν, Q) + 2r̃(ν); it suffices to prove the inequality for ν = ν*. Let E₁, E₂ be as in the proof of Theorem 3.6, and

 E₃: Q̃_ν*(A_ν*ν′) − Q_ν*(A_ν*ν′) ≤ r_{N_s}(ν′) + s̃ for all ν′ ≠ ν*,
 E₄: Q_ν′(A_ν′ν*) − Q̃_ν′(A_ν′ν*) ≤ r_{N_s}(ν′) + s̃ for all ν′ ≠ ν*.

By Lemma 3.2(b), (c), applied to the N_s simulated runs of ν* (for E₃) and of ν′ (for E₄), each single inequality fails with probability at most w(ν′)δ/2; no independence between different ν′ is used. So all four events hold with probability at least 1 − 2δ. On them, with TV* := TV(Q_ν*, Q): Ũ(ν*, ν′) = [Q̃_ν*(A) − Q_ν*(A)] + U_N(ν*, ν′) ≤ TV* + r̃(ν′) + s + s̃, so c̃(ν*) ≤ TV* + s + s̃ + r̃(ν*). For an ε-minimiser ν̂ ≠ ν* and A := A_ν̂ν*: U_N(ν̂, ν*) = Ũ(ν̂, ν*) + [Q_ν̂(A) − Q̃_ν̂(A)] ≤ Δ̃(ν̂) + r̃(ν*) + r_{N_s}(ν̂) + s̃ by E₄, and Q̂_N(A) − Q(A) ≤ r_N(ν̂) + s by E₂. As in Step 2 of Theorem 3.6, TV(Q_ν̂, Q_ν*) ≤ c̃(ν̂) + r̃(ν*) + s + s̃ + TV* ≤ 2·TV* + 2r̃(ν*) + 2s + 2s̃ + ε. ∎

So with a closed system the following suffice: the transcripts of N runs of the human system; the ability to run the scaffold with a hypothesis in place of the human; and exact comparison of likelihoods on these runs. N_s costs computation only, and for N_s → ∞ the bound becomes that of Theorem 3.6, at confidence 1 − 2δ in place of 1 − δ.

**(C4) The tests of a family 𝓣** (Theorem 3.3, Propositions 3.8 and 3.9). A test with tol_N(R) ≥ 1, that is with π(R) ≤ (2/δ)·e^(−2N), imposes no condition, so fewer than (δ/2)·e^(2N) tests matter (fewer than (δ/4)·e^(2N) for the tolerances tol* of Theorem 3.3 and tol′ of Proposition 3.8, which carry a further factor 2). For each of them one must decide whether a recorded run lies in R, so R must be decidable from what is recorded of a run; and one needs the numbers Q_ν(R), exactly or by simulation as in (C3). The tests that matter must also be *listed*. For the universal family of Section 1.3 (all decidable events, with the length of a shortest decider as the price) that is impossible, because the programs that halt on every input cannot be listed; the family must come from a language in which every program halts, for example programs with a time bound written into them (attack report, Finding m6). This is the only place where decidability of the tests enters; the theorems of Section 2 ask for measurability only (Remark 2.7(5)).

**What need not be known or computed:** the law Q of the human system; the densities of D₀ and Λ; any prior belief about the human. The weights w act as penalties, not as beliefs: the theorems hold for every human system and every choice of w, and w(ν) enters the bound only through the index ν with which one compares.

### 3.6 Sharpness, the hypotheses that are needed, and the literature

**Examples 3.11.** In (a) to (c) the scaffold makes one call with a fixed input, so a run is an answer y ∈ Y and a hypothesis is a probability vector on Y.

(a) *The factor 3 is attained by the estimator of Definition 3.4.* (The example is Lemma 11 of Mahalanabis and Štefankovič (2008), who use it for all selection rules that depend on the data through the test statistics only.) Let Y = {1, 2, 3, 4}, 0 < ε₀ < 1/4, and

 ν₁ = (0, 1/4 + ε₀, 1/2, 1/4 − ε₀), ν₂ = (1/2 + ε₀, 1/4 − ε₀, 0, 1/4), Q = (1/2, 1/2, 0, 0),

with w(ν₁) = w(ν₂). Then A_ν₁ν₂ = {2, 3}, A_ν₂ν₁ = {1, 4}, Q_ν₁(A_ν₁ν₂) = Q_ν₂(A_ν₂ν₁) = 3/4 + ε₀, TV(Q_ν₁, Q) = 3/4 − ε₀ and TV(Q_ν₂, Q) = 1/4 + ε₀. The data fall on the answers 1 and 2 only, so U_N(ν₁, ν₂) = 3/4 + ε₀ − Q̂_N({2}) and U_N(ν₂, ν₁) = 3/4 + ε₀ − Q̂_N({1}), with Q̂_N({1}) + Q̂_N({2}) = 1. Let N be odd and so large that r_N(ν₁) < 1/4. With probability exactly 1/2, Q̂_N({2}) > 1/2; then U_N(ν₁, ν₂) < 1/4 + ε₀ < U_N(ν₂, ν₁) and U_N(ν₂, ν₁) > r_N, so c_N(ν₁) < c_N(ν₂) and ν̂ = ν₁. On this event TV(Q_ν̂, Q) = 3/4 − ε₀ = (3 − 16ε₀/(1 + 4ε₀))·min_ν TV(Q_ν, Q). So for no c < 3 does this estimator satisfy TV(Q_ν̂, Q) ≤ c·min_ν TV(Q_ν, Q) + o(1) with probability above 1/2. *What is known for other estimators* (rewritten by the editor after both reports; the quantifiers below were read in the source, see the literature list). On the four-point space of this example a rule that returns a member of the class can do much better than the factor 3 once N is large: the member nearest in total variation to the empirical measure is the far one with probability 5.9·10⁻³ at N = 11 and 8.5·10⁻¹⁸ at N = 101, for ε₀ = 0.05 (attack report, `property-batch_attack_pr4.out`, block 4). The lower bound of Bousquet, Kane and Moran is for a number of samples that does not grow with the size of the space of outcomes. Their Theorem 19: for arbitrarily small β ∈ (0, 1) there is a class of two densities on an infinite domain such that for every (possibly randomised) rule that returns a member of the class and every number m of samples there is a target p with opt := min_i TV(q_i, p) = β/2 for which the rule, given at most m samples, returns a member q with TV(q, p) > (3 − 6β)·opt + β², with probability at least 1/3. Their Theorem 21 is the same for a domain of M > 1/β points and at most √(Mβ) samples. So "no rule that returns a member of the class has a factor below 3" is true with the addition "with a number of runs that does not depend on the size of the space of runs, and for guarantees that hold with probability above 2/3" (their Corollary 20). A rule that may return a mixture of members reaches the factor 2 for every finite class (their Theorem 1); I have not carried this over to weighted classes. For two densities a randomised rule that returns a member has the factor 2 in expectation (Mahalanabis and Štefankovič, Theorem 10, read by the attack report; Bousquet, Kane and Moran report it in their Section 1.6, read by the editor); so the factor 3 in the bound in expectation of Corollary 3.7(c) is not known to be the best possible.

(b) *For an infinite class the penalty is needed.* Let Y = {1, …, u} and let the human answer uniformly: Q uniform on Y. Let H contain Q and, for every set S ⊆ Y of N elements, the uniform law Q_S on S. If the N recorded answers are distinct (probability at least 1 − N²/(2u)), then Q̂_N = Q_S for S the set of recorded answers, so U_N(Q_S, ν′) = 0 for every ν′. Without penalties (Definition 3.4 with r_N ≡ 0) the criterion is therefore minimised by the hypothesis that replays the data, and TV(Q_S, Q) = 1 − N/u; for the human's own index, A_{Q,Q_S} = Y∖S and U_N(Q, Q_S) = Q(Y∖S) − Q̂_N(Y∖S) = 1 − N/u. With weights that are equal among the C(u, N) hypotheses Q_S we have w(Q_S) ≤ 1/C(u, N) ≤ (N/u)^N, so r_N(Q_S) ≥ √(ln(u/N)/2). As soon as u > N·e^(2(1+r_N(Q))²), this gives c_N(Q_S) ≥ r_N(Q_S) > 1 + r_N(Q) ≥ c_N(Q), and no replaying hypothesis is selected. (Theorem 3.6 holds whatever the weights are; the example shows what the penalty is for.)

(c) *Outside the class, "the highest-weight index that matches" need not exist.* Let Y = {0, 1}, H = {ν₁, ν₂} with ν₁(1) = 1/4, ν₂(1) = 3/4, and Q(1) = 1/2. Then A_ν₂ν₁ = {1}, A_ν₁ν₂ = {0}, Q̂_N({1}) → 1/2 almost surely, so |Q_ν(A_ν₂ν₁) − Q̂_N(A_ν₂ν₁)| → 1/4 for both ν and U_N(ν₁, ν₂), U_N(ν₂, ν₁) → 1/4, while every tolerance tends to 0. For large N neither index matches in the sense of Theorem 3.3, and neither is admissible in the sense of Proposition 3.8. The estimator of Definition 3.4 returns one of the two; both are at distance 1/4 from Q.

(d) *(IID) is needed*: Remark 2.7(2).

(e) *The Yatracos sets must be among the tests if the conclusion is to be about total variation.* A sampler can match every test of a family of small total price and be at total variation 1/2 from the human system: Proposition 5.2.

**The literature, and how each statement was accessed.**

* Y. G. Yatracos, "Rates of convergence of minimum distance estimators and Kolmogorov's entropy", *Annals of Statistics* 13(2) (1985) 768–774. Not read in this session; cited for the sets A_νν′ and the minimum-distance principle as described in the three sources below.
* L. Devroye and G. Lugosi, *Combinatorial Methods in Density Estimation*, Springer 2001, Chapter 6. Not read in this session. Read in this session in a restatement: S. Mahalanabis and D. Štefankovič, "Density estimation in linear time", arXiv:0712.2869v1 (2007; COLT 2008), Section 1, which states: for a finite class F of densities, the unknown density g, the empirical measure h, the test functions T_ij := sgn(f_i − f_j) and Δ := max_T (g − h)·T, "Theorem 3 ([DL01], Theorem 6.3)": the minimum distance estimate f₁, which minimises max{|(f − h)·T_ij| ; f_i, f_j ∈ F}, satisfies ‖f₁ − g‖₁ ≤ 3·d₁(g, F) + 2Δ; and "Theorem 2 ([DL01], Theorem 6.2)": the Scheffé tournament winner satisfies ‖f₁ − g‖₁ ≤ 9·d₁(g, F) + 8Δ. Their Remark 1 says that their Δ is at most twice the Δ of Devroye and Lugosi, which is defined with the sets {f_i > f_j}. In our units (TV is half the L₁ distance) their Theorem 3 reads TV ≤ 3·inf TV + Δ, with their Δ. Also read in this session: S. Compton and J. Li, "Density estimation for Hellinger via minimum-distance estimators", arXiv:2606.11469v1 (2026), Lemma 5, which states the same result as E[TV(f, f̂_n)] ≤ 3·inf_θ TV(f, f_θ) + O(√(VC(𝒜)/n)) for the Yatracos class 𝒜 = {{x : f_θ(x) > f_θ′(x)}}.
* Mahalanabis and Štefankovič, as above [read]: their Theorem 4 proves the same guarantee for the "modified minimum distance estimate", which minimises max{|(f_i − h)·T_ij| ; f_j ∈ F} over i, that is, which uses for each candidate only the test functions in which the candidate takes part; their Remark 5 notes that the deviation of h from g is needed only on the test functions of the best member; their Lemma 11 is Example 3.11(a). Definition 3.4 is this estimate with weights and with one-sided statistics; Theorem 3.6 is its analysis with a weighted union bound. I did not find the weighted statement in the literature and I do not claim that it is new.
* O. Bousquet, D. Kane and S. Moran, "The optimal approximation factor in density estimation", *Proceedings of COLT 2019*, PMLR 99, 318–341; arXiv:1902.05876. The prover saw it only through an automatic summary. Both verifiers and the editor then read version 5 (arXiv:1902.05876v5, 14 December 2025; Sections 1.5 to 1.7 and the statements of Section 5). Section 1.5: a class Q is α-learnable if there is an algorithm such that for every ε, δ > 0 there is a sample size m(ε, δ) with TV(p, q) ≤ α·opt + ε with probability at least 1 − δ for every target p; properly, if the output always lies in Q; and "when X is finite, we consider Q to be α-learnable only if its sample complexity depends efficiently on |X|, namely poly log(|X|)", because "if X is finite then any class of distribution is α-learnable for α = 1 with sample complexity O(|X|/ε²)". Theorem 1: "Every finite class of distributions Q is α-learnable with α = 2." Theorem 2: "For every α < 3 there is a class Q of size 2 that is not properly α-learnable." Theorems 19 and 21 and Corollary 20 are as quoted in Example 3.11(a); in Theorem 21 the bound on the number of samples reads √(Mβ) in the text extracted from the PDF, which agrees with the proof (there the domain has M = 2N·k points with k = (1 + β)/β, and the number N is chosen "sufficiently larger than m²", m being the number of samples). Remark 1 of this version: a gap in the original proof of the lower bound was found by Aamand, Aliakbarpour, Chen and Silwal (2025, arXiv:2509.03734) and is corrected there. Cite version 5.
* G. Biau and L. Devroye, "Density estimation by the penalized combinatorial method", *J. Multivariate Anal.* 94 (2005) 196–208. Named by the attack report as the nearest published penalised form of the minimum-distance estimate (selection among an increasing sequence of classes of finite Vapnik–Chervonenkis dimension). Bibliographic data confirmed there by a search; the paper was not opened by anyone in this project, and no theorem of it is used.
* The weighted union bound ("Occam bound") is standard. A related likelihood-based estimator with rates in Hellinger distance governed by min_ν [K(ν)/N + divergence] is "minimum complexity density estimation" (A. R. Barron and T. M. Cover, *IEEE Trans. Inform. Theory* 37(4) (1991) 1034–1054; from memory, not checked); in this project its counterpart is Theorem B of `proofs/hellinger-runs.md` (H2 in the note).

---

## 4. Pr2: what the Bayes mixture does with a simple property

**In brief.** Let R be a property of question–answer pairs that the human never violates. (1) *In hindsight* the mixture has learned R at the price of R: on any data that abide by R, the posterior expectation of the inverse of the probability that a hypothesis gave to abiding so far is at most the constant C_R with which the class is closed under conditioning on R (Theorem 4.2); C_R = 2^(K(R)+c) in the class of all programs. (2) *At a fresh input* this is false. In a class of memorisers the mixture violates a property of constant complexity with probability above 1/2 for all n up to (K − 2)/(bits per pair), and the exact value is computed (Theorem 4.5). If the class is closed under conditioning, the violation probability is at most 1 − 1/C_R, and this value is approached (Corollary 4.6); the remaining probability 1/C_R may be the probability of giving no answer (Remark 4.14). (3) What does hold at a fresh input is governed by the *regret*: one minus the violation probability is at least the n-th root of δ·M(D_n)/P(D_n) (Theorem 4.7), so the violation probability is at most (K ln 2 + ln(1/δ))/n, and a violation level v can be sustained only while the mixture loses log₂(1/(1 − v)) bits per pair against the human; this trade-off is attained (Proposition 4.8). (4) In the class of all programs the same holds with K replaced by the complexity of the simplest hypothesis that predicts the human's answers as well as the human's own law does. Universal reference machines can be chosen on which R has a program of 6 bits, the class is closed under conditioning on R with a constant that does not grow, and the memoriser phenomenon lasts for as many questions as one likes (Theorem 4.11(B)); so no bound in terms of the price of R and the closure constant holds on all universal machines. For one fixed machine the corresponding question is open (4.13). All of (2) and (4) are statements about the prior: the level at which the mixture violates R in these examples is the prior probability that a memorising hypothesis violates R where it has no data, and the examples set it to 1 (remark (3) after Theorem 4.5).

### 4.1 Setting; conditioning on a property

Hypotheses are samplers, possibly semimeasures; (H, w) is as in Section 1. A data set is D_n = ((x_1, y_1), …, (x_n, y_n)) with x_i ∈ X and y_i ∈ Y (an answer was given each time). ν(D_n) := Π_{i≤n} ν(y_i|x_i) is the likelihood, M(D_n) := Σ_ν w(ν)·ν(D_n), the posterior is w_{D_n}(ν) := w(ν)·ν(D_n)/M(D_n) when M(D_n) > 0, and M_{D_n}(y|x) := Σ_ν w_{D_n}(ν)·ν(y|x) is the mixture, as in the outline.

**Definition 4.1.** A *property* is a set R ⊆ X × Y. A pair *abides by* R if it lies in R and *violates* R otherwise; a data set abides by R if all its pairs do. R_x := {y ∈ Y : (x, y) ∈ R}. For a sampler ν,

 v_ν(x) := Σ_{y ∈ Y∖R_x} ν(y|x)

is the probability that the answer of ν at x violates R. Giving no answer is not a violation. ν *never violates* R if v_ν(x) = 0 for all x. The violation probability of the mixture at x is v_{M_D}(x) = Σ_ν w_D(ν)·v_ν(x).

*The sampler ν conditioned on R* is ν^R, with ν^R(y|x) := ν(y|x)·1[(x, y) ∈ R]/(1 − v_ν(x)) if v_ν(x) < 1, and ν^R(y|x) := 0 for all y ∈ Y if v_ν(x) = 1. It is a semimeasure sampler, because Σ_{y∈R_x} ν(y|x) + v_ν(x) ≤ 1, and it never violates R. It is the law of the procedure "draw answers from ν(·|x) until one does not violate R, and give it; a draw that gives no answer ends the procedure with no answer".

**(Cl_R)** The class (H, w) is *closed under conditioning on R with constant C_R ≥ 1* if there is a map φ: H → H such that φ(ν) names the sampler ν^R for every ν ∈ H, and

 Σ_{ν ∈ H : φ(ν) = ν′} w(ν) ≤ C_R·w(ν′) for every ν′ ∈ H.

If φ is injective this says w(φ(ν)) ≥ w(ν)/C_R.

**Theorem 4.2 (hindsight; Pr2(a)). PROVED** (the closure assumption of the draft is made exact as (Cl_R)). Assume (Cl_R). For every n and every data set D_n that abides by R and has M(D_n) > 0,

 Σ_ν w_{D_n}(ν)·Π_{i≤n} 1/(1 − v_ν(x_i)) ≤ C_R.

Here Π_{i≤n} (1 − v_ν(x_i)) is the probability that n independent answers of ν at the inputs x_1, …, x_n do not violate R: the probability that ν gave to abiding so far. The sum runs over the indices of positive posterior weight; for an index with ν(D_n) = 0 the term is 0, also when v_ν(x_i) = 1 at a seen input and the product is infinite (convention 0·∞ = 0; both reports). Nothing is assumed about the origin of the data: no A1, no A2.

*Proof.* Let ν have ν(D_n) > 0. Each (x_i, y_i) lies in R and ν(y_i|x_i) > 0, so v_ν(x_i) ≤ 1 − ν(y_i|x_i) < 1 and ν^R(D_n) = ν(D_n)·Π_i (1 − v_ν(x_i))^(−1). Hence, summing first over the ν with a given image under φ (all terms are nonnegative),

 Σ_{ν : ν(D_n)>0} w(ν)·ν(D_n)·Π_i (1 − v_ν(x_i))^(−1) ≤ Σ_ν w(ν)·φ(ν)(D_n) = Σ_{ν′} (Σ_{ν : φ(ν)=ν′} w(ν))·ν′(D_n) ≤ C_R·Σ_{ν′} w(ν′)·ν′(D_n) = C_R·M(D_n).

Divide by M(D_n). ∎

*Where it comes from* (added by the editor; attack report, Section 3). The floor of Corollary 4.3(c) is the first half of a "result" that the researcher states without proof and that the digest of his notes records (`research/understand/notes.md`, Q5: "the probability of P-abiding generalization is at least 2^{−C(P)}"). The hindsight bound, with this proof, is a derivation of the digest's author under Q5 for the class of all programs, marked there as unrefereed; the candidate theory took it from the digest. The technique is that of every dominance argument for universal mixtures: a class that is closed under an operation, at a bounded cost in weight, dominates the operated class. What this file adds is the exact closure condition (Cl_R) with its constant, the reading of "abiding" that makes the class of all programs closed, and the consequences drawn in Corollary 4.3.

**Corollary 4.3. PROVED.** Under the assumptions of Theorem 4.2:

(a) *The inputs already seen.* Σ_{i≤n} v_{M_{D_n}}(x_i) = Σ_ν w_{D_n}(ν)·Σ_{i≤n} v_ν(x_i) ≤ ln C_R. If the n inputs seen so far were put to the mixture M_{D_n} once more, the expected number of answers that violate R would be at most ln C_R.
(b) For η > 0, the posterior weight of {ν : Π_{i≤n} (1 − v_ν(x_i)) ≤ η} is at most η·C_R.
(c) *The floor.* The hypotheses that never violate R have posterior weight at least 1/C_R. Hence v_{M_{D_n}}(x) ≤ 1 − 1/C_R for every x ∈ X, seen or not. (A hypothesis that gives no answer does not violate R, so this does not say that the mixture gives an abiding answer with probability 1/C_R: Remark 4.14.)

*Proof.* (a) By Jensen's inequality for the logarithm, Σ_ν w_{D_n}(ν)·Σ_i ln(1/(1 − v_ν(x_i))) ≤ ln C_R, and v ≤ ln(1/(1 − v)). (b) Markov's inequality. (c) For abiding data ν^R(D_n) ≥ ν(D_n) for every ν. Every index in φ(H) names a sampler that never violates R, and Σ_{ν′ ∈ φ(H)} w(ν′)·ν′(D_n) ≥ (1/C_R)·Σ_{ν′ ∈ φ(H)} (Σ_{ν : φ(ν)=ν′} w(ν))·ν′(D_n) = (1/C_R)·Σ_ν w(ν)·ν^R(D_n) ≥ M(D_n)/C_R. ∎

**Remark 4.4 (the class of all programs; standard facts used without proof).** Let the hypotheses be the programs p of a prefix-free universal language in which a program draws random bits and computes an answer, or runs for ever; the sampler ν_p of p is then a lower semicomputable semimeasure, and w(p) := 2^(−ℓ(p)) with ℓ the length. Let R be decidable and let r be a program that decides it. The procedure of Definition 4.1 is a program φ_r(p) of length ℓ(p) + ℓ(r) + c, where c depends on the language only, and φ_r is injective. So (Cl_R) holds with C_R = 2^(ℓ(r)+c), and for a shortest r with C_R = 2^(K(R)+c): this is the form of the draft. Two points are made exact by Definition 4.1. First, "abiding" has to be read as "not violating": conditioning on the event that an answer is given *and* abides would divide by Σ_{y∈R_x} ν(y|x), which is not a lower semicomputable operation, whereas ν(y|x)·1[(x,y) ∈ R]/(1 − v_ν(x)) is lower semicomputable because v_ν(x) is. Second, R must be decidable for the procedure to be a program.

### 4.2 At a fresh input the price of the property is not enough: memorisers

**Theorem 4.5 (memorisers; Pr2(b), exact). PROVED.** Let u ≥ 1 be an integer and K ≥ 1 a real number. Let X = {1, …, u}, Y = {0, 1, b}, where b is "the bad answer", and R := {(x, y) : y ≠ b}. Let f: X → {0, 1} be any function; the human answers f(x). A *table* is a function T from a set dom T ⊆ X to {0, 1}; |T| is the size of dom T. The *memoriser* g_T answers T(x) if x ∈ dom T and b otherwise. The class H_mem consists of the index f with weight w(f) := 2^(−K) and of the indices g_T, for all tables T, with

 w(g_T) := c₀·(4u)^(−|T|), c₀ := (1 − 2^(−K))·(1 + 1/(2u))^(−u).

The weights sum to 1, the human never violates R, and R is decided by a program of constant length. Put β := log₂(4u + 2) (the *bits per pair*). Let D be a data set of pairs (x, f(x)) with k distinct inputs; inputs may repeat. Then:

(a) M(D) = 2^(−K) + (1 − 2^(−K))·(4u + 2)^(−k).
(b) For x not among the inputs of D, v_{M_D}(x) = M_D(b|x) = (2u/(2u + 1)) / (1 + (4u + 2)^k/(2^K − 1)). For x among the inputs of D, M_D(f(x)|x) = 1.
(c) Let μ be the uniform law on X. The probability that the mixture's answer to an input drawn from μ, independently of D, violates R is

 V(D) := Σ_x μ(x)·v_{M_D}(x) = ((u − k)/u)·(2u/(2u + 1)) / (1 + (4u + 2)^k/(2^K − 1)).

(d) If k ≤ θ·u and k·β ≤ K − j with θ ∈ [0, 1) and j ≥ 0, then V(D) ≥ (1 − θ)·(2u/(2u + 1)) / (1 + 2^(−j)/(1 − 2^(−K))). In particular, if u ≥ 5 and K ≥ 2, then **V(D_n) ≥ (3/4)·(10/11)·(3/4) > 0.51 for every data set D_n of n ≤ min{u/4, (K − 2)/β} pairs.**
(e) V(D) ≤ 2^(K − kβ).
(f) Every hypothesis of positive posterior weight has v_ν(x_i) = 0 at every input x_i of D, so the left side of Theorem 4.2 equals 1.

So the probability that the mixture violates R at a fresh input stays above 1/2 while n·β ≤ K − 2 (and n ≤ u/4), and it is at most 2^(−j) once (K + j)/β or more distinct inputs have been seen. For u = 2²⁰ and K = 1000 (β = 22.000, (K − 2)/β = 45.4) the values of V for k = 0, 10, 30, 44, 45, 46, 47, 48 are 1.000000, 0.999990, 0.999971, 0.999958, 0.998981, 0.000244, 5.8·10⁻¹¹, 1.4·10⁻¹⁷ (Section 9).

*Proof.* The likelihood of a deterministic hypothesis is 1 if it gives the recorded answer at every recorded input and 0 otherwise. Let S be the set of inputs of D, |S| = k. A memoriser g_T is consistent with D iff S ⊆ dom T and T = f on S; otherwise it answers b or the wrong bit at an input of D. So the consistent tables are f|_S extended by an arbitrary table T′ on X∖S, and

 Σ_{T consistent} (4u)^(−|T|) = (4u)^(−k)·Σ_{T′} (4u)^(−|T′|) = (4u)^(−k)·Σ_{i=0}^{u−k} C(u−k, i)·2^i·(4u)^(−i) = (4u)^(−k)·(1 + 1/(2u))^(u−k).

With k = 0 this shows that the weights sum to 2^(−K) + c₀·(1 + 1/(2u))^u = 1. Multiplying by c₀ and using 4u·(1 + 1/(2u)) = 4u + 2 gives the weight (1 − 2^(−K))·(4u + 2)^(−k) of the consistent memorisers, and (a) follows. (b) Let x ∉ S. The human answers f(x) ≠ b, and a consistent memoriser answers b at x iff x ∉ dom T; these tables are the extensions of f|_S by a table on X∖(S ∪ {x}), of total weight c₀·(4u)^(−k)·(1 + 1/(2u))^(u−k−1) = (1 − 2^(−K))·(4u + 2)^(−k)·(2u/(2u + 1)). Dividing by (a) and then by (1 − 2^(−K))·(4u + 2)^(−k) gives the formula. For x ∈ S every consistent hypothesis answers f(x). (c) X∖S has μ-probability (u − k)/u. (d) (4u + 2)^k = 2^(kβ) ≤ 2^(K−j), so (4u + 2)^k/(2^K − 1) ≤ 2^(−j)/(1 − 2^(−K)); for j = 2 and K ≥ 2 this is at most 1/3. V(D) is decreasing in k, and a data set of n pairs has k ≤ n. (e) V(D) ≤ (2^K − 1)/(4u + 2)^k. (f) Every consistent hypothesis answers f(x_i) ≠ b at x_i with probability 1. ∎

*Two remarks.* (1) The table that equals f on all of X is a memoriser of weight c₀·(4u)^(−u), which names the same kernel as the index f. The formulas above keep the two indices apart and are exact as stated; the weight of the kernel f is 2^(−K) + c₀·(4u)^(−u). (2) H_mem is not closed under conditioning on R: g_T^R gives no answer outside dom T and is not in the class. Theorem 4.2 therefore does not apply to H_mem, although its conclusion holds there by (f). The next corollary closes the class. (3) (Added by the editor from the attack report, Finding M3; checked in `property-batch_editor.out`, block (E10).) *The level is a parameter of the class.* In H_mem every memoriser answers b outside its table. Let each memoriser instead come in two versions with the same table, one that answers b outside the table, with the fraction λ of the weight c₀·(4u)^(−|T|), and one that answers there some fixed answer g ∉ {0, 1, b}, which abides by R and which the human never gives, with the fraction 1 − λ. Both versions fit the same data, so M(D) is as in (a), and at an input not among those of D the mixture answers b with probability exactly λ times the value of (b): for u = 4, K = 30 and one pair seen, 0.889, 0.444 and 0.018 for λ = 1, 1/2 and 1/50. So "the mixture violates R with probability near 1" means "near the prior probability that what a memoriser does outside its table violates R", which Theorem 4.5 sets to 1. Corollary 4.6 is the case in which the other version gives no answer. The theorem shows that the mixture *need not* keep a simple property at the price of the property; it does not show that a mixture with a prior that somebody would choose does not.

**Corollary 4.6 (the memoriser class closed under conditioning; the floor is approached). PROVED.** Let C > 0. Let H_mem^cl consist of the index f with weight 2^(−K), of the indices g_T with weights (C/(C + 1))·c₀·(4u)^(−|T|), and of indices h_T with weights (1/(C + 1))·c₀·(4u)^(−|T|), where h_T answers T(x) on dom T and gives no answer elsewhere. Then (Cl_R) holds with φ(g_T) = φ(h_T) = h_T, φ(f) = f and C_R = C + 1. For D as in Theorem 4.5, M(D) is as in 4.5(a), and for x not among the inputs of D

 v_{M_D}(x) = (1 − 1/C_R)·(2u/(2u + 1)) / (1 + (4u + 2)^k/(2^K − 1)).

So, for every constant C_R > 1 and every n, there are a class that satisfies (Cl_R) with this constant, a human in it who never violates R, and data of n pairs from this human, such that the mixture violates R at every unseen input with probability at least (1 − 1/C_R)·(1 − 1/(2u+1))·(3/4), where u is arbitrary. The value is always below 1 − 1/C_R and tends to it as u and K − nβ grow (for C_R = 2, u = 2²⁰, K = 1000, k = 10 it is 0.49999976): the bound of Corollary 4.3(c) is the supremum of what occurs and cannot be improved, although it is not attained. Under (Cl_R) alone there is no bound on the violation probability at a fresh input that tends to 0 with n.

*Proof.* g_T^R = h_T: at x ∈ dom T nothing changes, and at x ∉ dom T the answer b has probability 1, so the conditioned sampler gives no answer. h_T and f never violate R, so they are their own conditionings. The indices mapped to h_T are g_T and h_T, of total weight c₀·(4u)^(−|T|) = (C + 1)·w(h_T); the only index mapped to f is f; no index is mapped to g_T. h_T is consistent with D under the same condition as g_T, so M(D) is unchanged, and among the consistent memorisers whose table does not contain x, the fraction C/(C + 1) of the weight answers b. For the last statement take K ≥ nβ + 2: then (4u + 2)^k/(2^K − 1) ≤ 1/3 as in Theorem 4.5(d). ∎

### 4.3 What holds at a fresh input: the regret is the price

**Theorem 4.7 (foresight). ADDED, PROVED.** Assume A1: the human is a sampler P with Σ_y P(y|x) = 1; P need not be in H. Let μ be a law on X and R a property such that v_P(x) = 0 for every x with μ(x) > 0. Let x_1, x_2, … be independent with law μ, and let y_i be drawn from P(·|x_i). For ν ∈ H let

 V_ν := Σ_x μ(x)·v_ν(x),

the probability that ν violates R at a fresh input drawn from μ. Put P(D_n) := Π_{i≤n} P(y_i|x_i).

(a) Z_n := Σ_{ν : ν(D_n) > 0} w(ν)·ν(D_n)·(1 − V_ν)^(−n)/P(D_n), n = 0, 1, 2, …, is a nonnegative supermartingale with Z₀ = Σ_ν w(ν) ≤ 1.
(b) Let δ ∈ (0, 1). With probability at least 1 − δ, for all n ≥ 0 simultaneously: M(D_n) = 0 or

 Σ_ν w_{D_n}(ν)·(1 − V_ν)^(−n) ≤ P(D_n)/(δ·M(D_n)).

(The sum runs over the indices of positive posterior weight, as in Theorem 4.2; for the others the term is 0.)

(c) Let V(D_n) := Σ_ν w_{D_n}(ν)·V_ν = Σ_x μ(x)·v_{M_{D_n}}(x), the probability that the mixture M_{D_n}, asked an input drawn from μ independently of D_n, gives an answer that violates R. On the event of (b), for all n ≥ 1 with M(D_n) > 0:

 1 − V(D_n) ≥ (δ·M(D_n)/P(D_n))^(1/n), hence V(D_n) ≤ (ln(P(D_n)/M(D_n)) + ln(1/δ))/n.

(d) If in addition P ∈ H (A2) and K = K(P), then on the event of (b), for all n ≥ 1: 1 − V(D_n) ≥ (δ·2^(−K))^(1/n), V(D_n) ≤ (K ln 2 + ln(1/δ))/n, and V(D_n) < 1/2 whenever n > K + log₂(1/δ).
(e) For every S ∈ H, on the event of (b): V(D_n) ≤ (K(S)·ln 2 + ln(P(D_n)/S(D_n)) + ln(1/δ))/n.
(f) On the event of (b): if V(D_n) ≥ v, then log₂(P(D_n)/M(D_n)) ≥ n·log₂(1/(1 − v)) − log₂(1/δ).
(g) On the event of (b), for every v ∈ [0, 1): the posterior weight of {ν : V_ν ≥ v} is at most (1 − v)^n·P(D_n)/(δ·M(D_n)).

In words, (f) says: the mixture can violate R at a fresh input with probability v only while its cumulative log-loss on the data exceeds that of the human by at least log₂(1/(1 − v)) bits per pair. When the human is in the class the excess is never more than K bits in total, so this lasts for at most (K + log₂(1/δ))/log₂(1/(1 − v)) pairs.

*Proof.* (a) Almost surely P(D_n) > 0 and D_n abides by R. Fix ν and put ζ_n := ν(D_n)·(1 − V_ν)^(−n)/P(D_n) if ν(D_n) > 0, and ζ_n := 0 otherwise. If V_ν = 1, then v_ν(x) = 1 and so ν(y|x) = 0 for all y ∈ R_x, for every x with μ(x) > 0; hence ν(D_n) = 0 almost surely for n ≥ 1, and ζ_n = 0 ≤ ζ₀ = 1. If V_ν < 1, then given D_n the pair (x_{n+1}, y_{n+1}) has probability μ(x)·P(y|x), so

 E[ζ_{n+1} | D_n] = ζ_n·(1 − V_ν)^(−1)·Σ_{x, y : μ(x)P(y|x) > 0} μ(x)·ν(y|x) ≤ ζ_n·(1 − V_ν)^(−1)·Σ_x μ(x)·Σ_{y ∈ R_x} ν(y|x) ≤ ζ_n,

because μ(x)·P(y|x) > 0 implies y ∈ R_x, and Σ_{y∈R_x} ν(y|x) ≤ 1 − v_ν(x). Z_n = Σ_ν w(ν)·ζ_n(ν) is therefore a nonnegative supermartingale (monotone convergence), and Z₀ = Σ_ν w(ν).

(b) By Ville's inequality, Pr[sup_n Z_n ≥ 1/δ] ≤ δ·E Z₀ ≤ δ. (Proof of the inequality: let τ be the first n with Z_n ≥ 1/δ; the stopped process is a nonnegative supermartingale, so E Z₀ ≥ E Z_{τ∧n} ≥ (1/δ)·Pr[τ ≤ n]; let n → ∞.) On the complementary event, Z_n < 1/δ for all n, and if M(D_n) > 0, then Σ_ν w_{D_n}(ν)·(1 − V_ν)^(−n) = Z_n·P(D_n)/M(D_n).

(c) The function t ↦ (1 − t)^(−n) is convex on [0, 1). The posterior charges only indices with ν(D_n) > 0, and almost surely these have V_ν < 1, by the first case of (a). By Jensen's inequality (1 − V(D_n))^(−n) ≤ Σ_ν w_{D_n}(ν)·(1 − V_ν)^(−n) ≤ P(D_n)/(δ·M(D_n)). This is the first claim; the second follows from 1 − e^(−a) ≤ a. (d) M(D_n) ≥ w(P)·P(D_n) = 2^(−K)·P(D_n); and (δ·2^(−K))^(1/n) > 1/2 iff n > K + log₂(1/δ). (e) M(D_n) ≥ w(S)·S(D_n). (f) is (c) rearranged. (g) Markov's inequality applied to (b). ∎

*Which hypotheses are used.* The inputs must be drawn independently from the law μ from which the fresh input is drawn. Of A1 only this is used: given the past and x_{n+1}, the answer y_{n+1} has a conditional law that is concentrated on R_{x_{n+1}}; with P(D_n) defined as the product of these conditional probabilities the proof is unchanged, so the human may keep state. The property R may be any set; decidability is not used. For questions that are chosen adaptively, as in rehearsal, see Proposition 4.9.

*What it is* (added by the editor from the attack report, Finding M2(d)). For deterministic hypotheses and a deterministic human the Bayes posterior is the prior restricted to the hypotheses consistent with the data, and a bound of the form "the posterior-average rate of error at a fresh input is at most (ln(1/prior weight of the consistent set) + ln(1/δ))/n, up to lower-order terms" is the PAC-Bayesian theorem for consistent concepts of D. McAllester, "Some PAC-Bayesian theorems", *Machine Learning* 37 (1999) 355–363 (quoted from memory by the attack report, where it carries a further term of order (ln n)/n; the paper was not opened in this project). Theorem 4.7 reads "error" as "violation of R", concerns the Bayes posterior only and for it has no logarithmic term, holds for all n at once, and allows a human and hypotheses that are not deterministic. The maximal inequality used in (b) is Ville's. The trade-off (f) between the violation level and the bits of regret per pair, with Proposition 4.8, is the part for which neither report found a source.

**Proposition 4.8 (recognisers: the trade-off of Theorem 4.7 is attained). ADDED, PROVED.** Let X = {1, …, u}, Y = {0, 1, b}, R = {(x, y) : y ≠ b}, f: X → {0, 1}, K ≥ 1, 1 ≤ s < u and σ := s/u. For S ⊆ X with |S| = s let ν_S answer f(x) for x ∈ S and b for x ∉ S. The class H_rec consists of the index f with weight 2^(−K) and of the C(u, s) indices ν_S, each with weight (1 − 2^(−K))/C(u, s). Let D consist of pairs (x, f(x)) with k ≤ s distinct inputs, and put ω_k := Π_{i<k} (s − i)/(u − i). Then:

(a) M(D) = 2^(−K) + (1 − 2^(−K))·ω_k.
(b) For x not among the inputs of D: v_{M_D}(x) = ((u − s)/(u − k))·(1 − 2^(−K))·ω_k/M(D). For the uniform law μ: V(D) = (1 − σ)·(1 − 2^(−K))·ω_k/(2^(−K) + (1 − 2^(−K))·ω_k).
(c) σ^k·(1 − k²/(2s)) ≤ ω_k ≤ σ^k. Hence, if k ≤ √s and k·log₂(1/σ) ≤ K − 2 − j with j ≥ 0, then V(D) ≥ (1 − σ)/(1 + 2^(−j)).
(d) Under the conditions of (c), 1 − V(D) ≤ σ + 2^(−j). In the other direction, for every data set D of this kind with k ≥ 1 distinct inputs, 1 − V(D) ≥ M(D)^(1/k); this is the inequality of Theorem 4.7(c) with P(D) = 1, n = k and δ = 1, and in this class it holds for every data set and not only on an event of probability 1 − δ. Under the conditions of (c) it gives 1 − V(D) ≥ σ·(1/4)^(1/k).

So the violation level v = 1 − σ is sustained at the cost of log₂(1/σ) = log₂(1/(1 − v)) bits per pair, for about K/log₂(1/(1 − v)) pairs: the inequality 4.7(c) is attained up to the factor (δ/4)^(1/k) and the term 2^(−j). With σ = 1/4: V(D_n) ≥ 2/3 for all n ≤ min{(K − 5)/2, √(u/4)}, at two bits per pair. With σ just below 1/2 the level is just above 1/2 for about K pairs, which by 4.7(d) is the longest possible up to the additive log₂(1/δ). For u = 2¹⁶ and K = 200 the exact values are in Section 9.

*Proof.* ν_S is consistent with D iff S contains the k inputs of D. There are C(u − k, s − k) such sets, and C(u − k, s − k)/C(u, s) = Π_{i<k} (s − i)/(u − i) = ω_k; this gives (a). For x not among the inputs, the consistent sets that do not contain x number C(u − k − 1, s − k), and C(u − k − 1, s − k)/C(u − k, s − k) = (u − s)/(u − k); this gives the first formula of (b), and the second follows because the unseen inputs have μ-probability (u − k)/u. (c) (s − i)/(u − i) ≤ s/u because s ≤ u, and (s − i)/(u − i) ≥ (s − i)/u = σ·(1 − i/s); further Π_{i<k} (1 − i/s) ≥ 1 − Σ_{i<k} i/s ≥ 1 − k²/(2s). For k ≤ √s this gives ω_k ≥ σ^k/2, so 2^(−K)/((1 − 2^(−K))·ω_k) ≤ 2^(2−K)·σ^(−k) ≤ 2^(−j), and V(D) = (1 − σ)/(1 + 2^(−K)/((1 − 2^(−K))·ω_k)). (d) With e := 2^(−K)/((1 − 2^(−K))·ω_k) ≤ 2^(−j): 1 − V(D) = (σ + e)/(1 + e) ≤ σ + e. For the other direction (this step was missing in the prover's file, which applied Theorem 4.7(c) to a fixed data set; the fill is the check report's, verified by the editor, `property-batch_editor.out`, block (E5)): put a := 2^(−K) and M := M(D) = a + (1 − a)·ω_k; by (b), 1 − V(D) = (a + σ·(1 − a)·ω_k)/M. The function t ↦ t^(1+1/k) is convex, so M^(1+1/k) ≤ a·1 + (1 − a)·ω_k^(1+1/k) by Jensen's inequality, and ω_k^(1/k) ≤ σ by (c); hence M^(1+1/k) ≤ a + σ·(1 − a)·ω_k = (1 − V(D))·M, that is, 1 − V(D) ≥ M^(1/k). Finally M(D) ≥ (1 − 2^(−K))·ω_k ≥ σ^k/4 under the conditions of (c). ∎

**Proposition 4.9 (adaptively chosen questions; rehearsal). PROVED** (a consequence of Theorem R1 of `note.md`). Assume A1 to A3, P ∈ H, and that P never violates R. Let the questions x_1, …, x_n be chosen in any way that depends on the earlier data and on fresh randomness, and let M^(t) be the mixture before question t. Then

 Σ_{t=1}^n E[v_{M^(t)}(x_t)] ≤ Σ_{t=1}^n E[ln(1/(1 − v_{M^(t)}(x_t)))] ≤ K ln 2.

Under the rehearsal protocol of `note.md`, Section 2, the expected number of calls of a run answered by M^(T), T uniform on {1, …, n}, whose answer violates R is at most L·K ln 2/n.

*Proof.* Let p be a probability on Y with p(R_x) = 1 and q a semimeasure on Y. By the log-sum inequality, KL(p‖q) = Σ_{y∈R_x} p(y)·ln(p(y)/q(y)) ≥ ln(1/Σ_{y∈R_x} q(y)) ≥ ln(1/(1 − v_q(x))). Apply this with p = P(·|x_t) and q = M^(t)(·|x_t), and use the regret bound Σ_t E[KL(P(·|x_t)‖M^(t)(·|x_t))] ≤ K ln 2 for adaptively chosen questions, which is the first step of the proof of Theorem R1 (`note.md`, Section 3.1; `proofs/hellinger-runs.md`, Appendix A; `proofs/rehearsal-core.md`, Theorem 5.1). For the rehearsal protocol, Theorem R1 itself bounds Σ_t E[Σ_{calls x of the run of round t} KL(P(·|x)‖M^(t)(·|x))] by L·K ln 2; the expected number of violating calls of a run answered by M^(t) is E Σ_{calls x} v_{M^(t)}(x), because each call is answered by a fresh draw from M^(t). ∎

So for the mixture the price of a property that the human never violates is at most K, with the fast rate 1/n. Theorem 4.5 (a class with designed weights) and Theorem 4.11(B) (classes of all programs of suitable universal machines) show that K cannot in general be replaced by a function of the price of R and of the closure constant C_R. (The prover's sentence cited Theorem 4.11 as it then stood; on the machine built there the property is not cheap. See Theorem 4.11.)

*The proposition uses Theorem R1 only through its first step*, the regret bound for adaptively chosen questions; the check report verified that step with exact expectations (its entry for Proposition 4.9), and the full proof of R1 is in `proofs/rehearsal-core.md`, Theorem 5.1, and in `proofs/hellinger-runs.md`, Appendix A.

### 4.4 One abiding explanation in the class ends the phenomenon

**Proposition 4.10 (memorisers and a coin, exact). PROVED.** Let 0 < γ < 1. Let H_mem^coin be the class H_mem of Theorem 4.5 with all weights multiplied by 1 − γ, together with one more index: the fair coin, which answers 0 or 1 with probability 1/2 each at every input, with weight γ. For a data set D_n of n pairs (x_i, f(x_i)) with k distinct inputs:

(a) M(D_n) = (1 − γ)·[2^(−K) + (1 − 2^(−K))·(4u + 2)^(−k)] + γ·2^(−n).
(b) For x not among the inputs: v_{M_{D_n}}(x) = (2u/(2u + 1))·(1 − γ)·(1 − 2^(−K))·(4u + 2)^(−k)/M(D_n).
(c) V(D_n) ≤ ((1 − γ)/γ)·2^n·(4u + 2)^(−k). If the n inputs are distinct, V(D_n) ≤ ((1 − γ)/γ)·(2u + 1)^(−n), which is at most 2^(−j) as soon as n ≥ (log₂(1/γ) + j)/log₂(2u + 1).
(d) If the n inputs are distinct and (1 − γ)·(2u + 1)^(−n) ≤ γ·2^(−j) and (1 − γ)·2^(n−K) ≤ γ·2^(−j), then the coin has posterior weight at least 1/(1 + 2^(1−j)).

For u = 2²⁰, K = 1000 and γ = 2⁻²⁰ the values of V after n = 0, 1, 2, 3 distinct inputs are 1.00, 0.33, 2.4·10⁻⁷, 1.1·10⁻¹³ (Section 9), against 0.999958 after 44 inputs without the coin.

*Proof.* The coin gives every data set of n pairs with answers in {0, 1} the likelihood 2^(−n), and it never answers b; the rest is Theorem 4.5. For (d): the posterior weight of the coin is γ·2^(−n)/M(D_n), and the two conditions say that each of the other two terms of M(D_n) is at most 2^(−j)·γ·2^(−n). ∎

*Reading.* In this class the mixture keeps the property R after about log₂(1/γ)/log₂(2u + 1) questions: the coin never violates R and loses one bit per pair against the human, where the memorisers lose β bits per pair. Until n is about K − log₂(1/γ), the coin holds most of the posterior weight by (d), so at a fresh input the mixture answers 0 or 1 at random: it abides by R and is at total variation about 1/2 from the human. The mixture has learned the property long before it has learned the human, because the class contains a cheap explanation of the data that abides by R, and not because R is simple. Theorem 4.7(g) with M(D_n) ≥ w(S)·S(D_n) is the general form: if some hypothesis S loses ℓ_S bits per pair against the human (P(D_n)/S(D_n) = 2^(n·ℓ_S)), then the hypotheses that violate R at a fresh input with probability at least 1 − 2^(−ℓ_S−η) have posterior weight at most 2^(K(S)−nη)/δ, which is small once n exceeds (K(S) + log₂(1/δ))/η.

### 4.5 The class of all programs and the reference machine (Pr2(c))

**Theorem 4.11 (a universal reference machine does not prevent the phenomenon). (A) PROVED. (B) PROVED; added from the check report, because (A) alone does not carry the reading that the prover gave it.**

*(A) Memorisers added to any class.* Let u ≥ 5, X = {1, …, u}, let Y contain 0, 1 and b, and R := {(x, y) : y ≠ b}. Let (H₀, w₀) be any class of samplers with Σ w₀ ≤ 1, for instance all programs of a universal language with w₀ = 2^(−length). For an integer c ≥ 1 let H_c be the disjoint union of H₀ and of the memorisers g_T of Theorem 4.5, with the weights w(ν) := 2^(−c)·w₀(ν) for ν ∈ H₀ and w(g_T) := (1/4)·(4u)^(−|T|). Then Σ w ≤ 2^(−c) + (1/4)·(1 + 1/(2u))^u < 1. Let f: X → {0, 1} be any function and D a data set of pairs (x, f(x)) with k distinct inputs. For every x not among the inputs of D,

 v_{M_D}(x) ≥ M_D(b|x) ≥ (2u/(2u + 1)) / (1 + 2^(2−c)·(4u)^k),

and for the uniform law μ on X, V(D) ≥ ((u − k)/u)·(2u/(2u + 1)) / (1 + 2^(2−c)·(4u)^k). In particular **V(D_n) ≥ (3/4)·(10/11)·(4/5) > 0.54 for every data set of n ≤ min{u/4, (c − 4)/log₂(4u)} pairs.**

*Proof.* As in Theorem 4.5, the consistent memorisers have total weight W_m := (1/4)·(4u)^(−k)·(1 + 1/(2u))^(u−k) ≥ (4u)^(−k)/4, and those whose table does not contain x have weight W_m·2u/(2u + 1). All other hypotheses have total weight at most 2^(−c) and likelihood at most 1. So M(D) ≤ W_m + 2^(−c) and M_D(b|x) ≥ W_m·(2u/(2u + 1))/(W_m + 2^(−c)) = (2u/(2u + 1))/(1 + 2^(−c)/W_m). If k·log₂(4u) ≤ c − 4, then 2^(2−c)·(4u)^k ≤ 1/4. ∎

*The machine U′ (the prover's reading of (A)), and why it is not enough.* Let u = 2^d, let the inputs be the strings of d bits, and let (H₀, w₀) be the class of all programs of a universal prefix machine U. Define the machine U′ by U′(1^c p) := U(p), and U′(0q) := g_T when q = q(T) := (1 x_1 t_1)(1 x_2 t_2)…(1 x_k t_k) 0 lists the entries of the table T with x_1 < … < x_k and t_i = T(x_i). The programs of U′ form a prefix-free set, ℓ(0q) = 2 + |T|·(d + 2), so 2^(−ℓ(0q)) = (1/4)·(4u)^(−|T|), and U′ is universal: K_{U′} ≤ K_U + c. The class of all programs of U′ is H_c. Hence for every universal machine U and every c there is a universal machine U′, with K_{U′} ≤ K_U + c, for which the mixture answers b with probability above 1/2 at a fresh input, for every human f: X → {0, 1}, for all n ≤ min{u/4, (c − 4)/(d + 2)}.

This does not separate the price K of the human from the price of the property (the main finding of the check report; confirmed by the attack report and by the editor). The price of R that matters is its price on the machine of the class (in Remark 4.4 the decider r is a program of the same language). On U′ every program that decides R, and every program for a conditioned memoriser, has the form 1^c p. So K_{U′}(R) ≥ c + 1, which is more than the number (c − 4)/(d + 2) of questions for which (A) speaks: a bound such as V(D_n) ≤ (K_{U′}(R)·ln 2 + ln(1/δ))/n is not contradicted, because at n = (c − 4)/(d + 2) its right side exceeds (d + 2)·ln 2 > 1. And the constant of (Cl_R) for the class of all programs of U′ is at least 2^(c−1): the memoriser with the empty table has weight 1/4, and its conditioning, the sampler that never answers, is named only by programs 1^c p, each of weight at most 2^(−c−1). Part (B) gives the decider of R and the conditioned memorisers short programs of their own.

*(B) The machine U″.* Let U be a universal prefix machine whose programs name samplers, as in Remark 4.4. Let d ≥ 3, u := 2^d, and let c ≥ 5 be an integer. The inputs are all binary strings; X_d := {0, 1}^d, μ is the uniform law on X_d, and a pair (x, y) is coded by a string that does not lie in X_d. The answers include 0, 1 and b, and R := {(x, y) : y ≠ b}. Tables are tables on X_d: g_T answers T(x) for x ∈ dom T and b at every other input, and h_T answers T(x) on dom T and gives no answer at every other input, so that g_T^R = h_T. With q(T) the code of the table as above (its length is |T|·(d + 2) + 1), define

 U″(1^c p) := U(p),  U″(00 q(T)) := g_T,  U″(011000 q(T)) := h_T,  U″(010000) := r₀,

where r₀ is the program that, given the code of a pair (x, y), answers 1 if y ≠ b and 0 if y = b, and gives no answer at every other input, in particular at every x ∈ X_d. Then:

(B1) The programs of U″ form a prefix-free set. Their weights 2^(−length) are 2^(−c)·2^(−ℓ(p)) for 1^c p, (1/8)·(4u)^(−|T|) for g_T, (1/128)·(4u)^(−|T|) for h_T and 2^(−6) for r₀, with a sum of at most 2^(−c) + (1/8 + 1/128)·(1 + 1/(2u))^u + 1/64 < 2^(−c) + 0.24 < 1. U″ is universal, K_{U″} ≤ K_U + c, and **K_{U″}(R) ≤ 6 for every c**: the program 010000 decides R.

(B2) Suppose that the class of all programs of U satisfies (Cl_R) by an injective map p ↦ φ_r(p) with ℓ(φ_r(p)) = ℓ(p) + K_U(R) + c_U, where c_U depends on U only (Remark 4.4; standard facts that are not proved in this file). Then the class of all programs of U″ satisfies (Cl_R) with **C_R = max{17, 2^(K_U(R)+c_U)}, which does not depend on c.**

(B3) For every f: X_d → {0, 1}, every data set D of pairs (x, f(x)), x ∈ X_d, with k ≥ 1 distinct inputs, and every x ∈ X_d not among them,

 v_{M_D}(x) ≥ M_D(b|x) ≥ (16/17)·(2u/(2u + 1)) / (1 + 2^(3−c)·(4u)^k).

Hence **V(D_n) ≥ (3/4)·(16/17)·(10/11)·(4/5) > 0.51 for every data set of 1 ≤ n ≤ min{u/4, (c − 5)/(d + 2)} pairs**, and V ≥ 0.70 for the empty data set.

*Proof of (B).* (B1) A code word begins with 1 (then it is 1^c p, and these are prefix-free among themselves because the programs of U are), with 00, with 010000 or with 011000. The code q(T) is self-delimiting: each entry has d + 2 bits and begins with 1, and the code ends with 0. So no code word is a prefix of another. As in Theorem 4.5, Σ_T (4u)^(−|T|) = (1 + 1/(2u))^u < e^(1/2). (B2) Put φ(1^c p) := 1^c φ_r(p), φ(00 q(T)) := φ(011000 q(T)) := 011000 q(T) and φ(010000) := 010000. Each image names the conditioned sampler: for the programs of U by assumption; g_T^R = h_T and h_T^R = h_T as in Corollary 4.6; and r₀ never answers b, so r₀^R = r₀. The preimages of the index 011000 q(T) have total weight (1/8 + 1/128)·(4u)^(−|T|), which is 17 times its weight; the index 010000 has itself as its only preimage; an index 1^c p′ has at most one preimage, of weight 2^(K_U(R)+c_U) times its own; an index 00 q has none. (B3) As in Theorem 4.5, the g_T that are consistent with D have total weight W := (1/8)·(4u)^(−k)·(1 + 1/(2u))^(u−k) ≥ (4u)^(−k)/8, and those among them whose table does not contain x have weight W·2u/(2u + 1). The consistent h_T have weight W/16 and never answer b. The program r₀ gives no answer at the inputs of D, so its likelihood is 0 for k ≥ 1. All programs 1^c p together have weight at most 2^(−c) and likelihood at most 1. So M(D) ≤ (17/16)·W + 2^(−c), and

 M_D(b|x) ≥ W·(2u/(2u + 1))/((17/16)·W + 2^(−c)) ≥ (16/17)·(2u/(2u + 1))/(1 + 2^(−c)/W), with 2^(−c)/W ≤ 2^(3−c)·(4u)^k.

If k·(d + 2) ≤ c − 5, the last quantity is at most 1/4. A data set of n pairs has k ≤ n distinct inputs, the bound decreases in k, (u − k)/u ≥ 3/4 for k ≤ u/4, and 2u/(2u + 1) ≥ 10/11. For the empty data set, M ≤ (17/16)·W₀ + 2^(−6) + 2^(−c) with W₀ := (1/8)·(1 + 1/(2u))^u ≥ 0.2013, so V ≥ W₀·(10/11)/((17/16)·W₀ + 2^(−6) + 2^(−5)) ≥ 0.70. ∎

*Who checked (B).* The construction and the three claims are the check report's (its entry for Theorem 4.11), where they were verified by enumeration for u = 8 with random semimeasures in place of the programs of U and in closed form for 3 ≤ d ≤ 20 and 5 ≤ c ≤ 1000 (`property-batch_check_sec4.out`, block 9). The attack report found the same repair independently and recomputed the three claims by hand. The editor wrote out the proof above and enumerated the class for d = 3 with the worst case for the programs of U, namely all their weight on one hypothesis that fits the data and never answers b (`property-batch_editor.out`, block (E6)).

*What (B) shows.* For every universal machine U there are universal machines U″, as far from U as one likes, on which the property "the answer is not b" has a program of 6 bits and the class of all programs is closed under conditioning on it with a constant that does not grow with c, and on which the mixture violates the property at a fresh input with probability above 1/2 for (c − 5)/(d + 2) questions, for every human f: X_d → {0, 1}. Consequently **no bound of the form V(D_n) ≤ G(K(R), C_R, δ, n), with G nondecreasing in its first two arguments and tending to 0 as n grows, holds on all universal machines**, where the price K(R) and the closure constant C_R are measured on the machine of the class. (Fix δ and put C₀ := max{17, 2^(K_U(R)+c_U)}, which depends neither on c nor on d. Choose n* with G(6, C₀, δ, n*) < 0.51, then d with 2^d ≥ 4n*, then c ≥ 5 + n*·(d + 2). On the machine U″ with these d and c, V(D_{n*}) > 0.51 for every data set, while the bound would give at most G(6, C₀, δ, n*).) If f is simple for U, say K_U(f) = k₀, then K := K_{U″}(f) ≤ k₀ + c, and the statement covers all n ≤ min{u/4, (K − k₀ − 5)/(d + 2)}: all n up to the order of K divided by the bits per pair.

*What (B) does not show.* That the mixture of a reference machine which somebody would choose behaves in this way: U″ is built for the purpose, and the statement is a fact about the prior (remark (3) after Theorem 4.5). For each machine of this kind the phenomenon ends after a number of questions that is a constant of the machine (4.13, items 5 and 6), and for one fixed machine nothing is refuted (4.13, item 4).

**Proposition 4.12 (a simple abiding source protects its typical members, whatever the class and the machine). PROVED.** Let (H, w) be any class and S ∈ H a sampler with Σ_y S(y|x) = 1 that never violates R. Let F be a random function with independent values F(x) ∼ S(·|x), x ∈ X, and let the human answer F(x) at x. Let x_1, x_2, … be independent with law μ and independent of F, and V(D_n) as in Theorem 4.7(c). Then for δ ∈ (0, 1), with probability at least 1 − δ over F and the inputs, for every n ≥ 1: two of the inputs x_1, …, x_n coincide, or

 V(D_n) ≤ (K(S)·ln 2 + ln(1/δ))/n.

*Proof.* Let n₁ be the first n with x_n ∈ {x_1, …, x_{n−1}} (n₁ := ∞ if there is none). Given the inputs, the answers F(x_1), …, F(x_n) at distinct inputs are independent with laws S(·|x_i). So the sequence (D_n)_{n<n₁} has the same law as in the experiment in which the human is the sampler S itself and the inputs are the same. In that experiment A1 and A2 hold with P = S, and Theorem 4.7(b) and (d) give probability at least 1 − δ that V(D_n) ≤ (K(S) ln 2 + ln(1/δ))/n for all n ≥ 1. The event "the bound fails for some n < n₁" is a function of (D_n)_{n<n₁} and so has the same probability in both experiments. ∎

The complexity of the human does not enter: F is typically not computable when S is not deterministic. For the humans of Theorem 4.5 this says: if the class contains the fair coin with weight 2^(−k_c) (as the class of all programs does for every universal machine, with k_c depending on the machine), then for all but a fraction δ of the pairs (function f, sequence of inputs), the mixture violates R at a fresh input with probability at most (k_c·ln 2 + ln(1/δ))/n as long as no input has repeated. For the machines U′ and U″ of Theorem 4.11, k_c is about c, in agreement with that theorem.

**4.13 What can be proved about the class of all programs.**

1. *For every reference machine* (**PROVED**, given the standard facts of Remark 4.4): for all data that abide by a decidable R, the mixture violates R with probability at most 1 − 2^(−K(R)−c) at every input (Corollary 4.3(c), Remark 4.4), and at most ln 2·(K(R) + c) times in expectation over the inputs already seen (Corollary 4.3(a)). The first bound is a statement about the semimeasure: the remaining probability 2^(−K(R)−c) may be the probability of giving no answer (Remark 4.14).
2. *For every class* (**PROVED**): at a fresh input from the law of the data, the violation probability is at most (K*·ln 2 + ln(1/δ))/n, where K* := min_{S∈H} [K(S) + log₂(P(D_n)/S(D_n))] is the length of the cheapest two-part description of the answers, measured against the human's own law (Theorem 4.7(e)); K* ≤ K when the human is in the class. A violation probability v requires K* ≥ n·log₂(1/(1 − v)) − log₂(1/δ) (Theorem 4.7(f)).
3. *Universality of the machine gives nothing more* (**PROVED**): by Theorem 4.11(B) no bound on the violation probability at a fresh input in terms of the price of R and the closure constant, both measured on the machine of the class, holds on all universal machines.
4. *One fixed machine* (**OPEN**; reworded by the editor after the attack report, Finding M3). A statement about "natural" reference machines needs a definition of the word that excludes the machines of Theorem 4.11, and without one it is not a mathematical question. For each fixed universal machine U the following is one: *is there a constant c_U such that for every decidable R, every human in the class that never violates R and every law μ, with probability at least 1 − δ, V(D_n) ≤ ((c_U + K_U(R))·ln 2 + ln(1/δ))/n for all n?* Theorem 4.11(B) shows that c_U cannot be bounded in terms of the constants that govern hindsight on the machine: on U″, where K(R) ≤ 6 and C_R does not depend on c, the bound V > 0.51 at n₀ := ⌊(c − 5)/(d + 2)⌋ questions forces c_{U″} ≥ 0.74·n₀ − 1.45·ln(1/δ) − 6. It does not refute the statement for any machine, and neither report nor the editor proves it for any machine. By item 2 the statement would follow from a bound on K*, that is, from the existence of a simple program that predicts the human's answers on fresh inputs about as well as the human's own law does. This is an assumption about the human and the machine together. It holds for humans who are typical members of a simple source (Proposition 4.12). I do not know a way to derive it from the simplicity of R. A bound that also involves the composition constant of the machine is not excluded by the machines of Theorem 4.11, on which that constant is about c.
5. *Every machine with a cheap coin* (**PROVED**; added from the check report, entry for Theorem 4.11; verified by the editor, `property-batch_editor.out`, block (E7)). Let the class contain the fair coin on {0, 1} with weight 2^(−k_c), let the human be any function f: X → {0, 1}, whatever its complexity and whether or not it is in the class, and let R be a property that f does not violate on the support of μ. Then with probability at least 1 − δ over the inputs, for all n ≥ 1:

 1 − V(D_n) ≥ ½·(δ·2^(−k_c))^(1/n), hence V(D_n) ≤ ½ + (k_c·ln 2 + ln(1/δ))/(2n).

 *Proof.* Theorem 4.7(c) with P(D_n) = 1 and M(D_n) ≥ 2^(−k_c)·2^(−n); and 1 − ½·e^(−a/n) ≤ ½ + a/(2n) for a ≥ 0. ∎ So on a machine with a cheap coin no human with binary answers holds the mixture at a violation level much above 1/2 for long. On U′ and U″ the coin costs about c bits, in agreement with Theorem 4.11. The bound does not bring the level below 1/2; that needs a cheap hypothesis that predicts the answers nearly as well as the human does (item 2), as for the typical functions of Proposition 4.12.
6. *On the machines of Theorem 4.11 the added memorisers lose to the coin after a number of questions that is a constant of the machine* (**PROVED**; attack report, Finding M3, fact 2; recomputed by the editor). Let the fair coin be a program of length k_c for U, hence of length c + k_c for U′ and U″. On a data set of n pairs with distinct inputs and answers in {0, 1} the coin has likelihood 2^(−n), and the memorisers that are consistent with the data have total weight at most (1/4)·e^(1/2)·(4u)^(−n) ≤ 0.42·2^(−n(d+2)) on U′ and at most 0.22·2^(−n(d+2)) on U″. So their share of the posterior is at most 0.42·2^(c + k_c − n(d + 1)), for every human with answers in {0, 1}. On a fixed machine of this kind the phenomenon is over after about (c + k_c)/(d + 1) questions; what the mixture does afterwards is decided by the programs of U, about which nothing is proved here.

### 4.6 Silence in the floor, and a conditioning that always answers

This subsection was added by the editor from the attack report (Finding m5 and Proposition X3). The editor re-derived both statements; no second verifier examined them.

**Remark 4.14 (the floor of Corollary 4.3(c) may be made of silence).** Definition 4.1 counts "no answer" as not violating, and Remark 4.4 explains why it must do so for the class of all programs. Two consequences.

(i) "The never-violators have posterior weight at least 1/C_R" does not say that the mixture gives an abiding answer with probability at least 1/C_R. In the closed class of Corollary 4.6 with u = 4, K = 30, C_R = 5 and one pair seen, the mixture at an unseen input gives a violating answer with probability 0.7111, no answer with probability 0.1778 and an abiding answer with probability 0.1111. (Up to terms of order 2^(−25) these are (4/5)·(8/9), (1/5)·(8/9) and 1/9: the memorisers hold all but about 18·2^(−30) of the posterior, the fraction 2u/(2u + 1) = 8/9 of their weight has a table that does not contain the input, and the fraction C/(C + 1) = 4/5 of that answers b.) If the mixture is normalised over the answers given, as it is when a hypothesis is drawn from the posterior again and again until one answers, it violates R with probability 0.7111/(0.7111 + 0.1111) = 0.865, which is more than 1 − 1/C_R = 0.8. For C_R = 100 the three numbers are 0.8800, 0.0089 and 0.1111, and the normalised violation probability is 0.888. (Attack report, Finding m5(a), `property-batch_attack_pr2.out`, block B; recomputed by the editor by enumeration of the class in exact rationals, `property-batch_editor.out`, block (E4).) So the floor is a statement about the semimeasure. In the researcher's terms it does not pass the rock test: a hypothesis that falls silent wherever it has no data counts as abiding.

(ii) In the model of `note.md`, Section 1, a sampler gives an answer at every input, and the class is a set of samplers. For such a ν with v_ν(x) = 1 at some x, the conditioned ν^R gives no answer at x and is not a sampler in that sense. So a class of samplers that always answer and that contains one such ν does not satisfy (Cl_R) for any constant. Theorem 4.2 and Corollary 4.3 are statements for classes that admit hypotheses which may give no answer. The next proposition is a form for classes of samplers that always answer.

**Proposition 4.15 (a conditioning that always answers). PROVED** (statement and proof from the attack report, Proposition X3; re-derived by the editor; checked in that report on 1161 random classes, `property-batch_attack_pr2.out`). Let G be a sampler with Σ_y G(y|x) = 1 that never violates R (so R_x is not empty for any x), and let θ ∈ (0, 1]. For a sampler ν put

 ν^{R,θ}(y|x) := [ν(y|x)·1[(x, y) ∈ R] + θ·v_ν(x)·G(y|x)] / (1 − (1 − θ)·v_ν(x)).

It is the law of the procedure "draw an answer from ν; if it does not violate R, give it; if it violates R, give an answer of G with probability θ and otherwise start again". If Σ_y ν(y|x) = 1, then Σ_y ν^{R,θ}(y|x) = 1; ν^{R,θ} never violates R; and ν^{R,θ}(y|x) ≥ ν(y|x)/(1 − (1 − θ)·v_ν(x)) ≥ ν(y|x) for every pair (x, y) ∈ R. Suppose that the class is closed under ν ↦ ν^{R,θ} with constant C: there is a map φ: H → H such that φ(ν) names ν^{R,θ} for every ν, and Σ_{ν : φ(ν)=ν′} w(ν) ≤ C·w(ν′) for every ν′ ∈ H. Then for every data set D_n that abides by R and has M(D_n) > 0:

(a) Σ_ν w_{D_n}(ν)·Π_{i≤n} 1/(1 − (1 − θ)·v_ν(x_i)) ≤ C; hence, for θ < 1, Σ_{i≤n} v_{M_{D_n}}(x_i) ≤ ln C/(1 − θ);
(b) the indices in φ(H) have posterior weight at least 1/C; they never violate R, and those that are images of samplers that always answer are samplers that always answer. So in a class of samplers that always answer, the mixture M_{D_n} gives an answer that abides by R with probability at least 1/C at every input, seen or not.

*Proof.* The denominator is at least θ > 0. One round of the procedure gives the answer y with probability ν(y|x)·1[(x, y) ∈ R] + v_ν(x)·θ·G(y|x), starts again with probability (1 − θ)·v_ν(x), and ends with no answer with probability 1 − Σ_y ν(y|x). Summing the geometric series gives the formula. If Σ_y ν(y|x) = 1, the numerators sum to (1 − v_ν(x)) + θ·v_ν(x), which is the denominator. G never violates R, so ν^{R,θ} does not, and the lower bound for pairs in R is read off the formula. (a) For abiding data, φ(ν)(D_n) ≥ ν(D_n)·Π_i (1 − (1 − θ)·v_ν(x_i))^(−1). Summing over ν with the weights w(ν) and grouping by the image, as in the proof of Theorem 4.2: Σ_ν w(ν)·ν(D_n)·Π_i (1 − (1 − θ)·v_ν(x_i))^(−1) ≤ Σ_ν w(ν)·φ(ν)(D_n) ≤ C·M(D_n). The count of violations follows by Jensen's inequality for the logarithm and ln(1/(1 − (1 − θ)·v)) ≥ (1 − θ)·v. (b) As for Corollary 4.3(c): Σ_{ν′ ∈ φ(H)} w(ν′)·ν′(D_n) ≥ (1/C)·Σ_ν w(ν)·φ(ν)(D_n) ≥ M(D_n)/C, because φ(ν)(D_n) ≥ ν(D_n) for abiding data. ∎

With θ = 1 the map is the filter "replace a violating answer by an answer of G"; then (a) is empty and (b) remains. With θ = 1/2 both hold, at twice the count of Corollary 4.3(a). For the class of all programs, a decidable R with R_x never empty and a computable G, the procedure is a program of length ℓ(p) + ℓ(r) + ℓ(g) + c, so that C = 2^(K(R)+K(G)+c) (standard facts of the kind of Remark 4.4, not proved here); G may be "the first answer, in a fixed enumeration, that does not violate R", which is computed from a decider of R. Like Corollary 4.3(c), statement (b) does not improve with n.

---

## 5. The two prices side by side

### 5.1 The two guarantees

Both use N independent recorded runs of the human system. K(R) := log₂(1/π(R)) is the price in bits of a test R, and K the description length of the human. "Theorem A" is the theorem on recorded runs of `proofs/hellinger-runs.md`, Theorem 4.2; in the note it is called H1.

| | all properties at once | one property at a time |
|---|---|---|
| what is guaranteed | TV(law of the imitator's run, Q) ≤ ε: every event of runs has a probability within ε of its probability in the human system (Statement 2.0) | \|Q′(R) − Q(R)\| ≤ ε_R for every test R of the family, simultaneously |
| error | in expectation √(K ln 2/(2N)) (Theorem A: `proofs/hellinger-runs.md`, Theorem 4.2(c)); with probability 1 − δ: √((2K ln 2 + 2 ln(2/δ))/N) (Corollary 3.7(a)) | with probability 1 − δ: ε_R = √(2(K(R) ln 2 + ln(2/δ))/N); and Q′(R), Q(R) ≤ (K(R) ln 2 + ln(2/δ))/N for a test that never occurred in the data (Corollary 2.6) |
| which imitator | Theorem A: for each run, a hypothesis drawn from the posterior given a uniformly random number of the recorded runs; Corollary 3.7: the penalised minimum-distance estimate | any imitator whose run law lies in 𝓜_N (matches the empirical frequencies of all tests) |
| assumptions | Theorem A: A1 and A2. Corollary 3.7(a): (IID) and the human system in the class. Outside the class an approximation term is added (Theorem 3.6 here; part (b) of Theorem A in the cited file) | (IID) only, which includes that the human does not change between runs: no class, no statelessness within a run, no computability |
| says nothing when | N ≤ K ln 2/2 (the bound of Theorem A is at least 1) | K(R) ln 2 + ln(2/δ) ≥ N/2 (then ε_R ≥ 1); and for every property outside the family |
| what the human must do | N whole runs of the scaffold, up to N·L answers, by a human who is the same in every run | the same: N whole runs. (The certificate of Section 6 needs m single answers and no run of the human system, and certifies per-call tests only.) |

The last row was added after the attack report (its Finding w6 and its Section 2, "budget"): it is the one cost that the researcher counts. In numbers, from the bounds of this file with δ = 0.05: a property of 50 bits that never failed is certified to hold with frequency 0.99 once N ≥ (50·ln 2 + ln 40)/0.01 = 3835 runs; a two-sided tolerance of 0.05 for one such test needs N ≥ 2·38.35/0.05² = 30 677 runs; total variation 0.1 at K = 10⁶ bits needs N ≥ 1.4·10⁸ runs (Corollary 3.7(d)). These are statements for scaffolds small enough for a person to run thousands of times. For larger scaffolds what remains is the per-call certificate (Theorem 6.1) and the online rule of the part property-online.

The first guarantee implies the second for every test at the first price (Statement 2.0). For N below about K only the second says anything, and it then covers the tests of price well below N. When the human system is in the class, the estimate of Proposition 3.8 has both guarantees at once; outside the class no single rule is shown here to have both (Theorem 3.6 is for total variation and uses the penalised estimate, Proposition 3.9 is for tests and uses another selection rule). Neither price can be lowered in general: for the first see `proofs/lower-bounds.md`, Theorems 6.1 and 6.3 (a class of 2^K samplers for which every protocol has expected total variation of order √(K/n); the prover did not check that file; the check report of this part took over the verdicts of `research/verify/lower-bounds-check.md`, which has both as correct), and for the second Lemma 2.8.

Of the two prices only the first says anything about being the sampler and not one of its fill-ins (the researcher's "copy" test; attack report, Section 2): a class that contains both a sampler P₀ and a function f drawn from it separates them after about K(f) recorded runs, by the set of runs in which the answer equals f(x); test matching cannot (Proposition 5.2, Theorem 6.2). And the first price is the one that is empty for a person.

### 5.2 What an imitator that satisfies only the second guarantee can get wrong

**Proposition 5.2 (tests of small total price do not see what is complex). PROVED.** Let the scaffold make one call: an input x is drawn from a law μ on X and put to the answerer, so that a run is a pair (x, y) and Q_S(R) = Σ_x μ(x)·S(R_x|x) for a sampler S and a set R of pairs. Put coll(μ) := Σ_x μ(x)², the probability that two independent draws from μ coincide (1/u for the uniform law on u inputs). Let P₀ be a sampler with Σ_y P₀(y|x) = 1, and let F be a random function with independent values F(x) ∼ P₀(·|x); Q_F denotes the run law of the deterministic sampler that answers F(x). Let (𝓣, π) be a test family and η ∈ (0, 1). Then:

(a) with probability at least 1 − η over F, for all R ∈ 𝓣: |Q_F(R) − Q_{P₀}(R)| ≤ √(coll(μ)·ln(2/(π(R)η))/2);
(b) for every F: TV(Q_F, Q_{P₀}) = Σ_x μ(x)·(1 − P₀(F(x)|x)) ≥ 1 − Σ_x μ(x)·max_y P₀(y|x).

In particular, for the uniform law on u inputs and the fair coin P₀ on {0, 1}, there is a function f: X → {0, 1} with

 |Q_f(R) − Q_coin(R)| ≤ √(ln(2/(π(R)η))/(2u)) for every R ∈ 𝓣, and TV(Q_f, Q_coin) = 1/2.

*Proof.* (a) For fixed R, Q_F(R) = Σ_x μ(x)·1[(x, F(x)) ∈ R] is a sum of independent random variables; the x-th lies in [0, μ(x)] and has mean μ(x)·P₀(R_x|x), so E Q_F(R) = Q_{P₀}(R). By Hoeffding's inequality for independent bounded summands (W. Hoeffding, 1963, cited after Lemma 2.1, Theorem 2 there; standard, quoted from memory; for infinite X apply it to finite partial sums and pass to the limit), Pr[|Q_F(R) − Q_{P₀}(R)| ≥ t] ≤ 2·exp(−2t²/Σ_x μ(x)²). With t := √(coll(μ)·ln(2/(π(R)η))/2) the right side is π(R)·η; sum over R. (b) Both laws have the marginal μ on x, so the total variation is the μ-average of TV(point mass at F(x), P₀(·|x)) = 1 − P₀(F(x)|x). ∎

*Consequence.* Let the human be such a function f, let the imitator be the coin, let N ≤ u, and take η = δ. Then |Q_coin(R) − Q_f(R)| ≤ √(N/u)·tol_N(R) ≤ tol_N(R) for every R ∈ 𝓣. So the guarantee that Corollary 2.6 gives for the members of 𝓜_N, namely |Q′(R) − Q(R)| ≤ 2·tol_N(R), is met by the coin with room to spare. And the coin gives an answer different from the human's with probability 1/2 at every input. The property that it gets wrong is "y = f(x)": being right. This property has probability 1 in the human system and 1/2 for the coin. A test family cannot make up for this by containing the graphs: tol_N(R) < 1 requires π(R) > (2/δ)·e^(−2N), at most (δ/2)·e^(2N) tests have such a weight, and for u ≥ 3N this is a fraction below 2^(−N/10) of the 2^u functions. Whenever being right has no test that is much simpler than the human, an imitator that satisfies only the second guarantee may be an answerer that is right at the rate of chance and passes every simple test at the human's rate. (The counting argument is the one of Trevisan, Tulsiani and Vadhan for "regularity" of arbitrary functions, as reported in `research/understand/indistinguishability.md`, Section 4.1; I did not read that paper. The digest's Lemma I1a gives two further imitators of this kind; I did not check it.)

*Attribution* (added by the editor from the attack report, Finding M2(a); the passages were read in the source by the attack report and again by the editor). The content of Proposition 5.2, and of Theorem 6.2 below, is an observation with which the work on outcome indistinguishability begins. Dwork, Kim, Reingold, Rothblum and Yona, "Outcome indistinguishability", arXiv:2011.13426v1, Section 1: "Given only observations of outcomes, we cannot even determine whether Nature assigns integer or non-integer probabilities. Perhaps Nature is deterministic, but we do not have enough information or computing resources to carry out the predictions ourselves." Their example (Section 1.1): Nature selects p*_i = 1 for half of the mass of the individuals and p*_i = 0 for the remainder; if no efficient observer can tell the two sets apart, then "producing the estimates p̃_i = 1/2 for every individual" is the best feasible model. Their Section 4, where multi-accuracy is reviewed, has the mirror image, which is the situation of Example 5.3: "if every individual i ∈ X has p*_i = 1/2, then a random boolean function that predicts p̃_i ∈ {0, 1} for each i ∈ X will satisfy multi-accuracy for C of bounded complexity." The human f against the coin, with weighted tests in the place of efficient observers, is this example. What this file adds: the explicit error term for a weighted family, the statement at every input, and the consequence for an imitator and for a certificate.

In a computation with u = 2¹² inputs and 1490 tests (conjunctions of one, two input bits and the answer; thresholds; parities of three bits), the largest difference |Q_f(R) − Q_coin(R)| over the tests and over 40 random f was 0.022, the bound of (a) is 0.036, and with N = u/4 recorded runs the coin was within tol_N = 0.071 of the empirical frequency of every test in 40 of 40 trials (Section 9).

**Example 5.3 (tests of single calls do not see how the calls of a run hang together). PROVED.** Let the scaffold draw z uniformly from X = {1, …, u} and make two calls, both with the input z (the same question is asked twice). Let the human be the fair coin at every call; in the human system the two answers agree with probability 1/2. Let the imitator be a function g: X → {0, 1}; its two answers always agree. For a set B ⊆ X × {0, 1} of pairs, the per-call frequencies of Section 6 are a(B) = (1/u)·Σ_z 1[(z, g(z)) ∈ B] for the imitator and h(B) = (1/u)·Σ_z ½·(1[(z, 0) ∈ B] + 1[(z, 1) ∈ B]) for the human on the imitator's inputs. By Proposition 5.2(a) there is, for every family (𝓑, π) and η, a function g with |a(B) − h(B)| ≤ √(ln(2/(π(B)η))/(2u)) for all B ∈ 𝓑. For this imitator every per-call test of the family has the human's frequency up to that error, and the event "the two answers agree", a test of runs of constant price, has probability 1 against 1/2. ∎

So per-call test matching (what Theorem 6.1 certifies, and what the online imitator Pr5 delivers) is strictly weaker than matching tests of runs (Section 2), and the difference shows already for the simplest tests of runs. Matching tests of runs needs recorded runs of the human system; here, the human answering the same question twice.

**Proposition 5.4 (the coin is a member of the matching set). PROVED** (statement and proof from the attack report, Finding m8 and Proposition X4; re-derived by the editor; exact values for small cases in `property-batch_attack_sec56.out`, block B). In the setting of Proposition 5.2 let the human be P_F, the deterministic sampler that answers F(x), with F random as there. Let (𝓣, π) be a test family, δ ∈ (0, 1), and let 𝓜_N be the matching set of Corollary 2.6 for N recorded runs of the system answered by P_F. Then with probability at least 1 − δ − C(N, 2)·coll(μ) over F and the runs, the run law Q_{P₀} lies in 𝓜_N.

*Proof.* The N recorded runs are the pairs (x_i, F(x_i)) with x_1, …, x_N independent with law μ. Given the inputs, the values of F at distinct inputs are independent with the laws P₀(·|x_i). So on the event that the N inputs are distinct, the recorded pairs have the same conditional law as N independent runs of the system answered by P₀ (this is the lazy sampling of a random function, as in the proof of Theorem 6.2(c)). For N independent runs with law Q_{P₀}, Theorem 2.3 with Q = Q_{P₀} says that Q_{P₀} ∈ 𝓜_N with probability at least 1 − δ. Two given inputs coincide with probability coll(μ), so the N inputs are distinct with probability at least 1 − C(N, 2)·coll(μ). Hence Pr[Q_{P₀} ∉ 𝓜_N] ≤ Pr[the inputs are not distinct] + Pr[the inputs are distinct and Q_{P₀} ∉ 𝓜_N] ≤ C(N, 2)·coll(μ) + δ. ∎

This sharpens the Consequence after Proposition 5.2. There the coin is shown to meet the conclusion of Corollary 2.6; here it is a member of 𝓜_N. So for N small against √u, a rule of the form "return any member of 𝓜_N" may return the coin when the human is a function, Corollary 2.6 is true of it, and it differs from the human at every call with probability 1 − P₀(F(x)|x), which is 1/2 for the fair coin.

**5.3 Summary of this section.** An imitator that satisfies only the second guarantee can be wrong (i) about every property whose price is of the order N or more, in particular about being right when being right has no short test (Proposition 5.2); (ii) if its tests are tests of single calls, about every property of how the calls of a run hang together (Example 5.3); and (iii) about everything outside the distribution of the recorded runs, like every other imitator (Theorem N1 of the note); (iv) it may be a replay of the recorded runs, or the human's sampler in the place of the human's function (Remark 2.7(6), Proposition 5.4); and (v) on a kind of input whose frequency is below the tolerance it may do anything and still match every test. Conversely the Bayes mixture, which pays the first price, need not pay only the second (Theorems 4.5 and 4.11). Neither guarantee contains the other at its own price.

---

## 6. The validation certificate, and what single answers can certify

### 6.1 The certificate V1(b) is Pr3 for single calls on the imitator's own inputs

**Setting.** A is any answerer, frozen before validation. The human answers single questions according to A1: the answer to x is a draw from P(·|x), independent of everything else given x; P need not be in any class. One *validation round* (as in `note.md`, Section 2): run the scaffold with A, giving τ ∼ Q_A; draw J uniformly from {1, …, L}, independently; if J ≤ len(τ), let x* := x_J(τ) be the probe input and a* := y_J(τ) the answer A gave to it, put x* to the human and record the answer h* ∼ P(·|x*). If J > len(τ) the round is empty. There are m independent rounds. For B ⊆ X × Y and round i put

 α_i(B) := 1[round i is not empty and (x*_i, a*_i) ∈ B], η_i(B) := 1[round i is not empty and (x*_i, h*_i) ∈ B],

with means

 a(B) := E α_i(B) = (1/L)·E_{Q_A}[#{j ≤ len(τ) : (x_j, y_j) ∈ B}],
 h(B) := E η_i(B) = (1/L)·E_{Q_A}[Σ_{j ≤ len(τ)} P(B_{x_j}|x_j)],

and Δ(B) := a(B) − h(B), the quantity of Theorem V1(b) of the note. ᾱ(B) and η̄(B) are the averages over the m rounds.

**Theorem 6.1 (V1(b)). PROVED; in form (b) the tolerance is half that of the note.** Let (𝓑, π) be a countable family of sets of pairs with weights π(B) > 0, Σ π ≤ 1, fixed before validation, and δ ∈ (0, 1).

(a) *Paired form (the statement of the note).* With probability at least 1 − δ, for all B ∈ 𝓑: |Δ(B) − (ᾱ(B) − η̄(B))| ≤ √(2 ln(2/(π(B)δ))/m).
(b) *The human's frequencies alone.* With probability at least 1 − δ, for all B ∈ 𝓑: kl(η̄(B) ‖ h(B)) ≤ ln(2/(π(B)δ))/m. Consequently |η̄(B) − h(B)| ≤ √(ln(2/(π(B)δ))/(2m)), with the sharper forms of Corollary 2.4 for rare tests; and if the human's answer never fell in B during validation, h(B) ≤ ln(2/(π(B)δ))/m. The number a(B) is determined by A and the scaffold; no answer of the human enters it. In a closed system it can be computed, or estimated to any accuracy by simulated runs. So (b) certifies Δ(B) to within √(ln(2/(π(B)δ))/(2m)).
(c) *It is Theorem 2.3.* The validation rounds are m independent runs of the human system of a derived scaffold of horizon 1, whose top-level input is the pair (τ, J) and whose only call, made if J ≤ len(τ), puts x_J(τ) to the human. Statement (b) is Theorem 2.3 for this scaffold, with N = m and the tests "the call is made and (input, answer) ∈ B".

*Proof.* The rounds are independent and identically distributed, because A is frozen, each round uses fresh (z, ρ), fresh coins of A and a fresh J, and the human's answers are independent given the questions (A1). The mean of η_i(B) is Pr[J ≤ len(τ), (x_J, h*) ∈ B] = (1/L)·Σ_{j=1}^L Pr[j ≤ len(τ), (x_j, h) ∈ B with h ∼ P(·|x_j)], which is h(B); likewise for α_i(B). (a) α_i(B) − η_i(B) lies in [−1, 1] and has mean Δ(B); by Hoeffding's inequality the average deviates from Δ(B) by more than t with probability at most 2e^(−mt²/2); take t = √(2 ln(2/(π(B)δ))/m) and sum over B. (b) m·η̄(B) is binomial (m, h(B)); apply Lemma 2.1 with a = ln(2/(π(B)δ))/m, sum over B, and use Lemma 2.2. (c) is the construction. ∎

*What it certifies.* For every test B of the family: how often the imitator's answers lie in B, compared with how often the human's answers *to the same inputs* would lie in B, on the inputs that the imitator's own runs produce. It needs m single answers of the human and no run of the human system. Used on one side: if B is a set of bad pairs, the imitator produces it at the rate a(B), which is known, and a human who never produced it in m probes produces it at a rate of at most ln(2/(π(B)δ))/m.

*Which average* (added by the editor from the attack report, Finding w4). ᾱ(B) and η̄(B) are counts divided by the number m of all rounds; an empty round counts as 0 for both. If the counts are divided by the number of rounds in which a question was asked, the difference estimates Δ(B)·L/E[len(τ)] and not Δ(B). Example: L = 2, runs of one or two calls with probability 1/2 each, an imitator that always answers 1, a human who answers 1 with probability 1/4 and B the set of pairs with answer 1; then Δ(B) = (1/L)·E[len]·(1 − 1/4) = 9/16, and the average over the non-empty rounds only is 3/4 (`property-batch_attack_sec56.out`, block D). The statement of V1(b) in the note must say which average is meant.

*What it assumes about the human.* A1 for the probes: each probe is answered by a fresh draw from P(·|x*). Without it the rounds are not identically distributed and h(B) is not defined. No class and no computability are assumed. "Nothing is assumed about the human" is therefore not exact, either here or for the batch form, which assumes (IID) (both reports).

*What it does not certify.* Nothing about events of runs (Example 5.3: all per-call frequencies can agree while a constant-price event of runs is off by 1/2). Nothing about properties outside the family. With per-call frequencies a bad kind of pair that the human never showed in m probes is bounded by ln(2/(π(B)δ))/m per call, so by L times that per run: for a run to be free of it with probability 1 − ε one needs m ≥ L·ln(2/(π(B)δ))/ε, and the factor L of Theorem N2 of the note returns. And nothing about the distance between A(·|x) and P(·|x) at any input, as long as each input is put to the human once: this is the next theorem.

### 6.2 What single answers at non-repeating inputs cannot certify

Theorem 6.2 together with Theorem 6.6 is the statement that the note calls **Pr7**.

**Theorem 6.2. ADDED, PROVED** (the observation is that of Dwork et al., see the attribution after Proposition 5.2; answering a random function "lazily", as in the proof of (c), is a standard device). Let P₀ be a sampler with Σ_y P₀(y|x) = 1 and p_max(x) := max_y P₀(y|x). For a function F: X → Y let P_F be the deterministic human who answers F(x) at x. Let F be random with independent values F(x) ∼ P₀(·|x), x ∈ X. A *procedure with m questions* is any rule that, with internal randomness, chooses inputs x_1, …, x_m one after another, each as a function of its randomness and of the answers received so far, receives the answers y_1, …, y_m of the human, and finally accepts or rejects as a function of all it has seen.

(a) *Far apart at every input.* For every F and every x: TV(P_F(·|x), P₀(·|x)) = 1 − P₀(F(x)|x) ≥ 1 − p_max(x).
(b) *Equal test frequencies in the mean, nearly equal for most F.* Let μ be a law on X, coll(μ) := Σ_x μ(x)², and for a set B of pairs let freq_S(B) := Σ_x μ(x)·S(B_x|x). Then E_F[freq_{P_F}(B)] = freq_{P₀}(B) for every B. For a family (𝓑, π) and η ∈ (0, 1), with probability at least 1 − η over F: |freq_{P_F}(B) − freq_{P₀}(B)| ≤ √(coll(μ)·ln(2/(π(B)η))/2) for all B ∈ 𝓑.
(c) *Indistinguishable.* For every procedure with m questions, |E_F[Pr_{P_F}(accept)] − Pr_{P₀}(accept)| ≤ ξ, where ξ is the probability that the procedure, facing the human P₀, asks some input twice. If the procedure never repeats a question, E_F[Pr_{P_F}(accept)] = Pr_{P₀}(accept). If its questions are independent draws from μ, ξ ≤ C(m, 2)·coll(μ).
(d) *One human for each procedure.* For every procedure with m questions, every family (𝓑, π), every law μ and every η ∈ (0, 1) there is a function f: X → Y with
 Pr_{P_f}(accept) ≥ Pr_{P₀}(accept) − ξ − η,
 |freq_{P_f}(B) − freq_{P₀}(B)| ≤ √(coll(μ)·ln(2/(π(B)η))/2) for all B ∈ 𝓑, and
 TV(P_f(·|x), P₀(·|x)) ≥ 1 − p_max(x) for every x.

*Proof.* (a) The total variation between the point mass at y and a law p is 1 − p(y). (b) Linearity of expectation; the second statement is Proposition 5.2(a). (c) Realise the experiment with the human P_F as follows. Draw the randomness of the procedure. When the procedure asks an input x for the first time, draw the answer from P₀(·|x), independently of everything so far; when it asks an input again, repeat the earlier answer. This is the experiment with a random F: the values of F are independent, the input asked at a step is a function of the procedure's randomness and of the values of F at inputs asked earlier, so given all of these the value of F at a new input has the law P₀(·|x). Realise the experiment with the human P₀ with the same randomness and the same draws at first-time questions, and with fresh draws at repeated questions. The two transcripts agree up to the answer to the first repeated question. Hence they agree entirely on the event that no question is repeated, which is the same event in both experiments and has probability 1 − ξ. For independent questions from μ, two given questions coincide with probability coll(μ). (d) Let a_F := Pr_{P_F}(accept) and a₀ := Pr_{P₀}(accept), and let G be the set of functions for which the bound of (b) holds; Pr[F ∈ G] ≥ 1 − η. Since 0 ≤ a_F ≤ 1, E[a_F·1_G] ≥ E[a_F] − η ≥ a₀ − ξ − η. So either a₀ − ξ − η ≤ 0, and any f ∈ G will do, or E[a_F | F ∈ G] ≥ a₀ − ξ − η and some f ∈ G has a_f ≥ a₀ − ξ − η. (a) holds for every f. ∎

*Reading.* Let the procedure be any validation of the imitator A := P₀, for example the fair coin; the procedure may know A. Suppose that it accepts with probability at least 1 − α when the human is P₀ itself, as it must if a perfect imitator is to pass. By (d) there is a deterministic human f for whom this imitator is wrong at every single input with probability at least 1 − p_max(x) (1/2 for the coin; and for a scaffold all of whose runs make L calls, the run law of the coin and the run law of f are at total variation 1 − 2^(−L), because given (z, ρ) the run of f is one sequence of L answers and the coin produces it with probability 2^(−L)), who has the same frequencies as the imitator on all tests of the family up to √(coll(μ)·ln(2/(π(B)η))/2), and against whom the same imitator is accepted with probability at least 1 − α − ξ − η. So **no procedure that puts each input to the human at most once (ξ = 0), and more generally no procedure for which a repeated input is unlikely (ξ small), can certify, for a human who may be non-deterministic, a bound on the distance between the imitator's and the human's answer laws: not at one input, not on average over the inputs of such a procedure, not for runs.** Frequencies of tests are what such answers determine (Theorem 6.1), and by Theorem 6.2(b) the two humans have nearly the same frequencies on every test of the family. This is the precise form of the sentence in `note.md`, Section 3.3: "No number of single answers at inputs that never repeat reveals the distribution P(·|x) at any one input; only frequencies of tests can be estimated."

*Correction of the reading* (both reports; the attack report, Finding M1, has the counterexamples). The prover's text read "no procedure that uses m single answers can certify …", with the proviso "when repetitions are unlikely (m²·coll(μ) small)". The bound m²·coll(μ) is for questions that are independent draws from μ. Nothing is proved about procedures with ξ near 1, and assumption A1 puts no limit on ξ: by A1 a question may be put again and is then answered by a fresh draw. "Each input is seen once" describes the validation phase as the note designed it; it is not a fact about the problem. The procedure "put input 1 to the human twice and accept iff the two answers are equal" accepts with probability 1/2 if the human is the fair coin and with probability 1 if the human is any function; with 50 inputs put twice the coin gives 50 equal pairs with probability 2^(−50) (`property-batch_attack_sec56.out`, block E). So the sentence of `note.md`, Section 8.2, "for a human who is not deterministic this is also all that can be checked", is false as it stands. What repeated questions certify is Proposition 6.4, and when they do not help is Theorem 6.6.

*Statement (d) is one-sided* (check report). It says that the far human f is accepted at least as often as P₀, up to ξ + η, which is what the reading needs: a far human passes. It does not say that the procedure cannot tell f from P₀: the procedure "ask input 0 once and accept iff the answer is 0" (ξ = 0) accepts the fair coin with probability 1/2 and every function with probability 0 or 1. What is indistinguishable from P₀ without a repeated question is the random function F, statement (c). A two-sided statement with one function for a whole family of decision rules is Proposition 6.5.

*Which hypotheses are needed.* If the human is known to be deterministic, one answer reveals P(·|x), and faithfulness itself can be certified: Theorem V1(a). If inputs repeat, P(·|x) can be estimated at the repeated inputs; ξ measures this, and Proposition 6.4 says what two answers per input give. In (c) and (d) the quantifiers are "for every procedure there is a human": a procedure that knows f distinguishes P_f from P₀ with one question. The human f of (d) is deterministic; by symmetry the same construction gives, for a deterministic imitator, a stochastic human.

**Example 6.3 (frequencies that are exactly equal). PROVED.** Let X = {0, 1}^d with the uniform law, f(x) := x_1 ⊕ … ⊕ x_d, and P₀ the fair coin. Let 𝓑_d be the family of all B ⊆ X × {0, 1} for which there is a coordinate i such that membership of (x, y) in B does not depend on x_i. Then freq_{P_f}(B) = freq_{P₀}(B) exactly for every B ∈ 𝓑_d, while TV(P_f(·|x), P₀(·|x)) = 1/2 at every x.

*Proof.* Let B not depend on x_i and let x′ be x with the i-th bit flipped; then f(x′) = 1 − f(x). So 1[(x, f(x)) ∈ B] + 1[(x′, f(x′)) ∈ B] = 1[(x, f(x)) ∈ B] + 1[(x, 1 − f(x)) ∈ B] = 1[(x, 0) ∈ B] + 1[(x, 1) ∈ B], and the last expression is the same for x and x′. Summing over the 2^(d−1) pairs {x, x′} gives Σ_x 1[(x, f(x)) ∈ B] = ½·Σ_x (1[(x, 0) ∈ B] + 1[(x, 1) ∈ B]). ∎

Here the two humans agree exactly on a large family and are separated by one simple test outside it, the parity itself: the single question "ask any x and accept iff the answer is the parity of x" accepts the parity human with probability 1 and the coin with probability 1/2. So Example 6.3 is an example of equal test frequencies on a family and not of two humans that answers cannot tell apart (attack report, Finding M1). In Theorem 6.2(d) the function has no short description, and no test of the family separates it from the coin; the procedure chosen in advance accepts it at least as often as the coin.

### 6.3 Repeated questions: what they certify, and when they do not help

The three statements of this subsection were added after the verification. Propositions 6.4 and 6.5 are the attack report's Propositions X1 and X2; the editor re-derived their proofs, and the attack report's scripts check them numerically (`property-batch_attack_sec56.out`, block E2; `property-batch_attack_twosided.out`). Theorem 6.6 is the editor's; it gives a proof for what the attack report observed numerically (its Finding M1, "where the sentence is true"). No second verifier examined any of the three.

**Proposition 6.4 (two answers per probe: a certificate for a human who is not deterministic, when the set of answers is small). PROVED.** Take the setting of Theorem 6.1 with one change: in every round that is not empty the probe input x* is put to the human twice, and the answers y₁, y₂ are independent draws from P(·|x*); this is A1. Let A be a sampler whose probabilities A(y|x) can be computed. (For an answerer with memory, read A(·|x*) as the law of its answer at the probe call given its run so far.) Put

 s := 1[y₁ = y₂] − A(y₁|x*) − A(y₂|x*) + Σ_y A(y|x*)² (and s := 0 in an empty round),
 d(x)² := Σ_y (P(y|x) − A(y|x))², D₂ := (1/L)·E_{Q_A}[Σ_{j ≤ len(τ)} d(x_j)²],

and let s̄ be the average of s over the m rounds. Then:

(a) E[s] = D₂, and −1/2 ≤ s ≤ 2.
(b) With probability at least 1 − δ: D₂ ≤ s̄ + (5/2)·√(ln(1/δ)/(2m)).
(c) If at every input the laws P(·|x) and A(·|x) are carried by a common set of at most q answers, the expected number β of unfaithful calls in a run of A (in the coupling of `note.md`, Section 1) satisfies β ≤ (L/2)·√(q·D₂). For answers in {0, 1}: β ≤ L·√(D₂/2).

So with at most 2m answers of the human, Theorem R3 of the note applies with β ≤ (L/2)·√(q·(s̄ + (5/2)·√(ln(1/δ)/(2m)))), whatever the human is and however A was made.

*Proof.* (a) Given x*, E 1[y₁ = y₂] = Σ_y P(y|x*)² and E A(y_i|x*) = Σ_y P(y|x*)·A(y|x*), so E[s | x*] = Σ_y P² − 2·Σ_y P·A + Σ_y A² = d(x*)². The probe is the J-th call of a run of A with J uniform on {1, …, L}, which gives E[s] = D₂ as in the proof of Theorem 6.1. If y₁ = y₂ = y, then s = 1 − 2A(y|x*) + Σ_y′ A(y′|x*)² ≥ (1 − A(y|x*))² ≥ 0 and s ≤ 2. If y₁ ≠ y₂, put a := A(y₁|x*) and b := A(y₂|x*); then s ≥ −a − b + a² + b² ≥ −1/2, because t² − t ≥ −1/4 for every t, and s ≤ Σ_y A² ≤ 1. (b) Hoeffding's inequality, on one side, for m independent terms in an interval of length 5/2. (c) By the Cauchy–Schwarz inequality, TV(P(·|x), A(·|x)) = ½·Σ_y |P(y|x) − A(y|x)| ≤ (√q/2)·d(x). In the coupling a call at x is unfaithful with probability TV(P(·|x), A(·|x)). Hence β ≤ (√q/2)·E Σ_j d(x_j) ≤ (√q/2)·√(E[len(τ)])·√(E Σ_j d(x_j)²) ≤ (√q/2)·√L·√(L·D₂). For two answers, Σ_y (P − A)² = 2·TV², which gives the second form. ∎

*Attribution.* The statistic is the collision estimator of a squared ℓ₂ distance. The number of coincidences among samples was used to estimate the ℓ₂ norm of a distribution, and through it the distance from the uniform distribution, by O. Goldreich and D. Ron, "On testing expansion in bounded-degree graphs", ECCC TR00-020 (2000), and for the ℓ₂ distance between two unknown distributions by T. Batu, L. Fortnow, R. Rubinfeld, W. D. Smith and P. White, "Testing that distributions are close", FOCS 2000, 259–269 (journal version "Testing closeness of discrete distributions", arXiv:1009.5397v2). Read by the editor in this session in the arXiv version of the second paper: Section 2.1 states for the statistics r (from coincidences within each sample) and s (from coincidences between the two samples) that "E[r − s] = m²(‖p‖₂² + ‖q‖₂² − 2(p·q)) = m²(‖p − q‖₂²)", and Section 1.1 credits the first: "Goldreich and Ron give the first formal analysis that using O(√n) samples to estimate the collision probability yields an algorithm which gives a very good estimate of the ℓ₂ distance between the given distribution and the uniform distribution. Their 'collision count' idea underlies the present paper." The paper of Goldreich and Ron was not opened. Proposition 6.4 is the case in which one of the two distributions is known and each input supplies two samples of the other.

*What it does not say.* Nothing for answers that are long strings: q is then beyond any budget, and by Theorem 6.6 no statistic of repeated answers helps. Nothing about one input: P(·|x) at a given x stays unknown; only the average over the imitator's own calls is certified. And the rate is slow: for a perfect imitator D₂ = 0 is certified only to within about m^(−1/2), so β/L only to within about m^(−1/4), against 1/m for a deterministic human (Theorem V1(a)).

**Proposition 6.5 (Theorem 6.2(d) on both sides, with one function for a family of decision rules). PROVED.** Let P₀, p_max, F and coll(μ) be as in Theorem 6.2. A *decision rule with m probes* draws x_1, …, x_m independently from μ, receives one answer of the human to each, and accepts with a probability D((x_1, y_1), …, (x_m, y_m)) ∈ [0, 1]. (This is the form of a validation phase: the probes do not depend on the human's answers.) Let 𝒟 be a countable family of decision rules, the rule D using m_D probes, with weights π_D > 0 of total at most 1, and let η ∈ (0, 1). With probability at least 1 − η over F, for every D ∈ 𝒟:

 |Pr_{P_F}[D accepts] − Pr_{P₀}[D accepts]| ≤ C(m_D, 2)·coll(μ) + m_D·√(coll(μ)·ln(2/(π_D·η))/2).

So there is one function f, chosen before any rule of the family is, with TV(P_f(·|x), P₀(·|x)) ≥ 1 − p_max(x) at every x, that every rule of the family accepts with the probability with which it accepts P₀, up to the error shown. For m_D = 1 and D the indicator of a set B of pairs this is Proposition 5.2(a) and Theorem 6.2(b), with the same constant.

*Proof.* Put a_F(D) := Pr_{P_F}[D accepts] and a₀(D) := Pr_{P₀}[D accepts]. A decision rule is a procedure in the sense of Theorem 6.2 whose questions are independent draws from μ, so by Theorem 6.2(c), |E_F a_F(D) − a₀(D)| ≤ C(m_D, 2)·coll(μ). As a function of the independent values F(x), x ∈ X, the number a_F(D) changes by at most m_D·μ(x₀) when F is changed at the one input x₀, because the transcript changes only if x₀ is among the m_D probes. By the bounded-differences inequality (C. McDiarmid, "On the method of bounded differences", in *Surveys in Combinatorics 1989*, Cambridge University Press, 148–188: a function of independent variables that changes by at most c_i when the i-th variable alone is changed deviates from its mean by t or more with probability at most 2·exp(−2t²/Σ_i c_i²); standard, quoted from memory, not opened; for infinite X apply it to finitely many inputs and pass to the limit), Pr[|a_F(D) − E_F a_F(D)| ≥ t] ≤ 2·exp(−2t²/(m_D²·coll(μ))). Take t := m_D·√(coll(μ)·ln(2/(π_D·η))/2), which makes the right side π_D·η, and sum over D. ∎

For the uniform law on u inputs the error is at most m²/(2u) + m·√(ln(2/(π_D·η))/(2u)), which is small as soon as u is large against m²·ln(1/π_D). This is the statement "two humans, far apart at every input, with nearly equal test frequencies, that m such samples cannot tell apart" with the quantifiers in the strong order: one deterministic human for all rules of the family. It is for rules whose probes are independent draws from μ; for adaptive procedures Theorem 6.2(c) and (d) remain what is proved.

**Theorem 6.6 (answers from a large set: repeated questions do not help). PROVED** (added by the editor; checked by exact enumeration in `property-batch_editor.out`, block (E9), whose values agree with those of the attack report, `property-batch_attack_sec56.out`, block F). Let s ≥ 2 be an even integer. At every input x let Y_x ⊆ Y be a set of s answers, and let P₀(·|x) be uniform on Y_x. Let H = (H_x)_{x∈X} be random, the H_x independent and H_x uniform among the subsets of Y_x with s/2 elements, and let P_H(·|x) be uniform on H_x. Procedures with m questions are as in Theorem 6.2; they may repeat inputs at will. Then:

(a) TV(P_H(·|x), P₀(·|x)) = 1/2 for every H and every x.
(b) For every procedure with m questions: |E_H[Pr_{P_H}(accept)] − Pr_{P₀}(accept)| ≤ C(m, 2)/s.
(c) For every law μ on X, every family (𝓑, π) and every η ∈ (0, 1), with probability at least 1 − η over H: |freq_{P_H}(B) − freq_{P₀}(B)| ≤ √(coll(μ)·ln(2/(π(B)η))/2) for all B ∈ 𝓑, where freq is as in Theorem 6.2(b).
(d) Hence for every procedure with m questions, every family, every μ and every η there is one H such that (a) holds, the bound of (c) holds, and Pr_{P_H}(accept) ≥ Pr_{P₀}(accept) − C(m, 2)/s − η.

*Proof.* (a) P_H(·|x) gives probability 2/s to each of s/2 answers, to which P₀(·|x) gives 1/s, and probability 0 to the others; so the total variation is (s/2)·(2/s − 1/s) = 1/2.

(b) Consider the experiment in which H is drawn first and the human is P_H. Fix the randomness of the procedure and a transcript of the first t − 1 questions and answers, and let x be the t-th question; it is a function of the randomness and of the transcript. Suppose that x was asked r times before and that the answers given to it form a set V of j distinct answers. Given the randomness and the transcript, the sets H_x′ are independent, and H_x is uniform among the subsets of Y_x with s/2 elements that contain V, because the likelihood of the transcript given H is the product over the recorded pairs (x′, a) of (2/s)·1[a ∈ H_x′]. Hence a given v ∈ Y_x∖V lies in H_x with probability (s/2 − j)/(s − j), and the t-th answer, which is uniform on H_x, equals a given v ∈ V with probability 2/s and a given v ∈ Y_x∖V with probability (2/s)·(s/2 − j)/(s − j) = (s − 2j)/(s·(s − j)) ≤ 1/s. In the experiment with the human P₀ the t-th answer equals each v ∈ Y_x with probability 1/s. The total variation between the two conditional laws of the t-th answer is therefore j·(2/s − 1/s) = j/s ≤ (t − 1)/s. Now build the two experiments on one probability space, with the same randomness of the procedure, drawing the t-th answers of the two from a coupling in which they differ with probability equal to the total variation of their conditional laws, as long as the two transcripts agree. The transcripts first differ at step t with probability at most (t − 1)/s, so they differ at all with probability at most Σ_{t=1}^m (t − 1)/s = C(m, 2)/s, and the acceptance probabilities differ by no more.

(c) freq_{P_H}(B) = Σ_x μ(x)·|B_x ∩ H_x|/(s/2) is a sum of independent random variables; the x-th lies in [0, μ(x)] and has the mean μ(x)·|B_x ∩ Y_x|/s = μ(x)·P₀(B_x|x). Hoeffding's inequality gives the bound as in Proposition 5.2(a).

(d) As Theorem 6.2(d), with C(m, 2)/s in the place of ξ. ∎

*Reading.* Both humans of the theorem are non-deterministic, and they are at total variation 1/2 at every input. A procedure that receives m answers, to whatever inputs and with whatever repetitions, tells them apart with advantage at most m²/(2s). For answers that are strings of ℓ bits, s can be 2^ℓ, and no budget of questions reaches √s. So for answers from a very large set the conclusion of Theorem 6.2 holds also with repeated questions: frequencies of tests are what can be certified, and the distance between answer laws cannot. The bound is close to the truth: for one input asked r times the exact total variation between the two laws of the r answers is 0.00391 = 1/s for (s, r) = (256, 2), 0.0954 against the bound 0.1094 for (256, 8), and 0.1032 against 0.1240 for (65536, 128). The general fact behind the theorem is the lower bound for testing whether a distribution on s points is uniform or far from uniform, of the order of √s samples (L. Paninski, "A coincidence-based test for uniformity given very sparsely sampled discrete data", *IEEE Trans. Inform. Theory* 54 (2008) 4750–4755; not opened; Batu et al., Section 1.1, read by the editor, describe it as a test "using Θ(√n/ε²) samples"); Theorem 6.6 is self-contained and does not use it. The two regimes do not meet: Theorem 6.6 shows that a certificate of the distance needs at least of the order of √s answers when s answers are possible, and the certificate of Proposition 6.4 uses of the order of q²/ε⁴ probes to certify β/L ≤ ε when q answers are possible. What lies between is the subject of the literature on identity testing and is not examined here.

---

## 7. Which hypotheses are needed

| statement | what it needs | what it does not need | why the hypothesis is needed |
|---|---|---|---|
| Pr3: Theorems 2.3, 2.5, Corollary 2.6, Proposition 3.9 | (IID), which includes that the human does not change or remember from run to run; tests fixed before the data, with weights | A1 within a run, A2, any class, computability of the human | one run copied N times (Remark 2.7(2)); tests chosen after the data (2.7(3)); the price ln(1/π) (Lemma 2.8) |
| Pr4 in the class: Theorem 3.3, Proposition 3.8 | (IID); Q = Q_ν₀ for an index ν₀ | a stateless human beyond this; equality of kernels outside the inputs the scaffold reaches | outside the class no index may match: Example 3.11(c) |
| Pr4 in general: Theorem 3.6, Corollary 3.7 | (IID); weights with Σ w ≤ 1 | membership in the class, A1 (but for a human with memory in a run and a class of samplers the bound can be empty: item (3) of "What Theorem 3.6 does not say", after Corollary 3.7) | no penalty: the replay of the data wins, Example 3.11(b); factor 3: Example 3.11(a) |
| computing the estimate (3.5, Theorem 3.10) | a list of the heavy indices; exact comparison of likelihoods on given runs; a closed system for Q_ν(A_νν′) | Q, the densities of D₀ and Λ | lower semicomputable hypotheses: the comparison is not decidable |
| hindsight: Theorem 4.2, Corollary 4.3 | (Cl_R), hence a class with hypotheses that may give no answer (Remark 4.14; for samplers that always answer: Proposition 4.15); data that abide by R | A1, A2, any law of the inputs | H_mem is not closed (remark after Theorem 4.5); under (Cl_R) nothing more holds at a fresh input (Corollary 4.6) |
| foresight: Theorem 4.7 | inputs independent from the law μ of the fresh input; the human never violates R on the support of μ | A2 for (a), (b), (c), (e), (f), (g); decidability of R | another input law: Theorem N1 of the note; the bound is attained: Proposition 4.8 |
| certificate: Theorem 6.1 | A frozen; A1 for the answers to the probes; tests fixed before validation | A2; anything about A or about how it was made | if A changes during validation the rounds are not identically distributed |
| limits of the certificate: Theorem 6.2 | P₀ not deterministic (p_max < 1); each input put to the human once, or a repeated input unlikely (ξ small) | | deterministic human: V1(a) certifies faithfulness; repeated inputs and a small set of answers: a squared distance of the answer laws can be certified (Proposition 6.4) |
| limits of the certificate: Theorem 6.6 | answers from a set of s elements with s large against m² | a bound on repetitions | small s: Proposition 6.4 |

---

## 8. What remains open, and remarks on other files of the project

### 8.1 Open in this part

1. **One fixed reference machine** (4.13, item 4): for no universal machine U is it proved or refuted that there is a constant c_U with V(D_n) ≤ ((c_U + K_U(R))·ln 2 + ln(1/δ))/n for every decidable R and every human in the class that never violates R. Theorem 4.11(B) shows that universality of the machine is not enough to bound c_U by the price of R and the closure constant. What is proved is the bound with K*, the cost of the cheapest explanation of the answers, and the bound ½ + (k_c·ln 2 + ln(1/δ))/(2n) on machines with a cheap coin.
2. **Constants of Theorem 3.6.** Whether 2·r_N(ν), that is the leading term √(2K ln 2/N), is the best possible for an estimator that returns a member of the class is not decided here. The Bayes procedure of Theorem A has √(K ln 2/(2N)) in expectation, but it returns a random mixture.
3. **Factor 2 with mixtures.** Bousquet, Kane and Moran obtain the factor 2 for finite classes with an estimator that may leave the class. A version for a countable class with weights, with an additive term of order √(K(ν)/N), was not attempted.
4. **Theorem 2.5(c).** The draft's joint statement at confidence 1 − δ fails for one test with π(R)·δ = 0.332 (N = 4). On the grids of the two reports it held for all smaller values; this is not proved.
5. **Dependent runs.** If the top-level inputs of the recorded runs are chosen adaptively, the runs are not independent. Theorems 2.5(a), 3.3 and 3.6 should hold with a martingale inequality in place of Lemma 2.1; this was not written out.
6. **A last-round version of Proposition 4.9.** Theorem 4.7 is for inputs drawn independently from one law. Under rehearsal the questions come from the changing run laws of the mixtures, and Proposition 4.9 controls the violation rate only for the mixture of a uniformly random round, in expectation. A bound with high probability for the last mixture on its own run law is not proved (compare Remark 4.3 and Example 4.4 of `proofs/hellinger-runs.md`: the expected divergence is not monotone).
7. **Necessity of K\* class by class.** Proposition 4.8 shows that Theorem 4.7 is sharp in one family of classes. Whether, in a given class, the violation probability at a fresh input can be bounded below in terms of K* is not examined.
8. **The factor 3 in expectation** (added by the editor). Corollary 3.7(c) has the factor 3. For two densities a randomised rule that returns a member of the class has the factor 2 in expectation (Mahalanabis and Štefankovič, Theorem 10), and the lower bound of Bousquet, Kane and Moran is for guarantees with probability above 2/3. Whether 3 can be lowered in Corollary 3.7(c) is not examined.
9. **Both prices outside the class** (added by the editor). For a human system outside the class no single selection rule is shown to have both the oracle inequality for total variation (Theorem 3.6) and the per-test guarantee (Proposition 3.9).
10. **Certificates from repeated questions** (added by the editor). Between Proposition 6.4 (of the order of q²/ε⁴ probes for q possible answers) and Theorem 6.6 (at least of the order of √s answers for s possible answers) nothing is proved here.
11. **Statements that no second verifier examined** (added by the editor): Lemma 2.8, Remark 4.14, Propositions 4.15, 5.4, 6.4 and 6.5, Theorem 6.6, and items 5 and 6 of 4.13. Section 11 says for each who derived and who checked it.

### 8.2 Remarks on other files (things I noticed)

1. **`research/candidate-theory.md`, Pr3**: the two statements are claimed jointly with probability 1 − δ. This is false as stated (Theorem 2.5(c); found by the earlier worker): the joint confidence is 1 − 3δ/2, or use the divergence form (G), which contains both at confidence 1 − δ with ln(2/(πδ)) in the one-sided bound.
2. **`research/candidate-theory.md`, Pr4**: "Add to 𝓣 the sets {Q_ν > Q_ν′} … with weight w(ν)w(ν′)". If 𝓣 already has total weight 1, the union has total weight up to 2; with halved weights the bound is √((4K ln 2 + 2 ln(4/δ))/N) (Theorem 3.3). The constant 4K can be lowered to 2K (Corollary 3.7(a), Proposition 3.8). "The highest-weight sampler that matches all tests" is not defined when the human system is outside the class (Example 3.11(c)); the oracle inequality needs the penalised estimator of Definition 3.4. The inequality then holds in the form the draft hoped for, with the term √((2K(ν) ln 2 + 2 ln(2/δ))/N) in the place of C·√((K(ν) + ln(1/δ))/N) (Theorem 3.6).
3. **`research/candidate-theory.md`, Pr2, and the placeholder in `note.md`, Section 8.5**: "it stays near 1 for all n up to about K divided by the number of bits per pair" is true for the memoriser class H_mem (Theorem 4.5), but that class is not closed under conditioning on R, so the hindsight bound is not a statement about it (its conclusion holds there trivially). In a class that is closed under conditioning with constant C_R the violation probability at any input is at most 1 − 1/C_R, and it is this value, not 1, that the closed memoriser class approaches (Corollary 4.6). The two halves of the sentence in Section 8.5 need different classes, or the second half must say "stays near 1 − 1/C_R" (which is at least 1/2 when C_R ≥ 2). Also: "the probability a hypothesis gave to abiding so far" has to be read as "to not violating", with "no answer" counted as abiding; otherwise the class of all programs is not closed under the conditioning (Remark 4.4). (Added by the editor: for the class of all programs, "not bounded in terms of K(R)" is supported only by Theorem 4.11(B), and only in the sense "not on all universal machines"; and with silence counted as abiding the floor 1/C_R need not be a probability of answering, Remark 4.14.)
4. **`note.md`, Section 8.5**: the sentence "is not bounded in terms of K(R)" should be accompanied by what does hold: the violation probability at a fresh input is at most (K ln 2 + ln(1/δ))/n (Theorem 4.7(d)), and under rehearsal the expected number of violating calls of a deployed run is at most L·K ln 2/n (Proposition 4.9). The mixture pays K for a property, not K(R); it does not fail to pay. (Added by the editor: the title "the mixture does not give the per-property price" should read "need not give": the examples are facts about the prior, remark (3) after Theorem 4.5.)
5. **`note.md`, Theorem V1(b)**: correct as stated. Since the imitator's own frequency a(B) needs no human answer, the tolerance can be halved to √(ln(2/(π(B)δ))/(2m)), and the divergence form gives h(B) ≤ ln(2/(π(B)δ))/m for tests that the human's answers never met (Theorem 6.1(b)).
6. **`note.md`, Sections 3.3 and 8.2**: "for a human who is not deterministic this is also all that can be checked: each input is seen once" is true under the proviso that inputs do not repeat; Theorem 6.2 is the precise statement, with the probability ξ of a repetition as the error term. (Corrected by the editor after both reports: without the proviso the sentence of Section 8.2 is false, because A1 allows a question to be put twice; see the correction after Theorem 6.2, Proposition 6.4 and Theorem 6.6. Section 3.3 has the proviso and is correct.)
7. **`note.md`, Section 8.4, second bullet** ("Single calls, not runs"): Example 5.3 is a minimal exact example of this failure: all per-call tests matched, a constant-price test of runs off by 1/2.
8. **`research/prove-b/property-batch.md`** (the earlier version of this file): in the proof of Lemma 2.1 the consequence was not argued for q ∈ {0, 1}; the case is trivial and is now included. Its scripts refer to statement numbers of a plan that was not written; the prover's scripts, now in `proofs/code/`, carry the numbers of this file.
9. **`research/understand/indistinguishability.md`, Proposition I5** is Theorem 3.3 of this file for a one-call scaffold, with the same constants. Its part (b), the bound in total variation, needs the human in the class; for a human outside the class the counterpart is Theorem 3.6, with a different estimator. Item 3 of its Section 1 ("both regimes can be had from one learner") should be read with this restriction.

---

## 9. Numerical checks

All scripts are pure Python 3 (one block of the check report's `property-batch_check_sec3.py` uses numpy) and are run as `python3 NAME.py > NAME.out` in `proofs/code/`. The outputs of the prover's five scripts are copied below from the saved `.out` files; the output of the editor's script follows them. The editor ran all sixteen scripts of this part again in `proofs/code/` on 16 November: the fifteen of the prover and the verifiers reproduce their saved outputs exactly (compared with `diff`), in 1 to 213 seconds each.

**`property-batch_pr3.py`** (Section 2; taken over from the earlier worker with corrected labels):

```
(1) Lemma 2.1 / Theorem 2.3: max over grid of Pr[kl(Qhat||q) > ln(2/eps)/N] / eps = 0.4127 (must be <= 1)
(2) Lemma 2.2: violations of kl >= (p-q)^2/(2max(p,q)) and of Pinsker on a 401x399 grid: 0
(3) random triples satisfying both kl constraints: 16566  violations of Corollary 2.6(ii),(iii): 0
(4) Theorem 2.5(c): max exact failure probability of the joint statement / (pi*delta) = 1.105 at (N, pi*delta, q) = (1, 0.905, 0.1)
(5) same, restricted to pi*delta <= 0.2: max ratio = 0.9885 at (300, 0.1, 0.007684)
```

**`property-batch_pr4.py`** (Section 3). Random classes of 12 hypotheses on 6 points with weights 2^(−1), …, 2^(−12); in half of the trials the probabilities are multiples of 1/20, so that ties L_ν = L_ν′ are frequent. A "failure" is a trial in which the stated bound does not hold; the theorems allow a fraction δ = 10% of failures (20% in (7)).

```
(1) Lemma 3.2(a): max |TV(Q_i,Q_j) - (Q_i(A_ij) - Q_j(A_ij))| over 2000 random classes (half of them with ties): 2.2e-16
(2) Theorem 3.3 (two-sided matching, product weights; a family of 6 singleton tests of weight 1/6 added), human in the class:
    N=   30: failures 1/1500 (allowed 10%); TV/bound mean 0.176, max 0.680
    N=  200: failures 4/1500 (allowed 10%); TV/bound mean 0.012, max 0.651
    N= 2000: failures 1/1500 (allowed 10%); TV/bound mean 0.000, max 0.336
(3) Theorem 3.6 (penalised one-sided minimum distance, kappa = ln(2/delta)): TV(est, Q) against min_i [3 TV(Q_i,Q) + 2 r_N(i)]
    in the class      N=   30: failures 0/1500 (allowed 10%); TV/bound mean 0.286, max 0.836
    in the class      N=  200: failures 1/1500 (allowed 10%); TV/bound mean 0.047, max 1.041
    in the class      N= 2000: failures 0/1500 (allowed 10%); TV/bound mean 0.001, max 0.717
    in the class      N=20000: failures 0/1500 (allowed 10%); TV/bound mean 0.000, max 0.000
    outside the class N=   30: failures 0/1500 (allowed 10%); TV/bound mean 0.253, max 0.701
    outside the class N=  200: failures 0/1500 (allowed 10%); TV/bound mean 0.191, max 0.647
    outside the class N= 2000: failures 0/1500 (allowed 10%); TV/bound mean 0.246, max 0.519
    outside the class N=20000: failures 0/1500 (allowed 10%); TV/bound mean 0.297, max 0.509
(4) Proposition 3.8 (highest-weight index passing the one-sided tests), human in the class: bound 2 r_N = sqrt((2K ln2 + 2 ln(2/delta))/N)
    N=   30: failures 0/1500 (allowed 10%); TV/bound mean 0.236, max 0.774
    N=  200: failures 0/1500 (allowed 10%); TV/bound mean 0.021, max 0.743
    N= 2000: failures 1/1500 (allowed 10%); TV/bound mean 0.000, max 0.000
(5) Theorem 3.6, exact binomial computation for two hypotheses on {0,1} (661500 cases, truth in or outside the class):
    max Pr[TV(est,Q) > min_i(3 TV_i + 2 r_N(i))] / delta = 0.0653 (must be <= 1), at (N, delta, w1, w2, p1, p2, q) = (20, 0.3, 0.9, 0.1, 0.0, 0.65, 0.65)
(6) eps=0.05: TV(f1,g)=0.700, TV(f2,g)=0.300, ratio 2.333; N=101: the estimator returns f1 in 1989/4000 trials
(6) eps=0.05: TV(f1,g)=0.700, TV(f2,g)=0.300, ratio 2.333; N=10001: the estimator returns f1 in 2007/4000 trials
(6) eps=0.01: TV(f1,g)=0.740, TV(f2,g)=0.260, ratio 2.846; N=101: the estimator returns f1 in 1999/4000 trials
(6) eps=0.01: TV(f1,g)=0.740, TV(f2,g)=0.260, ratio 2.846; N=10001: the estimator returns f1 in 1970/4000 trials
(7) Theorem 3.10 (Q_i(A_ij) replaced by frequencies in N_sim simulated runs of hypothesis i): TV against min_i[3TV_i + 2 r_N(i) + 2 r_Nsim(i)]
    N=200, N_sim=200: failures 0/800 (allowed 20%); TV/bound mean 0.237, max 0.770
    N=200, N_sim=5000: failures 0/800 (allowed 20%); TV/bound mean 0.150, max 0.823
    N=2000, N_sim=2000: failures 0/800 (allowed 20%); TV/bound mean 0.120, max 0.531
(8) Corollary 3.7(c) (kappa = 0): E TV(est,Q) against min_i[3TV_i + sqrt(2 K_i ln2 / N)] + sqrt(2 pi/N), one fixed class and truth per row
    N=   50: E TV = 0.0888; best TV in class = 0.0746; bound = 0.9113
    N=  500: E TV = 0.0530; best TV in class = 0.0530; bound = 0.3765
    N= 5000: E TV = 0.0562; best TV in class = 0.0562; bound = 0.2374
(9) Theorem 3.6, exact multinomial computation for three hypotheses on three points (6423 cases, 916 with positive failure probability):
    max Pr[TV(est,Q) > min_i(3 TV_i + 2 r_N(i))] / delta = 0.0646 (must be <= 1)
```

Reading: the bounds hold with far fewer failures than allowed (the union bounds are conservative; in the exact computations (5) and (9) the failure probability is at most 0.065·δ). Block (6) is Example 3.11(a): the estimate is the worse of the two hypotheses in half of the trials, at every N. In these small classes the realised error is well below the bound; the examples of 3.6 show that the form of the bound cannot be improved.

**`property-batch_pr2.py`** (Section 4). Identities are checked with exact rational arithmetic against enumeration of the whole class.

```
(A) Theorem 4.5(a),(b): closed forms equal brute-force enumeration over all 3^u tables (exact rationals), u in {2,4,7}: True
    Corollary 4.6: closed class with constant C_R = C+1, C in {1,4}: predictive value = C/(C+1) x (Theorem 4.5): True ; never-violators have posterior weight >= 1/C_R and the violation probability is <= 1 - 1/C_R: True
(B) u=2^20, K=1000: bits per pair log2(4u+2) = 22.0000; (K-2)/bits = 45.36
    k (distinct inputs seen) : V = probability that the mixture violates R at a fresh uniform input
      0 : 1
      1 : 0.999999
     10 : 0.99999
     30 : 0.999971
     44 : 0.999958
     45 : 0.998981
     46 : 0.000244065
     47 : 5.82037e-11
     48 : 1.38768e-17
     50 : 7.88804e-31
     60 : 4.68127e-97
    lower bound (3/4)(10/11)(3/4) = 0.5114 of Theorem 4.5(d) holds for k <= min(u/4, (K-2)/bits): min over k<= 45 of V = 0.998981
    upper bound 2^K (4u+2)^-k of Theorem 4.5(e) at k=47: 5.82e-11
(C) Proposition 4.10: closed form equals brute force (exact rationals): True
    u=2^20, K=1000, coin of prior weight 2^-20, n distinct inputs: V = ['1', '0.333', '2.38e-07', '1.14e-13', '2.58e-26']
    bound ((1-gamma)/gamma)(2u+1)^-n of Proposition 4.10: ['1.05e+06', '0.5', '2.38e-07', '1.14e-13', '2.58e-26']
(D) Theorem 4.2 on 400 random closed classes of semimeasures: max of E_post[prod(1-v)^-1]/C_R = 1.0000 (must be <= 1);
    Corollary 4.3(a): max of E_post[sum_i v(x_i)]/ln C_R = 0.4144 (<= 1); (c): min of C_R x posterior weight of never-violators = 1.0000 (>= 1)
(E1) Theorem 4.7(a), exact enumeration (3 inputs, 3 answers, n=3, 60 random classes of semimeasures): max of E[Z_n]/sum(w) = 0.6495 (must be <= 1)
(E2) Theorem 4.7(b),(d), all n <= 30 at once: failures 73/4000 of the inequality, 0/4000 of V(D_n) <= (K ln2 + ln(1/delta))/n (allowed 10%)
(F) Proposition 4.8: closed form equals brute force over all subsets S (exact rationals): True
    violation level against bits per pair, u = 2^16, K = 200, k = n distinct inputs (V exact; 1 - sigma is the level; K/log2(1/sigma) the duration):
    sigma = 2^-1 (level 0.5000, K/bits = 200): 0:0.500  10:0.500  25:0.500  40:0.500  45:0.500  50:0.500  60:0.500  100:0.500  190:0.499  200:0.212  210:0.000
    sigma = 2^-2 (level 0.7500, K/bits = 100): 0:0.750  10:0.750  25:0.750  40:0.750  45:0.750  50:0.750  60:0.750  100:0.333  190:0.000  200:0.000  210:0.000
    sigma = 2^-4 (level 0.9375, K/bits = 50): 0:0.938  10:0.938  25:0.938  40:0.937  45:0.937  50:0.403  60:0.000  100:0.000  190:0.000  200:0.000  210:0.000
    Theorem 4.7(c) in this class, sigma = 1/4, delta = 0.1:  k : 1 - V(D_k)  >=  (delta M(D_k))^(1/k)
      5 : 0.2500  >=  0.1577
     20 : 0.2500  >=  0.2227
     50 : 0.2500  >=  0.2385
     90 : 0.2500  >=  0.2432
(G) Theorem 4.11: mixture probability of the bad answer at a new input >= (2u/(2u+1))/(1 + 2^(2-c) (4u)^k) on 300 random instances (exact rationals): True
```

Reading: (B) is the transition of Theorem 4.5: the violation probability is above 0.998 for 45 questions and below 10⁻³ from the 46th distinct input on. (D): the hindsight bound and the floor are attained to four digits on some of the random classes. (F): the level 1 − σ is held for K/log₂(1/σ) questions, and the lower bound of Theorem 4.7(c) is within a few per cent of the truth.

**`property-batch_prices.py`** (Section 5):

```
(1) Proposition 5.2: u = 2^12 inputs, 1490 tests with weight 1/1490 each; human = a random function f, imitator = a fair coin
    max over tests and over 40 draws of f of |Q_f(R) - Q_coin(R)| = 0.0222;  bound sqrt(ln(2/(pi eta))/(2u)) = 0.0355 (eta = 0.1); draws exceeding the bound: 0/40
    total variation between the two run laws: 0.5 exactly (the coin differs from f(x) with probability 1/2 at every x)
    with N = u/4 = 1024 recorded runs of f: tol_N = 0.0709; the coin is within tol_N of the empirical frequency of every test in 40/40 draws
    the test 'y = f(x)' would separate them (frequency 1 against 1/2); a family that contains it with weight pi must have
    sqrt(ln(2/(pi eta))/(2u)) >= 1/2, i.e. pi <= (2/eta) exp(-u/2) = 20 x exp(-2048)
(2) Example 5.3: scaffold with two calls that put the same input z to the answerer; human = fair coin at each call; imitator = one random function g
    per-call tests: max |a(B) - h(B)| over the 1490 tests and 10 draws of g = 0.0173 (bound 0.0355)
    run test 'the two answers agree': probability 1 for the imitator, 1/2 for the human system
```

**`property-batch_cert.py`** (Section 6). In (1) the scaffold has six inputs, three answers and horizon 3, with runs of variable length; a(B) and h(B) are computed exactly by recursion over the tree of runs.

```
(1) Theorem 6.1, m=   50, 18 singleton tests, 2000 random (imitator, human) pairs: failures of (b) divergence form 5, of (a) paired form 0, of 'never seen => h(B) <= ln(2/(pi delta))/m' 1 (allowed 10% = 200)
(1) Theorem 6.1, m=  400, 18 singleton tests, 2000 random (imitator, human) pairs: failures of (b) divergence form 18, of (a) paired form 0, of 'never seen => h(B) <= ln(2/(pi delta))/m' 2 (allowed 10% = 200)
(1) Theorem 6.1, m= 3000, 18 singleton tests, 2000 random (imitator, human) pairs: failures of (b) divergence form 16, of (a) paired form 0, of 'never seen => h(B) <= ln(2/(pi delta))/m' 2 (allowed 10% = 200)
(2) Theorem 6.2(c), u=6, m=4, exact rationals, 100 random adaptive procedures without repeated questions:
    average over all 2^u functions f of Pr_f[accept] equals Pr_coin[accept]: True
    100 procedures that may repeat questions: |average - coin| <= Pr_coin[some question repeated]: True (largest gap 0.2812)
    i.i.d. inputs, u=50, m=5: Pr_coin[accept] = 0.3519, E_f Pr_f[accept] = 0.3584, collision bound C(m,2)/u = 0.2000
    i.i.d. inputs, u=2000, m=5: Pr_coin[accept] = 0.3538, E_f Pr_f[accept] = 0.3550, collision bound C(m,2)/u = 0.0050
    i.i.d. inputs, u=2000, m=30: Pr_coin[accept] = 0.3342, E_f Pr_f[accept] = 0.3340, collision bound C(m,2)/u = 0.2175
(3) Example 6.3, d=5: for 500 random tests that ignore one input bit, the parity function and the fair coin have exactly equal frequencies: True
```

**`property-batch_editor.py`** (the editor's checks of what was changed or added after the verification; 15 seconds). Probabilities that are compared with a bound are computed in exact rational arithmetic.

```
(E1) Theorem 2.5(c), remark: one test of weight 1, N = 4; exact failure probability of the draft's joint statement
    delta = 0.3400: tol = 0.47063, ln(1/delta)/N = 0.26970, failure probability = 0.3470  (> delta)
    delta = 0.3320: tol = 0.47378, ln(1/delta)/N = 0.27566, failure probability = 0.3417  (> delta)
    delta = 0.3315: tol = 0.47398, ln(1/delta)/N = 0.27603, failure probability = 0.2805  (<= delta)
(E2) Lemma 2.8 (Remark 2.7(4)): exact Pr[largest of M deviations >= t*] against 1 - exp(-(N+1))
    N =  10, M = 1.33e+03: t* = 0.1448, Pr[one event deviates] = 1.719e-01 >= 8.264e-03, ln Pr[none of M deviates] = -251 <= -11; (1/2)sqrt(ln M/(3N)) - 1/N = 0.1448 (<= t*, M >= (N+1)^3)
    N =  30, M = 2.98e+04: t* = 0.1358, Pr[one event deviates] = 4.937e-02 >= 1.041e-03, ln Pr[none of M deviates] = -1.51e+03 <= -31; (1/2)sqrt(ln M/(3N)) - 1/N = 0.1358 (<= t*, M >= (N+1)^3)
    N =  30, M = 1e+08: t* = 0.2769, Pr[one event deviates] = 7.155e-04 >= 3.100e-07, ln Pr[none of M deviates] = -7.16e+04 <= -31; (1/2)sqrt(ln M/(3N)) - 1/N = 0.1929 (<= t*, M >= (N+1)^3)
    N = 100, M = 1.03e+06: t* = 0.0974, Pr[one event deviates] = 2.844e-02 >= 9.803e-05, ln Pr[none of M deviates] = -2.97e+04 <= -101; (1/2)sqrt(ln M/(3N)) - 1/N = 0.0974 (<= t*, M >= (N+1)^3)
    N = 100, M = 1e+20: t* = 0.2934, Pr[one event deviates] = 5.580e-10 >= 1.010e-18, ln Pr[none of M deviates] = -5.58e+10 <= -101; (1/2)sqrt(ln M/(3N)) - 1/N = 0.1859 (<= t*, M >= (N+1)^3)
    N = 400, M = 6.45e+07: t* = 0.0587, Pr[one event deviates] = 9.331e-03 >= 6.219e-06, ln Pr[none of M deviates] = -6.04e+05 <= -401; (1/2)sqrt(ln M/(3N)) - 1/N = 0.0587 (<= t*, M >= (N+1)^3)
    N = 400, M = 1e+40: t* = 0.2213, Pr[one event deviates] = 1.091e-19 >= 4.010e-38, ln Pr[none of M deviates] = -1.09e+21 <= -401; (1/2)sqrt(ln M/(3N)) - 1/N = 0.1360 (<= t*, M >= (N+1)^3)
    all inequalities of the proof hold: True
(E3) least total variation between the run law of a stateless sampler and the repeating human: 0.414215 at p = 0.29290 (sqrt(2) - 1 = 0.414214, 1/sqrt(2) = 0.70711 or its mirror image)
(E4) closed memoriser class, u = 4, K = 30, C_R = 5, one pair seen, unseen input: violating 0.7111, no answer 0.1778, abiding answer 0.1111; given an answer: violating 0.8649 (1 - 1/C_R = 0.8000)
(E4) closed memoriser class, u = 4, K = 30, C_R = 100, one pair seen, unseen input: violating 0.8800, no answer 0.0089, abiding answer 0.1111; given an answer: violating 0.8879 (1 - 1/C_R = 0.9900)
(E5) Proposition 4.8(d): least value of (1 - V(D)) / M(D)^(1/k) over 2605 cases = 1.000000 (must be >= 1)
(E6) machine U'', d = 3: codes of g_T, h_T, the decider and the prefix 1 form a prefix-free set: True;
     weight of all g_T = 0.203021 = (1/8)(1+1/(2u))^u: True; of all h_T = 0.012689 = (1/128)(1+1/(2u))^u: True; decider 2^-6; total without the programs of U = 0.2313
     (weight of g_T + weight of h_T) / weight of h_T = {Fraction(17, 1)} (closure constant of the memoriser part)
     lower bound M_D(b|x) >= (16/17)(2u/(2u+1))/(1 + 2^(3-c)(4u)^k) for k >= 1, V >= 0.5134 for 1 <= k <= min(u/4,(c-5)/(d+2)), V >= 0.70 for k = 0: True
     least V over the admissible k, by c: {10: 0.6717, 15: 0.571, 20: 0.661, 30: 0.6644}  (3/4)(16/17)(10/11)(4/5) = 0.5134
(E7) coin bound V(D_n) <= 1/2 + (k_c ln 2 + ln(1/delta))/(2n) in the classes of Proposition 4.10 [(1048576, 1000, 20), (16, 40, 3), (16, 40, 30), (1024, 300, 100)], n < 60: True
(E8) Proposition 6.4: E[s] = sum_y (P(y)-A(y))^2 and TV <= (sqrt(q)/2) d on 2130 pairs of laws (q = 2, 3, 4): True; range of s: [-1/2, 2] (claimed: within [-1/2, 2])
(E9) Theorem 6.6: one input asked r times; exact total variation of the two laws of the answers against C(r,2)/s
     s =      4, r =   2: TV = 0.25000, bound C(r,2)/s = 0.25000
     s =      4, r =   3: TV = 0.37500, bound C(r,2)/s = 0.75000
     s =      8, r =   3: TV = 0.28125, bound C(r,2)/s = 0.37500
     s =     16, r =   4: TV = 0.25635, bound C(r,2)/s = 0.37500
     s =    256, r =   2: TV = 0.00391, bound C(r,2)/s = 0.00391
     s =    256, r =   8: TV = 0.09543, bound C(r,2)/s = 0.10938
     s =   4096, r =   8: TV = 0.00678, bound C(r,2)/s = 0.00684
     s =   4096, r =  32: TV = 0.10175, bound C(r,2)/s = 0.12109
     s =  65536, r =  32: TV = 0.00749, bound C(r,2)/s = 0.00757
     s =  65536, r = 128: TV = 0.10322, bound C(r,2)/s = 0.12402
     TV <= C(r,2)/s in all cases: True
     brute force over all halves (exact): s=4 m=2 same input: 0.2500 <= 0.2500; s=4 m=2 adaptive, two inputs: 0.2500 <= 0.2500; s=4 m=3 same input: 0.3750 <= 0.7500; s=4 m=3 adaptive, two inputs: 0.2500 <= 0.7500; s=4 m=4 same input: 0.6562 <= 1.5000; s=4 m=4 adaptive, two inputs: 0.4688 <= 1.5000; s=6 m=3 same input: 0.3333 <= 0.5000; s=6 m=3 adaptive, two inputs: 0.1667 <= 0.5000; s=6 m=4 same input: 0.3889 <= 1.0000; s=6 m=4 adaptive, two inputs: 0.3519 <= 1.0000; s=8 m=3 same input: 0.2812 <= 0.3750; s=8 m=3 adaptive, two inputs: 0.1250 <= 0.3750
     all within the bound, and the one-input cases equal the closed form: True
(E10) memorisers with a prior lam(b) on the default answer, u = 4, K = 30, one pair seen: M_D(b|x) = 0.889 for lam(b) = 1, 0.444 for lam(b) = 1/2, 0.018 for lam(b) = 1/50 ; equals lam(b) x value of Theorem 4.5(b): True
```

Reading: (E1) the draft's joint form of Pr3 fails at δ = 0.332 and not at δ = 0.3315. (E2) every inequality in the proof of Lemma 2.8 holds in the cases tried. (E6) the three claims of Theorem 4.11(B) hold in an enumeration of all 6561 tables for d = 3 with the programs of U replaced by the worst case. (E9) the bound of Theorem 6.6(b) holds and is close to the exact value; the exact values for one input agree with those computed independently by the attack report. What these checks do not show: they are for small spaces, and for (E6) and (E9) they cover the statements only in the cases listed; the statements rest on the proofs.

**The verifiers' scripts** (`property-batch_check_*.py`, five scripts, and `property-batch_attack_*.py`, five scripts) and their outputs are in `proofs/code/` as well. What each checks is listed in Part VI of the check report and in Section 6 of the attack report. The blocks that this file cites: `property-batch_check_sec4.out`, block 9 (the machine U″); `property-batch_attack_pr4.out`, blocks 4 and 7 (the member nearest to the empirical measure in Example 3.11(a); the human who repeats himself); `property-batch_attack_pr2.out`, blocks B, H and J (silence in the floor; the prior on the default answer; Proposition 4.15); `property-batch_attack_sec56.out`, blocks B, D, E, E2, F, G (Proposition 5.4; the two averages; procedures that repeat a question; Proposition 6.4; large answer sets; Example 6.3); `property-batch_attack_twosided.out` (Proposition 6.5); `property-batch_attack_sec2.out`, block D, and `property-batch_check_joint25c.out` (the joint statement of the draft's Pr3).

---

## 10. References

How each source was accessed is stated where it is used (Sections 2, 3.6, 4.3, 5.2, 6.3). In one place; "this session" in an entry written by the prover means the prover's session, and what the verifiers and the editor read is said entry by entry:

* W. Hoeffding, "Probability inequalities for sums of bounded random variables", *J. Amer. Statist. Assoc.* 58 (1963) 13–30. From memory. Theorem 1 (binomial tails in divergence form) is proved here as Lemma 2.1; Theorem 2 (independent bounded summands) is used as a standard fact in Proposition 5.2 and Theorem 6.1(a).
* J. Ville, *Étude critique de la notion de collectif*, Gauthier-Villars 1939. From memory; nothing rests on the citation, because the inequality is proved in two lines inside the proof of Theorem 4.7(b).
* Y. G. Yatracos, *Annals of Statistics* 13(2) (1985) 768–774. Not read; see 3.6.
* L. Devroye and G. Lugosi, *Combinatorial Methods in Density Estimation*, Springer 2001. Not read; Theorems 6.2 and 6.3 as restated by Mahalanabis and Štefankovič, see 3.6.
* S. Mahalanabis and D. Štefankovič, "Density estimation in linear time", arXiv:0712.2869v1 (2007). Read by the prover (Sections 1, 2.1 and 4 of the arXiv version; the conference version, COLT 2008, was not read) and in the PDF by both verifiers, who found the account of Section 3.6 exact; the attack report also read Theorem 10 (for two densities a randomised rule that returns a member has E‖f − g‖₁ ≤ 2·d₁(g, F) + Δ). Not opened by the editor.
* S. Compton and J. Li, "Density estimation for Hellinger via minimum-distance estimators: mixtures of Gaussians, log-concave, and more", arXiv:2606.11469v1 (2026). Read by the prover (Section 1.5) and in the PDF by the attack report; the check report saw it through a summary. Not opened by the editor.
* O. Bousquet, D. Kane and S. Moran, "The optimal approximation factor in density estimation", COLT 2019, PMLR 99, 318–341; arXiv:1902.05876v5 (14 December 2025). The prover saw only an automatic summary; both verifiers and the editor read version 5 in the PDF (Sections 1.5 to 1.7 and the statements of Section 5); see 3.6.
* G. Biau and L. Devroye, "Density estimation by the penalized combinatorial method", *J. Multivariate Anal.* 94 (2005) 196–208. Not opened by anyone in this project; named by the attack report; see 3.6.
* A. R. Barron and T. M. Cover, "Minimum complexity density estimation", *IEEE Trans. Inform. Theory* 37(4) (1991) 1034–1054. From memory; not used in any proof.
* L. Trevisan, M. Tulsiani and S. Vadhan, "Regularity, boosting, and efficiently simulating every high-entropy distribution" (2009). Not read; cited through `research/understand/indistinguishability.md`.
* C. Dwork, M. P. Kim, O. Reingold, G. N. Rothblum and G. Yona, "Outcome indistinguishability", arXiv:2011.13426v1 (26 November 2020; STOC 2021, pp. 1095–1108, according to `research/sections/related-work.md`). Read in the PDF by the attack report (Section 1) and by the editor (Sections 1, 1.1, 1.2, the start of Section 4 and Section 5.4); the sentences used are quoted after Corollary 2.6 and after Proposition 5.2.
* Ú. Hébert-Johnson, M. P. Kim, O. Reingold and G. N. Rothblum, "Multicalibration: calibration for the (computationally-identifiable) masses", ICML 2018, PMLR 80, 1939–1948. Not opened in this part; cited as in `research/sections/related-work.md`.
* J. Langford, "Tutorial on practical prediction theory for classification", *J. Mach. Learn. Res.* 6 (2005) 273–306. Not opened (the journal's site could not be reached by the attack report, which confirmed volume and pages by a search); the Occam's razor bound is quoted from memory by both reports. Nothing rests on it: Theorem 2.3 is proved here.
* A. Blumer, A. Ehrenfeucht, D. Haussler and M. K. Warmuth, "Occam's razor", *Inform. Process. Lett.* 24 (1987) 377–380. From memory (attack report); not opened.
* D. McAllester, "Some PAC-Bayesian theorems", *Machine Learning* 37 (1999) 355–363. Statement from memory (attack report; journal data confirmed there by a search); not opened.
* T. Batu, L. Fortnow, R. Rubinfeld, W. D. Smith and P. White, "Testing closeness of discrete distributions", arXiv:1009.5397v2 (4 November 2010), the journal version of "Testing that distributions are close", FOCS 2000, 259–269. Read by the editor in the PDF (Section 1.1, the statement of Theorem 2 with the test of Figure 1, and the beginning of Section 2.1); see the attribution after Proposition 6.4.
* O. Goldreich and D. Ron, "On testing expansion in bounded-degree graphs", ECCC TR00-020 (2000). Not opened; cited as Batu et al. cite it.
* L. Paninski, "A coincidence-based test for uniformity given very sparsely sampled discrete data", *IEEE Trans. Inform. Theory* 54 (2008) 4750–4755. Not opened; cited as Batu et al. describe it and as `research/sections/related-work.md` lists it. Not used in any proof.
* C. McDiarmid, "On the method of bounded differences", in *Surveys in Combinatorics 1989*, London Math. Soc. Lecture Note Series 141, Cambridge University Press, 148–188. From memory (attack report and editor); the inequality is used in its standard form in Proposition 6.5.
* Project files: `research/outline.md`, `research/candidate-theory.md`, `note.md`, `proofs/hellinger-runs.md` (Theorem A, which the note calls H1; Theorem R1 in its Appendix A), `proofs/rehearsal-core.md` (Theorem 5.1, which is R1), `proofs/lower-bounds.md` (Theorems 6.1 and 6.3), `research/prove-b/property-batch.md`, `research/sections/related-work.md`, `research/understand/notes.md` (Q5), `research/understand/indistinguishability.md`.


---

## 11. Checking

Written by the editor. The proofs of this part were examined by two verifiers: a line-by-line check (`research/verify/property-batch-check.md`, "check" below) and an adversary (`research/verify/property-batch-attack.md`, "attack" below). Both reports exist and are complete. Neither found a numbered statement of the prover's file wrong. Both found that the reading of Theorem 4.11 was not supported by the machine it constructed, and the attack report found that one sentence about what can be certified for a human who is not deterministic is false as it stood. The editor verified each finding before deciding it: by hand in every case, and by computation where the tables below name a block of `proofs/code/property-batch_editor.out`. The editor also read every proof of the file once; the proofs that a finding touched were re-derived, and for the others the editor relies on the two reports, as Section 11.3 says statement by statement.

### 11.1 Findings of the check report

Numbers III.n are those of Part III of the report ("corrections that must be made"); the other rows are remarks made in its Parts II and IV.

| finding | decision | what was done |
|---|---|---|
| III.1 On the machine U′ of Theorem 4.11 the property R costs at least c + 1 bits and the closure constant is at least 2^(c−1), so the theorem does not show that the violation probability at a fresh input is "not bounded in terms of K(R)" for a universal class. Repair: the machine U″. | Accepted. Verified by hand: every decider of R and every conditioned memoriser on U′ lies behind the prefix 1^c. The repair was verified by hand and by enumeration, block (E6). | Theorem 4.11 now has parts (A) (the prover's statement, unchanged) and (B) (the machine U″, with a written proof). The reading was rewritten ("What (B) shows", "What (B) does not show"). Changed with it: the summary table, "In brief" at the top and in Section 4, the sentence after Proposition 4.9, items 3 and 4 of 4.13, item 3 of Section 8.2, item 1 of Section 8.1. |
| III.2 `note.md`, Section 8.5: the two halves of the placeholder hold in different classes; "abiding" must read "not violating"; the section must say what does hold at a fresh input. | Accepted. | The section text (`research/sections/property-batch.md`, 8.5) is written accordingly. |
| III.3 `note.md`, Section 8.2: "nothing is assumed about the human" and "each input is seen once" say more than is proved; state Theorem 6.2 with its provisos; add the caveat of Proposition 5.2 and Example 5.3. | Accepted. | Section text, 8.2 and 8.6; paragraphs "What it assumes about the human" after Theorem 6.1 and "Correction of the reading" after Theorem 6.2. |
| III.4 The conclusion of Theorem 6.2(d) is one-sided; the summary said "cannot tell". | Accepted. Verified: "ask input 0, accept iff the answer is 0" accepts the coin with probability 1/2 and every function with probability 0 or 1. | Summary table, "In brief" (5), new paragraph "Statement (d) is one-sided"; a two-sided form was added as Proposition 6.5. |
| III.5 Example 3.11(a): the sentence on Bousquet, Kane and Moran needs the quantifiers of their Theorems 19 and 21; cite version 5. | Accepted. The editor read version 5 of the paper (Sections 1.5 to 1.7, Theorems 19 and 21, Corollary 20, Remark 1). | The sentence was replaced by the paragraph "What is known for other estimators"; the literature entry in 3.6 and the reference in Section 10 were rewritten. |
| III.6 Theorems 4.2 and 4.7(b) need the convention 0·∞ = 0; in the summary the bound (K ln 2 + ln(1/δ))/n of Theorem 4.7 needs the human in the class. | Accepted. | One sentence in each statement; summary row of Theorem 4.7. |
| III.7 Corollary 4.6: the floor 1 − 1/C_R is approached, not attained. | Accepted. The value carries the factor 2u/(2u + 1) < 1. | Title, summary row, last sentences of the statement, "In brief" of Section 4. |
| III.8 Proposition 4.8(d) applies Theorem 4.7(c), which holds on an event, to a fixed data set; one line is missing. Fill: 1 − V(D) ≥ M(D)^(1/k) for every data set. | Accepted. The fill was re-derived (Jensen for t^(1+1/k)) and checked, block (E5). | Statement (d) and its proof. |
| III.9 Theorem 2.5: "the example needs δ close to 1" is not exact (δ = 0.34 is enough). | Accepted, with the sharper value of the attack report (δ = 0.332); both recomputed, block (E1). | The remark after the counterexample was replaced; Section 8.1, item 4. |
| III.10 Remark 2.7(4) is "not used below" but Section 5.1 rests on it; mark it as unproved or add the proof that the report sketches. | Accepted. The proof was added. The editor completed the sketch (the case t* < 0; the lower bound for a binomial coefficient through the mode of the binomial law) and checked every inequality, block (E2). | Lemma 2.8 with its reading; Remark 2.7(4) and Section 5.1 point to it. |
| III.11 Attributions: Theorem 2.3 is standard; the tag NEW must not reach the note; Corollary 2.6 needs the attribution of the outline; the lazy sampling of Theorem 6.2 is a standard device. | Accepted. | The tag was renamed ADDED and defined as "not in the lead's list"; "What it is" after Theorem 2.3; "Attribution" after Corollary 2.6 and after Proposition 5.2; header of Theorem 6.2. |
| III.12 Wording: Theorem 3.10 ("at confidence 1 − 2δ"); (C4) (the count for tol* and tol′ is (δ/4)·e^(2N)); summary row of Theorem 3.3 ("2·tol*"). | Accepted. The count was recomputed. | The three places. |
| III.13 Letters used twice (T, η, S). | Accepted in part. `research/outline.md`, Addendum 3, lets proof files keep their letters, and renaming the tables throughout four statements would risk new errors. | A note "Letters with two uses" in Section 1; the section text avoids the double uses. |
| II, Lemma 1.1: measurability of the maps next_j is used tacitly. | Accepted. | One word and a parenthesis in Section 1.1. |
| II, Section 3.5: (C1) could say how long the list of candidates is. | Accepted (also Finding m7 of the attack). | (C1). |
| II, Theorem 4.11: on every machine with a cheap coin, V(D_n) ≤ ½ + (k_c ln 2 + ln(1/δ))/(2n) for humans with binary answers. | Accepted. Re-derived from Theorem 4.7(c); checked, block (E7). | 4.13, item 5. |
| II, 4.13: item 4 should mention the coin and say that a bound involving the composition constant of the machine is not excluded. | Accepted. | 4.13, items 4 and 5. |
| II, Remark 2.7(2): the parenthesis about martingales is vague and unproved. | No change needed: the file already says "not needed here and not proved here", and nothing rests on it. It is listed as open (Section 8.1, item 5). | — |
| II, Proposition 5.2: the coin lies in 𝓜_N only with the tolerance (1 + √(N/u))·tol_N; the file claims only that it meets the conclusion of Corollary 2.6. | Noted; no error. Superseded by Proposition 5.4 (membership with probability 1 − δ − C(N, 2)·coll(μ)). | Proposition 5.4. |
| IV, `note.md`, Section 8.1: say what an additive error does not control; R1 gives whole runs only for a deterministic human; outside the class the batch estimator gives three times the best distance. | Accepted. | Section text, 8.1 and the subsection on the batch estimator. |
| IV, the sentence of the candidate theory "one learner, no prior belief needed, both regimes; and robust when the human is not a stateless sampler" must not be carried over. | Accepted. | Not carried into the section text; Section 5.1 says that no single rule is shown to have both guarantees outside the class; item (3) after Corollary 3.7 has the example of a human with memory. |

### 11.2 Findings of the attack report

| finding | decision | what was done |
|---|---|---|
| M1 "Frequencies of tests are all that can be checked for a human who is not deterministic" is false as the note and the Reading of Theorem 6.2 put it: A1 allows a question to be put twice, and two answers per probe estimate Σ_y (P(y\|x) − A(y\|x))². | Accepted. Verified by hand (the procedure "put one input twice, accept iff the answers agree"; the identity E[s] = d²) and in block (E8). | The Reading of Theorem 6.2 was restricted to procedures that put each input once or repeat with small probability; a paragraph "Correction of the reading" was added; the attack's Proposition X1 became Proposition 6.4. The part of the finding "where the sentence is true" (answers from a very large set), which the report supported by exact numbers only, was given a proof: Theorem 6.6, block (E9). The section text states Pr7 with these quantifiers. |
| M1, smaller points: (a) Theorem 6.2(d) is one-sided; (b) Example 6.3 is not an example of indistinguishability. | Accepted. | As for III.4 of the check; the sentence after Example 6.3 and its row in the summary table. |
| M2 Standard results carry the tag NEW; Section 8.2 of the note has no attribution. Sources: Dwork et al. for Proposition 5.2 and Theorem 6.2; the Occam's razor bound for Theorem 2.3; Mahalanabis and Štefankovič, and Biau and Devroye, for Theorem 3.6; McAllester for Theorem 4.7. | Accepted. The editor read the passages of Dwork et al. in the source. The papers of Langford, Blumer et al., McAllester, and Biau and Devroye were not opened by anyone; each citation says so. | Tag renamed; attributions after Theorem 2.3, Corollary 2.6, Theorem 4.7 and Proposition 5.2; entry for Biau and Devroye in 3.6; Section 10. |
| M3 (a) The gap in the reading of Theorem 4.11 (confirmation of the check's finding, with an independent repair). (b) Even after the repair the statement is about the prior: the level "near 1" is the prior probability that a memoriser violates R off its table; on a fixed machine the added memorisers lose to the coin after a number of questions that is a constant of the machine; for one fixed machine the positive statement is a mathematical question, and open. (c) The title of Section 8.5 should say "need not". | Accepted, all three. (b) was verified: the level with a prior λ on the default answer in block (E10); the share 0.42·2^(c+k_c−n(d+1)) by hand. For the fixed-machine question the editor found neither a proof nor a counterexample. | (a) as III.1 of the check. (b) remark (3) after Theorem 4.5; 4.13, items 4 and 6; "What (B) does not show". (c) section text, title and body of 8.5. |
| m1 The draft's joint form of Pr3 fails already at π(R)δ = 0.332 (N = 4). | Accepted; recomputed, block (E1). | Remark after Theorem 2.5. |
| m2 (IID) is an assumption about the human across runs; "nothing is assumed about the human" drops it. | Accepted. | Section 1.2; Remark 2.7(1); summary row of Theorem 2.3; table of Section 7; section text. |
| m3 The oracle inequality is empty for a human with memory inside a run unless the class has such hypotheses: for the human who repeats a fair bit the best stateless sampler is at total variation √2 − 1. | Accepted; recomputed by hand and in block (E3). | Item (3) of "What Theorem 3.6 does not say"; table of Section 7; section text. |
| m4 Example 3.11(a): the quantifier of the lower bound of Bousquet, Kane and Moran; on the four-point space the nearest member does far better; the factor 3 in expectation is not known to be best possible. | Accepted (the first part is III.5 of the check). The editor read in the source that the lower bound is for a success probability above 2/3 (Corollary 20) and that Mahalanabis and Štefankovič have a randomised factor 2 for two densities (reported in Section 1.6). | Paragraph "What is known for other estimators"; item (5) after Corollary 3.7; Section 8.1, item 8. |
| m5 (a) The floor of Corollary 4.3(c) may be made of silence. (b) In the note's model, where a sampler always answers, (Cl_R) cannot hold as stated. Proposition X3 is a form that can. | Accepted. (a) recomputed by enumeration, block (E4). (b) verified by hand. X3 was re-derived. | Remark 4.14 and Proposition 4.15 (new Section 4.6); pointers in Corollary 4.3(c), 4.13 item 1, the table of Section 7 and the summary; section text, 8.5. |
| m6 The universal family of tests (all decidable events, price K(R)) cannot be used as defined: listing its tests needs the programs that halt on every input. | Accepted. | Section 1.3; (C4). |
| m7 Computing the estimate takes of the order of e^(2N) comparisons in general. | Accepted. | (C1). |
| m8 The coin is a member of 𝓜_N, not only inside the conclusion of Corollary 2.6 (Proposition X4). | Accepted; re-derived. | Proposition 5.4; Remark 2.7(6). |
| m9 Confirmations of four findings of the check (0·∞; "attained"; Proposition 4.8(d); Remark 2.7(4)). | As for III.6, III.7, III.8, III.10. | — |
| w1 `note.md`, Section 8.1: "at the price K" must name the horizon. | Accepted. | Section text, 8.1. |
| w2 `note.md`, Section 8.2: the price in that paragraph is the price of checking a property of a given imitator. | Accepted. | Section text, 8.2. |
| w3 `note.md`, Section 8.2: the conflict between properties is moved to inputs rarer than the tolerance, not removed. | Accepted. | Section text, 8.2; item (v) of the summary 5.3. |
| w4 V1(b): the recorded frequencies must be counts divided by m, empty rounds counted as zero. | Accepted; the example was recomputed by hand (9/16 against 3/4). | Paragraph "Which average" after Theorem 6.1; the editor's notes of the section file pass it on for Section 3.3, where V1(b) is stated. |
| w5 Rows of the summary table (Theorem 6.2 and Example 6.3; Theorem 4.11; Theorem 2.3; Theorem 4.7). | Accepted. | Summary table. |
| w6 Table of Section 5.1: add what the human must do. | Accepted. | New row and the paragraph after the table. |
| Section 2, guard: with the per-call certificate the factor L returns for a property of a run. | Accepted. | "What it does not certify" after Theorem 6.1. |
| Section 2, machine: Pr2(b) and (c) are facts about the prior. | Accepted (it is M3). | As for M3. |
| Section 2, referent: for a closed system with a fixed top-level input and no randomness, the replay of the N recorded runs lies in 𝓜_N. | Accepted; verified by hand. | Remark 2.7(6). |
| Section 2, copy: of the two prices only the first distinguishes the sampler from one of its fill-ins. | Accepted. | Last paragraph of Section 5.1; item (iv) of the summary 5.3. |
| Section 2, budget: Pr3 in batch form and Pr4 need N whole runs of the human system; numbers. | Accepted; the numbers were recomputed. | Row and paragraph in Section 5.1; section text. |
| Section 2, rock: for one decidable property a filter enforces it; what Pr3 adds is the list. | Accepted. | Remark 2.7(7); the sentence was cut from the section text for length and is offered in its editor's notes. |
| Section 3, the table of what is not new. | Accepted. The row for Theorem 4.2 was checked against `research/understand/notes.md`, Q5, and made more exact: the researcher's notes state the floor without proof, and the hindsight bound is the digest author's derivation. | "Where it comes from" after Theorem 4.2; the attributions named under M2. |
| Section 4, the citations. | Accepted. | Sections 3.6 and 10. |
| Section 5, Propositions X1 to X4 (the report's own additions, checked there numerically, read by no second person). | Accepted after re-derivation by the editor. | Propositions 6.4, 6.5, 4.15 and 5.4. They are marked in the summary table and in Section 8.1, item 11, as not examined by a second verifier. |

No finding of either report was rejected. One was accepted in part (III.13 of the check), and one needed no change (the remark on Remark 2.7(2)).

### 11.3 Who checked which proof

"Both" means: verdict CORRECT (or MINOR, with the fix applied here) in the check report, and HOLDS (or HOLDS WITH CHANGE, with the change applied here) in the attack report. The middle column says where the section text `research/sections/property-batch.md` uses the statement.

| statement | used in the section text | checked by |
|---|---|---|
| Statement 2.0 (Pr1) | 8.1 | both |
| Theorem 2.3, Corollaries 2.4 and 2.6 (Pr3) | 8.2 | both |
| Theorem 2.5 (the draft's form; the joint confidence) | not in the text; in the editor's notes of the section file | both; the remark on δ = 0.332 also by the editor, (E1) |
| Lemma 2.8 | not in the text; in the editor's notes (it supports "neither price can be lowered", Section 5.1) | sketched by the check; proof completed and checked by the editor, (E2); the attack's exact medians agree with the remark and do not prove it. No second verifier read the final proof. |
| Theorem 3.3, Proposition 3.8 (the draft's estimator; both prices in the class) | not in the text; in the editor's notes | both |
| Theorem 3.6, Corollary 3.7 (Pr4) | batch estimator | both |
| Section 3.5, Theorem 3.10 (Proposition 3.9 is not used) | batch estimator (what must be computable) | both (Theorem 3.10 by the attack by simulation only) |
| Example 3.11(a) (the factor 3 is attained by the estimator) | batch estimator | both; the statement about other estimators was read in the source by both verifiers and the editor |
| the human who repeats himself (item (3) after Corollary 3.7) | batch estimator | attack; recomputed by the editor, (E3) |
| Theorem 4.2, Corollary 4.3 (Pr2(a)) | 8.5 | both |
| Remark 4.4 (the class of all programs is closed with C_R = 2^(K(R)+c)) | 8.5, one clause | no one: standard facts that the file does not prove; the check calls it correct as a statement of standard facts, the attack NOT VERIFIED. The section text marks the clause. |
| Remark 4.14 (silence in the floor) | 8.5 | attack; recomputed by the editor, (E4) |
| Proposition 4.15 (a conditioning that always answers) | 8.5, one clause | attack (statement, proof, numerical check); re-derived by the editor. No second verifier. |
| Theorem 4.5, Corollary 4.6 (Pr2(b)) | 8.5 | both |
| remark (3) after Theorem 4.5 (the level is a parameter of the class) | 8.5 | attack; recomputed by the editor, (E10) |
| Theorem 4.7 (foresight) | 8.5 (part (d); part (f) in the editor's notes) | both |
| Proposition 4.8 (the trade-off is attained) | not in the text; in the editor's notes | both; the fill of (d) by the check and the editor, (E5) |
| Proposition 4.9 (rehearsal) | 8.5 | both, given Theorem R1, which belongs to the part rehearsal-core; the check verified the step of R1 that is used with exact expectations |
| Theorem 4.11(A) | not used | both |
| Theorem 4.11(B) (Pr2(c), the machine U″) | 8.5 | check (construction, enumeration); attack (the three claims recomputed by hand; the repair found independently); editor (proof written out, (E6)). Part (B2) rests on the standard facts of Remark 4.4. |
| Propositions 4.10 and 4.12 | not used | both |
| 4.13, item 4 (one fixed machine) | 8.5 (stated as open) | open; neither report nor the editor has a proof or a counterexample |
| 4.13, items 5 and 6 | not in the text; item 5 in the editor's notes | item 5: check (proposed, with the proof) and editor, (E7); item 6: attack and editor |
| Proposition 5.2, Example 5.3 (the coin; the same question twice) | 8.2 | both |
| Proposition 5.4 | not used | attack (statement, proof, exact small cases); re-derived by the editor. No second verifier. |
| Theorem 6.1 (V1(b)) | 8.2 | both |
| Theorem 6.2 (Pr7, first half) | 8.6 | both |
| Proposition 6.4 (two answers per probe) | 8.6 | attack (statement, proof, numerical check); re-derived and checked by the editor, (E8). No second verifier. |
| Proposition 6.5 | not used | attack (statement, proof, numerical check); re-derived by the editor. No second verifier. |
| Theorem 6.6 (Pr7, second half) | 8.6 | editor only (proof; exact enumeration (E9), whose one-input values agree with the attack's block F). No verifier examined it. The section text marks it "not independently checked". |
| Example 6.3 | not used | both |

### 11.4 What the editor did and did not do

Done: both reports read in full; every finding decided after verification as stated in the tables; the passages of two sources read (Bousquet, Kane and Moran, version 5; Dwork et al.) and one source added and read (Batu et al.); all sixteen scripts of the part run again in `proofs/code/`, fifteen of them reproducing their saved outputs exactly; one script written (`property-batch_editor.py`).

Not done: the proofs that both reports found correct and that no finding touched were read by the editor but not recomputed constant by constant (Lemmas 1.1, 2.1, 2.2, 3.2, 3.5; Theorems 2.3, 3.3, 3.6, 3.10; Propositions 3.8, 3.9; Theorems 4.2, 4.5, 4.7; Propositions 4.10, 4.12; Proposition 5.2; Theorems 6.1, 6.2). The standard facts of Remark 4.4 were not proved. Theorem R1 and the lower bounds of `proofs/lower-bounds.md` were not examined; they belong to other parts. The papers of Yatracos, Devroye and Lugosi, Hoeffding, Ville, Langford, Blumer et al., McAllester, Biau and Devroye, Goldreich and Ron, Paninski, McDiarmid, Barron and Cover, Trevisan et al., and Hébert-Johnson et al. were not opened by the editor; Section 10 says for each who, if anyone, opened it.
