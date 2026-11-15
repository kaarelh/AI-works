# Lower bounds: what no imitation protocol can do (N1, N2, N3, N5, the dependence on K)

Part `lower-bounds` of the check of `research/candidate-theory.md` (version 2). All proofs below are mine and unrefereed. Scripts: `research/prove/code/lower-bounds_lp.py`, `research/prove/code/lower-bounds_sim.py`; their output is quoted in Section 8.

## 0. Summary

| # | statement | relation to the candidate theory | tag |
|---|---|---|---|
| Lemma 1.5 | Two samplers that agree on a set A give the same transcript law up to the probability γ that the protocol asks outside A | tool | PROVED |
| Theorem 1.6 | N1 for randomised adaptive protocols and randomised, history-dependent, abstaining deployed systems: failure sum ≥ 1 − γ; run laws differ by at most γ | N1 | PROVED (N1 MODIFIED: quantitative in γ, run-level form added) |
| Corollary 1.7 | Sum of the two silent-error probabilities ≥ 1 − γ − (abstention probability); never silently wrong on both ⇒ silent with probability ≥ 1 − γ | Section 0, item 5 | PROVED |
| Proposition 1.8 | Universal class: for a function f, a patch f_x with K(f_x) ≤ K(f) + sep(x; A) + c. For a sampler P, "P_x(·\|x) ⟂ P(·\|x)" is impossible when P(·\|x) has full support; true replacement: TV ≥ 1 − η at K(P) + sep(x; A) + log(1/η) + 2 log log(1/η) + c | last sentence of N1 | MODIFIED (REFUTED as stated for samplers) |
| Lemma 1.10 | Patch-family lemma: N disjoint patches of influence ≥ Δ force failure ≥ (N − n)Δ/(N + M) | tool for N2, N3, N5 | PROVED |
| Theorem 2.1 | N2 exact: needle class with N₀ cells, L calls: every protocol has max failure ≥ (N₀ − n)p/(N₀ + L), p = 1 − (1 − 1/N₀)^L | N2 | PROVED (constants improved) |
| Corollary 2.2 | Failure ≤ δ for all members needs n ≥ L/(4δ) − L (N₀ = L/(2δ)); the candidate's class N₀ = L/ε with failure ε/4 needs n ≥ (3/4)(1 − ε)L/ε | N2 | PROVED (candidate's "L/(2ε)" improved) |
| Proposition 2.3 | Tightness: a protocol with max failure (1 − n/N₀)p; minimax value known within the factor 1 + L/N₀ | N2 | PROVED |
| Proposition 2.5 | Even if the human may be asked after z is seen, during the run: n ≥ L(1 − √(2δ) − δ) − δ | new | PROVED |
| Theorem 3.1 | Factor K: block class of 2^K functions, K = m·log₂N: max failure ≥ p(1 − 2L/N − 2n/(mN)); failure ≤ δ needs n ≥ (1 − 10δ)·K·L/(8δ·log₂(L/2δ)) | task item 2 | PROVED |
| Proposition 3.2 | Tightness of Theorem 3.1 up to 1 + O(δ) in expected questions | | PROVED |
| Theorem 3.3 | Protocol AB (plurality answers plus targeted questions): for every class of functions with weights and every scaffold, a deployed run is faithful with probability ≥ 1 − ε after at most 1 + 2.7·K·L/(ε·log₂(L/ε)) questions | new upper bound; improves R2/R4 by a factor ≈ log₂(L/ε)/3.9 | PROVED |
| Corollary 3.4 | In terms of the VC dimension d: every protocol needs (1 − 10δ)·d·L/(8δ) questions for some class and scaffold. In terms of bits K = log(1/w): "every protocol needs c·K·L/ε" is false; the true order is K·L/(ε·log(L/ε)) (constants 1/8 and 2.7) | task item 2 | PROVED for VC dimension; REFUTED as stated for K, replacement PROVED |
| Theorem 4.1 | N3 exact: with N disjointly supported shifts, advantages over 1/2 satisfy Σ_i 2η_i ≤ n; right with probability ≥ 1/2 + η everywhere needs n ≥ 2ηN, and n = 2ηN suffices | N3 | MODIFIED (as stated N3 is false for randomised protocols: one question gives probability > 1/2 everywhere) |
| Theorem 4.3 | N shifts and an L-call scaffold: n ≥ N·(L/(4δ) − 3L/2) | N3 with N2 | PROVED |
| Proposition 4.4 | S2: (a) the domination inequality with B_i ≤ 1/π_i; (b) it is a protocol when the family of task laws is uniformly samplable; (c) no almost surely halting sampler dominates all samplable laws, so the universal mixture needs an oracle | S2 | (a) PROVED, (b)–(c) MODIFIED ("samplable" made exact) |
| Proposition 5.2 | Upper bound through the robustness curve: failure ≤ (concave majorant of δ_Π)(L·K ln 2/n) for functions; contains R3 | R3 "sharper form", first half | PROVED |
| Theorem 5.3 | N5: block-majority scaffold tolerating m faults with failure 0: n ≥ (1 − 4δ)·L/(4(2m+1)δ) | N5 | PROVED |
| Proposition 5.4 | What the method can give: for deterministic members that all tolerate m faults the patch lemma cannot exceed L/(4(2m+1)δ) on non-adaptive scaffolds; gap to R3 is the factor 4 ln 2·K·(2m+1)/(m+1) | N5 | PROVED |
| Example 5.5 | "For classes closed under patches about L/β questions are needed to get below δ_Π(β)" fails for a scaffold that repeats one input | R3 "sharper form", second half | REFUTED as stated; replacement = Proposition 5.4(a) |
| Theorem 6.1 | Stochastic, per call: class of 2^K samplers, E TV per call ≥ √(K/n)/(16√2); per-call TV ε′ needs n ≥ K/(512ε′²) | task item 5 | PROVED |
| Lemma 6.2 | TV(Bin(L, ½+θ), Bin(L, ½−θ)) ≥ θ√L(1 − 2Lθ²) | tool | PROVED |
| Theorem 6.3 | Stochastic, whole runs: E TV(run laws) ≥ √(LK/n)/(64√2) for n ≥ max{K/2, LK/8}; TV ≤ ε needs n ≥ L·K/(8192ε²) | matches R2 up to constants | PROVED |
| Theorem 7.1 | Conclusion: one run of L critical calls is not amplified (in advance: ≥ L/(4δ) − L answers; during the run: ≥ L(1 − √(2δ) − δ) − δ); r runs all correct with probability 1 − ε need ≥ rL/(4ε) − rL; a per-run failure rate δ is bought once for all future runs | task item 6 | PROVED |
| Section 9 | Open questions | | OPEN |

Conventions. log is log₂, ln the natural logarithm. [N] := {1, …, N}. TV is total variation distance (half the L₁ distance). "Function" means a sampler whose answers are deterministic.

**Changes of notation.** (1) The candidate uses the letter A both for an answerer and, in N1, for a set of inputs. Here A is always a set of inputs (as in sep(x; A)); what is deployed is called a *deployed system* (Definition 1.3). (2) The candidate states N2 with one parameter ε that fixes the class (N₀ = L/ε) and the failure level (ε/4). Here the failure level is δ and the class parameter N₀ is free; this is what allows the constants to be optimised. (3) n may be a bound on the *expected* number of questions; this is weaker than a worst-case bound, so the lower bounds are stronger.

## 1. Setting, and N1

### 1.1 Protocols and deployed systems

X and Y are countable sets, samplers and the class H with weights w are as in Section 1 of the candidate theory (A1, A2), K := log(1/w(P)).

**Definition 1.1 (protocol).** A *protocol* Λ consists of a seed r drawn from a probability space (R, λ₀), a number of steps T < ∞, and maps q_t(r, y_1, …, y_{t−1}) ∈ X ∪ {∅} for t ≤ T. In the interaction of Λ with a sampler P, at step t the protocol puts the question x_t := q_t(r, y_1, …, y_{t−1}) to the human if x_t ∈ X and receives y_t ~ P(·|x_t), drawn with coins independent of r and of all earlier draws (A1, A3); if x_t = ∅ nothing is asked and y_t := ∅. The *transcript* is D := (x_t, y_t)_{t ≤ T}. The number of questions is N_Λ := #{t : x_t ∈ X}. The protocol is adaptive and randomised; it may do any computation, in particular rehearsal runs of a scaffold. Pr_P and E_P refer to the interaction with P.

**Definition 1.2 (scaffold, runs).** As in the candidate theory: z ~ D₀, internal randomness ρ, next_j(z, ρ, y_1, …, y_{j−1}) ∈ X ∪ {STOP} for j ≤ L, and out(z, ρ, y_1, …, y_T′) ∈ O, where T′ ≤ L is the number of calls of the run. For a function f, run_f(z, ρ) is the run in which f answers every call, and out_f(z, ρ) its outcome. (z, ρ) is drawn after the interaction and independently of (r, D).

**Definition 1.3 (deployed system).** A *deployed system* is a measurable map g that assigns to (r, D, z, ρ, s), where s is fresh randomness independent of everything else, an outcome ô ∈ O ∪ {⊥}; ⊥ means that the system is silent (it abstained). The case of the candidate theory is a *deployed answerer*: a rule that produces the answer to call j, or ⊥, from (r, D, s) and the history of the run so far; Π is run with it, and ô is the outcome of that run, or ⊥ if some call was answered ⊥. A deployed answerer may be history-dependent and randomised. Every lower bound below is proved for deployed systems, which may in addition see z and ρ in full; the bounds therefore hold for deployed answerers.

**Definition 1.4 (failure).** For a function f the *failure probability* of (Λ, g) is Fail(f) := Pr_f[ô ≠ out_f(z, ρ)]: the outcome is wrong or silent. A deployed answerer's run is *faithful* if it equals run_f(z, ρ); a faithful run has the right outcome, so Pr_f[run not faithful] ≥ Fail(f), and every lower bound on Fail is a lower bound on the probability of an unfaithful run.

### 1.2 Indistinguishability

**Lemma 1.5.** Let P, P′ be samplers and A ⊆ X with P(·|a) = P′(·|a) for all a ∈ A. For a protocol Λ let τ be the first step t with x_t ∈ X ∖ A (τ := ∞ if there is none). Then the interactions of Λ with P and with P′ can be defined on one probability space, with the same seed, so that τ is the same in both and the two transcripts agree up to (not including) the answer at step τ. In particular γ := Pr_P[τ < ∞] = Pr_{P′}[τ < ∞], and the laws of (r, D) under P and under P′ are within total variation γ.

*Proof.* Fix an enumeration of Y. For a sampler ν let F_ν(x, u) be the quantile map of ν(·|x) with respect to this enumeration, so that F_ν(x, U) ~ ν(·|x) for U uniform on [0, 1]; then F_P(a, ·) = F_{P′}(a, ·) for a ∈ A. Take r ~ λ₀ and independent uniform U_1, …, U_T, and let both interactions use y_t := F_ν(x_t, U_t), with ν = P and ν = P′. By induction on t, for t < τ (τ defined by the interaction with P) the questions and answers of the two interactions coincide: the question at step t is a function of r and of the earlier answers, hence equal, it lies in A ∪ {∅}, and so the answers are equal. The question at step τ is again a function of r and equal earlier answers, so it is the same in both interactions and lies outside A; hence τ is the same. On {τ = ∞} the transcripts are equal, which gives the total variation bound. ∎

