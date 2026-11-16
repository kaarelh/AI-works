# Outline, notation and style for the note (lead; provisional until the proofs are checked)

Working title: **Imitating a human inside a computation we can run in advance: a protocol, its theorems and its limits.**

## The reader

The researcher who posed the problem, and readers like him: mathematically trained, at home with Solomonoff induction and log-loss regret, not necessarily with the imitation-learning literature. He will apply the seven tests listed in `understand/notes.md`, Section 5 (guard, machine, referent, copy, budget, rock, horizon). He reads cold: every symbol and every coined term must be defined where it is first used.

## Sections of the note

0. The question, and the answers in brief (written by the lead).
1. Model: the human as a sampler; classes and weights; scaffolds, runs, the human system; closed systems; faithful and unfaithful calls. Assumptions A1 (stateless human), A2 (the human is in the class), A3 (the protocol's coins are fresh).
2. The protocol: rehearse, validate, deploy.
3. What rehearsal guarantees: per call (R1), whole runs (R2), low stakes (R3), the certificate (V1).
4. What no protocol can do: no coverage, no guarantee (N1); critical steps are not amplified (N2, with the factor K); what low stakes requires (N5).
5. One program or a committee (R4, R5, R6); recorded runs of the human system for small scaffolds (Theorems A and B).
6. Inputs from outside: density ratio, all simple shifts at price 2^k (S1–S3, N3).
7. Failing obviously: thresholds, dominance, novelty (Ab1–Ab3, N4), and the comparison with Cohen, Hutter and Nanda.
8. The property idea: all properties at once; the price of one property; the batch and the online property imitators (Pr1–Pr5); what can be certified for a stochastic human.
9. What remains a bet: rare situations, isolation, copy or predictor.
10. The seven tests.
11. A toy closed system (the tree of additions) and other computations.
12. Related work.
13. Open questions.

## Notation (fixed)

* X, Y: countable sets of strings; x an input, y an answer.
* Sampler: a probability kernel S(·|x) on Y. The human is the sampler P (a function f when deterministic).
* H: countable class of samplers; w(ν) its weights, Σ w ≤ 1; K := log₂(1/w(P)); always "K ln 2" for the bound in nats.
* D: data (asked pairs); w_D posterior; M_D the mixture (posterior predictive), M^(t) the mixture frozen at the start of round t.
* Π: scaffold; L: its horizon (largest number of calls in a run); z ~ D₀ the top-level input; ρ the scaffold's own randomness; τ a run; Q_A the law of a run answered by A; Q_P the human system.
* n: number of questions put to the human in rehearsal; m: number in validation; T: the uniformly chosen round whose mixture is deployed.
* An **unfaithful call**: in the coupling of an imitator's run with the human system, a call whose answer differs from the human's coupled answer.
* TV total variation; KL in nats; H² := 1 − Σ√(pq) (squared Hellinger distance, so H² ≤ KL/2 and TV ≤ √(2H²)).
* sep(x; A): least complexity of a decidable set that contains x and no element of A.
* Words: "question" = one call put to the human; "run" = one execution of the scaffold; "round" = one rehearsal run with its question; "closed system" = a scaffold whose top-level inputs and randomness we can sample ourselves; "low stakes" = the human system's outcome survives a number of arbitrarily replaced answers.

## Style (binding for every section)

* Lead with the result; then the proof; then what it does not say. One main statement per numbered theorem. Complete proofs, or a precise pointer to the proof file in `verification/` when a proof is long and routine.
* Plain words. Short, common words where they are just as precise. Full sentences. No arrows or symbols in place of sentences in prose; mathematics in formulas.
* Every claim about the literature carries a full citation and says what the cited work proves. Results that are standard are called standard, with the source (in particular: the regret bound for Bayes mixtures; the reduction of imitation to no-regret learning on the learner's own distribution by Ross, Gordon and Bagnell; horizon-free log-loss cloning by Foster, Block and Misra; the top-set imitator of Cohen, Hutter and Nanda; minimum-distance estimation after Yatracos).
* Say plainly where a bound is empty (for example where K for a person makes it so) and what is assumed. Do not soften, and do not advertise.
* Hedge once, in the place where the uncertainty is; state checked facts flatly.
* Tables for comparisons; no decoration.
* Each numbered statement carries its status in the note: proved here, standard (with source), or open.

## Addendum (15 Nov): how the note is assembled

* **Labels.** Statements keep letter labels, the same in the note, in the proof files and in the reports: R (rehearsal: R1, R2, R3, R3a, R4, R5, R6), V (validation: V1), N (limits: N1 … N5), A and B (recorded runs), S (shift: S1 … S3), Ab (abstention: Ab1 … Ab3), Pr (properties: Pr1 … Pr5). New statements get the next free number of their letter, announced in the finaliser's summary.
* **Three kinds of file per part.**
  1. `proofs/KEY.md`: the full proofs, checked and corrected. Self-contained, numbered, line-by-line checkable. Published with the note.
  2. `research/verify/KEY-check.md` and `research/verify/KEY-attack.md`: the two verification reports.
  3. `research/sections/KEY.md`: the text of this part as it will stand in the note. The note states every result with its hypotheses and final constants. A proof of up to about fifteen lines is given in full; a longer one is given as a sketch of the idea in a few sentences, followed by "Proof: `proofs/KEY.md`, Theorem x.y." After each main statement: what it does not say, in one or two sentences. Length of a part: 800 to 2000 words unless the outline needs more.
* **Parts and the sections they supply.** rehearsal-core: Sections 1 to 3 (revising the lead's draft in `note.md`). lower-bounds: Section 4 and the lower bounds of Section 6. hellinger-runs: the subsection "whole runs" of Section 3 and Section 5.2 (recorded runs). one-mind: Section 5.1. shift-abstain: Sections 6 and 7. property-batch: Sections 8.1, 8.2, 8.5 and the batch estimator. property-online: Sections 8.3 and 8.4. assumptions: Sections 9 and 10 and the caveats on A1 to A3 for Section 1.
* **Results already established that later parts should use and not redo** (unchecked until the verification reports exist): `research/prove/lower-bounds.md` (N1 with randomised protocols; N2 with n ≥ L/(4δ) − L; the factor K holds in VC dimension, and in bits a targeted-question protocol needs only about 2.7·K·L/(ε·log(L/ε)) questions; N3 in the exact form n ≥ 2ηN; S2; N5; lower bounds for a stochastic human); `research/prove-b/hellinger-runs.md` (subadditivity of H² with constant 4, and 2.9641; R2 in general with E TV ≤ 2√(LK ln 2/n); Theorem A; the per-call mixture fails in Theorem A; Theorem B for λ > 1 and its failure at λ = 1).

## Addendum 2 (15 Nov): attributions every part must get right

These come from the literature check behind `research/sections/related-work.md` (read that file for the exact statements and the full references; it marks what was verified in a source). Editors: apply them in your section.

1. **Rehearsal is a published algorithm for finite classes and deterministic experts.** Li and Zhang, "Stagger" (arXiv:2412.07057; NeurIPS 2025 according to the arXiv comment), analyse exponential weights under log loss with one state of each rollout put to the expert and a uniformly chosen iterate deployed. Theorem R1 for a deterministic human is the estimation step of their proof. Credit Ross, Gordon and Bagnell (2011) for the reduction of imitation to learning without regret on the learner's own inputs, and Li and Zhang for this form of it. The note's additions are to be stated modestly: a countable class with a prior (so the bound is in K), a human who is not deterministic, and the use made of the bound (low stakes, the certificate, the limits). Do not write that the protocol or the observation behind it is new.
2. **The regret bound for Bayes mixtures.** Solomonoff (1978) is the squared-error form for binary sequences; the divergence form for countable classes is Hutter (2003, Theorem 1); the question–answer version is Solomonoff (2008, eq. (10) for the predictor, eq. (12) for its convergence); in this repository the per-query mixture is Paper 1, Proposition 5.7(b) (Theorem 5.3 there is about the one-tape version).
3. **The floor at an unseen simple region.** Paper 1, Proposition 8.1, is for the coin-free and one-tape versions and has the exponent K(Q, b); the form 2^(−sep) is for binary labels (Proposition 8.5); for the per-query mixture the reference is Paper 2, Proposition G.5. Cohen, Hutter, Bengio and Russell (2025) is a published relative.
4. **Low stakes** is Christiano's term; recoverability is the usual formal version in imitation learning.
5. **Tests.** That the price of a property is its own complexity and nothing is assumed about the data source is the central point of the literature on outcome indistinguishability and multicalibration (Dwork, Kim, Reingold, Rothblum and Yona; Hébert-Johnson, Kim, Reingold and Rothblum); attribute it. "Frequencies of tests are all that can be checked for a stochastic human" should rest on a stated lower bound (identity or closeness testing; or a direct two-human construction), not on assertion.
6. **Theorem Pr5.** The argument is Blackwell's approachability condition with an exponential potential; the nearest published forms are the online multivalid predictors of Gupta, Jung, Noarov, Pai and Roth and the defensive forecasting of Vovk, Takemura and Shafer; Sandroni, Smorodinsky and Vohra (2003) is asymptotic.
7. **Squared Hellinger distance of sequential experiments.** The constant 7 is Lemma D.2 of Foster, Han, Qian and Rakhlin (2024, arXiv:2404.10122); Foster, Kakade, Qian and Rakhlin (2021) has 10²·log n.
8. **Exact domination after the demonstrator is withdrawn** is this project's derivation from the top-set rule of Cohen, Hutter and Nanda (2022), not a theorem of theirs.

## Addendum 3 (16 Nov): the lead's decisions for the editors

The proofs are complete and most are verified. The editors of the eight parts write at the same time and cannot see one another's sections, so the following is fixed here. It overrides the earlier parts of this file where they differ.

### Letters and labels

* Tolerated faults: **k** (not m). Validation rounds: **m**. Description length of a shift or of a law of tasks: **ℓ** bits. Threshold of the threshold rule: **η**. Plausible-set parameter: **α**. Price of a test B: **Λ(B) := ln(1/π(B))**. Failure probability: **δ**. Tolerated fraction of faults: **θ** (so k + 1 ≥ θL). Accuracy in total variation: **ε**. The proof files may keep their own letters; the section text uses these.
* The two theorems on recorded runs of the human system are renamed **H1** (was "Theorem A") and **H2** (was "Theorem B"), so that they are not confused with the assumptions A1 to A3.
* Labels of statements that did not exist when the outline was written (use exactly these; do not invent others without saying so in your summary):
  * **R7** (coverage, see below), stated by the editor of rehearsal-core.
  * **N6** (lower bounds for a human who is not deterministic), by the editor of lower-bounds. **N7** (in an open system asking cannot stop: Theorem 3.3 of shift-abstain), by the editor of shift-abstain. **N8** (the factor K under fault tolerance by replication: Theorem 6.1 of assumptions), by the editor of assumptions.
  * **Ab4** (the trade-off between silent errors, abstentions and questions: Theorem 7.3 of shift-abstain).
  * **Pr5** is now the test-only imitator on any sequence in its best form (Rule NH of property-online, Theorem 3.3 with Corollary 3.4; the rule with one rate is mentioned as the simplest instance, with its defect). **Pr6**: the same under rehearsal (Theorem 6.2 and 6.3 of property-online). **Pr7**: what single answers can certify about a human who is not deterministic (Theorem 6.2 of property-batch, with the correction below).
  * **E1** (episodes as the unit that is asked: Theorems 1.7 and 1.8 of assumptions), **E2** (a human who changes during rehearsal: Theorem 1.11 of assumptions), **I1** (patch-free rehearsal for a separated human: Theorem 7.4 of assumptions, with Proposition 7.5 as its price).
* Status words in the note: "proved here", "standard (source)", "open". The provers' tag NEW only means "not in the lead's list of claims"; it must not reach the note as a claim of novelty.

### What each section features, and its length

The proof files contain far more than the note can state. State the results listed; mention others in a clause with a pointer to the proof file; leave the rest to the proof file. Word limits are for the section text.

* **rehearsal-core** (Sections 1 to 3, at most 2400 words). Section 1: the model; A1; A2; A3 in its exact parts, including that every rehearsal run uses fresh coins and that the prior is fixed before the data (take the parts from assumptions.md, Section 0.2, and the fifth part from research/verify/assumptions-attack.md, finding M3); closed deployment by the three conditions of assumptions.md, Definition 4.1 (as corrected in the reports). Section 2: the protocol; deployment draws one round per run. Section 3: R1 with its proof; then, each in a few sentences with a pointer: equality is attained; the random round (fresh per run; kept for good costs Markov's 1/δ and that is needed); the last round cannot replace it in general (the factor (L−1)/8 example) but can for scaffolds whose inputs do not depend on the answers; a new round at every call is not covered (ladder); more questions per run do not improve the bound. R2 for a deterministic human in one sentence, then the marked placeholder for the subsection on whole runs. **R7 (coverage)**: for every set Q of inputs fixed in advance, the probability that the deployed run makes a call in Q although no question of the rounds before T lay in Q is at most L/n; nothing is assumed about the human or the class; for N sets at once the bound is N·L/n. Proof (give it in full): if the run of round t has a call in Q, the asked call lies in Q with probability at least 1/L; the events "the first question in Q is asked in round t" are disjoint; so the sum over t of the probabilities that the run of round t enters Q before any question did is at most L; the deployed run has the law of the run of round T. (It is Theorem 3.2(a) of assumptions.md; verified in both reports of that part; it holds per fixed set, not for all sets at once.) Low stakes: R3; R3a with the constant 2 and the hypothesis that runs have exactly L calls; the recoverable form in one sentence with credit to Ross, Gordon and Bagnell; for a human who is not deterministic the bound L·√(K ln 2/(2n)), the matching lower bound, and the order K/θ² that an example needs. V1: (a) as a bound on the number of unfaithful calls valid for every human, with the plain statement that a certificate of this kind can only be obtained when the human is nearly deterministic on the visited inputs (the exact imitator of a human who varies fails it); the form with recorded disagreements; (b) tests; under A2 the form for a human who is not deterministic; the probability that validation of M^(T) passes. The online form (each call asked with probability q) in two sentences.
* **hellinger-runs** (block i at most 500 words, block ii at most 700). As in the task. Use the labels H1, H2. Add the sharpened form of R2 for scaffolds whose inputs do not depend on the answers (check report).
* **one-mind** (Section 5.1, at most 900 words). R4 with the constant 2L²/(L+1) and its sharpness; R4 has no version for a human who is not deterministic (the example with K = 1, L = 3); R5 as "a member of the class against the committee or its vote"; R6(a); R6(b) with the corollary on one posterior draw taken at the end and kept; the summary of what a single program can and cannot have.
* **lower-bounds** (Section 4 at most 1500 words; the block for Section 6 at most 300). N1 in the total-variation form, with the corrected sentence on the class of all programs; N2 with n ≥ L/(4δ) − L, its tightness, and the attribution of its core to the star-number argument of active learning; the factor K in the form of Theorem 3.1; what targeted questions gain (Protocol AB, with credit to Hegedűs and to Moshkov as the reports direct, its hypotheses, and the lower bound for rehearsal on the rare-points class from the check report, marked as checked by the adversary); N5 with the remark that the gap is closed at k + 1; N6; the bound when the human stays available during the run; the conclusion on what imitation amplifies, with every quantifier the reports ask for (it is a worst case over a class, the class grows, break-even comes after about K ln 2 failed runs).
* **shift-abstain** (Section 6 at most 800 words, Section 7 at most 1200). Section 6: the three kinds of shift as one theorem; S1 in its true forms with the counterexample to the form with visit measures; S3; the online form and N7. Section 7: Ab1 with the rehearsal version; Ab2 with coverage, the comparison with Cohen, Hutter and Nanda, and the abort bound after rehearsal; Ab3; N4 and Ab4; rocks and whitelists; what fails for a human who is not deterministic.
* **property-batch** (Sections 8.1, 8.2, 8.5 and the batch estimator, at most 1300 words). Pr1; Pr3 in the divergence form, called what it is (the Occam bound; the point that the price is the test's own complexity belongs to outcome indistinguishability and multicalibration); the two prices, with the coin example and the repeated-question example; Pr4 as the oracle inequality with the factor 3 and what must be computable; Pr2: the bound in hindsight with its closure constant, the memoriser class, the bound at a fresh input, the bound under rehearsal, and the dependence on the reference machine in the repaired form; **Pr7** with the quantifier that makes it true (one answer per input, or answers from a very large set) and the remark that with a question put twice the mean squared distance of the answer laws can be estimated (collision estimator; attribute it).
* **property-online** (Sections 8.3 and 8.4, at most 1100 words). Pr5 in the form of Rule NH: both bounds, the lower bounds that match them, the corollary with the tests "the answer is not ν's"; the rule with one rate as the simplest instance and why it has no fast one-sided rate; Pr6; one rule kept for good fails; the limits (tests outside the family; runs; a deterministic choice) each with its example; the randomised tilt in two sentences and the open question; the two comparisons with the mixture; what must be computable; attributions as the proof file's Section 5 gives them, marking what was read in the source.
* **assumptions** (caveats at most 300 words; Section 9 at most 1100; Section 10 at most 800). Caveats: A1 (memory inside a run is invisible to the protocol; E1 in one sentence; a human who knows that no run depends on the answer), A2 (the oracle inequality and what it does not give; the example in which the mixture destroys an exact member), A3 (the seeded example; a prior that has seen the data). Section 9: the budget in the researcher's units, with the table; K for a person; N8; rare situations; I1 and its price, with the link to isolation (ultranatural/note.md); E1 and E2; copy or predictor; the objections that are fatal to parts of the claim and the claim that survives, in the corrected wording of the two reports (including the objections the adversary added). Section 10: the seven tests as a table with one paragraph each, with the corrected verdicts of the reports.

### Corrections that every editor must respect

1. A certificate from zero recorded disagreements (V1(a)) is valid for every human but can be obtained only for a human who is nearly deterministic on the visited inputs. For a human who varies, what can be certified without assuming A2 is frequencies of tests and, with repeated questions, a squared distance of answer laws. No sentence may say or imply more.
2. R7 and every "guard" statement hold for each fixed property, or for N properties with the factor N; never "for every property at once".
3. Statements about what imitation amplifies are worst cases over stated classes; write the class and the quantifier.
4. "Frequencies of tests are all that can be checked for a stochastic human" is false as it stands (a question can be put twice under A1); use Pr7.
5. Where a bound is empty for a person (K of the order of 10⁹ bits under a generic prior; an answer that takes a year), say so in that place.
