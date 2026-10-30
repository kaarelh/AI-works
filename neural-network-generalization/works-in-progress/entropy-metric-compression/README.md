# Entropy-metric compression under the original internal-noise restriction

[Paper (PDF)](paper.pdf) · [LaTeX source](source/paper.tex) · [Entropy-metric proof](source/entropy-metric.tex) · [Scale interpolation](source/scale-interpolation.tex) · [Multilevel code](source/multilevel-code.tex) · [Review scope](verification/README.md)

For a layered Boolean teacher of width `C` and learner depth `L`, the unchanged Gaussian tanh prior and internal-noise restriction give these sufficient sample orders:

| Regime | Joint width–depth bound |
|---|---|
| Every positive `t≤1`, hence all `γ≥1` | **`Õ(C⁴L¹¹)`** |
| Every finite `γ≥8/7` | **`Õ(C⁴L⁹)`** |
| Strong scales `t≤N^(-1/2)` (`γ≥2`), or the strong-prior limit at each fixed width | **`Õ(min{C⁴L⁷, C^(9/2)L⁶})`** |

Here `t²=N^(1−γ)`. The strong-prior limit means sufficiently small positive scales at each fixed width. The bounds cover every eligible learner width `N≥C` and any common iid training/test input distribution. Boolean width includes a reserved constant wire, with `C≥2`. Input dimension, robustness calibration, accuracy, and confidence are fixed in these rate displays; the explicit budgets retain their dependence.

The support still requires clipped predictions to survive every simultaneous internal disturbance of norm at most `c/√(1+(L−1)N‖v‖²)`. Training conditions on signed output greater than `1/2`; the theorem bounds posterior-average test failure at margin `1/4`. No population-merging assumption or additional noise condition is imposed. Initial label-independent global-margin conditioning remains optional.

The new proof uses one integrated Fisher-information matrix to control every Gaussian channel, importance sampling in that metric, and an independent regression correction. A positive variance envelope and metric projection make the reconstruction valid even when the ideal residual variance vanishes. The finite comparison functions use arithmetic projection and square-root gates between tanh layers. These are proof devices; the learner and its prior remain ordinary tanh networks. A raw-prior bound handles the complementary range of width and scale. The separate multilevel code improves the strong-scale depth power.

With `F₀=1+log²(2+C)` and `G=log(2+CL)`, the first two entries retain logarithms as `O(C⁴L¹¹F₀⁴G²)` and `O(C⁴L⁹F₀⁴G²)`. The new strong-scale term is `O(C^(9/2)L⁶F₀^(9/2) log(2+L) G)`; take its minimum with the preceding quartic strong-scale bound.

The probability statement is explicit: with probability at least `1−δ` over the iid training sample, posterior-average test-margin failure `R(Q)` is at most `ε`, uniformly over the stated widths and scales. The pointwise posterior-confidence criterion follows from `D{x: Q(f(x)z_w(x)>1/4)≤2/3}≤3R(Q)`. Apply the risk theorem at accuracy `ε/3`, keeping `δ` unchanged: outside test-input mass at most `ε`, posterior correct-margin probability is strictly greater than `2/3`.

**Status:** conventional proofs with independent AI-agent mathematical reviews; **not Lean formalized**. The [review record](../../verification/entropy-metric-depth-2026-10-29.md) and [build/hash record](../../verification/entropy-metric-depth-2026-10-29.json) identify the checked revision. Existing Lean results are unchanged. These are upper bounds, without an efficient-inference or practical sample-size claim.

Build with `bash build.sh`. Generated intermediates stay in the ignored `build/` directory.
