# Fresh reader, Paper 2, round 1 (2026-10-13)

I read Paper 2, `paper-steeper/`, against `research/paper-review/REFRAME.md`. The user's request relayed with this task says that "it could be fine to keep most references to my notes in footnotes potentially". This report reads that together with REFRAME §4. I edited no file in the paper.

## How the reading was done

* **Build.**
  * Command: `cd paper-steeper && flock /tmp/claude-0/paper-build-sfi.lock ./build.sh`.
  * Result: 0 LaTeX errors, 0 undefined references, 0 undefined citations and 0 multiply defined labels. No overfull box exceeds 10pt. The PDF has 57 pages.
* **Text.**
  * `pdftotext -layout main.pdf` gave 3134 lines, saved as `research/paper-review/reframe/p2-r1-main.txt`.
  * I read lines 1–1456 (front matter to Code and data) and 1586–3134 (Appendices A–G) in full. I skipped the bibliography, but checked its three Hänni entries.
  * Appendix H (`app-verification.tex`) is switched off by `\sfirecordfalse` and does not print.
* **Line numbers.** "PDF line" below means the line number in that text file.
* **Bibliography keys** (from `main.bbl`):
  * Hänni (2026a) is `claudeSFI2026fundamentals`, the companion paper.
  * Hänni (2026b) is `hanni2026grokking`, the note on grokking.
  * Hänni (2026c) is `hanni2026notes`, the working notes.
  * Vaintrob and Hänni (2026) is `vaintrobhanni2026nnbayes`, the slides.
* **Sources consulted** for the provenance of phrases:
  * `research/prior/hanni-grokking-a-notion.md`;
  * `research/prior/hanni-lesswrong-comment-thread.md`;
  * `research/tracks/steeper/notes-final.md`;
  * `git diff 5acf4db3 -- paper-steeper/sections` (read-only), to see what the reframe pass changed.

## Summary

* **Footnotes that cite the notes: 4.** The target is at most about 5, so it is met. All four are in running text. None is inside a theorem-like environment or a float. All four use the neutral form "first appeared in the author's (working) note(s)".

  | FN | page | PDF lines | where | source | cites | credits |
  |---|---|---|---|---|---|---|
  | 1 | 2 | 98–101 | intro, at the first statement of the proposal | `intro.tex` l.9 | 2026c, 2026b | the notion of SFI; the proposal; the LessWrong discussion and the absorption point |
  | 2 | 9 | 474–476 | §4 opening | `absorb.tex` l.5 | 2026b | the sequence-case pathology; the suggestion that private randomness avoids it |
  | 3 | 12 | 636–638 | §5 opening | `teacher.tex` l.7 | 2026b | the example (both versions); the three-hypothesis calculation; the convex-hull view |
  | 4 | 24 | 1259–1261 | §8 opening | `algstat.tex` l.6 | 2026b | the slope method for locating the split; the reason the sequence case shows none |

  * After F3 (merging FN 2 into FN 1) the count would be 3.
  * For comparison, a source snapshot of Paper 1 (`paper/sections/*.tex`, comments excluded) has 8 such footnotes, against a target of at most about 10:
    * `intro`, `setting`, `versions`, `hist`, `ood`, `comp`, `nn` and `steeper`;
    * the one in `steeper` cites `hanni2026grokking`.
* **(b) Citations outside footnotes and the acknowledgements: none.**
  * `hanni2026notes` and `hanni2026grokking` are cited only in FN 1–4 and in the acknowledgements (PDF lines 1437–1440, `discussion.tex` l.30).
  * The acknowledgements contain both sentences that REFRAME §4 requires, and cite `hanni2026grokking` as the note in which the proposal first appeared.
* **(a) "The author".** It appears only in:
  * the title-page footnote (PDF lines 45–47);
  * the acknowledgements;
  * FN 1–4, in the form that REFRAME §4 allows.

  No body sentence says that the notes ask, propose, observe, anticipate or state anything. "Sam Eisenstat's coin example (personal communication …)" (PDF line 1139) is in the allowed form. The word "draft" does not occur in the printed text.
