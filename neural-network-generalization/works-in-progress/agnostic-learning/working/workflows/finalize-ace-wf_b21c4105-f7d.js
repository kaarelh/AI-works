export const meta = {
  name: 'finalize-ACE',
  description: 'Apply the final referee fixes to proofs A, C, E and independently check each revision',
  phases: [
    { title: 'Revise', detail: 'author applies every referee issue' },
    { title: 'Check', detail: 'independent checker verifies the revision' },
  ],
}

const S = '/tmp/claude-0/-workspace/e8ce7448-1256-507d-9f63-d716a14ba11f/scratchpad/agnostic'
const R = '/workspace/ai-works/neural-network-generalization/works-in-progress/agnostic-learning'

const RT_STATUS = `Verification status of the red-team propositions (research-notes/red-team.md, still being repaired; cite them with exactly this status, never as more):
- Proposition 4.1 (TUBE with a sup-norm residual budget rho_0): two referees (logic, computation) found it correct, minor fixes only. 'Never memorizes' holds only in the energy sense. The comparison with OPT must not be read as a constant factor of OPT: the bound is (tau+rho_0)^2 + 4eps/3, and an exact example has risk (rho - p rho_0)^2 + p(1-p) rho_0^2 while L_D(g) = p rho_0^2.
- Proposition 6.1 (learner width n^alpha with c=1): the displayed inequality is correct (two referees), but the 'in particular' rate O(n^{4alpha-1} + n^{alpha-1/2} sqrt(log n)) is wrong. It drops the competitor's Hoeffding term (U+1)^2 sqrt(ln(4/delta)/(2n)), so the display gives a polynomially small excess only for alpha < 1/8. A Bernstein step for the competitor restores 'polynomially small for every alpha < 1/4', at rate O~(n^{2alpha-1/2}). A repair is in progress; cite it as 'refereed with a corrected rate, repair under review'.
- Remark 6.2 (conditioning on aggregate training MSE < tau): correct (one logic referee), minor fixes. tau must exceed the competitor's empirical loss; for a high-probability statement, tau >= L_D(g) + (U+1)^2 sqrt(ln(1/delta)/(2n)).
- Section 5 (depth two): the proofs are correct (two referees). But Corollary 5.2's sentence 'it does not refute the +o(1) formulation' is false for c -> 0: for c = O(1/d) = O(1/log n), depth-two SP_c has constant excess (beta(lambda) - o(1) when dc -> 0). Repair in progress.`

const CONTEXT = `Context. We are publishing a research note on an agnostic (misspecified, MSE) version of the NNBayes generalization results, in the repository folder ${R} (project root /workspace/ai-works/neural-network-generalization, written NNG/ in the notes). Layout of the note folder:
- README.md (overview, written later by the lead);
- research-notes/: problem-brief.md (staged at ${S}/stage/problem-brief.md, to be published), A-tight-conditioning-fails.md, B-tempered-likelihood.md (already final), C-fixed-temperature-bayes.md, E-finite-prior-scale.md, red-team.md and literature.md (both being finalized separately);
- verification/: referee reports. For A: A-first-version.md (the first version of A), A-first-version-logic.md, A-first-version-computation.md, A-first-version-scope.md (first round, answered in A's Appendix R), and A-logic.md, A-computation.md, A-scope.md (second round, on the revised A). B-logic.md, B-computation.md, B-scope.md; C-logic.md, C-computation.md; E-logic.md, E-computation.md.
- checks/: scripts with outputs: checks/A/, checks/B/, checks/C/, checks/E/, checks/red-team-and-literature/, checks/verify-<X>-<lens>/ for the referees' scripts.
The problem statement the proofs call "the brief" is research-notes/problem-brief.md.
Results of the four proofs, for cross-references: A (tight conditioning fails at depth >= 3, width-uniformly, with d -> infinity), B (tempered likelihood c = n^(1-theta), theta < 1/H, works at every width; sharp at 1/H), C (fixed-temperature progressive mixture works only at polynomial width), E (finite prior scale). Section and result numbering of A, B, C and E is stable: a revision only adds new items.
${RT_STATUS}
Rules: do not run git. Write only the file you are asked to write and, if needed, scripts in its checks/ folder; scratch files go under ${S}/stage/.`

