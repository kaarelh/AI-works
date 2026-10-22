# Better polynomial bounds for NNBayes

Four research papers with independent AI-agent mathematical review. Each paper lists its authors alphabetically, using ChatGPT-6 Astra for the OpenAI model credit. Papers using the inherited robust construction also credit Claude. These results are **not Lean verified** and have not received a full human mathematical review.

The earlier [robust-prior paper](../../main-results/robust-polynomial-depth/) gives a polynomial-depth theorem at every mean-field-or-stronger scale. Its conservative manuscript budget has degree 510 in the sum of the parameters; the more conservative [formal construction](../../lean/VERIFICATION.md#generalization-under-a-robustness-restriction-scope-and-correspondence) has a checked degree-10974 budget. The papers here obtain much smaller powers, including under the original restriction throughout the entire `gamma >= 1` regime.

| Paper | Guarantee | Scope that matters |
|---|---|---|
| [A sharper polynomial learning bound for NNBayes on robust networks](original-support-all-scales/paper.pdf) · [source and build](original-support-all-scales/) | `O(C^6 log^13(2+C))` at fixed remaining parameters, and a conservative joint degree-46 envelope. | **Original support condition**, every `gamma >= 1` and every `N >= C`, including finite mean field. |
| [Quadratic-width learning bounds for Bayesian networks with stable neuron populations](neuron-averaging/paper.pdf) · [source and build](neuron-averaging/) | Quadratic dependence on Boolean teacher width, polynomial in depth, at every learner width above the teacher width and every `gamma >= 1`. | Adds a **stronger neuron-averaging support condition**. It is not proved to follow from the original internal-noise condition or to hold for ordinary trained networks. |
| [Low-degree all-width learning bounds for shallow Bayesian neural networks](shallow/paper.pdf) · [source and build](shallow/) | A sample bound affine in the teacher's weighted squared norm, with a dimension overhead, at every eligible learner width and every `gamma >= 1`. | Covers the raw Gaussian prior as well as the globally margin-conditioned and shallow robust priors. Training still requires a positive output margin. Quadratic teacher-width dependence needs bounded readout coefficients; the original larger coefficient class gives a quartic sufficient bound. |
| [A quartic-width learning bound for Bayesian networks stable under internal noise](original-support/paper.pdf) · [source and build](original-support/) | `O(C^4 log^9(2+C))` samples with other parameters fixed; polynomial depth dependence and a `1/epsilon` statistical factor. | Retains the **original support condition**, in the strong-prior regime and at finite scales with `gamma >= 2`. This argument does not supply that rate at `1 <= gamma < 2`. |

## The original restriction across all scales

The [all-scales paper](original-support-all-scales/) keeps the original prior support unchanged and sharpens its entropy compressor. Its complete bound is independent of learner width and polynomial jointly in all the parameters. At fixed remaining parameters it is `O(C^6 log^13(2+C))`; this does not mean that its accuracy dependence is merely `1/epsilon`. The exact formulas and the conservative joint degree-46 estimate are in the paper.

The new rate covers the mean-field endpoint and all stronger priors. Quadratic dependence under this same restriction remains open.

## What the quadratic result assumes

The neuron-averaging prior retains networks admitting a balanced grouping of neurons into at most `1 + N ||v||²` populations per layer, such that replacing weights by their population averages changes every clipped output by at most `1/16`. The grouping depends on the network, but the condition is fixed before observing labels and does not use the target circuit width. This is a structural compressibility assumption. The paper shows that every layered Boolean circuit still has an implementation with enough Gaussian prior mass.

For fixed calibration and accuracy, one bound is

$$
\widetilde O(L^4C^2+L^2d^2).
$$

A different, stronger population-count calibration gives

$$
\widetilde O(L^2C^2+LdC).
$$

The paper also gives a literal quadratic-width envelope for single-output bounded-fan-in Boolean teachers:

$$
n\ge\frac{A C^2S^9+2\log(1/\delta)}{\varepsilon},
\qquad S=2+d+L+c+\log(4/\varepsilon),
$$

for a universal constant `A`. Its proof prunes irrelevant circuit wires before bounding logarithmic factors; it does not hide exponential depth dependence in the coefficient of `C²`.

## The shallow bound

For a width-`C` teacher with hidden matrix `W` and readout `a`, put

$$
\kappa_C=\frac dC\lVert W\rVert_F^2+C\lVert a\rVert_2^2.
$$

The raw and globally margin-conditioned Gaussian priors have a sufficient bound

$$
n=\widetilde O\!\left(\frac{d(\kappa_C+d)+\log(1/\delta)}{\varepsilon}\right).
$$

The additive $d^2$ term retains the dimension cost in the target-neighborhood estimate. The shallow robust prior is also covered, with dependence on its calibration. The guarantee holds simultaneously for all `N >= C` and all mean-field-or-stronger scales. It uses signed training outputs above `1/2` and bounds posterior average test-margin failure at `1/4`, hence sign error.

If hidden coefficients are at most `C` and readout coefficients are bounded independently of `C`, the dependence on `C` is quadratic up to logarithms. A second bound is literally quadratic in `C`, with a worse dimension factor. If the readout coefficients may also be as large as `C`, the same argument has a quartic term. It does not prove that the quartic term is necessary.

## Verification, provenance, and open questions

- [Independent mathematical review of shallow and original-support proofs](verification/independent-review.md).
- [Independent mathematical review of neuron averaging and its extensions](verification/neuron-averaging-review.md).
- [Independent review of the complete all-scales theorem and final sources](verification/all-scales-review.md).
- [Second derivation of the improved reconstruction lemma](verification/reconstruction-independent-derivation.md).
- [Initial build and publication record](verification/publication-build.json) and [attribution correction with current builds](verification/attribution-correction-2026-10-22.json).
- [All-layer-margin audit](supporting-notes/all-layer-margin-audit.md): why a standard matrix-cover argument does not yet prove the desired quadratic rate.

The quartic original-support paper adapts the compressor from the [earlier depth report](../depth-supporting-notes/round1-depth-report/); the new paper states its adaptation and the finite-scale consequence explicitly. The old Markov-compression prototype is not published here as another new result.

A quadratic-width bound under the original internal-noise restriction alone remains open. So does a quadratic bound for the full original shallow complexity convention, including readout coefficients as large as the width. Whether useful weaker neuron-merging conditions hold for relevant trained networks is also unresolved.

All guarantees concern ideal Bayesian conditioning. Quadratic dependence is a useful benchmark for dense real-valued networks, but it is not an established optimal lower bound for the bounded-fan-in Boolean teachers: their descriptions can be substantially shorter than a dense parameter array.

To rebuild all four PDFs, run `./build.sh`. Each paper also has its own build script. The builds require a standard LaTeX installation with `pdflatex` and the packages imported by the sources; Pandoc is not needed.
