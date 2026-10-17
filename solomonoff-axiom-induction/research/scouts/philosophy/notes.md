# Scout P (philosophy): argument map, the Kepler example, limitations, literature, formal questions

*Scout record for the paper on Solomonoff axiom induction (working name; nothing here depends on the name). Brief: `../../00-brief.md`, read in full, including its epistemic policy: the author's philosophical claims are treated as hypotheses to assess. Sources read: every note in `../../prior/`, including `hanni-condensation-concepts.md`; in `/home/user/kaarelh/notes`, the folders `philosophy/philosophy of science`, `philosophy/prediction` (all notes, including the three on scientific reports), `philosophy/concepting` (the notes on good concepts, gaining concepts, limitations of condensation, purposes, "how come a new concept can expand our understanding", "some points against the world modeling story", "world-structures to mind-structures", "learning concepts"), `ai/learning/solomonoff induction` (the axiom-induction note and the sequence plan), plus three notes found by search (`philosophy/philosophy of language/treating many weird cases in language as language change.md`, `philosophy/reference/Ramsification.md`, `ai/mind uploads with ML (and prediction in particular)/msgs to samuel on ML mind upload difficulty.md`, which contains the Kepler remark quoted in §1.2). Also: the earlier report `../../../../axiom-induction/` (abstract, introduction, discussion and time sections), and the summaries of the sibling scouts `../fundamentals/notes.md` §0 and `../sfi/notes.md` §0–1, to keep the formal claims consistent with theirs.*

*Scripts are in `checks/`; each writes `<name>.out` next to itself; all are deterministic (c1 is seeded). No git command that changes repository state was run. Status tags: **[proved]** (full proof here), **[proof sketch]**, **[computed: script]**, **[known: key]** (bibliographic data verified by WebSearch on 2026-10-15; "content from secondary sources" says when only abstracts or citing works were seen), **[conjecture]**, **[open]**, **[refuted]**. Philosophical judgements are marked **[assessment]**: they are our considered view, argued in the text, not theorems.*

*Notation. AI: axiom induction (proof-requiring unless stated). SFI: Solomonoff function induction. FIcons: SFI restricted to logically consistent labellers. "Base language": the language in which data and questions are stated. "Fundamentals scout" and "SFI scout" are `../fundamentals/notes.md` and `../sfi/notes.md`.*

---

## 0. Summary

1. **Argument map (§1).** The axiom view makes four claims: a theory *does* something different from raw-data prediction (it answers questions posed in a given language); a theory *is* a different kind of object (a logical theory, not a program); theories *explain* propositions (by derivation); the language is given (the ladder). Our verdicts:
   * "what a theory does" holds in the comparative form, but the formal difference is the data type (labelled sentences instead of observation strings) plus logical coherence, since AI with free deduction *is* consistent SFI on sentences;
   * "what a theory is" holds as a description of written theories and fails as a claim about the idealised formalism (Craig); what survives formally is a list of six concrete differences (§1.7);
   * "explains" needs qualifying: derivation from a short theory captures unification-style explanation, but not explanatory asymmetry, and not Newton's explanation of Kepler, which is approximate and corrective;
   * the ladder (from the brief) stands.
