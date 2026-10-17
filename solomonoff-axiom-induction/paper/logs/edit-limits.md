# Edit log, group limits (limits.tex, related.tex)

Phase 1, 2026-10-17. Inputs: review/DECISIONS.md, review/issues-limits.json (13 issues: LIM-01 to LIM-10, LIM-X19, LIM-L1, LIM-L2).

Status: **PHASE 1 DONE.** All 13 issues are applied. List A and list B are applied in both sections. Both isolated builds compile with 0 errors, 0 undefined citations, 0 overfull boxes above 10pt and no multiply defined labels. Only `sections/limits.tex` and `sections/related.tex` were edited. No git command was run. (Restart note: the files as they were before this pass are saved in the scratchpad folder `limits-edit/` as `limits.orig.tex` and `related.orig.tex`.)

## Issues

* **LIM-01** (done; U1). `limits.tex`, `sec:limits:textbook`.
  * First occurrence: "In the model of \cref{sec:shape} this gap is a theorem, visible only when what is written, or the time to write it, is charged: ...". The sentence already opened with "In the model of §7", so only the grammar was adapted.
  * Second occurrence: "So insufficiency for a simple reasoner is a property of the pair (theory, reasoner) and of the vocabulary, in the model of \cref{sec:shape}, when what is written, or the time to write it, is charged".
  * No occurrence of "when what is written is what is charged" remains.
* **LIM-02** (done; U3, both sentences). `limits.tex`, `sec:limits:approx`. The first two sentences are U3 verbatim, with one adaptation.
  * "belongs to the open problem of \cref{sec:limits:stat}" became "belongs to the open problem stated above". After LIM-L1 that label is a paragraph of §11, so the `\cref` would print "Section 11" inside Section 11.
  * The clause on `prop:laws:strength` ("which rewards the false exact law over its true weakening") was cut. Its content is in §9 and App G. `\status` was updated to match.
