export const meta = {
  name: 'final-edit-pass',
  description: 'Apply the final README and cross-reference check findings, then check each edit pass independently',
  phases: [{ title: 'Edit' }, { title: 'Check' }],
}
const NNG = '/workspace/ai-works/neural-network-generalization'
const R = NNG + '/works-in-progress/agnostic-learning'
const S = '/tmp/claude-0/-workspace/e8ce7448-1256-507d-9f63-d716a14ba11f/scratchpad/agnostic'
const EDIT_SCHEMA = { type: 'object', properties: { summary: { type: 'string' }, rejected: { type: 'array', items: { type: 'object', properties: { id: { type: 'string' }, reason: { type: 'string' } }, required: ['id', 'reason'] } } }, required: ['summary', 'rejected'] }
const VERDICT_SCHEMA = {
  type: 'object',
  properties: {
    verdict: { type: 'string', enum: ['correct', 'minor_fixes', 'major_flaw'] },
    issues: { type: 'array', items: { type: 'object', properties: {
      severity: { type: 'string', enum: ['major', 'minor'] }, file: { type: 'string' }, location: { type: 'string' },
      description: { type: 'string' }, suggested_fix: { type: 'string' } },
      required: ['severity', 'file', 'location', 'description', 'suggested_fix'] } },
    summary: { type: 'string' },
  },
  required: ['verdict', 'issues', 'summary'],
}
const COMMON = `Folder: ${R} (research notes in research-notes/, referee reports and their index in verification/, scripts in checks/). NNG/ is ${NNG}/. The project asks whether Bayesian learning with MLPs is an agnostic learner; the notes are final and refereed, and you must not change any theorem, proof or number in them.
Writing style: plain, precise prose; keep each sentence's scope exactly right; add only the qualifiers that matter; do not bloat the text. Prefer the suggested fix when it is correct, but verify every factual claim in it against the cited note before writing it.`
const PASSES = [
  { key: 'readme',
    issues: `${S}/stage/final-readme-issues.json`, report: `${S}/stage/final-readme-check.md`,
    files: `${R}/README.md (the folder's main README), ${R}/verification/README.md (the verification index), and, in ${NNG}/README.md, only the agnostic-learning row of the works-in-progress table and the agnostic-learning paragraph under "Label-noise research"`,
    extra: 'Do not edit research notes. In the verification index, keep every verdict and link; correct counts and general statements as the issues say, after checking the reports. For the working/ folder (it stays on the working branch and is not published to main), word the README sentence so that it is true on both branches (for example, "On the working branch, working/ holds ..."), and keep the link.' },
  { key: 'xref',
    issues: `${S}/stage/final-xref-issues.json`, report: `${S}/stage/final-xref-check.md`,
    files: `the research notes in ${R}/research-notes/ named in the issues`,
    extra: 'These are lead-editor edits to final notes: citation, status and summary corrections only. For red-team.md §7 item 1, §0 item 7 and §6.1, add "[At finalization: ...]" notes in the style the note already uses, rather than rewriting the red-team text. For every note you edit, append one sentence per edit to its existing closing paragraph of lead-editor notes (A: "Lead editor\'s notes at finalization"; B: "Lead editor\'s notes at finalization"; depth-two: "Check of the final revision"; E: "Check of the scope revision"; C: "Check of the scope revision"; red-team: "Second check" paragraph; small-learner-width: after its "Second check of the revision" table) or, if the note has none (problem-brief.md, literature.md), state the change in the italic header note (the brief) or as a bracketed "At finalization" note (literature). Do not edit README files.' },
]
const EDIT = (p) => `You are the lead editor's assistant for the final edit pass. ${COMMON}

An adversarial checker reported issues; they are in ${p.issues} (JSON list; each has id, severity, file, location, quote, description, suggested_fix), and its full report is ${p.report}. Apply EVERY issue in that list to ${p.files}. For each issue: open the cited note(s) and check the claim; if valid, fix the text (the quote field locates it; if the quote no longer matches exactly, find the passage by its location); if you judge it invalid or already fixed, leave the text and record why. ${p.extra}
Write a resolution log to ${S}/stage/final-${p.key}-resolutions.md: one line per issue id with "fixed", "weakened", "already fixed" or "rejected" and a few words. Return a summary and the list of rejected issues with reasons.`
const CHECK = (p) => `You are an independent checker of a final edit pass. Your job is to find problems; default to reporting an issue when uncertain. ${COMMON}

The issues in ${p.issues} were to be applied to ${p.files}. The editor's log is ${S}/stage/final-${p.key}-resolutions.md. The pre-edit copies are in ${S}/stage/prefinal/ (README.md, verification/README.md, NNG-README.md, research-notes/*.md); diff every edited file against its copy. Check: (a) every issue was resolved as the log says, and every rejection is justified; (b) every changed sentence is true against the cited notes, with the hypotheses that matter, and claims no more than is proved; (c) nothing else changed, and no theorem, proof or number of a note was altered; (d) all links still resolve (run python3 ${NNG}/verify_collection.py and report any failure). Write a short report to ${S}/stage/final-${p.key}-edit-check.md and return the structured verdict ('correct' only if everything checks; 'minor_fixes' for small remaining problems, each with an exact suggested fix; 'major_flaw' if an edit introduced an error).`
const out = await pipeline(PASSES,
  (p) => agent(EDIT(p), { label: `edit:${p.key}`, phase: 'Edit', schema: EDIT_SCHEMA }),
  (ed, p) => agent(CHECK(p), { label: `check:${p.key}`, phase: 'Check', schema: VERDICT_SCHEMA }).then(chk => ({ key: p.key, ed, chk })))
return out
