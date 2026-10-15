
### 4.2 Every process-vocabulary passage in the visible text

This section covers what remains once the `\status`/`\src` markers (4.1) and Appendix H (4.4) are gone. The list comes from `process_vocab.out`, filtered by hand. Ordinary English uses are excluded ("selection tracks population selection", "a dovetailed search"). So is the title-page footnote's "independent AI referees", which the binding note prescribes.

| # | file:line | passage | replacement |
|---|---|---|---|
| V1 | intro.tex 14 | "lists Hänni's specific claims with their verdicts" | "lists the questions raised in [grokking note] and where they are answered" |
| V2 | intro.tex 27, 43 | Table 1 header "Claim & Verdict & Where"; caption "Hänni's specific claims about the proposal \citep{...,hanni2026request}, with verdicts" | header "Question & Answer & Where"; caption "Questions raised in the author's notes [grokking note] and where they are answered. Numbers with κ = 0 are illustrations." |
| V3 | intro.tex 46 | "as their abstracts describe them" | state what the papers prove (P2X-15) |
| V4 | intro.tex 46 | "Our literature search went only as far as abstracts, so the novelty claims of Remark 8.8 need a check against full texts." | delete (P2X-14, P2X-20) |
| V5 | intro.tex 48 | "which are cited in the third person, as Hänni's" | delete (P2X-12) |
| V6 | intro.tex 12, 43, 48; split.tex 5, 55 | `\citep{hanni2026request}` (prints "Personal communication to the author ... 00-brief.md") | author's voice; Eisenstat as personal communication (P2X-07) |
| V7 | setup.tex 48 | "are reported to appear in MDL convergence theory" | verified statement with chapter, or delete (P2X-17) |
| V8 | absorb.tex 105 | ``nothing is lost at λ = 1'' (an earlier draft's claim, in quotation marks) | "restricting to private randomness is not free at λ = 1 when compared with M_F" (P2X-33) |
| V9 | teacher.tex 8, 10, 107, 160, 166 | headings "Hänni's calculation" (subsection and remark), "Numbers at Hänni's sizes", "Hänni's numbers with sampled data", "Hänni's Version 1, in population form" | "The three-hypothesis calculation", "Numbers for the running example", "Finite samples", "The total-bits version of the example" (P2X-12) |
| V10 | limits.tex 89 | `\citep[H\"anni's proposition, with no log term]{...}` | the companion's result number (P2X-24) |
| V11 | limits.tex 98 | "looks within reach but is not proved" | open question (P2X-43) |
| V12 | algstat.tex 48 | "the thresholding above is presumably that translation" | verify or delete (P2X-19) |
| V13 | algstat.tex 82 | "As far as we can tell from the abstracts, ...", "A comparison with the full texts is left open." | after reading, a plain statement (P2X-16) |
| V14 | related.tex 35 | "As their abstracts describe them", "Their abstracts do not mention ...; whether their analysis covers some of this can only be settled from the full texts." | P2X-15 |
| V15 | related.tex 39 | "This is our reading, not checked against the papers' precise criteria." | P2X-18 |
| V16 | related.tex 47 | "We have not found the following in the literature, though our search was limited to abstracts:" | "To our knowledge the following are new:" after the check (P2X-20) |
| V17 | related.tex 51 | "And the novelty claims of Remark 8.8 remain to be checked against the full texts of ..." | delete |
| V18 | discussion.tex 26 | open problem "(8) Literature. The novelty claims ... need a comparison with the full texts ..." | delete |
| V19 | discussion.tex 30 | "and the comparison with the literature rests on abstracts and search snippets" | delete (after P2X-15 to P2X-20) |
| V20 | discussion.tex 33 | "the research notes with full proofs from which the paper was written are in the folder solomonoff-function-induction/research/tracks/steeper/" | new Code and data statement (4.5; P2X-21) |
| V21 | app-teacher.tex 56, 125, 137, 196, 216, 220; app-limits.tex 10, 12, 37, 65, 102 | script names `c6_revision.py`, `c7_run2.py` | content names (P2X-39) |
| V22 | app-teacher.tex 220; app-related.tex 46 | "were re-run from scratch copies and reproduce" | "reproduce" |
| V23 | app-teacher.tex 17, 125; app-limits.tex 65, 127; app-split.tex 42, 95, 101; app-absorb.tex 48 | "an independent computation/re-implementation" | acceptable once the Code and data statement says that independent implementations are included (4.5) |
| V24 | 65 visible "Hänni" and 19 "his/he" | third-person voice | P2X-12 |

### 4.3 Every mention of Wyeth, and how to remove it

**In the PDF (17 lines):**
* pp. 3 (×3), 5 (×2), 7, 8 (×2), 9 (footnote), 12, 13, 14, 19, 20 and 32 print "(Hänni and Wyeth, undated)";
* p. 34 prints the bibliography entry "Kaarel Hänni and Cole Wyeth. Comments in the thread ...";
* p. 62 (Appendix H.6) prints the citation again.

**In the source** (public on arXiv):
* the label `rem:absorb:wyeth` (absorb.tex 5, 101; intro.tex 16);
* `bib/core.bib` line 28 and `bib/all.bib` line 31 (`author = {H{\"a}nni, Kaarel and Wyeth, Cole}`);
* `main.bbl` lines 112–113;
* comments in absorb.tex 2 and intro.tex 7 (harmless wording, but they would be public).

**Not present:** no quotation of Wyeth's comment (checked against `research/prior/hanni-lesswrong-comment-thread.md`). No heading, theorem or remark is named after him. The visible title of `rem:absorb:wyeth` is "Answer to the absorption objection", as required. The paraphrase of the objection at intro.tex 12 and absorb.tex 5 is close to his wording ("a universal distribution which penalizes complexity minimally as usual"), but it is not a quotation and describes a standard point. That is acceptable once the point is attributed to algorithmic statistics (P2X-09).

**Replacement map for the 15 body citations of `hanni2026lesswrong`.** "Grokking note" means `philosophy/philosophy of thinking/beating solomonoff induction at grokking a notion.md` in github.com/kaarelh/notes, verified public (WebFetch, 2026-10-12).

| .tex line | what is cited | in the grokking note? | action |
|---|---|---|---|
| intro 10 | "each input gets its own private randomness" | yes (messy notes, second draft) | cite the note |
| intro 12 (1st) | "I don't see how to write down a universal hypothesis that gets good loss here" | yes | cite the note |
| intro 12 (2nd) | "Maybe I'm just failing ...", "some other pathology", "somewhat cherry-picked for the idea to work" | first two yes; "cherry-picked" no | cite the note; restate "cherry-picked" in the author's voice ("the example was chosen to favour the idea") |
| intro 43 | Table 1 caption | n/a | cite the note only |
| intro 48 | credits | n/a | cite the note only |
| setup 48 | "a higher coefficient on the length of the program than on the likelihood terms"; "penalize the likelihood term less" | yes, both | cite the note |
| setup 61 | "we will need to increase the hypothesis term coefficient ... as the data set size increases" | yes | cite the note |
| setup 64 | "the `good model' could be a vertex of the convex hull ..." | yes | cite the note |
| absorb 5 | footnote "It was also raised in the comment thread ..." | n/a | keep as the one neutral footnote with a sole-author entry and a real date, or delete |
| absorb 104 | "if each input gets its own private randomness, then I don't see how ..." | yes | cite the note |
| teacher 11 | the two versions of the example | yes (Version 2 wording there: "with those inputs taking 10000 bits to specify") | cite the note; quote its wording |
| teacher 16 | "Maybe I'm just failing to construct the right `universal hypothesis' ..." | yes | cite the note |
| limits 21 | "we will need to increase the hypothesis term coefficient ..." | yes | cite the note |
| limits 44 | "definitely somewhat cherry-picked for the idea to work, though I also don't consider it completely contrived" | no | restate in the author's voice, no quotation |
| discussion 9 | "it's very unlikely this steeper penalization is anywhere close to a full solution ...", "some hope that it works in some specific toy cases" | no | restate in the author's voice ("We do not expect steeper penalisation to solve the general problem; ...") |

After this, `hanni2026lesswrong` is cited at most once (the footnote). Rename the label to `rem:absorb:answer`. The tarball check of 4.6 must find no "Wyeth".

### 4.4 The internal-record appendix and the `\ifsfirecord` switch

`main.tex` lines 9–13 define `\newif\ifsfirecord` and set `\sfirecordtrue`; line 46 inputs `sections/app-verification.tex` (Appendix H, pp. 58–63) when the switch is true. The appendix's own first paragraph says that the arXiv version sets `\sfirecordfalse`. That is not sufficient, because arXiv distributes the source and the file would be in it. Plan:

1. Delete lines 9–13 and the `\ifsfirecord` line from the arXiv copy of `main.tex`, and do not upload `sections/app-verification.tex`. Keep both on the working branch as the internal record.
2. What a reader needs from Appendix H is already elsewhere or moves:
   * H.1 (preparation) is covered by the acknowledgements paragraph (4.5).
   * H.2 (referee rounds): one clause in the acknowledgements ("refereed in two rounds with independently written code") is enough.
   * H.3 (scripts and reproduction) moves into Code and data and Appendix C.8, with neutral script names.
   * H.4 rows 1–3 (refuted statements) are already in the body (prop:limits:envelope, lem:setup:hull, prop:algstat:set). Rows 4–31 are internal corrections and are not printed.
   * H.5 (status of the claims): not printed. The theorem environments now carry this information.
   * H.6 (references not checked): resolved by P2X-14 to P2X-20 and section 5, not printed.
   * H.7 (open issues of this draft): resolved by P2X-26, P2X-05/06 and P2X-24, not printed.

### 4.5 Acknowledgements and Code and data (proposed text)

The title-page footnote already matches the binding note word for word and can stay.

**Acknowledgements.** "This paper was developed and written with extensive assistance from Claude (Anthropic), an AI system. Under the author's direction, Claude produced the proofs, the computations and the text. Separate instances checked the proofs in two adversarial rounds and re-implemented the main computations independently. The earlier report [Cla26], whose results are re-derived here, was prepared in the same way. No human has yet independently checked all of the mathematics. The author thanks Sam Eisenstat for the coin example discussed in Section 6.2 and in the companion paper."

**Code and data.** "All numerical statements are produced by deterministic or seeded Python 3.11 scripts (NumPy, SciPy). The scripts, their saved outputs and independent re-implementations of the main computations are in the folder `solomonoff-function-induction/code/steeper/` of https://github.com/kaarelh/AI-works (release <tag>). Appendix C.8 lists the script for each computation."

This requires publishing the scripts to main under a neutral path, with names by content, and pinning a tag (P2X-21, P2X-39).

### 4.6 Mechanical steps, in order

1. Resolve the content issues first: P2X-01 to P2X-04 (front and back matter), P2X-09 and P2X-15 to P2X-20 (literature), P2X-05 to P2X-08 and P2X-22, P2X-23 (sources). Steps 2–10 are mechanical.
2. Delete every `\status{...}` and `\src{...}` (a brace-matching script such as `extract_status.py` can do it); apply the 12 rewordings of 4.1 that carry content.
3. Apply 4.2 (V1–V24) and 4.3.
4. Rename `rem:absorb:wyeth` → `rem:absorb:answer` (3 places).
5. Retitle the four theorem-like headings and Section 4.1 (V9); rewrite Table 1.
6. Replace the open-question cross-references (P2X-25); cite Paper 1 by number (P2X-24).
7. Delete the `\ifsfirecord` lines and leave out `app-verification.tex` (4.4).
8. Replace the acknowledgements and Code and data statements (4.5).
9. Fix the bibliography (section 5); rebuild; check that the printed bibliography has no "undated", "personal communication", "Draft", "prepared for".
10. Make the arXiv folder:
    * `latexpand main.tex > arxiv/main.tex`;
    * strip comments (arxiv_latex_cleaner);
    * copy `main.bbl` (not the `.bib` files);
    * add `\hypersetup{pdftitle=..., pdfauthor=...}` (P2X-40);
    * compile there twice;
    * `grep -i -E 'wyeth|track|referee|ledger|notes-final|brief|orchestrat|CLAIMS|OUTLINE|steep-[ab]|framing editor|unverified|snippet|abstracts? only|run2|revision\.py|scratch'` must return nothing. The only exception is "independent AI referees" in the footnote, which the binding note prescribes. "Claude" may appear only in the footnote and the acknowledgements.
11. Suggested arXiv categories: cs.LG (primary), cross-list cs.IT (math.IT) and stat.ML.

---

## 5. Bibliography: every entry in `bib/*.bib`

The bibliography has 42 entries in `bib/all.bib` (`core.bib` 27, `steep-a.bib` 9, `steep-b.bib` 6), of which 37 are cited and printed. Sources:
* "WS": this reviewer's WebSearch, 2026-10-12;
* "WS-P1": the Paper 1 review's same-day WebSearch log;
* "writer": the writers' bib comments only, because the shared search budget ran out.

Full log: `scratch/p2-arxiv/bibcheck-log.md`.

| key | printed | verdict | confirmed data / problem | action |
|---|---|---|---|---|
| hoeffding1963probability | yes | verified, fixable (WS) | JASA 58(301):13–30, doi 10.1080/01621459.1963.10500830 | add number, doi |
| sion1958general | yes | verified (WS) | Pacific J. Math. 8(1):171–176 | — |
| barron1991minimum | yes | verified (WS) | IEEE TIT 37(4):1034–1054 (correction Nov. 1991) | the content it is cited for is unverified (P2X-17) |
| gacs2001algorithmic | yes | verified (WS) | IEEE TIT 47(6):2443–2463 | — |
| vereshchagin2004kolmogorov | yes | verified (WS) | IEEE TIT 50(12):3265–3290 | — |
| vereshchagin2010rate | yes | verified (WS) | IEEE TIT 56(7):3438–3454; abstract matches rem:algstat:restricted's description | read the full text (P2X-16) |
| vereshchagin2017algorithmic | yes | verified (WS) | LNCS 10010:669–737; arXiv 1607.08077 | check the cited equivalence (P2X-19) |
| grunwald2007minimum | yes | verified (WS) | MIT Press 2007 | content (P2X-17) |
| gneiting2007strictly | yes | verified (WS) | JASA 102(477):359–378; the abstract's definition of strict propriety matches prop:limits:noident(i) | — |
| grunwald2012safe | yes | verified, fixable (WS) | ALT 2012, LNCS 7568:169–183, doi 10.1007/978-3-642-34106-9_16 | add doi; content (P2X-18) |
| grunwald2017inconsistency | yes | verified, fixable (WS) | Bayesian Anal. 12(4):1069–1103, doi 10.1214/17-BA1085 | add doi |
| zhang2006epsilon | yes | verified, fixable (WS) | Ann. Statist. 34(5):2180–2210, doi 10.1214/009053606000000704 | add doi |
| bissiri2016general | yes | verified, fixable (WS) | JRSS-B 78(5):1103–1130, doi 10.1111/rssb.12158 | add doi |
| bhattacharya2019fractional | yes | verified, fixable (WS) | Ann. Statist. 47(1):39–66, doi 10.1214/18-AOS1712 | add doi |
| li2008introduction | yes | verified (WS) | Springer 3rd ed. 2008 | — |
| solomonoff1978complexity | yes | verified (WS) | IEEE TIT IT-24(4):422–432 | — |
| poland2005asymptotics | yes | verified (WS) | IEEE TIT 51(11):3780–3795; the abstract confirms "exponentially worse than Bayes" (rem:absorb:reading) | — |
| kakutani1948equivalence | yes | verified (WS) | Ann. of Math. 49(1):214–224 | — |
| ville1939etude | yes | verified, fixable (WS) | Monographies des Probabilités, fasc. III, Gauthier-Villars 1939 (also Numdam thesis no. 218) | add series |
| hanni2026notes | yes | source verified; entry unfit | public repo; grokking note and SFI note located | replace by two specific entries (P2X-08) |
| claude2026whatfollows | yes | source verified (public on main); entry fixable | inferential-learning/ on main; Section 8 | URL, year, author line, drop "prepared for" (P2X-23) |
| grunwald2007suboptimal | yes | verified, fixable (WS-P1) | Machine Learning 66(2–3):119–149, doi 10.1007/s10994-007-0716-7 | add number, doi; content (P2X-15) |
| zhu2025quantifying | yes | verified (WS-P1) | COLT 2025, PMLR 291:6124–6155 | content (P2X-15) |
| zhu2026overfitting | yes | verified (WS-P1) | arXiv:2603.22644 | content (P2X-15) |
| vaintrobhanni2026nnbayes | yes | verified against the local copy only | URL not reachable or found | check the URL (P2X-38) |
| koppel1987complexity | yes | writer only | Complex Systems 1(6):1087–1091 | re-check (P2X-37) |
| koppel1991almost | yes | writer only | Inform. Sci. 56:23–33 | re-check |
| vitanyi2006meaningful | yes | writer only | IEEE TIT 52(10):4617–4626 | re-check |
| antunes2009sophistication | yes | writer only | Theory Comput. Syst. 45(1):150–161 | re-check |
| milovanov2016algorithmic | yes | writer only; conflict | the steeper notes say "exact title and pages unverified", the bib comment says confirmed | re-check title and pages |
| cover2006elements | yes | writer only | Wiley 2nd ed. 2006 | re-check (low risk) |
| goldreich1989hard | yes | writer only | STOC 1989, 25–32 | re-check (low risk) |
| kushilevitz1993learning | yes | writer only | SIAM J. Comput. 22(6); pages copied from a sibling project | confirm pages |
| wenzel2020good | yes | writer only | ICML 2020, PMLR 119:10248–10259 | re-check |
| hanni2026lesswrong | yes | **unverifiable; violates the binding note** | "undated", "text as pasted", Wyeth as co-author | drop (P2X-05, P2X-06) |
| hanni2026request | yes | **unverifiable; not a source** | private message to the AI system, path to the brief | drop (P2X-07) |
| claudeSFI2026fundamentals | yes | **not yet public** | folder not on main (404) | arXiv id or published URL (P2X-22) |
| claudeSFI2026steeper | no | self-reference | — | — |
| littlestone1988learning | no | verified (WS-P1) | — | not printed |
| barzdin1972prediction | no | fixable (WS-P1) | pages 1224–1228 | not printed |
| gold1967language | no | verified (WS-P1) | — | not printed |
| vovk2005algorithmic | no | verified (WS-P1) | — | not printed |

Totals over the 37 printed entries:
* 19 verified by this reviewer's WebSearch, 7 of them needing a DOI, issue number or series;
* 2 verified as sources, but the entries need rewriting;
* 4 verified by WS-P1;
* 9 rest on writer records only;
* 3 are not usable as printed.

---

## 6. Structure and length against a typical arXiv paper

| | this paper | typical arXiv paper in learning theory / AIT | outline budget |
|---|---|---|---|
| pages | 63 (1 title/abstract, 1 TOC, 30 main, 2.5 references, 22 appendices A–G, 5.5 internal record) | 25–45 including appendices | main 21, appendices ≈ 20 |
| theorem-like environments in the main text | 70 (5 theorems, 20 propositions, 10 lemmas, 3 corollaries, 21 remarks, 9 definitions, 2 examples) | 10–25 | — |
| in the appendices | 3 lemmas | most auxiliary lemmas | — |
| introduction | 3 pages with a full-page table; no informal theorem statement | 2–3 pages with 2–4 informal main results | 1.5 |
| related work | "Prior work" paragraph in the introduction, plus Section 8 (which also proves two propositions) | one section, early or late, without results | — |
| figures | none | 1–3 (e.g. a hull or structure-function plot) | — |
| open questions | a paragraph at the end of five sections plus a collected list | one list | — |

The standard elements are present: abstract, introduction with contributions, preliminaries (Section 2), results, discussion with open problems, references, appendices with proofs. The binding note's order would put related work before the preliminaries. The main text should shrink to about 20–22 pages. The moves are listed in P2X-26; the theorem restructuring in P2X-27. After the moves the main text would contain:
* Theorem 3.2 with Corollary 3.5 and Proposition 3.8;
* a simplified Theorem 4.7 with Table 2(a);
* Propositions 5.1, 5.3, 5.4 and Lemma 5.5;
* Theorems 6.4, 6.6 and 6.8;
* Proposition 7.6.

---

## 7. Readability

### 7.1 Proposed abstract (199 words)

> Solomonoff function induction (SFI) predicts labels from inputs with a universal prior over random partial functions. We analyse a proposal from the author's notes: penalise program length λ > 1 times more than log-loss, over hypotheses that use private randomness for each input, so that the selected hypothesis is a simple model with noise rather than a model of the teacher's errors. A standard objection is that a universal mixture, taken as one hypothesis, then wins. We show that it does in every class containing its own Bayes mixture, including Solomonoff induction and shared-randomness SFI, while no private-randomness hypothesis is universal; the price is a constant factor on latent causes shared by inputs. For a random parity on uniform inputs with errors on a junta-shaped set incompressible relative to the parity and flip rate below 0.056, we prove that for λ = cn, with n the sample size and c in an explicit window, every near-optimal hypothesis of the population objective knows the parity and holds little information about the errors. The window needs λ ∝ n and fails partly for some compressible error rules. At λ = 1 a sampler and programs filling in its random bits get similar posterior; for λ > 1, private randomness selects a sampler, shared randomness a universal mixture.

### 7.2 The first page

The first paragraph is mostly quotation of informal notes (P2X-13). The reader learns the problem ("learn what the teacher means, not what the teacher says") only through four quoted fragments. Suggested opening: "A learner trained on labels from a fallible teacher should ideally learn the teacher's intended concept, not the teacher's mistakes. Bayesian prediction with a universal prior, whether Solomonoff induction or its supervised counterpart SFI, does the opposite: it learns every computable regularity of the labels, the mistakes included. The author has proposed [grokking note] a steeper simplicity prior ..." Then the objective J_λ, and then an informal statement of the three main results as "Theorem 1 (informal)", "Theorem 2 (informal)", "Theorem 3 (informal)".

### 7.3 The central theorem

Theorem 4.7 needs about 40 symbols, five parts and sub-parts (a)–(e) (P2X-27). The table that follows it is what a reader remembers: window (9.54·10⁻⁷, 8.06·10⁻³]; at c = 10⁻⁴, u ≥ 0.983, ℓ ≤ d + 20.4, I ≤ 37.7, e ≤ 0.199. The main text should state a simplified form with B = ∞ and ε = 0 and the constants absorbed into O(log d + κ). The full form, with truncation level B, ε-slack and parts (iii)–(iv), goes to Appendix C.

### 7.4 Voice

The paper should speak as its author (P2X-12):
* "our proposal [grokking note]" or "the proposal of [grokking note]", not "Hänni's proposal";
* "the original sizes", not "Hänni's sizes";
* no "Verdict" column grading the author.

The third person is acceptable only where the earlier report, written by someone else, is discussed.

### 7.5 A figure

One figure would help readers more than several pages of remarks: the (length, risk) plane at the original sizes, with the coin, the good model, the memoriser, the lower hull, and the window of slopes (2^{−m}, c_hi]. The envelope of Proposition 5.3 can be added to show where the trick fails. A second candidate shows the set and product structure functions of the noisy parity, with the kink at α ≈ d (Proposition 7.6).

---

## 8. Numbered issue list

Severity: **fatal** = false or unsupported mathematical claim, or a claim stronger than the sources. **Major** = missing hypothesis, wrong number, inconsistency, misleading framing, an arXiv-standard violation a reader would notice, or a passage a reader cannot follow. **Minor** = local wording or formatting. The same list is in `issues-p2-arxiv.json`.

