# Response to the referee report on the third note

The report ([`referee-report-robust-runs.md`](referee-report-robust-runs.md)) reviewed `robust-runs.md` at commit `a75822a4`.
* *What held.* The maths of Sections 1–2 for the majority decoder, and all saved numbers.
* *What did not:*
  * the note claimed more than it proved about "solves the problem" being robust (A1);
  * Theorem 1 does not hold for every decoder (A2);
  * the slide-30 sentence and the persistence paragraph were wrong (A3, A5);
  * one E4 conclusion was a seed artefact (C1).

The note was rewritten. Its conclusion changed: there is no condition on the human alone, with arbitrary replacements, under which outcome properties are robust. The changes, item by item:

## A. Errors

* **A1.** Accepted; this changes the note's conclusion.
  * New Lemma 2: no property of the final state is ρ-robust for ρ ≥ 1/n under arbitrary replacements. Earlier replaced steps can also spoil outcomes with misleading content, and an append-only log does not help.
  * The abstract and items 3, 4 and 7 now say:
    * human-only robustness with arbitrary replacements covers counting properties only;
    * "solves the problem" needs a condition restricted to the decoder's actual guesses, which is learner-relative;
    * I know of no such condition I would vouch for.
  * The claim "for some tasks" is gone.
  * Section 3 now discusses the decoder's guesses by kind and by placement, and says that adversarial placement includes the last steps.
* **A2.** Accepted.
  * Section 2 states that Theorem 1 holds for the majority decoder, and for the per-step sampler with a factor ln 2.
  * It cites the referee's counterexample showing it does not hold for the per-run sampler.
  * Proposition 3 and item 6 say that neither imitator in the note has both guarantees, and Open item 3 asks for one that does.
* **A3.** Accepted. The per-step paragraph now states the Markov bound e/ρ, with the referee's example that e = ρ guarantees nothing.
* **A4.** Accepted. Theorem 1 is stated as n⌊K⌋/(⌊ρn⌋+1) ≤ K/ρ, which gives n⌊K⌋ in the fragile case.
* **A5.** Accepted. The persistence paragraph is rewritten in the referee's form (failures from deficits that start before (1−ρ)n are caught at rate ≥ ρ). It says that for catch-up humans this is restricted, learner-relative robustness against omissions only.

## B. Overclaims

* **B1.** Accepted: a paragraph "No factor n needs a fixed fraction", and in item 1 the bound n·K/(j+1) for a fixed number j of steps.
* **B2.** Accepted.
  * The "measuring it" paragraph and "exactly what Theorem 1 needs" are removed.
  * The empirical question is now Open item 4, phrased by kind and placement.
  * Item 4 says that any usable condition is learner-relative.
* **B3.** Accepted. The four-kinds table was replaced by a table of the decoder's guesses, by kind:
  * junk is removed, since the majority decoder rarely outputs it;
  * placement is discussed explicitly ("an idiosyncrasy at the decisive step is a missing decisive step");
  * the confidence claims are limited to inconsequential idiosyncrasies at random places.
* **B4.** Accepted. "Noise and overfitting" is removed. The note says that in the exact-Bayes model every mistake comes from the data not determining the human, and that the majority decoder's guesses are its most probable continuation.
* **B5.** Accepted. The "randomly placed replacements of any kind" sentence is replaced by robustness against randomly placed *guesses*.
* **B6.** Accepted. The abstract says "in expectation", and item 2 and Theorem 1 the random stopping round.
* **B7.** Accepted. Proposition 3 now:
  * requires Φ and x₀ to be fixed independently of the human, and the prior to be normalised;
  * says the claim fails for properties that mention the human;
  * drops "exactly when".
* **B8.** Accepted. E4 now reports Theorem 1's own quantity, the expected number of bad rounds, next to first passage. It notes that the rows measure all ρ-robust properties at once (Ψ_ρ is the strongest), and states the random-placement and no-compounding caveat.

## C. Experiment

* **C1.** Accepted.
  * E4 was rewritten. It runs until all rules are known, records the sum over rounds of the failure probability (Theorem 1's quantity) and first passage, and uses 40 humans × 5 query seeds.
  * "The fragile property gets more expensive with n" is removed. The note says that the fragile first-passage cost is about the same at every n (the referee's exact expectation, 851.8), while the expected bad rounds grow with n.
  * The README was corrected.
* **C2.** Superseded by the larger run.
* **C3.** Accepted. A bullet says that K(P) ≈ 247 bits while about 15 queries land on mistakes, so E4 does not test the size of the bound.
* **C4.** Accepted. The setup says the same humans are used at every n and that ± is a standard error; the stopping rule is described.

## D. Minor

* **D1.** "Chosen adaptively" is removed from the definition. A corrupted run is now defined as a sequence with j non-P transitions.
* **D2.** Ψ_ρ is stated as the strongest ρ-robust property.
* **D3.** The adversary does not see round t's coin; ⌊K⌋.
* **D4.** The notation is w(· | H_D).
* **D5.** "Fire in about one step of a run in which they fire at all".
* **D6.** Moot: the slack sentence is removed.
* **D7.** Moot: the new table reports standard errors over 200 runs.
* **D8.** Moot: junk is removed.
* **D9.** The graded hypothesis is written as "at least S(human) − c·j/n after j replaced steps".
* **D10.** The first note's Theorem 3 is cited as an example of the decisive case, not as a proof about robust properties.
