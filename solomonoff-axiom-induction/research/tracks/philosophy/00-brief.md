# Thread brief: philosophy (kind: phil)

**Title.** What a theory does and what it is: the argument map, the worked Kepler example, and the limitations of the axiom view.

**Read first.** `../../00-brief.md` in full; its **epistemic policy** is binding here above all: the author's philosophical claims are hypotheses to assess; only claims we believe go into the paper; a disagreement is raised only when it has a decent probability of being right, as a short note labelled "Possible error in the author's view" (claim and source, why it is probably wrong or overstated, what to write instead). Read also the sections "What a theory is" and "Existing language", which record where the discussion with the author stands. Then `../../NOTATION-draft.md`, `../../select.md`, and scout P's record `../../scouts/philosophy/notes.md` (all of it) with its `refs.bib` and `checks/`. Also scout N2 §1 (C11–C19), §5 and §7; scout L §3.9 and §7; scout N1 N9; the notes in `../../prior/` (all, including `hanni-condensation-concepts.md`) and, as needed, `/home/user/kaarelh/notes` (`philosophy/philosophy of science/`, `philosophy/prediction/`, `philosophy/concepting/`).

**Deliverables.** `tracks/philosophy/notes.md` and `tracks/philosophy/refs.bib` (only entries verified in this thread or already verified by a scout, each with a comment saying how), scripts in `tracks/philosophy/checks/`, ending with a Verification log.

---

## Goal

Write the research material for the paper's philosophical sections: what problems the axiom view is trying to make progress on, what it gets right and wrong, with the formal results of the other threads attached to each claim, a worked example that makes the claims concrete, and an honest limitations analysis. The record should say, for every claim, whether it is an argument (marked **[assessment]**) or a theorem (with its status and the thread or scout item that proves it).

The brief already fixes three stances; develop them, do not reopen them without a strong reason:
1. **"What a theory is."** The idealised formalism cannot see the difference in shape (Craig); the descriptive claim (human theories, as written, are declarative) is stated up front as an observation, with the caveat of the procedural parts of theory in use; the explanatory question (why that shape is good, and whether an ideal inducer should produce it) is open, and any answer must be relative to a reasoner or a community of reasoners.
2. **"Existing language": the ladder.** Raw data; questions posed with existing abstractions (SAI over a fixed language); theories that extend the language; theories that revise the base abstractions. SAI sits on step 2, with partial results on step 3.
3. **Progress over raw-data prediction** is presented as a list of concrete formal differences, not as a general claim.

## Targets

**T1 (core) The problems and the argument map.** Problems P1 (what a theory does) and P2 (what a theory is), with the candidate answers and their literature (scout P §1.1). Claims D (answers questions), S (is a logical theory), E (explains propositions), L (the ladder), P (progress). For each: statement, source, arguments for, strongest objections, verdict, and the formal results that bear on it, cited by thread and target. In particular:
* D's formal content is the change of data type plus logical coherence (SAI ≡ consistent SOI on sentences: `sfi` T2, T3, T6), with partiality and multi-directional use as the features that make it matter;
* S: the descriptive/explanatory split; the shape result of `shape` (separations are between reasoners and between vocabularies; logical shape buys multi-directional use only up to a constant factor once intermediate concepts are allowed) and Khardon–Roth (question-answering competence without an explicit theory); the semantic view (Halvorson 2012, Lutz 2017); inconsistent theories in use;
* L: step 3's formal content from `terms` (vocabulary costs $O(1)$ in the universal class; finite theories need theoretical functions, relations or entities; unary predicates do not help) and from `shape` (intermediate concepts pay for usability); step 4 has no formal handle;
* the list "what formally separates SAI from raw-data prediction" (scout P §1.7), each item with its pointer.

