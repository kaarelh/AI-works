export const meta = {
  name: 'axiom-induction-write',
  description: 'Write the Bayesian axiom induction paper: plan (outline, notation, claims ledger), section writers, intro/discussion',
  phases: [
    { title: 'Plan', detail: 'outline, unified notation, claims ledger, cross-track conflicts' },
    { title: 'Write', detail: 'one writer per section and its appendix' },
    { title: 'Frame', detail: 'intro, abstract, discussion, verification appendix, full build' },
  ],
}

const ROOT = '/home/user/AI-works/axiom-induction'
const P = `${ROOT}/paper`
const SOURCES = `Sources (the ONLY sources of claims): ${ROOT}/research/00-brief.md; the four final, refereed track records ${ROOT}/research/tracks/{model,universal,pa,experiments}/notes-final.md with their referee reports referee.md (read the verification logs at the end of each notes-final.md); code results in ${ROOT}/code/results/*.md; Hänni's notes in ${ROOT}/research/prior/. Background (cite, do not re-prove): ../axiom-schemas/paper/main.pdf (sources ../axiom-schemas/paper/sections/*.tex) and ../inferential-learning/paper (sections/*.tex).`
const RULES = `Rules: plain, precise prose, short sentences, no marketing; never claim more than the final notes establish; keep caveats, scope restrictions and refuted claims (refuted claims stay labelled refuted, with the counterexample, where they matter to the reader); every theorem-like environment gets \\status{proved | computed | conjecture | known | proof sketch | refuted} and \\src{track item} (e.g. \\src{model Thm 4.7}, \\src{universal Prop N2}, \\src{pa Prop 4.8}, \\src{experiments E2}); definitions get \\src only. Do not run git commands that change repository state. Do not edit files owned by other writers. Build checks: ./test-section.sh <section> <appendix> (isolated); never run ./build.sh except where told, and then only as: flock /tmp/claude-0/paper-build-ai.lock ./build.sh`

phase('Plan')
const plan = await agent(`You are the planning editor for a paper in ${P}. ${SOURCES}

Read ALL sources carefully (all four notes-final.md in full, and the referee reports). The paper answers Kaarel Hänni's question (quoted verbatim in the brief): is there a good Solomonoff-style axiom inducer (template prior, derivation-length likelihood, time penalty); what does it do for ∀xφ from instances φ(t); does it robustly pick up the actual axioms, a deductively equivalent system, or at least put a lot of posterior mass on them.

The paper scaffold exists: ${P}/main.tex (sections: intro, model, universal, ident, sound, time, pa, experiments, discussion; appendices app-model, app-universal, app-ident, app-sound, app-time, app-pa, app-experiments, app-verification), preamble.tex (copied from ../axiom-schemas; keep existing macros), bib/core.bib, build.sh, test-section.sh, merge_bib.py.

Write:
1. ${P}/OUTLINE.md: for each section and appendix, its purpose, the exact list of results (with source item and status) it states, what goes to the appendix (full proofs, computations), cross-references, and a page target. Main text about 40 pages total (intro 4, model 6, universal 7, ident 5, sound 5, time 5, pa 6, experiments 5, discussion 3), appendices about 35 pages. Section keys for labels: intro, model, univ, ident, sound, time, pa, exp, disc, ver (labels like sec:univ, thm:univ:B, prop:time:collapse, app:univ, tab:exp:e2).
   Assign: model = definitions (theories as finite DT° template sets; prior; Q grammar and subcriticality; likelihoods L0, L1, L2, L1^σ, L1-sel and other variants used by any track; Hänni's two 0/1 scores; size principle; computing the likelihood; the calculi used, e.g. C_min); universal = the ∀xφ case (universal track); ident = well-specified consistency, generator classes, splits and the MDL finding, misspecification, positive data and Gold, spare slots, predictive vs deductive (model §2, §3, §5, §8, plus experiments E5/E8 numbers briefly); sound = threshold verifier soundness (fixed weights, Dirichlet caveat and the two replacements, misspecified prover), cautious limit, trichotomy (model §4, §7; experiments E4 briefly); time = Hänni's collapse and time/derivation penalties (model §6, pa §3 link); pa = PA/ZF, equivalent axiomatisations, theorem data, Th(ℕ), Bayesian DTRC, robust failures (pa track; experiments E2/E3/E6 numbers briefly); experiments = implementation and E1–E8; discussion = answers, relation to Hänni's note, literature, open problems.
2. ${P}/NOTATION.md: ONE unified notation for the paper, reconciling the tracks (they list their differences in their "Cross-track consistency" sections: calculi, parameters, prior codes, likelihood names L1/L1-max/L1-sel/L1-norm/L1-sch/L1^σ, π_n, C*, Bel/Dis/Ind/Inc, S_prove/S_nc, V_{δ,d}, etc.). Give a table: symbol, meaning, defined where, and how each track's names map to it. Add needed macros to ${P}/preamble.tex (new macros only, in a clearly marked block; do not change existing macros).
3. ${P}/CLAIMS.md: a ledger of every result the paper will state: id, one-line statement, status, source (track and item), section. Then a section "Cross-track conflicts": every place where two tracks disagree or use incompatible setups (e.g. different calculi or codes giving different numbers; claims one track refuted that another still uses), with your resolution after checking the sources (or an explicit instruction to writers to state both with their scopes). Also list "Answers to the question" (5–10 bullet points, each tied to ledger ids) — the intro and discussion will be written from it.
4. Set the title in ${P}/main.tex (replace TITLE; a plain descriptive title, e.g. about Bayesian/Solomonoff-style axiom induction from instances).
${RULES}
Return a short summary of the outline and the conflicts you found.`, { label: 'plan', phase: 'Plan', schema: { type: 'object', properties: { summary: { type: 'string' }, conflicts: { type: 'array', items: { type: 'string' } } }, required: ['summary'] } })

