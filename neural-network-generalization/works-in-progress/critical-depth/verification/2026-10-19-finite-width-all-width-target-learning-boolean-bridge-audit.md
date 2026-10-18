# Frozen-source audit: target-based learning at every realizable width

Source: `source/critical-all-width-target-learning.tex`

SHA256: `12189cd5401374d9bb6749e9b502fb7c663a99b28fd7853b318b2f0eb967fef3`

Reviewer: `depth_boolean_bridge`.

## Verdict

The complete source passes. No correction is requested. This review checks the deductions and quantifiers in this section against the stated finite-width target-mass and intrinsic-learning theorems. The separate audit records for those analytic constructions remain the evidence for their underlying proofs.

## Mass-to-learning transfer and quantifiers

- A strict-margin realization has an open neighborhood in parameter space with the same margins, because the input cube is finite and network outputs are continuous in all parameters. The full-support finite-dimensional Gaussian prior assigns this neighborhood positive mass. Conversely, positive mass supplies a realization. A nonzero sign realization can be rescaled to strict margin on the finite cube. Thus the stated realizable-width equivalence is correct.
- For widths above the target-mass threshold, the raw target cost satisfies `a <= V_* + c T^2/L`. Since `L >= T`, the action prefactor is at most polynomial in `T`, while the square-root excess factor is at most `exp(C T)`. The hypothesis `T >= log(d+L+2)` absorbs all remaining dimension and depth factors.
- For widths below `exp(c T)`, the polynomial VC bound for the entire tanh architecture and Sauer's lemma on `2^d` inputs give logarithmic sign-class cardinality at most `exp(C T)`. This fallback requires no target-mass lower bound beyond positivity.
- Exact training fit removes every inconsistent function. A finite-class consistency bound then controls every supported sign function in the fallback, or the intrinsic theorem controls the posterior in the large-width case. Posterior expected error at most `epsilon/3` implies that the set with correct-label posterior probability at most `2/3` has mass at most `epsilon`. Mixtures of predictors introduce no missing majority-vote assumption.
- Positive target mass guarantees a positive conditioning denominator for every possible noiseless sample. The theorem is valid for each specified realizable width; it does not need a common high-probability sample event simultaneously over infinitely many widths.

## Substitutions

1. **Fourier targets.** The finite-width Fourier mass theorem has parameter a universal multiple of `log((d+L+2) A_F)`. Signed parities have `A_F=1`. Decision trees and arbitrary state-dependent width-two programs have the variation bounds cited in the source. Products of their resource parameters are bounded by a universal power of the displayed additive resource, so the polynomial substitutions are valid.

2. **Bounded threshold teachers.** The depth hypothesis leaves both the circuit-prefix depth and the required scalar-continuation depth. The finite-width circuit mass theorem uses exactly the stated `T`. A common sufficiently large tanh gain simulates all finitely many Boolean gates, including constant rails, while preserving subsequent gate signs. Propagating the scalar output through additional positive tanh layers preserves its sign. Thus every width at least the stated width including constant wires is realizable.

3. **Arbitrary-real threshold teachers and halfspaces.** The independently audited weight-independent compiler gives depth `O(h)` and universally polynomial width/norm, producing `T <= C h log R`. No original weight magnitude or precision enters. The source does not incorrectly claim the original width already includes an uncounted bias rail. A halfspace separately has a width-one realization: its bias is available at the input constant coordinate, and subsequent scalar tanh layers preserve the strict sign. Therefore its conclusion really holds for every `N >= 1`.

4. **Analog teachers.** The previous finite-precision compiler has universal polynomial degree independent of teacher depth, and depth `O(D+1)`. Consequently `T <= C(D+1) log R` and the stated sample exponent follows. The remaining dependence on the teacher weight bound is retained.

5. **Low-rank targets.** The audited grid construction has constant threshold depth and resources polynomial in `P`, `r`, and the number of boxes `(C P^2 sqrt(r))^r`. Their logarithms are `O(r log(P+r+2))`, which gives precisely the stated `S`, polynomial ambient factor, and `(P+r+2)^{O(r)}` term. The approximate-rank variant's readout rescaling changes the product bound to `8P/7` as stated.

6. **Solvable groups.** The frozen all-prefix compiler has depth `O(ell)` and universal polynomial width and gate norms in group order and program length. This yields `T <= C ell log R`, with no hidden polynomial degree depending on `ell`. The width-four permutation conclusion uses the fixed order and derived length of `S_4`; it retains the permutation convention and makes no claim about arbitrary noninvertible programs.

7. **Boolean blocking and formulas.** A block of `b` fan-in-two layers expands to two threshold layers with logarithmic resources `O(log(C_T+1)+2^b)`. For `k=ceil(h/b)`, the unoptimized finite-width parameter is bounded by the displayed `U_b`, including the depth and learner-depth terms. Choosing `b` of order `log log(S+L)`, capped by `h`, gives the stated exponent. Standard balancing gives polynomial formula size and logarithmic depth, yielding `exp(O(log^2 S/log log S))` for the stated polynomial learner-depth range. The source correctly distinguishes this finite-width parameter from the sharper optimized-prefix parameters proved only for the limiting construction.

The result removes the width-limit qualification for these target classes. It does not prove joint polynomial sample complexity for arbitrary small deep circuits, and the source states that limit accurately.
