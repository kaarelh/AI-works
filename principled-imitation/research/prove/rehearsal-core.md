# rehearsal-core: Lemmas L1–L3, Theorems R1–R3 and the remarks after R6

Part "rehearsal-core" of the check of `research/candidate-theory.md` (version 2). Everything below is written to be checked line by line. Tags: **PROVED** (statement of the candidate theory proved as stated, or in the stated precise form), **MODIFIED** (the statement needed a change, which is named), **REFUTED** (with counterexample), **OPEN**, and **NEW** (a statement that is not in the candidate theory, proved here). Nothing here has been refereed.

## Summary table

| no. | statement | tag |
|---|---|---|
| 2.1 | L1, chain rule for runs of variable length, values in [0, ∞] | PROVED |
| 3.2 | L2, coupling: E[number of unfaithful calls] = E_{Q_A} Σ_j TV, and TV(Q_A, Q_B) ≤ Pr[some call unfaithful] | PROVED (slightly sharper) |
| 3.4 | "the imitator's run is a run of the human system with the unfaithful calls replaced": exact sense, by a stateless randomised replacement rule | PROVED (sense made precise) |
| 4.1 | L3, Bayes regret on adaptive questions, with semimeasures, sub-probability weights, skipped rounds, all integrability | PROVED |
| 4.2 | L3 for a function: Π_t (1 − e_t) ≥ w(f)/W on every path | PROVED |
| 4.3 | high-probability forms: Σ_t E_{t−1}[a_t e_t] ≤ K ln 2 + ln(1/δ) (function); Σ_t E_{t−1}[a_t H²_t] ≤ (K ln 2)/2 + ln(1/δ) (general) | NEW |
| 5.1 | R1: Σ_{t≤n} E Λ(M^(t)) ≤ L·ln(W/w(P)) ≤ L·K ln 2 | PROVED |
| 5.2 | what "deploy M^(U), U a uniformly random round" guarantees: per run; once for good (Markov); with high probability over the rehearsal | PROVED / NEW |
| 5.3 | several calls of one rehearsal run put to the human: the bound L·K ln 2 stays, it does not improve, and the frozen sum is not bounded by the regret | MODIFIED (Remark (i) made precise) |
| 5.4 | re-drawing the round at every call (the averaged kernel) is not covered: it can exceed the bound by a factor of order L | NEW (counterexample) |
| 6.1 | last round, non-adaptive scaffold, deterministic human: E β(M^(n+1)) ≤ L·(K ln 2 + ln n + 1)/n | NEW |
| 6.2 | last round in general: E Λ(M^(n+1)) can exceed L·K ln 2/n by a factor ≥ 0.11·(L − 1) | PROVED (Remark (iii), by example; the reason given there is incomplete) |
| 7.1 | R2 for a function: the deployed run is the human system's run on the same (z, ρ) with probability ≥ 1 − L·K ln 2/n | PROVED |
| 8.3 | R3, sharper form with the robustness curve | PROVED (was [?]) |
| 8.4 | R3 with "tolerates m faults": true as stated; hypothesis weakened to budgeted stateless replacement rules | PROVED and MODIFIED (weaker hypothesis) |
| 8.5 | the Markov step is tight; the adversary classes are different | NEW |
| 8.6 | recoverable form: failure ≤ δ₀ + μ·β, no Markov step | NEW |
| 9.1 | stochastic human: E β(M^(U)) ≤ L·√(K ln 2/(2n)); R3 with √(K ln 2/(2n))/θ | PROVED |
| 9.2 | the rate √(K/n) per call is unavoidable: every protocol has E β ≥ 0.088·L·√(K/n) for some member of a class with K bits | NEW |
| 9.3 | low stakes for a stochastic human needs of order 1/θ² questions, not 1/θ | NEW |
| 10.1–10.3 | online form (ask each call with probability q): bound, and equivalence with rehearsal | PROVED (Observation A of `understand/notes.md`) / NEW |
| 11 | Remarks (i), (ii), (iii) after R6 | (i) MODIFIED, (ii) PROVED, (iii) PROVED in the form 6.2 |
| 14 | last round for a deterministic human and an adaptive scaffold (count of unfaithful calls); lower-bound half of the "sharper form" of R3 | OPEN |

## 0. Conventions and changes of notation

