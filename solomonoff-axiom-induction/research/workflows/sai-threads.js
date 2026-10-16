export const meta = {
  name: 'sai-threads',
  description: 'Continue the Solomonoff axiom induction research after a container restart: for the threads given in args, develop (or resume, or skip if done), two adversarial referees, revise; in mode "synthesis", the synthesis and a fresh final check',
  phases: [
    { title: 'Develop', detail: 'develop or resume the threads in args.develop / args.resume' },
    { title: 'Referee', detail: 'two adversarial referees per thread' },
    { title: 'Revise', detail: 'final records with cross-thread consistency' },
    { title: 'Synthesis', detail: 'only in mode synthesis' },
  ],
}
const ROOT = '/home/user/AI-works/solomonoff-axiom-induction'
const R = `${ROOT}/research`
const SC = `${R}/scouts`
const TR = `${R}/tracks`
const COMMON = `Research project in ${ROOT}: a paper on Solomonoff axiom induction (working name; the final name is undecided, so never build an argument on the name). Read the brief ${R}/00-brief.md in full first: it quotes the author's request verbatim and lists the sources: the author's notes (copies in ${R}/prior/, including hanni-condensation-concepts.md; the full notes repository is at /home/user/kaarelh/notes), the earlier report ../axiom-induction (paper/main.pdf and paper/sections, refereed records research/tracks/*/notes-final.md), ../axiom-schemas, and the two Solomonoff operator induction (SOI) papers ../solomonoff-operator-induction/paper and ../solomonoff-operator-induction/paper-steeper (notation: ../solomonoff-operator-induction/paper/NOTATION.md). Paths starting with ../ are relative to ${ROOT}. Conventions (from the brief): a status on every claim (proved, with a full proof; computed, with script and saved output; known, with an exact verified reference; proof sketch; conjecture; refuted, kept with its counterexample), seeded code with outputs saved next to each script, plain precise prose, a Verification log at the end of each record, no git commands that change repository state. Write only in your folder (given below). WebSearch works; arxiv.org, Google Docs and lesswrong.com cannot be fetched directly (search results and other mirrors are fine).`
const THREADS = {
  fundamentals: { title: 'Definitions and basic theorems of Solomonoff axiom induction', kind: 'math' },
  sfi: { title: 'Relation to Solomonoff operator induction (SOI), with the time-bounded equivalences and separations', kind: 'math' },
  philosophy: { title: 'What a theory does and what it is: argument map, the worked Kepler example, and limitations', kind: 'phil' },
  terms: { title: "Theoretical terms: Craig, Ramsey and the theoretician's dilemma in axiom induction", kind: 'math' },
  logic: { title: 'Random theories, Pi_1 truth and Goedel phenomena', kind: 'math' },
  shape: { title: 'Theory shape relative to a reasoner: know-how, intermediate concepts and the textbook point', kind: 'math' },
  laws: { title: 'Approximate laws, exceptions and the best system', kind: 'math' },
}
const DEV = { type: 'object', properties: { summary: { type: 'string' }, claims: { type: 'array', items: { type: 'object', properties: { id: { type: 'string' }, statement: { type: 'string' }, status: { type: 'string' } }, required: ['id', 'statement', 'status'] } }, open_problems: { type: 'array', items: { type: 'string' } } }, required: ['summary', 'claims'] }
const REF = { type: 'object', properties: { verdict: { type: 'string' }, issues: { type: 'array', items: { type: 'object', properties: { severity: { type: 'string' }, claim: { type: 'string' }, problem: { type: 'string' } }, required: ['severity', 'claim', 'problem'] } } }, required: ['verdict', 'issues'] }
const REV = { type: 'object', properties: { summary: { type: 'string' }, key_results: { type: 'array', items: { type: 'string' } }, unresolved: { type: 'array', items: { type: 'string' } } }, required: ['summary', 'key_results'] }
const refPrompts = t => t.kind === 'phil' ? [
  `ADVERSARIAL REFEREE A (philosophy) for thread "${t.key}" (${TR}/${t.key}/notes.md and its scripts). As a critical philosopher of science, attack every argument:
* steelman the objections: from the semantic view of theories, from Bayesian confirmation theory, from the best-system debate, and from the practice of physics;
* check that every characterisation of a cited author's view is accurate (verify by WebSearch);
* check that the Kepler example is correct as physics and as logic: orbital mechanics, which statements are only approximately true and by how much;
* check that limitations are not understated, and that formal results are not overclaimed as settling philosophical questions;
* check the brief's epistemic policy: the record asserts only what the evidence supports, whoever proposed it.
Write ${TR}/${t.key}/referee-A.md with a verdict and numbered issues (fatal / major / minor) with concrete fixes.`,
  `REFEREE B (formal accuracy and references) for thread "${t.key}" (${TR}/${t.key}/notes.md and its scripts):
* check every formal statement in the thread: prove or refute it, with INDEPENDENT seeded code in ${TR}/${t.key}/referee_code/ wherever something is computed (outputs saved next to each script);
* re-verify every bibliographic entry by WebSearch;
* check consistency with the shared notation ${R}/NOTATION-draft.md and with the other threads' records in ${TR}/.
Write ${TR}/${t.key}/referee-B.md with a verdict and numbered issues (fatal / major / minor) with concrete fixes.`,
] : [
  `ADVERSARIAL REFEREE A (proofs) for thread "${t.key}" (${TR}/${t.key}/notes.md and its scripts). Try to refute every claim marked proved. Check each proof line by line, for:
* hidden hypotheses and quantifier order;
* semimeasure versus measure, and the normaliser;
* r.e. versus decidable axiom sets, and the consistency of the induced theory;
* whether "proves" and "refutes" refer to the right theory;
* first-order details: languages, equality, constants, the deduction theorem, compactness;
* additive constants and logarithmic terms silently dropped;
* whether results of the earlier report and the SOI papers are used with their hypotheses.
Check that statements are no stronger than their proofs, and that each novelty claim agrees with the literature scout's record ${SC}/literature/notes.md. Write ${TR}/${t.key}/referee-A.md with a verdict and numbered issues (fatal / major / minor) with concrete fixes.`,
  `ADVERSARIAL REFEREE B (computation and counterexamples) for thread "${t.key}" (${TR}/${t.key}/notes.md and its scripts):
* write INDEPENDENT seeded code in ${TR}/${t.key}/referee_code/ (outputs saved next to each script) that tests the claims on small exactly enumerable cases: propositional or finite-signature fragments where provability is decidable; small enumerated classes of theories with explicit code lengths; exact posteriors and MAPs;
* search for counterexamples to every claim;
* re-run the developer's scripts and compare outputs.
Write ${TR}/${t.key}/referee-B.md with a verdict and numbered issues (fatal / major / minor) with concrete fixes and the evidence.`,
]
const developPrompt = (t, resumed) => `${COMMON}\n\nYou develop research thread "${t.key}" (${t.title}; kind ${t.kind}); folder ${TR}/${t.key}, with scripts in checks/. First read its brief ${TR}/${t.key}/00-brief.md, the shared notation ${R}/NOTATION-draft.md, ${R}/select.md, and the scout records the brief points to.
${resumed ? `An earlier run of this task was interrupted by a container restart. Partial records may already be in ${TR}/${t.key}/ (notes.md, scripts, outputs, refs.bib): read them first, check them, keep what is sound, and complete the task; re-run any script whose saved output is missing or incomplete.\n` : ''}* Prove the strongest true statements you can for the targets, with full proofs.
* Check small cases numerically where possible (seeded code, saved outputs).
* Keep refuted claims, with their counterexamples.
${t.kind === 'phil' ? '* Make every philosophical claim precise, attach the formal results that support it, and say which claims are arguments rather than theorems. Verify every reference by WebSearch.\n' : ''}Deliverable ${TR}/${t.key}/notes.md, ending with a Verification log. Return a structured summary of your claims with statuses.`
const revisePrompt = t => `${COMMON}\n\nRevise research thread "${t.key}" (folder ${TR}/${t.key}) after its referee reports referee-A.md and referee-B.md.
* Fix every fatal and major issue, or show with evidence why the referee is wrong. Handle the minor issues.
* Keep refuted claims, marked refuted, with their counterexamples.
* Read the other threads' current records (${TR}/*/notes-final.md if present, else notes.md) and ${R}/NOTATION-draft.md. Align definitions and notation, and add a "Cross-thread consistency" section.
Write ${TR}/${t.key}/notes-final.md: complete and self-contained, ending with a Verification log (what was checked, how, and with what result, including the referees' code). Do not delete notes.md.`

