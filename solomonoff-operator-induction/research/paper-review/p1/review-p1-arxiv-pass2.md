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

| # | label | env | file:line | current status | arXiv form |
|---|---|---|---|---|---|
| 1 | `def:setting:data` | Definition | setting.tex:8 | (none) | No tag (definition/remark); delete \src only. |
| 2 | `def:setting:weak` | Definition | setting.tex:18 | (none) | No tag (definition/remark); delete \src only. |
| 3 | `def:setting:rpf` | Definition | setting.tex:28 | (none) | No tag (definition/remark); delete \src only. |
| 4 | `ex:setting:weaknotrpf` | Example | setting.tex:42 | proved; computed | Example, unchanged; replace "($\nutri$ is weak (c1))" by "($\nutri$ is weak, by a direct check of the 18 inequalities)". |
| 5 | `def:setting:machine` | Definition | setting.tex:49 | (none) | No tag (definition/remark); delete \src only. |
| 6 | `rem:setting:perinput` | Remark | setting.tex:77 | (none) | No tag (definition/remark); delete \src only. |
| 7 | `thm:setting:weakuniversal` | Theorem | setting.tex:83 | proved; trimming computed | Keep as Theorem; delete the tag; replace every check identifier nearby by "a direct computation (code in the accompanying repository) confirms ...". |
| 8 | `thm:setting:weakvsmachine` | Theorem | setting.tex:87 | proved; computed | Theorem, unchanged; delete "(c1)" etc. in `ex:setting:weaknotrpf` and the proof (replace every check identifier nearby by "a direct computation (code in the accompanying repository) confirms ..."). |
| 9 | `rem:setting:h1a` | Remark | setting.tex:95 | refuted (weak definition); open (random-function laws) | Remark [Weak and machine universality differ]: "By analogy with sequences [ZL70] one might expect lsc function semimeasures to coincide, up to constant factors, with laws of function machines. For weak semimeasures this fails: by Theorem 2.13 (`thm:setting:weakvsmachine`), $\Mw$ and $\MF$ agree up to $2^{K(\dom D)+O(1)}$ but not up to a constant. For laws of random partial functions the question is open (the numbered Open Problem in Section 12)." |
| 10 | `def:setting:sfi` | Definition | setting.tex:103 | (none) | No tag (definition/remark); delete \src only. |
| 11 | `prop:setting:order` | Proposition | setting.tex:109 | proved; computed | Keep as Proposition; delete the tag; replace every check identifier nearby by "a direct computation (code in the accompanying repository) confirms ...". |
| 12 | `prop:setting:normalise` | Proposition | setting.tex:115 | proved; computed | Proposition, unchanged; following paragraph: "A direct computation (code in the accompanying repository) on a random mixture over six inputs gives semimeasure loss 10.919980315195 bits in all 720 orders and normalised loss between 7.33 and 10.64 bits." (drop "(c3)", "(context c3)"). |
| 13 | `rem:setting:conventions` | Remark | setting.tex:125 | proved (as a list); transfer open where stated | Remark [Lower bounds and the two conventions]; delete tag; in the first list add "(whether these hold normalised is open; see the numbered Open Problem in Section 12)". |
| 14 | `rem:setting:recommend` | Remark | setting.tex:134 | (none) | No tag (definition/remark); delete \src only. |
| 15 | `ex:setting:swap` | Example | setting.tex:155 | proved; computed | Example, unchanged; delete "(c9(c))". |
| 16 | `def:versions:variants` | Definition | versions.tex:8 | (none) | No tag (definition/remark); delete \src only. |
| 17 | `rem:versions:operator` | Remark | versions.tex:20 | known; unverified; equality on distinct inputs proved | DO NOT merely delete the hedges (that would assert an unverified identification). Either (preferred) check Solomonoff [Sol08, \S on operator induction] and write "Solomonoff's third kind of induction [Sol08] predicts the second element of a new pair from the first, given an unordered set of pairs; its predictor is the mixture $\sum_ja_j\prod_iO^j(A_i\mid Q_i)$ over all pairs, repeats included [Sol08]. This is $\Mpq$ ..."; or, if [Sol08] is not checked, write "We read operator induction [Sol08] as the per-query mixture $\Mpq$; under this reading it equals $\Mprod$ on distinct inputs and differs with repeats (Proposition 4.7, `prop:learn:perquery`)." and drop the Özkural snippet citation. |
| 18 | `rem:versions:randomness` | Remark | versions.tex:24 | (none) | No tag (definition/remark); delete \src only. |
| 19 | `prop:versions:tape` | Proposition | versions.tex:48 | proved; finite analogue computed | Proposition, unchanged. |
| 20 | `prop:versions:shared` | Proposition | versions.tex:60 | proved; counting step computed | Proposition, unchanged (the counting step is proved in Appendix B.4; mention the computation only as a sanity check, without the identifier r9(c)). |
| 21 | `thm:versions:nocoding` | Theorem | versions.tex:74 | proved; arithmetic and covering numbers computed | Theorem, unchanged; in App. B.5 replace "(c8(a) checks the arithmetic ...)" by "(the inequality $3^{2^g}<2^d$ is elementary; a direct computation confirms it for $d\le2\cdot10^5$)" or delete. |
| 22 | `prop:versions:covering` | Proposition | versions.tex:88 | proved; computed | Proposition, unchanged; App. B.5: replace "(c8(d))", "Check c8(c) computes ...", "(c8(b), $N\le14$)", "(r11)" by "a direct computation (code in the accompanying repository)"; replace "reported to be optimal \status{known; unverified}; we did not check optimality ..." by "[KS73] (we use only the construction, not its optimality)". |
| 23 | `rem:learn:h2` | Remark | learn.tex:30 | proved; open part | Remark [Scope of Theorem 4.1 (`thm:learn:dominance`)]; (iii) "is open" -> "is open (the numbered Open Problem in Section 12)". |
| 24 | `thm:learn:merging` | Theorem | learn.tex:40 | proved; finite analogue computed (foundations c4, r6; integrability inequality c11(c)) | Theorem, unchanged. Text after it: "This is the function analogue of Solomonoff's convergence theorem [Sol78]." (delete "(source not checked)"); "(summed KL 12.5 bits against a bound of 1 in a finite example; code in the accompanying repository)" (delete "foundations r6"). |
| 25 | `cor:learn:mistakes` | Corollary | learn.tex:51 | proved; known (Littlestone 1988; Barzdin--Freivalds 1972, content unverified) | Corollary, unchanged; the attribution sentence "This is the halving bound [Lit88, BF72] with $K(\varphi)$ in place of $\log\|H\|$" stays (both references verified). |
| 26 | `thm:learn:batch` | Theorem | learn.tex:65 | proved; finite analogues computed (foundations r9; c7, r7) | Theorem, unchanged; "[HLW94] use a permutation argument of this kind" (delete "(not checked)"). |
| 27 | `prop:learn:freshnoise` | Proposition | learn.tex:79 | proved; refuted (the brief's fresh-noise claim, as stated); computed (foundations c5, r9(b)) | Proposition, unchanged; (c) already has the standard form "the natural statement ... is false". Delete the sentences "(foundations c5)" -> "(a direct computation)" and "This refutes the fresh-noise form of the supervised-learning hypothesis H7 ..." (delete entirely). |
| 28 | `prop:learn:perquery` | Proposition | learn.tex:89 | proved; computed (foundations c7, r7) | Proposition, unchanged. |
| 29 | `prop:learn:curve` | Proposition | learn.tex:103 | proved; computed (foundations c11(a), r12) | Proposition, unchanged; "63 of 300 random finite instances had non-monotone curves (code in the accompanying repository)" (drop "foundations r12"). |
| 30 | `rem:learn:lastiterate` | Remark | learn.tex:110 | identity proved; computed (foundations c11(b)); bound open | Remark [Last iterate and leave-one-out]: keep the identity (proved); "Whether ... is open (the numbered Open Problem in Section 12). In 300 random finite instances the largest value of $(n+1)r_n/K$ was 0.873 (code in the accompanying repository)." |
| 31 | `prop:learn:splits` | Proposition | learn.tex:117 | proved; technique known; computed (context c3) | Proposition [Random splits]; add after it "The exchangeability argument is standard; cf. [HLW94]." (status 'technique known' becomes this sentence). |
| 32 | `prop:learn:loo` | Proposition | learn.tex:122 | proved; computed (context c7) | Proposition, unchanged. |
| 33 | `conj:learn:loo` | Conjecture | learn.tex:129 | conjecture | Conjecture (keep the environment); move the heuristic of App. C.7 directly after it as "Heuristic."; list as the numbered Open Problem in Section 12 in the discussion. |
| 34 | `prop:learn:typical` | Proposition | learn.tex:136 | proved; computed (context c4) | Proposition, unchanged. |
| 35 | `cor:learn:perstep` | Corollary | learn.tex:143 | proved; computed (context c7) | Corollary, unchanged. |
| 36 | `prop:learn:occam` | Proposition | learn.tex:156 | proved (standard); references known, unverified | Proposition [Occam bound]; add "This is the standard Occam bound [BEHW87] in description-length form." (status 'references known, unverified' disappears; BEHW87 verified). |
| 37 | `rem:learn:ideal` | Remark | learn.tex:163 | remark (each item cited) | Remark, unchanged (delete tag). |
| 38 | `rem:learn:hutterEX` | Remark | learn.tex:169 | known; unverified | Remark [Prior work]: "Hutter [Hut00, Hut07] lists supervised learning from examples among the problem classes of the AIXI model, and [Hut07] contains a section 'Supervised Learning from Examples (EX)'; [Hut05] is the book-length treatment. In this sense the use of a universal mixture as an ideal learner from examples is not new." Delete "A table-of-contents snippet shows" and "We have not read these sections". Better: move into Section 11 (Related work). |
| 39 | `def:hist:predictor` | Definition | hist.tex:16 | (none) | No tag (definition/remark); delete \src only. |
| 40 | `prop:hist:normchain` | Proposition | hist.tex:53 | proved; finite proxy computed | Proposition, unchanged. |
| 41 | `def:hist:readings` | Definition | hist.tex:64 | (none) | No tag (definition/remark); delete \src only. |
| 42 | `prop:hist:sketchfails` | Proposition | hist.tex:70 | computed; proved | Proposition [An earlier proof sketch fails] (or "The simulation argument needs shared randomness"); the example is proved by hand (two inputs), so call it proved; no 'computed'. |
| 43 | `thm:hist:directed` | Theorem | hist.tex:84 | proved; identity computed | Theorem, unchanged. |
| 44 | `thm:hist:randchain` | Theorem | hist.tex:88 | proved; refutes Reading B | Theorem [The randomised chain]; drop "Reading B is false" from the title; the sentence after it already says it refutes Reading B. |
| 45 | `thm:hist:minimax` | Theorem | hist.tex:96 | (a) proved; (b) proved for reveal laws that do not see $f$, proof sketch for those that do; computed | Split. Theorem (proved): the statement for (a) rational values, and for (b) computable real values when the reveal law does not see $f$. Then: "Remark (reveal laws that see $f$, real-valued case). The same bound should hold in case (b) for reveal laws that see $f\|_{A_n}$; we give only a proof sketch (Appendix D.2): the search must approximate $C_{\rm dir}$ to within one bit, which we do not write out." Delete the tag. |
| 46 | `cor:hist:thm1` | Corollary | hist.tex:103 | proved under the stated hypotheses | Corollary [A dominance theorem for computable reveal laws]; delete "under the stated hypotheses" tag; the statement already lists (A1), (A2). Drop "Hänni's" from the title (sole author). |
| 47 | `conj:hist:algmi` | Conjecture | hist.tex:111 | conjecture (untested) | Conjecture, unchanged; delete "The algorithmic form is untested:" and introduce with "We conjecture the following algorithmic form." |
| 48 | `def:hist:sfihist` | Definition | hist.tex:119 | (none) | No tag (definition/remark); delete \src only. |
| 49 | `thm:hist:representation` | Theorem | hist.tex:123 | proved; construction computed | Theorem, unchanged; following text: "The proof allocates dyadic intervals as in [ZL70]. For sequences, [WSH13] show that machine-based and mixture-based universal priors define the same class." Delete "(abstract seen only)" and "we have not checked whether ... and claim no novelty" (novelty is discussed once in Section 11). |
| 50 | `cor:hist:H4` | Corollary | hist.tex:129 | proved; identification known (unverified) | Corollary [Universality of $\SFIhist$]. Following text: replace "Agreement with Hutter's universal chronological semimeasure ... is known, but not checked against the sources ... and is not used" by "Universal chronological semimeasures were introduced by Hutter [Hut00, Hut05] for the AIXI model (with finite alphabets); nothing below depends on comparing his construction with $\MH$." Do NOT write "agrees with Hutter's $\xi$ up to constants" unless the author checks [Hut05]. |
| 51 | `prop:hist:strict` | Proposition | hist.tex:137 | proved; lemma computed | Proposition, unchanged. |
| 52 | `prop:hist:inputloss` | Proposition | hist.tex:153 | proved; toy computed | Proposition, unchanged. |
| 53 | `prop:hist:lhg` | Proposition | hist.tex:159 | conditional (on LHG transfer); LHG known, unverified beyond the abstract | Proposition (conditional statement; the hypotheses (LHG-even), (LHG-odd) are stated explicitly, so it is a proved implication). Rename the hypotheses (E) and (O); preceding sentence: "Lattimore, Hutter and Gavane [LHG11] show that the unnormalised version can fail to predict very simple recursive sub-patterns, such as ..." (delete "(abstract seen only)"). |
| 54 | `rem:hist:H4verdict` | Remark | hist.tex:165 | remark (cited items) | Remark [Summary: \SFIhist{} and SI]; delete "Verdict on Hänni's conjecture" title. |
| 55 | `thm:hist:gf` | Theorem | hist.tex:183 | proved; computed | Theorem, unchanged; "A direct computation (code in the accompanying repository) gives ..." already in standard form. |
| 56 | `def:ex:cyclic` | Definition | examples.tex:30 | (none) | No tag (definition/remark); delete \src only. |
| 57 | `thm:ex:cycle` | Theorem | examples.tex:37 | proved; computed (examples e3, e6(d)) | Theorem, unchanged; `tab:ex:cycle` caption: delete the in-table \status{computed}\src{...} line; caption begins "Exact finite mixtures (code in the accompanying repository):". |
| 58 | `thm:ex:ksteps` | Theorem | examples.tex:49 | proved; computed (examples e6(a),(b),(c)) | Theorem, unchanged. |
| 59 | `prop:ex:orderfree` | Proposition | examples.tex:59 | proved; sharper weak case open | Proposition, unchanged; the 'sharper weak case open' becomes the existing Open Question (move to Open Problems, item 'depth count for weak semimeasures'). |
| 60 | `prop:ex:normalised` | Proposition | examples.tex:72 | proved; proxy computed (examples e6(e)) | Proposition, unchanged. |
| 61 | `prop:ex:cychist` | Proposition | examples.tex:79 | proved, given \cref{cor:hist:H4} | Proposition, unchanged (its proof cites Corollary 5.18 (`cor:hist:H4`); 'given cor:hist:H4' is just the dependency). |
| 62 | `prop:ex:cycsi` | Proposition | examples.tex:95 | proved; computed (examples e6(f), an illustration) | Proposition, unchanged; the finite illustration: "An exact Bayes mixture ... gives full-cycle label loss 0.13-0.26 bits (code in the accompanying repository)." |
| 63 | `def:ex:eisenstat` | Definition | examples.tex:107 | (none) | No tag (definition/remark); delete \src only. |
| 64 | `prop:ex:asymp` | Proposition | examples.tex:141 | proved; computed (examples e1, e2, e7(d)) | Proposition, unchanged. |
| 65 | `thm:ex:expected` | Theorem | examples.tex:146 | proved; computed (examples e2) | Theorem, unchanged. |
| 66 | `prop:ex:law` | Proposition | examples.tex:152 | proved; computed (examples e1, s2(d)) | Proposition, unchanged. |
| 67 | `rem:ex:email` | Remark | examples.tex:161 | proved; normalised open | Remark [A heuristic argument for Eisenstat's example]: "The heuristic argument of [Hän26 / the author's correspondence with S. Eisenstat] (quoted in Appendix E.3) is correct in the semimeasure convention ...; for the normalised predictor the lower bound is open (the numbered Open Problem in Section 12)." Remove "Hänni's e-mail" from the title. |
| 68 | `prop:ex:burnin` | Proposition | examples.tex:168 | proved; computed (examples e1(e), e7(a),(b)) | Proposition, unchanged. |
| 69 | `prop:ex:rulestats` | Proposition | examples.tex:190 | proved; computed (examples e2, e7) | Proposition, unchanged. |
| 70 | `ex:ex:parity` | Example | examples.tex:213 | proved; computed (examples e4(a)) | Example, unchanged. |
| 71 | `ex:ex:threshold` | Example | examples.tex:218 | proved; computed (examples e4(b)) | Example, unchanged. |
| 72 | `prop:ex:frozen` | Proposition | examples.tex:235 | proved; computed (examples e4(c)) | Proposition, unchanged. |
| 73 | `prop:ood:relative` | Proposition | ood.tex:36 | proved (corrected) | Proposition, unchanged ("corrected" is internal; delete). |
| 74 | `prop:ood:machine` | Proposition | ood.tex:43 | proved; analogue known | Proposition; after it: "This is a supervised analogue of the dependence of AIXI on the reference machine [LH15b]." (status 'analogue known' becomes this sentence; already present). |
| 75 | `prop:ood:draftfalse` | Proposition | ood.tex:65 | refuted; proved | Proposition [The literal two-sided bounds fail]: state the two literal bounds in the paper's notation first (one displayed formula each, citing [Hän26] once), then (a), (b) as counterexamples. Remove "the draft" from section and statement titles. |
| 76 | `rem:ood:lopsided` | Remark | ood.tex:95 | refuted as stated; remark | Remark [The novelty bound is lopsided]: already in the form "Reading ... as ... is wrong: ..." -- acceptable; delete tag. |
| 77 | `prop:ood:labelled` | Proposition | ood.tex:125 | proved; disjointness computed (context c7) | Proposition, unchanged; the disjointness check in the proof: "(A direct computation on a finite mixture confirms the disjointness; code in the accompanying repository.)" (already in this form). |
| 78 | `rem:ood:answer` | Remark | ood.tex:143 | remark | Remark, unchanged (delete tag); candidate for merging into the Discussion. |
| 79 | `ex:ood:hanniexamples` | Example | ood.tex:166 | proved; computed (examples e5) | Example [Three examples from the author's notes] (drop the possessive); computation sentence already in standard form. |
| 80 | `conj:ood:natural` | Conjecture | ood.tex:177 | conjecture | Not a precise statement, so not a Conjecture environment. Replace by an item of the Open Problems list: "Formulate and prove a version of 'natural universal machines generalise as intended on natural training sets' (e.g. for proof-search labels); by Proposition 7.4 (`prop:ood:machine`) any such statement must restrict the reference machine." |
| 81 | `def:comp:timebounded` | Definition | comp.tex:15 | (none) | No tag (definition/remark); delete \src only. |
| 82 | `thm:comp:timebounded` | Theorem | comp.tex:20 | (a) proved (corrected); (b) proof sketch; computed (context c5, c9) | Split. Theorem (time-bounded SFI) = part (a) only. Part (b) becomes "Remark (running time; proof sketch). With $n_i=2^{2^i}$ and $g(n)=\lceil\log\log(n+4)\rceil$, round $k$ costs at most ... A proof sketch is in Appendix G; the machine model and the cost of the clocks are not written out." Also move the toy computation (regret 132.4 vs 184) into a sentence "A direct computation on a toy instance ...". |
| 83 | `rem:comp:distinct` | Remark | comp.tex:29 | refuted; computed (context c9) | Remark [Distinct inputs are a real restriction]: already in the form "One might hope ... For noisy labels it does not"; numbers: "a direct computation gives regret 469 bits". |
| 84 | `prop:comp:round` | Proposition | comp.tex:34 | proved; running time proof sketch; computed (context c9) | Split: Proposition = the regret bound (proved). The last sentence (per-round cost) moves to a Remark "(running time; proof sketch)" or is prefixed "Moreover, by a proof sketch in Appendix G, round $k$ costs ..." and the theorem statement keeps only the regret. |
| 85 | `rem:comp:apples` | Remark | comp.tex:56 | remark | Remark [Like-for-like comparison]; delete tag; replace "Hänni's 'apples to oranges' caveat" title. |
| 86 | `prop:comp:history` | Proposition | comp.tex:61 | regret proved; running time proof sketch | Split as for Proposition 8.4 (`prop:comp:round`): regret bound = Proposition; per-round cost = Remark with "Proof sketch". |
| 87 | `prop:comp:samplers` | Proposition | comp.tex:68 | proved (corrected) | Proposition, unchanged (delete "corrected"). |
| 88 | `def:comp:circuits` | Definition | comp.tex:80 | (none) | No tag (definition/remark); delete \src only. |
| 89 | `thm:comp:circuitbayes` | Theorem | comp.tex:87 | proved; computed (context c1, c8) | Theorem, unchanged; "A grid computation gives the largest ratio 10.85 in place of 16" -> "A direct computation over a grid of $(\mathcal E,d)$ values ...". |
| 90 | `rem:comp:gap` | Remark | comp.tex:97 | remark; computed (context c1) | Remark [Relation to the circuit sketch in [Hän26]]; computation sentence in standard form. |
| 91 | `prop:comp:occam` | Proposition | comp.tex:102 | (a) known; (b) proved | Proposition: "(a) [BEHW87] ...; (b) ..." -- the citation inside (a) is the 'known' status; delete tag. |
| 92 | `rem:comp:majority` | Remark | comp.tex:109 | proved; known | Remark; "known" is carried by the citations [Lit88, LW94]; delete tag. |
| 93 | `thm:comp:ladder` | Theorem | comp.tex:119 | proved; computed (context c6, c11); construction from the slides | Theorem [The conjunction ladder]; add "The construction is from [VH26]; we give a complete proof for formulas and circuits and every tie rule." (already in text). |
| 94 | `rem:comp:selection` | Remark | comp.tex:126 | computed (context c6(e)); known; unverified (claimed in the slides) | Remark [Selection rule versus prior]: keep the exact computations ("An exact computation (code in the accompanying repository) gives ..."); the slides' table: "Vaintrob and Hänni [VH26] state the following further bounds, which we do not prove: ..." Delete "and we have not checked them". |
| 95 | `prop:nn:functionspace` | Proposition | nn.tex:10 | proved (trivial) | Proposition (or Observation); delete "(trivial)". |
| 96 | `prop:nn:upper` | Proposition | nn.tex:19 | proved (given the coding theorem) | Proposition, unchanged; the following text marks the Gaussian case explicitly: "for Gaussian priors on real weights with sign outputs we only sketch why $P_A$ is lsc" (already), so the statement keeps its hypothesis "if $P_A$ is lower-semicomputed by $a$". |
| 97 | `prop:nn:typical` | Proposition | nn.tex:26 | proved; known (standard) | Proposition; after it "This is the standard fact that $-\log P\approx K$ on $P$-most objects [LV08]." (already). |
| 98 | `rem:nn:bridge` | Remark | nn.tex:49 | remark | Remark, unchanged (delete tag). |
| 99 | `thm:nn:walsh` | Theorem | nn.tex:56 | proved; (a) known, (b) standard; computed (context c2) | Theorem; after the proof idea: "Part (a) is known (see [YS19]); (b) is the standard dimension argument (cf. [KMS20])." Delete "(as summarised in its abstract and in the slides)". |
| 100 | `cor:nn:separation` | Corollary | nn.tex:64 | proved; computed (context c2) | Corollary, unchanged. |
| 101 | `rem:nn:oddparity` | Remark | nn.tex:71 | proved; computed (context c2, c10, c12); known | Remark; "This is the cube analogue of the observation of Basri et al. [BJKK19] that two-layer networks without bias cannot learn odd frequencies on the sphere." (delete "as stated in their abstract"); "this is computed, not proved" -> "(a direct computation; not proved)". |
| 102 | `rem:nn:slides` | Remark | nn.tex:79 | known; unverified (claimed in the slides); warm-up arithmetic re-checked (context c8) | Remark [Results stated in [VH26]]: "The slides [VH26] state the following results, with the caveats that ... We do not use them. (i) ... (vi) ... We verify the warm-up computation of (i), the character argument of their Appendix J (Theorem 9.7(a)) and the ladder of their Appendix K (Theorem 8.14)." Delete "the rest is unchecked" and the status words. |
| 103 | `rem:nn:rigorous` | Remark | nn.tex:84 | remark | Remark; delete tag; candidate for deletion (it repeats the section). |
| 104 | `rem:nn:literature` | Remark | nn.tex:89 | known (snippets; unverified) | Move into Section 11 (Related work) as a paragraph; delete "These descriptions follow the abstracts" and the status words; keep neutral one-line descriptions of verified papers. |
| 105 | `rem:related:new` | Remark | related.tex:16 | known (snippets; unverified) | Not a remark: replace by a short paragraph "Novelty" at the end of Section 11 stating, without process vocabulary, what is believed new; BEFORE that, the author must check [Sol08], [Hut05, Ch. on supervised learning] and [LH13] (all three are obtainable) -- the remark itself says this must be done 'before any claim of novelty'. If not checked, delete the novelty list entirely and keep only "We are not aware of earlier uses of the name 'Solomonoff function induction'." |
| 106 | `lem:setting:realise` | Lemma | app-setting.tex:76 | proved (binary case known: Zvonkin--Levin 1970, unverified) | Lemma [Realisation]; first proof sentence: "For binary sequences this is due to Zvonkin and Levin [ZL70]; the proof below covers countable alphabets." (delete "not checked against the source"). |
| 107 | `prop:setting:twopoint` | Proposition | app-setting.tex:138 | proved; computed | Proposition, unchanged; replace "(c10(a4))" and "Check c10 found agreement ... (r13: 300 of 300)" by "A direct computation found agreement between $(\star)$ and order independence on all 400 random laws with positive two-point cells tested (code in the accompanying repository)." |
| 108 | `prop:setting:transfer` | Proposition | app-setting.tex:156 | proved; (b) uses the relativised coding theorem (known); computed | Proposition; in (b) write "by the coding theorem relative to $\emptyset'$ [LV08, \S4.3]"; replace "(c10(b) checks this exactly on 16,200 cases ...)" by "a direct computation confirms (a) exactly on 16,200 cases". |
| 109 | `rem:versions:Wrate` | Remark | app-versions.tex:30 | proved; rate open | Remark [Growth of the gap of $W$]; replace "rate open" by a pointer to the numbered Open Problem in Section 12 (exact rate). |
| 110 | `rem:versions:hashing` | Remark | app-versions.tex:55 | proved; computed | Remark [A hashing bound] (drop "superseded" from the title; say "Proposition 3.6(b) is stronger"); replace "(c2 checks this exhaustively ...)" by "(a direct computation confirms this for $(q,k)\in\{(3,2),(3,3),(4,2),(4,3)\}$)". Candidate for deletion to save space. |
| 111 | `rem:learn:increasing` | Remark | app-learn.tex:112 | computed (context c3 Part 2) | Remark [Learning curves can increase]: "A direct computation (code in the accompanying repository) gives ..."; delete "(context c3 Part 2)". |
| 112 | `rem:learn:cesaro` | Remark | app-learn.tex:117 | refuted | Delete as a remark about an earlier version of the notes. If kept: Remark [Per-step versus averaged rates]: "Proposition 4.13 (`prop:learn:typical`) should not be read as matching the $O(1/n)$ Cesàro bound up to $\log^2 n$: it is a per-step lower bound, while Theorem 4.5 (`thm:learn:batch`) bounds an average; indeed $\sum_k\Ex e_k\le(\ln2)(K(f)+c)$, so $\liminf_k k\,\Ex e_k=0$. Corollary 4.14 (`cor:learn:perstep`) gives the per-step comparison." Remove "An earlier version of the context notes". |
| 113 | `rem:learn:relations` | Remark | app-learn.tex:122 | remark | Remark, unchanged (delete tag). |
| 114 | `rem:learn:positive` | Remark | app-learn.tex:131 | proof sketch; known (snippet) | Remark [Positive examples] with the derivation marked "Sketch."; last sentence: "A related ideal learner from positive evidence is studied by Chater and Vitányi [CV07]." Delete "their exact model was not checked" and the status words 'known (snippet)'. |
| 115 | `rem:learn:interventions` | Remark | app-learn.tex:136 | remark | Remark, unchanged (delete tag). Candidate for deletion. |
| 116 | `rem:hist:thm1open` | Remark | app-hist.tex:112 | open | Move to the Open Problems list (Section 12) as a numbered Open Problem "(Removing $K(n)+K(A)$ in Corollary 5.14.)" with items (i)-(iv); the numerical evidence becomes "a direct computation on one small instance suggests ...". |
| 117 | `prop:hist:shannon` | Proposition | app-hist.tex:124 | proved; computed | Proposition, unchanged. |
| 118 | `prop:hist:operator` | Proposition | app-hist.tex:176 | proved, given the unverified description | Proposition stated for $\Mpq$ (definitional): "\SFIhist{} dominates $\Mpq$ ..."; the identification with operator induction goes into one sentence citing [Sol08] under the reading fixed in Remark 3.x. Delete "given the unverified description". |
| 119 | `prop:hist:programs` | Proposition | app-hist.tex:184 | proved; toy computed | Proposition, unchanged; replace check identifiers in App. D by "a direct computation". |
| 120 | `lem:hist:charsum` | Lemma | app-hist.tex:227 | proved; computed | Lemma, unchanged; "Exhaustive search gives $\max_GN(G)=8$ ($q=2$) and $22$ ($q=3$); for $q=4$ it lies in $[56,80]$." stays (standard form). |
| 121 | `prop:hist:info` | Proposition | app-hist.tex:248 | (a) proved; (b) refuted; computed | Proposition [An individual-sequence bound and its limit]; (b) already reads "The natural strengthening ... is false": standard form. Delete tag. |
| 122 | `rem:hist:exploit` | Remark | app-hist.tex:256 | remark (informal part not a theorem) | Remark; the informal sentence starts with "Informally," and the proved bounds follow with references (already so); delete tag. |
| 123 | `lem:ex:depth` | Lemma | app-examples.tex:42 | proved; computed (examples e6(b)) | Lemma, unchanged. |
| 124 | `conj:ex:raw` | Conjecture | app-examples.tex:100 | conjecture | Conjecture, unchanged; "Heuristic, not proved." -> "Heuristic." |
| 125 | `rem:ex:where` | Remark | app-examples.tex:116 | proved; the other-direction part conditional | Remark; the 'other direction' sentence is a conditional statement: "if unnormalised $M$ has unbounded loss on ... (as [LHG11] show for related sub-patterns), then ..." -- keep the conditional explicit; delete tag. |
| 126 | `lem:ex:behind` | Lemma | app-examples.tex:168 | proved; computed (examples e7(a)) | Lemma, unchanged. |
| 127 | `lem:ex:pstar` | Lemma | app-examples.tex:196 | proved; computed (examples e1(c)) | Lemma, unchanged. |
| 128 | `rem:ex:fresh` | Remark | app-examples.tex:229 | proved (citing) | Remark, unchanged (delete tag). |
| 129 | `lem:comp:mobius` | Lemma | app-comp.tex:36 | proved; computed (context c6(a), $d\le4$) | Lemma, unchanged; the computation for $d\le4$ in standard form. |
| 130 | `rem:comp:adversary` | Remark | app-comp.tex:57 | proved; computed (context c11) | Remark (proved); "A direct computation under seven tie rules ($d=3,4,5$) confirms this." (already). |

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

| # | key | file | cited in P1 | class | data confirmed / corrected | action |
|---|---|---|---|---|---|---|
| 1 | `filan2016loss` | comp.bib | yes | verified | AISTATS 2016 PMLR 51:1394-1402 | none |
| 2 | `impagliazzo1990no` | comp.bib | yes | verified | FOCS 1990 pp 812-821 | none |
| 3 | `littlestone1994weighted` | comp.bib | yes | verified | Inf Comput 108(2):212-261 doi 10.1006/inco.1994.1009 | none |
| 4 | `schmidhuber2002speed` | comp.bib | yes | verified | COLT 2002 pp 216-228 doi 10.1007/3-540-45435-7_15 (vol LNAI 2375 unconfirmed; omitted already). | COLT 2002, pp. 216--228, doi 10.1007/3-540-45435-7_15; series volume (LNAI 2375) not confirmed, correctly omitted. |
| 5 | `barron1991minimum` | core.bib | yes | verified | IEEE TIT 37(4):1034-1054 | none |
| 6 | `barzdin1972prediction` | core.bib | yes | fixable | Soviet Math. Dokl. 13:1224-1228 (transl. of Dokl. Akad. Nauk SSSR 206(3):521-524). Add pages. | Add pages = {1224--1228} (English translation of Dokl. Akad. Nauk SSSR 206(3):521--524, Math-Net.Ru); the printed entry currently has volume only. |
| 7 | `bhattacharya2019fractional` | core.bib | no (shared core.bib; dropped by BibTeX) | verified | AoS 47(1):39-66 | none |
| 8 | `bissiri2016general` | core.bib | no (shared core.bib; dropped by BibTeX) | verified | JRSS-B 78(5):1103-1130 | none |
| 9 | `claude2026whatfollows` | core.bib | no (shared core.bib; dropped by BibTeX) | unverifiable / internal (uncited in P1) | author "Claude (Anthropic)" violates the authorship rule | Author field "Claude (Anthropic)" and "unpublished report" -- cannot appear in an arXiv bibliography under the authorship rule. Uncited in Paper 1, so harmless here; Paper 2 must drop or re-attribute it. |
| 10 | `claudeSFI2026fundamentals` | core.bib | no (shared core.bib; dropped by BibTeX) | n/a (self; uncited in P1) | key name contains "claude"; fine if invisible | Not cited in Paper 1 (it is this paper). No action; ensure Paper 2 cites the arXiv identifier. |
| 11 | `claudeSFI2026steeper` | core.bib | yes | fixable (self) | ok as "in preparation"/arXiv number when available | Companion paper. Replace "Companion paper, draft ... Folder ... of GitHub" by the arXiv identifier once posted (or "In preparation"). Key name is invisible and may stay. |
| 12 | `gacs2001algorithmic` | core.bib | no (shared core.bib; dropped by BibTeX) | verified | IEEE TIT 47(6):2443-2463 | none |
| 13 | `gneiting2007strictly` | core.bib | no (shared core.bib; dropped by BibTeX) | verified | JASA 102(477):359-378 | none |
| 14 | `gold1967language` | core.bib | yes | verified | Inf Control 10(5):447-474 | none |
| 15 | `grunwald2007minimum` | core.bib | yes | verified | MIT Press 2007 | none |
| 16 | `grunwald2012safe` | core.bib | no (shared core.bib; dropped by BibTeX) | verified | ALT 2012 LNCS 7568:169-183 | none |
| 17 | `grunwald2017inconsistency` | core.bib | no (shared core.bib; dropped by BibTeX) | verified | Bayesian Analysis 12(4):1069-1103 | none |
| 18 | `hanni2026lesswrong` | core.bib | yes | unverifiable / must change | LessWrong unreachable; no search hit; authorship "Hänni and Wyeth" is wrong for a comment thread. | Not reachable, no search hit, year "undated", author list "Hänni and Wyeth" is wrong for a comment thread (the post is Jonas Hallgren's shortform) and puts Wyeth's name next to the absorption objection. Drop it (the proposal is in hanni2026notes), or cite only Hänni's own comment (author = Hänni, with the comment date) in at most one neutral footnote, per the binding note. |
| 19 | `hanni2026notes` | core.bib | yes | fixable | github.com/kaarelh/notes exists (MIT, "some of my notes from 2023-2026"); SFI note is ai/learning/solomonoff induction/"solomonoff function induction.md" (+ .pdf). Title "notes" should name the note. | The repository exists (github.com/kaarelh/notes, "some of my notes from 2023-2026"); the SFI note is ai/learning/solomonoff induction/solomonoff function induction.md (and .pdf). Cite that note: title = {Solomonoff function induction}, howpublished = {Note in \url{https://github.com/kaarelh/notes}, folder ai/learning/solomonoff induction}, year = {2026}. The current title "notes" is unacceptable. |
| 20 | `hanni2026request` | core.bib | yes | unverifiable / must drop |  | A "personal communication to the author" from the sole author, pointing to research/00-brief.md (process file). Drop. Re-source each use: the author's ideas -> hanni2026notes or first person; Eisenstat's example -> "S. Eisenstat, personal communication" (in text and acknowledgements); the e-mail heuristic -> "a heuristic argument of the author (correspondence with S. Eisenstat)". |
| 21 | `hoeffding1963probability` | core.bib | yes | fixable | JASA 58(301):13-30 | Add number = {301}; optional doi 10.1080/01621459.1963.10500830. |
| 22 | `li2008introduction` | core.bib | yes | verified | Springer New York 2008, 3rd ed., Texts in CS, doi 10.1007/978-0-387-49820-1 | none |
| 23 | `littlestone1988learning` | core.bib | yes | verified | ML 2(4):285-318 | none |
| 24 | `sion1958general` | core.bib | yes | verified | PJM 8(1):171-176 | none |
| 25 | `vaintrobhanni2026nnbayes` | core.bib | yes | unverifiable | kaarelh.github.io not reachable; Fields talk 21 Apr 2026 by Vaintrob on joint work found, not the slides. | URL kaarelh.github.io/ai/nnbayes-generalization.pdf does not resolve from here and no search hit for the title or an ILIAD listing; a Fields Institute talk (21 Apr 2026) by Vaintrob on the joint work exists. Since the author is a co-author of the slides, he can confirm title/venue/date himself; until then keep only if the URL is live, else replace by vaintrob2026width where possible. |
| 26 | `vereshchagin2004kolmogorov` | core.bib | no (shared core.bib; dropped by BibTeX) | verified | IEEE TIT 50(12):3265-3290 | none |
| 27 | `vereshchagin2010rate` | core.bib | no (shared core.bib; dropped by BibTeX) | verified | IEEE TIT 56(7):3438-3454 | none |
| 28 | `vereshchagin2017algorithmic` | core.bib | no (shared core.bib; dropped by BibTeX) | verified | LNCS 10010:669-737 | none |
| 29 | `ville1939etude` | core.bib | yes | fixable |  | Numdam lists it as a thesis (Thèses de l'entre-deux-guerres no. 218, 1939, 124 pp.); the Gauthier-Villars imprint was not confirmed by search. Either confirm the imprint (series Monographies des Probabilités) or cite as @phdthesis{..., school = {Université de Paris}, year = {1939}}. |
| 30 | `vovk2005algorithmic` | core.bib | yes | verified | Springer 2005 doi 10.1007/b106715 | none |
| 31 | `zhang2006epsilon` | core.bib | no (shared core.bib; dropped by BibTeX) | verified | AoS 34(5):2180-2210 (2006) | none |
| 32 | `robbins1955remark` | examples.bib | yes | verified | AMM 62(1):26-29 doi 10.2307/2308012 | none |
| 33 | `lattimore2011universal` | hist.bib | yes | verified | ALT 2011 LNCS 6925 pp 262-276 doi 10.1007/978-3-642-24412-4_22. | none |
| 34 | `wood2013non` | hist.bib | yes | fixable | pp 417-425 doi 10.1007/978-3-642-44958-1_33, Ray Solomonoff 85th Memorial Conf; same book as lattimore2013nofree => LNCS/LNAI 7070. | Add volume = {7070}, editor = {Dowe, David L.} (same book as lattimore2013nofree; LNCS/LNAI 7070), pages 417--425 confirmed (ANU record). |
| 35 | `blumer1987occam` | learn.bib | yes | verified | IPL 24(6):377-380 | none |
| 36 | `cesabianchi2004generalization` | learn.bib | yes | verified | IEEE TIT 50(9):2050-2057 doi 10.1109/TIT.2004.833339 | none |
| 37 | `cesabianchi2006prediction` | learn.bib | yes | verified | CUP 2006 | none |
| 38 | `chater2007ideal` | learn.bib | yes | verified | J Math Psych 51(3):135-163 (2007) | none |
| 39 | `haussler1994predicting` | learn.bib | yes | verified | Inf Comput 115(2):248-292 (1994) | none |
| 40 | `hutter2000theory` | learn.bib | yes | verified | arXiv cs/0004001, 3 Apr 2000. | none |
| 41 | `hutter2005universal` | learn.bib | yes | verified | Springer Berlin 2005, Texts in TCS (EATCS), doi 10.1007/b138233 | none |
| 42 | `hutter2007aixi` | learn.bib | yes | verified | AGI book Springer 2007 pp 227-290; arXiv cs/0701125; abstract lists supervised learning. | none |
| 43 | `littlestone1989online` | learn.bib | yes | verified | COLT 1989 pp 269-284 doi 10.1016/B978-0-08-094829-4.50022-2 | none |
| 44 | `mcallester1999some` | learn.bib | yes | verified | ML 37(3):355-363 doi 10.1023/A:1007618624809 | none |
| 45 | `orseau2013universal` | learn.bib | yes | fixable | Springer: ALT 2013 proceedings = LNCS 8139 (LNAI subseries), eds Jain, Munos, Stephan, Zeugmann. | Add volume = {8139} (Springer: ALT 2013 proceedings, LNCS 8139, LNAI subseries; eds. Jain, Munos, Stephan, Zeugmann). |
| 46 | `solomonoff1978complexity` | learn.bib | yes | verified | IEEE TIT 24(4):422-432. | none |
| 47 | `vovk1990aggregating` | learn.bib | yes | fixable | COLT 1990 (3rd workshop, Rochester), starts p.371; end page 383 (Royal Holloway) vs 386. Add pp. 371--383. | Add pages = {371--383} (Royal Holloway repository; one citing list gives 371--386) and editors Fulk and Case, or keep pages omitted. |
| 48 | `basri2019convergence` | nn.bib | yes | verified | NeurIPS 32, arXiv 1906.00425; pages 4761-4771 (mlanthology) vs 4763-4772. | NeurIPS 32 (2019); pages differ between indexes (4761--4771 vs 4763--4772), so omitting pages is correct. |
| 49 | `buzaglo2024` | nn.bib | yes | verified | ICML 2024 PMLR 235:5035-5081 | none |
| 50 | `dingle2018input` | nn.bib | yes | verified | Nat Commun 9:761 doi 10.1038/s41467-018-03101-6 | none |
| 51 | `goldblum2023no` | nn.bib | yes | verified | ICML 2024 PMLR 235:15788-15808, "Position: ..." | ICML 2024, PMLR 235:15788--15808; title begins "Position:" (as in the entry). Key year differs, harmless. |
| 52 | `grau2024learning` | nn.bib | yes | verified | ICML 2024 PMLR 235:16178-16205 | none |
| 53 | `kamath2020approximate` | nn.bib | yes | verified | COLT 2020 PMLR 125:2236-2262 | none |
| 54 | `mingard2021sgd` | nn.bib | yes | verified | JMLR 22(79):1-64 | none |
| 55 | `mingard2025deep` | nn.bib | yes | verified | Nat Commun 16:220 doi 10.1038/s41467-024-54813-x | none |
| 56 | `vaintrob2026width` | nn.bib | yes | verified | arXiv 2607.05735, 7 July 2026, Vaintrob & Hänni. | none |
| 57 | `valle2019deep` | nn.bib | yes | verified | ICLR 2019, arXiv 1805.08522. | none |
| 58 | `yang2019fine` | nn.bib | yes | verified | arXiv 1907.10599 (v4 Apr 2020) | arXiv:1907.10599 (v4, 9 Apr 2020). Keep as arXiv; do not cite an ICLR 2020 version unless confirmed. |
| 59 | `leike2015bad` | ood.bib | yes | verified | COLT 2015 PMLR 40:1244-1259. | none |
| 60 | `case1983comparison` | related.bib | yes | fixable | TCS 25(2):193-220, doi 10.1016/0304-3975(83)90061-0. | Add number = {2}. |
| 61 | `lattimore2013nofree` | related.bib | yes | verified | LNAI 7070 pp 223-235 doi 10.1007/978-3-642-44958-1_17 (ed. Dowe). | none |
| 62 | `ozkural2015ultimate` | related.bib | yes | verified (data) / replace as content source | arXiv 1504.03303; abstract is about physical measures; operator-induction description not confirmed. | arXiv:1504.03303 confirmed (later AGI 2016 version has a different title). Its abstract concerns physical measures of intelligence; the operator-induction formula attributed to it was seen only in a snippet. Cite Solomonoff [Sol08] for the formula after checking it, and drop this entry. |
| 63 | `poland2005asymptotics` | related.bib | yes | verified | IEEE TIT 51(11):3780-3795 doi 10.1109/TIT.2005.856956 | none |
| 64 | `ryabko2006pattern` | related.bib | yes | verified | JMLR 7:645-664 (2006) | none |
| 65 | `vovk1992universal` | related.bib | yes | verified | Inf. Comput. 96(2):245-277 (1992) | none |
| 66 | `chaitin1975theory` | setting.bib | yes | verified | JACM 22(3):329-340 | none |
| 67 | `choquet1954theory` | setting.bib | yes | verified | Ann Inst Fourier 5:131-295 doi 10.5802/aif.53 | none |
| 68 | `day2011increasing` | setting.bib | yes | fixable | AMS TOC: Trans. Amer. Math. Soc. 363(10) (2011) 5577-5604 (confirmed by extended search, AMS issue listing). | Add volume = {363}, number = {10}, pages = {5577--5604} (AMS issue listing, Trans. Amer. Math. Soc. 363(10), 2011). Fix the .bib comment "CCC 2009" (conference version was CCR 2009). |
| 69 | `epstein2011sets` | setting.bib | yes | verified | arXiv 1107.1458 | arXiv:1107.1458; authorship (Epstein and Levin) as in citing literature ("Epstein-Levin theorem"). |
| 70 | `gacs1974symmetry` | setting.bib | yes | verified | Soviet Math Dokl 15:1477-1480 (Russian: DAN 218(6):1265-1267) | Optional: number = {5}; Russian original Dokl. Akad. Nauk SSSR 218(6):1265--1267. |
| 71 | `gacs1983relation` | setting.bib | yes | verified | TCS 22(1-2):71-93 | none |
| 72 | `kleitman1973families` | setting.bib | yes | fixable | Discrete Math 6:255-262 (1973) | Optional: number = {3}. |
| 73 | `leike2015computability` | setting.bib | yes | verified | ALT 2015 LNCS 9355:364-378 doi 10.1007/978-3-319-24486-0_24. | none |
| 74 | `levin1974laws` | setting.bib | yes | verified | Probl. Inf. Transm. 10(3):206-210 (mathnet); Russian 30-35. | none |
| 75 | `levin2016occam` | setting.bib | yes | verified | APAL 167(10):897-900; arXiv 1403.4539 | none |
| 76 | `matheron1975random` | setting.bib | yes | verified | Wiley, New York, 1975 ([1974, c1975]) | none |
| 77 | `ozkural2017ultimate` | setting.bib | yes | verified (data) / replace as content source | arXiv 1709.03879; content (operator-induction formula) not confirmed by snippet. | arXiv:1709.03879 confirmed. The product formula for operator induction is not confirmed by any search; replace by the primary source [Sol08] (check it) or drop. |
| 78 | `shafer1976mathematical` | setting.bib | yes | verified | Princeton UP 1976 | none |
| 79 | `solomonoff2008three` | setting.bib | yes | verified | Comput. J. 51(5):566-570 doi 10.1093/comjnl/bxm120. | none |
| 80 | `strassen1965existence` | setting.bib | yes | verified | AoMS 36(2):423-439 doi 10.1214/aoms/1177700153 | none |
| 81 | `zvonkin1970complexity` | setting.bib | yes | verified | Russ. Math. Surveys 25(6):83-124 | none |
| 82 | `grunwald2007suboptimal` | steeper.bib | yes | fixable | ML 66(2-3):119-149, doi 10.1007/s10994-007-0716-7. | Add number = {2--3}, doi = {10.1007/s10994-007-0716-7}. |
| 83 | `zhu2025quantifying` | steeper.bib | yes | verified | COLT 2025 PMLR 291:6124-6155. | none |
| 84 | `zhu2026overfitting` | steeper.bib | yes | verified | arXiv 2603.22644, 23 Mar 2026. | none |

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

**P1-ARX-01** [fatal] `paper/sections/intro.tex` — line 19 (contributions, "History-aware prediction") and line 26 ("Corrections to earlier claims")

- *Problem.* The introduction states that the dominance theorem for computable reveal laws (the notes' 'Thm 1') 'is true in the reading his text supports, under finiteness hypotheses' and 'holds in its intended reading'. The body proves it only with an extra K(n)+K(A) term for random reveal laws, and whether that term can be removed is listed as open. The introduction therefore claims more than the body and the ledger.
- *Evidence.* cor:hist:thm1(a): E LSFI <= E L_P + K(P) + K(Delta_f) + K(n) + K(A) + c under (A1),(A2); text after it: 'So Thm 1 is true in Hänni's reading, with an extra K(n)+K(A) for random reveal laws'; rem:hist:thm1open(i) and the Discussion's open problem 'Can the K(n)+K(A) term of cor:hist:thm1 be removed'; CLAIMS.md §3 R2: 'true under stated hypotheses, with K(n)+K(A)'. The H3 row of tab:intro:verdicts (same page) does carry 'with K(n)+K(A)', so the introduction is also internally inconsistent.
- *Fix.* intro.tex:19, replace the sentence by: "For computable reveal laws, the dominance theorem of [Hän26] holds in the reading its text supports: exactly and on every path for deterministic computable reveal orders, and in expectation, with an additional K(n)+K(A) term, for randomised reveal laws under finiteness assumptions; the original proof sketch fails, and a stronger (oracle) reading is false (Prop. 5.8, Cor. 5.14, Thm 5.12)." intro.tex:26: "... the theorem holds in its intended reading up to an additional K(n)+K(A) term for randomised reveal laws (Cor. 5.14)".

**P1-ARX-02** [major] `paper/sections/abstract.tex` — line 3, sentence "A dominance theorem for computable reveal orders holds in its intended reading, though an earlier proof sketch fails."

- *Problem.* Ambiguous and, for the reading a reader will take, stronger than the body: 'reveal orders' suggests deterministic orders (for which cor:hist:thm1(b) holds exactly), but 'intended reading' and 'earlier proof sketch' refer to randomised reveal laws, where the bound carries K(n)+K(A) and needs (A1),(A2). 'An earlier proof sketch' also refers to unpublished notes the arXiv reader cannot place; whose theorem it is is not said.
- *Evidence.* cor:hist:thm1(a),(b); prop:hist:sketchfails; the abstract never mentions the notes or the extra terms.
- *Fix.* Replace by: "For deterministic computable reveal orders a dominance theorem holds on every path; for randomised reveal laws it holds in expectation up to an additional K(n)+K(A) term, while a natural simulation proof fails and an oracle version is false."

**P1-ARX-03** [major] `paper/sections/intro.tex` — line 20 (contributions, "Worked examples"): "In Sam Eisenstat's coin example SFI pays H(1/3)/2 n ± O(log n) bits"

- *Problem.* Missing 'in expectation'. Pathwise the body proves |LSFI - UB_n| <= log n + O(log log n) + c_b, and UB_n itself fluctuates by Theta(sqrt n) around H(1/3)n/2, so the unqualified ± O(log n) is false pathwise. The same sentence says 'SI pays ... in expectation', which invites the pathwise reading for SFI.
- *Evidence.* thm:ex:expected (expectation, ± log n + 2 log log n + c); thm:ex:sandwich (pathwise, relative to UB_n); prop:ex:asymp: (UB_n - H(1/3)n/2)/sqrt n -> N(0, 1.0497). The H6 row of tab:intro:verdicts ('Confirmed up to O(log n)', citing the pathwise sandwich) has the same problem.
- *Fix.* "... SFI's expected loss is H(1/3)n/2 ± O(log n) bits (and almost surely within log n + O(log log n) of the threshold loss UB_n) in the semimeasure convention ..."

**P1-ARX-04** [major] `paper/sections/abstract.tex; paper/sections/intro.tex` — abstract line 3 ("Solomonoff induction on the interleaved sequence pays O(1) in expectation"); intro.tex line 20

- *Problem.* Missing hypothesis: the O(1) bound for SI on the cyclic permutation holds for the self-delimiting block code bar s = 1^|s| 0 s fixed in the body; with raw d-bit blocks the proved bound is K(d)+c and the conjectured order is K(d).
- *Evidence.* prop:ex:cycsi (prefix code), prop:ex:cycraw (raw blocks, K(d)+c), conj:ex:raw (order K(d)); examples.tex:100 'With raw d-bit blocks the bound becomes K(d)+c ... probably the right order'.
- *Fix.* Abstract: "... while Solomonoff induction on the interleaved sequence, with a self-delimiting encoding of the pairs, pays O(1) in expectation." Intro line 20: add "(with the self-delimiting code of Section 5.5)".

**P1-ARX-05** [major] `paper/CLAIMS.md` — §3, entry R5

- *Problem.* The ledger states that SFI's loss in Eisenstat's example is 'H(1/3)/2 n ± O(log n), pathwise a.s. and in expectation'. Pathwise this is false (fluctuations of order sqrt n); the paper's body is correct, but the conversion pass and the intro were written from this ledger.
- *Evidence.* prop:ex:asymp (CLT for UB_n), thm:ex:sandwich (pathwise statement is relative to UB_n).
- *Fix.* Correct R5 to: "E LSFI = H(1/3)n/2 ± O(log n); almost surely |LSFI - UB_n| <= log n + O(log log n) + c_b, with UB_n = H(1/3)n/2 + O_P(sqrt n)", and check every sentence derived from R5 (intro line 20, H6 row).

**P1-ARX-06** [major] `paper/bib/core.bib; paper/sections/{versions,learn,hist,examples,nn,steeper,intro}.tex; app-examples.tex` — key hanni2026request; versions.tex:4, learn.tex:7, hist.tex:12 and :117, examples.tex:7, :35, :112, nn.tex:8, steeper.tex:14, intro.tex:51, :55, app-examples.tex:140, versions.tex:123 and :137

- *Problem.* The sole author cites 'Request for a paper on Solomonoff function induction. Personal communication to the author ... quoted verbatim in solomonoff-function-induction/research/00-brief.md' (a process file), and the text speaks of 'his request', 'Hänni's request', 'He later asked that the paper include ...', 'Answer to Hänni's request', 'as quoted in his request'. With Hänni as sole author this is a request from the author to himself; the binding note forbids conversational references to 'his request' and process vocabulary ('brief').
- *Evidence.* PDF p. 54: 'Kaarel Hänni. Request for a paper on Solomonoff function induction. Personal communication to the author, 11 October 2026; quoted verbatim in solomonoff-function-induction/research/00-brief.md ...'. versions.tex:4 'He later asked that the paper "include an equivalence ..."'; versions.tex:137 remark title 'Answer to Hänni's request'.
- *Fix.* Delete the entry. Re-source every use: (i) the author's own conjectures and examples -> first person or [Hän26] (the notes) when they are in the notes; (ii) Eisenstat's coin example -> 'S. Eisenstat (personal communication)' in the text and the acknowledgements; (iii) the e-mail heuristic -> 'a heuristic argument (the author, in correspondence with S. Eisenstat)'; (iv) versions.tex:4 -> 'A natural question is whether the Kolmogorov and semimeasure versions are equivalent, as for strings; they are not.'; (v) rem:versions:answer title -> 'Summary: the versions are not equivalent'; (vi) table caption: delete '(Hänni's later request)'.

**P1-ARX-07** [major] `paper/sections/*.tex` — 143 occurrences of "Hänni" in the PDF before Appendix I; section titles sec:hist:counter "Hänni's counterexamples", sec:hist:thm1 "Hänni's Theorem 1", sec:ood:examples "Hänni's examples"; environment titles thm:hist:chain, thm:hist:skipped, thm:hist:randchain, cor:hist:thm1, prop:ood:hanni, ex:ood:hanniexamples, rem:comp:apples, rem:ex:email, rem:hist:H4verdict

- *Problem.* The paper is now sole-authored by Hänni but refers to its author in the third person throughout and names results after him ('Hänni's chain', 'Hänni's proposition, with no log term', 'Verdict on Hänni's conjecture', 'Hänni's Theorem 1 in Reading C'). Self-eponymous theorem titles and third-person self-reference are not standard and will confuse readers (is Hänni the author or someone being corrected?). It also cites unpublished numbering ('Thm 1', 'Remark 4').
- *Evidence.* PDF text: 'Theorem 5.3 (Hänni's chain)', 'Proposition 7.1 (Hänni's proposition, with no log term)', 'Remark 5.23 (Verdict on Hänni's conjecture)'; comp.tex:54 'This is Hänni's "Remark 4"'; hist.tex:62 'Hänni's Thm 1: ...'.
- *Fix.* Neutral titles: 'A chain example', 'Skipped strings', 'Unseen simple properties (no logarithmic term)', 'The randomised chain', 'A dominance theorem for computable reveal laws', 'Three examples', 'Like-for-like comparison', 'A heuristic argument for Eisenstat's example', 'Summary: SFI with the list of previous inputs'. In prose use 'the author's earlier notes [Hän26]' once per section and then '[Hän26]'; state the arrangement once in the introduction ('This paper develops, corrects and extends the author's notes [Hän26]').

**P1-ARX-08** [major] `paper/sections/{intro,ood,versions}.tex` — intro.tex:26 ("the PDF draft", "which the draft hoped"); ood.tex:7, :51 (subsection title "The draft's two-sided result"), :53, :65 (title "the draft's bounds as stated are false"); versions.tex:4, :144 ("Hänni's draft")

- *Problem.* 'The draft' / 'the PDF draft' is an unpublished document the reader cannot identify; it is neither in the bibliography nor distinguished from [Hän26].
- *Evidence.* PDF §7.2 heading 'The draft's two-sided result'; Proposition 7.6 title 'the draft's bounds as stated are false'.
- *Fix.* Cite it as [Hän26] (the PDF 'solomonoff function induction.pdf' is in the same notes folder) and rename: §7.2 'A two-sided bound', prop:ood:draftfalse 'The literal two-sided bounds fail'; state the literal bounds in a displayed formula before refuting them.

**P1-ARX-09** [major] `paper/sections/{setting,versions,hist,ood,nn,steeper,examples}.tex` — e.g. setting.tex:4, hist.tex:28, hist.tex:62, nn.tex:8, nn.tex:33, examples.tex:7, ood.tex:7, ood.tex:153, steeper.tex:6, steeper.tex:14

- *Problem.* Verbatim quotations of informal, lower-case working notes ('you have a bunch of input-output pairs. you have the usual prior on all programs. solomonoff function induction := ...', 'I'm pretty sure Solomonoff induction gets unbounded loss on this sequence. I don't actually have a proof', 'kinda like a circuit version of solomonoff function induction', 'doing sth more like a polyfit') are not formal academic register (binding note: 'Tone: formal academic register'). In a sole-authored paper they read as the author quoting his own chat messages.
- *Evidence.* PDF §2 first paragraph and §5.2, §9 first sentence.
- *Fix.* Paraphrase each in one formal sentence with a citation ([Hän26]); keep at most one short quotation where the exact wording matters (e.g. the definition of SFI in §2).

**P1-ARX-10** [major] `paper/sections/intro.tex` — lines 26-53 (tab:intro:verdicts and the sentence introducing it); learn.tex:87 ("This refutes the fresh-noise form of the supervised-learning hypothesis H7 ... (tab:intro:verdicts)")

- *Problem.* A table of 'the ten working hypotheses with which this study began' (H1-H10) with 'verdicts' is an internal research-process artefact (binding note; the review brief lists 'H1-H10 verdict tables' explicitly). It also duplicates the contributions list and costs a full page.
- *Evidence.* PDF p. 6 Table 1 'The working hypotheses H1-H10, paraphrased, with verdicts'; learn.tex:87 cites it.
- *Fix.* Delete the table, the sentence 'Table 1 lists the ten working hypotheses ...', and learn.tex:87's H7 sentence. Fold the two facts that are not already in the contributions list into it: (a) the weak-versus-machine refutation (rem:setting:h1a), (b) the H7 fresh-noise caveat (already in bullet 3).

**P1-ARX-11** [major] `paper/main.tex; paper/sections/app-verification.tex` — main.tex: \input{sections/app-verification}; Appendix I (pp. 96-103)

- *Problem.* The verification appendix ('How the claims were checked': roles, tracks, referees, corrections table with M/m item numbers, cross-track conflicts C1-C25, reproduction recipe, unresolved points) is required to be dropped by the binding note, and is 7.5 pages of process vocabulary.
- *Evidence.* Appendix I, e.g. 'Five research tracks, each one instance', 'An adversarial referee per track', 'resolved 25 cross-track conflicts', Table 9 'Corrections'.
- *Fix.* Drop the \input. Move: (1) environment (Python 3.11.15, numpy 2.4.6, scipy 1.17.1, mpmath 1.3.0) and the statement that every computation is seeded/deterministic and reproduces its saved output into 'Code and data'; (2) the reproduction recipe into the repository README (not the paper); (3) the account of how the paper was prepared into the existing acknowledgements paragraph (see issue on acknowledgements); (4) proof-sketch and conditional statuses (I.4) into the statements themselves (see conversion table); (5) open problems: already in §12; (6) literature caveats: resolved by verifying references (§5 of this review), not by a disclaimer; (7) the corrections table and conflicts: delete (the corrections that inform the reader are already stated where they occur).

**P1-ARX-12** [major] `paper/preamble.tex; all section files` — \status{...} and \src{...} on 187 of 203 theorem-like environments; inline \status in prose at setting.tex:40, app-versions.tex:92, app-versions.tex:102; inside tables at app-examples.tex:133 (tab:ex:cycle) and app-examples.tex:164 (tab:ex:eisenstat)

- *Problem.* Status tags ('[proved; computed (context c7)]', '[known; unverified (claimed in the slides)]', '[refuted]') and grey source notes ('foundations Thm 6.1; F20-F23') are printed in the PDF. The binding note requires none in the final PDF. Simply redefining the macros to no-ops is not enough for 16 environments whose status carries mathematical information (proof sketch, conjecture, conditional, refuted): those need rewording (conversion table, §4 of this review).
- *Evidence.* PDF: 151 occurrences of '[proved', e.g. 'Theorem 4.1 (dominance). [proved] foundations Thm 6.1'; p. 85 table 'Table ... [computed] examples §2.6; checks e3, e6'.
- *Fix.* Conversion: (1) apply the rewordings of the conversion table (130 rows) first; (2) then delete every \status{...} and \src{...} from the sources (do not just redefine them: \src arguments contain process vocabulary that would remain in the .tex shipped to arXiv); (3) remove the two macro definitions from preamble.tex; (4) grep the final .tex and PDF for 'track', 'referee', 'ledger', 'notes-final', 'brief', 'unverified', 'snippet', 'not checked', 'H[0-9]', 'c[0-9]', 'r[0-9]', 'e[0-9]' as a final check.

**P1-ARX-13** [major] `paper/sections/{setting,learn,app-setting,app-versions,app-learn}.tex` — setting.tex:44 "(c1)", :119 "(c3)", "(context c3)", :156 "(c9(c))"; learn.tex:49 "foundations r6", :87 "(foundations c5)", :108 and :112 "(foundations r12)"; app-setting.tex:115 "check c6", :117 "(c1 checks ...; r1 also k=3)", :125 "(c9(b))", "(c9(b) for k<=4; r1)", :151 "(c10(a4))", :154 "Check c10 ... (r13: 300 of 300)", :166 "(c10(b) checks ...)"; app-versions.tex:35, :60, :86, :99, :102 (c2, c8(a)-(d), r11); app-learn.tex:141 ("Foundations: c4 ... r6 ... Context: c3, c4, c7")

- *Problem.* Visible identifiers of internal check scripts (cN, rN, track names) in the running text. They are meaningless to a reader and are process vocabulary. (Sections ex, ood, comp, nn already use the correct form 'a direct computation (code in the accompanying repository)'.)
- *Evidence.* PDF §2.4: 'semimeasure probability 1/4 in both orders (c3). On a random six-point mixture ... (context c3)'; §4.2: 'in a finite analogue, foundations r6'.
- *Fix.* Replace each by 'a direct computation (code in the accompanying repository) confirms ...' or delete the parenthesis. Rewrite app-learn.tex:141 as 'Computations. All numbers in Section 4 and here come from seeded or deterministic scripts in the accompanying repository: dominance and order independence on finite mixtures over four inputs; ...' (descriptions without identifiers), mirroring app-examples.tex:237.

**P1-ARX-14** [major] `paper/sections/{setting,versions,learn,hist,comp,nn,related,discussion,intro,app-setting,app-versions,app-learn}.tex` — setting.tex:12 ("without re-checking the sources"), :40, :175; versions.tex:21 ("abstract only seen", "search snippet only"); learn.tex:49 ("source not checked"), :77 ("not checked"), :171 ("A table-of-contents snippet shows ... We have not read these sections"); hist.tex:127 ("abstract seen only"; "we have not checked whether ..."), :135, :157; comp.tex:128 ("we have not checked them"); nn.tex:62, :73, :81 ("the rest is unchecked"), :91 ("These descriptions follow the abstracts"); related.tex:6, :8, :10, :12; discussion.tex:13; intro.tex:9, :55, :57; app-setting.tex:81, :132; app-versions.tex:92, :102; app-learn.tex:106, :129, :133

- *Problem.* About 35 visible hedges describing the research process ('we have seen only the abstract', 'search snippet only', 'not checked against the source', 'we have not read these sections'). They are not standard academic form, and the binding note requires verified references instead of printed caveats. Where the hedge protects a content claim that was never verified, deleting it would create an unsupported claim.
- *Evidence.* See the process-vocabulary table (§4.2 of the review) for each sentence.
- *Fix.* For each: (a) bibliographic facts are now verified (§5) -> delete the caveat; (b) content claims about a cited work: either verify against the source (Solomonoff 2008, Hutter 2005/2007, Lattimore-Hutter 2013 and Lattimore-Hutter-Gavane 2011 are obtainable) and state them plainly, or rephrase as the paper's own reading ('We read operator induction [Sol08] as ...'), or drop the sentence; never keep 'abstract seen only'.

**P1-ARX-15** [major] `paper/sections/{versions,related,discussion}.tex; app-hist.tex` — versions.tex:20-22 rem:versions:operator; related.tex:6; discussion.tex:13; app-hist.tex:176 prop:hist:operator

- *Problem.* The identification 'operator induction = per-query mixture M_pq' rests on a search snippet of a secondary source (Özkural 2017), whose abstract does not concern operator induction; the primary source was seen only at abstract level. The conclusion 'So operator induction and M_prod coincide only on distinct inputs' and 'x-only dominance on distinct inputs is then Solomonoff's' are stated flatly. Once the hedges are deleted in the conversion, these become unsupported claims about Solomonoff's work.
- *Evidence.* Status of rem:versions:operator: 'known; unverified; equality on distinct inputs proved'; prop:hist:operator: 'proved, given the unverified description'; bib comment of ozkural2017ultimate: 'the product formula for operator induction seen in a snippet only'.
- *Fix.* Before submission, read Solomonoff (2008) (freely available from raysolomonoff.com) and cite the formula from it; or reformulate everything as statements about M_pq with one sentence 'We read Solomonoff's operator induction [Sol08] as the per-query mixture M_pq'. Drop the two Özkural citations as sources of the formula.

**P1-ARX-16** [major] `paper/sections/{intro,hist,related,discussion}.tex` — intro.tex:9 and :55; hist.tex:135 (after cor:hist:H4); related.tex:8; discussion.tex:13

- *Problem.* The relation of SFI^hist / M_H to Hutter's universal chronological semimeasure is described as 'known, but not checked against the sources', 'expected but was not checked', and 'prior work in substance'. The arXiv version cannot carry these process hedges, but replacing them by 'M_H agrees with Hutter's xi up to constants' would claim more than the sources (CLAIMS.md C13: 'Hutter identification known but unverified').
- *Evidence.* cor:hist:H4 status 'proved; identification known (unverified)'; hist.tex:135.
- *Fix.* Write: 'Chronological semimeasures and their universal mixture were introduced by Hutter [Hut00, Hut05] for the AIXI model, with finite alphabets; Corollary 5.18 shows that M_H is universal in this class for countable alphabets. Hutter also lists supervised learning from examples among AIXI's problem classes [Hut00, Hut07].' Do not assert equality with Hutter's construction unless the author checks [Hut05].

**P1-ARX-17** [major] `paper/sections/related.tex` — rem:related:new (lines 16-19)

- *Problem.* A 'Remark' titled 'what exists and what appears new' that begins 'At the level of a search that saw abstracts and secondary sources only' and ends with an instruction to the authors ('Each of these should be checked against [Sol08], [Hut05] and [LH13] before any claim of novelty'). This is process text, not a paper statement, and it carries a status tag 'known (snippets; unverified)'.
- *Evidence.* PDF p. 50, Remark 11.1.
- *Fix.* Do the three checks (the sources are obtainable). Then replace the remark by a two-sentence 'Novelty' paragraph without process vocabulary, e.g. 'To our knowledge the name and the function-machine formulation are new, as are the separations of Section 5, the OOD results of Section 7 and the time-bounded mixtures of Section 8.1; the per-query mixture, the universal chronological semimeasure, Occam/PAC-Bayes/online-to-batch bounds and the conjunction ladder are not.' If the checks are not done, keep only the first clause about the name.

**P1-ARX-18** [major] `paper/sections/{hist,comp}.tex` — thm:hist:minimax (hist.tex:96-99); thm:comp:timebounded(b) (comp.tex:20-25); prop:comp:round last sentence (comp.tex:36); prop:comp:history last clause (comp.tex:63)

- *Problem.* Parts that are only proof sketches are stated inside Theorem/Proposition environments. Today only the status tag says so; after the tags are removed, these statements would be presented as fully proved (binding note: 'the statement must not be presented as fully proved').
- *Evidence.* thm:hist:minimax status '(a) proved; (b) proved for reveal laws that do not see f, proof sketch for those that do'; the theorem text explicitly allows reveal laws that see f|A_n in case (b). thm:comp:timebounded '(b) proof sketch'; prop:comp:round 'running time proof sketch'; prop:comp:history 'running time proof sketch'.
- *Fix.* Split each: the environment states only what is proved (minimax (b) only for reveal laws that do not see f; time-bounded (a) only; round/history: regret only). The rest goes into a Remark with a paragraph labelled 'Proof sketch.' and the sentence 'We do not write out the machine model and the cost of the clocks.' (exact wording in the conversion table rows for these labels).

**P1-ARX-19** [major] `paper/sections/ood.tex` — conj:ood:natural (lines 177-182)

- *Problem.* A Conjecture environment whose next sentence says 'This is not a precise statement'. A conjecture in an arXiv paper must be a precise mathematical statement; this one is a research direction.
- *Evidence.* ood.tex:182 'This is not a precise statement, and by Proposition 7.4 it fails for some universal machines'.
- *Fix.* Remove the environment; add an item to the Open Problems list of §12: 'Find conditions on a reference machine and on training sets under which SFI gives the intended answers of Example 7.16 with posterior probability close to 1; by Proposition 7.4 no such statement holds for all universal machines.'

**P1-ARX-20** [major] `paper/sections/{setting,versions,hist,examples,ood,comp,nn}.tex; discussion.tex; intro.tex` — 13 "\paragraph{Open question.}\label{q:...}" (setting x4, versions x2, hist, examples x2, ood, comp x2, nn); references in intro.tex:57 and discussion.tex:17-23

- *Problem.* Open questions are unnumbered paragraphs with labels; every cross-reference to them prints the number of the enclosing subsection, so the reader is sent to 'Section 2.3' or 'Sections 2.4 and 6.3' instead of to a question. The Open Problems list in §12 thus points at sections.
- *Evidence.* PDF p. 5: 'whether MF dominates every lower-semicomputable law of a random partial function (Section 2.3); ... several lower bounds in the normalised convention (Sections 2.4 and 6.3)'. Appendix I.7 records this as unresolved.
- *Fix.* Define \theoremstyle{definition}\newtheorem{question}[theorem]{Open question} (or number the items of the §12 list and label those), convert the 13 paragraphs, and make §12's list the single home with back-references.

**P1-ARX-21** [major] `paper/sections/app-learn.tex` — rem:learn:cesaro (lines 117-120)

- *Problem.* A remark that records an internal correction: 'An earlier version of the context notes read Proposition 4.13 as ...'. The binding note: refuted earlier claims appear only where they inform the reader; no list of internal corrections; no 'notes'.
- *Evidence.* app-learn.tex:119.
- *Fix.* Delete, or rewrite as an informative remark: 'Proposition 4.13 should not be read as matching the O(1/n) Cesàro bound up to log^2 n: it is a per-step lower bound, whereas Theorem 4.5 bounds an average; indeed sum_k E e_k <= (ln 2)(K(f)+c), so liminf_k k E e_k = 0. Corollary 4.14 gives the per-step comparison.'

**P1-ARX-22** [major] `paper/sections/app-setting.tex` — line 132, paragraph heading "Reformulation (proof sketch; foundations Problem 3.6)." and "(quoted, not checked against the source)"; line 134

- *Problem.* A printed heading containing a track name and an internal problem number; the paragraph also says 'Two steps are not written out ... An adversary argument ... was tried and settled neither direction'.
- *Evidence.* PDF Appendix A.6 heading 'Reformulation (proof sketch; foundations Problem 3.6).'
- *Fix.* Heading 'A sufficient condition (proof sketch).'; cite Strassen as 'by Strassen's theorem on monotone couplings for finite partially ordered sets [Str65]'; replace the last paragraph by 'We do not carry out the reduction from general lower approximations to finite rational laws.' and delete the sentence about an attempted adversary argument.

**P1-ARX-23** [major] `paper/sections/versions.tex` — tab:versions:compare caption (line 123)

- *Problem.* Caption contains '(Hänni's later request)' and 'Source: foundations Table 4.12.'
- *Evidence.* PDF p. 16, Table 2 caption.
- *Fix.* Caption: 'The Kolmogorov and semimeasure versions compared, for data sets with inputs of length at most d; gaps in bits. Every entry is proved where cited; by Remark 3.12 no computable family exhibits a gap larger than K(k)+O(1) in any row.'

**P1-ARX-24** [major] `paper/bib/core.bib; paper/sections/steeper.tex` — key hanni2026lesswrong; steeper.tex:6 \citep{hanni2026notes,hanni2026lesswrong}

- *Problem.* The LessWrong entry lists 'Kaarel Hänni and Cole Wyeth' as authors of 'Comments in the thread "Jonas Hallgren's Shortform"', year 'undated', note 'Text as pasted by K. Hänni'. Wyeth thereby appears as co-author of a source cited in the sentence that introduces the steeper-prior proposal, directly before the paragraph 'The absorption objection'. The binding note allows at most one neutral footnote recording that the point was raised in the thread, and forbids naming the objection after Wyeth. The entry is also bibliographically wrong (co-authorship of a comment thread) and unverifiable (page not reachable, no search hit, no date).
- *Evidence.* PDF p. 47: '(Hänni, 2026b; Hänni and Wyeth, undated)'; p. 54 bibliography entry.
- *Fix.* Remove hanni2026lesswrong from steeper.tex:6 (the proposal is in [Hän26]). If the thread is to be mentioned, add one footnote to the absorption paragraph: 'The point was also raised in a LessWrong discussion [ref].' with an entry whose author is the thread owner or 'LessWrong', with the comment date, and without quoting anyone. Never print 'undated' or 'Text as pasted'.

**P1-ARX-25** [major] `paper/bib/core.bib` — keys hanni2026notes, vaintrobhanni2026nnbayes

- *Problem.* hanni2026notes prints as 'Kaarel Hänni. notes. Public repository of working notes, https://github.com/kaarelh/notes, 2026b. Accessed October 2026.' (title 'notes'). vaintrobhanni2026nnbayes points to kaarelh.github.io/ai/nnbayes-generalization.pdf, which could not be reached, and no search finds the title or an ILIAD listing; it is the source of all claims of §9 marked 'claimed in the slides' and of the conjunction-ladder construction.
- *Evidence.* WebFetch of github.com/kaarelh/notes: repository exists (MIT, 'some of my notes from 2023-2026'); the SFI note is ai/learning/solomonoff induction/solomonoff function induction.md and .pdf. Slides: no hit (a Fields Institute talk of 21 Apr 2026 by Vaintrob on the joint work exists).
- *Fix.* hanni2026notes: title = {Solomonoff function induction}, howpublished = {Note in the repository \url{https://github.com/kaarelh/notes}, folder ai/learning/solomonoff induction}, year = {2026}. Slides: the author (a co-author) confirms the exact title, venue and date and that the URL is public before submission; otherwise cite as 'D. Vaintrob and K. Hänni, slides of a talk, 2026, available from the authors' and keep only what is needed.

**P1-ARX-26** [major] `paper/sections/discussion.tex` — Acknowledgements, line 31

- *Problem.* The disclosure paragraph uses process vocabulary ('developed in five groups', 'Each group's notes ... were checked by a separate instance ... acting as an adversarial referee') and ends with 'The literature was searched only through a web-search tool that returned excerpts; most cited works were not read in full, and the text says so where it relies on them'. The binding note wants a short account of how the paper was prepared and checked, and verified references instead of caveats; after the conversion the text will no longer 'say so where it relies on them'.
- *Evidence.* discussion.tex:31.
- *Fix.* Replace by: 'This paper was developed and written with extensive assistance from Claude (Anthropic), an AI system. Working from the author's notes [Hän26] and under his direction, Claude produced the proofs, the computations and the text. Each part was checked by further, independent instances of the system, which re-derived the proofs and re-implemented the computations; the author reviewed the results. No human has yet independently checked all of the mathematics, and readers should weigh the results accordingly.' Add: 'The coin example of Section 6.3 is due to Sam Eisenstat (personal communication).'

**P1-ARX-27** [major] `paper/sections/discussion.tex` — Code and data, line 34

- *Problem.* The statement points to 'research/tracks/*/checks/' and 'research/tracks/*/referee_code/' (process vocabulary in printed paths) and does not give the software environment (which is only in Appendix I).
- *Evidence.* PDF p. 52.
- *Fix.* 'Code and data. All computations were done with seeded or deterministic Python scripts (Python 3.11, numpy 2.4, scipy 1.17, mpmath 1.3), available with their saved outputs at https://github.com/kaarelh/AI-works, folder solomonoff-function-induction/ (see its README for the list of scripts and the command that re-runs them).' If the folder names cannot change, refer to the README rather than to the paths.

**P1-ARX-28** [major] `paper/main.tex (whole paper)` — 103 pages: main text pp. 3-52, references pp. 52-57, appendices pp. 57-103; 203 theorem-like environments

- *Problem.* Far longer than a typical arXiv paper in learning theory / algorithmic information theory (usually 20-40 pages of main text plus appendices, often 40-70 pages in total). The length comes from breadth (12 sections, 9 appendices) and from many secondary remarks, not from long proofs. The page budget in OUTLINE.md (38 + 35.5) is already exceeded by 12 pages in the main text, as Appendix I.7 admits.
- *Evidence.* Page counts from main.toc: Intro 4.5, §2 5, §3 5, §4 5, §5 6, §6 6, §7 5, §8 4.5, §9 4, §10 2, §11 1, §12 2.5; App. A 7, B 4, C 6, D 8, E 7, F 2, G 4, H 1, I 7.5.
- *Fix.* Target <= 40 pages of main text and <= 30 of appendices (§6 of the review gives a cut list): drop App. I (-7.5) and Table 1 (-1); shrink §10 to one paragraph in §12 (-1.7); cut or move to appendices rem:versions:prediction/rem:versions:answer overlap (-1), rem:learn:ideal, rem:learn:hutterEX (to §11), rem:learn:positive, rem:learn:interventions, rem:learn:relations, rem:versions:hashing, rem:comp:apples, rem:comp:gap, rem:nn:rigorous, rem:nn:literature (to §11), rem:ood:answer (merge into §12), tab:ood:hanni; consider moving §8-§9 (computable versions, NN Bayes; 8.5 pp main + 5 pp appendix) to a separate short paper or to the companion.

**P1-ARX-29** [major] `paper/sections/intro.tex` — lines 15-24 (Contributions) and line 59 (Reader's guide)

- *Problem.* The contributions list is eight dense bullets of 5-8 lines with up to six cross-references each; it summarises nearly every result rather than stating the main contributions. The 'semimeasure convention', used in the abstract and in four bullets, is only defined in the Reader's guide at the end of the introduction.
- *Evidence.* intro.tex:19-21 use 'semimeasure convention' / 'normalised convention'; the definition is at intro.tex:59.
- *Fix.* Move the two-convention explanation (2-3 sentences) before the contributions list; cut the list to 5-6 bullets of 2-3 lines naming the main theorems (universality and invariance; no coding theorem for function programs; pathwise dominance and online-to-batch with the fresh-noise caveat; order-blindness and SFI^hist; the two worked examples; OOD bounds), and move the detail to the sections.

**P1-ARX-30** [major] `paper/sections/related.tex` — whole section (lines 4-19)

- *Problem.* Related work is one page, placed after all results and the companion-paper summary, and most sentences are hedged ('we have seen only the abstract', 'we have not checked', 'we have not examined'). Primary sources for Solomonoff induction itself are missing (only Li-Vitányi and Solomonoff 1978/2008 are cited), and the Discussion repeats the related-work paragraph ('Relation to the literature').
- *Evidence.* related.tex:6-12; discussion.tex:13.
- *Fix.* Move related work to §2 (after the introduction) or merge it with discussion.tex:13 into one section; remove hedges after verification; add the primary SI references (e.g. Solomonoff 1964, Information and Control 7; Hutter 2005 already cited) and a sentence on Gold-style identification vs Bayesian prediction; move rem:nn:literature and rem:learn:hutterEX into it.

**P1-ARX-31** [major] `paper/sections/abstract.tex; paper/main.tex` — abstract line 3; main.tex \tableofcontents\newpage

- *Problem.* Page 1 consists of the title, a 248-word abstract that lists ten results with undefined symbols (K(dom D), d, K in 'O(K/n)', 'semimeasure convention', 'universal chronological semimeasure', 'reveal orders') and no motivating sentence, and the start of a full-page table of contents; the introduction starts on page 3.
- *Evidence.* PDF pp. 1-2.
- *Fix.* Abstract: open with one sentence of motivation (SFI as an ideal of supervised learning, analogous to Solomonoff induction for sequences), then 4-5 main results in words (no undefined symbols), then the order-blindness/SFI^hist point, then one sentence on the companion paper. Drop \newpage after the TOC (or the TOC itself) so the introduction starts on page 2.

**P1-ARX-32** [minor] `paper/sections/intro.tex` — line 19 "its exact relation to SI on the interleaved sequence is in Theorem 5.20 and Proposition 5.21"

- *Problem.* 'exact' overstates: the relations hold up to additive constants, the identity needs a deterministic input policy, and whether L_M^joint = L_H + L_in^x ± O(1) is open.
- *Evidence.* thm:hist:si; prop:hist:inputloss; q:hist:open (iv).
- *Fix.* 'its relation to SI on the interleaved sequence ...'.

**P1-ARX-33** [minor] `paper/sections/abstract.tex` — line 3: "agree up to K(dom D) bits"; "does not depend, up to a constant factor, on the universal machine or on computable encodings"; "has risk O(K/n)"; "SFI cannot use the order of the data"

- *Problem.* Small imprecisions: the chain holds up to K(dom D)+O(1); invariance under an encoding (alpha,beta) costs a factor 2^{K(alpha,beta)+O(1)} that depends on the encoding; 'K' in O(K/n) is undefined; order-blindness is proved for the semimeasure-convention loss (normalised predictions can depend on the order; open for MF).
- *Evidence.* thm:versions:chain; thm:setting:invariance(b); thm:learn:batch(a); prop:setting:order, prop:setting:normalise(b).
- *Fix.* 'agree up to K(dom D)+O(1) bits'; 'up to a factor depending only on the encoding'; 'risk O(K(f)/n), where K(f) is the complexity of the labelling function'; 'SFI's cumulative loss does not depend on the order of the data'.

**P1-ARX-34** [minor] `paper/sections/intro.tex` — line 22: "makes 2^{Ω(ℓ/log ℓ)} mistakes on some ordering for a target of description length ℓ"

- *Problem.* Reads as a statement about every target of description length ℓ; the theorem is about one target family (the conjunction of d variables, ℓ = Θ(d log d)).
- *Evidence.* thm:comp:ladder.
- *Fix.* '... makes 2^{Ω(ℓ/log ℓ)} mistakes on some ordering for the conjunction of d variables, whose description length is ℓ = Θ(d log d)'.

**P1-ARX-35** [minor] `paper/sections/{setting,learn}.tex` — setting.tex:135 rem:setting:recommend, :143 thm:setting:invariance(c), :151 thm:setting:coding(b)

- *Problem.* Section 2 uses W, K_F, M_prod, M_pq and M^w before Section 3 defines them (forward references to def:versions:variants).
- *Evidence.* thm:setting:coding(b) '... with K_F the shortest consistent program (Definition 3.1)'.
- *Fix.* Either move def:versions:variants into §2.2 (it is three lines) or move thm:setting:invariance(c), the K_F part of thm:setting:coding(b) and rem:setting:recommend to §3.

**P1-ARX-36** [minor] `paper/sections/learn.tex` — prop:learn:curve, line 105: "for w = 1/16, r_0 = 0.912"

- *Problem.* Rounding: r_0 = log2(32/17) = 0.91254, which rounds to 0.913.
- *Evidence.* scratch/p1-arxiv-r2/numbers_check.out: 'r0=0.913 r1=1.544'.
- *Fix.* Write r_0 = 0.913 (or 0.9125).

**P1-ARX-37** [minor] `paper/sections/discussion.tex` — line 5 ("In exchange, ...", "are each a precise statement, not a caveat"); line 26 ("a universal hypothesis absorbs everything instead")

- *Problem.* Rhetorical or informal phrasing in the Discussion.
- *Evidence.* discussion.tex:5, :26.
- *Fix.* 'Moreover, for a computable target f ...'; delete 'are each a precise statement, not a caveat'; 'a universal hypothesis is selected and fits the data as well as the universal mixture (the absorption theorem of [Hän26a])'.

**P1-ARX-38** [minor] `paper/sections/nn.tex` — rem:nn:rigorous (line 86): "the Gaussian-process limits fail on sparse and odd parities where SFI succeeds"

- *Problem.* For sparse parities the failure is in averaged squared error over random targets (cor:nn:separation), and the text after it says 'we do not claim a 0-1 version in general'; only the bias-free two-layer ReLU case has an exact 0-1 failure.
- *Evidence.* cor:nn:separation; nn.tex:69.
- *Fix.* 'the Gaussian-process limits need n >= (1-ε)C(d,k) samples for squared error ε on random k-sparse parities, where SFI needs O(k log d/ε), and bias-free two-layer ReLU kernels never learn odd parities of size >= 3'.

**P1-ARX-39** [minor] `paper/sections/comp.tex` — line 54 "This is Hänni's \"Remark 4\""; hist.tex:12 and :62 "(\"Thm 1\")"

- *Problem.* References to item numbers of unpublished notes.
- *Evidence.* comp.tex:54; hist.tex:12, :62.
- *Fix.* 'This answers a question in [Hän26]'; 'the dominance theorem of [Hän26]'.

**P1-ARX-40** [minor] `paper/sections/app-versions.tex` — rem:versions:hashing title (line 55) "The hashing bound, superseded"

- *Problem.* 'superseded' describes the research history.
- *Evidence.* app-versions.tex:55.
- *Fix.* Title 'A hashing bound'; first sentence 'Proposition 3.6(b) is stronger'. Consider deleting the remark and its proof (1 page).

**P1-ARX-41** [minor] `paper/bib/*.bib` — day2011increasing, orseau2013universal, wood2013non, vovk1990aggregating, barzdin1972prediction, case1983comparison, hoeffding1963probability, grunwald2007suboptimal, kleitman1973families, ville1939etude

- *Problem.* Incomplete or unconfirmed bibliographic data in otherwise verified entries; Barzdin-Freivalds prints without pages, Day without volume and pages, Wood et al. without volume.
- *Evidence.* WebSearch results recorded in scratch/p1-arxiv-r2/bib_log.md (e.g. AMS issue listing: Trans. Amer. Math. Soc. 363(10) (2011) 5577-5604; Springer: ALT 2013 = LNCS 8139).
- *Fix.* Apply the corrections of the bibliography table (§5): Day 363(10):5577--5604; Orseau et al. volume 8139; Wood et al. volume 7070, ed. Dowe; Vovk 1990 pp. 371--383; Barzdin-Freivalds pp. 1224--1228; Case-Smith no. 2; Hoeffding no. 301; Grünwald-Langford no. 2--3 and doi; Kleitman-Spencer no. 3; Ville: confirm the Gauthier-Villars imprint or cite the thesis record.

**P1-ARX-42** [minor] `paper/bib/related.bib; paper/bib/setting.bib` — ozkural2015ultimate, ozkural2017ultimate

- *Problem.* Bibliographic data verified, but both are cited only as secondary sources for the operator-induction formula, which no search confirmed to be in them (2015's abstract is about physical measures of intelligence).
- *Evidence.* bib comments; WebSearch on both arXiv records.
- *Fix.* Drop both once the formula is cited from Solomonoff (2008) (see the operator-induction issue).

**P1-ARX-43** [minor] `paper/bib/core.bib` — claude2026whatfollows, claudeSFI2026fundamentals (uncited in Paper 1); claudeSFI2026steeper

- *Problem.* claude2026whatfollows has author '{Claude (Anthropic)}' and 'Unpublished report prepared for K. Hänni' -- incompatible with the authorship rule if any paper cites it; the companion entry prints 'Companion paper, draft ... Folder ... of GitHub'.
- *Evidence.* core.bib; PDF p. 54.
- *Fix.* Paper 1: nothing to do for the two uncited keys (BibTeX drops them). Companion: cite by arXiv identifier once posted, else 'In preparation'.

**P1-ARX-44** [minor] `paper/NOTATION.md` — §3.1 row \nulen

- *Problem.* NOTATION.md defines the shared-coin law as F(x) = omega_{|x|}; the paper (correctly) uses omega_{|x|+1}. Paper 2 must use the same indexing.
- *Evidence.* versions.tex:61; app-verification.tex:177.
- *Fix.* Update NOTATION.md and check paper-steeper for omega_{|x|}.

**P1-ARX-45** [minor] `paper/sections/app-examples.tex` — tab:ex:cycle (line 133), tab:ex:eisenstat (line 164)

- *Problem.* \status{computed}\src{examples §2.6; checks e3, e6} and '...check e2, seed 20261011' are typeset inside the table floats.
- *Evidence.* PDF Appendix E tables.
- *Fix.* Delete; put the seed into the caption only if useful ('simulation with a fixed seed; code in the accompanying repository').

**P1-ARX-46** [minor] `paper/sections/{versions}.tex` — rem:versions:prediction (lines 127-135) and rem:versions:answer (lines 137-145)

- *Problem.* The two remarks and the table repeat each other (the K_F gap, the W gap, the K(dom D) agreement, deterministic targets).
- *Evidence.* versions.tex:127-145.
- *Fix.* Merge into one remark 'What the gaps mean' of at most half a page.

**P1-ARX-47** [minor] `paper/sections/learn.tex` — rem:learn:ideal (lines 163-167)

- *Problem.* Repeats the introduction's 'Why SFI' paragraph and the Discussion's first paragraph almost item by item.
- *Evidence.* intro.tex:7; discussion.tex:5.
- *Fix.* Keep it here (it has the references) and shorten the other two to one sentence each pointing to it.

**P1-ARX-48** [minor] `paper/sections/intro.tex` — line 59, Reader's guide: "Section 3 answers the question of the Kolmogorov and semimeasure versions"

- *Problem.* 'the question' refers to the request.
- *Evidence.* intro.tex:59.
- *Fix.* 'Section 3 compares the Kolmogorov and semimeasure versions'.

**P1-ARX-49** [major] `paper/main.tex; paper/preamble.tex; paper/sections/*.tex; paper/bib/*.bib` — LaTeX comments, e.g. main.tex lines 5-6 and 44-46, the first lines of every section file, the "% unverified: ..." comments in bib/*.bib

- *Problem.* arXiv distributes the LaTeX source. The comments name the research process and internal files ('Plan: OUTLINE.md; ledger: CLAIMS.md', 'framing editor', 'binding note', '% Sources: research/tracks/foundations/notes-final.md', '% unverified: the LessWrong page did not resolve from the research environment'). They are invisible in the PDF but public in the source tarball.
- *Evidence.* main.tex:5-6 '% Paper 1. Plan: OUTLINE.md; ledger: CLAIMS.md; notation: NOTATION.md.'; setting.tex:1 '% Section 2 (writer: setting). Sources: research/tracks/foundations/notes-final.md (F) ...'.
- *Fix.* Prepare the arXiv tarball from a cleaned copy: strip all comments (e.g. with arxiv_latex_cleaner or a sed pass), include the generated main.bbl instead of bib/*.bib and merge_bib.py, and omit build logs, build-test/ and test-section.sh.
