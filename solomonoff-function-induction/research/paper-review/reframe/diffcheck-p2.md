# Paper 2: mathematics-invariance check of the reframing diff

Scope: `git diff 5acf4db3 -- paper-steeper/sections paper-steeper/main.tex`, which compares commit 5acf4db3 with the working tree on 2026-10-13. It touches 9 files (35+/34−): absorb, algstat, discussion, intro, limits, related, setup, split, teacher. `main.tex` and all appendices are unchanged. Every hunk was read in word-diff form and checked against REFRAME.md, the steeper track record (`research/tracks/steeper/notes-final.md`), the grokking note (`research/prior/hanni-grokking-a-notion.md`), Paper 1 (`paper/main.aux`, `paper/sections/learn.tex`) and the slides text. Nothing was edited.

## Verdict

* **No mathematical statement, hypothesis, quantifier, number, constant or proof step changed.** All inline math on the removed lines survives on the added lines or elsewhere in the paper, with two exceptions. The approximation "1/100" becomes the correct "$p\log(1/p)\approx1/100$". "in $\Hcl{\mathrm{SI}}$" is added, and it is a correct restriction.
* **No caveat or open-question statement was lost.**
  * "leaves open whether another hypothesis does better" is still in `rem:teacher:hanni`.
  * "We do not claim as new …" is still in related.tex and limits.tex.
  * The questions in the intro and the split section are now asked directly.
* **Structure is unchanged.**
  * No numbered environment, section, subsection or numbered equation was added or removed.
  * No `\label` was renamed, added or removed.
  * No `\status`/`\src` call was removed. The only environment touched is `rem:algstat:reading`, retitled "Reading: one bit for one bit".
* **The build is clean.** The latest full build (`main.log`, 01:09:56) is newer than every edited source (latest 00:59:47). It has 0 LaTeX errors, 0 undefined references or citations and 0 multiply defined labels, at 57 pages, the same as at 5acf4db3.
* **Footnotes are within the REFRAME limits.**
  * There are 4 credit footnotes (limit 5): intro, absorb, teacher, algstat.
  * All four are in running text, none in a statement or a float.
  * The old LessWrong footnote is merged into the intro footnote, as REFRAME §4 prescribes.
* **New cross-references resolve:** `tab:intro:claims`, `rem:teacher:hanni` (×3), `rem:algstat:reading`, `rem:limits:schedule`, `sec:absorb`. The new citation `\citep[Theorem~5.1(a)]{claudeSFI2026fundamentals}` matches Paper 1 (`thm:learn:dominance` = 5.1; part (a) covers x-only samplers, that is, lsc conditional semimeasures).

There are 5 findings, all minor and all in category (2): new wording asserts a fact or a priority that the paper and the track records do not support. One further non-mathematical observation is listed after them.

## Findings

### F1. algstat.tex:6 (section opening, first hunk): an overgeneral "no change of slope" claim, now in our voice
* **Old:** "The author's note proposes a second way … look for a change of slope, which in the sequence case does not appear, because there it is ``pretty much just 1 bit paying for 1 bit'' \citep{hanni2026grokking}."
* **New:** "With shared randomness, as in the sequence case, one expects none, because each bit of hypothesis pays for about one bit of data (\cref{rem:algstat:reading})."
* **Problem:** this was the note's remark and is now our general assertion. As stated it is false or unsupported in general.
  * Bits of a structured shared model can pay for many bits of data: Version 1 of the example has 100 bits per bit.
  * The set-model structure function does change slope at the minimal sufficient statistic. For the noisy parity this happens at $\alpha=O(\log d)$.
  * What the paper proves is narrower. By `prop:algstat:parity`(i), the set structure function lies on the sufficiency line for $\alpha$ between $O(\log d)$ and $d+O(\log d)$. By `rem:algstat:reading`, a random $d$-bit parameter costs the same in model and data. So the slope does not change where a random parameter ends, "at the model", as the table row of `tab:intro:claims` correctly says.
  * The note itself carries the caveat "(until you specify it in full if it's finite complexity)".
* **Fix:** replace the sentence with: "With shared randomness, as in the sequence case, one expects no change of slope where a random parameter of the model ends, because each bit of such a parameter pays for about one bit of data (\cref{rem:algstat:reading})."

