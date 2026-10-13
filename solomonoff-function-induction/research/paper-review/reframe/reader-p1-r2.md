# Paper 1, fresh reader, round 2 (2026-10-13)

## How the reading was done

* **Build.** `cd paper && flock /tmp/claude-0/paper-build-sfi.lock ./build.sh`. Result: 0 LaTeX errors, 0 undefined references or citations, 0 multiply defined labels, 0 overfull hboxes above 10pt, 90 pages.
* **Text.** `pdftotext -layout main.pdf` was saved as `reframe/p1-r2-main.txt` (5247 lines). "PDF line" below means a line of that file.
* **What was read.** The whole main text, the acknowledgements and Appendices A–H, in order, as an arXiv reader would. The bibliography was skipped.
* **Tracing.** Each passage was traced to its `.tex` source and label. For context I used REFRAME.md, the notes in `research/prior/` and `git diff 5acf4db3`. Nothing was edited.
* **Bibliography keys** (from `main.bbl`):
  * Hänni (2026a) = `claudeSFI2026steeper`, the companion paper, a normal reference;
  * Hänni (2026b) = `hanni2026grokking`;
  * Hänni (2026c) = `hanni2026notes`;
  * Vaintrob and Hänni (2026b) = `vaintrobhanni2026nnbayes`, the slides, citable joint work.

## Summary

* **(a) Replying to the notes, or "the author" in the body.**
  * No body sentence says that the notes ask, observe, state or intend anything.
  * "The author" appears only in three places, all allowed:
    * the title-page footnote;
    * the acknowledgements;
    * the credit footnotes, as "the author's working notes", which is REFRAME §4's own model wording.
  * Eisenstat's credit uses the allowed forms: "due to Sam Eisenstat (personal communication)" and "from correspondence with S. Eisenstat".
  * **One phrase remains that only makes sense against an earlier draft:** "the second, read as a lower bound on the probability of violation, is (c)" (F1).
* **(b) Citations of `hanni2026notes` or `hanni2026grokking` outside footnotes and the acknowledgements: none.**
  * Running text cites Hänni (2026c) only in the acknowledgements, and Hänni (2026b) not at all.
  * `app-verification.tex` cites the notes, but it is built only under `\ifsfirecord`, so it is not in the PDF.
* **(c) Credit footnotes.**
  * None is inside a theorem-like environment or a float. The `\footnotesize` at `versions.tex:104` is a font size, not a footnote.
  * All are neutral.
  * One is hard to parse (F2).
  * Two end with a pointer to "the form proved here". These are acceptable; see "Optional".
* **(d) Missing motivation.** Four places still lean on context that is now gone (F1, F3, F4, F5).
* **(e) Titles.** Two minor retitlings (F6, F7).
* **Footnotes citing the notes: 8**, against the target of at most about 10.
  * 7 cite `hanni2026notes`; 1 cites `hanni2026grokking`.
  * There is one per section, and no two can usefully be merged.

### The 8 credit footnotes

| # | section | PDF page, lines | source | attached to | credits |
|---|---|---|---|---|---|
| 1 | 1 Introduction | p. 2, l. 91–92 | `intro.tex:6` | "… labels every input." | the notion of SFI |
| 2 | 3 Function semimeasures … | p. 7, l. 343–346 | `setting.tex:4` | "… private to each input or shared by all inputs." | private stream per input and its dominance (Thm 5.1(a)); informal encoding claim (Thm 3.20(b)) |
| 3 | 4 Kolmogorov and semimeasure versions | p. 12, l. 626–627 | `versions.tex:4` | "… natural to ask whether they agree here." | the question |
| 4 | 6 History-aware prediction | p. 20, l. 1084–1088 | `hist.tex:16` | "… seeing the history helps without bound," | examples of §6.2 and Thm 6.11; informal dominance statement; simulation idea (Thm 6.8); question behind Conj. D.10 |
| 5 | 8 Out-of-distribution behaviour | p. 31, l. 1682–1686 | `ood.tex:11` | "… generalises as intended." | informal Prop 8.1; log-term question; observation behind Prop 8.2; properties simple given a fitted program; two-sided statement; converse question; §8.5 examples |
| 6 | 9 Computable versions | p. 36, l. 1961–1965 | `comp.tex:15` | "… should be polynomially related." | both computable relatives (activation, clocking, replay, like-for-like caveat, polytime extension); Occam in-distribution bounds; the every-ordering question |
| 7 | 10 Neural-network Bayes | p. 39, l. 2133–2136 | `nn.tex:29` | "… can omit most simple functions." | a version of Prop 10.2; three questions |
| 8 | 11 Steeper simplicity priors | p. 41, l. 2248–2249 | `steeper.tex:8` | "… teacher's systematic errors." | the steeper-prior proposal (`hanni2026grokking`) |

## Findings

