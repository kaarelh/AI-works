# Whole-run closeness for a stochastic human (key: hellinger-runs)

Full proofs for the part `hellinger-runs` of the note: Lemma L4, Theorem R2 in general, Theorem A and Theorem B (labels L4, R2, A, B), and their forms for a general countable class. The text of this part in the note is `research/sections/hellinger-runs.md`.

**How this file was made.** It is the prover's file `research/prove-b/hellinger-runs.md`, corrected in place by the editor after two verification reports: `verification/hellinger-runs-check.md` (a line-by-line check; "the first verifier" below) and `verification/hellinger-runs-attack.md` (an adversarial report; "the second verifier"). No statement of the prover's file was found false. The corrections are wording and rounding, three filled gaps, and sharper statements; the larger changes are these. (1) Section 2.5 is new: Lemma 2.10 bounds the total variation and single events directly, with the constants of a single call; Theorem 3.1 (R2) now has those constants, smaller by the factors √2 and 4 than the prover's. (2) Theorem 3.1(d) is sharper, Proposition 3.6 is new (it was an assertion without proof), and Theorem 5.7 is new (an oracle inequality that the prover's file said it did not have). (3) Results that are in the literature are now called standard, with the sources: Theorem A, Theorem B′, the counterexample at λ = 1, and Theorem B in substance. The last section, "Checking", lists every finding of the two reports and what was done about it, and says for each statement which verifier checked it. Every statement below is proved in this file or is marked otherwise. Scripts and their saved outputs are in `proofs/code/hellinger-runs_*`; Section 7 quotes them.

**Labels.** In the note the two theorems on recorded runs are called **H1** (Theorem A of this file, Theorem 4.2) and **H2** (Theorem B, Theorem 5.1), by the outline's Addendum 3; this file keeps the names Theorem A and Theorem B. The lower bounds of Propositions 3.4 and 3.5 are cited in the note under the label N6 of the part `lower-bounds`. Lemma L4 of the note is Corollary 2.3 together with Corollary 2.11.

