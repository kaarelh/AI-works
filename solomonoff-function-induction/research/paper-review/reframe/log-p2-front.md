# Reframe log: p2-front (Paper 2: abstract, intro, discussion with acknowledgements, main.tex)

Binding note: `research/paper-review/REFRAME.md` (2026-10-13).

Files edited:
* `paper-steeper/sections/intro.tex`
* `paper-steeper/sections/discussion.tex`

Read in full and left unchanged:
* `paper-steeper/sections/abstract.tex`. It does not cite the notes. It is in the "we" voice ("We study the proposal to penalise program length more steeply …"), and it frames nothing against the notes.
* `paper-steeper/main.tex`. The title names no notes. The title-page `\thanks` stays unchanged (REFRAME §7, DECISIONS §A4).

Originals for comparison: `git diff 5acf4db3 -- solomonoff-function-induction/paper-steeper/sections/{intro,discussion}.tex`. The Paper 2 files were unchanged since 5acf4db3 when this pass started.

## Where the footnote crediting `hanni2026grokking` is

**It is in `intro.tex`, line 9.** The introduction states the proposal before any body section does ("We study the following proposal …"), so the footnote at the proposal's first statement belongs to p2-front.

* `grep` before the edit: the proposal's first statement was in intro.tex. It was then cited in the running text at intro.tex:7,11. setup.tex:63 ("The two-part objective is the proposal of \citet{hanni2026grokking}") came later.
* `grep` now: setup.tex no longer cites `hanni2026grokking`; p2-body has already reframed it.
* As REFRAME §4 asks, the footnote absorbs the former LessWrong footnote of absorb.tex. **p2-body has already removed** that footnote; absorb.tex:5 now carries only its own credit footnote, for the sequence-case pathology and the private-randomness suggestion.

## Changes

### 1. intro.tex, first paragraph (`sec:intro`, line 9): citation of the notes removed from the first sentence
* **Old:** "… with a universal prior over random partial functions \citep{hanni2026notes,claudeSFI2026fundamentals}."
* **New:** "… with a universal prior over random partial functions \citep{claudeSFI2026fundamentals}."
* **Why:** REFRAME §4: no `hanni2026notes` in the running text. The credit for the notion of SFI moves into the footnote of change 2.
* **Mathematics:** unchanged. The description of SFI is verbatim.

### 2. intro.tex, first paragraph (line 9): the proposal is the paper's subject; one footnote
* **Old:** "The author's note \citep{hanni2026grokking} proposes a stronger simplicity prior for this purpose: when the mistakes are explainable deviations from a simple model, select the simple model with noise, by penalising the length of a hypothesis more than its likelihood term."
* **New:** "We study the following proposal for this purpose, a stronger simplicity prior: when the mistakes are explainable deviations from a simple model, select the simple model with noise, by penalising the length of a hypothesis more than its likelihood term.\footnote{The notion of SFI first appeared in the author's working notes \citep{hanni2026notes}. The proposal first appeared in the author's note \citep{hanni2026grokking} and in an online discussion (on LessWrong), where the absorption point below was also raised.}"
* **Why:** REFRAME §4, Paper 2.
  * The text uses "We study the following proposal: …".
  * The single footnote at its first statement uses REFRAME's wording verbatim.
  * The footnote is merged with the credit for the notion of SFI from change 1, so the section has one footnote.
  * The footnote is in running text, not in a float or a theorem-like statement.
  * The LessWrong facts were checked against `research/prior/hanni-lesswrong-comment-thread.md`: the thread contains the note and the reply that raises the universal-distribution point.
* **Mathematics:** unchanged. The proposal is worded as before, and the displayed $J_\lambda$ and the power-prior clause after it are untouched.

### 3. intro.tex, first paragraph (line 13): quotation removed
* **Old:** "The proposal is made for function induction in which ``each input gets its own private randomness'' \citep{hanni2026grokking}: a hypothesis is a probabilistic program that uses fresh coins at every input."
* **New:** "We consider it for function induction with private randomness at each input: a hypothesis is a probabilistic program that uses fresh coins at every input."
* **Why:** REFRAME §5 names this quotation. It also removes a running-text citation.
* **Mathematics:** unchanged. The definition after the colon is verbatim.

### 4. intro.tex, second paragraph (line 15): the absorption objection and the three-hypothesis calculation in our voice
* **Old:**
  * "The note makes this point for sequence prediction and suggests that the pathology is absent in the function case if each input samples its own random bits."
  * "Its example has a $100$-bit simple model … the first is selected for a range of $\lambda/n$."
  * "The example was chosen to favour the proposal; the note asks whether another hypothesis does better and whether some other pathology is present."
