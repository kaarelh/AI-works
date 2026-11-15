# The property idea in batch form: Pr1–Pr4 of the candidate theory (key: property-batch)

Worker's report. Everything below was derived in this session; the numerical checks are in `code/property-batch_*.py` and their output is quoted in Section 9. Tags: **PROVED** (complete proof below), **REFUTED** (counterexample below), **MODIFIED** (the draft's statement is changed, and the change is stated), **OPEN**.

@@SUMMARY@@

---

## 1. Setting and notation

The notation is that of the candidate theory (Section 1 there), with three changes, each forced by a defect.

* **Hypotheses are indices.** The draft's A2 calls H "a countable class of samplers with weights". Two descriptions of the same kernel must be allowed to carry separate weights (this is so in the universal class), so here H is a countable index set, each ν ∈ H names a sampler (also written ν), and w(ν) > 0 with Σ_ν w(ν) ≤ 1. K(ν) := log₂(1/w(ν)).
* **Data sets and the size of X.** The draft uses D for data and D₀ for the law of the top-level input. Here D_n denotes a data set of n pairs, and in Section 4 the finite input set has m elements.
* **Semimeasures.** A semimeasure sampler (Σ_y ν(y|x) ≤ 1) is completed by the outcome ⊥ with ν(⊥|x) := 1 − Σ_y ν(y|x). Put Y⊥ := Y ∪ {⊥}. The draft does not say what a scaffold does after ⊥; here a run stops at the first call that is answered ⊥.

**1.1 Runs.** A scaffold Π of horizon L consists of a law D₀ of the top-level input z ∈ Z, a law Λ of the internal randomness ρ (any measurable space), maps next_j(z, ρ, y_1..y_{j−1}) ∈ X ∪ {STOP} for j ≤ L, and an outcome map. A *complete run* is τ = (z, ρ, y_1, …, y_T) with T ≤ L such that next_j ≠ STOP for all j ≤ T, y_j ≠ ⊥ for j < T, and (T = L or y_T = ⊥ or next_{T+1} = STOP). The inputs x_j(τ) := next_j(z, ρ, y_{<j}) are functions of τ, so they need not be listed. Ω is the set of complete runs, with the product σ-algebra 𝔉 (Y⊥ is countable and discrete). An *answerer* A is a probability kernel giving the law of y_j ∈ Y⊥ given the history h_j = (x_1, y_1, …, x_{j−1}, y_{j−1}, x_j); a *sampler* is an answerer that depends on x_j only. Q_A is the law of the complete run when z ∼ D₀, ρ ∼ Λ independently, and each answer is drawn from A.

**Lemma 1.1 (likelihood of a run). PROVED.** For a sampler ν put L_ν(τ) := Π_{j ≤ T(τ)} ν(y_j | x_j(τ)) (the empty product is 1). Let B be the measure on Ω that is D₀ ⊗ Λ on (z, ρ) times counting measure on the answer sequences. Then B is σ-finite and Q_ν(E) = ∫_E L_ν dB for every E ∈ 𝔉. The same holds for an answerer A with L_A(τ) := Π_j A(y_j | h_j(τ)).

*Proof.* Fix (z, ρ). The complete answer sequences for (z, ρ) are the leaves of a tree of depth at most L with countable branching: a node y_{<j} is a leaf iff it is complete. Drawing the answers one after another, the probability of reaching a given leaf y_{1:T} is Π_{j≤T} ν(y_j|x_j), and the leaf probabilities sum to 1 (induction on the depth: at each inner node the probabilities of the children sum to 1, because ν(·|x) is a probability on Y⊥). Hence, given (z, ρ), the conditional law of the answer sequence has the density L_ν with respect to counting measure on the leaves. Integrating over (z, ρ) ∼ D₀ ⊗ Λ gives the claim (Tonelli; all integrands are nonnegative). B is σ-finite because there are countably many answer sequences and D₀ ⊗ Λ is a probability. ∎

So all run laws Q_ν have densities with respect to one measure B, and **the density L_ν(τ) can be evaluated from the transcript of the run and the sampler alone, without knowing D₀ or Λ.**

