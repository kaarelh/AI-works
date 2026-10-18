# Mean-field continuous-domain proof audit

## Scope and verdict

I read the assembled `paper/meanfield.tex` in full and the model, main theorem, posterior lemmas, teacher-tube statement, bounded-domain remark, and relevant limitations in `paper/paper.tex`. This is a conventional mathematical review, not Lean or other machine verification.

**Verdict: no substantive mathematical gap found in the mean-field extension or its deduction of the stated finite-width regression theorem.** The proof covers the actual independent-coordinate mean-field prior, including the specified non-Gaussian curvature family, at every learner width above teacher width.

The principal audit version of `meanfield.tex` had SHA256

`33cd028b97cad4c28b75575650dc3598d1fc3ec94453d3711a0c1829563f7eda`.

After the checked uniform-threshold clarification below, its SHA256 is

`1e5a2978824d7f5eabedca1258efb12e8f316731fe147fcdab13732c24ea2b97`.

The corresponding main source had SHA256

`78278c713ed85119eed649b7c228d71cb946c266139af6670cd4f2fb2dea7871`.

## Checks performed

1. **Approximate-readout duality.** Slater holds because the original readout is strictly feasible for every positive approximation tolerance. The signed multipliers satisfy `Nu=H^T beta`; complementarity gives `t||beta||_1=Nv^T u-N||u||^2`. Maximizing `sqrt(K)r-r^2` gives the stated `K/(4t)` bound. No inversion, global output margin, or nondegeneracy assumption is hidden in this step.

2. **Finite covariance certificates.** The sparse finite comparison has size at most `(2s^2+1)^q`; Hoeffding costs at most `G^2/(2q)<=1`. The bounded-dual lift follows from the normal-cone condition and nonnegative relative entropy. Symmetrizing the matrix leaves both the quadratic observable and the required bounds unchanged.

3. **Non-Gaussian comparison.** The relative Lindeberg calculation matches the first two scalar moments, retains a local multiplicative normalization, and yields error `c_nu P_3(G)/sqrt(N)` without an exponential tilt-budget loss. It compares log partition functions, not actual posterior measures or tilted covariances. The first-layer law is retained exactly.

4. **Gaussian proxy stability.** The derivative constants imply the displayed dimension-independent `8(1+G)^2` covariance Lipschitz bound. Singular covariances are covered by regularization and bounded convergence.

5. **Actual-output continuity.** The norm event has Lipschitz constant `K^(L/2)`. First-layer square moments, internal operator-norm sphere nets, and readout square moments give failure at most `L exp(-mNK/16)` once K exceeds a fixed law-dependent constant. This is exponentially small at the same N scale as teacher-tube cost.

6. **Input net and covariance budgets.** The net radius `a/(4K^(L/2))` depends on no learner width. Its logarithmic cardinality is polynomially bounded at fixed depth. The backward budgets give exactly `r(K+1)/G_r=a^2/(8K)`. The displayed width threshold makes the finite certificate failure at most `r exp(-NK/4)` and the relative Lindeberg error at most one at every internal layer.

7. **Finite realization and rounding.** Readout approximation, proxy replacement, sampled realization, parameter rounding, and extension from the net cost respectively `a/4,a/8,a/8,a/8,a/4`, totaling `7a/8<a`. The chosen covariance sampling accuracy and width produce the claimed `a/8` output error. The weight tail union bound intersects the covariance event with positive probability. All finite-description bounds depend only on fixed-depth polynomials in d,K,1/a, not the actual learner width or draw.

8. **No circular net selection.** The finite cover centers are rounded finite networks composed with the predetermined nearest-net-point map. Only the original network needs a Lipschitz bound; the finite approximation's possibly larger Lipschitz constant never changes the chosen net.

9. **Posterior and all-width deduction.** The uniform teacher tube lower-bounds the denominator for every sample. Choosing `cK>=A+log(12L/epsilon)` bounds exceptional posterior mass by `epsilon/6`. The finite-cover union bound gives Gibbs tolerance-risk at most `epsilon/3`; Tonelli and Markov give the full-posterior `>2/3` confidence assertion. The remaining widths use the direct tube-cost bound `AT_L`, with no width limit or missing width interval.

10. **Continuous-domain and parameter scope.** The results need positive training tolerance and a strictly larger test tolerance, retain a separate teacher weight bound, and claim fixed-depth polynomial complexity rather than an exponential-only depth prefactor. The compact-cube variant changes the logarithmic input-net size by at most the stated radius factor. It introduces no new issue into the mean-field argument.

## Minor presentation recommendation

The displayed threshold uses the actual input-net size s, while its notation is `T_L(d,K,1/a)`. Replacing `log(2s^2+1)` by the uniform upper bound

`log(3)+2d log(1+8K^(L/2)/a)`

or explicitly defining `T_L` to be a uniform majorant removes that cosmetic dependence on X. The existence of the claimed uniform polynomial threshold already follows from the displayed net-size bound; this is a clarification, not a proof defect. The writer subsequently incorporated the explicit uniform upper bound; I checked the revised displayed threshold and it is correct.

## Limits of this audit

The exact-interpolation iterated-limit corollary and the full strong-prior/super-mean-field compression proof were outside this audit's primary scope. The review checks the mean-field argument assuming the stated teacher-tube lower bound; its parameter translation and relative-entropy proof are delegated to a separate review.
