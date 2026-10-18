# Independent audit: finite-width scalar-channel target mass

Auditor: `depth_memorization`. Date: 2026-10-19 (research round identifier).

Audited source: `source/critical-finite-width-channel.tex`.

Frozen SHA-256: `6a45c4abf1df7a1e503d5dd5d7449ee4c4822ca86df16574eff6f007abe68dde`.

**Verdict: all statements in this source pass independent mathematical reconstruction.** This includes the approximate-prefix corollary and the Fourier target-mass corollary. This is an AI-agent mathematical audit, not Lean verification.

## Scope and principal checks

The raw-prior theorem concerns the original finite-width critical Gaussian network, with strict margin at every input. Auxiliary mixture tags, score variables, and Gaussian projections are devices for a change of measure. They introduce no support restriction on the network prior.

1. **Normalized empirical score.** The score Gram, score-feature cross moments, and diagonal moments are sufficient. When each differs from its population value by at most alpha <= 1/4, the coefficient error is <= 4 alpha and the squared residual error is <= 13 alpha. The resulting two-coordinate Hilbert metric error is <= 8 sqrt(alpha). The normalized coefficient vector has squared Euclidean norm exactly 1/N, and hence the empirical kernel decomposition into its rank-one component plus a positive-semidefinite residual is exact.

2. **Causal Gaussian row construction.** Given the previous actual features and normalized unit vector u, the reference row `(Z u + (I-u u^T) xi)/sqrt(N)` has exactly the original Gaussian marginal. The reference auxiliary kernel can depend on Z without changing that marginal. The prescribed tilt and its auxiliary variables are chosen without reference to a queried input. Querywise Gaussian comparison couplings are used only to prove error estimates, not to define incompatible networks.

3. **Component metric propagation.** Gaussian entropy controls `max(1,E Z^2) <= exp(2 sqrt(D))`. The shared score projection and the norm of its orthogonal residual are jointly contractive in the relevant L2 geometry. Thus one layer multiplies the component metric error by at most `exp(sqrt(D))`, with no additive baseline factor and no dependence on the number of inputs.

4. **Sampling and failure handling.** Conditional rows are independent. Hoeffding concentration for the three bounded moments costs `C B^4 alpha^-2 log(Hm/kappa)`. Stopping and reverting to the prior when normalization fails is causal, retains the entropy upper bound, and cannot occur on the selected concentration event. The empirical Gram normalization does not require a lower bound on a feature-kernel eigenvalue.

5. **Readout and strict margin.** The readout mean uses the actual normalized coefficient vector. With `t=(1+kappa)/(2 sqrt(v_H))`, the propagated error yields mean signed margin at least `1/2+kappa/4`. The actual Gaussian readout noise has variance at most 1/N per input. The specified concentration margin leaves a strict global margin greater than 1/2.

6. **Entropy-to-probability conversion.** The complete controlled construction has KL at most `N(A+3 A kappa)` and target-event probability at least `1-kappa`. Binary data processing gives the displayed raw-prior lower bound after dividing by `1-kappa` and accounting for binary entropy. The choice `kappa=min(1/4,tau/[32(A+1)])`, together with the width bound, covers these errors.

7. **Explicit width exponents.** Substituting `sqrt(alpha)=kappa sqrt(v_H)/(64 H exp(S))` yields the factors `B^4 H^4 exp(4S) kappa^-4 v_H^-2`. Since `v_H^-1 <= 8A`, the stated `(A+1)^6 (1+tau^-1)^4` factor is sufficient. The log factor covers the failure allocation and readout concentration.

## Approximate-prefix corollary

The prefix event can depend on the observed prefix, and continuation is applied only when its metric certificate holds. Its entropy cost is still the unconditional prefix KL plus the fixed continuation budget. There is no conditioning penalty. From

`e_0 <= kappa sqrt(v_M)/(64 exp(S))`

and `sqrt(alpha)=kappa sqrt(v_M)/(128 M exp(S))`, the final propagated error is at most `5 kappa sqrt(v_M)/64`, strictly below `kappa sqrt(v_M)/8`. Assigning failure at most kappa/4 to each of prefix, later moment concentration, and readout noise leaves total failure below kappa. The unchanged binary-entropy calculation applies.

## Fourier seed and continuation checks

I checked the supporting controlled-Fourier, target-seed, rate-upper, scalar-path, and rate-foundation sources in the critical-depth paper.

- The first law is an explicit mixture of translated Gaussian weight laws and symmetries. Its entropy bound therefore holds on the weight-plus-tag space, before data processing to features. Keeping the rare tag and taking its normalized indicator as score gives component `v_1=theta/Z_f^2`, not `theta^2/Z_f^2`, at joint entropy at most `theta D_* <= 1/L`.
- The first positive component is inverse polynomial in R. Free cooling retains an inverse-polynomial fraction. The holding value `delta exp(-C S_0)` is inverse polynomial because `S_0=O(log R)` and `delta >= c/L`.
- Prescribed component reduction is implemented by adding an independent random-sign score coordinate. Its unit norm, desired covariance, boundedness, and zero additional entropy all check.
- Growth and purification retain the holding floor. The last scalar continuation starts at a state at least c/L and uses O(L) steps. Its stable lift preserves a fixed fraction of each nominal scalar state because the purified residual is O(delta L^-4). Thus every score can be bounded by `R^C`.
- The square-root entropy proof permits upper bounds on feature entropies: scalar dissipation, Bellman suffix lower bounds, and the action decomposition all remain valid. It also covers excess action larger than 1/4 by Cauchy--Schwarz. Hence `S=O(log R)` in the stated depth range, including when the displayed excess need not be a small absolute constant.
- Taking tau=1/L makes the explicit sufficient width polynomial in R and absorbs the extra action into `C log^2(R)/L`.

No unproved comparison with the unknown minimum rate is used. The conclusion is a raw target-event probability lower bound for the explicit construction. Learning requires the separate collective competing-function bound.
