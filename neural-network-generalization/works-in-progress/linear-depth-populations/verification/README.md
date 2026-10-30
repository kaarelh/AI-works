# Review and verification scope

The [paper](../paper.pdf) contains three conventional learning theorems. None is Lean formalized.

| Result | Condition and scope |
|---|---|
| Nearly parameter-count learning | Balanced population averaging must preserve clipped outputs, satisfy the architecture-calibrated readout-energy count, and retain finite internal-noise robustness in the averaged model. |
| No depth logarithm | A stronger per-layer disturbance budget and a Euclidean-ball parameter count give `O(C²L log⁵(2+C))` at fixed other resources. |
| Literal quadratic width and linear depth | Global margin, digital saturation and relative gate margins, and a logarithmically weighted population-energy count give the explicit `dC+LC²` polynomial. This is a different support condition, optionally intersected with original internal-noise robustness. |

Each conclusion is uniform over every `N≥C` and every `0<t≤1`, includes finite mean field, permits arbitrary common iid training/test laws, and handles posterior mixtures. Boolean width includes constant wires at each stage; `C≥2`. The digital theorem requires global output-margin conditioning for exact sign transfer; the analog theorems do not.

Independent AI-agent mathematical checks examined:

- The exact interpretation of rounded weights as post-activation/output disturbances, with no product of layer norms.
- The Gaussian target cylinder, its invariance under averaging, and the averaged model's **own** readout-energy radius.
- Adaptive-partition Gaussian tails, padding and coefficient covers, and the common sample event across widths and scales.
- The constant bulk cutoff and product of independent layer-success probabilities, which remove depth logarithms from target gain.
- Constant-radius `ℓ₁` nets for normalized digital gate rows. Their cardinality is at most `33^m` in row dimension `m`, and the post-rounding signed margin remains positive.
- Saturation and relative row margins throughout the target cylinder, including the first layer, internal group coefficients, and readout.
- The population-count inversion and the universal envelope, including its dimension, calibration, accuracy and confidence terms.
- A fresh-reader review of the integrated manuscript and the distinction between the analog and digital prior supports.

One presentation issue was corrected during review: the digital event is not asserted to imply ordinary internal-noise stability. Its theorem permits imposing both; the target cylinder supplies their intersection. The finite digital nets may have real coordinates: this is a finite-function-class counting theorem, not a rational bit-encoder or efficient algorithm claim.

These checks are not external human peer review. No experiments on trained networks were performed, and no practical numerical tightness is claimed. The readout-energy calibration is a deliberate part of the new prior. The result does not establish quadratic width for the original robust support alone.

The [collection publication record](../../../verification/depth-improvements-2026-10-29.md) and [build/hash record](../../../verification/depth-improvements-2026-10-29.json) identify the reviewed source, isolated rebuild, and unchanged Lean scope.
