# Referee A (philosophy) on `tracks/philosophy/notes.md`

*Adversarial philosophical referee report, 2026-10-16. Object: `notes.md` (674 lines, third-run version) and its scripts in `checks/`. Read in full, together with the project brief `../../00-brief.md` (epistemic policy included), the thread brief `00-brief.md`, the author's notes the record quotes (`../../prior/`, and `/home/user/kaarelh/notes/.../msgs to samuel on ML mind upload difficulty.md`), the `shape` record §4 (to check how §1.4 uses it), and the c4 source and output. My own checks are in `referee_A_code/` (seeded or deterministic; each writes its `.out` next to itself). No git command was run. Statuses below: **[computed: ra1 (k)]** etc. for my scripts; **[searched]** for a characterisation checked by WebSearch in this report (the level is given in the Verification log).*

---

## Verdict

**Major revision.** The record is careful, honest about most of its limits, and unusually explicit about statuses. Its formal propositions (2.1–2.5, 3.1, 4.1–4.4) look correct as stated, and the Kepler physics is mostly right: the minimax errors of the historical forms are of the right sizes (I recover 22.5′, 7.5′ and 0.63′ as the *intrinsic* errors of the eccentric, the bisected equant and the vicarious hypothesis against an exact ellipse, so the 8′ is intrinsic to the equant), the Mercury figures match Clemence's decomposition, and the $q$-constants are right. Nothing I found is fatal.

But several of the record's philosophical *readings* go beyond what its results support. Some matter for the paper's central claims:

* **The headline reading of the Mars computation does not hold up.** The reading is that the data decide which forms are compatible, the syntax decides which compatible form is preferred, and this holds "at the level of precision where history was made". It is an artefact of one data regime: noise-free interval data at a single common tolerance, where compatibility is all or nothing. With Tycho-level Gaussian noise the ellipse overcomes even the epicyclic syntax's 204-bit advantage for the equant after about 40 independent observations. Removing the text prior altogether, the data alone favour the ellipse at every δ ≤ 60′. And the record's own Part C (distances) contradicts the phrase about historical precision (issue 1).
* **Formal toys are labelled as settling philosophical questions.** "Asymmetry is a matter of which questions the language can pose" is marked *proved here*, and Kitcher's answer to the flagpole is mischaracterised (issue 3). The `shape` results are stated as if they settled what logical shape buys, but they were proved for one operationalisation: propositional laws, unit propagation, and programs taken as directed rule sets (issue 8).
* **Two of the four steelmen the brief asks for are missing or weak.**
  * *The semantic view.* The record's own Occam-factor computation is semantic: it is a measure on a class of models. The semanticist has a ready diagnosis of the language-relativity the record finds (issue 4).
  * *The best-system debate.* Lewis is cited for the very relativity he tried to escape (issue 5).
* **Hempel's reply to his own dilemma is misdescribed.** The record treats it as purely about impracticality. That hides the most interesting philosophical consequence of the formal results: in the idealised setting they speak against Hempel's *inductive-systematisation* reply (issue 6).
* **Both "Possible error in the author's view" notes fall short of the brief's bar.** Each attacks a reading the author's text does not make. In each, the record's own concessions, and the strongest counter-literature, side with the author (issue 7). Under the epistemic policy this is the most important fix.
* **Some limitations are understated.**
  * Statistical theories and noisy data are central to physics, not a side issue (issue 10).
  * The "honest list" of progress items includes liabilities (issue 9).
  * Newton's "unification" is mis-described as a saving in parameters (issue 11).

Issues are numbered 1–11 (major) and 12–28 (minor). Each has a concrete fix.

---

## Major issues

### 1. (Major) §4.4, summary: "the syntax decides" holds only for noise-free interval data at a common tolerance, and Part C contradicts its historical gloss

**Claim.**
* Summary: "the preferred form is decided by the syntax".
* §4.4 reading 2: "'the simplest theory compatible with the data' is not a fact about the data at the level of precision where history was made".
* §4.4: "Among compatible forms the data contribute only the Occam factors … at most about 15 bits".

**Problem.**
1. *The regime is special.* Every datum is an interval of the same half-width δ around a noise-free plan94 value. A form either proves all of them or none (proof-requiring, deterministic). In that regime the data's discriminating power among compatible forms *cannot grow with the number of data*: the Occam factor depends on δ, not on N. In any regime where fit is graded, it does grow with N, and then 100–800-bit text differences are overwhelmed quickly. Two versions of graded fit:
   * a Gaussian noise model, which is the practice of celestial mechanics since Legendre and Gauss;
   * the record's own route to noise inside SAI: randomised honest theories, §4.6 and `laws` §3.6.

   I computed both on the c4 data **[computed: ra1 (3)]**. Least-squares RMS residuals: eccentric 15.81′, equant 5.26′, vicarious 0.628′, ellipse 0.446′.
   * *Gaussian noise, σ = 2′ (Tycho-level).* The expected penalty per independent observation relative to the ellipse is 45.1 bits (eccentric), 4.96 bits (equant) and 0.035 bits (vicarious). A crossover is needed only where a form's text is shorter than the ellipse's: the eccentric in S1 and S2, the equant and the vicarious hypothesis in S2. In S1 and S3 the ellipse is already the shorter text against the equant and the vicarious hypothesis. The ellipse overcomes the equant's S2 text advantage (204 bits) after about **41 observations**. It overcomes the eccentric's advantage (100 bits in S1, 312 in S2) after 2–7. The vicarious hypothesis's S2 advantage (186 bits) needs about 5,300 observations (1,300 at σ = 1′).
   * *Honest uniform-tolerance theories* (tolerance = minimax error). The per-datum cost differences are 4.43, 2.93 and 0.40 bits. The same text advantages are overtaken after 23–70 data (eccentric), 70 (equant, S2) and 467 (vicarious, S2).

   So in graded-fit regimes the data, not the syntax, decide every step except the last longitude-only step (vicarious against ellipse). The record's own Part C shows that the distances decide that step.
