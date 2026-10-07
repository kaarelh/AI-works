# Citation and attribution review

Reviewer lens: bibliography and attributions. This is a report only; no source file was edited.

Scope:
* all 262 entries of `paper/bib/all.bib`, traced back to the `paper/bib/<section>.bib` file that `merge_bib.py` keeps (the first file in sorted order);
* every `\cite*` in `paper/sections/*.tex` (about 520 citing lines), with the attribution read in context;
* the rendered bibliography (`main.bbl`) and the compiled text (`research/paper-review/main.txt`).

## 1. Summary

The bibliography is in good shape. **No entry looks hallucinated.** Every one of the 262 entries is a real publication with the right authors, title, venue and year. I checked 26 of the less-common entries by web search (search snippets; publisher sites were mostly blocked) and the rest from knowledge. The remaining problems are structural, plus a few attribution nuances:

1. **Four papers appear twice in the reference list** under different keys. They render with spurious year suffixes: "Rivest and Sloan, 1988a/1988b", "El-Yaniv and Wiener, 2010a/2010b", "Li et al., 2008a/2008b" and "Cohen, 1981a/1981b". A reader will assume eight distinct works. Three of the duplicates come from `bib/search.bib` and are cited only in `search.tex:86`; the fourth comes from `bib/philosophy.bib` and is cited in `philosophy.tex:50`. The two Cohen copies also disagree on pages. **(major)**
2. **One attribution misdescribes the cited theorems.** `philosophy.tex:24` says Daniels' independence constraint "is, formally, the conditional-independence assumption that the coherence impossibility theorems show to be necessary". The impossibility theorems (Bovens–Hartmann, Olsson) are proved *given* independence. What shows independence is needed is the paper's own Remark `rem:coherence:consensus` (no amplification under a common cause). Daniels' constraint is about disjoint sets of supporting judgments, so "is, formally" overstates the match. **(major)**
3. **Five "as we recall / unchecked" hedges** sit in the published text: Rautenberg, Lange–Zeugmann, Vereshchagin–Vitányi, Armstrong–Mindermann, and the theorem numbering of Garrabrant et al. Web search confirms four of them (Lange–Zeugmann only in substance), so the hedges can be replaced by precise attributions. **(minor)**
4. **Small attribution nuances:**
   * Edgington's use of the Adams bound is in terms of verities, not "over precisifications".
   * Tennenbaum's separate non-recursiveness of + and × is the Kreisel/McAloon strengthening.
   * "Post's hierarchy theorem" is a non-standard name, used uncited four times.
   * Sequent-style natural deduction is Gentzen 1936, not 1935.
   * The Zermelo quotation is an English translation with no source.
   * Rawls is never cited for (narrow/wide) reflective equilibrium.
   * The history table (`tab:informal:history`) cites nothing.
   * Lean 4, Mathlib and scikit-learn are uncited.

   **(minor)**
5. **Metadata:** one wrong page range (Rivest–Sloan, 635–640 not 635–639), plus missing pages and numbers in about 25 entries. **(minor)**

No `\cite` is undefined (`main.log` has 0 undefined citations; `main.blg` has 0 warnings). Two entries, `jiang2023draft` and `azzouni2004derivation` (both in `bib/informal.bib`), are never cited. BibTeX drops them, so they are harmless.

## 2. How `merge_bib.py` interacts with fixes

`merge_bib.py` keeps the **first** definition of each key in sorted filename order and silently drops the others. Keys that are defined in several files have identical content up to name formatting. I diffed all 63 multiply-defined keys, and only cosmetic differences appear: author-name order, a missing `number`, "The Journal of Philosophy" against "Journal of Philosophy", and a NeurIPS volume. **A correction must therefore be made in the first file**, or it is ignored. Examples:

* `rivest1988learning`: `caution.bib` wins over `setting.bib`;
* `plotkin1970note`: `caution.bib` wins over `experiments.bib`, `search.bib`, `setting.bib` and `twotier.bib`;
* `gold1967language`: `caution.bib` wins over five others.

Section 6 gives the first-defining file for every key. The four duplicate *papers* above are a different problem. They use different keys, so the merge keeps both copies.

## 3. Duplicated papers (rendered twice)

Confirmed in `main.bbl` and in the compiled text (main.txt lines 857–858, 1276–1277, 1316, 1411, 1628, 1896, 4224, 4790 and 8186–8613):

| paper | key kept for use | duplicate key (file) | cited at |
|---|---|---|---|
| Rivest & Sloan, AAAI-88 | `rivest1988learning` (caution.bib; also setting.bib) | `rivest1988reliable` (search.bib) | search.tex:86 |
| El-Yaniv & Wiener, JMLR 11 (2010) | `elyaniv2010foundations` (caution.bib; also imitation.bib, setting.bib) | `elyaniv2010selective` (search.bib) | search.tex:86 |
| Li, Littman & Walsh, ICML 2008 | `li2008knows` (caution.bib; also imitation.bib, setting.bib) | `li2008kwik` (search.bib) | search.tex:86 |
| L. J. Cohen, BBS 4(3) (1981) | `cohen1981can` (simplicity.bib) | `cohen1981irrationality` (philosophy.bib) | philosophy.tex:50 |

The Cohen copies disagree on pages: 317–370 (`cohen1981can`, article plus open peer commentary and response) against 317–331 (`cohen1981irrationality`, target article only). Either range is defensible, but use one. I suggest 317–331 for the article itself, or keep 317–370 and add `note = {With open peer commentary}`.

`li2008knows` (ICML 2008, three authors) and `li2011knows` (Machine Learning 82, four authors) are genuinely different publications. Keep both.

## 4. In-text attributions checked

I read every citation in context. The table lists the 40 most load-bearing attributions (who proved what) and a verdict for each. Of these 40, 36 are correct as stated and four have only minor nuances (rows 14, 27, 33 and 40); the paragraphs after the table add the Daniels misattribution and the remaining minor findings.

