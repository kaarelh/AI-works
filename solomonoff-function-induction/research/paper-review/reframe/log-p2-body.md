# Reframe log, group p2-body (Paper 2)

Files: `paper-steeper/sections/{setup,absorb,teacher,limits,split,algstat,computable,related}.tex` and every `app-*.tex` except `app-verification.tex`.
Binding note: `research/paper-review/REFRAME.md`. Baseline: commit `5acf4db3`. No other group had touched these files since then.

## Summary

* **Changes:** 21 changes in 7 files.
  * `computable.tex` and all seven appendices (`app-setup`, `app-absorb`, `app-teacher`, `app-limits`, `app-split`, `app-algstat`, `app-related`) are unchanged.
  * I read them in full. They contain no citation of the notes and no implicit framing. Their references to "the three-hypothesis calculation", "Version 1" and "the earlier report" (`claude2026whatfollows`) point to our own remark or to the earlier report, not to the notes.
* **Citations of the notes, before:**
  * 12 visible citations of `hanni2026grokking` and 2 of `hanni2026notes`.
  * 4 further mentions of "the note" or "the author's notes" with no citation: teacher l.17 (twice), teacher l.121 and split l.6.
  * 4 quotations from the grokking note: setup l.63, absorb l.90, teacher l.17 and algstat l.6.
  * 1 LessWrong footnote.
* **Citations of the notes, after:** 3 short neutral credit footnotes, all citing `hanni2026grokking`:
  * one in the opening paragraph of §absorb;
  * one in the opening paragraph of §teacher;
  * one in the opening paragraph of §algstat.

  None is inside a theorem-like environment or a float. No `hanni2026notes` citation remains in these files, and no quotation from the notes remains.
* **Footnote budget:** the front group's intro has one footnote (SFI notion + proposal + LessWrong). With my three, Paper 2 has 4 credit footnotes, within REFRAME's limit of 5. I checked this on the full build.
* **LessWrong footnote:** I removed it from `absorb.tex`, as REFRAME §4 (Paper 2) prescribes. The intro footnote now says "…and in an online discussion (on LessWrong), where the absorption point below was also raised"; I checked that it is in the current `intro.tex`.
* **Related work:** the intro paragraph "Relation to the author's notes and to other work" is being deleted by the front group. I checked its "other work" content against my files:
  * The λ-weighted MDL comparison and the earlier report are already in `related.tex`.
  * Eisenstat's coin example is already in `split.tex`.
  * The one missing item, "the basic theory of SFI is in the companion paper", is now in the first sentence of `related.tex` (change 21).
* **Credits deleted rather than moved.** The acknowledgements cover each of these: "Working from the author's notes … Several of the questions and examples studied here first appeared in those notes; the proposal first appeared in … \citep{hanni2026grokking}".
  * The computably samplable predictors of the SFI note (setup table, closing of `rem:absorb:wyeth`).
  * The absolute bound on model complexity as an alternative (§setup).
  * The remark that the length coefficient must grow with n (`rem:setup:persample`, `rem:limits:schedule`).
  * The sampler-versus-fill-in question (§split). It came from the author's request, which is not citable (DECISIONS §A7).
