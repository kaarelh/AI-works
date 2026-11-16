export const meta = {
  name: 'imitation-review',
  description: 'Review of the assembled imitation note: a second check of each part with fixes, or the referees of the whole note',
  phases: [
    { title: 'Second check', detail: 'per part: statements that no independent verifier has seen, and the note text against the proofs' },
    { title: 'Fix', detail: 'per part: decide the findings and correct the proof file and the section source' },
    { title: 'Referee', detail: 'whole note: reader, consistency, mathematics, references, reproduction' },
  ],
}

const ROOT = '/home/user/AI-works/principled-imitation'

const CONTEXT = `PROJECT. Repository /home/user/AI-works, project folder principled-imitation/ (all paths below are under ${ROOT}/).

A researcher asked for a human-imitation protocol with a theorem. In his words, he wants a protocol 'that does not do something insane but just really works (modulo having very much compute, but not modulo keeping the human in the loop producing data forever)', ideally with 'some theorem that convinces us it really works'. His model: a human is a probabilistic program P that maps an input string x to a random answer y; from a reasonable number of question-answer pairs one wants a sampler P' with broadly similar behaviour, in particular under distribution shift (for instance the shift produced by task decomposition, where the imitator's inputs are written by other imitator calls); or at least a P' that 'basically only fails obviously', without having to keep querying the human; ideally P' is 'more like a mind upload' and less like 'a weird clever guy' who thinks about what the human might think but also about the state of the world. He hoped that 'some property idea' (the imitator keeps the properties the data had) could give this, felt that Solomonoff induction on question-answer pairs 'isn't quite good enough', and suggested that task decomposition with re-querying the human with some probability on the deployment distribution induced by the decomposition might work. He asked: can a scheme be made to work, with a property idea or in some other way?

THE DELIVERABLE AND ITS FILES.
- note.md : the note, about 20,000 words, Sections 0 to 13. It is GENERATED: research/orchestration/assemble.py builds it from the section sources research/sections/*.md (intro.md = Section 0; rehearsal-core.md = Sections 1-3; hellinger-runs.md = Section 3.2 and 5.2; lower-bounds.md = Section 4 and a block of Section 6; one-mind.md = Section 5.1; shift-abstain.md = Sections 6-7; property-batch.md = Sections 8.1-8.3, 8.6, 8.7; property-online.md = Sections 8.4, 8.5; assumptions.md = the caveats in Section 1 and Sections 9-10; toy.md = Section 11; related-work.md = Section 12; open.md = Section 13) and applies the exact replacements in research/orchestration/patches.py. NEVER EDIT note.md. Whoever is told to change the note's text edits the section source.
- proofs/KEY.md for the eight parts KEY = rehearsal-core, hellinger-runs, lower-bounds, one-mind, shift-abstain, property-batch, property-online, assumptions: the full proofs. Each was written by a prover, examined by a line-by-line referee (verification/KEY-check.md) and an adversary (verification/KEY-attack.md), and then corrected by an editor, who also wrote the section source. The last section of each proof file ('Checking') lists every finding and the decision, and says which statements only one checker, or only the editor, has seen. Scripts and saved outputs: proofs/code/KEY_*.
- verification/ : the reports. code/ and results/ : three toy computations of Section 11.
- research/outline.md : outline, fixed notation, style rules and three addenda (assembly; attributions; the lead's decisions with letters and labels). Binding for the note's text. research/literature-checks.md : what the lead verified in one key source. research/understand/*.md : long background digests (notes.md digests the researcher's own notes; its Section 5 lists seven tests he applies to any proposal). The verification reports were written against the provers' drafts in research/prove*/ ; statement numbers mostly agree with proofs/KEY.md.

GENERAL RULES. Do not commit. Do not delegate to subagents. Write your output file in pieces as you go, so that nothing is lost if you are interrupted. Report what you verified and how; a statement you did not check is reported as not checked, never as correct. When you rely on the literature, say whether you read the source in this session. You may search the web for the literature; do not put the researcher's name, the repository's name or text of the project into web queries. Write plainly and precisely, in full sentences. Your final message is read by a program: return the structured result asked for.
`