2. *Even inside the record's regime, the data have a direction.* Remove the law-text prior (a uniform prior over the five forms and the c4 element boxes). The posterior is then fixed by the Occam factors alone, and its MAP is the ellipse at every δ ≤ 60′. The margin is 0.2–1.6 bits at 60′–20′, 4.5–7.7 bits at 12′–3′, and 10–15 bits at 2′–1.6′ (the eccentric is MAP at 720′ and 120′, by under 0.7 bit) **[computed: ra3]**. The record's "the syntax decides the rest" is true only for text differences much larger than 15 bits. It should say that the data's own preference is small and points to the true form.
3. *The historical gloss is contradicted by Part C.* "History was made" by Kepler at Tycho's precision (about 1–2′), with distance data. Part C shows that there, below 6.31′ at τ = 1%, only the ellipse is compatible in every syntax. The syntax decides only at the pre-Tycho precisions (roughly 9′–23′) where several forms are compatible, and in the longitude-only step at 1.41′–1.6′.

**Fix.**
* Rewrite reading 2 and the summary bullet in roughly this form: "In the guaranteed-tolerance regime the data contribute at most about 15 bits among compatible forms, and they point to the ellipse at δ ≤ 60′; a text prior with larger differences overrides this. With noisy data, or with honest theories inside $M_A$, fit differences grow linearly with the number of observations: at σ = 2′ the ellipse overcomes the equant's text advantage in the epicyclic syntax after about 40 observations (in the other syntaxes the ellipse is already the shorter text). Only the longitude-only choice between the vicarious hypothesis and the ellipse would stay syntax-dependent at historical sample sizes, and distance data decide that choice (Part C)."
* Add ra1 (3) and ra3, or the developer's own versions of them, to §4.4.
* Remove "at the level of precision where history was made", or restrict it to pre-Tycho precisions.

### 2. (Major) §4.3–4.4: physics and history accuracy of the Mars pool (error budget, reconstruction, "historical order", "Kepler's last step")

**Problems.**

**(a) Reference-ephemeris error is not stated.** All thresholds are minimax errors against plan94. The ERFA documentation for `eraPlan94` quotes maximum errors over 1800–2050 against DE102 of 17″ (Mars), 71″ (Jupiter) and 81″ (Saturn) in longitude, and "no worse than 1.5 times" that over 1000–3000. This was read from the docstring of the installed pyerfa 2.0.1.5 (Verification log).
* The vicarious–ellipse threshold gap (1.41′ − 1.07′ = 0.34′) is about the size of plan94's own Mars error (0.28–0.43′).
* Part B's 0.627′ against 0.632′ is fine, because there the data are model-generated.
* §4.3's 12-year entries for Jupiter (1.05′) and Saturn (1.70′) are of the same order as plan94's quoted errors for those planets (1.2–2.0′). So they measure the ellipse against plan94, not the ellipse against the sky.

**(b) Intrinsic against perturbation errors.** Against an exact unperturbed ellipse (e = 0.0934) the minimax errors are 22.53′ (eccentric), 7.49′ (equant) and 0.633′ (vicarious) **[computed: ra1 (4)]**. So the 8′ is intrinsic to the bisected equant, which supports §4.3's use of Kepler's 8′. But more than half of the vicarious hypothesis's 1.41′ is the perturbation error it shares with the ellipse.

**(c) "Drop out in the historical order … reproduces the evaluation side of the history exactly".**
* The forms are heliocentric reconstructions evaluated on modern heliocentric longitudes in the best plane. Ptolemy's actual Mars model carried the Earth's orbit as a uniform epicycle, and the geocentric tables' Mars errors were far larger than 8′. Its heliocentric deferent is what the "bisected equant" captures.
* That the forms drop out in chronological order is close to guaranteed by construction, since each successor was adopted because it fitted better.
* "Exactly" overclaims.

**(d) "Including Kepler's last step" (Part C).** Kepler's last step was oval to ellipse (*Astronomia Nova*, Part IV), after he abandoned circles. The oval is not in the pool. Part C reproduces the elimination of the circle-based vicarious hypothesis, not the last step.

**Fix.**
* Add an error-budget paragraph to §4.3: plan94's quoted accuracy, and which entries are near it.
* Say that the sub-arcminute ordering of the vicarious hypothesis and the ellipse is established against plan94. Against the true Mars it would need a better ephemeris (or the intrinsic-error argument of ra1 (4)).
* Report the intrinsic errors.
* Replace "exactly" by "in the same order, as expected since each form was adopted because it fitted better".
* Replace "including Kepler's last step" by "including the abandonment of circular orbits".
* State that the historical geocentric models had an Earth-orbit error part that the heliocentric reconstruction removes.

### 3. (Major) §1.7 item 11, §3.2, §3.5: the asymmetry thesis is labelled *proved*, Kitcher is mischaracterised, and the D-N gaps are understated

**Claim.**
* §1.7 item 11, status "proved here": "The answer to an explanatory question needs interventional vocabulary (Prop 3.1(c)): asymmetry is a matter of which questions the language can pose".
* §3.2: "the literature's 'height explains shadow, not conversely' is not recovered from simplicity alone. … This supports the interventionist account". Also: "Unificationists answer the asymmetry with argument patterns [kitcher1989]; Prop 3.1(b) is a formal version of why such answers depend on the choice of patterns".

