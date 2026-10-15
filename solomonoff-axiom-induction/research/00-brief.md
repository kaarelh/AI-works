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
