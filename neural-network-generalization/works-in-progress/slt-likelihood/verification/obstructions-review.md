This record reviews the research draft used to prepare the [published proof note](../README.md). The scratch filenames below identify that review snapshot. It is an AI-agent mathematical review, not a Lean proof or external peer review.

# Independent audit of smooth-likelihood obstructions

Auditor: separate Codex agent `/root/slt_positive`. Date: 19 October 2026.

Reviewed `/workspace/slt-likelihood-2026-10-19/obstruction.md` in full. Both principal obstructions are correct as stated, under their explicitly fixed-sample/fixed-likelihood limit orders. No mathematical gap found.

## Raw prior

The readout variance bound is uniform in hidden weights and inputs. For fixed finite data, bounded continuity and a positive limiting likelihood give L1 convergence to a positive constant, hence total variation convergence of posterior to prior. Symmetry of the Gaussian readout makes the latent sign probability exactly one half before likelihood reweighting (the conditional readout variance is positive almost surely for the tanh network with constant input). The conclusion is therefore valid for both strong-prior-first and width-first raw priors, and does not imply failure of a posterior-mean sign rule. The text preserves that distinction correctly.

## Globally conditioned depth-two XOR example

The strict concavity calculation is valid: setting t=tanh r, the displayed derivative numerator is r(1−3t²)−t, and t>r(1−t²) makes this strictly less than −2rt². The cube covariance identity and both Jensen steps are correct.

At minimum energy, equality in the first margin bound makes every output magnitude exactly 1/2. Strict Jensen makes each affine preactivation have constant magnitude. On the two-dimensional cube its three nonconstant square Fourier coefficients are 2a0a1, 2a0a2, 2a1a2, so exactly one affine coefficient is nonzero in every active row. Strict Jensen over row norms makes every row nonzero with equal norm. Pointwise equality in Cauchy–Schwarz forces the hidden functions to be mutually proportional. This leaves precisely constants and signed coordinates.

Coercivity at fixed width gives the stated strict energy gap to every other sign function, including XOR, even though the original margin constraint is open. The supplied three-neuron XOR implementation approaches outputs +1 on equal bits and −1 on unequal bits, so it supplies a strict-margin representation for sufficiently large t. Zero-padding preserves representability for larger N.

Fixed positive continuous bounded likelihood factors preserve the exponential energy rates. There are finitely many sign functions on this cube, so every limiting posterior is supported on the six identified functions. All have XOR error exactly 1/2, hence every mixture does too. The conversion from mean correct-sign probability tending to 1/2 to liminf confidence-failure fraction at least 1/4 is valid.

For the logistic posterior-predictive claim, one additionally uses concentration of the parameter posterior on the **minimum-energy parameter set**, not merely on the six sign-function events. The same elementary coercive Laplace argument proves this immediately: every fixed closed complement of a neighborhood of that compact minimum set has a strict energy gap. Thus the claim is correct. For clarity in the published note, consider adding one sentence explicitly stating this parameter-space concentration before invoking minimum-energy outputs ±1/2.

The note correctly does not claim a globally conditioned width-first counterexample for every gamma≥1. That extrapolation would require additional rate analysis.
