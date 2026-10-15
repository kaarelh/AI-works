# Paper 1: mathematics-invariance check of the reframing diff

Diff checked: `git diff 5acf4db3 -- paper/sections paper/main.tex` (17 files, 82+/82-; `main.tex` unchanged). Every hunk read and compared old against new. Nothing was edited.

## Verdict

No hunk changes a theorem-like statement, a hypothesis inside a statement, a proof step, or a constant inside a statement. The structure is frozen as REFRAME §8 requires:

* per file, the `\begin{...}` counts and their order are unchanged, as are numbered equations, `\section`/`\subsection` and the sequence of `\label`s;
* the set of labels is unchanged;
* the `\status{}` and `\src{}` calls are unchanged in number and in content.

The only structural change is one unnumbered `\paragraph` deleted in `intro.tex` ("Relation to the author's notes"). It has no label and nothing referred to it. Paper 2's citations of Paper 1 by number therefore still hold.

There are eight new footnotes (intro, setting, versions, hist, ood, comp, nn, steeper), within the 10 that REFRAME allows. None is inside a theorem-like environment or a float. The last full build (`build3.log`, 01:01) is newer than every section file. It has 0 errors, 0 undefined references or citations and no overfull box above 10pt, at 90 pages, the same as the base PDF. The sections changed by the diff shrink by about 300 characters in total.

Three findings need a fix (F1–F3). The rest are optional wording points or notes.

## Findings that need a fix

**F1. `intro.tex` l.32, contributions bullet "History-aware prediction" (category 1: a hypothesis dropped from a newly explicit statement).**
The old text said that "the dominance statement of the author's notes holds … under finiteness hypotheses, in expectation …". The new text quantifies explicitly: "SFI's loss exceeds that of every computable sampler $P$ that sees the history by at most …". That quantifier is correct for the pathwise case, `cor:hist:thm1`(b), where defective samplers are allowed. It is not correct for the expectation case, `cor:hist:thm1`(a), which needs $P$ and $\Delta_f$ to have computable real values (for example, halting with probability 1). Defective samplers are open there (`rem:hist:thm1open`(ii)).
*Fix:* replace "and, under finiteness hypotheses, in expectation with an additional $K(n)+K(A)$ term for randomised reveal laws" with "and, for samplers that halt with probability~$1$ and under finiteness hypotheses, in expectation with an additional $K(n)+K(A)$ term for randomised reveal laws". This matches the paragraph after `cor:hist:thm1` in hist.tex.

