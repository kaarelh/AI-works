# Independent mathematical review

Reviewed on 6 November 2026 by a separate AI research agent (`wide_gelu`). This is an informal mathematical audit, not a Lean formalization.

The complete assembled manuscript was checked against these source snapshots:

- `source/paper.tex`: SHA256 `b26f6794205abf24ac0a64d94cf526ee7a3426970a3b954f0f2f0a71f98b9d7d`.
- `source/volume.tex`: SHA256 `b4fc6eb63be11c0280a9d22eea83668946b65645c4028413e3b193081a05f7af`.

The review found no mathematical gap in the stated theorem. The scope is a **fixed discontinuous sign activation**, one hidden layer, the full Boolean cube, an appended constant coordinate, exactly isotropic independent Gaussian first-layer coefficients, global absolute margin greater than one half, and exact-label conditioning. Ordinary tanh, ReLU, and GELU are explicitly left open.

## Statement and proof correspondence

The construction has dimension `d=167k+1617` and a single fixed input permutation. Its calibration prefix contains `2^(d-1)+2` examples. It then queries exactly `2^k-2` distinct negative inputs. Every sufficiently large width has arbitrarily high posterior wrong-label probability on all those designated rounds, for every fixed `gamma>1` and positive prefactor. The gamma-one extension requires a sufficiently small fixed prefactor. These quantifiers match the proof; no claim at every width above the teacher width is made.

The canonical target is one affine threshold function. Positive homogeneous rescaling gives a width-one, weight-at-most-one sign teacher with output margin one. The separate linear-size Boolean circuit construction is valid: helper counting, a constant number of dyadic register sums, fixed shifts/subtractions, and the branch selector require `O(k)` bounded-fan-in gates. All base inputs are essential through the AND branch, giving the matching linear lower bound.

## Checked components

1. **All network competitors are included.** The finite-width Gaussian-tail inequality bounds the mass of every Boolean output function, including non-threshold outputs of a wide network. The correlation averaging argument, Gaussian tail ratio, binomial hidden-column averaging, and the exact aligned-column lower bound are correct. This proves the cold posterior proportional to the Gaussian cone probability raised to the width, as well as the direct fixed-exponent limit.
2. **Gamma-one qualification.** The competitor-base inequality permits one sufficiently small positive prefactor across the finitely many designated histories. It does not justify the unit-prefactor gamma-one case, which the manuscript correctly excludes.
3. **Arithmetic calibration.** The logical-coordinate signs, within-level comparisons, doubling recurrence, superincreasing estimate, and the explicit binary subset-sum error all follow from the specified exact labels. Coarse bounds on the bias and pair differences are valid.
4. **Helper geometry.** The pair-mean comparison bounds all centered helper deviations. The comparison between one negative total-helper-sum-zero example and a positive total-helper-sum-two example gives the exact inequality `h_l>R`. The calibration cone decomposes as an exact common-mode ray, because every nonzero-total-helper label has the sign of that total. Its lower threshold and centered quadratic cost obey the stated bounds.
5. **Entire Gaussian cells.** Both endpoint labels are present, so all compatible threshold functions are precisely the finite cutoff functions. Off-face labels follow automatically from the helper inequality. The volume calculation therefore integrates complete function cones, not selected subsets of representations.
6. **Radial and common-mode integration.** The dimension, Jacobian exponent, Gaussian quadratic form, common-mode tail estimate, differentiation, and uniform logarithmic-slope bound are correct. The adjacent-interval calculation proves the quantitative cone ratio stated in the manuscript. The explicit choice of precision parameter satisfies its required inequalities.
7. **Online conclusions.** The surviving maximum-cone function is unique and predicts the next designated label incorrectly. The geometric-series calculation bounds the total competing posterior mass. The finite-horizon union bound for sampled predictions does not require prediction independence.
8. **IID comparison.** The hyperplane-region count bounds the number of affine threshold truth tables. The sample bound gives error at most `epsilon/4` for every consistent threshold function. The non-threshold posterior bound is uniform over target-consistent histories and tends to zero in the claimed regimes. Combining this with the majority-versus-posterior-average inequality gives the stated `epsilon` risk guarantee.

## Limits that remain explicit

The calibration is exponentially long. The cold-posterior width threshold is exponential times a polynomial; the direct fixed-exponent theorem has additional dimension-sensitive requirements. The proof supplies existence of a threshold valid at every greater width, rather than a practical-width guarantee. It does not replace the sign activation by a smooth approximation uniformly in width or prior scale. None of these qualifications is hidden by the formal theorem statement.