* **New:**
  * "In sequence prediction the objection holds (\cref{sec:absorb}). In function induction one may hope that it fails if each input samples its own random bits, so that a hypothesis pays its likelihood term separately at every input."
  * "A three-hypothesis calculation supports this hope. Take a $100$-bit simple model … the first is selected for a range of $\lambda/n$ (\cref{rem:teacher:hanni})."
  * "The example was chosen to favour the proposal, and three hypotheses are not all hypotheses: does another hypothesis do better, and is some other pathology present?"
  * Added at the end of the paragraph: "\Cref{tab:intro:claims} lists these and further questions and where they are answered."
* **Why:**
  * REFRAME §2: "the note makes / suggests / asks". The questions are now motivated by the limits of a three-hypothesis comparison.
  * REFRAME §4: "The three-hypothesis calculation is a motivating calculation in our voice."
  * The last sentence keeps the table cited in the introduction. Before this pass its only citation was in the deleted paragraph (change 9).
* **Mathematics:** unchanged.
  * The numbers ($100$ bits, $2^{-10}$, $10{,}000$ bits, three hypotheses, a range of $\lambda/n$) are verbatim.
  * The caveat "chosen to favour the proposal" is kept.
  * "The objection holds in sequence prediction" is `thm:absorb:absorption`, already stated for SI in the contributions list. absorb.tex itself calls part (a) "the precise form of the sequence-case pathology".
  * "pays its likelihood term separately at every input" is the wording of absorb.tex:44 (`prop:absorb:pricing`). It is a motivation, not a new claim.
  * The added `\cref`s point to existing labels.
  * The sentence on the sampler-versus-fill-in question is verbatim.

### 5. intro.tex, `tab:intro:claims`, caption (line 52)
* **Old:** "Questions raised in the author's notes \citep{hanni2026grokking} and where they are answered. Numbers with $\kappa=0$ …"
* **New:** "Questions studied in this paper and where they are answered. Numbers with $\kappa=0$ …"
* **Why:** REFRAME §4, Paper 2. The caption is the exact wording given there. The citation inside a float is gone.
* **Mathematics:** unchanged. The $\kappa=0$ sentence is verbatim.

### 6. intro.tex, `tab:intro:claims`, row 4 (line 43)
* **Old:** "Is the arithmetic of the example right? & Yes. Version 2 is realised with an $11{,}710$-bit rule; Version 1 in population form, with …"
* **New:** "Is the three-hypothesis calculation correct, and is it realised by instances? & Yes. Its per-sample version is realised with an $11{,}710$-bit rule; its total-bits version in population form, with …"
* **Why:**
  * "Is the arithmetic of the example right?" made sense only as a check of someone else's calculation (REFRAME §3, implicit framing). The new question is the natural one for a motivating calculation.
  * "Version 1/2" were undefined in the introduction. The new names are the parentheticals of teacher.tex (`rem:teacher:hanni`: "Version 1 (total bits)", "Version 2 (per sample)") and the title of `ex:teacher:version1` ("the total-bits version of the example").
* **Mathematics:** unchanged. "$\lambda\in(9.77,58.0]$ at $n=10^4$, $\kappa=0$ (three hypotheses: $(10,100)$)", "$11{,}710$-bit" and the `\cref` list are verbatim.

### 7. intro.tex, `tab:intro:claims`, last row (line 49)
* **Old:** "Has this been considered for the model--noise split?"
* **New:** "Has a steeper penalty been studied for the model--noise split?"
* **Why:** "this" echoed a sentence of the note and had no antecedent in a table that stands on its own.
* **Mathematics:** none. The answer cell and the `\cref` are verbatim.

The other eight rows were already neutral questions and are unchanged ("Does absorption occur in the sequence case …?", "Is some other pathology present?", …). REFRAME §4 says the table keeps its rows.

### 8. intro.tex, contributions list
No change was needed. No bullet mentions the notes. The `\cref`s, numbers and caveats are as before.

