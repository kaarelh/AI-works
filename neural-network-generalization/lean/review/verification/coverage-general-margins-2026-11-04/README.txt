Verification of general training/test margin coverage, 4 November 2026

The literal clipped-score Gaussian learner is proved for arbitrary m>u>=0,
with strict training margin m, test margin u, clipping at +/-m, and variation
tolerance (m-u)/4. A universal polynomial adds m and the inverse margin gap.
The same sample event covers all widths/scales and optional global clean-margin
conditioning. Positive target mass, posterior entropy, exact two-stage
conditioning, Gibbs risk and two-thirds confidence are instantiated.
The quantitative target cylinder is proved with margin-dependent readout cost.
The original half/quarter support and sign-only 1/8 tolerance are checked.
A stronger saturated monotone-score theorem is included across general margins.
General two-margin transport and other listed gaps remain open.
No full-coverage claim is made.

Pinned Lean 4.32.0 and mathlib 81a5d257c8e410db227a6665ed08f64fea08e997.
The root build completes with 5315 jobs. All seven compiler/axiom gates pass:
CheckMain, CheckConfidence, CheckParity, CheckRobust, Audit,
CheckCoverageExtensions, and BatchTwoAudit. The ordinary audit checks 16312
proved project declarations; the extension gate checks 391 named
endpoints. Only propext, Classical.choice and Quot.sound occur transitively.
This is an incremental build, not a fresh rebuild of all external packages.

The comment/string-aware scan covers 2082 project
Lean files and finds no proof-placeholder or bypass tokens. All 561 checked
paper/source files are byte-identical to 8bd3d73a. The conditional package
is unchanged; its earlier fresh-build evidence is linked in record.json.
Source hashes for all 12 changed or added Lean files are recorded.