const SECOND_RULES = `YOUR ROLE: SECOND CHECKER OF ONE PART. The part named below has been through prover, two verifiers and an editor. The editor changed the proofs after the verifiers had finished, and some statements were written by one verifier or by the editor and have been seen by nobody else. You are the independent reader of exactly those, and of the note's text for this part.
1. Open proofs/KEY.md and read its 'Checking' section and summary table. List every statement that (a) the note's text for this part uses or mentions, and (b) is marked as seen only by its author, only by the editor, or by one checker besides its author; add every statement the editor says was written or changed after verification. Check each of these line by line, as a referee: recompute constants, check hypotheses and edge cases, and where it is cheap test it numerically with a script of your own (verification/code/KEY_second_*.py, with saved output). Verdict for each: CORRECT; MINOR (give the exact fix); GAP (say which step, fill it if you can); WRONG (failing step, counterexample if you can, strongest true replacement).
2. Then read the sections of note.md that belong to this part, statement by statement, against proofs/KEY.md: does the proof file contain the statement, with the same hypotheses, constants and quantifiers? Does each pointer ('Theorem x.y', 'Proposition x.y') exist and say that? Does the status given in the note (proved here, standard with source, open, not independently checked) agree with the proof file's 'Checking' section? Does any sentence of prose claim more than the statement proved? Use the letters and labels of research/outline.md, Addendum 3.
3. Do not edit note.md, the section sources or the proof file. Report.
OUTPUT: verification/KEY-second.md : first the list of statements you examined under item 1 with verdicts and reasons; then the findings on the note's text, each with the exact sentence and the exact replacement you propose; then what you did not check.
RETURN: the path of the report, a summary of at most 250 words, and the list of verdicts (id, verdict, note).
`

const FIX_RULES = `YOUR ROLE: EDITOR OF ONE PART, SECOND ROUND. A second checker has examined the statements of your part that no independent verifier had seen, and compared the note's text with the proof file. Read verification/KEY-second.md. Decide every finding: verify it yourself, then accept and fix it, or reject it with the reason.
1. Apply accepted corrections to proofs/KEY.md in place with the Edit tool (do not retype the file), and add to its 'Checking' section a subsection 'Second check' with a table of the findings and decisions, and an updated statement of who has checked what. A statement that the second checker verified now counts as independently checked: remove marks such as 'not independently checked' for it, in the proof file and in the section source. A statement found wrong is corrected or removed, in both places.
2. Apply accepted corrections of the note's text to the SECTION SOURCE of your part in research/sections/ (never to note.md). Keep the text within its length; change only what a finding requires. If a sentence you need to change belongs to another part's section source, do not edit it: list it under 'for the lead' in your return value with the exact old and new sentence.
3. If research/orchestration/patches.py contains a replacement whose old text you changed, say so in your return value (the lead will update it); do not edit that file.
RETURN: the paths of the files you changed, a summary of at most 200 words, the list of corrections made, and the list of points left for the lead.
`

