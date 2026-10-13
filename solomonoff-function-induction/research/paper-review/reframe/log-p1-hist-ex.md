# Reframe log, group p1-hist-ex (Paper 1)

Files: `paper/sections/{hist,examples,app-hist,app-examples}.tex`.
Binding note: `research/paper-review/REFRAME.md` (2026-10-13), applied to these files. Baseline: commit `5acf4db3`. No other group had touched these files since then (`git diff --stat 5acf4db3` was empty before this pass).

## Summary

* **Changes:** 24 edits in 3 files: 14 in `hist.tex` (one of them a `%` comment), 5 in `app-hist.tex`, 5 in `examples.tex` (one of them a `%` comment). `app-examples.tex` had no visible reference to the notes or to the author and no implicit framing, so it is unchanged.
* **Citations of the notes, before:** 6 visible citations of `hanni2026notes` in `hist.tex` (4 `\citep`, 2 `\citet`). There were also 9 further mentions: "The author's notes intend", "the proof sketch in the notes" (twice), "the example of failure in the author's notes, made precise", "The notes ask", "read as intended", "the mutual-information question of the notes", "The author conjectured" and "the conjecture holds". The text also had one quotation of the notes ("simple to sample from conditional on any particular choice of function f"). In `examples.tex`: 2 × "of the author", "the conjecture that …", "as intended".
* **Citations of the notes, after:** 1 neutral credit footnote, in the opening paragraph of §hist. There is none in §ex or in the two appendices. No `hanni2026grokking` citation occurred in these files.
* **Readings A/B/C:** these are now **Formulations A/B/C**. Definition `def:hist:readings` is retitled "Three formulations"; B is "the oracle form", matching the introduction's wording. Formulation C is motivated on its own merits: a function machine can simulate a reveal law that sees only the history. The paper never says which formulation the notes intended. The letters and their order in the definition are unchanged.
* **Results that existed to correct the notes:**
  * `prop:hist:sketchfails` becomes "A direct simulation fails". The simulation is introduced in the text as a natural proof strategy.
  * `thm:hist:randchain` becomes "The randomised chain; the oracle form fails".
  * The summary after `cor:hist:thm1` states what holds in Formulation C, with every caveat kept.
* **Eisenstat:** "due to Sam Eisenstat (personal communication)" stays in the opening of §ex. The heuristic argument now reads "A heuristic argument (from correspondence with S.~Eisenstat)", the first option of REFRAME §7. It needs no footnote.
* **Labels, `\status`, `\src`, environments, sections, equations:** checked by script against the baseline copies. The sequences of `\label{…}`, `\status{…}`, `\src{…}`, `\begin{…}`, `\(sub)section`, `\begin{equation}` and `\[` are identical in all four files, so Paper 1's numbering is unchanged. Three `\status`/`\src` calls still contain "Reading B" or "H\"anni's request". They print nothing and stay, per REFRAME §8.
* **Inline math:** a multiset diff of all `$…$` segments against the baseline shows four changes, all in framing sentences.
  * Removed: `$(x_1,0),(x_2,x_1),\dots$` and `$\epsilon$`, from the sentence that described the notes' version of the chain with first label 0 and the parenthesis "(We take $\epsilon$ as the chain's first label.)". The theorem defines the chain with $\epsilon$, so nothing is lost.
  * Removed: one `$f$`. The old opening of §hist:thm1 had two ("if $f$ is drawn", "choice of function $f$"), and the new one has one ("given $f$"). "which cannot see $f$" became "not one that sees $f$", with no change in count.
  * Added: `$C_\Delta$`, in "How $C_\Delta$ is measured matters".
  * No math segment in any theorem-like statement changed.
* **Length** (isolated builds, `pdftotext -layout`, non-empty lines and words, footnote and bibliography included):

  | pair | lines before | lines after | words before | words after | pages |
  |---|---|---|---|---|---|
  | hist + app-hist | 755 | 755 | 11199 | 11197 | 16 → 16 |
  | examples + app-examples | 553 | 553 | 7762 | 7748 | 12 → 12 |

* **Builds:** `./test-section.sh hist app-hist` and `./test-section.sh examples app-examples` both print OK, with 0 undefined citations and 0 overfull boxes. The undefined references (25 and 39) are cross-section references, as expected, and their counts are the same as at baseline.

