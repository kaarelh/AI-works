
### 4.3 The verification appendix: drop, and what moves where

`sections/app-verification.tex` (Appendix I, PDF pages 96–103) is dropped entirely (remove `\input{sections/app-verification}` from `main.tex`). Its parts go as follows.

| part of Appendix I | destination |
|---|---|
| I.1 "Process" (roles, five tracks, referees, revision, planning editor; "No referee found a fatal issue ...") | Acknowledgements only, in the two-to-four sentences already there (discussion.tex line 31): developed with Claude (Anthropic) under the author's direction; each part checked by independent AI referee passes that re-derived the proofs and wrote independent code; what a human has checked (P1X-31). Nothing else. |
| scripts table (seeds, re-runs, Python versions) | New short appendix "Code and data": one table result → script → command → output file → seed, plus the environment line (Python 3.11, numpy 2.4.6, scipy 1.17.1, mpmath 1.3.0) and the reproduction loop (P1X-30). |
| I.2 "Corrections" longtable (58 rows) | Dropped. Corrections of the author's notes that inform the reader stay where they occur in the body (prop:hist:sketchfails, prop:ood:draftfalse, prop:ood:converse, rem:comp:majority, rem:ex:email). Internal corrections of the tracks are not mentioned anywhere (this also removes rem:learn:cesaro, P1X-23). |
| I.3 cross-track conflicts C1–C25 (incl. "C25: a promised Wyeth–Hutter reference") | Dropped. |
| I.4 "What is not fully established": conjectures; proof sketches and conditional results; "results checked by their authors only"; the slides | Conjectures stay as conjecture environments; each proof sketch and conditional result is marked where it is stated (section 4.1, rows 1–7); the slides' unverified claims are stated as theirs in Section 11 (P1X-33). "Results checked by their authors only" is dropped (the acknowledgements say how the paper was checked). |
| I.5 "Literature" (no source could be opened) | Dropped after the literature is checked (P1X-14); any remaining limitation is one sentence in the acknowledgements. |
| I.6 "Reproduction" | Code-and-data appendix. |
| I.7 "Unresolved points" (length, conversion, status vocabulary, paragraph labels, ω-indexing note, shared bibliography) | Dropped; the items are addressed by P1X-08, P1X-27, P1X-28 and the bib fixes. |

No bibliography entry is cited only in Appendix I (checked against `main.aux`), so dropping it removes no reference.

### 4.4 Mechanical steps, in order

1. Rewrite the 114 environments of the table in 4.1 (content changes first, while `\status` still shows what each item is).
2. Fix the 111 visible process-vocabulary and hedge hits of 4.2 (most are covered by rewrites in step 1 and by the literature check).
3. Remove `\status{...}` and `\src{...}` from all section files (203 + 203 calls, plus the inline `\status` in setting.tex line 40 and app-versions.tex lines 92 and 102), then delete both macros from `preamble.tex`, so that any leftover call fails to compile.
4. Delete Table 1 (tab:intro:verdicts) and the reference to it in learn.tex line 87; rewrite the corrections paragraph (P1X-10).
5. Drop Appendix I; add the Code-and-data appendix.
6. Replace the `\paragraph{Open question.}` labels by a numbered question environment (P1X-27).
7. Bibliography: drop `hanni2026request`, `hanni2026lesswrong`; fix `hanni2026notes`; add the draft entry if cited; apply the field fixes of section 5; add the missing related work (decision complexity) after reading it.
8. Delete the source-file comments that point to `research/tracks/...`, `CLAIMS.md`, `OUTLINE.md` and "writer"/"framing editor" (they are invisible in the PDF but arXiv distributes the sources): every section file starts with such a comment block (e.g. hist.tex lines 1–9, main.tex lines 5–7 and 36–38).
9. Build: add `\hypersetup{pdftitle=..., pdfauthor=...}`; submit `main.bbl` (arXiv does not run `merge_bib.py`); check that no string from the list "track, referee, ledger, notes-final, brief, orchestrator, request, verdict, H1–H10, snippet, unverified, not checked, draft, Wyeth" remains in `pdftotext main.pdf` (except "referee" in the disclosure sentence the binding note prescribes).

## 6. Structure and length against a typical arXiv paper in learning theory / AIT (task 6)

**Current shape.** 103 pages: title + abstract + contents (pp. 1–2), introduction (pp. 3–7), Sections 2–9 of results (pp. 7–47), summary of Paper 2 (pp. 47–49), related work (pp. 49–50, one page), discussion and open problems (pp. 50–52), references (pp. 52–56), eight proof appendices (pp. 57–96) and the verification appendix (pp. 96–103). About 50,000 words in the section files; 203 theorem-like environments (33 theorems, 68 propositions, 17 lemmas, 12 corollaries, 48 remarks, 13 definitions, 8 examples, 4 conjectures) and about 20 open questions. No figures.

**Typical arXiv paper in the area.** A foundational paper in algorithmic information theory or learning theory (e.g. the ALT/COLT long versions cited here: Lattimore–Hutter–Gavane 2011, Leike–Hutter 2015; or JMLR/TCS articles) has 20–40 pages including appendices, one to three main theorems stated informally in the introduction, a contributions list of four to six short items, a related-work section of one to two pages based on read sources, preliminaries, results, discussion. Very long AIT surveys exist (Vereshchagin–Shen 2017 is 69 pages), but they are surveys.

**Assessment.** The paper is about two to three times the usual length and covers three papers' worth of topics: (i) foundations (definitions, versions, learning theorems), (ii) order and history (Sections 5–6), (iii) out-of-distribution, computable versions and neural networks (Sections 7–9). The introduction has a contributions list (good) but it is a catalogue (8 bullets, 65 cross-references) and no informal main theorems; the related-work section exists (good) but is one page of hedges.

