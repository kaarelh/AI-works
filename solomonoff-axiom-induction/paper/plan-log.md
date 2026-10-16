# Planning editor's log (paper on \SAI)

*2026-10-16. Folder `paper/`. Task: set up `paper/` so that section writers can work in parallel without conflicts: infrastructure, `NOTATION.md`, `OUTLINE.md`, `CLAIMS.md`, credit plan, stub build. No section prose was written.*

## 1. Restart check

At the start of this run `paper/` did not exist, so there was no partial output to recover. During the run the bibliography editor (working in parallel) created `paper/bib/` with `core.bib`, `refs.bib` and `bib-report.md`. This editor wrote nothing in `bib/` except the generated `bib/all.bib`.

## 2. What was read

* In full: `research/00-brief.md`; `research/notes-final.md` (the synthesis, all sections); `research/final-check.md`; `research/NOTATION-draft.md`; the companion papers' `REFRAME.md` and `DECISIONS.md` §0 and §A; the companion paper's `preamble.tex`, `main.tex`, `build.sh`, `test-section.sh`, `merge_bib.py`, and the first part of its `OUTLINE.md` and `CLAIMS.md` (format).
* From the seven thread final records: the summaries and claims-and-status tables (`fundamentals` §0.3, `sfi` §0 and §15, `logic` §0.3, `terms` §17, `shape` §12–§13, `laws` §13, `philosophy` §11 and §11.1); every statement line (grep of Theorem/Proposition/Corollary/Lemma/Definition/Remark headers) of `fundamentals`, `sfi`, `logic`, `terms`, `philosophy`; the setting and notation sections (`fundamentals` §1 and §13; `sfi` §1 and §12; `logic` §1 and §8; `terms` §1 and §12; `shape` §1 and §11; `laws` §11; `philosophy` §8); in full the statements of `fundamentals` Props 2.1–2.3, 5.2, 5.3, Thm 5.4 and `sfi` Thm 7.4.
* `research/prior/hanni-solomonoff-axiom-induction.md` (for the credit footnotes) and the list of files in `research/prior/`.
* `paper/bib/bib-report.md` §2.1–§2.2, §3, §4 (after the bibliography editor finished), to align the ledger's "how to state" constraints.
* The earlier report's `main.aux` and `sections/app-time.tex` (to confirm that the time follow-up and short-derivations results are printed there, so that they can be cited by printed number).

## 3. Files written

