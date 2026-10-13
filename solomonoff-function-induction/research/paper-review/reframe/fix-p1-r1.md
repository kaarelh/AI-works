# Paper 1, fixer round 1 (2026-10-13)

## Scope

* **Inputs.** `reader-p1-r1.md` (ids R-F1 to R-F14, R-O1 to R-O4) and `diffcheck-p1.md` (ids D-F1 to D-F3, D-O1 to D-O6).
* **Method.** I checked each finding against the current `.tex`, the base `5acf4db3`, REFRAME.md and the notes in `research/prior/`.
* **Files edited.** All in `paper/sections/`:
  * `hist.tex`, `ood.tex`, `setting.tex`, `learn.tex`;
  * `intro.tex`, `related.tex`, `discussion.tex`, `examples.tex`;
  * `comp.tex`, `app-comp.tex`.
* **What did not change.** No statement, hypothesis, proof step, label, `\status` or `\src` was changed. No numbered environment was added or removed. Against HEAD, the counts of `\status`, `\src`, `\label`, `\begin` and `\footnote` are identical.

## Mathematics-invariance findings (diffcheck)

| id | verdict | what was done |
|---|---|---|
| D-F1 | fixed | `intro.tex`, contributions bullet: inserted "for samplers that halt with probability~1 and" before "under finiteness hypotheses, in expectation …". `cor:hist:thm1`(a) needs P and Δ_f to have computable real values; only the pathwise case (b) allows defective samplers. |
| D-F2 | fixed | `related.tex`: "holds for every map" became "holds for every lower-semicomputable prior on functions", and `prop:nn:upper` was added to the citation. This matches the hypothesis of `prop:nn:upper`. |
| D-F3 | fixed | `discussion.tex`: "correct answers" was restored to "intended answers", as in `conj:ood:natural`. |

## Reader findings

| id | verdict | what was done / reason |
|---|---|---|
| R-F1 | fixed | `hist.tex` footnote. "with a proof sketch by simulation" and "Definition 6.6 gives three precise formulations of that statement" were removed. The footnote now credits "the idea of proving it by simulating the reveal law inside a function machine (\cref{thm:hist:shared})", the theorem where the simulation works. It ends with a neutral pointer, "the forms in which the statement holds are in \cref{cor:hist:thm1}", which REFRAME §4 allows. |
| R-F2 | fixed | `ood.tex` footnote. The pointer to the failing form `eq:ood:literal` and "with plain complexity" were removed. The footnote now says "a two-sided statement (for the form proved here see \cref{thm:ood:twosided})". Two credits that diffcheck D-O5 found dropped were also absorbed into it: the question whether a logarithmic term is lost, and the observation behind `prop:ood:machine` (`prior/hanni-solomonoff-function-induction-gives-at-least-some-const-probability-to-bad-behavior-on-ood-inputs.md`). |
| R-F3 | fixed | The `ood.tex` opening now reads "with no logarithmic term in prefix complexity $K$, of the kind a bound in plain complexity would carry". `prop:ood:hanni` was retitled "Unseen simple properties"; retitling is allowed. |
| R-F4 | fixed | `ood.tex` §8.4. One motivating sentence now precedes `prop:ood:converse`: "Propositions 8.1 and F.2 suggest a natural converse: that SFI works well if …. For complex targets it fails:". The sentence after the proposition was shortened to "So this converse fails, …", and the wording of the converse is unchanged. |
| R-F5 | fixed | `setting.tex`, after `thm:setting:invariance`. The comment now opens with "So the encoding of inputs and labels matters little as long as it is simple: a computable re-encoding costs at most $K(\alpha,\beta)+O(1)$ bits." The three caveats are kept verbatim. |
| R-F6 | fixed | `def:hist:readings` lists its items in the order A, B, C. Every sentence is verbatim; only the order changed. Paper 2 never mentions the formulations. "Formulation C is the natural one …" now follows directly after item C. |
| R-F7 | fixed, modified | `learn.tex`, proof idea of `prop:learn:typical`. It now reads "the natural condition for generalisation that no simple property separates the test input from the training inputs (\cref{sec:ood:converse})". I dropped the reader's word "sufficient", because §8.4 shows that the condition is not sufficient for complex targets. |
| R-F8 = D-O1 | fixed | `app-comp.tex`: the sentence now ends at "it needs $70\ell(f)+531$ samples." The constant $10^6$ served only the comparison with the notes. The exact count, which implies it, is unchanged, and diffcheck judged the removal invariant. |
| R-F9 | fixed, modified | `rem:comp:gap`: "Passing from …" became "Here the step from … is a circuit coding theorem". This ties the step to the route the remark has just described, `thm:comp:circuitbayes`(b) with (a). I did not take the reader's "Any argument … needs", which is a broader meta-claim. |
| R-F10 | fixed, modified | `rem:comp:constant`: "For comparison, a time-bounded predictor for sequences that starts machine $i$ at the round $r_1$ …". I did not take the reader's "first round", which would change the wording of the definition. |
| R-F11 | rejected | Remark 7.18 discusses a heuristic argument that the paper itself states, credited "from correspondence with S. Eisenstat" as REFRAME §7 prescribes. It is not about the notes. Saying what holds and what a rigorous proof changes is ordinary exposition. The proposed rewrite would reword two mathematical caveats ("must be measured" became "is measured") with no gain in framing. |
| R-F12 | fixed | `setting.tex`. "This informal definition," was dropped from the footnote, because FN 1 already credits the notion of SFI. The footnote mark moved to the end of the next sentence, about private and shared randomness. The new text is the reader's. |
| R-F13 | rejected | "\cref{prop:ood:hanni} (in this form)" was already in the base. It is a standard hedge in a novelty paragraph and needs no knowledge of the notes. The proposed "(as a prefix-complexity bound with no logarithmic term)" would change the scope of the novelty claim, which is a substantive matter and not framing. |
| R-F14 | rejected | "So easy-to-hard generalisation is limited in one precise sense: …" states the result and gives the precise sense in the same sentence. The reader also says that it "reads acceptably on its own". The proposed "never certain" is a different, looser claim. |
| R-O1 | no action | Outside the brief. The slides are joint, citable work, and REFRAME §6 allows reporting their claims. |
| R-O2 | no action | Outside the brief. REFRAME §6 forbids quoting only the slides' caveats about their own appendices, which are already removed. Short quotations of the slides' claims are allowed. |
| R-O3 | no action | A natbib suffix artefact; no text change is needed. |
| R-O4 | no action | Outside the brief. The redundancy is pre-existing and not related to the reframing. |

