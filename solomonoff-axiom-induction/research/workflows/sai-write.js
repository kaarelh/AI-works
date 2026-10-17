export const meta = {
  name: 'sai-write',
  description: 'Write the Solomonoff axiom induction paper from the research synthesis, in modes: plan (planning editor + bibliography/novelty agent), write (section writers for the groups in args), front (intro, discussion, abstract, notation and checking appendices, full build), review (five reviewers + lead editor), edit (editors for the groups in args), final (fresh final checkers)',
  phases: [
    { title: 'Plan', detail: 'mode plan' },
    { title: 'Write', detail: 'mode write / front' },
    { title: 'Review', detail: 'mode review' },
    { title: 'Edit', detail: 'mode edit' },
    { title: 'Final', detail: 'mode final' },
  ],
}
const ROOT = '/home/user/AI-works/solomonoff-axiom-induction'
const R = `${ROOT}/research`
const P = `${ROOT}/paper`
const SOI = '/home/user/AI-works/solomonoff-operator-induction'
const RESTART = `RESTART SAFETY: the container running this work is sometimes restarted, which kills you mid-task. (1) Before starting, look for partial versions of your own output files from an earlier interrupted run; if present, read them, check them, keep what is sound and continue from there instead of starting over. (2) Write your output files early and save them after each major part, so that little is lost if you are killed.`
const COMMON = `Project: a paper on Solomonoff axiom induction (name only through the macro \\SAI; working value "Solomonoff axiom induction"), in ${ROOT}. Authors: Kaarel Hänni and Claude (Anthropic).
Read first: the brief ${R}/00-brief.md (the author's requests verbatim; the binding epistemic policy: the paper asserts only what we believe, whoever proposed it; the authorship rule; the agreed stances on "what a theory is" and "existing language"), and the research synthesis ${R}/notes-final.md with its final check ${R}/final-check.md. The synthesis's §1 "How to state it" lines and §2.8 (which claims rest on theorems and which remain arguments) are binding. The thread records ${R}/tracks/<key>/notes-final.md (keys: fundamentals, sfi, logic, terms, shape, laws, philosophy) hold the full statements and proofs; their referee reports are next to them.
Writing rules (from the companion papers, binding): ${SOI}/research/paper-review/REFRAME.md and ${SOI}/research/paper-review/DECISIONS.md §A (arXiv form):
* first presentation of the material, voice "we";
* no running-text citations, quotations of or replies to Hänni's working notes; credit goes in short neutral footnotes ("first appeared in Hänni's working notes \\citep{hanni2026notes}") and the acknowledgements;
* statuses rendered in prose ("we prove", "we conjecture", "a computation shows (code in the accompanying repository)"); proof sketches labelled as such and never stated as theorems; computed numbers outside theorem statements;
* no process vocabulary in printed text: no "thread", "track", "scout", "referee", "workflow", "agent", "record", "synthesis";
* every source keeps a \\status{...} and \\src{...} call on each result, as in the companion papers (both macros print nothing);
* only references verified by search (see the bibliography report once it exists, ${P}/bib/bib-report.md);
* plain, precise, formal English; no model names or versions anywhere.
Mathematics must match the thread final records exactly: hypotheses, quantifiers, constants, status. Never strengthen a statement; when a record and the synthesis differ, the record (as corrected in final-check.md) wins.
Builds: isolated ./test-section.sh <section> <appendix> from ${P}; full builds only via cd ${P} && flock /tmp/claude-0/paper-build-sai.lock ./build.sh . No git commands that change repository state.
${RESTART}`
const LOG = { type: 'object', properties: { summary: { type: 'string' }, open: { type: 'array', items: { type: 'string' } }, pages: { type: 'string' } }, required: ['summary'] }
const GROUPS = {
  basic: { files: 'sections/setting.tex, sections/basic.tex, sections/app-basic.tex', what: '§2 Setting and §3 Basic theorems, with Appendix A (proofs for §2–§3)', src: 'fundamentals (and laws Props 1.8–1.9 for the randomised-theory remarks; logic for pointers)' },
  soi: { files: 'sections/soi.tex, sections/app-soi.tex', what: '§4 Relation to Solomonoff operator induction, with Table 1, and Appendix B', src: 'sfi (and terms Thm 6.5 where cited)' },
  logic: { files: 'sections/logic.tex, sections/app-logic.tex', what: '§5 Logic: random theories, Π1 truth and Gödel phenomena, and Appendix C', src: 'logic' },
  phil: { files: 'sections/phil.tex, sections/app-phil.tex', what: '§6 What a theory does and what it is, with Table 2, and Appendix D', src: 'philosophy (§§1–3, 5), with pointers to shape, terms, laws' },
  shape: { files: 'sections/shape.tex, sections/app-shape.tex', what: '§7 Theory shape relative to a reasoner, with Table 3, and Appendix E', src: 'shape' },
  terms: { files: 'sections/terms.tex, sections/app-terms.tex', what: '§8 Theoretical terms: Craig, Ramsey and the theoretician\'s dilemma, and Appendix F', src: 'terms (and philosophy §1.6 for Hempel\'s replies)' },
  laws: { files: 'sections/laws.tex, sections/app-laws.tex', what: '§9 Approximate laws and the best system, and Appendix G', src: 'laws' },
  kepler: { files: 'sections/kepler.tex, sections/app-kepler.tex', what: '§10 A worked example: Kepler and Newton, with its tables and Figure 1, and Appendix H', src: 'philosophy §4 (and laws §3.6 residuals, laws Prop 5.5 on K3)' },
  limits: { files: 'sections/limits.tex, sections/related.tex', what: '§11 Limitations (with Table 4, the condensation essay\'s list) and §12 Related work', src: 'philosophy §5–§7 and the synthesis §2.7, §5.7; scouts/literature; every thread\'s related-work section' },
}
const mode = (args && args.mode) || 'plan'

