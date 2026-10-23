# Output-aware one-population search: independent audit

The reviewed `q1_output_search.py` has SHA-256
`77c0b8a43748c5ecac5db31bf689b4d900878084afa7ba5e2a3d8515f72ae43b`.
No substantive implementation error was found. It reads weight arrays and
evaluates the network's own outputs and hidden activations over the Boolean
cube. It never reads target labels, training indices, or test labels.
Initial signs are correlations with either raw or clipped original outputs.
Four fixed-schedule coordinate sweeps seek reductions of mean squared clipped
discrepancy, optionally plus maximum squared discrepancy. Rejected flips are
undone; accepted loss and maximum values remain consistent with the saved
sign witness. The selected witness minimizes observed maximum discrepancy
among the four attempted settings. Search failure remains inconclusive.

For one signed population, the group's size is exactly N at every layer,
so the partition is balanced. In the stored row-vector convention, the
reduced first-layer vector is `W1 s1/N`, each later scalar weight is
`s(s-1)^T Ws ss/N`, and the readout is `sH^T v`. These are the exact q=1
specialization of the audited signed-projection reduction. The code uses
these formulas correctly.

The `fresh-000-majority5-H4-N32-adam-s0` witness was independently verified
with exact rational block averages of the stored binary weights and
outward-rounded mpmath intervals at 50 decimal digits. On all 256 inputs,
both the original and reduced outputs have the same sign and absolute value
greater than **0.535955**. Consequently their clipped outputs agree exactly;
the certified global discrepancy is zero. The readout energy is approximately
3.533674, so q=1 satisfies the energy constraint, while the original width is
32. There is one hidden signed population in each of four hidden layers.

This is a concrete low-readout-energy gradient-trained example of substantial
compression under the **signed balanced variant**. It does not certify the
original unsigned support, nor the optional internal-noise condition, and
does not establish that arbitrary targets or trained models have similar
compression. In particular, a width-one tanh chain has a monotone affine
decision rule, so this particular success for majority should not be treated
as evidence that parity itself can be compressed to one population.

The standalone replay is `verify_q1_witness.py`, using exact-arithmetic and
interval helpers from `verify_population_witnesses.py`. The new certificate
`certificate-fresh-000-output-aware-q1-signed-balanced.json` records source
hashes, checkpoint hash, group signs, exact reduced weight fractions, and all
256 input certificates. Earlier verifier sources and certificate files were
left untouched. This is a numerical interval proof depending on mpmath's
outward-rounded arithmetic and exponential, not a Lean proof.
