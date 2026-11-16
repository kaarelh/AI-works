# One hypothesis per run, or a fresh posterior draw at every call (key: one-mind)

Part "one-mind" of the check of `research/candidate-theory.md` (labels R4, R5, R6; Section 5.1 of the note). Everything is written to be checked line by line. Tags: **PROVED** (the candidate's statement, in the precise form given here), **MODIFIED** (the statement needed a change, which is named), **REFUTED** (with the counterexample), **NEW** (not in the candidate theory, proved here), **OPEN**. Nothing here has been refereed. Scripts are in `research/prove-c/code/` (`one-mind_r4.py`, `one-mind_stochastic.py`, `one-mind_r5.py`, `one-mind_r6.py`), each with its output next to it (`.out`); Section 7 quotes them.

## Summary table

| no. | statement | tag |
|---|---|---|
| Lemma 1.4 | First deviation: a run answered by a hypothesis follows the human system's run up to and including its first wrong answer; runs of variable length. | PROVED |
| Lemma 1.5 | Potential: for a deterministic human the removed posterior masses m_t satisfy Σ_t m_t ≤ ln(W/w(f)) ≤ K ln 2 on every path, for any class of samplers or semimeasures. | PROVED (standard) |
| Theorem 2.1 (**R4**) | One posterior draw per run, deterministic human, hypotheses may be stochastic: Σ_t E[ψ_L(u_t)] ≤ L·K ln 2 with ψ_L(u) = u − u²(L−1)/(2L); hence Σ_t Pr[the run of round t differs from the human system's] ≤ (2L²/(L+1))·K ln 2 < 2L·K ln 2. | PROVED; MODIFIED (constant 2L²/(L+1) in place of 2L; refined form; stochastic hypotheses allowed; runs of variable length) |
| Corollary 2.2 | Deployment of the draw of a uniformly random round, per run or once for good. | PROVED |
| Remark 2.3 | The candidate's symmetry proof of R4, checked line by line: correct. | PROVED |
| Proposition 2.5 (with Example 2.4) | Sharpness: a class, scaffold and f with Σ_t Pr[run unfaithful] ≥ (2L(L−1)/(L+1))·(K−1) ln 2 − η. So the constant of Theorem 2.1 is exact up to the factor (1 − 1/L)(1 − 1/K), and the order L·K is attained. | NEW |
| Example 3.1 | Stochastic human, K = 1 bit, L = 3 (one question asked three times): in every round before an asked input recurs, one posterior draw per run has TV(run law, Q_P) = (3/2)ε(1−ε) at fresh inputs and the posterior never moves; the per-call mixture is exact there. With N_z ≥ n²/η this covers n rounds. | REFUTED (every extension of R4 to a stochastic human, with or without a square root) |
| Proposition 3.2 | The same when all calls of every rehearsal run are put to the human and no input is repeated in a run (K = 1, L = 3): with probability ≥ 1 − n/(2R) − n²/(2N_z), TV ≥ ¼(1 − n/N_z) in each of the first n rounds. A recorded run of the human system removes the bad hypotheses with probability ½. | NEW |
| Remark 3.3 | What remains true for a stochastic human: Theorem 2.1 with stochastic hypotheses and a deterministic human; Theorem A with recorded runs (quoted); the regret bound for the per-call mixture along the driver's runs, which does not bound the run law. | summary |
| Remark 3.4 | The lead's suggested mechanism (a hypothesis that marks its own runs by a tilt) is paid for at the linear rate; it is not what breaks R4. | NEW (computation, not a theorem) |
| Proposition 4.2 (**R5**, posterior draw) | Trap class A, K = 1 bit, exact formulas. After n = N ≥ 100 rounds and for L ≤ √n: a posterior draw per run has at least L/4 unfaithful calls with probability ≥ 0.11·L/n; the per-call mixture has more than m unfaithful calls with probability ≤ (L/n)^(m+1)/(m+1)!. | PROVED (the candidate's sketch, for the posterior draw) |
| Proposition 4.3 (**R5**, every rule that deploys a member of the class) | Trap class B (no consensus member, K = log₂(2n) bits), n ≥ 16, L ≤ n: every protocol with n questions that deploys a member of the class (chosen without looking at the run's top-level input) has, for some human of the class, at least L/4 unfaithful calls with probability ≥ L/(8n); the per-call mixture has more than m unfaithful calls with probability ≤ L/(2n²) + (3L/(2n))^(m+1)/(m+1)! for every human. | PROVED; the candidate's statement is MODIFIED ("every rule that deploys a single hypothesis" is true for members of the class and false for a deterministic vote of the committee, Remark 4.5) |
| Corollary 4.4 | Consequence under tolerance of θL faults (θ < ¼): a member of the class needs n ≥ L/(8δ) (class B) or 0.11·L/δ (posterior draw, class A) questions; the mixture needs K ln 2/(θδ) by R3. | PROVED |
| Proposition 5.1 (**R6**(a), upper bound) | Rehearsal driven by the first consistent hypothesis of an enumeration: Σ_t Pr[run unfaithful] ≤ L·(number of hypotheses before f) ≤ L·(2^K − 1) for an enumeration by non-increasing weight. | PROVED |
| Example 5.2 (**R6**(a)) | For every M ≤ L: a class of M + 1 functions (K = log₂(M+1)) in which the first-consistent driver has exactly L·M = L·(2^K − 1) unfaithful rounds in expectation, all at the beginning; the posterior draw has at most (2L²/(L+1))·ln(M+1). | PROVED (for 2^K ≤ L + 1) |
| Example 5.3 | For every M: in total between L·M·(1 − 2ε) and L·M unfaithful rounds, but only about L·log n/log(1/ε) of them among the first n rounds. | PROVED |
| Remark 5.4 | Whether L·2^K unfaithful rounds can occur within a number of rounds polynomial in L·2^K when 2^K > L + 1; an obstruction is described. | OPEN |
| Theorem 5.5 (**R6**(b)) | Mixture-driven rehearsal, deterministic human and hypotheses: with probability ≥ 1 − δ every consistent g has average error (1/n)Σ_t d_t(g) < L·(ln(1/w(g)) + ln(1/δ))/n on the rehearsal's visit distributions; with probability ≥ 1 − 2δ every consistent g has Pr[own run unfaithful] < L·(ln(1/w(g)) + K ln 2 + 2 ln(1/δ))/n, which is < 2L·(K ln 2 + ln(1/δ))/n for the highest-weight consistent hypothesis. | PROVED (the candidate's sketch, with constants) |
| Corollary 5.6 | The same bound 2L·(K ln 2 + ln(1/δ))/n, with probability ≥ 1 − 2δ, for one posterior draw taken at the end and kept for good. | NEW |
| Section 6 | What survives for a single program and what needs the committee. | summary of proved statements |
| Section 8 | Open questions; remarks on other files. | OPEN |

**In brief.** (1) R4 is correct. The constant improves to 2L²/(L+1), and this is the exact constant up to a factor (1 − 1/L)(1 − 1/K). The hypotheses may be stochastic; what the proof needs is a deterministic human. (2) For a stochastic human R4 has no extension at all: with K = 1 bit a posterior draw per run stays at a fixed total-variation distance from the human system for any prescribed number of rounds, because single answers at fresh inputs cannot refute hypotheses whose answers within one run are dependent, and a posterior draw per run reproduces that dependence. The per-call mixture is exact in the same example. One program per run for a stochastic human needs recorded runs of the human system (Theorem A). (3) R5 holds for the posterior draw with K = 1 and, in a minimax form, for every rule that deploys a member of the class; it is false for a deterministic vote of the committee. (4) R6(a): the bound L·(2^K − 1) for the simplest-consistent driver is attained exactly when 2^K ≤ L + 1; R6(b) holds with the constants above.

## 0. Conventions

* Logarithms are natural unless written log₂. K := log₂(1/w(P)), so ln(1/w(P)) = K ln 2. [n] := {1, …, n}.
* **Change of notation.** As in `research/prove/rehearsal-core.md`: T is the number of calls of a run, **U** is the uniformly random round of deployment (the outline writes T for both), and the answer alphabet seen by the scaffold is Y_⊥ := Y ∪ {⊥}.
* TV(p, q) := ½ Σ_y |p(y) − q(y)|. Two elementary inequalities: (E2) 1 − u ≤ −ln u for u ∈ (0, 1]; (E3) 1 − x ≤ e^(−x) for real x.

## 1. Setting

**Definition 1.1 (class, posterior, mixture).** X and Y are countable sets. A *hypothesis* ν assigns to every x ∈ X numbers ν(y|x) ≥ 0, y ∈ Y, with Σ_y ν(y|x) ≤ 1; it is identified with the probability kernel on Y_⊥ that gives ⊥ the missing mass. A *sampler* is a hypothesis with no missing mass; a function g: X → Y_⊥ is the hypothesis δ_{g(x)}. H is a countable set of hypotheses with weights w(ν) > 0 and W := Σ_ν w(ν) ≤ 1. The human is a sampler P ∈ H (assumptions A1 and A2); when P is a function it is written f. For a list D of pairs (x_i, y_i): ν(D) := Π_i ν(y_i|x_i), ξ(D) := Σ_ν w(ν)ν(D), the posterior is w_D(ν) := w(ν)ν(D)/ξ(D) when ξ(D) > 0, and the mixture is M_D(y|x) := Σ_ν w_D(ν)ν(y|x). For a class of functions, w_D is w restricted to the *version space* V_D := {g ∈ H : g(x_i) = y_i for all i} and normalised.

**Definition 1.2 (scaffold, runs).** A scaffold Π of horizon L ≥ 1 has top-level inputs z ~ D₀ on a countable set, internal randomness ρ ~ λ, and maps next_j(z, ρ, y_1, …, y_{j−1}) ∈ X ∪ {STOP}, j ∈ [L] (next_{L+1} := STOP). The run answered by an answerer A on (z, ρ) is the sequence (z, ρ, y_1, …, y_T): x_j := next_j(z, ρ, y_<j), the run ends at the first STOP, T ≤ L is its number of calls, and y_j is A's answer at call j. A hypothesis ν answers call j by an independent draw from ν(·|x_j). Q_A is the law of the run. For a function g the run on (z, ρ) is determined; it is written τ^g(z, ρ), with inputs x^g_j(z, ρ) and length T^g(z, ρ). The *human system* is Q_P; for a deterministic human its run on (z, ρ) is τ^f(z, ρ).

**Definition 1.3 (three drivers).** A *rehearsal with driver 𝔡* runs for rounds t = 1, 2, …. In round t, with D_{t−1} the pairs collected so far and w_t := w_{D_{t−1}}:
1. the driver produces an answerer A_t from D_{t−1} (and fresh randomness);
2. (z_t, ρ_t) ~ D₀ ⊗ λ is drawn and Π is run with A_t; this uses compute only;
3. J_t is drawn uniformly from [L], independently of everything else; if the run made at least J_t calls, the input x_t := x_{t,J_t} of call J_t is put to the human, the answer y_t ~ P(·|x_t) is drawn independently of the past given x_t (A1, A3), and (x_t, y_t) is appended.

The drivers are:
* **mixture** (Protocol R of the candidate theory): A_t answers every call by a fresh draw from M^(t) := M_{D_{t−1}}; equivalently, a new hypothesis is drawn from w_t at every call;
* **posterior draw** (variant R′ of the candidate theory, "one mind per run"): one ν_t ~ w_t is drawn and answers every call of the run;
* **first consistent** (for a class of functions with a fixed enumeration g_1, g_2, …): A_t is the first g_i in V_{D_{t−1}}. If the enumeration is by non-increasing weight this is the "current simplest consistent hypothesis" (the highest-weight member of the version space).

For a deterministic human a run on (z, ρ) is called *unfaithful* if it differs from τ^f(z, ρ), and a call is *unfaithful* if its answer differs from f at its input. These are the notions of the outline: for a deterministic human the shadow answer at input x is f(x).

**Lemma 1.4 (first deviation). PROVED.** Let f be a function, fix (z, ρ), and let (y_1, …, y_T) be the answers of any run on (z, ρ), with inputs x_1, …, x_T. Let σ := min{j ≤ T : y_j ≠ f(x_j)} (σ := ∞ if there is no such j). Then:
(a) for every j ≤ min(σ, T): j ≤ T^f and x_j = x^f_j;
(b) the run equals τ^f(z, ρ) if and only if σ = ∞; so a run is unfaithful if and only if it has an unfaithful call, and its first unfaithful call is made at an input of the human system's run;
(c) if the run is answered by a hypothesis ν, and e_ν(x) := 1 − ν(f(x)|x), then for j ≤ T^f: Pr[σ ≥ j] = Π_{i<j}(1 − e_ν(x^f_i)) and Pr[σ = j] = e_ν(x^f_j)·Π_{i<j}(1 − e_ν(x^f_i)); and Pr[σ = ∞] = Π_{i≤T^f}(1 − e_ν(x^f_i)).

*Proof.* (a) By induction on j. For j = 1, x_1 = next_1(z, ρ) = x^f_1 (if T ≥ 1 then next_1 ≠ STOP, so T^f ≥ 1). If j ≤ min(σ, T) and j ≥ 2, then y_i = f(x_i) = f(x^f_i) for i < j by the induction hypothesis and the definition of σ, so the history before call j is that of the f-run; hence next_j has the same value in both runs, it is not STOP because j ≤ T, so j ≤ T^f and x_j = x^f_j. (b) If σ = ∞, the same induction shows that both runs have the same histories and stop at the same call. If σ < ∞, call σ exists in both runs by (a), with the same input, and the answers differ. (c) By (a), as long as no wrong answer has been given the inputs are those of the f-run, and the answer at x^f_i is f(x^f_i) with probability 1 − e_ν(x^f_i), independently of the earlier answers. ∎

**Lemma 1.5 (potential). PROVED (standard; it is Lemma 4.2 of `research/prove/rehearsal-core.md`).** Let the human be a function f ∈ H, and let questions x_1, x_2, … be put to the human in any way, D_k the first k pairs. Put m_k := 1 − M_{D_{k−1}}(f(x_k)|x_k), the posterior mass that the k-th answer removes (for a class of functions: m_k = w_{D_{k−1}}{g : g(x_k) ≠ f(x_k)}). Then on every path, for every n,

  Π_{k≤n} (1 − m_k) = ξ(D_n)/W ≥ w(f)/W, hence Σ_{k≤n} m_k ≤ Σ_{k≤n} −ln(1 − m_k) ≤ ln(W/w(f)) ≤ K ln 2.

*Proof.* f(D_n) = 1 for every list of answers of f, so ξ(D_n) ≥ w(f) > 0 and the posterior is defined. M_{D_{k−1}}(f(x_k)|x_k) = ξ(D_k)/ξ(D_{k−1}), the product telescopes, ξ(∅) = W; then (E2). ∎

## 2. R4: one posterior draw per run, deterministic human

Throughout this section the human is a function f ∈ H; the other members of H may be samplers or semimeasures. The rehearsal has the posterior-draw driver. For a round t and a pair (z, ρ) let

  u_t(z, ρ) := Pr[ the run of ν_t on (z, ρ) is unfaithful | D_{t−1} ],

the probability being over ν_t ~ w_t and over the answers of ν_t. The probability that the run of round t is unfaithful, given D_{t−1}, is ū_t := E[u_t(z_t, ρ_t) | D_{t−1}]. Put

  ψ_L(u) := u − u²·(L − 1)/(2L) for u ∈ [0, 1].

ψ_L is increasing and concave on [0, 1], ψ_1(u) = u, and u·(L + 1)/(2L) ≤ ψ_L(u) ≤ u.

**Theorem 2.1 (R4). PROVED; the constant and the generality are MODIFIED.** Assume A1 to A3 and a deterministic human f ∈ H. For the rehearsal with the posterior-draw driver,

  Σ_{t≥1} E[ ψ_L(u_t(z_t, ρ_t)) ] ≤ L·ln(W/w(f)) ≤ L·K ln 2.  (2.1)

Consequently

  Σ_{t≥1} Pr[ the run of round t differs from the human system's run on (z_t, ρ_t) ] = Σ_t E[ū_t] ≤ (2L²/(L + 1))·K ln 2 < 2L·K ln 2.  (2.2)

*Proof.* Fix t, condition on D_{t−1}, and fix (z, ρ); write x^f_j, T^f for the human system's run on (z, ρ). For ν ∈ H let σ_ν be the index of the first unfaithful call of the run of ν on (z, ρ) (Lemma 1.4), and put, for j ∈ [T^f],

  p_j := Σ_ν w_t(ν)·Pr[σ_ν = j],  so that u := u_t(z, ρ) = Σ_{j≤T^f} p_j

by Lemma 1.4(b). Let ē(x) := 1 − M^(t)(f(x)|x) = Σ_ν w_t(ν)e_ν(x).

*Step 1: ē(x^f_j) ≥ p_j.* By Lemma 1.4(c), Pr[σ_ν = j] ≤ e_ν(x^f_j); average over ν ~ w_t.

*Step 2: the removed mass.* Let m_t be the posterior mass removed in round t (m_t := 0 if no question is asked); m_t = ē(x_t) if a question is asked. Let ν_t be the driver and σ := σ_{ν_t}. If J_t ≤ min(σ, T^f), then by Lemma 1.4(a) and (b) the run has at least J_t calls (if σ = ∞ the run is the f-run; if σ < ∞ the run has at least σ calls) and its J_t-th input is x^f_{J_t}; so a question is asked and m_t = ē(x^f_{J_t}) ≥ p_{J_t}. Since m_t ≥ 0 always, and J_t is uniform on [L] and independent of the run,

  E[m_t | D_{t−1}, z, ρ] ≥ (1/L)·Σ_{j≤T^f} Pr[σ ≥ j]·p_j, where Pr[σ ≥ j] = 1 − Σ_{i<j} p_i

(the probability is over ν_t ~ w_t and its answers; σ ≥ j means that the first unfaithful call is not among the calls before j).

*Step 3: algebra.* Σ_j p_j·(1 − Σ_{i<j} p_i) = u − Σ_{i<j} p_i p_j = u − ½(u² − Σ_j p_j²) ≥ u − ½u² + u²/(2L) = ψ_L(u), because Σ_j p_j² ≥ (Σ_j p_j)²/T^f ≥ u²/L by the Cauchy–Schwarz inequality. So E[m_t | D_{t−1}, z, ρ] ≥ ψ_L(u_t(z, ρ))/L.

*Step 4: summation.* (z_t, ρ_t) is independent of D_{t−1}, so E[m_t] ≥ E[ψ_L(u_t(z_t, ρ_t))]/L. By Lemma 1.5, Σ_t m_t ≤ ln(W/w(f)) on every path. This gives (2.1). For (2.2) use ψ_L(u) ≥ u·(L + 1)/(2L). ∎

*What is used.* The human's answers remove hypotheses for certain: a wrong answer at the asked input costs a hypothesis the factor ν(f(x)|x). The freshness of J_t and of (z_t, ρ_t) (A3). Nothing about the class, the prior or the scaffold. *What it does not say.* Nothing about the number of unfaithful calls within an unfaithful run (Section 4), and nothing for a stochastic human (Section 3).

**Corollary 2.2 (deployment). PROVED.** After n rounds draw U uniformly from [n] and ν ~ w_U.
(a) *A fresh draw for each run.* A deployed run differs from the human system's run on the same (z, ρ) with probability at most 2L²·K ln 2/((L + 1)·n).
(b) *One draw kept for good.* With u(ν) := Pr_{z,ρ}[the run of ν is unfaithful]: E[u(ν)] ≤ 2L²·K ln 2/((L + 1)·n), so for every δ ∈ (0, 1), with probability at least 1 − δ over the rehearsal, U and the draw, u(ν) ≤ 2L²·K ln 2/((L + 1)·n·δ).

*Proof.* E[u(ν)] = (1/n)Σ_{t≤n} E[ū_t]; then (2.2), and Markov's inequality for (b). ∎

**Remark 2.3 (the candidate's proof, line by line).** The candidate takes two independent draws g, g′ ~ w_t and the event {j*(g′) ≤ j*(g), j*(g′) < ∞, J = j*(g′)}, where j*(h) is the first index of the f-run at which h differs from f. Each step is correct: on this event the run of g has at least J calls and its J-th input is x^f_J (Lemma 1.4(a), needed for runs of variable length: the question is asked only if the run of g has a J-th call), g′ is wrong there, and by exchangeability Pr[j*(g′) ≤ j*(g), j*(g′) < ∞] ≥ ½·Pr[min(j*(g), j*(g′)) < ∞] ≥ u/2. The step "the total of −ln(1 − removed mass) is at most ln(1/w(f))" is Lemma 1.5, applied to the realised removed mass, with Jensen's inequality or (E2) to pass to its expectation. Step 3 above replaces the symmetry bound u/2 by the exact value of the same lower bound; the gain is the term u²/(2L) and the factor 1 instead of 2 when u is small.

**Example 2.4 (the scaffold used in Proposition 2.5 and Example 5.2).** Let N_z ≥ 1 and L ≥ 1. Inputs: X := ([N_z] × [L]) ∪ {⋆}; answers {0, 1}. The scaffold Π^path_{N_z,L} draws z uniformly from [N_z] and has no internal randomness; next_j(z, y_<j) := (z, j) if y_i = 0 for all i < j, and := ⋆ otherwise. Every run has exactly L calls. The human is f ≡ 0, so the human system asks (z, 1), …, (z, L). A hypothesis that answers 1 at (z, j) and 0 at ⋆ sends the run to ⋆ for all later calls.

**Proposition 2.5 (the constant of Theorem 2.1 is sharp, and the order L·K is attained). NEW.** Let L ≥ 2, let K > 0 with ε := 2^(−K), and η > 0. There are N_z and n such that for the scaffold Π^path_{N_z,L}, the human f ≡ 0 with weight w(f) = ε, and the class H := {f} ∪ {g_a : a ∈ [L]^[N_z]}, where g_a(z, j) := 1[a(z) = j] and g_a(⋆) := 0, with weights w(g_a) := (1 − ε)/L^(N_z), the rehearsal with the posterior-draw driver has

  Σ_{t≤n} Pr[the run of round t is unfaithful] ≥ S(L, K) − η,  S(L, K) := Σ_{k≥0} u_k/(1 − u_k(L − 1)/(2L)),  u_k := R_k/(1 + R_k),  R_k := (2^K − 1)(1 − 1/L)^k,

and S(L, K) ≥ (2L/(L + 1))·ln(1 + (L + 1)(2^K − 1)/(2L))/ln(L/(L − 1)) ≥ (2L(L − 1)/(L + 1))·(K − 1) ln 2.

So the bound (2.2) cannot be improved by more than the factor (1 − 1/L)(1 − 1/K).

*Proof.* Every g_a deviates on every z, at position a(z): its run is unfaithful for every z. So given the data, u_t(z) is the posterior mass of H ∖ {f}, whatever z is.

*The posterior.* The prior on a is uniform, hence a product over z of uniform laws on [L]. A question at ⋆ removes nothing. A question at (z, j) is answered 0 and removes exactly the g_a with a(z) = j. So the posterior on a is again a product: a(z) is uniform on the set of positions j such that (z, j) has not been asked. If z is *fresh* (no (z, ·) asked before), a question at (z, j) removes the fraction 1/L of the mass of H ∖ {f}.

*One round at a fresh z.* Let R be the ratio of the posterior mass of H ∖ {f} to that of f, so u = R/(1 + R). With probability 1 − u the driver is f; the question is (z, J) and R is multiplied by 1 − 1/L. With probability u the driver is some g_a, and a(z) is uniform on [L]; if J ≤ a(z) the question is (z, J) and R is multiplied by 1 − 1/L; if J > a(z) the question is ⋆ and R does not change. Pr[J ≤ a(z)] = (L + 1)/(2L). So, as long as the top-level inputs are fresh, R moves from R_k to R_{k+1} with probability s_k := 1 − u_k(L − 1)/(2L) and stays otherwise, and each round spent at level k is unfaithful with probability u_k. The expected number of rounds at level k is 1/s_k, so the expected number of unfaithful rounds at level k is u_k/s_k, and the total over all levels is S(L, K), a convergent series (u_k ≤ R_k decays geometrically).

*Finitely many top-level inputs.* Choose n with Σ_{t≤n} E[u^∞_t] ≥ S(L, K) − η/2 for the chain just described (monotone convergence), then N_z ≥ n³/η. With probability at least 1 − n²/(2N_z) the first n top-level inputs are distinct, and on that event the rehearsal coincides with the chain (driven by the same coins); so Σ_{t≤n} E[u_t] ≥ Σ_{t≤n} E[u^∞_t] − n·n²/(2N_z) ≥ S(L, K) − η.

*The lower bound for S.* With c := (L + 1)/(2L) and φ(R) := u/(1 − u(L − 1)/(2L)) = R/(1 + cR), which is increasing in R: the terms φ(R_k) decrease in k, so S ≥ ∫_0^∞ φ(R_0 e^(−λx)) dx with λ := ln(L/(L − 1)) and R_0 := 2^K − 1. Substituting R = R_0 e^(−λx): the integral is (1/λ)∫_0^{R_0} dR/(1 + cR) = ln(1 + cR_0)/(cλ). Finally c ≥ ½ gives 1 + cR_0 ≥ (2^K + 1)/2 ≥ 2^(K−1), and λ ≤ 1/(L − 1). ∎

The script `one-mind_r4.py` evaluates S(L, K) (for L = 100 and K = 100 bits it is 1.951·L·K ln 2, between the two bounds 13452 and 13726), checks (2.1) and (2.2) by simulation on eight random classes and scaffolds with runs of variable length, and simulates this example directly (Section 7.1).

**Remark 2.6 (comparison with the mixture on the same example).** With the mixture driver the round at a fresh z asks on the main path with probability (1/L)Σ_J (1 − u/L)^(J−1), which is about 1 − 1/e = 0.63 when u is near 1, against (L + 1)/(2L), about ½, for the posterior draw. So the posterior draw learns more slowly here by a factor of about 1.26, and its count of unfaithful runs is about twice the mixture's count of unfaithful calls. This is the whole difference for a deterministic human as long as the object of interest is the probability of a fully faithful run.

## 3. A stochastic human: R4 has no extension

**3.0 What an unfaithful run is when the human is stochastic.** Under the posterior-draw driver the run of round t has, given D_{t−1}, the law

  Q̄_t := Σ_ν w_t(ν)·Q_ν.

In every coupling of this run with a run of the human system the two differ with probability at least TV(Q̄_t, Q_P), with equality for the best coupling. So TV(Q̄_t, Q_P) is the least possible probability of an unfaithful run. For a deterministic human it equals ū_t of Section 2 (both laws have the same marginal on (z, ρ), and given (z, ρ) the human system's run is the single point τ^f(z, ρ)). The larger quantity Σ_ν w_t(ν)·TV(Q_ν, Q_P) is not the right one: it is close to 1 whenever the drawn hypotheses are functions and the human is not, even if Q̄_t = Q_P. The examples below refute a bound for the smaller quantity, hence for both.

**Example 3.1 (one question asked three times). REFUTED: R4 for a stochastic human.** Let ε ∈ (0, ½] and N_z ≥ 1. X := [N_z], Y := {0, 1}. The human answers every input z with 1 ("right") with probability 1 − ε and with 0 with probability ε, independently each time it is asked: P(1|z) = 1 − ε. The class is H := {P} ∪ F, where F is the set of all functions s: [N_z] → {0, 1}, with weights w(P) := ½ and w(s) := ½·Π_z P(s(z)|z). The weights add up to 1 and K = 1 bit. The scaffold draws z uniformly from [N_z] and makes three calls, each with the input z (its outcome may be the majority of the three answers). So L = 3.

Consider a rehearsal with any driver and one question per round; the question of round t is z_t whichever call is chosen. Let 𝒟_t be the event that z_1, …, z_{t−1} are distinct; Pr[𝒟_t] ≥ 1 − (t − 1)²/(2N_z). Call z *fresh* in round t if it is none of z_1, …, z_{t−1}. On 𝒟_t:

(a) w_t(P) = ½, and under the posterior the members of F have s(z_i) = y_i at the asked inputs and independent values with law P(·|z) at the fresh inputs.

(b) *Posterior draw per run.* For fresh z, TV(Q̄_t(·|z), Q_P(·|z)) = (3/2)·ε(1 − ε). Hence TV(Q̄_t, Q_P) ≥ (3/2)·ε(1 − ε)·(1 − (t − 1)/N_z). The majority of the three answers is 0 with probability ½·ε + ½·(3ε² − 2ε³) at a fresh z, against 3ε² − 2ε³ in the human system.

(c) *Per-call mixture.* For fresh z, Q_{M^(t)}(·|z) = Q_P(·|z). Hence TV(Q_{M^(t)}, Q_P) ≤ (t − 1)/N_z.

Consequently, for every n and η ∈ (0, 1), with N_z ≥ n²/η: Σ_{t≤n} E[TV(Q̄_t, Q_P)] ≥ (1 − 2η)·n·(3/2)·ε(1 − ε), which is 0.375·(1 − 2η)·n for ε = ½, with K = 1 and L = 3. No bound of the form C·L·K, C·√(n·L·K), or b(L, K, n) with b/n → 0 holds for the posterior-draw driver and a stochastic human, while the mixture driver has total variation at most η/n in every one of these rounds.

*Proof.* (a) For distinct asked inputs the likelihood of the data under the prior on F is Σ_s w(s)·Π_i 1[s(z_i) = y_i] = ½·Π_i P(y_i|z_i), because the prior on F is a product over z; this is w(P) times the likelihood under P. So the posterior odds are 1. The second statement is the product form again. (b) At a fresh z the driver is P with probability ½, and then the three answers are independent draws from P(·|z); with probability ½ it is a function s, and the answers are (c, c, c) with c = s(z) of law P(·|z). The law of three independent draws gives the six non-constant triples the mass 1 − (1 − ε)³ − ε³ = 3ε(1 − ε), the law of (c, c, c) gives them 0 and is larger on the two constant triples; so their total variation distance is 3ε(1 − ε), and that of the half-and-half mixture from Q_P(·|z) is half of it. The two run laws have the same marginal on z, so TV(Q̄_t, Q_P) is the mean over z of the conditional distances. The majority is 0 under (c, c, c) with probability ε. (c) At a fresh z a fresh posterior draw answers 1 with probability ½(1 − ε) + ½(1 − ε), and the draws at the three calls are independent. ∎

*Reading.* F consists of the human "with the coins filled in" by a function of the input. Single answers at fresh inputs cannot tell F from P: every single-call likelihood is the same. The difference shows only in the joint law of several answers of one run: the human's three answers are independent, a function's are equal. A posterior draw per run reproduces the dependence. A fresh draw at every call destroys it, which is correct because the human is stateless (A1). In scaffold terms: asking three times and taking the majority lowers the human system's error from ε to about 3ε²; with one mind per run the error stays at ε on the runs driven by a function. If two calls of each run were put to the human, F would be refuted in this example (two different answers to one input). The next proposition shows that this repair is not general. In a class of programs the role of F is played by the human's program with its coins replaced by a keyed function of the input (the "sampler with some bits specified" of the researcher's notes, item F15 in `research/understand/notes.md`); I have not computed the posterior weight of that family in the universal class.

**Proposition 3.2 (all calls of the run put to the human; no repeated input). NEW.** Let R ≥ 2 and N_z ≥ 1. Inputs: X := [N_z] ∪ ([N_z] × [R] × {2, 3}). The human: P(·|z) is uniform on [R]; P(·|(z, r, j)) is uniform on {0, 1}. F is the set of all functions s on X with s(z) ∈ [R], s(z, r, j) ∈ {0, 1}, and

  s(z, s(z), 2) = s(z, s(z), 3) for every z.

H := {P} ∪ F with w(P) := ½ and w(s) := 1/(2|F|); K = 1 bit. The scaffold draws z uniformly, and asks x_1 := z, x_2 := (z, y_1, 2), x_3 := (z, y_1, 3); L = 3, and no input occurs twice in a run. For data whose top-level inputs are distinct, let ϱ be the posterior odds of F against P. Then:

(a) *One call of a run put to the human* (any driver): ϱ does not change.

(b) *All three calls of the driver's run put to the human.* Let r_d be the driver's first answer and r′, b, b′ the human's answers to x_1 = z, x_2 = (z, r_d, 2), x_3 = (z, r_d, 3). If r′ ≠ r_d, ϱ does not change. If r′ = r_d, ϱ is multiplied by 2 when b = b′ and by 0 when b ≠ b′.

(c) *A recorded run of the human system* (the human's own first answer r′ is fed forward, and the human then answers (z, r′, 2) and (z, r′, 3)): ϱ is multiplied by 2 when b = b′ and by 0 when b ≠ b′. So F survives N recorded runs with probability 2^(−N).

(d) At a fresh z, the run law of a uniformly drawn member of F is at total variation ½ from Q_P(·|z), and the per-call mixture has Q_{M^(t)}(·|z) = Q_P(·|z).

Consequently, for the posterior-draw driver with all calls of every rehearsal run put to the human (3n answers in n rounds): with probability at least 1 − n/(2R) − n²/(2N_z), every round t ≤ n has TV(Q̄_t, Q_P) ≥ ¼·(1 − n/N_z); in the same rounds the per-call mixture of the same posterior has TV(Q_{M^(t)}, Q_P) ≤ n/N_z.

*Proof.* F is a product over z of sets F_z; a member of F_z is given by r* := s(z) ∈ [R], a common bit for the two inputs (z, r*, 2), (z, r*, 3), and two free bits for each r ≠ r*; |F_z| = R·2·4^(R−1). The uniform law on F_z is invariant under relabelling of [R] and under flipping all bits. So under it s(z) is uniform on [R] and each single bit s(z, r, j) is uniform: (a). For (b), the members of F_z consistent with the three answers have r* = r′ (a fraction 1/R). If r_d ≠ r′ the bits at (z, r_d, ·) are free and must equal (b, b′): a further fraction ¼; the total 1/(4R) equals the likelihood under P. If r_d = r′ the common bit must equal both b and b′: the fraction is 0 if b ≠ b′ and ½ if b = b′, total 1/(2R), twice the likelihood under P. (c) is the case r_d = r′ of (b). (d) A uniform member of F_z produces the run (r, c, c) with r and c uniform, the human system (r, b, b′) with independent uniform entries; the distance is ½. For the mixture the three calls are answered by independent draws, and each single answer is uniform by (a). For the consequence: by (b), ϱ stays at least 1 unless some round has r′ = r_d and b ≠ b′, which has probability 1/(2R) per round because the human's answers are independent of r_d; the top-level inputs of n rounds are distinct with probability at least 1 − n²/(2N_z); and on these events the posterior on F at a fresh z is uniform on F_z, so TV(Q̄_t(·|z), Q_P(·|z)) = w_t(F)/2 ≥ ¼. ∎

*Reading.* The human's answers at calls 2 and 3 are answers at the driver's inputs, which lie on the human's own path only if the human's first answer happens to equal the driver's. The dependence between a hypothesis's first answer and its later answers is tested only by a run that the human carries out itself. This is why Theorem A needs recorded runs of the human system, and why rehearsal, which never needs one, deploys the per-call mixture.

**Remark 3.3 (what remains true for a stochastic human).** (i) Theorem 2.1 allows stochastic hypotheses; only the human must be deterministic. (ii) With N recorded runs of the human system, one posterior draw per run is sound: Theorem 4.2 of `research/prove-b/hellinger-runs.md` (Theorem A) states E KL(Q_P ‖ Q̂) ≤ K ln 2/N and E TV(Q̂, Q_P) ≤ √(K ln 2/(2N)) for the draw from the posterior of a uniformly random time (quoted from that file; not re-proved here). Since the human is stateless, a recorded run is L single questions put in sequence with the human's own answers fed forward, so this costs N·L answers; what it adds to rehearsal is that the questions lie on the human's own path. (iii) For the posterior-draw driver the regret bound still holds for the *per-call mixture* at the inputs of the driver's runs: Σ_t E[E_{Q̄_t} Σ_j KL(P ‖ M^(t))(x_j)] ≤ L·K ln 2 (Lemma L3 of the candidate theory applied to the asked inputs). It bounds neither TV(Q̄_t, Q_P) (in Example 3.1 all its terms vanish at fresh inputs) nor TV(Q_{M^(t)}, Q_P) (the mixture's own runs visit other inputs).

**Remark 3.4 (the mechanism suggested by the lead; a computation, not a theorem).** Consider a hypothesis ν that marks its own runs by a tilt at the first call, ν(S|x_1) = η > p₀ = P(S|x_1) for a set S of answers, and deviates only after an answer in S. It adds at most η·w_t(ν) to TV(Q̄_t, Q_P). Every question at x_1 multiplies its odds against P by a factor whose logarithm has mean −KL(P(·|x_1) ‖ ν(·|x_1)) ≤ −[p₀ ln(p₀/η) + (1 − p₀) ln((1 − p₀)/(1 − η))], about −η when p₀ is much smaller than η; and x_1 is asked with probability 1/L in every round, whoever drives. So ν loses about η/L nats per round and its total contribution to Σ_t TV is of order L times the nats it can lose, the order of (2.2). A tilt with small divergence (η close to p₀) does not make the marked runs its own: the other drivers visit them as often. So marking by a tilt is paid for at the linear rate. What breaks R4 is the dependence between the answers of one hypothesis at different calls, which costs nothing in any single-call likelihood.

## 4. R5: when stakes are low, a committee per call beats one member per run

**Definition 4.1 (trap scaffold, trap functions).** Let N ≥ 2 and L ≥ 1. Inputs X := [N] × ({0} ∪ [N]), answers {0, 1}. The scaffold Π^trap_{N,L} draws z = (a_1, …, a_L) uniformly from [N]^L and keeps a *flag* s_j ∈ {0} ∪ [N]: s_1 := 0; the input of call j is x_j := (a_j, s_j); s_{j+1} := a_j if s_j = 0 and y_j = 1, and s_{j+1} := s_j otherwise. Every run has L calls. The flag records the first input at which the answer 1 was given. Functions: g_0 :≡ 0, and for a ∈ [N],

  g_a(b, s) := 1 if (s = 0 and b = a) or s = a, and := 0 otherwise.

g_a answers 1 at its *trigger* (a, 0) and on its *region* [N] × {a}. **Class A:** H_A := {g_0, g_1, …, g_N} with w(g_0) := ½ and w(g_a) := 1/(2N); the human is g_0, K = 1 bit. **Class B:** H_B := {g_1, …, g_N} with weights 1/N; the human is some g_{a*}, K = log₂ N.

*What a question does.* Let c ∈ {0} ∪ [N] be the human's index. A question at (b, 0) with b ≠ c, or at (b, a) with a ≠ c, is answered 0 and removes exactly one member: g_b, respectively g_a. A question at the human's trigger or in the human's region (c ≠ 0) is answered 1 and removes every member but g_c.

**Proposition 4.2 (class A: posterior draw against mixture, K = 1). PROVED.** In class A with human g_0, let U be the set of traps that the data have not removed, k := |U|. The posterior gives g_0 the mass N/(N + k) and each trap in U the mass 1/(N + k). Let C be the number of unfaithful calls of a run.

(a) *One posterior draw for the run.* Pr[C = L − i + 1] = (k/(N + k))·(1 − 1/N)^(i−1)/N for i ∈ [L], and C = 0 otherwise. So for c ∈ [L]

  Pr[C ≥ c] = (k/(N + k))·(1 − (1 − 1/N)^(L−c+1)).

(b) *The mixture.* For every m ≥ 0, Pr[C ≥ m + 1] ≤ (L choose m+1)·N^(−(m+1)) ≤ (L/N)^(m+1)/(m + 1)!. Exactly: C = 0 if no call sets the flag; otherwise C = 1 + B, where the first flag-setting call τ is geometric with parameter k/(N(N + k)) and B is binomial with parameters L − τ and 1/(N + k).

(c) *After n rounds of rehearsal with either driver,* E[k] ≥ N·(1 − 1/N − L/N²)^n. In particular for n = N ≥ 100 and L ≤ √N, a posterior draw per run has

  Pr[C ≥ L/4] ≥ 0.11·L/n,

while the mixture has Pr[C ≥ 2] ≤ (L/n)²/2 and Pr[C ≥ L/4] ≤ (L/n)^⌈L/4⌉/⌈L/4⌉!.

*Proof.* (a) The run of g_0 is faithful. The run of g_a answers 0 until a first occurs in z, at position i say, and 1 at that call and at every later call, since the flag is then a; the human answers 0 everywhere. So C = L − i + 1 if a first occurs at position i, an event of probability (1 − 1/N)^(i−1)/N, and the driver is a trap with probability k/(N + k). (b) At a call with flag 0 and input (b, 0) the fresh draw answers 1 if and only if it is g_b, which has probability at most 1/(N + k); at a call with flag a it answers 1 if and only if it is g_a. So every call is unfaithful with conditional probability at most 1/N given the earlier calls. For a fixed set of m + 1 calls the probability that all are unfaithful is at most N^(−(m+1)); sum over the sets. The exact law: a call with flag 0 sets the flag with probability (k/N)·(1/(N + k)) (the input must be the trigger of a surviving trap and the draw that trap), and after the flag is set to a each call is unfaithful with probability 1/(N + k). (c) A trap a ∈ U is removed in a round only if the asked input is (a, 0) or lies in the region of a. The first has probability at most 1/N (the J-th top-level symbol is a). The second needs the flag a at the asked call: for the posterior-draw driver the driver must be g_a and a must occur in z, probability at most (1/(N + k))·(L/N); for the mixture some call must have the input (a, 0) and the draw g_a, probability at most L·(1/N)·(1/(N + k)). So each trap survives a round with conditional probability at least 1 − 1/N − L/N², and E[k] is the sum of the survival probabilities. For the numbers: k/(N + k) ≥ k/(2N), so E[k/(N + k)] ≥ ½(1 − 1.1/N)^N ≥ ½·0.989^100 ≥ 0.165 (the function N ↦ (1 − 1.1/N)^N increases); with c := ⌈L/4⌉ we have L − c + 1 ≥ 3L/4 and 1 − (1 − 1/N)^(L−c+1) ≥ (3L/(4N))·(1 − L/(2N)) ≥ 0.95·(3L/(4N)) by the Bonferroni inequality; the product is at least 0.117·L/N. The bounds for the mixture are (b). ∎

In class A the simplest consistent hypothesis is g_0 itself, so the failure of (a) belongs to the random draw. That every way of choosing a member fails for some human is the next statement.

**Proposition 4.3 (class B: every rule that deploys a member of the class). PROVED; the candidate's statement is MODIFIED (see Remark 4.5).** Let n ≥ 16, N := 2n and L ≤ n; class B on Π^trap_{N,L}.

(a) Let a protocol put at most n questions of its choice to the human (adaptively, with its own randomness) and then answer every call of a run by one member of H_B. The member is chosen in any way from the data and the protocol's randomness, possibly afresh for each run, but without looking at the top-level input of the run. Then for some human g_{a*} ∈ H_B, a deployed run has at least L/4 unfaithful calls with probability at least L/(8n).

(b) For the rehearsal with the mixture driver, for every human g_{a*}, every round t ≤ n + 1 and every m ≥ 0, the run of M^(t) has more than m unfaithful calls with probability at most L/(2n²) + (3L/(2n))^(m+1)/(m + 1)!.

*Proof.* (a) Let a* be uniform on [N], independent of the protocol's randomness ω. Each question tests one index: (b, 0) tests b and (b, a) tests a; the answer is 1 if and only if the tested index is a*. Let A(ω) be the set of at most n indices tested when all answers are 0, and â(ω) the index of the member deployed in that case. If a* ∉ A(ω), all answers are 0 and the protocol deploys g_â(ω). For every ω, Pr[a* ∉ A(ω) and a* ≠ â(ω)] ≥ 1 − (n + 1)/N. On this event the deployed member g_â is not the human: on a run in which â first occurs at position j it answers 0 before call j (so the flag stays 0), answers 1 at (â, 0), where the human answers 0, and answers 1 at each later input (·, â), where the human answers 0 because â ≠ a*. So the run has at least L − j + 1 unfaithful calls, and at least ⌈L/4⌉ of them if j ≤ m₀ := L − ⌈L/4⌉ + 1, where m₀ ≥ 3L/4. The top-level input of the run is independent of (ω, a*), and therefore of â, because the member is chosen without looking at it; so the probability is at least (1 − (n + 1)/N)·(1 − (1 − 1/N)^m₀) ≥ ((n − 1)/(2n))·(3L/(8n))·(1 − L/(4n)) ≥ (15/32)·(9/32)·L/n ≥ L/(8n). The bound holds on average over a*, hence for some a*.

(b) If some question so far was answered 1, the posterior is the point mass at the human and the run is faithful. Otherwise the posterior is uniform on a set S of at least N − (t − 1) ≥ n members, and a* ∈ S. Let Dm be the event that some call with flag 0 has the input (a*, 0) and the draw g_{a*}; Pr[Dm] ≤ L·(1/N)·(1/n) = L/(2n²). Outside Dm the flag is never a*, and a call is unfaithful only if its input is (a*, 0) (probability 1/N) or its draw is the one member that answers 1 there (g_b at (b, 0), g_s at flag s; probability at most 1/n). So outside Dm each call is unfaithful with conditional probability at most 3/(2n), and the claim follows as in Proposition 4.2(b). ∎

The condition in (a) that the member is chosen before the top-level input is seen is needed: a rule that sees z can deploy a member whose trigger does not occur in z, and on that run this member answers 0 everywhere, like the vote of Remark 4.5. Such a rule is a way of computing the committee's vote, not a single program.

On the event Dm the mixture has answered the human's trigger correctly and then stands in the human's own region, where the posterior still gives the human's answer little weight: the human of class B is a trap from the committee's point of view. This costs the term L/(2n²), a factor n/4 below the bound of (a).

**Corollary 4.4 (the consequence for a scaffold that tolerates faults). PROVED.** (a) *Class A.* Let G be the set of runs with fewer than L/4 answers equal to 1. The human system g_0 tolerates m := ⌈L/4⌉ − 1 faults with failure 0: after any replacements the human answers 0 at every input, so the number of answers 1 is at most the number of replacements. With N = n ≥ 100 and L ≤ √n, the run of a posterior draw is outside G with probability at least 0.11·L/n (its unfaithful calls are its answers 1), so failure at most δ needs n ≥ 0.11·L/δ; the run of the mixture is outside G with probability at most (L/n)^⌈L/4⌉/⌈L/4⌉! ≤ (4e/n)^(L/4). Theorem R3 gives the mixture, for every class and scaffold, failure at most K ln 2/(θn) under tolerance of θL faults, that is n = K ln 2/(θδ) questions whatever L.
(b) *Class B.* Theorem R3 turns tolerance of m faults into a guarantee through the probability of more than m unfaithful calls. For m < L/4 this probability is at least L/(8n) for every rule that deploys a member of the class (for the worst human), so such a rule needs n ≥ L/(8δ) questions, as if no fault were tolerated; for the mixture and m ≥ 2 it is at most L/(2n²) + 0.57·(L/n)³.

**Remark 4.5 (a member of the class, or the committee; not: deterministic or random).** The candidate's R5 says "every rule that deploys a single hypothesis per run". This is false if a hypothesis may be any function: in class B the function g_0 ≡ 0, which is not a member, has an unfaithful call only where a* occurs in z, so it has more than m unfaithful calls with probability at most (L/N)^(m+1)/(m + 1)! for every human; and g_0 is the plurality answer of the posterior at every input it visits as long as at least three members survive. So the separation is between one member of the class and the committee, and the committee may be used through its vote, which is the deployed object of Protocol AB (`research/prove/lower-bounds.md`, Theorem 3.3). This agrees with remark 7 in Section 10 of that file: for the probability of a fully faithful run a single deterministic function is as good as the mixture; the comparison of R5 concerns the number of unfaithful calls, and members of the class.

## 5. R6: which single hypothesis, and when it is chosen

In this section H is a class of functions and the human is a function f ∈ H. For g ∈ H put

  u(g) := Pr_{(z,ρ)}[ τ^g(z, ρ) ≠ τ^f(z, ρ) ],

the probability that a run answered by g alone is unfaithful.

### 5.1 The simplest consistent hypothesis as driver

**Proposition 5.1 (R6(a), upper bound). PROVED.** Let g_1, g_2, … be an enumeration of H and f = g_i₀. For the rehearsal with the first-consistent driver,

  Σ_{t≥1} Pr[the run of round t is unfaithful] ≤ L·(i₀ − 1).

If the enumeration is by non-increasing weight, i₀ − 1 ≤ W/w(f) − 1 ≤ 2^K − 1.

*Proof.* f is never removed, so the driver always has an index at most i₀, and a removed function never drives again. Fix i < i₀ and consider the rounds in which g_i drives and its run is unfaithful. In such a round the first deviation index j* of g_i on (z_t, ρ_t) is finite, and J_t = j* with probability 1/L, independently of the past and of (z_t, ρ_t); in that case the question is x^f_{j*} (Lemma 1.4), g_i is wrong there and is removed. So the number of such rounds exceeds k with probability at most (1 − 1/L)^k, and its expectation is at most L. Sum over i < i₀. For the count: (i₀ − 1)·w(f) ≤ Σ_{i<i₀} w(g_i) ≤ W − w(f). ∎

**Example 5.2 (R6(a): the bound is attained when 2^K ≤ L + 1). PROVED.** Let 1 ≤ M ≤ L. Take the scaffold Π^path_{1,L} of Example 2.4 (one top-level input; write j for the input (1, j)), f ≡ 0, and g_i(j) := 1[j = i], g_i(⋆) := 0 for i ∈ [M]. H := {g_1, …, g_M, f} in this order, with weights 1/(M + 1), so K = log₂(M + 1). (With weights proportional to 1 + ι·(M − i), ι > 0 small, the order is strictly by weight and K changes by less than log₂(1 + ιM).) Then, with the first-consistent driver:

(a) the number of unfaithful rounds is G_1 + … + G_M with independent G_i, each geometric with parameter 1/L (the number of trials up to the first success); its expectation is exactly L·M = L·(2^K − 1);

(b) the unfaithful rounds are exactly the rounds 1, …, G_1 + … + G_M; so for M ≥ 40 and every n ≤ L·M/2, the driver of round n produces an unfaithful run with probability at least 0.9.

With the posterior-draw driver the expected number of unfaithful rounds is at most (2L²/(L + 1))·ln(M + 1) (Theorem 2.1), and with the mixture driver at most L·ln(M + 1) (Theorem R1; in this scaffold a run has at most one unfaithful call).

*Proof.* While g_d drives, the functions g_i with i < d have been removed. The run of g_d answers 0 at the inputs 1, …, d − 1, answers 1 at d and then stands at ⋆. If J < d the question is the input J; every surviving function answers 0 there, nothing is removed. If J = d the question is d and exactly g_d is removed. If J > d the question is ⋆ and nothing is removed. So each round with driver g_d is unfaithful, ends the reign of g_d with probability 1/L independently of the past, and removes nothing else; after g_M is removed f drives and all runs are faithful. This is (a) and the first half of (b). The sum has mean L·M and variance at most L²·M, so it is below L·M/2 with probability at most 4/M by Chebyshev's inequality. ∎

So for M = L the simplest consistent hypothesis as driver spends about L² rounds, all of them unfaithful, where the mixture and the posterior draw have at most L·ln(L + 1) and 2L·ln(L + 1) unfaithful rounds in total. The reason is the one named in the candidate theory: a deterministic driver that deviates early hides the later deviations of all the other hypotheses, so each hypothesis is refuted only during its own reign.

**Example 5.3 (large K: the bound is approached, slowly). PROVED.** Let M ≥ 1 and ε ∈ (0, ¼]. The scaffold draws z ∈ {0, 1, …, M} with Pr[z = i] = ε^i for i ≥ 1, and is otherwise that of Example 2.4: next_j := (z, j) if all earlier answers are 0, and := ⋆ otherwise; L ≥ 1 calls. f ≡ 0; g_i := 1 at the single input (i, 1) and 0 elsewhere, for i ∈ [M]; H := {g_1, …, g_M, f} in this order with weights 1/(M + 1). With the first-consistent driver:

(a) the expected total number of unfaithful rounds lies between L·M·(1 − 2ε) and L·M = L·(2^K − 1);

(b) the expected number of unfaithful rounds among the first n is at most Σ_i min(L, n·ε^i) ≤ L·(log(n/L)/log(1/ε) + 3) for n ≥ L; and g_M is removed only after L·ε^(−M) rounds in expectation.

*Proof.* A question removes g_i if and only if it is (i, 1), that is, if and only if z_t = i and J_t = 1, whoever drives (a driver other than g_i answers 0 at (i, 1); the driver g_i answers 1 there, and the question of call 1 is still (i, 1)). So the removal time D_i of g_i is the first round with (z_t, J_t) = (i, 1), and for d ≠ i, Pr[D_i < D_d] = ε^i/(ε^i + ε^d). The reign of g_i is the set of rounds t with max_{d<i} D_d < t ≤ D_i; a round of this reign is unfaithful if and only if z_t = i, and each such round ends the reign with probability 1/L. So, given that the reign is not empty, it contains a geometric number of unfaithful rounds with mean L; and it is empty with probability at most Σ_{d<i} ε^(i−d) ≤ ε/(1 − ε) ≤ 2ε. This gives (a). For (b), the reign of g_i contributes at most L in expectation and at most the expected number n·ε^i of rounds t ≤ n with z_t = i; the indices with ε^i ≥ L/n number at most log(n/L)/log(1/ε) + 1, and the others contribute at most n·Σ_{i: ε^i<L/n} ε^i ≤ L/(1 − ε) ≤ 2L. E[D_M] = L·ε^(−M). ∎

**Remark 5.4 (why I have no fast example for 2^K > L + 1; OPEN).** For g_i to cost about L unfaithful rounds it must be removed almost only in rounds that it drives. In a round driven by g_d the question lies on the human system's run up to the first deviation of g_d (Lemma 1.4) or beyond it, off that run; it removes g_i when it is a position at or before the first deviation of g_d at which g_i is wrong. So g_i is safe on (z, ρ) only if every earlier driver deviates on (z, ρ) strictly before g_i does. On one (z, ρ) such a chain of drivers has strictly increasing first-deviation positions, hence at most L members; Example 5.2 is such a chain. Further hypotheses must deviate on rarer runs than their predecessors, which lengthens their own reigns as in Example 5.3. Whether the number of unfaithful rounds among the first n can exceed the order L²·log n for some class, and the exact worst case as a function of n, L and K, are open.

### 5.2 One consistent hypothesis selected at the end of mixture-driven rehearsal

For the rehearsal with the mixture driver let, for g ∈ H and a round t,

  d_t(g) := E[ #{ j ≤ T : g(x_j) ≠ f(x_j) } | D_{t−1} ]  for a run of M^(t),

the expected number of calls of the round-t run at whose inputs g is wrong. d_t(g)/L is the probability, given D_{t−1}, that the question of round t removes g.

**Theorem 5.5 (R6(b): an Occam bound on the rehearsal's own visit distribution, and the selected hypothesis's own run). PROVED.** Let H be a class of functions, f ∈ H the human, and run the rehearsal with the mixture driver for n rounds. Let δ ∈ (0, 1).

(a) With probability at least 1 − δ, every g in the final version space V_{D_n} satisfies

  (1/n)·Σ_{t≤n} d_t(g) < L·(ln(1/w(g)) + ln(1/δ))/n.

(b) With probability at least 1 − 2δ, every g ∈ V_{D_n} satisfies

  u(g) < L·(ln(1/w(g)) + K ln 2 + 2 ln(1/δ))/n.

In particular every consistent g with w(g) ≥ w(f), for instance the highest-weight member of V_{D_n}, has u(g) < 2L·(K ln 2 + ln(1/δ))/n: used alone for every call of every later run, it produces a run that differs from the human system's with less than this probability.

*Proof.* *Step 1 (Occam martingale).* Fix g. Let B_t := 1[a question is asked in round t and g(x_t) ≠ f(x_t)], so g ∈ V_{D_n} if and only if B_t = 0 for all t ≤ n. Since J_t is uniform and independent of the run, E[B_t | D_{t−1}] = d_t(g)/L =: r_t, and r_t is a function of D_{t−1}. Put N_s := Π_{t≤s} (1 − B_t)·e^(r_t). By (E3), E[(1 − B_t)e^(r_t) | D_{t−1}] = (1 − r_t)e^(r_t) ≤ 1, so (N_s) is a nonnegative supermartingale with N_0 = 1 and E[N_n] ≤ 1. On the event {g ∈ V_{D_n}, Σ_{t≤n} r_t ≥ c} we have N_n ≥ e^c; so this event has probability at most e^(−c) by Markov's inequality. Take c := ln(1/(w(g)δ)) and sum over g: the probability that some consistent g has Σ_t d_t(g) ≥ L·ln(1/(w(g)δ)) is at most Σ_g w(g)·δ ≤ δ. This is (a).

*Step 2 (the mixture's runs are mostly faithful, with high probability).* Let β_t := E[number of unfaithful calls of the run of M^(t) | D_{t−1}], and m_t the mass removed in round t. A call at input x is unfaithful with probability ē_t(x) = 1 − M^(t)(f(x)|x) given the run so far, and m_t = ē_t(x_t) when a question is asked, so E[m_t | D_{t−1}] = β_t/L, and β_t/L ≤ 1 − w_t(f) < 1. The process Π_{t≤s} (1 − m_t)/(1 − β_t/L) is a positive martingale with mean 1. By Markov's inequality, with probability at least 1 − δ it is below 1/δ at s = n, and then, by Lemma 1.5 and (E2), Σ_{t≤n} β_t/L ≤ Σ_{t≤n} −ln(1 − β_t/L) < ln(1/δ) + Σ_{t≤n} −ln(1 − m_t) ≤ ln(1/δ) + K ln 2. (This is Lemma 4.3(a) of `research/prove/rehearsal-core.md`.)

*Step 3 (from the visit distribution of the mixture to the hypothesis's own run).* Fix g and t. Given D_{t−1}, consider the run of M^(t) on (z, ρ). If g's own run on (z, ρ) is unfaithful, g is wrong at the input x^f_{j*} of the human system's run, j* its first deviation index (Lemma 1.4); and if the run of M^(t) is faithful, it is the human system's run and visits x^f_{j*}. So the number of calls of the mixture's run at whose inputs g is wrong is at least 1 on the intersection of the two events, and

  d_t(g) ≥ u(g) − Pr[the run of M^(t) is unfaithful | D_{t−1}] ≥ u(g) − β_t.

*Step 4.* Average Step 3 over t ≤ n: u(g) ≤ (1/n)Σ_t d_t(g) + (1/n)Σ_t β_t. On the intersection of the events of Steps 1 and 2, which has probability at least 1 − 2δ, the first term is below L·ln(1/(w(g)δ))/n for every consistent g and the second is below L·(K ln 2 + ln(1/δ))/n. ∎

*What it says and does not say.* The selection may be any rule that returns a consistent hypothesis: the bound is uniform over the version space, with the weight of the selected hypothesis in it. The first term is the price of selecting; the second is the price of having measured g on the mixture's runs instead of its own. The statement is for a deterministic human and deterministic hypotheses; for a stochastic human no version holds (Section 3). The driver matters: with the first-consistent driver in place of the mixture the same selection rule is the driver itself, and Example 5.2 applies.

**Corollary 5.6 (one posterior draw at the end, kept for good). NEW.** In the setting of Theorem 5.5 draw ĝ from the final posterior w_{D_n}. With probability at least 1 − 2δ over the rehearsal and the draw, u(ĝ) < 2L·(K ln 2 + ln(1/δ))/n.

*Proof.* For c > 0 let Bad_c := {g ∈ V_{D_n} : Σ_{t≤n} d_t(g) ≥ L·c}. The posterior mass of Bad_c is w(Bad_c)/w(V_{D_n}) ≤ w(Bad_c)/w(f), and E[w(Bad_c)] = Σ_g w(g)·Pr[g ∈ Bad_c] ≤ e^(−c) by Step 1. With c := K ln 2 + ln(1/δ) the expected posterior mass of Bad_c is at most δ, so ĝ ∉ Bad_c with probability at least 1 − δ. Combine with Steps 2 to 4. ∎

## 6. One program or a committee: what the results imply

The researcher would like the imitator to be one program, like the human, and not a mixture. The table says which guarantees a single member of the class can carry. "Member per run" is a posterior draw for each run; "member for good" is one function selected once.

| guarantee, from n single-call questions | committee (fresh posterior draw at every call) | one member per run | one member for good |
|---|---|---|---|
| deterministic human: the run is the human system's run | fails with probability ≤ L·K ln 2/n (R1, R2) | ≤ 2L²·K ln 2/((L+1)·n) (Theorem 2.1, Corollary 2.2); constant exact (Proposition 2.5) | < 2L·(K ln 2 + ln(1/δ))/n with confidence 1 − 2δ (Theorem 5.5, Corollary 5.6) |
| deterministic human, scaffold tolerating θL faults | additional failure ≤ K ln 2/(θn), whatever L (R3) | no gain from the tolerance: for some class and human at least L/(8n) (Proposition 4.3) | the same lower bound |
| how the rehearsal runs may be driven | mixture | posterior draw: the same order; first consistent ("simplest"): up to L·(2^K − 1) unfaithful rounds, L² of them at the start when K = log₂(L+1) (Proposition 5.1, Example 5.2) | select at the end of a mixture-driven or draw-driven rehearsal, not inside it |
| stochastic human: run law close to Q_P | E TV ≤ 2·√(L·K ln 2/n) (R2, `hellinger-runs.md`) | no bound from rehearsal data: TV = 0.375 at fresh inputs in every round, with K = 1 and L = 3, for as many rounds as the class is built for (Example 3.1; Proposition 3.2 when all calls are asked) | none either: a member s of F in Example 3.1 has TV(Q_s, Q_P) ≥ 1 − (1 − ε)³ |
| stochastic human, N recorded runs of the human system (N·L answers) | not the right object there (Example 4.6 of `hellinger-runs.md`) | E TV ≤ √(K ln 2/(2N)) (Theorem A) | Theorem B, steeper weights |

Four conclusions.

1. **For a deterministic human a single program is available at the same order of cost** as the committee, as long as every call matters: a fresh draw per run costs the factor 2L/(L + 1), a program fixed for good costs the factor 2 and a confidence parameter. The program must be chosen by a posterior draw or selected after a mixture-driven rehearsal; it must not drive the rehearsal as the current simplest consistent hypothesis.

2. **The committee is needed for low stakes.** A member of the class that is wrong at a rare input is the same wrong member at the next call; a committee that errs once is corrected by its other members at the next call. Tolerance of faults is used by the committee and by its vote, and is not used by any rule that deploys a member chosen before the run's input is seen (Propositions 4.2 and 4.3, Remark 4.5).

3. **The committee is needed for a stochastic human, unless the human carries out whole runs.** Under A1 the human's answers at different calls are independent given the inputs. A fresh draw per call has this property by construction. A member drawn for the run has it too, but the posterior over members need not: it can keep, for as long as the asked inputs do not recur, members whose answers at the calls of one run are jointly unlike the human's while each single answer is distributed correctly, because single answers do not test joint behaviour. The per-call mixture is itself one stateless sampler, a single program in the sense of the model; it is not a member of the class, and its description is the data and the class, not a program of K bits.

4. **Nothing here separates the human's own program from another member that behaves like it on the closed system.** Theorems 2.1 and 5.5 bound how often the selected member's run differs from the human system's; they say nothing about which member it is (the copy test). For a stochastic human the candidates that survive rehearsal include the human "with coins filled in" (Example 3.1), and for those the difference is behavioural, visible in runs and invisible in single calls.

## 7. Numerical checks

All scripts are in `research/prove-c/code/` and were run in this session; the complete outputs are in the `.out` files next to them. Assertions in the scripts check the stated inequalities.

### 7.1 `one-mind_r4.py` (Theorem 2.1, Proposition 2.5)

(a) The series S(L, K) of Proposition 2.5, with its two bounds (excerpt):

```
   L     K   S(L,K)    S/(L K ln2)  lower bd 2L(L-1)(K-1)ln2/(L+1)  upper bd 2L^2 K ln2/(L+1)
   2   100     133.45     0.9626              91.50                     184.84
   5   100     514.73     1.4852             457.48                     577.62
  20   100    2551.01     1.8402            2483.45                    2640.56
 100   100   13523.32     1.9510           13452.55                   13725.69
```

(b) Eight random instances (14 inputs, 3 answers, 6 top-level inputs, horizon 3 to 6, runs of variable length, 41 functions with random weights of total 0.9), posterior-draw driver, 300 rehearsals of 400 rounds each; u_t(z) is computed exactly in every round (excerpt):

```
 seed  L   K     sum E[u_t]   bound 2L^2 K ln2/(L+1)   sum E[psi_L(u_t)]   bound L K ln2
    3  6  4.28     6.570±0.156              30.52            5.436±0.126        17.81
    4  3  5.13     4.973±0.114              16.01            4.163±0.090        10.68
    8  3  4.64     1.667±0.046              14.48            1.554±0.043         9.66
```

On such unstructured classes the bounds are loose by a factor between 2.5 and 13; the extremal example is needed to see the constant.

(c) The example of Proposition 2.5 simulated directly with N_z = 20000 (product posterior tracked exactly, 200 rehearsals):

```
   L   K  rounds   sum E[u_t] (sim)   S(L,K) (series)
   5   5     150        22.80±0.21          23.02
  10  10     600       110.56±0.59         110.22
  20   5     600       106.99±0.55         106.70
```

### 7.2 `one-mind_stochastic.py` (Example 3.1, Proposition 3.2)

(1) Example 3.1 with N_z = 10 and ε = 0.1, exact Bayes over all 1024 functions and P, exact total variation by enumeration of runs, 200 rehearsals. In round 1 the posterior of P is 0.500000, TV(one draw per run, Q_P) = 0.135000 = (3/2)ε(1 − ε) and TV(per-call mixture, Q_P) = 5·10⁻¹⁶. In later rounds, on the rehearsals whose asked inputs are distinct, the posterior of P is 0.500000 in every case and the first distance is at least 0.1350; the mixture's distance is then positive (up to 0.14) because with N_z = 10 an asked input recurs with probability t/10, as part (c) of the example allows.

(2) Proposition 3.2 with N_z = 3 and R = 2: all 4096 members of F enumerated; the closed-form posterior odds of parts (a), (b), (c) equal the brute-force Bayes odds in 300 of 300 random data sets that mix the three kinds of rounds.

(3) Proposition 3.2 with R = 1000, N_z = 10⁷, n = 100 rounds, 2000 rehearsals:

```
 data put to the human                      rounds with TV>=1/4 at fresh z   mean final posterior of P   distinct z
 one call of the driver run                             1.0000                     0.5000         0.9990
 all calls of the driver run                            0.9787                     0.5163         0.9995
 a recorded human-system run                            0.0203                     1.0000         1.0000
```

The second row agrees with the loss rate 1/(2R) per round of part (b) (about 2.5% of the rounds lie after the loss of F).

### 7.3 `one-mind_r5.py` (Propositions 4.2 and 4.3)

(1) Class A, exact (the law of k after n = N rounds by dynamic programming over the transition probabilities of each driver; then the formulas of Proposition 4.2), c0 = ⌈L/4⌉:

```
    N=n   L   driver          E[k]/N   Pr[>=1 unf. call]  Pr[>=2]      Pr[>=c0]     (Pr[>=c0])*n/L
     400  20   posterior draw  0.3654        0.01306      1.242e-02    1.050e-02       0.2100
     400  20   mixture         0.3653        0.01329      2.291e-04    1.142e-10       0.0000
    1600  40   posterior draw  0.3667        0.00663      6.462e-03    5.150e-03       0.2060
    1600  40   mixture         0.3667        0.00669      5.934e-05    1.230e-25       0.0000
```

Both imitators have an unfaithful call with almost the same probability. The posterior draw then has at least L/4 of them with probability about 0.21·L/n; the mixture has two with probability 2.3·10⁻⁴ and 5.9·10⁻⁵ at these sizes (below (L/n)²/2) and L/4 essentially never.

(2) Monte Carlo of the two protocols themselves (N = n = 40, L = 8, 80000 rehearsals) against the exact values in brackets: posterior draw E[k] = 14.233 [14.236], Pr[≥ 1] = 0.0478 [0.0479], Pr[≥ 2] = 0.0422 [0.0425]; mixture E[k] = 14.227 [14.227], Pr[≥ 1] = 0.0504 [0.0511], Pr[≥ 2] = 0.0035 [0.0032]. (Standard errors 0.0008 for the probabilities near 0.05 and 0.0002 for the last one.)

(3) Class B with N = 2n = 120, L = 12, 6000 mixture-driven rehearsals with a uniformly random human, then one fresh run each: the first consistent member has at least L/4 unfaithful calls with frequency 0.0445 (lower bound L/(8n) = 0.0250); the mixture has at least 3 unfaithful calls with frequency 0.00083 (upper bound 0.00617).

### 7.4 `one-mind_r6.py` (Example 5.2, Theorem 5.5)

(a) Example 5.2 with M = L, mean number of unfaithful rounds over 400 rehearsals:

```
    L    K     first consistent   [exact L*M]   posterior draw   [bound 2L^2 K ln2/(L+1)]   mixture   [bound L K ln2]
    8  3.17           62.9             64          18.94              31.25            14.27        17.58
   16  4.09          258.0            256          53.22              85.33            38.71        45.33
   32  5.04         1011.7           1024         147.78             217.00            97.97       111.89
```

(b) Theorem 5.5 and Corollary 5.6 on three random instances (L = 6, 151 functions, f of median weight, K about 8.4 bits), δ = 0.1, 300 rehearsals per cell: for n = 50, 200, 800 the bound 2L·(K ln 2 + ln(1/δ))/n is about 1.95, 0.49, 0.12; the mean of u(ĝ) for the highest-weight consistent hypothesis is 0.05 to 0.08, 0.000 to 0.013, 0.0000, and for a final posterior draw 0.05 to 0.06, 0.006 to 0.008, at most 0.0003; the bound was never exceeded. On these classes the bound is loose by a factor of 20 or more.

### 7.5 The lead's toy (`code/toy.py`, `results/toy.out`)

The toy compares the three drivers on one class (1117 functions, K = 3.78 bits). Its figures agree with the statements here: for the posterior draw ("one-mind") the summed probability of an unfaithful run is 1.57, 15.37 and 22.30 for L = 3, 15, 63, below (2L²/(L + 1))·K ln 2 = 11.8, 73.7, 325; for the first-consistent driver ("map") it is 3.28, 21.07 and 27.20, below L·(i₀ − 1) = 2L = 6, 30, 126 of Proposition 5.1 (two hypotheses of that class are heavier than f). The toy's class has no long chain of protected hypotheses, so it does not show the effect of Example 5.2.

## 8. Open questions, and remarks on other files

### 8.1 Open in this part

1. **The exact constant of R4** for given L and K lies between S(L, K) and (2L²/(L + 1))·K ln 2; these differ by the factor (1 − 1/L)(1 − 1/K) at most. A version of Theorem 2.1 with high probability over the rehearsal, and a version for the last round in place of a random round, are not written.
2. **A nearly deterministic human** (P(f(x)|x) ≥ 1 − ε for all x). In Example 3.1 the damage is of order ε per run. Whether the posterior-draw driver satisfies a bound of the form (R4 bound) + O(L·ε) in general is not treated.
3. **A stochastic human and single-call data.** Proposition 3.2 refutes one member per run for rehearsal data, including all calls of the rehearsal runs. Recorded runs of the human system cost L answers each. Whether fewer answers on the human's own path suffice (for example a random prefix of a human run) is open.
4. **R6(a) for 2^K > L + 1** (Remark 5.4): the worst case of the number of unfaithful rounds among the first n for the first-consistent driver.
5. **Theorem 5.5** with one confidence parameter (a single martingale for Steps 1 and 2), and for a rehearsal driven by posterior draws.
6. **The vote.** Remark 4.5 uses the plurality function in class B only. A general statement that the plurality vote of the posterior inherits the committee's use of fault tolerance is not proved here; Protocol AB of `research/prove/lower-bounds.md` bounds the probability of a fully faithful run, not the number of unfaithful calls.

### 8.2 Remarks on other files of the project

1. **`research/candidate-theory.md`, R4.** Correct as stated. The hypothesis "functions" is needed for the human only; the constant 2L can be replaced by 2L²/(L + 1), which is exact up to lower-order terms.
2. **Same file, R5.** "Every rule that deploys a single hypothesis per run" must read "every rule that deploys a member of the class"; for an arbitrary function it is false (Remark 4.5). The statement is minimax over the humans of a class: for a fixed simple human (class A) the highest-weight consistent member is the human itself, and only the random draw fails.
3. **Same file, R6.** "Up to L·2^K in total" is the right supremum (Proposition 5.1), but in the examples I have it is reached within about L·2^K rounds only when 2^K ≤ L + 1. "Error ≤ (K ln 2 + ln(1/δ))/n on the mixture-driven visit distribution" is correct as an average over the n rounds of the probability of being wrong at the asked call, for a selected hypothesis at least as heavy as f. "O(L(K + ln(1/δ))/n)" holds with the constant 2 and confidence 1 − 2δ.
4. **Same file, Section 9, and Section 0 item 3.** "R4 and R6 give a single coherent program" holds for a deterministic human only. Since the note's model is "the human as a sampler", the note should say that for a stochastic human rehearsal supports the per-call mixture only, and that one program per run needs recorded runs of the human system (Section 3 here). Section 11 of the candidate theory lists "stochastic versions of R4 to R6" as open; for R4 and R6(b) the answer is negative.
5. **`research/prove-b/hellinger-runs.md`, Section 8.1 item 6** ("one fixed program inside Protocol R … for a stochastic human, is not treated"): Example 3.1 answers it in the negative for members of the class, whether drawn per run or kept for good.
6. **`code/toy.py`.** Its header says of the "map" driver "none" (no theorem); Proposition 5.1 gives it the bound L·(number of heavier hypotheses), which its output satisfies (Section 7.5).

## 9. Literature, and what is used from where

No result from the literature is used as a black box. The proofs use Markov's and Chebyshev's inequalities, the Cauchy–Schwarz inequality, the Bonferroni inequality 1 − (1 − x)^m ≥ mx − (m choose 2)x², and nonnegative supermartingales with Markov's inequality.

From the project's files: Lemma 1.5 and Step 2 of Theorem 5.5 are Lemmas 4.2 and 4.3(a) of `research/prove/rehearsal-core.md`, re-proved here in two lines each. Theorem R1, Theorem R2 and Theorem R3 are quoted for comparison from `note.md`, `research/prove/rehearsal-core.md` and `research/prove-b/hellinger-runs.md`; Theorem A (Theorem 4.2 of the latter) and Theorem B are quoted in Remark 3.3 and Section 6 and were not re-checked by me; Protocol AB (Theorem 3.3 of `research/prove/lower-bounds.md`) is quoted in Remark 4.5.

Pointers, quoted from memory and not opened in this session; no statement of these works is used. Drawing one hypothesis from the posterior and following it for a whole episode is posterior (Thompson) sampling per episode: M. Strens, "A Bayesian framework for reinforcement learning", ICML 2000; I. Osband, D. Russo and B. Van Roy, "(More) efficient reinforcement learning via posterior sampling", NeurIPS 2013. The analyses there bound regret in a reward problem with observed transitions; the symmetry argument of Theorem 2.1 (two independent posterior draws, the one that deviates later exposes the other) is the one of the candidate theory. Rehearsal with a no-regret learner on its own induced distribution is S. Ross, G. Gordon and J. A. Bagnell, "A reduction of imitation learning and structured prediction to no-regret online learning", AISTATS 2011 (cited in the outline; not opened by me).
