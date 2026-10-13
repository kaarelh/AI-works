# Reframe log: p1-front (Paper 1: abstract, intro, discussion with acknowledgements, main.tex)

Binding note: `research/paper-review/REFRAME.md` (2026-10-13). Files edited: `paper/sections/intro.tex`, `paper/sections/discussion.tex`. `paper/sections/abstract.tex` and `paper/main.tex` were read in full and left unchanged: the abstract never mentions the notes and frames nothing against them, and its "a coin example of Sam Eisenstat" is the attribution REFRAME §7 keeps. main.tex holds only the title-page footnote, which §7 keeps unchanged.

Originals for comparison: `git diff 5acf4db3 -- solomonoff-function-induction/paper/sections/{intro,discussion}.tex`.

## Changes

### 1. intro.tex, first paragraph (before `\paragraph{Why SFI.}`, under `sec:intro`)
* Old: "… labels every input. The notion was proposed in the author's working notes \citep{hanni2026notes}. We define SFI precisely, …"
* New: "… labels every input.\footnote{The notion of SFI first appeared in the author's working notes \citep{hanni2026notes}.} We define SFI precisely, …"
* Why: REFRAME §4. Credit for the notion moves from the running text into a short neutral footnote at its first mention. The footnote is in running text, not in a theorem-like statement or a float. It is the only footnote in my files.
* Mathematics: unchanged. The informal definition of SFI in the same sentence is untouched.