* Logarithms are natural unless written log₂. K := log₂(1/w(P)), so ln(1/w(P)) = K ln 2.
* **Change of notation 1.** The candidate theory uses T both for the number of calls of a run (Section 1) and for the uniformly random round (Protocol R). Here T is the number of calls of a run and **U** is the random round; the deployed imitator is M^(U).
* **Change of notation 2.** The answer alphabet seen by the scaffold is Y_⊥ := Y ∪ {⊥}. The candidate theory completes a semimeasure by ⊥ but defines next_j only on answers in Y; a mixture of semimeasures can answer ⊥, so next_j and out must be defined there.
* **Change of notation 3.** For a kernel C the two functionals Λ(C) and β(C) of Definition 1.5 are named; the candidate theory writes them out each time.
* TV(p, q) := ½ Σ_y |p(y) − q(y)|; KL(p ‖ q) := Σ_y p(y) ln(p(y)/q(y)) ∈ [0, ∞], with 0·ln(0/·) = 0 and KL = ∞ if p(y) > 0 = q(y) for some y; H²(p, q) := 1 − Σ_y √(p(y)q(y)) (the convention of L4). For kernels, TV(C, C′)(x) abbreviates TV(C(·|x), C′(·|x)), and so on.
* Two elementary inequalities are used repeatedly. (E1) For a probability p and a sub-probability q on a countable set, Σ_y p(y)·(ln(q(y)/p(y)))⁺ ≤ 1/e, because (ln u)⁺ ≤ u/e for u > 0. (E2) 1 − u ≤ −ln u for u ∈ (0, 1].

## 1. Setting

**Definition 1.1 (kernels).** X and Y are countable sets. A *kernel* is a map C that assigns to every x ∈ X a probability distribution C(·|x) on Y_⊥. A *sampler* is a kernel with C(⊥|x) = 0 for all x. A *hypothesis* is a conditional semimeasure ν(y|x) ≥ 0 with Σ_{y∈Y} ν(y|x) ≤ 1; it is identified with the kernel that gives ⊥ the missing mass, ν(⊥|x) := 1 − Σ_{y∈Y} ν(y|x) ("no answer"). The human is a sampler P (assumption A1). A function f: X → Y is the sampler δ_{f(x)}.

**Definition 1.2 (class, posterior, mixture).** H is a countable set of hypotheses with weights w(ν) > 0, W := Σ_ν w(ν) ≤ 1, and P ∈ H (assumption A2). A *data list* D is a finite sequence of pairs (x_i, y_i) ∈ X × Y; D + (x, y) is D with one pair appended. Put ν(D) := Π_i ν(y_i|x_i) (a repeated input is counted every time) and ξ(D) := Σ_ν w(ν)·ν(D), so ξ(∅) = W. If ξ(D) > 0 the *posterior* is w_D(ν) := w(ν)ν(D)/ξ(D) and the *mixture* is the kernel

  M_D(y|x) := Σ_ν w_D(ν)·ν(y|x) = ξ(D + (x, y))/ξ(D) for y ∈ Y,  M_D(⊥|x) := 1 − Σ_{y∈Y} M_D(y|x).

If ξ(D) = 0 put M_D := M_∅ (this case has probability 0 below). Since P ∈ H: M_D(y|x) ≥ w_D(P)·P(y|x), hence

  KL(P ‖ M_D)(x) ≤ ln(1/w_D(P)) < ∞ whenever P(D) > 0.  (1.1)

**Definition 1.3 (scaffold, run).** A *scaffold* Π of horizon L ≥ 1 consists of: a countable set Z with a distribution D₀ (top-level inputs); a probability space (R, 𝓡, λ) (internal randomness); measurable maps next_j: Z × R × Y_⊥^{j−1} → X ∪ {STOP} for j = 1, …, L, with the convention next_{L+1} := STOP; and a measurable map out on runs. For (z, ρ) and answers y_1, y_2, … the *history before call j* is h_j := (z, ρ, y_1, …, y_{j−1}), the *input of call j* is x_j := next_j(h_j), and the *number of calls* is

  T := min{ j ≥ 0 : next_{j+1}(h_{j+1}) = STOP } ∈ {0, …, L}.

So {j ≤ T} is determined by h_j: T is a stopping time for the histories. A *run* is τ = (z, ρ, y_1, …, y_T); its inputs x_1, …, x_T are functions of τ. The set of runs is called 𝒯.

