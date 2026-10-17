# Edit log, group logic (logic.tex, app-logic.tex)

Status: **phase 1 done** (2026-10-17). All seven issues of `review/issues-logic.json` fixed as decided (LOG-01..05, LOG-X19, LOG-L1 with list A and both list-B moves). Last isolated build: `./test-section.sh logic app-logic` → OK, 27 pages, 0 undefined citations, 0 overfull boxes > 10pt; the 40 undefined references are all labels of other groups (checked: each exists in `setting.tex`, `basic.tex`, `app-basic.tex`, `soi.tex`, `laws.tex` or `related.tex`). No label lost, none duplicated: the set of labels in `logic.tex` + `app-logic.tex` equals that of commit f4fbab0f (59 labels); theorem-like environments 21 + 23 before, 11 + 33 after (44 = 44).

## Issues

* **LOG-01** done. `logic.tex`, `sec:logic:pi1`, paragraph after `thm:logic:threshold`: first sentence now "every $\Pi_1^*$ sentence $\pi$ with $\Unif(O_\pi)$ above a uniformly random level"; last sentence "… a true r.e.\ theory $T_k$ … that proves every $\Pi_1^*$ sentence $\pi$ with $\Bel_0(\pi)\ge2^{-k}$ (\cref{thm:logic:thresholdtheories})".
* **LOG-02** done. `logic.tex`, sentence after `thm:logic:arith`: the decided text ("the least ticket that $B\cup\re k$ refutes ($0$ if none); the diagonal reports as the loser a different ticket, one that $B\cup\re k$ does not refute whenever $B\cup\re k$ is consistent and proves $\Lot^{\rm ar}_k$, and that report is true").
* **LOG-03** done. The main-text paragraph "Relatives" is cut to the decided novelty sentence (LOG-L1 item 6). The Demski claim remains only in App C, `app:logic:lottery`, paragraph "Relatives of the lottery", now: "The modified Demski prior \citep{…} also draws random axiom systems from a universal machine, and, for the process as described in those works, it too gives the lottery stream positive probability: …" (no `\cref{app:logic:lottery}` there, since the sentence is in that subsection).
* **LOG-04** done. The Pitt/Ambainis sentence is cut from §5 (LOG-L1 item 6); `grep -i 'pitt\|ambainis\|randomi[sz]ed learner'` finds nothing in `logic.tex` or `app-logic.tex`; `related.tex` keeps the version with "below a success-probability threshold".
* **LOG-05** done. `logic.tex`, paragraph after `cor:logic:Q1`: "Since consistent \SOIabbr agrees with \SAIabbr version by version up to constant factors (\cref{thm:soi:coinfree,thm:soi:onetape}), the lottery separates one-tape from coin-free consistent \SOIabbr, while plain coin-free \SOIabbr on sentences has bounded loss on it, through an inconsistent labeller (\cref{cor:logic:versions})." The hedge "We do not claim that these are the only cases." is kept (final-check item 5); the clause "the last holds because truth … is a constraint of arity one" is dropped from §5 (it stays in App C after `prop:logic:true`). 375 bytes (limit 300: the hedge, the decided qualifier and the two `\cref`s were kept).
* **LOG-X19** done (§U7). `logic.tex`: the only mention is now "Proposition B.10 of our earlier report \citep{claude2026axiominduction}" (first mention in §5); the second mention moved with `rem:logic:closures`. `app-logic.tex`: first mention "a derivation-charged axiom inducer, as in Section 6 of our earlier report \citep{claude2026axiominduction}, is another" (`app:logic:goedel`); later "by Theorem 3.9(c1) of the earlier report" (`rem:logic:closures`) and "Theorem 3.9 of the earlier report concerns …" (paragraph "The closures of …"), without citation commands. Neither file cites `claudeSFI2026fundamentals` or `claudeSFI2026steeper`. Item numbers unchanged.
* **LOG-L1** done. List A items 1–7 and list B items 1–2 applied (details below). §5 main text: 6.62 pp. before, **4.86 pp.** after (target 4.75, limit 5.00).

