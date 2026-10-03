# Master plan: what we are claiming, and in what shape

Status: draft by the orchestrator. It is based on the literature memos L1–L11 and the theory threads T1–T4. Threads T5–T7 are still in progress.

## Thesis, in one paragraph

A learner of the user's shape works, and provably so. It learns which inferences are valid by imitating human inferences, and is then conditioned on coherence and on sparse feedback from the world. But it works only in a specific shape, and each ingredient does a precisely delimited job:

* **Imitation** (positive examples) identifies *rules*. It needs the right hypothesis class: schemas, learned by least generalization. It needs *cautious* acceptance, which is the only kind of soundness that survives search. Under those conditions it gives exact, out-of-distribution, systematic generalization. Finite usage fixes inferential role for unbounded use. It cannot tell systematic human errors from rules.
* **Coherence** (contradictions from contexts designated as consistent) removes exactly the errors that are incoherent with the target. It pins the target down exactly when the target is Post-complete:
  * classical propositional logic;
  * complete theories such as RCF, the algebraic core of physics calculations.

  It is blind for intuitionistic logic. In arithmetic it is Popperian: it detects Π₁ truths, not Σ₁ truths. Its residue is the set of coherent uniform alternatives, which is the Kripkenstein residue. Coherence informs only *bold* learners. So the architecture has two tiers: cautious assertion, and a bold sandbox attacked by a red team.
* **World feedback** of the right kind does work that neither imitation nor coherence can do:
  * counterexample *objects* (step-level blame by descent);
  * computation with fresh randomness (Schwartz–Zippel);
  * validated simulation.

  Objects are exponentially more informative than paradoxes (log versus linear). In physics, world feedback calibrates the top model. Context-internal rules must not be trained on outcomes.
* **Contexts** are filters of models from a declared deformation family:
  * suppositions are exact discharge;
  * idealizations are push-forwards along declared deformations, possibly inconsistent with the root;
  * truth in a context is truth in every admissible completion.

  Coherence applies to the root and to anchored contexts. The realizability criterion makes this exact. Eternalism is impossible. Exports need certificates of finite information radius ("no free export"). Context choice is an attack surface, which is fixed by restricting contexts to declared deformations with side conditions evaluated in the parent. A physics checker built this way is sound against adversarial solvers *relative to* a judgment layer, and that layer (reading plus top-model adequacy) is provably ineliminable.

Philosophically, the setup instantiates Goodman's mutual adjustment of rules and inferences. With an independent world channel, it is *vindicated wide reflective equilibrium*. The theorems are conditional reliabilist vindications, relative to explicit channel assumptions, together with matching impossibility results showing that each assumption is needed. This is what "principled justification beyond proof" can look like:
* proof within contexts;
* certified bridges between contexts;
* an explicit, minimized and ineliminable judgment layer;
* learning signals whose limits are known exactly.

## Answers to the user's explicit asks

1. **A learning algorithm for inference rules.** Use anti-unification (least general generalization) over rule schemas. A trimmed version space handles sporadic noise. Acceptance is cautious (version-space intersection, or Bayes-conservative with a Ville guarantee). Simplicity priors (MDL/MAP) are the *wrong* bias for positive data (T1 Prop 2.4).
2. **Does it get math working, given coherence?**
   * *Formal, propositional:* yes, exactly. Coherence plus structurality pins classical logic down (Post-completeness). There is an end-to-end two-tier theorem (T7).
   * *Formal, complete decidable theories* (RCF, Presburger): yes.
   * *Arithmetic:* partially. There is Popperian boldness, and sharp impossibility results beyond Σ₁/Π₁.
   * *Informal math:* a bounded-gap conservative verifier over latent formalizations. Results:
     * soundness against adaptive provers;
     * identification exactly up to informal-validity equivalence;
     * object counterexamples needed ≤ log₂|H|;
     * the Frege→Russell→Zermelo toy.
     
     The robust-core theorem explains why informal mathematics survived formalization. This is "what would have worked before formalization", with the hardest open problem made explicit: affordable soundness when the learner must invent language.
   * *Physics:* a Structured Physics Solution checker, with a relative soundness theorem and a worked EuPhO problem. A physics *solver* is deliberately not built. The user's notes say capability work is the risky part, so we lead with checking.
3. **Contexts.** Handled as above. The user's air-pressure worry is made precise in two ways:
   * designating "idealization + full background" as coherent forces a globally paraconsistent logic (T2 Prop 7.1);
   * reductio hygiene (T3 Thm 1.9).
4. **The user's own open questions:**
   * the steeper simplicity penalty (T5 and T4 §7): a rate threshold, the vertex conjecture is false in general, and the pathologies are listed;
   * the philosophical completeness theorem (T6);
   * "true in the context at hand: wtf is that?" (T3 Thm 5.5: supertruth over admissible completions);
   * "how come mathematicians ended up with such a nice notion of proof?" (T4 Prop 6.5 plus the robust core).

## Deliverables

* `paper/`: LaTeX paper, about 50–70 pages including appendices with full proofs. Planned sections:
  1. Introduction and summary of answers
  2. Setting: steps, rules, contexts, provers, three channels
  3. Soundness against search
  4. Imitation
  5. Coherence
  6. The two-tier learner (the end-to-end formal-math theorem)
  7. Simplicity and normativity from imitation
  8. Coherence and existence
  9. Informal mathematics
  10. Contexts, idealization and physics checking
  11. Experiments
  12. Justification beyond proof (philosophy), with a table of one-sided signals and residues
  13. Limits and open problems

  Appendices hold the proofs.
* `code/`: the `cil` package and experiments:
  * algebra rule learning with fallacies and guards;
  * propositional ND, Post-completeness and coherence;
  * an adversarial prover against a statistical verifier versus a cautious learned calculus;
  * a physics SPS mini-checker (from T3-checks);
  * an informal-math comprehension toy (from T4-checks);
  * a steeper-simplicity simulation.
* `lean/`: Lean 4 + Mathlib formalization of a core discrete subset. Candidates:
  * T1 Lemma 1.1, Thm 2.1, Thm 3.1;
  * T2 Thm 3.1/3.3, Thm 2.2, Thm 2.4, Thm 4.2/4.4;
  * T4 Thm 4.3/4.4;
  * T3 Thm 2.1.
* `research/`: memos, theory threads and verification logs, kept as the record.

## Verification policy

Every theorem in the paper must have passed adversarial verification: two or three independent refuters per group, a repair, and a re-verification of anything changed. Ideally the core discrete theorems are also checked in Lean. Anything not so checked is labelled in the paper as a sketch or conjecture.
