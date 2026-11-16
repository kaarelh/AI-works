# Referee report, line by line: `research/prove-b/hellinger-runs.md` (key: hellinger-runs)

Checked file: `research/prove-b/hellinger-runs.md` (579 lines; labels L4, R2, A, B), with its scripts `research/prove-b/code/hellinger-runs_*`. The file was not changed. This report has six parts: (I) what was done and the result in brief; (II) one entry per statement; (III) the corrections that must be made, ordered by importance; (IV) improvements that the check produced; (V) what was not checked; (VI) notes for the editor of the two section blocks.

**Verdict words.** CORRECT: the statement and its proof stand as written. MINOR: correct after the small fix given. GAP: a step is missing; it is named and filled here. WRONG: the statement fails. No statement of the file received the verdict WRONG.

## I. What was done, and the result in brief

**Method.** Every proof was recomputed by hand, line by line. Every identity that the file calls "a direct computation" was checked symbolically. Every inequality with a potential was checked numerically on the extreme points of its constraint set. Every numerical claim was recomputed with an independent script. The four papers of Section 2.1 were downloaded from arxiv.org/e-print during this session (15 November 2026) and read in their TeX sources.

**Scripts of this report** (in `research/verify/code/`, outputs saved next to them as `.out`):

| script | content | needs |
|---|---|---|
| `hellinger-runs_symbolic.py` | 31 exact identities: Lemma 2.2; the function g of Theorem 2.7 and the identities (iii); the three forms of the parabola in Step 2 and their agreement at Λ = 1 and Λ = c; (iv), (v); Examples 2.6, 2.8(i), 2.8(ii); the integral of Example 4.8; Lemma 1.1(6); κ of Proposition 3.4 | sympy |
| `hellinger-runs_potentials.py` | q₀ and c* to 30 digits and by interval arithmetic; both one-step inequalities on the extreme laws; Step 2 on a grid; Example 2.8(ii) in 30-digit arithmetic, computed in two ways | numpy, scipy, mpmath |
| `hellinger-runs_sec3.py` | Lemma 1.1; Lemma 3.4a; the constants of Propositions 3.4, 3.5; Protocol R with exact expectations (R1 and Theorem 3.1(a) to (e)) | numpy, scipy |
| `hellinger-runs_sec45.py` | Examples 4.4, 4.6, 4.8, 5.4; Propositions 4.7, 5.6; Theorems 4.2, 5.1, 5.5; Lemma 5.0; all with exact expectations | numpy |
| `hellinger-runs_ex48many.py` | the second half of Example 4.8, summed over every t, by two methods | numpy, scipy |

How the outputs were made: each script was run without arguments, except `hellinger-runs_potentials.py fine` (the argument adds β = 1.0001 in 30-digit arithmetic and two finer values of β in double precision; about three minutes). sympy is not installed in this environment; for the symbolic script it was installed outside the project (version 1.14.0). No script writes a file.

The prover's scripts `hellinger-runs_l4_check.py`, `_r2_coins.py`, `_thmA.py`, `_thmB.py` were run again: their outputs are identical, byte for byte, to the saved `.out` files. `hellinger-runs_l4_lp.py` was run again in its default mode: identical output up to the grid ratio u = 1.035; the two finest rows of the linear programme (u = 1.025 and 1.018, 1.1 and 2.7 million constraints) were not run again.

**Result in brief.**

1. **The mathematics is correct.** Both potential arguments for L4 hold (constants 4 and c*). R2 in general, the lower bounds, Theorem A, the counterexample for the per-call mixture, Theorem B, its failure at λ = 1 and the substitute B′ are all correct, with the constants stated. Every constant was recomputed; the recomputed values are in the entries.
2. **The attribution is correct.** The constant 7 is in Foster, Han, Qian and Rakhlin (arXiv:2404.10122), not in Foster, Kakade, Qian and Rakhlin (arXiv:2112.13487), which has 10²·log n. Both checked in source.
3. **The corrections are small.** The most important ones: an upper bound rounded in the wrong direction ("c₀* ≤ 2.9641", where c* = 2.964147); one sentence of Example 4.6 that argues for each round t separately where Theorem A is about the average over t (one line closes it); one claim of Section 3.3 that the file itself marks "not written out" (filled here); one wrong sentence after Example 4.8 ("the same to first order": the two total variations differ by the factor 2 − ω_t); and four numbers of Example 4.8 called exact that are quadrature values (off by up to 2 per cent; two of the four change at the quoted precision).
4. **Two things the check adds.** (a) The root q₀ is unique, and c* is enclosed rigorously: 2.96414712 < c* < 2.96414723. (b) Theorem 3.1(d) can be sharpened: when the inputs do not depend on the answers, E KL(Q_P ‖ Q_{M^(T)}) ≤ LK ln2/n and E TV ≤ √(LK ln2/(2n)), which is exactly the bound of Theorem A for the same number of answers.

**Verdicts at a glance.**

| statement | verdict |
|---|---|
| Section 0, setting | CORRECT |
| Lemma 1.1 | MINOR (data processing is proved for countable sets only; one sentence) |
| Section 2.1, literature and attribution of 7 and of 10²·log n | CORRECT (read in source) |
| Lemma 2.2, Theorem 2.1 | CORRECT |
| Corollary 2.3 (**L4**, constant 4) | CORRECT |
| Propositions 2.4, 2.5; Example 2.6 | CORRECT |
| Theorem 2.7 (constant c*) | MINOR (proof correct; add uniqueness of the root; c* < 2.9642) |
| Example 2.8 | MINOR (values confirmed; "c₀* ≤ 2.9641" must read 2.9642) |
| Remark 2.9 | CORRECT for the inequality; the figure 12.6 has no proof |
| Protocol R, Theorem R1, Lemma A.1 | CORRECT |
| Theorem 3.1 (**R2**), Remarks 3.2, 3.3 | CORRECT |
| Lemma 3.4a, Propositions 3.4, 3.5 | CORRECT |
| Section 3.3 | GAP, filled (qualification 3, "not written out") |
| Lemma 4.1, Theorem 4.2 (**A**), Remark 4.3, Example 4.4, Lemma 4.5 | CORRECT |
| Example 4.6 (per-call mixture) | GAP, filled (the bounds are shown for each t, not for the average over t) |
| Proposition 4.7 | CORRECT |
| Example 4.8 | MINOR (four numbers are quadrature values, two change; one wrong sentence after the example) |
| Remark 4.9, Lemma 5.0 | CORRECT |
| Theorem 5.1 (**B**), Corollary 5.2, Remark 5.3 | CORRECT |
| Example 5.4 (λ = 1), Theorem 5.5 (**B′**), Proposition 5.6 | CORRECT |
| Section 6 | CORRECT |
| Sections 7 and 8 | MINOR (wording carried over from the items above) |

## II. Entries, statement by statement

### Section 0 (setting and conventions): CORRECT

The conventions agree with `research/outline.md`: H² = 1 − Σ√(pq), KL in nats, K = log₂(1/w(P)), "K ln2" in the bounds, T the deployed round.

Two remarks, neither a defect of substance.

* 0.3: the kernel a_j must be defined on all of Ω₀ × Y′^(j−1), also on sequences that the scaffold cannot produce (a symbol ∅ before the run has stopped), where next_j is not defined. "Point mass at ∅ otherwise" covers them if "otherwise" is read to include them. The final text should say so in three words. Such sequences have probability zero under every answerer, so nothing depends on the choice.
* 0.5: the weights may sum to less than 1 and the posterior is normalised; the proofs use only ξ(∅) = Σ_ν w(ν) ≤ 1, in the right direction (Lemma A.1, Theorem 4.2).

### Lemma 1.1 (relations between H², TV, KL; events): MINOR

All six items were recomputed and hold; random test on 100000 pairs, script `sec3`, part (B16): largest violation 1.8·10⁻¹⁵, which is rounding.

* Item 1: 2·TV = Σ|√p − √q|(√p + √q) ≤ √(2H²)·√(4 − 2H²), so TV ≤ √(H²(2 − H²)). Correct.
* Item 2: correct; equality −ln BC = ½·KL holds when P is a point mass, so the factor ½ cannot be improved.
* Item 3: Pinsker's inequality, standard. The citation "Tsybakov, Lemma 2.5" agrees with my memory of the book (Lemma 2.5, "Pinsker's inequalities"); I did not open the book.
* Item 5: (√Q(A) − √P(A))² ≤ 2H² and Q(A) ≤ (1+η)P(A) + (1+1/η)·2H². Correct. For P(A) = 0 the same line gives the slightly better Q(A) ≤ H²(2 − H²).
* Item 6: the second derivative of √(2t − t²) is −(2t − t²)^(−3/2). Correct (symbolic check).

