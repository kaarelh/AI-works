# Adversary's report on `research/prove-c/property-online.md` (part property-online: Theorem Pr5, Rules N and NH, the rehearsal corollary, the limits, the randomised version, the comparisons with the Bayes mixture) and, against it, on Sections 8.3 and 8.4 of `note.md`

Role: adversary. **Status: IN PROGRESS** (written in pieces; this line is removed when the verdict list is final).

The file under attack is `research/prove-c/property-online.md` (Sections 0 to 10; "the file"). The earlier stub of this report (1.7 KB, written by an interrupted verifier) was a list of intentions; per the instructions it was overwritten. Two scripts that interrupted verifier left in `research/verify/code/` (`property-online_attack_finite.py` with its output, and `property-online_attack_game.py`, whose output is empty) are re-used and re-run below; their outputs are quoted only after I re-ran them in this session.

## Hand check of the proofs (this session)

I re-derived, line by line: Lemma 1.3; Lemma 1.4 (a)-(f) (for (c) both the mixture route and the direct convexity route, including the identity G_v(s) = ∫ e^(ηs − vη²/2) φ(η) dη); Theorem 2.1 and the five-step check of the lead's proof; Example 2.3 (both phases of the claim, the tie-breaking, and N* ≥ √n·arcsinh(√n) for η = 1/√n, δ = 1/2, β = 1/(2n)); Proposition 2.4; Theorem 3.1; Corollary 3.2 (a)-(c), including the inequality e(2Λ+4) > 2Λ+3+ln(2Λ+4); Theorem 3.3 and Corollary 3.4 (weight w(f)/2 gives K+1 bits, hence K+3); Proposition 3.5; Proposition 3.6 (a) and (b), including the closed forms √n/(√(1+n/d²)+√n/d) and √n/(√(2+n/d²)+√n/d); Proposition 3.7 (grid; the constants 3/√2 and 2√2); Proposition 3.8 (ln(1+u) ≥ u − u² on [−1/2, ∞)); Propositions 4.1, 4.3, 4.4; Propositions 5.1, 5.2; Lemma 6.1; Theorem 6.2 (a)-(d); Theorem 6.3 including (6.2) and the constant e/(e−1); Example 6.5; Proposition 6.6 (steps (1)-(5), including ϱ = 1 − μ₀²/(8e) and C(μ₀)); Example 7.1; Proposition 7.3; Proposition 7.4 (performance-difference telescoping); Lemma 7.5; Theorem 7.6 (identity (7.1), the supermartingale and Ville's inequality); Corollary 7.7; Theorem 7.8; Proposition 8.1 (posterior weights of the memorisers, μ_k ≥ 1/2 iff k·log₂(A/p) ≤ K − 1); Proposition 8.2.

No arithmetic or logical error was found in these proofs. The findings below concern hypotheses, scope of the prose, and the literature.

## Findings (being filled in; ordered by severity at the end)

