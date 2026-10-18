# Solomonoff axiom induction

A paper on Solomonoff axiom induction (SAI), a Solomonoff-style prior over axiom systems.
* **The object.** A universal machine reads a random tape and emits first-order sentences. The prior probability of a set of sentences labelled true or false is the probability that the emitted theory is consistent and proves every datum (a sentence labelled false through its negation). At a new sentence the posterior splits three ways: the random theory proves it, refutes it or leaves it open. The predictions form a belief function.
* **What the paper does.** It develops the basic theory of this prior and relates it exactly to Solomonoff operator induction (SOI), the subject of the companion papers in [`../solomonoff-operator-induction/`](../solomonoff-operator-induction/). It studies what is specific to data that are sentences of a logic. And it uses the prior to make precise, and to test, claims about what a scientific theory does and what it is, with Kepler's laws worked through.
* **Earlier work it builds on:** the earlier report on axiom induction ([`../axiom-induction/`](../axiom-induction/)) and the report on learning axioms and schemas ([`../axiom-schemas/`](../axiom-schemas/)).
* **The name** "Solomonoff axiom induction" is a working name, set by a LaTeX macro. The final name is still to be decided by Hänni.

**Authors: Kaarel Hänni and Claude (Anthropic).** Claude did the research and writing, in response to questions from Kaarel Hänni and under Hänni's direction.
* **What Hänni asked for:** a paper that would contain
  * the fundamentals;
  * a discussion of the philosophical problems the formalism tries to make progress on: what a scientific theory is, how theories answer questions posed in existing language and explain propositions, a Kepler example, and the limitations of the axiom view;
  * the relation to SOI, including the time-bounded equivalences;
  * anything else cool enough, found by new research threads.

  Hänni also set the epistemic policy: the paper asserts only what we believe, whoever proposed it, and treats Hänni's philosophical claims as hypotheses to assess (`research/00-brief.md`).
* **Status:** the paper is a draft in arXiv form. Submission is Hänni's decision.

* **[*Solomonoff Axiom Induction: Definitions, Basic Theorems, and What a Theory Is and Does* (PDF)](paper/main.pdf)**, 230 pages: a main text of about 51 pages (Sections 1–13, pp. 2–53), the references, and Appendices A–I with the proofs, the Kepler computations and the notation (pp. 67–230).

## Answers in brief

Organised by what Hänni asked for. Section, theorem and table numbers are those of the PDF. Losses are in bits and in the semimeasure convention unless stated otherwise.

### 1. Fundamentals (Sections 2–3, Appendix A)

* **Definitions.** A theory machine reads random bits and writes sentences; consistency of its output is a random event, not a condition on the machine (Definition 2.3). SAI is the one-tape proof-requiring law M_A of the universal theory machine (Definition 2.4). Its coin-free versions W_A and W_A^dec (mixtures over deterministic enumerators and deciders of axiom sets) and its Kolmogorov version K_A (the length of a shortest compatible program) are in Definition 2.7. The consistency-requiring variant, which asks only that hypothesis and data be consistent, is in Definition 2.9; a graded variant and a generative law are in Definitions A.20 and A.36. Losses have three conventions: semimeasure (primary), normalised and three-valued (Definition 2.5).
* **Structure.**
  * M_A(D) > 0 iff D is consistent.
  * M_A is a weak semimeasure whose defect at a query, divided by M_A(D), is the posterior probability of "independent". It depends on the data only through their deductive closure: entailed data cost nothing and contradicting data are fatal.
  * Its cumulative semimeasure loss does not depend on the order of the data.
  * 0 < M_A(∅) = 1 − Inc₀ < 1, where Inc₀ is the probability that the random theory is inconsistent (Proposition 3.1).
* **Updating.** Proof-requiring updating is the geometric rule of conditioning of a belief function, and there is a probability on the complete consistent extensions of the background between belief and plausibility (Proposition 3.2). Consistency-requiring updating is Dempster's rule (Proposition A.4).
* **Computability.** Inc₀ is not computable, is Solovay complete and is Martin-Löf random. So M_A(∅) is right-c.e. and not left-c.e., and M_A is not lower semicomputable, unlike the one-tape law of SOI (Theorem 3.3); M_A + Inc₀ is lower semicomputable (Proposition A.7).
* **Dominance and invariance.**
  * M_A ≥ 2^(−K(ν)) ν for every theory-machine law ν (Theorem 3.4).
  * The universal machine matters only up to a constant factor (Proposition A.8). Building a background B′ into B gains at most K(B′) + c bits on any data (Proposition A.9).
  * Faithful translations between languages change the weights by at most 2^(±(K(τ)+c)) (Theorem 3.5), so new vocabulary buys at most a constant (Corollary 3.6).
* **Loss bound.** On any consistent reveal sequence, chosen in any way, the loss is at most K≡(T) + c for every r.e. theory T that is consistent with the background and proves every datum, K≡ being complexity up to deductive equivalence (Theorem 3.7).
* **Merging.** On three-valued data labelled by the random theory of a theory machine G with ν_G(∅) = 1, with questions chosen from the history and from randomness independent of the tape, the expected divergences between the predictions of G and of SAI sum to less than K(G) (Theorem A.12).
* **Kolmogorov against semimeasure: no coding theorem.** For every d ≥ 2 there are two literals of a fresh predicate on words of length d with K_A > log d − 2, while −log M_A ≤ 2 + c. No two of 2^(−K_A), W_A and M_A agree up to a constant factor (Theorem 3.9).
* **Why proof-requiring compatibility is primary.**
  * The 0/1 consistency-requiring weight is at least a fixed constant on all consistent data, and its data eliminate hypotheses but never change the odds between survivors (Proposition 3.10).
  * Its proper predictor, Dempster's rule, pays at least a fixed number of bits for every datum the earlier data do not entail (Proposition A.21).
  * The distinction exists only because the random theory is incomplete (Proposition 3.11). Priors of Demski's type complete their random theory, so they cannot see the difference between explaining a datum and tolerating it (Proposition A.39).
