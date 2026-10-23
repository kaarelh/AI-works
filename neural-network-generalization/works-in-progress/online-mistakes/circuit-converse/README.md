# Few online mistakes imply a small Boolean circuit

[Paper PDF](paper.pdf) · [LaTeX source](source/paper.tex) · [Review record](verification/review-record.md)

This note proves converses for three explicit circuit-induction rules. Write `C(f)` for the minimum total number of NAND gates implementing a Boolean function on `d` input bits. Constants and inputs are available wires; circuit depth is unrestricted.

- **Minimum consistent circuit:** after a complete reveal of the domain, actual mistakes `B` satisfy `C(f) ≤ (3d+3) B`, for any tie-breaking and any input order.
- **Bayesian posterior sampling with a geometric gate-count and uniform-wiring prior:** expected total mistakes `M` imply `C(f) = O(d M log(d+dM))`. The same prior gives the usual upper bound `M = O(C(f) log(d+C(f))+1)`.
- **Bayesian posterior sampling with an explicit prefix circuit language:** allowing a short exception constructor sharpens the converse to `C(f) = O(d M+1)`, while preserving the same circuit-size upper bound.

The Bayesian converses work by relating sampling mistakes to logarithmic loss. A one-point exception repairs a circuit without changing its earlier labels. We define the priors exactly, verify that the repair is injective on descriptions, and account for its probability cost. This last cost depends on the circuit length for the ordinary wiring prior; the prefix language makes it independent of length.

The results also hold for an infinite iid input sequence. If the input distribution has full support, every input is eventually revealed and the conclusion concerns the whole target. Otherwise it concerns the minimum circuit agreeing with the target on the distribution's support. Rare points can take arbitrarily long to appear, so these are total-mistake statements, not conclusions from a finite stretch of low error.

The theorem does not apply to arbitrary learners, arbitrary priors, posterior-majority prediction, fixed-depth circuit complexity, or conflicting noisy labels. A learner or prior that hard-codes a complex function can predict it with zero mistakes. Partial observations likewise cannot control the target outside the observed support.

Authors: ChatGPT-6 Astra, Kaarel Hänni, and Dmitry Vaintrob. This is a research manuscript with complete mathematical proofs and independent AI-agent mathematical reviews; it is not Lean verified.

Rebuild with `./build.sh`. See the [independent audit](verification/mathematical-review.md) and [publication record](verification/publication-build.json).
