# Sharper depth dependence under the original internal-noise restriction

[Paper (PDF)](paper.pdf) · [LaTeX source](source/paper.tex) · [Bounded-density and factor-code proof](source/factor-code.tex) · [Review and verification scope](verification/README.md)

For a layered Boolean teacher of width `C` and `L−1` gate stages, the unchanged internal-noise restriction on a Gaussian tanh prior gives:

| Regime | Sufficient joint width–depth bound |
|---|---|
| Every positive mean-field-or-stronger scale, hence all `γ≥1` | **`Õ(C⁵L¹²)`**, improving the preceding `Õ(C⁶L¹⁷)` bound |
| Strong-prior limit at each width, or finite `γ≥2` | **`Õ(C⁴L⁷)`**; this separate bound is unchanged by the factor-coding improvement |

The bounds are uniform over every eligible learner width `N≥C` and the indicated scales, for any common iid training/test input distribution. Width counts a reserved constant wire at every stage, with `C≥2`; a shallower teacher may be padded with copies. Use the learner's actual depth in the formulas. Input dimension, robustness calibration, accuracy and confidence are fixed in these rate displays.

The original condition requires clipped predictions to survive every simultaneous internal disturbance of norm at most `c/√(1+(L−1)N‖v‖²)`. Training conditions on signed output greater than `1/2`; the theorem bounds posterior-average test failure at margin `1/4`. Rescaling the error tolerance gives strict `>2/3` posterior confidence. No population-merging assumption is added, and initial global-margin conditioning is optional.

The proof uses three ingredients:

- **Sequential rounding.** Rounded weights are used while constructing each compressed layer, so their errors are disturbances of the original robust network. The compressed model need not inherit robustness.
- **Bounded posterior density.** Exact conditioning gives a pointwise density bound relative to the raw Gaussian. This property survives reconstruction with a finite information cost and sharpens the active-direction cutoff. Using this improvement alone gives `Õ(C⁶L¹⁵)`.
- **Factored reconstruction.** The active matrix has small rank. A shared Gaussian sketch gives a small-rank approximation to the remaining Gaussian field. Encoding the two factors requires fewer coefficients than encoding a dense matrix. The candidate law is the same for every input; only the comparison coupling depends on the input.

With `F₀=1+log²(2+C)` and `G=log(2+CL)`, the log-retaining bounds are

- `O(C⁵ L¹² F₀⁵ G)` throughout all `γ≥1`;
- `O(C⁴ L⁷ F₀⁴ log²(2+L) G)` in the stronger-scale regime.

At fixed depth the all-scale rate is `O(C⁵ log¹¹(2+C))`; at fixed width it is `O(L¹² log(2+L))`. The exact budgets retain all input-dimension and statistical dependence. One conservative joint envelope is `O(S³² log S)`, hence `O(S³³)`, where `S=2+d+L+C+c+c⁻¹+ε⁻¹+log(1/δ)`.

These are loose upper bounds. The subsequent [entropy-metric paper](../entropy-metric-compression/) proves `Õ(C⁴L¹¹)` throughout all `γ≥1`, `Õ(C⁴L⁹)` for `γ≥8/7`, and the stronger-scale tradeoff `Õ(min{C⁴L⁷,C⁹ᐟ²L⁶})`. This paper retains the simpler preceding arguments. A smaller depth exponent while retaining quartic width in the stronger-scale bound, and quadratic width for the unchanged restriction, remain open. The bounded-density improvement applies to the actual conditioned posterior; it is not asserted for arbitrary laws with only a relative-entropy bound.

**Status:** conventional proofs with independent AI-agent mathematical reviews; **not Lean formalized**. The quartic argument includes the target-cylinder, compression, posterior-tail, and statistical proofs. The all-scale argument imports explicitly stated active-direction and whitened-reconstruction estimates from the [earlier paper](../improved-polynomials/original-support-all-scales/), and proves the new density, Gaussian-factor, and quantization steps. Existing Lean sources and their earlier degree-46 theorem are unchanged.

Build with `bash build.sh`. Generated intermediates stay in the ignored `build/` directory.