### 9. intro.tex, paragraph "Relation to the author's notes and to other work." (formerly line 53): deleted
* **Old:** "The notion of SFI first appeared in the author's working notes \citep{hanni2026notes}, and the proposal, its example and most of the questions studied here in the note \citep{hanni2026grokking}; we cite those notes where they arise and say where a claim made there needs correction (\cref{tab:intro:claims}). The basic theory of SFI is in the companion paper …; the samplers of Sam Eisenstat's coin example (personal communication; see also \citet[Section~7.3]{claudeSFI2026fundamentals}) are covered by \cref{thm:split:lambda1}. \Citet[Section~8]{claude2026whatfollows} formalised the proposal for a general imitation channel; we re-derive what we use from this earlier report (\cref{rem:related:t5}). The closest prior work, $\lambda$-weighted two-part MDL in noisy classification, targets the data distribution, which ours deliberately does not; we do not claim as new that a bounded $\lambda$ fits the noise and that $\lambda$ must grow with $n$ (\cref{sec:related})."
* **New:** nothing. As REFRAME §4 requires, nothing replaces the paragraph.
* **Where each piece now lives:**
  * The notion of SFI and the proposal: the footnote of change 2.
  * The example and the questions: the acknowledgements (change 11) and p2-body's footnote in teacher.tex.
  * "Say where a claim made there needs correction": dropped (REFRAME §2, §3).
  * The companion paper: cited in the first sentence of the introduction and in "Notation follows the companion paper".
  * Eisenstat's coin samplers covered by `thm:split:lambda1`: already in split.tex:47 ("such as the Bern$(1/3)$ threshold hypotheses in Sam Eisenstat's coin example (personal communication; see also \citet[Section~7.3]{claudeSFI2026fundamentals})"), and in the acknowledgements.
  * The earlier report: already in related.tex, `rem:related:t5` ("An earlier report \citep{claude2026whatfollows} formalised the proposal for a general imitation channel … We re-derive, rather than copy, the results we use from it").
  * $\lambda$-weighted MDL: already in related.tex, `rem:related:mdl` ("The closest prior work …", "We do not claim as new the qualitative finding that a bounded $\lambda$ fits the noise and that $\lambda$ must grow with $n$. Their target is the data distribution; ours deliberately differs from it …").
  * So no "other work" content had to move. **Note to p2-body:** the only detail of the deleted paragraph that related.tex lacks is the pinpoint "[Section~8]" in `\Citet[Section~8]{claude2026whatfollows}`. Add it to `rem:related:t5` if wanted; it is optional, and I did not edit related.tex.
* **Mathematics:** the paragraph stated no new mathematics.
  * The removed inline math ($\lambda$ three times, $n$ once) is in the MDL sentence, which is verbatim in `rem:related:mdl`.
  * The removed `\cref` targets are still cited elsewhere in the introduction: `thm:split:lambda1` in the contributions list and table row 8, `sec:related` in table row 10 and the reader's guide, `tab:intro:claims` in change 4. `rem:related:t5` is cited in related.tex and in the appendix.
* **Numbering:** an unnumbered `\paragraph` was removed. No numbered environment, section or equation was touched.

### 10. intro.tex, header comment (lines 1–6; invisible)
* **Old:** "… (DECISIONS §D1, §A6, §A11, §F29, §F30) … (the only verbatim quotation: "each input gets its own private randomness") … the one permitted footnote is in absorb.tex"
* **New:** "… (DECISIONS §D1, §A11, §F29, §F30; framing: REFRAME.md, which deletes the paragraph … and moves the credit to one footnote and the acknowledgements) … (no quotation) … the single footnote crediting the proposal (REFRAME §4, at its first statement below) also records the online discussion"
* **Why:** the old comment had become false. It is a comment only.

### 11. discussion.tex, acknowledgements (`\section*{Acknowledgements}`, line 30)
* **Old:** "… an AI system. Under the author's direction, Claude produced the proofs, the computations and the text; further, independent instances of Claude checked the proofs …"
* **New:** "… an AI system. Working from the author's notes \citep{hanni2026notes} and under the author's direction, Claude produced the proofs, the computations and the text. Several of the questions and examples studied here first appeared in those notes; the proposal first appeared in the author's note \citep{hanni2026grokking}. Further, independent instances of Claude checked the proofs …"
* **Why:** REFRAME §4.
  * Paper 2's acknowledgements did not yet contain the sentence "Working from the author's notes \citep{hanni2026notes} and under the author's direction, …" that REFRAME says to keep. I inserted it in Paper 1's form, by extending the existing "Under the author's direction" clause.
  * The required sentence follows verbatim, and `hanni2026grokking` is cited as the note in which the proposal first appeared.
  * The order matches Paper 1's acknowledgements.
  * Everything else is verbatim: the Eisenstat and Vaintrob paragraph, the report sentence, "No human has yet …" and "The author takes responsibility …".
* **Mathematics:** none involved.

### 12. discussion.tex, header comment (line 2; invisible)
"(§A4, exact texts for Paper 2)." became "(§A4, exact texts for Paper 2; framing: REFRAME.md §4 adds the notes and the credit sentence to the acknowledgements)." This is a comment only.

## Checked and left unchanged (implicit framing)
* **Abstract.** It reads as a first presentation. "the proposal" is the paper's object, and "A standard objection is …" attributes the objection to no one.
* **Intro "Conventions", "The main result", Theorem (informal), the sizes paragraph, "Scope and reader's guide".** None of them mentions the notes.
  * "makes the example rigorous" now refers to the example the introduction itself presents.
