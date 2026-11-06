# Dual, posterior, selector, and compression review

Reviewed on 6 November 2026 by research agent `wide_gelu`. This is an informal mathematical audit, not a Lean formalization.

I independently reviewed the main theorem, the covariance dual, the relaxed-neuron energy gap, the selector certificate, and the actual Gaussian posterior comparison. I wrote the layer-cake compression proof in `compression.tex`; that component was independently checked by the geometry agent. It should therefore be treated as an authored proof with a separate review, rather than as my independent review of another author's proof.

The final assembled snapshots are:

| File | SHA256 |
| --- | --- |
| `source/paper.tex` | `85eee6fbf46bb436ecb7e4fa36e93fe0224154aa6677aee55ee64b9f78c8152c` |
| `source/dual.tex` | `0fda467e8b96367423c4f416917c92c9d49da5f69800ba26aaedda7b235a44f9` |
| `source/selector.tex` | `950940054310fdd20ed708be74571280af0a363171a1ef29998d466f6b774638` |
| `source/posterior.tex` | `11f9e353accec015474381fa1787b4deeb494edd871ae8c519aacc8d61325460` |
| `source/compression.tex` | `ed85129384d15c5c4e85f713261cef8a4dee54ec0448a850a09330170ef7b79d` |
| `paper.pdf` | `a4223ce606586306d044f19629368fcdab83e6e7cc1c30a11a2eaa0d22cbe15d` |

No mathematical gap was found in the stated claims.

## Scope and statement

The activation is the fixed discontinuous function `tanh(t)+epsilon sign(t)`, for every fixed positive epsilon. Its uniform distance from tanh is epsilon. The theorem does not take epsilon to zero together with dimension, width, or prior scale, and does not claim a result for a continuous activation.

The network has one hidden layer, the full Boolean input cube, an appended constant input, the unchanged independent isotropic Gaussian first-layer prior, the usual relative layer scaling, exact labels, and global absolute output margin greater than one half.

The statement correctly distinguishes the cold prior at every fixed width, the direct limit at fixed gamma greater than one, and the sufficiently small prefactor that works at every width and every gamma at least one. The target teacher width is `ceil(1/epsilon)`, independent of k, with all individual weights bounded by one. The dimension and calibration restrictions remain explicit.

## Covariance dual and equality

The active KKT identities imply the stated decomposition of the active score into mean t and variance at most `2||w||²`. The global bound `sup|tanh''|<1` justifies the second-order remainder estimate. The jump term contributes at most epsilon regardless of its signs.

The scalar profile has a unique positive minimizer, and the stationarity relation gives the exact quadratic floor. I checked the small-atom and large-atom split and every epsilon-dependent estimate. The assumption `d>=4 max(1,epsilon^(-6))` makes the orthogonal-cost bracket at least `31d/64`, as claimed. Large atoms have a nonnegative floor, while the optimum floor is strictly negative.

Equality therefore forces the orthogonal component to vanish, the scalar coefficient to have magnitude r, and the readout to have the matching sign and exact magnitude. Every equality atom gives the same full output. The inequalities integrate over arbitrary finite-energy neuron probability measures, so the equality statement is not limited to a fixed finite width.

## Uniform energy gap

The relaxed jump graph is closed: at a nonzero limiting preactivation the jump sign is eventually fixed, while at zero the compact interval of jump values is allowed. Its output is continuous in the relaxed coordinates. Energy sublevels are tight, and bounded activations make the output integrands uniformly integrable through the second-moment bound on the readout coefficient. Truncation therefore passes every finite margin constraint to a weak limit.

The correct-query energy infimum in the relaxed measure space is attained. If it equaled the old optimum, the atomwise equality characterization would force the old scalar output. Its preactivations are nonzero on the whole cube, so every relaxed jump value is forced too. This contradicts the new correct query margin and proves a positive gap independent of width.

The relaxation need not impose oddness on jump values at zero. The dual proof only uses the absolute jump-average bound, and the equality rows never encounter a zero score. Thus this enlargement does not create an omitted equality case. The argument also correctly avoids assuming that the partially revealed next calibration block already has its own covariance certificate.

## Selector and covariance certificate

The pairwise-independent free-bit sets have the stated size, means, and second moments. Their selected binary vectors span the seed space, so the parameterization is injective and the all-minus assignment is included.

I checked the KKT recurrences and total masses, all signed means in the orthonormal coordinates, the entries of the covariance block, the Gershgorin estimate, and both Schur-complement correction bounds. The final numerical bound holds at k=8 and decreases thereafter. Pairing labeled antipodes cancels the appended-constant mean and its covariance cross terms without assuming that competing network functions are odd.

The calibrated groups are disjoint. Each designated first query has the opposite sign from the preceding unique scalar optimum; the remaining points complete the next covariance-certified stage. The initial sample bound, the bound of `4k` inputs per stage, and the count `2^k-k-1` all follow as stated.

The target has linear Boolean circuit size. Dividing its affine coefficient vector by `2^k` bounds every incoming weight by one while preserving nonzero scores. The jump gives each cloned neuron signed output strictly above epsilon, so `ceil(1/epsilon)` unit readouts give signed output strictly above one.

## Actual Gaussian posterior

The physical neuron coordinates `(sqrt(d)u,b)` have covariance `N sigma² I`, and the energy is their average squared norm. A fixed box around a slightly amplified cloned witness stays inside one strict full-margin cell and below the competing energy level.

The product-box denominator and chi-square numerator are correct. Their logarithmic variance terms cancel, leaving the bound `exp[-Delta/(2sigma²)+C N]`. This proves the fixed-width cold limit, the direct gamma-greater-than-one limit, and the uniform small-prefactor claim at every width. The finite list of stages permits common constants, and the joint sampling statement follows by a union bound without prediction independence.

All networks predicting the correct next label are included. The proof compares actual conditional probabilities, rather than selecting a convenient minimum-energy representative.

## Compression and IID proof

For a bounded monotone activation, a uniform output-level threshold represents each neuron table as the expectation of Boolean affine threshold tables on the finite cube. Almost every level avoids all finitely many activation values; ties and jumps therefore require no rounding argument. Readout signs can be absorbed by complementing threshold tables.

The readout l1 norm is at most the square root of the energy. Sampling from the resulting signed-threshold mixture and applying Hoeffding's inequality gives an unweighted majority of `O(M²(E+1)d)` affine thresholds with exactly the same Boolean output. The representation uses no discretization of the overall output amplitude. Counting threshold truth tables gives the stated `O(M²(E+1)d³)` logarithmic class bound, uniformly over all finite learner widths.

For any affine threshold target, a small positive scalar input scale gives a full-target witness of energy below `1/(4epsilon²)`. Thus the product-box lemma suppresses the posterior event above energy `epsilon^(-2)` uniformly over target-consistent histories. The consistency bound for the compressed class, followed by Markov's inequality, gives the stated greater-than-two-thirds posterior confidence outside input mass eta. Its variance and width thresholds are independent of the sample realization and input distribution.

## Whitespace-only publication update

A final blank line at the end of `source/posterior.tex` was removed. Its SHA256 is now `11f9e353accec015474381fa1787b4deeb494edd871ae8c519aacc8d61325460`. No theorem or proof text changed; the selector source is unchanged. An isolated rebuild was compared with the retained publication PDF and has identical extracted text.
