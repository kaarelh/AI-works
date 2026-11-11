# Verification record

*Part of the [agnostic-learning note](../README.md). The proofs are on paper, with numerical sanity checks; nothing here is Lean verified.*

## How the results were checked

Each proof note in [`../research-notes/`](../research-notes/) (A, B, C, E, small-learner-width.md and depth-two.md) was written by an AI agent, from the [problem brief](../research-notes/problem-brief.md) or as a repair of a red-team result. The brief and the literature survey were not refereed, and the red-team note only in the parts listed below. Independent AI agents then refereed each proof note, each agent through one lens (in the last two rounds on depth-two.md, one agent covered both logic and computation):

- **logic**: quantifiers, the order of limits ($\sigma\to0$ after the sample and the learner width are fixed), case splits, definitions against the brief and the cited repository sources, misapplied lemmas, missing hypotheses;
- **computation**: every constant, exponent, energy bound, probability estimate and concentration inequality, recomputed, with Python checks on small instances;
- **scope**: whether the results establish or refute the intended version of the conjecture, and whether its proposer could object that they concern a different learner, law, loss or order of limits.

Each referee worked in a separate context and was told to look for errors. Some referees also read earlier reports on the same note, as their reports say. A note with a blocking issue went back to its author for repair and was refereed again through every lens. Notes with only minor issues were then revised by an author agent, who answered every issue in a referee record at the end of the note, and an independent agent checked each revision. Up to three revise-and-check rounds were run, and one more for C and E after their scope reports; the lead editor resolved the points left by the last check.

The red-team note contains propositions that the main README cites. Those propositions were refereed separately; the two that needed repair were refereed again as small-learner-width.md and depth-two.md, and the other two were restated in their referees' corrected form and checked in the finalization checks.

Line numbers in a report refer to the version it reviewed. The versions read by the referees are published here and named in the tables below, except the texts read by the scope reports on C and E and by the last two referee rounds of the depth-two note. Those texts, and the texts read by the checks of a revision, are intermediate and not published; their reports also locate each point by section and result number. Section and result numbers are stable across revisions, and revisions only added items, except that A's revision 1 moved its §5.2 (Discussion) to §5.3. The scripts that referees and checkers wrote are in [`../checks/`](../checks/), in folders named after the report (for example [`../checks/verify-B-scope/`](../checks/verify-B-scope/)); the script of the first red-team finalization check is not published.

## Proof notes

Verdicts: *minor fixes* means that no main result was found false; some reports with this verdict found a false sentence in a side result (B-logic.md, issue 1, in Proposition 9.1(c)) or a wrong justification of a correct bound (E-computation.md, E2). "Major for reporting" means that, left uncorrected, a summary would have told the reader more than was proved.

| note | version reviewed | lens | verdict | issues | report |
|---|---|---|---|---|---|
| A: tight conditioning fails | first version ([A-first-version.md](A-first-version.md)) | logic | minor fixes | 16 minor | [A-first-version-logic.md](A-first-version-logic.md) |
| | | computation | minor fixes | 8 minor | [A-first-version-computation.md](A-first-version-computation.md) |
| | | scope | minor fixes, scope repair required | 3 major for reporting, 7 minor | [A-first-version-scope.md](A-first-version-scope.md) |
| | revision 1 ([A-revision-1.md](A-revision-1.md); answers in its Appendix R) | logic | minor fixes | 16 minor | [A-logic.md](A-logic.md) |
| | | computation | minor fixes | 7 minor | [A-computation.md](A-computation.md) |
| | | scope | minor fixes | 9 minor | [A-scope.md](A-scope.md) |
| B: tempered likelihood | first version ([B-first-version.md](B-first-version.md)) | logic | minor fixes | 11 minor | [B-logic.md](B-logic.md) |
| | | computation | minor fixes | 10 minor | [B-computation.md](B-computation.md) |
| | | scope | minor fixes | 10 minor | [B-scope.md](B-scope.md) |
| C: fixed-temperature Bayes | first version ([C-first-version.md](C-first-version.md)) | logic | minor fixes | 10 minor | [C-logic.md](C-logic.md) |
| | | computation | minor fixes | 7 minor | [C-computation.md](C-computation.md) |
| | final text, after three revision checks | scope | minor fixes | 14 minor (7 on the README draft, 1 on the brief) | [C-scope.md](C-scope.md) |
| E: finite prior scale | first version ([E-first-version.md](E-first-version.md)) | logic | minor fixes | 10 minor | [E-logic.md](E-logic.md) |
| | | computation | minor fixes | 12 minor (2 errors, 10 imprecisions) | [E-computation.md](E-computation.md) |
| | final text, after three revision checks | scope | major flaw in the README draft's summary of E; minor fixes in E | 1 major for reporting, 10 minor; 7 of the 11 concern the README draft | [E-scope.md](E-scope.md) |

