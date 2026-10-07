# Paper outline: section allocation and theorem sources

Working title: **What Follows from What: Learning Inference Rules from Imitation, Coherence, and the World**

Audience: mathematically and philosophically literate researchers (learning theory, logic, philosophy of language and science, AI safety/verification).

Tone and style:
- Precise and honest about scope. Mark each result as proved, sketch, computed or conjecture.
- "Trivial once set up" results should say so, and the setup should be presented as the contribution.
- Lead with checking and justification, not with building strong provers.

Sources:
- Theory files in `research/theory/`. They have verification logs appended; always use the REPAIRED statements, and check each file's "## Verification log" section.
- Verification reports in `research/verification/`.
- Literature memos in `research/lit/`.

Length target: main text about 45–60 pages, plus appendices with full proofs.

## Sections

### 1. Introduction (`sections/intro.tex`; orchestrator writes)
- The question.
- The answer in one page: a division-of-labour table showing what each channel fixes and what it cannot. Table columns: Imitation (P), Coherence (C), World (W), Contexts.
- The headline theorems.
- What is new versus known.
- Roadmap.

### 2. Setting (`sections/setting.tex`)
- Judgments, positions, steps, rule sets, closure.
- Schemas and anti-unification.
- Hypothesis classes.
- The three channels.
- The prover/verifier protocol and soundness notions: deterministic soundness; δ-soundness uniform over adaptive provers; depth-relative soundness.
- Contexts preview.

Sources: T1 §1, T2 §1, T7 §1.

### 3. Search makes soundness a worst-case property (`sections/search.tex`)
- T1 Lemma 1.1 (stepwise = reasoner soundness).
- T1 Thm 2.1 and Cor 2.2 (tonk beyond the horizon; PAC learners can be maximally unsound).
- T1 Prop 2.3 (in CPC every unsound *pure* schema trivializes — use the repaired scope).
- T1 Prop 2.4 (MDL picks "anything from anything").
- L3 Lemma A (commitment-order lemma: PAC semantics survives adversarial chaining iff the world is random and the rules are fixed first; fresh per-check randomness à la Schwartz–Zippel).
- T2 Thm 2.4 (doctrinal paradox for verifier ensembles).
- Pointer to experiment C (adversarial prover).

### 4. Cautious verification and its price (`sections/caution.tex`)
- T1 Thm 3.1, as repaired: VS verifier sound and optimal.
- T1 Thm 3.2 (escalation dimension = positive elasticity).
- T1 Thms 3.4, 3.6, 3.7, 3.9 (cost table: single schema, tagged, untagged, unstructured); Prop 3.5 (two-sided Bell); Conj 3.8.
- T1 Thms 4.1, 4.2, 4.4, Cor 4.5, 4.6 (Bayes-conservative with Ville; cite Waudby-Smith & Ramdas 2020 for the prior–posterior-ratio martingale).

### 5. Imitation: what positive examples fix (`sections/imitation.tex`)
- T1 Thm 5.1, Prop 5.2 (anchors).
- T1 Thm 5.3 (coupon collector), Thm 5.4 (untagged), Cor 5.5 (systematic out-of-distribution generalization: finite usage fixes inferential role).
- T1 Prop 6.1 (fragility).
- T1 Thms 6.2–6.4, Cor 6.5 (trimmed version space; indistinguishability; systematic errors are rules).
- Remark: dimension inference as an exactly solvable case of learning meaning from positive examples (L9 TC1; mark as sketch unless verified).
- Pointer to experiment A (algebra) and B (propositional).

### 6. Coherence: what contradictions fix (`sections/coherence.tex`)
- T2 Lemma 2.1, Prop 2.9 (caution receives no signal), Thm 2.2 (oligarchic halving), Thm 2.5.
- T2 Thm 2.6, Prop 2.7 / Cor 2.8 as repaired (silent over-generalizations; compactness).
- T2 Thm 3.1, Prop 3.2, Thm 3.3 (Post-completeness pins CPC), Props 3.4–3.5, Thm 3.6 (IPC: coherence is blind).
- Arithmetic: T2 Lemma 3.7, Thm 3.8, Thm 3.9, Thm 3.10; L3 Thm D (coherence/Π₁/Π₂ trilemma).
- T2 Prop 3.11 as repaired: complete theories, theorem level only.
- T2 Lemma 4.1, Thms 4.2–4.4, Prop 4.5 (Carnap's problem = Gold's problem in the dual space; bilateral tell-tale).
- T2 Props 5.1–5.3 (tonk; coherence is Π₁, conservativity is Π₂).
- T2 Thm 6.1, Cor 6.2, Thm 6.4 (fallacy elimination iff incoherent; Kripkensteinian residue).
- Remark (from L11): eliminative versus confirmational uses of coherence; the Bovens–Hartmann/Olsson impossibilities bite only the latter.

