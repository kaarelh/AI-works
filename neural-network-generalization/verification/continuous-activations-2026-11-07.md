# Continuous-activation online results: publication verification

Date: 7 November 2026. These are conventional mathematical results, not Lean formalizations. Separate AI agents reviewed the mathematics; these reviews are not external peer review.

| Paper | Result and verification scope |
|---|---|
| [Monotone Lipschitz activation](../works-in-progress/online-mistakes/isotropic-monotone-allwidth/) | Standalone proof for one fixed strictly increasing, 1-Lipschitz activation, at every sufficiently large fixed width in the strong-prior limit. Includes every network competitor and the actual posterior. Multiple complete-source reviews checked the new affine calibration argument, exact atomic norm, strict ordering, integer allocation, and teacher bounds. |
| [Bounded triangle wave](../works-in-progress/online-mistakes/isotropic-triangle-allwidth/) | Standalone bounded continuous-activation version with a smaller teacher. Complete-source and component reviews checked the Fourier inequality, quantitative fiber estimate, logical optimization, and finite-width posterior transfer. Publication clarified two zero-perturbation endpoints without changing any theorem. |
| [Exact ReLU AND energy](../works-in-progress/online-mistakes/relu-and-energy/) | Conventional exact-energy theorem and actual posterior identification from the positive vertex and its neighbors. Independent full-source review. It does not bound errors on arbitrary orders. |
| [Four-input ReLU example](../works-in-progress/online-mistakes/relu-fourbit-mistakes/) | Exact-arithmetic computer-assisted proof of fifteen near-certain errors after the first query, at every fixed width at least sixteen. Both optimizer-free certificate checkers were rerun from the publication folder and passed. All 65,536 Boolean completions are covered; no growing-dimension lower bound follows. |

All four PDFs were rebuilt from isolated source copies with matching extracted text and no unresolved references. The first pages were inspected for author order and the alphabetical-order footnote. Per-paper publication records give current source and PDF hashes. The repository inventory checker passed for all 86 catalogued papers and Markdown links.

For the two scalable constructions, the input dimension is `Theta(m^6)` and the designated mistake count is `2^(m-4)`. Calibration occupies `15/16` of the cube; no polynomial sufficient-width bound or width-uniform small-variance threshold is claimed. Ordinary tanh, ReLU, GELU and hardtanh remain open for the growing-family target studied here.

The [method-obstruction notes](../works-in-progress/online-mistakes/isotropic-research-notes/continuous-activations-2026-11-07/) explain why direct sine and tanh transfers need a different argument. They are not online upper bounds. Uncertified exploratory numerical results are not used by any published theorem.