**The fix (item 4).** The lemma is stated for "a countable set (or laws of runs as in 0.4)". The proof of data processing ("the Cauchy–Schwarz inequality in each fibre") is a proof for countable sets. For laws of runs Ω₀ may be uncountable, and the lemma is used there three times: with the indicator of an event of runs (item 5, hence Corollary 2.3 and Theorem 3.1(c)), with the projection on the first i coordinates (Proposition 2.5), and with τ ↦ (ω₀, y_j) (Proposition 4.7(b)). Add one sentence: "For laws on a general measurable space the three statements are the data-processing inequality for f-divergences, which is standard; the same proof works with the conditional expectation given φ under the dominating measure ½(P+Q)."

### Section 2.1 (what the literature states): CORRECT

I read the four TeX sources in this session. Every statement of Section 2.1 about them is accurate.

1. **Dylan J. Foster, Sham M. Kakade, Jian Qian, Alexander Rakhlin, "The Statistical Complexity of Interactive Decision Making", arXiv:2112.13487** (archive dated 12 July 2023, file `paper-stripped.tex`). Lemma "Subadditivity for squared Hellinger distance", label `lem:hellinger_chain_rule`: D²_H(P,Q) ≤ 10²·log(n)·E_P[Σ_i D²_H(P^(i)(·|X_1:i−1), Q^(i)(·|X_1:i−1))], and with 3·log(V) when sup_A P^(i)(A|x)/Q^(i)(A|x) ≤ V for a constant V ≥ e. The convention is D²_H = ∫(√dP − √dQ)² (line 2148 of the source). Lemma `lem:mp_min` is as quoted, with the constants 3 and 4R. The digit 7 occurs in this paper only in an unrelated lower-bound proof ("≤ 7δ"). Lemma `lem:hellinger_pair` is E_{X∼P_X}[D²_H(P_{Y|X}, Q_{Y|X})] ≤ 4·D²_H(P_{X,Y}, Q_{X,Y}), as the parenthesis in the proof of Proposition 2.5 says.
2. **Dylan J. Foster, Yanjun Han, Jian Qian, Alexander Rakhlin, "Online Estimation via Offline Estimation: An Information-Theoretic Framework", arXiv:2404.10122** (archive dated 17 April 2024, file `appendix_technical.tex`). The lemma "Subadditivity for squared Hellinger distance" has the same hypotheses and the constant 7. The text before it says that it is "an improvement to Lemma A.13 of" the paper of item 1 "that removes a logarithmic factor". The proof uses the cut-and-paste property and "Theorem 7 of" Jayram (2009), and ends with "∏_{i=1}^n (1 − 1/2^i) > 2/7". The file's figure 2/∏_{i≥1}(1 − 2^(−i)) = 6.93 is right (6.9255). One addition: this paper defines D²_H = ½∫(√dP − √dQ)² (`section_examples.tex`, line 72), which is exactly the H² of the outline, so its 7 is the constant in our convention without any conversion.
3. **Fan Chen, Dylan J. Foster, Yanjun Han, Jian Qian, Alexander Rakhlin, Yunbei Xu, "Assouad, Fano, and Le Cam with Interaction: A Unifying Lower Bound Framework and Characterization for Bandit Learnability", arXiv:2410.05117** (archive dated 10 December 2024, file `tools.tex`): the lemma with the constant 7, attributed to Jayram (2009) with "see also" Lemma 11.5.3 of Duchi's notes and Lemma D.2 of the paper of item 2; squared Hellinger distance is the f-divergence with f(x) = ½(√x − 1)² (`prelim.tex`). Its Lemma `lemma:Hellinger-cond` is E_{X∼P_X}[D_H²(P_{Y|X}, Q_{Y|X})] ≤ 2·D_H²(P_{X,Y}, Q_{X,Y}), as the proof of Proposition 2.5 says.
4. **Dylan J. Foster, Adam Block, Dipendra Misra, "Is Behavior Cloning All You Need? Understanding Horizon in Imitation Learning", arXiv:2407.15007** (archive dated 3 December 2024): no subadditivity lemma of its own; "Lemma D.2 of Foster et al. (2024)" with the constant 7 is used four times (`appendix_main.tex`, `section_additional_lower.tex`). Convention D²_H = ∫(√dP − √dQ)². The change-of-measure lemma (`lem:hellinger_com`) and the proposition D²_H(P^π̂, P^π*) ≤ 2·log(|Π|δ⁻¹)/n (`prop:mle_finite`) are as quoted.

My own web search (three queries, not exhaustive) found no statement of the lemma with a constant below 7 and no statement of the best constant. Later papers that the search engine reports as restating the lemma (arXiv:2508.02637 with "an absolute constant c ≤ 7", arXiv:2501.14928, arXiv:2406.01378) were not opened by me. Jayram's paper and Duchi's notes were not read by me either.

So the candidate theory's sentence "7 in the convention of Foster, Kakade, Qian and Rakhlin" is wrong in the way the file says: wrong paper. The inequality is homogeneous of degree one, so the constant is the same in both conventions; this remark of the file is correct.

### Lemma 2.2 (one step, potential U(x) = ½(2 − x)₊², constant 4): CORRECT

(i) U(x) − (3/2 − x) = ½(x − 1)² on [0, 2], and U = 0 > 3/2 − x for x > 2. (ii) Case Λ ≤ 2: E U(Λr) ≤ 2 − 2Λ·E r + ½Λ²·E r² ≤ ½(2 − Λ)² + 2Λ(1 − E r), and 2Λ ≤ 4. Case Λ > 2: (2 − Λr)₊ ≤ 2(1 − r)₊, so E U(Λr) ≤ 2·E(1 − r)² ≤ 4(1 − E r). Both recomputed by hand and symbolically.

Numerical check on the extreme points (script `potentials`, part (N2)). For fixed Λ the map law(r) ↦ E U(Λr) − U(Λ) − 4(1 − E r) is linear and the constraint E r² ≤ 1 is one linear constraint, so it is enough to test point masses at r ≤ 1 and two-point laws with second moment exactly 1. On a grid of 1002 values of Λ, with about 62000 two-point laws and 2001 point masses for each, the largest value is 0.0. The largest ratio [E U(Λr) − U(Λ)]/(1 − E r) found is 4.0000 (as Λ ↑ 2): the constant 4 is the best that this potential gives, so an improvement needs another potential, which is what Theorem 2.7 supplies.

Edge cases: Λ = 0 is covered by the first case (U(0) = 2 on both sides); r with E r² < 1 (mass of q outside the support of p) is covered because only E r² ≤ 1 is used.

### Theorem 2.1 (identity (a), two-sided bound (b), one-sided bound with 4 (c)): CORRECT

* (F1) E_P[r_i | 𝓕_(i−1)] = Σ_{p_i>0} √(p_i q_i) = 1 − h_i. (F2) E_P[r_i² | 𝓕_(i−1)] = q_i({p_i > 0}) ≤ 1. (F3) E_P Λ_n = BC(P,Q). All correct, without any absolute continuity.
* (a) 1 − Λ_n = Σ_i Λ_(i−1)(1 − r_i); each term is integrable because E Λ_i ≤ 1. Correct.
* (b) Λ ≤ ½(1 + Λ²) and (F3) with g = h_i. Correct.
* (c) E_P U(Λ_n) ≤ U(1) + 4·E_P Σ h_i = ½ + 4·E_P Σ h_i and E_P U(Λ_n) ≥ 3/2 − BC = ½ + H². Correct.

Numerical check (script `potentials`, part (N7)): 3000 random trees of depth at most 4, with singular parts; |H² − E_P Σ Λh| ≤ 4.4·10⁻¹⁶, H² − ½(E_P + E_Q) ≤ 2.2·10⁻¹⁶. Hypotheses: countable 𝒳_i is used only to write sums. Edge case n = 1: (a) reads H² = E h_1.

### Corollary 2.3 (L4): CORRECT

The padding of 0.3 turns a scaffold into the setting of Theorem 2.1; after the stop both kernels are the point mass at ∅ and h = 0; whether the run has stopped is the same function of the past for both answerers. Constants: 4; 8 = 2·4 from TV ≤ √(2H²); 16 = 4·4 from Lemma 1.1(5). Runs with no calls contribute nothing. For horizon 1 the bound holds with the constant 1 (Proposition 2.4).

### Proposition 2.4 (inputs that do not depend on the answers; constant 1): CORRECT

