export const meta = {
  name: 'final-consistency',
  description: 'Adversarial check of the agnostic-learning README and of every cross-reference between its notes',
  phases: [{ title: 'Check' }],
}
const R = '/workspace/ai-works/neural-network-generalization/works-in-progress/agnostic-learning'
const S = '/tmp/claude-0/-workspace/e8ce7448-1256-507d-9f63-d716a14ba11f/scratchpad/agnostic'
const SCHEMA = {
  type: 'object',
  properties: {
    verdict: { type: 'string', enum: ['correct', 'minor_fixes', 'major_flaw'] },
    issues: { type: 'array', items: { type: 'object', properties: {
      severity: { type: 'string', enum: ['major', 'minor'] }, file: { type: 'string' }, location: { type: 'string' },
      quote: { type: 'string' }, description: { type: 'string' }, suggested_fix: { type: 'string' } },
      required: ['severity', 'file', 'location', 'quote', 'description', 'suggested_fix'] } },
    summary: { type: 'string' },
  },
  required: ['verdict', 'issues', 'summary'],
}
const COMMON = `Folder: ${R}. Main README: ${R}/README.md. Research notes: ${R}/research-notes/ (problem-brief.md, A-tight-conditioning-fails.md, B-tempered-likelihood.md, C-fixed-temperature-bayes.md, E-finite-prior-scale.md, small-learner-width.md, depth-two.md, red-team.md, literature.md). Referee reports and their index: ${R}/verification/. Scripts: ${R}/checks/. NNG/ is /workspace/ai-works/neural-network-generalization/. The project's question: is Bayesian learning with MLPs an agnostic learner (test MSE at most the least over MLPs of width poly(n), plus o(1))? The brief formalizes it as property (P_L).
You are an adversarial checker. Your job is to find problems; default to reporting an issue when uncertain. Do not edit any file. Quote the exact text of each problem (the 'quote' field) so the editor can find it, and give a concrete replacement in 'suggested_fix'. Severity 'major' only if a reader would be misled about what is proved or refuted; 'minor' otherwise.`

const README_TASK = `${COMMON}

Task: check ${R}/README.md sentence by sentence against the research notes. For every claim (theorem statements, constants, exponents, thresholds, probabilities, quantifiers over widths, dimensions, laws, predictors and limit order, refereeing status), open the cited note and check that the README says exactly what the note proves, with every hypothesis that matters (depth, clipping, learner widths, input dimension growth, in expectation vs high probability, strong-prior limit vs finite scale). Flag every overclaim, missing hypothesis, wrong number, wrong result number, broken or wrong link, and any statement about refereeing that the verification index (${R}/verification/README.md) does not support. Check also the verification index itself (verdict tables against the reports' own verdict lines; counts of points), and the two entries for this note in NNG/README.md (the row in the works-in-progress table and the paragraph under "Label-noise research"). Write your report to ${S}/stage/final-readme-check.md and return the structured result.`

const XREF_TASK = `${COMMON}

Task: check every cross-reference between the research notes, and the notes' own summaries. For each note, find every citation of another note of this folder (by file name and result, section, equation or table number) and check in the cited note that the item exists and says what the citing sentence says it says, with its hypotheses. Pay special attention to: citations of red-team.md (its numbered results were kept, but several parts now point to small-learner-width.md and depth-two.md; citations should describe the current status), citations of A's and B's results by number, and the verification status that notes attribute to each other (compare with ${R}/verification/README.md). Also check each note's header for accuracy (what it treats, its refereeing history, links) and every relative link and backticked path (they must resolve from the note's folder). Write your report to ${S}/stage/final-xref-check.md and return the structured result.`

phase('Check')
const [readme, xref] = await parallel([
  () => agent(README_TASK, { label: 'check:readme', phase: 'Check', schema: SCHEMA }),
  () => agent(XREF_TASK, { label: 'check:xref', phase: 'Check', schema: SCHEMA }),
])
return { readme, xref }
