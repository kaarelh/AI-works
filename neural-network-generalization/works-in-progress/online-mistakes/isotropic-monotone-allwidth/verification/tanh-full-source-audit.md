# Independent full-source mathematical audit

Reviewed on 7 November 2026 by the `tanh_nonlinear` research agent. This is an AI mathematical audit, not formal verification or an external referee report.

The complete source `../source/paper.tex` was read, with a final check of the ready snapshot and its subsequent endpoint corrections. Audited source SHA-256:

    36252ee3513ab1d17f7db22f5a94c40a66791679624446941d135d41387b7c0a

No substantive mathematical flaw was found. The source proves the stated result for the fixed strictly monotone activation `psi(t)=(2t+phi(t))/3`, with the original isotropic Gaussian energy, strict global margin conditioning, every sufficiently large fixed width, and the actual posterior measure. It does not establish the ordinary-tanh theorem.

## New monotone-activation argument

- The affine part of each ridge has zero projection onto the high-degree code characters. Four balanced sign orientations cancel that affine part exactly and yield the matching `1/epsilon` upper factor for the exact code norm. The same augmented-coordinate construction also justifies norm finiteness for even-support physical characters.
- The added L2 residual statement is proved in the appendix: round a far triangle atom to zero, and a localized one to its pure code character, then use orthogonal projection. Modulo-two reduction applies only to the triangle component; the original affine residue is retained in the network-level argument.
- Conditional on a calibrated logical input, the residual variable has mean zero. The full margin controls its negative part; multiplying by the calibration dual, whose magnitude is at least two at every known logical point, bounds the absolute residual average. No pointwise control is incorrectly inferred from an L2 estimate.
- The affine fourth-moment inequality includes the bias term. The bounds `E|L|>=A/sqrt(3)` and `E[1_U|L|]<=A/4` are valid and yield the stated positive coefficient `eta`.
- The convex-combination proof of the affine/rounding budget is correct: weight `kappa/[sqrt(c)(1+eta)]` makes both coefficients equal to `kappa eta/(1+eta)`. This gives the claimed uniform non-code penalty after the fiber-edge or core-mean argument.
- The chosen core size makes the star excess strictly smaller than that penalty. Projection is used to preserve unknown-label global margins only after the sign has been forced into the code family. The initial calibration remains sufficient after later individual queries.

## Exact optimization, finite widths, and posterior

- The negative Walsh coefficients of the square-root weights, subgroup dual, non-subgroup gap, and strict radical ordering are unchanged from the independently checked triangle proof. The odd `q_i` antichain is sufficient; primality is not required.
- The manuscript consistently distinguishes latent costs `C_v` from neural variation costs `C_v/epsilon`, including the correct-label gap and finite-width energy limits.
- Integer replication is performed separately for all four orientations. Each orientation keeps its exact total coefficient, so the affine cancellation survives unequal integer clone counts. The total desired neuron mass is strictly below one; zero padding yields convergence at every sufficiently large integer width.
- A small readout amplification supplies strict global margins while preserving the energy gap. The Gaussian ball and tail estimates control the entire correct-label event at fixed width, including all tied parameter representations. No bounded-activation compactness argument is used for this unbounded activation.
- The finite collection of rounds permits one width threshold and, at each eligible width, one sufficiently small variance threshold. Padding the width-`8m-4` target teacher ensures every posterior along the full permutation is well-defined.
- The sampling conclusion follows by a finite union bound and needs no independence assumption between prediction draws.

## Teacher, scope, and presentation

- The explicit score has margin at least one. Four oriented neurons per character give width `8m-4`, incoming weights `0, +/-1`, and readouts `+/-3/4`, consistent with the original `C_2` convention.
- The parameter count, Boolean-circuit size, `d=Theta(m^6)`, and displayed-width exponent are correct. The long calibration prefix and potentially very large sufficient width are explicitly stated.
- The remark for fixed `alpha>epsilon>0` is valid after the indicated core-size and readout-replication adjustments. It makes no unsupported uniform claim as `epsilon` tends to zero.
- The bibliography is used only to identify prior study of triangle-wave activations. No prior result is imported into the proof. This audit does not independently assess novelty or the external reference's full contents.
- A minor endpoint issue was reported during review: the small-radius display used a strict inequality at `rho=0`. The ready source now uses the correct non-strict bound and explicitly handles the zero reduced atom. This does not affect the equality classification or the non-code gap.

The 14-page PDF's first page was inspected visually at original image detail. Author order, the alphabetical-author footnote, title, abstract, and displayed activation render correctly. The build log had no Warning/Error/Overfull/Underfull matches at the final check.