* **Convergence and its limits.**
  * On a consistent stream the posterior converges in total variation if the consistent extensions of the data have positive prior mass, and the loss is then bounded (Proposition A.26).
  * Data presenting a consistent r.e. theory T* with B ∪ T* complete concentrate the posterior on the class of T*. If B ∪ T* is incomplete, two-valued data leave each sentence independent of B ∪ T* with limit belief and disbelief in (0, 1), and three-valued data identify the class of T* (Proposition A.27).
  * As with Gold's text and informant, no learner identifies from two-valued data every theory of a simple family (Proposition A.28).
  * The normalised loss depends on the reveal order, by a number of bits linear in n on some 2n data built from fresh atoms (Theorem A.33).
* **Open:** does M_A dominate every lower semicomputable provability function (Question 3.12)?

### 2. The philosophical problems (Sections 6–11)

**What a scientific theory is (Sections 6.2, 6.4 and 7).**
* **The idealised formalism cannot see shape.** On data labelled true or false it cannot see the difference between a theory and a program. Every consistent labeller of sentences is an axiom system at a cost of O(1) bits, through Craig's construction inside the universal prior (Theorems 4.2 and 4.3). New vocabulary costs O(1) bits, and program length sees no reasoner (Corollary 3.6 and Theorem 7.2).
* **The exception is partiality.** When "independent" is itself observed, a theory can leave a sentence open without committing to anything, while a labeller must output "independent" after finitely many steps. The gap is unbounded on one datum (Proposition 4.6). The paper reads this as a formal trace of partiality, not as support for the claim that empirical theories are logical theories.
* **Where shape becomes visible.** In the settings studied, shape becomes visible only when something other than program length is charged (the written theory, the time to produce it, or the derivations) or the class of hypotheses is restricted (to finite theories). There it is relative to a reasoner and a vocabulary, and for theoretical terms what pays is relations and entities, not vocabulary as such. Whether this holds beyond these settings is open (Question 7.7).
* **The descriptive observation.** That textbook presentations of theories are declarative (laws, definitions and equations, not procedures that print predictions) is an observation, with two qualifications: declarative is not sentential, and theories in use have procedural parts (Section 6.2).
* **The explanatory question is open.** Why the declarative shape is good is open. The paper finds it plausible that it is good, and not merely common, but its results do not show it. In its models, declarative against procedural form costs at most a constant factor once intermediate concepts are available and the reasoner can chain through them (Theorem E.26), and nothing in its results favours sentences over classes of models. What is missing is a formal setting in which that shape provably pays; communication and piecemeal checking by communities of reasoners are the candidates (Question 6.1).

**Answering questions in existing language (Sections 1, 6.1, 6.3 and 6.6; Table 3).**
* **A ladder of views of what a theory does:**
  1. predicting raw data;
  2. answering questions posed with available abstractions, which may be highly theoretical;
  3. extending the language with theoretical terms that pay for themselves;
  4. revising the base abstractions.
* **SAI over a fixed language sits on step 2.** The paper takes step 2 to be a step in the right direction, but not the end point: an account of what theories do needs steps 3 and 4 as well. It has partial results on step 3 (Sections 7 and 8) and none on step 4.
* **How step 2 differs from step 1.** It differs in the target, the data type, logical coherence and partiality, not in the inference principle: version by version SAI agrees with SOI over consistent labellers, up to constants (Section 4). Table 3 lists the formal differences.
* **Answers cost no more than raw modelling plus an extractor.** For a computable law μ of the raw data and an extractor η whose answers are μ-almost surely consistent with the background, with μ_η the induced law of the answers, L_A(D) ≤ −log μ_η(D) + K(μ) + K(η) + c, with c depending also on the family of question sentences (Proposition D.5). The extractor's cost is not small in real cases: it contains whatever recognises a planet in an image.
* **Statistical practice.** Physics often confronts theory with near-raw data through generative models. The question-answering claim survives this objection in comparative form, the paper argues, but the proof-requiring core of SAI, with no native noise model, sits far from that practice.
* **The progress claim, as the paper states it:** "for what a theory does, SAI is a step in the right direction; for what a theory is, the idealised formalism is neutral on data labelled true or false" (Section 6.6).

**Explaining propositions (Section 6.5).**
* **The paper's conclusion:** derivation from a short theory is explanation in the unification sense, with at least five gaps. It does not claim that derivation is explanation outright.
* **The gaps:**
  * asymmetry: in the flagpole toy, four formulations of the shadow law are deductively equivalent, so the coin-free posterior keeps their prior odds on every compatible data set (Proposition D.7);
  * explanation by approximate correction (Proposition G.37);
  * irrelevance;
  * the conjunction problem;
  * statistical explanation.
* **Kitcher's answer to the asymmetry** is a whole-theory simplicity effect that SAI reproduces only under a listing code (Proposition D.9).
* **Explanatory power** is the bits of data a module explains per bit of its statement (Definition G.29).

**The Kepler example (Section 10, Appendix H; Section 9).**
* **What K3 says depends on the language.** In heliocentric directions Kepler's third law K3 adds nothing to the first two laws, for every background containing the axioms of real closed fields (Proposition 10.2). In geocentric directions it fixes the size of the orbit of Mars, given the other elements of the Earth and Mars (Proposition 10.3).
* **What K3 is worth.** A computation on the daily geocentric longitudes of Mars over 1580–1600 puts what K3 saves on the elements of Mars at 11.3, 12.3, 13.4 and 14.7 bits at precisions of 8′, 4′, 2′ and 1′. Its law text costs 375 bits in the paper's arithmetic syntax and 165 or 115 bits in two Polish-notation codes. So in none of these codes does compression alone select K3 at Kepler's precision; this is an extrapolation from Mars to the other planets, conditional on the code (Example H.4).
* **How wrong Kepler's laws are.** Against the plan94 ephemeris, not the sky, one fixed least-squares ellipse misses Mars by 1.6′–1.9′ over 12–30 years and 51.8′ over 2000 years, and the Moon by 1.1° within a month (Table 8).
* **The Mars pool: setting.** The pool is five hand-picked historical forms of theory for Mars (circle, eccentric, equant, vicarious hypothesis, ellipse), as heliocentric reconstructions. The data are the 7306 daily plan94 heliocentric longitudes of Mars over 1580–1600, as interval sentences. Their minimax errors are 640.79′, 23.05′, 8.17′, 1.41′ and 1.07′; these are upper bounds witnessed by elements, and only the circle's is proved optimal (Table 9).
* **The Mars pool: what decides.**
  * The data decide compatibility: as the precision is refined the forms drop out in the historical order, in every syntax.
  * Among compatible forms the data contribute only Occam factors, which on their own point weakly to the true form: with a uniform prior over the five forms and no text prior, the MAP is the ellipse at every δ ≤ 60′, by 0.20 to 14.61 bits.
  * On noise-free data the text prior decides the rest, so the syntax of the law texts sets the sequence of MAP forms (Table 5, Figure 1).
  * A presentation-free prior on model classes relocates this relativity rather than removing it (Section 10.4).
