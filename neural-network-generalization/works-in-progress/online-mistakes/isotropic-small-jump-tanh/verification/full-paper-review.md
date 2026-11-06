# Integrated mathematical and theorem-correspondence review

Date: 2026-11-06.

Verdict: **PASS** for the frozen sources below. The result applies to the
fixed discontinuous activation `tanh(t)+epsilon sign(t)`, for every fixed
epsilon>0. It does not establish the corresponding claim for ordinary
tanh or any continuous activation.

This reviewer independently checked the energy dual, relaxed-measure gap,
Gaussian posterior comparison, compression lemma, IID theorem, and all
main-theorem interfaces. The reviewer authored the compressed-selector
source; that component has a separate independent hash-specific audit in
`selector-review.md`. Thus independent coverage of the selector does not
rest on its author's own review.

## Frozen artifacts

| Artifact | SHA256 |
|---|---|
| `source/paper.tex` | `85eee6fbf46bb436ecb7e4fa36e93fe0224154aa6677aee55ee64b9f78c8152c` |
| `source/dual.tex` | `0fda467e8b96367423c4f416917c92c9d49da5f69800ba26aaedda7b235a44f9` |
| `source/posterior.tex` | `11f9e353accec015474381fa1787b4deeb494edd871ae8c519aacc8d61325460` |
| `source/selector.tex` | `950940054310fdd20ed708be74571280af0a363171a1ef29998d466f6b774638` |
| `source/compression.tex` | `ed85129384d15c5c4e85f713261cef8a4dee54ec0448a850a09330170ef7b79d` |
| `paper.pdf` | `a4223ce606586306d044f19629368fcdab83e6e7cc1c30a11a2eaa0d22cbe15d` |

The PDF is the author's clean 12-page build. This mathematical review is
based on the frozen sources; the build/visual record is separate.

## Exact-profile theorem

The scalar objective has a unique strictly positive minimizing radius.
The stationarity equation, tangent coefficients, quadratic-floor leading
coefficient, and floor value all check. The active KKT covariance identity
gives exactly the displayed mean and variance of the neuron score.
Taylor's theorem is applicable with `sup |tanh''|<1`; the jump term is
used only through its absolute bound epsilon.

Both parameter ranges are covered: `0<epsilon<=1` with
`d>=4 epsilon^(-6)`, and `epsilon>=1` with `d>=4`. The large-norm cutoff
and the two small-norm corrections leave an orthogonal coefficient at
least `31d/64`. No extra Q>=1 hypothesis is needed, since an augmented
Boolean unit-margin constraint implies `dQ>=d/(d+1)>=1/2`.

All atomwise inequalities integrate over arbitrary finite-energy neuron
probability laws. Equality forces incoming vectors `+/-r a` and matching
readout signs, so all atoms contribute the same scalar output. The
strictly positive radius proves strict monotonicity in Q and places the
profile below `1/(4 epsilon^2)`.

## Width-uniform gap and activation discontinuities

The relaxed neuron graph is closed: at a nonzero limiting preactivation,
the sign is eventually fixed; at zero, the permitted interval is compact.
Bounded mean energy gives tightness of the incoming and readout parameters.
Output integrands have magnitude at most `(1+epsilon)|b|`, so their means
converge under weak limits by truncation and uniform integrability from
the bounded second moment of b. The relaxed constrained minimum is
therefore attained.

The dual proof remains valid at zero preactivations even though relaxed
jump values need not obey oddness: only their absolute bound is used.
Equality, however, puts every atom at `+/-r a`, and the selector witness
has no zero full-cube scores. Its jump values are then forced. The
minimizing scalar function predicts the wrong designated label, which
gives a strict gap to the correct-label relaxed class. This gap is
uniform in hidden width.

This addresses the important intermediate-history issue. At the first
query in a block, its antipodal label has not yet been observed. The proof
uses uniqueness at the preceding completed history, not a nonexistent
covariance certificate for that incomplete next history.

