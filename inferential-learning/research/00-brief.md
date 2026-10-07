# Research brief: learning inference rules → principled reasoners

This is the shared brief for the investigation. Every agent in this project should read it first.

## The user's question (paraphrased faithfully)

Kaarel wants to understand the following setup and whether anything like it can be made to work, ideally provably. Compute is not a constraint, but it must actually work if run.

* A **learning process that learns inference rules**: it learns which inferences are valid, and so learns to make valid inferences.
  * Under an **inferentialist** picture of meaning (Sellars, Brandom, Dummett, Prawitz), this is roughly the same as learning the meanings of terms and propositions.
* It could start by **imitating human inferences**, taken from formal or informal mathematical proofs, or from physics olympiad solutions.
* An argument counts as valid when it is a sequence of valid inferences.
* The learner is then conditioned on **coherence** (some loss that pushes away from having good arguments for both P and not-P) or on **practical success**, for example occasional truth-value feedback from the real world.
* **Contexts** are a problem. One option is "eternalism", where each proposition is true or false independently of context. But we want to set up contexts and argue inside them (as in physics problems). Arguments for P and not-P in contradictory contexts are fine and should not be penalized. Many reasonable contexts are technically contradictory: a physics problem says "assume air pressure is 0", yet one can prove from background knowledge that it isn't.

Concrete goals, from the user's own goal note:
* Give an appropriate **learning algorithm for inference rules**, perhaps some form of learning from positive examples.
* See whether that algorithm plus some coherence mechanism gets **math** working well: first formal math, then informal math, then **physics**.

What would count as success, in increasing order of impressiveness:
1. A setup of this shape that **provably works for formal math**. This is already cool.
2. A setup that **would have worked for mathematical proofs before we knew how to formalize them**. Very cool.
3. A **principled system for solving physics olympiad problems, or for checking physics olympiad solutions**. Amazing.

The deeper motivation is the question of **what principled justification looks like beyond mathematical proof**. The user's notes are at `/home/user/kaarelh/notes` (a clone of github.com/kaarelh/notes). Relevant notes include:
* `philosophy/philosophy of language/meaning and truth/*`: compositional inference warranting; between verificationism and holism; what it is to accept an axiom or inference rule; the correct theory of semantics.
* `ai/verification and generation/*`, especially `verification of physics olympiad solutions/`.
  * The structure of physics olympiad solutions: "a dance with many clear setups"; "contradictions being provable from stuff"; the hypothesis that "there's a local setting up of a clear thing".
  * Math was formalized by inventing a language into which proofs can be translated, not by translating proofs word for word.
  * "Verification from truth": check whether each claim is true *in the context at hand*. "But wtf is that???"
* `ai/learning/solomonoff induction/solomonoff axiom induction.md`.
* `philosophy/metaphilosophy/a formal system for doing philosophy?.md`.
* `logic/a 'philosophical version' of gödel's completeness theorem.md`.
* `philosophy/philosophy of thinking/analogy/logical models as distinct from mental models.md`.
* `introspection/*physics olympiad*`.
* `ai/DLK/*` (discovering latent knowledge, i.e. consistency-based unsupervised probing).

## Working hypotheses from the orchestrator (to test, refine or refute, not to accept)

