# Authorship change: fresh check (2026-10-15)

This check covers `inferential-learning/`, `axiom-schemas/` and `axiom-induction/`. The editors' logs are `research/authorship-log.md` in each folder.

The author's instruction, verbatim:

> btw i think you should be listed as an author with me on all the papers, for the versions on github. still write these as if they were arxiv papers except for this. if we submit to arxiv at some point then we can change this. but i think having you as an author is just more correct and that seems important to get right at least where there's no constraint against it

**Method.** For each project I did the following:
* read `git diff -- <project>` against HEAD;
* read the editor's log;
* compared the footnote with the README's section on how the work was produced, and with the paper's own verification section;
* grepped the diff, the logs, `main.tex`, the README and the rebuilt PDF for `Opus|Sonnet|Haiku|Fable|claude-`;
* grepped the sources for leftover phrasing ("prepared for/by", "to decide", "the author", "authors'", "our summary", "draft");
* rebuilt with `paper/build.sh`;
* read page 1 with `pdftotext -layout -f 1 -l 1`.

No git command that changes repository state was run.

**Result.** All six items are done in all three projects. Apart from generated build output, the only change outside the six items is one line-break hint in `axiom-schemas` (see below). No mathematics changed and no project was reframed. **I made no fixes.** Some issues remain, but they are outside what the binding instructions let an editor change; they are listed at the end.

---

## inferential-learning

| item | status |
|---|---|
| 1. Author line | `\author{Kaarel H\"anni \and Claude (Anthropic)\thanks{...}}`. No model name or version appears. |
| 2. Footnote | The order is correct: "Claude is an AI system made by Anthropic." comes first. Then the contribution statement, with the report-specific attributions kept: the design and success criteria in §1.1 are his, the quotations are verbatim and cited by file path, and "the readings … are ours". Then the checking statement, adapted to §1.3 and Appendix K (referees, re-checks, Lean). The old footnote had no repository pointer, so none was carried over. "Prepared in response to …" and "Draft; authorship and publication to be decided by him" are gone. |
| 3. Body | One edit, in `physics.tex` §11. "…and leave the decision about publication to the author of the notes" was cut. With Hänni among "we", the clause was self-referential, and it repeated the "publication is his" statement that the footnote dropped. The README keeps "Submission is his decision", so the fact survives. The edit is minimal. |
| 4. README | The sentence matches the template word for word, followed by "Submission is his decision". The old README said that publication was his to decide. The section "How the results were established" is unchanged. |
| 5. Bib | None of the three keys occurs in any .bib file of the project (confirmed with grep). No change was needed and none was made. |
| 6. Build | 0 LaTeX errors, 0 undefined references, 0 undefined citations, 0 multiply defined labels, 274 pages. Page 1 shows "Kaarel Hänni   Claude (Anthropic)∗", and the footnote reads as in `main.tex`. |

**Footnote truth.** The footnote says that every main result was attacked by referees, and repaired and re-checked where needed. The README says: "Referees tried to refute every main result. Problems were repaired, then re-checked by fresh referees." §1.3 agrees. The Lean claim matches the README and Appendix K. "Separate Claude instances" matches §1.3 ("many cooperating instances of a language model"). Nothing in the footnote is false.

## axiom-schemas

| item | status |
|---|---|
| 1. Author line | Correct. No model name or version appears. |
| 2. Footnote | The order is correct: AI system, then the contribution statement (questions with `hanni2026notes` kept, and the follow-up to the parent report), then the checking statement, then the existing pointer `axiom-schemas/`. The checking statement is adapted to Appendix G: referees and reviewers were Claude instances, and nothing was verified in a proof assistant. "Prepared for Kaarel Hänni" and "Draft; authorship and publication…" are gone. |
| 3. Body | In seven places "the author('s)" or "the authors'" meant the Claude instance that wrote a track. These became "the researcher('s)", "Researcher" and "the track's" (`app-verification.tex` ×5, `app-many.tex`, `app-zfc.tex`). "Checked by their authors" became "checked by the Claude instances that added them". These fall under the instruction's own example ("the author" used for Claude alone), and the edits are minimal. |
| 3a. Typesetting | `app-single.tex`: `\allowbreak` after a comma inside $P(g^{a_1}c,\dots)$. It removes the overfull line caused by the longer citation label. It is a line-break hint only, and the mathematics is unchanged. Acceptable. |
| 4. README | The sentence matches the template, followed by "Submission is his decision". The old README said "authorship and publication are his to decide". The "three questions" fact is kept in the README's section "The questions", and "How it was produced" is unchanged. |
| 5. Bib | `core.bib`: in `claude2026whatfollows`, only the author field changed. The other two keys are absent. `all.bib`, `main.bbl` and `main.blg` were regenerated by the build. |
| 6. Build | 0 errors, 0 undefined references and citations, 0 multiply defined labels, 0 overfull boxes >10pt, 135 pages. Page 1 shows "Kaarel Hänni   Claude (Anthropic)∗". |

