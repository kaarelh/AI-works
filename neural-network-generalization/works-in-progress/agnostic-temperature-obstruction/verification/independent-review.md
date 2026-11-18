# Independent review of the fixed-dimensional tanh obstruction

Reviewed the complete `tanh-sharp/fixed-dimension-paper.tex` on 18 November 2026 UTC. The matching source hash is in `fixed-dimension-tanh-review.json`. This is a conventional mathematical audit, not a Lean formalization.

## Verdict

The theorem and proof check. The construction genuinely gives one data law in input dimension two, with an exact width-two conditional mean, that defeats every likelihood temperature at every eligible width and every Gaussian scale satisfying `N sigma²<=1`. The theorem's coefficient condition `B_n/(n log n)->infinity` suffices. The Gaussian parameter covariance is retained exactly in the comparison measure. The result concerns laws varying with sample size and does not claim failure of consistency at one fixed law.

## Checks

- A weighted feature list admits integer clone counts with `k_j >= N |alpha_j|/(2 A0)` when `N>=2M`. The floor-plus-one construction has total at most N, and distributing the remainder preserves every lower bound. It gives `sum alpha_j²/k_j <=2 A0²/N`.
- Absorbing coefficient signs into affine rows is valid because tanh is odd. The normalized first-layer mean energy is at most `d beta²K²`, independent of clone imbalance. The scalar constraints use the bound A rather than the actual mass A0, so zero or small coefficients cause no division or concentration problem.
- The first-layer Gaussian smoothing bound and both Hoeffding estimates are pointwise uniform on the evaluation set. No simultaneous Gaussian event over all inputs is needed for pointwise expected empirical loss.
- The common-background tanh recursion uses only `N sigma²<=1`. The derivative inequalities, variance error bound, and scaled mean bootstrap are exactly the same valid scalar estimates as in the earlier Boolean memorizer. The first-layer input target is now exact, so the output root-mean-square error is t rather than 2t. The bad-event and readout-variance constants are conservative.
- The two groups of n/2 spatial nodes have minimum spacing at least `1/n`, including the extra node zero. The staircase formula is exact at all n+1 nodes. Its coefficient mass is at most n+1, the scaled thresholds have margin at least one, and their augmented row norms are at most `2 sqrt(2)n`.
- At fixed t and H, the memorizer has `R²=O_H(n^(2/H))`, beta of order log n, energy `O_H(n² log²n)`, and width `O_H(n^(4-2/H)log n)`. These bounds do not depend on teacher B or the learner's scale. The comparison law may depend on the sample, width and scale, as permitted by the variational inequality.
- The width-two teacher has the asserted exactly normalized opposite inner labels and bounded coefficients. Its outer values stay in [-1,1]. Only output values on the law's support are needed; the theorem does not claim a unit global amplitude bound.
- The input covariance is diagonal: the signal has Z=0 and the noise has T=0. Its first eigenvalue is `q(1+delta²)/2 >=1/20`; its second is `p E Z² >=p/4`. Both coordinates attain both endpoints.
- The singleton occupancy and signal-count event has the stated probability, is independent of learner parameters, and yields at least n/3 noisy singleton atoms for sufficiently large n.
- At small temperatures, the posterior comparison residual is below 1/5. Projection and Jensen preserve this for every stated mean convention. The reverse-triangle lower bound gives excess strictly above 1/100. Gibbs-risk lower bounds follow from the appropriate means.
- At large temperatures, normalized Gaussian operator-norm moments control the posterior's input sensitivity. At `lambda >=1/(100 K_n)`, the inner half-difference is `O_H((n log n/B_n)^L)`, which tends to zero under the exact theorem hypothesis. The inner signal pair then gives excess at least 1/80.
- All ingredients are uniform in N above the displayed polynomial threshold, in every positive scale with `N sigma²<=1`, and in both temperature ranges on one sample event. Thus data-dependent choices of temperature, width, or allowed scale are covered. A mixture of temperatures is correctly excluded.

The result is stronger than a fixed-temperature continuity obstruction: one law works simultaneously for every temperature, while input dimension and teacher width remain fixed.


## Arbitrary-mixture extension

The additional `mixture-sector.tex` source has also been independently checked. Its Gaussian-readout sector inequality is valid because conditioning on hidden features gives a positive-semidefinite contraction smoother `S=K(K+nu I)^(-1)`. Posterior averaging preserves the contraction, so every ordinary training mean obeys `y·f>=||f||²`. For labels in [-1,1], clipping the mean coordinatewise increases `y·f-||f||²`; this justifies individually clipped components as well.

The exact target identity `y·g=||g||²` holds at each observed atom. Combining it with a uniform empirical error lower bound yields one linear separator of all component predictions from the target. The separator survives arbitrary data-dependent mixtures. The approximate-identity remark has the correct sign: an upper defect nDelta reduces the separator constant by Delta.

The stronger occupancy event supplies an empirical error lower bound n/160 in both temperature branches. The collision-count variance is at most `n[p²/2+p³(1-p)]<n`; since `sum k_j²<=n+2C` and `EC<=n/2`, Chebyshev gives the stated extra failure 1/n. Inner-atom counts have total extra failure `2exp(-n/320)`.

The population L2 norm of the common witness is bounded by `4/p+16q<7`. Cauchy--Schwarz therefore gives mixture excess at least 1/179200, above the stated safe constant 1/200000. The argument covers mixtures over width, scale, and temperature, and includes mixtures of raw and individually clipped raw posterior means. It correctly does not infer the sector property for means of clipped posterior draws. Training-vector integrability is uniform, and the witness vanishes at unobserved atoms, so arbitrary extensions there cannot invalidate the lower bound; infinite-risk extensions are harmless.

