export const meta = {
  name: 'verify-redteam-claims',
  description: 'Adversarially referee the red-team propositions the final note will cite (TUBE with residual budget, small-width learner, aggregate-fit conditioning, depth two)',
  phases: [
    { title: 'Verify', detail: 'independent referees per claim and lens' },
    { title: 'Repair', detail: 'author fixes blocking issues; re-verify' },
  ],
}

const S = '/tmp/claude-0/-workspace/e8ce7448-1256-507d-9f63-d716a14ba11f/scratchpad/agnostic'
const OUT = `${S}/out`
const RT = `${OUT}/redteam.md`

const COMMON = `Background. We study an agnostic (misspecified, MSE) version of the NNBayes generalization results in the repository /workspace/ai-works/neural-network-generalization (abbreviated NNG/). The problem brief, with notation (energy kappa_N, strong-prior Gaussian prior, learners SP_c, TUBE_rho, FIX_eta, predictors), is ${S}/BRIEF.md: read it first. A red-team agent wrote ${RT}; it contains several propositions that our final note wants to cite, but nobody has refereed them. Companion proofs that were refereed: ${OUT}/A.md (tight conditioning fails), ${OUT}/B.md (tempered likelihood works), ${OUT}/C.md, ${OUT}/E.md. You may read anything in the repository; do not modify the repository and do not run git. Python3 with numpy, scipy, sympy, mpmath is available; put scratch scripts in your own subfolder of ${OUT}.`

const LENS_TEXT = {
  logic: 'LENS = logic and definitions: check every quantifier, limit order (sigma -> 0 after n, sample and width are fixed), case split and definition against the brief and the cited sources (open the sources, e.g. NNG/side-results/continuous-domains/source/paper.tex Theorem strong, Lemma posterior, Prop. exact, and compare exactly). Look for circularity, misapplied lemmas, missing hypotheses (widths, weight bounds, clipping, measurability, existence of minimizers, label range), and steps that silently assume what is to be proved. Check the red-team lemmas of its Section 1 that the proof uses.',
  computation: 'LENS = computation: recompute every constant, exponent, energy bound, probability estimate and concentration inequality. Re-derive the key inequalities yourself and run numerical checks in Python where possible (small instances, random networks, exact enumeration on small cubes). Report any arithmetic or exponent error, even if it does not change the conclusion.',
}

const ITEMS = [
  { key: 'tube', title: 'Proposition 4.1 (TUBE with a sup-norm residual budget)', where: 'Section 4.3 of the red-team report (Proposition 4.1 and the paragraph after its proof), which relies on paper.tex Theorem strong and Lemma posterior', lenses: ['logic', 'computation'],
    focus: 'Is the conclusion E_Pi L_D(clip z_w) <= (tau+rho_0)^2 + 4 eps/3 at the same polynomial sample size as Theorem strong correct, uniformly over learner width N >= C? Does Theorem strong really hold verbatim after the stated replacements (its proof uses clean labels; check every place)? Is the claim that hard conditioning within the residual budget never memorizes correct?' },
  { key: 'width', title: 'Proposition 6.1 (learner width tied to n; c = 1 works at width n^alpha, alpha < 1/4)', where: 'Section 6.3 of the red-team report (Proposition 6.1 and its proof), using Theorem 3.2 and Lemma 2.3-type facts from its Sections 1 and 3', lenses: ['logic', 'computation'],
    focus: 'Check the perturbation bound, the grid mesh and log-cardinality, the uniform deviation, the exponents O(n^{4 alpha - 1} + n^{alpha - 1/2} sqrt(log n)), and whether "polynomially small for alpha < 1/4" holds with the stated competitor class (width and weights <= n^alpha, d <= n^alpha). Also check the closing sentence on where the width transition lies.' },
  { key: 'aggregate', title: 'Remark 6.2 (conditioning on aggregate training error)', where: 'Section 6.3 of the red-team report, Remark 6.2', lenses: ['logic'],
    focus: 'Is the bound L_D(clip z_w) <= tau + 8 D((E_*+1)/H)^{H/2} n^{-1/2} + 4 sqrt(ln(2/delta)/(2n)) correct for the strong-prior limit of the prior conditioned on {empirical MSE < tau}, when the competitor has empirical MSE < tau? Is the concentration on {kappa_N <= E_* + zeta} justified (the event is not open in the same way as a tube; check the Laplace argument), and is the required n polynomial?' },
  { key: 'depth2', title: 'Depth two: Theorem 5.1, Corollary 5.2 and Proposition 5.3', where: 'Section 5 of the red-team report, using its Lemmas 1.2, 1.3 and 2.1', lenses: ['logic', 'computation'],
    focus: 'Theorem 5.1: partial memorization at depth two with excess >= gamma(lambda)(18dc+1)^{-2}(1-o(1)), gamma(1)=0.0999; Corollary 5.2: this refutes the polynomial-sample agnostic inequality for depth-two SP_c with c <= poly(d) but not the +o(1) formulation; Proposition 5.3: with Hadamard atoms (d = M) every c = o(sqrt M) gives excess >= beta(lambda) - o(1) at every width N >= 1. Check the energy of the depth-two memorizer, the bracket minimization, the limits, and the Hadamard construction (z = eps^{-1} tanh(eps u.x), kappa_N = eps^2 Q + eps^{-2}, error <= eps^2/3).' },
]

