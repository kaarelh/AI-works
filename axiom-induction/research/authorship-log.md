# Authorship change log (2026-10-15)

The author's instruction, verbatim:

> btw i think you should be listed as an author with me on all the papers, for the versions on github. still write these as if they were arxiv papers except for this. if we submit to arxiv at some point then we can change this. but i think having you as an author is just more correct and that seems important to get right at least where there's no constraint against it

The report is now by Kaarel Hänni and Claude (Anthropic). The body was not reframed: third-person references to Hänni's question, notes, scores, schema, objection and proposal stay. Only sentences that became false or self-contradictory under joint authorship were changed, with minimal edits.

## Changes, file by file

### `paper/main.tex` (line 6)

**Author line.** Old: `\author{Claude (Anthropic)\thanks{...}}`. New: `\author{Kaarel H\"anni \and Claude (Anthropic)\thanks{...}}`. No model name or version appears.

**The `\thanks` footnote**, attached to Claude.

Old:

> Prepared for Kaarel H\"anni, in response to his question about Solomonoff-style axiom induction \citep{hanni2026notes}; a follow-up to the earlier reports \citetalias{claude2026whatfollows} \citep{claude2026whatfollows} and \citetalias{claude2026axiomschemas} \citep{claude2026axiomschemas}. Draft; authorship and publication are for him to decide. Code, research notes and referee reports: \texttt{axiom-induction/} in the accompanying repository.

New, in this order:

1. "Claude is an AI system made by Anthropic."
2. The contribution statement: "Claude did the research and wrote this report in response to questions posed by Kaarel H\"anni and under his direction." The report-specific facts of the old footnote are kept: "The first was his question about Solomonoff-style axiom induction \citep{hanni2026notes}; the report is a follow-up to the earlier reports \citetalias{claude2026whatfollows} \citep{claude2026whatfollows} and \citetalias{claude2026axiomschemas} \citep{claude2026axiomschemas}." ("Questions" is plural because the report also answers his later objection to the time-penalty summary and his proposal on short axioms, §6 and Appendix H.)
3. The checking statement, adapted to Appendix H and to item (vi) of §1: "The results were checked by separate Claude instances acting as referees and reviewers (\cref{app:ver}); no human has checked all of the mathematics, and nothing has been verified in a proof assistant." The referees (research tracks, follow-ups) and the whole-paper reviewers were all separate Claude instances (Appendix H, "What this means for the reader"). The wording matches the footnote of `../axiom-schemas/`.
4. The existing pointer: "Code, research notes and referee reports: \texttt{axiom-induction/} in the accompanying repository."

**Removed:** "Prepared for Kaarel H\"anni" and "Draft; authorship and publication are for him to decide."

### `paper/sections/intro.tex`

* **Line 96, §1.5, item (vi).** Old: "results added in revision were checked only by their authors and the section writers". New: "… checked only by their tracks and the section writers". "Their authors" meant the Claude instances of the research tracks. Under joint authorship it can be read as the report's authors, Hänni included, which would be false. "Their tracks" is the wording of Appendix H ("checked by their track").
* **Line 101, §1.6.** Old: "AS and IL, prepared for H\"anni, are cited by their own numbering." New: "AS and IL are cited by their own numbering." The bibliography now lists Hänni as an author of AS and IL, so "prepared for Hänni" contradicts it. Line 58 already introduces AS and IL as "two earlier reports".

### `paper/sections/time.tex` (line 143, §6.4)

* Old: "H\"anni objected to our summary ``The time penalty doesn't block your collapse argument''". New: "H\"anni objected to Claude's summary …". With "our" meaning both authors, Hänni would be objecting to his own summary, which was sent to him.
* Old: "our summary had conflated the two directions". New: "that summary had conflated the two directions".

### `paper/sections/app-verification.tex`

* **Line 113** (table of corrections, first column of the follow-up row). Old: "our summary to H\"anni; H\"anni". New: "Claude's summary to H\"anni; H\"anni". Same reason: "our summary to Hänni" is self-contradictory when Hänni is one of "us".
* **Line 176** (Appendix H, "The correction"). Old: "After the first version of this paper, our summary to H\"anni said:". New: "After the first version of this paper, Claude's summary to H\"anni said:".

### `paper/bib/core.bib`

The author field of the two own-report keys present was `{{Claude (Anthropic)}}` and is now `{H{\"a}nni, Kaarel and {Claude (Anthropic)}}`:

* `claude2026whatfollows` (line 10);
* `claude2026axiomschemas` (line 245).

`claude2026axiominduction` does not occur in any .bib file of this project. No other key and no other field was touched. `bib/time.bib` and `bib/experiments.bib` mention these keys only in comments, with no entries. `paper/bib/all.bib` was regenerated by `merge_bib.py` (80 entries, 0 title conflicts).

### `research/paper-review/scratch/r_build/bib/core.bib`