* **Graded fit and distances.**
  * With graded fit (Gaussian errors, σ = 2′) the data decide every step within tens of observations. The exception is the epicyclic syntax's choice between the vicarious hypothesis and the ellipse, which needs about 5,300 (Example H.3).
  * With distances within 1% as data, compatibility alone eliminates the vicarious hypothesis below a longitude tolerance of at most 5.12′. This reproduces the abandonment of circles, not Kepler's step from an oval to the ellipse (Table 10).
* **What Newton adds (Section 10.5).** The paper argues that on 20 years of longitudes at Kepler's precision the masses buy nothing measurable. It thinks an SAI posterior on such data alone would not prefer Newton's theory. The gains of Newtonian mechanics lie in unification, corrections in the old domain and new questions; Newton's axioms do not entail Kepler's laws, only, with masses and initial conditions, honest tolerance forms of them.

**Limitations (Section 11).**
* **Textbook insufficiency.** The paper agrees that a written theory joined to a simple reasoner does not solve the problems the theory is used for, and sees three gaps: a bridge gap, a computational gap and a tacit gap.
  * **The computational gap is a theorem in the model of Section 7, visible only when what is written, or the time to write it, is charged.** For Boolean laws, program length sees neither the reasoner nor the vocabulary (Theorem 7.2). The least written length of a usable theory depends exponentially on the pair (reasoner, vocabulary) (Corollary 7.6, Table 4).
  * **An example.** Unit propagation over the observed variables needs all 2^(m−1) clauses of one parity law (m ≥ 3). With intermediate concepts 4m − 6 clauses suffice (m ≥ 4), but only for a reasoner that can chain through them. A hidden-state system of laws needs written length 2^(Ω(m^(ε/3))) for unit propagation, with any auxiliary variables, clause widths and rounds, while m equations suffice for Gaussian elimination (Theorem 7.5, given the bound of Göös et al. 2019; the paper did not find this bound stated and thinks it probably known to specialists).
  * **Charged deduction cannot express the gap**, since no reading charges finding a derivation (Section 4.6, Theorem E.31).
  * **So insufficiency for a simple reasoner is a property of the pair (theory, reasoner) and of the vocabulary,** in that model, when what is written, or the time to write it, is charged. It is not a theorem about textbooks, nor about what people carry in their heads. The tacit gap (skills, exemplars) is a genuine limit.
* **Approximate correctness.** "Kepler's laws are only approximately true" remains a limitation of SAI, not only of proof-requiring compatibility with deterministic theories (Sections 9.3 and 11, Appendix G.9).
  * **Deterministic theories.** Proof-requiring compatibility is monotone in logical strength, so it prefers a false exact law to its true tolerance form: with prior weights 2^(−‖T‖) the posterior odds of the exact law against the tolerance form stay at least 2 (Proposition G.10).
  * **Randomised theories.** The mixture also contains randomised theories, and under its pricing an approximately true law is a law with a calibrated error model (Proposition 9.2). This describes the credence- and compression-best forecast in the mixture, not what approximate correctness is. The error model is carried by the randomness of the theory machine, not stated as an axiom; a treatment by sentences about probabilities is open.
  * **What the pricing does not see.** Whether an approximate law is good enough depends on a purpose, and SAI's loss sees a purpose only through the questions asked. For questions about one quantity the loss is the log score of the cell the answers determine: a question family fixes a resolution, and the cost of a miss is set by each hypothesis's own error model, not by a purpose (Proposition G.42). The pricing ranks rival laws by a dispersion of the error for coarse cells and, for fine ones, by the entropy of the error rather than its size (Theorem G.45). It can rank a law above one that is closer to the truth at every time, and other proper scores rank rival laws differently, under misspecification and even without it (Examples G.47, G.48). On the real Kepler residuals the maximum, RMS and mean absolute errors disagree on which of four fitted ellipses is best, and the calibrated pricing agrees with none of them (Appendix G.9).
  * **Scope.** A tolerance on a domain is a sentence in which SAI holds a credence; a graded loss on answers is not (Proposition G.49). Adequacy for a purpose needs a loss on answers, as a decision layer on the posterior or inside learning (Remark G.52). So the limitation is shared by any account that ranks approximate laws by posterior weight or code length, but not by Bayesian inference as such. A law at least as close to the truth on every question of a family is at least as good for every purpose that rewards closeness; beyond that the paper thinks there is no canonical score, and the choice of quantities is not neutral.
* **Other limitations.**
  * Statistical confrontation with data: SAI has no native noise model, and a native treatment is open.
  * Domains and mutually inconsistent models in use: honest forms of true models are jointly consistent over a true background, but choosing a model, a domain or a tolerance is left to tacit understanding.
  * Features of human concepts the axiom view misses (Table 6, an assessment).
  * Discovery: SAI evaluates theories in a fixed hypothesis space and does not find them.
  * Step 4 of the ladder, theory-laden and fallible data, purposes, and science as a social structure.
  * Machine-dependence: all comparisons of theories are relative to the universal machine, up to constants that are not small at the scale of real theories (Proposition A.8).

### 3. The relation to Solomonoff operator induction (Section 4, Appendix B, Table 1)