Given X_0 both laws are products, BC = Π(1 − h_i), and 1 − Π(1 − h_i) ≤ Σ h_i. For a scaffold, "next_j depends on ω₀ only" includes the decision to stop.

### Proposition 2.5 (converse with the factor 2n): CORRECT

BC(P_i, Q_i) ≤ 1 − ½E_P h_i − ½E_Q h_i by √(ab) ≤ ½(a + b), then data processing. In the example, H² = 1 − √(1−ε) and E_{Q_S} Σ h = 1 − √(1−ε) + ε(n−1); the ratio is at least n − 1, as stated, and tends to 2n − 1 as ε → 0, so the constant 2n of the proposition is nearly attained. The two literature statements in the parenthesis were verified in source (entry on Section 2.1).

### Example 2.6 (two calls, ratio (2+√2)/2): CORRECT

Recomputed: H² = ½(1+s²)ε + O(ε²), E_{Q_S} Σ h = ½(s² − 2s + 3)ε + O(ε²); the only critical point of (s²+1)/(s²−2s+3) on s > 0 is s = 1+√2, with value (2+√2)/2 = 1.707107 (symbolic check). The value is a supremum that is not attained, which is enough for "no constant below 1.707".

### Theorem 2.7 (the constant c*): MINOR (the proof is correct and complete; two small additions)

**Check of the proof.**

* g′ = (g − 1)(1/q + q/2) + q/2: verified from the explicit g with erf (symbolic).
* (iii): ds/dq = −(s/(2q))(2(1−s) + q²); dp/dq = (q²s − 2(1−s)²)/q²; d(p/s)/dq = 1/s; dr/dq = −(1−s)(q² + 2(1−s))/(2q²); (dr/dq)/(ds/dq) = p/(2s). All five verified by hand and symbolically, with g treated as an unknown solution of the differential equation.
* (iv): ∂φ/∂s′ = s(p(s)/s − p(s′)/s′), φ(s,s) = 0, and p/s decreases in s. (v): ∂ψ/∂s′ = p(s) − s/√(s′ − ½) ≥ p(s) − √2·s ≥ 0. Correct. On a grid of 3001 × 3001 and 3001 × 4001 points the minima are −2.2·10⁻¹⁶ (script `potentials`, part (N5)).
* Step 1: V is continuous at 1 and at c (r(s₀) = 0, c·r(1)² = c/2). Correct.
* Step 2: the three closed forms of the parabola, ((c−Λ)/(2Λ²))(a−Λ)², (c/(4s²))(p·a/c − s·q)² and a(1 − c/Λ) + c·a²/(2Λ²), follow from the definition with the stated multipliers μ = (c−Λ)/2, c·p²/4, c/2 (symbolic check), they agree at Λ = 1 and Λ = c (symbolic check), and μ ≥ 0 in all three ranges. The nine cases (three ranges of Λ, three ranges of a) were each recomputed; the two monotonicity arguments in Λ (for Λ ≤ 1 and for Λ ≥ c) are correct. On a grid of 2299 values of Λ and 7801 values of a, with the parabola computed from its definition, min(parabola − V) = −1.1·10⁻¹⁶ (part (N3)).
* Step 3: E U(Λr̃) ≤ U(Λ) + c(1 − E r̃) + μ(E r̃² − 1), and U(x) ≥ U(1) + 1 − x because V ≥ 0 = V(1). Correct. On the extreme laws (300 values of Λ, with about 32000 two-point laws and 1001 point masses for each) the largest value of E U(Λr̃) − U(Λ) − c*(1 − E r̃) is 0.0, and the largest ratio found is 2.964146 against c* = 2.964147 (part (N4)): the one-step inequality is tight. A continuous search for a violation (500 Nelder–Mead runs from random starts for each of the two potentials, part (N4b)) found none: the largest values are 1.1·10⁻¹⁵ for Lemma 2.2 and 2.6·10⁻¹⁵ for Theorem 2.7, which is rounding.

**Addition 1 (uniqueness of the root; one line).** The theorem defines q₀ as the smallest positive root, and the proof uses only that. But the numerical value q₀ = 1.151204 rests on the claim that there is no smaller root; the file supports it by a grid ("a single sign change", Section 7.2). It follows from (iii): dr/dq = −(1−s)(q² + 2(1−s))/(2q²) < 0 for all q > 0, so r is strictly decreasing on (0, ∞); r(0+) = 1/√2 > 0 and r(q) < 1/q − q/2 ≤ 0 for q ≥ √2. So r has exactly one zero, and on (0, √2) the zeros of r are the roots of g = k. Hence g = k has exactly one root in (0, √2). Add this line after (ii).

**Addition 2 (the value, rigorously).** With interval arithmetic (erf by its alternating series, the tail bounded by the first omitted term; part (N1)): g − k ∈ [2.0135·10⁻⁸, 2.0136·10⁻⁸] at q = 1.15120357 and g − k ∈ [−4.6888·10⁻⁸, −4.6887·10⁻⁸] at q = 1.15120358. With uniqueness: 1.15120357 < q₀ < 1.15120358 and 2.96414712 < c* < 2.96414723. To 30 digits, q₀ = 1.15120357300424285968266629425 and c* = 2.96414715730767803218167583868. The file's values (q₀ = 1.151204, c* = 2.964147, g − k = +0.00136 and −0.00536 at 1.151 and 1.152, k(1.152) = 2.9723) are confirmed. So the last sentence of 8.1, item 1 ("the value of c* itself rests on a double-precision evaluation") can be replaced by the enclosure.

**The fix.** Wherever c* serves as an upper bound it must be rounded up: "c* < 2.9642", not "c* = 2.9641" (see Example 2.8). Remark 3.3(iii) already rounds correctly (1.49, 1.73, 2.97; recomputed: c*/2 = 1.4821, √c* = 1.7217).

**Presentation.** The proof reuses letters that are fixed elsewhere: τ_Λ for the parabola (τ is a run in the outline), r for the function r(q) and for the root likelihood ratios r_i (and r̃ in Step 3), s, p, q, k, μ. Rename for the published proof.

### Example 2.8 (ratios 2.0997 and 2.9639): MINOR

(i) The closed forms are correct: Λ² is a martingale under S, π = (β²−1)/(β^(2m+2) − 1), H² = 1 − (1−π)/β, and Wald's identity gives E_{Q_S} Σ h = ((β−1)/(β+1))((1−π) − mπ) + π. The limit 2(b²+1)/(b² + 3 − 2 ln b) is verified symbolically; its maximum is 2.099690 at b = 4.5893.

(ii) The pair is a legitimate pair of samplers: π_k d_k² + (1−π_k)β² = 1 (symbolic check). The computation was repeated in 30-digit arithmetic, in two ways: by the formula of Theorem 2.1(a), and directly as 1 − Σ over runs of √(Q_S Q_S′), with the total S′-mass of the listed runs checked to be 1 (script `potentials`, part (N6)):

| β | levels | ratio (both ways) | c* − ratio |
|---|---|---|---|
| 1.1 | 145 | 2.82406784 | 0.1401 |
| 1.01 | 1389 | 2.94927077 | 0.01488 |
| 1.001 | 13823 | 2.96264616 | 0.001501 |
| 1.0001 | 138163 | 2.96399241 | 0.0001548 |

The four figures of the file (2.82407, 2.94927, 2.96265, 2.96399) are confirmed; the lower bound c₀* ≥ 2.96399 no longer rests on double precision. The gap behaves like 1.5·(β − 1). In double precision the same construction gives 2.964127 for β = 1.00001 (1.38 million levels) and 2.964141 for β = 1.000001. A local search over all drop factors for β = 1.1 gives 2.8276, a little above the file's 2.8241 and below c*, as it must be (part (N7)).

**The fixes.**

1. "2.9639 ≤ c₀* ≤ 2.9641" (summary table, Section 2.4 twice, 8.1 item 1) rounds the upper bound down: c* = 2.964147 > 2.9641. What is proved is 2.9639 ≤ c₀* ≤ 2.9642 (more precisely 2.96399 ≤ c₀* ≤ 2.96415).
2. "c* is the best constant up to the fourth digit" (In brief (1); 8.2 item 1): 2.9639 and 2.9642 differ in the fourth significant digit. Say "the best constant lies between 2.9639 and 2.9642". With the example at β = 1.00001 the statement "c₀* = 2.9641 to four decimal places" becomes true, on a double-precision evaluation.

That c₀* = c* exactly is not proved; the file marks it as open, correctly. The computation above supports it.

### Remark 2.9 (the route of the candidate theory): CORRECT for the displayed inequality; the figure 12.6 is not checkable

