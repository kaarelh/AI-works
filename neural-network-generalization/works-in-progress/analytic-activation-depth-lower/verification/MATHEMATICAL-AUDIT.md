# Fresh adversarial audit: analytic activation counterexample

25 October 2026. Independent AI-agent mathematical audit of the complete manuscript, now distributed as [paper.tex](../source/paper.tex) and [critical-appendix.tex](../source/critical-appendix.tex). The subsequent publication preparation changed the title, date, and review-status wording, and split the critical appendix into its own source file; it did not change the mathematics.

## Verdict

**I did not find a substantive mathematical error in the stated counterexample.** The cold and fixed-gap finite-width branches are particularly direct. I also checked the critical appendix's scalar program, finite-width probability realization, canonical circuit reduction, and full-cube extraction route rather than treating a positive-learning theorem for arbitrary analytic activations as an imported black box.

The result has a crucial scope limitation already stated prominently in the manuscript: it changes the activation to a computationally contrived, fixed, computable function. It does not establish the original exact-tanh depth lower bound. The activation's efficient evaluability fails at precisely the precision used by its teachers. No full Lean verification is provided. The result is suitable for a conventionally checked work in progress with these limitations retained; this audit does not support presenting it as a solution of the original question or as a formalized main result.

This is a mathematical audit, not a claim of exhaustive formal verification.

## 1. No covert finite-architecture VC or Pfaffian assumption

A general real-analytic activation can have unbounded combinatorial expressiveness at fixed architecture, so transferring the usual tanh parameter-counting theorem would be invalid. This audit checked that the argument avoids that transfer.

The current manuscript does **not** make that transfer:

* The fixed-width cold argument uses finite-dimensional Gaussian concentration and the finiteness of the Boolean input domain. Its parameter dimension p occurs only in an ordinary Gaussian small-noise estimate at a fixed architecture; no VC bound is inferred from p.
* The fixed-gap finite-scale argument subtracts a typical small-operator Gaussian bulk from an actual posterior draw. The resulting low-energy representative has low Frobenius product. Its function is then simulated by the activation-independent low-product circuit theorem, whose hypothesis is zero preservation and Lipschitz continuity rather than Pfaffian definability.
* The critical argument extracts an approximate entropy certificate on the entire finite cube, repairs it to a genuine controlled path, and bounds the circuit complexity of near-baseline paths. This uses finite nonuniform lookup tables for a Lipschitz activation. It never asserts that the activation has a polynomial-time evaluator or that unrestricted finite-width networks with this activation have finite parameter-count VC bounds of the usual form.
* The raw bad event in the critical ceiling is measurable because there are finitely many Boolean functions on a fixed finite cube. That elementary finiteness is independent of how many functions a fixed architecture realizes.

The nonuniform lookup step is consistent with the deliberately difficult activation: its table length is polynomial in the canonical path resource R, and a hard teacher necessarily lies outside the small-R class. A lookup circuit of polynomial size in R is not an efficient evaluator at the teacher's inverse-exponential accuracy with R only polynomial in d.

## 2. Analytic construction and effective computability

I checked the following potentially delicate points.

1. The centers tend to negative infinity linearly in d, while the Gaussian widths shrink exponentially. On each fixed complex compact, the real part of `(z-c)^2` is eventually positive of order d^2. The entire bump series is locally uniformly summable, even after the factor 2^d for its band. Thus S is entire and phi=tanh+S-S(-.) is real analytic on the entire real axis.
2. The hard truth-table signs can be computed by finite exhaustive circuit enumeration independently of phi. The band tails have explicit computable bounds. Hence the single fixed activation is computable, though extremely inefficiently. No circular choice of the hard labels occurs.
3. The cubic prefactor makes R vanish to order three at zero, giving phi(0)=0 and phi'(0)=1 exactly. It also supplies the u^2 and |u| factors needed to preserve the global upper derivative bound and the sign of the second derivative near zero.
4. Away from zero, the first derivative relative to sech^2 has a band bound proportional to exp[-(M log2-8)d]. The second derivative has the corresponding exponent `(M-1)log2-8`. Both are strictly positive for M>=16. Choosing tau sufficiently small after J is fixed preserves strict increase, slope at most one, and strict concavity on the positive half-line.
5. The prescribed derivative orders converge because M>=r+2; shrinking tau gives arbitrary C^r closeness for each fixed r. Uniform summability also gives S(u)->0 as |u|->infinity, so the range remains (-1,1).
6. Choosing a sufficiently small positive rational tau is enough for the existence of a computable phi. The theorem does not need an efficient procedure taking arbitrary real eta as input and returning tau.

