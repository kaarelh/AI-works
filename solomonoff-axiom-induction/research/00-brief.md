# Brief: a paper on Solomonoff axiom induction (2026-10-15)

## The author's request (verbatim)

> please now work on a paper on solomonoff axiom induction. things it should contain:
>
> * fundamentals
> * some discussion of the philosophical problems it is trying to make progress on
>    * one problem is clarifying the nature of a scientific theory. here can discuss how scientific theories answer questions stated in existing language. they explain propositions. could maybe discuss a toy example like kepler's laws here. can also discuss limitations of the axiom view; a central limitation: our written theories are not actually remotely sufficient for solving problems when hooked to some simple reasoner, they are more things that help humans solve problems. eg the written physical picture presented in say a mechanics textbook isn't logically sufficient to imply solutions to problems alone; it helps a human who has lots of understanding solve problems though. i discuss limitations of the view in a bunch of my notes. still, axiom induction is plausibly progress over some raw data prediction program view, both in that it gets the type of thing a theory does more right (answering questions >> raw pixel prediction), and also in that it gets the type of thing a theory is more right (a logical theory >> an arbitrary program). there are also other limitations; one thing off the top of my head is kepler's laws not really giving you correct predictions but giving approximately correct predictions. i have written a bunch about these sorts of things in https://github.com/kaarelh/notes . also see https://docs.google.com/document/d/1iq9Ld7jCnW2MklmELyVEH-zVDwUyj_Fh8Iu7-i4ueYo/edit?usp=sharing
> * the relation to SFI. the time-bounded equivalences you've worked out in this chat
> * anything else you think is cool enough to be in this paper
>    * please launch some new research threads trying to identify new cool stuff relating to axiom induction + trying to work out anything you've identified as maybe promising

**The Google Doc** could not be fetched from this environment; the author pasted its text, saved as `research/prior/hanni-condensation-concepts.md`. It is a draft essay criticising "condensation" as an account of what a concept is. Its relevance here:
* **Concepts and theories are for answering questions and solving problems,** not for generating predictions. Predictions, when made, are high-level, very specific, and graded by purpose-made metrics rather than information-theoretic loss. This supports the axiom view's shift from raw-data prediction to answering questions in an existing language.
* **Concepts are inert alone.** They are elements of a mind; Newtonian notions do nothing by themselves. This is the textbook-insufficiency limitation.
* **Inferential relations are constitutive of a concept** (continuity implies the intermediate value property). This supports the axiom view: a theory is a system of inferential relations among sentences, not a code snippet.
* **The essay lists properties of human concepts that a code-snippet view misses,** and an axiom view misses most of them too. A limitations section should engage with them:
  * recognizers (when a concept applies);
  * purposes;
  * compositionality;
  * support for learning;
  * softness and meaning change (the Earth as a sphere, then an oblate spheroid; "satellite");
  * analogy;
  * forming new concepts from old ones;
  * methods attached to concepts;
  * clarification;
  * natural types;
  * concepts built from pointers ("London is the capital of the UK");
  * one notion with different recognizers.

The slides it links ("models and concepts") were not available.

## Epistemic policy (binding; the author's instruction of 2026-10-15)

> btw, and i think this matters most for more philosophical stuff: when you're doing philosophy work in general, and even when working on this paper currently, despite my earlier prompt saying xyz philosophical things, i want you to only write things in the paper you actually believe, ie don't write stuff xyz which you do not believe even if i believe it. if you think i've made a philosophical error somewhere, don't make that error in your paper, and also please tell me you think i've probably made an error (and then maybe i'll just agree you're right or push back and we can discuss). like, try less to write a paper with my views, and more to write a paper on this topic that covers the relevant questions and gets at the truth even if it isn't what i think. […] (anyway i'm asking to make this our tentative policy; i'm not necessarily committing to this policy for all of time.)

What this means for every scout, thread, referee and editor:
* **The author's philosophical claims are hypotheses to assess, not positions to defend.** This covers the claims in the request above, in the notes and in the condensation essay. Examples:
  * theories answer questions stated in an existing language;
  * theories explain propositions;
  * the axiom view is progress over raw-data prediction, both in what a theory does and in what a theory is;
  * the limitations listed.

  For each claim, assess it on the merits, against the strongest objections and the literature, and against our own formal results.
