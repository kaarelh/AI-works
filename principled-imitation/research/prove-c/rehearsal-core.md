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
* **Change of notation 1.** The candidate theory uses T both for the number of calls of a run (Section 1) and for the uniformly random round (Protocol R). Following `research/outline.md`, **T** is the uniformly chosen round whose mixture is deployed, and the deployed imitator is M^(T). The number of calls of a run τ is written **len(τ)**, or len when the run is clear from the context (as in `research/prove-b/hellinger-runs.md`); for the rehearsal run of round t it is len_t.
* **Change of notation 2.** The answer alphabet seen by the scaffold is Y_⊥ := Y ∪ {⊥}. The candidate theory completes a semimeasure by ⊥ but defines next_j only on answers in Y; a mixture of semimeasures can answer ⊥, so next_j and out must be defined there.
* **Change of notation 3.** For a kernel C the functionals Λ(C), β(C) and χ(C) of Definition 1.5 are named; the candidate theory writes them out each time.
* **Change of notation 4.** `note.md` and the candidate theory write m for the number of faults that the human system tolerates, and m again for the number of validation rounds. Following the outline, **m** is the number of validation rounds. The number of tolerated faults is **k** (lower case; K remains the description length of the human in bits).
* TV(p, q) := ½ Σ_y |p(y) − q(y)|; KL(p ‖ q) := Σ_y p(y) ln(p(y)/q(y)) ∈ [0, ∞], with 0·ln(0/·) = 0 and KL = ∞ if p(y) > 0 = q(y) for some y; H²(p, q) := 1 − Σ_y √(p(y)q(y)) (the convention of L4). For kernels, TV(C, C′)(x) abbreviates TV(C(·|x), C′(·|x)), and so on.
* Two elementary inequalities are used repeatedly. (E1) For a probability p and a sub-probability q on a countable set, Σ_y p(y)·(ln(q(y)/p(y)))⁺ ≤ 1/e, because (ln u)⁺ ≤ u/e for u > 0. (E2) 1 − u ≤ −ln u for u ∈ (0, 1].

## 1. Setting

**Definition 1.1 (kernels).** X and Y are countable sets. A *kernel* is a map C that assigns to every x ∈ X a probability distribution C(·|x) on Y_⊥. A *sampler* is a kernel with C(⊥|x) = 0 for all x. A *hypothesis* is a conditional semimeasure ν(y|x) ≥ 0 with Σ_{y∈Y} ν(y|x) ≤ 1; it is identified with the kernel that gives ⊥ the missing mass, ν(⊥|x) := 1 − Σ_{y∈Y} ν(y|x) ("no answer"). The human is a sampler P (assumption A1). A function f: X → Y is the sampler δ_{f(x)}.

**Definition 1.2 (class, posterior, mixture).** H is a countable set of hypotheses with weights w(ν) > 0, W := Σ_ν w(ν) ≤ 1, and P ∈ H (assumption A2). A *data list* D is a finite sequence of pairs (x_i, y_i) ∈ X × Y; D + (x, y) is D with one pair appended. Put ν(D) := Π_i ν(y_i|x_i) (a repeated input is counted every time) and ξ(D) := Σ_ν w(ν)·ν(D), so ξ(∅) = W. If ξ(D) > 0 the *posterior* is w_D(ν) := w(ν)ν(D)/ξ(D) and the *mixture* is the kernel

  M_D(y|x) := Σ_ν w_D(ν)·ν(y|x) = ξ(D + (x, y))/ξ(D) for y ∈ Y,  M_D(⊥|x) := 1 − Σ_{y∈Y} M_D(y|x).

If ξ(D) = 0 put M_D := M_∅ (this case has probability 0 below). Since P ∈ H: M_D(y|x) ≥ w_D(P)·P(y|x), hence

  KL(P ‖ M_D)(x) ≤ ln(1/w_D(P)) < ∞ whenever P(D) > 0.  (1.1)

**Definition 1.3 (scaffold, run).** A *scaffold* Π of horizon L ≥ 1 consists of: a countable set Z with a distribution D₀ (top-level inputs); a probability space (R, 𝓡, λ) (internal randomness); measurable maps next_j: Z × R × Y_⊥^{j−1} → X ∪ {STOP} for j = 1, …, L, with the convention next_{L+1} := STOP; and a measurable map out on runs. For (z, ρ) and answers y_1, y_2, … the *history before call j* is h_j := (z, ρ, y_1, …, y_{j−1}), the *input of call j* is x_j := next_j(h_j), and the *number of calls* is

  len := min{ j ≥ 0 : next_{j+1}(h_{j+1}) = STOP } ∈ {0, …, L}.

So {j ≤ len} is determined by h_j: len is a stopping time for the histories. A *run* is τ = (z, ρ, y_1, …, y_len); its inputs x_1, …, x_len are functions of τ, and we write len(τ) for its number of calls. The set of runs is called 𝒯.

**Definition 1.4 (answerers, run law).** An *answerer* A is a family of probability distributions A_j(·|h_j) on Y_⊥, measurable in h_j, for j ≤ L. A kernel C is the answerer A_j(·|h_j) := C(·|next_j(h_j)); it looks only at x_j. The *run law* Q_A is the distribution of the run obtained by drawing z ~ D₀ and ρ ~ λ independently and then, for j = 1, 2, … while next_j(h_j) ≠ STOP, y_j ~ A_j(·|h_j). In formulas, Q_A has the density Π_{j≤k} A_j(y_j|h_j) at a run with len(τ) = k, with respect to D₀ ⊗ λ ⊗ counting measure. The *human system* is Q_P. An answerer with private memory or private coins has the same run law as the answerer given by its conditional answer laws given h_j, so nothing is lost by Definition 1.4 as far as run laws go.

