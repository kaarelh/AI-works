# Adversarial report on `research/prove-b/hellinger-runs.md` (key: hellinger-runs)

Role: adversary. Target: the proof file `research/prove-b/hellinger-runs.md` (579 lines; labels L4, R2, A, B) and its scripts. The target file was not changed. This report was written after, and independently of, the line-by-line check `verification/hellinger-runs-check.md`; where the two overlap this is said.

**Status of this file: complete.** It was written by an adversary whose run was cut off before it removed the status line. The resumed run (16 November 2026) found every section present, including the verdict list. It spot-checked the file as follows. (i) It rederived by hand the proof of Lemma X (finding M1): both cases of the one-step inequality for U(x) = (γ/2)((m − x)₊)²; the identities U(x) − (1 − (1+η)x²) = (1 − (1+η)x)²/η for m = 1 and U(x) − (1 − x²) = (1 − mx)²/(m² − 1) for m > 1; and the optimisation giving v = σ + √(σ² + 2σ). (ii) It rederived the step of M2(c) that bounds Σ ρ ln(ρ/u) by −ln u_max when ρ ∝ u^λ and λ ≥ 1. (iii) It checked that the saved outputs `hellinger-runs_attack_events.out`, `_l4.out` and `_recorded.out` contain the numbers quoted in Sections 3 and 5. All three checks passed, and nothing was changed except this line.

Contents: (1) result in brief; (2) what was done; (3) findings by severity, each with its evidence; (4) hidden assumptions; (5) attacks that failed; (6) citations checked; (7) the researcher's seven tests; (8) what is not new; (9) verdicts, statement by statement.

Notation is that of the target file: H² = 1 − Σ√(pq); for laws P, Q of a sequence generated step by step by kernels p_i, q_i, h_i := H²(p_i, q_i)(history) and **σ := E_P Σ_i h_i**; for answerers A, B on a scaffold, σ_A := E_{Q_A} Σ_j H²(A,B)(history_j).

## 1. Result in brief

1. **No statement of the part is false.** Every theorem, proposition and example survived exact computation on small instances and adversarial search (Section 5). The two potential arguments for L4 are correct; I rederived both by hand and tested them again numerically, the second one in 50-digit arithmetic.
2. **The main statement of the part, R2, is not sharp, and the reason is the route through L4** (finding M1). Theorem 3.1 obtains its bounds on the total variation and on events from H²(Q_{M^(T)}, Q_P) ≤ 4σ. A potential argument of the same kind as Lemma 2.2, applied to the total variation and to events directly, gives the constants of a single call:
   * TV(Q_A, Q_B) ≤ σ_A + √(σ_A² + 2σ_A), which is at most 2√σ_A and is √(2σ_A) to first order (the file: √(8σ_A), or √(5.93·σ_A) with Theorem 2.7);
   * Q_A(G) ≤ (1+η)·Q_B(G) + 2(1+1/η)·σ_A for every event G (the file's route: 8(1+1/η)·σ_A);
   * Q_A(G) ≤ 2σ_A when Q_B(G) = 0 (the file: 8σ_A).

   For Protocol R this reads: E TV ≤ s + √(s² + 2s) with s = LK ln2/(2n), that is √(LK ln2/n) to first order and at most √2·√(LK ln2/n), where the file has 2·√(LK ln2/n); E Q_{M^(T)}(G) ≤ 2Q_P(G) + 2LK ln2/n where the file has 8LK ln2/n; and E Q_{M^(T)}(G) ≤ LK ln2/n for an event that the human system never produces, where the file has 4LK ln2/n. The last bound is the file's own bound for a function (Theorem 3.1(e)), now for every human, and it needs neither L4 nor a potential. The number of questions for whole-run total variation ε drops from 4LK ln2/ε² to about LK ln2/ε². All three statements were checked by exact computation; the constants in the second and third are attained.
3. **Several results are presented as proved here and are standard** (findings M2, M3). Theorem A, including its form for a human outside the class, is the progressive mixture rule of Catoni and Yang. Theorem B′ is Theorem 5.1 of Zhang (2006). Example 5.4 (failure at λ = 1) is a miniature of the counterexample of Barron, Schervish and Wasserman (1999), in the form of Section 4.4 of Zhang (2006), down to the value 1 − 1/√2 of the squared Hellinger distance. The oracle inequality that the file says it does not have for the weights w^λ (after Proposition 5.6; Section 6, point 4; Section 8.1, item 5) is Theorem 4.1 of Zhang (2006) for the λ-MAP, and the same five lines give it for the posterior. I read Zhang's paper in this session. For L4 the attribution of the constants 7 and 10²·log n is correct (read in source), but bounds of the variation distance by the expected Hellinger process under one of the two measures are classical in the theory of filtered experiments (Kabanov, Liptser and Shiryaev 1986; quoted from memory, not opened), so "no published constant below 7" must be confined to the form with H² on the left.
4. **What the researcher's tests catch** (Section 7): the budget test. Whole-run fidelity to a stochastic human costs at least LK/(8·10⁴·ε²) answers in the worst case (the file's own Proposition 3.4), so the number of answers exceeds the number of calls of a run by the factor K/ε²; m deployed runs are jointly close to the human system only while m·LK/n is small; and Theorems A and B need N of the order K/ε² runs of the human system itself. With K for a person all the bounds of the part are empty, and the lower bound shows that for this criterion no protocol does better in the worst case.

## 2. What was done

**Scripts of this report** (all in `verification/code/`; each was run without arguments and its complete output is saved next to it as `.out`; they need numpy, scipy and mpmath and write no file). Every quantity is an exact finite sum, evaluated in floating point: run laws by enumeration of all runs, expectations over the training data by a recursion over all data sets.

| script | what it attacks |
|---|---|
| `hellinger-runs_attack_l4.py` | L4 on general trees (every history has its own two kernels; exact zeros allowed), by random search and by optimisation of the ratio H²/σ; the two direct bounds of finding M1; Step 2 of Theorem 2.7 in 50-digit arithmetic at random points |
| `hellinger-runs_attack_events.py` | the event bound of finding M1 for η from ¼ to 100, on trees and inside Protocol R |
| `hellinger-runs_attack_r2.py` | Theorem R1 and Theorem 3.1(a), (b), (c), (e) under Protocol R with exact expectations: random instances and hill climbing over the class, the weights, the scaffold (adaptive, with stops) and the law of the top-level input |
| `hellinger-runs_attack_recorded.py` | Theorem 4.2, Theorem 5.1(a), (b), Theorem 5.5 and the oracle inequality of finding M2 on random classes with the human inside or outside; Example 4.6 for the law that Theorem A is about, by enumeration of all sequences of top-level inputs |
| `hellinger-runs_attack_lb.py` | Proposition 3.5: the exact Bayes risk of the two-coin problem at the stated number of questions; the number of rounds that Protocol R really needs on that instance |
| `hellinger-runs_attack_misc.py` | Example 2.8(ii) for β = 1.1, 1.01, 1.001 in two ways; Example 4.4; Lemma 3.4a; Example 5.4 by brute force over all tables |

**Proofs.** I rederived by hand: Lemma 2.2 and Theorem 2.1; every identity and every case of the proof of Theorem 2.7 (the derivative of g, the five identities of Step 0(iii), the three closed forms of the parabola and their agreement at Λ = 1 and Λ = c, the nine cases of Step 2); Theorem 3.1; Lemma 3.4a and the three steps of Proposition 3.4; Proposition 3.5; Theorem 4.2; Examples 4.6 and 4.8 (first half) and Proposition 4.7; Lemma 5.0, Theorems 5.1 and 5.5, Example 5.4, Proposition 5.6; Lemma A.1 and R1. I found no error in them.

