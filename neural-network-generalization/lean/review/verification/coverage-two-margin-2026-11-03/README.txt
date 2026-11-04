Verification of the two-margin coverage extension, 3 November 2026

The numerical two-margin transport proposition is now proved for the actual
Gaussian posterior, with the same universal polynomial envelope, strict
training likelihood, test margin, all-width/all-scale event and confidence
consequence. Optional global clean-margin conditioning is covered. The exact
localized union, same-input and pilot-selected variants are instantiated.
The scalar margin-band formula, support inclusions, interval certificate and
strict-weakening examples are also checked. This is not full paper coverage:
arbitrary transforms, general margins and other gaps remain in the inventory.

Pinned Lean 4.32.0 and mathlib 81a5d257c8e410db227a6665ed08f64fea08e997.
The root build completes with 5258 jobs. All seven compiler/axiom gates pass:
CheckMain, CheckConfidence, CheckParity, CheckRobust, Audit,
CheckCoverageExtensions, and BatchTwoAudit. The ordinary audit checks 15782
proved project declarations; the extension gate checks 227 named
endpoints. Only propext, Classical.choice and Quot.sound occur transitively.
This is an incremental build, not a fresh rebuild of all external packages.

The comment/string-aware scan covers 2026 project
Lean files and finds no proof-placeholder or bypass tokens. All 561 checked
paper/source files are byte-identical to af02df9b. The separate conditional
package is unchanged; its earlier fresh-build evidence is linked in record.json.
Source hashes for every changed or added Lean file are included in the record.
