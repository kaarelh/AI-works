# rehearsal-core: line-by-line check

Referee report on `research/prove-c/rehearsal-core.md` (871 lines, Sections 0 to 17) and, against it, on Sections 1 to 3 of `note.md`. Role: referee, line by line. Verdicts: **CORRECT**; **MINOR** (correct after a small fix, which is given); **GAP** (a step is missing; it is named, and filled where I could); **WRONG** (the failing step, a counterexample, and the strongest true replacement).

**Outcome.** No statement of the proof file is wrong in substance. The numbered statements of Sections 1 to 3 of `note.md` (R1, R3, R3a, V1) are correct once two hypotheses that their proofs use are written into them: in R3a, that every run has exactly L calls; in V1, that the answerer is frozen (Section 2 of the note says "freeze an imitator", but the theorem says "any answerer"). Eight statements of the proof file need a small fix: a missing hypothesis (Proposition 9.3(ii)); a missing range or domain (Propositions 5.2(d), 8.3(c), 8.3(d)); a claim of tightness that the example supports only in part (Theorem 5.1(d)); a rounding slip, and a summary that drops a qualification (Proposition 6.3); and wording that says more than is proved (Theorem 13.1(c), Corollary 13.2). One assertion made in a remark without proof is true and is proved here (Remark (ii) after Theorem 8.4). Two additions are proposed for Theorem V1: the certificate of part (a) is valid for every human, and a statement (c′) about two humans that validation cannot tell apart, which says what cannot be certified. All constants were recomputed; one is off in the sixth digit, without consequence. The prover's seven scripts reproduce their saved outputs exactly, and nine scripts of my own, which share no code with them, confirm the statements on other instances.

The parts: A to I, one entry for every numbered statement of the proof file; J, its closing sections; K, the note; L, the numerical checks; M, the corrections in order of importance; N, the table of verdicts.

## A. Sections 0 to 4 (conventions, setting, L1, L2, L3)

**Section 0, (E1) and (E2). CORRECT.** (E1): for u > 0, (ln u)⁺ ≤ u/e (the maximum of ln(u)/u is 1/e, at u = e); summing p·(ln(q/p))⁺ ≤ q/e over the y with p(y) > 0 gives at most 1/e. (E2) is 1 − u ≤ −ln u.

**Definition 1.2 and (1.1). CORRECT.** M_D(y|x) = ξ(D + (x, y))/ξ(D) is the definition written out; (1.1) follows from M_D ≥ w_D(P)·P and w_D(P) > 0 when P(D) > 0.

**Definition 1.5 (the three functionals and their relations). CORRECT.** Recomputed: H² ≤ KL/2 (by (E2) and Jensen); 2·TV = Σ|√p − √q|(√p + √q) ≤ √(2H²)·√(4 − 2H²), so TV ≤ √(H²(2 − H²)) ≤ √(2H²); β(C) ≤ √(2·E[len]·χ(C)) by Cauchy–Schwarz; for a function, TV = e, KL = −ln(1 − e), H² = 1 − √(1 − e) ≥ e/2.

**Lemma 2.1 (L1, chain rule). CORRECT.** All three cases checked. In Case 2a the set of histories that occur in S is a countable union of measurable sets (one for each y), it has positive μ_B-measure because S has positive measure for μ_B ⊗ counting measure, and r > 0 on it, so it has positive μ_A-measure. In Case 2b the two negative parts are integrable with the stated constants (∫ r(ln(1/r))⁺ dμ_B ≤ 1/e uses that μ_B is a probability measure). Padding by ∗ makes the terms beyond len vanish. Edge cases: len = 0 gives 0 = 0; infinite values are covered by Cases 1 and 2a.

**Lemma 3.1 (maximal coupling). CORRECT.** Row sums recomputed; t = 0 gives the diagonal coupling.

**Lemma 3.2 (L2). CORRECT.** In (c), {j ≤ j₁} = {y_i = y′_i for all i < j} belongs to 𝓖_j, and the history of the new run before call j is 𝓖_j-measurable on this event, so the conditional law of ỹ_j given the new run's past is B_j(·|h̃_j); the stopping rules agree because the histories agree up to call j₁. Runs with no calls: N = 0 and τ̃ = τ.

**Definition 3.3 and Proposition 3.4. CORRECT.** κ_C(·|x, y′) is defined only where P(y′|x) > 0, which is all that is needed (the other pairs have probability 0). (d): γ_x(y, f(x)) = C(y|x) because the second marginal is the point mass at f(x).

**Lemma 4.1 (L3). CORRECT.** The telescoping identity holds with the factor W: Π M_{D_{t−1}}(y_t|x_t) = ξ(D_n)/W. The integrability argument in (ii) is complete: a_t Z_t ≤ C + Σ_{s<t} (a_s Z_s)⁻ and each negative part has mean at most 1/e. Semimeasures and W < 1 are covered (κ_t is a divergence between distributions on Y_⊥).

**Lemma 4.2. CORRECT.** For a function no null set is needed: every data list that can arise has f(D_n) = 1.

**Lemma 4.3 (high-probability forms). CORRECT.** b_t > 0 in case (a) because M_{D_{t−1}}(f(x_t)|x_t) ≥ w_{D_{t−1}}(f) > 0; G_n is a nonnegative martingale of mean 1 because b_t is 𝓕_{t−1}-measurable; the constant ½ in (b) is the exponent c = ½.

**Remark 4.4. CORRECT.** (b): KL(P ‖ M^norm) = KL(P ‖ M) + ln(1 − M(⊥|x)); TV and H² also do not increase under normalisation because P gives ⊥ no mass and M^norm ≥ M on Y. (c): the computation is as stated.

## B. Section 5 (Theorem R1 and the deployed mixture)

**Definition 5.0 (Protocol R). CORRECT as a definition.** It agrees with Section 2 of `note.md` and with Protocol R of the candidate theory. Two readings that the definition fixes and the note does not: n is the number of rounds (the number of questions is at most n), and J_t is drawn after the run and independently of it.

**Theorem 5.1 (R1), parts (a), (b), (c). CORRECT.** (a) Protocol R is an instance of Setting 4.0 with 𝓖_t = σ(𝓕_{t−1}, τ_t, J_t); given 𝓕_{t−1} and τ_t the index is uniform, so the conditional mean of a_t κ_t is (1/L)·Σ_{j≤len_t} KL(P ‖ M^(t))(x_{t,j}); given 𝓕_{t−1} the run has the law Q_{M^(t)}. The sum is finite almost surely by (1.1). (b) and (c) are the same computation with H² and TV. Edge cases checked: L = 1 (then J_t = 1 and the protocol is passive learning from independent inputs); n = 1 (Λ(M^(1)) ≤ L·ln(W/w(P)) holds directly because M_∅ ≥ (w(P)/W)·P); runs with no calls (a_t = 0, the round is skipped); a repeated input within a run; hypotheses that are semimeasures and W < 1. Numerical check: exact enumeration on a scaffold of horizon 3 that has all of these features (`rehearsal-core_check_r1.py`): Σ_t E Λ(M^(t)) equals L·Σ_t E[a_t κ_t] to rounding and is below the bound; the pathwise statement of (c) holds on every path.