* **Version by version, SAI agrees with consistent SOI.** Never as an unqualified "SAI equals SOI".
  * **Coin-free:** W_A agrees with consistent coin-free SOI within constant factors on every finite data set, and the Kolmogorov versions agree up to ±c (Theorem 4.2). This is Craig's construction inside the universal prior; for deciders it is Theorem 6.3 of the earlier report.
  * **One-tape:** M_A agrees with one-tape consistent SOI within constant factors on every finite data set, the empty one included, and tape by tape (Theorem 4.3). Over closed labellers, the trichotomy of SAI is the three-way split of one-tape SOI (Corollary B.4).
  * **No schema needed.** A route through an axiom schema works with two sorts or with bounded witnesses, but fails in one sort over PA (Remark B.3).
* **On literals SAI is SOI.** On labelled atoms of a fresh predicate on distinct terms, SAI is SOI on strings, version by version and up to constants (Theorem 4.4). So the companion paper's binary-label results that hold up to additive constants transfer, while normalised cumulative statements, computability statements, and statements about private randomness or weak semimeasures do not in general (Corollary B.12).
* **What breaks.**
  * **Logical closure.** In the semimeasure convention SAI is certain of the consequences of the data, while consistent SOI never is: a share of at least 2^(−K(χ)−c) of its weight stays undefined at χ, entailed or not, whatever the data (Proposition 4.5).
  * **An observed "independent" label** gives a gap that is unbounded on one datum (for L ⊇ L_ar and Q ⊆ Cn(B)); no r.e. family of such sentences shows a large gap (Proposition 4.6, Proposition B.17).
  * **Consistency constraints of unbounded arity** separate the versions of consistent SOI (Corollary C.8).
  * **An encoding effect.** Plain coin-free SOI can beat SAI by n bits in expectation on literals with random signs, all labelled true, through the inconsistent labeller "always 1" (Remark B.14).
* **The time-bounded equivalences.**
  * **Penalties on the axiom side change nothing.** Charging a hypothesis for the time to check or to generate its axioms, with deduction free, at any time-constructible budget t(m) ≥ m^(a*), changes nothing up to constant factors, also class by class. This holds one-tape under the efficient self-simulation assumption (S_tape) and coin-free under its tape-free form (S), neither of which is proved for a particular machine (Theorem B.9, Proposition B.10).
  * **On the labeller side the relation is one-sided.** SAI loses at most a constant more than clocked consistent SOI (Corollary B.25).
  * **The reverse fails (Theorem 4.7).** Assume L ⊇ L_ar and a decidable background true in an expansion of ℕ. For every computable predictor there is a sequence of arithmetical sentences, labelled by their truth, on which it loses at least n − 0.361 bits, while SAI's coin-free versions lose at most a constant independent of the predictor. On the sequence built against one specific computable predictor, clocked plain and consistent SOI lose at least n − 1.37 and n − 1.37 − c⊥. One-tape forms: Theorem B.29.
  * **The separation comes from free deduction, not from axioms.** Unpenalised coin-free consistent SOI has bounded loss on these sequences (Proposition 4.8). The paper reads the separations as showing "not that axioms are better hypotheses than programs, but that free deduction is free computation". Clocked plain SOI and SAI are incomparable (Proposition B.26).
* **Charged deduction.**
  * **Derivation-charged SAI is certificate SOI.** Under the renaming condition (F1) and with time-constructible nondecreasing budgets, it is certificate SOI up to O(1) bits and polynomial changes of the budgets (Theorem B.31).
  * **Fit classes.** On literal data at polynomial budgets with charged degrees, the fit classes are NP ∩ coNP, EXPTIME and every decidable set, depending on the reading (Corollary B.32).
  * **What it cannot express.** Charged deduction bounds the size of a derivation that exists and never charges finding it. So it cannot express the point that a written theory is far from sufficient for a simple reasoner (Section 4.6).
* **A natural separation: Presburger arithmetic.**
  * **Free deduction.** On Presburger arithmetic listed by length, SAI has bounded loss. Given the Fischer–Rabin bound, clocked consistent and plain SOI have unbounded loss for clocks up to 2^(2^(c′m)) coin-free and 2^(c′m) one-tape (Proposition B.37). Under two unproved hypotheses (a Σ₂-time lower bound for Presburger arithmetic and a time-bounded form of BPP ⊆ Σ₂ᵖ), the one-tape losses are unbounded for doubly exponential clocks as well (Proposition B.40).
  * **Charged deduction.** SAI needs doubly exponential budgets under the size and material readings and at least exponential instance sizes under (a1); the rest is open (Proposition B.41, Question B.42).

### 4. Further results

* **Random theories that no r.e. theory can replace (Section 5.1).** In a language with a fresh binary relation symbol, there is a stream on which the one-tape loss is bounded although no consistent r.e. theory proves it. The coin-free loss is unbounded, and the limit posterior lives on random theories whose closure is not r.e. (Theorem 5.1). The obstruction is a consistency constraint of unbounded arity; bounded arity removes it (Proposition C.3).
* **True data, false theories (Section 5.2).** In arithmetic, over a decidable true background containing Robinson arithmetic Q, there is a stream of true sentences on which the loss is bounded and the limit posterior is concentrated on false theories (Corollary 5.5). The data are adversarial, so this is a possibility result in an idealised setting, not evidence about actual science.
* **Π₁ data (Section 5.3).** Over a decidable true background containing Q, on data of Π₁ type the mixture is, up to a constant factor, one random true threshold theory (Theorem 5.6). This gives a coding theorem for Π₁ data (Corollary 5.7) and Chaitin's theorem for random theories.
* **Gödel phenomena (Sections 5.4–5.5).**
  * Over a background containing Q, belief or independent mass on a Π₁ sentence certifies its truth (Proposition 5.8).
  * Over one containing PA, the coin-free posterior never learns Σ₁-soundness (Theorem 5.9).
  * The Bayesian ω-gap is the ω-incompleteness of the background plus the instances (Proposition 5.11).
  * On true arithmetic the loss grows at least like n^ξ up to logarithmic terms, with ξ ≥ 0.0823 for a stated syntax (Theorem C.30).