| # | where | attribution in text | verdict |
|---|---|---|---|
| 1 | setting.tex:125, app-setting.tex:9 | least general generalization (lgg) of terms, due to Plotkin 1970 and Reynolds 1970 | correct |
| 2 | caution.tex:29, setting.tex:468, search.tex:86 | reliable learning (Rivest–Sloan), perfect selective classification (El-Yaniv–Wiener), the "accept" side of KWIK | correct; but see the duplicate keys (§3) |
| 3 | caution.tex:46, imitation.tex:54 | El-Yaniv–Wiener's "consistent selective strategy" escalates on the disagreement region | correct (their term, CSS) |
| 4 | caution.tex:101, imitation.tex:54 | the closure algorithm is Helmbold–Sloan–Warmuth 1990; one-sided learning from positive data goes back to Natarajan 1987 | correct |
| 5 | caution.tex:77, imitation.tex:83,89 | finite elasticity (Wright 1989, corrected by Motoki–Shinohara–Wright 1991) suffices for identification and survives k-unions | correct |
| 6 | caution.tex:138 | exponential KWIK cost of conjunctions (Li et al. 2011) | correct (MB with n+1 mistakes vs exponentially many ⊥; L2 memo ✓) |
| 7 | caution.tex:138 | negative results for two-sided reliable learning (Kivinen 1995) | correct (web: Math. Systems Theory 28:141–172) |
| 8 | caution.tex:192 | KWIK enumeration bound \|H\|−1 (Li et al. 2008) | correct |
| 9 | caution.tex:254–257, informal.tex:120 | Ville's inequality; the prior–posterior-ratio martingale is Waudby-Smith & Ramdas 2020 | correct |
| 10 | caution.tex:257 | closest analogues are conservative Bayesian agents that defer to a mentor (Cohen & Hutter 2020; Cohen, Hutter & Nanda 2022) | correct (web) |
| 11 | imitation.tex:81 | identification in the limit is Gold's; tell-tales characterize it for indexed families (Angluin 1980) | correct |
| 12 | imitation.tex:81 | anchors are the ⊆-tell-tales of strong-monotonic learning (Lange & Zeugmann 1992) | correct in substance (web: characterization by recursively generable finite sets), but hedged "as we recall" (issue below) |
| 13 | imitation.tex:156, app-imitation.tex:105 | ε-net theorem (Haussler–Welzl 1987; Blumer et al. 1989) | correct |
| 14 | coherence.tex:81, informal.tex:253 | halving (Barzdin–Freivalds 1972; Littlestone 1988; Angluin 1988) | correct |
| 15 | coherence.tex:98 | weighted-majority bound (Littlestone–Warmuth 1994) | correct |
| 16 | coherence.tex:87, search.tex:220 | under deductive closure, aggregation is oligarchic (Gärdenfors 2006; Dietrich–List 2008); List–Pettit 2002 impossibility | correct (web for Gärdenfors); List–Pettit conditions stated correctly |
| 17 | search.tex:220 | doctrinal paradox (Kornhauser–Sager 1986), discursive dilemma (Pettit 2001) | correct |
| 18 | coherence.tex:126 | locking sequence (Blum & Blum 1975) | correct |
| 19 | coherence.tex:150, search.tex:108 | Post-completeness of classical propositional logic is Post 1921 | correct |
| 20 | coherence.tex:160, app-coherence.tex:71 | every two-element matrix logic is finitely based (Rautenberg 1981) | correct (web: "strong finite axiomatizability of all 2-valued matrices"), but hedged in the appendix |
| 21 | coherence.tex:177 | Harrop's rule is admissible and not derivable in IPC (Harrop 1960; Rybakov; Iemhoff) | correct |
| 22 | coherence.tex:189 | Glivenko; Jankov formulas of an antichain of finite Heyting algebras (Jankov 1968; Chagrov–Zakharyaschev ch. 9) | correct |
| 23 | coherence.tex:242, app-coherence.tex:136,198 | Shoenfield limit lemma; Putnam/Gold limiting recursion; Kelly | correct; but see "Post's hierarchy theorem" (issue below) |
| 24 | coherence.tex:244 | trilemma theorem is a self-contained form of Sawin & Demski 2013 | correct (web: MIRI TR 2013-10); the credit sits before the theorem, not in it |
| 25 | coherence.tex:267 | Carnap 1943: the classical rules admit the all-true and "true iff tautologous" valuations | correct |
| 26 | coherence.tex:357–373 | tonk (Prior 1960), conservativity (Belnap 1962), tonk without cut (Cook 2005; Ripley 2015), Read's bullet (Read 2000) | correct |
| 27 | coherence.tex:445 | no informative coherence measure is truth-conducive ceteris paribus (Bovens–Hartmann; Olsson) | correct here; misused in philosophy.tex:24 (issue below) |
| 28 | coherence.tex:469 | accuracy dominance (de Finetti 1974; Joyce 1998; Bregman version in Predd et al. 2009) | correct |
| 29 | existence.tex:42,136 | bilateral (Scott) completeness (Scott 1974; Shoesmith–Smiley 1978); Galois connection (Birkhoff 1940; Ore 1944) | correct |
| 30 | existence.tex:210, 198 | Gaifman 1964: a Gaifman-condition probability is fixed by its quantifier-free values | correct |
| 31 | existence.tex:213, app-existence.tex:152 | Limit Coherence and Non-Dogmatism of logical inductors (Garrabrant et al.) | correct (web: Thm 4.1.1 Convergence, Thm 4.1.2 Limit Coherence, Thm 4.6.2 Non-Dogmatism); the numbering hedge can go, and existence of P∞ is Thm 4.1.1, not Limit Coherence |
| 32 | existence.tex:182,289 | Specker's parable; contextuality (Abramsky–Brandenburger 2011); acyclicity (Beeri et al. 1983) | correct |
| 33 | existence.tex:371 | Tennenbaum: in no countable nonstandard model of PA is + computable, and in none is × computable | minor: the separate +/× form is the Kreisel(–Scott)/McAloon strengthening; Kaye is co-cited, so not wrong |
| 34 | existence.tex:363 | Beth definability (Beth 1953) | correct |
| 35 | existence.tex:374 | open induction has computable nonstandard models (Shepherdson 1964) | correct (web) |
| 36 | twotier.tex:143,157 | Reiter 1987 / de Kleer–Williams diagnosis duality; Shapiro's contradiction backtracing (1981, 1983) | correct |
| 37 | twotier.tex:413 | QE doubly exponential (Davenport–Heintz), RCF in EXPSPACE (Ben-Or–Kozen–Reif), Presburger 2^{2^{Ω(n)}} (Fischer–Rabin) | correct |
| 38 | search.tex:149,174 | PAC-semantics chaining (Valiant 2000); Schwartz–Zippel–DeMillo–Lipton | correct |
| 39 | informal.tex:371 | Incurvati–Murzi: several incompatible maximal consistent sets of naive comprehension instances, none recursively axiomatizable, generalizing McGee 1992 | correct (web: Mind 126(502):371–384) |
| 40 | informal.tex:416 | Adams's bound; its use for the sorites "over precisifications" is Edgington's; lottery tightness (Kyburg) | minor: Edgington uses *verities*; she mentions the Lewis–Kamp measure-over-precisifications reading without committing to it (web) |

