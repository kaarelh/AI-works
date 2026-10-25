# Independent audit: variable Gaussian directions and Fourier precision

25 October 2026. Finite-N audit agent. Conventional mathematical audit; not Lean verified.

**PASS** for `variable-diagonal-gaussian-scalar-formulas.md` and the precision interface `fourier-factory-finite-bits.md`, subject to their explicit centered-Gaussian path hypotheses. I read both complete notes and the earlier Fock/moment-floor constructions.

Audited SHA256: centered compiler `64c5ccafa3f12396a607e0dde990fda558fcae919fc9e91e5171ccb56ee0dd25`; Fourier precision `c5029dc75f0c3d8ce9ffd551c9d180f811855505c13ccd4d4cf8412e8f262efc`.

## Centered variable-diagonal construction

The scalar Fourier factory has unbiased mean by the Poisson product identity and finite second moment by the weighted Fourier L2 bound. The fixed frequency density has finite fourth moment, which pays the quadratic real-formula expansion cost. Syntactically repeated child expressions must preserve the same sampled coefficients; the precision note explicitly does this.

The mixed Hermite derivative estimates through the stated orders follow from bounded derivatives of `tanh(sqrt(t))/sqrt(t)` and polynomial Gaussian envelopes. Gaussian Sobolev Parseval supplies the weighted coefficient sums. Scaling the parameter to a fixed interval gives the small-a estimates, including the stronger degree-one residual estimate from `b_1'(0)=0`.

For small controls, the Hilbert--Schmidt entry sampler estimates `<u,(A*A-I)u>` with second moment `O(kappa^2)`. The inverse-square-root residual factory therefore has second moment `O(kappa^2)`, and probability-kappa corrections normalize the direction with only `O(kappa)` trace and expected-size increases. The relative variance update is built from an actual independent product oracle; it is not assumed available for free.

For large controls, copying J and sampling K avoids the infinite Hilbert--Schmidt norm of the identity/injection. The true norm lower bound supplies a smooth scalar extension with polynomial dependence on the reciprocal minimum singular value. Polynomial averaging restores the moment budget, so its logarithmic cost is `O(kappa+log_+(1/sigma))`.

At each free Gaussian step, coefficient and direction-product estimators are independent. Degree-dependent child averages control the sum over all ordered tensor coordinates. Rare creation with probability `a/k^2` converts the weighted coefficient bound into an `O(a)` trace increment. The degree-one cross term is nonpositive, and the scalar relative-variance residual has the stated `O(a)` cost. Large free steps have polynomial cost in `1+a`.

The deterministic upper variances telescope exactly. The lower bound by the unmodified scalar iteration gives the required `O(log(H+1))+O(S)` accumulated free-step cost. There is no hidden lower bound on the actual query variance or its coordinate values.

A minor scope detail for the final NN application: the note starts with `q0<=1`, while the original augmented cube has `q0=(d+1)/d<=2`. The identical proof works with the reciprocal-variance inequality on `(0,2]`, giving `log(1+C H q0)=O(log(H+1))`. Alternatively one bounded initial step can be treated separately. This does not change the theorem's polynomial resources.

## Fourier-factory finite-bit completion

The conditional noise is scaled by the conditional *complex product* RMS, so it prevents an arbitrarily small real-part output caused by phase cancellation. Averaging over frequency and Poisson degree gives a pointwise variance floor for the entire mixed oracle; it is not merely a conditional or input-averaged floor.

Every normalized product factor has coefficients bounded by one. The independent child variance floors give `s_theta^2>=gamma^K product t_j^2`, hence the normalized conditional root coefficient is at most `delta^-1/2 gamma^-K/2`. The phase coefficient is bounded and need not have a lower bound. The mixture normalization ratio has squared expectation exactly one, allowing the expected-call-count union bound without a frequency cutoff or a lower bound on Fourier coefficients.

The polynomial-size event bounds every active Poisson product degree. The existing noise-floor bounds also cover quadratic sampled products and independently multiplied coefficient/direction estimators. Thus a good finite realization has polynomial logarithmic coefficient magnitudes, even for countably supported control coordinates and arbitrary real precision in the original path. Ordinary finite-tree sensitivity then permits polynomial-bit dyadic rounding while preserving the good majority's classification margin.

This precision argument applies to ordinary integrable Fourier transforms as stated. It does not silently cover a singular-frequency residual estimator whose cancellation uses shared children.

## Scope

The conclusions are structural statements about the represented Gaussian-control path. This audit does not assert that the full critical posterior can be restricted to Gaussian row laws. Noncentral Gaussian controls are a further extension to be checked separately, and arbitrary finite-entropy non-Gaussian tilts remain outside these premises.
