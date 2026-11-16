# property-online: line-by-line check

Referee report on `research/prove-c/property-online.md` (Sections 0 to 10) and, against it, on Sections 8.3 and 8.4 of `note.md` (Theorem Pr5, its rehearsal corollary, and the bullets of "What this does not give"). Role: referee, line by line. Verdicts: **CORRECT**; **MINOR** (correct after a small fix, which is given); **GAP** (a step is missing; it is named, and filled where I could); **WRONG** (the failing step, a counterexample, and the strongest true replacement). A statement I did not check is listed as **NOT CHECKED**.

*Status: complete.*

**Note on the scripts.** An earlier verifier with this role was cut off before writing more than a stub of this report, but left five scripts with saved outputs in `verification/code/` (`property-online_check_potentials.py`, `_check_game.py`, `_check_ex23.py`, `_check_rehearsal.py`, `_check_tilt.py`, each with its `.out`). I read each script's relevant part before relying on it, and re-ran the ones named below. Where I cite one of these outputs I say which part of it supports which step. Scripts written in this session are named `property-online_check2_*.py`.

---

## Part A. note.md, Section 8.3: the lead's Theorem Pr5 and corollary (checked first, independently of the proof file)

**A.1 Theorem Pr5 (note.md 8.3). Verdict: CORRECT (with two wording fixes, MINOR).**
Checked step by step. (i) For g ∈ {−1, 0, 1}: cosh(η(S + g)) = cosh(ηS)cosh(ηg) + sinh(ηS)sinh(ηg); for g = ±1 this is cosh(η)cosh(ηS) + g·sinh(η)sinh(ηS) (equality), for g = 0 it is cosh(ηS) ≤ cosh(η)cosh(ηS). (ii) Multiplying by π(B) and summing is legitimate: Φ_{t−1} < ∞ by induction and |sinh| ≤ cosh, so all series converge absolutely. (iii) Σ_B π(B) sinh(ηS_{t−1}(B)) g_t(B) = F_t(x_t, a_t(x_t)) − F_t(x_t, y_t) ≤ 0, because a_t(x_t) minimises F_t(x_t, ·) over Y and y_t ∈ Y; a minimiser exists because Y is finite (ties: any choice works). (iv) Φ_n ≤ cosh(η)^n Φ_0 ≤ e^(nη²/2) (Φ_0 = Σπ ≤ 1; cosh η ≤ e^(η²/2)). (v) π(B)e^(η|S_n|)/2 ≤ π(B)cosh(ηS_n) ≤ Φ_n. Taking logarithms: |S_n(B)| ≤ ln(2/π(B))/η + nη/2. With η = 1/√n: √n(ln(2/π(B)) + 1/2). Recomputed; right.
Hypotheses: Y finite is used only for the existence of a minimiser; the adaptivity of x_t and y_t to a_t is harmless because the bound is deterministic. Nothing about the human is used. Edge cases: n = 0 trivial; void rounds are not in the lead's statement but would give g = 0 and are covered by the g = 0 case.
Fixes (wording): (1) "for every n ... which is √n(ln(2/π(B)) + 1/2) for η = 1/√n" — the second bound holds at the single horizon n for which η was tuned; the sentence should say "for a horizon n fixed in advance, η = 1/√n gives ...". (2) The sentence "the rule produces, at each question, an answer with the properties that the human's answers have had more often than its own" is a heuristic description and should be marked as such; the theorem says nothing about a single round.

**A.2 Corollary (rehearsal with the property imitator; note.md 8.3).** Entered after Section 6 of the proof file is checked (entry 6.2 below), because the protocol details (how the asked call is chosen when a run has fewer than L calls; what is assumed of the human) are fixed only there.

---

## Part B. The proof file, statement by statement

### Section 1

**Definition 1.1, notation (Section 0).** Consistent; nothing to check. The rule a_t is a function of rounds 1, …, t − 1 only; x_t, y_t may depend on a_t. Void rounds give g = 0.

**Lemma 1.3 (balancing lemma). CORRECT.** |F_t| ≤ C_{t−1} because 0 ≤ b_B ≤ 1 and Σπ ≤ 1; Ψ_t ≤ Ψ_{t−1} + Σπ c g by (1.1); all three series converge absolutely (Ψ_{t−1} < ∞ by induction, |c| ≤ C_{t−1}); the last sum equals F_t(x_t, a_t(x_t)) − F_t(x_t, y_t) ≤ ε_t since y_t ∈ Y; u ≥ 0 gives π(B)u(γ_n(B)) ≤ Ψ_n. The one hypothesis on the human that is used, y_t ∈ Y (the set the imitator minimises over), is stated in the remark after the proof and in Remark 2.2(5). The existence claim (finite Y, or finitely many score values at each x) is right.

**Lemma 1.4 (catalogue of potentials). CORRECT**, item by item.
(a) Dividing (1.3) by cosh(η)^(k+1) gives exactly the stated slope tanh(η)sinh(ηs)/cosh(η)^k; for g = 0 the clock still advances, and u(γ0) ≤ u(γ). C_k ≤ sinh(ηk) since |s| ≤ k.
(b) For g ≠ 0: cosh(η(s+g))e^(−(v+1)η²/2) ≤ (cosh η cosh ηs + g sinh η sinh ηs)e^(−(v+1)η²/2) and cosh(η)e^(−η²/2) ≤ 1; right. The second form (cosh(η)^v clock) holds with equality on {−1,0,1}; it is claimed only on {−1,0,1}, but it in fact also holds on [−1,1]: for g ≠ 0, g ↦ cosh(η(s+g))/cosh(η)^(v+1) is convex and its chord over [−1,1] is u(γ) + g·c(γ) (the endpoint cases are the equality). The numerical check agrees (`property-online_check_potentials.out`, lines "(not claimed)": minimum relative gap −3·10^(−61), i.e. zero). The restriction in the file is harmless and could be dropped.
(c) (1.4) recomputed: ∫(2π)^(−1/2)e^(ηs − (v+1)η²/2)dη = (v+1)^(−1/2)e^(s²/(2(v+1))). Slope: sinh η sinh ηs = (cosh η(s+1) − cosh η(s−1))/2 and ∫cosh(ηa)e^(−(v+1)η²/2)φ(η)dη = G_{v+1}(a); right. The direct check (convexity of G_{v+1}, then cosh η ≤ e^(η²/2) under the integral) is right and makes (c) independent of (f). C_k ≤ e^((k+1)/2): since |s| ≤ v ≤ k, (v+1)²/(2(v+2)) ≤ (k+1)/2; right.
(d) Halving: the four cases (v = 0; pure with g = 0, σ, −σ; impure) recomputed; equality holds.
(e) Products: exact identity; u > 0 because 0 < η < 1.
(f) Fubini; the integrability hypotheses are those needed.
Numerical confirmation: `property-online_check_potentials.out`, section "(1.1) for the potentials of Lemma 1.4" (60-digit arithmetic; minimum relative gaps of order 10^(−61), i.e. zero), and the halving identity on all sequences of length ≤ 9.