* **The theoretician's dilemma (Section 8, Theorem 8.3).**
  * **In principle.** With free deduction, theoretical vocabulary changes observational predictions only by a constant factor, so Hempel's inductive-systematisation reply fails in the universal mixture. This is a statement about the mixture, not about a single theory (Section 8.6).
  * **Craig's construction.** On literal data with charged deduction, padded (Craig-type) axiomatisations with polynomial-time membership fit exactly the polynomial-time regularities. The impracticality reply is thus a theorem about Craig's construction, not about theoretical vocabulary, which is eliminable at polynomial cost.
  * **What is indispensable.** With an empty background, a finite theory with only unary theoretical predicates and constants, compatible with the theory of the named objects, fits exactly the regular sets. One binary theoretical relation fits more. So does quantification over unnamed objects, at the price, for a theory without theoretical vocabulary, of proving a sentence false in the named structure.
* **Approximate laws and best systems (Section 9).**
  * **Guaranteed tolerances.** Over deterministic theories, with intervals of half-width δ around measurements with errors at most δ₀, an exact law with worst error ε* is almost surely compatible with the data at every sample size when δ ≥ ε* + δ₀ and, under mild conditions on the measurement error, eventually refuted when δ < ε* + δ₀ (Proposition G.12).
  * **Rounded data.** On rounded data (a dithered grid of cells) the exact law is almost surely refuted eventually iff its error is nonzero with positive probability, however coarse the cells (Proposition G.13).
  * **Error models.** On data from a law with independent errors, the best loss rate is that of the law with its error distribution, attained by M_A if that distribution is computable (Proposition 9.2).
  * **Scores and purposes (Section 9.3, Appendix G.9).** That rate is the differential entropy of the error smoothed at the cell width, minus log Δ (Theorem G.45); it is not an account of approximate correctness (see the limitations above). With a mixable purpose loss in place of log loss and universal weights over theory machines, the aggregating algorithm ("purpose-SAI") has regret at most K(G) ln 2/η against every theory machine G (Proposition G.51), a theory-machine form of predictive complexity. Whether a purpose can enter SAI itself is open (Question G.53).
  * **Best systems.** The best system is the same for every balance of simplicity against strength in an interval exactly when the hull of length against fit has a kink there (Proposition 9.3), one aspect of what Lewis calls a kind nature.
  * **What the split separates.** The model–randomness split separates facts reused across many data from facts used once, not laws from initial conditions. K3 is a law about initial conditions (Proposition G.33).
* **The paper says what it takes to be new** in Section 12. Not new: random axiom systems drawn by a universal machine (the modified Demski prior samples them), the mixture and dominance arguments, Craig's construction, the rules of conditioning for belief functions, and the reading of a law with its noise distribution as a two-part code.

### 5. Where the paper departs from the brief

The paper refines several of Hänni's views, and corrects some of the brief's own seed ideas:
* **"Axiom induction gets what a theory is more right than a program."** As agreed with Hänni, the idealised formalism cannot see the difference on data labelled true or false. The paper goes further: where shape is visible in its models, the large effects lie in the pair (reasoner, vocabulary), not in logical form, and nothing in its results favours sentences over classes of models.
* **"Theories answer questions stated in existing language."** Kept in comparative form, as a ladder with SAI on step 2 (as agreed).
* **"Kepler's laws give only approximately correct predictions" as a limitation of the axiom view.** The draft of 2026-10-17 placed this in proof-requiring compatibility with deterministic theories and said it was not a limitation of the axiom view as SAI formalises it, because under SAI's pricing an approximately true law is a law with a calibrated error model. Hänni objected that this reduces approximate correctness to a low-level predictive loss such as log loss, while some mistakes are much worse than others even when they look the same on log loss, and whether a theory's answers are good enough is graded by a purpose. The paper now agrees with Hänni's objection: log loss cannot be the account of approximate correctness, the claim is retracted, and approximate correctness remains a limitation of SAI (Sections 9.3, 11 and 13, Appendix G.9). The paper is narrower than the brief's agreed wording ("a limitation of SAI and of any Bayesian cumulative log loss") in one respect: the limitation is of ranking approximate laws by posterior weight or code length, not of Bayesian inference as such, since a decision layer (posterior plus a loss on answers) ranks laws by purpose when the posterior predicts well. What remains open: how a purpose can enter SAI, as acts under its belief-function predictions or as learning with a purpose loss over theory machines, and whether there is then a semicomputable universal element (Question G.53).
* **"Written theories are not remotely sufficient for a simple reasoner."** Agreed. It becomes a theorem only in a stated model and only when what is written, or the time to write it, is charged, as a property of the pair (theory, reasoner) and the vocabulary. The paper insists it is not a theorem about textbooks.
* **"Theories explain propositions."** Qualified, not contradicted: explanation in the unification sense, with at least five gaps.
* **Concepts are for answering questions and solving problems, not for predictions.** Accepted only comparatively. Table 6 says "yes for questions posed in a language; no for problems needing search or action".
* **The note's conjectured equivalence with consistent SOI through an axiom schema.** The equivalence holds version by version without a schema, and the schema route fails in one sort over PA (Remark B.3).
* **Seed ideas of the brief, corrected:**
  * "The time-bounded separations make the classical reply to Hempel a theorem": the reply that Craigian axiomatisations are unmanageable becomes a theorem only about Craig's construction and run-padded axiomatisations under charged derivations; theoretical vocabulary is eliminable at polynomial cost (Theorem 8.3), and the time-bounded separations from SOI come from free deduction (Proposition 4.8).
  * "The simpler approximate theory is preferred until the data's precision exceeds its error" holds for guaranteed tolerances. On rounded data an exact law whose error is nonzero with positive probability is almost surely refuted eventually, however coarse the cells (Propositions G.12, G.13).
  * A steeper prior does not separate laws from initial conditions, only facts reused from facts used once (Section 9.5).
  * "A program computes one direction cheaply" holds of particular programs only: a program with internal variables answers every direction of a parity law with O(m) operations (Section 6.2).
  * Theoretical terms pay by compression (step 3 of the ladder) only in a restricted sense: over r.e. hypotheses with free deduction they change predictions by at most a constant factor; they pay for finite theories and under charged deduction, and there what pays is relations or entities, not vocabulary as such (Section 8).

