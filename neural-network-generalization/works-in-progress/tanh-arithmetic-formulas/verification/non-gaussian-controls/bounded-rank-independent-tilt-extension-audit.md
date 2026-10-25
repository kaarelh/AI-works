# Independent audit: fixed-rank independent entropy blocks

25 October 2026. Non-Gaussian compiler agent. Conventional mathematical audit, not Lean verification.

**PASS**, conditional on the already audited rank-one scalar factories and global precision theorem. Checked source SHA-256: `f9c81ad6f46923f3640c4c9282625ddf3fd364da56dd7955cca16ea9a503eaf9`.

The block reduction correctly uses a unit query direction eta_z=Az/||z||, so its conditional scalar second-moment bound is uniform in z. Projecting onto E and its complement incurs only a constant depending on the fixed block rank. The perpendicular-norm helper uses independent copies for every squared mean; no hidden higher-moment assumption is introduced.

The radial entropy caps follow from the stated exponential-moment argument in a fixed dimension. The constants may grow with rank, and the note does not claim otherwise. Relative Gaussian damping and tensor averaging remain valid with the rank-dependent trace bound.

The uncentered second-moment inequality for M is correct. Finite relative entropy makes its covariance positive definite, and Gaussian maximum entropy gives tr(M)-logdet(M)-r<=2D. The square-root HS bound follows eigenvalue by eigenvalue. The exact embedding identity is J[I+A(sqrt(M)-I)A*]h=(z*alpha,Ph), because xi=M^(-1/2)z. Thus only the small residual needs the expensive projection, and the permanent old state remains an exact coordinate copy plus the charged HS correction.

For b_l=E xi_l R0, squared-coordinate density xi_l^2 has integral one and gives second moment E R0^2. Summing over the fixed rank and applying the rank-r orthogonal projection costs a rank-dependent constant, as stated. The squared-norm linear correction can be estimated with independent alpha copies; ||M-I||HS<=C(sqrtD+D) follows from the square-root bound and its operator-norm consequence.

Small-step rare creation, large-step averaging, physical rescaling, and the fixed-dimensional polynomial/complex formula balancing therefore close exactly as in the rank-one proof, with constants depending on r0. The precision stage adds an ordinary polynomial dependence on the number of stored layers for the noise-floor bookkeeping; the final polynomial-size PNC1 conclusion is unchanged. This harmless H factor should be included when displaying a final quantitative finite-bit bound.

The extension does not cover arbitrary conditional block laws, nor rank growing with the ambient resources. The note states both exclusions explicitly.
