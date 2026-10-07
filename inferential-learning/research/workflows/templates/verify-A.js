export const meta = {
  name: 'verify-theory-A',
  description: 'Adversarial verification and repair of theory developments (T1, T2)',
  phases: [
    { title: 'Verify', detail: 'independent refutation attempts per theorem group' },
    { title: 'Repair', detail: 'one repair agent per file applies fixes' },
    { title: 'Reverify', detail: 'second-round check of repaired fatal/major items' },
  ],
}
const ROOT = '/home/user/AI-works/inferential-learning'
const GROUPS = [
 {
  "key": "T1",
  "file": "T1-soundness-under-search.md",
  "parts": [
   "Sections 1-3 only: Lemma 1.1, Thm 2.1, Cor 2.2, Prop 2.3, Prop 2.4, Thm 3.1, Thm 3.2 (escalation dimension = positive elasticity, incl. the lower bound for randomized delta-sound verifiers), Prop 3.3, Lemma 1.2, Lemma 1.3, Thm 3.4, Prop 3.5, Thm 3.6, Thm 3.7 (all three parts), Conj 3.8 (check the claimed evidence), Thm 3.9.",
   "Sections 4-6 only: Thm 4.1, Thm 4.2 (Ville; check the supermartingale construction and the claim that no union bound is needed; check the deterministic-oracle single-event claim), Prop 4.3, Thm 4.4, Cor 4.5, Cor 4.6, Thm 5.1, Prop 5.2, Thm 5.3 (coupon-collector bound and constants), Thm 5.4 (untagged unions, epsilon-net bound), Cor 5.5, Prop 6.1, Thm 6.2, Thm 6.3, Thm 6.4, Cor 6.5, Prop 6.6."
  ]
 },
 {
  "key": "T2",
  "file": "T2-coherence-as-negative-data.md",
  "parts": [
   "Section 2 only: Lemma 2.1, Thm 2.2 (oligarchic halving), Prop 2.3, Thm 2.4 (doctrinal paradox), Thm 2.5, Thm 2.6, Prop 2.7, Cor 2.8, Prop 2.9.",
   "Section 3 only: Thm 3.1 (structural Post-completeness of classical consequence, incl. infinitary operators and the pure implicational fragment), Prop 3.2, Thm 3.3, Props 3.4-3.5, Thm 3.6 (Glivenko, Jankov chain), Lemma 3.7, Thm 3.8, Thm 3.9 (Turing chain), Thm 3.10 (Popperian learner, Sigma2 barrier), Prop 3.11.",
   "Sections 4-7 only: Lemma 4.1, Thm 4.2 (Carnap's problem in learning form), Thm 4.3 (denial-rank trichotomy), Thm 4.4 (12-datum tell-tale; brute-force check it), Prop 4.5 (re-run the 16384-matrix check), Prop 4.6 if present, Prop 5.1 (tonk), Prop 5.2, Thm 5.3 (Pi1/Pi2 completeness claims), Thm 6.1, Cor 6.2, Prop 6.3, Thm 6.4, Prop 7.1."
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