**Definition 1.4 (answerers, run law).** An *answerer* A is a family of probability distributions A_j(·|h_j) on Y_⊥, measurable in h_j, for j ≤ L. A kernel C is the answerer A_j(·|h_j) := C(·|next_j(h_j)); it looks only at x_j. The *run law* Q_A is the distribution of the run obtained by drawing z ~ D₀ and ρ ~ λ independently and then, for j = 1, 2, … while next_j(h_j) ≠ STOP, y_j ~ A_j(·|h_j). In formulas, Q_A has the density Π_{j≤k} A_j(y_j|h_j) at a run with T = k, with respect to D₀ ⊗ λ ⊗ counting measure. The *human system* is Q_P. An answerer with private memory or private coins has the same run law as the answerer given by its conditional answer laws given h_j, so nothing is lost by Definition 1.4 as far as run laws go.

*Padding.* It is sometimes convenient to give every run exactly L answers: after STOP every answerer answers a fixed symbol ∗ with probability 1. Padding changes no run law, no divergence between run laws, and none of the sums below, because all padded terms are zero.

**Definition 1.5 (the two functionals).** For a kernel C,

  Λ(C) := E_{Q_C} Σ_{j≤T} KL(P ‖ C)(x_j) ∈ [0, ∞],  β(C) := E_{Q_C} Σ_{j≤T} TV(P, C)(x_j) ∈ [0, L].

Both are computed along C's own runs. By Proposition 3.4, β(C) is the expected number of unfaithful calls of a run of C. For a function f and e_C(x) := 1 − C(f(x)|x): TV(f, C)(x) = e_C(x) and KL(f ‖ C)(x) = −ln(1 − e_C(x)), so β(C) ≤ Λ(C) by (E2).

**Assumption 1.6 (H1: fresh answers; this is A1 together with the part of A3 that is used).** Whenever a protocol puts an input x to the human, the answer y satisfies Pr[y = · | 𝓖] = P(·|x), where 𝓖 is the σ-algebra of everything realised before that answer: all earlier questions and answers, and all random choices of the protocol up to then, including those that produced x. The protocol's own random choices (z, ρ, the mixture's draws, the index J, the round U) are made as stated, independently of the past where the protocol says so.

*Remark on A3.* The candidate theory adds that the protocol's coins are "not computable by any hypothesis". For the class of Definition 1.2 this is automatic: a hypothesis is a function of x alone and never sees a coin. The clause would matter only if the string x differed between asked and unasked calls, which Protocol R excludes: the human is shown the same x that the imitator was shown.

## 2. Lemma L1 (chain rule)

**Lemma 2.1 (L1). PROVED.** For answerers A and B (in particular for kernels S, S′),

  KL(Q_A ‖ Q_B) = E_{Q_A} Σ_{j≤T} KL(A_j(·|h_j) ‖ B_j(·|h_j)),

both sides in [0, ∞]. For kernels the summand is KL(S ‖ S′)(x_j).

*Proof.* Pad the runs to L answers. Let Q_A^{(j)} be the law of h_{j+1} = (z, ρ, y_1, …, y_j) under A; Q_A^{(0)} = Q_B^{(0)} = D₀ ⊗ λ. It suffices to prove, for j = 1, …, L,

  KL(Q_A^{(j)} ‖ Q_B^{(j)}) = KL(Q_A^{(j−1)} ‖ Q_B^{(j−1)}) + E_{Q_A}[k(h_j)],  k(h) := KL(A_j(·|h) ‖ B_j(·|h)) ∈ [0, ∞],  (2.1)

and to add up: the padded terms (j > T) are zero because both answerers then answer ∗. Write μ_A, μ_B for the laws of h_j and a(y|h), b(y|h) for A_j, B_j.

Case 1: μ_A is not absolutely continuous with respect to μ_B. Then neither is Q_A^{(j)} with respect to Q_B^{(j)} (take a set N of histories with μ_A(N) > 0 = μ_B(N) and all continuations of it). Both sides of (2.1) are ∞.

Case 2: μ_A ≪ μ_B with density r. With respect to μ_B ⊗ counting measure, Q_A^{(j)} has density r(h)a(y|h) and Q_B^{(j)} has density b(y|h). Let S := {(h, y) : r(h)a(y|h) > 0 = b(y|h)}.

