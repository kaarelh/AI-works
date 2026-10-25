# Independent audit of the majority-threshold note

25 October 2026. Conventional mathematical audit, not Lean verification.

**Pass**, after the harmless explicit restriction `d>=2` was added to the affine-parity counterexample. At `d=1` every Boolean truth table is affine parity, so the claimed largest-to-smallest ratio would be one rather than exactly `1+rho`; the substantive counterexample uses arbitrarily large d and is unaffected.

The uniform truth-table component assigns equal mass to either label at any unseen input after a consistent sample. The only posterior majority bias is therefore the additional affine-parity component. Its tiny overall mass cancels when taking the sign. Once the augmented sample matrix has full rank, a realizable affine parity is uniquely determined. The stated rank failure bound follows by a union bound over nonzero affine forms; the constant-one form has zero failure probability, and every other nonzero affine form vanishes on a uniform observation with probability one half. The cube permutation, bit-flip and global-label symmetries preserve the affine family.

For r independent posterior draws, the pointwise correctness indicators are iid Bernoulli. Additivity of KL, `KL<=chi_squared=4u^2`, and Pinsker give exactly `TV<=sqrt(2r)|u|`. Fair tie breaking makes the reference fair-coin majority correct with probability one half, for both even and odd r. With `|u|<=rho/4`, the displayed error lower bound and the example constant `1/8` follow. Independence across test inputs is unnecessary: expectation and a pointwise bound suffice.

The note correctly distinguishes finite posterior-vote ensembles from exact posterior-majority access, and neither statement proves a majority lower bound for the actual neural prior. No additional correction was needed.