### F2. algstat.tex:6, the new footnote: a false priority claim
* **New:** "This way of locating the split, and this reason why the sequence case shows no change of slope, first appeared in the author's note \citep{hanni2026grokking}."
* **Problem:**
  * Locating the model–noise split by a change of slope of the remaining entropy against model length is Kolmogorov's structure function, as the very next sentence of the paper says. It is standard: gacs2001algorithmic, vereshchagin2004kolmogorov.
  * The footnote also states as a fact that "the sequence case shows no change of slope" (see F1).
  * What the note contributes is the suggestion to look for this change of slope in the function case, together with its one-bit-for-one-bit reason.
* **Fix:** "The suggestion to look for this change of slope in function induction, and the reason why none is expected with shared randomness, first appeared in the author's note \citep{hanni2026grokking}."

### F3. absorb.tex:5 (section opening, first hunk), the new footnote: a priority claim for a standard point
* **New:** "The sequence-case pathology, and the suggestion that private randomness at each input avoids it, first appeared in the author's note \citep{hanni2026grokking}."
* **Problem:**
  * The same paragraph calls the pathology "a standard point, familiar from algorithmic statistics".
  * The binding comment at absorb.tex:2 says the absorption objection is a standard point and is not to be attributed to a person in visible text.
  * The old text said only that the note "makes" the point. "First appeared" is a new priority claim for the pathology. The claim is supported only for the private-randomness suggestion (grokking note, line 7).
* **Fix:** "The suggestion that private randomness at each input avoids the sequence-case pathology first appeared in the author's note \citep{hanni2026grokking}, which also describes the pathology."

### F4. intro.tex:15 (second paragraph, intro hunk 2): the new sentence "A three-hypothesis calculation supports this hope."
* **Problem:**
  * "This hope" is that absorption fails with private randomness.
  * The calculation in `rem:teacher:hanni` compares the good model, the memoriser and a coin. It contains no universal or absorbing hypothesis, so it bears on the proposal, not on absorption.
  * The old text made no such evidential link: "Its example has …". The paper itself says two sentences later that "three hypotheses are not all hypotheses".
* **Fix:** "A three-hypothesis calculation illustrates the proposal." The rest of the paragraph can stay as it is.

### F5. teacher.tex:7 (section opening, first hunk), the new footnote: "the convex-hull view of selection first appeared in the author's note"
* **Problem:**
  * Penalised or two-part selection picking vertices of the lower convex hull of (complexity, loss) is standard. The earlier report also has the hull lemma: related.tex, `rem:related:t5`.
  * The old text credited something narrower: "the observation … that the good model of the example … could be a vertex of the convex hull …, and the alternative proposed there, an absolute bound on model complexity". This is grokking note, lines 8 and 62.
  * The new setup.tex:79 now presents the absolute bound as "a natural alternative to the penalty", and no footnote credits it.
* **Fix:** "The example (both versions), the three-hypothesis calculation, the question whether the good model is a vertex of the convex hull of (complexity, expected log loss), and the absolute bound on model complexity as an alternative first appeared in the author's note \citep{hanni2026grokking}."

### Observation (framing, not mathematics): setup.tex:63
"The two-part objective puts a higher coefficient on the length of the program than on the likelihood term" is an unquoted, near-verbatim copy of the grokking note: "with a higher coefficient on the length of the program than on the likelihood terms". REFRAME §5 names this phrase as one to paraphrase. Suggested: "The two-part objective weights the length of the program more heavily than the log-likelihood; the power-prior posterior is its Bayesian form." The mathematics is unaffected.

## Hunks checked and found invariant

