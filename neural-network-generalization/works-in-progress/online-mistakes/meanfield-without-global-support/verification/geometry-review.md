# Independent audit: mean-field online learning without initial global-margin conditioning

Reviewed 6 November 2026 by the geometry agent. The complete research note was independently checked. No mathematical issue found. This is an AI mathematical audit, not Lean verification.

- The finite-cube Gaussian-ridge feature span is full: an invertible step-function matrix is approached by finite-steepness tanh features, and the Gaussian input law has positive mass around every required feature. Thus the feature covariance G is positive definite.
- Integrating the Gaussian readout gives an everywhere-finite smooth cumulant function. Its quadratic lower bound and positive-definite Hessian justify the globally defined Legendre transform, unique finite tilts, positive-definite rate Hessian, and coercivity.
- Cramer large deviations apply to the complete output vector. Strict training conditioning has the same rate infimum as its closure because a strict feasible teacher exists. Uniqueness and coercivity give conditional concentration at the KL projection.
- The entropy identity, convex first-order projection inequality, readout second-moment entropy bound, and unnormalized Hellinger inequality give the stated per-bad-round increment and exact constant 16.
- The Gaussian-mixture teacher has strict signed mean above 3/4, the displayed polynomial KL bound, and no extra log C term by convexity of KL.
- Finitely many target-consistent histories justify a common large-width threshold for all input orders. Adaptive fresh posterior draws obey the same conditional good-round bound. The sampling expectation and high-probability floor(R_0) conclusions follow from a union bound.
- The theorem is for the canonical shallow gamma=1 prior at fixed positive tau. Removing initial full-cube absolute-margin conditioning is a substantive change; no uniform subsequent tau-to-zero limit is claimed. The statement and proof preserve both qualifications.

Audited source SHA-256: `5aa686504ed3153bf695b4bbb5ed2b0578876fc623512cca45f5f598f36096bc`.

## Integrated manuscript correspondence check

The complete final six-page manuscript source was independently read after preparation. It matches the audited research note. In particular, the displayed canonical variances correspond exactly to sigma_N=tau/sqrt(N); the large-width limit is at fixed tau; and the theorem quantifies a common sufficiently large width over every target-consistent history and adaptive order. The explicit polynomial corollary is valid: at fixed B,tau, the logarithmic covariance term is O(d(1+log C)), so K_T=O(d²+C²) and the mistake bound is O(d⁴+C⁴). The bounded-feature extension is appropriately qualified, and no ReLU extension is claimed. No source correction was requested.

Final integrated snapshots:

- `source/paper.tex`: `5c707e6a545f287cb0739e6b0dc5dfb9ba6d74c02639ff7ebfcd45bbecb8fc91`
- `paper.pdf`: `7b7bb942087705c6c93e8078c20980bd8ca89b33b3ef85f2b81dee1b6a81ca27`