### Section 2

**Theorem 2.1 (= Pr5). CORRECT.** Rule of Pr5 = minimiser of the score of potential (a), since the factor tanh(η)/cosh(η)^(t−1) is the same for all B (all histories in round t have length t − 1). The intermediate bound (ln(2/π(B)) + n ln cosh η)/η is right. Extension to [0,1]-valued tests: (a) is a potential on [−1,1]; right. The prover's line-by-line check of the lead's proof agrees with mine (A.1), including the point that absolute convergence must be said when the family is infinite.

**Remarks 2.2. CORRECT.** (1) At time n with η = 1/√n₀ the bound is √n₀ ln(2/π) + n/(2√n₀): right. (2) Best single-test η = √(2 ln(2/π)/n) gives √(2n ln(2/π)): right. (3) Clock-v rule: cosh(ηS)e^(−Vη²/2) ≤ 1/π gives |S| ≤ ln(2/π)/η + ηV/2; for h = 0, S = V = N gives N(1 − η/2) ≤ ln(2/π)/η: recomputed, right. (4) Spencer: see Section 5.1 entry. (5) ⊥ example: right (the imitator's answer is never in B = X × {⊥}, the human's always is). (6) Right; Example 7.1 and Proposition 3.5 are checked below.

**Example 2.3 (rule of Pr5 has no fast one-sided rate). CORRECT, with one MINOR qualification.** I re-derived the trajectory by hand: round 2k − 1 (even question 2k) has scores (0, β sinh(η(k−1)), 0), least minimiser 0, human 2, books go from (k−1, 0) to (k−1, −1); round 2k (odd question) has scores (0, β sinh(η(k−1)) − δ sinh η, 0), strictly negative middle score iff k − 1 < N*, so the imitator answers 1, the human 0, books (k, 0). After 2N* every round has g = 0 (checked both parities, including the tie at an odd question when β sinh(ηN*) = δ sinh η, where the least minimiser 0 agrees with the human). So N_n(B) = min(⌊n/2⌋, N*). N* ≥ arcsinh(ηδ/β)/η from sinh η ≥ η; with η = 1/√n, δ = 1/2, β = 1/(2n): ηδ/β = √n, arcsinh(√n) ≥ ln(2√n) ≥ ½ ln n; and ⌊n/2⌋ ≥ ½√n ln n for every n ≥ 1 (`property-online_check_potentials.out`, last line before "all checks passed", checked to n = 2·10⁵; for larger n it follows from √n ≥ ln n + 1). β + δ ≤ 1 holds. Simulation: `property-online_check_ex23.out`, Part 1, count = formula for all listed (n, η, β, δ), and min over n ≤ 3000 of count − ½√n ln n = 0 (attained at n = 1).
Qualification: the example uses ties at the even questions (answers 0 and 2 both score 0 while S(D) = 0). With the greatest minimiser the imitator answers 1 never (`property-online_check_ex23.out`, Part 2). The statement says "the least answer among the minimisers", so it is correct as stated, and since Theorem 2.1 allows every minimiser it does refute "every rule of Pr5 has a fast one-sided rate". It does not show that every tie-breaking of Pr5 fails. Fix: in the summary and in Section 10.3 say "the rule of Pr5 with least-index tie-breaking can give ½√n ln n such answers", or add a third test that breaks the tie strictly (I did not construct one).

**Proposition 2.4 (decreasing rate). CORRECT.** A_t ≤ cosh(η_t)Σπ cosh(η_t S_{t−1}) by (1.3) and the rule with rate η_t; cosh(η_t S) ≤ cosh(η_{t−1}S) since η_t ≤ η_{t−1}; Π cosh η_t ≤ exp(Σc²/(2t)) ≤ exp((c²/2)(1 + ln n)); then divide by η_n = c/√n. Recomputed.

### Section 3.1

**Theorem 3.1 (Rule N). CORRECT.** G_{V}(S) ≤ (1 + E_n)/π(B) gives S²/(2(V+1)) ≤ ln((1+E_n)/π) + ½ ln(V+1), which is (3.1); the right side increases in V and V ≤ n gives (3.2). The comparison paragraph: ln 2 + 1/2 = 1.193; the crossing at n = 10⁶ is at π(B) = 0.0357 (`property-online_check_potentials.out`, "crossing"); right. The factor "at most √(ln(n+1))/1.19" is attained at Λ = 0 and is exact only up to the factor √((n+1)/n); negligible, but strictly the bound should carry it (MINOR, cosmetic).

**Corollary 3.2. CORRECT** (one cosmetic MINOR). (a) D² ≤ (2h + D + 1)W gives D ≤ W + √((2h+1)W) (I recomputed the quadratic); for N < h, V + 1 ≤ 2h. (b) h = 0 forces S = V = N; N²/(N+1) ≥ N − 1; ψ(N) = N − 1 − ln(N+1) is increasing; ψ(N₀) − 2Λ = 1 + ln(2Λ+4) − ln(2Λ + 3 + ln(2Λ+4)) > 0 since e(2Λ+4) > 2Λ + 3 + ln(2Λ+4). Right. Numerically: `property-online_check_potentials.out`, "Corollary 3.2(b)": the stated bound exceeds the largest N allowed by (3.1) by at least 0.98 over Λ ∈ [0, 200]. (c) symmetric. Cosmetic fix for (c): "the number of non-void rounds t ≤ n with (x_t, a_t(x_t)) ∉ B" (in a void round there is no x_t). 1.39 = 2 ln 2: right.

### Section 3.2

