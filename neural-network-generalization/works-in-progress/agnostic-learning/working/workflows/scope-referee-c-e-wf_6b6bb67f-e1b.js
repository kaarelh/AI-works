export const meta = {
  name: 'scope-referee-C-E',
  description: 'Adversarial scope referees for the final C (fixed temperature) and E (finite prior scale) notes',
  phases: [{ title: 'Scope', detail: 'one scope referee per note' }],
}
const R = '/workspace/ai-works/neural-network-generalization/works-in-progress/agnostic-learning'
const S = '/tmp/claude-0/-workspace/e8ce7448-1256-507d-9f63-d716a14ba11f/scratchpad/agnostic'
const VERDICT_SCHEMA = {
  type: 'object',
  properties: {
    verdict: { type: 'string', enum: ['correct', 'minor_fixes', 'major_flaw', 'wrong'] },
    issues: { type: 'array', items: { type: 'object', properties: {
      severity: { type: 'string', enum: ['critical', 'major', 'minor'] },
      location: { type: 'string' }, description: { type: 'string' }, suggested_fix: { type: 'string' } },
      required: ['severity', 'location', 'description', 'suggested_fix'] } },
    summary: { type: 'string' },
  },
  required: ['verdict', 'issues', 'summary'],
}
const NOTES = [
  { key: 'C', file: 'C-fixed-temperature-bayes.md', readme: 'section 6 ("Ordinary tempered Bayes at a fixed temperature"), intro item 5, and the FIX_eta row of the section 2 table',
    extra: 'C was refereed through the logic and computation lenses only (../verification/C-logic.md, C-computation.md) and then checked three times after revision (../verification/C-revision-check-*.md). Nobody has yet refereed its scope. Pay special attention to: whether the FIX_eta learner with clipped outputs in the likelihood is a fair reading of "NN Bayesian learning"; whether "in expectation" vs "with high probability" is stated wherever it matters; the width dependence (Theorem C.5) and what exactly it refutes; Corollary C.2.2 ("the user\'s formulation") and its hypotheses on d; the counterexamples for unclipped predictors (Remark 3 after Theorem C.1); and whether anything contradicts B-tempered-likelihood.md or NNG/works-in-progress/slt-likelihood/README.md.' },
  { key: 'E', file: 'E-finite-prior-scale.md', readme: 'section 7 ("Finite prior scale"), intro item 6, and the finite-scale row of the section 2 table',
    extra: 'E was refereed through the logic and computation lenses only (../verification/E-logic.md, E-computation.md) and then checked three times after revision (../verification/E-revision-check-*.md). Nobody has yet refereed its scope. Pay special attention to: whether the finite-scale co-scaled learner (prior mu_{N,gamma}, likelihood variance c N^{-gamma}, no limit) is the learner the repository\'s finite-scale theorems use (compare NNG/works-in-progress/slt-likelihood/README.md and NNG/side-results/continuous-domains/source/paper.tex eq. finite-scales); whether the negative result really holds "at every gamma >= 1" and every width above a polynomial, with the stated probability; whether the positive thresholds theta_{L,gamma} are stated with their conditions (clipped predictions, the imported mean-field cover at gamma = 1); whether the "phase diagram" claims of sharpness are justified; and whether anything contradicts A-tight-conditioning-fails.md or B-tempered-likelihood.md.' },
]
const prompt = (n) => `You are an adversarial referee of a research note in learning theory. Your job is to find problems; do not edit the note. Default to reporting an issue when uncertain.

Context. The project asks whether Bayesian learning with MLPs is an agnostic learner: after n samples, is its test MSE at most the least test MSE over MLPs of width poly(n), plus o(1)? The formalization is ${R}/research-notes/problem-brief.md section 1 (property (P_L): a polynomial sample bound, uniform over laws, input dimensions and learner widths N >= m, for a competitor of depth L, width m, weights in [-B,B]). The other notes are in ${R}/research-notes/ (A: close conditioning fails; B: tempered likelihood works; small-learner-width.md; depth-two.md). NNG/ means /workspace/ai-works/neural-network-generalization/. The draft of the folder's main README is ${S}/stage/README.draft.md.

Note under review: ${R}/research-notes/${n.file} (final text). Read it completely, and read the cited parts of the brief, A, B and the repository sources.

LENS = scope and adversarial interpretation. Does each stated result establish (or refute) what the note says it does about the conjecture of the brief? Would a skeptical expert (the person who proposed the conjecture) accept it, or object that it addresses a different learner, a degenerate law, a different loss, a different predictor, or the wrong order of limits? Try to construct a scenario in which a stated theorem or summary sentence is false. Check consistency with the repository's theorems and with the other notes; any apparent contradiction is a red flag. Check every summary of the note's results (its own opening, results list, "bearing on the conjecture" and status sections) against the theorems they summarize: a summary that claims more than the theorem proves is an issue, even if small.
${n.extra}

Also check the README draft's summary of this note: ${n.readme}. Report every sentence there that misstates the note, omits a hypothesis that matters, or claims more than is proved, with a suggested replacement.

Run Python where a numerical check helps; put scripts and outputs in ${S}/stage/scope-${n.key}/ (create it). Write your full report to ${S}/stage/scope-${n.key}.md: a verdict line, then the issues (numbered, each with severity, location, description and suggested fix), then what you checked. Severity: 'major' only if a stated result or a summary would mislead a reader about what is proved; 'minor' otherwise. Return the structured verdict ('correct' only if you found nothing; 'minor_fixes' for small problems; 'major_flaw' if a result or summary is misleading in a way that matters; 'wrong' if a main result is false).`
phase('Scope')
const res = await parallel(NOTES.map(n => () => agent(prompt(n), { label: `scope:${n.key}`, phase: 'Scope', schema: VERDICT_SCHEMA })))
return NOTES.map((n, i) => ({ key: n.key, result: res[i] }))
