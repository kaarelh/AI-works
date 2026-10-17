# Front writer's log (abstract, §1, §13, Appendices I and J, full build)

*2026-10-17. Files written: `sections/abstract.tex`, `sections/intro.tex`, `sections/discussion.tex`, `sections/app-notation.tex` (Appendix I), `sections/app-verification.tex` (Appendix J, internal, switched off). `main.tex` needed no change. Outside my files: one minimal fix in `bib/refs.bib` (§6). No git command was run.*

## 1. Restart check

At the start of this run the five files were the planning editor's stubs (157–340 bytes) and there was no `logs/front.md`, so nothing from an earlier run had to be recovered. The log was created first and updated after each part.

## 2. What was read

* The brief `research/00-brief.md` (in full: the author's requests, the epistemic policy, the stances on "what a theory is" and "existing language", the authorship rule).
* The synthesis `research/notes-final.md`: §0, §1 (H1–H15, each "How to state it"), §2 (all, including §2.8), §3, §5 (plan, §5.2 front matter, §5.3, §5.7), §6 (open problems), §7, §8.3, §8.6–§8.7; `research/final-check.md` in full.
* The companion papers' `REFRAME.md` and `DECISIONS.md` §A (A1–A12); the companion paper's `abstract.tex`, `intro.tex` (first part) and `discussion.tex` (for form).
* `paper/OUTLINE.md` (§A–§C, front-owned parts of §D, §E–§H), `paper/CLAIMS.md` (§0, §1, §10–§13), `paper/NOTATION.md` (all), `paper/plan-log.md`, `preamble.tex`, `main.tex`, `build.sh`, `test-section.sh`, `bib/core.bib`, `bib/bib-report.md` (§1, §5).
* All nine writer logs (`logs/write-*.md`).
* All main-text section files in full: `setting`, `basic`, `soi`, `logic`, `phil`, `shape`, `terms`, `laws`, `kepler`, `limits`, `related`. Appendices: the statements that the front matter cites (e.g. `thm:shape:directions`, `prop:phil:conservation`, `prop:phil:flagpolesystem`, `prop:laws:strength`, `prop:laws:once`, `prop:laws:copernicus`, `thm:shape:learning`), every `question` label, and the places where the notation symbols are defined.
* `research/prior/good-concepts-are-concepts-that-support-inferences.md` (to approve credit footnote F8, §5).

## 3. What was written

### Abstract (`abstract.tex`, 249 words)
Carries, as synthesis §5.2 asks: the object (random theory emitted by a universal machine; prior = probability that it is consistent and proves the data; belief function with three outcomes); the version-by-version equivalence with consistent SOI and the transfer to labelled atoms of a fresh predicate; the lottery, and adversarially chosen true data concentrating the limit posterior on false theories (possibility result); the reasoner-relativity of shape for Boolean laws ("which program length cannot see"); the dilemma result on literal data with charged deduction; approximate laws as laws with calibrated error models; Kepler; the one-sentence upshot; a one-sentence summary of the checking footnote.
* **Decision:** OUTLINE §D says the checking statement is "not the abstract"; synthesis §5.2, which the task names as the model for the abstract, lists "the checking footnote's one-line summary". I followed the task and the synthesis with one short sentence ("Separate instances of Claude checked the proofs and computations; no human has yet checked all of the mathematics."). It is the last sentence and can be deleted without touching the rest if the author prefers the OUTLINE's form.
* "SOI" is produced by `\SOI`/`\SOIabbr`, the family name only by `\SAI`/`\SAIabbr`; the abbreviation is introduced at first use.

### Introduction (`intro.tex`, about 3.4 pages)
Opening paragraph with the two problems (what a theory does; what it is), the first-paragraph statement that "axiom" refers to the hypotheses and not to the induction axiom (NOTATION §0), and credit footnote **F3** (OUTLINE §C, wording as planned). Paragraphs: *The object*; *Raw data and questions* (with the four-step ladder, which `phil.tex` cites as "the ladder of §1" by `\cref{sec:intro}`; SAI on step 2, partial results on step 3, step 4 no handle; the base language is not an observation language in the logical empiricists' sense); *What a theory is* (Craig collapse as a theorem; the descriptive observation kept apart from the explanatory question, as agreed with the author); *A preview: Kepler's third law* (no content in heliocentric directions, content in geocentric directions, 11.3–14.7 bits against 115–375 bits of text, conditional on the code; the 1.6′–1.9′ miss, against plan94). §1.1 *Contributions* (`sec:intro:contrib`): eleven items in the order of OUTLINE §D, each with `\cref`s. §1.2 *What we do not claim* (`sec:intro:notclaim`). *Organisation* paragraph.
* **Length:** a first draft (saved in the scratchpad as `front/intro-long-v1.tex`, not part of the paper) had a contributions list with full hypotheses and ran to about 4.6 pages; the task asks for about 3 pages and "one line per main result", so the list was rewritten to one to three lines per item, with the sentence "the sections state them with their hypotheses". Every item keeps the qualifiers that `final-check.md` §4 restores (items 1, 2, 4, 5, 16): transfer only of results up to additive constants; declarative against procedural costs the factor m over the base variables or with one round, and at most 9 in written length only with intermediate concepts and unbounded rounds; the lottery with true data is a possibility result with adversarial data; "we do not claim these are the only cases" is not contradicted (the list makes no characterisation claim).
* **Wording checked against the statements** (selection): `thm:shape:directions` (1)–(2) for the factors m and 9; `prop:laws:errormodel`(c) (rate attained by $\MA$ only when the error distribution is computable; almost-sure statement in the section); `thm:basic:loss` (semimeasure convention, plus a constant); `thm:logic:soundness` (coin-free, $\PA\subseteq\Cn(B)$); `prop:logic:shape` ($\Q\subseteq\Cn(B)$); `prop:logic:omega` ("ω-incompleteness of the background plus the instances", as in `logic.tex`); `prop:phil:conservation`(d) (the raw gain equals the raw no-law predictor's loss on the question); `prop:phil:flagpolesystem` (direction recovered from simplicity only under a listing code, `phil.tex` wording); `thm:terms:dilemma`(ii)–(iv) (padded observational axiomatisations *with polynomial-time membership*; "polyadic theoretical relation or objects unlike every named one", the body's own phrasing); `thm:terms:regular` (unary predicates *and constants*, compatible with the named structure — kept in the long draft; the short list says "a finite theory needs ...", which is the contrapositive the body states).
* "We argue", not "we find", for the reading of claim D (an assessment, synthesis §2.8).

### Discussion (`discussion.tex`, about 1.3 pages plus acknowledgements and code and data)
*What the formalism shows* (synthesis §0 philosophy paragraph and §2.8, with the stance agreed with the author: the idealised formalism is neutral on what a theory is; shape matters only relative to a reasoner and a vocabulary, when the written theory is charged or the hypothesis class restricted — "or restricted" added because §8's gains for finite theories occur with free deduction). *What it cannot show* (the verdict of synthesis §2.7, without the word "verdict"; nothing realist; evaluation not discovery; not computable). §13.1 *Open problems* (`sec:discussion:open`): the five starred problems of synthesis §6 by `\cref` (`q:basic:domination`, `q:logic:computablefast`, `q:logic:soundness`, `q:shape:beyond`, `q:phil:declarative`), then one sentence citing **every other `q:` label** of CLAIMS.md §12 (17 labels; all 22 question labels of the paper are cited). *Directions*: ladder step 4; communities of reasoners; a costed-deduction mixture combining SAI with logical induction (`garrabrant2016logical`, cited in the body at the same level); a native treatment of statistical confrontation; smaller items of CLAIMS §12 (interventional asymmetry, a validated derivation of Kepler within tolerances from Newton, the Mars posterior with distances).
* **Acknowledgements** (`\section*`, in the table of contents): the sentence on Hänni's working notes; independent Claude instances re-derived the proofs and re-implemented the computations; the earlier report and the companion papers that are used were prepared and checked in the same way; no human has yet checked all of the mathematics, nothing verified in a proof assistant; "Hänni takes responsibility for the content of this paper" (**for the author to confirm**, as plan-log §6 notes). **No thanks to Sam Eisenstat or Dmitry Vaintrob:** `grep -i 'eisenstat\|vaintrob' sections/*.tex` finds nothing, so the body uses no work of theirs.
* **Code and data** (`\section*`): Python 3.11 with NumPy, SciPy and mpmath, pyerfa for the planetary computations (versions from the `logic`, `laws` and Kepler verification logs: Python 3.11.15, NumPy 2.4.6, SciPy 1.17.1, mpmath 1.3.0, pyerfa 2.0.1.5); folder `solomonoff-axiom-induction/` of https://github.com/kaarelh/AI-works; re-running reproduces the saved outputs apart from run-time lines (synthesis §8.6: 43 of 47 scripts re-run, 29 byte-identical, 14 identical apart from a run-time line); the longest Mars-pool computations take more than half an hour each and were also reproduced by independent code. **For publication:** the sentence "its README lists the script behind each reported number" is a commitment for the project README, which does not exist yet.

### Appendix I (`app-notation.tex`, about 4 pages)
A `longtable` (symbol, meaning, where, with `\crefabbrev`) in nine groups, built from NOTATION.md §1–§9 and checked against the definitions as they stand in the section files. `\Kpad`, `\Omtail`, `\Kt` and $K^q$ are used in the body without a displayed definition; the table gives their definitions and points to their first use. No process words.

### Appendix J (`app-verification.tex`, internal; `\sairecordfalse`, not printed)
J.1 the process (seven threads, two referees each with independent code, the revision round with examples of corrections, the synthesis and its script re-runs, the final check's 19 corrections and three byte-identical re-runs, the planning editor, the bibliography checks and their levels, the section writers' weakening corrections, the front matter); J.2 what was not checked (no proof assistant; no human check of all the mathematics; references at the levels of `bib-report.md`; the modified Demski prior only through published descriptions; novelty at search level; results of the earlier report and the companion papers not re-derived; the assumptions (S), (S_tape), (F1), (B*), (SGL) not proved; computations add no evidence beyond the proofs; the philosophy is argument); J.3 a status table of **every main-text result by label** (127 rows: 110 theorem-like environments, 9 labelled paragraphs, 8 tables and figures — every `\begin{theorem|proposition|...}` and every `\paragraph{..}\label{..}` of the eleven main-text files), with the printed number (`\cref`), the label, the `\status` argument and the `\src` argument. The rows were generated by a script from the section files (`statustable.py` in the scratchpad folder `front/tools/`, not part of the repository) so that they show exactly what the sources record; if a section changes, regenerate them. Checked by building a scratch copy of the paper with `\sairecordtrue`: 235 pages, 0 errors, 0 undefined references, 0 overfull boxes above 10pt (two column-width fixes made for this).

## 4. Credit footnotes

Eight in all (OUTLINE §C allows at most eight): F1 `setting.tex`, F2 `soi.tex`, **F3 `intro.tex` (mine)**, F4 `shape.tex`, F5 `logic.tex`, F6 `laws.tex`, F7 `limits.tex` (no key), F8 `terms.tex`. **F8 approved:** the factoring footnote ("The idea of introducing a concept that factors a complete bipartite pattern of inferences first appeared in Hänni's working notes") credits `research/prior/good-concepts-are-concepts-that-support-inferences.md`, whose second paragraph states exactly that idea (a complete bipartite subgraph of inferences $A_i\Rightarrow B_j$ factored through a new property $X$). The acknowledgements carry the general sentence; nothing else in the running text cites the notes.

## 5. Full build

`cd paper && flock /tmp/claude-0/paper-build-sai.lock ./build.sh` (run four times; the first run left "Label(s) may have changed", the later runs are settled):

| check | result |
|---|---|
| LaTeX errors | 0 |
| undefined references | 0 |
| undefined citations | 0 |
| multiply defined labels | 0 |
| overfull boxes above 10pt | 0 (largest: 8.4pt in `app-laws.tex`, 5.2pt in `kepler.tex`; none in the front files after the fix below) |
| BibTeX | 1 warning (the intentional empty publisher of `shapiro1991inductive`; `build.sh` counts 2 lines) |
| `merge_bib.py` | 299 entries, 223 cited keys, 0 missing, 0 from the fallback |
| other warnings | "Float too large for page by 0.895pt" for Table 1 (`soi.tex`, line 247): harmless, not fixed (not my file, not on the build criteria) |
| pages | 230 |

**Page counts (final build):**

| part | pages |
|---|---|
| title page, abstract, contents | p. 1 to the top of p. 2 |
| **main text** §1–§13 with acknowledgements and code and data | **pp. 2–71 (about 69.5 pages)** |
| **references** | **pp. 71–84 (about 13 pages; 223 entries)** |
| **appendices** A–I | **pp. 84–230 (about 146.5 pages)** |

Section start pages: §1 2, §2 6, §3 10, §4 17, §5 27, §6 33, §7 39, §8 45, §9 51, §10 57, §11 63, §12 66, §13 69; App. A 84, B 104, C 124, D 143, E 149, F 170, G 192, H 216, I 226. Front files: §1 about 3.4 pages (budget 3), §13 with acknowledgements and code and data about 2 pages (budget 1; the open-problem list must cite every question label), Appendix I about 4 pages. **The main text is about 27 pages over the OUTLINE budget of 42.5 pages**; the overrun is in the section files (each writer's log lists the cuts it proposes) and is for the planning editor.

**Greps on the PDF text** (`pdftotext main.pdf`): `thread|track|scout|referee|workflow|agent|record|synthesis|ledger|brief|notes-final|verdict|revision|snippet|unverified|abstract level|not checked` gives only the mandated title-page footnote ("acting as referees"), "In brief" (`laws.tex`), "revision of the base abstractions" (`limits.tex`, `discussion.tex`), "program synthesis" (related work and a bibliography title), "Intelligent Agent Foundations Forum" (a bibliography entry), "tracks of one tape" (a technical use in `app-terms.tex`) and "every verdict below" (`app-laws.tex`, ordinary English; not changed). One hit in my own text, "Other answers are on record", was reworded. No model names or versions (`opus|sonnet|haiku|claude-[0-9]|gpt|gemini`: no hit). No "??". No printed status tag (the only `[...]`-hit is the formula P[not proved]).

## 6. Fixes outside my files (minimal; recorded here)

* `bib/refs.bib`, entry `belnap1976logic`: the author field `Belnap, Nuel D., Jr. and Steel, Thomas B., Jr.` made BibTeX print "Jr. Belnap, Nuel D. and Jr. Steel, Thomas B."; changed to the BibTeX form `Belnap, Jr., Nuel D. and Steel, Jr., Thomas B.` (prints "Nuel D. Belnap, Jr. and Thomas B. Steel, Jr."). No other field touched. (The bibliography editor owns `bib/`.)
* No section file of another writer was changed.

## 7. Items for others

* **Planning editor:** the main-text overrun (§5); `related.tex` was written by the limits group (OUTLINE assigned it to the front group; I did not change it); CLAIMS §10's "intro" row is rendered; the generated status table of App. J replaces a hand-kept list.
* **Author (Hänni):** confirm "Hänni takes responsibility for the content of this paper"; decide whether the abstract keeps its last (checking) sentence (§3); confirm the title (synthesis §5.1 option 1 is in `main.tex`).
* **Publication:** the project README must list the script behind each reported number (promised by the Code and data statement); the root `CLAUDE.md` table should get `solomonoff-axiom-induction/` when the project is first published (plan-log §6).

## 8. Final greps on my files

The OUTLINE B.11 pattern, run on `abstract.tex`, `intro.tex`, `discussion.tex` and `app-notation.tex` outside `%` comments, `\status`/`\src` arguments and citation keys: one hit, "the revision of the base abstractions" (legitimate). `app-verification.tex` is internal and uses process vocabulary by design. No `\newcommand` in my files. Isolated builds: `./test-section.sh intro`, `./test-section.sh discussion app-notation`, `./test-section.sh discussion app-verification`, `./test-section.sh abstract`: all OK, 0 errors, 0 undefined citations, 0 overfull boxes above 10pt.
