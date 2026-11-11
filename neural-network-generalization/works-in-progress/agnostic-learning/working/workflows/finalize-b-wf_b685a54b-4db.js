export const meta = {
  name: 'finalize-B',
  description: 'Apply referee minor fixes to the tempered-likelihood proof (B) and independently check the revision',
  phases: [
    { title: 'Revise', detail: 'author applies every referee issue' },
    { title: 'Check', detail: 'independent checker verifies the revision' },
  ],
}

const S = '/tmp/claude-0/-workspace/e8ce7448-1256-507d-9f63-d716a14ba11f/scratchpad/agnostic'
const R = '/workspace/ai-works/neural-network-generalization/works-in-progress/agnostic-learning'
const SRC = `${S}/stage/B-tempered-likelihood.md`
const DST = `${R}/research-notes/B-tempered-likelihood.md`

const CONTEXT = `Context. We are publishing a research note on an agnostic (misspecified, MSE) version of the NNBayes generalization results, in the repository folder ${R} (project root /workspace/ai-works/neural-network-generalization, abbreviated NNG/). Layout of the note folder:
- README.md (overview, written later by the lead), research-notes/ (problem-brief.md, A-tight-conditioning-fails.md, B-tempered-likelihood.md, C-fixed-temperature-bayes.md, E-finite-prior-scale.md, red-team.md, literature.md), verification/ (referee reports, e.g. B-logic.md, B-computation.md, B-scope.md), checks/ (scripts and outputs: checks/B/, checks/verify-B-logic/, ...).
- The document under revision is Claim B: the tempered co-scaled Gaussian likelihood SP_c with c = n^(1-theta) satisfies an agnostic oracle inequality at every learner width. It was refereed by three independent referees (logic, computation, scope). All verdicts were 'minor_fixes': no error in the main chain, but many imprecise summary sentences, a wrong quoted sample size, dropped quantifiers in the discussion of Corollary 9.3, Corollary 8.1 vacuous for H=1 when alpha >= 1/8, and so on.
- The problem statement the proofs refer to as "the brief" is ${S}/BRIEF.md (to be published as research-notes/problem-brief.md).
- Do not run git. Do not touch files outside ${R}/research-notes/B-tempered-likelihood.md and ${R}/checks/B/, except scratch files under ${S}/stage/.`

const REVISE = (extra) => `You are the author of the document below, preparing its final published version after peer review.

${CONTEXT}

Input: the current text ${SRC} (scratch paths already rewritten to the repository layout). Referee reports: ${R}/verification/B-logic.md, ${R}/verification/B-computation.md, ${R}/verification/B-scope.md. Read all three completely, and the document completely.

Task: write the complete final document to ${DST}.
1. Address EVERY issue raised in the three reports, including all minor ones. Fix the text where the issue is valid: correct numbers, add missing quantifiers and qualifiers (uniformity over laws, d growing with n, learner widths N >= N0(n), clipped vs unclipped predictors, labels in [-1,1], exact competitor architecture), state the H=1 limitation of Corollary 8.1, make the Section 9 discussion sentences true as stated (or remove the unproved universal claims), and so on. If you judge an issue invalid, do not change the text for it; explain why in the final section.
2. Never strengthen a claim. When a fix requires weakening, weaken explicitly. Keep every proved result.
3. Keep the numbering of sections, theorems, lemmas, propositions, corollaries and remarks stable, because other documents cite them. New material goes into new remarks with primed or lettered numbers (for example Remark 9.4 or Remark 6.5a), not by renumbering.
4. Opening paragraph: say this is a research note of the agnostic-learning note (../README.md), define NNG/ as the project folder neural-network-generalization/ of this repository (not an absolute path), cite the brief as problem-brief.md, and the checks as ../checks/B/.
5. Scripts: where a referee found a stale docstring or a wrong quoted number tied to a script (for example sample_sizes.py, transition_window.py, the 10^13.4 sample size), edit the script in ${R}/checks/B/, re-run it from that folder (python3 X.py > X.out) if it runs in under five minutes, and make the text agree with the new output. If a script takes longer, do not re-run it; say so.
6. End with a section "Referee record": list the three reports (verification/B-logic.md etc., relative path ../verification/...) and a table with one row per referee issue: report, short description, resolution (fixed / weakened / rebutted), where in the text.
7. Plain, precise prose; no marketing language; no first-person plural flourishes. Keep the mathematical content and proofs; edit only what the reviews require (plus the opening paragraph and the record).
${extra}
Return the structured result.`

