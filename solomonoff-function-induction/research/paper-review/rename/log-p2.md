# Log of group p2 (Paper 2, `paper-steeper/`): renaming to Solomonoff operator induction

Binding: `RENAME.md` (this folder), then `REFRAME.md` and `DECISIONS.md`. Every statement about Solomonoff was checked against the text extractions of Solomonoff (2008) and (1999) named in RENAME.md §2.

## Result

* Full build (`flock /tmp/claude-0/paper-build-sfi.lock ./build.sh`): 0 LaTeX errors, 0 undefined references, 0 undefined citations, 0 multiply defined labels, 0 overfull boxes above 10pt (two below 3pt), 87 pages (87 before). Table-of-contents page numbers unchanged.
* Numbering check against `aux-before/paper2-main.aux`: 241 labels before, 241 after, 0 differ.
* Isolated builds, all OK: abstract; intro; related; setup + app-setup; absorb + app-absorb; kinks + app-kinks; recovery + app-recovery; recovery + app-split; parity + app-parity; teacher + app-teacher; limits + app-limits; imit + app-imit; computable + app-related; discussion.
* Greps on `pdftotext main.pdf`: `SFI` none; `function induction` only in the reference-list entry of `hanni2026notes` (its `note` field in `core.bib`, the allowed exception); `in this spirit` none; `unverified` none; `Wyeth` none.
* Abstract: 1919 characters between the environment lines (limit 1920).

## Conventions used in Paper 2

* "SFI" in Paper 2 meant $M_F$ (setup.tex defined it so), while "steeper SFI" meant the steeper prior over the product class $\mathcal H_\times$. So: plain "SFI" → "SOI" (default: the one-tape version) or "the one-tape version of SOI" where shared versus private randomness or repeated inputs matter; "steeper SFI" → "Solomonoff's per-query solution with a steeper prior" / "we apply the steeper prior to Solomonoff's per-query solution, over $\mathcal H_\times$".
* "the per-query solution" always means Solomonoff's solution (10), i.e. $M_{\rm pq}$, whose hypotheses are the product hypotheses of $\mathcal H_\times$; on data sets (distinct inputs) its mixture is $M_{\rm prod}$.
* The default convention is restated once in Paper 2, in setup.tex where $M_F$ is recalled ("as in the companion paper, SOI without qualification means this version").

## Changes by file

**sections/abstract.tex.** First two sentences: "Solomonoff operator induction (SOI) predicts labels from inputs with a universal prior. We study Solomonoff's per-query solution, with private randomness at each input, under a complexity penalty steeper than log-likelihood by a factor λ>1, and give two reasons for it." "taken as one hypothesis" → "as one hypothesis" to stay within 1920 characters. Rest unchanged.

**sections/intro.tex.**
* Paragraph 1 rewritten at its start: Solomonoff's operator-induction problem (`\citep{solomonoff1999two,solomonoff2008three}`), i.e. supervised learning; Solomonoff's universal-prior Bayesian solutions and convergence theorem (`solomonoff2008three`); SOI as the family (`claudeSFI2026fundamentals`), the counterpart of SI. The proposal is now "for Solomonoff's per-query solution (`\citep[eq.~(10)]{solomonoff2008three}`)". End of the paragraph: private randomness "as in the per-query solution, which is the mixture with the prior $2^{-\ell(\pi)}$, the case λ=1".
* Credit footnote: "SFI itself first appeared in the author's working notes" → "The one-tape version of SOI first appeared in the author's working notes".
* Paragraph 2: "in SFI and in SI" → "in the per-query solution and in SI".
* Paragraph 3 (absorption): "It holds in SI and in the one-tape version of SOI, whose random bits are shared by all inputs (…); in the class of the per-query solution, where each input samples its own random bits, no hypothesis is universal (…)".

**sections/related.tex.** Novelty paragraph: the "Known" list now begins with "Solomonoff's operator-induction problem and his per-query solution with its convergence theorem \citep{solomonoff2008three}". The "new" list is unchanged.