* **Labels, `\status`, `\src`, environments, sections, display equations:** checked by script (`p2-body-check.py` in the session scratchpad, which compares the regex extractions of each item) against the baseline copies from `git show 5acf4db3:…`. They are identical, in the same order, in all 15 files. Paper 2 numbering is therefore unchanged. One title is changed: `rem:algstat:reading`.
* **DECISIONS items superseded here:** §F38 and §F41(ii) asked for the note's sentence in §absorb, "paraphrased with at most one short quotation", and for the quotation in `rem:absorb:wyeth`(ii). REFRAME §2, §4 and §5 override both: the sentence is now in our voice, and the quotation is deleted. §F41(i) and (iii) are untouched.
* **Length:** rendered text lines (`pdftotext -layout`, non-empty lines, isolated builds via `./test-section.sh`, footnotes and bibliography included):

  | pair | before | after | pages before → after |
  |---|---|---|---|
  | setup + app-setup | 237 | 230 | 6 → 6 |
  | absorb + app-absorb | 374 | 366 | 8 → 8 |
  | teacher + app-teacher | 577 | 579 | 13 → 13 |
  | limits + app-limits | 407 | 403 | 9 → 9 |
  | split + app-split | 361 | 361 | 7 → 7 |
  | algstat + app-algstat | 255 | 254 | 6 → 6 |
  | computable + app-related | 116 | 116 | 3 → 3 |
  | related | 92 | 95 | 3 → 3 |
  | **total** | **2419** | **2404** | |

  `related` gains 3 lines from the companion-paper sentence moved out of the intro, which the intro loses. `teacher` gains 2 lines, net, for its credit footnote.
* **Builds:**
  * All eight isolated builds compile. Each has 0 undefined citations and 0 overfull boxes; the undefined references are cross-section references, as expected.
  * One full build ran under the lock (`flock /tmp/claude-0/paper-build-sfi.lock ./build.sh`), with the front group's in-progress intro and discussion. It had 0 LaTeX errors, 0 undefined references, 0 undefined citations, 0 multiply defined labels and 0 overfull boxes above 10pt, at 57 pages.

## Remaining visible citations of the notes (final grep of my files)

`grep -n "hanni2026notes\|hanni2026grokking"` over the 15 files gives exactly three hits, all footnotes:

1. **`absorb.tex:5`**, §absorb opening paragraph, running text, after "…and the pathology may be absent.". The footnote reads: "The sequence-case pathology, and the suggestion that private randomness at each input avoids it, first appeared in the author's note \citep{hanni2026grokking}."
2. **`teacher.tex:7`**, §teacher opening paragraph, running text, after "This section makes this rigorous for the example of \cref{rem:teacher:hanni}.". The footnote reads: "The example (both versions), the three-hypothesis calculation and the convex-hull view of selection first appeared in the author's note \citep{hanni2026grokking}."
3. **`algstat.tex:6`**, §algstat opening paragraph, running text, after "…one bit of data (\cref{rem:algstat:reading}).". The footnote reads: "This way of locating the split, and this reason why the sequence case shows no change of slope, first appeared in the author's note \citep{hanni2026grokking}."

In the full PDF, the only other mentions of the notes are the intro footnote and the acknowledgements, both in front-group files. `vaintrobhanni2026nnbayes` stays a normal reference in `computable.tex` (`rem:related:nn`), as REFRAME §6 allows. Eisenstat stays "Sam Eisenstat's coin example (personal communication; …)" in `split.tex`, as REFRAME §7 allows.

## Changes

### setup.tex

1. **l.14, table "Objects from the companion paper", row $\Mprod$.**
   * Old: "…product laws are machine laws, and they include the computably samplable predictors of \citet[note on Solomonoff function induction]{hanni2026notes}"
   * New: "…product laws are machine laws, and they include the computably samplable predictors that use fresh random bits at each input"
   * Why: the citation was in running text (a non-float table). The class is now described by its defining property; the acknowledgements give the credit.
   * Mathematics: unchanged. The new phrase is the definition of the class the citation referred to, and the inclusion claim is the same.
