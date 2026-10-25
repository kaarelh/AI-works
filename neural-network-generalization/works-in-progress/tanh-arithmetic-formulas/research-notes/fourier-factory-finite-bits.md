# Finite coefficients for a Fourier--Poisson scalar factory

25 October 2026. Proposed root-agent extension of the audited moment-floor argument. This note addresses the additional scalar coefficient functions in the variable-diagonal Gaussian compiler. It is not yet an independent audit of that entire compiler.

## Factory and moment assumptions

Suppose `X(x)` is an unbiased scalar oracle on the Boolean cube, with uniformly bounded second moment `E X(x)^2<=V`, and with a pointwise variance floor

`Var X(x)>=gamma a^2`, where `a^2=E_x E X(x)^2`.

The random expression shape is independent of x. Its normalized stored representation computes `X/a`. An input-dependent mean is allowed; gamma is inverse polynomial in the eventual resource bound. Zero RMS types are removed.

For a scalar function f admitting an integrable Fourier transform, choose a fixed positive frequency density p. Absorb Fourier convention constants into c(omega)=fhat(omega)/p(omega). Set `lambda=1+omega^2 V`, sample `K~Poisson(lambda)`, and use independent calls X_j to form

`Z=product_(j=1)^K (1+i omega X_j/lambda)`.

Then `E Z=exp(i omega E X)`, and `E |Z|^2<=e` after Poisson averaging. The real factory is `Re(c(omega) Z)`. A choice such as `p(omega) proportional to (1+omega^2)^-3` gives finite second moment and expected real arithmetic work `O((1+V^2)T)` when f has the corresponding H^3 bound: real expansion of a K-factor complex product costs O(K^2), and `E_p omega^4<infinity`. In the application V is a fixed constant after resets.

## Conditional noise prevents phase cancellation

Condition on theta=(omega,K). Let

`s_theta^2=E_x E[|Z|^2 | theta]`.

This is finite and positive for each finite theta. Replace the conditional output by

`Y_theta=Re(c Z)+sqrt(delta)|c| s_theta xi`,

where xi is an independent Rademacher sign and delta>0 is inverse polynomial. The new mean is unchanged. Its conditional cube RMS b_theta satisfies

`delta |c|^2 s_theta^2 <= b_theta^2 <= (1+delta)|c|^2 s_theta^2`.

Thus the added noise costs at most a factor 1+delta in the same Fourier second-moment bound, and it provides a pointwise variance floor. Writing `b^2=E_theta b_theta^2`, the mixed oracle satisfies

`Var Y(x)>=delta E_theta |c|^2 s_theta^2 >= delta/(1+delta) b^2`.

This is a floor for the entire mixed oracle, not merely for an average of input-dependent variances. Frequencies with c=0 return the exact zero expression.

## Normalizing the finite tree

For a fixed conditional product, normalize each factor by

`t_j=sqrt(1+(omega/lambda)^2 a_j^2)`.

Here a_j is the cube RMS of the relevant child type; in the simplest factory all types coincide. The factor becomes

`alpha_j+i beta_j (X_j/a_j)`, with `|alpha_j|,|beta_j|<=1`.

The child variance floor implies, at every input,

`E|1+i omega X_j/lambda|^2 >= gamma t_j^2`.

Independence of child calls, conditional on x and theta, therefore gives

`s_theta^2 >= gamma^K product_j t_j^2`.

Consequently the normalized conditional output `Y_theta/b_theta` can be written as the real part of a product of the normalized factors, with a root coefficient of magnitude at most

`delta^-1/2 gamma^-K/2`,

plus a Rademacher leaf of coefficient at most one. The phase c/|c| has bounded real and imaginary parts. Arbitrarily small Fourier coefficients, child RMS values, or Poisson parameters are not separately inverted in the final tree. The displayed bound uses only ratios after normalization.

The mixture-to-output normalization contributes the random coefficient `b_theta/b`. Its squared expectation over theta is exactly one. Thus a conditional second-moment/expected-call-count union bound excludes coefficients larger than a chosen polynomial in a polynomial-size collection of random formulas. No regularity or nonzero lower bound on fhat is needed for this step.

Balanced expansion into real arithmetic duplicates syntactic copies of already sampled child formulas, preserving their common random coefficients wherever the same child occurs in the real and imaginary parts. It costs O(K^2) rather than assuming that complex arithmetic is a primitive gate. There is no independent rerun of a copied child. Along a good seed of polynomial total size, every nonempty active product has K bounded by that size, so the root bound above has polynomial logarithmic magnitude. The same statement holds for K=0 directly.

## Resulting precision statement

Suppose the surrounding scalar-oracle construction has polynomial expected total arithmetic size and polynomial expected number of primitive calls; all injected floors satisfy `log(1/gamma)+log(1/delta)<=poly(R)`; and the final root RMS and target margin have polynomial upper/lower bounds. Then with positive probability one obtains both the usual all-cube correct majority and a polynomial-size expression family whose normalized coefficients have polynomial logarithmic magnitude. The bounds on selected mixture coefficients follow by conditioning on the caller's oracle type and summing over expected call count, as in the existing moment-floor proof.

All factor coefficients are bounded regardless of the sampled frequency magnitude. Thus a separate frequency cutoff is not needed merely to bound the final coefficient ratios, although a cutoff can still be used for other analytic bookkeeping. Large K is excluded by the size event, not by an unsupported tail assertion under an output-weighted frequency distribution.

Polynomial-bit rounding now follows from ordinary arithmetic-formula sensitivity: a size-polynomial tree with exp(poly(R))-bounded coefficients has uniformly exp(poly(R))-bounded values and coefficient derivatives on the cube. Approximation by dyadic constants preserves the fixed classification margin. This supplies the precision ingredient for the proposed variable-diagonal compiler, provided that compiler's claimed mean, second-moment, and expected-cost recurrences are established independently.

This argument is specialized to an ordinary Fourier--Poisson transform, whose conditional product moments factor. The cubic residual estimator with a subtraction sharing the same child realizations needs its own cancellation-preserving analysis; it is not automatically covered by adding noise before its singular-frequency cancellation. The variable-diagonal H^3 transforms use ordinary integrable Fourier representations and do not have that singularity.
