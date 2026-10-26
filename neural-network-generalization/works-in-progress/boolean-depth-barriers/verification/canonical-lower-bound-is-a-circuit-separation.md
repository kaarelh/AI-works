# Why a canonical depth lower bound would itself separate circuit classes

26 October 2026. A fresh check of the implication, including narrow learner widths. This is a logical consequence of the existing positive target-learning theorem, not merely a limitation of a proposed lower-bound proof method.

Fix the original Gaussian tanh learner: Boolean inputs, a common prefactor `0<t<=1`, global absolute output margin greater than one half, and exact noiseless training labels. Fix accuracy and confidence tolerances in `(0,1)`. Suppose a target sequence with learner depths `L_j -> infinity` has tanh teachers at those same depths, widths `C_j`, weight magnitude bounds `B_j`, and global signed margins greater than one half. Assume

`d_j+C_j+log(2+B_j) <= L_j^b`

for a fixed exponent b. An `exp(c L_j^alpha)` sample lower bound, for any fixed positive c and alpha, at actual realizable widths and canonical scales would imply

`P/poly != nonuniform NC`.

## The contradiction if the family were in NC

1. **Put the targets in P/poly.** Exact sample consistency gives the universal finite-domain sample upper O(2^d) at fixed tolerances. Therefore the hypothesized lower forces `d_j=Omega(L_j^alpha)` and `L_j=O(d_j^(1/alpha))`. The saturation-aware finite-description lemma compiles each teacher using a number of Boolean gates polynomial in `d_j+C_j+L_j+log(2+B_j)`, hence polynomial in `d_j`. Take a strictly increasing dimension subsequence and define constant functions at the other dimensions. This is a family in P/poly. Its original real weights need not be computable.

2. **Use a hypothetical alternative NC representation.** If this family were in nonuniform NC, one fixed exponent k and one fixed polynomial size bound would give Boolean implementations of depth `h_j=O(log^k d_j)` and size polynomial in `d_j`. Since also `d_j<=L_j^b`, the alternative circuit has resources polynomial in `L_j` and depth `O(log^k L_j)`.

3. **Keep the actual learner architecture.** The established uniform target theorem gives sample threshold `exp(O(h_j log R_j))` at learner depth L_j whenever `L_j>=C(h_j+1)log R_j`, with R_j polynomial in L_j. This padding condition eventually holds. No larger learner depth is selected. The sample threshold is `exp(O(log^(k+1)L_j))`, smaller than `exp(cL_j^alpha)`.

4. **A narrow learner does not evade this upper.** The target theorem holds at *every realizable width*, even when the alternative NC circuit itself does not fit at that width. Above `exp(C h_j log R_j)` the Gaussian circuit-seed construction applies. Below that threshold, the complete class of networks at the given finite width and depth has a VC bound at most `exp(O(h_j log R_j))`, and realizable consistency controls every posterior-supported function. The only required realizability is that of the target at the actual learner width; it can be witnessed by any representation. No condition that the learner width exceed B_j or the alternative circuit width is introduced.

5. **Keep the same distribution and scale.** This positive theorem is distribution-free and uniform over all `0<t<=1`. It therefore applies at the exact width, prefactor, and input law of any purported lower-bound instance. Its statement holds for every sample count above its sufficient threshold, so the contradiction does not assume pointwise monotonicity of posterior accuracy as sample size grows.

Thus the selected target family cannot be in NC, while Step 1 puts it in P/poly. The separation follows regardless of whether the proposed lower-bound proof uses any circuit methods.

The quantifier burden is weaker here than in the converse from universal polynomial learning. For this negative implication, the positive theorem already holds separately for every width, scale, and input distribution; an adversary may jointly choose its hard instance. The width-before-distribution convention of the two-majority converse is not needed to rescue the argument.

## Suggested reader-facing wording

“A stretched-exponential lower bound for the original canonical tanh learner, with teacher width and coefficient bit length polynomial in depth, would establish a major circuit-complexity separation: P/poly would differ from nonuniform NC. This is an implication of our positive learning theorem, not just an obstacle to one proof approach. If the targets had polynomial-size, polylogarithmic-depth Boolean circuits, that theorem would learn them with only `exp(polylog L)` samples at the same learner depth and every realizable width—even when the alternative circuit is too wide to fit in the learner. The separation is not known to be impossible; it explains how strong the proposed lower bound would be.”

The assertion does not apply to the `t>1` counterexamples, continuous domains, a changed conditioning rule, superpolynomial teacher-description resources, or an activation that lacks a polynomial-size numerical evaluator. Those are changes to the premises, not counterexamples to the implication.