Case 2a: S has positive measure. Then Q_A^{(j)}(S) > 0 = Q_B^{(j)}(S), so the left side is ∞. On the set of histories h that occur in S we have k(h) = ∞, and this set has positive μ_A-measure, so the right side is ∞.

Case 2b: S is a null set. Then Q_A^{(j)} ≪ Q_B^{(j)} with density r(h)a(y|h)/b(y|h), and KL(Q_A^{(j)} ‖ Q_B^{(j)}) = E_{Q_A}[ln r(h_j) + ln(a(y_j|h_j)/b(y_j|h_j))]. The negative parts of the two summands are integrable: ∫ r·(ln(1/r))⁺ dμ_B ≤ 1/e, and E[(ln(a/b))⁻ | h_j] ≤ 1/e by (E1). So the expectation of the sum is the sum of the expectations, each in (−∞, ∞]. The first is KL(μ_A ‖ μ_B). The second equals E_{Q_A}[k(h_j)] by conditioning on h_j (Tonelli for the positive part, Fubini for the integrable negative part). ∎

*Literature.* This is the chain rule for relative entropy (for discrete variables: Cover and Thomas, *Elements of Information Theory*, 2nd ed., Wiley 2006, Theorem 2.5.3; quoted from memory, not opened in this session). The proof above is self-contained and covers the uncountable ρ, the variable length and the value ∞.

## 3. Lemma L2 (coupling) and the notion of an unfaithful call

**Lemma 3.1 (maximal coupling).** Let a, b be probability distributions on a countable set S and t := TV(a, b). Put γ(y, y) := min(a(y), b(y)) and, for y ≠ y′, γ(y, y′) := (a(y) − b(y))⁺·(b(y′) − a(y′))⁺/t if t > 0 (and 0 if t = 0). Then γ is a distribution on S × S with marginals a and b and γ{(y, y′) : y ≠ y′} = t. Every pair of random variables with marginals a and b differs with probability at least t.

*Proof.* Fix y. If a(y) > b(y), then (b − a)⁺(y) = 0, so Σ_{y′≠y} (b − a)⁺(y′) = t and Σ_{y′} γ(y, y′) = b(y) + (a(y) − b(y)) = a(y). If a(y) ≤ b(y), the off-diagonal terms vanish and the sum is min(a(y), b(y)) = a(y). The second marginal is symmetric. The diagonal has mass Σ_y min(a(y), b(y)) = 1 − t. For any coupling, Pr[both equal s] ≤ min(a(s), b(s)); sum over s. ∎

**Lemma 3.2 (L2). PROVED, in the following form.** Let A, B be answerers. Construct (z, ρ) ~ D₀ ⊗ λ and pairs (y_j, y′_j), j = 1, 2, …, as follows: with h_j := (z, ρ, y_1, …, y_{j−1}) and 𝓖_j := σ(z, ρ, (y_i, y′_i)_{i<j}), as long as next_j(h_j) ≠ STOP draw (y_j, y′_j), conditionally on 𝓖_j, from the maximal coupling of A_j(·|h_j) and B_j(·|h_j). Call j ≤ T is *unfaithful* if y_j ≠ y′_j; N is the number of unfaithful calls. Then:

(a) τ := (z, ρ, y_1, …, y_T) has law Q_A, and given 𝓖_j the *shadow answer* y′_j has law B_j(·|h_j): it is B's answer at A's history.

(b) Pr[y_j ≠ y′_j | 𝓖_j] = TV(A_j(·|h_j), B_j(·|h_j)) on {j ≤ T}, hence E N = E_{Q_A} Σ_{j≤T} TV(A_j(·|h_j), B_j(·|h_j)).

(c) On an enlarged probability space there is a run τ̃ with law Q_B and τ̃ = τ on {N = 0}. Hence TV(Q_A, Q_B) ≤ Pr[N ≥ 1] ≤ min(1, E N).

(d) Any other joint construction of a run of A with shadow answers satisfying (a) has Pr[y_j ≠ y′_j | past] ≥ TV(A_j(·|h_j), B_j(·|h_j)): the expected number of unfaithful calls in (b) is the least possible.

