# Shallow paper: main theorem coverage

The main statements of `works-in-progress/improved-polynomials/shallow/source/paper.tex` now have compiled Lean proofs. A clean project-source rebuild and the final collection audit remain pending before public promotion.

| Manuscript statement | Lean theorem |
| --- | --- |
| First boxed sample bound, `16/ε [m h_d + log(1/δ)]` | `BatchTwoShallow.shallow_all_width_all_scale` in `BatchTwoShallowMain.lean` |
| Sharper implicit bound, `64/ε [m(d+1) log(2en) + log(4(m+2)/δ)]` | `BatchTwoShallow.shallow_sharp_all_width_all_scale` in `BatchTwoShallowSharpMain.lean` |
| Explicit sharper bound, `ceil(4T log(8eT))` | `BatchTwoShallow.shallow_explicit_sharp_all_width_all_scale` in `BatchTwoShallowSharpMain.lean` |
| Target cost linear in weighted teacher energy | `BatchTwoShallow.targetCost_le_energy` in `BatchTwoShallowResources.lean` |
| Displayed target-cost bound in first-layer/readout coefficient bounds | `BatchTwoShallow.targetCost_le_width_resources` in `BatchTwoShallowResources.lean` |
| Quadratic sample bound with bounded readout coefficients | `BatchTwoShallow.quadratic_width_sample_bound` in `BatchTwoShallowWidthPolynomials.lean` |
| Quartic sample bound when all coefficients are bounded by teacher width | `BatchTwoShallow.quartic_width_sample_bound` in `BatchTwoShallowWidthPolynomials.lean` |
| Initial support conditioning followed by training | `BatchTwoShallow.posterior_eq_twoStage` in `BatchTwoShallowPriorConventions.lean` |
| Literal `0<t≤1` and `γ≥1` scales | `BatchTwoShallow.good_event_all_t_scales` and `BatchTwoShallow.good_event_all_power_priors` in `BatchTwoShallowPriorConventions.lean` |

The learning statements use actual teacher networks, independent anisotropic Gaussian weight priors, the exact displayed target cost, readout bound and vote count, and a common measurable sample event for every learner width at least the teacher width and every scale `N σ²≤1`. Two support switches cover the raw prior, initial global-margin conditioning, and the original shallow robustness restriction with optional global margins. Training requires signed output greater than `1/2`; the conclusion bounds the actual posterior-averaged test-margin failure at `1/4`.

The proof constructs the target cylinder and halfspace mixture and proves the halfspace capacity and sampling bounds. It uses an indicator at margin `3/8` instead of the manuscript's ramp. Equal clone groups with disconnected padding replace balanced groups without increasing the displayed target cost. Independent pair swaps replace a hypergeometric tail in the relative growth argument. These proof changes preserve the stated main bounds; no analytic concentration or approximation conclusion is assumed as a model field.

`BatchTwoShallowAudit.lean` checks the endpoints' axiom dependencies. The separate [statement review](BatchTwoShallow-independent-review.md) found no substantive mismatch in the model or main budgets. It discloses the reviewer's authorship of a shared concentration helper. This is an AI-agent review, not a human review.
