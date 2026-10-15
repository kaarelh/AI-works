# Check of the authorship edit, both papers (fresh checker, 2026-10-15)

## What was checked

**The instruction** (Kaarel Hänni, 2026-10-15, verbatim):

> btw i think you should be listed as an author with me on all the papers, for the versions on github. still write these as if they were arxiv papers except for this. if we submit to arxiv at some point then we can change this. but i think having you as an author is just more correct and that seems important to get right at least where there's no constraint against it

**The editors' logs:** `log-authorship-p1.md` and `log-authorship-p2.md`.

**Base of the diff.** The working tree was clean when I started: the edits were already in the WIP commits 262bce1c and e03bf186. So I reviewed `git diff 0c164cc5 -- paper paper-steeper` (0c164cc5 is the rename commit) against the working tree, with a word diff of every `.tex` file. I also compared the PDF text before (the PDFs of 0c164cc5) and after, as a multiset of words.

## 0. Result

| item | Paper 1 (`paper/`) | Paper 2 (`paper-steeper/`) |
|---|---|---|
| 1. Author line | `\author{Kaarel H\"anni \and Claude (Anthropic)\thanks{...}}`, exactly as specified. `pdfauthor` matches. | Same. |
| 2. Footnote | On Claude. It has the four parts, word for word as specified, in order. | Same. Companion pointer to `claudeSFI2026fundamentals`. |
| 3. Acknowledgements | The AI-assistance and "Working from …" sentences are gone. The Eisenstat, Vaintrob and notes credits are kept, the notes credit as "in H\"anni's working notes \citep{hanni2026notes}". Code and data has the new folder name. **One fix**, F1 below. | The same sentences are gone, and so is the verbatim duplicate "No human has yet …". The Eisenstat, Vaintrob, notes and grokking-note credits are kept, and so is the `claude2026whatfollows` credit. Code and data has the new folder name. |
| 4. "The author" | 9 footnotes: intro ×2, setting, versions, hist, ood, comp, nn, steeper. Plus 2 in the acknowledgements: the notes credit and "H\"anni takes responsibility". All are true. | 3 footnotes: intro ×2, kinks. Plus the same 2 in the acknowledgements. All are true. |
| 5. Folder name | Code and data updated. No printed or URL mention of the old name is left. | Same. |
| 6. Nothing else | Prose only; no math token changed in any `.tex` file. | Same. |
| 7. Build | 0 errors, 0 undefined references and citations, 0 multiply defined labels, 0 overfull boxes above 10pt (largest 1.84pt), no "may have changed"; 93 pages. | The same counts (largest overfull box 2.75pt), no "may have changed"; 87 pages. |
| Numbering | `check_numbering.py`: 314 labels before, 314 after, 0 differ. | 241 before, 241 after, 0 differ. |
| 8. Rules | No git command that changes repository state was run. | Same. |

**Truthfulness against the README** ("How it was produced", and the authors paragraph). The footnote and the acknowledgements match it in both papers.
* "Claude produced the proofs, the computations and the text, under Kaarel Hänni's direction and starting from his questions and working notes" matches two README statements:
  * "Claude did the research and writing, in response to questions from Kaarel Hänni and under his direction … He also listed specific questions and examples";
  * the copies of his notes in `research/prior/`.
* "The results were checked by separate Claude instances acting as referees" matches "All roles were played by separate Claude instances" and the refereed tracks and reviews.
* "No human has yet independently checked all of the mathematics" matches "No human has checked all of the mathematics".
* "Hänni takes responsibility for the content of this paper" keeps the old sentence's meaning. "We" would not be true, because the responsibility is the human author's.
* Nothing credits Claude with a construction that the papers attribute to others. The Eisenstat example and the conjunction-ladder construction from the slides keep their credits.

## 1. Greps on `pdftotext main.pdf` (fresh builds)

| grep | Paper 1 | Paper 2 |
|---|---|---|
| "the author" | 0 | 0 |
| "author", any case | 0 | 0 |
| Opus, Sonnet, Haiku, Fable, `claude-` (case-insensitive) | 0 | 0 |
| `solomonoff-function-induction` | 0 | 0 |
| `solomonoff-operator-induction` | Code and data; the companion's reference entry | Same |
| `SFI` | 0 | 0 |
| "function induction" | The setting footnote and the notes' reference entry (both allowed) | The notes' reference entry |

