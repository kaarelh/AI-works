export const meta = {
  name: 'apply-referee-round',
  description: 'Apply the referees\' findings to the section sources of the imitation note, and check the new proposition Ab5',
  phases: [
    { title: 'Check Ab5', detail: 'a line-by-line check and an adversarial reading of the new proposition on batches' },
    { title: 'Edit', detail: 'one editor per section source decides and applies the referee findings' },
  ],
}

const ROOT = '/home/user/AI-works/principled-imitation'

const COMMON = [
  'You work in the repository at /home/user/AI-works, in the project folder principled-imitation/ (absolute path ' + ROOT + ').',
  'The project is a research note, note.md, written for a researcher who asked for a human-imitation protocol with a theorem. The note is GENERATED from the section sources in research/sections/ by research/orchestration/assemble.py; full proofs are in proofs/ (one file per part, each ending with a section "Checking"); the reports of all checks are in verification/. research/outline.md has the plan, the notation and the style rules (see its Addendum 3). research/understand/ holds digests of the literature and of the researcher\'s notes.',
  'Rules: do not run git commands that change anything (no commit, no push, no checkout). Do not edit note.md. Do not put the researcher\'s name, the repository\'s name or any text of the project into web queries. Scripts must finish within 10 minutes and use at most 4 GB. Write in plain words and full sentences; say exactly what you checked and what you did not.',
].join('\n')

