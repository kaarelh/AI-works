# L7 — Contexts, idealization, and reasoning with inconsistent or false assumptions

*Literature memo for the inferential-learning project. Strand L7. Written against the shared brief (`00-brief.md`), in particular H6 (contexts as chunks, export/bridge rules).*

**Verification policy.** Live web search was used to check bibliographic data and abstract-level claims. Fetching full texts was not possible: the proxy blocked every full-text host. Items marked **[unverified]** could not be checked in this session. For the classics (AGM, Lewis, Priest's LP, etc.) these are high-confidence memory, but they are flagged anyway. Where I describe a paper's internal technical content beyond its abstract, I say so.

---

## 0. Bottom line

1. **The user's "contexts" problem has a clean solution, and its pieces exist in the literature.** No single existing formalism covers all three requirements: (a) reductio-contradictions are fine, (b) idealized contexts may contradict background knowledge, and (c) only exported world-claims face coherence. The closest combination has three parts:
   * **McCarthy's `ist(c, p)`** gives meta-level eternalism. "In context c, p" is itself a context-free proposition, so contradictory contexts never conflict.
   * **Multi-context systems / Local Models Semantics** (Giunchiglia, Ghidini, Serafini; Brewka–Eiter) supply *locality + compatibility via bridge rules*, and a worked-out theory of *diagnosing inconsistency by blaming bridge rules* (Eiter et al. 2014).
   * **Brown–Priest chunk-and-permeate (C&P)** handles reasoning in internally consistent chunks that are jointly inconsistent, with a *permeability* relation controlling what crosses between chunks.

   I give a combined "context-tree" calculus in §8. It comes with a soundness and blame-localization lemma that makes "reductio immunity" precise.
2. **There are three different kinds of hypothetical context, with three different import regimes.** The brief (H6) conflates them.
   * Indicative supposition imports everything. Reductio lives here.
   * Counterfactual supposition imports a maximal compatible part of what is believed, ordered by entrenchment or similarity. This is AGM revision or Lewis–Stalnaker.
   * Idealization or model stipulation imports a designated minimal fragment. This is C&P, Cyc microtheories, Cartwright's models.

   Physics idealizations are *not* counterfactuals. "If air pressure were 0, the water in the beaker would boil" is a true counterfactual and irrelevant to the problem.
3. **Export is the crux, and it is never free.** A simple underdetermination argument (§9, "no-free-export") shows something about any rule whose premises concern only the idealized model, even including all of its derivatives in the idealization parameter: it cannot soundly export a world-claim with any finite tolerance. Justification needs information about the *family* of de-idealized models (McMullin's de-idealization, Laymon's monotonicity/continuity, perturbation remainder bounds, Gronwall-type bounds), or a *symmetry* that makes the idealized parameter irrelevant, or world/simulation data. Laymon (1987) already modelled this domain-theoretically with Scott domains: "monotonic" theories give better predictions when fed better data. This matches computable analysis and interval arithmetic exactly.
4. **Coherence is one-sided for export rules.** Widening an export tolerance never creates incoherence. So a coherence-only objective drives bridge tolerances to ∞ (trivial bridges). This is the export-level twin of Gold's over-generalization problem in H2. Multi-model agreement (Levins/Weisberg robustness) gives *lower* bounds on tolerances and catches some unsound bridges. It is blind to *common-mode* error (Odenbaugh–Alexandrova's objection). Sparse world feedback is needed, and conformal calibration of bridge tolerances is a natural principled tool for it.
5. **For physics olympiads, the graded "world" is the problem's intended model c_P, not the actual world.** Most exports in a solution go from solver-introduced sub-idealizations into c_P. They are asymptotic claims such as "to leading order in a/R", which are *mathematical* and formalizable. The irreducibly informal part is the *reading* map from problem text to the class of admissible intended models. I propose a supervaluational/robustness criterion for it: an answer is correct iff it holds, to the required precision, in every admissible completion. This bears directly on the user's "verification from truth… but wtf is that?" question.
6. **Design correction to the brief.** Under H6 the actual context @ contains background K. If K contains fundamental laws as unrestricted universals, @ may itself be inconsistent: physics is a "facade" (Wilson), and classical electrodynamics of point charges is arguably inconsistent (Frisch 2004, disputed). Then coherence penalties fire spuriously. Laws should live in model contexts (Cartwright), and @ should be *phenomenological*: interval-valued claims about measurable quantities plus observations plus exports.

---

## 1. The problem, sharpened

