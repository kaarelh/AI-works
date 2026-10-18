# Final independent audit: mean-field extension and prior complexity

Audited the assembled paper sources on 18 October 2026:
`paper/meanfield.tex`, `paper/sparse-dual.tex`,
`paper/tilt-compression.tex`, `paper/prior-complexity.tex`, and the
corresponding model, theorem, and posterior statements in `paper/paper.tex`.
Also cross-checked the referenced square-moment and width-threshold formulas.
No source files were edited.

**Conclusion: no mathematical blocker found in this audit.** This is a
conventional mathematical review, not a Lean verification.

## Checks

1. **Relative Lindeberg bound.** The stated third-order polynomial
   `24G + 36G^2 + 8G^3` follows from the displayed directional derivative
   bounds. The Taylor remainder has coefficient `1/6`. Conditioning on
   the removed-coordinate residual and using the local partition value
   gives the stated relative lower bound `e^{-1}` when `N >= 4G^2`.
   Summing logarithmic replacement errors proves precisely the stated
   `c_nu P(G)/sqrt(N)` bound, without an exponential tilt-budget loss or
   dependence on field dimension. Symmetry is not needed for this lemma.

2. **Certificate transfer.** The sign of the log-partition comparison in
   the certificate-transfer inequality is correct. The empirical law is
   first compared with its actual conditional product-row law; Gaussian
   replacement then concerns only the dual reference log partition.
   The proof never assumes that a non-Gaussian row law is determined by
   its covariance. First-layer sampling correctly retains the true law.

3. **Sparse dual.** The bounded-dual lift identity follows from the
   first-order condition on the closed l1 ball. The sparse approximation
   has Hoeffding error `G^2/(2q)` and at most `(2D+1)^q` points. With
   `q = ceil(G^2/2)`, the error is at most one. Conditional application
   is valid for singular and arbitrary empirical covariance matrices.

4. **Likely event.** The width threshold enforces the sparse-net tail,
   the Lindeberg hypothesis, and Lindeberg error at most one. Readout
   concentration is valid for `K >= 4 log(2)/m`. A union bound over the
   `L-1` hidden layers and readout gives the stated `L exp(-cNK)` bound.
   The first layer needs no Lindeberg comparison.

5. **Covariance propagation and margins.** Backward budgets obey
   `G_l = G_r product_{j>l} b_j`. Therefore the summed local errors are
   exactly at most `1/[32(K+1)]`. Multiplication by a dual vector of
   l1 norm at most `2K` costs at most `1/16` in output. Doubling gives
   margin at least `7/8`; finite realization loses at most `1/8`, leaving
   `3/4`. This is strictly above the required `1/2`.

6. **Finite realization.** The covariance Lipschitz constant
   `8(1+G)^2` follows from the normalized differentiation formula.
   Hoeffding over `2^{2d}` entries costs only a factor linear in `d`
   inside the required width. The first-layer tilted product law and
   subsequent Gaussian tilted row laws realize the stated hybrid tower.
   Auxiliary Gaussian sampling changes no learner distribution. The
   square-moment bound prices all sampled coordinate maxima by a
   polynomial bound. The sample width, entrywise weight bound, and
   logarithmic grid count are polynomial in `d,K,G` at fixed depth.

7. **Small widths and learning.** For widths below the polynomial
   cutoff, the raw target-mass lower bound also lower-bounds normalized
   target prior mass. The elementary target-mass posterior lemma covers
   every remaining width at least clean target complexity. For large
   widths, the outside-class/target mass ratio is at most `epsilon/6`,
   so the finite-class posterior lemma gives Gibbs risk at most
   `epsilon/3`. The confidence inequality gives the announced result
   for the actual posterior, including mixtures.

8. **Prior-complexity corollary.** Above the respective cutoff, a
   function whose raw mass exceeds the total bad-event mass must have a
   compressed implementation. Below the cutoff, the standardized square
   tail ensures an implementing draw with polynomial energy. The formula
   `S = N^gamma kappa_N(w)` and the chosen square-tail threshold are
   correct. Padding the finite realization can increase its width to
   dominate its weight bound without changing the function.

## Optional prose clarification

The scope paragraph says the theorems do not settle which laws retain
the "same ordering of functions by prior probability." Since the new
prior-complexity corollary proves a polynomial comparison, writing
"the same exact ordering" would make the remaining limitation clearer.
This is a wording issue, not a mathematical defect.
