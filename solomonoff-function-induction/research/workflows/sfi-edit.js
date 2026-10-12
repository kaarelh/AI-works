export const meta = {
  name: 'sfi-edit',
  description: 'Apply the review decisions and the arXiv conversion to both SFI papers: body editors, front editors, fresh final checks',
  phases: [
    { title: 'Edit body', detail: 'four editors (three for Paper 1, one for Paper 2) apply their issue lists, render statuses academically, cut length' },
    { title: 'Edit front', detail: 'abstract, intro, discussion, acknowledgements, preamble, main.tex, bibliography; status/src removal; full builds' },
    { title: 'Final check', detail: 'one fresh checker per paper: fixes in place, front vs body, spot checks, arXiv-readiness, full build' },
  ],
}
const ROOT = '/home/user/AI-works/solomonoff-function-induction'
const P1 = `${ROOT}/paper`
const P2 = `${ROOT}/paper-steeper`
const R = `${ROOT}/research/paper-review`
const E = `${R}/edits`
const COMMON = `Two companion papers: Paper 1 (fundamentals of Solomonoff function induction) in ${P1} and Paper 2 (steeper simplicity priors) in ${P2}; each has sections/*.tex, preamble.tex, main.tex, bib/, OUTLINE.md, CLAIMS.md (notation for both: ${P1}/NOTATION.md). BINDING: ${R}/DECISIONS.md (read it in full first) and the binding notes at the top of each OUTLINE.md. The target is a standard academic paper suitable for arXiv:
- no \\status or \\src markup carries information the reader needs: every non-"proved" status is rendered in prose or in the right environment exactly as DECISIONS.md says (proof sketches labelled "Proof sketch", conjectures in the conjecture environment, computations as "a direct computation (code in the accompanying repository) gives ...", known results as cited statements, refuted claims only where they inform the reader and then as "the stronger statement ... fails: ...");
- no process vocabulary anywhere in the PDF (track, referee, ledger, notes-final, brief, orchestrator, verdict, "the request", H1-H10, internal file paths other than the repository URL in the code-and-data statement);
- the absorption objection is a standard point: never name it after Wyeth, never quote him; at most one neutral footnote may say the point was also raised in an online discussion (only if DECISIONS.md keeps it);
- author Kaarel Hänni alone, AI assistance disclosed (title-page footnote and acknowledgements; "Claude (Anthropic)", never a model version);
- only verified references (per DECISIONS.md); formal, plain, precise prose; no claim beyond the sources.
Sources of claims: ${ROOT}/research/tracks/{foundations,history,examples,context,steeper}/notes-final.md (with referee.md and checks/), ${ROOT}/research/prior/ (Hänni's notes, the Vaintrob–Hänni slides). Reviews: ${R}/p1/, ${R}/p2/ (review-*.md, issues-*.json, reviewer scripts in ${R}/scratch/).
Rules: fix every fatal and major issue in your list exactly as decided (if the decided fix is itself wrong, make the correct fix and record why); fix minor issues; apply the length cuts and moves in DECISIONS.md for your files (never drop a result statement or a needed caveat; moved results keep a one-line pointer); labels are never renamed; grep all sections/*.tex of the paper before deleting or moving a labelled item; do not run git commands that change repository state. Isolated builds: ./test-section.sh <section> <appendix> from the paper folder. Full builds only as: cd <paper folder> && flock /tmp/claude-0/paper-build-sfi.lock ./build.sh . Record every issue's resolution in ${E}/<group>-log.md (issue id -> what you changed, file and label).`
const BODY = [
  { group: 'p1-setting', dir: P1, files: 'setting.tex, app-setting.tex, versions.tex, app-versions.tex, learn.tex, app-learn.tex' },
  { group: 'p1-hist-ex', dir: P1, files: 'hist.tex, app-hist.tex, examples.tex, app-examples.tex' },
  { group: 'p1-ood', dir: P1, files: 'ood.tex, app-ood.tex, comp.tex, app-comp.tex, nn.tex, app-nn.tex, steeper.tex, related.tex' },
  { group: 'p2-body', dir: P2, files: 'setup.tex, app-setup.tex, absorb.tex, app-absorb.tex, split.tex, app-split.tex, algstat.tex, app-algstat.tex, teacher.tex, app-teacher.tex, limits.tex, app-limits.tex, related.tex, app-related.tex' },
]
const LOG_SCHEMA = { type: 'object', properties: { summary: { type: 'string' }, unresolved: { type: 'array', items: { type: 'string' } }, pages: { type: 'string' } }, required: ['summary'] }
phase('Edit body')
const body = await parallel(BODY.map(b => () => agent(`You are the editor for group "${b.group}". ${COMMON}\nYour paper folder: ${b.dir}. Your files: ${b.files}. Your issue list: ${E}/${b.group}.json. Besides the issues, render every \\status and \\src in your files in academic form as DECISIONS.md prescribes, so that after the front editor redefines both macros to empty no information is lost; then delete the \\status{...} and \\src{...} calls from your files entirely (grep your files at the end: none may remain). Remove all process vocabulary and any Wyeth mention from your files. Only edit your files (exception: you may fix a \\cref target in another file of the same paper when your move changes it, and nothing else there; bibliography entries are owned by the front editor, so list any bib entry you need added, fixed or dropped in your log under "for front"). Do not edit preamble.tex or main.tex. When done, make sure ./test-section.sh compiles each of your section/appendix pairs, and report the page counts of your sections (isolated builds) against the targets in DECISIONS.md.`, { label: `edit:${b.group}`, phase: 'Edit body', schema: LOG_SCHEMA })))
phase('Edit front')
const FRONT = [
  { group: 'p1-front', dir: P1, files: 'abstract.tex, intro.tex, discussion.tex (with acknowledgements and code-and-data), app-verification.tex (switched off, file kept), preamble.tex, main.tex, bib/*.bib', body: 'p1-setting, p1-hist-ex, p1-ood' },
  { group: 'p2-front', dir: P2, files: 'abstract.tex, intro.tex, discussion.tex (with acknowledgements and code-and-data), app-verification.tex (switched off via \\sfirecordfalse, file kept), preamble.tex, main.tex, bib/*.bib', body: 'p2-body' },
]
const front = await parallel(FRONT.map(f => () => agent(`You are the front editor for group "${f.group}". ${COMMON}\nYour paper folder: ${f.dir}. Your files: ${f.files}. Your issue list: ${E}/${f.group}.json. The body sections have just been edited (logs: ${f.body.split(', ').map(g => `${E}/${g}-log.md`).join(', ')}; read their "for front" items and apply them). Read the edited body sections first, then make the abstract, the introduction (with a plain contributions list replacing any verdict table keyed to internal hypotheses) and the discussion match them exactly in scope and status. Apply the arXiv conversion for your paper as decided: author line and title-page footnote; acknowledgements (AI-assistance disclosure, Sam Eisenstat, Dmitry Vaintrob, as decided) and a "Code and data" statement; switch off the verification appendix (keep the file); render the \\status/\\src calls in your own files in prose and delete them; then grep the whole paper (sections/*.tex, main.tex) for \\status and \\src: if any remain in body files, render them yourself (minimally) and record it; finally redefine \\status and \\src to empty in preamble.tex (keep the definitions so stray uses do not break the build). Bibliography: apply the keep/fix/drop list in DECISIONS.md to bib/*.bib (fix entries with the verified data; drop unverifiable ones and rewrite or remove the sentences that cited them, in any file of this paper, minimally); keep core.bib identical in both papers (coordinate by applying exactly the decided core.bib changes). Remove every Wyeth mention and all process vocabulary from the whole paper (grep: Wyeth, track, referee, ledger, notes-final, brief, orchestrator, verdict, H1, H10, CLAIMS, "research/"). Then run the full build, fix every LaTeX error and every undefined reference or citation (in any file, minimally), and report pages (main text and appendices) and warnings against the targets in DECISIONS.md.`, { label: `edit:${f.group}`, phase: 'Edit front', schema: LOG_SCHEMA })))
phase('Final check')
const CHECK = [
  { key: 'p1', dir: P1, groups: 'p1-front, p1-setting, p1-hist-ex, p1-ood' },
  { key: 'p2', dir: P2, groups: 'p2-front, p2-body' },
]
const fin = await parallel(CHECK.map(c => () => agent(`You are a FRESH final checker who has not seen this paper before. ${COMMON}\nYour paper: ${c.dir} (groups ${c.groups}; their issue lists ${E}/<group>.json and logs ${E}/<group>-log.md).
1. For every fatal and major issue in your groups' issue lists, check in the current .tex files that the decided fix is in place and correct; list any that are not, and fix them yourself (minimally) if the fix is clear.
2. Read the abstract, introduction and discussion and check each claim against the body (same scope and status). Fix mismatches.
3. Spot-check 25 claims spread over all body sections and appendices against the track notes (numbers, hypotheses, statuses); fix errors.
4. arXiv-readiness: grep the sources for \\status, \\src, Wyeth, process vocabulary (track, referee, ledger, notes-final, brief, orchestrator, verdict, H1-H10, CLAIMS) and internal paths; read the rendered PDF text (pdftotext main.pdf) for the same; check every proof sketch is labelled, conjectures are conjectures, computations are presented as computations with a pointer to the code; check that every cited bib entry is in the verified/fixed list of DECISIONS.md; check the author line, the title-page footnote and the acknowledgements. Fix what you find.
5. Full build (flock as above): 0 errors, 0 undefined references/citations, 0 multiply defined labels; report overfull boxes > 10pt and page counts (main text and appendices).
Write ${R}/final-check-${c.key}.md with the results of 1-5.`, { label: `final-check:${c.key}`, phase: 'Final check', schema: { type: 'object', properties: { summary: { type: 'string' }, open: { type: 'array', items: { type: 'string' } }, pages: { type: 'string' } }, required: ['summary'] } })))
return { body, front, fin }