E_Q g ≤ ((1+η)/(1−η))·E_P g + R·H²/(η(1−η)) is correct (Cauchy–Schwarz, then 2√(ab) ≤ ηa + b/η); at η = ¼ the constants are 5/3 and 16/3. The arithmetic 1/(1−√(2θ)) + 1/θ + √(2/(θ(1−√(2θ)))) = 3.414 + 4 + 5.226 = 12.64 at θ = ¼ is right, but the proof that would give this constant is not written out, so the sentence cannot be checked. The file says that it is not used; it must not be cited in the note as a result.

### Protocol R, Theorem R1, Lemma A.1 (Section 3.1 and Appendix A): CORRECT

* Lemma A.1: ξ(D_t)/ξ(D_(t−1)) = M_(t−1)(y_t|x_t); the product telescopes to ξ(D_n)/ξ(∅) ≥ w(ν*)·Π ν*(y_t|x_t) because ξ(∅) ≤ 1. The negative parts are integrable: max(u, 0) ≤ e^(u−1) and E[M/P] ≤ 1. Correct.
* R1: the asked input is a function of the earlier pairs and of the protocol's randomness U; the conditional mean of 1{J_t ≤ len(τ_t)}·KL(P‖M^(t))(x_(t,J_t)) given D_(t−1) and τ_t is (1/L)·Σ_{j ≤ len(τ_t)} KL(P‖M^(t))(x_(t,j)). Correct. Only the first half of A3 (independence of the protocol's coins from the human's coins) is used, as 8.2 item 8 says.
* Exact check (script `sec3`, part (B15)): Protocol R on three scaffolds with L = 2 (adaptive; adaptive with a stop after the first answer; inputs fixed), 15 random classes (stochastic samplers; hypotheses that exclude answers; functions; a human who never gives one answer), n = 3 and n = 7, all expectations exact by a dynamic programme over the data sets. In all 30 rows Σ_t E[E_{Q_{M^(t)}} Σ_j KL(P‖M^(t))(x_j)] ≤ L·K ln2; for example 4.0554 ≤ 5.4590 and 3.3171 ≤ 4.2494.

One point for the statement in the note. In Protocol R the number n counts rounds. A round whose run has fewer than J_t calls asks nothing, so the human answers at most n questions, and fewer when runs are short. The outline calls n "the number of questions put to the human"; the note should say "at most n questions (n rounds)". (If J_t is drawn uniformly from the calls that the run of round t actually made, every round with at least one call asks a question and the same proof gives the same bound, because (1/len)·Σ_j ≥ (1/L)·Σ_j.)

### Theorem 3.1 (R2): CORRECT

* (a) H²(Q_{M^(t)}, Q_P) ≤ 4·E_{Q_{M^(t)}} Σ_j H²(M^(t), P)(x_j) ≤ 2·E_{Q_{M^(t)}} Σ_j KL(P‖M^(t))(x_j); average over t and R1: 2LK ln2/n. Correct.
* (b) Lemma 1.1(6) with b = min(1, 2LK ln2/n); √(b(2−b)) ≤ √(2b) ≤ 2·√(LK ln2/n). Correct.
* (c) (1+η)·Q_P(G) + (1+1/η)·2·E H²; η = 1 gives 2Q_P(G) + 8LK ln2/n; Q_P(G) = 0 gives 4LK ln2/n. Correct. The event G must be fixed before the data are seen; the statement says "for every event G of runs", which is this.
* (d) The factor 4 becomes 1 by Proposition 2.4; E H² ≤ ½·LK ln2/n and E TV ≤ √(LK ln2/n). Correct, and it can be sharpened (Part IV, improvement A).
* (e) −ln M(f(x)|x) ≥ 1 − M(f(x)|x) and the union bound over the calls of the run of M^(t). Correct.

Hypotheses: A1 and A3 enter through R1; A2 gives K; all are used. Exact check: the 30 rows of part (B15) satisfy (a), (b), (c) for the event "runs of Q_P-probability zero", (d) on the scaffold with fixed inputs, and (e) for classes of functions; the chain H² ≤ 4·E Σ h holds for every reachable data set.

Edge cases. Horizon 1: (d) applies, because the first input depends on ω₀ only. One round (n = 1): M^(1) is the normalised prior mixture and the bound is 2LK ln2, which is empty unless K is small. Runs with no calls: such a round asks nothing and such a run contributes nothing to any sum. A human who never gives some answer (events of probability zero under Q_P): KL(P‖M^(t))(x) ≤ ln(1/w_{D_(t−1)}(P)) < ∞ still holds, and (c) is the statement for such events. Semimeasures: a hypothesis completed by ⊥ is a sampler, and the mixture is a sampler; nothing else is needed.

### Remark 3.2: CORRECT

(i) convexity of H² in one argument; (ii) Markov's inequality, 2LK ln2/(nδ) and 2·√(LK ln2/(nδ)); (iii) BC is multiplicative over independent runs, 1 − (1−h)^m ≤ mh.

### Remark 3.3: CORRECT

(i) The hybrid bound with Pinsker and Cauchy–Schwarz gives L·√(K ln2/(2n)); its ratio to 2·√(LK ln2/n) is √L/(2√2). Recomputed. (ii) With ν* in place of P, E H² ≤ 2L·[ln(1/w(ν*))/n + sup_x KL(P‖ν*)(x)]; correct, and empty when the supremum is infinite. (iii) c*/2 = 1.4821 ≤ 1.49, √c* = 1.7217 ≤ 1.73, c* = 2.9641 ≤ 2.97; correctly rounded up.

### Lemma 3.4a (two coins of opposite bias): CORRECT

(d/dp) Pr_p[S ≥ k] = N·C(N−1, k−1)·p^(k−1)(1−p)^(N−k); C(2j, j) ≥ 4^j/(2√j) (induction step 2j+1 ≥ 2·√(j(j+1))); (1−4δ²)^j ≥ 1 − 4jδ² ≥ ½; N/√j ≥ √(2N). Recomputed. Exact check (part (B1)): over odd N from 3 to 20001 and δ up to the boundary (N−1)δ² = ¼, the smallest value of G(N, δ)/(δ·√(N/2)) is 1.931 (must be at least 1). At N = 3, δ = 1/(2√2): G = 0.884 against 0.433.

### Proposition 3.4 (K coins): CORRECT

Recomputed constants:

* κ = 2δ·ln((1+2δ)/(1−2δ)) ≤ 8δ²/(1−4δ²), by ln((1+x)/(1−x)) ≤ 2x/(1−x²) (the difference has the series −(4/3)x³ − (8/5)x⁵ − …). On a grid of (0, ½) the largest value of κ − 8δ²/(1−4δ²) is 5·10⁻²³.
* Step 2: under n ≤ K(1−4δ²)/(16δ²), κn/(2K) ≤ ¼, so the average of E_θ[d] is at least (K/2)(1 − ½) = K/4.
* Step 3: (¼ − ⅛)/(1 − ⅛) = 1/7. With r₀ = ⌈K/8⌉ and N = r₀m: L/8 ≤ N ≤ L/4 holds because ⌈K/8⌉ ≤ (K+7)/8 ≤ K/4 for K ≥ 7, and N ≥ 4 because m ≥ 4. G(dm, δ) ≥ δ·√((N−1)/2) ≥ δ·√(3N/8) ≥ δ·√(3L/64). Then (1/7)·½·√(3/64) = 0.015465 = 1/64.66 ≥ 1/65.
* The consequence: with δ = 65ε/√L, Lδ² = 4225ε² ≤ 1 and δ² ≤ 1/32, so K(1−4δ²)/(16δ²) ≥ (7/8)·KL/(16·4225·ε²) = KL/(77257·ε²) ≥ KL/(8·10⁴·ε²).

The definition of "protocol" covers Protocol R (its questions are functions of earlier answers and of independent randomness, and M^(T) is an answerer chosen from the data and independent randomness) and the recording of whole runs. The averaging over θ, the two-point bound and the chain rule for adaptively chosen questions are used correctly.

Remarks. The hypothesis δ ≤ ¼ is implied by Lδ² ≤ 1 and L = Km ≥ 32 (which give δ ≤ 0.177); it can be dropped. The proof gives an average over θ strictly above ε (1/64.66 against 1/65), so "E TV ≤ ε for all members" is indeed impossible with n ≤ LK/(8·10⁴·ε²), as the summary table says.

### Proposition 3.5 (two coins): CORRECT

