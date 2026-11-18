# Independent proof audit

Reviewed by the independent proof-audit research agent, 18 November 2026. Exact reviewed sources are listed in `independent-review-hashes.json`.

The row-gain theorem passes an independent conventional mathematical audit. This is not a Lean verification.

Checked the model and abstract against the complete final theorem, including the change in readout scale to precision H*N^kappa and the restrictions on teacher support. The bounded monotone activation argument correctly handles phi=c+psi with psi odd: symmetry gives the exact absolute-supremum decomposition, scalar contraction yields the stated geometric sum, and the first-layer threshold-mixture representation controls all affine features. The general zero-origin argument correctly uses exponential Rademacher contraction before taking its logarithm, so the depth dependence is linear in squared capacity rather than exponential.

Checked the conditional-Gaussian affine transport identity, including cancellation of its normalizer and boundary support points; clone energy and unchanged absolute row sums at every larger width; dimension normalization by H*N^kappa; and the per-neuron L2 perturbation recurrence without a maximum of Gaussian errors.

The readout energy has the claimed scaled chi-square law. The objective-tail bound, entropy payment, common dyadic statistical event, observable certificate, measurable smallest minimizing likelihood, and no-upper-lambda argument all match the previously independently checked generic square-root-capacity theorem. The final Bernstein substitution gives the advertised constants 6 and 25. Depth enters only logarithmically in the bounded-activation case and linearly for the general zero-origin case at fixed other resources.

No substantive gap was found. The theorem is not a result for unchanged canonical scaling tuples, unrestricted teacher networks, arbitrary activations with nonzero offsets, or efficient inference; these limits are clearly stated.

The subsequent sigmoid attenuation sentence was also checked: each of the H-1 internal unit-row-sum layers contracts input variation by at most 1/4, and a readout with coefficient cap B and width C has absolute coefficient sum at most CB. Hence output oscillation is at most CB*4^(-(H-1)). The hash record includes this presentation addition.
