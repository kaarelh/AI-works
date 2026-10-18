# Independent audit of the exact Boolean feature repair

Auditor: the critical-depth research agent, independently of the memorization agent who constructed the repair. Date: 2026-10-18.

I checked `exact-feature-repair.md` and the complete assembled TeX at `source/exact-feature-repair.tex`, SHA-256 `3253ed46ad4d1c421edd4c097d3d24c1f568dc659daea11de1d44a3167a224e0`.

The local lemma is valid as stated. Its reference covariance may be singular: the covariance domination places every used mean shift in its range, and the Gaussian shift entropy is bounded by the coefficient norm squared divided by twice the tracked state coefficient. The scalar Gaussian variance is common at every input, so all controlled first and second moments depend only on the Boolean state.

The Gaussian saturation estimate is uniform at variance at most two. Precision epsilon proportional to the inverse number of realized states requires a shift amplitude only linear in state width. The near-identity matrix of signed point detectors is invertible in the infinity operator norm. Solving this system and mixing output-negated laws realizes the exact gate mean while keeping all mixture weights nonnegative and all diagonal second moments between 1-epsilon and one.

For the second repair, the constant-shift diagonal dominates every point-zero diagonal. Thus its matrix is c times the identity plus a nonnegative off-diagonal matrix with small infinity norm. The stated Neumann estimate does imply that the solution weights are individually positive, not merely bounded in norm. Their total fits inside the reserved mixture mass. The final diagonal is exactly the same scalar at every state, the mean amplitude is at least one half, and both scalars can be chosen independently of the gate.

The number of mixture components can be exponential in the state width; this creates no entropy penalty because every component has polynomial Gaussian shift entropy and relative entropy is convex. The individual repair weights are exponentially small; their total mass is a small constant, not exponentially small.

The constant-coordinate and one-realized-state cases are covered by the construction. For bounded-fan-in gates the lemma may be applied only to the gate's input coordinates and the constant rail. That gives universal local shift cost for a fixed gate library. The resulting gate laws need not share the same scalar diagonal value: their mixture still has a diagonal constant over inputs.

No substantive mathematical gap was found. This is an AI-agent mathematical audit, not Lean verification. The audit verifies a prior-rate construction and does not certify a sample-complexity theorem.
