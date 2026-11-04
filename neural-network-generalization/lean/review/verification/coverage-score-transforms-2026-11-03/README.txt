Verification of monotone-score coverage, 3 November 2026

The arbitrary odd monotone 1-Lipschitz saturated-transform theorem is proved
for the actual Gaussian posterior. One universal coefficient and degree
precede the transform; its only additional parameter is the inverse positive
gap. Global, optional-clean-margin, localized-union, same-input and independent
pilot variants are instantiated. Exact two-stage conditioning is checked.

The target-cylinder proof now exposes the stronger strict noisy signed margin
above one, with the same Gaussian mass polynomial. The full-gap minimality
identity and support inclusion are proved. The margin-band specialization has
the original literal compressor resources and finite-class sample budget.
Other coverage gaps remain in the inventory; no full-coverage claim is made.

Pinned Lean 4.32.0 and mathlib 81a5d257c8e410db227a6665ed08f64fea08e997.
The root build completes with 5275 jobs. All seven compiler/axiom gates pass:
CheckMain, CheckConfidence, CheckParity, CheckRobust, Audit,
CheckCoverageExtensions, and BatchTwoAudit. The ordinary audit checks 15913
proved project declarations; the extension gate checks 259 named
endpoints. Only propext, Classical.choice and Quot.sound occur transitively.
This is an incremental build, not a fresh rebuild of all external packages.

The comment/string-aware scan covers 2043 project
Lean files and finds no proof-placeholder or bypass tokens. All 561 checked
paper/source files are byte-identical to 114e6c76. The separate conditional
package is unchanged; its earlier fresh-build evidence is linked in record.json.
Source hashes for all 21 changed or added Lean files are in the record.
