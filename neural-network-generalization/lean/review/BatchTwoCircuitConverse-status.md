# Circuit converse formalization: theorem map and scope

Manuscript: `neural-network-generalization/works-in-progress/online-mistakes/circuit-converse/source/paper.tex`.

Lean source prefix: `neural-network-generalization/lean/NeuralGeneralization/BatchTwoCircuitConverse`.
Common namespace: `NeuralGeneralization.BatchTwoCircuitConverse`, with the prefix-language results in its `.Prefix` namespace.

## Main statements completed

| Manuscript | Exact Lean theorem | Module |
|---|---|---|
| Deterministic Occam converse, every finite history: C_A ≤ (3d+3) B | `deterministic_occam_converse` | `BatchTwoCircuitConverseDeterministic` |
| Complete finite reveal with arbitrary minimum-size tie-breaking | `deterministic_complete_reveal` | same |
| Geometric gate prior: lower bound, inverted bound, forward bound with exact constants | `geometric_sampled_circuit_converse` | `BatchTwoCircuitConverseSampling` |
| Prefix exception prior: exact linear converse, forward bound, explicit code bound | `Prefix.prefix_sampled_circuit_converse` | `BatchTwoCircuitConversePrefixSampling` |
| Infinite iid deterministic Occam converse on exact PMF support | `deterministic_iid_circuit_converse` | `BatchTwoCircuitConverseIID` |
| Infinite iid geometric-prior converse, all three exact inequalities | `geometric_iid_sampled_circuit_converse` | same |
| Infinite iid prefix-prior converse and code bound | `Prefix.prefix_iid_sampled_circuit_converse` | same |

The finite sampled theorems permit a random/adaptive query order, an unbounded finite stopping index, and almost-sure complete revelation. The iid theorems count the actual infinite sum of sampled 0/1 mistakes, prove its expectation is finite, and require no lower bound on positive input probabilities. The standard conditional posterior-sampling law is the learner specification; equality of expected actual errors and the compensator is proved by tower property and Tonelli rather than assumed.

## Definitions match the substantive manuscript objects

- `Circuit d` is an actual topologically ordered NAND gate list. Inputs are `Fin d → Bool`; constants false/true are available; a nonempty circuit outputs its last gate, and empty outputs false. Dead gates and repeated wires are allowed.
- `complexity f A` is the actual minimum gate count, defined by `Nat.find` after proving representability.
- The circuit overwrite appends exactly `3d+3` gates, including a harmless extra NOT for each positive literal. The paper uses at most `3d+3`; this padded implementation proves the same statement and constants. Truncation proves injectivity on actual descriptions.
- `circuitPrior d` is a normalized PMF: size `s` has probability `2^(-(s+1))`, with uniform mass over every actual legal wiring list. It is pushed forward to the finite type of Boolean functions, with aggregation of all descriptions preserved.
- The prefix language is represented by its exact abstract syntax: a base circuit and a finite nested exception chain. `Program.length` counts the stated tags, unary length, fixed-width addresses, and exception metadata. An explicit bitstring serializer/parser is not formalized; the normalized probability law and Kraft bound are instead proved directly by counting these syntax objects, with exactly the manuscript's code lengths. No abstract coding, repair, or capacity assumption is introduced.
- `codeComplexity` is minimum actual program length. The compiled NAND circuit has at most three times this length. The exact quantitative replacement of the manuscript's big-O is `K ≤ 3+C+2*C*Nat.clog 2 (d+C+1)`.
- The exact consistency posterior is the shared `BatchTwoOnline.onlinePosterior`; proof modules establish equality between its sampling error and the actual version-mass ratio.

## Main dependency chain

1. Actual NAND syntax, one-point overwrite, injectivity: `Circuits`, `Descriptions`, `Deterministic`.
2. Actual geometric PMF and pushforward: `Prior`, `BayesForward`, `Mass`.
3. Predictive floor, exact loss control, inverse logarithmic estimate: `Prediction`, `Cutoff`, `Pathwise`, `LogInversion`, `Posterior`, `Lower`.
4. Random reveals and actual sampling: `RandomReveal`, `Sampling`.
5. Prefix grammar, Kraft counting, normalization: `PrefixLanguage`, `PrefixKraft`, `PrefixPrior`.
6. Prefix posterior bounds and exact code cost: `PrefixPrediction`, `PrefixPosterior`, `PrefixCoding`, `PrefixRandomReveal`, `PrefixSampling`.
7. Arbitrary finite-distribution iid coverage and actual infinite mistakes: `IIDCoverage`, `InfiniteSampling`, `IID`.

## Verification

Targeted build succeeded:

```sh
PATH=/workspace/lean-toolchains/lean-4.32.0-linux/bin:$PATH \
  lake build NeuralGeneralization.BatchTwoCircuitConverseIID
```

`#print axioms` for all six final deterministic/geometric/prefix finite-or-iid theorem families reports only `propext`, `Classical.choice`, and `Quot.sound`. There are no `sorry`, `sorryAx`, or custom axioms in this proof chain. Benign linter/deprecation warnings remain.

## Scope not claimed

- The prose discussion of limitations/counterexamples, the counting assertion that some functions need order `2^d/d` gates, and an executable prefix string parser are not formalized.
- The separate neural-network converse paper is not covered by these modules.
- Root must independently audit the theorem-to-manuscript mapping before changing public verification status or promoting the paper.