* **(e) Titles.** No section, subsection or environment title depends on the notes. "The three-hypothesis calculation" makes sense because the introduction gives the calculation. "Reading: one bit for one bit" paraphrases the note's phrase without quoting it, and the remark explains it.
* **What remains.** These are residues of the earlier reply framing rather than outright references:
  * one table row that grades a calculation (F1);
  * one near-verbatim phrase from the note without quotation marks, of a kind REFRAME §5 names (F2);
  * one footnote that duplicates the credit of FN 1 (F3);
  * three sentences that still read as a verdict on, or a correction of, someone else's example (F4–F6);
  * three places where the motivation that the citation used to supply is now thin (F7–F9);
  * two optional items (F10, F11).

  None needs a change to the mathematics, the numbering or the labels. Three observations outside REFRAME's scope follow at the end.

## Findings

They are ordered by priority. Each gives the location, the problem and a concrete replacement.

### F1. (a) Table 1 asks whether "the three-hypothesis calculation" is "correct"

* **Location.**
  * Table 1, row 4, p. 5, PDF lines 219–221.
  * Source: `intro.tex` l.43, inside `tab:intro:claims`.
* **Problem.**
  * "Is the three-hypothesis calculation correct, … ? — Yes." grades the calculation as if it were someone else's.
  * In the paper's own voice the calculation is ours (intro, Remark 5.1), and nobody asks whether their own arithmetic is correct.
  * The row is left over from the earlier caption "Questions raised in the author's notes". The track record also has "arithmetic confirmed" (`notes-final.md` l.1171).
* **Replacement** (the Answer and Where cells are unchanged except for the first word):
  ```latex
  Is the three-hypothesis calculation realised by instances? & Yes: its per-sample version with an $11{,}710$-bit rule; its total-bits version in population form, with $\lambda\in(9.77,58.0]$ at $n=10^4$, $\kappa=0$ (three hypotheses: $(10,100)$) & \cref{rem:teacher:hanni,rem:teacher:numbers,ex:teacher:version1}\\
  ```

### F2. (a, quotation) Section 3.3 keeps the note's wording "a higher coefficient on the length of the program than on the likelihood term(s)" without quotation marks

* **Location.**
  * §3.3, p. 8, PDF lines 388–389.
  * Source: `setup.tex` l.63, the running text after `def:setup:objectives` and before `lem:setup:basic`.
* **Problem.**
  * The reframe pass only removed the quotation marks and changed "terms" to "term".
    * Diff: `[-``a-]{+a+} … [-terms'';-]{+term;+}`.
    * The source is the LessWrong comment reproduced in the note: "What I'm suggesting is this loss but with a higher coefficient on the length of the program than on the likelihood terms." (`hanni-lesswrong-comment-thread.md` l.24; `hanni-grokking-a-notion.md` l.41, 54.)
  * REFRAME §5 lists "a higher coefficient …" among the phrases to paraphrase.
  * A near-verbatim sentence without attribution is worse than either a quotation or a paraphrase.
* **Replacement.** Replace the first sentence of the paragraph with:

  > The two-part objective weights the length of a program $\lambda$ times as heavily as its negative log-likelihood; the power-prior posterior is its Bayesian form.

### F3. (c) FN 2 repeats the credit of FN 1 and comes later than the text it credits; merge it into FN 1

* **Location.**
  * FN 2: p. 9, PDF lines 474–476, `absorb.tex` l.5. It comes after "the pathology may be absent." in the opening paragraph of `sec:absorb`.
  * FN 1: p. 2, PDF lines 98–101, `intro.tex` l.9.
* **Problem.**
  * In the abstract and the introduction, the proposal is "steeper penalty *with private randomness at each input*". FN 1 already credits the proposal, and the absorption point, to the note and to the online discussion.
  * The text that FN 2 credits (the sequence-case pathology and the private-randomness hope) appears first in the introduction (PDF lines 91–96), right after FN 1, where it gets no credit. It is credited only seven pages later.
  * REFRAME §4 for Paper 2 asks for "a single footnote at its first statement" crediting the note for the proposal. Merging the two footnotes satisfies that and reduces the count to 3.