| file | content |
|---|---|
| `preamble.tex` | generic part adapted from the companion paper (packages incl. `xspace`, `tikz`, `multirow`; theorem environments with `\crefname` for every kind; a `question` environment; `\crefabbrev`); `\status` and `\src` print nothing and swallow the following space (an internal switch `\saishowstatustrue` prints them); the SAI macro block (every global symbol of NOTATION.md) |
| `main.tex` | title `\SAItitle:\\ Definitions, Basic Theorems, and What a Theory Is and Does` (synthesis option 1); `\author{Kaarel H\"anni \and Claude (Anthropic)\thanks{…}}` with the footnote of synthesis §5.2 (AI system made by Anthropic; Claude produced the proofs, computations and text under Hänni's direction, starting from his questions and working notes; checked by separate Claude instances acting as referees with independent code; no human has yet checked all of the mathematics; nothing verified in a proof assistant; no model version); `\input` of every section and appendix in the order of synthesis §5.3; App. J behind `\ifsairecord` (off) |
| `build.sh`, `test-section.sh` | as in the companion paper; lock file `/tmp/claude-0/paper-build-sai.lock`; the reports add BibTeX warnings and overfull boxes |
| `merge_bib.py` | merges `bib/*.bib` (priority) and `../research/refs.bib` (fallback only) into `bib/all.bib` by brace matching; reports title conflicts, cited keys missing everywhere, and cited keys supplied only by the fallback |
| `sections/*.tex` | 24 stubs (abstract, 13 sections, 10 appendices), each with its `\section` title and `sec:`/`app:` label |
| `NOTATION.md` | the final notation (§0–§10), the renames of record symbols (§11), and the decision on each request of synthesis §5.6 with its reason (§12) |
| `CLAIMS.md` | the ledger: 321 labelled rows (126 propositions, 44 theorems, 26 lemmas, 23 corollaries, 37 remarks, 21 definitions, 4 examples, 1 conjecture, 5 assumptions, 22 questions, 8 tables, 1 figure, 3 prose sections), each with statement, source item, status and its rendering, place, "how to state" and dependencies; global rules; the final-check corrections (§11); the open-question index (§12); items left out (§13) |
| `OUTLINE.md` | binding notes; rules for writers; the credit footnotes (§C); per section and appendix: file, contents in order, labels, cites from other sections, source items, credit; page budget (42.5 pp main); suggested writer groups with ownership and dependencies; running example; bibliography rules |
| `logs/` | empty folder for the writers' logs |

## 4. Decisions and adjustments to the synthesis plan

1. **The infinity separation is stated once** (synthesis H4(v) and §5.3 §8): `fundamentals` Prop 1.8(d), listed by the synthesis as `prop:basic:finite` in §3, becomes the one-line variant `rem:terms:named` after `thm:terms:infinity` in §8.
2. **The lottery between versions of consistent SOI** (`sfi` Cor 4.2), listed in §4 with "a forward pointer to §5", is placed in §5 as `cor:logic:versions`, since it depends on `thm:logic:lottery`; §4 points to it.
3. **Penalty results** `sfi` Thm 3.4 (one tape) and Thm 7.1 (coin-free) are one statement, `thm:soi:penalty` (a), (b); Prop 3.5 is `prop:soi:classes`.
4. **Assumptions** (S), (S$_{\rm tape}$), (F1), (B*), (SGL) are `assumption` environments (`ass:soi:*`), as the companion papers' DECISIONS §A1 requires for conditional results.
5. **Appendix J** ("how the results were checked") would need process vocabulary, which may not be printed; as in the companion papers (DECISIONS §A3), its file exists but is switched off (`\sairecordfalse`). The acknowledgements carry the account of checking.
6. **Labels added** beyond the synthesis lists: appendix items (proofs, lemmas, remarks, proof sketches split from proved parts), the 22 questions (`q:`), `def:soi:objects`, `def:terms:literal`, `def:terms:named`, `def:laws:setting`, `def:kepler:language`, `tab:phil:map`, `prop:basic:form`, `prop:basic:oracle`, `prop:basic:prcr`, `prop:shape:E2`, `prop:shape:bridge`, `prop:laws:copernicus`, `sec:kepler:newton`, and the Kepler examples and tables. Synthesis labels kept unchanged otherwise.
7. **Left out** (CLAIMS.md §13): `philosophy` Prop 2.3 (its part (c) is the ω-gap, already in §5), and the proof-sketched or withdrawn items listed there.
8. **Notation decisions beyond the requests** (NOTATION.md §12 items 16–18 and §11): derivation-size budget $s$ (not $d$, which is the word length and meets it in §4); the $\Th(\mathbb N)$ exponent $\xi$ (not $\delta$, the data precision); the extractor $\eta$ (not $g$, the material budget); the consistency event $\mathrm{Cons}^G$ and the binary theoretical relation $\mathsf C$ (the $C$ clash); the class superscript $\mathrm{base}$ and the classes $\mathcal E^{\rm base}_m$, $\mathcal E_m$ (the record's $X$, $\mathcal C^X$ clash with the literal target set and the class notation $\UA(\mathcal C;D)$); $\MFmw$ for the records' $M_F^C$; $\mathcal L_{\rm hel}$ for the Kepler data language; $\mathrm{Occ}_{\mathsf F}$.
9. **The title** uses `\SAItitle` (title case, "Solomonoff Axiom Induction"), so that the title reads correctly; `\SAI` prints the lower-case working name in prose. Both come from one definition each in `preamble.tex` (`\SAIname`, `\SAItitlename`).
10. **Bibliography.** The paper's entries are the bibliography editor's (`bib/core.bib`, `bib/refs.bib`); `merge_bib.py` uses `research/refs.bib` only as a fallback and reports keys that need the editor. The ledger's "how to state" lines were aligned with `bib/bib-report.md` (belief-function references, Demuth, the modified Demski prior, the SAT 2026 paper, the lottery's and Craig's novelty wording).
11. **Credit footnotes**: seven planned (F1–F7) and one spare (OUTLINE.md §C), each pointing to the note in `research/prior/` it credits; the condensation essay is not in the public notes repository, so F7 calls it an unpublished draft essay without a citation key.
12. **Process word in print.** The title-page footnote's "acting as referees" is required by the task and matches the companion papers; it is the only exception to the no-process-vocabulary rule (OUTLINE.md A.4).

## 5. Builds

* Full build: `cd paper && flock /tmp/claude-0/paper-build-sai.lock ./build.sh` → LaTeX errors 0, undefined references 0, undefined citations 0, multiply defined labels 0, overfull boxes 0, BibTeX warnings 0; 4 pages (stubs). `merge_bib.py`: 299 entries (6 from `core.bib`, 293 from `refs.bib`, 0 from the fallback), no title conflicts; the one cited key (`hanni2026notes`) is in `core.bib`.
* Isolated builds: `./test-section.sh` passes for every section/appendix pair (setting+app-basic, basic+app-basic, soi+app-soi, logic+app-logic, phil+app-phil, shape+app-shape, terms+app-terms, laws+app-laws, kepler+app-kepler, limits, intro, related, discussion+app-notation, abstract).
* `pdftotext main.pdf | grep -i -E 'thread|track|scout|referee|workflow|agent|record|synthesis'`: one hit, the mandated footnote.
* Cross-check script (inline, not saved): every label named in `OUTLINE.md` and `NOTATION.md` is a ledger row or a section label; every ledger row is placed in `OUTLINE.md`.

## 6. Points for the next steps

* **Writers**: start from `OUTLINE.md` §B and §F; one owner per file.
* **The repository table** in the root `CLAUDE.md` does not yet list `solomonoff-axiom-induction/`; it is added when the project is first published (a shared file; not changed here).
* **Acknowledgements**: the sentence "Hänni takes responsibility for the content of this paper" (OUTLINE.md §13) is for the author to confirm.
* **Python versions** for the Code and data statement are to be read from the thread records' verification logs (the Kepler computations need pyerfa).

## 7. Git

No git command was run.