**Theorem 1.6 (N1).** Let P, P′ ∈ H agree on A ⊆ X, let Λ be a protocol, g a deployed system, and γ := Pr_P[Λ asks a question outside A] (by Lemma 1.5 the same under P′). Let Q̂_P, Q̂_{P′} be the laws of (z, ρ, ô) under P and P′.
1. TV(Q̂_P, Q̂_{P′}) ≤ γ. For a deployed answerer the same holds for the law of the whole deployed run.
2. For any two disjoint events G, G′ of (z, ρ, ô) ("good for P", "good for P′"): Q̂_P(not G) + Q̂_{P′}(not G′) ≥ 1 − γ.
3. For any two target laws Q, Q′ of (z, ρ, o) (for example the human systems Q_P, Q_{P′}): TV(Q̂_P, Q) + TV(Q̂_{P′}, Q′) ≥ TV(Q, Q′) − γ.
4. (Single call.) Let the task be one call at an input x ∉ A, and let R, R′ be the laws of the deployed answer in Y ∪ {⊥} under P and P′. Then TV(R, P(·|x)) + TV(R′, P′(·|x)) ≥ TV(P(·|x), P′(·|x)) − γ. If P = f and P′ = f′ are functions with f(x) ≠ f′(x): Pr_f[answer ≠ f(x)] + Pr_{f′}[answer ≠ f′(x)] ≥ 1 − γ, where a silent answer counts as ≠.

In particular, if all questions lie in A with probability one (γ = 0): for functions with f(x) ≠ f′(x), the deployed answer at x is wrong or silent with probability at least 1/2 for one of the two members; and in general no deployed system has a run law closer than TV(Q_P, Q_{P′})/2 to both human systems.

*Proof.* (1) (z, ρ, s) is independent of (r, D) and has the same law under P and P′, and ô is a function of (r, D, z, ρ, s); so the total variation between the laws of (z, ρ, ô) is at most that between the laws of (r, D), which is at most γ by Lemma 1.5. The run of a deployed answerer is likewise a function of (r, D, z, ρ, s). (2) Q̂_P(G) + Q̂_{P′}(G′) ≤ Q̂_P(G) + Q̂_P(G′) + γ ≤ 1 + γ. (3) Triangle inequality: TV(Q, Q′) ≤ TV(Q, Q̂_P) + TV(Q̂_P, Q̂_{P′}) + TV(Q̂_{P′}, Q′). (4) The first claim is (3) for the scaffold with one call at x and outcome = answer; the second is (2) with G = {ô = f(x)} and G′ = {ô = f′(x)}. ∎

**Corollary 1.7 (abstention does not help; it only makes the failure visible).** In the situation of Theorem 1.6(4) with functions f, f′, f(x) ≠ f′(x), let s_f := Pr_f[answer ∉ {f(x), ⊥}] be the probability of a *silent error* under f, and similarly s_{f′}. Then

  s_f + s_{f′} ≥ 1 − γ − min{R(⊥), R′(⊥)}.

So if γ = 0 and the deployed system is never silently wrong for both members, it abstains at x with probability one under both. More generally, if the questions lie in a set A with probability one and H contains, for every x′ ∉ A, a member that equals f on A and differs from f at x′, then a rule that is never silently wrong for every member of H abstains with probability one at every input outside A when the human is f.

*Proof.* s_f + s_{f′} = 2 − R(f(x)) − R(⊥) − R′(f′(x)) − R′(⊥). By Theorem 1.6(1), R′(f′(x)) ≤ R(f′(x)) + γ, and R(f(x)) + R(f′(x)) + R(⊥) ≤ 1. Hence s_f + s_{f′} ≥ 2 − (1 − R(⊥)) − γ − R(⊥) − R′(⊥) = 1 − γ − R′(⊥); by symmetry the same with R(⊥). ∎

**Proposition 1.8 (the universal class).** Let H be the class of all lower semicomputable samplers with w(ν) = 2^(−K(ν)), K(ν) the prefix complexity of a program for ν on the reference machine, and let sep(x; A) be the least K(Q) over decidable Q ⊆ X with x ∈ Q and Q ∩ A = ∅ (`understand/repo.md`, Section 1). There is a constant c, depending only on the reference machine, such that for every A ⊆ X and every x ∉ A with sep(x; A) < ∞:
1. for every computable function f there is a computable function f_x with f_x = f on A, f_x(x) ≠ f(x) and K(f_x) ≤ K(f) + sep(x; A) + c;
2. for every P ∈ H and every integer N ≥ 2 there is P_x ∈ H with P_x = P on A, TV(P_x(·|x), P(·|x)) ≥ 1 − 1/N and K(P_x) ≤ K(P) + sep(x; A) + log N + 2 log log N + c;
3. if P(y|x) > 0 for all y ∈ Y, no sampler P_x has P_x(·|x) ⟂ P(·|x). So the last sentence of N1 ("P_x(·|x) ⟂ P(·|x) with K(P_x) ≤ K(P) + sep(x; A) + c") is false for such P, and (2) is its replacement.

Consequently (Theorem 1.6): a protocol whose questions lie in A is, at x, wrong or silent with probability ≥ 1/2 for f or for f_x; and for samplers its answer law at x is at total variation ≥ (1 − 1/N)/2 from the truth for P or for P_x.

*Proof.* Let Q be a decidable set of complexity sep(x; A) that separates x from A. (1) Let f_x(x′) := f(x′) followed by the symbol 1 if x′ ∈ Q, and f(x′) otherwise. A program for f_x consists of a program for f, a program deciding Q and a fixed piece of code, so K(f_x) ≤ K(f) + K(Q) + c. (2) Among the first N strings y_1, …, y_N of Y some y_i has P(y_i|x) ≤ 1/N. Let P_x answer y_i with probability one on inputs in Q and as P elsewhere. Then TV(P_x(·|x), P(·|x)) = 1 − P(y_i|x) ≥ 1 − 1/N, and a program for P_x consists of programs for P and Q, a self-delimiting code of the index i ≤ N (at most log N + 2 log log N + O(1) bits) and fixed code. (3) Two laws on a countable set are mutually singular only if one of them gives probability 0 to a set of probability 1 under the other; with P(·|x) positive everywhere the only null set is empty. ∎

**Remark 1.9 (which hypotheses N1 needs).** (a) *The class must contain the patch.* For H = {f, f′} with f(x′) ≠ f′(x′) at every input, one question anywhere identifies the human; N1 is a statement about classes that contain, with P, a member that agrees with P on the asked set and differs at x. (b) *γ matters and the bound 1 − γ is attained.* A protocol that asks x with probability γ and otherwise answers f(x) fails with probability 0 under f and 1 − γ under f′. (c) Nothing is assumed about how questions are chosen or about the deployed system; in particular a history-dependent deployed answerer inside a scaffold is covered by parts 1–3, because its whole run has the same law under P and P′ up to γ.

### 1.3 The patch-family lemma

This lemma is the common core of N2, N3 and N5 for functions.

**Lemma 1.10 (patch family).** Let Π be a scaffold, f₀ ∈ H a function, B_1, …, B_N disjoint subsets of X, and f_1, …, f_N ∈ H functions with f_i = f₀ on X ∖ B_i. Put o_i := out_{f_i}(z, ρ), Δ_i := Pr[o_i ≠ o₀], and let M be a number with #{i ≥ 1 : o_i ≠ o₀} ≤ M for all (z, ρ). Let Λ be a protocol and g a deployed system, S(r) the set of questions that Λ asks on seed r when all answers are given by f₀, π_i := Pr[S(r) ∩ B_i ≠ ∅], and n := E_{f₀}[N_Λ]. Then Σ_i π_i ≤ n, and
1. Fail(f₀) + Fail(f_i) ≥ (1 − π_i)·Δ_i for every i;
2. (M/(N+M))·Fail(f₀) + (1/(N+M))·Σ_{i≥1} Fail(f_i) ≥ (1/(N+M))·Σ_i (1 − π_i)Δ_i ≥ (N − n)·min_i Δ_i/(N + M).
The left side of (2) is an average over the class, so max_i Fail(f_i) is at least the right side.

*Proof.* The sets B_i are disjoint, so the number of i with S(r) ∩ B_i ≠ ∅ is at most |S(r)| ≤ N_Λ on the f₀-path; taking expectations, Σ_i π_i ≤ n. Fix r and let D⁰(r) be the transcript when f₀ answers. If S(r) ∩ B_i = ∅, then by induction over the steps the interaction with f_i asks the same questions and receives the same answers (each asked input lies outside B_i, where f_i = f₀), so its transcript is D⁰(r) and the deployed outcome is g₀ := g(r, D⁰(r), z, ρ, s) under both f₀ and f_i. Write hit(r) := {i : S(r) ∩ B_i ≠ ∅}. Then Fail(f₀) = Pr[g₀ ≠ o₀] and, for i ≥ 1, Fail(f_i) ≥ Pr[i ∉ hit(r), g₀ ≠ o_i] ≥ Pr[i ∉ hit(r), o_i ≠ o₀, g₀ = o₀]. (1) On the event {i ∉ hit(r), o_i ≠ o₀}, g₀ differs from o₀ or from o_i; the event has probability (1 − π_i)Δ_i because r is independent of (z, ρ). (2) With V := #{i ∉ hit(r) : o_i ≠ o₀} ≤ M, the left side is at least
E[ (M/(N+M))·1[g₀ ≠ o₀] + (V/(N+M))·1[g₀ = o₀] ] ≥ E min{M, V}/(N+M) = E[V]/(N+M),
and E[V] = Σ_i (1 − π_i)Δ_i ≥ (N − Σ_i π_i)·min_i Δ_i. ∎

## 2. Critical steps are not amplified (N2)

### 2.1 The needle class

**Definition 2.0.** Let N₀, L ≥ 1 be integers, X := [N₀], Y := {0, 1}. The *needle class* is 𝒩(N₀) := {f₀, f_1, …, f_{N₀}} with f₀ ≡ 0 and f_i(x) := 1[x = i]. The *OR scaffold* Π_{L,N₀} has z = (x_1, …, x_L) independent and uniform on [N₀], no internal randomness, next_j := x_j, and out := max_j y_j. Write set(z) for the set of distinct cells among x_1, …, x_L and

  p := p(L, N₀) := 1 − (1 − 1/N₀)^L = Pr[i ∈ set(z)]  for each cell i;  (L/N₀)(1 − L/(2N₀)) ≤ p ≤ L/N₀

(the lower bound is 1 − (1 − a)^L ≥ La − (L(L−1)/2)a²). Under f₀ the outcome is 0 and every call is critical: one changed answer changes the outcome. With uniform weights every member has K = log(N₀ + 1); in the universal class K(f_i) ≤ log N₀ + 2 log log N₀ + c.

**Theorem 2.1 (N2, exact form).** Let Λ be any protocol (adaptive, randomised), g any deployed system (in particular any deployed answerer, history-dependent, randomised, abstaining), and n := E_{f₀}[N_Λ] the expected number of questions when the human is f₀. Then

  (L/(N₀+L))·Fail(f₀) + (1/(N₀+L))·Σ_{i=1}^{N₀} Fail(f_i) ≥ (N₀ − n)·p/(N₀ + L).

Hence some member of 𝒩(N₀) has failure probability, and probability of an unfaithful run, at least (N₀ − n)p/(N₀ + L).

*Proof.* Lemma 1.10 with B_i := {i}, o₀ = 0, o_i = 1[i ∈ set(z)], Δ_i = p and M := L (at most L cells are visited). ∎

**Corollary 2.2 (constants).** Suppose Fail(f) ≤ δ for every f ∈ 𝒩(N₀). Then n ≥ N₀ − δ(N₀ + L)/p. In particular:
1. if N₀ = L/(2δ) is an integer, n ≥ L/(4δ) − L;
2. for every δ ∈ (0, 1/6] and N₀ := ⌈L/(2δ)⌉, n ≥ L/(4δ) − 3L/2;
3. for the parameters of the candidate theory (N₀ = L/ε, δ = ε/4), n ≥ (3/4)·((1 − ε)/(1 − ε/2))·L/ε ≥ (3/4)(1 − ε)·L/ε.
In (1) and (2) every member has K ≤ log(L/(2δ) + 2) with uniform weights.