Findings are listed by importance. Every replacement changes only framing or motivation. No statement, hypothesis, number, label, `\status`/`\src` call or numbered environment changes.

### F1. (a)/(d) "the second, read as a lower bound on the probability of violation, is (c)" is a leftover of the "read as intended" framing, and the second "natural" candidate has no motivation

* **Location.**
  * Main text: §8.2, end of the paragraph after Theorem 8.3, p. 33, PDF l. 1755–1756. Source: `ood.tex:51`, after `thm:ood:twosided`.
  * Appendix: App. F, before Proposition F.3, p. 82, PDF l. 4729–4737. Source: `app-ood.tex:38` (`eq:ood:literal`, `prop:ood:draftfalse`).
* **Current text.**
  * `ood.tex:51`: "Two natural pointwise bounds of this kind fail (Proposition F.3); the second, read as a lower bound on the probability of violation, is (c)."
  * `app-ood.tex:38`: "… two natural pointwise forms of the two-sided statement of Section 8.2 are, for an input x and data D, (7) …"
* **Problem.**
  * "Read as" tells the reader that a bound which someone wrote down meant something other than what it says. Only a reader of the earlier draft knows who wrote it. REFRAME §2 bans "read as intended", and this is that phrase in another form. (Round 1 reported that no "read as" survives. This one does.)
  * The second line of (7) also gives a fresh reader no reason to find it "natural". It is an *upper* bound on the probability of an abiding output, c·2^(−K(Q)−K(z_x)). For simple P it even contradicts the first line.
  * §8.2 has just motivated the two-sided statement as "a constant probability of happening and of not happening". The natural pointwise form of "not happening" is a lower bound on violation, which is (c). The reader sees an unnatural candidate, called natural, and then is told to "read" it as something else.
* **Replacement, `ood.tex:51`** (from "Two natural …" to the end of the paragraph):
  > Two natural pointwise bounds of this kind fail (\cref{prop:ood:draftfalse}). The second bounds the probability of an abiding output from above; what holds in its place is (c), a lower bound on the probability of a violating output.
* **Replacement, `app-ood.tex:38`** (the sentence that introduces (7); the display and "where $z_x$ … Both fail:" stay unchanged):
  > For a property $P\subseteq X\times Y$ of input--output pairs (for example, ``$y$ is a correct proof of $x$''), two pointwise forms of the two-sided statement of \cref{sec:ood:twosided} suggest themselves: a lower bound on the probability of an abiding output that depends on $P$ alone, and an upper bound on it that is small when $Q$ and the simplest violating output are simple. For an input $x$ and data $D$ they read
* **Optional.** Keep the title of Proposition F.3, "Two natural two-sided bounds fail", as REFRAME §3 prescribes.

### F2. (c) Footnote 5 cannot be parsed as a list

* **Location.** §8 opening, p. 31, PDF l. 1682–1686. Source: `ood.tex:11`, footnote after "generalises as intended."
* **Current text.** "An informal version of Proposition 8.1, with the question whether a logarithmic term is lost and the observation behind Proposition 8.2, properties simple given a fitted program, a two-sided statement (for the form proved here see Theorem 8.3), the question of a converse and the examples of Section 8.5 first appeared in …"
* **Problem.**
  * The opening "with … and …" swallows the next item. "Properties simple given a fitted program" then reads as an apposition to "the observation behind Proposition 8.2". It is in fact a separate item, Proposition F.2. Proposition 8.2 is about the dependence on the universal machine.
  * The parenthesis "(for the form proved here see Theorem 8.3)" is acceptable as a pointer, but it adds a third level of nesting to an already long footnote.
