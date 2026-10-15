# Outline: Paper 2, "Steeper Simplicity Priors in Solomonoff Operator Induction: The Model–Randomness Split and the Teacher's Mistakes"

Renamed on 2026-10-15 under `research/paper-review/rename/RENAME.md` (binding): Solomonoff operator induction (SOI) is the family; SOI without qualification is the one-tape version $M_F$; the subject is Solomonoff's per-query solution (his eq. (10), $M_{\rm pq}$, the class $\mathcal H_\times$) with a steeper prior. Log: `research/paper-review/rename/log-p2.md`.

Restructured on 2026-10-13; fix round of the same day under `research/paper-review/restructure/DECISIONS-restructure.md`. Imitation integration of 2026-10-14 (a new §10 with App H, the weight-decay remark and appendix, the caveats in the introduction and the discussion; log `research/paper-review/imitation-edit/log-integrate.md`). The binding plan is `research/paper-review/restructure/PLAN.md` (structure, labels, notation, statuses, page budgets); framing and voice follow `research/paper-review/REFRAME.md`, the arXiv form `research/paper-review/DECISIONS.md`. The base version of every file is `git show dcb3a3a3:solomonoff-function-induction/paper-steeper/<path>`. The ledger of every numbered item is `CLAIMS.md`; notation is shared with Paper 1 (`../paper/NOTATION.md`) plus PLAN.md §4.

## Binding notes (still in force)

* **Authorship.** Author line "Kaarel Hänni" alone; the title-page footnote and the acknowledgements disclose the assistance of Claude (Anthropic) and the AI checking (DECISIONS §A4).
* **arXiv form.** No status tags or source notes in the PDF (`\status`/`\src` print nothing; their content is rendered in prose); proofs or labelled proof sketches; computed numbers outside statements with "a direct computation (code in the accompanying repository) gives …"; κ = 0 numbers are illustrations; no process vocabulary; no verification appendix (`\sfirecordfalse`).
* **Framing.** The paper presents the material for the first time, in the "we" voice; the author's notes are credited in at most five neutral footnotes (two now: the proposal, `intro.tex`; the change of slope, `kinks.tex`) and in the acknowledgements. The absorption objection is a standard point, never attributed to a person; no mention of Wyeth (`rem:absorb:wyeth` keeps its label, title "Answer to the absorption objection").
* **Paper 1** cites this paper only as a whole; Paper 2 cites Paper 1 by number (`% P1:` comments; check with `research/paper-review/scratch/editor/check_companion_numbers.py`). Paper 1's numbering is frozen.

## The story

Two reasons for a complexity penalty steeper than the likelihood penalty (λ > 1), for hypotheses with private randomness at each input:
1. **First and main: the model–randomness split.** Per query, every λ-MAP is eventually a shortest program for the sampler (Theorem A, `thm:recovery:main`), with a margin rate for fixed λ > 1 that λ = 1 lacks; on one data set a kink at a sufficient program makes every λ between 1 and its steepness select it, up to windows (Theorem B, `cor:kink:split`); per-query samples have a kink of the same kind with high probability (`thm:recovery:kink`), and so does the noisy parity's full table at every dyadic flip rate below 1/4 for large d (`prop:parity:range`), while set models have no steep one (`prop:parity:sets`).
2. **Second: not learning a teacher's mistakes**, the split at a positive rate: an error rule is reused at many inputs, so λ must grow with n (Theorem C, `thm:teacher:main`; `lem:teacher:reuse`).

Absorption is the precondition of both; kinks are their common geometry; `tab:discussion:reasons` sets them side by side.

Two additions of 2026-10-14:
* **Imitation** (§10, `sec:imit`), a motivation for both reasons (private coins: the first; coins that the environment drives and the input partly reveals: a fixed λ returns a program for the data kernel, and near-copies are guaranteed for λ/n in a window above $2^{-m}$, as in the second): a person is a sampler, a copy a program with the person's kernel. When the person's coins are an incompressible function of a cell variable with many more values than the person has bits, hypotheses that model the environment predict better, yet for λ/n in a window every near-optimal private-randomness hypothesis is close to the person in behaviour (`thm:imit:main`); no procedure reliably copies persons that share a data law or a person entangled with its coupling (`prop:imit:limits`); cheap couplings defeat every c (`prop:imit:cheap`, App H).
* **λ = cn and weight decay** (`rem:teacher:weightdecay` in §8, `app:teacher:weightdecay` in App F): no fixed prior gives the cn-MAPs; a fixed weight-decay coefficient on an averaged loss is a Gaussian prior of precision nω and can keep a worse classifier in the limit; the analogy is one of objectives.

