# Resolutions of the final cross-reference check (`final-xref-issues.json`)

*Published record: the editor's log of the final cross-reference edit pass. The issue ids refer to [`../checks/final-consistency/final-xref-issues.json`](../checks/final-consistency/final-xref-issues.json) and [`final-xref-check.md`](final-xref-check.md).*

Edits are in `research-notes/` only; no README was edited, and no theorem, proof or number of a note was changed. Each edited note records its edits in its closing lead-editor paragraph (A, B: "Lead editor's notes at finalization"; depth-two: "Check of the final revision"; C, E: "Check of the scope revision"; red-team: "Second check"; small-learner-width: the paragraph after the "Second check of the revision" table), in the italic header (brief) or in bracketed "At finalization" notes (literature).

- X1: fixed. red-team: "At finalization" notes on §7 item 1 (what A refutes, at L≥3, N≥N_0=O(n log⁴n), d=log₂n; not the conjecture, which B satisfies with clipped predictions; β(λ)Var loss proved for SP_c only; how TUBE fails; exact interpolation has no solution on a conflicting atom), on §0 item 7 and under the §6.1 heading; status table (§0, §6.1, §7 rows) and record rows added.
- X2: fixed. A §10 item 4 now says two rounds plus two re-refereeing rounds on intermediate texts, last changes checked but not refereed (suggested wording).
- X4: fixed. A Remark 6.6b now quotes Prop. 4.1(a) as min{4,(τ+ρ_0)²}+4ε/3, adds (b) ρ²+ε with its ρ,ρ_0,τ,N-free sample size and (c) energy; "never memorizes" sentence removed; example gets g≡−c_0, single atom and the 1−p^n qualifier; no-conflict sentence covers (b).
- X5: fixed. A §5.4 bullet and §10 item 6 name the three E reports (logic, computation, scope on the final text); the scope report's major issue concerned the README draft.
- X6: fixed. A closing note extended: edits (i)–(ii) removed the RT-width links from §5.4 "The heuristic" and §10 item 5 and the RT-depth2 links from §10 item 4 (second-check row 5, third-check row 2); §5.3 item 3 still links the width reports. Header now says the lead editor's later edits are listed in the last paragraph of the record ("updated three citations" not used: the edits are more than three citations).
- X7: fixed. A §0.1 and §0.2 item 10 now point to depth-two.md (SP_c fails (P_L) at L=2 for c≤polylog(n), at N≥N_0=O(n log⁴n); c=1 open) and small-learner-width.md.
- X8: fixed. C header names C-scope-revision-check.md and its result.
- X9: fixed. E header names E-scope-revision-check.md; sentence placed after "They add no numbered result…" so that "They" keeps its antecedent.
- X10: fixed. depth-two header names depth-two-revision-check.md (every point of the two reports resolved; no mathematical error).
- X11: fixed. small-learner-width §7.3 opening: lines 480–497 have been replaced by a pointer with a summary; other entries applied verbatim (checked by script).
- X12: fixed. small-learner-width §7.3, §8 entry: adds θ<θ_{L,γ} (for L≥3: 1/H when γ≥2−1/H, smaller for 1≤γ<2−1/H, γ=1 conditional on the imported cover).
- X13: fixed. B §0 "Still open" note on E (Thm 2.7 range incl. θ_{2,γ}=1; Thm 5.2/Cor 5.4 failure with cube, d=log₂n, N≥N_* qualifiers); §11 (v) points to it. The suggested clause "the n^α classes are open there" was not used: E Remark 2.8 bounds those classes for α<1/(8H) (Case I), so the note says only that unclipped predictors are not covered and points to E §6, §8.
- X14: fixed. red-team §7 item 2: "with clipped predictions" inserted (as "the strong-prior posterior, with clipped predictions, competes …"); note gives B Thm 6.3/6.4 ranges and, for H≥2, Cor. 8.1 (α<1/(4H)) and Cor. 9.3 (α>L/(2H(2L−1))).
- X15: fixed. red-team §6.3 item 1 states clipped θ<1/H, unclipped θ<1/L and cites B Theorems 6.3–6.4 (suggested wording).
- X16: fixed. depth-two §6 entry and red-team §0 item 6 both now cite B Proposition 6.1 with Lemmas 5.3 and 3.1, and Proposition 9.1; replacement still verbatim (checked by script).
- X17: fixed. B §7.5 item 3 note: displayed bound is depth-two Corollary 5.2(i) with λ=1, valid for every 0<c≤poly(d) along n=⌈λ2^d⌉; learner-width qualifier N≥N_0=O(n log⁴n) added.
- X18: fixed. Brief header: positive half of C clipped only (Thms C.1–C.2, C.6–C.7); failure of width-uniformity for clipped and unclipped (Thm C.5(e)); rest of the note kept, with "open" restricted to the positive half.
- X19: fixed. Brief header: weight-bound sentence replaced by the uniform-over-laws statement (B Cor. 9.3, H≥2) and the fixed-law statement (Rem. 9.4); cover threshold "(1/2 at L = 2)".
- X20: fixed. Brief header bullet on A′. Adjusted from the suggestion: A's corner cubes are an instance of the brief's clusters, so not "a different law"; the 2^Θ(d²) density is cited to A §0.1 (Proposition 7.4 bounds test mass, not A′'s density); the open class is stated as A states it (density ratio 2^o(d²) with noisy labels).
- X21: fixed. Brief header paragraph on §1's "Equivalently" (red-team §2.3 A3; depth-two Remark 5.7a). Placed as a separate italic paragraph because the bullets list §4 corrections; "agree only when" follows red-team's "holds only when" (the suggested "agree when" would assert a sufficiency red-team does not state).
- X22: fixed. C §C.9 path written as `NNG/works-in-progress/slt-finite-sample/README.md`.
- X23: fixed. C: `paper.tex` defined in the italic header, before its first use in §C.0 (as red-team and small-learner-width do). literature: bracketed "At finalization" note at the first use in Corollary 2, since the survey leaves the text around its notes unchanged.
- X24: fixed. A Appendix R2 "Numbers and scripts" and first-check row 5 name the three files with `../checks/verify-A-computation/`.
- X25: fixed. literature remark (iv): "cold limit" sentence kept (survey convention) and an "At finalization" note added: E Thm 5.2 and Cor. 5.3 give the atom failure at finite scale, no limit, N≥N_*(n); per-sample inverse temperature N^γ/(2c) is large, so what the failure needs is a cold posterior.
- X26: fixed. literature §0 item 4 note: "at learner widths N≥N_0(n)=poly(n)" added.
- X27: fixed. depth-two §6 introduction: the finalized red-team.md has made every first-group replacement verbatim (checked by script).

No issue was rejected.