* **Replacement** (the same credits, as a plain list):
  > \footnote{An informal version of \cref{prop:ood:hanni}, the question whether it loses a logarithmic term, the observation behind \cref{prop:ood:machine}, properties that are simple given a fitted program (\cref{prop:ood:relative}), a two-sided statement, the question of a converse and the examples of \cref{sec:ood:examples} first appeared in the author's working notes \citep{hanni2026notes}.}

### F3. (d) "one half of the comparison holds": which comparison, and why the uniform prior over circuits of one size?

* **Location.**
  * §10, the paragraph before Proposition 10.4, p. 40, PDF l. 2140–2142. Source: `nn.tex:36`, before `prop:nn:uniform`.
  * The follow-up "The other half of the comparison" is at PDF l. 2150–2151 (`nn.tex:43`).
* **Current text.** "For the uniform prior over circuits of one size, one half of the comparison holds (Definition 9.7 for N_s and size):"
* **Problem.**
  * The question of comparing uniform and simplicity priors on circuits is now credited only in footnote 7. The body never poses it.
  * The text names no comparison. The last candidate in the text is "how P_A compares with 2^(−K), with M_F, or with a circuit prior", two paragraphs earlier.
  * Nor does the text say why the uniform prior over circuits of a fixed size is the object to look at.
* **Replacement** (whole sentence; the label and numbering are unchanged):
  > The simplest stand-in for a fixed architecture with random parameters is the uniform prior over circuits of one size, and one may ask whether it agrees with the circuit simplicity prior $\Wcirc$ of \cref{def:comp:circuits} up to polynomial factors. One half of this comparison holds ($N_s$ and $\csize$ as in \cref{def:comp:circuits}):
* `nn.tex:43` can stay as it is ("The other half of the comparison, that …"), since the comparison is now defined.

### F4. (d) "compare like with like" appears without the concern it answers

* **Location.**
  * §9.1, after Corollary 9.5, p. 37, PDF l. 1991–1992. Source: `comp.tex:60`, after `cor:comp:poly`.
  * Remark G.3, p. 85, PDF l. 4934–4935. Source: `app-comp.tex:29` (`rem:comp:apples`).
* **Current text.**
  * `comp.tex:60`: "For x-only comparators these results compare like with like; history-aware comparators need a chronological learner (Remark G.3):"
  * `app-comp.tex:29`: "A time-bounded sequence learner that reuses state across rounds, against comparators that recompute each round, does not compare like with like."
* **Problem.**
  * The caveat was once introduced as a remark in an earlier note. Now the main text asserts "like with like" before any reader has seen a reason to doubt it. The reason appears only in an appendix remark, three pages later.
  * Remark G.3 opens with "A time-bounded sequence learner", a learner the paper does not define. The reader cannot tell whether it is a specific object.
* **Replacement, `comp.tex:60`** (second sentence):
  > For x-only comparators, which see one input per round and have nothing to reuse across rounds, these results compare like with like; history-aware comparators need a chronological learner (\cref{rem:comp:apples}):
* **Replacement, `app-comp.tex:29`** (first sentence; the rest of the remark is unchanged):
  > A time-bounded learner may reuse computations from earlier rounds; if its comparators must recompute everything in each round, the learner has a resource they lack, and the comparison is not like with like.

### F5. (d) Remark G.1 quotes the regret of an unnamed sequence predictor with no source or proof

* **Location.** Remark G.1 (Size of the constant), p. 85, PDF l. 4919–4921. Source: `app-comp.tex:19` (`rem:comp:constant`).
* **Current text.** "For comparison, a time-bounded predictor for sequences that starts machine i at the round r_1 with log log r_1 ≥ i has regret max(r_1, r_2) bits, with r_2 the round after which the comparator runs within its clock: doubly exponential in i."
* **Problem.**
  * The sentence used to cite the polytime note. It now states a regret bound for an object that the paper neither defines nor proves anything about.
  * The credit is in footnote 6 (p. 36), which the reader of App. G will not connect to this sentence.
  * A pointer to the paper's own analogue makes the sentence self-contained.
* **Replacement** (same claim, with a pointer):
  > For comparison, consider the sequence analogue of \cref{prop:comp:round}: a time-bounded predictor for sequences that starts machine $i$ at the round $r_1$ with $\log\log r_1\ge i$ has regret $\max(r_1,r_2)$ bits, with $r_2$ the round after which the comparator runs within its clock: doubly exponential in $i$.

### F6. (e) "the mutual-information question" names a question that the body only half-poses

* **Location.**
  * Proposition D.9, title "Shannon form of the mutual-information question", p. 69, PDF l. 3921. Source: `app-hist.tex:134` (`prop:hist:shannon`).
  * The paragraph after Corollary 6.14, p. 24, PDF l. 1265–1266. Source: `hist.tex:110`: "The Shannon form of the mutual-information question holds".
* **Problem.**
  * In the earlier draft this was "the mutual-information question of the notes".
  * In the body, the only antecedent is a clause after Theorem 6.11, four paragraphs back: "One may ask for the statement with the algorithmic mutual information of ∆ and f in place of the complexity of ∆". That clause is not set off as a question.
  * The definite "the … question" therefore reads as pointing to an external source. Footnote 4 credits "the question behind Conjecture D.10", which confirms that reading.
* **Replacement.**
  * Title: `\begin{proposition}[Shannon form of the mutual-information bound]`.
  * `hist.tex:110`: "The Shannon form of this mutual-information variant holds: …" (rest unchanged).

### F7. (e) Proposition 8.7 is titled "The naive converse" right after the text calls it "a natural converse"

* **Location.** §8.4, p. 34, PDF l. 1791–1796. Source: `ood.tex:86–88` (`prop:ood:converse`).
* **Problem.**
  * The new motivating sentence says "Propositions 8.1 and F.2 suggest a natural converse". The title then calls the same statement "naive".
  * "Naive" grades a proposal, which was the notes' question, rather than describing the mathematics.
* **Replacement** (title only):
  > \begin{proposition}[The natural converse fails for complex targets]

### F8. (d, optional) §9 says that regret and circuit complexity "should be" polynomially related, with no reason

* **Location.** §9 opening, p. 35–36, PDF l. 1894–1902. Source: `comp.tex:15`.
* **Problem.** The expectation was the notes' claim. It is now asserted in the paper's voice, and nothing in the sentence says why one would expect it.
* **Replacement** (first two sentences):
  > SFI is not computable (\cref{prop:setting:computability}). Two computable relatives are natural: a time-bounded Solomonoff predictor with constant regret against all predictors of a given running time, and induction over Boolean circuits, for which, as log loss and complexity are for SFI (\cref{thm:setting:coding}), regret and circuit complexity should be polynomially related.\footnote{…unchanged…}

  (`thm:setting:coding` is Theorem 3.21, checked in `setting.tex:133`.)

## Optional (acceptable as it stands)

* **Footnote 4** (`hist.tex:16`, PDF l. 1084–1088) ends with "; the forms in which the statement holds are in Corollary 6.14".
  * This is neutral, and REFRAME §4 allows it, because a reader of the notes would otherwise take the informal statement to hold in general.
  * If the lead prefers pure credit, end the footnote at "… \citep{hanni2026notes}." Corollary 6.14 is named in the body two pages later anyway.
  * "The examples of Section 6.2 and Theorem 6.11" would read more clearly as "the examples of Section 6.2 and of Theorem 6.11".
* **Footnote 6** (`comp.tex:15`) is long, at 3½ lines.
  * Each item it lists (activation, clocking, amortised replay, the like-for-like caveat, the polytime extension) is a construction or argument that first appeared in the notes. So shortening it would drop credit.
  * I would keep it.
* **"The author's working notes" in footnotes 1–7** is REFRAME §4's model wording. No change is needed.

## Checked and found clean

* **Introduction.**
  * No "Relation to the author's notes" paragraph.
  * The contributions bullet for §6 reads "A direct simulation argument fails, and the stronger oracle form … is false".
* **Openings of §3 (`setting.tex:4`) and §4 (`versions.tex:4`).**
  * §3 gives the informal SFI definition in our own words.
  * §4 gives the Kolmogorov-versus-semimeasure question with its own motivation (the coding theorem for strings).
* **Remark 3.19 (Choice of definition) and the Discussion paragraph "Which version to call SFI".** Both say "formalises the informal definition"; neither quotes the notes.
* **§6.2–6.3.**
  * The examples are introduced in our voice.
  * The dominance statement is "one may hope that …".
  * Definition 6.6 gives "Three formulations" in the order A, B, C, followed by "Formulation C is the natural one for SFI".
  * Proposition 6.7 is "A direct simulation fails", with the natural proof stated first.
  * Theorem 6.11 is "The randomised chain; the oracle form fails".
  * Corollary 6.14 and its paragraph contain no "read as intended".
* **§6.4.** It opens with "Between SFI and SI lies a natural intermediate"; no conjecture is attributed.
* **§7.**
  * The cyclic permutation came from the author's brief, not from the notes, so no credit footnote is needed.
  * Eisenstat's example and Remark 7.18 use the allowed credits. That Remark 7.18 discusses a heuristic stated in the paper is ordinary exposition, as round 1 decided.
* **§8.**
  * The opening, §8.1 (properties simple given a fitted program), §8.2, and §8.4's motivating sentence are all in our voice.
  * Example 8.12(a), "easy-to-hard generalisation is limited in one precise sense", reads on its own.
* **§9.**
  * Corollary 9.5 is followed by "So one learner has constant regret …"; there is no "answers a remark".
  * Remark 9.9 is "A natural argument, which holds for weighted majority", in our voice.
  * Remark G.7 is "Regret and circuit size", with "A natural form of the relation".
* **§10.**
  * The paragraph after Proposition 10.2 has no "as the author's notes observe".
  * The Gaussian-limits question is posed as "one may ask".
  * Remark 10.8 replaces the slides' caveats with "The slides give proofs or proof sketches for several of these claims; we use only what is proved here."
* **§11.** The proposal is the companion paper's subject, with one credit footnote.
* **Related work and Novelty.** No citation of the notes. "Proposition 8.1 (in this form)" was kept by round-1 decision R-F13.
* **Appendices A–H.**
  * No citation of the notes and no "the author".
  * Remark C.9 calls positive-example induction "a natural relative of SFI".
  * Proposition F.3 is titled "Two natural two-sided bounds fail"; see F1 for its lead-in.
* **Acknowledgements.**
  * They keep "Working from the author's notes (Hänni, 2026c) and under the author's direction, …".
  * They add "Several of the questions and examples studied here first appeared in those notes."
  * They also give Eisenstat's "personal communication" and the Vaintrob credit.
