# Paper 1, fixer round 2 (2026-10-13)

## Scope

* **Input.** `reader-p1-r2.md` (F1 to F8, plus "Optional").
* **Method.** I checked each finding against the current `.tex`, the base `5acf4db3`, REFRAME.md and the sources (`research/tracks/context/notes-final.md` Rem 3.1a, Rem 3.2; `research/prior/`).
* **Files edited.** All are in `paper/sections/`: `ood.tex`, `app-ood.tex`, `nn.tex`, `comp.tex`, `app-comp.tex`, `hist.tex`, `app-hist.tex`.
* **What did not change.**
  * No statement, hypothesis, number, proof step, label, `\status` or `\src` was changed.
  * No numbered environment was added or removed.
  * Only titles, motivation sentences and footnote wording changed.
* **Mathematics-invariance findings.** The report has none. I rejected one part of a proposed replacement because it was mathematically wrong (F1).

## Findings

| id | verdict | what was done / reason |
|---|---|---|
| F1 | fixed, modified | **The finding is valid.** "read as a lower bound on the probability of violation" is a leftover of the "read as intended" framing.<br>**`ood.tex:51`.** It now reads "Two natural pointwise bounds of this kind fail (\cref{prop:ood:draftfalse}); in place of the second, an upper bound on the probability of abiding, (c) bounds that of violation from below." The content is unchanged: (c) is the statement that holds in place of the second bound.<br>**`app-ood.tex:38`.** It now reads "two natural pointwise forms of the two-sided statement of \cref{sec:ood:twosided}, a lower and an upper bound on the probability of an abiding output, are, …". The display (7) and "Both fail" are unchanged.<br>**Rejected part of the reader's text: "an upper bound on it that is small when $Q$ and the simplest violating output are simple".** This is false. $c\,2^{-K(Q)-K(z_x)}$ is small when $Q$ and $z_x$ are *complex*.<br>The title "Two natural two-sided bounds fail" is kept, as REFRAME §3 prescribes. |
| F2 | fixed | The `ood.tex` footnote is now a plain list: "An informal version of \cref{prop:ood:hanni}, the question whether it loses a logarithmic term, the observation behind \cref{prop:ood:machine}, properties simple given a fitted program (\cref{prop:ood:relative}), a two-sided statement, the question of a converse and the examples of \cref{sec:ood:examples} first appeared in …".<br>As the reader proposed, I dropped the parenthesis "(for the form proved here see \cref{thm:ood:twosided})". §8.2 and Prop. F.3 already show the reader which forms hold, so a reader of the notes is not misled. The credits are unchanged. |
| F3 | fixed, modified | **The finding is valid.** The text named no comparison and gave no reason to look at the uniform circuit prior.<br>**`nn.tex:36`.** It now reads "The circuit analogue of a fixed architecture with random parameters is the uniform prior over circuits of one size; one half of its comparison with the circuit simplicity prior holds (\cref{def:comp:circuits} for $N_s$ and $\csize$):".<br>**Rejected part of the reader's text: "whether it agrees with … $\Wcirc$ … up to polynomial factors".** That misstates the comparison. The open half, `q:nn:bridges`(a), is $P_{{\rm unif},S}(f)\le\mathrm{poly}(d,S)\,2^{\csize(f)}\Wcirc(f)$, which has a factor $2^{\csize(f)}$. The follow-up "The other half of the comparison, …" now has its antecedent. |
| F4 | fixed, modified | **`comp.tex:60`.** It now reads "For x-only comparators, which have nothing to reuse, these results compare like with like; …".<br>**`rem:comp:apples`.** The first sentence is now "A time-bounded learner that reuses computations from earlier rounds, against comparators that recompute each round, does not compare like with like." This drops the undefined "sequence learner". The remark keeps its old structure, and the rest is unchanged. It matches context notes-final Rem 3.2.<br>I used shorter wording than the reader to keep the length down. |
| F5 | fixed, modified | **`rem:comp:constant`.** It now reads "For comparison, the sequence analogue of \cref{prop:comp:round}, which starts machine $i$ at the round $r_1$ with $\log\log r_1\ge i$, has regret $\max(r_1,r_2)$ bits, …". The claim is unchanged.<br>The pointer matches the remark's own later sentence and context notes-final Rem 3.1a: the round-activated Prop 3.2a "returns to Hänni's doubly exponential form". |
| F6 | fixed, modified | **Title.** It is now "Shannon form of the mutual-information bound" (`prop:hist:shannon`).<br>**`hist.tex:110`.** It now reads "The Shannon form of the mutual-information variant holds: …". This refers back to the variant posed after Theorem 6.11 ("One may ask for the statement with the algorithmic mutual information …").<br>I first tried a longer sentence. It added one line on p. 24, which cascaded into a 91-page PDF, so I chose this wording because it has the original length. |
| F7 | fixed | The title of `prop:ood:converse` is now "The natural converse fails for complex targets". Paper 2 does not cite the title. |
| F8 (optional) | fixed, modified | **`comp.tex:15`.** It now reads "… induction over Boolean circuits, for which, by analogy with \cref{thm:setting:coding}, regret and circuit complexity should be polynomially related." The footnote placement is unchanged. |
| Optional: footnote 4 | done | **`hist.tex:16`.** The footnote now reads "The examples of \cref{sec:hist:counter} and of \cref{thm:hist:randchain}", and it ends at "\citep{hanni2026notes}." The pointer "; the forms in which the statement holds are in \cref{cor:hist:thm1}" was dropped. The section opening says that it determines in which formulations the statement holds, and Corollary 6.14 follows two pages later, so the footnote is now pure credit. |
| Optional: footnote 6 | no change | It is long, but every item is a credit. I agree with the reader. |
| Optional: "the author's working notes" | no change | This is REFRAME §4's model wording. |

## Build and checks

* **Full build.** `cd paper && flock /tmp/claude-0/paper-build-sfi.lock ./build.sh` gave:
  * 0 LaTeX errors;
  * 0 undefined references and 0 undefined citations;
  * 0 multiply defined labels;
  * 0 overfull hboxes above 10pt (the 2 below 1.9pt are the same as before);
  * 90 pages, the same as the base and the previous round.
* **Numbering.**
  * The last line of `python3 -I research/paper-review/scratch/editor/check_companion_numbers.py` is **ALL OK**. The known extra line `used not in intended: {'Theorem~5.1'}` also appears; it is Paper 2 citing `thm:learn:dominance`, which is still 5.1.
  * I also rebuilt the base `5acf4db3` in a scratch copy outside the repository and compared every `\newlabel` number of the two `main.aux` files. There are 628 entries (314 labels plus their `@cref` twins), with **0 differences**.
* **Invariance counts.** For the seven edited files, the counts of `\status`, `\src`, `\label` and `\begin` equal those of the base.
* **Footnotes citing the notes: 8**, unchanged.
  * Seven cite `hanni2026notes`: intro, setting, versions, hist, ood, comp, nn.
  * One cites `hanni2026grokking`: steeper.
  * None is inside a theorem-like environment or a float.
  * Outside footnotes, the notes are cited only in the acknowledgements (`discussion.tex`), plus `app-verification.tex`, which is not built.
* **Length.**
  * The section text without comment lines and without `app-verification.tex` is 372,429 characters. The base has 372,348, so it is 81 characters (0.02%) longer.
  * Before this round it was 113 characters shorter than the base.
  * The page count is unchanged at 90.
  * I shortened the reader's proposed sentences (F1, F3, F4, F5, F8) and dropped two footnote pointers to keep the growth this small.