const mode = (args && args.mode) || 'threads'
if (mode === 'threads') {
  const done = new Set(args.done || [])
  const resumed = new Set(args.resume || [])
  const list = args.threads.map(k => ({ key: k, ...THREADS[k] }))
  log(`Threads: ${list.map(t => t.key + (done.has(t.key) ? ' (developed)' : resumed.has(t.key) ? ' (resume)' : '')).join(', ')}`)
  const res = await pipeline(list,
    t => done.has(t.key) ? Promise.resolve({ summary: 'developed earlier' }) : agent(developPrompt(t, resumed.has(t.key)), { label: `develop:${t.key}`, phase: 'Develop', schema: DEV }),
    (d, t) => parallel(refPrompts(t).map((p, i) => () => agent(`${COMMON}\n\nYou are ${p}`, { label: `referee${'AB'[i]}:${t.key}`, phase: 'Referee', schema: REF }))),
    (r, t) => agent(revisePrompt(t), { label: `revise:${t.key}`, phase: 'Revise', schema: REV }),
  )
  return res.map((x, i) => ({ thread: list[i].key, result: x }))
}
phase('Synthesis')
const keys = Object.keys(THREADS)
const syn = await agent(`${COMMON}\n\nYou are the SYNTHESIS editor. Read ${R}/select.md, ${R}/NOTATION-draft.md, the scout records in ${SC}/, and every thread's ${TR}/<key>/notes-final.md with its referee reports (threads: ${keys.join(', ')}). Write ${R}/notes-final.md with:
1. The headline results, ranked by importance and coolness, each stated exactly as proved (with pointers) and with its status.
2. The philosophy: the argument map with the Kepler example and the limitations, with the formal results attached where they support a claim, and an honest account of which claims remain arguments.
3. The relation to SOI, as a clean table of equivalences and separations.
4. What of ../axiom-induction is reused, restated or superseded.
5. A concrete paper plan:
   * title options;
   * the sections with their contents and the labels each will define;
   * which statements go in the main text and which proofs go in appendices;
   * page budgets (main text about 35–45 pages, appendices as needed);
   * the running example;
   * the related-work coverage, with the verified bibliography merged into ${R}/refs.bib (only entries verified by a scout or referee).
6. Open problems.
7. Any "Possible error in the author's view" notes that survived review (see the brief's epistemic policy), each with the claim, the reason and what the paper should say instead.
8. A consolidated Verification log.
Do not overstate anything relative to the thread records.`, { label: 'synthesis', phase: 'Synthesis', schema: REV })
const fin = await agent(`${COMMON}\n\nYou are a FRESH final checker.
* Compare ${R}/notes-final.md against the thread records ${TR}/{${keys.join(',')}}/notes-final.md and their referee reports. For every headline statement, check that it matches the thread statement exactly (hypotheses, constants, quantifiers, status) and that the cited proof exists and survived the referees.
* Check that every entry of ${R}/refs.bib was verified by a scout or referee.
* Re-run three of the most important scripts and compare them with the saved outputs.
Fix any mismatch in ${R}/notes-final.md minimally, and record what you changed in ${R}/final-check.md.`, { label: 'final-check', phase: 'Synthesis', schema: REV })
return { synthesis: syn, final: fin }
