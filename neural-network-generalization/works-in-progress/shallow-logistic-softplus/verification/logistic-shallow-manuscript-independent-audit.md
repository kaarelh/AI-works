# Independent audit of shallow targets under deep logistic posteriors

25 October 2026. Finite-N audit agent. Conventional mathematical audit, not Lean verification.

**PASS** on `manuscripts/logistic-shallow-posterior.tex`, SHA256 `c27e33ee5156467267a727eac450c4c213b84d7c07188b1339ade5819c5a3ebd`. PDF SHA256 `74e5e221b975d3802c9ecd3038da51e474d4f97b370b67ca9bc3338fef2360bb`.

I freshly checked the assembled theorem and proof, including the self-contained compression lemma rather than treating it as an imported capacity result. The two requested minor edits have been made: the energy lower bound has the proper LaTeX spacing command, and the small-width witness paragraph explicitly separates the direct L=2 witness from the L>=3 complementary wire. Neither changed the mathematical result.

## Compression and finite description

Sampling a neuron with probability proportional to incoming-row norm times outgoing-column norm gives exactly the displayed unbiased vector average. Its incoming Frobenius norm is sqrt(m), its outgoing norm is A/sqrt(m), and A is at most the old adjacent product. Zero-fixing and unit-Lipschitz activations bound each sampled vector by A times the input-state norm. Hilbert-space second moments plus bounded differences give the simultaneous finite-input error. Multiplying by the preceding and suffix norm products yields the global bound C P sqrt((d+1)/m), independently of all original widths.

Successive compressions preserve the product bound and the activation class, even though neighboring matrices change. The choice m=C P^2 L^2(d+1) leaves total error below 1/16. Normalizing each hidden matrix and absorbing its accumulated scale into its scalar activation is exact. Rounding hidden matrices, readout, offset, and scalar activation tables then has polynomial description length and uniformly small output error. The argument compares the stored maps to the original Lipschitz maps, so it does not incorrectly assume the rounded interpolants themselves remain unit-Lipschitz. Intermediate arguments remain in the stored interval. The resulting class is common to all physical widths and realized anchor maps.

## Complementary transmission and stability

The scalar sequence r_s=q^s/(sqrt(D') min(s,m-s)) has the claimed endpoint and energy bounds; the atanh remainder and paired ratios give a constant total overhead. Products of consecutive b_s telescope up to a bounded correction. In the logistic realization, the first added layer costs at most 4D alpha^2, later pair layers cost exactly 16b_s^2, and the odd-width excess is confined to the final readout. This yields K_L=2+16(L+12)T^(1/(L-1)), including all constants and constant-coordinate effects. The centered effective product is polynomial in T uniformly in L.

The witness stability proof uses its explicit partial products, not just its total energy. In normalized coordinates every perturbed logistic hidden state still has norm at most one. Each block perturbation therefore injects only O(eta) error, propagated by the witness gains; the total is O(L^2 T eta). This remains valid without a small perturbation factor multiplying each stage's norm.

## Actual posterior and limiting arguments

The convex symmetric Gaussian bulk has raw mass at least 1/2 for N>=M0>=d+1. Witness stability makes its translation a subset of the exact target-consistent global-margin event. Gaussian translation and isoperimetry yield the stated posterior distance tail with no missing volume or conditioning factor.

After metric projection, the proof centers the realized network and freezes its exact anchor maps before replacing linear blocks. This is essential and is done correctly. Dividing every block by four, with a factor four outside the readout, gives the displayed telescoping perturbation bound. The energy normalization and the small-bulk condition bound that error by 1/8. The surrogate need not be native logistic; the larger finite class expressly permits these frozen zero-fixing Lipschitz maps. Its nonconstant truth table automatically bounds the retained anchor output by twice its product, while constant tables are listed separately.

The finite-width fallback uses an actual target witness, a cube clipped at the Gaussian standard deviation, a sample-uniform conditional energy tail, and a margin-stable parameter net. Hence it has no log(1/t) divergence. The polynomial cutoff N_* depends only on the stated teacher resources, L, the confidence tolerance, and the fixed gap zeta. Using this fallback below N_* and the width-independent class above it gives all finite widths, including N=1 (where the truth table is constant).

At fixed architecture, Gaussian energy concentration near a strict-margin witness passes to any limiting posterior on the finite truth-table simplex. The statistical argument passes through Gibbs error, not through a discontinuous confidence-threshold event. The class and favorable sample event are independent of t and of all realized anchor values. The final finite-class union bound and Gibbs-to-2/3-confidence inequality are correct.

## Scope

This proves polynomial learning of bounded-weight shallow logistic targets under arbitrarily deep logistic learners, in the cold limit and every fixed exponent gamma>1, including both-label samples. It does not prove the critical gamma=1 theorem, a fixed positive canonical-prefactor theorem, arbitrary deep-teacher learning, or an exact-tanh depth resolution. The manuscript states these boundaries accurately.

## Abstract clarification, 26 October 2026

The author changed the abstract's informal energy summary to `16L+O(log T+1) once L-1>=log T`. This is correct: the exact audited witness bound `2+16(L+12)T^(1/(L-1))` has that expansion under the added depth condition, including `T=1`. The body and main theorem are unchanged. Confirmed source SHA256 `31e672a7b7a696a6ec2000de282be4a54a0ddd45e65ff567bd62bb4b94359440`. The publication source differs only in its author line, as checked by the author.