Other attributions I checked and found correct:
* Gold's limit-point theorem; Dietterich 1997 (multiple-instance learning); Sabato–Tishby (bag size enters mildly).
* Restall's reading of sequents; Smiley and Rumfitt bilateralism; van Fraassen's supervaluations; Garson's local validity; Bonnay–Westerståhl.
* Wilkie (model completeness of exp); Macintyre–Wilkie (decidable given Schanuel's conjecture); Gödel–Rosser and Tarski–Mostowski–Robinson; Turing and Feferman progressions; Q is Σ₁-complete; Matiyasevich; Trakhtenbrot; Dedekind categoricity; internal categoricity (Parsons, McGee, Button–Walsh).
* Łoś–Suszko Lindenbaum matrices; Blok–Pigozzi; Makkai–Reyes on Deligne's theorem; Motzkin; vNM.
* McCarthy's `ist`; Ghidini–Giunchiglia; Brewka–Eiter equilibria; chunk-and-permeate (Brown–Priest); Jaśkowski and Schotch–Jennings.
* Norton's limit property vs limit system; Painlevé's paradox (Stewart 2000); Strevens's "default values" (web); McMullin and Laymon (monotonicity, web); Levins and Odenbaugh–Alexandrova (web).
* Conformal prediction with k=⌈(n+1)(1−α)⌉; information-based complexity; the Nemirovsky–Yudin Lipschitz barrier; Gronwall; interval inclusion monotonicity; Gruntz and Richardson; Kuipers "sound but incomplete" (web confirms that usage); Andes; Barenblatt; Kennedy dimension types; Buckingham.
* Nelson's IST (conservativity, reduction, transfer); Robinson transfer via Łoś; Benacerraf; Zermelo 1908 Separation argument; Quine 1955 on Frege's way out; Quine 1937 stratification; Specker 1953 (NF refutes AC); Holmes on NF.
* Wiedijk's intrinsic de Bruijn factor ≈ 4 (web); Mathias's 4,523,659,424,929-symbol term; Lakatos's hidden lemma and monster-barring; Easwaran's convertibility of rebutting into undercutting defeat (web); Weber–Mejía-Ramos; Manders's co-exactness; system E (Avigad–Dean–Mumma); Hales on Jordan; Thurston; Kreisel's squeezing argument.
* Gneiting–Raftery; Shtarkov; the Goldreich–Levin and Kushilevitz–Mansour list-size bound; Hoeffding §6 (sampling without replacement); Sion; tempered and Safe-Bayes posteriors; Catoni; Vereshchagin–Vitányi "all shapes" (web); Lieberman et al. on irregular verbs; Carnap's meaning postulates; Quine's gavagai.
* Goodman's quotation (ch. III, verbatim); Dummett's suasive/explanatory distinction; Salmon's objection to Reichenbach; Carroll's tortoise; Stich–Nisbett vs Cohen.
* Bergstra–Tucker meadows; PRM800K (Lightman et al.); reward-model overoptimization (Gao et al.); Cobbe et al.'s rise-then-fall of verifier reranking; CCS (Burns et al.).

## 5. Issues (fix list)

Severity follows the brief: major = wrong reference or overclaim a careful reader would object to; minor = local clarity or metadata.

### Major

**M1. Duplicate references in `search.tex` (three papers rendered twice).**
* File: `paper/sections/search.tex`, line 86 ("(c) The uniform requirement is reliable learning \citep{rivest1988reliable}, perfect selective classification \citep{elyaniv2010selective}, or the ``accept'' side of KWIK \citep{li2008kwik}").
* Problem: these keys duplicate `rivest1988learning`, `elyaniv2010foundations` and `li2008knows`, which every other section uses. As a result, the reference list contains each paper twice, and all in-text citations become "1988a", "2010a" and "2008a".
* Fix: change the line to `reliable learning \citep{rivest1988learning}, perfect selective classification \citep{elyaniv2010foundations}, or the ``accept'' side of KWIK \citep{li2008knows}`. Then delete the entries `rivest1988reliable`, `elyaniv2010selective` and `li2008kwik` from `paper/bib/search.bib` and rerun `merge_bib.py`.

**M2. Duplicate reference for L. J. Cohen (1981), with inconsistent pages.**
* File: `paper/sections/philosophy.tex`, line 50 (`\citet{cohen1981irrationality}`).
* Problem: `cohen1981irrationality` (`bib/philosophy.bib`, pp. 317–331) and `cohen1981can` (`bib/simplicity.bib`, pp. 317–370) are the same BBS target article. They render as "Cohen 1981a" and "Cohen 1981b".
* Fix: replace `\citet{cohen1981irrationality}` with `\citet{cohen1981can}` in philosophy.tex:50 and delete `cohen1981irrationality` from `bib/philosophy.bib`. In `bib/simplicity.bib`, either set `pages = {317--331}` (the article) or keep `317--370` and add `note = {With open peer commentary and author's response}`.

**M3. Daniels' independence constraint is misattributed, and so are the impossibility theorems.**
* File: `paper/sections/philosophy.tex`, line 24 (the same sentence is in `research/lit/L11` line 25).
* Problem: the text says "Daniels' ``independence constraint'' is, formally, the conditional-independence assumption that the coherence impossibility theorems show to be necessary". There are two errors:
  * The Bovens–Hartmann and Olsson impossibility theorems are proved *under* conditional independence (L11 line 283: "given independence"). They show that coherence is not truth-conducive even then. They do not show that independence is necessary.
  * Daniels' constraint is that the sets of considered judgments supporting the background theories and the principles be partly disjoint. It is not a probabilistic independence assumption.
* Fix: replace the sentence with: `Daniels' ``independence constraint'', that the background theories not rest on the same considered judgments as the principles, can be read as the requirement that the corroborating channel's errors be independent of the human ones; without it, agreement moves the odds by at most a bounded factor (\cref{rem:coherence:consensus}), and even with it no informative coherence measure is truth-conducive in general (\cref{sec:coherence:eliminative}).`

### Minor

**m1. Hedge on the logical-induction theorem numbering; existence of P∞ misattributed.**
* File: `paper/sections/app-existence.tex`, line 152.
* Fix: replace "by Limit Coherence the limit … exists and is a coherent probability" with "by Convergence and Limit Coherence (\citealt[Thms 4.1.1, 4.1.2]{garrabrant2016logical}) the limit … exists and is a coherent probability". Replace "by Non-Dogmatism" with "by Non-Dogmatism (\citealt[Thm 4.6.2]{garrabrant2016logical})". Delete the parenthesis "(We cite these properties by name; we have confirmed the statements but not the theorem numbering of the arXiv version.)". Web snippets of arXiv:1609.03543 confirm all three numbers.

**m2. "As we recall" hedge on Lange–Zeugmann.**
* File: `paper/sections/imitation.tex`, line 81.
* Fix: replace "As we recall their characterization (we have not re-checked its exact form), strong-monotonic learnability is, up to effectivity, the existence of anchors." with "Their characterization of strong-monotonic learning from text by uniformly recursively generable finite sets $T_j\subseteq L_j$ with $T_j\subseteq L_k\Rightarrow L_j\subseteq L_k$ \citep{lange1992types,lange2008learning} is, up to effectivity, the existence of anchors."
* Web search confirms the characterization by recursively generable finite sets, but not the exact quantifier form. If the authors cannot check the survey's theorem, write "cf." instead of asserting the form.

**m3. Hedge on Rautenberg.**
* File: `paper/sections/app-coherence.tex`, line 71.
* Fix: replace `\citep[as we recall the result; we have not re-checked its exact statement]{rautenberg1981two}` with `\citep{rautenberg1981two}`. Web snippets confirm the main result: every two-element matrix is strongly finitely axiomatizable.

**m4. Hedge on Vereshchagin–Vitányi.**
* File: `paper/sections/simplicity.tex`, line 65.
* Fix: replace "and essentially every compatible shape occurs \citep{vereshchagin2004kolmogorov} (exact side conditions unchecked by us)" with "and, within these constraints and to logarithmic precision, every shape is realized by the structure function of some data \citep{vereshchagin2004kolmogorov}".

**m5. Hedge on Armstrong–Mindermann.**
* File: `paper/sections/simplicity.tex`, line 420.
* Fix: replace "As we recall their result, \citet{armstrong2018occam} show that simplicity alone does not identify such splits." with "\citet{armstrong2018occam} show that a policy does not determine its decomposition into planner and reward, and that a simplicity prior over decompositions does not single out the intended one."

**m6. Edgington attribution.**
* File: `paper/sections/informal.tex`, line 416.
* Fix: replace "its use for the sorites over precisifications is Edgington's \citep{edgington1997vagueness}" with "its use for the sorites is Edgington's, with her verities in place of a measure over precisifications \citep{edgington1997vagueness}".

**m7. Tennenbaum strengthening.**
* File: `paper/sections/existence.tex`, line 371.
* Fix: replace `\citep{tennenbaum1959non,kaye1991models}` with `(\citealt{tennenbaum1959non}; the separate statements for $+$ and $\times$ are due to Kreisel and McAloon, see \citealt{kaye1991models})`.

**m8. "Post's hierarchy theorem" is non-standard and uncited.**
* Files: `paper/sections/coherence.tex:251`, `paper/sections/twotier.tex:428`, `paper/sections/app-coherence.tex:136` and `paper/sections/app-twotier.tex:251`.
* Problem: strictness of the arithmetical hierarchy (a Σₙ-complete set is not Πₙ) is the Kleene–Mostowski hierarchy theorem. Post's theorem is the link between the hierarchy and Turing jumps.
* Fix: replace "Post's hierarchy theorem" with "the arithmetical hierarchy theorem \citep[\S57]{kleene1952introduction}" at each occurrence. `kleene1952introduction` is already in `bib/coherence.bib`.

**m9. Sawin–Demski credit is outside the theorem it credits.**
* File: `paper/sections/coherence.tex`, line 246.
* Fix: change the theorem header to `\begin{theorem}[The coherence/$\Pi_1$/$\Pi_2$ trilemma; cf.\ \citealt{sawin2013computable}]`. In line 244, replace "The same boundary appears for credences, in a self-contained form of a theorem of \citet{sawin2013computable}." with "The same boundary appears for credences (\Cref{thm:coherence:trilemma})."

**m10. Sequent-style natural deduction is Gentzen 1936.**
* File: `paper/sections/setting.tex`, line 80.
* Fix: change `\citealt{gentzen1935untersuchungen,prawitz1965natural}` to `\citealt{gentzen1936widerspruchsfreiheit,prawitz1965natural}`, and add the following to `bib/setting.bib`:

  ```
  @article{gentzen1936widerspruchsfreiheit, author={Gerhard Gentzen}, title={Die {W}iderspruchsfreiheit der reinen {Z}ahlentheorie}, journal={Mathematische Annalen}, volume={112}, pages={493--565}, year={1936}}
  ```

  Alternatively, write "natural deduction \citep{gentzen1935untersuchungen,prawitz1965natural}, in sequent style".

**m11. The Zermelo quotation has no translation source.**
* File: `paper/sections/informal.tex`, line 361.
* Problem: the English words "sufficiently to exclude all contradictions" and "all that is valuable" come from the van Heijenoort translation (p. 200), not from the German original.
* Fix: add `@book{vanheijenoort1967from, editor={Jean van Heijenoort}, title={From {F}rege to {G}{\"o}del: A Source Book in Mathematical Logic, 1879--1931}, publisher={Harvard University Press}, address={Cambridge, MA}, year={1967}}` to `bib/informal.bib`. Cite it as `\citep[trans.\ in][p.~200]{zermelo1908untersuchungen,vanheijenoort1967from}`, or use `\citep{zermelo1908untersuchungen}` plus "(trans.\ \citealt[p.~200]{vanheijenoort1967from})".

**m12. The history table cites nothing.**
* File: `paper/sections/informal.tex`, table `tab:informal:history` (around lines 443–460).
* Problem: the caption sends readers to an internal memo ("literature memo L6, §1, where dates are checked") instead of sources. The facts themselves are correct.
* Fix: add citations in the table, for example:
  * Cauchy row: `\citep[App.~1]{lakatos1976proofs}`;
  * Frege and Zermelo rows: `\citep{vanheijenoort1967from}`, which contains Russell's letter, Zermelo 1908 and Fraenkel/Skolem 1922;
  * Steiner row: Eisenbud & Harris, *3264 and All That* (CUP, 2016);
  * Lamé row: Edwards, *Fermat's Last Theorem* (Springer GTM 50, 1977);
  * Dirichlet row: Monna, *Dirichlet's Principle* (Oosthoek, 1975).

  Then change the caption's source clause to "(sources in the table; dates as checked in the project's literature memo L6)".

