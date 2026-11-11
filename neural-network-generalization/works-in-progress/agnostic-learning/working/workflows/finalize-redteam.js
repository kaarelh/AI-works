export const meta = {
  name: 'finalize-redteam',
  description: 'Finalize red-team.md: status header, pointers to the notes that supersede it, referee fixes, independent check',
  phases: [{ title: 'Revise' }, { title: 'Check' }],
}
const R = '/workspace/ai-works/neural-network-generalization/works-in-progress/agnostic-learning'
const S = '/tmp/claude-0/-workspace/e8ce7448-1256-507d-9f63-d716a14ba11f/scratchpad/agnostic'
const VERDICT_SCHEMA = {
  type: 'object',
  properties: {
    verdict: { type: 'string', enum: ['correct', 'minor_fixes', 'major_flaw'] },
    issues: { type: 'array', items: { type: 'object', properties: {
      severity: { type: 'string', enum: ['major', 'minor'] }, location: { type: 'string' },
      description: { type: 'string' }, suggested_fix: { type: 'string' } },
      required: ['severity', 'location', 'description', 'suggested_fix'] } },
    summary: { type: 'string' },
  },
  required: ['verdict', 'issues', 'summary'],
}
const REVISE_SCHEMA = { type: 'object', properties: { file: { type: 'string' }, summary: { type: 'string' } }, required: ['file', 'summary'] }

const TASK = `You are the editor preparing the final published version of the red-team report of a research folder in learning theory. Edit carefully; do not prove new results and do not strengthen any statement.

Folder: ${R} (research notes in research-notes/, referee reports in verification/, scripts in checks/). NNG/ is /workspace/ai-works/neural-network-generalization/. The main README of the folder is being written separately (draft: ${S}/stage/README.draft.md).

Source text: ${S}/stage/red-team.md (scratch paths already rewritten to the repository layout). It is the first adversarial pass over the draft Claims A-E of research-notes/problem-brief.md, written before the proof notes. Several of its parts were later refereed, repaired and published as separate notes, and other parts were superseded by the proof notes:
- §2 (Claim A) is superseded by research-notes/A-tight-conditioning-fails.md, which re-derives and extends it.
- §3 (Claim B and the threshold in D) is superseded by research-notes/B-tempered-likelihood.md.
- §4.3 Proposition 4.1 (TUBE with a sup-norm residual budget) was refereed: verification/RT-tube-logic.md and verification/RT-tube-computation.md (both "minor fixes"; read their issue lists and their "strongest statement" sections).
- §5 (depth two) was refereed twice (verification/RT-depth2-logic.md, RT-depth2-computation.md, RT-depth2-logic-revised.md, RT-depth2-computation-revised.md), repaired, and is now research-notes/depth-two.md (with two further referee rounds recorded there). depth-two.md §6 gives replacement text for every place in red-team.md that summarises §5, and records the corrections to §5 itself.
- §6.3 Proposition 6.1 (learner width tied to n) was refereed twice (verification/RT-width-*.md), repaired, and is now research-notes/small-learner-width.md. Its §7.3 gives replacement text for every place in red-team.md that cites Proposition 6.1.
- §6.3 Remark 6.2 (conditioning on aggregate training error) was refereed: verification/RT-aggregate-logic.md ("minor fixes"; read its issues and §6 "Corrected statement").
- §8 (remarks on C and E) is superseded by research-notes/C-fixed-temperature-bayes.md and research-notes/E-finite-prior-scale.md.
- Everything else (§0, §1 lemmas, §4.1-4.2, §6.1-6.2, §6.4, §7, Appendix A) was not refereed.

Write the final version to ${R}/research-notes/red-team.md. Required changes:
1. Header. Keep the title. Replace the "*Scope.*" paragraph with an italic header in the style of the other notes: what this note is (the first adversarial pass, written before the proof notes; part of the agnostic-learning note [\`../README.md\`](../README.md)); that it is kept as a record and because other notes cite its numbered results; then a status table with one row per part: §0, §1, §2, §3, §4.1-4.2, §4.3 Prop 4.1, §5, §6.1-6.2, §6.3 Prop 6.1, §6.3 Remark 6.2, §6.4, §7, §8, Appendix A, giving for each: refereed (with links to the reports) / superseded by (link) / replaced by a pointer / not refereed. Replace "Everything below is proved here unless it is labelled sketch or open" by an accurate statement (the proofs here were written in a red-team pass; only the parts marked refereed in the table were refereed). Define NNG/ as "the project folder neural-network-generalization/ of this repository". Keep the notation and limit-order paragraphs.
2. §5: replace the whole body by a short pointer section: keep the heading text as corrected in depth-two.md §6 ("Depth two ($L=2$), every $c>0$"), then a paragraph saying that the corrected Theorem 5.1, Corollary 5.2 and Proposition 5.3, with the lemmas they use, are in depth-two.md under the same numbers, summarising in two or three sentences what they show (take the wording from depth-two.md §0, with all qualifiers), and noting that §5.4's numerics are recorded in depth-two.md §7.1.
3. §6.3: amend item 2 of the list of surviving versions as small-learner-width.md §7.3 says; replace Proposition 6.1, its "In particular" clause, its proof and the paragraph after the proof by a pointer to small-learner-width.md (Theorem 1, Corollaries 2 and 3, Theorem 4, Remark 8), with a two-sentence summary of the corrected result taken from its §0 with all qualifiers (clipped predictions, one learner width tied to n, d <= n^alpha, not uniform over widths, rate O(n^{2 alpha - 1/2})). Keep the heading, the list and Remark 6.2.
4. Remark 6.2: apply the fixes of verification/RT-aggregate-logic.md (state the hypotheses: learner width N >= m, Gaussian prior, competitor of the learner's depth and the repository architecture, labels in [-1,1]; "with probability at least 1-delta" and "for every N"; which posterior functionals are bounded; the sample-dependent scale threshold; what "tau approx OPT" must mean, tau >= L_D(g) + (U+1)^2 sqrt(ln(1/delta)/(2n)), and that tau is an oracle hyperparameter). You may state the referee's corrected statement (its §6 (a)-(b)) in place of the original, citing the report; mention (c)-(d) only as the referee's observations, not as claims of this note.
5. §4.3 Proposition 4.1: apply the issues of the two RT-tube reports. Make the statement precise as in their "strongest statement" sections (part (a), and the sharper bound (b) and the energy statement (c) if you adopt them, citing the reports), and add their "Limits of the statement": these are bounded-residual guarantees, not oracle inequalities, and the posterior stays at energy <= E_*+2 ("no memorization" only in the energy sense; at small n it can still fit noise).
6. Apply every replacement of small-learner-width.md §7.3 (§0 item 1, §0 item 7, §2.3 A2, §6.3 item 2, §7 item 6, §8 "E, positive direction" second bullet) and of depth-two.md §6, first group (§0 item 6, §2.3 A3, §6.1, §6.4 second bullet, §7 item 3, Appendix A). Use their replacement text verbatim.
7. §0 item 8 and §8: add a sentence at the start of §8 (and a clause in §0 item 8) saying that the finite-scale questions are treated in E-finite-prior-scale.md (positive direction for clipped predictions with threshold 1/H for L>=3 and gamma >= 2-1/H; negative direction at every gamma >= 1, mean field included) and the fixed-temperature questions in C-fixed-temperature-bayes.md, and that the sketches of §8 are superseded. Check those claims against E §0 and C §C.0 before writing them.
8. §2 and §3: add one sentence at the start of each saying which note supersedes it and that its numbered results are kept because other documents cite them; do not otherwise rewrite them. In §0 items 1-4, add a bracketed "[At finalization: ...]" pointer where a proof note has since settled or corrected the statement (e.g. item 1 now points to A Theorem 4.4 and small-learner-width.md; item 3 to B Theorems 6.3-6.4; item 4 to B Theorem 7.4 and §7.5). Check every such pointer against the cited note.
9. Keep every numbered result, lemma, section and equation number (other notes cite them: Lemma 1.0, Lemmas 1.1-1.3, Lemma 2.1, Theorem 2.2, Proposition 2.4, Lemma 3.1, Theorem 3.2, Corollaries 3.3-3.4, Proposition 4.1, Theorem 5.1, Corollary 5.2, Proposition 5.3, Proposition 6.1, Remark 6.2). For results whose text is replaced by a pointer, keep a line with the number and the pointer.
10. Paths: every link must resolve from research-notes/; scripts are in ../checks/red-team-and-literature/ (check that each script named exists there). No absolute paths.
11. End the note with a section "Record of the finalization": a table with one row per change (where, what changed, source: report and issue number, or the replacement text's source section).

Grep the other research notes for "red-team.md" citations and make sure every cited number still exists and still says what they cite it for (report mismatches in your summary; do not edit other notes). Return the file path and a summary of the changes and of any citation mismatches found.`

