# Independent adversarial audit of the parallel-complexity barrier

24 October 2026. This is a fresh mathematical audit, not a summary of the previous audit notes. No manuscript or public repository file was edited.

Audited manuscript: `manuscripts/parallel-complexity.tex`, SHA-256 `09d00ad23718f0bf05a12e7c7c011ccf6bdf54cddf27485da3adbd44f431f845`.

Companion: `manuscripts/uniform-target-classes.tex`, SHA-256 `0beb3af4d8b8f93842dcf3f27620289e1c087d24b2741696b81cd983d34c84a7`.

## Verdict and limits of the verdict

I did not find a fatal mathematical or quantifier gap in the audited argument. In particular, the proposed weak points concerning changing maximum-diagonal coordinates, Rao–Blackwellized covariances, canonical projection followed by a residual norm, long nearcritical blocks, and extraction from an actual finite-width event have coherent proofs. Several tempting objections disappear only after retaining exactly the invariants and entropy accounting used in the text; those checks are detailed below.

The product-to-circuit theorem has a substantially shorter dependency chain and is the cleanest independent result here. The all-prefactor posterior converse relies additionally on the stated finite-width Fourier target-mass construction. The sufficiency and all-prefactor lower-bound barrier also rely on the companion intrinsic learning theorem. I inspected those dependencies and their principal constructions rather than treating their prior audit labels as evidence. This remains a human-style proof audit, not formal verification or a proof of every referenced general result, such as the standard polynomial VC bound for tanh networks.

The manuscript does **not** prove or disprove exponential depth necessity for the original class of bounded-weight Boolean teachers. Its strongest conclusions are conditional complexity barriers. Failure of a universal polynomial sample bound is weaker than a stretched-exponential lower bound; the paper correctly keeps these apart.

## 1. Product to parallel circuits

Theorem `thm:main` survives the following independent checks.

1. The inequality `E z(x)^2 <= P_F^2` uses the isotropic augmented input `(1,x)` and zero preservation, so `P_F >= 1` is valid even for a constant target. For a relevant coordinate, an opposite-label cube edge has output difference at least two. Summing the squared first-column lower bounds proves the `P_F^2` junta bound. Randomly fixing irrelevant variables preserves the expected squared first-layer Frobenius norm, including the bias column.
2. The two-ball formula is correct. With leading singular value `alpha`, residual bound `b^2=1-alpha^2`, and center displacement `(alpha^2-b^2)/(2alpha)`, the squared endpoint distances both equal `1/(4alpha^2) <= 1/2`. The convex quadratic then bounds the whole interval. The subsequent Lipschitz map need not send its ball centers to actual network states.
3. Prefix covers retain only polynomially many cells after `O(log(PR))` layers. Choosing actual states doubles the radius but leaves the asserted same-label distance and opposite-label separation with ample slack.
4. In finite-set sampling, paired incoming and outgoing Frobenius norms have product `sum_i ||w_i|| ||v_i||`, no larger than the old product. Sequentially processing the first `h` layers does not undo the width bound of an earlier layer. The telescoping output error uses the current network's product bound at each stage.
5. Normalization by the entire preceding product is essential and is used correctly. The auxiliary activation `phi(S_s u)/S_s` is still zero-preserving and 1-Lipschitz, regardless of the physical size of `S_s`. All lookup tables therefore have polynomial range and precision. Arbitrary noncomputable activations present no obstacle to this nonuniform existence theorem.
6. The majority implementation does not conceal enormous integer weights. Once a layer has been put on the specified inverse-polynomial dyadic grid, the affine coefficients, integer ranges, and table lengths are polynomial in `P`. The lookup resets precision. Squared-distance tests have the same property.

One very small proof-writing point: in `lem:maurey`, the displayed substitution `u=2J sqrt(log(2|X|)/m)` followed by the coefficient 3 uses `1 <= sqrt(log(2|X|))`. This is automatic for `|X| >= 2`, which is the nonconstant cube case used in `thm:main`, but not for a singleton. The lemma itself still follows with the stated coefficient: apply bounded differences directly at threshold `3J sqrt(log(2|X|)/m)`. The union bound is less than one for every `|X| >= 1`; alternatively use coefficient 4 and adjust 9 to 16. This is not a substantive obstruction.

## 2. The posterior-mixture and minimax argument

The sample-to-circuit step is valid under its stated distribution-free quantifier.

