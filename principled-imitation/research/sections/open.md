## 13. Open questions

The questions are ordered by how much an answer would change the conclusions of Section 0. Each proof file ends with a longer list for its part.

1. **A prior under which K is affordable.** Every positive result is in K, and the theorems hold for any prior fixed before the data. Nothing here says how to obtain a prior that puts weight 2^(−K) on a given person with K in the thousands and not in the billions, nor how to tell that one has it. With the certificate one can at least find out afterwards, for a human who is nearly deterministic on the inputs that matter.

2. **Classes without patches.** If the human is separated from every other member of a class, the posterior concentrates exponentially fast (I1), and the lower bounds of Section 4 do not apply, because they need a class that can change one place at a time. Is there a natural class of this kind that contains the humans one cares about? For functions on the integers the companion note on isolation (`ultranatural/note.md`) has candidates; for samplers, and with a prior to fall back on when the human is outside the class, nothing is proved.

3. **Both prices in one imitator, for a human who varies.** For a deterministic human, the imitator built from tests pays K + 3 disagreements if the human is in the class and log₂(1/π(B)) + 2 violations of each property otherwise (Pr5). For a human who varies, the tilted mixture trades the two against each other (Section 8.5). Is there one randomised imitator whose divergence from the human, summed over the questions, is of order K under A2, and whose books are of order √(n·(Λ(B) + ln n)) with no assumption?

4. **The factor K, exactly.** Over classes of K bits the least number of questions is of order K·L/(δ·log₂(L/δ)), reached by targeted questions that may lie off every run (N2c); rehearsal's own worst case is of order K·L/δ. A variant that asks only calls of its own runs and saves a logarithm is in the proof file with one check (`proofs/lower-bounds.md`, Proposition 3.9). Under low stakes with bounded damage the only lower bound that contains K is n ≥ (1 − 2θ − 2δ)·K; whether the factor 1/(θδ) of R3 is needed there is open.

5. **Low stakes for a human who varies.** R3 costs of the order of K/θ² questions in an example, against K/θ for a deterministic human. When is K/θ enough, and must the number of questions grow as the allowed excess failure shrinks?

6. **The last round.** All bounds are for the mixture of a uniformly chosen round. For a deterministic human on a scaffold whose questions depend on the answers, the mixture after all n answers is known to lose a factor between a constant and about L·ln n in the probability of an unfaithful run; for recorded runs (H1) the question whether the last posterior alone has the bound is posed in the literature (Grünwald and Kotłowski 2011).

7. **One program for a human who varies.** A member chosen by squared weights after rehearsal by the mixture has a bound (R6(c), checked by one reader besides its author). Whether a posterior draw for each run can be supported by fewer answers than whole recorded runs of the human system is open, and so is the general form of R5: does the plurality vote of the committee always inherit the fault tolerance that the committee uses?

8. **Abstention.** A bound on what the threshold rule refuses (its width as a whitelist); whether the novelty rule needs s > 2K or s > K suffices; rehearsal driven by the minimum rule, which would remove the term L(L − 1) from Ab2(d); what replaces the count of abstentions for samplers (Section 7.5); computable versions of sep and of the plausible sets under time bounds.

9. **The reference machine.** Whether the mixture keeps a simple property at a fresh input, at a price in the property's complexity, is false on some universal machines (Pr2(c)) and open for any fixed one that would be called natural. No definition of natural is known that makes the question precise.

10. **Episodes.** When the unit put to the human is an episode with memory inside it, R1 and V1 hold with episodes for calls (E1). For nested episodes and a human who varies the whole-run bound carries an extra factor, the smaller of four times the largest number of calls in one episode and half the number of episodes of a run; whether it is needed is open.

11. **Constants.** The best constant in Lemma L4(a) lies between 2.9639 and 2.9642. The constants of the lower bounds for a human who varies (N6) are about 10⁴ away from the upper bounds.
