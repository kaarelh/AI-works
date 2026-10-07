export const meta = {
  name: 'paper-edit-NAME',
  description: 'Apply whole-paper review issues and readability cuts, one editor per section: GROUPSDESC',
  phases: [{ title: 'Edit', detail: 'one editor per section file group' }],
}
const ROOT = '/home/user/AI-works/inferential-learning'
const P = ROOT + '/paper'
const RV = ROOT + '/research/paper-review'
const GROUPS = __GROUPS__
const SCHEMA = { type: 'object', properties: {
  applied: { type: 'array', items: { type: 'string' } },
  declined: { type: 'array', items: { type: 'object', properties: { issue: { type: 'string' }, reason: { type: 'string' } }, required: ['issue', 'reason'] } },
  cuts: { type: 'string', description: 'what was moved to the appendix or deleted, with approximate word counts' },
  compiles: { type: 'boolean' } }, required: ['applied', 'declined', 'cuts', 'compiles'] }
const prompt = g => `You are the editor of ONE section of a long research report. You own exactly these files and must not edit any others: ${P}/sections/${g}.tex${g === 'experiments' ? '' : `, ${P}/sections/app-${g}.tex`}, ${P}/bib/${g}.bib (if it exists).
Inputs:
1. Review issues for your files (JSON, each with reviewer, file, location, severity, problem, proposed_fix): ${RV}/edits/${g}-issues.json. Apply every fatal and major issue. Apply minor issues unless the proposed fix is wrong (then explain why in 'declined'). Verify each fix against the sources before applying: theory files ${ROOT}/research/theory/T*.md (honor their '## Verification log' sections), verification records ${ROOT}/research/verification/ (incl. T7's Round 3 re-verification), the Lean files ${ROOT}/lean/InfLearn/*.lean and ${ROOT}/lean/README.md, code results ${ROOT}/code/results/*.md.
2. Readability cut plan: ${RV}/readability.md. Apply the cuts that concern your section: move proof-heavy or computation-heavy passages and secondary results into your appendix file (keep every label and every result statement or a one-line pointer to it in the main text), replace exact duplicates of material that lives in another section by a \\cref to it, and remove internal workflow jargon (e.g. 'TOSU', 'thread', 'memo', 'orchestrator', bare 'T4 Prop 7.1' in running text — provenance belongs in \\src tags). Target: main text of your section at least 15% shorter without losing any result.
3. Naming of the commissioner: replace every 'the user' / 'his' / 'K. Hänni' style reference with 'the motivating notes' (or 'Hänni's notes'), and cite them as \\citep{hanni2026notes} at the first mention in your section (the bib entry exists in bib/intro.bib). Quotations from the notes must stay verbatim; keep hedges. Avoid repeating the profanity in 'wtf is that' except where the section's quotation of it is the main one (physics may keep one verbatim quotation).
4. Lean tags: ${RV}/orchestrator-lean-issues.md lists missing or stale \\leanok tags and fidelity remarks; apply those that concern your files. Every \\leanok{Name} must name a real declaration (grep ${ROOT}/lean/InfLearn) whose scope matches (see the map in ${P}/sections/app-lean.tex).
5. ${g === 'twotier' ? 'Note: the paper claims (twotier.tex around line 46) that the second-round repairs were checked only by their author and by computation; this is now outdated: a third referee re-checked them with no fatal or major findings (recorded in research/verification/T7-verification.md, "Round 3"). Update the text accordingly.' : 'Keep cross-references to other sections intact (labels sec:..., thm:..., etc. defined in other files must not be renamed).'}
6. Do not rename any existing \\label. Do not change notation defined in ${P}/sections/setting.tex or ${P}/NOTATION.md unless an issue requires it. Avoid \\providecommand macro names that may collide with other sections (prefix new macros with your section name).
Finally run ${P}/test-section.sh ${g}${g === 'experiments' ? '' : ` app-${g}`} and fix all LaTeX errors. Return the structured summary.`
phase('Edit')
const res = await parallel(GROUPS.map(g => () => agent(prompt(g), { label: `edit:${g}`, phase: 'Edit', schema: SCHEMA })))
return GROUPS.map((g, i) => ({ group: g, result: res[i] }))
