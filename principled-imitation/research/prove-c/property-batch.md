# The property idea in batch form: Pr1 to Pr4, the Bayes mixture and a simple property, the certificate (key: property-batch)

Prover's file, third round. Sections 1 and 2 were written by the earlier worker (`research/prove-b/property-batch.md`); I checked them line by line, found them correct, closed one small gap (the case q ∈ {0, 1} in the proof of Lemma 2.1) and changed some letters so that the file agrees with `research/outline.md`. Sections 3 to 10 were written in this round. Every statement is proved in this file unless it is tagged otherwise. The numerical checks are in `research/prove-c/code/property-batch_*.py`; their output is saved next to them as `*.out` and quoted in Section 9.

Tags: **PROVED** (complete proof below), **REFUTED** (counterexample below), **MODIFIED** (the draft's statement is changed, and the change is stated), **NEW** (not in the candidate theory; proved below), **OPEN**.

## Summary of the statements

N is the number of independent recorded runs of the human system, n a number of question–answer pairs, m a number of validation questions; K is the description length of the human, K(ν) that of a hypothesis, K(R) the price in bits of a test or property.

| no. | statement | tag |
|---|---|---|
| Lemma 1.1 | The law of a run answered by a sampler has the density Π_j ν(y_j\|x_j) with respect to one reference measure; it is read off the transcript. | PROVED |
| Statement 2.0 (**Pr1**) | TV ≤ ε is the same as "every event of runs within ε". | PROVED (definition) |
| Lemmas 2.1, 2.2 | Binomial tails in divergence form; three lower bounds on kl. | PROVED (standard) |
| Theorem 2.3, Corollary 2.4 (**Pr3**) | For a weighted family of tests of runs, with probability 1 − δ, kl(Q̂_N(R)‖Q(R)) ≤ ln(2/(π(R)δ))/N for all R; the Hoeffding form, a relative form, and Q(R) ≤ ln(2/(π(R)δ))/N for tests that never occurred. No assumption on the human system beyond independent runs. | PROVED (the divergence form is NEW) |
| Theorem 2.5 (**Pr3** as drafted) | (a) \|Q̂_N(R) − Q(R)\| ≤ tol_N(R) for all R at confidence 1 − δ; (b) Q(R) ≤ ln(1/(π(R)δ))/N for all tests that never occurred, at confidence 1 − δ; (c) both together at confidence 1 − δ. | (a), (b) PROVED; (c) REFUTED (N = 1, one test), MODIFIED to confidence 1 − 3δ/2 and PROVED |
| Corollary 2.6 | Every imitator that matches the test frequencies is within √(2 ln(2/(π(R)δ))/N) of the human system on each test R, and gives a test that never occurred at most ln(2/(π(R)δ))/N. | PROVED |
| Theorem 3.3 (**Pr4**, human system in the class) | The draft's estimator (highest-weight sampler matching all tests, Yatracos sets with weights w(ν)w(ν′)): TV ≤ √((4K ln 2 + 2 ln(2/δ))/N), and every test of the family within 2·tol. | PROVED; MODIFIED: ln(4/δ) in place of ln(2/δ) when the sets are added to a family that already has weight 1 |
| Definition 3.4, Theorem 3.6 (**Pr4**, any human system) | Penalised one-sided minimum distance. With probability 1 − δ, for every ν in the class: TV(Q_ν̂, Q) ≤ 3·TV(Q_ν, Q) + √((2K(ν) ln 2 + 2 ln(2/δ))/N). A version whose estimator does not depend on δ. | PROVED (announced in the draft as "to be proved"; estimator designed here) |
| Corollary 3.7 | In the class: TV ≤ √((2K ln 2 + 2 ln(2/δ))/N) (2K in place of the draft's 4K). In expectation: E TV ≤ min_ν[3·TV(Q_ν, Q) + √(2K(ν) ln 2/N)] + √(2π/N). | PROVED |
| Proposition 3.8 | The highest-weight sampler that passes one-sided tests: both prices at once, with 2K. | NEW, PROVED |
| Proposition 3.9 | Tests only, any set of candidates, no weights: every near-minimiser of the weighted test discrepancy is within 2·tol_N(R) plus the approximation error in the test seminorm. | NEW, PROVED |
| Section 3.5, Theorem 3.10 | What must be computable: a list of the heavy indices; exact comparison of likelihoods on given runs; the numbers Q_ν(A_νν′), which need a closed system. A version with simulated runs: 2r_N + 2r_{N_s} in the bound. | NEW, PROVED |
| Examples 3.11 | The factor 3 is attained by the estimator; without a penalty the replay of the data wins; outside the class the draft's estimator may be undefined. | PROVED |
| Theorem 4.2, Corollary 4.3 (**Pr2(a)**) | Hindsight: on data that abide by R, the posterior mean of 1/(probability the hypothesis gave to not violating R so far) is at most C_R, for a class closed under conditioning on R with constant C_R (exact definition (Cl_R)). Hence at most ln C_R expected violations over the inputs seen, and never-violators keep posterior weight 1/C_R. | PROVED (closure made exact; "abiding" must mean "not violating") |
| Theorem 4.5 (**Pr2(b)**) | Memorisers: exact value of the mixture's violation probability at a fresh input; above 0.51 for all n ≤ min{u/4, (K − 2)/log₂(4u + 2)}; below 2^(−j) after (K + j)/log₂(4u + 2) distinct inputs. | PROVED |
| Corollary 4.6 | The memoriser class closed under conditioning: the violation probability is (1 − 1/C_R) times that of Theorem 4.5; the floor 1 − 1/C_R is attained, and under closure alone no bound tends to 0 with n. | PROVED (MODIFIES the draft's "stays near 1": near 1 − 1/C_R in a closed class) |
| Theorem 4.7 | Foresight in any class: with probability 1 − δ, for all n, 1 − V(D_n) ≥ (δ·M(D_n)/P(D_n))^(1/n); so V(D_n) ≤ (K ln 2 + ln(1/δ))/n, and a violation level v needs log₂(1/(1 − v)) bits of regret per pair. | NEW, PROVED |
| Proposition 4.8 | Recognisers: the trade-off of Theorem 4.7 is attained (level 1 − σ for K/log₂(1/σ) pairs). | NEW, PROVED |
| Proposition 4.9 | Rehearsal: the expected number of calls of a deployed run that violate R is at most L·K ln 2/n. | PROVED (from Theorem R1) |
| Proposition 4.10 | Memorisers and one fair coin: exact; the violation probability falls after log₂(1/γ)/log₂(2u + 1) questions. | NEW, PROVED |
| Theorem 4.11 (**Pr2(c)**) | For every universal machine U and every c there is a universal machine U′ with K_{U′} ≤ K_U + c for which the mixture violates a constant-length property with probability above 0.54 at fresh inputs for all n ≤ min{u/4, (c − 4)/log₂(4u)}, for every human f. | PROVED |
| Proposition 4.12 | In any class: humans that are typical members of an abiding source S in the class are protected at the price K(S), as long as no input repeats. | NEW, PROVED |
| 4.13, item 4 | A bound in terms of K(R) for "natural" reference machines. | OPEN (no definition of natural; Theorem 4.11 limits what can be true) |
| Proposition 5.2 | A coin matches every test of a family as well as N runs can certify and is at total variation 1/2 from a typical function f. | PROVED |
| Example 5.3 | All per-call tests matched, a constant-price test of runs off by 1/2. | PROVED |
| Theorem 6.1 (**V1(b)**) | The certificate; divergence form with half the tolerance of the note; it is Theorem 2.3 for a derived scaffold of horizon 1. | PROVED (constant improved) |
| Theorem 6.2, Example 6.3 | For every procedure with m single questions there is a deterministic human, at total variation at least 1 − p_max(x) from a stochastic one at every input, with nearly equal test frequencies, that the procedure cannot tell from it except through repeated inputs. | NEW, PROVED |
| Section 8 | Open questions; remarks on other files. | OPEN |

**In brief.** (1) Pr3 holds as a statement about any human system with independent runs; the joint confidence claimed in the draft is 1 − 3δ/2, not 1 − δ. (2) Pr4 holds. In the class the draft's estimator has the stated bound; a one-sided estimator has √((2K ln 2 + 2 ln(2/δ))/N). Outside the class the draft's estimator may be undefined; the penalised minimum-distance estimator satisfies TV ≤ 3·TV(Q_ν, Q) + √((2K(ν) ln 2 + 2 ln(2/δ))/N) for every ν, and the factor 3 is attained. To compute it one needs decidable comparisons of likelihoods and a closed system. (3) Pr2: the hindsight bound holds with the closure constant C_R; at a fresh input the mixture pays the regret, hence K, and not K(R); in a class of memorisers it violates a trivial property with probability above 1/2 for (K − 2)/(bits per pair) questions; a universal reference machine can be chosen to show the same. (4) The two prices are incomparable: a coin can satisfy every test-matching guarantee that N runs allow and be wrong at every call with probability 1/2. (5) The certificate V1(b) is Pr3 for single calls, and for a human who may be non-deterministic nothing beyond frequencies of tests can be certified from single answers at non-repeating inputs.

---

## 1. Setting and notation

The notation is that of `research/outline.md`. The following additions and changes are used throughout.

* **Hypotheses are indices.** The draft's A2 calls H "a countable class of samplers with weights". Two descriptions of the same kernel must be allowed to carry separate weights (this is so in the class of all programs), so here H is a countable index set, each ν ∈ H names a sampler (also written ν), and w(ν) > 0 with Σ_ν w(ν) ≤ 1. K(ν) := log₂(1/w(ν)).
* **Sample sizes.** N is the number of recorded runs of the human system (Sections 2, 3, 5). D_n is a data set of n question–answer pairs ((x_1, y_1), …, (x_n, y_n)) (Section 4). m is the number of validation questions (Section 6). In Section 4 the finite input set has u elements.
* **Semimeasures.** A semimeasure sampler (Σ_y ν(y|x) ≤ 1) is completed by the outcome ⊥ ("no answer") with ν(⊥|x) := 1 − Σ_y ν(y|x). Put Y⊥ := Y ∪ {⊥}. The draft does not say what a scaffold does after ⊥; here a run stops at the first call that is answered ⊥.
* **Letters.** len(τ) is the number of calls of the run τ (the outline keeps T for the deployed round). Γ is the reference measure on runs of Lemma 1.1. R denotes an event of runs (a *test*, Sections 2, 3, 5) or a set of pairs (a *property*, Section 4); B denotes a set of pairs used as a per-call test (Section 6), as in `note.md`. A pair (x, y) is a run of the scaffold that makes one call, so these uses agree. μ is a law on X (Sections 4 to 6) and coll(μ) := Σ_x μ(x)² its collision probability. All other letters are defined in the section that uses them.

**1.1 Runs.** A scaffold Π of horizon L consists of a law D₀ of the top-level input z ∈ Z, a law Λ of the internal randomness ρ (any measurable space), maps next_j(z, ρ, y_1..y_{j−1}) ∈ X ∪ {STOP} for j ≤ L, and an outcome map. A *complete run* is τ = (z, ρ, y_1, …, y_len) with len ≤ L such that next_j ≠ STOP for all j ≤ len, y_j ≠ ⊥ for j < len, and (len = L or y_len = ⊥ or next_{len+1} = STOP). The inputs x_j(τ) := next_j(z, ρ, y_{<j}) are functions of τ, so they need not be listed. Ω is the set of complete runs, with the product σ-algebra 𝔉 (Y⊥ is countable and discrete). An *answerer* A is a probability kernel giving the law of y_j ∈ Y⊥ given the history h_j = (x_1, y_1, …, x_{j−1}, y_{j−1}, x_j); a *sampler* is an answerer that depends on x_j only. Q_A is the law of the complete run when z ∼ D₀, ρ ∼ Λ independently, and each answer is drawn from A.

**Lemma 1.1 (likelihood of a run). PROVED.** For a sampler ν put L_ν(τ) := Π_{j ≤ len(τ)} ν(y_j | x_j(τ)) (the empty product is 1). Let Γ be the measure on Ω that is D₀ ⊗ Λ on (z, ρ) times counting measure on the answer sequences. Then Γ is σ-finite and Q_ν(E) = ∫_E L_ν dΓ for every E ∈ 𝔉. The same holds for an answerer A with L_A(τ) := Π_j A(y_j | h_j(τ)).

*Proof.* Fix (z, ρ). The complete answer sequences for (z, ρ) are the leaves of a tree of depth at most L with countable branching: a node y_{<j} is a leaf iff it is complete. Drawing the answers one after another, the probability of reaching a given leaf y_{1:len} is Π_{j≤len} ν(y_j|x_j), and the leaf probabilities sum to 1 (induction on the depth: at each inner node the probabilities of the children sum to 1, because ν(·|x) is a probability on Y⊥). Hence, given (z, ρ), the conditional law of the answer sequence has the density L_ν with respect to counting measure on the leaves. Integrating over (z, ρ) ∼ D₀ ⊗ Λ gives the claim (Tonelli; all integrands are nonnegative). Γ is σ-finite because there are countably many answer sequences and D₀ ⊗ Λ is a probability. ∎

So all run laws Q_ν have densities with respect to one measure Γ, and **the density L_ν(τ) can be evaluated from the transcript of the run and the sampler alone, without knowing D₀ or Λ.**

**1.2 The human system and the data.** Q denotes the law of one run of the human system: *any* probability measure on (Ω, 𝔉). When the human is a stateless sampler P (assumption A1), Q = Q_P. Sections 2 and 3 do not need A1: the human may keep state inside a run, need not be computable, and need not be in any class. The only assumption on the data in Sections 2 and 3 is

 **(IID)** τ_1, …, τ_N are independent, each with law Q.

Q̂_N(E) := (1/N)·#{i ≤ N : τ_i ∈ E} is the empirical measure. TV(Q, Q′) := sup_{E∈𝔉} |Q(E) − Q′(E)|. Section 4 (the Bayes mixture) and Section 6 (validation) assume A1; each statement says what it assumes.

**1.3 Tests.** A *test family* is a countable family 𝓣 ⊆ 𝔉 with weights π(R) > 0, Σ_{R∈𝓣} π(R) ≤ 1, fixed before the data are seen. (It is an indexed family: the same event may occur twice with two weights.) For δ ∈ (0, 1):

 a_N(R) := ln(2/(π(R)·δ))/N,  tol_N(R) := √(a_N(R)/2) = √(ln(2/(π(R)δ))/(2N)) (the draft's tolerance).

For p, q ∈ [0, 1], kl(p‖q) := p·ln(p/q) + (1 − p)·ln((1 − p)/(1 − q)) is the divergence between Bernoulli laws (0·ln 0 = 0; the value is +∞ if q ∈ {0, 1} and p ≠ q). Note kl(1 − p‖1 − q) = kl(p‖q). When π(R) = 2^(−K(R)) with K(R) the length of a shortest program that decides R, the family consists of all decidable events and a_N(R) = (K(R)·ln 2 + ln(2/δ))/N; we call log₂(1/π(R)) the *price in bits* of R in every case.

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
*Counterexample to confidence 1 − δ.* N = 1, one test R with π(R) = 1, δ = 0.905, Q(R) = 0.2. Then tol_1(R) = √(ln(2/0.905)/2) = 0.6297… and ln(1/δ)/N = 0.0998…. If the single run is in R, then |Q̂ − Q| = 0.8 > tol and (a) fails. If it is not, R never occurred and Q(R) = 0.2 > 0.0998, so (b) fails. The joint statement fails with probability 1 > δ. (The example needs δ close to 1. For π(R)δ ≤ 0.2 the exact failure probability of the joint statement for one test stayed below π(R)δ on the grid of Section 9, check (5); I did not prove this.) ∎

**Corollary 2.6 (any test-matching imitator; the price of a property is its own complexity). PROVED.** Let 𝓜_N be the set of probability measures Q′ on (Ω, 𝔉) with kl(Q̂_N(R)‖Q′(R)) ≤ a_N(R) for all R ∈ 𝓣 ("Q′ matches the empirical frequencies of all tests"). On the event (G), which has probability ≥ 1 − δ:
(i) Q ∈ 𝓜_N; in particular, if the human system is the scaffold run with some answerer A (stateful or not), then 𝓜_N contains the run law Q_A of an answerer.
(ii) Every Q′ ∈ 𝓜_N satisfies, for every R ∈ 𝓣, with a = a_N(R) and q̄ := min{Q(R), 1 − Q(R)}:
 |Q′(R) − Q(R)| ≤ min{ √(2a) , 2√(2a·q̄) + 6a }.
(iii) If R ∈ 𝓣 never occurred in the data, every Q′ ∈ 𝓜_N has Q′(R) ≤ a, and Q(R) ≤ a.
With the draft's weaker matching condition |Q′(R) − Q̂_N(R)| ≤ tol_N(R), the conclusion is |Q′(R) − Q(R)| ≤ 2·tol_N(R) = √(2a), which is the draft's Pr3.

*Proof.* (i) is (G). (ii) By Corollary 2.4(a) applied to Q and to Q′ (the proof of 2.4 uses only the inequality kl(p̂‖·) ≤ a), both numbers are within √(a/2) of p̂. By 2.4(b) both lie in the interval [p̂ − √(2ap̂), p̂ + √(2ap̂) + 2a], of length 2√(2ap̂) + 2a, and √p̂ ≤ √(Q(R)) + √(2a), so the length is at most 2√(2a·Q(R)) + 6a. Apply the same to the complement of R. (iii) Corollary 2.4(c). The last sentence is the triangle inequality with Theorem 2.5(a). ∎

In the universal case (𝓣 = all decidable events, π(R) = 2^{−K(R)}): a = (K(R)·ln 2 + ln(2/δ))/N. A property R of complexity K(R) is preserved to within √(2a), and a property that the human system never violated in N runs is violated by a matching imitator with probability at most (K(R)·ln 2 + ln(2/δ))/N, whatever the complexity of the human.

**Remarks 2.7 (which hypotheses are needed).**
1. *Nothing about the human system is used except (IID).* Statefulness inside a run, non-computability and the absence of any class are all allowed.
2. *Independence is needed.* If the N recorded runs are one run copied N times, then Q̂_N(R) ∈ {0, 1}, and for a test with Q(R) = 1/2 the error is 1/2 for every N. (For runs that form a martingale-difference sequence, for instance top-level inputs chosen adaptively, Theorem 2.5(a) survives with Azuma's inequality in place of Lemma 2.1; not needed here and not proved here.)
3. *The tests must be fixed before the data, and an infinite family needs weights.* Let Q be non-atomic (for example ρ uniform on [0, 1]) and let 𝓣′ be the family of all finite sets of runs, which is uncountable. The data-dependent test R = {τ_1, …, τ_N} has Q̂_N(R) = 1 and Q(R) = 0. So no bound holds uniformly over 𝓣′ and none holds for tests chosen after the data.
4. *The price ln(1/π(R)) cannot be removed in general.* For M tests that are independent events of probability 1/2 under Q, the largest of the M deviations |Q̂_N(R) − 1/2| is of order √(ln M/N) for ln M ≤ N (the maximum of M independent binomial deviations). This standard fact is quoted without proof; it is not used below.
5. *Measurability is all the theorem asks of a test.* Whether tests must be decidable is a question about computing the estimator; see Section 3.5.

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

*What Theorem 3.6 does not say.* (1) The factor 3 is not 1: the estimate may be three times as far from the human system as the best index of the class, and for this estimator the factor is attained (Example 3.11(a)). (2) The rate is √(K/N), not K/N, also when the human system is in the class. (3) The approximation term TV(Q_ν, Q) is a distance between laws of whole runs. If the human keeps state within a run, it is the distance to the best stateless imitation of the run, which may be large. (4) N runs of the human system are up to N·L answers of the human, given in runs.

**Proposition 3.8 (the highest-weight sampler that passes one-sided tests; both prices, constant 2K). NEW, PROVED.** Let (𝓣, π) be a test family, possibly empty, and δ ∈ (0, 1). Put δ′ := δ/2 if 𝓣 is not empty, and δ′ := δ if 𝓣 is empty. Let r_N be as in Definition 3.1 with κ = ln(2/δ′), and tol′_N(R) := √(ln(2/(π(R)δ′))/(2N)). Call ν ∈ H *admissible* if

 (1) U_N(ν, ν′) ≤ max{r_N(ν), r_N(ν′)} for every ν′ ≠ ν, and
 (2) |Q_ν(R) − Q̂_N(R)| ≤ tol′_N(R) for every R ∈ 𝓣,

and let ν̂ be an admissible index of the largest weight, if there is an admissible index. Assume (IID) and Q = Q_ν₀, K := K(ν₀). Then with probability at least 1 − δ: ν₀ is admissible, w(ν̂) ≥ w(ν₀),

 TV(Q_ν̂, Q) ≤ 2r_N(ν₀) = √((2K ln 2 + 2 ln(2/δ′))/N), and |Q_ν̂(R) − Q(R)| ≤ 2·tol′_N(R) for every R ∈ 𝓣.

*Proof.* Let G′ be the event of Theorem 2.5(a) for (𝓣, π) at level δ′ (if 𝓣 is empty, G′ is the sure event). Let E₁ be the event that Q(A_ν₀ν′) − Q̂_N(A_ν₀ν′) ≤ max{r_N(ν₀), r_N(ν′)} for all ν′ ≠ ν₀. By Lemma 3.2(b), and because e^(−2N·r_N(ν)²) = w(ν)δ′/2, the inequality for ν′ fails with probability at most min{w(ν₀), w(ν′)}·δ′/2 ≤ w(ν′)δ′/2; so E₁ fails with probability at most δ′/2. Let E₂ be the event that Q̂_N(A_νν₀) − Q(A_νν₀) ≤ r_N(ν₀) for all ν ≠ ν₀ with w(ν) ≥ w(ν₀). Each of these inequalities fails with probability at most w(ν₀)δ′/2 ≤ w(ν)δ′/2, so E₂ fails with probability at most δ′/2. Together G′ ∩ E₁ ∩ E₂ fails with probability at most 2δ′ = δ if 𝓣 is not empty, and at most δ′ = δ if 𝓣 is empty.

On this event ν₀ is admissible: (1) is E₁, because U_N(ν₀, ν′) = Q(A_ν₀ν′) − Q̂_N(A_ν₀ν′), and (2) is G′. As in Theorem 3.3, an admissible index ν̂ of largest weight exists and w(ν̂) ≥ w(ν₀), so r_N(ν̂) ≤ r_N(ν₀). If ν̂ ≠ ν₀, let A := A_ν̂ν₀; then TV(Q_ν̂, Q) = U_N(ν̂, ν₀) + [Q̂_N(A) − Q(A)] ≤ max{r_N(ν̂), r_N(ν₀)} + r_N(ν₀) = 2r_N(ν₀), by (1) for ν̂ and by E₂. The statement about tests is the triangle inequality. ∎

Proposition 3.8 is Theorem 3.3 with a better constant (2K in place of 4K) and with fewer conditions to check: for each index only the sets A_νν′ in which it takes part, each on one side. It keeps what Corollary 3.7(a) does not give: every test of 𝓣 is matched at its own price, whatever K is. Like Theorem 3.3 it is a statement for a human system in the class.

### 3.4 Tests only: the price of a test needs no class

**Proposition 3.9 (least weighted test discrepancy over any set of candidates). NEW, PROVED.** Let 𝒞 be any set of probability measures on (Ω, 𝔉), for example the run laws of all samplers or of all answerers; 𝒞 need not be countable and carries no weights. Let (𝓣, π) be a test family, δ ∈ (0, 1), and for Q′ ∈ 𝒞

 d_N(Q′) := sup_{R ∈ 𝓣} (|Q′(R) − Q̂_N(R)| − tol_N(R))⁺.

Assume (IID). On the event of Theorem 2.5(a), which has probability at least 1 − δ, every Q′ ∈ 𝒞 with d_N(Q′) ≤ inf_𝒞 d_N + ε satisfies, for every R ∈ 𝓣,

 |Q′(R) − Q(R)| ≤ 2·tol_N(R) + inf_{Q″ ∈ 𝒞} sup_{R′ ∈ 𝓣} |Q″(R′) − Q(R′)| + ε.

If Q ∈ 𝒞 (for example: 𝒞 is the set of run laws of all answerers and the human system is the scaffold run with some answerer), the middle term is 0.

*Proof.* On the event, for Q″ ∈ 𝒞 and R′ ∈ 𝓣: |Q″(R′) − Q̂_N(R′)| − tol_N(R′) ≤ |Q″(R′) − Q(R′)|. So d_N(Q″) ≤ sup_{R′} |Q″(R′) − Q(R′)|, hence d_N(Q′) ≤ inf_{Q″} sup_{R′} |Q″(R′) − Q(R′)| + ε. And |Q′(R) − Q(R)| ≤ |Q′(R) − Q̂_N(R)| + tol_N(R) ≤ d_N(Q′) + 2·tol_N(R). ∎

This is Corollary 2.6 without the assumption that a matching candidate exists. The complexity of the candidates does not enter, because the deviation bound concerns the tests and not the candidates. What is lost is in the middle term and in the conclusion: both see the candidates only through the tests of 𝓣 (Section 5).

### 3.5 What must be computable for the estimators to be defined

As mathematical objects the estimators of this section are defined for every countable class with weights. To compute the estimate of Definition 3.4 one needs (C1) to (C3) below, and nothing else; the estimators that also use a test family need (C4) in addition.

**(C1) A finite list of candidates.** By Lemma 3.5 the set of ε-minimisers is determined by the indices of weight at least e^(κ−2N(1+r_N(ν₁)+ε)²): an index of smaller weight cannot be an ε-minimiser, and a competitor ν′ of weight at most e^(κ−2N) contributes nothing to any Δ_N(ν). One must be able to list the indices of weight above a given threshold. This is possible when w(ν) = 2^(−ℓ(ν)) for the lengths ℓ of programs in a prefix-free language. It is not possible when the weight is defined through the length of the *shortest* program for the kernel, which is not computable.

**(C2) For every recorded run τ_i and every pair of candidates: is L_ν(τ_i) > L_ν′(τ_i)?** By Lemma 1.1 both sides are products of at most L numbers ν(y_j|x_j) that are read off the transcript; D₀ and Λ are not needed, and neither is ρ if the transcript lists the inputs. The comparison must be decided exactly. This is possible when the probabilities ν(y|x) are rational numbers computable from (ν, x, y), for example for programs with a time bound. For lower semicomputable semimeasures (the class of all programs) L_ν(τ) is only a limit from below, and in general neither "L_ν(τ) > L_ν′(τ)" nor its negation can be confirmed by a finite computation; the estimate is then defined but not computable. Ties are harmless: Lemma 3.2(a) and all proofs hold for any measurable set A with {L_ν > L_ν′} ⊆ A ⊆ {L_ν ≥ L_ν′} in place of A_νν′.

**(C3) The numbers Q_ν(A_νν′).** This is the probability that a run of the scaffold answered by ν lies in A_νν′: a property of the scaffold and of two hypotheses, in which the human does not occur. It needs the laws D₀ and Λ of the scaffold, that is, a closed system. If (z, ρ) takes finitely many values with known rational probabilities and Y is finite, it is a finite sum over the tree of runs. In general it can be replaced by a simulation:

**Theorem 3.10 (the estimator with simulated runs). NEW, PROVED.** Let N_s ≥ 1. For each ν ∈ H let Q̃_ν be the empirical measure of N_s independent runs with law Q_ν (simulations of the scaffold with ν answering). Only this is used: the simulations of different indices may depend on each other, for example through a shared (z, ρ). Fix κ ≥ 0, put r̃(ν) := r_N(ν) + r_{N_s}(ν), and define Ũ(ν, ν′) := Q̃_ν(A_νν′) − Q̂_N(A_νν′), Δ̃(ν) := sup_{ν′≠ν} (Ũ(ν, ν′) − r̃(ν′))⁺ and c̃(ν) := Δ̃(ν) + r̃(ν). Assume (IID). Let δ ∈ (0, 1), s := √((ln(2/δ) − κ)⁺/(2N)) and s̃ := √((ln(2/δ) − κ)⁺/(2N_s)). There is an event of probability at least 1 − 2δ on which every ε-minimiser ν̂ of c̃ satisfies

 TV(Q_ν̂, Q) ≤ 3·TV(Q_ν, Q) + 2r_N(ν) + 2r_{N_s}(ν) + 2s + 2s̃ + ε for every ν ∈ H.

*Proof.* Let ν* minimise 3·TV(Q_ν, Q) + 2r̃(ν); it suffices to prove the inequality for ν = ν*. Let E₁, E₂ be as in the proof of Theorem 3.6, and

 E₃: Q̃_ν*(A_ν*ν′) − Q_ν*(A_ν*ν′) ≤ r_{N_s}(ν′) + s̃ for all ν′ ≠ ν*,
 E₄: Q_ν′(A_ν′ν*) − Q̃_ν′(A_ν′ν*) ≤ r_{N_s}(ν′) + s̃ for all ν′ ≠ ν*.

By Lemma 3.2(b), (c), applied to the N_s simulated runs of ν* (for E₃) and of ν′ (for E₄), each single inequality fails with probability at most w(ν′)δ/2; no independence between different ν′ is used. So all four events hold with probability at least 1 − 2δ. On them, with TV* := TV(Q_ν*, Q): Ũ(ν*, ν′) = [Q̃_ν*(A) − Q_ν*(A)] + U_N(ν*, ν′) ≤ TV* + r̃(ν′) + s + s̃, so c̃(ν*) ≤ TV* + s + s̃ + r̃(ν*). For an ε-minimiser ν̂ ≠ ν* and A := A_ν̂ν*: U_N(ν̂, ν*) = Ũ(ν̂, ν*) + [Q_ν̂(A) − Q̃_ν̂(A)] ≤ Δ̃(ν̂) + r̃(ν*) + r_{N_s}(ν̂) + s̃ by E₄, and Q̂_N(A) − Q(A) ≤ r_N(ν̂) + s by E₂. As in Step 2 of Theorem 3.6, TV(Q_ν̂, Q_ν*) ≤ c̃(ν̂) + r̃(ν*) + s + s̃ + TV* ≤ 2·TV* + 2r̃(ν*) + 2s + 2s̃ + ε. ∎

So with a closed system the following suffice: the transcripts of N runs of the human system; the ability to run the scaffold with a hypothesis in place of the human; and exact comparison of likelihoods on these runs. N_s costs computation only, and for N_s → ∞ the bound becomes that of Theorem 3.6.

**(C4) The tests of a family 𝓣** (Theorem 3.3, Propositions 3.8 and 3.9). A test with tol_N(R) ≥ 1, that is with π(R) ≤ (2/δ)·e^(−2N), imposes no condition, so fewer than (δ/2)·e^(2N) tests matter. For each of them one must decide whether a recorded run lies in R, so R must be decidable from what is recorded of a run; and one needs the numbers Q_ν(R), exactly or by simulation as in (C3). This is the only place where decidability of the tests enters; the theorems of Section 2 ask for measurability only (Remark 2.7(5)).

**What need not be known or computed:** the law Q of the human system; the densities of D₀ and Λ; any prior belief about the human. The weights w act as penalties, not as beliefs: the theorems hold for every human system and every choice of w, and w(ν) enters the bound only through the index ν with which one compares.

### 3.6 Sharpness, the hypotheses that are needed, and the literature

**Examples 3.11.** In (a) to (c) the scaffold makes one call with a fixed input, so a run is an answer y ∈ Y and a hypothesis is a probability vector on Y.

(a) *The factor 3 is attained by the estimator of Definition 3.4.* (The example is Lemma 11 of Mahalanabis and Štefankovič (2008), who use it for all selection rules that depend on the data through the test statistics only.) Let Y = {1, 2, 3, 4}, 0 < ε₀ < 1/4, and

 ν₁ = (0, 1/4 + ε₀, 1/2, 1/4 − ε₀), ν₂ = (1/2 + ε₀, 1/4 − ε₀, 0, 1/4), Q = (1/2, 1/2, 0, 0),

with w(ν₁) = w(ν₂). Then A_ν₁ν₂ = {2, 3}, A_ν₂ν₁ = {1, 4}, Q_ν₁(A_ν₁ν₂) = Q_ν₂(A_ν₂ν₁) = 3/4 + ε₀, TV(Q_ν₁, Q) = 3/4 − ε₀ and TV(Q_ν₂, Q) = 1/4 + ε₀. The data fall on the answers 1 and 2 only, so U_N(ν₁, ν₂) = 3/4 + ε₀ − Q̂_N({2}) and U_N(ν₂, ν₁) = 3/4 + ε₀ − Q̂_N({1}), with Q̂_N({1}) + Q̂_N({2}) = 1. Let N be odd and so large that r_N(ν₁) < 1/4. With probability exactly 1/2, Q̂_N({2}) > 1/2; then U_N(ν₁, ν₂) < 1/4 + ε₀ < U_N(ν₂, ν₁) and U_N(ν₂, ν₁) > r_N, so c_N(ν₁) < c_N(ν₂) and ν̂ = ν₁. On this event TV(Q_ν̂, Q) = 3/4 − ε₀ = (3 − 16ε₀/(1 + 4ε₀))·min_ν TV(Q_ν, Q). So for no c < 3 does this estimator satisfy TV(Q_ν̂, Q) ≤ c·min_ν TV(Q_ν, Q) + o(1) with probability above 1/2. That no estimator which must return a member of the class can have a factor below 3 is Theorem 2 of Bousquet, Kane and Moran (2019) (see below, with the caveat on how it was read). An estimator that may return a mixture of members can reach the factor 2 (the same paper, Theorem 1); I have not carried this over to weighted classes.

(b) *For an infinite class the penalty is needed.* Let Y = {1, …, u} and let the human answer uniformly: Q uniform on Y. Let H contain Q and, for every set S ⊆ Y of N elements, the uniform law Q_S on S. If the N recorded answers are distinct (probability at least 1 − N²/(2u)), then Q̂_N = Q_S for S the set of recorded answers, so U_N(Q_S, ν′) = 0 for every ν′. Without penalties (Definition 3.4 with r_N ≡ 0) the criterion is therefore minimised by the hypothesis that replays the data, and TV(Q_S, Q) = 1 − N/u; for the human's own index, A_{Q,Q_S} = Y∖S and U_N(Q, Q_S) = Q(Y∖S) − Q̂_N(Y∖S) = 1 − N/u. With weights that are equal among the C(u, N) hypotheses Q_S we have w(Q_S) ≤ 1/C(u, N) ≤ (N/u)^N, so r_N(Q_S) ≥ √(ln(u/N)/2). As soon as u > N·e^(2(1+r_N(Q))²), this gives c_N(Q_S) ≥ r_N(Q_S) > 1 + r_N(Q) ≥ c_N(Q), and no replaying hypothesis is selected. (Theorem 3.6 holds whatever the weights are; the example shows what the penalty is for.)

(c) *Outside the class, "the highest-weight index that matches" need not exist.* Let Y = {0, 1}, H = {ν₁, ν₂} with ν₁(1) = 1/4, ν₂(1) = 3/4, and Q(1) = 1/2. Then A_ν₂ν₁ = {1}, A_ν₁ν₂ = {0}, Q̂_N({1}) → 1/2 almost surely, so |Q_ν(A_ν₂ν₁) − Q̂_N(A_ν₂ν₁)| → 1/4 for both ν and U_N(ν₁, ν₂), U_N(ν₂, ν₁) → 1/4, while every tolerance tends to 0. For large N neither index matches in the sense of Theorem 3.3, and neither is admissible in the sense of Proposition 3.8. The estimator of Definition 3.4 returns one of the two; both are at distance 1/4 from Q.

(d) *(IID) is needed*: Remark 2.7(2).

(e) *The Yatracos sets must be among the tests if the conclusion is to be about total variation.* A sampler can match every test of a family of small total price and be at total variation 1/2 from the human system: Proposition 5.2.

**The literature, and how each statement was accessed.**

* Y. G. Yatracos, "Rates of convergence of minimum distance estimators and Kolmogorov's entropy", *Annals of Statistics* 13(2) (1985) 768–774. Not read in this session; cited for the sets A_νν′ and the minimum-distance principle as described in the three sources below.
* L. Devroye and G. Lugosi, *Combinatorial Methods in Density Estimation*, Springer 2001, Chapter 6. Not read in this session. Read in this session in a restatement: S. Mahalanabis and D. Štefankovič, "Density estimation in linear time", arXiv:0712.2869v1 (2007; COLT 2008), Section 1, which states: for a finite class F of densities, the unknown density g, the empirical measure h, the test functions T_ij := sgn(f_i − f_j) and Δ := max_T (g − h)·T, "Theorem 3 ([DL01], Theorem 6.3)": the minimum distance estimate f₁, which minimises max{|(f − h)·T_ij| ; f_i, f_j ∈ F}, satisfies ‖f₁ − g‖₁ ≤ 3·d₁(g, F) + 2Δ; and "Theorem 2 ([DL01], Theorem 6.2)": the Scheffé tournament winner satisfies ‖f₁ − g‖₁ ≤ 9·d₁(g, F) + 8Δ. Their Remark 1 says that their Δ is at most twice the Δ of Devroye and Lugosi, which is defined with the sets {f_i > f_j}. In our units (TV is half the L₁ distance) their Theorem 3 reads TV ≤ 3·inf TV + Δ, with their Δ. Also read in this session: S. Compton and J. Li, "Density estimation for Hellinger via minimum-distance estimators", arXiv:2606.11469v1 (2026), Lemma 5, which states the same result as E[TV(f, f̂_n)] ≤ 3·inf_θ TV(f, f_θ) + O(√(VC(𝒜)/n)) for the Yatracos class 𝒜 = {{x : f_θ(x) > f_θ′(x)}}.
* Mahalanabis and Štefankovič, as above [read]: their Theorem 4 proves the same guarantee for the "modified minimum distance estimate", which minimises max{|(f_i − h)·T_ij| ; f_j ∈ F} over i, that is, which uses for each candidate only the test functions in which the candidate takes part; their Remark 5 notes that the deviation of h from g is needed only on the test functions of the best member; their Lemma 11 is Example 3.11(a). Definition 3.4 is this estimate with weights and with one-sided statistics; Theorem 3.6 is its analysis with a weighted union bound. I did not find the weighted statement in the literature and I do not claim that it is new.
* O. Bousquet, D. Kane and S. Moran, "The optimal approximation factor in density estimation", *Proceedings of COLT 2019*, PMLR 99, 318–341; arXiv:1902.05876. Read in this session only through an automatic summary of the arXiv page (version 5): Theorem 2 there states that for every α < 3 there is a class of two densities that is not properly α-learnable, and Theorem 1 that every finite class is 2-learnable by an algorithm whose output need not lie in the class. The exact quantifiers should be checked in the source before the note relies on them.
* The weighted union bound ("Occam bound") is standard. A related likelihood-based estimator with rates in Hellinger distance governed by min_ν [K(ν)/N + divergence] is "minimum complexity density estimation" (A. R. Barron and T. M. Cover, *IEEE Trans. Inform. Theory* 37(4) (1991) 1034–1054; from memory, not checked); in this project its counterpart is Theorem B of `research/prove-b/hellinger-runs.md`.

---

## 4. Pr2: what the Bayes mixture does with a simple property

**In brief.** Let R be a property of question–answer pairs that the human never violates. (1) *In hindsight* the mixture has learned R at the price of R: on any data that abide by R, the posterior expectation of the inverse of the probability that a hypothesis gave to abiding so far is at most the constant C_R with which the class is closed under conditioning on R (Theorem 4.2); C_R = 2^(K(R)+c) in the class of all programs. (2) *At a fresh input* this is false. In a class of memorisers the mixture violates a property of constant complexity with probability above 1/2 for all n up to (K − 2)/(bits per pair), and the exact value is computed (Theorem 4.5). If the class is closed under conditioning, the violation probability is at most 1 − 1/C_R, and this is attained (Corollary 4.6). (3) What does hold at a fresh input is governed by the *regret*: one minus the violation probability is at least the n-th root of δ·M(D_n)/P(D_n) (Theorem 4.7), so the violation probability is at most (K ln 2 + ln(1/δ))/n, and a violation level v can be sustained only while the mixture loses log₂(1/(1 − v)) bits per pair against the human; this trade-off is attained (Proposition 4.8). (4) In the class of all programs the same holds with K replaced by the complexity of the simplest hypothesis that predicts the human's answers as well as the human's own law does; a universal reference machine can be chosen so that the memoriser phenomenon lasts for K/(bits per pair) questions (Theorem 4.11), and no statement about "natural" machines can be proved without a definition of the word (4.13).

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

Here Π_{i≤n} (1 − v_ν(x_i)) is the probability that n independent answers of ν at the inputs x_1, …, x_n do not violate R: the probability that ν gave to abiding so far. Nothing is assumed about the origin of the data: no A1, no A2.

*Proof.* Let ν have ν(D_n) > 0. Each (x_i, y_i) lies in R and ν(y_i|x_i) > 0, so v_ν(x_i) ≤ 1 − ν(y_i|x_i) < 1 and ν^R(D_n) = ν(D_n)·Π_i (1 − v_ν(x_i))^(−1). Hence, summing first over the ν with a given image under φ (all terms are nonnegative),

 Σ_{ν : ν(D_n)>0} w(ν)·ν(D_n)·Π_i (1 − v_ν(x_i))^(−1) ≤ Σ_ν w(ν)·φ(ν)(D_n) = Σ_{ν′} (Σ_{ν : φ(ν)=ν′} w(ν))·ν′(D_n) ≤ C_R·Σ_{ν′} w(ν′)·ν′(D_n) = C_R·M(D_n).

Divide by M(D_n). ∎

**Corollary 4.3. PROVED.** Under the assumptions of Theorem 4.2:

(a) *The inputs already seen.* Σ_{i≤n} v_{M_{D_n}}(x_i) = Σ_ν w_{D_n}(ν)·Σ_{i≤n} v_ν(x_i) ≤ ln C_R. If the n inputs seen so far were put to the mixture M_{D_n} once more, the expected number of answers that violate R would be at most ln C_R.
(b) For η > 0, the posterior weight of {ν : Π_{i≤n} (1 − v_ν(x_i)) ≤ η} is at most η·C_R.
(c) *The floor.* The hypotheses that never violate R have posterior weight at least 1/C_R. Hence v_{M_{D_n}}(x) ≤ 1 − 1/C_R for every x ∈ X, seen or not.

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

*Two remarks.* (1) The table that equals f on all of X is a memoriser of weight c₀·(4u)^(−u), which names the same kernel as the index f. The formulas above keep the two indices apart and are exact as stated; the weight of the kernel f is 2^(−K) + c₀·(4u)^(−u). (2) H_mem is not closed under conditioning on R: g_T^R gives no answer outside dom T and is not in the class. Theorem 4.2 therefore does not apply to H_mem, although its conclusion holds there by (f). The next corollary closes the class.

**Corollary 4.6 (the memoriser class closed under conditioning; the floor is attained). PROVED.** Let C > 0. Let H_mem^cl consist of the index f with weight 2^(−K), of the indices g_T with weights (C/(C + 1))·c₀·(4u)^(−|T|), and of indices h_T with weights (1/(C + 1))·c₀·(4u)^(−|T|), where h_T answers T(x) on dom T and gives no answer elsewhere. Then (Cl_R) holds with φ(g_T) = φ(h_T) = h_T, φ(f) = f and C_R = C + 1. For D as in Theorem 4.5, M(D) is as in 4.5(a), and for x not among the inputs of D

 v_{M_D}(x) = (1 − 1/C_R)·(2u/(2u + 1)) / (1 + (4u + 2)^k/(2^K − 1)).

So, for every constant C_R > 1 and every n, there are a class that satisfies (Cl_R) with this constant, a human in it who never violates R, and data of n pairs from this human, such that the mixture violates R at every unseen input with probability at least (1 − 1/C_R)·(1 − 1/(2u+1))·(3/4), where u is arbitrary. The bound of Corollary 4.3(c) cannot be improved, and under (Cl_R) alone there is no bound on the violation probability at a fresh input that tends to 0 with n.

*Proof.* g_T^R = h_T: at x ∈ dom T nothing changes, and at x ∉ dom T the answer b has probability 1, so the conditioned sampler gives no answer. h_T and f never violate R, so they are their own conditionings. The indices mapped to h_T are g_T and h_T, of total weight c₀·(4u)^(−|T|) = (C + 1)·w(h_T); the only index mapped to f is f; no index is mapped to g_T. h_T is consistent with D under the same condition as g_T, so M(D) is unchanged, and among the consistent memorisers whose table does not contain x, the fraction C/(C + 1) of the weight answers b. For the last statement take K ≥ nβ + 2. ∎

### 4.3 What holds at a fresh input: the regret is the price

**Theorem 4.7 (foresight). NEW, PROVED.** Assume A1: the human is a sampler P with Σ_y P(y|x) = 1; P need not be in H. Let μ be a law on X and R a property such that v_P(x) = 0 for every x with μ(x) > 0. Let x_1, x_2, … be independent with law μ, and let y_i be drawn from P(·|x_i). For ν ∈ H let

 V_ν := Σ_x μ(x)·v_ν(x),

the probability that ν violates R at a fresh input drawn from μ. Put P(D_n) := Π_{i≤n} P(y_i|x_i).

(a) Z_n := Σ_{ν : ν(D_n) > 0} w(ν)·ν(D_n)·(1 − V_ν)^(−n)/P(D_n), n = 0, 1, 2, …, is a nonnegative supermartingale with Z₀ = Σ_ν w(ν) ≤ 1.
(b) Let δ ∈ (0, 1). With probability at least 1 − δ, for all n ≥ 0 simultaneously: M(D_n) = 0 or

 Σ_ν w_{D_n}(ν)·(1 − V_ν)^(−n) ≤ P(D_n)/(δ·M(D_n)).

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

**Proposition 4.8 (recognisers: the trade-off of Theorem 4.7 is attained). NEW, PROVED.** Let X = {1, …, u}, Y = {0, 1, b}, R = {(x, y) : y ≠ b}, f: X → {0, 1}, K ≥ 1, 1 ≤ s < u and σ := s/u. For S ⊆ X with |S| = s let ν_S answer f(x) for x ∈ S and b for x ∉ S. The class H_rec consists of the index f with weight 2^(−K) and of the C(u, s) indices ν_S, each with weight (1 − 2^(−K))/C(u, s). Let D consist of pairs (x, f(x)) with k ≤ s distinct inputs, and put ω_k := Π_{i<k} (s − i)/(u − i). Then:

(a) M(D) = 2^(−K) + (1 − 2^(−K))·ω_k.
(b) For x not among the inputs of D: v_{M_D}(x) = ((u − s)/(u − k))·(1 − 2^(−K))·ω_k/M(D). For the uniform law μ: V(D) = (1 − σ)·(1 − 2^(−K))·ω_k/(2^(−K) + (1 − 2^(−K))·ω_k).
(c) σ^k·(1 − k²/(2s)) ≤ ω_k ≤ σ^k. Hence, if k ≤ √s and k·log₂(1/σ) ≤ K − 2 − j with j ≥ 0, then V(D) ≥ (1 − σ)/(1 + 2^(−j)).
(d) Under the conditions of (c), 1 − V(D) ≤ σ + 2^(−j), while Theorem 4.7(c) (with P(D) = 1 and n = k distinct inputs) gives 1 − V(D) ≥ (δ·M(D))^(1/k) ≥ σ·(δ/4)^(1/k).

So the violation level v = 1 − σ is sustained at the cost of log₂(1/σ) = log₂(1/(1 − v)) bits per pair, for about K/log₂(1/(1 − v)) pairs: the inequality 4.7(c) is attained up to the factor (δ/4)^(1/k) and the term 2^(−j). With σ = 1/4: V(D_n) ≥ 2/3 for all n ≤ min{(K − 5)/2, √(u/4)}, at two bits per pair. With σ just below 1/2 the level is just above 1/2 for about K pairs, which by 4.7(d) is the longest possible up to the additive log₂(1/δ). For u = 2¹⁶ and K = 200 the exact values are in Section 9.

*Proof.* ν_S is consistent with D iff S contains the k inputs of D. There are C(u − k, s − k) such sets, and C(u − k, s − k)/C(u, s) = Π_{i<k} (s − i)/(u − i) = ω_k; this gives (a). For x not among the inputs, the consistent sets that do not contain x number C(u − k − 1, s − k), and C(u − k − 1, s − k)/C(u − k, s − k) = (u − s)/(u − k); this gives the first formula of (b), and the second follows because the unseen inputs have μ-probability (u − k)/u. (c) (s − i)/(u − i) ≤ s/u because s ≤ u, and (s − i)/(u − i) ≥ (s − i)/u = σ·(1 − i/s); further Π_{i<k} (1 − i/s) ≥ 1 − Σ_{i<k} i/s ≥ 1 − k²/(2s). For k ≤ √s this gives ω_k ≥ σ^k/2, so 2^(−K)/((1 − 2^(−K))·ω_k) ≤ 2^(2−K)·σ^(−k) ≤ 2^(−j), and V(D) = (1 − σ)/(1 + 2^(−K)/((1 − 2^(−K))·ω_k)). (d) With e := 2^(−K)/((1 − 2^(−K))·ω_k) ≤ 2^(−j): 1 − V(D) = (σ + e)/(1 + e) ≤ σ + e. And M(D) ≥ (1 − 2^(−K))·ω_k ≥ σ^k/4. ∎

**Proposition 4.9 (adaptively chosen questions; rehearsal). PROVED** (a consequence of Theorem R1 of `note.md`). Assume A1 to A3, P ∈ H, and that P never violates R. Let the questions x_1, …, x_n be chosen in any way that depends on the earlier data and on fresh randomness, and let M^(t) be the mixture before question t. Then

 Σ_{t=1}^n E[v_{M^(t)}(x_t)] ≤ Σ_{t=1}^n E[ln(1/(1 − v_{M^(t)}(x_t)))] ≤ K ln 2.

Under the rehearsal protocol of `note.md`, Section 2, the expected number of calls of a run answered by M^(T), T uniform on {1, …, n}, whose answer violates R is at most L·K ln 2/n.

*Proof.* Let p be a probability on Y with p(R_x) = 1 and q a semimeasure on Y. By the log-sum inequality, KL(p‖q) = Σ_{y∈R_x} p(y)·ln(p(y)/q(y)) ≥ ln(1/Σ_{y∈R_x} q(y)) ≥ ln(1/(1 − v_q(x))). Apply this with p = P(·|x_t) and q = M^(t)(·|x_t), and use the regret bound Σ_t E[KL(P(·|x_t)‖M^(t)(·|x_t))] ≤ K ln 2 for adaptively chosen questions, which is the first step of the proof of Theorem R1 (`note.md`, Section 3.1; also `research/prove-b/hellinger-runs.md`, Appendix A). For the rehearsal protocol, Theorem R1 itself bounds Σ_t E[Σ_{calls x of the run of round t} KL(P(·|x)‖M^(t)(·|x))] by L·K ln 2; the expected number of violating calls of a run answered by M^(t) is E Σ_{calls x} v_{M^(t)}(x), because each call is answered by a fresh draw from M^(t). ∎

So for the mixture the price of a property that the human never violates is K, with the fast rate 1/n; Theorems 4.5 and 4.11 show that K cannot be replaced by a function of R.

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

**Theorem 4.11 (a universal reference machine does not prevent the phenomenon). PROVED.** Let u ≥ 5, X = {1, …, u}, let Y contain 0, 1 and b, and R := {(x, y) : y ≠ b}. Let (H₀, w₀) be any class of samplers with Σ w₀ ≤ 1, for instance all programs of a universal language with w₀ = 2^(−length). For an integer c ≥ 1 let H_c be the disjoint union of H₀ and of the memorisers g_T of Theorem 4.5, with the weights w(ν) := 2^(−c)·w₀(ν) for ν ∈ H₀ and w(g_T) := (1/4)·(4u)^(−|T|). Then Σ w ≤ 2^(−c) + (1/4)·(1 + 1/(2u))^u < 1. Let f: X → {0, 1} be any function and D a data set of pairs (x, f(x)) with k distinct inputs. For every x not among the inputs of D,

 v_{M_D}(x) ≥ M_D(b|x) ≥ (2u/(2u + 1)) / (1 + 2^(2−c)·(4u)^k),

and for the uniform law μ on X, V(D) ≥ ((u − k)/u)·(2u/(2u + 1)) / (1 + 2^(2−c)·(4u)^k). In particular **V(D_n) ≥ (3/4)·(10/11)·(4/5) > 0.54 for every data set of n ≤ min{u/4, (c − 4)/log₂(4u)} pairs.**

*Proof.* As in Theorem 4.5, the consistent memorisers have total weight W_m := (1/4)·(4u)^(−k)·(1 + 1/(2u))^(u−k) ≥ (4u)^(−k)/4, and those whose table does not contain x have weight W_m·2u/(2u + 1). All other hypotheses have total weight at most 2^(−c) and likelihood at most 1. So M(D) ≤ W_m + 2^(−c) and M_D(b|x) ≥ W_m·(2u/(2u + 1))/(W_m + 2^(−c)) = (2u/(2u + 1))/(1 + 2^(−c)/W_m). If k·log₂(4u) ≤ c − 4, then 2^(2−c)·(4u)^k ≤ 1/4. ∎

*Reading for reference machines.* Let u = 2^d, let the inputs be the strings of d bits, and let (H₀, w₀) be the class of all programs of a universal prefix machine U. Define the machine U′ by U′(1^c p) := U(p), and U′(0q) := g_T when q = (1 x_1 t_1)(1 x_2 t_2)…(1 x_k t_k) 0 lists the entries of the table T with x_1 < … < x_k and t_i = T(x_i). The programs of U′ form a prefix-free set, ℓ(0q) = 2 + |T|·(d + 2), so 2^(−ℓ(0q)) = (1/4)·(4u)^(−|T|), and U′ is universal: K_{U′} ≤ K_U + c. The class of all programs of U′ is H_c. Hence: **for every universal machine U and every c there is a universal machine U′, with K_{U′} ≤ K_U + c, for which the mixture violates the property "the answer is not b" with probability above 1/2 at a fresh input, for every human f: X → {0, 1}, for all n ≤ min{u/4, (c − 4)/(d + 2)}.** If f is simple for U, say K_U(f) = k₀, its complexity for U′ is K := K_{U′}(f) ≤ k₀ + c, and the statement holds for all n ≤ min{u/4, (K − k₀ − 4)/(d + 2)}: for all n up to the order of K divided by the bits per pair. (Adding the conditioned memorisers h_T of Corollary 4.6 at four more bits each makes the memoriser part closed under conditioning on R with constant 17 and multiplies the lower bound by 16/17; then 0.54 becomes 0.51.)

**Proposition 4.12 (a simple abiding source protects its typical members, whatever the class and the machine). PROVED.** Let (H, w) be any class and S ∈ H a sampler with Σ_y S(y|x) = 1 that never violates R. Let F be a random function with independent values F(x) ∼ S(·|x), x ∈ X, and let the human answer F(x) at x. Let x_1, x_2, … be independent with law μ and independent of F, and V(D_n) as in Theorem 4.7(c). Then for δ ∈ (0, 1), with probability at least 1 − δ over F and the inputs, for every n ≥ 1: two of the inputs x_1, …, x_n coincide, or

 V(D_n) ≤ (K(S)·ln 2 + ln(1/δ))/n.

*Proof.* Let n₁ be the first n with x_n ∈ {x_1, …, x_{n−1}} (n₁ := ∞ if there is none). Given the inputs, the answers F(x_1), …, F(x_n) at distinct inputs are independent with laws S(·|x_i). So the sequence (D_n)_{n<n₁} has the same law as in the experiment in which the human is the sampler S itself and the inputs are the same. In that experiment A1 and A2 hold with P = S, and Theorem 4.7(b) and (d) give probability at least 1 − δ that V(D_n) ≤ (K(S) ln 2 + ln(1/δ))/n for all n ≥ 1. The event "the bound fails for some n < n₁" is a function of (D_n)_{n<n₁} and so has the same probability in both experiments. ∎

The complexity of the human does not enter: F is typically not computable when S is not deterministic. For the humans of Theorem 4.5 this says: if the class contains the fair coin with weight 2^(−k_c) (as the class of all programs does for every universal machine, with k_c depending on the machine), then for all but a fraction δ of the pairs (function f, sequence of inputs), the mixture violates R at a fresh input with probability at most (k_c·ln 2 + ln(1/δ))/n as long as no input has repeated. For the machine U′ of Theorem 4.11, k_c is about c, in agreement with that theorem.

**4.13 What can be proved about the class of all programs.**

1. *For every reference machine* (**PROVED**): for all data that abide by a decidable R, the mixture violates R with probability at most 1 − 2^(−K(R)−c) at every input (Corollary 4.3(c), Remark 4.4), and at most ln 2·(K(R) + c) times in expectation over the inputs already seen (Corollary 4.3(a)).
2. *For every class* (**PROVED**): at a fresh input from the law of the data, the violation probability is at most (K*·ln 2 + ln(1/δ))/n, where K* := min_{S∈H} [K(S) + log₂(P(D_n)/S(D_n))] is the length of the cheapest two-part description of the answers, measured against the human's own law (Theorem 4.7(e)); K* ≤ K when the human is in the class. A violation probability v requires K* ≥ n·log₂(1/(1 − v)) − log₂(1/δ) (Theorem 4.7(f)).
3. *Universality of the machine gives nothing more* (**PROVED**): Theorem 4.11.
4. *Natural machines* (**OPEN**, and not a mathematical question as it stands). A statement of the form "for a natural reference machine the violation probability at a fresh input is at most C·(K(R) + log n)/n" would need a definition of "natural" that excludes the machines of Theorem 4.11. By item 2 it would follow from a bound on K*, that is, from the existence of a simple program that never violates R and predicts the human's answers on fresh inputs about as well as the human's own law does. This is an assumption about the human and the machine together. It holds for humans who are typical members of a simple source (Proposition 4.12). I do not know a way to derive it from the simplicity of R.

---

## 5. The two prices side by side

### 5.1 The two guarantees

Both use N independent recorded runs of the human system. K(R) := log₂(1/π(R)) is the price in bits of a test R, and K the description length of the human.

| | all properties at once | one property at a time |
|---|---|---|
| what is guaranteed | TV(law of the imitator's run, Q) ≤ ε: every event of runs has a probability within ε of its probability in the human system (Statement 2.0) | \|Q′(R) − Q(R)\| ≤ ε_R for every test R of the family, simultaneously |
| error | in expectation √(K ln 2/(2N)) (Theorem A: `research/prove-b/hellinger-runs.md`, Theorem 4.2(c)); with probability 1 − δ: √((2K ln 2 + 2 ln(2/δ))/N) (Corollary 3.7(a)) | with probability 1 − δ: ε_R = √(2(K(R) ln 2 + ln(2/δ))/N); and Q′(R), Q(R) ≤ (K(R) ln 2 + ln(2/δ))/N for a test that never occurred in the data (Corollary 2.6) |
| which imitator | Theorem A: for each run, a hypothesis drawn from the posterior given a uniformly random number of the recorded runs; Corollary 3.7: the penalised minimum-distance estimate | any imitator whose run law lies in 𝓜_N (matches the empirical frequencies of all tests) |
| assumptions | Theorem A: A1 and A2. Corollary 3.7(a): (IID) and the human system in the class. Outside the class an approximation term is added (Theorem 3.6 here; part (b) of Theorem A in the cited file) | (IID) only: no class, no statelessness, no computability |
| says nothing when | N ≤ K ln 2/2 (the bound of Theorem A is at least 1) | K(R) ln 2 + ln(2/δ) ≥ N/2 (then ε_R ≥ 1); and for every property outside the family |

The first guarantee implies the second for every test at the first price (Statement 2.0). For N below about K only the second says anything, and it then covers the tests of price well below N. When the human system is in the class, the estimate of Proposition 3.8 has both guarantees at once. Neither price can be lowered in general: for the first see `research/prove/lower-bounds.md`, Theorems 6.1 and 6.3 (a class of 2^K samplers for which every protocol has expected total variation of order √(K/n); I did not check that file), and for the second Remark 2.7(4).

### 5.2 What an imitator that satisfies only the second guarantee can get wrong

**Proposition 5.2 (tests of small total price do not see what is complex). PROVED.** Let the scaffold make one call: an input x is drawn from a law μ on X and put to the answerer, so that a run is a pair (x, y) and Q_S(R) = Σ_x μ(x)·S(R_x|x) for a sampler S and a set R of pairs. Put coll(μ) := Σ_x μ(x)², the probability that two independent draws from μ coincide (1/u for the uniform law on u inputs). Let P₀ be a sampler with Σ_y P₀(y|x) = 1, and let F be a random function with independent values F(x) ∼ P₀(·|x); Q_F denotes the run law of the deterministic sampler that answers F(x). Let (𝓣, π) be a test family and η ∈ (0, 1). Then:

(a) with probability at least 1 − η over F, for all R ∈ 𝓣: |Q_F(R) − Q_{P₀}(R)| ≤ √(coll(μ)·ln(2/(π(R)η))/2);
(b) for every F: TV(Q_F, Q_{P₀}) = Σ_x μ(x)·(1 − P₀(F(x)|x)) ≥ 1 − Σ_x μ(x)·max_y P₀(y|x).

In particular, for the uniform law on u inputs and the fair coin P₀ on {0, 1}, there is a function f: X → {0, 1} with

 |Q_f(R) − Q_coin(R)| ≤ √(ln(2/(π(R)η))/(2u)) for every R ∈ 𝓣, and TV(Q_f, Q_coin) = 1/2.

*Proof.* (a) For fixed R, Q_F(R) = Σ_x μ(x)·1[(x, F(x)) ∈ R] is a sum of independent random variables; the x-th lies in [0, μ(x)] and has mean μ(x)·P₀(R_x|x), so E Q_F(R) = Q_{P₀}(R). By Hoeffding's inequality for independent bounded summands (W. Hoeffding, 1963, cited after Lemma 2.1, Theorem 2 there; standard, quoted from memory; for infinite X apply it to finite partial sums and pass to the limit), Pr[|Q_F(R) − Q_{P₀}(R)| ≥ t] ≤ 2·exp(−2t²/Σ_x μ(x)²). With t := √(coll(μ)·ln(2/(π(R)η))/2) the right side is π(R)·η; sum over R. (b) Both laws have the marginal μ on x, so the total variation is the μ-average of TV(point mass at F(x), P₀(·|x)) = 1 − P₀(F(x)|x). ∎

*Consequence.* Let the human be such a function f, let the imitator be the coin, let N ≤ u, and take η = δ. Then |Q_coin(R) − Q_f(R)| ≤ √(N/u)·tol_N(R) ≤ tol_N(R) for every R ∈ 𝓣. So the guarantee that Corollary 2.6 gives for the members of 𝓜_N, namely |Q′(R) − Q(R)| ≤ 2·tol_N(R), is met by the coin with room to spare. And the coin gives an answer different from the human's with probability 1/2 at every input. The property that it gets wrong is "y = f(x)": being right. This property has probability 1 in the human system and 1/2 for the coin. A test family cannot make up for this by containing the graphs: tol_N(R) < 1 requires π(R) > (2/δ)·e^(−2N), at most (δ/2)·e^(2N) tests have such a weight, and for u ≥ 3N this is a fraction below 2^(−N/10) of the 2^u functions. Whenever being right has no test that is much simpler than the human, an imitator that satisfies only the second guarantee may be an answerer that is right at the rate of chance and passes every simple test at the human's rate. (The counting argument is the one of Trevisan, Tulsiani and Vadhan for "regularity" of arbitrary functions, as reported in `research/understand/indistinguishability.md`, Section 4.1; I did not read that paper. The digest's Lemma I1a gives two further imitators of this kind; I did not check it.)

In a computation with u = 2¹² inputs and 1490 tests (conjunctions of one, two input bits and the answer; thresholds; parities of three bits), the largest difference |Q_f(R) − Q_coin(R)| over the tests and over 40 random f was 0.022, the bound of (a) is 0.036, and with N = u/4 recorded runs the coin was within tol_N = 0.071 of the empirical frequency of every test in 40 of 40 trials (Section 9).

**Example 5.3 (tests of single calls do not see how the calls of a run hang together). PROVED.** Let the scaffold draw z uniformly from X = {1, …, u} and make two calls, both with the input z (the same question is asked twice). Let the human be the fair coin at every call; in the human system the two answers agree with probability 1/2. Let the imitator be a function g: X → {0, 1}; its two answers always agree. For a set B ⊆ X × {0, 1} of pairs, the per-call frequencies of Section 6 are a(B) = (1/u)·Σ_z 1[(z, g(z)) ∈ B] for the imitator and h(B) = (1/u)·Σ_z ½·(1[(z, 0) ∈ B] + 1[(z, 1) ∈ B]) for the human on the imitator's inputs. By Proposition 5.2(a) there is, for every family (𝓑, π) and η, a function g with |a(B) − h(B)| ≤ √(ln(2/(π(B)η))/(2u)) for all B ∈ 𝓑. For this imitator every per-call test of the family has the human's frequency up to that error, and the event "the two answers agree", a test of runs of constant price, has probability 1 against 1/2. ∎

So per-call test matching (what Theorem 6.1 certifies, and what the online imitator Pr5 delivers) is strictly weaker than matching tests of runs (Section 2), and the difference shows already for the simplest tests of runs. Matching tests of runs needs recorded runs of the human system; here, the human answering the same question twice.

**5.3 Summary of this section.** An imitator that satisfies only the second guarantee can be wrong (i) about every property whose price is of the order N or more, in particular about being right when being right has no short test (Proposition 5.2); (ii) if its tests are tests of single calls, about every property of how the calls of a run hang together (Example 5.3); and (iii) about everything outside the distribution of the recorded runs, like every other imitator (Theorem N1 of the note). Conversely the Bayes mixture, which pays the first price, does not pay the second (Theorem 4.5). Neither guarantee contains the other at its own price.

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

*What it does not certify.* Nothing about events of runs (Example 5.3: all per-call frequencies can agree while a constant-price event of runs is off by 1/2). Nothing about properties outside the family. And nothing about the distance between A(·|x) and P(·|x) at any input, as the next theorem shows.

### 6.2 What single answers at non-repeating inputs cannot certify

**Theorem 6.2. NEW, PROVED.** Let P₀ be a sampler with Σ_y P₀(y|x) = 1 and p_max(x) := max_y P₀(y|x). For a function F: X → Y let P_F be the deterministic human who answers F(x) at x. Let F be random with independent values F(x) ∼ P₀(·|x), x ∈ X. A *procedure with m questions* is any rule that, with internal randomness, chooses inputs x_1, …, x_m one after another, each as a function of its randomness and of the answers received so far, receives the answers y_1, …, y_m of the human, and finally accepts or rejects as a function of all it has seen.

(a) *Far apart at every input.* For every F and every x: TV(P_F(·|x), P₀(·|x)) = 1 − P₀(F(x)|x) ≥ 1 − p_max(x).
(b) *Equal test frequencies in the mean, nearly equal for most F.* Let μ be a law on X, coll(μ) := Σ_x μ(x)², and for a set B of pairs let freq_S(B) := Σ_x μ(x)·S(B_x|x). Then E_F[freq_{P_F}(B)] = freq_{P₀}(B) for every B. For a family (𝓑, π) and η ∈ (0, 1), with probability at least 1 − η over F: |freq_{P_F}(B) − freq_{P₀}(B)| ≤ √(coll(μ)·ln(2/(π(B)η))/2) for all B ∈ 𝓑.
(c) *Indistinguishable.* For every procedure with m questions, |E_F[Pr_{P_F}(accept)] − Pr_{P₀}(accept)| ≤ ξ, where ξ is the probability that the procedure, facing the human P₀, asks some input twice. If the procedure never repeats a question, E_F[Pr_{P_F}(accept)] = Pr_{P₀}(accept). If its questions are independent draws from μ, ξ ≤ C(m, 2)·coll(μ).
(d) *One human for each procedure.* For every procedure with m questions, every family (𝓑, π), every law μ and every η ∈ (0, 1) there is a function f: X → Y with
 Pr_{P_f}(accept) ≥ Pr_{P₀}(accept) − ξ − η,
 |freq_{P_f}(B) − freq_{P₀}(B)| ≤ √(coll(μ)·ln(2/(π(B)η))/2) for all B ∈ 𝓑, and
 TV(P_f(·|x), P₀(·|x)) ≥ 1 − p_max(x) for every x.

*Proof.* (a) The total variation between the point mass at y and a law p is 1 − p(y). (b) Linearity of expectation; the second statement is Proposition 5.2(a). (c) Realise the experiment with the human P_F as follows. Draw the randomness of the procedure. When the procedure asks an input x for the first time, draw the answer from P₀(·|x), independently of everything so far; when it asks an input again, repeat the earlier answer. This is the experiment with a random F: the values of F are independent, the input asked at a step is a function of the procedure's randomness and of the values of F at inputs asked earlier, so given all of these the value of F at a new input has the law P₀(·|x). Realise the experiment with the human P₀ with the same randomness and the same draws at first-time questions, and with fresh draws at repeated questions. The two transcripts agree up to the answer to the first repeated question. Hence they agree entirely on the event that no question is repeated, which is the same event in both experiments and has probability 1 − ξ. For independent questions from μ, two given questions coincide with probability coll(μ). (d) Let a_F := Pr_{P_F}(accept) and a₀ := Pr_{P₀}(accept), and let G be the set of functions for which the bound of (b) holds; Pr[F ∈ G] ≥ 1 − η. Since 0 ≤ a_F ≤ 1, E[a_F·1_G] ≥ E[a_F] − η ≥ a₀ − ξ − η. So either a₀ − ξ − η ≤ 0, and any f ∈ G will do, or E[a_F | F ∈ G] ≥ a₀ − ξ − η and some f ∈ G has a_f ≥ a₀ − ξ − η. (a) holds for every f. ∎

*Reading.* Let the procedure be any validation of the imitator A := P₀, for example the fair coin; the procedure may know A. Suppose that it accepts with probability at least 1 − α when the human is P₀ itself, as it must if a perfect imitator is to pass. By (d) there is a deterministic human f for whom this imitator is wrong at every single input with probability at least 1 − p_max(x) (1/2 for the coin; and for a scaffold all of whose runs make L calls, the run law of the coin and the run law of f are at total variation 1 − 2^(−L), because given (z, ρ) the run of f is one sequence of L answers and the coin produces it with probability 2^(−L)), who has the same frequencies as the imitator on all tests of the family up to √(coll(μ)·ln(2/(π(B)η))/2), and against whom the same imitator is accepted with probability at least 1 − α − ξ − η. So when repetitions are unlikely (m²·coll(μ) small), no procedure that uses m single answers can certify, for a human who may be non-deterministic, a bound on the distance between the imitator's and the human's answer laws: not at one input, not on average over inputs, not for runs. Frequencies of tests are what such answers determine (Theorem 6.1), and by Theorem 6.2(b) the two humans have nearly the same frequencies on every test of the family. This is the precise form of the sentence in `note.md`, Section 3.3: "No number of single answers at inputs that never repeat reveals the distribution P(·|x) at any one input; only frequencies of tests can be estimated."

*Which hypotheses are needed.* If the human is known to be deterministic, one answer reveals P(·|x), and faithfulness itself can be certified: Theorem V1(a). If inputs repeat, P(·|x) can be estimated at the repeated inputs; ξ measures this. In (c) and (d) the quantifiers are "for every procedure there is a human": a procedure that knows f distinguishes P_f from P₀ with one question. The human f of (d) is deterministic; by symmetry the same construction gives, for a deterministic imitator, a stochastic human.

**Example 6.3 (frequencies that are exactly equal). PROVED.** Let X = {0, 1}^d with the uniform law, f(x) := x_1 ⊕ … ⊕ x_d, and P₀ the fair coin. Let 𝓑_d be the family of all B ⊆ X × {0, 1} for which there is a coordinate i such that membership of (x, y) in B does not depend on x_i. Then freq_{P_f}(B) = freq_{P₀}(B) exactly for every B ∈ 𝓑_d, while TV(P_f(·|x), P₀(·|x)) = 1/2 at every x.

*Proof.* Let B not depend on x_i and let x′ be x with the i-th bit flipped; then f(x′) = 1 − f(x). So 1[(x, f(x)) ∈ B] + 1[(x′, f(x′)) ∈ B] = 1[(x, f(x)) ∈ B] + 1[(x, 1 − f(x)) ∈ B] = 1[(x, 0) ∈ B] + 1[(x, 1) ∈ B], and the last expression is the same for x and x′. Summing over the 2^(d−1) pairs {x, x′} gives Σ_x 1[(x, f(x)) ∈ B] = ½·Σ_x (1[(x, 0) ∈ B] + 1[(x, 1) ∈ B]). ∎

Here the two humans agree exactly on a large family and are separated by one simple test outside it, the parity itself. In Theorem 6.2(d) the function has no short description, and no test of the family and no procedure chosen in advance separates it from the coin.

---

## 7. Which hypotheses are needed

| statement | what it needs | what it does not need | why the hypothesis is needed |
|---|---|---|---|
| Pr3: Theorems 2.3, 2.5, Corollary 2.6, Proposition 3.9 | (IID); tests fixed before the data, with weights | A1, A2, any class, computability of the human | one run copied N times (Remark 2.7(2)); tests chosen after the data (2.7(3)); the price ln(1/π) (2.7(4)) |
| Pr4 in the class: Theorem 3.3, Proposition 3.8 | (IID); Q = Q_ν₀ for an index ν₀ | a stateless human beyond this; equality of kernels outside the inputs the scaffold reaches | outside the class no index may match: Example 3.11(c) |
| Pr4 in general: Theorem 3.6, Corollary 3.7 | (IID); weights with Σ w ≤ 1 | membership in the class, A1 | no penalty: the replay of the data wins, Example 3.11(b); factor 3: Example 3.11(a) |
| computing the estimate (3.5, Theorem 3.10) | a list of the heavy indices; exact comparison of likelihoods on given runs; a closed system for Q_ν(A_νν′) | Q, the densities of D₀ and Λ | lower semicomputable hypotheses: the comparison is not decidable |
| hindsight: Theorem 4.2, Corollary 4.3 | (Cl_R); data that abide by R | A1, A2, any law of the inputs | H_mem is not closed (remark after Theorem 4.5); under (Cl_R) nothing more holds at a fresh input (Corollary 4.6) |
| foresight: Theorem 4.7 | inputs independent from the law μ of the fresh input; the human never violates R on the support of μ | A2 for (a), (b), (c), (e), (f), (g); decidability of R | another input law: Theorem N1 of the note; the bound is attained: Proposition 4.8 |
| certificate: Theorem 6.1 | A frozen; A1 for the answers to the probes; tests fixed before validation | A2; anything about A or about how it was made | if A changes during validation the rounds are not identically distributed |
| limits of the certificate: Theorem 6.2 | P₀ not deterministic (p_max < 1); repetitions unlikely (ξ small) | | deterministic human: V1(a) certifies faithfulness; repeated inputs: P(·|x) can be estimated there |

---

## 8. What remains open, and remarks on other files of the project

### 8.1 Open in this part

1. **Natural reference machines** (4.13, item 4): no statement of the form "the universal mixture violates a simple property at a fresh input with probability O((K(R) + log n)/n)" is proved, and Theorem 4.11 shows that universality of the machine is not enough. What is proved is the bound with K*, the cost of the cheapest explanation of the answers.
2. **Constants of Theorem 3.6.** Whether 2·r_N(ν), that is the leading term √(2K ln 2/N), is the best possible for an estimator that returns a member of the class is not decided here. The Bayes procedure of Theorem A has √(K ln 2/(2N)) in expectation, but it returns a random mixture.
3. **Factor 2 with mixtures.** Bousquet, Kane and Moran obtain the factor 2 for finite classes with an estimator that may leave the class. A version for a countable class with weights, with an additive term of order √(K(ν)/N), was not attempted.
4. **Theorem 2.5(c).** For π(R)·δ ≤ 0.2 the joint statement held at confidence 1 − δ on a grid (Section 9, check (5) of the first block); this is not proved.
5. **Dependent runs.** If the top-level inputs of the recorded runs are chosen adaptively, the runs are not independent. Theorems 2.5(a), 3.3 and 3.6 should hold with a martingale inequality in place of Lemma 2.1; this was not written out.
6. **A last-round version of Proposition 4.9.** Theorem 4.7 is for inputs drawn independently from one law. Under rehearsal the questions come from the changing run laws of the mixtures, and Proposition 4.9 controls the violation rate only for the mixture of a uniformly random round, in expectation. A bound with high probability for the last mixture on its own run law is not proved (compare Remark 4.3 and Example 4.4 of `research/prove-b/hellinger-runs.md`: the expected divergence is not monotone).
7. **Necessity of K\* class by class.** Proposition 4.8 shows that Theorem 4.7 is sharp in one family of classes. Whether, in a given class, the violation probability at a fresh input can be bounded below in terms of K* is not examined.

### 8.2 Remarks on other files (things I noticed)

1. **`research/candidate-theory.md`, Pr3**: the two statements are claimed jointly with probability 1 − δ. This is false as stated (Theorem 2.5(c); found by the earlier worker): the joint confidence is 1 − 3δ/2, or use the divergence form (G), which contains both at confidence 1 − δ with ln(2/(πδ)) in the one-sided bound.
2. **`research/candidate-theory.md`, Pr4**: "Add to 𝓣 the sets {Q_ν > Q_ν′} … with weight w(ν)w(ν′)". If 𝓣 already has total weight 1, the union has total weight up to 2; with halved weights the bound is √((4K ln 2 + 2 ln(4/δ))/N) (Theorem 3.3). The constant 4K can be lowered to 2K (Corollary 3.7(a), Proposition 3.8). "The highest-weight sampler that matches all tests" is not defined when the human system is outside the class (Example 3.11(c)); the oracle inequality needs the penalised estimator of Definition 3.4. The inequality then holds in the form the draft hoped for, with the term √((2K(ν) ln 2 + 2 ln(2/δ))/N) in the place of C·√((K(ν) + ln(1/δ))/N) (Theorem 3.6).
3. **`research/candidate-theory.md`, Pr2, and the placeholder in `note.md`, Section 8.5**: "it stays near 1 for all n up to about K divided by the number of bits per pair" is true for the memoriser class H_mem (Theorem 4.5), but that class is not closed under conditioning on R, so the hindsight bound is not a statement about it (its conclusion holds there trivially). In a class that is closed under conditioning with constant C_R the violation probability at any input is at most 1 − 1/C_R, and it is this value, not 1, that the closed memoriser class approaches (Corollary 4.6). The two halves of the sentence in Section 8.5 need different classes, or the second half must say "stays near 1 − 1/C_R" (which is at least 1/2 when C_R ≥ 2). Also: "the probability a hypothesis gave to abiding so far" has to be read as "to not violating", with "no answer" counted as abiding; otherwise the class of all programs is not closed under the conditioning (Remark 4.4).
4. **`note.md`, Section 8.5**: the sentence "is not bounded in terms of K(R)" should be accompanied by what does hold: the violation probability at a fresh input is at most (K ln 2 + ln(1/δ))/n (Theorem 4.7(d)), and under rehearsal the expected number of violating calls of a deployed run is at most L·K ln 2/n (Proposition 4.9). The mixture pays K for a property, not K(R); it does not fail to pay.
5. **`note.md`, Theorem V1(b)**: correct as stated. Since the imitator's own frequency a(B) needs no human answer, the tolerance can be halved to √(ln(2/(π(B)δ))/(2m)), and the divergence form gives h(B) ≤ ln(2/(π(B)δ))/m for tests that the human's answers never met (Theorem 6.1(b)).
6. **`note.md`, Sections 3.3 and 8.2**: "for a human who is not deterministic this is also all that can be checked: each input is seen once" is true under the proviso that inputs do not repeat; Theorem 6.2 is the precise statement, with the probability ξ of a repetition as the error term.
7. **`note.md`, Section 8.4, second bullet** ("Single calls, not runs"): Example 5.3 is a minimal exact example of this failure: all per-call tests matched, a constant-price test of runs off by 1/2.
8. **`research/prove-b/property-batch.md`** (the earlier version of this file): in the proof of Lemma 2.1 the consequence was not argued for q ∈ {0, 1}; the case is trivial and is now included. Its scripts refer to statement numbers of a plan that was not written; the scripts in `research/prove-c/code/` carry the numbers of this file.
9. **`research/understand/indistinguishability.md`, Proposition I5** is Theorem 3.3 of this file for a one-call scaffold, with the same constants. Its part (b), the bound in total variation, needs the human in the class; for a human outside the class the counterpart is Theorem 3.6, with a different estimator. Item 3 of its Section 1 ("both regimes can be had from one learner") should be read with this restriction.

---

## 9. Numerical checks

All scripts are pure Python 3 and are run as `python3 NAME.py > NAME.out` in `research/prove-c/code/`. The outputs below are copied from the saved `.out` files.

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

---

## 10. References

How each source was accessed is stated where it is used (Sections 2, 3.6, 4.3, 5.2). In one place:

* W. Hoeffding, "Probability inequalities for sums of bounded random variables", *J. Amer. Statist. Assoc.* 58 (1963) 13–30. From memory. Theorem 1 (binomial tails in divergence form) is proved here as Lemma 2.1; Theorem 2 (independent bounded summands) is used as a standard fact in Proposition 5.2 and Theorem 6.1(a).
* J. Ville, *Étude critique de la notion de collectif*, Gauthier-Villars 1939. From memory; nothing rests on the citation, because the inequality is proved in two lines inside the proof of Theorem 4.7(b).
* Y. G. Yatracos, *Annals of Statistics* 13(2) (1985) 768–774. Not read; see 3.6.
* L. Devroye and G. Lugosi, *Combinatorial Methods in Density Estimation*, Springer 2001. Not read; Theorems 6.2 and 6.3 as restated by Mahalanabis and Štefankovič, see 3.6.
* S. Mahalanabis and D. Štefankovič, "Density estimation in linear time", arXiv:0712.2869v1 (2007). Read in this session (Sections 1, 2.1 and 4 of the arXiv version; the conference version, COLT 2008, was not read).
* S. Compton and J. Li, "Density estimation for Hellinger via minimum-distance estimators: mixtures of Gaussians, log-concave, and more", arXiv:2606.11469v1 (2026). Read in this session (Section 1.5).
* O. Bousquet, D. Kane and S. Moran, "The optimal approximation factor in density estimation", COLT 2019, PMLR 99, 318–341; arXiv:1902.05876. Read only through an automatic summary of the arXiv page; see 3.6.
* A. R. Barron and T. M. Cover, "Minimum complexity density estimation", *IEEE Trans. Inform. Theory* 37(4) (1991) 1034–1054. From memory; not used in any proof.
* L. Trevisan, M. Tulsiani and S. Vadhan, "Regularity, boosting, and efficiently simulating every high-entropy distribution" (2009). Not read; cited through `research/understand/indistinguishability.md`.
* Project files: `research/outline.md`, `research/candidate-theory.md`, `note.md`, `research/prove-b/hellinger-runs.md` (Theorem A, Theorem R1), `research/prove-b/property-batch.md`, `research/understand/notes.md` (Q5), `research/understand/indistinguishability.md`.

