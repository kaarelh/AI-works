# Independent whole-source audit of the monotone activation theorem

Auditor: `exact_search`, 7 November 2026. This is an independent AI mathematical review, not formal verification or an external referee report.

Reviewed the complete standalone manuscript `../monotone-paper/source/paper.tex`, including the atomic appendix and the remark on small periodic perturbations. The reviewed integrated source had SHA-256 `06dae35bb69906f719adfa281a0095ffff77bd12c54fae5394b220e112842e01`; subsequent minor notation and zero-case clarifications are listed below. I also checked the PDF's calibration argument visually and found a clean build log.

**Verdict: no substantive mathematical gap found.** In particular, the new affine component is controlled for arbitrary competing networks, rather than assumed to cancel. The proof supports the stated fixed strictly increasing 1-Lipschitz activation and retains the exact large-width, cold-prior, and long-calibration qualifications.

## New affine-component argument

For an arbitrary representation, the decomposition `F=L+epsilon T` uses the original, unreduced parameters in the affine part `L`. Modulo-two reduction is applied only to the auxiliary triangle ridges. Thus no invalid periodicity assumption is made about the monotone activation itself.

The new residual estimate `||(I-P)h_theta||_2<=e_theta` follows from the earlier rounding: in a far case the whole triangle ridge has L2 norm at most the reduced parameter norm; in a localized case its L2 distance from a pure code character is at most the perturbation norm. Orthogonal projection is contractive. This estimate survives the global signs introduced by parameter reduction.

Let `R=T-PT`. On each calibrated logical fiber, `Y=chi_C(L+epsilon R)` has mean zero because its code projection vanishes. The pointwise signed margin gives `s>=-yY`, so `s>=E|Y|/2`. The calibration dual has absolute value at least two on every known fiber, yielding the stated lower bound on its slack by the *unconditional* known-set average of `|L+epsilon R|`.

For the affine coefficient norm `A`, the moment facts `E L^2=A^2` and `E L^4<=3A^4` hold including a deterministic bias term. Interpolation therefore gives `E|L|>=A/sqrt(3)`. Removing a set of probability `1/16` costs at most `A/4`, regardless of its dependence on `L`. The residual contribution costs at most `epsilon B`. These facts establish the affine penalty without an independence assumption.

Writing `beta=epsilon B`, I checked the convex combination explicitly: weight `kappa/[sqrt(c)(1+eta)]` on the affine inequality produces the coefficient `kappa eta/(1+eta)` on *both* `A` and `beta`. Since `eta=1/sqrt(3)-1/4>1/4`, this coefficient exceeds `kappa/5`. The sign-change and failed-core-oddness alternatives then force `A+beta>=1/(2sqrt(D+1))`. The resulting non-code barrier and the choice `c=10^8(D+1)^3+1` separate all non-code completions from the stars; the ratio of the star excess to the claimed non-code excess is below `0.15 D/(D+1)`.

## Exact norm, teacher, and finite-width witnesses

The four orientation rows have positive row products and balanced columns. Pairing the remaining coordinates preserves both properties. Consequently their affine terms cancel exactly while their triangle components produce the same parity. The resulting exact monotone code norm is the triangle weighted norm divided by `epsilon`; the lower bound follows because every code character has degree at least three and therefore annihilates all affine terms.

All costs and barriers in the latent classification section are consistently interpreted as *scaled* neural variation costs. In particular, the correct-label gap is `(C_v+Delta)/epsilon`, and the finite-width star energy limit is `2sqrt(d) C_v/epsilon`. I found no unscaled triangle-only energy claim carried into the monotone theorem.

Each oriented star atom has total readout `|b_s|/(4epsilon)`. Rounding its clone count changes neither that total readout nor its exact output. Therefore unequal clone counts do not break affine cancellation. The sum of ideal allocation fractions is below one for the stated parameters, so all sufficiently large integer widths are covered, not only a subsequence.

For the teacher, each odd parity term has four incoming vectors with coordinates zero or `+/-1` and four readouts of magnitude `1/(4epsilon)=3/4`. The original `2m-1` parity terms therefore give exactly `8m-4` unit-bounded neurons. The score retains absolute margin at least one. The explicit definition of `C_2` concerns actual predictor coefficients, and `C_2(f_m)<=8m-4` follows.

## Remaining theorem and scope

I also rechecked the unchanged latent dual, subgroup versus nonsubgroup classification, cyclotomic/radical strict ordering, and the exhaustive categories of correct-label completions. The exact gap orders sign functions; it does not select a representative parameterization or disregard tied parameter minima.

The canonical Gaussian whitening and energy normalization are unchanged and explicit. The strict-margin wrong witness gives an open positive-volume denominator ball. A Gaussian tail bound for the *entire* correct-label event then proves actual posterior concentration. The width threshold is common to finitely many rounds at each fixed `m`, the variance limit is taken at fixed width, and the source explicitly enlarges the threshold to the teacher width so the whole input permutation has well-defined posteriors.

The activation is correctly described as odd, unbounded, strictly increasing, and 1-Lipschitz, with slopes `1/3` and `1`. The paper does not call it bounded or claim a result for tanh, ReLU, GELU, or hardtanh. The small-perturbation remark is qualitatively valid for fixed `alpha>epsilon>0`: its Lipschitz constant may differ, the exact code costs scale by `1/epsilon`, and the fixed core prefactor and teacher replication may depend on epsilon. No uniformity as epsilon tends to zero is claimed.

The dimensions remain `Theta(m^6)`, the mistake count remains `2^(m-4)`, and the displayed teacher width is `8m-4`. Hence the explicit-width formula `2^((w_m-28)/8)` is correct. The calibration still covers `15/16` of the physical cube. The manuscript distinguishes stretched-exponential dependence on dimension from exponential dependence on displayed teacher width, and does not claim a polynomial learner-width threshold or a width-uniform variance threshold.

## Minor presentation points sent to the author

The known logical set and the number of designated rounds both used `K`; the known set is now written `mathcal K`. The author also handled the zero reduced-parameter case explicitly and made the small-radius and combined-penalty comparisons weak at zero. I checked these edits in source SHA-256 `36252ee3513ab1d17f7db22f5a94c40a66791679624446941d135d41387b7c0a`. They resolve the boundary and notation points without changing the argument.

The mathematical proof is self-contained and imports no theorem from the bibliographic reference about periodic activations. I did not independently check that external citation's bibliographic metadata.
