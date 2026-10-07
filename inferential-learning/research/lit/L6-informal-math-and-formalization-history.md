# L6. Informal mathematics, its reliability, and the history of formalization viewed as a learning problem

Literature memo for the inferential-learning project. Strand L6. Written against the shared brief (`00-brief.md`, hypotheses H1-H7).

Verification convention. Statements whose bibliographic data or content I checked by web search during this session are cited plainly. Anything I could not check (because of the search budget, or because only my memory supports it) is marked **[unverified]** with what exactly is uncertain. Direct quotations are only given where a search result reproduced them; otherwise I paraphrase.

---

## 0. Executive summary (for the orchestrator)

1. **History supports a three-channel picture of the feedback that made informal mathematics converge, and it is not the two-channel picture of the brief.** The channels were: (a) *accepted proofs and accepted statements* (positive data, but **noisy**: many accepted steps were wrong, though usually fixable); (b) *coherence*, i.e. derivations of contradictions (paradoxes); and (c) by far the most informative channel, **counterexample objects**: specific functions, maps, polyhedra, manifolds and conic configurations in which a claimed step or theorem fails, plus numerical computation. Channel (c) is "world feedback" inside mathematics. It is much richer than a bag-level "⊥ was derived" signal, because an object can be evaluated at every intermediate line of a proof and so localizes blame. Lakatos's local/global counterexample distinction, Shapiro's contradiction backtracing and Easwaran's "convertibility" norm are three formulations of the same mechanism.