**1.2 The human system and the data.** Q denotes the law of one run of the human system: *any* probability measure on (Ω, 𝔉). When the human is a stateless sampler P (the draft's A1), Q = Q_P; but Sections 2, 3 and 5 do not need A1: the human may keep state inside a run, need not be computable, and need not be in any class. The only assumption on the data is

 **(IID)** τ_1, …, τ_N are independent, each with law Q.

Q̂_N(E) := (1/N)·#{i ≤ N : τ_i ∈ E} is the empirical measure. TV(Q, Q′) := sup_{E∈𝔉} |Q(E) − Q′(E)|.

**1.3 Tests.** A *test family* is a countable family 𝓣 ⊆ 𝔉 with weights π(R) > 0, Σ_{R∈𝓣} π(R) ≤ 1, fixed before the data are seen. For δ ∈ (0, 1):

 a_N(R) := ln(2/(π(R)·δ))/N,  tol_N(R) := √(a_N(R)/2) = √(ln(2/(π(R)δ))/(2N)) (the draft's tolerance).

For p, q ∈ [0, 1], kl(p‖q) := p·ln(p/q) + (1 − p)·ln((1 − p)/(1 − q)) is the divergence between Bernoulli laws (0·ln 0 = 0; the value is +∞ if q ∈ {0, 1} and p ≠ q). Note kl(1 − p‖1 − q) = kl(p‖q).

---

## 2. Pr1 and Pr3: matching the frequencies of tests

**Statement 2.0 (Pr1). PROVED** (it is the definition). TV(Q′, Q) ≤ ε holds iff |Q′(E) − Q(E)| ≤ ε for every event E ∈ 𝔉. So "every property of runs has probability within ε of its probability in the human system" is exactly TV(Q′, Q) ≤ ε, no more and no less; properties of probability below ε are not controlled by it.

**Lemma 2.1 (Chernoff bound in divergence form). PROVED.** Let S be binomial (N, q) and Q̂ = S/N. For x ∈ [q, 1]: Pr[Q̂ ≥ x] ≤ exp(−N·kl(x‖q)). For x ∈ [0, q]: Pr[Q̂ ≤ x] ≤ exp(−N·kl(x‖q)). Consequently, for every a > 0, Pr[kl(Q̂‖q) > a] ≤ 2e^{−Na}, and each of the events {Q̂ > q, kl(Q̂‖q) > a}, {Q̂ < q, kl(Q̂‖q) > a} has probability at most e^{−Na}.

*Proof.* Upper tail. If q ∈ {0, 1} or x = q the claim is trivial (the bound is 1, or Q̂ = q almost surely). Let 0 < q < x < 1 and λ := ln(x(1 − q)/(q(1 − x))) > 0. By Markov's inequality, Pr[S ≥ Nx] ≤ e^{−λNx}·E e^{λS} = (e^{−λx}(1 − q + qe^λ))^N, and e^{−λx}(1 − q + qe^λ) = (q(1 − x)/(x(1 − q)))^x·(1 − q)/(1 − x) = (q/x)^x((1 − q)/(1 − x))^{1−x} = e^{−kl(x‖q)}. For x = 1: Pr[S = N] = q^N = e^{−N·kl(1‖q)}. The lower tail follows by applying the upper tail to N − S, which is binomial (N, 1 − q), and kl(1 − x‖1 − q) = kl(x‖q).
For the consequence: u ↦ kl(u‖q) is continuous on [q, 1], zero at q and strictly increasing (its derivative ln(u(1 − q)/(q(1 − u))) is positive for u > q), with value ln(1/q) at 1. If a ≥ ln(1/q) the event {Q̂ > q, kl(Q̂‖q) > a} is empty. Otherwise let x_a ∈ (q, 1) be the point with kl(x_a‖q) = a; the event is {Q̂ > x_a} ⊆ {Q̂ ≥ x_a}, of probability at most e^{−Na}. The other side is symmetric. ∎

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