## How it was produced

* **Research.**
  * **Scouts.** Six scouts explored the ground (`research/scouts/`): fundamentals, the relation to SOI, philosophy, the literature, and two on new directions (logic, and the philosophy of science). Hänni's notes and essays (`research/prior/`) were the starting point.
  * **Selection.** A lead researcher selected seven research tracks (`research/select.md`):
    * `fundamentals`;
    * `sfi` (the relation to SOI, with time bounds);
    * `logic`;
    * `terms` (theoretical terms);
    * `shape` (theory shape relative to a reasoner);
    * `laws` (approximate laws and best systems);
    * `philosophy` (including the Kepler computations).
  * **Tracks.** Each track was developed (`notes.md`) and refereed twice by adversarial referees. Referee A checked the proofs (on `philosophy`, the philosophy), and referee B the computations and counterexamples (on `philosophy`, formal accuracy and references), with independent code (`referee_code/`, and `referee_A_code/` on `philosophy`). Each track was then revised into a final record, `notes-final.md`, ending in a verification log.
  * **Synthesis.** A synthesis ranked the results, wrote the argument map and the SOI table and planned the paper (`research/notes-final.md`). A fresh final check compared its headline statements with the records and re-ran key scripts (`research/final-check.md`).
* **Writing.**
  * A planning editor wrote the claims ledger, outline and notation (`paper/CLAIMS.md`, `OUTLINE.md`, `NOTATION.md`, `plan-log.md`).
  * A bibliography editor verified by search the references not yet verified in the research, and recorded for each reference how it was verified and what may be attributed to it (`paper/bib/bib-report.md`).
  * Nine section writers and a front-matter writer wrote the text (`paper/logs/write-*.md`, `front.md`).
* **Review.**
  * Five reviewers went over the draft: three on the mathematics, one on the philosophy, and one on consistency and arXiv-readiness. They raised 86 issues: 0 fatal, 14 major, 72 minor.
  * A lead editor verified every major issue against the sources and the records and wrote binding decisions (`paper/review/DECISIONS.md`, with issue lists for ten editing groups). These included length moves that brought the main text from about 69 pages to about 50; statements moved to the appendices keep a summary sentence in the main text.
  * Ten editor groups applied the decisions (`paper/logs/edit-*.md`).
  * Two fresh final checkers, one for the mathematics and one for the text, verified the result (`paper/review/final-check-math.md`, `final-check-text.md`). Each checked the major fixes, compared statements with the records (27 and 30), traced every computed number in its scope to a saved output, ran the arXiv-readiness greps and built the paper. Between them they corrected two computation paragraphs in the appendices and restored a hypothesis that one summary sentence of the introduction had dropped.
  * `paper/CLAIMS.md` records where each result ended up in the final build.
* **After the draft: approximate correctness.** Hänni objected to the draft's claim that approximate truth is not a limitation of the axiom view as SAI formalises it (`research/00-brief.md`, section of 2026-10-17).
  * **An eighth research track, `purpose`** (`research/tracks/purpose/`), checked the reply to that objection claim by claim: scoring rules and locality, what a question family can encode, error models, rival approximate laws (with the real Kepler residuals), purpose losses with universal weights, and what approximate correctness is. It was developed (`notes.md`), refereed by two adversarial referees (A: proofs and philosophy, with independent code in `referee_A_code/`; B: computations, counterexamples and references, with independent code in `referee_code/`) and revised into `notes-final.md`. Its references were verified by search (`refs-report.md`, `refs-revision.bib`).
  * **An editor applied the agreed change** (`paper/logs/edit-purpose.md`): the claim was retracted, a paragraph of Section 9.3 and Appendix G.9 were added, Sections 11–13, the abstract and the introduction were revised, and the new references were recorded in `paper/bib/bib-report.md` §7. `paper/CLAIMS.md` has rows for the new results.
* **Limits of the checking.** All roles were played by separate Claude instances. No human has checked all of the mathematics, and nothing was verified in a proof assistant.

## Layout

| path | contents |
|---|---|
| `paper/` | LaTeX sources (`main.tex`, `preamble.tex`, `sections/`, `bib/`), `build.sh`, `test-section.sh`, `merge_bib.py` and `main.pdf`. Also the planning files `OUTLINE.md`, `CLAIMS.md` (updated to the final build), `NOTATION.md` and `plan-log.md`. The working sources keep a `\status{…}` tag and a `\src{…}` note on each result, recording whether it is proved, computed, conjectured or an assessment, and which record item it comes from; both macros print nothing in the PDF. |
| `paper/bib/` | `refs.bib` and `core.bib` (merged into `all.bib` at build time) and `bib-report.md`, which records how each reference was verified and what may be attributed to it. |
| `paper/review/` | The five reviews (`math-a`, `math-b`, `math-c`, `phil`, `consistency`, with their JSON issue records), the lead editor's `DECISIONS.md` and per-group issue lists, and the two final checks. |
| `paper/logs/` | The section writers' logs (`write-*.md`, `front.md`) and the editors' logs (`edit-*.md`). |
| `paper/build-test/` | *(on the working branch `claude/sleepy-gauss-u4kem1` only, not on `main`)* Scratch builds of single sections made by `test-section.sh`. |
| `research/00-brief.md` | Hänni's request verbatim, the epistemic policy, the agreed stances on "what a theory is" and "existing language", the sources and the conventions. |
| `research/prior/` | Hänni's notes and essays the work started from: copies of notes from [kaarelh/notes](https://github.com/kaarelh/notes), the note on Solomonoff axiom induction, and the draft essay on concepts. |
| `research/scouts/` | The six scout records with their scripts (`checks/`) and saved outputs. |
| `research/select.md`, `research/NOTATION-draft.md` | The selection of the research tracks and their shared notation. |
| `research/tracks/` | The eight track records (the seven of the research behind the draft, and `purpose`, on scores, purposes and approximate correctness): `notes.md` (development), `referee-A.md`, `referee-B.md`, `notes-final.md` (the final record, which wins over the synthesis where they differ), the developers' scripts (`checks/`) and the referees' independent code (`referee_code/`, `referee_A_code/`), with saved outputs. |
| `research/synthesis/` | The synthesis's own scripts and logs: re-runs of the track scripts with output comparison (`rerun_checks.py`, `compare_outputs.py` and their `.out` files) and bibliography checks. |
| `research/notes-final.md`, `research/final-check.md` | The synthesis and its fresh final check. |
| `research/refs.bib` | The verified bibliography of the research. |
| `research/workflows/` | *(on the working branch `claude/sleepy-gauss-u4kem1` only, not on `main`)* The orchestration scripts that ran the research, writing, review and editing agents. |