const WRITERS = [
  { key: 'model', app: 'app-model' },
  { key: 'universal', app: 'app-universal' },
  { key: 'ident', app: 'app-ident' },
  { key: 'sound', app: 'app-sound' },
  { key: 'time', app: 'app-time' },
  { key: 'pa', app: 'app-pa' },
  { key: 'experiments', app: 'app-experiments' },
]

phase('Write')
const written = await parallel(WRITERS.map(w => () => agent(`You are the writer of section "${w.key}" of the paper in ${P}: write ${P}/sections/${w.key}.tex and ${P}/sections/${w.app}.tex (the appendix with full proofs and details). ${SOURCES}

First read ${P}/OUTLINE.md, ${P}/NOTATION.md and ${P}/CLAIMS.md (binding: use the unified notation and the macros in preamble.tex; state exactly the results the outline assigns to your section, with the statuses in the ledger; follow the conflict resolutions). Then read the source items for your section in full (the track notes, including proofs and verification logs) before writing.

Format: LaTeX for \\input into main.tex (no preamble); main text starts with \\section{...}\\label{sec:<key>} and the appendix with \\section{...}\\label{app:<key>} (keys as in OUTLINE.md). Main text: statements, intuition, short proofs or proof ideas with \\Cref to the appendix; appendix: full proofs (adapted from the notes, checked as you go — if you find an error in a proof, do not paper over it: write the result with a weaker status and report it in your return value), computation details, tables. Respect the page target. Put new references in ${P}/bib/${w.key}.bib (check core.bib first; never invent bibliographic data; mark anything you could not verify with a comment and hedge the claim). Figures, if any, go in ${P}/figures/ (only from existing results or scripts in ${ROOT}/code or the track checks; do not invent data). When done, run ./test-section.sh ${w.key} ${w.app} from ${P} until it compiles without errors.
${RULES}
Return: what you wrote, any errors or gaps you found in the sources, and labels other sections may reference.`, { label: `write:${w.key}`, phase: 'Write', schema: { type: 'object', properties: { summary: { type: 'string' }, problems: { type: 'array', items: { type: 'string' } }, labels: { type: 'array', items: { type: 'string' } } }, required: ['summary'] } })))

phase('Frame')
const problems = written.filter(Boolean).map((r, i) => `${WRITERS[i].key}: ${(r.problems || []).join(' | ')}`).join('\n')
const frame = await agent(`You are the framing editor of the paper in ${P}. ${SOURCES}
All body sections and appendices are written (sections/{model,universal,ident,sound,time,pa,experiments}.tex and their app-*.tex). Read OUTLINE.md, NOTATION.md, CLAIMS.md (especially "Answers to the question"), then every section file.
Write: ${P}/sections/abstract.tex (≤ 250 words, \\begin{abstract}...\\end{abstract}); ${P}/sections/intro.tex (\\section{Introduction}\\label{sec:intro}: the question verbatim, Hänni's note and its collapse argument in brief, the answers in brief with \\Cref pointers, contributions, what is not achieved, reader's guide; ≈4 pages); ${P}/sections/discussion.tex (\\section{Discussion}\\label{sec:disc}: what the answers mean for the user's proposal (template prior, derivation-length prior, time penalty), what a good version looks like and what it cannot promise, relation to literature, open problems collected from all tracks; ≈3 pages); ${P}/sections/app-verification.tex (\\section{How the results were established}\\label{app:ver}: tracks, adversarial referees with independent code, revisions; a table of corrections made during verification (every claim refuted or weakened by a referee, from the four verification logs); list of conjectures and open problems; unverified references; reproduction commands; the fact that all roles were separate Claude instances and no human checked the mathematics).
Writers reported these problems (address them in intro/discussion where relevant, and list unresolved ones in app-verification):
${problems}
Then run the full build: cd ${P} && flock /tmp/claude-0/paper-build-ai.lock ./build.sh ; fix every LaTeX error, undefined reference and undefined citation (you may edit any section file for this, minimally: fix labels/refs, not content); report remaining warnings. 
${RULES}
Return: page count, build status, and a list of remaining problems.`, { label: 'frame', phase: 'Frame', schema: { type: 'object', properties: { pages: { type: 'number' }, build: { type: 'string' }, problems: { type: 'array', items: { type: 'string' } } }, required: ['build'] } })

return { plan, written, frame }
