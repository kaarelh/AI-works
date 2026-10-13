# Fresh reader, Paper 1, round 1 (2026-10-13)

Paper 1, `paper/`, read against `research/paper-review/REFRAME.md`. No file was edited.

## How the reading was done

* **Build.** `cd paper && flock /tmp/claude-0/paper-build-sfi.lock ./build.sh`. The result was 0 LaTeX errors, 0 undefined references, 0 undefined citations, 0 multiply defined labels, 0 overfull boxes above 10pt, and 90 pages.
* **Text.** `pdftotext -layout main.pdf` gave 5234 lines. I read lines 1–2383 (front matter to the acknowledgements) and 2613–5234 (Appendices A–H) in full. I skipped the bibliography.
* **Line numbers.** "PDF line" below means the line number in that pdftotext output. Re-running the same command reproduces it.
* **Bibliography keys** (from `main.bbl`):
  * Hänni (2026a) is `claudeSFI2026steeper`, the companion paper.
  * Hänni (2026b) is `hanni2026grokking`, the note on grokking.
  * Hänni (2026c) is `hanni2026notes`, the working notes.
  * Vaintrob and Hänni (2026b) is `vaintrobhanni2026nnbayes`, the slides.

## Summary

* **Footnotes that cite the notes: 8.** The target is at most about 10, so it is met.
  * Seven cite `hanni2026notes` (FN 1–7). One cites `hanni2026grokking` (FN 8).

    | FN | page | PDF lines | where | source |
    |---|---|---|---|---|
    | 1 | 2 | 92 | intro | `intro.tex` l.6 |
    | 2 | 7 | 343–346 | §3 opening | `setting.tex` l.4 |
    | 3 | 12 | 626–627 | §4 opening | `versions.tex` l.4 |
    | 4 | 20 | 1089–1092 | §6 opening | `hist.tex` l.16 |
    | 5 | 31 | 1692–1695 | §8 opening | `ood.tex` l.11 |
    | 6 | 35 | 1907–1910 | §9 opening | `comp.tex` l.15 |
    | 7 | 39 | 2135–2138 | after Prop. 10.2 | `nn.tex` l.29 |
    | 8 | 41 | 2247–2248 | §11 | `steeper.tex` l.8 |

  * All eight are in running text. None is inside a theorem-like environment or a float.
* **(b) Citations outside footnotes and the acknowledgements: none.**
  * Neither `hanni2026notes` nor `hanni2026grokking` is cited anywhere else, in the main text or the appendices.
  * Every other "Hänni (2026b)" in the text is "Vaintrob and Hänni (2026b)", the slides (PDF lines 103, 247, 269, 294, 1039, 2059, 2064, 2100, 2205, 2308, 3641, 5108).
* **(a) "The author".** It appears only in:
  * the title-page footnote;
  * the acknowledgements;
  * the credit footnotes, as "the author's working notes" or "the author's note", which REFRAME §4 allows.

  No body sentence says the notes ask, observe, suggest, intend or state anything. No "earlier draft", "as intended", "read as" or "made precise" survives. Eisenstat's credit ("personal communication", and "from correspondence with S. Eisenstat") is in the allowed form.
* **What remains.** These are reply-shaped residues rather than outright references:
  * two footnotes that implicitly grade the notes (F1, F2);
  * a handful of places where removing the citation left a caveat, a number or a condition without its motivation (F3–F10);
  * small items (F11–F14).

  None needs a change to the mathematics, the numbering or the labels.

## Findings

They are ordered by priority. Each gives the location, the problem and a concrete replacement. The TeX is given where the replacement is not obvious.

### F1. (c) FN 4 implies that the notes' proof sketch fails, and presents Definition 6.6 as readings of the notes

* **Location.**
  * §6 opening, p. 20, PDF lines 1089–1092.
  * Source: `hist.tex` l.16, the footnote after "helps without bound,". It points at `sec:hist:counter`, `thm:hist:randchain`, `conj:hist:algmi` and `def:hist:readings`.
