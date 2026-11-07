# Independent full-source audit: monotone triangle construction

7 November 2026. Audited the complete source `fresh_full/monotone-paper/source/paper.tex`, using the normalized activation `psi(t)=(2t+phi(t))/3`, `epsilon=1/3`, and `c=10^8(D+1)^3+1`.

**Verdict: PASS.** The theorem establishes the claimed actual-posterior mistakes for this fixed strictly increasing, 1-Lipschitz activation, at every sufficiently large width and with the variance limit taken at that fixed width. It does not establish the ordinary ReLU, tanh, GELU, or hardtanh statement.

I checked the complete chain, with particular attention to the modifications from the triangle-only result:

* Four orientations have zero column sums and equal positive row products. They cancel the entire affine term, including the bias when representing even-support physical characters, while preserving the triangle parity term. Every teacher readout has magnitude `3/4`, and the width is `4(2m-1)=8m-4`.
* For an arbitrary competitor, `F=L+epsilon T` and `R=T-PT` give `V >= Q(F)/epsilon + kappa B`, `||R||_2<=B`. No cancellation assumption is made about its affine component.
* On each calibrated logical fiber, the residual after projection has zero core-weighted conditional mean. Therefore the available margin slack dominates half its conditional absolute mean. The flat dual has magnitude at least two at every calibrated logical input, including zero. Dropping these coefficients before bounding residuals avoids any large coefficient at zero.
* The affine moment bounds remain valid with a deterministic bias. Removing the unknown set of probability `1/16` costs at most `A/4`. Thus the stated `eta=1/sqrt(3)-1/4` and both inequalities for `E'` are correct. The convex-combination weight `kappa/[sqrt(c)(1+eta)]` yields exactly `kappa eta/(1+eta)(A+beta)`.
* Sign variation inside a parity fiber forces an adjacent two-bit sign change; failure of core oddness instead forces a nonzero core average. Together these give `A+beta >= 1/(2 sqrt(D+1))`. The core-size prefactor makes the non-code gap exceed every star's excess above the flat lower bound.
* The weighted subgroup dual, non-subgroup Fourier gap, squarefree independence, and cyclotomic distinctness arguments are correct. The odd block half-sizes lie in `(2m,4m)`, so no one divides another; primality is unnecessary.
* At finite width each orientation retains its exact total readout despite different integer replica counts, so its affine cancellation is exact, not asymptotic. The ideal total allocation is below one. Energies converge along every sufficiently large integer width.
* Strict-margin readout scaling preserves the finite energy gap. The Gaussian denominator contains an open parameter ball, and the displayed exponential-moment numerator bound gives the claimed posterior ratio without selecting any minimizer. A union bound proves the simultaneous sampling conclusion.

I also checked the atomic appendix against the earlier independently audited triangle lemmas, the numerical inequalities used there, the teacher and circuit complexity, and the scope qualifications. The background citation to prior triangle-wave activation use is bibliographic only and imports no prior/posterior assertion.
