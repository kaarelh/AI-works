# Independent mathematical review: volume, posterior, and theorem correspondence

Reviewer: a separate ChatGPT-6 Astra research agent (`wide_tanh`).
Date: 6 November 2026.

Reviewed complete source snapshots:

- `source/paper.tex`: SHA-256 `b26f6794205abf24ac0a64d94cf526ee7a3426970a3b954f0f2f0a71f98b9d7d`.
- `source/volume.tex`: SHA-256 `b4fc6eb63be11c0280a9d22eea83668946b65645c4028413e3b193081a05f7af`.

The full source and extracted PDF text were read. No mathematical error was found. This is an AI-agent mathematical review, not a Lean verification.

## Scope and quantifiers checked

The theorem concerns one hidden layer with the fixed discontinuous sign activation, the full Boolean cube, a constant input coordinate, independent identically distributed coordinates within the first-layer Gaussian, the stated standard width-dependent readout variance, global strict absolute output margin greater than one half, and exact observed labels. It does not claim ordinary tanh, ReLU, GELU, all widths above teacher width, a short calibration prefix, or a polynomial width threshold in the direct prescribed-exponent limit.

The fixed input permutation has exactly `2^(d-1)+2` calibration points followed by `2^k-2` designated points. The two query-face endpoints are part of the calibration and are not counted again as designated mistakes. The target and permutation are independent of learner width. The direct statement holds for every fixed gamma greater than one and every fixed positive variance prefactor; gamma equal to one requires a sufficiently small fixed prefactor depending on the finite construction.

## Posterior argument checked

For every Boolean output function, the correlation-vector argument bounds all hidden truth-table configurations, including those not aligned with the proposed output and outputs that are not threshold functions. If t columns are unaligned, the squared correlation norm is at most `N-c_d*t`. Averaging the global-margin inequalities and applying the Gaussian-tail ratio gives the conditional suppression factor `exp(-c_d*t/(8*N*sigma^2))`. Binomial summation yields the two-sided finite-width mass inequality in the paper. The aligned lower bound uses the exact scalar Gaussian tail, not a rate-only estimate.

At fixed width the inequality yields the cold posterior proportional to the Nth power of the full Gaussian threshold-cone probabilities. For fixed gamma greater than one, `N*delta_N` tends to zero, and all nonthreshold competitors vanish after comparison with a surviving threshold function. For gamma equal to one, the displayed strict comparison of upper and lower exponential bases suffices after choosing the prefactor small enough. Finiteness of the cube and the collection of histories is used explicitly; no uniform-in-dimension assertion is needed.

## Scaffold and whole-cone volume argument checked

The four-register addition table implies positivity and same-level coefficient agreement, the approximate doubling recurrence, and exponential precision of the selected high bits. The strict numerical-order inequalities for the C and D registers supply the lower bound on the high reference coefficient. The coarse coefficient and bias bounds are valid with the stated constants.

Balanced helper assignments bound the differences of pair means; the paired negative/positive examples force every actual helper coefficient to exceed the complete main-coordinate range. The exact representation cone decomposes into the balanced-label cone and one unbounded positive common-mode ray. Its lower threshold and residual quadratic form satisfy the stated polynomial bounds. The large common direction is integrated out rather than assumed bounded.

The full first-branch calibration plus the two query-face endpoint labels leaves exactly the finite list of cutoff truth tables. All off-face labels follow automatically. Consequently the cone calculation is for the entire parameter set representing each surviving threshold function; it does not select a favorable subset of representations.

The isotropic Gaussian change of variables gives variance two for each branch bias, the radial Jacobian `a^D`, and density exponent `(D+1)/2`. Integrating the common helper mode and bounding its upper tail gives the uniform logarithmic slope. Nearly equal adjacent intervals then give the quantitative neighboring cone ratio at least `1+ell/4`. The constants and precision choice `p=20k+200` satisfy the required epsilon inequalities, including the stronger `epsilon<ell/32` used for the quantitative ratio.

## Complexity and IID comparison checked

The canonical target is an affine threshold function and admits the claimed width-one, weight-bounded sign teacher by positive first-layer rescaling. The Boolean circuit can be implemented with linear-size carry-save arithmetic: the helper common coefficient is `2^(L+2)-3`, and the remaining dyadic terms have only a constant number of source bits per level. Essentiality through the AND branch gives the matching linear lower bound for bounded-fan-in circuits.

The IID theorem uses a finite threshold-class counting bound, a realizable consistency union bound, and a uniform bound on total nonthreshold posterior mass obtained from the same finite-scale inequality. Its majority-error conversion and uniformity over training samples and input distributions are valid. This comparison is about sample complexity; it does not assert a polynomial learner-width threshold or efficient posterior computation.

## Final wording update

The author applied the sole requested clarification: after Theorem 1, the width threshold now explicitly depends on `k, gamma, tau` and the required error allowance. An obsolete insertion comment was also removed. These are the only changes from the reviewed initial source snapshot, and the final hash above incorporates them. No theorem or proof changed.
