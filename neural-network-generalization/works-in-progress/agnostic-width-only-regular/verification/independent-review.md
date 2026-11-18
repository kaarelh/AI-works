# Independent mathematical review

Reviewed the five included source modules on 18 November 2026. No substantive gap was found. This is a conventional mathematical audit, not a Lean formalization.

The audit checked the shifted Kuhn-hat partition, coordinate-line variation estimate for arbitrary-weight ReLU teachers, and hierarchical dyadic interpolation improvement. Their width and mixed path-variation bounds are independent of the teacher coefficient magnitudes. The selected shift is deterministic after the existence argument and is not a randomization used by the learner.

The all-width argument was checked separately. The parameter certificate uses a strictly positive measurable likelihood scale, obtained from the small-temperature free-energy limit. The relative bounded-loss inequality integrates against arbitrary data-dependent posteriors, and the confidence allocation is summable across widths. Selecting the smaller of two observable certificates still selects one posterior on one fixed architecture.

The saturated Gaussian appendix was independently checked: norm-tail constants, exponential moment, deterministic Lipschitz cover, shell/accuracy choice, bounded-loss exponent p=max(d+2,d(H+1)/2), weighted objective tail, entropy absorption, and fallback calibration. Saturation is used in BOTH likelihood and prediction; the theorem is not a statement about clipping an ordinary raw posterior mean. The root argument permits any comparison law supplying the displayed free-energy inequality.

The selective Gaussian comparison, path-flow-to-energy implementation, all-gamma normalization, and fixed-comparator Bernstein step were checked. The final sample polynomial follows with A of order kappa^d(C+1)^(h(d+1)) epsilon^(-d), up to fixed-dimension/depth constants and logarithms. The smaller-width parameter bound is dominated by the same budget, yielding every N>=C+1, including the neuron carrying compiled biases. One event covers every such width and every gamma>=1.

Material scope: fixed input dimension and depth, an input density bounded relative to uniform cube measure, bounded labels, a final hard output saturation, no coefficient cap, and no architecture prior. The displayed polynomial has degree depending on input dimension and depth; this is not a dimension-free or jointly depth-polynomial result.