if (mode === 'plan') {
  phase('Plan')
  const [plan, bib] = await parallel([
    () => agent(`${COMMON}\n\nYou are the PLANNING EDITOR. Set up ${P} so that section writers can work in parallel without conflicts.
1. Infrastructure, adapted from the companion paper ${SOI}/paper (preamble.tex, main.tex, build.sh, test-section.sh, merge_bib.py): ${P}/preamble.tex with the generic part and this paper's macros (\\SAI and every symbol of the final notation; \\status and \\src printing nothing; theorem environments with \\crefname entries; a question environment); ${P}/main.tex (title "\\SAI: Definitions, Basic Theorems, and What a Theory Is and Does", the synthesis's recommended option; author line \\author{Kaarel H\\"anni \\and Claude (Anthropic)\\thanks{...}} with the footnote of synthesis §5.2: Claude is an AI system made by Anthropic; Claude produced the proofs, the computations and the text under Hänni's direction, starting from his questions and working notes; the results were checked by separate Claude instances acting as referees, with independent code; no human has yet independently checked all of the mathematics, and nothing was verified in a proof assistant; no model version); \\input of every section and appendix in the order of synthesis §5.3; build.sh, test-section.sh and merge_bib.py working in ${P}; a stub file for every section and appendix so that the full build passes.
2. ${P}/NOTATION.md: the final notation, from ${R}/NOTATION-draft.md, settling every decision listed in synthesis §5.6 and the threads' notation requests (fundamentals §13, philosophy §8, shape §15, laws, terms); one symbol per object across the paper; macros for each.
3. ${P}/OUTLINE.md: for each section and appendix: its file, its contents, the labels it defines (synthesis §5.3, adjusted to the final notation), its page budget (synthesis §5.4; main text about 42 pages), what it cites from other sections (by label), and the exact source items in the thread records.
4. ${P}/CLAIMS.md: the claims ledger. One row per numbered result to appear in the paper: label, statement in one line, source (thread and item), status as it must be rendered, main text or appendix, the "how to state it" constraint if any, and dependencies on other labels. Include the corrections recorded in ${R}/final-check.md §4.
5. Credit: list in OUTLINE.md the places where a footnote credits Hänni's working notes (questions, examples, the trichotomy, the proof-requiring/consistency-requiring variants, the condensation essay's list), at most about 8 footnotes.
6. Run a full build of the stubs (0 errors). Write ${P}/plan-log.md.
Do not write section prose; the writers do that.`, { label: 'plan', phase: 'Plan', schema: LOG }),
    () => agent(`${COMMON}\n\nYou are the BIBLIOGRAPHY AND NOVELTY EDITOR. Work in ${P}/bib/ (create it).
1. Start from ${R}/refs.bib (241 entries) and ${R}/final-check.md §2. Write ${P}/bib/refs.bib: fix the merge artefact (the five shape entries without a verification comment; the wrong "every entry below" line); keep provenance comments; confirm or drop unconfirmed fields (e.g. tenenbaum2006theory); add ${P}/bib/core.bib with the internal entries (hanni2026notes; the two companion papers with authors "H{\\"a}nni, Kaarel and {Claude (Anthropic)}" and titles exactly as in ${SOI}/paper/bib/core.bib; claude2026axiominduction, claude2026axiomschemas, claude2026whatfollows with both authors as in ${SOI}/paper/bib/core.bib or the projects' READMEs).
2. Verify by WebSearch, with exact bibliographic data, every reference the synthesis (§5.7 and the "to verify before citing" list), final-check.md and the thread records mark as unverified or not in refs.bib but needed: at least Dempster 1967, Shafer 1976, Suppes–Zanotti 1977, Pearl 1988, Demuth 1975, Smullyan 1961, the Babai–Gál–Wigderson title, the philosophy thread's references marked "[known, unverified here]" (its §7), the shape thread's GKRS, Gwynne–Kullmann, Berman et al., Chandra–Fortune–Lipton, Håstad, and the 24 entries copied without a search in this project (re-search them). Add verified entries with a comment saying how each was verified; list in the report what could not be verified (the writers must not cite those).
3. The modified Demski prior: find its definition (search results; mirrors such as greaterwrong.com or alignmentforum.org may be fetchable even though lesswrong.com is not; try them) and the posts of Fallenstein, Demski, Garrabrant and others on it, and the paper "Inductive Coherence" (Garrabrant et al. 2016). Write in the report the exact definition as stated in a source you could read (quote it), and whether fundamentals Prop 10.1's description of it is accurate. Add verified bib entries.
4. Novelty check for shape Thm 3.6: identify the SAT 2026 paper (LIPIcs vol. 377, paper 5) on propagation-complete XOR encodings, read at least its abstract, and decide whether it proves or implies Thm 3.6 (exponential written length of every UP-usable encoding of the hidden-state law, any auxiliary variables). Also search for any prior statement of the lottery (logic Thm 2.2), the dilemma theorem's complexity-theoretic Craig result (terms Thm 3.3), and the coin-free equivalence (sfi Thm 2.1).
5. Write ${P}/bib/bib-report.md: per item above, what was found, with sources and the verdict; a list "citable" (key → what it may be cited for) and "not citable".`, { label: 'bib', phase: 'Plan', schema: LOG }),
  ])
  return { plan, bib }
}

