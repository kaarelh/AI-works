export const meta = {
  name: 'verify-theory-L',
  description: 'Adversarial verification and repair of theory developments (L3 proved results)',
  phases: [
    { title: 'Verify', detail: 'independent refutation attempts per theorem group' },
    { title: 'Repair', detail: 'one repair agent per file applies fixes' },
    { title: 'Reverify', detail: 'second-round check of repaired fatal/major items' },
  ],
}
const ROOT = '/home/user/AI-works/inferential-learning'
const GROUPS = [
 {
  "key": "L3",
  "file": "../lit/L3-learning-to-reason-and-limit-inquiry.md",
  "parts": [
   "Only the results the memo claims to PROVE (not literature summaries): Lemma A (commitment-order lemma) and its corollaries, Prop C (axiom induction as Dempster-Shafer pair; re-run lit/L3-scripts), Thm D and D' (Sawin-Demski-style trilemma: coherence + Pi1-convergence forces liminf 0 on infinitely many true Pi2 sentences; and the claim incoherent credences can gradually verify Pi3), Lemma E' (coherentizing improves Brier score iff constraints are sound), Cor F (rule traders; check dependence on the cited affine provability induction), Thm G (success table), Lemma K (no computable modulus), Prop H (oracle feedback reaches Delta_{n+2})."
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
