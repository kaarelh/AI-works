# Independent review of the original-Gaussian raw width-only theorem

Reviewer: independent research agent /root/relu_finite_threshold.
Review date: 18 November 2026.

## Scope

I reviewed the five exact manuscript sources listed in the accompanying hash file. I checked their statistical interface against the previously audited finite-Gaussian direct theorem and the exact sub-Gaussian observation-map transfer. This review does not claim a new independent rederivation of the entire earlier Gaussian dictionary/compression theorem.

The new compiler constructions, raw-output bounds, input-law conditions, and oracle assembly pass the review. No substantive mathematical gap was found. One presentation issue was corrected before this snapshot: all internal/readout offsets now explicitly use the exact constant wire; the learner has no native internal or readout bias coordinates.

## Checks

- The actual prior is the original independent Gaussian family: first-layer variance nu/d, internal variance nu/N, readout variance nu/N². The compiler adds only ordinary neurons and weights, including an exact tanh constant wire. It introduces no deterministic special bias into the learner.
- The likelihood is the original raw-output Gaussian likelihood. Its evidence root is applied to the normalized observable z/M and labels Y/M, then converted back using lambda=M² lambda'. The selected temperature uses no comparator width, coefficients, or unknown risk.
- The common-event assertion over every eligible finite width and every nu in (0,1] matches the imported Gaussian theorem. The label-clipping event is likewise common to that entire family. No union over an uncountable collection of priors is silently inserted.
- The stated upper action bound dominates the imported teacher energy and logarithmic perturbation cost at every fixed depth. Its dependence on m and B is quadratic up to logarithms.
- The Boolean compiler uses signed majority gates with integer margin. Tanh saturation restores accuracy at every depth. A separate exact constant wire implements all offsets, including the raw readout constant. The resulting raw output itself is bounded; this is not merely a clipped-prediction guarantee.
- In the continuous box compiler, every point belongs to at most 2^d expanded boxes. All other soft indicators have total leakage at most the chosen small constant. This proves the global raw envelope 2^d+1 despite a potentially large readout constant and many cancelling indicator terms.
- Signed-copy padding preserves both the negative leakage bound outside an expanded box and the correct signs away from boundary strips. The constant wire is copied separately.
- Coordinate-line variation of a clipped width-C, depth-h ReLU network is bounded by twice its at-most (C+1)^h affine pieces. Shifted-grid averaging and the bounded-density hypothesis give the stated L1 approximation independently of original coefficient magnitudes.
- For slab regularity, activation-region and output-level hyperplanes give a collection of size at most (hC+L+1)(C+1)^(dh). A box-to-corner segment crossing a relevant plane lies in its slab. The mesh, boundary-strip probability, coefficient cap, and exponents d/alpha and max(d/alpha,1/alpha+1/alpha²) follow as stated.
- The sphere examples satisfy the quoted slab inequalities: bounded one-coordinate density for dimension at least three, and square-root endpoint mass on the circle.
- Risk transfer from a bounded raw compiler to the original real-valued teacher is valid with unchanged unbounded labels. On the label-tail event the error is charged to Y², not to an unproved independence assumption. The exact L2 label-tail remainder agrees with the imported transfer theorem.
- A deterministic near-minimizer of the comparison class suffices. It is chosen before the sample in the proof, so the inference rule does not receive the population minimizer or compiler.
- The Boolean, density, and slab growth exponents all satisfy both Gaussian statistical remainder inequalities. The concrete exponents in the final table leave slack, and their compiled widths are o(n).
- The finite Boolean sample bound is polynomial jointly in d and C at fixed teacher and learner depths. Its epsilon exponent controls the second remainder because r_H=v_H/rho_H is at least two.

## Limitations preserved

The raw means and likelihoods are not clipped, but clipping of a comparison function is a proof device. Learner and teacher depths are fixed in the displayed rate exponents. The continuous cases require their stated density or slab assumptions. The simple width condition N>=n is sufficient rather than minimal; the actual threshold is the compiled width. The likelihood variance is evidence-calibrated, not an arbitrary fixed observation variance. The proofs have not been formalized in Lean.
