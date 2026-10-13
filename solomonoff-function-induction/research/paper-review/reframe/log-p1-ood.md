# Reframe log, group p1-ood (Paper 1)

Files: `paper/sections/{ood,comp,nn,related,steeper,app-ood,app-comp,app-nn}.tex`.
Binding note: `research/paper-review/REFRAME.md`. Baseline: commit `5acf4db3`; no other group had touched these files since then (`git diff --stat 5acf4db3` was empty before I started).
Originals for comparison: `git diff 5acf4db3 -- solomonoff-function-induction/paper/sections/<file>.tex`.

## Summary

* **Changes:** 30 edits in 8 files (ood 9, app-ood 2, comp 6, app-comp 5, nn 4, app-nn 1, related 2, steeper 1). Title edits are counted separately from text edits in the same environment.
* **Citations of the notes.** Before: 17 visible citations of `hanni2026notes` (ood 4, app-ood 1, comp 3, app-comp 4, nn 3, related 2) and 1 of `hanni2026grokking` (steeper), plus 8 uncited mentions ("as the author's notes suspect / observe / state / expect", "that note", "a sketch in the author's notes"). After: 4 neutral credit footnotes (listed at the end), one per section. ood, comp and nn each have one footnote, and so does steeper. related, app-ood, app-comp and app-nn have no citation of the notes.
* **Footnote budget.** These 4 footnotes and the 3 of p1-front and p1-setting (intro, setting, versions) make 7, before p1-hist-ex. If Paper 1 ends up above 10, drop the steeper footnote first. Paper 2 already carries this credit (its footnote at the proposal and its acknowledgements).
* **Labels, `\status`, `\src`, numbering.** A script compared each file with its baseline copy for the sequence of `\label{…}`, `\status{…}`, `\src{…}`, `\begin{…}`, `\section`/`\subsection` and display-equation openers. All 8 files are identical in each of these. So no environment, section or equation was added or removed, and Paper 1's numbering is unchanged. Labels containing "hanni" or "draftfalse" (`prop:ood:hanni`, `ex:ood:hanniexamples`, `tab:ood:hanni`, `prop:ood:draftfalse`) are kept, since they are invisible.
* **Retitles:** 3 (`prop:ood:draftfalse`, `rem:comp:majority`, `rem:comp:gap`).
* **Inline math.** I compared the multiset of `$…$` tokens per file with the baseline. The only differences are:
  * `$O(C(f))$` → `$O(\ell(f))$` in `rem:comp:majority`, and `$10^6\,C(f)$` → `$10^6\,\ell(f)$` in app-comp. Both are notation only: `C(f)` was the notes' name for the description length, which this paper calls $\ell(f)$. In Paper 1, $C$ otherwise denotes plain complexity (`rem:ood:logterm`).
  * The deleted `$\log\log(1/P_A(f))$`, which belonged to the notes' weaker version of `prop:nn:upper`.
  * One extra `$P$` ("$P$-abiding generalisation") in ood.tex.
* **Length.** Rendered text lines (`pdftotext -layout`, non-empty lines, isolated builds, bibliography and footnotes included):

  | pair | before | after |
  |---|---|---|
  | ood + app-ood | 379 | 380 (body −2, footnote +3) |
  | comp + app-comp | 423 | 420 |
  | nn + app-nn | 219 | 218 |
  | related | 178 | 175 |
  | steeper | 30 | 32 (body equal, footnote +2) |
  | **total** | **1229** | **1225** |

  Page counts are unchanged: 8, 9, 5, 5 and 1.
* **Builds.** `./test-section.sh ood app-ood`, `comp app-comp`, `nn app-nn`, `related` and `steeper` all compile. Each has 0 undefined citations and 0 overfull boxes. Every undefined reference points to another section, as expected in isolation. The new `\cref{q:nn:bridges}` resolves within nn.tex.

## Changes

### ood.tex