**Notation.** The notation is that of `research/outline.md`: X, Y, samplers, H, w, K = log₂(1/w(P)), M_D, Π (scaffold), L (horizon), τ (a run), Q_A, Q_P, n (rounds of rehearsal; the human answers at most n questions), T (the deployed round), H² = 1 − Σ√(pq), KL in nats. Relative to the prover's file the editor renamed four symbols that collided with it: the parabola of Theorem 2.7 is ζ_Λ (was τ_Λ), the rate of Theorem 4.2 is Res_N(ν*) (was ρ_N(ν*)), the likelihood of the recorded runs is 𝓛_ν (was L_ν), and the posteriors of Section 5 are Post_λ and Post^(α) (were Π_λ and Π^(α)). Some letters keep a local meaning that differs from the outline's, each defined where it is used: m is the number of repetitions of an input in Section 3.2 and an integer in Example 2.8 (the outline's m, the number of validation questions, does not occur in this file); β is the base in Example 2.8 and the bound of Theorem 5.1; G is an event of runs, G(N, δ) is the function of Lemma 3.4a; δ is a bias in Section 3.2 and a confidence level elsewhere; ω₀ = (z, ρ) is the scaffold's randomness together with the top-level input, and ρ alone denotes a probability vector in the proof of Theorem 5.7; inside the proof of Theorem 2.7 the letters r, s, p, q, k, μ are local. The outline's Addendum 3 fixes further letters for the text of the note and lets the proof files keep their own; here k is a number of runs (Corollary 2.11, Remark 3.2; the note writes r), η is the free parameter of the bounds for events, α the exponent of a tempered likelihood, ℓ(ν) = log₂(1/w(ν)) a code length, and Λ_i a root likelihood ratio, where the note uses k, η, α, ℓ and Λ for other things and does not use them in this part.

## Summary of the statements

Status words. PROVED: proved in this file. STANDARD: in the literature, with the source in the section named; the proof here is self-contained all the same. COMPUTED: an exact or high-precision evaluation, not a proof of a general statement. The last column says who checked the proof: C = the first verifier's line-by-line check, A = the second verifier's adversarial report (both rederived the proofs by hand and tested them numerically unless a note says otherwise), E = the editor. Statements marked "new" were added after the verification.

| no. | statement | status | checked by |
|---|---|---|---|
| Lemma 1.1 | Relations between H², TV and KL; for single events Q(A) ≤ (1+η)·P(A) + (1+1/η)·2H²(P,Q), in particular Q(A) ≤ 2P(A) + 4H², and Q(A) ≤ H²(2−H²) ≤ 2H² when P(A) = 0. | STANDARD (Le Cam's and Pinsker's inequalities, data processing) | C, A |
| Theorem 2.1 | Sequential experiments with kernels p_i, q_i and h_i := H²(p_i, q_i): (a) H²(P,Q) = E_P Σ_i Λ_{i−1} h_i exactly; (b) H²(P,Q) ≤ ½(E_P Σ h_i + E_Q Σ h_i); (c) H²(P,Q) ≤ 4·E_P Σ h_i. | PROVED. (a), (b) are standard in substance (for Markov chains (b) is Proposition 2.1 of Clément, arXiv:2103.09648); (c) with the constant 7 is Foster, Han, Qian and Rakhlin (arXiv:2404.10122), with 10²·log n Foster, Kakade, Qian and Rakhlin (arXiv:2112.13487); the constant 4 was not found in a source (Section 2.1) | C, A |
| Corollary 2.3 (**L4**, H² form) | For answerers A, B on a scaffold, runs of any length, σ_A := E_{Q_A} Σ_j H²(A,B)(history_j): H²(Q_A, Q_B) ≤ 4σ_A; hence Q_B(G) ≤ 2Q_A(G) + 16σ_A for every event G. | PROVED. The candidate's L4 was a sketch with c₀ = 7 attributed to the wrong paper | C, A |
| Proposition 2.4 | If the inputs do not depend on the answers, the constant in L4 is 1. | PROVED (standard: affinity of product measures) | C; A read the proof |
| Proposition 2.5 | Converse with a factor: σ_A ≤ 2L·H²(Q_A, Q_B); the factor L is needed. | PROVED (the one-step form is in the literature, Section 2.3) | C; A read the proof |
| Example 2.6 | With two calls the constant in L4 cannot be below (2+√2)/2 = 1.707. | PROVED | C, A |
| Theorem 2.7 | L4 (H² form) with the constant c* = 1/(1 − q₀²/2) = 2.964147… < 2.9642 in place of 4; q₀ is the only root in (0, √2) of an explicit equation; 2.96414712 < c* < 2.96414723. Proved with a second potential. | PROVED; the enclosure by interval arithmetic | C, A (Step 2 also in 50-digit arithmetic); enclosure and uniqueness: C, E |
| Example 2.8 | Explicit pairs of samplers with ratio 2.0997 (closed form) and 2.96399 (a sum of positive terms, in 30-digit arithmetic). So 2.9639 ≤ c₀* ≤ 2.9642 for the best constant c₀*. | COMPUTED lower bound; c₀* = c* is OPEN | C (30 digits, two ways), A (three of the four values) |
| Lemma 2.10, Corollary 2.11 (**L4**, forms for the total variation and for events; new) | With σ := E_P Σ h_i: P(G) ≤ (1+η)·Q(G) + 2(1+1/η)·σ; P(G) ≤ 2σ if Q(G) = 0; TV(P,Q) ≤ φ(σ) := min(1, σ + √(σ²+2σ)) ≤ 2√σ. These are the constants of a single call. For k independent runs: TV ≤ φ(kσ). | PROVED. Found by the second verifier (its Lemma X). In the weaker form TV ≤ 2√σ it may be classical (Kabanov, Liptser and Shiryaev 1986; not opened, Section 2.1, item 7) | A (author), E; **not checked by C** |
| Theorem 3.1 (**R2**) | Under Protocol R with n rounds, s := LK ln2/(2n): (a) E H²(Q_{M^(T)}, Q_P) ≤ 2LK ln2/n; (b) E TV ≤ φ(s) ≤ √(2LK ln2/n), so E TV ≤ ε once n ≥ (1+ε)·LK ln2/ε²; (c) E Q_{M^(T)}(G) ≤ (1+η)·Q_P(G) + (1+1/η)·LK ln2/n, and E Q_{M^(T)}(G) ≤ LK ln2/n if Q_P(G) = 0; (d) if the inputs do not depend on the answers, E KL(Q_P‖Q_{M^(T)}) ≤ LK ln2/n and E TV ≤ √(LK ln2/(2n)); (e) for a function the deployed run differs from the human system's with probability ≤ LK ln2/n. | PROVED. (a), (e) as in the prover's file. (b), (c) with the constants of Lemma 2.10 (the prover had 2√(LK ln2/n), 8LK ln2/n and 4LK ln2/n). (d) sharpened by the first verifier. R1 is proved in Appendix A and is standard | (a), (e): C, A. (b), (c) final form: A, E. (d) final form: C, E |
| Proposition 3.4 | A class of K coins and a scaffold of L calls for which every protocol needs n > LK/(8·10⁴·ε²) questions to have E TV ≤ ε for all members (ε ≤ 1/65). So the order LK/ε² is necessary in the worst case over classes and scaffolds. | PROVED (Assouad's method) | C (constants recomputed), A (proof rederived) |
| Proposition 3.5 | Two samplers (K = 1) and L calls at one input: every protocol needs n > L/(740·ε²) questions for E TV ≤ ε for both (ε ≤ 1/12). | PROVED (Le Cam's two-point method) | C, A (exact Bayes risk) |
| Proposition 3.6 (new) | For the K coins every deployed sampler has, for some member, at least (√3/32)·L·√(K/n) unfaithful calls in expectation (n ≥ 3K/4). | PROVED. It was an assertion without proof in the prover's file; statement and proof by the first verifier | C (author), E |
| Theorem 4.2 (**Theorem A**; **H1** in the note) | N recorded runs, a posterior draw per run, uniformly random t: E KL(Q* ‖ Q̂) ≤ min_ν [ln(1/w(ν))/N + KL(Q* ‖ Q_ν)] for every law Q* of independent runs; for a human in the class E KL ≤ K ln2/N and E TV ≤ √(K ln2/(2N)); E Q̂(G) ≤ K ln2/N if Q_P(G) = 0. | STANDARD: the progressive mixture rule (Catoni; Yang), applied to whole runs (Remark 4.2a) | C, A; the bound for events of probability zero: A (author), E |
| Example 4.4 | The expected divergence of the posterior mixture is not monotone in the number of runs. | COMPUTED (exact) | C, A |
| Example 4.6 | The per-call mixture in place of the draw per run: the statement of Theorem A is false. With K = 1 the divergence is at least L/(8N), against ln2/N, also for the averaged law; the loss is a factor up to L. | PROVED (refutation of the per-call variant of Theorem A) | C (filled the step for the averaged law), A (exact enumeration), E |
| Proposition 4.7 | What holds for the per-call mixture: a bound with the factor L for a deterministic human, and for scaffolds whose inputs do not depend on the answers. | PROVED | C; A read the proof |
| Example 4.8 | For an adaptive scaffold and a stochastic human the summed per-call divergences of the frozen per-call mixture along human runs are not bounded by any multiple of L·K ln2 (as w(P) → 1). At K = 1: computed, not proved. | PROVED (first half); COMPUTED (second half) | C, A |
| Theorem 5.1 (**Theorem B**; **H2** in the note) | Weights 2^(−λℓ), λ > 1, any s ∈ [1/λ, 1): E[posterior mass of {ν : H²(Q_ν, Q_P) ≥ ε²}] ≤ 2^(λsℓ(P))·(1−ε²)^(2·min(s,1−s)·N); the same bound for the probability that some such ν has at least the posterior weight of P. | PROVED. In substance standard: Barron and Cover (1991, Theorem 4, as described by Zhang 2006); for a finite class Foster, Block and Misra (Section 5.4) | C, A |
| Corollary 5.2 | One fixed program: what closeness in H² gives for one run, for m runs, and for rare events. | PROVED | C; A read the proof |
| Example 5.4 | At λ = 1 no bound in terms of ℓ(P), ε and N exists: a class with ℓ(P) = 1 in which the expected posterior mass of hypotheses at H² = 0.29 is at least ¼ for all N ≤ 2^(d/2), d arbitrary. | PROVED. The phenomenon is known: Zhang (2006, Section 4.4); Barron, Schervish and Wasserman (1999) | C, A |
| Theorem 5.5 (**B′**) | With the likelihood raised to the power α ∈ (0,1), also for a human outside the class: the posterior mean of H²(Q_ν, Q*) has expectation at most [ln(1/w(ν*))/N + α·KL(Q* ‖ Q_ν*)]/(2·min(α,1−α)) for every ν*. | STANDARD: Zhang (2006), Theorem 5.1 | C, A |
| Proposition 5.6 | The posterior with weights w^λ when the human is outside the class: a bound in probability, with the approximation term divided by the confidence level. | PROVED; superseded in expectation by Theorem 5.7 | C; A read the proof |
| Theorem 5.7 (new) | Weights w^λ, λ > 1, a human inside or outside the class: for one posterior draw and for the λ-MAP, E H² ≤ [ln(1/w(ν*))/N + KL(Q* ‖ Q_ν*)/λ]/(2·min(1/λ, 1−1/λ)). | STANDARD for the λ-MAP: Zhang (2006), Theorem 4.1. For the posterior: PROVED here, argument by the second verifier | A (author), E; **not checked by C** |
| Section 6 | All theorems for a general countable class; what changes outside the class. | summary of proved statements | C, A |
| Section 8 | Open questions, and remarks on other parts of the candidate theory. | OPEN | |

**In brief.** (1) *Whole runs from single calls.* Let σ be the expected sum, along the run of one of two answerers, of the squared Hellinger distances between their answers. Then H² of the run laws is at most 4σ, by a potential-function argument of ten lines (Lemma 2.2), and at most c*·σ with c* = 2.964147… by a longer argument of the same kind (Theorem 2.7); explicit examples reach the ratio 2.96399, so the best constant lies between 2.9639 and 2.9642. For the total variation and for single events the same method gives the constants of a single call: TV ≤ σ + √(σ² + 2σ), and an event of probability zero under the other answerer has probability at most 2σ (Lemma 2.10). (2) *R2.* After n rounds of Protocol R, E TV ≤ √(2LK ln2/n) (to first order √(LK ln2/n)), E H² ≤ 2LK ln2/n, and an event that the human system never produces has expected probability at most LK ln2/n in the deployed run, the rate and the constant of the deterministic case. (3) The factor L under the square root is necessary for a stochastic human: for K coins of bias ±δ about LK/ε² answers are needed, whatever the protocol (the proved constants differ by about 10⁴). (4) Theorem A is correct, extends to a human outside the class, and is the progressive mixture rule of the literature applied to whole runs; its statement is false for the per-call mixture, by a factor up to L. (5) Theorem B is correct for all λ > 1 and is, in substance, a theorem of Barron and Cover; at λ = 1 it fails because of memorising hypotheses, which is a known counterexample, and tempering the likelihood (Zhang's theorem) or the oracle inequality for the steeper weights (Theorem 5.7) are the forms that also work outside the class.

## 0. Setting and conventions

**0.1 Samplers and answerers.** X and Y are countable sets. We assume that Y contains a symbol ⊥ ("no answer"). A **sampler** is a probability kernel S(·|x) on Y. A hypothesis that is given as a semimeasure is identified with its completion by ⊥; nothing else about semimeasures is used below. (The scaffold must therefore say what it does with the answer ⊥; if the human never answers ⊥, the completion does not enter any likelihood, but it does enter the law of an imitator's run.)

**0.2 Scaffolds and runs.** A scaffold Π of horizon L consists of a probability space (Ω₀, μ₀) carrying the pair ω₀ = (z, ρ) of the top-level input and the scaffold's own randomness, and of measurable maps next_j : Ω₀ × Y^(j−1) → X ∪ {STOP}, j = 1, …, L. (The outcome map of the candidate theory plays no role in this file.) An **answerer** A is a family of probability kernels A_j(·|ω₀, y_1, …, y_(j−1)) on Y; a sampler S is the answerer A_j(·|ω₀, y_<j) = S(·|x_j) with x_j = next_j(ω₀, y_<j). A run with answerer A is generated as follows: ω₀ ~ μ₀; for j = 1, 2, …, L: x_j := next_j(ω₀, y_<j); if x_j = STOP the run ends, otherwise y_j ~ A_j(·|ω₀, y_<j). The run is τ = (ω₀, y_1, …, y_len(τ)), where len(τ) ≤ L is its number of calls; the inputs x_j are functions of τ. Q_A is the law of τ. The **human system** is Q_P.

*Changes of notation.* The candidate theory uses T both for the number of calls of a run and for the deployed round; here len(τ) is the number of calls and T is the deployed round. It uses ρ for the scaffold's randomness; here ω₀ = (z, ρ), and the letter r is used for root likelihood ratios in Section 2. The candidate lets an answerer see "the history"; here an answerer may also see ω₀, which is more general and changes no proof.

**0.3 Runs as sequences of fixed length.** Put Y′ := Y ∪ {∅} with a new symbol ∅ and y_j := ∅ for j > len(τ). Then τ is identified with (ω₀, y_1, …, y_L) ∈ Ω₀ × Y′^L, and Q_A is the law generated by the kernels
a_j(·|ω₀, y_<j) := A_j(·|ω₀, y_<j) if next_j(ω₀, y_<j) ≠ STOP and no earlier call was STOP; a_j := point mass at ∅ otherwise.
("Otherwise" includes the sequences that the scaffold cannot produce, those with a symbol ∅ before the run has stopped, where next_j is not defined. They have probability zero under every answerer, so nothing depends on this choice.)
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
5. For every event A: (√Q(A) − √P(A))² ≤ 2H². Hence for every η > 0: Q(A) ≤ (1+η)·P(A) + (1 + 1/η)·2H²; in particular Q(A) ≤ 2P(A) + 4H². If P(A) = 0 then Q(A) ≤ H²(2 − H²) ≤ 2H².
6. The function t ↦ √(t(2−t)) is concave and increasing on [0,1]; so E TV ≤ √(E H²·(2 − E H²)) ≤ √(2·E H²) when the pair (P,Q) is random.

*Proof.* (1) Σ√(pq) ≥ Σ min(p,q) = 1 − TV gives H² ≤ TV. By the Cauchy–Schwarz inequality, 2·TV = Σ|√p − √q|(√p + √q) ≤ √(Σ(√p − √q)²)·√(Σ(√p + √q)²) = √(2H²)·√(4 − 2H²). (2) 1 − t ≤ −ln t; and by Jensen's inequality ln Σ_{p>0} p·√(q/p) ≥ Σ_{p>0} p·½ ln(q/p) = −½ KL(P‖Q). (3) Standard; it also follows, with the constant √(1/2) replaced by 1, from (1) and (2). We use the standard form [from memory: for example A. B. Tsybakov, *Introduction to Nonparametric Estimation*, Springer 2009, Lemma 2.5]. (4) BC is concave in each argument because √ is concave; TV is a norm distance; KL(Q‖·) is convex because −ln is. For a map φ, Σ_u √(P(φ⁻¹u)·Q(φ⁻¹u)) ≥ Σ_x √(p(x)q(x)) by the Cauchy–Schwarz inequality in each fibre; for TV the statement is immediate, and for KL it is the log-sum inequality in each fibre. This argument is for countable sets. For laws on a general measurable space (laws of runs with an uncountable Ω₀; the lemma is used there for the indicator of an event of runs, for the projection on the first coordinates and for the map τ ↦ (ω₀, y_j)) the three statements are the data-processing inequality for f-divergences, which is standard: the same proof works with the conditional expectation given φ under the dominating measure ½(P+Q) in place of the sums over a fibre, and Jensen's inequality for the jointly convex functions (u,v) ↦ −√(uv), |u − v| and u·ln(u/v). (5) Apply (4) to the indicator of A: 1 − √(P(A)Q(A)) − √(P(Aᶜ)Q(Aᶜ)) ≤ H², and the left side equals ½(√P(A) − √Q(A))² + ½(√P(Aᶜ) − √Q(Aᶜ))². Then √Q(A) ≤ √P(A) + √(2H²), and (a+b)² ≤ (1+η)a² + (1+1/η)b². If P(A) = 0 the first display reads 1 − √(1 − Q(A)) ≤ H², that is Q(A) ≤ 1 − (1 − H²)² = H²(2 − H²). (6) The second derivative of √(2t − t²) is −(2t − t²)^(−3/2) < 0; then Jensen's inequality and (1). ∎

Item 5 is the form in which closeness in H² is stronger than closeness in total variation: an event that is rare for P is rare for Q at the scale H², not √H².

## 2. Lemma L4: subadditivity of H² for sequentially generated data

### 2.1 What the literature states

The four papers of items 1 to 4 were read by the prover in their arXiv TeX sources (downloaded from arxiv.org/e-print on 14 November 2026). Both verifiers read them again in source (15 and 16 November 2026) and confirmed every statement made about them here. The editor read again, in the TeX sources downloaded on 16 November 2026, the two lemmas of items 1 and 2 (the constants 10²·log n and 7, and the sentence that the second is "an improvement to Lemma A.13 of" the first "that removes a logarithmic factor"). Items 5 to 7 were added after the verification; each says how its source was read.

1. **Dylan J. Foster, Sham M. Kakade, Jian Qian, Alexander Rakhlin, "The Statistical Complexity of Interactive Decision Making", arXiv:2112.13487** (current arXiv version; source files dated 12 July 2023). Convention: D²_H(P,Q) = ∫(√dP − √dQ)², which is 2H² in our convention. The lemma "Subadditivity for squared Hellinger distance" (label `lem:hellinger_chain_rule`; later papers cite it as Lemma A.13) says: for measurable spaces 𝒳_1, …, 𝒳_n and probability kernels P^(i), Q^(i) from 𝒳_1 × ⋯ × 𝒳_(i−1) to 𝒳_i, with P and Q the laws of X_1, …, X_n under X_i ~ P^(i)(·|X_1:i−1) and X_i ~ Q^(i)(·|X_1:i−1),
 D²_H(P,Q) ≤ 10²·log(n)·E_P[Σ_i D²_H(P^(i)(·|X_1:i−1), Q^(i)(·|X_1:i−1))],
and, if all kernels have likelihood ratios bounded by V ≥ e, the same with 3·log(V) in place of 10²·log(n). **This paper does not contain the constant 7.** Its change-of-measure lemma (label `lem:mp_min`) says: for 0 ≤ h ≤ R, |E_P h − E_Q h| ≤ √(2R(E_P h + E_Q h)·D²_H(P,Q)), and E_P h ≤ 3E_Q h + 4R·D²_H(P,Q).
2. **Dylan J. Foster, Yanjun Han, Jian Qian, Alexander Rakhlin, "Online Estimation via Offline Estimation: An Information-Theoretic Framework", arXiv:2404.10122.** The lemma "Subadditivity for squared Hellinger distance" in its technical appendix (cited by the two papers below as Lemma D.2) has the same hypotheses and the conclusion
 D²_H(P,Q) ≤ 7·E_P[Σ_i D²_H(P^(i)(·|X_1:i−1), Q^(i)(·|X_1:i−1))].
Its proof applies the "cut-and-paste" property and Theorem 7 of T. S. Jayram, "Hellinger strikes back: a note on the multi-party information complexity of AND", APPROX-RANDOM 2009, LNCS 5687, pp. 562–573 (not read by the prover, the verifiers or the editor); the constant is 2/Π_{i≥1}(1 − 2^(−i)) = 6.93, rounded up.
3. **Fan Chen, Dylan J. Foster, Yanjun Han, Jian Qian, Alexander Rakhlin, Yunbei Xu, "Assouad, Fano, and Le Cam with Interaction: A Unifying Lower Bound Framework and Characterization for Bandit Learnability", arXiv:2410.05117.** Restates the lemma with the constant 7 in the convention H² = 1 − Σ√(pq) (it defines squared Hellinger distance as the f-divergence with f(x) = ½(√x − 1)²), and attributes it to Jayram (2009), with pointers to Lemma 11.5.3 of J. C. Duchi's *Lecture Notes on Statistics and Information Theory* (not read by the prover, the verifiers or the editor) and to item 2.
4. **Dylan J. Foster, Adam Block, Dipendra Misra, "Is Behavior Cloning All You Need? Understanding Horizon in Imitation Learning", arXiv:2407.15007** (NeurIPS 2024 according to the digest `understand/ask-for-help.md`; source files dated 3 December 2024). Convention D²_H = ∫(√dP − √dQ)². It states no subadditivity lemma of its own; in the proofs of its lower bounds it uses "Lemma D.2 of Foster et al. (2024)", item 2, with the constant 7. It states the change-of-measure lemma |E_P h − E_Q h| ≤ √(½(E_P h² + E_Q h²)·D²_H(P,Q)), and E_P h ≤ 2E_Q h + R·D²_H(P,Q) for h ∈ [0,R]; and the proposition on log-loss behaviour cloning: for a finite class Π containing the expert, with probability at least 1 − δ, D²_H(P^π̂, P^π*) ≤ 2·log(|Π|/δ)/n (n trajectories, π̂ the maximum-likelihood policy).

5. **Guy Blanc, Clément L. Canonne, Erik Waingarten, "Instance-Optimal Uniformity Testing and Tracking", arXiv:2508.02637** (FOCS 2025 according to the arXiv comment as reported by the second verifier; read in the TeX source by the second verifier and, on 16 November 2026, by the editor). It still states the lemma with "an absolute constant c ≤ 7", citing Jayram (2009) and the paper of item 2, and calls it a "recent (and surprisingly non-obvious) result".
6. **The two-sided bound of Theorem 2.1(b) is in the literature for Markov chains.** Emmanuelle Clément, "Hellinger and total variation distance in approximating Lévy driven SDEs", arXiv:2103.09648 (source dated 8 March 2022; read in the TeX source by the editor on 16 November 2026), Proposition 2.1: for two homogeneous Markov chains with transition densities p and q and the same initial value, and with the laws Pⁿ, Qⁿ of the first n steps, H²(Pⁿ, Qⁿ) ≤ ½·Σ_{i=1}^n (E H²_{X_(i−1)}(p,q) + E H²_{Y_(i−1)}(p,q)), in the convention H² = ∫(√p − √q)². Its proof is the telescoping of the Hellinger affinity used for Theorem 2.1(a), (b) below.
7. **Filtered experiments (not opened).** For two probability measures on a filtered space the Hellinger process of order ½ is, in discrete time and in the notation of 2.2, the predictable process Σ_{i ≤ n} h_i, and the identity of Theorem 2.1(a) is the discrete form of the equation satisfied by the Hellinger integral. Yu. M. Kabanov, R. Sh. Liptser, A. N. Shiryaev, "On the variation distance for probability measures defined on a filtered space", *Probability Theory and Related Fields* 71:19–35, 1986, bound the variation distance between the restrictions of the two measures to a stopping time from above and below in terms of this process; the same bounds are in J. Jacod and A. N. Shiryaev, *Limit Theorems for Stochastic Processes*, Springer, 1987 (second edition 2003), Chapter V, Section 4. Title, journal and this description are from the publisher's record as returned by web searches of the second verifier and of the editor; the paper and the book were not opened (the publisher's host is not reachable from these sessions). From the second verifier's memory the upper bound is ‖P_T − P̃_T‖ ≤ 4·(E h_T)^(1/2), with the expectation under one of the two measures and ‖·‖ twice the total variation; in the notation of 2.2 this reads TV(P,Q) ≤ 2·√(E_P Σ_i h_i). The constant is not confirmed. Lemma 2.10(c) below implies this inequality and is proved here independently of it.

The inequality is homogeneous of degree one in the divergence, so its constant is the same in both conventions. So the literature gives c₀ = 7 for L4, in the paper of item 2 and not in the one named by the candidate theory. Web searches by the prover and by both verifiers found no statement of the inequality with H² on the left with a constant below 7 and no statement of the best constant; the searches were not exhaustive, and two possible sources could not be opened (Lemma 11.5.3 of Duchi's notes, item 3, and a course note "Chain rule for squared Hellinger distance (following T. S. Jayram)" on a Yale statistics page, which `research/sections/related-work.md` names). For the total variation on the left a one-sided bound with an absolute constant is classical (item 7). Theorem 2.1 below gives c₀ = 4 with a self-contained proof of a few lines, and Theorem 2.7 gives c₀ = c* = 2.964147…, which is below 2.9642. Section 2.4 also gives examples: no constant below 1.707 is possible (exact calculation), and none below 2.9639 (evaluation of an explicit example, confirmed in 30-digit arithmetic). Section 2.5 treats the total variation and single events directly, with the constants of a single call.

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

So runs of variable length, inputs that depend on the earlier answers, and answerers that do or do not see the history are all covered; the expectation is under the run of one of the two answerers, and H² is symmetric, so either may be chosen. Below we write **σ_A := E_{Q_A}[Σ_{j ≤ len(τ)} h_j]** for the expected sum of the per-call squared Hellinger distances along the run of A.

The third and fourth statements are consequences of the first, and they are not the best statements of their kind. For the total variation, and for a bound on Q_A(G) in terms of Q_B(G), Corollary 2.11 (Section 2.5) has the constants of a single call: TV(Q_A, Q_B) ≤ σ_A + √(σ_A² + 2σ_A), which is √(2σ_A) to first order where the corollary above has √(8σ_A), and Q_A(G) ≤ 2Q_B(G) + 4σ_A. The fourth statement above goes in the other direction (the probability under B, with the sum taken along the runs of A); Corollary 2.11 does not cover that direction, and Theorem 3.1(c) uses it.

### 2.3 Two complements

**Proposition 2.4 (inputs that do not depend on the answers).** In the setting of Theorem 2.1 suppose p_i(·|x_<i) and q_i(·|x_<i) depend on x_0 only. Then H²(P,Q) = E[1 − Π_i(1 − h_i(X_0))] ≤ E[Σ_i h_i(X_0)], the expectation being over X_0 ~ μ₀. In particular, if next_j depends on ω₀ only and S, S′ are samplers, then H²(Q_S, Q_S′) ≤ E_{μ₀}[Σ_j H²(S,S′)(x_j)]: the constant in L4 is 1.

*Proof.* Given X_0 = x_0 both laws are product measures, with BC equal to Π_i(1 − h_i(x_0)); and 1 − Π_i(1 − h_i) ≤ Σ_i h_i. ∎

**Proposition 2.5 (converse, with a factor n).** In the setting of Theorem 2.1, E_P[h_i] + E_Q[h_i] ≤ 2·H²(P,Q) for every i; hence E_P[Σ_i h_i] ≤ 2n·H²(P,Q), and for answerers E_{Q_A}[Σ_j h_j] ≤ 2L·H²(Q_A, Q_B). The factor n cannot be replaced by a constant.

*Proof.* Let P_i, Q_i be the laws of X_≤i under P and Q, with densities P_<i·p_i and Q_<i·q_i. Then BC(P_i, Q_i) = ∫μ₀ Σ_{x_<i} √(P_<i·Q_<i)·(1 − h_i(x_<i)) ≤ ∫μ₀ Σ_{x_<i} ½(P_<i + Q_<i)(1 − h_i(x_<i)) = 1 − ½E_P[h_i] − ½E_Q[h_i]. So E_P[h_i] + E_Q[h_i] ≤ 2H²(P_i, Q_i) ≤ 2H²(P,Q), the last step by Lemma 1.1(4), since X_≤i is an image of the whole sequence. (In its one-sided form for two variables, E_P[h] ≤ 2H², this is a lemma of the paper of item 3 of Section 2.1, and with the constant 4 of the paper of item 1; both read in source.) For the last claim take the scaffold: call 1 at x_0 with answers in {0,1}; after the answer 1, n − 1 further calls at x_1, …, x_(n−1); after the answer 0, stop. Let S(1|x_0) = ε, S′(1|x_0) = 0, S(·|x_i) = point mass at 0 and S′(·|x_i) = point mass at 1 for i ≥ 1. Then H²(Q_S, Q_S′) = 1 − √(1−ε) ≤ ε and E_{Q_S}[Σ_j h_j] = 1 − √(1−ε) + ε(n−1) ≥ (n−1)·H²(Q_S, Q_S′). ∎

Proposition 2.5 says what whole-run closeness of two samplers does *not* give: closeness of single calls along the run of one of them, except with a factor L. In the example S′ never enters the branch in which it differs from S at every call.

### 2.4 The best constant

Write c₀* for the smallest constant for which Theorem 2.1(c) holds for all n and all kernels. Theorem 2.1(c) says c₀* ≤ 4; by Proposition 2.4 the constant 1 suffices without adaptivity, and by Theorem 2.1(b) the constant 1 suffices for the two-sided bound. This subsection encloses c₀* between 2.9639 and 2.9642: Theorem 2.7 proves c₀* ≤ c* = 2.964147… < 2.9642, and explicit examples give c₀* ≥ 1.7071 (exact, two calls) and c₀* ≥ 2.96399 (many calls; a sum of positive terms evaluated in 30-digit arithmetic). The rest of this file uses the constant 4 of Theorem 2.1, whose proof is ten lines; Theorem 2.7 allows 4 to be replaced by c* wherever Theorem 2.1(c) is used. The constant 4 is the best that the potential of Lemma 2.2 gives: for Λ ≤ 2, a variable r with Λr ≤ 2 almost surely and E r² = 1, the one-step ratio [E U(Λr) − U(Λ)]/(1 − E r) equals 2Λ, which comes arbitrarily close to 4. More generally the potentials (γ/2)·((m − x)₊)² of Lemma 2.10 give the constant m²/(m − 1) for H², which is smallest, and equal to 4, at m = 2.

**Example 2.6 (two calls; c₀* ≥ (2+√2)/2 = 1.7071).** Scaffold: call 1 at x_0 with answers in {0,1}; after the answer 1, call 2 at x_1; after 0, stop. Samplers: S(1|x_0) = a, S′(1|x_0) = b, S(·|x_1) = point mass at 0, S′(·|x_1) = point mass at 1. The possible runs are (0), (1,0), (1,1), with S-probabilities 1−a, a, 0 and S′-probabilities 1−b, 0, b. So H²(Q_S, Q_S′) = 1 − √((1−a)(1−b)), while E_{Q_S}[Σ_j h_j] = h_1 + a with h_1 = 1 − √((1−a)(1−b)) − √(ab). With a = ε and b = s²ε, as ε → 0: H² = ½(1+s²)ε + O(ε²) and E_{Q_S}[Σ_j h_j] = ½(s² − 2s + 3)ε + O(ε²). The ratio tends to (s²+1)/(s²−2s+3), which is largest at s = 1+√2, where it equals (s+1)/2 = (2+√2)/2. (Section 7, script `hellinger-runs_l4_check.py`, part (d): ratio 1.70710 at ε = 10⁻⁵.) ∎

**Theorem 2.7 (the constant c* < 3).** For q ≥ 0 let g(q) := 1 + q·e^(q²/4)·(1/√2 + (√π/2)·erf(q/2)) and, for 0 ≤ q < √2, k(q) := 1/(1 − q²/2). Let q₀ be the smallest positive root of g = k, and c* := k(q₀) = 1/(1 − q₀²/2). Then, in the setting of Theorem 2.1,

 H²(P,Q) ≤ c*·E_P[Σ_{i=1}^n h_i],

and Corollary 2.3 holds with c* in place of 4 (and 2c*, 4c* in place of 8, 16). The equation g = k has exactly one root in (0, √2) (Step 0, (iii′)), and

 1.15120357 < q₀ < 1.15120358,  2.96414712 < c* < 2.96414723;

in particular **c* < 2.9642**. (g − k is positive near 0, since g(q) − k(q) = q/√2 + O(q²). Evaluated with interval arithmetic, erf by its power series with the tail bounded by the first omitted term, g − k lies in [2.0135·10⁻⁸, 2.0136·10⁻⁸] at q = 1.15120357 and in [−4.6888·10⁻⁸, −4.6887·10⁻⁸] at q = 1.15120358; with the uniqueness of the root this gives the enclosure of q₀, and k is increasing. To 30 digits q₀ = 1.15120357300424285968266629425 and c* = 2.96414715730767803218167583868. Section 7.6.)

*Proof.* Write c for c*. *Step 0: three functions.* For q ∈ (0, q₀] put s(q) := 1/g(q), p(q) := 2(1 − s(q))/q and r(q) := (p(q) − q)/2. Differentiating, g′(q) = (g(q) − 1)(1/q + q/2) + q/2 > 0. Hence:

(i) s is strictly decreasing, s(q) → 1 as q → 0, and s(q₀) = 1/c = 1 − q₀²/2 =: s₀. Also p(q) → √2 and r(q) → 1/√2 as q → 0.
(ii) r ≥ 0 on (0, q₀] and r(q₀) = 0: indeed r ≥ 0 is equivalent to s ≤ 1 − q²/2, that is to g ≥ k, which holds on (0, q₀] with equality at q₀ by the choice of q₀.
(iii) ds/dq = −g′/g² = −(s/(2q))·(2(1−s) + q²); dp/dq = (q²s − 2(1−s)²)/q²; therefore d(p/s)/dq = (s·dp/dq − p·ds/dq)/s² = 1/s > 0, and dr/dq = ½(dp/dq − 1) = −(1−s)(q² + 2(1−s))/(2q²), so that (dr/dq)/(ds/dq) = (1−s)/(sq) = p/(2s).
(iii′) *The root is unique.* The formulas of (iii) hold for all q > 0, with s = 1/g(q) ∈ (0,1). So dr/dq = −(1−s)(q² + 2(1−s))/(2q²) < 0 and r is strictly decreasing on (0, ∞). Moreover r(q) → 1/√2 > 0 as q → 0, and r(q) = (1−s)/q − q/2 < 1/q − q/2 ≤ 0 for q ≥ √2. Hence r has exactly one zero, it lies in (0, √2), and on (0, √2) the zeros of r are the roots of g = k (by the equivalence in (ii)). So g = k has exactly one root in (0, √2), namely q₀.

So q, p and r may be regarded as continuous functions of s ∈ [s₀, 1] (with q(1) = 0, p(1) = √2, r(1) = 1/√2), differentiable on (s₀, 1), with

 p·q = 2(1−s), p − q = 2r ≥ 0, dr/ds = p/(2s), and s ↦ p(s)/s strictly decreasing.

(iv) For s, s′ ∈ [s₀, 1]: φ(s, s′) := p(s)·s′ − s·q(s) − 2s·r(s′) ≥ 0. Indeed φ(s, s) = s(p − q − 2r) = 0, and ∂φ/∂s′ = p(s) − s·p(s′)/s′ = s·(p(s)/s − p(s′)/s′), which is ≤ 0 for s′ < s and ≥ 0 for s′ > s.
(v) For s ∈ [s₀, 1] and s′ ≥ 1: ψ(s, s′) := p(s)·s′ − s·q(s) − 2s·√(s′ − ½) ≥ 0. Indeed ψ(s, 1) = φ(s, 1) ≥ 0 because r(1) = 1/√2, and ∂ψ/∂s′ = p(s) − s/√(s′ − ½) ≥ p(s) − √2·s = s·(p(s)/s − p(1)/1) ≥ 0.

*Step 1: the potential.* Let V(x) := 0 for 0 ≤ x ≤ 1, V(x) := c·r(x/c)² for 1 ≤ x ≤ c, V(x) := x − c/2 for x ≥ c, and U(x) := V(x) − x. V is continuous (r(s₀) = 0 and c·r(1)² = c/2), V ≥ 0 = V(1), and U is bounded.

*Step 2: for every Λ > 0 there is μ ≥ 0 with U(a) ≤ U(Λ) + c(1 − a/Λ) + μ(a²/Λ² − 1) for all a ≥ 0.* Equivalently V(a) ≤ ζ_Λ(a) := U(Λ) + c(1 − a/Λ) + μ(a²/Λ² − 1) + a. We choose μ and compute ζ_Λ in three ranges.

* Λ ≤ 1: μ := (c − Λ)/2. With U(Λ) = −Λ one finds ζ_Λ(a) = ((c−Λ)/(2Λ²))·(a − Λ)².
* 1 ≤ Λ ≤ c, s := Λ/c: μ := c·p(s)²/4. With U(Λ) = c·r² − cs, the coefficients of ζ_Λ(a) are p²/(4cs²) for a², 1 − 1/s = −pq/(2s) for a, and c(r² + 1 − s − p²/4) = c·q²/4 for the constant (use pq = 2(1−s) and p − q = 2r). So ζ_Λ(a) = (c/(4s²))·(p(s)·a/c − s·q(s))².
* Λ ≥ c: μ := c/2. With U(Λ) = −c/2, ζ_Λ(a) = a(1 − c/Λ) + c·a²/(2Λ²).

(At Λ = 1 and at Λ = c the two applicable formulas agree, because p(s₀) = q(s₀) = q₀ with q₀² = 2(c−1)/c, and p(1) = √2, q(1) = 0.) Now let a ≥ 0.

*a ≤ 1.* V(a) = 0, and ζ_Λ(a) ≥ 0 in all three ranges (a square in the first two; in the third because Λ ≥ c).
*1 ≤ a ≤ c, with s′ := a/c ∈ [s₀, 1].* For 1 ≤ Λ ≤ c, by (iv), p(s)·s′ − s·q(s) ≥ 2s·r(s′) ≥ 0, hence ζ_Λ(a) = (c/(4s²))(p(s)s′ − sq(s))² ≥ c·r(s′)² = V(a). For Λ ≤ 1, the three positive factors of ζ_Λ(a) are decreasing in Λ (as a ≥ 1 ≥ Λ), so ζ_Λ(a) ≥ ζ_1(a) ≥ V(a). For Λ ≥ c, ∂ζ_Λ(a)/∂Λ = (c·a/Λ²)(1 − a/Λ) ≥ 0, so ζ_Λ(a) ≥ ζ_c(a) ≥ V(a).
*a ≥ c, with s′ := a/c ≥ 1.* For 1 ≤ Λ ≤ c, by (v), p(s)s′ − sq(s) ≥ 2s·√(s′ − ½) ≥ 0, hence ζ_Λ(a) ≥ c(s′ − ½) = a − c/2 = V(a). For Λ ≤ 1 again ζ_Λ(a) ≥ ζ_1(a) ≥ V(a). For Λ ≥ c, ζ_Λ(a) − V(a) = (c/2)(1 − a/Λ)² ≥ 0.

*Step 3: conclusion.* Let Λ ≥ 0 be a number and r̃ ≥ 0 a random variable with E r̃² ≤ 1. For Λ > 0, Step 2 with a = Λ·r̃ and expectations give E U(Λr̃) ≤ U(Λ) + c(1 − E r̃) + μ(E r̃² − 1) ≤ U(Λ) + c(1 − E r̃); for Λ = 0 this is trivial. This is Lemma 2.2(ii) with (U, c) in place of (½(2−x)₊², 4). As in the proof of Theorem 2.1(c), E_P U(Λ_n) ≤ U(1) + c·E_P Σ_i h_i; and since V ≥ 0 = V(1), U(x) ≥ U(1) + 1 − x, so E_P U(Λ_n) ≥ U(1) + 1 − E_P Λ_n = U(1) + H²(P,Q). ∎

**Example 2.8 (many calls; computed ratios 2.0997 and 2.9639).** Both examples are pairs of samplers on a scaffold whose input at each call is a "level" k, a function of the earlier answers.

(i) *A lattice walk.* Fix β > 1 and an integer m. The level starts at 0. At a level 0 ≤ k < m the answer is "up" or "down" and the level moves to k ± 1; S answers "up" with probability 1/(1+β²), S′ with probability β²/(1+β²). The run stops when the level reaches −1. At level m there is one last call, at which S and S′ answer with different point masses. The root likelihood ratio Λ is β^k at level k, each call below level m has h = (β−1)²/(1+β²), and with π := (β²−1)/(β^(2m+2) − 1) (the S-probability of reaching level m, from the martingale Λ²):
 H²(Q_S, Q_S′) = 1 − (1−π)/β,  E_{Q_S}[Σ_j h_j] = ((β−1)/(β+1))·((1−π) − mπ) + π.
(For an unbounded horizon; the truncation to L calls converges to these values as L grows.) As β → 1 with β^m = b fixed the ratio tends to 2(b²+1)/(b² + 3 − 2 ln b), with maximum 2.0997 at b = 4.59. (Section 7, part (e).)

(ii) *The drift-and-drop strategy for which the proof of Theorem 2.7 is tight.* Fix β > 1. At level k = 0, 1, 2, … the answer is "up" (the level becomes k+1) or "drop" (the run stops). With numbers d_k ∈ [0,1) and π_k := (β²−1)/(β²−d_k²), let S answer "drop" with probability π_k and S′ with probability π_k·d_k² (then S′ answers "up" with probability (1−π_k)β²). The root likelihood ratio is β^k at level k, and by Theorem 2.1(a), with R_k := Π_{i<k}(1−π_i) and h_k = 1 − π_k d_k − (1−π_k)β,
 H²(Q_S, Q_S′) = Σ_k R_k β^k h_k,  E_{Q_S}[Σ_j h_j] = Σ_k R_k h_k.
Take d_k := q(s)/p(s) at s = β^k/c* in the notation of Theorem 2.7 when 1 < β^k < c*, d_k := 0 when β^k ≥ c*, and d_0 := β^(−0.01). (A drop from the level Λ = c*·s leads to the level Λ·q/p, which is at most 1 by (iv) with s′ = s₀ and is the point at which the parabola ζ_Λ vanishes; so in the limit β → 1 every step is an equality case of Step 2.) With β = 1.0001 and the run truncated when β^k exceeds 10⁶ (138163 levels), the computed ratio is 2.96399. (Section 7, script `hellinger-runs_l4_lp.py`, part (D). The sums have positive terms and were evaluated in double precision.)

So **2.9639 ≤ c₀* ≤ 2.9642** (more precisely 2.96399 ≤ c₀* ≤ c* < 2.96415). The lower bound is the evaluation of an explicit example; the first verifier repeated it in 30-digit arithmetic in two ways, by the formula of Theorem 2.1(a) and directly as 1 − Σ over runs of √(Q_S·Q_S′), and obtained 2.82406784, 2.94927077, 2.96264616, 2.96399241 for β = 1.1, 1.01, 1.001, 1.0001 (Section 7.6); the pair is a legitimate pair of samplers because π_k·d_k² + (1−π_k)·β² = 1. For these four values the gap c* − ratio is about 1.5·(β − 1). In double precision the same construction, still truncated at the level 10⁶, gives 2.964127 for β = 1.00001 (1.38 million levels) and 2.964141 for β = 1.000001 (gaps 2.0·10⁻⁵ and 6.6·10⁻⁶). The prover expects c₀* = c*; a proof would have to show that the ratio of the strategy (ii) converges to c* as β → 1 and the truncation level grows, which the computation indicates but which is not proved here. As a further check, a linear programme for the best pair (U, c) against adversaries restricted to a geometric grid of ratio u gives 2.827, 2.864, 2.890, 2.906 for u = 1.05, 1.035, 1.025, 1.018 (Section 7).

**Remark 2.9 (the route sketched in the candidate theory).** The inequality quoted there is correct: for 0 ≤ g ≤ R, E_Q g − E_P g = Σ g(√q − √p)(√q + √p) ≤ √(2R·H²)·√(2(E_P g + E_Q g)) ≤ η(E_P g + E_Q g) + R·H²/η for every η ∈ (0,1), so E_Q g ≤ ((1+η)/(1−η))·E_P g + R·H²(P,Q)/(η(1−η)), which is (5/3)E_P g + (16/3)R·H² at η = ¼. Stopping the sequence before the predictable sum Σ h_i exceeds a threshold θ, and treating the stopped part with Theorem 2.1(b) and this inequality, should also prove the lemma with some absolute constant. The prover's accounting of that route gave the constant 1/(1−√(2θ)) + 1/θ + √(2/(θ(1−√(2θ)))), about 12.6 at θ = ¼; that proof is not written out, the figure was checked by nobody (both verifiers could confirm only its arithmetic), and it is not a result of this file and is not used anywhere.

### 2.5 Total variation and single events, without the detour through H²

Corollary 2.3 obtains its bounds on the total variation and on events from H² ≤ 4σ and from the relations of Lemma 1.1. Each of the two steps is sharp, but not for the same pairs of laws: the pairs of Example 2.8 that come near H² = 2.96·σ have a small total variation. A potential argument of the same kind as Lemma 2.2, applied to the total variation and to events directly, gives the constants that hold for a single call. (This subsection was added after the verification. The lemma and its proof are due to the second verifier, `verification/hellinger-runs-attack.md`, finding M1, where it is called Lemma X. The editor checked the proof line by line and tested every part of it numerically, Section 7.6; no one else has checked it.)

**Lemma 2.10 (total variation and events from single calls).** In the setting of Theorem 2.1 let σ := E_P[Σ_{i=1}^n h_i].
(a) For every event G and every η > 0: P(G) ≤ (1+η)·Q(G) + 2(1 + 1/η)·σ. In particular P(G) ≤ 2Q(G) + 4σ.
(b) If Q(G) = 0, then P(G) ≤ 2σ.
(c) TV(P,Q) ≤ φ(σ), where **φ(u) := min(1, u + √(u² + 2u))**. Moreover φ(u) ≤ 2√u for all u ≥ 0, and φ(u) = √(2u) + O(u) as u → 0.

*Proof.* *One step.* For numbers m > 0 and γ > 0 let U(x) := (γ/2)·((m − x)₊)² for x ≥ 0. For every number Λ ≥ 0 and every random variable r ≥ 0 with E r² ≤ 1,

 E U(Λr) ≤ U(Λ) + γm²·(1 − E r).  (∗)

Note E r ≤ √(E r²) ≤ 1. If Λ ≤ m: pointwise U(Λr) ≤ (γ/2)(m − Λr)², so E U(Λr) ≤ (γ/2)(m² − 2mΛ·E r + Λ²·E r²) ≤ (γ/2)(m² − 2mΛ·E r + Λ²) = U(Λ) + γmΛ(1 − E r) ≤ U(Λ) + γm²(1 − E r). If Λ > m: U(Λ) = 0, and pointwise (m − Λr)₊ ≤ m(1 − r)₊ (if r ≥ 1 both sides vanish; if r < 1 then m − Λr ≤ m − mr); so E U(Λr) ≤ (γ/2)m²·E(1 − r)² ≤ (γ/2)m²(2 − 2E r) = γm²(1 − E r). For m = 2 and γ = 1 this is Lemma 2.2(ii).

*Summation.* As in the proof of Theorem 2.1(c): conditionally on 𝓕_(i−1), Λ_(i−1) is a constant and r_i is a non-negative variable with conditional second moment at most 1 and conditional mean 1 − h_i, by (F1) and (F2). So E_P[U(Λ_i) | 𝓕_(i−1)] ≤ U(Λ_(i−1)) + γm²·h_i, and since U is bounded,

 E_P U(Λ_n) ≤ U(1) + γm²·σ.  (∗∗)

*The density ratio.* Let p and q be the densities of P and Q with respect to μ₀ ⊗ counting measure. On {p > 0}, which has P-probability one, q/p = Λ_n². Hence Q(G) ≥ ∫_{G ∩ {p > 0}} q = E_P[1_G·Λ_n²] for every event G, and TV(P,Q) = ∫(p − q)₊ = E_P[(1 − Λ_n²)₊].

(a) Take m = 1 and γ = 2(1+η)/η. Then U(1) = 0 and γm² = 2(1 + 1/η). Moreover U(x) ≥ 1 − (1+η)x² for all x ≥ 0: for x ≤ 1 the difference of the two sides is (1 − (1+η)x)²/η ≥ 0, and for x > 1 the right side is negative. Therefore P(G) − (1+η)·Q(G) ≤ E_P[1_G·(1 − (1+η)Λ_n²)] ≤ E_P[1_G·U(Λ_n)] ≤ E_P U(Λ_n) ≤ 2(1 + 1/η)·σ, by (∗∗).

(b) Let η → ∞ in (a). (Directly, without a potential: if Q(G) = 0 then q = 0 almost everywhere on G, so P(G) ≤ P(q = 0) ≤ E_P Σ_i a_i with a_i := p_i({x : q_i(x|X_<i) = 0} | X_<i), by the union bound over the step at which a factor of q vanishes; and h_i ≥ 1 − √(1 − a_i) ≥ a_i/2, because Σ_x √(p_i q_i) ≤ √(p_i({q_i > 0}))·√(q_i({q_i > 0})) ≤ √(1 − a_i) by the Cauchy–Schwarz inequality.)

(c) Take m > 1 and γ = 2/(m² − 1). Then U(x) ≥ (1 − x²)₊ for all x ≥ 0: for x ≤ 1 the difference of the two sides is (1 − mx)²/(m² − 1) ≥ 0, and for x > 1 the right side is 0. So TV(P,Q) = E_P[(1 − Λ_n²)₊] ≤ E_P U(Λ_n) ≤ U(1) + γm²σ = (m−1)/(m+1) + 2m²σ/(m² − 1), by (∗∗). With v := m − 1 > 0 the right side is [v² + 2σ(1+v)²]/(v(v+2)). If σ = 0 then P = Q by Theorem 2.1(c). Otherwise choose v := σ + √(σ² + 2σ), the positive root of v² = 2σ(1+v); then the numerator is v² + v²(1+v) = v²(v+2), and the bound equals v. With TV ≤ 1 this is TV ≤ φ(σ). Next, u + √(u² + 2u) ≤ 2√u is equivalent, for u ≤ 4, to u² + 2u ≤ (2√u − u)² = 4u − 4u^(3/2) + u², that is to √u ≤ ½; and for u > ¼ we have 2√u > 1 ≥ φ(u). Finally √(u² + 2u) = √(2u)·√(1 + u/2). ∎

**Corollary 2.11 (answerers on a scaffold).** Let A, B be answerers on a scaffold and σ_A as defined after Corollary 2.3. Then

 TV(Q_A, Q_B) ≤ φ(σ_A) ≤ 2·√σ_A,
 Q_A(G) ≤ (1+η)·Q_B(G) + 2(1 + 1/η)·σ_A for every event G of runs and every η > 0, in particular Q_A(G) ≤ 2Q_B(G) + 4σ_A,
 Q_A(G) ≤ 2σ_A if Q_B(G) = 0.

If S and S′ are samplers and k ≥ 1, the joint laws of k independent runs satisfy TV(Q_S^⊗k, Q_S′^⊗k) ≤ φ(k·σ_S).

*Proof.* Use the representation 0.3 as in the proof of Corollary 2.3, with P = Q_A and Q = Q_B, and Lemma 2.10. For the last statement apply the first to the scaffold that draws k independent copies of ω₀ and then runs Π k times in succession: its horizon is kL, a sampler answers its calls as it answers those of Π, and its expected sum of per-call distances is k·σ_S. ∎

**Remark 2.12 (the constants are those of one call; what the lemma does not give).** (i) For one call (n = 1) and η > 0, the two-point laws p = (1−a, a) and q = (1 − a/(1+η)², a/(1+η)²), with G the second point, have P(G) − (1+η)Q(G) = aη/(1+η) and h_1 = (a/2)·(η/(1+η))² + O(a²), so the ratio tends to 2(1 + 1/η) as a → 0: the constant of (a) cannot be lowered, even for one call. With q = (1, 0) the same pair has P(G)/h_1 → 2: the constant of (b) cannot be lowered. For p = (½+t, ½−t) and q = (½−t, ½+t), TV = √(h_1(2 − h_1)): the factor √2 in φ(σ) = √(2σ) + O(σ) cannot be lowered. So for these one-sided statements the dependence of the inputs on the answers costs nothing, to first order, whereas for H² itself it costs a factor between 2.9639 and 2.9642 (Section 2.4). (ii) In exact computations on trees of depth up to 4 the second verifier found, for σ at most 0.001, 0.01, 0.05, 0.1, 0.2, total variations up to 0.0447, 0.141, 0.322, 0.436, 0.600, where φ(σ) is 0.0457, 0.152, 0.370, 0.558, 0.863 and the bound √(8σ) of Corollary 2.3 is 0.089, 0.283, 0.632, 0.894, 1 (Section 7.6). (iii) The lemma bounds the probability under P, the law along whose sequences the sum σ is taken. A bound on Q(G) in terms of P(G) and σ, with the sum still under P, is available only through H² (Corollary 2.3, fourth statement). (iv) In one call Pinsker's inequality gives TV ≤ √(KL/2), which is better by the factor √2 than TV ≤ √(2H²) with H² ≤ KL/2. Whether the sum of the per-call divergences KL(q_i‖p_i) under P controls TV(P,Q) with the constant of Pinsker's inequality when the inputs depend on the answers is not decided here (it does when they do not: Theorem 3.1(d)). (v) If the upper bound recalled in Section 2.1, item 7, is quoted correctly, it is the inequality TV ≤ 2√σ, which (c) implies.

## 3. Theorem R2: whole runs under the rehearsal protocol

### 3.1 The upper bound

**Protocol R** (candidate theory, Section 3). For t = 1, …, n: (1) M^(t) := M_{D_(t−1)}, the mixture given the pairs collected before round t; (2) a run τ_t of Π is generated with the sampler M^(t) answering every call, with fresh randomness; (3) J_t is drawn uniformly from {1, …, L}, independently of everything else; if J_t ≤ len(τ_t), the input x_(t,J_t) of call J_t is put to the human, who answers y ~ P(·|x_(t,J_t)), and the pair is added to the data. Deployment: T is uniform on {1, …, n} and independent of everything else, and Π is run with M^(T).

Three things are part of this definition and are used silently below. (i) **n counts rounds.** A round whose run has fewer than J_t calls asks nothing, so the human answers at most n questions; the expected number of questions is Σ_t E[len(τ_t)]/L, which is much smaller than n when most runs are much shorter than the longest one. (If J_t is drawn uniformly from the calls that the run of round t made, every round with at least one call asks a question, and R1 and Theorem 3.1 hold with the same bounds: Appendix A, the paragraph on this variant.) (ii) **L is the largest number of calls of a run and must be known to the protocol.** (iii) **Closed system.** The deployed run has the same scaffold and the same law μ₀ of ω₀ = (z, ρ) as the rehearsal runs; this is what Q_{M^(T)} means. A top-level input outside the support of μ₀, or a larger scaffold, is outside every statement of this section.

**Theorem R1** (candidate theory; proof in Appendix A). Under A1, A2, A3, with E denoting the expectation over the data,
 Σ_{t=1}^n E[E_{Q_{M^(t)}} Σ_j KL(P ‖ M^(t))(x_j)] ≤ L·K ln2.
Here KL(P‖M^(t))(x) ≤ ln(1/w_{D_(t−1)}(P)) < ∞ for every x, so every term is finite.

**Theorem 3.1 (R2).** Assume A1, A2, A3 and Protocol R, and let E be the expectation over the data and T. Put

 **s := LK ln2/(2n)**, and φ(u) := min(1, u + √(u² + 2u)) as in Lemma 2.10.

(a) E[H²(Q_{M^(T)}, Q_P)] ≤ 4s = 2LK ln2/n.
(b) E[TV(Q_{M^(T)}, Q_P)] ≤ φ(s) ≤ 2√s = √(2LK ln2/n), and φ(s) = √(LK ln2/n)·(1 + O(√(LK/n))). In particular E[TV(Q_{M^(T)}, Q_P)] ≤ ε as soon as n ≥ (1+ε)·LK ln2/ε² (0 < ε ≤ 1).
(c) Let G be an event of runs, fixed before the data are seen, and η > 0. Then E[Q_{M^(T)}(G)] ≤ (1+η)·Q_P(G) + (1 + 1/η)·LK ln2/n. In particular E[Q_{M^(T)}(G)] ≤ 2Q_P(G) + 2LK ln2/n, and **if Q_P(G) = 0 then E[Q_{M^(T)}(G)] ≤ LK ln2/n**. In the other direction, Q_P(G) ≤ (1+η)·E[Q_{M^(T)}(G)] + (1 + 1/η)·4LK ln2/n.
(d) If the inputs of Π do not depend on the answers (next_j is a function of ω₀ only, the decision to stop included), then E[KL(Q_P ‖ Q_{M^(T)})] ≤ LK ln2/n, E[TV(Q_{M^(T)}, Q_P)] ≤ √(LK ln2/(2n)), E[H²(Q_{M^(T)}, Q_P)] ≤ LK ln2/(2n), and the last inequality of (c) holds with LK ln2/n in place of 4LK ln2/n.
(e) (The case of a function, restated from the candidate theory.) If P is a function f, the deployed run and the run of the human system on the same ω₀ differ with probability at most LK ln2/n.

*Proof.* Fix t and the data D_(t−1); then M^(t) is a fixed sampler. Put σ_t := E_{Q_{M^(t)}} Σ_j H²(M^(t), P)(x_j). By Lemma 1.1(2), σ_t ≤ ½·E_{Q_{M^(t)}} Σ_j KL(P‖M^(t))(x_j). Taking the expectation over the data and averaging over t, R1 gives

 E[σ_T] ≤ LK ln2/(2n) = s.

(a) Corollary 2.3 with A = M^(T) and B = P: H²(Q_{M^(T)}, Q_P) ≤ 4σ_T. (b) Corollary 2.11 with A = M^(T) and B = P: TV(Q_{M^(T)}, Q_P) ≤ φ(σ_T). The function u ↦ u + √(u² + 2u) is increasing and concave on [0, ∞) (the second derivative of √(u² + 2u) is −(u² + 2u)^(−3/2)), so φ, the minimum of it and of the constant 1, is non-decreasing and concave; by Jensen's inequality E φ(σ_T) ≤ φ(E σ_T) ≤ φ(s). The bound 2√s and the expansion are in Lemma 2.10(c). For the last claim, u + √(u² + 2u) = ε holds exactly for u = ε²/(2(1+ε)), and s ≤ ε²/(2(1+ε)) means n ≥ (1+ε)·LK ln2/ε². (c) Corollary 2.11 for each value of the data and of T gives Q_{M^(T)}(G) ≤ (1+η)·Q_P(G) + 2(1 + 1/η)·σ_T, and Q_{M^(T)}(G) ≤ 2σ_T if Q_P(G) = 0; take expectations (G does not depend on the data). The other direction is Lemma 1.1(5) with (a): Q_P(G) ≤ (1+η)·Q_{M^(T)}(G) + (1 + 1/η)·2H²(Q_{M^(T)}, Q_P). (d) By the chain rule (Lemma 4.5(i)), KL(Q_P‖Q_M) = E_{Q_P}[Σ_j KL(P‖M)(x_j)] for every sampler M. The inputs and the length of the run are functions of ω₀, whose law is μ₀ under every answerer; so the expectation under Q_P equals the expectation under Q_M. Hence E[KL(Q_P‖Q_{M^(T)})] is the average over t of E[E_{Q_{M^(t)}} Σ_j KL(P‖M^(t))(x_j)], which is at most LK ln2/n by R1. The other three bounds follow from Lemma 1.1(3) with Jensen's inequality for the square root, from Lemma 1.1(2), and from Lemma 1.1(5). (e) For a function, KL(P‖M)(x) = −ln M(f(x)|x) ≥ 1 − M(f(x)|x), the probability that a draw from M(·|x) differs from f(x). Run Π with M^(t) and, on the same ω₀, with f. The two runs coincide unless at some call of the M^(t)-run the draw differs from f(x_j); by the union bound over the calls this has probability at most E_{Q_{M^(t)}} Σ_j (1 − M^(t)(f(x_j)|x_j)). Average over t and use R1. ∎

*The bound for events that the human system never produces needs no Hellinger distance.* If Q_P(G) = 0, then for μ₀-almost every ω₀ every run in G contains a call j with P(y_j|x_j) = 0. So, for a sampler M, Q_M(G) ≤ E_{Q_M} Σ_j M({y : P(y|x_j) = 0} | x_j) by the union bound over the calls; and KL(P‖M)(x) ≥ −ln M({y : P(y|x) > 0} | x) ≥ M({y : P(y|x) = 0} | x) by Lemma 1.1(4) applied to the indicator of the support of P(·|x). With R1 this is E[Q_{M^(T)}(G)] ≤ LK ln2/n. For a function this is the proof of (e). So the linear rate of the deterministic case holds, with the same constant, for every human and every event that the human system never produces.

*History of the constants.* The prover's version of this theorem derived (b) and (c) from (a) and Lemma 1.1, which gives E[TV] ≤ 2·√(LK ln2/n), E[Q_{M^(T)}(G)] ≤ 2Q_P(G) + 8LK ln2/n, and 4LK ln2/n when Q_P(G) = 0. These are true and weaker: by the factor √2 in the first (2 to first order) and by the factor 4 in the other two. The sharper forms come from Lemma 2.10 (the second verifier's finding M1), and the sharper form of (d) from the first verifier's improvement A.

**Remark 3.2 (what is deployed, and with what confidence).** (i) If T is drawn afresh for each deployed run, the law of a deployed run given the data is the average Q̄ := (1/n) Σ_t Q_{M^(t)}; H² and TV are convex in one argument (Lemma 1.1(4)) and Q(G) is linear, so (a)–(c) hold for Q̄ with the expectation over the data only. (ii) If T is drawn once and M^(T) is used for good, Markov's inequality for σ_T gives: with probability at least 1 − δ over the data and T, σ_T ≤ s/δ, and then every later run has a law with H²(Q_{M^(T)}, Q_P) ≤ 2LK ln2/(nδ) and TV(Q_{M^(T)}, Q_P) ≤ φ(s/δ) ≤ √(2LK ln2/(nδ)). The price of the confidence 1 − δ is the factor 1/δ; this file has no statement with ln(1/δ), and none for the last round (Remark 4.3; Section 8.1, item 3). (iii) The bound is on each single run. For k independent deployed runs with the same M^(T), Corollary 2.11 gives total variation at most φ(k·σ_T) between the k runs and k runs of the human system, hence at most φ(k·s) ≤ √(2k·LK ln2/n) in expectation; and BC is multiplicative, so the joint laws have H² = 1 − (1 − H²(Q_{M^(T)}, Q_P))^k ≤ k·H²(Q_{M^(T)}, Q_P). The k runs together are close to k runs of the human system only while k·LK/n is small: an imitator that is run far more often than it was rehearsed is, over all its runs together, distinguishable from the human system.

**Remark 3.3 (what the lemmas buy, the human outside the class, and how far the bounds are from attained).** (i) Without Lemma 2.10 or L4, the hybrid bound TV(Q_A, Q_B) ≤ E_{Q_A} Σ_j TV(A,B)(history_j) (Lemma 4.5 below) with Pinsker's inequality and the Cauchy–Schwarz inequality gives E TV ≤ L·√(K ln2/(2n)). The bound √(2LK ln2/n) of Theorem 3.1(b) is smaller by the factor √L/2. (ii) If A2 fails, the proof of R1 gives, for every ν* ∈ H, (1/n) Σ_t E[E_{Q_{M^(t)}} Σ_j KL(P‖M^(t))(x_j)] ≤ L·ln(1/w(ν*))/n + (1/n) Σ_t E[E_{Q_{M^(t)}} Σ_j KL(P‖ν*)(x_j)] (Appendix A, the paragraph on the human outside the class), so (a) becomes E H² ≤ 2L·[ln(1/w(ν*))/n + sup_x KL(P‖ν*)(x)]. The approximation error is measured on the inputs that the imitators themselves visit, which are not known in advance; hence the supremum. The supremum is over all inputs, including those that only bad imitators produce; so without A2 rehearsal asks much more of the class than recorded runs do (Theorem 4.2(d): the divergence along the human system's own runs). (iii) With Theorem 2.7 in place of Theorem 2.1(c), the two statements of Theorem 3.1 that rest on L4 improve: E H² ≤ (c*/2)·LK ln2/n ≤ 1.49·LK ln2/n in (a), and c*·LK ln2/n ≤ 2.97·LK ln2/n in place of 4LK ln2/n in the last inequality of (c). The bounds on the total variation and on E[Q_{M^(T)}(G)] do not use L4. (iv) *How far from attained.* In exact computations of Protocol R on small instances (random search and hill climbing by the second verifier; 120 random instances by the editor; Section 7.6), R1 is attained (ratio 1.0000, when one answer identifies the human), the bound LK ln2/n for events with Q_P(G) = 0 is nearly attained (ratio 1.0000 as w(P) → 1), and E H² never exceeded one quarter of the bound of (a). The three inequalities behind (a) are sharp in different places: R1 when one answer settles everything, H² ≤ KL/2 when the human's answer is nearly certain, L4 only for small H² with a drifting likelihood ratio. So the best constant C in E H² ≤ C·LK ln2/n is at most c*/2 < 1.49 and, on this evidence, not below ½; where it lies is open.

### 3.2 The lower bound

**Lemma 3.4a (two coins of opposite bias).** For an integer N ≥ 1 and δ ∈ (0, ½) put G(N, δ) := TV(Bern(½+δ)^⊗N, Bern(½−δ)^⊗N). Then G(N, δ) is non-decreasing in N, and for every odd N ≥ 3 with (N−1)δ² ≤ ¼,
 G(N, δ) ≥ δ·√(N/2).

*Proof.* Let N = 2k − 1 and let S be the number of ones. For S ~ Bin(N, p), (d/dp) Pr_p[S ≥ k] = N·C(N−1, k−1)·p^(k−1)(1−p)^(N−k) (differentiate the sum term by term; it telescopes). Here N − k = k − 1, and p(1−p) ≥ ¼ − δ² on [½−δ, ½+δ]. With j := k − 1 = (N−1)/2 ≥ 1 and the bound C(2j, j) ≥ 4^j/(2√j) (by induction on j: the ratio of consecutive central binomial coefficients is 2(2j+1)/(j+1) ≥ 4√j/√(j+1)),
 G ≥ Pr_(½+δ)[S ≥ k] − Pr_(½−δ)[S ≥ k] ≥ 2δ·N·C(2j, j)·4^(−j)·(1−4δ²)^j ≥ (δN/√j)·(1 − 4jδ²) ≥ δ·√(2N)·½,
using N/√j ≥ √(2N) and 4jδ² = 2(N−1)δ² ≤ ½. Monotonicity in N is Lemma 1.1(4) applied to the projection on the first N − 1 coordinates. ∎

**Proposition 3.4 (K coins: about LK/ε² questions are necessary).** Let K ≥ 8 and m ≥ 4 be integers, L := Km, and δ > 0 with Lδ² ≤ 1 (hence δ ≤ 1/√32 < ¼, because L ≥ 32). Let X = {1, …, K}, and for θ ∈ {−1, +1}^K let P_θ be the sampler with P_θ(1|i) = ½ + θ_i δ and P_θ(0|i) = ½ − θ_i δ. The class H_K := {P_θ} has the uniform weights 2^(−K), so log₂(1/w) = K for every member. The scaffold Π_K makes L calls, and call j has the input 1 + ((j−1) mod K) whatever the answers; so every input is asked m times. A *protocol* puts at most n questions to the human: each question is an element of X, chosen as a function of the earlier questions and answers and of randomness independent of the human's coins, and it is answered by an independent draw from P_θ(·|question). After that the protocol deploys an answerer of its choice; Q̂ denotes the law of the deployed run. If

 n ≤ K(1 − 4δ²)/(16δ²),

then the average over θ of E_θ[TV(Q̂, Q_{P_θ})] is at least δ·√L/65. Consequently, for every ε ∈ (0, 1/65]: every protocol with n ≤ LK/(8·10⁴·ε²) questions has E_θ[TV(Q̂, Q_{P_θ})] ≥ ε for some member P_θ of H_K (take δ := 65ε/√L).

*Proof.* Write Q_θ for Q_{P_θ}; since the inputs are fixed, a run is the vector of its L answers and Q_θ is a product of L Bernoulli laws. *Step 1 (from a law to a parameter).* Let θ̂ minimise θ′ ↦ TV(Q̂, Q_θ′). Then TV(Q_θ̂, Q_θ) ≤ 2·TV(Q̂, Q_θ). If θ̂ and θ differ in r coordinates, then TV(Q_θ̂, Q_θ) = G(rm, δ): the coordinates of the run that belong to inputs where θ̂ and θ agree are identical independent factors, and on the remaining rm coordinates a relabelling of the answers turns the two laws into Bern(½+δ)^⊗rm and Bern(½−δ)^⊗rm. *Step 2 (many coordinates are wrong).* Let d be the number of coordinates in which θ̂ and θ differ, and let ℙ_θ be the law of everything the protocol sees (its randomness, questions and answers); θ̂ is a function of it. For a coordinate i and a choice of the other coordinates write θ^(i+), θ^(i−) for the two completions. Then ½·ℙ_θ^(i+)[θ̂_i ≠ +1] + ½·ℙ_θ^(i−)[θ̂_i ≠ −1] ≥ ½(1 − TV(ℙ_θ^(i+), ℙ_θ^(i−))). By Pinsker's inequality in both directions and the chain rule for KL (the two laws differ only in the answers to questions at input i, each of which contributes κ := KL(Bern(½+δ)‖Bern(½−δ)) = 2δ·ln((1+2δ)/(1−2δ)) ≤ 8δ²/(1−4δ²)), TV(ℙ_θ^(i+), ℙ_θ^(i−))² ≤ (κ/4)(E_θ^(i+)[N_i] + E_θ^(i−)[N_i]), N_i being the number of questions at input i. Averaging over i and the other coordinates, with Jensen's inequality for the square root and Σ_i N_i ≤ n, the average of E_θ[d] over θ is at least (K/2)(1 − √(κn/(2K))) ≥ K/4 under the hypothesis on n. *Step 3.* Since d ≤ K, the average over θ of ℙ_θ[d ≥ K/8] is at least (¼ − ⅛)/(1 − ⅛) = 1/7. On this event d ≥ r₀ := ⌈K/8⌉, and N := r₀m satisfies L/8 ≤ N ≤ L/4 (as K ≥ 8), so N ≥ 4 and Nδ² ≤ ¼. By Lemma 3.4a applied to N or N − 1, whichever is odd, G(dm, δ) ≥ G(N, δ) ≥ δ·√((N−1)/2) ≥ δ·√(3N/8) ≥ δ·√(3L/64). With Step 1 the average of E_θ[TV(Q̂, Q_θ)] is at least (1/7)·½·δ·√(3L/64) ≥ δ·√L/65. *The consequence.* With δ = 65ε/√L we have Lδ² ≤ 1 and δ² ≤ 1/32, so K(1−4δ²)/(16δ²) ≥ (7/8)·KL/(16·4225·ε²) ≥ KL/(8·10⁴·ε²). ∎

The questions of the protocol may be chosen in any way; in particular the protocol may record whole runs of the human system. So Proposition 3.4 also bounds from below the number N·L of answers used by Theorem A. The definition of a protocol covers Protocol R: its questions are functions of the earlier answers and of independent randomness, and M^(T) is an answerer chosen from the data and independent randomness.

*Method and scope.* The proof is Assouad's hypercube method with adaptively chosen questions, and the proof of Proposition 3.5 below is Le Cam's two-point method (for both see B. Yu, "Assouad, Fano, and Le Cam", in *Festschrift for Lucien Le Cam*, Springer, 1997, pp. 423–435; quoted from memory, not opened). The statements have a scope that must be stated with them. (i) The criterion is the expected total variation between the run law of the trained imitator and the human system; under the weaker criterion of Section 3.3, qualification (4), the factor disappears. (ii) The scaffolds ask the same input several times within a run (each of K inputs m ≥ 4 times in Proposition 3.4, one input L times in Proposition 3.5) and count on fresh coins at each repetition, which is assumption A1. (iii) The class of Proposition 3.4 has uniform weights, so its K is the logarithm of the size of the class; the proposition does not show that K bits are needed for a given human in a given class.

**Proposition 3.5 (two coins: the factor L/ε² without the factor K).** Let L ≥ 3 be odd, ε ∈ (0, 1/12] and a := 4ε·√(2/L). Let X = {x}, let P₊ and P₋ be the samplers with P_±(1|x) = ½ ± a, and let the scaffold make L calls at x. For every protocol (in the sense of Proposition 3.4) with n ≤ L/(740·ε²) questions, E[TV(Q̂, Q_P)] ≥ ε for P = P₊ or for P = P₋.

*Proof.* Write Q_± and ℙ_± for the run laws and for the laws of what the protocol sees. For every value of the data, TV(Q̂, Q₊) + TV(Q̂, Q₋) ≥ TV(Q₊, Q₋) = G(L, a). Since ∫f₊ dℙ₊ + ∫f₋ dℙ₋ ≥ ∫(f₊ + f₋) d min(ℙ₊, ℙ₋) for non-negative f_±, it follows that E₊[TV(Q̂, Q₊)] + E₋[TV(Q̂, Q₋)] ≥ G(L, a)·(1 − TV(ℙ₊, ℙ₋)). Here (L−1)a² ≤ 32ε² ≤ ¼, so G(L, a) ≥ a·√(L/2) = 4ε by Lemma 3.4a. By Pinsker's inequality and the chain rule, TV(ℙ₊, ℙ₋)² ≤ nκ/2 ≤ 4na²/(1−4a²) with κ as in the proof of Proposition 3.4; and 4a² = 128ε²/L ≤ 0.3, so TV(ℙ₊, ℙ₋)² ≤ 183·nε²/L ≤ ¼ when n ≤ L/(740ε²). The sum of the two expectations is then at least 2ε. ∎

Two independent derivations of the same kind appeared while this file was written; they were not checked here. The digest `understand/imitation-theory.md` (its LB3) has (L−1)/(2048·ε²) for the two samplers of Proposition 3.5 under a slightly different criterion. The file `proofs/lower-bounds.md` (its Theorem 6.3, consequence 2) has n ≥ L·K/(8192·ε²), for ε ≤ 1/64, for 2^K coins on a different scaffold (one input drawn at random and asked L times), which is a better constant than that of Proposition 3.4; both verification reports on that file confirm this consequence (and correct the display of that theorem, which does not affect it).

**Proposition 3.6 (the number of unfaithful calls: the order L·√(K/n) is attained).** In the setting of Proposition 3.4, with any integers K ≥ 1 and m ≥ 1, L = Km and any δ ∈ (0, ½), let a protocol with at most n questions deploy a sampler Ŝ (for Protocol R, Ŝ = M^(T)), and let u_θ := E_θ[E_{Q_Ŝ} Σ_j TV(Ŝ, P_θ)(x_j)] be the expected number of unfaithful calls of its run in the coupling L2 of the candidate theory. If n ≤ K(1−4δ²)/(16δ²), then the average of u_θ over θ is at least Lδ/4. In particular, for n ≥ 3K/4 and δ := √(K/(16n + 4K)), some member has

 u_θ ≥ (L/4)·√(K/(16n + 4K)) ≥ (√3/32)·L·√(K/n) > 0.054·L·√(K/n).

*Proof.* The inputs of a run are fixed and each input occurs m times, so Σ_j TV(Ŝ, P_θ)(x_j) = m·Σ_i TV(Ŝ(·|i), P_θ(·|i)) ≥ m·Σ_i |Ŝ(1|i) − ½ − θ_i δ|. Put θ̂_i := +1 if Ŝ(1|i) ≥ ½ and θ̂_i := −1 otherwise. If θ̂_i ≠ θ_i, then |Ŝ(1|i) − ½ − θ_i δ| ≥ δ. So the sum is at least m·δ·d, with d the number of coordinates in which θ̂ and θ differ. Step 2 of the proof of Proposition 3.4 uses neither K ≥ 8 nor m ≥ 4, holds for every θ̂ that is a function of what the protocol sees, and gives an average of E_θ[d] of at least K/4 under the hypothesis on n. Hence the average of u_θ is at least m·δ·K/4 = Lδ/4. With δ² = K/(16n + 4K) the hypothesis on n holds with equality; and 16n + 4K ≤ 64n/3 because K ≤ 4n/3, so δ ≥ √(3K/(64n)). ∎

(The proposition was stated without proof in the prover's version, in Section 3.3; the statement and the proof are the first verifier's, and the editor checked them.) The upper bound of the candidate's R3 on the same quantity is L·√(K ln2/(2n)) < 0.589·L·√(K/n). So for a stochastic human the expected number of unfaithful calls of a deployed sampler is of order L·√(K/n) in the worst case, the two constants differing by a factor of at most 11.

**Remark 3.7 (how far the constants of the lower bounds are from the truth).** The constants 1/(8·10⁴) and 1/740 were not optimised. Exact evaluation on the two-coin instance of Proposition 3.5 by the second verifier (Section 7.6; twelve pairs (L, ε) with L from 3 to 1001): the Bayes risk that the proof uses stays above ε up to n between 0.0093 and 0.0123 times L/ε², so the two-point argument itself allows a constant about 8 times larger than 1/740 = 0.00135; and Protocol R reaches E TV ≤ ε on that instance after 0.045 to 0.052 times L/ε² rounds (six pairs), where the upper bounds are 0.69·(1+ε) (Theorem 3.1(b), K = 1) and 0.35 (Theorem 3.1(d)) times L/ε². So on this instance the number of rounds that Protocol R needs is about 4 times the two-point lower bound and about 7 times below the best upper bound.

### 3.3 Is the factor √L necessary? What the truth is

Yes. Already for two samplers, expected whole-run total variation ε needs more than L/(740·ε²) questions (Proposition 3.5). For the class and scaffold of Proposition 3.4, expected whole-run total variation ε for every member needs more than LK/(8·10⁴·ε²) questions, and Theorem 3.1(d) shows that LK ln2/(2ε²) rounds of Protocol R suffice there ((1+ε)·LK ln2/ε² rounds on an arbitrary scaffold, by Theorem 3.1(b)). So the order LK/ε² is necessary in the worst case over classes and scaffolds, and Protocol R attains it. The two proved bounds differ by an absolute constant that is large: about 2.8·10⁴ on the scaffold of Proposition 3.4, most of it lost in the proof of the lower bound, which was not optimised (Remark 3.7), and about 2.8·10³ with the constant 8192 of `proofs/lower-bounds.md`. The reason for the factor L is statistical and has nothing to do with compounding errors: a run of L calls is a sample of size up to L from the human, and a sample of that size detects a per-call discrepancy of order 1/√L.

| human | guarantee after n rounds of Protocol R | rounds for accuracy ε | lower bound on the number of questions |
|---|---|---|---|
| a function | the deployed run differs from the human system's with probability ≤ LK ln2/n (Theorem 3.1(e)) | LK ln2/ε | L/(4ε) − L for the needle class of N2 (`proofs/lower-bounds.md`, Corollary 2.2; proved and checked in that part, not here) |
| a sampler | E TV ≤ φ(s) ≤ √(2LK ln2/n), s = LK ln2/(2n) (Theorem 3.1(b)); E TV ≤ √(LK ln2/(2n)) if the inputs do not depend on the answers (Theorem 3.1(d)) | (1+ε)·LK ln2/ε²; LK ln2/(2ε²) | LK/(8·10⁴·ε²) for the K coins (Proposition 3.4); L/(740·ε²) for two samplers (Proposition 3.5) |
| a sampler, event G with Q_P(G) = 0 | E Q_{M^(T)}(G) ≤ LK ln2/n (Theorem 3.1(c)) | LK ln2/ε | |

Four qualifications. (1) The lower bound is for one class; for a given class the truth can be smaller (for a class of functions LK ln2/ε questions suffice, by Theorem 3.1(e)). (2) The square-root rate is the price of *all* events at once. For an event that the human system produces with probability zero, or with small probability, Theorem 3.1(c) gives the rate LK ln2/n of the deterministic case, with the same constant. (3) The expected *number* of unfaithful calls in the coupling of the candidate's L2 is bounded by L·√(K ln2/(2n)) (candidate theory, R3), and for the K coins with δ of order √(K/n) this order is attained by every deployed sampler (Proposition 3.6). So for a stochastic human the per-call count is of order L·√(K/n) while the whole-run distance is of order √(LK/n). (4) *Which criterion.* Theorem 3.1 and Propositions 3.4 and 3.5 are about E[TV(Q_{M^(T)}, Q_P)]: the distance between the run law of the trained imitator and the human system, averaged over the training data. The weaker criterion TV(E[Q_{M^(T)}], Q_P) describes one deployed run averaged over the training randomness as well. It can be much smaller (the digest `understand/imitation-theory.md`, §5.8, gives an example with L/n in place of √(L/n)), and for one run of the scaffold of Proposition 3.4 it is met exactly with L questions: put the L calls of one run to the human and replay the answers. An imitator is trained in order to be run many times on the same data; its runs then share the training error, and the first criterion is the relevant one.

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

**Theorem 4.2 (Theorem A).** For every ν* ∈ H put Res_N(ν*) := ln(1/w(ν*))/N + KL(Q* ‖ Q_ν*) (the letters stand for "resolvability": the minimum of Res_N over ν* is the index of resolvability of Barron and Cover, Section 5.4). Then, with E the expectation over the recorded runs:

(a) Σ_{t=1}^N E[KL(Q* ‖ Q̂_t)] ≤ ln(1/w(ν*)) + N·KL(Q* ‖ Q_ν*).
(b) E[KL(Q* ‖ Q̂)] ≤ Res_N(ν*), E[TV(Q̂, Q*)] ≤ √(Res_N(ν*)/2), E[H²(Q̂, Q*)] ≤ Res_N(ν*)/2, and for every event G of runs (fixed before the runs are seen) E[Q̂(G)] ≤ 2Q*(G) + 2Res_N(ν*), and E[Q̂(G)] ≤ Res_N(ν*) if Q*(G) = 0. The same five bounds hold for Q̂_t with t drawn once and uniformly (expectation over t as well).
(c) Under A1 and A2 (Q* = Q_P, P ∈ H): E[KL(Q_P ‖ Q̂)] ≤ K ln2/N and E[TV(Q̂, Q_P)] ≤ √(K ln2/(2N)).
(d) For a stateless human P (A1) and a sampler ν*, KL(Q_P ‖ Q_ν*) = E_{Q_P}[Σ_j KL(P‖ν*)(x_j)]: the approximation error is the per-call divergence summed along the human system's own runs.

*Proof.* (a) If KL(Q*‖Q_ν*) = ∞ there is nothing to prove. Otherwise q_ν*(τ_s) > 0 almost surely, so ξ_t ≥ w(ν*)·Π_{s<t} q_ν*(τ_s) > 0 for all t, the posteriors are defined, and ξ_(t+1) = ξ_t·q̂_t(τ_t). With W := ξ_1 = Σ_ν w(ν) ≤ 1 this gives, on every path,
 Σ_{t ≤ N} ln(q*(τ_t)/q̂_t(τ_t)) = ln(Π_t q*(τ_t)/ξ_(N+1)) + ln W ≤ ln(1/w(ν*)) + Σ_{t ≤ N} ln(q*(τ_t)/q_ν*(τ_t)).
Given τ_<t the run τ_t has law Q*, so the conditional expectation of ln(q*(τ_t)/q̂_t(τ_t)) is KL(Q*‖Q̂_t) ≥ 0. Each variable Z = ln(q*(τ_t)/q̂_t(τ_t)) and Z = ln(q*(τ_t)/q_ν*(τ_t)) has E[max(−Z, 0)] ≤ E[e^(−Z)]/e ≤ 1/e, so all expectations exist in (−∞, ∞] and add; taking expectations gives (a). (b) KL(Q*‖·) is convex, so KL(Q*‖Q̂) ≤ (1/N) Σ_t KL(Q*‖Q̂_t); then (a). The next three bounds follow from Lemma 1.1(3), (2), (5) and Jensen's inequality for the square root. For the last one: if Q*(G) = 0 then q* = 0 almost everywhere on G, so Q̂(G) ≤ 1 − Q̂({q* > 0}) ≤ −ln Q̂({q* > 0}) ≤ KL(Q*‖Q̂), the last step by Lemma 1.1(4) applied to the indicator of {q* > 0}. For t drawn once, the expectation over t of KL(Q*‖Q̂_t) is (1/N) Σ_t KL(Q*‖Q̂_t). (c) Take ν* = P. (d) Lemma 4.5(i) below. ∎

**Remark 4.2a (what is standard here, and what kind of object the imitator is).** (i) *The theorem is the progressive mixture rule applied to whole runs.* With one recorded run as one observation, (a) is the regret bound for Bayes mixtures, and (b) is the oracle inequality for the average of the Bayes predictive densities over the sample sizes 0, …, N − 1. A. Juditsky, P. Rigollet, A. B. Tsybakov, "Learning by mirror averaging", *Annals of Statistics* 36(5):2183–2206, 2008 (arXiv:math/0511468; read in the arXiv PDF by the second verifier and, on 16 November 2026, by the editor), Corollary 5.4: for M densities p_1, …, p_M, an i.i.d. sample from a density p, which is not assumed to be one of them, and the aggregate p̃_n obtained by their mirror averaging algorithm with β = 1, E_{n−1} K(p, p̃_n) ≤ min_{1 ≤ j ≤ M} K(p, p_j) + (log M)/n, where K is the Kullback–Leibler divergence and E_{n−1} the expectation over the n − 1 observations that p̃_n uses. They add: "the KL aggregate p̃_n as in Corollary 5.4 coincides with the 'progressive mixture rule' considered by Catoni [7, 8, 9] and Yang [29] and the oracle inequality of Corollary 5.4 is the one obtained in those papers." Their references, not opened here: O. Catoni, "A mixture approach to universal model selection", preprint LMENS-97-30, École Normale Supérieure, Paris, 1997; O. Catoni, "'Universal' aggregation rules with exact bias bounds", preprint 510, Laboratoire de Probabilités et Modèles Aléatoires, Universités Paris 6 and Paris 7, 1999; O. Catoni, *Statistical Learning Theory and Stochastic Optimization*, Lecture Notes in Mathematics 1851, Springer, 2004; Y. Yang, "Mixing strategies for density estimation", *Annals of Statistics* 28(1):75–87, 2000. For a truth inside the class the device of averaging the Bayes predictive densities over the sample sizes goes back, from the second verifier's memory, to A. R. Barron, "Are Bayes rules consistent in information?", in *Open Problems in Communication and Computation* (T. M. Cover and B. Gopinath, eds.), Springer, 1987, pp. 85–91 (not opened). What this file adds is the application to runs of a scaffold (Lemma 4.1), weights ln(1/w(ν)) in place of log M, and the bounds on events. (ii) *The imitator of Theorem A is not a sampler.* It draws one hypothesis for a run and lets it answer every call of that run. This is an answerer whose state lasts for a run or, which gives the same law, a per-call mixture that conditions on the earlier answers of its own run. In a scaffold whose calls are executed apart from each other (a tree of calls) it needs a run identifier or a shared seed at every call. The stateless per-call mixture loses up to the factor L (Section 4.3); Theorem B (Section 5) is the statement about one sampler.

**Remark 4.3 (the role of the uniformly random t).** The regret bound (a) controls the *sum* over t of the expected divergences, not any single term. Drawing t uniformly turns it into a bound on an expectation; equivalently, the deployed object is the Cesàro average of the posterior mixtures. The expected divergence is not monotone in the number of runs (Example 4.4), so the bound for the random t does not pass to "the posterior after all N runs" by monotonicity. Whether E[KL(Q_P‖Q̂_(N+1))] ≤ C·K ln2/N holds with an absolute constant C is not decided here. The question has been asked in the literature: P. D. Grünwald and W. Kotłowski, "Bounds on individual risk for log-loss predictors", *Proceedings of the 24th Annual Conference on Learning Theory* (COLT 2011), PMLR 19:813–816, pose as an open problem "to use the results on cumulative risk to prove corresponding individual-risk bounds" (the abstract was read on the proceedings' web page by the editor on 16 November 2026; the paper itself was not opened, and whether the problem has since been solved was not checked). (For a human drawn from the normalised prior the expected divergence is non-increasing in t, by the standard fact that for conditionally independent observations the conditional mutual information I(P; τ_t | τ_<t) is non-increasing; this is not used.) Compare the remark (iii) at the end of Section 3 of the candidate theory: what is established is non-monotonicity, not the failure of a last-round bound.

**Example 4.4 (the expected divergence is not monotone).** One call per run with a fixed input and answers in {0,1}. H consists of the human P = Bern(½) with weight 0.01, of A = Bern(0.4) with weight 0.89 and of B = Bern(0.99) with weight 0.10. The exact values of E[KL(Q_P‖Q̂_(t+1))] after t = 0, 1, …, 5 recorded runs are 0.00321, 0.01058, 0.02451, 0.03794, 0.04298, 0.03988 (Section 7): after four runs the expected divergence is thirteen times what it was with no data. (An answer 1 moves posterior weight from the good approximation A to the bad one B before the human gains weight.) ∎

### 4.3 The per-call mixture in place of the draw per run

The question is whether Theorem 4.2(c) remains true if, in the imitation run, every call is answered by a fresh draw from the mixture M_t := M_{D_(t−1)} (D_(t−1) the pairs of the runs τ_<t), that is, if Q̂_t is replaced by Q_{M_t}. Section 12 of the candidate theory observes that the obvious proof fails. The statement itself fails too.

**Lemma 4.5 (chain rule and hybrid bound).** For answerers A, B on a scaffold: (i) KL(Q_A ‖ Q_B) = E_{Q_A}[Σ_j KL(A_j(·|ω₀, y_<j) ‖ B_j(·|ω₀, y_<j))], as an identity in [0, ∞]; for samplers this is the candidate's L1. (ii) TV(Q_A, Q_B) ≤ E_{Q_A}[Σ_j TV(A_j(·|ω₀, y_<j), B_j(·|ω₀, y_<j))].

*Proof.* (i) ln(q_A/q_B) = Σ_j ln(a_j/b_j), and given the past of step j the term j has conditional Q_A-expectation KL(a_j‖b_j) ≥ 0, which vanishes after the run has stopped; the negative parts are integrable as in the proof of Theorem 4.2. (ii) For k = 0, …, L let Q^(k) be the law of the run in which calls 1, …, k are answered by A and the later calls by B. Q^(k) and Q^(k−1) have the same law of the first k − 1 answers (that of Q_A), different kernels at step k, and the same kernels afterwards; so TV(Q^(k), Q^(k−1)) = E_{Q_A}[TV(a_k, b_k)(ω₀, y_<k)]. Sum over k, with Q^(L) = Q_A and Q^(0) = Q_B. ∎

**Example 4.6 (the statement of Theorem A is false for the per-call mixture; it fails by a factor up to L).** Let B ≥ 2 and L ≥ 1 be integers. The top-level input z is uniform on {1, …, B}; the scaffold makes L calls with the inputs (z,1), …, (z,L), whatever the answers. The human is the function f ≡ 0. For b ∈ {1, …, B} the function g_b is 1 at the inputs (b, ·) and 0 elsewhere. H := {f, g_1, …, g_B} with w(f) = ½ and w(g_b) = 1/(2B); so K = 1.

Let N ≤ B/2 runs of the human system be recorded, and let v ≤ t − 1 be the number of distinct values of z among the first t − 1 of them. The hypothesis g_b has likelihood 1 if b was not visited and 0 otherwise, so the posterior weight of f is B/(2B − v) and that of each surviving g_b is ω := 1/(2B − v). Hence, for every t ≤ N and every data set:

* *One draw per run.* Q̂_t differs from Q_f only on the runs with an unvisited z, where it answers all ones with probability ω. So TV(Q̂_t, Q_f) = (B−v)ω/B ≤ 1/(2B) and KL(Q_f‖Q̂_t) = ((B−v)/B)·ln(1/(1−ω)).
* *Per-call mixture.* M_t answers 1 with probability ω at every input (z, j) with z unvisited. So TV(Q_{M_t}, Q_f) = ((B−v)/B)·(1 − (1−ω)^L) and KL(Q_f‖Q_{M_t}) = ((B−v)/B)·L·ln(1/(1−ω)) = L·KL(Q_f‖Q̂_t).

Since v < B/2 and ω ≥ 1/(2B): TV(Q_{M_t}, Q_f) ≥ ½(1 − e^(−L/(2B))) and KL(Q_f‖Q_{M_t}) ≥ L/(4B). Take B = 2N. Then for every t ≤ N,
 KL(Q_f‖Q_{M_t}) ≥ L/(8N) and TV(Q_{M_t}, Q_f) ≥ ½(1 − e^(−L/(4N))).

*The same two bounds hold for the law that Theorem A is about*, the average Q̄_M := (1/N)·Σ_{t ≤ N} Q_{M_t}, which is the law of an imitation run when t is drawn afresh for the run; the bounds for each single t refute only the form "t drawn once and uniformly". Given z, Q_f is the point mass on the run "all zeros". So TV(Q, Q_f) = E_z[1 − Q(zeros | z)] is linear in Q, and the lower bound on the total variation passes to the average. And KL(Q_f‖Q) = E_z[ln(1/Q(zeros | z))]. At most N − 1 values of z are visited before some round t ≤ N; for each of the other values, at least B − N + 1 > B/2 of them, every Q_{M_t}(zeros | z) = (1−ω_t)^L is at most (1 − 1/(2B))^L, hence so is their average, and KL(Q_f‖Q̄_M) ≥ ½·L·ln(1/(1 − 1/(2B))) ≥ L/(4B) = L/(8N). The same computation covers the variant in which every call draws its own t: that imitator answers 1 at every input (z, j) with probability (1/N)·Σ_t ω_t ≥ 1/(2B) when z is unvisited in all rounds.

Theorem 4.2(c) would require E KL ≤ ln2/N = 0.693/N and E TV ≤ √(ln2/(2N)) = 0.589/√N. The first fails if L ≥ 6. The second fails if L > 9.5·√N and N ≥ 4 (for L ≤ 4N use 1 − e^(−x) ≥ x/2 on [0,1], which gives TV ≥ L/(16N); for L ≥ 4N the total variation is at least ½(1 − e^(−1)) = 0.316). These thresholds are sufficient, not sharp: by exact enumeration of all sequences of top-level inputs for N ≤ 5, the divergence of the averaged law exceeds ln2/N already for L ≥ 3 when N ≤ 4 and for L ≥ 4 when N = 5, and at L = 1 the two imitators coincide (Section 7.6). For example B = 200, N = 100, L = 50 gives E TV(Q_{M_t}, Q_f) = 0.087 against 0.0019 for the draw per run and 0.059 for the bound of Theorem A (Section 7.4). ∎

*How the statement fails.* The loss is a factor of at most L in the cases that Proposition 4.7 covers, and the rate in N is unchanged. For a deterministic human the per-call mixture has the bound LK ln2/N on the total variation (Proposition 4.7(a)), which is below the bound √(K ln2/(2N)) of Theorem A as soon as N > 2L²K ln2. So "false" must not be read as "the per-call mixture does not work after recorded runs".

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
For the draw per run the corresponding sum is at most K ln2 (Theorem 4.2(a)). So the ratio of the left side to L·K ln2 exceeds (1−p)·ln(1/o)/2, which is unbounded as η → 0. (Section 7.4: ratios 2.2, 3.3, 5.6, 10.2 for η = 10⁻¹, 10⁻², 10⁻⁴, 10⁻⁸ at p = 0.01.) Note that the ratio is unbounded only as w(P) → 1, where K → 0. ∎

*The case K = 1 (computed, not proved).* The same seems to happen at K = 1 with many alternatives. Construction: answers at x_0 in {0, 1, …, B}; after the answer i ≥ 1 a second call at the input x_i, after 0 the run stops (L = 2). Human: P(i|x_0) = p/B for i ≥ 1, P(0|x_0) = 1 − p, P(·|x_i) = point mass at 1; w(P) = ½. Alternatives ν_1, …, ν_B of weight 1/(2B): ν_i(i|x_0) = 0, ν_i(0|x_0) = 1 − p + p/B, ν_i(·|x_i) = point mass at 0, and ν_i = P elsewhere; so ν_i is refuted in its own branch. With p = ½, the excess of the frozen per-call mixture over the draw per run, in expected summed per-call divergence along human runs, summed over all rounds t up to 6·B·ln(B)/p + 10, is 1.786, 2.494, 3.210, 3.916 for B = 4, 16, 64, 256, against L·K ln2 = 1.386. It grows by about ½·ln 4 = 0.69 for each factor 4 in B (0.708, 0.716, 0.706). These are sums over every t computed by the first verifier with two independent methods (for B = 256 with one; Section 7.6); the second verifier's script reproduces the first three, and the editor's the first two. The prover's version quoted 1.82, 2.50, 3.21, 3.92 and called them exact; they were trapezoid sums over a logarithmic grid of t.

In the two-hypothesis example the total variations of the two imitators are of the same order, and differ by a factor below 2: while ν is alive, TV(Q̂_t, Q_P) = p·ω_t and TV(Q_{M_t}, Q_P) = p·ω_t·(2 − ω_t). What fails is the bound on the summed divergences, which is what every proof in this file uses. The route through the per-call H² along the human system's runs (Lemma 2.10 or L4 with the roles A = P, B = M_t) is closed as well: in the same example the sum over t of the expected per-call H² is 0.80, 1.35, 2.49, 4.78 times L·K ln2 for η = 10⁻¹, 10⁻², 10⁻⁴, 10⁻⁸ at p = 0.01; the sum itself behaves like ½·o·ln(1/o), while L·K ln2 is about 2o (second verifier, Section 7.6). *Open:* for an adaptive scaffold and a stochastic human, does the frozen per-call mixture after N recorded runs satisfy E[TV(Q_{M_t}, Q_P)] ≤ C·√(LK/N)?

**Remark 4.9 (the same number of unfaithful calls, differently distributed).** For a function f, the expected number of calls along a run of the human system at which the imitator's answer would differ is E_{Q_f}[Σ_j (1 − M_t(f(x_j)|x_j))] for the per-call mixture, and it is the same number for one posterior draw per run, by linearity in ν. The draw per run puts all of them into few runs (in Example 4.6: L wrong calls in a fraction ω of the runs that meet an unvisited z); the per-call mixture spreads them (each such run has about Lω wrong calls). The first is better when every call is critical, by a factor up to L (Example 4.6). Under the low-stakes assumption of the candidate's R3 a few wrong calls in a run do no harm and many do, which favours the second; this is a reading, nothing in this file proves it, and it belongs to the part on R5 (`proofs/one-mind.md`). It qualifies the sentence "The right deployed object is then the per-call mixture" in Section 0 of the candidate theory: at most for low stakes.

## 5. Theorem B: one fixed program

### 5.1 Setting

The data are N independent runs τ_1, …, τ_N with law Q*, as in 4.2. H is a countable class with weights w, and ℓ(ν) := log₂(1/w(ν)), so that w = 2^(−ℓ) and Σ_ν 2^(−ℓ(ν)) ≤ 1; if ℓ are the lengths of a prefix-free code this is the setting of the candidate theory, but ℓ need not be integers. For λ ≥ 1 put

 π_λ(ν) := w(ν)^λ = 2^(−λℓ(ν)), 𝓛_ν := Π_{s ≤ N} q_ν(τ_s), Post_λ(ν | τ_1:N) := π_λ(ν)·𝓛_ν / Σ_ν′ π_λ(ν′)·𝓛_ν′.

By Lemma 4.1, Post_λ is the posterior given the pairs for the weights w^λ. A **λ-MAP** is a maximiser of π_λ(ν)·𝓛_ν. For s ∈ (0,1) the Chernoff coefficient of ν is A_s(ν) := ∫μ₀ Σ_τ q*(τ)^(1−s)·q_ν(τ)^s; A_½(ν) = BC(Q*, Q_ν) = 1 − H²(Q_ν, Q*), and E[(q_ν(τ)/q*(τ))^s] = A_s(ν) for τ ~ Q*.

**Lemma 5.0.** A_s(ν) ≤ (1 − H²(Q_ν, Q*))^(2·min(s, 1−s)) for s ∈ (0,1).

*Proof.* For s ≥ ½ write q*^(1−s)·q_ν^s = (q*·q_ν)^(1−s)·q_ν^(2s−1) and apply Hölder's inequality with the exponents 1/(2−2s) and 1/(2s−1): A_s ≤ BC^(2−2s)·(∫Σ q_ν)^(2s−1) = BC^(2−2s). For s ≤ ½ exchange the roles of q* and q_ν. ∎

### 5.2 The theorem for λ > 1

**Theorem 5.1 (Theorem B).** Assume A1 and A2, so Q* = Q_P with P ∈ H. Let λ > 1, s ∈ [1/λ, 1), ε ∈ (0,1], N ≥ 1, and

 B_ε := {ν ∈ H : H²(Q_ν, Q_P) ≥ ε²}, β := 2^(λ·s·ℓ(P))·(1 − ε²)^(2·min(s, 1−s)·N).

(a) E[Post_λ(B_ε | τ_1:N)] ≤ β.
(b) Pr[there is ν ∈ B_ε with π_λ(ν)·𝓛_ν ≥ π_λ(P)·𝓛_P] ≤ β. So with probability at least 1 − β every λ-MAP ν̂ has H²(Q_ν̂, Q_P) < ε².
(c) *Choices of s.* For λ ≥ 2 and s = ½: β = 2^(λℓ(P)/2)·(1−ε²)^N ≤ 2^(λℓ(P)/2)·e^(−Nε²). For 1 < λ ≤ 2 and s = 1/λ: β = 2^(ℓ(P))·(1−ε²)^(2(1−1/λ)N). At λ = 2 both give the candidate's 2^(ℓ(P))·e^(−Nε²). Hence β ≤ δ as soon as
 N ≥ [(λ/2)·ℓ(P)·ln2 + ln(1/δ)]/ε² (λ ≥ 2), N ≥ λ·[ℓ(P)·ln2 + ln(1/δ)]/(2(λ−1)·ε²) (1 < λ ≤ 2).

*Proof.* 𝓛_P > 0 almost surely. For every ν, Post_λ(ν | τ_1:N) ≤ min(1, π_λ(ν)𝓛_ν/(π_λ(P)𝓛_P)) ≤ (π_λ(ν)/π_λ(P))^s·(𝓛_ν/𝓛_P)^s, because min(1, a) ≤ a^s. The runs are independent, so E[(𝓛_ν/𝓛_P)^s] = A_s(ν)^N ≤ (1 − ε²)^(2·min(s,1−s)·N) for ν ∈ B_ε, by Lemma 5.0. Finally Σ_ν π_λ(ν)^s = Σ_ν 2^(−λsℓ(ν)) ≤ Σ_ν 2^(−ℓ(ν)) ≤ 1 because λs ≥ 1, and π_λ(P)^(−s) = 2^(λsℓ(P)). This proves (a). For (b), Markov's inequality gives Pr[(𝓛_ν/𝓛_P)^s ≥ (π_λ(P)/π_λ(ν))^s] ≤ (π_λ(ν)/π_λ(P))^s·A_s(ν)^N for each ν; sum over ν ∈ B_ε. (c) is arithmetic, with −ln(1−ε²) ≥ ε². ∎

The candidate theory states the case λ = 2 and, for general λ > 1, the exponent 2·min(1/λ, 1−1/λ)·Nε² with the factor 2^(ℓ(P)); this is the choice s = 1/λ and is correct. For λ > 2 the choice s = ½ is better: it needs N ≥ [(λ/2)ℓ(P) ln2 + ln(1/δ)]/ε² instead of (λ/2)·[ℓ(P) ln2 + ln(1/δ)]/ε². In both regimes the number of runs is c(λ)·ℓ(P) ln2/ε² with c(λ) = max(λ/2, λ/(2(λ−1))), smallest at λ = 2, and c(λ) grows like 1/(2(λ−1)) as λ decreases to 1.

**Corollary 5.2 (one program used for all future runs).** Under the hypotheses of Theorem 5.1, let ν̂ be one draw from Post_λ(· | τ_1:N), or any λ-MAP. With probability at least 1 − β (over the recorded runs and the draw), H²(Q_ν̂, Q_P) < ε². On this event the program ν̂, used for good, has the following properties.

1. *Each run.* TV(Q_ν̂, Q_P) ≤ ε·√(2 − ε²) < √2·ε.
2. *Each event of a run.* Q_ν̂(G) ≤ 2Q_P(G) + 4ε² and Q_P(G) ≤ 2Q_ν̂(G) + 4ε²; if Q_P(G) = 0 then Q_ν̂(G) ≤ 2ε². (Lemma 1.1(5).) With N ≥ [ℓ(P) ln2 + ln(1/δ)]/ε² at λ = 2: an event that the human system never produces has probability at most 2[ℓ(P) ln2 + ln(1/δ)]/N in every run of the program.
3. *Many runs.* The joint laws of m independent runs satisfy H² = 1 − (1 − H²(Q_ν̂, Q_P))^m ≤ m·ε², so the total variation between m runs of the program and m runs of the human system is at most ε·√(2m). The bound is useful for m much smaller than 1/ε² ≈ N/(ℓ(P) ln2 + ln(1/δ)). Unless H²(Q_ν̂, Q_P) = 0 the joint laws separate as m grows (1 − (1−h)^m → 1): a fixed program is close to the human system on each run, not on the whole future.
4. *Single calls.* E_{Q_P}[Σ_j H²(ν̂, P)(x_j)] ≤ 2L·ε² (Proposition 2.5), and the factor L cannot be removed in general: closeness of whole runs allows ν̂ to be wrong at every call of a branch that it enters with small probability.
5. Nothing is said about inputs that the human system does not visit.

The guarantee of Theorem 4.2 is about a fresh posterior draw for every run (the *mixture* of run laws is close); Corollary 5.2 is about one draw kept for ever. In total variation the two bounds are of the same order: √(2[ℓ(P) ln2 + ln(1/δ)]/N) here (at λ = 2) against √(K ln2/(2N)) there, with ℓ(P) = K. The comparison is of orders only: the first bound holds with probability 1 − δ, which is where the term ln(1/δ) comes from, and the second is a bound in expectation.

**Remark 5.3 (finite classes; the relation to log-loss behaviour cloning).** The proof of Theorem 5.1 uses λ > 1 only for Σ_ν π_λ(ν)^s < ∞ with some s < 1. For λ = 1 and a class with S_½ := Σ_ν √w(ν) < ∞ the same proof with s = ½ gives E[Post_1(B_ε)] ≤ S_½·w(P)^(−1/2)·(1−ε²)^N, and the same bound for the event of (b). For a finite class of M samplers with uniform weights this is M·e^(−Nε²): with probability at least 1 − δ the maximum-likelihood sampler has H²(Q_ν̂, Q_P) ≤ ln(M/δ)/N. In the convention D²_H = 2H² this is the proposition of Foster, Block and Misra quoted in 2.1, item 4. So Theorem B is the form of their bound for a countable class, and the steeper weights 2^(−λℓ) are what replaces the finiteness of the class.

### 5.3 What goes wrong at λ = 1

**Example 5.4 (tables against a fair coin).** Let d ≥ 1. The top-level input z is uniform on {0,1}^d and the scaffold makes one call, with input z. The human is the fair coin: P(·|x) = Bern(½) for every x. The class H_d consists of P, with ℓ(P) = 1, and of all 2^(2^d) functions f: {0,1}^d → {0,1} (as samplers), each with ℓ(f) = 2^d + 1 (the code is one bit to say "coin" or "table", then the table; the Kraft sum is 1). So K = ℓ(P) = 1.

For every table, H²(Q_f, Q_P) = 1 − 1/√2 = 0.2929. Let R be the number of recorded runs whose z has occurred before. Given the inputs, the answers are consistent with some table with probability 2^(−R); then the consistent tables have total weight 2^(−(N−R)−1) and likelihood 1, against weight ½ and likelihood 2^(−N) for P, so the posterior mass of the tables at λ = 1 is 1/(1 + 2^(−R)) ≥ ½. Hence for every ε² ≤ 0.29

 E[Post_1(B_ε | τ_1:N)] = E[2^(−R)/(1 + 2^(−R))] ≥ ½·Pr[R = 0] ≥ ½·(1 − N²/2^(d+1)),

which is at least ¼ for all N ≤ 2^(d/2). (Exact values: 0.4999 for d = 30, N = 1024; 0.479 for d = 30, N = 16384; Section 7.) Since d is arbitrary and ℓ(P) = 1, no bound of the form E[Post_1(B_ε)] ≤ β(ℓ(P), ε, N) with β → 0 as N → ∞ holds for all classes with Kraft weights. In the same class at λ = 2 the tables have relative weight 2^(R − 2^d), and Theorem 5.1 gives E[Post_2(B_ε)] ≤ 2e^(−Nε²). ∎

A table is the human "with the coins filled in": it reproduces every recorded answer and is deterministic. At λ = 1 a single draw from the posterior is such an object with probability about ½ in this class, for as long as inputs do not repeat. The digest `understand/repo.md` (item E11, read there) reports the same for the universal class: at λ = 1 the sampler and its fill-ins have comparable posterior weight. The argument of Theorem 5.1 fails at λ = 1 because for every s < 1 the sum Σ_ν w(ν)^s is infinite in such classes, or, in a finite class such as H_d, of the order 2^((1−s)·2^d). The imitation of Theorem 4.2 is not affected: in Example 5.4 the mixture of all consistent tables answers a new z like a fair coin. The phenomenon and a construction of this kind are published (Zhang 2006, Sections 4.3 and 4.4; Barron, Schervish and Wasserman 1999; see Section 5.4, item 4); Example 5.4 is a version without randomisation and with an exact posterior mass, and the reading of a table as the human with the coins filled in is this project's.

**Theorem 5.5 (Theorem B′: the likelihood to the power α; also for a human outside the class).** In the setting 5.1 (any law Q* of independent runs, any weights w with Σ w ≤ 1) let α ∈ (0,1) and

 Post^(α)(ν | τ_1:N) := w(ν)·𝓛_ν^α / Σ_ν′ w(ν′)·𝓛_ν′^α.

For every ν* ∈ H with KL(Q* ‖ Q_ν*) < ∞ the tempered posterior Post^(α) is almost surely defined, and

 E[Σ_ν Post^(α)(ν | τ_1:N)·(−ln A_α(ν))] ≤ ln(1/w(ν*))/N + α·KL(Q* ‖ Q_ν*).

Consequently E[Σ_ν Post^(α)(ν | τ_1:N)·H²(Q_ν, Q*)] ≤ [ln(1/w(ν*))/N + α·KL(Q* ‖ Q_ν*)] / (2·min(α, 1−α)). For α = ½ the right side is ln(1/w(ν*))/N + ½·KL(Q* ‖ Q_ν*); under A1 and A2 it is K ln2/N.

*Proof.* Let 𝓛* := Π_s q*(τ_s), which is positive almost surely, and r_ν := 𝓛_ν/𝓛*. Then Post^(α)(ν) = w(ν)r_ν^α/Z with Z := Σ_ν w(ν)r_ν^α, and E[r_ν^α] = A_α(ν)^N by independence. If A_α(ν) = 0 then r_ν = 0 almost surely; such ν are left out of all sums. Put Φ := Σ_ν w(ν)·r_ν^α·A_α(ν)^(−N). Then E Φ ≤ Σ_ν w(ν) ≤ 1, so Φ < ∞ almost surely; and Z ≤ Φ, while Z ≥ w(ν*)·r_ν*^α > 0 almost surely because KL(Q*‖Q_ν*) < ∞. By the concavity of the logarithm, with the probability weights Post^(α)(ν),
 ln Φ = ln Σ_ν Post^(α)(ν)·[Z·A_α(ν)^(−N)] ≥ ln Z + N·Σ_ν Post^(α)(ν)·(−ln A_α(ν)).
Therefore N·Σ_ν Post^(α)(ν)(−ln A_α(ν)) ≤ ln Φ − ln Z ≤ ln Φ + ln(1/w(ν*)) + α·ln(𝓛*/𝓛_ν*) on almost every path. The left side is non-negative; E[ln Φ] ≤ ln E[Φ] ≤ 0 by Jensen's inequality (ln Φ is bounded below by the integrable variable ln w(ν*) + α ln r_ν*); and E[ln(𝓛*/𝓛_ν*)] = N·KL(Q*‖Q_ν*). This proves the first inequality. The second follows from −ln A_α ≥ 2·min(α,1−α)·(−ln BC) ≥ 2·min(α,1−α)·H² (Lemma 5.0 and Lemma 1.1(2)). ∎

*Reading.* Post^(α) with α = 1/λ and Post_λ have the same maximisers, and Post_λ is proportional to (Π^(1/λ))^λ; raising the likelihood to the power ½ means counting each recorded run as half a run. So the substitute at λ = 1 is: keep the weights w, temper the likelihood. A program drawn from Π^(½) then has expected squared Hellinger distance at most K ln2/N from the human system, at the price K of the unsteepened weights, and by Markov's inequality H²(Q_ν̂, Q_P) ≤ K ln2/(Nδ) with probability at least 1 − δ. In Example 5.4 the tables have Π^(½)-mass at most 2^(R − N/2) (their total weight is 2^(−(N−R)−1) against ½·2^(−N/2) for the coin), which is small once N is large; at λ = 2 it is at most 2^(R − 2^d) from the start.

*Literature.* Theorem 5.5 is standard: for a countable class it is Theorem 5.1 of Zhang (2006) with his exponent ρ equal to 1/λ = α. The exact statements, and how they were read, are in Section 5.4. The proofs of Theorems 5.1 and 5.5 above do not rely on the literature.

**Proposition 5.6 (the weights w^λ and a human outside the class; a bound in probability).** In the setting 5.1 let λ ≥ 1 with S := Σ_ν w(ν)^(λ/2) < ∞ (S ≤ 1 if λ ≥ 2). Let ν* ∈ H with KL* := KL(Q* ‖ Q_ν*) < ∞ and δ₁, δ₂ ∈ (0,1). With probability at least 1 − δ₁ − δ₂ over the recorded runs, every ν ∈ H with π_λ(ν)·𝓛_ν ≥ π_λ(ν*)·𝓛_ν*, in particular every λ-MAP, satisfies

 H²(Q_ν, Q*) < KL*/(2δ₁) + [(λ/2)·ℓ(ν*)·ln2 + ln(S/δ₂) + 1/(2e·δ₁)]/N =: ε₀².

Moreover E[Post_λ({ν : H²(Q_ν, Q*) ≥ ε₀²} | τ_1:N)] ≤ δ₁ + δ₂.

*Proof.* Let Y := ln(𝓛*/𝓛_ν*). Then E[Y] = N·KL* and E[max(−Y,0)] ≤ E[e^(−Y)]/e ≤ 1/e, so E[max(Y,0)] ≤ N·KL* + 1/e, and the event G := {Y ≤ c₁} with c₁ := (N·KL* + 1/e)/δ₁ has probability at least 1 − δ₁. On G, the inequality π_λ(ν)𝓛_ν ≥ π_λ(ν*)𝓛_ν* implies √(𝓛_ν/𝓛*) ≥ √(π_λ(ν*)/π_λ(ν))·e^(−c₁/2). Since E[√(𝓛_ν/𝓛*)] = (1 − H²(Q_ν, Q*))^N ≤ e^(−Nε₀²) for the ν in question, Markov's inequality and the union bound give probability at most S·π_λ(ν*)^(−1/2)·exp(c₁/2 − Nε₀²) = δ₂ for the existence of such a ν on G. For the posterior mass, on G we have Post_λ(ν) ≤ min(1, π_λ(ν)𝓛_ν/(π_λ(ν*)𝓛_ν*)) ≤ √(π_λ(ν)/π_λ(ν*))·√(𝓛_ν/𝓛*)·e^(c₁/2), and the same computation bounds the expectation of the mass on G by δ₂. ∎

In Proposition 5.6 the approximation error KL* is divided by the confidence level δ₁. In expectation there is a clean bound for the weights w^λ as well, with the approximation error at the factor 1/λ and no confidence level: Theorem 5.7 below, which for the λ-MAP is a published theorem. (The prover's version said that only the bound in probability was available; the second verifier pointed to the published inequality.) In probability, the term KL*/δ₁ of Proposition 5.6 comes from Markov's inequality for ln(𝓛*/𝓛_ν*), whose upper tail is not controlled by its mean alone. Whether it can be replaced by a term with ln(1/δ₁) without a further assumption (such as bounded likelihood ratios between Q* and Q_ν*) is not decided here.

### 5.4 The oracle inequality for the weights w^λ, and what is in the literature

**Theorem 5.7 (the weights w^λ, a human inside or outside the class; bounds in expectation).** In the setting 5.1 (any law Q* of independent runs, any weights w with Σ w ≤ 1) let λ > 1 and let ν* ∈ H with KL(Q* ‖ Q_ν*) < ∞. Then almost surely the posterior Post_λ is defined and a λ-MAP exists, and for the posterior and for every λ-MAP ν̂:

 E[Σ_ν Post_λ(ν | τ_1:N)·(−ln A_{1/λ}(ν))] ≤ ln(1/w(ν*))/N + KL(Q* ‖ Q_ν*)/λ,
 E[−ln A_{1/λ}(ν̂)] ≤ ln(1/w(ν*))/N + KL(Q* ‖ Q_ν*)/λ.

Consequently E[Σ_ν Post_λ(ν | τ_1:N)·H²(Q_ν, Q*)] and E[H²(Q_ν̂, Q*)] are both at most

 [ln(1/w(ν*))/N + KL(Q* ‖ Q_ν*)/λ] / (2·min(1/λ, 1 − 1/λ)).

At λ = 2 this is ln(1/w(ν*))/N + ½·KL(Q* ‖ Q_ν*); under A1 and A2 it is K ln2/N.

*Proof.* Put α := 1/λ ∈ (0,1), r_ν := 𝓛_ν/𝓛*, u_ν := w(ν)·r_ν^α and Φ := Σ_ν w(ν)·r_ν^α·A_α(ν)^(−N), as in the proof of Theorem 5.5 (hypotheses with A_α(ν) = 0 have r_ν = 0 almost surely and are left out of all sums). There it is shown that E Φ ≤ 1 and that u_ν* > 0 almost surely. *Existence.* Σ_ν u_ν^λ = Σ_ν w(ν)^λ·r_ν has expectation at most Σ_ν w(ν)^λ ≤ 1, so it is finite almost surely; hence Post_λ(ν) = w(ν)^λ·𝓛_ν / Σ_ν′ w(ν′)^λ·𝓛_ν′ = u_ν^λ / Σ_ν′ u_ν′^λ is defined, u_ν → 0 along every enumeration of H, the maximum u_max := max_ν u_ν ≥ u_ν* > 0 is attained, and the maximisers of u_ν are the λ-MAPs.
*Step 1.* Let ρ be a probability vector on H, which may depend on the data, with ρ(ν) > 0 only where u_ν > 0. By the concavity of the logarithm,
 ln Φ ≥ ln Σ_{ν : ρ(ν) > 0} ρ(ν)·[u_ν·A_α(ν)^(−N)/ρ(ν)] ≥ Σ_ν ρ(ν)·[ln u_ν − N·ln A_α(ν) − ln ρ(ν)],
that is, N·Σ_ν ρ(ν)·(−ln A_α(ν)) ≤ ln Φ + Σ_ν ρ(ν)·ln(ρ(ν)/u_ν).
*Step 2.* For ρ = Post_λ the last sum equals (λ−1)·Σ_ν ρ(ν)·ln u_ν − ln Σ_ν u_ν^λ ≤ (λ−1)·ln u_max − λ·ln u_max = −ln u_max, because λ ≥ 1 and Σ_ν u_ν^λ ≥ u_max^λ. For ρ the point mass at a λ-MAP ν̂ it equals −ln u_ν̂ = −ln u_max. And −ln u_max ≤ −ln u_ν* = ln(1/w(ν*)) + α·ln(𝓛*/𝓛_ν*).
*Step 3.* So in both cases N·Σ_ν ρ(ν)·(−ln A_α(ν)) ≤ ln Φ + ln(1/w(ν*)) + α·ln(𝓛*/𝓛_ν*) on almost every path. The left side is non-negative; E[ln Φ] ≤ ln E[Φ] ≤ 0 (as in the proof of Theorem 5.5); and E[ln(𝓛*/𝓛_ν*)] = N·KL(Q*‖Q_ν*). Divide by N. The consequence follows from −ln A_α ≥ 2·min(α, 1−α)·H² (Lemma 5.0 and Lemma 1.1(2)). ∎

For the λ-MAP the theorem is Theorem 4.1 of Zhang (2006), item 1 below, at his exponent ρ = 1/λ. For the posterior Post_λ the statement and the argument above are the second verifier's (`verification/hellinger-runs-attack.md`, finding M2(c)); the editor checked the proof and tested both inequalities by enumeration of all data sets on 1473 random instances with the human inside or outside the class (largest ratios of the two sides 0.77 and 0.86; the second verifier, on 3872 instances, found 0.9945; Section 7.6). Compared with Theorem 5.1, Theorem 5.7 holds outside the class and has no factor 2^(λsℓ(P)), but it bounds an expectation: for the posterior mass of B_ε it gives, through Markov's inequality, only [ℓ(P)·ln2/N]/(2·min(1/λ, 1−1/λ)·ε²) under A2, which decays like 1/N where Theorem 5.1 decays exponentially. At λ = 1 the same proof gives a bound on −ln of the Q_ν-probability of the support of Q*, which is not a distance; this is consistent with Example 5.4.

**What is in the literature.** The outline requires that standard results be called standard. The status of the statements of Sections 4 and 5 is as follows.

1. *T. Zhang, "From ε-entropy to KL-entropy: analysis of minimum information complexity density estimation", Annals of Statistics 34(5):2180–2210, 2006* (arXiv:math/0702653; read in the arXiv PDF by the second verifier and, on 16 November 2026, by the editor). Setting: densities p(·|θ) with a prior π, n independent observations from a density q that need not belong to the family. With D_ρ(q‖p) := (1/(ρ(1−ρ)))·E_q[1 − (p/q)^ρ] and D_ρ^Re(q‖p) := −(1/(ρ(1−ρ)))·ln E_q[(p/q)^ρ]; in the notation of this file D_{1/2} = 4H² and D_ρ^Re = −ln A_ρ/(ρ(1−ρ)).
 (a) His Theorem 4.1, for a countable family p_1, p_2, … with prior weights π_k and the estimator k̂ := arg min_k [Σ_i ln(1/p_k(X_i)) + λ·ln(1/π_k)], which is the λ-MAP of this file: "Assume that λ > 1. Then ∀ρ ∈ (0, 1/λ], E_X D_ρ(q‖p_k̂) ≤ E_X D_ρ^Re(q‖p_k̂) ≤ (1/(ρ(λ−1)))·inf_k [D_KL(q‖p_k) + (λ/n)·ln(1/π_k)]." At ρ = 1/λ this is the second inequality of Theorem 5.7. Zhang calls r_{λ,n}(q) := inf_k [D_KL(q‖p_k) + (λ/n)·ln(1/π_k)] the index of resolvability, after Barron and Cover, and writes: "They showed (Theorem 4) that D_{1/2}(q‖p_k̂) = O_p(r_{λ,n}(q)) when λ > 1"; he attributes the case λ = 2, ρ = ½ to A. Barron and J. Li (J. Li, "Estimation of mixture models", PhD dissertation, Yale University, 1999, Theorem 5.5; not opened).
 (b) His Theorem 5.1, for the generalised Bayes posterior π_{1/λ}(θ|X) in which the likelihood is raised to the power 1/λ: for λ > 1 and every ρ ∈ (0, 1/λ], E_X E_π π_{1/λ}(θ|X)·D_ρ^Re(q‖p(·|θ)) ≤ −(λ/(ρ(λ−1)n))·ln E_π exp(−(n/λ)·D_KL(q‖p(·|θ))). For a countable family the right side is at most (1/(ρ(λ−1)))·inf_k [D_KL(q‖p_k) + (λ/n)·ln(1/π_k)]. At ρ = 1/λ = α this is the first inequality of Theorem 5.5. (The second verifier's report writes the factor before the infimum as λ/(ρ(λ−1)), which is too large by the factor λ; its conclusion at λ = 2, ρ = ½ is the correct one.)
 (c) His Section 4.3: for "the standard MDL (λ = 1)" "it is impossible to give a bound similar to Theorem 4.1 that depends only on the index of resolvability"; his Theorem 4.3 gives a bound at λ = 1 under a condition on the decay of the prior (finiteness of a sum Σ_j π_j^((γ−1)/(γ−ρ))), of which Remark 5.3 above (Σ_ν √w(ν) < ∞) is a relative.
2. *A. R. Barron, T. M. Cover, "Minimum complexity density estimation", IEEE Transactions on Information Theory 37(4):1034–1054, 1991* (not opened; journal data as in Zhang's reference list; content as Zhang describes it in item 1(a)). So Theorem 5.1(b) of this file, the statement about the λ-MAP for a human in the class, is a version with explicit constants, for whole runs, of a theorem of Barron and Cover, and Theorem 5.7 is its form for a human outside the class. For a finite class with uniform weights Theorem 5.1 is the proposition of Foster, Block and Misra (Remark 5.3; read in source). The explicit exponential bound of Theorem 5.1 with the free exponent s was not found in a source.
3. *A. Bhattacharya, D. Pati, Y. Yang, "Bayesian fractional posteriors"* (arXiv:1611.01125; read in source by the second verifier; the editor read only the passage quoted in item 4; the journal data *Annals of Statistics* 47(1):39–66, 2019, are from memory) have statements in probability for the posterior with the likelihood raised to a power, among them, as the second verifier quotes it: with probability at least 1 − ε, ∫ (1/n)·D_α^(n)(θ, θ_0) Π_{n,α}(dθ | X^(n)) ≤ (α/(n(1−α)))·∫ r_n(θ, θ_0) ρ(dθ) + D(ρ, Π_n)/(n(1−α)) + log(1/ε)/(n(1−α)) for every ρ ≪ Π_n.
4. *The failure at λ = 1 is the known counterexample.* Zhang (2006), Section 4.4, "Slow convergence of the standard MDL": the truth q is uniform on 2m points and has prior ¼; 2^n further densities, each equal to 1/m on m of the 2m points and drawn at random, have prior 3/2^(n+2) each; for m large enough the standard MDL estimate differs from q with probability at least 1 − e^(−1/2), "no matter how large n is" (read by the editor). Each of these densities has affinity m·√((1/(2m))·(1/m)) = 1/√2 with the truth, hence squared Hellinger distance 1 − 1/√2, the value 0.2929 of Example 5.4, and for the same reason: a hypothesis that is silent on half of the space doubles the likelihood of what it has not yet excluded. Zhang relates his example to "the Bayesian inconsistency counterexample given in" A. Barron, M. J. Schervish, L. Wasserman, "The consistency of posterior distributions in nonparametric problems", *Annals of Statistics* 27(2):536–561, 1999 (not opened). Bhattacharya, Pati and Yang describe that counterexample thus: "the posterior tends to put all its mass on a set of distributions that are √(2−√2) away from the true data generating distribution with respect to the Hellinger metric" (read in source by the editor); and (2 − √2)/2 = 1 − 1/√2.
5. *Theorem 4.2 (Theorem A)* is the progressive mixture rule: Remark 4.2a.
6. *Not found in a source:* the comparison of the frozen per-call mixture with one posterior draw per run (Examples 4.6 and 4.8, Proposition 4.7).

## 6. General countable classes, and a human outside the class

All statements of Sections 3 to 5 are stated and proved for an arbitrary countable class H of samplers with weights w(ν) > 0, Σ_ν w(ν) ≤ 1; prefix code lengths enter only through ℓ(ν) = log₂(1/w(ν)), and K = ℓ(P). No computability and no particular reference machine are used. The table collects the forms.

| statement | human in the class | human outside the class (ν* any member) |
|---|---|---|
| Theorem A (4.2): fresh posterior draw per run, weights w | E KL(Q_P‖Q̂) ≤ ln(1/w(P))/N; E TV ≤ √(ln(1/w(P))/(2N)) | E KL(Q*‖Q̂) ≤ ln(1/w(ν*))/N + KL(Q*‖Q_ν*), for every law Q* of independent runs |
| Theorem B (5.1): one draw or the MAP, weights w^λ, λ > 1 | mass of {H² ≥ ε²} at most 2^(λsℓ(P))·(1−ε²)^(2 min(s,1−s) N) | in expectation, for one draw and for the MAP: E H² ≤ [ln(1/w(ν*))/N + KL*/λ]/(2·min(1/λ, 1−1/λ)) (5.7); in probability: H² < KL*/(2δ₁) + [(λ/2)ℓ(ν*) ln2 + ln(S/δ₂) + 1/(2eδ₁)]/N (5.6) |
| Theorem B′ (5.5): one draw, weights w, likelihood to the power ½ | E H²(Q_ν̂, Q_P) ≤ ln(1/w(P))/N | E H²(Q_ν̂, Q*) ≤ ln(1/w(ν*))/N + ½·KL(Q*‖Q_ν*) |
| Theorem R2 (3.1): Protocol R, per-call mixture | E H² ≤ 2L·ln(1/w(P))/n; E TV ≤ √(2L·ln(1/w(P))/n) | E H² ≤ 2L·[ln(1/w(ν*))/n + sup_x KL(P‖ν*)(x)] (Remark 3.3) |

(KL* := KL(Q*‖Q_ν*), and S := Σ_ν w(ν)^(λ/2).)

What changes outside the class:

1. **An approximation term is added, and it is a divergence, not a distance.** For recorded runs it is KL(Q*‖Q_ν*), which for a stateless human is the per-call divergence summed along the human system's own runs (Theorem 4.2(d)). For Protocol R it is measured along the imitators' runs, and only a supremum over inputs bounds it in advance. The bounds trade the complexity ln(1/w(ν*)) against this term, and they do not tend to zero as the data grow: what remains is the approximation term, of order √(KL*/2) in total variation.
2. **If every member excludes some answer that the human gives** (KL(Q*‖Q_ν) = ∞ for all ν), all the bounds are empty, and the posterior is undefined once the data have refuted every member (which one such answer need not do). This is a property of likelihood-based learners. The minimum-distance learner of the candidate's Pr4 is aimed at this case; it is not treated here.
3. **Theorem A does not need a stateless human.** It holds for every law Q* of independent runs, for example a human who remembers the earlier calls of the same run. The class still consists of samplers, so the approximation term is then the divergence from the best stateless imitation of the whole run. Corollary 2.3 (L4) also holds for arbitrary answerers.
4. **For one fixed program** there are oracle inequalities in expectation both for the tempered posterior (Theorem 5.5) and for the steeper weights w^λ (Theorem 5.7; for the λ-MAP this is Theorem 4.1 of Zhang 2006). In probability the bound for the weights w^λ is Proposition 5.6, with the approximation term divided by the confidence level.
5. **Without A2 rehearsal asks more of the class than recorded runs do.** The bound of Remark 3.3(ii) needs sup_x KL(P‖ν*)(x) < ∞ over all inputs, including those that only bad imitators produce; for recorded runs the corresponding term is the divergence along the human system's own runs.

## 7. Numerical checks

All scripts are in `proofs/code/`; their complete outputs are saved next to them as `hellinger-runs_*.out`. Sections 7.1 to 7.5 are the prover's five scripts (copied from `research/prove-b/code/`); they need numpy, and the linear programme in `hellinger-runs_l4_lp.py` also needs scipy. The first verifier ran them again: the outputs are identical, byte for byte, to the saved ones, except that the two finest rows of the linear programme of 7.2 were not run again. Section 7.6 lists the scripts of the two verifiers (copied from `verification/code/`) and of the editor, on which the statements added after the verification rest. Lines quoted below are verbatim.

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

The chain E H² ≤ 4·E σ ≤ 2LK ln2/n holds in every row (σ is the expected sum of per-call H² along the imitator's run; the scaffold of parts (2) and (3) does not adapt, so there even E H² ≤ E σ holds, Proposition 2.4). The expected total variation grows like √L at fixed n, as Section 3.3 says. The last column of the output is the prover's bound 2·√(LK ln2/n), which is five to ten times the observed value in these instances. The final bounds of Theorem 3.1 are smaller: √(2LK ln2/n) on every scaffold (by the factor √2), and √(LK ln2/(2n)) on the scaffolds of parts (2) and (3), whose inputs do not depend on the answers (by the factor 2√2).

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

In part (1), estimate (b) is the average of ln(w_N(P)/w(P))/N, which has the same expectation as the average divergence and never exceeds the bound on any path; estimate (a) averages the conditional divergences and is noisier (in one configuration, K = 3, δ = 0.1, it came out at 0.02131 against the bound 0.02079, while (b) gave 0.02079). In part (3) the values are expectations over the data for the posterior after all N runs. In part (4) the label "(exact expectation)" of the lines for many alternatives is wrong: the expectation for each t is exact, but the sum over t is a trapezoid sum over a logarithmic grid of t. The sums over every t are 1.7855, 2.4939, 3.2097, 3.9158 for B = 4, 16, 64, 256 (first verifier, `hellinger-runs_ex48many.out`, Section 7.6); the text of Example 4.8 quotes these.

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

**7.6 Scripts of the two verifiers and of the editor.** All are in `proofs/code/` with their saved outputs. Every quantity in them is an exact finite sum evaluated in floating point (run laws by enumeration of all runs, expectations over the training data by a recursion over all data sets), except where arithmetic of higher precision is named.

| script | by | what it establishes for this file |
|---|---|---|
| `hellinger-runs_symbolic.py` | first verifier | 31 exact identities (needs sympy, which had to be installed outside the project): Lemma 2.2; the function g of Theorem 2.7 and the identities of Step 0(iii); the three forms of the parabola of Step 2 and their agreement at Λ = 1 and Λ = c; (iv), (v); Examples 2.6, 2.8(i), 2.8(ii); the integral of Example 4.8; Lemma 1.1(6); κ of Proposition 3.4 |
| `hellinger-runs_potentials.py` (run with the argument `fine`) | first verifier | q₀ and c* to 30 digits and by interval arithmetic; both one-step inequalities on the extreme laws (the constraint E r² ≤ 1 is linear in the law of r, so point masses and two-point laws with second moment 1 suffice); Step 2 on a grid; Example 2.8(ii) in 30-digit arithmetic, in two ways, and in double precision for β down to 1.000001 |
| `hellinger-runs_sec3.py` | first verifier | Lemma 1.1; Lemma 3.4a; the constants of Propositions 3.4, 3.5, 3.6; Protocol R with exact expectations (R1 and Theorem 3.1(a) to (e) in the prover's form, and the sharper (d)) |
| `hellinger-runs_sec45.py` | first verifier | Examples 4.4, 4.6 (also for the averaged law), 4.8, 5.4; Propositions 4.7, 5.6; Theorems 4.2, 5.1, 5.5; Lemma 5.0 |
| `hellinger-runs_ex48many.py` | first verifier | the second half of Example 4.8, summed over every t, by two methods |
| `hellinger-runs_attack_l4.py` | second verifier | L4 on general trees by random search and by optimisation of H²/σ (largest ratios 1.707, 2.000, 2.19, 2.31, 2.39 at depths 2 to 6, all below c*); Lemma 2.10(b), (c) on trees; Step 2 of Theorem 2.7 in 50-digit arithmetic at 4000 random points |
| `hellinger-runs_attack_events.py` (loads the two neighbouring attack scripts) | second verifier | Lemma 2.10(a) for η from ¼ to 100 on trees (the optimiser reaches the ratio 1.0000 for each η: the bound is attained); Lemma 2.10(c); Theorem 3.1(b), (c) in the final form inside Protocol R |
| `hellinger-runs_attack_r2.py` | second verifier | R1 and Theorem 3.1(a), (b), (c), (e) under Protocol R: 1500 random instances and hill climbing on each ratio, for the prover's constants and for the final ones |
| `hellinger-runs_attack_recorded.py` | second verifier | Theorem 4.2(a); Theorem 5.1(a), (b); Theorem 5.5; Theorem 5.7 (3872 instances); Example 4.6 for the averaged law by enumeration of all sequences of top-level inputs, N ≤ 5 |
| `hellinger-runs_attack_lb.py` | second verifier | Proposition 3.5: the exact Bayes risk of the two-coin problem at the stated number of questions; the number of rounds Protocol R needs on that instance (Remark 3.7) |
| `hellinger-runs_attack_misc.py` | second verifier | Example 2.8(ii) for β = 1.1, 1.01, 1.001 in two ways; Example 4.4; Lemma 3.4a; Example 5.4 by brute force over all tables; Example 4.8 with H² in place of KL, and its second half for B = 4, 16, 64 |
| `hellinger-runs_editor_checks.py` | editor | independent tests of everything added after the verification: Lemma 2.10 (one-step inequality on extreme laws, the two pointwise identities, (a), (b), (c) on 5931 random trees); the enclosure of q₀ and c* and the monotonicity of r; Theorem 3.1(d); Theorem 5.7 (1473 instances, all data sets enumerated); Example 4.6 for the averaged law; the two total variations after Example 4.8; Theorem 4.2(b) for events of probability zero; Protocol R exactly on 120 small instances with the final constants of Theorem 3.1; the second half of Example 4.8 for B = 4 and 16 |

Lines from the editor's output (`hellinger-runs_editor_checks.out`):

```
(E1) Lemma 2.10
     one step, max of E U(Lam r) - U(Lam) - g m^2 (1 - E r) over extreme laws: 1.776e-15  (must be <= 0 up to rounding)
     5931 random trees (depth <= 5 binary, <= 4 ternary, exact zeros): largest ratio of the two sides
       (a) sup_G [P(G) - (1+eta) Q(G)] / [2(1+1/eta) sigma]: eta=0.25: 0.9370, eta=1: 0.9974, eta=4: 0.9542, eta=100: 0.9901
       (b) P(q = 0) / (2 sigma): 1.0000     (c) TV / min(1, sigma + sqrt(sigma^2 + 2 sigma)): 1.0000     (all must be <= 1)
(E2) Theorem 2.7: the root q0 and the constant c*
     q0 = 1.15120357300424285968266629425   c* = 2.96414715730767803218167583868
     hence 1.15120357 < q0 < 1.15120358 and 2.96414712692 < c* < 2.96414722807
(E4) Theorem 5.7: oracle inequality in expectation for the weights w^lambda (posterior and lambda-MAP)
     largest E[posterior mean of -ln A_(1/lambda)] / rhs = 0.7745;  largest E[-ln A_(1/lambda)(MAP)] / rhs = 0.8572   (must be <= 1)
(E8) Protocol R, exact (expectation over all data sets and T): ratios to the bounds of R1 and Theorem 3.1
     R1: sum_t E[E sum_j KL] / (L K ln2) <= 1.0000
     3.1(a): E H^2 / (2 L K ln2 / n) <= 0.2491
     3.1(b): E TV / min(1, s + sqrt(s^2 + 2s)), s = L K ln2/(2n): <= 0.9999  (on the instances with s <= 1/8: <= 0.2615)
     3.1(c): E sup_G [Q_M(G) - (1+eta) Q_P(G)] / ((1 + 1/eta) L K ln2 / n): eta=0.25: 0.2009, eta=1: 0.4950, eta=4: 0.7920
     3.1(c): E Q_M(runs of Q_P-probability zero) / (L K ln2 / n) <= 0.9900     (every ratio must be <= 1)
```

In (E8) the ratio 0.9999 for (b) occurs where the bound is the trivial bound 1 (a prior mixture that is nearly singular to the human); the ratio 0.99 for events of probability zero shows that the constant of that bound cannot be lowered by more than one per cent, whereas the prover's constant 4 was loose by the factor 4. Lines from the second verifier's outputs: `hellinger-runs_attack_events.out` has, for the event bound, "eta = 1 random trees: 0.96055 optimised: 0.99999995"; `hellinger-runs_attack_r2.out` has the largest ratios "r3n (new TV bound) 1.0000" and "r4n (new null-event bound) 0.9990" over 1500 random instances of Protocol R.

## 8. What remains open, and remarks on other parts of the candidate theory

### 8.1 Open in this part

1. **The best constant in L4.** 2.9639 ≤ c₀* ≤ 2.9642, with c₀* ≤ c* = 2.964147… (Theorem 2.7 and Example 2.8(ii)). That c₀* = c* is not proved: it needs the convergence of the ratio of the strategy of Example 2.8(ii) to c*, for which there is only the computation. The value of c* is enclosed by interval arithmetic: 2.96414712 < c* < 2.96414723.
2. **The per-call mixture after recorded runs** (Section 4.3): for an adaptive scaffold and a stochastic human, is E TV(Q_{M_t}, Q_P) ≤ C·√(LK/N)? Proposition 4.7 covers a deterministic human and scaffolds that do not adapt; Example 4.8 shows that the summed per-call divergences are not controlled.
3. **The last round in place of a random round** in Theorems 3.1 and 4.2: this file shows only non-monotonicity (Example 4.4). For Protocol R the part `rehearsal-core` answers the question in part (`proofs/rehearsal-core.md`, Section 6, Propositions 6.1 to 6.4; not checked here): for a deterministic human the last mixture has bounds on a scaffold whose inputs do not depend on the answers and weaker ones in general; the summed per-call divergence of the last mixture can exceed L·K ln2/n by the factor (L − 1)/8 in an example; for a human who is not deterministic the last round stays open for whole runs. For recorded runs (Theorem 4.2) the question is open; for Bayes predictive distributions in general it is posed as an open problem by Grünwald and Kotłowski (2011; Remark 4.3).
4. **The lower bound** of Proposition 3.4 has the constant 1/(8·10⁴) and is for one class. The number of questions needed for whole-run total variation ε as a function of the class and the scaffold is not characterised; in the examples it ranges from at most LK ln2/ε (functions) to the order LK/ε² (coins).
5. **Outside the class:** in expectation the question for the steeper weights is answered (Theorem 5.7). Open: a bound in probability in which the approximation term is not divided by the confidence level (Proposition 5.6); and the case in which every member excludes an answer the human gives.
6. **One fixed program inside Protocol R.** Theorem 5.1 needs independent recorded runs of the human system. Its analogue for the data of Protocol R (single calls on the mixtures' runs), which would be the version of the candidate's R4 and R6 for a stochastic human, is not treated here.
7. **A human with memory across runs** is outside every statement of this file.
8. **The constants of Theorem 3.1.** (i) Does E TV(Q_{M^(T)}, Q_P) ≤ √(LK ln2/(2n))·(1 + o(1)) hold on scaffolds whose inputs depend on the answers? It holds when they do not (Theorem 3.1(d)); in general Theorem 3.1(b) has √(LK ln2/n) to first order, larger by √2 (Remark 2.12(iv)). (ii) The best constant C in E H² ≤ C·LK ln2/n: at most c*/2 < 1.49, and not below ½ on the computed evidence (Remark 3.3(iv)).
9. **Sources not opened.** (i) Kabanov, Liptser and Shiryaev (1986) and Jacod and Shiryaev, Chapter V, Section 4: the classical upper bound for the variation distance in terms of the Hellinger process, quoted in Section 2.1, item 7, from a verifier's memory; its statement and constant must be checked in the source before the note relates Lemma 2.10(c) to it. (ii) Lemma 11.5.3 of Duchi's lecture notes, the course note on the chain rule for the squared Hellinger distance on a Yale statistics page, and Jayram (2009): until they are read, "no published constant below 7 for the inequality with H² on the left" is a statement about the sources that were opened. (iii) Barron and Cover (1991), Barron, Schervish and Wasserman (1999), Li (1999), Catoni (1997, 1999, 2004), Yang (2000) and Barron (1987) are cited as Zhang (2006) and Juditsky, Rigollet and Tsybakov (2008) describe them. The hosts link.springer.com and web.stanford.edu do not resolve from these sessions; they would have to be allowed in the session's network settings.

### 8.2 Remarks on other parts of the candidate theory

1. **L4, the source of the constant.** The constant 7 is in Foster, Han, Qian and Rakhlin (arXiv:2404.10122), via Jayram's cut-and-paste lemma; the paper named in the candidate theory (Foster, Kakade, Qian and Rakhlin) has 10²·log n. Corollary 2.3 gives 4 by a ten-line proof, and Theorem 2.7 gives c* < 2.9642, where the best constant is at least 2.9639. The citation should stay next to the new constants, and for the total variation the classical line of Section 2.1, item 7, should be cited once its source has been opened. The candidate's change-of-measure inequality with (5/3, 16/3) is correct but no longer needed.
2. **R2 should be stated for single events as well as in total variation** (Theorem 3.1(c)): for an event that the human system never produces, the deployed run has it with probability at most LK ln2/n. This is the linear rate of the deterministic case, with the same constant, and it is the relevant form for "fails only obviously" and for the candidate's Pr1 (all properties at once: within φ(s) ≤ √(2LK ln2/n) additively; and E[Q_{M^(T)}(G)] ≤ 2Q_P(G) + 2LK ln2/n multiplicatively).
3. **Section 0, item 2, and Section 10, test 5 (budget)** quote the numbers of the deterministic case. For a stochastic human the whole-run budget is (1+δ)·LK ln2/δ² rounds for total variation δ, and Proposition 3.4 shows that the order LK/δ², including the factor K, is necessary for some classes. Under the low-stakes assumption of R3, the candidate's bound β ≤ L·√(K ln2/(2n)) on the expected number of unfaithful calls gives failure ≤ δ_f + √(K ln2/(2n))/θ for tolerance θL, that is n ≥ K ln2/(2θ²δ²), again quadratic in 1/δ. The order L·√(K/n) of β is attained for the K coins (Proposition 3.6). With K for a person every bound of this file is empty: for K = 10⁹ bits, L = 100 and δ = 0.1 the count is 7.6·10¹² rounds, and by Proposition 3.4 no protocol does better than the order LK/δ² in the worst case for this criterion.
4. **Section 0, item 3, and Proposition R5** ("the right deployed object is the per-call mixture"): at most under low stakes (a reading that this file does not prove; Remark 4.9). For whole-run fidelity from recorded runs the per-call mixture is worse than one posterior draw per run by a factor up to L (Example 4.6), while the expected number of unfaithful calls along the human's run is the same for both (Remark 4.9).
5. **Section 3, remark (iii)** ("random round cannot be replaced by last round in general"): the learning curve is indeed not monotone (Example 4.4), but that does not by itself show that a last-round bound fails. For Protocol R the part `rehearsal-core` gives examples in which it fails for the summed divergence (8.1, item 3).
6. **Theorem B for λ > 2:** use s = ½ (Theorem 5.1(c)); the candidate's exponent 2·min(1/λ, 1−1/λ) is correct but gives a larger sample size there.
7. **Section 12** is correct: with P₁ = point mass at b, P₂ = Bern(½) and R = (1−ε)·δ_a ⊗ Bern(0.01) + ε·δ_b ⊗ Bern(½) one has KL(P₁⊗P₂‖R) = ln(1/ε), while the sum of the marginal divergences is ln(1/ε) + KL(Bern(½)‖(1−ε)Bern(0.01) + ε·Bern(½)), which is larger. Examples 4.6 and 4.8 show that this is not only a gap in a proof: the conclusion fails as well.
8. **A3.** The proofs of R1 and of everything in this file use only the first half of A3 (the protocol's coins are independent of the human's coins). The clause "not computable by any hypothesis" is not used: a hypothesis is a kernel in x alone and cannot depend on the protocol's coins.
9. **Theorem A and the human's time.** By Proposition 3.4 (whose protocols may record whole runs), N·L ≥ LK/(8·10⁴·ε²) answers are needed in the worst case, so recorded runs save no human answers over Protocol R beyond a constant. For the same number n = N·L of rounds, the bound √(K ln2/(2N)) of Theorem 4.2(c) equals the bound of Theorem 3.1(d) when the inputs do not depend on the answers; on other scaffolds it is smaller than the bound √(2K ln2/N) of Theorem 3.1(b) by the factor 2, and by √2 to first order. (A round of Protocol R is at most one answer, so in answers actually given Protocol R does no worse.) What Theorem A costs is that the human must execute whole runs.

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

*A variant in which no round is wasted* (first verifier, improvement E). Let J_t be drawn uniformly from {1, …, len(τ_t)} when the run of round t made at least one call, so that every such round puts a question. Lemma A.1 applies as before and gives Σ_{t ≤ n} E[1{len(τ_t) ≥ 1}·KL(P‖M^(t))(x_(t,J_t))] ≤ K ln2. Given D_(t−1) and τ_t, the conditional expectation of the summand is now (1/len(τ_t))·Σ_{j ≤ len(τ_t)} KL(P‖M^(t))(x_(t,j)), which is at least (1/L) times the same sum. So R1 holds for this variant with the same bound, and with it Theorem 3.1. The protocol then need not know L, which enters only the bound.

*What is standard.* Lemma A.1 is the regret bound for Bayes mixtures on adaptively chosen questions, and R1 for a deterministic human is the estimation step of Li and Zhang's analysis of their algorithm; the attributions are those of `research/outline.md`, Addendum 2, items 1 and 2, and belong to the part `rehearsal-core`, whose final proof of R1 is in `proofs/rehearsal-core.md`. The proof is kept here so that this file is self-contained.


## Checking

This section was written by the editor of the part. It lists every finding of the two verification reports and what was done about it, and then says, for each statement that the text of the note (`research/sections/hellinger-runs.md`) uses, who checked its proof.

**The two reports.** `verification/hellinger-runs-check.md` (the first verifier, C): every proof recomputed by hand, line by line; every identity checked symbolically; every inequality with a potential checked numerically on the extreme points of its constraint set; every numerical claim recomputed with an independent script; the four papers of Section 2.1 read in source. Verdict: no statement wrong; thirteen corrections, six improvements. `verification/hellinger-runs-attack.md` (the second verifier, A): the proofs rederived by hand; exact computation on small instances and adversarial search; the literature searched. Verdict: no statement false; three major findings (sharper constants for R2; results that are standard; the scope of "no published constant below 7"), nine minor ones, six on wording. Both reports are complete.

**What the editor did before deciding.** The editor verified each finding before accepting it: every proof proposed in the reports (Lemma 2.10, Proposition 3.6, Theorem 5.7, the sharper Theorem 3.1(d), the step for the averaged law in Example 4.6, the bound for events of probability zero in Theorem 4.2) was read line by line and re-derived; `proofs/code/hellinger-runs_editor_checks.py` tests each of them on exact instances (Section 7.6); the prover's scripts `l4_check`, `r2_coins`, `thmA`, `thmB` and the verifiers' scripts `sec3`, `sec45` and `potentials` (with the argument `fine`) were run again from `proofs/code/` and reproduce their saved outputs byte for byte, and `attack_misc`, `attack_r2`, `attack_recorded`, `attack_l4`, `attack_events`, `attack_lb`, `ex48many` reproduce theirs apart from the line that reports the running time (not run again by the editor: the prover's linear programme `l4_lp`, and `symbolic`, which needs sympy); and the passages of the literature on which the new attributions rest were read by the editor in source on 16 November 2026 (the lemmas of arXiv:2404.10122 and arXiv:2112.13487; Theorems 4.1, 4.3, 5.1 and Sections 4.3, 4.4 of Zhang 2006 in arXiv:math/0702653; Corollary 5.4 of Juditsky, Rigollet and Tsybakov in arXiv:math/0511468; one sentence each of arXiv:1611.01125 and arXiv:2508.02637; Proposition 2.1 of arXiv:2103.09648; the abstract of Grünwald and Kotłowski 2011).

### Findings of the first verifier (check report, Part III and Part IV)

| no. | finding | decision | what was done |
|---|---|---|---|
| C1 | The upper bound is rounded down: "c₀* ≤ c* = 2.9641", "best constant up to the fourth digit", while c* = 2.964147… | accepted | Everywhere: c* = 2.964147… < 2.9642 and 2.9639 ≤ c₀* ≤ 2.9642 (summary, In brief, 2.1, 2.4, Theorem 2.7, Example 2.8, 8.1, 8.2) |
| C2 | Example 4.6 bounds each Q_{M_t}; Theorem A is about the average over t | accepted | Paragraph on the averaged law added to Example 4.6 (total variation is linear in the law; the divergence by the common bound on more than half of the top-level inputs); the editor's enumeration (E5) and the second verifier's confirm it |
| C3 | Section 3.3, qualification (3): the order L·√(K/n) of the number of unfaithful calls is asserted, "not written out" | accepted | New Proposition 3.6 with the verifier's statement and proof; the editor checked the proof |
| C4 | The sentence after Example 4.8 ("the same to first order") is wrong by a factor up to 2 | accepted | Replaced by the two exact formulas p·ω_t and p·ω_t·(2 − ω_t) (re-derived by the editor, E6) |
| C5 | Example 4.8, second half: the four numbers are quadrature values, two change at the quoted precision; the construction is only in the script | accepted | Construction stated in the text; numbers replaced by 1.786, 2.494, 3.210, 3.916; "exact" removed; note in Section 7.4. The editor recomputed the first two independently (E9: 1.7855, 2.4939) |
| C6 | Theorem 2.7: the root is unique (one line); c* can be enclosed rigorously | accepted | Step 0 (iii′) added; the enclosure 2.96414712 < c* < 2.96414723 is in the statement; the editor recomputed it with interval arithmetic (E2) |
| C7 | Lemma 1.1(4): data processing is proved for countable sets only, and is used for laws of runs with a general Ω₀ | accepted | Sentence for general measurable spaces added to the proof |
| C8 | n counts rounds; the human answers at most n questions | accepted | Paragraph after Protocol R; the table of Section 3.3 and the text of the note count rounds (a round is at most one question) |
| C9 | Letters that the outline fixes are reused (L_ν, Π_λ, ρ_N, τ_Λ; m, β, G, δ; r, s, p, q, k, μ inside Theorem 2.7) | accepted in part | Renamed: ζ_Λ, Res_N, 𝓛_ν, Post_λ and Post^(α), the four that collide with a fixed symbol in a statement. Not renamed: m, β, G, δ and the local letters of Theorem 2.7; each is defined where it is used, the outline's m (validation) and the β of R3 do not occur in this file, and renaming single letters by hand throughout proofs that both verifiers have checked would risk new errors. The notation paragraph at the top lists them; the text of the note avoids them |
| C10 | Section 3.3, table, first row quotes N2 in the candidate's unchecked form | accepted | The row now has L/(4ε) − L with the pointer `proofs/lower-bounds.md`, Corollary 2.2 |
| C11 | Remark 2.9: the constant 12.6 has no written proof | accepted | The remark says so; the figure is not a result of this file and is not in the note |
| C12 | After Corollary 5.2: "the same up to a factor 2" compares a bound in probability with a bound in expectation | accepted | Sentence rewritten |
| C13 | Small: the hypothesis δ ≤ ¼ of Proposition 3.4 is redundant; G(N, δ) should be defined for all N; a_j on sequences that the scaffold cannot produce; Section 6, point 2 | accepted | All four fixed in place |
| C-A | Improvement: Theorem 3.1(d) can be sharpened to E KL(Q_P‖Q_{M^(T)}) ≤ LK ln2/n and E TV ≤ √(LK ln2/(2n)) | accepted | Theorem 3.1(d) restated and proved (re-derived by the editor; E3) |
| C-B | Improvement: rigorous enclosure of c* | accepted | See C6 |
| C-C | Improvement: finer values of Example 2.8(ii) | accepted | Quoted after Example 2.8, with the remark that the two finest are in double precision |
| C-D | Improvement: 4 is the best constant for the potential of Lemma 2.2 | accepted | Sentence in Section 2.4; the editor adds that the family (γ/2)(m − x)₊² gives m²/(m − 1), smallest at m = 2 |
| C-E | Improvement: J_t uniform on the calls that the run made | accepted | Appendix A, and one clause after Protocol R |
| C-F | Improvement: Q(A) ≤ H²(2 − H²) when P(A) = 0 | accepted | Lemma 1.1(5) |
| C-notes | Notes in the entries: ρ_N collides with ρ; the event G of Theorem 3.1(c) must be fixed before the data; the closed system should be said in words; Remark 4.9 contains a reading | accepted | Res_N; "fixed before the data are seen" in Theorem 3.1(c) and 4.2(b); item (iii) after Protocol R; Remark 4.9 reworded |

### Findings of the second verifier (attack report, Sections 3 and 4)

| no. | finding | decision | what was done |
|---|---|---|---|
| M1 | The bounds of R2 on the total variation and on events are loose by the factors 2 and 4 because they go through L4; a direct potential argument (the report's Lemma X) gives the constants of a single call | accepted | New Section 2.5 (Lemma 2.10, Corollary 2.11, Remark 2.12); Theorem 3.1(b), (c) restated with E TV ≤ φ(s) ≤ √(2LK ln2/n) and E Q_{M^(T)}(G) ≤ (1+η)·Q_P(G) + (1+1/η)·LK ln2/n; Remarks 3.2, 3.3, Section 3.3, Section 8.2 updated. The editor re-derived the proof and tested it (E1, E8). The other direction (Q_P(G) in terms of Q_{M^(T)}(G)) is not covered by the lemma and stays with the constant 4 (Theorem 3.1(c), last inequality) |
| M1-open | Whether E TV ≤ √(LK ln2/(2n))·(1 + o(1)) holds on adaptive scaffolds | recorded as open | Remark 2.12(iv); Section 8.1, item 8 |
| M2(a) | Theorem A is the progressive mixture rule (Catoni; Yang), as described by Juditsky, Rigollet and Tsybakov (2008, Corollary 5.4) | accepted | Remark 4.2a(i); status STANDARD in the summary. The editor read the corollary and the sentence of attribution in the arXiv text; Catoni's and Yang's papers were not opened |
| M2(b) | Theorem B′ is Theorem 5.1 of Zhang (2006) | accepted, with one correction to the report | Section 5.4, item 1(b). The editor read the theorem. The report's intermediate formula for a countable class has the factor λ/(ρ(λ−1)) where 1/(ρ(λ−1)) is right; its conclusion at λ = 2, ρ = ½ is correct |
| M2(c) | The oracle inequality that the file said it did not have for the weights w^λ is Theorem 4.1 of Zhang (2006) for the λ-MAP, and the same lines give it for the posterior | accepted | New Theorem 5.7 (stated for λ > 1, where A_{1/λ} is defined in 5.1), with a proof that the editor checked and tested (E4); the sentences "I have only the bound in probability" are gone; Proposition 5.6 is kept as a bound in probability |
| M2(d) | Example 5.4 is in substance the counterexample of Barron, Schervish and Wasserman (1999) in the form of Zhang (2006, Section 4.4) | accepted | Section 5.4, item 4, and one sentence after Example 5.4. The editor read Zhang's Sections 4.3 and 4.4; the 1999 paper was not opened |
| M3(a) | The attribution of 7 and of 10²·log n is correct | no change needed | The editor read both lemmas again in source |
| M3(b) | Bounds of the variation distance by the Hellinger process are classical (Kabanov, Liptser and Shiryaev 1986), so "no published constant below 7" holds only for the form with H² on the left | accepted, with a reservation | Section 2.1, item 7, and the last paragraph of 2.1. The source could not be opened by anyone (the host is not reachable); the statement and its constant are from the verifier's memory and are marked so; Section 8.1, item 9 |
| M3(c) | Duchi's notes (Lemma 11.5.3), a Yale course note and Jayram (2009) remain unopened | accepted as a caveat | Section 2.1, last paragraph; Section 8.1, item 9 |
| m1 | "The factor √L is necessary": state the scope (criterion; repeated inputs with fresh coins; uniform weights) and how far the constants are from the truth | accepted | "Method and scope" after Proposition 3.4; Remark 3.7; Section 3.3 |
| m2 | Theorem 3.1(a) is far from attained in every computation | accepted | Remark 3.3(iv); Section 8.1, item 8 |
| m3 | Example 4.6: the thresholds are sufficient conditions; exact values | accepted | Sentence in Example 4.6 |
| m4 | The imitator of Theorem A is not a sampler | accepted | Remark 4.2a(ii); said in Section 5.2 of the note |
| m5 | Theorem 4.2(b): E Q̂(G) ≤ Res_N(ν*) if Q*(G) = 0 | accepted | Statement and proof of Theorem 4.2(b); tested (E7) |
| m6 | The last-round question is, from memory, a known open problem (Grünwald and Kotłowski 2011) | accepted | Remark 4.3. The editor confirmed the reference and the wording of the problem on the web page of the proceedings; the paper itself was not opened |
| m7 | L is the largest number of calls and must be known; n counts rounds, and runs differ in length | accepted | Items (i), (ii) after Protocol R; Appendix A (the variant needs no L) |
| m8 | Example 4.8: the ratio is unbounded only as w(P) → 1; the route through per-call H² is closed too | accepted | One sentence at the end of the example; the paragraph after it |
| m9 | Proposition 5.6 is dominated in expectation by the published inequality | accepted | Summary; paragraph after Proposition 5.6; Section 6 |
| w1 | c* rounded down | accepted | See C1 |
| w2 | "Theorem A is false for the per-call mixture" should say how it fails | accepted | Title of Example 4.6; the paragraph "How the statement fails" |
| w3 | Remark 4.9, last sentence, is a reading | accepted | Reworded |
| w4 | "R2 is optimal up to an absolute constant" | accepted | Now: the order LK/ε² is necessary in the worst case, with the size of the constant between the proved bounds |
| w5 | Section 3.3, qualification (2), "up to the factor 4" | accepted | With the new constants there is no factor |
| w6 | Section 8.2, item 1: the citation should stay | accepted | Reworded |
| H1–H9 | Hidden assumptions: closed system; A1 in two strong forms; the event is fixed before the data; expectation over data and T, confidence only through Markov's inequality; one run; L known; Theorem A needs independent recorded runs and an imitator with a state that lasts for a run; outside the class Protocol R needs a supremum over all inputs; answers ⊥ | accepted | Protocol R, items (i) to (iii); Theorem 3.1(c); Remark 3.2(ii), (iii); "Method and scope" (ii); Remark 4.2a(ii); Remark 3.3(ii) and Section 6, point 5; Section 0.1 already says the last. Each is stated in the text of the note where the result is stated |
| tests | The researcher's seven tests: the budget test is the one the part fails (K for a person; quadratic in 1/ε; nothing amplified within a run) | accepted for the part's own text | Section 8.2, item 3; the text of the note says where the bounds are empty. The other six readings belong to Section 10 of the note (part `assumptions`) |

No finding was rejected outright. Two were accepted in part (C9; M2(b), where the report's intermediate formula is corrected), and one with a reservation about an unopened source (M3(b)).

### Who checked the statements that the text of the note uses

"C" and "A" are the two reports; "E" is the editor. A statement that neither verifier checked and the editor did not re-derive would be marked "not independently checked" in the text of the note; there is none. Statements that only their author and the editor checked are named as such in the note.

| statement in the note | proof in this file | checked by |
|---|---|---|
| L4(a): H²(Q_A, Q_B) ≤ 4σ_A | Lemma 2.2, Theorem 2.1(c), Corollary 2.3 | C (hand, symbolic, extreme laws), A (hand, optimisation over trees), E (as the case m = 2, γ = 1 of Lemma 2.10) |
| the constant c* < 2.9642, and the lower bound 2.9639 | Theorem 2.7, Example 2.8 | C (every identity symbolically, Step 2 on a grid, the example in 30-digit arithmetic), A (hand; Step 2 in 50-digit arithmetic); the enclosure of c*: C, E |
| L4(b), (c): TV ≤ φ(σ_A); Q_A(G) ≤ (1+η)·Q_B(G) + 2(1+1/η)·σ_A; Q_A(G) ≤ 2σ_A if Q_B(G) = 0 | Lemma 2.10, Corollary 2.11 | A (author; exact tests on trees and inside Protocol R), E (proof re-derived; E1). Not checked by C |
| constant 1 when the inputs do not depend on the answers | Proposition 2.4 | C; A read the proof |
| R2(a) (the bound on H²), and the first sentence of the block (a deterministic human) | Theorem 3.1(a), (e) | C, A |
| R2(b), (c) (total variation and events, in the final form) | Theorem 3.1(b), (c) | A (statement, exact computation), E (proof; E8). C checked the prover's weaker form |
| R2 when the questions do not depend on the answers | Theorem 3.1(d) | C (author; exact check), E (proof; E3) |
| several runs of the same imitator are jointly within √(2r·L·K ln2/n) (r runs; k in this file) | Corollary 2.11, Remark 3.2(iii) | E; the statement was proposed by A |
| lower bounds for the K coins and for two samplers | Propositions 3.4, 3.5 | C (all constants recomputed), A (proofs rederived; exact Bayes risk for 3.5) |
| the number of unfaithful calls is of order L·√(K/n) | Proposition 3.6 | C (author), E |
| Theorem H1 (Theorem A), also outside the class | Theorem 4.2 | C, A (1465 random instances); the bound for events of probability zero: A (author), E (E7) |
| the per-call mixture fails in H1 by a factor up to L | Example 4.6, Proposition 4.7 | C (formulas by brute force; the step for the averaged law), A (exact enumeration for N ≤ 5), E (E5) |
| Theorem H2 (Theorem B) | Theorem 5.1, Corollary 5.2 | C (24 exact cases), A (2000 random classes) |
| failure of H2 at λ = 1 | Example 5.4 | C (brute force over all tables; exact values), A (brute force) |
| the form with the likelihood to the power ½ (Theorem B′) | Theorem 5.5 | C, A (3872 instances); it is Zhang's Theorem 5.1 (read by A and E) |
| the oracle inequality for the weights w^λ | Theorem 5.7 | A (author; 3872 instances), E (proof; E4); for the λ-MAP it is Zhang's Theorem 4.1 (read by A and E). Not checked by C |
| R1 (used, not part of this file's results) | Appendix A | C, A; its final proof belongs to the part `rehearsal-core` |
