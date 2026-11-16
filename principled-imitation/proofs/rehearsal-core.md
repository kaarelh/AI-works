# rehearsal-core: the rehearsal protocol (L1–L3, R1, R2 for a deterministic human, R3, R3a, V1)

The full proofs behind Sections 1 to 3 of the note (model; protocol "rehearse, validate, deploy"; what rehearsal guarantees). This is the corrected version of the prover's file `research/prove-c/rehearsal-core.md`. Two verifiers examined that file: a line-by-line check (`research/verify/rehearsal-core-check.md`, below "the check report") and an adversarial reading (`research/verify/rehearsal-core-attack.md`, below "the attack report"). Every finding of the two reports was decided by the editor and, where accepted, applied in place; Section 18 lists the findings, what was done about each, and which statements were checked by whom. Statements added in the edition are marked "added in the edition" and say who proved them.

"`note.md`" and "the candidate theory" (`research/candidate-theory.md`, version 2 and its Section 13) are the lead's unchecked drafts that this file was written to check; Section 15 records what in them had to change.

Tags: **PROVED** (a statement of the candidate theory or of the draft note, proved as stated or in the stated precise form), **MODIFIED** (the statement needed a change, which is named), **REFUTED** (with counterexample), **OPEN**, and **NEW**. The tag NEW means only that the statement is in neither of the lead's two drafts. It is not a claim that the statement is new to the literature: several NEW statements are standard or published, and the summary table and Section 17 say which.

## Summary table

| no. | statement | tag |
|---|---|---|
| 2.1 | L1, chain rule for runs of variable length, values in [0, ∞] | PROVED |
| 3.1 | maximal coupling of two distributions | PROVED (standard) |
| 3.2 | L2, coupling: E[number of unfaithful calls] = E_{Q_A} Σ_j TV, and TV(Q_A, Q_B) ≤ Pr[some call unfaithful] | PROVED (slightly sharper) |
| 3.4 | "the imitator's run is a run of the human system with the unfaithful calls replaced": exact sense, by a stateless randomised replacement rule | PROVED (sense made precise) |
| 4.1 | L3, Bayes regret on adaptive questions, with semimeasures, sub-probability weights, skipped rounds, all integrability | PROVED |
| 4.2 | L3 for a function: Π_t (1 − e_t) ≥ w(f)/W on every path | PROVED |
| 4.3 | high-probability forms: Σ_t E_{t−1}[a_t e_t] ≤ K ln 2 + ln(1/δ) (function); Σ_t E_{t−1}[a_t H²_t] ≤ (K ln 2)/2 + ln(1/δ) (general) | NEW to the drafts; published ((b) is Lemma A.14 of Foster, Kakade, Qian and Rakhlin 2021) |
| 4.4 | remarks: infinite divergences; normalising the mixture; without A2; (d) K may be read on the inputs that the scaffold can produce | PROVED; (d) added in the edition |
| 5.1 | R1: Σ_{t≤n} E Λ(M^(t)) ≤ L·ln(W/w(P)) ≤ L·K ln 2; the forms for H² and for a function; (d) equality is attained in (a), and the bound of (c) is approached | PROVED (for a finite class and a function, (c) is the estimation step of Li and Zhang 2025); (d) NEW |
| 5.2 | deploying M^(T), T a uniformly chosen round: (a) in expectation; (b) a fresh round for every run, with bounds of high probability over the rehearsal; (c) one round for good, by Markov's inequality; (d) the factor 1/δ in (c) is needed, for δ ≤ 0.63 | (a) PROVED; (b)–(d) NEW to the drafts ((a) and the rule itself are in Ross, Gordon and Bagnell 2011; (b) for a function is in Li and Zhang 2025) |
| 5.3 | several calls of one rehearsal run put to the human: the bound L·K ln 2 stays, it does not improve, and the sum of the frozen divergences is not bounded by the regret | MODIFIED (Remark (i) of the candidate theory made precise) |
| 5.5 | a new round at every call (the averaged kernel): the probability of an unfaithful run is at most L times larger (a), and a factor of order L occurs (b, the ladder) | NEW |
| 5.6 | R7, coverage: for every fixed set Q of inputs, the deployed run makes a call in Q although no question before round T lay in Q with probability at most L/n; no assumption on the human or the class | added in the edition (Theorem 3.2(a) of `research/prove-c/assumptions.md`) |
| 5.7 | audits that are not uniform: with audit probabilities π_j the same bound holds for the π-weighted sums | added in the edition (Proposition X5 of the attack report) |
| 5.8 | remarks: the guarantees are per run (questions × unfaithful calls ≤ deployed calls × K ln 2); answers of a deterministic human can be cached | added in the edition |
| 6.1 | last round, scaffold whose inputs do not depend on the answers: (a) deterministic human, E β(M^(n+1)) ≤ L·(K ln 2 + 1)/n; (b) any sampler, if Σ_ν √(w(ν)) < ∞ | NEW |
| 6.2 | last round, divergence: E Λ(M^(n+1)) ≥ ((L − 1)/8)·L·K ln 2/n in an example | PROVED (Remark (iii) of the candidate theory, by example; the reason given there is incomplete) |
| 6.3 | last round, number of unfaithful calls of a deterministic human: E β(M^(n+1)) ≥ ((L − 1)/(40√L))·L·K ln 2/n in an example whose class contains samplers that are not functions | NEW |
| 6.4 | last round, any scaffold, deterministic human: E u(M^(n+1)) ≤ 2L·B₀·(1 + ln(1/(2B₀))) + 2B₀ + 2L/n with B₀ = L·ln(W/w(f))/n, and E β(M^(n+1)) ≤ L times this; below 1 only when n exceeds 2L²·K ln 2 by a factor of about ln L + 3 | NEW |
| 7.1 | R2 for a function: the deployed run is the human system's run on the same (z, ρ) with probability ≥ 1 − L·K ln 2/n; TV(Q_C, Q_f) = Pr[run unfaithful] | PROVED |
| 8.3 | R3 with the robustness curve: failure ≤ δ̄_Π(E β); (d) the concave majorant is needed | PROVED (tagged [?] in the candidate theory); (d) NEW |
| 8.4 | R3: failure ≤ δ + β/(k + 1) if the human system tolerates k faults; tolerance is needed only against budgeted stateless rules when the imitator is a kernel | PROVED, and MODIFIED (weaker hypothesis) |
| 8.5 | examples: (a) equality in R3; (b), (c) the three classes of replacement rules give different notions of tolerance; (d) tolerance of faults that are placed without sight of the human's answer does not give R3 | NEW; (d) added in the edition (attack report, m4; check report, part E) |
| 8.6 | recoverable form: E cost ≤ E_{Q_P} cost + μ·β, with no Markov step | NEW to the drafts; standard (Ross, Gordon and Bagnell 2011, Theorem 2.2) |
| 9.1 | any sampler: E β(M^(T)) ≤ L·√(K ln 2/(2n)); R3 with √(K ln 2/(2n))/θ | PROVED |
| 9.2 | every protocol has E β ≥ 0.088·L·√(K/n) for some member of a class with K bits | NEW to the drafts (the method of Assouad; standard) |
| 9.3 | low stakes with a human who is not deterministic: of the order K/θ² questions are needed in an example (for failure γ ≤ ½), against K/θ for a deterministic human | NEW |
| 9.4 | low stakes with a human who is not deterministic, second bound: Pr[more than k unfaithful calls] ≤ 2e²·L·Λ/(k + 1)² + 2^(−(k+1)), hence excess failure 2e²·K ln 2/(θ²·n) + 2^(−θL) | added in the edition (Proposition X4 of the attack report) |
| 10.1 | online form (every call put to the human with probability q): Σ_t E KL ≤ K ln 2/q | PROVED (Observation A of `research/understand/notes.md`) |
| 10.2 | online rehearsal in a closed system has the price of Protocol R | NEW |
| 10.3 | freezing after online rehearsal: the bound of R1 with a factor at most e, and a factor of at least 1.33 does occur | NEW |
| 11 | Remarks (i), (ii), (iii) after R6 of the candidate theory | (i) MODIFIED, (ii) PROVED, (iii) PROVED in the form 6.2, 6.3 (and limited by 6.1, 6.4) |
| 12.1 | Azuma–Hoeffding inequality with conditional ranges | PROVED (standard) |
| 12.2 | R3a, bounded damage: if every run has exactly L calls, tolerance of k faults whenever k·(1 + D) + √(2L·ln(1/δ)) ≤ η·μ·L | PROVED with the constant 2 in place of 8; the statement of `note.md`, which does not require runs of exactly L calls, is REFUTED (Remark 12.3(v)) |
| 12.3 | the term k·(1 + D) cannot be k·(μ + D), because the rule sees the human's answer; the term of order √L cannot be dropped; (v) the counterexample for runs that may stop early | NEW; (v) added in the edition (attack report, m1) |
| 13.1 | V1: (o) the rounds are independent; (a) the certificate from recorded disagreements, valid for every human, issued only if the human is nearly deterministic on the inputs visited; (b) tests, for any human; (c) what tests and disagreements do not certify | PROVED; (a0), (a2), (b1′), (b2), (b3), (c) NEW ((a0), (b1′) and the corrected (c) added in the edition) |
| 13.2 | rehearse, validate, deploy: the certificate is issued with probability ≥ 1 − m·K ln 2/n | NEW |
| 13.4 | two humans that validation cannot tell apart: without A2 no certificate that a randomised imitator of a human who is not deterministic has few unfaithful calls, from single answers at inputs that do not repeat, nor from any answers when the answer set is large | added in the edition (statement (c′) of the check report; Proposition X2 of the attack report) |
| 13.5 | repeated questions: β(A)/L certified up to ½·√((s − 1)/r) for an answer set of s elements and r answers per audited input | added in the edition (Proposition X3 of the attack report) |
| 14 | open questions of this part | OPEN |

**In brief.** (1) R1, R2 for a deterministic human and R3 are correct as stated in `note.md`. R3a as stated there is false for a scaffold whose runs can stop early; with the hypothesis that every run has exactly L calls it holds, and with the constant 2 in place of 8. V1 needs the hypothesis that the answerer is frozen. R3 needs tolerance only against a smaller class of replacement rules, but the rules must see the human's answer. (2) "Deploy the mixture of a uniformly chosen round" must mean one round per run or one round for good. A new round at every call is a different imitator, and its run can be unfaithful with a probability of the order of L times larger (at most L times; about L/4 times in an example). (3) The last mixture can replace the random round on scaffolds whose inputs do not depend on the answers when the human is deterministic, at the price of the additive term L/n. In general it cannot: it can be worse than the bound by a factor of order L in the divergence and, for a deterministic human in a class that contains samplers that are not functions, by a factor of order √L in the number of unfaithful calls (for a class of functions this is open). For a deterministic human it is never worse by more than a factor of order L·ln n in the probability of an unfaithful run (L²·ln n in the number of unfaithful calls); whether the probability of an unfaithful run can be worse by more than a constant is open. For a deterministic human, validation certifies whichever imitator is deployed, so the choice need not rest on these bounds. (4) For a human who is not deterministic the bound on the number of unfaithful calls is of the order L·√(K/n), and no protocol does better on every class; under low stakes this costs of the order K/θ² questions where a deterministic human costs K/θ, and in an example that many are needed. (5) Putting every call to the human with probability 1/L, online, is the same protocol up to a constant below e. (6) Validation certifies, for any frozen imitator and with no assumption on the human beyond A1, an upper bound on the expected number of unfaithful calls from the recorded disagreements; this certificate is valid for every human, but it can come out small only if the human is nearly deterministic on the inputs visited. For other humans validation certifies frequencies of tests, and under A2 also the number of unfaithful calls, at the rate √(K/m); without A2 no procedure certifies from single answers that a randomised imitator has few unfaithful calls (Proposition 13.4). (7) Every bound contains K. For a person under a generic prior K is of the order of 10⁹ bits, and there R1 and R3 are empty: at one hour per answer, R1 with L = 10 and failure 0.1 costs 350 years of answers already for K = 10⁴. The certificate does not contain K (300 rounds certify an excess failure 0.1 under θ = 0.1); it certifies an imitator and does not produce one. All guarantees are per run: a fixed number of questions buys a constant rate of unfaithful calls for as long as the imitator is used (Remark 5.8).

## 0. Conventions and changes of notation

* Logarithms are natural unless written log₂. K := log₂(1/w(P)), so ln(1/w(P)) = K ln 2.
* **Change of notation 1.** The candidate theory uses T both for the number of calls of a run (Section 1) and for the uniformly random round (Protocol R). Following `research/outline.md`, **T** is the uniformly chosen round whose mixture is deployed, and the deployed imitator is M^(T). The number of calls of a run τ is written **len(τ)**, or len when the run is clear from the context (as in `proofs/hellinger-runs.md`); for the rehearsal run of round t it is len_t.
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

**Remark 1.7 (A3 in five parts, and the closed deployment; added in the edition).** The note states A3 in five parts. Parts (i) to (iv) are those of `research/prove-c/assumptions.md`, Section 0.2; part (v) is the one that the adversary of that part found missing (`research/verify/assumptions-attack.md`, finding M3, with a counterexample in which rehearsal runs come from a generator with a short seed). In this file the five parts are written into Assumption 1.6 and into the definitions of the protocol, as follows.

* (i) *The asked call is uniform given the run.* Step 3 of Definition 5.0 and step 2 of Definition 13.0: the index J is drawn uniformly from {1, …, L}, independently of everything realised so far, the run included. Used in Theorem 5.1(a) (the conditional mean of the asked term is 1/L times the sum over the calls of the run), in Proposition 5.6 and in Theorem 13.1.
* (ii) *Deployment is a further sample.* The last sentences of Definition 5.0: T is uniform on {1, …, n} and independent of 𝓕_n, and the deployed run is a run of M^(T) on a fresh pair (z, ρ) ~ D₀ ⊗ λ with fresh draws of the mixture. Used wherever a statement about the rehearsal run of round t is carried over to the deployed run (Proposition 5.2, Proposition 5.6, Theorem 7.1).
* (iii) *The class is fixed first.* H and w of Definition 1.2 are fixed objects, not functions of any coin of the protocol or of the human. Used in Lemma 4.1(i): the inequality ξ(D_n) ≥ w(P)·P(D_n) is of use only if w(P) does not depend on the data.
* (iv) *The human is shown what the imitator was shown.* The question put to the human is the input string of the chosen call, and the answer is a draw from P(·|x) given everything realised before it (Assumption 1.6): nothing the human perceives distinguishes a question of rehearsal or validation from the same string inside a run.
* (v) *Every run uses fresh coins.* Step 2 of Definition 5.0 and step 1 of Definition 13.0: given the past, the run of round t is a run of the current imitator on a fresh (z_t, ρ_t) ~ D₀ ⊗ λ with fresh draws of the imitator, so that its conditional law is Q_{M^(t)}. Used where a conditional expectation over the run of round t is identified with one of the functionals Λ, β, χ of the frozen kernel (Theorem 5.1).

The note calls a deployment *closed* if three conditions hold (`research/prove-c/assumptions.md`, Definition 4.1, with the two corrections of the reports on that part: (C2) is a statement about the runs that were used, and in (C3) the answers may depend on the history of the run). (C1) *One more sample:* given everything the protocol saw and did, the pair (z*, ρ*) of the run that counts has the law D₀ ⊗ λ, and the coins of the imitator in that run are fresh. (C2) *Sampled in advance:* the runs of rehearsal and validation were generated by the protocol, answered by the imitator of the round, on fresh pairs with the law D₀ ⊗ λ, independent of (z*, ρ*). (C3) *Nothing else gets in:* the inputs of the run that counts are the strings next_j(z*, ρ*, y_1, …, y_{j−1}), and the answers depend on the history of that run and on the imitator's coins alone. (C1) and (C3) are part (ii) for the run that counts; (C2) is part (v). Every statement of Sections 5 to 9, 12 and 13 about a deployed run is a statement about a closed deployment. Lemma 4.1 and Theorem 10.1 make no assumption on how the inputs arise.

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

