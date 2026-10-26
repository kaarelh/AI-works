# Independent audit of the Gaussian mean-shift circuit witness

26 October 2026. **PASS.** Source: `finite-width-boolean-circuit-mean-shift-learning.md`, SHA256 `8a1e4471522ecec402fca59c3bd379f3fe2ea0b431ec3ace0c9e722e869ee2d7`.

This audit verifies the actual finite-width target-mass and sample bound, with its stated width threshold and explicit `1/t²` dependence. It does not turn the bound into a width-independent or cold-limit theorem.

## Propagation and constant wires

All Gaussian mean shifts are deterministic functions of the specified Boolean circuit. Under the comparison law, rows remain independent with exactly the original variances. Background connections are retained. Each gate's coefficient absolute sum is at most three even when inputs coincide. The constant wire is an actual group and its cost is included.

For group means within signed magnitude 0.9 of their Boolean bits, an AND or OR has signed affine score at least 0.8 even when the constant group's mean is only 0.9. COPY and NOT have score at least 0.9. Initial Boolean inputs give score at least one. With gain ten, every controlled signed mean is at least eight. Conditional variances are at most two initially and one later. The displayed expectation estimate is at least `1-2e^-4-2e^-8 > .95`; Hoeffding with a gap of .05 gives exactly `exp(-n_g/800)`.

The conditional induction requires no independence among inputs. Union bounds over every cube input, group, and layer yield the stated 1/8 hidden failure probability. The readout variance is at most `t²/N`; the displayed width threshold more than suffices for its all-cube absolute-noise error at most 1/4 with failure probability 1/8. Hence the globally correct strict margin event has comparison probability at least 3/4.

## Entropy, actual target mass, and posterior normalization

The first-layer cost is at most `450dN/t²`. Internal row mean squared norm is at most `18a² C/N`, giving `900C/t²` per row. Readout mean squared norm is at most `2C/N`, hence its KL cost is at most `NC/t²`. These sum to at most `1000N(d+CH)/t²`.

Binary data processing gives `KL(Q||P) >= Q(E) log(1/P(E))-log 2`. Using the weaker success probability 1/2 yields the stated `2002N(d+CH)/t²` raw target-mass exponent. Since the target-margin event is contained in the global absolute-margin event, its truth-table probability under the already globally conditioned prior is at least this raw mass. Thus the subsequent version-space normalization is handled correctly; neither conditioning operation is dropped.

## Statistical conversion

The expected prior mass of sample-consistent hypotheses with population error exceeding `epsilon/6` is at most `exp(-n epsilon/6)`. The target atom supplies a sample-uniform lower bound on the version-space normalizer. Markov gives the stated posterior bad-mass bound, and the final Gibbs error is at most `epsilon/3`. Every point with correct-label probability at most 2/3 contributes at least 1/3 to Gibbs error, proving the confidence claim for the actual posterior mixture.

The sample law may be any common training/test distribution. The result applies to layered bounded-fan-in Boolean circuits at the learner's available depth, not arbitrary tanh teachers with soft hidden states. Its linear dependence on N is valid only above the displayed circuit-group concentration threshold; the note states this restriction correctly.

## Layerwise-width comparison addendum

Section 7 was added and checked against final source SHA256 `58c030de2ede0457f61978ab7aee2e75108b80220642ace5b4340ad826f4520c`. At stage j the internal KL uses the preceding width `C_(j-1)`, and readout KL uses `C_H`, so their sum is controlled by `G=sum_j C_j`. The concentration union has G groups, giving the stated threshold with `C_max` and `log(8G)`. For exponent gamma, `N/t²=N^gamma` exactly. The comparison with the uniform-scale quadratic-width upper is correct. The coarse all-eligible-width linear-in-N statement explicitly means `N>=C_max`; below the concentration threshold its extra N factor can be absorbed into the polynomial circuit resources. No unproved same-width circuit realization is asserted for `N<C_max`.