*Proof.* The first claim is Theorem 2.1 rearranged. (1) p ≥ 2δ(1 − δ) and N₀ + L = N₀(1 + 2δ), so δ(N₀+L)/p ≤ N₀(1 + 2δ)/(2(1 − δ)) and n ≥ N₀(1 − 4δ)/(2(1 − δ)); for δ ≤ 1/4 this is at least N₀(1 − 4δ)/2 = L/(4δ) − L, and for δ > 1/4 the claim is trivial. (2) Now L/(2δ) ≤ N₀ < L/(2δ) + 1, so p ≥ (L/N₀)(1 − δ) and δ(N₀+L)/L < 1/2 + δ/L + δ ≤ 1/2 + 2δ; hence n ≥ N₀[1 − (1/2 + 2δ)/(1 − δ)] = N₀(1/2 − 3δ)/(1 − δ) ≥ N₀(1/2 − 3δ) ≥ L/(4δ) − 3L/2. (3) p ≥ ε(1 − ε/2), so δ(N₀+L)/(N₀p) ≤ (1 + ε)/(4 − 2ε) and n ≥ N₀(3 − 3ε)/(4 − 2ε). ∎

The candidate theory states the bound (ε/2)(1 − nε/L)(1 − o(1)) and the consequence n ≥ L/(2ε). Theorem 2.1 with N₀ = L/ε gives the larger bound ε(1 − ε/2)(1 − nε/L)/(1 + ε) (the prior is chosen better), and the free choice of N₀ gives n ≥ (1 − ε)L/ε for failure ε/4 (item 1 with δ = ε/4).

**Proposition 2.3 (tightness).** For every integer 0 ≤ n ≤ N₀ there is a non-adaptive protocol with exactly n questions, deploying a function, with Fail(f₀) = 0 and Fail(f_i) = (1 − n/N₀)·p for i ≥ 1. So the minimax failure v(n) over protocols with at most n questions satisfies

  (N₀ − n)p/(N₀ + L) ≤ v(n) ≤ (N₀ − n)p/N₀,

and for N₀ = L/(2δ) the least number n*(δ) of questions with which failure ≤ δ is possible for all members satisfies L/(4δ) − L ≤ n*(δ) ≤ ⌈L/(4δ)⌉.

*Proof.* Ask the cells of a uniformly random n-subset S. If an answer is 1 the human is identified and is deployed. Otherwise deploy f₀. Under f₀ there is no failure; under f_i the deployed run fails iff i ∉ S and i ∈ set(z), which are independent events. For the last claim, n ≥ N₀(1 − δ/p) suffices, and δ/p ≥ δN₀/L = 1/2. ∎

**Remark 2.4 (what the hypotheses do).**
1. *Order of events.* The questions are asked before z is drawn. If the human can be asked after z is known, L questions give failure 0; Proposition 2.5 shows that nearly L are then still needed.
2. *Closure under patches.* The class must contain, with f₀, its one-cell patches. For a class of two functions that differ everywhere one question suffices.
3. *Many distinct inputs.* The bound is at most N₀: a scaffold that can only produce N₀ inputs is learned exactly with N₀ questions.
4. *Worst case over the class.* The left side of Theorem 2.1 is the Bayes risk for the prior with weights L/(N₀+L) on f₀ and 1/(N₀+L) on each needle. A guarantee on average over a prior that favours f₀ is cheap. The bound is not about complexity: every member has K ≈ log(L/δ) bits. It is about search: an answer 0 excludes one cell.
5. *Abstention.* A silent outcome counts as a failure. If only silent errors counted, the system that always abstains would have none (Corollary 1.7).
6. *Comparison.* For this class the bound of Protocol R is L·K ln 2/δ questions for failure δ (candidate R2; Lemma 5.1′ below), with K = log(L/(2δ) + 1): the ratio to L/(4δ) − L is about 4 ln 2·K.

### 2.2 The human in the loop during the run

**Proposition 2.5.** Consider protocols that first see z, then ask the human questions adaptively, and then output ô; let n := E_{f₀}[N_Λ]. For the needle class and the OR scaffold,

  (L/(N₀+L))·Fail(f₀) + (1/(N₀+L))·Σ_i Fail(f_i) ≥ (N₀·p − n)/(N₀ + L).

Hence failure ≤ δ for all members requires n ≥ N₀p − δ(N₀ + L), and with N₀ := ⌈L/√(2δ)⌉:

  n ≥ L·(1 − √(2δ) − δ) − δ.

Asking every call of the run (L questions) gives failure 0, so this is tight up to the factor 1 − √(2δ) − δ.

*Proof.* Fix (r, z) and let S(r, z) be the set of cells asked when all answers are 0. If i ∉ S(r, z), the transcript under f_i is the all-zero transcript, so the output is the same g₀(r, z, s) as under f₀. With V := |set(z) ∖ S(r, z)| ≤ L, the left side is at least E[(L/(N₀+L))·1[g₀ ≠ 0] + (V/(N₀+L))·1[g₀ = 0]] ≥ E[V]/(N₀+L), and E[V] ≥ E|set(z)| − E|S(r, z)| ≥ N₀p − n. For the last display, N₀p ≥ L − L²/(2N₀) ≥ L − L√(2δ)/2 and δN₀ ≤ L√(2δ)/2 + δ. ∎

So a run of L critical calls costs about L human answers whatever is done; imitation prepared in advance costs about 1/(4δ) times more (Corollary 2.2). Section 7 states this as one theorem.

## 3. The dependence on K

Section 2 gives L/(4δ) for a class with K ≈ log(L/δ). This section shows that the number of questions grows linearly in K for fixed L/δ (Theorem 3.1), and that the growth is K·L/(δ·log(L/δ)), not K·L/δ (Theorem 3.3).

### 3.1 Lower bound: many needles

**Definition 3.0.** Let m, N, L ≥ 1, X := [m] × [N], Y := {0, 1}. For a ∈ [N]^m let f_a(j, i) := 1[a_j = i]: block j contains exactly one needle, at cell a_j. The *block class* is 𝒩^m(N) := {f_a : a ∈ [N]^m}; it has 2^K members with K := m·log N, which is the complexity of every member under uniform weights. The *block scaffold* Π^m_{L,N} has z = (J, u_1, …, u_L) with J uniform on [m] and u_1, …, u_L independent and uniform on [N], no internal randomness, next_l := (J, u_l), out := max_l y_l. Write set(z) := {u_1, …, u_L} and p := p(L, N) as in Definition 2.0.

**Theorem 3.1 (the factor K).** Let Λ be any protocol, g any deployed system, and n the expected number of questions of Λ when a is uniform on [N]^m (n is at most the worst-case number of questions). Then

  N^(−m)·Σ_a Fail(f_a) ≥ p·(1 − 2L/N − 2n/(mN)).

Consequently, if Fail(f_a) ≤ δ for all a, then n ≥ (mN/2)·(1 − 2L/N − δ/p); and if N = L/(2δ) is an integer,

  n ≥ (1 − 10δ)·m·L/(8δ) = (1 − 10δ)·K·L/(8δ·log(L/(2δ))).

*Proof.* Let a be uniform on [N]^m and independent of (r, z, s). Fix a block j, a seed r and the coordinates a_{−j} of a other than j. The *j-silent interaction* is the interaction of Λ on seed r in which inputs of the other blocks are answered according to a_{−j} and every input of block j is answered 0. Let c_1, …, c_k be the distinct cells of block j that it asks, in the order of first appearance, S := {c_1, …, c_k}, k = k_j(r, a_{−j}) ≤ N, κ_j := k/N ∈ [0, 1].

*Step 1 (questions).* Let N_j be the number of questions put to inputs of block j in the real interaction. If a_j = c_i, the real interaction coincides with the j-silent one until c_i is asked for the first time, and by then c_1, …, c_i have been asked: N_j ≥ i. If a_j ∉ S the real interaction is the j-silent one: N_j ≥ k. Since a_j is uniform and independent of (r, a_{−j}),

  E[N_j | r, a_{−j}] ≥ (1/N)·(Σ_{i=1}^{k} i + (N − k)·k) = k − k(k − 1)/(2N) ≥ N·(κ_j − κ_j²/2) ≥ N·κ_j/2.

Summing over j and taking expectations, Σ_j E[κ_j] ≤ (2/N)·Σ_j E[N_j] ≤ 2n/N.  (∗)

*Step 2 (failure).* Condition on J = j, r and a_{−j}. For every value a_j = i ∉ S the transcript is the j-silent transcript, so the outcome ô = g₀(z, s) does not depend on i, while the right outcome is 1[i ∈ set(z)]. For fixed (z, s) the number of i ∈ [N] ∖ S with g₀ ≠ 1[i ∈ set(z)] is |set(z) ∖ S| if g₀ = 0, N − k − |set(z) ∖ S| if g₀ = 1, and N − k otherwise. If N − k ≥ 2L, then |set(z) ∖ S| ≤ L ≤ N − k − L, so this number is at least |set(z) ∖ S|. As z is independent of (r, a) and each cell of block j lies in set(z) with probability p,

  Pr[failure | J = j, r, a_{−j}] ≥ (1/N)·(N − k)·p·1[N − k ≥ 2L] = p·(1 − κ_j)·1[1 − κ_j ≥ 2L/N] ≥ p·(1 − κ_j − 2L/N).

*Step 3.* Averaging over J (uniform on [m]), r and a, and using (∗): the average failure is at least p·(1 − 2L/N − (1/m)Σ_j E[κ_j]) ≥ p·(1 − 2L/N − 2n/(mN)).

*Step 4 (numbers).* If all failures are ≤ δ the average is ≤ δ, which gives the bound on n. For N = L/(2δ): 2L/N = 4δ, p ≥ 2δ(1 − δ), δ/p ≤ 1/(2(1 − δ)) ≤ 1/2 + δ, so n ≥ (mN/2)(1/2 − 5δ) = (mL/(8δ))(1 − 10δ). ∎

**Proposition 3.2 (tightness).** Let N = L/(2δ). The following protocol has Fail(f_a) ≤ δ for every a, asks at most ⌈m/2⌉(N − 1) questions, and asks at most ⌈m/2⌉·(L/(4δ) + 1/2) in expectation when a is uniform: choose ⌈m/2⌉ blocks uniformly at random; in each, ask the cells 1, 2, …, N − 1 in turn until an answer is 1 (if there is none the needle is at N); deploy the function that equals f_a on the chosen blocks and 0 elsewhere.

*Proof.* A run fails iff its block was not chosen and the needle of that block is in set(z): probability (1 − ⌈m/2⌉/m)·p ≤ p/2 ≤ L/(2N) = δ. The number of questions in a chosen block is min(a_j, N − 1), with mean (N − 1)(N + 2)/(2N) ≤ (N + 1)/2 for uniform a_j. ∎

So Theorem 3.1 is sharp up to the factor (1 + O(δ))(1 + 1/m) in the expected number of questions. Scanning half of the blocks completely is better than scanning all blocks half-way: the search for one needle is all or nothing.

### 3.2 Upper bound: plurality answers and targeted questions

**Theorem 3.3 (Protocol AB).** Let H be a countable class of total functions X → Y with weights w, f ∈ H the human, K := log(1/w(f)), Π any scaffold of horizon L, and X₀ ⊆ X a set that contains every input Π can produce (X₀ = X is allowed). Let γ ∈ (0, 1/2) and n_B ≥ 1. Write V_t for the set of members consistent with the answers received before step t, W_t := w(V_t), and M_t(y|x) := w({g ∈ V_t : g(x) = y})/W_t.

*Protocol AB(γ, n_B).* At step t:
* **(A)** if some x ∈ X₀ has max_y M_t(y|x) ≤ 1 − γ, ask the human the first such x in a fixed enumeration of X₀;
* **(B)** otherwise every x ∈ X₀ has a unique answer h_t(x) with M_t(h_t(x)|x) > 1 − γ. Draw (z, ρ), run Π with h_t answering every call (this uses compute only), draw J uniformly from [L], and if the run made at least J calls ask the human the input of call J.

