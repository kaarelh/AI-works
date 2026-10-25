# Independent audit of the Fourier-increment low-product compiler

25 October 2026. Audited Fourier-increment-low-product-compiler.md.

**Verdict: PASS**, conditional on the already audited normal-form and
finite-bit components explicitly imported by the note. This is conventional
mathematical verification, not Lean verification.

I checked the increment factory directly. The compound-Poisson second
moment is

    E|Z-1|²=exp(omega² EX²/lambda)-2cos(omega EX)+1,

and is bounded by a universal multiple of min(omega² V,1). The work is
O((1+omega² V)T). Importance sampling with density proportional to the
square root of moment divided by work gives the stated
work-times-second-moment bound. The weighted first Fourier moment makes
both integrals finite, even when the Fourier measure has infinite variation
near zero. No second Fourier moment is used.

The activation changes in the width-compression proof are correct. Large
row deletion only changes its bound by the fixed activation amplitude.
The small-row error is c tau^kappa R^(1+kappa) S ||W||F. Replicating the
linear singular channels gives propagated error
C P_* (c0 nu S²/K)^(kappa/2) R^(1+kappa), with the same exact pair-product
norm as before. All required replication counts remain polynomial for
fixed positive kappa.

The mixed normal form avoids an unjustified saturation assumption:
only the retained prefix uses the original activation, while the existing
tanh classifier handles the new suffix. The bounded-activation margin
bound controls retained prefix products. The local inverse supplies a
constant rail with only a fixed norm factor per logarithmically many
layers. Tiny-prefix linearization and collapsing runs give polynomial
physical weights; ratios of original prefix products bound the composed
matrices even if cancellations shrink their actual product norms.

The finite-bit argument has the hypotheses it needs: bounded total work
and second moment, input-independent sampling, multilinear increment
polynomials, and fixed-dimensional complex arithmetic. The moment-floor
normalization and category representation do not require a lower Fourier
frequency or an extra Fourier moment.

The spectral examples check. Normalized erf has Gaussian derivative
measure, arctan has Laplace derivative measure, and softsign has the stated
Gamma mixture of Cauchy measures. Each has total derivative-measure mass
one and no atom at zero. Softsign only needs its quadratic local remainder,
not analyticity.

The conclusion correctly concerns an alternative arithmetic-sign
representation. It does not silently provide a posterior energy ceiling
for these activations, extend to unbounded ReLU/GELU, or solve the arbitrary
conditional-tilt problem at gamma one.

## Assembled public appendix

I additionally audited the assembled public source

    neural-network-generalization/works-in-progress/tanh-arithmetic-formulas/
      source/fourier-activations.tex

at SHA256

    4c0ab850d09e814e0bb495b1d498e463c968026c5ad0120d95533861c8dea89e.

The assembled appendix replaces the imported moment-floor precision
argument with a correct explicit spectral truncation. Low frequencies are
replaced by their linear term, and high frequencies are dropped; the
uniform error is M eta B^2/2+2M/U. The cutoffs can have logarithms
O(log^2(d+P)), without harming polynomial work-times-moment potential.
The truncated activation is at most 2M-Lipschitz, and the stated hybrid
error estimate explicitly accounts for that factor across logarithmic
depth. Its quasi-polynomial frequency range affects only coefficient bit
length, which remains polynomial.

The fixed nonzero spectral band gives the stated lower normalization
bound, while the positive linear-branch moment bound avoids division by
an arbitrarily tiny linear coefficient. Together with the dyadic physical
weights these estimates justify the deterministic logarithmic scale
recurrence and final rounding. The coded analytic activation's derivative
Fourier variation is summable by the displayed bump estimate; this does
not conflict with its large-product depth counterexample.

The one missing backslash in the real-part operator was reported and is
fixed in the hashed version. **Assembled verdict: PASS.**