* **Replacement.**
  * Delete the footnote in `absorb.tex` l.5. The sentence ends "…, and the pathology may be absent."
  * Replace FN 1 (`intro.tex` l.9) with:

    > \footnote{The notion of SFI first appeared in the author's working notes \citep{hanni2026notes}. The proposal, the observation that it fails in sequence prediction and the suggestion that private randomness at each input avoids this first appeared in the author's note \citep{hanni2026grokking} and in an online discussion (on LessWrong), where the absorption point below was also raised.}

  * Both statements hold for both sources: the note has the sequence-case pathology and the private-randomness suggestion (`hanni-grokking-a-notion.md` l.7), and Hänni's LessWrong answer repeats them.

### F4. (a) §6.2 still pronounces a verdict on "the example" in reply form

* **Location.**
  * §6.2, p. 19, PDF lines 979–981.
  * Source: `limits.tex` l.48, the paragraph after `prop:limits:envelope`, beginning "So density and description length alone do not suffice".
* **Problem.**
  * Current text: "The example is a favourable case, though not a contrived one; what holds is the example for error rules incompressible relative to the model."
  * The first clause paraphrases Hänni's LessWrong caveat ("somewhat cherry-picked for the idea to work, though I also don't consider it completely contrived").
  * The second clause ("what holds is the example for …") reads as a ruling on a claim someone else made. It is also hard to parse.
  * The mathematical content, that the conclusion holds for incompressible rules and not for every rule of the same density and length, should stay.
* **Replacement:**

  > The example is favourable to the proposal, though not contrived: its conclusion holds over all product hypotheses for error rules incompressible relative to the model (\cref{thm:teacher:main}), but not for every rule with the same density and description length.

### F5. (a) Remark 5.1 still corrects the note's approximation

* **Location.**
  * §5.1, Remark 5.1, p. 13, PDF lines 659–660.
  * Source: `teacher.tex` l.17, inside `rem:teacher:hanni`.
* **Problem.**
  * Current text: "…, with the exact $H(2^{-10})=0.0112$ rather than $p\log(1/p)\approx1/100$."
  * It used to read "in place of the approximation $1/100$ of the note" (diff). The "rather than" clause now corrects an approximation that the paper never makes.
  * A first-time reader asks who used $p\log(1/p)$.
  * The clause carries no mathematical caveat: the paper's numbers all use the exact entropy.
* **Replacement:**

  > A direct computation (code in the accompanying repository) gives these numbers, with the exact binary entropy $H(2^{-10})=0.0112$.

### F6. (a) Introduction: "The example was chosen to favour the proposal"

* **Location.**
  * §1, p. 3, PDF line 106.
  * Source: `intro.tex` l.15.
* **Problem.**
  * The passive voice hides who chose the example. In a paper that presents the example as its own motivating calculation, the sentence reads as a remark about someone else's example.
  * It paraphrases the "cherry-picked" caveat; see F4.
* **Replacement:**

  > The example is deliberately favourable to the proposal, and three hypotheses are not all hypotheses: does another hypothesis do better, and is some other pathology present?

### F7. (d) Remark 5.1 opens abruptly: "The example has two versions."

* **Location.**
  * §5.1, Remark 5.1, p. 13, PDF line 648.
  * Source: `teacher.tex` l.12, the first line of `rem:teacher:hanni`.
* **Problem.**
  * The sentence used to be "The author's note gives two versions of its example". Now nothing says which example is meant, or why it comes in two versions.
  * The introduction gives only the per-sample version.
  * Version 1 (total bits) is new to the reader, yet it is used later: Table 1 row 4 and Example C.3 cite "the total-bits version".
* **Replacement** (the items stay):

  > The calculation sketched in the introduction can be set up in two ways: in total bits for a fixed data set, comparing how many bits of labels each part of a hypothesis predicts per bit of description, or per sample, comparing rates.

### F8. (d) The sampler-versus-fill-in question has no motivation of its own

* **Location.**
  * §1, p. 3, PDF lines 107–110; source `intro.tex` l.15: "A second question is whether a steeper prior prefers a simple sampler to programs in which the sampled bits are filled in; at $\lambda=1$, Solomonoff induction has no such preference."
  * §7 opening, p. 21, PDF lines 1060–1062; source `split.tex` l.6.