*Padding.* It is sometimes convenient to give every run exactly L answers: after STOP every answerer answers a fixed symbol ∗ with probability 1. Padding changes no run law, no divergence between run laws, and none of the sums below, because all padded terms are zero.

**Definition 1.5 (three functionals of a kernel).** For a kernel C,

  Λ(C) := E_{Q_C} Σ_{j≤len} KL(P ‖ C)(x_j) ∈ [0, ∞],  β(C) := E_{Q_C} Σ_{j≤len} TV(P, C)(x_j) ∈ [0, L],  χ(C) := E_{Q_C} Σ_{j≤len} H²(P, C)(x_j) ∈ [0, L].

All three are computed along C's own runs. By Proposition 3.4, β(C) is the expected number of unfaithful calls of a run of C. Relations: χ(C) ≤ Λ(C)/2, because H² ≤ KL/2 (for distributions p, q: H² = 1 − Σ√(pq) ≤ −ln Σ√(pq) ≤ −Σ_{p>0} p·ln√(q/p) = KL(p ‖ q)/2, by (E2) and Jensen's inequality). And β(C) ≤ √(2·E_{Q_C}[len]·χ(C)) ≤ √(2L·χ(C)), because TV ≤ √(2H²) (Cauchy–Schwarz: 2·TV = Σ|√p − √q|·(√p + √q) ≤ √(2H²)·√(4 − 2H²)) and by the Cauchy–Schwarz inequality for the measure E_{Q_C} Σ_{j≤len}. For a function f and e_C(x) := 1 − C(f(x)|x): TV(f, C)(x) = e_C(x), KL(f ‖ C)(x) = −ln(1 − e_C(x)) and H²(f, C)(x) = 1 − √(1 − e_C(x)) ≥ e_C(x)/2, so β(C) ≤ Λ(C) by (E2) and β(C) ≤ 2χ(C).

**Assumption 1.6 (H1: fresh answers; this is A1 together with the part of A3 that is used).** Whenever a protocol puts an input x to the human, the answer y satisfies Pr[y = · | 𝓖] = P(·|x), where 𝓖 is the σ-algebra of everything realised before that answer: all earlier questions and answers, and all random choices of the protocol up to then, including those that produced x. The protocol's own random choices (z, ρ, the mixture's draws, the index J, the round T) are made as stated, independently of the past where the protocol says so.

*Remark on A3.* The candidate theory adds that the protocol's coins are "not computable by any hypothesis". For the class of Definition 1.2 this is automatic: a hypothesis is a function of x alone and never sees a coin. The clause would matter only if the string x differed between asked and unasked calls, which Protocol R excludes: the human is shown the same x that the imitator was shown.

## 2. Lemma L1 (chain rule)

**Lemma 2.1 (L1). PROVED.** For answerers A and B (in particular for kernels S, S′),

  KL(Q_A ‖ Q_B) = E_{Q_A} Σ_{j≤len} KL(A_j(·|h_j) ‖ B_j(·|h_j)),

both sides in [0, ∞]. For kernels the summand is KL(S ‖ S′)(x_j).

*Proof.* Pad the runs to L answers. Let Q_A^{(j)} be the law of h_{j+1} = (z, ρ, y_1, …, y_j) under A; Q_A^{(0)} = Q_B^{(0)} = D₀ ⊗ λ. It suffices to prove, for j = 1, …, L,

  KL(Q_A^{(j)} ‖ Q_B^{(j)}) = KL(Q_A^{(j−1)} ‖ Q_B^{(j−1)}) + E_{Q_A}[k(h_j)],  k(h) := KL(A_j(·|h) ‖ B_j(·|h)) ∈ [0, ∞],  (2.1)

and to add up: the padded terms (j > len) are zero because both answerers then answer ∗. Write μ_A, μ_B for the laws of h_j and a(y|h), b(y|h) for A_j, B_j.

Case 1: μ_A is not absolutely continuous with respect to μ_B. Then neither is Q_A^{(j)} with respect to Q_B^{(j)} (take a set N of histories with μ_A(N) > 0 = μ_B(N) and all continuations of it). Both sides of (2.1) are ∞.

Case 2: μ_A ≪ μ_B with density r. With respect to μ_B ⊗ counting measure, Q_A^{(j)} has density r(h)a(y|h) and Q_B^{(j)} has density b(y|h). Let S := {(h, y) : r(h)a(y|h) > 0 = b(y|h)}.

Case 2a: S has positive measure. Then Q_A^{(j)}(S) > 0 = Q_B^{(j)}(S), so the left side is ∞. On the set of histories h that occur in S we have k(h) = ∞, and this set has positive μ_A-measure, so the right side is ∞.

Case 2b: S is a null set. Then Q_A^{(j)} ≪ Q_B^{(j)} with density r(h)a(y|h)/b(y|h), and KL(Q_A^{(j)} ‖ Q_B^{(j)}) = E_{Q_A}[ln r(h_j) + ln(a(y_j|h_j)/b(y_j|h_j))]. The negative parts of the two summands are integrable: ∫ r·(ln(1/r))⁺ dμ_B ≤ 1/e, and E[(ln(a/b))⁻ | h_j] ≤ 1/e by (E1). So the expectation of the sum is the sum of the expectations, each in (−∞, ∞]. The first is KL(μ_A ‖ μ_B). The second equals E_{Q_A}[k(h_j)] by conditioning on h_j (Tonelli for the positive part, Fubini for the integrable negative part). ∎

