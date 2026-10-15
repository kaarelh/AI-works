# Fresh check of Paper 2 (`paper-steeper/`) after the rename to Solomonoff operator induction

I am a checker who had not seen the paper before this pass. This file is also the log of my edits.

**Read in full first:**
* the binding notes `RENAME.md`, `REFRAME.md` and `DECISIONS.md`;
* the editors' log `log-p2.md`;
* the text extractions of Solomonoff (2008) and Solomonoff (1999) named in RENAME §2.

**Diff base.** The rename edits were committed while I worked, by someone else, in the work-in-progress commit `1c6ff5eb`. So every diff below is taken against `9b5cd936`, the last commit before the rename edits of `paper-steeper/`. I ran no git command that changes repository state.

## Result in brief

* Every renamed sentence names the right version.
* No mathematics changed.
* Every statement about Solomonoff's work is supported by the two papers.
* All the RENAME §5 greps come back empty except for the allowed hits.
* Full build: 0 errors, 0 undefined references, 0 undefined citations, 0 multiply defined labels, 0 overfull boxes above 10pt.
* Numbering check: 241 labels before and after, 0 differ.
* All 25 numbered citations of Paper 1 point to the intended results.

**Fixes:**
* One fairness fix in the introduction: the family name SOI is now marked as our name.
* One clarity fix, made in two places (`limits.tex` and `app-limits.tex`): "than SOI" becomes "than the one-tape version", because the subject of the sentence is itself a version of SOI.

## Step 1. The diff, sentence by sentence

Files changed by the editors: `abstract.tex`, `intro.tex`, `related.tex`, `setup.tex`, `absorb.tex`, `app-absorb.tex`, `kinks.tex`, `recovery.tex`, `limits.tex`, `app-limits.tex`, `app-related.tex`, `discussion.tex`, `CLAIMS.md`, `OUTLINE.md`.

### Is the right version named?

The test throughout: the old "SFI" meant $M_F$ in Paper 2, because `setup.tex` defined it so. "Steeper SFI" meant the steeper prior over $\mathcal H_\times$.

**abstract.tex**
* "SOI predicts labels from inputs with a universal prior" refers to the family. OK.
* "We study Solomonoff's per-query solution, with private randomness at each input, under a complexity penalty …" replaces "… for private-randomness hypotheses". The scope is the same, since $\mathcal H_\times$ is the class of $M_{\rm pq}$. OK.

**intro.tex, ¶1**
* The problem, Solomonoff's solutions and the family: checked against the sources in Step 2.
* "the per-query solution, which is the mixture with the prior $2^{-\ell(\pi)}$, the case $\lambda=1$". This is $\xi_1=\sum_\pi2^{-\ell(\pi)}\nu_\pi$ over $\mathcal H_\times$, which equals $M_{\rm prod}$, and $M_{\rm pq}$ on per-query samples. Correct.
* Footnote: "The one-tape version of SOI first appeared in the author's working notes". The old "SFI itself" meant $M_F$. This is consistent with Paper 1's footnote in `setting.tex`, which attaches "The author's working notes call this setting function induction" to the one-tape definition. OK.

**intro.tex, ¶2.** "In the per-query solution and in SI" cites `thm:split:lambda1`. That theorem concerns $\mathcal H_\times$, with frozen labels on distinct inputs and $\xi_\times=M_{\rm prod}$. On distinct inputs $M_{\rm prod}=M_{\rm pq}$ (Paper 1, Prop 5.7(a)). Correct.

**intro.tex, ¶3.** "It holds in SI and in the one-tape version of SOI, whose random bits are shared by all inputs; in the class of the per-query solution … no hypothesis is universal." This matches `thm:absorb:absorption`, `thm:split:shared` and `cor:absorb:nouniversal`. Shared and private randomness are named explicitly, as RENAME §4 (Paper 2, item 2) requires. OK.

**related.tex, Novelty.** "Known are Solomonoff's operator-induction problem and his per-query solution with its convergence theorem". Correct (Step 2). The "new" list is unchanged and claims nothing that is Solomonoff's. OK.

