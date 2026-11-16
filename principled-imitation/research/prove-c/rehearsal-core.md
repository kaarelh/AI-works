# rehearsal-core: the rehearsal protocol (L1–L3, R1, R2 for a deterministic human, R3, R3a, V1)

Part "rehearsal-core" of the check of `research/candidate-theory.md` (version 2 and its Section 13) and of Sections 1 to 3 of `note.md`. Sections 0 to 4 were written by an earlier worker (`research/prove/rehearsal-core.md`) and are kept, with the notation brought into line with `research/outline.md`; Sections 5 to 17 were written in this round. Everything is meant to be checked line by line. Tags: **PROVED** (a statement of the candidate theory or of the note, proved as stated or in the stated precise form), **MODIFIED** (the statement needed a change, which is named), **REFUTED** (with counterexample), **OPEN**, and **NEW** (a statement that is in neither, proved here). Nothing here has been refereed.

## Summary table

| no. | statement | tag |
|---|---|---|
| 2.1 | L1, chain rule for runs of variable length, values in [0, ∞] | PROVED |
| 3.1 | maximal coupling of two distributions | PROVED (standard) |
| 3.2 | L2, coupling: E[number of unfaithful calls] = E_{Q_A} Σ_j TV, and TV(Q_A, Q_B) ≤ Pr[some call unfaithful] | PROVED (slightly sharper) |
| 3.4 | "the imitator's run is a run of the human system with the unfaithful calls replaced": exact sense, by a stateless randomised replacement rule | PROVED (sense made precise) |
| 4.1 | L3, Bayes regret on adaptive questions, with semimeasures, sub-probability weights, skipped rounds, all integrability | PROVED |
| 4.2 | L3 for a function: Π_t (1 − e_t) ≥ w(f)/W on every path | PROVED |
| 4.3 | high-probability forms: Σ_t E_{t−1}[a_t e_t] ≤ K ln 2 + ln(1/δ) (function); Σ_t E_{t−1}[a_t H²_t] ≤ (K ln 2)/2 + ln(1/δ) (general) | NEW |
| 5.1 | R1: Σ_{t≤n} E Λ(M^(t)) ≤ L·ln(W/w(P)) ≤ L·K ln 2; the forms for H² and for a function; (d) equality is attained | PROVED; (d) NEW |
| 5.2 | deploying M^(T), T a uniformly chosen round: (a) in expectation; (b) a fresh round for every run, with bounds of high probability over the rehearsal; (c) one round for good, by Markov's inequality; (d) the factor 1/δ in (c) is needed | (a) PROVED; (b)–(d) NEW |
| 5.3 | several calls of one rehearsal run put to the human: the bound L·K ln 2 stays, it does not improve, and the sum of the frozen divergences is not bounded by the regret | MODIFIED (Remark (i) of the candidate theory made precise) |
| 5.5 | a new round at every call (the averaged kernel): the probability of an unfaithful run is at most L times larger (a), and a factor of order L occurs (b, the ladder) | NEW |
| 6.1 | last round, scaffold whose inputs do not depend on the answers: (a) deterministic human, E β(M^(n+1)) ≤ L·(K ln 2 + 1)/n; (b) any sampler, if Σ_ν √(w(ν)) < ∞ | NEW (the bound with ln n announced in the first version is improved) |
| 6.2 | last round, divergence: E Λ(M^(n+1)) ≥ ((L − 1)/8)·L·K ln 2/n in an example | PROVED (Remark (iii) of the candidate theory, by example; the reason given there is incomplete) |
| 6.3 | last round, number of unfaithful calls of a deterministic human: E β(M^(n+1)) ≥ ((L − 1)/(40√L))·L·K ln 2/n in an example | NEW (listed as open in the first version) |
| 6.4 | last round, any scaffold, deterministic human: E u(M^(n+1)) ≤ 2L·B₀·(1 + ln(1/(2B₀))) + 2B₀ + 2L/n with B₀ = L·ln(W/w(f))/n, and E β(M^(n+1)) ≤ L times this | NEW |
| 7.1 | R2 for a function: the deployed run is the human system's run on the same (z, ρ) with probability ≥ 1 − L·K ln 2/n; TV(Q_C, Q_f) = Pr[run unfaithful] | PROVED |
| 8.3 | R3 with the robustness curve: failure ≤ δ̄_Π(E β); (d) the concave majorant is needed | PROVED (tagged [?] in the candidate theory); (d) NEW |
| 8.4 | R3: failure ≤ δ + β/(k + 1) if the human system tolerates k faults; tolerance is needed only against budgeted stateless rules when the imitator is a kernel | PROVED, and MODIFIED (weaker hypothesis) |
| 8.5 | examples: equality in R3; the three classes of replacement rules give different notions of tolerance | NEW |
| 8.6 | recoverable form: E cost ≤ E_{Q_P} cost + μ·β, with no Markov step | NEW in this project (the standard form of the literature) |
| 9.1 | any sampler: E β(M^(T)) ≤ L·√(K ln 2/(2n)); R3 with √(K ln 2/(2n))/θ | PROVED |
| 9.2 | every protocol has E β ≥ 0.088·L·√(K/n) for some member of a class with K bits | NEW |
| 9.3 | low stakes with a human who is not deterministic: of the order K/θ² questions are needed in an example, against K/θ for a deterministic human | NEW |
| 10.1 | online form (every call put to the human with probability q): Σ_t E KL ≤ K ln 2/q | PROVED (Observation A of `research/understand/notes.md`) |
| 10.2 | online rehearsal in a closed system has the price of Protocol R | NEW |
| 10.3 | freezing after online rehearsal: the bound of R1 with a factor at most e, and a factor of at least 1.33 does occur | NEW |
| 11 | Remarks (i), (ii), (iii) after R6 of the candidate theory | (i) MODIFIED, (ii) PROVED, (iii) PROVED in the form 6.2, 6.3 (and limited by 6.1, 6.4) |
| 12.1 | Azuma–Hoeffding inequality with conditional ranges | PROVED (standard) |
| 12.2 | R3a, bounded damage: tolerance of k faults whenever k·(1 + D) + √(2L·ln(1/δ)) ≤ η·μ·L | PROVED (the note's constant 8 improved to 2; hypotheses made explicit) |
| 12.3 | the term k·(1 + D) cannot be k·(μ + D), because the rule sees the human's answer; the term of order √L cannot be dropped | NEW |
| 13.1 | V1: (o) the rounds are independent; (a) certificate for a deterministic human; (b) tests, for any human; (c) what is not certified | PROVED; (a2), (b2), (b3), (c) NEW |
| 13.2 | rehearse, validate, deploy: the certificate is issued with probability ≥ 1 − m·K ln 2/n | NEW |
| 14 | open questions of this part | OPEN |

**In brief.** (1) R1, R2 for a deterministic human, R3, R3a and V1 are correct as stated in `note.md`; R3a holds with the constant 2 in place of 8, and R3 needs tolerance only against a smaller class of replacement rules. (2) "Deploy the mixture of a uniformly chosen round" must mean one round per run or one round for good. A new round at every call is a different imitator, and its run can be unfaithful with a probability L times larger. (3) The last mixture can replace the random round on scaffolds whose inputs do not depend on the answers when the human is deterministic, at the price of the additive term L/n. In general it cannot: it can be worse than the bound by a factor of order L in the divergence and of order √L in the number of unfaithful calls. For a deterministic human it is never worse by more than a factor of order L·ln n in the probability of an unfaithful run (L²·ln n in the number of unfaithful calls); whether the probability of an unfaithful run can be worse by more than a constant is open. Validation certifies whichever imitator is deployed, so the choice need not rest on these bounds. (4) For a human who is not deterministic the bound on the number of unfaithful calls is of the order L·√(K/n), and no protocol does better on every class; under low stakes this costs of the order K/θ² questions where a deterministic human costs K/θ, and in an example that many are needed. (5) Putting every call to the human with probability 1/L, online, is the same protocol up to a constant below e. (6) For a deterministic human, validation certifies the expected number of unfaithful calls of any frozen imitator with no assumption on the human beyond A1; for other humans it certifies frequencies of tests, and under A2 also the number of unfaithful calls, at the rate √(K/m).

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

(With the maximal inequality for nonnegative martingales in place of Markov's inequality the statement holds for all n simultaneously. Part (b) is the form used in the imitation-learning literature, where it is Lemma A.14 of Foster, Kakade, Qian and Rakhlin 2021 according to `research/understand/imitation-theory.md`; I did not open that paper. The proof above is self-contained.)

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

*The hypotheses, and why each is needed.* (i) *The index J_t is uniform and independent of the run.* Let L = 2 with call 1 at x_1 and call 2 at x_2, and let g agree with f at x_1 and differ at x_2. If the question were always put at call 1, g would never be refuted, M^(t) would stay the prior mixture, and Λ(M^(t)) = ln(1/w(f)) for every t. (ii) *The run of step 2 is answered by M^(t) alone.* If the rehearsal runs were answered by another kernel C₀, the questions would be calls of runs of C₀, and the same proof would bound the divergences along the runs of C₀; it would say nothing about the inputs that only the runs of M^(t) visit. (iii) *A2.* If H consists of one sampler different from P at the inputs visited, Λ(M^(t)) is a positive constant; Remark 4.4(c) states what remains without A2. (iv) *H1.* The identity of Lemma 4.1(i) holds for whatever answers are given. It becomes a statement about P only because each answer is a fresh draw from P(·|x) given everything before it; a human whose answer depends on the earlier questions, or on whether the call belongs to a rehearsal, is not covered.

*Literature.* The inequality of Lemma 4.1 is the standard regret bound for Bayes mixtures; `research/understand/repo.md` (items A6, A7, C2) reports the versions of the repository's first paper with adaptively chosen inputs. Protocol R with a finite class under the uniform prior and a deterministic human is, according to `research/understand/imitation-theory.md` (Section 3.5), the algorithm "Stagger" of Li and Zhang (2025), whose theorem is the high-probability form of (c) combined with a recoverability assumption; see Section 17.

**Proposition 5.2 (deploying the mixture of a uniformly chosen round). (a) PROVED; (b) to (d) NEW.** Under the assumptions of Theorem 5.1:

(a) *In expectation.* E[Λ(M^(T))] ≤ L·ln(W/w(P))/n ≤ L·K ln 2/n and E[χ(M^(T))] ≤ L·ln(W/w(P))/(2n). If P is a function f, E[β(M^(T))] ≤ L·ln(W/w(f))/n.

(b) *A fresh round for every run.* Let every deployed run draw its own round (independent, uniform on {1, …, n}) and be answered throughout by the mixture of that round. Conditionally on 𝓕_n the deployed runs are independent with the common law Q̄ := (1/n)·Σ_{t≤n} Q_{M^(t)}, and the expected number of unfaithful calls of a deployed run is β̄ := (1/n)·Σ_{t≤n} β(M^(t)). If P is a function f, then for every δ ∈ (0, 1), with probability at least 1 − δ over the rehearsal,

  β̄ ≤ L·(ln(W/w(f)) + ln(1/δ))/n.

In general, with probability at least 1 − δ over the rehearsal, χ̄ := (1/n)·Σ_{t≤n} χ(M^(t)) ≤ L·(½·ln(W/w(P)) + ln(1/δ))/n and β̄ ≤ √(2L·χ̄) ≤ L·√((ln(W/w(P)) + 2·ln(1/δ))/n).

(c) *One round for good.* Let T be drawn once and M^(T) be used for every later run. For every δ ∈ (0, 1), with probability at least 1 − δ over the rehearsal and T: Λ(M^(T)) ≤ L·ln(W/w(P))/(n·δ). If P is a function f, then for δ₁, δ₂ ∈ (0, 1), with probability at least 1 − δ₁ − δ₂: β(M^(T)) ≤ L·(ln(W/w(f)) + ln(1/δ₁))/(n·δ₂).

(d) *The factor 1/δ in (c) is needed.* For every n ≥ 1 and δ ∈ [1/n, 1] there are a class of two functions with K = 1 and a scaffold with L = 1 such that β(M^(T)) = 1/(2δn) with probability at least (1 − e^(−1/δ))·δ ≥ 0.63·δ. So no bound of the form "β(M^(T)) ≤ φ(δ)·L·K ln 2/n with probability 1 − δ" holds with φ(δ) < 0.45/δ.

*Proof.* (a) E[Λ(M^(T))] = (1/n)·Σ_t E[Λ(M^(t))], and likewise for χ and β; then Theorem 5.1. (b) Given 𝓕_n the kernels M^(1), …, M^(n) are fixed, and each deployed run uses its own round, top-level input, randomness and draws; this gives the independence and the law Q̄. Given 𝓕_n and the round t of a run, its expected number of unfaithful calls is β(M^(t)) (Proposition 3.4(b)); average over t. For a function, Lemma 4.3(a) says that with probability at least 1 − δ, Σ_{t≤n} E[a_t e_t | 𝓕_{t−1}] ≤ ln(W/w(f)) + ln(1/δ), and the left side is n·β̄/L by Theorem 5.1(c). In general, Lemma 4.3(b) and Theorem 5.1(b) give the bound on χ̄ in the same way; β(M^(t)) ≤ √(2L·χ(M^(t))) by Definition 1.5, and the square root is concave, so β̄ ≤ √(2L·χ̄). (c) Markov's inequality for Λ(M^(T)) ≥ 0, whose mean is bounded in (a). For the second statement, the event of (b) with δ₁ has probability at least 1 − δ₁ and depends on 𝓕_n only; given 𝓕_n, Pr[β(M^(T)) > β̄/δ₂] ≤ δ₂ by Markov's inequality over T.

(d) Let X = {x₀, x₁}, Y = {0, 1}, q := 1/(δn) ≤ 1, and let the scaffold make one call, at x₁ with probability q and at x₀ otherwise. Let f ≡ 0 and let g agree with f at x₀ and answer 1 at x₁, with w(f) = w(g) = ½. Every round puts its call to the human, and x₁ is asked in each round with probability q independently. As long as x₁ has not been asked, β(M^(t)) = q/2; afterwards it is 0. So Pr[β(M^(T)) = q/2] = (1/n)·Σ_{t≤n} (1 − q)^(t−1) = (1 − (1 − q)^n)/(qn) ≥ δ·(1 − e^(−1/δ)), and q/2 = 1/(2δn). Here L·K ln 2/n = ln 2/n. If β(M^(T)) ≤ φ(δ′)·ln 2/n held with probability at least 1 − δ′, then for δ′ := 0.63·δ < (1 − e^(−1/δ))·δ we would need φ(δ′)·ln 2/n ≥ 1/(2δn), that is φ(δ′) ≥ 0.63/(2 ln 2·δ′) > 0.45/δ′. ∎

*What Proposition 5.2 does not say.* The guarantee in (b) is for runs each of which is answered by the mixture of a single round. It does not cover an imitator that draws a new round at every call (Proposition 5.5). A statement with ln(1/δ) in place of 1/δ for a single frozen imitator is obtained by validation (Section 13), not by the choice of the round.

**Proposition 5.3 (more than one question in a rehearsal run). MODIFIED (this replaces Remark (i) of the candidate theory).** Protocol R⁺ is Protocol R with step 3 changed as follows: after the question at call J_t (if J_t ≤ len_t), further calls of the same run τ_t may be put to the human, chosen by any rule that may depend on everything realised so far; all pairs received are added to the data, and M^(t+1) is the mixture given all of them.

(a) Parts (a) to (c) of Theorem 5.1 hold for Protocol R⁺.

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

For the second moment, let ξ_t := 1[J_t = min({1, …, L} ∖ A_{t−1})] if u_t ≥ 1 and ξ_t := 1[J_t = 1] if u_t = 0. Given 𝓕_{t−1} the index J_t is uniform, so the ξ_t are independent with Pr[ξ_t = 1] = 1/L. If u_t ≥ 1 and ξ_t = 1, the run of M^(t) reaches the least index outside A_{t−1} with probability 1 (all earlier inputs have been asked), so that index is added and u_{t+1} ≤ u_t − 1. Hence u_t = 0 for every t after the L-th round with ξ = 1; call that round R (continue the sequence ξ_t beyond round n by independent coins of the same bias, so that R is always defined). R is a sum of L independent geometric variables with parameter 1/L, so E[R] = L², Var[R] ≤ L³ and E[R²] ≤ L⁴ + L³ ≤ 2L⁴. Since S ≤ L·R, E[S²] ≤ 2L⁶. Together: E[β(M̄)] ≥ (1 − p)²·L³/(2n) − (1 − p)²·L⁶/n².

*A round per run.* E[β(M^(T))] = (1/n)·Σ_{t≤n} E[1 − p^(u_t)] ≤ E[min(R, n)]/n ≤ L²/n, and E[β(M^(T))] ≤ L·ln(1/w(f))/n = L²·ln(1/p)/n by Proposition 5.2(a). ∎

*Reading.* In the ladder each mixture M^(t) stops, with probability 1 − p, at the first input it has not learned, and so rarely reaches the later ones. The averaged kernel answers the early inputs correctly most of the time, reaches the later inputs, and there mixes in the many rounds in which they had not been learned. The functional β(C) is not convex in C, because the inputs along which it is computed depend on C. Simulation output: Section 16.

*What remains open here.* Part (a) bounds the probability that the run of M̄ is unfaithful. For the expected number of unfaithful calls of M̄ this file has only β(M̄) ≤ L·u(M̄). The case of a human who is not deterministic is not treated.

## 6. The last round

Theorem 5.1 bounds a sum over the rounds, and Proposition 5.2 turns it into a statement about the mixture M^(T) of a uniformly chosen round. This section asks what holds for M^(n+1) = M_{D_n}, the mixture that has seen all the answers. The answer: for a deterministic human on a scaffold whose inputs do not depend on the answers, the last round is as good as the random round up to the additive term L/n (Proposition 6.1). In general it is not: the last round can exceed the bound L·K ln 2/n by a factor of order L in the divergence (Proposition 6.2) and by a factor of order √L in the expected number of unfaithful calls of a deterministic human (Proposition 6.3). For a deterministic human there is also an upper bound on every scaffold (Proposition 6.4): the probability u that the run of the last mixture is unfaithful (Theorem 7.1) exceeds the bound of the random round by at most a factor of order L·ln n, and the number of unfaithful calls by at most a factor of order L²·ln n. Whether u can exceed that bound by more than a constant is open: in both examples it stays below it.

**Definition 6.0 (non-adaptive scaffold).** Π is *non-adaptive* if no next_j depends on the answers: next_j(z, ρ, y_1, …, y_{j−1}) = ν_j(z, ρ). Then len and the inputs x_1, …, x_len are functions of (z, ρ). Put d(x) := E #{j ≤ len : x_j = x} (the *visit measure*, the same for every answerer) and q(x) := d(x)/L, so Σ_x q(x) = E[len]/L ≤ 1. For every kernel C: β(C) = L·Σ_x q(x)·TV(P, C)(x) and χ(C) = L·Σ_x q(x)·H²(P, C)(x).

**Proposition 6.1 (last round, non-adaptive scaffold). NEW.** Let Π be non-adaptive, and assume H1 and P ∈ H. Under Protocol R, for every n ≥ 1:

(a) If P is a function f, then E[β(M^(n+1))] ≤ L·(ln(W/w(f)) + 1)/n ≤ L·(K ln 2 + 1)/n.

(b) For any sampler P ∈ H, if S_½ := Σ_ν √(w(ν)) is finite, then E[χ(M^(n+1))] ≤ L·(½·ln(1/w(P)) + ln S_½ + 1)/n and E[β(M^(n+1))] ≤ L·√((ln(1/w(P)) + 2·ln S_½ + 2)/n).

*Proof.* In round t the pair (a_t, x_t) is a function of (z_t, ρ_t, J_t), because the inputs of τ_t do not depend on the answers. So the pairs (a_t, x_t), t ≤ n, are independent and identically distributed, with Pr[a_t = 1, x_t = x] = q(x), and they are independent of all answers of the mixtures.

(a) For ν ∈ H put ε_ν := Σ_x q(x)·(1 − ν(f(x)|x)) ∈ [0, 1]. The likelihood ν(D_n) is the product over the rounds t ≤ n with a_t = 1 of ν(f(x_t)|x_t), so E[ν(D_n)] = (1 − ε_ν)^n. Since 1 − M_D(f(x)|x) = Σ_ν w_D(ν)·(1 − ν(f(x)|x)),

  β(M^(n+1))/L = Σ_ν w_{D_n}(ν)·ε_ν = ∫_0^1 w_{D_n}({ν : ε_ν > s}) ds.

Because ξ(D_n) ≥ w(f)·f(D_n) = w(f), and f does not belong to {ν : ε_ν > s}, the integrand satisfies w_{D_n}({ε_ν > s}) ≤ min{1, Σ_{ν: ε_ν>s} w(ν)·ν(D_n)/w(f)}, and its expectation is at most min{1, c·e^(−sn)} with c := (W − w(f))/w(f). Now ∫_0^∞ min{1, c·e^(−sn)} ds equals c/n ≤ 1/n if c ≤ 1, and (ln c + 1)/n if c > 1; in both cases it is at most (ln(W/w(f)) + 1)/n.

(b) For ν ∈ H put h_ν := Σ_x q(x)·H²(P, ν)(x) ∈ [0, 1]. Given everything before the answer of round t, the factor √(ν(y_t|x_t)/P(y_t|x_t)) of √(ν(D_n)/P(D_n)) has conditional mean Σ_{y∈Y} √(ν(y|x_t)·P(y|x_t)) = 1 − H²(P, ν)(x_t) on {a_t = 1} (P gives ⊥ no mass), and this depends on (a_t, x_t) only; so by induction E[√(ν(D_n)/P(D_n))] = (1 − h_ν)^n. (P(D_n) > 0 almost surely by Lemma 4.1(i).) The map C ↦ H²(P, C)(x) is convex, because the square root is concave; hence H²(P, M_D)(x) ≤ Σ_ν w_D(ν)·H²(P, ν)(x) and

  χ(M^(n+1))/L ≤ Σ_ν w_{D_n}(ν)·h_ν = ∫_0^1 w_{D_n}({ν : h_ν > s}) ds.

Since ξ(D_n) ≥ w(P)·P(D_n), and min{1, Σ_i a_i} ≤ Σ_i √(a_i) for a_i ≥ 0,

  w_{D_n}({h_ν > s}) ≤ min{1, Σ_{ν: h_ν>s} w(ν)·ν(D_n)/(w(P)·P(D_n))} ≤ Σ_{ν: h_ν>s} √(w(ν)/w(P))·√(ν(D_n)/P(D_n)),

with expectation at most min{1, c·e^(−sn)}, c := S_½/√(w(P)) ≥ 1. The integral is at most (ln c + 1)/n. The bound on β follows from β(C) ≤ √(2L·χ(C)) (Definition 1.5) and Jensen's inequality. ∎

*Remarks.* (i) The argument for (a) is the classical one for learners that are consistent with independent examples (a hypothesis with error rate ε survives n examples with probability (1 − ε)^n), integrated over ε instead of applied at one threshold; applied at one threshold it gives ln n more. An exact computation for a family of examples is in Section 16. (ii) For weights of the form w(ν) = 2^(−2ℓ(ν)) with code lengths ℓ that satisfy Kraft's inequality, S_½ ≤ 1. For general weights with Σ_ν √(w(ν)) = ∞ part (b) is not available: the step from the minimum to the sum of square roots is the one that fails for posterior mass at the weights 2^(−ℓ) (`research/prove-b/hellinger-runs.md`, Example 5.4). Whether the conclusion of (b) holds for all weights is open. (iii) Neither part says anything about scaffolds whose inputs depend on the answers; there the questions of different rounds are not identically distributed, and the next two propositions show that the conclusion fails.

**Proposition 6.2 (last round, divergence form). PROVED (this is Remark (iii) of the candidate theory, by example).** For every L ≥ 2 and every n ≥ L there are a class of three samplers with weights of total 1, a function f in the class, and a scaffold of horizon L such that under Protocol R

  E[Λ(M^(n+1))] ≥ ((L − 1)/8)·L·K ln 2/n,  while  E[Λ(M^(T))] ≤ L·K ln 2/n.

*The example (a hypothesis that hedges).* X = {c, r, b}, Y = {0, 1}. Put p := L/(3n), κ := 8L/n, η := 2·e^(−8L), φ := e^(−80L). The scaffold has z ∈ {0, 1} with D₀(1) = p and no randomness, and every run has L calls. If z = 0, all calls are at c. If z = 1, call 1 is at r, and calls 2, …, L are at b if y_1 = 1 and at c otherwise. The class:

* f: f(c) = 0, f(r) = 1, f(b) = 0, with weight ηφ/W′;
* h: h(c) = 0, h(r) = 1, h(b) = 1, with weight η/W′;
* g: g(0|c) = e^(−κ), g(1|c) = 1 − e^(−κ), g(r) = 0, g(b) = 1, with weight 1/W′;

where W′ := 1 + η + ηφ. So K ln 2 = ln(W′/(ηφ)) = 88L − ln 2 + ln W′ < 88L. The hypothesis g loses a little at every question at c, and it is wrong at r in the way that keeps the runs away from b. While g dominates the posterior, h is not refuted; when g has decayed, h takes over, and h is wrong at every call at b.

*Proof.* The second inequality is Proposition 5.2(a). For the first: every run has L calls, so every round puts one question to the human, at c (answer 0), at r (answer 1) or at b (answer 0). A question at r gives g the likelihood 0; a question at b gives g and h the likelihood 0; a question at c multiplies the weight of g by e^(−κ) and leaves h and f unchanged. Call round t *early* if no question at r or b was asked in rounds 1, …, t − 1. In an early round the posterior weights of g, h, f are proportional to e^(−κ(t−1)), η, ηφ, so

  ψ_t := M^(t)(1|r) = (η + ηφ)/(e^(−κ(t−1)) + η + ηφ),  M^(t)(0|b) = ηφ/(e^(−κ(t−1)) + η + ηφ).

In an early round the question is at r with probability p/L (z = 1 and J_t = 1) and at b with probability p·ψ_t·(L − 1)/L (z = 1, y_1 = 1, J_t ≥ 2). Hence

  Pr[round n + 1 is early] ≥ 1 − Σ_{t≤n} (p/L + p·ψ_t) = 2/3 − p·Σ_{t≤n} ψ_t.

Since e^(−κn) = e^(−8L) = η/2, we have e^(−κ(t−1)) = (η/2)·e^(κi) with i := n − t + 1 ∈ {1, …, n}, and ψ_t = 1/(1 + e^(κi)/(2(1 + φ))), which decreases in i. Therefore Σ_{t≤n} ψ_t ≤ ∫_0^∞ du/(1 + e^(κu)/(2(1 + φ))) = ln(3 + 2φ)/κ, and p·Σ_t ψ_t ≤ (L/(3n))·(n/(8L))·ln(3 + 2φ) = ln(3 + 2φ)/24 < 0.0458. So round n + 1 is early with probability at least 0.6208.

If round n + 1 is early, the weights are proportional to η/2, η, ηφ. Then ψ_{n+1} = (1 + φ)/(3/2 + φ) ≥ 2/3 and KL(f ‖ M^(n+1))(b) = ln((3/2 + φ)/φ) ≥ ln(1/φ) = 80L. A run of M^(n+1) has z = 1 and y_1 = 1 with probability p·ψ_{n+1}, and then makes L − 1 calls at b. So Λ(M^(n+1)) ≥ p·(2/3)·(L − 1)·80L, and

  E[Λ(M^(n+1))] ≥ 0.6208·(L/(3n))·(2/3)·(L − 1)·80L > 11.03·L²·(L − 1)/n > ((L − 1)/8)·88L²/n > ((L − 1)/8)·L·K ln 2/n. ∎

*Remarks.* (i) The exact values for L = 5, 10, 20, 40 and n = 4000 are in Section 16: the ratio of E[Λ(M^(n+1))] to L·K ln 2/n is 0.76, 1.50, 2.89, 5.65, about 0.14·(L − 1). (ii) The candidate theory gives as the reason for its Remark (iii) that learning curves are not monotone. That reason is incomplete: a curve that is not monotone can still satisfy a bound of the same order at every round, as it does in Proposition 6.1(a). What the example uses is a hypothesis whose weight decays at a known rate, so that the posterior changes at a time that can be placed at round n, together with an input that the runs reach only after the change. (iii) In this example the *number* of unfaithful calls of M^(n+1) is small: in every posterior state β(M) ≤ L·(1 − e^(−κ)) + p·L ≤ 8.4·L²/n, which is below L·K ln 2/n. The excess is in the logarithmic loss at b. The next proposition is about the number.

**Proposition 6.3 (last round, number of unfaithful calls of a deterministic human). NEW.** Let L ≥ 2, n ≥ L, N ≥ 1 an integer and λ > 0. There are a class of 2^(N+1) samplers with weights of total 1, a function f in the class with K ln 2 = N·ln 2 + ln(1 + e^λ), and a scaffold of horizon L, such that under Protocol R

  E[β(M^(n+1))] ≥ (L·(L − 1)/(6n))·[ s₁·(e^(−1/3)·(1 − 1/(9n)) − ā/N) − (λ + 1)·ā/(4n) ],  (6.1)

where s₁ := 1/(1 + e^(−1)) > 0.731 and ā := L·ln(1 + e)/(3(λ + 1)). In particular, for L ≥ 4, n ≥ 100·L, λ := 1.1272·√L − 1 and N := ⌈1.6262·√L⌉,

  E[β(M^(n+1))] ≥ ((L − 1)/(40·√L))·L·K ln 2/n,  while  E[β(M^(T))] ≤ L·K ln 2/n.

So for a deterministic human no bound of the form E[β(M^(n+1))] ≤ C·L·K/n with an absolute constant C holds.

*The example.* X = {c, r, b_1, …, b_N}, Y = {0, 1}. Put p := L/(3n), κ := (λ + 1)/n, η := e^(−λ). The scaffold has z ∈ {0, 1, …, N} with D₀(0) = 1 − p and D₀(i) = p/N for i ≥ 1, no randomness, and every run has L calls. If z = 0, all calls are at c. If z = i ≥ 1, call 1 is at r, and calls 2, …, L are at b_i if y_1 = 1 and at c otherwise. The human is f with f(c) = 0, f(r) = 1, f(b_i) = 0. The class consists, for every S ⊆ {1, …, N}, of

* h_S: h_S(c) = 0, h_S(r) = 1, h_S(b_i) = 1[i ∈ S], with weight η·2^(−N)/(1 + η);
* g_S: g_S(0|c) = e^(−κ), g_S(1|c) = 1 − e^(−κ), g_S(r) = 0, g_S(b_i) = 1[i ∈ S], with weight 2^(−N)/(1 + η).

f = h_∅, so ln(1/w(f)) = N·ln 2 + ln(1 + e^λ). The members h_S are functions; the members g_S are not (they are random at c).

*Proof.* *The posterior.* Every run has L calls, so every round puts exactly one question to the human: at c, at r, or at some b_i. Let the data consist of k questions at c, possibly questions at r, and questions at the b_i with i ∈ A. The likelihood of h_S is 1[S ∩ A = ∅], and that of g_S is e^(−κk)·1[r was not asked]·1[S ∩ A = ∅]. Hence the posterior gives the family {g_S} the total weight

  G := e^(−κk)/(e^(−κk) + η) if r was not asked,  G := 0 otherwise,

and within each family S is uniformly distributed over the subsets of the complement of A. So M(1|r) = 1 − G, M(1|c) = G·(1 − e^(−κ)), and M(1|b_i) = ½ for i ∉ A, M(1|b_i) = 0 for i ∈ A. A run of M has z ≥ 1 with probability p; then y_1 = 1 with probability 1 − G; then each of its L − 1 calls at b_z is unfaithful with probability ½ if z ∉ A, and given z ≥ 1 this has probability 1 − |A|/N. Therefore

  β(M) ≥ (p·(L − 1)/2)·(1 − G)·(1 − |A|/N).  (6.2)

*The clock.* Put s(u) := 1/(1 + e^(λ−κu)), so 1 − G = s(k) as long as r was not asked. The function s is increasing, s′ = κ·s·(1 − s) ≤ κ/4, and s(n) = 1/(1 + e^(−1)) = s₁.

*The event.* Let E₀ be the event that no question at r is asked in rounds 1, …, n. In every round the question is at r with probability p/L (z ≥ 1 and J_t = 1), whatever the past, so Pr[E₀] = (1 − 1/(3n))^n ≥ e^(−1/3)·(1 − 1/(9n)), using ln(1 − x) ≥ −x − x² for 0 ≤ x ≤ ½. Let a′ be the number of rounds t ≤ n with a question at a trap b_i. On E₀ the number of questions at c in rounds 1, …, n is k_n = n − a′, and |A_n| ≤ a′ for the set A_n of traps asked. So on E₀, at the start of round n + 1,

  1 − G ≥ max{0, s₁ − κ·a′/4},  1 − |A_n|/N ≥ max{0, 1 − a′/N},  hence  (1 − G)·(1 − |A_n|/N) ≥ s₁ − a′·(κ/4 + s₁/N).

(For x, y ≥ 0: max{0, s₁ − x}·max{0, 1 − y} ≥ s₁ − x − s₁·y; if both maxima are positive the product is s₁ − x − s₁·y + xy, and otherwise the right side is at most 0.)

*Few questions at traps before round n.* Let a″ be the number of rounds t ≤ n in which a question at a trap is asked and no question at r was asked in rounds 1, …, t − 1; on E₀, a′ = a″. In such a round, given the past, the question is at a trap with probability p·(1 − G)·(L − 1)/L ≤ p·s(k) ≤ p·s(t − 1), where k ≤ t − 1 is the number of earlier questions at c. So

  E[a″] ≤ p·Σ_{t=1}^{n} s(t − 1) ≤ p·∫_0^n s(u) du = (p/κ)·ln((1 + η·e^(κn))/(1 + η)) ≤ (p/κ)·ln(1 + e) = ā.

*Conclusion.* By (6.2) and the two displays, E[β(M^(n+1))] ≥ (p·(L − 1)/2)·E[1_{E₀}·(s₁ − a′·(κ/4 + s₁/N))] ≥ (p·(L − 1)/2)·(s₁·Pr[E₀] − (κ/4 + s₁/N)·ā), which is (6.1).

*The numbers.* Let L ≥ 4, n ≥ 100·L, λ + 1 = 1.1272·√L and N = ⌈1.6262·√L⌉. Then ā = 0.38836·√L, ā/N ≤ 0.23881, (λ + 1)·ā/(4n) = 0.10944·L/n ≤ 0.0011, and e^(−1/3)·(1 − 1/(9n)) ≥ 0.71633. So the bracket in (6.1) is at least 0.731·(0.71633 − 0.23881) − 0.0011 > 0.3479, and E[β(M^(n+1))] ≥ 0.05798·L·(L − 1)/n. On the other side K ln 2 ≤ (1.6262·√L + 1)·ln 2 + λ + e^(−λ) ≤ 2.2544·√L − 0.3068 + e^(−λ) ≤ 2.2544·√L, because λ ≥ 1.25. The quotient is at least 0.0257·(L − 1)/√L. The bound for M^(T) is Proposition 5.2(a). ∎

*Remarks.* (i) Exact values (Section 16): with these parameters the ratio of E[β(M^(n+1))] to L·K ln 2/n is 0.50, 0.81, 1.41, 2.63 for L = 100, 400, 1600, 6400, about 0.033·√L, and E[β(M^(n+1))] is 4.6 times the average over the rounds for L = 6400. The constant 1/40 is small; the proposition settles the order of growth, not a practical size. (ii) Why √L and not L in this example: the trap is reached only through the answer at r, which is asked with probability p/L per round, and g must not have been refuted there, so p is of order L/n; the height of the last round is then of order p·L, that is L/K times the bound, and the protection of the traps before round n needs K of order √L. (iii) The class contains samplers that are not functions. The decay of g_S at c can presumably be replaced by many clock inputs and a product prior over functions; this is not carried out here.

**Proposition 6.4 (last round, any scaffold, deterministic human: an upper bound). NEW.** Assume H1 and let P be a function f ∈ H. Let Π be any scaffold of horizon L, let u(C) be the probability that a run of the kernel C is unfaithful (Theorem 7.1), and let B₀ := L·ln(W/w(f))/n be the bound of Proposition 5.2(a) for a uniformly chosen round. If 2·B₀ < 1, then under Protocol R

  E[u(M^(n+1))] ≤ 2L·B₀·(1 + ln(1/(2B₀))) + 2·B₀ + 2L/n,  and  E[β(M^(n+1))] ≤ L·E[u(M^(n+1))].

The right side increases with B₀ on 2·B₀ < 1, and B₀ ≤ L·K ln 2/n. So if 2L·K ln 2 < n, then in the probability of an unfaithful run the last mixture is worse than the bound L·K ln 2/n of a random round by at most the factor 2L·(1 + ln(n/(2L·K ln 2))) + 2, up to the term 2L/n; in the number of unfaithful calls by at most L times as much.

*Proof.* *Notation.* For (z, ρ) let x^f_1, …, x^f_len be the inputs of the run τ^f(z, ρ) of the human system, and for a hypothesis or kernel ν let e_ν(x) := 1 − ν(f(x)|x). Put b_ν := E[Σ_j e_ν(x^f_j)] ∈ [0, L], the expected number of calls *of the human system's run* at which ν differs from f; b_f = 0. Write u_t := u(M^(t)) and e_t := e_{M^(t)}.

*Step 1: the last mixture.* By Theorem 7.1(a) and 1 − Π_j (1 − e_j) ≤ Σ_j e_j, and because e_{M_D} = Σ_ν w_D(ν)·e_ν,

  u(M^(n+1)) ≤ E[Σ_j e_{M_{D_n}}(x^f_j)] = Σ_ν w_{D_n}(ν)·b_ν = L·∫_0^1 w_{D_n}(B_s) ds,  B_s := {ν ∈ H : b_ν > L·s},

where the expectation in the middle is over (z, ρ) only.

*Step 2: questions on the path of the human system.* In round t let σ_t be the first call at which the answer of the run τ_t differs from f (σ_t := ∞ if there is none). At the calls j ≤ σ_t the inputs of τ_t are x^f_j(z_t, ρ_t), because the earlier answers are those of f. Let O_t be the event that J_t ≤ σ_t and J_t ≤ len(τ^f(z_t, ρ_t)); on O_t the question of round t is at x^f_{J_t}(z_t, ρ_t). Put R_t(ν) := 1 − 1_{O_t}·e_ν(x^f_{J_t}(z_t, ρ_t)) ∈ [0, 1]. The factor that round t contributes to the likelihood ν(D_n) is R_t(ν) on O_t and is at most 1 otherwise, so ν(D_n) ≤ Π_{t≤n} R_t(ν). Given 𝓕_{t−1} and (z_t, ρ_t), the event {σ_t ≥ j} has probability Π_{i<j} (1 − e_t(x^f_i)) ≥ π_t := Π_i (1 − e_t(x^f_i)), and J_t is uniform and independent. Hence

  r_t(ν) := E[1 − R_t(ν) | 𝓕_{t−1}] ≥ (1/L)·E[π_t·Σ_j e_ν(x^f_j)] ≥ b_ν/L − E[1 − π_t] = b_ν/L − u_t,

because Σ_j e_ν(x^f_j) ≤ L and E[1 − π_t] = u_t by Theorem 7.1(a).

*Step 3: a supermartingale.* S_n(ν) := Π_{t≤n} R_t(ν)·exp(Σ_{t≤n} r_t(ν)) satisfies E[S_n(ν) | 𝓕_{n−1}] = S_{n−1}(ν)·e^(r_n(ν))·(1 − r_n(ν)) ≤ S_{n−1}(ν), so E[S_n(ν)] ≤ 1. Let U_n := Σ_{t≤n} u_t. For ν ∈ B_s, Step 2 gives Σ_{t≤n} r_t(ν) ≥ n·s − U_n. So on the event {U_n ≤ n·s/2}, Π_{t≤n} R_t(ν) ≤ S_n(ν)·e^(−ns/2) for every ν ∈ B_s, and therefore E[1{U_n ≤ ns/2}·ν(D_n)] ≤ e^(−ns/2).

*Step 4: the posterior mass of B_s.* Since ξ(D_n) ≥ w(f) and f ∉ B_s, w_{D_n}(B_s) ≤ min{1, Σ_{ν∈B_s} w(ν)·ν(D_n)/w(f)}. By Step 3 and Markov's inequality for U_n,

  E[w_{D_n}(B_s)] ≤ min{1, Pr[U_n > ns/2] + (W/w(f))·e^(−ns/2)} ≤ min{1, 2·E[U_n]/(ns)} + min{1, (W/w(f))·e^(−ns/2)}.

By u ≤ β and Theorem 5.1(c), E[U_n] ≤ L·ln(W/w(f)) = n·B₀.

*Step 5: integration.* With c := 2·B₀ < 1, ∫_0^1 min{1, c/s} ds = c + c·ln(1/c); and ∫_0^∞ min{1, (W/w(f))·e^(−ns/2)} ds = 2·(ln(W/w(f)) + 1)/n. With Step 1,

  E[u(M^(n+1))] ≤ L·(2B₀·(1 + ln(1/(2B₀))) + 2·(ln(W/w(f)) + 1)/n) = 2L·B₀·(1 + ln(1/(2B₀))) + 2·B₀ + 2L/n.

Finally β(C) ≤ L·u(C) for every kernel, because a run has at most L calls. ∎

*Remarks.* (i) Where the factors come from. The factor L is the union bound of Step 1 over the calls of a run; it is the loss of Proposition 5.5(a) again, since the last mixture, like the averaged kernel, mixes hypotheses call by call. The logarithm comes from applying Markov's inequality to U_n at every threshold s. The proof uses that the rehearsal runs follow the human system's run up to their first unfaithful call, so that hypotheses with many errors along that run are refuted at a rate that only the unfaithful rehearsal runs can lower. (ii) Together with Proposition 6.3: for a deterministic human the largest possible ratio of E[β(M^(n+1))] to L·K ln 2/n lies between (L − 1)/(40√L) and about 2L²·(1 + ln(n/(2L·K ln 2))). For E[u(M^(n+1))] it lies between 1 and about 2L·(1 + ln(n/(2L·K ln 2))); in the examples of Propositions 6.2 and 6.3 the ratio is below 1, because in every posterior state u(M) ≤ p + L·κ (the run is faithful if z = 0 and no call at c is answered wrongly), which is 8.4·L²/n in the first example and L·(λ + 4/3)/n in the second (for N ≥ 2). The excess of Proposition 6.3 comes from runs that are unfaithful at L − 1 calls at once.

*What remains open in Section 6.* The right order of the last round for a deterministic human: for the number of unfaithful calls between √L and L²·ln n times the bound of the random round, for the probability of an unfaithful run between 1 and L·ln n times. For a human who is not deterministic there is no upper bound for the last round on scaffolds whose inputs depend on the answers, and Proposition 6.2 shows that none of the order L·K/n holds for the divergence. In practice the question is answered by validation: Theorem 13.1 certifies whichever imitator is deployed, the last mixture included.

## 7. Theorem R2 for a deterministic human

**Theorem 7.1 (R2 for a function). PROVED.** Let P be a function f, C a kernel, (z, ρ) ~ D₀ ⊗ λ, τ a run of C on (z, ρ), and τ^f(z, ρ) the run of the human system on the same (z, ρ). Let x^f_1, …, x^f_len be the inputs of τ^f(z, ρ).

(a) u(C) := Pr[τ ≠ τ^f(z, ρ)] = E[1 − Π_j (1 − e_C(x^f_j))] ≤ min{1, β(C)}, and TV(Q_C, Q_f) = u(C).

(b) Assume H1 and f ∈ H. Under Protocol R the deployed run of M^(T) is the run of the human system on the same (z, ρ) with probability at least 1 − L·ln(W/w(f))/n ≥ 1 − L·K ln 2/n; the probability is over the rehearsal, T and the deployed run.

(c) If every deployed run draws its own round, then with probability at least 1 − δ over the rehearsal, every deployed run is, conditionally on the rehearsal, the run of the human system on its (z, ρ) with probability at least 1 − L·(ln(W/w(f)) + ln(1/δ))/n.

*Proof.* (a) By Proposition 3.4(d) the run of C is the run of the human system corrupted by the stateless rule that replaces f(x_j) by a draw from C(·|x_j), and it equals τ^f(z, ρ) if and only if no replacement happens. Given (z, ρ), no replacement happens with probability Π_j (1 − e_C(x^f_j)), because as long as none has happened the inputs are those of τ^f(z, ρ). The number N of replacements has mean β(C) (Proposition 3.4(b)), and Pr[N ≥ 1] ≤ E[N]. For the total variation: Q_f gives the graph {(z, ρ, τ^f(z, ρ))} probability 1 and Q_C gives it probability 1 − u(C), so TV(Q_C, Q_f) ≥ u(C); and TV(Q_C, Q_f) ≤ u(C) by the coupling. (b) Take the expectation of u(M^(T)) ≤ β(M^(T)) and use Proposition 5.2(a). (c) Proposition 5.2(b), with u ≤ β for the mixture of the drawn round. ∎

*What it does not say.* The bound is useful only when n exceeds L·K ln 2: more questions than the run has calls. That no protocol avoids this when every call is critical is the subject of `research/prove/lower-bounds.md` (N2). For a human who is not deterministic the statement about whole runs is Theorem 3.1 of `research/prove-b/hellinger-runs.md`.

## 8. Theorem R3: low stakes

**Definition 8.1 (tolerance).** Let G ⊆ 𝒯 be a measurable set of runs (the *good* runs), 𝓡 a class of replacement rules (Definition 3.3), k ≥ 0 an integer and δ ∈ [0, 1]. The human system *tolerates k faults against 𝓡 with failure δ* if for every rule r ∈ 𝓡 under which the corrupted run has at most k replacements with probability 1, the corrupted run lies in G with probability at least 1 − δ.

For k = 0 this says Q_P(G) ≥ 1 − δ. Since 𝓡_bst ⊆ 𝓡_tr ⊆ 𝓡_all, tolerance against 𝓡_all implies tolerance against 𝓡_tr, which implies tolerance against 𝓡_bst. The definition in `note.md` and in the candidate theory ("every rule that, at each call, sees the run so far and the human's answer") is tolerance against 𝓡_all; Definition 5.1 of `research/prove/lower-bounds.md` is the same for functions.

**Definition 8.2 (the rule of an answerer; the robustness curve).** (a) For an answerer A let γ_h be the maximal coupling (Lemma 3.1) of A_j(·|h) and P(·|x_j) at the history h = h_j, and r^A_j(y | h_j, y′) := γ_{h_j}(y, y′)/P(y′|x_j). By Lemma 3.2 with B = P, the run of the human system corrupted by r^A has the law Q_A, and given the past a replacement happens at call j with probability TV(A_j(·|h_j), P(·|x_j)). We write β(A) := E_{Q_A} Σ_{j≤len} TV(A_j(·|h_j), P(·|x_j)) for the expected number of replacements; for a kernel this is Definition 1.5, and r^C = κ_C is stateless. The *budgeted* rule r^{A,≤k} applies r^A at call j if fewer than k replacements have happened before call j, and passes the human's answer otherwise. In general r^{A,≤k} ∈ 𝓡_all; for a kernel C, κ_C^{≤k} ∈ 𝓡_bst.

(b) For β ∈ [0, L] put δ_Π(β) := sup{ Q_C(G^c) : C a kernel with β(C) ≤ β }. This function is nondecreasing with values in [0, 1], and δ_Π(0) = Q_P(G^c) (if β(C) = 0, no call is unfaithful almost surely, and Q_C = Q_P by Lemma 3.2(c)). Let δ̄_Π(β) := sup{ Σ_i λ_i·δ_Π(β_i) : λ_i ≥ 0, Σ_i λ_i = 1, Σ_i λ_i β_i = β } (finite sums) be its least concave majorant on [0, L]. δ̄_Π is nondecreasing: if β < β′ ≤ L and β = Σ_i λ_i β_i, then β′ = Σ_i λ_i β′_i with β′_i := β_i + (β′ − β)·(L − β_i)/(L − β) ∈ [β_i, L], and δ_Π(β′_i) ≥ δ_Π(β_i).

**Proposition 8.3 (R3 in the form with the robustness curve). PROVED (tagged [?] in the candidate theory).** (a) For every kernel C: Q_C(G^c) ≤ δ_Π(β(C)).

(b) Let C be a random kernel that takes countably many values and is independent of the randomness of the deployed run (for example a function of the rehearsal data and of T). Then the deployed run of C is outside G with probability at most E[δ_Π(β(C))] ≤ δ̄_Π(E[β(C)]).

(c) Under Protocol R with H1 and P ∈ H: the deployed run of M^(T) is outside G with probability at most δ̄_Π(L·ln(W/w(f))/n) if P is a function f, and at most δ̄_Π(L·√(ln(W/w(P))/(2n))) in general.

(d) In (b) the concave majorant cannot be replaced by δ_Π itself. Example: L calls at distinct inputs x_1, …, x_L, f ≡ 0, G := {not all L answers differ from 0}. Then δ_Π(β) = (β/L)^L and δ̄_Π(β) = β/L. The random kernel that answers 1 everywhere with probability ε and is f otherwise has E[β] = εL and failure probability ε = δ̄_Π(E[β]) > δ_Π(E[β]) = ε^L.

*Proof.* (a) is the definition. (b) Given the data, the failure probability is Q_C(G^c) ≤ δ_Π(β(C)) ≤ δ̄_Π(β(C)); δ̄_Π is concave and bounded on [0, L], so Jensen's inequality gives E[δ̄_Π(β(C))] ≤ δ̄_Π(E[β(C)]). (c) By (b), the monotonicity of δ̄_Π, and E[β(M^(T))] ≤ L·ln(W/w(f))/n (Proposition 5.2(a)), respectively E[β(M^(T))] ≤ L·√(ln(W/w(P))/(2n)) (Proposition 9.1). (d) For a kernel C with e_j := e_C(x_j): β(C) = Σ_j e_j and Q_C(G^c) = Π_j e_j ≤ (β(C)/L)^L by the inequality between the geometric and the arithmetic mean, with equality when all e_j are equal; (β/L)^L is convex with the values 0 at 0 and 1 at L, so its least concave majorant on [0, L] is β/L. ∎

The function case of (a) to (c) is also Proposition 5.2 of `research/prove/lower-bounds.md`. The second half of the candidate's "sharper form" (a lower bound of about L/β questions for classes closed under patches) is refuted there by Example 5.5; its replacement is Proposition 5.4(a) of that file.

**Theorem 8.4 (R3: low stakes). PROVED, with a weaker hypothesis.** Let G be a measurable set of runs, k ≥ 0 an integer and A an answerer. Let N be the number of replacements in the run of the human system corrupted by r^A, and δ_k(A) the probability that the run corrupted by the budgeted rule r^{A,≤k} is outside G. Then

  Q_A(G^c) ≤ δ_k(A) + Pr[N ≥ k + 1] ≤ δ_k(A) + β(A)/(k + 1).

Consequently:

(a) If A is a kernel C and the human system tolerates k faults against 𝓡_bst with failure δ, then Q_C(G^c) ≤ δ + β(C)/(k + 1); in particular δ_Π(β) ≤ δ + β/(k + 1) and δ̄_Π(β) ≤ δ + β/(k + 1) for all β.

(b) For any answerer A, if the human system tolerates k faults against 𝓡_all with failure δ, then Q_A(G^c) ≤ δ + β(A)/(k + 1).

(c) Under Protocol R with H1, a function f ∈ H, and tolerance of k faults against 𝓡_bst with failure δ: the deployed run of M^(T) is outside G with probability at most δ + L·ln(W/w(f))/((k + 1)·n). If k + 1 ≥ θL (for example k = ⌊θL⌋), this is at most δ + K ln 2/(θ·n), whatever L.

*Proof.* Generate the run τ corrupted by r^A: (z, ρ), and at each call j ≤ len the human's answer y′_j ~ P(·|x_j) and then the passed answer y_j ~ r^A_j(·|h_j, y′_j). It has the law Q_A (Definition 8.2(a)). Let j_k be the call of the k-th replacement (j_k := ∞ if N < k). Define a second run τ̃ on the same (z, ρ): at the calls j ≤ j_k it has the same human answers and the same passed answers as τ. At the calls j > j_k, as long as its history equals that of τ, its human answer is y′_j and its passed answer is y′_j; the two histories remain equal after call j exactly if y_j = y′_j. After the first call j > j_k at which τ has a replacement the two histories differ, and from then on τ̃ continues with fresh draws of the human at its own inputs, passed unchanged. At every call of τ̃ the human's answer is, given the past of τ̃, a draw from P at the input of τ̃ (it is y′_j, drawn before y_j, or a fresh draw), and the passed answer is drawn from r^A_j if fewer than k replacements have happened and is the human's answer otherwise. So τ̃ is the run of the human system corrupted by r^{A,≤k}, and Pr[τ̃ ∉ G] = δ_k(A). The two runs are equal on {N ≤ k}. Hence Q_A(G^c) = Pr[τ ∉ G] ≤ Pr[τ̃ ∉ G] + Pr[N ≥ k + 1], and Pr[N ≥ k + 1] ≤ E[N]/(k + 1) = β(A)/(k + 1) by Markov's inequality.

(a) κ_C^{≤k} belongs to 𝓡_bst and makes at most k replacements on every path, so δ_k(C) ≤ δ; the bound for δ_Π follows by taking the supremum, and the bound for δ̄_Π because the right side is affine in β. (b) r^{A,≤k} ∈ 𝓡_all makes at most k replacements. (c) Apply (a) to C = M^(T) for every value of the data and of T, take expectations, and use Proposition 5.2(a); L/(k + 1) ≤ 1/θ. ∎

*Remarks.* (i) The statement of `note.md` is (b) and (c) with tolerance against 𝓡_all. The proof uses only the budgeted version of the one stateless rule κ_C, so tolerance against 𝓡_bst suffices for imitators that are kernels; Example 8.5 shows that this is a weaker requirement on the human system. (ii) The rule κ_C(·|x, y′) depends on the human's answer y′. For a deterministic human this is no extra knowledge. For a human who is not deterministic it is: the coupling may replace exactly those answers of the human that the imitator never gives. A tolerance assumption for rules that do not see the human's answer would not suffice for Theorem 8.4. (iii) *What the theorem does not say.* It says nothing unless the human system itself tolerates faults; a scaffold in which one wrong answer spoils the outcome has k = 0, and the bound is δ + β.

**Example 8.5 (the Markov step is attained; the three classes of rules differ). NEW.** In all three examples Y = {0, 1} and f ≡ 0.

(a) *Equality in Theorem 8.4.* Let L ≥ k + 1, X = {c, a_1, …, a_{k+1}}, and let the scaffold have z ∈ {0, 1} with D₀(1) = ε: if z = 0 all L calls are at c; if z = 1 calls 1, …, k + 1 are at a_1, …, a_{k+1} and the remaining calls at c. Let G := {at most k answers differ from 0}. The human system tolerates k faults against 𝓡_all with failure 0. The kernel C that answers 0 at c and 1 at every a_i has β(C) = (k + 1)·ε and Q_C(G^c) = ε = β(C)/(k + 1). So the bound δ + β/(k + 1) cannot be improved as a function of δ, β and k.

(b) *Tolerance against 𝓡_tr does not imply tolerance against 𝓡_all.* Let L ≥ 2, X = {x₀}, let the scaffold's randomness ρ be an index I that is uniform on {1, …, L}, let all L calls be at x₀, and G := {y_I = 0}. The rule "replace the answer at call I by 1" is in 𝓡_all, makes one replacement, and its run is never in G. A rule in 𝓡_tr depends on (z, ρ) only through the inputs, which are constant; so the answers (y_1, …, y_L) it passes are independent of I, and if it makes at most k replacements then Pr[y_I ≠ 0] = E[#{j : y_j ≠ 0}]/L ≤ k/L. So the human system tolerates k faults against 𝓡_tr with failure k/L, and it does not tolerate one fault against 𝓡_all with any failure below 1.

(c) *Tolerance against 𝓡_bst does not imply tolerance against 𝓡_tr.* Let L ≥ 3, X = {a_1, …, a_{L−1}, x₀}, z uniform on {1, …, L − 1}; call 1 is at a_z and calls 2, …, L are at x₀; G := {y_{1+z} = 0}. A rule in 𝓡_tr sees x_1 = a_z and replaces the answer at call 1 + z: one replacement, and the run is never in G. A budgeted stateless rule κ^{≤k} acts at the calls 2, …, L by independent coins of one fixed bias (the inputs and the human's answers there are always x₀ and 0), until its budget is used up. So the set R of calls among 2, …, L that it replaces is contained in the set R₀ of the first k calls among 2, …, L whose coin shows a replacement; R₀ is a function of the coins alone, |R₀| ≤ k, and the coins are independent of z. Hence Pr[y_{1+z} ≠ 0] = Pr[1 + z ∈ R] ≤ E[|R₀|]/(L − 1) ≤ k/(L − 1). So the human system tolerates k faults against 𝓡_bst with failure k/(L − 1), and it does not tolerate one fault against 𝓡_tr with any failure below 1.

**Theorem 8.6 (low stakes in the recoverable form). NEW in this project; the statement is the standard one of the imitation-learning literature.** Let c: 𝒯 → [0, 1] be measurable (a *cost*; c = 1 on bad runs and 0 on good runs gives the failure probability). For j = L + 1, L, …, 1 and a history h_j before call j define v_j(h_j), the expected cost if the human answers call j and all later calls: v_j(h_j) := c(τ) if the run has already stopped at h_j (that is, len < j, with τ the stopped run), and v_j(h_j) := Σ_{y∈Y} P(y|x_j)·v_{j+1}(h_j, y) otherwise. Suppose that for a number μ ∈ [0, 1], for every j ≤ L, every history h_j with len ≥ j, every y ∈ Y_⊥ and every y′ ∈ Y with P(y′|x_j) > 0,

  v_{j+1}(h_j, y) − v_{j+1}(h_j, y′) ≤ μ.  (8.1)

Then for every replacement rule r ∈ 𝓡_all, with τ^r the corrupted run and N its number of replacements,

  E[c(τ^r)] ≤ E_{Q_P}[c] + μ·E[N].

Consequently E_{Q_A}[c] ≤ E_{Q_P}[c] + μ·β(A) for every answerer A, δ_Π(β) ≤ Q_P(G^c) + μ·β when c is the indicator of G^c, and under Protocol R with H1 and a function f ∈ H: E[c(deployed run of M^(T))] ≤ E_{Q_f}[c] + μ·L·ln(W/w(f))/n.

*Proof.* The functions v_j are measurable with values in [0, 1], by backward induction, and E_{Q_P}[c] = E[v_1(z, ρ)]. Along the corrupted run put V_j := v_j(h_j) for j ≤ len + 1 and V_j := c(τ^r) for j > len + 1; so V_{L+1} = c(τ^r). Let 𝓖_j be the σ-algebra of everything realised before the human's answer at call j. On {j ≤ len}: the human's answer y′_j has the law P(·|x_j) given 𝓖_j (H1), so E[v_{j+1}(h_j, y′_j) | 𝓖_j] = v_j(h_j); and by (8.1), v_{j+1}(h_j, y_j) ≤ v_{j+1}(h_j, y′_j) + μ·1[y_j ≠ y′_j], since y′_j has positive probability under P(·|x_j) almost surely. Hence E[V_{j+1} − V_j] ≤ μ·Pr[j ≤ len, y_j ≠ y′_j]. Summing over j = 1, …, L gives E[c(τ^r)] ≤ E[V_1] + μ·E[N]. For an answerer A apply this to r^A (Definition 8.2(a)); for Protocol R use Proposition 5.2(a). ∎

*Remarks.* (i) For a function f, condition (8.1) reads v_{j+1}(h_j, y) − v_{j+1}(h_j, f(x_j)) ≤ μ: one replaced answer, followed by the human, raises the expected cost by at most μ. This is the recoverability condition of Ross, Gordon and Bagnell (2011, Theorem 2.2), whose statement (read in the source; Section 17) is: "Let π be such that E_{s∼d_π}[ℓ(s, π)] = ε, and Q^{π*}_{T−t+1}(s, a) − Q^{π*}_{T−t+1}(s, π*) ≤ u for all action a, t ∈ {1, 2, …, T}, d^t_π(s) > 0, then J(π) ≤ J(π*) + uTε." Theorem 8.6 is this statement for scaffolds, with their u, T and Tε being μ, L and β; for a human who is not deterministic the difference in (8.1) is between two answers, not between an answer and the human's average, because the rule sees the human's answer (Remark (ii) after Theorem 8.4). (ii) *Relation to tolerance.* Theorem 8.6 implies that a human system satisfying (8.1) tolerates k faults against 𝓡_all with failure Q_P(G^c) + k·μ. Putting this into Theorem 8.4 gives Q_P(G^c) + k·μ + β/(k + 1), which is at least Q_P(G^c) + 2·√(μβ) − μ for every k, while Theorem 8.6 gives Q_P(G^c) + μ·β directly, with no Markov step. In the other direction tolerance does not give a small μ: for 2k + 1 calls at one input with f ≡ 0 and G := {at most k answers differ from 0}, the human system tolerates k faults with failure 0, but μ = 1, because at a history with k wrong answers one more wrong answer decides the outcome; here Theorem 8.4 gives β/(k + 1) and Theorem 8.6 gives β. So the two forms are not comparable. (iii) *What it does not say.* (8.1) is required at every history, including histories that the human system itself never reaches; an imitator's run can reach them.

## 9. The human who is not deterministic

**Proposition 9.1 (the number of unfaithful calls, and R3, for any sampler). PROVED.** Assume H1 and P ∈ H. Under Protocol R:

(a) E[β(M^(T))] ≤ √(ℓ̄·L·ln(W/w(P))/(2n)) ≤ L·√(K ln 2/(2n)), where ℓ̄ := (1/n)·Σ_{t≤n} E[len_t] ≤ L is the mean number of calls of a rehearsal run.

(b) If the human system tolerates k faults against 𝓡_bst with failure δ, the deployed run of M^(T) is outside G with probability at most δ + L·√(K ln 2/(2n))/(k + 1), which is at most δ + √(K ln 2/(2n))/θ if k + 1 ≥ θL. Under condition (8.1), E[c(deployed run)] ≤ E_{Q_P}[c] + μ·L·√(K ln 2/(2n)).

*Proof.* (a) Pinsker's inequality, TV(p, q) ≤ √(KL(p ‖ q)/2) for probability distributions p, q (standard; see Section 17), applied at every input, and the Cauchy–Schwarz inequality for the measure E_{Q_C} Σ_{j≤len} give, for every kernel C, β(C) ≤ E_{Q_C} Σ_{j≤len} √(KL(P ‖ C)(x_j)/2) ≤ √(E_{Q_C}[len]·Λ(C)/2). Hence, by the Cauchy–Schwarz inequality over the rounds and the rehearsal,

  E[β(M^(T))] = (1/n)·Σ_t E[β(M^(t))] ≤ √((1/n)·Σ_t E[len_t])·√((1/n)·Σ_t E[Λ(M^(t))]/2) ≤ √(ℓ̄·L·ln(W/w(P))/(2n)),

by Theorem 5.1(a). (b) Theorem 8.4(a) and Theorem 8.6 for every value of the data and of T, then expectations and (a). ∎

**Theorem 9.2 (the rate √(K/n) per call cannot be improved). NEW (the constant is twice that of Theorem 6.1 of `research/prove/lower-bounds.md`).** *Protocols.* A protocol draws a seed r, and then, for at most a fixed finite number of steps, either stops or puts a question x_t ∈ X to the human, chosen as a function of r and of the earlier answers; the answer is y_t ~ P(·|x_t) (H1). Let ω be the seed together with the answers, 𝐏_P the law of ω when the human is P, and N_i the number of questions at the input i. After its questions the protocol deploys an answerer A^ω, any measurable function of ω; it may depend on the history of the run and have private coins.

Let K ≥ 1, L ≥ 1, n ≥ K/2 and θ := √(K/(32n)) ≤ ¼. Let X := {1, …, K}, Y := {0, 1}, and for σ ∈ {−1, +1}^K let P_σ(1|i) := ½ + σ_i·θ. The class {P_σ} has the weights 2^(−K), so every member has K bits. The scaffold draws z = (i_1, …, i_L) independently and uniformly from X and makes call j at i_j. For an answerer A let β_σ(A) := E_{Q_A} Σ_{j≤L} TV(A_j(·|h_j), P_σ(·|x_j)), the least expected number of unfaithful calls of a run of A against the human P_σ (Lemma 3.2(d)). Then for every protocol whose expected number of questions is at most n under every member,

  2^(−K)·Σ_σ E_σ[β_σ(A^ω)] ≥ L·θ/2 = L·√(K/n)/(8√2) > 0.088·L·√(K/n).

So for some member the deployed run has at least 0.088·L·√(K/n) unfaithful calls in expectation, whatever the protocol; by Proposition 9.1, Protocol R has at most L·√(K ln 2/(2n)) < 0.59·L·√(K/n) for every member of every class with K bits.

*Proof.* (1) *One input, two humans.* Fix ω, i and j, and let R^ω_j(·|i) be the conditional law of the answer y_j given x_j = i in a run of A^ω; it does not depend on σ, because A^ω is fixed by ω and the human is not asked during the run. Total variation is convex, so E[TV(A^ω_j(·|h_j), P_σ(·|i)) | x_j = i] ≥ TV(R^ω_j(·|i), P_σ(·|i)), and with φ_{σ,i}(ω) := Σ_{j≤L} TV(R^ω_j(·|i), P_σ(·|i)) we get β_σ(A^ω) ≥ (1/K)·Σ_i φ_{σ,i}(ω). Let σ^(i) be σ with the sign of coordinate i changed. By the triangle inequality, for every ω,

  φ_{σ,i}(ω) + φ_{σ^(i),i}(ω) ≥ L·TV(P_σ(·|i), P_{σ^(i)}(·|i)) = 2θL.

(2) *Two-point inequality.* For nonnegative functions φ, φ′ with φ + φ′ ≥ c and probability measures 𝐏, 𝐏′: ∫φ d𝐏 + ∫φ′ d𝐏′ ≥ ∫(φ + φ′) d min(𝐏, 𝐏′) ≥ c·(1 − TV(𝐏, 𝐏′)). Hence E_σ[φ_{σ,i}] + E_{σ^(i)}[φ_{σ^(i),i}] ≥ 2θL·(1 − TV(𝐏_σ, 𝐏_{σ^(i)})).

(3) *The transcripts are close.* By Lemma 2.1, applied to the scaffold whose internal randomness is the seed and whose calls are the questions of the protocol (the answerers being the kernels P_σ and P_{σ^(i)}), KL(𝐏_σ ‖ 𝐏_{σ^(i)}) = E_σ Σ_t KL(P_σ ‖ P_{σ^(i)})(x_t) = E_σ[N_i]·kl(θ), where kl(θ) := KL(Bern(½ + θ) ‖ Bern(½ − θ)) = 2θ·ln((1 + 2θ)/(1 − 2θ)) ≤ 2θ·4θ/(1 − 2θ) ≤ 16θ² for θ ≤ ¼. By Pinsker's inequality TV(𝐏_σ, 𝐏_{σ^(i)}) ≤ θ·√(8·E_σ[N_i]).

(4) *Averaging.* Each pair {σ, σ^(i)} occurs twice in the sum over σ, so by (1) and (2)

  2^(−K)·Σ_σ E_σ[β_σ(A^ω)] ≥ (1/K)·Σ_i 2^(−K)·Σ_σ θL·(1 − TV(𝐏_σ, 𝐏_{σ^(i)})) ≥ θL·(1 − θ·√(8n/K)),

where the last step uses (3), the concavity of the square root, and Σ_i E_σ[N_i] ≤ n. With θ = √(K/(32n)) the last factor is ½. ∎

**Proposition 9.3 (low stakes with a human who is not deterministic costs of the order of K/θ² questions). NEW.** Let K ≥ 1, θ′ ∈ (0, ¼], L odd, and let {P_σ} be the class of Theorem 9.2 with θ′ in place of θ. The scaffold draws z = i uniformly from X and makes all L calls at i. For a run τ let maj(τ) := +1 if more than L/2 answers are 1, maj(τ) := −1 if more than L/2 answers are 0, and maj(τ) := 0 otherwise; put G_σ := {τ : maj(τ) = σ_z} (the majority of the answers shows the sign of the bias).

(i) For every σ and every integer k ≤ θ′L, the human system of P_σ tolerates k faults against 𝓡_all with failure exp(−2(θ′L − k)²/L), for G_σ. With k := ⌊θ′L/2⌋, a fraction θ := θ′/2 of the calls, the failure is at most exp(−θ′²L/2).

(ii) If a protocol asks at most n questions in expectation under every member, and its deployed run lies in G_σ with probability at least 1 − γ whenever the human is P_σ, for every σ, then

  n ≥ K·(1 − 2γ)²/(8θ′²) = K·(1 − 2γ)²/(32θ²).

(iii) By Proposition 9.1(b), Protocol R with n ≥ K ln 2/(2θ²γ′²) rounds has failure at most exp(−θ′²L/2) + γ′ for every member. So for a fixed excess failure the number of questions is of the order K/θ², while for a deterministic human K ln 2/(θ·γ′) questions suffice (Theorem 8.4(c)).

*Proof.* (i) Let z = i and σ_i = +1; the other case is symmetric, with the roles of the answers 0 and 1 exchanged. The inputs do not depend on the answers, so in the corrupted run the human's answers y′_1, …, y′_L are, each given the past, draws from Bern(½ + θ′). By Lemma 12.1 (with ranges of length 1), S′ := Σ_j y′_j satisfies Pr[S′ ≤ L/2 + k] = Pr[S′ − L·(½ + θ′) ≤ −(θ′L − k)] ≤ exp(−2(θ′L − k)²/L). A rule that makes at most k replacements passes at least S′ − k answers equal to 1, so maj = +1 unless S′ ≤ L/2 + k.

(ii) For ω, i and s ∈ {−1, +1} let π^ω_i(s) be the probability that the run of A^ω has maj = s, given z = i; it does not depend on σ, and π^ω_i(+1) + π^ω_i(−1) ≤ 1. The failure probability under σ is (1/K)·Σ_i E_σ[1 − π^ω_i(σ_i)]. By the two-point inequality of the proof of Theorem 9.2, E_σ[1 − π^ω_i(σ_i)] + E_{σ^(i)}[1 − π^ω_i(−σ_i)] ≥ 1 − TV(𝐏_σ, 𝐏_{σ^(i)}), and TV(𝐏_σ, 𝐏_{σ^(i)}) ≤ θ′·√(8·E_σ[N_i]) as there. Averaging over σ and i as in step (4), the mean failure probability over the class is at least ½·(1 − θ′·√(8n/K)). If this is at most γ, then θ′·√(8n/K) ≥ 1 − 2γ.

(iii) With k = ⌊θ′L/2⌋ we have L/(k + 1) ≤ 2/θ′ = 1/θ, so Proposition 9.1(b) gives the failure δ + √(K ln 2/(2n))/θ with δ = exp(−θ′²L/2). ∎

*What Proposition 9.3 does not say.* In this family the tolerated fraction θ and the bias θ′ of the human are tied together. The proposition shows that the dependence on θ in Proposition 9.1(b) cannot be improved from 1/θ² to 1/θ for all human systems; it does not say that every human system with tolerance θ needs K/θ² questions.

## 10. The online form: every call is put to the human with probability q

**Theorem 10.1 (asking at random; Observation A of `research/understand/notes.md`). PROVED.** Steps t = 1, 2, … follow one another, finitely or infinitely many. At step t an input x_t ∈ X arrives; it may depend in any way on everything realised before step t and on further randomness. Then a coin c_t with Pr[c_t = 1] = q ∈ (0, 1] is flipped, independently of everything realised before it, x_t included. If c_t = 1, the input is put to the human, the human's answer y_t ~ P(·|x_t) (H1) is the answer of step t, and (x_t, y_t) is added to the data. If c_t = 0, the answer of step t is a fresh draw ŷ_t from M_{D_{<t}}(·|x_t), where D_{<t} is the data collected before step t. Assume P ∈ H. Then, the sum running over all steps,

  Σ_t E[KL(P ‖ M_{D_{<t}})(x_t)] ≤ ln(W/w(P))/q ≤ K ln 2/q.

If P is a function f, the expected number of steps with c_t = 0 and ŷ_t ≠ f(x_t) is at most (1 − q)·ln(W/w(f))/q. The expected number of questions among the first s steps is q·s.

*Proof.* This is Setting 4.0 with a_t := c_t, so Σ_t E[c_t κ_t] ≤ ln(W/w(P)) by Lemma 4.1(iii), where κ_t = KL(P ‖ M_{D_{<t}})(x_t) is finite and is a function of what is realised before the coin c_t. Hence E[c_t κ_t] = q·E[κ_t]. For a function, given the past and c_t = 0 the draw differs from f(x_t) with probability e_t = 1 − M_{D_{<t}}(f(x_t)|x_t) ≤ κ_t, and E[(1 − c_t)·e_t] = (1 − q)·E[e_t]. ∎

*What it does not say.* It does not say which steps are wrong. It keeps the human in the loop: questions arrive at rate q for as long as the system runs. And it is a statement about the system with the human in it, not about a frozen imitator.

**Corollary 10.2 (online rehearsal in a closed system has the price of Protocol R). NEW.** Run the scaffold r times in succession in the online form with q := 1/L; the steps are the calls of the successive runs, each run with a fresh (z, ρ). Then the expected number of questions is at most r; the sum over the r runs of E[Σ_{calls} KL(P ‖ current mixture)(x)] is at most L·ln(W/w(P)); and if P is a function f, the sum over the r runs of the expected number of unfaithful calls (calls answered by the mixture with an answer other than f(x); a call answered by the human is faithful) is at most (L − 1)·ln(W/w(f)).

*Proof.* Theorem 10.1 with q = 1/L; the number of steps is at most L·r. ∎

These are the bounds of Theorem 5.1 with n = r, for the same expected number of answers. The runs, however, are runs of the system with the human in it.

**Proposition 10.3 (freezing after online rehearsal costs a constant factor). NEW.** In the setting of Corollary 10.2 with any q ∈ (0, 1), let M_i be the mixture at the start of run i. Then

  Σ_{i≤r} E[Λ(M_i)] ≤ ln(W/w(P))/(q·(1 − q)^(L−1)),

which for q = 1/L is at most e·L·ln(W/w(P)). So the mixture M_I at the start of a uniformly chosen run I ≤ r, frozen and deployed alone, has E[Λ(M_I)] ≤ e·L·K ln 2/r. The same bound holds for the variant with *shadow* questions, in which run i is answered by M_i throughout and the human's answers at the calls whose coin shows 1 are only recorded and added to the data after the run. A loss against Protocol R does occur: in the example of Theorem 5.1(d), for either variant, Σ_{i≤r} E[Λ(M_i)] tends to L·ln(1/w)/(1 − (1 − q)^L) as r grows, which for q = 1/L and L ≥ 2 lies between (4/3)·L·ln(1/w) and 1.59·L·ln(1/w).

*Proof.* Fix i and condition on everything realised before run i; then M_i is fixed. Let j* be the first call of run i whose coin shows 1 (j* := ∞ if there is none). The mixture changes only when an answer of the human arrives, so at the calls j ≤ j* the current mixture is M_i, and the answers at the calls j < j* are draws from M_i. Let τ′ be the run that has the (z, ρ) of run i and its answers at the calls j < j*, and is continued from call j* on with fresh draws from M_i. For each j, the j-th answer of τ′ is a draw from M_i given the earlier answers of τ′ and all the coins; so τ′ has the law Q_{M_i} and is independent of the coins. At the calls j ≤ min(j*, len(τ′)) run i and τ′ have the same inputs. Therefore the sum over the calls of run i of KL(P ‖ current mixture)(x_j) is at least Σ_{j≤len(τ′)} 1[c_1 = … = c_{j−1} = 0]·KL(P ‖ M_i)(x′_j), and the conditional expectation of this is E_{Q_{M_i}} Σ_{j≤len} (1 − q)^(j−1)·KL(P ‖ M_i)(x_j) ≥ (1 − q)^(L−1)·Λ(M_i). Sum over i and use Theorem 10.1. For q = 1/L, (1 − 1/L)^(L−1) ≥ 1/e.

For the shadow variant apply Lemma 4.1 to all questions in the order in which they are asked and keep, as in the proof of Proposition 5.3(a), the first question of each run: it is at call j* of the run τ_i ~ Q_{M_i}, the data before it are those at the start of the run, and the conditional expectation of its term is E_{Q_{M_i}} Σ_{j≤len} q·(1 − q)^(j−1)·KL(P ‖ M_i)(x_j) ≥ q·(1 − q)^(L−1)·Λ(M_i).

In the example of Theorem 5.1(d), Λ(M_1) = L·ln(1/w); a run asks at least one of its L calls with probability 1 − (1 − q)^L, the first answer of the human identifies f, and until then the mixture is M_1. So E[Λ(M_i)] = L·ln(1/w)·(1 − q)^(L(i−1)), and the sum over i is a geometric series. The number 1/(1 − (1 − 1/L)^L) increases from 4/3 at L = 2 to e/(e − 1) < 1.59. ∎

*Summary of Section 10.* Protocol R is online rehearsal with two changes: the run is answered by the frozen mixture alone, and the question is placed at one uniformly chosen call. With these changes the bound of Theorem 5.1 holds for the frozen mixtures with the constant 1; without them it holds with a constant between 1.58 and e (for large L). What the online form adds is that Theorem 10.1 needs no closed system: it holds for any process that produces the inputs. What it costs is that the human stays in the loop. Exact enumeration for small cases: Section 16.

## 11. The three remarks after Proposition R6 of the candidate theory

**Remark (i)** ("one question per rehearsal run is what the proof uses; more questions per run are harmless extra data"). MODIFIED: Proposition 5.3. More questions per run are harmless for the bound if one of them is at a uniformly chosen call; they do not improve the bound and can cost L times as many answers for the same mixtures; the proof cannot be changed to profit from them while the mixture is frozen during the run.

**Remark (ii)** ("the human only ever answers single calls; no run of the human system is needed"). PROVED, by inspection: in Protocol R (Definition 5.0) and in validation (Section 13) the human is asked the input of at most one call per round, n + m questions at most, and no statement of Sections 5 to 10, 12 and 13 uses a recorded run of the human system. Two qualifications belong with it. First, the questions are inputs of runs of the imitators, the poor early ones included. Assumption A1 is used at those inputs: the human is assumed to answer every x ∈ X, also an input that the human system itself would never produce, by a draw from P(·|x). Second, a single call need not be short; one call may stand for a long episode of work.

**Remark (iii)** ("the random round cannot be replaced by the last round in general, because learning curves are not monotone"). PROVED in the form of Propositions 6.2 and 6.3, with the reason corrected (Remark (ii) after Proposition 6.2), and complemented by Propositions 6.1 and 6.4: with a deterministic human the last round is as good as the random round up to L/n on scaffolds whose inputs do not depend on the answers, and on every scaffold it is worse by at most a factor of order L·ln n in the probability of an unfaithful run.

## 12. Proposition R3a: bounded damage implies tolerance of faults

**Lemma 12.1 (the Azuma–Hoeffding inequality with conditional ranges; standard).** Let 𝓗_0 ⊆ 𝓗_1 ⊆ … ⊆ 𝓗_L be σ-algebras and Δ_1, …, Δ_L bounded random variables such that, for every j, Δ_j is 𝓗_j-measurable, a_j ≤ Δ_j ≤ a_j + c_j for an 𝓗_{j−1}-measurable random variable a_j and a constant c_j ≥ 0, and E[Δ_j | 𝓗_{j−1}] ≥ μ_j for a constant μ_j. Then for every t ≥ 0,

  Pr[Σ_j Δ_j ≤ Σ_j μ_j − t] ≤ exp(−2t²/Σ_j c_j²).

If instead E[Δ_j | 𝓗_{j−1}] ≤ μ_j for every j, the same bound holds for Pr[Σ_j Δ_j ≥ Σ_j μ_j + t].

*Proof.* *Hoeffding's lemma.* Let U be a random variable with values in [0, 1] and conditional mean u given a σ-algebra 𝓗. For real λ the function v ↦ e^(λv) is convex, so e^(λU) ≤ 1 − U + U·e^λ and E[e^(λU) | 𝓗] ≤ 1 − u + u·e^λ = exp(ψ(λ)) with ψ(λ) := ln(1 − u + u·e^λ). Now ψ(0) = 0, ψ′(0) = u, and ψ″(λ) = p·(1 − p) ≤ ¼ with p := u·e^λ/(1 − u + u·e^λ); so ψ(λ) ≤ uλ + λ²/8, that is E[e^(λ(U−u)) | 𝓗] ≤ e^(λ²/8). *The inequality.* Let m_j := E[Δ_j | 𝓗_{j−1}] ≥ μ_j and s ≥ 0. Applying the lemma to U := (Δ_j − a_j)/c_j with λ := −s·c_j (if c_j = 0, then Δ_j = a_j = m_j and the next inequality is trivial) gives E[e^(−s(Δ_j − m_j)) | 𝓗_{j−1}] ≤ e^(s²c_j²/8), hence E[e^(−s(Δ_j − μ_j)) | 𝓗_{j−1}] ≤ e^(s²c_j²/8), because s·(m_j − μ_j) ≥ 0. By induction on L and the tower property, E[exp(−s·Σ_j (Δ_j − μ_j))] ≤ exp(s²·Σ_j c_j²/8). By Markov's inequality Pr[Σ_j (Δ_j − μ_j) ≤ −t] ≤ exp(−st + s²·Σ_j c_j²/8), and s := 4t/Σ_j c_j² gives the claim. The second statement is the first for −Δ_j. ∎

For independent variables this is Hoeffding's inequality (W. Hoeffding 1963, Theorem 2); the extension to martingale differences is noted there and is usually named after K. Azuma (1967). Both are quoted from memory; the proof above is complete.

**Proposition 12.2 (R3a: bounded damage). PROVED; the constant 8 of `note.md` is improved to 2, and the hypotheses are made explicit.** Let Π be a scaffold all of whose runs have exactly L calls. For j = 0, …, L let Φ_j be a measurable real function of the history h_{j+1} = (z, ρ, y_1, …, y_j) (a *progress function*; in `note.md`, Φ_j is a function φ of the state after call j). Suppose that there are numbers μ > 0 and D ≥ 0 such that for every j ≤ L and every history h_j, with x_j the input of call j:

(i) Σ_{y′∈Y} P(y′|x_j)·Φ_j(h_j, y′) − Φ_{j−1}(h_j) ≥ μ (an answer of the human raises Φ by at least μ in expectation);

(ii) |Φ_j(h_j, y′) − Φ_{j−1}(h_j)| ≤ 1 for every y′ ∈ Y with P(y′|x_j) > 0 (an answer of the human changes Φ by at most 1);

(iii) Φ_j(h_j, y) − Φ_{j−1}(h_j) ≥ −D for every y ∈ Y_⊥ (no answer lowers Φ by more than D).

Let η ∈ (0, 1] and G := {τ : Φ_L(τ) − Φ_0(z, ρ) ≥ (1 − η)·μ·L}. Then for every integer k ≥ 0 and every δ ∈ (0, 1) with

  k·(1 + D) + √(2L·ln(1/δ)) ≤ η·μ·L,  (12.1)

the human system tolerates k faults against 𝓡_all with failure δ. If P is a function, it tolerates k faults against 𝓡_all with failure 0 whenever k·(1 + D) ≤ η·μ·L.

(In this section μ is the drift of the progress function; it is not the constant of condition (8.1).)

*Proof.* Let r ∈ 𝓡_all make at most k replacements with probability 1, and consider the corrupted run: at call j the history is h_j, the human answers y′_j ~ P(·|x_j), and the rule passes y_j. Put

  Δ′_j := Φ_j(h_j, y′_j) − Φ_{j−1}(h_j),  Δ_j := Φ_j(h_j, y_j) − Φ_{j−1}(h_j),

the change that the human's answer would have caused, and the actual change; Φ_L(τ) − Φ_0(z, ρ) = Σ_j Δ_j. At a call without replacement Δ_j = Δ′_j. At a call with replacement Δ_j ≥ −D by (iii) and Δ′_j ≤ 1 by (ii), so Δ_j ≥ Δ′_j − (1 + D). Hence, almost surely,

  Σ_j Δ_j ≥ Σ_j Δ′_j − k·(1 + D).  (12.2)

Let 𝓗_j be the σ-algebra of everything realised up to and including the passed answer of call j (𝓗_0 contains z, ρ). By H1 the human's answer y′_j has the law P(·|x_j) given everything realised before it, which includes 𝓗_{j−1}; so E[Δ′_j | 𝓗_{j−1}] ≥ μ by (i), and −1 ≤ Δ′_j ≤ 1 by (ii). The hypotheses hold at every history, so they hold at the histories of the corrupted run. Lemma 12.1 with a_j = −1, c_j = 2 and t := √(2L·ln(1/δ)) gives Pr[Σ_j Δ′_j ≤ μL − t] ≤ exp(−2t²/(4L)) = δ. Outside this event, by (12.2) and (12.1), Σ_j Δ_j > μL − t − k·(1 + D) ≥ (1 − η)·μL. If P is a function, Δ′_j is determined by h_j and (i) says Δ′_j ≥ μ, so Σ_j Δ′_j ≥ μL surely and (12.2) alone suffices. ∎

**Remarks 12.3.** (i) *The statement of `note.md`* has √(8L·ln(1/δ)) in (12.1). That condition is stronger than (12.1), so the statement of the note is correct. The constant 8 arises if the centred variables are bounded by 2 in absolute value; their conditional range has length 2, which gives the constant 2. The exact failure probabilities of an extremal example are in Section 16.

(ii) *The rule sees the human's answer, and this is why the loss per fault is 1 + D and not μ + D.* Let all calls be at one input x₀, let the human answer u ("up") with probability (1 + μ)/2 and d ("down") otherwise, let b be a third answer, and Φ_j := Σ_{i≤j} s(y_i) with s(u) := 1, s(d) := −1, s(b) := s(⊥) := −D, where D ≥ 1. Then (i) to (iii) hold. The stateless rule that replaces u by b and leaves d, with the budget k, belongs to 𝓡_bst, and it is the budgeted rule κ_C^{≤k} of the kernel C(d|x₀) := (1 − μ)/2, C(b|x₀) := (1 + μ)/2: the imitator that gives the bad answer whenever the human would have given the good one. Under this rule every replacement lowers the total by exactly 1 + D, so the run is good if and only if Σ_j s(y′_j) ≥ (1 − η)·μL + k·(1 + D) (provided the human answers u at least k times). The sum Σ_j s(y′_j) has mean μL and standard deviation √(L·(1 − μ²)). So for k·(1 + D) = η·μL the failure probability is close to ½, and for k·(1 + D) = η·μL + 2√L it is close to 1 (0.49 and 0.98 for μ = 0.2, D = 3, η = ½, L = 1600; Section 16). Hence the term k·(1 + D) in (12.1) cannot be replaced by k·(μ + D), and the term of order √L cannot be dropped. A rule that does not see the human's answer and replaces k calls chosen in advance would lower the mean of the total by only k·(μ + D).

(iii) *With Theorem 8.4.* For a deterministic human take k := ⌊η·μL/(1 + D)⌋: by the last sentence of the proposition the tolerance has failure 0, k + 1 > η·μL/(1 + D), and Theorem 8.4(c) gives that the deployed run of M^(T) is outside G with probability at most

  (1 + D)·K ln 2/(η·μ·n),

whatever L. For a human who is not deterministic let L ≥ 8·ln(1/δ)/(η·μ)²; then √(2L·ln(1/δ)) ≤ η·μL/2, so (12.1) holds for k := ⌊η·μL/(2(1 + D))⌋, and Proposition 9.1(b) gives the failure probability δ + 2·(1 + D)·√(K ln 2/(2n))/(η·μ). This is the sentence after R3a in `note.md` ("the number of questions does not grow with the length of the run"), with its constants.

(iv) *What the proposition does not say.* Hypotheses (i) to (iii) are required at every history, also at those that only a corrupted run reaches: the human must make progress from wherever the run stands, and no single answer may set the run back by more than D. In a chain in which one wrong answer spoils everything, D is of the order of L and (12.1) allows k = 0 only. The proposition does not help to find a progress function.

## 13. Theorem V1: the validation certificate

**Definition 13.0 (validation).** An answerer A is *frozen* if it is fixed before validation and answers every run with fresh private coins, independently of all other runs given A. (A may have been obtained in any way, for example from the rehearsal; a frozen answerer may be randomised, and it may depend on the history of the run. An answerer that learns from one run to the next is not frozen.) Validation with m rounds: for i = 1, …, m,

1. a run τ_i of Π is generated with A answering every call, on a fresh (z_i, ρ_i);
2. J_i is drawn uniformly from {1, …, L}, independently of everything realised so far;
3. if J_i ≤ len(τ_i), the input x_i := x_{i,J_i} is put to the human, and the human's answer y^P_i ~ P(·|x_i) (H1) is recorded next to the answer y^A_i := y_{i,J_i} that A gave at this call in the run. Put a_i := 1[J_i ≤ len(τ_i)].

Nothing is updated. The human answers at most m questions. A round with J_i > len(τ_i) asks nothing; it stays in the count of the m rounds and contributes 0 to every frequency below.

**Theorem 13.1 (V1). PROVED, with additions.** Assume H1: the human answers every question by a fresh draw from P(·|x). P need not belong to any class (A2 is not used). Let A be frozen. All statements are conditional on A.

(o) The rounds are independent and identically distributed: the tuples (a_i, x_i, y^A_i, y^P_i), i ≤ m, are independent with a common law (when a_i = 0 the other three entries are a fixed dummy symbol).

(a) *Deterministic human.* Let P be a function f, N the number of calls of a run of A whose answer differs from f(x_j) (the unfaithful calls), and ρ := E[N]/L. The indicators d_i := a_i·1[y^A_i ≠ y^P_i] of a recorded disagreement are independent Bernoulli variables with mean ρ. Consequently:

 (a1) If ρ > ln(1/δ)/m, the probability that no disagreement is recorded in m rounds is less than δ. So the rule "if no disagreement is recorded, certify E[N] ≤ L·ln(1/δ)/m" issues a false certificate with probability less than δ, whatever A is.

 (a2) With ρ̂ := (1/m)·Σ_i d_i: with probability at least 1 − δ, ρ ≤ ρ̂ + √(2·ρ̂·ln(1/δ)/m) + 2·ln(1/δ)/m.

 (a3) A certified bound E[N] ≤ B may be used as β(A) ≤ B: the run of A is the run of the human system on the same (z, ρ) with probability at least 1 − B (Theorem 7.1(a), which holds for answerers by Lemma 3.2), and Theorems 8.4 and 8.6 apply with β(A) ≤ B. In Theorem 8.4 the tolerance must be against 𝓡_all if A depends on the history, and against 𝓡_bst if A is a kernel.

(b) *Any human.* A *test* is a set B ⊆ X × Y_⊥ of pairs (input, answer); write B_x := {y : (x, y) ∈ B}. Put

  a_A(B) := (1/L)·E #{j ≤ len : (x_j, y_j) ∈ B},  h_A(B) := (1/L)·E Σ_{j≤len} P(B_{x_j}|x_j),  Δ(B) := a_A(B) − h_A(B),

the expectations being over a run of A: a_A(B) is the frequency of B among the answers of A, per L calls, and h_A(B) the frequency with which the human's answer to the same calls would lie in B. Let â(B) := (1/m)·Σ_i a_i·1[(x_i, y^A_i) ∈ B] and ĥ(B) := (1/m)·Σ_i a_i·1[(x_i, y^P_i) ∈ B] be the recorded frequencies. Let 𝓑 be a countable family of tests with weights π(B) > 0, Σ_B π(B) ≤ 1; the family and the weights are fixed before validation (they may depend on A and on anything known before the validation rounds, and must not depend on the validation rounds).

 (b1) With probability at least 1 − δ, simultaneously for all B ∈ 𝓑: |Δ(B) − (â(B) − ĥ(B))| ≤ √(2·ln(2/(π(B)·δ))/m).

 (b2) With probability at least 1 − δ, simultaneously for all B ∈ 𝓑: if â(B) = 0 then a_A(B) ≤ ln(2/(π(B)·δ))/m, and if ĥ(B) = 0 then h_A(B) ≤ ln(2/(π(B)·δ))/m.

 (b3) *With A2: a certificate for the number of unfaithful calls.* Let A be a kernel, let H be a class with weights w, and for ν ∈ H let B_ν := {(x, y) : A(y|x) > ν(y|x)}. Then Δ(B) ≤ β(A)/L for every test B, and Δ(B_P) = β(A)/L. With probability at least 1 − δ, simultaneously for all ν ∈ H: Δ(B_ν) ≤ â(B_ν) − ĥ(B_ν) + √(2·ln(1/(w(ν)·δ))/m). So if P ∈ H and K ≤ K₀, then with probability at least 1 − δ

  β(A)/L ≤ max{ â(B_ν) − ĥ(B_ν) : ν ∈ H, w(ν) ≥ 2^(−K₀) } + √(2·(K₀·ln 2 + ln(1/δ))/m).

(c) *What is not certified when the human is not deterministic.* The rate of recorded disagreement says nothing about faithfulness: for A = P it equals (1/L)·E Σ_{j≤len} (1 − Σ_y P(y|x_j)²), which is positive unless P is a function on the inputs visited. And no finite family of tests bounds the number of unfaithful calls without an assumption on P: if Y is infinite and 𝓑 is finite, there are a function P and a function A with Δ(B) = 0 for every B ∈ 𝓑 and all calls of every run of A unfaithful.

*Proof.* (o) Given A, round i uses a fresh (z_i, ρ_i), fresh coins of A and a fresh J_i, and by H1 the human's answer is a draw from P(·|x_i) given everything realised before it. So the conditional law of the tuple of round i, given the earlier rounds, is one fixed law.

(a) y^P_i = f(x_i), and J_i is uniform and independent of τ_i, so Pr[d_i = 1] = E[(1/L)·Σ_{j≤len} 1[y_j ≠ f(x_j)]] = E[N]/L. (a1) (1 − ρ)^m ≤ e^(−ρm) < δ. (a2) For 0 < t ≤ ρ and s ≥ 0, E[e^(−s·mρ̂)] = (1 − ρ·(1 − e^(−s)))^m ≤ exp(−mρ·(1 − e^(−s))), so by Markov's inequality with e^(−s) := 1 − t/ρ and ε := t/ρ,

  Pr[ρ̂ ≤ ρ − t] ≤ exp(−mρ·(ε + (1 − ε)·ln(1 − ε))) ≤ exp(−mρ·ε²/2) = exp(−m·t²/(2ρ)),

because (1 − ε)·ln(1 − ε) ≥ −ε + ε²/2 on [0, 1). Put ℓ := ln(1/δ). If ρ ≤ 2ℓ/m there is nothing to prove. Otherwise t := √(2ρℓ/m) < ρ, and with probability at least 1 − δ we have ρ − √(2ρℓ/m) < ρ̂; with b := √(2ℓ/m) this reads (√ρ)² − b·√ρ − ρ̂ < 0, hence √ρ < (b + √(b² + 4ρ̂))/2 and ρ < ρ̂ + b²/2 + (b/2)·√(b² + 4ρ̂) ≤ ρ̂ + b² + b·√ρ̂. (a3) By Definition 8.2(a) the run of A is the run of the human system corrupted by r^A, with E[N] replacements in expectation; for a function f a replacement is a call with y_j ≠ f(x_j), and the run equals τ^f(z, ρ) if there is none.

(b) Put g_i(B) := a_i·(1[(x_i, y^A_i) ∈ B] − 1[(x_i, y^P_i) ∈ B]) ∈ {−1, 0, 1}. Since J_i is uniform and independent of τ_i, E[a_i·1[(x_i, y^A_i) ∈ B]] = a_A(B); and since y^P_i ~ P(·|x_i) given the run and J_i, E[a_i·1[(x_i, y^P_i) ∈ B]] = E[a_i·P(B_{x_i}|x_i)] = h_A(B). So the g_i(B) are independent with mean Δ(B) and range of length 2. (b1) By both parts of Lemma 12.1 (with c_j = 2 and the sum over the m rounds), Pr[|(1/m)·Σ_i g_i(B) − Δ(B)| ≥ t] ≤ 2·exp(−m·t²/2), which is π(B)·δ for the stated t; sum over B. (b2) If a_A(B) > ln(2/(π(B)·δ))/m, then Pr[â(B) = 0] = (1 − a_A(B))^m < π(B)·δ/2, and likewise for ĥ; sum over B. (b3) For a kernel A, a_A(B) = (1/L)·E Σ_{j≤len} A(B_{x_j}|x_j), so Δ(B) = (1/L)·E Σ_{j≤len} (A(B_{x_j}|x_j) − P(B_{x_j}|x_j)). For distributions a, p and any set S, a(S) − p(S) ≤ TV(a, p), with equality for S = {a > p}. This gives Δ(B) ≤ β(A)/L and Δ(B_P) = β(A)/L. The one-sided part of Lemma 12.1 gives Pr[Δ(B_ν) − (â(B_ν) − ĥ(B_ν)) ≥ t] ≤ exp(−m·t²/2) = w(ν)·δ for t = √(2·ln(1/(w(ν)·δ))/m); sum over ν. The last display is the case ν = P, with ln(1/w(P)) ≤ K₀·ln 2.

(c) The first statement is a computation: for A = P the two recorded answers are independent draws from P(·|x_i). For the second, the finitely many tests of 𝓑 partition X × Y_⊥ into finitely many cells (two pairs are in the same cell if they belong to the same tests). For every x there are, among the infinitely many pairs (x, y), y ∈ Y, two in the same cell, say (x, p(x)) and (x, a(x)) with p(x) ≠ a(x). Let P be the function p and A the function a. Then 1[(x, a(x)) ∈ B] = 1[(x, p(x)) ∈ B] for all x and all B ∈ 𝓑, so Δ(B) = 0, and every call of every run of A is unfaithful. ∎

**Corollary 13.2 (rehearse, validate, deploy). NEW.** Assume H1 and let P be a function f ∈ H. Run Protocol R with n rounds, then validate A := M^(T) (or the imitator that draws a fresh round for every run, which is frozen in the sense of Definition 13.0) with m rounds. The probability that no disagreement is recorded is at least 1 − m·ln(W/w(f))/n. So for n ≥ m·K ln 2/δ′ the certificate of (a1), E[N] ≤ L·ln(1/δ)/m, is issued with probability at least 1 − δ′; and whenever it is issued it is false with probability less than δ, whether or not f ∈ H.

*Proof.* Given A, the probability of at least one recorded disagreement is at most m·ρ(A), and E[ρ(M^(T))] = E[β(M^(T))]/L ≤ ln(W/w(f))/n by Proposition 5.2(a); for the fresh-round imitator ρ = β̄/L, with the same expectation. ∎

**Remarks 13.3.** (i) *What the certificate rests on.* On H1 for the validation questions; on A being frozen; on J_i being drawn after the run, independently of it, so that A cannot treat the call that will be examined differently from the others; on y^A_i being the answer used in the run and not a new draw (for an answerer with private coins or memory within the run a new draw would have another law); and on deployment being a run of the same scaffold, with (z, ρ) drawn from the same law, answered by the same A. It does not rest on A2, nor on any property of the way A was obtained. Each of these is needed: an answerer that knew J_i before answering could answer the examined call as the human does and all other calls at will; an answerer that changes after validation is not the one that was examined; and if a new draw were recorded in place of the answer used in the run, the certificate would be wrong for an imitator that draws one hypothesis per run: when each hypothesis errs only at inputs that its own runs visit, a newly drawn hypothesis is mostly right at the examined call although the run was not.

(ii) *Runs shorter than the drawn index.* Because a round with J_i > len(τ_i) counts as a round without disagreement, d_i has the mean E[N]/L exactly. If J_i were drawn uniformly from {1, …, len(τ_i)} instead, every round with a nonempty run would ask a question, and the recorded disagreements would be Bernoulli with mean E[N/len]; this is at least E[N]/L, so the certificates of (a) remain valid as bounds on E[N]/L, but the frequencies no longer estimate E[N]/L.

(iii) *The price of a test is the logarithm of the weight given to it before validation.* For a finite family of N₀ tests with equal weights the tolerance in (b1) is √(2·ln(2N₀/δ)/m), whatever the tests are; with π(B) := 2^(−K(B)) the price of a test is its complexity. The tests may be chosen after the rehearsal and after looking at the imitator, by any procedure; they need not be simple, and for the theorem they need not be decidable (to evaluate the recorded frequencies one must be able to decide membership for the recorded pairs). The same proof gives (b) for tests that are sets of pairs (history before the call, answer).

(iv) *What (b) certifies.* That the answers of A, at the inputs of A's own runs, lie in each test of the family about as often as the human's answers to the same inputs would, in the average over the calls of a run. It certifies nothing about any single input (each input is seen once), nothing about the joint behaviour of several answers of one run (the human answers one call per run), and, by (c), no bound on the number of unfaithful calls unless the family contains the right test, as it does in (b3) under A2. The tolerance of (b1) is of the order 1/√m; for tests that are never met, (b2) gives the order 1/m.

(v) *Several candidates.* If each of several frozen imitators is validated with its own m rounds and one that passes is deployed, the probability of a false certificate is at most the sum of the individual probabilities.

## 14. What remains open in this part

1. **The last round for a deterministic human on a scaffold whose inputs depend on the answers.** The ratio of E[β(M^(n+1))] to L·K ln 2/n can be of order √L (Proposition 6.3) and is at most of order L²·ln n (Proposition 6.4); the ratio of E[u(M^(n+1))] to L·K ln 2/n is at most of order L·ln n (Proposition 6.4), and no example with a ratio above a constant is known. The right orders are open. (A variant of the example of Proposition 6.3 with a separate routing input for every trap may give a factor of order L/ln L for the number of unfaithful calls; this has not been written out or checked.) Also open is whether the example of Proposition 6.3 can be built from functions only.
2. **The last round for a human who is not deterministic:** on a non-adaptive scaffold for weights with Σ_ν √(w(ν)) = ∞ (Proposition 6.1(b) needs the sum to be finite), and any upper bound at all on scaffolds whose inputs depend on the answers.
3. **The averaged kernel.** For the expected number of unfaithful calls of M̄ (a new round at every call) there is only β(M̄) ≤ L·u(M̄) ≤ L²·β̄; Proposition 5.5 settles the probability of an unfaithful run up to a constant. The human who is not deterministic is not treated.
4. **Constants.** Theorem 9.2 against Proposition 9.1: 0.088 against 0.59. Proposition 9.3: K/(32θ²) against K ln 2/(2θ²) for a fixed excess failure. Proposition 10.3: the factor lost by freezing after online rehearsal is between 1/(1 − (1 − 1/L)^L) and (1 − 1/L)^(−(L−1)), that is between 1.58 and e for large L.
5. **When does a human who is not deterministic cost 1/θ and not 1/θ²?** Proposition 9.3 shows that 1/θ² is needed for some human systems. A condition under which the linear rate holds (for example in terms of the variance of the cost-to-go under the human's own answers, as in the result of Foster, Block and Misra reported in `research/understand/imitation-theory.md`, Section 3.4) is not worked out.
6. **A single frozen imitator with high confidence.** For the mixture of a random round the factor 1/δ of Markov's inequality is needed (Proposition 5.2(d)). Corollary 13.2 obtains a certificate by validation; the best division of the answers between rehearsal and validation, and a selection among several rounds by validation, are not worked out.
7. **Bounded damage.** The term √(2L·ln(1/δ)) in (12.1) is of the right order for the example of Remark 12.3(ii). A form that uses the variance of the human's steps (Bernstein's inequality) would be smaller when the steps are rarely negative; it is not written. No method for finding a progress function is given.
8. **The certificate for tests.** The tolerance of Theorem 13.1(b1) is of the order 1/√m; a form with the variance of the test (of the order √(frequency/m) + 1/m for rare tests on both sides) is not written, only the one-sided form (b2).

The second half of the candidate's "sharper form" of R3, listed as open in the first version of this file, is not open: it is refuted by Example 5.5 of `research/prove/lower-bounds.md`.

## 15. Remarks on other files of the project

**`note.md`, Sections 1 to 3.** No statement there is false. The following should be changed or made exact.

1. *Deployment (Section 2).* "Draw T uniformly from {1, …, n} and deploy M^(T)" must say that one round is drawn for a whole run (or once for good). An imitator that draws a new round at every call is the averaged kernel M̄; its run can be unfaithful with a probability L times larger (Proposition 5.5).
2. *Notation.* The note uses m for the number of tolerated faults (Section 3.2) and for the number of validation rounds (Section 3.3); the outline fixes m for validation. This file writes k for the faults. In Protocol R, n is the number of rounds; the number of questions is at most n, because a round whose run is shorter than the drawn index asks nothing.
3. *Proof of R1.* "Π_t M^(t)(y_t|x_t) = Σ_ν w(ν)·Π_t ν(y_t|x_t)" holds with the factor 1/W on the right; since W ≤ 1 the inequality that follows is correct. "On every path" should read "almost surely" when the human is not deterministic. Before expectations are taken the summands must be shown to be integrable (Lemma 4.1(ii)); this is routine and belongs in the proof file.
4. *First remark after R1.* "Each question lowers its weight relative to the human's by an expected factor that depends on ρ only" is not exact: the factor depends on how the hypothesis answers, not only on how often it differs from the human. For a hypothesis and a human that are both functions the exact statement is that a question refutes the hypothesis with probability equal to the frequency of their disagreement among the calls of the rehearsal run. The theorem does not use such an account.
5. *Third remark after R1.* "They have the same distribution" should be: given the data before round t, the question of round t is a uniformly chosen call of a run of M^(t), and the deployed run for T = t is another run of the same kernel.
6. *Faithful calls (Section 1) and the proof of R3.* "The run of the imitator is a run of the human system in which the answers at the unfaithful calls were replaced" is true in the sense of Definition 3.3 and Proposition 3.4: after a replacement the later answers of the human are fresh answers to the inputs of the changed run. Only for a deterministic human is it the run on the same (z, ρ) with some answers overwritten. The replacement rule sees the human's answer; for a human who is not deterministic this matters (Remark (ii) after Theorem 8.4, Remark 12.3(ii)).
7. *Theorem R3.* Correct. For imitators that are kernels the hypothesis can be weakened to tolerance against budgeted stateless rules (Theorem 8.4(a), Example 8.5). The sentence for a human who is not deterministic needs the Cauchy–Schwarz inequality besides Pinsker's (Proposition 9.1); the order 1/θ² that results cannot be improved in general (Proposition 9.3). The recoverable form (Theorem 8.6) should stand next to it; it is the form of the literature.
8. *Proposition R3a.* Correct. The constant 8 can be 2. The statement needs: every run has exactly L calls; "from every state" includes the states reached after replaced answers; D is at least the largest decrease that an answer of the human can cause. For a deterministic human the square-root term is not needed.
9. *Theorem V1.* Correct. To be said: A is frozen and the recorded answer of A is the one used in the run; a round whose run is shorter than the drawn index counts as a round without disagreement; "Theorem R3 applies" needs tolerance against rules of the kind of A (against 𝓡_all if A looks at the history). Additions available: the bound (a2) when disagreements are recorded; the one-sided form (b2); the certificate (b3) for the number of unfaithful calls of a human who is not deterministic, under A2; Corollary 13.2.
10. *Assumption A3.* The clause "not predictable by any hypothesis" is automatic for hypotheses that are functions of the input alone. What the proofs use is H1 (Assumption 1.6), and for validation that the index J is drawn after the run.
11. *Literature (Section 2).* Besides Ross, Gordon and Bagnell (2011), the note should cite Li and Zhang (2025): their algorithm Stagger is Protocol R for a finite class with the uniform prior and a deterministic expert (Section 17).

**`research/candidate-theory.md`.** L1, L2, L3, R1, R2 for functions and R3 are correct as stated (with W ≤ 1). R3, "sharper form": the first half is Proposition 8.3; the second half is false (Example 5.5 of `research/prove/lower-bounds.md`). Remark (i) is modified (Proposition 5.3); the reason given for Remark (iii) is incomplete (Remark (ii) after Proposition 6.2). Section 13, V1(a): the imitator need not be deterministic. Section 0, item 3 ("about K/(θδ) questions suffice, whatever L") is for a deterministic human; for a human who is not deterministic the corresponding number is K ln 2/(2θ²δ²) (Proposition 9.1(b)).

**`research/prove/lower-bounds.md`.** Theorem 6.1 there can be stated with twice its constant: its step (i) bounds the total variation below by θ times the indicator of a wrong sign, and the triangle inequality gives 2θ for the sum over the two signs (Theorem 9.2 here). This is an improvement, not a correction.

**`research/prove-b/hellinger-runs.md`.** Section 8.2, item 5, and Section 8.1, item 3, list the last round as open. Propositions 6.1 to 6.4 here answer it in part: for a deterministic human the total variation between the run of the last mixture and the human system is u(M^(n+1)), bounded in Propositions 6.1(a) and 6.4; for a human who is not deterministic the last round stays open for whole runs, and Proposition 6.2 excludes a bound of the order L·K/n for the divergence.

**`research/understand/imitation-theory.md`.** Its high-probability form (b) of Section 5.2 agrees with Lemma 4.3(b) and Proposition 5.2(b) here (the digest states it for the squared Hellinger distance of the literature, which is twice H²).

## 16. Numerical checks

All scripts are in `research/prove-c/code/`; the output of each is saved in the file of the same name with the ending `.out`. Sampling is used only in `rehearsal-core_percall_and_stochastic.py`, part (1), and in `rehearsal-core_lastround_count_mc.py` (fixed seeds); the instances of check (5) of `rehearsal-core_checks.py` are drawn at random with a fixed seed and then evaluated exactly. Everything else is exact up to floating-point rounding.

**`rehearsal-core_r1_exact.py`** (Theorem 5.1, Proposition 5.3). Enumeration of all data histories of Protocol R on a scaffold with L = 2 and runs of variable length: z uniform on {0, 1}; call 1 at x = z; if z = 0, call 2 at 2 + y_1; if z = 1, STOP if y_1 = 0 and call 2 at x = 3 otherwise. Classes of five and six samplers. Output:

```
== R1, stochastic human, one question per run ==
n=6: sum_t E Lambda = 1.1929 <= L ln(1/w(P)) = 5.9915;  sum_t E[a_t kappa_t] = 0.5965 <= 2.9957;  avg E beta = 0.3411 <= L sqrt(ln(1/w)/(2n)) = 0.9993
== R1/R2, deterministic human, one question per run ==
n=6: sum_t E Lambda = 5.3713, sum_t E beta = 3.1461 <= 7.8240;  sum_t E[a_t kappa_t] = 2.6856 <= 3.9120
== every call asked (frozen mixture): no gain in the worst case ==
w(f)=0.01: Lambda(M^(1)) = 6.9308 = E[len] ln(1/w(f)) = 6.9308; sum_t E Lambda over 3 rounds, one question per run: 9.0707; all calls asked: 6.9308; ln(1/w(f)) = 4.6052; L ln(1/w(f)) = 9.2103
== Section 12 of the candidate theory: the counterexample ==
eps=0.01: joint KL = 4.6052 < sum of marginal KLs = 6.0227
```

In every line Σ_t E[Λ(M^(t))] = L·Σ_t E[a_t κ_t], as Theorem 5.1(a) says. The third block is the class {f ≡ 1, g ≡ 0} on this scaffold: with all calls asked the sum is Λ(M^(1)) = E[len]·ln(1/w(f)), which exceeds ln(1/w(f)); so the sum of the frozen divergences over the questions of a round is not bounded by the regret (Proposition 5.3(c)).

**`rehearsal-core_percall_and_stochastic.py`.** Part (1): the ladder of Proposition 5.5 with p = ½ and n = 20·L³; 300 simulated rehearsals, and given each rehearsal the two probabilities are computed exactly. Part (2): Theorem 9.2 for K = 1, L = 1 against the Bayes mixture of the two samplers.

```
L=10 n=20000: Pr[unfaithful run], one round per run: 0.00250 <= L K ln2/n = 0.00347; averaged kernel Mbar (a round per call): 0.00718 (proved >= 0.00563); ratio Mbar/bound = 2.07
L=20 n=160000: Pr[unfaithful run], one round per run: 0.00123 <= L K ln2/n = 0.00173; averaged kernel Mbar (a round per call): 0.00646 (proved >= 0.00563); ratio Mbar/bound = 3.73
L=40 n=1280000: Pr[unfaithful run], one round per run: 0.00063 <= L K ln2/n = 0.00087; averaged kernel Mbar (a round per call): 0.00650 (proved >= 0.00563); ratio Mbar/bound = 7.50
n=128: eps=0.0156; minimax lower bound eps/2 = 0.0078 = 0.0884/sqrt(n); Bayes mixture: E TV after n answers = 0.0139, average over rounds = 0.0147 <= sqrt(ln2/(2n)) = 0.0520
n=2048: eps=0.0039; minimax lower bound eps/2 = 0.0020 = 0.0884/sqrt(n); Bayes mixture: E TV after n answers = 0.0035, average over rounds = 0.0037 <= sqrt(ln2/(2n)) = 0.0130
```

The ratio of the averaged kernel to the bound of Theorem 5.1 doubles when L doubles.

**`rehearsal-core_lastround.py`** (Proposition 6.2). Forward recursion over the posterior states of the example, n = 4000.

```
L=5 n=4000 a=0.3333333333333333 ln(1/eta)=39 ln(1/phi)=400: avg_t E Lambda(M^(t)) = 0.12801 <= L K ln2 / n = 0.54913;  E Lambda(M^(n+1)) = 0.41942;  ratio last/bound = 0.764
L=10 n=4000 a=0.3333333333333333 ln(1/eta)=79 ln(1/phi)=800: avg_t E Lambda(M^(t)) = 0.65564 <= L K ln2 / n = 2.1983;  E Lambda(M^(n+1)) = 3.2974;  ratio last/bound = 1.500
L=20 n=4000 a=0.3333333333333333 ln(1/eta)=159 ln(1/phi)=1600: avg_t E Lambda(M^(t)) = 2.9871 <= L K ln2 / n = 8.7965;  E Lambda(M^(n+1)) = 25.379;  ratio last/bound = 2.885
L=40 n=4000 a=0.3333333333333333 ln(1/eta)=319 ln(1/phi)=3200: avg_t E Lambda(M^(t)) = 12.637 <= L K ln2 / n = 35.193;  E Lambda(M^(n+1)) = 198.8;  ratio last/bound = 5.649
L=40, n=4000: proved E Lambda(M^(n+1)) >= 172.19;  proved ratio to L K ln2/n >= 4.893 = 0.1255 (L-1)
```

**`rehearsal-core_lastround_count.py`** (Proposition 6.3). Forward recursion over the states (the family {g_S} is alive or not; number of questions at traps so far); the fraction of traps not yet asked enters through its conditional expectation (1 − 1/N)^c given c questions at traps, which is exact because β is linear in that fraction. Parameters of the proposition, n = 100·L:

```
L=100 n=10000 N=17 lambda=10.272 K=31.8 bits: sum_t<=n E beta = 1153 <= L K ln2 = 2206;  avg = 0.1153;  bound L K ln2/n = 0.2206;  E beta(M^(n+1)) = 0.11 (proved >= 0.05869);  ratio last/bound = 0.499 = 0.0499 sqrt(L);  proved ratio >= 0.266;  dropped mass 0.0e+00
L=400 n=40000 N=33 lambda=21.544 K=64.1 bits: sum_t<=n E beta = 9851 <= L K ln2 = 1.777e+04;  avg = 0.2463;  bound L K ln2/n = 0.4442;  E beta(M^(n+1)) = 0.3594 (proved >= 0.2332);  ratio last/bound = 0.809 = 0.0405 sqrt(L);  proved ratio >= 0.525;  dropped mass 0.0e+00
L=1600 n=160000 N=66 lambda=44.088 K=129.6 bits: sum_t<=n E beta = 8.159e+04 <= L K ln2 = 1.437e+05;  avg = 0.51;  bound L K ln2/n = 0.8984;  E beta(M^(n+1)) = 1.269 (proved >= 0.9345);  ratio last/bound = 1.412 = 0.0353 sqrt(L);  proved ratio >= 1.040;  dropped mass 0.0e+00
L=6400 n=640000 N=131 lambda=89.176 K=259.7 bits: sum_t<=n E beta = 6.627e+05 <= L K ln2 = 1.152e+06;  avg = 1.035;  bound L K ln2/n = 1.8;  E beta(M^(n+1)) = 4.73 (proved >= 3.726);  ratio last/bound = 2.628 = 0.0329 sqrt(L);  proved ratio >= 2.070;  dropped mass 0.0e+00
```

For n = 20·L the ratios are 0.498, 0.807, 1.408, 2.619: they differ from those above by less than half a percent. The column "proved" is the right side of (6.1).

**`rehearsal-core_lastround_count_mc.py`** (Proposition 6.3, an independent check of the recursion). Protocol R is simulated directly for small parameters: all 2^(N+1) hypotheses are kept with their likelihoods, and the mixture is computed from them. The simulated means agree with the recursion within the sampling error:

```
L=6 n=60 lambda=2.0 N=3: recursion: avg_t E beta = 0.20652, E beta(M^(n+1)) = 0.11425;  simulation (20000 rehearsals): avg_t = 0.20660, last = 0.11404;  bound L K ln2/n = 0.42064
L=8 n=80 lambda=3.0 N=4: recursion: avg_t E beta = 0.29415, E beta(M^(n+1)) = 0.15572;  simulation (10000 rehearsals): avg_t = 0.29397, last = 0.15535;  bound L K ln2/n = 0.58212
```

**`rehearsal-core_online.py`** (Section 10). Enumeration of the online form and of the variant with shadow questions on the scaffold of the first script, q = 1/L = ½. S_all is the sum of Theorem 10.1, S_wrong the expected number of unasked wrong answers, S_frozen = Σ_i E[Λ(M_i)], N_q the expected number of questions.

```
== stochastic human ==
r=3: online: S_all = 0.6312 <= ln(1/w)/q = 5.9915;  S_frozen = 0.6270 <= ln(1/w)/(q(1-q)^(L-1)) = 11.9829;  N_q = 2.832 <= r;  shadow: S_frozen = 0.6208 <= 11.9829
== deterministic human ==
r=3: online: S_all = 2.9730 <= 7.8240;  S_wrong = 0.9733 <= (1-q) ln(1/w)/q = 3.9120;  S_frozen = 2.8898 <= 15.6481;  shadow: S_frozen = 2.9318 <= 15.6481
== two hypotheses that differ everywhere (f = 1, g = 0): the loss against Protocol R is real ==
w(f)=0.01: sum over 6 runs of E Lambda(M_i): online 11.0369, shadow 11.0369;  Protocol R (one uniformly placed question): at most L ln(1/w) = 9.2103;  bound of 10.3: 18.4207
L=100: sum_i E Lambda(M_i) / (L ln(1/w)) = 1/(1-(1-1/L)^L) = 1.5774;  proved factor (1-1/L)^-(L-1) = 2.7047
```

**`rehearsal-core_checks.py`.** (1) Proposition 6.1(a) for L = 1 and the class of f and N functions that are each wrong on one of N disjoint regions of probability ε (exact, by the Markov chain of the number of regions asked); (1c) Proposition 6.1(b) for one input and classes of Bernoulli samplers; (2) Proposition 12.2 against the rule of Remark 12.3(ii), by exact binomial probabilities, with μ = 0.2, D = 3, η = ½; (3) Theorem 13.1(a); (4) Proposition 9.3(i); (5) Theorems 8.4 and 8.6 on 200 random instances with a human who is not deterministic (three calls, three answers, inputs that depend on the answers; all corrupted runs enumerated); (6) Proposition 6.4 on 40 random classes of 64 functions with a scaffold of three calls whose inputs depend on the answers and one rare branch (exact, by dynamic programming over the sets of inputs asked).

```
w(f)=0.0001: max over x of n*E[error of M^(n+1)] = 6.2326 at x=7;  ln(1/w) = 9.2103;  bound ln(1/w) + 1 = 10.2103      (N = 10^4, n = 10^5, eps = x/n)
human of small weight among six: max over n of n*E[H^2(P, M^(n+1))] = 0.9809 at n=200;  bound (1/2) ln(1/w(P)) + ln S + 1 = 6.4143
L=1600 delta=0.1 with sqrt(2 L ln(1/delta)): largest k = 18 (fraction 0.0112); exact failure = 1.178e-02 <= delta
L=1600 delta=0.1 with sqrt(8 L ln(1/delta)) [note.md]: the condition allows no k
L=6400 delta=0.01 with sqrt(2 L ln(1/delta)): largest k = 99 (fraction 0.0155); exact failure = 9.086e-04 <= delta
L=6400 delta=0.01 with sqrt(8 L ln(1/delta)) [note.md]: largest k = 38 (fraction 0.0059); exact failure = 2.654e-10 <= delta
L=1600: k = floor(eta mu L/(1+D)) = 40 (no square-root term): exact failure = 0.489
L=1600: k = floor((eta mu L + 2 sqrt(L))/(1+D)) = 60: exact failure = 0.978
delta=0.1 m=100: worst coverage failure over rho = 0.0077 <= delta;  rule 'no disagreement => rho <= ln(1/delta)/m': worst failure = 0.0881 <= delta
L=401 theta'=0.1 k=20: exact = 2.070e-02 <= bound = 1.333e-01
200 instances: max of Q_C(not G) - (delta_k + Pr[N >= k+1]) = 1.11e-16 (should be <= 0);  max of Pr[N >= k+1] - beta/(k+1) = -6.32e-03 (<= 0);  max of Q_C(not G) - (Q_P(not G) + mu beta) = -2.26e-01 (<= 0)
40 random classes: max over classes and n of E u(M^(n+1)) / (bound of Proposition 6.4) = 0.0041 (<= 1);  max of E u(M^(n+1)) / (L ln(1/w(f))/n) = 0.0629
```

In the line before the last the first maximum is rounding error: equality holds in the first inequality of Theorem 8.4 whenever the budget is not exhausted. The last line is far from the bound of Proposition 6.4; these random classes do not come near the worst case, and the check only shows that the bound is not contradicted.

No check contradicts a statement of this file. The checks are of small cases and prove nothing beyond them.

## 17. Literature used, and how

Every proof in this file is self-contained except for Pinsker's inequality. The other entries name the source of a standard argument or a neighbouring result.

* **Pinsker's inequality:** TV(p, q) ≤ √(KL(p ‖ q)/2), KL in nats. Standard; for example A. B. Tsybakov, *Introduction to Nonparametric Estimation*, Springer 2009, Lemma 2.5. Quoted from memory. Used in Proposition 9.1 and Theorem 9.2.
* **The regret bound for Bayes mixtures** (Lemma 4.1 here). Standard: R. J. Solomonoff, "Complexity-based induction systems: comparisons and convergence theorems", *IEEE Transactions on Information Theory* 24(4):422–432, 1978, for sequences (from memory); for pairs with adaptively chosen inputs, the first paper of this repository, Theorem 5.3, Proposition 5.7 and Theorem 8.4, as reported in `research/understand/repo.md` (items A7, A6, C2; digest, not opened by me). The proof here is self-contained.
* **Chain rule for relative entropy** (Lemma 2.1): T. M. Cover and J. A. Thomas, *Elements of Information Theory*, 2nd ed., Wiley 2006, Theorem 2.5.3 (from memory). Self-contained proof given.
* **Rehearsal as a reduction to online learning.** S. Ross, G. J. Gordon and J. A. Bagnell, "A reduction of imitation learning and structured prediction to no-regret online learning", *Proceedings of AISTATS 2011*, JMLR W&CP 15:627–635; arXiv:1011.0686. Read in this session (arXiv version 3, Section 2.2). Theorem 2.2 there: "Let π be such that E_{s∼d_π}[ℓ(s, π)] = ε, and Q^{π*}_{T−t+1}(s, a) − Q^{π*}_{T−t+1}(s, π*) ≤ u for all action a, t ∈ {1, 2, …, T}, d^t_π(s) > 0, then J(π) ≤ J(π*) + uTε", where Q^{π′}_t(s, π) is the t-step cost of executing π in the initial state s and then following π′, ℓ is the 0-1 loss with respect to the expert π* or an upper bound on it, and the cost C is bounded in [0, 1]. Theorem 8.6 is this statement for scaffolds, with a proof for replacement rules that see the human's answer.
* **One question per run.** Y. Li and C. Zhang, "Interactive and hybrid imitation learning: provably beating behavior cloning", NeurIPS 2025; arXiv:2412.07057. In this session I checked the bibliographic data and the abstract on arxiv.org (the abstract calls Stagger "a one sample per round variant of DAgger"); I did not read the paper. According to `research/understand/imitation-theory.md`, Section 3.5 (whose author read it): Stagger runs exponential weights under the logarithmic loss, played as the mixture at each step, on one state sampled from each rollout and labelled by the expert, and outputs a uniformly chosen iterate; for a deterministic expert in a finite class of size B that is μ-recoverable, with probability at least 1 − δ, J(π^E) − J(π̂) ≤ μH·(log B + 2·log(1/δ))/N. In the terms of this file that is Theorem 5.1(c) with Proposition 5.2(b) and Theorem 8.6 for the uniform prior on a finite class. What this file adds to it: weights on a countable class and semimeasures, the human who is not deterministic (Sections 5 and 9), the statements about the round (Propositions 5.2, 5.5, 6.1 to 6.3), tolerance of faults (Theorem 8.4), and the certificate (Section 13).
* **High-probability form** (Lemma 4.3(b)): D. J. Foster, S. M. Kakade, J. Qian and A. Rakhlin, "The statistical complexity of interactive decision making", arXiv:2112.13487, Lemma A.14, as quoted in `research/understand/imitation-theory.md` (digest; not opened by me): with probability at least 1 − δ the sum of the conditional expectations of the squared Hellinger distances is at most the regret plus 2·log(1/δ), in the convention in which the squared Hellinger distance is twice H². The proof of Lemma 4.3 is self-contained.
* **Hoeffding's and Azuma's inequalities** (Lemma 12.1): W. Hoeffding, "Probability inequalities for sums of bounded random variables", *Journal of the American Statistical Association* 58:13–30, 1963, Theorem 2 and the remark on martingales at the end of its Section 2; K. Azuma, "Weighted sums of certain dependent random variables", *Tôhoku Mathematical Journal* 19:357–367, 1967. From memory. Self-contained proof given.
* **Two-point and hypercube lower bounds** (Theorem 9.2, Proposition 9.3): the method of Le Cam and Assouad; B. Yu, "Assouad, Fano, and Le Cam", in *Festschrift for Lucien Le Cam*, Springer 1997, pp. 423–435 (from memory). Written out in full here; Theorem 6.1 of `research/prove/lower-bounds.md` is the same statement with half the constant.
* **The argument of Proposition 6.1(a)** is that of the bounds for learners consistent with independent examples: A. Blumer, A. Ehrenfeucht, D. Haussler and M. K. Warmuth, "Occam's razor", *Information Processing Letters* 24:377–380, 1987 (from memory). Their statement is for a finite class and one threshold; the form with weights and the integral over the threshold is written out here.
* **Asking at random** (Theorem 10.1): Observation A of `research/understand/notes.md`, Section 6.2, which is that digest's own derivation; the proof is repeated here. The digest names N. Cesa-Bianchi, G. Lugosi and G. Stoltz, "Minimizing regret with label efficient prediction", *IEEE Transactions on Information Theory* 51:2152–2162, 2005, as the nearest published setting (not read by me).
