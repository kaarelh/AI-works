# Verification record

25 October 2026. This is a conventional mathematical verification record, **not a Lean formalization and not human peer review**.

## Scope

The paper proves a finite-width exponential-depth confidence lower bound for tanh with a fixed mean-field variance prefactor `t>1`. The original exact coefficient-one prior `t=1` is not covered. All statements retain the global absolute margin and exact-fit posterior conventions.

Two fresh AI agents independently reviewed the proof:

- [Finite-width audit](finite-width-audit.md): empirical scalar/pair/matrix quality, actual all-label Gaussian mass, correct-marginal covariance coupling, parameter order, exact readout comparison, and the posterior conclusion.
- [Occupation and contraction audit](occupation-audit.md): simultaneous scalar/pair maxima, upper and lower spectral drift, local Bures geometry, and their empirical application.

Both then read the standalone manuscript and reported that its compressed presentation preserved the checked arguments. The audit texts retain historical filenames for the development notes they reviewed; those arguments are consolidated in the self-contained [paper source](../source/paper.tex). Subsequent introductory edits clarify the mean-field prefactor convention, compatibility with fixed-depth positive bounds, and relation to prior random-network and Gaussian-process literature; they do not change the proof inequalities.

## Checks that matter

- The common empirical error is `ζ(v)=v^(1/4)+v`; the pair estimate is not silently replaced by the stronger matrix-only square-root rate.
- The conservative uniform-process threshold is `m^4 log(eN)/N`, with `m=2^d`.
- A near-unit largest eigenvalue does not imply a near-unit smallest eigenvalue. The proof tracks a separate lower-eigenvalue potential.
- Hidden bad-event and readout-tail exponents exceed the full-margin mass exponent with strict slack.
- The width exponent is chosen before the large depth multiplier; the target-mass width exponent is independent of that multiplier.
- The coupling uses rotations depending only on earlier layers. No invertible transport of hidden weights or hidden-law Jacobian is assumed.
- Pairwise deterministic probability comparisons do not need a union bound over all truth tables.

## Supporting notes

The [nearcritical audit](nearcritical-audit.md) checks the explicit inverse powers of `ε`, uniform mass bound, and final width/depth choices in the [nearcritical note](../research-notes/nearcritical-prefactor.md).

The [majority audit](majority-audit.md) checks the near-uniform affine-parity counterexample and the independent-posterior-ensemble bound in the [majority note](../research-notes/majority-prediction.md). Neither note proves an exact-majority lower bound for the neural posterior, nor resolves the canonical `t≤1` depth question.

The [sign-only audit](sign-only-audit.md) checks the separate [raw-prior sign-conditioning theorem](../research-notes/sign-only-conditioning.md), including the exact Gaussian orthant comparison and exceptional probability relative to `2^(-m)`. This variant removes the global margin but still assumes the supercritical hidden prefactor `t>1`.

## Reproducibility

The paper is rebuilt in a fresh isolated directory using only `source/paper.tex` and `build.sh`. The [build record](publication-build.json) records the source and PDF hashes, page count, equality of extracted PDF text, and LaTeX warnings. This confirms reproducibility of the artifact; it is not a mathematical proof check.

## Bibliographic check

The related-work paragraph credits the established free covariance recursions and ordered/chaotic phase analysis. Titles, author lists, and publication details were checked against primary sources on 25 October 2026: [Poole et al.](https://arxiv.org/abs/1606.05340), [Schoenholz et al.](https://arxiv.org/abs/1611.01232), and [Lee et al.](https://arxiv.org/abs/1711.00165). The paper distinguishes those results from its finite-width comparison after rare global-margin conditioning.