**m13. Rawls and Reichenbach are named but not cited.**
* File: `paper/sections/philosophy.tex`, lines 24 and 36.
* Problem: "reflective equilibrium" and the narrow/wide distinction are Rawls's, and "Reichenbachian vindications" are named without a source.
* Fix: add to `bib/philosophy.bib`:

  ```
  @book{rawls1971theory, author={John Rawls}, title={A Theory of Justice}, publisher={Harvard University Press}, address={Cambridge, MA}, year={1971}}
  @article{rawls1974independence, author={John Rawls}, title={The Independence of Moral Theory}, journal={Proceedings and Addresses of the American Philosophical Association}, volume={48}, pages={5--22}, year={1974}}
  @book{reichenbach1938experience, author={Hans Reichenbach}, title={Experience and Prediction}, publisher={University of Chicago Press}, address={Chicago}, year={1938}}
  ```

  Then write "\emph{narrow} reflective equilibrium \citep{rawls1971theory,rawls1974independence}" and "Reichenbachian vindications \citep{reichenbach1938experience}".

**m14. Software is uncited.**
* Files: `paper/sections/app-lean.tex` (line 3) and `paper/sections/experiments.tex` (line 193).
* Fix: in app-lean.tex, write "Lean~4 \citep{demoura2021lean4} with Mathlib \citep{mathlib2020}". In experiments.tex, write "scikit-learn \citep{pedregosa2011scikit}". Add to `bib/experiments.bib`:

  ```
  @inproceedings{demoura2021lean4, author={Leonardo de Moura and Sebastian Ullrich}, title={The {L}ean 4 Theorem Prover and Programming Language}, booktitle={Automated Deduction -- CADE 28}, series={LNCS}, volume={12699}, pages={625--635}, publisher={Springer}, year={2021}}
  @inproceedings{mathlib2020, author={{The mathlib Community}}, title={The {L}ean Mathematical Library}, booktitle={Proceedings of the 9th ACM SIGPLAN International Conference on Certified Programs and Proofs (CPP)}, pages={367--381}, year={2020}}
  @article{pedregosa2011scikit, author={Fabian Pedregosa and others}, title={Scikit-learn: Machine Learning in {P}ython}, journal={Journal of Machine Learning Research}, volume={12}, pages={2825--2830}, year={2011}}
  ```

**m15. Wrong page range for Rivest–Sloan.**
* File: `paper/bib/caution.bib`, entry `rivest1988learning`. This is the first-defining file; `setting.bib` holds a copy.
* Fix: `pages = {635--640}`, verified on mlanthology. Change the copy in `bib/setting.bib` too, to keep the files consistent.

**m16. Incomplete metadata in `bib/caution.bib`.**
* Fix:
  * `natarajan1987learning`: add `pages = {296--304}`;
  * `li2008knows`: add `pages = {568--575}`;
  * `motoki1991correct`: add `pages = {375}`;
  * `cohen2022fully`: add `number = {334}, pages = {1--30}`.

  Mirror these in `imitation.bib` and `setting.bib`, where the same keys are duplicated.

**m17. Incomplete metadata in `bib/coherence.bib` and `bib/imitation.bib`.**
* Fix:
  * `barzdin1972prediction`: add `pages = {1224--1228}`;
  * `sawin2013computable`: add `number = {2013-10}` and change the note to `Result from a July 2013 workshop; released December 2014`;
  * `lange1992types` (imitation.bib): add `pages = {377--390}`;
  * `stephan2001learning` (imitation.bib): add `number = {2}, pages = {221--273}`.

**m18. Incomplete metadata in `bib/informal.bib`.**
* Fix:
  * `easwaran2015rebutting`: `number = {1}, pages = {146--162}`;
  * `weber2011why`: `number = {3}, pages = {329--344}`;
  * `avigad2009formal`: `pages = {700--768}`;
  * `mcgee1992maximal`: `number = {3}, pages = {235--241}`;
  * `specker1953axiom`: `number = {9}, pages = {972--975}`;
  * `cantor1891elementare`: `pages = {75--78}`;
  * `varzi2007supervaluationism`: `pages = {633--676}`;
  * `sabato2012multi`: `pages = {2999--3039}`;
  * `hales2007jordan`: `pages = {882--894}`;
  * `edgington1997vagueness`: `pages = {294--316}`.

  Optionally delete the uncited `jiang2023draft` and `azzouni2004derivation`.

**m19. Incomplete metadata in `bib/existence.bib`, `bib/physics.bib`, `bib/search.bib` and `bib/simplicity.bib`.**
* Fix:
  * existence.bib: `shepherdson1964nonstandard` add `number = {2}, pages = {79--86}`; `adams1966probability` add `pages = {265--316}`.
  * physics.bib: `kennedy1994dimension` add `pages = {348--362}`; `stalnaker1968theory` add `pages = {98--112}`; `los1955quelques` add `pages = {98--113}`.
  * search.bib: `valiant2000robust` add `number = {2}, pages = {231--253}`; `kornhauser1986unpacking` add `number = {1}, pages = {82--117}`; `cobbe2021training` replace "Cobbe, Karl and others" with the full author list: Karl Cobbe, Vineet Kosaraju, Mohammad Bavarian, Mark Chen, Heewoo Jun, Lukasz Kaiser, Matthias Plappert, Jerry Tworek, Jacob Hilton, Reiichiro Nakano, Christopher Hesse, John Schulman.
  * simplicity.bib: `shtarkov1987universal` add `pages = {175--186}`; `grunwald2012safe` add `pages = {169--183}`; `vereshchagin2017algorithmic` add `pages = {669--737}`.

