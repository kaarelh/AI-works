export const meta = {
  name: 'final-round',
  description: 'Second readers for the referee-round changes of the imitation note, a check of Theorem Ab6, and referees of the reassembled note',
  phases: [
    { title: 'Check Ab6', detail: 'a line-by-line check and an adversarial reading of the theorem on batches of tasks, then a fixer' },
    { title: 'Second readers', detail: 'one second reader per part for the changes of the referee round, each followed by a fixer' },
    { title: 'Whole note', detail: 'referees of the reassembled note' },
  ],
}

const ROOT = '/home/user/AI-works/principled-imitation'
const SCRATCH = '/tmp/claude-0/-home-user-AI-works/45ab58da-204e-5042-9d88-71bbd9750f58/scratchpad'

const COMMON = [
  'You work in the repository at /home/user/AI-works, in the project folder principled-imitation/ (absolute path ' + ROOT + ').',
  'The project is a research note, note.md, written for a researcher who asked for a human-imitation protocol with a theorem. The note is GENERATED from the section sources in research/sections/ by research/orchestration/assemble.py; full proofs are in proofs/ (one file per part, each ending with a section "Checking"); the reports of all checks are in verification/. research/outline.md has the plan, the notation and the style rules; research/orchestration/apply-notes.md has the conventions for labels, letters and terms that hold for the whole note. research/understand/ holds digests of the literature and of the researcher\'s notes.',
  'Rules: git may be used to READ (git diff, git show, git log); do not run git commands that change anything (no add, commit, push, checkout, stash). Do not edit note.md. Do not put the researcher\'s name, the repository\'s name or any text of the project into web queries. Scripts must finish within 10 minutes and use at most 4 GB. Write in plain words and full sentences; say exactly what you checked and what you did not.',
  'To see the note as it would be assembled now, copy research/sections and research/orchestration into a new directory under ' + SCRATCH + '/ (keeping the path research/...), and run  python3 research/orchestration/assemble.py  there; it writes note.md into that directory and leaves the project\'s note.md alone.',
].join('\n')

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