H1. **Worst-case soundness is required.** A reasoner is a search process over arguments that the learned validity relation V̂ accepts. Search is adversarial to V̂, so a single false-accepting rule (cf. Prior's *tonk*) can make everything derivable. Average-case, in-distribution accuracy on human steps (PAC or process-reward-model style) is therefore not enough. We need guarantees that hold uniformly over the steps a prover may choose. Candidate frameworks:
* reliable learning (Rivest–Sloan);
* KWIK, "knows what it knows" (Li–Littman–Walsh);
* perfect selective classification / the consistent selective strategy (El-Yaniv–Wiener);
* Bayesian-conservative acceptance (accept a step only if its posterior probability of invalidity is below δ), combined with Ville's inequality for time-uniform soundness against adaptive provers.

H2. **Learning from positive examples** (human steps) faces Gold's problem: positive data never rules out over-general hypotheses. Two remedies:
* Remedy 1: conservative or minimal learners (closure algorithm, version-space intersection, Plotkin least-general-generalization / anti-unification, Angluin tell-tales, finite elasticity of bounded unions of patterns and of length-bounded elementary formal systems (Wright, Shinohara)).
* Remedy 2: **coherence acts as negative data**. Deriving ⊥ from accepted premises shows that at least one step in the derivation is invalid. This is a "negative bag", a multiple-instance-style label.

H3. **Carnap's categoricity problem looks like a semantic twin of Gold's theorem.** Proof-theoretic rules alone do not fix the classical truth-functional meanings (non-normal valuations). The bilateralist fixes are Smiley/Rumfitt's assertion+denial and Restall's multiple-conclusion sequents read as "coherence constraints on positions". These are the semantic analogue of adding negative information. The user's "coherence loss" may be essentially Restall's reading of consequence: Γ ⊢ Δ means it is incoherent to assert all of Γ while denying all of Δ.

H4. **Post-completeness.** Classical propositional logic is Post-complete, so coherence pins the target down from above: the maximal coherent structural extension of the data is the truth. In arithmetic, incompleteness means coherence cannot do this. There are many incomparable coherent extensions, including ¬Con(PA). So a coherence-driven learner needs either minimality/conservativity (Belnap) or world feedback; in math, world feedback means computation, which can refute false Π₁ claims. Topologically, Kelly's "logic of reliable inquiry" characterizes what can be learned in the limit.

H5. **Informal math as latent formalization.** Human informal proofs are images of short derivations in an unknown calculus R* under an unknown reading map ρ*. Gap size is measured by something like the de Bruijn factor. Learning (R, ρ) by MDL subject to coverage and coherence is roughly what Frege, Hilbert and Zermelo did by hand.
* Naive comprehension is the MDL-simplest rule covering practice. Russell's paradox is coherence feedback that refutes it. Separation is the minimal repair.
* This mirrors Lakatos (monster-barring, lemma-incorporation).
* Kreisel's "informal rigour" and his squeezing argument are a model of how informal validity gets pinned to formal validity.

H6. **Contexts as chunks.** Judgments are context-indexed: Γ ⊢ φ.
* Deriving ⊥ inside a hypothetical context is legitimate (reductio).
* Coherence penalties apply to the *actual* context (background K plus observations) and to *exported* claims.
* Idealized contexts import only a selected fragment K_Γ ⊆ K, as in chunk-and-permeate (Brown & Priest), McCarthy's ist(c, p), and Mark Wilson's facades/patches.
* An **export (bridge) rule** turns "in idealized model M_Γ, Q = q" into the world claim "Q ≈ q ± ε". It needs a justification: a stability or sensitivity certificate, or validation by world feedback or by numerical simulation of a less idealized model (a refinement chain).
* So coherence trains the in-context rules, world feedback trains the export rules, and contexts separate the two. This could yield a principled checker for physics olympiad solutions:
  * chunks (each one internally formal math);
  * bridges (accepted idealization schemas with side conditions checked);
  * error propagation;
  * coherence checks such as dimensional analysis (a type system), limiting cases, symmetry and conservation laws.

H7. **Rule-following.** The non-identifiability left after coherence is exactly the set of coherent alternative calculi, i.e. alternative meanings: Kripkenstein's quus, Goodman's grue. Simplicity priors, coherence and community practice are three answers. The theory should say precisely which of the three does what work.

## Deliverable we are aiming at

A paper-quality write-up plus code:
* a precise setup and algorithm(s) for formal math, informal math and physics;
* theorems with complete, adversarially checked proofs, covering soundness against adversarial search, identification or sample complexity, the role of coherence, contexts and export, and impossibility results that delimit what can work;
* toy experiments demonstrating the key phenomena;
* an honest discussion of what is established and what is conjecture, and how this bears on "principled justification beyond proof".

Prefer depth and correctness over breadth. Cite real papers accurately: give author, year and title, and flag uncertain citations as uncertain. Never invent results.
