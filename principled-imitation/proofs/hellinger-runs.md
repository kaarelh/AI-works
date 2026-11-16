# Whole-run closeness for a stochastic human (key: hellinger-runs)

Part of the second proving round for `candidate-theory.md` (version 2). This file covers Lemma L4, Theorem R2 in general, Theorem A and Theorem B, and their forms for a general countable class. Every statement below is proved in this file or is marked otherwise. Scripts are in `research/prove-b/code/hellinger-runs_*.py`; their output is quoted in Section 7.

## Summary of the statements

| no. | statement | tag |
|---|---|---|
| Lemma 1.1 | Relations between H², TV and KL; bounds for single events, among them Q(A) ≤ 2P(A) + 4H²(P,Q) and Q(A) ≤ 2H²(P,Q) when P(A) = 0. | PROVED (standard) |
| Theorem 2.1 | Sequential experiments with kernels p_i, q_i and h_i := H²(p_i, q_i): (a) H²(P,Q) = E_P Σ_i Λ_{i−1} h_i exactly; (b) H²(P,Q) ≤ ½(E_P Σ h_i + E_Q Σ h_i); (c) H²(P,Q) ≤ 4·E_P Σ h_i. | PROVED |
| Corollary 2.3 (**L4**) | For answerers A, B on a scaffold of horizon L, runs of any length: H²(Q_A, Q_B) ≤ 4·E_{Q_A} Σ_j H²(A,B)(history_j); hence TV(Q_A, Q_B) ≤ √(8·E_{Q_A} Σ_j H²_j). | MODIFIED: the candidate's L4 was a sketch with c₀ = 7 attributed to Foster, Kakade, Qian and Rakhlin. It is proved here with c₀ = 4 by a different and shorter argument (and with c₀ = 2.9641 in Theorem 2.7); the constant 7 is in a later paper (Section 2.1). |
| Proposition 2.4 | If the inputs do not depend on the answers, the constant in L4 is 1. | PROVED |
| Proposition 2.5 | Converse with a factor: E_{Q_A} Σ_j H²(A,B)(history_j) ≤ 2L·H²(Q_A, Q_B); the factor L is needed. | PROVED |
| Example 2.6 | With two calls the constant in L4 cannot be below (2+√2)/2 = 1.707. | PROVED |
| Theorem 2.7 | L4 with the constant c* = 2.9641 in place of 4, where c* = 1/(1 − q₀²/2) and q₀ is the smallest positive root of an explicit equation; proved with a second potential. | PROVED |
| Example 2.8 | Explicit pairs of samplers with ratio 2.0997 (closed form) and 2.9639 (computed). So the best constant c₀* satisfies 2.9639 ≤ c₀* ≤ 2.9641; that c₀* = c* exactly is not proved. | lower bound by floating-point evaluation of an explicit example; equality OPEN |
| Theorem 3.1 (**R2**) | Under Protocol R: E H²(Q_{M^(T)}, Q_P) ≤ 2LK ln2/n; E TV(Q_{M^(T)}, Q_P) ≤ 2√(LK ln2/n); for an event G of runs, E Q_{M^(T)}(G) ≤ 2Q_P(G) + 8LK ln2/n, and E Q_{M^(T)}(G) ≤ 4LK ln2/n if Q_P(G) = 0. | PROVED (the candidate's statement with c₀ = 4; the bounds in H² and for events are additions). R1 is proved in Appendix A. |
| Proposition 3.4 | A class of K coins and a scaffold of L calls for which every protocol needs n > LK/(8·10⁴·ε²) questions to have E TV ≤ ε for all members (ε ≤ 1/65). So the factor √L in R2 is necessary, and R2 is optimal up to an absolute constant in the worst case. | PROVED |
| Proposition 3.5 | Two samplers (K = 1) and L calls at one input: every protocol needs n > L/(740·ε²) questions for E TV ≤ ε for both (ε ≤ 1/12). | PROVED |
| Theorem 4.2 (**Theorem A**) | N recorded runs, a posterior draw per run, uniformly random t: E KL(Q* ‖ Q̂) ≤ min_ν [ln(1/w(ν))/N + KL(Q* ‖ Q_ν)] for every law Q* of independent runs; for a human in the class, E KL ≤ K ln2/N and E TV ≤ √(K ln2/(2N)). | PROVED (the candidate's statement, extended to a human outside the class) |
| Example 4.4 | The expected divergence of the posterior mixture is not monotone in the number of runs. | PROVED (exact computation) |
| Example 4.6 | The per-call mixture in place of the draw per run: the statement of Theorem A is false. With K = 1 the divergence is L times larger, and the total variation exceeds the bound of Theorem A as soon as L > 9.5·√N. | REFUTED (the per-call variant of Theorem A) |
| Proposition 4.7 | What holds for the per-call mixture: a bound with the factor L for a deterministic human, and for scaffolds whose inputs do not depend on the answers. | PROVED |
| Example 4.8 | For an adaptive scaffold and a stochastic human the summed per-call divergences of the frozen per-call mixture along human runs are not bounded by any multiple of L·K ln2. | PROVED (exact formula) |
| Theorem 5.1 (**Theorem B**) | Weights 2^(−λℓ), λ > 1, any s ∈ [1/λ, 1): E[posterior mass of {ν : H²(Q_ν, Q_P) ≥ ε²}] ≤ 2^(λsℓ(P))·(1−ε²)^(2·min(s,1−s)·N); the same bound for the probability that some such ν has at least the posterior weight of P. | PROVED (the candidate's constants are confirmed; for λ > 2 the choice s = ½ gives a smaller sample size than the candidate's s = 1/λ) |
| Corollary 5.2 | One fixed program: what closeness in H² gives for one run, for m runs, and for rare events. | PROVED |
| Example 5.4 | At λ = 1 no bound in terms of ℓ(P), ε and N exists: a class with ℓ(P) = 1 in which the expected posterior mass of hypotheses at H² = 0.29 is at least ¼ for all N ≤ 2^(d/2), d arbitrary. | PROVED |
| Theorem 5.5 (**B′**) | Substitute at λ = 1, also for a human outside the class: with the likelihood raised to the power α ∈ (0,1), the posterior mean of H²(Q_ν, Q*) has expectation at most [ln(1/w(ν*))/N + α·KL(Q* ‖ Q_ν*)]/(2·min(α,1−α)) for every ν*. | PROVED |
| Proposition 5.6 | The posterior with weights w^λ when the human is outside the class: a bound in probability, with the approximation term divided by the confidence level. | PROVED |
| Section 6 | Both theorems for a general countable class; what changes outside the class. | summary of proved statements |
| Section 8 | Open questions, and remarks on other parts of the candidate theory. | OPEN |

**In brief.** (1) L4 holds with the constant 4, by a potential-function argument of ten lines (Lemma 2.2), and with the constant c* = 2.9641 by a longer argument of the same kind (Theorem 2.7); explicit examples reach the ratio 2.9639, so c* is the best constant up to the fourth digit. (2) R2 follows: E TV ≤ 2·√(LK ln2/n), and in the stronger form E H² ≤ 2LK ln2/n, which gives the linear rate 4LK ln2/n for events that the human system never produces. (3) The factor √L is necessary for a stochastic human: for K coins of bias ±δ about LK/ε² answers are needed, whatever the protocol. (4) Theorem A is correct and extends to a human outside the class; it is false for the per-call mixture, by a factor L. (5) Theorem B is correct for all λ > 1; at λ = 1 it fails because of memorising hypotheses, and tempering the likelihood is a substitute that also works outside the class.

## 0. Setting and conventions

**0.1 Samplers and answerers.** X and Y are countable sets. We assume that Y contains a symbol ⊥ ("no answer"). A **sampler** is a probability kernel S(·|x) on Y. A hypothesis that is given as a semimeasure is identified with its completion by ⊥; nothing else about semimeasures is used below. (The scaffold must therefore say what it does with the answer ⊥; if the human never answers ⊥, the completion does not enter any likelihood, but it does enter the law of an imitator's run.)

**0.2 Scaffolds and runs.** A scaffold Π of horizon L consists of a probability space (Ω₀, μ₀) carrying the pair ω₀ = (z, ρ) of the top-level input and the scaffold's own randomness, and of measurable maps next_j : Ω₀ × Y^(j−1) → X ∪ {STOP}, j = 1, …, L. (The outcome map of the candidate theory plays no role in this file.) An **answerer** A is a family of probability kernels A_j(·|ω₀, y_1, …, y_(j−1)) on Y; a sampler S is the answerer A_j(·|ω₀, y_<j) = S(·|x_j) with x_j = next_j(ω₀, y_<j). A run with answerer A is generated as follows: ω₀ ~ μ₀; for j = 1, 2, …, L: x_j := next_j(ω₀, y_<j); if x_j = STOP the run ends, otherwise y_j ~ A_j(·|ω₀, y_<j). The run is τ = (ω₀, y_1, …, y_len(τ)), where len(τ) ≤ L is its number of calls; the inputs x_j are functions of τ. Q_A is the law of τ. The **human system** is Q_P.

*Changes of notation.* The candidate theory uses T both for the number of calls of a run and for the deployed round; here len(τ) is the number of calls and T is the deployed round. It uses ρ for the scaffold's randomness; here ω₀ = (z, ρ), and the letter r is used for root likelihood ratios in Section 2. The candidate lets an answerer see "the history"; here an answerer may also see ω₀, which is more general and changes no proof.

**0.3 Runs as sequences of fixed length.** Put Y′ := Y ∪ {∅} with a new symbol ∅ and y_j := ∅ for j > len(τ). Then τ is identified with (ω₀, y_1, …, y_L) ∈ Ω₀ × Y′^L, and Q_A is the law generated by the kernels
a_j(·|ω₀, y_<j) := A_j(·|ω₀, y_<j) if next_j(ω₀, y_<j) ≠ STOP and no earlier call was STOP; a_j := point mass at ∅ otherwise.
Q_A has the density q_A(τ) = Π_{j≤L} a_j(y_j|ω₀, y_<j) with respect to μ₀ ⊗ (counting measure on Y′^L). All laws of runs in this file have the same marginal μ₀ on Ω₀.

**0.4 Divergences.** For probability vectors p, q on a countable set:
BC(p,q) := Σ_x √(p(x)q(x)), **H²(p,q) := 1 − BC(p,q)** (the convention of the candidate theory), TV(p,q) := ½ Σ_x |p(x) − q(x)|, KL(p‖q) := Σ_x p(x) ln(p(x)/q(x)) ∈ [0, ∞] (in nats; +∞ if p(x) > 0 = q(x) for some x).
For laws of runs the sums are replaced by ∫ μ₀(dω₀) Σ_{y ∈ Y′^L} applied to the densities of 0.3. For samplers S, S′ and x ∈ X we write H²(S,S′)(x) := H²(S(·|x), S′(·|x)), and likewise TV(S,S′)(x) and KL(S‖S′)(x). In sums over the calls of a run, Σ_j always means Σ_{j ≤ len(τ)}.

**0.5 Class, posterior, mixture.** H is a countable class of samplers with weights w(ν) > 0, Σ_ν w(ν) ≤ 1 ("Kraft weights"). For data D = ((x_i, y_i))_i the posterior is w_D(ν) := w(ν)·Π_i ν(y_i|x_i) / Σ_ν′ w(ν′)·Π_i ν′(y_i|x_i) (defined when the denominator is positive), and the mixture is M_D(y|x) := Σ_ν w_D(ν) ν(y|x). If the human P is in H, K := log₂(1/w(P)). The assumptions A1 (stateless human: each question x is answered by an independent draw from P(·|x)), A2 (P ∈ H) and A3 (the protocol's coins are independent of the human's coins) are those of the candidate theory; each statement says which of them it uses.

## 1. Elementary facts

**Lemma 1.1.** Let P, Q be probability measures on a countable set (or laws of runs as in 0.4). Write H² = H²(P,Q).
1. H² ≤ TV(P,Q) ≤ √(H²(2 − H²)) ≤ √(2H²).
2. H² ≤ −ln BC(P,Q) ≤ ½·KL(P‖Q).
3. TV(P,Q) ≤ √(KL(P‖Q)/2) (Pinsker's inequality).
4. P ↦ H²(P,Q), P ↦ TV(P,Q) and P ↦ KL(Q‖P) are convex. H², TV and KL do not increase when the same map is applied to both arguments (data processing).
5. For every event A: (√Q(A) − √P(A))² ≤ 2H². Hence for every η > 0: Q(A) ≤ (1+η)·P(A) + (1 + 1/η)·2H²; in particular Q(A) ≤ 2P(A) + 4H². If P(A) = 0 then Q(A) ≤ 2H².
6. The function t ↦ √(t(2−t)) is concave and increasing on [0,1]; so E TV ≤ √(E H²·(2 − E H²)) ≤ √(2·E H²) when the pair (P,Q) is random.

*Proof.* (1) Σ√(pq) ≥ Σ min(p,q) = 1 − TV gives H² ≤ TV. By the Cauchy–Schwarz inequality, 2·TV = Σ|√p − √q|(√p + √q) ≤ √(Σ(√p − √q)²)·√(Σ(√p + √q)²) = √(2H²)·√(4 − 2H²). (2) 1 − t ≤ −ln t; and by Jensen's inequality ln Σ_{p>0} p·√(q/p) ≥ Σ_{p>0} p·½ ln(q/p) = −½ KL(P‖Q). (3) Standard; it also follows, with the constant √(1/2) replaced by 1, from (1) and (2). We use the standard form [from memory: for example A. B. Tsybakov, *Introduction to Nonparametric Estimation*, Springer 2009, Lemma 2.5]. (4) BC is concave in each argument because √ is concave; TV is a norm distance; KL(Q‖·) is convex because −ln is. For a map φ, Σ_u √(P(φ⁻¹u)·Q(φ⁻¹u)) ≥ Σ_x √(p(x)q(x)) by the Cauchy–Schwarz inequality in each fibre; for TV the statement is immediate, and for KL it is the log-sum inequality in each fibre. (5) Apply (4) to the indicator of A: 1 − √(P(A)Q(A)) − √(P(Aᶜ)Q(Aᶜ)) ≤ H², and the left side equals ½(√P(A) − √Q(A))² + ½(√P(Aᶜ) − √Q(Aᶜ))². Then √Q(A) ≤ √P(A) + √(2H²), and (a+b)² ≤ (1+η)a² + (1+1/η)b². (6) The second derivative of √(2t − t²) is −(2t − t²)^(−3/2) < 0; then Jensen's inequality and (1). ∎

Item 5 is the form in which closeness in H² is stronger than closeness in total variation: an event that is rare for P is rare for Q at the scale H², not √H².

## 2. Lemma L4: subadditivity of H² for sequentially generated data

### 2.1 What the literature states

All four papers below were read in their arXiv TeX sources during this session (downloaded from arxiv.org/e-print on 14 November 2026).

1. **Dylan J. Foster, Sham M. Kakade, Jian Qian, Alexander Rakhlin, "The Statistical Complexity of Interactive Decision Making", arXiv:2112.13487** (current arXiv version; source files dated 12 July 2023). Convention: D²_H(P,Q) = ∫(√dP − √dQ)², which is 2H² in our convention. The lemma "Subadditivity for squared Hellinger distance" (label `lem:hellinger_chain_rule`; later papers cite it as Lemma A.13) says: for measurable spaces 𝒳_1, …, 𝒳_n and probability kernels P^(i), Q^(i) from 𝒳_1 × ⋯ × 𝒳_(i−1) to 𝒳_i, with P and Q the laws of X_1, …, X_n under X_i ~ P^(i)(·|X_1:i−1) and X_i ~ Q^(i)(·|X_1:i−1),
 D²_H(P,Q) ≤ 10²·log(n)·E_P[Σ_i D²_H(P^(i)(·|X_1:i−1), Q^(i)(·|X_1:i−1))],
and, if all kernels have likelihood ratios bounded by V ≥ e, the same with 3·log(V) in place of 10²·log(n). **This paper does not contain the constant 7.** Its change-of-measure lemma (label `lem:mp_min`) says: for 0 ≤ h ≤ R, |E_P h − E_Q h| ≤ √(2R(E_P h + E_Q h)·D²_H(P,Q)), and E_P h ≤ 3E_Q h + 4R·D²_H(P,Q).
2. **Dylan J. Foster, Yanjun Han, Jian Qian, Alexander Rakhlin, "Online Estimation via Offline Estimation: An Information-Theoretic Framework", arXiv:2404.10122.** The lemma "Subadditivity for squared Hellinger distance" in its technical appendix (cited by the two papers below as Lemma D.2) has the same hypotheses and the conclusion
 D²_H(P,Q) ≤ 7·E_P[Σ_i D²_H(P^(i)(·|X_1:i−1), Q^(i)(·|X_1:i−1))].
Its proof applies the "cut-and-paste" property and Theorem 7 of T. S. Jayram, "Hellinger strikes back: a note on the multi-party information complexity of AND", APPROX-RANDOM 2009, LNCS 5687, pp. 562–573 (not read by me); the constant is 2/Π_{i≥1}(1 − 2^(−i)) = 6.93, rounded up.
3. **Fan Chen, Dylan J. Foster, Yanjun Han, Jian Qian, Alexander Rakhlin, Yunbei Xu, "Assouad, Fano, and Le Cam with Interaction: A Unifying Lower Bound Framework and Characterization for Bandit Learnability", arXiv:2410.05117.** Restates the lemma with the constant 7 in the convention H² = 1 − Σ√(pq) (it defines squared Hellinger distance as the f-divergence with f(x) = ½(√x − 1)²), and attributes it to Jayram (2009), with pointers to Lemma 11.5.3 of J. C. Duchi's *Lecture Notes on Statistics and Information Theory* (not read by me) and to item 2.
4. **Dylan J. Foster, Adam Block, Dipendra Misra, "Is Behavior Cloning All You Need? Understanding Horizon in Imitation Learning", arXiv:2407.15007** (NeurIPS 2024 according to the digest `understand/ask-for-help.md`; source files dated 3 December 2024). Convention D²_H = ∫(√dP − √dQ)². It states no subadditivity lemma of its own; in the proofs of its lower bounds it uses "Lemma D.2 of Foster et al. (2024)", item 2, with the constant 7. It states the change-of-measure lemma |E_P h − E_Q h| ≤ √(½(E_P h² + E_Q h²)·D²_H(P,Q)), and E_P h ≤ 2E_Q h + R·D²_H(P,Q) for h ∈ [0,R]; and the proposition on log-loss behaviour cloning: for a finite class Π containing the expert, with probability at least 1 − δ, D²_H(P^π̂, P^π*) ≤ 2·log(|Π|/δ)/n (n trajectories, π̂ the maximum-likelihood policy).

The inequality is homogeneous of degree one in the divergence, so its constant is the same in both conventions. So the literature gives c₀ = 7 for L4, in the paper of item 2 and not in the one named by the candidate theory. A web search during this session found no statement of the lemma with a constant below 7 and no statement of the best constant; the search was not exhaustive. Theorem 2.1 below gives c₀ = 4 with a self-contained proof of a few lines, and Theorem 2.7 gives c₀ = c* = 2.9641. Section 2.4 also gives examples: no constant below 1.707 is possible (exact calculation), and none below 2.9639 (floating-point evaluation of an explicit example).

### 2.2 The statement and its proof

**Setting.** Let X_0 be a random element of a measurable space, with law μ₀. Let 𝒳_1, …, 𝒳_n be countable sets and, for i = 1, …, n, let p_i(·|x_0, …, x_(i−1)) and q_i(·|x_0, …, x_(i−1)) be probability kernels on 𝒳_i (measurable in x_0). P is the law of (X_0, …, X_n) when X_0 ~ μ₀ and X_i ~ p_i(·|X_<i); Q is the law when X_i ~ q_i(·|X_<i) instead. Write 𝓕_i for the σ-field generated by X_0, …, X_i, and

h_i := H²(p_i(·|X_<i), q_i(·|X_<i)) (an 𝓕_(i−1)-measurable variable with values in [0,1]),
r_i := √(q_i(X_i|X_<i) / p_i(X_i|X_<i)) (defined P-almost surely, since p_i(X_i|X_<i) > 0 with P-probability one),
Λ_i := r_1·r_2⋯r_i, Λ_0 := 1.

No absolute continuity between the kernels is assumed.

**Theorem 2.1.**
(a) H²(P,Q) = E_P[Σ_{i=1}^n Λ_(i−1)·h_i].
(b) H²(P,Q) ≤ ½·E_P[Σ_{i=1}^n h_i] + ½·E_Q[Σ_{i=1}^n h_i].
(c) H²(P,Q) ≤ 4·E_P[Σ_{i=1}^n h_i].

**Lemma 2.2 (one step).** Let U(x) := ½·((2 − x)₊)² for x ≥ 0. Then
(i) U(x) ≥ 3/2 − x for all x ≥ 0, and U(1) = ½;
(ii) for every number Λ ≥ 0 and every random variable r ≥ 0 with E r² ≤ 1: E U(Λr) ≤ U(Λ) + 4·(1 − E r).

*Proof.* (i) For x ≤ 2, U(x) − 3/2 + x = ½(x − 1)² ≥ 0; for x > 2, U(x) = 0 > 3/2 − x. (ii) Note E r ≤ √(E r²) ≤ 1. *Case Λ ≤ 2.* Pointwise U(Λr) ≤ ½(2 − Λr)², so E U(Λr) ≤ 2 − 2Λ·E r + ½Λ²·E r² ≤ 2 − 2Λ·E r + ½Λ² = ½(2 − Λ)² + 2Λ(1 − E r) ≤ U(Λ) + 4(1 − E r). *Case Λ > 2.* Here U(Λ) = 0, and pointwise (2 − Λr)₊ ≤ 2(1 − r)₊: if r ≥ 1 both sides vanish, and if r < 1 then 2 − Λr ≤ 2 − 2r. So E U(Λr) ≤ 2·E(1 − r)² = 2(1 − 2E r + E r²) ≤ 4(1 − E r). ∎

*Proof of Theorem 2.1.* Three facts, each a direct computation with the densities Π_j p_j and Π_j q_j with respect to μ₀ ⊗ counting measure:

(F1) E_P[r_i | 𝓕_(i−1)] = Σ_{x : p_i(x|X_<i) > 0} √(p_i(x|X_<i)·q_i(x|X_<i)) = 1 − h_i.
(F2) E_P[r_i² | 𝓕_(i−1)] = q_i({x : p_i(x|X_<i) > 0} | X_<i) ≤ 1. Hence E_P Λ_i² ≤ 1 and E_P Λ_i ≤ 1 for all i.
(F3) E_P[Λ_n] = ∫μ₀ Σ_{x_1:n} √(Π_j p_j · Π_j q_j) = BC(P,Q) (terms with Π_j p_j = 0 vanish on both sides). In the same way, for every measurable g ≥ 0, E_P[Λ_(i−1)²·g(X_<i)] = ∫μ₀ Σ_{x_<i : Π_{j<i} p_j > 0} Π_{j<i} q_j · g ≤ E_Q[g(X_<i)].

(a) 1 − Λ_n = Σ_i Λ_(i−1)(1 − r_i), and all terms are P-integrable by (F2). By (F1), E_P[Λ_(i−1)(1 − r_i)] = E_P[Λ_(i−1)·h_i]. Sum over i and use (F3).
(b) Λ_(i−1) ≤ ½(1 + Λ_(i−1)²); apply (F3) with g = h_i to the second term of (a).
(c) Conditionally on 𝓕_(i−1), Λ_(i−1) is a constant and r_i is a non-negative variable with conditional second moment at most 1 and conditional mean 1 − h_i, by (F1) and (F2). Lemma 2.2(ii) gives E_P[U(Λ_i) | 𝓕_(i−1)] ≤ U(Λ_(i−1)) + 4h_i. Since 0 ≤ U ≤ 2, all expectations are finite, and summing over i gives E_P U(Λ_n) ≤ U(1) + 4·E_P Σ_i h_i = ½ + 4·E_P Σ_i h_i. By Lemma 2.2(i) and (F3), E_P U(Λ_n) ≥ 3/2 − E_P Λ_n = ½ + H²(P,Q). ∎

**Corollary 2.3 (L4).** Let Π be a scaffold of horizon L and A, B answerers (0.2). For a run τ and j ≤ len(τ) put h_j(τ) := H²(A_j(·|ω₀, y_<j), B_j(·|ω₀, y_<j)); for samplers S, S′ this is H²(S,S′)(x_j). Then

 H²(Q_A, Q_B) ≤ 4·E_{Q_A}[Σ_{j ≤ len(τ)} h_j],  H²(Q_A, Q_B) ≤ ½·E_{Q_A}[Σ_j h_j] + ½·E_{Q_B}[Σ_j h_j],
 TV(Q_A, Q_B) ≤ √(8·E_{Q_A}[Σ_j h_j]),  and for every event G of runs, Q_B(G) ≤ 2Q_A(G) + 16·E_{Q_A}[Σ_j h_j].

*Proof.* Use the representation 0.3: X_0 = ω₀, X_j = y_j ∈ Y′, with kernels a_j and b_j. At a step j after the run has stopped both kernels are the point mass at ∅ and contribute h = 0; at a step j ≤ len(τ) the contribution is h_j(τ). Whether the run has stopped at step j is a function of X_<j and is the same function for both answerers. Theorem 2.1(b),(c) and Lemma 1.1(1),(5) give the four statements. ∎

So runs of variable length, inputs that depend on the earlier answers, and answerers that do or do not see the history are all covered; the expectation is under the run of one of the two answerers, and H² is symmetric, so either may be chosen.

### 2.3 Two complements

**Proposition 2.4 (inputs that do not depend on the answers).** In the setting of Theorem 2.1 suppose p_i(·|x_<i) and q_i(·|x_<i) depend on x_0 only. Then H²(P,Q) = E[1 − Π_i(1 − h_i(X_0))] ≤ E[Σ_i h_i(X_0)], the expectation being over X_0 ~ μ₀. In particular, if next_j depends on ω₀ only and S, S′ are samplers, then H²(Q_S, Q_S′) ≤ E_{μ₀}[Σ_j H²(S,S′)(x_j)]: the constant in L4 is 1.

*Proof.* Given X_0 = x_0 both laws are product measures, with BC equal to Π_i(1 − h_i(x_0)); and 1 − Π_i(1 − h_i) ≤ Σ_i h_i. ∎

**Proposition 2.5 (converse, with a factor n).** In the setting of Theorem 2.1, E_P[h_i] + E_Q[h_i] ≤ 2·H²(P,Q) for every i; hence E_P[Σ_i h_i] ≤ 2n·H²(P,Q), and for answerers E_{Q_A}[Σ_j h_j] ≤ 2L·H²(Q_A, Q_B). The factor n cannot be replaced by a constant.

*Proof.* Let P_i, Q_i be the laws of X_≤i under P and Q, with densities P_<i·p_i and Q_<i·q_i. Then BC(P_i, Q_i) = ∫μ₀ Σ_{x_<i} √(P_<i·Q_<i)·(1 − h_i(x_<i)) ≤ ∫μ₀ Σ_{x_<i} ½(P_<i + Q_<i)(1 − h_i(x_<i)) = 1 − ½E_P[h_i] − ½E_Q[h_i]. So E_P[h_i] + E_Q[h_i] ≤ 2H²(P_i, Q_i) ≤ 2H²(P,Q), the last step by Lemma 1.1(4), since X_≤i is an image of the whole sequence. (In its one-sided form for two variables, E_P[h] ≤ 2H², this is a lemma of the paper of item 3 of Section 2.1, and with the constant 4 of the paper of item 1; both read in source.) For the last claim take the scaffold: call 1 at x_0 with answers in {0,1}; after the answer 1, n − 1 further calls at x_1, …, x_(n−1); after the answer 0, stop. Let S(1|x_0) = ε, S′(1|x_0) = 0, S(·|x_i) = point mass at 0 and S′(·|x_i) = point mass at 1 for i ≥ 1. Then H²(Q_S, Q_S′) = 1 − √(1−ε) ≤ ε and E_{Q_S}[Σ_j h_j] = 1 − √(1−ε) + ε(n−1) ≥ (n−1)·H²(Q_S, Q_S′). ∎

Proposition 2.5 says what whole-run closeness of two samplers does *not* give: closeness of single calls along the run of one of them, except with a factor L. In the example S′ never enters the branch in which it differs from S at every call.

### 2.4 The best constant

Write c₀* for the smallest constant for which Theorem 2.1(c) holds for all n and all kernels. Theorem 2.1(c) says c₀* ≤ 4; by Proposition 2.4 the constant 1 suffices without adaptivity, and by Theorem 2.1(b) the constant 1 suffices for the two-sided bound. This subsection determines c₀* up to the fourth digit: Theorem 2.7 proves c₀* ≤ c* = 2.9641, and explicit examples give c₀* ≥ 1.7071 (exact, two calls) and c₀* ≥ 2.9639 (many calls, evaluated in floating point). The rest of this file uses the constant 4 of Theorem 2.1, whose proof is ten lines; Theorem 2.7 allows 4 to be replaced by c* everywhere.

**Example 2.6 (two calls; c₀* ≥ (2+√2)/2 = 1.7071).** Scaffold: call 1 at x_0 with answers in {0,1}; after the answer 1, call 2 at x_1; after 0, stop. Samplers: S(1|x_0) = a, S′(1|x_0) = b, S(·|x_1) = point mass at 0, S′(·|x_1) = point mass at 1. The possible runs are (0), (1,0), (1,1), with S-probabilities 1−a, a, 0 and S′-probabilities 1−b, 0, b. So H²(Q_S, Q_S′) = 1 − √((1−a)(1−b)), while E_{Q_S}[Σ_j h_j] = h_1 + a with h_1 = 1 − √((1−a)(1−b)) − √(ab). With a = ε and b = s²ε, as ε → 0: H² = ½(1+s²)ε + O(ε²) and E_{Q_S}[Σ_j h_j] = ½(s² − 2s + 3)ε + O(ε²). The ratio tends to (s²+1)/(s²−2s+3), which is largest at s = 1+√2, where it equals (s+1)/2 = (2+√2)/2. (Section 7, script `hellinger-runs_l4_check.py`, part (d): ratio 1.70710 at ε = 10⁻⁵.) ∎

**Theorem 2.7 (the constant c* < 3).** For q ≥ 0 let g(q) := 1 + q·e^(q²/4)·(1/√2 + (√π/2)·erf(q/2)) and, for 0 ≤ q < √2, k(q) := 1/(1 − q²/2). Let q₀ be the smallest positive root of g = k, and c* := k(q₀) = 1/(1 − q₀²/2). Then, in the setting of Theorem 2.1,

 H²(P,Q) ≤ c*·E_P[Σ_{i=1}^n h_i],

and Corollary 2.3 holds with c* in place of 4 (and 2c*, 4c* in place of 8, 16). Numerically q₀ = 1.151204 and c* = 2.964147. (g − k is positive near 0, since g(q) − k(q) = q/√2 + O(q²), and it is +0.00136 at q = 1.151 and −0.00536 at q = 1.152 in double precision; so a root exists, q₀ < 1.152 and c* < k(1.152) = 2.9723.)

*Proof.* Write c for c*. *Step 0: three functions.* For q ∈ (0, q₀] put s(q) := 1/g(q), p(q) := 2(1 − s(q))/q and r(q) := (p(q) − q)/2. Differentiating, g′(q) = (g(q) − 1)(1/q + q/2) + q/2 > 0. Hence:

(i) s is strictly decreasing, s(q) → 1 as q → 0, and s(q₀) = 1/c = 1 − q₀²/2 =: s₀. Also p(q) → √2 and r(q) → 1/√2 as q → 0.
(ii) r ≥ 0 on (0, q₀] and r(q₀) = 0: indeed r ≥ 0 is equivalent to s ≤ 1 − q²/2, that is to g ≥ k, which holds on (0, q₀] with equality at q₀ by the choice of q₀.
(iii) ds/dq = −g′/g² = −(s/(2q))·(2(1−s) + q²); dp/dq = (q²s − 2(1−s)²)/q²; therefore d(p/s)/dq = (s·dp/dq − p·ds/dq)/s² = 1/s > 0, and dr/dq = ½(dp/dq − 1) = −(1−s)(q² + 2(1−s))/(2q²), so that (dr/dq)/(ds/dq) = (1−s)/(sq) = p/(2s).

So q, p and r may be regarded as continuous functions of s ∈ [s₀, 1] (with q(1) = 0, p(1) = √2, r(1) = 1/√2), differentiable on (s₀, 1), with

 p·q = 2(1−s), p − q = 2r ≥ 0, dr/ds = p/(2s), and s ↦ p(s)/s strictly decreasing.

(iv) For s, s′ ∈ [s₀, 1]: φ(s, s′) := p(s)·s′ − s·q(s) − 2s·r(s′) ≥ 0. Indeed φ(s, s) = s(p − q − 2r) = 0, and ∂φ/∂s′ = p(s) − s·p(s′)/s′ = s·(p(s)/s − p(s′)/s′), which is ≤ 0 for s′ < s and ≥ 0 for s′ > s.
(v) For s ∈ [s₀, 1] and s′ ≥ 1: ψ(s, s′) := p(s)·s′ − s·q(s) − 2s·√(s′ − ½) ≥ 0. Indeed ψ(s, 1) = φ(s, 1) ≥ 0 because r(1) = 1/√2, and ∂ψ/∂s′ = p(s) − s/√(s′ − ½) ≥ p(s) − √2·s = s·(p(s)/s − p(1)/1) ≥ 0.

*Step 1: the potential.* Let V(x) := 0 for 0 ≤ x ≤ 1, V(x) := c·r(x/c)² for 1 ≤ x ≤ c, V(x) := x − c/2 for x ≥ c, and U(x) := V(x) − x. V is continuous (r(s₀) = 0 and c·r(1)² = c/2), V ≥ 0 = V(1), and U is bounded.

*Step 2: for every Λ > 0 there is μ ≥ 0 with U(a) ≤ U(Λ) + c(1 − a/Λ) + μ(a²/Λ² − 1) for all a ≥ 0.* Equivalently V(a) ≤ τ_Λ(a) := U(Λ) + c(1 − a/Λ) + μ(a²/Λ² − 1) + a. We choose μ and compute τ_Λ in three ranges.

* Λ ≤ 1: μ := (c − Λ)/2. With U(Λ) = −Λ one finds τ_Λ(a) = ((c−Λ)/(2Λ²))·(a − Λ)².
* 1 ≤ Λ ≤ c, s := Λ/c: μ := c·p(s)²/4. With U(Λ) = c·r² − cs, the coefficients of τ_Λ(a) are p²/(4cs²) for a², 1 − 1/s = −pq/(2s) for a, and c(r² + 1 − s − p²/4) = c·q²/4 for the constant (use pq = 2(1−s) and p − q = 2r). So τ_Λ(a) = (c/(4s²))·(p(s)·a/c − s·q(s))².
* Λ ≥ c: μ := c/2. With U(Λ) = −c/2, τ_Λ(a) = a(1 − c/Λ) + c·a²/(2Λ²).

(At Λ = 1 and at Λ = c the two applicable formulas agree, because p(s₀) = q(s₀) = q₀ with q₀² = 2(c−1)/c, and p(1) = √2, q(1) = 0.) Now let a ≥ 0.

*a ≤ 1.* V(a) = 0, and τ_Λ(a) ≥ 0 in all three ranges (a square in the first two; in the third because Λ ≥ c).
*1 ≤ a ≤ c, with s′ := a/c ∈ [s₀, 1].* For 1 ≤ Λ ≤ c, by (iv), p(s)·s′ − s·q(s) ≥ 2s·r(s′) ≥ 0, hence τ_Λ(a) = (c/(4s²))(p(s)s′ − sq(s))² ≥ c·r(s′)² = V(a). For Λ ≤ 1, the three positive factors of τ_Λ(a) are decreasing in Λ (as a ≥ 1 ≥ Λ), so τ_Λ(a) ≥ τ_1(a) ≥ V(a). For Λ ≥ c, ∂τ_Λ(a)/∂Λ = (c·a/Λ²)(1 − a/Λ) ≥ 0, so τ_Λ(a) ≥ τ_c(a) ≥ V(a).
*a ≥ c, with s′ := a/c ≥ 1.* For 1 ≤ Λ ≤ c, by (v), p(s)s′ − sq(s) ≥ 2s·√(s′ − ½) ≥ 0, hence τ_Λ(a) ≥ c(s′ − ½) = a − c/2 = V(a). For Λ ≤ 1 again τ_Λ(a) ≥ τ_1(a) ≥ V(a). For Λ ≥ c, τ_Λ(a) − V(a) = (c/2)(1 − a/Λ)² ≥ 0.

*Step 3: conclusion.* Let Λ ≥ 0 be a number and r̃ ≥ 0 a random variable with E r̃² ≤ 1. For Λ > 0, Step 2 with a = Λ·r̃ and expectations give E U(Λr̃) ≤ U(Λ) + c(1 − E r̃) + μ(E r̃² − 1) ≤ U(Λ) + c(1 − E r̃); for Λ = 0 this is trivial. This is Lemma 2.2(ii) with (U, c) in place of (½(2−x)₊², 4). As in the proof of Theorem 2.1(c), E_P U(Λ_n) ≤ U(1) + c·E_P Σ_i h_i; and since V ≥ 0 = V(1), U(x) ≥ U(1) + 1 − x, so E_P U(Λ_n) ≥ U(1) + 1 − E_P Λ_n = U(1) + H²(P,Q). ∎

**Example 2.8 (many calls; computed ratios 2.0997 and 2.9639).** Both examples are pairs of samplers on a scaffold whose input at each call is a "level" k, a function of the earlier answers.

(i) *A lattice walk.* Fix β > 1 and an integer m. The level starts at 0. At a level 0 ≤ k < m the answer is "up" or "down" and the level moves to k ± 1; S answers "up" with probability 1/(1+β²), S′ with probability β²/(1+β²). The run stops when the level reaches −1. At level m there is one last call, at which S and S′ answer with different point masses. The root likelihood ratio Λ is β^k at level k, each call below level m has h = (β−1)²/(1+β²), and with π := (β²−1)/(β^(2m+2) − 1) (the S-probability of reaching level m, from the martingale Λ²):
 H²(Q_S, Q_S′) = 1 − (1−π)/β,  E_{Q_S}[Σ_j h_j] = ((β−1)/(β+1))·((1−π) − mπ) + π.
(For an unbounded horizon; the truncation to L calls converges to these values as L grows.) As β → 1 with β^m = b fixed the ratio tends to 2(b²+1)/(b² + 3 − 2 ln b), with maximum 2.0997 at b = 4.59. (Section 7, part (e).)

(ii) *The drift-and-drop strategy for which the proof of Theorem 2.7 is tight.* Fix β > 1. At level k = 0, 1, 2, … the answer is "up" (the level becomes k+1) or "drop" (the run stops). With numbers d_k ∈ [0,1) and π_k := (β²−1)/(β²−d_k²), let S answer "drop" with probability π_k and S′ with probability π_k·d_k² (then S′ answers "up" with probability (1−π_k)β²). The root likelihood ratio is β^k at level k, and by Theorem 2.1(a), with R_k := Π_{i<k}(1−π_i) and h_k = 1 − π_k d_k − (1−π_k)β,
 H²(Q_S, Q_S′) = Σ_k R_k β^k h_k,  E_{Q_S}[Σ_j h_j] = Σ_k R_k h_k.
Take d_k := q(s)/p(s) at s = β^k/c* in the notation of Theorem 2.7 when 1 < β^k < c*, d_k := 0 when β^k ≥ c*, and d_0 := β^(−0.01). (A drop from the level Λ = c*·s leads to the level Λ·q/p, which is at most 1 by (iv) with s′ = s₀ and is the point at which the parabola τ_Λ vanishes; so in the limit β → 1 every step is an equality case of Step 2.) With β = 1.0001 and the run truncated when β^k exceeds 10⁶ (138163 levels), the computed ratio is 2.96399. (Section 7, script `hellinger-runs_l4_lp.py`, part (D). The sums have positive terms and were evaluated in double precision.)

So 2.9639 ≤ c₀* ≤ c* = 2.9641, the lower bound being a floating-point evaluation of an explicit example. I expect c₀* = c*; a proof would have to show that the ratio of the strategy (ii) converges to c* as β → 1 and the truncation level grows, which the computation indicates (2.82407, 2.94927, 2.96265, 2.96399 for β = 1.1, 1.01, 1.001, 1.0001) but which is not proved here. As a further check, a linear programme for the best pair (U, c) against adversaries restricted to a geometric grid of ratio u gives 2.827, 2.864, 2.890, 2.906 for u = 1.05, 1.035, 1.025, 1.018 (Section 7).

**Remark 2.9 (the route sketched in the candidate theory).** The inequality quoted there is correct: for 0 ≤ g ≤ R, E_Q g − E_P g = Σ g(√q − √p)(√q + √p) ≤ √(2R·H²)·√(2(E_P g + E_Q g)) ≤ η(E_P g + E_Q g) + R·H²/η for every η ∈ (0,1), so E_Q g ≤ ((1+η)/(1−η))·E_P g + R·H²(P,Q)/(η(1−η)), which is (5/3)E_P g + (16/3)R·H² at η = ¼. Stopping the sequence before the predictable sum Σ h_i exceeds a threshold θ, and treating the stopped part with Theorem 2.1(b) and this inequality, also proves the lemma; my accounting of that route gave the constant 1/(1−√(2θ)) + 1/θ + √(2/(θ(1−√(2θ)))), about 12.6 at θ = ¼. That proof is not written out here and is not used.

## 3. Theorem R2: whole runs under the rehearsal protocol

### 3.1 The upper bound

**Protocol R** (candidate theory, Section 3). For t = 1, …, n: (1) M^(t) := M_{D_(t−1)}, the mixture given the pairs collected before round t; (2) a run τ_t of Π is generated with the sampler M^(t) answering every call, with fresh randomness; (3) J_t is drawn uniformly from {1, …, L}, independently of everything else; if J_t ≤ len(τ_t), the input x_(t,J_t) of call J_t is put to the human, who answers y ~ P(·|x_(t,J_t)), and the pair is added to the data. Deployment: T is uniform on {1, …, n} and independent of everything else, and Π is run with M^(T).

**Theorem R1** (candidate theory; proof in Appendix A). Under A1, A2, A3, with E denoting the expectation over the data,
 Σ_{t=1}^n E[E_{Q_{M^(t)}} Σ_j KL(P ‖ M^(t))(x_j)] ≤ L·K ln2.
Here KL(P‖M^(t))(x) ≤ ln(1/w_{D_(t−1)}(P)) < ∞ for every x, so every term is finite.

**Theorem 3.1 (R2).** Under A1, A2, A3 and Protocol R, with E the expectation over the data and T:

(a) E[H²(Q_{M^(T)}, Q_P)] ≤ 2LK ln2/n.
(b) E[TV(Q_{M^(T)}, Q_P)] ≤ √(b(2−b)) ≤ 2·√(LK ln2/n), where b := min(1, 2LK ln2/n).
(c) For every event G of runs and every η > 0: E[Q_{M^(T)}(G)] ≤ (1+η)·Q_P(G) + (1+1/η)·4LK ln2/n. In particular E[Q_{M^(T)}(G)] ≤ 2Q_P(G) + 8LK ln2/n, and if Q_P(G) = 0 then E[Q_{M^(T)}(G)] ≤ 4LK ln2/n.
(d) If the inputs of Π do not depend on the answers (next_j is a function of ω₀ only), (a)–(c) hold with LK ln2/n replaced by ¼·LK ln2/n; for example E[TV] ≤ √(LK ln2/n).
(e) (The case of a function, restated from the candidate theory.) If P is a function f, the deployed run and the run of the human system on the same ω₀ differ with probability at most LK ln2/n.

*Proof.* (a) Fix t and the data D_(t−1); then M^(t) is a fixed sampler. Corollary 2.3 with A = M^(t), B = P and Lemma 1.1(2) give
 H²(Q_{M^(t)}, Q_P) ≤ 4·E_{Q_{M^(t)}} Σ_j H²(M^(t), P)(x_j) ≤ 2·E_{Q_{M^(t)}} Σ_j KL(P‖M^(t))(x_j).
Take the expectation over the data and average over t; by R1 the result is at most 2LK ln2/n. (b) By Lemma 1.1(1) and (6), and because H² ≤ 1. (c) Lemma 1.1(5) for each value of the data and of T, then (a). (d) Proposition 2.4 replaces the factor 4 of Corollary 2.3 by 1. (e) For a function, KL(P‖M)(x) = −ln M(f(x)|x) ≥ 1 − M(f(x)|x), the probability that a draw from M(·|x) differs from f(x). Run Π with M^(t) and, on the same ω₀, with f. The two runs coincide unless at some call of the M^(t)-run the draw differs from f(x_j); by the union bound over the calls this has probability at most E_{Q_{M^(t)}} Σ_j (1 − M^(t)(f(x_j)|x_j)). Average over t and use R1. ∎

**Remark 3.2 (what is deployed, and with what confidence).** (i) If T is drawn afresh for each deployed run, the law of a deployed run given the data is the average Q̄ := (1/n) Σ_t Q_{M^(t)}; by convexity (Lemma 1.1(4)), H²(Q̄, Q_P) ≤ (1/n) Σ_t H²(Q_{M^(t)}, Q_P), so (a)–(c) hold for Q̄ with the expectation over the data only. (ii) If T is drawn once and M^(T) is used for good, (a) and Markov's inequality give: with probability at least 1 − δ over the data and T, H²(Q_{M^(T)}, Q_P) ≤ 2LK ln2/(nδ), and then every later run has a law within total variation 2·√(LK ln2/(nδ)) of Q_P. (iii) The bound is on each single run. For m independent deployed runs with the same M^(T), BC is multiplicative, so the joint laws have H² = 1 − (1 − H²(Q_{M^(T)}, Q_P))^m ≤ m·H²(Q_{M^(T)}, Q_P); the m runs together are close to m runs of the human system only while m·LK/n is small.

**Remark 3.3 (what L4 buys, and the human outside the class).** (i) Without L4, the hybrid bound TV(Q_A, Q_B) ≤ E_{Q_A} Σ_j TV(A,B)(history_j) (Lemma 4.5 below) with Pinsker's inequality and the Cauchy–Schwarz inequality gives E TV ≤ L·√(K ln2/(2n)). Theorem 3.1(b) is smaller by the factor √L/(2√2). (ii) If A2 fails, the proof of R1 gives, for every ν* ∈ H, (1/n) Σ_t E[E_{Q_{M^(t)}} Σ_j KL(P‖M^(t))(x_j)] ≤ L·ln(1/w(ν*))/n + (1/n) Σ_t E[E_{Q_{M^(t)}} Σ_j KL(P‖ν*)(x_j)] (Appendix A, last paragraph), so (a) becomes E H² ≤ 2L·[ln(1/w(ν*))/n + sup_x KL(P‖ν*)(x)]. The approximation error is measured on the inputs that the imitators themselves visit, which are not known in advance; hence the supremum. (iii) With Theorem 2.7 in place of Theorem 2.1(c) the constants of Theorem 3.1 improve: E H² ≤ (c*/2)·LK ln2/n ≤ 1.49·LK ln2/n, E TV ≤ √(c*·LK ln2/n) ≤ 1.73·√(LK ln2/n), and E Q_{M^(T)}(G) ≤ c*·LK ln2/n ≤ 2.97·LK ln2/n for an event with Q_P(G) = 0.

### 3.2 The lower bound

**Lemma 3.4a (two coins of opposite bias).** For an odd integer N ≥ 3 and δ ∈ (0, ½) with (N−1)δ² ≤ ¼,
 G(N, δ) := TV(Bern(½+δ)^⊗N, Bern(½−δ)^⊗N) ≥ δ·√(N/2).
G(N, δ) is non-decreasing in N.

*Proof.* Let N = 2k − 1 and let S be the number of ones. For S ~ Bin(N, p), (d/dp) Pr_p[S ≥ k] = N·C(N−1, k−1)·p^(k−1)(1−p)^(N−k) (differentiate the sum term by term; it telescopes). Here N − k = k − 1, and p(1−p) ≥ ¼ − δ² on [½−δ, ½+δ]. With j := k − 1 = (N−1)/2 ≥ 1 and the bound C(2j, j) ≥ 4^j/(2√j) (by induction on j: the ratio of consecutive central binomial coefficients is 2(2j+1)/(j+1) ≥ 4√j/√(j+1)),
 G ≥ Pr_(½+δ)[S ≥ k] − Pr_(½−δ)[S ≥ k] ≥ 2δ·N·C(2j, j)·4^(−j)·(1−4δ²)^j ≥ (δN/√j)·(1 − 4jδ²) ≥ δ·√(2N)·½,
using N/√j ≥ √(2N) and 4jδ² = 2(N−1)δ² ≤ ½. Monotonicity in N is Lemma 1.1(4) applied to the projection on the first N − 1 coordinates. ∎

**Proposition 3.4 (K coins: about LK/ε² questions are necessary).** Let K ≥ 8 and m ≥ 4 be integers, L := Km, and δ ∈ (0, ¼] with Lδ² ≤ 1. Let X = {1, …, K}, and for θ ∈ {−1, +1}^K let P_θ be the sampler with P_θ(1|i) = ½ + θ_i δ and P_θ(0|i) = ½ − θ_i δ. The class H_K := {P_θ} has the uniform weights 2^(−K), so log₂(1/w) = K for every member. The scaffold Π_K makes L calls, and call j has the input 1 + ((j−1) mod K) whatever the answers; so every input is asked m times. A *protocol* puts at most n questions to the human: each question is an element of X, chosen as a function of the earlier questions and answers and of randomness independent of the human's coins, and it is answered by an independent draw from P_θ(·|question). After that the protocol deploys an answerer of its choice; Q̂ denotes the law of the deployed run. If

 n ≤ K(1 − 4δ²)/(16δ²),

then the average over θ of E_θ[TV(Q̂, Q_{P_θ})] is at least δ·√L/65. Consequently, for every ε ∈ (0, 1/65]: every protocol with n ≤ LK/(8·10⁴·ε²) questions has E_θ[TV(Q̂, Q_{P_θ})] ≥ ε for some member P_θ of H_K (take δ := 65ε/√L).

*Proof.* Write Q_θ for Q_{P_θ}; since the inputs are fixed, a run is the vector of its L answers and Q_θ is a product of L Bernoulli laws. *Step 1 (from a law to a parameter).* Let θ̂ minimise θ′ ↦ TV(Q̂, Q_θ′). Then TV(Q_θ̂, Q_θ) ≤ 2·TV(Q̂, Q_θ). If θ̂ and θ differ in r coordinates, then TV(Q_θ̂, Q_θ) = G(rm, δ): the coordinates of the run that belong to inputs where θ̂ and θ agree are identical independent factors, and on the remaining rm coordinates a relabelling of the answers turns the two laws into Bern(½+δ)^⊗rm and Bern(½−δ)^⊗rm. *Step 2 (many coordinates are wrong).* Let d be the number of coordinates in which θ̂ and θ differ, and let ℙ_θ be the law of everything the protocol sees (its randomness, questions and answers); θ̂ is a function of it. For a coordinate i and a choice of the other coordinates write θ^(i+), θ^(i−) for the two completions. Then ½·ℙ_θ^(i+)[θ̂_i ≠ +1] + ½·ℙ_θ^(i−)[θ̂_i ≠ −1] ≥ ½(1 − TV(ℙ_θ^(i+), ℙ_θ^(i−))). By Pinsker's inequality in both directions and the chain rule for KL (the two laws differ only in the answers to questions at input i, each of which contributes κ := KL(Bern(½+δ)‖Bern(½−δ)) = 2δ·ln((1+2δ)/(1−2δ)) ≤ 8δ²/(1−4δ²)), TV(ℙ_θ^(i+), ℙ_θ^(i−))² ≤ (κ/4)(E_θ^(i+)[N_i] + E_θ^(i−)[N_i]), N_i being the number of questions at input i. Averaging over i and the other coordinates, with Jensen's inequality for the square root and Σ_i N_i ≤ n, the average of E_θ[d] over θ is at least (K/2)(1 − √(κn/(2K))) ≥ K/4 under the hypothesis on n. *Step 3.* Since d ≤ K, the average over θ of ℙ_θ[d ≥ K/8] is at least (¼ − ⅛)/(1 − ⅛) = 1/7. On this event d ≥ r₀ := ⌈K/8⌉, and N := r₀m satisfies L/8 ≤ N ≤ L/4 (as K ≥ 8), so N ≥ 4 and Nδ² ≤ ¼. By Lemma 3.4a applied to N or N − 1, whichever is odd, G(dm, δ) ≥ G(N, δ) ≥ δ·√((N−1)/2) ≥ δ·√(3N/8) ≥ δ·√(3L/64). With Step 1 the average of E_θ[TV(Q̂, Q_θ)] is at least (1/7)·½·δ·√(3L/64) ≥ δ·√L/65. *The consequence.* With δ = 65ε/√L we have Lδ² ≤ 1 and δ² ≤ 1/32, so K(1−4δ²)/(16δ²) ≥ (7/8)·KL/(16·4225·ε²) ≥ KL/(8·10⁴·ε²). ∎

The questions of the protocol may be chosen in any way; in particular the protocol may record whole runs of the human system. So Proposition 3.4 also bounds from below the number N·L of answers used by Theorem A.

**Proposition 3.5 (two coins: the factor L/ε² without the factor K).** Let L ≥ 3 be odd, ε ∈ (0, 1/12] and a := 4ε·√(2/L). Let X = {x}, let P₊ and P₋ be the samplers with P_±(1|x) = ½ ± a, and let the scaffold make L calls at x. For every protocol (in the sense of Proposition 3.4) with n ≤ L/(740·ε²) questions, E[TV(Q̂, Q_P)] ≥ ε for P = P₊ or for P = P₋.

*Proof.* Write Q_± and ℙ_± for the run laws and for the laws of what the protocol sees. For every value of the data, TV(Q̂, Q₊) + TV(Q̂, Q₋) ≥ TV(Q₊, Q₋) = G(L, a). Since ∫f₊ dℙ₊ + ∫f₋ dℙ₋ ≥ ∫(f₊ + f₋) d min(ℙ₊, ℙ₋) for non-negative f_±, it follows that E₊[TV(Q̂, Q₊)] + E₋[TV(Q̂, Q₋)] ≥ G(L, a)·(1 − TV(ℙ₊, ℙ₋)). Here (L−1)a² ≤ 32ε² ≤ ¼, so G(L, a) ≥ a·√(L/2) = 4ε by Lemma 3.4a. By Pinsker's inequality and the chain rule, TV(ℙ₊, ℙ₋)² ≤ nκ/2 ≤ 4na²/(1−4a²) with κ as in the proof of Proposition 3.4; and 4a² = 128ε²/L ≤ 0.3, so TV(ℙ₊, ℙ₋)² ≤ 183·nε²/L ≤ ¼ when n ≤ L/(740ε²). The sum of the two expectations is then at least 2ε. ∎

Two independent derivations of the same kind appeared while this file was written; I did not check their proofs. The digest `understand/imitation-theory.md` (its LB3) has (L−1)/(2048·ε²) for the two samplers of Proposition 3.5 under a slightly different criterion. The file `research/prove/lower-bounds.md` (its Theorem 6.3) has L·K/(8192·ε²) for the 2^K coins on a different scaffold (one input drawn at random and asked L times), which is a better constant than that of Proposition 3.4.

### 3.3 Is the factor √L necessary? What the truth is

Yes. Already for two samplers, expected whole-run total variation ε needs more than L/(740·ε²) questions (Proposition 3.5). For the class and scaffold of Proposition 3.4, expected whole-run total variation ε for every member needs more than LK/(8·10⁴·ε²) questions, and Theorem 3.1(d) shows that LK ln2/ε² questions of Protocol R suffice (4LK ln2/ε² on an adaptive scaffold). So, in the worst case over classes and scaffolds, the number of single questions needed for whole-run total variation ε with a stochastic human is of order LK/ε², and R2 is optimal up to an absolute constant (about 5·10⁴ between the two bounds, most of it lost in the proof of the lower bound, which was not optimised; about 6·10³ with the constant of `research/prove/lower-bounds.md`). The reason is statistical and has nothing to do with compounding errors: a run of L calls is a sample of size up to L from the human, and a sample of that size detects a per-call discrepancy of order 1/√L.

| human | guarantee after n questions of Protocol R | questions for accuracy ε | lower bound |
|---|---|---|---|
| a function | the deployed run differs from the human system's with probability ≤ LK ln2/n (Theorem 3.1(e)) | LK ln2/ε | L/(2ε) for some class with K ≤ log₂(L/ε) + c (candidate theory, N2; not checked here) |
| a sampler | E TV ≤ 2·√(LK ln2/n) (Theorem 3.1(b)) | 4LK ln2/ε² | LK/(8·10⁴·ε²) for the K coins (Proposition 3.4); L/(740·ε²) for two samplers (Proposition 3.5) |
| a sampler, event G with Q_P(G) = 0 | E Q_{M^(T)}(G) ≤ 4LK ln2/n (Theorem 3.1(c)) | 4LK ln2/ε | |

Four qualifications. (1) The lower bound is for one class; for a given class the truth can be smaller (for a class of functions LK ln2/ε questions suffice, by Theorem 3.1(e)). (2) The square-root rate is the price of *all* events at once. For an event that the human system produces with probability zero, or with small probability, Theorem 3.1(c) gives the rate LK/n of the deterministic case, up to the factor 4. (3) The expected *number* of unfaithful calls in the coupling of the candidate's L2 is bounded by L·√(K ln2/(2n)) (candidate theory, R3), and for the K coins with δ of order √(K/n) this order is attained (the signs cannot then be learned from n questions, and each call of the mixture is at total variation of order δ from the human's; this is the reasoning of Proposition 3.4 and is not written out). So for a stochastic human the per-call count is of order L·√(K/n) while the whole-run distance is of order √(LK/n). (4) *Which criterion.* Theorem 3.1 and Propositions 3.4 and 3.5 are about E[TV(Q_{M^(T)}, Q_P)]: the distance between the run law of the trained imitator and the human system, averaged over the training data. The weaker criterion TV(E[Q_{M^(T)}], Q_P) describes one deployed run averaged over the training randomness as well. It can be much smaller (the digest `understand/imitation-theory.md`, §5.8, gives an example with L/n in place of √(L/n)), and for one run of the scaffold of Proposition 3.4 it is met exactly with L questions: ask each input of the run once and replay the answers. An imitator is trained in order to be run many times on the same data; its runs then share the training error, and the first criterion is the relevant one.

## 4. Theorem A: recorded runs of the human system, a posterior draw per run

### 4.1 Runs and pairs

**Lemma 4.1 (the likelihood of a run).** For a sampler ν the density of Q_ν with respect to μ₀ ⊗ counting measure is q_ν(τ) = Π_{j ≤ len(τ)} ν(y_j|x_j), with x_j = next_j(ω₀, y_<j), on the sequences that the scaffold can produce (those with y_j = ∅ exactly for j > len(τ)), and 0 elsewhere. Consequently, for runs τ_1, …, τ_N the posterior over H given the runs,
 w(ν)·Π_s q_ν(τ_s) / Σ_ν′ w(ν′)·Π_s q_ν′(τ_s),
equals the posterior w_D of 0.5 given the collection D of all pairs (x_(s,j), y_(s,j)) of these runs. The same holds if only the transcripts ((x_j, y_j))_{j ≤ len(τ)} are recorded and ω₀ is not: the probability of a transcript under Q_ν is c·Π_j ν(y_j|x_j), where c = μ₀{ω₀ : next_j(ω₀, y_<j) = x_j for all j ≤ len, and the scaffold stops after these calls} does not depend on ν.

*Proof.* The first statement is 0.3 for a sampler. The factors that do not involve ν (the density 1 of ω₀ with respect to μ₀, the indicator of consistency, or the constant c) cancel in the posterior. ∎

So "the posterior given runs" and "the posterior given pairs" are the same object; what distinguishes the settings of this file is only how the questions are generated.

### 4.2 The theorem

**Setting.** τ_1, τ_2, … are independent runs of the scaffold with a common law Q* whose marginal on Ω₀ is μ₀ and whose density with respect to μ₀ ⊗ counting measure is q*. Under A1 with the human P this is Q* = Q_P; nothing else is assumed about Q* (the human may be outside H, and may even have a memory within a run, as long as the runs are independent). Put ξ_t := Σ_ν w(ν)·Π_{s<t} q_ν(τ_s), let w_(t−1) be the posterior given τ_1, …, τ_(t−1) (defined when ξ_t > 0), and

 Q̂_t := Σ_ν w_(t−1)(ν)·Q_ν, with density q̂_t = Σ_ν w_(t−1)(ν)·q_ν.

Q̂_t is the law of a run in which one hypothesis ν is drawn from the posterior w_(t−1) and answers every call. The imitation of the candidate theory draws t uniformly from {1, …, N} and then ν from w_(t−1); given the data its run has the law Q̂ := (1/N) Σ_{t ≤ N} Q̂_t.

**Theorem 4.2 (Theorem A).** For every ν* ∈ H put ρ_N(ν*) := ln(1/w(ν*))/N + KL(Q* ‖ Q_ν*). Then, with E the expectation over the recorded runs:

(a) Σ_{t=1}^N E[KL(Q* ‖ Q̂_t)] ≤ ln(1/w(ν*)) + N·KL(Q* ‖ Q_ν*).
(b) E[KL(Q* ‖ Q̂)] ≤ ρ_N(ν*), E[TV(Q̂, Q*)] ≤ √(ρ_N(ν*)/2), E[H²(Q̂, Q*)] ≤ ρ_N(ν*)/2, and E[Q̂(G)] ≤ 2Q*(G) + 2ρ_N(ν*) for every event G of runs. The same four bounds hold for Q̂_t with t drawn once and uniformly (expectation over t as well).
(c) Under A1 and A2 (Q* = Q_P, P ∈ H): E[KL(Q_P ‖ Q̂)] ≤ K ln2/N and E[TV(Q̂, Q_P)] ≤ √(K ln2/(2N)).
(d) For a stateless human P (A1) and a sampler ν*, KL(Q_P ‖ Q_ν*) = E_{Q_P}[Σ_j KL(P‖ν*)(x_j)]: the approximation error is the per-call divergence summed along the human system's own runs.

*Proof.* (a) If KL(Q*‖Q_ν*) = ∞ there is nothing to prove. Otherwise q_ν*(τ_s) > 0 almost surely, so ξ_t ≥ w(ν*)·Π_{s<t} q_ν*(τ_s) > 0 for all t, the posteriors are defined, and ξ_(t+1) = ξ_t·q̂_t(τ_t). With W := ξ_1 = Σ_ν w(ν) ≤ 1 this gives, on every path,
 Σ_{t ≤ N} ln(q*(τ_t)/q̂_t(τ_t)) = ln(Π_t q*(τ_t)/ξ_(N+1)) + ln W ≤ ln(1/w(ν*)) + Σ_{t ≤ N} ln(q*(τ_t)/q_ν*(τ_t)).
Given τ_<t the run τ_t has law Q*, so the conditional expectation of ln(q*(τ_t)/q̂_t(τ_t)) is KL(Q*‖Q̂_t) ≥ 0. Each variable Z = ln(q*(τ_t)/q̂_t(τ_t)) and Z = ln(q*(τ_t)/q_ν*(τ_t)) has E[max(−Z, 0)] ≤ E[e^(−Z)]/e ≤ 1/e, so all expectations exist in (−∞, ∞] and add; taking expectations gives (a). (b) KL(Q*‖·) is convex, so KL(Q*‖Q̂) ≤ (1/N) Σ_t KL(Q*‖Q̂_t); then (a). The other three bounds follow from Lemma 1.1(3), (2), (5) and Jensen's inequality for the square root. For t drawn once, the expectation over t of KL(Q*‖Q̂_t) is (1/N) Σ_t KL(Q*‖Q̂_t). (c) Take ν* = P. (d) Lemma 4.5(i) below. ∎

**Remark 4.3 (the role of the uniformly random t).** The regret bound (a) controls the *sum* over t of the expected divergences, not any single term. Drawing t uniformly turns it into a bound on an expectation; equivalently, the deployed object is the Cesàro average of the posterior mixtures. The expected divergence is not monotone in the number of runs (Example 4.4), so the bound for the random t does not pass to "the posterior after all N runs" by monotonicity. Whether E[KL(Q_P‖Q̂_(N+1))] ≤ C·K ln2/N holds with an absolute constant C is not decided here. (For a human drawn from the normalised prior the expected divergence is non-increasing in t, by the standard fact that for conditionally independent observations the conditional mutual information I(P; τ_t | τ_<t) is non-increasing; this is not used.) Compare the remark (iii) at the end of Section 3 of the candidate theory: what is established is non-monotonicity, not the failure of a last-round bound.

**Example 4.4 (the expected divergence is not monotone).** One call per run with a fixed input and answers in {0,1}. H consists of the human P = Bern(½) with weight 0.01, of A = Bern(0.4) with weight 0.89 and of B = Bern(0.99) with weight 0.10. The exact values of E[KL(Q_P‖Q̂_(t+1))] after t = 0, 1, …, 5 recorded runs are 0.00321, 0.01058, 0.02451, 0.03794, 0.04298, 0.03988 (Section 7): after four runs the expected divergence is thirteen times what it was with no data. (An answer 1 moves posterior weight from the good approximation A to the bad one B before the human gains weight.) ∎

### 4.3 The per-call mixture in place of the draw per run

The question is whether Theorem 4.2(c) remains true if, in the imitation run, every call is answered by a fresh draw from the mixture M_t := M_{D_(t−1)} (D_(t−1) the pairs of the runs τ_<t), that is, if Q̂_t is replaced by Q_{M_t}. Section 12 of the candidate theory observes that the obvious proof fails. The statement itself fails too.

**Lemma 4.5 (chain rule and hybrid bound).** For answerers A, B on a scaffold: (i) KL(Q_A ‖ Q_B) = E_{Q_A}[Σ_j KL(A_j(·|ω₀, y_<j) ‖ B_j(·|ω₀, y_<j))], as an identity in [0, ∞]; for samplers this is the candidate's L1. (ii) TV(Q_A, Q_B) ≤ E_{Q_A}[Σ_j TV(A_j(·|ω₀, y_<j), B_j(·|ω₀, y_<j))].

*Proof.* (i) ln(q_A/q_B) = Σ_j ln(a_j/b_j), and given the past of step j the term j has conditional Q_A-expectation KL(a_j‖b_j) ≥ 0, which vanishes after the run has stopped; the negative parts are integrable as in the proof of Theorem 4.2. (ii) For k = 0, …, L let Q^(k) be the law of the run in which calls 1, …, k are answered by A and the later calls by B. Q^(k) and Q^(k−1) have the same law of the first k − 1 answers (that of Q_A), different kernels at step k, and the same kernels afterwards; so TV(Q^(k), Q^(k−1)) = E_{Q_A}[TV(a_k, b_k)(ω₀, y_<k)]. Sum over k, with Q^(L) = Q_A and Q^(0) = Q_B. ∎

**Example 4.6 (Theorem A is false for the per-call mixture).** Let B ≥ 2 and L ≥ 1 be integers. The top-level input z is uniform on {1, …, B}; the scaffold makes L calls with the inputs (z,1), …, (z,L), whatever the answers. The human is the function f ≡ 0. For b ∈ {1, …, B} the function g_b is 1 at the inputs (b, ·) and 0 elsewhere. H := {f, g_1, …, g_B} with w(f) = ½ and w(g_b) = 1/(2B); so K = 1.

Let N ≤ B/2 runs of the human system be recorded, and let v ≤ t − 1 be the number of distinct values of z among the first t − 1 of them. The hypothesis g_b has likelihood 1 if b was not visited and 0 otherwise, so the posterior weight of f is B/(2B − v) and that of each surviving g_b is ω := 1/(2B − v). Hence, for every t ≤ N and every data set:

* *One draw per run.* Q̂_t differs from Q_f only on the runs with an unvisited z, where it answers all ones with probability ω. So TV(Q̂_t, Q_f) = (B−v)ω/B ≤ 1/(2B) and KL(Q_f‖Q̂_t) = ((B−v)/B)·ln(1/(1−ω)).
* *Per-call mixture.* M_t answers 1 with probability ω at every input (z, j) with z unvisited. So TV(Q_{M_t}, Q_f) = ((B−v)/B)·(1 − (1−ω)^L) and KL(Q_f‖Q_{M_t}) = ((B−v)/B)·L·ln(1/(1−ω)) = L·KL(Q_f‖Q̂_t).

Since v < B/2 and ω ≥ 1/(2B): TV(Q_{M_t}, Q_f) ≥ ½(1 − e^(−L/(2B))) and KL(Q_f‖Q_{M_t}) ≥ L/(4B). Take B = 2N. Then for every t ≤ N,
 KL(Q_f‖Q_{M_t}) ≥ L/(8N) and TV(Q_{M_t}, Q_f) ≥ ½(1 − e^(−L/(4N))),
while Theorem 4.2(c) would require E KL ≤ ln2/N = 0.693/N and E TV ≤ √(ln2/(2N)) = 0.589/√N. The first fails as soon as L ≥ 6. The second fails as soon as L > 9.5·√N and N ≥ 4 (for L ≤ 4N use 1 − e^(−x) ≥ x/2 on [0,1], which gives TV ≥ L/(16N); for L ≥ 4N the total variation is at least ½(1 − e^(−1)) = 0.316). For example B = 200, N = 100, L = 50 gives E TV(Q_{M_t}, Q_f) = 0.087 against 0.0019 for the draw per run and 0.059 for the bound of Theorem A (Section 7). ∎

**Proposition 4.7 (what is true for the per-call mixture).** In the setting of 4.2 with Q* = Q_P and P ∈ H:

(a) If P is a function f, then Σ_{t=1}^N E[TV(Q_{M_t}, Q_f)] ≤ Σ_{t=1}^N E[E_{Q_f} Σ_j (1 − M_t(f(x_j)|x_j))] ≤ L·K ln2. So for uniformly random t, E[TV(Q_{M_t}, Q_f)] ≤ LK ln2/N.
(b) If the inputs of the scaffold do not depend on the answers, then KL(Q_P‖Q_{M_t}) ≤ L·KL(Q_P‖Q̂_t) for every t and every data set; so Σ_{t=1}^N E[KL(Q_P‖Q_{M_t})] ≤ L·K ln2, and for uniformly random t, E[TV(Q_{M_t}, Q_P)] ≤ √(LK ln2/(2N)).
(c) The factor L in (a) and (b) cannot be removed: Example 4.6 satisfies the hypotheses of both, with KL(Q_f‖Q_{M_t}) = L·KL(Q_f‖Q̂_t) and, for L ≤ 2B, TV(Q_{M_t}, Q_f) ≥ (L/4)·TV(Q̂_t, Q_f).

*Proof.* (a) By Lemma 4.5(ii) with A = f and B = M_t, TV(Q_{M_t}, Q_f) ≤ E_{Q_f}[Σ_j (1 − M_t(f(x_j)|x_j))]. For a run τ answered by f put m_t(τ) := 1 − Σ_ν w_(t−1)(ν)·Π_{i ≤ len(τ)} ν(f(x_i)|x_i) = 1 − q̂_t(τ). For every call j of τ, 1 − M_t(f(x_j)|x_j) = Σ_ν w_(t−1)(ν)(1 − ν(f(x_j)|x_j)) ≤ m_t(τ). Hence E_{Q_f}[Σ_j (1 − M_t(f(x_j)|x_j))] ≤ L·E[m_t(τ_t) | τ_<t]. On every path, Π_{t ≤ N}(1 − m_t(τ_t)) = Π_t q̂_t(τ_t) = ξ_(N+1)/W ≥ w(f), because q_f(τ_t) = 1; so Σ_t m_t(τ_t) ≤ Σ_t −ln(1 − m_t(τ_t)) ≤ ln(1/w(f)). (b) By Lemma 4.5(i), KL(Q_P‖Q_{M_t}) = E_{Q_P}[Σ_j KL(P‖M_t)(x_j)]. Fix j. Since x_j is a function of ω₀ alone, the pair (ω₀, y_j) has the law μ₀(dω₀)·P(y_j|x_j) under Q_P and the law μ₀(dω₀)·Σ_ν w_(t−1)(ν)ν(y_j|x_j) = μ₀(dω₀)·M_t(y_j|x_j) under Q̂_t. KL does not increase under the map τ ↦ (ω₀, y_j), so E_{μ₀}[KL(P‖M_t)(x_j)] ≤ KL(Q_P‖Q̂_t). Sum over j ≤ L, then use Theorem 4.2(a) and Pinsker's inequality. (c) From the formulas of Example 4.6: 1 − (1−ω)^L ≥ 1 − e^(−Lω) ≥ Lω/4 when Lω ≤ 2, and Lω ≤ 2L/(3B) ≤ 2 for L ≤ 2B (as ω ≤ 2/(3B)); so TV(Q_{M_t}, Q_f) ≥ ((B−v)/B)·Lω/4 = (L/4)·TV(Q̂_t, Q_f). ∎

**Example 4.8 (adaptive scaffold, stochastic human: the per-call divergences of the frozen mixture are not controlled by L·K).** X = {x_0, x_1}, answers in {0,1}. Scaffold: call 1 at x_0; after the answer 1, call 2 at x_1; after 0, stop (L = 2). Human: P(1|x_0) = p ∈ (0,1), P(·|x_1) = point mass at 1. One alternative ν: ν(1|x_0) = 0, ν(·|x_1) = point mass at 0. Weights w(P) = 1 − η, w(ν) = η with η ≤ ½; put o := η/(1−η) ≤ 1, so K ln2 = ln(1+o) ≤ o.

Before round t the alternative ν is alive exactly if all t − 1 recorded runs answered 0 at x_0, which has probability u_t := (1−p)^(t−1); its posterior weight is then ω_t = o/(o + u_t) (each such run multiplies its odds by 1/(1−p)). On this event M_t(1|x_0) = p(1−ω_t) and M_t(1|x_1) = 1 − ω_t, so
 E_{Q_P}[Σ_j KL(P‖M_t)(x_j)] = KL(Q_P‖Q̂_t) + p·ln(1/(1−ω_t)) = KL(Q_P‖Q̂_t) + p·ln(1 + o/u_t):
the first call contributes exactly KL(Q_P‖Q̂_t), and the second call, reached with probability p, is answered by a mixture that still gives ν the weight ω_t, although the answer 1 at the first call has refuted ν within this very run. Now sum over t. The function g(u) := ln(1 + o/u) is decreasing and u_t = (1−p)·u_(t−1), so p·u_t·g(u_t) = (1−p)·(u_(t−1) − u_t)·g(u_t) ≥ (1−p)·∫ g over [u_t, u_(t−1)] for t ≥ 2, and these intervals cover (0,1]. Hence
 Σ_{t ≥ 1} E[E_{Q_P} Σ_j KL(P‖M_t)(x_j)] ≥ (1−p)·∫_0^1 ln(1 + o/u) du = (1−p)·((1+o)·ln(1+o) + o·ln(1/o)) ≥ (1−p)·ln(1/o)·K ln2.
For the draw per run the corresponding sum is at most K ln2 (Theorem 4.2(a)). So the ratio of the left side to L·K ln2 exceeds (1−p)·ln(1/o)/2, which is unbounded as η → 0. (Section 7: ratios 2.2, 3.3, 5.6, 10.2 for η = 10⁻¹, 10⁻², 10⁻⁴, 10⁻⁸ at p = 0.01.) The same happens at K = 1 with many alternatives: with B alternatives of weight 1/(2B), each refuted in its own branch, the computed excess of the frozen per-call mixture over the draw per run, summed over t, is 1.82, 2.50, 3.21, 3.92 for B = 4, 16, 64, 256, growing like ½·ln B, against L·K ln2 = 1.39 (exact expectations, Section 7; not proved). ∎

In this example the total variation of the two imitators is the same to first order; what fails is the bound on the summed divergences, which is what every proof in this file uses. *Open:* for an adaptive scaffold and a stochastic human, does the frozen per-call mixture after N recorded runs satisfy E[TV(Q_{M_t}, Q_P)] ≤ C·√(LK/N)?

**Remark 4.9 (the same number of unfaithful calls, differently distributed).** For a function f, the expected number of calls along a run of the human system at which the imitator's answer would differ is E_{Q_f}[Σ_j (1 − M_t(f(x_j)|x_j))] for the per-call mixture, and it is the same number for one posterior draw per run, by linearity in ν. The draw per run puts all of them into few runs (in Example 4.6: L wrong calls in a fraction ω of the runs that meet an unvisited z); the per-call mixture spreads them (each such run has about Lω wrong calls). The first is better when every call is critical, by a factor up to L; the second is the right object under the low-stakes assumption of the candidate's R3. This qualifies the sentence "The right deployed object is then the per-call mixture" in Section 0 of the candidate theory: it is right for low stakes only.

## 5. Theorem B: one fixed program

### 5.1 Setting

The data are N independent runs τ_1, …, τ_N with law Q*, as in 4.2. H is a countable class with weights w, and ℓ(ν) := log₂(1/w(ν)), so that w = 2^(−ℓ) and Σ_ν 2^(−ℓ(ν)) ≤ 1; if ℓ are the lengths of a prefix-free code this is the setting of the candidate theory, but ℓ need not be integers. For λ ≥ 1 put

 π_λ(ν) := w(ν)^λ = 2^(−λℓ(ν)), L_ν := Π_{s ≤ N} q_ν(τ_s), Π_λ(ν | τ_1:N) := π_λ(ν)·L_ν / Σ_ν′ π_λ(ν′)·L_ν′.

By Lemma 4.1, Π_λ is the posterior given the pairs for the weights w^λ. A **λ-MAP** is a maximiser of π_λ(ν)·L_ν. For s ∈ (0,1) the Chernoff coefficient of ν is A_s(ν) := ∫μ₀ Σ_τ q*(τ)^(1−s)·q_ν(τ)^s; A_½(ν) = BC(Q*, Q_ν) = 1 − H²(Q_ν, Q*), and E[(q_ν(τ)/q*(τ))^s] = A_s(ν) for τ ~ Q*.

**Lemma 5.0.** A_s(ν) ≤ (1 − H²(Q_ν, Q*))^(2·min(s, 1−s)) for s ∈ (0,1).

*Proof.* For s ≥ ½ write q*^(1−s)·q_ν^s = (q*·q_ν)^(1−s)·q_ν^(2s−1) and apply Hölder's inequality with the exponents 1/(2−2s) and 1/(2s−1): A_s ≤ BC^(2−2s)·(∫Σ q_ν)^(2s−1) = BC^(2−2s). For s ≤ ½ exchange the roles of q* and q_ν. ∎

### 5.2 The theorem for λ > 1

**Theorem 5.1 (Theorem B).** Assume A1 and A2, so Q* = Q_P with P ∈ H. Let λ > 1, s ∈ [1/λ, 1), ε ∈ (0,1], N ≥ 1, and

 B_ε := {ν ∈ H : H²(Q_ν, Q_P) ≥ ε²}, β := 2^(λ·s·ℓ(P))·(1 − ε²)^(2·min(s, 1−s)·N).

(a) E[Π_λ(B_ε | τ_1:N)] ≤ β.
(b) Pr[there is ν ∈ B_ε with π_λ(ν)·L_ν ≥ π_λ(P)·L_P] ≤ β. So with probability at least 1 − β every λ-MAP ν̂ has H²(Q_ν̂, Q_P) < ε².
(c) *Choices of s.* For λ ≥ 2 and s = ½: β = 2^(λℓ(P)/2)·(1−ε²)^N ≤ 2^(λℓ(P)/2)·e^(−Nε²). For 1 < λ ≤ 2 and s = 1/λ: β = 2^(ℓ(P))·(1−ε²)^(2(1−1/λ)N). At λ = 2 both give the candidate's 2^(ℓ(P))·e^(−Nε²). Hence β ≤ δ as soon as
 N ≥ [(λ/2)·ℓ(P)·ln2 + ln(1/δ)]/ε² (λ ≥ 2), N ≥ λ·[ℓ(P)·ln2 + ln(1/δ)]/(2(λ−1)·ε²) (1 < λ ≤ 2).

*Proof.* L_P > 0 almost surely. For every ν, Π_λ(ν | τ_1:N) ≤ min(1, π_λ(ν)L_ν/(π_λ(P)L_P)) ≤ (π_λ(ν)/π_λ(P))^s·(L_ν/L_P)^s, because min(1, a) ≤ a^s. The runs are independent, so E[(L_ν/L_P)^s] = A_s(ν)^N ≤ (1 − ε²)^(2·min(s,1−s)·N) for ν ∈ B_ε, by Lemma 5.0. Finally Σ_ν π_λ(ν)^s = Σ_ν 2^(−λsℓ(ν)) ≤ Σ_ν 2^(−ℓ(ν)) ≤ 1 because λs ≥ 1, and π_λ(P)^(−s) = 2^(λsℓ(P)). This proves (a). For (b), Markov's inequality gives Pr[(L_ν/L_P)^s ≥ (π_λ(P)/π_λ(ν))^s] ≤ (π_λ(ν)/π_λ(P))^s·A_s(ν)^N for each ν; sum over ν ∈ B_ε. (c) is arithmetic, with −ln(1−ε²) ≥ ε². ∎

The candidate theory states the case λ = 2 and, for general λ > 1, the exponent 2·min(1/λ, 1−1/λ)·Nε² with the factor 2^(ℓ(P)); this is the choice s = 1/λ and is correct. For λ > 2 the choice s = ½ is better: it needs N ≥ [(λ/2)ℓ(P) ln2 + ln(1/δ)]/ε² instead of (λ/2)·[ℓ(P) ln2 + ln(1/δ)]/ε². In both regimes the number of runs is c(λ)·ℓ(P) ln2/ε² with c(λ) = max(λ/2, λ/(2(λ−1))), smallest at λ = 2, and c(λ) grows like 1/(2(λ−1)) as λ decreases to 1.

**Corollary 5.2 (one program used for all future runs).** Under the hypotheses of Theorem 5.1, let ν̂ be one draw from Π_λ(· | τ_1:N), or any λ-MAP. With probability at least 1 − β (over the recorded runs and the draw), H²(Q_ν̂, Q_P) < ε². On this event the program ν̂, used for good, has the following properties.

1. *Each run.* TV(Q_ν̂, Q_P) ≤ ε·√(2 − ε²) < √2·ε.
2. *Each event of a run.* Q_ν̂(G) ≤ 2Q_P(G) + 4ε² and Q_P(G) ≤ 2Q_ν̂(G) + 4ε²; if Q_P(G) = 0 then Q_ν̂(G) ≤ 2ε². (Lemma 1.1(5).) With N ≥ [ℓ(P) ln2 + ln(1/δ)]/ε² at λ = 2: an event that the human system never produces has probability at most 2[ℓ(P) ln2 + ln(1/δ)]/N in every run of the program.
3. *Many runs.* The joint laws of m independent runs satisfy H² = 1 − (1 − H²(Q_ν̂, Q_P))^m ≤ m·ε², so the total variation between m runs of the program and m runs of the human system is at most ε·√(2m). The bound is useful for m much smaller than 1/ε² ≈ N/(ℓ(P) ln2 + ln(1/δ)). Unless H²(Q_ν̂, Q_P) = 0 the joint laws separate as m grows (1 − (1−h)^m → 1): a fixed program is close to the human system on each run, not on the whole future.
4. *Single calls.* E_{Q_P}[Σ_j H²(ν̂, P)(x_j)] ≤ 2L·ε² (Proposition 2.5), and the factor L cannot be removed in general: closeness of whole runs allows ν̂ to be wrong at every call of a branch that it enters with small probability.
5. Nothing is said about inputs that the human system does not visit.

The guarantee of Theorem 4.2 is about a fresh posterior draw for every run (the *mixture* of run laws is close); Corollary 5.2 is about one draw kept for ever. In total variation the price is the same up to a factor 2: √(2[ℓ(P) ln2 + ln(1/δ)]/N) here against √(K ln2/(2N)) there, with ℓ(P) = K.

**Remark 5.3 (finite classes; the relation to log-loss behaviour cloning).** The proof of Theorem 5.1 uses λ > 1 only for Σ_ν π_λ(ν)^s < ∞ with some s < 1. For λ = 1 and a class with S_½ := Σ_ν √w(ν) < ∞ the same proof with s = ½ gives E[Π_1(B_ε)] ≤ S_½·w(P)^(−1/2)·(1−ε²)^N, and the same bound for the event of (b). For a finite class of M samplers with uniform weights this is M·e^(−Nε²): with probability at least 1 − δ the maximum-likelihood sampler has H²(Q_ν̂, Q_P) ≤ ln(M/δ)/N. In the convention D²_H = 2H² this is the proposition of Foster, Block and Misra quoted in 2.1, item 4. So Theorem B is the form of their bound for a countable class, and the steeper weights 2^(−λℓ) are what replaces the finiteness of the class.

### 5.3 What goes wrong at λ = 1

**Example 5.4 (tables against a fair coin).** Let d ≥ 1. The top-level input z is uniform on {0,1}^d and the scaffold makes one call, with input z. The human is the fair coin: P(·|x) = Bern(½) for every x. The class H_d consists of P, with ℓ(P) = 1, and of all 2^(2^d) functions f: {0,1}^d → {0,1} (as samplers), each with ℓ(f) = 2^d + 1 (the code is one bit to say "coin" or "table", then the table; the Kraft sum is 1). So K = ℓ(P) = 1.

For every table, H²(Q_f, Q_P) = 1 − 1/√2 = 0.2929. Let R be the number of recorded runs whose z has occurred before. Given the inputs, the answers are consistent with some table with probability 2^(−R); then the consistent tables have total weight 2^(−(N−R)−1) and likelihood 1, against weight ½ and likelihood 2^(−N) for P, so the posterior mass of the tables at λ = 1 is 1/(1 + 2^(−R)) ≥ ½. Hence for every ε² ≤ 0.29

 E[Π_1(B_ε | τ_1:N)] = E[2^(−R)/(1 + 2^(−R))] ≥ ½·Pr[R = 0] ≥ ½·(1 − N²/2^(d+1)),

which is at least ¼ for all N ≤ 2^(d/2). (Exact values: 0.4999 for d = 30, N = 1024; 0.479 for d = 30, N = 16384; Section 7.) Since d is arbitrary and ℓ(P) = 1, no bound of the form E[Π_1(B_ε)] ≤ β(ℓ(P), ε, N) with β → 0 as N → ∞ holds for all classes with Kraft weights. In the same class at λ = 2 the tables have relative weight 2^(R − 2^d), and Theorem 5.1 gives E[Π_2(B_ε)] ≤ 2e^(−Nε²). ∎

A table is the human "with the coins filled in": it reproduces every recorded answer and is deterministic. At λ = 1 a single draw from the posterior is such an object with probability about ½ in this class, for as long as inputs do not repeat. The digest `understand/repo.md` (item E11, read there) reports the same for the universal class: at λ = 1 the sampler and its fill-ins have comparable posterior weight. The argument of Theorem 5.1 fails at λ = 1 because for every s < 1 the sum Σ_ν w(ν)^s is infinite in such classes, or, in a finite class such as H_d, of the order 2^((1−s)·2^d). The imitation of Theorem 4.2 is not affected: in Example 5.4 the mixture of all consistent tables answers a new z like a fair coin.

**Theorem 5.5 (Theorem B′: the likelihood to the power α; also for a human outside the class).** In the setting 5.1 (any law Q* of independent runs, any weights w with Σ w ≤ 1) let α ∈ (0,1) and

 Π^(α)(ν | τ_1:N) := w(ν)·L_ν^α / Σ_ν′ w(ν′)·L_ν′^α.

For every ν* ∈ H with KL(Q* ‖ Q_ν*) < ∞ the tempered posterior Π^(α) is almost surely defined, and

 E[Σ_ν Π^(α)(ν | τ_1:N)·(−ln A_α(ν))] ≤ ln(1/w(ν*))/N + α·KL(Q* ‖ Q_ν*).

Consequently E[Σ_ν Π^(α)(ν | τ_1:N)·H²(Q_ν, Q*)] ≤ [ln(1/w(ν*))/N + α·KL(Q* ‖ Q_ν*)] / (2·min(α, 1−α)). For α = ½ the right side is ln(1/w(ν*))/N + ½·KL(Q* ‖ Q_ν*); under A1 and A2 it is K ln2/N.

*Proof.* Let L* := Π_s q*(τ_s), which is positive almost surely, and r_ν := L_ν/L*. Then Π^(α)(ν) = w(ν)r_ν^α/Z with Z := Σ_ν w(ν)r_ν^α, and E[r_ν^α] = A_α(ν)^N by independence. If A_α(ν) = 0 then r_ν = 0 almost surely; such ν are left out of all sums. Put Φ := Σ_ν w(ν)·r_ν^α·A_α(ν)^(−N). Then E Φ ≤ Σ_ν w(ν) ≤ 1, so Φ < ∞ almost surely; and Z ≤ Φ, while Z ≥ w(ν*)·r_ν*^α > 0 almost surely because KL(Q*‖Q_ν*) < ∞. By the concavity of the logarithm, with the probability weights Π^(α)(ν),
 ln Φ = ln Σ_ν Π^(α)(ν)·[Z·A_α(ν)^(−N)] ≥ ln Z + N·Σ_ν Π^(α)(ν)·(−ln A_α(ν)).
Therefore N·Σ_ν Π^(α)(ν)(−ln A_α(ν)) ≤ ln Φ − ln Z ≤ ln Φ + ln(1/w(ν*)) + α·ln(L*/L_ν*) on almost every path. The left side is non-negative; E[ln Φ] ≤ ln E[Φ] ≤ 0 by Jensen's inequality (ln Φ is bounded below by the integrable variable ln w(ν*) + α ln r_ν*); and E[ln(L*/L_ν*)] = N·KL(Q*‖Q_ν*). This proves the first inequality. The second follows from −ln A_α ≥ 2·min(α,1−α)·(−ln BC) ≥ 2·min(α,1−α)·H² (Lemma 5.0 and Lemma 1.1(2)). ∎

*Reading.* Π^(α) with α = 1/λ and Π_λ have the same maximisers, and Π_λ is proportional to (Π^(1/λ))^λ; raising the likelihood to the power ½ means counting each recorded run as half a run. So the substitute at λ = 1 is: keep the weights w, temper the likelihood. A program drawn from Π^(½) then has expected squared Hellinger distance at most K ln2/N from the human system, at the price K of the unsteepened weights, and by Markov's inequality H²(Q_ν̂, Q_P) ≤ K ln2/(Nδ) with probability at least 1 − δ. In Example 5.4 the tables have Π^(½)-mass at most 2^(R − N/2) (their total weight is 2^(−(N−R)−1) against ½·2^(−N/2) for the coin), which is small once N is large; at λ = 2 it is at most 2^(R − 2^d) from the start.

*Literature.* Bounds of this form for tempered ("fractional") posteriors and for two-part codes are standard: T. Zhang, "From ε-entropy to KL-entropy: analysis of minimum information complexity density estimation", *Annals of Statistics* 34(5):2180–2210, 2006; A. Bhattacharya, D. Pati, Y. Yang, "Bayesian fractional posteriors", *Annals of Statistics* 47(1):39–66, 2019; A. R. Barron, T. M. Cover, "Minimum complexity density estimation", *IEEE Transactions on Information Theory* 37(4):1034–1054, 1991. I quote these three from memory and did not open them in this session; the proofs of Theorems 5.1 and 5.5 above do not rely on them.

**Proposition 5.6 (the weights w^λ and a human outside the class; a bound in probability).** In the setting 5.1 let λ ≥ 1 with S := Σ_ν w(ν)^(λ/2) < ∞ (S ≤ 1 if λ ≥ 2). Let ν* ∈ H with KL* := KL(Q* ‖ Q_ν*) < ∞ and δ₁, δ₂ ∈ (0,1). With probability at least 1 − δ₁ − δ₂ over the recorded runs, every ν ∈ H with π_λ(ν)·L_ν ≥ π_λ(ν*)·L_ν*, in particular every λ-MAP, satisfies

 H²(Q_ν, Q*) < KL*/(2δ₁) + [(λ/2)·ℓ(ν*)·ln2 + ln(S/δ₂) + 1/(2e·δ₁)]/N =: ε₀².

Moreover E[Π_λ({ν : H²(Q_ν, Q*) ≥ ε₀²} | τ_1:N)] ≤ δ₁ + δ₂.

*Proof.* Let Y := ln(L*/L_ν*). Then E[Y] = N·KL* and E[max(−Y,0)] ≤ E[e^(−Y)]/e ≤ 1/e, so E[max(Y,0)] ≤ N·KL* + 1/e, and the event G := {Y ≤ c₁} with c₁ := (N·KL* + 1/e)/δ₁ has probability at least 1 − δ₁. On G, the inequality π_λ(ν)L_ν ≥ π_λ(ν*)L_ν* implies √(L_ν/L*) ≥ √(π_λ(ν*)/π_λ(ν))·e^(−c₁/2). Since E[√(L_ν/L*)] = (1 − H²(Q_ν, Q*))^N ≤ e^(−Nε₀²) for the ν in question, Markov's inequality and the union bound give probability at most S·π_λ(ν*)^(−1/2)·exp(c₁/2 − Nε₀²) = δ₂ for the existence of such a ν on G. For the posterior mass, on G we have Π_λ(ν) ≤ min(1, π_λ(ν)L_ν/(π_λ(ν*)L_ν*)) ≤ √(π_λ(ν)/π_λ(ν*))·√(L_ν/L*)·e^(c₁/2), and the same computation bounds the expectation of the mass on G by δ₂. ∎

In Proposition 5.6 the approximation error KL* is divided by the confidence level δ₁, where Theorem 5.5 has it with the factor ½ in expectation. I do not know whether the posterior with weights w^λ admits a bound with ln(1/δ₁) in place of 1/δ₁ without a further assumption (such as bounded likelihood ratios between Q* and Q_ν*).

## 6. General countable classes, and a human outside the class

All statements of Sections 3 to 5 are stated and proved for an arbitrary countable class H of samplers with weights w(ν) > 0, Σ_ν w(ν) ≤ 1; prefix code lengths enter only through ℓ(ν) = log₂(1/w(ν)), and K = ℓ(P). No computability and no particular reference machine are used. The table collects the forms.

| statement | human in the class | human outside the class (ν* any member) |
|---|---|---|
| Theorem A (4.2): fresh posterior draw per run, weights w | E KL(Q_P‖Q̂) ≤ ln(1/w(P))/N; E TV ≤ √(ln(1/w(P))/(2N)) | E KL(Q*‖Q̂) ≤ ln(1/w(ν*))/N + KL(Q*‖Q_ν*), for every law Q* of independent runs |
| Theorem B (5.1): one draw or the MAP, weights w^λ, λ > 1 | mass of {H² ≥ ε²} at most 2^(λsℓ(P))·(1−ε²)^(2 min(s,1−s) N) | in probability: H² < KL*/(2δ₁) + [(λ/2)ℓ(ν*) ln2 + ln(S/δ₂) + 1/(2eδ₁)]/N (5.6) |
| Theorem B′ (5.5): one draw, weights w, likelihood to the power ½ | E H²(Q_ν̂, Q_P) ≤ ln(1/w(P))/N | E H²(Q_ν̂, Q*) ≤ ln(1/w(ν*))/N + ½·KL(Q*‖Q_ν*) |
| Theorem R2 (3.1): Protocol R, per-call mixture | E H² ≤ 2L·ln(1/w(P))/n | E H² ≤ 2L·[ln(1/w(ν*))/n + sup_x KL(P‖ν*)(x)] (Remark 3.3) |

What changes outside the class:

1. **An approximation term is added, and it is a divergence, not a distance.** For recorded runs it is KL(Q*‖Q_ν*), which for a stateless human is the per-call divergence summed along the human system's own runs (Theorem 4.2(d)). For Protocol R it is measured along the imitators' runs, and only a supremum over inputs bounds it in advance. The bounds trade the complexity ln(1/w(ν*)) against this term, and they do not tend to zero as the data grow: what remains is the approximation term, of order √(KL*/2) in total variation.
2. **If every member excludes some answer that the human gives** (KL(Q*‖Q_ν) = ∞ for all ν), all the bounds are empty, and after such an answer the posterior is not defined. This is a property of likelihood-based learners. The minimum-distance learner of the candidate's Pr4 is aimed at this case; it is not treated here.
3. **Theorem A does not need a stateless human.** It holds for every law Q* of independent runs, for example a human who remembers the earlier calls of the same run. The class still consists of samplers, so the approximation term is then the divergence from the best stateless imitation of the whole run. Corollary 2.3 (L4) also holds for arbitrary answerers.
4. **For one fixed program** the clean oracle inequality is for the tempered posterior (Theorem 5.5). For the posterior with steeper weights I have only the bound in probability of Proposition 5.6.

## 7. Numerical checks

All scripts are in `research/prove-b/code/`; their complete outputs are saved next to them as `hellinger-runs_*.out`. They need numpy; the linear programme in `hellinger-runs_l4_lp.py` also needs scipy. Lines quoted below are verbatim.

**7.1 `hellinger-runs_l4_check.py` (Lemma 2.2, Theorem 2.1, Examples 2.6 and 2.8(i)).** Part (a) tests Lemma 2.2(ii) on 200000 random pairs of kernels (with and without mutually singular parts) and random Λ; part (b) computes H², E_P Σ h, E_Q Σ h and E_P Σ Λh exactly on 4000 random trees of depth at most 4; part (c) is a local search for a large ratio.

```
(a) one-step inequality, max of lhs - rhs over 200000 random cases: 3.365e-16  (must be <= 0 up to rounding)
(b) random trees: max ratio H2/E_P[sum h] = 1.5404 ; max |H2 - E_P sum Lam h| = 5.55e-16 ; max of H2 - (E_P sum h + E_Q sum h)/2 = 2.53e-16
(c) hill-climbing, depth 2, binary: best ratio 1.6968
    hill-climbing, depth 3, binary: best ratio 1.9860
    hill-climbing, depth 4, binary: best ratio 2.1670
(d) two-stage example, s = 1+sqrt2, limit (2+sqrt2)/2 = 1.707107
    eps=1e-05: H2=3.414243e-05, E_P sum h=2.000029e-05, ratio=1.707096
(e) lattice example, closed form; b = u^m
    u=1.001, m=1530, b=4.615: H2=0.001097, sigma=0.000523, ratio=2.09863
    maximum over b of the continuous limit: 2.09969 at b = 4.589
    exact dynamic programme for the truncated strategy (u=1.05, m=31):
      horizon  10001: H2=0.052117, sigma=0.025427, ratio=2.04967
```

(In the script the parameter β of Example 2.8 is called u.) Already binary trees of depth 4 exceed the ratio 2.

**7.2 `hellinger-runs_l4_lp.py` (Theorem 2.7, Example 2.8(ii)).** Part (B) evaluates q₀ and c*; parts (C) and (E) check the ingredients of the proof of Theorem 2.7 numerically (the parabola condition of Step 2 on a grid of 1200 values of Λ and 1700 values of a, the identities of Step 0(iii) by central differences, the inequalities (iv) and (v) on a grid, and the one-step inequality of Step 3 on 40000 random laws); part (D) evaluates the example; part (A) is a linear programme that estimates the best constant from below without using the potential.

```
(B) q0 = 1.151203573004,  c* = 2.964147157308
    sign changes of g(q) - 1/(1-q^2/2) on (0, 1.41) at q ~ [1.15119836]; values at q = 1.151 and 1.152: +0.001363, -0.005361; 1/(1-1.152^2/2) = 2.97223
(E) max |d(p/s)/dq - 1/s| = 2.88e-09, max |dr/ds - p/(2s)| = 1.98e-09 (central differences); min of (iv) on the grid = -2.22e-16, min of (v) = 3.54e-09; direct test of (S) for U*, 40000 random laws: max lhs - rhs = 0.00e+00
(C) min over the grid of [tangent parabola - U] = 0.000e+00 at (Lam, a) = (0.0200, 0.0200); min of U(x)+x = 0.000e+00  (both must be >= 0 up to rounding)
(D) explicit strategy: ratio H2 / E_P sum h
    u=1.1     top=1e+06: levels=   145  H2=1.644833e-03  E_P sum h=5.824339e-04  ratio=2.82407
    u=1.01    top=1e+06: levels=  1389  H2=1.895338e-04  E_P sum h=6.426462e-05  ratio=2.94927
    u=1.001   top=1e+06: levels= 13823  H2=1.938008e-05  E_P sum h=6.541475e-06  ratio=2.96265
    u=1.0001  top=1e+06: levels=138163  H2=1.943858e-06  E_P sum h=6.558242e-07  ratio=2.96399
(A) linear programme on geometric grids: u, range, constraints, c_G
    u=1.05   x in [0.6,60]  constraints=  152096  c_G=2.82709
    u=1.035  x in [0.6,60]  constraints=  428536  c_G=2.86424
    u=1.025  x in [0.6,60]  constraints= 1125180  c_G=2.89015
    u=1.018  x in [0.7,60]  constraints= 2667126  c_G=2.90589
```

In (C) and (E) the minima 0 (up to rounding) are attained where the proof has equality; no violation was found. On the interval (0, 1.41) the function g − k has a single sign change, at q₀. Part (D) with 145 levels already gives a pair of samplers on a scaffold of horizon 145 with ratio 2.82. (In the script the parameter β is called u, and (S) is the one-step inequality E U(Λr̃) ≤ U(Λ) + c*(1 − E r̃).)

**7.3 `hellinger-runs_r2_coins.py` (Lemma 3.4a, Theorem 3.1).** Part (2) runs Protocol R on the scaffold of Proposition 3.4 (each round asks a uniformly random input), computes the run laws exactly and averages over 600 data sets and rounds T. Part (4) does the same on an adaptive scaffold: a walk down a binary tree whose node is the input of the call, with a class of six samplers with random biases at the nodes and random weights (300 data sets).

```
    smallest ratio G / (delta sqrt(N/2)) over the cases tried: 1.9314 (must be >= 1)
(2) Protocol R, exact run laws; columns: K m L n delta | E H2, 4E sigma, bound 2LK ln2/n | E TV, bound 2 sqrt(LK ln2/n)
    K=2 m=10 L= 20 n=  400 delta=0.0707 | 0.0164 0.0675 0.1386 | 0.0974 0.5266
    K=3 m= 8 L= 24 n=  600 delta=0.1414 | 0.0211 0.0931 0.1664 | 0.0655 0.5768
    K=2 m=30 L= 60 n= 2400 delta=0.0577 | 0.0105 0.0447 0.0693 | 0.0429 0.3723
(3) growth in L at fixed K=2, n=800, delta = sqrt(K/n): E TV / sqrt(L)
    L=   2: E TV=0.0230  E TV/sqrt(L)=0.0163  E H2/L=0.00037
    L=  32: E TV=0.0798  E TV/sqrt(L)=0.0141  E H2/L=0.00037
    L= 128: E TV=0.1606  E TV/sqrt(L)=0.0142  E H2/L=0.00037
(4) adaptive scaffold (walk down a binary tree, L = depth), class of 6 samplers, Protocol R
    L n | K | E H2, 4E sigma, bound 2LK ln2/n | E TV, bound 2 sqrt(LK ln2/n)
    L=4 n=   50 | K=2.53 | 0.02706 0.10955 0.28029 | 0.1521 0.7487
    L=6 n=  400 | K=2.49 | 0.00508 0.02164 0.05169 | 0.0499 0.3215
    L=6 n= 3200 | K=2.49 | 0.00074 0.00306 0.00646 | 0.0112 0.1137
```

The chain E H² ≤ 4·E σ ≤ 2LK ln2/n holds in every row (σ is the expected sum of per-call H² along the imitator's run; the scaffold of parts (2) and (3) does not adapt, so there even E H² ≤ E σ holds, Proposition 2.4). The expected total variation grows like √L at fixed n, as Section 3.3 says. The upper bound is five to ten times the observed value in these instances.

**7.4 `hellinger-runs_thmA.py` (Theorem 4.2, Examples 4.4, 4.6, 4.8).**

```
(1) Theorem A, K coins: average over t<=N of E KL(Q_P||Qhat_t), bound K ln2/N
    exact, K=1, m=5, delta=0.1, N=50: sum_t E KL = 0.69114  (K ln2 = 0.69315)
    K=2 m=5 delta=0.1 N=50: (a) 0.02709  (b) 0.02769  bound 0.02773
    K=3 m=4 delta=0.05 N=100: (a) 0.01923  (b) 0.01892  bound 0.02079
(2) expected KL of the posterior mixture after t runs, t = 0..5 (not monotone):
     0.00321 0.01058 0.02451 0.03794 0.04298 0.03988
(3) Example 4.6: per-call mixture against one posterior draw per run; K = 1 bit
    B, N, L | E TV per-call, E TV per-run, Theorem A bound sqrt(ln2/(2N)) | E KL per-call, E KL per-run, ln2/N
    B=   200 N=   100 L=    7 | 0.01308 0.001886 0.05887 | 0.013222 0.0018888 0.006931
    B=   200 N=   100 L=   50 | 0.08745 0.001886 0.05887 | 0.094442 0.0018888 0.006931
    B=  2000 N=  1000 L= 4000 | 0.43186 0.000189 0.01862 | 0.755127 0.0001888 0.000693
(4) Example 4.8, two hypotheses, L = 2: cumulative expected per-call KL along human runs
    eta=0.01 p=0.01 N=6000: frozen=6.6384e-02  coherent=1.0050e-02  K ln2=1.0050e-02  (1-p) o ln(1/o)=4.5951e-02  ratio=3.303
    eta=1e-08 p=0.01 N=6000: frozen=2.0328e-07  coherent=1.0000e-08  K ln2=1.0000e-08  (1-p) o ln(1/o)=1.8236e-07  ratio=10.164
    many alternatives, K = 1 bit, L = 2, p = 1/2 (exact expectation):
    B=   4 (t <= 76): excess=1.8189   (ln B)/2=0.6931
    B=  16 (t <= 542): excess=2.5025   (ln B)/2=1.3863
    B=  64 (t <= 3204): excess=3.2131   (ln B)/2=2.0794
    B= 256 (t <= 17044): excess=3.9188   (ln B)/2=2.7726
```

In part (1), estimate (b) is the average of ln(w_N(P)/w(P))/N, which has the same expectation as the average divergence and never exceeds the bound on any path; estimate (a) averages the conditional divergences and is noisier (in one configuration, K = 3, δ = 0.1, it came out at 0.02131 against the bound 0.02079, while (b) gave 0.02079). In part (3) the values are expectations over the data for the posterior after all N runs.

**7.5 `hellinger-runs_thmB.py` (Example 5.4, Theorems 5.1 and 5.5).** Part (2) uses the class of all Bern(θ) with θ a dyadic rational of level at most 10, code length 2·level − 1, a scaffold with five calls at one input, the human Bern(3/8) (ℓ(P) = 5) and ε² = 0.02; part (3) uses the dyadic levels up to 3 and the human Bern(0.3), which is not in the class.

```
(1) Example 5.4: expected posterior mass of the tables (all at H2 = 0.2929 from the coin)
    d=20 N=   512: 0.4795   0.000e+00   1.486e-65
    d=30 N= 16384: 0.4794   0.000e+00   0.000e+00
(2) dyadic class (levels <= 10), truth Bern(3/8) with l(P) = 5, runs of L = 5 calls
    lambda=1.5  N= 320: 1.0315e-07   bound 4.2991e-01
    lambda=2.0  N= 320: 9.8606e-08   bound 4.9830e-02
    lambda=3.0  N=  80: 2.3943e-01   bound 1.0000e+00
    lambda=3.0  N= 320: 1.2181e-04   bound 2.8188e-01
(3) Theorem B', alpha = 1/2: class = dyadic levels <= 3, truth Bern(0.3), L = 5
    N=   80: 0.00949   bound 0.04200
    N= 1280: 0.00804   bound 0.01763
    (the best member has H2 = 0.00782 and KL/2 = 0.01600)
```

(Columns of part (1): λ = 1, λ = 2, bound of Theorem 5.1 at λ = 2.) In this smooth one-parameter class the bounds of Theorem 5.1 are far from tight, and λ = 1 does no harm; the failure at λ = 1 needs a class with many memorising members, as in Example 5.4. A larger λ makes the posterior slower at small N, in line with the factor 2^(λsℓ(P)).

## 8. What remains open, and remarks on other parts of the candidate theory

### 8.1 Open in this part

1. **The best constant in L4.** 2.9639 ≤ c₀* ≤ c* = 2.9641 (Theorem 2.7 and Example 2.8(ii)). That c₀* = c* is not proved: it needs the convergence of the ratio of the strategy of Example 2.8(ii) to c*, for which there is only the computation. The value of c* itself rests on a double-precision evaluation of an elementary function.
2. **The per-call mixture after recorded runs** (Section 4.3): for an adaptive scaffold and a stochastic human, is E TV(Q_{M_t}, Q_P) ≤ C·√(LK/N)? Proposition 4.7 covers a deterministic human and scaffolds that do not adapt; Example 4.8 shows that the summed per-call divergences are not controlled.
3. **The last round in place of a random round** in Theorems 3.1 and 4.2: only non-monotonicity is shown (Example 4.4).
4. **The lower bound** of Proposition 3.4 has the constant 1/(8·10⁴) and is for one class. The number of questions needed for whole-run total variation ε as a function of the class and the scaffold is not characterised; in the examples it ranges from at most LK ln2/ε (functions) to the order LK/ε² (coins).
5. **Outside the class:** a bound for the posterior with steeper weights in which the approximation term is not divided by the confidence level (Proposition 5.6); and the case in which every member excludes an answer the human gives.
6. **One fixed program inside Protocol R.** Theorem 5.1 needs independent recorded runs of the human system. Its analogue for the data of Protocol R (single calls on the mixtures' runs), which would be the version of the candidate's R4 and R6 for a stochastic human, is not treated here.
7. **A human with memory across runs** is outside every statement of this file.

### 8.2 Remarks on other parts of the candidate theory

1. **L4, the source of the constant.** The constant 7 is in Foster, Han, Qian and Rakhlin (arXiv:2404.10122), via Jayram's cut-and-paste lemma; the paper named in the candidate theory (Foster, Kakade, Qian and Rakhlin) has 10²·log n. Corollary 2.3 gives 4 by a ten-line proof, and Theorem 2.7 gives 2.9641, which is the best possible up to the fourth digit; either should replace the citation. The candidate's change-of-measure inequality with (5/3, 16/3) is correct but no longer needed.
2. **R2 should be stated in H² as well as in total variation** (Theorem 3.1(a),(c)): E H² ≤ 2LK ln2/n gives, for an event that the human system never produces, probability at most 4LK ln2/n in the deployed run. This is the linear rate of the deterministic case and is the relevant form for "fails only obviously" and for the candidate's Pr1 (all properties at once: within √(2H²) additively, and within a factor 2 plus 4H² multiplicatively).
3. **Section 0, item 2, and Section 10, test 5 (budget)** quote the numbers of the deterministic case. For a stochastic human the whole-run budget is 4LK ln2/δ² questions for total variation δ, and Proposition 3.4 shows that the order LK/δ², including the factor K, is necessary for some classes. Under the low-stakes assumption of R3, the candidate's bound β ≤ L·√(K ln2/(2n)) on the expected number of unfaithful calls gives failure ≤ δ_f + √(K ln2/(2n))/θ for tolerance θL, that is n ≥ K ln2/(2θ²δ²), again quadratic in 1/δ. The order L·√(K/n) of β is attained for the K coins (Section 3.3, qualification 3; not written out).
4. **Section 0, item 3, and Proposition R5** ("the right deployed object is the per-call mixture"): true under low stakes only. For whole-run fidelity from recorded runs the per-call mixture is worse than one posterior draw per run by a factor up to L (Example 4.6), while the expected number of unfaithful calls along the human's run is the same for both (Remark 4.9).
5. **Section 3, remark (iii)** ("random round cannot be replaced by last round in general"): the learning curve is indeed not monotone (Example 4.4), but that does not show that a last-round bound fails; the question is open (8.1, item 3).
6. **Theorem B for λ > 2:** use s = ½ (Theorem 5.1(c)); the candidate's exponent 2·min(1/λ, 1−1/λ) is correct but gives a larger sample size there.
7. **Section 12** is correct: with P₁ = point mass at b, P₂ = Bern(½) and R = (1−ε)·δ_a ⊗ Bern(0.01) + ε·δ_b ⊗ Bern(½) one has KL(P₁⊗P₂‖R) = ln(1/ε), while the sum of the marginal divergences is ln(1/ε) + KL(Bern(½)‖(1−ε)Bern(0.01) + ε·Bern(½)), which is larger. Examples 4.6 and 4.8 show that this is not only a gap in a proof: the conclusion fails as well.
8. **A3.** The proofs of R1 and of everything in this file use only the first half of A3 (the protocol's coins are independent of the human's coins). The clause "not computable by any hypothesis" is not used: a hypothesis is a kernel in x alone and cannot depend on the protocol's coins.
9. **Theorem A and the human's time.** By Proposition 3.4 (whose protocols may record whole runs), N·L ≥ LK/(8·10⁴·ε²) answers are needed in the worst case, so recorded runs save no human answers over Protocol R beyond a constant: for the same number n = N·L of answers the bound √(K ln2/(2N)) of Theorem 4.2(c) is 2√2 times smaller than the bound of Theorem 3.1(b). What Theorem A costs is that the human must execute whole runs.

## Appendix A. Proof of Theorem R1

**Lemma A.1 (the candidate's L3: Bayes regret on adaptively chosen questions).** Let H and w be as in 0.5 and let P be a sampler. In rounds t = 1, 2, …, n a procedure either asks nothing or asks a question x_t; x_t (and whether a question is asked) is a function of the pairs collected in the earlier rounds and of a random element U; and, conditionally on U, the earlier pairs and x_t, the answer y_t has the law P(·|x_t). Let D_(t−1) be the pairs collected before round t and M_(t−1) := M_{D_(t−1)}. Then for every ν* ∈ H,

 Σ_{t ≤ n} E[KL(P‖M_(t−1))(x_t)] ≤ ln(1/w(ν*)) + Σ_{t ≤ n} E[KL(P‖ν*)(x_t)],

where rounds without a question contribute 0 to both sums. In particular, if P ∈ H, then Σ_{t ≤ n} E[KL(P‖M_(t−1))(x_t)] ≤ K ln2.

*Proof.* If the right side is infinite there is nothing to prove; otherwise ν*(y_t|x_t) > 0 almost surely at every asked pair. Let ξ(D) := Σ_ν w(ν)·Π_{(x,y) ∈ D} ν(y|x); then ξ(∅) ≤ 1, ξ(D_t) ≥ w(ν*)·Π_{s ≤ t} ν*(y_s|x_s) > 0, and M_(t−1)(y_t|x_t) = ξ(D_t)/ξ(D_(t−1)). So on every path Π_t M_(t−1)(y_t|x_t) = ξ(D_n)/ξ(∅) ≥ w(ν*)·Π_t ν*(y_t|x_t) (products over the rounds with a question), that is,
 Σ_t ln(P(y_t|x_t)/M_(t−1)(y_t|x_t)) ≤ ln(1/w(ν*)) + Σ_t ln(P(y_t|x_t)/ν*(y_t|x_t)).
Given U and D_(t−1), the input x_t is fixed and y_t ~ P(·|x_t), so the conditional expectations of the two logarithms of round t are KL(P‖M_(t−1))(x_t) and KL(P‖ν*)(x_t). Negative parts are integrable as in the proof of Theorem 4.2 (each has expectation at most 1/e). Take expectations. ∎

*Proof of R1.* Let U collect all the randomness of Protocol R: the variables ω₀ of the rehearsal runs, the uniform variables with which the answers of the mixtures are drawn, and J_1, …, J_n. By A1 and the first half of A3, the answer of the human to a question is, given U and the earlier pairs, a draw from P at the asked input. The run τ_t is a function of U and D_(t−1) (through M^(t)), and so is the question x_(t,J_t) of round t, which is asked if J_t ≤ len(τ_t). Lemma A.1 with ν* = P gives
 Σ_{t ≤ n} E[1{J_t ≤ len(τ_t)}·KL(P‖M^(t))(x_(t,J_t))] ≤ K ln2.
Given D_(t−1) and τ_t, the index J_t is uniform on {1, …, L}, so the conditional expectation of the summand is (1/L)·Σ_{j ≤ len(τ_t)} KL(P‖M^(t))(x_(t,j)); and given D_(t−1) the run τ_t has the law Q_{M^(t)}. Multiply by L. ∎

*The human outside the class.* The same argument with an arbitrary ν* ∈ H gives Σ_{t ≤ n} E[E_{Q_{M^(t)}} Σ_j KL(P‖M^(t))(x_j)] ≤ L·ln(1/w(ν*)) + Σ_{t ≤ n} E[E_{Q_{M^(t)}} Σ_j KL(P‖ν*)(x_j)], which is the statement used in Remark 3.3(ii).

