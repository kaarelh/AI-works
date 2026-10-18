# Final independent audit of assembled non-Gaussian paper

Reviewed the assembled sources `paper/target-mass.tex`, `paper/above.tex`, and `paper/prior-complexity.tex`, together with their statements and posterior lemmas in `paper/paper.tex`. Also checked the precise mean-field aggregate-class and deterministic-compression statements on which the prior-complexity corollary relies.

**Verdict: no substantive mathematical error or quantifier mismatch found in these sections.** This is a conventional mathematical audit, not a Lean verification and not an independent audit of the mean-field relative-Lindeberg proof.

## Target-mass section

- Convex symmetric conditioning preserves strong log-concavity and centering. Brascamp--Lieb after linear tilts gives the stated sub-Gaussian bound. Smooth convex barriers justify the hard cylinder.
- Caffarelli contraction is used in the correct direction. Its Lipschitz constant yields precisely the displayed enlargement rate sqrt(m).
- The translation inequality applies to a centrally symmetric event that need not be convex. The score cancellation only requires simultaneous negation. Upper curvature guarantees the needed integrability and quadratic translation cost.
- Disjoint clone groups make all cylinder scalar constraints independent. The one-dimensional small-ball constant c_m=(3/8)min(1,sqrt(m)) is valid.
- The two-net calculation yields conditional failure 2(4L)^(-N)<=1/(2L). Its intersection with the cylinder is centrally symmetric, so the translation argument remains applicable.
- The stability recurrence uses the full operator-norm bound on Z. Therefore its coefficient sqrt(2) C^2+b_{m,L}, without an additional rho sqrt(C), is correct. The displayed rho makes the output error strictly less than 1/2.
- The standardized clone norm is exactly N^gamma times its weighted energy. The stated B0 is a valid upper bound, with slack in its readout constant.
- The resulting target-mass exponent is polynomially majorized in d,C at fixed depth and fixed coordinate law, uniform over every gamma>=1 and N>=C. No hidden O(N^2) density-normalization loss occurs.

## Gamma>1 section

- The net probability at 8 sigma sqrt(N/m) is below 1/2 for every positive integer N.
- The Frobenius distance to the operator-norm ball is the stated singular-value soft-threshold sum. Hard truncation above a is bounded by twice this distance, giving the exponent mK/(8 sigma^2).
- The square-exponential moment and the sufficient condition m u>=8D0 are valid.
- The two width thresholds imply all required first-layer, output, and internal-matrix tail hypotheses. The aggregate union has L terms.
- Spectral truncation produces output error at most 1/8; doubling the readout gives a strict-margin implementation with weighted energy at most (L+3)K.
- The large-width prior ratio is at most epsilon/6. The relevant class contains the target, including in cases with multiple implementations.
- The small-width target-mass argument covers every remaining N>=C. The threshold, including T^gamma, has a polynomial majorant at each fixed gamma>1.
- Taking a=tau=epsilon/6 gives Gibbs risk <=epsilon/3. The confidence bound then gives F_{2/3}<=epsilon, exactly as stated in the main theorem. No inappropriate posterior-mean or selected-minimizer substitution occurs.

## Prior-complexity corollary

- At gamma>1, the spectral structural tail at a budget polynomial in the raw function mass cost yields a bounded-energy implementation; deterministic compression supplies bounded width and bounded weights.
- At gamma=1, the mean-field aggregate class can and should be chosen to consist of the sign functions with the bounded-width, bounded-weight, margin-at-least-3/4 implementations produced by its constructive proof. With this choice, membership supplies the claimed circuit-complexity bound. The existing text permits precisely this choice.
- At sub-threshold widths, the displayed value of u in the coordinate-square tail gives exp(-bN^gamma-1), strictly smaller than the function mass. The resulting energy bound is polynomial because the width threshold is polynomial in d,1+b.
- Global-margin conditioning multiplies all function probabilities by the same factor, so raw mass preserves function ordering at a fixed width and exponent. The corollary appropriately claims polynomial comparison rather than exact pairwise ordering.

No change is required for correctness in the reviewed sections. An optional expository improvement would define the mean-field class explicitly as the family of bounded-implementation functions just described, making its use in the prior-complexity corollary immediate.
