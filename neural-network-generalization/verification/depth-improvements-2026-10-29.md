# Quadratic-width and improved-depth results, 29 October 2026

**Historical publication snapshot.** The sequential-quantization manuscript was subsequently extended by the [bounded-density and factor-coding result](factored-depth-2026-10-29.md). The source/PDF hashes in this record’s JSON companion identify the earlier revision, not the current PDF.

Two conventional manuscripts extend the polynomial bounds in the [technical FAQ](../TECHNICAL-FAQ.md#23-what-are-the-explicit-sample-complexity-polynomials-and-are-practical-sample-bounds-close). They do not change earlier paper sources or Lean proofs.

## New results and their distinct assumptions

[**Quadratic-width and linear-depth learning bounds for Bayesian networks with stable populations**](../works-in-progress/linear-depth-populations/paper.pdf) proves three tanh results at every learner width `N≥C` and every positive Gaussian scale `0<t≤1`, including all `γ≥1`:

1. Internal-noise robustness of the averaged population representation gives `Õ(dC+LC²)`.
2. A stronger per-layer disturbance budget gives `O(C²L log⁵(2+C))` at fixed other resources, with no depth logarithm.
3. A digital-population restriction gives the explicit sufficient bound

$$
n\ge\frac A\varepsilon\left[(1+c^2)^2(dC+LC^2)+\log^2(6/\varepsilon)+\log(1/\delta)\right]
$$

for an absolute constant `A`. This is literal quadratic width and linear depth, with no hidden logarithm of either. It controls strict `>2/3` posterior confidence outside test mass `ε`, with sample probability at least `1−δ`. The digital support uses global output margin, saturated merged hidden states, relative gate margins, and a logarithmically weighted readout-energy population count. It does not use the unknown teacher or its complexity. Every eligible Boolean teacher has a positive-Gaussian-mass implementation. It is a different structural restriction from the analog conditions, optionally intersected with original internal-noise robustness; it is not shown to be typical of trained networks.

[**Sharper depth dependence for Bayesian networks stable under internal noise**](../works-in-progress/sequential-robust-quantization/paper.pdf) retains the original support unchanged. Sequential rounding improves:

- `Õ(C⁴L⁸)` to `Õ(C⁴L⁷)` at sufficiently small positive scale at each width and at every finite `γ≥2`;
- `Õ(C⁶L¹⁸)` to `Õ(C⁶L¹⁷)` throughout all `γ≥1`.

The all-scales appendix also gives a conventional degree-45 envelope. The previous degree-46 Lean result remains unchanged. A constant Gaussian bulk cutoff and a product of independent layer-success probabilities remove depth logarithms from the target gain. With `F₀=1+log²(2+C)`, the two sufficient orders are `C⁴L⁷F₀⁴log²(2+L)log(2+CL)` and `C⁶L¹⁷F₀⁶log(2+CL)`.

Here `C` is layered Boolean width including a reserved constant wire at every stage, with `C≥2`; the learner has `L−1` hidden layers. A teacher with fewer stages may be padded with copies. The rate displays hold at fixed input dimension, calibration, accuracy and confidence except where the formula includes these explicitly. Every learning theorem allows any common iid training/test distribution and arbitrary posterior mixtures. No efficient inference claim or optimality lower bound is made.

## What was checked

Independent derivations and mathematical reviews checked the target-cylinder probability, target membership in each new support, Gaussian posterior tails, population-count calibration, and width/scale-uniform sample events. The robust-rounding and digital-code arguments received separate checks. A further fresh-reader review read both assembled manuscripts and compared the imported all-scale claims with their original source.

The principal checks were:

- Treat rounded weights as exact internal disturbances evaluated on the already rounded states, rather than propagating an external error through subsequent layer norms.
- Preserve independence from fresh source samples in the quartic construction and preserve bounded-prefix/future-entropy hypotheses in the all-scale construction.
- Keep the averaged model's own readout-energy radius distinct from that of the original network.
- Check the digital gate margin after Booleanizing hidden states and rounding normalized rows. Constant-radius `ℓ₁` nets give at most `33^m` choices for a row of dimension `m`; their finite count does not require a rational bit encoder.
- Use global margin for the digital theorem's exact transfer from averaged signs to original signs. It is optional for the analog margin-risk theorems.
- Keep the analog and digital support definitions distinct. Review corrected prose that could have implied an unproved inclusion between them.
- Recheck the confidence conversion and all parameter dependencies. A bound on Gibbs error is not silently equated with posterior-majority error or exact boundary behavior of weak posterior limits.

Detailed scope is recorded with the [population paper](../works-in-progress/linear-depth-populations/verification/README.md) and [sequential-quantization paper](../works-in-progress/sequential-robust-quantization/verification/README.md). These are AI-agent mathematical reviews, not external human peer review. There are no new empirical training claims.

## Formalization and reproducibility

Neither new paper is Lean formalized. Existing Lean source files are unchanged, and no Lean rebuild or extension of their coverage is claimed. The all-scales appendix states the active-direction and bounded-prefix reconstruction estimates it imports from the earlier manuscript; its sequential-rounding modification is proved separately. The stronger-scale quartic argument and the stable-population arguments give their target, coding, and posterior proofs within the new manuscripts.

The [build and hash record](depth-improvements-2026-10-29.json) records clean source builds, independent isolated rebuilds with matching extracted PDF text, and source/PDF hashes. The collection catalog, local Markdown links, FAQ headings and anchors, and checksums are checked for publication. The catalog now contains 68 canonical manuscripts; the earlier 66-paper review records remain historical snapshots of their stated sources.