## Remaining visible citations of `hanni2026notes` / `hanni2026grokking` in these files

Exactly one, the footnote at the end of the clause "We give two examples in which seeing the history helps without bound," in the opening paragraph of §hist (`hist.tex` l.16, running text, not inside an environment or float):

> The examples of \cref{sec:hist:counter} and \cref{thm:hist:randchain}, an informal dominance statement for simple reveal laws with a proof sketch by simulation, and the question behind \cref{conj:hist:algmi} first appeared in the author's working notes \citep{hanni2026notes}; \cref{def:hist:readings} gives three precise formulations of that statement.

Rendered: "The examples of Section 6.2 and Theorem 6.11, … first appeared in the author's working notes (Hänni, 2026); Definition 6.6 gives three precise formulations of that statement."

* Every item credited there is in `research/prior/hanni-sfi-notes.md`:
  * the chain: l.24;
  * the skipped strings: l.70;
  * the randomised chain: l.26, "putting the randomization inside the reveal sequence distribution";
  * Thm 1 and its simulation proof sketch: l.27–29;
  * the algorithmic-mutual-information question: l.35.
* The footnote does not evaluate the notes.
* It does not say which formulation the notes meant. Its last clause tells a reader of the notes that the informal statement is made precise in three ways (REFRAME §4: "only where a reader of the notes would otherwise be misled").
* Not credited in a footnote: the conjecture that \SFIhist{} is as good as SI and the cyclic permutation. They came from the author's request (the brief), not from the notes. The acknowledgements cover them ("under the author's direction").
* `examples.tex`, `app-hist.tex`, `app-examples.tex`: no citation of either note.
* Grep of the rendered isolated PDFs for `author|notes|H.nni|draft|conjectur|reading|intend|request` finds only:
  * this footnote;
  * the bibliography entry;
  * "Conjecture A.10" as a cross-reference;
  * "reading fresh consecutive bits" in a proof.

## Changes

### hist.tex

1. **l.2–4, header comment (prints nothing).**
   * Old: "The author's notes (…) are cited and paraphrased (one short verbatim phrase in sec:hist:thm1)."
   * New: "Credit to the author's notes (…) is in one footnote in the opening paragraph (REFRAME.md; log in …); no quotation of the notes."
   * Why: the comment now describes the source accurately. It is a comment, so the mathematics is untouched.

2. **l.16, section opening.**
   * Old: "The author's notes \citep{hanni2026notes} give two examples in which seeing the history helps without bound, and a dominance statement for reveal laws that are simple to sample from. We prove the examples, determine in which readings the dominance statement holds (some cases remain open), and show …"
   * New: "We give two examples in which seeing the history helps without bound,\footnote{…credit, quoted above…} determine in which formulations a dominance statement for simple reveal laws holds (some cases remain open), and show …"
   * Why: REFRAME §1, §2 and §4. The section states its programme in our voice. The credit for the examples, the randomised chain, the informal dominance statement with its proof sketch, and the algorithmic-mutual-information question is merged into one footnote, the only one in these four files.
   * Mathematics: unchanged. "Some cases remain open" is kept, and so is the remark on the convention and on $c_\omega$.

3. **l.24, after `def:hist:predictor`.**
   * Old: "The dominance statement of \citet{hanni2026notes} concerns computable samplers; one that halts with probability 1 has computable probabilities (…)."
   * New: "The dominance statements of \cref{sec:hist:thm1} concern computable samplers; …"
   * Why: §4, no citation in running text.
   * Mathematics: the computability remark is verbatim.

4. **l.32, opening of `sec:hist:counter`.**
   * Old: "The author's notes \citep{hanni2026notes} reveal a deterministic sequence of increasingly long random strings as $(x_1,0),(x_2,x_1),\dots$ and expect, without proof, that SFI has unbounded loss on it; for a second construction, …, they sketch a proof. Both claims hold. (We take $\epsilon$ as the chain's first label.)"
   * New: "In two examples a simple predictor that sees the history beats SFI without bound. In the first, a deterministic sequence of increasingly long random strings is revealed as a chain, each label being the previous input; in the second, every string of a given length but one is labelled $0$, and the remaining one, revealed last, is labelled $1$."
   * Why: §2 ("expect without proof", "Both claims hold" is replying to the notes). The examples are motivated by what they show.
   * Mathematics: unchanged.
     * The new first sentence restates the content of `thm:hist:chain` and `thm:hist:skipped`: an O(1) set-based predictor with loss 0 against SFI's unbounded loss for Martin-Löf random strings. "Both claims hold" said the same.
     * The parenthesis about $\epsilon$ only reconciled the notes' first label 0 with the theorem, which defines the chain with $\epsilon$. It is no longer needed.