**Rule NH, Theorem 3.3. CORRECT.** ½G + ½u^H with slope ½c^N + ½c^H is a balancing potential on {−1,0,1} by (c), (d), (f) (the mixture is over a two-point measure, so (f) needs nothing). Lemma 1.3: ½G_V(S) + ½u^H ≤ 1/π, both terms ≥ 0. (i) G_V(S) ≤ 2/π gives S² ≤ (V+1)(2Λ + 2 ln 2 + ln(V+1)); 2 ln 2 = 1.3863 is rounded up to 1.39, so the displayed form is valid. (ii) u^H = 2^(V−1) ≤ 2/π gives V ≤ log₂(2/π) + 1 = K(B) + 2; recomputed. When the human never satisfies B, every non-zero increment is +1 and V = N; when always, V counts the rounds with the imitator outside B. The ε-version: Lemma 1.3 gives (1 + E_n)/π on the right; right. Edge cases: V = 0 trivial; the pure-history hypothesis is all that (ii) needs (no assumption that the human is a function).
Exhaustive check: `property-online_check_game.out`, Part A, rule "NH": over all adversaries (questions, answers, void rounds and tie-breaking) of length 5 to 9 on six small families, the largest ratio of |S_t| to the bound (i) is ≤ 0.61 and the potential never increases (max dΨ = 0); one-sided worst counts are ≤ the bound (e.g. 3 against K(B) + 2 = 5 for the m = 3 tables). Part B (n = 3000, four adversaries) gives ratios ≤ 0.50.

**Corollary 3.4. CORRECT.** Weights π₀/2 and w/2 sum to ≤ 1; B_f is never satisfied by a human y_t = f(x_t); Theorem 3.3(ii) with K(B_f) = K + 1 gives ≤ K + 3 rounds in which a_t(x_t) ∈ B_f, i.e. a_t(x_t) ≠ f(x_t); for B ∈ 𝓑₀ the complexity becomes log₂(1/π₀(B)) + 1. If a test appears in both families its weights add, which only helps. "In total" means over non-void rounds, for all n.

**Proposition 3.5 (lower bound). CORRECT.** For any deterministic imitator, y_t = 1 − a_t(t) and c*(t) = y_t: the human's pair is never in B_{c*}, the imitator's always; N_m = m = K(B_{c*}). Each question is asked once, so c* is a consistent function (a stateless deterministic human). `property-online_check_ex23.out`, Part 5, reproduces N_m = m for four rules, and the exhaustive search for Rule NH with ties given to the adversary finds largest one-sided count m (bound m + 2). Remark: the lower bound is for deterministic imitators (as all rules of the file are); for a randomised imitator the adversary could not know a_t in advance; not needed here.

### Section 3.3

**Proposition 3.6 (√n forced with √n tests). CORRECT.** (a) Increment identity: for y = 1 − a, g(B_k) = (2a − 1)x_k (checked for x_k = ±1). The greedy choice of signs keeps every partial sum of x_k S(k) in [−‖S‖∞, ‖S‖∞]: right. ‖S_t‖₂² = ‖S_{t−1}‖₂² + 2ε⟨x, S_{t−1}⟩ + d ≥ ‖S_{t−1}‖₂² + d − 2D; summed, n(d − 2D) ≤ ‖S_n‖₂² ≤ dD²; solving D² + (2n/d)D − n ≥ 0 gives D ≥ √(n + n²/d²) − n/d = √n/(√(1 + n/d²) + √n/d); for d ≥ √n, ≥ √n/(√2 + 1) = (√2 − 1)√n. (b) m_t = 1[y_t ≠ a_t(x_t)] is a fair coin independent of the past and of x_t (y_t uniform and independent of all before it); the conditional expectation step, E‖S_{t−1}‖∞ ≤ (E max_k S_{t−1}(k)²)^(1/2) ≤ D₂ and E‖S_n‖₂² ≤ dD₂² give dD₂² + nD₂ − nd/2 ≥ 0, so D₂ ≥ (√(n²/d² + 2n) − n/d)/2 = √n/(√(2 + n/d²) + √n/d) ≥ √n/(√3 + 1) = 0.366√n. Recomputed. The words "even against a stateless human" are right: the fair-coin human is stateless; the questions are chosen adaptively (they depend on a_t), which the statement says.

### Section 3.4

**Proposition 3.7 (grid of rates). CORRECT.** (3.3) from Lemma 1.3 with the ρ-mixture of potentials (b): ρ_i e^(η_i|S|)e^(−Vη_i²/2)/2 ≤ 1/π; right. With η* = √(2Λ₂/V) ≤ 1 and i = ⌈log₂(1/η*)⌉: η*/2 < η_i ≤ η*; Λ₂/η_i < √(2Λ₂V), η_iV/2 ≤ √(Λ₂V/2), total (3/√2)√(VΛ₂); i + 2 < ½log₂V + 3 (uses 2Λ₂ ≥ 2 ln 2 > 1); ln((i+1)(i+2))/η_i < 2 ln(i+2)·√2·√(V/Λ₂). All recomputed. The Remark on Chernov and Vovk is explicitly not relied upon; I did not check it (NOT CHECKED, not used).

**Proposition 3.8 (products / iProd). CORRECT.** Lemma 1.3 with the ρ′-mixture of (e): for each σ and i, Σ_t ln(1 + ση_ig_t) ≤ ln(2i(i+1)/π); ln(1+u) ≥ u − u² on [−1/2, ∞) (derivative u(1+2u)/(1+u), recomputed; `property-online_check_potentials.out` "min of ln(1+u) − (u − u²) on [−1/2, 5] : 0.0"); hence |S| ≤ ln(2i(i+1)/π)/η_i + η_iQ. i = 1: 2 ln(4/π) + Q/2. One-sided: g_t ∈ [0, 1] so Q ≤ S, and S ≤ 4 ln(4/π). Right.

### Section 4

**Proposition 4.1. CORRECT.** (a) Near-minimisers exist since |F_t| ≤ C_{t−1}; E_n < 1 so 1 + E_n < 2 and π → π/2 everywhere (for (ii) of Theorem 3.3 this is K(B) + 3, consistent with "K(B) + 1 in place of K(B)"). For the rule of Pr5 the ε is measured on the score with the true slopes of potential (a), which is the unnormalised score times tanh(η)/cosh(η)^(t−1) ≤ 1, so an ε-minimiser of the unnormalised score is also one of the true score. (b), (c): Lemma 1.3 uses the rule only through F_t(x_t, a_t(x_t)) ≤ F_t(x_t, y_t) + ε_t in non-void rounds; right. In (c) the books "so defined" omit rounds in which the human answered outside Y(x_t); the statement says this, so nothing more is claimed.

**Proposition 4.2 (computability). MINOR (a gap for tests with real values and clock-v potentials).** For set tests the proof is right; I recomputed the error budget: tail ≤ C_{t−1}2^(−j) ≤ 2^(−t)/6, approximation ≤ 2^(−t)/6, so the chosen y exceeds the true minimum by at most 4·2^(−t)/6 ≤ 2^(−t). Gap: the statement allows tests with values in [0,1] ("(k, x, y) ↦ b_{B_k}(x, y) is computable"), but the slopes of Lemma 1.4(b), (c), (d) and hence of Rules N and NH depend on v(γ), the number of non-zero increments, and whether a computable real g_t(B) = b(x_t, a_t(x_t)) − b(x_t, y_t) equals 0 is not decidable. So for real-valued tests "c(γ) is a computable real function of γ" fails for (b), (c), and Rule N. Fix: state Proposition 4.2 for set tests (or for tests whose values are rationals given exactly, so that g = 0 is decidable); for real-valued tests only the potentials (a) and (e), whose slopes are continuous in the entries of γ, qualify. Rule NH is for set tests anyway.

