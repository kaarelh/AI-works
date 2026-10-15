# One-tape definition of SFI: fresh reader's report (2026-10-13)

## What was read

- **Paper 1** (`paper/main.pdf`, built 11:19, after the last source edit at 11:18). Text extracted with `pdftotext -layout`; "l." below means a line of that output.
  - the abstract;
  - Section 1 up to the reader's guide, and the SFI sentence of Section 2;
  - all of Section 3;
  - Section 4: the opening, Definition 4.1 and the paragraph after it, Remarks 4.2 and 4.3, Theorem 4.4, Propositions 4.5 and 4.6, Remark 4.12 and Table 1;
  - Section 5: the opening, Theorem 5.1 and Remark 5.12;
  - Section 11 and Section 12 up to the open problems.
- **Paper 1 sources:** the matching `paper/sections/*.tex`, and `rem:versions:Wdelim` and `rem:versions:Wrate` in `app-versions.tex`.
- **Paper 2:** the abstract, the introduction, and the table "Objects from the companion paper" (Section 3, `setup.tex`).
- **Notes:** `DECISIONS.md`, `REFRAME.md` and `onetape/log-edit.md`.
- No file was edited apart from this report.

## Verdict

- **(a) One random object.** Mostly unmistakable.
  - Strong:
    - the introduction's first paragraph ("The same sequence serves every query");
    - the opening of Section 3 ("The same ω serves every query: the coin flips are shared by all inputs, not drawn afresh at each input");
    - Definition 3.15;
    - the paragraph after Theorem 3.8 ("one tape read in two parts, not a second source of randomness").
  - Two short descriptions can still be read as "one sequence per input": the abstract (R1) and Section 2 (R2).
- **(b) Wording that suggests two kinds of randomness.** None is left in Paper 1.
  - Searches for "random program", "reading random bits", "labels every input", "pick machine", "then a random tape" and "probabilistic program" over `paper/sections/*.tex` find nothing.
  - The remaining "program + coins" wording is the representation after Theorem 3.8, Remark 4.3, Remark 4.12(2) and Remark 5.12(1). Each presents it as a reading of the one tape.
- **(c) W as the coin-free version.** Yes. It comes directly after Definition 4.1.
  - Every claim matches the cited statement:
    - `thm:versions:chain`;
    - `prop:versions:tape`(a), last sentence, and (b) with |D| = 2;
    - `prop:versions:Wgap`, "M_F/W unbounded";
    - `rem:versions:Wrate`, "≤ 2 log(h(d)+2) + O_h(1)", proved through (c).
  - The extra term K(dom D) in the minimum follows from the chain together with 2^{-K_F} ≤ W, as `log-edit.md` says.
  - Flow problem: the passage is now one 26-line paragraph that also carries the W(∅) sentence and the AIT terminology (R7).
- **(d) Flow.** Good on the whole. Three places need work:
  - the opening of Section 3 says "U is T_U" and then treats U as arbitrary (R3);
  - the heading of the paragraph after Theorem 3.8 announces the definition again, and the paragraph uses "universal" before defining it (R5);
  - "special cases" in the Section 3 opening has no clear referent (R4).
  - The abstract is 1884 source characters (limit 1920). It would be 1889 after R1.
- **(e) Consistency.** The abstract, the introduction, Section 3, Section 4, Remark 5.12 and the discussion describe the same object in compatible words. The one internal inconsistency is R3.

## Findings and exact replacements

The findings are ordered by importance. "old" is the current source text, and each "old" string occurs exactly once in its file (checked by script). All replacements leave the mathematics, labels, `\status`/`\src` calls, footnote count and numbering unchanged. Together, R1 to R9 add about 26 source characters net.

### R1 (important): the abstract can be read as one sequence per run

- **Location:** PDF p.1, l.12–14; `sections/abstract.tex` l.3.
- **Problem:** "a universal Turing machine, run separately on each input, reads one infinite sequence of fair coin flips". A first-time reader can take "one … sequence" to mean one sequence for each run. The abstract is the only place where many readers meet the definition. Its whole point, one tape shared by all inputs, rests on that word.
- **old:** `reads one infinite sequence of fair coin flips from its first bit`
- **new:** `reads the same infinite sequence of fair coin flips from its first bit`
- **Length:** +5 characters, so the abstract would be 1889 of 1920.

### R2 (important): Section 2 says "one sequence ... for every input"

- **Location:** PDF p.5, l.221–222; `sections/related.tex` l.14 (paragraph "Solomonoff induction and operator induction").
- **Problem:** "reads one sequence of fair coin flips for every input". In English, "one X for every Y" usually means one X per Y, which is the private-randomness reading (M_prod) that the paragraph then contrasts with SFI.
- **old:** `the law of a universal machine that reads one sequence of fair coin flips for every input.`
- **new:** `the law of a universal machine that reads the same sequence of fair coin flips on every input.`

