# Independent audit of the new deep mean-field proof

Reviewer: the agent responsible for the ReLU/GELU polynomial-depth merging theorem.
Date: 22 October 2026.

I found no substantive mathematical gap in the following proof fragments and their stated assembly. This is an AI-agent mathematical review, not a Lean proof or human review.

## Audited versions

- `../meanfield-alternative/bulk-tail.tex`: SHA256 `a2fcee8a6f5778a7893df7d41f2c47efe1188f72a65ecc1bf889ffce8387f2f0`.
- `../allgamma/meanfield-atoms.tex`: SHA256 `4146c33679e0e6cebd3cc44120ec39966a2750ec4b919953474ad5b9a50bf4e7`.
- `../common/generic-meanfield-atoms.tex`: SHA256 `5d0b93286d4543c85318d0e6c852f430dbe4ea675b32a459a0bdedf19c7cd421`.
- `../allgamma/meanfield-closure.tex`: SHA256 `d5d9dbc39414171f3163ad10ef991f6c4b3386d2a800ebb145c68973e49bd913`.
- The auxiliary neuronwise-activation capacity section of `../common/source/paper.tex`: file SHA256 `e5ab822f8f61ddc7a577ebbce45a2977b2fc8c509ab988b0226f0d31e10f7283`.

## Main adversarial checks

**No concealed exponential input-set factor.** Gaussian isoperimetry is applied after whitening on the support of the covariance, and its distance tail has no rank factor. The smooth cutoff derivative sums depend on the number of inputs only through its logarithm. The RKHS certificate bounds the coefficient vector's l1 norm without a smallest-eigenvalue assumption. Dense certificates over the full Boolean cube select fixed network weights; their length is not a parameter count in the resulting network. Every selected weight has a magnitude bound using the certificate's l1 norm, without an input-set cardinality factor.

**The weighted-covariance induction represents a feedforward network.** Nonnegative feature coefficients enter Gaussian incoming weights through their square roots and atom incoming weights directly. A cutoff selected for a whole Gaussian row is a single coefficient, not an operation evaluated on each test input. The reconstruction can use both Gaussian-bulk and atom neurons at the same hidden layer. Zero-width padding preserves functions because every physical activation vanishes at zero. The original learner still uses its original fixed activation.

**The arbitrary auxiliary activation class is controlled.** Standard fixed-activation contraction alone would not suffice. I checked the supplied scalar activation cover, its entropy bound, rowwise norm normalization, exponential convex-contraction inequality, and the resulting m^(-1/3) Rademacher bound. Together they bound the union over all neuronwise zero-at-zero Lipschitz activations. The capacity theorem consequently applies to the generic tail-atom construction.

**The reconstruction has polynomial finite weights.** The bounded tilt density is at most exp(2 G F0) relative to the latent Gaussian. Its logarithm, not its value, enters the chosen coordinate bound. Hoeffding covariance concentration and simultaneous Gaussian-coordinate bounds have intersecting positive-probability events. Atom weights have deterministic bounds from the RKHS certificate. At fixed depth these bounds remain polynomial under the backward precision recursion and forward physical-network construction.

## Constants and closure

- The Gaussian projection energy bound uses `E exp(distance^2/4) <= 2` and has failure probability exp(-N q).
- The generic tail approximation costs at most `6 lambda^2 B M A/T`.
- The sparse observable-dual event is valid after normalizing its bounded coordinates. With `q=4K` and the stated width threshold, its failure probability is at most exp(-N K).
- The listed one-step approximation errors sum to at most alpha/2, leaving slack in the claimed alpha tolerance.
- The atom count 8192 and certificate constant 512 correctly specialize the generic atom proposition at target accuracy alpha/8.
- The bulk sample count 1024 gives covariance failure probability below 1/8 even for signed outer-product entries. The displayed latent Gaussian bound gives total coordinate failure probability at most 1/8.
- The backward reciprocal tolerances, diagonal bounds, width thresholds, reconstruction widths, and weight bounds are polynomial in d and K for each fixed depth and Lipschitz constant.
- The readout event `E_v <= 8K` implies RKHS norm squared at most 8K. Approximation accuracy 1/8 gives certificate l1 norm at most 16K. Covariance accuracy `1/(128K)` adds at most 1/8. Doubling the final readout converts the total 1/4 output error into a strict margin above 1/2.
- The reconstructed equal-width network has the claimed normalized energy bound.
- The raw exceptional probability divided by the teacher-cylinder mass bounds the posterior outside one common finite function class for all sufficiently large widths. Direct prior-mass Occam bounds cover the finitely many smaller widths. Their union gives the stated simultaneous all-width learning theorem.

No assertion of polynomial depth dependence is made for this unrestricted theorem. The polynomial degree may depend on depth. The separate merging-prior theorem supplies polynomial depth dependence under its additional support restriction.
