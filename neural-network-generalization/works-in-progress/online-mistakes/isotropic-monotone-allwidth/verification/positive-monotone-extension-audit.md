# Independent audit of the strictly monotone triangle-residual extension

Audit by the `positive_symmetry` research lane, 7 November 2026. Audited source: `relu/MONOTONE-TRIANGLE-CALIBRATION-GAP.md`. No substantive flaw was found. This is an AI mathematical review, not formal verification or human peer review.

The fixed activation

`psi(t)=(2t+phi(t))/3`,

where `phi` is the period-four odd triangle wave, is continuous, strictly increasing, and 1-Lipschitz: its two slopes are `1/3` and `1`. It has infinitely many kinks. This is a new activation-specific result, not a theorem for ordinary tanh or ReLU.

## Exact code norm

Every code character has degree at least three, so its Fourier coefficient annihilates the affine component of `psi`. The triangle atomic inequality therefore supplies the lower bound with all weights multiplied by `1/epsilon`, where `epsilon=1/3`.

The matching four-orientation construction is correct. Partition an odd support into three nonempty odd groups (or use the explicit balanced-column construction in the source). The four sign patterns `+++,+--,-+-,--+` preserve parity and have zero column sums. Thus their affine parts cancel, while their triangle parts all equal the same signed character. Readouts of magnitude `1/(4epsilon)=3/4` give a pure parity at cost `sqrt(|S|)/epsilon`.

## Calibration penalty for the affine component

For any representation write `F=L+epsilon T`. Let `A` be the Euclidean norm of the affine coefficient vector of `L`, let `B` be the summed triangle rounding error, and set `R=T-PT`. The following checks are decisive:

1. Each triangle atom is within L2 distance at most its rounding error of a code atom or zero. Orthogonal projection therefore gives `||R||_2<=B`, with no factor two.

2. On a calibrated logical fiber, `Y=chi_C(L+epsilon R)` has conditional mean zero. If `a=y(z)g(z)-1/2` is the averaged margin surplus, pointwise feasibility implies `Y` has one-sided deficit at most `a`, hence `a>=E(|Y| | z)/2`.

3. The flat training dual has magnitude at least two at every calibrated logical point. Dropping its magnitudes to two **before** estimating the residual gives

   `D(g)-L0 >= E[1_(z notin U)|L+epsilon R|]`.

4. For the full-cube affine function, `E L^2=A^2` and `E L^4<=3A^4`, including the bias. Interpolation gives `E|L|>=A/sqrt(3)`. Omitting a set of probability `1/16` costs at most `A/4`; the residual costs at most `epsilon B`. Thus the surplus is at least `eta A-epsilon B`, with `eta=1/sqrt(3)-1/4`.

Putting `b=epsilon B` and `E'=epsilon V-sqrt(c)L0`, the two lower bounds are

`E'>=kappa b`,

`E'>=sqrt(c)(eta A-b)+kappa b`.

A convex combination with weight `kappa/((1+eta)sqrt(c))` on the second bound yields

`E'>=kappa eta/(1+eta) (A+b)`.

This avoids any assumption that one of the two terms is separately large.

## Non-code exclusion and teacher

The earlier fiber Lipschitz and core-mean arguments apply with residual size `A+epsilon B`. Any globally margin-valid sign function outside the code family forces this quantity to be at least `1/(2sqrt(D+1))`. Since `eta/(1+eta)>1/5`, the source's additive variation penalty

`kappa/(10epsilon sqrt(D+1))`

follows for every representation and hence for its infimum. With `c>=10^8(D+1)^3`, the feasible-star excess is at most `0.15D/(D+1)` times that penalty, so the gap is strict.

The margin-one teacher

`chi_C [sum_i chi_(B_i)-(m-1)]`

uses `2m-1` unit parity terms. Four orientations per term give width `4(2m-1)`, incoming weights at most one, and readouts of magnitude `3/4`. Its sign is the required logical singleton target and every absolute margin is at least one.

The finite-width allocation and actual posterior transfer from `audit_triangle_counterexample_transfer.md` remain valid with every variation cost multiplied by `1/epsilon`. Optimal allocation mass is at most `3/(2epsilon sqrt(dc))<1`. Unboundedness of `psi` creates no issue for the direct energy lower bound, explicit finite witness, continuity/openness, or finite-dimensional Gaussian large deviations.

Two notational clarifications were sent to the author: distinguish the triangle component `T` from the parity-fiber map, and write restricted expectations with an indicator rather than notation that could mean a normalized conditional expectation.