### R3 (moderate): "Formally, U is T_U" conflicts with the paragraph after Theorem 3.8

- **Location:** PDF p.7, l.305–306; `sections/setting.tex` l.4 (section opening).
- **Problem:** The opening introduces U as any universal Turing machine and then says "Formally, U is the universal function machine T_U". Two pages later, the paragraph after Theorem 3.8 treats U as an arbitrary universal machine again and compares ν_U with M_F = ν_{T_U}. That comparison is trivial if U = T_U.
  - The subscript of T_U also reads as "the machine of U".
  - Fix: let SFI *use* T_U, without identifying U with it.
- **old:** `Formally, $U$ is the universal function machine $T_U$ of \cref{thm:setting:universal} (\cref{def:setting:sfi}); every universal machine gives the same law up to a constant factor.`
- **new:** `Formally, SFI uses the universal function machine $T_U$ of \cref{thm:setting:universal} (\cref{def:setting:sfi}); every universal $U$ gives the same law up to a constant factor.`

### R4 (moderate): "special cases" in the Section 3 opening has no referent

- **Location:** PDF p.7, l.307–308; `sections/setting.tex` l.4.
- **Problem:** The sentence "Deterministic programs and private random streams per input are special cases (Proposition 3.9)" follows sentences about SFI and U. So it reads as "special cases of SFI", which again suggests that SFI's randomness could be private. In the old text the referent was "one random tape read by all inputs (def:setting:machine)", and that referent is gone. Also, "private random streams" are not hypotheses, but samplers that use them are.
- Optional: move the footnote of this paragraph, which credits "the private random stream per input", from the end of "… not drawn afresh at each input." to the end of this sentence, where private streams are named. This changes no footnote count.
- **old:** `Deterministic programs and private random streams per input are special cases (\cref{prop:setting:includes}), and \cref{sec:versions} compares the variants.`
- **new:** `Deterministic programs and samplers with a private random stream per input are non-universal machines of this kind (\cref{prop:setting:includes}), and \cref{sec:versions} compares the variants.`

### R5 (moderate): the heading and order of the paragraph after Theorem 3.8

- **Location:** PDF p.9, l.423–426; `sections/setting.tex` l.60 (unnumbered `\paragraph`).
- **Problem:** The definition now opens the section, so the heading "SFI as one universal machine on one random tape" announces it a second time. What the paragraph actually proves is that the choice of U does not matter. Its first sentence also claims something about "every universal Turing machine U" before the paragraph defines "universal" (three sentences later).
- **Fix:** retitle the paragraph, define universality first, then state and prove the claim. The proof is unchanged. The heading is not referenced anywhere else (grep over `*.tex` and `*.md`).
- **old (start):** `\paragraph{SFI as one universal machine on one random tape.} Every universal Turing machine $U$ in the informal definition gives $\MF$ up to a constant factor. As noted after`
- **new (start):** `\paragraph{The choice of universal machine.} Let $U$ be a Turing machine as in the informal definition. As noted after`
- **old (middle):** `$T_U$ is universal, with $p_T$ a $V$-program for an index of $T$. By \eqref{eq:setting:mixture},`
- **new (middle):** `$T_U$ is universal, with $p_T$ a $V$-program for an index of $T$. Every universal $U$ gives $\MF$ up to a constant factor: by \eqref{eq:setting:mixture},`
- Everything else in the paragraph stays as it is.

### R6 (minor): Theorem A repeats "one random tape for all queries"

- **Location:** PDF p.3, l.115–116; `sections/intro.tex` l.18 (Theorem A (informal)).
- **Problem:** The text says "answers queries as in the definition of SFI above, reading one random tape for all queries, but need not be universal". The clause "as in the definition of SFI above" already includes the shared tape. The repetition is the third statement of the same point within one page.
- **old:** `A \emph{function machine} is a Turing machine that answers queries as in the definition of SFI above, reading one random tape for all queries, but need not be universal.`
- **new:** `A \emph{function machine} is a Turing machine that answers queries as in the definition of SFI above but need not be universal.`
- **Length:** −42 characters.

### R7 (minor, flow): the paragraph after Definition 4.1 is one 26-line block

- **Location:** PDF p.12–13, l.612–640; `sections/versions.tex` l.18.
- **Problem 1:** The coin-free passage, the sentence that W(∅), M_prod(∅) and M_pq(ε‖ε) are below 1, and the AIT terminology form one paragraph. A paragraph break after the W passage lets the reader see where the one-line relation to M_F ends.
- **old:** `\cref{rem:versions:Wrate}). $W(\emptyset)$,`
- **new:** `\cref{rem:versions:Wrate}).` + blank line + `$W(\emptyset)$,`
- **Problem 2:** "The gap is unbounded … but small" reads as a contradiction until the colon. Say what the bound shows. This also matches the discussion's "small on the known witnesses".
- **old:** `(\cref{prop:versions:Wgap}) but small: on`
- **new:** `(\cref{prop:versions:Wgap}) but grows slowly: on`