* **Problem.**
  * The sentence used to be "A second question of the author's notes is whether …". With the citation gone, the question arrives with no reason to ask it.
  * "A second question" also follows a sentence that already asks two questions.
  * The motivation is in the paper's own theme: a sampler with private coins is a model plus noise, and a fill-in stores the noise as model. §7's opening says what each option is, but not why one should prefer the sampler.
* **Replacements.**
  * `intro.tex` l.15, from "A second question" to "no such preference.":

    > The same split between model and noise arises in its simplest form when the labels are drawn by a computable sampler: they are explained both by the sampler, with private coins, and by programs in which the sampled bits are filled in. A learner that separates model from noise should prefer the sampler; at $\lambda=1$, Solomonoff induction has no such preference, and we ask whether a steeper prior has one.

  * `split.tex` l.6, the second sentence:

    > At $\lambda=1$, Solomonoff induction has no preference between the two, although only the sampler separates the model from the noise; a steeper prior might prefer it.

### F9. (d) Three rows of Table 1 use terms the introduction has not introduced

* **Location.**
  * Table 1, p. 5. Source: `intro.tex`, inside `tab:intro:claims`.
  * Row 2 (PDF lines 210–212, l.41): "Can the good model of the example be a vertex of the convex hull of (complexity, expected log loss)?"
  * Row 6 (PDF lines 224–225, l.45): "Is an absolute length bound equivalent to the penalty?"
  * Row 9 (PDF lines 233–234, l.48): "Does the slope of the remaining entropy change at the model?"