* Conditioning on a posterior ceiling event of mass at least `5/6` makes the wrong-label probability at a good input less than `(1/3)/(5/6)=2/5`. Thus a draw from the ceiling class has signed vote greater than `1/5` there.
* `O(d)` draws and a union bound over all `2^d` inputs produce one finite majority agreeing with the target at every good input, not merely on average under the current distribution.
* The class of all such finite majorities is independent of the input distribution. The conclusion `for every D, some g has error <= epsilon` therefore really is a finite minimax statement. It yields a mixture with pointwise advantage `1-2 epsilon`, and a second majority gives the exact full-cube target.
* The proof does not require the ceiling class to be closed under majority or to contain the target itself. Nor does it require a measurable choice of a particular low-product representative: first condition the induced distribution on the finite set of Boolean functions, then select circuits nonuniformly.
* The restriction `epsilon < 1/2` is material. The argument would not establish an exact circuit at the endpoint `epsilon=1/2`.

The learner width and actual scale must be chosen before the input distribution. The collapse corollary meets this condition because its hypothesized polynomial sample count has no learner-width dependence and the uniform ceiling threshold has no prefactor dependence.

## 3. Maximum diagonals and critical occupation

The maximum-diagonal argument does not require one fixed input to attain the maximum at every layer.

At layer `j`, choose an input attaining the new maximum `q_j`, and write its old variance as `p <= q_{j-1}`. Scalar dissipation gives `q_j <= p-cp^2+D_j`. The function `p-cp^2` is increasing on the relevant interval, so this implies the claimed maximum-diagonal recurrence. For a prefix budget at time `i`, choose an input attaining `q_i` and project the entire suffix onto that input. Its remaining hidden costs plus readout cost dominate `V(q_i)`. Changing the chosen input between these two arguments is legitimate: each lower bound is against the same full nonnegative action budget.

The occupation proof also works as written. The reciprocal identity has the right direction:

`(q'-q)/q^2 - (1/q-1/q') = (q'-q)^2/(q^2 q') >= 0`.

The forced-cooling comparison uses a nonnegative forcing sequence with square sum controlled by total entropy. Last-exit bands, rather than first-entrance bands, ensure that after removal of one initial transition their pre-states stay above the relevant threshold. A band's total expenditure is bounded by the prefix budget at its endpoint; it need not be bounded by a difference of potential values. These facts give both the variance sum and the square-root entropy sum.

The imported scalar statements match `critical-rate-foundations.tex`. I checked the monotonicity argument, the small-state bridge, and the strict exponential potential. The extension of the dissipation interval from `[0,1]` to `[0,2]` is justified by the same strict heat inequality and compactness. It does not introduce a new unproved asymptotic assumption.

## 4. Rao–Blackwellization and canonical features

The anchors are selected against the original path. At each layer, replacing the density by its conditional expectation given the Gaussian anchor vector preserves the anchor marginal exactly and decreases entropy. Because every transferred preceding kernel has that same anchor block, the original anchor density remains normalized at subsequent stages. Thus the replacement is a genuine full-cube controlled path, not a collection of unrelated one-query marginals.

Different queries can use different Gaussian couplings for error estimates. This causes no incompatibility: the two full marginal laws being compared are defined independently of the coupling, using the same anchor density. The metric only records the anchor-plus-one-query law.

The canonical map preserves exactly what the next anchor-dependent transition needs: the anchor block, the query-anchor inner products, and each query norm. It deliberately changes other query-query inner products. Including the Gaussian coordinate functions in the projection space makes the linear term lie entirely in that space; consequently the residual can be written as

`(P_V R(u), ||(I-P_V)R(u)||)`.

Projection and the reverse triangle inequality give the claimed contraction bound on residual differences. The residual norm coordinate does not create an uncontrolled Lipschitz term. At an anchor the last coordinate is zero, which is why the query-anchor identities persist.

Ill-conditioned anchor spans do not invalidate either evaluator. The circuits never compute the inverse Gram matrix or the orthonormal basis. Importance sampling bounds the *stored weighted coefficients* directly. In the normalized evaluator, `E ||g||^2/alpha^2 <= K` supplies the requisite integrability even if the physical scale or its inverse is arbitrarily large. The proof gives nonuniform finite constants, which is exactly the conclusion required.

## 5. Finite-width extraction

The bounded-dual certificate is an actual finite-`N` argument. In particular, it does not assume an asymptotic large-deviation principle, exchangeability of the conditioning event, or attainment of a rate infimum.

For a maximizing dual parameter in the box, coordinatewise optimality gives

`lambda_i(q_i-a_i) = B |q_i-a_i|`.

Thus the bounded dual is the tilt entropy plus `B` times the moment error. A finite grid gives the exponential moment uniformly in the conditional Gaussian row law. The readout factor is valid on the covariance range: conditional on the hidden layers, its quadratic rate is a chi-square variable divided by `2N`, including singular covariance cases. Iterated conditional expectation and entropy duality for the raw event then provide one realization with small total cost.