The construction is not claiming that tanh plus an arbitrary small analytic perturbation is hard. It engineers the perturbation to encode the separately chosen hard tables.

## 3. Decoder and teacher resources

At a target center, the central bump has exactly the intended signed amplitude delta_d. Every noncentral finite-difference query is at least Delta_d/(2m) from the current band's centers, so the J-dependent same-band error is uniformly small. For other bands, the Gaussian suppression in `(e-d)^2/r_e^2` beats the potentially large amplitude ratio delta_e/delta_d; splitting e<=d/2, d/2<e<d, and e>d handles this uniformly. Reflected bumps are farther away.

The m-th difference of tanh is bounded by Delta_d^m exp(-8d). Dividing by delta_d leaves the stated exponentially vanishing factor because m-D=2. The O(1)-width finite-difference decoder therefore has the correct sign on all cube inputs, not merely on sampled inputs.

The following scalar weight-two layers require Dd+O(1) stages. Their cumulative relative error is controlled by a geometric sum of the ideal amplitudes, rather than multiplying a fixed relative error Dd times. The target readout is a fixed constant depending on the chosen perturbation. The teacher's first-layer coefficients have O(d) bits, and rounding all later fixed coefficients/primitive operations to exp(-O(d)) accuracy preserves the unit margin by ordinary Lipschitz propagation. Thus polynomial coefficient bit length is sufficient; no exponentially long advice is hidden in the teacher weights. The computational information is instead in phi itself.

The separate evaluator lower bound is consistent: an efficient phi evaluator at O(d)-bit precision on O(d)-sized dyadic inputs would simulate the entire teacher with polynomial overhead and violate the defining circuit hardness of f_d.

## 4. Cold and fixed-gap finite-scale posterior arguments

The point memorizer is valid for this phi because oddness and the controlled saturation tail give uniform indicator approximations. Its low-energy scalar tail stays close enough to the linear regime with total relative error O(alpha/(q-1)); q>1 is a fixed number chosen very close to one. Its action is at most q^2 L+O(1), uniformly through the specified exponential sample range.

The weighted energy blocks multiply to d times the squared ordinary Frobenius product. AM--GM therefore gives exactly the product conversion used in the manuscript. Rescaling the readout by two in the cold branch, or by 8/3 after the finite-scale perturbation, restores a unit margin.

For fixed-gap scales, the normalized input and energy-coordinate activations remain zero-preserving and 1-Lipschitz. The perturbation inequality correctly applies to arbitrary low-energy centers, not only the memorizer. The bulk set T is convex and symmetric and has raw Gaussian mass at least one half by the stated Gaussian/net bounds. Symmetry justifies the translated-set lower bound; Gaussian isoperimetry justifies the distance tail. Consequently the projection argument supplies a low-product representative for almost every posterior function without requiring concentration of the full raw parameter norm.

The chosen threshold N>=exp(C_zeta d) makes t times the bulk bound smaller than the inverse-exponential perturbation radius for each fixed zeta>0. The result does not assert uniformity as zeta tends to zero. The critical endpoint is supplied separately.

## 5. Critical target program and actual finite-width mass

I checked the scalar lemmas, especially the places where an argument valid for tanh might fail for a general activation.