*Literature.* This is the chain rule for relative entropy (for discrete variables: Cover and Thomas, *Elements of Information Theory*, 2nd ed., Wiley 2006, Theorem 2.5.3; quoted from memory, not opened in this session). The proof above is self-contained and covers the uncountable ρ, the variable length and the value ∞.

## 3. Lemma L2 (coupling) and the notion of an unfaithful call

**Lemma 3.1 (maximal coupling).** Let a, b be probability distributions on a countable set S and t := TV(a, b). Put γ(y, y) := min(a(y), b(y)) and, for y ≠ y′, γ(y, y′) := (a(y) − b(y))⁺·(b(y′) − a(y′))⁺/t if t > 0 (and 0 if t = 0). Then γ is a distribution on S × S with marginals a and b and γ{(y, y′) : y ≠ y′} = t. Every pair of random variables with marginals a and b differs with probability at least t.

*Proof.* Fix y. If a(y) > b(y), then (b − a)⁺(y) = 0, so Σ_{y′≠y} (b − a)⁺(y′) = t and Σ_{y′} γ(y, y′) = b(y) + (a(y) − b(y)) = a(y). If a(y) ≤ b(y), the off-diagonal terms vanish and the sum is min(a(y), b(y)) = a(y). The second marginal is symmetric. The diagonal has mass Σ_y min(a(y), b(y)) = 1 − t. For any coupling, Pr[both equal s] ≤ min(a(s), b(s)); sum over s. ∎

**Lemma 3.2 (L2). PROVED, in the following form.** Let A, B be answerers. Construct (z, ρ) ~ D₀ ⊗ λ and pairs (y_j, y′_j), j = 1, 2, …, as follows: with h_j := (z, ρ, y_1, …, y_{j−1}) and 𝓖_j := σ(z, ρ, (y_i, y′_i)_{i<j}), as long as next_j(h_j) ≠ STOP draw (y_j, y′_j), conditionally on 𝓖_j, from the maximal coupling of A_j(·|h_j) and B_j(·|h_j). Call j ≤ len is *unfaithful* if y_j ≠ y′_j; N is the number of unfaithful calls. Then:

(a) τ := (z, ρ, y_1, …, y_len) has law Q_A, and given 𝓖_j the *shadow answer* y′_j has law B_j(·|h_j): it is B's answer at A's history.

(b) Pr[y_j ≠ y′_j | 𝓖_j] = TV(A_j(·|h_j), B_j(·|h_j)) on {j ≤ len}, hence E N = E_{Q_A} Σ_{j≤len} TV(A_j(·|h_j), B_j(·|h_j)).

(c) On an enlarged probability space there is a run τ̃ with law Q_B and τ̃ = τ on {N = 0}. Hence TV(Q_A, Q_B) ≤ Pr[N ≥ 1] ≤ min(1, E N).

(d) Any other joint construction of a run of A with shadow answers satisfying (a) has Pr[y_j ≠ y′_j | past] ≥ TV(A_j(·|h_j), B_j(·|h_j)): the expected number of unfaithful calls in (b) is the least possible.

*Proof.* (a) and (b) follow from Lemma 3.1 applied conditionally, with the tower property; {j ≤ len} ∈ σ(h_j) by Definition 1.3. (d) is the last sentence of Lemma 3.1 applied conditionally. (c) Let j₁ be the first unfaithful call (j₁ = ∞ if N = 0). Put ỹ_j := y′_j for j ≤ min(j₁, len). If j₁ ≤ len, continue for j > j₁ by drawing ỹ_j from B_j(·|h̃_j) with fresh randomness, where h̃_j := (z, ρ, ỹ_1, …, ỹ_{j−1}), until STOP. For j ≤ j₁ we have h̃_j = h_j, because ỹ_i = y′_i = y_i for i < j₁. So for every j, given everything realised before call j of the new run, ỹ_j has law B_j(·|h̃_j): for j ≤ j₁ by (a), since {j ≤ j₁} ∈ 𝓖_j; for j > j₁ by construction. A run built in this way has law Q_B. If N = 0 then ỹ_j = y_j for all j ≤ len and the two runs stop at the same call. ∎

The candidate theory states "TV(Q_A, Q_B) ≤ that expectation"; (c) is the same with Pr[N ≥ 1] in between. By symmetry the bound also holds with the expectation under Q_B.

**Definition 3.3 (replacement rules; the corrupted human system).** A *replacement rule* r is a family of probability distributions r_j(· | z, ρ, x_1, …, x_j, y′_1, …, y′_j, y_1, …, y_{j−1}) on Y_⊥, measurable in the arguments. The *run of the human system corrupted by r* is produced as follows: draw (z, ρ); for j = 1, 2, …, while x_j := next_j(z, ρ, y_1, …, y_{j−1}) ≠ STOP, the human answers y′_j ~ P(·|x_j) (a fresh draw at the input actually asked, by H1), and the answer passed to the scaffold is y_j ~ r_j(· | …). A *replacement* happens at call j if y_j ≠ y′_j. Classes of rules:

* 𝓡_all: all replacement rules (they see the top-level input, the scaffold's internal randomness, all earlier human answers and their own earlier outputs, and they have private coins);
* 𝓡_tr: the rules that depend on (z, ρ) only through x_1, …, x_j (they see the transcript only);
* 𝓡_st: the *stateless* rules r_j = κ(· | x_j, y′_j), for a family κ of distributions on Y_⊥ indexed by X × Y;
* for a stateless κ and an integer k ≥ 0, the *budgeted* rule κ^{≤k}: apply κ at call j if fewer than k replacements have happened before call j, and pass y_j := y′_j otherwise. κ^{≤k} makes at most k replacements on every path, and κ^{≤k} ∈ 𝓡_tr. The class of all budgeted stateless rules is called 𝓡_bst; so 𝓡_bst ⊆ 𝓡_tr ⊆ 𝓡_all.

**Proposition 3.4 (in what sense the imitator's run is a run of the human system with the unfaithful calls replaced). PROVED.** Let C be a kernel. For x ∈ X let γ_x be the maximal coupling of C(·|x) and P(·|x), and κ_C(y | x, y′) := γ_x(y, y′)/P(y′|x) for P(y′|x) > 0.

(a) The run of the human system corrupted by the stateless rule κ_C has law Q_C.

(b) Given the past, a replacement happens at call j with probability TV(C, P)(x_j). The expected number of replacements is β(C).

(c) Conversely, for every stateless κ the corrupted run has law Q_{C_κ}, where C_κ(y|x) := Σ_{y′} P(y′|x)·κ(y|x, y′), and its expected number of replacements is at least β(C_κ).

(d) If P is a function f, then κ_C(· | x, f(x)) = C(·|x): a replacement at call j is the event that the draw from C(·|x_j) differs from f(x_j), and the corrupted run equals the run τ^f(z, ρ) of the human system on the same (z, ρ) if and only if no replacement happens.

*Proof.* (a), (b): drawing y′_j ~ P(·|x_j) and then y_j ~ κ_C(·|x_j, y′_j) is drawing the pair from γ_{x_j}; this is the construction of Lemma 3.2 with A = C, B = P. (c) Given h_j the passed answer has law C_κ(·|x_j), so the run has law Q_{C_κ}; the pair (y_j, y′_j) is a coupling of C_κ(·|x_j) and P(·|x_j), so it differs with conditional probability at least their total variation (Lemma 3.1). (d) γ_x(y, f(x)) = C(y|x). ∎

*What the statement does not say.* For a stochastic human, after the first replacement the inputs differ from those of the uncorrupted run on the same (z, ρ) and the same human coins, and the later shadow answers are fresh human answers to the new inputs. So "a run of the human system in which the unfaithful calls have been replaced" is true for the corrupted human system of Definition 3.3, and false if read as "the human system's run on the same randomness with some entries overwritten", except for a deterministic human (part (d)), where a run with N replacements is the scaffold's run on (z, ρ) with f's answer overwritten at N calls.

## 4. Lemma L3 (Bayes regret on adaptive questions)

**Setting 4.0.** Rounds t = 1, 2, …. 𝓖_t is the σ-algebra of everything realised before the human's answer of round t, and 𝓕_t the σ-algebra of everything realised up to the end of round t; 𝓕_{t−1} ⊆ 𝓖_t ⊆ 𝓕_t. In round t there are an indicator a_t ∈ {0, 1} ("a question is asked") and an input x_t ∈ X, both 𝓖_t-measurable and otherwise arbitrary (any function of the earlier pairs and of any randomness; no computability). If a_t = 1 the human answers y_t with Pr[y_t = · | 𝓖_t] = P(·|x_t) (H1) and D_t := D_{t−1} + (x_t, y_t); if a_t = 0, D_t := D_{t−1}. Before round 1 the data list is empty (the law of the top-level input, which Definition 1.3 also calls D₀, does not occur in this section). Put

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

*Proof.* Put c := 1 in case (a) and c := ½ in case (b), ψ_t := exp(−c·a_t Z_t) ∈ (0, ∞) and b_t := E_{t−1}[ψ_t]. In case (a), Z_t = −ln(1 − e_t) is 𝓖_t-measurable and ψ_t = 1 − a_t e_t, so b_t = 1 − E_{t−1}[a_t e_t]. In case (b), E[ψ_t | 𝓖_t] = 1 − a_t + a_t Σ_y √(P(y|x_t)·M_{D_{t−1}}(y|x_t)) = 1 − a_t H²(P, M_{D_{t−1}})(x_t), so b_t = 1 − E_{t−1}[a_t H²(…)]. In both cases 0 < b_t ≤ 1. The process G_n := Π_{t≤n} ψ_t/b_t is a nonnegative martingale for (𝓕_n) with mean 1, so Pr[G_n ≥ 1/δ] ≤ δ by Markov's inequality. On the complement, Σ_{t≤n} −ln b_t < c·Σ_{t≤n} a_t Z_t + ln(1/δ) ≤ c·ln(W/w(P)) + ln(1/δ) by 4.1(i), and −ln b_t ≥ 1 − b_t by (E2). ∎

(With the maximal inequality for nonnegative martingales in place of Markov's inequality the statement holds for all n simultaneously. Part (b) is the form used in the imitation-learning literature, where it is Lemma A.14 of Foster, Kakade, Qian and Rakhlin 2021 according to `understand/imitation-theory.md`; I did not open that paper. The proof above is self-contained.)

**Remark 4.4.** (a) *Infinite divergences.* KL(P ‖ M_D)(x) is finite on every data list that can arise, by (1.1). KL(P ‖ ν)(x) can be infinite for single hypotheses ν; this plays no role when P ∈ H.

(b) *Normalising the mixture.* If M_D(⊥|x) < 1, the sampler M^norm_D(y|x) := M_D(y|x)/(1 − M_D(⊥|x)) satisfies KL(P ‖ M^norm_D)(x) = KL(P ‖ M_D)(x) + ln(1 − M_D(⊥|x)) ≤ KL(P ‖ M_D)(x). So 4.1(iii) holds with M^norm in the definition of κ_t (the posterior weights are still computed from the unnormalised likelihoods), and every upper bound of Sections 5 to 10 holds for the protocol that uses M^norm both to drive the rehearsal runs and as the deployed imitator (TV, H² and KL from P to M^norm are at most those from P to M, because P gives ⊥ no mass). The imitator then never answers ⊥.

(c) *Without realisability* (not used below). If P ∉ H, then for every ν ∈ H with Σ_t E[a_t KL(P ‖ ν)(x_t)] < ∞ the same computation, with ξ(D_n) ≥ w(ν)·ν(D_n), gives Σ_t E[a_t κ_t] ≤ ln(W/w(ν)) + Σ_t E[a_t KL(P ‖ ν)(x_t)]. Under Protocol R the second term is the comparator's divergence on the inputs that the mixtures' runs visit, which no assumption of the candidate theory controls.

## 5. Theorem R1, and what the deployed mixture guarantees

**Definition 5.0 (Protocol R: rehearsal).** Fix n ≥ 1. For t = 1, …, n:

1. M^(t) := M_{D_{t−1}}, the mixture given the pairs collected in rounds 1, …, t − 1 (none for t = 1).
2. A run τ_t of Π is generated with the kernel M^(t) answering every call: (z_t, ρ_t) ~ D₀ ⊗ λ and the answers are drawn afresh, independently of the past given M^(t). Nothing is put to the human in this step.
3. J_t is drawn uniformly from {1, …, L}, independently of everything realised so far, including τ_t. If J_t ≤ len_t := len(τ_t), the input x_{t,J_t} of call J_t of τ_t is put to the human, the answer y_t ~ P(·|x_{t,J_t}) is received (H1), and D_t := D_{t−1} + (x_{t,J_t}, y_t). Otherwise D_t := D_{t−1}.

𝓕_t is the σ-algebra of everything realised up to the end of round t. We write a_t := 1[J_t ≤ len_t] and x_t := x_{t,J_t}. *Deployment:* T is uniform on {1, …, n} and independent of 𝓕_n, and Π is run with M^(T). We also write M^(n+1) := M_{D_n} (the mixture "of the last round").

The human answers at most n questions, each a single call. The mixture's own answer at the call that is put to the human plays no role in the update.

**Theorem 5.1 (R1). PROVED.** Assume H1 and P ∈ H. Under Protocol R, for every n:

(a) E[a_t·KL(P ‖ M^(t))(x_t) | 𝓕_{t−1}] = Λ(M^(t))/L for every t, and

  Σ_{t=1}^{n} E[Λ(M^(t))] ≤ L·ln(W/w(P)) ≤ L·K ln 2.

(b) E[a_t·H²(P, M^(t))(x_t) | 𝓕_{t−1}] = χ(M^(t))/L, and Σ_{t≤n} E[χ(M^(t))] ≤ (L/2)·ln(W/w(P)).

(c) If P is a function f and e_t := 1 − M^(t)(f(x_t)|x_t): on every path Σ_{t≤n: a_t=1} e_t ≤ ln(W/w(f)); E[a_t e_t | 𝓕_{t−1}] = β(M^(t))/L; and Σ_{t≤n} E[β(M^(t))] ≤ L·ln(W/w(f)) ≤ L·K ln 2.

(d) The inequalities in (a) and (c) cannot be improved in general: for every L ≥ 1 and w ∈ (0, 1) there are a class of two functions with W = 1 and w(f) = w and a scaffold of horizon L with Σ_{t≤n} E[Λ(M^(t))] = L·ln(1/w) and Σ_{t≤n} E[β(M^(t))] = L·(1 − w) for every n ≥ 1.

*Proof.* (a) Protocol R is an instance of Setting 4.0 with 𝓖_t := σ(𝓕_{t−1}, τ_t, J_t): a_t and x_t are 𝓖_t-measurable, and by H1 the answer has the law P(·|x_t) given 𝓖_t on {a_t = 1}. With κ_t := KL(P ‖ M^(t))(x_t) as in Setting 4.0, Lemma 4.1(iii) gives Σ_t E[a_t κ_t] ≤ ln(W/w(P)), and κ_t is finite by 4.1(ii). Given 𝓕_{t−1} and τ_t, the index J_t is uniform on {1, …, L}, so E[a_t κ_t | 𝓕_{t−1}, τ_t] = (1/L)·Σ_{j≤len_t} KL(P ‖ M^(t))(x_{t,j}). Given 𝓕_{t−1}, the kernel M^(t) is fixed (it is a function of the data list D_{t−1}, which takes countably many values) and τ_t has the law Q_{M^(t)}. Hence E[a_t κ_t | 𝓕_{t−1}] = Λ(M^(t))/L. All quantities are nonnegative, so the expectations may be taken term by term. (b) The same computation with H² in place of KL, and H² ≤ KL/2 (Definition 1.5). (c) The pathwise statement is Lemma 4.2. The conditional expectation is computed as in (a), with TV(f, M^(t))(x) = e_{M^(t)}(x). Finally e_t ≤ −ln(1 − e_t) = κ_t, so the sum of the expectations is at most that in (a).

(d) Let X = {x_1, …, x_L}, Y = {0, 1}, and let the scaffold have no top-level input and no randomness and make call j at x_j for j = 1, …, L. Let f ≡ 1 and g ≡ 0 with w(f) = w and w(g) = 1 − w. Then M^(1)(1|x) = w for every x, so Λ(M^(1)) = L·ln(1/w) and β(M^(1)) = L·(1 − w). Every run has L calls, so round 1 puts a question to the human; the answer is 1 and gives g the likelihood 0. Hence M^(t) = f, and Λ(M^(t)) = β(M^(t)) = 0, for all t ≥ 2. ∎

*What Theorem 5.1 does not say.* It bounds a sum over the rounds and says nothing about a single round (Section 6). It concerns the frozen kernels M^(t) along their own runs: step 2 must be driven by M^(t) alone, and the bound says nothing about M^(t) on inputs that its own runs do not visit. The constant is ln(1/w(P)): the statement is empty for n below L·K ln 2.

*Literature.* The inequality of Lemma 4.1 is the standard regret bound for Bayes mixtures; `understand/repo.md` (items A6, A7, C2) reports the versions of the repository's first paper with adaptively chosen inputs. Protocol R with a finite class under the uniform prior and a deterministic human is, according to `understand/imitation-theory.md` (Section 3.5), the algorithm "Stagger" of Li and Zhang (2025), whose theorem is the high-probability form of (c) combined with a recoverability assumption; see Section 17.

**Proposition 5.2 (deploying the mixture of a uniformly chosen round). PROVED; (b), (c) NEW.** Under the assumptions of Theorem 5.1:

(a) *In expectation.* E[Λ(M^(T))] ≤ L·ln(W/w(P))/n ≤ L·K ln 2/n and E[χ(M^(T))] ≤ L·ln(W/w(P))/(2n). If P is a function f, E[β(M^(T))] ≤ L·ln(W/w(f))/n.

(b) *A fresh round for every run.* Let every deployed run draw its own round (independent, uniform on {1, …, n}) and be answered throughout by the mixture of that round. Conditionally on 𝓕_n the deployed runs are independent with the common law Q̄ := (1/n)·Σ_{t≤n} Q_{M^(t)}, and the expected number of unfaithful calls of a deployed run is β̄ := (1/n)·Σ_{t≤n} β(M^(t)). If P is a function f, then for every δ ∈ (0, 1), with probability at least 1 − δ over the rehearsal,

  β̄ ≤ L·(ln(W/w(f)) + ln(1/δ))/n.

In general, with probability at least 1 − δ over the rehearsal, χ̄ := (1/n)·Σ_{t≤n} χ(M^(t)) ≤ L·(½·ln(W/w(P)) + ln(1/δ))/n and β̄ ≤ √(2L·χ̄) ≤ L·√((ln(W/w(P)) + 2·ln(1/δ))/n).

(c) *One round for good.* Let T be drawn once and M^(T) be used for every later run. For every δ ∈ (0, 1), with probability at least 1 − δ over the rehearsal and T: Λ(M^(T)) ≤ L·ln(W/w(P))/(n·δ). If P is a function f, then for δ₁, δ₂ ∈ (0, 1), with probability at least 1 − δ₁ − δ₂: β(M^(T)) ≤ L·(ln(W/w(f)) + ln(1/δ₁))/(n·δ₂).

(d) *The factor 1/δ in (c) is needed.* For every n ≥ 1 and δ ∈ [1/n, 1] there are a class of two functions with K = 1 and a scaffold with L = 1 such that β(M^(T)) = 1/(2δn) with probability at least (1 − e^(−1/δ))·δ ≥ 0.63·δ. So no bound of the form "β(M^(T)) ≤ φ(δ)·L·K ln 2/n with probability 1 − δ" holds with φ(δ) < 0.45/δ.

*Proof.* (a) E[Λ(M^(T))] = (1/n)·Σ_t E[Λ(M^(t))], and likewise for χ and β; then Theorem 5.1. (b) Given 𝓕_n the kernels M^(1), …, M^(n) are fixed, and each deployed run uses its own round, top-level input, randomness and draws; this gives the independence and the law Q̄. Given 𝓕_n and the round t of a run, its expected number of unfaithful calls is β(M^(t)) (Proposition 3.4(b)); average over t. For a function, Lemma 4.3(a) says that with probability at least 1 − δ, Σ_{t≤n} E[a_t e_t | 𝓕_{t−1}] ≤ ln(W/w(f)) + ln(1/δ), and the left side is n·β̄/L by Theorem 5.1(c). In general, Lemma 4.3(b) and Theorem 5.1(b) give the bound on χ̄ in the same way; β(M^(t)) ≤ √(2L·χ(M^(t))) by Definition 1.5, and the square root is concave, so β̄ ≤ √(2L·χ̄). (c) Markov's inequality for Λ(M^(T)) ≥ 0, whose mean is bounded in (a). For the second statement, the event of (b) with δ₁ has probability at least 1 − δ₁ and depends on 𝓕_n only; given 𝓕_n, Pr[β(M^(T)) > β̄/δ₂] ≤ δ₂ by Markov's inequality over T.

(d) Let X = {x₀, x₁}, Y = {0, 1}, q := 1/(δn) ≤ 1, and let the scaffold make one call, at x₁ with probability q and at x₀ otherwise. Let f ≡ 0 and let g agree with f at x₀ and answer 1 at x₁, with w(f) = w(g) = ½. Every round puts its call to the human, and x₁ is asked in each round with probability q independently. As long as x₁ has not been asked, β(M^(t)) = q/2; afterwards it is 0. So Pr[β(M^(T)) = q/2] = (1/n)·Σ_{t≤n} (1 − q)^(t−1) = (1 − (1 − q)^n)/(qn) ≥ δ·(1 − e^(−1/δ)), and q/2 = 1/(2δn). If a bound φ(δ′)·ln 2/n held with probability 1 − δ′ for all δ′, then with δ′ := 0.63·δ we would need φ(δ′)·ln 2 ≥ 1/(2δ), that is φ(δ′) ≥ 0.63/(2 ln 2·δ′) > 0.45/δ′. ∎

*What Proposition 5.2 does not say.* The guarantee in (b) is for runs each of which is answered by the mixture of a single round. It does not cover an imitator that draws a new round at every call (Proposition 5.4). A statement with ln(1/δ) in place of 1/δ for a single frozen imitator is obtained by validation (Section 13), not by the choice of the round.

**Proposition 5.3 (more than one question in a rehearsal run). MODIFIED (this replaces Remark (i) of the candidate theory).** Protocol R⁺ is Protocol R with step 3 changed as follows: after the question at call J_t (if J_t ≤ len_t), further calls of the same run τ_t may be put to the human, chosen by any rule that may depend on everything realised so far; all pairs received are added to the data, and M^(t+1) is the mixture given all of them.

(a) Theorem 5.1 holds for Protocol R⁺ as stated.

(b) The extra questions do not improve the bound, and they can multiply the number of answers by L for nothing. In the example of Theorem 5.1(d), Protocol R⁺ with every call asked has Σ_t E[Λ(M^(t))] = L·ln(1/w), the same as Protocol R. If the human and all members of H are functions and the scaffold makes all its L calls at one input (for example z uniform on a finite set Z ⊆ X and x_j = z for all j), then Protocol R⁺ with every call asked produces, round by round, the same mixtures as Protocol R and uses L times as many answers.

(c) The sum of the divergences of the frozen mixture over all the questions of a round is not bounded by the regret. If every call of every rehearsal run is asked, then E[Σ_{t≤n} Σ_{j≤len_t} KL(P ‖ M^(t))(x_{t,j})] = Σ_t E[Λ(M^(t))], which equals L·ln(1/w(P)) in the example of Theorem 5.1(d). Lemma 4.1 bounds by ln(W/w(P)) the sum, over the same questions, of the divergences of the mixture that is updated after every answer.

*Proof.* (a) Order the questions of round t with the question at call J_t first, and apply Lemma 4.1 to the sequence of all questions in this order; Setting 4.0 allows any rule for choosing the questions. All terms of Lemma 4.1(iii) are nonnegative. Keep the first question of each round only: the data list before it is D_{t−1}, so its term is a_t·KL(P ‖ M^(t))(x_t), and its conditional expectation given 𝓕_{t−1} is Λ(M^(t))/L as in the proof of Theorem 5.1. Parts (b) and (c) of Theorem 5.1 follow in the same way. (b) In the example of 5.1(d) the first answer of round 1 already identifies f, under either protocol. In the second example the L pairs of a round are L copies of (z, f(z)), and a function has likelihood 1 on L copies of a pair if it has likelihood 1 on one copy, and likelihood 0 otherwise; so the posterior after a round is the same under both protocols. (c) If every call is asked, the sum over the questions of round t of the divergences of the frozen mixture is Σ_{j≤len_t} KL(P ‖ M^(t))(x_{t,j}), whose conditional expectation given 𝓕_{t−1} is Λ(M^(t)); in the example of 5.1(d) the sum over the rounds is L·ln(1/w). ∎

*Remarks.* (i) In the candidate theory, Remark (i) reads "one question per rehearsal run is what the proof uses; more questions per run are harmless extra data". By (a) they are harmless for the bound, provided that one question of each round is at a uniformly chosen call that is chosen independently of the run. By (b) they are not useful for the bound, and by (c) the proof of Theorem 5.1 cannot be changed so as to profit from them while the mixture stays frozen during the run. Section 12 of the candidate theory records the same obstacle (a sum of divergences of marginals is not bounded by the divergence of the joint law); the output of `rehearsal-core_r1_exact.py` in Section 16 shows the numbers. (ii) An improvement per round is possible only if the mixture is updated inside the run; that is the online form of Section 10, which has the same price per answer.

**Definition 5.4 (the averaged kernel).** M̄ := (1/n)·Σ_{t≤n} M^(t), that is M̄(y|x) := (1/n)·Σ_{t≤n} M^(t)(y|x). An imitator that draws a new round (uniform, independent) at every call and answers that call with the mixture of that round is, given 𝓕_n, the kernel M̄, because given the history its answer at input x has the law (1/n)·Σ_t M^(t)(·|x). Its run has the law Q_{M̄}, which in general differs from the law Q̄ of Proposition 5.2(b).

**Proposition 5.5 (a new round at every call is not covered). NEW.** Let P be a function f. For a kernel C let u(C) be the probability that a run of C is not the run τ^f(z, ρ) of the human system on the same (z, ρ) (Proposition 3.4(d)); so u(C) ≤ β(C).

(a) u(M̄) ≤ (L/n)·Σ_{t≤n} u(M^(t)) ≤ L·β̄, hence under Protocol R: E[u(M̄)] ≤ L²·ln(W/w(f))/n.

(b) The factor L in (a) is attained up to a constant. For every L ≥ 2 and p ∈ (0, 1) there are a class of 2^L functions with weights of total 1, a member f with ln(1/w(f)) = L·ln(1/p), and a scaffold of horizon L, such that under Protocol R, for every n ≥ L²,

  E[u(M̄)] = E[β(M̄)] ≥ (1 − p)²·(L³/(2n) − L⁶/n²),  while  E[u(M^(T))] = E[β(M^(T))] ≤ min{ln(1/p), 1}·L²/n.

For n ≥ 4L³ the left quantity is at least (1 − p)²·L³/(4n), which is (1 − p)²·L/(4·ln(1/p)) times the bound L·ln(1/w(f))/n of Proposition 5.2(a) (0.09·L times for p = ½), and at least (1 − p)²·L/4 times E[β(M^(T))].

*Proof.* (a) Fix (z, ρ) and let x^f_1, …, x^f_len be the inputs of τ^f(z, ρ). A run of a kernel C on (z, ρ) equals τ^f(z, ρ) if and only if its answer at x^f_j is f(x^f_j) for every j, so the conditional probability of this is π_C := Π_j (1 − e_C(x^f_j)), and u(C) = E[1 − π_C]. Since e_{M̄} = (1/n)·Σ_t e_{M^(t)} and 1 − Π_j (1 − e_j) ≤ Σ_j e_j,

  1 − π_{M̄} ≤ Σ_j e_{M̄}(x^f_j) = (1/n)·Σ_t Σ_j e_{M^(t)}(x^f_j) ≤ (1/n)·Σ_t L·max_j e_{M^(t)}(x^f_j) ≤ (L/n)·Σ_t (1 − π_{M^(t)}),

because 1 − Π_j (1 − e_j) ≥ max_j e_j. Take the expectation over (z, ρ), then use u ≤ β and Proposition 5.2(a).

(b) *The ladder.* X = {x_1, …, x_L}, Y = {0, 1}. The scaffold has no top-level input and no randomness: call 1 is at x_1, and next_j(y_1, …, y_{j−1}) is x_j if y_1 = … = y_{j−1} = 0 and STOP otherwise. The class consists of the functions h_s, s ∈ {0, 1}^L, with h_s(x_j) = s_j and w(h_s) := Π_j p^(1−s_j)·(1 − p)^(s_j); f := h_{0…0}, so w(f) = p^L. After any data the posterior is a product: with A ⊆ {1, …, L} the set of indices j for which x_j has been asked (the answer is f(x_j) = 0), the mixture answers 0 at x_j with probability 1 if j ∈ A and with probability p if j ∉ A. A run stops at its first answer 1, so it has at most one unfaithful call and u(C) = β(C) for every kernel C.

Let A_{t−1} be the set A at the start of round t and u_t := L − |A_{t−1}|. The run of M^(t) is faithful with probability p^(u_t), so β(M^(t)) = 1 − p^(u_t). In round t the index j ∉ A_{t−1} is added to A if and only if J_t = j and the run answers 0 at all x_i with i < j, i ∉ A_{t−1}. The members of {1, …, L} ∖ A_{t−1}, in increasing order, have 0, 1, …, u_t − 1 predecessors outside A_{t−1}, so

  E[u_t − u_{t+1} | 𝓕_{t−1}] = (1/L)·Σ_{i=0}^{u_t−1} p^i = (1 − p^(u_t))/(L·(1 − p)) ≤ 1/(L·(1 − p)).  (5.1)

*The averaged kernel.* Let N_j := #{t ≤ n : j ∉ A_{t−1}}. Then M̄(1|x_j) = (1 − p)·N_j/n, and with S := Σ_j N_j = Σ_{t≤n} u_t,

  β(M̄) = 1 − Π_j (1 − (1 − p)·N_j/n) ≥ (1 − p)·S/n − (1 − p)²·S²/(2n²),

by the inequality 1 − Π_j (1 − a_j) ≥ Σ_j a_j − Σ_{i<j} a_i a_j ≥ Σ_j a_j − ½·(Σ_j a_j)² for a_j ∈ [0, 1] (Bonferroni's inequality for independent events of probabilities a_j). By (5.1), E[u_t] ≥ L − (t − 1)/(L·(1 − p)), and u_t ≥ 0. The function g(s) := (L − s/(L·(1 − p)))⁺ is nonincreasing and vanishes from s₀ := L²·(1 − p) on, so for n ≥ L²,

  E[S] ≥ Σ_{t=1}^{n} g(t − 1) ≥ ∫_0^{s₀} g(s) ds = L·s₀ − s₀²/(2L·(1 − p)) = (1 − p)·L³/2.

For the second moment, let ξ_t := 1[J_t = min({1, …, L} ∖ A_{t−1})] if u_t ≥ 1 and ξ_t := 1[J_t = 1] if u_t = 0. Given 𝓕_{t−1} the index J_t is uniform, so the ξ_t are independent with Pr[ξ_t = 1] = 1/L. If u_t ≥ 1 and ξ_t = 1, the run of M^(t) reaches the least index outside A_{t−1} with probability 1 (all earlier inputs have been asked), so that index is added and u_{t+1} ≤ u_t − 1. Hence u_t = 0 for every t after the L-th round with ξ = 1; call that round R. R is a sum of L independent geometric variables with parameter 1/L, so E[R] = L², Var[R] ≤ L³ and E[R²] ≤ L⁴ + L³ ≤ 2L⁴. Since S ≤ L·R, E[S²] ≤ 2L⁶. Together: E[β(M̄)] ≥ (1 − p)²·L³/(2n) − (1 − p)²·L⁶/n².

*A round per run.* E[β(M^(T))] = (1/n)·Σ_{t≤n} E[1 − p^(u_t)] ≤ E[min(R, n)]/n ≤ L²/n, and E[β(M^(T))] ≤ L·ln(1/w(f))/n = L²·ln(1/p)/n by Proposition 5.2(a). ∎

*Reading.* In the ladder each mixture M^(t) stops, with probability 1 − p, at the first input it has not learned, and so rarely reaches the later ones. The averaged kernel answers the early inputs correctly most of the time, reaches the later inputs, and there mixes in the many rounds in which they had not been learned. The functional β(C) is not convex in C, because the inputs along which it is computed depend on C. Simulation output: Section 16.

*What remains open here.* Part (a) bounds the probability that the run of M̄ is unfaithful. For the expected number of unfaithful calls of M̄ this file has only β(M̄) ≤ L·u(M̄). The case of a human who is not deterministic is not treated.