## Moved labels (all from `logic.tex` to `app-logic.tex`, each statement with its `\status` and `\src` unchanged, placed immediately before its proof, "Proof of \cref{…}" turned into a plain proof)

| label | to (App C subsection) | main-text replacement |
|---|---|---|
| `prop:logic:arity` (list B 1) | `app:logic:lottery`, after "Relatives of the lottery" | "Where it cannot happen": one sentence with the hypotheses (bounded loss, decidable class, inconsistent sets reducible to $\le r$ elements), threshold $1-1/(r+1)$ "exact for the argument" (the decided text's "exact threshold" would have dropped "for the argument"), `\cref{prop:logic:arity}(a)`, de Leeuw et al. cited; part (b) stays cited in the opening paragraph of §5.1. The proof-idea sentence is dropped (the proof and the "threshold is exact" paragraph are in App C). |
| `cor:logic:chaitin` (A5) | `app:logic:pi1` | decided paragraph after the definition of $\Kgt_m(x)$ (merged with the definition into one paragraph). The moved paragraph after it: "The lower bound combines … Chaitin's bound" dropped as a duplicate of App C's "The deterministic step is Chaitin's bound …"; the rest ("One $m$-bit $\Pi_1$ law …; … the $m$ bits disappear:") appended to that App C paragraph. |
| `prop:logic:normalised` (A5) | `app:logic:pi1` | as above ("for every $j\ge0$" added to the decided sentence, since $j$ is otherwise free); the sentence after it opens the App C paragraph "So for $d\ge\dots$". |
| `thm:logic:soundnessPi1` (A4) | `app:logic:goedel`, after `prop:logic:unsound` | decided sentence, worded "over a decidable true background containing $\PA$ … at most $1-2^{-c}$, with $c$ independent of the data (…, given (G2)); whether this holds for all data is open (for partial answers see \cref{app:logic:goedel}):" followed by `q:logic:soundness` (stays). The paragraph after the theorem (proof idea; "yes on $\Pi_1$ data, with a bounded coding gap, and on the Win-lottery stream") is dropped as a duplicate of the proof and of App C's paragraph "What is known about \cref{q:logic:soundness}". |
| `prop:logic:oldevidence` (list B 2) | `app:logic:goedel`, before its proof | one sentence after the footnote F5 sentence (data entailed by $B$ leave the posterior equal to the prior for $\MA$, $\WA$, $\KA$; the $\Delta_0$ instance case), then the old-evidence/logical-omniscience citations and the fresh-predicate and costly-reasoner sentence, shortened. **Footnote F5 stays in the main text**, on "Checking instances of a decidable property, the classic case of induction in mathematics,". |
| `thm:logic:goedelomega` (A3) | `app:logic:omega` | decided sentence. The sentence after the theorem ("$\forall x\,\zeta_k$ is the consistency statement of $B\cup T_k$ …") is dropped: the App C proof says the same. |
| `rem:logic:closures` (A2) | `app:logic:omega`, before the paragraph "The closures of \cref{rem:logic:closures}." | "In arithmetic the gap closes under the $\omega$-rule (with $B\supseteq\Q$) and under full second-order consequence, and in the generative variant only with the universal sentence among the data (\cref{rem:logic:closures})." ("In arithmetic" and "with $B\supseteq\Q$" added: the remark's (a) and (b) are about $\Lar$ and $\Th(\mathbb N)$.) |
| `thm:logic:thn`, `cor:logic:undecided`, `q:logic:thn` (A1) | `app:logic:thn`: setup paragraph and theorem before its proof; "The digit sentences … so:" and the corollary before its proof; "Conversely …" lead-in before `prop:logic:generic`; the question after the proof of `prop:logic:generic`, before the paragraph that discusses it | `\paragraph{True arithmetic.}\label{sec:logic:thn}` at the end of §5.5 with the decided sentence ("for an exponent $\xi>0$ of the syntax" and "for a constant $C'$" added so that both symbols are introduced). The sentence "For a stated Polish-notation syntax, $\xi\ge0.0823$: a computation … (\cref{app:logic:thn})" is dropped as a duplicate of App C's paragraph "The exponent for a stated syntax". |

Labelled paragraph: `sec:logic:thn` was a subsection label and is now the label of `\paragraph{True arithmetic.}` (same label; it resolves to §5.5). No label renamed or removed.

Other-group citations of the moved labels (grep of `sections/`): `setting.tex` and `phil.tex` (`prop:logic:normalised`), `phil.tex`, `limits.tex`, `discussion.tex` (`prop:logic:oldevidence`), `discussion.tex` (`q:logic:thn`), `app-notation.tex` (`thm:logic:thn`, `app:logic:thn`). All are parenthetical `\cref`s whose wording stays true; no request needed.

## Prose cuts (LOG-L1 list A item 7 and §L2)

| paragraph | before → after (bytes) | what went |
|---|---|---|
| Conventions | 1036 → 803 | the list of standard facts and the textbook citations (both in `app:logic:conv`); "(likewise for $\PA$ and $B\cup T$)" (also in `app:logic:conv`); (G2) kept, defined in one clause, since §5 still invokes it |
| after `cor:logic:Q1` (LOG-05) | 519 → 375 | see LOG-05 |
| "Relatives" (A6) | 840 → 367 | decided text; pointer `\cref{sec:related,app:logic:lottery}` |
| after `cor:logic:false` | 740 → 466 | the explanation of (ii) (in the App C proof); the realism clause (the introduction says "We say nothing realist about the theories an inducer favours", citing `cor:logic:false`) |
| §5.3 opening | 500 → 421 | the clause "and the mixture collapses … to one random true theory" (repeated after `thm:logic:threshold`) |
| after `cor:logic:coding` | 808 → 399 (+ the $\Kgt_m$ definition, now opening the Chaitin paragraph) | wording only; every statement and pointer kept |
| boundary | 1035 → 645 (of which the kept novelty sentence ~190) | the literature sentence on de Leeuw et al., Bienvenu et al. and Shen (in §12 `related.tex`; `shen2011random` is now cited nowhere, which is harmless for natbib); the double hedge "we have not found them stated, but cannot exclude that they are known" reduced to "To our knowledge" (same hedge) |
| $\Con$ paragraph | 771 → ~470 + footnote F5 (the paragraph now continues with the one-sentence summary of `prop:logic:oldevidence`, list B 2) | "its belief and independent shares certify its truth" (= `prop:logic:con`(b), from `prop:logic:shape`(b)); truth hypothesis and the counterexample $B=\PA+\neg\Con(\PA)$ kept; F5 kept |
| after `prop:logic:omega` | 1020 → ~600 (+ the three decided summary sentences, merged into the same paragraph) | the explicit formula of the gap (replaced by "misses it by at least $2^{-K(I)-c}$") and the description of the structures in the earlier report's Proposition B.10 |

## Page counts (isolated build, measured as in §L1)

Measured with a script in the editor's scratchpad (`logic-edit/measure.py`): word positions from `pdftotext -bbox`, fractions of the text block; "content" ignores the white space left at the bottom of a page by a page break.

| | before (commit f4fbab0f) | after |
|---|---|---|
| §5 main text (heading of §5 to the heading of App C) | 6.62 (6.67 in the full build of 15:17) | **4.86** (content); 5.00 by heading position, because the App C heading moves to the top of the next page |
| App C (heading to References) | 18.25 | 19.68 |

Target 4.75, limit 5.00: within the limit, 0.11 above target after all list-A and list-B moves. Expected full-build value about 4.9 (the isolated build ran 0.05 short of the full build before the edits).

## Rule 0.8 greps

On both files, outside comments and `\status`/`\src`: the process-vocabulary pattern of rule 0.8 has no hit; no model names. Hänni's notes appear only in footnote F5 (`hanni2026notes`).

## Requests to other groups

None.