* **Only claims we actually believe go into the paper.** Where we think a claim is false, overstated or confused, the paper says what we think is true instead, or leaves the claim out.
* **Our formal results bear on the philosophy.** For example, the Craig-trick collapse bears on the claim that axiom induction gets "what a theory is" more right than an arbitrary program does. Where a result undercuts a claim, say so plainly.
* **Raise a disagreement only when it has a decent probability of being right,** the kind of point one would actually bring up in a research discussion. Do not keep a running list or add a standing section for it, and do not invent disagreements.
* **When you do disagree,** add a short note to your record, labelled "Possible error in the author's view". It gives the claim and its source, why it is probably wrong or overstated, and what to write instead. The synthesis passes on the notes that survive review.

## "What a theory is": where the discussion stands (2026-10-15)

* **We raised an objection.** In the idealised, untimed setting, the Craig-trick collapse undercuts the claim that axiom induction gets "what a theory is" more right than program induction. Any consistent assigner becomes an axiom set at O(1) bits.
* **The author agrees,** and says Solomonoff axiom induction does not succeed for exactly this reason:
  > yea i don't think solomonoff axiom induction succeeds, for exactly this reason. so i kinda agree. but then i think that a theory still should be shaped more like a logical theory than a program, it's just that we don't have a good way of making this work out precisely yet
* **The paper's stance.** The paper should say this plainly:
  * the idealised formalism cannot see the difference in shape;
  * the intuition that theories are shaped like logical theories is nonetheless plausible;
  * what is missing is a formal setting in which the shape matters.
* **The author's follow-up:**
  > i think this is just true about human theories. we can say this is true by observation before we have some precise account of how this comes about

  So the paper separates two claims.
  * **The descriptive claim** is stated up front as an observation. Human theories, as written, are declarative: laws, definitions and principles, not procedures that print predictions. We agree. The caveat is the procedural parts of theory in use: methods attached to concepts, numerical schemes, simulation codes.
  * **The explanatory question** is open: why that shape is good, and whether an ideal inducer should produce it. Craig rules out an account based only on what can be represented, so an answer must be relative to a reasoner, or to a community of reasoners who communicate, check and extend theories piece by piece.
* **An open research question.** This is a candidate thread for the selection step, if a scout's material supports it: in what precise sense is a theory better shaped like a logical theory than like a program? Craig shows that the set of representable answer-functions is the same, so any difference must lie in what is cheap to obtain from each, relative to a reasoner. Candidate properties of logical theories:
  * **Multi-directional use.** A theory answers questions from any partial information. For example, Kepler's third law gives the period from the semi-major axis and the semi-major axis from the period. A program computes one direction cheaply.
  * **Partiality.** A theory is silent where it has nothing to say.
  * **Modularity.** Axioms have individual content and can be added, removed, tested and combined across domains.
  * **Closure under inference.**
* **A separation to look for.** Under a costed-deduction reasoner, find a family of query types where every hypothesis shaped like a program needs length growing with the number of query directions, while one axiomatised law plus cheap deduction answers them all.
* **What the separation would and would not show.** Such a result would make "theory shape" relative to a reasoner, which matches the condensation essay's point that concepts are inert alone. It would not show that logic, rather than, say, probabilistic programs with conditioning or classes of models (the semantic view), is the right formal home.

## "Existing language": where the discussion stands (2026-10-15)

* **We raised an objection.** "Theories answer questions stated in existing language" is too strong:
  * major theories introduce vocabulary (entropy, field, gene);
  * they revise existing concepts (simultaneity, mass);
  * they sometimes show that existing questions were ill-posed.
* **The author agrees, and clarifies that the claim was comparative:**
  > yeah totally agree with this. i only meant to say that it's more like answering questions in terms of existing abstractions than predicting pixels / some concrete/verificationism-style stuff. like that's a step in the right direction. but i agree really we need to go even more in that direction
