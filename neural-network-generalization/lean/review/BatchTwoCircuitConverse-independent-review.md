# Circuit-converse statement review

Reviewed against `works-in-progress/online-mistakes/circuit-converse/source/paper.tex` on 22 October 2026 by the coordinating agent, separately from the agent that implemented these proofs.

The three main results match the manuscript. The deterministic learner uses actual minimum-size NAND circuits with arbitrary tie-breaking. The geometric Bayesian learner uses the stated normalized geometric distribution over gate count and uniform legal wiring; its lower bound, inverted bound, and forward bound retain the displayed constants. The exception-code learner uses the stated squared code weights, and its linear converse, forward bound, and explicit code-length bound match. Inputs, full or partial-domain coverage, repeated queries, and the distinction between NAND gate count and network width are retained.

The Bayesian theorems count actual sampled errors. Their conditional-expectation premise specifies posterior sampling; the proof derives the relation to cumulative predictive error rather than assuming the final expected mistake bound. The infinite-IID extension uses the actual product input law, proves coverage of its support, and needs no minimum positive atom probability. No Bayesian majority-prediction converse is claimed.

Two representation choices deserve explicit mention. The formal overwrite pads to exactly `3d+3` gates, within the manuscript's upper bound. Prefix programs are formal abstract syntax with exact code lengths and a proved counting/Kraft bound; a bitstring serializer and parser are not included. These choices preserve the probability laws and main quantitative statements.

The theorem map in `BatchTwoCircuitConverse-status.md` identifies the checked endpoints and the prose claims outside scope. Main theorem statement inspection found no added analytic premise or weakened numerical conclusion. Public verification still requires the collection's final source rebuild and axiom audit.