**Proposition 4.3 (truncation). CORRECT** (one MINOR wording point). c(∅) = 0 for all potentials of Lemma 1.4 (checked: (a), (b), (d), (e) obvious; (c) c^N(0, 0) = (G_1(1) − G_1(−1))/2 = 0). A test entering in round t is not in F′_t, which is consistent because its slope would be c(∅) = 0; its potential after the round is ≤ 1; so Ψ′_t ≤ Ψ′_{t−1} + Σ_{new} π + ε_t. Book difference ≤ t_k − 1. With M_t = 2^t − 1, t_k = ⌈log₂(k+1)⌉, so t_k − 1 < log₂(k+1) ≤ 1 + log₂k ≤ 1 + K(B_k) when kπ(B_k) ≤ 1 (non-increasing weights). Right. Note: with potential (a) the clock of a truncated test is its own age, so the truncated rule is not "sinh(ηS′) for all tests" but uses the slopes c(γ′); the statement is in terms of c, so this is consistent. Wording: in the paragraph after the proof, "each π(B_k) is a computable real" should read "the weights are computable reals, uniformly in k".

**Proposition 4.4 (no terminating rule for unbounded Y). CORRECT.** B is decidable (checking that y is a valid halting record of x). (a) With one test the score is c^N(S, V)·1[(x, y) ∈ B] with c^N of the sign of S and c^N(0, v) = 0; the case analysis keeps S ∈ {−1, 0, 1}; uses that the empty string is not a record (should be said as an assumption on the coding: records are non-empty; it is implicit in the definition of f). (b) If a total computable x ↦ a_t(x) put every halting x into B, halting would be decidable; so some halting x_t has a_t(x_t) ∉ B_{x_t}, while f(x_t) ∈ B. The sequence is defined adaptively and need not be computable; the statement claims only existence. Right. The oracle remark (Σ₁ patterns for finitely many tests) is right.

### Section 5 (literature)

**Proposition 5.1 (quadratic potential). CORRECT.** Recomputed: Σπ S_n² ≤ Σ_t Σ_B π g_t² ≤ n; middle terms = 2(F(a) − F(y)) ≤ 0.

**Proposition 5.2 (reduction to experts). CORRECT, with an edge case (MINOR).** Σ_{B,σ} w_t ℓ_t = −(score(a) − score(y)) ≥ 0, so the normalised loss of 𝔄 is ≥ 0 and σS_n = −Σ_t ℓ_t(B,σ) ≤ R_n(B,σ). Edge case: the normalised loss is undefined if all weights of a round are 0; the statement should require a positive total weight (or define the normalised loss as 0 then, which keeps the proof). The identification "Theorem 2.1 = exponential weights with prior π/2 on each signed test" checked: Σ_σ σ(π/2)e^(ησS) = π sinh(ηS), and the Hoeffding term for losses of range 2 is nη/2.

**Sections 5.1–5.6, relation to the literature.** The *exact relations* (the special case "human gives the other answer" is Spencer's balancing game; the target {0} satisfies Blackwell's condition trivially; tests of pairs are checking rules independent of the current prediction; Lemma 1.3 is defensive forecasting with an answer as the move; the potential is GJNPR's surrogate loss with one bucket) are correctly derived from the definitions as the file quotes them; I checked each derivation. The conclusion relevant to the note is right and should be applied: Sandroni, Smorodinsky and Vohra (2003) concern checking rules that look at the current forecast and are analogous, not the same; the statement Pr5 quantifies is the one for checking rules independent of the prediction (Lehrer 2001; Perchet's survey, Theorem 3.2). Literature spot checks done in this session are reported in the entry "Literature spot checks" below. Statements quoted by the prover from sources he marks "not read" or "memory" (Spencer 1977; Blackwell 1956; Hart and Mas-Colell; Cesa-Bianchi and Lugosi; Sandroni et al.; Lehrer; Foster et al. 2011; Foster and Kakade 2006; Littlestone; Robbins) are NOT CHECKED by me beyond what is said below.

### Section 6 (rehearsal corollary)

**Protocol and assumptions (6.1).** The property-rehearsal protocol is the note's rehearsal protocol (note.md Section 2: J uniform on {1, …, L}, void round if the run is shorter) with the rule in place of the mixture; deployment draws T afresh for each run. (H1) is A3, (H2) is A1 restricted to the asked calls. This matches the note.

**Lemma 6.1. CORRECT.** a_t is 𝔉_{t−1}-measurable; given (𝔉_{t−1}, z_t, ρ_t, J_t), E[g_t] = 1[J_t ≤ T_t](b_B(x_{J_t}, a_t(x_{J_t})) − (Pb_B)(x_{J_t})) by (H2); averaging over J_t uniform on {1, …, L} gives (1/L)Σ_{j≤T_t}; averaging over (z_t, ρ_t) gives d_B(a_t)/L. Second claim: g² = 1[exactly one of the two answers in B] ≤ b(a) + b(y). Right. The factor is 1/L, not 1/T, precisely because J is uniform on {1, …, L} and short runs give void rounds.