1. **l.11, section opening.**
   * Old: "The author's notes observe that if some simple property holds for no training input, SFI keeps a constant probability of a simple behaviour …; they ask whether a logarithmic term is lost, state a two-sided version, ask for a converse and list examples where SFI plausibly generalises as intended \citep{hanni2026notes}. We make these statements precise, with prefix complexity $K$ in place of plain complexity."
   * New: "If some simple property holds for no training input, SFI keeps a constant probability of a simple behaviour, such as outputting $0$, on all inputs with that property, with no logarithmic term in prefix complexity $K$ (\cref{sec:ood:prop}). We give a two-sided version, study converses and work out examples where SFI plausibly generalises as intended.\footnote{An informal version of \cref{prop:ood:hanni} with plain complexity, properties simple given a fitted program, the two-sided statement in the form \eqref{eq:ood:literal}, the question of a converse and the examples of \cref{sec:ood:examples} first appeared in the author's working notes \citep{hanni2026notes}.}"
   * Why: REFRAME §1, §2, §4. The observation is stated as ours, and the merged credit goes to one footnote.
   * The footnote records neutrally that the two-sided statement first appeared "in the form \eqref{eq:ood:literal}". The text right after that equation in app-ood says both bounds fail. So a reader of the notes is not misled (§4), and the footnote does not evaluate the notes.
   * Mathematics: unchanged. "Prefix complexity $K$" and "no logarithmic term" restate `prop:ood:hanni` and `rem:ood:logterm`.

2. **l.29, after `prop:ood:hanni`.**
   * Old: "The author's notes also raise properties that are simple only given a program $p$ … the same bound holds for them with conditional complexity …"
   * New: "A property may also be simple only given a program $p$ that fits the training data, … the same bound holds for such properties with conditional complexity, relative to the posterior weight of $p$ (\cref{prop:ood:relative})."
   * Why: §2 ("the author's notes … raise"). The credit is in the footnote.
   * Mathematics: unchanged.

3. **l.36, proof idea of `prop:ood:machine`.**
   * Old: "So, as the author's notes suspect, for some programming language good behaviour on $Q$ has no better constant than bad behaviour; …"
   * New: "So for some programming language good behaviour on $Q$ has no better constant than bad behaviour; …"
   * Why: §2 ("suspect").
   * Mathematics: unchanged. The caveat that the language is tailored and lies $K(Q,b)+O(1)$ bits from the reference machine is kept verbatim.

4. **l.41, before `thm:ood:twosided`.**
   * Old: "For a property $P\subseteq X\times Y$ … (``$y$ is a correct proof of $x$''), the author's notes state that, whatever the amount of data, good out-of-distribution generalisation has at least a constant probability of happening and of not happening. This holds when no training input lies in a simple property $Q$ of the test inputs:"
   * New: "Often any output with a property $P\subseteq X\times Y$ of input--output pairs will do (``$y$ is a correct proof of $x$''). Whatever the amount of data, $P$-abiding generalisation has at least a constant probability of happening and of not happening when no training input lies in a simple property $Q$ of the test inputs:"
   * Why: §1. The question is motivated on its own merits (generalisation as producing outputs with a property rather than one intended function), and the claim is in our voice.
   * Mathematics: unchanged. It is the same informal claim with the same condition. The quoted phrase is our example of a property, not a quotation from the notes.

5. **l.51, after `thm:ood:twosided`.**
   * Old: "The two bounds that the author's notes give for the statement fail as stated (\cref{prop:ood:draftfalse}); the second, read as a lower bound on the probability of violation, is (c)."
   * New: "Two natural pointwise bounds of this kind fail (\cref{prop:ood:draftfalse}); the second, read as a lower bound on the probability of violation, is (c)."
   * Why: §3 (`prop:ood:draftfalse`: "two natural two-sided bounds fail").
   * Mathematics: unchanged.

6. **l.94, after `prop:ood:converse`.**
   * Old: "So the converse asked for in \citet{hanni2026notes}, that SFI works well if no property simple given a program doing well on the training data separates the test point, fails, …"
   * New: "So the natural converse of \cref{prop:ood:hanni,prop:ood:relative}, that SFI works well if …, fails, …"
   * Why: §2 gives this exact replacement. The added `\cref` shows why the converse is natural: those two results force errors on separated points.
   * Mathematics: unchanged. The rest of the paragraph is verbatim.

7. **l.109, `rem:ood:answer` (iii).**
   * Old: "So ``no simple separating property implies small error'' fails only for bounds independent of $K(f)$, …"
   * New: "So the implication from no simple separating property to small error fails only for bounds independent of $K(f)$, …"
   * Why: §5 and the grep for quotation marks. The quoted slogan paraphrased the notes' question, so I removed the quotation marks.
   * Mathematics: unchanged. It is the same statement, with the same two exceptions.