Stop when n_B steps of type (B) have been made. *Deployment:* draw I uniformly from [n_B] and let the function h := h_t of the I-th step of type (B) answer every call, in this and all later runs.

Then:
1. Let a be the number of steps of type (A) and b the number of steps of type (B) at which the human's answer differed from h_t. Always a·ln(1/(1 − γ)) + b·ln(1/γ) ≤ K ln 2. Hence a ≤ K ln 2/γ, b ≤ K/log(1/γ), and the number of questions is at most n_B + K ln 2/γ.
2. Pr[the deployed run differs from run_f(z, ρ)] ≤ L·K/(n_B·log(1/γ)).
3. Let ε ∈ (0, 1) with L/ε ≥ 16, u := log(L/ε), γ := u·ε/L and n_B := ⌈L·K/(ε·(u − log u))⌉. Then the deployed run is faithful with probability ≥ 1 − ε, and the number of questions is at most

  1 + (u/(u − log u) + ln 2)·K·L/(ε·u) ≤ 1 + 2.7·K·L/(ε·log(L/ε)).

*Proof.* (1) A question x answered f(x) multiplies W by M_t(f(x)|x) ≤ 1. At a step of type (A) the factor is at most max_y M_t(y|x) ≤ 1 − γ. At a step of type (B) with f(x) ≠ h_t(x) the factor is at most 1 − M_t(h_t(x)|x) < γ. Since W_1 ≤ 1 and W_t ≥ w(f) for all t, (1 − γ)^a·γ^b ≥ w(f). Use ln(1/(1 − γ)) ≥ γ.

(2) At a step t of type (B) let u_t be the probability, over (z, ρ) and given the data so far, that the run of h_t differs from run_f(z, ρ). If the two runs differ, let j* be the first call of the h_t-run at whose input h_t and f differ; it exists, because otherwise both runs make the same calls with the same answers, by induction over the calls; and the inputs of calls 1, …, j* are the same in both runs. With probability 1/L, independently of the run, J = j*, and then the human is asked an input at which f and h_t differ. So the conditional probability of a disagreement at step t is at least u_t/L. Whether step t is one of the first n_B steps of type (B) is determined by the data before step t; summing over these steps, E Σ u_t ≤ L·E[b] ≤ L·K/log(1/γ). The deployed h is that of a uniformly chosen one of these n_B steps, and (z, ρ) at deployment has the same law as in rehearsal, so the probability in (2) is (1/n_B)·E Σ u_t.

(3) u ≥ 4 gives γ = u·2^(−u) ≤ 1/4 and log(1/γ) = u − log u ≥ u/2. By (2) the failure is at most ε; by (1) the number of questions is at most n_B + K ln 2·L/(u·ε) ≤ 1 + (K·L/(ε·u))·(u/(u − log u) + ln 2), and u/(u − log u) ≤ 2. ∎

**Remarks on Theorem 3.3.**
1. *What is new compared with Protocol R.* Steps of type (B) are rehearsal with one audited call, driven by the plurality function instead of the mixture. A disagreement then removes all but a fraction γ of the posterior mass, that is log(1/γ) ≈ log(L/ε) bits, where a disagreement of the mixture removes about one bit on average. Steps of type (A) ask inputs chosen by the protocol, where the posterior is split; they are needed so that the plurality function exists and is nearly unanimous. These inputs lie in X₀ but need not be typical for the scaffold.
2. *The deployed object* is one deterministic function per run and for all runs (in general not a member of H: it is the pointwise plurality vote of the surviving members).
3. *K must be known* to choose n_B as in (3). Claims (1) and (2) hold for every n_B.
4. *Compute.* Step (A) searches X₀ for an input with a split posterior. For finite classes and finite X₀ this is a finite computation. For the universal class the posterior is not computable, as everywhere in the candidate theory.
5. *Functions only.* The proof uses that one answer refutes a hypothesis. For stochastic humans the rate L·K/ε² of the candidate's R2 has no logarithm to save (Theorem 6.3).

**Corollary 3.4 (the right dependence on the complexity of the class).**
1. *Upper bound in bits.* For every class of functions with weights, every member f, every scaffold with L calls and every ε with L/ε ≥ 16, 1 + 2.7·K·L/(ε·log(L/ε)) questions suffice for a deployed run that is faithful with probability ≥ 1 − ε (K = log(1/w(f)) must be known).
2. *Lower bound.* For all m ≥ 1, L ≥ 1 and δ ≤ 1/20 with N := L/(2δ) an integer, the block class 𝒩^m(N) with the block scaffold needs at least (1 − 10δ)·m·L/(8δ) questions, in expectation over a uniform member, to make the deployed outcome right with probability ≥ 1 − δ for every member. The class has 2^K members with K = m·log(L/(2δ)) and VC dimension d = m (for N ≥ 2: the m inputs (j, 1), j ∈ [m], are shattered, and of two inputs in one block at most one is answered 1).
3. *In terms of the VC dimension d* the statement asked for holds with c = (1 − 10δ)/8: there are classes of VC dimension d and scaffolds with L calls for which every protocol, however it chooses its questions, needs at least c·d·L/δ questions. This is the bound d/ε′ of passive learning at ε′ = δ/L; for this class 1 + 2.7·d·L/δ questions suffice by (1), since K ≤ d·log(L/δ).
4. *In terms of description length* (the K = log(1/w(f)) of the candidate theory) the statement "for some absolute c > 0 there are classes of functions of complexity K and scaffolds with L calls for which every protocol needs c·K·L/ε questions" is **false**: by (1) it fails as soon as log(L/ε) > 2.7/c (and K·L/ε is large enough to absorb the additive 1). The worst case over classes of weight-complexity K ≥ log(L/(2δ)) is of order K·L/(δ·log(L/δ)), with constants 1/8 from below (2) and 2.7 from above (1).
5. *For the candidate theory:* the sentence "this is optimal up to the factor K" (Section 0, item 2) can be sharpened. Protocol R's bound L·K ln 2/δ is optimal up to the factor 8 ln 2·log(L/(2δ))/(1 − 10δ) for the block classes, and it is not optimal: Protocol AB removes the logarithm up to a constant.

**Remark 3.5 (small K).** If K < log(L/(2δ)), a class with at most 2^K members is identified on X₀ with at most 2^K − 1 questions (ask an input at which two surviving members differ; each answer refutes at least one). The needle class with N₀ = 2^K − 1 cells needs n ≥ N₀ − δ(N₀ + L)/p(L, N₀) questions (Corollary 2.2); this is at least N₀ − 3.2·δ·L when N₀ ≤ L (then p ≥ 1 − 1/e), and at least N₀/2 when L ≤ N₀ ≤ L/(8δ) (then p ≥ L/(2N₀)). So for such K the worst case is of order 2^K, apart from the range 2^K = O(δL), and for larger K it is of order K·L/(δ·log(L/δ)) (Corollary 3.4).

**Remark 3.6 (relation to the literature).** The standard lower bound for learning a class of VC dimension d from random examples to error ε′ is of order d/ε′ (Ehrenfeucht, Haussler, Kearns and Valiant 1989). Its proof does not apply here: its hard instance (a shattered set of d inputs, most of them rare) is learned with d well-chosen questions when the learner may choose its questions. What makes questions expensive for every protocol is search: in the block class the d shattered inputs are hidden among d·N cells. A search over N cells yields log N bits, which is why the bound in bits carries K/log(L/δ) and not K. The saving of a logarithm by chosen questions is known for exact learning with membership queries (Hegedűs 1995). See Section 11 for the citations and for what I checked.

## 4. Shift outside the closed system (N3 and S2)

### 4.1 N3: each alternative shift must be paid for

**Theorem 4.1 (N3, exact form).** Let Q_1, …, Q_N ⊆ X be disjoint and nonempty, D_i a probability law on X with D_i(Q_i) = 1, and 𝒮 := {f₀, f_1, …, f_N} with f₀ ≡ 0 and f_i := 1_{Q_i}. Under *shift i* the task is one call at x ~ D_i. For a protocol Λ with a deployed system let s_i(f) := Pr_f[the deployed answer at x ~ D_i equals f(x)], π_i := Pr[Λ asks an input of Q_i when the human is f₀], and n := E_{f₀}[N_Λ].
1. s_i(f₀) + s_i(f_i) ≤ 1 + π_i for every i, and Σ_i π_i ≤ n. Hence Σ_i (s_i(f₀) + s_i(f_i) − 1) ≤ n: the advantages over 1/2 are paid from a budget of n.
2. If s_i(f) ≥ 1/2 + η for all i and all f ∈ 𝒮, then n ≥ 2ηN. In particular success probability ≥ 1 − δ under every shift needs n ≥ (1 − 2δ)·N.
3. For every integer 0 ≤ n ≤ N there is a protocol with n questions and s_i(f) ≥ 1/2 + n/(2N) for all i and all f ∈ 𝒮. So the best uniform advantage with n questions is exactly n/(2N).
4. For a *deterministic* protocol π_i ∈ {0, 1}, so s_i(f) > 1/2 for all i and f forces a question in every Q_i and n ≥ N: this is N3 as stated in the candidate theory. For *randomised* protocols N3 as stated is false: by (3) one question gives success probability ≥ 1/2 + 1/(2N) > 1/2 for every member under every shift. The correct statement is (2).

*Proof.* (1) Apply Lemma 1.10(1) to the scaffold "one call at x ~ D_i, outcome = answer" with the single patch B := Q_i: f_i ≠ f₀ at D_i-almost every x, so Δ = 1 and Fail(f₀) + Fail(f_i) ≥ 1 − π_i. The Q_i are disjoint, so Σ_i π_i ≤ n as in Lemma 1.10. (2) follows from (1). (3) Fix a point q_i ∈ Q_i for each i. Draw a uniformly random n-subset I of [N] and ask q_i for i ∈ I. If an answer is 1, say at q_j, the human is f_j; deploy it. Otherwise the human is f₀ or f_j with j ∉ I; deploy the rule that answers 0 on Q_i for i ∈ I and outside ∪Q_i, and a fair coin on Q_i for i ∉ I. Under shift i, for f₀ and for f_i the answer is right with probability Pr[i ∈ I] + (1/2)·Pr[i ∉ I] = 1/2 + n/(2N). For f_j with j ≠ i it is right if j ∈ I or i ∈ I, and with probability 1/2 otherwise; Pr[i ∈ I or j ∈ I] ≥ n/N. (4) is immediate. ∎

The value n/(2N) of (3) was confirmed as the exact optimum by linear programming for N ≤ 5 (Section 8).

**Corollary 4.2 (description length).** Let X = {0, 1}* and k ≥ 1. The 2^k sets Q_i := {x : x begins with i}, i ∈ {0,1}^k, are disjoint and decidable with K(Q_i) ≤ k + K(k) + c ≤ k + 2 log k + c′; the indicators f_i and the laws D_i := uniform on Q_i ∩ {0,1}^(2k) have complexity at most k + 2 log k + c″. By Theorem 4.1, being right with probability ≥ 1/2 + η under each of these 2^k shifts, for the zero function and each f_i, needs n ≥ 2η·2^k questions.

*Remark on the constant.* The candidate theory writes "complexity ≤ k + c". This holds for the complexity conditional on k. For prefix complexity I can only prove k + K(k) + c for all 2^k regions; the number of objects of prefix complexity at most j is 2^(j − K(j) + O(1)) [from memory: a counting theorem of Chaitin, see Section 11], so the term K(k) cannot be dropped for a family of 2^k sets in general (it can for those k that are themselves simple). This changes "2^k" to "2^k up to a factor polynomial in k" and nothing else.

**Theorem 4.3 (N shifts and L critical calls).** Let X := [N] × [N₀], let the class consist of f₀ ≡ 0 and the N·N₀ point indicators f_{i,c} := 1[· = (i, c)], and let shift i be the OR scaffold with L calls that are independent and uniform on {i} × [N₀]. If under every shift every member has failure ≤ δ, then

  n := E_{f₀}[N_Λ] ≥ N·(N₀ − δ(N₀ + L)/p(L, N₀)),  and for N₀ = ⌈L/(2δ)⌉, δ ≤ 1/6:  n ≥ N·(L/(4δ) − 3L/2).

