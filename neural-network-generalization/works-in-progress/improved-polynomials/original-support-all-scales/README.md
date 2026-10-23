# A sharper polynomial bound under the original robustness restriction

[Paper (PDF)](paper.pdf) · [LaTeX source](source/paper.tex) · [Independent mathematical review](../verification/all-scales-review.md)

With the **same internal-noise support restriction** as the main robust-prior theorem, this paper proves a sufficient sample bound

$$
n=O(C^6\log^{13}(2+C))
$$

when the remaining parameters are fixed. A single high-probability sample event works simultaneously for every learner width `N >= C` and every Gaussian scale `0 < t <= 1`, hence for every `gamma >= 1`, including the actual finite mean-field prior. Here `C` is the width of a layered Boolean circuit, with constant wires and compilation overhead counted.

The paper gives the complete sample budget. Its joint dependence on dimension, depth, width, calibration, accuracy and confidence is polynomial; a conservative envelope is `O(S^46)`, where

$$
S=2+d+L+C+c+c^{-1}+\varepsilon^{-1}+\log(1/\delta).
$$

This improves the earlier manuscript's degree-510 envelope. The original Lean proof retains its degree-10974 budget. The second formalization batch separately certifies the new width exponent and degree-46 envelope.

Training requires signed outputs above `1/2`; the bound controls posterior average test-margin failure at `1/4`, hence sign error and posterior-confidence failure. The theorem needs no all-input clean-output margin and also permits the original extra margin conditioning.

The improvement replaces the expensive reconstruction step in the entropy compressor with importance sampling, exact empirical whitening, and a mean-square Gaussian standard-deviation comparison. The target-cylinder construction, conditional-entropy bookkeeping, preservation of the original posterior marginal, and statistical proof are included so that the paper can be read independently.

**Status:** full proof and final sources passed independent AI-agent mathematical review. Main learning statements Lean verified; not externally peer reviewed. Quadratic dependence under this unchanged support restriction remains open. The stronger-scale [quartic bound](../original-support/) and the stronger-support [quadratic bound](../neuron-averaging/) have different scopes.

Run `./build.sh` to rebuild the PDF using `pdflatex`. [Collection overview and verification records](../README.md).

## Lean verification

The main statements are included in the second formalization batch. [Exact coverage and exclusions](../../../lean/review/BatchTwo-coverage.md) · [Lean entry point](../../../lean/NeuralGeneralization/BatchTwoMain.lean). This label does not extend automatically to every appendix, remark or numerical allocation. The original mathematical review records describe their earlier source snapshots.
