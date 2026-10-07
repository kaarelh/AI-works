export const meta = {
  name: 'schemas-edit-E1',
  description: 'Apply whole-paper review issues and length cuts to sections setting, universal and many (with appendices)',
  phases: [{ title: 'Edit', detail: 'one editor per section group' }],
}
const P = '/home/user/AI-works/axiom-schemas/paper'
const RV = '/home/user/AI-works/axiom-schemas/research/paper-review'
const R = '/home/user/AI-works/axiom-schemas/research'
const GROUPS = [
  { key: 'setting', files: ['setting.tex', 'app-setting.tex'] },
  { key: 'univ', files: ['universal.tex', 'app-universal.tex'] },
  { key: 'many', files: ['many.tex', 'app-many.tex'] },
]
const SCHEMA = { type: 'object', properties: {
  applied: { type: 'array', items: { type: 'string' } },
  declined: { type: 'array', items: { type: 'object', properties: { issue: { type: 'string' }, reason: { type: 'string' } }, required: ['issue', 'reason'] } },
  cuts: { type: 'string' }, other_files_touched: { type: 'string' }, main_pages_after: { type: 'number' }, compiles: { type: 'boolean' }, notes_for_final_editor: { type: 'string' } },
  required: ['applied', 'declined', 'cuts', 'compiles', 'notes_for_final_editor'] }
const prompt = g => `You are the editor of ONE section of a research paper (LaTeX, ${P}). You own exactly these files: ${g.files.map(f => P + '/sections/' + f).join(', ')} (and you may add entries to ${P}/bib/${g.key}.bib). Do not edit other files, except: updating a \\cref target in another section file when you remove/move a label it references (DECISIONS.md item 11), and adding a prefixed macro to preamble.tex if strictly needed.
Read FIRST: ${RV}/edits/DECISIONS.md (binding decisions for cross-cutting issues), ${RV}/edits/${g.key}-issues.json (all review issues touching your files; multi_file=true marks cross-cutting ones — handle your part per DECISIONS.md), and the full reviewer reports for context: ${RV}/review-*.md (especially review-readability.md for your section's cut plan). Conventions: ${P}/NOTATION.md. Ground truth for any mathematical question: ${R}/tracks/*/notes-final.md and referee.md, ${R}/prior/, code results ${P}/../code/results/.
Tasks: (1) Apply every fatal and major issue; apply minor issues unless the proposed fix is wrong (explain in 'declined'). Verify each fix against the sources before applying; for fatal issues re-check the mathematics yourself (reviewer scripts are in ${RV}/scratch/; you may run them). (2) Apply the length cuts for your section (DECISIONS.md item 10): move secondary material to your appendix with one-line pointers, delete duplication, tighten prose; keep every result statement (or a pointer) and every caveat. (3) Keep \\status/\\src conventions (definitions: \\src only). (4) Check your section reads well as a whole after the edits: an opening summary, clear statement of what it answers, consistent notation.
Then compile your files alone with: cd ${P} && ./test-section.sh ${g.files[0].replace('.tex', '')} ${g.files[1].replace('.tex', '')} — fix all errors. Finally run the full build under the lock: cd ${P} && flock /tmp/claude-0/paper-build.lock ./build.sh — and make sure nothing you did introduced undefined references (other editors are working concurrently on other sections; report problems that are theirs). Return the structured summary, including main_pages_after (your section's main-text length in the full build) and notes for the final editor (things intro/discussion/verification appendix must now say differently, e.g. weakened statements).`
phase('Edit')
const res = await parallel(GROUPS.map(g => () => agent(prompt(g), { label: `edit:${g.key}`, phase: 'Edit', schema: SCHEMA })))
return GROUPS.map((g, i) => ({ key: g.key, result: res[i] }))