**Literature.** Opened in this session, from arxiv.org (TeX source unless marked PDF): arXiv:2112.13487, 2404.10122, 2410.05117, 2407.15007 (the four papers of the file's Section 2.1); arXiv:2508.02637; arXiv:math/0702653 (Zhang 2006; PDF); arXiv:1611.01125 (Bhattacharya, Pati and Yang); arXiv:math/0511468 (Juditsky, Rigollet and Tsybakov 2008; PDF). **Not opened:** every source that is not on arXiv. The hosts link.springer.com and web.stanford.edu did not resolve from this session (they are outside its allowed network domains; they would have to be allowed in the session's network settings), and after two such failures I did not try further hosts. This concerns Jayram (2009), Duchi's lecture notes, the course note at Yale named in `research/sections/related-work.md`, Kabanov, Liptser and Shiryaev (1986), the book of Jacod and Shiryaev, Barron and Cover (1991), Barron, Schervish and Wasserman (1999), Catoni's and Yang's papers, and Tsybakov's book. Statements about them below are marked "from memory" or "as described in" a source that I did read.

## 3. Findings, by severity

### FATAL

None.

### MAJOR

#### M1. The bounds of R2 on the total variation and on events are loose by the factors 2 and 4, because they go through L4; a direct argument gives the constants of a single call

**Where.** Corollary 2.3 (last two statements); Theorem 3.1(b), (c); Remark 3.3(i), (iii); Section 3.3 (text and table); "In brief" (2); Section 8.2, items 2, 3 and 9.

**What the file does.** It bounds H²(Q_A, Q_B) ≤ 4σ_A (Theorem 2.1(c)) and then uses TV ≤ √(2H²) and Q_A(G) ≤ (1+η)Q_B(G) + (1+1/η)·2H² (Lemma 1.1). Each of the two steps is sharp, but not for the same pairs of laws: pairs that come near H² = 2.96·σ have a small total variation.

**What is true.** In the setting and notation of Theorem 2.1 of the file (laws P, Q with kernels p_i, q_i and the same law of X_0; r_i, Λ_i as there; σ = E_P Σ_i h_i):

> **Lemma X.** (a) For every event G and every η > 0: P(G) ≤ (1+η)·Q(G) + 2(1+1/η)·σ. In particular P(G) ≤ 2Q(G) + 4σ.
> (b) If Q(G) = 0 then P(G) ≤ 2σ.
> (c) TV(P,Q) ≤ σ + √(σ² + 2σ). The right side is at most 2√σ when σ ≤ ¼ (when σ > ¼ it exceeds 1), and it is √(2σ) + O(σ) as σ → 0.

*Proof.* For numbers m > 0 and γ > 0 let U(x) := (γ/2)·((m − x)₊)² for x ≥ 0. *One step:* for every number Λ ≥ 0 and every random variable r ≥ 0 with E r² ≤ 1,

 E U(Λr) ≤ U(Λ) + γm²·(1 − E r).

If Λ ≤ m: pointwise U(Λr) ≤ (γ/2)(m − Λr)², so E U(Λr) ≤ (γ/2)(m² − 2mΛ·E r + Λ²) = U(Λ) + γmΛ(1 − E r) ≤ U(Λ) + γm²(1 − E r), because E r ≤ 1. If Λ > m: U(Λ) = 0 and (m − Λr)₊ ≤ m(1 − r)₊, so E U(Λr) ≤ (γ/2)m²·E(1 − r)² ≤ γm²(1 − E r). (For m = 2, γ = 1 this is Lemma 2.2(ii) of the file.) Exactly as in the file's proof of Theorem 2.1(c), with (F1) and (F2), summing over the steps gives

 E_P U(Λ_n) ≤ U(1) + γm²·σ. (∗)

(a) Take m = 1 and γ = 2(1+η)/η. Then U(1) = 0 and γm² = 2(1+1/η). Moreover U(x) ≥ 1 − (1+η)x² for all x ≥ 0: for x ≤ 1 the difference of the two sides is (1 − (1+η)x)²/η, and for x > 1 the right side is negative. On {p > 0} the density ratio q/p equals Λ_n², so Q(G) ≥ E_P[1_G·Λ_n²] and P(G) − (1+η)Q(G) ≤ E_P[1_G·(1 − (1+η)Λ_n²)] ≤ E_P U(Λ_n) ≤ 2(1+1/η)·σ by (∗).
(b) Let η → ∞ in (a). (Directly: P(G) ≤ P(q = 0) ≤ E_P Σ_i a_i with a_i := p_i({q_i = 0} | X_<i), and h_i ≥ 1 − √(1 − a_i) ≥ a_i/2.)
(c) Take m > 1 and γ = 2/(m² − 1). Then U(x) ≥ (1 − x²)₊ for all x ≥ 0: for x ≤ 1 the difference is (1 − mx)²/(m² − 1). So TV(P,Q) = E_P[(1 − Λ_n²)₊] ≤ E_P U(Λ_n) ≤ (m−1)/(m+1) + 2m²σ/(m² − 1) by (∗). With v := m − 1 the right side is [v² + 2σ(1+v)²]/(v(v+2)); it is smallest where v² = 2σ(1+v), that is at v = σ + √(σ² + 2σ), and its value there is v. ∎

*The constants are those of one step.* For n = 1 and η > 0 the two-point laws p = (1−a, a), q = (1 − a/(1+η)², a/(1+η)²) with G the second point have [P(G) − (1+η)Q(G)]/h_1 → 2(1+1/η) as a → 0. For n = 1 the laws p = (½+t, ½−t), q = (½−t, ½+t) have TV = √(h_1(2 − h_1)), so the factor √2 in (c) cannot be lowered. So for these one-sided statements the adaptive choice of the inputs costs nothing, whereas for H² itself it costs a factor between 2.9639 and 2.9642 (Theorem 2.7 and Example 2.8 of the file).

**Consequences for R2.** Fix t and the data and put σ_t := E_{Q_{M^(t)}} Σ_j H²(M^(t), P)(x_j). By Lemma 1.1(2), σ_t ≤ ½·E_{Q_{M^(t)}} Σ_j KL(P‖M^(t))(x_j), so by R1 the expectation of σ_T over the data and T is at most **s := LK ln2/(2n)**. With Lemma X for A = M^(T), B = P, under the hypotheses of Theorem 3.1:

| statement | the file | with Lemma X |
|---|---|---|
| E TV(Q_{M^(T)}, Q_P) | ≤ 2·√(LK ln2/n) (1.73 in place of 2 with Theorem 2.7) | ≤ min(1, s + √(s² + 2s)); this is ≤ √2·√(LK ln2/n) always, and √(LK ln2/n)·(1 + O(√(LK/n))) |
| E Q_{M^(T)}(G), any event G | ≤ (1+η)Q_P(G) + (1+1/η)·4LK ln2/n | ≤ (1+η)Q_P(G) + (1+1/η)·LK ln2/n |
| the same with η = 1 | ≤ 2Q_P(G) + 8LK ln2/n | ≤ 2Q_P(G) + 2LK ln2/n |
| E Q_{M^(T)}(G) when Q_P(G) = 0 | ≤ 4LK ln2/n | ≤ LK ln2/n |
| questions for E TV ≤ ε | 4LK ln2/ε² | LK ln2/ε² to first order (exactly: the n with s + √(s² + 2s) = ε, which is LK ln2·(1+ε)/ε²) |

