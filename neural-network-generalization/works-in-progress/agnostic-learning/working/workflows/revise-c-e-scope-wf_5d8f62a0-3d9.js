export const meta = {
  name: 'revise-C-E-scope',
  description: 'Answer the scope referee reports on the C and E notes, then check each revision independently',
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
const NOTES = [
  { key: 'C', file: 'C-fixed-temperature-bayes.md', report: 'C-scope.md', issues: 'issues 7, 8, 9, 10, 11 and 12 (issues 1-6 and 14 concern the README draft, issue 13 the brief; the lead editor handles those, so do not act on them, but list them in your record table as "answered in the README / brief by the lead editor")' },
  { key: 'E', file: 'E-finite-prior-scale.md', report: 'E-scope.md', issues: 'issues 5 (the parts in E: §0 row 6 and Answers (2)), 7, 8, 9 and 11 (issues 1-4, 6, 10 and the README parts of 5 concern the README draft; the lead editor handles those, so do not act on them, but list them in your record table as "answered in the README by the lead editor"). For issue 7, reword the two overstated sentences; do not add the zero-network comparison as a new result unless you write its proof out in full and mark it as not refereed. For issue 8, verify the referee\'s claims (the certified excess numbers near theta = 1/H, and that Lemma 2.2 with (C1)-(C2) gives the oracle inequality for the expected clipped Gibbs risk at widths N^gamma <= eps n^{1-theta}/4 for every theta in (0,1)) against the note before adding them; state only what you verified, with its hypotheses' },
]
const REVISE = (n) => `You are the author of the research note ${R}/research-notes/${n.file}. It is final apart from the points of a scope referee who reviewed it after its three revision checks: ${R}/verification/${n.report} (scripts in ${R}/checks/verify-${n.key}-scope/). Read the report completely and the note completely, and edit the note in place.

Address ${n.issues}. For each, fix the text if the point is valid (do not strengthen any statement; re-derive any number you add), or explain in the record why it is invalid. Keep every result number. Then: (1) update the note's opening paragraph so that its account of the refereeing mentions this scope report, with a relative link ../verification/${n.report}; (2) add, at the end of the note's referee record, a subsection "Scope referee" with a table of one row per issue of the report (all of them, including the ones handled by the lead editor): issue, short description, resolution (fixed / weakened / rebutted / answered in the README or brief by the lead editor), where. Paths must resolve from research-notes/. Return the file path and a summary.`
const CHECK = (n) => `You are an independent checker of a revised research note. Your job is to find problems; default to reporting an issue when uncertain.

The note ${R}/research-notes/${n.file} was revised to answer the scope report ${R}/verification/${n.report}. The pre-revision text is ${S}/stage/${n.key}-pre-scope.md (diff against it). Check that (a) each issue the author was asked to handle (${n.issues}) is resolved as the new "Scope referee" table says, by a correct fix or a valid rebuttal; (b) every changed passage is mathematically correct and claims no more than is proved (re-derive; run Python where useful, scratch ${S}/stage/check-${n.key}-scope/); (c) nothing else changed; (d) links resolve from research-notes/. Write a short report to ${S}/stage/check-${n.key}-scope.md and return the structured verdict ('correct' only if everything checks; 'minor_fixes' for small remaining problems; 'major_flaw' if a revision introduced an error).`
const out = await pipeline(NOTES,
  (n) => agent(REVISE(n), { label: `revise:${n.key}:scope`, phase: 'Revise', schema: REVISE_SCHEMA }),
  (rev, n) => agent(CHECK(n), { label: `check:${n.key}:scope`, phase: 'Check', schema: VERDICT_SCHEMA }).then(chk => ({ key: n.key, rev, chk })))
return out
