Verification of hidden-only and geometric-family coverage, 4 November 2026

The literal hidden-only Gaussian-conditioned learning theorem is proved,
including the zero-readout branch, support measurability, unchanged target
mass polynomial, actual finite compression, exact two-stage conditioning,
all-width/all-scale sample event, original polynomial parameters, optional
clean margin, Gibbs risk and two-thirds confidence. The exact nonexpansive
hidden-only gain and calibrated raw variation are included.

The fixed-center upper-orthant VC bound is proved from shattering. Arbitrary
quadratic forms are represented in exactly (d+1)(d+2)/2 monomials, including
weak sublevels by complementation. Actual ellipsoidal cylinders and unions
of at most k cylinders have the paper's finite-family log-cardinality bound.
The exact network first-layer semimetric is connected to that family.
Stability and coverage premises of localized learning are still required.
Other coverage gaps remain; this is not a full-coverage claim.

Pinned Lean 4.32.0 and mathlib 81a5d257c8e410db227a6665ed08f64fea08e997.
The root build completes with 5288 jobs. All seven compiler/axiom gates pass:
CheckMain, CheckConfidence, CheckParity, CheckRobust, Audit,
CheckCoverageExtensions, and BatchTwoAudit. The ordinary audit checks 16034
proved project declarations; the extension gate checks 297 named
endpoints. Only propext, Classical.choice and Quot.sound occur transitively.
This is an incremental build, not a fresh rebuild of all external packages.

The comment/string-aware scan covers 2055 project
Lean files and finds no proof-placeholder or bypass tokens. All 561 checked
paper/source files are byte-identical to f41152ef. The conditional package
is unchanged; its earlier fresh-build evidence is linked in record.json.
Source hashes for all 15 changed or added Lean files are recorded.
