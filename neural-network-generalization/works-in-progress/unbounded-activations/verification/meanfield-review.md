# Independent audit of the deep mean-field closure

Reviewed on 22 October 2026 by the activation-review agent. This is ordinary mathematical review, not Lean verification.

## Scope and conclusion

The generic auxiliary-activation construction and the written finite-width closure prove the stated deep gamma=1 learning theorem for every fixed globally Lipschitz activation vanishing at zero. The original Bayesian learner uses a single fixed activation throughout. The finite reconstructed networks used to count Boolean functions may use different zero-at-zero activations of the same Lipschitz bound. This distinction is valid and essential to the generic formulation; these reconstructions are not asserted to be fixed-activation implementations.

No mathematical defect remains in the reviewed closure. A stagewise diagonal-bound issue was identified independently by this reviewer and the converse reviewer, and corrected before the hashes below: layer s uses M_(s-1), and its projection event proves the next bound M_s. A common maximum is not substituted into every projection step without accounting for its effect on the induction.

## Bounded bulk and Gaussian projection

Metric projection in the RKHS norm onto the sup-norm ball is measurable. Gaussian isoperimetry applies on the support of a singular covariance as well as for a positive definite covariance. The projected remainder has an exponential squared-RKHS-norm moment at most two, giving the stated empirical energy tail. Its cutoff support forces the remainder norm to be at least T/(2 sqrt(M)), which yields both tail-count and tail-first-moment estimates.

For arbitrary lambda-Lipschitz phi with phi(0)=0, replacing phi(Z) by phi(u) on the tail changes each feature by at most lambda B. Writing u=delta v and psi_delta(t)=phi(delta t)/delta transfers the squared delta into the nonnegative covariance coefficient. Each psi_delta has the original Lipschitz bound and vanishes at zero, regardless of how large delta is. The total coefficient mass is at most A. The covariance error is at most 6 lambda^2 B M A/T.

The global smooth cutoff has bounded first- and second-derivative entrywise sums independent of the input-set cardinality except for log(m). Gaussian convolution of a globally Lipschitz activation gives the asserted uniform approximation, first-derivative bound, and second-derivative bound. The smoothed activation is only used to choose a bounded tilt; actual sampled neurons evaluate the original zero-at-zero activation. Thus no offset introduced by smoothing enters the reconstructed network.

The Gaussian interpolation formula for the tilted expectation is valid. Writing the derivative as a tilted expectation plus a covariance avoids any reciprocal-partition-function estimate. Its constant is polynomial in the cutoff and tilt budgets. Singular covariances follow by regularization and dominated convergence because all cutoff observables and their relevant derivatives are bounded.

## RKHS certificates and generic atoms

The finite-dimensional KKT argument for the l1 certificate is sound in the support RKHS, including singular Q. Strict feasibility is supplied by the original vector. Complementary slackness gives eta ||beta||_1 = <v,u>_Q - ||v||_Q^2 <= 1/4 for a unit-norm target.

Sampling the generic atoms is valid even when their outer-product entries can be negative. Their range length is at most 2 lambda^2 M; the sample-size constant 128 leaves ample room in Hoeffding's inequality. The same beta vectors work uniformly over every entrywise-close positive semidefinite Q'. The incoming-weight formula is an ordinary linear combination of the previous layer's features. No table lookup over the input set is performed during evaluation.

The capacity theorem already permits arbitrary neuron-specific zero-at-zero Lipschitz activations. The per-layer normalization remains valid with different activations in different rows, and the scalar cover controls all such choices before the Rademacher signs are drawn. Therefore its count is a single fixed count over an enlarged auxiliary function class, even if the chosen activations depend on the realized network or the entire input cube.

## One-step error and probability budgets

The cutoff-tail, smoothing, and entropy-certificate errors are each at most alpha/16. The transported bulk costs at most alpha/16; the generic atoms cost at most alpha/8. The bulk finite sample and its replacement by actual activation outputs each cost at most alpha/16. Their sum is strictly below alpha.

With q=4K, the threshold N>=ceil(2s log(2m^2+1)/q) bounds the entropy failure by exp[-N(2K-1/2)]<=exp(-NK). The projection failure is even smaller. These estimates are conditional and uniform in the previous covariance satisfying its stagewise diagonal bound. No independence of adaptively selected certificates is assumed.

The tilted sampling law on the underlying Gaussian coordinates has density ratio at most exp(2GF0). The displayed R_xi bounds every such coordinate with total failure probability at most 1/8, while the finite covariance approximation fails with probability less than 1/8. Their intersection is nonempty. Consequently actual incoming weights are polynomially bounded. Coefficients of the weighted covariance representation stay below max(1,A). The recursion bounding all physical hidden values and all weights is polynomial at any fixed depth, even for sampled features with zero cutoff coefficient.

## Backward tolerances, readout, and finite-width learning

The backward tolerances use the layer-specific moduli r_s. Their reciprocal bounds are a fixed finite composition of polynomial bounds. Forward reconstruction therefore reaches final covariance error at most 1/(128K), with polynomial layer widths and weights.

On E_v<=8K, the original output is an RKHS vector of squared norm at most 8K. Applying the scaled certificate at accuracy 1/8 gives ||beta||_1<=16K. The final covariance replacement adds at most another 1/8. Since the original signed margin is strictly greater than 1/2, doubling the reconstructed readout restores a strict margin greater than 1/2. Its coefficients are bounded by 32K V B_h. Padding unequal layer widths with zero neurons is valid, and the energy bound [d(d+1)+(L-1)r_*^2] B_*^2 is correct.