* Monotonicity of the scalar value function uses oddness, monotonicity of |phi|, and Gaussian rescaling; concavity and the derivative assumptions supply the required small-variance expansions and heat-convolution estimates.
* The strict potential for the constructed activation is correctly inherited from tanh. For `G(u)=exp(tanh(u)^2)`, direct differentiation gives G''<2G away from zero, while the expansion of log E G(sqrt(q)Z) is q-q^2+O(q^3). The perturbation changes this logarithmic moment by O(epsilon q^2), leaving a strict deficit on [0,2].
* The short increasing scalar path estimate follows from its near-optimal prefix expenditure O(p+q), the entropy ratio bound, and dissipation. Each dyadic variance band contributes O(1) to the square-root entropy sum.
* The Fourier seed uses polynomially shifted first-row Gaussians and cube-translation symmetrization. Its exponentially many auxiliary labels do not cost an additional entropy term because the reference uses the same labels and has the correct Gaussian weight marginal. The score norm and component are charged correctly.
* Cooling, controlled growth, holding, purification, and the scalar suffix fit the advertised depth and action budgets. The estimate r'<=r uses conditional Gaussian Poincare; the stronger purification contraction uses the derivative square expansion. The heat bound supplies a multiplicative loss in the target component during the non-Gaussian suffix, avoiding a dangerous additive error at tiny component scale.
* The finite-width row construction uses a unit score direction plus independent orthogonal Gaussian noise. Under the reference its weight marginal is exactly the original Gaussian even when the direction depends on past layers. The conditional KL cost is the prescribed scalar cost. This is a finite-N construction, not a rate-limit heuristic.
* The displayed N bound has the correct powers: the moment tolerance produces B^4 H^4 exp(4K) kappa^-4 v_H^-2, and v_H^-1<=8A gives the stated `(A+1)^6(1+tau^-1)^4` factor.

## 6. Critical canonical circuit ceiling

The path-to-circuit proof uses only properties genuinely verified for the constructed activation.

The occupation inequality's last-exit decomposition controls both variance occupation and square-root entropy by O(log H+sqrt(H epsilon)). The maximum-over-input variance does not invalidate dissipation: after reducing c so q-cq^2 is increasing, the scalar inequality at the maximizing new input implies the displayed inequality for the old maximum.

Anchor-only density replacement preserves the anchor marginal exactly. Its one-query conditional KL increment bounds a feature-coupling error, which propagates through later layers by Gaussian entropy gain. Greedy anchor additions are charged either to total entropy or to squared readout projection norm. The canonical state preserves all anchor crosses and diagonals, even though it is not itself asserted to be a genuine full-covariance transition. That distinction is stated correctly.

The nonlinear residual has Lipschitz cost O(q+sqrt D), from entropy duality applied to a Gaussian fourth-moment expression. Radial extension and inverse-polynomial floors preserve the needed budgets. Importance sampling by `1+||e||^2` keeps the finite quadrature coefficients bounded even if an anchor basis is ill-conditioned. Scalar activation values can consequently be stored in polynomial-size nonuniform lookup tables, which is the appropriate treatment of the present inefficiently evaluable phi.

The parallel Picard iteration is acyclic in time, so its error expansion uses distinct ordered indices and gains the factorial denominator. This allows O(log R) iterations with polynomially small accumulated numerical error.

Finally, the bounded-dual certificate and covariance repair are genuine finite-width arguments. The Gaussian moment tilts are extracted conditionally from the actual empirical chain, then repaired by coupled feature embeddings. The repair cost is not increased. Applying this to the entire Boolean cube costs an exponential width threshold, explicitly allowed in the theorem. It avoids a counting argument for arbitrary-activation finite architectures.

## 7. Publication framing

Retain all of the following:

* One fixed, deliberately engineered activation, not exact tanh and not a claim about a generic perturbation.
* Exponential accuracy evaluation of that activation is computationally hard; the teacher's polynomial architecture count alone does not measure the computation performed by its activation primitive.
* Every fixed gamma>=1 is covered, with gamma-dependent width thresholds above one; moving exponents near one are not claimed.
* Actual finite widths are covered, but they are exponentially large in d. This is consistent with the separate finite-width issues for ordinary tanh.
* Conventional proof/audits only, not a Lean-verified result.

The public title states the statistical conclusion explicitly: “Exponential sample complexity for an analytic activation arbitrarily close to tanh.”
