export const meta = {
  name: 'write-paper-part1',
  description: 'Draft paper sections (LaTeX) from verified theory files: part1DESC',
  phases: [{ title: 'Draft', detail: 'one writer per section (+ its proof appendix)' }, { title: 'Check', detail: 'independent fidelity check per section' }],
}
const ROOT = '/home/user/AI-works/inferential-learning'
const P = ROOT + '/paper'
const SECTIONS = [
 {
  "key": "setting",
  "title": "Setting: judgments, steps, rules, provers, and three channels",
  "app": false,
  "pages": 5,
  "sources": "/home/user/AI-works/inferential-learning/research/theory/T1-soundness-under-search.md \u00a71, /home/user/AI-works/inferential-learning/research/theory/T2-coherence-as-negative-data.md \u00a71, /home/user/AI-works/inferential-learning/research/theory/T7-two-tier-coherent-inferential-learner.md \u00a71, /home/user/AI-works/inferential-learning/research/theory/T3-contexts-idealization-export.md \u00a71 (contexts preview only)",
  "content": "Unified formal setting used by the whole paper: judgments and positions (single/multiple conclusion; Restall's reading of Gamma |- Delta as 'asserting Gamma while denying Delta is out of bounds'), steps P |> j, rule sets and derivability closure Cl_R, Sound(R); schemas, instances, Plotkin lgg and the rank mu; hypothesis classes (step sets vs structural consequence relations vs meanings-as-valuation-sets); practice R^P = R* \u222a R_F; the three channels (P) practice/imitation (positive steps, possibly tagged with rule names, possibly noisy), (C) coherence (designated contexts / certified positions; negative bags), (W) world (truth values on a fragment, counterexample objects evaluated line by line, computation with fresh randomness, simulation); the prover/verifier protocol (ACCEPT/REJECT/ESCALATE), soundness notions (deterministic, delta-sound uniformly over adaptive provers, depth-relative), cost notions (escalations, mind changes, detections); a one-paragraph preview of contexts (ist(c,phi); suppositions vs idealizations) pointing to Section 11. Include one running example used across the paper: propositional natural deduction with a human who sometimes affirms the consequent, and school algebra with the 'freshman's dream' and unguarded cancellation x/x -> 1. Keep definitions crisp; no theorems needed except trivial facts."
 },
 {
  "key": "search",
  "title": "Search makes soundness a worst-case property",
  "app": true,
  "pages": 6,
  "sources": "/home/user/AI-works/inferential-learning/research/theory/T1-soundness-under-search.md (\u00a72, Lemma 1.1), /home/user/AI-works/inferential-learning/research/theory/T2-coherence-as-negative-data.md (Thm 2.4 only), /home/user/AI-works/inferential-learning/research/lit/L3-learning-to-reason-and-limit-inquiry.md (Lemma A commitment-order, as repaired; see its Verification log), /home/user/AI-works/inferential-learning/research/verification/ (T1, L3 reports), and the experiment report /home/user/AI-works/inferential-learning/research/../code/results/adversarial_prover.md for a short illustrative pointer",
  "content": "Per OUTLINE \u00a73: T1 Lemma 1.1; T1 Thm 2.1 + Cor 2.2 (with the repaired scope of 'every output trivializes'); T1 Prop 2.3 (repaired: pure schemas / purification lemma); T1 Prop 2.4; L3 Lemma A (repaired: sufficient condition, per-scene validity, fresh randomness version with degree bound); T2 Thm 2.4 (doctrinal paradox for verifier ensembles). End with a short paragraph pointing to the adversarial-prover experiment in Section 12 (numbers: gradient boosting AUC 0.995 in distribution, still proves 16.3/23 false goals at 99% calibrated precision; the learned calculus with world feedback proves 0/23 false and 32.3/33 true), stating these are prior-known phenomena in ML practice (cite Gao, Schulman, Hilton 2023 reward model overoptimization) and that the theorem explains why."
 },
 {
  "key": "caution",
  "title": "Cautious verification and its price",
  "app": true,
  "pages": 8,
  "sources": "/home/user/AI-works/inferential-learning/research/theory/T1-soundness-under-search.md (\u00a73-4, as repaired), /home/user/AI-works/inferential-learning/research/verification/T1-soundness-under-search-verification.md, /home/user/AI-works/inferential-learning/research/lit/L2-reliable-selective-kwik.md (for literature: Rivest-Sloan reliable learning, KWIK, El-Yaniv-Wiener, Waudby-Smith & Ramdas 2020)",
  "content": "Per OUTLINE \u00a74: T1 Thm 3.1 (repaired: joint-probability form of optimality for randomized verifiers), Thm 3.2 (escalation dimension = positive elasticity), Prop 3.3 (intersection-closed classes; Natarajan; Helmbold-Sloan-Warmuth), Lemmas 1.2-1.3 (rank and witness events), Thm 3.4, Prop 3.5 (with signature caveat), Thm 3.6 (repaired justification), Thm 3.7 (with the linear-flat-schema scope), Conj 3.8 (report evidence honestly, including the h=5 ceiling caveat), Thm 3.9; Bayes-conservative: Thm 4.1, Thm 4.2 (credit Waudby-Smith & Ramdas 2020 for the prior-posterior-ratio martingale), Prop 4.3, Thm 4.4, Cor 4.5, Cor 4.6. Include a cost table (class -> escalation cost) and the slogan 'structure, not the prior, makes sound learned verification affordable'."
 },
 {
  "key": "imitation",
  "title": "Imitation: what positive examples fix",
  "app": true,
  "pages": 7,
  "sources": "/home/user/AI-works/inferential-learning/research/theory/T1-soundness-under-search.md (\u00a75-6, as repaired), /home/user/AI-works/inferential-learning/research/verification/T1-soundness-under-search-verification.md, /home/user/AI-works/inferential-learning/research/lit/L1-positive-data-learning.md (Gold, Angluin, Wright, Shinohara, Plotkin, Lange-Zeugmann), /home/user/AI-works/inferential-learning/research/lit/L9-physics-solutions-verification.md (TC1 dimension inference, only as a remark marked sketch), experiment report /home/user/AI-works/inferential-learning/research/../code/results/algebra_learning.md",
  "content": "Per OUTLINE \u00a75: T1 Thm 5.1 and Prop 5.2 (anchors vs tell-tales, repaired), Thm 5.3 (coupon collector exact identification with the constants), Thm 5.4 (untagged unions), Cor 5.5 (systematic OOD generalization \u2014 the formal sense in which 'finite usage fixes inferential role for unbounded use'), Prop 6.1 (one error collapses the lgg), Thm 6.2-6.3 (trimmed version space, with the ground-rule caveat), Thm 6.4 (indistinguishability; correct factor-2 statement as repaired), Cor 6.5 (systematic errors are rules). Remark: dimension inference (finest grading via Smith normal form) as an exactly solvable instance of learning meaning from positive examples, marked as a sketch from the L9 memo. Close with the algebra experiment pointer: positive data alone recover rule shapes and generalize OOD but never display guards; fallacies reach support."
 },
 {
  "key": "coherence",
  "title": "Coherence: what contradictions fix",
  "app": true,
  "pages": 12,
  "sources": "/home/user/AI-works/inferential-learning/research/theory/T2-coherence-as-negative-data.md (all, as repaired), /home/user/AI-works/inferential-learning/research/verification/T2-coherence-as-negative-data-verification.md, /home/user/AI-works/inferential-learning/research/lit/L3-learning-to-reason-and-limit-inquiry.md (Thm D trilemma, Lemma E', as repaired), /home/user/AI-works/inferential-learning/research/lit/L4-inferentialism-and-categoricity.md (Carnap, Restall, Rumfitt, Belnap, Prior, Kripke), /home/user/AI-works/inferential-learning/research/lit/L5-logic-facts.md (Post-completeness, Glivenko, Godel-Rosser, Shoenfield), /home/user/AI-works/inferential-learning/research/lit/L11-justification-and-reflective-equilibrium.md (eliminative vs confirmational coherence; Bovens-Hartmann/Olsson), experiment report /home/user/AI-works/inferential-learning/research/../code/results/prop_learning_quick.md",
  "content": "Per OUTLINE \u00a76, in subsections: 6.1 coherence as negative data (Lemma 2.1, Prop 2.9 caution gets no signal, Thm 2.2 oligarchic halving + Prop 2.3, Thm 2.5, Thm 2.6 silent over-generalizations, Prop 2.7/Cor 2.8 as repaired: fixed target-independent designated family); 6.2 Post-completeness: when coherence suffices (Thm 3.1, Prop 3.2, Thm 3.3, Props 3.4-3.5, Thm 3.6 IPC blindness, Prop 3.11 complete theories at theorem level only \u2014 as repaired; Prop 7.1 forward-reference to Section 11); 6.3 arithmetic (Lemma 3.7, Thm 3.8, Thm 3.9 Turing chain, Thm 3.10 Popperian learner and Sigma2 barrier, L3 Thm D in its repaired form \u2014 NOT the retracted 'ceiling' slogan); 6.4 Carnap's problem is Gold's problem (Lemma 4.1, Thm 4.2, Thm 4.3 denial-rank trichotomy, Thm 4.4 bilateral tell-tale with the repaired (d), Prop 4.5 compositional prior); 6.5 tonk, harmony and conservativity (Prop 5.1-5.3, Thm 5.3 complexity); 6.6 fallacies and the Kripkensteinian residue (Thm 6.1, Cor 6.2, examples of surviving fallacies, Thm 6.4 with the repaired (iii)); 6.7 a remark on eliminative vs confirmational coherence (L11; Bovens-Hartmann/Olsson; consensus does not amplify under common cause \u2014 state as remark with short argument)."
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