const PARTS = {
  'rehearsal-core': {
    where: 'Sections 1, 2, 3.1, 3.3, 3.4, 3.5 and 3.6 of the note. (The caveat paragraphs on A1 to A3 inside Section 1 are BLOCK A of assumptions.md and are not yours; Section 3.2 is block (i) of hellinger-runs.md and is not yours.)',
    items: [
      'reader: F13 (R7: its meaning in bits, what it does not say, the random-stopping argument), F16 first half (how K is to be read in Sections 3.1 to 3.4), the rows of F18 on "the run that counts", "the ladder", "Protocol R" and on "Paper 1" at its first use in your sections, F19 (r, r-hat and s_P in V1; X0 for the region of R7), F20 items 4 and 5, Part G (say at R3 that the bound is empty for a person under a generic prior), F31, F33 item 2.',
      'mathematics: F3, F5 (add the argument for V1(c) to the note and to the proof file), F9, F16 (name Protocol R in Section 2; define "outcome of a run" and "unfaithful run" in Section 1), F21, F24, F25, F29.',
      'consistency: the letter rho in V1(a); "Protocol R" never named; "350 years" are working years; the letter of the slack in R3a.',
      'references: the replacements of Section 3 of that report that fall in your sections (for example "Christiano\'s term", the Azuma-Hoeffding inequality).',
    ],
  },
  'hellinger-runs': {
    where: 'Section 3.2 of the note (block (i) of your file) and Section 5.2 (block (ii)).',
    items: [
      'reader: the row of F18 on the squared Hellinger distance, F20 item 6, F21 item 1 (the idea of the proof of L4: give the idea as proposed after checking it against the proof, or print the short proof), F25(a), F32 item 1, F33 item 5.',
      'mathematics: F6, F7, F15, F17, F36.',
      'consistency: the label N6 is stated twice; the pointer for L4 (Corollaries 2.3 and 2.11); a sentence that describes how the note was produced.',
      'letters: in L4 write H²_j for the squared Hellinger distance at call j (h_j is the history in Section 1).',
      'The fixer of your part offered two small additions for Section 5.2 ("(so H1 fails once L >= 6)" after "against ln 2/N", and the pointer "(Remark 5.3 there)" after "for maximum likelihood"); add them if they are correct.',
    ],
  },
  'lower-bounds': {
    where: 'Section 4 of the note, and inside Section 6.1 the block with Theorem N3 and "What S2 needs" (the second block of your file).',
    items: [
      'reader: the rows of F18 on K(Q), "Paper 2", "Protocol AB" and "audits"; F20 items 7, 8, 9, 10 and 13 (state S2 as a proposition with its status before "What S2 needs"); F25(b); F31 (N2, N2b, N5: the result before the construction).',
      'mathematics: F8, F10, F11, F28, F16 (S2), F39(i).',
      'consistency: K(Q) is used and never defined; the region of N1 is to be written X0.',
      'references: the replacements of Section 3 of that report that fall in Section 4 (Paper 2 and Cohen et al. in 4.1; "crediting Dasgupta"; the attribution of Protocol AB; "Assouad\'s method").',
    ],
  },
  'one-mind': {
    where: 'Section 5 of the note up to the end of Section 5.1 (the heading of Section 5, its opening lines, and Section 5.1).',
    items: [
      'reader: F2(d) (where Section 5.1 uses squared weights, say that this is the steeper prior of the researcher\'s notes and of Paper 2, after checking the digest research/understand/notes.md, Section 2.4); the rows of F18 on "traps" and "the driver"; F20 item 11; F21 items 2 and 3; F22 item 1 (the cells and column heads of the table); F30 item 4 (first sentence quoted there); F33 item 1 (Sections 5 and 5.1 have the same heading: give 5.1 a plain heading of its own).',
      'mathematics: F13, F39(ii) and (iii).',
      'consistency: say at the start of 5.1 that bare numbers refer to proofs/one-mind.md; R6(a) in the form used by Section 11.',
      'references: finding 13 (the sentence proposed in Section 6 of that report on what Li and Zhang leave open may be added to Section 5.1); the halving algorithm and Littlestone.',
    ],
  },
  'shift-abstain': {
    where: 'Sections 6 and 7 of the note, without the block of Section 6.1 that holds Theorem N3 and "What S2 needs" (that block is in lower-bounds.md).',
    items: [
      'reader: F14(b), F17, the rows of F18 on "rocks", "audits" and "a needle class"; F19 (G for the logarithmic term of Ab2(d); p_s and p_a in the last row of Ab4 and after the table; Qu for the number of questions in N7 and Ab4); F20 items 12, 14 and 15; F22 items 2 and 3; Part G (say at Ab1 that the bound is empty for a person under a generic prior).',
      'mathematics: F4, F16 ("Rule Ab2", "needle class"), F30 to F35, F37.',
      'consistency: "all laws of l bits cost about 2^l" (the upper bound of S2 is 2^(2l+1)); say in the first paragraph of Section 7 that bare numbers refer to proofs/shift-abstain.md; sep(x; A) is never defined.',
      'references: the replacements of Section 3 of that report for Ab3 (Observation B is the digest\'s) and N4 (the example of singletons).',
    ],
  },
  'property-batch': {
    where: 'The opening of Section 8 and Sections 8.1, 8.2, 8.3, 8.6 and 8.7 of the note. In your file the last three carry the headings 8.2a, 8.5 and 8.6; the assembly renumbers the headings, so leave the heading lines as they are.',
    items: [
      'reader: F20 items 16 and 17; F23 (one sentence in 8.3 on why the estimate belongs to the property idea; and make plain the sentence of 8.2 that begins "The researcher\'s conflict is thereby confined"); F32 item 3; F33 item 2.',
      'mathematics: F14.',
      'consistency: which proof file the bare numbers refer to (say "Numbers in Sections 8.6 and 8.7 refer to proofs/property-batch.md" where needed); K_nu in the place of K(nu).',
      'references: the replacements of Section 3 of that report that fall in your sections ("after Yatracos", "Dwork et al.", Bousquet-Kane-Moran "Theorem 19 of arXiv version 5", the mark on Langford).',
      'A loose end of the fixer: the sentence of 8.2 "On a kind of input much rarer than 1/N a matching imitator may do anything (Remark 5.5)." rests on Remark 5.5(a) of proofs/property-batch.md, which only its author has seen. Be its second reader: check the argument line by line and on small exact cases, record the result in the proof file, and keep, correct or replace the sentence.',
    ],
  },
  'property-online': {
    where: 'Sections 8.4 and 8.5 of the note.',
    items: [
      'reader: the row of F18 on "Rule NH"; F23 (the paragraph on what becomes of the researcher\'s objection, to be placed after Pr5, and the sentence on properties that no short program decides, in 8.5; check both against the proofs before use); F30 item 4 (the fragment "Outside the closed system nothing (Theorem N1)."); F31 item 2 (state Pr5 for "the rule given below" first, then the rule, if that reads better); F33 item 2.',
      'mathematics: F18.',
      'consistency: say at the start of 8.4 that bare numbers in Sections 8.4 and 8.5 refer to proofs/property-online.md; lambda for the rate and kappa for the strength of the tilt.',
      'references: the mark on Littlestone; Le Cam.',
    ],
  },
  'assumptions': {
    where: 'Your file has three blocks. BLOCK A (the caveats on A1 to A3) is at present inside Section 1 of the note and will be placed as a new Section 3.7, "The assumptions in practice". BLOCK B is Section 9. BLOCK C is Section 10. Keep the marker lines exactly as they are, and add one new marker line for the new block A0 (see the decisions file, Section 4).',
    items: [
      'reader: F5, F6, F7 (a list of the bets at the head of Section 9; say at I1 and at E1 that the bound is empty for a person), F14(a), F15 ("What survives"), F16 second half, the rows of F18 on "a class without patches", "patch-free prior", "isolated", "the human\'s kernel" and "Paper 1"; F20 items 3, 18, 19 and 20; F21 item 4; F27, F28, F29; F30 items 2, 3 and 5.',
      'mathematics: F23, F38.',
      'consistency: delta has two meanings in Section 9 (write gamma for the separation of I1); "K the weight of that function"; "Section 8 of the proof file" and the missing word "exactly".',
      'references: the replacements of Section 3 of that report that fall in your blocks (the attribution of the seven tests; Barron and Cover in the caveat on A2; Thompson 1933; Paper 1, Proposition 8.2).',
      'the new proposition Ab5: test 6 of Section 10 and the objection on silent failures in Section 9.5 change as the decisions file says. Read the block "Between the rock and the bet: batches" at the end of Section 7.4 in research/sections/shift-abstain.md and Section 7.4 of proofs/shift-abstain.md before you write. Ab5 is being checked by two referees while you work; state it with the hypotheses that the block has (a deterministic human, a known bound b on K, questions drawn independently from one law, inputs known as a batch in advance).',
      'new block A0 for Section 1, and BLOCK A rewritten for its new place as Section 3.7 (begin BLOCK A with the heading line "### 3.7 The assumptions in practice").',
    ],
  },
}