*Proof.* (a) and (b) follow from Lemma 3.1 applied conditionally, with the tower property; {j ≤ T} ∈ σ(h_j) by Definition 1.3. (d) is the last sentence of Lemma 3.1 applied conditionally. (c) Let j₁ be the first unfaithful call (j₁ = ∞ if N = 0). Put ỹ_j := y′_j for j ≤ min(j₁, T). If j₁ ≤ T, continue for j > j₁ by drawing ỹ_j from B_j(·|h̃_j) with fresh randomness, where h̃_j := (z, ρ, ỹ_1, …, ỹ_{j−1}), until STOP. For j ≤ j₁ we have h̃_j = h_j, because ỹ_i = y′_i = y_i for i < j₁. So for every j, given everything realised before call j of the new run, ỹ_j has law B_j(·|h̃_j): for j ≤ j₁ by (a), since {j ≤ j₁} ∈ 𝓖_j; for j > j₁ by construction. A run built in this way has law Q_B. If N = 0 then ỹ_j = y_j for all j ≤ T and the two runs stop at the same call. ∎

The candidate theory states "TV(Q_A, Q_B) ≤ that expectation"; (c) is the same with Pr[N ≥ 1] in between. By symmetry the bound also holds with the expectation under Q_B.

**Definition 3.3 (replacement rules; the corrupted human system).** A *replacement rule* r is a family of probability distributions r_j(· | z, ρ, x_1, …, x_j, y′_1, …, y′_j, y_1, …, y_{j−1}) on Y_⊥, measurable in the arguments. The *run of the human system corrupted by r* is produced as follows: draw (z, ρ); for j = 1, 2, …, while x_j := next_j(z, ρ, y_1, …, y_{j−1}) ≠ STOP, the human answers y′_j ~ P(·|x_j) (a fresh draw at the input actually asked, by H1), and the answer passed to the scaffold is y_j ~ r_j(· | …). A *replacement* happens at call j if y_j ≠ y′_j. Classes of rules:

