export const meta = {
  name: 'finalize-depth2-width',
  description: 'Turn the two repaired red-team results into notes (depth two, small learner width), apply referee fixes, and re-referee',
  phases: [
    { title: 'Revise', detail: 'author applies every referee issue' },
    { title: 'Check', detail: 'independent referees / checkers' },
  ],
}

const S = '/tmp/claude-0/-workspace/e8ce7448-1256-507d-9f63-d716a14ba11f/scratchpad/agnostic'
const R = '/workspace/ai-works/neural-network-generalization/works-in-progress/agnostic-learning'

const CONTEXT = `Context. We are publishing a research note on an agnostic (misspecified, MSE) version of the NNBayes generalization results, in the repository folder ${R} (project root /workspace/ai-works/neural-network-generalization, written NNG/ in the notes; never write absolute paths in a note). Layout:
- README.md (overview, written by the lead later);
- research-notes/: problem-brief.md (the brief; its section 1 defines the property (P_L)), A-tight-conditioning-fails.md (tight conditioning fails at depth >= 3; being finalized, numbering stable; staged copy ${S}/stage/A-tight-conditioning-fails.md), B-tempered-likelihood.md (final: tempered likelihood c = n^(1-theta) works at every width for theta < 1/H, clipped predictors; Theorem 6.3, Theorem 7.4, Corollary 8.1, Corollary 9.3, section 7.5 general c), C-fixed-temperature-bayes.md, E-finite-prior-scale.md, red-team.md (the red-team report, being finalized separately; its sections 5 and 6.3 will be replaced by pointers to the two notes below), literature.md, and two NEW notes made from repaired red-team results: depth-two.md (red-team section 5: Theorem 5.1, Corollary 5.2, Proposition 5.3, with the red-team lemma numbering 1.0-1.3, 2.1) and small-learner-width.md (red-team section 6.3: Proposition 6.1, now Theorem 1, Corollaries 2-3, Theorem 4, Remarks 5-8);
- verification/: referee reports. For the depth-two result: RT-depth2-logic.md and RT-depth2-computation.md (first round, on red-team.md section 5), RT-depth2-logic-revised.md and RT-depth2-computation-revised.md (second round, on the repaired proof). For the width result: RT-width-logic.md, RT-width-computation.md (first round), RT-width-logic-revised.md, RT-width-computation-revised.md (second round).
- checks/: scripts with outputs. checks/depth-two/ and checks/small-learner-width/ hold the repair author's scripts; checks/verify-RT-<key>-<lens>[-revised]/ hold the referees' scripts.
Rules: do not run git. Write only the file you are asked to write and, if needed, scripts in its checks/ folder; scratch files go under ${S}/stage/.`

const COMMON_REVISE_RULES = `General rules for the final text:
1. Address EVERY issue in the second-round reports, including all minor ones. Fix the text where the issue is valid; if you judge one invalid, do not change the text for it and explain why in the referee record.
2. Never strengthen a claim. Weaken explicitly where needed. Keep every proved result.
3. Keep the numbering of the results (other documents cite them as red-team numbers). New material goes into lettered items (e.g. Remark 5.4a).
4. Opening paragraph: a research note of the agnostic-learning note (../README.md); say it replaces the corresponding red-team section (red-team.md), keeps its numbering, and was refereed twice (cite the reports with relative paths ../verification/...); define NNG/ as the project folder neural-network-generalization/ of this repository; cite the brief as problem-brief.md and the scripts as the checks folder named below. Paper proofs with numerical checks, not Lean verified.
5. Scripts: if a referee found a wrong number or a script that does not do what the text says, edit the script in the note's checks folder, re-run it there (python3 X.py > X.out) if it runs in under five minutes, and make the text agree with the output.
6. Keep the existing response to the first-round referees, and add a final section "Referee record, second round": the reports (relative paths) and a table with one row per issue: report, short description, resolution (fixed / weakened / rebutted), where.
7. Plain, precise prose; no marketing language.`

