# Independent precision audit of the moment-floor completion

25 October 2026. Finite-N audit agent. Conventional mathematical audit; not Lean verified.

**PASS** for Sections 2–6 of `fock-moment-floor-finite-bits.md`, also read together with the scalar-oracle construction in `gaussian-fock-scalar-formulas.md`. I found no unresolved precision gap in the stated equal-diagonal, compatible-coordinate Fock setting.

Audited source SHA256: `f7542b4c69b834e74dd55663581e97890cf93ab1324c489cf1d13748231b9a55`.

The independent artificial noise has zero mean and adds at most delta times the uniform trace bound, because the sum of average coordinate second moments is bounded by that same uniform trace. Its variance floor is pointwise in the input, which is the essential property. Countably many positive-RMS coordinates cause no problem: all trace sums are nonnegative and finite, and all oracle calls use fresh independent randomness.

After internal RMS normalization, a scalar copy has coefficient plus or minus one, and the noise-injection coefficients are bounded. At a linear near-copy primitive, the two independent branch variances add; hence mean cancellation cannot invalidate inequality (5). Conditional variance of the sampled branch gives precisely the factor 1/p. Inequality (6) then bounds the expected square of the selected normalized coefficient, with no lower bound on original coordinates or sampling probabilities. The final sampled readout has the claimed exact normalized second-moment identity.

For an average of m independent floored children, the pointwise second-moment floor is at least `(gamma/m)` times the averaged child's global RMS squared. Independence across tensor factors gives inequality (8). The arbitrary Hermite coefficient cancels in the normalized tensor coefficient. No assumption about overlapping coordinate moment profiles is being silently made; the injected noise is what supplies that overlap uniformly over inputs.

The good-seed argument uses unconditioned expected call counts before intersecting the good events. This is valid even when caller types range over countably many coordinates: given the type selected by the caller, each local Bernoulli/coordinate choice is fresh and the displayed bound holds uniformly. Summing conditional bad-event probabilities over expected calls does not require a finite support bound. Every active positive-RMS product has its degree and averaging count bounded by the realized unsimplified formula size. Known zero oracle types can be removed in advance. Copy-only chains have at most the stated number of trajectory primitives; alternatively, the added noise additions charge their calls directly.

Only upper bounds on normalized coefficient magnitudes are needed for later rational rounding: tiny coefficients may be rounded toward zero. The final root RMS is at least one by the uniform signed margin and at most `sqrt(2)||v||` by the trace estimate. The resulting polynomial-size trees therefore have coefficients of magnitude at most exponential in a polynomial, with a fixed global margin on a majority of groups. The standard finite-tree sensitivity bound then permits polynomial-bit dyadic rounding. No encoding of a huge sampled coordinate index is needed after the finite tree is expanded into its scalar input leaves.

This audit does not establish that a general critical controlled trajectory admits the required Fock representation. The equal-diagonal and compatible-coordinate-map assumptions, and the polynomial resource bound on the number of primitives, remain explicit premises.
