# Independent audit

25 October 2026. Non-Gaussian compiler agent. Conventional mathematical audit, not Lean verification.

Source: `block-tilt-quantitative-factory-interface.md`, SHA-256 `967347f67dddc086e0bc6deaddf122cb0ae5d90a193c08f98b235227156618e4`.

The local polynomial-rank bounds pass. Unit-direction sampling keeps the tilted scalar oracle moment independent of the selected z. Perpendicular projections and squared-norm helpers introduce only fixed polynomial powers of rank. Relative exponential damping cancels the true-norm exponential before summing tensor degree, leaving fixed powers of the trace bound, not V_r^k. Every remaining frequency moment has fixed order. The entropy dual parameter 1/(8r) gives precisely the displayed polynomial-rank caps. Whitened block coordinates xi have normalized squared densities, so inverse covariance eigenvalues do not appear in second moments. Local common-work balancing adds only another fixed rank power.

The random-rank consequence for unreset residual traces and scalar norm increments follows from the stated exponentially weighted component entropy estimates and D_K<=C K. A common-isometry construction still must be supplied, as the note explicitly says. A simpler valid choice than the proposed common uncentered-covariance normalization is J=direct_integral J_omega, with enlarged residual Rtilde_omega=R_omega+J_omega(S_omega-I)h. This isometry has J*J=I, and its extra linear residual has HS squared norm at most 2 E D_omega. The exact embedding F -> (J*F,(I-JJ*)F) leaves a literal old-state copy. Component projections and reapplications are balanced to common work before integration, paying only another fixed rank polynomial, which the weighted Poisson estimates absorb. No component-wise expensive reset is needed.

This audit certifies the local quantitative interface; the separate mixture identity and full path closure have their own proofs.
