export const meta = {
  name: 'finalize-depth2-r3',
  description: 'Depth-two note: answer the final-round referee points, then an independent check',
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
const REVISE_SCHEMA = { type: 'object', properties: { file: { type: 'string' }, summary: { type: 'string' }, redteam_sync: { type: 'array', items: { type: 'string' } } }, required: ['file', 'summary', 'redteam_sync'] }

const TASK = `You are the author of the research note ${R}/research-notes/depth-two.md, preparing its final text. Edit it in place.

The note was refereed in two rounds and then re-refereed twice in its final form, by a scope referee and a logic-and-computation referee each time. The reports of the last round are ${R}/verification/depth-two-referee-scope-2.md and ${R}/verification/depth-two-referee-logic-computation-2.md (both "minor fixes"); those of the round before are depth-two-referee-scope-1.md and depth-two-referee-logic-computation-1.md in the same folder (already answered in §9 as "the two checks of the revision"; they are referee reports, so call them "the first re-refereeing round" from now on, and the last round "the second re-refereeing round"). Read the two last-round reports completely, and the note completely.

Address EVERY point of the two last-round reports (the logic-and-computation report has 12 points; the scope report has 3 issues and nits 4-9). Fix the text where the point is valid; if you judge one invalid, leave the text and explain why in the record. Do not strengthen any refereed statement. For the scope report's issue 3, prefer the minimal fix (replace "Other c are not settled here" by an accurate statement of what (5.7a) gives and what is not classified). You may add the extension of Corollary 5.2(a) to c <= n^{o(1)} only as a separate remark marked "not refereed; observed by the scope referee of the second re-refereeing round", with its two-line proof written out; otherwise record it as the referee's observation. For scope issue 1 (fixed d, c of order n), add the qualifier c = o(n) where the text says the cube family is learned consistently at a fixed d, and state what happens for c of order n, citing A-tight-conditioning-fails.md (paragraph after its Proposition 8.3) and the referee's script; check A's text before citing it.

Three points were already applied by the lead editor to §6 before this revision; keep them and record them in the table as "fixed (lead editor)": (i) logic-and-computation point 2 / scope nit 6, first part: the §0 item 6 replacement's numerics bullet now says "At the run's width, every near-minimizer leaves at most (1-phi)G+c"; (ii) scope nit 6, second part: in the Appendix A replacement, "at the run's width" now qualifies the near-minimizer clause; (iii) scope nit 4: the §7 item 3 replacement now adds "For the polynomial-sample version, every c <= polylog(n) fails (Corollary 5.2(a)), and c = n^{1-theta} with 0 < theta < 1 works for clipped predictors (B-tempered-likelihood.md Theorem 6.3)."

IMPORTANT: the replacement texts in the first group of §6 ("Summaries of §5 elsewhere in red-team.md") are being applied verbatim to red-team.md in parallel. Do not change them unless a point requires it. If you must change one, list each changed replacement (which red-team place, old and new sentence) in the redteam_sync field of your result; otherwise return an empty list.

Record keeping: update the header (it says the material added after the first check "has not been reviewed"; it has now been reviewed by the second re-refereeing round), cite the four re-refereeing reports by relative path (../verification/depth-two-referee-*.md) wherever §9 or the header mention the checks, rename "check of the revision" to "first re-refereeing round" consistently (keep the S1-S6 / LC1-LC9 labels), and add a final table "Second re-refereeing round" with one row per point: report, point, resolution (fixed / weakened / rebutted / fixed (lead editor)), where. Update §0.5's title and text if needed so that the change log stays accurate, and add a short §0.6 for this round's changes. Keep all result numbers. Paths must resolve from research-notes/. Return the file path, a summary, and redteam_sync.`

const CHECK = `You are an independent checker of a revised research note. Your job is to find problems; default to reporting an issue when uncertain.

The note ${R}/research-notes/depth-two.md was revised to answer the points of ${R}/verification/depth-two-referee-scope-2.md and ${R}/verification/depth-two-referee-logic-computation-2.md. The pre-revision text is ${S}/stage/depth-two.r2-final-candidate.md (diff against it; note that three erratum edits in §6 were made by the lead editor and are expected). Check: (a) every point of both reports is resolved as the note's last record table says, by a correct fix or a valid rebuttal; (b) every changed passage is mathematically correct (re-derive; run Python where useful, scratch ${S}/stage/check-depth2-r3/); (c) no refereed statement was strengthened, and any new remark is marked as not refereed with a complete proof; (d) the record tables, §0.5/§0.6 and the header are accurate; (e) links resolve from research-notes/. Write a short report to ${S}/stage/check-depth2-r3.md and return the structured verdict ('correct' only if everything checks; 'minor_fixes' for small remaining problems; 'major_flaw' if a revision introduced an error).`

phase('Revise')
const rev = await agent(TASK, { label: 'revise:depth2:r3', phase: 'Revise', schema: REVISE_SCHEMA })
phase('Check')
const chk = await agent(CHECK, { label: 'check:depth2:r3', phase: 'Check', schema: VERDICT_SCHEMA })
return { rev, chk }
