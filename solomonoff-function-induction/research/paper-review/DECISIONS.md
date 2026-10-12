# Lead editor's decisions for both papers (binding for every editor group)

Paper 1: `paper/` ("Solomonoff Function Induction: Definitions, Versions and Basic Theorems").
Paper 2: `paper-steeper/` ("Steeper Simplicity Priors in Solomonoff Function Induction").
Inputs: the six reviews in `p1/` and `p2/` (367 issue records under 353 distinct ids, including the 18 issues P2M-25 to P2M-42 that the second pass of the Paper 2 mathematical review added at 18:53), the binding notes at the top of both `OUTLINE.md`, the refereed track records `research/tracks/*/notes-final.md` and `research/00-brief.md`.
Outputs of this decision pass: this file; the issue lists `edits/{p1-front,p1-setting,p1-hist-ex,p1-ood,p2-body,p2-front}.json`; `edits/rejected.json`; the helper table `edits/status-rendering.md` (every non-plain `\status`, with its required rendering). Independent checks of the lead editor are in `scratch/editor/`.

Every merged issue in the `edits/*.json` files carries the reviewers' ids it absorbs, the lead editor's verdict, the severity after verification, and the required fix. Where an issue says "see §F7" or similar, the exact text is in this file. **Where this file and a reviewer's suggested fix disagree, this file wins.**

---

## V. Verification of the reviewers' fatal and major issues (summary)

The reviews contain 10 distinct fatal and 144 distinct major issues (159 records; the two P1 arXiv passes and the two P1 C runs overlap). The lead editor checked every one against the paper sources and the track records; the verdict and the evidence are in the `verdict` and `evidence` fields of the merged entries (`edits/*.json`, field `source_ids` lists the reviewers' ids) or in `rejected.json`.

* **All 10 fatal issues are confirmed:** the abstract's reveal-law sentence and order-blindness sentence (P1X-01, P1X-02) and the introduction's reveal-law claim (P1-ARX-01); the unsupported k-point gap of the shortest program (P1A-01, the source states it without proof); the false non-existence of a pointwise bound on e(x\*) (C-01, stronger than the source, which only says its argument does not give one); "t_n doubly logarithmic" (C-02); the discussion's "provably fails" for structured human errors (P2X-01); "refuted for some error rules" in Paper 2's Table 1 (P2X-46); the false claim that a class's own mixture attains K(y_D | dom D)+O(1) (P2M-01; refuted by Paper 1's swap example); "(Dom) fails in every product class" (P2M-02; a one-program class is a counterexample).
* **Raised to fatal:** P2M-03 (the λ_n/n → 0 schedule claim is false on the paper's own instance; the source's finite-domain caveat was dropped; it is repeated in the introduction). P1-ARX-02 and MB-04 are merged into the fatal abstract entry.
* **Majors:** 137 confirmed as major (plus the three merged into fatal entries above). For 51 of the 154 fatal and major ids the required fix differs from the reviewer's proposal, mainly because the reviewer asked for reading new literature, for a new argument, for deleting rather than redefining the tags, or for a label rename (see the verdicts "accepted (modified)" and `rejected.json`). Lowered to minor: P1-ARX-05 (an error in the internal ledger, not printed), P1-ARX-49 and P2X-28 (comments in the uploaded source: packaging step). Rejected: P1X-17 (decision-complexity literature is not in the sources). One factual error of a reviewer is corrected: P1X-32 says the notes repository is not public; it is (P1-ARX-25).
* **Independent checks by the lead editor** (`scratch/editor/`): extraction of all 256 `\status` calls and the 278 `\src` calls (`extract_status.py`, `status_p1.json`, `status_p2.json`); the Wyeth, request and LessWrong citation counts; the reading of the history notes' "Verdict on Thm 1", the foundations notes' "What the differences mean", the context notes' "Reading" after Prop 2.16 and Cor 3.2b, the steeper notes on t_n and on the envelope's deficiency, the e5 grammar script (line 88), and the slides (lines 855–866, 2830–2841); the arithmetic of P2M-03 (n^{-0.1} ∈ (2^{-20}, 8.06·10^{-3}] for n ∈ [8.6·10^{20}, 2^{100}]); the waiting-sampler argument of C-01; Section 8 of the earlier report.

**Counts per group** (merged issues; fatal / major / minor): p1-front 32 (3 / 20 / 9); p1-setting 41 (1 / 19 / 21); p1-hist-ex 29 (0 / 14 / 15); p1-ood 41 (2 / 18 / 21); p2-body 50 (3 / 18 / 29); p2-front 28 (3 / 17 / 8). Rejected (in full or in part): 27 entries. Every one of the 353 reviewer ids is in at least one merged entry or in `rejected.json` (checked by `scratch/editor/make_edits.py`).

---

## 0. Editor rules (all groups)

1. **Sources of claims.** Only `research/tracks/{foundations,history,examples,context,steeper}/notes-final.md` (with `referee.md` and `checks/`), `research/00-brief.md` and the author's notes in `research/prior/`. No new mathematics, no new literature claims. Several reviewers propose new arguments (a pointwise bound on e(x\*), a K(⌈C_dir⌉)-advice closure of the minimax gap, a normalised transfer for the swap example, a proof that L_{1/2} is unbounded); these are **not** added (see `rejected.json`). Where a claim in the paper is unproved, the fix is to delete or weaken it, not to prove it.
2. **Corrections of evident slips** (wrong index, wrong summation range, wrong rounding) are allowed when the issue entry says so; the claim they support must not change.
3. **No label renames.** Labels stay exactly as they are, including `rem:absorb:wyeth` (the binding note allows it; it is invisible). New labels may be added (e.g. `sec:computable` in Paper 2, `rem:comp:runtime` in Paper 1).
4. **Grep before deleting or moving a labelled item.** Before deleting an environment, a table or a section, run `grep -rn '<label>' paper/sections paper-steeper/sections` and fix every reference first. When an environment becomes prose (a remark turned into a related-work paragraph), keep its label on the new paragraph so existing `\cref`s still resolve. When a labelled item moves to a file owned by another group, the giving group deletes it and the receiving group inserts it (with the same label); both record the move in their edit log. The final full build must show no undefined and no multiply defined labels.
5. **File ownership.** Edit only your group's files (list below). Cross-group needs go to the owning group through its issue list or edit log. `CLAIMS.md`, `OUTLINE.md` and `NOTATION.md` may be updated by the front group of the same paper only where an issue says so.
6. **Builds.** Isolated checks only via `./test-section.sh <section> <appendix>` from the paper folder (undefined references to other sections are expected there). Full builds only via `flock /tmp/claude-0/paper-build-sfi.lock ./build.sh`, run by the front group of the paper, and only at the end of a phase (§H).
7. **No git commands that change repository state** during the edit pass.
8. **Logs.** Each group writes `research/paper-review/edits/log-<group>.md`: for each issue id, what was changed (file, label), or why not; page counts of its sections after the last isolated build; every moved or deleted label.

**Groups and files**

| group | files |
|---|---|
| p1-front | `paper/sections/abstract.tex`, `intro.tex`, `discussion.tex` (incl. acknowledgements, code and data), `paper/main.tex`, `paper/preamble.tex`, `app-verification.tex` (switch only), `paper/bib/*.bib`, `paper/NOTATION.md`, `paper/CLAIMS.md` |
| p1-setting | `setting.tex`, `versions.tex`, `learn.tex`, `app-setting.tex`, `app-versions.tex`, `app-learn.tex` |
| p1-hist-ex | `hist.tex`, `examples.tex`, `app-hist.tex`, `app-examples.tex` |
| p1-ood | `ood.tex`, `comp.tex`, `nn.tex`, `related.tex`, `steeper.tex`, `app-ood.tex`, `app-comp.tex`, `app-nn.tex` |
| p2-body | `paper-steeper/sections/{setup,absorb,teacher,limits,split,algstat,related}.tex`, all `app-*.tex` except `app-verification.tex`, and the new `computable.tex` (§D2) |
| p2-front | `paper-steeper/sections/{abstract,intro,discussion}.tex`, `paper-steeper/main.tex`, `paper-steeper/preamble.tex`, `app-verification.tex` (switch only), `paper-steeper/bib/*.bib`, `paper-steeper/CLAIMS.md` |

---

## A. The arXiv conversion

### A1. How each status is rendered

The status tags stay in the sources during the edit pass (they are the record of what each item is). Each group renders, in visible text, the information that a non-plain status carries. `edits/status-rendering.md` lists all 119 non-plain statuses of Paper 1 (116 in environments, 3 inline) and all 47 of Paper 2, with the group and the required rendering. The categories:

