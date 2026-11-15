# Review of the online-lower-bound coverage extension

This review compares the added statements with the two manuscripts, including the definitions appearing in their hypotheses and conclusions. It records independent AI-agent checks during November 8–14, 2026. It is separate from Lean’s proof checking: a kernel-checked proof can still formalize the wrong statement.

[ReLU/softplus result inventory](OnlineLowerRelu-full-paper-coverage.md) · [Tanh result inventory](OnlineLowerTanh-full-paper-coverage.md) · [Reproducible theorem and axiom gate](../CheckOnlineLowerCoverage.lean).

## The learning statements

The existing ReLU and tanh main statements remain unchanged. Their quantifier order is one target and full nonrepeating input permutation, followed by every sufficiently large fixed finite learner width, followed by the prior scale tending to zero. The objects are actual finite Gaussian weight measures and their margin/sign-conditioned posteriors. Neither a minimum-energy surrogate nor a caller-supplied construction certificate replaces that posterior.

The standard-softplus extension uses literally `log(1+exp(x))`. Its main statement fixes the **same target, permutation and designated rounds as ReLU**. The raw teacher retains the stated width `C`, has strict signed margin greater than one, and coefficients at most `24C`; the padded bounded teacher and the square-root-exponential resource statement are also proved. Positive posterior normalization holds for every positive scale and every round. Finite-scale sampling, majority, confidence and expected-mistake conclusions concern those same posteriors. No homogeneity or zero-at-zero property is incorrectly assumed for softplus.

The optional ReLU layer-variance result is about the actual product Gaussian measure with positive incoming and readout variances `α σ²` and `β σ²`. A proved measure-map identity identifies every function mass, preserving the absolute output scale, with the original prior at scale `σ(dαβ)^(1/4)`. It retains the original target, sequence, count and explicit sufficient width. The positive constants may depend on the fixed width; uniformity when they vary with `σ` is not asserted.

## Norms, minimizers and ambient coordinates

The ReLU and tanh variation norms are defined as infima over actual finite affine-network representations. They are not defined to equal a desired Fourier expression. Separate representation/attainment theorems and lower bounds prove the claimed formulas. The ReLU minimum-completion result ranges over every real-valued cube function satisfying the closed margin and observed labels; it does not restrict the feasible scores to a chosen Fourier subspace. Its unique minimizer is the asserted cheapest live star.

The ReLU block-balancing statement compares actual suprema. It allows irrelevant coordinates, eliminates their weights and the bias on the restricted side, and requires even sizes only for the active blocks. Equality classifications include arbitrary signs and the zero case where appropriate.

The tanh ambient code theorem quantifies over all ambient dimensions and all coordinate identifications with the active rail cube plus arbitrary extra coordinates. The radius includes every incoming weight and the bias. It uses the actual balanced costs and the paper’s `S=max(2,96√6 W²)`, with the exact `2S` parameter and projection bounds. At positive radius, equality forces zero bias, zero weights outside one retained transversal, and precisely the optimal selected magnitudes. Equality atoms are constructed, not merely characterized conditionally. The selected support is fixed before conditional averaging; a fiberwise existential support is not incorrectly moved outside the expectation.

The quantitative localization statement likewise selects one retained orientation for the full ambient neuron. The unweighted rate holds for every code size at least two, with no sufficiently-large-size premise; its sum includes all code orientations except the chosen one, even when competitiveness is assumed only for a retained weighted subcode. Constants are chosen before the rail array, ambient dimension, bias and weights. The displayed exponential rate is exported separately from the weaker inverse-polynomial consequence used by the main theorem.

## Independent tanh analytic results

- **Three-bit parity:** the affine bound and equality classification concern every actual real vector, arbitrary bias and irrelevant coordinates. The exact finite-representation variation infimum and an attaining orbit are proved. The illustrative decimal gain is not interval-certified.
- **Finite odd degree:** the scalar optimizer is unique for every stated degree. The full-neighborhood local maximum is stronger than separate radial, bias and pairwise checks: one neighborhood works in all directions simultaneously. The actual Fréchet Hessian is negative definite. The local odd-rail code theorem includes the literal optimized weights, value one, every orientation and all independent input-sign flips; cubic off-support coefficients preserve the quadratic maximum without a C² assumption on the absolute-value objective.
- **Periodic response:** the Fourier series is proved equal to the paper’s paired-tanh series. Shape, actual derivatives, the maximum and its equality lattice hold for every positive gain, not only gain at most two. The bound is identified with the paper’s `F₀`.
- **Restoring curvature:** the exact eighty-percent threshold requires its own proof; the earlier ninety-nine-percent finite-mixture result is not a substitute. The new proof uses exact rational Bernstein coefficients and analytic truncation bounds instead of Jacobi elliptic-function identities. The exported expectation statement covers arbitrary measurable real random variables without a moment or finite-support hypothesis. Both clauses use the actual paired-tanh response, its ordinary second derivative and the paper’s F₀; integrability is derived from global bounds.
- **Residual approximation:** for every fixed derivative order and tolerance, the threshold is uniform over the specified compact gain/energy families, the literal finite arrays and every real external bias. It differentiates the full leading expression, including its Gaussian envelope. The leading response is identified with the actual Gaussian convolution of the paired-tanh series. There is no extra convergence assumption on gain or residual energy.
- **Near-optimal sequences:** the theorem assumes only near-optimal efficiency, not actual maximizers. One absolute residual-energy constant is selected before the sequence. Bulk density, common-gain convergence, maximum residual, total residual energy and outside energy are the actual coordinate quantities. The limiting supremum is over all nonzero vectors, not a stipulated constant.
- **Inverse Laplace lemma:** the hypotheses are holomorphicity, reality and the displayed quadratic remainder bound. The proof constructs a real continuous kernel with exponential growth, positive near zero, and the exact transform for sufficiently large real arguments. A pre-existing kernel is not an assumption.

## Optimization and cost order

The point-positive and subgroup-positive statements concern actual global minima, including every minimizer and the stated uniqueness. The subgroup averaging map and its invariance are proved. The paper’s normalizations are connected explicitly to the formal objective.

The high-order coefficient and dominant-pair statements allow changing dimensions and increment arrays. They use the actual optimized cost, via a proved analytic-branch identification. The uniform coefficient result supplies a stronger zero-remainder estimate; the dominant-pair bound is the stronger `O(S/H)` estimate. The rectangle-order theorem includes both a finite sufficient threshold and a checked implication from the manuscript’s asymptotic baseline condition. The quantitative path gap concerns the literal finite edge sum, with lower bound `(t/9216)^k=exp(-log(9216)k)t^k`.

## Limits of the review

The result inventories are authoritative about the precise statement coverage and exclusions. Illustrative numerical approximations and every intermediate identity in an alternative manuscript proof are not automatically covered by a theorem with the same conclusion. In particular, the ReLU proof uses a positive Fourier-integral normalizer which cancels in comparisons; its separate numerical evaluation as `π` is not formalized. The restoring-curvature proof does not formalize the manuscript’s Jacobi identities.

No contradiction in either main learning theorem was found. A phrase in the tanh phase-defect discussion was clarified to distinguish equality at the global maximum from equality in an auxiliary inequality. The main statements, protocols, resources and Lean propositions were preserved.

The combined import check also caught independently duplicated tanh variation-norm definitions. The three-bit and retained-code results now share the same definition of the finite-representation infimum. The definitions were mathematically identical; the consolidation changes no theorem statement. The complete 4,336-job dependency build and the audit of all 16,183 declarations in the 143 added modules passed after this integration fix.