if (mode === 'write') {
  phase('Write')
  const keys = args.groups
  const res = await pipeline(keys, k => agent(`${COMMON}\n\nYou are the SECTION WRITER for group "${k}": ${GROUPS[k].what}. Your files: ${P}/${GROUPS[k].files} (only these). Sources: the thread record(s) ${GROUPS[k].src}, the synthesis, ${P}/OUTLINE.md (your section's contents, labels, budget and cross-references), ${P}/CLAIMS.md (every row of your section: statement, status, placement, constraints), ${P}/NOTATION.md (use its macros only), ${P}/bib/bib-report.md (cite only "citable" keys, for what they may be cited for).
Write the section as a first presentation in arXiv style: motivation for each definition and result, then precise statements (main text) and complete proofs (appendix), with \\status and \\src on each result. Use exactly the labels of OUTLINE.md; refer to other sections only by those labels. Keep to the page budget (report your main-text and appendix pages from an isolated build). Each statement must match its source item and the CLAIMS.md row; each proof must be complete or explicitly a proof sketch. When the source has a "how to state it" line, follow it. Where a result's novelty is unconfirmed, say so in the text as the bibliography report requires.
When done, ./test-section.sh must compile your section(s) with 0 errors. Write ${P}/logs/write-${k}.md (what you wrote, page counts, any deviation from OUTLINE/CLAIMS with the reason, items for other groups).`, { label: `write:${k}`, phase: 'Write', schema: LOG }))
  return res.map((r, i) => ({ group: keys[i], r }))
}