| status (or part) | rendering in the PDF |
|---|---|
| `proved` | Theorem / Proposition / Lemma / Corollary with its proof (or "Proof." in the appendix with a pointer). Nothing else. |
| `proved; computed (…)` with no number from the computation in the text | Nothing to add; the Code and data statement covers the computation. |
| `computed` number quoted in the text | Introduce it with "A direct computation (code in the accompanying repository) gives …". The number goes **outside** any theorem-like statement: a sentence after it, or an "Example (computation)" / "Remark" after it (§A9). Never a script identifier (c3, r12, e6(f), `c7_run2.py`), never a track name. |
| `computed; illustration` (Paper 2 κ = 0 numbers, `ex:split:noisyparity`, `prop:ex:cycsi`'s finite illustration) | `\begin{example}[… (an illustration)]` or a sentence "For illustration, with the machine constant set to 0, a direct computation gives …". Must say that it is not a value for any fixed reference machine. |
| `proof sketch` (whole item) | The environment stays a Remark (never a theorem); its argument is headed `\emph{Proof sketch.}`; the first sentence says what is not written out ("We do not fix the machine model or analyse the clocks."). |
| `(a) proved; (b) proof sketch` (part of a statement) | Split: the theorem keeps only the proved part; the sketched part goes into a Remark after it whose argument is headed "Proof sketch." (§F3, §F5). |
| `conjecture` | `\begin{conjecture}` with a precise statement, followed by "We have neither a proof nor a counterexample." No "(untested)". An imprecise "conjecture" becomes a `question` (§A10). |
| `conditional (on X)` | X becomes an `\begin{assumption}[name]` environment (already defined in the preamble); the proposition says "Under Assumption …". The text before it says, in one sentence, where the assumption comes from and that it is not proved here. |
| `refuted` / `a natural reading refuted` | Only where it informs the reader, phrased "The natural strengthening … fails: …" or as a proposition titled by what it shows ("The literal two-sided bounds fail"). No mention of who held the refuted view, no "an earlier version", no internal correction history. |
| `open` / `… open part` | The open part becomes a `question` environment (§A10) or a sentence pointing to one; the proved part stays. |
| `known` with a checked citation (standard results) | Cite in the heading or the first sentence: "(standard; see [LV08])", "(cf. [Lit88, BF72])". |
| `known; unverified` / `known (snippet)` | Keep the citation only for what the cited work's title or abstract says (as recorded in the track notes), stated plainly ("X show that …" only for abstract-level content; otherwise "cf. [X]"); anything beyond the abstract is either the paper's own reading, stated as such ("We read operator induction as …"), or deleted. Never print "unverified", "snippet", "abstract seen only", "not checked" (§A8). |
| `known; unverified (claimed in the slides)` | "The slides of Vaintrob and Hänni [VH26] state … (we do not prove these claims here)"; list what this paper proves of them. |
| `remark`, `remark (cited items)`, `remark; known` | Plain Remark; the qualifier disappears. |
| `proved (corrected)`, `proved (trivial)`, `proved (given …)`, `proved (citing)`, `proved under the stated hypotheses` | Plain; the qualifier disappears (the hypotheses are in the statement). "(given the coding theorem)": the coding theorem is cited where it is used. |

### A2. Removal of `\status` and `\src`

1. During phases 1–2 (§H) every group renders the information of its tags in prose (A1, `status-rendering.md`) and records in its log, for each non-plain status, "rendered as: …".
2. **Inline calls are deleted from the source by hand** (a redefinition would leave stray spaces or table cells): `setting.tex:40`, `app-versions.tex:92`, `app-versions.tex:102` (Paper 1, inline in prose), and the `\status{computed}\src{…}` inside the floats `tab:ex:cycle` (`app-examples.tex:133`) and `tab:ex:eisenstat` (`app-examples.tex:164`).
3. `\src` notes that carry credit (grep result in `scratch/editor/`): Paper 1 `examples.tex:31,108` ("Hänni's request": replaced by the Eisenstat / author credit of §A7), `nn.tex:80` (slides: credited in `rem:nn:slides`), `versions.tex:137` (draft: §A7). Paper 2: 16 notes name "T5 …" results; this credit is carried by the correspondence table `app:related:t5`, which stays (p2-body checks that every T5 item named in a `\src` appears in it).
4. **Phase 3, last step of the edit pass (front groups):** append to the macro block of both preambles, after all groups have reported that their statuses are rendered:
   ```latex
   % arXiv version: status tags and source notes are not printed (their content is rendered in the text).
   \renewcommand{\status}[1]{}
   \renewcommand{\src}[1]{}
   ```
5. **Grep check before the redefinition** (front groups, recorded in their logs): `python3 research/paper-review/scratch/editor/extract_status.py` re-extracts every remaining `\status` (it rewrites `status_p1.json`, `status_p2.json` and prints the number of calls outside an environment); that number must be 0, no call may sit inside a `table` float, and every non-plain status must have a "rendered as" entry in some group log. Also `grep -n 'src{[^}]*\(slides\|T5\|request\|draft\|known\)' sections/*.tex` and confirm that the credit or attribution each such note carries is in the visible text (item 3). After the redefinition, `pdftotext main.pdf - | grep -n -E '\[(proved|computed|conjecture|known|proof sketch|refuted|remark)'` must return nothing.
6. The `\status`/`\src` calls and all `%` comments remain in the working sources. Stripping them (and the process-vocabulary comments) from the files uploaded to arXiv is a **packaging step at submission time**, not part of this pass (§A12).

### A3. The verification appendices

* Paper 1: replace the last `\input{sections/app-verification}` in `main.tex` by the same switch as Paper 2, set off:
  ```latex
  \newif\ifsfirecord
  \sfirecordfalse   % internal verification record, not part of the arXiv version
  ...
  \ifsfirecord\input{sections/app-verification}\fi
  ```
  and delete the comment lines 36–38 that describe the conversion.
* Paper 2: change `\sfirecordtrue` to `\sfirecordfalse` (and shorten the comment to one line).
* Keep both `app-verification.tex` files in the repository unchanged.
* Before switching off: `grep -n 'app:verification\|app:verif' sections/*.tex` and remove every reference from the other files (none expected outside the appendix itself).
* What a reader needs from the appendices is already elsewhere or moves: the account of preparation and checking → acknowledgements (A4); seeds, Python versions, the list of scripts → the Code and data statement and the repository README; refuted statements that inform the reader → the body (they are there already); conjectures, sketches and conditional results → the statements (A1); open points → the Open problems lists; the corrections tables, cross-track conflicts, "results checked by their authors only", "literature not checked" and "unresolved points" → dropped.

### A4. Title page, author line, acknowledgements, code and data

**Author line (both papers):** `\author{Kaarel H\"anni\thanks{…}}`, nothing else. Affiliation and contact address are for the author to add at submission; editors do not add an e-mail address.

**Title-page footnote (both papers, exact):**
```latex
\thanks{This paper was developed and written with extensive assistance from Claude (Anthropic), an AI system, which produced the proofs, the computations and the text under the author's direction. It was checked by independent AI referees, and no human has yet independently checked all of the mathematics. Companion paper: \citet{claudeSFI2026steeper}.}
```
(Paper 2: `\citet{claudeSFI2026fundamentals}`.) The sentence about code and research notes is removed from the Paper 1 footnote; the Paper 2 pointer to the Code and data statement is removed.

**PDF metadata (main.tex, after `\title`):** `\hypersetup{pdftitle={<the title without line break>},pdfauthor={Kaarel H\"anni}}`. Keep the table of contents, delete the `\newpage` after it (both papers).

**Paper 1, acknowledgements (replace discussion.tex lines 28–31 by):**
```latex
\section*{Acknowledgements}\addcontentsline{toc}{section}{Acknowledgements}
The coin example of \cref{sec:ex:eisenstat} is due to Sam Eisenstat (personal communication). \Cref{sec:nn} and the conjunction ladder of \cref{thm:comp:ladder} build on joint work with Dmitry Vaintrob \citep{vaintrobhanni2026nnbayes}.

This paper was developed and written with extensive assistance from Claude (Anthropic), an AI system. Working from the author's notes \citep{hanni2026notes} and under the author's direction, Claude produced the proofs, the computations and the text. Further, independent instances of Claude checked each part: they re-derived the proofs and re-implemented the computations, and the results were revised in response. No human has yet independently checked all of the mathematics, and readers should weigh the results accordingly. The author takes responsibility for the content of this paper.
```

**Paper 1, code and data (replace discussion.tex lines 33–34 by):**
```latex
\section*{Code and data}\addcontentsline{toc}{section}{Code and data}
All computations reported here were done with seeded or deterministic Python scripts (Python~3.11 with NumPy, SciPy and mpmath). The scripts, their saved outputs and independent re-implementations of the main computations are in the folder \texttt{solomonoff-function-induction/} of the repository \url{https://github.com/kaarelh/AI-works}; its README lists the script behind each reported number and how to re-run them. Re-running the scripts reproduces the saved outputs, apart from timing information and one time-limited optimisation.
```

**Paper 2, acknowledgements (replace discussion.tex lines 29–30 by):**
```latex
\section*{Acknowledgements}
The coin example discussed in \cref{sec:split:lambda1} and in the companion paper is due to Sam Eisenstat (personal communication). The question of \cref{rem:related:nn} comes from joint work with Dmitry Vaintrob \citep{vaintrobhanni2026nnbayes}.

This paper was developed and written with extensive assistance from Claude (Anthropic), an AI system. Under the author's direction, Claude produced the proofs, the computations and the text; further, independent instances of Claude checked the proofs in two rounds and re-implemented the main computations, and the results were revised in response. The earlier report \citep{claude2026whatfollows}, whose results are re-derived here, was prepared in the same way. No human has yet independently checked all of the mathematics. The author takes responsibility for the content of this paper.
```

**Paper 2, code and data (replace discussion.tex lines 32–33 by):**
```latex
\section*{Code and data}
Every numerical statement comes from a deterministic or seeded Python script (Python~3.11 with NumPy and SciPy) whose output is saved next to it. The scripts, their outputs and independent re-implementations of the main computations are in the folder \texttt{solomonoff-function-induction/} of the repository \url{https://github.com/kaarelh/AI-works}; its README lists the script behind each number.
```
(The README itself is written when the project is published to `main`; it is not part of this pass. The papers never print `research/tracks/…`, `referee_code`, `checks/` or script names that expose the process, such as `c7_run2.py` or `c6_revision.py`; where a specific script must be named, write "the script for Table 2 in the accompanying repository".)

**Recommendation to the author (not an editor action):** before submission, check the proofs of the main theorems named in the introductions and, if done, add one sentence to the acknowledgements saying which; confirm the "takes responsibility" sentence; add an affiliation.

### A5. Process vocabulary

Not allowed anywhere in the visible text (outside the binding footnote's "independent AI referees"): track, referee, ledger, notes-final, brief, orchestrator, planning/framing editor, writer, "the notes" for the research notes, check ids (`c1`–`c12`, `r1`–`r13`, `e1`–`e7`, `s1`–`s4`, `q4(C)`), track names used as sources ("foundations Thm 6.1", "context c3", "examples §2.6", "St", "Co", "Hi", "F"), H1–H10, "verdict", "working hypotheses", "request", "later request", "the draft", "the PDF draft", "his draft" (an earlier draft is cited only as in §A7), "superseded", "an earlier version", "not written out", "for the page cap", "re-run from scratch copies", "run2", "revision". Final grep (front groups, on `pdftotext main.pdf`):
```
grep -n -i -E 'track|referee|ledger|notes-final|brief|orchestrat|framing|writer|verdict|working hypothes|\bH(10|[1-9])\b|\b[cres][0-9]+(\([a-z0-9,]+\))?\b|request|superseded|earlier version|not written out|page cap|snippet|unverified|not checked|abstracts? only|abstract seen|run2|revision|Wyeth|personal communication to the author|undated'
```
Expected hits: only "independent AI referees" in the footnote and "Sam Eisenstat (personal communication)". Hits inside formulas (pdftotext renders $e_1$, $c_1$, $r_2$ as e1, c1, r2) are inspected and ignored; every other hit is fixed.

### A6. Self-reference and voice

The author is Kaarel Hänni. The papers must not read as an external review of the author.
* State the arrangement **once**, in the introduction: "The notion of SFI, several of the questions studied here and most of the examples first appeared in the author's working notes \citep{hanni2026notes}; we cite those notes where they arise and say where a claim made there needs correction." (Paper 2: same, with \citep{hanni2026grokking} for the proposal.)
* Afterwards: "the author's notes [Hän26]", "[Hän26] conjectures …", "the argument sketched in [Hän26] …", or simply "we". No "Hänni's chain", "H\"anni's Theorem 1", "his remark is correct", "which Hänni doubts", "as Hänni expected", "He wrote plausibly …", "weakly held hypothesis", "Hänni's request". No evaluation of the author.
* **Theorem and section titles never carry the author's name.** Required retitles: Paper 1 `thm:hist:chain` "the chain example", `thm:hist:skipped` "skipped strings", `thm:hist:randchain` "the randomised chain; the oracle reading fails", `cor:hist:thm1` "a dominance theorem for computable reveal laws", `sec:hist:counter` "Counterexamples for order-free prediction", `sec:hist:thm1` "A dominance theorem for computable reveal laws", `rem:hist:H4verdict` "summary: hypotheses that see the previous inputs", `prop:ood:hanni` "unseen simple properties (no logarithmic term)", `sec:ood:examples` "Three examples", `ex:ood:hanniexamples` "three examples from [Hän26]" or "three examples", `sec:ood:twosided` "A two-sided bound", `prop:ood:draftfalse` "the literal two-sided bounds fail", `rem:comp:apples` "like-for-like comparison", `rem:ex:email` "a heuristic argument for Eisenstat's example", `rem:versions:answer` "summary: the versions are not equivalent", `rem:versions:hashing` "a hashing bound". Paper 2: the first subsection of `sec:teacher` (now "Hänni's calculation") "The three-hypothesis calculation", `rem:teacher:hanni` "the three-hypothesis calculation", `rem:teacher:numbers` "numbers for the running example", `cor:teacher:sampled` "finite samples", `ex:teacher:version1` "the total-bits version of the example", section titles with "the trick" → "steeper selection" (§D2).
* Item numbers of unpublished notes ("Thm 1", "Remark 4", "Thm 1 (template)") are replaced by their content ("the dominance statement for reveal laws in [Hän26]", "a remark in [Hän26]").
* **Quotations of the notes:** keep at most one short verbatim quotation per section, only where the exact wording matters (e.g. the definition of SFI in §setting, the proposal's wording in Paper 2's introduction, "1 bit paying for 1 bit"); paraphrase all other informal, lower-case quotations in formal English with a citation. Quotations must be verbatim where they are kept (C-21, C-53, C-20).

### A7. The request, the draft, the e-mail and the LessWrong thread as sources

* `hanni2026request` is **dropped** from both bibliographies; every citation is re-sourced:
  * the author's conjectures, examples and questions (the "as good as SI" conjecture, the cyclic permutation, the sampler-versus-fill-in question, "ideal supervised learning", "NN Bayes is like a circuit version of SFI", the Kolmogorov-versus-semimeasure question) → stated as the paper's motivation in the author's voice, or cited to [Hän26] where the text is in the notes (the Kolmogorov-versus-semimeasure question is in the SFI note: "need coding theorem"); no verbatim quotation of the request;
  * Eisenstat's example → "due to Sam Eisenstat (personal communication)" in the text where it is introduced and in the acknowledgements;
  * the e-mail argument → "a heuristic argument of the author (from correspondence with S. Eisenstat)", paraphrased in at most four sentences in `rem:ex:email`; the verbatim e-mail quotation in `app-examples.tex:140` is deleted.
* **"The draft" / "the PDF draft"** (`hanni-sfi-draft-2025-09.txt`) is in the public notes repository (SFI folder). Cite it as "an earlier draft in [Hän26]" once per section where needed, never in a heading.
* `hanni2026lesswrong` is **dropped** from both bibliographies (unverifiable: no date; lists Wyeth as an author). The quotations it supports that are also in the grokking note are cited to `hanni2026grokking` (replacement map: `review-p2-arxiv.md` §4.3, which this file adopts). The three LessWrong-only remarks ("somewhat cherry-picked …", "anywhere close to a full solution", "some specific toy cases") are restated in the author's voice without quotation marks. See §B for the footnote.

### A8. Literature: hedges and content claims

* Bibliographic data: §G.
* Content attributed to a cited work is limited to what the track notes record as checked (in practice: the work's title and abstract, and standard textbook facts). State it plainly, without saying how it was checked: "X show that …" for abstract-level content, "cf. [X]" for pointers, "(standard; see [LV08])" for textbook facts.
* Delete every process hedge ("we have seen only the abstract", "search snippet only", "not checked against the source", "we have not read these sections", "These descriptions follow the abstracts", "is known, but not checked", "is expected but was not checked", "our literature search reached abstracts only", "need a check against full texts", "This is our reading, not checked …").
* A claim that relies on content **beyond** the abstract is rephrased as the paper's own reading or deleted:
  * Operator induction (P1 `rem:versions:operator`, `prop:hist:operator`, related work, discussion): $\Mpq$ is the paper's own object. Allowed: "Solomonoff's operator induction \citep{solomonoff2008three} predicts the second element of a new pair from an unordered set of ordered pairs; $\Mpq$ is a per-query mixture in this spirit." Not allowed: the product formula attributed to Solomonoff or to Özkural, or "x-only dominance on distinct inputs is then Solomonoff's". `prop:hist:operator` is stated for $\Mpq$ only.
  * Hutter (P1): "Chronological semimeasures and a universal mixture over them were introduced by Hutter for the AIXI model \citep{hutter2000theory,hutter2005universal}, with actions and percepts; here the inputs play the actions and the labels the percepts. We define $\MH$ directly and do not use any identification with Hutter's construction. \citet{hutter2007aixi} lists supervised learning among the problem classes of the AIXI model." No "prior work in substance", no novelty claim for `thm:hist:representation` (the history notes make none).
  * Lattimore–Hutter 2013 (P1 related work): one sentence at abstract level ("a Solomonoff-inspired off-line classifier; random selection of training data can reduce misclassification"); no comparison with `prop:learn:splits` and no "we have not checked".
  * Lattimore–Hutter–Gavane (P1 `prop:hist:lhg`): §F22.
  * Paper 2 MDL works: Zhu–Srebro 2025 and Zhu–Ohannessian–Srebro 2026 are described at abstract level (two-part-code MDL / PAC-Bayes prediction in noisy binary classification; overfitting along the regularisation path); Grünwald–Langford 2007 is described separately and by its title ("Bayes and MDL classifiers can behave suboptimally under misspecification"); no attribution to it of "λ must grow". Keep "We do not claim as new the qualitative finding that a bounded λ fits the noise and that λ must grow with n" (P2M-20 wording).
  * Paper 2 `setup.tex:48` "two-part codes with a complexity weight above 1 are reported to appear in MDL convergence theory \citep{barron1991minimum,grunwald2007minimum}": delete the clause here, in the introduction and in `rem:related:new` (the weight > 1 is known only through a secondary source).
  * Paper 2 `rem:related:posteriors`: delete the two SafeBayes sentences.
  * Paper 2 `prop:algstat:coarse`: delete "Vereshchagin and Shen state that set and distribution models are equivalent … presumably that translation"; the proposition stands without it.
  * Paper 2 `rem:algstat:restricted`: keep only "Restricting the model family changes the structure function; Hamming-ball models \citep{vereshchagin2010rate} are the closest case. For the full-table noisy parity the Hamming ball of radius pN around f_a is a set model of complexity about d and log-size about N H(p), i.e. parity plus independent flips as a set." Drop the Milovanov sentence unless its content is the abstract's (keep the citation only as "see also [Mil16]").
* **Novelty.** P1: replace `rem:related:new` by a paragraph `\paragraph{Novelty.}\label{rem:related:new}` that says, with "To our knowledge": the name and the function-machine formulation of SFI; the separations between SFI and \SFIhist{} and the comparisons with SI on the interleaved sequence; the OOD results `prop:ood:hanni` (in this form), `thm:ood:twosided`, `prop:ood:budget`, `prop:ood:converse`, `prop:ood:sandwich`, `prop:ood:labelled`, `ex:ood:easyhard`; the time-bounded mixtures in the function setting (the sequence analogues are the author's polytime note and the speed priors); the every-ordering form of circuit Bayes with explicit constants; `prop:nn:uniform`; `rem:nn:oddparity`(b),(c). Then the "exists" list without hedges. No to-do sentence. P2: `rem:related:new` becomes "To our knowledge the following are new: …" with the existing list, minus "the observation that consistent schedules learn the teacher's errors" (that observation is attributed to the MDL literature in the same paper); delete "though our search was limited to abstracts" and the last sentence of `q:related:open`; delete open problem (8) "Literature".
* Not added in this pass (see `rejected.json`): decision complexity (Loveland; Uspensky–Shen), Solomonoff 1964, comparisons that need full texts. These are listed for the author as pre-submission reading.

### A9. Computed numbers

* A number obtained by computation never sits inside a theorem, proposition, lemma or corollary statement. Move it to the sentence after the statement or to a Remark/Example after it, worded "A direct computation (code in the accompanying repository) gives …" (P1: `lem:ex:behind` exact values, `prop:hist:normchain` proxies if any; P2: `prop:limits:plain`(a) "1 − 9.6·10^{-24}", `cor:teacher:fulltable` d = 20 window, `prop:limits:noident`(ii) losses).
* Computer re-checks of proved inequalities inside proofs ("a 120-digit computation confirms the window", "No violation occurs over all 625 partial functions …", "check c6 confirms both facts on examples", "A direct computation … confirms the disjointness") are deleted from proofs; if worth keeping, one sentence after the proof: "A direct computation (code in the accompanying repository) confirms this for …".
* κ = 0 numbers in Paper 2 always say "with the machine constant set to 0 (an illustration)" at first use in each table caption and remark.
* Rounding: printed upper bounds are rounded up and lower bounds down where the issue lists say so (P2X-53); otherwise state the rounding convention in the caption.

### A10. Open questions

Add to the theorem block of **both** preambles (identical text; front groups, phase 0):
```latex
\theoremstyle{definition}
\newtheorem{question}[theorem]{Question}
\crefname{question}{Question}{Questions}
```
and add `\crefname{question}{Q.}{Qs.}` inside `\crefabbrev`. Every `\paragraph{Open question.}\label{q:…}` and `\paragraph{Open questions.}\label{q:…}` becomes `\begin{question}\label{q:…} … \end{question}` (same label), with a precise question; to-do items inside them ("a check of the slides' main theorem", "the machine-model details are not written out", "a comparison with the full texts") are deleted or rephrased as mathematical questions (C-36). `conj:ood:natural` and `conj:ex:raw` become `question` environments with the same labels (§F21). The Discussion's "Open problems" list (both papers) refers to every question by `\cref` and is the single collected list.

### A11. Tables keyed to internal hypotheses

* Paper 1: delete `tab:intro:verdicts` (Table 1), the sentence that introduces it, the paragraph "Corrections to earlier claims" in its present form, and the reference in `learn.tex:87`. Replace by a three-sentence paragraph **"Relation to the author's notes"** (intro): the arrangement sentence of §A6, then "Where those notes claim more than holds, the relevant section says so: the simulation argument for the reveal-law theorem (\cref{prop:hist:sketchfails}), the literal two-sided out-of-distribution bounds (\cref{prop:ood:draftfalse}), the converse without dependence on $K(f)$ (\cref{prop:ood:converse}), and the argument for few online mistakes of simplest-consistent learning (\cref{rem:comp:majority,thm:comp:ladder})." The weak-versus-machine refutation and the fresh-noise caveat are already in the contributions list.
* Paper 2: `tab:intro:claims` stays (it is keyed to the author's published claims, not to internal hypotheses) but is rewritten: caption "Questions raised in the author's notes \citep{hanni2026grokking} and where they are answered. Numbers with $\kappa=0$ set the machine constant to $0$ and are illustrations."; header "Question & Answer & Where"; no "Verdict", "Confirmed"/"refuted" replaced by "Yes", "No", "In part"; rows 3 and 8 per §F30; quotations only from the grokking note.
* The contributions lists replace the verdict tables (§D1).

### A12. Packaging for arXiv (later step, recorded here so nobody does it now)

At submission: flatten the sources, strip all `%` comments and all `\status{…}`/`\src{…}` calls with a brace-matching script, upload `main.bbl` instead of `bib/`, do not upload `app-verification.tex`, `build-test/`, logs or scripts, compile twice in a clean folder and repeat the grep of §A5 on the sources and the PDF. Suggested categories: Paper 1 cs.LG with cross-list cs.IT; Paper 2 cs.LG with cross-lists cs.IT and stat.ML.

---

## B. Every mention of Wyeth removed

Found (lead editor's grep, `scratch/editor/`): Paper 1 PDF 4 lines (the citation "(Hänni and Wyeth, undated)" in `steeper.tex`, the bibliography entry, Appendix I line 136 "a promised Wyeth–Hutter reference"); Paper 2 PDF 17 lines (15 citations of `hanni2026lesswrong`, the bibliography entry, Appendix H). No visible heading names him and no comment of his is quoted.

Decisions:
1. Drop `hanni2026lesswrong` from `bib/core.bib` of both papers (it lists "Hänni, Kaarel and Wyeth, Cole"); re-source every citation (§A7). `all.bib` and `main.bbl` regenerate in the build.
2. Appendix I (P1) and Appendix H (P2) are switched off (§A3).
3. Paper 2 `absorb.tex:5`: the one permitted footnote becomes, with no citation and no name: `\footnote{The point was also raised in the online discussion (on LessWrong) in which the author described the proposal.}` The sentence it is attached to is rewritten per §F38.
4. The label `rem:absorb:wyeth` stays (binding note); its printed title is "Answer to the absorption objection" (already).
5. The visible text calls the objection "the absorption objection" or "the standard absorption point" only.
6. Final check: `pdftotext main.pdf - | grep -c -i wyeth` = 0 for both papers; `grep -rn -i wyeth sections/*.tex bib/*.bib | grep -v '^[^:]*:[0-9]*:\s*%' | grep -v 'rem:absorb:wyeth' | grep -v app-verification` returns nothing.

---

## C. Length targets

Measured (build of 2026-10-12 16:59): Paper 1 103 pages (main text pp. 1–52 incl. title/TOC and acknowledgements, references pp. 52–56, appendices pp. 57–103 of which Appendix I 7.5); Paper 2 63 pages (main pp. 1–33, references 33–35, appendices 36–63 of which Appendix H 5.5).

Targets (11pt, current geometry; a long arXiv paper). **Hard caps:** Paper 1 main text (title page through Code and data) ≤ 41 pages, appendices ≤ 38 pages, total ≤ 84 pages. Paper 2 main text ≤ 27 pages, appendices ≤ 27 pages, total ≤ 57 pages. Per-section budgets are guides (± 0.5 page) and each group reports its counts.

**Paper 1 budgets (main / appendix, pages; section numbers in the new order of §D2):** title+abstract+TOC 1.5; §1 Introduction 3; §2 Related work 1.5; §3 Setting 4.5 / A 6.5; §4 Versions 4 / B 4; §5 Learning 4 / C 6; §6 History 5 / D 7.5; §7 Examples 5 / E 6; §8 OOD 3.5 / F 2.5; §9 Computable versions 3 / G 3.5; §10 NN Bayes 2 / H 1; §11 Steeper summary 0.5; §12 Discussion + open problems + acknowledgements + code and data 2.5.

**Paper 1 cut/move list:**
* Remove: Appendix I (−7.5); Table 1 and the corrections paragraph (−1); `rem:nn:rigorous` (delete; one corrected sentence goes to the Discussion, §F18); `rem:learn:interventions` (delete); `rem:learn:cesaro` (rewrite to 3 lines, §F26); `rem:related:new`'s process text; the numbers of the steeper-prior section `sec:steep` (§F20, −1.5); duplicated limits of the analogy in intro "Why SFI" and Discussion ¶1 (keep `rem:learn:ideal`, one sentence each elsewhere); "Comparison with other bounds" paragraph in `app-learn` shortened to the PAC-Bayes and resolvability sentences; the e1–e7 check descriptions at the end of `app-examples` (→ README; one sentence remains); the computational re-checks inside proofs (§A9).
* Merge: `rem:versions:prediction` and `rem:versions:answer` into one remark "What the gaps mean" (≤ 0.5 page; keep both labels: `rem:versions:answer` on the remark, `rem:versions:prediction` on its first item or on a `\label` inside it).
* Move to related work (§2) as prose with their labels: `rem:learn:hutterEX` (p1-setting gives, p1-ood receives), `rem:nn:literature` (within p1-ood), Discussion ¶"Relation to the literature" (deleted from the Discussion; p1-front).
* Move to appendices (same group): `rem:learn:positive` stays in App C; from Learning (`learn.tex`) to App C if it exceeds 4 pages: `prop:learn:curve`, `rem:learn:lastiterate`, `prop:learn:loo`, `conj:learn:loo` (keep `prop:learn:typical`, `cor:learn:perstep`, `prop:learn:splits` in the main text with one summary sentence); from History (`hist.tex`) to App D if it exceeds 5 pages: `thm:hist:expected` with its paragraph, `prop:hist:inputloss` details; from OOD (`ood.tex`) to App F: `ex:ood:easyhard` (keep a two-sentence summary), `tab:ood:hanni` (already in App F); from Computable versions (`comp.tex`): `rem:comp:apples`, `rem:comp:gap`, `prop:comp:samplers` to App G with one sentence each in the main text; from NN Bayes (`nn.tex`): `rem:nn:slides` shortened to ≤ 12 lines.
* Not done: splitting off the OOD and computable-versions sections as a separate paper (rejected).

**Paper 2 budgets (main / appendix; section numbers in the new order of §D2):** title+abstract+TOC 1.5; §1 Introduction 2.5; §2 Related work 1.5; §3 Setup 2.5 / A 1.5; §4 Absorption 3 / B 3.5; §5 Teacher's mistakes 5 / C 7.5; §6 Limits 3.5 / D 4.5; §7 Split 2.5 / E 4; §8 Algorithmic statistics 2 / F 2.5; §9 Computable classes 0.5 / G 2; §10 Discussion + open problems + acknowledgements + code and data 2.

**Paper 2 cut/move list (all p2-body unless stated):** remove Appendix H (−5.5, p2-front); move to appendices with a one-sentence pointer in the main text: `prop:absorb:inputs`, `rem:absorb:condsemi` (→ App B), `prop:limits:guard`, `prop:limits:inputlaw`, `rem:limits:method` (→ App D), `ex:split:noisyparity`, `rem:split:siprograms` (→ App E), `prop:algstat:product`, `prop:algstat:coarse` (→ App F), `ex:teacher:version1` and `prop:teacher:concentration` (→ App C, keep `cor:teacher:sampled` in the main text); `tab:teacher:numbers`(b) may move to App C if the teacher's-mistakes section exceeds 5 pages; the per-section open-question paragraphs become `question` environments (shorter, §A10); the introduction's "Prior work" paragraph moves into §2 (p2-front gives, p2-body receives, as prose). Not done: replacing `thm:teacher:main` by a simplified main-text version (rejected; §D2 adds an informal statement and a notation box instead).

---

## D. Structure

### D1. Both papers

Order: abstract; 1 Introduction (motivation; informal statement of the main results; contributions list; relation to the author's notes; reader's guide with the two loss conventions defined **before** the contributions list); 2 Related work; 3 … results sections (the setting section serves as preliminaries); Discussion with a subsection "Open problems"; Acknowledgements; Code and data; References; Appendices with proofs. No verification appendix.

* **Contributions list:** 5–6 bullets, each 2–4 lines, naming the main theorems with `\cref`s; no catalogue of every result.
* **Informal main results:** P1, before the contributions list, three or four displayed informal statements "Theorem A (informal)" etc. as plain paragraphs (not theorem environments, no new labels needed): A universality, invariance and pathwise dominance; B no coding theorem for function programs; C order-blindness in the semimeasure convention and \SFIhist{} as the universal chronological semimeasure; D the cyclic permutation and Eisenstat's example. Each ends with "(\cref{…})". P2: "Theorem (informal)" for the teacher's-mistakes theorem, with its hypotheses (uniform inputs, product-form error set, flip rate below 0.056, incompressible error rule, population objective, λ = cn with c in a window).
* **Related work** is Section 2 in both papers (binding note), short, without results, readable before the definitions (informal descriptions with forward `\cref`s).
* **Open problems:** one numbered list at the end of the Discussion that `\cref`s every `question` and `conjecture`.
* Main-text results keep a 2–6 sentence proof idea; full proofs in the appendix of the section; appendix titles follow one pattern: "Proofs for Section N (<short title>)".

### D2. Paper-specific

* **Paper 1 (`main.tex`, p1-front):** input order intro, related, setting, versions, learn, hist, examples, ood, comp, nn, steeper, discussion. The related-work file is rewritten by p1-ood to stand at §2 and absorbs `rem:learn:hutterEX`, `rem:nn:literature` and Discussion ¶"Relation to the literature" (which p1-front deletes). The steeper-prior section (`sec:steep`, §11 in the new order) stays a short section (≤ 0.5 page, §F20).
* **Paper 2:** input order intro, related, setup, absorb, teacher, limits, split, algstat, computable, discussion (p2-front edits `main.tex`). `related.tex` becomes the related-work section (prose: the current `rem:related:mdl`, `rem:related:posteriors`, `rem:related:cold`, `rem:related:t5`, `rem:related:new` as paragraphs that keep their labels; plus the introduction's "Prior work" paragraph). A new file `sections/computable.tex` (p2-body), `\section{Computable hypothesis classes}\label{sec:computable}`, receives `prop:related:computable`, `prop:related:computability`, `rem:related:nn` and `q:related:open` (labels unchanged); the examples paragraph of `prop:related:computable` becomes a remark after it. `app-related.tex` keeps the proofs and the T5 correspondence table, retitled "Proofs for \cref{sec:computable} and the correspondence with the earlier report". `sec:limits` is retitled "Limits of steeper selection", `sec:limits:rules` "Which error rules defeat steeper selection", and its appendix "Proofs for \cref{sec:limits} (limits of steeper selection)"; "the trick" is replaced by "steeper selection" or "the proposal" throughout (P2X-49). The teacher's-mistakes section (`teacher.tex`) gets, before `def:teacher:instance`, a short "Notation for this section" list (one line per symbol) of the symbols used in the statement of `thm:teacher:main`; symbols used only in proofs ($\tau_B,\beta_B,\Gamma_g,j_g,\varrho$) are defined in Appendix C.

---

## E. Notation fixes

* **Shared-coin law** (both papers and `NOTATION.md`): $\nulen$ is the law of $F(x)=\omega_{|x|+1}$ (Paper 1's convention). p1-front updates `NOTATION.md` §3.1; p2-body changes `app-absorb.tex:67` and `absorb.tex:71` from $\omega_{|x|}$ to $\omega_{|x|+1}$ and checks the certificate length $\Kpad(d+1)$.
* **Paper 1:**
  * $H_f$: entropy of the reveal sequence becomes $H(x_{1:n}\mid f)$ in `cor:hist:thm1`(c); the hypothesis set of `prop:comp:occam` becomes $\mathcal H_f$.
  * $P_A$: the sampler's output law in `prop:comp:samplers` becomes $P^{\rm samp}_A$; $P_A$ stays the architecture prior in §nn.
  * In `cor:learn:perstep`(a) write $\exp(-\varepsilon n)$, not $e^{-\varepsilon n}$, since $e$ is the error.
  * Empty string: $\epsilon$ throughout (`ex:ood:easyhard` uses $\varepsilon$ for it; change).
  * Confidence exponent $j$ in §hist and App D (MB-11), as in §ex.
  * $\bar\ell_k$ (cumulative block length) stays in §hist; the normalised step loss is $\beta_t$ in both §hist and §ex (MB-12).
  * In §ex paragraph "SI." rename the domination exponent to $a$ (MB-10) and fix "$L^y_M=\LMy$".
  * Define in `sec:setting:data`: the length-lexicographic index $j(x)$; both pairings $\langle\cdot,\cdot\rangle$; $K(T):=\min\{K(i):T_i=T\}$ for function machines; the enumeration of lsc conditional semimeasures and $K(P)$ (P1A-23, P1A-53). Effective presentation of $Y$ (P1A-49).
  * §comp: activation lengths $n_i,n_A,n'_A$ become $\ell_i,\ell_A,\ell'_A$; define the activation rounds $k_i$ (C-48).
  * `prop:ood:draftfalse`(a): sequence index $Q_m$ ($m\to\infty$), not $Q_d$ (C-30). Define $K(Q)$ in the conventions paragraph of §ood (C-46).
  * §nn: $\Lambda_{|S|}$ throughout; Gram matrix $G$ (not $K$); $\mathbb E_x[z(x)\chi_S(x)]$ for the $L^2$ pairing (C-54); define the prior scale or write "at a fixed (not vanishing) prior scale" (C-18).
  * Formula size in `rem:comp:adversary` is not $\csize$ (C-50).
  * $\Mnorm$ defined in one line where first used in §ex; "LHG" expanded (P1X-37).
* **Paper 2** (P2X-34, P2M-23): programs are $\pi$ ($\pi_w,\pi_s$, $2^{-\lambda\ell(\pi)}$); point mass $\mathbf 1_w$ instead of $\delta_w$; constants of `lem:limits:robust` $\alpha_0,\beta_0$; integer index $v$ ($A_v$) in App F; $p=h'/2^{e'}$ in App F; the integer $\rho$ in `prop:algstat:coarse` becomes $r_D$ and its threshold $\rho_0$; $\kappa'$ for the subclass constant becomes $\kappa_2$; simulation prefixes in App E $\sigma$; guard gain $g_G$; product index in `prop:absorb:history` $j$.

---

## F. Results whose statement must change (exact new text)

Text in `latex` blocks is binding up to typography; "replace X by Y" means exactly that.

### Paper 1

**F1. Abstract (p1-front; replace the whole abstract; ≤ 1920 characters):**
```latex
Solomonoff induction is the standard ideal predictor for sequences. We study its analogue for supervised learning, Solomonoff function induction (SFI): Bayesian prediction of labels from input--output pairs under a universal prior over random functions, in which a random program, reading random bits shared by all inputs, labels every input. A universal function machine exists; its law dominates the law of every function machine and does not depend, up to a constant factor, on the choice of universal machine. The shortest consistent program, the program mixture, the mixture of product laws and SFI agree up to the complexity of the set of inputs, but there is no coding theorem for function programs. On every consistent data sequence, SFI's cumulative log loss exceeds that of every computable random labeller by at most the labeller's complexity plus a constant; with i.i.d.\ inputs and a computable deterministic target, the averaged predictor has risk $O(K(f)/n)$. SFI cannot model fresh label noise on repeated inputs. Measured on its unnormalised predictive probabilities, SFI's cumulative loss does not depend on the order of the data: on a random cyclic permutation of $\{0,1\}^d$ revealed backwards along its cycle it pays about $(d-\log_2e)2^d$ bits, while Solomonoff induction on the interleaved sequence, with self-delimiting blocks, pays $O(1)$ bits of label loss in expectation. Hypotheses that see the list of previous inputs give the universal chronological semimeasure. A dominance theorem for computable reveal laws holds pathwise for deterministic laws and, up to the complexities of the horizon and of the input sets, in expectation for randomised ones. We also treat a coin example of Sam Eisenstat, out-of-distribution behaviour, computable versions and neural-network Bayes.
```

**F2. Introduction (p1-front).**
* l.5 first paragraph: define SFI in the paper's own words ("the Bayes predictor for the prior under which a random program, reading random bits shared by all inputs, labels every input") and cite \citet{hanni2026notes} as the origin of the notion; move the lower-case quotation out (it is already in §setting).
* l.9, replace from "Giving SFI's hypotheses" to the end of the paragraph by:
  "Giving SFI's hypotheses the list of previous inputs removes the gaps of \cref{sec:hist,sec:ex}: the result, \SFIhist{}, is a universal lower-semicomputable chronological semimeasure (\cref{cor:hist:H4}), and its loss is within a constant of SI's joint loss on the interleaved sequence (\cref{thm:hist:si}); against SI's loss on the labels alone the comparison involves SI's loss on the inputs (\cref{prop:hist:inputloss}). Chronological semimeasures, with actions and percepts in place of inputs and labels, are the setting of Hutter's AIXI \citep{hutter2000theory,hutter2005universal}; we define \SFIhist{} directly and use no identification with Hutter's construction."
* History bullet (l.19): "… every lower-semicomputable order-independent predictor pays the same lower bounds up to its complexity, and every order-independent predictor pays them in expectation (\cref{prop:hist:orderfree}). For computable reveal laws, the dominance theorem of \citet{hanni2026notes} holds pathwise for deterministic reveal policies and, under finiteness hypotheses, in expectation with an additional $K(n)+K(A)$ term for randomised reveal laws; whether that term is needed is open. The proof sketch in the notes fails, and a stronger (oracle) reading is false (\cref{prop:hist:sketchfails,cor:hist:thm1,thm:hist:randchain,rem:hist:thm1open}). … its relation to SI on the interleaved sequence is in \cref{thm:hist:si,prop:hist:inputloss}." (drop "exact")
* Examples bullet (l.20): "… while SI, with the self-delimiting code of \cref{sec:ex:tools}, pays $O(1)$ in expectation … In Sam Eisenstat's coin example SFI's expected loss is $\frac{H(1/3)}2n\pm O(\log n)$ bits in the semimeasure convention (and almost surely within $\log n+O(\log\log n)$ bits of the loss of the threshold hypothesis), which is optimal among order-independent predictors up to $O(\log n)$ in expectation, while SI pays at most $2.4$ bits plus a constant in expectation."
* Computable bullet (l.22): "… makes $2^{\Omega(\ell/\log\ell)}$ mistakes on some ordering for the conjunction of $d$ variables, whose description length is $\ell=\Theta(d\log d)$ …"; "a separation in squared error between Gaussian-process limits and SFI on sparse parities, and a failure of bias-free two-layer ReLU kernels on odd parities".
* Steeper bullet: unchanged in content; cite \citet{claudeSFI2026steeper}.
* Delete the paragraphs "Corrections to earlier claims" (replaced per §A11), Table 1, "Credit" (replaced by the arrangement sentence of §A6, Eisenstat as personal communication, and "The material on neural-network Bayes, including the conjunction ladder of \cref{thm:comp:ladder}, builds on joint slides with Dmitry Vaintrob \citep{vaintrobhanni2026nnbayes}"), and in "What is not achieved" the sentences "The main theorems of the slides are not checked here." (→ "We do not prove the main theorems of the slides.") and "Much of the literature was seen only through abstracts …" (delete).
* Reader's guide: "\Cref{sec:versions} compares the Kolmogorov and semimeasure versions"; the two-convention sentences move before the contributions list.

**F3. `thm:hist:minimax` (p1-hist-ex).** Replace "and let the reveal law see the history (with private memory) and possibly $f|_{A_n}$" by "and let the reveal law see the history (with private memory) and possibly $f|_{A_n}$ in case (a), and only the history in case (b)". After the proof idea add:
```latex
\begin{remark}[reveal laws that see $f$, case (b)]\label{rem:hist:minimaxsketch}
For computable real values and reveal laws that may see $f|_{A_n}$, the argument of case (b) goes through if $C_{\rm dir}(\Delta,n)$ can be computed to within one bit from $(P,\Delta,n,A)$. \emph{Proof sketch.} … (the present sentence of the appendix). We do not carry this out.
\end{remark}
```
Delete "not written out" from the proof idea; in `app-hist.tex:104` replace "this is not written out, so this case is a proof sketch" by "this case is only sketched (\cref{rem:hist:minimaxsketch})". `cor:hist:thm1`(a) uses only reveal laws that do not see $f$ and is unaffected.

**F4. Sentence after `cor:hist:thm1` (hist.tex:109; p1-hist-ex).** Replace "So Thm~1 is true in H\"anni's reading, with an extra $K(n)+K(A)$ for random reveal laws; only the proof sketch fails." by:
"So the dominance statement of \citet{hanni2026notes}, read as intended (Reading C), holds pathwise for deterministic reveal policies (b); in expectation, for samplers that halt almost surely and finite alphabets up to the horizon, it holds with the additional term $K(n)+K(A)$ (a); and in general it holds with the reveal entropy added (c). Defective samplers, infinite alphabets and the removal of $K(n)+K(A)$ are open (\cref{rem:hist:thm1open}); the proof sketch in the notes fails (\cref{prop:hist:sketchfails})." (MB-04)

**F5. Time-bounded SFI (p1-ood).** `thm:comp:timebounded`: keep (a) only, with title "time-bounded SFI". Delete (b) from the statement and add after the proof idea:
```latex
\begin{remark}[running time]\label{rem:comp:runtime}
We assume the RAM model and do not analyse the cost of running the clocks. With $n_i=2^{2^i}$ and $g(n)=\lceil\log\log(n+4)\rceil$, round $k$ of $\Mlen$ costs at most $\log\log|x_k|+1$ simulations of $g(|x_k|)t(|x_k|)$ steps plus as many arithmetic operations on stored weights, and weights stored with relative precision $\varepsilon_k=(k+1)^{-2}$ change the cumulative loss by at most $\sum_j\log\frac{1+\varepsilon_j}{1-\varepsilon_j}\le1.9$ bits. Round $k$ of $\Mrd$ (\cref{prop:comp:round}) and of the learner of \cref{cor:comp:poly} costs $\#\{i:k_i\le k\}$ simulations of $g(k)t(|x_k|)$, respectively $(|x_k|+2)^{g(k)}$, steps plus as many arithmetic operations; the learner of \cref{prop:comp:history} costs $O(\#\{i:k_i\le k\}\,g(k)t(\tilde n_k))$ steps in round $k$ plus the memory for replaying the history. \emph{Proof sketch.} Only active machines change their weights, and rounding errors telescope; for \cref{prop:comp:history} add the replay cost.
\end{remark}
```
Delete the last sentence of `prop:comp:round`, the "round $k$ costs …" clause of `cor:comp:poly` and of `prop:comp:history` (each statement then states only the regret). The appendix argument is headed "Proof sketch for \cref{rem:comp:runtime}" and uses $\varepsilon_k=(k+1)^{-2}$. Replace "in time $|x|^{\omega(1)}$ per round" after `cor:comp:poly` by "in time $(|x_k|+2)^{g(k)}$ per round for an arbitrarily slowly growing $g$ (\cref{rem:comp:runtime}); with the clock $(|x|+2)^{g(|x|)}$ the same holds on distinct inputs, in time $|x|^{\omega(1)}$ per round" (C-24; both clauses are in context notes-final Cor 3.2b).

**F6.** (merged into F5.)

**F7. Sentence after `prop:ood:labelled` (ood.tex:134; p1-ood).** Replace "The mass undefined at $x^*$ is not lsc, so there is no pointwise bound on $e(x^*)$; \cref{cor:learn:perstep} bounds it in distribution." by "The argument bounds only the mass that is defined and wrong at $x^*$; \cref{cor:learn:perstep} bounds the semimeasure-convention error $e(x^*)$ in distribution." (C-01; the stronger pointwise bound proposed by the reviewer is not added.)

**F8. `rem:ood:answer` (p1-ood).** Title "summary of the positive statements". (iii): "For simple $f$ and binary labels, $e^{\rm wr}(x^*)\ge2^{-\sep(x^*;A)-O(1)}$ and $e_{\rm norm}(x^*)\le2^{L_\nu(f)-\sep(x^*;A\mid f)+O(1)}$ (\cref{prop:ood:labelled}); for random $f$ no learner has a converse." Keep the rest of (iii). (iv): add "for computable binary $f$ and uniform inputs on $\{0,1\}^d$ with $d\ge\lceil\log n\rceil+1$" before "at least of order".

**F9. `lem:ex:chainsemi` and `eq:ex:depth` (p1-hist-ex).** Statement: "For every law $\nu$ of a random partial function $F$ and every $x$, $\sum_z\nu(D(x,z))\le1$, the sum over the finite sequences $z$ of strings different from $0^{|x|}$ for which $D(x,z)$ is a data set. Hence $K(z\mid x)\le\LSFI(D(x,z))+c$ for these $z$." In the proof of `thm:ex:ksteps`(b): "summing over $x\in\{0,1\}^d\setminus\{0^d\}$ and $z\in(\{0,1\}^d\setminus\{0^d\})^{k-1}$". Same range in `prop:ex:orderfree`(a)'s proof and in `q:ex:depthweak`.

**F10. `rem:versions:prediction`, merged with `rem:versions:answer` (p1-setting).**
* (2): "\emph{Random tape or not:} $W$ predicts as well as SFI up to $\Kpad(L_{1/2}(\MF,D))+O(1)$ bits in total. On binary labels its loss exceeds the fair-coin loss $|D|$ by at most $K(\lceil\log(d+1)\rceil)+O(1)$ bits however many labels are predicted, hence exceeds SFI's loss by at most $\delta_D+K(\lceil\log(d+1)\rceil)+O(1)$ with $\delta_D=|D|-K(D\mid\dom D)$ (\cref{thm:setting:coding}(a)). …"
* (3): "… It can exceed SFI's loss by $\log d-O(1)$ bits on two points (\cref{thm:versions:nocoding}), and on $k$ binary labels with randomness deficiency $\delta_D$ by at most $\delta_D+\log(k(d+2))+K(\lceil\log(d+2)\rceil,k)+O(1)$ (\cref{prop:versions:covering}); whether gaps of order $\log k$ occur is open (\cref{q:versions:open}). …" (P1A-01)
* (4): "$\Mw$ can exceed $\MF$ by linearly many bits on some data sets (\cref{thm:setting:weakvsmachine}(iii)), because it dominates the weak semimeasure $\nutri^{\otimes k}$, which no law of a random function dominates by a factor better than $(2/3)^k$; it pays for this by having no posterior over functions."
* (5): "… hold for $W$, $\Mprod$, $\MF$ and $\Mw$; for $\KF$ the corresponding statement is the Occam bound \cref{prop:learn:occam}."
* versions.tex:96 (after `prop:versions:covering`): "A logarithmic cost in $d$ is real for the single shortest program already on two points (\cref{thm:versions:nocoding}); the covering argument shows that it is at most logarithmic in $k(d+2)$. $W$, compared with the fair-coin law, pays no factor depending on $|D|$ (\cref{prop:versions:tape}(b))."
* In `q:versions:open` delete "$L_{1/2}$ is not computably bounded in $(d,|D|)$" (unproved in the sources), and add "whether the single shortest program has gaps of order $\log k$ on $k$ points".

**F11. `tab:versions:compare` (p1-setting).** Row "$\Mprod$ vs $\MF$", upper-bound cell: "against $\nulen$, inputs of length $\le d$: $\Kpad(d+1)+O(1)$ (\cref{rem:versions:sharedsize}); general: $\min\{\Kpad(L_{1/2}(\MF,D)),K(\dom D)\}+O(1)$". Caption: "The Kolmogorov and semimeasure versions compared. Data sets $D$ with inputs of length at most $d$; gaps in bits ($\log$ of the ratio of the two quantities, or $\KF$ plus $\log$ of the other). Every entry is proved where cited. By \cref{rem:versions:noncomputable}, along a computable family $k\mapsto D_k$ of data sets no gap between the five quantities of \cref{thm:versions:chain} exceeds $K(k)+O(1)$; the last row compares objects on sequences, where $\Mpq$ and $\Mprod$ can differ completely."

**F12. `thm:setting:invariance`(b) (p1-setting).** Replace the last sentence by "So cumulative losses in the semimeasure convention on original and re-encoded data differ by at most $K(\alpha,\beta)+O(1)$ bits, uniformly over data sets and reveal orders." After the theorem: "The constant is not small for complex encodings; only the upper bound is proved, and whether such encodings can change losses by that much is not known." (P1A-29)

**F13. `rem:setting:recommend` (p1-setting).** Replace the last sentence by "The variants $W$, $\KF$, $\Mprod$ and $\Mw$ (\cref{sec:versions}) agree with it up to $K(\dom D)+O(1)$ bits on data sets, and so does the per-query mixture $\Mpq$ on sequences with distinct inputs, where it equals $\Mprod$; they differ by unbounded amounts and should be kept distinct."

**F14. After `ex:setting:swap` (setting.tex:159; p1-setting).** "This is \emph{not} a separation between SFI and history-aware prediction: every lower-semicomputable history-aware predictor $\rho$ shown $x_1$ first pays at least $K(x_2\mid x_1)-K(\rho)-O(1)$ bits on the label of $x_1$ (conditional coding theorem), and $\MH$ pays at least $K(x_2\mid x_1)-O(1)$. Such separations are \cref{thm:hist:chain,thm:hist:skipped,thm:ex:cycle}."

**F15. `rem:versions:hist` (p1-setting).** "… while for the worst labels the single shortest program pays more: along every input sequence, $\max_{y\in\{0,1\}^n}\Khist(y\Vert x_{1:n})-n>\log n+\log\log n$ for infinitely many $n$ (\cref{prop:hist:programs}(d))."

**F16. `prop:learn:freshnoise` (p1-setting).** Proof (b): "The labels at $x_0$ agree with probability $(1-\alpha)^n+\sum_{j\ge1}\binom nj\alpha^j(1-\alpha)^{n-j}\sum_yP(y\mid x_0)^j$. For $j\ge1$, $\sum_yP(y\mid x_0)^j\le p_{\max}^{j-1}$, so this is at most $(1-\alpha)^n+p_{\max}^{-1}(1-\alpha+\alpha p_{\max})^n$." Statement (c): "The natural strengthening ``for every input distribution and every computable conditional probability $P$, SFI's expected cumulative log loss exceeds that of $P$ by at most $K(P)+O(1)$'' fails for random-function SFI. For $P$ with finite expected log loss it holds for all $n$ exactly when …" (rest unchanged). Delete "This refutes the fresh-noise form of the supervised-learning hypothesis H7 … (\cref{tab:intro:verdicts})" and replace "The finite-loss proviso in (c) is ours (…)" by "(For $P$ with infinite expected log loss the inequality is trivial.)"; numbers "at $n=2,10,20$" are introduced by "a direct computation (code in the accompanying repository) gives".

**F17. Hänni's three examples (p1-ood).** Title per §A6. (a) replace the "This makes precise …" sentence by: "This gives one precise sense to the tentative remark in \citet{hanni2026notes} that for Solomonoff induction easy-to-hard generalisation ``is not'' a thing: no number of easy sentences removes a (small) floor on the wrong-label probability of a hard one." (c) "``$|x|$ even'' and ``output $1$'' cost $O(1)$ bits, so a wrong answer keeps probability at least $2^{-c'}$ on every even-length input" (C-45/P1C-17), define online errors as steps where the correct label gets probability at most $\frac12$ (\cref{thm:ood:cumulative}), and "… and about $0.11$ when a single extra program with ten times the prior mass of the intended one is added". `app-ood.tex:39`: "The tilted rows add one program ``if $|x|$ even then $0$ else $|x|$'' with prior mass equal to (or ten times) that of the intended program $|x|$, the only plain program consistent with the training data; with the factor ten it carries $44\%$ of the prior mass (the predictive is computed after normalising)." and "Plain expressions with the same values on all strings of length $1$ to $8$ are merged into $1345$ classes; an \texttt{if} program is a condition and two such classes." `tab:ood:hanni`: "$0.11$ with a tilted prior". (C-31's own suggested wording "of all plain programs" is wrong and is not used.)

**F18. NN remarks (p1-ood).** `rem:nn:slides`, item (vi): "out of distribution the in-distribution guarantee ``is simply false''; an online mistake bound might still hold for NN Bayes (the slides give a heuristic argument and list it as open), while the analogous claim for simplest-consistent learning over circuits fails (their Appendix K; \cref{thm:comp:ladder})." Caveats quoted exactly ("Many of these appendices have largely been generated by Claude"; "I haven't meticulously reviewed many appendix slides yet"; (ii) "for each width, with the prior scale small enough and outputs conditioned with margin $\frac12$"). Replace "We re-checked … the rest is unchecked." by "Of these, this paper proves the Markov half of the relevance-based bound in (i) (\cref{cor:learn:perstep}(a)), the character argument of their Appendix J (\cref{thm:nn:walsh}(a)) and the ladder of their Appendix K (\cref{thm:comp:ladder}); we do not prove the other claims." **Delete `rem:nn:rigorous`** (grep first; it is referenced only in nn.tex). Add to the Discussion (p1-front) one sentence in its place: "In the Gaussian-process limits, kernel regression and Gaussian-process posterior means need $\binom dk$ samples, in squared error, on random $k$-sparse parities where SFI needs $O(k\log d)$, and bias-free two-layer ReLU kernels never learn odd parities of degree at least $3$ (\cref{cor:nn:separation,rem:nn:oddparity}); whether NN Bayes generalises like SGD-trained networks is not addressed here."

**F19. Ladder and selection (p1-ood).** Add to `thm:comp:ladder`: "For this target the bound is tight up to the constant in the exponent, since there are only $2^d$ inputs." `rem:comp:selection`: "The first row (for the conjunction target) and the last row are proved here (\cref{thm:comp:ladder,rem:comp:majority}); the slides of \citet{vaintrobhanni2026nnbayes} (Appendix K) also state the other rows, which we do not prove." `rem:comp:uniformties`: add "The slides make this observation for their strong-prior learner (Appendix K); we give the formula-prior version with explicit constants."

**F20. `steeper.tex` (p1-ood; replace the whole section body, keep `\section{…}\label{sec:steep}`):**
```latex
The author's notes propose to penalise program length more steeply than likelihood, by a factor $\lambda>1$, for hypotheses that use private randomness at each input, so that the selected hypothesis is a simple model plus noise rather than a model of a teacher's systematic errors \citep{hanni2026grokking}. The companion paper \citep{claudeSFI2026steeper} studies this proposal; we summarise its results. A standard objection is that, under a steeper penalty, a hypothesis that is itself a universal mixture absorbs all structure of the data. The companion paper shows that this happens in every class that contains its own mixture as a member, such as Solomonoff induction and SFI with shared randomness, and in the history-aware class, whose mixture is $\MH$ (\cref{cor:hist:H4}); no hypothesis with private randomness is universal. The restriction to private randomness has a price on latent causes shared by several inputs; at $\lambda=1$ it is the gap between $\Mprod$ and $\MF$ (\cref{prop:versions:shared,rem:versions:sharedsize}). For a random parity whose labels a teacher flips on an error set of product form that is incompressible relative to the parity, with uniform inputs and $\lambda$ proportional to the sample size $n$, the companion paper proves that for $\lambda/n$ in an explicit window every near-optimal hypothesis with private randomness knows the parity and gives the erroneous labels far less probability than a memoriser does; $\lambda$ must grow linearly in $n$, and the density and description length of the error rule alone do not suffice. At $\lambda=1$, with private randomness and in Solomonoff induction, a computable sampler and the programs that fill in its sampled bits get similar posterior weight; for fixed $\lambda>1$ with private randomness the selected hypotheses are samplers rather than fill-ins, while with shared randomness, or in Solomonoff induction, a universal mixture beats every sufficiently long sampler.
```
(This removes C-02's "$t_n$ doubly logarithmic", "all of them are proved there", the numbers, the LessWrong and request citations, and the misquotation C-21.)

**F21. Questions replacing imprecise conjectures.**
* `conj:ood:natural` (p1-ood): `\begin{question}[natural machines]\label{conj:ood:natural} Is there a universal machine for which the intended answers of \cref{ex:ood:hanniexamples} get posterior probability tending to $1$ as the natural training sets grow? By \cref{prop:ood:machine} no such statement holds for every universal machine; what is machine-invariant is the bounded number of errors (\cref{thm:ood:cumulative}).\end{question}` Delete the paragraph after it.
* `conj:ex:raw` (p1-hist-ex): `\begin{question}[raw blocks]\label{conj:ex:raw} With raw $d$-bit blocks, is SI's expected label loss at least $K(d)-\Kpad(d)-O(1)$? (The upper bound $K(d)+c$ is \cref{prop:ex:cycraw}; a heuristic: SI does not know where the first block ends, and the first label costs about $K(d)-\min_{L\ge d}K(L)$ bits.)\end{question}`

**F22. `prop:hist:lhg` (p1-hist-ex).** Before it: "\citet{lattimore2011universal} show that unnormalised Solomonoff induction can fail to predict simple recursive sub-patterns of a sequence. We do not show that their construction gives the following assumptions." Then two `assumption` environments: `\begin{assumption}[(LHG-even)]` "With $X=Y=\{0,1\}$ and the identity code, for some $\omega$ the loss of unnormalised $M$ on positions $2,4,\dots$ of $\omega_1\omega_1\omega_2\omega_2\cdots$ is unbounded." and `\begin{assumption}[(LHG-odd)]` "The same for positions $3,5,\dots$ of $0\omega_1\omega_1\omega_2\omega_2\cdots$." with "LHG" expanded in the sentence before. The proposition: "With $X=Y=\{0,1\}$ and the identity code: under Assumption (LHG-even), $\LMy\le\LH+O(1)$ fails on some sequence; under Assumption (LHG-odd), $\LH\le\LMy+O(1)$ fails on some sequence. For the code $\bar s=1^{|s|}0s$ the assumptions must also hold for framed blocks." Delete the "(abstract seen only)" clause and the attributed example. `rem:hist:H4verdict` and `rem:ex:where`: "conditionally on Assumptions (LHG-even) and (LHG-odd)".

**F23. Discussion, "Which version to call SFI" (p1-front).** Replace "and their gaps, although unbounded, are small on the known witnesses: about $\log d$ … (\cref{cor:versions:twopoint,prop:versions:tape})." by "and their gaps are unbounded. Between the program-based versions and SFI they are small on the known witnesses: about $\log d$ for the single shortest program on two points with $d$-bit inputs, and a padded tape-length cost for the program mixture (\cref{cor:versions:twopoint,prop:versions:tape}); the weak semimeasure, which has no posterior over functions, can exceed $\MF$ by linearly many bits (\cref{thm:setting:weakvsmachine})." Delete the paragraph "Relation to the literature" (moved to §2) and "In exchange," / "are each a precise statement, not a caveat"; "a universal hypothesis absorbs everything instead" → "a universal hypothesis is selected and fits the data as well as the universal mixture".

**F24.** (in F10.)

**F25. GF process after `thm:hist:expected` (hist.tex:193; p1-hist-ex).** "The upper bound is attained up to the last input's entropy in the randomised chain, but not in general. Let $(a,b,r)$ be uniform, let $f(a)=r$, $f(b)=r+ab$ and $f=\epsilon$ elsewhere, and reveal $a$ and $b$ in a uniformly random order. Then $I(f\to x)=(q-1)+\log(2^q-1)$, while the predictor of \cref{thm:hist:gf}(a) has $\Ex L_P=q$ and its reveal law has an $O(1)$ program relative to an oracle for $f$, and $\Ex\LSFI\ge3q/2-2$: a second process on which the oracle reading fails." At hist.tex:187 write "against the Bayes history-aware loss $q$ ($\LH\le q+c$)".

**F26. `rem:learn:cesaro` (p1-setting).** Title "per-step versus averaged bounds"; text: "\Cref{prop:learn:typical} is a per-step lower bound and cannot be compared with the Ces\`aro bound of \cref{thm:learn:batch}(a): since $\sum_k\Ex e_k\le(\ln2)(K(f)+c)$, $\liminf_kk\,\Ex e_k=0$. The per-step rate is given by \cref{cor:learn:perstep}." In learn.tex:141 cite the remark without "is refuted".

**F27.** (C-03 precision schedule: in F5.)

### Paper 2

**F28. Abstract (p2-front; replace; ≤ 1920 characters):**
```latex
Solomonoff function induction (SFI) predicts labels from inputs with a universal prior over random functions. We study the proposal to penalise program length more steeply than log-likelihood, by a factor $\lambda>1$, for hypotheses with private randomness at each input, so that learning selects a simple model plus noise rather than a model of a teacher's systematic errors. A standard objection is that a universal mixture, taken as one hypothesis, absorbs all structure. We prove that it does in every class containing its own mixture, such as Solomonoff induction and SFI with shared randomness, while no private-randomness hypothesis is universal. For a random parity on uniform inputs whose labels are flipped, at a rate below $0.056$, on an error set of product form that is incompressible relative to the parity, we prove that for $\lambda=cn$ ($n$ samples) and $c$ in an explicit window, every near-optimal hypothesis of the population objective knows the parity and gives the erroneous labels far less probability than a memoriser does. The window needs $\lambda$ proportional to $n$; density and description length of the error rule do not suffice. At $\lambda=1$ a computable sampler and the programs that fill in its sampled bits get similar posterior weight; for fixed $\lambda>1$, private randomness selects samplers over fill-ins, while with shared randomness a universal mixture beats every sufficiently long sampler.
```

**F29. Introduction bullets (p2-front).**
* Absorption: "… every $\lambda$-MAP is shorter than a bound that does not depend on the data, and for every fixed $\lambda>1$ a computable deterministic teacher's labels, errors included, are eventually predicted (\cref{thm:absorb:absorption}). …"
* Teacher: "If $S$ is incompressible relative to the parity, the inputs are uniform and $\lambda=cn$ with $c$ in an explicit window $(2^{-m},c_{\rm hi})$, every near-optimal product hypothesis of the population objective knows the parity, is short, holds little information about $S$ and gives the erroneous labels average probability at most $0.199$ ($\kappa=0$) or $0.274$ ($\kappa=30$) at $c=10^{-4}$ and the example's sizes, against $1$ for a memoriser (\cref{thm:teacher:main})." (The window of part (i) may stay closed at $c_{\rm hi}$; the identification conclusions are stated on the open interval.)
* Limits: "Plain Bayes, MDL and SI learn the errors, and so does every schedule with $(\lambda_n/n)(d+L_S)\to0$ along a sequence of instances, so steeper selection needs $\lambda=\Theta(n)$ … on almost a third ($\kappa=0$; a quarter at $\kappa=30$) of the window's logarithmic width …"
* Split: "… with $2\log(t_n+1)$ doubly logarithmic in the input length and at most triply logarithmic in $n$ and in the sampled randomness …"; "(\cref{thm:split:shared}): no sampler longer than $\ell^*_\lambda$ is selected"; "… by $d-O(\log d)$ bits for a range of sufficiency slacks".
* Computable classes: "The lower bounds and the private-randomness split hold in every c.e.\ prefix-free product class (for the split, one that contains the sampler), with the class's own constants (\cref{prop:related:computable})."

**F30. `tab:intro:claims` (p2-front).** Row 3: "Yes for error rules incompressible relative to the model. Not for every rule with the same density and description length: for one such rule, no hypothesis that fits no better than the good model is near-optimal on about a third ($\kappa=0$) to a quarter ($\kappa=30$) of the window's logarithmic width; elsewhere only the weaker bounds of \cref{thm:teacher:main} with that rule's deficiency apply." Row 8: "possible confident wrong extrapolation off the training support". Header and caption per §A11.

**F31. After `lem:setup:coding` (setup.tex:89; p2-body).** Replace the last two sentences by: "What separates the two kinds of class is whether one member attains the class's best two-part code length $\min_\pi[\ell(\pi)-\log P_\pi(D)]$ up to a constant on every data set. Under (Dom) the member $U$ does: $\ell_U-\log U(D)\le\ell(\pi)-\log P_\pi(D)+\ell_U+\kappa_0$ for every $\pi$ (\cref{sec:absorb}). In the product class no member does (\cref{cor:absorb:nouniversal})."

**F32. `cor:absorb:nouniversal` (p2-body).** Replace "and (Dom) fails in every product class." by "and (Dom) fails in $\Hcl{\times}$, and in every product class that contains, for every $d$, programs of length at most $d+2\log d+\kappa$ for the parities on $\{0,1\}^d$." Adjust the first paragraph of §absorb and `rem:absorb:wyeth`(ii) to "in the product class $\Hcl{\times}$".

**F33. `thm:absorb:absorption` (p2-body).** (a): "For every observation $o$ with $U(o)>0$, …". (c): begin "Let $\lambda>1$ be fixed." and add after (c3): "With $\lambda=cn$, (c1) and (c3) are not available; (a) and (c2) hold at each $n$." Same "$U(o)>0$" in `thm:split:shared`(i).

**F34. `prop:limits:plain` and `rem:limits:schedule` (p2-body).** (b): replace "If $\lambda_n/n\to0$, this tends to $1-2^{-B}$ as $n$ grows (within $n\le2^d$)." by "In particular $e(\hat\pi)\ge1-2^{-B}-o(1)$ whenever $(\lambda_n/n)\hat L\to0$ and $\hat L/n\to0$, along any sequence of instances $(d_n)$ with fixed $m$, $r$ and error rule and $n\le2^{d_n}$. On a fixed instance the bound is informative only once $(\lambda_n/n)(d+L_S)$ is small compared with $p$; for slowly decaying schedules such as $\lambda_n=n^{0.9}$ at the example's sizes this never happens for $n\le2^d$." (a): move "if all inputs are revealed, this is a fraction $1-9.6\cdot10^{-24}$ of the error inputs at the example's sizes ($\kappa=0$)" after the statement as "For instance, a direct computation … with the machine constant set to $0$ …"; write "$d+L_S+O(\log d+\log m)$ inputs (the memoriser can name $s_0$ through $r$)" (P2M-19). `rem:limits:schedule`: replace "every schedule with $\lambda_n/n\to0$ eventually reproduces the errors" (twice) by "every schedule with $(\lambda_n/n)(d+L_S)\to0$ along a sequence of instances eventually reproduces them (\cref{prop:limits:plain}(b))"; "This confirms H\"anni's remark that …" → "as anticipated in \citet{hanni2026grokking}".

**F35. After `thm:teacher:main` (teacher.tex:105; p2-body).** Replace "holds little information about the rule and gives the erroneous labels little probability" by "holds little information about the rule and gives the erroneous labels average probability at most $1-u+\gamma_g+2^{-g}$ (at most $0.2$ to $0.29$ at the example's sizes, against $1$ for the memoriser and $2^{-10}$ for the good model), when the error rule is large compared with the information budget"; "in the window $2^{-m}<c<c_{\rm hi}$" (open at $c_{\rm hi}$ for the identification conclusions; P2X-52).

**F36. Split (p2-body).** split.tex:5: replace the request quotation by "A second question of the author's notes is whether a steeper prior prefers a simple sampler to programs in which the sampled bits are filled in; at $\lambda=1$, Solomonoff induction has no such preference." and "up to explicit factors that do not depend on how much randomness was sampled" by "up to explicit factors: $2^{k+\delta^*}$ in one direction and $2^{2\log(t_n+1)+\kappa}$ in the other, where $2\log(t_n+1)$ grows at most triply logarithmically in $n$ and in the sampled randomness (not at all if the sampler's label probabilities are bounded below)"; "At $\lambda>1$ with private randomness the sampler wins" → "At fixed $\lambda>1$ with private randomness samplers beat fill-ins (not necessarily $\nu$ itself; \cref{rem:split:reading})". `thm:split:lambda1`(iii): replace "whatever the sampled randomness $-\log\nu(D_n)$" by "with a lower end that depends on the sampled randomness only through $t_n$". `sec:split:private` title: "$\lambda>1$ with private randomness: samplers beat fill-ins". split.tex:62: "whatever the amount of sampled randomness" → "with the dependence on the sampled randomness only through $t_n$". split.tex:55 Eisenstat: "Sam Eisenstat's coin example (personal communication; see also \citet{claudeSFI2026fundamentals})". Paragraph after `thm:split:shared` (P2M-11): "For fixed $\lambda$, both steeper predictors dominate $\nu$ ($\xi^\times_\lambda\ge2^{-\lambda k}\nu$; $\xi^F_\lambda\ge2^{-\lambda\ell_U-\kappa_0-k}\nu$), so by the argument of the merging theorem of \citet{claudeSFI2026fundamentals} their summed expected KL divergences to $\nu$'s predictions are at most $\lambda k$ and $\lambda\ell_U+\kappa_0+k$."

**F37. Discussion (p2-front).**
* ¶"What counts as one hypothesis": "it cannot for any model longer than $\ell^*_\lambda$, a bound that does not depend on the data, and for fixed $\lambda$ a computable teacher's labels, errors included, are eventually predicted".
* ¶"The window and its price": "near-optimal product hypotheses are, up to explicit slack, the simple model with noise for $2^{-m}<c<c_{\rm hi}$".
* ¶"The gap to realistic errors": replace the first two sentences by: "Human labelling errors are often cheap, frequent patterns rather than incompressible sets. In the parity instance steeper selection provably fails for such errors in two ways: a fixed cheap rule defeats every $c$ once the simple model is long enough (\cref{prop:limits:rateblind,lem:limits:robust}), and a rule made of a cheap region plus random points, with the original density and description length, makes the good model non-optimal on about a third of the window (\cref{prop:limits:envelope}). Whether any window survives for structured errors in general is open. Steeper simplicity sorts components by rate, not by validity (\cref{prop:limits:separable}), so by itself it does not tell errors from rare valid rules." The last sentence (LessWrong quotation) becomes: "We do not expect steeper penalisation alone to solve the general problem of learning a norm from imperfect imitation; it works in one toy case and fails in others."
* ¶"The model–randomness split": "indifferent, up to factors that grow at most triply logarithmically in the amount of data, between …".
* ¶"Relation to other work": "is the bridge question of the companion paper, which the slides of \citet{vaintrobhanni2026nnbayes} motivate".
* Open problems: delete (8); (2) "we expect that majority-like functions do not give a window" (no "presumably").

**F38. `absorb.tex:5` (p2-body).** "… can absorb all the structure of the data. This is a standard point, familiar from algorithmic statistics, where the model classes are restricted, for example to finite sets \citep{gacs2001algorithmic,vereshchagin2017algorithmic}.\footnote{The point was also raised in the online discussion (on LessWrong) in which the author described the proposal.}" Then the author's note sentence, paraphrased with at most one short quotation, cited to \citet{hanni2026grokking}.

**F39. `prop:teacher:concentration` (p2-body).** Add "with $cn\ge1$" to the hypotheses. App C.7: "$-1000+241.7=-758.3$".

**F40. `prop:algstat:parity`(i) (p2-body).** "lies on the sufficiency line for $\alpha$ between $O(\log d)$ and $d+O(\log d)$".

**F41. `rem:absorb:wyeth` (p2-body).** (i) "samplers longer than $\ell^*_\lambda=\ell_U+(\ell_U+\kappa_0)/(\lambda-1)$ are never selected (\cref{thm:split:shared}); with $\lambda=cn$ this tends to $\ell_U$"; (ii) quotation cited to \citet{hanni2026grokking}; (iii) "So restricting to private randomness is not free at $\lambda=1$ when compared with $\MF$."

**F42. Moved statements (P2X-47, p2-body).** `cor:teacher:fulltable`: the sentence "At $d=20$ … a direct computation gives the window $\lambda\in(1,1.19\cdot10^4]$ at $\kappa=0$ and $(1,6456]$ at $\kappa=30$" moves after the corollary, with the windows printed as $(1,1.19\cdot10^4)$ and $(1,6456)$. `prop:limits:noident`(ii): the losses at $c=10^{-1},\dots,10^{-7}$ move after the statement as an example with the machine constant set to $0$.

**F43. `lem:setup:hull` and `prop:algstat:set` (p2-body).** The refuted strengthenings move out of the statements into a remark directly after each: "The converse in (iv) cannot be weakened to `on the boundary of $C$': in $\mathcal A=\{(0,1),(10,0),(20,0)\}$ …" and "The bounds do not show that $\lambda$ slightly above $1$ selects an approximately minimal sufficient statistic: as $\lambda\to1$ the length bound becomes vacuous." In (iv) write "the open horizontal ray" (P2M-42).

**F44. `cor:teacher:fulltable`(ii) (p2-body).** "(ii) If $G_1>H(p)$ and $N(G_1-H(p))>d+\kappa_g+\log(N+1)$, then at $\lambda=1$ the optimum of $\ell+NR$, and the values $\ell(\pi_g)+NR(\pi_g)$ and $\ell(\pi_b)+NR(\pi_b)$, lie within $O(\log N)+\delta_E$ of each other, so $\lambda=1$ does not decide whether the errors are memorised; lower-order terms and the reference machine do." Same notation ($\ell+NR$ instead of $J_1$) in the proof. (P2M-25; the hypothesis is the one the proof uses.)

**F45. Parenthesis after `prop:limits:envelope` (limits.tex:44; p2-body).** "(Its deficiency is about $1{,}300$ bits; \cref{thm:teacher:main} applies to it with this value of $\delta_S$ in its bounds, which are correspondingly weaker, and \cref{prop:limits:envelope} says nothing about it above $c_{\rm env}$.)" Check `app-limits.tex:125` for the same reading. (P2M-26)

**F46. Power-prior versus tempered posterior (p2-body: setup.tex:48, `rem:related:posteriors`; p2-front: introduction, discussion).** Replace "In statistics these objects are generalised, Gibbs, fractional or safe posteriors with learning rate $\eta=1/\lambda$ \citep{…}" by: "The tempered posterior $\Pi^{1/\lambda}$ is a generalised (Gibbs, fractional or safe) posterior with learning rate $1/\lambda$ \citep{zhang2006epsilon,bissiri2016general,bhattacharya2019fractional,grunwald2012safe,grunwald2017inconsistency}, and the $\lambda$-MAP, its maximiser (\cref{lem:setup:basic}), is a two-part code with complexity weight $\lambda$. The power-prior posterior $\Pi_\lambda$ has the same maximiser but is Bayes' rule with the prior $2^{-\lambda\ell}$; it is proportional to $(\Pi^{1/\lambda})^\lambda$. Our posterior results concern $\Pi_\lambda$ unless stated." (P2M-27; the "two-part codes … reported to appear in MDL convergence theory" clause is deleted per §A8.)

---

## G. Bibliography

Verification basis: the WebSearch logs of the reviews (`scratch/p1-arxiv/bibcheck-log.md`, `scratch/p1-arxiv-r2/bib_log.md`, `scratch/p2-arxiv-B/bibcheck-log.md`) and the writers' dated bib comments. The lead editor's own searches could not run (the shared search budget was exhausted); no entry below depends on them. `core.bib` is identical in both papers and must stay identical: both front groups apply the same `core.bib` edits and `diff paper/bib/core.bib paper-steeper/bib/core.bib` must be empty at the end.

### G1. Drop (both papers)

| key | reason | what happens to the claims |
|---|---|---|
| `hanni2026request` | a message from the sole author; points to an internal file | §A7: author's voice or [Hän26]; Eisenstat "personal communication"; e-mail paraphrased |
| `hanni2026lesswrong` | unverifiable (no date, page unreachable); lists Wyeth as author | §A7, §B: cite `hanni2026grokking` where the text is there; three remarks restated without quotation; one footnote without citation |
| `ozkural2015ultimate`, `ozkural2017ultimate` (P1) | cited only for the operator-induction formula, which no check confirmed | §A8: $\Mpq$ is the paper's own object; Solomonoff (2008) cited at abstract level |

### G2. Fix (exact data)

| key | change |
|---|---|
| `hanni2026notes` (core) | `title = {Working notes, 2023--2026}`, `howpublished = {Public repository, \url{https://github.com/kaarelh/notes}}`, `year = {2026}`, `note = {Accessed October 2026. The note on Solomonoff function induction is in the folder \texttt{ai/learning/solomonoff induction}}`. Cite with a pinpoint where a specific note is meant: `\citet[note ``polytime solomonoff'']{hanni2026notes}`. |
| `hanni2026grokking` (new, core) | `@misc{hanni2026grokking, author = {H{\"a}nni, Kaarel}, title = {Beating {Solomonoff} induction at grokking a notion}, howpublished = {Note in the repository \url{https://github.com/kaarelh/notes}, folder \texttt{philosophy/philosophy of thinking}}, year = {2026}, note = {Accessed October 2026}}` — used in Paper 2 and in Paper 1 `sec:steep`. |
| `claudeSFI2026fundamentals`, `claudeSFI2026steeper` (core) | `howpublished = {Preprint}`, `note = {Folder \texttt{solomonoff-function-induction} of \url{https://github.com/kaarelh/AI-works}}`; replace by the arXiv identifiers at submission. Titles as in the final `main.tex`. |
| `claude2026whatfollows` (core; cited only by P2) | keep the report's own author line `{Claude (Anthropic)}` and title; `howpublished = {Report, \url{https://github.com/kaarelh/AI-works/tree/main/inferential-learning}}`, `year = {2026}`; delete "Unpublished report prepared for K. Hänni" and the `note`. Cite once as `\citet[Section~8]{claude2026whatfollows}` (Section 8 is "Simplicity and normativity from imitation"; checked in `inferential-learning/paper/main.tex`), then "the earlier report". |
| `vaintrobhanni2026nnbayes` (core) | keep; verified against the local copy of the slides (title page). The author confirms before submission that the URL is public; if not, `howpublished = {Slides of a talk at ILIAD 2026}` without URL. |
| `hoeffding1963probability` | `number = {301}`, `doi = {10.1080/01621459.1963.10500830}` |
| `barzdin1972prediction` | `pages = {1224--1228}` |
| `ville1939etude` | `series = {Monographies des Probabilit{\'e}s}`, `number = {3}`, `publisher = {Gauthier-Villars}`, `address = {Paris}` (confirmed by the Paper 2 review) |
| `grunwald2007suboptimal` (P1 steeper.bib, P2 steep-b.bib) | `number = {2--3}`, `doi = {10.1007/s10994-007-0716-7}` |
| `case1983comparison` | `number = {2}` |
| `kleitman1973families` | `number = {3}` |
| `gacs1974symmetry` | `number = {5}` |
| `wood2013non` | `editor = {Dowe, David L.}`, `series = {Lecture Notes in Computer Science}`, `volume = {7070}`, `pages = {417--425}` |
| `orseau2013universal` | `series = {Lecture Notes in Computer Science}`, `volume = {8139}` |
| `day2011increasing` | `volume = {363}`, `number = {10}`, `pages = {5577--5604}` (AMS issue listing, second P1 review); correct the comment "CCC 2009" to "CCR 2009" |
| `grunwald2012safe`, `grunwald2017inconsistency`, `zhang2006epsilon`, `bissiri2016general`, `bhattacharya2019fractional` | add the DOIs of P2X-36 |
| `vovk1990aggregating` | no change (end page differs between sources; pages stay omitted) |

### G3. Keep as verified

All other printed entries of `paper/bib/*.bib` (57 verified as printed by the P1 reviews) and of `paper-steeper/bib/*.bib`. Nine Paper 2 entries rest on the writers' dated search records only (`koppel1987complexity`, `koppel1991almost`, `vitanyi2006meaningful`, `antunes2009sophistication`, `milovanov2016algorithmic`, `cover2006elements`, `goldreich1989hard`, `kushilevitz1993learning`, `wenzel2020good`); they are kept, their data agree with the standard records, and they are on the author's pre-submission check list (priority: Milovanov's title and pages, Kushilevitz–Mansour's pages). Bibliographic comments in `.bib` files stay (they are not uploaded; §A12).

### G4. What each kept citation may support

Content per §A8. In particular: `solomonoff2008three` (three kinds of induction; operator induction concerns an unordered set of ordered pairs), `hutter2000theory`/`hutter2005universal` (chronological semimeasures and a universal mixture for AIXI), `hutter2007aixi` (supervised learning among AIXI's problem classes), `lattimore2011universal` (unnormalised SI can fail on simple recursive sub-patterns; normalised SI learns them), `lattimore2013nofree` (Solomonoff-inspired off-line classifier; random selection of training data), `wood2013non` (Solomonoff's and Levin's constructions define the same class of priors), `leike2015bad` (AIXI's optimality depends on the reference machine), `poland2005asymptotics` (two-part MDL prediction bounds exponentially worse than Bayes), slides (their own claims, as theirs), `basri2019convergence` ("cannot represent or learn simple, low-frequency functions with odd frequencies"), `mingard2025deep` ("together with the structure of the data"), `vovk1992universal` ("see also"), Barzdin–Freivalds (prediction of recursive functions with bounded errors, not identification in the limit; C-29).

---

## H. Phases, order of work and final checks

* **Phase 0 (front groups, first):** add the `question` environment and `\crefname`s (§A10) to both preambles; add `\hypersetup`; add the new bib entry `hanni2026grokking` and the `claudeSFI` fixes to both `core.bib`; announce in the logs. Body groups may start editing immediately but compile `question` environments only after phase 0.
* **Phase 1 (all groups in parallel):** fatal and major issues of their lists, statement changes of §F, status rendering (§A1 and `status-rendering.md`), process vocabulary, voice, citations, moves within the group. Isolated builds with `./test-section.sh`.
* **Phase 2:** minor issues; cross-group moves (`rem:learn:hutterEX` → related work; the P2 "Prior work" paragraph → §2); length cuts to the budgets of §C; group logs with page counts.
* **Phase 3 (front groups):** abstract, introduction and discussion against the final body (every claim with the body's hypotheses); verification switch (§A3); main.tex order (§D2); bibliography (§G); the grep checks of §A2.5, §A5 and §B.6; the `\status`/`\src` redefinition (§A2.4); full build via `flock /tmp/claude-0/paper-build-sfi.lock ./build.sh` until there are 0 LaTeX errors, 0 undefined references and citations, 0 multiply defined labels and no overfull box above 10pt; page counts against §C.
* **Phase 4 (p2-front, after Paper 1's final build):** replace Paper 2's informal names of companion results by "\citet[Theorem~X.Y]{claudeSFI2026fundamentals}" with the numbers from Paper 1's final `main.aux`, and check Paper 1 `sec:steep` against Paper 2's final statements (P2X-24).

Acceptance criteria for the pass: no fatal or major issue of the `edits/*.json` lists open in the logs; the greps of §A5 and §B return only the allowed hits; `\status`/`\src` print nothing and every non-plain status has a "rendered as" entry; the length caps of §C hold.
