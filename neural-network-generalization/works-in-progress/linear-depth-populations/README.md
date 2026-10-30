# Quadratic-width and linear-depth learning with stable populations

[Paper (PDF)](paper.pdf) · [LaTeX source](source/paper.tex) · [Mathematical review and verification scope](verification/README.md)

For a layered Boolean teacher of width `C`, `L−1` gate stages, and input dimension `d`, a suitably restricted Gaussian tanh Bayesian learner has sufficient sample size

$$
n\ge\frac A\varepsilon\left[(1+c^2)^2(dC+LC^2)+\log^2(6/\varepsilon)+\log(1/\delta)\right]
$$

for an absolute constant `A`. With probability at least `1−δ` over iid training samples, correct-label posterior probability is strictly greater than `2/3` outside test mass `ε`. One sample event works at **every learner width `N≥C` and every positive scale `0<t≤1`**, hence throughout `γ≥1`. There are no hidden logarithms of `C` or `L` in this bound. The constants are not optimized for practical sample counts.

This literal bound uses a **digital-population prior**. The Gaussian prior is conditioned on a global output margin and on the existence of balanced neuron populations such that:

- Averaging the populations preserves clipped predictions within `1/16` on the Boolean cube.
- Every averaged hidden activation has absolute value at least `15/16`.
- Every averaged gate and the readout has preactivation magnitude at least one fifth of its incoming row's absolute weight sum.
- The population count `q` obeys `λ q log²(2+q) ≤ N‖v‖²`, with architecture-only calibration `λ=(d+L)(1+log(d+2))`.

The condition does not use the target, its width, or its labels. Every eligible Boolean circuit has a positive-Gaussian-mass implementation satisfying it. Constant wires count toward `C`, with a reserved constant wire at every stage; the paper uses `C≥2`. The same theorem permits retaining the original internal-noise restriction with calibration `c`.

The assumption is strong: it asks the merged network to behave like stable digital logic. The logarithmic population-energy calibration is a deliberate additional choice. Neither property is established as typical of trained networks, and the theorem is not a quadratic bound for the original internal-noise prior alone.

The paper also proves two analog variants:

| Condition after population averaging | Joint width–depth sample order at fixed other resources |
|---|---|
| Robustness on the usual calibrated aggregate internal-noise ball | `O(C² L F² log(2+CL))`, where `F=1+log²(2+C)+log(2+L)` |
| Robustness under a full calibrated perturbation at every layer simultaneously | `O(C² L log⁵(2+C))`, with no depth logarithm |

These variants allow nonsaturated hidden states and use the linear population-count calibration `q≤1+N‖v‖²/(d+L)`. Global-margin conditioning is optional for them. They control posterior-average margin failure, from which confidence guarantees follow. The analog and digital conditions are different restrictions, not asserted implications of one another.

The proof avoids multiplying approximation errors through layers. For the analog variants, rounded weights are exactly represented as internal disturbances of the robust averaged model. For the digital variant, constant-radius nets of normalized gate rows encode the entire sign function with `O(dq+Lq²)` complexity. A Gaussian readout-energy tail bounds the required number of populations independently of learner width.

**Status:** conventional proofs with independent AI-agent mathematical reviews; **not Lean formalized**. Existing formalizations in this collection do not certify these new support conditions or bounds. No efficient posterior inference algorithm is asserted.

Build with `bash build.sh`. Generated intermediates stay in the ignored `build/` directory.