The transfer from approximate to consistent covariances also works. The square-root matrices can be aligned with row distance at most `sqrt(m Delta)`, and any existing embedding can be enlarged and identified with such an embedding. Tilting a joint Gaussian coupling by the old controlled density decreases marginal entropy and amplifies the row error by at most the entropy second-moment gain. Readout projection cannot increase its norm. The required extremely small moment tolerance enters only logarithmically in the dual grid, so the resulting width remains `2^{O(d)} poly(d,n,L)`.

For the posterior ceiling, the raw bad event need not be sample-consistent: bounding the larger raw event and dividing by a sample-specific denominator is valid. The denominator is supplied by the point-memorizer Fourier construction. The contradiction produces a representation of *one of the bad event's realized sign functions*, which is sufficient to rule out the proposed lower bound on that event's raw mass.

## 6. Uniformity near the critical prefactor

This is the most intricate part of the manuscript, but the principal accounting identities check out.

Let `r=q_j/q_{j-1}` and choose an input attaining the new maximum. If `M` is its physical preactivation second moment divided by its own preceding variance, then `r <= M`. Gaussian change of reference yields

`e_j >= D_1(query) + (a/2)[M-1-log r] >= D_1(query)`.

The last inequality follows from `M-1-log r >= M-1-log M >= 0`. It proves nonnegativity and the critical Bellman/dissipation inequalities for adjusted costs. The same identity is valid when the two maximizing inputs differ.

For the entropy upper gain `g_j`, the exact Gaussian identity is

`D_j-c_t = a g_j + (1+a)(exp(2g_j)-1-2g_j)/2`.

Since `q_j/q_{j-1} <= exp(2g_j)`, its nonnegative remainder is at most `e_j`. The argument `g_j <= sqrt(e_j)` is valid, including negative gains. The complementary tangent/last-exit bound controls the accumulated gain when `aH` is large. In the long regime the last-exit estimate supplies a prefix of length `Theta(S/a)` whose *original* hidden entropy is `O(aS)`. In the short regime `Hc_t` is absorbed into `O(S^2/H)`, and the critical occupation proof applies to the raw subcritical costs.

The full second moment, rather than centered covariance, is crucial in the Gaussian/non-Gaussian decomposition. It allows nonzero controlled means and gives

`D(rho || N(0,t^2 I)) = D(rho || N(0,Sigma)) + sum F_t(lambda_i)`.

Rao–Blackwellization does not increase the first term. Project both the original law and its matching Gaussian onto the anchor span; after replacement the complement is an independent free Gaussian. The replacement's matching Gaussian has exactly this product structure, including if the anchor marginal has nonzero mean. Canonical changes of realization preserve this conclusion, because the added unused directions are free.

For a Gaussian-good block, the polar decomposition gives a contracting isometry plus a Hilbert–Schmidt perturbation with a fixed bound. The retained singular rank after truncation is constant. The nonlinear remainder estimate is needed only on pairs of actual query states, and the construction preserves actual representatives at every good and bad block. Thus there is no invalid ambient-ball extension of this remainder.

The constants can be chosen without a parameter-dependent circularity: choose the physical block length constant `c`, then the Gaussian-good threshold `r_0` large relative to `c`, then the nonlinear tolerance depending on these constants, then the prefix multiplier `K`, and finally the long-regime multiplier `K_H`. Gaussian-bad blocks account for a fixed small fraction after choosing `r_0`; nonlinear-bad blocks scale like `sqrt(K) S`, while the total block count scales like `K S`. There are only `O(S)` blocks, even though there can be `Theta(S/a)` physical layers.

The cover gains charge every original hidden entropy once. Dividing by the entropy upper product leaves the sum of Gaussian gain remainders, bounded by the adjusted prefix cost. Each good block supplies an additional fixed contraction. This produces `exp(O(S))` representatives. The canonical prefix still has a total residual Lipschitz budget `O(S)`, so strictly causal Picard iteration needs `O(S)` iterations, rather than one circuit stage per physical layer.

## 7. Imported inputs and how far they were checked

I inspected the following source proofs, in addition to their statements:

