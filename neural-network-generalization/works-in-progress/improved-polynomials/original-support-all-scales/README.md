# A sharper polynomial bound under the original robustness restriction

[Paper (PDF)](paper.pdf) · [LaTeX source](source/paper.tex) · [Independent mathematical review](../verification/all-scales-review.md)

With the **same internal-noise support restriction** as the main robust-prior theorem, this paper proves a sufficient sample bound

$$
n=O(C^6\log^{13}(2+C))
$$

when the remaining parameters are fixed. A single high-probability sample event works simultaneously for every learner width `N >= C` and every Gaussian scale `0 < t <= 1`, hence for every `gamma >= 1`, including the actual finite mean-field prior. Here `C` is the width of a layered Boolean circuit, with constant wires and compilation overhead counted. The scale convention is `t=N^((1-gamma)/2)`, with `gamma=1` at mean field.

Write `d` for input dimension, `L` for depth, `c>0` for robustness calibration, `ε` for test-error tolerance, and `δ` for training-sample failure probability. The paper gives the complete sample budget. Its joint dependence on these parameters and width is polynomial; a conservative envelope is `O(S^46)`, where

$$
S=2+d+L+C+c+c^{-1}+\varepsilon^{-1}+\log(1/\delta).
$$

This improves the earlier manuscript's degree-510 envelope. The original Lean proof retains its degree-10974 budget. Separate formal proofs certify this paper's literal sample budget, width exponent, and degree-46 envelope.

Training requires signed outputs above `1/2`; the bound controls posterior average test-margin failure at `1/4`, hence sign error and posterior-confidence failure. The theorem needs no all-input clean-output margin and also permits the original extra margin conditioning.

The improvement replaces the expensive reconstruction step in the entropy compressor with importance sampling, exact empirical whitening, and a mean-square Gaussian standard-deviation comparison. The target-cylinder construction, conditional-entropy bookkeeping, preservation of the original posterior marginal, and statistical proof are included so that the paper can be read independently.

**Status:** full proof and final sources passed independent AI-agent mathematical review. Main learning statements Lean verified; not externally peer reviewed. Quadratic dependence under this unchanged support restriction remains open. The stronger-scale [quartic bound](../original-support/) and the stronger-support [quadratic bound](../neuron-averaging/) have different scopes.

Run `./build.sh` to rebuild the PDF using `pdflatex`. [Collection overview and verification records](../README.md).

## Lean verification

The [15 November coverage record](../../../lean/review/coverage-completion-2026-11-15.txt) certifies the exact target-cylinder cost `D_*`, finite-grid entropy `J`, and printed sample allocation `16(J+log(1/δ))/ε` for the actual posterior, with or without optional global-margin conditioning. The sixth-power width rate and degree-46 envelope are proved for that same formula.

The [literal-target correspondence](../../../lean/review/manuscript-literal-target-correspondence-2026-11-15.txt) explains the construction at every `N≥C`, including the literal small-width cases. It resolves the earlier constant-wire and numerical-allocation qualifications recorded in the [statement audit](../../../lean/review/statement-audit-2026-10-23/polynomials-online.md) and [original endpoint map](../../../lean/review/BatchTwo-coverage.md). Those records and the [original Lean entry point](../../../lean/NeuralGeneralization/BatchTwoMain.lean) remain useful for tracing the formalization. Dated mathematical reviews describe their own source snapshots; coverage of the stated results does not certify every informal auxiliary calculation.