## Optional diffcheck items

| id | verdict | what was done / reason |
|---|---|---|
| D-O2 | fixed | `examples.tex`: "must see the \emph{list} of previous inputs; their set is not enough" was restored. |
| D-O3 | fixed | `hist.tex`: "the reveal order is complex" became "the reveal sequence is complex". |
| D-O4 | fixed | `learn.tex`: "(samplers that also see the history are treated in \cref{sec:hist:thm1})". |
| D-O5 | partly fixed | **Absorbed into existing footnotes**, so the count stays at 8:<br>• the logarithmic-term question and the `prop:ood:machine` observation went into the ood footnote (see R-F2);<br>• the like-for-like caveat went into the comp footnote, as "a like-for-like caveat (\cref{rem:comp:apples})" (polytime note, Remark 3).<br>**Not absorbed:**<br>• positive-example induction (`rem:learn:positive`). The notes only list it, and the notion is known; the remark cites Chater and Vitányi;<br>• the easy-to-hard remark, which is covered by the credit for "the examples of \cref{sec:ood:examples}". |
| D-O6 | rejected | `app-verification.tex` is built only with `\ifsfirecord`, so it is not in the arXiv version. It records the verification against the notes, where "Reading C, the one Hänni's text supports" describes the notes' readings accurately. |

## Build and checks

* **Full build.** `cd paper && flock /tmp/claude-0/paper-build-sfi.lock ./build.sh` gave:
  * 0 LaTeX errors;
  * 0 undefined references and 0 undefined citations;
  * 0 multiply defined labels;
  * 0 overfull hboxes above 10pt; there are 2 below 1.9pt, and the base has 2 as well;
  * 90 pages, the same as the base.
* **Numbering.**
  * The last line of `python3 -I research/paper-review/scratch/editor/check_companion_numbers.py` is **ALL OK**.
  * The script also prints `used not in intended: {'Theorem~5.1'}`. That is Paper 2's `absorb.tex` citing `Theorem~5.1(a)`, which is `thm:learn:dominance`, still 5.1. The script's map simply lacks this entry.
  * I also built the base `5acf4db3` in a scratch copy, outside the repository, and compared every `\newlabel` of the two `main.aux` files. All 314 labels have identical numbers.
* **Footnotes citing the notes: 8.** Seven cite `hanni2026notes` (intro, setting, versions, hist, ood, comp, nn) and one cites `hanni2026grokking` (steeper).
  * None is inside a theorem-like environment or a float.
  * Outside footnotes, the notes are cited only in the acknowledgements, plus `app-verification.tex`, which is not built.
* **Length.** The section text without comment lines is 372,243 characters. The base has 372,356, so the paper is still shorter than the base. After this round's motivating sentences it is 512 characters longer than the previous reframing pass.