## 6. Per-entry verification table

Status legend:
* "checked by web search": confirmed from search snippets (publisher pages were mostly blocked; arXiv, intelligence.org and university hosts were blocked by the egress proxy);
* "checked from knowledge": standard reference whose authors, title, venue and year match the canonical record.

The table is grouped by the file whose definition `merge_bib.py` keeps.

**bib/caution.bib** (18 entries kept from this file)

| key | first author, year | also defined in | status |
|---|---|---|---|
| `cohen2020pessimism` | Michael K. Cohen 2020 | - | real; checked by web search |
| `cohen2022fully` | Michael K. Cohen 2022 | - | real; checked by web search |
| `elyaniv2010foundations` | Ran El-Yaniv 2010 | imitation.bib, setting.bib | real; checked from knowledge |
| `gold1967language` | E. Mark Gold 1967 | coherence.bib, imitation.bib, informal.bib, search.bib, setting.bib | real; checked from knowledge |
| `helmbold1990learning` | David Helmbold 1990 | imitation.bib | real; checked from knowledge |
| `kivinen1995learning` | Jyrki Kivinen 1995 | - | real; checked by web search |
| `li2008knows` | Lihong Li 2008 | imitation.bib, setting.bib | real; checked from knowledge |
| `li2011knows` | Lihong Li 2011 | - | real; checked from knowledge |
| `motoki1991correct` | Tatsuya Motoki 1991 | imitation.bib | real; checked by web search |
| `natarajan1987learning` | Balas K. Natarajan 1987 | imitation.bib | real; checked from knowledge |
| `plotkin1970note` | Gordon D. Plotkin 1970 | experiments.bib, search.bib, setting.bib, twotier.bib | real; checked from knowledge |
| `ramdas2023game` | Aaditya Ramdas 2023 | - | real; checked from knowledge |
| `reynolds1970transformational` | John C. Reynolds 1970 | setting.bib, twotier.bib | real; checked from knowledge |
| `rivest1988learning` | Ronald L. Rivest 1988 | setting.bib | pages 635--640, not 635--639 (web-checked) |
| `shafer2011test` | Glenn Shafer 2011 | - | real; checked from knowledge |
| `ville1939etude` | Jean Ville 1939 | informal.bib | real; checked from knowledge |
| `waudbysmith2020confidence` | Ian Waudby-Smith 2020 | informal.bib | real; checked from knowledge |
| `wright1989identification` | Keith Wright 1989 | imitation.bib | real; checked from knowledge |

**bib/coherence.bib** (64 entries kept from this file)

| key | first author, year | also defined in | status |
|---|---|---|---|
| `angluin1980inductive` | Angluin 1980 | imitation.bib, search.bib | real; checked from knowledge |
| `barzdin1972prediction` | Janis M. Barzdin 1972 | informal.bib | real; checked by web search |
| `belnap1962tonk` | Belnap 1962 | imitation.bib, search.bib | real; checked from knowledge |
| `blum1975toward` | Lenore Blum 1975 | - | real; checked from knowledge |
| `bonnay2016compositionality` | Denis Bonnay 2016 | - | real; checked from knowledge |
| `boolos2007computability` | George S. Boolos 2007 | existence.bib, twotier.bib | real; checked from knowledge |
| `bovens2003bayesian` | Luc Bovens 2003 | - | real; checked from knowledge |
| `bovens2003solving` | Luc Bovens 2003 | - | real; checked from knowledge |
| `carnap1943formalization` | Rudolf Carnap 1943 | setting.bib | real; checked from knowledge |
| `chagrov1997modal` | Alexander Chagrov 1997 | - | real; checked from knowledge |
| `clark1978negation` | Keith L. Clark 1978 | - | real; checked from knowledge |
| `cook2005whats` | Roy T. Cook 2005 | - | real; checked from knowledge |
| `daniels1979wide` | Norman Daniels 1979 | philosophy.bib | real; checked from knowledge |
| `definetti1974theory` | Bruno de Finetti 1974 | - | real; checked from knowledge |
| `dietrich2008judgment` | Dietrich 2008 | search.bib | real; checked from knowledge |
| `dietterich1997solving` | Thomas G. Dietterich 1997 | informal.bib, setting.bib | real; checked from knowledge |
| `dummett1991logical` | Michael Dummett 1991 | - | real; checked from knowledge |
| `feferman1962transfinite` | Solomon Feferman 1962 | twotier.bib | real; checked from knowledge |
| `gardenfors2006representation` | G"ardenfors 2006 | search.bib | real; checked by web search |
| `garson2013what` | James W. Garson 2013 | - | real; checked from knowledge |
| `geis1971invited` | Michael L. Geis 1971 | - | real; checked from knowledge |
| `glivenko1929quelques` | V. Glivenko 1929 | existence.bib | real; checked from knowledge |
| `godel1931formal` | Kurt G"odel 1931 | existence.bib, twotier.bib | real; checked from knowledge |
| `gold1965limiting` | E. Mark Gold 1965 | - | real; checked from knowledge |
| `goodman1955fact` | Nelson Goodman 1955 | philosophy.bib, twotier.bib | real; checked from knowledge |
| `harrop1960concerning` | Ronald Harrop 1960 | - | real; checked from knowledge |
| `iemhoff2001admissible` | Rosalie Iemhoff 2001 | - | real; checked from knowledge |
| `jankov1968construction` | V. A. Jankov 1968 | - | real; checked from knowledge |
| `joyce1998nonpragmatic` | James M. Joyce 1998 | - | real; checked from knowledge |
| `kelly1996logic` | Kevin T. Kelly 1996 | setting.bib | real; checked from knowledge |
| `kleene1952introduction` | Stephen Cole Kleene 1952 | - | real; checked from knowledge |
| `kripke1982wittgenstein` | Saul A. Kripke 1982 | imitation.bib | real; checked from knowledge |
| `lewis1946analysis` | Clarence Irving Lewis 1946 | - | real; checked from knowledge |
| `littlestone1988learning` | Nick Littlestone 1988 | informal.bib, twotier.bib | real; checked from knowledge |
| `littlestone1994weighted` | Nick Littlestone 1994 | twotier.bib | real; checked from knowledge |
| `macintyre1996decidability` | Angus Macintyre 1996 | - | real; checked from knowledge |
| `mendelson1964introduction` | Elliott Mendelson 1964 | - | real; checked from knowledge |
| `olsson2005against` | Erik J. Olsson 2005 | - | real; checked from knowledge |
| `olsson2005impossibility` | Erik J. Olsson 2005 | - | real; checked from knowledge |
| `pogorzelski1971structural` | W. A. Pogorzelski 1971 | - | real; checked from knowledge |
| `pogorzelski2008completeness` | Witold A. Pogorzelski 2008 | - | real; checked from knowledge |
| `post1921` | Post 1921 | search.bib, twotier.bib | real; checked from knowledge |
| `post1943formal` | Emil L. Post 1943 | twotier.bib | real; checked from knowledge |
| `prawitz1965natural` | Dag Prawitz 1965 | setting.bib | real; checked from knowledge |
| `predd2009probabilistic` | Joel B. Predd 2009 | - | real; checked from knowledge |
| `prior1960runabout` | Prior 1960 | experiments.bib, search.bib, setting.bib | real; checked from knowledge |
| `putnam1965trial` | Hilary Putnam 1965 | - | real; checked from knowledge |
| `rautenberg1981two` | Wolfgang Rautenberg 1981 | - | real; checked by web search |
| `read2000harmony` | Stephen Read 2000 | - | real; checked from knowledge |
| `restall2005multiple` | Greg Restall 2005 | existence.bib, setting.bib, twotier.bib | real; checked from knowledge |
| `ripley2015anything` | David Ripley 2015 | - | real; checked from knowledge |
| `rosser1936extensions` | J. Barkley Rosser 1936 | existence.bib, twotier.bib | real; checked from knowledge |
| `rumfitt2000yes` | Ian Rumfitt 2000 | setting.bib, twotier.bib | real; checked from knowledge |
| `rybakov1997admissibility` | Vladimir V. Rybakov 1997 | - | real; checked from knowledge |
| `sawin2013computable` | Will Sawin 2013 | - | real; checked by web search |
| `shoenfield1959degrees` | Joseph R. Shoenfield 1959 | twotier.bib | real; checked from knowledge |
| `shoesmith1978multiple` | D. J. Shoesmith 1978 | existence.bib, setting.bib | real; checked from knowledge |
| `smiley1996rejection` | Timothy Smiley 1996 | setting.bib, twotier.bib | real; checked from knowledge |
| `smullyan1961theory` | Raymond M. Smullyan 1961 | twotier.bib | real; checked from knowledge |
| `tarski1953undecidable` | Alfred Tarski 1953 | - | real; checked from knowledge |
| `turing1939systems` | Alan M. Turing 1939 | twotier.bib | real; checked from knowledge |
| `vanfraassen1966singular` | Bas C. van Fraassen 1966 | - | real; checked from knowledge |
| `wilkie1996model` | A. J. Wilkie 1996 | - | real; checked from knowledge |
| `wojcicki1988theory` | Ryszard W'ojcicki 1988 | existence.bib, setting.bib | real; checked from knowledge |