const DOCS = [
  { key: 'A', file: 'A-tight-conditioning-fails.md', checks: 'checks/A/', reports: ['A-logic.md', 'A-computation.md', 'A-scope.md'],
    extra: `This is the SECOND referee round for A. The document already has Appendix R, which answers the first-round reports; keep Appendix R, point its references to ../verification/A-first-version-logic.md, A-first-version-computation.md and A-first-version-scope.md, and say in the opening paragraph that the first version is preserved at ../verification/A-first-version.md. The second-round reports to address now are ../verification/A-logic.md, A-computation.md, A-scope.md. Put the new referee record in a new Appendix R2 ("Second referee round"). Where A cites red-team propositions, use the verification status given above. Where A cites B, C or E, check the cited statement in research-notes/B-tempered-likelihood.md (final), ${S}/stage/C-fixed-temperature-bayes.md and ${S}/stage/E-finite-prior-scale.md.` },
  { key: 'C', file: 'C-fixed-temperature-bayes.md', checks: 'checks/C/', reports: ['C-logic.md', 'C-computation.md'],
    extra: `C was refereed by two referees (logic, computation), both 'minor_fixes'. Where C cites A, B or E, check the cited statement in ${S}/stage/A-tight-conditioning-fails.md (A, revised; numbering stable), research-notes/B-tempered-likelihood.md (final), ${S}/stage/E-finite-prior-scale.md.` },
  { key: 'E', file: 'E-finite-prior-scale.md', checks: 'checks/E/', reports: ['E-logic.md', 'E-computation.md'],
    extra: `E was refereed by two referees (logic, computation), both 'minor_fixes'. E was written against the FIRST version of A. Check every citation of A against the revised A at ${S}/stage/A-tight-conditioning-fails.md (numbering stable; Section 5 gained 5.2 'Fixed input dimension', so the old 5.2 'Discussion' is now 5.3; new items Prop 5.2, Prop 6.6, Prop 7.4, Remarks 7.5-7.6). Where E repeats a caveat of A, use A's revised wording: the refutation needs d -> infinity (d = log2 n), and at fixed d the cube family is consistent at every width (A Prop. 5.2); 'test MSE tends to 2' is a two-sided statement only in A Prop. 6.1(a') at n = M. Where E cites B or C, check against research-notes/B-tempered-likelihood.md and ${S}/stage/C-fixed-temperature-bayes.md.` },
]

const REVISE = (d, extra) => `You are the author of the document below, preparing its final published version after peer review.

${CONTEXT}

Input: the current text ${S}/stage/${d.file} (scratch paths already rewritten to the repository layout; check them anyway). Referee reports to address: ${d.reports.map(r => R + '/verification/' + r).join(', ')}. Read all of them completely, and the document completely.
${d.extra}

Task: write the complete final document to ${R}/research-notes/${d.file}.
1. Address EVERY issue raised in the reports, including all minor ones. Fix the text where the issue is valid: correct numbers, add missing quantifiers and qualifiers (uniformity over laws, d growing with n, learner widths N >= N0(n), clipped vs unclipped predictors, labels in [-1,1], exact competitor architecture, limit order sigma -> 0 after n), and make every summary sentence true as stated. If you judge an issue invalid, do not change the text for it; explain why in the referee record.
2. Never strengthen a claim. When a fix requires weakening, weaken explicitly. Keep every proved result.
3. Keep the numbering of sections, theorems, lemmas, propositions, corollaries and remarks stable, because other documents cite them. New material goes into new items with primed or lettered numbers (for example Remark 4.7a), not by renumbering.
4. Opening paragraph: say this is a research note of the agnostic-learning note (../README.md); define NNG/ as the project folder neural-network-generalization/ of this repository (no absolute paths anywhere); cite the brief as problem-brief.md and the scripts as ../${d.checks}.
5. Scripts: where a referee found a wrong number, a stale docstring or a script that does not do what the text says, edit the script in ${R}/${d.checks}, re-run it from that folder (python3 X.py > X.out) if it runs in under five minutes, and make the text agree with the new output. If a script takes longer, do not re-run it; say so in the record.
6. End with a section "Referee record": list the reports (relative paths ../verification/...) and a table with one row per referee issue: report, short description, resolution (fixed / weakened / rebutted), where in the text.
7. Plain, precise prose; no marketing language. Keep the mathematical content and proofs; edit only what the reviews require, plus the opening paragraph, the record, and cross-reference corrections.
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

const CHECK = (d, round) => `You are an independent checker of a revised mathematical document. Your job is to find problems; default to reporting an issue when uncertain.