a = 4ε·√(2/L) ≤ 0.2722; (L−1)a² ≤ 32ε² ≤ 0.2222 ≤ ¼; G(L, a) ≥ a·√(L/2) = 4ε; 4a² = 128ε²/L ≤ 0.2963 ≤ 0.3; TV(ℙ₊, ℙ₋)² ≤ 4na²/(1−4a²) ≤ (128/0.7)·nε²/L = 182.9·nε²/L ≤ 183·nε²/L; 183/740 = 0.2473 ≤ ¼. All recomputed (part (B3)).

The cross-references in the paragraph after the proof exist as described: `understand/imitation-theory.md`, LB3, has (L−1)/(2048·ε²); `research/prove/lower-bounds.md`, Theorem 6.3, has L·K/(8192·ε²) on the scaffold with one random input asked L times.

### Section 3.3 (is √L necessary; the table; four qualifications): GAP (filled)

The main text and the table are correct: 8·10⁴·ln2 = 55452 ("about 5·10⁴") and 8192·ln2 = 5678 ("about 6·10³").

**The gap.** Qualification (3) asserts that for the K coins with δ of order √(K/n) the expected number of unfaithful calls is of order L·√(K/n), and adds "not written out". Here is the missing proof; it uses only Step 2 of the proof of Proposition 3.4.

*Claim.* In the setting of Proposition 3.4, with any integers K ≥ 1 and m ≥ 1 and any δ ∈ (0, ½), let a protocol with at most n questions deploy a sampler Ŝ (for Protocol R, Ŝ = M^(T)), and let u_θ := E_θ[E_{Q_Ŝ} Σ_j TV(Ŝ, P_θ)(x_j)] be the expected number of unfaithful calls of its run in the coupling L2. If n ≤ K(1−4δ²)/(16δ²), then the average of u_θ over θ is at least Lδ/4. In particular, for n ≥ 3K/4 and δ := √(K/(16n + 4K)), some member has u_θ ≥ (L/4)·√(K/(16n+4K)) ≥ (√3/32)·L·√(K/n).

*Proof.* The inputs of a run are fixed and each input occurs m times, so Σ_j TV(Ŝ, P_θ)(x_j) = m·Σ_i TV(Ŝ(·|i), P_θ(·|i)) ≥ m·Σ_i |Ŝ(1|i) − ½ − θ_i δ|. Put θ̂_i := +1 if Ŝ(1|i) ≥ ½ and θ̂_i := −1 otherwise. If θ̂_i ≠ θ_i, then |Ŝ(1|i) − ½ − θ_i δ| ≥ δ. So the sum is at least m·δ·d, with d the number of coordinates where θ̂ and θ differ. Step 2 holds for every θ̂ that is a function of what the protocol sees, and gives an average of E_θ[d] of at least K/4. Hence the average of u_θ is at least mδK/4 = Lδ/4. With δ² = K/(16n+4K) the hypothesis on n holds with equality; δ ≤ ¼ because n ≥ 3K/4; and 16n + 4K ≤ 64n/3, so δ ≥ √(3K/(64n)). ∎

The upper bound of the candidate's R3 is L·√(K ln2/(2n)) = 0.589·L·√(K/n); the lower bound is 0.054·L·√(K/n). They differ by a factor of at most 10.9 (9.42 for n much larger than K; part (B17)). The statement holds for a deployed sampler, that is, for an imitator that answers each call from the input alone.

**Two notes for the editor.** (1) The first row of the table quotes N2 in the candidate's form "L/(2ε)" and says "not checked here"; the note must take the checked form of N2 from the lower-bounds part (the outline's addendum quotes n ≥ L/(4δ) − L). (2) If improvement A of Part IV is adopted, "LK ln2/ε² questions of Protocol R suffice" becomes LK ln2/(2ε²) for scaffolds whose inputs do not depend on the answers, and the ratio between the upper and the lower bound becomes 2.8·10⁴ (2.8·10³ with the constant of the other file).

Qualification (4) is correct: for one run of the scaffold of Proposition 3.4, asking the L calls of one run and replaying the answers gives a run whose law, averaged over the training randomness, is exactly Q_P. The reference to `understand/imitation-theory.md`, §5.8, exists and says what is quoted.

### Lemma 4.1 (the likelihood of a run): CORRECT

The factors that do not involve ν cancel in the posterior, for full runs and for transcripts.

### Theorem 4.2 (Theorem A): CORRECT

* (a) ξ_(t+1) = ξ_t·q̂_t(τ_t), so Σ_t ln(q*(τ_t)/q̂_t(τ_t)) = ln(Π_t q*(τ_t)/ξ_(N+1)) + ln W ≤ ln(1/w(ν*)) + Σ_t ln(q*(τ_t)/q_ν*(τ_t)). Correct; if every member has infinite divergence the bound is empty and the posterior may be undefined, which the proof says.
* (b) Convexity of KL(Q*‖·); Pinsker and Jensen; H² ≤ KL/2; Lemma 1.1(5) gives 2Q*(G) + 4·E H² ≤ 2Q*(G) + 2ρ_N. Correct, for the average law and for t drawn once.
* (c), (d) Correct.

Hypotheses: the runs must be independent with a common law; nothing else. Exact check (script `sec45`, part (B9)): 36 random instances with L = 2, an adaptive scaffold with stops, N = 4, for a human in the class, a sampler outside the class and a human with memory inside the run; Σ_t E KL(Q*‖Q̂_t) ≤ min_ν [ln(1/w(ν)) + N·KL(Q*‖Q_ν)] in all, with smallest slack 0.11.

Notation: ρ_N(ν*) uses the letter that the outline fixes for the scaffold's randomness. Rename it in the final text.

### Remark 4.3: CORRECT

The regret bound controls the sum over t; the random t turns it into an expectation. The parenthesis (for a human drawn from the normalised prior the expected divergence does not increase in t) is the standard monotonicity of I(P; τ_t | τ_<t) for conditionally independent, identically distributed observations. The status given to the last-round question ("not decided here") is right: Example 4.4 shows a bump of 0.043 where the bound K ln2/N at N = 4 is 1.15, so it is not a counterexample to a last-round bound.

### Example 4.4 (not monotone): CORRECT

Recomputed exactly: 0.00321, 0.01058, 0.02451, 0.03794, 0.04298, 0.03988 for t = 0, …, 5; the ratio of the value at t = 4 to the value at t = 0 is 13.4.

### Lemma 4.5 (chain rule and hybrid bound): CORRECT

(i) is the chain rule for KL with the padding of 0.3; (ii) is the hybrid argument, in which consecutive hybrids differ in one kernel and share the law of the past under Q_A.

### Example 4.6 (Theorem A fails for the per-call mixture): GAP, filled (the counterexample is right; one step is missing)

**Check.** Posterior: w(f) = B/(2B−v) and ω = 1/(2B−v) for each surviving g_b (verified by brute force). One draw per run: TV = (B−v)ω/B ≤ 1/(2B), KL = ((B−v)/B)·ln(1/(1−ω)). Per-call mixture: TV = ((B−v)/B)(1 − (1−ω)^L), KL = L·((B−v)/B)·ln(1/(1−ω)). The four formulas agree with a brute-force computation of the run laws to 2·10⁻¹⁶ (part (B5); B ≤ 6, L ≤ 4). With B = 2N: KL ≥ L/(8N) and TV ≥ ½(1 − e^(−L/(4N))). Thresholds recomputed: L/(8N) > ln2/N if and only if L > 5.545, so L ≥ 6; L/(16N) > √(ln2/(2N)) if and only if L > 9.42·√N, so 9.5 suffices; ½(1 − e⁻¹) = 0.316 > 0.589/√N if and only if N > 3.47, so N ≥ 4. The numerical example (0.087, 0.0019, 0.059) is reproduced.

**The missing line.** The file bounds KL(Q_f‖Q_{M_t}) and TV(Q_{M_t}, Q_f) from below for every single t ≤ N. That refutes the per-call analogue of Theorem 4.2(b) in its form "t drawn once and uniformly, expectation over t as well". Theorem A itself is about the law of an imitation run given the data, which is the average (1/N)·Σ_t Q_{M_t}; a lower bound on each KL(Q_f‖Q_{M_t}) does not by itself bound the divergence from the average, because KL(Q_f‖·) is convex, not concave. Add: "Given z, Q_f is the point mass on the run 'all zeros'. So TV(Q, Q_f) = E_z[1 − Q(zeros | z)] is linear in Q, and the lower bound on the total variation passes to the average. And KL(Q_f‖Q) = E_z[ln(1/Q(zeros | z))]; for each of the at least B − N + 1 > B/2 values of z that are unvisited in all rounds t ≤ N, every Q_{M_t}(zeros | z) = (1−ω_t)^L ≤ (1 − 1/(2B))^L, hence the same holds for their average, and KL(Q_f‖(1/N)·Σ_t Q_{M_t}) ≥ ½·L·ln(1/(1 − 1/(2B))) ≥ L/(4B) = L/(8N)." The same computation covers the variant in which every call draws its own t: that imitator answers 1 at every input (z, j) with probability (1/N)·Σ_t ω_t ≥ 1/(2B) when z is unvisited in all rounds.

