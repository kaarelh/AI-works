# Check of Paper 1 after the rename to Solomonoff operator induction (fresh checker, 2026-10-15)

Binding: `rename/RENAME.md`, then `REFRAME.md` and `DECISIONS.md` where RENAME does not override them. Primary sources: the text extractions of Solomonoff (2008) and (1999) named in RENAME §2. I read both in full before checking.

This file is also this group's log: §6 lists every file I changed, §7 my version decisions, §8 what other groups or the lead editor must do.

## 0. Result

| step | result |
|---|---|
| 1. Diff | Every changed sentence names the right object. No formula, hypothesis, number, proof step or caveat was removed (mechanical check below). Two sentences were imprecise about versions; I fixed them (F2, F5). |
| 2. Statements about Solomonoff | All match the primary sources. Two overstatements fixed: F4 (eq. (10) is ours only "in our formalisation") and F3 ("Solomonoff's papers" → "these two papers"). |
| 3. Greps | 0 hits for `SFI`, "in this/the spirit" and "unverified" in the PDF. "function induction" appears only in the footnote and the notes' reference entry (both allowed), plus the repository folder name `solomonoff-function-induction` in URLs, which must stay. |
| 4. Build and numbering | 0 errors, 0 undefined references, 0 undefined citations, 0 multiply defined labels, 0 overfull boxes above 10pt (largest 1.84pt); 93 pages. Numbering check: 314 labels before, 314 after, 0 differ. |
| 5. Referee reading | The relation to Solomonoff is now stated accurately. Two framing fixes in the introduction (F1, F2) and one attribution in the contributions list (F6). |

## 1. Step 1: the diff

**Base.** Most of the edits are already in the WIP commits 1c6ff5eb and e2088079, which the editor groups did not make. So I reviewed `git diff abbbe387 -- paper/` against the working tree. abbbe387 is the first commit after the RENAME brief. That diff covers 26 files: all section files, CLAIMS.md, OUTLINE.md, NOTATION.md and all.bib. I also reviewed the pre-done changes of a09c0205 (preamble macros, titles, `core.bib` titles, the two `setting.bib` entries); all of them are correct.