const CHECK = (round) => `You are an independent checker of an edited research note. Your job is to find problems; default to reporting an issue when uncertain.

The note ${R}/research-notes/red-team.md was edited from ${S}/stage/red-team.md (diff them) according to these instructions:
---
${TASK}
---
Check: (a) every required change was made, and its text matches its source (small-learner-width.md §7.3, depth-two.md §6, the RT-tube and RT-aggregate reports, A, B, C, E); (b) no statement was strengthened beyond its source, and nothing else changed; (c) the status table is accurate (open each report and note it cites); (d) every numbered result that other notes cite still exists (grep ${R}/research-notes/*.md for "red-team.md"); (e) every link and path resolves from research-notes/; (f) the record table lists every change. Write a short report to ${S}/stage/check-redteam-r${round}.md and return the structured verdict ('correct' only if everything checks; 'minor_fixes' for small remaining problems; 'major_flaw' if a change is wrong or misleading).`

phase('Revise')
let rev = await agent(TASK, { label: 'revise:redteam', phase: 'Revise', schema: REVISE_SCHEMA })
const checks = []
for (let round = 1; round <= 2; round++) {
  const chk = await agent(CHECK(round), { label: `check:redteam:r${round}`, phase: 'Check', schema: VERDICT_SCHEMA })
  checks.push(chk)
  if (!chk || chk.verdict === 'correct' || (chk.verdict === 'minor_fixes' && round >= 2)) break
  rev = await agent(`${TASK}\n\nThis is revision round ${round + 1}. The note ${R}/research-notes/red-team.md already exists: edit it in place. An independent checker reported these problems (JSON):\n${JSON.stringify(chk.issues, null, 1)}\nFix each valid one; for an invalid one, leave the text and say why in the record (add a 'Check of the finalization' table at the end).`, { label: `revise:redteam:r${round + 1}`, phase: 'Revise', schema: REVISE_SCHEMA })
}
return { rev, checks }