The Bayesian hyperprior interpretation is valid: conditional on each allowed hyperparameter, its component is exactly the corresponding posterior, and its final mean is a data-dependent probability mixture. The component-width/scale restrictions remain necessary.

## Fixed-dimensional sphere/Fourier strengthening

Independently checked `tanh-sharp/fourier-fixed-dimension.tex` in full. The cosine multiplier is bounded away from zero uniformly over native first-layer Gaussian variances at most one; the truncated tanh-difference convolution and its squared-feature variance estimate have the claimed exponential tails. The deterministic quadrature is obtained before the actual Gaussian perturbation, and its finite support union bound is paid in the displayed width threshold. The signed second-layer coefficients preserve the scalar native-noise recursion.

The midpoint grid mask is exactly one on every grid point and zero at the signal location. Parseval gives Fourier coefficient mass at most square root of the grid size; multiplying by the mask costs at most two. The unit-sphere embedding equalizes the first Gaussian preactivation variance, and its centered covariance is diagonal with the claimed positive lower bounds, including the final coordinate.

The resulting energy exponent is max(2/D,(1+2/D)/H), and the width exponent is (1+2/D)(2-1/H). The growing-width two-chain teacher has separation order (B(rB)^H)^-1 and coefficients at most B, including the case B=1 with r growing. The strict inequality Ha+Lb>(H+1)/(2H) permits a fixed D making the large-temperature sensitivity tend to zero. The earlier occupancy and common separating-functional mixture arguments transfer unchanged.

No substantive gap was found. This audit covers the strict exponent range, with dimension chosen from the fixed slack; it does not certify an endpoint in one universal fixed dimension.

## Fixed width-one teacher and one fixed-law slow-rate result

Independently read `simple-teacher-rate.tex` and `fixed-law-rate.tex` in full. Both pass the audit. The target is the same depth-H tanh iterate of one coordinate, with width one and unit coefficients; noise is independent homoscedastic plus/minus one quarter.

The Gaussian-readout normal equations give the strengthened projected-sector inequality with exactly the stated likelihood parameter multiplying the affine-orthogonal prediction norm. This remains valid after hidden-posterior averaging and allows a centered Gaussian affine output skip of any bounded covariance. The target has a fixed positive affine residual, with the stated explicit r_H formula, uniformly well-conditioned augmented input Gram matrix, and exponentially concentrating empirical residual. The low-temperature native Fourier comparison fits singleton noise; the high-temperature quadratic minimization supplies a common linear witness after controlling noise-target alignment. Constants and the n^(-2 rho_D) lower rate are correct.

For the one-fixed-law upgrade, checked the weighted occupancy expectation and variance, including all collision covariances; nesting of midpoint grids under odd resolution multiples; monotone block atom masses; active support size and minimum mass; the no-future-observations event; and the lower bound p_m >= n_m^(-1/(D m^2)). The tolerance t_m proportional to square root p_m adds a p_m inverse factor to width but no fixed energy exponent, because p_m=M_m^(-o(1)). Its width penalty is absorbed by the displayed n_m^kappa bound since kappa>1.

The population witness has uniformly bounded weighted norm on the active support. Its common separator survives arbitrary data-dependent raw-mean mixtures. Every failure probability is summable, so the first Borel--Cantelli lemma supplies the almost-sure subsequence conclusion on one fixed IID law. The theorem correctly retains a growing overparameterized learner-width requirement and does not claim inconsistency or a lower bound for one fixed finite learner width.

## Gaussian-noise and shallow-target extensions

Read `gaussian-noise-rate.tex` and `shallow-teacher-rate.tex` in full; both pass. Scaling only the comparison readout mean preserves its native Gaussian covariance and gives the exact stated RMS comparison. The Gaussian training-label cap contributes U^2 to energy and width and U^2 to witness norm, producing the log-cubed denominator in the fixed-law lower bound. Singleton chi-square tails and noise-target alignment remain summable.

The width-two fixed-point tanh code exactly preserves the first-layer features at all four first-coordinate support values, and the elementary determinant/coefficient intervals give a universal coefficient cap below four. The target itself is the fixed shallow unit-coefficient function tanh(x1), while deep realizability is only claimed on the actual support. The no-joint-polynomial-in-depth-and-inverse-accuracy corollary uses the accuracy exponent correctly; it does not claim a fixed-positive-accuracy exponential-depth lower bound or a fixed-learner-width inconsistency theorem.

## Gaussian-noise refinement and explicit depth theorem

The updated Gaussian-noise comparison clips only empirical atom means used by the proof comparison to [-2,2]. Its exponential clipping-cost bound and direct Gaussian population-witness bound remove earlier logarithmic energy, width, and risk losses. Old-block count control makes the fixed-law subsequence extension valid. The learner remains the original raw Gaussian-likelihood posterior.

The new finite-depth-rate.tex theorem was independently checked: D=4H, J=4, n=4*256^H, ambient d=4H+2; input covariance smallest eigenvalue at least 1/(64H); a shallow unit-coefficient tanh(x1) target; Gaussian noise variance 1/16. Native Fourier choices R=10^6 and U=1000H satisfy the explicit truncation and amplification requirements and yield mean comparison energy O_M(H^3) and width at most exp(C H). The augmented Gram perturbation at entry tolerance O(H^-3), Gaussian alignment, weighted occupancy, and common separator give excess at least c H^-6 uniformly over all temperatures, allowed widths/scales, and arbitrary raw-mean mixtures. All failure probabilities tend to zero, so probability at least 0.9 holds for sufficiently large H. The optional bounded-covariance affine output component is included. This is an exponential depth obstruction at inverse-polynomial accuracy and dimension linear in depth, not at fixed positive accuracy or fixed dimension as depth grows. No substantive gap was found.
