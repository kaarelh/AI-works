export const meta = {
  name: 'verify-theory-C',
  description: 'Adversarial verification and repair of theory developments (T5, T6, T7)',
  phases: [
    { title: 'Verify', detail: 'independent refutation attempts per theorem group' },
    { title: 'Repair', detail: 'one repair agent per file applies fixes' },
    { title: 'Reverify', detail: 'second-round check of repaired fatal/major items' },
  ],
}
const ROOT = '/home/user/AI-works/inferential-learning'
const GROUPS = [
 {
  "key": "T5",
  "file": "T5-steeper-simplicity-and-normativity-from-imitation.md",
  "parts": [
   "Sections 1-2 only: setup definitions, Lemma 1.2, Thm 2.1 (no adaptation with private randomness), Prop 2.3, Thm 2.5 (kink theorem: shared vs private randomness; check the Fourier/list-decoding and coding-theorem steps carefully), Prop 2.6 (in-context universality); re-run research/theory/T5-checks scripts c1,c2,c5.",
   "Sections 3-5 and the rest: Lemma 3.1 (convex hull), Thm 3.2 (rate threshold), Thm 3.3 (idealized K version), any realizability-of-hull-shapes result, Thm 4.1, Thm 4.3 (non-identifiability of c), Prop 4.4 (guard erosion), the pathologies list, Thm 5.2 (division of labour), Prop 5.3 (repair by sacrifice); re-run T5-checks c3,c4."
  ]
 },
 {
  "key": "T7",
  "file": "T7-two-tier-coherent-inferential-learner.md",
  "parts": [
   "Sections 1-3: the model and assumptions (WS etc.), Lemma 2.1, Prop 2.2, Lemma 2.3 (Reiter hitting-set duality), Prop 2.4, Lemma 2.5 (descent with trusted steps), Lemma 3.1 (audit correctness), Prop 3.3 (sandbox isolation and budget), and Theorem 4.1 (end-to-end: check every clause, the sample-size N_1 formula, and that the event G really depends only on the first N_1 steps).",
   "Sections 5-6: lower bounds Prop 5.1-5.4, Thm 5.5 (rare refuter), Thm 5.6 (blame symmetry), Thm 5.7 (depth relativization necessary; check the halting-problem encoding), Prop 5.8; specializations Lemma 6.1/Cor 6.2 (CPC exact; check the T/F-substitution lemma), Prop 6.3, Lemma 6.4/Cor 6.5 (complete decidable theories), Thm 6.6 (arithmetic: Popperian); re-run any simulation scripts (e.g. ttl_sim.py) under research/theory/."
  ]
 },
 {
  "key": "T6",
  "file": "T6-philosophical-completeness.md",
  "parts": [
   "Sections 1-3: Prop 1.3, Thm 1.4, Thm 1.5, Prop 1.6, Thm 2.2/Cor 2.3, Thm 2.4 (Stone duality claim), Thm 2.6, Thm 3.1 (de Finetti via counting sequents), Thm 3.4 (arity counterexample P_k \u2014 verify by LP), Thm 3.5 (multiplicity hierarchy), Prop 3.6, Thm 3.7 (Gaifman coherence = measures on Stone space), Thm 3.8 (probabilistic omega-rule pins Th(N)), Cor 3.9 (logical inductors non-standard \u2014 check the Delta2 argument), Prop 3.10.",
   "Sections 4-5: Thm 4.1/Cor 4.2 (multi-context completeness), Prop 4.3, Prop 4.4, Thm 4.5 (rules of proof vs conditionals counterexample), Thm 4.6/Prop 4.7 (local-to-global), Thm 5.1, Thm 5.2 (Leibniz collapse), Prop 5.3, Thm 5.5, Thm 5.6, Thm 5.7 (computability barrier), Prop 5.8 (Beth); re-run research/theory/T6-checks/run_all.sh."
  ]
 }
]
const ISSUE = { type: 'object', properties: {
  item: { type: 'string', description: 'theorem/lemma/prop name and number as in the file' },
  severity: { type: 'string', enum: ['fatal', 'major', 'minor', 'ok'] },
  description: { type: 'string' },
  evidence: { type: 'string', description: 'counterexample, computation, or precise pointer to the faulty proof step' },
  suggested_fix: { type: 'string' } }, required: ['item', 'severity', 'description', 'evidence', 'suggested_fix'] }