const FIX_SCHEMA = {
  type: 'object',
  properties: {
    files: { type: 'array', items: { type: 'string' } },
    summary: { type: 'string' },
    corrections: { type: 'array', items: { type: 'string' }, description: 'each finding with the decision and, where text changed, old and new' },
    unchecked: { type: 'array', items: { type: 'string' }, description: 'what only you have seen after this round' },
    for_lead: { type: 'array', items: { type: 'string' } },
  },
  required: ['files', 'summary', 'corrections', 'unchecked', 'for_lead'],
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

// ------------------------------------------------------------------ Ab6

const AB6_TARGET = [
  'THE OBJECT. After the referees had read the note, the lead added two statements on rules for batches. Proposition Ab5 (single inputs; Theorem 7.6 of proofs/shift-abstain.md) has been examined by two referees (verification/shift-abstain-ab5-check.md and -attack.md) and corrected. Theorem Ab6 is new and nobody but its author has seen it. It applies the same rule to whole runs of a rehearsed scaffold: a function answers a whole run in one way, so each member of the version space turns a task with the scaffold\'s coins into one run; the rule refuses the tasks on which some member that fits the answers makes a different run from the chosen member h on more than a fraction eps of the batch, and delivers the run of h on the others.',
  'It consists of: (1) Section 7.5 of proofs/shift-abstain.md: Setting 7.11, the rule RBat_eps, Theorem 7.11 with items 1 to 6 and its proof, Corollary 7.12, Remark 7.13; (2) Section 8.7 of the same file and the script proofs/code/shift-abstain_batch_runs.py with its saved output; (3) the rows for it in the table of Section 0.1 and the entry in Section 12.8 of that file; (4) in the note\'s source research/sections/shift-abstain.md, in Section 7.4 after Proposition Ab5, Theorem Ab6 with parts (a), (b), (c), its proof, the paragraph that begins "So after n = " and "What it does not say" (i) to (v).',
  'It rests on Theorem 7.6 of the same file (items 1, 2 and 4 and their proofs) and on Theorem 5.5(b) of proofs/one-mind.md (R6(b) of the note: with probability at least 1 - 2 delta every function g that fits the answers of a rehearsal driven by the mixture has an unfaithful run with probability below L(ln(1/w(g)) + K ln 2 + 2 ln(1/delta))/n). Both first-round verifiers of the part one-mind checked Theorem 5.5.',
].join('\n')

const AB6_CHECK = [
  COMMON,
  '',
  'YOUR TASK: referee the new Theorem Ab6 line by line.',
  AB6_TARGET,
  'DO: (a) Check every statement and every step of every proof in Section 7.5 of proofs/shift-abstain.md; give a verdict CORRECT, MINOR, GAP or WRONG for each item of Theorem 7.11, for Corollary 7.12 and for each part of Remark 7.13. Read Theorem 5.5 of proofs/one-mind.md with its proof and check that it is applied within its hypotheses (a class of functions, the mixture over H as driver, the version space of all members of H, the meaning of u(g), runs that may have different lengths, the scaffold\'s coins). In item 5(b) the proof re-runs the steps of that proof for further rounds whose pair (z, rho) is drawn from the batch and whose mixture starts from the posterior after D: check each step for that changed setting (the supermartingale of Step 1 started at the first further round; the martingale of Step 2 and the bound by the posterior weight of f; Step 3 for the new task law; the union over g with the prior weights).',
  '(b) Write your own script, independent of the lead\'s, at verification/code/shift-abstain_ab6_check.py, and save its output next to it (.out): exact where possible (enumerate every rehearsal history of a small instance to compute the probability of the event of item 3 and of item 5(b) exactly; every batch of pairs up to a small length for items 1 and 2), simulation otherwise. Use scaffolds whose questions depend on the answers and runs of different lengths. Run the lead\'s script too and compare its output with the saved one.',
  '(c) Compare the note\'s text (Theorem Ab6 in research/sections/shift-abstain.md) sentence by sentence with what the proof file proves: every bound and constant (gamma, 2 gamma/eps, 14.8 gamma, the number of further rounds), every probability, the paragraph on the price, and each of (i) to (v).',
  'Write the report to verification/shift-abstain-ab6-check.md (say at its head who wrote the object and that you did not). For every finding give the exact old sentence and an exact replacement. Return the structured result.',
].join('\n')

const AB6_ATTACK = [
  COMMON,
  '',
  'YOUR TASK: try to break the new Theorem Ab6. You are an adversarial reader; assume it is wrong somewhere and look for where.',
  AB6_TARGET,
  'ATTACK, at least: (a) item 1 by exhaustive search on tiny instances: every class of up to four functions, small scaffolds whose next question depends on the answers and whose runs have different lengths, every data set that a rehearsal can produce, every batch of pairs up to a small length (with repeated pairs), eps on a fine grid; is "every other delivered run is the run that the human system makes" exactly right; what if two members of the class are the same function, or make the same runs; what if the scaffold has no coins, or the batch repeats one pair; (b) item 3: is the event really of probability at least 1 - 2 delta, for the version space restricted to weight at least 2^(-b) while the mixture is over all of H; does "(D0 x lambda)(Delta(c)) <= u(c) + u(h)" hold; is the statement about a task "drawn independently of the batch" correctly limited (find how badly the tasks of a batch drawn from D0 can be refused when eps*r is small); (c) item 4: the binomial claim needs the pairs of the batch to be independent draws from D0 x lambda and independent of the rehearsal; is the count of members right; is "eps >= 2 e^2 gamma" what the proof uses; (d) item 5(b): simulate or enumerate a second rehearsal on the pairs of a batch and look for a violation; check the claim when the batch repeats pairs, and what "the first such member answers the whole batch" promises; (e) Corollary 7.12 and Remark 7.13, every sentence, especially (i) "holds for every batch of tasks, from any source, and with certainty", (ii) on batches of one task, (v) on the class of N2; (f) the note\'s text: does any sentence say more than is proved or suggest to the researcher more than the result gives? In particular "the tasks may come from anywhere", "No further question is needed as long as the test passes", "the delivered runs are those of one program", and the comparison with R1; is the result consistent with the lower bounds of the note (Theorem N2 and Theorem 4.5 of proofs/shift-abstain.md on the class of N2 with abstention; Proposition N4; N1)? Compute, on the class of N2, what the rule does and whether the stated price contradicts or trivially undercuts those bounds. (g) Is there a hidden assumption about what the rule knows (the bound b, the task law, the scaffold\'s coins being fixed before any run is delivered)?',
  'Write your own script at verification/code/shift-abstain_ab6_attack.py and save its output next to it (.out). Do not rely on the lead\'s script.',
  'Write the report to verification/shift-abstain-ab6-attack.md: findings graded FATAL / MAJOR / MINOR / WORDING, each with the exact sentence, what is wrong, a counterexample or computation, and an exact replacement; then what you attacked and could not break; then what you did not look at. Return the structured result (use the field verdicts for what you attacked).',
].join('\n')

const AB6_FIX = [
  COMMON,
  '',
  'YOUR TASK: you are the editor who decides the findings of two reports on the new Theorem Ab6.',
  AB6_TARGET,
  'The reports are verification/shift-abstain-ab6-check.md and verification/shift-abstain-ab6-attack.md. Read both in full. Verify each finding yourself (by hand; by a script in proofs/code/ where it has numbers) and decide it: accepted, accepted in other words, or rejected with a reason. Apply the accepted corrections to proofs/shift-abstain.md (Section 7.5, Section 8.7, the table of Section 0.1) and to the Ab6 text in research/sections/shift-abstain.md. If a finding refutes a part of the theorem, correct the statement in both files so that only what is proved remains, and report it to the lead as the first item. Complete Section 12.8 of the proof file: who checked Theorem 7.11 and how, each finding with the decision, and what remains seen by one person only. Do not edit other files; report what concerns Section 0 (research/sections/intro.md) or other sections to the lead with exact old and new text.',
  'Return the structured result.',
].join('\n')

// ------------------------------------------------------------------ second readers of the referee round

const PART_WHERE = {
  'rehearsal-core': 'Sections 1, 2, 3.1, 3.3, 3.4, 3.5 and 3.6 of the note',
  'hellinger-runs': 'Section 3.2 and Section 5.2 of the note',
  'lower-bounds': 'Section 4 of the note, and in Section 6.1 the block with Theorem N3 and Proposition S2',
  'one-mind': 'Section 5 of the note up to the end of Section 5.1',
  'shift-abstain': 'Sections 6 and 7 of the note without the block of Section 6.1 that holds Theorem N3 and Proposition S2; Proposition Ab5 and Theorem Ab6 at the end of Section 7.4 have their own referees, so read them only for consistency with the rest',
  'property-batch': 'the opening of Section 8 and Sections 8.1, 8.2, 8.3, 8.6 and 8.7 of the note (in the file the last three carry the headings 8.2a, 8.5 and 8.6)',
  'property-online': 'Sections 8.4 and 8.5 of the note',
  'assumptions': 'the last paragraph of Section 1 (block A0), Section 3.7 (block A), Section 9 (block B) and Section 10 (block C) of the note',
}

function recheckPrompt(key) {
  return [
    COMMON,
    '',
    'YOUR TASK: you are the second reader of what the editor of part "' + key + '" changed in the referee round. Five referees had read the assembled note; the editor of each part then decided their findings and rewrote the section source research/sections/' + key + '.md (' + PART_WHERE[key] + '), and in places the proof file proofs/' + key + '.md. The text grew a good deal, and nobody but that editor has read the new text.',
    'READ FIRST: research/orchestration/apply-notes.md (the lead\'s decisions; Section 3 has the conventions); the subsection "Referee round" in the section "Checking" of proofs/' + key + '.md (the editor\'s record of every decision); and the part "' + key + '" of research/orchestration/unchecked-referee-round.md (what the editor says only the editor has seen).',
    'GET THE CHANGES with  git diff ca30e760 -- principled-imitation/research/sections/' + key + '.md principled-imitation/proofs/' + key + '.md  (run from /home/user/AI-works; ca30e760 is the state before the referee round), and read the new section text in full.',
    'CHECK: (1) every changed or added sentence of the section source that states mathematics: a statement, a hypothesis, a bound, a constant, a number, a printed proof or idea of a proof. Compare it with the proof file, re-derive it by hand, and test it numerically where it has numbers (your own script at verification/code/' + key + '_referee_round_check.py with its saved .out). A printed proof must prove the statement as printed. (2) Every item of the unchecked list of this part, line by line. (3) Run the editor\'s new script(s) in proofs/code/ (names containing "referee") in a scratch copy and compare the output with the saved one. (4) Whether the conventions of the decisions file are applied in these sections: labels, letters, terms defined at first use, "What it does not say.", the order of K for a person, the places that must say that a bound is empty for a person. (5) Pointers: assemble the note in a scratch directory and check that every "Section x.y", every label and every numbered statement of a proof file that these sections cite exists and says what the citing sentence says. (6) Attributions to the literature and to the researcher\'s notes that the editor added or changed: compare with references.md and with the digests; open a source only if it is on arxiv.org or proceedings.mlr.press and a sentence depends on it. (7) Length: name passages that no finding required and that could go back to a pointer to the proof file without loss for the reader; do not ask for cuts of definitions, hypotheses or "What it does not say."',
    'Write the report to verification/' + key + '-referee-round.md: a verdict (CORRECT / MINOR / GAP / WRONG) for each statement or passage examined; then the findings, each with the exact old sentence and an exact replacement; then what you did not check. Return the structured result.',
  ].join('\n')
}

function refixPrompt(key) {
  return [
    COMMON,
    '',
    'YOUR TASK: you are the editor who decides the findings of the second reader on the referee-round changes of part "' + key + '" (' + PART_WHERE[key] + ').',
    'The report is verification/' + key + '-referee-round.md. Read it in full, and read research/orchestration/apply-notes.md (binding conventions). Verify each finding yourself and decide it: accepted, accepted in other words, or rejected with a reason. Apply the accepted corrections to research/sections/' + key + '.md and, where a correction requires it, to proofs/' + key + '.md (mark such passages "(editor, referee round)"). Record the decisions at the end of the subsection "Referee round" of the section "Checking" of the proof file, under a heading "Second reader". For findings on length, cut or move to the proof file only what the second reader names and you agree is not needed by the reader of the note; keep definitions, hypotheses and limits.',
    'Do not edit other files. When you have finished, assemble the note in a scratch directory and confirm that the assembly succeeds and that your sections read correctly. Return the structured result; put under for_lead whatever concerns other files, with exact old and new text.',
  ].join('\n')
}

// ------------------------------------------------------------------ referees of the whole note

const WHOLE = {
  section0: {
    first: 'opus',
    prompt: [
      'YOUR TASK: check the lead\'s own sections of the reassembled note against the rest. The lead wrote Section 0 (research/sections/intro.md), Section 11 (toy.md), Section 12 (related-work-final.md), Section 13 (open.md), the list of references (references-short.md, with the fuller references.md in the project folder) and README.md; nobody else has read their present text.',
      'Assemble the note in a scratch directory and read all of it once. Then: (1) Section 0, sentence by sentence: for every claim find the statement in Sections 1 to 10 that it summarises and compare hypotheses, quantifiers, constants, probabilities and labels; a summary may leave out detail but must not say more than the statement, and must name the hypothesis that carries the result (deterministic human, known bound, batch known in advance, and so on). Check the arithmetic of every number in Section 0 with a script (verification/code/final-section0_checks.py, output saved). (2) Section 11: every number against results/*.out and the scripts in code/; every bound quoted against the statement it cites. (3) Section 12: every sentence that says what a statement of the note is or adds, against that statement as it now stands; labels and letters. (4) Section 13: every open question against the sections (is it still open as stated; are the quoted bounds right). (5) The list of references: with a script, extract every citation of the form "Author (year)" or "Author year" from the assembled note and check that it has an entry in the list, and that every entry is cited somewhere. (6) README.md: every sentence of "Answers in brief" against Section 0; the layout table against the folder.',
      'Write the report to verification/final-section0.md, with a verdict per item examined and findings with the exact old sentence and an exact replacement. Return the structured result.',
    ].join('\n'),
  },
  consistency2: {
    first: 'opus',
    prompt: [
      'YOUR TASK: consistency of the reassembled note. Assemble the note in a scratch directory and read all of it. With a script (verification/code/final-consistency_checks.py, output saved) and by reading: (1) every "Section x.y" that the text cites exists and holds what the citing sentence says; (2) every label (R1 to R7, L4, V1, N1 to N8 with their letters, S1 to S5, Ab1 to Ab6, Pr1 to Pr7, H1, H2, I1, E1, E2) is stated exactly once with a status (proved here / standard / open) and every citation of a label or of a part "(b)" matches a statement or part that exists; (3) every pointer of the form "proofs/FILE.md, Theorem/Proposition/Lemma/Corollary/Remark/Example N" resolves to a statement of that file with that number, and for each one read the title and first lines to see that it is the statement meant; (4) the conventions of research/orchestration/apply-notes.md, Section 3, hold in every section: letters (r and s_P in V1, H^2_j in L4, gamma in I1, lambda and kappa in 8.4 and 8.5, K_nu in 8.3, X0 for a region of inputs, Qu in N7 and Ab4, p_s and p_a in Ab4, G in Ab2(d)), terms, "What it does not say.", "Idea." and "Proof."; (5) the same quantity has the same value everywhere: the constants of R1, R2, R3, R6, N2, N2b, N6, N8, S5, Ab1, Ab5, Ab6, Pr5, Pr6, the budget numbers, the order of K for a person; (6) a term or symbol used before it is defined, reading from the top; (7) statements that contradict each other between sections.',
      'Write the report to verification/final-consistency.md: findings with the exact old sentence, the section source file that holds it, and an exact replacement; then what you checked and found in order; then what you did not check. Return the structured result.',
    ].join('\n'),
  },
  reader2: {
    first: null,
    prompt: [
      'YOUR TASK: read the reassembled note as the researcher for whom it is written, and judge whether the six major findings of the first cold reading are answered. Read verification/referee-reader.md first (Parts B, C, D, G and H: what he asked for, the six major findings F1 to F6, the bottom line, the seven tests), and the digest research/understand/notes.md (summary and Sections 3, 5 and 6) for what he accepts and rejects. Then assemble the note in a scratch directory and read Section 0 cold, then Sections 1 to 3.1, 3.7, 7, 9 and 10 in full, and the other sections as far as needed.',
      'ANSWER: (1) For each of F1 to F6: is it resolved, and does the new text introduce a new overclaim or a new gap? (2) The table of Part C of the first report (the eight things he asked for): fill it in again for the new Section 0. (3) Two statements were added after the first reading: Proposition Ab5 and Theorem Ab6 at the end of Section 7.4 (rules for batches that are silently wrong at a small rate). Are they presented with their limits, in Section 0, Section 7.4, Section 9.5 and test 6 of Section 10? Would he read more into them than they give (a rate over a batch; a deterministic human; a known bound on K; the batch known in advance and large; empty for a person)? (4) Is the bottom line stated plainly and early? (5) The note has about doubled in length. Where does the length hurt? Name passages that he would skip and that could go back to the proof files, and passages that are still too compressed to read cold. (6) Any term or symbol in Section 0 or in Sections 7, 9, 10 that is used before it is defined. (7) The verdicts of the seven tests: are they justified by what the note proves, and would he accept them?',
      'Write the report to verification/final-reader.md, with findings graded MAJOR / MINOR / WORDING, each with the exact sentence, the section source that holds it and an exact replacement. Return the structured result.',
    ].join('\n'),
  },
  reproduce2: {
    first: 'opus',
    prompt: [
      'YOUR TASK: re-run the scripts that were written after the re-run recorded in verification/reproduction.md (16 November). Find them with  git diff --name-status e0546722 -- principled-imitation/proofs/code principled-imitation/verification/code principled-imitation/code  (run from /home/user/AI-works) and by comparing the folders with the list in that report. Copy the project folder to a scratch directory, run every such script there with a limit of 10 minutes and 4 GB each (at most two at once), and compare the output byte for byte with the saved .out file; where only printed run times differ, say so. Also re-run code/toy.py 60, code/toy_stakes.py 40 and code/toy_property.py and compare with results/*.out, and check every number of Section 11 of the note (assemble it in the scratch copy) against those outputs. Do not edit any script or saved output.',
      'Write the report to verification/reproduction-2.md: one line per script (identical / differs only in run times / differs, with the difference / failed, with the reason / over the limit), and the numbers of the note that you compared. Return the structured result (verdicts: one per script).',
    ].join('\n'),
  },
}

const mode = args && args.mode
let out

if (mode === 'ab6') {
  const reps = await parallel([
    () => run(AB6_CHECK, { label: 'ab6:check', phase: 'Check Ab6', schema: REPORT_SCHEMA }, 'opus'),
    () => run(AB6_ATTACK, { label: 'ab6:attack', phase: 'Check Ab6', schema: REPORT_SCHEMA }, 'opus'),
  ])
  const fix = await run(AB6_FIX, { label: 'ab6:fix', phase: 'Check Ab6', schema: FIX_SCHEMA }, null)
  let after = null
  if (args.then_recheck) {
    const rc = await run(recheckPrompt('shift-abstain'), { label: 'recheck:shift-abstain', phase: 'Second readers', schema: REPORT_SCHEMA }, 'opus')
    const rf = rc ? await run(refixPrompt('shift-abstain'), { label: 'refix:shift-abstain', phase: 'Second readers', schema: FIX_SCHEMA }, null) : null
    after = { key: 'shift-abstain', check: rc, fix: rf }
  }
  out = { mode, check: reps[0], attack: reps[1], fix, after }
} else if (mode === 'recheck') {
  const results = await pipeline(
    args.keys,
    k => run(recheckPrompt(k), { label: 'recheck:' + k, phase: 'Second readers', schema: REPORT_SCHEMA }, 'opus'),
    (rep, k) => rep ? run(refixPrompt(k), { label: 'refix:' + k, phase: 'Second readers', schema: FIX_SCHEMA }, null).then(fix => ({ key: k, check: rep, fix })) : { key: k, check: null, fix: null },
  )
  out = { mode, parts: results }
} else if (mode === 'whole') {
  const results = await parallel(args.names.map(nm => () =>
    run(COMMON + '\n\n' + WHOLE[nm].prompt, { label: 'whole:' + nm, phase: 'Whole note', schema: REPORT_SCHEMA }, WHOLE[nm].first)))
  out = { mode, referees: args.names.map((nm, i) => ({ name: nm, result: results[i] })) }
} else {
  throw new Error('args.mode must be "ab6", "recheck" or "whole"')
}
return out