### R8 (minor): Remark 4.3 puts K_F under "apart from the choice of a program"

- **Location:** PDF p.13, l.644; `sections/versions.tex` l.25 (`rem:versions:randomness`).
- **Problem:** "Apart from the choice of a program, there is no randomness in W and K_F". K_F chooses no program at random; it takes the shortest one. Only W draws a program.
- **old:** `Apart from the choice of a program, there is no randomness in $W$ and $\KF$;`
- **new:** `There is no randomness in $\KF$, and none in $W$ beyond the choice of a program;`

### R9 (minor, precision): the "Equivalently" sentence after Definition 3.6

- **Location:** PDF p.8, l.397–399; `sections/setting.tex` l.45.
- **Problem:** "on query x it reads finitely many bits of a one-way random tape and halts with a label or diverges". A diverging run may read infinitely many bits. The informal definition, which this sentence points to, says "as many bits as it needs".
- **old:** `on query $x$ it reads finitely many bits of a one-way random tape and halts with a label or diverges; all queries read the same tape.`
- **new:** `on query $x$ it reads a one-way random tape and either halts with a label after finitely many bits or diverges; all queries read the same tape.`

### R10 (optional, flow): an abrupt topic change in the paragraph after Theorem 3.8

- **Location:** PDF p.9, l.419–422; `sections/setting.tex` l.58.
- **Problem:** The paragraph explains the one-tape reading of (1), then turns without a break to random total functions ("If every conditional of an order-independent predictor q sums to 1 …"). A paragraph break makes the representation paragraph stand alone.
- **old:** `on $T_i$ after $D$. If every conditional`
- **new:** `on $T_i$ after $D$.` + blank line + `If every conditional`

## Checked and fine (no change)

- **Introduction, first paragraph** (`intro.tex` l.6). The one-tape definition is clear and complete: one sequence, a separate run per query, the same sequence for every query, then conditioning.
  - Optional style point: "each query $x$ is a separate run on $x$" could read "each query $x$ is answered by a separate run on $x$". The same applies in the opening of `setting.tex`. If either is changed, change both.
- **Paragraph after Theorem 3.8.** "one tape read in two parts, not a second source of randomness" says exactly what item 2 of the agreed change asks for, and it matches the proof in `app-setting.tex`.
- **`def:setting:sfi`** ("of one tape ω∼𝕌, read by every query") and **`rem:setting:recommend`** ("the law of the one-tape definition at the start of this section") are consistent with the opening, with or without R3.
- **The W passage** (`versions.tex` l.18). It starts "W is the coin-free version of SFI". Every bound is as stated in the cited results (see the verdict). The terminology sentence is kept.
- **"Shared by all inputs"** appears exactly once in Section 3 (the opening) and once in Remark 4.3, each time set against fresh coins. The uses in Proposition 4.7 ("shared by all inputs of that length") and Section 2 ("sharing randomness across inputs") are different statements and are fine.
- **Remark 4.12(2)** ("Coin flips or not … coin flips beyond the program matter little") and **Remark 5.12(1)** ("with the tape read as a program followed by its coin flips") present the split as a reading of the one tape.
- **The discussion's "Which version to call SFI"** ("the program mixture, SFI's coin-free version"; "the law of the one-tape definition (one universal machine, one sequence of coin flips)") is consistent with Sections 3 and 4.
- **Section 11** (Paper 1's summary of Paper 2) says "SFI with shared randomness". There it names Paper 2's hypothesis class, set against product hypotheses, so item 7 leaves it as it is.
- **Paper 2.** It describes SFI only as "a universal prior over random (partial) functions" (abstract and introduction), and its table describes "one random tape ω ∼ 𝕌 that all inputs share" and M_F as "the law of the universal function machine". Nowhere does it describe SFI as a random program reading random bits, so no change is needed.

## Mechanical checks

- **Abstract length:** the source between `\begin{abstract}` and `\end{abstract}`, stripped, is 1884 characters now and 1889 with R1.
- **Structural tokens:** for `abstract`, `intro`, `related`, `setting`, `versions`, `learn` and `discussion`, the multiset of `\begin{…}`, `\label{…}`, `\section`, `\subsection`, `\status{`, `\src{` and `\footnote` tokens is identical in `HEAD` and the working tree.
- **Companion numbers:** `python3 -I research/paper-review/scratch/editor/check_companion_numbers.py` ends with "ALL OK". Every number that Paper 2 cites from Paper 1 is unchanged.
- **Running-text references to the notes:** none were added. The only `hanni2026notes` citations in `setting.tex`, `intro.tex` and `versions.tex` are the existing credit footnotes.
- **Layout:** since this pass, the heading of §5.1 moved to p.17 and left blank lines at the foot of p.16 (as `log-edit.md` records). R6 and R7 do not change the line count much. This is cosmetic and needs no action.
