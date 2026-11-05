Verification of general two-margin transport coverage, 5 November 2026

The actual Gaussian learner with general two-margin transport is proved for
m>0, u>=0, theta>=0 and theta<(m-u)/2. The literal four levels and both labels
are used. Borel support, target-cylinder mass, exact two-stage conditioning,
entropy, common finite compression, all-width/all-scale learning and optional
global clean-margin conditioning are instantiated without analytic oracles.
The exact arbitrary-rounding-error transfer and a universal polynomial bound
in m and the inverse residual gap m-u-2 theta-2 e are proved for every e>=0
with positive gap. Clipped-support inclusion, exact numerical specialization,
and test-implication redundancy under global clean margin are included.
Other listed gaps remain open; no full-coverage claim is made.

Pinned Lean 4.32.0 and mathlib 81a5d257c8e410db227a6665ed08f64fea08e997.
The root build completes with 5322 jobs. All seven compiler/axiom gates pass:
CheckMain, CheckConfidence, CheckParity, CheckRobust, Audit,
CheckCoverageExtensions, and BatchTwoAudit. The ordinary audit checks 16384
proved project declarations; the extension gate checks 412 named
endpoints. Only propext, Classical.choice and Quot.sound occur transitively.
This is an incremental build, not a fresh rebuild of all external packages.

The comment/string-aware scan covers 2089 project
Lean files and finds no proof-placeholder or bypass tokens. All 561 checked
paper/source files are byte-identical to 67b5581a. The conditional package
is unchanged; its earlier fresh-build evidence is linked in record.json.
Source hashes for all 9 changed or added Lean files are recorded.