### 7. An end-to-end theorem for formal mathematics: the two-tier learner (`sections/twotier.tex`)
- T7 in full, as repaired:
  - Prop 2.2 (caution over practice asserts fallacies);
  - Lemma 2.3 (Reiter);
  - Prop 2.4 (dilemma);
  - Lemma 2.5 (descent);
  - Lemma 3.1, Prop 3.3;
  - Thm 4.1 (main);
  - lower bounds Props 5.1–5.4, Thms 5.5–5.7, Prop 5.8;
  - specializations: Cor 6.2 (CPC exact), Cor 6.5 (complete decidable theories), Thm 6.6 (arithmetic is Popperian).
- Experiment: TTL simulation, plus the propositional experiment (bold extension of IPC).

### 8. Simplicity and normativity from imitation (`sections/simplicity.tex`)
This section answers the user's steeper-simplicity conjecture.
- T5 setup; Thm 2.1 (no adaptation with private randomness); Prop 2.3; Thm 2.5 (kink: shared vs private randomness); Prop 2.6 (in-context universality).
- T5 Lemma 3.1 (hull), Thm 3.2/3.3 (rate threshold).
- T5 Thm 4.3 (c not identifiable from imitation data), Prop 4.4 (guard erosion), other pathologies.
- T4 Prop 7.3 (rate inversion counterexample).
- T5 Thm 5.2 (division of labour), Prop 5.3.
- Relation to structure functions (Vereshchagin–Vitányi) and to tempered posteriors (Grünwald).

### 9. Coherence and existence (`sections/existence.tex`)
This section answers the "philosophical completeness theorem" question.
- T6 Prop 1.3, Thms 1.4, 1.5, Prop 1.6.
- T6 Thms 2.2, 2.4, 2.6.
- T6 Thm 3.1, Thms 3.4, 3.5 (CCS-style constraints insufficient), Prop 3.6, Thms 3.7, 3.8, Cor 3.9.
- T6 Thm 4.1, 4.5, 4.6 / Prop 4.7 (contexts; belief states vs worlds; contextuality).
- T6 Thm 5.1, 5.2, 5.7 (computability barrier), Prop 5.8 (anchoring = Beth).

### 10. Informal mathematics: learning a latent formalization (`sections/informal.tex`)
- T4 model, Thm 2.4, Prop 2.3 (equivocation: check links), Thm 2.5, Thm 2.7 / Prop 2.8.
- T4 Lemma 3.3, Thm 3.4, Props 3.5–3.7.
- T4 Lemma 4.1, Thms 4.3–4.5, Prop 4.6.
- T4 Thm 5.1, Thm 5.2 (Frege → Russell → Zermelo toy), Prop 5.4; Incurvati–Murzi.
- T4 Thm 6.2, Thm 6.3 / Prop 6.4 (robust core; sorites), Prop 6.5 (emergence of a notion of proof).
- Historical grounding from L6: three channels, object counterexamples dominant, Lakatos, Zermelo's stated method, Manders/System E.

### 11. Contexts, idealization, and checking physics (`sections/physics.tex`)
- T3 §1:
  - filter semantics (Prop 1.4);
  - SUP as discharge (Prop 1.5);
  - import = deformation stability (Lemma 1.8);
  - reductio hygiene (Thm 1.9);
  - continuity asymmetry (Prop 1.10).
- T3 Thm 2.1 (eternalism is impossible), Thm 2.4 (realizability criterion), Thm 2.5 / Cor 2.6.
- T2 Prop 7.1 (mis-designation forces paraconsistency: the user's air-pressure worry).
- T3 §3: no free export (Thm 3.3), Prop 3.4, certificates (Thms 3.5–3.8), adversarial stipulation (Thm 3.9).
- T3 §4: coherence cannot calibrate tolerances (Thm 4.1); conformal failure (Thm 4.3); Lipschitz certifier (Thm 4.5); monotone certifier (Thm 4.6); Prop 4.7.
- T3 §5: SPS checker relative soundness (Thm 5.3); judgment layer ineliminable (Thm 5.4); supervaluational correctness (Thm 5.5); Gricean one-sidedness (Prop 5.6).
- T3 §6 worked EuPhO example.
- L9: structure of olympiad solutions; four logical roles of physicists' checks.

### 12. Experiments (`sections/experiments.tex`)
- A: algebra (rule learning, guards, fallacies, coherence-only alternative meaning 1/0 = 0).
- B: propositional ND (Post probes; bold IPC extension).
- C: adversarial prover against statistical versus learned-calculus verifiers.
- D: TTL simulation.
- E: physics mini-checker (accepts the honest solution, rejects six defective variants).
- F: T5 simulations.
- G: T4 comprehension toy.

All with commands for reproduction.

### 13. Justification beyond proof (`sections/philosophy.tex`)
- Goodman's mutual adjustment; narrow versus wide reflective equilibrium (L11).
- The theorems as conditional reliabilist vindications.
- The table of one-sided signals (rules, tolerances, readings).
- Residues and what fixes them: simplicity, community, convention.
- Carroll's tortoise: rules versus premises.
- Kripkenstein.
- Lakatos.
- Answers to the user's questions Q1–Q20 (from L10 §2.3), at least the main ones.
- What "principled" means here.

### 14. Limits and open problems (`sections/open.tex`)

### Appendices
- Full proofs for each of sections 3–11 (`sections/app-*.tex`).
- Lean formalization summary (`sections/app-lean.tex`).
- Reproduction.