(With the maximal inequality for nonnegative martingales in place of Markov's inequality the statement holds for all n simultaneously. Part (b) is published: it is the form used in the imitation-learning literature, Lemma A.14 of Foster, Kakade, Qian and Rakhlin 2021. The author of `research/sections/related-work.md` read that lemma in the arXiv text; neither the prover nor the editor opened the paper. The proof above is self-contained.)

**Remark 4.4.** (a) *Infinite divergences.* KL(P ‖ M_D)(x) is finite on every data list that can arise, by (1.1). KL(P ‖ ν)(x) can be infinite for single hypotheses ν; this plays no role when P ∈ H.

(b) *Normalising the mixture.* If M_D(⊥|x) < 1, the sampler M^norm_D(y|x) := M_D(y|x)/(1 − M_D(⊥|x)) satisfies KL(P ‖ M^norm_D)(x) = KL(P ‖ M_D)(x) + ln(1 − M_D(⊥|x)) ≤ KL(P ‖ M_D)(x). So 4.1(iii) holds with M^norm in the definition of κ_t (the posterior weights are still computed from the unnormalised likelihoods), and every upper bound of Sections 5 to 10 holds for the protocol that uses M^norm both to drive the rehearsal runs and as the deployed imitator (TV, H² and KL from P to M^norm are at most those from P to M, because P gives ⊥ no mass). The imitator then never answers ⊥.

(c) *Without realisability* (not used below). If P ∉ H, then for every ν ∈ H with Σ_t E[a_t KL(P ‖ ν)(x_t)] < ∞ the same computation, with ξ(D_n) ≥ w(ν)·ν(D_n), gives Σ_t E[a_t κ_t] ≤ ln(W/w(ν)) + Σ_t E[a_t KL(P ‖ ν)(x_t)]. Under Protocol R the second term is the comparator's divergence on the inputs that the mixtures' runs visit, which no assumption of the candidate theory controls.

(d) *Which K (added in the edition; Proposition X7 of the attack report, and Proposition 2.2 of `research/prove-c/assumptions.md`).* Let X₀ ⊆ X contain every input that is ever put to the human (under Protocol R: every input that occurs in some run of Π under some answers), let [P] := {ν ∈ H : ν(·|x) = P(·|x) for all x ∈ X₀} and w([P]) := Σ_{ν∈[P]} w(ν). Then Lemmas 4.1 to 4.3 hold with w([P]) in place of w(P), and they need only w([P]) > 0, not P ∈ H. Indeed every member of [P] has the likelihood P(D_n) on data whose inputs lie in X₀, so ξ(D_n) ≥ w([P])·P(D_n), and M_D(y|x) ≥ w_D([P])·P(y|x) for x ∈ X₀; these two inequalities are all that the proofs of Section 4 use of P ∈ H. Consequently the bounds of Sections 5 to 10 (which use P ∈ H only through Lemmas 4.1 to 4.3 and through the inequality ξ(D_n) ≥ w(P)·P(D_n) itself) hold with K read as log₂(1/w([P])): the number of bits that the prior needs to single out the human's behaviour on the inputs that the scaffold can produce. This is a real reduction when those inputs are few, and none when the scaffold can pose arbitrary questions. (Theorem 13.1(b3) uses one member of the class: there K may be read as the least log₂(1/w(ν)) over ν ∈ [P].)

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

(d) The inequalities in (a) and (c) cannot be improved in general. (d1) *Equality in (a).* For every L ≥ 1 and w ∈ (0, 1) there are a class of two functions with W = 1 and w(f) = w and a scaffold of horizon L with Σ_{t≤n} E[Λ(M^(t))] = L·ln(1/w) for every n ≥ 1; in this example Σ_{t≤n} E[β(M^(t))] = L·(1 − w), which is below the bound L·ln(1/w) of (c). (d2) *The bound of (c) is approached.* For every L ≥ 1, w ∈ (0, 1) and N ≥ 1 there are a class of N + 1 functions with W = 1 and w(f) = w and a scaffold of horizon L with

  Σ_{t=1}^{∞} E[β(M^(t))] = L·Σ_{k=0}^{N−1} ((1 − w)/N)/(1 − k·(1 − w)/N),

which tends to L·ln(1/w) as N → ∞.

*Proof.* (a) Protocol R is an instance of Setting 4.0 with 𝓖_t := σ(𝓕_{t−1}, τ_t, J_t): a_t and x_t are 𝓖_t-measurable, and by H1 the answer has the law P(·|x_t) given 𝓖_t on {a_t = 1}. With κ_t := KL(P ‖ M^(t))(x_t) as in Setting 4.0, Lemma 4.1(iii) gives Σ_t E[a_t κ_t] ≤ ln(W/w(P)), and κ_t is finite by 4.1(ii). Given 𝓕_{t−1} and τ_t, the index J_t is uniform on {1, …, L}, so E[a_t κ_t | 𝓕_{t−1}, τ_t] = (1/L)·Σ_{j≤len_t} KL(P ‖ M^(t))(x_{t,j}). Given 𝓕_{t−1}, the kernel M^(t) is fixed (it is a function of the data list D_{t−1}, which takes countably many values) and τ_t has the law Q_{M^(t)}. Hence E[a_t κ_t | 𝓕_{t−1}] = Λ(M^(t))/L. All quantities are nonnegative, so the expectations may be taken term by term. (b) The same computation with H² in place of KL, and H² ≤ KL/2 (Definition 1.5). (c) The pathwise statement is Lemma 4.2. The conditional expectation is computed as in (a), with TV(f, M^(t))(x) = e_{M^(t)}(x). Finally e_t ≤ −ln(1 − e_t) = κ_t, so the sum of the expectations is at most that in (a).

(d1) Let X = {x_1, …, x_L}, Y = {0, 1}, and let the scaffold have no top-level input and no randomness and make call j at x_j for j = 1, …, L. Let f ≡ 1 and g ≡ 0 with w(f) = w and w(g) = 1 − w. Then M^(1)(1|x) = w for every x, so Λ(M^(1)) = L·ln(1/w) and β(M^(1)) = L·(1 − w). Every run has L calls, so round 1 puts a question to the human; the answer is 1 and gives g the likelihood 0. Hence M^(t) = f, and Λ(M^(t)) = β(M^(t)) = 0, for all t ≥ 2.

(d2) (The example is the check report's.) Let X = {x_1, …, x_N}, Y = {0, 1}, f ≡ 0 with w(f) = w, and g_i(x) := 1[x = x_i] with w(g_i) := (1 − w)/N for i = 1, …, N. The scaffold draws z uniformly from {1, …, N} and makes all its L calls at x_z. Every run has L calls, so every round puts the question x_z to the human, and the answer 0 refutes g_z and no other member. When k distinct inputs have been asked, the posterior gives f the weight w/(1 − k·(1 − w)/N) and each of the N − k remaining g_i the weight ((1 − w)/N)/(1 − k·(1 − w)/N). The mixture then answers wrongly at an input that has not been asked with the latter probability, and correctly at an input that has been asked; so β(M) = L·((N − k)/N)·((1 − w)/N)/(1 − k·(1 − w)/N). The number of rounds that begin with exactly k inputs asked is geometric with mean N/(N − k). Multiply and sum over k = 0, …, N − 1. The sum is a Riemann sum of ∫_0^{1−w} du/(1 − u) = ln(1/w) with the integrand taken at the left end of each interval; the integrand increases, so the sum is below the integral and tends to it as N → ∞. For w = 0.01 the sum, divided by L, is 2.78, 4.19 and 4.60 for N = 10, 100 and 10⁴, against ln(1/w) = 4.605 (`proofs/code/rehearsal-core_editor_checks.out`, block 1, which also evaluates the sum over the rounds t ≤ n exactly for N = 10). ∎

*What Theorem 5.1 does not say.* It bounds a sum over the rounds and says nothing about a single round (Section 6). It concerns the frozen kernels M^(t) along their own runs: step 2 must be driven by M^(t) alone, and the bound says nothing about M^(t) on inputs that its own runs do not visit. It is an average over runs: at an input that the runs reach with a probability below about L·K ln 2/n the mixture may answer in any way, and no protocol can exclude this (Theorem N1 of the note; `proofs/lower-bounds.md`). The constant is ln(1/w(P)): the statement is empty for n below L·K ln 2. With one hour for an answer and 2000 hours to the year, n = L·K ln 2/0.1 questions (an expected number of unfaithful calls of 0.1 for a deterministic human) are 3.5 years of answers for K = 100 bits and L = 10, 350 years for K = 10⁴, and 3.5·10⁷ years for K = 10⁹, which is the order of K for a person under a generic prior according to Section 9 of the note (`proofs/code/rehearsal-core_editor_checks.out`, block 7; the table of the attack report, finding M2, has more cases).

*The hypotheses, and why each is needed.* (i) *The index J_t is drawn independently of the run, and every call has its chance.* Let L = 2 with call 1 at x_1 and call 2 at x_2, let the class be {f, g} with W = 1, and let g agree with f at x_1 and differ at x_2. If the question were always put at call 1, g would never be refuted, M^(t) would stay the prior mixture, and Λ(M^(t)) = ln(1/w(f)) for every t. Uniformity itself is not needed: with other probabilities for the calls the same proof bounds the sums weighted by these probabilities (Proposition 5.7). What cannot be dropped is that the index is random given the run: an index computed from the run by a rule that a hypothesis can also compute lets that hypothesis err exactly at the calls that are not asked (`research/prove-c/assumptions.md`, Example 3.3). (ii) *The run of step 2 is answered by M^(t) alone.* If the rehearsal runs were answered by another kernel C₀, the questions would be calls of runs of C₀, and the same proof would bound the divergences along the runs of C₀; it would say nothing about the inputs that only the runs of M^(t) visit. (iii) *A2.* If H consists of one sampler different from P at the inputs visited, Λ(M^(t)) is a positive constant; Remark 4.4(c) states what remains without A2. (iv) *H1.* The identity of Lemma 4.1(i) holds for whatever answers are given. It becomes a statement about P only because each answer is a fresh draw from P(·|x) given everything before it; a human whose answer depends on the earlier questions, or on whether the call belongs to a rehearsal, is not covered.

*Literature.* Neither the protocol nor the observation behind it is new. The inequality of Lemma 4.1 is the standard regret bound for Bayes mixtures (Section 17 gives the sources: Solomonoff 1978 for the squared-error form on binary sequences, Hutter 2003, Theorem 1, for the divergence form on countable classes, Solomonoff 2008 for question–answer pairs, and Proposition 5.7(b) of the repository's first paper for the per-query mixture with inputs chosen from the earlier pairs). That a learner without regret, trained on the inputs that its own behaviour produces, imitates well on those inputs is the reduction of Ross, Gordon and Bagnell (2011), who also deploy one uniformly chosen iterate for a whole episode. Protocol R with a finite class under the uniform prior and a deterministic human is the algorithm "Stagger" of Li and Zhang (2025): exponential weights under the logarithmic loss, one state of each rollout put to the expert, a uniformly chosen iterate deployed for a whole episode. Part (c) is the estimation step of the proof of their Theorem 3, with ln(1/w(f)) in place of the logarithm of the size of the class. What this file adds to these is modest: weights on a countable class (so that the bound is in K), hypotheses that are semimeasures, a human who is not deterministic (parts (a), (b), Section 9), and the statements about the round, about tolerance of faults and about the certificate.

**Proposition 5.2 (deploying the mixture of a uniformly chosen round). (a) PROVED; (b) to (d) NEW.** Under the assumptions of Theorem 5.1:

(a) *In expectation.* E[Λ(M^(T))] ≤ L·ln(W/w(P))/n ≤ L·K ln 2/n and E[χ(M^(T))] ≤ L·ln(W/w(P))/(2n). If P is a function f, E[β(M^(T))] ≤ L·ln(W/w(f))/n.

(b) *A fresh round for every run.* Let every deployed run draw its own round (independent, uniform on {1, …, n}) and be answered throughout by the mixture of that round. Conditionally on 𝓕_n the deployed runs are independent with the common law Q̄ := (1/n)·Σ_{t≤n} Q_{M^(t)}, and the expected number of unfaithful calls of a deployed run is β̄ := (1/n)·Σ_{t≤n} β(M^(t)). If P is a function f, then for every δ ∈ (0, 1), with probability at least 1 − δ over the rehearsal,

  β̄ ≤ L·(ln(W/w(f)) + ln(1/δ))/n.

In general, with probability at least 1 − δ over the rehearsal, χ̄ := (1/n)·Σ_{t≤n} χ(M^(t)) ≤ L·(½·ln(W/w(P)) + ln(1/δ))/n and β̄ ≤ √(2L·χ̄) ≤ L·√((ln(W/w(P)) + 2·ln(1/δ))/n).

(c) *One round for good.* Let T be drawn once and M^(T) be used for every later run. For every δ ∈ (0, 1), with probability at least 1 − δ over the rehearsal and T: Λ(M^(T)) ≤ L·ln(W/w(P))/(n·δ). If P is a function f, then with probability at least 1 − δ over the rehearsal and T: β(M^(T)) ≤ L·ln(W/w(f))/(n·δ). If the two sources of randomness are to be kept apart: for δ₁, δ₂ ∈ (0, 1), with probability at least 1 − δ₁ over the rehearsal, at most a fraction δ₂ of the rounds t ≤ n have β(M^(t)) > L·(ln(W/w(f)) + ln(1/δ₁))/(n·δ₂).

(d) *The factor 1/δ in (c) is needed.* For every n ≥ 1 and δ ∈ [1/n, 1] there are a class of two functions with K = 1 and a scaffold with L = 1 (both depend on n and δ) such that β(M^(T)) = 1/(2δn) with probability at least (1 − e^(−1/δ))·δ > 0.63·δ. So if a bound of the form "β(M^(T)) ≤ φ(δ′)·L·K ln 2/n with probability at least 1 − δ′" holds for all classes, scaffolds and n, then φ(δ′) > 0.45/δ′ for every δ′ ∈ (0, 0.63]. For δ′ above 0.63 the example shows nothing.

*Proof.* (a) E[Λ(M^(T))] = (1/n)·Σ_t E[Λ(M^(t))], and likewise for χ and β; then Theorem 5.1. (b) Given 𝓕_n the kernels M^(1), …, M^(n) are fixed, and each deployed run uses its own round, top-level input, randomness and draws; this gives the independence and the law Q̄. Given 𝓕_n and the round t of a run, its expected number of unfaithful calls is β(M^(t)) (Proposition 3.4(b)); average over t. For a function, Lemma 4.3(a) says that with probability at least 1 − δ, Σ_{t≤n} E[a_t e_t | 𝓕_{t−1}] ≤ ln(W/w(f)) + ln(1/δ), and the left side is n·β̄/L by Theorem 5.1(c). In general, Lemma 4.3(b) and Theorem 5.1(b) give the bound on χ̄ in the same way; β(M^(t)) ≤ √(2L·χ(M^(t))) by Definition 1.5, and the square root is concave, so β̄ ≤ √(2L·χ̄). (c) Markov's inequality for Λ(M^(T)) ≥ 0 and for β(M^(T)) ≥ 0, whose means are bounded in (a). For the third statement, the event of (b) with δ₁ has probability at least 1 − δ₁ and depends on 𝓕_n only; on that event, by Markov's inequality for the uniform distribution on the rounds, at most a fraction δ₂ of the rounds have β(M^(t)) > β̄/δ₂. (As a statement about M^(T) the direct form is the stronger one: for δ = δ₁ + δ₂ its bound is the smaller. The check report pointed this out.)

(d) Let X = {x₀, x₁}, Y = {0, 1}, q := 1/(δn) ≤ 1, and let the scaffold make one call, at x₁ with probability q and at x₀ otherwise. Let f ≡ 0 and let g agree with f at x₀ and answer 1 at x₁, with w(f) = w(g) = ½. Every round puts its call to the human, and x₁ is asked in each round with probability q independently. As long as x₁ has not been asked, β(M^(t)) = q/2; afterwards it is 0. So Pr[β(M^(T)) = q/2] = (1/n)·Σ_{t≤n} (1 − q)^(t−1) = (1 − (1 − q)^n)/(qn) ≥ δ·(1 − e^(−1/δ)), and q/2 = 1/(2δn). Here L·K ln 2/n = ln 2/n. If β(M^(T)) ≤ φ(δ′)·ln 2/n held with probability at least 1 − δ′, then for δ′ := 0.63·δ < (1 − e^(−1/δ))·δ we would need φ(δ′)·ln 2/n ≥ 1/(2δn), that is φ(δ′) ≥ 0.63/(2 ln 2·δ′) > 0.45/δ′. Every δ′ ∈ (0, 0.63] is of the form 0.63·δ with δ ∈ (0, 1], and the example exists for every n ≥ 1/δ. ∎

*What Proposition 5.2 does not say.* The guarantee in (b) is for runs each of which is answered by the mixture of a single round. It does not cover an imitator that draws a new round at every call (Proposition 5.5). A statement with ln(1/δ) in place of 1/δ for a single frozen imitator is obtained by validation (Section 13), not by the choice of the round, and by validation only for a human who is nearly deterministic on the inputs visited (Theorem 13.1(a)).

*Remarks.* (i) The rule of (a) and (b) is that of Ross, Gordon and Bagnell (2011), whose footnote 3 says that their guarantee "holds for the policy which uniformly randomly picks one policy in the sequence π̂_{1:N} and executes that policy for T steps" (quoted from the attack report, whose author read it in the source; not opened by the editor). (ii) All terms of Theorem 5.1 are nonnegative, so the round may be drawn uniformly from any set of rounds fixed in advance: for T′ uniform on the last ⌈n/2⌉ rounds, E[Λ(M^(T′))] ≤ 2L·ln(W/w(P))/n, and likewise for β and χ. This costs a factor 2 and leaves out the early rounds, in which the mixture has seen few answers (the adversary of the part "assumptions" proposed it; `research/verify/assumptions-attack.md`, finding m2).

**Proposition 5.3 (more than one question in a rehearsal run). MODIFIED (this replaces Remark (i) of the candidate theory).** Protocol R⁺ is Protocol R with step 3 changed as follows: after the question at call J_t (if J_t ≤ len_t), further calls of the same run τ_t may be put to the human, chosen by any rule that may depend on everything realised so far; all pairs received are added to the data, and M^(t+1) is the mixture given all of them. (Whether further calls may also be asked in a round with J_t > len_t does not matter: the proof covers both readings.)

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

Exact values (check report, by a recursion without sampling; `proofs/code/rehearsal-core_check_ladder.out`): for p = ½ and n = 20·L³, E[u(M̄)] = 0.00719, 0.00663, 0.00641 for L = 10, 20, 40, while E[β(M^(T))] = (1 − p)·L²/n = 0.0025, 0.00125, 0.000625. So in the ladder the averaged kernel is worse than the mixture of one round per run by a factor of about L/4 for p = ½ (about 0.46·L for p = 0.1), against the factor L that part (a) allows.

*What remains open here.* Part (a) bounds the probability that the run of M̄ is unfaithful. For the expected number of unfaithful calls of M̄ this file has only β(M̄) ≤ L·u(M̄). The case of a human who is not deterministic is not treated.

**Proposition 5.6 (R7: coverage). Added in the edition; it is Theorem 3.2(a) of `research/prove-c/assumptions.md`, which both reports on that part verified, re-derived here.** Run Protocol R, or any protocol of the same shape in which the kernel M^(t) of round t is an arbitrary function of what was realised in rounds 1, …, t − 1. Assume parts (i), (ii) and (v) of A3 (Remark 1.7). Nothing is assumed about the human, who may answer in any way, or about the class. Let Q ⊆ X be a set of inputs that is fixed before the protocol starts. Then

  Pr[the deployed run of M^(T) makes a call with input in Q, and no question of rounds 1, …, T − 1 lay in Q] ≤ L/n.

For N sets fixed in advance, the probability that this happens for at least one of them is at most N·L/n.

*Proof.* Let A_t be the event that no question of rounds 1, …, t − 1 lay in Q; A_t ∈ 𝓕_{t−1} and A_1 is the sure event. Let v_t := Pr[τ_t has a call with input in Q | 𝓕_{t−1}] and p_t := Pr[a_t = 1 and x_t ∈ Q | 𝓕_{t−1}]. Given 𝓕_{t−1} and τ_t the index J_t is uniform on {1, …, L}, so the conditional probability that the question of round t lies in Q is 1/L times the number of calls of τ_t with input in Q, which is at least 1/L if τ_t has such a call. Hence p_t ≥ v_t/L. The events "the first question in Q is asked in round t" are disjoint for different t, and their probabilities are E[1_{A_t}·p_t] = Pr[A_t] − Pr[A_{t+1}]. Therefore

  Σ_{t≤n} E[1_{A_t}·v_t] ≤ L·Σ_{t≤n} (Pr[A_t] − Pr[A_{t+1}]) ≤ L.

Given 𝓕_n and T = t the deployed run has the law Q_{M^(t)}, which is the conditional law of τ_t given 𝓕_{t−1}; and A_t ∈ 𝓕_{t−1}. So the probability in question is (1/n)·Σ_{t≤n} E[1_{A_t}·v_t] ≤ L/n. The last sentence is the union bound. ∎

*What it does not say.* The set must not depend on the data. For the set of inputs that have not been asked so far the statement is false: with one call per run at an input uniform on 1000 values and n = 50, the deployed run is at an input never asked before with probability 0.976, while L/n = 0.02 (`proofs/code/rehearsal-core_editor_checks.out`, block 6; the adversary of the part "assumptions" gave this example). So the statement holds for each fixed set, and for N sets with the factor N; it does not hold "for every property at once". For all the sets on which some member of the class differs from the human, taken together, the price is K (Theorem 5.1), not a union bound. The statement is about the random round: for the last mixture it fails by a factor of order √L in an example (`research/verify/assumptions-check.md`, Example C; not re-derived by the editor). And it says nothing about what the imitator does in Q once a question has lain there: one question in Q refutes a function that differs from a deterministic human throughout Q, and need not refute any other hypothesis.

*Reading.* For a deterministic human f and a function g of the class, take Q := {x : g(x) ≠ f(x)}: the probability that g is unrefuted before round T and the deployed run reaches an input at which g differs from f is at most L/n, whatever the weight of g. This is the exact form of the remark in `note.md` that "no property separates the questions of the deployed run from the questions put to the human".

**Proposition 5.7 (audits that are not uniform). Added in the edition; Proposition X5 of the attack report, re-derived here.** Change step 3 of Protocol R as follows. Let π_1, …, π_L be measurable functions of a run with values in [0, 1], π_j(τ) = 0 for j > len(τ), and Σ_j π_j(τ) ≤ 1 for every run τ. After the run τ_t, call j is put to the human with probability π_j(τ_t), by a coin that is independent of everything else given τ_t; at most one call is asked. Assume H1 and P ∈ H. Then

  Σ_{t≤n} E[ E_{Q_{M^(t)}} Σ_{j≤len} π_j(τ)·KL(P ‖ M^(t))(x_j) ] ≤ ln(W/w(P)),

and for a function f the same holds with e_{M^(t)}(x_j) in place of the divergence. Protocol R is the case π_j = 1/L for j ≤ len. In particular, if c_j(τ) ≥ 0 are weights of the calls ("how much call j matters") with Σ_j c_j(τ) ≤ C on every run, the choice π_j := c_j/C gives Σ_{t≤n} E[E_{Q_{M^(t)}} Σ_j c_j·KL(P ‖ M^(t))(x_j)] ≤ C·ln(W/w(P)): the horizon L is replaced by the largest total weight C of a run.

*Proof.* The asked pair is an adaptively chosen question in the sense of Setting 4.0, with 𝓖_t generated by 𝓕_{t−1}, τ_t and the coin that chooses the call. Given 𝓕_{t−1} and τ_t, the conditional mean of a_t·κ_t is Σ_j π_j(τ_t)·KL(P ‖ M^(t))(x_{t,j}), and τ_t has the law Q_{M^(t)} given 𝓕_{t−1}. Lemma 4.1(iii) bounds the sum of the means, and Lemma 4.2 gives the case of a function. ∎

*Use.* In Theorem 8.6, let the constant μ of condition (8.1) be replaced by a function μ_j(h_j) of the history, with Σ_j μ_j(h_j) ≤ C_μ on every run. The proof of Theorem 8.6 then gives E[c(τ^r)] ≤ E_{Q_P}[c] + E[Σ_j μ_j(h_j)·1[replacement at call j]]. For a function f and audits with π_j := μ_j/C_μ this yields E[c(deployed run of M^(T))] ≤ E_{Q_f}[c] + C_μ·ln(W/w(f))/n, where Theorem 8.6 with uniform audits has L·max μ_j in place of C_μ. The weights must be known to the protocol; nothing is gained when all calls matter equally. An exact example is in `proofs/code/rehearsal-core_editor_checks.out`, block 8; the attack report checked 600 random instances (`proofs/code/rehearsal-core_attack_weighted.out`).

**Remark 5.8 (per run, not for ever; cached answers; added in the edition, from findings M2(c), M2(d) and Proposition X6 of the attack report).** (i) Every guarantee of this section is for one run. Let the human be a function, and let R runs, S := R·L calls in all, be deployed, each with its own round. By Proposition 5.2(a) the expected number of unfaithful calls in all of them is at most R·L·ln(W/w(f))/n, that is

  n × E[number of unfaithful calls among the S deployed calls] ≤ S·K ln 2.

The online form of Section 10 has the same product: about q·S questions and at most K ln 2/q wrong answers (Theorem 10.1). So a fixed number of questions buys a constant rate of unfaithful calls for as long as the imitator is used, not a bounded number of them; a bounded number needs a number of questions that grows with the use (n of the order √(S·K ln 2) questions for about as many unfaithful calls). If one round is drawn once for good, there is in addition the factor 1/δ of Proposition 5.2(c), (d). (ii) For a deterministic human, a question that was asked before need not be put again: its answer is known. So n counts rounds, and the number of answers the human gives is the number of distinct questions among them, which is smaller when inputs repeat (in particular when the first call of every run has the same input).

## 6. The last round

Theorem 5.1 bounds a sum over the rounds, and Proposition 5.2 turns it into a statement about the mixture M^(T) of a uniformly chosen round. This section asks what holds for M^(n+1) = M_{D_n}, the mixture that has seen all the answers. The answer: for a deterministic human on a scaffold whose inputs do not depend on the answers, the last round is as good as the random round up to the additive term L/n (Proposition 6.1). In general it is not: the last round can exceed the bound L·K ln 2/n by a factor of order L in the divergence (Proposition 6.2) and by a factor of order √L in the expected number of unfaithful calls of a deterministic human (Proposition 6.3; the class of that example contains samplers that are not functions, and for a class of functions the question is open). For a deterministic human there is also an upper bound on every scaffold (Proposition 6.4): once n exceeds about 2L²·K ln 2·(ln L + 3), the probability u that the run of the last mixture is unfaithful (Theorem 7.1) exceeds the bound of the random round by at most a factor of order L·ln n, and the number of unfaithful calls by at most a factor of order L²·ln n; for smaller n Proposition 6.4 says nothing. Whether u can exceed that bound by more than a constant is open: in both examples it stays below it.

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

*Remarks.* (i) The argument for (a) is the classical one for learners that are consistent with independent examples (a hypothesis with error rate ε survives n examples with probability (1 − ε)^n), integrated over ε instead of applied at one threshold; applied at one threshold it gives ln n more. An exact computation for a family of examples is in Section 16. (ii) For weights of the form w(ν) = 2^(−2ℓ(ν)) with code lengths ℓ that satisfy Kraft's inequality, S_½ ≤ 1. For general weights with Σ_ν √(w(ν)) = ∞ part (b) is not available: the step from the minimum to the sum of square roots is the one that fails for posterior mass at the weights 2^(−ℓ) (`proofs/hellinger-runs.md`, Example 5.4). Whether the conclusion of (b) holds for all weights is open. (iii) Neither part says anything about scaffolds whose inputs depend on the answers; there the questions of different rounds are not identically distributed, and the next two propositions show that the conclusion fails.

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

So for a deterministic human, in a class that may contain samplers that are not functions, no bound of the form E[β(M^(n+1))] ≤ C·L·K/n with an absolute constant C holds. (The class of the example contains the samplers g_S, which are random at one input. Whether such a bound holds when all members of the class are functions is open.)

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

*The numbers.* Let L ≥ 4, n ≥ 100·L, λ + 1 = 1.1272·√L and N = ⌈1.6262·√L⌉. Then ā = 0.38836·√L, ā/N ≤ 0.23882, (λ + 1)·ā/(4n) = 0.10944·L/n ≤ 0.0011, and e^(−1/3)·(1 − 1/(9n)) ≥ 0.71633. So the bracket in (6.1) is at least 0.731·(0.71633 − 0.23882) − 0.0011 > 0.3479, and E[β(M^(n+1))] ≥ 0.05798·L·(L − 1)/n. On the other side K ln 2 ≤ (1.6262·√L + 1)·ln 2 + λ + e^(−λ) ≤ 2.2544·√L − 0.3068 + e^(−λ) ≤ 2.2544·√L, because λ ≥ 1.25. The quotient is at least 0.0257·(L − 1)/√L. The bound for M^(T) is Proposition 5.2(a). ∎

*Remarks.* (i) Exact values (Section 16): with these parameters the ratio of E[β(M^(n+1))] to L·K ln 2/n is 0.50, 0.81, 1.41, 2.63 for L = 100, 400, 1600, 6400, about 0.033·√L, and E[β(M^(n+1))] is 4.6 times the average over the rounds for L = 6400. The constant 1/40 is small; the proposition settles the order of growth, not a practical size. (ii) Why √L and not L in this example: the trap is reached only through the answer at r, which is asked with probability p/L per round, and g must not have been refuted there, so p is of order L/n; the height of the last round is then of order p·L, that is L/K times the bound, and the protection of the traps before round n needs K of order √L. (iii) The class contains samplers that are not functions. The decay of g_S at c can presumably be replaced by many clock inputs and a product prior over functions; this is not carried out here.

**Proposition 6.4 (last round, any scaffold, deterministic human: an upper bound). NEW.** Assume H1 and let P be a function f ∈ H. Let Π be any scaffold of horizon L, let u(C) be the probability that a run of the kernel C is unfaithful (Theorem 7.1), and let B₀ := L·ln(W/w(f))/n be the bound of Proposition 5.2(a) for a uniformly chosen round. If 2·B₀ < 1, then under Protocol R

  E[u(M^(n+1))] ≤ 2L·B₀·(1 + ln(1/(2B₀))) + 2·B₀ + 2L/n,  and  E[β(M^(n+1))] ≤ L·E[u(M^(n+1))].

The right side increases with B₀ on 2·B₀ < 1, and B₀ ≤ L·K ln 2/n. So if 2L·K ln 2 < n, then in the probability of an unfaithful run the last mixture is worse than the bound L·K ln 2/n of a random round by at most the factor 2L·(1 + ln(n/(2L·K ln 2))) + 2, up to the term 2L/n; in the number of unfaithful calls by at most L times as much.

*Where the statement has content.* The left side is a probability, and the right side is below 1 only if 2L·B₀·(1 + ln(1/(2B₀))) < 1. With n = c·2L²·ln(W/w(f)) this term equals (1 + ln(L·c))/c, which is below 1 only for c above 4.9, 7.6 and 10.2 when L = 10, 100 and 1000: about ln L + 3 (`proofs/code/rehearsal-core_editor_checks.out`, block 7). So the hypothesis 2·B₀ < 1 does not mark the range in which the proposition says something. For n between L·K ln 2, where the bound of the random round is already below 1, and about 2L²·K ln 2·(ln L + 3), it says nothing about the last mixture. (Both reports made this point.)

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

*Remarks.* (i) Where the factors come from. The factor L is the union bound of Step 1 over the calls of a run; it is the loss of Proposition 5.5(a) again, since the last mixture, like the averaged kernel, mixes hypotheses call by call. The logarithm comes from applying Markov's inequality to U_n at every threshold s. The proof uses that the rehearsal runs follow the human system's run up to their first unfaithful call, so that hypotheses with many errors along that run are refuted at a rate that only the unfaithful rehearsal runs can lower. (ii) Together with Proposition 6.3: for a deterministic human (in a class that may contain samplers that are not functions) the largest possible ratio of E[β(M^(n+1))] to L·K ln 2/n lies between (L − 1)/(40√L) and about 2L²·(1 + ln(n/(2L·K ln 2))). For E[u(M^(n+1))] it lies between a positive constant (0.68 in the family of check (1) of Section 16, where L = 1) and about 2L·(1 + ln(n/(2L·K ln 2))); no example with a ratio of 1 or more is known, and in the examples of Propositions 6.2 and 6.3 the ratio is below 1, because in every posterior state u(M) ≤ p + L·κ (the run is faithful if z = 0 and no call at c is answered wrongly), which is 8.4·L²/n in the first example and L·(λ + 4/3)/n in the second (for N ≥ 2). The excess of Proposition 6.3 comes from runs that are unfaithful at L − 1 calls at once.

*What remains open in Section 6.* The right order of the last round for a deterministic human: for the number of unfaithful calls between √L and L²·ln n times the bound of the random round (the lower end only for classes that contain samplers that are not functions), for the probability of an unfaithful run between a constant and L·ln n times. For a human who is not deterministic there is no upper bound for the last round on scaffolds whose inputs depend on the answers, and Proposition 6.2 shows that none of the order L·K/n holds for the divergence. For a human who is deterministic, or nearly so on the inputs visited, the question is answered in practice by validation: Theorem 13.1(a) certifies whichever imitator is deployed, the last mixture included. For other humans it is not (Theorem 13.1(c), Proposition 13.4).

## 7. Theorem R2 for a deterministic human

**Theorem 7.1 (R2 for a function). PROVED.** Let P be a function f, C a kernel, (z, ρ) ~ D₀ ⊗ λ, τ a run of C on (z, ρ), and τ^f(z, ρ) the run of the human system on the same (z, ρ). Let x^f_1, …, x^f_len be the inputs of τ^f(z, ρ).

(a) u(C) := Pr[τ ≠ τ^f(z, ρ)] = E[1 − Π_j (1 − e_C(x^f_j))] ≤ min{1, β(C)}, and TV(Q_C, Q_f) = u(C).

(b) Assume H1 and f ∈ H. Under Protocol R the deployed run of M^(T) is the run of the human system on the same (z, ρ) with probability at least 1 − L·ln(W/w(f))/n ≥ 1 − L·K ln 2/n; the probability is over the rehearsal, T and the deployed run.

(c) If every deployed run draws its own round, then with probability at least 1 − δ over the rehearsal, every deployed run is, conditionally on the rehearsal, the run of the human system on its (z, ρ) with probability at least 1 − L·(ln(W/w(f)) + ln(1/δ))/n.

*Proof.* (a) By Proposition 3.4(d) the run of C is the run of the human system corrupted by the stateless rule that replaces f(x_j) by a draw from C(·|x_j), and it equals τ^f(z, ρ) if and only if no replacement happens. Given (z, ρ), no replacement happens with probability Π_j (1 − e_C(x^f_j)), because as long as none has happened the inputs are those of τ^f(z, ρ). The number N of replacements has mean β(C) (Proposition 3.4(b)), and Pr[N ≥ 1] ≤ E[N]. For the total variation: Q_f gives the graph {(z, ρ, τ^f(z, ρ))} probability 1 and Q_C gives it probability 1 − u(C), so TV(Q_C, Q_f) ≥ u(C); and TV(Q_C, Q_f) ≤ u(C) by the coupling. (b) Take the expectation of u(M^(T)) ≤ β(M^(T)) and use Proposition 5.2(a). (c) Proposition 5.2(b), with u ≤ β for the mixture of the drawn round. ∎

*What it does not say.* The bound is useful only when n exceeds L·K ln 2: more questions than the run has calls. Theorem N2 (`proofs/lower-bounds.md`) gives a class and a scaffold with L critical calls for which every protocol needs a number of questions of the order L/δ for failure δ; it does not say that every run of L critical calls costs that much (Example 5.5 of that file is a run of L critical calls that costs one question). For a human who is not deterministic the statement about whole runs is Theorem 3.1 of `proofs/hellinger-runs.md`.

## 8. Theorem R3: low stakes

**Definition 8.1 (tolerance).** Let G ⊆ 𝒯 be a measurable set of runs (the *good* runs), 𝓡 a class of replacement rules (Definition 3.3), k ≥ 0 an integer and δ ∈ [0, 1]. The human system *tolerates k faults against 𝓡 with failure δ* if for every rule r ∈ 𝓡 under which the corrupted run has at most k replacements with probability 1, the corrupted run lies in G with probability at least 1 − δ.

For k = 0 this says Q_P(G) ≥ 1 − δ. Since 𝓡_bst ⊆ 𝓡_tr ⊆ 𝓡_all, tolerance against 𝓡_all implies tolerance against 𝓡_tr, which implies tolerance against 𝓡_bst. The definition in `note.md` and in the candidate theory ("every rule that, at each call, sees the run so far and the human's answer") is tolerance against 𝓡_all; Definition 5.1 of `proofs/lower-bounds.md` is the same for functions.

**Definition 8.2 (the rule of an answerer; the robustness curve).** (a) For an answerer A let γ_h be the maximal coupling (Lemma 3.1) of A_j(·|h) and P(·|x_j) at the history h = h_j, and r^A_j(y | h_j, y′) := γ_{h_j}(y, y′)/P(y′|x_j). By Lemma 3.2 with B = P, the run of the human system corrupted by r^A has the law Q_A, and given the past a replacement happens at call j with probability TV(A_j(·|h_j), P(·|x_j)). We write β(A) := E_{Q_A} Σ_{j≤len} TV(A_j(·|h_j), P(·|x_j)) for the expected number of replacements; for a kernel this is Definition 1.5, and r^C = κ_C is stateless. The *budgeted* rule r^{A,≤k} applies r^A at call j if fewer than k replacements have happened before call j, and passes the human's answer otherwise. In general r^{A,≤k} ∈ 𝓡_all; for a kernel C, κ_C^{≤k} ∈ 𝓡_bst.

(b) For β ∈ [0, L] put δ_Π(β) := sup{ Q_C(G^c) : C a kernel with β(C) ≤ β }. This function is nondecreasing with values in [0, 1], and δ_Π(0) = Q_P(G^c) (if β(C) = 0, no call is unfaithful almost surely, and Q_C = Q_P by Lemma 3.2(c)). Let δ̄_Π(β) := sup{ Σ_i λ_i·δ_Π(β_i) : λ_i ≥ 0, Σ_i λ_i = 1, Σ_i λ_i β_i = β } (finite sums) be its least concave majorant on [0, L]. δ̄_Π is nondecreasing: if β < β′ ≤ L and β = Σ_i λ_i β_i, then β′ = Σ_i λ_i β′_i with β′_i := β_i + (β′ − β)·(L − β_i)/(L − β) ∈ [β_i, L], and δ_Π(β′_i) ≥ δ_Π(β_i).

**Proposition 8.3 (R3 in the form with the robustness curve). PROVED (tagged [?] in the candidate theory).** (a) For every kernel C: Q_C(G^c) ≤ δ_Π(β(C)).

(b) Let C be a random kernel that takes countably many values and is independent of the randomness of the deployed run (for example a function of the rehearsal data and of T). Then the deployed run of C is outside G with probability at most E[δ_Π(β(C))] ≤ δ̄_Π(E[β(C)]).

(c) Under Protocol R with H1 and P ∈ H: the deployed run of M^(T) is outside G with probability at most δ̄_Π(min{L, L·ln(W/w(f))/n}) if P is a function f, and at most δ̄_Π(min{L, L·√(ln(W/w(P))/(2n))}) in general. (The minimum keeps the argument in [0, L], where δ̄_Π is defined.)

(d) In (b) the concave majorant cannot be replaced by δ_Π itself. Example: let L ≥ 2 and 0 < ε < 1; L calls at distinct inputs x_1, …, x_L, f ≡ 0, G := {not all L answers differ from 0}. Then δ_Π(β) = (β/L)^L and δ̄_Π(β) = β/L. The random kernel that answers 1 everywhere with probability ε and is f otherwise has E[β] = εL and failure probability ε = δ̄_Π(E[β]) > δ_Π(E[β]) = ε^L.

*Proof.* (a) is the definition. (b) Given the data, the failure probability is Q_C(G^c) ≤ δ_Π(β(C)) ≤ δ̄_Π(β(C)); δ̄_Π is concave and bounded on [0, L], so Jensen's inequality gives E[δ̄_Π(β(C))] ≤ δ̄_Π(E[β(C)]). (c) By (b), the monotonicity of δ̄_Π, the trivial bound E[β(M^(T))] ≤ L, and E[β(M^(T))] ≤ L·ln(W/w(f))/n (Proposition 5.2(a)), respectively E[β(M^(T))] ≤ L·√(ln(W/w(P))/(2n)) (Proposition 9.1). (d) For a kernel C with e_j := e_C(x_j): β(C) = Σ_j e_j and Q_C(G^c) = Π_j e_j ≤ (β(C)/L)^L by the inequality between the geometric and the arithmetic mean, with equality when all e_j are equal; (β/L)^L is convex with the values 0 at 0 and 1 at L, so its least concave majorant on [0, L] is β/L. ∎

The function case of (a) to (c) is also Proposition 5.2 of `proofs/lower-bounds.md`. The candidate theory states its "sharper form" with the argument L·K ln 2/n for every human; that is right for a deterministic human only, and (c) has the argument L·√(ln(W/w(P))/(2n)) in general. The second half of the candidate's "sharper form" (a lower bound of about L/β questions for classes closed under patches) is refuted in `proofs/lower-bounds.md` by Example 5.5; its replacement is Proposition 5.4(a) of that file.

**Theorem 8.4 (R3: low stakes). PROVED, with a weaker hypothesis.** Let G be a measurable set of runs, k ≥ 0 an integer and A an answerer. Let N be the number of replacements in the run of the human system corrupted by r^A, and δ_k(A) the probability that the run corrupted by the budgeted rule r^{A,≤k} is outside G. Then

  Q_A(G^c) ≤ δ_k(A) + Pr[N ≥ k + 1] ≤ δ_k(A) + β(A)/(k + 1).

Consequently:

(a) If A is a kernel C and the human system tolerates k faults against 𝓡_bst with failure δ, then Q_C(G^c) ≤ δ + β(C)/(k + 1); in particular δ_Π(β) ≤ δ + β/(k + 1) and δ̄_Π(β) ≤ δ + β/(k + 1) for all β.

(b) For any answerer A, if the human system tolerates k faults against 𝓡_all with failure δ, then Q_A(G^c) ≤ δ + β(A)/(k + 1).

(c) Under Protocol R with H1, a function f ∈ H, and tolerance of k faults against 𝓡_bst with failure δ: the deployed run of M^(T) is outside G with probability at most δ + L·ln(W/w(f))/((k + 1)·n). If k + 1 ≥ θL (for example k = ⌊θL⌋), this is at most δ + K ln 2/(θ·n), whatever L.

*Proof.* Generate the run τ corrupted by r^A: (z, ρ), and at each call j ≤ len the human's answer y′_j ~ P(·|x_j) and then the passed answer y_j ~ r^A_j(·|h_j, y′_j). It has the law Q_A (Definition 8.2(a)). Let j_k be the call of the k-th replacement (j_k := ∞ if N < k). Define a second run τ̃ on the same (z, ρ): at the calls j ≤ j_k it has the same human answers and the same passed answers as τ. At the calls j > j_k, as long as its history equals that of τ, its human answer is y′_j and its passed answer is y′_j; the two histories remain equal after call j exactly if y_j = y′_j. After the first call j > j_k at which τ has a replacement the two histories differ, and from then on τ̃ continues with fresh draws of the human at its own inputs, passed unchanged. At every call of τ̃ the human's answer is, given the past of τ̃, a draw from P at the input of τ̃ (it is y′_j, drawn before y_j, or a fresh draw), and the passed answer is drawn from r^A_j if fewer than k replacements have happened and is the human's answer otherwise. So τ̃ is the run of the human system corrupted by r^{A,≤k}, and Pr[τ̃ ∉ G] = δ_k(A). The two runs are equal on {N ≤ k}. Hence Q_A(G^c) = Pr[τ ∉ G] ≤ Pr[τ̃ ∉ G] + Pr[N ≥ k + 1], and Pr[N ≥ k + 1] ≤ E[N]/(k + 1) = β(A)/(k + 1) by Markov's inequality.

(a) κ_C^{≤k} belongs to 𝓡_bst and makes at most k replacements on every path, so δ_k(C) ≤ δ; the bound for δ_Π follows by taking the supremum, and the bound for δ̄_Π because the right side is affine in β. (b) r^{A,≤k} ∈ 𝓡_all makes at most k replacements. (c) Apply (a) to C = M^(T) for every value of the data and of T, take expectations, and use Proposition 5.2(a); L/(k + 1) ≤ 1/θ. ∎

*Remarks.* (i) The statement of `note.md` is (b) and (c) with tolerance against 𝓡_all. The proof uses only the budgeted version of the one stateless rule κ_C, so tolerance against 𝓡_bst suffices for imitators that are kernels; Example 8.5 shows that this is a weaker requirement on the human system. (ii) The rule κ_C(·|x, y′) depends on the human's answer y′. For a deterministic human this is no extra knowledge. For a human who is not deterministic it is: the coupling may replace exactly those answers of the human that the imitator never gives. A tolerance assumption for faults that are placed without sight of the human's answer does not suffice for Theorem 8.4: Example 8.5(d). So "the human system survives k faulty answers" in the sense of engineering (k of the answers come from a faulty component, chosen without knowledge of what the sound component would have said) is not the hypothesis of the theorem when the human is not deterministic. (iii) *What the theorem does not say.* It says nothing unless the human system itself tolerates faults; a scaffold in which one wrong answer spoils the outcome has k = 0, and the bound is δ + β.

**Example 8.5 (the Markov step is attained; the three classes of rules differ; faults placed blindly). NEW; (d) added in the edition.** In (a), (b) and (c), Y = {0, 1} and f ≡ 0.

(a) *Equality in Theorem 8.4.* Let L ≥ k + 1, X = {c, a_1, …, a_{k+1}}, and let the scaffold have z ∈ {0, 1} with D₀(1) = ε: if z = 0 all L calls are at c; if z = 1 calls 1, …, k + 1 are at a_1, …, a_{k+1} and the remaining calls at c. Let G := {at most k answers differ from 0}. The human system tolerates k faults against 𝓡_all with failure 0. The kernel C that answers 0 at c and 1 at every a_i has β(C) = (k + 1)·ε and Q_C(G^c) = ε = β(C)/(k + 1). So for δ = 0 the bound δ + β/(k + 1) cannot be improved as a function of β and k.

(b) *Tolerance against 𝓡_tr does not imply tolerance against 𝓡_all.* Let L ≥ 2, X = {x₀}, let the scaffold's randomness ρ be an index I that is uniform on {1, …, L}, let all L calls be at x₀, and G := {y_I = 0}. The rule "replace the answer at call I by 1" is in 𝓡_all, makes one replacement, and its run is never in G. A rule in 𝓡_tr depends on (z, ρ) only through the inputs, which are constant; so the answers (y_1, …, y_L) it passes are independent of I, and if it makes at most k replacements then Pr[y_I ≠ 0] = E[#{j : y_j ≠ 0}]/L ≤ k/L. So the human system tolerates k faults against 𝓡_tr with failure k/L, and it does not tolerate one fault against 𝓡_all with any failure below 1.

(c) *Tolerance against 𝓡_bst does not imply tolerance against 𝓡_tr.* Let L ≥ 3, X = {a_1, …, a_{L−1}, x₀}, z uniform on {1, …, L − 1}; call 1 is at a_z and calls 2, …, L are at x₀; G := {y_{1+z} = 0}. A rule in 𝓡_tr sees x_1 = a_z and replaces the answer at call 1 + z: one replacement, and the run is never in G. A budgeted stateless rule κ^{≤k} acts at the calls 2, …, L by independent coins of one fixed bias (the inputs and the human's answers there are always x₀ and 0), until its budget is used up. So the set R of calls among 2, …, L that it replaces is contained in the set R₀ of the first k calls among 2, …, L whose coin shows a replacement; R₀ is a function of the coins alone, |R₀| ≤ k, and the coins are independent of z. Hence Pr[y_{1+z} ≠ 0] = Pr[1 + z ∈ R] ≤ E[|R₀|]/(L − 1) ≤ k/(L − 1). So the human system tolerates k faults against 𝓡_bst with failure k/(L − 1), and it does not tolerate one fault against 𝓡_tr with any failure below 1.

(d) *Faults placed blindly do not give Theorem 8.4.* (The first example is the attack report's, finding m4; the second is the check report's, part E. The editor re-derived both.) Call a rule *blind* if at each call it decides, before the human's answer at that call is drawn, whether to pass that answer or to give an answer of its own; the decision and the answer may depend on everything realised before.

*First count: every call that the rule answers itself is a fault.* Let all L calls be at one input, let the human answer 1 with probability μ and 0 otherwise, and let G := {some answer is 1}. A blind rule that answers at most k calls itself leaves at least L − k calls to the human, and the run is bad only if the human answers 0 at all of these; so the human system survives k blind faults with failure at most (1 − μ)^(L−k). The kernel C ≡ 0 has β(C) = μ·L, and its run is never in G. For L = 4000, μ = 0.002 and k = 399: (1 − μ)^(L−k) = 0.0007 and β(C)/(k + 1) = 0.02, so "δ + β/(k + 1)" with the blind tolerance would be 0.021, while Q_C(G^c) = 1. Theorem 8.4 is not contradicted: the rule κ_C replaces exactly the answers 1 of the human, and against its budgeted version the human system fails with probability Pr[Bin(L, μ) ≤ k], which is 1.0000 here (`proofs/code/rehearsal-core_editor_checks.out`, block 2; `proofs/code/rehearsal-core_attack_r3.out`, part 2).

*Second count: a replacement is a call at which the passed answer differs from the human's (Definition 3.3).* Under this count blindness is no restriction in the example above: a blind rule may answer 0 at every call, and only the calls at which the human would have said 1 are counted. A gap needs an answer that is worse than the human's worst. Take the family of Remark 12.3(ii): the human's answers u and d move a counter by +1 and −1, with probabilities (1 + μ)/2 and (1 − μ)/2; a third answer b moves it by −D; a run is good if the counter rises by at least (1 − η)·μL. A blind rule that passes loses nothing; an override by d loses 2 if the human would have said u, which is then a replacement, and nothing otherwise; an override by u loses nothing; an override by b or ⊥ is always a replacement and loses μ + D + ξ_j, where ξ_j is the human's step minus μ and has conditional mean 0. So the rise is at least μL − max{2, μ + D}·k + Σ_j ξ_j·1[no override by b or ⊥ at call j]. The indicator is decided before the human's answer is drawn, so the sum is a martingale whose increments have conditional range at most 2, and by Lemma 12.1 every blind rule with at most k replacements fails with probability at most δ whenever max{2, μ + D}·k + √(2L·ln(1/δ)) ≤ η·μ·L. A kernel that gives b where the human would give u, with probability ε, has β = ε·L·(1 + μ)/2 and loses 1 + D at each unfaithful call. For μ = 0.2, D = 3, η = ½, δ = 10⁻³ and L = 2·10⁶ the condition allows k = 60 857, and the kernel with β = 0.9·k has a bad run with probability 1.0000, although δ + β/(k + 1) = 0.901 (`proofs/code/rehearsal-core_check_blind.out`). For D = 1 the two losses per replacement agree and there is no gap.

**Theorem 8.6 (low stakes in the recoverable form). NEW in this project; the statement is the standard one of the imitation-learning literature.** Let c: 𝒯 → [0, 1] be measurable (a *cost*; c = 1 on bad runs and 0 on good runs gives the failure probability). For j = L + 1, L, …, 1 and a history h_j before call j define v_j(h_j), the expected cost if the human answers call j and all later calls: v_j(h_j) := c(τ) if the run has already stopped at h_j (that is, len < j, with τ the stopped run), and v_j(h_j) := Σ_{y∈Y} P(y|x_j)·v_{j+1}(h_j, y) otherwise. Suppose that for a number μ ∈ [0, 1], for every j ≤ L, every history h_j with len ≥ j, every y ∈ Y_⊥ and every y′ ∈ Y with P(y′|x_j) > 0,

  v_{j+1}(h_j, y) − v_{j+1}(h_j, y′) ≤ μ.  (8.1)

Then for every replacement rule r ∈ 𝓡_all, with τ^r the corrupted run and N its number of replacements,

  E[c(τ^r)] ≤ E_{Q_P}[c] + μ·E[N].

Consequently E_{Q_A}[c] ≤ E_{Q_P}[c] + μ·β(A) for every answerer A, δ_Π(β) ≤ Q_P(G^c) + μ·β when c is the indicator of G^c, and under Protocol R with H1 and a function f ∈ H: E[c(deployed run of M^(T))] ≤ E_{Q_f}[c] + μ·L·ln(W/w(f))/n.

*Proof.* The functions v_j are measurable with values in [0, 1], by backward induction, and E_{Q_P}[c] = E[v_1(z, ρ)]. Along the corrupted run put V_j := v_j(h_j) for j ≤ len + 1 and V_j := c(τ^r) for j > len + 1; so V_{L+1} = c(τ^r). Let 𝓖_j be the σ-algebra of everything realised before the human's answer at call j. On {j ≤ len}: the human's answer y′_j has the law P(·|x_j) given 𝓖_j (H1), so E[v_{j+1}(h_j, y′_j) | 𝓖_j] = v_j(h_j); and by (8.1), v_{j+1}(h_j, y_j) ≤ v_{j+1}(h_j, y′_j) + μ·1[y_j ≠ y′_j], since y′_j has positive probability under P(·|x_j) almost surely. Hence E[V_{j+1} − V_j] ≤ μ·Pr[j ≤ len, y_j ≠ y′_j]. Summing over j = 1, …, L gives E[c(τ^r)] ≤ E[V_1] + μ·E[N]. For an answerer A apply this to r^A (Definition 8.2(a)); for Protocol R use Proposition 5.2(a). ∎

*Remarks.* (i) For a function f, condition (8.1) reads v_{j+1}(h_j, y) − v_{j+1}(h_j, f(x_j)) ≤ μ: one replaced answer, followed by the human, raises the expected cost by at most μ. This is the recoverability condition of Ross, Gordon and Bagnell (2011, Theorem 2.2), whose statement (read in the source by the prover and again by the adversary; Section 17) is: "Let π be such that E_{s∼d_π}[ℓ(s, π)] = ε, and Q^{π*}_{T−t+1}(s, a) − Q^{π*}_{T−t+1}(s, π*) ≤ u for all action a, t ∈ {1, 2, …, T}, d^t_π(s) > 0, then J(π) ≤ J(π*) + uTε." Theorem 8.6 is this statement for scaffolds, with their u, T and Tε being μ, L and β; for a human who is not deterministic the difference in (8.1) is between two answers, not between an answer and the human's average, because the rule sees the human's answer (Remark (ii) after Theorem 8.4). (ii) *Relation to tolerance.* Theorem 8.6 implies that a human system satisfying (8.1) tolerates k faults against 𝓡_all with failure Q_P(G^c) + k·μ. Putting this into Theorem 8.4 gives Q_P(G^c) + k·μ + β/(k + 1), which is at least Q_P(G^c) + 2·√(μβ) − μ for every k, while Theorem 8.6 gives Q_P(G^c) + μ·β directly, with no Markov step. (The direct bound is never the worse of the two when the other is at most 1: if k·μ + β/(k + 1) ≤ 1 then β ≤ k + 1, hence (β − k)⁺ ≤ β/(k + 1) and μ·β ≤ k·μ + (β − k)⁺ ≤ k·μ + β/(k + 1). The check report noted this.) In the other direction tolerance does not give a small μ: for 2k + 1 calls at one input with f ≡ 0 and G := {at most k answers differ from 0}, the human system tolerates k faults with failure 0, but μ = 1, because at a history with k wrong answers one more wrong answer decides the outcome; here Theorem 8.4 gives β/(k + 1) and Theorem 8.6 gives β. So the two forms are not comparable. (iii) *What it does not say.* (8.1) is required at every history, including histories that the human system itself never reaches; an imitator's run can reach them.

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

(ii) Let 0 ≤ γ ≤ ½. If a protocol asks at most n questions in expectation under every member, and its deployed run lies in G_σ with probability at least 1 − γ whenever the human is P_σ, for every σ, then

  n ≥ K·(1 − 2γ)²/(8θ′²) = K·(1 − 2γ)²/(32θ²).

(For γ > ½ the conclusion is false: the protocol that asks nothing and answers every call with a fair coin has failure ½ for every σ. The check report found the missing hypothesis.)

(iii) By Proposition 9.1(b), Protocol R with n ≥ K ln 2/(2θ²γ′²) rounds has failure at most exp(−θ′²L/2) + γ′ for every member; by Proposition 9.4, so has Protocol R with n ≥ 4e²·K ln 2/(θ²·γ′) rounds if 2^(−θL) ≤ γ′/2. So for a fixed excess failure the number of questions is of the order K/θ², while for a deterministic human K ln 2/(θ·γ′) questions suffice (Theorem 8.4(c)).

*Proof.* (i) Let z = i and σ_i = +1; the other case is symmetric, with the roles of the answers 0 and 1 exchanged. The inputs do not depend on the answers, so in the corrupted run the human's answers y′_1, …, y′_L are, each given the past, draws from Bern(½ + θ′). By Lemma 12.1 (with ranges of length 1), S′ := Σ_j y′_j satisfies Pr[S′ ≤ L/2 + k] = Pr[S′ − L·(½ + θ′) ≤ −(θ′L − k)] ≤ exp(−2(θ′L − k)²/L). A rule that makes at most k replacements passes at least S′ − k answers equal to 1, so maj = +1 unless S′ ≤ L/2 + k.

(ii) For ω, i and s ∈ {−1, +1} let π^ω_i(s) be the probability that the run of A^ω has maj = s, given z = i; it does not depend on σ, and π^ω_i(+1) + π^ω_i(−1) ≤ 1. The failure probability under σ is (1/K)·Σ_i E_σ[1 − π^ω_i(σ_i)]. By the two-point inequality of the proof of Theorem 9.2, E_σ[1 − π^ω_i(σ_i)] + E_{σ^(i)}[1 − π^ω_i(−σ_i)] ≥ 1 − TV(𝐏_σ, 𝐏_{σ^(i)}), and TV(𝐏_σ, 𝐏_{σ^(i)}) ≤ θ′·√(8·E_σ[N_i]) as there. Averaging over σ and i as in step (4), the mean failure probability over the class is at least ½·(1 − θ′·√(8n/K)). If this is at most γ, then θ′·√(8n/K) ≥ 1 − 2γ; for γ ≤ ½ the right side is nonnegative and the inequality may be squared. (The hypothesis that L is odd is a convenience: it excludes ties. It is not used in (i) or (ii).)

(iii) With k = ⌊θ′L/2⌋ we have L/(k + 1) ≤ 2/θ′ = 1/θ, so Proposition 9.1(b) gives the failure δ + √(K ln 2/(2n))/θ with δ = exp(−θ′²L/2). ∎

*What Proposition 9.3 does not say.* In this family the tolerated fraction θ and the bias θ′ of the human are tied together. The proposition shows that the dependence on θ in Proposition 9.1(b) cannot be improved from 1/θ² to 1/θ for all human systems; it does not say that every human system with tolerance θ needs K/θ² questions. Its lower bound (ii) does not grow as the allowed failure γ shrinks, while the upper bounds grow like 1/γ′² (Proposition 9.1(b)) or 1/γ′ (Proposition 9.4) in the excess failure γ′; whether a factor of the order 1/γ′ is needed is open.

**Proposition 9.4 (low stakes for a human who is not deterministic: a second bound). Added in the edition. It is Proposition X4 of the attack report; the editor re-derived the proof below; no second verifier checked it.** Let C be a kernel, N the number of unfaithful calls of its run (the number of replacements in the run of the human system corrupted by κ_C, Proposition 3.4), and k ≥ 1 an integer. Then

  Pr[N ≥ k] ≤ 2e²·L·Λ(C)/k² + 2^(−k).

Consequently:

(a) If the human system tolerates k faults against 𝓡_bst with failure δ, then Q_C(G^c) ≤ δ + 2e²·L·Λ(C)/(k + 1)² + 2^(−(k+1)).

(b) Under Protocol R with H1 and P ∈ H, if the human system tolerates k faults against 𝓡_bst with failure δ and k + 1 ≥ θL, the deployed run of M^(T) is outside G with probability at most

  δ + 2e²·K ln 2/(θ²·n) + 2^(−θL).

*Proof.* Pad the run to L calls. For j ≤ len let t_j := TV(C, P)(x_j), which is a function of the history h_j, and let I_j be the indicator of a replacement at call j; for j > len put t_j := 0 and I_j := 0. Put S := Σ_j t_j, so N = Σ_j I_j. Given everything realised before call j, Pr[I_j = 1] = t_j (Proposition 3.4(b)). Hence for λ ≥ 0, E[e^(λ·I_j) | past] = 1 + t_j·(e^λ − 1) ≤ exp((e^λ − 1)·t_j), and by induction over the calls E[exp(λ·N − (e^λ − 1)·S)] ≤ 1. For a > 0 it follows by Markov's inequality that Pr[N ≥ k and S ≤ a] ≤ exp(−λ·k + (e^λ − 1)·a). Take a := k/(2e) and λ := ln(2e): the exponent is −k·ln(2e) + (2e − 1)·k/(2e) ≤ −k·ln(2e) + k = −k·ln 2, so Pr[N ≥ k and S ≤ a] ≤ 2^(−k). On the other side, by the Cauchy–Schwarz inequality over the at most L calls and by Pinsker's inequality at every call, S² ≤ L·Σ_j t_j² ≤ (L/2)·Σ_{j≤len} KL(P ‖ C)(x_j); so E[S²] ≤ L·Λ(C)/2, and Pr[S > a] ≤ L·Λ(C)/(2a²) = 2e²·L·Λ(C)/k² by Markov's inequality. Add the two probabilities. (a) is the first inequality of Theorem 8.4 with Pr[N ≥ k + 1] bounded in this way. (b) Apply (a) to C = M^(T) for every value of the data and of T, take expectations, and use E[Λ(M^(T))] ≤ L·ln(W/w(P))/n (Proposition 5.2(a)), (k + 1)² ≥ θ²L² and 2^(−(k+1)) ≤ 2^(−θL). ∎

*Reading.* For an excess failure γ′ the bound needs n = 4e²·K ln 2/(θ²·γ′) rounds once 2^(−θL) ≤ γ′/2, where Proposition 9.1(b) needs K ln 2/(2θ²·γ′²). It is the smaller number for γ′ below 1/(8e²) ≈ 0.017. So for a human who is not deterministic the price of low stakes is of the order K/(θ²·γ′): the square is on the tolerated fraction, where Proposition 9.3 shows that it is needed, and not on the excess failure. The proposition applies Markov's inequality to the summed divergence and a Chernoff bound to the number of unfaithful calls given the summed total variation; Proposition 9.1(b) applies Markov's inequality to the number of unfaithful calls. The term 2^(−θL) makes the bound useless for runs with few tolerated faults; there Proposition 9.1(b) remains. In the family of Proposition 9.3 with K = 1, L = 400, θ = 0.05 and n = 10⁶, the exact probability of at least θL unfaithful calls is 9.1·10⁻⁶, Proposition 9.4 gives 4.1·10⁻³ and Markov's inequality for the number gives 1.2·10⁻² (attack report, `proofs/code/rehearsal-core_attack_lowstakes.out`); a grid of binomial cases is in `proofs/code/rehearsal-core_editor_checks.out`, block 5.

*What it does not say.* It is stated for kernels. (The same proof gives the first display for any answerer A, with t_j := TV(A_j(·|h_j), P(·|x_j)) and the divergences KL(P(·|x_j) ‖ A_j(·|h_j)); in (a) the tolerance must then be against 𝓡_all.) It does not remove the factor K, and it does not improve the bound E[β(M^(T))] ≤ L·√(K ln 2/(2n)) on the expected number of unfaithful calls, which is of the right order (Theorem 9.2).

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

*Remarks.* (i) The statement excludes q = 1, hence L = 1 with q = 1/L. There every call is put to the human, the mixture at the start of a run is the current mixture, and the bound holds with the factor 1. (ii) The example is not extremal. For L = 3, q = 1/3 and four runs the adversary's local search found an instance whose loss factor Σ_i E[Λ(M_i)]/(L·ln(W/w(P))) is 1.4416, above the value 1.4211 = 1/(1 − (2/3)³) that the example approaches as the number of runs grows, and below the proved bound (1 − 1/L)^(−(L−1)) = 2.25 (`proofs/code/rehearsal-core_attack_online.out`; a second search, `proofs/code/rehearsal-core_attack_online_l3.out`, found 1.4139 against the example's 1.4101 at four runs, with a hypothesis that is a semimeasure). For L = 2 the search found nothing above the example. So the largest loss factor of freezing after online rehearsal lies between the value of the example and the bound, and is not known. The editor did not re-run these searches.

*Summary of Section 10.* Protocol R is online rehearsal with two changes: the run is answered by the frozen mixture alone, and the question is placed at one uniformly chosen call. With these changes the bound of Theorem 5.1 holds for the frozen mixtures with the constant 1; without them it holds with a constant between 1.58 and e (for large L). What the online form adds is that Theorem 10.1 needs no closed system: it holds for any process that produces the inputs. What it costs is that the human stays in the loop. Exact enumeration for small cases: Section 16.

## 11. The three remarks after Proposition R6 of the candidate theory

**Remark (i)** ("one question per rehearsal run is what the proof uses; more questions per run are harmless extra data"). MODIFIED: Proposition 5.3. More questions per run are harmless for the bound if one of them is at a uniformly chosen call; they do not improve the bound and can cost L times as many answers for the same mixtures; the proof cannot be changed to profit from them while the mixture is frozen during the run.

**Remark (ii)** ("the human only ever answers single calls; no run of the human system is needed"). PROVED, by inspection: in Protocol R (Definition 5.0) and in validation (Section 13) the human is asked the input of at most one call per round, n + m questions at most, and no statement of Sections 5 to 10, 12 and 13 uses a recorded run of the human system. Two qualifications belong with it. First, the questions are inputs of runs of the imitators, the poor early ones included. Assumption A1 is used at those inputs: the human is assumed to answer every x ∈ X, also an input that the human system itself would never produce, by a draw from P(·|x). Second, a single call need not be short; one call may stand for a long episode of work.

**Remark (iii)** ("the random round cannot be replaced by the last round in general, because learning curves are not monotone"). PROVED in the form of Propositions 6.2 and 6.3, with the reason corrected (Remark (ii) after Proposition 6.2), and complemented by Propositions 6.1 and 6.4: with a deterministic human the last round is as good as the random round up to L/n on scaffolds whose inputs do not depend on the answers, and on every scaffold it is worse by at most a factor of order L·ln n in the probability of an unfaithful run, once n is large enough for Proposition 6.4 to say anything. The example of Proposition 6.3 (the number of unfaithful calls of a deterministic human) uses a class that contains samplers that are not functions.

## 12. Proposition R3a: bounded damage implies tolerance of faults

**Lemma 12.1 (the Azuma–Hoeffding inequality with conditional ranges; standard).** Let 𝓗_0 ⊆ 𝓗_1 ⊆ … ⊆ 𝓗_L be σ-algebras and Δ_1, …, Δ_L bounded random variables such that, for every j, Δ_j is 𝓗_j-measurable, a_j ≤ Δ_j ≤ a_j + c_j for an 𝓗_{j−1}-measurable random variable a_j and a constant c_j ≥ 0, and E[Δ_j | 𝓗_{j−1}] ≥ μ_j for a constant μ_j. Then for every t ≥ 0,

  Pr[Σ_j Δ_j ≤ Σ_j μ_j − t] ≤ exp(−2t²/Σ_j c_j²).

If instead E[Δ_j | 𝓗_{j−1}] ≤ μ_j for every j, the same bound holds for Pr[Σ_j Δ_j ≥ Σ_j μ_j + t].

*Proof.* *Hoeffding's lemma.* Let U be a random variable with values in [0, 1] and conditional mean u given a σ-algebra 𝓗. For real λ the function v ↦ e^(λv) is convex, so e^(λU) ≤ 1 − U + U·e^λ and E[e^(λU) | 𝓗] ≤ 1 − u + u·e^λ = exp(ψ(λ)) with ψ(λ) := ln(1 − u + u·e^λ). Now ψ(0) = 0, ψ′(0) = u, and ψ″(λ) = p·(1 − p) ≤ ¼ with p := u·e^λ/(1 − u + u·e^λ); so ψ(λ) ≤ uλ + λ²/8, that is E[e^(λ(U−u)) | 𝓗] ≤ e^(λ²/8). *The inequality.* Let m_j := E[Δ_j | 𝓗_{j−1}] ≥ μ_j and s ≥ 0. Applying the lemma to U := (Δ_j − a_j)/c_j with λ := −s·c_j (if c_j = 0, then Δ_j = a_j = m_j and the next inequality is trivial) gives E[e^(−s(Δ_j − m_j)) | 𝓗_{j−1}] ≤ e^(s²c_j²/8), hence E[e^(−s(Δ_j − μ_j)) | 𝓗_{j−1}] ≤ e^(s²c_j²/8), because s·(m_j − μ_j) ≥ 0. By induction on L and the tower property, E[exp(−s·Σ_j (Δ_j − μ_j))] ≤ exp(s²·Σ_j c_j²/8). By Markov's inequality Pr[Σ_j (Δ_j − μ_j) ≤ −t] ≤ exp(−st + s²·Σ_j c_j²/8), and s := 4t/Σ_j c_j² gives the claim. The second statement is the first for −Δ_j. ∎

For independent variables this is Hoeffding's inequality (W. Hoeffding 1963, Theorem 2); the extension to martingale differences is noted there and is usually named after K. Azuma (1967). Both are quoted from memory; the proof above is complete.

**Proposition 12.2 (R3a: bounded damage). PROVED in this form. The constant 8 of `note.md` is improved to 2. The statement of `note.md` does not require that every run has exactly L calls, and without that hypothesis it is false (Remark 12.3(v)).** Let Π be a scaffold all of whose runs have exactly L calls. For j = 0, …, L let Φ_j be a measurable real function of the history h_{j+1} = (z, ρ, y_1, …, y_j) (a *progress function*; in `note.md`, Φ_j is a function φ of the state after call j). Suppose that there are numbers μ > 0 and D ≥ 0 such that for every j ≤ L and every history h_j, with x_j the input of call j:

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

**Remarks 12.3.** (i) *The statement of `note.md`* has √(8L·ln(1/δ)) in (12.1). That condition is stronger than (12.1), so for scaffolds all of whose runs have exactly L calls the statement of the note is correct; for other scaffolds it is false (Remark (v)). The constant 8 arises if the centred variables are bounded by 2 in absolute value; their conditional range has length 2, which gives the constant 2. The constant 2 cannot be lowered much: with √(1.5·L·ln(1/δ)) in (12.1) the rule of Remark (ii) fails with probability 2δ at δ = 10⁻⁸ (L = 3200, μ = 0.3, D = 0, η = 1; check report, `proofs/code/rehearsal-core_check_v1.out`). The exact failure probabilities of an extremal example are in Section 16.

(ii) *The rule sees the human's answer, and this is why the loss per fault is 1 + D and not μ + D.* Let all calls be at one input x₀, let the human answer u ("up") with probability (1 + μ)/2 and d ("down") otherwise, let b be a third answer, and Φ_j := Σ_{i≤j} s(y_i) with s(u) := 1, s(d) := −1, s(b) := s(⊥) := −D, where D ≥ 1. Then (i) to (iii) hold. The stateless rule that replaces u by b and leaves d, with the budget k, belongs to 𝓡_bst, and it is the budgeted rule κ_C^{≤k} of the kernel C(d|x₀) := (1 − μ)/2, C(b|x₀) := (1 + μ)/2: the imitator that gives the bad answer whenever the human would have given the good one. Under this rule every replacement lowers the total by exactly 1 + D, so the run is good if and only if Σ_j s(y′_j) ≥ (1 − η)·μL + k·(1 + D) (provided the human answers u at least k times). The sum Σ_j s(y′_j) has mean μL and standard deviation √(L·(1 − μ²)). So for k·(1 + D) = η·μL the failure probability is close to ½, and for k·(1 + D) = η·μL + 2√L it is close to 1 (0.49 and 0.98 for μ = 0.2, D = 3, η = ½, L = 1600; Section 16). Hence the term k·(1 + D) in (12.1) cannot be replaced by k·(μ + D), and the term of order √L cannot be dropped. A rule that does not see the human's answer and replaces k calls chosen in advance would lower the mean of the total by only k·(μ + D); a rule that does not see the current answer but counts its replacements as Definition 3.3 does can lose max{2, μ + D} per replacement (Example 8.5(d)).

(iii) *With Theorem 8.4.* For a deterministic human take k := ⌊η·μL/(1 + D)⌋: by the last sentence of the proposition the tolerance has failure 0, k + 1 > η·μL/(1 + D), and Theorem 8.4(c) gives that the deployed run of M^(T) is outside G with probability at most

  (1 + D)·K ln 2/(η·μ·n),

whatever L. For a human who is not deterministic let L ≥ 8·ln(1/δ)/(η·μ)²; then √(2L·ln(1/δ)) ≤ η·μL/2, so (12.1) holds for k := ⌊η·μL/(2(1 + D))⌋, and Proposition 9.1(b) gives the failure probability δ + 2·(1 + D)·√(K ln 2/(2n))/(η·μ); Proposition 9.4(b), with θ := η·μ/(2(1 + D)), gives δ + 8e²·(1 + D)²·K ln 2/((η·μ)²·n) + 2^(−θL). This is the sentence after R3a in `note.md` ("the number of questions does not grow with the length of the run"), with its constants; the sentence of the note has the constants of the deterministic case only.

(iv) *What the proposition does not say.* Hypotheses (i) to (iii) are required at every history, also at those that only a corrupted run reaches: the human must make progress from wherever the run stands, and no single answer may set the run back by more than D. In a chain in which one wrong answer spoils everything, D is of the order of L and (12.1) allows k = 0 only. Hypothesis (iii) bounds decreases only, and the good runs are defined through Φ: an answer that raises Φ without real progress makes the run good by definition. So Φ must be a quantity that a wrong answer cannot raise, or the conclusion is about Φ and not about the task. The proposition does not help to find a progress function.

(v) *Runs that may stop early: the statement of `note.md` is false (attack report, finding m1; the check report asks for the same hypothesis).* The note states R3a for "a sequential scaffold" without requiring that every run has L calls, and its Section 1 lets a scaffold stop after any call. Let the scaffold make up to L calls; the answer "go" raises the counter Φ by 1, and any other answer stops the run with Φ unchanged. The human always answers "go". Then from every state a call answered by the human raises Φ by μ = 1 and changes it by at most 1, and no answer lowers Φ (D = 0); the human system's run raises Φ by L. With η = ½, δ = 0.01 and L = 1000 the condition of the note admits 308 faults, and (12.1) admits 404 (`proofs/code/rehearsal-core_editor_checks.out`, block 7; `proofs/code/rehearsal-core_attack_r3.out`, part 3). But one replaced answer at call 1 stops the run with Φ unchanged: the run is bad with probability 1. The proof of Proposition 12.2 uses the hypothesis where it writes the rise of Φ as a sum of L terms, each with conditional mean at least μ under the human's answer; a run that has stopped has no further terms.

## 13. Theorem V1: the validation certificate

**Definition 13.0 (validation).** An answerer A is *frozen* if it is fixed before validation and answers every run with fresh private coins, independently of all other runs given A. (A may have been obtained in any way, for example from the rehearsal; a frozen answerer may be randomised, and it may depend on the history of the run. An answerer that learns from one run to the next is not frozen.) Validation with m rounds: for i = 1, …, m,

1. a run τ_i of Π is generated with A answering every call, on a fresh (z_i, ρ_i);
2. J_i is drawn uniformly from {1, …, L}, independently of everything realised so far;
3. if J_i ≤ len(τ_i), the input x_i := x_{i,J_i} is put to the human, and the human's answer y^P_i ~ P(·|x_i) (H1) is recorded next to the answer y^A_i := y_{i,J_i} that A gave at this call in the run. Put a_i := 1[J_i ≤ len(τ_i)].

Nothing is updated. The human answers at most m questions. A round with J_i > len(τ_i) asks nothing; it stays in the count of the m rounds and contributes 0 to every frequency below.

**Theorem 13.1 (V1). PROVED, with additions.** Assume H1: the human answers every question by a fresh draw from P(·|x). P need not belong to any class (A2 is not used). Let A be frozen. All statements are conditional on A.

(o) The rounds are independent and identically distributed: the tuples (a_i, x_i, y^A_i, y^P_i), i ≤ m, are independent with a common law (when a_i = 0 the other three entries are a fixed dummy symbol).

(a) *Recorded disagreements.* Let d_i := a_i·1[y^A_i ≠ y^P_i] be the indicator of a recorded disagreement in round i, and β(A) the expected number of unfaithful calls of a run of A (Definition 8.2(a)). The d_i are independent Bernoulli variables with one mean ρ, and:

 (a0) *For every human* (added in the edition; found independently by both reports). ρ = (1/L)·E_{Q_A} Σ_{j≤len} (1 − Σ_y A_j(y|h_j)·P(y|x_j)), and with s_P := (1/L)·E_{Q_A} Σ_{j≤len} (1 − Σ_y P(y|x_j)²), the *noise of the human* along the runs of A,

  β(A)/L ≤ ρ ≤ β(A)/L + s_P  and  ρ ≥ s_P/2.

 If P is a function f, then s_P = 0 and ρ = β(A)/L = E[N]/L, where N is the number of calls of a run of A whose answer differs from f(x_j).

 (a1) If ρ > ln(1/δ)/m, the probability that no disagreement is recorded in m rounds is less than δ. So the rule "if no disagreement is recorded, certify β(A) ≤ L·ln(1/δ)/m" issues a false certificate with probability less than δ, whatever A is and whatever the human is. The certificate is issued with probability (1 − ρ)^m ≤ exp(−m·s_P/2): unless the human is nearly deterministic on the inputs that the runs of A visit, it is almost never issued, also for a perfect imitator.

 (a2) With ρ̂ := (1/m)·Σ_i d_i: with probability at least 1 − δ, β(A)/L ≤ ρ ≤ ρ̂ + √(2·ρ̂·ln(1/δ)/m) + 2·ln(1/δ)/m.

 (a3) A certified bound β(A) ≤ B may be used in Theorems 8.4 and 8.6. In Theorem 8.4 the tolerance must be against 𝓡_all if A depends on the history, and against 𝓡_bst if A is a kernel. For an imitator that draws one kernel C for each run, the same rule certifies the mean of β(C) over the kernel drawn, and tolerance against 𝓡_bst suffices (apply (a0) and Theorem 8.4(a) conditionally on the kernel). If P is a function f, the run of A is the run of the human system on the same (z, ρ) with probability at least 1 − B (Theorem 7.1(a), which holds for answerers by Lemma 3.2).

(b) *Any human.* A *test* is a set B ⊆ X × Y_⊥ of pairs (input, answer); write B_x := {y : (x, y) ∈ B}. Put

  a_A(B) := (1/L)·E #{j ≤ len : (x_j, y_j) ∈ B},  h_A(B) := (1/L)·E Σ_{j≤len} P(B_{x_j}|x_j),  Δ(B) := a_A(B) − h_A(B),

the expectations being over a run of A: a_A(B) is the frequency of B among the answers of A, per L calls, and h_A(B) the frequency with which the human's answer to the same calls would lie in B. Let â(B) := (1/m)·Σ_i a_i·1[(x_i, y^A_i) ∈ B] and ĥ(B) := (1/m)·Σ_i a_i·1[(x_i, y^P_i) ∈ B] be the recorded frequencies. Let 𝓑 be a countable family of tests with weights π(B) > 0, Σ_B π(B) ≤ 1; the family and the weights are fixed before validation (they may depend on A and on anything known before the validation rounds, and must not depend on the validation rounds).

 (b1) With probability at least 1 − δ, simultaneously for all B ∈ 𝓑: |Δ(B) − (â(B) − ĥ(B))| ≤ √(2·ln(2/(π(B)·δ))/m).

 (b1′) *Half the tolerance* (added in the edition; attack report, finding m6). The frequency a_A(B) is a property of A and of the scaffold alone: it can be computed, or estimated from as many runs of A as one likes, without a question to the human. With probability at least 1 − δ, simultaneously for all B ∈ 𝓑: |Δ(B) − (a_A(B) − ĥ(B))| ≤ √(ln(2/(π(B)·δ))/(2m)).

 (b2) With probability at least 1 − δ, simultaneously for all B ∈ 𝓑: if â(B) = 0 then a_A(B) ≤ ln(2/(π(B)·δ))/m, and if ĥ(B) = 0 then h_A(B) ≤ ln(2/(π(B)·δ))/m.

 (b3) *With A2: a certificate for the number of unfaithful calls.* Let A be a kernel, let H be a class with weights w, and for ν ∈ H let B_ν := {(x, y) : A(y|x) > ν(y|x)}. Then Δ(B) ≤ β(A)/L for every test B, and Δ(B_P) = β(A)/L. With probability at least 1 − δ, simultaneously for all ν ∈ H: Δ(B_ν) ≤ â(B_ν) − ĥ(B_ν) + √(2·ln(1/(w(ν)·δ))/m). So if P ∈ H and K ≤ K₀, then with probability at least 1 − δ

  β(A)/L ≤ max{ â(B_ν) − ĥ(B_ν) : ν ∈ H, w(ν) ≥ 2^(−K₀) } + √(2·(K₀·ln 2 + ln(1/δ))/m).

(c) *What disagreements and tests do not certify* (corrected in the edition; both reports found the first sentence of the earlier version false in one direction).

 (c1) *The exact imitator of a human who varies fails the certificate of (a).* For A = P the rate of recorded disagreement is ρ = s_P, which is positive unless P is a function on the inputs visited, although β(P) = 0. By (a0) the rate is an upper bound on β(A)/L for every human; it is a useful one only if the human is nearly deterministic on the inputs visited.

 (c2) *A finite family of tests that is fixed without regard to A does not bound the number of unfaithful calls.* If Y is infinite and 𝓑 is finite, there are a function P and a function A with Δ(B) = 0 for every B ∈ 𝓑 and all calls of every run of A unfaithful. (In this example the human is a function, and part (a) certifies what the tests miss. A family that may depend on A can do better: for an imitator that is a function a, the one test B_a := {(x, a(x)) : x ∈ X}, the graph of a, has Δ(B_a) = β(A)/L for every human.)

 (c3) *For a randomised imitator of a human who is not deterministic,* single answers certify a small number of unfaithful calls under A2 (part (b3)) and not without it (Proposition 13.4).

*Proof.* (o) Given A, round i uses a fresh (z_i, ρ_i), fresh coins of A and a fresh J_i, and by H1 the human's answer is a draw from P(·|x_i) given everything realised before it. So the conditional law of the tuple of round i, given the earlier rounds, is one fixed law.

(a) By (o) the d_i are independent with one mean ρ. (a0) Given the run τ_i and J_i, the human's answer y^P_i is a draw from P(·|x_i) by H1, so on {a_i = 1} it differs from the recorded answer y^A_i with conditional probability 1 − P(y^A_i|x_i). J_i is uniform and independent of τ_i, so ρ = (1/L)·E Σ_{j≤len} (1 − P(y_j|x_j)); and given the history h_j the answer y_j has the law A_j(·|h_j), which gives the formula for ρ. Now let a be a distribution on Y_⊥ and p one on Y. First, a(y)·p(y) ≤ min(a(y), p(y)), so 1 − Σ_y a(y)p(y) ≥ 1 − Σ_y min(a(y), p(y)) = TV(a, p). Second, Σ_y p(y)² − Σ_y a(y)p(y) = Σ_y p(y)·(p(y) − a(y)) ≤ Σ_{y: p(y)>a(y)} (p(y) − a(y)) = TV(a, p), so 1 − Σ_y a(y)p(y) ≤ TV(a, p) + 1 − Σ_y p(y)². Third, Σ_y a(y)p(y) ≤ max_y p(y) and 1 − Σ_y p(y)² ≤ 1 − (max_y p(y))² ≤ 2·(1 − max_y p(y)), so 1 − Σ_y a(y)p(y) ≥ (1 − Σ_y p(y)²)/2. Apply the three inequalities with a = A_j(·|h_j) and p = P(·|x_j) at every call and take E_{Q_A} Σ_{j≤len}. For a function, P(·|x_j) is a point mass, s_P = 0, and a call is unfaithful exactly if y_j ≠ f(x_j). (a1) If β(A)/L > ln(1/δ)/m, then ρ > ln(1/δ)/m by (a0), and (1 − ρ)^m ≤ e^(−ρm) < δ. The certificate is issued with probability (1 − ρ)^m ≤ e^(−ρm) ≤ e^(−m·s_P/2). (a2) The first inequality is (a0). For the second: for 0 < t ≤ ρ and s ≥ 0, E[e^(−s·mρ̂)] = (1 − ρ·(1 − e^(−s)))^m ≤ exp(−mρ·(1 − e^(−s))), so by Markov's inequality with e^(−s) := 1 − t/ρ and ε := t/ρ,

  Pr[ρ̂ ≤ ρ − t] ≤ exp(−mρ·(ε + (1 − ε)·ln(1 − ε))) ≤ exp(−mρ·ε²/2) = exp(−m·t²/(2ρ)),

because (1 − ε)·ln(1 − ε) ≥ −ε + ε²/2 on [0, 1). Put ℓ := ln(1/δ). If ρ ≤ 2ℓ/m there is nothing to prove. Otherwise t := √(2ρℓ/m) < ρ, and with probability at least 1 − δ we have ρ − √(2ρℓ/m) < ρ̂; with b := √(2ℓ/m) this reads (√ρ)² − b·√ρ − ρ̂ < 0, hence √ρ < (b + √(b² + 4ρ̂))/2 and ρ < ρ̂ + b²/2 + (b/2)·√(b² + 4ρ̂) ≤ ρ̂ + b² + b·√ρ̂. (a3) By Definition 8.2(a) the run of A is the run of the human system corrupted by r^A, with β(A) replacements in expectation, and Theorems 8.4 and 8.6 are stated in terms of β(A). For an imitator that draws a kernel C for each run, the argument of (a0), applied given C, shows that the rate of recorded disagreement is at least the mean of β(C)/L over the kernel drawn, and Theorem 8.4(a) gives Q_C(G^c) ≤ δ + β(C)/(k + 1) for every kernel; take the mean. For a function f a replacement is a call with y_j ≠ f(x_j), and the run equals τ^f(z, ρ) if there is none.

(b) Put g_i(B) := a_i·(1[(x_i, y^A_i) ∈ B] − 1[(x_i, y^P_i) ∈ B]) ∈ {−1, 0, 1}. Since J_i is uniform and independent of τ_i, E[a_i·1[(x_i, y^A_i) ∈ B]] = a_A(B); and since y^P_i ~ P(·|x_i) given the run and J_i, E[a_i·1[(x_i, y^P_i) ∈ B]] = E[a_i·P(B_{x_i}|x_i)] = h_A(B). So the g_i(B) are independent with mean Δ(B) and range of length 2. (b1) By both parts of Lemma 12.1 (with c_j = 2 and the sum over the m rounds), Pr[|(1/m)·Σ_i g_i(B) − Δ(B)| ≥ t] ≤ 2·exp(−m·t²/2), which is π(B)·δ for the stated t; sum over B. (b1′) The variables a_i·1[(x_i, y^P_i) ∈ B] are independent with values in {0, 1} and mean h_A(B), so by both parts of Lemma 12.1 with c_j = 1, Pr[|ĥ(B) − h_A(B)| ≥ t] ≤ 2·exp(−2m·t²), which is π(B)·δ for t = √(ln(2/(π(B)·δ))/(2m)); sum over B, and note that Δ(B) − (a_A(B) − ĥ(B)) = ĥ(B) − h_A(B). (b2) If a_A(B) > ln(2/(π(B)·δ))/m, then Pr[â(B) = 0] = (1 − a_A(B))^m < π(B)·δ/2, and likewise for ĥ; sum over B. (b3) For a kernel A, a_A(B) = (1/L)·E Σ_{j≤len} A(B_{x_j}|x_j), so Δ(B) = (1/L)·E Σ_{j≤len} (A(B_{x_j}|x_j) − P(B_{x_j}|x_j)). For distributions a, p and any set S, a(S) − p(S) ≤ TV(a, p), with equality for S = {a > p}. This gives Δ(B) ≤ β(A)/L and Δ(B_P) = β(A)/L. The one-sided part of Lemma 12.1 gives Pr[Δ(B_ν) − (â(B_ν) − ĥ(B_ν)) ≥ t] ≤ exp(−m·t²/2) = w(ν)·δ for t = √(2·ln(1/(w(ν)·δ))/m); sum over ν. The last display is the case ν = P, with ln(1/w(P)) ≤ K₀·ln 2.

(c) (c1) is a computation: for A = P the two recorded answers are independent draws from P(·|x_i), so the formula of (a0) gives ρ = s_P, and β(P) = 0. (c2) The finitely many tests of 𝓑 partition X × Y_⊥ into finitely many cells (two pairs are in the same cell if they belong to the same tests). For every x there are, among the infinitely many pairs (x, y), y ∈ Y, two in the same cell, say (x, p(x)) and (x, a(x)) with p(x) ≠ a(x). Let P be the function p and A the function a. Then 1[(x, a(x)) ∈ B] = 1[(x, p(x)) ∈ B] for all x and all B ∈ 𝓑, so Δ(B) = 0, and every call of every run of A is unfaithful. For the graph test of a function a: every answer of A lies in B_a, so a_A(B_a) = E[len]/L, and h_A(B_a) = (1/L)·E Σ_{j≤len} P(a(x_j)|x_j); the difference is (1/L)·E Σ_{j≤len} (1 − P(a(x_j)|x_j)) = β(A)/L, because the total variation between the point mass at a(x) and P(·|x) is 1 − P(a(x)|x). (c3) refers to (b3) and to Proposition 13.4. ∎

**Corollary 13.2 (rehearse, validate, deploy). NEW.** Assume H1 and let P be a function f ∈ H. Run Protocol R with n rounds, then validate A := M^(T) (or the imitator that draws a fresh round for every run, which is frozen in the sense of Definition 13.0) with m rounds. The probability that no disagreement is recorded is at least 1 − m·ln(W/w(f))/n. So for n ≥ m·K ln 2/δ′ the certificate of (a1), β(A) ≤ L·ln(1/δ)/m, is issued with probability at least 1 − δ′. And whatever A is, and whether or not f ∈ H, the probability that a false certificate is issued is less than δ.

*Proof.* Given A, the probability of at least one recorded disagreement is at most m·ρ(A), and E[ρ(M^(T))] = E[β(M^(T))]/L ≤ ln(W/w(f))/n by Proposition 5.2(a); for the fresh-round imitator ρ = β̄/L, with the same expectation. The last sentence is Theorem 13.1(a1). ∎

*What it does not say* (both reports). It does not say that a certificate, once issued, is false with probability less than δ. That conditional statement is false: an imitator with ρ = 2·ln(1/δ)/m receives the certificate with probability about δ², and each time it does the certificate is false; if every imitator submitted to validation has ρ slightly above ln(1/δ)/m, every certificate issued is false (`proofs/code/rehearsal-core_check_v1.out`, part 6; `proofs/code/rehearsal-core_attack_v1.out`, part D). "Confidence 1 − δ" in the note means the statement proved: an imitator for which the claim is false passes with probability less than δ.

*The price of the rule "no disagreement"* (attack report, finding m5). To certify an expected number γ of unfaithful calls one needs m = L·ln(1/δ)/γ rounds, and the certificate is likely to be issued only if n ≥ m·K ln 2/δ′ = (ln(1/δ)/δ′)·L·K ln 2/γ: the imitator must be better than what is certified by the factor ln(1/δ)/δ′, which is 30 for δ = 0.05 and δ′ = 0.1. The reason is in the rule: m rounds without a disagreement are likely only if ρ is below δ′/m. Form (a2), which allows recorded disagreements, certifies about 4.4·ln(1/δ)/m when the true ρ is ln(1/δ)/m, so it does not ask for a better imitator than it certifies, up to that constant.

**Remarks 13.3.** (i) *What the certificate rests on.* On H1 for the validation questions; on A being frozen; on J_i being drawn after the run, independently of it, so that A cannot treat the call that will be examined differently from the others; on y^A_i being the answer used in the run and not a new draw (for an answerer with private coins or memory within the run a new draw would have another law); and on deployment being a run of the same scaffold, with (z, ρ) drawn from the same law, answered by the same A. It does not rest on A2, nor on any property of the way A was obtained. Each of these is needed: an answerer that knew J_i before answering could answer the examined call as the human does and all other calls at will; an answerer that changes after validation is not the one that was examined; and if a new draw were recorded in place of the answer used in the run, the certificate would be wrong for an imitator that draws one hypothesis per run: when each hypothesis errs only at inputs that its own runs visit, a newly drawn hypothesis is mostly right at the examined call although the run was not.

(ii) *Runs shorter than the drawn index.* Because a round with J_i > len(τ_i) counts as a round without disagreement, d_i has the mean E[N]/L exactly. If J_i were drawn uniformly from {1, …, len(τ_i)} instead, every round with a nonempty run would ask a question, and the recorded disagreements would be Bernoulli with mean E[N/len]; this is at least E[N]/L, so the certificates of (a) remain valid as bounds on E[N]/L, but the frequencies no longer estimate E[N]/L.

(iii) *The price of a test is the logarithm of the weight given to it before validation.* For a finite family of N₀ tests with equal weights the tolerance in (b1) is √(2·ln(2N₀/δ)/m), whatever the tests are; with π(B) := 2^(−K(B)) the price of a test is its complexity. The tests may be chosen after the rehearsal and after looking at the imitator, by any procedure; they need not be simple, and for the theorem they need not be decidable (to evaluate the recorded frequencies one must be able to decide membership for the recorded pairs). The same proof gives (b) for tests that are sets of pairs (history before the call, answer).

(iv) *What (b) certifies.* That the answers of A, at the inputs of A's own runs, lie in each test of the family about as often as the human's answers to the same inputs would, in the average over the calls of a run. It certifies nothing about any single input (each input is seen once), nothing about the joint behaviour of several answers of one run (the human answers one call per run), and, by (c), no bound on the number of unfaithful calls unless the family contains the right test, as it does in (b3) under A2. The tolerance of (b1) is of the order 1/√m; for tests that are never met, (b2) gives the order 1/m.

(v) *Several candidates, several attempts.* If each of several frozen imitators is validated with its own m rounds and one that passes is deployed, the probability of a false certificate is at most the sum of the individual probabilities. The same holds when validation fails and is repeated, with the same imitator or another: r attempts issue a false certificate with probability less than r·δ. So the protocol must fix in advance how many attempts there may be. (Ross, Gordon and Bagnell 2011 end their Algorithm 3.1 with "Return best π̂_i on validation", according to the attack report, whose author read it in the source.)

(vi) *The human system is not needed for validation,* but the human is: validation puts at most m further single questions. And the certificate is for one scaffold with one law of top-level inputs; it says nothing about the same imitator in another scaffold.

**Proposition 13.4 (two humans that single answers cannot tell apart). Added in the edition. Part (a) is statement (c′) of the check report; part (b) is Proposition X2 (B2) of the attack report. The editor re-derived both proofs; no second verifier checked them.** Assume H1 for every human named. A2 is not assumed.

(a) *Inputs that do not repeat.* Let α be a distribution on Y that is not a point mass, c_α := 1 − Σ_y α(y)² > 0, X₀ a set of N inputs, the scaffold one call (L = 1) at an input uniform on X₀, and A the kernel with A(·|x) := α for x ∈ X₀. Against the human P := A we have β(A) = 0. Against the deterministic human given by a function p: X₀ → Y we have β(A) = b(p) := (1/N)·Σ_{x∈X₀} (1 − α(p(x))). Consider any procedure that puts at most m questions to the human, each at an independently and uniformly drawn input of X₀ (validation as in Definition 13.0 is such a procedure), and then issues or does not issue the certificate "β(A) ≤ B", for a number B < c_α. If for every human the probability that it issues the certificate when the certificate is false is at most δ, then against the human P = A, for whom the certificate is true, it issues the certificate with probability at most

  δ + m(m − 1)/(2N) + exp(−2N·(c_α − B)²).

(b) *Any questions, a large answer set.* Let Y have M elements, M even, and let A be the kernel that answers uniformly on Y at every input. The human P₀ also answers uniformly on Y at every input. For a family S = (S_x)_{x∈X} of subsets of Y with M/2 elements each, the human P_S answers at x uniformly on S_x. Then β(A) = 0 against P₀, and β(A) = E[len]/2 against every P_S, where E[len] is the expected number of calls of a run of A. Consider any procedure that puts at most m questions of its choice to the human, adaptively, repeated or not, and then issues or does not issue a certificate "β(A) ≤ B" with B < E[len]/2. If for every human the probability that it issues the certificate when the certificate is false is at most δ, then against P₀ it issues the certificate with probability at most δ + m(m − 1)/(2M).

*Proof.* (a) Draw p at random with independent coordinates p(x) ~ α. As long as no input has been drawn twice, each answer of the human p is, given the earlier inputs and answers, a draw from α. So what the procedure sees under the random p and under P = A has the same law up to the first repetition of an input, and the probability that some input is drawn twice among m is at most m(m − 1)/(2N). Hence Pr_A[issue] ≤ E_p[Pr_p[issue]] + m(m − 1)/(2N). For p with b(p) > B the certificate is false, so Pr_p[issue] ≤ δ. And b(p) is the mean of the N independent variables 1 − α(p(x)) ∈ [0, 1], each with mean Σ_y α(y)·(1 − α(y)) = c_α, so Pr_p[b(p) ≤ B] ≤ exp(−2N·(c_α − B)²) by Lemma 12.1. Together E_p[Pr_p[issue]] ≤ δ + exp(−2N·(c_α − B)²).

(b) The total variation between the uniform distribution on Y and the uniform distribution on a set of M/2 elements is ½, which gives β(A) = E[len]/2 against P_S. Draw S at random, the sets S_x independent and uniform over the subsets of M/2 elements. Consider the question number i + 1 of the procedure (i questions were put before), at an input x at which c ≤ i distinct answers have been received so far. Under P₀ the next answer has probability 1/M for every value. Under the random S, given everything seen so far, the set S_x is uniform over the sets of M/2 elements that contain the c values seen (every such set gives the answers received at x the same likelihood, every other set gives them the likelihood 0, and the answers at other inputs do not depend on S_x). So the next answer equals each of the c values seen with probability 2/M and, by symmetry, each of the other M − c values with probability (1 − 2c/M)/(M − c). The total variation between the two conditional laws is ½·(c·(1/M) + (M − c)·|1/M − (1 − 2c/M)/(M − c)|) = c/M ≤ i/M. By Lemma 3.2(c), applied to the scaffold whose internal randomness is the coins of the procedure and whose calls are its questions, the laws of everything the procedure sees under P₀ and under the random S differ by at most Σ_{i<m} i/M = m(m − 1)/(2M) in total variation. Against every P_S the certificate is false, so E_S[Pr_{P_S}[issue]] ≤ δ, and Pr_{P₀}[issue] ≤ δ + m(m − 1)/(2M). ∎

*Reading.* Without A2, single answers cannot certify that a randomised imitator of a human who is not deterministic has few unfaithful calls, however good the imitator is: in (a) as long as m is small against √N (the inputs do not repeat), and in (b) whatever the questions are, as long as m is small against √M. For answers of 100 bits and m = 10⁹ questions the term m(m − 1)/(2M) is 4·10⁻¹³. Under A2 the functions p of (a) and the families S of (b) are excluded by their description length, which is why (b3) of Theorem 13.1 is possible. The bounds are of the kind that underlies the lower bounds for testing whether a distribution is uniform (Paninski 2008, named in `research/sections/related-work.md`; not opened by the editor). Exact values of the total variation in (b) for one input asked m times: 0.0264 against the bound 0.0273 for M = 1024, m = 8, and 0.00469 against 0.00472 for M = 2²⁰, m = 100 (`proofs/code/rehearsal-core_editor_checks.out`, block 4; the attack report has more, `proofs/code/rehearsal-core_attack_v1.out`, part B).

*What it does not say.* It does not exclude certificates when inputs repeat and the answer set is small (Proposition 13.5; and the squared distance of answer laws from questions put twice, Pr7 of the note). It does not concern imitators that are functions (the graph test of Theorem 13.1(c2)) or humans who are nearly deterministic (Theorem 13.1(a)).

**Proposition 13.5 (a certificate from repeated questions, for a small answer set). Added in the edition. It is Proposition X3 of the attack report; the editor re-derived the proof; no second verifier checked it.** Assume H1, let Y have s elements, and let A be frozen. Change validation as follows: in round i, if J_i ≤ len(τ_i), the input x_i of the audited call is put to the human r times, and p̂_i is the empirical distribution of the r answers. Let q_i := A_{J_i}(·|h_{i,J_i}) be the law of the answer of A at the audited call given the history before it. (It is computed from A, or estimated by drawing A's answer at the recorded history as often as one likes; no question to the human is needed.) Put D_i := a_i·TV(q_i, p̂_i). Then with probability at least 1 − δ,

  β(A)/L ≤ (1/m)·Σ_{i≤m} D_i + ½·√((s − 1)/r) + √(ln(1/δ)/(2m)).

*Proof.* By the triangle inequality TV(q, p) ≤ TV(q, p̂) + TV(p̂, p). For the empirical distribution p̂ of r independent draws from p: E[TV(p̂, p)] = ½·Σ_y E|p̂(y) − p(y)| ≤ ½·Σ_y √(p(y)(1 − p(y))/r) ≤ ½·√(s·(1 − Σ_y p(y)²)/r) ≤ ½·√((s − 1)/r), by the Cauchy–Schwarz inequality and Σ_y p(y)² ≥ 1/s. By H1 the r answers of round i are independent draws from P(·|x_i) given the run and J_i, and J_i is uniform and independent of the run; so E[D_i] ≥ (1/L)·E Σ_{j≤len} TV(A_j(·|h_j), P(·|x_j)) − ½·√((s − 1)/r) = β(A)/L − ½·√((s − 1)/r). The D_i are independent with values in [0, 1], so by Lemma 12.1 their mean is above E[D_1] − √(ln(1/δ)/(2m)) with probability at least 1 − δ. ∎

*What it does not say.* The human answers up to m·r questions. The bound is of use only if r is large against s: it is for answers from a small set (yes or no, a grade), not for texts. And it uses A1 where A1 is least credible for a person: the same question is put r times, and each answer must be a fresh draw from P(·|x), although a person who is asked the same question again remembers the first time. The adversary's simulation found no violation in 4000 trials for each of six settings (`proofs/code/rehearsal-core_attack_v1.out`, part C); block 9 of `proofs/code/rehearsal-core_editor_checks.out` evaluates the middle term exactly for s = 2.

## 14. What remains open in this part

1. **The last round for a deterministic human on a scaffold whose inputs depend on the answers.** The ratio of E[β(M^(n+1))] to L·K ln 2/n can be of order √L (Proposition 6.3) and is at most of order L²·ln n (Proposition 6.4); the ratio of E[u(M^(n+1))] to L·K ln 2/n is at most of order L·ln n (Proposition 6.4), and no example with a ratio above a constant is known. The right orders are open. (A variant of the example of Proposition 6.3 with a separate routing input for every trap may give a factor of order L/ln L for the number of unfaithful calls; this has not been written out or checked.) Also open is whether the example of Proposition 6.3 can be built from functions only: as it stands, the statement that no bound C·L·K/n holds for the number of unfaithful calls of the last mixture is proved for classes that contain samplers that are not functions. The adversary's searches over small random instances (n ≤ 12) found no last mixture above 0.5 times the bound of the random round (`proofs/code/rehearsal-core_attack_lastgeneral.out`), which says little. Proposition 6.4 says nothing for n below about 2L²·K ln 2·(ln L + 3).
2. **The last round for a human who is not deterministic:** on a non-adaptive scaffold for weights with Σ_ν √(w(ν)) = ∞ (Proposition 6.1(b) needs the sum to be finite), and any upper bound at all on scaffolds whose inputs depend on the answers.
3. **The averaged kernel.** For the expected number of unfaithful calls of M̄ (a new round at every call) there is only β(M̄) ≤ L·u(M̄) ≤ L²·β̄; Proposition 5.5 settles the probability of an unfaithful run up to a constant. The human who is not deterministic is not treated.
4. **Constants.** Theorem 9.2 against Proposition 9.1: 0.088 against 0.59. Proposition 9.3: K·(1 − 2γ)²/(32θ²) against K ln 2/(2θ²γ′²) and 4e²·K ln 2/(θ²·γ′) (Propositions 9.1(b) and 9.4); whether the number of questions must grow as the excess failure γ′ shrinks, as both upper bounds do, is open. Proposition 10.3: the largest factor lost by freezing after online rehearsal is at least 1/(1 − (1 − 1/L)^L) and at most (1 − 1/L)^(−(L−1)), that is between 1.58 and e for large L; the example that gives the lower value is not extremal (Remark (ii) after Proposition 10.3).
5. **When does a human who is not deterministic cost 1/θ and not 1/θ²?** Proposition 9.3 shows that 1/θ² is needed for some human systems. A condition under which the linear rate holds (for example in terms of the variance of the cost-to-go under the human's own answers, as in the result of Foster, Block and Misra reported in `research/understand/imitation-theory.md`, Section 3.4) is not worked out.
6. **A single frozen imitator with high confidence.** For the mixture of a random round the factor 1/δ of Markov's inequality is needed (Proposition 5.2(d)). Corollary 13.2 obtains a certificate by validation, for a human who is nearly deterministic on the inputs visited; the best division of the answers between rehearsal and validation, and a selection among several rounds by validation, are not worked out. For a human who is not deterministic there is no such certificate without A2 (Proposition 13.4), and the factor 1/δ stays.
7. **Bounded damage.** The term √(2L·ln(1/δ)) in (12.1) is of the right order for the example of Remark 12.3(ii). A form that uses the variance of the human's steps (Bernstein's inequality) would be smaller when the steps are rarely negative; it is not written. No method for finding a progress function is given.
8. **The certificate for tests.** The tolerance of Theorem 13.1(b1) is of the order 1/√m; a form with the variance of the test (of the order √(frequency/m) + 1/m for rare tests on both sides) is not written, only the one-sided form (b2).
9. **Statements added in the edition that no second verifier checked:** Propositions 5.7, 9.4, 13.4 and 13.5, Remark 4.4(d), Example 8.5(d) and Theorem 5.1(d2). Each was proposed by one verifier and re-derived by the editor (Section 18).

The second half of the candidate's "sharper form" of R3, listed as open in the first version of this file, is not open: it is refuted by Example 5.5 of `proofs/lower-bounds.md`.

## 15. Remarks on other files of the project

The remarks of this section are about the lead's drafts and about the provers' versions of other parts, as they stood when this part was checked. The section text `research/sections/rehearsal-core.md` applies those that concern Sections 1 to 3 of the note.

**`note.md`, Sections 1 to 3.** Two statements there are false as written: Proposition R3a without the hypothesis that every run has exactly L calls (item 8), and the last paragraph of Section 3.3, on what can be measured when the human is not deterministic (item 12). Theorem V1 needs the hypothesis that the answerer is frozen (item 9). The other points make statements exact or correct an attribution.

1. *Deployment (Section 2).* "Draw T uniformly from {1, …, n} and deploy M^(T)" must say that one round is drawn for a whole run (or once for good). An imitator that draws a new round at every call is the averaged kernel M̄; its run can be unfaithful with a probability of the order of L times larger (at most L times; about L/4 times in the ladder with p = ½; Proposition 5.5).
2. *Notation.* The note uses m for the number of tolerated faults (Section 3.2) and for the number of validation rounds (Section 3.3); the outline fixes m for validation. This file writes k for the faults. In Protocol R, n is the number of rounds; the number of questions is at most n, because a round whose run is shorter than the drawn index asks nothing.
3. *Proof of R1.* "Π_t M^(t)(y_t|x_t) = Σ_ν w(ν)·Π_t ν(y_t|x_t)" holds with the factor 1/W on the right; since W ≤ 1 the inequality that follows is correct. "On every path" should read "almost surely" when the human is not deterministic. Before expectations are taken the summands must be shown to be integrable (Lemma 4.1(ii)); this is routine and belongs in the proof file.
4. *First remark after R1.* "Each question lowers its weight relative to the human's by an expected factor that depends on ρ only" is not exact: the factor depends on how the hypothesis answers, not only on how often it differs from the human. For a hypothesis and a human that are both functions the exact statement is that a question refutes the hypothesis with probability equal to the frequency of their disagreement among the calls of the rehearsal run. The theorem does not use such an account.
5. *Third remark after R1.* "They have the same distribution" should be: given the data before round t, the question of round t is a uniformly chosen call of a run of M^(t), and the deployed run for T = t is another run of the same kernel.
6. *Faithful calls (Section 1) and the proof of R3.* "The run of the imitator is a run of the human system in which the answers at the unfaithful calls were replaced" is true in the sense of Definition 3.3 and Proposition 3.4: after a replacement the later answers of the human are fresh answers to the inputs of the changed run. Only for a deterministic human is it the run on the same (z, ρ) with some answers overwritten. The replacement rule sees the human's answer; for a human who is not deterministic this matters (Remark (ii) after Theorem 8.4, Remark 12.3(ii)).
7. *Theorem R3.* Correct. For imitators that are kernels the hypothesis can be weakened to tolerance against budgeted stateless rules (Theorem 8.4(a), Example 8.5). The sentence for a human who is not deterministic needs the Cauchy–Schwarz inequality besides Pinsker's (Proposition 9.1); the order 1/θ² that results cannot be improved in general (Proposition 9.3), and Proposition 9.4 has a second bound that is better for a small excess failure. "m = θL" must be an integer k with k + 1 ≥ θL. The clause "sees the human's answer" in the definition of tolerance cannot be dropped (Example 8.5(d)). The recoverable form (Theorem 8.6) should stand next to it; it is the form of the literature.
8. *Proposition R3a.* False as written, for a scaffold whose runs can stop early, which Section 1 of the note allows (Remark 12.3(v); found by the adversary). With the hypothesis that every run has exactly L calls it is correct, and the constant 8 can be 2. The statement also needs: "from every state" includes the states reached after replaced answers; D is at least the largest decrease that an answer of the human can cause; the progress function must be a quantity that a wrong answer cannot raise. For a deterministic human the square-root term is not needed. The sentence after R3a ("the number of questions needed … does not grow with the length of the run") gives the number for a deterministic human; Remark 12.3(iii) has both cases.
9. *Theorem V1.* Correct for a frozen answerer; "any answerer" must be "any frozen answerer". To be said: the recorded answer of A is the one used in the run; a round whose run is shorter than the drawn index counts as a round without disagreement, so "m questions" should be "m rounds"; "with confidence 1 − δ" means that an imitator for which the claim is false passes with probability less than δ; "Theorem R3 applies" needs tolerance against rules of the kind of A (against 𝓡_all if A looks at the history). In (b), "the expected number of those calls at which the human's answer would lie in B" should be "the expected number of calls of the run at which …". Part (a) need not assume a deterministic human: its certificate is valid for every human (Theorem 13.1(a0), (a1)). Additions available: the bound (a2) when disagreements are recorded; the halved tolerance (b1′); the one-sided form (b2); the certificate (b3) for the number of unfaithful calls of a human who is not deterministic, under A2; Corollary 13.2.
10. *Assumption A3.* The clause "not predictable by any hypothesis" is automatic for hypotheses that are functions of the input alone. What the proofs use is H1 (Assumption 1.6) and the five parts listed in Remark 1.7.
11. *Literature (Sections 2 and 3.1).* The note presents the protocol as "the method of Ross, Gordon and Bagnell (2011) … with the Bayes mixture as the learner and one question per run", and says that "what the protocol adds is that the bound is spent on the distribution that matters". The reduction is theirs, and so is that point. The algorithm in this form (logarithmic loss, one uniformly chosen call per run put to the expert, a uniformly chosen iterate deployed for a whole run) is Stagger of Li and Zhang (2025), and Theorem R1 for a deterministic human is the estimation step of their Theorem 3 (Section 17). The citation of the regret bound should name Hutter (2003, Theorem 1) for the divergence form, Solomonoff (2008) for question–answer pairs, and Proposition 5.7(b) of Paper 1 for the per-query mixture; Theorem 5.3 of Paper 1 is about the one-tape version.
12. *Last paragraph of Section 3.3* ("Part (b) is what can be measured when the human is not deterministic. No number of single answers at inputs that never repeat reveals the distribution P(·|x) at any one input; only frequencies of tests can be estimated."). Not correct as written, in three ways. The certificate of part (a) is valid for every human (Theorem 13.1(a0)). Under A2 the number of unfaithful calls is certified at the rate √(K/m) (Theorem 13.1(b3)). And A1 allows the same question to be put again, after which more can be estimated (Proposition 13.5; Pr7 of the note). What is true: without A2, single answers cannot certify that a randomised imitator of a human who is not deterministic has few unfaithful calls (Proposition 13.4), and the certificate of (a) is issued only if the human is nearly deterministic on the inputs visited.
13. *Section 1, "faithful calls".* "If no call is unfaithful, the run *is* a run of the human system": on that event the run coincides with a run of the human system built on the same probability space (Lemma 3.2(c)); given that event it need not have the law Q_P. The formula TV(A(·|x_j), P(·|x_j)) is for an imitator that is a kernel; for one that looks at the history it is TV(A_j(·|h_j), P(·|x_j)).
14. *Section 1, the class.* "The set of all samplers computable by a program" should say that such hypotheses are semimeasures (a program need not halt), that the mixture may then give no answer, and that the statements hold for any countable class with weights (Definition 1.1, Remark 4.4(b)).
15. *Sections 2 and 3: counts and emptiness.* "The human answers n + m single calls" should be "at most n + m". Section 3.2: "A run of L calls is entirely faithful with probability 1 − L·K ln 2/n" needs "at least" and "for a deterministic human"; "Section 4 shows that no protocol avoids this when every call is critical" should say that Section 4 gives a class and a scaffold for which no protocol avoids it. Nowhere do Sections 1 to 3 say where the bounds are empty (item (7) of "In brief"; the outline asks for it) or that the guarantees are per run (Remark 5.8).
16. *Closed systems.* The definition of the note is condition (C2) of Remark 1.7 only; (C1) and (C3) must be added (`research/prove-c/assumptions.md`, Section 4, has the examples).

**`research/candidate-theory.md`.** L1, L2, L3, R1, R2 for functions and R3 are correct as stated (with W ≤ 1). R3, "sharper form": the first half is Proposition 8.3 for a deterministic human (for other humans the argument of the curve is L·√(K ln 2/(2n)), not L·K ln 2/n); the second half is false (Example 5.5 of `proofs/lower-bounds.md`). Remark (i) is modified (Proposition 5.3); the reason given for Remark (iii) is incomplete (Remark (ii) after Proposition 6.2). Section 13, V1(a): the imitator need not be deterministic. Section 0, item 3 ("about K/(θδ) questions suffice, whatever L") is for a deterministic human; for a human who is not deterministic the corresponding number is K ln 2/(2θ²δ²) (Proposition 9.1(b)).

**`research/prove/lower-bounds.md`.** Theorem 6.1 there can be stated with twice its constant: its step (i) bounds the total variation below by θ times the indicator of a wrong sign, and the triangle inequality gives 2θ for the sum over the two signs (Theorem 9.2 here). This is an improvement, not a correction.

**`research/prove-b/hellinger-runs.md`.** Section 8.2, item 5, and Section 8.1, item 3, list the last round as open. Propositions 6.1 to 6.4 here answer it in part: for a deterministic human the total variation between the run of the last mixture and the human system is u(M^(n+1)), bounded in Propositions 6.1(a) and 6.4; for a human who is not deterministic the last round stays open for whole runs, and Proposition 6.2 excludes a bound of the order L·K/n for the divergence.

**`research/understand/imitation-theory.md`.** Its high-probability form (b) of Section 5.2 agrees with Lemma 4.3(b) and Proposition 5.2(b) here (the digest states it for the squared Hellinger distance of the literature, which is twice H²).

## 16. Numerical checks

All scripts are in `proofs/code/`; the output of each is saved in the file of the same name with the ending `.out`. There are three groups: the prover's seven scripts (`rehearsal-core_<name>.py`, Section 16.1), the verifiers' scripts (`rehearsal-core_check_<name>.py` and `rehearsal-core_attack_<name>.py`, Section 16.2), and the editor's script (`rehearsal-core_editor_checks.py`, Section 16.3). The scripts of one group share no code with those of another.

### 16.1 The prover's scripts

Sampling is used only in `rehearsal-core_percall_and_stochastic.py`, part (1), and in `rehearsal-core_lastround_count_mc.py` (fixed seeds); the instances of check (5) of `rehearsal-core_checks.py` are drawn at random with a fixed seed and then evaluated exactly. Everything else is exact up to floating-point rounding. The check report states that all seven scripts, run again, reproduce their saved outputs byte for byte.

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

### 16.2 The verifiers' scripts

Copied unchanged from `research/verify/code/`. The editor ran `rehearsal-core_check_sweep.py`, `rehearsal-core_check_constants.py`, `rehearsal-core_check_blind.py`, `rehearsal-core_attack_weighted.py` and `rehearsal-core_attack_r3.py` again in `proofs/code/`; each reproduces its saved output exactly. The others were not run again by the editor.

| script | what it checks | result as reported |
|---|---|---|
| `rehearsal-core_check_constants.py` | every numerical constant of the prover's file | all confirmed except 0.23881 in Proposition 6.3; the saved output has one line FAIL for that constant, which is 0.23882 in this file |
| `rehearsal-core_check_r1.py` | Theorem 5.1(a) to (c), Lemma 4.3, Proposition 9.1(a) by exact enumeration on a scaffold of horizon 3 with runs of length 0 to 3, inputs that depend on the answers, a repeated input, semimeasures, W < 1; the example of Theorem 5.1(d2) | all hold |
| `rehearsal-core_check_ladder.py` | Proposition 5.5 by an exact recursion, p ∈ {0.1, 0.5, 0.9}, L up to 40 | all inequalities hold in 54 cases |
| `rehearsal-core_check_lastround.py`, `rehearsal-core_check_sweep.py` | Propositions 6.1(a), 6.2, 6.3 by independent exact recursions; inequality (6.1) for 400 random parameter settings and Proposition 6.2 for 200 | no violation; the prover's values reproduced |
| `rehearsal-core_check_lowstakes.py` | Theorem 8.4 for answerers that depend on the history; Theorem 8.6 for random rules in 𝓡_all; Proposition 8.3(d); Example 8.5(c); Theorem 9.2 against one protocol; Proposition 9.3(ii) for γ > ½ | all hold; the conclusion of 9.3(ii) fails for γ > ½, as corrected here |
| `rehearsal-core_check_blind.py` | Example 8.5(d), second count | the gap exists for D = 3 and not for D = 1 |
| `rehearsal-core_check_online.py` | Theorem 10.1, Corollary 10.2, Proposition 10.3 by exact enumeration | all hold |
| `rehearsal-core_check_v1.py` | Proposition 12.2 against the rule of Remark 12.3(ii) on a grid; Theorem 13.1(a0), (a2), (b1), (b3); the graph test; what "confidence" means | all hold |
| `rehearsal-core_attack_r1.py` | Protocol R enumerated exactly on 1799 random instances with a local search: Theorem 5.1, Lemma 4.3, Propositions 5.2 and 9.1 | largest ratio of a left side to a right side 1.000000 |
| `rehearsal-core_attack_r3.py` | Theorem 8.4 against the exact worst case over all replacement rules on 400 random human systems; Example 8.5(d), first count; Remark 12.3(v) | no violation; the two examples as stated here |
| `rehearsal-core_attack_v1.py` | Theorem 13.1(a0) on 3000 random instances; Proposition 13.4 (exact total variations); Proposition 13.5 (simulation); the conditional reading of Corollary 13.2 | all as stated here |
| `rehearsal-core_attack_lastround.py`, `rehearsal-core_attack_lastgeneral.py` | Propositions 6.1 to 6.4 at the edges of their ranges and on 850 random instances with a local search | no violation; no last mixture above 0.5 times the bound of the random round was found (n ≤ 12) |
| `rehearsal-core_attack_ladder.py` | Proposition 5.5 exactly for L ≤ 4 | holds; the ratio of the averaged kernel to the random round is between 1.02 and 1.79 for these L |
| `rehearsal-core_attack_online.py`, `rehearsal-core_attack_online_l3.py` | Section 10 on 500 random instances and by local search | all bounds hold; the example of Proposition 10.3 is not extremal for L = 3 |
| `rehearsal-core_attack_lowstakes.py` | Proposition 9.4 against Proposition 9.1(b) in the family of Proposition 9.3 | exact tail below both bounds; Proposition 9.4 falls like 1/n |
| `rehearsal-core_attack_weighted.py` | Proposition 5.7 on 600 random instances | largest ratio 1.000000 |
| `rehearsal-core_attack_budget.py` | the numbers of item (7) of "In brief" and of Remark 5.8 | a table |

### 16.3 The editor's script

`rehearsal-core_editor_checks.py` recomputes what the edition added or changed. Block 3 evaluates inequalities on random distributions drawn with a fixed seed; everything else is exact.

```
== 1. Theorem 5.1(d): the bound of (c) is approached ==
  N=10: sum over all rounds of E beta(M^(t)) / L = 2.7836;  ln(1/w) = 4.6052;  two-function example: 1 - w = 0.99
  N=100: sum over all rounds of E beta(M^(t)) / L = 4.1909;  ln(1/w) = 4.6052;  two-function example: 1 - w = 0.99
  N=10000: sum over all rounds of E beta(M^(t)) / L = 4.6003;  ln(1/w) = 4.6052;  two-function example: 1 - w = 0.99
== 2. Example 8.5(d): faults placed blindly ==
  L=4000 mu=0.002 k=399: human system fails 0.0003; k calls answered blindly: 0.0007; k replacements by a rule that sees the answer: 1.0000; beta/(k+1) = 0.0200; 'delta + beta/(k+1)' with blind tolerance = 0.0207 < 1 = Q_C(not G)
== 3. Theorem 13.1(a0): TV(a,p) <= 1 - sum_y a(y)p(y) <= TV(a,p) + 1 - sum_y p(y)^2 ==
  20000 random pairs of distributions: max of TV - dis = 1.11e-16 (<= 0);  max of dis - TV - noise = 1.11e-16 (<= 0);  max of noise/2 - dis = 0.00e+00 (<= 0)
== 4. Proposition 13.4(b): m answers at one input, uniform on Y (M values) against uniform on a random half ==
  M=1024 m=8: exact TV = 0.026435 <= m(m-1)/(2M) = 0.027344
  M=1048576 m=100: exact TV = 0.004688 <= m(m-1)/(2M) = 0.004721
== 5. Proposition 9.4: Pr[N >= k] <= 2 e^2 L Lambda / k^2 + 2^-k ==
  12300 cases (L, t, k), of which 8148 have a bound below 1: largest value of exact tail / bound among these = 0.0852 (<= 1)
== 6. Proposition 5.6 (R7): one call per run at an input uniform on N values ==
  N=1000 n=50: fixed input: 0.0010; fixed set of 10 inputs: 0.0079; both <= L/n = 0.0200;  'the set of inputs not asked so far' (depends on the data): 0.9759
== 7. Constants ==
  Proposition 6.3: abar/sqrt(L) = 0.388355; abar/N <= 0.2388114 (so 0.23882, not 0.23881); bracket >= 0.34796 > 0.3479
  Proposition 6.4: with n = c * 2 L^2 K ln2 the term 2 L B0 (1 + ln(1/(2 B0))) = (1 + ln(L c))/c is below 1 only for c > 7.64  (L = 100; ln L + 3 = 7.61)
  Corollary 13.2: ln(1/delta)/delta' = 30.0 for delta = 0.05, delta' = 0.1
  Remark 12.3(v): L=1000 eta=0.5 delta=0.01, mu=1, D=0: the condition admits k = 308 with the constant 8 and k = 404 with the constant 2; on the early-stopping scaffold one replaced answer makes the run bad
  Budget (K bits, one hour per answer, 2000 hours a year), R1 with L = 10 and failure 0.1: K=1e2: 3.47 years; K=1e4: 347 years; K=1e9: 3.47e+07 years
  Certificate: m = ln(1/0.05)/(0.1*0.1) = 300 rounds certify an excess failure 0.1 under theta = 0.1, whatever L and K
== 8. Proposition 5.7 (audits that are not uniform): an exact example ==
  pi1=0.5: sum = 1.0571 <= ln(1/w(f)) = 1.6094
  pi1=0.9: sum = 1.0229 <= ln(1/w(f)) = 1.6094
  pi1=0.1: sum = 1.0914 <= ln(1/w(f)) = 1.6094
```

(Selected lines; the full output is in `rehearsal-core_editor_checks.out`.) The editor's checks are of single examples and of elementary inequalities. They support the statements added in the edition and prove nothing beyond the cases computed.

## 17. Literature used, and how

Every proof in this file is self-contained except for Pinsker's inequality. The other entries name the source of a standard argument or a neighbouring result.

* **Pinsker's inequality:** TV(p, q) ≤ √(KL(p ‖ q)/2), KL in nats. Standard; for example A. B. Tsybakov, *Introduction to Nonparametric Estimation*, Springer 2009, Lemma 2.5. Quoted from memory. Used in Proposition 9.1 and Theorem 9.2.
* **The regret bound for Bayes mixtures** (Lemma 4.1 here). Standard. The attributions follow `research/outline.md`, Addendum 2, item 2, and `research/sections/related-work.md`, whose author checked them; neither the prover nor the editor opened these sources. R. J. Solomonoff, "Complexity-based induction systems: comparisons and convergence theorems", *IEEE Transactions on Information Theory* 24(4):422–432, 1978: the squared-error form for the universal mixture on binary sequences (the expected sum of the squared errors of the predicted probabilities is at most (k/2)·ln 2 for a true measure of description length k). M. Hutter, "Convergence and loss bounds for Bayesian sequence prediction", *IEEE Transactions on Information Theory* 49(8):2061–2067, 2003, Theorem 1: the divergence form for a countable class (the expected log-likelihood ratio of the true measure μ to the mixture is at most ln(1/w_μ)). R. J. Solomonoff, "Three kinds of probabilistic induction: universal distributions and convergence theorems", *The Computer Journal* 51(5):566–570, 2008: the mixture on question–answer pairs (its equation (10)) and its convergence for any given inputs (equation (12)). In this repository the per-query mixture with inputs chosen from the earlier pairs is Proposition 5.7(b) of the first paper (`solomonoff-operator-induction`); Theorem 5.3 there is about the one-tape version and is not the right reference. The proof here is self-contained.
* **Chain rule for relative entropy** (Lemma 2.1): T. M. Cover and J. A. Thomas, *Elements of Information Theory*, 2nd ed., Wiley 2006, Theorem 2.5.3 (from memory). Self-contained proof given.
* **Rehearsal as a reduction to online learning.** S. Ross, G. J. Gordon and J. A. Bagnell, "A reduction of imitation learning and structured prediction to no-regret online learning", *Proceedings of AISTATS 2011*, JMLR W&CP 15:627–635; arXiv:1011.0686. Read in the source by the prover (arXiv version 3, Section 2.2), by the adversary, and by the editor (arXiv version 3, pages 1 to 5, in the session of the edition). Three things are used. (1) The reduction, their Theorem 4.1: "For DAGGER, there exists a policy π̂ ∈ π̂_{1:N} s.t. E_{s∼d_π̂}[ℓ(s, π̂)] ≤ ε_N + γ_N + (2ℓ_max/N)·[n_β + T·Σ_{i=n_β+1}^{N} β_i], for γ_N the average regret of π̂_{1:N}", where ε_N is the loss of the best policy in hindsight on the state distributions of the iterates and β_i the probability with which round i executes the expert. (2) The rule of deployment, their footnote 3: "It is not necessary to find the best policy in the sequence that minimizes the loss under its distribution; the same guarantee holds for the policy which uniformly randomly picks one policy in the sequence π̂_{1:N} and executes that policy for T steps." Their Algorithm 3.1 ends with the line "Return best π̂_i on validation". So rehearsing, validating and deploying, and deploying one uniformly chosen iterate for a whole run, are theirs. (3) The recoverable form, Theorem 2.2 there: "Let π be such that E_{s∼d_π}[ℓ(s, π)] = ε, and Q^{π*}_{T−t+1}(s, a) − Q^{π*}_{T−t+1}(s, π*) ≤ u for all action a, t ∈ {1, 2, …, T}, d^t_π(s) > 0, then J(π) ≤ J(π*) + uTε", where Q^{π′}_t(s, π) is the t-step cost of executing π in the initial state s and then following π′, ℓ is the 0-1 loss with respect to the expert π* or an upper bound on it, and the cost C is bounded in [0, 1]. Theorem 8.6 is this statement for scaffolds, with a proof for replacement rules that see the human's answer.
* **One question per run.** Y. Li and C. Zhang, "Interactive and hybrid imitation learning: provably beating behavior cloning", arXiv:2412.07057 (version 3, 13 January 2026; the arXiv comment says "Accepted by NeurIPS 2025"). The prover saw only the abstract. The paper was read in the source by the lead (`research/literature-checks.md`), by the adversary, and by the editor (version 3, pages 3 to 6, in the session of the edition). Their Algorithm 1, "Stagger": for n = 1, …, N_int, receive a policy π^n from an online learner, "execute π^n and sample s^n ∼ d^{π^n}", ask the expert for its action a^{*,n} at s^n, update the learner with the loss log(1/π(a^{*,n}|s^n)), and output "a first-step uniform mixture" of the π^n, which the text explains as "sample one π^n uniformly at random and execute it for the episode". Their Assumption 1: "The expert policy π^E is deterministic and is contained in the learner's policy class B", for a finite class of size B. Their Theorem 3: if the pair of environment and expert is μ-recoverable (one action other than the expert's, followed by the expert, costs at most μ) and the online learner is the exponential weight algorithm over the each-step mixtures of the class, then "with probability at least 1 − δ, J(π^E) − J(π̂) ≤ μH·(log(B) + 2 log(1/δ))/N_int". In the terms of this file that is Protocol R with Theorem 5.1(c), Proposition 5.2(b) and Theorem 8.6 for the uniform prior on a finite class. Their footnote 3 says that a version of another algorithm with one sample per iteration was analysed earlier in the lecture notes of Agarwal, Jiang, Kakade and Sun (not opened). What this file adds: weights on a countable class and semimeasures (so that the bound is in K), the human who is not deterministic (Sections 5 and 9), the statements about the round (Propositions 5.2(c), (d), 5.5, 6.1 to 6.4), coverage in the form of Proposition 5.6, tolerance of faults (Theorem 8.4), and the certificate (Section 13). None of these is deep, and no claim is made about what that paper leaves open.
* **High-probability form** (Lemma 4.3(b)): D. J. Foster, S. M. Kakade, J. Qian and A. Rakhlin, "The statistical complexity of interactive decision making", arXiv:2112.13487, Lemma A.14, as quoted in `research/understand/imitation-theory.md` (digest; the author of `research/sections/related-work.md` read the lemma in the arXiv text; not opened by the prover or the editor): with probability at least 1 − δ the sum of the conditional expectations of the squared Hellinger distances is at most the regret plus 2·log(1/δ), in the convention in which the squared Hellinger distance is twice H². The proof of Lemma 4.3 is self-contained.
* **Hoeffding's and Azuma's inequalities** (Lemma 12.1): W. Hoeffding, "Probability inequalities for sums of bounded random variables", *Journal of the American Statistical Association* 58:13–30, 1963, Theorem 2 and the remark on martingales at the end of its Section 2; K. Azuma, "Weighted sums of certain dependent random variables", *Tôhoku Mathematical Journal* 19:357–367, 1967. From memory. Self-contained proof given.
* **Two-point and hypercube lower bounds** (Theorem 9.2, Proposition 9.3): the method of Le Cam and Assouad; B. Yu, "Assouad, Fano, and Le Cam", in *Festschrift for Lucien Le Cam*, Springer 1997, pp. 423–435 (from memory). Written out in full here; Theorem 6.1 of `research/prove/lower-bounds.md` is the same statement with half the constant.
* **The argument of Proposition 6.1(a)** is that of the bounds for learners consistent with independent examples: A. Blumer, A. Ehrenfeucht, D. Haussler and M. K. Warmuth, "Occam's razor", *Information Processing Letters* 24:377–380, 1987 (from memory). Their statement is for a finite class and one threshold; the form with weights and the integral over the threshold is written out here.
* **Asking at random** (Theorem 10.1): Observation A of `research/understand/notes.md`, Section 6.2, which is that digest's own derivation; the proof is repeated here. The digest names N. Cesa-Bianchi, G. Lugosi and G. Stoltz, "Minimizing regret with label efficient prediction", *IEEE Transactions on Information Theory* 51:2152–2162, 2005, as the nearest published setting (not opened by the prover or the editor).
* **Low stakes.** The term is P. Christiano's ("Low-stakes alignment", Alignment Forum, 30 April 2021; cited as in `research/sections/related-work.md`, whose author did not open the post). The definition by tolerated faults (Definition 8.1) is this project's; the usual formal version in imitation learning is recoverability (Theorem 8.6, after Ross, Gordon and Bagnell).
* **The certificate from no recorded disagreement** (Theorem 13.1(a1)) is the "rule of three" for a rate with zero observed events: J. A. Hanley and A. Lippman-Hand, "If nothing goes wrong, is everything all right? Interpreting zero numerators", *JAMA* 249(13):1743–1745, 1983 (from memory; not opened). Theorem 13.1(b1) is Hoeffding's inequality with a union bound over weighted tests. That the price of a test is the logarithm of the weight given to it in advance, with nothing assumed about the source of the data, is the central point of the literature on outcome indistinguishability and multicalibration (C. Dwork, M. P. Kim, O. Reingold, G. N. Rothblum and G. Yona, "Outcome indistinguishability", STOC 2021; Ú. Hébert-Johnson, M. P. Kim, O. Reingold and G. N. Rothblum, "Multicalibration: calibration for the (computationally-identifiable) masses", ICML 2018; both as cited in `research/sections/related-work.md`, not opened by the editor). The sets {A > ν} of Theorem 13.1(b3) are used as in the minimum-distance estimate of Y. G. Yatracos, "Rates of convergence of minimum distance estimators and Kolmogorov's entropy", *Annals of Statistics* 13(2):768–774, 1985 (as cited in `research/sections/related-work.md`; not opened).
* **Proposition 13.4** is a bound of the "birthday" kind, as in the lower bounds for testing whether a distribution is uniform: L. Paninski, "A coincidence-based test for uniformity given very sparsely sampled discrete data", *IEEE Transactions on Information Theory* 54(10):4750–4755, 2008 (as cited in `research/sections/related-work.md`; not opened). The proofs here are self-contained.
* **Proposition 9.4** uses the exponential supermartingale for sums of indicators with predictable probabilities, as in D. A. Freedman, "On tail probabilities for martingales", *Annals of Probability* 3(1):100–118, 1975 (from memory; not opened). The proof here is self-contained.
* **The last iterate.** That the last iterate of a scheme of this kind carries no guarantee of its own has published relatives (C.-A. Cheng and B. Boots, "Convergence of value aggregation for imitation learning", AISTATS 2018; the work is named in `research/sections/related-work.md`, the title and venue are from the editor's memory, and nobody in this part opened it). Propositions 6.1 to 6.4 were not compared with that paper.

## 18. Checking

The prover's file `research/prove-c/rehearsal-core.md` was examined by two verifiers. The *check report* (`research/verify/rehearsal-core-check.md`) went through every numbered statement line by line, recomputed every constant, and ran nine scripts of its own. The *attack report* (`research/verify/rehearsal-core-attack.md`) looked for counterexamples with eleven scripts, compared the claims in words with the theorems, read the two main sources, and proposed seven additions (X1 to X7). Both reports are complete. Neither found a numbered statement of the prover's file wrong in substance; both found statements of `note.md` and sentences of the prover's file that had to change. The editor verified every finding before deciding it: by re-deriving the argument, and for the additions also by the script of Section 16.3. No finding was rejected. Three were accepted with a restriction, which the tables name.

### 18.1 Findings of the check report

| no. | finding | decision | what was done |
|---|---|---|---|
| C1 | Theorem 13.1(c) and the last paragraph of Section 3.3 of the note: the rate of recorded disagreement is at least β(A)/L for every human; "no finite family of tests" needs "fixed without regard to A"; statement (c′) on two humans that validation cannot tell apart is missing | accepted | Theorem 13.1(a0), (a1), (a2) restated for every human; (c) rewritten as (c1) to (c3) with the graph test; (c′) is Proposition 13.4(a); Section 15, items 9 and 12 |
| C2 | hypotheses missing in the note: R3a (every run has exactly L calls), V1 (the answerer is frozen), deployment (one round per run) | accepted | Proposition 12.2 already has the first, and Remark 12.3(v) now has the counterexample; summary table, "In brief" (1) and Section 15, items 1, 8, 9 corrected; the section text states all three |
| C3 | Proposition 6.3: the class of the example contains samplers that are not functions, and the summaries drop this | accepted | statement of Proposition 6.3, summary table, "In brief" (3), introduction and end of Section 6, Section 11, Section 14 |
| C4 | Corollary 13.2: "whenever it is issued it is false with probability less than δ" is false as a conditional statement | accepted | corollary reworded; a paragraph "What it does not say" added |
| C5 | Proposition 9.3(ii) is false for γ > ½ | accepted | hypothesis 0 ≤ γ ≤ ½ added, with the counterexample; the proof says where it is used |
| C6 | Theorem 5.1(d): equality is shown for (a) only; an example in which the bound of (c) is approached is supplied | accepted | (d) split into (d1) and (d2); the check report's example is (d2), re-derived and computed (Section 16.3, block 1) |
| C7 | Proposition 5.2(d): the conclusion is shown for levels up to 0.63 only | accepted | range stated; the proof ends with the sentence that gives it |
| C8 | Proposition 6.4: the bound exceeds 1 unless n exceeds 2L²·K ln 2 by a factor of about ln L + 3; "between 1 and" in Remark (ii) is not proved | accepted | paragraph "Where the statement has content" added; Remark (ii), the introduction of Section 6 and Section 14 corrected |
| C9 | Proposition 8.3: (c) the argument of the curve can exceed L; (d) needs L ≥ 2 and 0 < ε < 1 | accepted | both corrected |
| C10 | Remark (ii) after Theorem 8.4 asserts without proof that blind tolerance does not suffice; an example with D > 1 is supplied | accepted | Example 8.5(d), second count; Remark 12.3(ii) has the clause on max{2, μ + D} |
| C11 | Proposition 6.3: 0.23881 must be 0.23882 | accepted | corrected (Section 16.3, block 7) |
| C12 | "a probability L times larger" for the averaged kernel says more than is proved | accepted | "In brief" (2) and Section 15, item 1 reworded; the exact values of the check report are quoted after Proposition 5.5 |
| C13 | Proposition 5.2(c): the direct form of Markov's inequality is stronger than the form with two parameters | accepted | direct form added; the other kept as a statement about the fraction of bad rounds; the section text uses the direct form |
| C14 | small points: "L odd" in Proposition 9.3 is not used; Proposition 10.3 for q = 1; Example 8.5(a) shows tightness for δ = 0; the entry on the regret bound in Section 17 | accepted | each corrected in place |
| C15 | Theorem 13.1(a3): an imitator that draws one kernel for each run needs tolerance against budgeted stateless rules only | accepted | added to (a3), with its proof |
| C16 | Remark (ii) after Theorem 8.6: the direct bound μ·β is never the worse one when the other is at most 1 | accepted | added to the remark |
| C17 | Proposition 5.3: the definition of Protocol R⁺ leaves a case open | accepted | one sentence added |
| C18 | the changes to Sections 1 to 3 of `note.md` (part K of the report) | accepted | Section 15, items 1 to 16; applied in `research/sections/rehearsal-core.md` |

### 18.2 Findings of the attack report

| no. | finding | decision | what was done |
|---|---|---|---|
| M1 | what can be certified for a human who is not deterministic: the paragraph of the note is wrong in three directions, the example of 13.1(c) has a deterministic human, and the lower bound is missing | accepted | as C1; Proposition 13.4 (X2, with the check report's (c′) as part (a)); Proposition 13.5 (X3); Section 15, item 12 |
| M2 | the note does not say where its bounds are empty, nor what "the human need not stay for ever" costs; answers of a deterministic human can be cached | accepted | "In brief" (7); numbers after Theorem 5.1; Remark 5.8; the section text says it in Section 3 |
| M3 | the protocol, its analysis for a deterministic human and both halves of its low-stakes guarantee are published; the tag NEW misleads | accepted | first paragraph of the file; summary table (tags name the published rows); "Literature" after Theorem 5.1; Remark (i) after Proposition 5.2; Section 17. The editor read both sources (Section 17) |
| m1 | R3a as written in the note fails on a scaffold that may stop early; the progress function must not be raised by a wrong answer | accepted | Remark 12.3(iv), (v); summary table; Section 15, item 8 |
| m2 | Theorem 13.1(c), first sentence | accepted | as C1 |
| m3 | Corollary 13.2 and "confidence 1 − δ"; nothing is said on repeated attempts | accepted | as C4; Remark 13.3(v) |
| m4 | the clause "sees the human's answer" is essential; example | accepted | Example 8.5(d), first count; Remark (ii) after Theorem 8.4 |
| m5 | the certificate from no disagreement is issued only to an imitator better than what is certified by the factor ln(1/δ)/δ′ | accepted | paragraph after Corollary 13.2; the section text states form (a2) next to the rule |
| m6 | the tolerance of V1(b) can be halved, because the frequency of a test among the imitator's answers needs no human | accepted | Theorem 13.1(b1′) with proof; in this file only (the section text has no room for it) |
| m7 | for a human who is not deterministic the dependence on the excess failure is 1/γ′, not 1/γ′² (X4) | accepted | Proposition 9.4; Proposition 9.3(iii) and the paragraph after it; Section 14, items 4 and 5. In this file only: the section text states the bound of Proposition 9.1 and no number of questions as a function of the excess failure |
| m8 | hidden assumptions of the closed system | accepted | Remark 1.7 (the three conditions and the five parts of A3); Section 11, Remark (ii), had the point on inputs that the human system never produces; the section text states the conditions |
| m9 | the last round: scope of what is proved | accepted | as C3 and C8; Section 14, item 1; Section 17, last entry |
| m10 | "Section 4 shows that no protocol avoids this when every call is critical" claims too much | accepted | "What it does not say" after Theorem 7.1; Section 15, item 15; the section text |
| m11 | uniformity of the audited call is not needed (X5) | accepted | item (i) of "The hypotheses" after Theorem 5.1; Proposition 5.7 |
| m12 | the candidate's "sharper form" of R3 holds with the argument L·K ln 2/n for a deterministic human only | accepted | sentence after Proposition 8.3; Section 15, entry on the candidate theory |
| m13 | smaller points (9.3(ii), 5.1(d), 5.2(d), "L times larger", "validation certifies whichever imitator is deployed", the example of 10.3 is not extremal) | accepted | as C5, C6, C7, C12; "In brief" (3) and the end of Section 6 now say "for a deterministic human"; Remark (ii) after Proposition 10.3 |
| w1 to w10 | wording of the note and of the summary table | accepted | Section 15, items 3 to 5, 9, 11, 13 to 15; first paragraph and summary table of this file; applied in the section text |
| X1 | the certificate from no disagreement holds for every human, with ρ ≤ β(A)/L + s_P | accepted | Theorem 13.1(a0), (a1), with the further inequality ρ ≥ s_P/2 that gives the probability of issue |
| X2 | two-human lower bounds (B1: inputs that do not repeat; B2: any questions, large answer set) | accepted | Proposition 13.4; part (a) is the check report's more general form of B1 |
| X3 | a certificate from repeated questions for a small answer set | accepted, with a restriction | Proposition 13.5, with the statement of what it does not say. The section text does not feature it: the lead's decision (outline, Addendum 3, correction 1) limits what the note says can be certified for a human who varies, and Pr7 belongs to another part |
| X4 | Pr[N ≥ k] ≤ 2e²·L·Λ/k² + 2^(−k) | accepted | Proposition 9.4, proof re-derived; with tolerance of k faults the bound uses k + 1 |
| X5 | audits that are not uniform | accepted | Proposition 5.7, with the audit probabilities as functions of the whole run and the use with Theorem 8.6; in this file only |
| X6 | questions × unfaithful calls ≤ deployed calls × K ln 2 | accepted | Remark 5.8(i) |
| X7 | K may be read on the inputs that the scaffold can produce | accepted, with a restriction | Remark 4.4(d): it holds for the bounds that rest on Lemmas 4.1 to 4.3; Theorem 13.1(b3) needs one member of the class. It is also Proposition 2.2 of the part "assumptions" |
| Section 3 | the seven tests applied to this part | accepted as far as they concern this part | guard: the sentence on rare inputs after Theorem 5.1 and "What it does not say" after Proposition 5.6; budget and "for ever": as M2. The table of the tests is written by the part "assumptions" |
| Section 4 | what is not new | accepted | as M3 |

Rejected: none. One point on which the two reports differ is the count of faults for rules that do not see the human's answer. Both counts are right for what they count, and Example 8.5(d) gives both.

### 18.3 Which statements were checked, and by whom

"Check" means the check report, "attack" the attack report. A statement marked "editor only" was proposed by one verifier, written out and re-derived by the editor, and not read by a second verifier in its final form.

| statement | checked by |
|---|---|
| Lemma 2.1 (L1), Lemmas 3.1 and 3.2 (L2), Proposition 3.4, Lemmas 4.1 and 4.2 (L3), Lemma 4.3 | check (CORRECT, each); attack (HOLDS; proofs followed) |
| Remark 4.4(d) (which K) | proposed by the attack (X7); editor only; the same statement is Proposition 2.2 of `research/prove-c/assumptions.md`, which the reports on that part examined |
| Theorem 5.1(a) to (c) (R1) | check (CORRECT; exact enumeration); attack (HOLDS; exact search on 1799 instances) |
| Theorem 5.1(d1) | check (CORRECT) |
| Theorem 5.1(d2) | proposed by the check; editor only (re-derived, computed) |
| Proposition 5.2(a), (b), (c) first form, (d) | check (CORRECT; (d) with the range now stated); attack (HOLDS) |
| Proposition 5.2(c), direct form and the form for the fraction of rounds | proposed by the check; editor only (Markov's inequality) |
| Proposition 5.3 | check (CORRECT); attack (HOLDS) |
| Proposition 5.5 (averaged kernel, the ladder) | check (CORRECT; exact recursion in 54 cases); attack (HOLDS; exact for L ≤ 4) |
| Proposition 5.6 (R7) | as Theorem 3.2(a) of `research/prove-c/assumptions.md`: both reports on that part (CORRECT; HOLDS for each fixed set, exact check on all subsets in 40 instances). The proof as written here: editor only |
| Proposition 5.7 (audits that are not uniform) | proposed by the attack (X5, 600 random instances); editor only |
| Remark 5.8 | proposed by the attack; editor only (it is Proposition 5.2(a) applied R times) |
| Propositions 6.1, 6.2, 6.3, 6.4 | check (CORRECT; independent exact recursions; 6.3 with the constant corrected); attack (HOLDS; recomputed at the edges of the ranges) |
| Theorem 7.1 (R2 for a function) | check (CORRECT); attack (HOLDS) |
| Proposition 8.3, Theorem 8.4 (R3), Example 8.5(a) to (c) | check (CORRECT; the coupling of Theorem 8.4 checked call by call, exact check with answerers that depend on the history); attack (HOLDS; exact worst case over all rules on 400 systems) |
| Example 8.5(d) | first count: proposed and computed by the attack; second count: proposed and computed by the check; both re-derived by the editor; neither verifier read the other's example in its final form |
| Theorem 8.6 (recoverable form) | check (CORRECT; exact check with random rules); attack (HOLDS) |
| Proposition 9.1 | check (CORRECT); attack (HOLDS) |
| Theorem 9.2 | check (CORRECT; constant recomputed); attack (HOLDS; "not checked line by line beyond the order of the constant") |
| Proposition 9.3 | check (CORRECT with the hypothesis γ ≤ ½ now added); attack (confirms) |
| Proposition 9.4 | proposed by the attack (X4; exact computation in one family); editor only |
| Theorem 10.1, Corollary 10.2, Proposition 10.3 | check (CORRECT; exact enumeration); attack (HOLDS; random instances and local search) |
| Lemma 12.1, Proposition 12.2 (R3a), Remarks 12.3(i) to (iv) | check (CORRECT; exact check on a grid of 324 settings); attack (HOLDS; constant 2 confirmed) |
| Remark 12.3(v) | proposed and computed by the attack; the check asks for the same hypothesis; re-derived by the editor |
| Theorem 13.1(o), (a1) for a function, (a2), (a3), (b1), (b2), (b3), (c2) | check (CORRECT; exact binomial and enumeration checks); attack (HOLDS) |
| Theorem 13.1(a0) and (a1), (a2) for every human | found independently by the check and by the attack (X1), each with its own exact check on random instances; the further inequality ρ ≥ s_P/2: editor only |
| Theorem 13.1(b1′) | proposed by the attack (m6); editor only (Hoeffding's inequality) |
| Theorem 13.1(c1), (c3) | editor's wording of what both reports state |
| Corollary 13.2 | check (computation CORRECT, last clause corrected); attack (the same) |
| Proposition 13.4(a) | proposed and proved by the check ((c′)); the attack has the special case B1 with an exact computation; re-derived by the editor |
| Proposition 13.4(b) | proposed and proved by the attack (X2, B2, exact values); re-derived and recomputed by the editor; not read by the check |
| Proposition 13.5 | proposed by the attack (X3, simulation); editor only |

**What the section text uses.** `research/sections/rehearsal-core.md` states or uses: Lemma 3.2 and Proposition 3.4 (unfaithful calls), Remark 4.4(d) (which K), Lemma 4.1 and Theorem 5.1(a), (c), (d) (R1 and its proof), Proposition 5.2(a), (c) in the direct form, (d), Proposition 5.3, Proposition 5.5, Proposition 5.6 (R7, with its proof), Remark 5.8(i) in one sentence, Propositions 6.1(a) and 6.2, Theorem 7.1 (R2), Theorem 8.4 (R3, with its proof), Example 8.5(d) (first count), Theorem 8.6, Proposition 9.1, Theorem 9.2, Proposition 9.3, Theorem 10.1, Proposition 12.2 (R3a) with Remarks 12.3(iii) and (v), Theorem 13.1(a0), (a1), (a2), (a3), (b1), (b3), (c1), Corollary 13.2, and Proposition 13.4 in one sentence. It does not use Propositions 5.7, 9.4 and 13.5, Theorem 13.1(b1′), Propositions 6.3 and 6.4, or Proposition 10.3; these are in this file only.

Every statement that the section text uses was checked by at least one verifier, or was derived by one verifier and then re-derived by the editor, as the table says. The rule of the edition was to mark as "not independently checked" a statement that no verifier checked and that the editor did not re-derive; no statement used by the section text is in that case, so the section text carries no such mark. The statements used there for which only one verifier and the editor stand are: Theorem 5.1(d2) ("approached for the unfaithful calls"), the direct form of Proposition 5.2(c), Remark 5.8(i), and the inequality ρ ≥ s_P/2 behind "issued with probability at most exp(−m·s/2)". The sentence of the section text that rests on Proposition 13.4 ("single answers cannot certify …") rests on its part (a), which the check report proved and of which the attack report found the special case independently.