${CONTEXT}

Files: the revised document ${R}/research-notes/${d.file}; the pre-revision text ${S}/stage/${d.file} (compare with diff); the referee reports ${d.reports.map(r => R + '/verification/' + r).join(', ')}; the scripts in ${R}/${d.checks}.
Check:
(a) Every issue in the referee reports is addressed correctly, either fixed in the text or rebutted with a valid reason. List any that are not in unaddressed_referee_issues.
(b) Every changed passage is mathematically correct. Re-derive changed statements, numbers and exponents; run Python where useful (scratch folder ${S}/stage/check-${d.key}-r${round}/).
(c) No claim was strengthened, and no proved result was dropped without saying so.
(d) The numbering of sections and results is unchanged from the pre-revision text, apart from added primed or lettered items.
(e) Every cross-reference to another note (A, B, C, E, red-team) states what the cited item actually says, in its current version (A revised: ${S}/stage/A-tight-conditioning-fails.md or research-notes/A-tight-conditioning-fails.md if already final; B final: research-notes/B-tempered-likelihood.md; C, E: stage or research-notes). Red-team propositions are cited with the status given above.
(f) Every relative path in the document resolves from ${R}/research-notes/ (problem-brief.md, red-team.md, literature.md and the other notes may be missing for now; that is fine), there are no absolute paths, and the script outputs quoted in the text match the .out files.
Write a short report to ${S}/stage/check-${d.key}-r${round}.md and return the structured verdict. Use 'correct' only if everything checks; 'minor_fixes' for small remaining problems; 'major_flaw' if a revision introduced an error or left a referee issue unaddressed in a way that matters.`

const results = await pipeline(DOCS, async (d) => {
  let rev = await agent(REVISE(d, ''), { label: `revise:${d.key}`, phase: 'Revise', schema: REVISE_SCHEMA })
  let chk = await agent(CHECK(d, 1), { label: `check:${d.key}:r1`, phase: 'Check', schema: VERDICT_SCHEMA })
  const history = [{ rev, chk }]
  let round = 2
  while (chk && chk.verdict !== 'correct' && round <= 3) {
    const needs = chk.verdict === 'major_flaw' || chk.verdict === 'wrong' || (chk.unaddressed_referee_issues || []).length > 0 || (chk.issues || []).length > 0
    if (!needs) break
    log(`${d.key}: checker verdict ${chk.verdict}; revision round ${round}`)
    rev = await agent(REVISE(d, `\nThis is revision round ${round}. The document ${R}/research-notes/${d.file} already exists: edit it in place (do not start again from the stage copy). An independent checker reported these problems with the previous revision (JSON):\n${JSON.stringify({ issues: chk.issues, unaddressed: chk.unaddressed_referee_issues }, null, 1)}\nFix each valid one; rebut invalid ones in the referee record (add a short 'Check of the revision' table).`), { label: `revise:${d.key}:r${round}`, phase: 'Revise', schema: REVISE_SCHEMA })
    chk = await agent(CHECK(d, round), { label: `check:${d.key}:r${round}`, phase: 'Check', schema: VERDICT_SCHEMA })
    history.push({ rev, chk })
    round++
  }
  return { key: d.key, final: `${R}/research-notes/${d.file}`, rounds: history.length, lastVerdict: chk && chk.verdict, lastIssues: chk && chk.issues, unaddressed: chk && chk.unaddressed_referee_issues, revSummaries: history.map(h => h.rev && h.rev.summary), checkSummaries: history.map(h => h.chk && h.chk.summary) }
})
return results