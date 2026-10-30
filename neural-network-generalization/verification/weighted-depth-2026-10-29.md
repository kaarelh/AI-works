# Gaussian-weighted coding and a uniform cold-scale bound, 29 October 2026

The revised [paper](../works-in-progress/entropy-metric-compression/paper.pdf) proves the following sufficient sample orders under the unchanged internal-noise restriction:

| Regime | Bound, up to logarithms |
|---|---|
| Every `0<t≤1`, hence every `γ≥1` | `C⁴L⁹` |
| Every `t²≤N⁻³ᐟ⁴`, hence every `γ≥7/4` | `C⁴L⁸` |
| Every `t²≤N⁻¹`, hence every `γ≥2`; also every `t²≤u_c` for the positive width-independent ceiling below | `min{C⁴L⁷,C⁹ᐟ²L⁶}` |

All statements are simultaneous over every eligible learner width `N≥C` and the stated scales. The teacher is a layered Boolean circuit of width `C≥2` and `L−1` gate stages, with the reserved constant wire and compilation overhead counted. A shallower teacher may be padded, using the learner's actual depth in the formulas. The displayed rates fix input dimension, robustness calibration, accuracy, and confidence; the manuscript supplies full budgets. Training and test inputs have any common iid law.

The risk is posterior-average failure at test margin `1/4`, after fitting every training label with margin strictly greater than `1/2`. The pointwise confidence conclusion follows from `D{x: Q(f(x)z_w(x)>1/4)≤2/3}≤3R(Q)`, using risk tolerance `ε/3` with the original confidence parameter `δ`. Optional all-input absolute-margin conditioning is label-independent.

## Gaussian-weighted finite descriptions

The new [weighted entropy proof](../works-in-progress/entropy-metric-compression/source/weighted-entropy.tex) changes the comparison distribution on finite descriptions, **not the Bayesian learner's prior**. Its uniformly sampled variance-estimation rows are assigned their quantized Gaussian reference probabilities. Their relative entropy is at most the sampled fraction of the full Gaussian row-block entropy. The pilot, correction, metric, and readout parameters remain in an ordinary finite description.

Independent AI-agent audits checked:

- The uniform-subset relative-entropy inequality, proved by the chain rule and convexity without assuming exchangeability of rows.
- A fixed reference law after padding the actual active rank with unused independent Gaussian coordinates. Padding occurs before the same clipping and rounding map is applied to every row.
- Sampling uniformly from the completed virtual layer. The selected subset does not determine which rows are rounded; an initially considered marked-row construction would have broken this independence and was discarded before publication.
- Enlarging the canonical prefix only with data available to its existing kernel. Earlier uniform row records are then measurable from the prefix, and the conditional entropy estimates combine into one joint relative-entropy bound.
- Keeping generated records on approximation failures, with fresh unused reference records only on the specified density-abort/default branches. There is no hidden conditioning on successful paths.
- Charging the finite parameter record once using `KL(J,Z || Unif(J)×Π_Z)≤log|J|+KL(Z||Π_Z)`, even when the two records depend on each other.
- The finite parameter count: the regression matrix's variance-group columns are zero, so the dominant uniformly sampled rows do not require another full matrix of arbitrary coefficients. Duplicate biased rows may be recorded separately; no learner-width neuron addresses are needed.

The [scale proof](../works-in-progress/entropy-metric-compression/source/weighted-code.tex) uses a finite sequence of dyadic scale ceilings. In each interval it adjusts the variance-estimation count and uses a finite Gaussian reference grid. A raw-posterior branch handles the widths too small for sampling without replacement or for the message overhead. The coldest interval uses the earlier uniform finite code. One tagged reference prior gives a single statistical event for all widths and scales.

The resulting abstract charge is `Õ(LK²/e²)` at fixed input dimension, with the full dimensional and statistical dependence in the explicit budgets. Here `e` is the reconstruction tolerance, not Euler's constant. Substituting `K=O(CLF₀)` and `e⁻¹=O(CL³F₀)` gives the log-retaining sample order `O(C⁴L⁹F₀⁴G²)`, where `F₀=1+log²(2+C)` and `G=log(2+CL)`. The scale-grid probabilities, endpoint cases, small-width cutoff, and statistical allocation were independently checked.

## Positive cold scales independent of learner width

The [spectral proof](../works-in-progress/entropy-metric-compression/source/spectral-code.tex) clamps the singular values of each internal weight matrix at `8t`. The clamped part has operator norm at most `8t`. The remainder, together with the unchanged first layer and readout, has energy equal to squared distance from a convex product set in isotropic Gaussian coordinates.

An elementary Gaussian operator-norm tail bounds the mean squared distance independently of width. Gaussian Lipschitz concentration and the target-cylinder denominator then give a uniform posterior energy cutoff

`K_sp=2(d+2H)+4[D_*+log(2/ε)]`, where `H=L−1`.

With `r_sp=min{1/6,c/√(1+H K_sp)}`, the exact sufficient scale ceiling is

`u_c=r_sp²/(256H)`.

Both the dense and multilevel compressors have bounded full virtual hidden states. At those same states, restoring the clamped matrices adds stacked disturbance at most `8t√(H−1)`. The original network's robustness therefore applies. **No robustness or training fit of the residual network is assumed.** Independent audits checked the Gaussian constants, posterior tail, bounded-state composition for both codes, and common finite-class event.

At fixed ancillary resources, `u_c⁻¹=O(CL³F₀)`. Thus this is a positive interval common to every learner width, rather than only a limit taken separately at each width. It need not contain the entire earlier `t²≤1/N` interval at small widths; the two sufficient regimes are both available.

The [interpolation proof](../works-in-progress/entropy-metric-compression/source/spectral-interpolation.tex) combines this interval with a direct posterior bound. For fixed `γ>1`, it gives

`Õ(min{C⁴L⁹, C⁴L⁷ + C^(2+1/(γ−1)) L^(4+3/(γ−1))})`.

In particular `γ≥7/4` permits `O(C⁴L⁸F₀⁴log²(2+L)G)`. At the endpoint the more precise two-term power is `C⁴L⁷+C^(10/3)L⁸`. The finite Gaussian grid and the event common to all eligible widths and scales were checked independently.

## Scope and publication checks

The stronger-scale depth-six option still has width power `9/2`; a smaller depth power with quartic width uniformly in both resources remains open. Additional investigations of readout tails, energy profiles, and alternative variance estimators did not establish another general exponent improvement and are not used in the claims above.

These are conventional mathematical proofs with independent AI-agent review, **not Lean formalizations or human peer review**. No Lean file or other manuscript's mathematical source/PDF is changed. The prior [entropy-metric review](entropy-metric-depth-2026-10-29.md) remains a historical record of the earlier `C⁴L¹¹` revision. The collection still has 69 canonical manuscripts.

The [machine-readable check record](weighted-depth-2026-10-29.json) records the revised source/PDF hashes, an isolated rebuild with matching extracted text, final LaTeX warnings, link checks, unchanged FAQ headings/anchors, and preservation of earlier formalized files.