* **Problem.**
  * "an informal dominance statement for simple reveal laws *with a proof sketch by simulation*" credits the notes with a proof sketch. Two pages later, Proposition 6.7 is titled "A direct simulation fails" (p. 22, l.1190). A reader puts the two together and learns that the notes' sketch is wrong, which is an evaluation of the notes.
  * "Definition 6.6 gives three precise formulations of that statement" casts Formulations A/B/C as readings of the notes' statement. REFRAME §3 asks for the dominance statement to be "our question and our theorem", with the formulations as natural formulations of it.
  * The editors' rationale (`log-p1-hist-ex.md`, "Footnote") is that the last clause tells a reader of the notes that the statement is made precise in three ways. A neutral pointer to where the statement holds does that job without the comparison.
* **Replacement** (the credit is kept, and the simulation idea is credited where it works, Theorem 6.8):

  > The examples of \cref{sec:hist:counter} and \cref{thm:hist:randchain}, an informal dominance statement for simple reveal laws, the idea of proving it by simulating the reveal law inside a function machine (\cref{thm:hist:shared}), and the question behind \cref{conj:hist:algmi} first appeared in the author's working notes \citep{hanni2026notes}.

  * If a REFRAME §4 pointer for readers of the notes is wanted, append: "; the forms in which the statement holds are in \cref{cor:hist:thm1}."

### F2. (c) FN 5 credits the notes with the failing form (7), and with "plain complexity"

* **Location.**
  * §8 opening, p. 31, PDF lines 1692–1695.
  * Source: `ood.tex` l.11. It points at `prop:ood:hanni`, `eq:ood:literal` and `sec:ood:examples`.
* **Problem.**
  * "the two-sided statement in the form (7)" sends the reader to Appendix F (p. 82, l.4712–4720). There (7) is introduced and followed at once by "Both fail" and Proposition F.3. So the first footnote of §8 tells an arXiv reader that the notes stated a false bound, which reads as a correction.
  * "with plain complexity" sets up the contrast "no logarithmic term" (see F3) against the notes' version.
  * The editors argue (`log-p1-ood.md`, change 1) that this keeps a reader of the notes from being misled. REFRAME §4's template for that case names the hypotheses that are needed. It does not point at the false form.
* **Replacement:**

  > An informal version of \cref{prop:ood:hanni}, properties simple given a fitted program, a two-sided statement (the form that holds is \cref{thm:ood:twosided}), the question of a converse and the examples of \cref{sec:ood:examples} first appeared in the author's working notes \citep{hanni2026notes}.

### F3. (e)/(d) "No logarithmic term" is a contrast with a version the reader never sees

* **Location.**
  * §8 opening, p. 31, PDF lines 1688–1690: "with no logarithmic term in prefix complexity K".
  * Title of Proposition 8.1, p. 32, l.1721: "Unseen simple properties (no logarithmic term)".
  * Source: `ood.tex` l.11 and l.22 (`prop:ood:hanni`).
* **Problem.**
  * A fresh reader asks: no logarithmic term compared with what?
  * The only answers are FN 5 ("with plain complexity", i.e. the notes) and Remark F.1 in Appendix F (p. 81: plain complexity would cost K(Q) ≤ C(Q)+2 log C(Q)).
  * The proof idea's "Summing over all hypotheses avoids a logarithmic term" does not say where such a term would come from.
* **Replacement.**
  * Retitle `prop:ood:hanni` as **"Unseen simple properties"**.
  * In the §8 opening, replace "with no logarithmic term in prefix complexity $K$ (\cref{sec:ood:prop})" by:

    > at a cost measured in prefix complexity $K$, with no logarithmic term of the kind a bound in plain complexity would carry (\cref{sec:ood:prop}, \cref{rem:ood:logterm})

### F4. (d) §8.4 opens with "the naive converse fails" before any converse has been stated

* **Location.**
  * §8.4, p. 33, PDF lines 1804–1806, with the statement of the converse only afterwards at p. 34, l.1817–1819.
  * Source: `ood.tex` l.84–86 (`prop:ood:converse`) and the paragraph after the proposition.
* **Problem.**
  * The subsection heading is followed directly by Proposition 8.7, "The naive converse fails for complex targets". The converse it refutes is spelled out only after the proof-free statement.
  * Before the reframing, the notes' question supplied this context. Now the motivation comes after the result.
