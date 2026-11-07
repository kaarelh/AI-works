# Independent audit of the strictly monotone extension

Reviewed on 7 November 2026 by the `tanh_nonlinear` research agent. This is an AI mathematical audit, not formal verification or external peer review.

Sources read in full:

- `../../new_lens/MONOTONE-CALIBRATION-REDUCTION.md`
- `../../relu/MONOTONE-TRIANGLE-CALIBRATION-GAP.md`

No substantive mathematical flaw was found. The activation is the fixed strictly increasing, unbounded, piecewise-linear function `psi(t)=(2t+tau(t))/3`. The result does not concern ordinary tanh.

1. All code characters have degree at least three, so the affine part has zero code projection. The triangle atomic lower bound therefore transfers with factor `1/beta`.
2. The four sign orientations have balanced columns and positive row products. The remaining support coordinates can be appended in identical balanced pairs. Their affine outputs cancel exactly, while their triangle outputs agree. Readouts of magnitude `3/4` realize a unit parity and give the correct exact variation cost `3sqrt(s)`.
3. The triangle rounding lemma supplies the claimed L2 residual. In a far case the rounded function is zero and the reduced triangle atom has L2 norm at most its reduced parameter norm. In a localized case it is within `rho` of the signed pure character. Modulo-two reduction affects only the triangle part; the argument correctly retains the original affine coefficient vector in `L`. This is essential when original parameters are large.
4. Conditional on each calibrated logical value, `Y=chi_C(L+beta R)` has mean zero. The full calibration margin bounds its negative part pointwise; hence the projected margin slack is at least half its conditional absolute mean. The normalized dual coefficient has magnitude at least two on every calibrated point, including the distinguished point. This gives the residual-slack inequality with no large adverse coefficient.
5. For an affine Rademacher form, `E L^4<=3(E L^2)^2`, including a nonzero constant term. The interpolation bound `E|L|>=A/sqrt(3)` and Cauchy--Schwarz loss at most `A/4` on the free set are valid. The residual loss is at most `beta B`.
6. The parity-fiber edge and failed-core-oddness cases give `A+beta B>=1/(2sqrt(D+1))`. The first case uses the larger edge constant `1/(2sqrt(2))`, which safely implies this bound.
7. Minimizing the maximum of the two affine excess bounds gives exactly `kappa eta K/(1+eta)`. The intersection is at `beta B=eta K/(1+eta)`; the region `beta B>=K` gives a larger bound. Since `eta/(1+eta)>1/5`, the displayed simplified penalty is safe.
8. For `c>=10^8(D+1)^3`, the ratio of the star upper excess to the simplified non-code penalty is at most `0.15D/(D+1)<1`. This excludes non-code signs before projecting unknown-label margins.
9. Subsequent integer replication preserves each orientation's total coefficient exactly, even when clone counts differ across orientations. Thus affine cancellation survives rounding at every sufficiently large width. The total desired neuron mass is bounded by `3/(2beta sqrt(dc))<1`.
10. Unbounded activation values cause no issue for the direct energy lower bound, explicit strict-margin witnesses, or the fixed-dimensional Gaussian tail argument. A bounded-activation compactness theorem is unnecessary and should not be invoked.

The assembled monotone manuscript still requires a full-source audit when available. The previous triangle audit already covers the unchanged latent weighted optimization, radical ordering, fixed query sequence, and Gaussian posterior ratio.
