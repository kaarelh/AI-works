# Sharper learning bounds under the original internal-noise restriction

[Paper (PDF)](paper.pdf) · [LaTeX source](source/paper.tex) · [Gaussian-weighted code](source/weighted-entropy.tex) · [Dyadic scale argument](source/weighted-code.tex) · [Spectral residual argument](source/spectral-code.tex) · [Scale interpolation](source/spectral-interpolation.tex) · [Review scope](verification/README.md)

For a layered Boolean teacher of width `C` and learner depth `L`, the unchanged Gaussian tanh prior and internal-noise restriction give these sufficient sample orders:

| Regime | Joint width–depth bound |
|---|---|
| Every positive `t≤1`, hence all `γ≥1` | **`Õ(C⁴L⁹)`** |
| Every finite `γ≥7/4` | **`Õ(C⁴L⁸)`** |
| Strong scales `t≤N⁻¹ᐟ²`, hence `γ≥2`, or the strong-prior limit at each fixed width | **`Õ(min{C⁴L⁷, C⁹ᐟ²L⁶})`** |

The last bound also holds simultaneously at **every** width `N≥C` whenever the positive scale satisfies the width-independent threshold `t²≤u_c` defined below. It therefore provides a common finite-scale version of the strong-prior conclusion.

For power-law scaling, `t²=N^(1−γ)`. All displayed bounds cover every eligible learner width `N≥C` and any common iid training/test input distribution. Boolean width includes a reserved constant wire, with `C≥2`; the teacher has `L−1` gate stages, or is padded with COPY gates to that depth. Use the learner's actual `L`. Input dimension, robustness calibration, accuracy and confidence are fixed in these displays; the exact budgets retain their dependence.

The support requires clipped predictions to survive every simultaneous internal disturbance of norm at most `c/√(1+(L−1)N‖v‖²)`. Training conditions on signed output greater than `1/2`; the theorem bounds posterior-average test failure at margin `1/4`. No merging condition or extra robustness requirement is added. Initial label-independent global-margin conditioning remains optional.

The proof first constructs finite arithmetic comparison functions using an entropy matrix, an independent regression correction, and a positive variance estimate. The larger variance-estimation batch is sampled uniformly. Its rounded coefficients are assigned their **Gaussian reference probabilities**, while the other coefficients retain an ordinary finite description. Uniform-subset entropy bounds make this cheaper than counting every coefficient equally. Dyadic scale intervals give the generic fixed-dimension resource bound `Õ(LK²/e²)` and hence the all-scale `C⁴L⁹` rate. Gaussian weighting concerns this comparison code only: the learner and its prior remain ordinary Gaussian tanh networks.

A separate argument splits every internal weight matrix into a part with operator norm at most `8t` and a residual. Gaussian concentration bounds the total residual energy independently of learner width. At sufficiently small `t`, removing the bounded-operator part is an internal disturbance allowed by the original support. Applying the dense or multilevel energy code to the residual gives the stronger bound above.

The exact width-independent threshold is `u_c=r_sp²/(256H)`, where `H=L−1`,

- `K_sp=2(d+2H)+4(D_*+log(2/ε))`;
- `r_sp=min{1/6, c/√(1+H K_sp)}`;
- `D_*` is the explicit product-cylinder target cost in the paper.

Here `ε` is the risk tolerance used in that theorem. At fixed ancillary resources, `u_c⁻¹=O(CL³F₀)`, with `F₀=1+log²(2+C)`. This is a positive threshold common to all widths; it need not be a power law in `N`.

With `G=log(2+CL)`, logarithms can be retained as `O(C⁴L⁹F₀⁴G²)` for all scales and `O(C⁴L⁸F₀⁴ log²(2+L) G)` for `γ≥7/4`. The stronger-scale alternatives are `O(C⁴L⁷F₀⁴ log²(2+L)G)` and `O(C⁹ᐟ²L⁶F₀⁹ᐟ² log(2+L)G)`. The depth-six branch trades a larger width exponent for a smaller depth exponent; it is not a quartic-width depth-six theorem.

The probability statement is explicit: with training-sample probability at least `1−δ`, posterior-average test-margin failure `R(Q)` is at most `ε`, uniformly over the stated widths and scales. The pointwise posterior-confidence criterion follows from `D{x: Q(f(x)z_w(x)>1/4)≤2/3}≤3R(Q)`. Apply the risk theorem at accuracy `ε/3`, keeping `δ` unchanged: outside test-input mass at most `ε`, correct-margin posterior probability is strictly greater than `2/3`.

**Status:** conventional proofs with independent AI-agent mathematical reviews; **not Lean formalized**. The [current review](../../verification/weighted-depth-2026-10-29.md) and [build/hash record](../../verification/weighted-depth-2026-10-29.json) identify the checked revision. The [preceding review](../../verification/entropy-metric-depth-2026-10-29.md) records the earlier `C⁴L¹¹` version, whose arguments remain as supporting material. Existing Lean results are unchanged. No efficient posterior-inference or practical sample-size claim is made.

Build with `bash build.sh`. Generated intermediates stay in the ignored `build/` directory.