* **LIM-03** (done; U6).
  * `limits.tex`, `sec:limits:other`, "The mathematics is free, and large". "so charging for it changes little in the universal setting" became "a constant that does not grow with the data but is not small for the mathematics physics uses, and that matters when rival theories need different mathematics".
  * Same paragraph: added the sentence "More generally, all our ... are relative to the universal machine, up to constants that are not small at the scale of real theories (\cref{prop:basic:invariance})". One copy-edit: "verdicts" became "comparisons of theories". "verdict" is on the rule-0.8 list, and the meaning (SAI's preferences between theories) is unchanged.
  * The clause "we expect it to matter much more under charged deduction" was cut for length.
  * `related.tex`, "Universal and operator induction": "nothing here depends on it" is replaced by the U6 text verbatim, as a new sentence after the Sterkenburg sentence: "Our theorems do not depend on it; our use of \SAIabbr as an ideal of the evaluation of theories does, and we take the universal prior as a modelling choice whose dependence on the machine and the language is bounded by constants that, at the scale of our examples, are not small (\cref{prop:basic:invariance,thm:basic:translation,sec:kepler:pool})".
* **LIM-04** (done). `limits.tex`, `sec:limits:domains`: "physicists rarely state or propagate worst-case bounds on the error of an approximate model (measurement uncertainties are propagated routinely, and statistically)", verbatim.
* **LIM-05** (done). `limits.tex`, `sec:limits:concepts`: "We accept them as features of human concepts, the first only comparatively (\cref{sec:phil:map}), with two further qualifications: inferential role is one major account of meaning (cf. Sellars), disputed by referential accounts (cf. Kripke); and natural types we find plausible."
  * The clause "supported for theoretical terms by the Ramsey--Lewis treatment" was cut for length.
  * The table row "inferential role constitutive" still names Ramsey--Lewis, and `lewis1970define` is cited in §12.
* **LIM-06** (done). `related.tex`, "Craig, Ramsey, Hempel": "in the universal mixture they cannot, beyond a constant factor, that is, by more than a bounded number of bits over all data (\cref{thm:terms:horn})", verbatim.
* **LIM-07** (done). `related.tex`, "Learning theories from data": "Shapiro's model inference infers theories from facts by conjectures and refutations \citep{shapiro1981algorithm,shapiro1991inductive}; it outputs one conjecture at a time, without a prior." The precedent claim is deleted.
* **LIM-08** (done, one word kept). `related.tex`, "Probabilities on sentences": "\citet{sawin2013computable} show that computable distributions that satisfy natural coherence conditions and come to believe the true $\Pi_1$ sentences must give some short true $\Pi_2$ sentences arbitrarily low limiting probability; ...".
  * The decided text drops the word "limiting" from the old sentence. I kept it, as light copy-editing that keeps an existing qualifier.
  * Reason: the reviewer's reading of the abstract (review/phil.md issue 20: "probabilities approaching arbitrarily low values") and the report's title ("converge on believing ... will disbelieve") both describe a limit.
  * If the lead editor wants the word gone, delete it; nothing else depends on it.
* **LIM-09** (done). `related.tex`, "Universal and operator induction": "... develop its one-tape universal law and its versions, and by \cref{sec:soi} \SAIabbr agrees, version by version and up to constants, with operator induction over consistent labellers of sentences, in which deduction ties the answers together." This is the decided text, joined to the preceding clause.
* **LIM-10** (done). `limits.tex`, `sec:limits:other`: "(heliocentric longitudes presuppose Copernican geometry; \cref{def:kepler:language}; \cref{sec:phil:map})".
* **LIM-X19** (done; U7).
  * `limits.tex`: the only mention is now "as in our earlier report \citep{claude2026axiominduction}".
  * `related.tex`, first mentions: "the companion paper \citep{claudeSFI2026fundamentals}", "the companion paper on steeper priors \citep{claudeSFI2026steeper}", "our earlier report \citep{claude2026axiominduction}".
  * `related.tex`, later mentions: "the template prior of the earlier report", "proved for deciders in the earlier report", without citation commands.
  * `claude2026axiomschemas` is not named in U7. It is cited once, as "a second report \citep{claude2026axiomschemas}", never with `\citet`.
  * No `\citet` of any of these works remains in either file.
* **LIM-L1** (done; see page counts). §11.
  * List A (1): the six subsections are now `\paragraph{...}\label{sec:limits:...}` with the same labels: `sec:limits:stat`, `sec:limits:textbook`, `sec:limits:approx`, `sec:limits:domains`, `sec:limits:concepts`, `sec:limits:other`.
    * Every citing sentence was checked and reads correctly with "Section 11": `intro.tex` l. 36; `discussion.tex` l. 10 and 23; `kepler.tex` l. 144; `laws.tex` l. 50; `phil.tex` l. 37 and 65; `shape.tex` l. 141; `app-verification.tex` l. 13.
    * The one exception was the U3 sentence in §11 itself, fixed under LIM-02. No request to another group is needed.
  * List A (2): paragraphs shortened. Sizes are bytes of source including `\status`/`\src`; §L3 targets are in brackets.
    * `sec:limits:textbook`: 2,138 -> about 1,660 [1,500].
    * `sec:limits:domains`: 1,861 -> 1,396 [1,200].
    * `sec:limits:other`: 2,429 -> about 2,170, of which about 2,000 print [1,800].
    * Analogy paragraph with `eq:limits:analogy`: about 1,060 -> about 630 [650]. The inequality, its label and its one-line proof are kept.
    * `sec:limits:approx`: 1,389 -> 1,249 [1,150].
    * Concepts paragraph: 911 -> 812 [750].
    * `sec:limits:stat` (not on the list): 1,200 -> 1,162.
  * Several paragraphs stay above their byte targets. They now carry the decided texts that were added (U1 twice, U3 in full, U6, PHIL-13). They also carry claims found nowhere else: the three gaps; "nor about what people carry in their heads"; Lanford's theorem; and the "partially addressable / genuine limit" verdicts that the section's first paragraph promises. The page target is met (see below).
  * What was cut:
    * Repetition of §6, §7, §9 and §10. The honest-form device is now one sentence with a pointer to `sec:laws:sound`, the strength of the exact law is gone, and the domain sentence points only to `rem:laws:domainlearning`.
    * The illustration from classical electrodynamics (`frisch2004inconsistency`).
    * The explicit $\Delta_0$-instances example of `prop:logic:oldevidence`, now one clause with the pointer.
    * "on Popper's definition no false theory is closer to the truth than another" and "the similarity approach needs a metric". The four citations are kept.
    * The Le Verrier pointer sentence. The table row "built from pointers" stays.
    * "in \cref{sec:kepler} the pool of forms is given" and the pointer to discovery systems in §12.
    * The examples engines, circuits and lenses.
    * "we agree", which in effect replied to the author's claim.
  * Table 7 (`tab:limits:concepts`): one cell reworded ("definitions cost $O(1)$ ..., help a chaining reasoner ...") so that the row fits on one line. No row was removed.
  * List B (applied, because §11 was still over 2.5): "What the axiom view captures" is cut to its first and last sentences. The "misses" sentence is folded into the first sentence as one clause ("and misses the procedural, the statistical and the dynamic side"), because `phil.tex` l. 37 and `discussion.tex` l. 10 cite §11 for exactly that claim.
* **LIM-L2** (done; see page counts). §12. Sizes are bytes; §L3 targets in brackets.
  * List A:
    * "Usable theories": 950 -> about 375 [450]. Citations merged; the learning-to-reason and DreamCoder pointer dropped.
    * "Probabilities on sentences": 2,280 -> about 2,060 [1,850], with PHIL-20. The clause "random axiom systems ... are not new here" was dropped, because "What is new" says it. The bib-report §3 wordings on the modified Demski prior are kept.
    * "Craig, Ramsey, Hempel": 1,460 -> about 1,340 [1,100]. The complexity-facts sentence is dropped. PHIL-15 adds about 80 bytes.
    * "Laws, approximation, explanation, and what a theory is": 1,510 -> about 1,070 [1,100]. The citation lists for explanation and for what a theory is are replaced by a pointer to §6, which cites all those keys, and to `sec:limits:approx` for truthlikeness. Discovery systems are now one sentence.
    * "What is new": 1,700 -> about 1,680 [1,350]. Not shortened further, because every item and every hedge is required (bib-report §4.1 and §4.3 wordings). The coin-free equivalence moved into the "Not new" sentence as a parenthesis (U7).
  * List B (applied): the cognitive-science sentence of "Learning theories from data" is cut to one clause.

## Moved labels

None. Neither §11 nor §12 has an appendix, and no theorem-like environment, table or figure was moved or removed. `eq:limits:analogy` and `tab:limits:concepts` stay in §11.

## Shortened labelled paragraphs

* All now `\paragraph`s that keep their labels: `sec:limits:stat`, `sec:limits:textbook`, `sec:limits:approx`, `sec:limits:domains`, `sec:limits:concepts` (with the analogy paragraph and `eq:limits:analogy`), `sec:limits:other`.
* Unlabelled: the closing paragraph "What the axiom view captures" (list B).

## Page counts

**Method.**
* Isolated builds (`./test-section.sh limits`, `./test-section.sh related`), measured from the section heading to the "References" heading with `pdftotext -bbox`.
* The same build was then rerun once with the `\newlabel`s of the last full build (`main.aux` of 15:17) added, so that cross-references print at their real length. An isolated build prints "??" instead.
* Calibration on the files as they were before this pass: for §11, isolated 3.27 and 3.35 with references resolved, against 3.36 in the full build. For §12, isolated 2.56 against 2.64 full.

| section | before (full build) | after, references resolved (estimate of the full build) | target (tolerance) |
|---|---|---|---|
| §11 `limits.tex` (with Table 7) | 3.36 | **2.65** | 2.50 (+0.25) |
| §12 `related.tex` | 2.64 | **2.35** | 2.25 (+0.25) |

* Both sections are within tolerance: §11 is 0.15 above target and §12 is 0.10 above.
* The remaining uncertainty is where each section starts on its page in the full build, and where Table 7 floats.
* Source sizes (comments included): `limits.tex` 16,367 -> 14,041 bytes; `related.tex` 13,202 -> 12,318 bytes.

**Final isolated builds.**
* `limits`: OK, 4 pages, 0 undefined citations, 38 undefined references (all to other sections), 0 overfull boxes above 10pt.
* `related`: OK, 8 pages, 0 undefined citations, 35 undefined references (all to other sections), 0 overfull boxes above 10pt.
* Every `\cref`/`\eqref` target in the two files (57 labels) is defined exactly once in `sections/`.

## Greps (rule 0.8)

* Scope: both files, outside `%` comments and `\status`/`\src` arguments.
* The only hit is "the revision of the base abstractions" (`sec:limits:other`), which is a legitimate use.
* "verdicts" (from U6) was reworded (LIM-03).
* No model names, and no process vocabulary or decision ids outside `\src`.
* Credit footnote F7 is kept on the sentence that introduces Table 7: "The list follows, with changes, an unpublished draft essay of H\"anni's on concepts."

## Citation keys no longer cited anywhere in the paper

* Cited in no section file after the cuts: `frisch2004inconsistency`, `godel1936lange`, `pudlak1998lengths` (the last two from the dropped complexity-facts sentence), `khardon1997learning`, `ellis2021dreamcoder`. They stay in `bib/` and simply no longer print.
* Dropped from §11/§12 but still cited elsewhere:
  * `bessiere2009circuit`, `gwynne2014sat`, `goos2019adventures` (§7).
  * `fischer1974super`, `cook1979relative`, `chandra1981alternation` (§4, §8, App B, App F).
  * `hacking1967slightly` (§5).
  * `hempel1948studies`, `kitcher1989explanatory`, `vanfraassen1980scientific`, `woodward2003making`, `suppe1977structure`, `suppes1960comparison`, `sneed1971logical`, `halvorson2012what` (§6).
* For the front group's record only; no action is needed.

## Requests to other groups

None required. Notes for the front group:
1. `discussion.tex` l. 10 and `phil.tex` l. 37 cite §11 for "misses the procedural, statistical and dynamic sides". §11 still says so in its closing paragraph.
2. `kepler.tex` l. 144 and `discussion.tex` l. 23 cite "the computational gap" of `sec:limits:textbook`. The paragraph still names it.
3. LIM-08 kept the word "limiting" (see above). The lead editor may delete it.

## Post-edit fix (2026-10-17, after the front editor's report)

* related.tex, the Craig/Hempel paragraph: "which \cref{sec:terms} sets against our results" became "the first two of which \cref{sec:terms} sets against our results", because §8 (rem:phil:hempel) now treats only the impracticality and inductive-systematisation replies, not the third (science does not aim only at prediction). Requested by the front editor (logs/edit-front.md).
* LIM-08 "limiting" in the Sawin–Demski sentence: kept. Their theorem is about the limit of the probabilities as true Π1 sentences are conditioned on, so the word is accurate.
