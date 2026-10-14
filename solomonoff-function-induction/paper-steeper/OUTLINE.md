# Outline: Paper 2, "Steeper Simplicity Priors in Solomonoff Function Induction: The Model–Randomness Split and the Teacher's Mistakes"

Restructured on 2026-10-13; fix round of the same day under `research/paper-review/restructure/DECISIONS-restructure.md`. The binding plan is `research/paper-review/restructure/PLAN.md` (structure, labels, notation, statuses, page budgets); framing and voice follow `research/paper-review/REFRAME.md`, the arXiv form `research/paper-review/DECISIONS.md`. The base version of every file is `git show dcb3a3a3:solomonoff-function-induction/paper-steeper/<path>`. The ledger of every numbered item is `CLAIMS.md`; notation is shared with Paper 1 (`../paper/NOTATION.md`) plus PLAN.md §4.

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

## Sections, files and pages

Pages measured on the full build after the fix round of 2026-10-13 (74 pages), in text-block pages between the heading positions (`pdftotext -bbox`); targets and caps from `research/paper-review/restructure/DECISIONS-restructure.md` §3 (tolerance ±0.15 per section), which supersede PLAN.md §6 and DECISIONS §C for this paper. The measurements before the fix round are in `log-front.md` §4.

| § | title | main file | appendix | target main / app | measured main / app |
|---|---|---|---|---|---|
| – | title, abstract, contents | `main.tex`, `abstract.tex` | – | 1.5 / – | 1.51 / – |
| 1 | Introduction (Theorems A–C informal, contributions, `tab:intro:claims`, reader's guide) | `intro.tex` | – | 3.2 / – | 3.28 / – |
| 2 | Related work | `related.tex` | – | 0.95 / – | 0.97 / – |
| 3 | Setting: data, hypothesis classes and steeper objectives | `setup.tex` | A `app-setup.tex` | 3.0 / 2.4 | 3.24 / 2.33 |
| 4 | What counts as one hypothesis: absorption and private randomness | `absorb.tex` | B `app-absorb.tex` | 2.9 / 4.4 | 3.00 / 4.30 |
| 5 | Kinks: the model–randomness split on one data set | `kinks.tex` | C `app-kinks.tex` | 2.5 / 2.1 | 2.55 / 2.07 |
| 6 | Exact model recovery from samples | `recovery.tex` | D `app-recovery.tex` + `app-split.tex` | 5.1 / 8.7 | 5.33 / 8.80 |
| 7 | The noisy random parity: one instance, two readings | `parity.tex` | E `app-parity.tex` | 3.8 / 6.3 | 3.84 / 6.37 |
| 8 | The teacher's mistakes: the split at a positive rate | `teacher.tex` | F `app-teacher.tex` | 5.3 / 7.0 | 5.42 / 7.30 |
| 9 | When errors have structure: a second kink (two subsections; §9.3 "Unseen properties" is now App G.4, `sec:limits:ood` an alias there) | `limits.tex` | G `app-limits.tex` | 2.1 / 4.0 | 2.32 / 3.80 |
| 10 | Computable hypothesis classes | `computable.tex` | H `app-related.tex` | 0.8 / 2.2 | 0.95 / 1.99 |
| 11 | Discussion, open problems, acknowledgements, code and data | `discussion.tex` | – | 2.0 / – | 2.10 / – |
| | **main text / references / appendices / total** | | | **33.15 (cap 33.5) / – / 37.1 (cap 37.5) / cap 73.5** | **34.50 / 2.33 / 36.96 / 73.79** |

The main text is 1.0 pp over its cap and the total 0.29 pp over (74 pages); the appendices are within theirs. Every part is within its target's tolerance except §3 (+0.24, of which 0.10 is white space at the bottom of p. 9 before §4), §6 (+0.23), §9 (+0.22), §10 (+0.15, at the edge) and App F (+0.30). Even with every section at its target the main text would be 33.15 pp, so the cap leaves 0.35 pp for page breaks and floats. The next candidates, which need the author's decision, are REJ-01, REJ-04 and REJ-05 (main text) and REJ-08 (appendices) of `research/paper-review/restructure/rejected.json`.

**Moved to the appendices in the fix round** (labels, statuses and sources unchanged; one-sentence pointers in the main text): `lem:setup:basic` (App A.2), `prop:absorb:pricing` (App B.4), `rem:recovery:window` (App D.4), the frozen-table failure probabilities (after `rem:recovery:frozentable`, App D), `prop:teacher:sharp` with the definitions of $\Phi_2^\sharp$ (App F.7), the text of §9.3 (App G.4), `prop:related:computability` (App H).

**Abstract.** The text of DECISIONS-restructure D9, verbatim (1920 characters of source between the environment lines).

Not input any more (one comment line each): `split.tex`, `algstat.tex`, `app-algstat.tex`. `app-verification.tex` is kept, switched off.

## Labels

Every label of the base survives under its own name, except the four cut items (`lem:split:hash`, `tab:algstat:numbers`, `rem:limits:method` and their `app:` subsections); moved labels and section aliases are listed in PLAN.md §3 and the writer logs. New theorem-like labels are those of PLAN.md §3.3, all created (the [V-T] items were verified). Front labels: `sec:intro`, `sec:related`, `sec:related:work`, `rem:related:posteriors`, `rem:related:cold`, `rem:related:mdl`, `rem:related:new`, `tab:intro:claims`, `sec:discussion`, `sec:discussion:open`, `tab:discussion:reasons` (new).

## Builds

* Isolated: `./test-section.sh <section> <appendix>` (undefined references to other sections expected).
* Full: `flock /tmp/claude-0/paper-build-sfi.lock ./build.sh`; acceptance: 0 LaTeX errors, 0 undefined references and citations, 0 multiply defined labels, no overfull box above 10 pt.
* `bib/core.bib` is byte-identical to `../paper/bib/core.bib`.