**Problem.**
1. *What Prop 3.1(c) proves.* In one toy, two theories that agree on the old vocabulary are separated by one datum in a stipulated intervention vocabulary. It does not prove that explanatory asymmetry *needs* interventional vocabulary. Prop 3.1(b) itself breaks the tie without it, and the record's own reading admits this, relative to the formulation. Rival non-interventionist sources of asymmetry are untouched: temporal order, process or mark-transmission accounts (Salmon), and Kitcher's global unification. So item 11 is an **[assessment]**, not **[proved]**.
2. *Kitcher is misdescribed.* Kitcher's 1989 answer is not that a choice of formulation of the shadow law fixes the direction. It is that the best systematisation of *all* of our beliefs contains a single "origin and development" pattern that derives the dimensions of artefacts, mountains, stars and organisms from their origins and later history. A height-from-shadow pattern would add a pattern, or fail for objects without shadows **[searched: SEP and Kitcher's text]**.

   The record's toy has no other law in which height figures, so it cannot represent Kitcher's answer. In SAI terms Kitcher's answer is a *simplicity* answer at the scale of the whole theory: if $h$ appears in $k$ further laws (weight, construction, growth), the theory whose initial conditions sit at $h$ is shorter, by an amount growing with $k$. So "not recovered from simplicity alone" is shown only for an isolated law, which is the case unificationists concede is locally symmetric.
3. *"This supports the interventionist account."* The intervention semantics was written into $C_H$, $C_S$ by hand. SAI then only learns which stipulated causal theory is right. The toy is *consistent with* Woodward's account; it gives no support over rivals.
4. *Two known gaps is too few.* §3.5's "two known gaps" understates the D-N literature. Irrelevance (Salmon's and Kyburg's examples) and the conjunction problem for explaining laws by laws (Hempel–Oppenheim's own footnote; the reason Friedman and Kitcher appeal to unification) are standard. SAI's length prior addresses the conjunction problem partially, since adding φ as an axiom costs |φ|, and addresses irrelevance only for whole theories, not for derivations.

**Fix.**
* Relabel item 11 **[assessment]** and restate it: "in the toy, interventional data separate causal theories that the old vocabulary cannot; whether explanatory asymmetry in general is interventional is not settled here".
* Rewrite the Kitcher sentence as: "Kitcher answers with the global 'origin and development' pattern; in SAI terms this is a whole-theory simplicity effect that an isolated toy cannot show".
* Optionally add a variant of Prop 3.1(b) with $k$ extra laws on $h$, which should give the height hub an advantage that grows with $k$.
* Change "supports" to "is consistent with".
* Change "two known gaps" to "at least these two gaps; irrelevance and the conjunction problem are older ones", with a sentence on how far SAI's length prior addresses each.

### 4. (Major) §1.2, §1.4 item 4: the semantic-view steelman is missing, and the record's own computations are its best evidence

**Claim.** §1.4 item 4: "The axiom view's real commitment is to a fixed language in which *questions* are posed; since questions are sentences, the syntactic view is the natural one here". §1.2 / row S: the descriptive observation that written theories are declarative supports S, "a theory is a logical theory".