The user wants to argue "in contexts" (physics problems, hypotheticals) without being penalized for having good arguments for P in one context and ¬P in another. They also observe that many reasonable contexts are *technically* inconsistent with background knowledge ("assume air pressure is 0", yet one can prove it isn't).

Four phenomena are at stake. The literature treats them separately.

| Phenomenon | Example | What happens to ⊥ inside | What gets exported |
|---|---|---|---|
| Indicative supposition / reductio | "Suppose √2 = p/q…" | ⊥ is the goal | ¬A, or A → B (discharge) |
| Counterfactual supposition | "If the atmosphere vanished, the beaker would boil" | ⊥ means the revision was done badly | the counterfactual A □→ B |
| Idealization / model stipulation | "Neglect air resistance", "p_atm = 0", "frictionless" | ⊥ means the model is ill-posed | answers to queries, via a *bridge* with tolerance and regime |
| Patch / facade structure of a theory | rigid-body vs elastic vs continuum treatment of the same bar | joint union may be inconsistent; each patch consistent | conclusions valid in the patch's domain |

The brief's H6 is right in spirit. It needs (i) the separation of the first three regimes, (ii) a statement of what exactly is penalized where, and (iii) a theory of what justifies the bridge.

---

## 2. Formal theories of context (AI/KR)

**McCarthy (1993), "Notes on formalizing context", IJCAI-93, pp. 555–560.**
* The basic relation is `ist(c, p)`: proposition p is true in context c. Contexts are first-class objects in an outer context.
* The most important axioms are **lifting axioms**, which relate truth in one context to truth in another. One "enters" a context to reason inside it and "exits" with `ist`-claims.
* The motivating goal is *transcendence*: axioms written for a limited context (a static blocks world) can be lifted into a more general one.
* An expanded version is McCarthy & Buvač, "Formalizing context (expanded notes)", 1998 [venue: CSLI volume *Computing Natural Language*, unverified].

*Use for us:* `ist` gives **meta-level eternalism**. Read `ist(c, φ)` as the context-free proposition "the finitely specified context c (stipulations, import filter, rule set) yields φ". Then the user's eternalism worry dissolves: `ist(c₁, P)` and `ist(c₂, ¬P)` are not contradictory. Coherence can be enforced globally *on `ist`-claims* and *on root-context claims*, and nowhere else. Lifting axioms are our bridge rules.

**Guha (1991), *Contexts: A Formalization and Some Applications*, PhD thesis, Stanford (tech report STAN-CS-91-1399).** Guha put contexts into Cyc as **microtheories**, each making simplifying assumptions, linked by lifting rules. A key Cyc design principle is that each microtheory must be free of monotonic contradictions, *while the knowledge base as a whole need not be* (secondary sources, e.g. the Cyc Wikipedia article; Lenat & Guha 1990 *Building Large Knowledge-Based Systems* [unverified detail]). This is the engineering ancestor of "local consistency, global tolerance". The project took it to scale, but it gives no theory of *when* a lifting is justified.

**Buvač & Mason (1993), "Propositional logic of context", AAAI-93, pp. 412–419.**
* `ist(κ, φ)` is treated as a modality.
* The paper gives a Hilbert-style system and proves soundness and completeness for it and for various extensions, and proves decidability.
* My recollection, not re-verified: the semantics lets contexts have different vocabularies (propositions can be meaningless in a context) and supports nested context sequences.

Massacci (1996, AAAI-96, pp. 621–626) showed satisfiability for PLC is **NP-complete**, cheaper than the PSPACE-complete multimodal and hierarchical alternatives.
*Use:* checking a given context structure is cheap. Finding the right one is the hard part (cf. Nayak below).

**Giunchiglia & Serafini (1994), "Multilanguage hierarchical logics", AIJ 65:29–70 [unverified]; Ghidini & Giunchiglia (2001), "Local models semantics, or contextual reasoning = locality + compatibility", AIJ 127(2):221–259.**
* Each context has its own language and its own class of *local models*.
* A model of the whole system is a set of local-model-sets satisfying a **compatibility** relation.
* Proof-theoretically, these are **multi-context systems (MCS)**: local inference rules plus **bridge rules** whose premises are in one context and conclusion in another.

Serafini & Bouquet (2004, AIJ 155:41–67) proved that PLC embeds into a class of MCS (MPLC), but MCS/LMS cannot be embedded into PLC using only lifting axioms. So **MCS/LMS is the more general framework, and the natural semantic home for our proposal** (§8).

**Brewka & Eiter (2007), "Equilibria in heterogeneous nonmonotonic multi-context systems", AAAI-07, pp. 385–390.**
* Each context is an abstract logic L = (KB, BS, ACC): knowledge bases, belief sets, and an acceptability function.
* Contexts are linked by possibly nonmonotonic bridge rules.
* Semantics is given by *equilibria* (belief states stable under the bridge rules).

**Eiter, Fink, Schüller & Weinzierl (2014), "Finding explanations of inconsistency in multi-context systems", AIJ 216:233–274.** When an MCS has no equilibrium, a **diagnosis** is a pair (D₁, D₂) of sets of bridge rules such that removing D₁ and adding the heads of D₂ unconditionally restores consistency. Dual "inconsistency explanations" locate minimal culprits.

*Use:* this is exactly the **blame-assignment problem for coherence feedback restricted to export rules**, already formalized and with algorithms. It is the MCS analogue of Reiter's (1987) consistency-based diagnosis [Reiter 1987, AIJ 32:57–95, unverified]. If our learner's world-level contradiction is traced through a context tree, the minimal diagnoses over {in-context steps, imports, bridges} are the "negative bags" of H2.

**de Kleer (1986), "An assumption-based TMS", AIJ 28:127–162.**
* Every derived datum carries a *label*: the set of minimal assumption-sets (environments) under which it holds.
* An environment from which ⊥ is derived becomes a *nogood*, and nogoods do not contaminate other environments.

*Use:* the ATMS is the computational form of "contradictions inside hypothetical contexts are fine, and are themselves informative". It is also an efficient data structure for a learner that maintains many contexts at once. Nogood environments are exactly the inputs a coherence loss should consume.

---

## 3. Inconsistency-tolerant reasoning

### 3.1 Chunk and permeate

**Brown & Priest (2004), "Chunk and permeate, a paraconsistent inference strategy. Part I: The infinitesimal calculus", J. Phil. Logic 33:379–388.**
* Information is split into **chunks**, each consistent and closed under *classical* logic.
* A **permeability relation** ρ specifies which formulas may flow from one chunk to another. A designated output chunk yields the conclusions.
* My reconstruction of the exact definition, not re-verified: chunk i's theory at stage n+1 is the classical closure of its own premises plus ρ(j,i)-filtered formulas from the stage-n theories of other chunks.

The calculus application works as follows:
* Chunk 1 treats the increment h as nonzero and computes, e.g., (f(x+h)−f(x))/h = 2x + h for f = x².
* Only equations of a certain form permeate to chunk 2, where h is treated as 0, giving f′(x) = 2x.
* The formula h ≠ 0 does *not* permeate, so no contradiction arises in any chunk.

Secondary literature describes the permeating formulas as "standard part" claims.

**Brown & Priest (2015), "Chunk and permeate II: Bohr's hydrogen atom", Eur. J. Phil. Sci. 5(3):297–314.**
* Bohr's model relied on classical electrodynamics together with quantization assumptions irreconcilable with it: accelerating orbital electrons should radiate.
* C&P reconstruction: classical mechanics/electrostatics compute the orbit in one chunk; quantization and the frequency condition live in another; only selected equations cross over.

**Benham, Mortensen & Priest (2014), "Chunk and permeate III: the Dirac delta function", Synthese [vol./pages unverified]** applies the same strategy to the delta function.

**Critiques and extensions.**
* Heyninck, Verdée & Heeffer (2018, JPL 47(3):481–511) identify shortcomings in C&P's application to the early calculus. They give an **adaptive logic for the design of C&P structures**: the chunking and permeability are *generated* rather than stipulated by hand.
* Vickers (2013, below) argues that such reconstructions often depart from what scientists actually did.
* Friend & Martínez-Ordaz (2018, "Keeping globally inconsistent scientific theories locally consistent", in *Contradictions, from Consistency to Inconsistency*, Springer [editors unverified]) defend local consistency strategies.
* Martínez-Ordaz (2022) [venue unverified] argues that C&P is insufficient for theory–observation inconsistencies in which observation is not theory-independent (the solar-neutrino case).

**What this gives us.**
1. *Classical logic inside chunks, structure between chunks.* We never need a paraconsistent logic inside a mathematical derivation.
2. **A unifying observation (mine, not in the C&P papers as far as I know).** In the calculus case, the permeability that is safe is exactly "pass the standard part / the limit as h → 0 of an expression continuous in h". Weierstrassian analysis later *certified* this permeation by a continuity theorem.

   In physics, the export that is safe is "pass the value at λ = 0 of a quantity continuous in the idealization parameter λ". So **permeability is principled exactly when backed by a continuity (or asymptotic) theorem**. This is the same criterion as physics export (§9). The early calculus is *the* historical case of mathematics done before formalization in inconsistent contexts with controlled permeation. A learner that learns C&P-style permeation rules *and* is required to justify them by continuity would have handled Leibnizian calculus. This is relevant to the user's success criterion 2 ("would have worked before we knew how to formalize").
3. **Heyninck et al. show permeability can be generated by a logic, not hand-chosen.** That is the closest prior work to *learning* import/export filters.

### 3.2 Paraconsistent logics proper

* **LP** (Priest 1979, "The logic of paradox", JPL 8:219–241 [unverified]): three values with "both" designated, so no explosion. But disjunctive syllogism and (material) modus ponens fail.
* **Relevance logics** (Anderson & Belnap 1975, *Entailment* vol. 1 [unverified]): enforce variable-sharing between premises and conclusion.
* **Jaśkowski's discussive logic D2** (1948; English translation "Propositional calculus for contradictory deductive systems", Studia Logica 24 (1969):143–157). This is literally a *logic of discussion with several participants*.
  * A is discussively asserted iff ◇A holds in S5: some participant holds it.
  * Discussive implication is A →_d B := ◇A → B, and discussive conjunction is A ∧_d B := ◇A ∧ B.
  * Adjunction fails: A and ¬A can both be asserted without A ∧ ¬A.
* **Preservationism** (Schotch & Jennings 1980, "Inference and necessity", JPL 9:327–340; later Schotch, Brown & Jennings (eds.) 2009, *On Preserving* [unverified]).
  * The *level* of a premise set is the least number of cells in a partition into consistent subsets.
  * Γ *forces* A iff every such minimal partition has a cell entailing A. These technical details are from memory [unverified].
  * Inference preserves the level of incoherence instead of truth.
* **Rescher & Manor (1970)**, "On inference from inconsistent premisses", Theory and Decision 1:179–217. They define:
  * *W-consequences*: what follows from *some* maximal consistent subset;
  * *I-consequences*: what follows from *all* of them;
  * *P-consequences*: what follows from preferred ones.
* **Batens' inconsistency-adaptive logics** interpret premises "as consistently as possible". Their *dynamic proofs* mark lines as defeated when an abnormality is later derived. Meheus applied them to Clausius's derivation of Carnot's theorem from inconsistent premises [venue unverified].

*Assessment for our project:*
* Discussive logic and preservationism are formal versions of "P in one context and ¬P in another is fine". They achieve it by **blocking adjunction across contexts**, which is exactly what a context tree does structurally. They are useful as *semantics for a pooled knowledge base* that is globally inconsistent (e.g., a learner's union of patch-relative rule sets).
* Rescher–Manor W-consequence is the "credulous import" regime and I-consequence the "skeptical" one. Neither matches idealization, because idealization deliberately imports *less* than any maximal consistent subset (§4).
* Adaptive logics' dynamic proofs are the closest logical model of a *learner* that retracts derivations when coherence feedback arrives.
* Quantitative inconsistency measures (e.g., Hunter & Konieczny, KR 2008 [unverified]) based on minimal inconsistent subsets are ready-made candidates for a **graded coherence loss** over exported claims.
* Using LP or relevance logic *inside* chunks would cripple ordinary mathematics. Avoid.

### 3.3 Vickers (2013), *Understanding Inconsistent Science* (OUP)

* Four core case studies: Bohr's atom, classical electrodynamics, Newtonian cosmology, the early calculus.
* Further cases in ch. 7: Aristotle's theory of motion, Olbers' paradox, the "classical" electron, Kirchhoff's diffraction theory.
* Main thesis: most "inconsistent science" claims depend on reconstructions that depart unacceptably from the history. The right response to inconsistency differs greatly from case to case, so general claims about "science" are suspect.

Relatedly, Frisch (2004, "Inconsistency in classical electrodynamics", Phil. Sci. 71 [pages unverified]) argued that four standard assumptions of the classical electrodynamics of point charges are jointly inconsistent, yet physicists use them fruitfully. Muller (2007, Phil. Sci. 74 [unverified]) and others replied that Frisch *applied* the theory inconsistently.

*Use:* Vickers is a warning against hoping that one inconsistency-handling *logic* fits all cases. For us this argues for a **learned, content-driven** permeability/bridge structure rather than a fixed paraconsistent consequence relation. That fits the user's learning framing well.

---

## 4. Supposition, belief revision, counterfactuals, counterpossibles

**AGM** (Alchourrón, Gärdenfors & Makinson 1985, JSL 50:510–530 [unverified]).
* Revision K∗A of a theory by A satisfies success (A ∈ K∗A) and consistency (if A is consistent), and is a minimal change.
* The Levi identity defines it as K∗A = Cn((K ÷ ¬A) ∪ {A}), with contraction governed by an entrenchment ordering.

**Gärdenfors (1986)**, "Belief revisions and the Ramsey test for conditionals", Phil. Review 95 [pages unverified]. There is no non-trivial revision system that satisfies both:
* the Ramsey test (A > B is accepted in K iff B ∈ K∗A), and
* Preservation (if ¬A ∉ K then K ⊆ K∗A).

**Levi (1996)**, *For the Sake of the Argument* (CUP), develops suppositional reasoning "for the sake of argument" as distinct from belief change.

**Counterfactuals.**
* Stalnaker (1968) and Lewis (1973, *Counterfactuals*) [both unverified]: A □→ B is true iff B holds at the closest (or all closest) A-worlds.
* Lewis (1976) introduced *imaging* as the probabilistic analogue. Joyce (1999) distinguishes *indicative supposition* (conditioning) from *subjunctive supposition* (imaging) [both unverified].

**Counterpossibles.**
* Williamson's vacuism holds that all counterpossibles are true.
* Nolan (1997, "Impossible worlds: a modest approach", NDJFL 38(4):535–572) introduces impossible worlds and the "strangeness of impossibility condition": any possible world is closer than any impossible one.
* Berto, French, Priest & Ripley (2018, "Williamson on counterpossibles", JPL 47(4):693–713) defend non-vacuism against Williamson.

**What this gives us, and where it misleads.**
1. **Indicative supposition = full import.** Natural-deduction subproofs and reductio are the indicative regime: import everything from the parent, add A, derive, then discharge. ⊥ inside is *productive*.
2. **Counterfactual supposition = maximal-compatible import** (AGM, or Lewis similarity). It keeps laws and as much particular fact as possible.
3. **Idealization is neither.** "Assume air pressure is 0" in a hydrostatics problem does not ask what *would* happen if the atmosphere vanished. In that counterfactual the water boils, the student asphyxiates, and the problem is moot. It asks what follows in a *designated mathematical model* that imports incompressible hydrostatics and the problem data and *nothing else*. This is minimal, designated import (C&P, Cyc microtheories, Cartwright's models). Using AGM or similarity semantics for physics idealizations imports exactly the background that makes the context degenerate. **So H6's single import mechanism should be split into three regimes, and the learner must learn which regime a "suppose/assume/consider" sentence invokes.** This is a meaning-learning problem in the inferentialist sense.
4. **Counterpossibles are needed rarely.** Physics idealizations are usually *nomically* impossible ("frictionless", "massless rope", "point charge") but *mathematically consistent*. So a local-model semantics suffices and impossible worlds are rarely needed. They become relevant only for "suppose π = 3"-type mathematical counterpossibles. There, reductio (regime 1) is normally what is meant.
5. **Gärdenfors' triviality is a warning for the meta-level.** If the learner's language contains a conditional whose acceptance is defined by revising its own belief state (Ramsey test), Preservation must fail somewhere. Keeping `ist(c, φ)` *about a specified context* rather than about "my beliefs revised by A" avoids the issue: the context is a fixed syntactic object, not a function of the current belief state.

---

## 5. Philosophy of idealization

This section is distilled toward *export criteria*.

**Cartwright (1983), *How the Laws of Physics Lie* (OUP).** Fundamental laws are true only of models (*simulacra*). Phenomenological laws are true of the world. Explanation proceeds by fitting phenomena into models, and the composition of causes (e.g., vector addition of forces) is a key point of contention.
*Use:* this is the semantic justification for putting laws *in model contexts* and keeping the root context phenomenological (correction 6 in §12).

**McMullin (1985), "Galilean idealization", Stud. Hist. Phil. Sci. 16(3):247–273.**
* Distinguishes mathematical, construct (formal vs material) and causal idealizations.
* Central thesis: a model's simplifying assumptions can be removed step by step. This **de-idealization** is theoretically motivated rather than ad hoc, and the model then grounds a continuing research programme.
* The theory-driven availability of corrections is evidence for the theory.

*Use:* the export justification "I can say what the first correction is, and why, from the same theory" is McMullin's criterion. It is exactly what the no-free-export argument (§9) shows to be *necessary*: information about the de-idealized family.

**Laymon** (several papers; the most relevant line for the user's "principled justification").
* (1985), "Idealizations and the testing of theories by experimentation", in Achinstein & Hannaway (eds.), *Observation, Experiment, and Hypothesis in Modern Physical Science*, MIT Press/Bradford, pp. 147–173. As reported in secondary sources (SEP "Models in Science"): predictions of a model typically become better when idealizations are relaxed, and this improvement is what confirms the theory.
* (1987), "Using Scott domains to explicate the notions of approximate and idealized data", Phil. Sci. 54(2):194–221. Abstract, verified:
  * Scott domains (continuous lattices) model idealized and approximately true data.
  * Historical episodes are attempts to show theories are **monotonic**: they "yield better predictions when fed better or more realistic data".
  * **Monotonicity and truth are independent notions.**
  * A stronger notion of **continuity** relates to "the finite nature of scientific computations".
  * The space of theories is itself a Scott domain, giving an account of one theory approximating another.
* (1989), "Cartwright and the lying laws of physics", J. Phil. 86(7):353–372.
* (1989), "Applying idealized scientific theories to engineering", Synthese 81 [pages unverified].
* (1991), on thought experiments as ideal limits [unverified bibliographic details]. The SEP summary: "imagine a series of experimental refinements of the actual situation which approach the postulated limit and then require that the closer the properties of a system come to the ideal limit, the closer its behavior has to come to the behavior of the ideal limit (monotonicity)".
* (1995), "Experimentation and the legitimacy of idealization", Phil. Studies 77:353–375.

*Use:* the most directly usable idea in the strand.
* **Two directions.**
  * (i) *Export direction.* As the actual system approaches the ideal limit, its behaviour approaches the ideal model's. This is continuity at λ = 0, and it licenses exporting the ideal model's answer for nearly ideal systems.
  * (ii) *Confirmation direction.* Feeding the theory more realistic inputs must move predictions toward observation. If not, the theory, not the idealization, is in trouble.
* **Domain theory = interval arithmetic.**
  * Read data as intervals ordered by reverse inclusion.
  * A theory's prediction map T is *monotone* if narrower inputs give narrower (nested) outputs.
  * T is *Scott-continuous* if the prediction for the exact input is the limit of predictions for approximations.
  * This is precisely the inclusion-monotonicity and continuity of interval arithmetic and computable analysis: computable real functions are continuous.
  * This gives us a **mechanizable export certificate format**: interval-valued predictions under interval-valued inputs, with the idealized parameter included as an interval [0, λ_max].
* Laymon's warning that **monotonicity ≠ truth** is the same one-sidedness as point 4 of §0. A coherent, monotone theory can still be wrong, so world feedback remains necessary.

**J. L. Ramsey** (I take "Ramsey's view of approximations" to mean Jeffry L. Ramsey, not F. P. Ramsey).
* (1990), "Beyond numerical and causal accuracy: expanding the set of justificational criteria", PSA 1990 vol. 1, pp. 485–499. Distinguishes two forms of approximation and contrasts them with idealization. Argues that numerical- and causal-accuracy arguments succeed only if the theories used are known to be true, computational difficulties are absent, and experimental conditions permit.
* (1992), "Towards an expanded epistemology for approximations", PSA 1992 vol. 1 [pages unverified]. Asks how to judge an approximation's quality and validity when equations are intractable, initial conditions imprecise, or auxiliary theories missing.

*Use:* a reminder that "compare with the exact solution" is usually unavailable. Export criteria must work without the true model, through bounds, regimes and robustness.

**Norton (2012), "Approximation and idealization: why the difference matters", Phil. Sci. 79(2):207–232.**
* An **approximation** is an inexact *description* of a target system: a set of propositions.
* An **idealization** is *another system*, real or fictitious, whose properties inexactly describe the target.
* Limit systems can have unexpected, even inconsistent properties. *Limit properties* (limits of a property along the sequence) can differ from the *properties of the limit system*. Norton reports limit systems whose behaviour violates determinism and energy conservation.
* Illustration: a capsule (cylinder of length a with hemispherical caps). As a → ∞ its area/volume ratio tends to 2, which agrees with the infinite cylinder's ratio. Here limit property and limit-system property agree. Other examples are of cases where they do not.
* Consequence: familiar statistical-physics limit systems sometimes fail to be idealizations and are mere approximations.

*Use:* Norton's distinction is exactly the **difference between arguing *inside* an idealized context and exporting a *property***.
* Arguing in context c is reasoning about the limit system M₀.
* Exporting "Q ≈ Q(M₀)" is legitimate iff Q(M₀) = lim_{λ→0} Q(M_λ): the limit property equals the property of the limit system, which is continuity of Q at 0.
* When they differ, *reasoning in M₀ is not the right justification*. One must reason about the sequence: Norton's "approximation" in place of "idealization". In our formalism this means using asymptotic analysis as the bridge, not evaluation at λ = 0.

**Batterman (2002), *The Devil in the Details: Asymptotic Reasoning in Explanation, Reduction, and Emergence* (OUP).** Asymptotic reasoning eliminates details. The philosophically significant cases are **singular limits**: caustics, rainbows (Batterman 1997 "Into a mist"), critical phenomena. In these, the limiting theory's behaviour is not approached smoothly, yet asymptotic analysis of the singular limit is explanatorily essential.
*Use:* exports across singular limits are possible but need *structured* bridges (matched asymptotics, uniform approximations), not value-at-the-limit.

**Strevens (2008), *Depth* (Harvard UP); Strevens (2019), "The structure of asymptotic idealization", Synthese 196:1713–1731.**
* In the kairetic account, an idealization signals that a factor is **not a difference-maker** for the explanandum. Such factors are set to extreme or default values, typically zero or infinity.
* The 2019 paper gives a general schema for asymptotic idealization, engaging Batterman and Norton, with population-genetics examples.

*Use:* "set the non-difference-maker to its default value" is a *licensing condition for stipulations*: a stipulation λ := 0 is admissible for query Q iff λ does not make a difference to Q at the required grain. That is again a continuity/insensitivity condition, but stated *relative to the query*. **Admissibility of an idealization is query-relative.** The same "p_atm = 0" is fine for "gauge pressure at depth h" and fatal for "will the suction cup hold?"

**Weisberg (2007), "Three kinds of idealization", J. Phil. 104(12):639–659.** Three kinds, each with its own justification and governed by different *representational ideals*:
* **Galilean**: distortions for tractability, to be removed later. Justified by de-idealizability.
* **Minimalist**: keep only core difference-makers. Justified by explanatory relevance (Strevens).
* **Multiple-models (MMI)**: several incompatible models, not expected to converge on one de-idealized model.

**Robustness.**
* Weisberg (2006), "Robustness analysis", Phil. Sci. 73(5):730–742: search for predictions common to several models, identifying "robust theorems".
* Levins (1966), "The strategy of model building in population biology", Am. Sci. 54:421–431: "our truth is the intersection of independent lies" (p. 423).
* Odenbaugh & Alexandrova (2011), "Buyer beware", Biol. & Phil. 26(5):757–771: robustness across models that share idealizations is not independent evidence. It is a discovery heuristic, not confirmation.

*Use:*
* MMI is the explicit acknowledgement that *mutually inconsistent contexts are normal* in good science.
* Robustness is the internal coherence check across exports.
* The Odenbaugh–Alexandrova point is exactly the common-mode blind spot in §9, Proposition 5.

**Wilson (2006), *Wandering Significance* (OUP); "Theory façades", Proc. Arist. Soc. 104 (2004):273–288; *Physics Avoidance* (OUP 2017).**
* Predicates such as "hardness", "force" and "weight" look unified but are supported by an **atlas of local patches**, each with its own inferential practice, joined at boundaries.
* A **façade** is such a patchwork masquerading as a single theory. Classical mechanics is a central example: point-mass, rigid-body and continuum treatments with incompatible presuppositions.

*Use:* this is directly about *inferentialist meaning*.
* The inferential role of "friction", "pressure" or "rigid" is patch-relative. A learner of inference rules from physics solutions will learn patch-indexed rules, and global coherence of the pooled rule set should *not* be expected.
* Wilson is the strongest support for making context indices part of the learned rule representation, and for the correction that @ must not contain unrestricted laws.

  *Example*: "frictionless" in an olympiad problem with a rolling ball means "non-dissipative", not "no tangential contact force". Otherwise rolling without slipping is impossible and the context is ill-posed. The meaning is fixed by inferential role within the patch.

**Knuuttila & Morgan (2019), "Deidealization: no easy reversals", Phil. Sci. 86(4):641–661.** De-idealization is rarely a simple reversal of idealizing steps. Models are more inflexible than the "reversal thesis" suggests, and de-idealization is creative.
*Use:* do not assume a canonical de-idealization path exists for every context. Export certificates should be *bounds on the neglected effect* (§9), which need only an envelope of the de-idealized family, not a constructed de-idealized model.

**Frigg & Hartmann, "Models in science", SEP** (first published 2006, revised later [revision date unverified]). The standard survey. Its idealization section is the source of the Laymon summary quoted above.

---

## 6. The mathematics of justified idealization

These are the textbook mathematical forms of "export".

1. **Regular perturbation.** If Q(λ) is C¹ (better: analytic) near 0, then Q(λ*) = Q(0) + λ*Q′(0) + R₂ with an explicit remainder bound. *Certificate:* a bound on |Q′| on [0, λ*] (Lipschitz), or the first-order term plus a bound on |Q″|. Physicists call this a **controlled approximation**: there is a small dimensionless parameter and the error is bounded or systematically improvable.
2. **Gronwall / fundamental inequality for ODEs.** Let ẋ = f(x) be the idealized dynamics with f L-Lipschitz, and let the true dynamics be ẏ = f(y) + g(y) with |g| ≤ δ along the trajectory. Then |x(t) − y(t)| ≤ |x₀ − y₀|e^{Lt} + (δ/L)(e^{Lt} − 1). This is the canonical *finite-horizon* export certificate: bound the neglected force, get a trajectory tolerance that grows with time.
3. **Structural stability** (Andronov–Pontryagin 1937 [unverified]). A system is structurally stable if C¹-small perturbations of the vector field give topologically equivalent phase portraits. Qualitative claims about structurally *unstable* idealizations do not export.
   * The undamped oscillator's closed orbits, or Lotka–Volterra's neutral cycles, are destroyed by arbitrarily small damping or nonlinearity.
   * Yet the period of the undamped oscillator exports fine over a few cycles (by 2).
   * So **exportability is a 3-place relation: (idealization, claim, regime/horizon/tolerance).**
4. **Singular perturbation and matched asymptotic expansions** (Van Dyke 1964; Bender & Orszag 1978 [both unverified]). When the small parameter multiplies the highest derivative, the λ → 0 limit is not uniform. Boundary layers appear, and the outer (idealized) solution is valid only away from them.
   * The paradigm is **d'Alembert's paradox**: inviscid (zero-viscosity) potential flow predicts zero drag on a body, while real drag stays finite as viscosity → 0. This is because of boundary-layer separation (Prandtl).
   * This is the cleanest example of Norton's "limit property ≠ property of limit system".
   * The bridge must be the *matched* expansion, not the value of the idealized model.
5. **Near-decomposability** (Simon & Ando 1961, "Aggregation of variables in dynamic systems", Econometrica 29(2):111–138). Nearly decomposable linear systems separate short-run dynamics within blocks from long-run aggregate dynamics. This justifies ignoring weak links over appropriate time scales, which is a time-scale-relative export theorem. It was taken into AI by Iwasaki & Simon (1994, "Causality and model abstraction", AIJ 67 [unverified]).
6. **Symmetry and invariance.** If the idealized parameter enters the equations only through a quantity it does not affect, the export is *exact* after reinterpretation. Example: hydrostatics depends on p only through ∇p and pressure differences. See §10.
7. **Robustness across models** (Levins/Weisberg). Agreement of several models with different idealizations is evidence that the claim is not an artefact, modulo shared assumptions.

---

## 7. AI: automated modelling with explicit modelling assumptions

**Falkenhainer & Forbus (1991), "Compositional modeling: finding the right model for the job", AIJ 51:95–143.**
* Domain knowledge is organized into **model fragments** conditioned on *explicit modelling assumptions*.
* Assumption classes group mutually exclusive choices (e.g., consider vs ignore a phenomenon, or granularity) [the exact terminology of "simplifying" vs "operating" assumptions is from memory, unverified].
* Given a domain theory, a structural description and a **query**, the algorithm composes a model that suffices to answer the query while minimizing extraneous detail.

Builds on Forbus's qualitative process theory (1984, AIJ 24:85–168).

**Nayak (1994), "Causal approximations", AIJ 70:277–334; Nayak (1995), *Automated Modeling of Physical Systems*, Springer LNAI [unverified].**
* Finding an **adequate** model (roughly, the simplest model that answers the query with required accuracy) is **NP-hard**. Three sources of intractability: deciding what phenomena to model, deciding how to model them, and satisfying domain constraints.
* For **causal approximations**, in which more approximate models entail fewer causal relations so that causal relations decrease monotonically as models simplify, there is a polynomial-time algorithm [further restrictions may apply, unverified].

**Weld (1990), "Approximation reformulations", AAAI-90; Weld (1992), "Reasoning about model accuracy", AIJ 56:255–300.**
* A simple model *approximates* a complex one when the complex model has an exogenous **fitting parameter** such that the two models' quantitative predictions become arbitrarily close as the parameter tends to a limit.
* This reduces *inter-model* comparison to analysis of a *parameter change within one model*. So when predictions disagree with observations, one can reason about which model switch would fix the discrepancy.

**Addanki, Cremonini & Penberthy (1991), "Graphs of models", AIJ 51:145–177/178 [page range uncertain]; earlier IJCAI-89 paper "Reasoning about assumptions in graphs of models".** Models are nodes and edges are changes of assumptions. Conflicts between predictions and observations guide traversal to a model lacking the violated assumption [content from memory, unverified].

*Use for us:* this literature is the closest *engineering* precedent for a principled physics-problem system.
* Compositional modelling gives the representation: model fragments plus explicit assumptions, which correspond to our context stipulations.
* Nayak gives adequacy and its complexity. *Checking* a supplied model is easy; *finding* one is hard. For a solution *checker*, the solver supplies the context, which is good news.
* Weld's fitting parameters are Laymon's monotonicity, mechanized.
* Graphs of models give feedback-driven model switching.

What these systems lacked:
* a learning story (all fragments were hand-written);
* rigorous export certificates (accuracy reasoning was mostly qualitative);
* any treatment of informal text.

Those are exactly the gaps the user's project would fill.

---

## 8. Key question 1: a clean formal account of arguing in a context

I propose the following "context-tree calculus". It combines `ist`, LMS/MCS bridge rules, C&P permeability, and natural-deduction discharge. It is offered as a candidate for the project's formal core. Statements marked *Proposition* are mine. They are routine, but the proofs should be adversarially checked before use.

### 8.1 Syntax

* Fix a base logic ⊢ (classical many-sorted FOL with real arithmetic) and a learned rule set R of inference schemas (the object of learning).
* A **context system** is a finite rooted tree of contexts. The root is @. For olympiad *grading*, the root is the problem context c_P (§10.4).
* Each context c has:
  * a **kind** κ(c) ∈ {SUP, IDL};
  * a language L_c;
  * **stipulations** S_c;
  * an **import filter** F_c ⊆ L_{π(c)}, where π is the parent;
  * for IDL contexts, a set of **bridges** B_c.
* SUP contexts have S_c = {A} and full import: F_c = L_{π(c)}.
* A bridge β = (φ_β(x), σ_β(c, x), ε_β(x)) consists of:
  * a pattern φ_β(x) of in-context conclusions;
  * a side condition σ_β(c, x) ∈ L_{π(c)};
  * an export formula ε_β(x) ∈ L_{π(c)}.
* Judgments have the form c ⊩ φ.

The rules are:

* **(Ax)** φ ∈ S_c ⇒ c ⊩ φ. At @, the axioms are K ∪ O (background plus observations).
* **(Step)** c ⊩ φ₁,…,φₙ and (φ₁…φₙ / ψ) ∈ R ⇒ c ⊩ ψ.
* **(Imp)** π(c) ⊩ φ and φ ∈ F_c ⇒ c ⊩ φ. This is permeation *into* c.
* **(Dis)** κ(c) = SUP, S_c = {A}, c ⊩ ψ ⇒ π(c) ⊩ A → ψ. In particular, c ⊩ ⊥ gives π(c) ⊩ ¬A.
* **(Exp)** κ(c) = IDL, β ∈ B_c, c ⊩ φ_β(t), π(c) ⊩ σ_β(c, t) ⇒ π(c) ⊩ ε_β(t). This is permeation *out of* c.
* **(Ist)** c ⊩ φ ⇒ d ⊩ ist(c, φ) for every d.

Counterfactual contexts (the AGM regime) can be added as a third kind CF, with F_c computed by an entrenchment-based revision. I omit them because olympiad physics rarely needs them.

### 8.2 Semantics (local models)

* Mod(@) is the class of models of K ∪ O. The actual world W ∈ Mod(@) iff K ∪ O is true.
* For SUP: Mod(c) = {M ∈ Mod(π(c)) : M ⊨ A}. This may be empty.
* For IDL: Mod(c) = {M : M ⊨ S_c ∪ Imp*(c)}, where Imp*(c) = F_c ∩ Th(Mod(π(c))). There is no requirement that Mod(c) ∩ Mod(π(c)) ≠ ∅. This is how "p_atm = 0" coexists with "p_atm ≈ 10⁵ Pa".
* A rule instance is *sound* if it preserves truth in all L_c-structures. Optionally, allow patch-relative soundness: truth-preserving within a declared patch class.
* A bridge β is *sound at c* if for every M′ ∈ Mod(π(c)): whenever Mod(c) ⊨ φ_β(t) and M′ ⊨ σ_β(c, t), then M′ ⊨ ε_β(t). This is LMS compatibility.

**Proposition 1 (soundness).** If every Step and Exp instance in a derivation is sound, then c ⊩ φ implies Mod(c) ⊨ φ. In particular, if @ ⊩ φ and K ∪ O is true, then W ⊨ φ.

*Proof sketch:* induction on derivations.
* (Imp): by the induction hypothesis, φ holds throughout Mod(π(c)). Since φ ∈ F_c, φ ∈ Imp*(c), so it holds in Mod(c).
* (Dis): every M ∈ Mod(π(c)) with M ⊨ A lies in Mod(c), so M ⊨ ψ, hence M ⊨ A → ψ. If Mod(c) = ∅, then ¬A holds throughout Mod(π(c)).
* (Exp): by bridge soundness. ∎

**Corollary (reductio immunity and blame localization).** Suppose @ ⊩ ⊥ while K ∪ O is true. Then some Step or Exp instance *in the derivation of @ ⊩ ⊥* is unsound. These instances form the negative bag, and they include steps inside sub-contexts whose conclusions were discharged or exported into @.

Conversely, a SUP context deriving ⊥ is *never*, by itself, evidence of an unsound step: SUP contexts with Mod(c) = ∅ soundly prove ⊥. Likewise, `ist(c₁, P)` together with `ist(c₂, ¬P)` is never a coherence violation.

**Proposition 2 (well-posedness is a bridge precondition).** Suppose IDL context c is ill-posed: Mod(c) = ∅. Then Mod(c) ⊨ φ_β(t) for every t. So soundness of β at c requires that every M′ ∈ Mod(π(c)) satisfying σ_β(c, t) also satisfies ε_β(t), for *all* t.

For any *informative* bridge, the family {ε_β(t)} is jointly unsatisfiable. A typical case is ε_β(t) = "Q ∈ [t − ε, t + ε]", ranging over all t. Then σ_β(c, ·) must be unsatisfiable at ill-posed c.

*Moral:* penalizing c ⊩ ⊥ for IDL contexts is *not* a world-coherence penalty. It is the contrapositive of bridge soundness. Ill-posed idealizations must not export, so "the idealized model is consistent" is an implicit side condition of every bridge. This gives the brief's H6 a principled reason to impose *local* coherence on idealized contexts while exempting suppositional ones.

### 8.3 Coherence losses implied by the calculus

The losses are:

* **L_world**: a penalty whenever @ ⊩ ⊥. Optionally, use a graded inconsistency measure over the minimal inconsistent subsets of exported claims. Blame is distributed over the Step, Imp and Exp instances in the derivation, using MCS-style diagnoses (Eiter et al. 2014) or Reiter/ATMS minimal conflict sets.
* **L_wellposed**: a penalty whenever c ⊩ ⊥ for IDL c that is used for export. Blame goes to Step instances in c and to the *import filter* F_c. Example: importing phase-diagram facts into the "p_atm = 0" context makes it ill-posed. This is the negative data that a learner of import filters needs.
* **No penalty** for SUP c ⊩ ⊥, or for contradictory `ist`-claims across contexts.

Two remarks:

* **Learning the import filter is itself a Gold-type problem.** Human solutions show which imports *were* used (positive data), never which are forbidden. L_wellposed is the source of negative data, together with world-level failures of exported answers.
* **Stipulations must never permeate.** S_c is non-exportable by construction: Exp only exports instances of bridge patterns, which are query answers. This is the C&P lesson. In the calculus example, h ≠ 0 does not permeate. In physics, "p_atm = 0" is never exported to @. Without this, the user's worry ("you can prove air pressure isn't 0") would become real incoherence.

### 8.4 What existing formalism comes closest?

* **LMS/MCS** with bridge rules and the Eiter et al. diagnosis theory supply the semantics and blame assignment.
* **C&P** supplies the "classical inside, filtered between" discipline and the calculus/Bohr case studies.
* **`ist`** supplies the meta-level eternal propositions.
* **Natural deduction** supplies SUP discharge.

None of them separates SUP from IDL contexts with *different coherence obligations*, or attaches justification obligations (certificates) to bridges. The calculus above is a small but real addition.

---

## 9. Key question 2: what justifies exporting?

### 9.1 A taxonomy of export certificates

| Code | Certificate | Formal content | Sources |
|---|---|---|---|
| E1 | Exact symmetry / invariance | Q is invariant under λ ↦ λ′ on the relevant model class, after a lifting/reinterpretation map | McCarthy lifting; gauge-type reasoning |
| E2 | Regular perturbation / continuity with modulus | sup_{λ ∈ [0, λ*]} \|Q(λ) − Q(0)\| ≤ ε, from a derivative or remainder bound | Norton (limit property = limit-system property); Laymon continuity; controlled approximation |
| E3 | Dynamical (Gronwall) bound | neglected force ≤ δ, L-Lipschitz flow, horizon T ⇒ trajectory error ≤ (δ/L)(e^{LT} − 1) | ODE theory |
| E4 | Theory-driven de-idealization | first correction computed within the same theory, with a bound on the rest | McMullin; Knuuttila–Morgan caveat |
| E5 | Monotone refinement chain | successive corrections shrink (e.g., geometrically with ratio r < 1) ⇒ tail bound \|ΔQ₁\|/(1 − r) | Laymon monotonicity |
| E6 | Difference-making / insensitivity at grain | the query's answer at required precision is invariant over the range of the idealized factor | Strevens |
| E7 | Asymptotic validity in a regime | matched or uniform asymptotic expansion; export restricted to the stated regime | Batterman; Van Dyke; Strevens 2019 |
| E8 | Structural stability | qualitative (topological) claims export if the idealized system is structurally stable; otherwise only finite-horizon quantitative claims | Andronov–Pontryagin |
| E9 | Robustness across independent idealizations | intersection of exported intervals; shared assumptions must be tracked | Levins; Weisberg; Odenbaugh–Alexandrova |
| E10 | Empirical / simulation calibration | tolerances calibrated on world feedback or on numerically solved less-idealized models | Laymon 1995; J. L. Ramsey; conformal prediction |

### 9.2 Propositions that constrain any export mechanism

**Proposition 3 (no free export).**
* *Setup:*
  * IDL context c stipulates λ = 0, while in @ we have λ = λ* ≠ 0.
  * A bridge β exports "Q_world ∈ Q(0) ± ε" under a side condition σ that depends only on (i) facts about the λ = 0 model class, including all derivatives d^kQ/dλ^k(0), and (ii) the value λ*.
  * The class of admissible model families is closed under adding a flat perturbation h(λ) = A·e^{−1/λ²}. This holds, for example, for all C^∞ families.
* *Claim:* for every ε there are admissible worlds in which σ holds but the export is false. So β is unsound.
* *Proof:* add A·h(λ) with |A·h(λ*)| > 2ε. All λ = 0 facts are unchanged.
* *Moral:* a sound export needs **information about the family away from λ = 0**. Possible sources:
  * a uniform bound (E2, E3);
  * a theory restricting the family, e.g. analyticity with a known radius plus a remainder bound (E4/E5, which is McMullin's "theory-motivated de-idealization");
  * an invariance (E1);
  * data at λ ≈ λ* (E10).

  A formal power series in λ without a remainder bound is not a certificate. This is the physicist's "uncontrolled approximation", and asymptotic series make the point vivid. *This is a theorem-shaped vindication of McMullin and Laymon against the view that idealized models "speak for themselves".*

**Proposition 4 (export soundness is continuity on a known neighbourhood).**
* Let Θ be a parameter space of models, θ₀ the idealized parameters, and U ⊆ Θ a set certified in @ to contain the true θ*.
* The export "Q(θ*) ∈ Q(θ₀) ± ε" is sound for all worlds in U iff sup_{θ∈U} |Q(θ) − Q(θ₀)| ≤ ε. (Trivial, but it fixes the logical form of every bridge side condition: a *neighbourhood certificate* plus a *modulus of continuity*.)
* Corollary in the spirit of Laymon's Scott-domain account: suppose measurements in @ shrink U to {θ*} and the idealization θ₀ tracks the measured parameters. Then exports converge to the truth iff Q is continuous at θ*.
* This ties export to Kelly-style verifiability in the limit (H4): "Q(θ*) lies in an open interval" is verifiable in the limit through such exports when Q is continuous [the formal link to Kelly is my conjecture; to be checked].

**Proposition 5 (coherence is one-sided for tolerances; common-mode blindness).**
* Let bridges export intervals I_m = [q_m − ε_m, q_m + ε_m] for the same world quantity, from models m = 1…k.
* (a) The exports are jointly coherent iff ∩ I_m ≠ ∅. Increasing any ε_m preserves coherence. So a coherence-only objective is minimized by ε = ∞, giving trivial bridges ("tolerance inflation", the export analogue of Gold's over-general hypothesis).
* (b) Suppose all q_m share a common error e (shared idealization or shared false law) with |e| > max ε_m. The exports can still be perfectly coherent.
* (c) Hence calibration needs world feedback or a trusted refinement. With exchangeable feedback, split-conformal calibration of each bridge schema's ε gives marginal coverage ≥ 1 − α [Vovk, Gammerman & Shafer 2005, unverified]. Calibration should be stratified by regime, i.e. by dimensionless-parameter bins (Mondrian conformal).
* *Caveat (H1):* an adversarial solver *chooses* contexts. That is covariate shift, so marginal coverage does not give worst-case soundness. Regime-conditional calibration plus E2/E3-type certificates are needed where adversarial pressure is expected.

**Proposition 6 (adversarial stipulation).**
* Suppose solvers may introduce arbitrary stipulations, and bridge side conditions are evaluated *inside c* (on c's own parameter values).
* Then for any target world claim there is a context and a bridge use that exports it. Example: declare g := 10⁶ m/s² so that the drag ratio looks negligible.
* Uniform soundness over solver choices therefore requires two things:
  * side conditions evaluated in π(c) on π(c)'s values;
  * contexts restricted to **declared deformations of the parent**: "set the parameters in Λ_c to idealized values, inherit everything else". This is Strevens' "default values" made into a syntactic discipline.
* This is H1's adversarial-search concern transplanted to idealizations: *context choice is an attack surface*.

### 9.3 Laymon's monotonicity as an operational test

Two concrete checks can be implemented.

* **Export test (continuity).** For each export, require one of E1–E8. In practice, the solution must contain an *estimate of the neglected effect*: the first correction, or a bound on it, in terms of a dimensionless parameter evaluated at @'s values. This matches good physics practice ("check that the neglected term is small").
* **Confirmation test (monotonicity).** When world or simulation data are available, de-idealize one step. Predictions should move toward observation, in the sense of interval nesting. A violation points to the theory or to the bridge, *not* to the in-context mathematics. This routes the negative signal correctly.

---

## 10. Key question 3: "assume air pressure is 0"

### 10.1 Hydrostatics (exact export via symmetry, E1)

**The context.**
* Context c: IDL with stipulation p_surface = 0.
* Imports: incompressible-fluid hydrostatics (∇p = ρg), the container geometry, ρ, g.
* Not imported: the measured value of p_atm, the water phase diagram.

**In c.** We derive p(h) = ρgh.

**Is c consistent with @?** No, since @ ⊩ p_atm ≈ 1.0×10⁵ Pa. This does not matter: Mod(c) ≠ ∅, so c is well-posed, and no stipulation permeates.

**The tempting contradiction.** "At p = 0, water at 20 °C boils, so there is no liquid." This uses an import (vapour pressure about 2.3 kPa) that is *not* in F_c. If a solver imports it, c becomes ill-posed. L_wellposed blames the *import*, which is the right negative signal for import-filter learning. Nothing is said against the world.

**Export.** The incompressible equations depend on p only through ∇p and pressure differences. So the shift p ↦ p + p_atm is a symmetry of the relevant model class. The bridge is a *reinterpretation (lifting) map*, not an approximation:

> ist(c, p = ρgh) ⟶ @ ⊩ p_abs − p_atm = ρgh (gauge pressure), exactly within the incompressible model.

**Side condition.** p_atm acts on *all* relevant boundary surfaces, i.e. there are open surfaces exposed to the same atmosphere.

**When the side condition fails, export is blocked.** This explains a family of classic errors:
* the force on a dam whose air side is also at p_atm (fine), versus a submerged hatch with vacuum or sealed air behind it (not fine);
* suction cups;
* Magdeburg hemispheres;
* barometers.

In these cases, by Strevens' criterion, p_atm *is* a difference-maker for the query, and the stipulation is inadmissible for that query.

### 10.2 Projectile (perturbative export with a rigorous interval, E2/E3)

**The context.** IDL c stipulates "no air" (drag 0, buoyancy 0). In c the range is R₀ = v₀² sin 2θ / g.

**Certificate.**
* Energy: d/dt(½v² + gy) = −k|v|³ ≤ 0. So for y ≥ 0, |v| ≤ v₀, and the drag acceleration is bounded by a_d = ½ρC_dAv₀²/m along the whole flight.
* Hence the trajectory deviates from the idealized one by at most ½a_d t².
* The flight time T satisfies 2v_{0y}/(g + a_d) ≤ T ≤ 2v_{0y}/(g − a_d), provided a_d < g.
* So R ∈ [v_{0x}T_lo − ½a_dT_hi², v_{0x}T_hi + ½a_dT_hi²].
* Buoyancy shifts g by the factor (1 − ρ_air/ρ_body).

**Steel ball (r = 1 cm, m ≈ 32.7 g, v₀ = 10 m/s, θ = 45°).**
* a_d/g ≈ 0.028; buoyancy ratio ≈ 1.5×10⁻⁴.
* The certificate gives R ∈ [9.61, 10.79] m around R₀ = 10.19 m.
* A numerical simulation with quadratic drag (C_d = 0.47; my computation) gives 9.98 m, inside the interval.
* Export: R = 10.2 m ± 6% (rigorous), or ≈ 2% (first-order estimate).

**Ping-pong ball (m = 2.7 g, r = 2 cm), same launch.**
* a_d/g ≈ 1.34 > 1. The certificate cannot even bound the landing time.
* The simulated range is about 5.3 m, i.e. 48% short.
* **Export blocked**, although the in-context derivation is word-for-word identical.

**Lesson.** The context's soundness and the export's soundness come apart. The dimensionless side condition a_d/g ≪ 1, evaluated with *@'s* values (Proposition 6), is what separates them. In-context steps can be checked worst-case (formal math). Exports are certified by an interval argument that is itself formal math, once the bounds on neglected forces are supplied as @-claims.

### 10.3 Singular and structurally unstable cases (export must change form)

* **Zero viscosity** (d'Alembert). In the ideal-fluid context the drag is exactly 0. As ν → 0 the real drag does not tend to 0. Value-at-the-limit export is unsound (Norton). A valid bridge is boundary-layer theory (E7).
* **Undamped oscillator.**
  * "Period = 2π√(m/k)" exports over finite horizons (E3).
  * "Oscillates forever with constant amplitude" does not export (E8 fails).
  * "Energy is conserved" exports only as "energy changes by at most (dissipation bound) × T".

### 10.4 Olympiad problems: the problem context is the graded root

When a *problem* says "assume air pressure is 0", the stipulation defines the graded context c_P. The correct answer is the answer *in c_P*. No export to the actual world is required, and background facts contradicting the stipulation are simply not imported.

The exports that need justification are from *solver-introduced* sub-idealizations into c_P. The user's EuPhO 2025-T1 introspection contains several:
* "sun is a point at infinity";
* "the illuminance at B is negligible compared to A";
* "the leg is a mirror, not diffuse";
* "the finger is horizontal".

Two cases:
* When c_P states a regime ("θ ≪ 1", "thin rod"), these exports are **leading-order asymptotic equivalences**, which are formal mathematics.
* When c_P is *underspecified*, the solver must complete it. I propose the **supervaluational/robustness criterion**:
  * an answer is correct iff it holds, to the precision demanded, in *every admissible completion* of c_P (cf. Fine 1975, "Vagueness, truth and logic", Synthese 30 [unverified]);
  * a solver's completion is acceptable iff the answer is insensitive to it across admissible completions (E6/E9), or it is a recognized default (Strevens).

This answers the user's note "verification from truth: check whether each claim is true in the context at hand — but wtf is that?" A claim is *true in the context at hand* iff it holds in all admissible models of the context.

The admissible class is fixed by:
* the problem text;
* domain conventions, which are learnable from positive examples of accepted completions;
* stated regimes.

The *reading* map from text to admissible class is the part that cannot be formalized away. It is also where imitation learning on human solutions has its proper role.

---

## 11. Theorem candidates and design ideas suggested by this strand

**Theorem candidates.** Most are short; their value is in fixing the right definitions.

1. **Context-tree soundness and blame localization** (Prop. 1 and Corollary). Includes reductio immunity: the coherence loss never penalizes a sound reductio or contradictory `ist`-claims. Extends to blame over bridges via MCS diagnoses.
2. **Well-posedness as bridge precondition** (Prop. 2). This justifies local coherence penalties exactly for idealized contexts that export.
3. **No free export** (Prop. 3). Idealized-model facts, even all Taylor coefficients, never certify export. De-idealization information, symmetry or data is necessary. This is a formal McMullin/Laymon theorem.
4. **Export = continuity on a certified neighbourhood** (Prop. 4), with the Laymon/Scott-domain reading. *Conjecture:* exports through idealizations make a world-claim verifiable in the limit iff the query map is continuous at the true parameters. This links to H4/Kelly.
5. **Gronwall-certified finite-horizon export, with structural-instability limits** (E3/E8). There is a negative companion: no bridge exporting *qualitative* long-time claims from a structurally unstable idealization is sound.
6. **One-sidedness of coherence for tolerances, and common-mode blindness** (Prop. 5). With a positive companion: conformal calibration of bridge schemas from sparse world feedback, with coverage guarantees under exchangeability, and a negative result under adversarial context choice.
7. **Adversarial stipulation** (Prop. 6). Uniform soundness requires side conditions evaluated in the parent, and contexts restricted to declared deformations.
8. **Learning import filters.**
   * *Gold-type negative result:* from positive examples of used imports alone, an over-permissive filter is never refuted.
   * *Positive result (conjecture):* with L_wellposed feedback, i.e. ill-posedness exposures, a conservative filter learner identifies a sufficient filter in the limit for finitely many context types.
9. **Supervaluational correctness for underspecified problem contexts.** Correctness = invariance over admissible completions, and checking reduces to robustness verification. Open question: complexity and learnability of the admissible class.

**Design ideas.**

* **Solution format for a physics checker.** A context tree containing:
  * the root c_P, holding the problem data and the stipulations from the problem;
  * solver IDL sub-contexts, as declared parameter deformations;
  * SUP sub-contexts for reductio and case splits;
  * in-context derivations, which are formal math and checkable worst-case;
  * exports, each citing a bridge schema from a catalogue plus its side-condition instance (dimensionless ratios evaluated at the parent's values, symmetry conditions, regime declarations);
  * global sanity checks: dimensional analysis as a type system, limiting cases, conservation laws, and robustness across two idealizations.
* **Bridge catalogue as learned objects**, after the model fragments of Falkenhainer–Forbus and the fitting parameters of Weld. Examples: small angle, with sin θ ≈ θ to relative error θ²/6; Stokes drag for Re ≲ 1; continuum for Kn ≪ 1; thin lens; point mass; rigid body; quasi-static process. Each has a validity regime and tolerance calibrated by simulation and world feedback.
* **ATMS-style labels** in the learner's working memory, so many contexts are maintained cheaply and nogoods are recorded as coherence data.
* **Coherence loss** = inconsistency measure over the minimal inconsistent subsets of @-claims (including exports) + L_wellposed for exporting IDL contexts. Zero weight on SUP contradictions.
* **"No export without a neglected-term estimate"** as a hard rule. It is cheap, it matches expert practice, and it is necessary by Prop. 3.
* **For informal math:** treat Leibnizian or other pre-rigorous reasoning as C&P with learned permeability. A *later* certification step (continuity theorems) upgrades permeations to bridges. This is a concrete, historically grounded instance of H5.

---

## 12. Where the brief's hypotheses need refinement

1. **H6, the import regime.** "Idealized contexts import only a selected fragment K_Γ ⊆ K" is right for idealizations. But there are three regimes: SUP (full import), CF (maximal compatible import by entrenchment or similarity) and IDL (designated minimal import). They have different coherence obligations. Using AGM/counterfactual import for physics idealizations imports exactly the background that makes the context degenerate.
2. **H6, the export form.** "An export (bridge) rule turns 'Q = q' into 'Q ≈ q ± ε'". Exports can also be:
   * exact reinterpretations via symmetry (absolute → gauge pressure);
   * regime- and horizon-restricted claims;
   * qualitative/topological claims (only under structural stability);
   * asymptotic statements (matched expansions) when the limit is singular.

   Stipulations themselves must never be exportable.
3. **H6, who trains what.** "Coherence trains the in-context rules, world feedback trains the export rules" is partly wrong.
   * World-level coherence blames bridges as well as in-context steps (Prop. 1).
   * Multi-model coherence constrains bridges from one side only (Prop. 5).
   * Well-posedness failures train *import filters*, which is a third learned component the brief omits.
   * World feedback is needed specifically for calibration and common-mode errors.
   * In-context rules in physics are mostly mathematics plus theory laws, and can often be checked worst-case without any feedback.
4. **The actual context @ must be phenomenological.** If @ contains fundamental laws as unrestricted universals, @ may itself be inconsistent (Wilson's façades; Frisch on classical electrodynamics, disputed), and L_world will fire spuriously. Laws should live in model contexts (Cartwright). @ should hold interval-valued claims about measurable quantities, observations and exports.
5. **H1 (worst-case soundness) needs a context-relative split.**
   * In-context soundness is relative to local semantics and can be worst-case.
   * World-soundness applies only to exports, which require certificates.
   * Statistical calibration of exports is not worst-case under adversarial context choice (Props. 5, 6).

   The soundness theorem should quantify over the contexts a prover may introduce, and that space must be restricted to declared parameter deformations.
6. **H7 (rule-following) gains a new axis.** Under Wilson's patch picture, the non-identifiability left after coherence includes *where patch boundaries and import filters lie*, not only which calculus is used. Meanings of terms like "frictionless" are patch-relative inferential roles. Coherence cannot fix them (each patch is coherent); difference-making and world feedback can.
7. **The eternalism worry is resolved at the meta-level**, via `ist` as eternal claims about finitely specified contexts. The brief can state this outright.
8. **Physics-olympiad goal: the target root is c_P, not the world.** Most of the needed export reasoning then becomes formal asymptotics. The residual informal core is the reading of the problem into an admissible class of intended models. That is where the supervaluational/robustness criterion and imitation of humans belong. This is a hopeful reframing of the user's success criterion 3.

---

## References

Bibliographic data checked by web search unless marked **[unverified]**.

* Addanki, S., Cremonini, R., & Penberthy, J. S. (1991). Graphs of models. *Artificial Intelligence* 51:145–177 (page end uncertain). Earlier IJCAI-89 paper "Reasoning about assumptions in graphs of models".
* Alchourrón, C., Gärdenfors, P., & Makinson, D. (1985). On the logic of theory change. *JSL* 50:510–530. [unverified]
* Anderson, A. R., & Belnap, N. D. (1975). *Entailment*, vol. 1. Princeton UP. [unverified]
* Andronov, A., & Pontryagin, L. (1937). Systèmes grossiers. *Doklady Akad. Nauk SSSR* 14. [unverified]
* Batterman, R. W. (2002). *The Devil in the Details*. OUP.
* Bender, C., & Orszag, S. (1978). *Advanced Mathematical Methods for Scientists and Engineers*. McGraw-Hill. [unverified]
* Benham, R., Mortensen, C., & Priest, G. (2014). Chunk and permeate III: the Dirac delta function. *Synthese* 191 [vol./pages unverified].
* Berto, F., French, R., Priest, G., & Ripley, D. (2018). Williamson on counterpossibles. *JPL* 47(4):693–713.
* Brewka, G., & Eiter, T. (2007). Equilibria in heterogeneous nonmonotonic multi-context systems. *AAAI-07*, 385–390.
* Brown, B., & Priest, G. (2004). Chunk and permeate, a paraconsistent inference strategy. Part I: The infinitesimal calculus. *JPL* 33:379–388.
* Brown, M. B., & Priest, G. (2015). Chunk and permeate II: Bohr's hydrogen atom. *Eur. J. Phil. Sci.* 5(3):297–314.
* Buvač, S., & Mason, I. A. (1993). Propositional logic of context. *AAAI-93*, 412–419.
* Cartwright, N. (1983). *How the Laws of Physics Lie*. OUP.
* de Kleer, J. (1986). An assumption-based TMS. *Artificial Intelligence* 28:127–162.
* Eiter, T., Fink, M., Schüller, P., & Weinzierl, A. (2014). Finding explanations of inconsistency in multi-context systems. *Artificial Intelligence* 216:233–274.
* Falkenhainer, B., & Forbus, K. D. (1991). Compositional modeling: finding the right model for the job. *Artificial Intelligence* 51:95–143.
* Fine, K. (1975). Vagueness, truth and logic. *Synthese* 30:265–300. [unverified]
* Forbus, K. D. (1984). Qualitative process theory. *Artificial Intelligence* 24:85–168.
* Friend, M., & Martínez-Ordaz, M. del R. (2018). Keeping globally inconsistent scientific theories locally consistent. In *Contradictions, from Consistency to Inconsistency*, Springer. [editors/pages unverified]
* Frigg, R., & Hartmann, S. Models in science. *Stanford Encyclopedia of Philosophy*. [revision date unverified]
* Frisch, M. (2004). Inconsistency in classical electrodynamics. *Phil. Sci.* 71. [pages unverified]
* Gärdenfors, P. (1986). Belief revisions and the Ramsey test for conditionals. *Phil. Review* 95. [pages unverified]
* Ghidini, C., & Giunchiglia, F. (2001). Local models semantics, or contextual reasoning = locality + compatibility. *Artificial Intelligence* 127(2):221–259.
* Giunchiglia, F., & Serafini, L. (1994). Multilanguage hierarchical logics. *Artificial Intelligence* 65:29–70. [unverified]
* Guha, R. V. (1991). *Contexts: A Formalization and Some Applications*. PhD thesis, Stanford (STAN-CS-91-1399).
* Heyninck, J., Verdée, P., & Heeffer, A. (2018). Handling inconsistencies in the early calculus: an adaptive logic for the design of chunk and permeate structures. *JPL* 47(3):481–511.
* Iwasaki, Y., & Simon, H. A. (1994). Causality and model abstraction. *Artificial Intelligence* 67. [unverified]
* Jaśkowski, S. (1948/1969). Propositional calculus for contradictory deductive systems. *Studia Logica* 24:143–157.
* Joyce, J. (1999). *The Foundations of Causal Decision Theory*. CUP. [unverified]
* Knuuttila, T., & Morgan, M. S. (2019). Deidealization: no easy reversals. *Phil. Sci.* 86(4):641–661.
* Laymon, R. (1985). Idealizations and the testing of theories by experimentation. In Achinstein & Hannaway (eds.), *Observation, Experiment, and Hypothesis in Modern Physical Science*, MIT Press/Bradford, 147–173.
* Laymon, R. (1987). Using Scott domains to explicate the notions of approximate and idealized data. *Phil. Sci.* 54(2):194–221.
* Laymon, R. (1989). Cartwright and the lying laws of physics. *J. Phil.* 86(7):353–372.
* Laymon, R. (1989). Applying idealized scientific theories to engineering. *Synthese* 81. [pages unverified]
* Laymon, R. (1995). Experimentation and the legitimacy of idealization. *Phil. Studies* 77:353–375.
* Levi, I. (1996). *For the Sake of the Argument*. CUP.
* Levins, R. (1966). The strategy of model building in population biology. *American Scientist* 54:421–431.
* Lewis, D. (1973). *Counterfactuals*. Blackwell. [unverified]
* Lewis, D. (1976). Probabilities of conditionals and conditional probabilities. *Phil. Review* 85. [unverified]
* Martínez-Ordaz, M. del R. (2022). Inconsistencies between theory and observation and the limits of chunk and permeate. [venue unverified]
* Massacci, F. (1996). Contextual reasoning is NP-complete. *AAAI-96*, 621–626.
* McCarthy, J. (1993). Notes on formalizing context. *IJCAI-93*, 555–560.
* McCarthy, J., & Buvač, S. (1998). Formalizing context (expanded notes). [venue unverified]
* McMullin, E. (1985). Galilean idealization. *Stud. Hist. Phil. Sci.* 16(3):247–273.
* Muller, F. A. (2007). Inconsistency in classical electrodynamics? *Phil. Sci.* 74. [unverified]
* Nayak, P. P. (1994). Causal approximations. *Artificial Intelligence* 70:277–334.
* Nayak, P. P. (1995). *Automated Modeling of Physical Systems*. Springer LNAI. [unverified]
* Nolan, D. (1997). Impossible worlds: a modest approach. *NDJFL* 38(4):535–572.
* Norton, J. D. (2012). Approximation and idealization: why the difference matters. *Phil. Sci.* 79(2):207–232.
* Odenbaugh, J., & Alexandrova, A. (2011). Buyer beware: robustness analyses in economics and biology. *Biol. & Phil.* 26(5):757–771.
* Priest, G. (1979). The logic of paradox. *JPL* 8:219–241. [unverified]
* Ramsey, J. L. (1990). Beyond numerical and causal accuracy: expanding the set of justificational criteria. *PSA 1990*, vol. 1, 485–499.
* Ramsey, J. L. (1992). Towards an expanded epistemology for approximations. *PSA 1992*, vol. 1. [pages unverified]
* Reiter, R. (1987). A theory of diagnosis from first principles. *Artificial Intelligence* 32:57–95. [unverified]
* Rescher, N., & Manor, R. (1970). On inference from inconsistent premisses. *Theory and Decision* 1:179–217.
* Schotch, P. K., & Jennings, R. E. (1980). Inference and necessity. *JPL* 9:327–340.
* Serafini, L., & Bouquet, P. (2004). Comparing formal theories of context in AI. *Artificial Intelligence* 155:41–67.
* Simon, H. A., & Ando, A. (1961). Aggregation of variables in dynamic systems. *Econometrica* 29(2):111–138.
* Stalnaker, R. (1968). A theory of conditionals. In Rescher (ed.), *Studies in Logical Theory*. [unverified]
* Strevens, M. (2008). *Depth: An Account of Scientific Explanation*. Harvard UP.
* Strevens, M. (2019). The structure of asymptotic idealization. *Synthese* 196:1713–1731.
* Van Dyke, M. (1964). *Perturbation Methods in Fluid Mechanics*. Academic Press. [unverified]
* Vickers, P. (2013). *Understanding Inconsistent Science*. OUP.
* Vovk, V., Gammerman, A., & Shafer, G. (2005). *Algorithmic Learning in a Random World*. Springer. [unverified]
* Weisberg, M. (2006). Robustness analysis. *Phil. Sci.* 73(5):730–742.
* Weisberg, M. (2007). Three kinds of idealization. *J. Phil.* 104(12):639–659.
* Weisberg, M. (2013). *Simulation and Similarity*. OUP. [unverified]
* Weld, D. S. (1990). Approximation reformulations. *AAAI-90*.
* Weld, D. S. (1992). Reasoning about model accuracy. *Artificial Intelligence* 56:255–300.
* Wilson, M. (2004). Theory façades. *Proc. Aristotelian Soc.* 104:273–288.
* Wilson, M. (2006). *Wandering Significance: An Essay on Conceptual Behavior*. OUP.
* Wilson, M. (2017). *Physics Avoidance: Essays in Conceptual Strategy*. OUP.
