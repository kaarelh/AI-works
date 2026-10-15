# Fresh reader, Paper 2, round 2 (2026-10-13)

I read Paper 2 (`paper-steeper/`) as a first-time arXiv reader and checked it against `research/paper-review/REFRAME.md`. The user's relayed request was: "it could be fine to keep most references to my notes in footnotes potentially". I read that together with REFRAME §4. I edited no file in the paper and ran no git command that changes state.

## How the reading was done

* **Build.** `cd paper-steeper && flock /tmp/claude-0/paper-build-sfi.lock ./build.sh`. Result: 0 LaTeX errors, 0 undefined references, 0 undefined citations, 0 multiply defined labels, no overfull box above 10pt, 57 pages.
* **Text.** `pdftotext -layout main.pdf` gave 3133 lines, saved as `research/paper-review/reframe/p2-r2-main.txt`. "PDF line" below means a line of that file.
* **What I read.** Lines 1–1451 (title page to "Code and data") and 1585–3133 (Appendices A–G) in full. I skipped the bibliography but checked its three Hänni entries. Appendix H (`app-verification.tex`) does not print, because `main.tex` sets `\sfirecordfalse`.
* **Bibliography keys** (from `main.bbl`):
  * Hänni (2026a) is `claudeSFI2026fundamentals`, the companion paper.
  * Hänni (2026b) is `hanni2026grokking`, the note on grokking.
  * Hänni (2026c) is `hanni2026notes`, the working notes.
* **Sources used for provenance.** `research/prior/hanni-grokking-a-notion.md`, `research/prior/hanni-lesswrong-comment-thread.md`, `research/00-brief.md`, `research/tracks/steeper/notes-final.md`, and `git diff 5acf4db3 -- paper-steeper/sections` (read-only).

## Summary

* **Footnotes that cite the notes: 3.** The target is at most about 5, so it is met. None is inside a theorem-like statement or a float. All three use the neutral form "first appeared in the author's (working) note(s)".

  | FN | page | PDF lines | where | source | cites | credits |
  |---|---|---|---|---|---|---|
  | 1 | 2 | mark 83, text 98–101 | §1, first paragraph, on the sentence that states the proposal | `intro.tex` l.9 | 2026c, 2026b | SFI; the proposal; the private-randomness suggestion; the online discussion |
  | 2 | 12 | mark 628, text 633–636 | §5, opening paragraph | `teacher.tex` l.7 | 2026b | the example and its calculation; the vertex question; the absolute bound |
  | 3 | 24 | mark 1218, text 1258–1260 | §8, opening paragraph | `algstat.tex` l.6 | 2026b | the change-of-slope suggestion and why none is expected with shared randomness |

  If R2-F1 (option A) is adopted, the count drops to 2.
* **(b) Citations outside footnotes and the acknowledgements: none.** `hanni2026notes` and `hanni2026grokking` occur only in FN 1–3 and in the acknowledgements (PDF lines 1436–1439, `discussion.tex` l.30). The acknowledgements contain REFRAME's required sentence and cite `hanni2026grokking` as the note in which the proposal first appeared.
* **(a) "The author".** It occurs only in the title-page footnote (PDF lines 45–47), in the acknowledgements, and in FN 1–3 in REFRAME's own wording. No body sentence says that the notes ask, propose, observe or anticipate anything. The paper contains no quotation from the notes. The Eisenstat credit (PDF line 1143, "Sam Eisenstat's coin example (personal communication; …)") is in the allowed form.
* **(e) Titles.** No section, subsection or environment title depends on the notes.
* **What remains.** The reframe is in good shape. What is left is small:
  * two footnote issues: a credit that arrives ten pages after the reader has met the items it credits (R2-F1), and a first footnote whose parts do not match the sentence it is attached to (R2-F2);
  * four places where the old framing still shows through: the two "versions" of the example (R2-F3), one table row (R2-F4), one premise stated as a known fact (R2-F5), one defensive self-assessment (R2-F6);
  * two optional items (R2-F7, R2-F8).

  None needs a change to any statement, number, label, `\status` or `\src` call. Two observations outside REFRAME's scope follow at the end (O1, O2). O1 includes one real regression of the reframe: a section pointer was lost when the introduction's "Relation" paragraph was deleted.

## Findings

They are ordered by priority. Each gives the criterion, the location, the problem and a concrete replacement.

### R2-F1. (c) Footnote 2 credits items that the reader met ten pages earlier, and its mark reads as "Remark 5.1.2"

* **Location.**
  * §5 opening, p. 12. The mark is at PDF line 628; the footnote text is at PDF lines 633–636.
  * Source: `teacher.tex` l.7 (in `sec:teacher`, pointing at `rem:teacher:hanni`).