const EDIT_SCHEMA = {
  type: 'object',
  properties: {
    files: { type: 'array', items: { type: 'string' }, description: 'files written or changed' },
    summary: { type: 'string', description: 'what was done, what was checked and how, what was not checked' },
    decisions: {
      type: 'array',
      items: {
        type: 'object',
        properties: {
          report: { type: 'string', description: 'reader, math, consistency, references, second-check or ab5' },
          finding: { type: 'string', description: 'number or short name of the finding' },
          decision: { type: 'string', description: 'applied / applied in other words / already settled / rejected' },
          detail: { type: 'string', description: 'old and new sentence where text changed, or the reason' },
        },
        required: ['report', 'finding', 'decision', 'detail'],
      },
    },
    unchecked: { type: 'array', items: { type: 'string' }, description: 'statements or arguments that only you have seen' },
    for_lead: { type: 'array', items: { type: 'string' }, description: 'anything that concerns a file of the lead or of another editor, with exact old and new text' },
  },
  required: ['files', 'summary', 'decisions', 'unchecked', 'for_lead'],
}

const REPORT_SCHEMA = {
  type: 'object',
  properties: {
    report: { type: 'string' },
    summary: { type: 'string' },
    verdicts: {
      type: 'array',
      items: {
        type: 'object',
        properties: {
          id: { type: 'string' },
          verdict: { type: 'string', description: 'CORRECT / MINOR / GAP / WRONG' },
          note: { type: 'string' },
        },
        required: ['id', 'verdict', 'note'],
      },
    },
    findings: {
      type: 'array',
      items: {
        type: 'object',
        properties: {
          grade: { type: 'string' },
          where: { type: 'string' },
          finding: { type: 'string' },
          fix: { type: 'string' },
        },
        required: ['grade', 'where', 'finding', 'fix'],
      },
    },
  },
  required: ['report', 'summary', 'verdicts', 'findings'],
}

