# Paper 1: consistency and arXiv-readiness review (second independent pass)

> **Note on files.** This review ran at the same time as another pass with the same brief, which wrote `p1/review-p1-arxiv.md` and `p1/issues-p1-arxiv.json` (ids `P1X-nn`) first. To avoid overwriting it, this pass is saved as `p1/review-p1-arxiv-pass2.md` and `p1/issues-p1-arxiv-pass2.json` (ids `P1-ARX-nn`). Its 14 findings that the other pass lacks, and three bibliography corrections to it, are appended to the canonical files as an addendum. The two passes agree on everything they both cover.

**Paper.** *Solomonoff Function Induction: Definitions, Versions and Basic Theorems* (`paper/main.pdf`, build of 2026-10-12 16:59, 103 pages; sources `paper/sections/*.tex`, `paper/bib/*.bib`).
**Reviewed against.** The binding notes at the top of `paper/OUTLINE.md` (authorship; standard academic paper for arXiv; the absorption objection), `paper/NOTATION.md`, `paper/CLAIMS.md`, the final track notes `research/tracks/*/notes-final.md`, and the request in `research/00-brief.md`.
**Scope.** This review covers consistency and arXiv readiness: whether the framing matches the body, notation, status tags, the conversion plan, the bibliography, structure and readability. Whether the proofs are correct is the subject of the separate mathematical reviews (`review-p1-math-A.md`, `review-p1-math-B.md`).
**Independent checks** (all in `research/paper-review/scratch/p1-arxiv-r2/`):
* `extract_status.py` → `envs.json`, `envs.txt`: all 203 theorem-like environments, each with its label, status and source.
* `compare_status2.py` → `compare_status2.out`: each status compared with `CLAIMS.md` §1, after normalising track abbreviations and check identifiers.
* `process_vocab.py` → `process_vocab.out`: process vocabulary in the visible text (comments, `\status` and `\src` stripped).
* `main.txt`, `main-raw.txt`: `pdftotext` of the PDF, used for every "PDF shows" statement below.
* `numbers_check.py` → `numbers_check.out`: the numbers that the abstract, introduction and discussion repeat from the body.
* `conversion_table.py` → `conversion_table.md`: the per-environment conversion plan in §4.3.
* `bib_log.md`, `bib_table.py` → `bib_table.md`: the result of a WebSearch for every one of the 84 entries in `bib/*.bib`.
* `issues_p1_arxiv.py`: generates the issue list and the JSON file (`issues-p1-arxiv.json` in this folder; copied to `p1/issues-p1-arxiv-pass2.json`).

## Verdict

The paper is **not yet ready for arXiv**. The mathematics in the body is presented carefully, and almost every claim carries its hypotheses and its loss convention. The statuses agree with the ledger. There are three groups of problems:

1. **One framing claim is stronger than the body.** The introduction says twice that the dominance theorem for computable reveal laws "is true"/"holds in its intended reading". For randomised reveal laws it is proved only with an extra $K(n)+K(A)$ term, and whether that term can be removed is open (P1-ARX-01, fatal). Four further framing statements lack a hypothesis or are ambiguous (P1-ARX-02 to -05): the abstract's "reveal orders" sentence; "$\pm O(\log n)$" for Eisenstat's example, which holds in expectation, not pathwise; "SI pays $O(1)$", which needs the self-delimiting code; and the ledger's pathwise claim R5.
2. **The paper still reads as the output of a research process, not as an arXiv paper.** It has status tags and source notes on 187 environments, about 30 visible check identifiers and about 35 "not checked / abstract only" hedges. It also has the H1–H10 verdict table, the 7.5-page verification appendix, and a bibliography entry for "Hänni's request" pointing to `00-brief.md`. With Hänni as sole author it refers to him in the third person 143 times, with theorem titles such as "Hänni's chain" and section titles such as "Hänni's Theorem 1". The LessWrong citation lists Wyeth as co-author, next to the absorption paragraph. Four statements contain proof-sketch parts inside Theorem/Proposition environments, and one "Conjecture" is declared imprecise by the sentence after it. Cross-references to the 13 open questions print section numbers instead.
3. **Length and structure.** At 103 pages and 203 environments the paper is two to three times the length of a typical arXiv paper in this area. The contributions list summarises nearly everything, related work is one heavily hedged page at the end, and the two loss conventions, used throughout the introduction, are defined only at the end of it.

All of these can be fixed without new mathematics, except two content checks, which the author must do before deleting the hedges that now protect them:
* Solomonoff (2008), for the operator-induction formula;
* Hutter (2005), for the identification of $\MH$ with Hutter's universal chronological semimeasure. Alternatively, the text can be reworded so that it no longer depends on this identification.