8. **l.119, opening of `sec:ood:examples`.**
   * Old: "The author's notes list three examples where SFI plausibly generalises as intended \citep{hanni2026notes}: sentences …"
   * New: "Three examples show what these bounds give where SFI plausibly generalises as intended: sentences …"
   * Why: §2 ("list"). The credit is in the footnote of change 1.
   * Mathematics: unchanged; the list of examples is verbatim.

9. **l.135, `ex:ood:hanniexamples`(a), inside the example environment.**
   * Old: "This gives one precise sense to the tentative remark in \citet{hanni2026notes} that for Solomonoff induction easy-to-hard generalisation ``is not'' a thing: no number of easy sentences removes a (small) floor on the wrong-label probability of a hard one."
   * New: "So easy-to-hard generalisation is limited in one precise sense: no number of easy sentences removes a (small) floor on the wrong-label probability of a hard one."
   * Why: §2 and §5. There is no citation and no quotation, and no footnote inside the environment (§4).
   * Mathematics: unchanged. The clause after the colon is verbatim, and the floor $2^{-K(\mathcal T)-2\log\log L-c}$ and the relative floor are untouched.

### app-ood.tex

10. **l.38, before `prop:ood:draftfalse`.**
    * Old: "…, an earlier draft in \citet{hanni2026notes} supports the two-sided statement of \cref{sec:ood:twosided} by two bounds: for an input $x$ and data $D$, [eq] where $z_x$ is … These bounds fail as stated:"
    * New: "…, two natural pointwise forms of the two-sided statement of \cref{sec:ood:twosided} are, for an input $x$ and data $D$, [eq] where $z_x$ is … Both fail:"
    * Why: §2 ("an earlier draft") and §3 (stated as natural candidates).
    * Mathematics: `eq:ood:literal` is unchanged, including $c$, $K(P)$, $K(Q)$ and $K(z_x)$. "Both fail" is accurate: (a) refutes the second bound and (b) the first.

11. **`prop:ood:draftfalse`, title.**
    * Old: "The literal two-sided bounds fail".
    * New: "Two natural two-sided bounds fail".
    * Why: REFRAME §3, which gives this wording. "Literal" presupposed a text being read literally.
    * Mathematics: the statement and its proof are unchanged.

### comp.tex

12. **l.15, section opening.**
    * Old: "The author's notes sketch two computable relatives \citep{hanni2026notes}: a time-bounded Solomonoff predictor … and induction over Boolean circuits, for which regret and circuit complexity should be polynomially related."
    * New: "Two computable relatives are natural: a time-bounded Solomonoff predictor … and induction over Boolean circuits, for which regret and circuit complexity should be polynomially related.\footnote{Both were first sketched in the author's working notes \citep{hanni2026notes}, the first for sequences, with activation, clocking, amortised replay and an extension to all polynomial-time predictors; so were in-distribution bounds for Occam learning and the question whether it makes few online mistakes on every ordering.}"
    * Why: §1, §4. One merged footnote replaces the credits of changes 13–15 and 18–21.
    * Mathematics: unchanged.

13. **l.60, after `cor:comp:poly`.**
    * Old: "This answers a remark in the author's polytime note \citep[note ``polytime solomonoff'']{hanni2026notes}: constant regret against all polynomial-time predictors, in time …"
    * New: "So one learner has constant regret against all polynomial-time predictors, in time …"
    * Why: §2 gives this exact case ("a plain statement of what is proved").
    * Mathematics: unchanged. The clocks, running times and the distinct-inputs variant are verbatim.

14. **l.67, proof idea of `prop:comp:history`.** Deleted: "This is the function-setting form of the amortised warm-up of that note."
    * Why: §2. The credit is in the footnote of change 12.
    * Mathematics: the sentence held no mathematics.

15. **l.89, proof idea of `thm:comp:circuitbayes`.**
    * Old: "Both directions hold on every ordering and formalise a sketch in the author's notes; the step …"
    * New: "Both directions hold on every ordering; the step …"
    * Why: §2.
    * Mathematics: unchanged.

