# Independent audit: near-baseline critical decomposition

Auditor: `depth_counter_audit`. Date: 2026-10-18.

Reviewed frozen source: `source/critical-near-baseline-decomposition.tex`.
SHA-256: `79498d3baf3f41abd76300ecc179a98443e40ccc08d6c68985fade931da8267f`.

**Verdict: all statements and proofs pass.** No mathematical correction requested. This is an independent mathematical review, not a Lean verification.

## Dependencies checked

Read the scalar-value and signed-pair comparison results in the existing `critical-rate-foundations.tex`, together with the previous last-exit argument in `critical-rate-lower-proof.tex`. The review uses precisely their scalar Bellman inequality, monotonicity of `V`, strict quadratic dissipation, and `V_* - V(q) <= C q`. The latter extends to `(0,1]` by increasing the constant.

## Additive occupation lemma

The reciprocal telescoping inequality has the correct direction. Last exits into dyadic sublevel sets are nondecreasing. Removing the first transition of each nonempty block makes every remaining pre-state exceed the lower dyadic level; the endpoint lies between that level and twice it. Bounding each block by the complete prefix entropy is legitimate because all entropy costs are nonnegative. The initial block, removed transitions, and final tail are all accounted for. The geometric sums give `H <= C(1/m + epsilon/m^2)`, and solving the resulting quadratic gives the stated minimum-variance bound.

## Directional budget and exact scalar decomposition

For a bichromatic edge or a constant-target antipodal pair the selected signed average has input variance `1/d` and output magnitude at least `1/2`. Finite entropy propagates a zero pair variance, so every variance on a feasible path is positive. Prefix entropy is bounded by `epsilon + C_0 v_i` using the remaining scalar value; all occupation hypotheses hold.

Lifting through coordinatewise tanh preserves KL, including singular Gaussian reference laws on their support. Scalar projection and disintegration give the exact decomposition into projected KL and nonnegative conditional KL. The signed-pair contraction and monotonicity of `V` give nonnegative Bellman slacks. The terminal scalar slack is nonnegative by the zero-transition scalar path. Readout Cauchy--Schwarz on the covariance range gives the nonnegative orthogonal residual; the output margin gives the nonnegative amplitude excess. Their algebraic sum is exactly `A - V(m)`, as asserted. Empty prefixes or suffixes cause no exception.

## Anchored kernel section

The covariance-seminorm residual has cost at most `B`; coordinatewise Cauchy--Schwarz and diagonal entries at most one imply residual magnitude at most `sqrt(2B)`. Thus `B < 1/8` preserves the target sign. If `B <= 1/32`, the anchored output has margin at least `1/4`. The scaling factor is at most `4A`, yielding the section margin `1/(16A) >= 1/48`.

## Zero directional entropy

The signed-coordinate-permutation stabilizer of the selected pair preserves the initial covariance. Zero prefix entropy gives the free feature recursion. Zero conditional KL means that each later controlled law changes only the scalar anchor marginal and preserves the conditional Gaussian law; this construction preserves the stabilizer even for singular covariance. Hence the anchored section, and therefore the target, is constant on stabilizer orbits.

For an edge these orbits are indexed by one coordinate and the Hamming weight of the rest; the displayed integer code separates them. For an antipodal pair they are Hamming-weight classes. The exact ordered-step expansion has the correct constant coefficient `(f_1+f_M)/2`. Replacing separated steps by tanh at logarithmic slope gives the claimed uniform approximation. A first-layer constant feature uses the existing augmented input coordinate. Width, incoming norms, and readout norm are polynomial in `d`, independent of original depth.

## Scope

This is a variational structural result. It does not establish an unconditional product-complexity or posterior-learning theorem at small positive directional entropy. The final paragraph explicitly preserves that distinction.