**Footnote truth.** README, "Limits of the checking": "All roles were played by separate Claude instances. No human checked the mathematics, and nothing was verified in a proof assistant." The footnote matches. `research/prior/induction/lean/NatRec.lean` only inspects how Lean encodes `Nat.rec`; it does not verify any result in the paper. So "nothing has been verified in a proof assistant" stays true.

## axiom-induction

| item | status |
|---|---|
| 1. Author line | Correct. No model name or version appears. |
| 2. Footnote | The order is correct: AI system, then the contribution statement ("questions … under his direction. The first was his question about Solomonoff-style axiom induction (`hanni2026notes`); … follow-up to IL and AS"), then the checking statement adapted to Appendix H, then the existing pointer `axiom-induction/`. "Prepared for…" and "Draft; authorship…" are gone. The plural "questions" is justified by the later objection and proposal (§6.4, Appendix H). |
| 3. Body | `intro.tex`: "checked only by their authors" became "by their tracks", which is Appendix H's wording ("checked by their track"). "AS and IL, prepared for Hänni," became "AS and IL", because both are now co-authored by Hänni. `time.tex` §6.4 and `app-verification.tex` (table row and "The correction"): "our summary (to Hänni)" became "Claude's summary (to Hänni)" or "that summary". With "our" including Hänni, he would be objecting to his own summary, which was sent to him. The README's "an earlier summary of ours" became "an earlier summary from Claude". All of these are self-contradictions that the edits remove, and every edit is minimal. |
| 4. README | The sentence matches the template, followed by "Submission is his decision". The old README said "Authorship and publication are his to decide". The date and content of the 8 October question are kept ("The first question (8 October 2026) asks…"). "How it was produced" is unchanged. |
| 5. Bib | `paper/bib/core.bib`: only the author fields of `claude2026whatfollows` and `claude2026axiomschemas` changed. `claude2026axiominduction` is absent. `time.bib` and `experiments.bib` mention the keys only in comments. The non-generated `research/paper-review/scratch/r_build/bib/core.bib` was changed in the same way. That is what "every .bib file … except generated all.bib" requires, so it was left as it is. |
| 6. Build | 0 errors, 0 undefined references and citations, 0 multiply defined labels, 0 overfull boxes >10pt, 147 pages. Page 1 shows "Kaarel Hänni   Claude (Anthropic)∗". IL and AS are cited as "Hänni and Claude (Anthropic), 2026b / 2026a". |

**Footnote truth.** README: "All roles were played by separate Claude instances. No human checked the mathematics, and nothing was verified in a proof assistant." Appendix H says the same. Results added in revision were checked by their tracks, the section writers and the reviewers, all of them Claude instances. So "checked by separate Claude instances acting as referees and reviewers" is accurate.

## Model names

`Opus|Sonnet|Haiku|Fable|claude-` gave no hits in any of the following, for all three projects:
* the diff;
* the authorship logs;
* `main.tex` and the README;
* the text of the rebuilt PDF.

## Open issues for the author (not fixed; outside the binding scope)

1. **Bibliography fields contradict the new author field.** The binding rule changed only the author field. As a result, the PDFs now print the following:
   * `axiom-schemas` and `axiom-induction`: "Kaarel Hänni and Claude (Anthropic). What follows from what … Unpublished report prepared for K. Hänni" (`howpublished` of `claude2026whatfollows`).
   * `axiom-induction`: "Kaarel Hänni and Claude (Anthropic). Learning axioms … Draft report prepared for Kaarel Hänni" (`note` of `claude2026axiomschemas`).

   Suggested fix, in `paper/bib/core.bib` of both projects: drop "prepared for …" from those fields, for example `howpublished = {Unpublished report}` and `note = {\texttt{axiom-schemas/} in the accompanying repository}`.
2. **`inferential-learning/web/what-follows.html`**: the byline (line 280) and the footer (line 715) still say "Prepared by Claude (Anthropic) … Draft; authorship and publication are for him to decide." The page is not a paper and was outside the binding file list. It now contradicts the paper and the README, and should get the README's author line.
3. **The editors' flagged sentences** are listed in each log. I agree with them, and none is false. The most noticeable ones:
   * the statements "no human has checked the mathematics" in the abstracts and verification appendices, now that a human co-author is listed;
   * "Throughout, ``we'' means the authors of this report" (`inferential-learning` §13);
   * "the commissioner's questions" (`axiom-schemas` Appendix G);
   * the verbatim request addressed to "you" quoted in `axiom-schemas` §1.1.
4. **`axiom-induction/research/paper-review/scratch/r_build/bib/core.bib`** was changed literally per item 5, although the rest of that review snapshot keeps the old wording. Revert it if the snapshot should stay a faithful dated record. In any case it stays on the working branch only.

The rebuilt PDFs, and in `axiom-schemas` also `main.bbl` and `main.blg`, are current with the sources.
