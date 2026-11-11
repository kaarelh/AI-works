# Check of the revision of `depth-two.md` after the second re-refereeing round

*Published record of the independent check of the depth-two note's last revision, made during finalization. Paths under `stage/` refer to the lead's unpublished working copies. The check's scripts and outputs are in [`../checks/revision-check-depth-two/`](../checks/revision-check-depth-two/); re-runs of the note's own scripts are not published.*

**Inputs.**
- Revised note: `research-notes/depth-two.md`.
- Reports answered: `verification/depth-two-referee-scope-2.md` (S) and `verification/depth-two-referee-logic-computation-2.md` (LC).
- Pre-revision text: `stage/depth-two.r2-final-candidate.md` (the text the second re-refereeing round read; unpublished).

The word diff has 40 hunks (`../checks/revision-check-depth-two/diff.txt`, `../checks/revision-check-depth-two/wdiff.txt`). My recomputations are in `../checks/revision-check-depth-two/fixed_d_recheck.py`, with output in `../checks/revision-check-depth-two/fixed_d_recheck.out`.

## Verdict: minor fixes

- **No mathematical error found in any changed passage.**
- **All 21 points of the two reports are resolved as the last §9 table says.** Every fix is correct. The one partial rebuttal, in the row for LC nit 2, is valid.
- **No proved theorem was strengthened.**
- **What remains is small problems of labelling and record.** One concerns criterion (c): new claims that are not refereed but are not marked as such where they appear (issue 2 below).

## (a) Each point against the table

| Point | Status |
|---|---|
| S1 | Resolved. Row 4 now says "when $c=o(n)$". The $c\ge C_1n$ statement is checked against A, the paragraph after Prop. 8.3: $C_t=2(1+\sqrt{t/2})^2/t$, so $C_1=5.8284$. The $c\ge n/k$ observation is attributed to the referee. The $1/\delta$ remark is added. Two-point failure is given for $c\ge n^{1-o(1)}$. §0 and "Input dimension" are updated. |
| S2 | Resolved. §1.4 names $\phi=\log_2n+C_0$ and adds the case $\phi\ge n/b$, which matches Remark 5.3a. |
| S3, LC12 | Resolved. The row lists what (5.7a) gives and what is not classified; the gap for the unclipped readings is stated correctly. Remark 5.2b is new and marked "not refereed". |
| S4 | Resolved. The lead editor's sentence is in the erratum for RT §7 item 3, and §0 adds a sentence on B §7.5 item 3. |
| S5 | Resolved. |
| S6, LC2 | Resolved by the lead editor. The rebuttal of LC's zero-padding argument is correct: $\kappa_N=\frac dN\lVert W^1\rVert^2+N\lVert v\rVert^2$ changes under zero padding, and clones preserve it only at integer multiples of the width. |
| S7, LC3 | Resolved, in both places. |
| S8 | Resolved. It is checked: $K\le k+1$, $\delta_0=1/(k+1)$, $\eta_0\le1/2$, and $\omega^2=k+1\ge2$ if and only if $k\ge1$. It is marked "not refereed". |
| S9, LC11 | Resolved. |
| LC1 | Resolved. The new wording matches B Thm 6.3 (statements 1, 3 and 4 of Prop. 6.1) and the passage paragraph: $\ln(4/\delta)$, and $+4\eta$ under (R1′) and (R2). |
| LC4 | Resolved. `opt_hadamard.out` has $N=8$ and $M=d\in\{64,256\}$; the ball rows give 0.003, 0.000, 0.001 and 0.000. |
| LC5 | Resolved. The range is right: for $c\ge n^{-O(1)}$, $\ln K'=O(\log n)$. |
| LC6 | Resolved. |
| LC7 | Resolved. |
| LC8 | Resolved. |
| LC9 | Resolved. |
| LC10 | Resolved. The row matches what `prop91_l2.py` asserts and prints. The actual largest weight is $v=1/\tanh\sqrt{\delta_0}\approx\sqrt K$, from B Prop. 9.1(b) at $L=2$. |

## (b) Re-derivations

- **Remark 5.2b.**
  - Only two steps of Cor. 5.2(i)(a) use $c\le d^k$. The first is $c(18dc+1)(dF_d+1)/M\to0$, which holds uniformly for $c\le2^{o(d)}$. The second is $1/\varepsilon_d=2^{o(d)}$, which gives $\mathsf p(\dots)=2^{o(d)}<n$. The proof is complete.
  - The numbers recompute: ratios 0.987679 and 0.999228, and $\log_2(1/\varepsilon_d)/d$ equal to 0.0403 and 0.0578.