**bib/existence.bib** (42 entries kept from this file)

| key | first author, year | also defined in | status |
|---|---|---|---|
| `abramsky2011sheaf` | Samson Abramsky 2011 | physics.bib | real; checked from knowledge |
| `adams1966probability` | Ernest W. Adams 1966 | informal.bib | real; checked from knowledge |
| `beeri1983desirability` | Catriel Beeri 1983 | - | real; checked from knowledge |
| `beth1953padoa` | Evert W. Beth 1953 | - | real; checked from knowledge |
| `birkhoff1940lattice` | Garrett Birkhoff 1940 | - | real; checked from knowledge |
| `blok1989algebraizable` | Willem J. Blok 1989 | - | real; checked from knowledge |
| `brewka2007equilibria` | Gerhard Brewka 2007 | - | real; checked from knowledge |
| `burns2023discovering` | Collin Burns 2023 | - | real; checked from knowledge |
| `button2018philosophy` | Tim Button 2018 | - | real; checked from knowledge |
| `christiano2013definability` | Paul Christiano 2013 | - | real; checked from knowledge |
| `dedekind1888zahlen` | Richard Dedekind 1888 | informal.bib | real; checked from knowledge |
| `definetti1937prevision` | Bruno de Finetti 1937 | - | real; checked from knowledge |
| `farkas1902theorie` | Julius Farkas 1902 | - | real; checked from knowledge |
| `font2016abstract` | Josep Maria Font 2016 | - | real; checked from knowledge |
| `gaifman1964concerning` | Haim Gaifman 1964 | - | real; checked from knowledge |
| `garrabrant2016logical` | Scott Garrabrant 2016 | - | real; checked by web search |
| `ghidini2001local` | Chiara Ghidini 2001 | physics.bib | real; checked from knowledge |
| `godel1930vollstandigkeit` | Kurt G"odel 1930 | informal.bib | real; checked from knowledge |
| `henkin1949completeness` | Leon Henkin 1949 | - | real; checked from knowledge |
| `hilbert1893vollen` | David Hilbert 1893 | - | real; checked from knowledge |
| `kaye1991models` | Richard Kaye 1991 | - | real; checked from knowledge |
| `lewis1970how` | David Lewis 1970 | - | real; checked from knowledge |
| `los1958remarks` | Jerzy Lo's 1958 | setting.bib | real; checked from knowledge |
| `makkai1977first` | Michael Makkai 1977 | - | real; checked from knowledge |
| `matiyasevich1970enumerable` | Yuri Matiyasevich 1970 | - | real; checked from knowledge |
| `mccarthy1993notes` | John McCarthy 1993 | physics.bib, setting.bib | real; checked from knowledge |
| `mcgee1997how` | Vann McGee 1997 | - | real; checked from knowledge |
| `motzkin1936beitrage` | Theodore S. Motzkin 1936 | - | real; checked from knowledge |
| `ore1944galois` | Oystein Ore 1944 | - | real; checked from knowledge |
| `paris1994uncertain` | Jeff B. Paris 1994 | - | real; checked from knowledge |
| `parsons1990uniqueness` | Charles Parsons 1990 | - | real; checked from knowledge |
| `scott1974completeness` | Dana Scott 1974 | - | real; checked from knowledge |
| `shepherdson1964nonstandard` | John C. Shepherdson 1964 | - | real; checked by web search |
| `specker1960logik` | Ernst Specker 1960 | - | real; checked from knowledge |
| `stengle1974nullstellensatz` | Gilbert Stengle 1974 | - | real; checked from knowledge |
| `stone1936theory` | Marshall H. Stone 1936 | - | real; checked from knowledge |
| `suszko1977fregean` | Roman Suszko 1977 | - | real; checked from knowledge |
| `tennenbaum1959non` | Stanley Tennenbaum 1959 | - | real; checked by web search |
| `trakhtenbrot1950impossibility` | Boris A. Trakhtenbrot 1950 | - | real; checked from knowledge |
| `vanemden1976semantics` | Maarten H. van Emden 1976 | - | real; checked from knowledge |
| `vonneumann1944theory` | John von Neumann 1944 | - | real; checked from knowledge |
| `zariski1947new` | Oscar Zariski 1947 | - | real; checked from knowledge |

**bib/experiments.bib** (7 entries kept from this file)

| key | first author, year | also defined in | status |
|---|---|---|---|
| `abreu2007accuracy` | Abreu 2007 | - | real; checked from knowledge |
| `bergstra2007rational` | Bergstra 2007 | - | real; checked from knowledge |
| `gao2023scaling` | Gao 2023 | search.bib | real; checked from knowledge |
| `lakatos1976proofs` | Imre Lakatos 1976 | informal.bib, simplicity.bib, twotier.bib | real; checked from knowledge |
| `lightman2023verify` | Lightman 2023 | search.bib | real; checked from knowledge |
| `schwartz1980fast` | Schwartz 1980 | search.bib, setting.bib, simplicity.bib | real; checked from knowledge |
| `zippel1979probabilistic` | Zippel 1979 | search.bib, setting.bib, simplicity.bib | real; checked from knowledge |

**bib/imitation.bib** (11 entries kept from this file)

| key | first author, year | also defined in | status |
|---|---|---|---|
| `blumer1989learnability` | Anselm Blumer 1989 | - | real; checked from knowledge |
| `brandom1994making` | Robert B. Brandom 1994 | twotier.bib | real; checked from knowledge |
| `buckingham1914physically` | Edgar Buckingham 1914 | physics.bib | real; checked from knowledge |
| `haussler1987epsilon` | David Haussler 1987 | - | real; checked from knowledge |
| `kearns1993learning` | Michael Kearns 1993 | - | real; checked from knowledge |
| `kennedy1994dimension` | Andrew Kennedy 1994 | physics.bib | real; checked from knowledge |
| `lange1992types` | Steffen Lange 1992 | - | real; checked by web search |
| `lange2008learning` | Steffen Lange 2008 | - | real; checked from knowledge |
| `rossmanith2001stochastic` | Peter Rossmanith 2001 | - | real; checked from knowledge |
| `shinohara1994rich` | Takeshi Shinohara 1994 | - | real; checked by web search |
| `stephan2001learning` | Frank Stephan 2001 | - | real; checked by web search |

**bib/informal.bib** (34 entries kept from this file)

