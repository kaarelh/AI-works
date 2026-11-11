# Check of the final README edit pass (final-readme-issues.json)

*Published record of the independent check of the final README edit pass. `prefinal/` is the lead's unpublished copy of the files as committed in c00c253b. The lead editor resolved its three points after the check (see [`README.md`](README.md), "Final consistency checks").*

Verdict: **minor fixes**. Every issue was applied as the log says, and no edit introduced a mathematical error. Four changed sentences still say slightly more than the record supports. Three of these inaccuracies were already in the text before the edit, and the rewritten sentences kept them.

## What was checked

- **Diffs.** All three edited files were diffed against `prefinal/`, and `prefinal/` is identical to `HEAD` (commit c00c253b). The agnostic README changed only in hunks that belong to R1–R55 and X-readme-X3. A word-level diff shows no other edits. The verification index changed only on lines 7, 13, 15, 17, 21, 38 and 43. In `NNG/README.md`, only the agnostic-learning row (line 147) and the agnostic paragraph under "Label-noise research" (line 224) changed. Nothing outside these files changed (`git status`).
- **Notes.** This pass edited no research note. All note diffs match entries X1–X27 of `final-xref-resolutions.md`, and none of them alters a theorem, a proof or a note's own number. The only changed number is in A Remark 6.6b, which restates red-team Proposition 4.1(a) as min{4,(τ+ρ₀)²}+4ε/3 instead of (τ+ρ₀)²+4ε/3 "exceeds 9". This matches red-team Proposition 4.1(a) as finalized.
- **Issues R1–R55 and X-readme-X3.** Each was resolved as logged. No issue was rejected. Each departure from a suggested fix is justified:
  - R15: the paraphrase was dropped.
  - R27: a shorter parenthesis was used.
  - R39: the laws' conditions are not repeated, because the next bullet states them.
  - R40: "tempered profile" was not used, because boundedness is proved only for clipped predictions; "not benign" is what Theorem A gives.
  - R45: the link was kept on the lead's instruction.
- **Claims verified against the notes.**
  - A: §0.1, Lemma 2.1, Theorem 4.4, Corollaries 4.5 and 4.5a, Remark 4.8, §5.1, Proposition 5.1, Remark 5.1a, Proposition 5.2(c), §5.3, Propositions 6.1, 6.5, 6.6 and 6.6a, Remark 6.6b, Proposition 7.4, Remark 7.5, §10.
  - B: §0 table, "Which posterior mean", Theorems 6.2, 6.3 and 6.4, the text after Theorem 6.3 (10^14.1 and 10^29.2), Theorem 7.4, Corollary 8.1 and the paragraph after it, Proposition 9.1(c), Corollary 9.3 with Cases 1–2, the Discussion, Remark 9.4.
  - C: C.0, C.1.3, C.1.4, Theorems C.1, C.2, C.5(c)–(e) and C.6.
  - E: header, Theorem 2.7, Remark 2.8, Theorem 5.2, Remark 5.4a, the §9 scope record (five points on the note).
  - small-learner-width: §0, Corollary 3(i) with Theorem 4.
  - depth-two: header, §0, Corollary 5.2.
  - red-team: status table, Proposition 4.1(a)–(c), Remark 6.2(a)–(b).
  - literature: B11 (the window 1≪λ≪m/log m, with m their sample size) and G14(b).
  - brief: §1 ("We may pick whichever version of Bayesian learning is best").
  - Verification record:
    - B-logic issue 1 and E-computation E2.
    - E-computation lists 12 points: E1–E2 and I-1 to I-10.
    - The C and E scope revision checks.
    - Every report except red-team-finalization-check-1 has a `checks/` folder, and that check did use a script.
    - Section and result labels of every published reviewed version were compared with the final notes. The only move is A's §5.2 to §5.3. The red-team note keeps the numbers of its §5 results and of Proposition 6.1 as pointers.
- **Links.** `python3 NNG/verify_collection.py` returned `{"papers": 88, "failures": []}`. An independent check of 367 relative links in the three files found none broken.

## Remaining problems (minor)

1. **README intro item 6 and the §2 finite-scale row.** "Unclipped predictions are not treated at finite scale" and "unclipped predictions are not treated" are too broad. E Theorem 5.2(ii), Corollary 5.4 (F2) and Remark 5.4a cover the unclipped posterior mean, its clip and the unclipped Gibbs risk on the negative side. README §7 itself says "the posterior means, clipped or not". Only the positive result leaves out unclipped predictions.
   - Fix, intro: "The positive result at finite scale does not cover unclipped predictions, and the conjecture's form of item 2 is not proved there:"
   - Fix, table: "the positive result does not cover unclipped predictions, and the conjecture's form of §4 is not proved".
2. **Verification index, line 7.** "each agent through one lens" is false for depth-two-referee-logic-computation-1.md and -2.md. Each of these is one agent covering logic and computation (depth-two header: "each time by a scope referee and a logic-and-computation referee").
   - Fix: "Independent AI agents then refereed each proof note, each agent through one lens (in the last two rounds on depth-two.md, one agent covered both logic and computation):"
3. **Verification index, line 21.** "no theorem was found false" conflicts with the gloss's own example: B-logic issue 1 is a false sentence inside the statement of Proposition 9.1(c), which the report calls "a genuine error".
   - Fix: "*minor fixes* means that no main result was found false; some reports with this verdict found a false sentence in a side result (B-logic.md, issue 1, in Proposition 9.1(c)) or a wrong justification of a correct bound (E-computation.md, E2)."

## Notes (no change requested)

- **R45.** The `working/` link resolves on the working branch. When `main` is published without `working/`, the link will break and `verify_collection.py` will report it there. This follows the lead's instruction.
- **§3, "for n≫d2^d it is O(2^d/n)".** This copies A §5.3 item 1. Proposition 5.2 fixes c, and its bound is (8M/δ'+4ct)/n, so the O(·) treats c, t and δ' as constants. The next bullet states the bound in full.
