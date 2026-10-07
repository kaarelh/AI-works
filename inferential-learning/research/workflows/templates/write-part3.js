export const meta = {
  name: 'write-paper-part3',
  description: 'Draft paper sections (LaTeX) from verified theory files: twotier',
  phases: [{ title: 'Draft', detail: 'one writer per section (+ its proof appendix)' }, { title: 'Check', detail: 'independent fidelity check per section' }],
}
const ROOT = '/home/user/AI-works/inferential-learning'
const P = ROOT + '/paper'
const SECTIONS = [
 {
  "key": "twotier",
  "title": "An end-to-end theorem for formal mathematics: the two-tier learner",
  "app": true,
  "pages": 11,
  "sources": "/home/user/AI-works/inferential-learning/research/theory/T7-two-tier-coherent-inferential-learner.md (all, as repaired in TWO rounds \u2014 read both '### Round 1' and '### Round 2' parts of its Verification log; note e.g. the (OE) assumption in Thm 5.5, the corrected floor bound in Thm 6.6(e), the dropped third clause of (WS), the scoping of Prop 2.4(c), Prop 3.2, Prop 5.2(a), Thm 5.6, Cor 6.5, Thm 6.6(e)), /home/user/AI-works/inferential-learning/research/verification/T7-verification.md, the already-written sections /home/user/AI-works/inferential-learning/research/../paper/sections/setting.tex (definitions: channels, (WS), depth, soundness \u2014 REUSE its labels, do not redefine), search.tex, caution.tex, imitation.tex, coherence.tex (cite their results by label), the simulation scripts in /home/user/AI-works/inferential-learning/research/theory/T7-checks/ (e.g. ttl_sim.py; quote their numbers only after re-running), and the propositional experiment report /home/user/AI-works/inferential-learning/research/../code/results/prop_learning_quick.md (and prop_learning.md if present)",
  "content": "Per OUTLINE \u00a77. This is the paper's answer to 'a setup of this shape that provably works for formal math'. Structure: 7.1 why the naive two-tier claim is false (Prop 2.2 caution over practice asserts fallacies; Prop 2.4 caution-presumption dilemma) \u2014 present this honestly as a finding; 7.2 blame (Lemma 2.3 Reiter hitting-set duality \u2014 Lean-formalized as InfLearn.Blame.*, use \\leanok{Blame.iInter\\_maxClean\\_eq} etc.; Lemma 2.5 descent with trusted steps \u2014 L4.1 descent is Lean-formalized as InfLearn.Blame.LineArg.descent); 7.3 the learner TTL(d,delta): tier 0 (per-tag trimmed lgg), audit (descent first, minimal-conflict fallback; Lemma 3.1), tier 1 assertion (frozen at N_1), tier 2 sandbox (oligarchic halving; Prop 3.3 isolation and budget); 7.4 the main theorem (Thm 4.1, all clauses, with the N_1 formula); 7.5 every ingredient is necessary (Props 5.1-5.4, Thm 5.5 with (OE), Thm 5.6 blame symmetry, Thm 5.7 depth relativization, Prop 5.8); 7.6 specializations: CPC exact (Lemma 6.1 = Lean InfLearn.Post.schema_invalid_iff_closedRefutation; Cor 6.2; Prop 6.3 coherence alone: sound but lossy), complete decidable theories (Cor 6.5 with its repaired scope and the honest caveat that the decision procedure already checks steps), arithmetic is Popperian (Thm 6.6 with corrected (e)); 7.7 simulation evidence (ttl_sim: TTL unsound 0/80 and exact 20/20 at N=250 vs positive-only cautious tier unsound 72/80 \u2014 verify these by re-running before quoting) and the propositional experiment (bold IPC extension; Post probes); 7.8 reading in the user's terms: 'learning which inferences are valid' = learning the audited practice; 'learning meanings' = identification up to the residue."
 }
]

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