* **The paper's stance: a ladder.** Each step moves further from verificationism.
  1. **Raw-data prediction.** Pixels, observation sequences.
  2. **Answering questions posed with existing abstractions.** This is axiom induction over a fixed language. The base language is whatever abstractions are already available, which may be highly theoretical. It is not an observational language in the logical empiricists' sense, so the classical objections to a theory-neutral observation language do not apply to it in the same way.
  3. **Theories that extend the language.** These are theoretical terms that pay for themselves by compression. The data stay in the base language. This step is formally reachable: succinctness of extensions, Ramsey sentences. It is a candidate thread.
  4. **Theories that revise the base abstractions.** This covers meaning change, and questions shown to be ill-posed. There is no formal handle yet. It is open.
* **Axiom induction sits on step 2, with partial results possible on step 3.** The paper presents step 2 as a step in the right direction, and says plainly that steps 3 and 4 are needed.

## Naming of the companion papers (2026-10-15)

The two companion papers are being renamed from "Solomonoff function induction (SFI)" to **Solomonoff operator induction (SOI)**. The binding rules are in `../solomonoff-function-induction/research/paper-review/rename/RENAME.md`.
* **Where the name comes from.** Solomonoff (2008) posed the operator-induction problem: predict the answer to a new question from an unordered set of question–answer pairs. He gave two universal-prior solutions. His per-query solution is the per-query mixture M_pq.
* **What "SOI" means without qualification:** the one-tape version M_F, one random tape shared by all questions.
* **Other versions:** the coin-free version W, the Kolmogorov version K_F, and the history-aware version SOI^hist.
* **In new records,** write SOI rather than SFI. Older records keep SFI.
* **This paper's working name stays "Solomonoff axiom induction"** (macro), in parallel with SOI.

## Target

An arXiv-quality paper with Kaarel Hänni as sole author. The AI assistance is disclosed as in the two SFI papers (`../solomonoff-function-induction/paper*/main.tex`: title-page footnote and acknowledgements). From the start it follows the rules the SFI papers reached after review:
* `../solomonoff-function-induction/research/paper-review/REFRAME.md`:
  * it is a first presentation of the material;
  * no running-text citations, quotations or "replies" to the author's notes;
  * credit goes in short neutral footnotes and the acknowledgements;
  * the voice is "we".
* `../solomonoff-function-induction/research/paper-review/DECISIONS.md`: arXiv form, statuses in prose, computed numbers outside statements, verified references only.

The working name is "Solomonoff axiom induction". The final name is still to be decided by the author, so the LaTeX will use a macro.

## Sources

* **The author's notes**, copied into `research/prior/`. The whole notes repository is readable at `/home/user/kaarelh/notes`, especially:
  * `philosophy/philosophy of science/`;
  * `philosophy/prediction/`;
  * `ai/learning/solomonoff induction/`;
  * `philosophy/concepting/`.

  Key positions:
  * a theory is a logical theory (a way of talking: kinds of things, questions one can ask about them, relations between the answers), not a program that prints observations;
  * science predicts only very particular things;
  * written theories are far from sufficient without tacit understanding ("our science is very human software");
  * approximate models have domains of applicability;
  * the note on Solomonoff axiom induction: proof-requiring and consistency-requiring variants; the true/false/independent trichotomy; the conjectured equivalence with consistent SFI, whose proof uses an axiom schema of the form "T(⌜φ⌝)=accept → φ".
* **The earlier report on axiom induction (Claude-authored, in this repository): `../axiom-induction/`.**
  * The paper is `../axiom-induction/paper/main.pdf`; its sources are in `paper/sections/`.
  * Its refereed research records are `../axiom-induction/research/tracks/{model,universal,pa,experiments,time-followup,short-derivations}/notes-final.md`.
  * They contain:
    * a Bayesian axiom inducer with template priors and derivation likelihoods;
    * ∀xφ from instances (the Bayesian ω-gap);
    * PA and equivalent axiomatisations;
    * experiments;
    * §6, the relation to function induction: the Craig-trick equivalence of proof-requiring axiom induction with consistent function induction (Thm 6.3), the one-sided equivalence under time penalties on checking or generating axioms (Thm 6.14), the diagonal separation with free deduction (Thm 6.15), and charging deduction (short certificates: NP ∩ coNP, EXPTIME, no limit).
  * Reuse is allowed, but results must be re-verified and restated in this paper's own notation and voice.