const PARTS = {
  'rehearsal-core': 'PART rehearsal-core. Proof file proofs/rehearsal-core.md. In the note: Sections 1, 2, 3.1, 3.3, 3.4, 3.5, 3.6 (source research/sections/rehearsal-core.md; Section 3.2 belongs to part hellinger-runs; the paragraph of caveats in Section 1 belongs to part assumptions; the paragraph "Compute" in Section 2 was added by the lead through patches.py: check it too, as a statement about rejection sampling from the posterior).',
  'hellinger-runs': 'PART hellinger-runs. Proof file proofs/hellinger-runs.md. In the note: Section 3.2 (Lemma L4, Theorem R2, the necessity of the factor L) and Section 5.2 (H1, the failure of the per-call mixture, H2, the failure at lambda = 1). Source research/sections/hellinger-runs.md. Give special attention to Lemma 2.10 and Corollary 2.11 of the proof file (found by one verifier, seen otherwise only by the editor), on which the final constants of R2 rest, and to Theorem 5.7.',
  'lower-bounds': 'PART lower-bounds. Proof file proofs/lower-bounds.md. In the note: Section 4 (N1, N2, N2a, N2b, N2c, N5, N6, N2d) and, inside Section 6.1, the paragraphs "Theorem N3" and "What S2 needs". Source research/sections/lower-bounds.md. Give special attention to Propositions 3.7, 3.8, 3.9, 3.10, 4.6, 5.6, 5.7, 7.2 and Remark 1.11 of the proof file (each seen by one checker or by the editor only), and to the restated Theorem 3.3 (Protocol AB).',
  'one-mind': 'PART one-mind. Proof file proofs/one-mind.md. In the note: Section 5.1 (R4, R5, R6 with parts (a), (b), (c), the table). Source research/sections/one-mind.md. Give special attention to Theorem 3.8 with Remark 3.9 (R6(c) in the note; proved by the editor, seen by nobody else), Proposition 3.5, Example 3.6, Proposition 4.6, the restated Corollary 4.4(b),(c) and Proposition 5.7.',
  'shift-abstain': 'PART shift-abstain. Proof file proofs/shift-abstain.md. In the note: Sections 6 and 7 except the paragraphs "Theorem N3" and "What S2 needs" (source research/sections/shift-abstain.md). Give special attention to the restated Corollary 3.6 (N7), Example 4.5a, the rewritten Theorem 5.3(b), Proposition 6.2(4), and the two tables of Section 7.4 of the note (every cell against a statement of the proof file).',
  'property-batch': 'PART property-batch. Proof file proofs/property-batch.md. In the note: Sections 8.1, 8.2, 8.3, 8.6, 8.7 (source research/sections/property-batch.md, where the last three are still numbered 8.2a, 8.5, 8.6; the assembly renumbers them). Give special attention to Lemma 2.8, Theorem 4.11 part (B), Remark 4.14, Propositions 4.15, 5.4, 6.4, 6.5 and Theorem 6.6 (Pr7(b) in the note; the editor\'s own), and to the standard facts of Remark 4.4 (C_R = 2^(K(R)+c) for the class of all programs), which no file proves: prove them or say exactly what remains assumed.',
  'property-online': 'PART property-online. Proof file proofs/property-online.md. In the note: Sections 8.4 and 8.5 (source research/sections/property-online.md, where they are numbered 8.3 and 8.4; the assembly renumbers them). Give special attention to Example 2.5, Propositions 3.9, 3.10 and 6.7, the new proof of Proposition 2.4 and the repaired Proposition 6.6 (all written by the editor after verification), and re-derive Theorem 3.3 (Rule NH) and Theorem 6.2 once more yourself.',
  'assumptions': 'PART assumptions. Proof file proofs/assumptions.md. In the note: the paragraph "Caveats on the assumptions" in Section 1, Section 9 (the budget table, N8, I1, E1, E2, copy or predictor, the objections, what survives) and Section 10 (the seven tests). Source research/sections/assumptions.md. Give special attention to Proposition 6.4, Example 3.3a, Remark 3.2a, Proposition 1.9a (each seen by one checker and the editor), to every number of Section 9.1, and to the verdicts of Section 10 and the paragraph "What survives": each sentence must follow from statements of the note with their hypotheses and quantifiers.',
}