Every member has K = log(N·N₀ + 1) with uniform weights.

*Proof.* For each i apply Lemma 1.10(2) to the scaffold of shift i with the patches B_c := {(i, c)}, c ∈ [N₀]: with n_i the expected number of questions in {i} × [N₀] on the f₀-path, Σ_c π_{i,c} ≤ n_i and some member fails with probability ≥ (N₀ − n_i)p/(N₀ + L). So n_i ≥ N₀ − δ(N₀+L)/p for every i, and Σ_i n_i ≤ n. The numbers are those of Corollary 2.2(2). ∎

### 4.2 S2: the matching upper bound, and what "samplable" has to mean

**Proposition 4.4 (S2).**

(a) *Domination.* Let (D_i)_{i ∈ I} be a countable family of laws of the top-level input z, π_i > 0 with Σ_i π_i ≤ 1, and ξ := Σ_i π_i D_i/Σ_i π_i. For every measurable Φ ≥ 0 and every i,

  E_{z~D_i} Φ(z) ≤ E_{z~ξ} Φ(z)/π_i.

Consequently, if a protocol is run with top-level inputs z ~ ξ in rehearsal and its guarantee has the form E_{z~ξ} Φ(z) ≤ β for one of the functionals Φ(z) := E[number of unfaithful calls of the deployed run | z], Pr[deployed run unfaithful | z], Pr[failure | z], then under deployment with z ~ D_i the same quantity is at most β/π_i. With the candidate's R2 for a function: Pr[deployed run unfaithful under D_i] ≤ L·K ln 2/(π_i·n).

(b) *When this is a protocol.* Rehearsal has to draw z ~ ξ. This is possible by an almost surely halting randomised procedure if the family is *uniformly samplable*: i ↦ (a probabilistic program that halts with probability one and outputs z ~ D_i) is computable, and the index i can be drawn with probabilities proportional to π_i by a halting procedure (for example π_i = 2^(−ℓ(i)) for the code lengths ℓ of a complete prefix code). Examples: a finite list of task laws; all laws sampled by programs p of a fixed machine within a fixed computable time bound, with the index p drawn by choosing its length ℓ with probability 2^(−ℓ−1) and then ℓ fair bits, which gives π_p = 2^(−2|p|−1) and B ≤ 2^(2|p|+1) for a law with such a program p.

(c) *What is not possible.* Let 𝒟 be the set of all laws on Z = {0,1}* that are sampled by a probabilistic program that halts with probability one. For every ξ ∈ 𝒟 there is D ∈ 𝒟 with sup_z D(z)/ξ(z) = ∞. Hence no almost surely halting rehearsal sampler has a finite factor B for every samplable task law. The universal mixture does: with ξ_U(z) := Σ_p 2^(−|p|)·Pr[U(p) outputs z] over all programs p of a universal prefix machine with access to coins, the normalised law ξ̄_U := ξ_U/ξ_U(Z) satisfies D ≤ 2^(K(D))·ξ̄_U for every D ∈ 𝒟, where K(D) is the length of a shortest program sampling D. ξ̄_U is not in 𝒟; it is computable relative to the halting problem and can therefore be sampled exactly by a procedure with an oracle for the halting problem.

(d) *Optimality.* For N disjointly supported task laws and π_i = 1/N, (a) costs a factor N, and Theorem 4.3 shows that a factor N is necessary: N·(L/(4δ) − 3L/2) questions against N·L·K ln 2/δ.

*Proof.* (a) Σ_i π_i ≤ 1 gives ξ ≥ π_i·D_i pointwise; integrate Φ ≥ 0. (b) Draw i, then run the sampler of D_i. (c) Let ξ ∈ 𝒟. Then ξ(z), the probability that the sampler halts with output z, is lower semicomputable, and because Σ_z ξ(z) = 1 it is also upper semicomputable (ξ(z) = 1 − Σ_{z′≠z} ξ(z′)); so ξ is computable. Define z_1, z_2, … recursively: z_j is the first string found, by a dovetailed search through all strings and all upper approximations of ξ, that differs from z_1, …, z_{j−1} and has ξ(z_j) < 4^(−j). The search halts because all but finitely many strings have ξ(z) < 4^(−j). Let D(z_j) := 2^(−j). D is sampled by drawing j with probability 2^(−j) and computing z_j, so D ∈ 𝒟, and D(z_j)/ξ(z_j) > 2^j. For the universal mixture: if p samples D then ξ_U ≥ 2^(−|p|)·D and ξ̄_U ≥ ξ_U. ξ̄_U ∉ 𝒟 by the first part. Each ξ_U(z) and the normaliser are limits of computable nondecreasing sequences of rationals, hence computable to any precision with an oracle for the halting problem; a law that is computable relative to an oracle is sampled exactly, with fair coins and that oracle, by comparing a uniform random real with the cumulative sums to increasing precision, which halts with probability one. (d) is Theorem 4.3 and (a) with R2. ∎

