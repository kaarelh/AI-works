# The property idea in batch form: Pr1 to Pr4, the Bayes mixture and a simple property, the certificate (key: property-batch)

Prover's file, third round. Sections 1 and 2 were written by the earlier worker (`research/prove-b/property-batch.md`); I checked them line by line, found them correct, closed one small gap (the case q ∈ {0, 1} in the proof of Lemma 2.1) and changed some letters so that the file agrees with `research/outline.md`. Sections 3 to 10 were written in this round. Every statement is proved in this file unless it is tagged otherwise. The numerical checks are in `research/prove-c/code/property-batch_*.py`; their output is saved next to them as `*.out` and quoted in Section 9.

Tags: **PROVED** (complete proof below), **REFUTED** (counterexample below), **MODIFIED** (the draft's statement is changed, and the change is stated), **NEW** (not in the candidate theory; proved below), **OPEN**.

@@SUMMARY@@

---

## 1. Setting and notation

The notation is that of `research/outline.md`. The following additions and changes are used throughout.

* **Hypotheses are indices.** The draft's A2 calls H "a countable class of samplers with weights". Two descriptions of the same kernel must be allowed to carry separate weights (this is so in the class of all programs), so here H is a countable index set, each ν ∈ H names a sampler (also written ν), and w(ν) > 0 with Σ_ν w(ν) ≤ 1. K(ν) := log₂(1/w(ν)).
* **Sample sizes.** N is the number of recorded runs of the human system (Sections 2, 3, 5). D_n is a data set of n question–answer pairs ((x_1, y_1), …, (x_n, y_n)) (Section 4). m is the number of validation questions (Section 6). In Section 4 the finite input set has u elements.
* **Semimeasures.** A semimeasure sampler (Σ_y ν(y|x) ≤ 1) is completed by the outcome ⊥ ("no answer") with ν(⊥|x) := 1 − Σ_y ν(y|x). Put Y⊥ := Y ∪ {⊥}. The draft does not say what a scaffold does after ⊥; here a run stops at the first call that is answered ⊥.
* **Letters.** len(τ) is the number of calls of the run τ (the outline keeps T for the deployed round). Γ is the reference measure on runs of Lemma 1.1. R denotes an event of runs (a *test*, Sections 2, 3, 5) or a set of pairs (a *property*, Section 4); B denotes a set of pairs used as a per-call test (Section 6), as in `note.md`. A pair (x, y) is a run of the scaffold that makes one call, so these uses agree. μ is a law on X (Sections 4 to 6).

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

**Proposition 3.8 (the highest-weight sampler that passes one-sided tests; both prices, constant 2K). NEW, PROVED.** Let (𝓣, π) be a test family, possibly empty, and δ ∈ (0, 1). Put δ′ := δ/2 if 𝓣 is not empty and δ′ := δ if it is. Let r_N be as in Definition 3.1 with κ = ln(2/δ′), and tol′_N(R) := √(ln(2/(π(R)δ′))/(2N)). Call ν ∈ H *admissible* if

 (1) U_N(ν, ν′) ≤ max{r_N(ν), r_N(ν′)} for every ν′ ≠ ν, and
 (2) |Q_ν(R) − Q̂_N(R)| ≤ tol′_N(R) for every R ∈ 𝓣,

and let ν̂ be an admissible index of the largest weight, if there is an admissible index. Assume (IID) and Q = Q_ν₀, K := K(ν₀). Then with probability at least 1 − δ: ν₀ is admissible, w(ν̂) ≥ w(ν₀),

 TV(Q_ν̂, Q) ≤ 2r_N(ν₀) = √((2K ln 2 + 2 ln(2/δ′))/N), and |Q_ν̂(R) − Q(R)| ≤ 2·tol′_N(R) for every R ∈ 𝓣.

*Proof.* Let G′ be the event of Theorem 2.5(a) for (𝓣, π) at level δ′ (if 𝓣 is empty, G′ is the sure event). Let E₁ be the event that Q(A_ν₀ν′) − Q̂_N(A_ν₀ν′) ≤ max{r_N(ν₀), r_N(ν′)} for all ν′ ≠ ν₀. By Lemma 3.2(b), and because e^(−2N·r_N(ν)²) = w(ν)δ′/2, the inequality for ν′ fails with probability at most min{w(ν₀), w(ν′)}·δ′/2 ≤ w(ν′)δ′/2; so E₁ fails with probability at most δ′/2. Let E₂ be the event that Q̂_N(A_νν₀) − Q(A_νν₀) ≤ r_N(ν₀) for all ν ≠ ν₀ with w(ν) ≥ w(ν₀). Each of these inequalities fails with probability at most w(ν₀)δ′/2 ≤ w(ν)δ′/2, so E₂ fails with probability at most δ′/2. Together G′ ∩ E₁ ∩ E₂ fails with probability at most 2δ′ = δ if 𝓣 is not empty, and at most δ′ = δ if it is.

On this event ν₀ is admissible: (1) is E₁, because U_N(ν₀, ν′) = Q(A_ν₀ν′) − Q̂_N(A_ν₀ν′), and (2) is G′. As in Theorem 3.3, an admissible index ν̂ of largest weight exists and w(ν̂) ≥ w(ν₀), so r_N(ν̂) ≤ r_N(ν₀). If ν̂ ≠ ν₀, let A := A_ν̂ν₀; then TV(Q_ν̂, Q) = U_N(ν̂, ν₀) + [Q̂_N(A) − Q(A)] ≤ max{r_N(ν̂), r_N(ν₀)} + r_N(ν₀) = 2r_N(ν₀), by (1) for ν̂ and by E₂. The statement about tests is the triangle inequality. ∎

Proposition 3.8 is Theorem 3.3 with better constants (2K in place of 4K) and smaller tests. It keeps what Corollary 3.7(a) does not give: every test of 𝓣 is matched at its own price, whatever K is. Like Theorem 3.3 it is a statement for a human system in the class.

### 3.4 Tests only: the price of a test needs no class

**Proposition 3.9 (least weighted test discrepancy over any set of candidates). NEW, PROVED.** Let 𝒞 be any set of probability measures on (Ω, 𝔉), for example the run laws of all samplers or of all answerers; 𝒞 need not be countable and carries no weights. Let (𝓣, π) be a test family, δ ∈ (0, 1), and for Q′ ∈ 𝒞

 d_N(Q′) := sup_{R ∈ 𝓣} (|Q′(R) − Q̂_N(R)| − tol_N(R))⁺.

Assume (IID). On the event of Theorem 2.5(a), which has probability at least 1 − δ, every Q′ ∈ 𝒞 with d_N(Q′) ≤ inf_𝒞 d_N + ε satisfies, for every R ∈ 𝓣,

 |Q′(R) − Q(R)| ≤ 2·tol_N(R) + inf_{Q″ ∈ 𝒞} sup_{R′ ∈ 𝓣} |Q″(R′) − Q(R′)| + ε.

If Q ∈ 𝒞 (for example: 𝒞 is the set of run laws of all answerers and the human system is the scaffold run with some answerer), the middle term is 0.

*Proof.* On the event, for Q″ ∈ 𝒞 and R′ ∈ 𝓣: |Q″(R′) − Q̂_N(R′)| − tol_N(R′) ≤ |Q″(R′) − Q(R′)|. So d_N(Q″) ≤ sup_{R′} |Q″(R′) − Q(R′)|, hence d_N(Q′) ≤ inf_{Q″} sup_{R′} |Q″(R′) − Q(R′)| + ε. And |Q′(R) − Q(R)| ≤ |Q′(R) − Q̂_N(R)| + tol_N(R) ≤ d_N(Q′) + 2·tol_N(R). ∎

This is Corollary 2.6 without the assumption that a matching candidate exists. The complexity of the candidates does not enter, because the deviation bound concerns the tests and not the candidates. What is lost is in the middle term and in the conclusion: both see the candidates only through the tests of 𝓣 (Section 5).

### 3.5 What must be computable for the estimators to be defined

As mathematical objects the estimators of this section are defined for every countable class with weights. To compute the estimate of Definition 3.4 one needs the following, and nothing else.

**(C1) A finite list of candidates.** By Lemma 3.5 the set of ε-minimisers is determined by the indices of weight at least e^(κ−2N(1+r_N(ν₁)+ε)²): an index of smaller weight cannot be an ε-minimiser, and a competitor ν′ of weight at most e^(κ−2N) contributes nothing to any Δ_N(ν). One must be able to list the indices of weight above a given threshold. This is possible when w(ν) = 2^(−ℓ(ν)) for the lengths ℓ of programs in a prefix-free language. It is not possible when the weight is defined through the length of the *shortest* program for the kernel, which is not computable.

**(C2) For every recorded run τ_i and every pair of candidates: is L_ν(τ_i) > L_ν′(τ_i)?** By Lemma 1.1 both sides are products of at most L numbers ν(y_j|x_j) that are read off the transcript; D₀ and Λ are not needed, and neither is ρ if the transcript lists the inputs. The comparison must be decided exactly. This is possible when the probabilities ν(y|x) are rational numbers computable from (ν, x, y), for example for programs with a time bound. For lower semicomputable semimeasures (the class of all programs) L_ν(τ) is only a limit from below, and in general neither "L_ν(τ) > L_ν′(τ)" nor its negation can be confirmed by a finite computation; the estimate is then defined but not computable. Ties are harmless: Lemma 3.2(a) and all proofs hold for any measurable set A with {L_ν > L_ν′} ⊆ A ⊆ {L_ν ≥ L_ν′} in place of A_νν′.

**(C3) The numbers Q_ν(A_νν′).** This is the probability that a run of the scaffold answered by ν lies in A_νν′: a property of the scaffold and of two hypotheses, in which the human does not occur. It needs the laws D₀ and Λ of the scaffold, that is, a closed system. If (z, ρ) takes finitely many values with known rational probabilities and Y is finite, it is a finite sum over the tree of runs. In general it can be replaced by a simulation:

**Theorem 3.10 (the estimator with simulated runs). NEW, PROVED.** Let N_s ≥ 1. For each ν ∈ H let Q̃_ν be the empirical measure of N_s independent runs with law Q_ν (simulations of the scaffold with ν answering). The simulations are independent of the data; those of different indices may depend on each other, for example through a shared (z, ρ). Fix κ ≥ 0, put r̃(ν) := r_N(ν) + r_{N_s}(ν), and define Ũ(ν, ν′) := Q̃_ν(A_νν′) − Q̂_N(A_νν′), Δ̃(ν) := sup_{ν′≠ν} (Ũ(ν, ν′) − r̃(ν′))⁺ and c̃(ν) := Δ̃(ν) + r̃(ν). Assume (IID). Let δ ∈ (0, 1), s := √((ln(2/δ) − κ)⁺/(2N)) and s̃ := √((ln(2/δ) − κ)⁺/(2N_s)). There is an event of probability at least 1 − 2δ on which every ε-minimiser ν̂ of c̃ satisfies

 TV(Q_ν̂, Q) ≤ 3·TV(Q_ν, Q) + 2r_N(ν) + 2r_{N_s}(ν) + 2s + 2s̃ + ε for every ν ∈ H.

*Proof.* Let ν* minimise 3·TV(Q_ν, Q) + 2r̃(ν); it suffices to prove the inequality for ν = ν*. Let E₁, E₂ be as in the proof of Theorem 3.6, and

 E₃: Q̃_ν*(A_ν*ν′) − Q_ν*(A_ν*ν′) ≤ r_{N_s}(ν′) + s̃ for all ν′ ≠ ν*,
 E₄: Q_ν′(A_ν′ν*) − Q̃_ν′(A_ν′ν*) ≤ r_{N_s}(ν′) + s̃ for all ν′ ≠ ν*.

By Lemma 3.2(b), (c), applied to the N_s simulated runs of ν* (for E₃) and of ν′ (for E₄), each single inequality fails with probability at most w(ν′)δ/2; no independence between different ν′ is used. So all four events hold with probability at least 1 − 2δ. On them, with TV* := TV(Q_ν*, Q): Ũ(ν*, ν′) = [Q̃_ν*(A) − Q_ν*(A)] + U_N(ν*, ν′) ≤ TV* + r̃(ν′) + s + s̃, so c̃(ν*) ≤ TV* + s + s̃ + r̃(ν*). For an ε-minimiser ν̂ ≠ ν* and A := A_ν̂ν*: U_N(ν̂, ν*) = Ũ(ν̂, ν*) + [Q_ν̂(A) − Q̃_ν̂(A)] ≤ Δ̃(ν̂) + r̃(ν*) + r_{N_s}(ν̂) + s̃ by E₄, and Q̂_N(A) − Q(A) ≤ r_N(ν̂) + s by E₂. As in Step 2 of Theorem 3.6, TV(Q_ν̂, Q_ν*) ≤ c̃(ν̂) + r̃(ν*) + s + s̃ + TV* ≤ 2·TV* + 2r̃(ν*) + 2s + 2s̃ + ε. ∎

So with a closed system the following suffice: the transcripts of N runs of the human system; the ability to run the scaffold with a hypothesis in place of the human; and exact comparison of likelihoods on these runs. N_s costs computation only, and for N_s → ∞ the bound becomes that of Theorem 3.6.

**What need not be known or computed:** the law Q of the human system; the densities of D₀ and Λ; any prior belief about the human. The weights w act as penalties, not as beliefs: the theorems hold for every human system and every choice of w, and w(ν) enters the bound only through the index ν with which one compares.

### 3.6 Sharpness, the hypotheses that are needed, and the literature

**Examples 3.11.** In (a) to (c) the scaffold makes one call with a fixed input, so a run is an answer y ∈ Y and a hypothesis is a probability vector on Y.

(a) *The factor 3 is attained by the estimator of Definition 3.4.* (The example is Lemma 11 of Mahalanabis and Štefankovič (2008), who use it for all selection rules that depend on the data through the test statistics only.) Let Y = {1, 2, 3, 4}, 0 < ε₀ < 1/4, and

 ν₁ = (0, 1/4 + ε₀, 1/2, 1/4 − ε₀), ν₂ = (1/2 + ε₀, 1/4 − ε₀, 0, 1/4), Q = (1/2, 1/2, 0, 0),

with w(ν₁) = w(ν₂). Then A_ν₁ν₂ = {2, 3}, A_ν₂ν₁ = {1, 4}, Q_ν₁(A_ν₁ν₂) = Q_ν₂(A_ν₂ν₁) = 3/4 + ε₀, TV(Q_ν₁, Q) = 3/4 − ε₀ and TV(Q_ν₂, Q) = 1/4 + ε₀. The data fall on the answers 1 and 2 only, so U_N(ν₁, ν₂) = 3/4 + ε₀ − Q̂_N({2}) and U_N(ν₂, ν₁) = 3/4 + ε₀ − Q̂_N({1}), with Q̂_N({1}) + Q̂_N({2}) = 1. Let N be odd and so large that r_N(ν₁) < 1/4. With probability exactly 1/2, Q̂_N({2}) > 1/2; then U_N(ν₁, ν₂) < 1/4 + ε₀ < U_N(ν₂, ν₁) and U_N(ν₂, ν₁) > r_N, so c_N(ν₁) < c_N(ν₂) and ν̂ = ν₁. On this event TV(Q_ν̂, Q) = 3/4 − ε₀ = (3 − 16ε₀/(1 + 4ε₀))·min_ν TV(Q_ν, Q). So for no c < 3 does this estimator satisfy TV(Q_ν̂, Q) ≤ c·min_ν TV(Q_ν, Q) + o(1) with probability above 1/2. For every estimator that must return a member of the class the same is true: Bousquet, Kane and Moran (2019), Theorem 2 (see below). An estimator that may return a mixture of members can reach the factor 2 (the same paper, Theorem 1); I have not carried this over to weighted classes.

(b) *For an infinite class the penalty is needed.* Let Y = {1, …, u} and let the human answer uniformly: Q uniform on Y. Let H contain Q and, for every set S ⊆ Y of N elements, the uniform law Q_S on S. If the N recorded answers are distinct (probability at least 1 − N²/(2u)), then Q̂_N = Q_S for S the set of recorded answers, so U_N(Q_S, ν′) = 0 for every ν′. Without penalties (Definition 3.4 with r_N ≡ 0) the criterion is therefore minimised by the hypothesis that replays the data, and TV(Q_S, Q) = 1 − N/u; for the human's own index, A_{Q,Q_S} = Y∖S and U_N(Q, Q_S) = Q(Y∖S) − Q̂_N(Y∖S) = 1 − N/u. With weights that are equal among the C(u, N) hypotheses Q_S we have w(Q_S) ≤ 1/C(u, N) ≤ (N/u)^N, so r_N(Q_S) ≥ √(ln(u/N)/2). As soon as u > N·e^(2(1+r_N(Q))²), this gives c_N(Q_S) ≥ r_N(Q_S) > 1 + r_N(Q) ≥ c_N(Q), and no replaying hypothesis is selected. (Theorem 3.6 holds whatever the weights are; the example shows what the penalty is for.)

(c) *Outside the class, "the highest-weight index that matches" need not exist.* Let Y = {0, 1}, H = {ν₁, ν₂} with ν₁(1) = 1/4, ν₂(1) = 3/4, and Q(1) = 1/2. Then A_ν₂ν₁ = {1}, A_ν₁ν₂ = {0}, Q̂_N({1}) → 1/2 almost surely, so |Q_ν(A_ν₂ν₁) − Q̂_N(A_ν₂ν₁)| → 1/4 for both ν and U_N(ν₁, ν₂), U_N(ν₂, ν₁) → 1/4, while every tolerance tends to 0. For large N neither index matches in the sense of Theorem 3.3, and neither is admissible in the sense of Proposition 3.8. The estimator of Definition 3.4 returns one of the two; both are at distance 1/4 from Q.

(d) *(IID) is needed*: Remark 2.7(2).

(e) *The Yatracos sets must be among the tests if the conclusion is to be about total variation.* A sampler can match every test of a family of small total price and be at total variation 1/2 from the human system: Proposition 5.2.

**The literature, and how each statement was accessed.**

* Y. G. Yatracos, "Rates of convergence of minimum distance estimators and Kolmogorov's entropy", *Annals of Statistics* 13(2) (1985) 768–774. Not read in this session; cited for the sets A_νν′ and the minimum-distance principle as described in the three sources below.
* L. Devroye and G. Lugosi, *Combinatorial Methods in Density Estimation*, Springer 2001, Chapter 6. Not read in this session. Read in this session in a restatement: S. Mahalanabis and D. Štefankovič, "Density estimation in linear time", arXiv:0712.2869v1 (2007; COLT 2008), Section 1, which states: for a finite class F of densities, the unknown density g, the empirical measure h, the test functions T_ij := sgn(f_i − f_j) and Δ := max_T (g − h)·T, "Theorem 3 ([DL01], Theorem 6.3)": the minimum distance estimate f₁, which minimises max{|(f − h)·T_ij| ; f_i, f_j ∈ F}, satisfies ‖f₁ − g‖₁ ≤ 3·d₁(g, F) + 2Δ; and "Theorem 2 ([DL01], Theorem 6.2)": the Scheffé tournament winner satisfies ‖f₁ − g‖₁ ≤ 9·d₁(g, F) + 8Δ. Their Remark 1 says that their Δ is at most twice the Δ of Devroye and Lugosi, which is defined with the sets {f_i > f_j}. In our units (TV is half the L₁ distance) Theorem 6.3 reads TV ≤ 3·inf TV + Δ. Also read in this session: S. Compton and J. Li, "Density estimation for Hellinger via minimum-distance estimators", arXiv:2606.11469v1 (2026), Lemma 5, which states the same result as E[TV(f, f̂_n)] ≤ 3·inf_θ TV(f, f_θ) + O(√(VC(𝒜)/n)) for the Yatracos class 𝒜 = {{x : f_θ(x) > f_θ′(x)}}.
* Mahalanabis and Štefankovič, as above [read]: their Theorem 4 proves the same guarantee for the "modified minimum distance estimate", which minimises max{|(f_i − h)·T_ij| ; f_j ∈ F} over i, that is, which uses for each candidate only the test functions in which the candidate takes part; their Remark 5 notes that the deviation of h from g is needed only on the test functions of the best member; their Lemma 11 is Example 3.11(a). Definition 3.4 is this estimate with weights and with one-sided statistics; Theorem 3.6 is its analysis with a weighted union bound. I did not find the weighted statement in the literature and I do not claim that it is new.
* O. Bousquet, D. Kane and S. Moran, "The optimal approximation factor in density estimation", *Proceedings of COLT 2019*, PMLR 99, 318–341; arXiv:1902.05876. Read in this session only through an automatic summary of the arXiv page (version 5): Theorem 2 there states that for every α < 3 there is a class of two densities that is not properly α-learnable, and Theorem 1 that every finite class is 2-learnable by an algorithm whose output need not lie in the class. The exact quantifiers should be checked in the source before the note relies on them.
* The weighted union bound ("Occam bound") is standard. A related likelihood-based estimator with rates in Hellinger distance governed by min_ν [K(ν)/N + divergence] is "minimum complexity density estimation" (A. R. Barron and T. M. Cover, *IEEE Trans. Inform. Theory* 37(4) (1991) 1034–1054; from memory, not checked); in this project its counterpart is Theorem B of `research/prove-b/hellinger-runs.md`.

<!--CONTINUE-->