2. **Informal rules were average-case sound, not worst-case sound.** In almost every documented case (Cauchy's sum theorem, Ampère's differentiability "theorem", Dirichlet's principle, Steiner's 7776 conics, Kempe's four-colour argument, Lamé's FLT proof, Poincaré's 1900 homology claim), the faulty rule was correct on the "tame" or generic objects practitioners had in mind and failed on degenerate or pathological ones. Rigour was forced precisely when mathematicians became adversarial searchers over objects (Weierstrass, Peano, Russell). This strongly supports **H1** and refines it: the adversary that matters is a *monster generator over objects*, not only a prover over arguments.

3. **H5 is right in spirit but wrong in two specifics.**
   * "Separation is the minimal repair" of naive comprehension is false. There is no canonical repair. Incurvati and co-author (Mind 2017) show that there are multiple incompatible maximal consistent sets of instances of naive comprehension, none recursively axiomatizable (generalizing McGee's theorem for the T-schema).
   * Historically, ZF was selected by coverage of practice (Replacement was added in 1922 because Zermelo's 1908 system could not prove that ℵ_ω exists; the Axiom of Choice was defended in 1908 by pointing to its uses in practice), by a semantic *conception* (the cumulative hierarchy, Zermelo 1930), and by metatheoretic preferences (first-order logic; Ferreirós 2001).
   * Zermelo's own stated method is literally constrained optimization: restrict the principles "sufficiently to exclude all contradictions" and take them "sufficiently wide to retain all that is valuable". That is H5's objective, but the optimum is not unique and not computable. Coverage of practice, used as Lakatos's "heuristic falsifiers", does the selecting. A concrete example: NF refutes the Axiom of Choice (Specker 1953), so practice data that uses choice separates NF from ZFC.

4. **Lakatos's monster-barring is revision of the reading map ρ, not of the calculus R.** In the brief's (R, ρ) decomposition, every counterexample can be absorbed in R (lemma-incorporation, exception-barring), in ρ (monster-barring, monster-adjustment), or by extending the language (proof-generated concepts such as uniform convergence, ideals and the fundamental group). The R/ρ split is non-identifiable. Tanswell's "overgeneration" objection to the derivation-indicator view and DeDeo-Duede's "correspondence problem" are the static form of this. A learner that may revise ρ at no cost can absorb any counterexample (a Gold-like pathology). Revision costs are therefore needed, and MDL gives Lakatos's own preference ordering.

5. **The de Bruijn factor is evidence for the bounded-gap model in H5, with a caveat.** De Bruijn observed a roughly constant "loss factor" (he guessed 10-20) that does not grow through a book. Wiedijk measured an intrinsic (compressed) factor of about 4. But without a definitional library, sizes explode: Bourbaki's term for "1" has 4,523,659,424,929 symbols (Mathias 2002). MDL must therefore be computed over a library-structured representation.
   * Architecturally: if informal steps expand to boundedly many formal steps, step validity becomes decidable by bounded search. The learner should then learn to *propose expansions* (Draft-Sketch-Prove style) and not to judge validity directly. This turns per-step soundness risk into a single global risk: consistency and intended truth of the chosen calculus.

6. **For contexts (H6) the history offers a precise, proven bridge criterion.** Manders's exact/co-exact distinction for Euclid's diagrams says only properties stable under perturbation may be read off the model. Avigad-Dean-Mumma's system E is sound and complete for ruler-and-compass semantics. This is the template for physics export rules: export only what is stable under perturbation of the idealization parameters, and check that the actual situation lies in the stability neighbourhood. Steiner's error (Bézout count 6⁵ = 7776 instead of 3264) is a failure of exactly this genericity condition.

7. **Berkeley's "compensation of errors" is a warning for H6.** Outcome-level world feedback cannot distinguish a correct in-context calculus from one whose errors cancel. World feedback trains export rules; it does not certify in-context rules.

8. **Positive data are noisy.** The human corpus is a sample of *accepted and mostly fixable* steps, not of valid steps:
   * hundreds of small errors were corrected while formalizing Hales's Kepler proof (Avigad 2024);
   * a misquoted lemma surfaced in the crystalline-cohomology literature during the Lean FLT project (Buzzard, December 2024);
   * Lecat (1935) catalogued about 500 errors by 330 mathematicians.

   A conservative positive-data learner (H2, Remedy 1) that treats every human step as ground truth will internalize Euler-style and Italian-school-style rules. Coherence and object feedback must be able to *overrule* accepted steps. The right acceptance notion for informal proofs is closer to D'Alessandro's "corrigibility" than to "every step valid".

---

## 1. The history as a data-generating process

H5 treats formalization as learning. The first question is then what the data were. The table lists the best-documented episodes, classified by type of evidence, by what was revised, and by how and when the problem was caught. Dates and facts were checked unless marked otherwise.

| Episode | Faulty or informal rule | Negative evidence | How caught, lag | What was revised |
|---|---|---|---|---|
| Euclid's *Elements* | diagram-based inferences (intersections, betweenness) | gaps, not false theorems | Pasch 1882 (*Vorlesungen über neuere Geometrie*) identified tacit assumptions; Hilbert 1899 | language and axioms (order and continuity axioms); later system E (Avigad-Dean-Mumma 2009) recovers the diagram rules as a sound and complete calculus |
| Infinitesimal calculus | dividing by dx and then setting dx = 0 | logical criticism (Berkeley 1734, *The Analyst*: "ghosts of departed quantities"; compensation of errors) | no false results; criticism took about 100 years to bear fruit (Cauchy 1821, Weierstrass) | language (ε-δ); much later an alternative consistent semantics (Robinson 1966) |
| Euler, Basel problem (1735) | sin x treated as an infinite polynomial | none; *positive* numerical evidence (Euler had computed Σ1/n² ≈ 1.644934 in 1731) | n/a; justified about 100 years later via Weierstrass factorization | nothing; the rule was correct in this instance |
| Euler, ζ functional equation (E352, written 1749, published 1768) | divergent-series summation | none; Euler checked special values | Riemann 1859 proved it | language (analytic continuation) |
| Cauchy's sum theorem (*Cours d'analyse*, 1821) | a convergent series of continuous functions has a continuous sum | counterexample object: Fourier series (Abel 1826) | Abel 1826 ("exceptions"); Seidel and Stokes 1847 found the hidden lemma | proof-generated concept: uniform convergence (Lakatos's main appendix case) |
| Ampère 1806 | continuous functions are differentiable except at isolated points | counterexample: Weierstrass 1872 (Bolzano about 1830, unpublished) | 66 years | concept of function broadened; monsters accepted |
| Dirichlet principle (Riemann 1851/1857) | a minimizer of the Dirichlet integral exists | counterexample variational problem (Weierstrass 1870) | 13-19 years; Hilbert 1900-04 rescued the principle under boundary conditions | side conditions (lemma-incorporation); direct method |
| Steiner 1848, conics tangent to five conics | Bézout count 6⁵ = 7776 | a degenerate excess component (the Veronese surface of double lines) | de Jonquières 1859, Chasles 1864: 3264 | genericity and characteristics; much later excess intersection theory |
| Lamé 1847, FLT | unique factorization in cyclotomic integers | Kummer had shown in 1844 that it fails | weeks (Liouville and Kummer) | proof-generated concept: ideal numbers |
| Kempe 1879, four colours | a Kempe-chain case analysis | counterexample configuration (Heawood 1890) | 11 years | the proof salvaged as a five-colour theorem |
| Poincaré 1889, three-body prize memoir | stability argument | found while editing (Phragmén and Poincaré) | before publication | the correction discovered homoclinic tangles (Barrow-Green 1994, 1997) |
| Poincaré 1900 | homology characterizes S³ | counterexample object: the Poincaré homology sphere (1904) | 4 years | proof-generated concept: the fundamental group |
| Dehn 1910 | Dehn's lemma | gap (Kneser 1929) | 19 years; proved by Papakyriakopoulos 1957 | new technique (tower construction) |
| Dulac 1923 | finiteness of limit cycles | gap found by Ilyashenko in 1981 while lecturing | 58 years; Ilyashenko 1991, Écalle 1992 | very long new proofs; the original was "right in principle" |
| Italian school (Severi, from about 1930) | "principle of continuity" and similar | false results, rival school | Zariski, Weil (*Foundations of Algebraic Geometry*) | new foundations; De Toffoli and Fontanari (2022, 2023) on the "endless and depressing controversy" |
| Frege, *Grundgesetze* I (1893) | Basic Law V | paradox (Russell's letter of 16 June 1902; Frege's reply of 22 June) | 9 years | Frege's "way out" (1903) was itself inconsistent for domains with more than one object (Quine 1955): 52 years |
| Zermelo 1908 (Z) | no Replacement | coverage failure: ℵ_ω and {Z₀, P(Z₀), …} not provable | 14 years (Fraenkel and Skolem 1922) | axiom added |
| Kapranov-Voevodsky (1989-91) | ∞-groupoids model homotopy types | counterexample (Simpson, arXiv 1998) without localization of the error | 24 years before the authors accepted it (2013) | motivated univalent foundations (Voevodsky, IAS 2014 essay) |
| Wiles 1993 | Euler-system bound | referee questions (Katz) | 3 months to detection; fixed with Taylor in 1994 | new argument |
| Hales 1998, Kepler | massive computer-assisted case analysis | referees "99% certain" | Flyspeck finished 10 August 2014; *Forum of Mathematics, Pi* 2017; hundreds of small errors fixed (Avigad 2024) | full formalization |
| Lean FLT project (December 2024) | a lemma in the divided-power and crystalline literature misquotes Roby (1963) | formalization | decades; repaired via a different proof (Berthelot-Ogus appendix, pointed out by Conrad) | none needed in the theory |
| Jordan 1887 (counter-case) | Jordan curve theorem proof | the alleged error is folklore | Hales (2007) found "nothing objectionable"; critics "admitted to having no direct knowledge of an error" | **the error label itself was noise** |

Observations relevant to the learning model:

* **The dominant negative-data type is a counterexample object, not a contradiction.** Of the cases above, the paradoxes (Frege, and the Burali-Forti and Cantor antinomies) are the only pure "⊥-derivations". Most refutations came from a function, a series, a map configuration or a manifold. This matters for H2: a counterexample object M lets one evaluate every line of a proof in M, so it yields **instance-level** labels (see Section 3), while a ⊥-derivation yields only a bag-level label.
* **Many refutations were *available* long before they were *seen*.** Fourier series contradicting Cauchy's theorem existed from Fourier's own work. Lakatos's appendix stresses that the counterexamples were not recognized because "function" and "convergence" were in flux. In learning terms, whether a datum is negative depends on the current reading map ρ. Negative evidence is itself theory-laden.
* **Lag times are long and heavy-tailed:** weeks (Lamé), years (Kempe, Poincaré), decades (Dehn, Ampère, Dulac, Frege's way out, Kapranov-Voevodsky). Coherence and object feedback are sparse and delayed. Any guarantee in our project should therefore be time-uniform or anytime, not "after convergence".
* **Label noise exists in both directions.** Accepted-but-wrong proofs exist; so do "known errors" that are not errors (Jordan). Whether Cauchy's sum theorem was "false" is still disputed, because under an infinitesimal reading of his continuity and convergence it may come out true. See Lakatos's later "Cauchy and the continuum" **[unverified: exact venue and year, I believe 1978]** and the arXiv literature by Katz, Bascelli and others **[unverified authorship]**. An error is an error *relative to a reading map ρ*.
* **Base rates.**
  * Grcar (2013, *Notices AMS* 60:418-425) finds a 0.2% correction rate in AMS journals and argues that mathematical culture discourages publishing corrections.
  * Lecat (1935, *Erreurs de mathématiciens des origines à nos jours*) catalogues about 500 errors by 330 mathematicians.
  * Formalization projects suggest that small, fixable errors are ubiquitous.

  No reliable estimate exists of the fraction of invalid steps in accepted informal proofs. It is an open empirical question, and formalization projects (Flyspeck, the Liquid Tensor Experiment, FLT, Beeson-Narboux-Wiedijk's "Proof-checking Euclid" **[unverified: author list]**) could supply data for it.

---

## 2. Lakatos's *Proofs and Refutations* as a revision calculus

**Source.** Lakatos, *Proofs and Refutations: The Logic of Mathematical Discovery*, ed. J. Worrall and E. Zahar (Cambridge UP, 1976). It first appeared in four parts in *BJPS* 14 (1963-64) **[unverified: volume numbering]**. The main case is the Euler polyhedron conjecture V − E + F = 2 and Cauchy's 1813 proof. Appendix 1 treats Cauchy's sum theorem.

**The operators**, stated as moves of a learner whose state is (language L, concept definitions D, reading ρ, rules R, accepted statements S):

| Lakatos's move | What it does | Which component changes |
|---|---|---|
| Surrender | drop the conjecture | S |
| Monster-barring | redefine the concept so the counterexample is no longer an instance ("that is not a polyhedron") | D, i.e. the domain of ρ |
| Exception-barring | keep the theorem but list exceptions ("holds for all polyhedra except those with tunnels") | S (theorem with an exception clause) |
| Monster-adjustment | reinterpret the counterexample so it is no longer counter (re-read a star polyhedron's faces) | ρ on that instance |
| Lemma-incorporation | find the step the counterexample falsifies and add it as a hypothesis | S and R (theorem gets a new antecedent) |
| Proofs and refutations, with proof-generated concepts | name the hidden lemma as a new concept (uniform convergence, simple connectivity) | L (language extension) |

Lakatos's Rule 2 (verified wording): *"If you have a global counterexample discard your conjecture, add to your proof-analysis a suitable lemma that will be refuted by the counterexample, and replace the discarded conjecture by an improved one that incorporates that lemma as a condition."* He distinguishes **global** counterexamples (to the conclusion) from **local** ones (to a lemma or step), and studies the combinations "global but not local" (which reveals a hidden lemma), "local but not global" (the proof is wrong but the theorem survives), and "local and global".

**Mapping onto our setup.**

* *Blame assignment.* "Global but not local" is exactly the case where coherence or world feedback contradicts the conclusion while every explicit step looks fine. The defect is then an *unstated* step, an implicit rule application. In our terms, the human corpus contains invisible steps that ρ* elides, so the learner must posit them. This is the de Bruijn gap.
* *Convertibility.* Easwaran (2015, "Rebutting and undercutting in mathematics", *Philosophical Perspectives*) argues that published proofs must be detailed enough to convert a **rebutting** defeater (evidence that the theorem is false) into an **undercutting** defeater (identification of what is wrong with the proof). This is Lakatos's "global → local" move made into a norm. For us, convertibility is a *granularity requirement on proofs*: steps must be fine enough that a counterexample object can be evaluated on each line.
* *Algorithmic precedents.*
  * Shapiro's Model Inference System (1981 Yale tech report "Inductive inference of theories from facts"; *Algorithmic Program Debugging*, MIT Press 1983 **[unverified: report number and book year]**) contains the **contradiction backtracing** algorithm. Given a derivation of a false ground fact and an oracle for the truth of ground atoms, it walks back through the derivation tree to a clause that is false in the intended model. The aim is a finite set of true Horn clauses implying all true ground atoms and no false ones, which is H2 plus Remedy 2 in ILP form.
  * Pease, Colton, Smaill and Lee implemented Lakatos's methods (surrender, piecemeal exclusion, monster-barring, lemma-incorporation, monster-adjusting) in the multi-agent HRL system on top of Colton's HR theory-formation program (Pease, PhD thesis, Edinburgh 2007 **[unverified: year]**).
  * Pease, Lawrence, Budzynska, Corneli and Reed (2017, *Artificial Intelligence* 246:181-219) model Lakatos-style dialogues with structured argumentation.
* *Non-identifiability.* Monster-barring and monster-adjustment change ρ (what the words pick out). Lemma-incorporation changes the statement and, implicitly, the calculus. With both available, a single counterexample never forces a unique revision. This is the dynamic version of **Tanswell's overgeneration problem** (2015, *Philosophia Mathematica* 23(3):295-310): an informal proof corresponds to too many formal derivations. It is also the dynamic version of **DeDeo and Duede's correspondence problem** (*Philosophy of Science*, forthcoming; arXiv 2603.13680), which distinguishes "thin" correspondence (some derivation of the theorem exists) from "thick" correspondence (a derivation mirroring the human steps exists).
* *Why Lakatos disliked monster-barring.* If concept revision is free, every counterexample can be barred, the theorem's content shrinks silently, and the learner never revises its inferential practice. This is Gold's over-generality problem in a new place: the learner protects an over-general rule by shrinking its domain. **Design consequence:** revisions to D and ρ must carry a description-length cost, and exception lists must be paid for item by item. Under MDL, once several counterexamples share a short distinguishing predicate, introducing a named concept and incorporating it as a lemma is cheaper than an exception list. That is Lakatos's preference ordering, recovered as a theorem candidate (Section 8, TC7).

**Quasi-empiricism: Lakatos's two falsifier classes.** In "A renaissance of empiricism in the recent philosophy of mathematics" (*BJPS* 1976, drafted 1967, reprinted in *Mathematics, Science and Epistemology*, 1978 **[unverified: volume and pages]**), Lakatos classifies theories by the direction of truth-value flow:

* **Euclidean** theories transmit truth *downward* from axioms.
* **Quasi-empirical** theories retransmit *falsity upward* from false basic statements.

Formal mathematical theories have two kinds of potential falsifiers:

* **logical falsifiers**: inconsistencies, p ∧ ¬p;
* **heuristic falsifiers**: informal theorems or practice that the formal theory contradicts or fails to capture.

This is almost exactly the brief's pair "coherence + world feedback", with *informal mathematical practice playing the role of the world* for a formal theory. Section 4 shows that heuristic falsifiers did the real selecting in set theory.

---

## 3. How informal mathematics stayed reliable: mechanisms, mapped to coherence and world feedback

Philosophical accounts, briefly:

* **Azzouni's derivation-indicator view.** Azzouni (2004, "The derivation-indicator view of mathematical practice", *Philosophia Mathematica* 12(2):81-106): informal proofs *indicate* the existence of formal derivations, which explains why mathematicians converge on whether a proof is correct.
* **Tanswell's objection** (2015): overgeneration.
* **Hamami's "standard view"** (2022, "Mathematical rigor and proof", *Review of Symbolic Logic* 15(2):409-449; online 2019): a proof is rigorous iff it can be *routinely translated* into a formal proof. Hamami splits this into a normative part and a descriptive part (verification by a typical agent of the practice with commonly available resources), and gives an account of how mathematicians check and acquire that capacity.
* **Burgess** (*Rigor and Structure*, OUP 2015): rigor means careful derivation from the previous literature, with indifference to how that literature traces back to first principles. Structuralist features of mathematics are artifacts of this.
* **Rav** (1999, "Why do we prove theorems?", *Philosophia Mathematica* 7:5-41): proofs, not theorems, are the bearers of mathematical knowledge.
* **"Hilbert's thesis"** (the name follows a suggestion of Martin Davis): Barwise (1977, *Handbook of Mathematical Logic*) wrote that "the informal notion of provable used in mathematics is made precise by the formal notion provable in first-order logic." A Studia Logica paper, "Is there a 'Hilbert thesis'?" **[unverified: author, I believe R. Kahle]**, reviews this.
* **Avigad** (2021, "Reliability of mathematical inference", *Synthese* 198:7377-7399) defends the standard view and explains how practice *reliably and robustly* meets the formal standard. He uses an engineering analogy (systems that stay within tolerance despite imperfect parts), modularity, and abstraction (components specified by interface, not implementation). See also Avigad 2020, "Modularity in mathematics", *RSL* 13(1):47-79.
* **Larvor** (2022, "On the unreasonable reliability of mathematical inference", *Synthese* 200:332) replies that Avigad's strategies are agnostic between the standard view and its rivals.
* **Weatherall and Wolfson** (arXiv 2602.12463, 2026) argue that formal correctness is neither necessary nor sufficient for a proof's epistemic value.

The concrete mechanisms, and how each maps onto the project:

1. **Checking on examples (object feedback).** Weber and Mejía-Ramos (2011, "Why and how mathematicians read proofs: an exploratory study", *Educational Studies in Mathematics* 76 **[unverified: pages]**) found that research mathematicians reading published proofs typically: (i) rely on the reputation of author and journal; (ii) **check how particular steps apply to specific examples**; (iii) read for overarching ideas, and usually not to check correctness line by line. Item (ii) is world feedback at step level: each claim is evaluated in a sampled model of the context. This is the user's "verification from truth" ("check whether each claim is true in the context at hand"), practised with *one-sided error*. It can find falsity but never certifies truth, matching Lakatos's retransmission of falsity.

2. **Numerical computation as world feedback.** Euler's acceptance of π²/6 rested on numerical agreement to six decimals (computed in 1731, before the 1735 "proof"). His further confirmations included more series, more decimals and agreement with independently known results. His functional equation for the η/ζ function (E352) was checked at special values. Pólya (*Mathematics and Plausible Reasoning*, 2 vols, Princeton 1954) presents Euler as "a master of inductive research" who discovered "by observation, daring guess, and shrewd verification" **[unverified: which chapter treats the Basel case]**. Pólya's "patterns of plausible inference" (verifying a consequence raises credibility; an improbable consequence raises it more) are a qualitative Bayesian confirmation theory. In mathematics, world feedback means *computation*, as H4 says. History adds that computation was used to test *conjectural rules* (sin x as an infinite product), not only Π₁ statements. Brent (arXiv 2106.07269, 2021) catalogues published errors and how computer algebra (Maple, Sage) would have caught some.

3. **Redundancy: multiple independent derivations, and known results as a test suite.** A rule that also re-derives known results (Euler's product method re-deriving Leibniz's series π/4 = 1 − 1/3 + 1/5 − ...) is corroborated. This is *path-independence coherence*: different derivations of the same quantity must agree. It is stronger and more local than "never derive P and ¬P" and is easy to operationalize (a commutative-diagram check over derivations).

4. **Modularity, abstraction and fixability.** Errors stay local because lemmas have clean interfaces (Avigad).
   * Fixability is the actual acceptance criterion. D'Alessandro ("Transferable and fixable proofs", *Episteme*, 2023/24) argues that transferability (a typical expert is convinced from the proof alone) conflicts with the fact that acceptable proofs contain errors, and replaces it with **corrigibility**: errors can be fixed by experts without significant new mathematics.
   * Easwaran (2009, "Probabilistic proofs and transferability", *Philosophia Mathematica* 17:341-362) uses transferability to explain why mathematicians reject probabilistic proofs.
   * Fallis (2003, "Intentional gaps in mathematical proofs", *Synthese* 134:45-69) and Andersen ("Acceptable gaps in mathematical proofs", *Synthese* **[unverified: 2020, vol. 197]**) analyse which gaps are acceptable.
   * Baaz and Gamsakhurdia (arXiv 2609.18486, 2026) give an ε-calculus analysis of "false-tolerant" incorrect or incomplete proofs and of conditions for semantic repair. This is a formal handle on corrigibility.

5. **Usage track record.** In Buzzard's FLT post (11 December 2024), it was "absolutely clear" that the crystalline-cohomology results would be fixable even though an intermediate lemma was false, because the theory "has been used so much since the 1970s that if there were a problem with it, it would have come to light a long time ago." This is inductive reliability from heavy use. Caveat for our learner: use concentrated in tame cases does not test monster cases (see 6).

6. **Restricting inference to robust features (co-exactness).** Manders ("The Euclidean diagram", written 1995, published in Mancosu (ed.), *The Philosophy of Mathematical Practice*, OUP 2008 **[unverified: pages]**):
   * Euclid uses diagrams only for **co-exact** attributes, those unaffected by some range of every continuous variation of the diagram (containment, existence of intersections).
   * **Exact** attributes (equality, straightness) must be derived in the text.

   This explains why diagram reasoning was reliable despite imprecise drawings. Avigad, Dean and Mumma (2009, "A formal system for Euclid's Elements", *RSL*; arXiv 0810.4315) built a system E with co-exact diagrammatic inferences that is **sound and complete for a standard semantics of ruler-and-compass constructions** and models Books I-IV faithfully. **This is the cleanest case in the whole history of an informal inferential practice turning out to be a latent sound calculus (H5's R\*), recovered by studying the practice.** Its reliability mechanism, stability under perturbation, is exactly what H6 needs for physics export rules.

7. **Social process and adversarial scrutiny.**
   * De Millo, Lipton and Perlis (1979, "Social processes and proofs of theorems and programs", *CACM* 22(5):271-280 **[unverified: pages]**): proofs become believed through a social process of reading, doubting, simplifying, generalizing and using.
   * Thurston (1994, "On proof and progress in mathematics", *Bull. AMS* 30(2):161-177): "the reliability does not primarily come from mathematicians formally checking formal arguments; it comes from mathematicians thinking carefully and critically about mathematical ideas", and "people are usually not very good in checking formal correctness of proofs, but they are quite good at detecting potential weaknesses or flaws in proofs."
   * Refereeing caught Wiles's gap (Katz) and Poincaré's (Phragmén).
   * Jaffe and Quinn (1993, *Bull. AMS* 29(1):1-13) argued that speculative "theoretical mathematics" is dangerous without labelling, citing reliability failures. The responses (*Bull. AMS* 30, 1994) include Thurston's essay.

   For us, the social channel is an *ensemble of semi-independent verifiers plus deliberate adversaries*. Thurston's point that humans are good at locating *potential weaknesses* suggests training a "weak-point detector" (which steps are most likely to hide a monster) separately from a step-validity checker.

**What this means for H1.** Every mechanism above except formal checking is *average-case*: sampling examples, numerics on typical inputs, track record on typical uses. The documented failures sit exactly where the average case and the worst case come apart: degenerate configurations (Steiner), pathological functions (Ampère, Cauchy), arbitrary sets (Frege), non-generic dynamics (Dulac). Informal practice survived because human search was guided by intended, tame models and was *not* adversarial. Rigour arrived when mathematicians *became* adversarial over objects (Weierstrass's function, Peano's curve, Russell's set). A learned verifier trained on human steps will inherit the tameness assumption. A strong prover searching against it will find the monsters. So H1 is confirmed historically, and the adversary class should explicitly include *object (counterexample) generators*.

---

## 4. Could an MDL + coverage + coherence learner have "discovered" ZF from pre-1900 practice?

**What practice looked like.**
* Cantor's and Dedekind's set practice formed sets by specific operations: subsets defined by a property of elements of a given set, power sets, unions, images under maps, and choice (implicitly).
* Naive comprehension came from logicians (Frege's Basic Law V, Russell), as a compression of the notion of extension, not from mathematicians' usage.
* Cantor's own 1899 letters distinguished "consistent" from "inconsistent multiplicities" **[unverified: dating details]**.

Zermelo's methodology was explicitly data-driven. In the 1908 *Mathematische Annalen* paper (vol. 65:261-281) he says the principles must be restricted "sufficiently to exclude all contradictions and, on the other, take them sufficiently wide to retain all that is valuable in this theory". He also says one must start "from set theory as it is historically given" **[unverified: exact wording, from van Heijenoort's translation as I recall it]**. In the same year, defending choice in "Neuer Beweis für die Möglichkeit einer Wohlordnung", he pointed out that his critics (Borel, Baire, Lebesgue, Bernstein, Schoenflies) had used the principle themselves (Moore, *Zermelo's Axiom of Choice*, 1982). That is coverage of accepted proofs used as evidence for an axiom.

Related statements of "axioms by their consequences":
* Russell's 1907 lecture "The regressive method of discovering the premises of mathematics" (published posthumously in 1973): "we tend to believe the premises because we can see that their consequences are true, instead of believing the consequences because we know the premises to be true", and "inferring premises from consequences is the essence of induction".
* Gödel (1947, "What is Cantor's continuum problem?", *Amer. Math. Monthly* 54): axioms "so abundant in their verifiable consequences … that quite irrespective of their intrinsic necessity they would have to be assumed at least in the same sense as any established physical theory."
* Dedekind's letter to Keferstein (27 February 1890) asks for "the mutually independent fundamental properties of the sequence N … from which all others follow", i.e. irredundant axioms that cover practice.
* Gentzen (1935) designed natural deduction as "a formalism that comes as close as possible to actual reasoning". That is imitation learning of inference rules, done by hand.

Together these are the historical form of the user's "Solomonoff axiom induction" note.

**Step-by-step assessment of H5's story.**

1. *MDL picks naive comprehension (NC).* Plausible. One schema covers every set-formation instance in practice and gives the shortest derivations. Frege's choice of Basic Law V is exactly this economy.
2. *Coherence refutes NC.* Yes, and cheaply: Russell's derivation is a few lines. Zermelo found it independently, by 1902 and possibly from 1899 (Husserl's 1902 note; Rang and Thomas 1981, *Historia Mathematica*). A learner that actively searches for ⊥ would find it at once. So the learner would do *at least* as well as history here.
3. *"Separation is the minimal repair."* **False as stated.** There is no canonical repair:
   * **Incurvati and co-author**, "Maximally consistent sets of instances of naive comprehension", *Mind* 126(502):371-384 (2017) **[unverified: co-author, I believe Julian J. Schlöder]**: there are *multiple incompatible* maximal consistent sets of instances of NC, and under minimal assumptions *none is recursively axiomatizable*. This generalizes **McGee's theorem** for instances of Tarski's T-schema **[unverified: McGee 1992, J. Phil. Logic 21]**. The paper also notes that the "restrict NC by consistency maxims" view goes back to Quine and perhaps to Zermelo 1908, and argues the view is untenable for exactly these reasons.
   * The neo-Fregean analogue is the "embarrassment of riches" objection (Weir 2003, *Notre Dame J. Formal Logic* 44(1):13-48): there are consistent but pairwise inconsistent abstraction principles.
   * Even plausible-looking "minimal" syntactic repairs can be subtly inconsistent. Frege's 1903 "way out" proves there is at most one object (Quine 1955, *Mind* 64:145-159), and this was found 52 years later.

   Separation is also not *maximal* among consistent restrictions. It is one *uniformly specified* restriction ("φ(x) ∧ x ∈ a"), and stratification (NF), positive comprehension, type restriction and limitation of size are others.
4. *What actually selected ZF(C):*
   * (i) **coverage of practice as heuristic falsifiers**: Replacement added by Fraenkel and Skolem in 1922 because Z does not prove that ℵ_ω exists, and choice kept because practice uses it;
   * (ii) a **semantic conception**: Zermelo's 1930 cumulative hierarchy ("Über Grenzzahlen und Mengenbereiche") and later the iterative conception (Boolos 1971) **[unverified: details of both]**;
   * (iii) **metatheoretic preferences**: Skolem's first-order formulation and the consolidation of first-order logic driven by axiomatics, foundational insecurity and the metatheorems of the 1930s (Ferreirós 2001, "The road to modern logic", *BSL* 7(4):441-484).

   A concrete example of practice data separating two coherent repairs: **Specker (1953) proved NF ⊢ ¬AC** **[unverified: citation details, PNAS 39]**. Practice relies on AC, so coverage of practice rejects NF in favour of ZFC even though both are presumably consistent.
5. *Residual risk.* By Gödel's second incompleteness theorem the learner can never certify the consistency of its chosen system from inside it. Consistency is Π₁: refutable in finite time when false, never verifiable. So the learner's confidence in ZF is inductive, resting on track record and the conception. This is Kelly's "verifiable vs refutable in the limit" topology in its purest form, and it fits H4.

**Verdict on question (1).** A learner with an MDL prior over *uniformly specified schema restrictions*, active ⊥-search, and practice coverage as a constraint would plausibly reproduce the sequence: NC, then refutation, then a family of candidate repairs. It would select among those repairs only through further practice data (AC usage, large constructions such as ℵ_ω) and some prior over conceptions. The output is identifiable at best up to *coverage-equivalence on the practice fragment* (ZFC, NBG and type theory with enough axioms are largely inter-interpretable on ordinary mathematics). This matches H7's non-identifiability. The selection between equivalent systems was made on metatheoretic and conceptual grounds that are not part of "fitting proofs".

**What else a learner that "would have worked before formalization" must do, judged against the whole history:**

1. **Extend the language.** The decisive historical moves were new concepts (ε-δ quantifier structure, uniform convergence, ideals, fundamental group, set). Learning (R, ρ) over a fixed L cannot reproduce them. The learner needs a concept-invention operator, triggered by blame localization: name the hidden lemma. The user's note says "math was formalized by inventing a language into which proofs can be translated, not by translating proofs word for word". History strongly supports this. The constant de Bruijn factor (Section 5) says that once the right language exists, translation is cheap.
2. **Have objects.** It must be able to generate and evaluate examples and counterexamples (finite structures, numerics, diagrams). This was the main negative-data channel.
3. **Contain an adversary over objects** (the Weierstrass role).
4. **Use practice coverage to select among coherent repairs** (the Fraenkel and Zermelo roles).
5. **Treat the positive corpus as noisy and corrigible**, not as ground truth.
6. **Accept anytime fallibility.** Coherence feedback can arrive decades late (Frege's way out, Dulac, Kapranov-Voevodsky). Acceptance thresholds should be time-uniform (H1's Ville-inequality suggestion is apt).
7. **End by outputting a formal system** with bounded expansion and no known inconsistency. At that point verification becomes exact and learning moves to the reading map ρ (autoformalization).

---

## 5. The de Bruijn factor and autoformalization: quantitative anchors for ρ*

* **De Bruijn's "loss factor".** For AUTOMATH, de Bruijn estimated the size ratio of a meticulous formal version to ordinary mathematics at "something like 10 or 20", and stressed that it is **constant**: it does not grow as one moves through a book. Jutting's AUTOMATH translation of Landau's *Grundlagen der Analysis* (thesis 1977 **[unverified: year]**) is the classic measured case.
* **Wiedijk, "The De Bruijn Factor"** (manuscript, about 2000 **[unverified: year]**): the ratio of formal size to informal size. The "apparent" factor uses raw file sizes; the "intrinsic" factor uses compressed sizes. For his three examples the intrinsic factor is about 4. It depends on how much detail the original contains and on the expressivity of the formal system.
* **Mathias** (2002, "A term of length 4,523,659,424,929", *Synthese* 133:75-86): Bourbaki's definition of the number 1, written out in Bourbaki's τ-based formal language, has 4,523,659,424,929 symbols plus 1,179,618,517,981 disambiguating links. Bourbaki had estimated "some tens of thousands".

**Lessons for H5.** (a) The constancy of the factor is evidence for the "bounded gap" model: informal steps are images of boundedly long derivations, given a growing library of definitions and lemmas. (b) Mathias's number shows the bound holds *only relative to a definitional/abbreviation mechanism*. MDL over a flat calculus gives absurd results; the hypothesis space must be library-structured, with definitions as compression. (c) The factor depends on the formal system's expressivity, which is another way the latent calculus is non-unique (a ZF-based ρ and a type-theory-based ρ give different factors on the same corpus).

**Autoformalization as learning ρ.**
* Wang, Kaliszyk and Urban (2018, CICM, LNCS 11006:255-270): neural translation of "informalized" Mizar into Mizar. 65.73% of statements correct for the best model; 79.17% for the union of models.
* Szegedy (2020, "A promising path towards autoformalization and general artificial intelligence", CICM, LNCS 12236) argues for autoformalization bootstrapped from unlabeled data as a path to general reasoning.
* Wu, Jiang, Li, Rabe, Staats, Jamnik and Szegedy (2022, "Autoformalization with large language models", NeurIPS): 25.3% of competition problems translated perfectly into Isabelle/HOL; miniF2F proof rate improved from 29.6% to 35.2%.
* Jiang et al. (2023, "Draft, Sketch, and Prove", ICLR) use informal proofs as sketches that guide a formal prover. **This is the derivation-indicator view operationalized**: the informal proof indicates a derivation, and a bounded search finds it.
* Sieg and Walsh (2019, "Natural formalization: deriving the Cantor-Bernstein theorem in ZF", *RSL*) argue for formalizations that preserve the informal proof's structure, which is "thick correspondence" in DeDeo and Duede's sense.
* A recent arXiv paper (2608.28997, 2026, "Verification abundance, adjudication scarcity" **[unverified: authors; empirical claims not checked]**) separates three layers: derivational validity (mechanizable), representational fidelity (whether the formal statement means the informal question, which it argues cannot be mechanized even in principle), and epistemic significance. It argues that cheap kernel checking shifts the burden onto the fidelity layer. For our project, fidelity is exactly the ρ-learning problem, and it is where coherence and object feedback must operate once R is fixed.
* The Liquid Tensor Experiment (Scholze's challenge, December 2020). Scholze's June 2021 report said the experiment "has verified the entire part of the argument that I was unsure about", after he and Clausen had been "99.9%" sure. The project was completed 14 July 2022. This shows formalization used as the decisive "world feedback" for a single high-stakes informal proof.

---

## 6. Calculus, inconsistent foundations, and contexts (chunk and permeate)

**The phenomenon.** From Newton and Leibniz to Cauchy, analysts reasoned reliably with infinitesimals that were treated as nonzero (to divide by them) and as zero (to discard them). Berkeley (1734) made the inconsistency explicit, called the evanescent increments "ghosts of departed quantities", and explained the correct results by a **compensation of errors**: two mistakes that cancel, so that analysts arrive "though not at science, yet at truth". The infinitesimal method also produced paradoxes under careless use. Torricelli catalogued them in *De indivisibilium doctrina perperam usurpata*, e.g. two triangles of equal area "composed" of equally many indivisibles of unequal length. Practitioners kept the method and learned informal restrictions on it (Mancosu, *Philosophy of Mathematics and Mathematical Practice in the Seventeenth Century*, OUP 1996, chs. 3 and 5).

**Formal reconstructions.**
* Brown and Priest (2004, "Chunk and permeate, a paraconsistent inference strategy. Part I: the infinitesimal calculus", *J. Phil. Logic* 33:379-388): the reasoning is split into chunks (in one, dx ≠ 0 and we divide; in another, dx = 0). Only certain results permeate between chunks, so no chunk is trivialized.
* Part II treats Bohr's atom (Brown and Priest 2015, *Euro. J. Phil. Sci.*).
* Heyninck, Verdée and Heeffer (2018, "Handling inconsistencies in the early calculus: an adaptive logic for the design of chunk and permeate structures", *J. Phil. Logic* 47(3):481-511) criticize C&P's ad hoc permeation relation. They replace it with an adaptive logic that **permeates formulas conditionally, on the assumption that consistency is preserved**, and withdraws them when that assumption fails.
* Vickers (*Understanding Inconsistent Science*, OUP 2013) argues that many alleged "inconsistent theories" (early calculus, Bohr) are better seen as consistent fragments used in turn, with no inconsistent belief.
* Robinson's non-standard analysis (1966) later gave a *consistent* semantics for Leibnizian reasoning (via a transfer principle). So the same informal practice is the shadow of at least two different consistent calculi (Weierstrassian ε-δ, Robinsonian). This is non-identifiability of R\* again.

**Mapping to H6 (contexts).**
1. C&P is a *description* of good practice. The hard learning problem is the **permeability relation** (what may cross between contexts). Heyninck et al.'s adaptive default, "permeate unless that produces inconsistency in the receiving chunk", is a principled, learnable default and fits H6's "coherence on exported claims".
2. **Dirichlet's principle as an idealized context.** "Assume the minimizer exists" is false in general (Weierstrass 1870) but true in the cases Riemann needed (Hilbert 1900-04). Conclusions drawn inside the idealized context were true because the assumption held *in the relevant instances*. This is the mathematical twin of "assume air pressure is 0": a learner must track the **scope** in which an idealizing assumption holds, not its universal truth. A context that is technically contradictory with background knowledge (as in the user's physics example) is acceptable if exported conclusions are stable over the actual instances.
3. **Steiner's error is a failed bridge.** The Bézout count is valid only under a genericity (transversality) condition. The configuration violates it because there is an excess component, so the "export" from a generic count to the actual count fails. Manders's co-exactness, which says to read off the model only what survives perturbation, is the corresponding positive criterion. It gives H6 a precise form for "stability certificates" (TC5).
4. **Compensating errors (Berkeley).** World feedback on final answers cannot distinguish a correct calculus from one whose mistakes cancel. In H6's division of labour ("coherence trains in-context rules, world feedback trains export rules"), world feedback is *not even in principle* able to validate in-context rules. Validating them needs internal coherence or intermediate observables (models or simulations evaluated at intermediate claims).

---

## 7. Kreisel's informal rigour, and what "pinning informal validity" can and cannot mean

Kreisel (1967, "Informal rigour and completeness proofs", in Lakatos (ed.), *Problems in the Philosophy of Mathematics*, North-Holland **[unverified: pages 138-186]**) introduced the **squeezing argument**. Let D be first-order derivability, Val intuitive validity (truth in all structures, in the informal sense), and V model-theoretic validity (truth in all set-sized structures). Then D ⊆ Val (soundness is intuitively evident) and Val ⊆ V (set structures are among all structures), while completeness gives V ⊆ D. Hence all three coincide extensionally.

See also P. Smith (2011, "Squeezing arguments", *Analysis* 71(1) **[unverified: pages 22-30 vs 23-30]**), who extends the idea to Church's thesis, and Dean and Kurokawa ("On the methodology of informal rigour: set theory, semantics, and intuitionism", *J. Phil. Logic* **[unverified: year]**), who reconstruct Kreisel's three examples and compare informal rigour with Carnapian explication.

**Refinement of H5's use of Kreisel.** Squeezing needs (i) a provably sound lower bound, (ii) an independently motivated semantic upper bound, and (iii) a completeness theorem closing the gap. All three hold for *logical* validity. None holds for *mathematical truth* (arithmetic or set theory): by incompleteness, no r.e. D captures truth in the intended model. So Kreisel shows how the *logic* part of informal validity is pinned. The *axioms* part (which rules R count as valid mathematical inference beyond logic) cannot be squeezed. That is exactly the part Sections 2 and 4 found non-identifiable, and it is settled by coverage, coherence, conception and track record. A learner can therefore hope for a squeeze-style identification theorem for the *logical core* of its validity relation (for example, if V̂ is sound for all models of the context and complete for a recognizable class, it equals derivability). It cannot hope for one for its *mathematical* axioms.

---

## 8. Theorem candidates and design ideas suggested by this strand

**TC1. Counterexample-to-blame conversion (Lakatos-Shapiro-Easwaran).**
* *Setting:* a derivation DAG π proving φ from context Γ by rule instances, and a counterexample object M ⊨ Γ, M ⊭ φ, with an evaluation oracle for M ⊨ ψ on each node formula ψ.
* *Claim (easy):* some node v has all parents true in M and v false in M. It is found by descending from the root along false parents in ≤ depth(π) steps, with ≤ Σ(fan-in along the path) oracle calls. The rule instance at v is then refuted *with a witness model*, and M can be stored and replayed against every other instance of the same schema (a "monster library").
* *Learning consequence to prove:* with a counterexample oracle plus an evaluation oracle, a finite class 𝓡 of rule schemas is learnable with O(log|𝓡|) counterexamples by halving over consistent schema sets. That matches Angluin-style query learning and Shapiro's MIS. With only ⊥-derivations and no model, the labels are multiple-instance bags, and the mistake bound degrades by up to the bag size in the worst case.
* *Message:* the brief's coherence-as-negative-bag (H2, Remedy 2) is strictly weaker than object feedback. The system should generate models (finite structures, numerics, simulations), not only search for ⊥. Easwaran's convertibility is the step-granularity condition under which TC1 applies.

**TC2. No canonical coherent repair, and selection by coverage in the limit.**
* *Known:* Incurvati et al. (2017) and McGee (1992): maximal consistent subsets of an inconsistent schema are non-unique and non-r.e.
* *Candidate project theorem:* let H be a class of *uniformly specified* restrictions of a schema with finite elasticity (Wright 1989; Motoki-Shinohara-Wright 1991 for bounded unions **[unverified: exact citations]**). Let the practice-data stream be **separating**: any two coherent, coverage-inequivalent h, h′ ∈ H are distinguished by some practice item derivable from one and not the other. Then an MDL learner that dovetails ⊥-search and discards refuted hypotheses identifies in the limit a coherent h of maximal practice coverage, if one exists in H. Inconsistency is semi-decidable and the class has finite elasticity, so each wrong hypothesis is eventually abandoned.
* *Illustration:* the NF vs ZFC split via AC (Specker).
* *Negative companion:* without the uniformity restriction, i.e. over arbitrary instance sets, no computable learner converges (from non-r.e.-ness).

**TC3. Bounded expansion ⇒ certificate learning (the "de Bruijn-bounded" architecture).**
* If every accepted informal step s expands under ρ* to a derivation of length ≤ c·|s| + c₀ over library Λ, then step validity relative to (R*, Λ) is decidable by bounded search.
* A learner that outputs expansions which are checked (Draft-Sketch-Prove) is **sound by construction against adversarial search**, so H1 holds for free at the step level.
* The remaining risk is global: consistency and intended truth of R* ∪ Λ.
* *Pre-formal version:* the learner hypothesizes (R, ρ) and verifies by bounded search in R. Its soundness reduces to the soundness of R, which TC2-style dynamics (coherence, coverage, object feedback) manage over time.
* *Message:* "learn to formalize, check exactly" dominates "learn to judge validity" whenever a bounded expansion exists. The de Bruijn evidence says one does, relative to a good library.

**TC4. Noisy positives.** Formalize "accepted ≠ valid":
* The corpus is drawn from a distribution over accepted steps in which a fraction η is invalid but fixable (each has a nearby valid replacement within edit distance k).
* A conservative positive-data learner (closure or least general generalization) then converges to an over-general rule set that includes invalid schemas whenever η > 0 on a schema's support.
* A learner that allows coherence and object feedback to *veto* accepted steps, with repair via TC1, converges to the valid rules plus a repair map.
* This makes D'Alessandro's corrigibility the target notion of acceptance.

**TC5. Co-exact reading is sound (bridge criterion for H6).**
* *Setting:* a context with a parametrized model family {M_θ}, an idealized θ₀, and a reading that extracts only properties holding on an open neighbourhood U of θ₀ (co-exact), deriving all other properties by rules valid in every M_θ.
* *Claim:* conclusions hold for every θ ∈ U. Exporting to the actual θ* is licensed iff θ* ∈ U. That membership is the stability certificate.
* Avigad-Dean-Mumma's soundness and completeness of E is a proven instance for Euclidean diagrams. Steiner's 7776 is the canonical violation: the count is "exact", and the degenerate locus breaks openness.
* For physics: "set air pressure to 0" may be exported for quantity Q only with a modulus-of-continuity bound on Q in the pressure near 0, plus the actual pressure.

**TC6. Outcome-only feedback cannot identify in-context rules.** If two calculi agree on all exported observables they are indistinguishable by world feedback (Berkeley's compensation of errors is a historical witness). *Corollary:* to train in-context rules from the world you need **intermediate observables**, e.g. model or simulation checks of intermediate claims. That is the physics analogue of "check the step on an example".

**TC7. Revision costs and Lakatos's preference ordering.**
* With free ρ-revision (monster-barring), any counterexample sequence can be absorbed without changing R, so the learner can fail to converge to the right R while staying "coherent".
* Charge description length for concept definitions and per-item exception lists. Then after k counterexamples that share a predicate of description length ≤ ℓ (with k ≫ ℓ), lemma-incorporation with a new named concept strictly beats exception-barring and monster-barring.
* Proof-generated concepts are the MDL-optimal response to clustered counterexamples. This could be formalized in the style of "Occam with exceptions".

**Design ideas.**
* (a) Learner state à la **Kitcher**. *The Nature of Mathematical Knowledge* (OUP 1984) represents a practice as ⟨L, M, Q, R, S⟩: language, metamathematical views, questions, accepted reasonings, accepted statements. Change happens through "interpractice transitions" (question-answering, question-raising, generalization, rigorization, systematization) that restore concordance among the components. R is literally our inference-rule set, and rigorization appears as one transition type among several, triggered by discord. Kitcher's 1981 paper "Mathematical rigor—who needs it?" (*Noûs* 15(4):469-493) argues that rigour is adopted when existing methods stop answering pressing questions reliably **[unverified: my paraphrase of the paper's central example, 19th-century series questions]**. In learning terms: rigorize *on demand*, when the question distribution shifts toward regions where learned rules are unreliable.
* (b) Train on **revision traces** (errata, Lakatos-style dialogues, MathOverflow corrections, formalization-discovered errors), not only on accepted proofs.
* (c) A **monster generator** adversary over objects, plus a **weak-point detector** (Thurston: people are good at finding potential flaws).
* (d) **Path-independence coherence**: different derivations of the same quantity must agree. This is cheap, local and historically central (Euler).
* (e) **Library-structured MDL**, with definitions as compression (the Mathias lesson).
* (f) **Time-uniform acceptance**, since coherence feedback can arrive decades late.

---

## 9. Where the brief's hypotheses need correction or refinement

* **H1 (worst-case soundness).** *Supported.* Refinement: the historically relevant adversary searches over *objects* (counterexamples) as well as arguments. Human informal rules were sound on tame or generic objects only. Rigour became necessary when search turned adversarial.
* **H2 (positive data; coherence as negative data).**
  * (i) The positive data are *noisy*: accepted is not valid, and the error is fixable but real. Gold-conservative learners will internalize invalid rules. Coherence must be able to veto positives (TC4).
  * (ii) Coherence via ⊥ is a weak negative channel. The main historical channel was *counterexample objects*, which give instance-level blame (TC1). Add model generation and evaluation to the design.
* **H4.** *Supported*, and history adds a third selector besides minimality and world feedback: **coverage of practice** (Lakatos's heuristic falsifiers), which chose among coherent set theories (Replacement in 1922; AC versus NF).
* **H5.** *Partly wrong in specifics.*
  * Naive comprehension was a logicians' principle, though MDL would indeed pick it.
  * Separation is not "the minimal repair": maximal consistent repairs are non-unique and non-r.e. (Incurvati et al. 2017).
  * ZF was selected by coverage, conception and metatheory.
  * Model monster-barring as ρ-revision and add revision costs (TC7).
  * The latent calculus is identifiable only up to coverage-equivalence (Weierstrass vs Robinson; ZFC vs type theory).
  * Euclid plus system E is the best existing *proof of concept* that a latent sound and complete calculus can be extracted from an informal practice.
  * Kreisel's squeeze pins down logical validity but not mathematical axioms (Section 7).
* **H6.** *Supported, with a sharper bridge criterion:* co-exactness or stability (Manders, ADM; TC5). Also a warning: world feedback cannot certify in-context rules (Berkeley; TC6). Heyninck et al.'s conditional permeation is a principled default for chunk-and-permeate. Idealized contexts that are false in general can be legitimately used where the assumption holds in the relevant instances (Dirichlet principle).
* **H7.** History gives concrete Kripkensteinian cases: whether Cauchy's theorem was "false" depends on how one reads his concepts, and Jordan's proof was accused without evidence. *Community practice* did real selecting work: Zermelo justified AC by its use in practice. Simplicity alone did not settle ZF versus its rivals.

---

## 10. Reference list (with verification status)

Checked by search during this session, for title, venue and year, and for content where cited:
Lakatos, *Proofs and Refutations* (CUP 1976; Rule 2 wording); Lakatos, "A renaissance of empiricism…" (falsifier classes; venue partly unverified); Zermelo 1908, *Math. Ann.* 65:261-281 (methodology sentence); Moore 1982 (AC and critics' implicit use); Fraenkel and Skolem 1922 (Replacement, ℵ_ω); Zermelo's independent discovery of the paradox (Husserl note; Rang and Thomas 1981); Russell-Frege letters 16 and 22 June 1902; Quine 1955, *Mind* 64:145-159; Russell 1907 regressive method (quote); Gödel 1947 (quote); Dedekind's letter to Keferstein 1890; Gentzen 1935; Kreisel 1967 (squeezing); Smith 2011; Dean and Kurokawa; Brown and Priest 2004, *JPL* 33:379-388; Brown and Priest 2015; Heyninck, Verdée and Heeffer 2018, *JPL* 47(3):481-511; Vickers 2013; Berkeley 1734 (quotes); Mancosu 1996; Torricelli's paradoxes; Cauchy, Abel, Seidel and Stokes; Euler Basel numerics; Euler E352; Ampère 1806 and Weierstrass 1872; Dirichlet principle (Riemann, Weierstrass 1870, Hilbert 1900-04); Steiner 7776 and Chasles/de Jonquières 3264; Lamé and Kummer; Kempe and Heawood; Poincaré 1889 and Barrow-Green; Poincaré homology sphere; Dehn, Kneser and Papakyriakopoulos; Dulac, Ilyashenko and Écalle; De Toffoli and Fontanari 2022 (*Noesis*) and 2023; Voevodsky (IAS 2014); Wiles and Katz; Hales, Flyspeck and *Forum of Math. Pi* 2017; Avigad 2024, *Bull. AMS* 61:225-240; Scholze's LTE posts (2021) and completion (2022); Buzzard's FLT blog post (11 Dec 2024); Hales 2007 (Jordan); Grcar 2013, *Notices* 60:418-425; Lecat 1935; Brent 2021 arXiv; Wiedijk "The de Bruijn Factor" (≈4); de Bruijn loss factor (10-20, constant); Mathias 2002, *Synthese* 133:75-86; Wang, Kaliszyk and Urban 2018 (65.73% / 79.17%); Szegedy 2020; Wu et al. 2022 (25.3%; 29.6→35.2%); Jiang et al. 2023 (DSP); Sieg and Walsh 2019; DeDeo and Duede (arXiv 2603.13680); Weatherall and Wolfson (arXiv 2602.12463); Baaz and Gamsakhurdia (arXiv 2609.18486); Azzouni 2004, *Phil. Math.* 12(2):81-106; Tanswell 2015, *Phil. Math.* 23(3):295-310; Hamami 2022, *RSL* 15(2):409-449; Burgess 2015; Rav 1999, *Phil. Math.* 7:5-41; Barwise 1977 ("Hilbert's thesis" quote); Avigad 2021, *Synthese* 198:7377-7399; Avigad 2020, *RSL* 13(1):47-79; Larvor 2022, *Synthese* 200:332; Thurston 1994 (quotes); De Millo, Lipton and Perlis 1979 (social-process thesis); Jaffe and Quinn 1993; Kitcher 1981, *Noûs* 15(4):469-493; Kitcher 1984 (practice quintuple); Grabiner 1974, *AMM* 81(4):354-365; Ferreirós 2001, *BSL* 7(4):441-484; Easwaran 2009, *Phil. Math.* 17:341-362; Easwaran 2015 (convertibility); D'Alessandro (*Episteme*; corrigibility); Fallis 2003, *Synthese* 134:45-69; Weber and Mejía-Ramos 2011 (findings); Manders (co-exactness); Avigad, Dean and Mumma 2009 (E sound and complete); Pasch 1882 and Hilbert 1899; Shapiro (MIS, contradiction backtracing); Pease et al. (HRL; AIJ 2017, 246:181-219); Weir 2003, *NDJFL* 44(1):13-48; "Maximally consistent sets of instances of naive comprehension", *Mind* 126(502):371-384 (2017; result as stated).

**[unverified]**, needing a check before citing in the paper:
* the co-author of the *Mind* 2017 paper (believed Schlöder);
* McGee 1992 (title and venue);
* Specker 1953 (PNAS 39) on NF ⊢ ¬AC (the result is standard; the citation details are from memory);
* Zermelo 1930 and Boolos 1971 (details);
* the "historically given" wording in Zermelo 1908;
* Lakatos's "Cauchy and the continuum" (venue and year);
* Cauchy's 1853 correction;
* pages for Kreisel 1967, Manders 2008, Weber and Mejía-Ramos 2011, De Millo et al. 1979, ADM 2009;
* the Andersen *Synthese* year;
* Pease's PhD year;
* Shapiro's report number and the year of *Algorithmic Program Debugging*;
* the author of "Is there a Hilbert thesis?";
* the authors of arXiv 2608.28997;
* the Wiedijk manuscript year;
* the Jutting thesis year;
* Beeson, Narboux and Wiedijk ("Proof-checking Euclid") author list;
* the Pólya chapter on the Basel problem;
* Cantor's 1899 "inconsistent multiplicities" dating;
* Wright 1989 and Motoki-Shinohara-Wright 1991 (finite elasticity) exact citations;
* Kitcher's 1981 central example as paraphrased.

I deliberately omitted an often-repeated anecdote, that Euler claimed Σ_{n∈ℤ} xⁿ = 0, because I could not source it.
