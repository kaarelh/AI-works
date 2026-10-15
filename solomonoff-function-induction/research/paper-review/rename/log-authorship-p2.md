# Log: authorship of Paper 2 (`paper-steeper/`), 2026-10-15

## The instruction

The author's instruction of 2026-10-15, verbatim:

> btw i think you should be listed as an author with me on all the papers, for the versions on github. still write these as if they were arxiv papers except for this. if we submit to arxiv at some point then we can change this. but i think having you as an author is just more correct and that seems important to get right at least where there's no constraint against it

The editor's brief fixed the author line, the footnote text, what the acknowledgements keep, how to replace "the author", and the folder name `solomonoff-operator-induction`. `bib/core.bib` was already updated and was not edited.

## Result

* **Full build** (`flock /tmp/claude-0/paper-build-sfi.lock ./build.sh`):
  * 0 LaTeX errors, 0 undefined references, 0 undefined citations, 0 multiply defined labels;
  * no overfull box above 10pt; the two below 3pt were there before;
  * 87 pages, as before.
* **First build.** After the first `build.sh`, `build3.log` still said "Label(s) may have changed". The new footnote changed the citations, so three passes were not quite enough.
  * One more `pdflatex` pass, run under the lock, converged: no warning, and `main.aux` was identical to the one before it.
  * A second `build.sh` was clean ("may have changed": 0 in `build3.log`). The figures above come from that build.
* **Numbering check:** `check_numbering.py aux-before/paper2-main.aux paper-steeper/main.aux` gives "241 labels before, 241 after, 0 differ".
* **Page 1** (`pdftotext -layout -f 1 -l 1`):
  * The author line is "Kaarel Hänni    Claude (Anthropic)∗".
  * The ∗ footnote at the foot of the page reads: "Claude is an AI system made by Anthropic. Claude produced the proofs, the computations and the text, under Kaarel Hänni's direction and starting from his questions and working notes (Hänni, 2026b). The results were checked by separate Claude instances acting as referees; no human has yet independently checked all of the mathematics. Companion paper: Hänni and Claude (Anthropic) (2026b)."
* **PDF metadata:** `pdfinfo` gives Author "Kaarel Hänni and Claude (Anthropic)".
* **Greps on `pdftotext main.pdf`:**
  * "the author": none.
  * `solomonoff-function-induction`: none. `solomonoff-operator-induction` appears in Code and data and in the companion paper's reference entry.
  * `SFI`: none.
  * Model names or versions (Opus, Sonnet, Haiku, "Claude <digit>"): none.
  * `function induction`: only in the reference-list entry of `hanni2026notes`, the allowed exception.

## Changes by file

**`main.tex`.**
* The author line is now `\author{Kaarel H\"anni \and Claude (Anthropic)\thanks{...}}`, with the `\thanks` on Claude. The footnote has four parts, in order:
  * "Claude is an AI system made by Anthropic."
  * The contribution statement as given.
  * The checking statement as given.
  * The existing pointer "Companion paper: \citet{claudeSFI2026fundamentals}."
* The old single-author footnote is gone.
* The `pdfauthor` field of `\hypersetup` is now "Kaarel H\"anni and Claude (Anthropic)", so the PDF metadata matches the printed author line. This is the author line in another form, so I counted it as part of item 1.
* One `.tex` comment line was added.

**`sections/discussion.tex`, Acknowledgements.**
* The first paragraph (Sam Eisenstat; Dmitry Vaintrob) is unchanged.
* In the second paragraph, the following were removed because the footnote now says them:
  * the AI-assistance sentence ("This paper was developed and written with extensive assistance from Claude (Anthropic), an AI system.");
  * "Working from the author's notes \citep{hanni2026notes} and under the author's direction, Claude produced the proofs, the computations and the text.";
  * "No human has yet independently checked all of the mathematics.", which the footnote's checking statement repeats word for word.
* The paragraph now reads:

  > Several of the questions and examples studied here first appeared in H\"anni's working notes \citep{hanni2026notes}, most of them in the note \citep{hanni2026grokking}, where the proposal also first appeared. Independent instances of Claude checked the proofs in two rounds and re-implemented the main computations, and the results were revised in response. The earlier report \citep{claude2026whatfollows}, whose results are re-derived here, was prepared in the same way. H\"anni takes responsibility for the content of this paper.

* **What was kept:**
  * The notes credit, with "those notes" changed to "H\"anni's working notes \citep{hanni2026notes}" as instructed.
  * The grokking-note credit.
  * The detailed checking sentence. It says more than the footnote: two rounds, re-implemented computations, revisions. Its opening "Further," was dropped because the sentence it continued is gone.
  * The credit to the earlier report.
* **Responsibility sentence.** "The author takes responsibility …" → "H\"anni takes responsibility …". "We" would not be true here: the responsibility is the human author's.
* **LessWrong.** Paper 2's acknowledgements never mentioned the LessWrong discussion. It is credited in the introduction's footnote, which is kept.
* **Code and data:** `\texttt{solomonoff-function-induction/}` → `\texttt{solomonoff-operator-induction/}`. Nothing else changed.
* One `.tex` comment line was added.

**`sections/intro.tex`, credit footnote.**
* "The proposal first appeared in the author's note \citep{hanni2026grokking}" → "… in H\"anni's note …".
* "The one-tape version of SOI first appeared in the author's working notes \citep{hanni2026notes}" → "… in H\"anni's working notes …".
* The LessWrong credit and the rest of the footnote are unchanged.
* One `.tex` comment line was added.

**`sections/kinks.tex`, change-of-slope footnote.** "first appeared in the author's note" → "first appeared in H\"anni's note". One `.tex` comment line was added.

**Nothing else changed:**
* no mathematics, statements or numbered environments;
* no other section file;
* not `bib/`, not `preamble.tex`.

## Left alone, by the brief

**`sections/app-verification.tex`** is not printed: `\sfirecordfalse`.
* **Line 129.** The phrase "personal communication to the author" quotes the text of a former bib entry, `hanni2026request`, which no longer exists. The sentence records why that entry was a problem. Changing the quotation would falsify the record, so it is left unchanged.
* **Line 7.** It still says "Paths are relative to `\texttt{solomonoff-function-induction/research/}`". The brief says to leave this file alone except for "author", so it is unchanged.
* **Flag:** if the record is ever printed after the folder is renamed, this path has to change.