**setup.tex, "Objects from the companion paper"**
* "The one-tape version of SOI is the law $M_F$ …; as in the companion paper, SOI without qualification means this version." This is the default convention, stated once. OK.
* "the per-query mixture $M_{\rm pq}$, which equals $M_{\rm prod}$ on distinct inputs, is Solomonoff's per-query solution [Sol08, eq. (10)]". This is the identification fixed in RENAME §2, and the equality is Paper 1's Prop 5.7(a). OK.
* "We study this solution with the steeper prior $2^{-\lambda\ell}$, and the λ-MAP, over the same class $\mathcal H_\times$". OK.

**setup.tex, `rem:setup:objects`(c).** "the one-tape version's expected loss would be infinite [P1, Prop 5.6]". Paper 1's Prop 5.6 covers $M_F$, $W$, $M_{\rm prod}$ and $M_w$. The old "SFI's" meant $M_F$, so the statement still means $M_F$ and remains true. OK.

**setup.tex, `def:setup:class`**
* "data sets for SOI" was left unchanged; see Decision 3 below.
* "$\mathcal H_\times$, the class of the per-query solution". OK.
* "$\mathcal H_F$ … ($M_F$, the one-tape version, …)". OK.
* "$M_H$, the law of SOI^hist, the history-aware version of SOI, whose hypotheses see the earlier inputs". OK.

**absorb.tex**
* Opening: "In operator induction there is a way out: if each input samples its own random bits, as in Solomonoff's per-query solution, …". OK.
* `rem:absorb:examples`: "$U=M_F$ (the one-tape version of SOI)". OK.
* `thm:split:shared`, title only: "SI, or the one-tape version of SOI". The statement assumes (Dom). The title names the main example, as the old title "SFI with shared randomness" did. OK.
* §4.4: "We therefore apply the steeper prior to Solomonoff's per-query solution, over $\mathcal H_\times$". OK.
* "(the history-aware version SOI^hist)". OK.
* `rem:absorb:wyeth`(i) and (ii): the versions are named explicitly. OK.
* `rem:absorb:wyeth`, last paragraph: "which the one-tape version dominates [P1, Thm 5.1(a)]". Paper 1's Thm 5.1(a) is $M_F$'s dominance over every lsc conditional semimeasure. OK.

**app-absorb.tex**
* `rem:absorb:why` (same wording as absorb.tex §4.4). OK.
* `prop:absorb:inputs`: "as in the history-aware version SOI^hist". OK.

**kinks.tex, footnote.** "in function induction" becomes "in supervised learning". This is a neutral paraphrase of the setting, and the credit is unchanged. OK.

**recovery.tex, `thm:split:lambda1` title.** "Solomonoff's per-query solution at λ=1". The class is $\mathcal H_\times$ on distinct inputs, where $\xi_\times=M_{\rm prod}=M_{\rm pq}$. OK.

**limits.tex and app-limits.tex.** "with a steeper prior the per-query solution extrapolates more reliably than SOI". By the default convention SOI is $M_F$, the old meaning, but the subject of the sentence is itself a version of SOI, so "than SOI" reads as a member compared with its own family. **Fixed:** see Fix 2.

**app-related.tex.**
* "not about operator induction". OK.
* "hold for the per-query solution with a steeper prior". OK.

**discussion.tex.** "ours is the private-randomness class of Solomonoff's per-query solution". OK.

**CLAIMS.md and OUTLINE.md.** The names are updated, and no "SFI" remains (grep: 0).

### No mathematics changed

* I compared every math segment (`$…$`, `\[…\]` and `equation`) of each changed file with the version in `9b5cd936`. The script is `/tmp/claude-0/-home-user-AI-works/c4435474-536f-5a96-a73c-7d0c5ea93659/scratchpad/checkp2/mathdiff.py`.
* No math segment was removed or changed, except:
  * the opening of the introduction lost "a label $y$ from an input $x$" (framing);
  * the introduction gained "$2^{-\ell(\pi)}$, the case $\lambda=1$", which identifies the λ=1 case;
  * `setup.tex` gained "$M_{\rm prod}$, $2^{-\lambda\ell}$, $\lambda$-MAP, $\mathcal H_\times$" in the framing sentence.
* Inside environments, only two theorem titles and the naming parentheses listed above changed.
* No hypothesis, number, proof step or caveat changed. My two fixes add no mathematics.

## Step 2. Statements about Solomonoff, checked against the primary sources