(For the first row: u ↦ min(1, u + √(u² + 2u)) is concave and increasing, so Jensen's inequality applies as in Lemma 1.1(6). For the last row: s + √(s² + 2s) = ε if and only if s = ε²/(2(1+ε)).)

The fourth row needs no Hellinger distance at all. If Q_P(G) = 0, a run in G has P(y_j|x_j) = 0 at some call (up to a set of Q_M-probability zero), so Q_M(G) ≤ E_{Q_M} Σ_j M({y : P(y|x_j) = 0} | x_j) by the union bound; and KL(P‖M)(x) ≥ −ln M(supp P(·|x) | x) ≥ M({y : P(y|x) = 0} | x); then R1. For a function f this is the proof of Theorem 3.1(e) of the file. So the linear rate LK ln2/n of the deterministic case holds, with the same constant, for every human and every event that the human system never produces.

**Evidence.**
* The proof above. It was found in this round; it has not been checked by anyone else.
* `hellinger-runs_attack_events.py`, part (E1): the largest value of Σ_runs (P − (1+η)Q)₊ divided by 2(1+1/η)·σ, over 3000 random trees and over optimised trees of depth up to 4, for η = ¼, 1, 4, 100. It never exceeds 1 and the optimiser reaches 1.00000 for each η (the bound is attained). The file's route corresponds to the value 4 on this scale.
* The same script, part (E2), and `hellinger-runs_attack_l4.py`, part (C): TV/(σ + √(σ² + 2σ)), optimised over trees, does not exceed 1; the largest values are 1.000000 at depth 1 (in the limit σ → 0, where the single-call bound is attained) and 0.999999 at depth 2. For σ at most 0.001, 0.01, 0.05, 0.1, 0.2 the largest total variation found on trees of depth up to 4 is 0.0447, 0.141, 0.322, 0.436, 0.600; the bound of Lemma X(c) is 0.0457, 0.152, 0.370, 0.558, 0.863; the file's √(8σ) is 0.089, 0.283, 0.632, 0.894, 1. So for small σ Lemma X(c) is within a few per cent of what adaptive trees can reach, and the file's bound is twice that.
* `hellinger-runs_attack_l4.py`, parts (A–D) and (D): P(q = 0)/σ reaches 2.0000 (random trees with exact zeros, and optimised trees of depth 1 to 3) and does not exceed it.
* `hellinger-runs_attack_r2.py` (exact Protocol R, 1500 random instances and hill climbing): E Q_{M^(T)}(Z)/(LK ln2/n), with Z the set of runs of Q_P-probability zero, has the largest value 1.0000 (reached as w(P) → 1), which is ¼ on the file's scale; E TV divided by the file's bound 2√(LK ln2/n) never exceeds 0.32.
* `hellinger-runs_attack_events.py`, part (E3) (exact Protocol R): E Σ_runs (Q_{M^(T)} − (1+η)Q_P)₊ divided by (1+1/η)·LK ln2/n is at most 0.22, 0.51, 0.80 for η = ¼, 1, 4; E TV divided by s + √(s² + 2s) is at most 0.37 on the instances with s ≤ ⅛.

**What should change.** (1) State R2 with the constants of the third column; give Lemma X with its proof (it is as short as Lemma 2.2), and say that the constants are those of a single call. (2) L4 in its H² form (Corollary 2.3 with the constant 4, and Theorem 2.7) is then needed only for the statement E H² ≤ 2LK ln2/n itself. The note can keep it as a result of independent interest, but R2 does not rest on it, and the long proof of Theorem 2.7 buys nothing for R2. (3) Remark 3.2(iii) (m runs with the same M^(T)) follows from Lemma X applied to the m runs as one scaffold of horizon mL: TV ≤ φ(m·σ). (4) In Section 8.2, item 9, the factor between the bounds of Theorem 4.2(c) and of Theorem 3.1(b) for the same number of answers is √2 to first order, not 2√2. (5) In Section 3.3, "up to the factor 4" in qualification (2) goes, and the table changes as above.

**A question that M1 leaves open.** In one step Pinsker's inequality gives TV ≤ √(KL/2), which is better by √2 than TV ≤ √(2H²) with H² ≤ KL/2. Whether E TV(Q_{M^(T)}, Q_P) ≤ √(LK ln2/(2n))·(1 + o(1)) holds on adaptive scaffolds (it holds when the inputs do not depend on the answers: improvement A of the check report) I could not decide.

#### M2. Theorem A, Theorem B′, the failure at λ = 1 and the missing oracle inequality for the weights w^λ are in the literature; the file presents the first three as proved here and the fourth as open

The outline (style rules) requires that standard results be called standard, with the source. The file's summary table tags Theorem 4.2 "PROVED (the candidate's statement, extended to a human outside the class)", Example 5.4 and Theorem 5.5 "PROVED", and its literature paragraph after Theorem 5.5 quotes three papers from memory. Here is what I could establish.

**(a) Theorem 4.2 is the progressive mixture rule.** A. Juditsky, P. Rigollet and A. B. Tsybakov, "Learning by mirror averaging", *Annals of Statistics* 36(5):2183–2206, 2008 (arXiv:math/0511468; read in the arXiv PDF in this session), Corollary 5.4: for M densities p_1, …, p_M, an i.i.d. sample from a density p (not assumed to be one of them) and the average p̃_n of the Bayes predictive densities with the uniform prior after 0, 1, …, n − 1 observations, E K(p, p̃_n) ≤ min_{j ≤ M} K(p, p_j) + (log M)/n. They write: "the KL aggregate p̃_n as in Corollary 5.4 coincides with the 'progressive mixture rule' considered by Catoni [7, 8, 9] and Yang [29] and the oracle inequality of Corollary 5.4 is the one obtained in those papers." With one recorded run as one observation and ln(1/w(ν)) in place of log M, this is Theorem 4.2(b) of the file, including the case of a human outside the class. The papers they cite (not opened by me): O. Catoni, "A mixture approach to universal model selection", preprint LMENS-97-30, École Normale Supérieure, 1997; O. Catoni, *Statistical Learning Theory and Stochastic Optimization*, Lecture Notes in Mathematics 1851, Springer, 2004; Y. Yang, "Mixing strategies for density estimation", *Annals of Statistics* 28(1):75–87, 2000. For a truth inside the class the device of averaging the Bayes predictive densities over the sample sizes goes back, from memory, to A. R. Barron, "Are Bayes rules consistent in information?", in *Open Problems in Communication and Computation* (T. M. Cover and B. Gopinath, eds.), Springer, 1987, pp. 85–91 (not opened). What the file adds is the application to whole runs and Lemma 4.1.

**(b) Theorem 5.5 (B′) is Theorem 5.1 of Zhang (2006).** T. Zhang, "From ε-entropy to KL-entropy: analysis of minimum information complexity density estimation", *Annals of Statistics* 34(5):2180–2210, 2006 (arXiv:math/0702653; read in the arXiv PDF in this session). With D_ρ^Re(q‖p) := −(1/(ρ(1−ρ)))·ln E_q[(p/q)^ρ] and the posterior π_{1/λ} in which the likelihood is raised to the power 1/λ: "Theorem 5.1. Consider the generalized Bayesian posterior π_{1/λ}(θ|X) defined in (9) with λ > 1. Then ∀ρ ∈ (0, 1/λ], E_X E_π π_{1/λ}(θ|X) D_ρ^Re(q‖p(·|θ)) ≤ −(λ/(ρ(λ−1)n))·ln E_π exp(−(n/λ)·D_KL(q‖p(·|θ)))." For a countable class the right side is at most (λ/(ρ(λ−1)))·inf_k [D_KL(q‖p_k) + (λ/n)·ln(1/π_k)]. At λ = 2, ρ = ½, where D_{1/2}^Re = −4 ln BC ≥ 4H², this is the file's Theorem 5.5 at α = ½: the posterior mean of H² has expectation at most ln(1/π_k)/n + ½·D_KL(q‖p_k). The truth q need not be in the class. A. Bhattacharya, D. Pati and Y. Yang, "Bayesian fractional posteriors" (arXiv:1611.01125, read in source; the journal data *Annals of Statistics* 47(1):39–66, 2019, are from the file and from memory), have the statement in probability ("PAC-Bayes inequality relative to θ_0"): with probability at least 1 − ε, ∫ (1/n)·D_α^(n)(θ, θ_0) Π_{n,α}(dθ | X^(n)) ≤ (α/(n(1−α)))·∫ r_n(θ, θ_0) ρ(dθ) + D(ρ, Π_n)/(n(1−α)) + log(1/ε)/(n(1−α)) for every ρ ≪ Π_n. So the file's sentence "bounds of this form … are standard" is right; the sources are now read.

**(c) The oracle inequality that the file does not have is Theorem 4.1 of Zhang (2006).** The file proves, for the weights w^λ and a human outside the class, only a bound in probability in which the approximation error is divided by the confidence level (Proposition 5.6), and says "For the posterior with steeper weights I have only the bound in probability of Proposition 5.6" (Section 6, point 4; also the paragraph after Proposition 5.6 and Section 8.1, item 5). Zhang's estimator (6) is k̂ := arg min_k [Σ_i ln(1/p_k(X_i)) + λ·ln(1/π_k)], which is the file's λ-MAP, and: "Theorem 4.1. Consider the estimator k̂ defined in (6). Assume that λ > 1. Then ∀ρ ∈ (0, 1/λ], E_X D_ρ(q‖p_k̂) ≤ E_X D_ρ^Re(q‖p_k̂) ≤ (1/(ρ(λ−1)))·inf_k [D_KL(q‖p_k) + (λ/n)·ln(1/π_k)]", where D_ρ(q‖p) := (1/(ρ(1−ρ)))·E_q[1 − (p/q)^ρ], so D_{1/2} = 4H². In the file's notation, at λ = 2 and for every λ-MAP ν̂ and every ν* ∈ H:

 E[H²(Q_ν̂, Q*)] ≤ ln(1/w(ν*))/N + ½·KL(Q* ‖ Q_ν*),

