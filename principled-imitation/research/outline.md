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
