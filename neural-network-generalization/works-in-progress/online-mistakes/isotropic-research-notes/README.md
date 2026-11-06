# Research records for the unchanged-prior continuous-activation question

These notes record proved obstructions to particular approaches to an exponential online-mistake example for wide neural networks. **They are not online-mistake upper bounds for unrestricted NNbayes, and they do not settle the ordinary-tanh, ReLU, or hardtanh question.**

The common attempted reduction is to identify the network's prediction with the sign of the convex minimum-norm affine separator of the observed data, and to represent the energy minimum by a network whose first-layer rows are all proportional to that separator. The notes show why this route cannot produce the desired exponential lower bound when a bounded, small teacher gives a cheap competing implementation.

- [Shallow ridge obstruction](SHALLOW-RIDGE-OBSTRUCTION.md). For any fixed Lipschitz activation vanishing at zero, a bounded shallow teacher supplies a polynomial energy bound at every sufficiently large width. An affine ridge has energy at least a constant times the affine separator's norm, while each wrong affine prediction forces a definite increase in that squared norm. Together these give a polynomial bound for the proposed affine-ridge reduction.
- [Fixed-depth extension](FIXED-DEPTH-RIDGE-OBSTRUCTION.md). Only the first layer is required to be a ridge; all later matrices may be arbitrary. A product-of-layer-norms bound gives the analogous obstruction at every fixed learner depth. The resulting conditional bound may grow exponentially with depth.
- [Every learner depth, given a fixed-depth teacher](ALL-DEPTH-RIDGE-OBSTRUCTION.md). Sparse teacher embeddings strengthen the comparison. For tanh, the conditional mistake bound is polynomial in teacher complexity and learner depth. For hardtanh, the bound is independent of learner depth. The width requirement is polynomial in teacher parameters when teacher depth is fixed.

Three further notes test other possible shortcuts:

- [Potential and convex-relaxation obstructions](POTENTIAL-OBSTRUCTIONS.md). The globally conditioned tanh posterior can make a near-certain mistake without increasing its minimum energy. Removing the global-margin condition also changes the energy optimum, even on a two-example history. Neither observation settles the total-mistake question.
- [The scalar AND implementation is not optimal](AND-SCALAR-OBSTRUCTION.md). For all sufficiently large input dimensions and then all sufficiently large widths, an explicit two-feature tanh construction has lower canonical Gaussian energy than the best scalar implementation of AND. This rules out a specific energy-optimality claim, not an online-learning theorem.

- [A nonintegral minimum affine margin norm](FRACTIONAL-AFFINE-NORM.md). A nine-variable Boolean threshold function has exact minimum squared affine norm `2405/2`. A rational dual certificate and a standard-library Python verifier establish the value. Thus a proposed argument based on integer-valued affine energy levels would be invalid; this does not show that exponentially many levels exist or can be visited.

A “ridge” has an exact meaning here: if `a` is the minimum affine unit-margin coefficient vector, each first-layer row is `r_j a`, with arbitrary scalars `r_j`. The energy bound permits arbitrary later layers. The online consequence additionally assumes that predictions follow the affine sign; that conclusion is not automatic for arbitrary ridge networks.

The proofs use closed global output margins when discussing energy minimizers. Those minimum energies equal the corresponding strict-cell infima by readout amplification. The notes distinguish the network's imposed output margin from the affine witness's margin; dropping the latter only weakens the numerical mistake bound by a factor of four.

These are research records, not a separate paper or a new main result. They have independent AI-agent mathematical checks and have not been formalized in Lean. The shallow and fixed-depth notes were independently checked by two agents; the full tanh/hardtanh embedding extension was independently checked by a separate agent who reviewed its construction and constants. No numerical experiment is used as a proof.

The [verification record](VERIFICATION.md) identifies the reviewed files and the exact-arithmetic check.
