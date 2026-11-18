# Independent mathematical audit

Reviewed by the independent proof-audit research agent on 18 November 2026. Exact source hashes are in `independent-review-hashes.json`. This is not Lean verification.

The complete current path-prior manuscript passes the audit. No substantive gap was found.

Checked path-flow rescaling with Euclidean first-row masses, removal of zero-flow neurons, the two weighted-Schur identities, preservation of exact function and path variation, and exact equality of first/readout squared norms with P. Equal-group cloning with disconnected leftovers preserves internal absolute spectral norm and Frobenius cost. Final endpoint balancing gives Q=2P exactly at every width above teacher width. The lower energy inequality and the infinite-width variational limit follow with the stated infimum and width quantifiers.

Checked the new normalization omega=N(d+1)+(H-1)N^(gamma+1). Endpoint chi-square degrees divided by omega, total coordinate count divided by omega, and Nd/omega are all at most one; the cloned internal normalized mean cost is at most C/N. This is why no additional learner-width threshold involving input dimension remains.

Checked the conditional-Gaussian transport formula, full uniform-in-input L2 comparison estimate, independence used in the supremum readout-noise estimate, and all constants in the teacher neighborhood. The two-sided function-prior theorem uses the correct different radii, a valid chi-square lower probability bound, and binary relative entropy for the upper probability bound. It does not substitute pointwise RMS for the required uniform-function norm.

Checked dimension-free path capacity on the Euclidean unit ball. The first Rademacher supremum is a Hilbert norm, its mean is at most square root n, and bounded differences gives the stated exponential moment. The subsequent ReLU exponential contractions give only square-root depth in capacity. The raw-risk prior bound, exact free-energy root, common width/scale statistical event, weighted tails, entropy absorption, and population constants match the independently checked quadratic-capacity theorem.

The dimension-free H*(1+P)^2 sample polynomial is correct under the explicit prior normalization. The controlled-gain C^2*H corollary counts endpoint norms correctly. The extension to arbitrary internal precisions retains dimension control and clone mean cost. The source accurately distinguishes its prior-ordering theorem from an exact ordering of every pair of functions, permits every representable ReLU function only after reparameterization, and does not claim unrestricted polynomial dependence on teacher width/depth or efficient inference.

Presentation follow-up (18 November): the abstract now explicitly describes precision-normalized negative log neighborhood probabilities, rather than width-independent absolute mass. The bounded IID label premise is explicit; the soft-prior abstract also states the Euclidean unit-ball domain. These qualifications match the proved model. Only paper.tex changed, and its hash is refreshed; proof modules are unchanged.