5. **l.59, opening of `sec:hist:thm1`.**
   * Old: "The author's notes \citep{hanni2026notes} state that if $f$ is drawn and the inputs are drawn from a reveal law $\Delta$ that is ``simple to sample from conditional on any particular choice of function $f$'', then every computable sampler $P$ … beats SFI … by at most the complexity $C_\Delta$ … plus a constant depending on $P$; a preceding remark says that this fails if the randomness of the chain example is moved into the reveal law."
   * New: "In these examples the reveal order is complex. If instead the inputs are drawn from a reveal law $\Delta$ that is simple to sample from given $f$, one may hope that every computable sampler $P$ that sees the history beats SFI in expected log loss by at most the complexity $C_\Delta$ of sampling from $\Delta$ plus a constant depending on $P$. How $C_\Delta$ is measured matters, since the randomness of the chain example can be moved into the reveal law (\cref{thm:hist:randchain})."
   * Why: §2, §3 and §5. The dominance statement is now our question, motivated by the examples. The quotation from the notes is removed.
   * Mathematics: the hoped-for statement is the same, with the same quantities. That the chain's reveal order is complex is what `cor:hist:thm1`(b) forces, given loss 0 for $P$ against SFI's quadratic loss. The pointer to the randomised chain is kept.

6. **l.61–63, `def:hist:readings`.**
   * Old: title "Three readings"; "\emph{Reading A}", "\emph{Reading C}", "\emph{Reading B} (the oracle reading)".
   * New: title "Three formulations"; "\emph{Formulation A}", "\emph{Formulation C}", "\emph{Formulation B} (the oracle form)".
   * Why: §3 ("The readings become different natural formulations"). "Reading" presupposes a text being read. "Oracle form" matches the introduction's contributions list ("the stronger oracle form … is false").
   * Mathematics: each formulation's content, the definition of $C_\Delta$ and "A is the case $\Delta_f=\Delta$" are verbatim. The label is unchanged.

7. **l.65, after the definition.**
   * Old: "The author's notes intend Reading C: their example of failure has $C_\Delta=O(1)$ in Reading B but is excluded in Reading C (\cref{thm:hist:randchain}), and the proof sketch in the notes simulates $\Delta$ in a function machine, which cannot see $f$."
   * New: "Formulation C is the natural one for SFI: a function machine can simulate a reveal law that sees only the history, not one that sees $f$. The randomised chain has $C_\Delta=O(1)$ in Formulation B but is excluded in Formulation C (\cref{thm:hist:randchain})."
   * Why: §3 ("The paper never says which reading the notes intended"). The preference for C is now justified by a property of SFI. That property is the one the old sentence gave as evidence of the notes' intent.
   * Mathematics: the $C_\Delta=O(1)$ versus excluded statement is verbatim. The definitions of directed information and of the reveal-sequence law that follow are untouched.

8. **l.65 (end of the paragraph) and l.67–69, `prop:hist:sketchfails` and its lead-in.**
   * Old:
     * title "The proof sketch fails";
     * statement: "…; the simulator of the proof sketch, run with separate randomness for each input, has loss $2$ bits.";
     * after it: "The sketch simulates $\Delta$ and $P$ inside a function machine and then applies Jensen's inequality \citep{hanni2026notes}. A simulator with private randomness per input …"
   * New:
     * lead-in before the proposition: "A natural proof simulates $\Delta$ and $P$ alternately inside a function machine until the query appears, outputs its label, and applies Jensen's inequality. With separate randomness per input, this direct simulation fails:";
     * title "A direct simulation fails";
     * statement: "…; the direct simulator, run with separate randomness for each input, has loss $2$ bits.";
     * after it: "A simulator with private randomness per input …" (rest verbatim).
   * Why: §3 (`prop:hist:sketchfails`: "a natural proof strategy … fails"). The description of the simulator moves from the sentence after the proposition to the sentence before it, so "the direct simulator" is defined before the statement uses it. The citation is removed.
   * Mathematics: unchanged.
     * The example ($X=\{a,b\}$, $f(a)=f(b)=\beta$, 1 bit against 2 bits) is verbatim.
     * The simulator is the same: it alternates $\Delta$ and $P$ until the query appears, with separate randomness for each input.
     * The explanation of the two failures and "(SFI itself pays at most $1+c$ bits here.)" are verbatim.
     * The appendix proof ("The simulator at $a$ …") needs no change.

