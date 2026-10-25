# Gaussian-controls proof notes

The authoritative assembled statement is the [Gaussian-controls companion](../gaussian-controls.pdf), with [source](../source/gaussian-controls.tex). These selected derivations retain their research chronology and audited snapshots. Absolute workspace paths in a note identify the original research snapshot; the corresponding repository dependencies are listed in the [build record](../verification/gaussian-controls-build.json).

The result concerns Gaussian variational controls, including nonzero means and changing input variances. Its useful critical corollary uses the Gaussian scalar baseline `V_*^G`. The strict inequality `V_*^G > V_*` rules out an interpretation as a near-unrestricted-baseline posterior theorem.

| Derivation | Role | Review |
| --- | --- | --- |
| [Near-copy scalar formulas](near-copy-scalar-formula-compiler.md) | Coordinate copying, Hilbert–Schmidt corrections, and charged scalar trees | [Independent audit](../verification/near-copy-scalar-formula-independent-audit.md) |
| [Gaussian Fock scalar formulas](gaussian-fock-scalar-formulas.md) | Weighted Hermite tails and degree-dependent child averaging | [Independent audit](../verification/gaussian-fock-scalar-formulas-independent-audit.md) |
| [Moment floors and finite bits](fock-moment-floor-finite-bits.md) | Artificial noise and normalization without a lower bound on coordinates | [Independent audit](../verification/fock-moment-floor-finite-bits-audit.md) |
| [Fourier-factory finite bits](fourier-factory-finite-bits.md) | Conditional noise handles cancellation and arbitrary importance coefficients | [Independent audit](../verification/fourier-factory-finite-bits-independent-audit.md) |
| [Variable-diagonal Gaussian formulas](variable-diagonal-gaussian-scalar-formulas.md) | Exact pointwise variance tracking and Gaussian covariance controls | [Joint precision audit](../verification/variable-gaussian-and-fourier-precision-finite-n-audit.md) |
| [Noncentral Gaussian formulas](noncentral-gaussian-scalar-formulas.md) | Gaussian means, two-variable factories, and joint control budgets | [Independent audit](../verification/noncentral-gaussian-scalar-formulas-audit.md) |
| [Gaussian baseline gap](gaussian-scalar-baseline-gap.md) | Strict gap, own-baseline occupation, and exclusion near the unrestricted baseline | [Independent audit](../verification/gaussian-scalar-baseline-gap-independent-audit.md) |
| [Own-baseline nonvacuity](gaussian-own-baseline-nonvacuity.md) | Gaussian target-component construction from the prescribed input, with exact depth | [Final manuscript audit](../verification/gaussian-control-manuscript-occupation-audit.md) |
| [Quantified Gaussian PNC¹ corollary](all-gaussian-path-pnc1-corollary.md) | Kernel semantics, action infima, nonattainment, and posterior scope | [Final assembly audit](../verification/noncentral-gaussian-and-manuscript-finite-n-audit.md) |

The smaller coordinate subclasses in the early derivations are intermediate steps, not extra assumptions of the final theorem. The final manuscript and its last audit entries include the noncentral, varying-variance, and Gaussian-own-baseline extensions. No numerical estimate of the baseline gap is used as a proof premise.