const REVISE_SCHEMA = {
  type: 'object',
  properties: {
    file: { type: 'string' },
    issues: { type: 'array', items: { type: 'object', properties: {
      report: { type: 'string' }, issue: { type: 'string' },
      resolution: { type: 'string', enum: ['fixed', 'weakened', 'rebutted'] }, where: { type: 'string' } },
      required: ['report', 'issue', 'resolution', 'where'] } },
    scripts_changed: { type: 'array', items: { type: 'string' } },
    numbers_changed: { type: 'array', items: { type: 'string' } },
    summary: { type: 'string' },
  },
  required: ['file', 'issues', 'summary'],
}

const VERDICT_SCHEMA = {
  type: 'object',
  properties: {
    verdict: { type: 'string', enum: ['correct', 'minor_fixes', 'major_flaw', 'wrong'] },
    issues: { type: 'array', items: { type: 'object', properties: {
      severity: { type: 'string', enum: ['critical', 'major', 'minor'] },
      location: { type: 'string' }, description: { type: 'string' }, suggested_fix: { type: 'string' } },
      required: ['severity', 'location', 'description'] } },
    unaddressed_referee_issues: { type: 'array', items: { type: 'string' } },
    summary: { type: 'string' },
  },
  required: ['verdict', 'issues', 'unaddressed_referee_issues', 'summary'],
}

const CHECK = (round) => `You are an independent checker of a revised mathematical document. Your job is to find problems; default to reporting an issue when uncertain.

${CONTEXT}

Files: the revised document ${DST}; the pre-revision text ${SRC} (compare with: diff ${SRC} ${DST}); the referee reports ${R}/verification/B-logic.md, B-computation.md, B-scope.md; the scripts in ${R}/checks/B/.
Check:
(a) Every issue in the three referee reports is addressed correctly, either fixed in the text or rebutted with a valid reason. List any that are not in unaddressed_referee_issues.
(b) Every changed passage is mathematically correct. Re-derive changed statements, numbers and exponents; run Python where useful (scratch folder ${S}/stage/check-B-r${round}/).
(c) No claim was strengthened, and no proved result was dropped without saying so.
(d) The numbering of sections and results is unchanged from the pre-revision text, apart from added primed or lettered items.
(e) Every relative path in the document resolves from ${R}/research-notes/ (for example ../checks/B/sample_sizes.py, problem-brief.md may be missing for now and is fine, ../verification/B-logic.md), and the script outputs quoted in the text match the .out files.
Write a short report to ${S}/stage/check-B-r${round}.md and return the structured verdict. Use 'correct' only if everything checks; 'minor_fixes' for small remaining problems; 'major_flaw' if a revision introduced an error or left a referee issue unaddressed in a way that matters.`

phase('Revise')
let rev = await agent(REVISE(''), { label: 'revise:B', phase: 'Revise', schema: REVISE_SCHEMA })
phase('Check')
let chk = await agent(CHECK(1), { label: 'check:B:r1', phase: 'Check', schema: VERDICT_SCHEMA })
const history = [{ rev, chk }]
let round = 2
while (chk && (chk.verdict !== 'correct') && round <= 3) {
  const needs = chk.verdict === 'major_flaw' || chk.verdict === 'wrong' || (chk.unaddressed_referee_issues || []).length > 0 || (chk.issues || []).length > 0
  if (!needs) break
  log(`B: checker verdict ${chk.verdict}; revision round ${round}`)
  rev = await agent(REVISE(`\nThis is revision round ${round}. The document ${DST} already exists: edit it in place (do not start again from ${SRC}). An independent checker reported these problems with the previous revision (JSON):\n${JSON.stringify({ issues: chk.issues, unaddressed: chk.unaddressed_referee_issues }, null, 1)}\nFix each valid one; rebut invalid ones in the Referee record.`), { label: `revise:B:r${round}`, phase: 'Revise', schema: REVISE_SCHEMA })
  chk = await agent(CHECK(round), { label: `check:B:r${round}`, phase: 'Check', schema: VERDICT_SCHEMA })
  history.push({ rev, chk })
  round++
}
return { final: DST, rounds: history.length, lastVerdict: chk && chk.verdict, lastIssues: chk && chk.issues, unaddressed: chk && chk.unaddressed_referee_issues, revSummaries: history.map(h => h.rev && h.rev.summary) }