if (mode === 'front') {
  phase('Write')
  return await agent(`${COMMON}\n\nYou are the FRONT WRITER. The section writers have finished; read their logs (${P}/logs/write-*.md) and all section files before writing. Your files: ${P}/sections/abstract.tex, intro.tex, discussion.tex, app-notation.tex (Appendix I, the notation table), app-verification.tex (Appendix J, the internal record of how the results were checked; it is switched off in main.tex by \\sairecordfalse because it may use process vocabulary, so it is not printed), and main.tex if needed.
* Abstract (≤ 250 words): as synthesis §5.2.
* Introduction (§1, about 3 pages): as synthesis §5.3 §1 — the two problems, raw-data prediction against answering questions posed with existing abstractions, the object, the ladder, a short Kepler preview, the contributions list (one line per main result with \\cref), what we do not claim, roadmap. Every claim with the body's hypotheses.
* Discussion (§13, about 1 page): what the formalism shows and cannot show; five open problems (synthesis §6) by \\cref to the body where stated; directions; acknowledgements (thanks to Sam Eisenstat and Dmitry Vaintrob only if the body uses their work; the sentence that several questions and examples first appeared in Hänni's working notes; Hänni takes responsibility for the content); code and data (folder solomonoff-axiom-induction/ of https://github.com/kaarelh/AI-works).
* Appendix J (not printed): the checking process (independent derivations and code by separate Claude instances acting as referees; what was not checked: no proof assistant, no human check of all the mathematics, references verified at the stated level), a status table of every main-text result by label.
Then a full build (flock) until 0 LaTeX errors, 0 undefined references and citations, 0 multiply defined labels, no overfull box above 10pt (fix minimally in any file and record it). Report page counts (main text, references, appendices). Write ${P}/logs/front.md.`, { label: 'front', phase: 'Write', schema: LOG })
}

if (mode === 'review') {
  phase('Review')
  const REV = { type: 'object', properties: { summary: { type: 'string' }, fatal: { type: 'integer' }, major: { type: 'integer' }, minor: { type: 'integer' } }, required: ['summary'] }
  const reviewers = [
    { key: 'math-a', task: 'MATHEMATICS REVIEWER A: §2, §3, §4 and Appendices A, B. Check every statement against its source item in the thread records (fundamentals, sfi) and CLAIMS.md, and every proof line by line; look for hidden hypotheses, wrong constants, misplaced quantifiers, statuses stronger than the source, broken cross-references.' },
    { key: 'math-b', task: 'MATHEMATICS REVIEWER B: §5, §8 and Appendices C, F (sources: logic, terms). Same checks as a mathematics reviewer.' },
    { key: 'math-c', task: 'MATHEMATICS REVIEWER C: §7, §9, §10 and Appendices E, G, H (sources: shape, laws, philosophy §4). Same checks; for every computed number, find it in the saved script outputs in the thread folders.' },
    { key: 'phil', task: 'PHILOSOPHY REVIEWER: §1, §6, §10, §11, §12, §13 and the abstract. As a critical philosopher of science: are the characterisations of cited authors accurate (verify by WebSearch where doubtful)? Are the brief\'s epistemic policy and agreed stances respected (only what we believe; the descriptive observation versus the explanatory question; the ladder; theorems versus arguments as in synthesis §2.8)? Is any formal result overclaimed as settling a philosophical question? Are the limitations stated fully and fairly? Does the paper engage the obvious objections (semantic view, Bayesian confirmation theory, best-system debate, practice of physics)?' },
    { key: 'consistency', task: 'CONSISTENCY AND ARXIV-READINESS REVIEWER: the whole paper. Notation against NOTATION.md; labels and cross-references; the same result stated the same way everywhere (abstract, intro, body, tables, discussion); statuses rendered in prose; no process vocabulary (grep the PDF text); no quotation of or reply to the working notes; footnote credits; author line and footnote; no model names; every \\cite key verified per bib-report.md (and each citation used only for what it may support); page budget; readability.' },
  ]
  const revs = await parallel(reviewers.map(r => () => agent(`${COMMON}\n\nYou are ${r.task}\nThe paper is in ${P} (build it first, under the lock). Write ${P}/review/${r.key}.md: numbered issues, each with severity (fatal / major / minor), location (file, label), the problem, the evidence (source item, script output, quotation) and a concrete fix. Also write ${P}/review/${r.key}.json: a list of {id, severity, file, label, problem, fix}.`, { label: `review:${r.key}`, phase: 'Review', schema: REV })))
  const lead = await agent(`${COMMON}\n\nYou are the LEAD EDITOR. Read the five reviews in ${P}/review/ (*.md, *.json). Verify every fatal and major issue yourself against the paper and the thread records (accept, modify or reject, with the reason). Write ${P}/review/DECISIONS.md: editor rules; file ownership for the edit groups (basic: setting, basic, app-basic; soi; logic; phil; shape; terms; laws; kepler; limits: limits, related; front: abstract, intro, discussion, app-notation, app-verification, main.tex, preamble, bib); for each group, the issues it must fix (fatal, major, accepted minors) with the exact required change where the change is a statement; cross-group items; length targets. LENGTH IS BINDING: the drafts' main text is far over the planned 42.5 pages (the writers' logs give each section's overrun and list further cuts). Set a page target for every main-text section so that the whole main text (§1–§13, without references and appendices) is at most about 50 pages, and for each over-budget section name the exact statements or paragraphs to move to its appendix (a one-sentence summary with \\cref stays in the main text) or to cut; never drop a result from the paper. Also write ${P}/review/issues-<group>.json for each group, with the length moves as issues of severity "major".`, { label: 'lead-editor', phase: 'Review', schema: LOG })
  return { reviews: revs, lead }
}