9. **l.85, `thm:hist:randchain`.**
   * Old: title "The randomised chain; the oracle reading fails".
   * New: title "The randomised chain; the oracle form fails".
   * Why: §3; the terminology of change 6.
   * Mathematics: the statement is untouched. `\status{proved; refutes Reading B}` stays (it prints nothing).

10. **l.89, after `thm:hist:randchain`.**
    * Old: "This is the example of failure in the author's notes, made precise. It refutes only Reading B: in Reading C, $K(\Delta^{(n)}_f)\ge n(n+1)/2-j-c$ for all but a $2^{-j}$ fraction of chains, …. The notes ask whether the dominance statement can be improved to one in terms of the algorithmic mutual information of $\Delta$ and $f$; in Reading B the answer is negative."
    * New: "This refutes only Formulation B: in Formulation C, $K(\Delta^{(n)}_f)\ge n(n+1)/2-j-c$ for all but a $2^{-j}$ fraction of chains, …. One may ask for the statement with the algorithmic mutual information of $\Delta$ and $f$ in place of the complexity of $\Delta$; in Formulation B this also fails."
    * Why: §2 ("made precise", "The notes ask"). The mutual-information question is now posed in our voice. Its credit is in the footnote.
    * Mathematics: the bound on $K(\Delta^{(n)}_f)$ with its exceptional fraction is verbatim. "In Reading B the answer is negative" (to whether the improvement holds) is restated as "in Formulation B this also fails". The claim is the same: the version with mutual information is stronger and fails in Formulation B. The later sentence "The Shannon form of the mutual-information question holds" still has its antecedent.

