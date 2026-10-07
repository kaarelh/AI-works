export const meta = {
  name: 'paper-review-NAME',
  description: 'Whole-paper review (report-only): REVIEWERSDESC',
  phases: [{ title: 'Review', detail: 'independent reviewers with distinct lenses; report only, no edits' }],
}
const ROOT = '/home/user/AI-works/inferential-learning'
const P = ROOT + '/paper'
const OUT = ROOT + '/research/paper-review'
const ISSUE = { type: 'object', properties: {
  file: { type: 'string', description: 'paper/sections/<name>.tex (or main.tex / bib/<name>.bib) where the fix must be made' },
  location: { type: 'string', description: 'label, line number or quoted snippet' },
  severity: { type: 'string', enum: ['fatal', 'major', 'minor'] },
  problem: { type: 'string' },
  proposed_fix: { type: 'string', description: 'concrete replacement text or precise instruction' } },
  required: ['file', 'location', 'severity', 'problem', 'proposed_fix'] }
const SCHEMA = { type: 'object', properties: { reviewer: { type: 'string' }, summary: { type: 'string' }, issues: { type: 'array', items: ISSUE } }, required: ['reviewer', 'summary', 'issues'] }
const COMMON = `You are a reviewer of a long research report (LaTeX sources in ${P}/main.tex and ${P}/sections/*.tex; compiled text of the current PDF in ${OUT}/main.txt, 263 pages; bibliography in ${P}/bib/all.bib generated from ${P}/bib/*.bib). Context: ${ROOT}/research/00-brief.md (the commissioning question) and ${ROOT}/research/02-master-plan.md. The theorems come from verified theory files ${ROOT}/research/theory/T*.md (each with a '## Verification log'), verification records in ${ROOT}/research/verification/, literature memos in ${ROOT}/research/lit/, Lean formalization in ${ROOT}/lean (README.md, audit-output.txt), code and results in ${ROOT}/code (README.md, results/*.md).
REPORT ONLY: do not edit any files. Write your full report as markdown to ${OUT}/REVIEWER.md and return the structured list of issues. Each issue must name the file where the fix belongs and give a concrete proposed fix (replacement text where possible). Be concrete and precise; do not report vague style preferences. Severity: fatal = false or seriously misleading claim; major = real gap, inconsistency, wrong reference, or overclaim that a careful reader would object to; minor = local clarity/typo.`
const REVIEWERS = __REVIEWERS__
phase('Review')
const res = await parallel(REVIEWERS.map(r => () => agent(`${COMMON.replace('REVIEWER', r.key)}\n\nYOUR LENS (${r.key}): ${r.lens}`, { label: `review:${r.key}`, phase: 'Review', schema: SCHEMA })))
return res.filter(Boolean)