**Theorem 6.2. CORRECT.** (a) E S_n = (n/L)E Δ_n; Theorem 3.3(i) with V ≤ n gives L√((1 + 1/n)(2Λ + 1.39 + ln(n+1))/n); the rule of Pr5 gives L(ln(2/π) + 1/2)/√n, the lead's bound. Recomputed. (b) E|S| ≤ √((E V + 1)W) by Jensen; E V = Σ E g² ≤ n(p̄ + q̄) by Lemma 6.1; |p̄ − q̄| = |E S_n|/n; gives √((p̄ + q̄ + 1/n)W/n). Right. (c) If (Pb_B) ≡ 0 then y_t ∉ B a.s., the history is pure a.s., N_n = S_n ≤ K(B) + 2 a.s.; E N_n = Σ E n_B(a_t)/L; expected count per deployed run = (L/n)E N_n ≤ L(K(B) + 2)/n. Right; only the questions that can occur matter, so "(Pb_B)(x) = 0 for all x" can be weakened to "for all x that a run can ask". (d) B_f has K(B_f) = K + 1, so L(K + 3)/n; for a deterministic human a run with no differing call is a run of the human system with the same (z, ρ), and Pr[some call differs] ≤ E[number]. Right. The Rule N variants follow from Theorem 3.1 and Corollary 3.2(b) (a.s. h_n = 0). Exact enumeration: `property-online_check_rehearsal.out`, Part 1: Lemma 6.1 holds to 3·10^(−15) for three rules, n ≤ 14, six tests; all bounds hold with large room.
Wording (MINOR): in "What (c) and (d) say", "Example 2.3 shows that his rule can come within a factor 2 of this" — Example 2.3 is proved for a fixed order of questions, not under rehearsal, and the ratio of N*/n to the lead's bound is below 1/2 for every n (fixed order: 0.470 at n = 400, 0.481 at n = 10⁵, 0.4915 at n = 10¹², and below 1/2 for all n < 5000, `property-online_check2_misc.out`, Part 4; under rehearsal 0.474 and 0.479; it tends to 1/2 from below, since N* ≈ √n(ln 2 + ½ ln n) and the bound is √n(ln 4 + ln n + ½)). The simulation under rehearsal (`property-online_check_ex23.out`, Part 3: L = 1, parity a fair coin) gives exactly these ratios. Replace by: "comes within a factor of about 2 (Example 2.3; under rehearsal only by simulation, Section 9)".

**Theorem 6.3. CORRECT.** M_k is a martingale with increments in an interval of length 2; Hoeffding's lemma gives e^(θ²/2); λ = √(2n ln(2/(πδ))) gives failure probability π(B)δ; union over B; (n/L)Δ_n = S_n − M_n. The NH form: 2n ln(2/(πδ)) = n(2Λ + 2 ln(2/δ)); right. (6.2): e^(−x) ≤ 1 − (1 − e^(−1))x on [0, 1] (chord of a convex function), Ville/Markov for the non-negative supermartingale Z, N_n ≤ K(B) + 2; gives (e/(e − 1))L(K(B) + 2 + Λ(B) + ln(1/δ))/n, and e/(e − 1) = 1.58198 < 1.582. Right. Simulation: `property-online_check_rehearsal.out`, Part 2, (6.1) and (6.2) never violated (largest left/right 0.66).
The paragraph after the proof says "given the rehearsal the rate is 1/√n for two-sided tests whatever the rule". The upper bound is proved; the lower bound ("a term of this order is unavoidable") rests on a standard fact that the file says it does not prove. MINOR: mark that half of the sentence as unproved here (or cite a lower bound for estimating a Bernoulli mean from n samples, e.g. Le Cam's two-point method).

**Remarks 6.4. CORRECT.** (1) With kernels P_t determined by the past and y_t ∼ P_t(·|x_t), Lemma 6.1 holds with d_B computed from P_t; right. (5) Example recomputed: d_B(1,1,0) = 2/3 − 1/2 = 1/6, d_B(1,0,0) = −1/6; d_C = 1/3 − 1/3 = 0 for both rules; under the point mass at u the imitator always answers 1 against 1/2. The one-sided transfer under D′ with factor sup dD′/dD₀ is right (non-negative integrands). (6) Example recomputed: all slopes stay 0, ties to 1 give an answer in B at every run.

**Example 6.5 (one rule kept for good). CORRECT.** d_B(a) = ±1/2 for every rule; with one set test any of the sign-respecting rules (Pr5, N, NH) keeps S ∈ {−1, 0, 1}, so |E Δ_n| ≤ 1/n and, from (6.1) with π = 1, |Δ_n| ≤ (1 + √(2n ln(2/δ)))/n w.p. ≥ 1 − δ. Exact check: `property-online_check_rehearsal.out`, Part 3 (support of S_40 is [−1, 0]). The statement should name the rule ("any of the rules of Sections 2 and 3"); MINOR. This settles the lead's bullet "a fresh rule for each run" with an example: correct.

**Proposition 6.6 (quadratic rule, interior condition). CORRECT.** Each step recomputed: r_t² recursion and |r_t − r_{t−1}| ≤ 1; E[⟨S_{t−1}, g_t⟩_π | 𝔉] = −(1/L)E Σ m ≤ −μ₀r by (I); μ₀ ≤ 1 from m_x(S) ≤ Σπ|S| ≤ ‖S‖_π and T ≤ L; on r ≥ 1/μ₀, E r_t ≤ r − μ₀ + 1/(2r) ≤ r − μ₀/2; with λ = μ₀/(2e), e^u ≤ 1 + u + (e/2)u² for |u| ≤ 1 (since e − 2 ≤ e/2), giving ϱ = 1 − λμ₀/2 + eλ²/2 = 1 − μ₀²/(8e); on the complement e^(λr_t) ≤ e^((1+μ₀)/(2e)) ≤ e^(1/e); the recursion a_n ≤ ϱa_{n−1} + c with a_0 = 1 ≤ c/(1−ϱ) gives a_n ≤ c/(1 − ϱ) = 8e·e^(1/e)/μ₀²; then E r_n ≤ (1/λ)ln(...) = (2/μ₀)(1 + e ln(8e/μ₀²)). C(1/2) = 52.56 and C(0.0821) = 559.3 (`property-online_check_potentials.out`). Reading (i): μ₀ = 1/2 in Example 6.5 (m = |S|/2); right; the failure for one-sided tests is right. Note: (I) must hold uniformly over all rules a, a strong condition; the statement says so.

**A.2 (note.md 8.3) Corollary (rehearsal with the property imitator). Verdict: MINOR.** The bound is right and the proof is right in substance (it is Lemma 6.1 plus Theorem Pr5 at the tuned horizon n). Fixes: (1) The proof says "the asked call is a uniformly chosen call of the run of a_t, so the conditional expectation of g_t(B) is 1/L times the difference": with a call chosen uniformly among the run's own T calls the factor would be 1/T, not 1/L, and the statement would be false for runs of varying length. The protocol of note.md Section 2 (J uniform on {1, …, L}, void round if the run is shorter) gives 1/L; the proof should say "the asked call is the J-th call with J uniform on {1, …, L}, and the round is void if the run has fewer than J calls". (2) The corollary uses A1 for the asked calls and A3; it should say so, since the preceding paragraph says "nothing is assumed about the human: not A1, not A2", which is true of the theorem only. A2 is not used. (3) The bound uses η = 1/√n, so n must be fixed before rehearsal (or use Rule N/NH, Theorem 6.2(a)). (4) The closing sentence ("for a bad kind of answer that the human never gives, the imitator gives it at most (ln(2/π(B)) + 1/2)/√n of the time per call") is true per call slot (expected number per run divided by L) but far from the best: Rule NH gives (K(B) + 2)/n (Theorem 6.2(c)), and the rule of Pr5 does attain order √n·ln(1/π(B))/n with least-index tie-breaking (Example 2.3). "Per call" should read "per call slot (expected number per run divided by L)".

### Section 7 (limits; randomised version)

**Example 7.1. CORRECT.** Score c·1[y = 1] with c of the sign of S, independent of x; round 1 answers 0 (tie, least), human 1, S = −1; round 2 answers 1, human 0, S = 0; period 2. The imitator's answers are 0, 1, 0, 1, … against the human's 1, 0, 1, 0, …: differs every round. Holds for the rules of Pr5, N, NH with least-index ties (all slopes vanish at S = 0). Simulation: `property-online_check_ex23.out`, Part 4. The deployed law (1/n)Σδ_{a_t(x)} is the fair coin at every x (Section 7.4): right.

**Example 7.2. CORRECT** (wording MINOR). The first sentence is Proposition 3.5. "The two-sided frequency error of Theorem 3.1 ... is below ε only when n exceeds about 2Λ(B)/ε²" is a statement about the *bound*, not about the error; reword "the bound of Theorem 3.1 on the two-sided frequency error". The sentence "for a human who is not deterministic there is no such test of single pairs" is informal (no statement is proved); it should be marked as a remark.

**Proposition 7.3. CORRECT.** One rule gives the same answer to the same question; the human's two answers agree w.p. 1/2; the event "the two answers agree" has probabilities 1 and 1/2, so TV ≥ 1/2. The toy figures quoted (exact sums 0.90 against 0.90; exact root about 0.62 against 0.477 in the simulation, 0.478 = 0.9⁷ exactly) agree with `results/toy_property.out` (n = 64000: 0.8995, 0.6197 against 0.4773) and with Section 9.4 (0.571 at n = 8000 under Rule NH).

**Proposition 7.4 (continuation-value tests). CORRECT.** Step 1 (performance difference) recomputed: hybrids H_k, the state s_k has the same law under H_k and H_{k−1} (first k − 1 calls by a), the conditional outcomes are V^u(s_k, a(s_k)) and (PV^u)(s_k); telescoping gives Q_a(u) − Q_P(u) = E_{Q_a}Σ_{j≤T}(V^u(s_j, a(s_j)) − (PV^u)(s_j)). Step 2 is Lemma 6.1 for state tests (the human sees only x_J and answers by P under (H2)). Step 3: |g(V^u) − g(B)| ≤ 2ξ; dividing by n gives the stated bound with Theorem 3.1. Lemma 1.3 needs a countable family, not a countable state space: right. The example V^u(s_2, y) = 1[y = y_1], V^u(s_1, y) = 1/2 is right. Hypothesis to make explicit (MINOR): u must be a function of the run with values in [0, 1] and V^u must be defined for every state reachable under the rules a_t (it is, since P answers all later calls).

**Lemma 7.5 (tilt identity). CORRECT.** Recomputed both identities from Λ = ln(R/q) − ln Z on {R > 0}; the inequality ≤ ln(1/R(y|x)) uses q ≤ 1 and KL(q‖R) ≥ 0, which holds for a semimeasure R (KL(q‖R) ≥ −ln ΣR ≥ 0). KL(q‖R) ≤ osc for a probability R, and ≤ osc − ln ΣR for a semimeasure (the file says this). KL(P‖q) ≤ 2KL(P‖R) + osc²: from KL(P‖q) ≤ KL(P‖R) + osc·TV(P, q), Pinsker, and r ≤ a + √c ⇒ r² ≤ 2a² + 2c with a = osc/√2; recomputed. Numerical: `property-online_check_tilt.out`, Part 1 (20000 instances; the semimeasure correction term is needed, as stated).

**Theorem 7.6. CORRECT.** Σ|ω| ≤ tanh(η max|S̄|) < 1, so osc(Λ_t) ≤ β sinh η. (7.1): sinh η·Σπ sinh(ηS̄)ḡ = (Φ_{t−1}/β)((qΛ) − Λ(y)); recomputed. (i) bracket ≤ ℓ_t; cosh η + r ≤ e^(η²/2 + r); Φ_0 ≤ 1. (ii) Φ_{t−1}, ω_t, q_t and κ_t are ℌ_t-measurable; E[Φ_t | ℌ_t] ≤ Φ_{t−1}(cosh η + κ_t/β); M_t is a non-negative supermartingale for (ℌ_{t+1}); E ln Φ_n ≤ nη²/2 + EΣκ/β; Ville's inequality for the uniform-in-n version. The convention M_t := 0 when some κ_s = ∞ is consistent (the bound is then vacuous). (iii) from Lemma 7.5. Note: the guarantee concerns the *expected* books S̄ (expectation over the imitator's own draw), which the statement says. Numerical: `property-online_check_tilt.out`, Part 2: (i) and (iii) hold on every path, the one-step inequality holds with room, for four bases including a semimeasure and a time-varying base.

