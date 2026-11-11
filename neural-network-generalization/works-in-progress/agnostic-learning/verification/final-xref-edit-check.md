# Check of the final cross-reference edit pass

*Published record of the independent check of the final cross-reference edit pass. `prefinal/` is the lead's unpublished copy of the notes as committed in c00c253b. The lead editor resolved its nine points after the check (see [`README.md`](README.md), "Final consistency checks").*

**Verdict: minor fixes.** All 26 issues (X1–X27; X3 belongs to the README pass) were applied as the log says. The log rejects none, and its four departures from the suggested wording are justified: X6, X13, X20 and X21. No theorem, proof or number of any note was changed, and `verify_collection.py` reports no failures (88 papers, `"failures": []`). Nine small problems remain, and an exact fix is given for each below. No edit introduced a mathematical error.

## What was compared

- I word-diffed all nine research notes against `prefinal/research-notes/`. Every hunk maps to an issue or to the record entry for it: A 10 lines, B 4, C 3, E 2, depth-two 4, literature 3, brief 2 changed and 3 added, red-team 15, small-learner-width 3.
- `README.md`, `verification/README.md` and `NNG/README.md` also differ from `prefinal/`. These diffs (88, 14 and 4 lines) belong to the parallel README pass, as `final-readme-resolutions.md` says. None of them carries an edit from this pass, and they were not reviewed here.
- The changes are confined to headers, bracketed notes, list items, record rows, citations and paths. A's Remark 6.6b now quotes red-team Proposition 4.1(a)–(c) as finalized. That is a quotation of another note's result; none of A's own results changed.

## Verified against the sources

- **New header sentences.** C (X8), E (X9) and depth-two (X10) match their check reports: `C-scope-revision-check.md`, `E-scope-revision-check.md` and `depth-two-revision-check.md` (21 points resolved, no mathematical error).
- **Verbatim claims.** I checked these by script.
  - X27: all six first-group replacements in depth-two §6 appear verbatim in red-team.md, and red-team's record marks each one "verbatim".
  - X11: the six quoted §7.3 replacements in small-learner-width.md appear verbatim in red-team.md. The two pointer entries became a pointer plus a summary (record row "§6.3, Proposition 6.1 …").
- **X16.** depth-two Remark 5.7a derives the clipped "+o(1)" range from B Proposition 6.1 with Lemma 5.3(a), and the all-predictors range with Lemma 5.3(b) and Lemma 3.1. B Corollary 8.1 covers only c=n^{(2−8α)/3}.
- **X12, X13.** These match E §0 rows 2, 6 and 7, Theorem 5.2 and Corollaries 5.3–5.4:
  - θ_{2,γ}=1;
  - for L≥3, θ_{L,γ}=1/H when γ≥2−1/H, and smaller below;
  - the case γ=1, L≥3 is conditional on (I3);
  - failure at every γ≥1, at N≥N_*=poly(n), on the noisy cube with d=log₂n.
- **X25.** E's posterior is ∝e^{−(N^γ/2c)R_S}μ, and N≥N_*≥min{n,2^d} with c=o(n), so the per-sample inverse temperature N^γ/(2c) is large, as the note says.
- **X17, X7, X2.** These match depth-two Corollary 5.2(i) (c≤poly(d); N_0=O(n log⁴n) at a_d=1/d; γ(1)=0.0999), depth-two §0, and the depth-two header together with `verification/README.md` line 17.
- **X1.** This matches the following parts of A:
  - Corollary 4.5a: N_0=O(n log⁴n) for every c with (4.4), that is, cK_mem=o(n);
  - Corollary 7.2b: A′ for fixed c or (4.4);
  - Corollary 4.6, Lemma 6.4, Propositions 6.3/6.6/6.6a, and §0.1 (the TUBE windows).