The introduction's paragraph "Scope" and the discussion's "What the toy cases leave open" state that the motivating problems are not solved, name the four toy cases solved and list six concrete open problems.

## Sections, files and pages

Pages measured on the full build after the imitation integration of 2026-10-14 (86 pages), in text-block pages between the heading positions (`pdftotext -bbox`, text block from y = 0.096 to 0.909 of the page height; the last appendix ends at its last text line), the method of `log-front.md` §4. Targets and caps from `research/paper-review/restructure/DECISIONS-restructure.md` §3, which were set before this integration; §10 and App H have no target there. The column "before" is the build of the same sources before the integration (74 pages, measured the same way; it reproduces `log-front.md`).

| § | title | main file | appendix | target main / app | before main / app | measured main / app |
|---|---|---|---|---|---|---|
| – | title, abstract, contents | `main.tex`, `abstract.tex` | – | 1.5 / – | 1.51 / – | 1.59 / – |
| 1 | Introduction (Theorems A–C informal, contributions, `tab:intro:claims`, Scope, Reader's guide) | `intro.tex` | – | 3.2 / – | 3.28 / – | 3.80 / – |
| 2 | Related work (new paragraph "Imitation and identifiability from behaviour") | `related.tex` | – | 0.95 / – | 0.97 / – | 1.36 / – |
| 3 | Setting: data, hypothesis classes and steeper objectives | `setup.tex` | A `app-setup.tex` | 3.0 / 2.4 | 3.24 / 2.33 | 3.25 / 2.29 |
| 4 | What counts as one hypothesis: absorption and private randomness | `absorb.tex` | B `app-absorb.tex` | 2.9 / 4.4 | 3.00 / 4.30 | 3.00 / 4.24 |
| 5 | Kinks: the model–randomness split on one data set | `kinks.tex` | C `app-kinks.tex` | 2.5 / 2.1 | 2.54 / 2.07 | 2.54 / 2.10 |
| 6 | Exact model recovery from samples | `recovery.tex` | D `app-recovery.tex` + `app-split.tex` | 5.1 / 8.7 | 5.33 / 8.80 | 5.33 / 8.82 |
| 7 | The noisy random parity: one instance, two readings | `parity.tex` | E `app-parity.tex` | 3.8 / 6.3 | 3.84 / 6.37 | 3.84 / 6.34 |
| 8 | The teacher's mistakes: the split at a positive rate (with `rem:teacher:weightdecay`) | `teacher.tex` | F `app-teacher.tex` (with `app:teacher:weightdecay`) | 5.3 / 7.0 | 5.42 / 7.31 | 6.04 / 9.33 |
| 9 | When errors have structure: a second kink | `limits.tex` | G `app-limits.tex` | 2.1 / 4.0 | 2.32 / 3.80 | 2.25 / 3.80 |
| 10 | Imitation: a sampler whose coins the environment drives (new) | `imit.tex` | H `app-imit.tex` (new) | – / – | – / – | 2.33 / 3.99 |
| 11 | Computable hypothesis classes (was §10) | `computable.tex` | I `app-related.tex` (was H) | 0.8 / 2.2 | 0.95 / 1.98 | 0.94 / 1.99 |
| 12 | Discussion, open problems, acknowledgements, code and data (was §11) | `discussion.tex` | – | 2.0 / – | 2.10 / – | 2.80 / – |
| | **main text / references / appendices / total** | | | **33.15 (cap 33.5) / – / 37.1 (cap 37.5) / cap 73.5** | **34.50 / 2.32 / 36.96 / 73.78** | **39.08 / 3.69 / 42.89 / 85.66** |

The integration adds 4.58 pp to the main text (§10 2.33, the weight-decay remark 0.62, the discussion 0.70, the introduction 0.52, related work 0.39, contents 0.08), 1.37 pp of references (19 new entries, `bib/imit.bib`) and 5.93 pp of appendices (App H 3.99, App F 2.02). All three caps of DECISIONS-restructure §3 are now exceeded (main text by 5.58 pp, appendices by 5.39 pp, total by 12.16 pp); they predate the author's request for this material, and nothing else was moved or cut. Candidates, all needing the author's decision, are listed in `log-integrate.md` §7, besides REJ-01, REJ-04, REJ-05 and REJ-08 of `research/paper-review/restructure/rejected.json`.

**After the fix round of 2026-10-14** (`research/paper-review/imitation-edit/log-fix.md`; same method): 87 pages; main text 39.76, references 3.63, appendices 43.28, total 86.66 (§1 3.97, §2 1.44, §3 3.22, §8 6.11, §10 2.44, §12 2.84; App F 9.33, App H 4.11, App I 2.21, the last from float placement). Nothing was moved or cut.

**Moved to the appendices in the fix round** (labels, statuses and sources unchanged; one-sentence pointers in the main text): `lem:setup:basic` (App A.2), `prop:absorb:pricing` (App B.4), `rem:recovery:window` (App D.4), the frozen-table failure probabilities (after `rem:recovery:frozentable`, App D), `prop:teacher:sharp` with the definitions of $\Phi_2^\sharp$ (App F.8), the text of §9.3 (App G.4), `prop:related:computability` (App I).

**Placed in App H by the compact cut of the imitation synthesis** (`research/tracks/imitation/notes-final.md` §5.3): `rem:imit:private` (H.1, with the paragraph on hypotheses that learn in context), the numerical illustrations and the range of $c$ outside the window (H.3), `prop:imit:limits`(c) and the cell count as the new `prop:imit:cheap` (H.5). The draft's `q:imit:open` is not in the paper; its questions are open problem (7). `tab:teacher:rates` was moved in the source of App F.8 (before the proof of `prop:teacher:rates`) so that the float stays in App F.

**Abstract.** The text of DECISIONS-restructure D9, verbatim (1920 characters of source between the environment lines); unchanged by the integration, since it claims nothing about imitation or weight decay and stays truthful.

Not input any more (one comment line each): `split.tex`, `algstat.tex`, `app-algstat.tex`. `app-verification.tex` is kept, switched off.

## Labels

Every label of the base survives under its own name, except the four cut items (`lem:split:hash`, `tab:algstat:numbers`, `rem:limits:method` and their `app:` subsections); moved labels and section aliases are listed in PLAN.md §3 and the writer logs. New theorem-like labels are those of PLAN.md §3.3, all created (the [V-T] items were verified). Front labels: `sec:intro`, `sec:related`, `sec:related:work`, `rem:related:posteriors`, `rem:related:cold`, `rem:related:mdl`, `rem:related:new`, `tab:intro:claims`, `sec:discussion`, `sec:discussion:open`, `tab:discussion:reasons` (new).

New labels of the imitation integration (2026-10-14; no existing label renamed): `sec:imit`, `def:imit:setting`, `thm:imit:main`, `prop:imit:limits`, `app:imit`, `app:imit:private`, `rem:imit:private`, `app:imit:lemmas`, `lem:imit:coding`, `lem:imit:closeness`, `app:imit:main`, `app:imit:limits`, `app:imit:cheap`, `prop:imit:cheap`; `rem:teacher:weightdecay`, `app:teacher:weightdecay`, `prop:teacher:nofixedprior`, `ex:teacher:weightdecay`. The section numbers of §10–§11 and the appendix letter H moved by one (now §11, §12, App I); Paper 1 cites Paper 2 only as a whole, and the companion check passes.

## Builds

* Isolated: `./test-section.sh <section> <appendix>` (undefined references to other sections expected).
* Full: `flock /tmp/claude-0/paper-build-sfi.lock ./build.sh`; acceptance: 0 LaTeX errors, 0 undefined references and citations, 0 multiply defined labels, no overfull box above 10 pt.
* `bib/core.bib` is byte-identical to `../paper/bib/core.bib`. The entries added on 2026-10-14 are in `bib/imit.bib` (eleven for weight decay, eight for imitation and identifiability), which `merge_bib.py` picks up.
