# Verification record

Checked on 6 November 2026. These are independently checked mathematical research records, not Lean formalizations. No experimental optimization output is used as a proof.

- The shallow and fixed-depth affine-ridge notes were independently reviewed by two research agents (`wide_geometry` and `wide_numerics`).
- The all-depth sparse-embedding note was independently reviewed by `wide_geometry`, including layer counts, rounding, the tanh reciprocal bound, both depth regimes, and the displayed loose constants.
- The potential/convex-relaxation note and the scalar-AND descent note were independently reviewed by `wide_tanh`, who did not write their original arguments.
- The fractional-affine-norm certificate and its Cauchy–Schwarz proof were independently reviewed by `wide_tanh`. The published standard-library verifier was run successfully and checked all 512 cube margins and all rational dual identities.

The mathematical scope is part of the result: the affine-ridge notes are conditional obstructions to a particular reduction; the other notes refute specific shortcuts. None establishes an unrestricted online-mistake upper bound or an exponential online-mistake lower bound.

## Checked file snapshots

- [SHALLOW-RIDGE-OBSTRUCTION.md](SHALLOW-RIDGE-OBSTRUCTION.md): SHA256 `397917bb9ac0758fc2b1d370ac37e56df6a64749a18ad9b9c7b5019030414f52`.
- [FIXED-DEPTH-RIDGE-OBSTRUCTION.md](FIXED-DEPTH-RIDGE-OBSTRUCTION.md): SHA256 `ca44b23ba4de80a8a6c3ae5310da84f89e31ec99cf74e0b243673617549f0aef`.
- [ALL-DEPTH-RIDGE-OBSTRUCTION.md](ALL-DEPTH-RIDGE-OBSTRUCTION.md): SHA256 `1e5e133e66a92635396d82aa7f4c558978d35129628cde6f6270d916770fbab0`.
- [POTENTIAL-OBSTRUCTIONS.md](POTENTIAL-OBSTRUCTIONS.md): SHA256 `c0fb2c7b6da3dd3c3037a1def03729124a5f727517fc93227c9392ee9b1ad2e5`.
- [AND-SCALAR-OBSTRUCTION.md](AND-SCALAR-OBSTRUCTION.md): SHA256 `00c8bfb96d1565bafd9ad3334195788b787ac8ab1175ad0b1b014a086d15b129`.
- [FRACTIONAL-AFFINE-NORM.md](FRACTIONAL-AFFINE-NORM.md): SHA256 `c69bac6e72a2991de03fc9441aad49f01d268718a19e3b046b8810367ec77d78`.
- [fractional-ltf-certificate.json](fractional-ltf-certificate.json): SHA256 `725ea04c90080b35d95c77293a6dd440be175e076e964f21721c5363135c4140`.
- [check_fractional_certificate.py](check_fractional_certificate.py): SHA256 `0d00b7d5b0bcff79f20a12d698c513abbbe7d8f32904b3951241fe9dfae3f635`.