**Theorem 5.1(d). MINOR.** The example is correct and shows that (a) holds with equality: Σ_t E Λ(M^(t)) = L·ln(1/w). For (c) the same example gives Σ_t E β(M^(t)) = L·(1 − w), which is strictly below the bound L·ln(1/w) of (c); the quotient (1 − w)/ln(1/w) tends to 1 only as w → 1 and tends to 0 as w → 0. So the words "the inequalities in (a) and (c) cannot be improved" and the entry "(d) equality is attained" of the summary table are justified for (a) only. *Fix.* Either restrict the claim to (a), or add the following example, which shows that the bound of (c) is approached for every w. Let X = {x_1, …, x_N}, f ≡ 0, and g_i(x) := 1[x = x_i] with w(g_i) := (1 − w)/N, w(f) := w; let z be uniform on {1, …, N} and let all L calls be at x_z. When k of the inputs have been asked, the mixture errs at each other input with probability ((1 − w)/N)/(1 − k·(1 − w)/N), and β(M^(t)) is L·(N − k)/N times this. Every round asks x_z, and the expected number of rounds spent with k inputs asked is N/(N − k); so Σ_{t=1}^{∞} E β(M^(t)) = L·Σ_{k<N} ((1 − w)/N)/(1 − k·(1 − w)/N), which tends to L·∫_0^{1−w} du/(1 − u) = L·ln(1/w) as N → ∞ (the sum over t ≤ n tends to this value as n → ∞, and w(f) = w does not change with N). Numerically (`rehearsal-core_check_r1.py`): for w = 0.01 the sum divided by L is 2.78, 4.19, 4.60 for N = 10, 100, 10⁴, against ln(1/w) = 4.605 and against 1 − w = 0.99 in the two-function example.

**"The hypotheses, and why each is needed" (after 5.1). CORRECT.** In (i) the class must be {f, g} with W = 1 for the stated value ln(1/w(f)); this is implicit.

**Proposition 5.2(a). CORRECT.** T is independent of 𝓕_n and uniform.

**Proposition 5.2(b). CORRECT.** For a function, Lemma 4.3(a) and E_{t−1}[a_t e_t] = β(M^(t))/L give n·β̄/L ≤ ln(W/w(f)) + ln(1/δ). In general 2L·χ̄ ≤ L²·(ln(W/w(P)) + 2·ln(1/δ))/n, and β̄ ≤ √(2L·χ̄) by the concavity of the square root. Constants recomputed.

**Proposition 5.2(c). CORRECT; one remark.** Both statements follow from Markov's inequality. The second statement (with δ₁ and δ₂) is never better than Markov's inequality applied directly to β(M^(T)), which gives β(M^(T)) ≤ L·ln(W/w(f))/(n·δ) with probability at least 1 − δ: for δ = δ₁ + δ₂ one has (ln(W/w(f)) + ln(1/δ₁))/δ₂ > ln(W/w(f))/δ. The two-parameter form is of use only if the two sources of randomness are to be kept apart (with probability 1 − δ₁ over the rehearsal, at most a fraction δ₂ of the rounds have β(M^(t)) above the stated value); it should be stated in that form, or the direct form should be added.

**Proposition 5.2(d). MINOR.** The example and the computation are correct: Pr[β(M^(T)) = q/2] = (1 − (1 − q)^n)/(q·n) ≥ δ·(1 − e^(−1/δ)), and 1 − e^(−1) > 0.63, 0.63/(2 ln 2) = 0.4544 > 0.45 (recomputed; the probability was also evaluated exactly for five pairs (n, δ)). *Fix.* The last sentence must carry the range of δ: the argument produces levels δ′ = 0.63·δ with δ ∈ [1/n, 1], so it shows that a bound valid for all n needs φ(δ′) ≥ 0.45/δ′ for δ′ ∈ (0, 0.63]; for δ′ above 0.63 nothing is shown.

**Proposition 5.3 (several questions in a run). CORRECT.** (a) The first question of each round has the data list D_{t−1} before it, so its term in Lemma 4.1(iii) is a_t·KL(P ‖ M^(t))(x_t); the other terms are nonnegative and are dropped. The pathwise statement of 5.1(c) also survives (the product over all questions is at least w(f)/W). (b) and (c): the two examples are correct; in the second example every run has L calls, so both protocols ask in every round. The definition of Protocol R⁺ leaves open whether further calls may be asked in a round with J_t > len_t; the proof covers both readings.

**Definition 5.4 and Proposition 5.5(a). CORRECT.** 1 − Π_j (1 − e_j) lies between max_j e_j and Σ_j e_j; the number of calls of τ^f is at most L.

