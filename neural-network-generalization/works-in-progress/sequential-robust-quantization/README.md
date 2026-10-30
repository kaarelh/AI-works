# Sharper depth dependence under the original internal-noise restriction

[Paper (PDF)](paper.pdf) · [LaTeX source](source/paper.tex) · [All-scales extension](source/all-scales.tex) · [Review and verification scope](verification/README.md)

Rounding coefficients **during** neuron compression improves sample bounds without changing the original internal-noise restriction on the Gaussian tanh prior:

| Regime | Previous joint bound | Improved joint bound |
|---|---|---|
| Strong-prior limit at each width, or finite `γ≥2` | `Õ(C⁴L⁸)` | `Õ(C⁴L⁷)` |
| Every positive mean-field-or-stronger scale, hence all `γ≥1` | `Õ(C⁶L¹⁸)` | `Õ(C⁶L¹⁷)` |

Here `C` is layered Boolean teacher width, including a reserved constant wire at every stage, and the learner has `L−1` hidden layers. A shallower Boolean teacher may be padded with copies. Input dimension, calibration, accuracy and confidence are fixed in the displayed rates. Both guarantees are uniform over every eligible learner width `N≥C` and the indicated scales; they allow any common iid training/test input distribution. The paper uses the explicit convention `C≥2`.

The original condition requires clipped predictions to survive every simultaneous internal disturbance of norm at most `c/√(1+(L−1)N‖v‖²)`. Training conditions on signed output greater than `1/2`; the theorem bounds posterior-average test failure at margin `1/4`. Rescaling the accuracy parameter gives strict `>2/3` posterior confidence. No population-merging assumption is added, and initial global-margin conditioning is optional.

The compression pass constructs rounded hidden states before sampling the next layer. Fresh samples remain independent of those states, and the rounding errors become bounded disturbances of the **original** robust network. This removes the former exponential-depth precision requirement. It does not assume that the compressed model inherits robustness.

A further target-cylinder refinement multiplies independent layer-success probabilities rather than making every layer succeed with probability near one. With `F₀=1+log²(2+C)` and `G=log(2+CL)`, sufficient orders are

- `O(C⁴ L⁷ F₀⁴ log²(2+L) G)` in the stronger-scale regime;
- `O(C⁶ L¹⁷ F₀⁶ G)` throughout all `γ≥1`.

These remain loose upper bounds. Quadratic width for the unchanged original restriction, and substantially smaller depth powers, remain open.

**Status:** conventional proofs with independent AI-agent mathematical reviews; **not Lean formalized**. The quartic argument includes the target-cylinder, compression, posterior-tail, and statistical proofs. The all-scales appendix states and uses the active-direction and reconstruction estimates from the [earlier all-scales paper](../improved-polynomials/original-support-all-scales/), then proves the sequential-rounding modification. Its conservative degree-45 envelope is a new conventional consequence; the earlier degree-46 Lean theorem is unchanged.

Build with `bash build.sh`. Generated intermediates stay in the ignored `build/` directory.
