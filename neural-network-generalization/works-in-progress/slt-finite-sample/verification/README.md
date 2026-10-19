# Mathematical review of the finite-sample fan-in certificate

19 October 2026. This records conventional mathematical checks of the [supporting note](../README.md). It is not Lean verification and does not extend the five main results.

One Codex agent developed the Gaussian comparison distribution. The parent independently checked its variance choices, exact relative-entropy cost, layerwise mean-squared approximation bound, and final-posterior argument. A second agent independently checked both the matched-noise predictive guarantee and the clean-data final-posterior extension. A third agent reviewed the completed note and FAQ, including the polynomial depth dependence. A separate source review checked the associated SLT comparison.

## Checks performed

- **Full prior accounted for.** Only the first C incoming rows of each hidden matrix and the full readout have their variances reduced. All other parameters remain distributed as under the prior. The count Q and mean-shift cost E_N in the note are exact, including the first-layer normalization.
- **Extent of the comparison distribution.** Unselected hidden rows retain their full prior law, with total expected squared displacement from the padded teacher equal to (L−1)(N−C). The certificate does not require a small parameter ball or accuracy for every parameter in its support. Its cancellation is conditional variance addition within a neuron, not cancellation of squared losses across inputs. This distinction does not assert that all SLT proofs use small isotropic balls.
- **No independence assumption on activation errors.** The deterministic discrepancy is bounded by Cauchy–Schwarz. Conditional independence of each new Gaussian weight row from preceding layers makes the noise cross term vanish; bounded activations give variance at most t. This proves the uniform expected output-error bound.
- **Normalizer controlled for every sample.** Variational Jensen uses the fixed comparison distribution and its pointwise expected approximation bound. No unproved high-probability tube event or parameter truncation is needed.
- **Actual final posterior.** Integration of the bad-predictor likelihood, independence of training inputs, and Markov's inequality give posterior bad-set mass at most b. Tonelli and a second Markov inequality yield the strict greater-than-two-thirds latent-output confidence convention, with r=b=epsilon/6.
- **Depth dependence.** The propagation factor A_L can be exponential in depth, but only its logarithm enters the final sample threshold. The displayed explicit threshold is polynomial in depth and bounded-weight teacher resources, while remaining linear in learner width.
- **Noisy-data scope.** The matched Gaussian-noise statement uses the relative-entropy chain rule and controls expected averaged sequential predictive KL, or the mixture of prefix predictives. It does not claim a final-predictive bound from that average.
- **Counterexample.** Gaussian conjugacy gives the exact bias, sampling variance, and posterior variance in the delayed-learning example. The stated lower bound and fixed-prior asymptotic coefficient follow directly.

## Limits

The result uses bounded tanh hidden activations, a bounded-weight teacher at the learner depth, the stated independent Gaussian prior, and a fixed Gaussian likelihood. It does not assert exact interpolation or condition on a global margin. The clean-data theorem concerns posterior latent-output accuracy; the noisy variant concerns predictive densities. The O(N) sample cost is eventually smaller than the quadratic parameter count at fixed depth at least three, but is not uniform in arbitrarily large N. This does not establish practical numerical sharpness, superiority to all classical complexity bounds, or the behavior of typical SGD-trained networks.

The main manuscripts, PDFs, and Lean sources are unchanged. The collection checker, local links, and file checksums are checked separately for publication.