11. **l.110, after `cor:hist:thm1`.**
    * Old: "So the dominance statement of \citet{hanni2026notes}, read as intended (Reading C), holds pathwise …; … are open (\cref{rem:hist:thm1open}); the proof sketch in the notes fails (\cref{prop:hist:sketchfails}). … The Shannon form of the mutual-information question of the notes holds: …"
    * New: "So in Formulation C the dominance statement holds pathwise …; … are open (\cref{rem:hist:thm1open}); a direct simulation fails (\cref{prop:hist:sketchfails}). … The Shannon form of the mutual-information question holds: …"
    * Why: §2 ("read as intended"; REFRAME's example "The dominance statement holds only under (A1)–(A2), and the f-seeing case is open").
    * Mathematics: unchanged. These are kept verbatim:
      * the pathwise case (b), the expectation case (a) with $K(n)+K(A)$, the entropy case (c);
      * the open cases;
      * "No pathwise version with $K(\Delta)$ alone holds";
      * the Shannon statement with equality in the randomised chain;
      * the open algorithmic form.

12. **l.114, opening of `sec:hist:sfihist`.**
    * Old: "The author conjectured that SFI whose hypotheses see the list of previous inputs, but not the previous labels, is as good as SI; we make this precise."
    * New: "Between SFI and SI lies a natural intermediate: the hypotheses see the list of previous inputs but not the previous labels, which they can recompute. We show in what sense it is as good as SI."
    * Why: §2 ("The author conjectured") and §7 ("the author" in the body). The motivation is the structure of the problem: hypotheses with shared randomness recompute their own earlier labels, as `def:hist:sfihist` says.
    * Mathematics: unchanged. It is the same object, and the "as good as SI" sense is made precise by the results that follow.
    * Credit: this conjecture came from the author's request, not from the notes. The acknowledgements cover it ("under the author's direction"), so there is no footnote.

13. **l.132, after `cor:hist:H4`.**
    * Old: "So the conjecture holds in this sense."
    * New: "In this sense \SFIhist{} is as good as SI."
    * Why: there is no longer a "conjecture" to refer to.
    * Mathematics: the same claim, in the same sense (universality, `cor:hist:H4`). The rest of the paragraph is verbatim.

14. **l.175, `q:hist:open`(i).**
    * Old: "In Reading C (\cref{rem:hist:thm1open}): …"
    * New: "In Formulation C (\cref{rem:hist:thm1open}): …"
    * Why: the terminology of change 6.
    * Mathematics: the question is verbatim.

15. **Not changed in hist.tex** (checked):
    * `rem:hist:minimaxsketch`: "proof sketch" is our own sketch.
    * `rem:hist:H4verdict`: title and text make no reference to the notes.
    * The section title "As good as Solomonoff induction?" stands on its own.
    * The quotation marks at l.38, l.46 and l.150 enclose our own predictor descriptions and a formula, not text from the notes.

### app-hist.tex

16. **l.122, `rem:hist:thm1open`.** Title "Open cases in Reading C" → "Open cases in Formulation C". Terminology only; the remark's content, numbers ($0.026$, $0.005$, horizon $6$) and open items are verbatim.
17. **l.126, `prop:hist:nopathwise`.** Title "No pathwise version of Reading A" → "No pathwise version of Formulation A". The statement and proof are verbatim.
18. **l.135, `prop:hist:shannon`(c).** "In Reading C, $\Theta:=\Delta^{(n)}_f$ …" → "In Formulation C, …". Terminology only; formulas unchanged.
19. **l.142, `conj:hist:algmi`.** Title "Algorithmic form in Reading C" → "Algorithmic form in Formulation C". The conjectured inequality is verbatim.
20. **l.292, after `thm:hist:expected`.** "a second process on which the oracle reading fails" → "… the oracle form fails". Terminology only; the GF example and its numbers are verbatim.

There is no citation of the notes in app-hist.tex, before or after. The `%` comment at l.139 ("the notes write H(Delta_f)") refers to the track notes, prints nothing and stays.

### examples.tex

21. **l.91, before `prop:ex:cycset`.**
    * Old: "For the conjecture that seeing the previous inputs makes SFI as good as SI (\cref{sec:hist:sfihist}), the hypotheses must see the \emph{list} of previous inputs; their set is not enough:"
    * New: "For seeing the previous inputs to make SFI as good as SI (\cref{sec:hist:sfihist}), the hypotheses must see their \emph{list}; their set is not enough:"
    * Why: no "conjecture" framing (see change 12).
    * Mathematics: the same claim, that the list is needed and the set is not. It leads into the unchanged `prop:ex:cycset`.

22. **l.103, after `prop:ex:cycsi`.**
    * Old: "So the example separates SFI from SI as intended: SFI pays …"
    * New: "So the example separates SFI from SI: SFI pays …"
    * Why: "as intended" refers to the author's purpose for the example (implicit framing, §2).
    * Mathematics: all numbers and conventions are verbatim.

23. **l.115, before `lem:ex:shape`.**
    * Old: "A heuristic argument of the author (\cref{rem:ex:email}) suggests …"
    * New: "A heuristic argument (\cref{rem:ex:email}) suggests …"
    * Why: §7 ("the author" in the body).
    * Mathematics: the rest is verbatim.

24. **l.166, `rem:ex:email`.**
    * Old: "A heuristic argument of the author (from correspondence with S.~Eisenstat) bounds …"
    * New: "A heuristic argument (from correspondence with S.~Eisenstat) bounds …"
    * Why: REFRAME §7, first option, verbatim. The correspondence is named in the text, so no footnote is needed, and a footnote inside a remark is not allowed in any case.
    * Mathematics: the remark is otherwise verbatim. That includes the two changes the converse needs, $K(g_n)=O(\log n)$, and $UB_n$ versus $\tau_nH(1/3)$ differing by $\Theta(\sqrt n)$.

25. **l.5, header comment (prints nothing).** Added: "Framing per REFRAME.md (reframe/log-p1-hist-ex.md): no citation of the notes here."

Not changed in examples.tex (checked):
* l.8: "a coin example due to Sam Eisenstat (personal communication)" is kept, per §7.
* The title "Eisenstat's example" and the cyclic-permutation material have no framing against the notes.
* `\src{… H\"anni's request}` at l.32 and l.111 prints nothing and stays (§8).

### app-examples.tex

No change. Read in full. It has no reference to the notes or to the author. Its quotation marks enclose our own text ("Gibbs", "copy the previous input", a product law).

## Footnote count

This group adds 1 credit footnote (Paper 1 target: at most 10 in total). The other groups' logs report: intro 1, setting 1, versions 1, learn 0.
