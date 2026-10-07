export const meta = {
  name: 'verify-theory-B',
  description: 'Adversarial verification and repair of theory developments (T3, T4)',
  phases: [
    { title: 'Verify', detail: 'independent refutation attempts per theorem group' },
    { title: 'Repair', detail: 'one repair agent per file applies fixes' },
    { title: 'Reverify', detail: 'second-round check of repaired fatal/major items' },
  ],
}
const ROOT = '/home/user/AI-works/inferential-learning'
const GROUPS = [
 {
  "key": "T3",
  "file": "T3-contexts-idealization-export.md",
  "parts": [
   "Sections 1-2 only: Prop 1.4 (Los), Prop 1.5, Lemma 1.8, Thm 1.9 (reductio hygiene, incl. the K={A->q, notA->q, not q} example), Prop 1.10, Thm 2.1 (no truth-functional eternal reading), Cor 2.2, Thm 2.4 (realizability criterion; re-run the brute-force checks in research/theory/T3-checks/), Thm 2.5, Cor 2.6.",
   "Sections 3-4 only: Lemma 3.2, Thm 3.3 (no free export: all four instances), Prop 3.4, Thm 3.5, Thm 3.6 (Gronwall), Thm 3.7 (projectile certificate: verify the inequalities analytically and numerically), Thm 3.8, Thm 3.9 (adversarial stipulation), Thm 4.1, Thm 4.3, Thm 4.4, Thm 4.5 (Lipschitz certifier upper and lower bounds), Thm 4.6, Prop 4.7 (re-run the numerics).",
   "Sections 5-6 only: Thm 5.3 (relative soundness of the SPS checker), Thm 5.4 (judgment layer ineliminable), Thm 5.5, Prop 5.6, Prop 6.1 (exact chair-leg illuminance: re-derive with SymPy and re-run Monte Carlo at smaller scale), Prop 6.2, Prop 6.3, and the mini-checker's accept/reject claims (re-run the scripts in research/theory/T3-checks/)."
  ]
 },
 {
  "key": "T4",
  "file": "T4-informal-math-latent-formalization.md",
  "parts": [
   "Sections 1-3 only: the formal model definitions, Lemma 2.2, Thm 2.4, Prop 2.3 (equivocation), Thm 2.5, Thm 2.7, Prop 2.8, Lemma 3.3 (informal completeness lemma), Thm 3.4, Prop 3.5, Prop 3.6, Prop 3.7.",
   "Sections 4-5 only: Lemma 4.1, Thm 4.3, Thm 4.4 (incl. the chain-paradox lower bound), Thm 4.5, Prop 4.6, Conjecture 4.x (check the computational evidence in research/theory/T4-checks/), Prop 4.7, Thm 5.1, Thm 5.2 (comprehension toy: check each model and refutation claimed, and the selection-by-coverage claims), Prop 5.4.",
   "Sections 6-7 only: Thm 6.2 (robust core), Thm 6.3, Prop 6.4 (sorites tightness), Prop 6.5 (emergence of a notion of proof), Props 7.1-7.3 (steeper simplicity penalty: rate threshold and the counterexample to the convex-hull vertex conjecture)."
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

const repairPrompt = (g, reports) => `You are the author-repairer of the theory file ${ROOT}/research/theory/${g.file} (project context: ${ROOT}/research/00-brief.md). Independent adversarial referees produced the reports below. For each reported issue with severity fatal/major/minor: decide whether it is genuine (re-check yourself, with computation if useful). If genuine: FIX the file in place (repair the proof, add missing hypotheses, weaken the statement, or retract it, clearly marked). If not genuine: explain why in the log. Keep the file's numbering stable where possible (if a statement changes materially, keep its number and mark '(revised after verification)'). Append a section '## Verification log' at the end of the file listing each issue and the action taken. Also write a copy of the referee reports + your log to ${ROOT}/research/verification/${g.file.replace('.md', '')}-verification.md. Return the structured summary; list in items_to_reverify every item whose statement or proof you changed in a non-trivial way (fatal/major fixes).

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