| Paper 2 text | where | source |
|---|---|---|
| "Solomonoff's operator induction problem asks for the probability of each answer to a new question, given an unordered set of question–answer pairs [Sol99, Sol08]" | intro ¶1 | 2008 §4: "we are given an unordered set of n strings and/or number pairs, [Q_i, A_i]. Given a new Q_{n+1}, what is the probability distribution over all possible A_{n+1}?"; 2008 §1: Qs as questions, As as answers. 1999 §1: question–answer pairs as examples of "stochastic operator induction" (the term). Supported. |
| ": supervised learning" | intro ¶1 | Our gloss. 2008 lists the identification, categorisation and curve-fitting problems; 1999 calls the mushroom example "the supervised categorization problem". Fair. |
| "Solomonoff gave Bayesian solutions with a universal prior, and a convergence theorem [Sol08]" | intro ¶1 | 2008 §4.1, §4.2: two solutions "based on universal distributions", (9) and (10); §4.3: eq. (12), for (10). Supported. It does not say which solution the theorem is for, and it attributes nothing beyond the paper. |
| "Solomonoff's per-query solution [Sol08, eq. (10)]" | intro ¶1, setup, absorb, discussion, `thm:split:lambda1` | 2008 eq. (10): $\sum_j a_0^j\prod_{i=1}^{n+1}O^j(A_i\mid Q_i)$, an independent factor per question. "Per-query solution" is our name for it. Its identification with $M_{\rm pq}$ is fixed by RENAME §2. Supported. |
| "his per-query solution with its convergence theorem [Sol08]" | related, Novelty | 2008 §4.3, eq. (12), is stated for the distribution of (10). Supported. |

Not used in Paper 2:
* the details of eq. (12): expected squared error, any question sequence, k bits, k ln 2;
* the joint solution (9);
* the 1999 term "stochastic operator induction", which the citation `solomonoff1999two` supports in the introduction but which is not quoted.

So nothing is attributed beyond what the papers say. The bib entries `solomonoff2008three` and `solomonoff1999two` in `bib/operator.bib` print correctly (reference list: Comput. J. 51(5):566–570, 2008, with DOI; 42(4):256–259, 1999).

## Step 3. Greps of RENAME §5

**Sources** (`sections/*.tex`, `main.tex`; `%` comments, bib keys `claudeSFI2026*`, macro names `\SFI…` and `sfirecord` ignored, `app-verification.tex` not printed):
* `SFI`: none in printed text.
* `function induction`: none.
* `in this spirit`: none.
* `unverified`: only inside `\status{…}` of `prop:algstat:coarse` and `rem:algstat:restricted` and in `%` comments of `related.tex`. These print nothing and are not about operator induction.

**`pdftotext main.pdf`**, also with line breaks and hyphenation joined:
* `SFI`: 0. Case-insensitive, the 13 hits are all inside "satisfies".
* `function induction`: one hit, the reference-list entry of `hanni2026notes` ("The note on Solomonoff function induction is in the folder …"). This is the allowed exception of RENAME §3.
* `in this spirit`: 0.
* `unverified`: 0.
* `Wyeth`: 0.
* The DECISIONS §A5 process-vocabulary grep: only "independent AI referees" in the title-page footnote (allowed).
* Not a hit, but noted: the reference entry of the companion paper prints the repository folder name `solomonoff-function-induction`. That is a path, not the name of the method.

## Step 4. Full build and numbering

`cd paper-steeper && flock /tmp/claude-0/paper-build-sfi.lock ./build.sh` (run twice, the second time after my last source change, which was a comment):

* LaTeX errors: 0
* Undefined references: 0
* Undefined citations: 0
* Multiply defined labels: 0
* Overfull boxes above 10pt: 0 (two below 3pt, 1.84pt and 2.75pt, as before)
* Pages: 87, as before.
* `bib/core.bib` is identical in both papers.
* `check_numbering.py aux-before/paper2-main.aux paper-steeper/main.aux`: 241 labels before, 241 after, 0 differ.

## Step 5. The abstract and introduction, read as a referee who knows Solomonoff's work

**What he did** is stated accurately:
* the operator-induction problem, cited to both papers;
* Bayesian solutions with universal priors;
* a convergence theorem;
* the per-query solution, eq. (10), named as his.

