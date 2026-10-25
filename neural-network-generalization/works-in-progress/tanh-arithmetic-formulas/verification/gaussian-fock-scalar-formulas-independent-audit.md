# Independent audit: equal-diagonal Gaussian/Fock scalar formulas

25 October 2026. Independent check of `gaussian-fock-scalar-formulas.md`, including infinite degree, scalar formula size, repeated realizations, and the precision qualifications. The stated exact real-constant theorem passes this audit. Its stated applicability restrictions remain essential.

## Hermite and tensor calculations

Gaussian Sobolev Parseval gives `sum k(k-1)a_k(q)^2=q^2 E(tanh''(sqrt(q)Z))^2`. Since only odd k occur and `k^2<=3k(k-1)/2` for k>=3, the bound `tanh''(z)^2<=4tanh(z)^2` yields exactly `sum_(k>=3)k^2b_k(q)^2<=6q^2`. This holds for all q>0, not merely asymptotically.

For a unit mean vector and m independent averages, the trace second moment is `1+(sum_i V_i-1)/m`. Taking `m=ceil(kV)` gives its kth power at most e. For each ordered tensor word, the k averaged children must be independently drawn even when indices repeat; then the squared product moment factors. Summing all words is exactly `(sum_i W_i)^k`. Tonelli handles countably many coordinates and all degrees because every summand is nonnegative.

The rare-branch probability `p_k=min(1,q/k^2)` gives `p_k k ceil(kV)<=2qV`, so the coordinate cost is at most `1+CqVT`, uniformly over degree and coordinate word. For small q the trace increment is at most `6e q`. For large q, `1/p_k<=1+k^2/q` gives the claimed O(1+q) trace bound and polynomial reset cost.

## Independence and formula size

Unlike the residual subtraction construction, this proof does not require using a random child twice in a cancellation identity. Distinct tensor factors are independent draws. Every actually selected high-degree branch is a finite scalar tree, with all averaged copies and products charged. Its possibly enormous cost is compensated in expectation by the rare-branch probability.

An absent high-degree branch returns a literal zero. Specifying a sampled coordinate index or degree belongs to the input-independent choice of formula, not its arithmetic evaluation on x. Accordingly this is a nonuniform random-formula theorem, not an efficient algorithm for discovering or sampling the coordinate representation.

Degree-one steps only change a scalar edge weight of the existing expression. Multiplying these deterministic weights along copy chains creates no chain of new arithmetic nodes; converting the final weighted tree to ordinary arithmetic changes size only by a constant factor. These statements are valid for the fixed-variance q_j in the theorem.

## Composition and readout

The near-copy Hilbert--Schmidt row-sampling argument extends to countable coordinate spaces. The row and trace sums are nonnegative; Hilbert--Schmidt square summability supplies the exact total budget. The bounded true mean norm justifies the two-copy reset. The number of small resets is charged to S+Q, and large-step polynomial multipliers have logarithm O(S+Q). Thus the common expected coordinate cost is bounded by `C T0 exp(C(S+Q))`.

Sampling the l2 readout gives second moment at most `2||v||^2`; its mean is the intended inner product by absolute convergence. Independent group averaging, Chebyshev, a finite-input union bound, and a size Markov bound give the deterministic all-input classifier. No sum of coordinatewise suprema over x is substituted for the pointwise trace bound.

## Finite-bit scope

The exact theorem permits arbitrary real constants. The sufficient finite-bit conditions in Section 5 control every denominator that actually appears: q, rare-branch probabilities, nonzero control entries, and nonzero readout entries. A selected nonzero degree-k branch has at least k child occurrences, so accepted polynomial-size realizations have polynomially bounded active degrees. Hermite coefficients satisfy |b_k|<=1 and are never inverted. They may be extremely small; only a polynomial upper bound on coefficient logarithmic magnitude is needed for absolute-precision rounding.

The PNC1 corollary should explicitly be read for Boolean inputs, or polynomial-length bit encodings with initial arithmetic formulas over those bits. The imported arithmetic-formula evaluation/composition theorem remains an external hypothesis of that complexity-class conclusion. No new computability or uniform algorithm is established for the infinite coordinate basis.

## Remaining mathematical gap

For q=q(x), the Hermite coefficients and the normalization of the input vector become input-dependent functions. They cannot be inserted as fixed edge coefficients or fixed random branch probabilities. The present proof does not silently extend to that case, and it does not show that arbitrary canonical Gaussian control paths admit the required near-copy representation. These limitations are accurately stated in the source note.