### 2. intro.tex, contributions list (`sec:intro:contrib`), bullet "History-aware prediction"
* Old: "For computable reveal laws, the dominance statement of the author's notes holds pathwise for deterministic reveal policies and, under finiteness hypotheses, in expectation with an additional $K(n)+K(A)$ term for randomised reveal laws; whether that term is needed is open. The proof sketch in the notes fails, and a stronger (oracle) reading is false (\cref{prop:hist:sketchfails,cor:hist:thm1,thm:hist:randchain,rem:hist:thm1open})."
* New: "For computable reveal laws $\Delta_f$, which may depend on the target $f$ but see only the history, SFI's loss exceeds that of every computable sampler $P$ that sees the history by at most $K(P)+K(\Delta_f)+c$ on every path for deterministic reveal policies and, under finiteness hypotheses, in expectation with an additional $K(n)+K(A)$ term for randomised reveal laws; whether that term is needed is open. A direct simulation argument fails, and the stronger oracle form, with the complexity of the reveal law measured relative to an oracle for $f$, is false (same \cref list)."
* Why: REFRAME §3 and §4 (wording from §4's example). The bullet now states the dominance theorem itself, so the reader no longer needs to know what "the dominance statement of the author's notes" was. The two negative results are described as a natural proof strategy that fails and a stronger natural form that is false.
* Mathematics: unchanged. The displayed bound is `cor:hist:thm1` as printed in hist.tex: (b) $\LSFI(D_n)\le L_P+K(\delta_f)+K(P)+c$ on every path for $x_i=\delta_f(h_{i-1})$; (a) the same in expectation with $+K(n)+K(A)$ under (A1), (A2). "Under finiteness hypotheses", "whether that term is needed is open" and the `\cref` list are kept verbatim. The oracle form is described exactly as Reading B in `def:hist:readings`: $C_\Delta$ is the complexity of $\Delta$ relative to an oracle for $f$, refuted by `thm:hist:randchain`. I deliberately did not write "the form in which the reveal law sees $f$ is false": reveal laws that see $f$, with standalone complexity, are an open case (`rem:hist:thm1open`, open problem (5)). $P$ ranges over computable samplers, which in `def:hist:predictor` take $(h,x)$, as in the old bullet's source statement. $c$ is the constant defined in "Two loss conventions".

### 3. intro.tex, paragraph "Relation to the author's notes." (after the contributions list): deleted
* Old: "\paragraph{Relation to the author's notes.} The notion of SFI, several of the questions … first appeared in the author's working notes \citep{hanni2026notes}; we cite those notes where they arise and say where a claim made there needs correction. Where those notes claim more than holds, the relevant section says so: … (\cref{prop:hist:sketchfails}), … (\cref{prop:ood:draftfalse}), … (\cref{prop:ood:converse}), … (\cref{rem:comp:majority,thm:comp:ladder}). The coin example of \cref{sec:ex:eisenstat} is due to Sam Eisenstat (personal communication). The material on neural-network Bayes, including the conjunction ladder …, builds on joint slides with Dmitry Vaintrob \citep{vaintrobhanni2026nnbayes}."
* New: nothing. As REFRAME §4 requires, nothing replaces the paragraph.
* Where its content now lives:
  * the notion of SFI: the footnote of change 1;
  * the questions and examples: the new sentence in the acknowledgements (change 7);
  * Eisenstat and Vaintrob: the first paragraph of the acknowledgements (unchanged), "Sam Eisenstat's coin example" in Theorem D (informal), and the citation of the slides in "Relation to neural-network Bayes";
  * the "corrections" list: dropped from the introduction (REFRAME §3, §4). Those results stay in the body as natural statements, under their owners' reframing.
* Every dropped `\cref` target still exists and is still cited:
  * `prop:hist:sketchfails`: kept in the bullet of change 2;
  * `prop:ood:draftfalse`: ood.tex, app-ood.tex;
  * `prop:ood:converse`: ood.tex, related.tex;
  * `rem:comp:majority`: Discussion and comp.tex;
  * `thm:comp:ladder`: the contributions list and the acknowledgements;
  * `sec:ex:eisenstat`: Discussion (acknowledgements) and examples.tex.
* Numbering: an unnumbered `\paragraph` is removed; no section, subsection, environment or equation is touched.
* Mathematics: the paragraph contained no mathematical statement.

### 4. intro.tex, header comment (lines 1–2; invisible)
* Old: "% Introduction (arXiv conversion: …DECISIONS.md §A6, §A11, §D1, §F2). …"
* New: "% Introduction (arXiv conversion: …DECISIONS.md §A11, §D1, §F2; framing: REFRAME.md, which replaces the paragraph "Relation to the author's notes" by footnote credit and the acknowledgements). …"
* Why: §A6 is superseded. This is a comment only.

### 5. discussion.tex, `\paragraph{What the hypotheses may see.}`, last sentence
* Old: "… and even with the list, ``as good as Solomonoff induction'' holds against SI's joint loss, not automatically against its conditional label loss (\cref{thm:hist:si,prop:hist:inputloss})."
* New: "… and even with the list, the loss of \SFIhist{} is at most SI's joint loss plus a constant, not automatically at most SI's conditional label loss plus a constant (same \cref)."
* Why: REFRAME §5. The quotation marks around the author's slogan are gone, and the slogan is replaced by what is proved.
* Mathematics: unchanged. `thm:hist:si`(a) is $\LH\le\LMjoint+c$, one-sided, so the new text is deliberately one-sided rather than "within a constant". By `prop:hist:inputloss`, $\LH-\LMy$ is governed by $\LMx$, hence "not automatically".

### 6. discussion.tex, `\paragraph{Which version to call SFI.}`
* Old: "We call $\MF$ SFI because it formalises the definition in the author's notes, it has a posterior over functions, …"
* New: "We call $\MF$ SFI because it formalises directly the informal definition (a random program labels every input), it has a posterior over functions, …"
* Why: REFRAME §2 lists this exact phrase. The reason is now one of mathematical naturalness, and refers to the informal definition given in the first paragraph of the introduction.
* Mathematics: unchanged. The other four reasons, the constant $2^{-K(\nu)}$ and `\cref{rem:setting:recommend}` are verbatim.

### 7. discussion.tex, acknowledgements (`\section*{Acknowledgements}`), second paragraph
* Old: "… Working from the author's notes \citep{hanni2026notes} and under the author's direction, Claude produced the proofs, the computations and the text. Further, independent instances …"
* New: "… Working from the author's notes \citep{hanni2026notes} and under the author's direction, Claude produced the proofs, the computations and the text. Several of the questions and examples studied here first appeared in those notes. Further, independent instances …"
* Why: REFRAME §4. This is the exact sentence, placed directly after the "Working from the author's notes" sentence so that "those notes" has its antecedent. The rest of the acknowledgements, including the Eisenstat and Vaintrob paragraph, is unchanged.
* Mathematics: none involved.

### 8. discussion.tex, open problems item (7)
* Old: "… for which the intended answers of \cref{ex:ood:hanniexamples} get posterior probability close to $1$ (\cref{conj:ood:natural})?"
* New: "… for which the correct answers of \cref{ex:ood:hanniexamples} get posterior probability close to $1$ …?"
* Why: the examples come from the notes, so "intended" next to them could read as "intended by the notes". "Correct" is the word ood.tex itself uses for these examples: "the correct label" in (a), "The correct answer has probability at least $2^{-c}$" in (c).
* Mathematics: unchanged. In each example the answer is the value of the target rule. Note to p1-ood: `conj:ood:natural` still says "the intended answers". That is harmless, but p1-ood may align it.

### 9. discussion.tex, header comment (invisible)
* "§F23)." became "§F23; framing: REFRAME.md §4)." This is a comment only.

## Checked and left unchanged (implicit framing)
* **Abstract.** No reference to the notes. It is in "we" voice ("We study its analogue …").
* **Intro "Why SFI", "Relation to Solomonoff induction" and Theorems A–D (informal).** These motivate SFI by the analogy with SI and by supervised learning. Theorem D keeps "Sam Eisenstat's coin example" (REFRAME §7).
* **Intro "Relation to neural-network Bayes" and "What is not achieved".** They cite the slides `vaintrobhanni2026nnbayes` as a normal joint reference ("the slides … argue …"; "We do not prove the main theorems of the slides"). This is allowed by REFRAME §6.
* **Discussion paragraphs on computable versions, networks and the companion paper.** No notes framing. "which is what the slides … claim for small prior scales" is allowed by §6.
* **Open problems (9).** "does the main theorem of the slides hold as stated" concerns the joint slides (§6) and states a mathematical question.
* **main.tex.** The title-page `\thanks` is unchanged, as §7 and DECISIONS §A4 require.

## Footnotes added
1 (intro, change 1). For the Paper 1 count of at most 10: this footnote credits the notion of SFI. **Note to p1-setting:** a footnote in setting.tex need not repeat "the notion of SFI first appeared in the notes". It can cover the setting-specific items: the wording of the informal definition, private tape streams, and the encoding remark from the earlier draft.

## Remaining visible citations of hanni2026notes / hanni2026grokking in my files (final grep)
* `intro.tex` line 6, footnote to the first paragraph: "The notion of SFI first appeared in the author's working notes \citep{hanni2026notes}."
* `discussion.tex` line 32, acknowledgements: "Working from the author's notes \citep{hanni2026notes} and under the author's direction, Claude produced the proofs, the computations and the text. Several of the questions and examples studied here first appeared in those notes."
* `hanni2026grokking`: none in Paper 1's front files.
* Other hits of "author" are the protected ones: the title-page `\thanks` in main.tex ("under the author's direction"), and "under the author's direction" and "The author takes responsibility …" in the acknowledgements. There are no hits for "notes", "draft", "conjectur", "as proposed", "anticipated", "intended" or quotation marks in the visible text. The comment headers mention REFRAME.md and the deleted paragraph's title; they are invisible.

## Invariants
* **Labels.** Identical in all four files (`sec:intro`, `sec:intro:results`, `sec:intro:contrib`, `sec:discussion`, `sec:discussion:open`).
* **Structure.** No section, subsection, environment or numbered equation added or removed. The `\section*` acknowledgements and code-and-data headings are unchanged.
* **`\status` and `\src`.** My files contain no `\status`/`\src` calls, before or after.
* **abstract.tex and main.tex.** Byte-identical to the originals.
* **discussion.tex.** The multiset of inline math and `\cref` arguments is identical to the original.
* **intro.tex.** The math and `\cref` arguments differ from the original only as follows:
  * removed with the deleted paragraph: the `\cref`s listed in change 3 and `$K(f)$`;
  * added in change 2: `$\Delta_f$`, `$f$` (twice), `$P$` and `$K(P)+K(\Delta_f)+c$`, which restate `cor:hist:thm1`.

## Builds
* `./test-section.sh intro`: OK, 4 pages, 0 undefined citations (undefined cross-section references expected).
* `./test-section.sh discussion`: OK, 3 pages, 0 undefined citations.
* `./test-section.sh abstract`: OK, 1 page.
* **Length** (text lines of the isolated PDFs before References, original versus new):
  * intro: 146 → 121;
  * discussion: 99 → 99. The new acknowledgements sentence is offset by the shorter rewrites.
* **Words in the sources:** intro 1685 → about 1620; discussion 1302 → about 1325.
* **Full build.** Not run by this group in this step, because other groups are editing in parallel. main.tex is unchanged.