The three scope issues on the first version of A were that it did not say the conjecture is existential in the learner (another learner, in B, satisfies it), that its counterexample needs the input dimension to grow with $n$, and that its continuous-input variant is near-atomic at the learner's resolution. Revision 1 restates the scope accordingly and adds Proposition 5.2 (fixed input dimension) and Proposition 7.4 (how near-atomic the law must be).

C and E were first refereed through the logic and computation lenses only. After their revision checks, a scope referee reviewed each final text together with the README draft's summary of it. The report on E found E's theorems correct and raised five minor points on its text, but found that the README draft claimed for the finite prior scale the whole strong-prior picture (unclipped predictors, the conjecture's form with competitors of size $n^\alpha$, the threshold $1/H$ at every $\gamma$), which E does not prove; the README was corrected before publication. The notes' answers to both reports are in their final sections.

## Revision checks

| note | check | verdict | points | report |
|---|---|---|---|---|
| A | 1 | minor fixes | 5 | [A-revision-check-1.md](A-revision-check-1.md) |
| A | 2 | minor fixes | 5 | [A-revision-check-2.md](A-revision-check-2.md) |
| A | 3 | minor fixes; resolved by the lead editor | 3 | [A-revision-check-3.md](A-revision-check-3.md) |
| B | 1 | minor fixes | 7 | [B-revision-check-1.md](B-revision-check-1.md) |
| B | 2 | minor fixes | 8 | [B-revision-check-2.md](B-revision-check-2.md) |
| B | 3 | minor fixes; resolved by the lead editor | 3 | [B-revision-check-3.md](B-revision-check-3.md) |
| C | 1 | minor fixes | 3 | [C-revision-check-1.md](C-revision-check-1.md) |
| C | 2 | minor fixes | 3 | [C-revision-check-2.md](C-revision-check-2.md) |
| C | 3 | minor fixes; resolved by the lead editor | 3 | [C-revision-check-3.md](C-revision-check-3.md) |
| C | after the scope report | minor fixes; resolved by the lead editor | 3 | [C-scope-revision-check.md](C-scope-revision-check.md) |
| E | 1 | minor fixes | 5 | [E-revision-check-1.md](E-revision-check-1.md) |
| E | 2 | minor fixes | 7 | [E-revision-check-2.md](E-revision-check-2.md) |
| E | 3 | minor fixes; resolved by the lead editor | 5 | [E-revision-check-3.md](E-revision-check-3.md) |
| E | after the scope report | minor fixes; resolved by the lead editor | 3 | [E-scope-revision-check.md](E-scope-revision-check.md) |

Each note's final section lists every referee issue and every revision-check point, with its resolution (fixed, weakened or rebutted) and where in the text it was handled.

## Red-team propositions

The red-team note ([red-team.md](../research-notes/red-team.md)) is the first adversarial pass over the draft claims of the brief. Four of its results are cited by the main README and were refereed separately. Two of them needed repair, and the repaired versions are now notes of their own.

| result | round | lens | verdict | report |
|---|---|---|---|---|
| Proposition 4.1 (TUBE with a sup-norm residual budget) | 1, first version ([red-team-first-version.md](red-team-first-version.md)) | logic | minor fixes | [RT-tube-logic.md](RT-tube-logic.md) |
| | | computation | minor fixes | [RT-tube-computation.md](RT-tube-computation.md) |
| Remark 6.2 (conditioning on the aggregate training error) | 1, first version | logic | minor fixes | [RT-aggregate-logic.md](RT-aggregate-logic.md) |
| Proposition 6.1 (learner width tied to $n$), now [small-learner-width.md](../research-notes/small-learner-width.md) | 1, original text | logic | major flaw; the claim survives after a repair | [RT-width-logic.md](RT-width-logic.md) |
| | | computation | major flaw, repairable | [RT-width-computation.md](RT-width-computation.md) |
| | 2, repaired note ([small-learner-width-first-version.md](small-learner-width-first-version.md)) | logic | minor fixes | [RT-width-logic-revised.md](RT-width-logic-revised.md) |
| | | computation | minor fixes | [RT-width-computation-revised.md](RT-width-computation-revised.md) |
| | check of the revision 1 | | minor fixes | [small-learner-width-revision-check-1.md](small-learner-width-revision-check-1.md) |
| | check of the revision 2 | | minor fixes; resolved by the lead editor | [small-learner-width-revision-check-2.md](small-learner-width-revision-check-2.md) |
| §5 (depth two), now [depth-two.md](../research-notes/depth-two.md) | 1, original text | logic | major flaw in a scope claim of Corollary 5.2; the proofs are correct | [RT-depth2-logic.md](RT-depth2-logic.md) |
| | | computation | minor fixes | [RT-depth2-computation.md](RT-depth2-computation.md) |
| | 2, repaired note ([depth-two-first-version.md](depth-two-first-version.md)) | logic | major flaw in the formulations claimed refuted; every proof and displayed bound correct | [RT-depth2-logic-revised.md](RT-depth2-logic-revised.md) |
| | | computation | minor fixes | [RT-depth2-computation-revised.md](RT-depth2-computation-revised.md) |
| | 3, final candidate | scope | minor fixes | [depth-two-referee-scope-1.md](depth-two-referee-scope-1.md) |
| | | logic and computation | minor fixes | [depth-two-referee-logic-computation-1.md](depth-two-referee-logic-computation-1.md) |
| | 4, final candidate after revision | scope | minor fixes | [depth-two-referee-scope-2.md](depth-two-referee-scope-2.md) |
| | | logic and computation | minor fixes | [depth-two-referee-logic-computation-2.md](depth-two-referee-logic-computation-2.md) |
| | check of the last revision | | minor fixes; resolved by the lead editor | [depth-two-revision-check.md](depth-two-revision-check.md) |
| The finalized red-team note (status header, pointers, referee fixes to Proposition 4.1 and Remark 6.2) | check of the finalization 1 | | minor fixes | [red-team-finalization-check-1.md](red-team-finalization-check-1.md) |
| | check of the finalization 2 | | minor fixes; resolved by the lead editor | [red-team-finalization-check-2.md](red-team-finalization-check-2.md) |

The major issues were these.

- **Proposition 6.1.** Its displayed inequality is correct, but the stated rate is not: read off the display, the excess against competitors of width and weights $n^\alpha$ is polynomially small only for $\alpha<1/8$. The repair replaces Hoeffding's inequality for the competitor by Bernstein's, which restores $\alpha<1/4$ at the slower rate $O(n^{2\alpha-1/2})$, and proves the transfer from near-minimizers to the posterior that the original asserted.
- **§5, first round.** Corollary 5.2 said it does not refute the "$+o(1)$" formulation, which is false on part of its own range: for $c\le\nu/\log_2n$ its bound is a constant.
- **§5, second round.** Two formulations that the repaired note claimed to refute were ill-posed. One required the bound at every learner width $N\ge1$, which no learner whose output is a network of its own width can meet; the other was uniform over input dimensions of order $n$, which no learner can meet at all. The final note requires the bound at learner widths at least the competitors' width, as the brief does, and describes Proposition 5.3 by what it shows.

The rest of red-team.md was not refereed. Its status table says which parts are superseded by the proof notes.

## Final consistency checks

After every note was final, two adversarial checks read the whole folder. One checked the main README, this index and the two entries in the collection README sentence by sentence against the notes and the reports; the other checked every cross-reference between the notes. An edit pass applied every point, with a log, and an independent check reviewed each edit pass. The lead editor resolved the points left by those checks.

| check | verdict | points | edit log | check of the edits |
|---|---|---|---|---|
| README, verification index, collection README entries: [final-readme-check.md](final-readme-check.md) | major flaw for reporting (the collection README attributed noise memorization to tube conditioning; two README summaries overstated the depth-two and strong-prior results) | 4 major, 51 minor, and 1 from the cross-reference check | [final-readme-resolutions.md](final-readme-resolutions.md): all fixed or weakened | [final-readme-edit-check.md](final-readme-edit-check.md): minor fixes, 3 points, resolved by the lead editor |
| cross-references between the notes: [final-xref-check.md](final-xref-check.md) | major flaw for reporting (red-team.md §7 still called the conjecture false) | 1 major, 25 minor | [final-xref-resolutions.md](final-xref-resolutions.md): all fixed or weakened | [final-xref-edit-check.md](final-xref-edit-check.md): minor fixes, 9 points, resolved by the lead editor |

The issue lists, with the ids the logs use, are in [`../checks/final-consistency/`](../checks/final-consistency/).

## Limits of this record

- The referees, authors and checkers are AI agents. Their reports are adversarial in intent, but they are not a substitute for human refereeing or for formal verification.
- Numerical checks are sanity checks on small instances. Checks based on local optimization give one-sided evidence only: they bound suprema from below and minima from above.
- The literature survey was checked against search listings only; full texts were not available in the working environment (see [literature.md](../research-notes/literature.md)).
