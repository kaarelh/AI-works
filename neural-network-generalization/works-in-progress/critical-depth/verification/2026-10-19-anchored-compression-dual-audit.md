# Independent audit: exact-anchor critical path compression

Auditor: critical-depth agent. Date: 2026-10-19. Reviewed source SHA-256: `ea896304e0366da97194b7e7dcf3927506173953f9608c6fcd7fa48a4161dcfe`.

I checked the complete proof in `anchored-compression.md`, focusing independently on the greedy anchor construction, conditional entropy and Gaussian coupling arguments, singular cases, and final readout transfer. No substantive mathematical gap was found.

## Greedy selection

For each layer, the increase `I_j(T union {x})-I_j(T)` is exactly the conditional relative entropy averaged under the controlled anchor marginal. Adding other anchors can change this increase in either direction, but the proof does not require monotonicity of the increase: the total `sum_j I_j(T)` is monotone, bounded by `sum_j D_j`, and increases by more than delta whenever an entropy step is chosen.

For the readout step, if its residual inner product at x exceeds t, the new feature direction orthogonal to the existing anchor span has squared norm at most one. Orthogonal projection therefore increases the squared norm of the represented readout by more than t^2. The same anchor additions also monotonically increase every layer's information. The combined potential proves the stated anchor count even when both searches are interleaved.

## Anchored Gaussian geometry

With an identical anchor second-moment block, the normalized cross vector lies in its range by positive semidefiniteness. The formula involving its pseudoinverse is therefore legitimate. Coupling the Gaussian anchor vectors identically fixes the linear conditional means. Coupling the two scalar conditional residuals with the same standard Gaussian gives precisely the displayed root-mean-square distance. This proves the distance formula and triangle inequality, including zero conditional variances and singular anchor blocks.

A common-anchor coupling of arbitrary feature vectors gives a positive semidefinite uncentered joint second-moment matrix. Gaussianizing this matrix yields another common-anchor coupling with the same query mean-square discrepancy. Hence the second-moment comparison needs neither centering nor Gaussian original feature laws.

## Entropy projection and propagation

The Rao--Blackwellized law has the original controlled anchor marginal and the reference Gaussian conditional law elsewhere, so its density depends only on the anchor Gaussian field and it preserves the outgoing anchor covariance exactly. Conditional Gaussian T2 applies to each query given the anchors. The conditional variance is bounded by the original incoming diagonal, at most two initially and at most one afterwards. Integrating the conditional KL gives the injected bound `2 sqrt(delta)`.

For transfer between two covariances with the same anchor block, the optimal anchored reference coupling is jointly Gaussian. Tilting this joint law by the common anchor density changes both marginals exactly as desired and costs precisely the anchor relative entropy. Gaussian T2 after whitening, or its scalar marginal consequence, bounds the RMS difference by `1+sqrt(2D_T)` times its reference RMS difference. Singular covariances cause no issue: all finite-entropy tilted laws stay on the reference support.

Only the selected query and anchors are coupled in each comparison. This suffices because the candidate controlled law itself is defined globally from the fixed density on anchors, independently of the coupling used to prove the bound for a particular query. No incompatible query-dependent candidate law is introduced.

## Finite realization and final output

I also checked the finite quadrature algebra. The correction B is positive definite, has `E^T B E=I`, and can be absorbed into the next ordinary linear preactivation matrix together with the positive importance weights. Its possibly large finite coefficients are permitted: no quantitative weight bound is being claimed. An incoming corrected covariance can have diagonal slightly above one; this does not invalidate the proof. The entropy-projection injection bound uses original covariances, the controlled propagation lemma has no diagonal bound, and every newly sampled activated feature is again in [-1,1].

The original and candidate kernels keep the anchor block exactly equal at every step. The projected terminal readout has norm at most sqrt(2r) in that common anchor Hilbert space, so its output error is bounded by this norm times the anchored distance. No bound on its possibly ill-conditioned coefficient vector is needed. The finite output is a linear readout of the final tanh neurons, including the final positive covariance factor. Thus depth remains L.

The stated error choice is conservative: it gives projection error 1/16 and propagated error at most 1/32. The resulting finite network has strictly positive margin above 1/4. Anchor count and quadrature width are a universal polynomial in d,H,A times exp(C S).

This verifies the finite-representation theorem. It does not by itself assert an intrinsic Frobenius-product bound, a bound on numerical weights, or the separate VC/sample-complexity consequence.

## Final TeX source

I also independently reviewed the complete assembled source `source/critical-anchored-compression.tex`, SHA-256 `2ba18dca29258d012eacd3b8974a3ebbfb6ea6e5788a1a709785a62631f0320d`. It faithfully preserves the audited argument. The explicit bound `C(d+L+A_0)^30 exp(20S)` is valid: the displayed intermediate width is `C H^12 A_0^10 exp(12sqrt(2)S)` times `d+log(H+A_0+2)+S+1`, and `S<=sqrt(H A_0)` absorbs the remaining factor into the chosen polynomial. The uniform output error is 3/32. The infimum-rate corollary correctly uses an admissible path within 1/L of the infimum and absorbs its extra exponential factor into a universal constant. Approved without mathematical corrections.