* **Problem.** These rows keep the note's wording:
  * "could be a vertex of the convex hull of … tuples";
  * "set abs bound on model complexity … in a sense this is equivalent";
  * "how many bits of entropy are left given the hypothesis … see some point at which the derivative changes".

  The introduction does not mention the convex hull, an absolute length bound or a remaining-entropy curve. Without the note, a reader of the introduction cannot tell why anyone would ask these questions. §3 (Remark 3.7's paragraph) and §8's opening do motivate them, but only later.
* **Replacements** (the Answer and Where cells are unchanged except as shown):
  * **Row 2:**
    > Is the good model of the example selected for a range of $c$, that is, is it a vertex of the convex hull of the attainable pairs (complexity, expected log loss) (\cref{rem:setup:persample})?
  * **Row 6:**
    > Does an absolute bound on model complexity, a natural alternative to the penalty, select the same hypotheses?

    Answer: "At vertices of the hull; elsewhere it can also select points that the penalty never selects". This is the content of Lemma A.1(iv) and of the §3 paragraph.
  * **Row 9:**
    > Plotting the entropy left given a hypothesis against its length: does the slope change at the model?
  * **Alternative:** add one sentence to the introduction after "(\cref{rem:teacher:hanni})." (`intro.tex` l.15) and leave rows 2 and 6 as they are:

    > Selection by $c\,\ell+R$ picks vertices of the convex hull of the attainable pairs of complexity and expected log loss (\cref{rem:setup:persample}), so the question is whether the good model is such a vertex once all hypotheses compete.

### F10. (c, optional) FN 3 credits the convex-hull view two sections after the paper introduces it

* **Location.**
  * FN 3: p. 12, PDF lines 636–638, `teacher.tex` l.7.
  * The convex-hull view itself first appears in Table 1 (p. 5) and in §3 (PDF lines 417–423, `setup.tex` l.79, after `rem:setup:persample`).
* **Problem.** The credit "and the convex-hull view of selection" sits in §5, after the reader has met the view twice without credit. This is minor. The footnote is neutral and correctly placed for the example.
* **Replacement.** Choose one:
  * leave FN 3 as it is;
  * move "the convex-hull view of selection" into the merged FN 1 of F3, which then reads "…, the three-hypothesis example and the convex-hull view of selection first appeared …". FN 3 then shrinks to "The example (both versions) first appeared in the author's note \citep{hanni2026grokking}."

  Either way there is one footnote per section at most.

### F11. (optional) Table 1's last row answers the note's "have people not already considered this"

* **Location.**
  * Table 1, last row, p. 5, PDF lines 235–237.
  * Source: `intro.tex` l.49.
  * The row reads: "Has a steeper penalty been studied for the model–noise split? — In part: λ-weighted MDL; restricted model families — §2".
* **Problem.**
  * The row mirrors the note's question "have people not already considered this for solving the model + data split problem?".
  * In a table captioned "Questions studied in this paper", a question about the literature is out of place. §2 (its "Novelty" paragraph) already answers it.
* **Replacement.** Delete the row. If it is kept, phrase it as a question about the paper: "Which parts of this are known? — λ-weighted MDL in noisy classification; restricted model families in algorithmic statistics — §2".

## Checked and fine

* **Abstract and introduction.**
  * The proposal is presented as the paper's subject ("We study the following proposal …"), with its single credit footnote.
  * The relation-to-notes paragraph is gone, and the contributions list never mentions the notes.
  * The Table 1 caption is "Questions studied in this paper and where they are answered. …", as REFRAME §4 requires.
* **The three-hypothesis calculation** is presented in "we" voice in the introduction and in Remark 5.1, apart from F5–F7.
* **§4.**
  * The absorption objection is "a standard objection" or "standard point" (DECISIONS §B), with no person named.
  * Remark 4.8 "Answer to the absorption objection" answers the objection, not the notes.
* **§5, end of §5.4.** "settles the question left open by the three-hypothesis calculation of Remark 5.1" (PDF lines 824–825) refers to our own calculation.
* **§6.** "as anticipated in [Hän26b]" is gone. Remark 6.2 states its result directly.
* **§8.** The opening motivates the slope method on its own terms. The phrase "one bit for one bit" is a paraphrase, not a quotation of the note's "1 bit paying for 1 bit".
* **Remark 9.4 and the Discussion.** They cite the slides of Vaintrob and Hänni (2026) as a normal reference, as REFRAME §6 asks.
* **Appendices A–G.**
  * They contain no reference to the notes.
  * The "earlier report" (`claude2026whatfollows`) is a separately published, citable report. DECISIONS §G2 keeps it, so it is outside REFRAME's scope; see O1–O3.
* **The acknowledgements** contain:
  * the required sentence "Working from the author's notes \citep{hanni2026notes} and under the author's direction, …";
  * the added sentence "Several of the questions and examples studied here first appeared in those notes";
  * the credit of the proposal to \citep{hanni2026grokking}.

## Outside REFRAME's scope (for the lead editor's judgement)

These concern the earlier report, not the notes. I list them because they have the same reply or process tone.

### O1. Related work, "The earlier report"

* **Location.** p. 6, PDF lines 264–273, `related.tex` l.28 (`rem:related:t5`).
* **Problem.** "We re-derive, rather than copy, the results we use from it" is process language. "Two statements change." is abrupt.
* **Suggestion.**
  * "We re-derive the results we use from it: …".
  * "Two of its statements are refined here: …".

### O2. Proposition D.1 (guard erosion) uses the earlier report's vocabulary without explanation

* **Location.** p. 45, PDF lines 2427–2438, `app-limits.tex` l.62 (`prop:limits:guard`).
* **Problem.** "a schema σ is one of $n_{\rm st}$ possible steps" carries over the report's vocabulary of inference steps. §6.3 describes the result as "a guard that restricts a rule to its proper contexts", so a reader of the appendix meets "schema" and "steps" unexplained.
* **Suggestion.** Change the wording only, not the mathematics: "a rule σ is one of $n_{\rm st}$ possible labels (steps)".

### O3. Appendix C.3, "Numbers": "the scripts of the earlier report reproduce its window"

* **Location.** p. 40, PDF lines 2157–2159, `app-teacher.tex` l.125.
* **Problem.** "its" can refer to Remark 5.1 or to the earlier report.
* **Suggestion.** "For the three hypotheses of Remark 5.1, the scripts of the earlier report give the same window $(1.119\cdot10^{-6},8.989\cdot10^{-3})$, with ratio 8037, and the same $\lambda=1$ switch at $n=894{,}054$."