async function attempt(prompt, o) {
  try { return await agent(prompt, o) } catch (e) { log('agent error for ' + o.label + ': ' + String((e && e.message) || e)); return null }
}
// first = 'opus' runs the agent on Opus and falls back to the session model; first = null does the reverse.
async function run(prompt, o, first) {
  let r = await attempt(prompt, first ? { ...o, model: first } : o)
  if (!r) {
    log('retrying ' + o.label + ' on the other model')
    r = await attempt(prompt, first ? { ...o, label: o.label + ' [session model]' } : { ...o, label: o.label + ' [opus]', model: 'opus' })
  }
  return r
}

function editPrompt(key, extra) {
  const p = PARTS[key]
  return [
    COMMON,
    '',
    'YOUR TASK: you are the editor of the section source research/sections/' + key + '.md in the referee round.',
    'Five referees read the assembled note: verification/referee-reader.md (a cold reading for the researcher; its Parts D to I hold the findings with exact replacements, Part J lists them), verification/referee-math.md (the mathematics as printed), verification/referee-consistency.md, verification/referee-references.md (its Section 3 lists exact sentence replacements) and verification/reproduction.md. Before them, a second check of your part (verification/' + key + '-second.md) was applied by a fixer; what the fixer did is recorded in the section "Checking" of proofs/' + key + '.md.',
    'FIRST read research/orchestration/apply-notes.md in full. It is the lead\'s decision on the findings and is binding: who edits what, the general rules, the conventions for labels, letters and terms that hold for the whole note, and the decisions on single findings.',
    'Then read your section source, the note note.md around your sections to see the context, and the findings.',
    'Your sections: ' + p.where,
    'Findings that concern your file, as far as the lead has listed them (go through all four reports yourself as well and take every further finding that concerns your sections; line numbers in the reports refer to an older assembly, so find passages by their words):',
    p.items.map(s => '  - ' + s).join('\n'),
    extra || '',
    'WHAT TO DO. Decide every finding: apply it, apply it in other words, note that it is already settled, or reject it with a reason. Before you apply a replacement that a referee proposes, check it against the proof file; the reader marked with (*) those that restate his own reading. Apply the conventions of Section 3 of the decisions file to your whole section, not only where a finding points. Edit research/sections/' + key + '.md, and proofs/' + key + '.md where a correction requires it (mark such passages "(editor, referee round)" and add a short subsection "Referee round" to its section "Checking"). If your file has notes for the lead at its end (after a line that holds only three hyphens), keep them there and add yours.',
    'When you have finished, run from the project folder:  python3 research/orchestration/assemble.py  with the output redirected so that note.md is NOT overwritten:  copy research/ to a scratch directory under /tmp/claude-0/-home-user-AI-works/45ab58da-204e-5042-9d88-71bbd9750f58/scratchpad/ and run the script there, to confirm that the assembly still finds every marker and heading it needs in your file. Then read your sections once more in the scratch copy of the assembled note, as the researcher would read them cold.',
    'Return the structured result: the files you changed; a summary; one decision for each finding; the statements or arguments that only you have seen; and what concerns files of the lead or of other editors, with exact old and new text.',
  ].join('\n')
}