**Proposition 5.5(b) (the ladder). CORRECT.** Recomputed: (5.1); β(M̄) ≥ (1 − p)·S/n − (1 − p)²·S²/(2n²) (Bonferroni); E[S] ≥ ∫_0^{s₀} g = (1 − p)·L³/2 for n ≥ L² ≥ s₀; R is a sum of L independent geometric variables, E[R] = L², Var[R] = L³ − L², E[R²] ≤ 2L⁴, S ≤ L·R; hence E β(M̄) ≥ (1 − p)²·(L³/(2n) − L⁶/n²). Exact check without sampling (`rehearsal-core_check_ladder.py`): the number u_t of unlearned inputs is a Markov chain, and E[Π_j (1 − (1 − p)·N_j/n)] is computed by a forward recursion in which the addition of an input in round t carries the factor 1 − (1 − p)·t/n; the recursion agrees with a brute-force enumeration for four small cases. For p ∈ {0.1, 0.5, 0.9}, L ∈ {2, …, 40} and n ∈ {L³, 4L³, 20L³} every inequality of the proposition that applies holds (54 cases). The exact values for p = ½, n = 20·L³ are E u(M̄) = 0.00719, 0.00663, 0.00641 for L = 10, 20, 40 (the prover's simulation: 0.00718, 0.00646, 0.00650), that is 2.08, 3.82, 7.40 times the bound L·K ln 2/n. In this example E β(M^(T)) = (1 − p)·L²/n exactly once n is large.

*Wording.* "In brief", item (2), and Section 15, item 1, say that the run of the averaged kernel "can be unfaithful with a probability L times larger". Proved: at most L times larger (5.5(a)), and in the ladder at least (1 − p)²·L/4 times larger; the exact computation gives about L/4 for p = ½ and about 0.46·L for p = 0.1. Write "of the order of L times larger (at most L times; about L/2 in an example)".

## C. Section 6 (the last round)

**Definition 6.0 and Proposition 6.1(a). CORRECT.** For a non-adaptive scaffold the pairs (a_t, x_t) are functions of (z_t, ρ_t, J_t), hence independent and identically distributed with Pr[a_t = 1, x_t = x] = q(x), and E[ν(D_n)] = (1 − ε_ν)^n. The layer-cake identity uses Σ_ν w_{D_n}(ν) = 1. ∫_0^∞ min{1, c·e^(−sn)} ds = (ln c + 1)/n for c > 1 and c/n for c ≤ 1; both are at most (ln(W/w(f)) + 1)/n. Check on a second family (thresholds, `rehearsal-core_check_lastround.py`, part 1): n·E β(M^(n+1)) stays below 0.53 against bounds between 5.6 and 21.7; the prover's family reaches 6.23 against 10.21, so the bound has the right order and that family is the informative one.

**Proposition 6.1(b). CORRECT.** E[√(ν(D_n)/P(D_n))] = (1 − h_ν)^n by induction, because the conditional mean of the factor of round t depends on (a_t, x_t) only and this pair is independent of the past; H²(P, ·)(x) is convex; min{1, Σ a_i} ≤ Σ √(a_i); c = S_½/√(w(P)) ≥ 1 because √(w(P)) is one of the terms of S_½. The bound on β follows by Jensen.

**Proposition 6.2 (the hedging hypothesis). CORRECT.** Recomputed: K ln 2 = 88L − ln 2 + ln W′ < 88L; ψ_t = 1/(1 + e^(κi)/(2(1 + φ))) with i = n − t + 1; Σ_t ψ_t ≤ ln(3 + 2φ)/κ; p·Σ_t ψ_t ≤ ln(3 + 2φ)/24 = 0.04578; Pr[round n + 1 is early] ≥ 0.6208; ψ_{n+1} ≥ 2/3; KL(f ‖ M^(n+1))(b) ≥ 80L; 0.6208·(1/3)·(2/3)·80 = 11.036 > 11 = 88/8. The hypothesis n ≥ L is what makes p ≤ 1/3 a probability; nothing else is needed. Independent exact computation (the posterior has three kinds of state; `rehearsal-core_check_lastround.py`, part 2): E Λ(M^(n+1)) = 0.41942, 3.2974, 25.379, 198.80 for L = 5, 10, 20, 40 and n = 4000, the prover's values to all printed digits; the inequality also holds at the edge n = L (L = 2 and 7) and for 200 random pairs (L, n) with n ≥ L (`rehearsal-core_check_sweep.py`).

**Proposition 6.3 (traps behind a clock). CORRECT; one rounding slip (MINOR).** Recomputed: the posterior (G, uniform S on the complement of A); (6.2); s′ = κ·s·(1 − s) ≤ κ/4 and s(n) = s₁; Pr[E₀] = (1 − 1/(3n))^n ≥ e^(−1/3)·(1 − 1/(9n)); E[a″] ≤ (p/κ)·ln((1 + η·e^(κn))/(1 + η)) ≤ ā; (6.1). In "The numbers": ā/√L = ln(1 + e)/(3·1.1272) = 0.388355, and ā/N ≤ 0.388355/1.6262 = 0.238811, which is above the stated 0.23881 by 1.4·10⁻⁶. *Fix.* Write "ā/N ≤ 0.23882"; then the bracket is at least 0.731·(0.71633 − 0.23882) − 0.0011 = 0.34796 > 0.3479 and everything after it stands. The right side of (6.1) divided by L·K ln 2/n was also evaluated directly for L from 4 to 10⁶ at n = 100·L; it exceeds (L − 1)/(40·√L) in every case. Independent exact recursion (part 3 of the same script): E β(M^(n+1)) = 0.10998, 0.35944, 1.2686, 4.7303 for L = 100, 400, 1600, 6400 (the prover: 0.11, 0.3594, 1.269, 4.73), and 0.11425, 0.15572 for the two small cases that the prover simulated. Inequality (6.1) itself, which is stated for all N ≥ 1, λ > 0 and n ≥ L ≥ 2, holds in 400 random parameter settings (`rehearsal-core_check_sweep.py`).

*Wording (must be carried into the note).* The class of the example contains the samplers g_S, which are not functions. So the statement is: for a deterministic human *in a class that also contains samplers that are not functions*, no bound C·L·K/n holds for the last round. "In brief", item (3), the introduction of Section 6 and Section 11 drop this qualification. For a class of functions the question is open (the file says so in Section 14, item 1).

**Proposition 6.4 (an upper bound for the last round). CORRECT; add what it does not say.** All five steps checked: R_t(ν) is the likelihood factor on O_t and is 1 otherwise; r_t(ν) ≥ b_ν/L − u_t; S_n(ν) is a supermartingale because r_n(ν) is 𝓕_{n−1}-measurable and e^r·(1 − r) ≤ 1; on {U_n ≤ ns/2} every ν ∈ B_s has Π_t R_t(ν) ≤ S_n(ν)·e^(−ns/2); ∫_0^1 min{1, c/s} ds = c·(1 + ln(1/c)) for c < 1; 2L·ln(W/w(f))/n = 2B₀. The class may contain samplers. *Missing remark.* The bound is a bound on a probability and exceeds 1 unless 2L·B₀·(1 + ln(1/(2B₀))) < 1, which needs n to exceed 2L²·K ln 2 by a factor of about ln L + 3 (a factor 7.6 for L = 100; in the examples of Propositions 6.2 and 6.3 with the parameters used there the bound is between 0.9 and 400). The hypothesis "2·B₀ < 1" therefore does not mark the range in which the statement has content; say so after the statement. In Remark (ii), "For E[u(M^(n+1))] it lies between 1 and about …": the lower end is not proved as stated (no example with ratio at least 1 is given; the family of Section 16 reaches 0.68 for L = 1, and the ratio tends to 1 only as w(f) → 0); write "between a constant and".

## D. Section 7 (R2 for a deterministic human)

**Theorem 7.1. CORRECT.** (a) Given (z, ρ), the run of C equals τ^f(z, ρ) exactly if every answer on the path of τ^f is f's; TV(Q_C, Q_f) = u(C) because Q_f is carried by the graph of τ^f. (b) and (c) are 5.2(a) and 5.2(b) with u ≤ β. Edge cases: len = 0 gives an empty product and u = 0; L = 1 gives u = β.

## E. Section 8 (Theorem R3: low stakes)

**Definitions 8.1 and 8.2. CORRECT.** The monotonicity of δ̄_Π is proved correctly (β′_i ∈ [β_i, L] and Σ_i λ_i β′_i = β′). r^{A,≤k} needs the earlier human answers and passed answers to count the replacements, so it is in 𝓡_all in general and in 𝓡_bst for a kernel, as stated.

**Proposition 8.3(a), (b). CORRECT.** δ̄_Π is concave and bounded on [0, L], so Jensen's inequality applies; C takes countably many values, so there is no measurability question.

**Proposition 8.3(c). MINOR.** The arguments L·ln(W/w(f))/n and L·√(ln(W/w(P))/(2n)) can exceed L (for n < ln(W/w(f)), respectively n < ln(W/w(P))/2), and δ̄_Π is defined on [0, L] only. *Fix.* Write δ̄_Π(min{L, L·ln(W/w(f))/n}) and δ̄_Π(min{L, L·√(ln(W/w(P))/(2n))}); the proof is unchanged because E β ≤ L.

**Proposition 8.3(d). MINOR.** Correct for L ≥ 2 and ε ∈ (0, 1) (Π_j e_j ≤ (Σ_j e_j/L)^L with equality for equal e_j; the least concave majorant of the convex function (β/L)^L on [0, L] is the chord β/L; checked by random search for L = 2, 3, 5). For L = 1 the two sides are equal and the strict inequality ε > ε^L fails. *Fix.* Add "L ≥ 2, 0 < ε < 1".

**Theorem 8.4 (R3). CORRECT.** The coupling of τ with τ̃ was checked call by call: (1) at the calls j ≤ j_k the budgeted rule applies r^A, as τ does; (2) at the calls j > j_k with equal histories, the human's answer y′_j has the law P(·|x_j) given 𝓖_j, and the past of τ̃ together with the event "histories equal so far" is 𝓖_j-measurable; whether the two histories separate at call j is decided by y_j, which is drawn after y′_j and affects only where τ̃ takes its later answers from, and in both cases these are draws from P at the inputs of τ̃ given its past; (3) τ̃ = τ on {N ≤ k}. So τ̃ has the law of the run corrupted by r^{A,≤k}, and the two inequalities follow. (a), (b), (c) follow as stated; in (c), L/(k + 1) ≤ 1/θ. Exact check for answerers that depend on the whole history and a human who is not deterministic (`rehearsal-core_check_lowstakes.py`, part 1, 300 random instances, runs of length 1 to 3): the run corrupted by r^A has the law Q_A, E N = β(A), and Q_A(G^c) ≤ δ_k(A) + Pr[N ≥ k + 1] ≤ δ_k(A) + β(A)/(k + 1) for k = 0, …, 3, with equality in the first inequality up to rounding in some instances.

**Remark (ii) after Theorem 8.4 ("a tolerance assumption for rules that do not see the human's answer would not suffice"). GAP in a remark, filled.** The file asserts this and gives no example; Remark 12.3(ii) compares only with a rule that replaces calls chosen in advance. The assertion is true; in the family of Remark 12.3(ii) the example needs D > 1, that is, an answer that is worse than the worst answer the human gives. The family: steps +1 (answer u, probability (1 + μ)/2) and −1 (answer d); a third answer b with step −D. Call a rule *blind* if at call j it chooses, before the human's answer exists, either to pass that answer or to override it by an answer of its choice. A replacement is counted when the passed answer differs from the human's (Definition 3.3), so a blind rule may pass d at every call until its budget is used: passing d when the human says d is no replacement, and each counted replacement then costs 2. An override by b costs μ + D in expectation. Precisely, with ξ_j := step(y′_j) − μ and c* := max{2, μ + D}, the loss of call j is at most c*·1[replacement at j] + ξ_j·1[override by b or ⊥ at j], so the rise is at least μL − c*·k + Σ_j ξ_j·1[no override by b or ⊥ at j]; the last sum is a martingale with increments of conditional range 2, and by Lemma 12.1 every blind rule with at most k replacements fails with probability at most δ whenever c*·k + √(2L·ln(1/δ)) ≤ η·μ·L. The kernel that gives b in place of u with probability ε has β = ε·L·(1 + μ)/2, and each of its unfaithful calls costs 1 + D. For D = 1, the smallest value that hypothesis (iii) of Proposition 12.2 allows in this family, this equals c*, and there is no gap between the two notions. For D > 1 there is: with μ = 0.2, D = 3, η = ½, δ = 10⁻³ and L = 2·10⁶ the condition allows k = 60 857 blind replacements, and the kernel with β = 0.9·k fails with probability 1.0000 (exact binomial computation, `rehearsal-core_check_blind.py`; 0.9998 for L = 2·10⁵ and β = 0.95·k), while δ + β/(k + 1) = 0.901. So the conclusion of Theorem 8.4 does not follow from tolerance against rules that do not see the current answer of the human. *Fix.* Keep the sentence and add this example, or delete it. (The last sentence of Remark 12.3(ii) is accurate as written: it speaks of k calls chosen in advance. A blind rule that counts its replacements can lose max{2, μ + D} per replacement, which is worth one clause there.)

**Example 8.5. CORRECT.** (a): equality for δ = 0 and β = (k + 1)·ε; the sentence "cannot be improved as a function of δ, β and k" is shown for δ = 0 only, which is enough for the point made. (b): for a rule in 𝓡_tr the passed answers are independent of I. (c): the set R of replaced calls among 2, …, L is contained in the set R₀ of the first k calls among 2, …, L whose coin shows a replacement, also when the budget was partly used at call 1; R₀ is independent of z. A grid search over budgeted stateless rules (part 4 of the script) gives the worst failure exactly k/(L − 1) for five pairs (L, k), so the bound of (c) is attained.

**Theorem 8.6 (recoverable form). CORRECT.** V_{j+1} = V_j on {j > len}; on {j ≤ len}, E[v_{j+1}(h_j, y′_j) | 𝓖_j] = v_j(h_j) and v_{j+1}(h_j, y_j) ≤ v_{j+1}(h_j, y′_j) + μ·1[y_j ≠ y′_j]; summing gives the claim. Exact check for 200 random rules in 𝓡_all (part 2 of the script): E c(τ^r) − (E_{Q_P} c + μ·E N) ≤ −0.13, and (E c − E_{Q_P} c)/(μ·E N) reaches 0.82. Remark (ii): k·μ + β/(k + 1) ≥ 2√(μβ) − μ is correct; and the direct bound μ·β is never worse than the bound obtained through Theorem 8.4 when the latter is at most 1 (if k·μ + β/(k + 1) ≤ 1 then β ≤ k + 1, and then μβ ≤ k·μ + μ·(β − k)⁺ ≤ k·μ + β/(k + 1), because (β − k)⁺ ≤ β/(k + 1) for β ≤ k + 1). The quotation of Ross, Gordon and Bagnell (2011, Theorem 2.2) agrees with my memory of that paper; I did not open it in this session.

## F. Section 9 (the human who is not deterministic)

**Proposition 9.1. CORRECT.** β(C) ≤ √(E_{Q_C}[len]·Λ(C)/2) by Pinsker and Cauchy–Schwarz; the second Cauchy–Schwarz step is over rounds and the rehearsal; √(ln 2/2) = 0.5887 < 0.59. The exact enumeration of `rehearsal-core_check_r1.py` confirms (a) on a scaffold with runs of variable length (ℓ̄ = 1.90 < L = 3).

**Theorem 9.2 (lower bound √(K/n) per call). CORRECT.** Recomputed: β_σ(A^ω) ≥ (1/K)·Σ_i φ_{σ,i}(ω) by the convexity of TV; φ_{σ,i} + φ_{σ^(i),i} ≥ 2θL; kl(θ) = 2θ·ln((1 + 2θ)/(1 − 2θ)) ≤ 16θ² for θ ≤ ¼ (the quotient kl/θ² is between 8.0 and 8.8 on (0, ¼], so 16 is safe); TV(𝐏_σ, 𝐏_{σ^(i)}) ≤ θ·√(8·E_σ N_i); averaging with the concavity of the square root gives θL·(1 − θ·√(8n/K)) = θL/2; θ/2 = √(K/n)/(8√2) = 0.0884·√(K/n). The hypothesis n ≥ K/2 is what gives θ ≤ ¼. Lemma 2.1 applies to the transcript because the protocol has a bounded number of steps. Consistency check against a concrete protocol (equal split, sign of the majority): its average β/L is between 1.29 and 1.46 times θ/2 in five cases, never below.

**Proposition 9.3(i), (iii). CORRECT.** (i) The human's answers are independent Bern(½ + θ′) whatever the rule does, because the inputs do not depend on the answers; Lemma 12.1 with c_j = 1 gives exp(−2(θ′L − k)²/L); with k = ⌊θ′L/2⌋ this is at most exp(−θ′²L/2). (iii) follows from Proposition 9.1(b) with L/(k + 1) ≤ 2/θ′. The hypothesis "L odd" is not used anywhere (for even L a tie counts as a failure and both parts still hold); it can be dropped or kept as a convenience.

**Proposition 9.3(ii). MINOR.** The proof gives θ′·√(8n/K) ≥ 1 − 2γ. The stated conclusion n ≥ K·(1 − 2γ)²/(8θ′²) follows from this only if 1 − 2γ ≥ 0. For γ > ½ the conclusion is false: the protocol that asks nothing and answers every call with a fair coin has failure probability ½ for every σ (L odd) and n = 0. *Fix.* Add the hypothesis γ ≤ ½ (or write (1 − 2γ)₊²).

## G. Section 10 (the online form) and Section 11

**Theorem 10.1. CORRECT.** κ_t is determined before the coin, so E[c_t κ_t] = q·E[κ_t]; the statement for a function uses e_t ≤ κ_t.

**Corollary 10.2. CORRECT.** The expected number of questions is q times the expected number of steps (the existence of step t is decided before its coin), hence at most r for q = 1/L; (1 − 1/L)·L = L − 1.

**Proposition 10.3. CORRECT.** The run τ′ has the law Q_{M_i} and is independent of the coins (extend the coins to all L positions); at the calls j ≤ min(j*, len(τ′)) the online run has the inputs of τ′ and the current mixture M_i (the data before a step do not contain that step's answer); (1 − q)^(j−1) ≥ (1 − q)^(L−1). The shadow variant is correct by the argument of 5.3(a). In the example of 5.1(d): E Λ(M_i) = L·ln(1/w)·(1 − q)^(L(i−1)); the factor 1/(1 − (1 − 1/L)^L) increases from 4/3 (L = 2) to e/(e − 1) = 1.582 (recomputed for 2 ≤ L < 2000). The statement excludes q = 1, hence L = 1 with q = 1/L; there the bound holds trivially (0⁰ = 1) and this may be said. Independent exact enumeration of the online form and of the shadow variant on the scaffold of horizon 3 (`rehearsal-core_check_online.py`; stochastic human with semimeasures, and deterministic human; q ∈ {1/3, ½, 0.9, 1}): all bounds of 10.1 to 10.3 hold, and E[questions] = q·E[steps] to rounding.

**Section 11, Remarks (i) to (iii). CORRECT** as summaries of 5.3, of the protocol, and of 6.1 to 6.4, with the qualification on 6.3 noted above (the class of the example is not a class of functions).

## H. Section 12 (Proposition R3a)

**Lemma 12.1 (Azuma–Hoeffding with conditional ranges). CORRECT.** ψ″ = p(1 − p) ≤ ¼ gives E[e^(λ(U−u)) | 𝓗] ≤ e^(λ²/8); the choice s = 4t/Σ_j c_j² gives exp(−2t²/Σ_j c_j²). The case c_j = 0 is handled.

**Proposition 12.2 (R3a). CORRECT.** Δ_j ≥ Δ′_j − (1 + D) at a replaced call because Δ_j ≥ −D by (iii) and Δ′_j ≤ 1 by (ii) (almost surely, since y′_j has positive probability); E[Δ′_j | 𝓗_{j−1}] ≥ μ by (i) and H1, with 𝓗_{j−1} containing everything up to the passed answer of call j − 1, the rule's coins included; the conditional range of Δ′_j has length 2, so t = √(2L·ln(1/δ)) gives exactly δ. For a function Σ_j Δ′_j ≥ μL surely. Each hypothesis is used: "exactly L calls" (the sum has L terms and the good set is defined through μL), (i) and (ii) at every history (the corrupted run reaches histories the human system does not), (iii) for all answers including ⊥. Exact check against the rule of Remark 12.3(ii) over a grid of 324 settings of (L, μ, D, η, δ), of which 177 allow some k by (12.1) (`rehearsal-core_check_v1.py`, part 1): the largest quotient (exact failure)/δ at the largest admissible k is 0.19. The constant 2 cannot be lowered much: with √(1.5·L·ln(1/δ)) the same rule fails with probability 2δ at δ = 10⁻⁸ (L = 3200, μ = 0.3, D = 0, η = 1), and with √(L·ln(1/δ)) with probability 391·δ.

**Remarks 12.3. CORRECT.** (i): the note's constant 8 is what the two-sided form "differences bounded by 2 in absolute value" gives; the condition of the note implies (12.1). (ii): the kernel C with C(d|x₀) = (1 − μ)/2, C(b|x₀) = (1 + μ)/2 has the maximal coupling that sends u to b and d to d, so κ_C replaces exactly the human's good answers; failure probabilities 0.489 and 0.978 recomputed. (iii): (1 + D)·K ln 2/(η·μ·n) for a deterministic human; for the other case L ≥ 8·ln(1/δ)/(η·μ)² is exactly the condition √(2L·ln(1/δ)) ≤ η·μ·L/2, and the failure is δ + 2(1 + D)·√(K ln 2/(2n))/(η·μ).

## I. Section 13 (Theorem V1)

**Definition 13.0 and Theorem 13.1(o). CORRECT.** Given A the rounds are independent and identically distributed.

**Theorem 13.1(a), (a1), (a2), (a3). CORRECT.** Pr[d_i = 1] = E[N]/L because J_i is uniform on {1, …, L} and independent of the run, and a round with J_i > len counts as no disagreement. (a2): the Chernoff bound Pr[ρ̂ ≤ ρ − t] ≤ exp(−m·t²/(2ρ)) and the solution of the quadratic inequality were recomputed; exact binomial coverage (part 2 of the script): the worst miscoverage is 0.036 for δ = 0.2 and 0.0024 for δ = 0.05. (a3): for a deterministic human N is a function of the run, so E[N] = β(A′) for the answerer A′ given by the conditional answer laws of A, and Theorems 7.1(a), 8.4 and 8.6 are statements about run laws. One addition to (a3): an imitator that draws one kernel per run (for example the mixture of a fresh round) needs tolerance against 𝓡_bst only, by Theorem 8.4(a) applied conditionally on the kernel drawn.

**A strengthening of (a) that the file misses (and that corrects a sentence of (c)).** For every human P satisfying H1 and every frozen A, the probability of a recorded disagreement in a round is

  ρ′ := (1/L)·E_{Q_A} Σ_{j≤len} (1 − Σ_y A_j(y|h_j)·P(y|x_j)) ≥ (1/L)·E_{Q_A} Σ_{j≤len} TV(A_j(·|h_j), P(·|x_j)) = β(A)/L,

because a·p ≤ min(a, p) for a, p ∈ [0, 1]; there is equality if P or A is deterministic at the calls visited. (Given the run and J_i, the human's answer is a fresh draw from P(·|x_i) by H1, so the pair disagrees with probability 1 − P(y^A_i|x_i).) Hence the certificates (a1) and (a2), read as bounds on β(A)/L, are valid for every human: "no disagreement in m rounds, so β(A) ≤ L·ln(1/δ)/m" issues a false certificate with probability less than δ whatever the human is. For a human who is not deterministic the certificate is almost never issued (ρ′ ≥ (1/L)·E Σ_j (1 − max_y P(y|x_j))), which is the true limitation. Checked exactly on 300 random instances (part 3 of the script): L·ρ′ − β(A) ≥ 0 always, and = 0 for deterministic A.

**Theorem 13.1(b), (b1), (b2), (b3). CORRECT.** g_i(B) ∈ {−1, 0, 1} has mean Δ(B) and range of length 2; Hoeffding gives 2·exp(−m·t²/2); the union bound uses Σ_B π(B) ≤ 1. (b2): (1 − a)^m ≤ e^(−am). (b3): a(S) − p(S) ≤ TV(a, p) with equality at S = {a > p}; the set {ν : w(ν) ≥ 2^(−K₀)} is finite, so the maximum exists. Exact checks: (b1) for one test by the law of Σ_i g_i (part 5); (b3) on 100 random kernels by enumerating all 512 tests (part 4): max_B Δ(B) = Δ(B_P) = β(A)/L to rounding.

**Theorem 13.1(c). MINOR (two sentences claim more than is true or proved).**
(1) "The rate of recorded disagreement says nothing about faithfulness." By the display above it is an upper bound on β(A)/L for every human. The correct sentence: it is an upper bound on β(A)/L that is not small for a human who is not deterministic, even for A = P.
(2) "No finite family of tests bounds the number of unfaithful calls without an assumption on P." The mathematical statement that follows it is correct, but its order of quantifiers (first the family, then P and A) is not that of part (b), where the family may depend on A. With the family allowed to depend on A the sentence is false for an imitator that is a function a: the single test B_a := {(x, a(x))} (the graph of A) has Δ(B_a) = (1/L)·E Σ_j (1 − P(a(x_j)|x_j)) = β(A)/L for every human P (verified, part 4). *Fix.* Say "no finite family of tests fixed without regard to A"; and replace the gloss by a statement that does not refer to tests, which is also the lower bound that the sentence "only frequencies of tests can be estimated" of `note.md` needs (outline, Addendum 2, item 5):

 *(c′) Two humans that validation cannot tell apart.* Let α be a distribution on Y that is not a point mass, c_α := 1 − Σ_y α(y)² > 0, X₀ a set of N inputs, the scaffold one call (L = 1) at a uniformly drawn input of X₀, and A the kernel with A(·|x) = α for x ∈ X₀. For a function p: X₀ → Y let P_p be the deterministic human p; then β(A) = b(p) := (1/N)·Σ_x (1 − α(p(x))) against P_p, and β(A) = 0 against the human P = A. Let a procedure put at most m questions to the human, each at an independently and uniformly drawn input of X₀ (validation in the sense of Definition 13.0 is such a procedure), and then issue or not issue the certificate "β(A) ≤ B", where B < c_α. If it issues a false certificate with probability at most δ for every human, then against the human P = A, for whom the certificate is true, it issues it with probability at most δ + m(m − 1)/(2N) + exp(−2N·(c_α − B)²).

 *Proof.* Draw p with independent coordinates p(x) ~ α. As long as no input is asked twice, each answer of P_p is, given the past, a draw from α; so the transcript under the mixture over p and the transcript under P = A have the same law up to the first repeated input, and Pr_A[issue] ≤ E_p Pr_{P_p}[issue] + Pr[some input is asked twice] ≤ E_p Pr_{P_p}[issue] + m(m − 1)/(2N). For p with b(p) > B the certificate is false, so Pr_{P_p}[issue] ≤ δ; and Pr_p[b(p) ≤ B] ≤ exp(−2N·(c_α − B)²) by Lemma 12.1 of the proof file (Hoeffding's inequality, proved there), because b(p) is a mean of N independent variables in [0, 1] with expectation c_α. The bound m(m − 1)/(2N) is the union bound over the pairs of questions. ∎

 So without A2 a randomised imitator of a human who is not deterministic cannot be certified faithful by single answers unless inputs repeat, however good it is; with A2 the functions p are excluded by their description length (about N times the entropy of α in bits for a typical p), which is why (b3) is possible.

**Corollary 13.2. MINOR (wording).** The computation is correct (Pr[some disagreement | A] ≤ m·ρ(A) and E ρ(M^(T)) ≤ ln(W/w(f))/n). The last clause, "whenever it is issued it is false with probability less than δ", is not what (a1) proves and is false as a conditional statement: if the rehearsal always yields an imitator with ρ slightly above ln(1/δ)/m (which can happen when f ∉ H), every issued certificate is false. *Fix.* "…and, whatever A is and whether or not f ∈ H, the probability that a false certificate is issued is less than δ."

**Remarks 13.3. CORRECT.** (ii): E[N/len] ≥ E[N]/L. (iii): the price of a test is ln(1/π(B)), fixed before validation. (v): union bound.

## J. Sections 14, 15 and 17 of the proof file

**Section 14 (open questions).** Consistent with what is proved. Item 1 correctly lists as open whether the example of Proposition 6.3 can be built from functions only.

**Section 15 (remarks on other files).** I checked each of the eleven remarks on `note.md` against the note and agree with all of them; my own list for the note is in part K. The remark on `research/prove/lower-bounds.md` is correct: Theorem 6.1 there has (θ/2)·(1 − θ·√(8n/K)), obtained from "θ times the indicator of a wrong sign"; the triangle inequality gives θ·(1 − θ·√(8n/K)), which in the case K = 1 is exactly the Bayes risk θ·(1 − TV(𝐏₊, 𝐏₋)) before Pinsker's inequality is applied, so the doubled constant is safe. The remarks on the candidate theory are correct (L3 there has Π_t (1 − e_t) ≥ w(f), which follows from ≥ w(f)/W).

**Section 17 (literature).** Not my role to check in the sources (the adversary does). Two points for the editor: the entry on the regret bound should follow the outline, Addendum 2, item 2 (Hutter 2003, Theorem 1, for the divergence form on countable classes; Solomonoff 2008 for question–answer pairs; Paper 1, Proposition 5.7(b), for the per-query mixture, and not Theorem 5.3, which is about the one-tape version); and the file says honestly that the paper of Li and Zhang was not read in this session.

## K. Sections 1 to 3 of `note.md`, checked against the proof file

The numbered statements of the note are correct once two hypotheses are written into them (R3a: every run has exactly L calls, without which the statement is false for scaffolds whose runs can stop early; V1: the answerer is frozen, as the protocol of Section 2 says and the theorem does not). The following must be changed for the statements to say exactly what is proved; items marked (P) are already in Section 15 of the proof file, the others are additions.

**Section 1 (model).**
* "Faithful calls": "the run of the imitator is then a run of the human system in which the answers at the unfaithful calls were replaced" is true in the sense of Definition 3.3 and Proposition 3.4 (the later human answers are fresh answers to the inputs of the changed run) and is the run on the same (z, ρ) with entries overwritten only for a deterministic human (P). The formula TV(A(·|x_j), P(·|x_j)) presupposes an imitator that is a kernel; for an imitator that looks at the history it is TV(A_j(·|h_j), P(·|x_j)).
* A3: "not predictable by any hypothesis" is automatic for hypotheses that are functions of the input (P). What the proofs use is H1 (Assumption 1.6) and that J is drawn after the run, independently of it.
* The class is a class of samplers. If the note wants the class of all programs, hypotheses are semimeasures and the mixture can give no answer; the proof file covers this (Definition 1.1, Remark 4.4(b)), and the note should say in one sentence which of the two it means.

**Section 2 (protocol).**
* Validate: add "if the run made at least J calls" as in the rehearsal step; say that A is frozen (P); the note already records "the answer A gave in the run", which is what the proof needs; "the human answers n + m single calls" should be "at most n + m".
* Deploy: "draw T uniformly and deploy M^(T)" must say that one round is drawn for a whole run, or once for good; drawing a round at every call is a different imitator (Proposition 5.5) (P).
* Attribution: credit Li and Zhang for this form of the protocol, as the outline (Addendum 2, item 1) requires (P).

**Theorem R1. Statement CORRECT; proof MINOR** (the statement is Theorem 5.1(a), (c), Proposition 5.2(a) and Theorem 7.1(b)). In the proof: the telescoping identity holds with the factor 1/W on the right, and the inequality that follows is correct because W ≤ 1 (P); "on every path" should be "almost surely" for a human who is not deterministic (P); the integrability of the summands must be shown before expectations are taken (Lemma 4.1(ii)) (P). "Is a run of the human system with probability at least 1 − L·K ln 2/n" should read "is the run of the human system on the same z and ρ".
* First remark after R1: "an expected factor that depends on ρ only" is exact only for a hypothesis and a human that are both functions (then a question refutes the hypothesis with probability equal to the frequency of disagreement among the calls of the rehearsal run, per L calls) (P).
* Third remark: "they have the same distribution" is true round by round: given the data before round t, the question of round t is a uniformly chosen call of a run of M^(t), and the deployed run for T = t is another run of the same kernel (P).
* The citation of the regret bound should follow the outline, Addendum 2, item 2.

**Section 3.2, first sentence.** "A run of L calls is entirely faithful with probability 1 − L·K ln 2/n": add "at least" and "for a deterministic human".

**Theorem R3. CORRECT** (Theorem 8.4(b), (c)). The note's definition of tolerance is tolerance against 𝓡_all; for imitators that are kernels the weaker tolerance against budgeted stateless rules suffices (P). "m = θL" must be an integer with m + 1 ≥ θL (for example m = ⌊θL⌋). The sentence for a human who is not deterministic is Proposition 9.1 (it needs the Cauchy–Schwarz inequality besides Pinsker's) (P). The letter m is used for the number of tolerated faults here and for the number of validation rounds in Section 3.3 (P).

**Proposition R3a. CORRECT, with a conservative constant** (Proposition 12.2 has √(2L·ln(1/δ)) where the note has √(8L·ln(1/δ)); the note's condition implies the sharper one). The statement must say that every run has exactly L calls, and that "from every state" includes the states reached after replaced answers (P). The sentence after it ("the number of questions needed … is about K ln 2·(1 + D)/(η·μ·δ′)") is for a deterministic human, for whom the square-root term is not needed at all; for a human who is not deterministic the corresponding number is 2(1 + D)²·K ln 2/((η·μ)²·δ′²) once L ≥ 8·ln(1/δ)/(η·μ)² (Remark 12.3(iii)); both are independent of L.

**Theorem V1. CORRECT** (Theorem 13.1(a1), (a3), (b1)), with these precisions.
* "Any answerer" must be a frozen answerer (P); "m questions" should be "m rounds" (a round whose run is shorter than the drawn index asks nothing and counts as a round without disagreement) (P); the "recorded frequencies" of (b) are counts divided by m.
* (a) can be stated for every human: the rate of recorded disagreement is at least β(A)/L whatever the human is (part I above), so "no disagreement, hence at most L·ln(1/δ)/m unfaithful calls in expectation" is a valid certificate without the assumption that the human is deterministic. Determinism of the human (or of A) is what makes the rate equal to β(A)/L, so that a good imitator passes.
* "With confidence 1 − δ" means: an imitator for which the claim is false passes with probability less than δ. The note should say this once; it is not a probability statement about the imitator.
* "Theorem R3 applies with β = L·ln(1/δ)/m": yes, with tolerance against the kind of rule that A induces (all rules if A looks at the history) (P).
* Last paragraph: "No number of single answers at inputs that never repeat reveals the distribution P(·|x) at any one input; only frequencies of tests can be estimated." The proof file's 13.1(c) does not yet support this as stated; statement (c′) of part I does, and (b3) says what A2 adds. Without A2 the correct summary is: for a human who is not deterministic, validation bounds every Δ(B) of a family fixed in advance, it bounds β(A) from above by the rate of disagreement (useless unless the human is nearly deterministic), and it cannot certify β(A) small for a randomised imitator.

## L. Numerical checks made for this report

Scripts and their saved outputs are in `research/verify/code/`, names `rehearsal-core_check_*.py` and `.out`. All are exact computations (enumeration, forward recursions, binomial laws); where instances are random they are drawn with a fixed seed and then evaluated exactly. None uses the prover's code.

| script | what it checks | result |
|---|---|---|
| `rehearsal-core_check_constants.py` | every numerical constant of the proof file (Sections 0, 5.2, 5.5, 6.2, 6.3, 6.4, 9.2, 10.3, 12, 13) | all confirmed except the rounding slip 0.23881 in Proposition 6.3 (the script prints FAIL on that one line and "SOME CONSTANT FAILED" at the end for this reason; with 0.23882 everything holds) |
| `rehearsal-core_check_r1.py` | Theorem 5.1(a) to (c), Lemma 4.3, Proposition 9.1(a) by exact enumeration of Protocol R on a scaffold of horizon 3 with runs of length 0 to 3, inputs that depend on the answers (also on the answer ⊥), a repeated input, semimeasures, W < 1; the tightness example for 5.1(c) | all hold; Σ_t E Λ = L·Σ_t E[a_t κ_t] to rounding |
| `rehearsal-core_check_ladder.py` | Proposition 5.5 by an exact recursion (validated against brute force), p ∈ {0.1, 0.5, 0.9}, L up to 40, n up to 20·L³ | every inequality of the proposition that applies holds in all 54 cases |
| `rehearsal-core_check_lastround.py` | Proposition 6.1(a) on a second family; Propositions 6.2 and 6.3 by independent exact recursions; Proposition 6.4 evaluated on those examples | all hold; the prover's values are reproduced |
| `rehearsal-core_check_sweep.py` | inequality (6.1) of Proposition 6.3 for 400 random parameter settings (2 ≤ L ≤ 40, L ≤ n ≤ 60·L, 1 ≤ N ≤ 25, 0 < λ ≤ 12) and Proposition 6.2 for 200 random (L, n) with n ≥ L, by the same exact recursions | no violation; the exact value is at least 1.99 times the right side of (6.1), and at least 1.18 times the bound of 6.2 |
| `rehearsal-core_check_lowstakes.py` | Theorem 8.4 for history-dependent answerers; Theorem 8.6 for random rules in 𝓡_all; 8.3(d); Example 8.5(c); Theorem 9.2 against one protocol; the counterexample to 9.3(ii) for γ > ½ | all hold |
| `rehearsal-core_check_blind.py` | the assertion of Remark (ii) after Theorem 8.4 | confirmed by an example with D = 3; no gap for D = 1, as the analysis predicts |
| `rehearsal-core_check_online.py` | Theorem 10.1, Corollary 10.2, Proposition 10.3 by exact enumeration of the online form and of the shadow variant | all hold |
| `rehearsal-core_check_v1.py` | Proposition 12.2 against the rule of Remark 12.3(ii); Theorem 13.1(a2), (b1), (b3); the inequality "rate of disagreement ≥ β(A)/L" for every human; the single test for a deterministic imitator | all hold |

*Reproduction of the prover's outputs.* I ran the prover's seven scripts `research/prove-c/code/rehearsal-core_*.py` again, writing to a scratch directory and leaving the saved files untouched. All seven outputs are identical, byte for byte, to the saved `.out` files (run times between 1 and 142 seconds). All 43 output lines quoted in Section 16 of the proof file occur in the saved `.out` files (one of them with an added annotation).

## M. Corrections that must be made, in order of importance

1. **What validation certifies for a human who is not deterministic (Theorem 13.1(c); last paragraph of Section 3.3 of the note).** (i) Replace "the rate of recorded disagreement says nothing about faithfulness" by: it is at least β(A)/L for every human, with equality if the human or the imitator is deterministic at the calls visited; so certificates (a1) and (a2) are valid for every human as bounds on β(A), and are informative only if the human is nearly deterministic. (ii) In "no finite family of tests bounds the number of unfaithful calls without an assumption on P", add "fixed without regard to A": for an imitator that is a function, the one test "graph of A" measures β(A)/L exactly for every human. (iii) Put statement (c′) of part I (two humans that validation cannot tell apart) in place of the gloss; it is the lower bound that the note's sentence "only frequencies of tests can be estimated" needs.
2. **Hypotheses that must be written into the statements of the note.** (i) Proposition R3a: every run has exactly L calls; without this the statement is false for a scaffold whose runs can stop early (the human system itself then fails to raise φ by (1 − η)·μL). (ii) Theorem V1: "any answerer" must be "any frozen answerer" (fixed before validation, with fresh private coins in every run, and the same at deployment), as the protocol of Section 2 already says. (iii) Deployment: one round is drawn for a whole run, or once for good; with a new round at every call the run can be unfaithful with a probability of the order of L times larger (Proposition 5.5).
3. **Scope of the negative result on the last round (Proposition 6.3 and every summary of it: "In brief" (3), the introduction of Section 6, Section 11, and the note).** The class of the example contains samplers that are not functions. Say "for a deterministic human in a class that may contain samplers that are not functions"; for classes of functions the question is open.
4. **Corollary 13.2, last clause; and "with confidence 1 − δ" in the note.** Write "the probability that a false certificate is issued is less than δ, whatever A is"; do not write that an issued certificate is false with probability less than δ.
5. **Proposition 9.3(ii).** Add the hypothesis γ ≤ ½; without it the stated conclusion is false.
6. **Theorem 5.1(d) and the entry "(d) equality is attained" of the summary table.** Equality is attained in (a). For (c) the two-function example gives L·(1 − w), not L·ln(1/w). Restrict the claim to (a), or add the example of part B (N one-point alternatives), in which Σ_t E β(M^(t)) tends to L·ln(1/w).
7. **Proposition 5.2(d).** State the range: the conclusion φ(δ) ≥ 0.45/δ is shown for δ ≤ 0.63 (for bounds that are to hold for all n).
8. **Proposition 6.4.** Say after the statement that the bound exceeds 1 unless n exceeds 2L²·K ln 2 by a factor of about ln L + 3, so that "2·B₀ < 1" is not the range in which the statement has content. In Remark (ii) replace "between 1 and" by "between a constant and".
9. **Proposition 8.3.** (c): write δ̄_Π(min{L, ·}). (d): add L ≥ 2 and 0 < ε < 1.
10. **Remark (ii) after Theorem 8.4.** Either delete the last sentence or support it by the example of part E, which needs D > 1 in the family of Remark 12.3(ii). In Remark 12.3(ii) one clause may be added: a rule that does not see the current answer but counts its replacements can lose max{2, μ + D} per replacement.
11. **Proposition 6.3, "The numbers".** Replace "ā/N ≤ 0.23881" by "ā/N ≤ 0.23882".
12. **Wording of Proposition 5.5 in "In brief" (2) and Section 15, item 1.** "A probability L times larger" should be "a probability of the order of L times larger (at most L times; about L/2 in the ladder with small p)".
13. **Proposition 5.2(c).** Add the direct form β(M^(T)) ≤ L·ln(W/w(f))/(n·δ) with probability 1 − δ, which is stronger than the two-parameter form for δ = δ₁ + δ₂; keep the latter only as a statement about the fraction of bad rounds.
14. **Small points.** Proposition 9.3: "L odd" is not used. Proposition 10.3: the case q = 1 (L = 1) holds trivially and may be included. Example 8.5(a): tightness is shown for δ = 0. Section 17: bring the entry on the regret bound into line with the outline, Addendum 2, item 2.
15. **The other changes to `note.md`, Sections 1 to 3,** listed in part K: "if the run made at least J calls" and "rounds" in validation; at most n + m questions; the factor 1/W, "almost surely" and integrability in the proof of R1; the two remarks after R1; "the run of the human system on the same z and ρ"; "at least" and "for a deterministic human" in the first sentence of 3.2; integer m and the double use of the letter m; the constant 2 in R3a; the certificate of V1(a) for every human; credit to Li and Zhang and the citation of the regret bound.

## N. Table of verdicts

| statement | verdict | reason in one line |
|---|---|---|
| Section 0, (E1), (E2) | CORRECT | elementary |
| Definition 1.2, (1.1); Definition 1.5 (relations between Λ, β, χ) | CORRECT | recomputed |
| Lemma 2.1 (L1, chain rule) | CORRECT | all cases, infinite values and variable length covered |
| Lemma 3.1 (maximal coupling) | CORRECT | row sums recomputed |
| Lemma 3.2 (L2) | CORRECT | the continuation of the second run has the right conditional law |
| Proposition 3.4 (sense of "unfaithful calls replaced") | CORRECT | κ_C is the conditional law of the maximal coupling |
| Lemma 4.1 (L3) | CORRECT | telescoping with the factor W; integrability shown |
| Lemma 4.2 (L3 for a function) | CORRECT | pathwise |
| Lemma 4.3 (high-probability forms) | CORRECT | exponential martingale; checked exactly |
| Remark 4.4 | CORRECT | normalisation does not increase KL, TV, H² |
| Theorem 5.1(a), (b), (c) (R1) | CORRECT | exact enumeration agrees |
| Theorem 5.1(d) | MINOR | equality shown for (a) only; for (c) the example gives L(1 − w); an example approaching L·ln(1/w) is supplied |
| Proposition 5.2(a), (b) | CORRECT | constants recomputed |
| Proposition 5.2(c) | CORRECT | the second form is weaker than Markov's inequality applied directly; add the direct form |
| Proposition 5.2(d) | MINOR | the conclusion holds for δ ≤ 0.63; state the range |
| Proposition 5.3 | CORRECT | first question of each round carries the bound |
| Proposition 5.5(a), (b) | CORRECT | exact recursion confirms; the summaries should say "of the order of L", not "L times" |
| Proposition 6.1(a), (b) | CORRECT | integrals recomputed |
| Proposition 6.2 | CORRECT | all constants recomputed; exact values reproduced |
| Proposition 6.3 | MINOR | 0.23881 must be 0.23882; the class of the example is not a class of functions, which the summaries omit |
| Proposition 6.4 | CORRECT | proof checked step by step; say that the bound exceeds 1 unless n exceeds 2L²·K ln 2 by a factor of about ln L + 3 |
| Theorem 7.1 (R2 for a function) | CORRECT | TV(Q_C, Q_f) = u(C) |
| Proposition 8.3(a), (b) | CORRECT | Jensen for the concave majorant |
| Proposition 8.3(c) | MINOR | argument of δ̄_Π can exceed L; write min{L, ·} |
| Proposition 8.3(d) | MINOR | needs L ≥ 2 and 0 < ε < 1 |
| Theorem 8.4 (R3) | CORRECT | coupling checked call by call; exact check with history-dependent answerers |
| Remark (ii) after Theorem 8.4 | GAP (filled) | asserted without proof; true (the example needs answers worse than the human's worst, D > 1); example and computation supplied |
| Example 8.5 | CORRECT | (c) is attained exactly |
| Theorem 8.6 (recoverable form) | CORRECT | exact check with random rules |
| Proposition 9.1 | CORRECT | Pinsker and two uses of Cauchy–Schwarz |
| Theorem 9.2 | CORRECT | constant 1/(8√2) recomputed; equals the Bayes risk before Pinsker for K = 1 |
| Proposition 9.3(i), (iii) | CORRECT | "L odd" is not used |
| Proposition 9.3(ii) | MINOR | false for γ > ½ as stated; add γ ≤ ½ |
| Theorem 10.1, Corollary 10.2 | CORRECT | exact enumeration agrees |
| Proposition 10.3 | CORRECT | factors 4/3, 1.582 and e recomputed |
| Section 11, Remarks (i) to (iii) | CORRECT | with the qualification on 6.3 |
| Lemma 12.1 (Azuma–Hoeffding) | CORRECT | proof complete |
| Proposition 12.2 (R3a) | CORRECT | constant 2 confirmed; cannot be lowered to 1.5 |
| Remarks 12.3 | CORRECT | numbers recomputed |
| Theorem 13.1(o), (a), (a1), (a2), (a3) | CORRECT | (a1), (a2) hold for every human as bounds on β(A) (addition) |
| Theorem 13.1(b), (b1), (b2), (b3) | CORRECT | Hoeffding and union bound |
| Theorem 13.1(c) | MINOR | two glosses say more than is proved; fix and replacement (c′) supplied |
| Corollary 13.2 | MINOR | last clause must read "a false certificate is issued with probability less than δ" |
| Remarks 13.3 | CORRECT | |
| `note.md`, Sections 1 and 2 (model, protocol) | MINOR | frozen imitator; "if the run made at least J calls"; one round per run in deployment; at most n + m questions |
| `note.md`, Theorem R1 | MINOR | statement correct; in the proof the telescoping identity lacks the factor 1/W (the inequality stands), "on every path" must be "almost surely", integrability must be shown; two remarks after it are inexact |
| `note.md`, Theorem R3 | CORRECT | integer m; the letter m is used twice |
| `note.md`, Proposition R3a | MINOR | must assume that every run has exactly L calls; the constant 8 can be 2 |
| `note.md`, Theorem V1 | MINOR | A must be frozen; "rounds", not "questions"; meaning of "confidence"; the last paragraph needs (c′) |