2. **Kepler example (§2).** A two-sorted first-order language, the axioms K12 (Kepler's equation) and K3, elements as initial conditions, and interval sentences as data. Computed on ERFA's planetary theory, the following findings make "approximate truth" concrete:
   * **Mars over 1580–1600:** one fixed ellipse misses the heliocentric longitude by at most 1.17′. Ptolemy's bisected equant misses by 8.3′, close to Kepler's famous 8′, and Kepler's vicarious hypothesis by 1.50′ in longitude but 2.9% in distance. This yields an exact precision-dependent compatibility table.
   * **Kepler's third law:** its constant is off by 1.5×10⁻³ for Saturn. Newton's two-body correction gives 2.9×10⁻⁴ of this, and the orbit-averaged pull of Jupiter supplies the rest: predicted 1.00154, fitted 1.0013–1.0019.
   * **Other failures of fixed Kepler orbits:** the line of apsides of Mercury turns by 575″ per century; Saturn's longitude carries a 900-year oscillation of about 44′; the Moon leaves any fixed ellipse by 1.1° within a month.

   Three new formal observations come with the example:
   * K3 has no content in a direction-only data language [proved];
   * the Ramsey sentence of the laws answers no position question [proved];
   * proof-requiring AI with interval data prefers a *false exact* law to its *true tolerance-weakened* version at every sample size [proved]. So the simplicity prior alone does not deliver honest approximate theories. Honest approximate theories are partial theories.
3. **Limitations (§3).** Twelve limitations, each with its source in the notes and a verdict: partially addressable formally (a research question), or a genuine limit. The condensation essay's list is mapped item by item. The axiom view captures:
   * compositionality;
   * inferential role;
   * concepts introduced by pointers;
   * defined concepts.

   It misses recognizers, purposes, softness and meaning change, methods, clarification and reinforcement.
4. **Literature (§4).** 75 references, with bibliographic data checked by search, each with its relation to the paper. `refs.bib` carries the verification notes: a few page ranges and some contents were confirmed only from secondary sources.
5. **Formal questions (§5), ranked:**
   1. approximate truth and precision-dependent selection;
   2. theory shape relative to a reasoner, posed as a factorisation question under time bounds;
   3. a hierarchy of hypothesis classes in which theoretical terms pay;
   4. laws versus initial conditions;
   5. lemmas for bounded reasoners;
   6. explanation and asymmetry in the generative variant;
   7. piecemeal confirmation;
   8. learning domains of applicability.
6. **Possible error in the author's view.** One note (§1.8), on information-theoretic losses.

---

## 1. Argument map for the philosophy section

### 1.1 The two problems

* **P1 (what a theory does).** What is a scientific theory *for*? Candidate answers:
  * predicting observation sequences (the raw-data view behind Solomonoff induction);
  * answering questions posed in some language;
  * explaining phenomena;
  * solving problems and guiding action (Laudan's problem-solving view [known: laudan1977progress]; the author's purposive view in the condensation essay and in `philosophy/philosophy of doing/a world of purposes.md`).
* **P2 (what a theory is).** What *kind of object* is a scientific theory? Candidate answers:
  * a program that prints or predicts observations;
  * a set of sentences closed under consequence: the syntactic or "received" view [known: suppe1977structure];
  * a class of models: the semantic view [known: suppes1960comparison, vanfraassen1980scientific];
  * a core of models plus a set of intended applications: the structuralist view [known: sneed1971logical, balzer1987architectonic];
  * a practice, made of exemplars, skills and tacit knowledge [known: kuhn1970structure, kuhn1977second, polanyi1958personal].

The axiom view answers P1 with "answering questions in a given language, which includes explaining" and P2 with "a logical theory". The raw-data view answers "predicting observations" and "a program".

### 1.2 Claim D: a theory answers questions; it does not predict pixels

**Statement.** A theory answers questions stated in an existing language: "what is the period of Jupiter?", "where will Mars be at time t, to within 2′?". It does not generate or predict a raw data stream. Sources:
* the brief (the author's request);
* `phil-sci-scientific-theories-are-not-for-generating-or-predicting-arbitrary-data.md`;
* `phil-sci-science-predicts-only-very-particularly.md`;
* `predicting-specific-things.md`;
* the condensation essay, which says that concepts help one answer questions and solve problems, and that predictions are "already high-level" and "about extremely specific things".

**Arguments for.**
* (D1) **Science is silent on almost everything.** Mechanics improves the prediction of arbitrary video pixels negligibly, and does not even predict how far a cannon fires. It relates particular quantities (trajectory and initial velocity) in particular set-ups. A raw-data predictor must model everything, so the theory's contribution is a vanishing fraction of its loss.
* (D2) **Predictions are graded by purpose-made tolerances** on high-level quantities (Mercury's precession "about right"), not by total log loss on sense data.
* (D3) **Questions are partial, and so are theories.** A theory is silent where it has nothing to say. The axiom view represents this natively: the trichotomy true / false / independent, and the semimeasure defect as the mass of "independent" (fundamentals scout §0). A total predictor of a data stream must say something about every bit.
* (D4) **Theories answer questions in many directions.** K3 gives the period from the semi-major axis and the semi-major axis from the period. Le Verrier used Newton's theory to answer "where is the body that perturbs Uranus?". Raw-data prediction answers only "what comes next".

**Objections.**
* (o1) **The theory is in the raw-data predictor too, only deeply.** A Solomonoff predictor of a long video of the sky must contain something equivalent to Kepler's laws: the author's own remark, in `msgs to samuel on ML mind upload difficulty.md`, is that "Kepler's laws are 'in' a video of the sky in a deep way, but in the numerical data Kepler was looking at in a much more shallow way". So the contrast is not one of content. It concerns whether the theory is a separable, queryable component, and what the inductor is given.
* (o2) **Formally, AI is still prediction.** It predicts the truth values of sentences, and with free deduction it *is* SFI on sentences restricted to consistent labellers. Precisely, it equals the coin-free version of consistent SFI within constant factors (the earlier report's Thm 6.3), and random axiom systems correspond to one-tape consistent SFI (SFI scout §0). So "answering versus predicting" is not a difference in the type of inference. It is a difference in the *data type* (sentences of a chosen language, not raw sensor strings) and in the *coherence constraint* (labellers must be logically consistent, hence closed under consequence) [assessment, resting on the cited theorem].
* (o3) **Choosing the questions is half of science.** The axiom view takes the questions, and the language they are posed in, as given. This moves the hard part out of the model (§3, L4–L5).

**Verdict [assessment].** Claim D is true in its comparative form: answering questions in a given high-level language models what theories are used for much better than predicting raw data does. The paper should state the formal content precisely. The step is a change of data type plus logical coherence. It is not a different inference principle. Answering in many directions and partiality are the two features that make the change matter (§1.7).

**A precise definition the paper can use.** Following the erotetic tradition [known: belnap1976logic, hintikka1999inquiry]:
* a *question* is a finite set Q = {φ_1, …, φ_k} of pairwise incompatible sentences of the base language (its direct answers), with their disjunction provable from the background;
* a theory T *answers* Q if T ⊢ φ_i for some i, and *answers Q partially* if it proves a disjunction of a proper subset;
* the posterior of AI induces, for each Q, the numbers Bel_D(φ_i) together with an "unanswered" mass. That mass is the defect of the semimeasure.

Under this definition AI is an ideal question-answerer for every question expressible in the base language, and raw-data prediction answers the single question "what is the next observation" [assessment; the definition is standard in form, applied here].

### 1.3 Claim S: a theory is a logical theory, not a program

**Statement.** Sources:
* the brief;
* `phil-sci-some-disanalogies-between-solomonoff-induction-and-science.md`, first bullet: "a system of talking which involves some sorts of things … about which some questions can be asked … with some relations between the answers";
* the condensation essay: concepts are not code snippets, and inferential relations are constitutive.

**Arguments for.**
* (S1) **Descriptive.** Written theories are declarative: laws, definitions and principles, not procedures that print predictions.
* (S2) **Modularity.**
  * Axioms have individual content and can be added, dropped and tested.
  * Theories in different vocabularies combine by union.
  * "The program contains this law" has no canonical meaning.
* (S3) **Inferential role.** The meaning of theoretical terms is fixed by their role in the theory, as meaning postulates [known: carnap1952meaning] and as Ramsey–Lewis functional definitions [known: ramsey1931theories, lewis1970define]. This matches the condensation essay's claim that inferential relations are constitutive of a concept.
* (S4) **Answers in many directions** (D4 again). A law is a constraint among quantities, usable from any partial information.

**Objections.**
* (o1) **Craig's collapse.** In the untimed idealisation, every consistent labeller becomes an axiom set at O(1) bits: Craig's trick [known: craig1953axiomatizability]; the earlier report's Thm 6.3; the SFI scout I2. Theoretical vocabulary is dispensable up to O(1) bits (fundamentals scout §0, language-expansion invariance). Time penalties on checking or generating axioms do not change this (SFI scout I10). So the formalism cannot see the difference in shape [proved in those records]. The author agrees (brief, "What a theory is").
* (o2) **Theories in use are partly procedural.** Methods are attached to concepts: integration, the linearity-of-expectation trick (condensation essay), numerical schemes, perturbation series, simulation codes. In §2, the derivation of a single Mars position from K12 *is* a numerical computation, a root-finding for Kepler's equation.
* (o3) **The semantic view** holds that a theory is a class of models, and that sentences are only one way to pick it out. Halvorson argued that the semantic view, taken literally, misidentifies theories [known: halvorson2012what]. Lutz argued that the remaining disagreement, about dependence on a language, is illusory [known: lutz2017what; content from abstract].

  For our purposes:
  * in first-order logic, a theory T and its model class Mod(T) determine each other up to logical equivalence;
  * the axiom view's real commitment is to a *fixed language in which questions are posed*. On this point the syntactic view is the right one for us, because questions are sentences.
* (o4) **Inconsistent theories in use.** Classical electrodynamics of point charges is inconsistent as standardly formulated [known: frisch2004inconsistency; disputed in the literature, content from abstracts]. Boltzmann's H-theorem with molecular chaos assumed at all times conflicts with reversible dynamics (Loschmidt's objection) [known: brown2009boltzmann; content from abstract]. Proof-requiring AI gives such theories weight 0. Real theories are logical theories only after domains are restricted (§3, L3).

**Verdict [assessment]. We agree with the descriptive claim:** written theories are declarative. **The explanatory claim, that this shape is good and that an ideal inducer should produce it, is open.** By Craig, any answer must be relative to a reasoner with costs, or to a community that communicates, checks and extends theories piece by piece. The paper should say both (as the brief already decided), and should list what *does* separate AI from SFI formally (§1.7).

**A caveat for the brief's own argument (S4).** "A program computes one direction cheaply" is true of a particular program, not of the class of programs. A program can consist of a generic solver, or a theorem prover, applied to a declarative law, at O(1) extra length. So the separation the brief looks for cannot be "programs lose". It has to be stated as "the optimal (time-bounded) hypothesis *factors* through a declarative core plus a generic reasoner". This is question Q2 in §5 [assessment].

### 1.4 Claim E: theories explain propositions

**Statement.** The brief says that a theory explains propositions. In the axiom view, φ is explained by T when T ∪ B ⊢ φ, where B is the background. This is the deductive-nomological pattern [known: hempel1948studies]. The quality of the explanation is measured by how short T is relative to what it derives: unification [known: friedman1974explanation, kitcher1981explanatory, kitcher1989explanatory]. AI's posterior weight 2^(−|T|) on theories proving the data is a quantitative unification measure: bits of data derived per bit of axiom. This is the brief's seed "explanatory power".

**Qualifications [assessment].**
* (E1) **Asymmetry.** Derivability is symmetric where explanation is not. The flagpole's height and the sun's elevation entail the shadow's length, and the shadow's length and the sun's elevation entail the height [known: bromberger1966why]. In the Kepler example (§2), K3 derives the period from the semi-major axis and the semi-major axis from the period, which is exactly the feature (S4) that we praised as answering in many directions. A theory as a set of axioms does not single out an explanatory direction. Kitcher answers with argument patterns [known: kitcher1989explanatory]. In AI, the generative (derivation-likelihood) variant might supply a direction: the derivation that *generated* a datum (question Q6 in §5).
* (E2) **Explanation by correction.** Newton's theory does not entail Kepler's laws. It contradicts them: Duhem's point [known: duhem1954aim; content from secondary sources]. Our computations show by how much (§2.5). What Newton derives is a *corrected* version, plus the statement that Kepler's laws hold within stated tolerances in stated domains: Schaffner's model of reduction to a corrected theory [known: schaffner1967approaches]. So "explaining a proposition" must include deriving an approximation of it with an error bound. Plain derivation does not cover the central historical case.
* (E3) **Explanation without better prediction.** Copernicus explained why superior planets retrogress exactly at opposition: retrograde motion is an effect of the Earth overtaking them [known: kuhn1957copernican; content from secondary sources]. Ptolemy had to stipulate that coincidence for each planet separately. In the axiom view, Ptolemy's system needs one extra coincidence axiom per planet, and Copernicus's system derives it. This is a clean case where derivation from a shorter theory tracks an explanatory gain with no gain in accuracy. **It is the best illustration of unification for the paper** [assessment].

**Verdict.** Write "a theory entails answers; derivation from a short theory is explanation in the unification sense, with two known gaps (asymmetry, and explanation by approximate correction)". Do not claim that derivation is explanation outright.

### 1.5 Claim L: existing language, the ladder

This is taken from the brief, and we agree:
1. raw data;
2. questions in existing abstractions (AI over a fixed language);
3. theories that extend the language;
4. theories that revise the base abstractions.

Two additions from this scout:
* **On step 2.** The base language of the Kepler example is already heavily theoretical. Heliocentric longitudes presuppose Copernican geometry and the Earth's orbit, which Kepler had to determine first (history from memory, not checked against a source). So "existing abstractions" includes earlier theory. This is the theory-ladenness of data [known: hanson1958patterns], and it is harmless for step 2 because no theory-neutral observation language is claimed.
* **On step 3.** Whether theoretical terms "pay" depends sharply on the hypothesis class: O(1) in the universal class, linear or unbounded in restricted classes (§5, Q3).

### 1.6 Claim P: axiom induction is progress over raw-data prediction

**Statement.** Axiom induction is progress over raw-data prediction both in what a theory does and in what a theory is (brief).

**Verdict [assessment].**
* **What a theory does: yes, as a step on the ladder** (§1.2).
* **What a theory is: yes for the description, no for the idealised formalism.** The formal content of the progress is the list in §1.7. **The paper should present that list in place of a general claim of progress.**

### 1.7 What does separate AI from raw-data prediction formally

Each item is a property the axiom formalism has that a predictor of an observation stream lacks. For each, the status of the claim is given.

1. **Data type.** The data are labelled sentences of a chosen language, and questions are sets of sentences (§1.2) [definition].
2. **Logical coherence.** Hypotheses are consistent and closed under consequence. Every consequence of the data gets probability 1, which SFI gets only after restriction to deductively closed labellers (SFI scout §0, "what breaks" (i)) [proved there].
3. **Partiality and the trichotomy.**
   * "Independent" is a native third value, and the semimeasure defect *is* its mass (fundamentals scout §0) [proved there].
   * If "independent" is an observed label, AI and SFI separate by an unbounded amount (SFI scout §0 (ii)) [proved there].
4. **Laws are sentences with belief values.** Bel_D(∀x φ) is defined directly. The earlier report's ω-gap distinguishes "all future data conform to the law" (confirmed) from "the theory proves the law" (not confirmed by instances) [proved there: `thm:univ:omega` in `../../../../axiom-induction/paper/sections/universal.tex`]. A predictor of observations has only the first notion.
5. **Piecemeal confirmation.** The posterior assigns credence to individual laws (Bel_D(K3)), although only whole theories meet the data. This is the Duhem–Quine situation, handled coherently [assessment; follows from the definitions].
6. **Language-relative simplicity.** The prior is over theories in the base language. Invariance under faithful translations costs 2^(K(τ)+c) (fundamentals scout §0), so the dependence of "simplicity" on vocabulary, the problem raised against best-system accounts [known: lewis1983new, cohen2009better], is bounded but not removed [proved there].

None of these is about the *shape* of hypotheses. They are about what is given to the inducer and what it outputs. **This is the honest form of the progress claim** [assessment].

### 1.8 Possible error in the author's view

**Claim and source.** The condensation essay, discussing predictions graded by L² closeness: "there is really nothing fundamentally right about these information-theoretic losses — it comes down to what the practical thing the prediction is supposed to help you with is". The author adds that he has not thought this through.

**Why it is probably overstated.** Two jobs are run together here:
* *grading* a prediction for use;
* *updating beliefs* about which theory is true.

For the first job, purposes rightly decide: tolerances, and which quantities matter. For the second, the logarithmic score is not arbitrary. It is the unique proper scoring rule that depends only on the probability given to what happened (up to affine change, for more than two outcomes) [known: bernardo1979expected; content from secondary sources]. Bayesian and MDL theory choice rest on it. Our own Kepler example (§2.4) shows the two jobs combining without conflict:
* the purpose fixes which sentences are data, namely "the longitude of Mars lies within δ of v", with δ chosen by purpose;
* the prior and the 0/1 likelihood of proof-requiring AI then select the theory.

The essay's example, "put Gaussian noise on a guess to get a log-loss predictor", is the wrong reconstruction. The right one turns the purpose-made tolerance into the *question*, not into a noise model.

**What to write instead.** Predictions in science are assessed by purpose-relative standards on high-level quantities. This is compatible with likelihood-based theory choice, which enters once the purpose has fixed which propositions are at stake.

---

## 2. The running example: Kepler's laws, and what Newton adds

### 2.1 The language

Two sorts:
* 𝔅 (bodies);
* ℝ (reals: times in days from an epoch, angles in radians, lengths in AU).

**Base (data and question) vocabulary L_obs:**
* body constants Sun, Me, Ve, Ea, Ma, Ju, Sa, Mo (Mercury, Venus, Earth, Mars, Jupiter, Saturn, Moon);
* a unary predicate Planet on 𝔅;
* function symbols λ(b, t), β(b, t), r(b, t) of sort 𝔅 × ℝ → ℝ: the heliocentric ecliptic longitude, latitude and distance of body b at time t (for the Moon, geocentric).

**Background B (not charged to any theory):**
* the axioms of an ordered field, with sin, cos and π;
* enough analysis to prove numerical bounds, for example rational-function bounds of the kind MetiTarski uses [known: akbarpour2010metitarski].

The full theory of (ℝ, +, ·, <, sin) is undecidable, because sin(πx) = 0 defines ℤ [proof sketch]. So B is a sound recursively enumerable fragment, and "T ∪ B ⊢ datum" is semi-decidable only. In practice, interval data are proved by interval arithmetic.

**Theoretical vocabulary of Kepler's theory:** element functions a, e, i, Ω, ϖ, M_0, P : 𝔅 → ℝ (semi-major axis, eccentricity, inclination, node, longitude of perihelion, mean anomaly at the epoch, period). None of these occurs in data sentences.

### 2.2 The axioms

* **K12 (Kepler's first and second laws, via Kepler's equation).** For all b with Planet(b) and all t, with M := M_0(b) + 2πt/P(b), there is E such that:
  * E − e(b) sin E = M;
  * the heliocentric position with spherical coordinates (λ, β, r)(b, t) equals Rot(b)·(a(b)(cos E − e(b)), a(b)√(1 − e(b)²) sin E, 0).

  Here Rot(b) is the rotation by ϖ − Ω, i(b) and Ω(b). The solution of Kepler's equation is equivalent, given the ellipse with the Sun at a focus, to the area law (standard).
* **K3.** For all b, b′ with Planet(b) and Planet(b′): P(b)² a(b′)³ = P(b′)² a(b)³.
* **Elements (initial conditions)** E_b: a(Ma) = 1.5237, e(Ma) = 0.0934, … as numerals or intervals.

The theory is T_K = K12 + K3 + ⋃_b E_b. Laws are reused across bodies and times. Elements are contingent, and specific to one body.

### 2.3 Data, questions, and what is explained

**Data** are true-labelled interval sentences:
* d(b, t, v, δ) := "the direction (λ, β)(b, t) lies within angle δ of v" (t, v, δ numerals);
* when distances are available, "r(b, t) ∈ [r_1, r_2]".

**Questions** are covers by such sentences, for example "where is Mars at t, to within 2′?". Two questions that are expressible in L_obs without the theoretical terms:
* the *return period*, the least p > 0 with λ(b, t+p) = λ(b, t);
* the *mean distance* of b.

**What T_K explains, and how.**
* **Each datum.**
  * T_K ∪ B ⊢ d(Ma, t, v, δ) whenever the Keplerian direction is within δ of v.
  * The derivation instantiates K12 at (Ma, t), traps E in an interval by bisection (each step one inequality provable in B), and propagates the bounds to λ and β.
  * This is a D-N explanation whose derivation is a certified numerical computation, of length polynomial in log(1/δ) [proof sketch].
* **Structural regularities, from the laws alone.** These follow without the elements, from the Ramsey sentence R(K12 + K3) := ∃a ∃e … ∃P [K12 ∧ K3]:
  * each planet's motion is periodic and planar through the Sun;
  * angular speed is greatest at least distance;
  * the squares of return periods are proportional to the cubes of mean distances.
* **No position datum follows from the laws alone.**

**Proposition 2.1 [proved].**
(a) R(T) and T have the same consequences in L_obs.
(b) R(K12 + K3) ∪ B proves no sentence d(b, t, v, δ) with δ < π.

*Proof.* (a) A model of R(T) is an L_obs-structure that expands to a model of T, by the semantics of the second-order existential. So every L_obs-sentence true in all models of T is true in all models of R(T), and conversely (T ⊨ R(T)).

(b) Fix b, t, v and δ < π. Keep a(b) and P(b) (so K3 is untouched). Choose the plane (i(b), Ω(b)) and the phase (ϖ(b), M_0(b)) so that the Keplerian direction of b at time t is −v. This is possible because the plane can be any plane through the Sun and the phase can put the body anywhere on its orbit. Define λ, β and r by K12 from these elements. This gives a model of K12 + K3 ∪ B in the standard reals in which the angle between the direction of b at t and v is π > δ. Hence it is a model of R(K12 + K3) ∪ B in which d(b, t, v, δ) is false. ∎

So laws answer only structural questions, and laws plus initial conditions answer individual position questions. This is the laws-versus-initial-conditions split in the language of questions (Q4).

**Proposition 2.2 [proved]: K3 has no content in a direction-only data language.** Let L_dir contain only the direction (λ, β), not r. Then K12 and K12 + K3 have the same consequences in L_dir.

*Proof.* A Kepler direction depends on (e, i, Ω, ϖ, M_0, P) but not on a: scaling the ellipse about the focus leaves every direction unchanged. Given a model of K12, define a′(b) := (k² P(b)²/4π²)^(1/3) for any fixed k > 0, and leave everything else unchanged. Then K3 holds, K12 still holds with the scaled positions, and all directions are unchanged. So every L_dir-consequence of K12 + K3 is an L_dir-consequence of K12. The converse is trivial. ∎

So what K3 explains depends on which sentences are data. K3 needs relative distances, which Copernicus and Kepler obtained by triangulation (history from memory). The proposition is about *heliocentric* directions. Geocentric directions depend on the ratio of each planet's orbit to the Earth's, so in a geocentric direction language K3 does have content.

**The c1 fits confirm this numerically.** The fits with K3 imposed have the same largest angular residuals as the free fits, to within 0.005′ for Mercury and Mars. The small differences arise because the fits minimise 3-D residuals, so a constrained a shifts the other elements slightly [computed: c1].

### 2.4 Approximate truth: by how much Kepler is wrong, and precision-dependent selection

**Data source.** The "observations" are ERFA's eraPlan94 (the Simon et al. analytical planetary theory) and eraMoon98 (Meeus's lunar theory), called through pyerfa 2.0.1.5. Their stated accuracy:
* plan94: maximum errors over 1800–2050 against DE102 of 17″ (Mars), 71″ (Jupiter) and 81″ (Saturn) in longitude, and no worse than 1.5 times these over 1000–3000;
* moon98: worst case 18.3″ against ELP/MPP02 over 1950–2100.

These figures are from the ERFA documentation, printed by the library itself. Neither theory is fitted to Kepler's laws. All residuals below are far above these error levels, except where noted.

**Table 2.1 [computed: c1].** Largest angular separation between one fixed least-squares Kepler ellipse (seven free elements) and the data, by window length W centred on J2000:

| W (yr) | Mercury | Mars | Jupiter | Saturn |
|---|---|---|---|---|
| 12 | 0.46′ | 1.58′ | 1.05′ | 1.70′ |
| 30 | 0.89′ | 1.86′ | 4.19′ | 3.32′ |
| 100 | 2.17′ | 3.61′ | 7.64′ | 9.73′ |
| 300 | 6.04′ | 9.17′ | 7.74′ | 11.7′ |
| 1000 | 19.3′ | 26.2′ | 31.8′ | 91.3′ |
| 2000 | 38.6′ | 51.8′ | 38.5′ | 92.4′ |

The largest residual of the least-squares fit bounds from above the smallest tolerance ε at which "Kepler plus this body's elements" is compatible with all interval data. The RMS bounds it from below, up to the difference between 3-D and angular residuals.

So **Kepler's laws are approximately true with an error that grows with the domain**:
* about 1–2′ over a decade;
* tens of arcminutes over a millennium;
* 1.1° for the Moon within a single sidereal month (moon98, one fixed ellipse: 1.12°; over one year 3.0°; over 18.6 years 9.6°).

The "domain of applicability" is quantitative here: a body, a time window, and a tolerance.

**Table 2.2 [computed: c2]. Mars over 1580.0–1600.0** (the span of Tycho's observations), heliocentric longitude in the best plane through the Sun, 7306 daily points. Fit to longitudes, then L_p-refined toward the minimax fit:

| theory | parameters | max \|Δλ\| | RMS \|Δλ\| | max \|Δr\|/r of that fit |
|---|---|---|---|---|
| circle about the Sun | 2 | 641.0′ | 454.7′ | 1.1×10⁻¹ |
| eccentric circle (Hipparchus) | 4 | 23.5′ | 15.8′ | 1.1×10⁻¹ |
| equant, bisected (Ptolemy) | 4 | 8.28′ | 5.27′ | 2.7×10⁻³ |
| vicarious hypothesis (Kepler) | 5 | 1.50′ | 0.66′ | 2.9×10⁻² |
| ellipse (K12) | 4 | 1.17′ | 0.46′ | 1.5×10⁻⁴ |

**Checks against first-order theory [proof sketch; computed agrees].** The equations of centre are:
* Kepler: 2e sin M + (5/4)e² sin 2M + O(e³);
* circle: error ≈ 2e = 639.6′ for e = 0.0930;
* eccentric circle with offset 2e: error ≈ (3/4)e² = 22.3′;
* bisected equant: error ≈ e²/4 = 7.4′.

The computed values exceed these by up to about 1′, which is the residual that remains even for the ellipse: perturbations, plus at most about 0.4′ of plan94's own error.

**When distances are fitted as well** [computed: c2 (C)]:
* the vicarious hypothesis is forced to bisection (fitted Sun–centre and centre–equant offsets 0.0932 and 0.0933), and its longitude error rises to 9.0′;
* the equant also rises to 9.0′;
* the ellipse stays at 1.25′.

**This is the structure of Kepler's argument in Astronomia Nova** ch. 16–20 [known: kepler1992new; the 8′ passage and its context from secondary sources, see refs.bib]:
* the vicarious hypothesis fits longitudes to within about 2′ but gives wrong distances;
* bisecting the eccentricity fixes the distances and produces an 8′ longitude error;
* Kepler judged that too large to blame on Tycho's observations.

Our fitted vicarious offsets (Sun–centre 0.1154, Sun–equant 0.1865) are close to the values reported for Kepler's (0.11332 and 0.18564) [known, secondary only; not checked against the text].

**Table 2.3 [computed: c2 (D)].** Compatibility with longitude data at tolerance δ (yes when max |Δλ| ≤ δ):

| δ | circle | eccentric | equant | vicarious | ellipse |
|---|---|---|---|---|---|
| 12° | yes | yes | yes | yes | yes |
| 30′ | – | yes | yes | yes | yes |
| 10′ | – | – | yes | yes | yes |
| 8′ … 2′ | – | – | – | yes | yes |
| 1′ | – | – | – | – | – |

As the precision of the data improves, the compatible theories shrink in the historical order circle → eccentric → equant → vicarious/ellipse. With distance data at about 1%, only the ellipse survives. Below about 1.2′ over 20 years, even the ellipse fails: Newton is needed. Compatibility is monotone in δ, since a datum at precision δ′ < δ implies the datum at δ [proved, trivially].

**Code lengths [computed: c2 (E)].** The elements cost:
* 35–42 bits (four elements) at δ ≥ 10′;
* 55–62 bits at δ = 8′–2′, for the ellipse.

One datum stated outright costs log₂(π/δ): 7.5 bits at 60′, 12.4 bits at 2′. So the elements pay for themselves after about 5 data. The law texts are not counted. Their lengths depend on the formalisation and differ between the candidates by an amount we did not measure. Because the parameter counts are equal (4 for eccentric, equant and ellipse), the choice among compatible theories is decided by the law texts, that is, by the syntax. This is the language-relativity of simplicity again (§1.7, item 6).

**Proposition 2.3 [proved]: proof-requiring AI prefers a false exact law to its true tolerance-weakened version.** Setting:
* T_0 := an exact law plus elements; it asserts dir(b, t) = K(t) for a computable K;
* T_ε := the same elements plus "dir(b, t) lies within ε of K(t)", with ε > 0 written as a numeral;
* assume a fixed prefix code for theories in which writing the tolerance clause and the numeral ε costs at least one bit, so |T_ε| ≥ |T_0| + 1;
* data d(b, t_j, v_j, δ) with true directions u_j, angle(u_j, v_j) ≤ δ_0.

Then:
(a) T_0 ⊢ d_j iff angle(K(t_j), v_j) ≤ δ. T_ε ⊢ d_j iff angle(K(t_j), v_j) + ε ≤ δ.
(b) Hence every data set compatible with T_ε is compatible with T_0. The posterior odds of T_0 against T_ε are at least 2^(|T_ε| − |T_0|) ≥ 2 on every data set compatible with T_ε, at every sample size.
(c) If the true error e* := sup_t angle(K(t), u(t)) is positive, T_0 is false. T_ε is true whenever ε ≥ e*.

*Proof.* (a) A spherical cap of radius ε about c is contained in the cap of radius δ about v iff angle(c, v) + ε ≤ δ, for ε + angle(c, v) < π. T_0 proves dir(b, t_j) = K(t_j), and proves d_j iff K(t_j) lies in the δ-cap about v_j. T_ε proves exactly that dir lies in the ε-cap about K(t_j), and nothing finer about dir(b, t_j). It proves d_j iff the ε-cap lies in the δ-cap.

(b) Compatibility is all-or-nothing in proof-requiring AI. By (a), T_ε ⊢ d_j implies T_0 ⊢ d_j, and consistency is inherited because T_0 proves the data. The prior ratio is 2^(|T_ε| − |T_0|).

(c) Immediate. ∎

**Consequences [assessment].**
* The simplicity prior alone makes the inducer believe exact laws that are false at finer precision than the data. Its answers to finer questions ("within δ′ < e* of K(t)") are overconfident: T_0 asserts them, and they are false for some t.
* T_ε is *silent* on such questions: they are independent of it. **Honest approximate theories are partial theories**, and the trichotomy is the device that makes this expressible.
* Getting honest approximate theories out of AI needs more than the 0/1 likelihood. Candidates:
  * the generative variant, where a theory that would generate sharper sentences than are ever observed pays by the size principle;
  * an explicit prior over tolerances;
  * a requirement that theories answer only at the precision they were tested at.

  This is question Q1 in §5.

### 2.5 What Newton adds

**Language.** Newton's theory extends the language with:
* a mass function m : 𝔅 → ℝ;
* the gravitational constant G;
* accelerations, which need a sort of trajectories or an axiomatised derivative in B.

The law is m(b)·ẍ_b = Σ_{b′≠b} G m(b) m(b′)(x_{b′} − x_b)/|x_{b′} − x_b|³. The data language L_obs is unchanged. This is ladder step 3: theoretical terms with no new data vocabulary. Masses are T-theoretical in Sneed's sense: they are measurable only by using the theory [known: sneed1971logical, balzer1987architectonic].

**What it adds, with sizes.**
1. **Unification.** One law plus one number per body replaces K12 + K3 for every body. It derives the two-body form of K3 with a mass-dependent constant: n²a³ = G(M + m), so q := n²a³/k² = 1 + m/M.

   **Computed fitted values of q** [computed: c1]:
   * Jupiter (windows ≥ 30 yr): q ∈ [1.00075, 1.00099]; two-body value 1.00095.
   * Saturn: q ∈ [1.0013, 1.0019]; two-body value 1.00029.

   Saturn is explained by the orbit-averaged pull of Jupiter, which acts like an interior ring adding to the central mass. The ring estimate q = 1 + m/M + Σ_j (m_j/M) a² f_j(a) gives:
   * Saturn 1.00154, of which Jupiter supplies 1.25×10⁻³;
   * Jupiter 1.00093 [computed: c3; a secular, circular, coplanar heuristic, not a perturbation theory].

   So the "constant" of Kepler's third law differs between planets at the 10⁻³ level, and Newton says why.
2. **Corrections inside the old domain.**
   * Mercury's line of apsides advances 575.4″ per century in the fixed J2000 frame (fit over 100–2000 yr; the precession variant cuts the 2000-year residual from 38.6′ to 9.95′) [computed: c1].
   * The classical decomposition [known: clemence1947relativity; the figures 531.54″ and 574.10″ from secondary sources]:
     * observed, relative to the equinox: 5599.74″;
     * minus general precession: ≈ 574″;
     * Newtonian planetary perturbations: ≈ 531.5″;
     * remainder: 42.56″, which is general relativity.

     Newton's own domain ends here, at 43″ per century.
   * Saturn's longitude residual from a fixed ellipse over 2000 years contains an oscillation of period about 900 years and amplitude 43.8′; Jupiter's has period about 910 years and amplitude 18.3′ [computed: c1]. This is the great inequality explained by Laplace [known: wilson1985great for the history; period and amplitude not checked against the source].
3. **New questions in the old language, and new answering directions.**
   * The masses of the Sun and of planets with satellites.
   * "Where is the body perturbing Uranus?": Le Verrier's Neptune, also Kripke's example of a reference fixed by a description [known: kripke1980naming; content from secondary sources].
4. **New domains.**
   * The Moon, where Kepler fails by 1.1° in a month [computed: c1].
   * Falling bodies, tides, comets. These need further base vocabulary, so the language grows too.
5. **No deductive entailment of Kepler.** Newton's axioms do not entail K12 or K3. They entail corrected statements, plus "K12 holds within ε(b, W) on window W", with ε as in Table 2.1 (E2 above).

   The formal derivation of even one such bound from the ODE needs:
   * an existence-and-uniqueness theorem;
   * a validated integration or a perturbation estimate.

   This is a very long derivation that no textbook writes out. **This is the textbook point in a concrete case** [assessment].

### 2.6 Which parts could be computed

**Done:**
* (a) The residuals and compatibility tables (Tables 2.1–2.3), the element code lengths and the q constants (c1–c3).
* (b) Propositions 2.1–2.3, which need no computation.

**Feasible, not done:**
* (c) **The proof-requiring AI posterior over a finite pool** (circle, eccentric, equant, vicarious, ellipse; with and without K3; two-body Newton; ring-corrected Newton) at each data precision. This needs a fixed syntax for the law texts, so that |T| is defined. It is a direct analogue of the earlier report's exact posteriors over hand-picked pools.
* (d) **Formal derivations of interval data** from K12 + elements in a prover for real special functions (MetiTarski-style), giving derivation lengths as functions of δ, for a derivation-charged variant.

**Feasible but heavy:**
* (e) A validated N-body integration certifying "Kepler within ε on window W" from Newton plus initial conditions. Fitting N-body initial conditions to plan94 would be needed, because plan94's osculating velocities are not accurate enough to integrate from directly; its documented velocity errors are about 20 m/s RMS for Saturn.

**Not computable:**
* (f) The universal AI posterior itself (it is not lower semicomputable; fundamentals scout §0).

---

## 3. Limitations of the axiom view

Each item gives the sharp statement, the source in the notes, and whether it is partially addressable formally (a candidate research question) or a genuine limit.

**L1. Written theories are far from sufficient for a simple reasoner (the textbook point).**
* **Sources:**
  * brief (the author's request);
  * `phil-sci-our-science-is-very-human-software.md` ("those predictions are very much not just made by formal inferences from the letter of the theory");
  * `phil-sci-scientific-theories-are-not-for-generating-or-predicting-arbitrary-data.md` (the Feynman, IPhO and EuPhO problems);
  * `phil-sci-some-disanalogies…` bullet 3 (tacit understanding);
  * the condensation essay ("the notions of newtonian mechanics alone are inert").
* **Sharpened [assessment].** The insufficiency has three parts, and the paper should separate them:
  * **(a) The bridge gap.** A problem posed in ordinary terms ("a rope over a pulley …") does not become a formal problem without idealisations and bridge principles, which the written theory does not contain. For the problem as posed, the theory is *logically* insufficient. This is Cartwright's "preparing the description" and the models-as-mediators thesis [known: cartwright1983how, morgan1999models].
  * **(b) The computational gap.** For the formalised problem the theory, together with mathematics, is logically sufficient, but finding the answer needs methods, lemmas and approximation schemes: the derivation of Kepler-within-ε from Newton in §2.5. Here the theory is *computationally* insufficient.
  * **(c) The tacit gap.** Perceptual and manual skills: reading instruments, recognising situations [known: polanyi1958personal, polanyi1966tacit], and the exemplars through which problems are seen as like solved ones [known: kuhn1970structure, kuhn1977second].
* **Formal status:**
  * (a) partially addressable: bridges are more axioms in a larger language. A measurable question is how large the bridge and method parts are compared with the "physical picture".
  * (b) partially addressable: costed deduction. The induced theory for a bounded reasoner contains lemmas and derived rules (Q5); the earlier report already found that frequently used lemmas become axioms under a derivation cost.
  * (c) a genuine limit for a declarative view.

**L2. Approximate truth.**
* **Sources:**
  * brief ("kepler's laws not really giving you correct predictions");
  * `hanni-solomonoff-axiom-induction.md` ("we should have a metric on values grade generated sentences");
  * the condensation essay (purpose-made metrics).
* **Sharp statement.** Kepler's laws as stated are false. They are compatible with data at precision δ exactly when δ exceeds their error on the domain (§2.4, computed). Proof-requiring AI then prefers the false exact law to the true weakened one at every sample size (Proposition 2.3) and answers finer questions overconfidently.
* **Formal status:** partially addressable (Q1). Tolerance-weakened axioms, metric-graded data and the generative variant are concrete starting points. The literature on truthlikeness shows how hard a *general* comparative notion is: Popper's definition fails for false theories [known: popper1963conjectures, miller1974popper, tichy1974popper], and the similarity approach needs a metric on possible worlds [known: niiniluoto1987truthlikeness]. The structuralists formalised approximate application with "blurs" [known: moulines1976approximate, balzer1987architectonic]. **What is open:**
  * a canonical metric (none exists; the metric is purpose-relative, see §1.8);
  * the relation of approximation between theories (Newton to Kepler as m/M → 0 and perturbations → 0), Schaffner's corrected reduction [known: schaffner1967approaches].

**L3. Domains of applicability, multiple models, inconsistent theories in use.**
* **Sources:**
  * `phil-sci-the-domain-of-applicability-of-a-scientific-model.md`: flat-earth 100 m versus spherical-earth 99.9 m, then "use 100 = 99.9 in some algebraic manipulations"; Stosszahlansatz plus Newtonian mechanics;
  * `phil-sci-some-disanalogies…` ("having multiple ways to think about something");
  * the condensation essay (the Earth as sphere, oblate spheroid, rugged).
* **Sharp statement.** Practice uses several mutually inconsistent models, each in its own domain. A single consistent axiom set must relativise each model to a domain predicate (Dom(x) → law(x)) or drop one of them. Proof-requiring AI gives a globally inconsistent theory weight 0, however useful it is.
* **Formal status:**
  * **The specific catastrophe is formally blocked.** Write the approximations as tolerances. Approximate equality ≈_ε is not transitive, so "100 ≈ 99.9" licenses no algebra. We disagree mildly with the note's "I don't think any nice formal criterion is going to be right": for this failure mode there is one.
  * **Domains are formalisable.** They are restricted axioms, or structuralist intended applications [known: balzer1987architectonic], and learning a domain is a candidate question (Q8).
  * **Knowing when a model applies is not formalised here.** "Don't do that, silly!" in the note is a *recognizer* (L6), and that part is a genuine limit of the declarative view.

**L4. Science predicts only very particular things, and makes the set-ups in which it can predict.**
* **Sources:**
  * `phil-sci-science-predicts-only-very-particularly.md` (the cannon with consistent muzzle velocity);
  * `predicting-specific-things.md` (where the invented predictands come from);
  * `phil-sci-some-disanalogies…` bullets 2, 5, 6 (Kirchhoff's laws needed circuits);
  * the condensation essay.
* **Sharp statement.** AI captures half of this: the data are a selected set of sentences, and theories are partial. It does not capture:
  * which questions are worth asking (relevance, interestingness);
  * the building of set-ups that make questions answerable [known: hacking1983representing].
* **Formal status:**
  * the selection of data is modelled in the earlier report: human-stated theorems are misspecified data, with KL-minimising limits. This is partially addressable;
  * value-weighted questions are a further partial handle;
  * the origin of the predictands, and the making of phenomena, are a genuine limit.

**L5. Concept formation and language change (ladder steps 3–4).**
* **Sources:**
  * `phil-sci-some-disanalogies…` bullet 4: Faraday's lines of force; Lorentz, Poincaré and Einstein on Michelson–Morley; "the bayesian conception basically completely fails to model gaining scientific understanding";
  * `treating many weird cases in language as language change.md`;
  * `good-concepts-are-concepts-that-support-inferences.md`;
  * `how come a new concept can expand our understanding?.md`;
  * the condensation essay ("a system for making new concepts of old ones").
* **Sharp statement.**
  * AI selects among theories in a fixed language.
  * Step 3, new terms with old data, is reachable, but whether a new term *pays* depends on the hypothesis class (Q3).
  * Step 4, revising the base concepts (simultaneity; "earth" as fixed, in Kuhn's Copernicus example quoted in the language-change note [known: kuhn1970structure]), has no formal handle in AI.
* **Formal status:** step 3 partially addressable; step 4 a genuine limit for now.

**L6. What concepts do (the condensation essay's list), item by item.**

| item in the essay | does the axiom view capture it? |
|---|---|
| inferences, and inferential relations as constitutive | **yes**: axioms are inferential relations; meaning postulates and Ramsey–Lewis definitions [known: carnap1952meaning, lewis1970define]; inferential-role semantics [known: sellars1953inference] |
| compositionality (bear + has-a-scarf) | **yes**: first-order formulas compose; this is a strength over code snippets |
| concepts built from pointers ("London is the capital of the UK"), later enriched | **yes**: a constant introduced by one reference-fixing axiom, then accumulating axioms; Kripke's reference fixing by description [known: kripke1980naming] |
| new concepts from old (affixation, compounding) | **partly**: explicit definitions are definitional extensions; which definitions to introduce is the prior's business (Q3) |
| support for learning (new inferential links added under rules) | **partly**: adding axioms and posterior updating; the "rules governing how these are established" are the inducer itself |
| analogy between thoughts | **partly**: an analogy is a partial interpretation between theories; this is formalisable (structure mapping [known: gentner1983structure]; models and analogies [known: hesse1963models]; the author's `model-thinking-in-mathematics.md`), but *finding* analogies is not modelled |
| natural types (nouns, adjectives, verbs) | **partly**: sorts and arities give a type system; that these types *emerge* is not modelled |
| one notion, different recognizers (the blind and the deaf person's "train station") | **partly**: sameness of notion is identity of the predicate symbol, plus different bridge axioms; the language fixes it; it is not discovered |
| recognizers (when a concept applies; the chair; recalling integration) | **no**: recognition is a procedure on situations, not an axiom |
| purposes (a door is for passing through) | **no**: axioms can state functions, but the *use* of purposes in search ("wishes matched with purposes") is not in the view |
| methods attached to concepts (the linearity-of-expectation trick; using a hammer) | **no** for motor methods; **partly** for mathematical methods, as derived rules or lemmas for a bounded reasoner (Q5); Craig says methods can be axioms, but at a cost |
| softness, flexibility, meaning change (sphere, oblate spheroid, rugged; "satellite" of a person) | **no**: first-order predicates are sharp; the sphere-versus-spheroid case is partly the tolerance device of §2.4; metaphorical extension is not modelled; see M. Wilson on how concepts behave in patches [known: wilson2006wandering] and Lakatos on concept-stretching [known: lakatos1976proofs] |
| clarification (the "ears in my field"; coherence-seeking) | **no** in the inducer; interpretation as abduction is a formal model of it [known: hobbs1993interpretation], so partially addressable outside AI |
| action-facing concepts (doors, rooms) | **no** |
| reinforcement structures for "hanging together" | **no** |

**Verdict [assessment].** The axiom view captures the *static, declarative, inferential* side of concepts. It misses the *procedural* side (recognition, methods, action) and the *dynamic* side (purposes, softness, clarification, meaning change). This is less than the essay asks of a theory of concepts. **But a theory of concepts is not what the paper offers.** It offers a model of the declarative core of scientific theories, and the paper should say so in those words.

**L7. Discovery is not selection.**
* **Source:** `phil-sci-some-disanalogies…` bullet 4.
* **Sharp statement.** AI is an ideal of *evaluation* over a fixed space of hypotheses. It says nothing about how a decent way of thinking is found. The Mars sequence of §2.4 shows the evaluation side working: given each precision, compatibility picks out the historically chosen theory. Finding the ellipse took Kepler years of search (history from memory).
* **Formal status:** a genuine limit of the idealised inducer. Resource-bounded search is a formal handle on search, not on understanding.

**L8. Statistical theories (found by us).**
* **Sharp statement.** Statistical mechanics, quantum mechanics and population genetics answer with probabilities, and their data are frequencies. Proof-requiring AI with true/false sentences reaches them only through sentences about probabilities, whose relation to finite frequency data is not deductive. Hempel and Oppenheim already flagged the extension of D-N to statistical laws as open [known: hempel1948studies; from the paper's statement as quoted in a citing source].
* **Formal status:** partially addressable through the generative (derivation-likelihood) variant, or through probabilistic sentences in the language.

**L9. Theory-laden and fallible data (found by us).**
* **Sharp statement.**
  * Kepler's "data" were heliocentric positions computed from Tycho's geocentric angles through a model of the Earth's orbit (history from memory).
  * AI takes labels as correct, so one mislabelled datum forces an exception axiom.
* **Formal status:** partially addressable. The earlier report's corruption-channel noise model handles errors; theory-ladenness is harmless at ladder step 2 (§1.5) [known: hanson1958patterns].

**L10. Purposes, technology, and the creation of phenomena.**
* **Sources:**
  * `phil-sci-some-disanalogies…` bullets 5–6 (thermodynamics, circuits, lenses);
  * `philosophy/philosophy of doing/a world of purposes.md`;
  * `philosophy/concepting/what do we want from our concepts?.md`;
  * Hacking [known: hacking1983representing].
* **Formal status:** a genuine limit.

**L11. Science as a social structure.**
* **Source:** `phil-sci-some-disanalogies…`, last bullet.
* **Formal status:** a genuine limit as stated. **But it may be where the explanatory question of §1.3 gets its answer:** declarative theories can be communicated, split among people, checked piece by piece and extended. A formal version would ask which hypothesis shapes are cheap to *verify jointly by several bounded agents*. This is speculative; we list it under Q2.

**L12. The mathematics is free, and huge.**
* **Source:** `philosophy/concepting/some points against the world modeling story.md` ("you needed to invent real numbers"; "where is the R^3 structure given?").
* **Sharp statement.** In §2 the background B (ordered fields, trigonometry, and for Newton analysis and ODE theory) is free. Historically it was invented along with the physics: Newton's calculus.
* **Formal status:** partially addressable. Charge B as part of the hypothesis. By invariance this changes little in the universal setting, but a lot in derivation-charged settings.

---

## 4. Literature the section must engage

Bibliographic data for every key below were verified by WebSearch on 2026-10-15. `refs.bib` records, entry by entry, what was confirmed and what was not; content claims marked "secondary" rest on abstracts or citing works. For each entry, a sentence or two on its relation to the paper.

**Syntactic versus semantic view**
* **suppe1977structure** (Suppe ed., *The Structure of Scientific Theories*, 2nd ed., 1977). The standard account of the "received view" (theories as axiomatised sets of sentences, with an observational/theoretical split) and its critics. The axiom view is a descendant of the received view, minus the observational/theoretical dichotomy (ladder step 2).
* **suppes1960comparison** (Suppes 1960, Synthese 12) and **vanfraassen1980scientific** (van Fraassen 1980): the semantic view.
  * Our reply: questions are sentences, so a theory that answers questions is naturally syntactic.
  * Van Fraassen's ch. 5 also gives the *erotetic* account of explanation (an explanation is an answer to a contrastive why-question), which is close to the paper's "theories answer questions".
* **halvorson2012what** (Phil. Sci. 79) and **lutz2017what** (PPR 95): the case that the semantic view gains nothing over the syntactic one, and that the remaining difference, language dependence, is illusory. Cite these to justify working syntactically without apology.
* **sneed1971logical**, **balzer1987architectonic**, **moulines1976approximate**: structuralism.
  * Its "intended applications" formalise domains of applicability (L3).
  * Its approximation apparatus formalises approximate truth (L2).
  * Its notion of T-theoretical terms (mass in classical mechanics) fits §2.5.

**Explanation**
* **hempel1948studies** (Phil. Sci. 15): D-N explanation; the axiom view's "T ⊢ φ" is its formal core. The paper itself flags statistical explanation as open (L8).
* **friedman1974explanation** (J. Phil. 71) and **kitcher1981explanatory** (Phil. Sci. 48), **kitcher1989explanatory** (Minnesota Studies 13): explanation as unification.
  * The posterior weight 2^(−|T|) on theories deriving the data is a quantitative unification measure.
  * Kitcher's argument patterns are the unificationist's answer to asymmetry (E1).
* **bromberger1966why** (in *Mind and Cosmos*): why-questions; the flagpole-type counterexamples to D-N. Derivability is symmetric (E1).
* **woodward2003making**: invariance as the mark of explanatory generalisations. It is relevant to Q6, since invariance across contexts may supply the explanatory direction in a generative model.
* **kuhn1957copernican**: the Copernican explanation of retrograde motion at opposition (E3), the cleanest case of unification without better accuracy.

**Craig, Ramsey, Hempel; theoretical terms**
* **craig1953axiomatizability** (JSL 18) and **craig1956replacement** (Phil. Rev. 65): the theorem, and its application to eliminating auxiliary (theoretical) expressions. The collapse of AI into consistent function induction is this construction.
* **hempel1958theoretician** (Minnesota Studies II): the theoretician's dilemma. Theoretical terms are either unnecessary (Craig, Ramsey) or fail to serve their purpose. His reply: Craigian axiomatisations are unwieldy (from memory), and theoretical terms may be needed for *inductive* systematisation (confirmed from an abstract). The SFI scout's §3 turns "unwieldy" into theorems about derivation size. Hempel's inductive point is exactly the AI setting, where predictive probabilities of the inductive kind depend on the prior over theories in the larger language.
* **putnam1965craig** (J. Phil. 62): Craig's theorem does not vindicate instrumentalism; the Craig substitute is impractical (content from secondary sources).
* **ramsey1931theories** and **lewis1970define**: Ramsey sentences, and functional definition of theoretical terms. Proposition 2.1 is the Ramsey sentence of Kepler's laws.
* **kleene1952finite** (Memoirs AMS 10) and **craigvaught1958finite** (JSL 23): every recursively axiomatisable theory with only infinite models has a finitely axiomatised conservative extension in a larger language (content from secondary sources).
  * This is the precise sense in which theoretical predicates buy *finite* axiomatisability (Q3).
  * The classical instances are NBG over ZF and ACA₀ over PA (known; secondary).
* **carnap1956methodological** (Minnesota Studies I) and **carnap1952meaning** (Phil. Studies 3): the two-language picture with correspondence rules, and meaning postulates. Carnap's observation language sits between ladder steps 1 and 2; our base language is not observational.

**Laws: the Mill–Ramsey–Lewis best system**
* **lewis1973counterfactuals** (pp. 72–77), **lewis1983new** (AJP 61), **lewis1994humean** (Mind 103): laws are the theorems of the true deductive system that best balances simplicity and strength.
  * **AI with a 2^(−|T|) prior and the proof-requiring constraint is a formal best-system account:** strength is fixed by the requirement to prove the data, and simplicity is code length.
  * Lewis's trivialisation worry is our language-relativity (§1.7, item 6): with perverse primitive vocabulary, any system can be stated very simply (content from secondary sources). His fix (natural properties) corresponds to fixing the base language.
* **cohen2009better** (Phil. Studies 145): best systems relativised to a choice of kinds. This is the honest form of the AI prior's dependence on the language.
* **woodward2014simplicity** (BJPS 65; pages not confirmed): doubts that the simplicity–strength trade-off appears in scientific practice. Relevant to §2.4, where the trade-off is decided by data precision and the law texts, and where the parameter counts tie.

**Verisimilitude and approximate truth**
* **popper1963conjectures** (ch. 10), **miller1974popper**, **tichy1974popper** (BJPS 25): Popper's truthlikeness, and its refutation for false theories. A general comparative notion is hard. Our tolerance-relative notion (§2.4) is deliberately local: question, tolerance, domain.
* **niiniluoto1987truthlikeness**: the similarity approach, which needs a metric (cf. §1.8: the metric is purpose-relative).
* **laudan1981confutation** (Phil. Sci. 48) and **psillos1999scientific**: whether approximate truth explains success, and the pessimistic induction. Relevant if the paper says anything realist about theories induced by AI; we recommend that it does not.
* **duhem1954aim**: Newton's gravitation contradicts Kepler's laws, so it cannot be induced from them (content from secondary sources). This is E2, made quantitative in §2.5.
* **schaffner1967approaches** (Phil. Sci. 34): reduction to a *corrected* reduced theory. This is the right model of "Newton explains Kepler".
* **harper2011newton**: Newton's inferences from approximate phenomena, and measurement of theoretical parameters. Harper's thesis, in the publisher's description, is that Newton's method "aims to turn theoretical questions into ones which can be empirically answered by measurement from phenomena". That is a question-answering view of theories (content from the description and reviews).

**Cartwright and models**
* **cartwright1983how** and **cartwright1999dappled**:
  * fundamental laws are true only of models;
  * the world is "dappled", with laws holding in limited domains.

  These are the strongest published form of L2 and L3. The axiom view can accommodate them only through domain-restricted and tolerance-weakened axioms.
* **morgan1999models**: models as autonomous mediators between theory and world. This is the bridge gap of L1(a).
* **frisch2004inconsistency**: a successful but inconsistent theory (L3, objection o4 of §1.3).
* **brown2009boltzmann**: the H-theorem and its discontents. The author's Stosszahlansatz example (L3).

**Tacit knowledge and exemplars**
* **polanyi1958personal** and **polanyi1966tacit**: tacit knowledge, which cannot be fully stated (content from memory and secondary descriptions). This is L1(c).
* **kuhn1970structure** (2nd ed.; that this printing carries the 1969 Postscript was not confirmed by the search) and **kuhn1977second**: exemplars, meaning that problems are solved by seeing them as like solved problems. This is the strongest literature version of the textbook point. An axiom view has no place for exemplars except as data.

**Carnap and inductive logic**
* **carnap1950logical** (*Logical Foundations of Probability*): probabilities on the sentences of a formal language. This is the direct ancestor of probabilities over sentences in AI. AI replaces Carnap's symmetric measures with a simplicity prior over theories.
* **putnam1963degree** (in Schilpp ed.; pages not confirmed): Putnam's diagonal argument that a computable confirmation function fails to confirm some effectively computable regularity (content from memory; not checked in the essay). This is the diagonal limit that also bounds AI (the earlier report's diagonal separation).
* **carnap1950empiricism** (Rev. Int. Phil. 4): linguistic frameworks, internal and external questions.
  * "Questions in an existing language" are internal questions.
  * Ladder steps 3–4 are changes of framework.
  * The author's note `phil-sci-an-argument-sorta-against-antirealism.md` argues against treating the choice of framework as merely pragmatic, close to Quine's objection to Carnap; not used in the paper.

**Logic of questions and inquiry**
* **belnap1976logic** and **hintikka1999inquiry**: questions as sets of direct answers; inquiry as interrogation. These give the definition in §1.2.
* **laudan1977progress**: science as problem-solving. The broadest version of claim D.

**Formal learning and probabilities on sentences**
* **solomonoff1964formal**: the raw-data baseline.
* **gaifman1964concerning** (Isr. J. Math. 2) and **gaifman1982probabilities** (JSL 47): probabilities over first-order sentences; convergence to truth in rich languages. Compare AI's posterior on Th(ℕ)-type data (fundamentals scout §0, "limits").
* **kelly1996logic** and **martin1998elements**: formal learning theory of first-order theories, identification in the limit. These are the non-Bayesian counterpart of AI's limit theorems.

**Concepts, analogy, meaning change, interpretation**
* **sellars1953inference**: material inference and meaning, i.e. inferential relations as constitutive (L6).
* **wilson2006wandering**: concepts behave differently in different patches; the best account of the "softness" in L6.
* **lakatos1976proofs**: concept-stretching under counterexamples; meaning change in mathematics. The author's notes quote it.
* **kripke1980naming**: reference fixed by description. Le Verrier's "Neptune" links pointers (L6) to Newton (§2.5).
* **gentner1983structure** and **hesse1963models**: analogy as structure mapping; models and analogies in science (L6).
* **hobbs1993interpretation**: interpretation as abduction, i.e. clarification (L6).
* **hanson1958patterns**: theory-laden observation (§1.5, L9).
* **hacking1983representing**: intervention and the creation of phenomena (L4, L10).

**Proof theory and scoring rules used above**
* **statman1979lower**: non-elementary lower bounds for eliminating cuts (lemmas). The formal reason why theories for bounded reasoners contain lemmas (Q5).
* **bernardo1979expected**: uniqueness of the log score (§1.8).
* **akbarpour2010metitarski**: automated proofs of inequalities with sin and cos (§2.6(d)).

**Astronomy**
* **kepler1992new**, **wesley1978accuracy**, **clemence1947relativity**, **wilson1985great**, cited in §2.

---

## 5. Formal questions suggested by the philosophy, ranked

Each question comes with what is already known or proved and what would count as an answer.

**Q1. Approximate truth and precision-dependent selection** (ranked first: tractable, needed for the running example, and with a negative result already in hand).
* **In hand:**
  * Proposition 2.3 [proved]: with interval data, proof-requiring AI prefers false exact laws, and its finer-precision answers are overconfident;
  * compatibility is monotone in precision [proved];
  * a computed instance, the Mars sequence of Table 2.3.
* **The question.** Find a variant whose posterior satisfies three requirements:
  * (i) it prefers a theory T until the data precision falls below T's error on the domain, then switches to the more exact theory, with the switch point computable;
  * (ii) its answers at finer precision are calibrated, or abstain (the "independent" value).

  Candidates are the generative variant with the size principle, or an explicit tolerance prior.
* **A natural target theorem.** For data at precision δ_n → 0 from a process within ε* of a law family, the posterior mass moves from K to K + corrections when δ_n < ε*, and the switch point is computable.

**Q2. Theory shape relative to a reasoner** (ranked second: central to claim S, but harder).
* **The question.** In the untimed universal setting, a generic reasoner is O(1), so the question must be asked with time bounds: *when does the optimal time-bounded hypothesis factor as a fixed reasoner applied to a short declarative core?*
* **A computable toy.** k linear relations among n quantities. Queries supply any n − k quantities and ask for the rest, giving C(n, k) directions.
  * A declarative core is the k × n matrix (O(kn) numbers) plus elimination at query time, in time O(k³).
  * A procedural hypothesis stores per-direction solutions, C(n, k)·O(k²) numbers, at query time O(k²).

  Map the optimum as a function of the number of query directions in the data and of the time bound.
* **Expected answer [conjecture].** Declarative cores win when the data span many directions and the time bound allows a generic reasoner. Procedures win for few directions under tight time.
* **Extension.** The variant with several agents, where the hypothesis must be checkable piece by piece (L11), is a second, more speculative form.

**Q3. In which hypothesis classes do theoretical terms pay?**
* **The hierarchy, assembled from proved and known results:**
  * **universal r.e. class:** O(1) [proved: fundamentals scout §0 (language-expansion invariance), the Craig construction];
  * **derivation-charged classes:** the SFI scout §3. Craig-type observational axiomatisations fit exactly the polynomial-time regularities at polynomial derivation budgets. Elimination with padding by proofs costs only O(1) length and a polynomial in derivation size, so what survives elimination is the proofs, not the vocabulary;
  * **finite axiom sets:** possibly unbounded. Kleene and Craig–Vaught give finite axiomatisability with extra predicates; NBG over ZF and ACA₀ over PA are instances [known; secondary];
  * **implication graphs between atomic properties** (the author's complete-bipartite factoring in `good-concepts-are-concepts-that-support-inferences.md`): n·m edges versus n + m [proved below];
  * **full first-order logic with explicit definitions:** gain proportional to reuse [proof sketch below].
* **Proposition 5.1 [proved].** Let L contain unary predicates A_1, …, A_n, B_1, …, B_m. Let T_dir := {∀x(A_i x → B_j x) : i ≤ n, j ≤ m}, and let T_X := {∀x(A_i x → X x)} ∪ {∀x(X x → B_j x)} in L ∪ {X}. Then:
  * (a) Cn(T_X) ∩ Sent_L = Cn(T_dir);
  * (b) in the class of theories made of implications between two atoms, T_dir needs nm axioms and T_X needs n + m;
  * (c) in full first-order logic, T_dir is equivalent to the single sentence ∀x((A_1x ∨ … ∨ A_nx) → (B_1x ∧ … ∧ B_mx)), of length O(n + m), so X saves only a constant factor there.

  *Proof.*
  * (a) T_X ⊢ A_i → X → B_j. Conversely, every model of T_dir expands to a model of T_X with X := A_1 ∪ … ∪ A_n, which is contained in B_1 ∩ … ∩ B_m in any model of T_dir. Hence every L-consequence of T_X holds in every model of T_dir.
  * (b) is counting.
  * (c) The sentence is equivalent to the conjunction of T_dir by propositional logic. ∎

  So the author's "new concept factoring a complete bipartite inference graph" pays in restricted inference formats: atom-to-atom rules, as in a cheap symbolic engine. In unrestricted logic, the "artificial" X := ⋁A_i is already available, as the note itself observes. The real gain of a *good* X, one with short independent characterisations ("TFAE"), must come from reuse across many inference graphs, or from derivation costs.
* **Reuse [proof sketch].** If a defined formula of length ℓ is used k times, the definitional extension saves about (k − 1)ℓ − O(1) symbols.
* **The research question.** For the earlier report's template (schema) prior, which sits between finite and r.e.: do theoretical predicates pay, and by how much? Two observations [assessment]:
  * under templates a schema costs O(1), so the advantage of NBG over ZF shrinks to a constant;
  * the interesting case is therefore derivation-charged templates.

**Q4. Laws versus initial conditions.**
* **In hand:** Proposition 2.1 (laws alone answer no position question) and the element bits in c2.
* **The question.** Does Paper 2's model–randomness split (the kink of a steeper prior) separate K12 + K3 from the elements on data from many bodies, uniformly in the number of bodies? This connects to the brief's seed and to the fundamentals scout's "laws-plus-exceptions" loss bound.

**Q5. Lemmas and methods for bounded reasoners (the textbook point, part (b)).**
* **The question.** Under a derivation budget, the optimal theory contains lemmas, i.e. derived rules. Quantify the trade-off between the length of the axioms and their usability. The non-elementary cut-elimination lower bounds [known: statman1979lower] show that lemma-free theories can be non-elementarily worse for a cut-free reasoner. Relate this to the earlier report's short-derivations results.
* **A test case.** Newton plus a perturbation lemma ("Kepler within ε on W") against Newton alone.

**Q6. Explanation and asymmetry in the generative variant.**
* **The question.** Define the explanation of a datum as the posterior over the derivations that generated it. Does a direction emerge?
* **Toy.** Shadow lengths at many sun angles, with one fixed pole height.
  * The theory with the height as an axiom derives every shadow in one step.
  * The theory with one shadow as an axiom derives the height first.

  Under pure code length they tie up to O(1). Under derivation length the height-axiom theory wins [proof sketch]. Asymmetry would then come from *invariance across contexts* [cf. woodward2003making].

**Q7. Piecemeal confirmation.** Bel_D(law) is defined (§1.7, item 5). When does the posterior concentrate on theories proving an individual law, such as K3, while the rest of the theory varies? Relate this to the ω-gap.

**Q8. Learning domains of applicability.** Theories of the form Dom(x) → law(x), with Dom learned. On the Kepler data, does the posterior find "Planet ∧ |t| < W(ε)" and exclude the Moon? This is computable on a hand-picked pool.

---

## 6. Verification log

1. **Briefing and reading.**
   * Read `../../00-brief.md` in full, and all 21 notes in `../../prior/`, including `hanni-condensation-concepts.md`.
   * Browsed the four notes folders named in the task and read the notes listed in the header. The quotations in §§1–3 were copied from those files.
   * Read the earlier report's abstract, introduction and the relevant discussion and time passages, and the sibling scouts' summaries, so that the formal claims cited from them are transcribed and not re-derived. Claims marked "proved there" are proved in those records, not here.
2. **Partial records from the interrupted run.**
   * The folder held `checks/c1_kepler_fit.py` and a partial `checks/c1_kepler_fit.out` (116 lines, stopping at the great-inequality header). pyerfa was not installed, so pyerfa 2.0.1.5 was installed into a scratch library folder outside the repository.
   * The script was reviewed:
     * its accuracy statements for plan94 and moon98 were checked against the docstrings printed by the library itself (plan94: Jupiter 71″, Saturn 81″ in L over 1800–2050 against DE102; moon98: worst case 18.3″);
     * the bound argument in its docstring (largest residual is an upper bound on the minimax tolerance, RMS a lower bound up to the 3-D/angular mismatch) was checked and is correct.
   * It was re-run unchanged on a scratch copy (1 min 46 s, exit 0).
     * Lines 1–116 of the new output are identical to the partial output (`diff` empty).
     * The full output (128 lines, ending "# done") replaces the partial file in `checks/`.
3. **c2_mars_models.py (new).**
   * Deterministic; run on a scratch copy in 14 s; output saved.
   * Sanity checks against the first-order equations of centre (§2.4): circle 641.0′ against 2e = 639.6′; eccentric 23.5′ against (3/4)e² = 22.3′; bisected equant 8.28′ against e²/4 = 7.44′. The excess of at most about 1′ matches the ellipse's own residual (1.17′).
   * The fitted period 686.979 d is Mars's sidereal period.
   * The best-plane inclination of 1.883° matches Mars's inclination.
   * Points out of the plane are within 0.07′, so the planar reduction is harmless.
4. **c3_kepler_constant.py (new).**
   * Deterministic; output saved.
   * The fitted q values are copied by hand from c1's output into the script, and were re-checked against `c1_kepler_fit.out`.
   * Ring forces are evaluated by adaptive quadrature. The limits are right: an interior ring adds ≈ m_j(1 + (3/4)(R/r)²) to the central mass, and an exterior ring subtracts ≈ m_j r³/(2R³). Spot check: for Saturn, Jupiter's contribution of 1.25×10⁻³ is close to 9.55×10⁻⁴ × (1 + 0.75 × 0.296) = 1.17×10⁻³, with higher-order terms making up the rest.
   * The 12-year Saturn window (q = 1.0049) covers less than half an orbit and is excluded from the quoted range.
5. **Proofs.**
   * Propositions 2.1, 2.2, 2.3 and 5.1 are proved in full above; they are elementary.
   * Statements marked [proof sketch] are: the undecidability of B via sin(πx); derivation lengths polynomial in log(1/δ); the e²/4 equant coefficient; the reuse saving; the derivation-length tie-break in Q6.
6. **Literature.** Every key in §4 was searched on 2026-10-15. Two mechanical checks were run:
   * every citation key in this file is in `refs.bib`, and vice versa (`comm` on the two key lists: empty);
   * `refs.bib` parses with BibTeX (plain style, `\nocite{*}`), with no warnings and 75 entries, in a scratch copy.

    `refs.bib` gives, per entry, what the search confirmed and what was not confirmed:
   * page ranges not confirmed: Woodward 2014, Putnam 1963;
   * Popper's 1957 "The aim of science" was dropped because its pages could not be confirmed;
   * Kuhn's "Second thoughts" is cited from *The Essential Tension*, where its pages (293–319) were confirmed;
   * contents seen only in abstracts or citing works are marked "secondary" in the text.

   Not checked against the primary text:
   * Kepler's 8′ passage, seen in translation on a secondary site;
   * the vicarious-hypothesis values 0.11332 and 0.18564, from a search snippet;
   * Clemence's 531.54″ and the general-precession figure, from citing papers;
   * the amplitudes of the great inequality, not stated as literature values here.
7. **Not done:**
   * no AI posterior over the Kepler pool (§2.6(c));
   * no formal derivations;
   * no N-body integration;
   * the Possible-error note (§1.8) is one note; we considered and rejected several others as not having a decent probability of being right (see §1.4 E1–E3 and L3, where the author's view is qualified rather than contradicted).
8. **Repository state.** No git command that changes repository state was run. All files written are in this folder; scratch copies and the pyerfa installation are in the session scratchpad.