const VERDICT_SCHEMA = {
  type: 'object',
  properties: {
    verdict: { type: 'string', enum: ['correct', 'minor_fixes', 'major_flaw', 'wrong'] },
    issues: { type: 'array', items: { type: 'object', properties: {
      severity: { type: 'string', enum: ['critical', 'major', 'minor'] },
      location: { type: 'string' }, description: { type: 'string' }, suggested_fix: { type: 'string' } },
      required: ['severity', 'location', 'description'] } },
    corrected_statement: { type: 'string' },
    summary: { type: 'string' },
  },
  required: ['verdict', 'issues', 'summary'],
}
const AUTHOR_SCHEMA = {
  type: 'object',
  properties: { status: { type: 'string', enum: ['proved', 'weakened', 'withdrawn'] }, file: { type: 'string' }, statement: { type: 'string' }, summary: { type: 'string' } },
  required: ['status', 'file', 'statement', 'summary'],
}

const verifyPrompt = (it, lens, file, round) => `You are an adversarial referee. Your job is to REFUTE or find flaws in a claimed result; do not fix it yourself beyond suggesting fixes. Default to reporting an issue when uncertain.

${COMMON}

Claim under review: ${it.title}. Location: ${file === RT ? it.where : 'the file ' + file + ' (a revised version of ' + it.where + ')'}. Read the claim, its proof, and every lemma of the red-team report it uses.
Focus questions: ${it.focus}
${LENS_TEXT[lens]}

Write your full referee report to ${OUT}/verify-RT-${it.key}-${lens}${round ? '-r' + round : ''}.md. If the claim is false or overstated, give the strongest correct statement you can support in corrected_statement. Use 'correct' only if you checked every step; 'minor_fixes' if only presentational or harmless issues; 'major_flaw' if a step is wrong or unjustified but the claim may survive with repair; 'wrong' if the main claim is false as stated. Return the structured verdict.`

const authorPrompt = (it, issues) => `You are the author repairing a result after referee reports.

${COMMON}

The result: ${it.title}, at ${it.where} of ${RT}. Referees raised these issues (JSON):
${JSON.stringify(issues, null, 1)}
Also read the full referee reports ${OUT}/verify-RT-${it.key}-*.md. Write a self-contained corrected statement and complete proof to ${OUT}/RT-${it.key}.fixed.md, with a final section "Response to referees" (one entry per issue). Never claim more than you prove; weaken the statement explicitly if needed, or withdraw it if it cannot be saved. Return the structured result.`

const blocking = (v) => v && (v.verdict === 'major_flaw' || v.verdict === 'wrong' || (v.issues || []).some(i => i.severity === 'critical' || i.severity === 'major'))

const results = await pipeline(ITEMS, async (it) => {
  const vs = (await parallel(it.lenses.map(lens => () => agent(verifyPrompt(it, lens, RT, 0), { label: `verify:RT-${it.key}:${lens}`, phase: 'Verify', schema: VERDICT_SCHEMA })))).filter(Boolean)
  const rounds = [{ file: RT, verdicts: vs }]
  if (!vs.some(blocking)) return { key: it.key, final: RT, verdicts: vs, rounds: 1 }
  const issues = vs.flatMap(v => (v.issues || []).filter(i => i.severity !== 'minor'))
  log(`${it.key}: ${issues.length} blocking issue(s); repair`)
  const fixed = await agent(authorPrompt(it, issues), { label: `repair:RT-${it.key}`, phase: 'Repair', schema: AUTHOR_SCHEMA })
  if (!fixed || fixed.status === 'withdrawn') return { key: it.key, final: null, withdrawn: true, verdicts: vs, fixed }
  const vs2 = (await parallel(it.lenses.map(lens => () => agent(verifyPrompt(it, lens, fixed.file, 1), { label: `reverify:RT-${it.key}:${lens}`, phase: 'Repair', schema: VERDICT_SCHEMA })))).filter(Boolean)
  return { key: it.key, final: fixed.file, fixedStatus: fixed.status, statement: fixed.statement, verdicts: vs, reverdicts: vs2, rounds: 2 }
})
return results.map(r => r && ({ key: r.key, final: r.final, withdrawn: !!r.withdrawn, fixedStatus: r.fixedStatus, statement: r.statement,
  first: (r.verdicts || []).map(v => ({ verdict: v.verdict, nIssues: (v.issues || []).length, blocking: (v.issues || []).filter(i => i.severity !== 'minor').map(i => i.description), corrected: v.corrected_statement, summary: v.summary })),
  second: (r.reverdicts || []).map(v => ({ verdict: v.verdict, blocking: (v.issues || []).filter(i => i.severity !== 'minor').map(i => i.description), summary: v.summary })) }))