**What is new** is stated accurately:
* the steeper prior $2^{-\lambda\ell}$ and the λ-MAP applied to his per-query solution, with λ=1 being his solution;
* the absorption contrast, with the one-tape version as the companion paper's object, not his;
* the Novelty list, which puts his problem, his solution and his theorem among the known items.

**What is only a new name.** Before my fix the introduction said "the family of such solutions is *Solomonoff operator induction* (SOI) [companion paper]". A reader could take SOI for an established term. **Fixed (Fix 1)**: "as in the companion paper [ref], we call the family of such solutions *Solomonoff operator induction* (SOI). It is the supervised-learning counterpart of …".

**Abstract.** "Solomonoff operator induction (SOI) predicts labels from inputs with a universal prior. We study Solomonoff's per-query solution, …" I left it unchanged:
* it attributes to Solomonoff only the per-query solution, which is his;
* it claims no provenance for the name;
* it is at 1919 of the 1920 characters allowed (DECISIONS §F28), so a provenance clause would need cuts elsewhere.

The introduction now carries the provenance.

## Step 6. Citations of Paper 1 by number, and the names of Paper 1's objects

**Numbers.** Every `\cite…[…]{claudeSFI2026fundamentals}` with a number was mapped, through its `% P1:` comment, to the label's number in `paper/main.aux`. Paper 1's numbering check against its own snapshot also shows 0 differences. The script is `/tmp/claude-0/-home-user-AI-works/c4435474-536f-5a96-a73c-7d0c5ea93659/scratchpad/checkp2/p1cites.py`.

| Paper 2 place | printed | P1 label | number in P1 |
|---|---|---|---|
| absorb.tex:91 | Theorem 5.1(a) | `thm:learn:dominance` | 5.1 |
| absorb.tex:96 | Question 3.14 | `q:setting:rpf` | 3.14 |
| app-absorb.tex:9 | Theorems 3.11, 3.8, 6.16; Corollary 6.17 | `thm:setting:weakuniversal`, `thm:setting:universal`, `thm:hist:representation`, `cor:hist:H4` | 3.11, 3.8, 6.16, 6.17 |
| app-absorb.tex:29, setup.tex:48 | Corollary 6.17(a) | `cor:hist:H4` | 6.17 |
| app-absorb.tex:31 | Theorem 5.3 | `thm:learn:merging` | 5.3 |
| app-absorb.tex:72 | Theorem 4.4, Proposition 4.7, Remark 4.8 | `thm:versions:chain`, `prop:versions:shared`, `rem:versions:sharedsize` | 4.4, 4.7, 4.8 |
| app-absorb.tex:92 | Theorem 3.8 | `thm:setting:universal` | 3.8 |
| app-limits.tex:96, 107 | Proposition 8.1, 8.1(a) | `prop:ood:hanni` | 8.1 |
| app-limits.tex:108 | Theorem 9.10, Remark G.11 | `thm:comp:ladder`, `rem:comp:uniformties` | 9.10, G.11 |
| app-related.tex:32 | Proposition A.10(c) | `prop:setting:computability` | A.10 |
| app-teacher.tex:42 | Corollary 5.4 | `cor:learn:mistakes` | 5.4 |
| computable.tex:23 | Section 9.1 | `sec:comp:time` | 9.1 |
| computable.tex:30 | Proposition 10.1 | `prop:nn:functionspace` | 10.1 |
| computable.tex:31, discussion.tex:42 | Question 10.9, Remark H.2 | `q:nn:bridges`, `rem:nn:bridge` | 10.9, H.2 |
| recovery.tex:147 | Proposition 4.6(a) | `prop:versions:tape` | 4.6 |
| recovery.tex:161 | Section 7.3 | `sec:ex:eisenstat` | 7.3 |
| setup.tex:29, 35 | Proposition 5.7, 5.7(a) | `prop:learn:perquery` | 5.7 |
| setup.tex:30 | Proposition 5.6 | `prop:learn:freshnoise` | 5.6 |

All 25 match.