This file is a reviewer's build snapshot from the whole-paper review. The instruction covers every .bib file except generated `all.bib`, so the same two author fields (lines 10 and 245) were changed here. The rest of the snapshot (`main.tex`, `sections/`, the generated `bib/all.bib` and `main.bbl`) still holds the old wording. It was left as it is, as a dated review record. If the snapshot should stay a faithful record, this one file can be reverted.

### `README.md`

* **Line 3.** Old: "Claude (Anthropic) prepared it in response to a question from Kaarel Hänni (8 October 2026). The question asks whether there is a good Solomonoff-style axiom inducer, with three ingredients:". New: "Authors: Kaarel Hänni and Claude (Anthropic). Claude did the research and writing, in response to questions from Kaarel Hänni and under his direction. Submission is his decision." This is followed by a new paragraph: "The first question (8 October 2026) asks whether there is a good Solomonoff-style axiom inducer, with three ingredients:". The date and content of the question are kept.
* **Old line 10, removed:** "It is a draft. Authorship and publication are his to decide." "Submission is his decision" was kept, and moved next to the author line, because the old README said that publication was his to decide.
* **Answers in brief, item 5.** Old: "(An earlier summary of ours, "the time penalty doesn't block your collapse", conflated the two directions; Hänni pointed this out.)" New: "(An earlier summary from Claude, …)". This is the same self-contradiction as in §6.4 and Appendix H, and the same fix.
* **Unchanged:** "How it was produced", which says that all roles were separate Claude instances, that no human checked the mathematics and that nothing was verified in a proof assistant. The page count (147) is unchanged.

### Rebuild

Running `paper/build.sh` gave: LaTeX errors 0, undefined references 0, undefined citations 0, multiply defined labels 0, overfull hboxes >10pt 0, 147 pages.

On page 1, `pdftotext -layout` gives the author line "Kaarel Hänni   Claude (Anthropic)∗", in that order. Plain `pdftotext` prints Claude first only because of how it reads the two-column author block. The footnote shows on page 1 as written above. The own reports are now cited as "(Hänni and Claude (Anthropic), 2026a)" for AS and "… 2026b" for IL. They are listed as "Kaarel Hänni and Claude (Anthropic). …" in the bibliography. The aliases AS and IL are unchanged.

## Sentences flagged and left unchanged

These read oddly now, but they are not false or self-contradictory in the body text, or the rule for their file forbids the change.

1. **The bibliography fields beside the author field** (`paper/bib/core.bib`):
   * line 13, `claude2026whatfollows`: `howpublished = {Unpublished report prepared for K. H{\"a}nni}`;
   * line 248, `claude2026axiomschemas`: `note = {Draft report prepared for Kaarel H\"anni; ...}`.

   The PDF now prints "Kaarel Hänni and Claude (Anthropic). … Unpublished report prepared for K. Hänni" and "… Draft report prepared for Kaarel Hänni". This is self-contradictory. The instruction allows only the author field to change, so they were left. Suggested fix: drop "prepared for …" from both fields.
2. **Abstract:** "AI referees checked first versions; no human has checked the mathematics." The same holds for §1.5 (vi), "Nothing is checked in a proof assistant or by a human", and for Appendix H, "What this means for the reader": "No human has checked the mathematics." These are true as the record stands. With a human co-author, though, they now say that the co-author has not checked the mathematics. They are also stronger than the footnote's "no human has checked all of the mathematics". The two are consistent, but they differ.
3. **Abstract, first sentence:** "Kaarel H\"anni asked whether a Solomonoff-style inducer …". The abstract opens with its first-listed author in the third person. This is normal for citing a co-author's question, but it is noticeable in the abstract.
4. **§1.4 heading and first sentence** (`intro.tex` lines 54, 56): "The question as we read it, and the model" and "We read the question as asking for …". "We" now includes the person who asked the question.
5. **Appendix H, "The correction"** (`app-verification.tex` line 176): "He is right: the sentence conflated …". The report now judges a co-author's objection to a summary sent to him. This is still accurate, and it reads like a record of correspondence between the authors.
6. **§9.2, "H\"anni's note, point by point"** (`discussion.tex` lines 38–40): "His equivalence holds with the constant he expects …; his consistency argument needs two sorts or a sound assigner". The same goes for the verdicts in `time.tex` ("H\"anni's argument refuted in this reading", line 64) and `app-time.tex` ("This confirms H\"anni's informal separation", line 20). These evaluate the co-author's notes from outside. This is normal for third-person citation, but the effect accumulates.
7. **"ours"** in `app-ident.tex` line 26 ("the exact identity above is ours") and `app-universal.tex` line 50 ("The consistency condition in the score row is ours; the notes leave it implicit"). Here "ours" separates the paper from the research tracks' notes. It now also credits Hänni with these details, which Claude wrote.

## Outside the paper and README (not changed)

* `research/paper-review/` (reviews, issue lists, the `scratch/r_build/` snapshot's `main.tex` and `sections/intro.tex`, and the generated `all.bib` and `main.bbl`) quotes the old author line, footnote and bibliography fields. These are dated review records.
* `research/tracks/*` records were not searched for changes. They are dated research records and do not state the report's authorship.
