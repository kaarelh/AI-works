# Total mistakes, circuit complexity, and NNBayes

[NNBayes total-mistake paper](upper/paper.pdf) · [circuit converse paper](circuit-converse/paper.pdf) · [neural converse note](nn-converse.md)

These supporting results study the entire noiseless learning process: each input is presented, a prediction is made, and its true label is revealed. A mistake bound counts all errors, including errors on rare inputs that appear much later. It is stronger than achieving a fixed test accuracy after a finite sample. The three original neural regimes retain their all-input absolute-margin support restriction: `|z(x)| > 1/2` before training.

| Question | Result and qualifications |
|---|---|
| Do the good NNBayes regimes make only polynomially many mistakes in total? | **Yes under uniform random Boolean inputs.** All three original positive regimes have width-independent polynomial bounds in expectation and with high probability, for posterior sampling, majority, and the strict `>2/3` confidence criterion. Uniform sampling without replacement is also covered. |
| Does this extend to other input distributions? | An expected bound depends on `log(1/p_min)`, where `p_min` is the smallest positive input probability. It remains polynomial if that logarithm does. Arbitrary-order or distribution-free cumulative claims require more than the existing class-count argument. |
| Does a small mistake count force a small circuit for circuit induction? | **Yes for specified rules.** Minimum-consistent-circuit mistakes `B` imply `C(f) <= (3d+3)B`. Bayesian sampling under a geometric gate-count/uniform-wiring prior gives `C(f)=O(d M log(d+dM))` for expected mistakes `M`; an explicit prefix prior improves this to `O(dM+1)`. These count total NAND gates without a depth restriction. |
| Does the polynomial converse hold for the original NNBayes learner? | **Not yet proved.** A strong-prior-then-width-limit argument gives an exponential converse. Adding a fixed output cap gives a polynomial converse in that same limit. The original fixed-width polynomial converse remains open. |
| Can the cumulative bound be polynomial in depth? | Yes under the deterministic neuron-merging restrictions, for layered Boolean-circuit teachers with constant wires and compilation overhead counted. The original internal-noise restriction's current approximate-compression proof does not yet give the desired polynomial-depth cumulative extension. |
| What about ReLU? | The [ReLU learning theorem](../relu-learning/) gives cumulative bounds in the strong-prior regime, at finite `gamma >= 2`, and at every finite `gamma >= 1` for one hidden layer. |

## Why the upper bounds work

Suppose the posterior puts all but `beta` of its mass, uniformly over every history, on a fixed family of functions whose log cardinality is at most `h`. On a domain of size `m`, the expected total posterior-sampling errors in a uniform random permutation are at most

$$
1+2(h+1)\sum_{j=1}^{m-1}\frac1j+m\beta.
$$

Repeated inputs require no further mistakes under exact conditioning, so the infinite uniform iid stream has the same total-error distribution. On the Boolean cube, choose `beta=2^(-d)`. The neural compression bounds pay only polynomially for its logarithm, giving polynomial total mistakes. Small learner widths use the direct Bayesian log-prior bound instead. Mixtures of tied minimizers are fully allowed. Cumulative high-probability bounds hold for each fixed learner, with constants independent of its width; they do not assert one event controlling independently sampled predictions at every width.

The [upper paper](upper/) supplies the proof, explicit imported neural budgets, logarithmic-confidence bounds, and the relevant distinctions between sampling and confidence errors. A finite class alone does not give the same guarantee under arbitrary input order: strongly unequal prior masses can produce a long sequence of mistakes. The paper gives an explicit counterexample to that general inference, without claiming it is a counterexample for the Gaussian neural prior.

## Why the circuit converses work

A circuit can be overwritten at one Boolean input using at most `3d+3` additional NAND gates. For minimum-consistent-circuit prediction, a correct prediction leaves minimum size unchanged, and a mistake raises it by at most this additive cost. For Bayesian sampling, an injective repair of descriptions bounds the probability of the correct label from below, letting cumulative sampling errors control log loss. The exact encoding and its length tail matter.

All converses require sufficient coverage: after revealing the full cube they bound the full target's circuit complexity; on a smaller support they bound the smallest extension agreeing there. They also hold after an infinite iid sequence with that support. The Bayesian circuit converse is for posterior sampling, not a proved converse for posterior majority. An arbitrary prior or learner can hard-code a complicated target and make no mistakes.

The [neural note](nn-converse.md) identifies the remaining obstruction in transferring the exception argument: a linear readout can produce a large wrong output, so adding a correcting singleton may cost energy proportional to the current energy. It gives an exact tanh singleton construction, handles tied minimizers, and proves the stated weaker and output-capped results with their distinct order of limits.

## Verification

The papers and neural note have independent AI-agent mathematical reviews. They are not Lean verified and do not change the five main formalized results. Each paper has editable sources, a build script, an independent review, and a publication record. Run `./build.sh` here to rebuild both PDFs. The [neural-note review](verification/nn-converse-review.md) records its narrower scope.