- **X4.** This matches red-team Proposition 4.1 (a)–(c), its tightness example (g≡−c_0, c_0∈(ρ,1], the 1−p^n qualifier) and its no-conflict paragraph. The arithmetic checks: τ+ρ_0>3, and ρ²+ε>1≥L_D(0).
- **X14, X15, X19.** These match B Theorems 6.2–6.4, Corollaries 8.1 and 9.3, Remark 9.4, and red-team Corollary 3.3(a)/(b).
- **X18.** C.5 and C.5(e) are cited correctly. Remaining problem 1 concerns the reference to C.7.
- **X20, X21.** These match A §0.1, §0.2 item 7, §7 ("Clusters", the corner cubes at p∈{−1,1}^d) and red-team §2.3 A3.
- **Paths.** The paths of X22–X24 exist. `paper.tex` means the continuous-domains paper at every use in C and in literature.md, and literature.md's first use is at its line 71, where the note now stands. red-team.md no longer contains "never memorizes" outside its record.

## Remaining problems (all minor)

1. **problem-brief.md, Claim C bullet: "Theorems C.6–C.7 give high-probability versions".** Theorem C.7 bounds the *final* posterior, through its Gibbs predictor and posterior mean, not the progressive mixture. Its bound also carries a +4η term that does not vanish at fixed η. C §C.0 ("Bearing on the conjecture") gives the high-probability oracle inequality only for f̃_n, which is Theorem C.6.
   *Fix:* "(Theorems C.1–C.2, in expectation; Theorem C.6 gives a high-probability version)".
2. **red-team.md §7 item 2, new note: the Corollary 9.3 sentence drops the learner-width quantifier.** B's scope referee (issue 1) asked for both quantifiers. B's §9 Discussion states the result "uniformly over laws and dimensions, at every learner width at least the competitors' width bound", and Case 1 fails only at N≥N_0(n)>n (Remark 9.4).
   *Fix:* "… against these classes uniformly over laws and input dimensions, at every learner width at least the competitors' width.]"
3. **red-team.md, "Check of the finalization", row 6(d) is now stale.** The row says that A's Remark 6.6b "refers to" the "never memorizes" sentence and quotes (τ+ρ_0)²+4ε/3, with "Reported; no change needed". X4 rewrote that remark. Rows 6(a)–(b) record later changes made in the other notes.
   *Fix:* append to the row's last cell: "After a final cross-reference check, A's Remark 6.6b was rewritten: it now summarizes parts (a)–(c) of Proposition 4.1 and no longer refers to that sentence."
4. **A §5.4 (E bullet) and §10 item 6: "the last on the note's final text" / "the last on its final text".** E was revised after its scope report. `verification/README.md` line 17 counts the texts read by the C and E scope reports among the intermediate, unpublished texts, the same category as the depth-two rounds that §10 item 4 now calls "on intermediate texts" (X2).
   *Fix:* "the last after the note's three revision checks" and "the last after its three revision checks" (the verification table's label), or delete the clause.
5. **problem-brief.md, Claim A′ bullet: "such as uniform inputs".** A §0.1 has "uniform inputs on [−1,1]^d". In the brief, Claim A's law has uniform inputs on {−1,1}^d with noisy labels, where failure *is* proved, so the bare phrase can be read as contradicting Claim A.
   *Fix:* "such as uniform inputs on [−1,1]^d".
6. **problem-brief.md, §1 correction, last sentence.** depth-two Remark 5.7a proves the second form at c=log³n only as (P₂^{o(1)}[log₂n+C₀]), that is, with the o(1) uniform over d≤log₂n+C₀. The brief's second form states no range of d, and with d unrestricted no learner satisfies it (depth-two Remark 5.3a).
   *Fix:* "… and, for clipped predictions and input dimensions d ≤ log₂ n + O(1), satisfies the second form (…)".
7. **problem-brief.md, §1 correction: the quoted form is not §1's wording.** §1 reads "test loss <= min over depth-L MLPs with width and weights <= n^alpha, plus o(1)".
   *Fix:* quote that text exactly, or drop the quotation marks.
8. **A, "Lead editor's notes at finalization": "small-learner-width.md and depth-two.md link all four".** Each note links two of the reports.
   *Fix:* "small-learner-width.md links the two width reports and depth-two.md the two reports on red-team.md §5".
9. **red-team.md §6.1 heading note: "Proposition 2.4, which these items cite".** Only the first item cites Proposition 2.4; the other two cite "A′".
   *Fix:* "Proposition 2.4, which the first item cites".