**Problem.**
1. *Questions need not be sentences.* They have a standard semantic treatment as partitions of logical space (Groenendijk and Stokhof's partition semantics, where a question denotes a partition and an answer a union of cells) **[searched]**. A theory answers a question when its model class lies in one cell. So the question-answering view gives no reason to prefer sentences to model classes.
2. *The record's own Kepler computation is semantic.* Proof-requiring compatibility with interval data is a condition on the class of models (element space). The Occam factor is the measure of the compatible part of that class. The only syntactic ingredient in §4.4 is the law-text prior, and it is exactly what produces the language-relativity the record reports.

   A semanticist would say the relativity is an artefact of the syntactic prior. ra3 shows what a presentation-free prior (uniform over the model families, uniform volume on parameters) does: it selects the ellipse at δ ≤ 60′ from the data alone. The record must give the rejoinder, which I think is correct but is not in the record:
   * a prior over *infinitely many* model families needs an enumeration, that is, a presentation, so relativity is relocated rather than removed;
   * volume priors depend on the parametrisation, a Bertrand-type relativity.
3. *The descriptive observation supports "declarative", not "sentential".* What physics texts write is a class of models given by equations over mathematical structures: state spaces, dynamics, Suppes's "set-theoretic predicates", and Suppes's hierarchy of models of data **[searched: Suppes 1962]**. They are not first-order axiom lists. Turning K12 into first-order axioms with a background $B$ of "enough true analysis" is a reconstruction (§4.1 says so). So S's descriptive part is true of "declarative" and needs an argument for "first-order sentences".
4. *Scope of "declarative".* In large parts of science "theory" names a procedure. Quantum chemistry's "level of theory" means a computational method: Hartree–Fock, coupled cluster, a density functional. Feynman rules and renormalisation schemes are recipes. The caveat in §1.2 ("procedural parts in use") should become part of the observation's scope: "as written in the textbook presentation of fundamental theories".

**Fix.**
* Replace "since questions are sentences, the syntactic view is the natural one here" with the partition point and the honest conclusion: "the question-answering view is neutral between sentences and model classes; the paper uses sentences because SAI's prior is over texts, and §4.4 shows that this is where the language-relativity enters".
* Add the semanticist objection, ra3, and the enumeration and parametrisation rejoinder.
* Restate the descriptive observation as declarative, with its scope stated, and with "sentential" as a modelling choice.

### 5. (Major) §1.7 item 9, §4.4 reading 2, §7: the best-system debate is cited for the relativity Lewis tried to escape

**Claim.** §1.7 item 9: "simplicity is relative to the base language, as in best-system accounts [known: lewis1983new, cohen2009better]".

**Problem.** Lewis (1983) treats language-relativity as a *problem*. With a predicate F true exactly where the world's system holds, "∀x Fx" axiomatises everything and every regularity becomes a law. Lewis's answer is to require the system to be stated with predicates for perfectly natural properties **[searched]**. Cohen and Callender (2009) *embrace* relativity to kinds; Lewis does not. Citing both for "simplicity is relative, as in best-system accounts" misstates Lewis.

The record also misses the steelman that bears most directly on SAI. In SAI the base language is fixed, so Lewis's trivialisation problem moves into the choice of the base language. `fundamentals` Thm 4.4 (the $K(\tau)$ bound) makes a trivialising primitive expensive only *when translating from a fixed reference language*. A base language that has F as a primitive simply contains it. Finally, the best-system account is a metaphysics of laws, the best system of the *whole* history, while SAI is inference from finite data. The analogy should be stated as an analogy.

**Fix.**
* Write: "best-system accounts face the same relativity: Lewis meets it by requiring natural predicates, Cohen and Callender accept it relative to kinds; SAI inherits it through the choice of base language, bounded by $K(\tau)$ only relative to a fixed reference language, and §4.4 measures it for Kepler".
* Add one sentence on the predicate-F problem in SAI.

### 6. (Major) §6.3 and §1.6: Hempel's dilemma is misdescribed, and the formal results bear on Hempel's actual reply

**Claim.** §6.3: the classical reply to the dilemma is "Craigian axiomatisations are useless in practice", the reply that goes back to the impracticality of Craig's construction [craig1956, putnam1965].

**Problem.**
* Hempel's own 1958 reply was not only practical. He argued that theoretical terms may be indispensable for *inductive* systematisation: a Craigian replacement preserves deductive connections among observation sentences but may lose inductive ones. Niiniluoto's 1972 survey in *Synthese* and the Wikipedia article on Craig's theorem both state this **[searched]**.
* Putnam's 1965 argument is, by secondary accounts, that the instrumentalist use of Craig rests on the misconception that science aims only at prediction **[searched; secondary]**.
* This matters because SAI *is* an inductive systematisation. The record cites theorems saying that in the idealised setting theoretical vocabulary changes posterior weights by $O(1)$ bits (`terms` Thm 2.1, `fundamentals` Cor 4.5; "in the idealised setting nothing theoretical is indispensable", §1.6). Read through Hempel, they say that **in the idealised Bayesian setting Hempel's inductive-systematisation reply fails**: theoretical terms add no inductive power beyond $O(1)$ bits. Where something theoretical pays (relations, entities, charged derivations: `terms` Thm 5.1, 4.6, 6.2), the reply survives in a corrected form.
* That is a more interesting philosophical consequence than the practicality reading. It is also more exposed: it needs to be checked against `terms`' own reading.
* `terms` has already stated the formal half and handed the philosophical half to this thread. `terms/notes-final.md` §2, "What it says about inductive systematisation": the posterior predictive of every observational sentence is the same up to $2^{\pm2c}$ with or without theoretical vocabulary, "a statement about the mixture, not about any single theory … The philosophical assessment is `philosophy`'s". Its literature section also contrasts this with Hintikka–Tuomela monadic inductive logic, where theoretical concepts *do* change inductive probabilities. The philosophy record never takes up this hand-off.

**Fix.**
* Restate the classical replies: impracticality (Craig, Hempel), inductive systematisation (Hempel 1958; Scheffler, Lehrer, Tuomela pro; Bohnert, Hooker, Stegmüller contra, per Niiniluoto 1972), and aims beyond prediction (Putnam 1965).
* Say which of them the formal results bear on, and how.
* Write the assessment `terms` asks for: "in the universal mixture with free deduction, theoretical vocabulary gives no inductive systematisation beyond a constant factor (`terms` Thm 2.1, Rem 2.2), unlike Hintikka–Tuomela's monadic systems; where theoretical relations or entities pay (finite theories, charged derivations), Hempel's reply survives in a corrected form".
* Cite Niiniluoto 1972 (Synthese 25:25–81), which `terms` has verified at abstract level.

### 7. (Major, epistemic policy) §6.1 and §6.2: neither "Possible error in the author's view" meets the brief's bar

The brief: raise a disagreement "only when it has a decent probability of being right … do not invent disagreements".

**§6.1 ("no nice formal criterion").**
* *What the author is answering.* The note asks "how come we *usually avoid* this sort of catastrophic reasoning?" and answers "i don't think any nice 'formal criterion' is going to be right?". It then adds: "the vibe of physics is imo more like: … don't do them, silly!" (source read in full). The natural reading is explanatory and descriptive: what *explains* our avoidance is not a formal criterion. The record concedes this ("right as a description").
* *The record's own limits paragraph supports the author.* It concedes that worst-case propagation "becomes vacuous" over long chains and for ill-conditioned or chaotic dynamics. There the work is done by tools "specific to classes of problems". That is close to what the author said: no single nice criterion.
* *The note's own example cuts the other way.* The rigorous honest-domain version of the Stosszahlansatz is Lanford's theorem. It derives the Boltzmann equation only for a *fraction of the mean free time*, in the Boltzmann–Grad (low-density) limit **[searched]**. Practice uses the Boltzmann equation far beyond that domain, and rightly. So the soundly licensed domain is tiny compared with the domain of correct practice: an example *for* the author's "here's a way of talking that works".

**§6.2 ("nothing fundamentally right about these information-theoretic losses").**
* *Context.* The essay's context is grading predictions for a purpose, by bounded ("condensation") models. The record concedes the claim there.
* *The general reading is not the essay's.* The record's correction targets a general reading the essay does not make. Its counter-claim, "the log score is privileged for scoring credences", is itself contested:
  * the uniqueness theorem needs *locality* (Bernardo 1979: the log score is the only proper local rule, under regularity conditions and more than two outcomes) **[searched]**;
  * accuracy-first epistemology argues for the *Brier* score (Leitgeb and Pettigrew; Pettigrew 2016, ch. 4, narrows the strictly proper measures to Brier) **[searched]**;
  * conditionalisation is justified by expected-accuracy arguments for strictly proper (strongly proper) epistemic utilities generally, not for the log score alone (Greaves and Wallace 2006, as presented in the SEP supplement) **[searched]**.
* *The essay's strongest version survives.* For unbounded probabilistic beliefs every strictly proper score has the same optimum, the true distribution, so "different losses give different behaviour" is false there. For bounded or misspecified models (the essay's subject) different proper losses yield different best-in-class models. Raw-data log loss then spends capacity on "a huge amount of crap" (the essay's words). That is the author's point, and it is correct.

**Fix.**
* Drop both "Possible error" labels.
* Keep the content as complementary remarks:
  * in §5.3: "a sound formal device exists (tolerances on domains, `laws` Prop 4.3); it does not reproduce practice, and its rigorous domains can be far narrower than the domains practice rightly uses (Lanford)";
  * in §1.3 or §2.2: "for ideal probabilistic beliefs all strictly proper scores agree; for bounded models the loss matters, which is the essay's point; SAI's answer is to let the purpose fix the propositions and to score credences on those".
* §6 may then contain no note. The brief allows that ("do not invent disagreements"). If the developer wants to keep §6.2 in some form, the minimum fix is to replace "the log score is privileged" with "proper scores are privileged; which proper score is contested (log versus Brier)", and to state the misspecification point.

### 8. (Major) §0 row S, §1.4 item 2, §1.7 closing: the `shape` results are read as settling what logical shape buys

**Claim.**
* §1.4 item 2: "**So the large separations are between reasoners and between vocabularies, not between declarative and procedural shapes;** logical shape buys many-directional use only up to a constant factor once intermediate concepts are allowed".
* §1.7: "none concerns the shape of hypotheses".

**Problem.** The `shape` results (Thm 1.12, 2.6, 3.6, Prop 4.2, Thm 4.3) are proved for one operationalisation:
* propositional laws (linear over GF(2) and parity for the large separations; any Boolean law for the factor-9 splitting);
* reasoners that are unit propagation, forward chaining or Gaussian elimination;
* "program shape" taken as a direction-complete set of sound directed rules (`shape` Def 4.1).

That is a reasonable model, but it is one model. Numerical solvers, probabilistic programs with conditioning, simulation codes and real-valued laws are outside it. `shape`'s own "What this shows and does not show" is more careful than §1.4's bold sentence. The summary table then turns the restricted statement into a general verdict on claim S.

**Fix.** Each time, write: "in `shape`'s model (Boolean laws; unit-propagation and forward-chaining reasoners; programs as directed rule sets), logical shape buys many-directional use only up to a factor ≤ 9 once auxiliary variables are allowed". Add to the S row: "whether this extends beyond that model is open". Change §1.7's "none concerns shape" to "none concerns shape *in the idealised setting*".

### 9. (Major) §1.7: "the honest form of the progress claim" lists liabilities as progress

**Claim.** §1.7, closing sentence: items 1–11 are "the honest form of the progress claim".

**Problem.** Several items are neutral or count *against* SAI as an account of theories:
* Item 7: on true arithmetical data the limit posterior concentrates on *false* theories.
* Item 9: language-relative simplicity, which §4.4 shows decides real choices.
* Item 6: piecemeal confirmation, but the blame allocation is set by the syntax-relative prior.
* Item 8 ("truth from unprovability") is a curiosity, not progress in what a theory is or does.

Item 6's "Duhem–Quine situation, handled coherently" is also the standard Bayesian treatment. It goes back to Dorling 1979; Strevens 2001 argues that the standard treatment begs the question and offers another, and Mayo criticises it **[searched]**. SAI inherits that debate.

**Fix.**
* Split the table into: (a) differences that are advantages for the purposes in claims D and E (1–5, 10); (b) neutral differences (6, 8, 11); (c) liabilities (7, 9).
* Rename the section "what formally separates SAI from raw-data prediction".
* Cite Dorling and Strevens for item 6 and add "the allocation of blame is fixed by the prior, hence by the syntax".

### 10. (Major) §1.3 and L8: the practice-of-physics objection to D is not engaged, and statistical theories are treated as peripheral

**Claim.** D: theories answer questions rather than predict or generate raw data. L8 lists statistical theories as one "partially addressable" item.

**Problem.** The strongest objection from current practice is not engaged. Large parts of modern physics confront theory with *near-raw* data through generative forward models and likelihoods:
* gravitational-wave searches match waveform templates against the raw strain series with a Gaussian likelihood;
* cosmology evaluates likelihoods of pixel-level microwave-background maps;
* particle physics simulates raw detector responses (event generators and detector simulation) to compare with data.

There the theory, together with instrument and noise models, *generates* predictions for raw data, and the loss is information-theoretic. D in its comparative form survives, because these pipelines exist in order to answer a few questions (a mass, a spin, a cosmological parameter). But the record should say so. And the proof-requiring core of SAI, with exact or interval data and no native noise model, sits far from this practice.

The record's own showcase (§4.4) uses noise-free model outputs, and issue 1 shows that its main reading changes when noise is added. Statistical confrontation is therefore not one limitation among twelve. It is the default form of contact between theory and data in physics.

**Fix.**
* Add objection (o4) to §1.3 with the examples above and the reply: "these pipelines serve question answering; their raw-data likelihood is a means".
* Promote L8 to a headline limitation: "SAI's proof-requiring core has no native noise model; graded fit enters only through honest theories (`laws`) or the generative variant".
* State in §4.4 that the computation is the noise-free special case.

### 11. (Major) §4.5: "what Newton adds" mis-describes the unification and mixes old and new language

**Claim.**
* §4.5 item 1: "**Unification.** One law plus one number per body replaces K12 + K3 for every body".
* Item 3: "New questions in the old language … The masses of the Sun and of planets with satellites".
* Items 2–4: credited to "Newton's theory".

**Problem.**
1. *Parameter count.* Newton does not reduce the parameters. Per body he needs six initial conditions, equivalent to osculating elements (as Kepler does), *plus* a mass. The law (an ODE system with $G$) is much longer than K12 + K3.

   On planetary longitudes at Kepler-era precision the extra parameters buy nothing measurable over 20 years: the Kepler ellipse fits Mars to 1.07′, inside Tycho's 1–2′. An SAI posterior on planetary data alone would not prefer Newton then. Newton's unifying gain is *across domains*: the Moon test (terrestrial gravity and lunar acceleration under one law), falling bodies, tides, comets, and K3 for satellite systems with its mass correction. Item 4 lists some of these as "new domains". It is where the unification lies, and it should lead.
2. *Masses are not old language.* Masses are T-theoretical in Sneed's sense, as the record says one paragraph earlier. "The mass of Jupiter" is a new question in a new language (ladder step 3), not a question in the old one. Old-language new questions are, for example, Neptune's position and the return of Halley's comet.
3. *Attribution.* Items 2–4 are achievements of Newtonian mechanics developed over 150 years, not of Newton: Clairaut on the lunar apsides (Newton accounted for about half), Laplace on the great inequality, Le Verrier on Neptune **[searched: the lunar apsides]**. Philosophers of Newtonian method (Harper 2011, which the record cites; G. E. Smith) stress exactly this.

**Fix.**
* Rewrite item 1: "Newton adds one parameter per body (the mass) and a longer law; on planetary longitudes at Kepler's precision this buys no fit. The unifying gain is across domains: the Moon test, falling bodies, tides, and K3 for satellite systems with its mass correction".
* Move the masses to "new questions in a new language".
* Say "Newtonian mechanics (Newton to Laplace and Le Verrier)" for items 2–4.

---

## Minor issues

12. **(Minor) Prop 2.2(b) is true by construction, and (d)'s factor depends on the baseline.**
    * The question share of 1 holds because the only question asked is the conserved quantity. Say so: the toy chooses the questions the law answers. Choosing which questions matter is ladder steps 3–4 and L4, and the energy concept arose with its conservation law.
    * QA-NOLAW (|x_t| uniform on {0..m}) is not the Bayes no-law predictor. The fair baseline is the true marginal Binomial(m,1/2). Under it the law's value per question and per raw step differ by a factor of only 1.36 (m = 8) down to 1.14 (m = 1024), and by about $\tfrac12\log_2 e$ = 0.72 bit asymptotically, against 1.69–1.88 with the uniform baseline **[computed: ra1 (1)]**.
    * Fix: replace "within a factor of about 2" with "nearly equal (with the fair baseline they differ by about 0.72 bit)". This strengthens the record's own point.

13. **(Minor) The K3 text cost is a serialisation artefact of about 2×, and the summary's conclusion is conditional.**
    * c4 counts every bracket as a token. In Polish notation with fixed arities, also prefix-free, K3 costs 165 bits (S1). With a power symbol it costs 115 bits. So K3 pays at 11–15 bodies, or 8–10 with the power symbol, not 25–40 **[computed: ra1 (2)]**.
    * $s(\delta)$ also depends on the arbitrary prior range ρ ∈ [0,4): it adds log₂ of the range.
    * The conclusion "K3 does not pay for Kepler's five bodies" (55–75 bits saved, by the record's extrapolation) survives in these three codes, but by a factor of about 1.5–3 rather than 5–7, and the record itself says a compact code could reverse it. The summary's "so at Kepler's precision compression alone does not select K3" must become conditional: "in these literal codes".
    * Also report the size of K3's own approximate truth: with $q-1$ = 9.5·10⁻⁴ (Jupiter) and 1.5·10⁻³ (Saturn), exact K3 misplaces Jupiter and Saturn geocentrically by at most 0.23′ and 0.19′ over 1580–1600 **[computed: ra1 (5)]**. That is invisible at Tycho's precision, so at Kepler's precision K3 is effectively exact. This is the "by how much" the brief asks for.

14. **(Minor) §3.3 misreads the table.** "Kepler off by 1–2′ per decade for Mars" is not a rate. Table 2.1 gives 1.58′ over 12 years, 1.86′ over 30 and 3.61′ over 100. Write "1.6–1.9′ over one to three decades, 3.6′ over a century".

15. **(Minor) §4.5 item 5 and §3.3: what Newton entails.** Newton's laws entail "K12 within ε on W" only together with masses and initial conditions. Say so.

16. **(Minor) Lutz 2017.** The published abstract (Phil. Phenom. Res. 95(2):319–352) locates the residual disagreement in dependence *on predicate logic*. "Language dependence" is the 2015 preprint's wording. Quote the published version.

17. **(Minor) Putnam 1965.** See issue 6: by secondary accounts Putnam's point is about the aims of science, not mainly impracticality. Hedge as "content: secondary".

18. **(Minor) "Occam factor" has standard precedents.** The term and the posterior-volume/prior-volume reading are MacKay's (Neural Computation 4:415–447, 1992). Jefferys and Berger ("Ockham's razor and Bayesian analysis", *American Scientist* 80:64–72, 1992) use Bayes factors on Mercury's perihelion **[searched]**. Credit both in §4.4 and §4.5. Adopting $\mathrm{Occ}_F$ as the record requests in §8 fits.

19. **(Minor) Condensation table, "Support for learning: yes".** The essay means concept-local addition of inferential links to a persisting concept. SAI has a persisting symbol but a global, static mixture over whole theories. "Partly" is accurate.

20. **(Minor) §4.1 overstates the data language.** "This is the language of Tycho's observations": Tycho measured mainly equatorial coordinates, and reducing them (refraction, precession, the equinox of date) is itself theory-laden. The c4/c7 data are geometric plan94 positions: no aberration (about 0.34′) or light time, and geocentric from the Earth–Moon barycentre rather than the Earth (up to about 0.3′ for Mars at a close opposition: 4,670 km at 0.37 AU). Say "a modern idealisation of Tycho's language".

21. **(Minor) "K3 is a law about initial conditions" depends on the parametrisation.** The reading (§4.4 B, reading 3) holds because P and a are both taken as free elements (Kepler's kinematic parametrisation). In a state-space parametrisation (positions and velocities) K3 is the dynamical relation fixing the mean motion from the energy. The parametrisation also decides whether K3 "pays". This is the same relativity as issue 1 and deserves a sentence.

22. **(Minor) Pool restriction: checked, robust in S1.** I tested a natural form outside the pool, the equation-of-centre series truncated at second or third order (four elements, like the ellipse). In S1 its texts are longer than the ellipse's (680 bits at second order, 1,345 at third, against 545), because S1 has only the numerals 0, 1, 2. So the S1 MAP rows are robust to this extension. The third-order series has minimax error 1.31′, between the vicarious hypothesis and the ellipse **[computed: ra2]**. Suggest a sentence: "conclusions are about the pool; one natural extension checked does not change them".

23. **(Minor) §4.1–4.2, structural questions.** §4.1 gives the examples "(the return period; the mean distance)", and after Prop 4.1 the record says "the laws alone answer only structural questions". Without elements the laws do not fix the return period or the mean distance either. Give genuine structural examples, such as "is the orbit of b planar?" or "does b's direction return periodically?".

24. **(Minor) §2.3 reading.** Prop 2.3(a) is about certifying a law from black-box *dynamics*, not about extracting answers from a *predictor*. Rephrase the first sentence of the reading, or add the missing step.

25. **(Minor) L9, "theory-ladenness is harmless at ladder step 2".** This conflicts with §1.6's own strongest objection: scoring a revising theory in the language it rejects. Write "is not the classical objection to a neutral observation language, but it biases comparisons between theories that disagree about the base language (§1.6)".

26. **(Minor) §3.4.** Copernicus's system also fixed the order and relative distances of the planets (Kuhn's "harmony"). That is a second unification with no accuracy gain, and it connects to §4.2's ρ discussion. It is worth one clause.

27. **(Minor) §1.4 item 4.** "Halvorson argues that the semantic view, taken literally, misidentifies theories": accurate to the abstract, which also says the view cannot express relations between theories such as embeddability **[searched]**. Fine as is. Listed only to record that it was checked.

28. **(Minor) Summary, "Kepler's laws are approximately true with an error that grows with the domain".** Add the K3 figure (issue 13) and the plan94 error budget (issue 2), so that "by how much" is complete for all three laws.

---

## What I checked and found sound (no change requested)

* **Prop 4.3** (K3 has content geocentrically): the proof is correct. The appeal to equal angular rates via $r^2\dot\theta$, the reading of $P$ and $a$ from the motion, the role of the universal quantifier over $E$ in $\theta_{\rm K3}$, and Remarks (i)–(ii) on the coincidence convention and the outer planet all check out.
* **Prop 4.2, Prop 4.4(b), Prop 2.1, Prop 2.5(d), Prop 2.3(a)** with its counterexample to N2's Prop 5.2(a): correct.
* **Orbital mechanics:**
  * the eccentric's 23′ follows analytically from the second-order terms: ellipse $\tfrac54e^2\sin2M$ against eccentric $2e^2\sin2M$, difference $\tfrac34e^2$ ≈ 22.5′ for e = 0.0934, matching ra1 (4)'s 22.53′;
  * the equant's error is intrinsic and about 7.5′;
  * $q = 1 + m/M$ with 1.000955 for Jupiter and 1.000286 for Saturn, and the ring heuristic for Saturn is plausible (monopole plus quadrupole of Jupiter ≈ 1.0012 + 0.0002);
  * the Mercury budget is consistent with Clemence: general precession 5025.6″ plus planetary 531.5″ gives 5557.2″.
* **Quotations of the author.** Spot-checked against the files: "in a deep way", "inert", the domain note, and the essay's Gaussian-noise passage. All verbatim.

---

## Verification log

1. **Restart check.** No earlier `referee-A.md` or `referee_A_code/` existed in the folder. I wrote a skeleton first and then this report.
2. **Read in full.**
   * `notes.md` (all 674 lines);
   * `../../00-brief.md` and `00-brief.md`;
   * the c4 source (law texts, models, fitting) and `c4_mars_pool.out` tables A1–A4;
   * the author's notes `phil-sci-the-domain-of-applicability-of-a-scientific-model.md` (all), `phil-sci-science-predicts-only-very-particularly.md`, `phil-sci-some-disanalogies-between-solomonoff-induction-and-science.md`, `phil-sci-our-science-is-very-human-software.md`, `phil-sci-scientific-theories-are-not-for-generating-or-predicting-arbitrary-data.md`, and `hanni-condensation-concepts.md` (Section 1 in full);
   * `shape/notes.md` §4 (Def 4.1, Prop 4.2, Thm 4.3 and its reading);
   * `terms/notes-final.md`, the passages on inductive systematisation and Hempel, Putnam, Hintikka–Tuomela and Niiniluoto (found by grep; used in issue 6);
   * the ERFA `eraPlan94` docstring from the installed pyerfa 2.0.1.5, for the accuracy figures quoted in issue 2.
3. **Scripts** (in `referee_A_code/`, run with pyerfa from the scratch library folder, importing `../checks/c4_mars_pool.py` for data and models; outputs saved next to each script):
   * `ra1_checks.py` (seed 20261016, 11 s; run twice, the second time only to print "n/a" where no crossover is needed; the numbers were identical): (1) conservation baselines; (2) law-text token counts with and without brackets, compact K3; (3) least-squares residuals and noise-regime crossover counts; (4) intrinsic form errors against an exact ellipse, by c4's own fitting routine; (5) the geocentric error of exact K3 for Jupiter and Saturn.
   * `ra2_series.py` (seed 20261016, 4 s): S1 texts (asserted to lie in c4's S1 alphabet) and minimax errors of the second- and third-order equation-of-centre series.
   * `ra3_semantic_prior.py` (deterministic): the posterior over the pool without the text prior, from the record's Occam-factor table.
   * Caveats: ra1 (3) uses the expected Gaussian penalty with the model's systematic residuals as the misfit, which is an estimate, not a full noisy-data simulation. ra1 (4) uses c4's own minimax routine, whose global optimality is not proved.
4. **WebSearch** (content level in brackets):
   * Lutz 2017 abstract [abstract, two versions];
   * Hempel's inductive-systematisation reply and Putnam 1965 [secondary: Wikipedia "Craig's theorem", abstract of Niiniluoto 1972 *Synthese* 25:25–81];
   * Lewis 1983 on predicate F and natural properties [secondary: several papers quoting it];
   * Kitcher 1989's "origin and development" pattern [SEP *Scientific Explanation* and secondary summaries quoting Kitcher's text];
   * Groenendijk–Stokhof partition semantics [secondary: Shan and ten Cate, Groenendijk 1999];
   * Bernardo 1979 locality [secondary: Ehm–Gneiting, Dawid–Lauritzen–Parry];
   * Pettigrew 2016 and Leitgeb–Pettigrew on Brier [chapter description, Norton's and Joyce's discussions];
   * Greaves–Wallace 2006 [abstract and SEP supplement, "strong propriety"];
   * Lanford's theorem [several arXiv expositions: valid for a fraction of the mean free time];
   * MacKay 1992 and Jefferys–Berger 1992 [abstracts and secondary];
   * Suppes 1962 [scan and secondary];
   * Halvorson 2012 [abstract];
   * Dorling 1979 and Strevens 2001 [abstracts];
   * Newton's half of the lunar apsidal motion and Clairaut 1749 [secondary: arXiv 1503.06861, Physics Today, MacTutor];
   * Tycho's accuracy (1–3′ typical) and Kepler's 8′ [secondary, conflicting figures noted];
   * Kepler's 1.00429 secant [secondary; chapter attribution inconsistent, so not used].
   * Not confirmed and therefore not used as evidence: the exact width of Kepler's lune; Wesley 1978's content.
5. **Repository state.** Files written: `referee-A.md` and `referee_A_code/` (three scripts, three `.out` files). No git command was run.

### Sources consulted (WebSearch)

* Lutz 2017: https://dc2.philarchive.org/rec/LUTWWT ; https://philsci-archive.pitt.edu/11346
* Craig's theorem / Hempel: https://en.wikipedia.org/wiki/Craig%27s_theorem ; https://api.philpapers.org/rec/NIIISD
* Lewis 1983 secondary: https://dc2.philarchive.org/rec/EDDNWF ; https://riviste.unimi.it/index.php/rifanalitica/article/view/4010/4111
* Kitcher 1989: http://fitelson.org/woodward/kitcher_eu.pdf ; https://plato.stanford.edu/archives/fall2025/entries/scientific-explanation/
* Partition semantics: https://arxiv.org/abs/cs/0209008
* Log score locality: https://arxiv.org/pdf/1101.5011 ; https://arxiv.org/pdf/1104.2224
* Accuracy-first / Brier: https://academic.oup.com/book/26987/chapter/196189746 ; https://sites.pitt.edu/%7Ejdnorton/papers/material_theory/material_theory_April_23_chapters/11_Scoring_rules.pdf
* Greaves–Wallace: https://philsci-archive.pitt.edu/2212 ; https://plato.stanford.edu/archives/spr2012/entries/epistemic-utility/theorem12.html
* Lanford: https://arxiv.org/pdf/1405.4676 ; https://ar5iv.labs.arxiv.org/html/1301.2514
* MacKay 1992: https://resolver.caltech.edu/CaltechAUTHORS:MACnc92a
* Jefferys–Berger 1992: https://www2.stat.duke.edu/~berger/papers/ockham.html
* Suppes 1962: https://errorstatistics.com/wp-content/uploads/2016/12/suppes-p-1962-models-of-data.pdf
* Halvorson 2012: https://philsci-archive.pitt.edu/8615
* Dorling / Strevens: https://www.princeton.edu/~bayesway/Dorling/dorling.html ; https://mail.joelvelasco.net/teaching/3865/strevens%20auxhyp.pdf
* Lunar apsides: https://arxiv.org/pdf/1503.06861 ; https://physicstoday.aip.org/features/the-18th-century-battle-over-lunar-motion
* Tycho accuracy: https://arxiv.org/pdf/1209.3563 ; https://astroweb.case.edu/ssm/gened/quothkepler.html