2. **l.63, after `def:setup:objectives`.**
   * Old: "The two-part objective is the proposal of \citet{hanni2026grokking}, which puts ``a higher coefficient on the length of the program than on the likelihood terms''; the power-prior posterior is its Bayesian form."
   * New: "The two-part objective puts a higher coefficient on the length of the program than on the likelihood term; the power-prior posterior is its Bayesian form."
   * Why: REFRAME §4 (the proposal is the paper's subject, credited once in the intro footnote) and §5 (no quotations).
   * Mathematics: unchanged. It is a verbal description of $J_\lambda$ with $\lambda>1$, and the rest of the paragraph is verbatim.
3. **l.76, `rem:setup:persample`.**
   * Old: "As noted in \citet{hanni2026grokking}, the coefficient of the length term must grow with the size of the data set; $\lambda=cn$ with $c$ fixed is this choice."
   * New: "The coefficient of the length term must grow with the size of the data set (\cref{rem:limits:schedule}); $\lambda=cn$ with $c$ fixed is this choice."
   * Why: §2. The claim is now supported by our own result instead of the note.
   * Mathematics: unchanged. `rem:limits:schedule` (with `prop:limits:plain`(b)) proves that $\lambda=\Theta(n)$ is needed. The batch caveat that follows is verbatim.
4. **l.79, paragraph before `lem:setup:coding` (hull geometry).**
   * Old: "Selection by $c\,\ell+R$ has a simple geometry, which underlies the observation of \citet{hanni2026grokking} that the good model of the example of \cref{sec:teacher} could be a vertex of the convex hull of the attainable pairs (complexity, expected log loss), and the alternative proposed there, an absolute bound on model complexity. The minimisers lie on the lower-left boundary of the convex hull of the pairs $(\ell(\pi),R(\pi))$, and exactly its vertices are unique minimisers on an open interval of $c$; … an absolute length bound selects …"
   * New: "Selection by $c\,\ell+R$ has a simple geometry. The minimisers lie on the lower-left boundary of the convex hull of the attainable pairs $(\ell(\pi),R(\pi))$ of complexity and expected log loss, and exactly its vertices are unique minimisers on an open interval of $c$, so for the example of \cref{sec:teacher} the question is whether the good model is a vertex; … an absolute bound on model complexity, a natural alternative to the penalty, selects …"
   * Why: §2 ("the observation of", "the alternative proposed there"). The vertex question and the absolute bound are now motivated on their own merits. The convex-hull credit is in the §teacher footnote; the absolute-bound credit is left to the acknowledgements.
   * Mathematics: unchanged. The four statements are verbatim: minimisers on the boundary, vertices are the unique minimisers on open intervals, monotonicity in $c$, and an absolute bound selects the same at vertices but also points above the boundary. So are the references to `lem:setup:hull` and `rem:setup:hullconverse`.

### absorb.tex

5. **l.5, §absorb opening paragraph.**
   * Old: "…for example to finite sets \citep{gacs2001algorithmic,vereshchagin2017algorithmic}.\footnote{The point was also raised in the online discussion (on LessWrong) in which the author described the proposal.} The author's note makes it for sequence prediction, where it is better to drop bits of the hypothesis and pay for them in likelihood, and suggests that the pathology is absent in the function case if the randomness is not shared between inputs, each input sampling its own random bits \citep{hanni2026grokking}. We call it the \emph{absorption objection}."
   * New: "…for example to finite sets \citep{…}. In sequence prediction it means that it is better to drop bits of the hypothesis and pay for them in likelihood. In function induction there is a natural way out: if the randomness is not shared between inputs, each input sampling its own random bits, a hypothesis pays its likelihood term separately at every input, and the pathology may be absent.\footnote{The sequence-case pathology, and the suggestion that private randomness at each input avoids it, first appeared in the author's note \citep{hanni2026grokking}.} We call the point the \emph{absorption objection}."
   * Why: §2 ("the author's notes … suggest"). The private-randomness escape is now motivated by the per-input likelihood term, which used to be cited to the note at l.44. The LessWrong footnote is absorbed into the intro footnote (REFRAME §4, Paper 2), and its place is taken by the credit footnote.
   * Mathematics: unchanged. The suggestion stays a hedged hope ("may be absent"); the section's results decide it. The road map sentence after it is verbatim.
6. **l.39, `rem:absorb:reading`.**
   * Old: "Part (a) is the absorption objection made exact, and the precise form of the sequence-case pathology described in \citet{hanni2026grokking};"
   * New: "Part (a) is the absorption objection made exact, and in $\Hcl{\mathrm{SI}}$ the precise form of the sequence-case pathology;"
   * Why: §2 ("described in"). The sequence case is named by its class, which $\Hcl{\mathrm{SI}}$ is (`rem:absorb:examples`).
   * Mathematics: unchanged. Part (a) holds in every class with (Dom), including $\Hcl{\mathrm{SI}}$. The threshold, its limit $\ell_U$, the reference-machine caveat, the (d)/$\Hcl{\mathrm{chr}}$ caveat and the no-rate caveat for (c3) are verbatim.
7. **l.44, opening of §absorb:private.**
   * Old: "In the product class a hypothesis pays its likelihood term separately at every input \citep{hanni2026grokking}."
   * New: the same sentence without the citation.
   * Why: §4 (no citation in running text); the credit is in footnote 1.
   * Mathematics: unchanged.
8. **l.90, `rem:absorb:wyeth`(ii).**
   * Old: "…(\cref{prop:absorb:inputs}). This makes exact the reply in \citet{hanni2026grokking}: if each input has its own private randomness, ``I don't see how to write down a universal hypothesis that gets good loss here''."
   * New: "…(\cref{prop:absorb:inputs})."
   * Why: §2 ("makes exact the reply") and §5 (no quotations, including "I …" sentences). Nothing mathematical needed replacing.
   * Mathematics: unchanged. The three results of (ii) are verbatim: no universal product hypothesis, the conditional semimeasure never learns, and input history does not help.
9. **l.94–95, closing of `rem:absorb:wyeth`.**
   * Old: "Two reasons support it: the dominance statement of the author's note on SFI \citep[note on Solomonoff function induction]{hanni2026notes} compares SFI with computably samplable predictors that use different random bits on different inputs, which are exactly the product hypotheses; and in supervised learning …"
   * New: "Two reasons support it: the product hypotheses are exactly the computably samplable predictors that use different random bits on different inputs, the natural class to compare SFI with, and SFI dominates them \citep[Theorem~5.1(a)]{claudeSFI2026fundamentals};% P1: thm:learn:dominance\n\ and in supervised learning …"
   * Why: §2 ("the dominance statement of [Hän26]"). The reason now rests on the proved dominance theorem of Paper 1 (`thm:learn:dominance`(a), x-only samplers, number 5.1 checked in `paper/main.aux`) instead of the note.
   * Mathematics: unchanged. The identification of these predictors with the product hypotheses is kept verbatim. Paper 1's Theorem 5.1(a) is exactly the dominance of $\MF$ over every lsc conditional semimeasure. The second reason is verbatim.

### teacher.tex

10. **l.7, §teacher opening paragraph.**
    * Old: "The author's note \citep{hanni2026grokking} asks how a learner can grasp what a teacher means rather than predict what the teacher would say, mistakes included, and proposes the steeper objective of \cref{def:setup:objectives} over product hypotheses: when the mistakes are explainable deviations from a simple model, select the simple model with noise. This section makes the example of the note rigorous."
    * New: "A learner that grasps what a teacher means, rather than predicting what the teacher would say, should not reproduce the teacher's mistakes. When these are explainable deviations from a simple model, the steeper objective of \cref{def:setup:objectives} over product hypotheses is meant to select the simple model with noise. This section makes this rigorous for the example of \cref{rem:teacher:hanni}.\footnote{The example (both versions), the three-hypothesis calculation and the convex-hull view of selection first appeared in the author's note \citep{hanni2026grokking}.}"
    * Why: §2 ("asks", "proposes") and §4: the three-hypothesis calculation is a motivating calculation in our voice. This one footnote merges the credits that were at setup l.79, at teacher l.12 and l.17, and in the deleted sentence at l.121.
    * Mathematics: unchanged. The rest of the paragraph is verbatim: the summary of `thm:teacher:main`, the window of more than three orders of magnitude at $\kappa\le30$, and the pointer to §limits.
11. **l.12, `rem:teacher:hanni`, first sentence.**
    * Old: "The note gives two versions of its example \citep{hanni2026grokking}."
    * New: "The example has two versions."
    * Why: §2, §4.
    * Mathematics: unchanged. Both versions are verbatim, with every number ($100$, $10$, $(10,100)$, $2^{-10}$, $10{,}000$, $10{,}100$, $1.1185\cdot10^{-6}$, $8.989\cdot10^{-3}$, $8000$, $8.94\cdot10^5$).
12. **l.17, `rem:teacher:hanni`, closing sentences.**
    * Old: "A direct computation … confirms this arithmetic, with the exact $H(2^{-10})=0.0112$ in place of the approximation $1/100$ of the note. The calculation compares three hypotheses only; it does not exclude partial models, partial memorisers or mixtures, and the note asks: ``Maybe I'm just failing to construct the right `universal hypothesis' for this example?''"
    * New: "A direct computation … gives these numbers, with the exact $H(2^{-10})=0.0112$ rather than $p\log(1/p)\approx1/100$. The calculation compares three hypotheses only; it does not exclude partial models, partial memorisers, mixtures or some universal hypothesis, so it leaves open whether another hypothesis does better."
    * Why: §2 ("confirms this arithmetic" of the note) and §5 (the quotation). The open question is now ours. The approximation $1/100$ is named by its formula, $p\log(1/p)=10/1024$, so the sentence no longer points to the note.
    * Mathematics: unchanged. The caveat that only three hypotheses are compared is kept and extended by the quotation's content, "some universal hypothesis". The numbers are unchanged.
13. **l.121, paragraph after the proof idea of `thm:teacher:main`.**
    * Old: "…near-optimal hypotheses reproduce the errors. For such rules this answers the question of the note quoted in \cref{rem:teacher:hanni}."
    * New: "…near-optimal hypotheses reproduce the errors. For such rules this settles the question left open by the three-hypothesis calculation of \cref{rem:teacher:hanni}."
    * Why: §2 ("answers … the note").
    * Mathematics: unchanged. The scope "for such rules" (error rules incompressible relative to the model, in the window) is kept, and the preceding sentences are verbatim.

### limits.tex

14. **l.25, `rem:limits:schedule`.**
    * Old: "…eventually reproduces the errors (\cref{prop:limits:plain}(b)), as anticipated in \citet{hanni2026grokking}."
    * New: "…eventually reproduces the errors (\cref{prop:limits:plain}(b))."
    * Why: §2 ("as anticipated in").
    * Mathematics: unchanged. The rest of the remark is verbatim: the schedule condition $(\lambda_n/n)(d+L_S)\to0$, the batch excess, the "not a sequential regret" caveat and the non-novelty statement.
15. **l.48, paragraph after `prop:limits:envelope`.**
    * Old: "The example was chosen to favour the proposal, though it is not contrived; what holds is the example for error rules incompressible relative to the model."
    * New: "The example is a favourable case, though not a contrived one; what holds is the example for error rules incompressible relative to the model."
    * Why: "was chosen to favour" referred implicitly to the author's choice (the restated LessWrong remark, DECISIONS §A7). It is now a property of the example in our voice.
    * Mathematics: unchanged. The caveat that the example is favourable, and the scope of what holds, are kept. The deficiency caveat and the envelope remarks around it are verbatim.

### split.tex

16. **l.6, §split opening paragraph.**
    * Old: "A second question of the author's notes is whether a steeper prior prefers a simple sampler to programs in which the sampled bits are filled in; at $\lambda=1$, Solomonoff induction has no such preference. This section makes both halves precise."
    * New: "Labels drawn from a computable sampler are explained both by the sampler, with private coins, and by programs that fill in the sampled bits. At $\lambda=1$, Solomonoff induction has no preference between the two; a steeper prior might prefer the sampler. This section makes both halves precise."
    * Why: §2 ("the author's notes ask"). The question is now posed as a natural one. Its source was the author's request, which is not citable (DECISIONS §A7), so there is no footnote.
    * Mathematics: unchanged. The statement about SI at $\lambda=1$ is kept (proved in `prop:split:si`). The summary that follows is verbatim, with its factors, the triply logarithmic growth, and the private and shared cases.
17. **l.68, `rem:split:reading`.**
    * Old: "This is the split asked for in \cref{sec:intro}, for every fixed $\lambda>1$, in a precise and limited sense."
    * New: "This gives the split for every fixed $\lambda>1$, in a precise and limited sense."
    * Why: the question is now posed in §split itself. The pointer to the intro also depended on intro text that the front group is rewriting.
    * Mathematics: unchanged. Every caveat of the remark is verbatim: "not necessarily $\nu$", up to $(k+\delta^*)/(\lambda-1)$ extra bits, the threshold for fill-ins, the positive fill-in posterior, the meaning of "$\nu$-equivalent on the run", and vacuity on finite domains.

### algstat.tex

18. **l.6, §algstat opening paragraph.**
    * Old: "The author's note proposes a second way to find the split between model and noise: plot the entropy left given the hypothesis against the hypothesis length and look for a change of slope, which in the sequence case does not appear, because there it is ``pretty much just 1 bit paying for 1 bit'' \citep{hanni2026grokking}."
    * New: "Besides a steeper penalty, one can look for the split between model and noise by plotting the entropy left given the hypothesis against the hypothesis length and looking for a change of slope. With shared randomness, as in the sequence case, one expects none, because each bit of hypothesis pays for about one bit of data (\cref{rem:algstat:reading}).\footnote{This way of locating the split, and this reason why the sequence case shows no change of slope, first appeared in the author's note \citep{hanni2026grokking}.}"
    * Why: §2 ("proposes") and §5 (the "1 bit paying for 1 bit" quotation).
    * Mathematics: unchanged. The note's informal claim about the sequence case is kept as an expectation ("one expects"), not as a claim of ours. It points to `rem:algstat:reading`, where the paper makes it precise for the parity, and to `prop:algstat:parity`(i). The rest of the paragraph is verbatim.
19. **l.58, title of `rem:algstat:reading`.**
    * Old: "Reading: one bit paying for one bit"
    * New: "Reading: one bit for one bit"
    * Why: §5. The old title was a near-verbatim rendering of the note's phrase; the new one matches the remark's own wording ("one bit for one bit"). REFRAME §8 allows retitling.
    * Mathematics: unchanged. The label is unchanged.
20. **l.59, `rem:algstat:reading`.**
    * Old: "…and the slope of $\rho^\times_D$ changes at $\alpha\approx d$, as the note \citep{hanni2026grokking} anticipated for the function case."
    * New: "…and the slope of $\rho^\times_D$ changes at $\alpha\approx d$."
    * Why: §2 ("anticipated").
    * Mathematics: unchanged. The remark's statements are verbatim: one bit for one bit with shared randomness, about one bit per input with private randomness, the kink at $\alpha\approx d$, and steeper simplicity useless over sets and decisive over products.

### related.tex

21. **l.13, first sentence of §related.**
    * Old: "This section describes the closest work informally; the objects are defined in \cref{sec:setup}."
    * New: "This section describes the closest work informally; the objects are defined in \cref{sec:setup}, and the basic theory of SFI is in the companion paper \citep{claudeSFI2026fundamentals}."
    * Why: REFRAME §4 (Introductions). The front group deletes the intro paragraph "Relation to the author's notes and to other work", and this was the only "other work" item in it not already in §related or §split.
    * Mathematics: no mathematical content.

## For the front group

* `absorb.tex` no longer has the LessWrong footnote. The intro footnote now carries it; I checked that it is in the current `intro.tex`. The intro comment "the single footnote crediting the proposal … also records the online discussion" is consistent with this.
* My files contain 3 credit footnotes (absorb, teacher, algstat). With the intro's one, Paper 2 has 4.
* `tab:intro:claims` rows still say "the example" and "the arithmetic of the example". These now refer to the example as posed in `rem:teacher:hanni`, in our voice.