* **Replacement.** Insert one sentence between `\subsection{Converses}` and the proposition:

  > \Cref{prop:ood:hanni,prop:ood:relative} suggest a natural converse: SFI works well at a test point if no property that is simple given a program doing well on the training data separates it. For complex targets this fails:

  Then shorten the first sentence after the proposition (l.1817) to:

  > So this converse fails, both for a program determined by the target (a, b) and for one fitted to the training data (c); the obstruction is $K(f)$.

  The length is unchanged.

### F5. (d) The comment after Theorem 3.20 repeats (b) and then answers a claim that is no longer there

* **Location.**
  * After Theorem 3.20, p. 11, PDF lines 542–545.
  * Source: `setting.tex` l.131 (`thm:setting:invariance`).
* **Problem.**
  * "So a computable re-encoding of inputs and labels costs at most K(α,β)+O(1) bits" restates the last sentence of (b) (l.537–539).
  * "The constant is not small for complex encodings" is then a caveat to the claim "the encoding matters little", which now appears only in FN 2.
  * Read cold, the paragraph is a rebuttal without a thesis, and (b) has no stated motivation.
* **Replacement** (the caveats are kept verbatim):

  > So the encoding of inputs and labels matters little as long as it is simple: a computable re-encoding changes losses by at most $K(\alpha,\beta)+O(1)$ bits. The constant is not small for complex encodings; only the upper bound is proved, and whether such encodings can change losses by that much is not known. Non-computable encodings are not covered.

### F6. (e) Definition 6.6 lists the formulations in the order A, C, B

* **Location.**
  * Definition 6.6, p. 22, PDF lines 1173–1177.
  * Source: `hist.tex` l.61–62 (`def:hist:readings`).
* **Problem.**
  * The letters run A, C, B. Only the notes' "Readings A/B/C" explain this order. The log (`log-p1-hist-ex.md`) records that letters and order were deliberately left unchanged.
  * A fresh reader sees an unexplained permutation.
* **Replacement.** Reorder the three sentences only. No letter changes, no text elsewhere changes, and Paper 2 never mentions the formulations.

  > Let $y_i=f(x_i)$. \emph{Formulation A}: one reveal law $\Delta(x_i\mid h_{i-1})$ that does not see $f$ (private randomness and memory allowed), $f$ arbitrary. \emph{Formulation B} (the oracle form): $x_i\sim\Delta(\cdot\mid f,h_{i-1})$, with $C_\Delta$ the complexity of $\Delta$ relative to an oracle for $f$. \emph{Formulation C}: for each $f$ a reveal law $\Delta_f(x\mid h)$ that sees only the history, with $C_\Delta:=K(\Delta_f)$ as a standalone sampler; A is the case $\Delta_f=\Delta$.

  The following paragraph, "Formulation C is the natural one for SFI: …", then follows the item it discusses.

### F7. (d) "The condition that no simple property separates test from train" is used before it is introduced

* **Location.**
  * Proof idea of Proposition 5.9, p. 19, PDF lines 1017–1020.
  * Source: `learn.tex` l.117 (`prop:learn:typical`).
* **Problem.** "the condition" refers to something not yet stated. It replaced a quotation of the notes' condition. The condition is introduced as a natural converse only in §8.4.
* **Replacement:**

  > So the natural sufficient condition for generalisation, that no simple property separates the test input from the training inputs (\cref{sec:ood:converse}), typically holds only at scales of about $\log n$ bits.

### F8. (d) "So 10⁶ℓ(f) samples suffice" now has no reason to be there

* **Location.**
  * After Proposition G.6, p. 86, PDF lines 4975–4976.
  * Source: `app-comp.tex` l.52 (`prop:comp:occam`).
* **Problem.**
  * 10⁶ was the sample size of the in-distribution theorem in the notes' circuit note (`log-p1-ood.md` renamed C(f) to ℓ(f)). Without that reference, a reader sees an arbitrary constant right after the exact count 70ℓ(f)+531.
