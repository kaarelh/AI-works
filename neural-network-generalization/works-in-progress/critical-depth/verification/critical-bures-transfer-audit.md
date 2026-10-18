# Independent audit: stable transfer of covariance controls

Auditor: `depth_counter_audit`. Date: 2026-10-18.

Reviewed frozen source: `source/critical-bures-transfer.tex`.
SHA-256: `c983bd79d8902b6e13ed3225b0e6714254afe0c8ae6992bbe37f960fd88ca887`.

**Verdict: all definitions, statements and proofs pass.** No mathematical correction requested. This is an independent mathematical review, not Lean verification.

## Metrics and second moments

The feasible Gaussian cross-covariance set is closed and bounded, so each stated optimum is attained, including singular marginals. Gaussian conditional gluing produces a joint Gaussian triple and proves the triangle inequality for the maximum-coordinate metric by coordinatewise Minkowski. The weighted distance is a metric for positive weights and a pseudometric if some weights vanish. A possibly noncentered joint law has a positive semidefinite uncentered second-moment block; using that block as a centered Gaussian covariance proves both second-moment coupling inequalities exactly.

## One controlled step

Multiplying an optimal reference joint coupling by the first-marginal likelihood ratio preserves the intended controlled first marginal. Its joint KL is exactly the original marginal KL, and its other marginal has no larger KL by data processing. Whitening injectively on the reference Gaussian support preserves this KL, even for singular covariances.

Gaussian quadratic transport on that support provides one common coupling of the tilted whitened variable and a standard Gaussian. Minkowski followed by the operator/Frobenius inequality gives the weighted expansion factor `1 + sqrt(2D)`. For the maximum-coordinate metric the same whitened coupling is used for every scalar difference row. Each row's operator norm equals its Euclidean norm, so the same factor holds simultaneously at every coordinate; no dimension or cardinality factor is introduced. Coordinatewise tanh contraction and the second-moment lemma complete the result. Zero distance and zero-rank support are harmless limiting or degenerate cases.

The controlled density is allowed to change with the reference covariance, as stated. Fixing the old density formula would be a different assertion not established here.

## Free blocks and covariance-entry continuity

At zero KL the transferred law is exactly the reference Gaussian, so iterating the one-step theorem gives free nonexpansion. For two-dimensional covariances, the common upper covariance obtained from the positive and negative parts of their difference gives Bures distance squared at most twice the nuclear norm of the difference. In fixed dimension this is bounded by a universal multiple of the largest entrywise difference. After one tanh step all diagonal second moments are at most one; Cauchy--Schwarz under an output Gaussian coupling bounds the difference of any covariance entry by twice its unweighted Bures distance. This proves the claimed depth-independent one-half-Holder bound.

## Complete paths

Each successive feature law can be lifted by coordinatewise atanh without changing KL. Induction therefore transfers the entire path with no increase in any individual hidden entropy cost. The multiplicative bound and its exponential estimate follow directly.

I also read the dependency `critical-square-root-entropy.tex`, through its square-root entropy lemma. The full vector entropy prefix bound, last-exit dyadic blocks, initial low-variance prefix, and terminal high-variance suffix justify `sum sqrt(D_j) <= C(log(H+2) + sqrt(H epsilon))`. Substitution yields exactly the displayed polynomial times exponential factor. The final introduction now correctly states that the overall factor is polynomial in depth in the regime `H epsilon = O(log^2(H+2))`; it does not assert this for arbitrary fixed positive excess.

## Readout transfer and total action

With `beta = Q^+ z`, the scalar variable `Y = beta^T G` has variance `2r`, and `z = E[GY]`. Setting `z' = E[G'Y]` lies in the range of `Q'`; the singular Schur-complement or Gaussian regression inequality bounds its readout cost by `r`. Cauchy--Schwarz gives the stated weighted error or simultaneous coordinatewise error. Combining this with hidden-path transfer thus preserves or decreases total action and gives the claimed uniform output approximation. An approximation error smaller than the original signed margin preserves signs, but need not preserve the original numerical margin; the source does not claim otherwise.

## Rank limitation and scope

The Bures formula for distance from the identity is the sum of `(1 - sqrt(lambda_i))^2`; a rank-at-most-`n` covariance has at least `m-n` zero eigenvalues. Uniform normalization gives lower bound `1-n/m`. For every Gaussian coupling its maximum coordinate cost is at least its average coordinate cost, so the same lower bound holds for the square of the maximum-coordinate metric.

The source correctly distinguishes covariance-control stability from finite-rank approximation, finite network representation, product-complexity compression, and a posterior learning theorem. It transfers a path to a changed starting covariance; it does not assert that this change leaves the original neural-network prior unchanged.