an inequality in expectation, with the approximation error at the factor ½ and no confidence level. Zhang attributes the case λ = 2, ρ = ½ to A. Barron and J. Li (J. Li, PhD thesis, Yale, 1999, Theorem 5.5), and says of A. R. Barron and T. M. Cover, "Minimum complexity density estimation", *IEEE Transactions on Information Theory* 37(4):1034–1054, 1991: "They showed (Theorem 4) that D_{1/2}(q‖p_k̂) = O_p(r_{λ,n}(q)) when λ > 1", with r_{λ,n} the index of resolvability inf_k [D_KL(q‖p_k) + (λ/n)·ln(1/π_k)]. So Theorem B of the file (its part on the MAP) is a version with explicit constants, for whole runs and for a human in the class, of a theorem of Barron and Cover, and Zhang's Theorem 4.1 is its form for a human outside the class.

The same bound holds for the posterior Π_λ itself, by the file's own proof of Theorem 5.5 with one change. With α := 1/λ, r_ν := L_ν/L*, u_ν := w(ν)·r_ν^α and Φ as in that proof, the inequality Σ_ν ρ(ν)·f(ν) ≤ ln Σ_ν w(ν)·e^(f(ν)) + Σ_ν ρ(ν)·ln(ρ(ν)/w(ν)) (Jensen), applied to f(ν) := α·ln r_ν − N·ln A_α(ν), gives for every probability vector ρ on H: N·Σ_ν ρ(ν)·(−ln A_α(ν)) ≤ ln Φ + Σ_ν ρ(ν)·ln(ρ(ν)/u_ν). For ρ = Π_λ, which is proportional to u^λ, the last sum equals (λ−1)·Σ_ν ρ(ν) ln u_ν − ln Σ_ν u_ν^λ ≤ (λ−1)·ln u_max − λ·ln u_max = −ln u_max ≤ ln(1/w(ν*)) + α·ln(L*/L_ν*); for ρ the point mass at a λ-MAP it equals −ln u_max as well. Taking expectations as in the file (E ln Φ ≤ 0):

 E[Σ_ν Π_λ(ν | τ_1:N)·(−ln A_{1/λ}(ν))] ≤ ln(1/w(ν*))/N + KL(Q* ‖ Q_ν*)/λ for every λ ≥ 1 and every ν* ∈ H,

and the same with −ln A_{1/λ}(ν̂) for any λ-MAP ν̂ on the left. Since −ln A_{1/λ} ≥ 2·min(1/λ, 1 − 1/λ)·H² (Lemma 5.0), this is an oracle inequality in H² for λ > 1. Evidence: `hellinger-runs_attack_recorded.py`, part (4): 3872 random instances (human inside or outside the class, λ from 1.02 to 5, N up to 30, the MAP with the worst tie-breaking), exact expectations; the inequality holds in all, and the largest ratio of the two sides is 0.9945. So Proposition 5.6 is correct but is not the best available statement, and the open question of Section 8.1, item 5 (first half) is answered in expectation. In probability, the term KL*/δ₁ of Proposition 5.6 comes from Markov's inequality for ln(L*/L_ν*), whose upper tail is not controlled by its mean alone; I do not claim that it can be removed.

**(d) Example 5.4 is the known counterexample.** Zhang (2006), Section 4.3: "The standard MDL (λ = 1) … It is impossible to give a bound similar to Theorem 4.1 that depends only on the index of resolvability." Section 4.4 gives the example: the truth is uniform on 2m points and has prior ¼; 2^n further densities, each uniform on m of the 2m points and drawn at random, have prior 3/2^(n+2) each; then the standard MDL estimate differs from the truth with probability at least 1 − e^(−1/2), "no matter how large n is". Each of these densities is at squared Hellinger distance 1 − 1/√2 from the truth (my computation: the affinity is m·√((1/(2m))·(1/m)) = 1/√2), which is the value 0.2929 of the file's Example 5.4, and for the same reason: a hypothesis that is silent on half of the space doubles the likelihood of what it has not yet excluded. Zhang relates the example to "the Bayesian inconsistency counterexample given in [2]", A. Barron, M. J. Schervish and L. Wasserman, "The consistency of posterior distributions in nonparametric problems", *Annals of Statistics* 27(2):536–561, 1999 (not opened; Bhattacharya, Pati and Yang describe it thus: "the posterior tends to put all its mass on a set of distributions that are √(2 − √2) away from the true data generating distribution with respect to the Hellinger metric", and (2 − √2)/2 = 1 − 1/√2). Zhang's Theorem 4.3 also has the positive statement at λ = 1 under a condition on the decay of the prior, of which the file's Remark 5.3 (S_½ = Σ√w < ∞) is a case. The file's example is cleaner than Zhang's (no randomisation, exact posterior mass), and its reading as "the human with the coins filled in" is the project's own; but the phenomenon and the construction are published.

**What should change.** In Section 5.2 of the note: Theorem A "standard (progressive mixture rule: Catoni 1997, 2004; Yang 2000), applied to whole runs"; Theorem B "a form, with explicit constants, of Barron and Cover (1991, Theorem 4); for a finite class with uniform weights the proposition of Foster, Block and Misra"; the failure at λ = 1 "the counterexample of Barron, Schervish and Wasserman (1999) and Zhang (2006, Section 4.4) in the present setting"; Theorem B′ "Zhang (2006, Theorem 5.1)"; and for a human outside the class cite Zhang (2006, Theorem 4.1) in place of Proposition 5.6. Remove "I have only the bound in probability" and item 5 (first half) of Section 8.1.

#### M3. For L4 the cited constants are right, but the sentence "no published constant below 7" holds only for the inequality with H² on the left

**(a) The attribution is correct** (read in the TeX sources, see Section 6): 10²·log n and 3·log V in Foster, Kakade, Qian and Rakhlin (arXiv:2112.13487); 7 in Foster, Han, Qian and Rakhlin (arXiv:2404.10122), whose text says that the lemma is "an improvement to Lemma A.13 of" the former "that removes a logarithmic factor". A paper of August 2025 still states the lemma with "an absolute constant c ≤ 7" and calls it "a recent (and surprisingly non-obvious) result" (G. Blanc, C. L. Canonne and E. Waingarten, "Instance-Optimal Uniformity Testing and Tracking", arXiv:2508.02637, FOCS 2025 according to the arXiv comment; read in source). I found nothing against the constants 4 and 2.9642 being new for the H² form.

**(b) The older literature on filtered experiments is missing.** For two probability measures on a filtered space, the Hellinger process h of order ½ is, in discrete time and in the file's notation, the predictable process Σ_{i ≤ n} h_i, and the identity of Theorem 2.1(a) is the discrete form of the equation satisfied by the Hellinger integral. Yu. M. Kabanov, R. Sh. Liptser and A. N. Shiryaev, "On the variation distance for probability measures defined on a filtered space", *Probability Theory and Related Fields* 71:19–35, 1986, bound the variation distance between the restrictions of the two measures to a stopping time from above and below in terms of h (title, journal and this description of the content: from the publisher's record as returned by a web search in this session; the paper itself was not opened). From memory, their upper bound is ‖P_T − P̃_T‖ ≤ 4·(E h_T)^(1/2), with the expectation under one of the two measures and ‖·‖ twice the total variation, and the same inequality is in J. Jacod and A. N. Shiryaev, *Limit Theorems for Stochastic Processes*, Springer, 1987 (2nd edition 2003), Chapter V, Section 4. I could not confirm the constant. In the file's notation it reads TV(P,Q) ≤ 2√σ. Lemma X(c) above implies exactly this (σ + √(σ² + 2σ) ≤ 2√σ for σ ≤ ¼, and both sides are at least 1 for σ ≥ ¼), which makes me trust the recollection; it is independent of it. So a one-sided bound on the total variation of sequentially generated laws with an absolute constant is, as far as I can tell, forty years old, and it is better than what the file derives from L4 (√8·√σ, or 2.44·√σ with Theorem 2.7). The note should (i) cite this line of work next to Jayram and Foster et al., after someone has opened the source, and (ii) confine "we found no published constant below 7" to the inequality with H² on the left.

