# Independent audit of the dropout alternative

Reviewed on 22 October 2026 by an independent AI agent. This is an ordinary mathematical review, not Lean verification. The reviewed source is `dropout-conditions.md`.

## Verdict and scope

The proof supports the stated tanh result: the proposed random-subset support condition gives sample complexity quadratic in Boolean teacher width up to logarithms, polynomial in depth and input dimension, at every learner width above the compiled teacher width and every Gaussian scale with `sigma^2 <= 1/N^2` (in particular every `gamma >= 2`). The same uniform bound gives the fixed-width strong-prior conclusion. It does not establish the mean-field or `1 <= gamma < 2` result.

No substantive mathematical gap was found. The only correction requested was to replace “exceeds 13/32” by “is at least 13/32” for the rounded reconstruction's training score. Its strict separation from the bad-set threshold 11/32 is unchanged.

The restriction is adaptive through the readout-energy/output-amplitude ratio, but it remains a strong assumption about pruning down to an absolute retained count. It is not ordinary constant-rate dropout, and no assertion about usual trained networks is proved.

## Compression identity and finite count

Independent uniform subsets at adjacent layers retain each internal edge with probability `(m/N)^2`. This independence is the needed fact; independence of neurons within one subset is not required. Including the inverse-retention edge rescaling and the width-dependent first-layer/readout coefficients gives exact equality of expected weighted energies. The same calculation applies to any fixed parameter difference because the pruning map is linear in the parameters.

The probability-three-quarters support event intersects the energy-at-most-`4K` event in probability at least one half. A nonempty fitted sample implies `M > 1/2`, so the selected width is bounded by the stated `Q(K)`. Every retained weight is bounded by `2 sqrt(QK)`, including the width-dependent first layer and readout. Zero padding preserves a tanh network's output.

The displayed rounding recurrence bounds the accumulated output error by `L zeta A_g^L = 1/32`. Although the mesh is exponentially small in depth, only its logarithm enters the number of descriptions. The parameter count and mesh bound therefore give the stated logarithmic class size of order `LdK + L^2 K^2`, up to logarithmic factors. The clipped reconstruction error is at most `1/16 + 1/32 = 3/32`.

## Boolean witness and mask counts

The NAND/COPY/NOT implementation restores the logical state tolerance at each stage: each count-weighted input differs from its intended sign by at most `33/256`, and the at most three signed terms preserve a preactivation margin greater than `A/2`. The gain `A=8` then restores error below `1/16`. This induction is uniform over the whole input cube, so the mask-count event needs no union bound over inputs.

The balanced-population bounds imply the displayed hypergeometric probability estimate. For `R >= C/4`, the chosen constant `A0=2^16` makes the network's own selected width meet the required count threshold whenever it is smaller than `N`. If the selected width equals `N`, pruning is exactly the identity. The conservative logical-row, clone-ratio, and readout calculations give the stated teacher energy `B` and `8C <= E_v <= 32C`.

On the good-count event, every contribution to compressed teacher energy is multiplied by one count factor or by a product of two such factors. Thus the bound `2B` is valid. The retained readout also retains signed margin greater than three.

## Entire perturbation ball and the discontinuous width choice

The weighted coordinates reduce the network to an input of norm at most `sqrt(2)`, zero-at-zero 1-Lipschitz hidden activations, and layer matrices whose combined squared Frobenius norm is the weighted energy. Telescoping layer replacements and Cauchy–Schwarz over the layer perturbation norms prove equation (6), with the stated `sqrt(2L)` factor.

The radii `r1` and `r0=r1/10` are conservative. Every point in the `r0` ball keeps the original signed margin above one and has `M <= 17/4`; the lower bound on its readout norm gives `R >= C/4`. For each such point, one applies the count estimate at its own integer-valued selected width. The argument does not assume continuity of the ceiling or local constancy of that width.

The compression identity applied to the fixed perturbation gives compressed perturbation radius at most `r1` with probability at least 99 percent. Intersecting with the at-least-98-percent good-count event leaves at least 97 percent. Applying the same Lipschitz estimate around the compressed teacher of energy at most `2B` preserves margin above one. Both clipped outputs equal the target sign divided by two on that event. Consequently the entire parameter ball, rather than just its center, belongs to the prior support and every target training event.

## Gaussian mass, posterior ratio, and uniform learning event

In the weighted coordinates the raw Gaussian is isotropic with variance `sigma^2=t^2/N`. Under `sigma^2 <= 1/N^2`, its dimension `p` satisfies `p sigma^2 <= S=d+L+1`. Integrating over the inscribed coordinate cube gives the stated Gaussian ball probability. Multiplying the logarithm of the volume penalty by `sigma^2` bounds it by `S log(2 sqrt(S)/r0)`, so the coefficient `D_*` is independent of learner width.

The chi-square exponential moment at parameter one quarter gives the numerator in equation (10). The selected `K` cancels the dimension contribution using `p sigma^2 <= S`; since `sigma^2 <= 1`, the remaining posterior mass is at most `epsilon/2`. Conditioning the raw prior on the dropout event, and optionally on the global absolute margin, cancels from this ratio. The target ball proves every such prior and posterior normalizer is positive.

For the finite statistical step, the rounded predictor's training clipped score is at least `13/32`, whereas every original test-margin failure implies rounded score at most `11/32`. The latter bad set must therefore be missed by the training data. A union bound over the common finite grid, followed by the posterior energy-tail bound, proves the displayed expectation guarantee. The same grid and same data event apply to all learner widths and permitted scales; no uncountable union over scales is being taken.

## Limitations checked

The full-ball mass proof uses the stronger scaling explicitly. At mean field the analogous quantity `p sigma^2` grows with width. The free-bulk covariance calculation gives variance `t^2(N/m-1)` after inverse-retention subsampling, confirming the stated obstruction to reusing that cylinder proof. Neither calculation proves failure of every possible dropout-conditioned mean-field learner. The note correctly leaves that extension open.
