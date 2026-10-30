# Exponential mistakes and polynomial guarantees for circuit Occam learning

[Paper (PDF)](paper.pdf) · [LaTeX source](source/paper.tex) · [review and checks](verification/README.md)

An online learner predicts a Boolean label and then receives the correct label. The target is fixed, but the input distribution or input order may change. The learner always uses a circuit of minimum gate count consistent with every previous label. Which minimum circuit it selects matters.

| Rule or input condition | Total-mistake result |
|---|---|
| Any deterministic circuit selection based only on the previous history | For the AND of `d` variables, some distinct-input ordering forces at least `2^d−d−2` mistakes. The target's exact minimum size is `d−1` with AND available and `2d−2` for NAND-only circuits. |
| Fresh uniform sampling among minimum-size consistent circuit descriptions | Expected `O(s² log(d+s))` mistakes for every nonanticipating adaptive input sequence, where `s` is the target gate count. A logarithmic-confidence bound holds over the infinite horizon. |
| Majority vote within the minimum-size class | Deterministic `O(s² log(d+s))` mistakes on every input sequence. This can be implemented by selecting a minimum circuit after seeing the current input. |
| Any history-based tie rule; random shuffling within successive Hamming-weight levels | The same AND example has `Θ(d²)` expected mistakes. This statement uses the all-binary-gate or AND/OR/NOT basis. |
| Any history-based tie rule; arbitrary adaptive switching or mixing among `K` fixed uniform-subset environments | Expected `O(K(s+1) log(d+s+2)(d+1))` mistakes, with an infinite-horizon high-probability bound. The subsets may be disjoint and the learner need not know them. More general distributions are covered through their smallest positive disagreement probabilities. |
| Adaptive input laws between `a` and `b` times a fixed reference distribution | Polynomial expected mistakes if `b/a` and the logarithm of the inverse smallest positive disagreement probability are controlled. The distributions need never converge. |
| Constant-fraction elimination on the selected predictor's mistakes | The target-relative genericity premise gives expectation and high-probability bounds logarithmic in the initial candidate count. Its applicability to realistic data remains a separate question. |

The first lower bound is literal exponential dependence on **gate count**. In a gate-list description of length `ℓ=Θ(d log d)`, it is `2^{Ω(ℓ/log ℓ)}`. Circuits have bounded fan-in, arbitrary sharing, and charged gates. The NAND proof does not follow merely by compiling AND gates: it proves exact NAND minimality using a positive-certificate bound.

The deterministic lower bound has quantifiers “for every history-based deterministic selection rule, there exists a bad permutation.” The permutation can be fixed in advance for that rule. It is not one permutation that defeats all rules. Fresh random circuit choices must remain hidden until the next input has been selected. Query-dependent minimum-circuit selection is a different rule and includes the polynomial minimum-class majority predictor.

**Small distribution shifts alone are insufficient.** A further construction gives at least `2^{d/2}` mistakes even though every conditional input law is within `exp(−d/8)` total variation of uniform. For a fixed circuit ranking, the total successive distribution drift is also exponentially small. This construction uses repeated inputs and an exponentially long horizon; the distinct-input ladder does not use repetitions. The failure comes from continually excluding most of the remaining rare counterexamples. The positive reference theorem therefore requires persistent lower as well as upper coverage, or a summable total departure from that condition.

**Provenance and verification.** The all-binary-gate AND ladder was already proved in the [Solomonoff operator-induction manuscript](../../../../solomonoff-operator-induction/paper/main.pdf), following the original slides. This paper presents a shorter proof, a NAND-only extension, and a common treatment of the positive results and their limitations. The proofs have independent AI-agent reviews and finite computational checks; they are **not Lean formalized**. The checks and their precise scope are recorded in [verification](verification/README.md).

These are results about specified circuit learners. They do not establish arbitrary-order polynomial mistake bounds for a Gaussian NNBayes posterior. Ordinary Bayesian averaging over a fixed circuit prior also differs from selecting a minimum circuit; its standard log-prior mistake bound is discussed in the [circuit-converse paper](../circuit-converse/paper.pdf).

Run `bash build.sh` to rebuild the PDF. Generated `build/` files are not published.