**F2. `related.tex` l.24, paragraph "Computable versions and networks" (category 2: a claim now made in the paper's own voice, broader than what is proved).**
Old: "The objection in the author's notes …, that the upper bound holds for every map while the needed lower bound fails, is made precise in (`prop:nn:typical`, `prop:nn:nolower`)". New: "The simplicity-bias upper bound holds for every map, while the lower bound needed for a simplicity prior fails (`prop:nn:typical`, `prop:nn:nolower`)".
The paper proves the upper bound only for priors that are lower-semicomputed by a program (`prop:nn:upper`; the case of Gaussian real weights is only sketched). The proposition that gives the bound, `prop:nn:upper`, is also not cited.
*Fix:* "The simplicity-bias upper bound holds for every lower-semicomputable prior on functions, while the lower bound needed for a simplicity prior fails (\cref{prop:nn:upper,prop:nn:typical,prop:nn:nolower}); …"

**F3. `discussion.tex` l.24, open-problems item on natural machines (category 1: the wording of an open question changed).**
"the intended answers of \cref{ex:ood:hanniexamples}" became "the correct answers". The question being summarised, `conj:ood:natural` in ood.tex l.143, still says "intended answers", and `prop:ood:intended` is "The intended answer". "Intended" was the paper's own term, not a reference to the notes.
*Fix:* restore "intended".

## Optional (wording and clarity; the mathematics is unchanged)

* **O1. `app-comp.tex` l.52.** "so $10^6\,\ell(f)$ samples suffice." This is correct, since $70\ell+531\le10^6\ell$ for $\ell\ge1$. But the constant $10^6$ now has no motivation in the paper; it came from the notes' theorem. Either end the sentence at "it needs $70\ell(f)+531$ samples." or leave it as it is.
* **O2. `examples.tex` l.91.** "the hypotheses must see their \emph{list}; their set is not enough". The antecedent of "their" is ambiguous. Restore "must see the \emph{list} of previous inputs; their set is not enough".
* **O3. `hist.tex` l.59.** "In these examples the reveal order is complex." $C_\Delta$ measures the reveal *sequence*, and in the chain example what is complex is the input strings themselves. "reveal sequence" is more precise.
* **O4. `learn.tex` l.26.** "(for samplers that also see the revealed data see \cref{sec:hist:thm1})". The double "see" reads badly. Suggested wording: "(samplers that also see the history are treated in \cref{sec:hist:thm1})".
* **O5. Credits dropped without a footnote.** This is outside the four categories and is noted only for the credit editor; each could be absorbed into an existing footnote:
  * positive-example induction (`app-learn.tex` l.163; the notes list it among the ideal inductions);
  * the question whether a logarithmic term is lost (ood opening);
  * the suspicion behind `prop:ood:machine`;
  * the easy-to-hard remark of `ex:ood:hanniexamples`(a);
  * the like-for-like caveat of `rem:comp:apples`.
* **O6. `app-verification.tex`.** This appendix is built only with `\ifsfirecord`. Its table `tab:verification:corrections` (l.72) still says "Reading C" and "oracle reading", while the body now says "Formulation". This affects only the record build.

## Hunks checked and found invariant (summary)

* **intro**
  * The SFI footnote is fine.
  * The new explicit dominance bound $K(P)+K(\Delta_f)+c$ matches `cor:hist:thm1`(b) with $\delta_f$ (the caveat is F1).
  * "the stronger oracle form … is false" matches `thm:hist:randchain`.
  * In the deleted paragraph, the Eisenstat credit survives in examples.tex l.8 and in the acknowledgements, and the credit for the ladder and the slides survives in comp.tex l.101–104, nn.tex l.13, the Novelty paragraph and the acknowledgements.
* **setting**
  * The informal definition is fine.
  * "dominance over all such samplers" = `thm:learn:dominance`(a).
  * The new sentence "a computable re-encoding … costs at most $K(\alpha,\beta)+O(1)$ bits" matches `thm:setting:invariance`(b) (injections; the statement says this itself).
  * The caveats "constant not small / only the upper bound / non-computable encodings" are kept.
  * The retitling of `rem:setting:recommend` is allowed.
* **versions**
  * The new motivation matches `def:versions:variants`: $\KF$ is the shortest consistent program, $W$ and $\MF$ are mixtures.
  * "For strings the two agree up to an additive constant" is the discrete coding theorem; it is correct, and it is the same claim the old text made in §3.3.
  * The §3.3 sentence was rephrased with the same content.
* **related**
  * The Novelty paragraph drops "the polytime note" as a sequence analogue. The credit moved to the comp.tex footnote, and the novelty claim (function setting) is unchanged.
* **learn / app-learn**
  * The changes are framing only.
  * The subsection retitle is allowed.
* **hist / app-hist**
  * "Reading" became "Formulation" consistently: in the body, in `q:hist:open`, in `rem:hist:thm1open`, `prop:hist:nopathwise`, `prop:hist:shannon` and `conj:hist:algmi`. Paper 2 never uses the word.
  * The "natural proof" description (alternate simulation of $\Delta$ and $P$, output at the first visit, Jensen) matches the notes' sketch and history Thm 3.2's proof.
  * "Formulation C is the natural one for SFI: a function machine can simulate a reveal law that sees only the history" is supported (history notes §3, the reasons for Reading C).
  * "in Formulation B this also fails" (algorithmic mutual information) = old "in Reading B the answer is negative".
  * The dropped "(We take $\epsilon$ as the chain's first label.)" is harmless, because `thm:hist:chain` fixes $(x_1,\epsilon)$.
  * "In this sense \SFIhist{} is as good as SI" = old "the conjecture holds in this sense".
* **examples**
  * The changes are framing only.
  * "A heuristic argument (from correspondence with S. Eisenstat)" follows REFRAME §7.
* **ood / app-ood**
  * "with no logarithmic term in prefix complexity $K$" = the title of `prop:ood:hanni`.
  * The two-sided paragraph keeps its old content.
  * "Two natural pointwise bounds … fail" with "Both fail": `prop:ood:draftfalse`(a) refutes the second bound and (b) the first.
  * "natural converse of \cref{prop:ood:hanni,prop:ood:relative}" is the correct direction.
  * In `ex:ood:hanniexamples`(a), the floor statement is unchanged.
* **comp / app-comp**
  * $O(C(f))\to O(\ell(f))$ and $10^6C(f)\to10^6\ell(f)$ are the same quantity, since the circuit note defines $C(f)$ as the shortest description length.
  * "the factor $O(\log m)$" is correct for $O(m\log m\cdot d)$.
  * The regret $\max(r_1,r_2)$ for the sequence predictor is unchanged.
  * "So one learner has constant regret against all polynomial-time predictors …" = `cor:comp:poly` for each fixed $g$.
  * The rem:comp:apples generalisation is supported by Remark 3 of the polytime note.
  * The footnote's facts (activation, clocking, amortised replay, the extension to all polynomial-time predictors; the Occam in-distribution bound; the online-mistakes question) were checked against `prior/hanni-polytime-solomonoff.md` and `prior/hanni-circuit-circuit-occam-learning.md`.
* **nn / app-nn**
  * The deleted "extra $\log\log$ term in the notes" was only a comparison: `prop:nn:upper` already has no such term.
  * "The other half of the comparison … is open (\cref{q:nn:bridges}(a))" is correct; it refers back to nn.tex l.36 and matches `q:nn:bridges`(a).
  * The new Gaussian-limit motivation is standard and is answered by `cor:nn:separation`.
  * In `rem:nn:bridge`, the slides' claim is correctly restated.
* **discussion**
  * The new precise form "the loss of \SFIhist{} is at most SI's joint loss plus a constant, not automatically at most SI's conditional label loss plus a constant" matches `thm:hist:si`(a) and `prop:hist:inputloss`.
  * The acknowledgements sentence was added as REFRAME prescribes.
* **steeper**
  * The changes are framing only. The footnote credits `hanni2026grokking`.

## Slides of Vaintrob and Hänni (checked against `prior/vaintrob-hanni-nnbayes-generalization-slides.txt`)

* `rem:nn:slides`:
  * "importantly different" is l.128.
  * (iii) "scrambled only polynomially" is l.789.
  * (v) NNGP "does not have a good circuit prior" is l.781.
  * (vi) "simply false" out of distribution, with a heuristic argument for an online mistake bound listed as open, is l.856–863.
  * The ladder (Appendix K) is l.863 and Appendix K.
  * The quotations of the slides' caveats about their appendices (l.888–889) are removed, as REFRAME §6 requires.
  * The new sentence "The slides give proofs or proof sketches for several of these claims; we use only what is proved here" is accurate: the slides contain a "Proof" (l.185), "Proof of the corollary" (l.422) and "Appendix A: proof" (l.940), and only a heuristic for (vi). It is more accurate than the REFRAME template "these claims with proof sketches", which would misdescribe (vi).
* related.tex:
  * "the slides … argue the same" is accurate: Appendix F, l.1758–1771 says that only one direction can hold, and that the converse is impossible via functions that diagonalise against small circuits.
  * "the slides call this the closest prior work" (Buzaglo et al.) is l.1746.
* `rem:nn:bridge`: the converse (few mistakes imply a small circuit) is stated by the slides in their setting and in distribution. This matches (iv) of `rem:nn:slides`.
* Credit for the ladder construction is kept in the text (`thm:comp:ladder` title and l.101).