Exact check of the averaged law (part (B5), expectation over the recorded runs): N = 2, L = 6: E KL = 0.7265 against ln2/N = 0.3466; N = 5, L = 30: E KL = 1.2934 against 0.1386 and E TV = 0.6662 against √(ln2/(2N)) = 0.2633; in all nine cases tried E KL ≥ L/(8N).

### Proposition 4.7 (what holds for the per-call mixture): CORRECT

(a) 1 − M_t(f(x_j)|x_j) ≤ m_t(τ) for each call, and Π_t (1 − m_t(τ_t)) = ξ_(N+1)/W ≥ w(f). Correct. Exact check: 40 random adaptive scaffolds with L = 3, stops, classes of functions, N = 4; both inequalities hold, smallest slack 0.66 (part (B6)).

(b) Under Q̂_t the pair (ω₀, y_j) has the law μ₀(dω₀)·M_t(y_j|x_j) when x_j depends on ω₀ only; data processing. Correct. 400 random cases: KL(Q_P‖Q_M) − L·KL(Q_P‖Q̂) ≤ −2·10⁻¹³ (part (B7)). The hypothesis on the inputs is needed: on the adaptive scaffold of Example 4.8 with p = 0.01 and ω = 0.9, KL(Q_P‖Q_M) = 0.0371 > L·KL(Q_P‖Q̂) = 0.0281.

(c) 1 − e^(−x) ≥ x/4 on [0, 2] and Lω ≤ 2L/(3B) ≤ 4/3. Correct.

### Example 4.8 (adaptive scaffold, stochastic human): MINOR

**First half (two hypotheses): correct.** ω_t = o/(o + u_t); the first call contributes exactly KL(Q_P‖Q̂_t) = KL(Bern(p)‖Bern(p(1−ω_t))); the second contributes p·ln(1 + o/u_t); p·u_t = (1−p)(u_(t−1) − u_t); ∫₀¹ ln(1 + o/u) du = (1+o)·ln(1+o) + o·ln(1/o) (symbolic check). Exact sums (part (B8)): for p = 0.01 and η = 10⁻¹, 10⁻², 10⁻⁴, 10⁻⁸ the ratio of the summed divergences to L·K ln2 is 2.208, 3.303, 5.582, 10.164, as the file says, and in each case the excess over the draw per run is at least (1−p) times the integral.

**Fix 1 (second half).** The numbers 1.82, 2.50, 3.21, 3.92 "for B = 4, 16, 64, 256" are called "exact expectations". They are not exact: the prover's script integrates over t by the trapezoid rule on a logarithmic grid. Summed over every t up to the prover's cut-off (script `ex48many`; two independent methods agree to four decimals for B ≤ 64, and for B = 256 a separate run of the first method, not saved, gave the same value as the second), the excess is 1.786, 2.494, 3.210 and 3.916 for B = 4, 16, 64, 256; the terms after the cut-off add 0.001 for B = 4 and nothing visible for the others. At the precision quoted in the file, 1.82 should read 1.79 and 2.50 should read 2.49; 3.21 and 3.92 stand. The growth by about ½·ln 4 = 0.69 for each factor 4 in B is confirmed (0.708, 0.716, 0.706). Also, the construction of this second example is given only in the script (`hellinger-runs_thmA.py`, function `example_48_many`), not in the text. State the construction in the text and replace the numbers and the word "exact", or drop the sentence; the file already says "not proved".

**Fix 2 (the sentence after the example).** "In this example the total variation of the two imitators is the same to first order" is not right. While ν is alive, TV(Q̂_t, Q_P) = p·ω_t and TV(Q_{M_t}, Q_P) = p·ω_t·(2 − ω_t) (part (B8c)). The per-call mixture is worse by the factor 2 − ω_t, which is close to 2 when ω_t is small. Write "of the same order (they differ by the factor 2 − ω_t)".

### Remark 4.9: CORRECT

The first statement is linearity in ν of E_{Q_f}[Σ_j (1 − ν(f(x_j)|x_j))]; the count is along the run of the human system. The comparison "better by a factor up to L when every call is critical" is what Example 4.6 shows. That the per-call mixture is the right object under low stakes is a reading; it is not proved in this file and belongs to the part on R5.

### Lemma 5.0: CORRECT

Hölder's inequality with the exponents 1/(2−2s) and 1/(2s−1), which are conjugate; s = ½ is the trivial case. 100000 random pairs and exponents: A_s − BC^(2·min(s,1−s)) ≤ 1.1·10⁻¹⁶ (part (B10)).

### Theorem 5.1 (Theorem B): CORRECT

min(1, a) ≤ a^s; E[(L_ν/L_P)^s] = A_s(ν)^N; Σ_ν 2^(−λsℓ(ν)) ≤ 1 because λs ≥ 1. Parts (a) and (b) correct. (c) recomputed: s = ½ for λ ≥ 2 and s = 1/λ for 1 < λ ≤ 2 are the best admissible choices; the two sample sizes are as stated; c(λ) = max(λ/2, λ/(2(λ−1))) has its minimum 1 at λ = 2.

Hypotheses: A1 and A2 (the runs have the law Q_P and P is in the class); λ > 1 is used only to have Σ_ν π_λ(ν)^s ≤ 1 for some s < 1. Ties: (b) is about every ν with π_λ(ν)·L_ν ≥ π_λ(P)·L_P, so every maximiser is covered; a maximiser exists because L_ν ≤ 1 and only finitely many ν have π_λ(ν) ≥ π_λ(P)·L_P. ε = 1 is allowed (then B_ε is the set of mutually singular hypotheses and β = 0).

Exact check (part (B11)): a class of six Bernoulli samplers with code lengths 3, 1, 2, 4, 5, 6, the human with ℓ = 3; λ ∈ {1.05, 1.5, 2, 3}, ε² ∈ {0.004, 0.02}, N ∈ {20, 100, 400}; the expected posterior mass and the probability of (b), computed exactly, are below β for every admissible s in all 24 cases. The arithmetic of (c) was checked on three examples (β ≤ δ at the stated N).

### Corollary 5.2: CORRECT

Items 1 to 5 follow from Lemma 1.1(1), (5), the multiplicativity of BC and Proposition 2.5 (2L·ε²). One remark on the paragraph after the corollary: "the price is the same up to a factor 2" compares a bound that holds with probability 1 − δ (with the term ln(1/δ)) with a bound in expectation; say so.

### Remark 5.3: CORRECT

For M samplers with uniform weights, S_½·w(P)^(−1/2) = M, so the mass is at most M·e^(−Nε²). In the convention D²_H = 2H² this is the proposition of Foster, Block and Misra, D²_H ≤ 2·log(|Π|δ⁻¹)/n (verified in source, entry on Section 2.1).

### Example 5.4 (tables against a fair coin, λ = 1): CORRECT

Kraft sum ½ + 2^(2^d)·2^(−2^d−1) = 1; H² = 1 − 1/√2 = 0.2929; posterior mass of the tables 1/(1 + 2^(−R)) when the answers are consistent, which has probability 2^(−R); at λ = 2 the odds are 2^(R−2^d). Brute force over the 16 tables for d = 2, N = 3: both formulas hold exactly (part (B12)). Exact values by a recursion on the number of repeats: 0.4999 (d = 30, N = 1024), 0.4794 (d = 30, N = 16384), 0.4795 (d = 20, N = 512), as the file says; the lower bound ½(1 − N²/2^(d+1)) ≥ ¼ for N ≤ 2^(d/2) holds.

### Theorem 5.5 (Theorem B′, tempered likelihood): CORRECT

Z ≤ Φ because A_α ≤ 1; Jensen's inequality for ln with the weights Π^(α); E ln Φ ≤ ln E Φ ≤ 0; −ln Z ≤ ln(1/w(ν*)) + α·ln(L*/L_ν*). Then −ln A_α ≥ 2·min(α, 1−α)·H². Correct, also outside the class. Exact check on the 36 instances of part (B9) with α ∈ {0.3, 0.5, 0.8}: both inequalities hold (part (B13)). The three literature items are quoted by the prover from memory; the bibliographic data agree with my memory (Zhang, Annals of Statistics 34(5), 2006; Bhattacharya, Pati and Yang, Annals of Statistics 47(1), 2019; Barron and Cover, IEEE Transactions on Information Theory 37(4), 1991); I did not open them. The proofs do not rely on them.