**(c) Two possible sources remain unopened**, as `research/sections/related-work.md` already says: Lemma 11.5.3 of J. C. Duchi's lecture notes, and the course note "Chain rule for squared Hellinger distance (following T. S. Jayram)" on a Yale statistics page (a web search in this session returned it as a scribed note of 13 February 2024 for a course of Yihong Wu, saying that the chain rule "holds also for the squared Hellinger within a constant"; the constant was not in the returned text). Neither host is reachable from this session. Until they are read, the sentence about the constant 7 is NOT VERIFIED.

### MINOR

**m1. "The factor √L is necessary": what exactly is shown, and how far the constants are from the truth.** Propositions 3.4 and 3.5 are correct. Their scope should be stated with them: (i) the criterion is the expected total variation between the run law of the trained imitator and the human system (the file says this in qualification (4) of Section 3.3; under the weaker criterion the factor disappears, by replay); (ii) the scaffolds ask the same input several times within a run (each of K inputs at least four times with K ≥ 8 in Proposition 3.4, one input L times in Proposition 3.5) and count on fresh coins at each repetition (assumption A1); (iii) the class of Proposition 3.4 has uniform weights, so its K is the logarithm of the size of the class. Exact evaluation on the two-coin instance of Proposition 3.5 (`hellinger-runs_attack_lb.py`): the Bayes risk that the proof uses stays above ε up to n = 0.0093 to 0.0123 times L/ε² (twelve pairs (L, ε) with L from 3 to 1001), so the constant 1/740 = 0.00135 is smaller than the proof's own argument allows by a factor of about 8; and Protocol R itself reaches E TV ≤ ε after 0.045 to 0.052 times L/ε² rounds (six pairs), where the upper bounds are 2.77 (Theorem 3.1(b)), 0.69 (Theorem 3.1(d), and Lemma X to first order) and 0.35 (improvement A of the check report) times L/ε². So on this instance the truth for Protocol R is about 4 times the two-point lower bound and about 7 times below the best upper bound; "about 5·10⁴ between the two bounds" describes the proofs, not the problem.

**m2. Theorem 3.1(a) is far from attained in everything I could compute.** In exact computations (1500 random instances, then hill climbing on this ratio) E H²(Q_{M^(T)}, Q_P) never exceeded 0.2500 times the bound 2LK ln2/n. The three inequalities behind (a) are sharp in different places: R1 when one answer settles everything, H² ≤ KL/2 when the human's answer is nearly certain, L4 only for small H² with a drifting likelihood ratio. The best constant in (a) lies between ½ and 2; I do not know where. Not an error.

**m3. Example 4.6: the thresholds are sufficient conditions; exact values.** By enumeration of all (2N)^N sequences of top-level inputs, for the law (1/N)·Σ_t Q_{M_t} that Theorem A is about (`hellinger-runs_attack_recorded.py`, part (5), N ≤ 5): the divergence exceeds ln2/N already for L ≥ 3 when N ≤ 4 and for L ≥ 4 when N = 5 (the file: "as soon as L ≥ 6"); the total variation exceeds √(ln2/(2N)) from L = 4, 5, 6 on for N = 1, 2, 3. In all 40 rows E KL ≥ L/(8N), as the file claims; at L = 1 the two imitators coincide, as they must. This also confirms numerically, for the averaged law, the step that the check report found missing in the text of Example 4.6.

**m4. The imitator of Theorem A is not a sampler.** It draws one hypothesis per run and lets it answer every call of that run. This is an answerer whose state lasts for a run, or, which is the same law, a per-call mixture that conditions on the earlier answers of its own run. In a scaffold whose calls are executed apart from each other (a tree of calls) it needs a run identifier or a shared seed at every call. The researcher asked for a sampler; the note should say in Section 5.2 that the object of Theorem A is a mixture at the level of runs, that the stateless per-call mixture loses up to the factor L (Example 4.6, Proposition 4.7), and that Theorem B is the statement about a sampler.

**m5. Theorem 4.2(b), events that the human system never produces.** The file has E Q̂(G) ≤ 2Q*(G) + 2ρ_N(ν*). If Q*(G) = 0 then Q̂(G) ≤ 1 − Q̂(supp Q*) ≤ −ln Q̂(supp Q*) ≤ KL(Q* ‖ Q̂), so E Q̂(G) ≤ ρ_N(ν*): the factor 2 is not needed.

**m6. The last round.** Remark 4.3 and Section 8.1, item 3, leave open whether the posterior mixture after all N runs satisfies a bound C·K ln2/N. From memory, this is a known open problem: P. D. Grünwald and W. Kotłowski, "Bounds on individual risk for log-loss predictors", COLT 2011 (open problems), JMLR Workshop and Conference Proceedings 19:813–816, ask whether bounds on the cumulative risk of Bayes predictive distributions give bounds on the risk at one sample size. I did not open it. If confirmed, the note should say "open, and asked in the literature".

**m7. Horizon and rounds.** L is the largest number of calls of a run and must be known to the protocol (J_t is uniform on {1, …, L}); n counts rounds, of which a fraction E[len]/L puts a question (the check report makes the second point). For a scaffold whose runs differ much in length the bound in rounds is governed by the longest run; in answers actually given it scales with the mean length. Task decompositions have runs of very different sizes, so the note should say this.

**m8. Example 4.8.** (i) In the first half the ratio to L·K ln2 is unbounded only as w(P) → 1, where K → 0; the case K = 1 is computed, not proved (the file says so; the check report corrects two of the four numbers). (ii) The file asks whether the frozen per-call mixture still satisfies E TV ≤ C·√(LK/N). One would try Lemma X or L4 with the per-call H² along the human system's runs. That route is closed too: in the same example the sum over t of the expected per-call H² is 0.80, 1.35, 2.49, 4.78 times L·K ln2 for η = 10⁻¹, 10⁻², 10⁻⁴, 10⁻⁸ at p = 0.01 (`hellinger-runs_attack_misc.py`, part (5); it grows like ½·o·ln(1/o)). The same part reproduces the file's four ratios 2.2, 3.3, 5.6, 10.2 for KL.

**m9. Proposition 5.6** is correct and is dominated, in expectation, by the published inequality (finding M2(c)).

### WORDING

**w1. c* rounded down** ("c₀* ≤ c* = 2.9641", "the best constant up to the fourth digit"): found by the check report; I agree. c* = 2.964147…, so the proved statement is 2.9639 ≤ c₀* ≤ 2.9642.

**w2. "Theorem A is false for the per-call mixture"** (summary table; "In brief" (4); title of Example 4.6). Correct, but the same sentence should say how it fails: by a factor of at most L in the cases covered by Proposition 4.7, with the rate in N unchanged. For a deterministic human the per-call mixture has the bound LK ln2/N on the total variation, which is below the bound √(K ln2/(2N)) of Theorem A as soon as N > 2L²K ln2. A reader of "false" alone will conclude that the per-call mixture does not work after recorded runs.

**w3. Remark 4.9, last sentence** ("the second is the right object under the low-stakes assumption"): a reading; nothing in this file proves it. It belongs to the part on R5.

**w4. "R2 is optimal up to an absolute constant"** (summary table, Section 3.3): say "the order LK/ε² is necessary in the worst case over classes and scaffolds"; the constant between the proved bounds is of the order 10⁴ (see m1 for what an exact computation shows).

**w5. Section 3.3, qualification (2), "up to the factor 4"**: with finding M1 there is no factor.

**w6. Section 8.2, item 1** ("either should replace the citation"): the citation should stay next to the new constants, and the classical line of finding M3(b) should be added.

## 4. Hidden assumptions

None of these makes a statement false; each is used silently or said only once, and the note should say it where the result is stated.

