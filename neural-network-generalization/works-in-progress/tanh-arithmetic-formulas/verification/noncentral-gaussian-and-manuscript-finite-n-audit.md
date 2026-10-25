# Independent audit of the noncentral Gaussian compiler and manuscript

25 October 2026. Finite-N audit agent. Conventional mathematical audit; not Lean verified.

**PASS.** I read the complete `noncentral-gaussian-scalar-formulas.md` and the assembled eight-page manuscript `manuscripts/gaussian-control-formulas.tex`, against the centered variable-diagonal compiler and the finite-bit machinery already audited separately.

Audited source hashes:

- noncentral note: `64a0ec90183c668e42862bd9ddcb595f8f46904ff905dad25904949de4ad5335`;
- manuscript at the original audit: `9d7f5dc0b5a82a1c4d5de32d0cbf2e75f117a877b2ef0595b44e97c93cc5341a`;
- manuscript after the final clarifications checked below: `4b1338b65d7d2aecd7ee4eb31cf76f4eb08542dfe9e3724b1ca6c618776b41e9`.

No substantive correction was needed. The final manuscript incorporates the minor clarifications that H>=1, the majority rather than every individual formula agrees with the target, repeated complex-product children preserve their sampled coefficients, and fixed absolute rounding error preserves the good groups.

The final clarifications were checked again after assembly. The coefficient lemma now explicitly supplies every fixed mixed derivative, including order five: the H4 tail estimate involving four b derivatives uses one further t derivative. Its proof already supplies this bound. The near-baseline corollary explicitly states that V_* is universal and that sum D <= V_* + epsilon = O(1+epsilon); thus the additional epsilon in its resource exponent is justified directly. The shortened final scope paragraph continues to exclude unrestricted non-Gaussian row tilts and does not claim a solution of the original learning question. These changes preserve the PASS verdict.

## Noncentral feature identities and estimates

Writing the preactivation as `sqrt(t)(Z+b)/sqrt(1+b^2)` is exact with the stated `t`, `b`, and normalized Gaussian direction. The full ordered-tensor Hermite representation preserves every query-query inner product even when both parameters vary with the query. Degree zero must be retained and is retained.

The normalized shifted Gaussian has uniformly bounded fixed moments and uniformly polynomial Gaussian envelopes for fixed b derivatives. The small-ball lower bound from its unit second moment and fourth moment at most three supplies a uniform denominator bound. This justifies the removable-t=0 formulas and the mixed Sobolev estimates. Gaussian second-derivative Parseval gives the exact weighted tail bound `sum_(k>=2) k^2 c_k^2<=8t^2`. Vanishing of the entire tail at t=0 also holds after b derivatives, so scaling t=ar gives the required factor a in every fixed mixed H4 derivative.

The two-dimensional Fourier density `(1+|omega|^2)^-4` has finite fourth moment and matches the H4 coefficient bound. The Poisson child is a sum of independently sampled coordinate estimators, with uniformly bounded second moment after frequency scaling. The real-formula quadratic expansion cost is fully charged.

The scalar envelope `tanh^2(z)<=z^2/(1+z^2/2)` follows from the displayed supersolution comparison. Concavity then gives the universal second-moment envelope G, including nonzero Gaussian means. The common upper variance recursion and its reciprocal cooling telescope are valid.

## Small and large control accounting

Both norm corrections are Hilbert--Schmidt quadratic forms; the extra mean term is rank one with Hilbert--Schmidt norm `||m||^2`. The leading feature can equivalently be viewed as the normalized linear map `u -> (<m,u>,Au)`, an isometric coordinate injection plus a Hilbert--Schmidt perturbation. Its rare mean-coordinate creation and inverse-norm correction therefore have the stated small joint budget.

The helper `b/M` is constructed from actual scalar oracles, with a bounded second moment at small controls. It is called only inside charged rare branches. The noise direction and leading direction are alternative local oracle families; the proof does not permanently duplicate the trace budget or hide vector sharing.

For degree zero and one, the summed cross term is exactly `<Y_b,phi_(t,b)>-1<=0`. It is correct to use this summed inequality; separate signs for the two coefficient residuals are neither assumed nor needed. Independent residual estimators contribute only `O(a)` additional trace. The higher-degree tensor products have independent coefficient and direction estimators and are controlled by degree-dependent averaging.

At a large joint stage, the minimum covariance singular value bounds the inverse norm. Rescaling the helper by `max(1,M/rho)` controls its second moment. Its parameter-range cost is polynomial and is charged to that same large stage, rather than repeatedly at later free layers. The total logarithmic charge is `O(kappa+M+log(1/rho)+ell(a))`, as claimed.

## Precision and final theorem

The ordinary Fourier-factory conditional noise argument extends to two variables: independent input noise floors bound the variance of the frequency linear combination even if its means cancel. Each normalized factor has at most three bounded coefficients. Conditional product RMS, mixed output RMS, and the expected-call-count argument give polynomial logarithmic coefficient bounds on a polynomial-size good seed. Arbitrarily small original entries, Fourier coefficients, and query norms do not introduce hidden reciprocals into the final tree.

The positive covariance square root acts in the current Fock coordinates after transporting the finite query span, and its Hilbert--Schmidt and inverse-singular-value costs are bounded by `C(sqrt(D)+D)`. The final normalized feature has the same sign and at least the original signed margin under the same readout. Thus the main arithmetic-formula/PNC1 statement follows with the displayed resources.

The near-baseline corollary correctly retains the additional `+epsilon` term from sum D. Its specialization at `epsilon=O(log^2 Q/H)` and `H>=c log Q` is polynomial in Q. The imported occupation estimate is used only for valid paths; the manuscript does not assert that arbitrary posterior row tilts are Gaussian.

The accompanying note `all-gaussian-path-pnc1-corollary.md` records the exact finite-span semantics, infimum/nonattainment treatment, and why the unrestricted posterior ceiling does not automatically transfer to this Gaussian subclass.

## Later correction: the Gaussian class's own scalar baseline

Later on 25 October, the strict baseline-gap result established that the earlier Gaussian implication near the unrestricted baseline was asymptotically empty. Its conditional proof was correct, but its useful scope required correction. See `gaussian-scalar-baseline-gap-independent-audit.md` for my independent check of the gap, Gaussian-own occupation, and inverse-depth lower bound.

I freshly checked the final eleven-page manuscript, SHA256 `2ecc9d221a6da039d426375eee70feb3a0a900a8cef51941fb3f25f52a34bd1b`. The inserted final section and abstract correctly use the Gaussian baseline V_*^G, prove its strict separation from V_*, and state the nonvacuity limitation. The direct compiler theorem is unchanged. The final corollary scales the readout only after using the original action in occupation, as required.

I also read the detailed own-baseline attainment note, `gaussian-own-baseline-nonvacuity.md`, SHA256 `3d4a0c66ae220ee44a64e37a365af49f87e571b8839a97ac5b04209e2b13fd11`, and checked its incorporation into the final proposition. The seed, cooling, holding, growth, purification, and Gaussian scalar suffix remain Gaussian under the covariance decomposition and data-processing argument. The dyadic short-suffix proof uses only the Gaussian value's own bridge/Bellman/dissipation estimates, so no unrestricted suffix is imported. The exact-depth holding schedule and the displayed S_f^2/H plus log^2(H)/H action accounting agree with the construction. The first-Hermite and full-cube spectral bounds give the stated simple-target and general-target seed costs. I find no substantive omission in the manuscript's compressed statement of this imported construction.

**Final assembled manuscript verdict: PASS**, with the Gaussian-own-baseline scope now explicit.