const VSCHEMA = { type: 'object', properties: { file: { type: 'string' }, items_checked: { type: 'array', items: { type: 'string' } }, issues: { type: 'array', items: ISSUE }, overall: { type: 'string' } }, required: ['file', 'items_checked', 'issues', 'overall'] }
const RSCHEMA = { type: 'object', properties: { file: { type: 'string' }, changes: { type: 'array', items: { type: 'object', properties: { item: { type: 'string' }, action: { type: 'string', enum: ['fixed', 'weakened-statement', 'retracted', 'rejected-issue', 'clarified'] }, detail: { type: 'string' } }, required: ['item', 'action', 'detail'] } }, items_to_reverify: { type: 'array', items: { type: 'string' } } }, required: ['file', 'changes', 'items_to_reverify'] }

const verifyPrompt = (g, part) => `You are an adversarial referee (expert in learning theory, mathematical logic, analysis as needed). Context: ${ROOT}/research/00-brief.md describes the project. Your job is to try hard to REFUTE the mathematical claims in ONE part of a theory file: ${ROOT}/research/theory/${g.file}. Scope: ${part}.
For each theorem/lemma/proposition in scope: (1) check the statement is precise and the hypotheses suffice; (2) check the proof line by line — look for gaps, unjustified steps, quantifier errors, wrong constants, circularity, misuse of cited results; (3) actively search for counterexamples (use Python via Bash for brute-force checks on small cases, and re-run any check scripts the file references, e.g. under ${ROOT}/research/theory/); (4) check cited literature results are stated correctly (mark if unsure). Also flag claims of novelty that are actually standard (that is 'minor' unless misleading). Severity: fatal = statement false; major = proof has a real gap or the statement needs a material change; minor = local fix/clarity; ok = verified. Report EVERY item in scope (including ok ones). Do NOT edit the theory file. Be concrete: give counterexamples and exact pointers. Default to skepticism, but do not invent problems: an 'issue' must be a genuine defect.`

const repairPrompt = (g, reports) => `You are the author-repairer of the theory file ${ROOT}/research/theory/${g.file} (project context: ${ROOT}/research/00-brief.md). Independent adversarial referees produced the reports below. For each reported issue with severity fatal/major/minor: decide whether it is genuine (re-check yourself, with computation if useful). If genuine: FIX the file in place (repair the proof, add missing hypotheses, weaken the statement, or retract it, clearly marked). If not genuine: explain why in the log. Keep the file's numbering stable where possible (if a statement changes materially, keep its number and mark '(revised after verification)'). Append a section '## Verification log' at the end of the file listing each issue and the action taken. Also write a copy of the referee reports + your log to ${ROOT}/research/verification/${g.key}-verification.md. Return the structured summary; list in items_to_reverify every item whose statement or proof you changed in a non-trivial way (fatal/major fixes).

REFEREE REPORTS (JSON):
${JSON.stringify(reports, null, 1)}`

const reverifyPrompt = (g, items) => `You are an adversarial referee. In ${ROOT}/research/theory/${g.file}, the following items were repaired after a first verification round (see its '## Verification log' section and ${ROOT}/research/verification/): ${items.join('; ')}. Re-check ONLY these items, rigorously, trying to refute the repaired statements and proofs (use Python for brute-force checks where useful). Do NOT edit the theory file. Report every item.`

const results = await pipeline(GROUPS,
  g => parallel(g.parts.map((part, i) => () => agent(verifyPrompt(g, part), { label: `verify:${g.key}:${i + 1}`, phase: 'Verify', schema: VSCHEMA }))).then(rs => rs.filter(Boolean)),
  (reports, g) => agent(repairPrompt(g, reports), { label: `repair:${g.key}`, phase: 'Repair', schema: RSCHEMA }).then(r => ({ reports, repair: r })),
  (st, g) => {
    const items = (st.repair && st.repair.items_to_reverify) || []
    if (!items.length) return { ...st, reverify: null }
    return agent(reverifyPrompt(g, items), { label: `reverify:${g.key}`, phase: 'Reverify', schema: VSCHEMA }).then(rv => ({ ...st, reverify: rv }))
  })
return results.map((r, i) => ({ file: GROUPS[i].file,
  issues_round1: r ? r.reports.flatMap(x => x.issues.filter(z => z.severity !== 'ok').map(z => `${z.severity}: ${z.item}: ${z.description.slice(0, 300)}`)) : null,
  repairs: r && r.repair ? r.repair.changes : null,
  reverify: r && r.reverify ? r.reverify.issues.map(z => `${z.severity}: ${z.item}: ${z.description.slice(0, 300)}`) : null }))