* **Replacement.**
  * Preferred: end the sentence after the exact count, as "Part (a) is a union bound over $H_f$; with $\varepsilon=\delta=0.01$ it needs $70\ell(f)+531$ samples." The clause only served the comparison with the notes, and the claim that remains is unchanged.
  * If the number must stay (REFRAME §8): "…, so a sample size linear in $\ell(f)$ suffices, for instance $10^6\,\ell(f)$."

### F9. (d) Remark G.7 comments on a proof step that the paper never presents

* **Location.**
  * Remark G.7, p. 87, PDF lines 5024–5029.
  * Source: `app-comp.tex` l.70 (`rem:comp:gap`).
* **Problem.**
  * "Passing from log loss at most poly(m) to a circuit of size at most poly(m) is a circuit coding theorem" was "The sketch passes from …". Now it describes a step of an argument that the reader has not seen.
* **Replacement:**

  > Any argument that first bounds the log loss by $\mathrm{poly}(m)$ and then infers a circuit of size $\mathrm{poly}(m)$ needs a \emph{circuit coding theorem}, which (a) gives for a size prior with exponential tail, while a polynomial tail gives only $\csize(f)\le2^{O(L)}$.

### F10. (d) Remark G.1 introduces a particular sequence predictor without saying why

* **Location.**
  * Remark G.1, p. 85, PDF lines 4905–4908.
  * Source: `app-comp.tex` l.19 (`rem:comp:constant`).
* **Problem.** "For sequences, a predictor that starts machine i at the round r₁ with log log r₁ ≥ i has regret …" was the notes' polytime predictor. Now it is an arbitrary-looking example.
* **Replacement:**

  > For comparison, the natural sequence predictor that starts machine $i$ at the first round $r_1$ with $\log\log r_1\ge i$ has regret $\max(r_1,r_2)$ bits, with $r_2$ the round after which the comparator runs within its clock: doubly exponential in $i$.

### F11. (a) Remark 7.18 grades the heuristic argument like a referee

* **Location.**
  * Remark 7.18, p. 30, PDF lines 1589–1601.
  * Source: `examples.tex` l.164–166 (`rem:ex:email`).
* **Problem.**
  * Before the reframing the heuristic was "a heuristic argument of the author". The remark still says "The claim … holds …" and "The converse needs two changes".
  * Now that the heuristic is anonymous, the tone is less pointed, but it still reads as a verdict on someone's argument. It could instead present how the heuristic is made rigorous.
* **Replacement.** This keeps every caveat. It replaces the two sentences from "The claim that the two losses agree" to "…(enough for o(n), not for O(log n); Appendix E.3)":

  > Made rigorous, the agreement of the two losses holds in the semimeasure convention, almost surely with $O(\log n)$ in place of $o(n)$ and the threshold at the tail frontier (\cref{thm:ex:sandwich}); the upper bound is \cref{prop:ex:UB}. The lower bound takes two steps beyond the heuristic: the step from a lower bound on the semimeasure to a short description is the coding theorem given the domain of the fully revealed segment $[0,g_n)$, which costs $K(g_n)=O(\log n)$ bits; and incompressibility is measured by the empirical surprisal $UB_n$, not by $\tau_nH(1/3)$, which differs from it by $\Theta(\sqrt n)$ (enough for $o(n)$, not for $O(\log n)$; \cref{app:ex:eisenstat}).

### F12. (c) FN 1 and FN 2 both credit the definition of SFI

* **Location.**
  * FN 1, p. 2, l.92 ("The notion of SFI first appeared …").
  * FN 2, p. 7, l.343–346 ("This informal definition, …").
  * Source: `intro.tex` l.6 and `setting.tex` l.4.
* **Problem.**
  * The informal definition in §3 is now in our own words, so crediting "this informal definition" repeats FN 1.
  * The front log itself suggested that the setting footnote need not repeat the credit.
* **Replacement.**
  * Drop "This informal definition," from FN 2.
  * Move its mark to the end of the next sentence ("… private to each input or shared by all inputs."), where the private streams are mentioned.
  * New FN 2 text:

    > The private random stream per input, with the resulting dominance (\cref{thm:learn:dominance}(a)), and an informal claim that the input encoding matters little (\cref{thm:setting:invariance}(b)) first appeared in the author's working notes \citep{hanni2026notes}.

  * The count stays at 8.