1. **Closed system.** The deployed run has the same scaffold and the same law μ₀ of (z, ρ) as the rehearsal runs, or as the recorded runs. A top-level input outside the support of μ₀, or a longer scaffold, is outside every statement of the part.
2. **A1 is used in two strong forms.** (i) A call taken out of a run of the imitator, possibly a senseless one from an early round, is answered by the human as P would answer it. (ii) The same input asked again is answered with fresh coins. The lower bounds count exactly these repeated draws, and the independence of recorded runs rests on (ii) across runs.
3. **The event G of Theorem 3.1(c) is fixed before the data are seen.** For events chosen afterwards only the bound on the total variation applies.
4. **Expectation over the data and over T.** For one M^(T) kept for good there is only Markov's inequality: confidence 1 − δ at the price 1/δ (Remark 3.2(ii)). There is no statement with ln(1/δ) and none for the last round.
5. **One run.** For m runs of the same M^(T) the joint laws are close only while m·LK/n is small (Remark 3.2(iii)). An imitator that is run far more often than it was rehearsed is, over all its runs together, distinguishable from the human system.
6. **L is the maximum length and is known** (m7).
7. **Theorem A:** independent recorded runs with the scaffold's own law of ω₀; an imitator with a state that lasts for a run (m4).
8. **Human outside the class under Protocol R:** the bound of Remark 3.3(ii) needs sup_x KL(P‖ν*)(x) < ∞ over all inputs, including those that only bad imitators produce. For recorded runs the corresponding term is the divergence along the human system's own runs. So without A2 rehearsal asks much more of the class than recorded runs do.
9. **Answers ⊥.** A hypothesis given as a semimeasure answers ⊥ with the missing mass, the mixture inherits this, and the scaffold must define what it does then (Section 0.1 of the file says so).

## 5. Attacks that failed