The internal verification appendix (`paper/sections/app-verification.tex`, a status table of every main-text result with its source and the record of the review) is kept in the sources but switched off in the PDF (`\sairecordfalse` in `main.tex`).

## Building and reproducing

* **The paper.** Run `cd paper && ./build.sh`; it needs `pdflatex`, `bibtex` and Python 3 (for `merge_bib.py`). To compile one section with its appendix alone, run `./test-section.sh <section> <appendix>`, for example `./test-section.sh soi app-soi`; references to other sections are then undefined, as expected.
* **The computations.**
  * **Scripts.** Every script in `research/tracks/*/checks/`, `research/tracks/*/referee_code/`, `research/tracks/philosophy/referee_A_code/`, `research/tracks/purpose/referee_A_code/` and `research/scouts/*/checks/` is deterministic or seeded, and its output is saved next to it as `<name>.out`. Helper modules (`shapelib.py`, `hilbert_check.py`, `rb_common.py`, `refA_lib.py`, `refB_lib.py`, `rb_logic.py`) have no output of their own.
  * **Environment.** They were run with Python 3.11.15, NumPy 2.4.6 and SciPy 1.17.1. mpmath (1.3.0) is needed by `sfi/checks/c3_presburger_constants.py` and two referee scripts, and SymPy by `fundamentals/referee_code/rb4_order.py`. The planetary scripts need pyerfa 2.0.1.5, the Python interface to the ERFA library: `scouts/philosophy/checks/*`, `philosophy/checks/c4`, `c4b` and `c7`–`c10` (some import `c4` or `c8`), `laws/checks/l4_kepler_pk.py`, `purpose/checks/p4_allfits.py`, and the philosophy referees' `rb2`–`rb5`, `ra1` and `ra2`, which import them.
  * **How to re-run.** Copy `research/` to a scratch directory, because some scripts overwrite their `.out` file. Run each script from its own folder in the copy, redirecting standard output to a file for the scripts that print their output, and compare with the saved output. `research/synthesis/rerun_checks.py <scratch-root> <track…>` does this for the developers' scripts, and `compare_outputs.py` separates timing lines from real differences.
  * **What re-running gives.** At synthesis the developers' scripts were re-run, and every output compared was identical to the saved one apart from lines reporting run times (`research/synthesis/*.out`). The Mars-pool, volume cross-check and distance scripts (`philosophy/checks/c4`, `c4b`, `c8`, `c10`) were not re-run there.
  * **Scripts needing care.**
    * `logic/checks/c0_rerun_scout.py` takes a scratch folder and the scout's `checks/` folder as arguments.
    * `terms/checks/t6_revision.py` imports scout S's `s2_craig_blowup.py` by a path relative to the repository tree.
    * Scout S's `s2_craig_blowup.py` needs more than 12 GB of memory at its largest word.
    * `purpose/checks/p4_allfits.py` (about 20 minutes) writes `p4_allfits.npz`, which `p4_kepler.py`, `p7_kepler_effects.py`, `referee_code/rb5_kepler.py` and `referee_A_code/ra1_fine_rates.py` read; it, `p4_kepler.py` and `rb5_kepler.py` also read `laws/checks/l4_residuals.npz` by a relative path.
  * **Long runs.** The Mars-pool posterior (`philosophy/checks/c4_mars_pool.py`) takes about 80 minutes on one core, and the distance search (`c10_distances_research.py`) about 36 minutes; their figures were also reproduced by the referees' independent implementations. `c4b_volume_crosscheck.py` did not finish three of its cases within 72 minutes; its saved output holds the cases it finished, and referee B's `rb3_mars_pool.py` estimated the others.
  * **Seeds.** The Kepler computations use seed 20261015 (residual fits, Mars pool) and 20261016 (graded fit, distances). Other scripts state their seeds in their headers and outputs, and the records' verification logs list them with run times.

**Where the computed numbers come from.** Paths are relative to `research/tracks/`, except those starting with `scouts/`, which are relative to `research/`. Each record's claims table and verification log give the item-by-item detail (the record item behind each paper item is in its `\src{…}` note).