if (mode === 'edit') {
  phase('Edit')
  const keys = args.groups
  const files = { ...Object.fromEntries(Object.entries(GROUPS).map(([k, v]) => [k, v.files])), front: 'sections/abstract.tex, intro.tex, discussion.tex, app-notation.tex, app-verification.tex, main.tex, preamble.tex, bib/' }
  const res = await pipeline(keys, k => agent(`${COMMON}\n\nYou are the EDITOR for group "${k}". Your files: ${P}/${files[k]} (only these, except a \\cref target elsewhere that your change breaks). Binding: ${P}/review/DECISIONS.md and your issue list ${P}/review/issues-${k}.json. Fix every issue in your list as decided; record each in ${P}/logs/edit-${k}.md (issue id, what changed, where; or why not). ${k === 'front' ? 'You run last: read the other groups\' edit logs first and apply every item addressed to "front"; then a full build (flock) to 0 errors, 0 undefined references and citations, 0 multiply defined labels, no overfull box above 10pt; report page counts.' : 'When done, ./test-section.sh must compile your section(s).'}`, { label: `edit:${k}`, phase: 'Edit', schema: LOG }))
  return res.map((r, i) => ({ group: keys[i], r }))
}

if (mode === 'final') {
  phase('Final')
  const halves = [
    { key: 'math', scope: '§2–§5, §7–§9 and Appendices A–C, E–G' },
    { key: 'text', scope: 'the abstract, §1, §6, §10–§13 and Appendices D, H, I, J' },
  ]
  return await parallel(halves.map(h => () => agent(`${COMMON}\n\nYou are a FRESH FINAL CHECKER who has not seen this paper before. Scope: ${h.scope}. You may edit any file, minimally, to fix what you find.
1. Every fatal and major issue in ${P}/review/DECISIONS.md within your scope: is the decided fix in place and correct?
2. Spot-check 25 statements in your scope against the thread records and CLAIMS.md (hypotheses, constants, statuses), and every computed number in your scope against the saved script outputs.
3. arXiv-readiness greps on the sources and on pdftotext main.pdf: process vocabulary, quotations of the notes, model names, "SFI", unverified citations (against bib-report.md).
4. Full build (flock): 0 errors, 0 undefined references and citations, 0 multiply defined labels; overfull boxes above 10pt; page counts.
Write ${P}/review/final-check-${h.key}.md.`, { label: `final:${h.key}`, phase: 'Final', schema: LOG })))
}