const DOCS = [
  { key: 'depth2', file: 'depth-two.md', checks: 'checks/depth-two/', reports: ['RT-depth2-logic-revised.md', 'RT-depth2-computation-revised.md'], rereferee: true,
    extra: `The second-round logic referee found the mathematics correct but raised three MAJOR definition and scope issues, which you must fix (read its report in full):
(i) The width quantifier. The "+o(1)" property (P_2^{o(1)}) was defined with "every learner width N >= 1" against competitors of width up to n^alpha. That makes it false for every learner by a width-1 approximation argument (the referee's example), so the refutation is vacuous as written, and it conflicts with B-tempered-likelihood.md Corollary 8.1, which uses learner widths N >= n^alpha. Define the property with learner widths at least the competitor class's width bound (N >= n^alpha), as in B Corollary 8.1, and check that every refutation in the note still holds under that definition (the failures are shown at N >= N_0, which must exceed n^alpha; say so).
(ii) The d <= n formulation. "+o(1) uniformly over d <= n" is information-theoretically impossible for every learner (the referee's example with d = n and x uniform on the unit vectors). So Proposition 5.3 refutes nothing specific to close conditioning in that formulation, and "unit-ball inputs: refuted only for c < 0.348" is a false status claim. Reframe Proposition 5.3 as what it shows: SP_c is worse than the Bayes-optimal zero network by beta(lambda) - o(1), in a regime (d = M of order n) where no learner meets a polynomial guarantee; remove every claim that it refutes a formulation of the conjecture.
(iii) The open range. At depth two (H = 1), B-tempered-likelihood.md proves the positive side for c = n^(1-theta), theta in (0,1), with clipped predictors (Theorem 6.3), and its section 7.5 and Theorem 7.4(a) treat general c. The referee says that for clipped readings with log^2 n << c <= n^(1-eps), B already proves the +o(1) formulation. Check this claim against B's actual statements (open B and verify the hypotheses: dimension d = log2 n on the noisy cube, the capacity term at H = 1, the competitor class), state precisely what B gives at depth two for general c, and state the open range exactly (it should include c = 1 if the lower bound there tends to 0). Do not claim B proves more than it states; if B only gives it for the noisy cube or only for fixed competitors, say so.
Also fix every minor issue of both second-round reports (misrounded table entry, an errata sentence that rounds lower bounds up, the step 'Q^+ <= 2M' that needs M large, wording and scope points).
Make sure the note says clearly, near the top, what is refuted at depth two and what is not: the polynomial-sample property (P_2) fails for every 0 < c <= poly(d) = polylog(n) (excess >= gamma(lambda)(18dc+1)^-2 (1-o(1)), which decays only polylogarithmically); the +o(1) formulation fails for c <= nu/log2 n; the case dc -> infinity (e.g. c = 1) is open for +o(1); learner widths below N_0 and the progressive mixture are not covered.` },
  { key: 'width', file: 'small-learner-width.md', checks: 'checks/small-learner-width/', reports: ['RT-width-logic-revised.md', 'RT-width-computation-revised.md'], rereferee: false,
    extra: `Both second-round referees found the repaired result correct (minor fixes only). Apply every minor issue in both reports. Among them: Lambda_N names both the diagonal energy matrix and the logarithm (rename one); Remark 8 says the full excess beta(lambda) - o(1) needs width N_0 = O(n^{5/3} log^2 n), but that bound belongs to A's Corollary 4.5 schedule a = n^{-1/3}, and any a_n -> 0 works at N_0 = O(n log^2 n / a_n^2) (e.g. a = 1/d gives O(n log^4 n)); section 7.3 misses a citation of Proposition 6.1 in red-team.md section 8 (the finite-scale sketch), which applies it outside Theorem 1's scope; the A2 replacement text omits the hypothesis d <= n^alpha. Check A's numbering against ${S}/stage/A-tight-conditioning-fails.md (Corollary 4.5, Remark 4.7). Make sure the note says near the top what it proves: with c = 1 (tight conditioning) at learner width about n^alpha, alpha < 1/4, the clipped near-minimizers, Gibbs risk and posterior mean of clipped outputs compete with depth-L networks of width and weights <= n^alpha, with excess O(n^{2 alpha - 1/2}) (rate of the corrected clause), and that this is not uniform over learner widths (Claim A shows failure at widths above a polynomial in n).` },
]

const REVISE = (d, extra) => `You are the author of the research note below, preparing its final published version after two rounds of review.

${CONTEXT}

Input: the current text ${S}/stage/${d.file} (scratch paths already rewritten to the repository layout; check them). Second-round referee reports to address: ${d.reports.map(r => R + '/verification/' + r).join(', ')}. Read them completely, and the note completely. The first-round reports (same names without -revised) were answered in the note's response section; keep that.

${d.extra}

Task: write the complete final note to ${R}/research-notes/${d.file}. Scripts are in ${R}/${d.checks}.
${COMMON_REVISE_RULES}
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

const CHECK = (d, round) => `You are an independent checker of a revised research note. Your job is to find problems; default to reporting an issue when uncertain.

${CONTEXT}