### Proposition 5.6 (weights w^λ, human outside the class): CORRECT

E[max(Y, 0)] ≤ N·KL* + 1/e; Markov's inequality gives c₁; S·π_λ(ν*)^(−1/2)·exp(c₁/2 − Nε₀²) = δ₂ gives exactly the stated ε₀² (recomputed). If ε₀² > 1 the statement is empty. Exact check on a Bernoulli class with the truth outside (part (B14b)): 70 non-trivial cases, the bound holds in all, with a large margin.

### Section 6 (table and four points): CORRECT

Each row of the table agrees with the theorem it summarises.

### Section 7 (numerical checks): MINOR

All quoted lines are in the saved outputs, and the saved outputs are reproduced (Part I). Fix: in 7.4 and in the output of the script the many-alternatives sums are labelled "exact expectation"; they are trapezoid sums (entry on Example 4.8).

### Section 8 (open questions and remarks): MINOR (the wording fixes above)

8.1 item 1 and 8.2 item 1: the bounds must read 2.9639 ≤ c₀* ≤ 2.9642, and the caveat about double precision can be replaced by the enclosure of c*. 8.2 item 3: n ≥ K ln2/(2θ²δ²) recomputed. 8.2 item 7: KL(P₁⊗P₂‖R) = ln(1/ε) and the sum of the marginal divergences is larger; correct. 8.2 item 9: the factor 2√2 is right for the bounds as stated; with improvement A the two bounds coincide on scaffolds whose inputs do not depend on the answers.

### Edge cases, collected

| case | where it matters | finding |
|---|---|---|
| Horizon 1 | Corollary 2.3, Theorem 3.1 | Corollary 2.3 holds with the constant 1 (H² = E h₁ exactly). Theorem 3.1(d) applies, and with improvement A of Part IV the bounds are E KL ≤ K ln2/n and E TV ≤ √(K ln2/(2n)), the same as Theorem 4.2(c) with N = n. |
| One round, or one recorded run | Theorems 3.1, 4.2, 5.1 | The deployed object is the normalised prior mixture (T = 1, or t = 1). The bounds read 2LK ln2, K ln2 and β with N = 1; they are valid and mostly empty. Nothing is undefined. |
| Runs with no calls | 0.3, Protocol R, Lemma 4.1 | Such a run has likelihood 1 under every hypothesis and contributes 0 to every sum; in Protocol R such a round asks nothing. |
| Events of probability zero | Theorem 2.1, Lemma 1.1(5), Theorem 3.1(c), Corollary 5.2 | Theorem 2.1 assumes no absolute continuity: the proof uses E r² ≤ 1, not E r² = 1, and r_i is needed only where p_i > 0. All numerical tests include kernels with singular parts. |
| Infinite divergences | Lemma 1.1(2), Theorem 4.2, Remark 3.3(ii), Theorem 5.5, Proposition 5.6 | H² ≤ ½·KL holds with KL = ∞. Under A2 every divergence in Theorem 3.1 is finite. Outside the class the statements either assume KL(Q*‖Q_ν*) < ∞ or are empty, and the proofs say so. Section 6, point 2, says "after such an answer the posterior is not defined"; exactly, it is undefined once the data have refuted every member, which one such answer need not do. |
| Semimeasures | 0.1 | A hypothesis completed by ⊥ is a sampler and so is the mixture; if the human never answers ⊥ no likelihood changes; the scaffold must say what it does with ⊥ (said in 0.1). Weights with Σ w < 1 enter only through ξ(∅) ≤ 1 and W ≤ 1, in the right direction. |
| Ties | Theorem 5.1(b), Proposition 5.6, Proposition 3.4 | The statements are about every ν with π_λ(ν)·L_ν ≥ π_λ(P)·L_P (or ≥ π_λ(ν*)·L_ν*), so every maximiser is covered, and a maximiser exists. In Proposition 3.4 any measurable choice of the minimiser θ̂ works. |

### Hypotheses, collected

| statement | hypotheses | finding |
|---|---|---|
| Theorem 2.1, Corollary 2.3 | sequential kernels; the same law of X₀ (of ω₀) and the same stopping rule under both laws | all used; none missing |
| Theorem 3.1 | A1, A2, the first half of A3; J_t uniform on {1, …, L}; T uniform and independent | all used. Not used: computability, prefix codes, the second clause of A3. The top-level input and the scaffold's randomness of the deployed run have the same law μ₀ as in rehearsal; this is part of the definition of Q_{M^(T)} and should be said in words in the note ("closed system"). |
| Proposition 3.4 | K ≥ 8, m ≥ 4, Lδ² ≤ 1, δ ≤ ¼ | K ≥ 8 and m ≥ 4 are used in Step 3; δ ≤ ¼ is redundant |
| Proposition 3.5 | L odd, L ≥ 3, ε ≤ 1/12 | all used |
| Theorem 4.2 | independent runs with a common law | (a), (b) need nothing else; A1 enters (c) and (d), A2 enters (c) |
| Proposition 4.7 | (a) a function; (b) inputs that do not depend on the answers | both needed; (b) fails on an adaptive scaffold (entry above) |
| Theorem 5.1 | A1, A2, λ > 1, s ∈ [1/λ, 1) | all used; the statement fails at λ = 1 (Example 5.4) |
| Theorem 5.5, Proposition 5.6 | KL(Q*‖Q_ν*) < ∞; S < ∞ | all used |

## III. Corrections that must be made, in order of importance

None of them changes a theorem. Numbers 1 to 5 change sentences that a reader of the note would take as claims.