const REFEREES = {
  reader: {
    first: null,
    out: 'verification/referee-reader.md',
    prompt: `YOUR ROLE: REFEREE, AS THE READER FOR WHOM THE NOTE IS WRITTEN. You are the researcher described above: mathematically trained, at home with Solomonoff induction and regret bounds, not with the imitation-learning literature, sceptical, and reading the note cold. Read note.md from the first line to the last, once, in order, without opening any other file first. Then read research/understand/notes.md, Sections 3, 5 and 6 (what he calls insane; his seven tests; his own observations), and re-read Sections 0, 9 and 10 of the note.
Report, with the exact sentence for each finding and a proposed replacement where you can:
(1) Does Section 0 answer his question, in his terms? Is anything he asked for left without an answer (a scheme that works; a theorem; distribution shift; failing only obviously; mind upload against clever predictor; the property idea; why Solomonoff induction is not enough; the re-querying idea)? Is any answer there stronger or weaker than what the sections state?
(2) Overclaims: every sentence that says more than the stated theorem, hides a hypothesis, or presents a standard result as the note's own. Underclaims: results buried where he would want them stated up front.
(3) Clarity: every symbol or coined term used before it is defined, every passage you had to read twice, every proof idea that does not convey the idea, every table whose cells are unclear. The note must be readable without the proof files.
(4) Whether the honest bottom line is stated plainly and early enough: where the theorems are empty (K for a person), what is merely standard, what remains a bet.
(5) His seven tests: is each verdict in Section 10 justified by what the note proves? Would he accept it?
(6) Style rules of research/outline.md (lead with the result; plain words; full sentences; no decoration; hedge once): the worst violations.
Grade each finding MAJOR (misleads the reader or leaves his question unanswered), MINOR or WORDING.`,
  },
  math: {
    first: null,
    out: 'verification/referee-math.md',
    prompt: `YOUR ROLE: REFEREE OF THE MATHEMATICS OF THE NOTE AS PRINTED. Work from note.md alone at first; open a proof file only to settle a doubt.
(1) For every statement whose proof or proof idea is printed in the note (R1, R7, R3, V1, N1, N2, Ab1, Ab3, Pr3, Pr6 and the others), check the printed argument line by line: is it a proof of the statement as printed, with the printed hypotheses and constants?
(2) Consistency between sections: collect every pair of an upper bound and a lower bound for the same quantity (for example R1 against N2 and N2b; R3 against N5 and N8; R2 against N6; Pr5(i),(ii) against their lower bounds; Ab1 against the rows of the table in 7.4; S5 against N7; H1 against N6) and verify with a short script, at several parameter values in the stated ranges, that no lower bound exceeds the matching upper bound. Check likewise every sentence of the form 'within a factor c of' and every worked number in the text (for example the figures in Section 9.1, in the paragraph after R1, in 3.5, in 4.6 and in Section 11) by recomputing it. Put the script in verification/code/referee-math_checks.py and save its output.
(3) Edge cases of the statements as printed: L = 1, n = 1, K = 0 or K < 1, delta at the ends of its range, runs with no call, a human with one possible answer.
(4) Definitions: is every object in a statement defined in the note (unfaithful call, tolerates k faults, closed deployment, test, book, top set, sep, visit measure, and so on), and used in the sense defined?
For each finding give the exact sentence, what is wrong, and the exact correction. Grade: WRONG (a false statement as printed), GAP, MINOR, WORDING. List what you did not check.`,
  },
  consistency: {
    first: 'opus',
    out: 'verification/referee-consistency.md',
    prompt: `YOUR ROLE: REFEREE FOR CONSISTENCY. A mechanical and complete pass over note.md.
(1) Labels. List every label of a statement (R1, R2, R3, R3a, R4, R5, R6, R7, V1, L4, N1 ... N8 with N2a-N2d, H1, H2, S1, S3, S4, S5, Ab1 ... Ab4, Pr1 ... Pr7, E1, E2, I1, A1-A3) with the section where it is stated. Report every label that is used but never stated, stated twice, stated under two different meanings, or cited with the wrong section. S2 and Pr2 are stated as paragraphs: check that every citation of them fits.
(2) Cross-references. Every 'Section x.y' in the text: does that section exist and contain what the sentence says? Every pointer of the form 'proofs/KEY.md, Theorem/Proposition/Lemma/Example/Corollary/Remark x.y' or a bare number after 'Numbers refer to proofs/KEY.md': does that numbered statement exist in that file and is it about that subject? (Write a script that extracts the pointers and checks that the numbers exist as headings or bold statement titles in the proof file; then check the subject by reading. Script and output in verification/code/referee-consistency_*.)
(3) The same quantity everywhere. For each main bound (R1, R2 in total variation, R3 in both forms, R4, R6(b), R7, V1(a), N2, N2b, N5, N6, N7, N8, Pr5(i),(ii), Pr6, H1, H2, I1, E1, the figures 1443 bits and 0.72 bits) list every place in the note where it is quoted, including Section 0, the tables, Sections 9, 10, 11, 12 and 13, and report every place where constant, hypothesis or quantifier differs from the statement.
(4) Letters. research/outline.md, Addendum 3, fixes letters (k tolerated faults, m validation rounds, ell bits of a shift, eta threshold, alpha plausible-set parameter, Lambda(B), delta, theta, epsilon). Report every clash inside one section and every use against the list that could mislead.
(5) Section 11 against results/toy.out, results/toy_stakes.out and results/toy_property.out: every number.
(6) Leftovers: text that is visibly an editor's note, a placeholder, a word-count remark, a reference to 'the lead', 'the candidate theory', 'the draft', 'the prover' or to files under research/ that a reader of the published note will not have.
For each finding give the line or sentence and the exact correction.`,
  },
  references: {
    first: null,
    out: 'verification/referee-references.md',
    prompt: `YOUR ROLE: EDITOR OF SECTION 12 AND OF THE REFERENCES. The note cites the literature in every section. research/sections/related-work.md is an earlier draft of Section 12 with a reference list that records, for each entry, how its bibliographic data and the statement used were checked; it predates the final sections: it uses old labels (Theorem A and B are now H1 and H2), old constants (the subadditivity constant is now 4 and 2.9642, with an example at 2.9639; R2 is now E TV <= sqrt(2 L K ln 2 / n)) and lacks attributions found since. The section sources research/sections/*.md end with editors' notes that list further references with how each was read; the proof files have literature sections (usually near the end) with the same; research/literature-checks.md has the lead's check of Li and Zhang.
Produce three files.
1. research/sections/related-work-final.md : Section 12 of the note, starting with the line '## 12. Related work', at most 1500 words. Revise the draft: bring every label, constant and claim in line with the final note.md (read Sections 2 to 8 of note.md for what they now attribute to whom, and make Section 12 agree with them and add what a reader needs to place the note: for instance that the core of N2 is the star-number bound of active learning, that Protocol AB is the membership-query algorithm of Hegedus and Moshkov, that H1 is the progressive mixture rule, that H2 and R6(c) are in the line of Barron and Cover and of Zhang, that R6(a) is the gap between a consistent learner and the halving algorithm, that Pr5 uses potentials of expert algorithms without a learning rate, that S5 is label-efficient prediction). Every claim about a cited work says what that work proves. Say plainly what in the note is standard and what, to the authors' knowledge, was not found in the literature ('we did not find', never 'new').
2. references.md (in the project folder): the full list of every work cited anywhere in note.md (extract the citations of all sections; nothing cited may be missing, nothing uncited included except sources of restatements, marked as such), alphabetical, each with full bibliographic data and one or two sentences on provenance in the style of the draft list: how the bibliographic data were checked and where the statement used was read (in the source, by whom among prover, verifiers, editor, lead; or through which secondary source; or from memory). Take provenance from the files named above; do not upgrade it. Where two files disagree about an entry, check the entry on the web and record what you found. For entries marked not verified, try to verify the bibliographic data on the web (title, authors, venue, year, pages or arXiv number) and record the result. The repository's own earlier papers are cited as 'Paper 1' and 'Paper 2' (solomonoff-operator-induction/paper and paper-steeper) and the companion note ultranatural/note.md: give them entries.
3. research/sections/references-short.md : the reference list as it stands in the note, starting with the line '## References', one line per work (authors, year, title, venue or arXiv number), alphabetical, preceded by one sentence saying that references.md records for each entry how it was checked and where the statement used was read.
Also write verification/referee-references.md : every citation in note.md that you could not match to a verified source, every attribution in the note that the provenance does not support, every disagreement you found, and every sentence in Sections 0 to 11 or 13 of the note whose citation should change (exact sentence and replacement; do not edit those sections).`,
  },
  reproduce: {
    first: 'opus',
    out: 'verification/reproduction.md',
    prompt: `YOUR ROLE: REPRODUCTION. (1) Run the three toy scripts as their docstrings say (code/toy.py with 60 trials; code/toy_stakes.py; code/toy_property.py), writing outputs to a scratch directory, and compare with results/toy.out, results/toy_stakes.out and results/toy_property.out; they use fixed seeds and should agree exactly. Then compare every number of Section 11 of note.md with these outputs. (2) For every script in proofs/code/ (Python files; list them first), run it with a time limit of 10 minutes (write a small driver; run at most two scripts at a time; never run with more than 4 GB of memory), capture its output, and compare with the saved output file of the same name (.out) if there is one. Record for each script: ran or timed out or failed (with the error, for instance a missing module), and identical or different output (for different output say whether the difference is in the numbers or only in timing or ordering). Do not edit any script or saved output. (3) For the ten most-quoted numerical claims of note.md that rest on a script (find them by searching the note for numbers that also occur in proofs/code/*.out), confirm that the number in the note is the number in the output.
OUTPUT: verification/reproduction.md with a table of all scripts and results, the list of mismatches, and the list of claims of part (3).`,
  },
}

