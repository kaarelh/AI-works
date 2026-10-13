# Outline: Paper 2, "Steeper Simplicity Priors in Solomonoff Function Induction: The Model–Randomness Split and the Teacher's Mistakes"

Restructured on 2026-10-13. The binding plan is `research/paper-review/restructure/PLAN.md` (structure, labels, notation, statuses, page budgets); framing and voice follow `research/paper-review/REFRAME.md`, the arXiv form `research/paper-review/DECISIONS.md`. The base version of every file is `git show dcb3a3a3:solomonoff-function-induction/paper-steeper/<path>`. The ledger of every numbered item is `CLAIMS.md`; notation is shared with Paper 1 (`../paper/NOTATION.md`) plus PLAN.md §4.

## Binding notes (still in force)

* **Authorship.** Author line "Kaarel Hänni" alone; the title-page footnote and the acknowledgements disclose the assistance of Claude (Anthropic) and the AI checking (DECISIONS §A4).
* **arXiv form.** No status tags or source notes in the PDF (`\status`/`\src` print nothing; their content is rendered in prose); proofs or labelled proof sketches; computed numbers outside statements with "a direct computation (code in the accompanying repository) gives …"; κ = 0 numbers are illustrations; no process vocabulary; no verification appendix (`\sfirecordfalse`).
* **Framing.** The paper presents the material for the first time, in the "we" voice; the author's notes are credited in at most five neutral footnotes (two now: the proposal, `intro.tex`; the change of slope, `kinks.tex`) and in the acknowledgements. The absorption objection is a standard point, never attributed to a person; no mention of Wyeth (`rem:absorb:wyeth` keeps its label, title "Answer to the absorption objection").
* **Paper 1** cites this paper only as a whole; Paper 2 cites Paper 1 by number (`% P1:` comments; check with `research/paper-review/scratch/editor/check_companion_numbers.py`). Paper 1's numbering is frozen.

## The story

Two reasons for a complexity penalty steeper than the likelihood penalty (λ > 1), for hypotheses with private randomness at each input:
1. **First and main: the model–randomness split.** Per query, every λ-MAP is eventually a shortest program for the sampler (Theorem A, `thm:recovery:main`), with a margin rate for fixed λ > 1 that λ = 1 lacks; on one data set a kink at a sufficient program makes every λ between 1 and its steepness select it (Theorem B, `cor:kink:split`); samples and the noisy parity's full table have such kinks.
2. **Second: not learning a teacher's mistakes**, the split at a positive rate: an error rule is reused at many inputs, so λ must grow with n (Theorem C, `thm:teacher:main`; `lem:teacher:reuse`).

Absorption is the precondition of both; kinks are their common geometry; `tab:discussion:reasons` sets them side by side.

## Sections, files and pages

Pages measured on the full build of 2026-10-13 (75 pages) from the heading positions; budgets from PLAN.md §6.

| § | title | main file | appendix | budget main / app | measured main / app |
|---|---|---|---|---|---|
| – | title, abstract, contents | `main.tex`, `abstract.tex` | – | 1.25 / – | 1.51 / – |
| 1 | Introduction (Theorems A–C informal, contributions, `tab:intro:claims`, reader's guide) | `intro.tex` | – | 2.25 / – | 3.38 / – |
| 2 | Related work | `related.tex` | – | 0.75 / – | 0.97 / – |
| 3 | Setting: data, hypothesis classes and steeper objectives | `setup.tex` | A `app-setup.tex` | 2.25 / 2.5 | 3.49 / 2.09 |
| 4 | What counts as one hypothesis: absorption and private randomness | `absorb.tex` | B `app-absorb.tex` | 2.25 / 3.5 | 3.40 / 3.85 |
| 5 | Kinks: the model–randomness split on one data set | `kinks.tex` | C `app-kinks.tex` | 2.25 / 1.75 | 2.57 / 2.10 |
| 6 | Exact model recovery from samples | `recovery.tex` | D `app-recovery.tex` + `app-split.tex` | 4.75 / 7.0 | 5.80 / 8.27 |
| 7 | The noisy random parity: one instance, two readings | `parity.tex` | E `app-parity.tex` | 2.5 / 3.75 | 4.31 / 6.46 |
| 8 | The teacher's mistakes: the split at a positive rate | `teacher.tex` | F `app-teacher.tex` | 4.75 / 4.5 | 6.12 / 6.38 |
| 9 | When errors have structure: a second kink | `limits.tex` | G `app-limits.tex` | 1.75 / 2.75 | 2.43 / 4.05 |
| 10 | Computable hypothesis classes | `computable.tex` | H `app-related.tex` | 0.5 / 1.25 | 1.12 / 1.99 |
| 11 | Discussion, open problems, acknowledgements, code and data | `discussion.tex` | – | 1.5 / – | 2.30 / – |
| | **main text / references / appendices** | | | **26.75 / – / 27.0** | **37.40 / 2.38 / 35.19** |

Not input any more (one comment line each): `split.tex`, `algstat.tex`, `app-algstat.tex`. `app-verification.tex` is kept, switched off.

## Labels

Every label of the base survives under its own name, except the four cut items (`lem:split:hash`, `tab:algstat:numbers`, `rem:limits:method` and their `app:` subsections); moved labels and section aliases are listed in PLAN.md §3 and the writer logs. New theorem-like labels are those of PLAN.md §3.3, all created (the [V-T] items were verified). Front labels: `sec:intro`, `sec:related`, `sec:related:work`, `rem:related:posteriors`, `rem:related:cold`, `rem:related:mdl`, `rem:related:new`, `tab:intro:claims`, `sec:discussion`, `sec:discussion:open`, `tab:discussion:reasons` (new).

## Builds

* Isolated: `./test-section.sh <section> <appendix>` (undefined references to other sections expected).
* Full: `flock /tmp/claude-0/paper-build-sfi.lock ./build.sh`; acceptance: 0 LaTeX errors, 0 undefined references and citations, 0 multiply defined labels, no overfull box above 10 pt.
* `bib/core.bib` is byte-identical to `../paper/bib/core.bib`.
