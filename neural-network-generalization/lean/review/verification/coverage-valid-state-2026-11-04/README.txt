Verification of valid-hidden-state coverage, 4 November 2026

The actual Gaussian-conditioned learner with hidden states confined to [-1,1]
is proved with the original finite-class budget and polynomial envelope.
The literal trajectory support is equivalent to the finite-path condition.
Borel measurability follows from countably many compact closed projections.
The unchanged target cylinder, exact two-stage posterior, positive mass,
optional global clean margin, common all-width/all-scale sample event, Gibbs
risk and two-thirds confidence are all instantiated without compression or
stability oracles.

Both the original and improved constructive compressors now retain the actual
full activation-box invariant through selected histories and terminal sampling.
The prior raw comparison interface follows from the strengthened interface.
Other listed coverage gaps remain; no full-coverage claim is made.

Pinned Lean 4.32.0 and mathlib 81a5d257c8e410db227a6665ed08f64fea08e997.
The root build completes with 5297 jobs. All seven compiler/axiom gates pass:
CheckMain, CheckConfidence, CheckParity, CheckRobust, Audit,
CheckCoverageExtensions, and BatchTwoAudit. The ordinary audit checks 16101
proved project declarations; the extension gate checks 323 named
endpoints. Only propext, Classical.choice and Quot.sound occur transitively.
This is an incremental build, not a fresh rebuild of all external packages.

The comment/string-aware scan covers 2064 project
Lean files and finds no proof-placeholder or bypass tokens. All 561 checked
paper/source files are byte-identical to 7de35de5. The conditional package
is unchanged; its earlier fresh-build evidence is linked in record.json.
Source hashes for all 21 changed or added Lean files are recorded.