## Actual Gaussian posterior and quantifiers

Under the normalized row coordinates `(sqrt(d)u,b)` with `b=Nv`, the rows
are independent Gaussians of covariance `N sigma^2 I`, and the canonical
energy is their average squared norm. A slight readout amplification and
a fixed small row box give strict full-cube margins while staying below
the competing energy. The product-box denominator and chi-square upper
tail have the displayed constants. Their logarithmic variance terms
cancel exactly, leaving

    exp[-Delta/(2 sigma^2)+C N].

This tends to zero at each fixed width in the cold limit, and under
`sigma_N^2=tau^2 N^(-gamma)` for every fixed gamma>1 and tau>0 as width
increases. The displayed two inequalities on tau also imply the tail
condition and a prescribed error bound simultaneously for every N>=1
and gamma>=1. Taking common constants over the finite designated list
is legitimate. The sampling union bound does not require independence.
Posterior-majority and strict 2/3-confidence conclusions follow from the
same actual posterior probabilities.

The original coordinate-isotropic variances are preserved, including
the appended constant. The activation is the explicit changed component.

## Selector and teacher interfaces

The independent selector review checks the pairwise-independent support,
positive KKT weights, covariance entries, Schur complement, disjointness,
counts, fixed input order, circuit size, and teacher. Its final source
hash matches this review. The initial count is at most `2k^2+6k+2`; every
query block has at most 4k examples; the number of designated first-query
errors is `2^k-k-1`. Remaining inputs are appended to form a permutation
of the full cube.

The same-depth teacher has width `ceil(1/epsilon)`, all weights at most
one, and signed output strictly greater than one. Thus the all-width
claim includes every width at least the teacher complexity. The Boolean
target has size Theta(k), and the learner need not be odd.

## Energy compression and IID theorem

For a bounded nondecreasing activation, random upper level sets of each
neuron are affine threshold truth tables. On the finite cube, almost every
random level avoids all activation values, so the resulting table can be
realized by a strict affine threshold even at jumps. Negating the table
for a negative readout preserves that class. Cauchy--Schwarz gives the
readout variation bound `B^2<=E`.

The Hoeffding exponent, full-cube union bound, and choice of m_* give a
uniform approximation error below 1/8 with positive probability. The
full margin then yields an unweighted threshold majority with no ties.
The hyperplane-arrangement count bounds the logarithmic class size by
`m_*(d+1)^2 log 2`, uniformly over all network widths.

For any affine threshold target, the small positive scalar radius gives
a full-target witness below `1/(4 epsilon^2)`, without needing a covariance
certificate. The product-box estimate therefore suppresses energy at least
`epsilon^(-2)` uniformly over all target-consistent histories in the stated
regimes. The finite-class consistency bound makes every low-energy
consistent function have population error at most eta/4. Adding at most
eta/12 posterior tail mass gives mean error at most eta/3. Markov's
inequality then bounds the mass with correct-label posterior probability
at most 2/3 by eta. The n, beta, eta constants and all width/variance
quantifiers in the IID theorem match this proof. The thresholds are
independent of the realized sample and input distribution, as claimed.

The resulting fixed-epsilon IID rate is O((d^3+log(1/beta))/eta). It does
not rely on a false claim that every low-energy function is itself affine.

## Scope and presentation

The abstract, main theorem, and concluding discussion consistently retain
the fixed nonzero jump. The introductory wording does not claim a proved
behavioral separation from ordinary tanh. No limit interchange with
epsilon tending to zero is asserted. The displayed author order and
author-order footnote follow the repository convention.

No unresolved mathematical issue was found in these frozen sources.

## Whitespace-only publication update

A final blank line at the end of `source/posterior.tex` was removed. Its SHA256 is now `11f9e353accec015474381fa1787b4deeb494edd871ae8c519aacc8d61325460`. No theorem or proof text changed; the selector source is unchanged. An isolated rebuild was compared with the retained publication PDF and has identical extracted text.
