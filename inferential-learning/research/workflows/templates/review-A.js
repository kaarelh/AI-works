export const meta = {
  name: 'paper-review-A',
  description: 'Whole-paper review (report-only): math-core, math-advanced, math-applied, consistency',
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
  "key": "math-core",
  "lens": "Mathematical correctness of the core formal sections: setting, search, caution, imitation, coherence (sections/*.tex and their app-*.tex). Pick the ~12 most important results (e.g. lem:search:stepwise, thm:search:tonk, thm:caution:vs, thm:caution:esc, thm:caution:ville, thm:imitation:coupon, cor:imitation:systematic, thm:coherence:halving, thm:coherence:post, thm:coherence:cpc, thm:coherence:carnap, thm:coherence:telltale, thm:coherence:popper, thm:coherence:residue) and re-check statement and appendix proof line by line against the verified source in research/theory (honor Verification logs). Also check every Lean tag \\leanok{...} in these sections names a real declaration (grep lean/InfLearn) whose statement matches the paper statement's scope (see lean/README.md fidelity column)."
 },
 {
  "key": "math-advanced",
  "lens": "Mathematical correctness of the two-tier, simplicity and existence sections (twotier.tex, simplicity.tex, existence.tex and their app-*.tex). Re-check the ~10 most important results (thm:twotier:main and its N_1 formula, prop:twotier:practice, thm:twotier:burnin, thm:twotier:depth, cor:twotier:cpc, thm:twotier:arith, thm:simplicity:kink, thm:simplicity:separable, thm:simplicity:validation, thm:simplicity:division, thm:existence:points, thm:existence:bilindenbaum, thm:existence:arity, thm:existence:omega, thm:existence:computability) against research/theory/T5,T6,T7 (honor both repair rounds of T7). Check Lean tags as above."
 },
 {
  "key": "math-applied",
  "lens": "Mathematical correctness of the informal-mathematics and physics sections (informal.tex, physics.tex and app-*.tex). Re-check the ~10 most important results (thm:informal:soundness, thm:informal:identify, thm:informal:objects, thm:informal:paradoxes, thm:informal:frz, thm:informal:robust, prop:informal:emergence, thm:physics:eternalism, thm:physics:realizability, thm:physics:nofree, thm:physics:stipulation, thm:physics:relative, thm:physics:judgment, thm:physics:superval, thm:physics:projectile) against research/theory/T3,T4 (honor Verification logs; T3's Def 5.2 checklist). Spot-check the worked EuPhO numbers by re-running research/theory/T3-checks scripts (sps_checker.py etc.)."
 },
 {
  "key": "consistency",
  "lens": "Cross-section consistency and rendering. (a) Search /home/user/AI-works/inferential-learning/research/paper-review/main.txt for rendering defects: '??', stray macro names, broken math, garbled symbols, overfull content; map each to its source. (b) Notation consistency across sections versus paper/NOTATION.md (e.g. channel names (P),(C),(W) vs (O); R^P, Sigma^P; 'designated contexts'; soundness notions); conflicting macro definitions via \\providecommand across sections (grep all \\providecommand and \\newcommand in sections/*.tex and find same-name different-definition collisions \u2014 these silently break later sections). (c) Every claim in intro.tex, abstract.tex, philosophy.tex and open.tex that cites a result (\\cref) must accurately describe that result as stated in the body (check each one). (d) The intro's verification statistics ('four false statements and about twenty significant gaps', 'one theorem needed a second repair round', 'about fifty paper results machine-checked, 14,600 lines') against research/verification/*.md and lean/README.md / app-lean.tex."
 }
]
phase('Review')
const res = await parallel(REVIEWERS.map(r => () => agent(`${COMMON.replace('REVIEWER', r.key)}\n\nYOUR LENS (${r.key}): ${r.lens}`, { label: `review:${r.key}`, phase: 'Review', schema: SCHEMA })))
return res.filter(Boolean)