### F13. (e) "Proposition 8.1 (in this form)" in the novelty paragraph points at an unseen earlier form

* **Location.**
  * Related work, "Novelty", p. 6, PDF line 282.
  * Source: `related.tex` l.27.
* **Problem.** "In this form" invites the question "as opposed to which form?". The only answer is FN 5, i.e. the notes.
* **Replacement:** "\cref{prop:ood:hanni} (as a prefix-complexity bound with no logarithmic term)", or simply drop "(in this form)".

### F14. (a) "Easy-to-hard generalisation is limited in one precise sense" still answers a remark

* **Location.**
  * Example 8.12(a), p. 35, PDF lines 1876–1878.
  * Source: `ood.tex` (`ex:ood:hanniexamples`).
* **Problem.**
  * The sentence replaced "This gives one precise sense to the tentative remark in [notes] that … easy-to-hard generalisation 'is not' a thing". "Limited in one precise sense" keeps the shape of a reply to a claim that is no longer in the text.
  * It is low priority: it also reads acceptably on its own.
* **Replacement:**

  > So no number of easy sentences removes a (small) floor on the wrong-label probability of a hard one: in this sense easy-to-hard generalisation is never certain.

## Checked and found clean

* **Openings of §3, §4, §6.2, §6.3, §6.4, §9 and §10.** Each motivates its subject on its own terms:
  * §3: the informal definition in our voice;
  * §4: two natural formalisations, and the coding-theorem question;
  * §6.2: the examples, stated directly;
  * §6.3: "one may hope …", "How C_Δ is measured matters";
  * §6.4: "a natural intermediate";
  * §9: "Two computable relatives are natural";
  * §10: "one may ask whether a network then behaves like circuit SFI …".
* **The results REFRAME §3 asks to be reframed** are stated as natural candidates or strategies that fail, with no reference to the notes:
  * Proposition 6.7 "A direct simulation fails" (p. 22);
  * Proposition F.3 "Two natural two-sided bounds fail" (p. 82);
  * Theorem 6.11 "… the oracle form fails" (p. 23);
  * Proposition 8.7, "So the natural converse … fails" (p. 34). See F4 for its placement.
  * Remark 9.9 "A natural argument, which holds for weighted majority" (p. 38).
  * Remark D.7, Proposition D.8, Proposition D.9, Conjecture D.10, and the "Formulation" wording throughout.
* **Introduction and discussion.**
  * No "Relation to the author's notes" paragraph remains.
  * The contributions list does not mention the notes.
  * The discussion's "formalises directly the informal definition" refers to §3's own definition.
* **Acknowledgements.** They carry the sentence REFRAME requires, "Several of the questions and examples studied here first appeared in those notes."
* **No quotations** from the notes or the grokking note remain.
* **Section, theorem and remark titles.** None refers to the notes. Remaining title issues are F3 (Proposition 8.1) and, mildly, F6.

## Outside the brief (for the lead, no action implied)

* **O1.** p. 6, l.273, `related.tex` l.24: "the slides call this the closest prior work" reports the slides' judgement in our related-work paragraph. Possible rewrite: "(singled out as the closest prior work in the slides of Vaintrob and Hänni, 2026b)", or delete.
* **O2.** Remark 10.8 (p. 41, l.2205–2221) still quotes four phrases of the slides ("importantly different", "scrambled only polynomially", "does not have a good circuit prior", "is simply false"). REFRAME §6 allows citing the slides and only forbids quoting their caveats, but paraphrase would match the paper's voice.
* **O3.** FN 8 cites "Hänni (2026b)" (the grokking note), while the slides are "Vaintrob and Hänni (2026b)". The shared suffix b is easy to confuse. It is a natbib artefact and needs no text change.
* **O4.** These three passages say much the same thing:
  * the Hutter/AIXI sentence and "we define M_H directly and do not use any identification with Hutter's construction" in the introduction (l.98–99);
  * the same in Related work (l.228–234);
  * the paragraph after Corollary 6.17 (l.1298–1302), nearly verbatim.

  The last two could be cut to one.