| file:line | hunk | check |
|---|---|---|
| absorb.tex:5 | opening paragraph | The LessWrong footnote is removed and merged into the intro footnote (REFRAME §4). The sequence-case content ("better to drop bits … pay in likelihood") is supported by `thm:absorb:absorption`(a). The private-randomness route is hedged ("may be absent"). Only the footnote is flagged (F3). |
| absorb.tex:39 | `rem:absorb:reading` | Adds "in $\Hcl{\mathrm{SI}}$". This is correct: `rem:absorb:examples` gives (Dom) in $\Hcl{\mathrm{SI}}$ with $U=M$. The threshold, its limit and the caveats are unchanged. |
| absorb.tex:44 | §absorb:private opening | Citation dropped; statement unchanged. |
| absorb.tex:90 | `rem:absorb:wyeth`(ii) | Drops the quoted reply. The mathematical content (no universal product hypothesis; `cor:absorb:nouniversal`, `rem:absorb:condsemi`, `prop:absorb:inputs`) is already in (ii). |
| absorb.tex:94 | `rem:absorb:wyeth`, last sentence | Adds "SFI dominates them [P1, Theorem 5.1(a)]". This is correct: product laws are machine laws, so $\MF\ge2^{-K(\nu)}\nu$, and 5.1(a) is the x-only-sampler loss form. The `%`-comment followed by `\ and` renders as "…5.1(a)); and in supervised learning …" (checked in pdftotext). |
| algstat.tex:58 | `rem:algstat:reading` | Title and attribution changed; all mathematics unchanged. |
| discussion.tex:2,30 | comment; acknowledgements | Adds the REFRAME sentence and the grokking credit. `hanni2026grokking` sits in the same repository as `hanni2026notes` (bib/core.bib), so "those notes" is accurate. |
| intro.tex:9 | first paragraph and footnote | Citation moved to the footnote. The footnote follows REFRAME §4 verbatim and is attached after the sentence. |
| intro.tex:13 | "We consider it for function induction with private randomness at each input" | Same content as the old quotation. |
| intro.tex:15 | absorption paragraph | "In sequence prediction the objection holds (\cref{sec:absorb})" is supported by `thm:absorb:absorption`(a),(d). The open questions are kept as direct questions. Only F4 is flagged. |
| intro.tex:43 | table row on the calculation | "per-sample version" = Version 2 and "total-bits version" = Version 1, as in `rem:teacher:hanni`. The numbers are unchanged: 11,710; (9.77, 58.0]; $n=10^4$; $\kappa=0$; (10,100). |
| intro.tex:50 | row "Has a steeper penalty been studied …"; caption | Wording only; the caption is the one REFRAME prescribes. |
| intro.tex (deleted ¶) | "Relation to the author's notes and to other work" | Its other-work content survives elsewhere:<br>• companion paper: related.tex:13;<br>• Eisenstat's coin covered by `thm:split:lambda1`: split.tex:47 and the acknowledgements;<br>• the earlier report formalised the proposal: `rem:related:t5`;<br>• "target is the data distribution" and "we do not claim as new …": `rem:related:mdl` and `rem:limits:schedule`. |
| limits.tex:25 | `rem:limits:schedule` | Citation dropped; statement unchanged. |
| limits.tex:48 | "a favourable case, though not a contrived one" | Wording only. "Chosen to favour the proposal" is kept in the intro. |
| related.tex:13 | opening | Adds the pointer to the companion paper, moved from the intro. |
| setup.tex:14 | `\Mprod` row | "computably samplable predictors that use fresh random bits at each input" replaces "… of [notes]". The inclusion is true and unchanged in content. |
| setup.tex:63 | two-part objective | Attribution dropped; see the observation above. |
| setup.tex:76 | `rem:setup:persample` | "must grow … (\cref{rem:limits:schedule})": the claim is now backed by our own result instead of the note. |
| setup.tex:79 | hull paragraph | "absolute length bound" becomes "absolute bound on model complexity" (= $\ell(\pi)$). Both hull statements are unchanged. |
| split.tex:6 | section opening | "simple sampler" becomes "computable sampler", and the question is now asked directly. The $\lambda=1$ claim about SI is unchanged. |
| split.tex:68 | `rem:split:reading` | Drops "asked for in \cref{sec:intro}"; all caveats are kept. |
| teacher.tex:7 | section opening | The framing is rewritten. "Makes this rigorous for the example", followed by the incompressible-rule restriction, is unchanged in substance. Only the footnote is flagged (F5). |
| teacher.tex:13–17 | `rem:teacher:hanni` | All numbers are unchanged. "$p\log(1/p)\approx1/100$" is correct ($10/1024=0.0098$) and is the note's own approximation (note, line 58). The caveat is kept and extended with "some universal hypothesis". |
| teacher.tex:121 | "settles the question left open by the three-hypothesis calculation" | Wording only. |

## Slides of Vaintrob and Hänni

No hunk touches the slides citations. They appear in two places:
* `rem:related:nn` (computable.tex:29–31): "the bridge question of the companion paper …, which the slides of \citet{vaintrobhanni2026nnbayes} motivate; nothing here settles it";
* the acknowledgements (discussion.tex:28): "The question of \cref{rem:related:nn} comes from joint work with Dmitry Vaintrob".

Both remain accurate:
* The slides state as their research aim to "Establish that/when the neural net Bayesian prior is a circuit complexity prior" (slide 32).
* Their Appendix F asks "is the NNbayes prior a Kolmogorov prior?" and argues it charges for computation, not description alone.
* So "motivate" and "comes from joint work" are fair, and Paper 2 claims nothing further from the slides.
* The Paper 1 numbers cited next to them still match `paper/main.aux`: Proposition 10.1, Question 10.9, Remark H.2, Section 9.1, Proposition A.10.