**Corollary 7.7. CORRECT.** (a) As Lemma 6.1, with E[b_B(x_j, y_j) | x_j] = (q_t b_B)(x_j) for the run's own answers. (b) Σ_t E κ_t ≤ K ln 2 for adaptively chosen asked questions is the standard chain-rule bound for the Bayes mixture under A2; E|S̄_n| ≤ √n(ln(2/π) + 1/2 + K ln 2/β) at η = 1/√n; n sinh²(1/√n) ≤ sinh²(1) = 1.381 < 1.39 (convexity of sinh on [0, 1]); right. (iii) requires the base to be a probability kernel; the Bayes mixture of a class of probability kernels is one. (c) ℓ_t = ln|Y|, β = 2n ln|Y| gives ln(2/π)/η + nη; right. Simulation: `property-online_check_tilt.out`, Part 3 (mean ΣKL(P‖M^(t)) = 2.76 ± 0.04 against K ln 2 = 2.77; the bounds hold).

**Theorem 7.8 (gradient tilt identity). CORRECT.** Middle terms = (2/γ)((qΛ) − Λ(y)), then Lemma 7.5; Λ_t is bounded because |S̄_{t−1}| ≤ t − 1. (ii): E[ln(q/R)(y_t) | past, x_t] = KL(P‖R) − KL(P‖q); the hypothesis E ΣKL(P‖R_t) < ∞ gives R_t(y_t|x_t) > 0 a.s., which the identity needs. Exact numerical check: `property-online_check_tilt.out`, Part 4 (both sides agree to 8 decimals).