16. **`rem:comp:majority`, title.**
    * Old: "An informal argument that holds for weighted majority".
    * New: "A natural argument, which holds for weighted majority".
    * Why: §3 lists this remark. It now presents a natural proof strategy and where it holds.
    * Mathematics: unchanged.

17. **`rem:comp:majority`, first sentence.**
    * Old: "An informal argument in \citet{hanni2026notes} that Occam makes $O(C(f))$ online mistakes on every ordering assumes …"
    * New: "A natural argument that Occam makes $O(\ell(f))$ online mistakes on every ordering assumes …"
    * Why: §2 and §3. The citation is removed from inside a theorem-like environment.
    * Mathematics: unchanged. $C(f)$ was the notes' symbol for the shortest description length in the circuit language. That is $\ell(f)$ here (comp.tex l.91, `prop:comp:occam`), while in Paper 1 $C$ denotes plain complexity. The remainder of the remark is verbatim.

### app-comp.tex

18. **`rem:comp:constant`.**
    * Old: "The sequence predictor of the polytime note \citep[note ``polytime solomonoff'']{hanni2026notes} starts machine $i$ at the round $r_1$ with $\log\log r_1\ge i$; with $r_2$ the round after which the comparator runs within its clock, its regret is $\max(r_1,r_2)$ bits, doubly exponential in $i$."
    * New: "For sequences, a predictor that starts machine $i$ at the round $r_1$ with $\log\log r_1\ge i$ has regret $\max(r_1,r_2)$ bits, with $r_2$ the round after which the comparator runs within its clock: doubly exponential in $i$."
    * Why: §2 and §4. There is no citation inside the remark, and the credit is in the comp.tex footnote ("the first for sequences").
    * Mathematics: unchanged; it is the same predictor and the same regret.

19. **`rem:comp:apples`.**
    * Old: "In the sequence theorem of the polytime note \citep{hanni2026notes} the learner reuses state across rounds while the comparator recomputes, a caveat raised there. For x-only comparators, …"
    * New: "A time-bounded sequence learner that reuses state across rounds, against comparators that recompute each round, does not compare like with like. For x-only comparators, …"
    * Why: §2. The caveat is now a plain fact, which matches the remark's title.
    * Mathematics: unchanged; the rest is verbatim.

20. **After `prop:comp:occam`.**
    * Old: "…it needs $70\ell(f)+531$ samples, so the sample size $10^6\,C(f)$ of the in-distribution theorem in the author's circuit note \citep{hanni2026notes} suffices when $C(f)$ is the description length."
    * New: "…it needs $70\ell(f)+531$ samples, so $10^6\,\ell(f)$ samples suffice."
    * Why: §2. The credit for the in-distribution bound is in the comp.tex footnote.
    * Mathematics: unchanged. It is the same inequality, with $C(f)$ = description length = $\ell(f)$ as the old sentence stipulated.

21. **`rem:comp:gap`, title.**
    * Old: "Relation to the sketch in the author's notes".
    * New: "Regret and circuit size".
    * Why: §3 ("Section and theorem titles carry no reference to the notes").
    * Mathematics: unchanged.

22. **`rem:comp:gap`, text.**
    * Old: "The author's note on circuit induction \citep[note ``for circuit induction, …'']{hanni2026notes} sketches that expected regret $m$ … implies a circuit of size $O(m\log m\cdot d)$ for $f$. … the additional $O(\log m)$ term flagged there is the $\log(d+s)$ in $\Gamma$. The sketch passes from log loss at most $\mathrm{poly}(m)$ to a circuit of size at most $\mathrm{poly}(m)$; this step is a circuit coding theorem, …"
    * New: "A natural form of the relation is that expected regret $m$ … implies a circuit of size $O(m\log m\cdot d)$ for $f$. … the factor $O(\log m)$ is the $\log(d+s)$ in $\Gamma$. Passing from log loss at most $\mathrm{poly}(m)$ to a circuit of size at most $\mathrm{poly}(m)$ is a circuit coding theorem, …"
    * Why: §2 and §3. The sketch becomes a natural statement, and the text keeps where it holds and what step it needs.
    * Mathematics: unchanged. The identification with `thm:comp:circuitbayes`(b),(a), "every single ordering", "no Markov step", the exponential- versus polynomial-tail caveat, the converse and the $d=3$ computation are all verbatim.

