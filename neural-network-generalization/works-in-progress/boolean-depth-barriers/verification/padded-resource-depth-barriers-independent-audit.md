# Independent audit of complexity-only resource padding

26 October 2026. **PASS** for `padded-resource-depth-barriers.md`,
SHA256 `fa57641312abb64d98ca0652daebef72e2713deb29fc28b61dc5e7062c89eb80`.
The teacher's global positive margin is fixed as stated in the setup;
the usual original-model normalization may be taken as signed margin
greater than1/2. Statistical constants are fixed in `(0,1)`.

The finite-description lemma gives circuits of size polynomial in
`R=d+C+L+log(2+B)+4`, with universal degree. Since R>=L and L tends
to infinity, an increasing subsequence of `M=ceil R` exists. Completing
the padded family by constants at all other input lengths places it
in P/poly. Nonuniformity permits the selected coefficient descriptions
and input lengths; no computability of the original real weights is
being assumed.

The padding affects only this circuit-complexity family. Fixing the
dummy coordinates in an alternative threshold or Boolean circuit
leaves the original target on its original d inputs. The learning
theorem is then used at the actual original learner depth, width,
Gaussian scale, and distribution. No prior covariance or learning
problem is padded. The all-realizable-width version of the theorem
is essential and is explicitly used.

For fixed TC0 depth and polynomial-in-M size, the alternative target
has resource polynomial in R, so the sample upper is polynomial in R.
When `0<alpha<=1` and `logR=o(L^alpha)`, this is
`exp(o(L^alpha))`, and the long-padding condition also holds because
`logR=o(L)`. The stated short-padding fallback is valid as well.

For NC^k, the threshold depth is O(log^k R), size polynomial in R,
and the target resource exponent is O(log^(k+1) R); the log L term
is absorbed because R>=L. Under `logR=L^{o(1)}`, that exponent is
o(L) and o(L^alpha) for every fixed alpha>0. Thus both the learner
padding requirement and the contradiction to the stretched-exponential
sample lower are valid for every fixed k.

The optional ordinary-majority lower-bound formulation is also sound:
an ordinary-majority mistake lies inside the posterior-confidence-error
set, including any fixed tie convention. The stronger confidence upper
therefore contradicts such a majority lower.

Neither conclusion is an unconditional complexity separation or an
actual statistical lower. In particular `logR=o(L)` alone does not
permit arbitrarily high powers of logR in the same learner depth, so
the weaker TC0 conclusion is not silently promoted to NC.

Final editorial follow-up: the checked source now has SHA256
`6b5a02e872bb8201f0072a7348ea2ddbbd0bf73538cb47551621794cdb27b1f7`.
The only intervening changes explicitly state signed teacher margin
greater than 1/2 everywhere and statistical constants in `(0,1)`.
These are the setup conventions already checked above. PASS is unchanged.
