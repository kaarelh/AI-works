# Response to the referee report

The report ([`referee-report.md`](referee-report.md)) is on the first draft of `note.md` (commit `ultranatural: draft note, enumeration experiment and results`). It found no error in a numbered statement, four major overclaims (M1–M4), and minor points. Every finding was checked before acting on it. All were accepted. What changed:

| finding | change in `note.md` |
|---|---|
| M1 (Answers 4, wrong exponent) | Answers 4 and the text after Proposition 6 now give 2^(2a+K(f)+c)·((2a+K(f)+c)·ln 2 + ln(1/η))/n. |
| M2 ("SOI attains the bound") | Section 3.2 retitled "How stable SOI is". Proposition 4 restated in terms of the margin m, with the referee's construction as part 3: the Kolmogorov version is stable to m/2 and not beyond m/2 + 1. Answers 3 and the closing paragraph reworded. Whether any equivariant scheme is stable beyond sep(x; A)/2 is now open question 1. |
| M3 (Proposition 2 overstated) | Proposition 2 extended with parts 1 and 4 (the tally agrees with SOI at typical inputs: E[v(f(x))] ≤ 1/(n+1)). Answers 2 and the discussion reworded: guards dominate only where sep(x; A) is below L(D) ≤ K(f); the cost of excluding the right label is sep(x; A) only up to K(f), with the referee's example. |
| M4 (numbers that depend on the 11-node limit) | Section 6 and Answers 8 now lead with the statistic that does not depend on the limit (a dissenter of size at most K(f) + 2) and the posterior, with its caveat. The limit-dependent fraction is reported separately with the referee's figures at limits 9, 10, 11 and the spread over seeds. "A few samples" replaced by the values of n. |
| m1 (slack s) | Theorem 5(3) converse is now ≤ L(D) + b, with the referee's argument. |
| m2 (definitions in 3.1) | Complexities of sets, labels and relabellings are taken on the fixed machine; tie-breaking stated in Section 1; the conditions under which a tally of properties and the tape versions are equivariant are stated. |
| m3 | The floor is stated in conditional form, K(f) + sep(x; A | f) + c; the margin sentence follows from it. |
| m4 | The "repair" paragraph is restricted to finite Y and claims only "a version of SOI, between W_tot and the product mixture". |
| m5 | Proposition 8(3) defines Q_g as the exact disagreement set and is retitled. |
| m6 | In Section 5, X is the (decidable) support of μ. |
| m7 | "Nonempty", "normalised" and the one-line proof added. |
| m8, m9, m10 | The three "What it costs" bullets corrected as proposed. |
| m11 | Open question on a shrinking scale: super-polynomial pinning needs δ_n·n/log n → ∞. |
| m12, m13, m14, m15 | "At least" in the table of Section 4; the 1/n statements carry their factors and cite Paper 1, Remark 8.9(iv), for the upper bound; "expected" error in Answers 7; "up to K(f) + O(1)" in Answers 1; "binary labels" and "relabelling-equivariant" in Answers 3. |
| m16 | Section 6: five functions of size 7 within distance 6 of addition, of which S(P(x+y)) is the one at distance 1; which neighbour makes each patch non-isolated; "δ ≤ 5/36"; the language description now says a closed term runs with a = 0 and where n and init are evaluated; the claim about patches is limited to the patches of addition that were tried; "fixed before running anything" is marked as not verifiable from the repository. |
| m17 | Remark 1.1 now says the c.e. version is expected, not written out. |
| w1–w7 | Applied (w5: the heuristic sentence is removed; w7: the relative form of the papers' floor is in Remark 1.1). |

One sentence added after the report, and checked against the enumeration: for successor at δ = 1/6 cheap dissent persists because S(S(P(x))), of size 4 and at distance 6 from successor, is itself isolated at that scale (R = 6).

The revised note has not been refereed again.