**sections/setup.tex.**
* "Objects from the companion paper": "Solomonoff function induction (SFI) is the law $M_F$ …" → "The one-tape version of SOI is the law $M_F$ …; as in the companion paper, SOI without qualification means this version." "$M_{\rm pq}$ is the per-query mixture" → "the per-query mixture $M_{\rm pq}$, which equals $M_{\rm prod}$ on distinct inputs, is Solomonoff's per-query solution \citep[eq.~(10)]{solomonoff2008three}. We study this solution with the steeper prior $2^{-\lambda\ell}$, and the λ-MAP, over the same class $\mathcal H_\times$ of product hypotheses (Defs 3.3, 3.5, 3.6)." This is where the per-query class is introduced, so the citation of RENAME §4 Paper 2 item 4 is here (and in the introduction).
* `rem:setup:objects`(c): "SFI's expected loss would be infinite" → "the one-tape version's expected loss would be infinite".
* `def:setup:class`: "data sets for SFI" → "data sets for SOI"; $\mathcal H_\times$ "the class of the per-query solution: lsc conditional semimeasures …"; $\mathcal H_F$ "($M_F$, the one-tape version, on nonempty data sets)"; $\mathcal H_{\rm chr}$ "the law of SOI^hist, the history-aware version of SOI, whose hypotheses see the earlier inputs".

**sections/absorb.tex.**
* Opening: "In function induction there is a way out: if each input samples its own random bits, …" → "In operator induction there is a way out: if each input samples its own random bits, as in Solomonoff's per-query solution, …".
* `rem:absorb:examples`: "in $\mathcal H_F$ with $U=M_F$ (the one-tape version of SOI)".
* `thm:split:shared` title: "SI, or SFI with shared randomness, λ>1" → "SI, or the one-tape version of SOI, λ>1".
* §4.4: "Steeper SFI is therefore defined over $\mathcal H_\times$" → "We therefore apply the steeper prior to Solomonoff's per-query solution, over $\mathcal H_\times$"; "(SOI^hist)" → "(the history-aware version SOI^hist)".
* `rem:absorb:wyeth`: (i) "in SI, in the one-tape version of SOI, in the weak class and in the history-aware version SOI^hist"; (ii) "unavailable in $\mathcal H_\times$, the class of Solomonoff's per-query solution"; last paragraph "which SFI dominates" → "which the one-tape version dominates" (P1 Theorem 5.1(a) is the dominance of $M_F$ over machine laws).

**sections/kinks.tex.** Credit footnote: "this change of slope in function induction" → "in supervised learning" (the grokking note says "the function case").

**sections/recovery.tex.** `thm:split:lambda1` title: "SFI at λ=1" → "Solomonoff's per-query solution at λ=1".

**sections/limits.tex** and **sections/app-limits.tex** (opening of `app:limits:ood`): "steeper SFI extrapolates more reliably than SFI if they extrapolate well" → "with a steeper prior the per-query solution extrapolates more reliably than SOI if these hypotheses extrapolate well" ("they" → "these hypotheses" only to keep the referent clear after the change of subject).

**sections/app-absorb.tex.** `rem:absorb:why`: "so steeper SFI is defined over $\mathcal H_\times$" → "so we apply the steeper prior to Solomonoff's per-query solution, over $\mathcal H_\times$". `prop:absorb:inputs`: "as in SOI^hist" → "as in the history-aware version SOI^hist".

**sections/app-related.tex.** Last paragraph of `app:related:t5`: "not about function induction" → "not about operator induction"; "hold for steeper SFI" → "hold for the per-query solution with a steeper prior".

**sections/discussion.tex.** "What counts as one hypothesis": "ours is the private-randomness class of Solomonoff's per-query solution".

**OUTLINE.md.** Title updated; one paragraph on the rename and the convention.

**CLAIMS.md.** Title line; §1 absorption bullet ("the one-tape version of SOI"); rows 4.4 and 6.11 (new theorem titles).

**Not changed.** `main.tex` (no printed "SFI" besides the title, already done); `preamble.tex`, `core.bib`, `operator.bib` (not ours / already done); `imit.bib`, `steep-a.bib`, `steep-b.bib` (no occurrence); `parity.tex`, `teacher.tex`, `imit.tex`, `computable.tex` and the other appendices (no occurrence). `app-verification.tex` is switched off and has no operator-induction sentence; its old wording is left (RENAME §5). `%` comments and `\src` notes that still say SFI print nothing and stay. `bib/all.bib` and `main.pdf` are regenerated by the build.

## Version decisions (which version a statement is about)