| key | first author, year | also defined in | status |
|---|---|---|---|
| `angluin1988queries` | Dana Angluin 1988 | - | real; checked from knowledge |
| `avigad2009formal` | Jeremy Avigad 2009 | - | real; checked from knowledge |
| `avigad2021reliability` | Jeremy Avigad 2021 | - | real; checked by web search |
| `azzouni2004derivation` | Jody Azzouni 2004 | - | uncited (harmless) |
| `benacerraf1965numbers` | Paul Benacerraf 1965 | - | real; checked from knowledge |
| `cantor1891elementare` | Georg Cantor 1891 | - | real; checked from knowledge |
| `easwaran2015rebutting` | Kenny Easwaran 2015 | - | real; checked by web search |
| `edgington1997vagueness` | Dorothy Edgington 1997 | - | real; checked by web search |
| `fine1975vagueness` | Kit Fine 1975 | physics.bib | real; checked from knowledge |
| `frege1893grundgesetze` | Gottlob Frege 1893 | - | real; checked from knowledge |
| `hales2007jordan` | Thomas C. Hales 2007 | - | real; checked from knowledge |
| `holmes2015nf` | M. Randall Holmes 2015 | - | real; checked from knowledge |
| `incurvati2017maximally` | Luca Incurvati 2017 | - | real; checked by web search |
| `jiang2023draft` | Albert Q. Jiang 2023 | - | uncited (harmless) |
| `keefe2000theories` | Rosanna Keefe 2000 | - | real; checked from knowledge |
| `kreisel1967informal` | Georg Kreisel 1967 | - | real; checked from knowledge |
| `kyburg1961probability` | Henry E. Kyburg 1961 | - | real; checked from knowledge |
| `manders2008euclidean` | Kenneth Manders 2008 | - | real; checked from knowledge |
| `mathias2002term` | A. R. D. Mathias 2002 | - | real; checked from knowledge |
| `mcgee1992maximal` | Vann McGee 1992 | - | real; checked from knowledge |
| `moore1982zermelo` | Gregory H. Moore 1982 | - | real; checked from knowledge |
| `nelson1977internal` | Edward Nelson 1977 | - | real; checked from knowledge |
| `quine1937new` | W. V. Quine 1937 | - | real; checked from knowledge |
| `quine1955frege` | W. V. Quine 1955 | - | real; checked from knowledge |
| `robinson1966nonstandard` | Abraham Robinson 1966 | physics.bib | real; checked from knowledge |
| `sabato2012multi` | Sivan Sabato 2012 | - | real; checked from knowledge |
| `shapiro1983algorithmic` | Ehud Y. Shapiro 1983 | twotier.bib | real; checked from knowledge |
| `specker1953axiom` | Ernst P. Specker 1953 | - | real; checked from knowledge |
| `thurston1994proof` | William P. Thurston 1994 | - | real; checked from knowledge |
| `varzi2007supervaluationism` | Achille C. Varzi 2007 | - | real; checked from knowledge |
| `weber2011why` | Keith Weber 2011 | - | real; checked from knowledge |
| `wiedijk2000debruijn` | Freek Wiedijk 2000 | - | real; checked by web search |
| `williamson1994vagueness` | Timothy Williamson 1994 | - | real; checked from knowledge |
| `zermelo1908untersuchungen` | Ernst Zermelo 1908 | - | real; checked from knowledge |

**bib/philosophy.bib** (5 entries kept from this file)

| key | first author, year | also defined in | status |
|---|---|---|---|
| `carroll1895tortoise` | Carroll 1895 | - | real; checked from knowledge |
| `cohen1981irrationality` | Cohen 1981 | - | DUPLICATE of cohen1981can (pages differ) |
| `dummett1973justification` | Dummett 1973 | - | real; checked from knowledge |
| `salmon1967foundations` | Salmon 1967 | - | real; checked from knowledge |
| `stich1980justification` | Stich 1980 | simplicity.bib | real; checked from knowledge |

**bib/physics.bib** (30 entries kept from this file)

| key | first author, year | also defined in | status |
|---|---|---|---|
| `alchourron1985logic` | Carlos E. Alchourr'on 1985 | - | real; checked from knowledge |
| `barenblatt1996scaling` | Grigory I. Barenblatt 1996 | - | real; checked from knowledge |
| `brown2004chunk` | Bryson Brown 2004 | setting.bib | real; checked from knowledge |
| `cartwright1983laws` | Nancy Cartwright 1983 | - | real; checked from knowledge |
| `falkenhainer1991compositional` | Brian Falkenhainer 1991 | - | real; checked from knowledge |
| `gronwall1919note` | T. H. Gronwall 1919 | - | real; checked from knowledge |
| `gruntz1996computing` | Dominik Gruntz 1996 | - | real; checked from knowledge |
| `immler2018verified` | Fabian Immler 2018 | - | real; checked from knowledge |
| `jaskowski1969propositional` | Stanislaw Ja'skowski 1969 | - | real; checked from knowledge |
| `kuipers1986qualitative` | Benjamin Kuipers 1986 | - | real; checked by web search |
| `laymon1987scott` | Ronald Laymon 1987 | - | real; checked by web search |
| `lei2018distribution` | Jing Lei 2018 | - | real; checked from knowledge |
| `levins1966strategy` | Richard Levins 1966 | - | real; checked from knowledge |
| `lewis1973counterfactuals` | David Lewis 1973 | - | real; checked from knowledge |
| `los1955quelques` | Jerzy Lo's 1955 | - | real; checked from knowledge |
| `mcmullin1985galilean` | Ernan McMullin 1985 | - | real; checked from knowledge |
| `moore1966interval` | Ramon E. Moore 1966 | - | real; checked from knowledge |
| `nemirovsky1983problem` | Arkadi S. Nemirovsky 1983 | - | real; checked from knowledge |
| `norton2012approximation` | John D. Norton 2012 | - | real; checked from knowledge |
| `odenbaugh2011buyer` | Jay Odenbaugh 2011 | - | real; checked by web search |
| `richardson1968some` | Daniel Richardson 1968 | - | real; checked from knowledge |
| `schotch1980inference` | Peter K. Schotch 1980 | - | real; checked from knowledge |
| `stalnaker1968theory` | Robert C. Stalnaker 1968 | - | real; checked from knowledge |
| `stewart2000rigid` | David E. Stewart 2000 | - | real; checked from knowledge |
| `strevens2008depth` | Michael Strevens 2008 | - | real; checked by web search |
| `traub1988information` | Joseph F. Traub 1988 | - | real; checked from knowledge |
| `tucker2011validated` | Warwick Tucker 2011 | - | real; checked from knowledge |
| `vanlehn2005andes` | Kurt VanLehn 2005 | - | real; checked from knowledge |
| `vovk2005algorithmic` | Vladimir Vovk 2005 | - | real; checked from knowledge |
| `wilson2006wandering` | Mark Wilson 2006 | - | real; checked from knowledge |

**bib/search.bib** (11 entries kept from this file)

| key | first author, year | also defined in | status |
|---|---|---|---|
| `cobbe2021training` | Cobbe 2021 | - | real; checked from knowledge |
| `demillo1978probabilistic` | DeMillo 1978 | - | real; checked from knowledge |
| `elyaniv2010selective` | El-Yaniv 2010 | - | DUPLICATE of elyaniv2010foundations |
| `juba2013implicit` | Juba 2013 | - | real; checked from knowledge |
| `khardon1997learning` | Khardon 1997 | - | real; checked from knowledge |
| `kornhauser1986unpacking` | Kornhauser 1986 | - | real; checked from knowledge |
| `li2008kwik` | Li 2008 | - | DUPLICATE of li2008knows |
| `list2002aggregating` | List 2002 | - | real; checked from knowledge |
| `pettit2001deliberative` | Pettit 2001 | - | real; checked from knowledge |
| `rivest1988reliable` | Rivest 1988 | - | DUPLICATE of rivest1988learning |
| `valiant2000robust` | Valiant 2000 | - | real; checked from knowledge |

