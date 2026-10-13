export const meta = {
  name: 'sfi-reframe',
  description: 'Rewrite both SFI papers so they read as the first presentation of the material, with the author\'s notes credited only in footnotes and acknowledgements; then independent framing and math-invariance checks, fixes and a second fresh read',
  phases: [
    { title: 'Edit', detail: 'six editor groups rewrite framing, attribution and motivation per REFRAME.md' },
    { title: 'Check', detail: 'per paper: a fresh reader (framing) and a diff checker (mathematics unchanged, numbering frozen)' },
    { title: 'Fix', detail: 'per paper: apply confirmed findings, full build' },
    { title: 'Recheck', detail: 'per paper: a second fresh reader; a last fix only if needed' },
  ],
}
const ROOT = '/home/user/AI-works/solomonoff-function-induction'
const P1 = `${ROOT}/paper`
const P2 = `${ROOT}/paper-steeper`
const RV = `${ROOT}/research/paper-review`
const L = `${RV}/reframe`
const BASE = '5acf4db3'
const COMMON = `Two companion papers on Solomonoff function induction (SFI), by Kaarel Hänni: Paper 1 (fundamentals) in ${P1} and Paper 2 (steeper simplicity priors) in ${P2}; each has sections/*.tex, preamble.tex, main.tex, bib/. Both are finished arXiv-style drafts (see ${RV}/DECISIONS.md for the earlier editorial decisions, which still hold except where the new note overrides them).
NEW BINDING NOTE, read it in full first: ${RV}/REFRAME.md. It quotes the author's request: the papers should read as the first presentation of this material, not as a reply to his notes; the notes are an internal stage of the research; references to them go in short neutral footnotes and the acknowledgements; mathematics, labels, \\status/\\src calls and Paper 1's numbering stay unchanged.
Sources for any factual question: ${ROOT}/research/tracks/*/notes-final.md, ${ROOT}/research/prior/ (the notes themselves, the slides). Work only in the files you are assigned. No git commands that change repository state (read-only git such as git diff ${BASE} -- <path> is fine). Isolated builds: ./test-section.sh <section> <appendix> from the paper folder; full builds only as: cd <paper folder> && flock /tmp/claude-0/paper-build-sfi.lock ./build.sh . Logs go to ${L}/ (create it).`
const GROUPS = [
  { g: 'p1-front', dir: P1, files: 'sections/abstract.tex, sections/intro.tex, sections/discussion.tex (incl. acknowledgements), main.tex' },
  { g: 'p1-setting', dir: P1, files: 'sections/setting.tex, versions.tex, learn.tex, app-setting.tex, app-versions.tex, app-learn.tex' },
  { g: 'p1-hist-ex', dir: P1, files: 'sections/hist.tex, examples.tex, app-hist.tex, app-examples.tex' },
  { g: 'p1-ood', dir: P1, files: 'sections/ood.tex, comp.tex, nn.tex, related.tex, steeper.tex, app-ood.tex, app-comp.tex, app-nn.tex' },
  { g: 'p2-body', dir: P2, files: 'sections/setup.tex, absorb.tex, teacher.tex, limits.tex, split.tex, algstat.tex, computable.tex, related.tex and every app-*.tex except app-verification.tex' },
  { g: 'p2-front', dir: P2, files: 'sections/abstract.tex, sections/intro.tex, sections/discussion.tex (incl. acknowledgements), main.tex' },
]
const LOG = { type: 'object', properties: { summary: { type: 'string' }, changes: { type: 'number' }, footnotes_citing_notes: { type: 'number' }, unresolved: { type: 'array', items: { type: 'string' } } }, required: ['summary'] }
const FIND = { type: 'object', properties: { summary: { type: 'string' }, findings: { type: 'array', items: { type: 'object', properties: { id: { type: 'string' }, file: { type: 'string' }, where: { type: 'string' }, problem: { type: 'string' }, fix: { type: 'string' }, severity: { type: 'string' } }, required: ['file', 'problem', 'fix'] } } }, required: ['summary', 'findings'] }
const editor = x => agent(`You are the editor for group "${x.g}". ${COMMON}
Your paper folder: ${x.dir}. Your files: ${x.files}.
Task: apply REFRAME.md to your files. Grep them for every visible reference to the notes and to the author (hanni2026notes, hanni2026grokking, "author", "notes", "draft", "conjectur", "as proposed", "anticipated", quotation marks around text from the notes) and read the files in full, since framing can also be implicit (a result introduced as a fix, a title that only makes sense against the notes). Rewrite each passage so that the question or result is motivated on its own merits and stated in our voice; move credit into short neutral footnotes (merged, about one per section, never inside a theorem-like statement or a float) or delete it where the acknowledgements cover it; keep every mathematical statement, hypothesis, number and caveat; keep labels, \\status/\\src calls and (in Paper 1) the numbering of every environment, section and equation. Keep or shorten the length. ${x.g.endsWith('front') ? 'You own the introduction: delete the "Relation to the author\'s notes" paragraph (Paper 2: move any "other work" content into related work only if it is not already there, and tell p2-body in your log rather than editing related.tex), make the contributions list free of references to the notes, rewrite the acknowledgements as REFRAME.md §4 says' + (x.g === 'p2-front' ? ', recaption tab:intro:claims and rewrite its rows and the introduction so that the proposal is the paper\'s subject (REFRAME.md §4, Paper 2); the single footnote crediting hanni2026grokking at the first statement of the proposal is yours if that first statement is in the introduction, otherwise p2-body\'s in setup.tex or absorb.tex — check with grep and say in your log which file has it.' : '.') : 'Introductions, abstracts and acknowledgements are the front groups\' files.'}
At the end: ./test-section.sh compiles each of your section/appendix pairs (front groups: test intro and discussion as sections); grep your files once more and list every remaining visible citation of hanni2026notes / hanni2026grokking with its footnote/acknowledgement context. Write ${L}/log-${x.g}.md: for every change, file and label or line, the old text (abridged) and the new text (abridged), and why mathematics is unchanged.`, { label: `edit:${x.g}`, phase: 'Edit', schema: LOG })
const PAPERS = [
  { key: 'p1', dir: P1, groups: ['p1-front', 'p1-setting', 'p1-hist-ex', 'p1-ood'], name: 'Paper 1' },
  { key: 'p2', dir: P2, groups: ['p2-front', 'p2-body'], name: 'Paper 2' },
]
const reader = (p, round) => agent(`You are a FRESH reader of ${p.name} (${p.dir}) who has not seen it before. ${COMMON}
First run the full build (flock as above) and then pdftotext -layout main.pdf. Read the whole PDF text (main text and appendices, not the bibliography) as an arXiv reader would. Report every passage that (a) reads as replying to, answering, confirming, correcting, quoting or evaluating the author's notes or an earlier draft, or speaks of "the author" outside the title-page footnote and the acknowledgements (Eisenstat's "personal communication" credit is allowed); (b) cites hanni2026notes or hanni2026grokking (shown as Hänni (2026b/c) or similar; check main.bbl for which key is which) anywhere except a footnote or the acknowledgements; (c) has a footnote crediting the notes that is not neutral, is inside a statement or float, or could be merged with a nearby one; (d) introduces a definition, question or result without a motivation of its own now that the reference to the notes is gone (the motivation reads as missing or abrupt); (e) has a title that only makes sense against the notes. Also count the footnotes that cite the notes (REFRAME.md target: Paper 1 at most about 10, Paper 2 at most about 5). For each finding give the exact location (section, PDF line, and the .tex file and label you traced it to), the problem and a concrete replacement text. Do not edit anything. Write ${L}/reader-${p.key}-r${round}.md.`, { label: `reader:${p.key}:r${round}`, phase: round === 1 ? 'Check' : 'Recheck', schema: FIND })
const diffcheck = p => agent(`You are the mathematics-invariance checker for ${p.name} (${p.dir}). ${COMMON}
Run: cd ${ROOT} && git diff ${BASE} -- ${p.dir.replace(ROOT + '/', '')}/sections ${p.dir.replace(ROOT + '/', '')}/main.tex . Read every hunk. The edit was meant to change only motivation, attribution and framing. Report every hunk that (1) changes a mathematical statement, hypothesis, quantifier, number, constant, proof step, or drops a caveat or an open-question statement (compare old and new carefully; a caveat that was phrased against the notes must survive as mathematics); (2) adds a claim not supported by the track records (${ROOT}/research/tracks/*/notes-final.md) — e.g. a new motivation that asserts a fact; (3) adds or deletes a numbered environment, section, subsection or numbered equation${p.key === 'p1' ? ' (forbidden in Paper 1: Paper 2 cites Paper 1 by number; check by comparing \\\\begin{...} counts per file between the base and now)' : ''}, or renames, removes or adds a \\label, or removes a \\status/\\src call; (4) introduces a LaTeX problem (footnote in a statement or float, broken \\cref). Also confirm that the facts attributed to the slides of Vaintrob and Hänni stay accurate (slides text: ${ROOT}/research/prior/vaintrob-hanni-nnbayes-generalization-slides.txt). For each finding: file, hunk location, problem, the exact fix (often: restore the old wording of the mathematical part). Do not edit anything. Write ${L}/diffcheck-${p.key}.md.`, { label: `diffcheck:${p.key}`, phase: 'Check', schema: FIND })
const fixer = (p, inputs, round) => agent(`You are the fixer for ${p.name} (${p.dir}), round ${round}. ${COMMON}
Findings to resolve: ${inputs}. Verify each finding yourself against the current sources and REFRAME.md (a reader can be wrong; reject with a reason if so), then fix it minimally in any file of this paper. Mathematics-invariance findings take precedence: restore the mathematical content exactly. Then run the full build (flock as above) until there are 0 LaTeX errors, 0 undefined references or citations, 0 multiply defined labels and no overfull box above 10pt. ${p.key === 'p1' ? 'Check that Paper 1\'s numbering is unchanged: compare the \\\\newlabel entries of main.aux with those of the base version (git show ' + BASE + ':solomonoff-function-induction/paper/main.pdf is not useful; instead rebuild the base in a scratch copy only if needed — simpler: run python3 -I ' + RV + '/scratch/editor/check_companion_numbers.py, which checks every Paper 1 number that Paper 2 cites, and report its last line).' : 'Run python3 -I ' + RV + '/scratch/editor/check_companion_numbers.py (it checks the Paper 1 numbers Paper 2 cites) and report its last line.'} Count the footnotes citing the notes. Write ${L}/fix-${p.key}-r${round}.md: each finding id → fixed / rejected (reason), and the build result.`, { label: `fix:${p.key}:r${round}`, phase: round === 1 ? 'Fix' : 'Recheck', schema: LOG })
phase('Edit')
const results = await pipeline(
  PAPERS,
  p => parallel(GROUPS.filter(x => p.groups.includes(x.g)).map(x => () => editor(x))),
  async (edits, p) => {
    const [r, d] = await parallel([() => reader(p, 1), () => diffcheck(p)])
    return { edits, r, d }
  },
  async (prev, p) => {
    const f1 = await fixer(p, `${L}/reader-${p.key}-r1.md and ${L}/diffcheck-${p.key}.md`, 1)
    return { ...prev, f1 }
  },
  async (prev, p) => {
    const r2 = await reader(p, 2)
    const n = r2 && r2.findings ? r2.findings.length : 0
    log(`${p.name}: second fresh read found ${n} items`)
    const f2 = n > 0 ? await fixer(p, `${L}/reader-${p.key}-r2.md`, 2) : null
    return { ...prev, r2, f2 }
  },
)
return results.map((x, i) => ({ paper: PAPERS[i].key, editors: x && x.edits ? x.edits.map(e => e && e.summary) : null, reader1: x && x.r && x.r.findings.length, diff: x && x.d && x.d.findings.length, fix1: x && x.f1 && x.f1.summary, reader2: x && x.r2 && x.r2.findings.length, fix2: x && x.f2 && x.f2.summary }))
