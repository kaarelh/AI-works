export const meta = {
  name: 'purpose-redteam',
  description: 'Red-team the purpose-sensitivity study: five skeptic lenses, then adversarial verification of each serious issue',
  phases: [
    { title: 'Critique', detail: 'five independent skeptics, one lens each' },
    { title: 'Verify', detail: 'independent verifier per critical/major issue tries to refute it' },
  ],
}

const ROOT = '/home/user/AI-works/purpose-sensitivity'
const COMMON = `You are red-teaming a research project before publication. Project root: ${ROOT}. Read ${ROOT}/README.md (the write-up and its claims) and ${ROOT}/DESIGN.md (pre-registered design + post-pilot changes) first. Code is in ${ROOT}/src (task_*.py define tasks and scorers; conditions.py defines principals and prompts; run.py the runner; score.py, judge.py, judge_loop.py, code_loop_patterns.py the scoring/judging; analyze.py the statistics; figures.py). Data: ${ROOT}/runs/main_raw/<id>.json (raw responses with prompts; id = task__cond__model__rNN), ${ROOT}/results/scored.jsonl (one row per response), ${ROOT}/analysis/ (report.md with all tables, CSVs, scored_with_judge.csv, qualitative/workflow_result.json), ${ROOT}/runs/loop_judge, runs/loop_judge_opus, runs/judge/attitude, runs/judge/edits, runs/loop_patterns.
You may run python3 to recompute anything (pandas, numpy available). DO NOT modify, create or delete any file under ${ROOT}; work in /tmp if you need scratch files.
Report only real problems you can substantiate with evidence (file paths, line numbers, recomputed numbers, quotes). Rate severity: critical (a headline conclusion is wrong or unsupported), major (a specific claim/number is wrong or materially misleading, or a validity threat is unaddressed), minor (wording, small inaccuracies). Do not pad: an empty list is fine if you find nothing.`

const ISSUE_SCHEMA = {
  type: 'object',
  properties: {
    lens: { type: 'string' },
    issues: {
      type: 'array',
      items: {
        type: 'object',
        properties: {
          id: { type: 'string' },
          severity: { type: 'string', enum: ['critical', 'major', 'minor'] },
          location: { type: 'string', description: 'README section / file:line' },
          claim_or_component: { type: 'string' },
          problem: { type: 'string' },
          evidence: { type: 'string' },
          suggested_fix: { type: 'string' },
        },
        required: ['id', 'severity', 'location', 'claim_or_component', 'problem', 'evidence', 'suggested_fix'],
      },
    },
    checked_ok: { type: 'string', description: 'what you checked and found sound' },
  },
  required: ['lens', 'issues', 'checked_ok'],
}