const VERDICT_SCHEMA = {
  type: 'object',
  properties: {
    report: { type: 'string' },
    summary: { type: 'string' },
    verdicts: { type: 'array', items: { type: 'object', properties: { id: { type: 'string' }, verdict: { type: 'string' }, note: { type: 'string' } }, required: ['id', 'verdict', 'note'] } },
  },
  required: ['report', 'summary', 'verdicts'],
}
const FIX_SCHEMA = {
  type: 'object',
  properties: {
    files: { type: 'array', items: { type: 'string' } },
    summary: { type: 'string' },
    corrections: { type: 'array', items: { type: 'string' } },
    for_lead: { type: 'array', items: { type: 'string' } },
  },
  required: ['files', 'summary', 'corrections', 'for_lead'],
}
const REFEREE_SCHEMA = {
  type: 'object',
  properties: {
    report: { type: 'string' },
    summary: { type: 'string' },
    findings: { type: 'array', items: { type: 'object', properties: { grade: { type: 'string' }, where: { type: 'string' }, finding: { type: 'string' }, fix: { type: 'string' } }, required: ['grade', 'where', 'finding', 'fix'] } },
  },
  required: ['report', 'summary', 'findings'],
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
const opts = (label, phaseName, schema) => ({ label, phase: phaseName, schema, agentType: 'general-purpose' })

const mode = (args && args.mode) || 'second'
if (mode === 'second') {
  const keys = (args && Array.isArray(args.keys) ? args.keys : Object.keys(PARTS)).filter(k => PARTS[k])
  const results = await pipeline(
    keys,
    async k => {
      const key = 'Your key is: ' + k + ' (KEY in the file names below).\n\n'
      const c = await run(CONTEXT + '\n' + key + SECOND_RULES + '\n' + PARTS[k], opts('second:' + k, 'Second check', VERDICT_SCHEMA), 'opus')
      return { check: c }
    },
    async (prev, k) => {
      if (!prev.check) return { key: k, check: null, fix: null }
      const key = 'Your key is: ' + k + ' (KEY in the file names below).\n\n'
      const f = await run(CONTEXT + '\n' + key + FIX_RULES + '\n' + PARTS[k], opts('fix:' + k, 'Fix', FIX_SCHEMA), null)
      return { key: k, check: prev.check, fix: f }
    }
  )
  return { mode, parts: results }
}

const names = (args && Array.isArray(args.names) ? args.names : Object.keys(REFEREES)).filter(n => REFEREES[n])
const reports = await parallel(names.map(n => () =>
  run(CONTEXT + '\n' + REFEREES[n].prompt + '\nOUTPUT FILE: ' + REFEREES[n].out + ' (unless other files are named above).\nRETURN: the path of your report, a summary of at most 300 words, and the list of findings (grade, where, finding, fix); for the reproduction role use grade MISMATCH or OK and one finding per mismatch.',
    opts('referee:' + n, 'Referee', REFEREE_SCHEMA), REFEREES[n].first).then(r => ({ name: n, result: r }))
))
return { mode, referees: reports }