| statement | attack | outcome |
|---|---|---|
| Theorem 2.1(a), (b) | 4000 random trees (binary to depth 5, ternary to depth 4, kernels with exact zeros) | identity (a) to 4·10⁻¹⁶; (b) violated by at most 10⁻¹⁶ |
| Theorem 2.1(c), Theorem 2.7 (H² ≤ 4σ, ≤ c*·σ) | the same trees; then maximisation of H²/σ by L-BFGS-B from random starts on trees with free kernels at every history | largest ratio 1.53 at random; optimised: 1.707 (depth 2), 2.000 (depth 3), 2.19 (depth 4), 2.31 (depth 5), 2.39 (depth 6, binary), 2.00 and 2.19 (ternary, depth 3 and 4). All below c* = 2.9641. Depth 2 reproduces (2+√2)/2 of Example 2.6 |
| Theorem 2.7, Step 2 (the parabola lies above V) | 50-digit arithmetic at 4000 random points (Λ, a), a quarter of them near the tangency a = Λ and a quarter near Λ = 1 and Λ = c* | no negative value; the smallest value of parabola − V is 6·10⁻¹⁰, at a point with a close to Λ, where the two touch |
| Example 2.8(ii) (ratio 2.9639) | recomputed from the text for β = 1.1, 1.01, 1.001, by Theorem 2.1(a) and from the two run laws | 2.82407, 2.94927, 2.96265, as in the file; β = 1.0001 not recomputed by me (the check report has it in 30-digit arithmetic) |
| Theorem R1 | exact Protocol R; random instances and hill climbing on the ratio to L·K ln2 | largest ratio 1.0000 (equality when one answer identifies the human); never above |
| Theorem 3.1(a), (b), (c), (e) | the same, on each ratio | largest ratios to the file's bounds: 0.2500 for (a), 0.318 for (b), 0.2500 for (c) with Q_P(G) = 0; for (e), which is the case of a function of the statement "E Q_{M^(T)}(G) ≤ LK ln2/n when Q_P(G) = 0", the largest ratio is 1.0000. Never above 1 |
| Lemma 3.4a | grid of odd N from 3 to 20001 and δ up to the boundary | smallest G/(δ√(N/2)) = 1.931 |
| Proposition 3.5 | exact Bayes risk at n = ⌊L/(740ε²)⌋ for twelve pairs (L, ε) | between 2.66·ε and 4.42·ε, never below ε |
| Proposition 3.4 | proof rederived; no computation of mine (the argument is Assouad's lemma with Lemma 3.4a; the check report recomputed the constants) | no error found |
| Theorem 4.2(a) | 1465 random classes, human inside or outside, hypotheses with zeros, N ≤ 8, exact | never violated; equality for two mutually singular hypotheses |
| Example 4.4 | recomputed | 0.00321, 0.01058, 0.02451, 0.03794, 0.04298, 0.03988, as in the file |
| Example 4.6 | exact, averaged law, N ≤ 5 (m3) | the file's inequalities hold in all rows |
| Example 4.8, first half | recomputed (m8) | ratios 2.208, 3.303, 5.582, 10.164 |
| Theorem 5.1(a), (b) | 2000 random classes with Kraft weights (integer and non-integer lengths), λ from 1.02 to 5, ε² from 0.002 to 0.2, N ≤ 30, the smallest β over 25 admissible values of s, exact | never violated |
| Theorem 5.5 | 3872 instances, α = ½, human inside or outside | never violated |
| Example 5.4 | brute force over all tables for d = 1, 2 and N ≤ 4 | the posterior mass of the tables at λ = 1 equals E[2^(−R)/(1 + 2^(−R))] to six digits |

I did not attack Proposition 2.4, Proposition 2.5, Example 2.6 beyond the depth-2 optimum above, Example 2.8(i), Lemma 4.5, Proposition 4.7, Corollary 5.2 and Remark 5.3 by computation; I read their proofs and found no error, and the check report recomputed them.

One warning about such searches, from my own first runs: when the two laws agree on everything that P reaches, σ and H² are both zero, and a ratio formed from two rounding errors can be anything (I got 27). The scripts now skip instances with σ < 10⁻¹² and compute every h as ½Σ(√p − √q)², which has no cancellation.

## 6. Citations checked

"Read" means: opened in this session and the statement found in the text. Authors, titles and arXiv dates were compared with the arXiv records.

| citation in the file | how checked | result |
|---|---|---|
| D. J. Foster, S. M. Kakade, J. Qian, A. Rakhlin, "The Statistical Complexity of Interactive Decision Making", arXiv:2112.13487 (v3, 11 July 2023) | read (TeX source) | Lemma "Subadditivity for squared Hellinger distance": D²_H(P,Q) ≤ 10²·log(n)·E_P[Σ_i D²_H(P^(i), Q^(i))], and 3·log(V) in place of 10²·log(n) when the ratios P^(i)(A|x)/Q^(i)(A|x) are at most V ≥ e. No constant 7. As the file says. |
| D. J. Foster, Y. Han, J. Qian, A. Rakhlin, "Online Estimation via Offline Estimation: An Information-Theoretic Framework", arXiv:2404.10122 (v1, 15 April 2024) | read (TeX source) | Same hypotheses, constant 7; the text calls it "an improvement to Lemma A.13 of" the paper above "that removes a logarithmic factor"; the proof uses the cut-and-paste property and "Theorem 7 of" Jayram (2009) and ends with "∏_{i=1}^n (1 − 1/2^i) > 2/7". In that proof D²_H is written as 1 − ∫√(·), the file's convention. The number "D.2" cannot be read off the source (the order of the appendices depends on a switch); arXiv:2407.15007 and arXiv:2410.05117 cite the lemma as "Lemma D.2". As the file says. |
| F. Chen, D. J. Foster, Y. Han, J. Qian, A. Rakhlin, Y. Xu, "Assouad, Fano, and Le Cam with Interaction: A Unifying Lower Bound Framework and Characterization for Bandit Learnability", arXiv:2410.05117 (v2, 6 December 2024) | read (TeX source) | The lemma with 7, attributed to Jayram (2009), "see also" Lemma 11.5.3 of Duchi's notes and Lemma D.2 of the paper above; squared Hellinger distance is the f-divergence with f(x) = ½(√x − 1)²; the lemma E_{X∼P_X}[D²_H(P_{Y|X}, Q_{Y|X})] ≤ 2·D²_H(P_{X,Y}, Q_{X,Y}). As the file says. |
| D. J. Foster, A. Block, D. Misra, "Is Behavior Cloning All You Need? Understanding Horizon in Imitation Learning", arXiv:2407.15007 (v2, 30 November 2024; arXiv comment: NeurIPS 2024) | read (TeX source) | Proposition: D²_H(P^π̂, P^π*) ≤ 2·log(|Π|δ⁻¹)/n with probability at least 1 − δ; the change-of-measure lemma in both forms quoted; "Lemma D.2 of Foster et al. (2024)" is used four times. As the file says. |
| T. S. Jayram, "Hellinger strikes back: a note on the multi-party information complexity of AND", APPROX-RANDOM 2009, LNCS 5687, pp. 562–573 | not opened | The file also marks it "not read". That Foster, Han et al. apply its Theorem 7 is confirmed in their text. Its own statement and constant: NOT VERIFIED. |
| J. C. Duchi, *Lecture Notes on Statistics and Information Theory*, Lemma 11.5.3 | not opened (host not reachable) | NOT VERIFIED; may state a constant. |
| A. B. Tsybakov, *Introduction to Nonparametric Estimation*, Springer 2009, Lemma 2.5 (Pinsker) | not opened | From memory the lemma number is right. The file needs only Pinsker's inequality. |
| T. Zhang, "From ε-entropy to KL-entropy: analysis of minimum information complexity density estimation", *Annals of Statistics* 34(5):2180–2210, 2006 | read (arXiv:math/0702653, PDF; the first page carries the journal data) | The file cites it from memory for "bounds of this form". It contains them and more: Theorems 4.1, 4.3, 5.1 and the example of Section 4.4 (finding M2). |
| A. Bhattacharya, D. Pati, Y. Yang, "Bayesian fractional posteriors", *Annals of Statistics* 47(1):39–66, 2019 | read (arXiv:1611.01125, TeX source); journal data not verified | Results in probability for the fractional posterior, among them the inequality quoted in M2(b). Consistent with the file's use. |
| A. R. Barron, T. M. Cover, "Minimum complexity density estimation", *IEEE Transactions on Information Theory* 37(4):1034–1054, 1991 | not opened | Journal, volume and pages as in Zhang's reference list. Content as Zhang describes it: Theorem 4, a rate in probability for λ > 1, no bound at λ = 1. |
| `understand/repo.md`, item E11; `understand/imitation-theory.md`, LB3 and §5.8; `research/prove/lower-bounds.md`, Theorem 6.3 | read | Exist and say what the file quotes. |

Sources that this report adds: Juditsky, Rigollet and Tsybakov (2008) and Blanc, Canonne and Waingarten (2025) were read; Kabanov, Liptser and Shiryaev (1986), Jacod and Shiryaev, Catoni (1997, 2004), Yang (2000), Barron (1987), Barron, Schervish and Wasserman (1999), Li (1999) and Grünwald and Kotłowski (2011) were not opened, and every statement about them above says so.

## 7. The researcher's seven tests (`understand/notes.md`, Section 5), applied to R2, Theorem A and Theorem B

**1. Guard** (an input property that no training input has; what does the scheme do there, and with what probability?). *R2.* The asked calls are a uniform sample of the calls of the imitator's own full runs, so inside the closed system no property of calls separates asked from deployed calls in distribution; depth is not a guard. For a set Γ of calls the statements give: the run makes a call in Γ with probability at most (1+η)·Q_P(visits Γ) + (1+1/η)·LK ln2/n; it makes a call in Γ and does there what the human system never does with probability at most LK ln2/n (finding M1). *What the test catches.* The guarantee is a budget of probability of order LK/n per run. Inside this budget the imitator may do anything, including reaching inputs that the human system never produces (they are created by its own wrong answers), and nothing is said about its behaviour once there. A property that the runs meet with probability below LK/n is never rehearsed often enough to matter, and the behaviour on it is fixed by the prior. And two guards are assumed away, not handled: a top-level input outside μ₀, and any feature of an input that tells deployment from rehearsal (Section 4, item 1). *Theorems A and B.* The data are runs of the human system. A guard on inputs that occur in no human run is refuted by no amount of data; the imitator reaches such inputs only after leaving the human system's behaviour, which costs it total variation. A larger scaffold at deployment than in the recorded runs is exactly such a guard ("depth of the tree"), and nothing in the part covers it.

**2. Machine.** The reference machine enters only through K (or ℓ(P)); another machine changes it by a constant, and the bounds by the factor (K + c)/K. Proposition 3.4 shows that a factor K is needed for a class with uniform weights; it does not show that K(P) is needed for a given human in the universal class. In Theorem B the exponent λ is a second choice of the same kind: for λ ≥ 2 the length ℓ(P) counts λ/2 times. So the answer to the guard test is a fact about the scheme and the prior together, through one number that nobody has estimated for a person.

**3. Referent** (does a hypothesis that models how the data were made do as well?). *R2.* Hypotheses are kernels in x. A hypothesis "answer as the human does on calls that look like rehearsal questions, and otherwise differently" loses weight exactly where its answers differ on calls that the imitator's runs make; the calls of the deployed run and the asked calls of round T have the same law, so it gains nothing. *What the test catches:* this rests on A1 in the form of Section 4, item 2(i) (the human answers an isolated call as he would inside a run), and on the absence of any mark of rehearsal in the inputs. *Theorems A and B.* The data are whole runs of the human system, and the run law is the referent that is learned; a human with memory inside a run is then approximated by the best stateless sampler (Section 6, point 3, of the file).

**4. Copy** (does anything distinguish the sampler from a better predictor of it, or from the sampler with its coins filled in?). R2 deploys a mixture and Theorem A a fresh posterior draw for every run; both are statements about run laws. Example 5.4 makes the point sharply: at λ = 1 the hypothesis drawn in Theorem A is a fill-in with probability about ½, and Theorem A holds all the same. Theorem B (λ > 1) returns one program whose run law is close to the human system's; among the fill-ins it excludes those that are far in run law. It cannot tell the human from any program with nearly the same run law on this scaffold: single calls are controlled only up to the factor L, and inputs that the human system does not visit not at all (Corollary 5.2, items 4 and 5). So the part removes one failure, the fill-in, for λ > 1 and for recorded runs only, and says nothing else about being a copy. That the idea of steeper weights and its known theory (Barron and Cover; Zhang) are older than the project should be said (finding M2).

**5. Budget.** *R2:* about LK ln2/ε² single calls for whole-run total variation ε (4LK ln2/ε² in the file), and LK ln2/ε for an event that the human system never produces. Each answer is one call out of context, which fits "short human tasks". *What the test catches.* (i) Fidelity is quadratic in 1/ε. (ii) The number of answers exceeds the number of calls of one run by the factor K/ε², and by Proposition 3.4 this is forced for the criterion of whole-run total variation: nothing is amplified within a run. (iii) Across runs only the law of each single run is amplified; m runs together are close to the human system only while m·LK/n is small. (iv) With K for a person, say 10⁹ bits, and L = 100, ε = 0.1, the count is 7·10¹² answers: every bound of the part is empty. *Theorems A and B:* N of the order K/ε² runs of the human system, each a human episode as long as the whole scaffold; Section 8.2, item 9, of the file shows that this saves no answers. The budget test is the one the part fails, and the file's own lower bound shows that for this criterion no protocol passes it in the worst case. The note must say so where R2 is stated.

**6. Rock.** There is no abstention in this part; the imitator always answers. The test is passed, at a price: where a bound is empty, nothing warns. (The certificate V1 of the candidate theory is the remedy and lies outside this part.)

**7. Horizon.** The theorems carry the law of the human system over to the imitator and say nothing on whether the human system achieves anything. Three facts of the part bear on it: the number of questions grows linearly in L; Theorems A and B need the human system itself to be run N times, which confines them to scaffolds that people can execute; and A1 forbids learning within a run, so a long computation must carry all its progress in the inputs.

## 8. What is not new

| result of the file | status | source, and how I know |
|---|---|---|
| Lemma 1.1 | standard | Le Cam's inequalities, Pinsker's inequality, data processing; for example Tsybakov's book, Section 2.4 (from memory). |
| Theorem 2.1(a), (b) | standard in substance | The telescoping identity for the Hellinger affinity; in continuous time it is the equation of the Hellinger integral in terms of the Hellinger process (Jacod and Shiryaev, Chapter IV; from memory). |
| Corollary 2.3 with some absolute constant | standard | Jayram (2009) as used by Foster, Han, Qian and Rakhlin (2024): constant 7 (read). For the total variation: Kabanov, Liptser and Shiryaev (1986) (from memory; M3). |
| the constants 4 and c* < 2.9642, and the example with ratio 2.9639 | apparently new | No earlier source found by the prover, the checker or me; two sources unopened (M3(c)). |
| Proposition 2.4 | standard | The affinity of product measures is the product of the affinities. |
| Proposition 2.5 | standard | Chen et al. (constant 2) and Foster, Kakade et al. (constant 4), read; the file says so. |
| R1, Theorem 3.1(e) | standard | Outside my part; `research/outline.md`, addendum 2, item 1 (Li and Zhang; Ross, Gordon and Bagnell). |
| Theorem 3.1(a) to (d) | new as statements; the tools are L4 and R1 | With finding M1 the statements on the total variation and on events follow from R1 and a ten-line lemma. |
| Propositions 3.4, 3.5 | standard methods, statements apparently new | Assouad's lemma and Le Cam's two-point method (for example B. Yu, "Assouad, Fano, and Le Cam", in *Festschrift for Lucien Le Cam*, Springer 1997; from memory). The file does not name the methods; it should. |
| Theorem 4.2 | standard | The progressive mixture rule: Catoni (1997, 2004), Yang (2000), as described by Juditsky, Rigollet and Tsybakov (2008), read (M2(a)). |
| Lemma 4.5 | standard | The chain rule for KL, and the hybrid argument (replace the answerer one call at a time). |
| Examples 4.6, 4.8, Proposition 4.7 | apparently new | The comparison of the frozen per-call mixture with one posterior draw per run; I know no source. |
| Theorem 5.1 | standard in substance | Barron and Cover (1991, Theorem 4) as described by Zhang (2006), read; for finite classes Foster, Block and Misra (read). The explicit bound with the free exponent s is the file's. |
| Example 5.4 | standard in substance | Barron, Schervish and Wasserman (1999); Zhang (2006, Section 4.4), read (M2(d)). |
| Theorem 5.5 | standard | Zhang (2006, Theorem 5.1), read; Bhattacharya, Pati and Yang, read (M2(b)). |
| Proposition 5.6 | superseded | Zhang (2006, Theorem 4.1), read (M2(c)). |
| Lemma X of this report | Lemma X(c) refines a classical inequality (M3(b), from memory); X(a) I have not seen | Found in this round; unchecked by others. |

## 9. Verdicts

HOLDS: I could not break it and I followed the proof. HOLDS WITH CHANGE: true, but the statement, its constant, its attribution or a sentence around it must change as said. NOT VERIFIED: I could neither break it nor establish it. BROKEN: none.

| statement | verdict | note |
|---|---|---|
| Lemma 1.1 | HOLDS | standard; the check report's sentence on general measurable spaces should be added |
| Section 2.1: the constant 7 is in Foster, Han, Qian and Rakhlin (arXiv:2404.10122); Foster, Kakade, Qian and Rakhlin (arXiv:2112.13487) have 10²·log n | HOLDS | read in the TeX sources in this session |
| Section 2.1: "no statement of the lemma with a constant below 7" | NOT VERIFIED | true of everything opened, for the form with H² on the left; for the total variation a classical bound exists (M3(b), from memory); Duchi's notes, the Yale note and Jayram's paper were not opened |
| Lemma 2.2, Theorem 2.1(a), (b), (c) | HOLDS | proof rederived; exact tests |
| Corollary 2.3 (L4), H²(Q_A, Q_B) ≤ 4σ_A | HOLDS | |
| Corollary 2.3, the bounds on TV and on events | HOLDS WITH CHANGE | true but loose by the factors 2 and 4; replace by Lemma X (M1) |
| Propositions 2.4, 2.5; Example 2.6 | HOLDS | 2.6 reproduced by optimisation at depth 2 |
| Theorem 2.7 (constant c*) | HOLDS | proof rederived by hand; Step 2 confirmed in 50-digit arithmetic; write "c* < 2.9642" (w1) |
| Example 2.8 | HOLDS WITH CHANGE | ratios recomputed for β = 1.1, 1.01, 1.001; "c₀* ≤ 2.9641" must read 2.9642; that c₀* = c* stays open |
| Remark 2.9 | NOT VERIFIED | the figure 12.6 has no written proof; not used |
| Theorem R1, Lemma A.1 | HOLDS | exact computations reach equality |
| Theorem 3.1(a), E H² ≤ 2LK ln2/n | HOLDS | never above a quarter of the bound in exact computations (m2) |
| Theorem 3.1(b), E TV ≤ 2√(LK ln2/n) | HOLDS WITH CHANGE | true; the sharper E TV ≤ s + √(s² + 2s), s = LK ln2/(2n), holds (M1) |
| Theorem 3.1(c), events | HOLDS WITH CHANGE | true; 8LK ln2/n can be 2LK ln2/n and 4LK ln2/n can be LK ln2/n (M1) |
| Theorem 3.1(d), (e) | HOLDS | (d) can be sharpened as in the check report, improvement A |
| Remarks 3.2, 3.3 | HOLDS WITH CHANGE | 3.3(i) and (iii) are overtaken by M1; 3.2 stands |
| Lemma 3.4a | HOLDS | recomputed on a grid |
| Proposition 3.4 | HOLDS | proof rederived; not attacked by computation |
| Proposition 3.5 | HOLDS | exact Bayes risk at the stated n; the constant 1/740 is loose by a factor of about 8 against its own argument (m1) |
| Section 3.3 ("√L is necessary", the table, the four qualifications) | HOLDS WITH CHANGE | state the scope (m1); new constants in the table and no "factor 4" in qualification (2) (M1); "optimal" only with the size of the constant (w4); qualification (3) as filled by the check report |
| Lemma 4.1 | HOLDS | |
| Theorem 4.2 (Theorem A) | HOLDS WITH CHANGE | correct; it is the progressive mixture rule and must be attributed (M2(a)); for Q*(G) = 0 the factor 2 in (b) is not needed (m5); the imitator is not a sampler (m4) |
| Remark 4.3 | HOLDS | the last-round question is, from memory, a known open problem (m6) |
| Example 4.4 | HOLDS | recomputed |
| Lemma 4.5 | HOLDS | |
| Example 4.6 (Theorem A fails for the per-call mixture) | HOLDS WITH CHANGE | correct for the averaged law as well (exact enumeration, N ≤ 5); add the step named by the check report; say that the loss is a factor up to L (w2) |
| Proposition 4.7 | HOLDS | |
| Example 4.8, first half | HOLDS | recomputed; the same failure occurs with H² in place of KL (m8) |
| Example 4.8, second half (K = 1, B alternatives) | NOT VERIFIED | not recomputed by me; the check report corrects two of its four numbers; the file marks it "not proved" |
| Remark 4.9 | HOLDS WITH CHANGE | the last sentence is a reading, not a result of this file (w3) |
| Lemma 5.0, Theorem 5.1 (Theorem B) | HOLDS | correct with the stated constants; a relative of Barron and Cover (1991, Theorem 4) and must be presented so (M2(c)) |
| Corollary 5.2, Remark 5.3 | HOLDS | |
| Example 5.4 (λ = 1) | HOLDS | correct; in substance the published counterexample (M2(d)) |
| Theorem 5.5 (Theorem B′) | HOLDS | correct; it is Theorem 5.1 of Zhang (2006) (M2(b)) |
| Proposition 5.6 and the sentences "I have only the bound in probability", "I do not know whether …" | HOLDS WITH CHANGE | the proposition is correct; the oracle inequality in expectation exists (Zhang 2006, Theorem 4.1, for the λ-MAP; for the posterior by the argument in M2(c), checked numerically) |
| Section 6 (table and four points) | HOLDS WITH CHANGE | point 4 changes with M2(c); the row of R2 with M1 |
| Section 8.1, item 5; Section 8.2, items 1, 2, 3, 9 | HOLDS WITH CHANGE | M1, M2(c), M3 |
| Lemma X of this report (not a statement of the file) | proposed | proved in M1 and tested exactly; not checked by anyone else |