**What S2 should say.** "Samplable" must be read as *uniformly samplable family with a samplable prior on indices* (for example a time bound on the samplers). Then B_i ≤ 1/π_i exactly (the candidate's constant c is 0 when π_i is the weight used in the mixture). For the family of all samplable laws with weights 2^(−K(i)) the statement is true as an inequality, but the protocol needs an oracle for the halting problem to draw its rehearsal inputs: unlimited ordinary compute is not enough. Second, S1 and S2 are cleanest at the level of the top-level law, as in (a): the per-call visit measure at deployment depends on the imitator, the top-level law does not.

**Remark 4.5 (abstention under a shift).** Let the deployed system be allowed to abstain, and count only silent errors. For shift i, the members f₀ and f_i agree outside Q_i, so in Lemma 1.5 γ = π_i. The proof of Corollary 1.7, applied to the pair (x, answer) with x ~ D_i, gives: the silent-error probabilities of f₀ and f_i under shift i sum to at least 1 − π_i − a_i, where a_i is the smaller of the two abstention probabilities under shift i. So a system whose silent-error probability is at most σ for both members abstains with probability at least 1 − π_i − 2σ under shift i: on every shift that was not paid for it abstains almost always.

## 5. Fault tolerance (N5)

### 5.1 Definitions and the upper bound

**Definition 5.1.** Let f be a function, Π a scaffold and G a set of runs. A *replacement rule with at most m replacements* sees, at each call, (z, ρ), the history of the run and the human's answer f(x_j), and may replace the answer by any element of Y ∪ {⊥}; it replaces at most m answers in a run. (The candidate's rule sees only the history and the answer; giving it (z, ρ) makes tolerance a stronger property, so the lower bound below is stronger. In the upper bound only rules of the candidate's kind are used.) The human system of f *tolerates m faults with failure δ₀* (for G) if for every such rule, deterministic or randomised with coins independent of (z, ρ), the run is in G with probability ≥ 1 − δ₀. In the lower bounds G is G_f := {the outcome equals out_f(z, ρ)}, so that "the deployed run is not in G_f" is the event Fail of Definition 1.4.
The *robustness curve* of (Π, f, G) is

  δ_Π(β) := sup{ Q_C(not G) : C a sampler with E_{Q_C} Σ_j (1 − C(f(x_j)|x_j)) ≤ β },  0 ≤ β ≤ L;

1 − C(f(x)|x) is the total variation between C(·|x) and the answer f(x), so this is the curve of the candidate's R3 for a function. δ_Π is nondecreasing and bounded by 1; let δ̄_Π be its least concave majorant on [0, L], which is again nondecreasing.

**Lemma 5.1′ (the candidate's R1 for a function; proof reproduced for completeness).** In Protocol R (candidate theory, Section 3) with a function f ∈ H as the human, let β_t := E_{Q_{M^(t)}} Σ_j (1 − M^(t)(f(x_j)|x_j)) be the expected number of calls of a run driven by the round-t mixture at which its draw differs from f, given the data before round t. Then Σ_{t=1}^{n} E[β_t] ≤ L·K ln 2, so E[β_T] ≤ L·K ln 2/n for T uniform on [n].

*Proof.* Let W_t be the prior mass of the hypotheses weighted by the likelihood of the answers before round t: W_1 ≤ 1, W_{t+1} = W_t·M^(t)(f(x)|x) if x is asked in round t and W_{t+1} = W_t otherwise, and W_{n+1} ≥ w(f). Hence the sum over the asked inputs of −ln M^(t)(f(x)|x) is at most ln(1/w(f)) = K ln 2 on every path, and 1 − M ≤ −ln M. In round t the asked input is that of call J of the rehearsal run when the run has at least J calls, with J uniform on [L] and independent of the run; so the conditional expectation of 1 − M^(t)(f(x_J)|x_J) on that event, given the past, is β_t/L. ∎

**Proposition 5.2 (upper bound through the robustness curve).** Let f ∈ H be a function and G any set of runs. After Protocol R with n rounds, the run deployed with M^(T), T uniform on [n], satisfies

  Pr[deployed run ∉ G] ≤ δ̄_Π(L·K ln 2/n).

If the human system tolerates m faults with failure δ₀, then δ_Π(β) ≤ δ₀ + β/(m + 1) for all β, and therefore Pr[deployed run ∉ G] ≤ δ₀ + L·K ln 2/((m + 1)·n). This is the candidate's R3 for a function.

*Proof.* Given T and the data, the deployed imitator C := M^(T) is a sampler with E_{Q_C} Σ_j (1 − C(f(x_j)|x_j)) = β_T ≤ L. So Q_C(not G) ≤ δ_Π(β_T) ≤ δ̄_Π(β_T), and by Jensen's inequality, monotonicity and Lemma 5.1′, E δ̄_Π(β_T) ≤ δ̄_Π(E β_T) ≤ δ̄_Π(L·K ln 2/n).
For the second claim let C be a sampler with expected number of faults at most β, where a call of a run of C is a *fault* if the draw y_j ~ C(·|x_j) differs from f(x_j). A run of C is a run of f under the randomised replacement rule "draw y_j ~ C(·|x_j) and replace f(x_j) by it if it differs". Let the truncated rule do the same until it has made m replacements and then replace nothing. It makes at most m replacements, so its run is in G with probability ≥ 1 − δ₀. With the same coins the two runs coincide unless the run of C has at least m + 1 faults, which has probability at most β/(m + 1) by Markov's inequality. ∎

### 5.2 The lower bound

**Definition 5.2′ (block-majority scaffold).** Let m ≥ 0, B ≥ 1, N₀ ≥ 1 be integers and L := B·(2m + 1). X := [N₀] × [2m + 1], Y := {0, 1}. The *region class* is {f₀, f_1, …, f_{N₀}} with f₀ ≡ 0 and f_i(i′, u) := 1[i′ = i]. The scaffold Π^maj has z = (R_1, …, R_B) independent and uniform on [N₀] and no internal randomness; block b consists of the 2m + 1 calls at the inputs (R_b, 1), …, (R_b, 2m + 1); the value of a block is 1 if at least m + 1 of its answers equal 1, and 0 otherwise (an answer ⊥ is not equal to 1); out is the maximum of the block values.

**Theorem 5.3 (N5).**
1. For every member f of the region class, the human system of f tolerates m faults with failure 0 for G_f, against all replacement rules of Definition 5.1.
2. For every protocol Λ and deployed system, with n := E_{f₀}[N_Λ], some member has Fail ≥ (N₀ − n)·p(B, N₀)/(N₀ + B).
3. Hence failure ≤ δ for all members needs n ≥ N₀ − δ(N₀ + B)/p(B, N₀); if N₀ = B/(2δ) is an integer,

  n ≥ B/(4δ) − B = (1 − 4δ)·L/(4·(2m + 1)·δ).

4. Protocol R achieves failure ≤ δ for every member with n = ⌈L·K ln 2/((m + 1)δ)⌉ questions, where K = log(N₀ + 1) = log(L/(2(2m + 1)δ) + 1) with uniform weights.
With m = θL (so B = 1/(2θ + 1/L)): at least about (1 − 4δ)/(8θδ) questions are needed and K ln 2/(θδ) suffice, whatever L.

*Proof.* (1) The inputs of a block lie in one region, and every member is constant on a region, so the 2m + 1 human answers of a block are equal. The inputs of the scaffold do not depend on the answers. A rule with at most m replacements changes at most m answers of a block: a block whose human answers are all 1 keeps at least m + 1 ones, and a block whose human answers are all 0 gets at most m ones. So every block value, and the outcome, is that of the run of f. (2) Lemma 1.10(2) with B_i := {i} × [2m + 1], o₀ = 0, o_i = 1[i ∈ {R_1, …, R_B}], Δ_i = p(B, N₀) and M := B. (3) is the computation of Corollary 2.2(1) with B in place of L. (4) Proposition 5.2 with δ₀ = 0, by (1). ∎

The tolerance claim (1) was also checked by brute force for small cases (Section 8).

### 5.3 The right pair of statements, and the gap

**Proposition 5.4.** Let Π be a scaffold and H a class of functions.
(a) *Lower bound by packing.* For f₀ ∈ H and Δ > 0 let N_Π(Δ) be the largest N such that H contains functions f_1, …, f_N that equal f₀ outside disjoint sets B_1, …, B_N and have Pr[out_{f_i} ≠ out_{f₀}] ≥ Δ. If Fail(f) ≤ δ for all f ∈ H, then n := E_{f₀}[N_Λ] ≥ N_Π(Δ)·(1 − 2δ/Δ) for every Δ; in particular n ≥ N_Π(4δ)/2.
(b) *Packing is limited by tolerance.* Suppose the scaffold is non-adaptive (its inputs do not depend on the answers) and f₀, f_1, …, f_N all tolerate m faults with failure 0, each for its own G_f. Then Pr[out_{f_i} ≠ out_{f₀}] ≤ E[number of calls with input in B_i]/(2m + 1), and therefore N·min_i Δ_i ≤ L/(2m + 1): N_Π(Δ) ≤ L/((2m + 1)Δ) when all members are required to tolerate m faults.
(c) *Consequence.* On non-adaptive scaffolds, for classes whose members all tolerate m faults with failure 0, no lower bound obtained from Lemma 1.10 exceeds L/(4(2m + 1)δ); Theorem 5.3 attains this up to the term −B.

*Proof.* (a) By Lemma 1.10(1), max{Fail(f₀), Fail(f_i)} ≥ (1 − π_i)Δ/2; averaging over i and using Σ_i π_i ≤ n, δ ≥ (Δ/2)(1 − n/N). (b) On (z, ρ) let v and v′ be the vectors of answers of f₀ and f_i along the common sequence of inputs; they differ only at calls with input in B_i. Suppose their Hamming distance d is at most 2m. Changing ⌊d/2⌋ of the differing coordinates of v into those of v′ gives a vector w at distance at most m from both. The rule that turns v into w, and the rule that turns v′ into w, each make at most m replacements (they may see (z, ρ)), so by tolerance the outcome of w equals out_{f₀} and equals out_{f_i}, almost surely. Hence, up to a null event, out_{f_i} ≠ out_{f₀} implies at least 2m + 1 calls in B_i, and Markov's inequality gives the bound on Δ_i. The B_i are disjoint and the input sequence is the same for all members, so the expected numbers of calls in the B_i sum to at most L. (c) In Lemma 1.10(2) the requirement (N − n)Δ/(N + M) ≤ δ gives n ≥ N − δ(N + M)/Δ ≤ N − δN/Δ, and with N·Δ ≤ L/(2m + 1) =: B′ this is at most N(1 − δN/B′) ≤ B′/(4δ). ∎

**The pair of statements.** For a function f in a class with weights:
* *Upper bound (Proposition 5.2):* n = L·K ln 2/β questions suffice for failure ≤ δ̄_Π(β).
* *Lower bound (Proposition 5.4(a), Lemma 1.10(2)):* failure ≤ δ for all members needs n ≥ N_Π(Δ)·(1 − 2δ/Δ) for every Δ, where N_Π counts disjoint patches in the class.

They match, up to the factor K and constants, when the class contains about L/β disjoint patches whose influence is a constant fraction of δ_Π(β). For scaffolds that tolerate m faults:

| | questions |
|---|---|
| sufficient (R3) | L·K ln 2/((m + 1)·δ) |
| necessary (Theorem 5.3) | (1 − 4δ)·L/(4·(2m + 1)·δ) |

The gap is the product of three factors. (i) K ln 2: by Section 3 it is partly real (linear growth in K for fixed L/δ is forced when m = 0) and partly an artefact of Protocol R (a logarithm can be saved when m = 0; whether Protocol AB has a fault-tolerant version is open). (ii) The constant 4, as in Section 2. (iii) (2m + 1)/(m + 1) < 2: R3 treats m + 1 faults as fatal, while two members that both tolerate m faults and have different outcomes differ in at least 2m + 1 answers of the run (Proposition 5.4(b)). Closing (iii) from either side is open.

**Example 5.5 (the curve alone gives no lower bound).** Let Π make L calls at one input x₀, with out := max_j y_j, f₀ ≡ 0 and G = {out = 0}. The sampler C with C(1|x₀) = β/L has expected number of faults β and Q_C(not G) = 1 − (1 − β/L)^L ≥ β − β²/2, so δ_Π(β) ≥ β(1 − β/2) for β ≤ 1. But for every class of functions, one question at x₀ gives failure 0 for every member. So the second half of the candidate's "sharper form" of R3 ("for classes closed under patches about L/β questions are needed to get below δ_Π(β)") is false as stated: here the class of all functions is closed under patches, and one question suffices. Two things are missing in that statement. The supremum in δ_Π runs over stochastic samplers, which can spread β faults thinly over repeated visits to one input, and a function cannot. And a lower bound needs many disjoint places where a patch has influence, which is what N_Π(Δ) counts. The example also shows that the upper bound of Proposition 5.2 can be far from the truth: it bounds Protocol R by L·K ln 2/n here, while after the first rehearsal round with a question the mixture is exact at x₀.

## 6. Stochastic humans

### 6.1 The criterion

For a stochastic human, let Q̂_{r,D} be the law of the deployed run given the seed and the transcript (for a deployed answerer: the law of the run of Π with it, over (z, ρ) and its own coins; an abstention is recorded in the run). The error of a protocol against P is

  Err(P) := E_P[ TV(Q̂_{r,D}, Q_P) ],

the expected distance between the run law of the *trained* imitator and the human system. This is the quantity bounded from above in the candidate's R2 and Theorem A.

**Remark 6.0 (why not the law averaged over the training).** The weaker criterion TV(E_P[Q̂_{r,D}], Q_P) admits no lower bound of the kind below: for a task with one call at a fixed input, the protocol "ask the human once and replay the answer" has averaged law exactly Q_P with one question. Replay cannot serve two runs, and its Q̂_{r,D} is a point mass. Err is the right criterion whenever the trained imitator is used more than once. (`understand/imitation-theory.md`, Section 5.8, discusses the two criteria.)

### 6.2 Per call

**Theorem 6.1.** Let K ≥ 1, X := [K], Y := {0, 1}, θ ∈ (0, 1/4], and for σ ∈ {−1, +1}^K let P_σ be the sampler with P_σ(1|i) := 1/2 + σ_i·θ. The class 𝒞_θ := {P_σ} has 2^K members, each of K bits under uniform weights. The task is one call at an input uniform on [K]. Let Λ be a protocol whose expected number of questions is at most n under every member, and let R_{r,D}(·|i) be the law on Y ∪ {⊥} of the deployed answer at input i. Then

  2^(−K)·Σ_σ E_σ[(1/K)·Σ_i TV(R_{r,D}(·|i), P_σ(·|i))] ≥ (θ/2)·(1 − θ·√(8n/K)).

Consequently:
1. for n ≥ K/2 and θ := √(K/(32n)), some member of 𝒞_θ has Err ≥ √(K/n)/(16√2) ≈ 0.044·√(K/n);
2. for ε′ ∈ (0, 1/16], if Err(P) ≤ ε′ for every member of 𝒞_{4ε′}, then n ≥ K/(512·ε′²).
For comparison, the candidate's R1 with L = 1 and Pinsker's inequality give E TV ≤ √(K ln 2/(2n)) ≈ 0.59·√(K/n) for every class. So the per-call total variation ε′ costs between K/(512ε′²) and K ln 2/(2ε′²) questions in the worst case over classes of K bits.

*Proof.* Write R(1|i) for R_{r,D}(1|i) and let σ̂_i := +1 if R(1|i) ≥ 1/2 and −1 otherwise; σ̂_i is a function of (r, D).

(i) TV(R(·|i), P_σ(·|i)) ≥ |R(1|i) − 1/2 − σ_iθ|, and if σ̂_i ≠ σ_i the right side is at least θ. Hence E_σ TV(R(·|i), P_σ(·|i)) ≥ θ·Pr_σ[σ̂_i ≠ σ_i].

(ii) Let σ^(i) be σ with coordinate i flipped, and 𝐏_σ the law of (r, D) under P_σ. The events {σ̂_i = σ_i} and {σ̂_i = σ^(i)_i} are complementary, so Pr_σ[σ̂_i ≠ σ_i] + Pr_{σ^(i)}[σ̂_i ≠ σ^(i)_i] ≥ 1 − TV(𝐏_σ, 𝐏_{σ^(i)}).

(iii) Given the seed, the likelihood ratio of a transcript under P_σ and P_{σ^(i)} is the product over the question steps of P_σ(y_t|x_t)/P_{σ^(i)}(y_t|x_t); the factors with x_t ≠ i are 1, and the logarithm of a factor with x_t = i is bounded by ln 3 and has conditional mean kl(θ) := KL(Bern(1/2 + θ) ‖ Bern(1/2 − θ)) given the past, for either sign of σ_i. The number of steps is finite, so KL(𝐏_σ ‖ 𝐏_{σ^(i)}) = E_σ[N_i]·kl(θ), with N_i the number of questions at input i. Now kl(θ) = 2θ·ln((1 + 2θ)/(1 − 2θ)) ≤ 2θ·4θ/(1 − 2θ) ≤ 16θ² for θ ≤ 1/4 (using ln(1 + v) ≤ v with v = 4θ/(1 − 2θ)). By Pinsker's inequality TV(𝐏_σ, 𝐏_{σ^(i)}) ≤ √(KL/2) ≤ θ·√(8·E_σ[N_i]).

(iv) Average (ii) over σ uniform (each pair {σ, σ^(i)} is counted twice) and over i, and use the concavity of the square root and Σ_i E_σ[N_i] ≤ n:

  (1/K)·Σ_i 2^(−K)·Σ_σ Pr_σ[σ̂_i ≠ σ_i] ≥ (1/2)·(1 − θ·(1/K)·Σ_i 2^(−K)·Σ_σ √(8·E_σ[N_i])) ≥ (1/2)·(1 − θ·√(8n/K)).

With (i) this is the displayed bound. (1) For θ = √(K/(32n)) ≤ 1/4 the bound is θ/4. (2) With θ = 4ε′ ≤ 1/4 the bound 2ε′(1 − 4ε′√(8n/K)) ≤ ε′ gives √(8n/K) ≥ 1/(8ε′). ∎

### 6.3 Whole runs

**Lemma 6.2.** For L ≥ 1 and θ ∈ [0, 1/2] let τ_L(θ) := TV(Bern(1/2 + θ)^{⊗L}, Bern(1/2 − θ)^{⊗L}). Then τ_L(θ) ≥ θ·√L·(1 − 2Lθ²), and for odd L even τ_L(θ) ≥ θ·√(2L)·(1 − 2Lθ²).

*Proof.* Let L = 2j + 1 be odd and g(p) := Pr[Bin(L, p) ≥ j + 1]. Since Pr[Bin(L, p) ≥ k] is the probability that the k-th smallest of L independent uniform variables is at most p, g′(p) = L·C(2j, j)·(p(1 − p))^j. With p = 1/2 + t this is L·C(2j, j)·4^(−j)·(1 − 4t²)^j. For j ≥ 1, C(2j, j)·4^(−j) ≥ 1/(2√j): equality at j = 1, and the ratio of consecutive terms (2j + 1)/(2j + 2) is at least √(j/(j + 1)) because (2j + 1)² ≥ 4j(j + 1). If 1 − 2Lθ² < 0 there is nothing to prove; assume 1 − 2Lθ² ≥ 0. Then for j ≥ 1 and |t| ≤ θ, g′(1/2 + t) ≥ (L/(2√j))·(1 − 4jt²) ≥ √(L/2)·(1 − 2Lθ²), using (1 − 4t²)^j ≥ 1 − 4jt² ≥ 1 − 2Lθ² ≥ 0 and L/(2√j) = L/√(2(L − 1)) ≥ √(L/2). Therefore τ_L(θ) ≥ g(1/2 + θ) − g(1/2 − θ) ≥ 2θ·√(L/2)·(1 − 2Lθ²). For L = 1, τ_1 = 2θ. For even L ≥ 2 the first L − 1 coordinates give τ_L ≥ τ_{L−1} ≥ θ·√(2(L − 1))·(1 − 2(L − 1)θ²) ≥ θ·√L·(1 − 2Lθ²). ∎

**Theorem 6.3.** Let 𝒞_θ be the class of Theorem 6.1 and let the scaffold Π^rep_L have z = I uniform on [K] and L calls, all at the input I; the run records all answers. For every protocol whose expected number of questions is at most n under every member,

  2^(−K)·Σ_σ Err(P_σ) ≥ (τ_L(θ)/4)·(1 − θ·√(8n/K)) ≥ (θ·√L/4)·(1 − 2Lθ²)·(1 − θ·√(8n/K)).

Consequently:
1. for n ≥ max{K/2, L·K/8} and θ := √(K/(32n)), some member of 𝒞_θ has Err ≥ √(L·K/n)/(64√2) ≈ 0.011·√(L·K/n);
2. for ε ∈ (0, 1/64] and θ := 16ε/√L, if Err(P) ≤ ε for every member of 𝒞_θ, then n ≥ L·K/(8192·ε²).
The candidate's R2 gives Err ≤ √(c₀·L·K ln 2/n) for every class. So whole-run total variation ε for a stochastic human costs of order L·K/ε² questions in the worst case over classes of K bits, with no logarithm to save, in contrast to Corollary 3.4.

*Proof.* Let R_i be the law, given (r, D), of the vector of deployed answers in a run with I = i, and B_± := Bern(1/2 ± θ). Both run laws have I uniform, so TV(Q̂_{r,D}, Q_{P_σ}) = (1/K)·Σ_i TV(R_i, B_{σ_i}^{⊗L}). Let σ̂_i := +1 if TV(R_i, B_+^{⊗L}) ≤ TV(R_i, B_−^{⊗L}) and −1 otherwise. If σ̂_i ≠ σ_i, the triangle inequality gives τ_L(θ) ≤ 2·TV(R_i, B_{σ_i}^{⊗L}). Hence E_σ TV(Q̂_{r,D}, Q_{P_σ}) ≥ (τ_L(θ)/2)·(1/K)·Σ_i Pr_σ[σ̂_i ≠ σ_i], and steps (ii)–(iv) of the proof of Theorem 6.1 bound the average of the last sum from below by (1/2)(1 − θ√(8n/K)). The second inequality is Lemma 6.2. (1) θ ≤ 1/4 because n ≥ K/2; 2Lθ² = L·K/(16n) ≤ 1/2; 1 − θ√(8n/K) = 1/2; so the bound is θ√L/16. (2) θ ≤ 1/4, 2Lθ² = 512ε² ≤ 1/2, so the bound is at least 2ε·(1 − θ√(8n/K)); if this is ≤ ε then n ≥ K/(32θ²). ∎

## 7. The conclusion as one theorem

**Theorem 7.1 (what imitation with a worst-case guarantee does and does not amplify).** Let L ≥ 1 and δ ∈ (0, 1/20] with L/(2δ) an integer.

(A) *One run, questions asked in advance.* There are a scaffold with L calls (the OR scaffold) and a class of L/(2δ) + 1 functions, each of at most log(L/δ) bits, such that every protocol that asks its questions before the top-level input of the run is drawn, and whose deployed outcome is right with probability ≥ 1 − δ for every member, asks at least

  L/(4δ) − L

questions. The human does the same run with L answers and failure 0. So the imitator costs at least 1/(4δ) − 1 ≥ 4 times the human work it replaces, although the class is as simple as a class with L/(2δ) + 1 members can be.

(B) *With complexity.* For every m ≥ 1 there are a scaffold with L calls and a class of 2^K functions, K = m·log(L/(2δ)), of VC dimension m, for which the same requirement needs at least (1 − 10δ)·m·L/(8δ) = (1 − 10δ)·K·L/(8δ·log(L/(2δ))) questions. Since m is arbitrary, no number of questions that depends on L and δ alone suffices: the number must grow with the complexity of the human, linearly in the VC dimension, and as K·L/(δ·log(L/δ)) in bits, and no faster (Theorem 3.3).

(C) *One run, the human available during the run.* For the OR scaffold and the needle class with ⌈L/√(2δ)⌉ cells: even if the protocol sees z before it asks, it needs at least L·(1 − √(2δ) − δ) − δ answers. A worst-case guarantee therefore saves at most the fraction √(2δ) + δ + δ/L of the human's work on one run of L critical calls.

(D) *Many runs under one failure budget.* Let r ≥ 1 and ε ∈ (0, 1/20] with rL/(2ε) an integer. If r independent runs of the OR scaffold must all have the right outcome with probability ≥ 1 − ε for every member, then for the needle class 𝒩(rL/(2ε)) at least rL/(4ε) − rL questions are needed in advance, and for the needle class with ⌈rL/√(2ε)⌉ cells at least rL·(1 − √(2ε) − ε) − ε are needed even with the human available throughout. The human does the r runs with rL answers. There is no amplification for any r.

(E) *Many runs at a failure rate.* For every class of functions with weights, every member f with K = log(1/w(f)) and every scaffold with L calls, ⌈L·K ln 2/δ⌉ questions (Protocol R; Lemma 5.1′) or 1 + 2.7·K·L/(δ·log(L/δ)) questions (Protocol AB; K known) give an imitator each of whose runs is faithful with probability ≥ 1 − δ, for any number r of future runs; the expected number of unfaithful runs among r is at most δr. The human would spend rL answers. The ratio of human answers replaced to human answers spent is therefore at least rL/(L·K ln 2/δ + 1), about r·δ/(K ln 2), which is unbounded in r, and for the classes of (A) and (B) it is at most 4rδ/(1 − 4δ) and 8rδ·log(L/(2δ))/((1 − 10δ)·K).

(F) *Fault tolerance.* For the block-majority scaffold, which tolerates m faults, (A) becomes (1 − 4δ)·L/(4(2m + 1)δ) (Theorem 5.3), and L·K ln 2/((m + 1)δ) questions suffice (candidate R3). One run is then amplified by Protocol R once (m + 1)·δ > K ln 2, and by no protocol unless 4(2m + 1)δ > 1 − 4δ.

*Proof.* (A) Corollary 2.2(1); log(L/(2δ) + 1) ≤ log(L/δ). (B) Theorem 3.1; for any n choose m with (1 − 10δ)·m·L/(8δ) > n; the upper bound is Corollary 3.4(1). (C) Proposition 2.5. (D) The r runs of the OR scaffold with N₀ cells are one run of the OR scaffold with rL calls, cut into r pieces; if all r outcomes are right, so is their maximum, which is the outcome of the long run. Apply Corollary 2.2(1) and Proposition 2.5 with rL and ε in place of L and δ. (E) By Lemma 5.1′ the expected number of calls at which the draw of M^(T) differs from f in a run is at most L·K ln 2/n, and a run without such a call is faithful; Theorem 3.3(3) for Protocol AB. The imitator is trained once; each later run uses a fresh (z, ρ), so each is unfaithful with probability at most δ. The upper limits on the ratio are (A) and (B). (F) Theorem 5.3. ∎

**In words.** Questions do not buy runs; they buy coverage of the scaffold's input distribution. A protocol that must be right for every member of a class closed under patches has to have asked, with probability about 1 − δ/p, every place whose patch would change the outcome with probability p. For a run all of whose calls are critical there are about L/δ places that matter at level δ, and nothing is gained over letting the human do the run; this holds per unit of failure probability, so it holds for any number of runs that share one budget (D). What imitation buys is *reuse*: the same L·K/δ answers (up to the logarithm) serve every later run at failure rate δ per run (E). And it buys *tolerance*: if the scaffold survives m faults the price drops by a factor between m + 1 and 2m + 1 (F). The first is the sense in which sound imitation does not amplify human work on critical tasks; the second and third are the senses in which it does.

## 8. Numerical checks

Both scripts ran without a failed assertion (`python3 lower-bounds_lp.py`, 33 s; `python3 lower-bounds_sim.py`, 4 s; Python 3 with numpy 2.5.3 and scipy 1.18.1).

**8.1 Exact minimax values by linear programming** (`lower-bounds_lp.py`). A randomised protocol for the needle class is a mixture of pairs (set S of cells asked while the answers are 0; outcome deployed after the all-zero transcript as a function of the set of visited cells). The linear programme minimises the largest failure probability over the class, so its value is the exact minimax v(n) over all protocols with at most n questions.

```
Theorem 2.1: lower bound (N0-n)p/(N0+L) <= minimax <= (N0-n)p/N0
 N0  L  n   lower      minimax(LP)  upper
  3  2  0   0.333333   0.416667     0.555556
  3  2  1   0.222222   0.222222     0.370370
  3  2  2   0.111111   0.138889     0.185185
  4  2  0   0.291667   0.437500     0.437500
  4  2  1   0.218750   0.262500     0.328125
  4  2  2   0.145833   0.156250     0.218750
  4  2  3   0.072917   0.087500     0.109375
  5  2  0   0.257143   0.360000     0.360000
  5  2  1   0.205714   0.288000     0.288000
  5  2  2   0.154286   0.180000     0.216000
  5  2  3   0.102857   0.112000     0.144000
  5  2  4   0.051429   0.060000     0.072000
  4  3  0   0.330357   0.390625     0.578125
  4  3  1   0.247768   0.309375     0.433594
  4  3  2   0.165179   0.192708     0.289062
  4  3  3   0.082589   0.115625     0.144531

Proposition 2.5: lower bound (N0*p-n)/(N0+L) <= minimax (questions during the run)
 N0  L  n   lower      minimax(LP)
  5  3  0   0.305000   0.406667
  5  3  1   0.180000   0.288000
  5  3  2   0.055000   0.096000
  5  3  3   0.000000   0.000000
  8  4  0   0.275879   0.413818
  8  4  1   0.192546   0.288818
  8  4  2   0.109212   0.164062
  8  4  3   0.025879   0.051270
  8  4  4   0.000000   0.000000

Theorem 4.1: best advantage eta over 1/2 with n questions and N shifts; claim eta = n/(2N)
  N  n   eta(LP)    n/(2N)
  4  1   0.125000   0.125000
  4  2   0.250000   0.250000
  5  1   0.100000   0.100000
  5  3   0.300000   0.300000
```

(The tables for Proposition 2.5 and Theorem 4.1 are excerpts; the script prints all rows, N ≤ 5 for Theorem 4.1, and asserts equality with n/(2N) in every row.) The lower bound of Theorem 2.1 is attained exactly at (N₀, L, n) = (3, 2, 1). For these small N₀ the upper bound of Proposition 2.3 is not attained in general, because guessing outcome 1 is sometimes better when p is large; the two bounds differ by the factor 1 + L/N₀, which tends to 1 in the regime N₀ = L/(2δ) of Corollary 2.2.

**8.2 Simulations and exact evaluations** (`lower-bounds_sim.py`).

```
(a) block class: lower bound of Theorem 3.1 vs. the all-or-nothing protocol
   m     N    L   rho  E[questions]  failure(protocol)  lower bound at that n
  16   200    5  0.50        804.0   0.012376           0.011077
  64  1000   10  0.25       8008.0   0.007466           0.007265
  64  1000   10  0.50      16016.0   0.004978           0.004773
  64  1000   10  0.75      24024.0   0.002489           0.002282
  64  1000   50  0.50      16016.0   0.024397           0.019493

(b) protocol AB on the block class with N = L/(2 eps) (scaffold: L uniform calls in one random block)
   m=16, N=128, L=4, eps=0.01562, K=112 bits, log2(L/eps)=8, gamma=0.0312, n_B=5735
      questions asked: mean 1045, max 1307; proved bound n_B + K ln2/gamma = 8219; 2.7 K L/(eps log2(L/eps)) = 9677
      failure of the deployed h: mean 0.00837; proved bound 0.01562 (<= eps)
      Theorem 3.1: failure <= eps for all members needs n >= 442; Protocol R's bound L K ln2/eps = 19874
   m=32, N=512, L=8, eps=0.00781, K=288 bits, log2(L/eps)=10, gamma=0.0098, n_B=44162
      questions asked: mean 8108, max 9311; proved bound n_B + K ln2/gamma = 64604; 2.7 K L/(eps log2(L/eps)) = 79626
      failure of the deployed h: mean 0.00453; proved bound 0.00781 (<= eps)
      Theorem 3.1: failure <= eps for all members needs n >= 3812; Protocol R's bound L K ln2/eps = 204417
   m=32, N=2048, L=16, eps=0.00391, K=352 bits, log2(L/eps)=12, gamma=0.0029, n_B=171336
      questions asked: mean 31661, max 36908; proved bound n_B + K ln2/gamma = 254617; 2.7 K L/(eps log2(L/eps)) = 324403
      failure of the deployed h: mean 0.00236; proved bound 0.00391 (<= eps)
      Theorem 3.1: failure <= eps for all members needs n >= 15812; Protocol R's bound L K ln2/eps = 999374

(c) block-majority scaffold: outcome unchanged by <= m replaced answers (brute force)
   m=1, blocks G=2, block size 3, regions N0=3: tolerant = True
   m=2, blocks G=1, block size 5, regions N0=3: tolerant = True
   m=1, blocks G=3, block size 3, regions N0=2: tolerant = True

(d) Lemma 6.2: min over a grid of TV / (t sqrt(L) (1 - 2 L t^2)); must be >= 1
   smallest ratio found: 1.4142

(e) Theorem 6.1: lower bound (t/2)(1 - t sqrt(8 q)) vs exact Bayes risk 2 t Pr[MAP sign wrong]
    q     t        lower bound   exact (equal allocation)
     1  0.17678   0.044194      0.114277
    16  0.04419   0.011049      0.032141
   256  0.01105   0.002762      0.007998
```

Notes. (a) is exact arithmetic, not simulation; rows are excerpts. In (b) a question whose answer is already known is not asked, so the simulated protocol asks fewer questions than the bound counts; "mean" and "max" are over 20 runs with a uniformly random member; the failure is the average over the n_B rehearsal steps of the exact failure probability of the function deployed at that step. In (b) the number of questions the simulated protocol used lies between the lower bound of Theorem 3.1 and the bound of Theorem 3.3, and is far below Protocol R's bound. In (c) the replaced answers range over {0, 1, ⊥} and all members, all z and all sets of at most m positions are enumerated; the script's letter G is the number B of blocks. In (d) the grid is L ∈ {1, …, 59, 101, 200, 401} and 199 values of t in (0, 1/√(2L)); the smallest ratio is √2, attained as t → 0 for L = 1, which suggests that the bound with √(2L) holds for even L too (I prove it only for odd L). In (e) "exact" is the Bayes risk of the protocol that asks each of the K inputs q times, for the loss |R(1|i) − P_σ(1|i)|.

## 9. What remains open in this part

1. **Constants.** (i) For the needle class the minimax number of questions for failure δ is between L/(4δ) − L and ⌈L/(4δ)⌉ (Proposition 2.3). Whether some class with K = O(log(L/δ)) needs more than L/(4δ)·(1 + o(1)) is open. (ii) In Corollary 3.4 the constants are 1/8 below and 2.7 above (1 + ln 2 asymptotically).
2. **Protocol AB beyond its theorem.** A version without knowledge of K (doubling should work, not written out); a version whose guarantee uses fault tolerance (Theorem 3.3 bounds the probability of any unfaithful call, so it gains nothing from m > 0); whether the per-call mixture can be combined with targeted questions to get K·L/((m + 1)·δ·log) questions; a computable version.
3. **N5.** The factor (2m + 1)/(m + 1) between Theorem 5.3 and R3 (Section 5.3, item (iii)). Proposition 5.4(b) is proved for non-adaptive scaffolds and failure 0 only; the adaptive case and δ₀ > 0 are open.
4. **A characterisation.** For a given class with weights and a given scaffold, the minimax number of questions lies between the packing bound of Proposition 5.4(a) and the bounds of Theorem 3.3 and Proposition 5.2. A combinatorial parameter that determines it up to constants (an analogue, for chosen single-call questions inside a scaffold, of the teaching-dimension parameters of query learning) is not known to me.
5. **Stochastic humans.** The constants in Theorems 6.1 and 6.3 (512 and 8192 against ln 2/2 and c₀ ln 2). Lower bounds for the averaged criterion of Remark 6.0 when the imitator is used for r runs. A stochastic class with critical calls for which both ε^(−2) and a needle-type factor appear together.
6. **N3.** Whether 2^k disjoint decidable regions of prefix complexity at most k + c exist (Corollary 4.2 has k + K(k) + c).
7. **N1 for samplers with full support.** Proposition 1.8(2) pays log(1/η) bits for total variation 1 − η; I did not look for a matching lower bound on the complexity of such a patch.

## 10. Remarks on other parts of the candidate theory

Found while working on this part; I did not check the other parts systematically.

1. **N1, last sentence** is false for samplers with full support at x (Proposition 1.8(3)); correct for functions.
2. **N2.** The factor (1 − o(1)) is (1 − ε/2); the consequence n ≥ L/(2ε) can be replaced by n ≥ (1 − ε)·L/ε (Corollary 2.2). "Protocol R needs 4LK ln 2/ε" is right for failure ε/4.
3. **N3** is false as stated for randomised protocols (Theorem 4.1(4)); "regions of complexity ≤ k + c" needs k + K(k) + c for prefix complexity.
4. **Section 0, item 2** ("optimal up to the factor K") and **Section 10, item 5** (budget): the worst case is of order K·L/(ε·log(L/ε)), and Protocol R is not optimal for functions (Corollary 3.4).
5. **R3, "sharper form".** The upper half is correct (Proposition 5.2). The lower half is false as stated (Example 5.5).
6. **S2.** The mixture over all samplable laws is not samplable by a halting procedure (Proposition 4.4(c)). The constant c is unnecessary. **S1** should be stated for the top-level law (or it must say whose visit measure d′ is: the visit measure of the deployed imitator depends on the imitator).
7. **R5** says that every rule deploying a single hypothesis per run has, in some classes, runs with Ω(L) unfaithful calls with probability Ω(L/n). Theorem 3.3 deploys one function per run with probability at most L·K/(n_B·log(1/γ)) of any unfaithful call; this is consistent with R5 but shows that "single hypothesis" is not worse than the mixture for the probability of a fully faithful run. R5's comparison should be stated for the number of unfaithful calls only.
8. **`understand/imitation-theory.md`, Section 5.5** ("active selection helps on classes with few patches and not in the worst case"): Theorem 3.3 shows that chosen questions save a factor of order log(L/ε) in the worst case over classes of functions with weights. The same digest's LB1–LB3 are lower bounds of the same family as Theorems 2.1, 3.1 and 6.3 (derived independently there; its LB2 is given as a sketch). The differences here: exact constants and tightness for N2, bounds in terms of the expected number of questions, deployed systems that see (z, ρ), a complete proof of the factor K with the matching upper bound, and the per-call stochastic bound with the factor K.

## 11. Literature used, and how

No result from the literature is used as a black box in a proof, except Pinsker's inequality. Statements marked [memory] were not read in the source during this session.

* **Pinsker's inequality:** TV(P, Q) ≤ √(KL(P‖Q)/2), KL in nats. [memory; standard; for example A. B. Tsybakov, *Introduction to Nonparametric Estimation*, Springer 2009, Lemma 2.5.] Used in Theorems 6.1 and 6.3.
* **The two-point and hypercube method** (Le Cam; Assouad): B. Yu, "Assouad, Fano, and Le Cam", in *Festschrift for Lucien Le Cam*, Springer 1997, pp. 423–435 [memory]. The proofs of Theorems 6.1 and 6.3 are an instance of Assouad's method with adaptive sampling, written out in full; the divergence decomposition KL = E[N_i]·kl in step (iii) is the standard one for adaptively collected samples.
* **A. Ehrenfeucht, D. Haussler, M. Kearns and L. Valiant,** "A general lower bound on the number of examples needed for learning", *Information and Computation* 82(3):247–261, 1989. Statement [memory, constants not verified]: a class of VC dimension d ≥ 2 cannot be learned to error ε ≤ 1/8 with confidence 99% from fewer than (d − 1)/(32ε) random examples. Bibliographic data confirmed by a web search in this session; the theorem was not read. Used only in Remark 3.6, as the bound that does *not* apply to protocols that choose their questions.
* **T. Hegedűs,** "Generalized teaching dimensions and the query complexity of learning", *Proceedings of COLT 1995*, pp. 108–117. Statement [memory, not verified]: a finite class C is identified exactly with a number of membership queries of order XTD(C)·log|C|/log XTD(C), where XTD is the extended teaching dimension. Bibliographic data confirmed by a web search; the paper was not read. Used only in Remark 3.6, as the known precedent for the logarithm saved in Theorem 3.3; the proof of Theorem 3.3 is self-contained.
* **Counting of strings of small prefix complexity** (Remark after Corollary 4.2): the number of strings x with K(x) ≤ j is 2^(j − K(j) + O(1)). [memory: G. J. Chaitin, "A theory of program size formally identical to information theory", *Journal of the ACM* 22:329–340, 1975; M. Li and P. Vitányi, *An Introduction to Kolmogorov Complexity and Its Applications*, Springer.] Used only in that remark.
* **No computable measure dominates all computable measures** [memory: standard, Li and Vitányi, the chapter on universal semimeasures]. Proposition 4.4(c) proves the version needed here directly.
* **Exact sampling from a computable discrete law with fair coins** [memory: D. Knuth and A. Yao, "The complexity of nonuniform random number generation", 1976]. Proposition 4.4(c) gives the elementary argument.
* **Lower bounds for imitation learning** (Foster, Block and Misra 2024; Rajaraman, Yang, Jiao and Ramchandran 2020): not read by me; quoted in `understand/imitation-theory.md`, Section 5.4. They concern episodes with every state labelled; none of them is used here.
* **From the candidate theory:** R1 for functions is re-proved as Lemma 5.1′ and is what Theorem 7.1(E) and Proposition 5.2 use. R2 for stochastic humans (the constant c₀) and R3 for stochastic humans are quoted for comparison only and were not checked.
* **From the repository digest** (`understand/repo.md`): the definition of sep(x; A) (Section 1 there); the patch construction of Proposition 1.8 is that of items D1 and D5 there.