* **Discussion paragraphs "What counts as one hypothesis", "The window and its price", "The gap to realistic errors", "The model–randomness split", "Relation to other work".** None of them mentions the notes. The slides of Vaintrob and Hänni are cited as a normal joint reference ("which the slides of \citet{vaintrobhanni2026nnbayes} motivate"), which REFRAME §6 allows.
* **Open problems (1)–(7).** Mathematical questions, each with its `\cref`.
* **main.tex.** The title-page footnote is unchanged (REFRAME §7).

## Footnotes for credit (Paper 2 limit: 5)
* Mine: 1, at intro.tex:9 (change 2).
* p2-body's, at the time of my final grep:
  * absorb.tex:5, sequence-case pathology and private randomness;
  * teacher.tex, the example, its versions and the hull observation;
  * algstat.tex:6, the slope-change idea.
* Total: 4.

## Remaining visible citations of hanni2026notes / hanni2026grokking in my files (final grep)
* `intro.tex:9`, footnote to the proposal's first statement: "The notion of SFI first appeared in the author's working notes \citep{hanni2026notes}. The proposal first appeared in the author's note \citep{hanni2026grokking} and in an online discussion (on LessWrong), where the absorption point below was also raised."
* `discussion.tex:30`, acknowledgements: "Working from the author's notes \citep{hanni2026notes} and under the author's direction, Claude produced the proofs, the computations and the text. Several of the questions and examples studied here first appeared in those notes; the proposal first appeared in the author's note \citep{hanni2026grokking}."
* None in abstract.tex or main.tex.

Other hits of the grep are not references to the notes:
* "author": the protected ones only: the `\thanks` in main.tex ("under the author's direction"), and "under the author's direction" and "The author takes responsibility" in the acknowledgements. `authoryear` and `pdfauthor` in main.tex are package options.
* "notes": the footnote and the acknowledgements; `\footnotesize`; `%` comments.
* No hits for "draft", "conjectur", "as proposed", "anticipated", "intended", "the note" (outside the footnote and acknowledgements), "Hänni" or quotation marks.
* On `pdftotext main.pdf`, the introduction and the discussion show "note", "author" or "Hänni" only in the footnote, the acknowledgements and the reference keys "(Hänni, 2026a/b/c)".

## Invariants
* **Labels.** Identical in all four files (`sec:intro`, `tab:intro:claims`, `sec:discussion`, `sec:discussion:open`).
* **`\status` / `\src`.** My files contained none before and contain none now.
* **abstract.tex and main.tex.** Byte-identical to the originals.
* **discussion.tex.** The multiset of inline math and `\cref` arguments is identical to the original.
* **intro.tex.** The inline math differs only by the removed $\lambda$ (three times) and $n$ of the deleted MDL sentence (change 9), which is in `rem:related:mdl`. The `\cref` arguments differ as follows:
  * removed: `rem:related:t5`, one of two `sec:related`, `thm:split:lambda1` (still cited twice in intro), `tab:intro:claims` (moved);
  * added: `sec:absorb`, `rem:teacher:hanni`, `tab:intro:claims`.
* **Structure.** No section, subsection, numbered environment or equation was added or removed.

## Builds
* `./test-section.sh intro`: OK, 3 pages (was 4), 0 undefined citations.
* `./test-section.sh discussion`: OK, 3 pages, 0 undefined citations.
* `./test-section.sh abstract`: OK, 1 page.
* **Full build** (`flock … ./build.sh`, with p2-body's edits as they stood): 0 LaTeX errors, 0 undefined references, 0 undefined citations, 0 multiply defined labels, 0 overfull boxes >10pt, 57 pages. In the PDF the new references resolve: "(Section 4)", "(Remark 5.1)", "Table 1".
* **Length** (non-empty text lines of the isolated PDFs before References, original versus new):
  * intro: 125 → 121;
  * discussion: 78 → 80, all from the acknowledgements sentences that REFRAME §4 requires.
  * Together: 203 → 201.
* **Words in the sources:** intro 1682 → 1637; discussion 990 → 1032.

## Notes for p2-body
1. The proposal's credit footnote is in intro.tex:9 and includes the LessWrong discussion. The absorb.tex LessWrong footnote is already gone; do not reinstate it.
2. related.tex: nothing needs to move from the deleted paragraph (see change 9). Adding "[Section~8]" to the `claude2026whatfollows` citation in `rem:related:t5` is optional.
3. The table now calls the two versions of the calculation "per-sample" and "total-bits". If teacher.tex renames "Version 1/2", keep those descriptors.