1. **setup.tex, the definition of $M_F$.** Old "SFI" = $M_F$ → "the one-tape version of SOI", with the default convention.
2. **intro ¶1 footnote.** "SFI itself first appeared in the notes": SFI meant $M_F$ here, so "the one-tape version of SOI".
3. **intro ¶2, "in SFI and in SI".** It cites `thm:split:lambda1`, which is about $\mathcal H_\times$ on distinct inputs (mixture $M_{\rm prod}=M_{\rm pq}$), so "the per-query solution". The old wording did not mean $M_F$.
4. **intro ¶3, `thm:split:shared` title, `rem:absorb:wyeth`(i), CLAIMS §1.** "SFI with shared randomness" is the class $\mathcal H_F$ with $U=M_F$: "the one-tape version of SOI". Explicit, because absorption is where shared versus private randomness matters (RENAME §4 Paper 2 item 2).
5. **`rem:setup:objects`(c).** P1 Proposition 5.6 is stated for $M_F$ (and other data-set laws) under fresh noise on repeated inputs: explicit "the one-tape version".
6. **`def:setup:class`, "data sets for SFI".** Means the data-set laws, $M_F$ first: "SOI" by the default convention (still $M_F$).
7. **`rem:absorb:wyeth`, last paragraph.** P1 Theorem 5.1(a) is $M_F$'s dominance over machine laws; shared versus private randomness is the point of the sentence: explicit "the one-tape version".
8. **"Steeper SFI" (absorb.tex §4.4, `rem:absorb:why`, limits.tex, app-limits.tex, app-related.tex).** Always the steeper prior over $\mathcal H_\times$: "Solomonoff's per-query solution with a steeper prior".
9. **limits.tex / app-limits.tex, "… more reliably than SFI".** The comparison is with the un-steepened predictor; the appendix paragraph opens with $M_F$'s bound (P1 Proposition 8.1), so "SOI" by the default convention, still $M_F$. (At λ=1 the same bound holds for $M_{\rm prod}$, as the paragraph after `prop:limits:ood` says; that sentence is unchanged.)
10. **`thm:split:lambda1` title.** Class $\mathcal H_\times$, frozen labels on distinct inputs, $\xi_\times=M_{\rm prod}$, which equals $M_{\rm pq}$ on distinct inputs: "Solomonoff's per-query solution at λ=1".
11. **History-aware mentions.** "history-aware SFI", "SFI whose hypotheses see the earlier inputs", "(SOI^hist)": "the history-aware version SOI^hist".
12. **"function induction" as the setting** (absorb.tex opening, app-related.tex): "operator induction", the name of Solomonoff's problem; in the kinks.tex footnote, "supervised learning".

## Statements about Solomonoff (checked against the sources)

* The operator-induction problem: 2008 §4 ("unordered set of n strings and/or number pairs, [Q_i, A_i]. Given a new Q_{n+1}, what is the probability distribution over all possible A_{n+1}?"); 1999 §1 (question–answer pairs as examples of "stochastic operator induction"). Cited as `\citep{solomonoff1999two,solomonoff2008three}`.
* "Bayesian solutions with a universal prior, and a convergence theorem": 2008 §4.1–§4.3 (solutions (9) and (10), convergence theorem (12) for (10)).
* "Solomonoff's per-query solution (eq. (10))": 2008 §4.2; its hypotheses act independently at each question ($\prod_i O^j(A_i\mid Q_i)$), which is the private randomness of $\mathcal H_\times$. Identification with $M_{\rm pq}$ as in RENAME §2.
* Novelty paragraph, "his per-query solution with its convergence theorem": 2008 §4.3.

## For other groups

* **Paper 1, `steeper.tex` (summary of Paper 2).** Paper 2 now says: it studies Solomonoff's per-query solution (his eq. (10), $M_{\rm pq}$; the class $\mathcal H_\times$) with the steeper prior $2^{-\lambda\ell}$ and the λ-MAP; absorption holds in SI, the one-tape version $M_F$, the weak class and SOI^hist; the per-query class has no universal member; `thm:split:lambda1` is titled "Solomonoff's per-query solution at λ=1".
* **Paper 1, statements Paper 2 cites by number and now names by version:** Proposition 5.6 (`prop:learn:freshnoise`) as a statement about the one-tape version; Theorem 5.1(a) (`thm:learn:dominance`) as the one-tape version's dominance; Proposition 5.7 (`prop:learn:perquery`) for $M_{\rm pq}$; Proposition 8.1 (`prop:ood:hanni`) for $M_F$. Numbering is frozen, so the numbers stay valid; please keep these statements about the same objects.
* **Credit wording (Paper 1 front).** Paper 2's credit footnote says "The one-tape version of SOI first appeared in the author's working notes"; Paper 1's footnote (RENAME §3) says "The author's working notes call this setting function induction". Both are consistent; if Paper 1 words the credit differently, tell p2 so that the two papers match.
* **`core.bib`.** Unchanged by p2. The `note` of `hanni2026notes` still prints "Solomonoff function induction" (allowed exception); `diff paper/bib/core.bib paper-steeper/bib/core.bib` should stay empty.
* **Paper 2 `preamble.tex`** (not ours): its `%` comments still say SFI; nothing printed.
