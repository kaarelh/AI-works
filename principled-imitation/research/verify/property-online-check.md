# property-online: line-by-line check

Referee report on `research/prove-c/property-online.md` (Sections 0 to 10) and, against it, on Sections 8.3 and 8.4 of `note.md` (Theorem Pr5, its rehearsal corollary, and the bullets of "What this does not give"). Role: referee, line by line. Verdicts: **CORRECT**; **MINOR** (correct after a small fix, which is given); **GAP** (a step is missing; it is named, and filled where I could); **WRONG** (the failing step, a counterexample, and the strongest true replacement). A statement I did not check is listed as **NOT CHECKED**.

*Status: complete when the section "Corrections, ordered by importance" at the end is present.*

**Note on the scripts.** An earlier verifier with this role was cut off before writing more than a stub of this report, but left five scripts with saved outputs in `research/verify/code/` (`property-online_check_potentials.py`, `_check_game.py`, `_check_ex23.py`, `_check_rehearsal.py`, `_check_tilt.py`, each with its `.out`). I read each script's relevant part before relying on it, and re-ran the ones named below. Where I cite one of these outputs I say which part of it supports which step. Scripts written in this session are named `property-online_check2_*.py`.

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

