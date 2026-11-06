# Independent final-source mathematical review

Reviewed on 6 November 2026 by a separate research agent (`wide_tanh`), independently of the manuscript author. This is an informal mathematical audit, not Lean verification.

Reviewed source: `source/paper.tex`, SHA256 `5c707e6a545f287cb0739e6b0dc5dfb9ba6d74c02639ff7ebfcd45bbecb8fc91`.

The full source agrees with the previously checked proof and its stated quantifiers. I checked the following:

1. The model is canonical shallow mean-field scaling at fixed positive prefactor, with training margin greater than one half and no initial global-margin conditioning. This distinction is stated throughout.
2. The one-neuron cumulant is finite and smooth on the full finite-dimensional output space. The feature-span argument, positive Hessian, coercivity of the dual maximization, and smooth strictly convex rate function are valid.
3. Cramer's theorem applies. Strict feasibility and uniqueness give exponential conditional concentration at each history, including histories whose optimum is on the boundary of the strict training event.
4. The entropy tilt identities, projection increment, Gaussian second-moment bound, and Hellinger inequality imply the displayed potential payment for every limiting output at or below the test threshold. The constants `16`, `64`, and `256` match the definitions.
5. Finiteness of the domain gives a common sufficiently large width over all histories and test points. This proves the claimed deterministic confidence-mistake count, and the expectation and high-probability bounds for fresh posterior sampling, uniformly over adaptive input orders. No quantitative or polynomial width threshold is claimed.
6. The Gaussian mixture around a doubled teacher has strict signed mean above three quarters. Its stated KL bound follows from the Gaussian formula and convexity under mixing, without a spurious mixture penalty. At fixed weight bound and prior prefactor it gives the stated `O(d^4 + C^4)` total-mistake bound.
7. The scope section correctly excludes the globally conditioned learner, a uniform zero-prefactor limit, zero-margin training, and an unproved ReLU extension.

No mathematical correction remains outstanding.