* 𝓡_all: all replacement rules (they see the top-level input, the scaffold's internal randomness, all earlier human answers and their own earlier outputs, and they have private coins);
* 𝓡_tr: the rules that depend on (z, ρ) only through x_1, …, x_j (they see the transcript only);
* 𝓡_st: the *stateless* rules r_j = κ(· | x_j, y′_j), for a family κ of distributions on Y_⊥ indexed by X × Y;
* for a stateless κ and m ≥ 0, the *budgeted* rule κ^{≤m}: apply κ at call j if fewer than m replacements have happened before call j, and pass y_j := y′_j otherwise. κ^{≤m} makes at most m replacements on every path, and κ^{≤m} ∈ 𝓡_tr.

**Proposition 3.4 (in what sense the imitator's run is a run of the human system with the unfaithful calls replaced). PROVED.** Let C be a kernel. For x ∈ X let γ_x be the maximal coupling of C(·|x) and P(·|x), and κ_C(y | x, y′) := γ_x(y, y′)/P(y′|x) for P(y′|x) > 0.

(a) The run of the human system corrupted by the stateless rule κ_C has law Q_C.

(b) Given the past, a replacement happens at call j with probability TV(C, P)(x_j). The expected number of replacements is β(C).

(c) Conversely, for every stateless κ the corrupted run has law Q_{C_κ}, where C_κ(y|x) := Σ_{y′} P(y′|x)·κ(y|x, y′), and its expected number of replacements is at least β(C_κ).

(d) If P is a function f, then κ_C(· | x, f(x)) = C(·|x): a replacement at call j is the event that the draw from C(·|x_j) differs from f(x_j), and the corrupted run equals the run τ^f(z, ρ) of the human system on the same (z, ρ) if and only if no replacement happens.

*Proof.* (a), (b): drawing y′_j ~ P(·|x_j) and then y_j ~ κ_C(·|x_j, y′_j) is drawing the pair from γ_{x_j}; this is the construction of Lemma 3.2 with A = C, B = P. (c) Given h_j the passed answer has law C_κ(·|x_j), so the run has law Q_{C_κ}; the pair (y_j, y′_j) is a coupling of C_κ(·|x_j) and P(·|x_j), so it differs with conditional probability at least their total variation (Lemma 3.1). (d) γ_x(y, f(x)) = C(y|x). ∎

*What the statement does not say.* For a stochastic human, after the first replacement the inputs differ from those of the uncorrupted run on the same (z, ρ) and the same human coins, and the later shadow answers are fresh human answers to the new inputs. So "a run of the human system in which the unfaithful calls have been replaced" is true for the corrupted human system of Definition 3.3, and false if read as "the human system's run on the same randomness with some entries overwritten", except for a deterministic human (part (d)), where a run with N replacements is the scaffold's run on (z, ρ) with f's answer overwritten at N calls.

## 4. Lemma L3 (Bayes regret on adaptive questions)

**Setting 4.0.** Rounds t = 1, 2, …. 𝓖_t is the σ-algebra of everything realised before the human's answer of round t, and 𝓕_t the σ-algebra of everything realised up to the end of round t; 𝓕_{t−1} ⊆ 𝓖_t ⊆ 𝓕_t. In round t there are an indicator a_t ∈ {0, 1} ("a question is asked") and an input x_t ∈ X, both 𝓖_t-measurable and otherwise arbitrary (any function of the earlier pairs and of any randomness; no computability). If a_t = 1 the human answers y_t with Pr[y_t = · | 𝓖_t] = P(·|x_t) (H1) and D_t := D_{t−1} + (x_t, y_t); if a_t = 0, D_t := D_{t−1}. D₀ here is the empty list. Put

  κ_t := KL(P ‖ M_{D_{t−1}})(x_t),  Z_t := ln( P(y_t|x_t) / M_{D_{t−1}}(y_t|x_t) ) on {a_t = 1}.

The hypotheses may be semimeasures and W = Σ w may be less than 1. κ_t is the divergence between probability distributions on Y_⊥ (P gives ⊥ mass 0), so κ_t ≥ 0.

**Lemma 4.1 (L3). PROVED.**

(i) Almost surely, for all n: P(D_n) > 0 and Σ_{t≤n} a_t Z_t = ln( W·P(D_n)/ξ(D_n) ) ≤ ln(W/w(P)).

(ii) Each a_t Z_t is integrable, E[a_t Z_t | 𝓖_t] = a_t κ_t, and κ_t ≤ ln(1/w_{D_{t−1}}(P)) < ∞ almost surely.

(iii) Σ_{t=1}^∞ E[a_t κ_t] ≤ ln(W/w(P)) ≤ ln(1/w(P)) = K ln 2.

*Proof.* (i) Pr[a_t = 1, P(y_t|x_t) = 0 | 𝓖_t] = 0, so almost surely every recorded answer has positive probability under P; then P(D_n) > 0 and ξ(D_n) ≥ w(P)·P(D_n) > 0 for all n. By Definition 1.2, M_{D_{t−1}}(y_t|x_t) = ξ(D_t)/ξ(D_{t−1}) on {a_t = 1}, so the product of these factors over the asked rounds t ≤ n telescopes to ξ(D_n)/W, while the product of the factors P(y_t|x_t) is P(D_n). The inequality is ξ(D_n) ≥ w(P)·P(D_n).

(ii) On {a_t = 1}, given 𝓖_t, y_t has law P(·|x_t) and M_{D_{t−1}}(·|x_t) restricted to Y is a sub-probability, so E[Z_t⁻ | 𝓖_t] ≤ 1/e by (E1). Hence E[Z_t | 𝓖_t] is well defined in (−∞, ∞] and equals Σ_y P(y|x_t) ln(P(y|x_t)/M_{D_{t−1}}(y|x_t)) = κ_t, which is finite by (1.1). For integrability, let S_t := Σ_{s≤t} a_s Z_s and C := ln(W/w(P)). By (i), S_t ≤ C almost surely for every t, so a_t Z_t = S_t − S_{t−1} ≤ C + Σ_{s<t} (a_s Z_s)⁻, and the right side is integrable because each (a_s Z_s)⁻ has expectation at most 1/e. So (a_t Z_t)⁺ and (a_t Z_t)⁻ are both integrable.

(iii) By (ii) and because a_t is 𝓖_t-measurable, Σ_{t≤n} E[a_t κ_t] = Σ_{t≤n} E[a_t Z_t] = E[S_n] ≤ C. Let n → ∞; the terms are nonnegative. ∎

**Lemma 4.2 (L3 for a function). PROVED.** Let P be a function f and e_t := 1 − M_{D_{t−1}}(f(x_t)|x_t). On every path and for every n,

  Π_{t≤n, a_t=1} (1 − e_t) = ξ(D_n)/W ≥ w(f)/W,

hence Σ_{t: a_t=1} e_t ≤ Σ_{t: a_t=1} −ln(1 − e_t) ≤ ln(W/w(f)) ≤ K ln 2, and for ε ∈ (0, 1) at most ln(W/w(f))/(−ln(1 − ε)) asked rounds have e_t ≥ ε.

*Proof.* Every data list that can arise has f(D_n) = 1, so ξ(D_n) ≥ w(f) > 0 and no exceptional set is needed; the product telescopes as in 4.1(i); then (E2). ∎

**Lemma 4.3 (high-probability forms). NEW.** In Setting 4.0 write E_{t−1} := E[· | 𝓕_{t−1}]. For every n and δ ∈ (0, 1), with probability at least 1 − δ:

(a) if P is a function f: Σ_{t≤n} E_{t−1}[a_t e_t] ≤ ln(W/w(f)) + ln(1/δ);

(b) in general: Σ_{t≤n} E_{t−1}[a_t·H²(P, M_{D_{t−1}})(x_t)] ≤ ½·ln(W/w(P)) + ln(1/δ).

*Proof.* Put c := 1 in case (a) and c := ½ in case (b), ψ_t := exp(−c·a_t Z_t) ∈ (0, ∞) and m_t := E_{t−1}[ψ_t]. In case (a), Z_t = −ln(1 − e_t) is 𝓖_t-measurable and ψ_t = 1 − a_t e_t, so m_t = 1 − E_{t−1}[a_t e_t]. In case (b), E[ψ_t | 𝓖_t] = 1 − a_t + a_t Σ_y √(P(y|x_t)·M_{D_{t−1}}(y|x_t)) = 1 − a_t H²(P, M_{D_{t−1}})(x_t), so m_t = 1 − E_{t−1}[a_t H²(…)]. In both cases 0 < m_t ≤ 1. The process G_n := Π_{t≤n} ψ_t/m_t is a nonnegative martingale for (𝓕_n) with mean 1, so Pr[G_n ≥ 1/δ] ≤ δ by Markov's inequality. On the complement, Σ_{t≤n} −ln m_t < c·Σ_{t≤n} a_t Z_t + ln(1/δ) ≤ c·ln(W/w(P)) + ln(1/δ) by 4.1(i), and −ln m_t ≥ 1 − m_t by (E2). ∎

(With the maximal inequality for nonnegative martingales in place of Markov's inequality the statement holds for all n simultaneously. Part (b) is the form used in the imitation-learning literature, where it is Lemma A.14 of Foster, Kakade, Qian and Rakhlin 2021 according to `understand/imitation-theory.md`; I did not open that paper. The proof above is self-contained.)

**Remark 4.4.** (a) *Infinite divergences.* KL(P ‖ M_D)(x) is finite on every data list that can arise, by (1.1). KL(P ‖ ν)(x) can be infinite for single hypotheses ν; this plays no role when P ∈ H.

(b) *Normalising the mixture.* If M_D(⊥|x) < 1, the sampler M^norm_D(y|x) := M_D(y|x)/(1 − M_D(⊥|x)) satisfies KL(P ‖ M^norm_D)(x) = KL(P ‖ M_D)(x) + ln(1 − M_D(⊥|x)) ≤ KL(P ‖ M_D)(x). So 4.1(iii) holds with M^norm in the definition of κ_t (the posterior weights are still computed from the unnormalised likelihoods), and every statement of Sections 5 to 10 holds for the protocol that uses M^norm both to drive the rehearsal runs and as the deployed imitator. The imitator then never answers ⊥.

(c) *Without realisability* (not used below). If P ∉ H, then for every ν ∈ H with Σ_t E[a_t KL(P ‖ ν)(x_t)] < ∞ the same computation, with ξ(D_n) ≥ w(ν)·ν(D_n), gives Σ_t E[a_t κ_t] ≤ ln(W/w(ν)) + Σ_t E[a_t KL(P ‖ ν)(x_t)]. Under Protocol R the second term is the comparator's divergence on the inputs that the mixtures' runs visit, which no assumption of the candidate theory controls.

<!-- END -->