**Recommended structure** (main text ≤ 35 pages; appendices ≤ 35 pages):

| new § | content | from | target pp. |
|---|---|---|---|
| 1 | Introduction: motivation; informal definition; Theorems A–D stated informally (universality/invariance/dominance; no coding theorem; order blindness and SFIhist; the two examples); contributions (5 short bullets); relation to the author's notes; organisation | intro.tex | 3 |
| 2 | Preliminaries and definitions: data, conventions, function machines, universality, SFI, invariance, coding bounds (move weak semimeasures, Möbius, normalised-transfer details to App. A) | setting.tex | 4 |
| 3 | Versions: chain, W gap, tape bound, no coding theorem, table | versions.tex | 3 |
| 4 | Learning: dominance, merging, mistakes, online-to-batch, fresh noise, per-query mixture, Occam comparison (move sec:learn:curves except cor:learn:perstep to App. C) | learn.tex | 4 |
| 5 | Order and history: counterexamples, reveal-law theorem (short), SFIhist universality, SI comparison (move thm:hist:gf, thm:hist:expected, prop:hist:lhg, prop:hist:inputloss details to App. D) | hist.tex | 5 |
| 6 | Worked examples: cyclic permutation, Eisenstat, positive examples (short) | examples.tex | 4 |
| 7 | Out-of-distribution (move ex:ood:easyhard, ex:ood:hanniexamples to App. F) | ood.tex | 3 |
| 8 | Computable versions and neural networks (merge Sections 8 and 9; move rem:comp:apples, prop:comp:samplers, rem:comp:selection, rem:comp:uniformties, rem:nn:slides, rem:nn:literature, rem:nn:rigorous out) | comp.tex, nn.tex | 4 |
| 9 | Related work (2 pp., after reading the sources; include decision complexity, Lattimore–Hutter 2013, Hutter's EX section, operator induction from the primary source) | related.tex | 2 |
| 10 | Discussion and open problems (one paragraph on Paper 2 replaces Section 10) | discussion.tex, steeper.tex | 2 |
| App. | proofs A–H; Code and data | app-*.tex | ≤ 35 |

An alternative that keeps more material: split off Sections 8–9 (computable versions and neural networks, about 9 pages with appendices G–H) as a short third paper.

## 7. Readability (task 7)

### 7.1 Page-1 story and a proposed abstract

Page 1 currently holds the title, a 248-word abstract and the start of a table of contents; the introduction begins on page 3 after a `\newpage`. The abstract lists results without motivation and uses undefined terms (P1X-07). A proposal (about 1,700 characters, under arXiv's limit of 1,920; it also fixes P1X-01 and P1X-02):

> Solomonoff induction is the standard ideal predictor for sequences. We study its analogue for supervised learning, Solomonoff function induction (SFI): Bayesian prediction of labels from input–output pairs under a universal prior over random functions, in which a random program reads random bits shared by all inputs. A universal function machine exists; its law dominates every machine law and is invariant, up to constant factors, under the choice of universal machine and under computable injective re-encodings. The shortest consistent program, the program mixture, the mixture of product laws, SFI and the universal weak semimeasure agree up to K(dom D) bits, but there is no coding theorem for function programs. On every consistent data sequence, chosen in any way, SFI's cumulative log loss exceeds that of every computable random labeller by at most the labeller's complexity; with i.i.d. inputs and deterministic computable labels the averaged predictor has risk O(K/n). Random-function SFI cannot model fresh label noise on repeated inputs; a per-query mixture can. SFI's cumulative loss, measured on its raw sub-probabilities, ignores the order of the data: on a random cyclic permutation of {0,1}^d revealed backwards along its cycle it pays about (d − log₂ e)2^d bits, while Solomonoff induction on the interleaved sequence pays O(1) bits of label loss in expectation. Letting hypotheses see the list of previous inputs gives the universal chronological semimeasure and removes these gaps. We also treat a dominance theorem for computable reveal orders, a coin example due to Sam Eisenstat, out-of-distribution behaviour, time-bounded and circuit versions, and neural-network Bayes.

(If the reveal-law theorem is mentioned with a result, use the wording of P1X-01.)

### 7.2 Motivation and examples

* The first paragraph defines SFI by quoting informal, lower-case notes (P1X-44). The "Why SFI" paragraph is good and should come first, followed by an informal definition in the paper's own words.
* The introduction never shows a small example. The shared-coin law F(x) = ω_{|x|+1} (one fair coin per input length) is the paper's simplest example of what shared randomness buys (prop:versions:shared) and would make "random program reading shared random bits" concrete on page 2; the cyclic permutation is the natural example for order blindness. Both are already in the paper.
* Informal statements of three or four main theorems on page 2 would let a reader decide whether to read on (P1X-29).
* A figure of the chain 2^{−K_F} ≤ W ≤ M_prod ≤ M_F ≤ M_w with the known gaps (from Table 2) would replace a paragraph of prose; a diagram of SFI / SFIhist / SI on the interleaved sequence would anchor Sections 5–6.

### 7.3 Definitions before use

Section 2 is dense but in the right order (data, weak semimeasures, machines, universality, SFI, conventions, basic properties). Fixes are local: P1X-37 (M_F, Mnorm, LHG), the semimeasure convention defined on page 1–2 of the introduction rather than at the end of the reader's guide, and Definition 2.1, which packs eight notions (data set, D+(x,y), restriction, extension, consistency, history, conditional, repeated-input convention) into one paragraph and would read better as a short list.

### 7.4 Voice

With the sole author named Hänni, sentences that assess "Hänni's" claims in the third person must be neutralised (P1X-13). The register is otherwise formal and concise; the remaining informal phrases are listed in P1X-43, P1X-50, P1X-53.