* `unrestricted-primary-posterior-ceiling.tex`, its Gaussian-distance argument, and the scalar transmission lemma used for the memorizing witness. The quoted constants and the same-depth product ceiling agree. Subtracting a typical Gaussian bulk yields a low-energy *representative*, which need not be the posterior draw itself.
* `critical-rate-foundations.tex`: scalar monotonicity, bridge, dissipation, and stable lifting.
* `critical-controlled-fourier-seeds.tex`: the polynomial-cost parity mean, cube symmetrization, mixture, and rare tag. The exact target component is proportional to the rare probability, not its square, because a unit latent score is retained.
* `critical-finite-width-channel.tex`: bounded-score moment concentration, exact finite empirical score decomposition, conditional Gaussian weight construction, readout shift, and binary-entropy comparison. Its width bound has the stated polynomial resource dependence once the square-root entropy budget is logarithmic.
* `critical-anchored-compression.tex`: importance sampling and exact Gram correction. The correction is absorbed into the next affine matrix, so it does not add a nonlinear layer.
* The companion `nearcritical-target-reuse.md`, `fixed-t-compression.md`, `uniform-scale-intrinsic.md`, `uniform-sharp-intrinsic.md`, and `uniform-baseline-gain.md`. The scale change keeps the physical scalar program; it charges its scalar entropy upper costs, not an inappropriately smaller vector KL. The finite-width comparison uses slack `1/(Ht^2)` and normalized action, avoiding a separate inverse-power-of-`t` width cost.
* The quoted above-one and critical circuit-target learning statements. The manuscript's bounded-fan-in specialization is a genuine weakening with the claimed resource exponents.

The finite-witness intrinsic argument is not the false assertion that every function outside a VC class has a small separating witness. It defines a larger class of functions representable on *every* fixed-size witness. That local-representability class still has bounded VC dimension, and its complement has a witness by definition. The distinction is correctly preserved in the source notes.

## 8. Complexity consequences and essential quantifiers

The joint-polynomial-learning implication is valid for a prescribed prefactor schedule independent of the sample and input law. A bounded-fan-in circuit has a robust constant-weight tanh implementation with polynomial width/depth. Padding its depth to at least the input dimension preserves polynomial teacher resources. The hypothesized sample count is then polynomial in the input dimension **before** the large learner width is chosen. The uniform converse applies at that width and actual scheduled prefactor. This establishes nonuniform `P/poly subset TC^1`; the reverse containment is standard.

The sufficient collapse uses `P/poly=TC^0` on one universal circuit-evaluation family. This supplies one fixed depth and one fixed polynomial exponent for *all* teacher descriptions. Applying the collapse separately to each teacher family would not justify the universal polynomial degree, but the manuscript avoids that mistake. The finite-description lemma uses the fixed global output margin and therefore needs no bound on the precision of the original real weights. The finitely many learner depths below the compiled circuit depth are covered by the fixed-depth intrinsic argument.

For the stretched-exponential lower-bound barrier, finite-domain occupancy forces `d_j >= Omega(L_j^alpha)`. This makes teacher depth and width polynomial in input dimension, which is needed to extend the selected targets to a family in `P/poly`. Without this occupancy step the family argument would have a real resource gap. If that family belonged to some nonuniform `NC^k`, the circuit-target upper bound would be `exp(O(log^{k+1} L_j))`, contradicting the fixed stretched-exponential lower bound at the same widths and scales. The subsequence selection is permitted by nonuniformity.

These results require the stated global teacher output margin, polynomial teacher resources, and relevant all-width or actual-width learning guarantee. They do not establish the same circuit barrier for arbitrary bounded real weights with only nonzero, possibly arbitrarily tiny, output signs.

## 9. Recommendations before treating this as a finished theorem package

1. Keep the theorem dependency labels explicit. The all-prefactor claims are not consequences of the above-one ceiling alone; they require the new finite-width Fourier mass and, for positive learning, the intrinsic theorem.
2. Split the generic constant in the uniform posterior-ceiling statement into separate mass-budget, depth-padding, width, and circuit-resource constants. The proof supports separate universal constants. Reusing one `C` and saying it is enlarged can make a literal reading enlarge the defining rate class at the same time as its claimed circuit bound. This is a presentation issue that is easily removed, not a counterexample to the argument.
3. State whether “all widths” in any surrounding document means a separate `1-delta` guarantee at each width or one sample event holding simultaneously at all widths. The manuscript's collapse needs only the former. The common-class intrinsic constructions can support the latter when supplied a common target budget, but it should not be silently changed when restating a lower-bound hypothesis.
4. Do not present this as resolution of the original exponential-depth question. The verified mathematical progress is a conditional obstruction to both proposed extreme resolutions, plus the independent product-to-parallel-circuit representation theorem.

No manuscript edits are required to repair a fatal defect identified by this audit, because no such defect was found. The small proof-writing and quantifier clarifications above would nevertheless make the claim easier to review independently.
