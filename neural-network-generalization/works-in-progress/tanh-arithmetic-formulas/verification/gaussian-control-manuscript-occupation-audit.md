# Independent audit of the assembled Gaussian-control manuscript

25 October 2026. Audited `manuscripts/gaussian-control-formulas.tex`, final SHA256

`4b1338b65d7d2aecd7ee4eb31cf76f4eb08542dfe9e3724b1ca6c618776b41e9`.

Verdict: the assembled theorem and proof pass this independent mathematical audit. This is conventional verification, not Lean or kernel verification.

The manuscript preserves the necessary hypotheses and mechanisms from the detailed centered and noncentral notes: positive covariance singular values, Hilbert--Schmidt perturbations relative to actual coordinate copies, dimension-free quadratic sampling, a separately tracked relative-variance scalar, transient rather than persistent b helpers, degree-dependent averaging, and joint charging of a large mean/covariance stage. Its deterministic upper variance starts in (1,2] for the stated cube input and is at most one after the first free step, so the stated telescoping bound remains valid.

I independently checked the ordinary one- and two-variable Fourier precision argument: conditional output noise protects against phase cancellation; independent child variance floors protect normalized factor coefficients; mixture coefficients are controlled by conditional second moments and expected call count. This handles arbitrarily tiny original control coefficients without a hidden bit-size hypothesis. The initial normalized Boolean input formulas supply the required bounded base coefficients.

The following presentation repairs were requested and are incorporated in this version:

1. Zero corrections are omitted, so a completely free path never divides by a zero branch probability.
2. The mixed derivative statement includes the fifth-order derivative needed when the fourth b derivative is combined with a fundamental-theorem-of-calculus step in t. The underlying smoothness argument supports every fixed order.
3. The finite-seed correctness event retains a strict majority of individually good groups at every input. Rounding uses a uniform absolute error bound; bad groups are not assumed to have a margin.
4. The near-baseline corollary explicitly controls the sum of D_j as well as the sum of sqrt(D_j), using the universal baseline action bound.

The main theorem concerns all finite-entropy Gaussian mean and covariance controls. It does not identify unrestricted posterior row tilts with Gaussian controls. The near-baseline corollary imports the existing critical occupation theorem and is correctly restricted to the Gaussian subclass. The manuscript explicitly states that the original unrestricted NNBayes depth question is not resolved.

## Updated baseline and nonvacuity audit

The original near-unrestricted-baseline implication above was formally valid
but asymptotically vacuous. The revised manuscript fixes that interpretation.
I independently audited its final section at TeX SHA256

`2ecc9d221a6da039d426375eee70feb3a0a900a8cef51941fb3f25f52a34bd1b`.

**Verdict: PASS.** In particular:

* The compact crossing proof establishes a strict universal gap
  (V_*^G>V_*), including Gaussian means. Its fixed-output entropy optimizer
  is an exponential tilt by bounded tanh-square, so it cannot coincide with
  any nontrivial Gaussian. Compactness keeps the saving uniformly positive.
* The Gaussian bridge, monotonicity, and increasing-path reduction remain
  within the Gaussian class. The explicit upper bound below two is the
  earlier all-Gaussian construction, with the same integral and final-step
  costs.
* For maximum query variance, the scalar dissipation inequality follows by
  choosing the input attaining the post-step maximum and using monotonicity
  of (p-cp^2). The Gaussian suffix Bellman bound is valid for an input
  attaining any intermediate maximum. These give the displayed occupation
  estimates and (V_*^G-C/H) lower action bound with no equal-diagonal
  assumption on a general path.
* The all-target attainability proposition is valid from the prescribed
  augmented-cube input. I checked the source construction separately in
  `gaussian-own-baseline-nonvacuity.md`: all prefix stages are Gaussian,
  smaller tracked components merely choose covariance decompositions, and
  a Gaussian scalar suffix remains Gaussian after lifting. Its exact-depth
  holding and action accounting give the stated (S_f)-dependent excess.
* Constants and dictators have (S_f=O(log(d+1))), so the corrected
  own-baseline corollary really is nonempty in its polynomial-resource
  range. The final warning correctly leaves unrestricted row tilts open.

This updated verdict concerns conventional mathematical verification only;
the manuscript has not been formalized in Lean.
