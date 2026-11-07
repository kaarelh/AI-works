# Continuous-activation research record, 7 November 2026

The [triangle-wave paper](../../isotropic-triangle-allwidth/paper.pdf) and [monotone-activation paper](../../isotropic-monotone-allwidth/paper.pdf) give actual-posterior counterexamples at every sufficiently large width. These two notes explain why their exact atomic argument does not immediately extend to ordinary smooth activations.

- [Smooth periodic activations](SMOOTH-PERIODIC-OBSTRUCTION.md): integer-lattice parity atoms are not norm-optimal after differentiable smoothing. For sine, the note determines the one-parity variation cost and disproves the proposed diagonal weighted Fourier norm even after projection onto a two-character code.
- [Tanh](TANH-ATOMWISE-OBSTRUCTION.md): an optimal single-parity atom has zero dual deficit but nonzero variation within parity fibers, so the specific atomwise rounding inequality cannot hold. This leaves calibration-aware and multi-neuron arguments open.

Neither note proves a total-mistake upper bound, or rules out a different counterexample for tanh, sine, or ReLU. These are conventional mathematical research notes, not Lean formalizations. The smooth-periodic note has an independent source-level mathematical review; the tanh note has been checked by the coordinating agent against its norm-attainment and injectivity arguments.