**Names.** Paper 2's descriptions match Paper 1's current statements and titles:
* Paper 1's Prop 5.6 is titled "the one-tape version cannot model fresh label noise" and covers $M_F$, $W$, $M_{\rm prod}$ and $M_w$; Paper 2 cites it for the one-tape version.
* Paper 1's Prop 5.7 is titled "Solomonoff's per-query solution"; its (a) gives $M_{\rm pq}=M_{\rm prod}$ on distinct inputs.
* Paper 1's Thm 5.1(a) is $M_F$'s dominance over lsc conditional semimeasures ("which the one-tape version dominates").
* Paper 1's Prop 8.1 is stated for $W$ and $M_F$ ("For $M_F$, …"; "with $M_{\rm prod}$ in place of $W$ and $M_F$").
* Paper 1's Prop 4.7, Remark 4.8 and Question 3.14 match the statements Paper 2 attributes to them.
* "SOI^hist, the history-aware version" matches Paper 1's naming.

Paper 1's `steeper.tex` already describes Paper 2 in the new names: the class of Solomonoff's per-query solution, the one-tape version and the history-aware class.

## Fixes made

1. **`sections/intro.tex`, ¶1** (fairness: what is only a new name).
   * Before: "…; the family of such solutions is \emph{Solomonoff operator induction} (SOI) \citep{claudeSFI2026fundamentals}, the supervised-learning counterpart of Solomonoff induction (SI), and like SI it learns every computable regularity of the labels."
   * After: "…; as in the companion paper \citep{claudeSFI2026fundamentals}, we call the family of such solutions \emph{Solomonoff operator induction} (SOI). It is the supervised-learning counterpart of Solomonoff induction (SI), and like SI it learns every computable regularity of the labels."
   * I also added one `%` comment line to the rename comment block of `intro.tex`, which prints nothing.
2. **`sections/limits.tex`, after `rem:limits:hull`, and `sections/app-limits.tex`, in `app:limits:ood`** (version named explicitly).
   * Before: "with a steeper prior the per-query solution extrapolates more reliably than SOI if these hypotheses extrapolate well".
   * After: "… more reliably than the one-tape version if these hypotheses extrapolate well".
   * The meaning is unchanged: the comparison was with $M_F$, whose bound $2^{-K(Q,b)-O(1)}$ opens the appendix paragraph. Only the ambiguity of a version compared with its own family is removed.

`main.pdf`, `main.aux`, `bib/all.bib` and the build logs were regenerated by the two builds. No other file was changed.

## Decisions on which version a statement is about

1. **limits.tex and app-limits.tex, "than SOI".** The old "SFI" meant $M_F$; the appendix paragraph begins with $M_F$'s bound (P1 Prop 8.1). The comparison is between two versions, so the version is named as RENAME §3 requires: "the one-tape version". The alternative, "the per-query solution at λ=1", would change the referent, although P1 Prop 8.1(a) with $M_{\rm prod}$ shows the same bound. Rejected so as to keep the old meaning.
2. **intro ¶1, "we call the family of such solutions SOI".** Here SOI is the family, as RENAME §3 defines it. The default convention (SOI means $M_F$) is introduced later, in `setup.tex`, and is not needed here.
3. **`def:setup:class`, "data sets for SOI" — left unchanged.** Read as the family, or as $M_F$ by the default convention, it is true either way. Data sets are the observations of every data-set law: $M_F$, $W$, $M_w$, and $M_{\rm prod}$ on DS and FR. The sentence then adds per-query samples for product classes. Naming one version would narrow a statement that holds for all of them.
4. **The abstract — left unchanged.** See Step 5.

## For other groups

* **Paper 1 (front and ood groups), if not already in progress.** Paper 1's printed text still says "SFI" in places:
  * `abstract.tex`, the whole abstract;
  * `intro.tex`, the paragraph after the opening and its footnote "The notion of SFI first appeared in the author's working notes";
  * `ood.tex`, line 26, "So, however large $D$ is, SFI behaves like $b$ …".

  Paper 2 relies on none of these sentences. The credit footnotes of the two papers are consistent:
  * Paper 2: "The one-tape version of SOI first appeared in the author's working notes";
  * Paper 1, `setting.tex`: "The author's working notes call this setting function induction".

  If Paper 1's introduction footnote is reworded, keep it consistent with these two.
* **Paper 1, the statements Paper 2 cites by number with a version name.** Please keep these about the same objects:
  * Prop 5.6, for the one-tape version;
  * Thm 5.1(a), the one-tape version's dominance;
  * Prop 5.7, Solomonoff's per-query solution;
  * Prop 8.1, for $M_F$ and $W$.

  All match today.