**Remarks 7.9. CORRECT** except one wording point. (1) The counterexample with R(y*|x) = 0 gives S̄_n = −n (Part 5 of the tilt output). (2) The deviation √(2n ln(2/δ)) is for one test; for all tests at once it is √(2n ln(2/(π(B)δ))) (MINOR). (3) β → ∞ limit: heuristic, fine as a remark. (4) The derivative of −ln q_λ(y) in λ(B) is b_B(x, y) − (q_λ b_B)(x) = −ḡ: right; Theorem 7.8 is gradient descent with step γπ(B); Theorem 7.6's λ is β sinh η times the difference of the normalised EG± weights (they sum to 1 since Σπ cosh = Φ): right. (5) With γ ≤ 2K ln 2/n identity (ii) gives EΣKL(P‖q_t) ≤ γn/2 + K ln 2 ≤ 2K ln 2: right. OPEN question correctly marked. (6) Right.

### Section 8 (comparisons with the Bayes mixture)

**Proposition 8.1 (memorisers). CORRECT.** Total weight ½ + 2^(−K) ≤ 1 since K ≥ 1. (a) Weight of the memorisers consistent with f on Q: ½A^(−k)Σ_{D⊇Q}p^|D|(1−p)^(N−|D|) = ½(p/A)^k; those with x ∉ D: ½(p/A)^k(1 − p); so the posterior predictive probability of 0 at an unseen x is (1 − p)μ_k; μ_k ≥ ½ iff k log₂(A/p) ≤ K − 1. Recomputed. (b) Σ_{t≤n}μ_{t−1} ≥ min(n, k* + 1)/2; k* + 1 > (K − 1)/log₂(A/p). (c) Σ_{t≤n}(t − 1) ≤ n²/2. (d) Theorem 3.3(ii); π(R) = ½ gives 3. The independent brute-force check `property-online_check2_misc.out` (Part 1) reproduces (a) on a second instance (see below). Note: the index convention matters (the memoriser with D = X and τ = f is the same function as f; K refers to the index f), and the file states it. Remarks (1)–(4): recomputed ((1 − p)/(2 log₂(A/p)) ≤ (ln 2)/2 since ln(1/p) ≥ 1 − p; (3) K(R) = 2 gives 4).

**Proposition 8.2. CORRECT** (one MINOR). (a) Σ_t(1 − M^(t)(f(x_t)|x_t)) ≤ −ln Π_t M^(t)(f(x_t)|x_t) ≤ ln(1/w(f)) = ln 2: right. The rule of Pr5 count is Example 2.3 (with its tie-breaking qualification). The restriction "for n ≥ 400" is unnecessary: ⌊n/2⌋ ≥ ½√n ln n for all n ≥ 1, so min(⌊n/2⌋, N*) ≥ ½√n ln n always; the reason given ("for n ≥ 400, ½√n ln n ≤ n/2") is true but weaker than needed. Also note the test weight π(B) = 1/(2n) depends on the horizon, which should be said where the comparison is quoted. (b), (c) right.

**"What remains of K ln 2/n against 1/√n" (MODIFIED claim). CORRECT.** Item 2: (1/n)ΣE TV ≤ √(K ln 2/(2n)) by Pinsker and concavity, and the deployed per-call-slot discrepancy of the mixture for any test is at most this; recomputed. The phrase "Given the rehearsal, the order 1/√n cannot be improved for either" rests on the unproved standard lower bound (see 6.3). Item 1 and the table: consistent with Theorems 3.3, 6.2 and Corollary 3.4; the row "whole runs" quotes R2 from `hellinger-runs.md` (not checked by me).

### Section 9 (numerical checks)

**9.1–9.9. Spot-checked; consistent.** I did not re-run the prover's scripts. The earlier verifier's independent scripts (`property-online_check_*.out`) reproduce 9.2 exactly (lead counts 30, 132, 530, 2040 = formula; NH count 11 at n = 10⁵), confirm the potential inequalities of 9.1 at 60 digits, and bound-check all rules exhaustively on small games (9.3) and in rehearsal (9.4). The toy figures of 9.4 are consistent with `results/toy_property.out`. 9.5–9.9: NOT CHECKED beyond plausibility (the quoted constants C(μ₀) = 559 and the lower-bound columns of 9.5 were recomputed: for d = 32, n = 1000, √n/(√(1 + n/d²) + √n/d) = 13.2; for d = 100, n = 10⁴, 41.4; for d = 1000, n = 10⁴, 90.5).

### Section 10

**10.1 (open points).** Correctly marked OPEN. Item 1: the claim that the value of Spencer's game for d = n is of order √(n ln n) is from memory and marked as such.
**10.2 (noticed elsewhere).** Items 1–9 agree with my findings, with two adjustments: item 2 says Example 2.3 shows the rule "can really give about half of that" — right, but only with least-index tie-breaking and for a fixed order of questions (see Example 2.3 and 6.2 entries); item 6 says the corollary is "correct as stated" — it is, but its proof needs the J-uniform-on-{1, …, L} protocol to get the factor 1/L (entry A.2).
**10.3 (for the editor).** Sound. One addition: the editor should state Proposition 4.2 for set tests only (entry 4.2).

### Literature spot checks (done in this session)

Read on arXiv abstract pages in this session (bibliographic data only, not the theorems): Gupta, Jung, Noarov, Pai, Roth, "Online Multivalid Learning: Means, Moments, and Prediction Intervals", arXiv:2101.01739 (5 Jan 2021; related DOI LIPIcs ITCS 2022): title, authors and venue as cited. Lee, Noarov, Pai, Roth, "Online Minimax Multiobjective Optimization: Multicalibeating and Other Applications", arXiv:2108.03837: title and authors as cited; the abstract does not state the 4C√(T ln d) bound, so the file's quotation of Theorem 2.1 is NOT CHECKED by me. Farina and Perdomo, "Defensive Generation", arXiv:2602.21390 (24 Feb 2026): exists, authors and date as cited; the abstract claims online outcome-indistinguishable generation with error rate T^(−1/2), consistent with the file's description; Definition 1 and Theorem 1 NOT CHECKED. The theorem statements the prover marks "read" (Perchet 2013; Abernethy–Bartlett–Hazan; Chernov–Vovk; Luo–Schapire; Koolen–van Erven; Vovk–Takemura–Shafer; Vovk 2007; Bárány 2024; Bansal et al.) are NOT CHECKED by me. Nothing in the proofs depends on them (Section 5's own opening sentence; I confirm that every proof in Sections 1–4 and 6–8 is self-contained, except Hoeffding's lemma, Pinsker's inequality, Ville's inequality and the Bayes-mixture regret bound, which are standard).

Independent script of this session: `verification/code/property-online_check2_misc.py` (output `.out`): Proposition 8.1(a) by exact brute force on three further instances (zero error); the lower-bound column of Section 9.5; Remark 6.4(5); the ratio in Example 2.3; Example 2.3 with the greatest minimiser (books never move).