**bib/setting.bib** (1 entries kept from this file)

| key | first author, year | also defined in | status |
|---|---|---|---|
| `gentzen1935untersuchungen` | Gerhard Gentzen 1935 | - | real; checked from knowledge |

**bib/simplicity.bib** (25 entries kept from this file)

| key | first author, year | also defined in | status |
|---|---|---|---|
| `armstrong2018occam` | Stuart Armstrong 2018 | - | real; checked by web search |
| `barron1991minimum` | Andrew R. Barron 1991 | - | real; checked from knowledge |
| `bhattacharya2019fractional` | Anirban Bhattacharya 2019 | - | real; checked from knowledge |
| `bissiri2016general` | Pier Giovanni Bissiri 2016 | - | real; checked from knowledge |
| `carnap1952meaning` | Rudolf Carnap 1952 | - | real; checked from knowledge |
| `catoni2007pac` | Olivier Catoni 2007 | - | real; checked from knowledge |
| `cohen1981can` | L. Jonathan Cohen 1981 | - | kept copy; pages 317--370 = article+commentaries |
| `gacs2001algorithmic` | P'eter G'acs 2001 | - | real; checked from knowledge |
| `gneiting2007strictly` | Tilmann Gneiting 2007 | - | real; checked from knowledge |
| `goldreich1989hard` | Oded Goldreich 1989 | - | real; checked from knowledge |
| `grunwald2007minimum` | Peter D. Gr"unwald 2007 | - | real; checked from knowledge |
| `grunwald2012safe` | Peter Gr"unwald 2012 | - | real; checked from knowledge |
| `grunwald2017inconsistency` | Peter Gr"unwald 2017 | - | real; checked from knowledge |
| `hoeffding1963probability` | Wassily Hoeffding 1963 | twotier.bib | real; checked from knowledge |
| `kushilevitz1993learning` | Eyal Kushilevitz 1993 | - | real; checked from knowledge |
| `li2008introduction` | Ming Li 2008 | - | real; checked from knowledge |
| `lieberman2007quantifying` | Erez Lieberman 2007 | - | real; checked from knowledge |
| `quine1960word` | Willard Van Orman Quine 1960 | - | real; checked from knowledge |
| `rissanen1978modeling` | Jorma Rissanen 1978 | - | real; checked from knowledge |
| `shtarkov1987universal` | Yuri M. Shtarkov 1987 | - | real; checked from knowledge |
| `sion1958general` | Maurice Sion 1958 | - | real; checked from knowledge |
| `vereshchagin2004kolmogorov` | Nikolai K. Vereshchagin 2004 | - | real; checked by web search |
| `vereshchagin2010rate` | Nikolai K. Vereshchagin 2010 | - | real; checked from knowledge |
| `vereshchagin2017algorithmic` | Nikolay Vereshchagin 2017 | - | real; checked from knowledge |
| `zhang2006epsilon` | Tong Zhang 2006 | - | real; checked from knowledge |

**bib/twotier.bib** (14 entries kept from this file)

| key | first author, year | also defined in | status |
|---|---|---|---|
| `benor1986complexity` | Michael Ben-Or 1986 | - | real; checked from knowledge |
| `berge1989hypergraphs` | Claude Berge 1989 | - | real; checked from knowledge |
| `bioch1995complexity` | Jan C. Bioch 1995 | - | real; checked from knowledge |
| `davenport1988real` | James H. Davenport 1988 | - | real; checked from knowledge |
| `dekleer1987diagnosing` | Johan de Kleer 1987 | - | real; checked from knowledge |
| `fischer1974super` | Michael J. Fischer 1974 | - | real; checked from knowledge |
| `fredman1996complexity` | Michael L. Fredman 1996 | - | real; checked from knowledge |
| `gurvich1999generating` | Vladimir Gurvich 1999 | - | real; checked from knowledge |
| `miller1991logic` | Dale Miller 1991 | - | real; checked from knowledge |
| `presburger1929vollstandigkeit` | Moj.zesz Presburger 1929 | - | real; checked from knowledge |
| `reiter1987theory` | Raymond Reiter 1987 | - | real; checked from knowledge |
| `robinson1965machine` | J. Alan Robinson 1965 | - | real; checked from knowledge |
| `shapiro1981inductive` | Ehud Y. Shapiro 1981 | - | real; checked from knowledge |
| `tarski1951decision` | Alfred Tarski 1951 | - | real; checked from knowledge |
## 7. Sources used for web verification

* Rivest & Sloan, AAAI 1988, pp. 635–640: https://mlanthology.org/aaai/1988/rivest1988aaai-learning/
* Sawin & Demski, MIRI TR 2013-10: https://intelligence.org/2014/12/16/new-report-computable-probability-distributions-converge/
* Cohen & Hutter, COLT 2020, PMLR 125:1344–1373: http://proceedings.mlr.press/v125/cohen20a.html
* Cohen, Hutter & Nanda, JMLR 23(334):1–30: https://jmlr.org/papers/v23/21-0618.html
* Kivinen, Math. Systems Theory 28:141–172: https://link.springer.com/article/10.1007/BF01191474
* Motoki, Shinohara & Wright, COLT 1991, p. 375: https://mlanthology.org/colt/1991/motoki1991colt-correct/
* Easwaran, Phil. Perspectives 29(1):146–162: https://philpapers.org/rec/EASRAU
* Incurvati & Murzi, Mind 126(502):371–384: https://academic.oup.com/mind/article-abstract/126/502/371/2937026
* Laymon, Phil. Sci. 54(2):194–221: https://www.journals.uchicago.edu/doi/abs/10.1086/289370
* Odenbaugh & Alexandrova, Biol. Phil. 26:757–771: https://www.semanticscholar.org/paper/e2641327c12605947ad5613f6501a773bd07b06c
* Garrabrant et al., Logical Induction, Thms 4.1.1, 4.1.2, 4.6.2: https://arxiv.org/abs/1609.03543 (search snippets)
* Wiedijk, The De Bruijn Factor: https://www.cs.ru.nl/~freek/factor/
* Avigad, Synthese 198:7377–7399: https://philpapers.org/rec/AVIROM
* Lange & Zeugmann, COLT 1992: https://dl.acm.org/doi/10.1145/130385.130427
* Shepherdson 1964, Bull. Acad. Polon. 12(2):79–86 (cited in https://link.springer.com/article/10.1007/s00153-024-00929-2)
* Barzdin & Freivalds, Soviet Math. Dokl. 13:1224–1228 (cited in follow-up literature)
* Gärdenfors, Econ. Phil. 22(2):181–190: https://ideas.repec.org/a/cup/ecnphi/v22y2006i02p181-190_00.html
* Tennenbaum history (Kreisel/McAloon strengthening): https://en.wikipedia.org/wiki/Tennenbaum%27s_theorem
* Kuipers, QSIM "sound but incomplete": https://arxiv.org/pdf/1110.0020
* Rautenberg, Studia Logica 40:315–353 (strong finite axiomatizability of 2-element matrices): search snippets, e.g. https://apcz.umk.pl/LLP/article/viewFile/3427/3391
* Armstrong & Mindermann, NeurIPS 2018: https://arxiv.org/abs/1712.05812
* Vereshchagin & Vitányi, IEEE TIT 50(12):3265–3290: https://homepages.cwi.nl/~paulv/papers/structure.pdf
* Edgington's verities and the Lewis–Kamp framework: https://philarchive.org/archive/WILDSL-3 and https://link.springer.com/article/10.1007/s11229-015-0724-2
* Strevens, "default values": https://www.strevens.org/research/expln/Idealization.pdf
* Shinohara, Inf. Comput. 108:175–186; Stephan & Ventsov, TCS 268:221–273 (search snippets)