* **Problem.**
  * FN 2 credits three items, and each one first appears well before §5:
    * the example and its three-hypothesis calculation: §1, p. 2–3, PDF lines 95–106, right next to FN 1;
    * the question whether the good model is a vertex of the convex hull: Table 1, row 2 (p. 5), and §3.3, p. 8, PDF lines 419–422 ("so for the example of Section 5 the question is whether the good model is a vertex");
    * the absolute complexity bound as an alternative: Table 1, row 6 (p. 5), and §3.3, p. 8, PDF lines 423–425.
  * So a reader meets all three items with no credit, and the credit arrives on p. 12.
  * The mark sits directly after a cross-reference that ends in a period: "…for the example of Remark 5.1.² Theorem 5.7…". `pdftotext` renders it as "Remark 5.1.2", and on paper it can be misread as a numbered item.
  * The material that FN 2 credits is introduced in the same intro paragraph as the proposal, so FN 2 can be merged with FN 1.
* **Replacement, option A (preferred: merge into FN 1, giving 2 footnotes).**
  * In `intro.tex` l.9, replace the whole FN 1 by:
    ```latex
    \footnote{The proposal; the suggestion that private randomness at each input blocks the absorption objection described below; the example below with its three-hypothesis calculation, in both versions of \cref{rem:teacher:hanni}; the question whether the good model is a vertex of the convex hull; and an absolute complexity bound as an alternative all first appeared in the author's note \citep{hanni2026grokking} and in an online discussion (on LessWrong), where the absorption objection was also raised. SFI itself first appeared in the author's working notes \citep{hanni2026notes}.}
    ```
  * In `teacher.tex` l.7, delete FN 2. The sentence becomes "This section makes this rigorous for the example of \cref{rem:teacher:hanni}."
  * Every item is in the note (`hanni-grokking-a-notion.md` l.7–8 and its "messy notes"), and Hänni's LessWrong comment reproduces the note, so "first appeared in the author's note … and in an online discussion" holds for each item.
* **Replacement, option B (minimal: keep FN 2 in §5).** Move the mark away from the cross-reference:
  ```latex
  This section makes the example of \cref{rem:teacher:hanni} rigorous.\footnote{The example (in both versions) and its three-hypothesis calculation, the question whether the good model is a vertex of the convex hull, and an absolute complexity bound as an alternative first appeared in the author's note \citep{hanni2026grokking}.}
  ```
  This fixes the "5.1.2" reading but not the late credit.

### R2-F2. (c) Footnote 1 credits SFI from a sentence about the proposal, and words the credit as a verdict

* **Location.**
  * §1, first paragraph, p. 2. The mark is at PDF line 83, after "…more than its likelihood term."; the footnote text is at PDF lines 98–101.
  * Source: `intro.tex` l.9 (`sec:intro`).
* **Problem.**
  * The first sentence of FN 1 ("The notion of SFI first appeared in the author's working notes") credits the subject of the paragraph's first sentence. But the mark sits on the fourth sentence, which states the proposal. The first sentence already cites the companion paper for SFI.
  * "the suggestion that private randomness at each input avoids its failure in sequence prediction" refers to a failure the reader has not yet met; the paper introduces it only in the next paragraph. It also puts a verdict on the proposal ("its failure") into a credit footnote.
  * "the absorption point below" uses a different name from the paper's own term, "absorption objection" (PDF line 91).
* **Replacement** (only if R2-F1 option A is not taken; option A already contains these fixes):
  ```latex
  \footnote{The proposal, and the suggestion that private randomness at each input blocks the absorption objection described below, first appeared in the author's note \citep{hanni2026grokking} and in an online discussion (on LessWrong), where that objection was also raised. SFI itself first appeared in the author's working notes \citep{hanni2026notes}.}
  ```
  The proposal now comes first, matching the sentence the mark is on. The SFI credit is kept, so nothing is lost.

### R2-F3. (d), (e) "The example comes in two versions" and the labels "Version 1 / Version 2"

* **Location.**
  * Remark 5.1, §5.1, p. 13, PDF lines 643–648. Source: `teacher.tex` l.12–15, `rem:teacher:hanni`.
  * The labels recur at §5.5, p. 17, PDF lines 884–885 ("Version 1 of the example is realised in population form"; `teacher.tex` l.167, the paragraph after `cor:teacher:sampled`), and in Example C.3, p. 42, PDF line 2251 ("the sizes and rates of Version 1 in Remark 5.1"; `app-teacher.tex` l.209, `ex:teacher:version1`).