const LENSES = [
  { key: 'statistics', prompt: `LENS: statistics. Audit src/analyze.py and the reported numbers. Check: the blocking/pairing logic (block = model x task x rep; is pairing valid given conditions were sampled independently?), the sign-flip permutation test and bootstrap implementation, standardisation within model x task when many cells have zero variance (does it dilute or bias pooled estimates, and is the SD-unit MDE claim right?), the Holm correction family, whether "pre-registered primary family = four tasks" is consistent with DESIGN.md, multiple-comparison exposure in the secondary/effort claims, and whether the CIs/p-values quoted in README's tables match analysis/pre4_pooled_contrasts_*.csv and analysis/secondary_contrasts.csv. Recompute at least the primary table independently from results/scored.jsonl.` },
  { key: 'measurement', prompt: `LENS: measurement validity. Audit every scorer and judge for bugs and, above all, for asymmetries across conditions that could fake or mask a principal effect. Specifically: task_memo.py anchors (T6 uses stance-specific role nouns; are other anchors condition-specific?), memo parse robustness (sample at least 15 memo responses across conditions where errors were marked missed and verify by reading whether they were really missed); task_whip.py parsing and the rubric's determinacy (e.g. Whitfield item); task_sched.py parser and salvage scoring (sample 10 sched responses, re-verify feasibility); task_code.py harness; judge_loop.py (does the judge see condition-revealing text? check runs/loop_judge_agreement.md) and especially the I6 item: read at least 8 industry and 8 ban responses judged missing/finding I6 and decide whether the judge's call is right and condition-symmetric. Report false negatives/positives by condition.` },
  { key: 'design', prompt: `LENS: design and construct validity. Does the design actually answer "do AIs perform worse when working toward an AGI ban than toward other purposes"? Examine: what exactly differs between conditions (read conditions.py and task_*.py build_prompt; diff actual prompts in runs/main_raw for ai_ban vs ai_industry vs ai_neutral on each task) -- especially whether request wording differences (not just the principal's identity/mission) could drive the loop findings; the hidden headless preamble and the "no tools" line; realism/eval-awareness (grep responses for signs the model treats it as a test); ceiling effects and what they do and don't license; the neutral newsroom as a control; fictional orgs vs MIRI; whether the README overgeneralises (e.g. from Claude-only, single-turn, near-ceiling tasks to "AIs"). Distinguish threats the README already acknowledges from unacknowledged ones.` },
  { key: 'claims', prompt: `LENS: claim-by-claim audit. Go through README.md sentence by sentence and verify every numeric or factual claim against the data/analysis outputs (recompute where needed): e.g. the summary bullets, every table cell in Results, effort percentages, ambiguous-lean numbers, attitude rates ("Opus wished ... good luck 6 times"), loop table values, issue-list lengths, the quoted passages (verify each quote exists verbatim in some runs/main_raw response and is attributed to the right model/condition), counts (1,428 responses, cost figures, ~550 failed calls), and the description of the multi-agent workflow and coder agreement (analysis/qualitative/workflow_result.json, and run 'python3 src/code_loop_patterns.py --validate runs/loop_patterns analysis/qualitative/workflow_result.json' from ${ROOT} -- this only reads). List every discrepancy.` },
  { key: 'alternatives', prompt: `LENS: alternative explanations and overclaiming for the positive findings (section 3, loophole review, and the small mining wishful-thinking effect). For each pattern in the README's loop table, propose the strongest alternative explanation (request-wording differences, judge/coder bias, relevance to the stated use, model-specific quirks, a few outlier models driving pooled rates, domain differences in what I6 means) and test it with the data: break down by model, check whether the coder (runs/loop_patterns, Sonnet) could be keying on condition-revealing words, read a sample of responses. Also assess whether the README's interpretation ("asymmetric candour", "not sandbagging", "not AI-specific") is warranted or over/under-stated. Check the claim that the interaction is null for calibration and hold-back and positive for the grandfather step.` },
]

phase('Critique')
const critiques = await parallel(LENSES.map(L => () => agent(`${COMMON}\n\n${L.prompt}`, { label: `critique:${L.key}`, phase: 'Critique', schema: ISSUE_SCHEMA })))
const all = critiques.filter(Boolean).flatMap(c => c.issues.map(i => ({ ...i, lens: c.lens })))
const serious = all.filter(i => i.severity !== 'minor')
log(`${all.length} issues raised (${serious.length} critical/major)`)

const VERDICT_SCHEMA = {
  type: 'object',
  properties: {
    issue_id: { type: 'string' },
    verdict: { type: 'string', enum: ['confirmed', 'partially_confirmed', 'refuted'] },
    corrected_severity: { type: 'string', enum: ['critical', 'major', 'minor', 'none'] },
    reasoning: { type: 'string' },
    evidence: { type: 'string' },
    recommended_fix: { type: 'string' },
  },
  required: ['issue_id', 'verdict', 'corrected_severity', 'reasoning', 'evidence', 'recommended_fix'],
}

phase('Verify')
const verified = await parallel(serious.map(i => () => agent(
  `${COMMON}\n\nYou are an independent verifier. A skeptic (lens: ${i.lens}) raised this issue:\n${JSON.stringify(i, null, 1)}\n\nTry hard to REFUTE it: re-derive the evidence yourself from the files and data, check whether the README already addresses it, and whether the claimed impact is real. Confirm only if you can reproduce the problem. Give a corrected severity and a concrete recommended fix (exact wording or code change) if confirmed.`,
  { label: `verify:${i.id}`, phase: 'Verify', schema: VERDICT_SCHEMA }).then(v => ({ issue: i, verification: v }))))

return {
  minor: all.filter(i => i.severity === 'minor'),
  serious: verified.filter(Boolean),
  checked_ok: critiques.filter(Boolean).map(c => ({ lens: c.lens, ok: c.checked_ok })),
}