const AB5_TARGET = [
  'THE OBJECT. After the referees had read the note, the lead added a proposition, Ab5, in answer to finding F4 of verification/referee-reader.md. It is the counterpart, for a countable class with weights and any set of answers, of the algorithm "Rejectron" of Goldwasser, Kalai, Kalai and Montasser (2020, arXiv:2007.05145). Nobody but its author has seen it.',
  'It consists of: (1) Section 7.4 of proofs/shift-abstain.md: Setting 7.6, the rule Bat_eps, Theorem 7.6 with items 1 to 6 and its proof, Corollary 7.7, Remark 7.8, Example 7.9 (a), (b), (c), Remark 7.10; (2) Section 8.6 of the same file and the script proofs/code/shift-abstain_batch_rule.py with its saved output; (3) the rows for it in the table of Section 0.1, the item of Section 9 and the entries of Section 11 of that file; (4) in the note\'s source research/sections/shift-abstain.md, at the end of Section 7.4, the paragraph "Between the rock and the bet: batches", Proposition Ab5 with parts (a), (b), (c), its proof, the paragraph on the price and "What it does not say" (i) to (v).',
  'The digest research/understand/abstention-shift.md (Sections 5.1, 7.2, 9.1 to 9.3) reports the source and already has the count for programs of k bits and the test of item 6; its author read the paper in the source.',
].join('\n')

const AB5_CHECK = [
  COMMON,
  '',
  'YOUR TASK: referee the new proposition Ab5 line by line.',
  AB5_TARGET,
  'DO: (a) Check every statement and every step of every proof in Section 7.4 of the proof file; for each item of Theorem 7.6, for Corollary 7.7, each part of Example 7.9 and each part of Remarks 7.8 and 7.10 give a verdict CORRECT, MINOR (true, wording or a missing hypothesis), GAP (a step is missing; supply it if you can) or WRONG (give a counterexample). Check the hypotheses that each item really needs (P a probability law or a sub-probability; the batch chosen with knowledge of the data; the role of the order of H_b; eps = 1; eps*m an integer; gamma >= 1; conditional statements "given D on the event").',
  '(b) Write your own script, independent of the lead\'s, at verification/code/shift-abstain_ab5_check.py, and save its output next to it (.out): exhaustive or exact where possible (all classes of a few functions on a few inputs, all samples, all batches up to a small length, a grid of eps), simulation otherwise. Run the lead\'s script too and compare its output with the saved one.',
  '(c) Compare the note\'s text (the block in research/sections/shift-abstain.md) sentence by sentence with what the proof file proves: every bound, every hypothesis, the probabilities in (b) and (c), the sentence on the price, the comparison with enumeration (N7(b)) and with the frozen minimum rule (Ab2(d)), and each of (i) to (v).',
  '(d) Check the account of the source in Remark 7.8(i) and in the status line of Ab5 against the source itself: read arXiv:2007.05145 (the abstract page https://arxiv.org/abs/2007.05145 and the PDF or HTML of the paper; use your web tools, and if one host does not answer try https://arxiv.org/pdf/2007.05145 ). Confirm or correct: the setting (two values, VC dimension d, labelled examples from P, unlabelled test inputs), the algorithm, the numbers of the theorems cited (Theorem A.2, Theorems 5.2 to 5.5, Lemma 4.1), the bounds as quoted, and the lower bound. Say exactly what you read. If you cannot open the source, say so and check the account against the digest only.',
  'Write the report to verification/shift-abstain-ab5-check.md (state at its head who wrote the object and that you did not). For every finding give the exact old sentence and an exact replacement. Return the structured result.',
].join('\n')