The same model-name grep found nothing in the diff, in the papers' `.tex` and `.bib` sources, or in the two editor logs. The only `claude-` hits there are the path `/tmp/claude-0/...`.

**Page 1** (`pdftotext -layout -f 1 -l 1`), both papers. The author line is "Kaarel Hänni    Claude (Anthropic)∗". The ∗ footnote reads: "Claude is an AI system made by Anthropic. Claude produced the proofs, the computations and the text, under Kaarel Hänni's direction and starting from his questions and working notes (Hänni, 2026b). The results were checked by separate Claude instances acting as referees; no human has yet independently checked all of the mathematics. Companion paper: Hänni and Claude (Anthropic) (2026)." In Paper 2 the pointer reads "(2026b)", because Paper 2 also cites `claude2026whatfollows`, now by the same authors.

**PDF-text diff** against the rename commit. The only word changes are:
* the author block and the footnote;
* the acknowledgements;
* "the author's" → "Hänni's";
* citation labels that moved because the companion papers and `claude2026whatfollows` now have two authors: "Hänni, 2026a" → "Hänni and Claude (Anthropic), 2026", and the notes from 2026c to 2026b;
* the folder name;
* math tokens that pdftotext splits differently after line breaks moved. The `.tex` word diff confirms that no math changed.

## 2. Fix made

**F1 (Paper 1, `sections/discussion.tex`, acknowledgements).**
* The change: "… \citep{hanni2026notes}. Further, independent instances of Claude checked each part: …" → "… \citep{hanni2026notes}. Independent instances of Claude checked each part: …".
* Why: "Further" continued the deleted sentence "Claude produced the proofs, the computations and the text". After the notes credit it no longer connects. Paper 2's editor made the same change for the same reason. One word; nothing else changed.

After F1 both papers were rebuilt with `flock /tmp/claude-0/paper-build-sfi.lock ./build.sh`, and the numbering checks were rerun. The figures in §0 and §1 come from those builds. Paper 2's sources are unchanged; its rebuild only refreshed `main.pdf`.

## 3. Points checked and accepted as they are

* **"No human has yet …", Paper 1.** Paper 1's acknowledgements keep "No human has yet independently checked all of the mathematics, and readers should weigh the results accordingly." This half-repeats the footnote. Paper 2 removed its verbatim duplicate. Both are within item 3, which lists only the two sentences to remove, and Paper 1's sentence carries the extra caution. Not changed.
* **"Prepared in the same way", Paper 2.** "The earlier report …, whose results are re-derived here, was prepared in the same way." It still reads correctly as "in the same way as this paper", and the report now has the same two authors.
* **LessWrong credit.** Paper 1's printed text never credited the LessWrong discussion: it is cited only in the unprinted `app-verification.tex`. Paper 2 credits it in the intro footnote, which is unchanged except for "H\"anni's".
* **`pdfauthor`.** Both editors changed it to "Kaarel H\"anni and Claude (Anthropic)". It is the author line in metadata form, so it is part of item 1.
* **Paper 1, `app-verification.tex`** (not printed). The two person-"author" edits are correct:
  * "which H\"anni supplied later";
  * the shared-bibliography item, which now says truthfully that both `core.bib` copies name both authors. I confirmed with `diff` that the two `core.bib` files are identical.

  Left alone, correctly:
  * "Results checked by their authors only", which is about the research tracks;
  * "once H\"anni is the sole author", which is about a possible arXiv conversion;
  * the two `\texttt{solomonoff-function-induction/research/...}` paths.
* **Paper 2, `app-verification.tex` line 129** (not printed). "Personal communication to the author" quotes the text of a former bib entry. Leaving the quotation is right.
* **Comments.** The `.tex` comment lines that Paper 2's editor added contain no model name.

## 4. For the lead editor (outside this check's files; not changed)

* **README page count.** `README.md` gives Paper 1 as "90 pages: a 44-page main text". The PDF has had 93 pages since the rename commit (0c164cc5 already had 93), and the references start on page 47. Paper 2's "87 pages: a 40-page main text" is correct.
* **`paper/OUTLINE.md`.** Its "BINDING NOTE (authorship, 2026-10-12)" still says Hänni is the sole author. The instruction of 2026-10-15 supersedes it. (Also flagged in `log-authorship-p1.md`.)
* **Paths after the folder rename.** Both unprinted `app-verification.tex` files still give paths under `solomonoff-function-induction/research/`. They need updating if the record is ever printed after the folder is renamed.