**Counts.** 49 issues: 1 fatal, 31 major, 17 minor. There are 130 rows in the conversion table (114 environments whose status is not plain "proved", and 16 untagged definitions and remarks). Of the 84 bibliography entries:
* 67 are verified;
* 12 are fixable, with corrected data given;
* 4 are unverifiable or internal (`hanni2026request`, `hanni2026lesswrong`, `vaintrobhanni2026nnbayes`, `claude2026whatfollows`);
* 1 is not applicable (the paper itself).

72 of the 84 entries are cited in Paper 1; the other 12 are in the shared `core.bib` and are dropped by BibTeX.

---

## 1. Abstract, introduction and discussion against the body

I checked every claim of the abstract (one paragraph, 248 words), of the introduction (§1, including the contributions list, "Corrections", "Credit", "What is not achieved" and Table 1) and of the discussion (§12) against the cited body results, with the same scope and hypotheses. Most claims match. The mismatches are below; the issue ids refer to the issue list at the end.

| claim (where) | body result | verdict |
|---|---|---|
| "A universal function machine exists; its law dominates the law of every function machine" (abstract) | `thm:setting:universal` | matches |
| "does not depend, up to a constant factor, on the universal machine or on computable encodings" (abstract) | `thm:setting:invariance`: the factor for an encoding is $2^{K(\alpha,\beta)+O(1)}$ | imprecise: the factor depends on the encoding (P1-ARX-33) |
| "agree up to $K(\dom D)$ bits, but no two of the first three agree up to a constant" (abstract) | `thm:versions:chain` (with $+O(1)$); `thm:versions:nocoding`, `prop:versions:Wgap`, `prop:versions:shared` | matches, apart from the missing $+O(1)$ (P1-ARX-33) |
| pathwise dominance "by at most the labeller's complexity plus a constant" (abstract; intro "Why SFI") | `thm:learn:dominance` | matches |
| "with i.i.d. inputs ... and computable labels, the averaged predictor has risk $O(K/n)$" (abstract; intro) | `thm:learn:batch`(a): $\varphi$ partial computable with $\mu(\dom\varphi)=1$ | matches; $K$ is undefined in the abstract (P1-ARX-33) |
| "SFI cannot model fresh label noise on repeated inputs; a per-query mixture can" (abstract) | `prop:learn:freshnoise`, `prop:learn:perquery` | matches |
| "SFI cannot use the order of the data" (abstract) | `prop:setting:order` (semimeasure convention); `prop:setting:normalise`(b) (normalised losses can depend on the order) | true for the cumulative semimeasure-convention loss only (P1-ARX-33) |
| cyclic permutation: SFI "pays about $(d-\log_2e)2^d$ bits ... while Solomonoff induction ... pays $O(1)$ in expectation" (abstract; intro bullet 5) | `thm:ex:cycle`; `prop:ex:cycsi` (with the code $\bar s=1^{|s|}0s$); `prop:ex:cycraw`, `conj:ex:raw` (raw blocks: $K(d)+c$) | the encoding hypothesis is missing (P1-ARX-04) |
| "Hypotheses that see the list of previous inputs give the universal chronological semimeasure" (abstract) | `thm:hist:representation`, `cor:hist:H4` | matches |
| "A dominance theorem for computable reveal orders holds in its intended reading, though an earlier proof sketch fails" (abstract) | `cor:hist:thm1`(a): extra $K(n)+K(A)$ under (A1), (A2); (b) exact for deterministic orders | ambiguous, and stronger than the body in the reading the context suggests (P1-ARX-02) |
| "Hänni's dominance theorem for computable reveal laws is true in the reading his text supports, under finiteness hypotheses" (intro bullet 4); "the theorem holds in its intended reading" (intro "Corrections") | as above; `rem:hist:thm1open`(i) lists the removal of $K(n)+K(A)$ as open | **stronger than the body** (P1-ARX-01, fatal) |
| "its exact relation to SI on the interleaved sequence" (intro bullet 4) | `thm:hist:si`, `prop:hist:inputloss` hold up to constants; `q:hist:open`(iv) | overstated (P1-ARX-32) |
| normalised cyclic bound "at least $\delta d-O(\log d)$ bits per step in expectation for the first $2^{(1-\delta)d}$ steps" (intro bullet 5) | `prop:ex:normalised`: $\Ex\bar\ell_t\ge\log(N-t+1)-K(t-1)-c$ | matches (checked: $K(t-1)\le(1-\delta)d+O(\log d)$) |
| Eisenstat: "SFI pays $\frac{H(1/3)}2n\pm O(\log n)$ bits ... optimal among order-independent predictors up to $O(\log n)$, while SI pays at most 2.4 bits plus a constant in expectation" (intro bullet 5) | `thm:ex:expected` (expectation), `thm:ex:sandwich` (pathwise, relative to $UB_n$), `prop:ex:asymp` ($\sqrt n$ fluctuations of $UB_n$), `prop:ex:law`, `thm:ex:eisensi` ($3\vartheta=2.39855$) | "in expectation" is missing for SFI (P1-ARX-03); $2.4\ge3\vartheta$ checked |
| OOD bullet: "with no logarithmic term and independently of the amount of data"; "machine-dependent"; "total posterior error ... at most $(\ln2)(K(f)+c)$" | `prop:ood:hanni`, `prop:ood:machine`, `thm:ood:cumulative` | matches |
| "Time-bounded mixtures have constant regret against all predictors of a given running time" (intro bullet 7) | `thm:comp:timebounded`(a) (distinct inputs), `prop:comp:round` (every stream; regret proved, running time sketched) | matches, because `prop:comp:round` covers all streams |
| circuit Bayes "polynomially related on every ordering"; Occam "$2^{\Omega(\ell/\log\ell)}$ mistakes ... for a target of description length $\ell$" (intro bullet 7) | `thm:comp:circuitbayes`; `thm:comp:ladder` (one target family) | the second needs "for the conjunction" (P1-ARX-34) |
| networks: "general facts about the induced prior and a separation between Gaussian-process limits and SFI on parities" | `prop:nn:*`, `cor:nn:separation` (squared error, averaged), `rem:nn:oddparity` | matches; the paraphrase in `rem:nn:rigorous` is stronger (P1-ARX-38) |
| Table 1 rows H1–H10 | each row checked against the cited results | correct except that the H6 row ("confirmed up to $O(\log n)$", citing the pathwise sandwich) has the same pathwise problem; the table is to be deleted anyway (P1-ARX-10) |
| Discussion ¶1–¶4 (ideal learning; what the hypotheses may see; which version; computable versions) | `thm:learn:dominance`, `thm:learn:merging`, `thm:learn:batch`, `thm:ood:cumulative`, `prop:hist:orderfree`, `prop:ex:orderfree`, `prop:ex:law`, `cor:hist:H4`, `prop:hist:strict`, `prop:ex:cycset`, `thm:hist:si`, `prop:hist:inputloss`, `cor:versions:twopoint`, `prop:versions:tape`, `rem:versions:prediction`, `prop:comp:round`, `cor:comp:poly`, `thm:comp:circuitbayes`, `thm:comp:ladder`, `prop:nn:nolower` | match ("computable random function" in ¶1 means total, as in `thm:hist:bayes`) |
| Discussion "Relation to the literature" (operator induction = $\Mpq$; Hutter) | `rem:versions:operator` and `cor:hist:H4` are known; unverified | hedged now; must not lose the hedge without verification (P1-ARX-15, -16) |
| Discussion "Open problems" | each item matches its `q:` paragraph or conjecture | matches; the cross-references print section numbers (P1-ARX-20) |
| Steeper summary (§10) and Discussion ¶7 | numbers checked for presence in `paper-steeper/CLAIMS.md`: 9.54e-7, 8.06e-3, 3.66e-3, 0.983, 37.7, 0.199, 11,710, 1.6e-5, 31%, 25%, 0.056, $\min(\lambda,2)$ | consistent with the Paper 2 ledger (detailed checks are Paper 2's review) |

The headline numbers that the framing repeats were checked independently (`numbers_check.out`): $H(1/3)/2=0.4591479$, $\sigma^2=1.0496602$, $\log3-\frac13=1.2516$, $\vartheta=0.7995167$, $3\vartheta=2.39855$, and the $\log((N-1)!)$ table for $d=4,8,12$. All agree. One rounding slip is in the body: $r_0=0.9125$ is printed as $0.912$ (P1-ARX-36).

**Ledger.** `CLAIMS.md` §3 R5 says SFI's loss in Eisenstat's example is $\frac{H(1/3)}2n\pm O(\log n)$ "pathwise a.s. and in expectation". Pathwise this is false: `prop:ex:asymp` gives fluctuations of order $\sqrt n$. The intro sentence was evidently written from this entry (P1-ARX-05).

## 2. Notation and definitions before use

* **Agreement with `NOTATION.md`.** I checked the macros and renamings of `NOTATION.md` §4: no bare $\kappa$, $\lambda$ only for the steepness exponent, $\Unif$ for the tape measure, $j$ for confidence exponents, GF$(2^q)$, $\Kpad$, $\Ktail$, $\MH$, $\vartheta$. The paper follows them. One discrepancy runs the other way: `NOTATION.md` still writes the shared-coin law as $\omega_{|x|}$, while the paper correctly uses $\omega_{|x|+1}$ (P1-ARX-44; Paper 2 must follow the paper).
* **Forward references.** §2 uses $W$, $\KF$, $\Mprod$, $\Mpq$ and $\Mw$ before §3 defines them, in `thm:setting:coding`(b), `thm:setting:invariance`(c) and `rem:setting:recommend` (P1-ARX-35).
* **Terms used in the introduction before they are explained.** "Semimeasure convention" and "normalised convention" are defined only in the Reader's guide at the end of the introduction (P1-ARX-29). The terms "padded complexity", "reveal law", "machine law" and "Gaussian-process limits" are never explained there; one clause each would do.
* **Undefined symbols in the abstract.** $K(\dom D)$, $d$, and $K$ in $O(K/n)$ (P1-ARX-31, -33).
* **Statements that rely on the appendix.** Some main-text results lean on statements that appear only in the appendix: `lem:setting:total`, `prop:setting:normtotal`, `cor:setting:normuniversal`, `prop:hist:variants`, `lem:hist:memory`, `prop:hist:operator`. This is acceptable for an arXiv paper, provided each main-text use explains the object in words. Currently, `def:hist:sfihist` refers to `lem:hist:chronolaw` (appendix) for the fact that $M^{\rm hist}_T$ is a chronological semimeasure; one sentence of justification in the main text would help.
* **Local notation is consistent.** I checked $\tau_n$, $\eta_n$, $g_n$, $UB_n$, $\sep_k$, $D^*_y$, $\mathcal T$, $\Gamma$ and $\mathcal E$ section by section.

## 3. Statuses against `CLAIMS.md`

`compare_status2.py` compares all 203 environments with the ledger's status column, after normalising "F/Hi/Ex/Co/St" to track names and removing check-identifier parentheses. Results:
* every ledger row has an environment in the paper, and every labelled environment has a ledger row;
* there are no substantive mismatches;
* 10 cosmetic differences remain. For example, `prop:ex:cycsi` has "computed" where the ledger says "illustrated", and `prop:learn:freshnoise` says "the brief's fresh-noise claim" where the ledger says "H7".

Two points matter for the conversion:
* 16 environments carry status information that is mathematical, not decorative: proof sketch, conjecture, conditional, refuted, open, known/unverified. Their wording must change, not just their tags (§4.3).
* Four statements state proof-sketch parts as if proved, and only the tag reveals this: `thm:hist:minimax`(b) for reveal laws that see $f$, `thm:comp:timebounded`(b), and the running-time sentences of `prop:comp:round` and `prop:comp:history` (P1-ARX-18).

## 4. Plan for the arXiv conversion

### 4.1 Global steps, in order

1. **Re-source the request and the LessWrong thread.** Delete `hanni2026request` and `hanni2026lesswrong` from the citations and re-source each use (P1-ARX-06, -24):
   * the author's ideas: first person, or [Hän26] (the notes);
   * Eisenstat's example: "S. Eisenstat, personal communication";
   * the e-mail heuristic: "the author, in correspondence with S. Eisenstat";
   * the absorption point: at most one neutral footnote naming the thread, with no author "Wyeth".
2. **Self-reference.** Replace third-person self-reference and self-eponymous titles by neutral titles and "[Hän26]", and state the arrangement once in the introduction (P1-ARX-07, -08, -09).
3. **Delete the verdict table.** Delete Table 1 (H1–H10) and every "H$k$" in the text (P1-ARX-10).
4. **Apply the conversion table (§4.3).** Each of the 130 rows says what the environment becomes. The 16 rows that need real rewording are marked by their status: sketch, conjecture, conditional, refuted, open, known/unverified, remark with process content.
5. **Remove the internal apparatus from the visible text.** Remove the check identifiers (P1-ARX-13) and the process hedges (P1-ARX-14). Do the two content checks first (P1-ARX-15, -16) and rewrite `rem:related:new` (P1-ARX-17).
6. **Open problems.** Number them as environments, and make §12 the single home for them (P1-ARX-20).
7. **Delete the tags.** Delete every `\status{...}` and `\src{...}` from the sources, including the inline ones in prose and tables, then delete both macros from `preamble.tex`. Redefining them as no-ops is not enough, because the `.tex` files sent to arXiv would still contain "foundations Thm 6.1; F20–F23" (P1-ARX-12).
8. **Remove the verification appendix.** Remove `\input{sections/app-verification}` and move what is worth keeping (§4.4).
9. **Rewrite the closing statements.** Rewrite the acknowledgements and the "Code and data" statement (P1-ARX-26, -27).
10. **Bibliography.** Apply the corrections of §5.
11. **Clean the shipped sources.** Delete the `%` comments that contain process vocabulary. arXiv distributes the `.tex` sources, so comments such as "% Sources: research/tracks/..." and "% framing editor" are public. Simplest: strip all comments when preparing the arXiv tarball (P1-ARX-49).
12. **Final check.** Grep the `.tex` and the PDF text for `track|referee|ledger|notes-final|brief|orchestrat|unverified|snippet|not checked|abstract seen|H[0-9]|\b[cres][0-9]+\b|Wyeth|request|verdict|working hypothes`, and expect no hit outside the acknowledgements.

### 4.2 Every place with process vocabulary in the visible text (outside Appendix I)

Line numbers are those of the source files. The source of this table is `scratch/p1-arxiv-r2/process_vocab.out`, curated by hand.

| file:line | visible text | fix |
|---|---|---|
| intro.tex:9 | "we have not checked the identification against Hutter's texts" | delete; P1-ARX-16 wording |
| intro.tex:26 | "the PDF draft"; "which the draft hoped"; "Table 1 lists the ten working hypotheses with which this study began" | cite [Hän26]; delete the last sentence |
| intro.tex:28–53 | Table 1 "The working hypotheses H1–H10 ... with verdicts" | delete |
| intro.tex:55 | "\citet{hanni2026request}"; "as reported in \citet{hanni2026request}"; "we have checked them only at the level of abstracts and tables of contents" | re-source; delete the hedge |
| intro.tex:57 | "The main theorems of the slides are not checked here"; "Much of the literature was seen only through abstracts and secondary sources" | "We do not use the main theorems of [VH26]"; delete the second sentence |
| intro.tex:59 | "answers the question of the Kolmogorov and semimeasure versions" | "compares ..." |
| setting.tex:4 | "the claims checked below are Hänni's" | "the notion is from [Hän26]" |
| setting.tex:12 | "We use, without re-checking the sources" | "We use the following standard facts" |
| setting.tex:40 | "\status{known; unverified}; we have not checked the analogy against these sources" | "cf. [Cho54, Mat75, Sha76]" |
| setting.tex:44, 119, 156 | "(c1)", "(c3)", "(context c3)", "(c9(c))" | "a direct computation ..." or delete |
| setting.tex:175 | "(not checked against the source)" | delete |
| versions.tex:4 | "He later asked that the paper 'include an equivalence ...'" | "A natural question is whether ..." |
| versions.tex:21 | "(abstract only seen)", "(search snippet only)" | P1-ARX-15 |
| versions.tex:123 | caption "(Hänni's later request)", "Source: foundations Table 4.12." | P1-ARX-23 |
| versions.tex:137, 144 | "Answer to Hänni's request", "which Hänni's draft names as the tool" | "Summary: the versions are not equivalent"; "[Hän26]" |
| learn.tex:7 | "Hänni describes SFI as 'just ideal supervised learning' [request]" | "SFI is a candidate for ideal supervised learning" |
| learn.tex:49 | "(source not checked)"; "foundations r6" | delete; "a direct computation" |
| learn.tex:77 | "(not checked)" | delete |
| learn.tex:87 | "(foundations c5)"; "This refutes the fresh-noise form of the supervised-learning hypothesis H7 ... (Table 1)" | "a direct computation"; delete the sentence |
| learn.tex:108, 112 | "(foundations r12)" | "code in the accompanying repository" |
| learn.tex:171 | "A table-of-contents snippet shows ... We have not read these sections" | conversion-table row `rem:learn:hutterEX` |
| hist.tex:12 | "his request conjectures", "(``Thm 1'')" | first person / [Hän26] |
| hist.tex:28, 62 | verbatim informal quotes; "Hänni's Thm 1" | paraphrase (P1-ARX-09) |
| hist.tex:117 | "Hänni's request: '...'" | "The author conjectured that ..." |
| hist.tex:127 | "(abstract seen only); we have not checked whether ... and claim no novelty for it" | conversion-table row `thm:hist:representation` |
| hist.tex:135 | "is known, but not checked against the sources" | P1-ARX-16 |
| hist.tex:157 | "(abstract seen only)" | delete (LHG11 is verified) |
| hist.tex:165 | remark title "Verdict on Hänni's conjecture" | "Summary: SFI with the list of previous inputs" |
| examples.tex:7, 35, 112 | "\citet{hanni2026request} proposed ...", "H\"anni's e-mail claims" | re-source (P1-ARX-06) |
| ood.tex:7, 51, 53, 65 | "His draft adds ...", "The draft's two-sided result", "the draft's bounds as stated are false" | P1-ARX-08 |
| comp.tex:54 | "Hänni's 'Remark 4'" | P1-ARX-39 |
| comp.tex:128 | "the other claims are the slides' and we have not checked them" | "[VH26] state further bounds, which we do not prove" |
| nn.tex:8 | "\citep{hanni2026request}" | [Hän26] or first person |
| nn.tex:62 | "(as summarised in its abstract and in the slides)" | "see [YS19]" |
| nn.tex:73 | "(on the sphere, as stated in their abstract)" | "(on the sphere)" |
| nn.tex:81 | "We re-checked ... the rest is unchecked" | conversion-table row `rem:nn:slides` |
| nn.tex:91 | "These descriptions follow the abstracts." | delete |
| steeper.tex:6 | "\citep{hanni2026notes,hanni2026lesswrong}" → "Hänni and Wyeth, undated" | P1-ARX-24 |
| steeper.tex:14 | "H\"anni also asked for ... [request]" | "The author also proposed ... [Hän26]" |
| related.tex:6, 8, 10, 12 | "(we have seen only the abstract)", "was not checked against his texts", "we have not checked", "we have not examined" | verify or delete (P1-ARX-14) |
| related.tex:16–19 | `rem:related:new` "At the level of a search that saw abstracts and secondary sources only ... should be checked ... before any claim of novelty" | P1-ARX-17 |
| discussion.tex:13 | "(we have not checked the identification against his texts)"; "Our literature search reached abstracts and secondary sources only" | P1-ARX-16; delete |
| discussion.tex:31 | "five groups", "Each group's notes", "adversarial referee", "web-search tool ... most cited works were not read in full" | P1-ARX-26 |
| discussion.tex:34 | "research/tracks/*/checks/", "research/tracks/*/referee\_code/" | P1-ARX-27 |
| app-setting.tex:81 | "(not checked against the source)" | delete |
| app-setting.tex:115, 117, 125, 151, 154, 166 | "check c6", "(c1 checks ...; r1 also k=3)", "(c9(b))", "(c9(b) for $k\le4$; r1)", "(c10(a4))", "Check c10 ... (r13: 300 of 300)", "(c10(b) checks ...)" | "a direct computation (code in the accompanying repository)" |
| app-setting.tex:132–134 | heading "Reformulation (proof sketch; foundations Problem 3.6)."; "(quoted, not checked against the source)"; "was tried and settled neither direction" | P1-ARX-22 |
| app-versions.tex:35, 60, 86, 99, 102 | "(c8(a))", "(c2 checks ...)", "(c8(a) checks ...)", "(c8(d))", "Check c8(c)", "(c8(b), $N\le14$)", "(r11)" | as above |
| app-versions.tex:55 | title "The hashing bound, superseded" | P1-ARX-40 |
| app-versions.tex:92, 102 | "\status{known; unverified}; we have not checked its statement", "(statements not checked)", "we did not check optimality against the source, and the checks confirm it only for ..." | "[Lev16, EL11]"; "(we use only the construction of [KS73], not its optimality)" |
| app-learn.tex:106, 129, 133 | "(content not checked)", "(foundations §6.6; the cited works were not checked against their sources)", "their exact model was not checked" | delete |
| app-learn.tex:119 | "An earlier version of the context notes read ..." | P1-ARX-21 |
| app-learn.tex:141 | "Foundations: c4 ... r6 ... c5 ... Context: c3 ... c4 ... c7" | describe the computations without identifiers |
| app-examples.tex:133, 164 | in-table "[computed] examples §2.6; checks e3, e6", "check e2, seed 20261011" | P1-ARX-45 |
| app-examples.tex:140 | "H\"anni's e-mail argument, as quoted in his request" | "The heuristic argument (the author, in correspondence with S. Eisenstat) reads:" |
| app-examples.tex:237 | script names `e1_eisenstat_exact` ... and "Separately written implementations agree" | acceptable as a code pointer; replace the last sentence by "Independent implementations agree on ..." |
| PDF bibliography | "Personal communication to the author ... research/00-brief.md"; "Hänni and Wyeth ... undated. Text as pasted by K. Hänni"; "Kaarel Hänni. notes." | §5 |
| all theorem-like environments | printed `[status]` and grey source notes | §4.1 step 7 |

### 4.3 Every theorem-like environment whose status is not plain "proved"

The table has 130 rows: 114 environments with a status other than plain "proved", and the 16 untagged definitions and remarks (only their `\src` goes). The column "arXiv form" gives the academic wording; "unchanged" means the statement stays and only the tag and any nearby check identifier go.

The rows that change the mathematics' presentation are these:
* **Splits** (the proof-sketch parts must leave the theorem): `thm:hist:minimax`, `thm:comp:timebounded`, `prop:comp:round`, `prop:comp:history`.
* **Out of the Conjecture environment:** `conj:ood:natural`.
* **Statements to rephrase as conditional or as a reading:** `rem:versions:operator`, `prop:hist:operator`, `cor:hist:H4` (the surrounding text), `prop:hist:lhg`, `rem:ex:where`.
* **Refuted earlier claims**, kept only in informative form: `rem:setting:h1a`, `prop:learn:freshnoise`(c), `prop:ood:draftfalse`, `rem:ood:lopsided`, `rem:comp:distinct`, `prop:hist:info`(b), `rem:learn:cesaro`.
* **Into the Open Problems list:** `rem:hist:thm1open`.
* **Into related work or replaced:** `rem:related:new`, `rem:nn:literature`, `rem:learn:hutterEX`, `rem:nn:slides`.

{{CONVERSION_TABLE}}

### 4.4 The verification appendix (Appendix I): drop it, and move what is worth keeping

| part of App. I | destination |
|---|---|
| I.1 Roles (tracks, referees, revisions, editors) | Not in the paper. A single sentence goes in the acknowledgements ("checked by further, independent instances of the system, which re-derived the proofs and re-implemented the computations"); the binding footnote already says "checked by independent AI referees". |
| I.1 Scripts table and environment (Python 3.11.15, numpy 2.4.6, scipy 1.17.1, mpmath 1.3.0) | The environment goes in "Code and data" (P1-ARX-27); the per-track table goes in the repository README. |
| I.2 Corrections (Table 9, about 70 rows with referee item numbers) | Delete. The corrections that inform the reader are already stated where they occur, for example `prop:ood:draftfalse`, `prop:hist:sketchfails`, `prop:learn:freshnoise`(c) and `rem:comp:majority`. |
| I.3 Cross-track conflicts C1–C25 | Delete. |
| I.4 What is not fully established (conjectures, proof sketches and conditional results, open problems, "results checked by their authors only", the slides) | Into the statements (conversion table) and the Open Problems list of §12. Delete "checked by their authors only" (process). For the slides, use the sentence in row `rem:nn:slides`. |
| I.5 Literature ("No cited source could be opened ...") | Delete, once the references are verified (§5). |
| I.6 Reproduction (shell loop, `git status`) | The repository README. |
| I.7 Unresolved points | Resolved by this plan: length (§6), conversion (§4), status vocabulary (§4.3), open-question labels (P1-ARX-20), notation (P1-ARX-44), shared `core.bib` (P1-ARX-43). |

Afterwards the paper has, as the binding note requires:
* the title-page footnote (already in the binding wording);
* one acknowledgements paragraph on how the paper was prepared and checked;
* a "Code and data" statement.

## 5. Bibliography: all 84 entries of `bib/*.bib`

**Method.** One or more WebSearch queries per entry, and WebFetch where it resolved (github.com resolved; arxiv.org, lesswrong.com, dblp.org, mlanthology.org and kaarelh.github.io did not). The search results are in `scratch/p1-arxiv-r2/bib_log.md`. "Verified" means that a search result confirms the authors, title, venue, year and the volume and pages given in the entry. "Fixable" means the entry is verified but incomplete or partly wrong, and the corrected data are given. "Unverifiable" means no independent record was found or the entry is internal. "Cited in P1" is taken from `main.bbl`.

**Results.** Verified: 67. Fixable: 12 (`day2011increasing`, `orseau2013universal`, `wood2013non`, `vovk1990aggregating`, `barzdin1972prediction`, `case1983comparison`, `hoeffding1963probability`, `grunwald2007suboptimal`, `kleitman1973families`, `ville1939etude`, `hanni2026notes`, and the companion entry `claudeSFI2026steeper`). Unverifiable or internal: 4 (`hanni2026request` must be dropped; `hanni2026lesswrong` must be changed or dropped; `vaintrobhanni2026nnbayes` must be confirmed by the author; `claude2026whatfollows` is uncited here). Not applicable: 1 (`claudeSFI2026fundamentals`, the paper itself).

Two verified entries, `ozkural2015ultimate` and `ozkural2017ultimate`, are cited for content that no search confirmed: the operator-induction formula. They should be replaced by the primary source (P1-ARX-15, -42).

{{BIB_TABLE}}

**Corrected entries, ready to paste:**

```bibtex
@article{day2011increasing, author={Day, Adam R.}, title={Increasing the Gap between Descriptional Complexity and Algorithmic Probability}, journal={Transactions of the American Mathematical Society}, volume={363}, number={10}, pages={5577--5604}, year={2011}}
@inproceedings{orseau2013universal, ..., series={Lecture Notes in Computer Science}, volume={8139}, pages={158--172}, ...}
@inproceedings{wood2013non, ..., editor={Dowe, David L.}, series={Lecture Notes in Computer Science}, volume={7070}, pages={417--425}, ...}
@inproceedings{vovk1990aggregating, ..., pages={371--383}, ...}            % one citing list gives 371--386
@article{barzdin1972prediction, ..., volume={13}, pages={1224--1228}, year={1972}}
@article{case1983comparison, ..., volume={25}, number={2}, pages={193--220}, ...}
@article{hoeffding1963probability, ..., volume={58}, number={301}, pages={13--30}, ...}
@article{grunwald2007suboptimal, ..., volume={66}, number={2--3}, pages={119--149}, doi={10.1007/s10994-007-0716-7}}
@misc{hanni2026notes, author={H{\"a}nni, Kaarel}, title={Solomonoff Function Induction}, howpublished={Note in the repository \url{https://github.com/kaarelh/notes}, folder \texttt{ai/learning/solomonoff induction}}, year={2026}}
```

## 6. Structure and length against a typical arXiv paper in learning theory / AIT

**Current layout.**
* Page counts from `main.toc`: Introduction 4.5; §2 Setting 5; §3 Versions 5; §4 Learning 5; §5 History 6; §6 Examples 6; §7 OOD 5; §8 Computable 4.5; §9 NN 4; §10 Companion summary 2; §11 Related 1; §12 Discussion and acknowledgements 2.5; references 5; appendices A 7, B 4, C 6, D 8, E 7, F 2, G 4, H 1, I 7.5.
* In total 50 pages of main text and 46 of appendices, with 203 theorem-like environments.

**Typical arXiv papers in this area.** Typical papers in this area run to about 20–40 main pages and 40–70 pages in total. Examples are the ALT/COLT-length papers on universal prediction that the paper cites (Lattimore–Hutter–Gavane, Leike–Hutter) and the long journal versions in IEEE TIT/TCS. They state 10–30 results, with a short contributions list and a related-work section after the introduction. A "fundamentals" paper may be longer, but 103 pages with 203 environments will deter readers and referees.

**What to keep.** The mathematical core is good and coherent: §2, §3, §4, §5, §6, and §7 in part.

**What to cut or move:**
1. **Remove process material:** App. I (−7.5 pp), Table 1 (−1 p), and the "Corrections" paragraph shortened to 3 sentences.
2. **§10, the companion summary:** keep one paragraph (−1.5 pp). It repeats Paper 2's numbers (the window endpoints, 37.7 of 11,710 bits and so on), which belong to Paper 2.
3. **§8 and §9, computable versions and NN Bayes** (8.5 pp main + 5 pp appendix). Either move them to a short third paper, or keep a 3-page section with the four headline results (`thm:comp:timebounded`(a), `prop:comp:round`, `thm:comp:circuitbayes`, `thm:comp:ladder`, plus `prop:nn:functionspace`, `prop:nn:nolower`, `cor:nn:separation`) and move the rest to the appendix.
4. **Secondary remarks:** move to the appendices or delete:
   * `rem:versions:prediction` and `rem:versions:answer` (merge), `rem:versions:hashing`, `rem:versions:randomness`;
   * `rem:learn:ideal` (dedupe), `rem:learn:hutterEX`, `rem:learn:positive`, `rem:learn:interventions`, `rem:learn:relations`, `rem:learn:increasing`, `rem:learn:cesaro`;
   * `rem:hist:H4verdict`, `rem:hist:exploit`;
   * `rem:ood:answer` (into the Discussion), `rem:ood:lopsided`, `tab:ood:hanni`;
   * `rem:comp:apples`, `rem:comp:gap`, `rem:comp:selection`, `rem:comp:uniformties`;
   * `rem:nn:bridge`, `rem:nn:rigorous`, `rem:nn:literature` (into §11).
5. **Related work:** move to §2 (after the introduction) and merge in discussion.tex:13, `rem:nn:literature` and `rem:learn:hutterEX`. Add primary SI references (Solomonoff 1964) and a sentence on how inductive inference in the limit differs from Bayesian prediction (P1-ARX-30).
6. **Contributions list:** 5–6 bullets of 2–3 lines naming the main theorems (P1-ARX-29).
7. **Preliminaries:** §2 serves as the preliminaries. Its standard facts (coding theorem, $\mm$) could be one short "Preliminaries" subsection, with the conventions moved before the contributions.

**Targets.** About 35–40 pages of main text and 25–30 pages of appendices, with roughly 120 environments. If the author prefers to keep everything, a two-part split (fundamentals and learning, §2–§4 and §7; history and examples, §5–§6) would also fit arXiv norms better than one 103-page paper.

## 7. Readability

* **Page 1.** The title, a dense abstract and a table of contents; the introduction starts on page 3. The abstract has no motivation sentence, uses undefined symbols, and refers to "an earlier proof sketch" the reader cannot place (P1-ARX-31).
* **Story.** The introduction's first paragraph and "Why SFI" give a good motivation (SFI as the ideal of supervised learning, as SI is for sequences), and "Relation to SI" states the key structural point (SFI sees the data as a set). This story is then buried under eight dense bullets, a one-page verdict table and three process paragraphs. A reader who stops after page 3 should know:
  1. the definition in one sentence;
  2. the three positive theorems;
  3. that SFI is order-blind, with the cyclic permutation as the vivid example, and that $\SFIhist$ fixes this;
  4. that the Kolmogorov and mixture versions differ (no coding theorem for function programs).
* **Examples.** The positive examples (§6.4: parity, thresholds, sorting, polynomials) are a good entry point but come on page 33. One worked toy example of the posterior in §2 or §4 (for instance, sparse parity) would help, as would a figure of the cyclic permutation's chain.
* **Definitions before use.** See §2: the conventions are used before they are defined, §2 refers forward to §3's variants, and the abstract has undefined symbols.
* **Self-reference and register.** The third-person "Hänni" (143 times), self-eponymous titles, verbatim informal quotes and the "request" are the most visible obstacles for a reader (P1-ARX-06 to -09).
* **Cross-references to open questions** print section numbers (P1-ARX-20).
* **Redundancy.** The same limits of the analogy are listed in the intro "Why SFI", in `rem:learn:ideal` and in Discussion ¶1. Versions are summarised three times (the table, `rem:versions:prediction`, `rem:versions:answer`). Section 11 and Discussion ¶5 overlap (P1-ARX-30, -46, -47).

## Numbered issue list

1 fatal, 31 major, 17 minor. The same list, with identical ids and fields, is in `issues-p1-arxiv-pass2.json`.

{{ISSUES}}