- **"General $c$, the polynomial-sample property."**
  - For $n^a\le c\le n^{1-a}$ the three terms are bounded as stated.
  - The sample-size entries of B's Theorem 6.3, with $\gamma=a/2$, are polynomial.
  - The unclipped variant has terms of order $D_nn^{-a}$ and a $\delta$-term $\lesssim n^{-a}\sqrt{\ln(2/\delta)}$. Both are correct.
- **"Input dimension", bullet 3.**
  - Excess $\le\sup|z_w|^2\le\kappa_N\le G/c+\zeta$ on $\mathcal N_\zeta$, using $F(0)=(G+W)/c=n/c$. This is checked.
  - $\mathbb E\,G=\mathbb E\,s\le2^d$, and Lemma 1.1(ii)(iii) handles (R1), (R1′) and (R2). This is correct.
- **Referee numbers quoted** (part (1): at least 0.050 and 0.085; part (5)). They match `fixed_d_and_other_c.out`.
  - My independent run, with another seed, gives minima 0.0492 to 0.0512 at $c=n/10$ and 0.0860 to 0.0873 at $c=n/4$.
  - The note quotes the referee's samples, so it is accurate.
- **The "Not classified" list of §0.2 row 1.** The trichotomy ($c\le n^{o(1)}$; $n^a\le c\le n^{1-a}$; $c\ge n^{1-o(1)}$) leaves only sequences that oscillate. The list is exact.

## (c) Strengthening and marking

- Corollary 5.2 is unchanged. The extension is in Remark 5.2b, marked. The $n/k$ fixed law is marked.
- See issue 2 for the new claims that are not marked in place.

## (d) Records

- §0.6 is accurate: 21 points, and the item lists match the diff. The lead-editor paragraph matches the three §6 edits.
- §0.5 is accurate after the renames.
- The §9 tables are complete: 21 rows, with correct "Where" entries.
- No script changed after the second re-refereeing round. The published `prop91_l2.*` and `rt54_record.*` are byte-identical to the referee's re-run copies.

## (e) Links

Every link and code-span path in the note resolves from `research-notes/`.

## Issues

1. **(minor; record) The §6 intro is no longer accurate.** It says "where they cite `B-tempered-likelihood.md`, they do so through Remark 5.7a". The lead editor's new sentence in the erratum for RT §7 item 3 cites "(`B-tempered-likelihood.md` Theorem 6.3)" directly. The same text is in `red-team.md` line 519.
   - *Fix:* write "(`depth-two.md` Remark 5.7a, from `B-tempered-likelihood.md` Theorem 6.3)", or relax the intro.
2. **(minor; criterion c) Some new material that is not refereed is not marked in place.** Two items are affected:
   - the new paragraph "General $c$, the polynomial-sample property" of Remark 5.7a, and the §0.2 row-1 status it creates ("holds" for $n^a\le c\le n^{1-a}$, replacing "not settled");
   - the author's new argument in "Input dimension", bullet 3.

   The header's general sentence covers them. But §0.6 item 4 ("Additions that are not refereed") and the §9 intro ("Two observations … extend refereed statements … marked as not refereed") list only Remark 5.2b and the $n/k$ law. The first item is correct; both referees derived it in their reports.
   - *Fix:* mark it "(not refereed; pointed out by both referees of the second re-refereeing round)", and list it in §0.6 item 4 and the §9 intro, or say there that the list is not exhaustive.
3. **(nit) Row LC3 of the first re-refereeing table** says the preamble names "the four bullets (L2, L3, C2, C3)". It now names five, with L5. Add "(five since the second re-refereeing round)".
4. **(nit) The header's "re-refereed twice in its final form"** is loose: the two rounds read two different intermediate texts. "Re-refereed twice during finalization" would be exact; the later sentences already say this.
5. **(optional)** Remark 5.8 ("what is open") does not list the (P$_2$) ranges that §0.2 row 1 now names as not classified. Those are, for the unclipped readings, $n^a\le c\le n^{1/2+o(1)}$, and, if Remark 5.2b is set aside, polylog $<c\le n^{o(1)}$.
6. **(optional) The Remark 5.2b ratio does not single out $c\le n^{o(1)}$.** The ratio 0.988/0.999 is identical for the referee's contrast $c=n^{1/3}$, because it is dominated by $a=1/d$. Only $\log_2(1/\varepsilon_d)/d$ distinguishes $c\le n^{o(1)}$; one clause would say so.
7. **(optional) Two short additions.**
   - In Remark 5.7a, the $n/k$ extension could add the one-line check ($K\le k+1$ gives $\eta_0\le1/2$; and $\delta_0\le1/2$ holds if and only if $k\ge1$).
   - §0.2 row 1's "By (5.7a)" covers the unclipped clause only through the unclipped variant; it could say "(5.7a) and its unclipped variant".