Files: the revised note ${R}/research-notes/${d.file}; the pre-revision text ${S}/stage/${d.file} (compare with diff); the second-round referee reports ${d.reports.map(r => R + '/verification/' + r).join(', ')}; scripts in ${R}/${d.checks}.
Check:
(a) Every issue in those reports is addressed correctly (fixed, or rebutted with a valid reason). List unaddressed ones.
(b) Every changed passage is mathematically correct; re-derive changed statements and numbers; run Python where useful (scratch ${S}/stage/check-${d.key}-r${round}/).
(c) No claim was strengthened; no proved result dropped silently.
(d) Every cross-reference to another note states what the cited item says in its current version (B final at research-notes/B-tempered-likelihood.md; A at research-notes/A-tight-conditioning-fails.md if present, else ${S}/stage/A-tight-conditioning-fails.md).
(e) Relative paths resolve from ${R}/research-notes/ (red-team.md, literature.md and the README may be missing for now); no absolute paths; quoted script outputs match the .out files.
Write a short report to ${S}/stage/check-${d.key}-r${round}.md and return the structured verdict ('correct' only if everything checks; 'minor_fixes' for small remaining problems; 'major_flaw' if a revision introduced an error or left a referee issue unaddressed in a way that matters).`

const REREFEREE = (d, round, lens) => `You are an adversarial referee. Your job is to find flaws in a research note, especially in what it claims is refuted or proved; do not fix it yourself beyond suggesting fixes. Default to reporting an issue when uncertain.

${CONTEXT}

Note under review: ${R}/research-notes/${d.file} (final candidate). Earlier reports on it: ${R}/verification/RT-depth2-logic.md, RT-depth2-computation.md (first round), RT-depth2-logic-revised.md, RT-depth2-computation-revised.md (second round; the second-round logic report found three major definition and scope issues, which this revision claims to fix). The brief: ${R}/research-notes/problem-brief.md.
LENS = ${lens === 'scope' ? 'scope and definitions: are the formulations of the conjecture that the note claims to refute well defined, non-vacuous (satisfiable by some learner, e.g. the tempered learner of B-tempered-likelihood.md), and consistent with the brief and with B Corollary 8.1? Is every "refuted" / "not refuted" / "open" status claim exactly right? Are the three major issues of the second-round logic report fixed? Check every claim about what B-tempered-likelihood.md proves at depth two against B itself.' : 'logic and computation of the changed passages: re-derive every statement, constant and number that changed relative to the pre-revision text ' + S + '/stage/' + d.file + ' (diff them), and check quantifiers and limit order (sigma -> 0 after sample and width are fixed). Run Python where useful.'}
Write your report to ${S}/stage/rereferee-${d.key}-${lens}-r${round}.md and return the structured verdict ('correct', 'minor_fixes', 'major_flaw' or 'wrong'); put unaddressed second-round issues in unaddressed_referee_issues.`

const blocking = (v) => v && (v.verdict === 'major_flaw' || v.verdict === 'wrong' || (v.issues || []).some(i => i.severity !== 'minor') || (v.unaddressed_referee_issues || []).length > 0)

const results = await pipeline(DOCS, async (d) => {
  let rev = await agent(REVISE(d, ''), { label: `revise:${d.key}`, phase: 'Revise', schema: REVISE_SCHEMA })
  const history = []
  for (let round = 1; round <= 3; round++) {
    let checks
    if (d.rereferee) {
      checks = (await parallel(['scope', 'logic-computation'].map(lens => () => agent(REREFEREE(d, round, lens), { label: `referee:${d.key}:${lens}:r${round}`, phase: 'Check', schema: VERDICT_SCHEMA })))).filter(Boolean)
    } else {
      checks = [await agent(CHECK(d, round), { label: `check:${d.key}:r${round}`, phase: 'Check', schema: VERDICT_SCHEMA })].filter(Boolean)
    }
    history.push({ rev: rev && rev.summary, checks: checks.map(c => ({ verdict: c.verdict, issues: c.issues, unaddressed: c.unaddressed_referee_issues, summary: c.summary })) })
    const allIssues = checks.flatMap(c => c.issues || [])
    const unaddressed = checks.flatMap(c => c.unaddressed_referee_issues || [])
    const anyBlocking = checks.some(blocking)
    if (!anyBlocking && (allIssues.length === 0 || round >= 2)) break
    if (round === 3) break
    log(`${d.key}: round ${round} -> ${checks.map(c => c.verdict).join(', ')}; revising`)
    rev = await agent(REVISE(d, `\nThis is revision round ${round + 1}. The note ${R}/research-notes/${d.file} already exists: edit it in place. Independent ${d.rereferee ? 'referees' : 'checkers'} reported these problems with the previous revision (JSON):\n${JSON.stringify({ issues: allIssues, unaddressed }, null, 1)}\nFix each valid one; rebut invalid ones in the referee record (add a 'Check of the revision' table).`), { label: `revise:${d.key}:r${round + 1}`, phase: 'Revise', schema: REVISE_SCHEMA })
  }
  return { key: d.key, final: `${R}/research-notes/${d.file}`, history }
})
return results