export const meta = {
  name: 'repair-T7-round2',
  description: 'Second repair round for T7 residual major issues, then re-verify',
  phases: [{ title: 'Repair' }, { title: 'Reverify' }],
}
const ROOT = '/home/user/AI-works/inferential-learning'
const F = ROOT + '/research/theory/T7-two-tier-coherent-inferential-learner.md'
const RS = { type: 'object', properties: { changes: { type: 'array', items: { type: 'string' } }, items_to_reverify: { type: 'array', items: { type: 'string' } } }, required: ['changes', 'items_to_reverify'] }
const VS = { type: 'object', properties: { issues: { type: 'array', items: { type: 'object', properties: { item: { type: 'string' }, severity: { type: 'string', enum: ['fatal', 'major', 'minor', 'ok'] }, description: { type: 'string' } }, required: ['item', 'severity', 'description'] } } }, required: ['issues'] }
phase('Repair')
const r = await agent(`You are the author-repairer of ${F}. It has been through one adversarial verification + repair round (see its '## Verification log' and ${ROOT}/research/verification/T7-verification.md). A re-verification found residual issues:
(1) MAJOR: Thm 5.5 (burn-in is necessary: the rare refuter), revised scenario-independence conventions: the revised statement assumes 'escalation answers follow the practice (§5 conventions)', but the §5 convention only gives the same law in every scenario with that practice; in Thm 5.5 the two scenarios may not have the same practice, so the convention does not deliver what the proof needs. Fix the statement/conventions so the two-point argument is valid (e.g. state explicitly the observational-equivalence assumption on all channels including escalations, or restrict to channels without escalation), and re-check the proof.
(2) MAJOR: Thm 6.6(e), 'What the floor buys' remark and its proof line: the stated bound t >= ln((1-delta')/delta)/ln(1/(1-pi)) is false, because in Thm 5.5 the rare tag lives in the scenario where acceptance is unsound, whereas here the rare tag Con(T_{k-1}) lives in the other scenario. Correct or retract the remark (derive the right two-point bound, if any, carefully).
(3) MINOR: Lemma 2.5(d) size convention (derivations as DAGs/sequences so that size counts distinct judgments) — make Def 1.5 consistent; Thm 4.1 proof Step 1 conventions for ground rules (c_i := 1, rho_i := 1) — state them.
Also re-read the round-1 majors (Prop 2.4(c), Prop 3.2 voting audit, Prop 5.2(a) conditional probability form, Thm 5.6 optimality clause, Cor 6.5 scope for complete decidable theories, Thm 6.6(e) applicability of T1 Thm 6.3 to the induction schema) and make sure their repairs are consistent with your new changes. Edit the file in place, append to its Verification log ('Round 2'), and update ${ROOT}/research/verification/T7-verification.md. Return the changes and the items to re-verify.`, { label: 'repair:T7:r2', phase: 'Repair', schema: RS })
phase('Reverify')
const v = await agent(`You are an adversarial referee. In ${F}, these items were repaired in a second round (see 'Round 2' in its Verification log): ${(r && r.items_to_reverify || ['Thm 5.5', 'Thm 6.6(e)']).join('; ')}. Re-check ONLY these items rigorously; try to refute them. Do not edit the file. Report each item.`, { label: 'reverify:T7:r2', phase: 'Reverify', schema: VS })
return { r, v }