* **The axiom-schemas report:** `../axiom-schemas/`. It covers templates, the anchor theorem, the cautious verifier, and ZF/PA schemas.
* **The SFI papers:**
  * Paper 1, `../solomonoff-function-induction/paper/`: the one-tape universal machine M_F; the coin-free version W; K_F; no coding theorem; time-bounded and circuit SFI (§9).
  * Paper 2, `../solomonoff-function-induction/paper-steeper/`: steeper priors; the kink geometry; the model–randomness split; imitation.
  * Notation: `../solomonoff-function-induction/paper/NOTATION.md`.

## What the paper should contain

1. **Fundamentals.** Precise definitions of the family:
   * the proof-requiring variant (data: sentences labelled true or false; hypotheses: programs deciding or enumerating axiom sets; compatibility: the axioms prove each true datum and refute each false one);
   * the consistency-requiring variant;
   * the derivation-likelihood or generative variant;
   * the semimeasure convention, and the trichotomy true / false / independent.

   Basic theorems: dominance or universality within the relevant class, invariance, posterior behaviour (merging, convergence and its limits), and the Kolmogorov-versus-semimeasure question for axioms.
2. **Philosophy:**
   * the nature of a scientific theory: answering questions posed in an existing language; explaining propositions; a Kepler toy example;
   * progress over raw data prediction, in both what a theory does and what a theory is;
   * the limitations: written theories are not sufficient for a simple reasoner; Kepler's laws are only approximately correct; and others from the notes.
3. **Relation to SFI,** including the time-bounded equivalences and separations.
4. **New results** from the research threads below.

## Seed ideas for new research threads (the scouts should add their own)

* **Craig's theorem and the theoretician's dilemma.**
  * The collapse of axiom induction into consistent function induction is Craig's trick.
  * In philosophy of science, Craig's theorem was used to argue that theoretical terms are dispensable (Hempel's theoretician's dilemma), with the classical reply that Craigian axiomatisations are useless in practice.
  * The time-bounded separations make that reply a theorem.
* **Theoretical terms and succinctness.** Can a simplicity prior over theories in an extended language, with data only in the observational language, provably prefer theories with theoretical terms because they compress? Look for succinctness results for definitional or conservative extensions and Ramsey sentences.
* **Approximate theories (Kepler versus Newton).**
  * Data are approximate propositions, intervals or tolerances.
  * Find a precision-dependent selection theorem: the simpler approximate theory is preferred until the data's precision exceeds its error, and the more exact theory after that.
  * Also: a domain of applicability.
* **Theories for bounded reasoners (the textbook point).**
  * With a derivation-length or time budget, the induced theory must contain lemmas or know-how, not only the "physical picture".
  * Quantify the trade-off between the compression of axioms and their usability.
  * Relate this to the earlier report's short-derivations results.
* **Laws versus initial conditions.**
  * Paper 2's model–randomness split, transferred to theories.
  * A steeper prior separates laws, reused across many data, from contingent facts (initial or boundary conditions, exceptions) through a kink in (axiom length, fit).
  * Kepler's laws plus orbital elements is the example.
* **Randomised axiom systems.**
  * Axiom systems enumerated from a random tape, giving a one-tape version.
  * Ask whether this matches M_F restricted to consistent random labellers, and whether the Kolmogorov / semimeasure gaps of Paper 1 recur for axioms.
* **Learning theories in the limit.** Formal learning theory of first-order theories (Martin and Osherson's *Elements of Scientific Inquiry*, Gold, Putnam, Kelly). What the posterior does on data from complete theories such as Th(N), or from a structure.
* **Related probabilistic approaches.** Demski's logical prior, Hutter, Lloyd, Ng and Uther's probabilities on sentences, Garrabrant et al.'s logical induction, and Gaifman. Compare precisely.
* **Explanation.**
  * Explanation as derivation from axioms (deductive-nomological), and unification (Friedman, Kitcher).
  * An explanatory-power measure: bits of data explained per bit of axiom, the kink slope.
  * The question-answering view as opposed to prediction.

## Conventions (as for the earlier tracks)

* Mark every claim:
  * proved, with a full proof in the notes;
  * computed, with the script and its output;
  * conjecture;
  * known, with an exact verified reference;
  * proof sketch.
* Keep refuted claims, marked refuted, with their counterexamples.
* Code is seeded and its outputs are saved.
* Each track ends with a Verification log.
* Prose is plain and precise.
* Do not run git commands that change repository state.
* Write only in your own folder.
