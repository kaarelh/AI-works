export const meta = {
  name: 'paper-review-B',
  description: 'Whole-paper review (report-only): honesty, citations, user-fidelity, readability',
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
const COMMON = `You are a reviewer of a long research report (LaTeX sources in ${P}/main.tex and ${P}/sections/*.tex; compiled text of the current PDF in /home/user/AI-works/inferential-learning/research/paper-review/main.txt, 263 pages; bibliography in ${P}/bib/all.bib generated from ${P}/bib/*.bib). Context: ${ROOT}/research/00-brief.md (the commissioning question) and ${ROOT}/research/02-master-plan.md. The theorems come from verified theory files ${ROOT}/research/theory/T*.md (each with a '## Verification log'), verification records in ${ROOT}/research/verification/, literature memos in ${ROOT}/research/lit/, Lean formalization in ${ROOT}/lean (README.md, audit-output.txt), code and results in ${ROOT}/code (README.md, results/*.md).
REPORT ONLY: do not edit any files. Write your full report as markdown to ${OUT}/REVIEWER.md and return the structured list of issues. Each issue must name the file where the fix belongs and give a concrete proposed fix (replacement text where possible). Be concrete and precise; do not report vague style preferences. Severity: fatal = false or seriously misleading claim; major = real gap, inconsistency, wrong reference, or overclaim that a careful reader would object to; minor = local clarity/typo.`
const REVIEWERS = [
 {
  "key": "honesty",
  "lens": "Overclaiming, scope and novelty across the WHOLE paper. Flag: claims of novelty for known results (the paper should credit Gold, Angluin, Plotkin, Natarajan, Rivest-Sloan, KWIK, Waudby-Smith & Ramdas, Post, Glivenko, Carnap/Shoesmith-Smiley/Rumfitt/Restall, Brown-Priest, information-based complexity (Traub-Wasilkowski-Wozniakowski), de Finetti, Gaifman, Reiter, Littlestone, etc. where relevant); statements stronger than the verified sources; places where 'trivial once set up' should be said; experimental claims not supported by code/results/*.md; anything presented as proved that is only a sketch/conjecture/computed. Also check that the paper consistently frames itself as checking/verification-first (it deliberately does not build a strong prover) and does not present toy experiments as evidence of scalability."
 },
 {
  "key": "citations",
  "lens": "Bibliography and attributions. For every entry in paper/bib/all.bib: is it a real publication with correct authors, title, venue and year? Use WebSearch/WebFetch (load via ToolSearch 'select:WebSearch,WebFetch') where possible; many publisher sites are blocked, so search snippets are acceptable evidence. Flag entries that look hallucinated or wrong, and propose corrections or removal (then the citing sentence must be adjusted \u2014 name the citing file). Also check in-text attributions (who proved what) in sections/*.tex for the 40 most important citations. Note which bib/<section>.bib file holds each problematic entry (merge_bib.py keeps the first entry per key in sorted filename order)."
 },
 {
  "key": "user-fidelity",
  "lens": "Fidelity to the commissioning person's notes and preferences. The work was commissioned by Kaarel H\u00e4nni; his notes are at /home/user/kaarelh/notes (digest: research/lit/L10-user-notes-digest.md). Check every place the paper quotes or paraphrases his notes or questions (grep for 'notes', 'commission', 'H\u00e4nni', 'user', quotes) for accuracy against the original note files, respectful tone, and correct hedging (he often hedges; do not make him sound more certain). Check that the paper does not refer to him as 'the user' in a way unsuitable for a paper (prefer 'the motivating notes' or similar), that his views (pluralism about meaning; distrust of limit framings; verification-first motivation; caution about publishing capability research) are represented accurately, and that the paper does not misattribute ideas to him. Also check the title page/author footnote (main.tex)."
 },
 {
  "key": "readability",
  "lens": "Structure, length and readability for a mathematically and philosophically literate reader. The main text is ~150 pages. Identify (1) redundancy: results or explanations repeated across sections (list exact duplicates and propose which copy to keep, replacing the other by a cross-reference); (2) passages in the main text that are proof-heavy and should move to the appendix; (3) sections whose opening does not tell the reader what the section establishes (propose a 3-5 sentence opening); (4) inconsistent tone (e.g. internal jargon like 'TOSU', memo names like 'T4 Prop 7.1' in running text instead of \\src tags, references to 'the orchestrator', 'thread', 'memo' that readers cannot follow). Propose concrete edits; aim for changes that cut at least 15% of main-text length without losing any result."
 }
]
phase('Review')
const res = await parallel(REVIEWERS.map(r => () => agent(`${COMMON.replace('REVIEWER', r.key)}\n\nYOUR LENS (${r.key}): ${r.lens}`, { label: `review:${r.key}`, phase: 'Review', schema: SCHEMA })))
return res.filter(Boolean)
