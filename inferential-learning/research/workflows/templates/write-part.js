export const meta = {
  name: 'write-paper-PART',
  description: 'Draft paper sections (LaTeX) from verified theory files: PARTDESC',
  phases: [{ title: 'Draft', detail: 'one writer per section (+ its proof appendix)' }, { title: 'Check', detail: 'independent fidelity check per section' }],
}
const ROOT = '/home/user/AI-works/inferential-learning'
const P = ROOT + '/paper'
const SECTIONS = __SECTIONS__

const SUM = { type: 'object', properties: {
  files: { type: 'array', items: { type: 'string' } },
  compiles: { type: 'boolean' },
  approx_pages_main: { type: 'number' }, approx_pages_appendix: { type: 'number' },
  results: { type: 'array', items: { type: 'object', properties: { label: { type: 'string' }, kind: { type: 'string' }, source: { type: 'string' }, one_line: { type: 'string' }, status: { type: 'string' } }, required: ['label', 'kind', 'source', 'one_line', 'status'] } },
  concerns: { type: 'array', items: { type: 'string' } } }, required: ['files', 'compiles', 'approx_pages_main', 'approx_pages_appendix', 'results', 'concerns'] }
const CHK = { type: 'object', properties: { issues: { type: 'array', items: { type: 'object', properties: { location: { type: 'string' }, severity: { type: 'string', enum: ['fatal', 'major', 'minor'] }, problem: { type: 'string' }, fix_applied: { type: 'boolean' } }, required: ['location', 'severity', 'problem', 'fix_applied'] } }, compiles_after: { type: 'boolean' }, summary: { type: 'string' } }, required: ['issues', 'compiles_after', 'summary'] }

const writerPrompt = s => `You are writing one section of a research paper (LaTeX) for a mathematically and philosophically literate audience. Project context: ${ROOT}/research/00-brief.md (the question), ${ROOT}/research/02-master-plan.md (thesis), ${P}/OUTLINE.md (section plan and theorem sources — follow it), ${P}/NOTATION.md (MANDATORY unified notation), ${P}/preamble.tex (macros and theorem environments; do not edit it — if you need a new macro, define it with \\providecommand at the top of your own file).

YOUR SECTION: ${s.title} — main file ${P}/sections/${s.key}.tex${s.app ? `, proof appendix ${P}/sections/app-${s.key}.tex` : ''}, references ${P}/bib/${s.key}.bib (BibTeX; real references only, taken from the project's literature memos; omit anything you cannot attribute confidently).
SOURCES: ${s.sources}. IMPORTANT: the theory files have been adversarially verified; each ends with a '## Verification log' and there are reports in ${ROOT}/research/verification/. Use the REPAIRED statements and scopes; never reintroduce a retracted or overstated claim.
CONTENT: ${s.content}

Requirements:
- Start with \\section{...}\\label{sec:${s.key}}${s.app ? ` and the appendix file with \\section{Proofs for Section~\\ref{sec:${s.key}}}\\label{app:${s.key}}` : ''}. Label theorems as thm:${s.key}:<short>, lem:..., prop:..., def:..., etc. Cross-section references use labels sec:setting, sec:search, sec:caution, sec:imitation, sec:coherence, sec:twotier, sec:simplicity, sec:existence, sec:informal, sec:physics, sec:experiments, sec:philosophy, sec:open (and app:<key>).
- Main text: motivate each result in a sentence or two, define precisely, state theorems precisely (with all hypotheses), give short proofs inline when they are a few lines, otherwise a proof idea plus 'Full proof in Appendix~\\ref{app:${s.key}}'. After major results add a short 'Reading' paragraph explaining what it means for the user's question (learning which inferences are valid; coherence; contexts; justification). Credit known results explicitly (e.g. 'This is essentially Natarajan (1987)'); say when a result is 'trivial once set up'.
- Mark each theorem's provenance with \\src{...} pointing to the research file and its numbering (e.g. \\src{T1 Thm 3.1}); mark status with \\status{proof sketch}/\\status{computed}/\\status{conjecture} where applicable.
- Appendix: complete rigorous proofs (adapt from the sources; fix presentation; do not invent new claims). If a source proof is only a sketch, keep it labelled as a sketch.
- Length: main text roughly ${s.pages} pages; appendix as long as needed.
- Must compile: run ${P}/test-section.sh ${s.key}${s.app ? ` app-${s.key}` : ''} and fix all LaTeX errors (undefined cross-section references are fine).
Return the structured summary (list every theorem/lemma/definition you stated with its label and source).`

const checkPrompt = (s, w) => `You are a meticulous referee checking a drafted paper section against its sources. Section files: ${P}/sections/${s.key}.tex${s.app ? ` and ${P}/sections/app-${s.key}.tex` : ''}. Sources: ${s.sources} (use the repaired statements: see each theory file's '## Verification log' and ${ROOT}/research/verification/). Check: (1) every theorem statement in the draft matches a verified source statement (hypotheses not dropped, scope not widened, constants right); (2) proofs in the appendix are complete and correct (no silent gaps); (3) no retracted/overstated claims (e.g. claims fixed in verification logs); (4) notation follows ${P}/NOTATION.md; (5) citations are real and correctly attributed; (6) the prose does not overclaim novelty or generality. FIX problems directly in the section files (minimal edits), re-run ${P}/test-section.sh ${s.key}${s.app ? ` app-${s.key}` : ''} to ensure it compiles, and report each issue with fix_applied. Writer's summary for reference: ${JSON.stringify(w || {}).slice(0, 6000)}`

phase('Draft')
const out = await pipeline(SECTIONS,
  s => agent(writerPrompt(s), { label: `write:${s.key}`, phase: 'Draft', schema: SUM }),
  (w, s) => agent(checkPrompt(s, w), { label: `check:${s.key}`, phase: 'Check', schema: CHK }).then(c => ({ key: s.key, writer: w, check: c })))
return out