* **Problem.**
  * "The example comes in two versions" treats the two forms as facts about an example that existed before the paper. The reader is not told why the calculation is done twice.
  * "Version 1" and "Version 2" are labels for two drafts in an outside source (the note's draft and the LessWrong answer). Elsewhere the paper names the two by what they are: "per-sample version" and "total-bits version" (Table 1, row 4; the title of Appendix C.6 and of Example C.3). So the naming is also inconsistent.
* **Replacement.**
  * `teacher.tex` l.12:
    ```latex
    We give the calculation in two versions: in total bits on a fixed data set, where the geometry of the hull is simplest, and per sample with $\lambda=cn$ (\cref{rem:setup:persample}), which is the version of \cref{sec:intro} and of the running example.
    ```
  * `teacher.tex` l.14: `\emph{Version 1} (total bits):` → `\emph{Total-bits version}:`.
  * `teacher.tex` l.15: `\emph{Version 2} (per sample):` → `\emph{Per-sample version}:`.
  * `teacher.tex` l.167: "and Version~1 of the example is realised in population form" → "and the total-bits version of the example is realised in population form".
  * `app-teacher.tex` l.209: "the sizes and rates of Version 1 in \cref{rem:teacher:hanni}" → "the sizes and rates of the total-bits version in \cref{rem:teacher:hanni}".
  * No number, `\status`, `\src` or label changes.

### R2-F4. (d) Table 1, row 4 asks a question the introduction has not prepared

* **Location.**
  * Table 1, row 4, p. 5, PDF lines 219–221.
  * Source: `intro.tex` l.43, inside `tab:intro:claims`.
* **Problem.**
  * "Is the three-hypothesis calculation realised by instances?" is opaque at this point. The calculation in §1 uses round, idealised sizes (a 100-bit model, a 10,000-bit error set), but the reader is not told that the question is whether explicit instances with these sizes exist.
  * The answer cell uses "per-sample version" and "total-bits version". The introduction does not mention a total-bits version, and both terms first appear in Remark 5.1.
* **Replacement** (the numbers and the Where cell are unchanged):
  ```latex
  Can the three-hypothesis calculation be carried out on explicit instances? & Yes. The per-sample version with an explicit $11{,}710$-bit error rule; the total-bits version (\cref{rem:teacher:hanni}) in population form, with $\lambda\in(9.77,58.0]$ at $n=10^4$, $\kappa=0$ (three hypotheses: $(10,100)$) & \cref{rem:teacher:hanni,rem:teacher:numbers,ex:teacher:version1}\\
  ```

### R2-F5. (d) The introduction states the λ = 1 premise of the sampler question as a known fact

* **Location.**
  * §1, second paragraph, p. 3, PDF lines 109–111.
  * Source: `intro.tex` l.15.
* **Problem.**
  * "At λ = 1, Solomonoff induction has no preference between the two; does a steeper prior prefer the sampler?" states the premise without support. Yet the paper proves it (Theorem 7.3, Proposition E.3), and Table 1, row 8, lists it as a question.
  * This is a remnant of the earlier framing, in which the premise was someone's claim that the paper then checked. The premise comes from the author's brief (`research/00-brief.md` l.23), not from a citable note. So no footnote is needed, but the sentence should carry its own support.
* **Replacement:**
  ```latex
  At $\lambda=1$, in SI and in SFI, the two get similar posterior weight (\cref{thm:split:lambda1,prop:split:si} make this precise); does a steeper prior prefer the sampler?
  ```
  This matches the answer in Table 1, row 8, and the abstract ("similar posterior weight").

### R2-F6. (a) "though not contrived" defends the example against a charge the paper never raises

* **Location.**
  * §6.2, p. 19, PDF lines 983–985.
  * Source: `limits.tex` l.48, the paragraph after the numbers of `prop:limits:envelope`.
* **Problem.**
  * "The example is favourable to the proposal, though not contrived" answers a charge of cherry-picking that this paper never raises. It echoes the author's remark in the online discussion ("somewhat cherry-picked … though I also don't consider it completely contrived").
  * The paper gives no argument that the example is not contrived. The same subsection, and the discussion paragraph "The gap to realistic errors", stress that realistic errors are often structured, which pulls the other way.
* **Replacement:**
  ```latex
  The example is favourable to the proposal; its conclusion holds for error rules incompressible relative to the model (\cref{thm:teacher:main}).
  ```

### R2-F7. (a, earlier draft; optional) Remark 4.8(iii) ends by rebutting an unstated claim

* **Location.**
  * Remark 4.8(iii), §4.4, p. 12, PDF lines 607–608.
  * Source: `absorb.tex` l.91, `rem:absorb:wyeth`.
* **Problem.**
  * "So restricting to private randomness is not free at λ = 1 when compared with MF" repeats the first sentence of (iii), which already says that the restriction costs up to K(dom D) + O(1) bits against MF at λ = 1, unboundedly in the worst case.
  * The words "is not free" reply to a claim that the restriction is free. That claim appears nowhere in the paper. It comes from an earlier internal draft ("Nothing is lost at λ = 1", `notes-final.md` l.339). So the sentence reads as a correction of something the reader has not seen.
* **Replacement.** Delete the sentence: the caveat stays in the first sentence of (iii). If a closing sentence is wanted instead:
  ```latex
  So the restriction already has a cost at $\lambda=1$, measured against $\MF$.
  ```

### R2-F8. (c; optional) The acknowledgements locate the questions in the working notes, while the footnotes locate them in the grokking note

* **Location.**
  * Acknowledgements, p. 28, PDF lines 1437–1439.
  * Source: `discussion.tex` l.30.
* **Problem.**
  * "Several of the questions and examples studied here first appeared in those notes" points to Hänni (2026c). FN 2 and FN 3 credit Hänni (2026b) for the example and the questions.
  * This is accurate, because 2026b is a note in the same repository. But a reader who compares the two may be puzzled.
* **Replacement** (keeps REFRAME's required sentence and the 2026b citation):
  ```latex
  Several of the questions and examples studied here first appeared in those notes, most of them in the note \citep{hanni2026grokking}, where the proposal also first appeared.
  ```

## Checked, no change needed

* **Footnote 3** (`algstat.tex` l.6) is neutral and accurate (grokking note l.8). It is attached after "(Remark 8.5).", outside any statement.
* **Remark 8.5, "Reading: one bit for one bit".** It paraphrases the note's "1 bit paying for 1 bit" without quoting it, and the remark itself explains the phrase. So it is not a title that only makes sense against the notes.
* **§4 opening** (`absorb.tex` l.5). The pathology is presented as a standard point, with the function-induction way out in our voice ("there is a natural way out"). No credit is needed here, because FN 1 carries it.
* **§5 opening, §7 opening and §8 opening** (`teacher.tex` l.7, `split.tex` l.6, `algstat.tex` l.6). Each now motivates its subject on its own terms: a learner should not reproduce a teacher's mistakes; only the sampler separates model from noise; one can look for a change of slope.
* **§3.3 after Remark 3.7** (`setup.tex`). The vertex question and the absolute bound are motivated in our voice ("the question is whether the good model is a vertex"; "a natural alternative to the penalty").
* **Table 1 caption and rows 1–3 and 5–10.** None refers to the notes or grades anyone's claim.
* **Remark 4.8 and §4.4, "Answer to the absorption objection".** The objection is introduced as a standard objection, so answering it is the paper's own business.
* **Title-page footnote, Remark 9.4, acknowledgements.** The Vaintrob slides are cited as a normal reference, and the Eisenstat credit is in the allowed form.

## Outside REFRAME's scope

### O1. The earlier report: one lost pointer and inconsistent naming

* **Location.**
  * §2, paragraph "The earlier report.", p. 6, PDF line 268; source `related.tex` l.27–28 (`rem:related:t5`).
  * Remark 4.3, p. 10, PDF line 508 (`absorb.tex` l.39).
  * Appendix G title, p. 56, PDF line 3051 (`app-related.tex` l.3, `app:related`), and G.1, p. 57, PDF line 3092 (`app-related.tex` l.26, `app:related:t5`).
* **Problem.**
  * **A regression from the reframe.** The deleted intro paragraph cited `\Citet[Section~8]{claude2026whatfollows}`; DECISIONS asks for that pinpoint once. REFRAME §4 says to move the paragraph's "other work" content to related work if it is not already there. The pinpoint did not survive: §2 now cites the report without "Section 8".
  * This matters because the report's title ("What follows from what: Learning inference rules from imitation, coherence, and the world") does not suggest that it treats steeper priors. Its Section 8 is "Simplicity and normativity from imitation" (checked in `inferential-learning/paper/sections/simplicity.tex` l.28).
  * **Naming.** The paragraph heading "The earlier report." uses a definite article before the reader knows of any report. The Appendix G title says "the earlier report"; G.1 says "the earlier formalisation".
* **Replacement.**
  * `related.tex` l.27–28:
    ```latex
    \paragraph{An earlier formalisation.}\label{rem:related:t5}
    \Citet[Section~8]{claude2026whatfollows} formalised the proposal for a general imitation channel, mostly by comparing a few hypotheses by rate; we call it the earlier report below. We re-derive the results we use from it: …
    ```
    The rest of the paragraph is unchanged.
  * `app-related.tex` l.26: "Correspondence with the earlier formalisation" → "Correspondence with the earlier report", to match the Appendix G title.

### O2. §4 names the absorption objection a second time

* **Location.** §4 opening, p. 9, PDF line 455; `absorb.tex` l.5.
* **Problem.** "We call the point the *absorption objection*." repeats the naming of §1 (PDF line 91, "A standard objection, which we call the *absorption objection*").
* **Replacement:** "This is the absorption objection of \cref{sec:intro}."