Conditional union bounds produce the aggregate exceptional raw mass (2H+1)exp(-NK). Comparing it with the target cylinder controls the posterior complement of one common finite auxiliary function class. The separate small-width prior-mass/Markov calculation and log(4T/(epsilon delta)) term correctly establish the stated simultaneous all-width sample event.

## Reviewed source hashes

- `common/generic-meanfield-atoms.tex`: `5d0b93286d4543c85318d0e6c852f430dbe4ea675b32a459a0bdedf19c7cd421`
- `allgamma/meanfield-closure.tex`: `d5d9dbc39414171f3163ad10ef991f6c4b3386d2a800ebb145c68973e49bd913`
- `meanfield-alternative/bulk-tail.tex`: `a2fcee8a6f5778a7893df7d41f2c47efe1188f72a65ecc1bf889ffce8387f2f0`
- `allgamma/meanfield-atoms.tex`: `4146c33679e0e6cebd3cc44120ec39966a2750ec4b919953474ad5b9a50bf4e7`

These are the independently reviewed fragments. A subsequently integrated manuscript requires a separate integration check.

## Self-contained integrated preliminaries and uniform scale theorem

The final integration files `source/meanfield-preliminaries.tex` and `source/meanfield-atoms.tex` were checked against the preceding arguments. The new self-contained sparse exponential-tilt proof is valid. Every l1-ball point is the mean of a random signed coordinate vertex; Hoeffding and Jensen bound the mean log partition function after sparse averaging. All possible sparse averages belong to one data-independent finite set, so the union bound applies even to an empirically selected maximizer. The first-order maximizer identity and the entropy formula give both the maximum-norm approximation and the entropy bound. An omitted explicit hypothesis c_j>=0 in the generic atom proposition was reported to the author; all applications already use nonnegative weights.

The additional `allgamma/uniform-supercritical.tex` proof was independently derived and audited. It proves a stronger result than the endpoint alone: one fixed-depth polynomial and one training-sample event work for every width N>=C and every scale 0<t<=1, with no deterioration as gamma approaches one.

The mean-field compression ingredients are uniform over t<=1: replace each preactivation covariance by t^2 times the previous covariance, and multiply its auxiliary covariance coefficients by t^2. This only decreases incoming-weight upper bounds and covariance-approximation errors. The readout energy tail also decreases. Consequently the same functional compression class and exp(-NK) exceptional probability apply.

For t below t_*, spectral compression is valid at every width, and its exceptional probability has the same N/t^2 rate as the target cylinder. For t above t_*, the uniform endpoint argument uses a larger but polynomial K_m that dominates the worst target rate. Below its finite width threshold, a total-energy chi-square estimate supplies a third common energy class. This final step avoids a union over the uncountable scale parameter. The sum J_* of the three energy budgets contains all three classes, and the finite-class learning event for that one enlarged class is simultaneously valid for all widths and all scales.

Reviewed uniform fragment SHA-256: `0d1f226cfb7e56910bd8f4e192a64a652fff7390abf62c801004873ffbd8e8bd`.

Reviewed integrated preliminary source SHA-256: `fec67f22f4195dcdc50451c515b56b8e08a125a6dae90533b8c80c78309c267c`.

## Final integrated manuscript sign-off

The frozen complete manuscript and all six final source files were checked together. The product-norm proposition now explicitly quantifies over neuron-specific activations; the class F(K) is consistently defined as the enlarged auxiliary class. The generic atom proposition explicitly requires a finite sum of nonnegative coefficients. Stage-specific diagonal budgets and backward moduli are present. The final uniform-scale theorem uses the same capacity budget as the earlier counting theorem, and the raw-law notation distinguishes t from the original sigma. Removing the separate endpoint-only posterior theorem leaves no logical dependency missing: its functional compression proposition is used directly by the stronger all-scale theorem.

The final theorem gives fixed-depth polynomial sample complexity simultaneously for every N>=C and every 0<sigma^2<=1/N, for any fixed globally Lipschitz activation vanishing at zero and any target satisfying the stipulated bounded-weight teacher premise. The original learner uses its fixed activation. No unrestricted polynomial-depth conclusion or same-activation compression converse for the generic class is asserted.

No unresolved mathematical issue was found in this final integrated version. The final PDF text contains no unresolved-reference markers. The build script checks unresolved references and overfull boxes after three isolated LaTeX passes. This remains an AI-agent mathematical review, not a proof-assistant certification.

Frozen final hashes:

- `source/paper.tex`: `1793ad161334f922f6d32982e14c4ab152ba9a073a6088b1620f067a547c7396`
- `source/spectral-extension.tex`: `bbf8ea4a4a138d9e2cd856ee0185f4bb96d3080a6d512bc407d1d69d49533d35`
- `source/meanfield-preliminaries.tex`: `722eac54ff77fe82f60a2928cac5fd4e7770fa6494e13e13beda7b3ac0319cfa`
- `source/meanfield-atoms.tex`: `df0673be93fe246251ca4c1820332fa254822318b37656b380175ddbbda2d0ca`
- `source/meanfield-closure.tex`: `f20a10b87122f6061bdad2a4e1d408ce1740e6b25d3a6c21cae7d167ac191a1a`
- `source/uniform-supercritical.tex`: `de1104c4f61cc3c6de18e00844dbaf7c287c0b5b7182a9d54eb3ecda83e87da9`
- `paper.pdf`: `66bc84c115f205821c630d5dfa2535069a88ff8e0594daeb7c0f27c1f1bac252`