---

## Verdict list

| Statement | Verdict |
|---|---|
| note.md 8.3, Theorem Pr5 | CORRECT (wording MINOR: η = 1/√n needs n fixed in advance) |
| note.md 8.3, Corollary (rehearsal) | MINOR (proof must use J uniform on {1,…,L} with void rounds, not "a uniformly chosen call of the run"; assumptions A1 at asked calls and A3 must be stated; "per call" means per call slot) |
| note.md 8.4, bullets | first bullet MINOR (k/√n is the Pr5 rate; Rule N gives √((2k ln 2 + ln n)/n)); "Single calls" CORRECT (figures agree with results/toy_property.out); "A fresh rule" CORRECT (Example 6.5); "The rate" WRONG as a general statement (correct only for the rule of Pr5; see Section 8.2 "What remains"); "Outside the closed system" not in this part (NOT CHECKED) |
| Lemma 1.3 | CORRECT |
| Lemma 1.4 (a)–(f) | CORRECT ((b) second form also holds on [−1,1]) |
| Theorem 2.1 | CORRECT |
| Remarks 2.2 | CORRECT |
| Example 2.3 | CORRECT as stated; MINOR qualification (depends on least-index tie-breaking) |
| Proposition 2.4 | CORRECT |
| Theorem 3.1 | CORRECT |
| Corollary 3.2 | CORRECT (cosmetic: "non-void rounds" in (c)) |
| Theorem 3.3 | CORRECT |
| Corollary 3.4 | CORRECT |
| Proposition 3.5 | CORRECT |
| Proposition 3.6 | CORRECT |
| Proposition 3.7 | CORRECT (the remark on Chernov–Vovk NOT CHECKED, not used) |
| Proposition 3.8 | CORRECT |
| Proposition 4.1 | CORRECT |
| Proposition 4.2 | MINOR (restrict to set tests or exactly given rational values; v-dependent slopes not computable for real-valued tests) |
| Proposition 4.3 | CORRECT |
| Proposition 4.4 | CORRECT |
| Proposition 5.1 | CORRECT |
| Proposition 5.2 | CORRECT (edge case: total weight 0) |
| Section 5 relations | derivations CORRECT; quoted theorems NOT CHECKED |
| Lemma 6.1 | CORRECT |
| Theorem 6.2 | CORRECT (wording MINOR in "What (c) and (d) say") |
| Theorem 6.3 | CORRECT (the lower-bound half of the following remark is unproved) |
| Remarks 6.4 | CORRECT |
| Example 6.5 | CORRECT |
| Proposition 6.6 | CORRECT |
| Example 7.1 | CORRECT |
| Example 7.2 | CORRECT (wording MINOR) |
| Proposition 7.3 | CORRECT |
| Proposition 7.4 | CORRECT |
| Lemma 7.5 | CORRECT |
| Theorem 7.6 | CORRECT |
| Corollary 7.7 | CORRECT |
| Theorem 7.8 | CORRECT |
| Remarks 7.9 | CORRECT (MINOR: union over tests in (2)) |
| Proposition 8.1 | CORRECT |
| Proposition 8.2 | CORRECT ("n ≥ 400" unnecessary; test weight depends on n) |
| Section 8.2 "What remains" (MODIFIED) | CORRECT |
| Section 9 | spot-checked, consistent; 9.5–9.9 largely NOT CHECKED |
| Section 10 | sound |

## Corrections, ordered by importance

1. **note.md 8.4, bullet "The rate"** must be replaced: "1/√n per test against K/n per call" holds only for the rule of Pr5 and a deterministic human. With Rule NH a one-sided property is violated at most K(B) + 2 times (rate (K(B) + 2)/n); for a non-deterministic human both the mixture (√(K ln 2/(2n)) on average for all tests) and the test imitator have order 1/√n for test frequencies; K/n is the mixture's rate for the divergence. Use the paragraph "What remains of K ln 2/n against 1/√n" of the proof file.
2. **note.md 8.3, Corollary, proof:** replace "the asked call is a uniformly chosen call of the run of a_t" by "the asked call is the J-th call, J uniform on {1, …, L}, and the round is void if the run is shorter" (otherwise the factor is 1/T and the statement fails for runs of varying length). State the assumptions: A1 for the asked calls and A3; not A2. Say that n is fixed in advance (η = 1/√n), or use Theorem 6.2(a) with Rule N/NH.
3. **note.md 8.3:** replace Pr5 as the main statement by Theorem 3.3 (Rule NH; all n; complexity under the root; K(B) + 2 one-sided), keeping Pr5 as the simple case; replace the closing sentence's (ln(2/π(B)) + 1/2)/√n by (K(B) + 2)/n per call slot (Theorem 6.2(c)).
4. **note.md 8.3, literature sentence:** name Spencer's balancing games / potential-based approachability and calibration for checking rules *independent of the prediction* (Lehrer 2001; Perchet's survey Thm 3.2); Sandroni–Smorodinsky–Vohra (2003) is analogous only (forecast-dependent rules, randomisation needed).
5. **Proof file, Proposition 4.2:** restrict to set tests (or rational-valued tests given exactly): for real-valued tests the clock v (number of non-zero increments) is not computable, so Rules N, (b), (c) are not computable as claimed; (a) and (e) remain.
6. **Proof file, Example 2.3 and its uses (summary, 6.2, 8.2(a), 10.2(2)):** say "with least-index tie-breaking"; with the greatest minimiser the imitator never gives the answer 1 (`property-online_check2_misc.out`, Part 5). The phrase "within a factor 2" should read "within a factor of about 2 (ratio below 1/2, tending to 1/2)", and under rehearsal it is shown only by simulation.
7. **note.md 8.4, first bullet:** "within about k/√n" is the rate of Pr5; with Rule N it is √((2k ln 2 + ln(n + 1))/n). "Being the answers of this particular human is a property of complexity about K" holds only for a deterministic human (then Corollary 3.4: K + 3 errors).
8. Minor wording: Theorem 6.3 remark and Section 8.2 item 2 ("the order 1/√n cannot be improved") rest on an unproved standard lower bound — mark or cite. Proposition 5.2: require positive total weight. Remark 7.9(2): union bound over tests. Proposition 8.2(a): drop "n ≥ 400"; note π(B) = 1/(2n) depends on the horizon. Corollary 3.2(c): "non-void rounds". Example 7.2: "the bound on the error". Example 6.5: name the rule. Proposition 4.4: state that records are non-empty. Lemma 1.4(b): the second form also holds on [−1, 1] (restriction can be dropped).

*Status: complete.*
