# Verification record

The proofs in this package have independent AI-agent mathematical reviews. They have not been formalized in Lean.

The [final twenty-eight-source integration review](independent-final-twentyeight-source-review.md) and its [SHA-256 manifest](independent-final-twentyeight-source-review-hashes.json) identify the current manuscript. Earlier `raw-core` and `raw-assembly` reviews are preserved as intermediate snapshots; they are not substitutes for the final review.

The reviewed argument has seven components:

1. Uniform comparison distributions inside the same finite architecture, with placement entropy canceled and the full selected parameter blocks charged.
2. Native raw-output supremum tails for Gamma/Gaussian, normalized Gaussian, independent variance-gamma, and optional normalized power readouts.
3. Transfer from a proof-only bounded prior to the actual unrestricted posterior, including removal of an auxiliary comparison-output cutoff.
4. A relative finite-dictionary argument for finite-variance labels, with distinct Gaussian-hidden and Student-hidden compression budgets.
5. Noise-separated posterior-density control, optimistic approximation oracles, a fixed-temperature noisy-realizable raw-risk theorem, and a separate correctly specified Gaussian-likelihood testing theorem at the exactly matched variance.
6. An optional sinh-normal readout law with native logarithmic supremum moments, its nearly inverse-sample expected oracle, a growing-range compiler interface, and conditional- and marginal-label high-probability guarantees.
7. A single additional hardtanh or ReLU6 final hidden layer, allowing arbitrary globally Lipschitz prefixes and input distributions on the cube, with a jointly polynomial resource and logarithmic coefficient cost. Both sinh-normal and normalized Gaussian readout versions are included. The teacher/learner depth difference is explicit.

The ordinary mean and posterior-averaged risk are distinguished in the theorem statements. The agnostic likelihood calibration, fixed-temperature realizable result, and prescribed-budget optimistic result are separate guarantees. The final manuscript's source hashes cover their integration and the displayed resource bounds.

The PDF is built twice with `pdflatex`; the final build is checked for undefined references, missing citations, and overfull boxes.