### nn.tex

23. **l.29, after `prop:nn:upper`.**
    * Old: "… The version in \citet{hanni2026notes} has an extra $\log\log(1/P_A(f))$ term; it is not needed. The bound is an exact, uncomputable form of … As the author's notes observe, it owes nothing to the networks: …"
    * New: "… The bound is an exact, uncomputable form of … It owes nothing to the networks: … which can omit most simple functions.\footnote{A version of \cref{prop:nn:upper} with this observation, and the questions of comparing uniform and simplicity priors on circuits, of the Gaussian limits and of whether few mistakes imply a small circuit for NN Bayes, first appeared in the author's working notes \citep{hanni2026notes}.}"
    * Why: §2 ("observe") and §4. The comparison with the notes' weaker version (the extra loglog term) is deleted. That version is weaker but true, so no reader of the notes is misled, and a footnote may not evaluate the notes. One merged footnote also covers changes 24, 25 and 27.
    * Mathematics: `prop:nn:upper` is unchanged. The deleted sentence compared it with another text and asserted nothing new about it.

24. **l.43, proof idea of `prop:nn:uniform`.**
    * Old: "This settles one half of an open problem posed in \citet{hanni2026notes}; the other half, that the uniform prior is not much \emph{larger} than the simplicity prior on functions without small circuits, is open."
    * New: "The other half of the comparison, that the uniform prior is not much \emph{larger} than the simplicity prior on functions without small circuits, is open (\cref{q:nn:bridges}(a))."
    * Why: §2 ("settles one half of an open problem posed in"). The text before the proposition already says "one half of the comparison holds", so "the comparison" has its antecedent. The new `\cref` points to the question that states the other half.
    * Mathematics: unchanged; the open half is stated verbatim.

25. **l.45, paragraph "The Gaussian-process limits".**
    * Old: "The author's notes suggest that in the infinite-width Gaussian limits (NNGP and NTK) a network behaves more like a polynomial fit than like circuit SFI \citep{hanni2026notes}."
    * New: "In the infinite-width Gaussian limits (NNGP and NTK) learning reduces to kernel methods, and one may ask whether a network then behaves like circuit SFI or more like a polynomial fit."
    * Why: §1 and §2. The suggestion becomes a natural question, which `thm:nn:walsh`, `cor:nn:separation` and `rem:nn:oddparity` answer on sparse parities. I did not turn it into an unconditional claim of ours.
    * Mathematics: unchanged; the paragraph contains no statement.

26. **`rem:nn:slides`.**
    * Old: "The slides of \citet{vaintrobhanni2026nnbayes} warn that ``Many of these appendices have largely been generated by Claude'' and ``I haven't meticulously reviewed many appendix slides yet'', and that Bayesian learning and SGD are ``importantly different''. … Of these, this paper proves …"
    * New: "The slides of \citet{vaintrobhanni2026nnbayes} note that Bayesian learning and SGD are ``importantly different''. … The slides give proofs or proof sketches for several of these claims; we use only what is proved here. Of these claims, this paper proves …"
    * Why: REFRAME §6. The two quoted caveats about the slides' own appendices are deleted and replaced by the neutral sentence.
    * Deviation from the REFRAME wording ("The slides give these claims with proof sketches"): I wrote "proofs or proof sketches for several of these claims". Some appendices (for example App. A, E) give full arguments, and for (iv) and (vi) the context track found no proof in the slides (only a heuristic for (vi)). The REFRAME wording would therefore be inaccurate.
    * The slides' other short quotations ("importantly different", "scrambled only polynomially", "does not have a good circuit prior", "is simply false") are kept. They come from a citable joint work (§6), not from the notes, and they record the slides' claims without our paraphrase.
    * Mathematics: unchanged. Items (i)–(vi), their hypotheses and the list of what this paper proves are verbatim.

### app-nn.tex

27. **`rem:nn:bridge`.**
    * Old: "The converse, that few mistakes imply a small circuit, which the author's notes expect to hold for NN Bayes as well, is stated by the slides in their setting and in distribution …"
    * New: "The converse, that few mistakes imply a small circuit, is stated for NN Bayes by the slides in their setting and in distribution …"
    * Why: §2 ("expect"). There is no citation inside the remark, and the credit is in the nn.tex footnote.
    * Mathematics: unchanged; the caveats "in their setting and in distribution" and "holds for circuit Bayes on every ordering" are kept.