| paper | computed content | scripts |
|---|---|---|
| §3, App. A | checks of the proved statements (Props 3.1, 3.2, 3.10, A.4, A.11, A.21–A.24, A.26, A.27, A.39; Thms 3.9, A.12, A.33, A.35; Cor A.32); no computed number is reported outside a statement | `fundamentals/checks/c1_structure.py` (structure, updating, merging, limits), `c2_separations.py` (Prop A.21, Thm A.33, Prop A.24), `c3_kolmogorov.py` (Prop A.11, Thm A.35), `c4_coloring.py` (Thm 3.9), `c5_revision.py`; `fundamentals/referee_code/ra1_order_demski.py`, `rb1`–`rb8` |
| §4, App. B | checks of Thms 4.3, 4.4, Lemma B.2, Cor B.4, Props 4.5, 4.6, B.21, Rem B.14, B.15; Presburger thresholds (App. B.7); verifier-circuit translation sizes (App. B.8); the constant of Thm 4.7 | `sfi/checks/c1_onetape_finite.py`, `c2_independent_label.py`, `c5_revision.py` (Prop 4.6), `c3_presburger_constants.py` (App. B.7), `c4_circuit_axioms.py` (Thm B.43); `sfi/referee_code/rb1`–`rb6`, `rA1_gadget_ratio.py` (Cor B.44), `rb4_arith.py` (Thm 4.7) |
| §5, App. C | the lottery product 0.288788… (Thm 5.1) and Cor C.7, Props C.3–C.5, Thm 5.4; threshold theories (Thms 5.6, C.11, C.21); Prop 5.8; ξ ≥ 0.0823 and its certificate (Thm C.30); Rem C.12, Prop C.16, Prop C.27 | `logic/checks/c1_lottery.py`, `c2_majority.py`, `c3_threshold.py`, `c4_trichotomy.py`, `c5_syntax.py`, `c6_revision.py`, `c0_rerun_scout.py`; `logic/referee_code/rb0`–`rb7` (`rb3` for Cor 5.5, `rb7` for Prop C.27) |
| §6, App. D | the conservation-law world (Prop D.3); the flagpole (Prop D.7); checks of Props D.2, D.6 | `philosophy/checks/c5_conservation.py`, `c9_revision.py` (part 1), `c6_flagpole.py`; `philosophy/referee_code/rb1_formal.py` |
| §7, App. E | minima over the base variables and the simplex family (Thm 7.4, Cor E.14, Rem E.15); intermediate concepts and depth (Props E.16–E.20, E.24, Lemma E.22, Rem E.19); directions and the homes of know-how (Props E.25, E.29); learning (Thm E.34); spanners and Conj E.38 (m ≤ 18); the Kraft sum of Lemma E.1; the reduction of Thm 7.5 | `shape/checks/c1_linear_noaux.py`, `c2_intermediate.py`, `c3_directions_decider.py`, `c4_setting_depth2.py`, `c5_learning.py`, `c6_spanners.py`, `c7_revision.py` (with `shapelib.py`); `shape/referee_code/refA_*`, `refB_*` (`refB_t7_conj.py` for m = 17, 18) |
| §8, App. F | the projection toy for Thm F.3; the Craig axiom of more than 10^204.6 symbols against 795 (Ex F.7); two-stack and alternating constructions (Lemma F.10, Prop F.11, Thm F.14); regular sets (Thm F.17); monadic theories, bits and factoring (Lemma F.27, Props F.30, F.36); 13 sentences of Prop F.22; Prop F.20 | `terms/checks/t1_hempel_toy.py`, `t3_alternating.py`, `t4_two_stack.py`, `t4_regular.py`, `t5_monadic.py`, `t6_revision.py` (with `hilbert_check.py`); `scouts/sfi/checks/s2_craig_blowup.py`, `s3_vocab_ontology.py`, `scouts/novel-logic/checks/c2_finite_models.py`; `terms/referee_code/rA1`, `rb1`–`rb8` (`rb7` for Thm F.3, `rb8` for Ex F.7) |
| §9, App. G | regimes G and R and the 94 data (Props G.12–G.14); rates, phases and selection (Lemmas G.15, G.20, Props G.16, G.18, G.19, Thm G.22, Cor G.23); the Kepler residual series, Table 7, the 429 cells and 34 of 39 pairs (Prop 9.2); exception codes (Prop G.17); horizons and 7.96ε (Props G.25, G.28, Rem G.26); the solar-system toy, λ ∈ (7.03, 135.37) (Prop 9.3, Props G.33–G.35); the correction table (Prop G.37); domains and retention (Props G.39, G.40); regime-G refutation probabilities; repeated times | `laws/checks/l2_precision.py`, `l3_phases.py`, `l4_kepler_pk.py` (writes `l4_residuals.npz`), `l5_kepler_select.py`, `l6_horizons.py`, `l7_best_system.py`, `l8_domains.py` (first computation; the paper's domain and retention figures are `l10`'s exact recomputation), `l9_correction.py`, `l10_revision.py`; `laws/referee_code/ra1_checks.py`, `rb1_dither_exact.py`, `rb2`–`rb8` |
| §9.3, App. G.9 | the Gaussian price of a miss after Prop G.42; the arcsine convergence after Thm G.45; Ex G.47 (closed-form prices, Δ_c = 1.558542, Δ_c′ = 1.429612, the non-nested-information model); Ex G.48 (the nearby and scattered forecasts, the misspecified Gaussian family); the rival Kepler fits (234 pairs, 11–16 reversals, up to 6.8%) | `purpose/checks/p6_revision.py` (Prop G.42, Thm G.45, Ex G.47(c)), `p4_toy.py` (Ex G.47(a), (b)), `p2_scores.py` (Ex G.48), `p4_allfits.py`, `p4_kepler.py` and `p7_kepler_effects.py` (Kepler fits); independent re-implementations `purpose/referee_code/rb1`–`rb6`, `purpose/referee_A_code/ra1_fine_rates.py` |
| §10, App. H | Table 8 (residuals), the third-law constant, Mercury's perihelion and the great inequality | `scouts/philosophy/checks/c1_kepler_fit.py`, `c3_kepler_constant.py` |
| §10, App. H | Table 9 (minimax errors), Table 5 and Figure 1 (the Mars-pool posterior), what K3 saves (Prop 10.3, Ex H.4), the arc of Prop 10.3 and Prop H.2 | `philosophy/checks/c4_mars_pool.py`, `c4b_volume_crosscheck.py`, `c7_geocentric_arc.py` |
| §10, App. H | graded fit (Ex H.3), intrinsic errors against an exact ellipse, the exact-K3 errors, the prior without texts, Polish-notation codes | `philosophy/checks/c9_revision.py` |
| §10, App. H | Table 10 (distances as data) | `philosophy/checks/c10_distances_research.py`, `c8_mars_distances.py` |
| §10, App. H | independent re-implementations | `philosophy/referee_code/rb2_law_texts.py`, `rb3_mars_pool.py`, `rb3b_distances.py`, `rb4_geocentric.py`, `rb5_k3_geocentric.py`; `philosophy/referee_A_code/ra1_checks.py`, `ra2_series.py`, `ra3_semantic_prior.py` |