**Mechanical check that no mathematics changed.** For each changed section file I compared the multiset of `$…$` and `\[…\]` segments before and after, outside comments and `\status`/`\src`.
* Removed math: none, in every file.
* Added math falls into three kinds:
  * names: `$\MF$` (app-learn ×3, learn ×3, setting ×1, versions ×5), `$\nu$`, `$\nu=\MF$`, `$\Mprod$`, `$\Mpq$`;
  * Solomonoff's formulas in `rem:versions:operator`: eq. (10), $a^j_0\approx2^{-l(O^j)}$, $\Mpq(A_{1:n+1}\Vert Q_{1:n+1})$;
  * restatements of bounds the paper already proves: $K(\dom D)+O(1)$ (from `thm:versions:chain`), $K(\dom f)\le K(d)+O(1)$ and $O(\log d)$ in examples.tex, $k\ln2$ (Solomonoff's eq. (12)), $2^{-\lambda\ell}$ in steeper.tex.

**Prose caveats.** I read the word diff of every file.
* No caveat was removed.
* One caveat was added: the abstract's "under finiteness assumptions", in the reveal-law sentence. It matches `cor:hist:thm1` and the introduction ("under finiteness hypotheses"). It narrows the claim to what is proved, so I kept it.
* The abstract also gained "and no order-independent predictor pays less in expectation". This is `prop:ex:orderfree`(b) ($\Ex[-\log\nu(f)]\ge\log((N-1)!)$ for every weak $\nu$) and was already in Theorem D. So it adds no result.

**Version check, file by file.** Every plain "SOI" that replaced "SFI" is a statement about $\MF$, $\LSFI$ or $\MFbar$, so the default convention keeps its meaning. Where the old text meant the family, it now says the family: the versions opening, $W$ "of SOI", `rem:learn:positive`, "circuit SOI", "Time-bounded SOI". Explicit names appear wherever RENAME §3 requires them:
* repeated inputs and fresh noise: `prop:learn:freshnoise`, `rem:ex:fresh`, `rem:comp:distinct`, the end of examples.tex, the discussion;
* shared versus private randomness: `rem:versions:randomness`, Formulation C, `prop:hist:sketchfails` and the line after it, `app:hist:exploit`, steeper.tex;
* the per-query proposition: `prop:learn:perquery` and its credit;
* the private-randomness class: steeper.tex, `rem:comp:uniformties`;
* absorption: steeper.tex, discussion.

Points I checked against the statements themselves:
* `prop:learn:freshnoise`. The title "the one-tape version cannot model fresh label noise" is narrower than (a) and (b), which hold for every weak $\nu$; the statement says so. Part (c) now ends "fails for the one-tape version $\MF$", which is correct: it holds for $\Mpq$ by `prop:learn:perquery`(c).
* The proof of `cor:learn:perstep`(b) now says "$\nu$ sees its data as a set" (was "SFI"). This is correct, because the corollary is for $\nu\in\{W,\MF\}$.
* `def:hist:sfihist`: "the history-aware version of SOI, is the one-tape version over $X_H$". This is correct: $\MH$ is the law of the universal function machine on $X_H$.
* The new sentences in examples.tex check out against the statements:
  * `prop:ex:orderfree`(a) is stated "for every law $\nu$ of a random partial function, computable or not".
  * $\Mprod=\sum_i\mm(i)\prod P_i$ is a sub-probability mixture of laws of random partial functions, so its losses are at least those of such a law.
  * The inputs of the cycle are distinct, so $\Mpq=\Mprod$ there (`prop:learn:perquery`(a)).
  * `prop:ex:cycset` says \SFIset{} pays $\log((N-1)!)$ in expectation.
  * `rem:ex:where`: a predictor that sees the previous *pairs* as a set pays nothing. This does not conflict, because \SFIset{} sees only the previous inputs.
* `prop:ex:law`(b) is for every weak $\nu$. $\Mpq=\Mprod$ is weak on the distinct inputs of Eisenstat's example, so "also binds Solomonoff's per-query solution" is correct.
* "$\Mpq$ … the per-query solution can [model fresh noise]" (abstract, intro, discussion) is `prop:learn:perquery`(b),(c).
* "The per-query solution has the analogous bound against samplers that see only the input, on every sequence" (Theorem A) is `prop:learn:perquery`(b).
* `rem:setting:recommend` and the default-convention sentence after `def:setting:sfi` agree with DECISIONS §F13. The convention is stated once. The introduction only points to it ("our default (\cref{sec:setting:sfi})").

**Planning files.** In CLAIMS.md, OUTLINE.md and NOTATION.md the names are updated. The operator-induction rows (`rem:versions:operator`, `prop:learn:perquery`, `prop:hist:operator`, C1, `rem:related:new`) agree with the paper. For a leftover in a status column, see §8.

**Not printed.** `app-verification.tex` is switched off. Its operator-induction row and its literature paragraph were updated as RENAME §5 asks; two other "SFI" mentions remain in its corrections table (lines 62 and 65), as RENAME §5 allows.

## 2. Step 2: statements about Solomonoff against the primary sources

| statement (where) | source | verdict |
|---|---|---|
| Solomonoff posed operator induction, predicting the answer to a new question from an unordered set of question–answer pairs, and gave universal-prior solutions with a convergence theorem (abstract) | 2008 §4: "we are given an unordered set of n strings and/or number pairs, [Qi, Ai]. Given a new Qn+1, what is the probability distribution over all possible An+1? We will give two solutions." §1: "The Qs can be questions …, the As can be associated answers"; "two solutions … based on universal distributions, and … associated convergence theorems" | correct; "(supervised learning)" is our gloss (§1 lists identification, categorisation, curve fitting) |
| operator induction [Sol99, Sol08]: find the distribution of the answer to a new question; "in the second paper he gave two solutions with universal priors and proved a convergence theorem for one of them" (intro) | 1999 §1 (question–answer pairs; "stochastic operator induction"); 2008 §4.1, §4.2, §4.3 "Convergence Proof" for (10) | correct; 1999 gives solutions only for unordered sets of strings, so "in the second paper" is right |
| Solomonoff's per-query solution "mixes computable conditional distributions of the answer given the question, with an independent factor for each question" (intro) | 2008 eq. (10), $\sum_ja^j_0\prod_{i=1}^{n+1}O^j(A_i\mid Q_i)$, $O^j$ "the jth possible conditional probability distribution", summed "over all partial recursive functions" | correct ("computable" glosses "computed by partial recursive functions") |
| 1999 "describes the prediction of answers … as an example of stochastic operator induction, the search for a stochastic map from questions to distributions on answers" (related) | 1999 §1: "may also be thought of as examples of 'stochastic operator induction'. … we want a stochastic function so that when we give it xj as input, it will give the probability distribution of yj … insert our 'question' into the stochastic operator, we want a probability distribution on 'answers.'" | correct |
| (9): "a joint one, which treats each pair as one string and so also models the questions" (related); "treats each question–answer pair as one string, predicts with his universal mixture over unordered sets of strings, and conditions on the new question; it also models the questions" (Remark 4.2) | 2008 §4.1: $D_i=(Q_i,A_i)$, eq. (6) and (7) give $P(Q_{n+1},A_{n+1})$, eq. (9) divides by $\sum_iP(Q_{n+1},A_i)$; end of §4.3: "(9) … includes regularities in the set [Qi]" | correct |
| (10): "takes the probability of the new answer $A_{n+1}$ to be $\sum_ja^j_0\prod_{i\le n+1}O^j(A_i\mid Q_i)$ … computed by partial recursive functions, with weights $a^j_0\approx2^{-l(O^j)}$; with the lsc conditional semimeasures $P_i$ for the $O^j$ and $\mm(i)$ for the weights, this is $\Mpq$" (Remark 4.2) | 2008 §4.2, verbatim in substance | correct; the identification is stated as a formalisation |
| eq. (12): "if the answers come from a probabilistic algorithm describable in $k$ bits, then for any given sequence of questions the expected squared error of the predicted probabilities, summed over all symbols of all answers, is less than $k\ln2$" (related); the same in learn.tex after `prop:learn:perquery`, "(in binary, with separators)" | 2008 §4.3: "created by a probabilistic algorithm, μ(Ai\|Qi) and that μ can be described with k bits"; "μ(Zl) is the probability that μ assigns to Zl in view of the sequence of Qs"; ternary alphabet {0,1,s}; "summed over the individual symbols of all of the Ai, will be less than k ln 2" | correct, including the hypotheses: expected squared error, any given question sequence, k bits, "less than" |
| "he notes that the proofs of the underlying sequence-prediction theorems also give the bound for Kullback–Leibler loss (his Section 2)" (learn.tex) | 2008 §2: "The proofs of the theorems also show the same convergence for the Kullback-Liebler loss function" (said of the sequence-prediction theorems) | correct; the paper does not claim that he states (12) for KL |
| "the standard dominance argument, which also underlies Solomonoff's convergence theorem" (learn.tex); "Solomonoff's convergence theorem is its expected squared-error form" (Theorem A) | 2008 §4.3: the error is "less than – ln c, c being the largest positive number such that P/μ > c" | correct |
| Known: "Solomonoff's operator-induction problem, his two solutions and the convergence theorem for his per-query solution, with expected squared error less than $k\ln2$" (novelty) | as above | correct |
| "His eq. (10) is our per-query solution $\Mpq$" (related) | — | **fixed (F4)**: "our" claimed the solution; now "is, in our formalisation, the per-query solution $\Mpq$" |
| "it and the coin-free, Kolmogorov and history-aware versions do not appear in Solomonoff's papers" (related) | true of the two papers read; a claim about all of Solomonoff's work was not checked | **fixed (F3)**: "do not appear in these two papers"; the novelty paragraph's "to our knowledge" covers the rest |
| "$\Mpq$ is Solomonoff's second solution, his eq. (10) (Remark 4.2)" (learn.tex); "his eq. (10) for the operator-induction problem" (app-hist) | — | correct, with the pointer to the formalisation in Remark 4.2 |
| "These hypotheses form the class of Solomonoff's per-query solution" (steeper.tex) | eq. (10): each $O^j$ is applied independently at each question | correct |
| Bib entries (printed): Solomonoff 1999, Comput. J. 42(4):256–259; Solomonoff 2008, 51(5):566–570, doi 10.1093/comjnl/bxm120 | 2008 title page and doi | correct. Solomonoff's own reference [10] says "Comput. J., 64", evidently a misprint; 42(4) is right. |

Nothing printed attributes to Solomonoff anything about $\MF$, $W$, $\KF$, $\MH$ or the comparisons. Solomonoff (2008) numbers its sections inconsistently: §1 says "Section 3 deals with operator induction", but the heading is "4. OPERATOR INDUCTION". The paper cites §4, as the headings do.

## 3. Step 3: greps

**Sources** (`sections/*.tex`, `main.tex`):
* `SFI`. All hits are justified:
  * macro names (`\LSFI`, `\SFIhist`, …), labels, `\cref` arguments, bib keys, `\ifsfirecord`;
  * `%` comments and `\status`/`\src` notes, which print nothing;
  * `app-verification.tex:62,65`, which is switched off (RENAME §5).
  
  A filtered scan, run after stripping all of these, finds no other hit.
* "function induction": only `setting.tex:4`, the allowed footnote.
* "in this spirit" / "in the spirit": 0 hits.
* "unverified": only inside `\status{…}` tags and `%` comments. None is about operator induction. They concern Littlestone/Barzdin–Freivalds, Zvonkin–Levin, LHG, Hutter's identification and the slides.

**PDF** (`pdftotext main.pdf`; also on text with line breaks and hyphenation joined):
* `SFI`, case-sensitive: 0 hits. A case-insensitive search matches only "satisfies".
* "function induction":
  * the footnote "The author's working notes call this setting function induction (Hänni, 2026c)";
  * the reference entry of `hanni2026notes` ("The note on Solomonoff function induction is in the folder …").
  
  Both are allowed by RENAME §3. The joined text also contains the repository folder name `solomonoff-function-induction` in the Code and data URL and in the notes of the two `claudeSFI` entries. That is the actual path and must stay.
* "in this spirit" / "in the spirit": 0 hits.
* "unverified": 0 hits.
* No occurrence of "operator" within 300 characters of "unverified", "snippet", "not checked", "abstract seen/only" or "secondary".
* DECISIONS §A5 process-vocabulary grep: only the allowed "referees" in the title footnote, plus $h_1$ inside a formula.

## 4. Step 4: build and numbering

Full build: `cd paper && flock /tmp/claude-0/paper-build-sfi.lock ./build.sh`, run after my last edit.
* 0 LaTeX errors;
* 0 undefined references;
* 0 undefined citations;
* 0 multiply defined labels;
* 0 overfull boxes above 10pt (the three remaining are 1.84pt, 0.86pt and 0.84pt);
* 93 pages.

Numbering: `python3 research/paper-review/rename/check_numbering.py research/paper-review/rename/aux-before/paper1-main.aux paper/main.aux` reports 314 labels before, 314 after, 0 differ.

Length (non-empty lines, `pdftotext -layout`):
* introduction 166 (164 before my fixes; 146 before the rename);
* related work 83 (unchanged by my fixes);
* discussion 96;
* abstract unchanged at 1914 characters.

Section 3 still starts on p. 8.

## 5. Step 5: abstract and introduction read as a referee would

**What Solomonoff did.**
* The abstract's first sentence and the introduction's opening state his problem, his two solutions and his convergence theorem correctly.
* Related work and Remark 4.2 give the details of (9), (10) and (12), and the novelty paragraph lists them as known.
* Theorem A credits eq. (12) as the expected squared-error form of the per-query bound.

**What is new.**
* The one-tape version is "our default", and its credit footnote goes to the author's notes.
* The comparisons of the versions and the rest of the novelty list are claimed "to our knowledge".

**What is only a new name.** The introduction says "We call the family of such solutions Solomonoff operator induction (SOI)". The abstract says "We study several versions of Solomonoff operator induction (SOI)" without marking the name as ours. That is acceptable: the abstract is at 1914 of 1920 characters, and the introduction marks the name at once.

**Misleading points found and fixed:**
* F1: "On distinct inputs, little" overstated the agreement.
* F2: "see the data as a set" is false for $\Mpq$ on repeats.
* F6: the contributions list put "its repairs (… `prop:learn:perquery`)" among our contributions without saying that the per-query solution is Solomonoff's.

**Considered and left unchanged:**
* "Solomonoff axiom induction" in "Why SOI". RENAME §4 item 2 prescribes it, and its footnote credits the author's notes.
* "(supervised learning)", and "computable" for "partial recursive". These are fair glosses.
* The discussion's reasons for the default include an order-independent semimeasure-convention loss. All weak $\nu$ share this property, so it does not distinguish $\MF$, but it is true. It was there before the rename.

## 6. Fixes made (files changed by this group)

| id | file | old | new | reason |
|---|---|---|---|---|
| F1 | `sections/intro.tex`, ¶"How much the version matters" | "On distinct inputs, little: on data sets all versions but the history-aware one agree up to $K(\dom D)+O(1)$ bits" | "On distinct inputs, little when the set of inputs is simple: on data sets …" | The agreement is up to $K(\dom D)$. That is large on the chain example and linear on the witnesses of `thm:setting:weakvsmachine`(iii), and Section 4 and the discussion say the gaps are unbounded. "Little" unqualified overstated it. No mathematics changed. |
| F2 | `sections/intro.tex`, ¶"Relation to Solomonoff induction" | "all versions but the history-aware one see the data as a set" | "… see the data as an unordered set (a multiset, for the per-query solution)" | `prop:learn:perquery`(a): $\Mpq$ depends on the multiset of pairs; a repeated pair gives a second factor. |
| F3 | `sections/related.tex`, operator-induction paragraph | "do not appear in Solomonoff's papers" | "do not appear in these two papers" | Only the two papers were read. A negative claim about all of Solomonoff's work is unchecked (DECISIONS §A8). |
| F4 | `sections/related.tex`, same paragraph | "His eq. (10) is our per-query solution $\Mpq$" | "His eq. (10) is, in our formalisation, the per-query solution $\Mpq$" | "Our" read as claiming his solution. The identification is a formalisation (lsc conditional semimeasures for his $O^j$, $\mm(i)$ for his weights), as Remark 4.2 states. |
| F5 | `sections/examples.tex`, separation summary of §7.2 | "The cost does not depend on the version:" | "The cost is the same for every order-free version:" | The same paragraph says that the history-aware version \SFIhist{}, a version of SOI, pays $O(1)$, so the old sentence contradicted itself. The supporting results (`prop:ex:orderfree`, `thm:versions:chain`) concern the order-free versions. |
| F6 | `sections/intro.tex`, contributions, learning bullet | "the failure of the one-tape version under fresh label noise on repeated inputs and its repairs (…)" | "… and its repairs, among them Solomonoff's per-query solution (…)" | The repair by per-query mixing is Solomonoff's eq. (10). Without the attribution, the contributions list read as claiming it. learn.tex already says "The repairs are stamps and frozen noise … and Solomonoff's per-query solution". |

`main.pdf` was rebuilt. No other file was changed. No git command that changes repository state was run.

## 7. Version decisions

* **F1:** Kept the RENAME §4 headline ("little" on distinct inputs) and stated when it holds. The precise statement follows the colon, as before.
* **F2:** "Unordered" covers $\KF,W,\Mprod,\MF,\Mw$ (data sets, `prop:setting:order`) and $\Mpq$ (multisets).
* **F5:** "Order-free version" means the versions of `sec:versions` and $\Mpq$, which are all weak on distinct inputs. It excludes \SFIhist{}, as the paragraph's last sentence already says.
* **F6:** The per-query solution is named as Solomonoff's, as in learn.tex. The proposition `prop:learn:perquery` stays among the contributions because parts (a), (c) and (d) and the pathwise form (b) are proved here.

## 8. For other groups and the lead editor

1. **Lead editor, length:**
   * the introduction is now 20 lines longer than before the rename (146 → 166), 2 of them from F1, F2 and F6;
   * related work is 11 lines longer;
   * the paper is 93 pages (92 before).
   
   The cheapest cut is the one log-p1-front §5 item 3 names: the Hutter sentence in "Relation to Solomonoff induction", which repeats related work (2 lines). DECISIONS §F2 prescribes it, so I left it.
2. **Lead editor, RENAME §2:** I confirm log-p1-front §5 item 1. In 1999 §1 the two examples called "stochastic operator induction" are number pairs $[x_i,y_i]$ and question–answer pairs. Supervised categorisation (the mushrooms) is the paragraph before them. Nothing printed repeats the inaccuracy.
3. **CLAIMS.md (planning file, not printed):** the `rem:related:new` row still has the status "known (snippets; unverified)", although its text now records Solomonoff 2008 as read in full. If the planning files are updated again, write "known (Solomonoff 2008 read in full; the other items at snippet level)". I did not edit it: RENAME §5 limits planning-file edits to names.
4. **Paper 2:** nothing needed. I grepped `paper-steeper/sections` for the phrasings fixed here ("Solomonoff's papers", "our per-query solution", "see the data as a set", "On distinct inputs, little"): 0 hits. Paper 1's numbering is unchanged.
5. **Repository state:** my edits (F1–F6) and the rebuilt `main.pdf` are uncommitted in the working tree, on top of WIP commit e2088079.