### related.tex

28. **Paragraph "Computable versions and networks" (`rem:nn:literature`).**
    * Old: "The objection in the author's notes \citep{hanni2026notes}, that the upper bound holds for every map while the needed lower bound fails, is made precise in \cref{prop:nn:typical,prop:nn:nolower}; the slides … argue the same."
    * New: "The simplicity-bias upper bound holds for every map, while the lower bound needed for a simplicity prior fails (\cref{prop:nn:typical,prop:nn:nolower}); the slides … argue the same."
    * Why: §2 and §4. There is no citation of the notes in running text. "Simplicity-bias upper bound" ties back to \citet{dingle2018input} in the previous sentence.
    * Mathematics: unchanged. It is the same claim with the same `\cref`s.

29. **Paragraph "Novelty" (`rem:related:new`).**
    * Old: "(\cref{sec:comp:time}; the sequence analogues are the polytime note in \citealp{hanni2026notes} and the speed priors)"
    * New: "(\cref{sec:comp:time}; the speed priors are sequence analogues)"
    * Why: §4. The polytime note's credit is in the comp.tex footnote ("the first for sequences").
    * Mathematics: none involved.

### steeper.tex

30. **Opening of `sec:steep`.**
    * Old: "The author's notes propose to penalise program length more steeply than likelihood, … systematic errors \citep{hanni2026grokking}. The companion paper \citep{claudeSFI2026steeper} studies this proposal; we summarise its results. A standard objection …"
    * New: "The companion paper \citep{claudeSFI2026steeper} studies the following proposal: penalise program length more steeply than likelihood, … systematic errors.\footnote{The proposal first appeared in the author's note \citep{hanni2026grokking}.} A standard objection …"
    * Why: §4 (Paper 2: "We study the following proposal", with a single footnote crediting the grokking note).
    * "We summarise its results" is dropped, because the section title already says "summary of the companion paper". This keeps the body the same length despite the footnote.
    * Mathematics: unchanged. The proposal's wording ($\lambda>1$, private randomness) and every later sentence (rate $0.056$, window, linear growth of $\lambda$) are verbatim.

## Remaining visible citations of `hanni2026notes` / `hanni2026grokking` in my files

All four are short neutral credit footnotes in running text. None is inside a theorem-like environment or a float. The acknowledgements (p1-front) carry the general credit.

1. `ood.tex` l.11, footnote to the section's opening paragraph: "An informal version of \cref{prop:ood:hanni} with plain complexity, properties simple given a fitted program, the two-sided statement in the form \eqref{eq:ood:literal}, the question of a converse and the examples of \cref{sec:ood:examples} first appeared in the author's working notes \citep{hanni2026notes}."
2. `comp.tex` l.15, footnote to the section's opening paragraph: "Both were first sketched in the author's working notes \citep{hanni2026notes}, the first for sequences, with activation, clocking, amortised replay and an extension to all polynomial-time predictors; so were in-distribution bounds for Occam learning and the question whether it makes few online mistakes on every ordering."
3. `nn.tex` l.29, footnote to the paragraph after `prop:nn:upper`: "A version of \cref{prop:nn:upper} with this observation, and the questions of comparing uniform and simplicity priors on circuits, of the Gaussian limits and of whether few mistakes imply a small circuit for NN Bayes, first appeared in the author's working notes \citep{hanni2026notes}."
4. `steeper.tex` l.8, footnote to the statement of the proposal: "The proposal first appeared in the author's note \citep{hanni2026grokking}."

Final grep of my files for "author", "notes", "draft", "conjectur", "as proposed", "anticipated", "suspect", "tentative", "that note", "polytime note", "flagged" and "raised there", outside `%` comments: the only hits are the four footnotes above and the invisible label `prop:ood:draftfalse`.

Remaining quotation marks fall into two groups:
* our own names for properties or programs (``$y$ is a correct proof of $x$'', ``size in unary, then the gate list'', ``if $|x|$ even then $0$ else $|x|$'', and so on);
* four short quotations of the Vaintrob–Hänni slides in `rem:nn:slides`, kept under REFRAME §6.

None quotes the notes or the grokking note.
