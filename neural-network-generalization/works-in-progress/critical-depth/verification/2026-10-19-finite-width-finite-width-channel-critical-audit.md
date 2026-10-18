# Independent audit: finite scalar channel and Fourier target mass

Reviewed by the critical-depth agent, 2026-10-19.

Source: `source/critical-finite-width-channel.tex`.

SHA256: `6a45c4abf1df7a1e503d5dd5d7449ee4c4822ca86df16574eff6f007abe68dde`.

The complete source passes this audit, including its quantitative Fourier application and approximate-prefix corollary.

## Generic finite-channel mechanism

The score is a unit vector in the appropriate L2 space, even if it has nonzero mean. Orthogonal projection onto it bounds the joint coefficient/residual-norm discrepancy by the feature L2 discrepancy. The empirical normalized score yields an exact physical unit vector and positive-semidefinite residual. Thus no full covariance approximation or common cross-input residual coupling is being assumed.

The Gaussian second-moment entropy inequality applies to noncentered scalar controls as well, and yields the stated e^{sqrt(D_j)} RMS multiplier. Conditional independence of new rows permits Hoeffding simultaneously over the finite input set. The computed alpha produces alpha^{-2} proportional to H^4 e^{4S} kappa^{-4} v_H^{-2}; v_H^{-1}<=8A and the kappa definition give precisely the displayed polynomial factors. Score stopping can be implemented by using an arbitrary fixed unit vector after failure; this does not change the success or entropy estimates.

The final readout shift has the exact normalized Gaussian cost t^2/2. Its noise variance is at most 1/N at every input. The strict margin, controlled success probability and binary-entropy comparison all have slack in the displayed constants. Auxiliary reference kernels preserve the original Gaussian weight marginals, so data processing gives a lower bound for the original raw prior.

For the approximate-prefix version, the propagated initial error contributes at most kappa sqrt(v_M)/64, and the stated sampling tolerance contributes at most kappa sqrt(v_M)/16. Their sum is below kappa sqrt(v_M)/8. Prefix and continuation entropies add by the causal chain rule.

## Quantitative Fourier application

I checked the earlier controlled-Fourier, target-seed upper, exact-purification, scalar-path and scalar-lift sources against this application.

- The parity/Fourier mixture is realized by actual first-row Gaussian shifts with component and symmetrization tags. Using identical tag probabilities under the reference law gives joint entropy at most D_*, and dilution yields at most 1/L. The rare-tag score gives exactly v_1=theta/Z_f^2, rather than a squared-mixture approximation.
- Free cooling may use the bounded conditional-mean score. Its squared norm dominates the first-Hermite tracked component used in the cooling proof. It is nonincreasing along free steps, and at the endpoint remains at least c delta v_1. Thus every free-step component is inverse-polynomial in R.
- The deliberate reduction to v_0=delta exp(-C S_0) has S_0=O(log R) and delta>=c/L. The independent sign score implements this exactly and is bounded by 1+v_0^{-1/2}. Holding keeps v_0 fixed, prescribed growth increases it, and purification keeps the exact component p fixed. None creates a smaller signal.
- The final scalar path is strictly increasing from p>=c/L and has at most C/p steps. Purification leaves residual at most C delta L^{-4}; hence the stable lift retains a fixed positive fraction of every nominal state. All its conditional-mean scores are bounded by a polynomial in R.
- The scalar entropy-budget proof is valid for the program's upper entropy costs. Actual feature entropy is no larger, so dissipation still holds; every programmed suffix including its possibly nonminimal readout costs at least the corresponding scalar value. Therefore all prefix inequalities hold for the upper costs. Its total excess gives S=O(log R), even when total A itself grows at the minimum learner depth.
- Substitution of tau=1/L, B<=R^C, e^S<=R^C and A<=V_*+C log^2(R)/L into the generic width bound gives N>=R^c with a universal exponent. No exponential input-set size or e^{poly(L)} width factor remains.

No mathematical correction is requested. The corollary proves the asserted raw target probability bound; its statement correctly keeps the separate competing-mass/learning step separate.