const AB5_ATTACK = [
  COMMON,
  '',
  'YOUR TASK: try to break the new proposition Ab5. You are an adversarial reader; assume it is wrong somewhere and look for where.',
  AB5_TARGET,
  'ATTACK, at least: (a) each item of Theorem 7.6 by exhaustive search for counterexamples on tiny instances (every class of up to four functions on up to four inputs with two or three answers, every order of the class, every human in it, every sample, every batch up to length five or six, eps on a fine grid including 1, values with eps*m an integer and values below 1/m); (b) the probability statements: is the event of item 3 really of probability more than 1 - delta/2, also for a sub-probability P and when two members are the same function; is "an input drawn from P independently of the batch, given D" a correct reading; does item 4 hold when h itself depends on the questions; is the count "fewer than 2^b members" right in items 4 and 6; what exactly does item 6(b) promise when the first consistent member changes after the new answers; (c) Example 7.9: recompute every claim, including "at most one step" in (c) and the P-masses; find out whether a better rule for inputs that arrive one at a time exists in that example, and say so if the text suggests otherwise; (d) Remark 7.10(a): for a scaffold whose questions do not depend on the answers, are the asked calls of a rehearsal independent draws from one sub-probability, exactly as claimed (see Lemma 1.2 and Protocol R[r] in Section 1.3 of the proof file)? What if runs have different lengths? (e) Remark 7.10(b): is the count of wrong answers by stages right; (f) the note\'s block in research/sections/shift-abstain.md: every sentence, especially (b) "nothing is refused, with probability at least 1 - delta over the batch", (c), the price n = (2b ln 2 + ln(1/delta))/(eps*eps\'), "with eps*m < 1 the rule is enumeration", and (i) to (v); does any sentence say more than is proved, or suggest to the researcher more than the result gives (the refused set has small mass for a FRESH input; what about the inputs of the batch itself)? (g) the comparison with the rules of Sections 7.1 to 7.4: is "a price linear in b where enumeration needs up to 2^b - 1 answered abstentions and the frozen minimum rule a rehearsal of the order of 2^K rounds" a fair comparison? Is Ab5 consistent with Proposition N4, Proposition 7.5(0) and the table "Rocks and whitelists"?',
  'Write your own script at verification/code/shift-abstain_ab5_attack.py and save its output next to it (.out). Do not rely on the lead\'s script.',
  'Write the report to verification/shift-abstain-ab5-attack.md: findings graded FATAL / MAJOR / MINOR / WORDING, each with the exact sentence, what is wrong, a counterexample or computation, and an exact replacement; then a list of what you attacked and could not break; then what you did not look at. Return the structured result (use the field verdicts for the things you attacked and could not break or broke).',
].join('\n')

const AB5_EXTRA = [
  'IN ADDITION, the new proposition Ab5 (the block at the end of Section 7.4 of your file, and Section 7.4 of proofs/shift-abstain.md, written by the lead) has just been examined by two referees: verification/shift-abstain-ab5-check.md and verification/shift-abstain-ab5-attack.md. Read both reports, verify each finding yourself, and apply the accepted ones to the proof file and to the block in the section source. Complete Section 12.7 of the proof file: who checked Theorem 7.6 and how, each finding with the decision, and what remains seen by one person only. If a finding refutes a part of Ab5, correct the statement in both files so that only what is proved remains, and report it to the lead as the first item.',
].join('\n')

const mode = args && args.mode
let out

if (mode === 'edit') {
  phase('Edit')
  const results = await parallel(args.keys.map(k => () =>
    run(editPrompt(k, ''), { label: 'edit:' + k, phase: 'Edit', schema: EDIT_SCHEMA }, null)))
  out = { mode, parts: args.keys.map((k, i) => ({ key: k, edit: results[i] })) }
} else if (mode === 'ab5') {
  const chain = async () => {
    const reps = await parallel([
      () => run(AB5_CHECK, { label: 'ab5:check', phase: 'Check Ab5', schema: REPORT_SCHEMA }, 'opus'),
      () => run(AB5_ATTACK, { label: 'ab5:attack', phase: 'Check Ab5', schema: REPORT_SCHEMA }, 'opus'),
    ])
    const ed = await run(editPrompt('shift-abstain', AB5_EXTRA), { label: 'edit:shift-abstain', phase: 'Edit', schema: EDIT_SCHEMA }, null)
    return { check: reps[0], attack: reps[1], edit: ed }
  }
  const others = (args.keys || []).map(k => () =>
    run(editPrompt(k, ''), { label: 'edit:' + k, phase: 'Edit', schema: EDIT_SCHEMA }, null))
  const res = await parallel([chain, ...others])
  out = { mode, ab5: res[0], parts: (args.keys || []).map((k, i) => ({ key: k, edit: res[i + 1] })) }
} else {
  throw new Error('args.mode must be "edit" or "ab5"')
}
return out