**T2 (core) What a theory does: questions against raw data.** The erotetic definition of a question (scout P §1.2; Belnap–Steel, Hintikka; verify); scout N2's Prop 5.1 (conservation-law world: the law saves $\tfrac12\log(\pi m/2)$ bits per step of raw-data loss, a vanishing share, and all of the question-answering loss; a Bayes mixture learns the law at 1 bit) and Prop 5.2 (certification needs $2^m$ black-box queries; universal laws of programs are $\Pi_1$-complete): re-prove, re-run independently, and make the reading exact. Scout N1's N9 (answering implies predicting; predicting a stream does not imply that any theory answers it, via `logic`'s lottery; predicting a text does not converge to answers on unasked questions; closure of $\Bel$ under conjunction). Scout N2 §5.3 (question answering never needs more description than raw modelling plus the extractor) as a proof sketch or proof.

**T3 (core) Explanation.** D-N and unification (Hempel–Oppenheim, Friedman, Kitcher); the explanatory-power measure is defined and studied in `laws` T5, cite it; scout P's E1–E3:
* asymmetry: make scout N2's C13 a precise proposition (the flagpole theories $T_H$, $T_S$ prove the same data and their lengths differ by $O(1)$, so their posterior odds never move; derivation-length charges break the tie only relative to a choice of primitives; interventional questions break it) and prove it;
* explanation by approximate correction: Newton derives the honest Kepler law, not the exact one (Duhem, Schaffner); the formal toy is `laws` T7, cite it;
* unification without better prediction: Copernicus and the retrograde coincidences (Kuhn 1957; verify), as an instance of `laws`' explanatory power.
Verdict to develop: "a theory entails answers; derivation from a short theory is explanation in the unification sense, with two known gaps".

**T4 (core) The worked Kepler example.** Scout P §2, checked and completed:
* the two-sorted language, K12, K3, the elements, interval data and questions; scout P's Props 2.1 (the Ramsey sentence of the laws answers no position question) and 2.2 (K3 has no content in a heliocentric direction-only language). **Add** the geocentric counterpart: in a geocentric direction language K3 does have content; give an explicit $\mathcal L_{\rm obs}$-sentence that K12 + K3 proves and K12 does not, with proof;
* re-run scout P's `c1`–`c3` (pyerfa may need installing in a scratch library folder outside the repository, as scout P did) and check Tables 2.1–2.3 and the $q$ constants (`laws` T3 computes its own residual series for the peakedness criterion; the two threads run in parallel, so neither waits for the other, but check at revision time that the two records quote consistent residuals);
* **new computation:** the proof-requiring posterior over the historical pool for Mars 1580–1600 (circle, eccentric, bisected equant, vicarious hypothesis, ellipse; with and without K3) at each data precision $\delta$, under a fixed, written-down syntax for the law texts so that $|T|$ is defined. Report how the posterior moves as precision improves, and how much of the ordering is decided by the syntax (the language-relativity of simplicity);
* what Newton adds (unification, corrections inside the old domain, new questions, new domains, no deductive entailment of Kepler), with the computed figures;
* the selection theorems about approximate laws (scout P's Prop 2.3, precision regimes, honest laws against laws with exceptions) are `laws` T2–T3: cite and use them, do not re-prove them.

**T5 (core) Limitations.** Scout P §3 (L1–L12), each with source, sharp statement and formal status (partially addressable / genuine limit), checked against the other threads' results:
* the textbook point split into the bridge gap, the computational gap and the tacit gap; the computational gap is `shape`'s theorem (the explicit theory a weak deterministic reasoner needs can be exponentially longer than the core), and say exactly what that theorem does and does not show about textbooks;
* approximate truth and domains (`laws`); statistical theories; theory-laden and fallible data; purposes, technology and the making of phenomena; science as a social structure; free mathematics;
* the condensation essay's list (recognizers; purposes; compositionality; support for learning; softness and meaning change; analogy; new concepts from old; methods attached to concepts; clarification; natural types; concepts built from pointers; one notion with different recognizers), item by item, with the verdict that the axiom view models the declarative, inferential core of theories and misses their procedural and dynamic sides. Engage the essay's points as claims to assess, not as positions to defend.

**T6 (core) Possible errors in the author's view.** Assess, on the merits, the candidates the scouts raised, and decide which survive (write each survivor in the required format; drop the others with a one-line reason in the Verification log):
* scout P §1.8: "there is really nothing fundamentally right about these information-theoretic losses" (condensation essay); the proposed correction separates grading a prediction for use from updating beliefs about theories;
* scout N2 §7: "i don't think any nice formal criterion is going to be right" (domain-of-applicability note); the proposed correction: a sound criterion exists (tolerances, propagated; `laws` T4), what it lacks is fidelity to practice.
Look also, briefly, for any other claim in the request or the notes on which we would likely disagree; the policy forbids inventing disagreements. Scout S's correction of the brief's seed ("the time-bounded separations make that reply a theorem") is not the author's claim; record the corrected statement (from `terms` T7) as a correction of the seed, not as a possible error of the author.

**T7 (core) Literature.** Verify by WebSearch every reference the philosophical sections will cite (start from scout P's `refs.bib`, 75 entries, and scout L's formal-neighbour entries used here: Khardon–Roth, Kowalski, Winograd, McCarthy, Evans et al., Langley et al.). For content claims, record whether the content was checked against the source, an abstract, or secondary sources only, and hedge in the text accordingly. Priority: Hempel 1958, Craig 1956, Putnam 1965 and 1962, Ramsey 1931, Lewis 1970/1983/1994, Cohen–Callender 2009, Carnap 1950/1952/1956, van Fraassen 1980, Suppes 1960, Suppe 1977, Halvorson 2012, Lutz 2017, Sneed 1971, Balzer–Moulines–Sneed 1987, Friedman 1974, Kitcher 1981/1989, Bromberger 1966, Woodward 2003, Duhem, Schaffner 1967, Cartwright 1983/1999, Morgan–Morrison 1999, Polanyi, Kuhn 1957/1970/1977, Laudan 1977, Hacking 1983, Belnap–Steel 1976, Wilson 2006, Lakatos 1976, Kripke 1980, Gentner 1983, Hesse 1963, Sterkenburg 2016/2019.

## What to verify computationally

* Re-run scout P's `c1`–`c3` (scratch copies), compare outputs, and save any new outputs in your `checks/`.
* The new posterior over the historical Mars pool (T4), with the law-text syntax written out in the script.
* Scout N2's conservation-law computation (T2), re-implemented independently (`../../scouts/novel-science/checks/n4_raw_vs_questions.py` is the reference to compare against).
* The flagpole tie (T3) on a small explicit pool, if a computation helps.

## What this thread must NOT do

* Not prove the formal theorems owned by other threads; cite them by thread and target: `sfi` (equivalences), `terms` (Craig, Ramsey, Hempel, vocabulary or ontology), `logic` (lottery, Gödel phenomena), `shape` (reasoner-relative theory size, directionality), `laws` (approximate laws, best system, explanatory power, explanation by correction), `fundamentals` (definitions, trichotomy, limits). Where a citation is needed before the other thread has finished, cite the scout item and say so.
* Not write paper prose; this is research material in your own words.
* Not keep a running list of disagreements with the author, and not add a standing section for them.
