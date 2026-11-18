# Independent mathematical review

Reviewed 18 November 2026 (UTC). This record concerns the current standalone manuscript and the exact files listed in `independent-review-hashes.json`. It is an independent AI-agent mathematical review, not a Lean formalization or a guarantee against every possible error.

## Verdict and scope

No substantive mathematical gap was found in the main fixed-dimensional raw oracle theorem, the sharper tanh theorem, the clipped-output corollary, or their stated growing-comparator consequences. The theorem statements match the proof constructions. The result concerns actual finite Gaussian posteriors on one dense architecture at each width; neither a prior over network sizes nor a support restriction is introduced.

The review checked the common event over every learner width and every Gaussian scale in (0,1], including all canonical exponents gamma >= 1. A comparator is fixed before sampling; applying the statement to a population-risk minimizer of a compact capped class is valid. The same event is not claimed to be uniform over an unrestricted continuum of comparators. The posterior mean is the ordinary raw mean unless the clipped-output corollary explicitly changes the prediction convention.

## Calculations checked

- Gaussian first-layer, readout, and internal operator-norm tails at speed omega=N/tau^2, with K>=128; integration gives the exponential moment of the continuous maximum norm. The cover is a deterministic family of nearest-spatial-net-point functions, independent of width and scale.
- The elementary finite-class relative Bernstein inequality: loss bounded by b, variance at most b times population risk, followed by solving the square-root self-bound. The displayed constants 3 and 4 are conservative. No external SST theorem is required.
- Balanced cloning at every N>=m, including activations with nonzero phi(0); its exact output identity and weighted Gaussian energy. Nonempty clone groups avoid any padding assumption.
- The teacher cylinder constrains only first-layer/readout coordinates and internal projections onto clone-constant subspaces. Conditional coordinates remain centered unit-subgaussian. Two sphere nets control the remaining internal operators. Gaussian translation of the centrally symmetric event gives the exact mean-energy cost. The normalized error recursion proves the claimed uniform approximation, including arbitrary fixed globally Lipschitz activations with nonzero phi(0).
- The second and fourth prior moments with affine growth |phi(u)|<=A(1+|u|), the sample-independent evidence lower bound, and weighted population-risk tails outside the empirical-risk and norm truncations.
- The posterior entropy inequality pays the term lambda*K/16. Combining it with the exact Gibbs variational identity preserves coefficient one on the comparison risk.
- For general activations, the finite-cover sample power is p=(H+1)(d+2)/2. The maximum over dyadic norm shells has order lambda^(-p); the confidence contribution is dominated. The fixed-resource raw excess is therefore n^(-1/p), up to logarithms.
- For tanh, bounded last-layer coordinates reduce the loss range to order K. Maximizing K^[1+d(H+1)/2]/(epsilon+lambda*K)^(d+2) gives the stated two-parameter sample budget and fixed-resource power max{d+2,1+d(H+1)/2}. The tanh moment bound 24 follows from R<=2r+2 with r=N||v||^2 and prior moments E r<=1, E r^2<=3.
- For clipped individual outputs, the loss range is constant; the power becomes max{d+2,d(H+1)/2}. The posterior still uses raw empirical square loss. The proof does not conflate averaging clipped draws with clipping the raw posterior mean.
- The growing-class powers account for both the energy penalty and the comparator Bernstein terms. With joint width and weight caps n^alpha, the generic sufficient range is alpha<1/(4p); the tanh two-parameter calibration gives alpha<1/[4+2d(H+1)]. With fixed weight cap the corresponding width exponents double.
- Jensen's inequality transfers Gibbs risk to raw posterior-mean risk, and the finite fourth moments ensure these raw means exist.

## Standalone and interpretation checks

The manuscript now defines the forward recurrence, loss, Gaussian scales, weighted energy, and balanced-cloning construction explicitly. Its abstract's L is the total affine-map count H+1, matching the theorem rates. It distinguishes actual finite posteriors from limiting learners and states that the dimensional constants may be exponential. The linear dependence of the sample exponent on depth is not a joint polynomial width-depth guarantee. The coefficient cap, likelihood calibration, IID condition, and nonzero additive remainder remain substantive assumptions.

Root and `source/` TeX copies were byte-identical at review time. Source/PDF hashes are recorded separately. The author's build record reports a clean two-pass build; this review is mathematical and source-correspondence review, not an independent Lean check.

## Biased-comparator compilation addition

The final compiler remark was independently checked. For any fixed activation that is not identically zero, choose a0 with c=phi(a0) nonzero. A constant neuron per hidden layer, using first preactivation a0 and subsequent self-edge a0/c, supplies every internal and readout bias by an edge b/c. The coefficient factor max{1,|a0|,|a0/c|,1/|c|} covers all new entries, preserves depth, and requires width m+1. It equals one for ReLU with a0=c=1 and two for tanh with c=1/2. This modifies only the comparator representation, not the learner prior. The identically-zero activation is correctly excluded only from this remark. Source/PDF hashes were refreshed after the clean rebuild.