1. **An upper bound is rounded down.** "2.9639 ≤ c₀* ≤ 2.9641" and "c₀* ≤ c* = 2.9641" occur in the summary table (row of Example 2.8), in "In brief" (1), at the start and the end of Section 2.4, in 8.1 item 1 and in 8.2 item 1. Since c* = 2.964147…, the proved statement is **2.9639 ≤ c₀* ≤ 2.9642**. Where c* is used as a bound write "c* < 2.9642"; where its value is given write "c* = 2.964147…". Replace "the best constant up to the fourth digit" by "the best constant lies between 2.9639 and 2.9642". The note must state the constant of L4 in this form.
2. **Example 4.6 must argue about the object of Theorem A.** Add the two lines given in the entry: the lower bounds L/(8N) and ½(1 − e^(−L/(4N))) hold for the average law (1/N)·Σ_t Q_{M_t} (the total variation is linear in it because Q_f is a point mass given z; the divergence because every Q_{M_t} gives the run "all zeros" probability at most (1 − 1/(2B))^L on more than half of the values of z).
3. **Section 3.3, qualification (3):** the assertion that the order L·√(K/n) of the expected number of unfaithful calls is attained is marked "not written out". Insert the claim and the proof given in the entry (lower bound (√3/32)·L·√(K/n) for n ≥ 3K/4, for a deployed sampler), or delete the assertion. The same sentence is repeated in 8.2 item 3.
4. **The sentence after Example 4.8** ("the total variation of the two imitators is the same to first order") is wrong by a factor of up to 2: TV(Q_{M_t}, Q_P) = (2 − ω_t)·TV(Q̂_t, Q_P). Write "of the same order".
5. **Example 4.8, second half** ("B alternatives of weight 1/(2B)"): the four numbers are not exact (quadrature in t). Exact sums: 1.786, 2.494, 3.210, 3.916 for B = 4, 16, 64, 256, so 1.82 and 2.50 should read 1.79 and 2.49. State the construction in the text, correct the numbers and the word "exact" (also in Section 7.4 and in the output line of the script), or drop the sentence.
6. **Theorem 2.7:** add the line that the root is unique (r is strictly decreasing by (iii), r(0+) > 0 and r < 0 from √2 on), and quote the enclosure 2.96414712 < c* < 2.96414723 in place of the sentence in 8.1 item 1 that the value rests on double precision.
7. **Lemma 1.1, item 4:** the proof of data processing covers countable sets; add the sentence for laws on a general space (it is used for laws of runs with a general Ω₀).
8. **Protocol R and Theorems R1 and 3.1:** say that n is the number of rounds and that the human answers at most n questions. The outline's "n: number of questions" is then an upper bound.
9. **Notation in the published proofs.** The file reuses letters that the outline fixes: L_ν (likelihood) against L (horizon); Π_λ and Π^(α) (posteriors) against Π (scaffold); ρ_N against ρ (the scaffold's randomness); m (repetitions of an input in Proposition 3.4, number of runs in Remark 3.2 and Corollary 5.2, m_t in Proposition 4.7) against m (validation questions); τ_Λ against τ (a run); β (base in Example 2.8, bound in Theorem 5.1) against β of R3; G (event of runs, the function G(N, δ), an event in the proof of Proposition 5.6); δ (bias, and confidence level). Inside Theorem 2.7: r, s, p, q, k, μ. Rename in `proofs/hellinger-runs.md`.
10. **Section 3.3, table, first row:** take N2 in its checked form from the lower-bounds part, not "L/(2ε)" from the candidate theory.
11. **Remark 2.9:** the constant 12.6 has no written proof; do not carry it into the note.
12. **After Corollary 5.2:** "the same up to a factor 2" compares a bound in probability with a bound in expectation; say so.
13. **Small.** Proposition 3.4: the hypothesis δ ≤ ¼ is implied by the others and can go. Lemma 3.4a defines G(N, δ) inside a sentence about odd N, and Proposition 3.4 uses it for every N; define it for all N ≥ 1. Section 0.3: say that a_j is the point mass at ∅ also on sequences that the scaffold cannot produce. Section 6, point 2: the posterior is undefined once the data have refuted every member, not after one excluded answer.

## IV. Improvements that the check produced (not corrections)

**A. Theorem 3.1(d) can be sharpened.** Suppose next_j is a function of ω₀ only (including the decision to stop). Then for every sampler M, KL(Q_P ‖ Q_M) = E_{Q_M}[Σ_j KL(P‖M)(x_j)]. Proof: by the chain rule (Lemma 4.5(i)), KL(Q_P‖Q_M) = E_{Q_P}[Σ_j KL(P‖M)(x_j)]; the inputs and the length of the run are functions of ω₀, whose law is μ₀ under every answerer; so the expectation under Q_P equals the expectation under Q_M. With R1, under A1, A2, A3 and Protocol R:

 E[KL(Q_P ‖ Q_{M^(T)})] ≤ LK ln2/n, E[TV(Q_{M^(T)}, Q_P)] ≤ √(LK ln2/(2n)), E[H²] ≤ LK ln2/(2n).

The bound on the total variation improves (d) by the factor √2; the bound on H² is that of (d); the bound on the divergence is new. For n = N·L answers this is exactly the guarantee of Theorem 4.2(c) for N recorded runs (K ln2/N and √(K ln2/(2N))). So on scaffolds whose inputs do not depend on the answers, rehearsal with single questions and recorded runs of the human system have the same guarantee per answer. The factor 2√2 of 8.2 item 9 is then the ratio of the two bounds on adaptive scaffolds only; on the scaffold of Proposition 3.4, to which that item refers, the two bounds coincide. Exact check: on the scaffold with fixed inputs, Σ_t E KL(Q_P‖Q_{M^(t)}) equals Σ_t E[E_{Q_{M^(t)}} Σ_j KL] to six digits in all ten rows, and E TV ≤ √(LK ln2/(2n)) (script `sec3`, last table of part (B15)).

**B. The constant c* is now enclosed rigorously** (entry on Theorem 2.7): 2.96414712 < c* < 2.96414723, and the root is unique.

**C. A finer lower bound for the best constant.** Example 2.8(ii) with β = 1.00001 (1381558 levels) has the ratio 2.964127 in double precision, and with β = 1.000001 the ratio 2.964141. The value 2.96399 at β = 1.0001 is confirmed in 30-digit arithmetic and by direct evaluation of the two run laws.

**D. The constant 4 is the best one for the potential of Lemma 2.2.** The one-step ratio [E U(Λr) − U(Λ)]/(1 − E r) equals 2Λ when Λ ≤ 2, Λr ≤ 2 almost surely and E r² = 1, and so comes arbitrarily close to 4. For the potential of Theorem 2.7 the one-step ratio comes arbitrarily close to c* (it is 2.964146 at Λ = c*, r ∈ {0, 1.000001}).

**E. A variant of Protocol R.** Drawing J_t uniformly from the calls that the run of round t made (when it made any) gives the same bounds with the same proof, and no round is wasted on a short run.

**F. Lemma 1.1(5) for P(A) = 0:** the same computation gives Q(A) ≤ H²(2 − H²), slightly better than 2H².

## V. What was not checked

* T. S. Jayram's paper (APPROX-RANDOM 2009), J. C. Duchi's lecture notes, Tsybakov's book, and the three papers on tempered posteriors were not opened; the file itself marks them as not read or quoted from memory, and no proof depends on them.
* The two finest rows of the prover's linear programme (2.890 and 2.906) were not recomputed.
* Whether c₀* = c* exactly, whether a last-round bound holds in Theorems 3.1 and 4.2, and whether the frozen per-call mixture satisfies E TV ≤ C·√(LK/N) after recorded runs on an adaptive scaffold are open in the file and remain open.

## VI. Notes for the editor of the two section blocks

**Status of the statements** (the outline asks for "proved here", "standard, with source" or "open").

| statement | status that the check supports |
|---|---|
| L4 with the constant 7 | standard: Foster, Han, Qian and Rakhlin, arXiv:2404.10122, lemma "Subadditivity for squared Hellinger distance" in the appendix "Technical Tools" (cited by later papers as Lemma D.2); read in source |
| L4 with the constants 4 and c* < 2.9642 | proved here (Theorem 2.1(c), ten lines; Theorem 2.7). No source with a constant below 7 was found. The lower bound 2.9639 for the best constant is a computed example, confirmed in 30-digit arithmetic |
| R2 (Theorem 3.1) | proved here, from R1 and L4 |
| the lower bounds (Propositions 3.4, 3.5) | proved here |
| Theorem A (Theorem 4.2) | the regret bound for Bayes mixtures, which the outline lists as standard, applied to whole runs and averaged over t; the file's proof is complete and covers a human outside the class |
| the per-call mixture (Examples 4.6, 4.8; Proposition 4.7) | proved here, after correction 2 of Part III |
| Theorem B (Theorem 5.1) | proved here; for a finite class with uniform weights it is the proposition of Foster, Block and Misra (arXiv:2407.15007, read in source) |
| λ = 1 (Example 5.4) and Theorem B′ (Theorem 5.5) | proved here; the literature on tempered posteriors is quoted by the prover from memory and was not opened |
| c₀* = c*; a last-round bound; the per-call mixture after recorded runs on an adaptive scaffold; ln(1/δ₁) in Proposition 5.6 | open |

**Final constants for the blocks.**

* Block "whole runs" (Section 3). A function: the deployed run differs from the human system's run on the same ω₀ with probability at most LK ln2/n. In general: E H² ≤ 2LK ln2/n, E TV ≤ 2·√(LK ln2/n), and E Q_{M^(T)}(G) ≤ 4LK ln2/n for an event with Q_P(G) = 0; with Theorem 2.7 the three constants are c*/2 < 1.49, √c* < 1.73 and c* < 2.97. If improvement A is adopted, add for inputs that do not depend on the answers: E KL(Q_P‖Q_{M^(T)}) ≤ LK ln2/n and E TV ≤ √(LK ln2/(2n)). Lower bounds: n > LK/(8·10⁴·ε²) for the K coins (ε ≤ 1/65), n > L/(740·ε²) for two samplers (ε ≤ 1/12). Here n is the number of rounds, and the human answers at most n questions.
* Block 5.2 (recorded runs). Theorem A: E KL(Q_P‖Q̂) ≤ K ln2/N and E TV ≤ √(K ln2/(2N)); outside the class the right side is ln(1/w(ν*))/N + KL(Q*‖Q_ν*). The per-call mixture: KL(Q_f‖·) ≥ L/(8N) in Example 4.6 (for every t and for the average law), against ln2/N. Theorem B: mass at most 2^(λsℓ(P))·(1−ε²)^(2·min(s,1−s)·N), with s = ½ for λ ≥ 2. At λ = 1: mass at least ¼ for N ≤ 2^(d/2) in Example 5.4; the substitute B′ gives E H² ≤ K ln2/N for the likelihood to the power ½. For the remark that this route needs runs of the human system: by improvement A, on a scaffold whose inputs do not depend on the answers, N recorded runs and n = N·L single questions of Protocol R have the same bound, so recorded runs buy nothing there; on adaptive scaffolds the stated bounds differ by the factor 2√2 (8.2 item 9), and by Proposition 3.4 no protocol saves more than a constant factor in the worst case.
