# Verification record

Date: 22 October 2026.

This is a mathematical review record, not a Lean verification claim.

## Frozen manuscript

- Source: `paper.tex`, SHA256 `5b93dfb76c4bee27813359453424175d60e739611c9578dd10f0624983186916`.
- PDF: `paper.pdf`, SHA256 `ef0b0e13e53bbeb8cf5cf3d850678cd819beeaa237270635266075c4d414c881`.
- The PDF has eight pages and was compiled twice with `pdflatex -interaction=nonstopmode -halt-on-error`. The log has no LaTeX warnings or overfull boxes.

## Independent reviews

The root research agent independently checked the complete ReLU theorem and proof. The review checked teacher norm budgets and unequal clone sizes, Gaussian-cylinder mass, closure of the cylinder under merging projections, the union over partitions before witness selection, uniformity of the finite code over all widths and scales, and the literal quadratic-width polynomial. No substantive issue was found.

The common-activation research agent independently checked the GELU extension, including its exact Boolean compiler, constant-wire pair, repeated-input coefficient bounds, positive lower readout-energy budget, normalized population representation, bounded perspective-scale derivative, and finite-grid error recurrence. No mathematical objection was found.

A separate activation-review agent independently checked the GELU extension and its integration with the main proof. This review also covered the Gaussian target-cylinder radius, projection invariance, the zero-population-scale limit, extra population-mass coding parameters, and the ancestral-pruning argument for the literal polynomial. No mathematical defect was found.

The only source change after the final independent reviews replaced the grammatical singular “It does not settle” with “They do not settle”; no statement or proof changed.

## Scope checks

The statement distinguishes:

- The neuron-merging prior restriction from arbitrary internal-noise robustness.
- ReLU learner width at least the counted Boolean width from GELU learner width at least the compiler's doubled width.
- All finite Gaussian scales `0 < t <= 1`, including all `gamma >= 1`, from a claim about other scaling regimes.
- Posterior-average margin error from posterior-majority, MAP, or efficient algorithmic guarantees.
- Layered Boolean-circuit teachers from arbitrary analog teachers.

Every counted constant wire and compilation overhead is explicit. No typical-trained-network claim, unrestricted polynomial-depth theorem, or Lean verification claim is made.
