Verification of clean-Jacobian finite-radius coverage, 4 November 2026

The actual tanh network satisfies the paper's finite-radius clean-Jacobian
bound with its literal operator/row norms, signed triangular inverse, readout
gain, curvature ratio, and joint hidden/output RMS disturbance budget. The
proof includes the actual nonlinear expansion, global quadratic remainder,
continuous homotopy no-crossing argument, and calibrated-support corollary.
The signed transport and gain are identified with actual clean derivatives;
g^2 is the sum of squared hidden-injection coordinate derivatives.
The ancillary product-block bound on k and other listed gaps remain open.
No full-coverage claim is made.

Pinned Lean 4.32.0 and mathlib 81a5d257c8e410db227a6665ed08f64fea08e997.
The root build completes with 5304 jobs. All seven compiler/axiom gates pass:
CheckMain, CheckConfidence, CheckParity, CheckRobust, Audit,
CheckCoverageExtensions, and BatchTwoAudit. The ordinary audit checks 16189
proved project declarations; the extension gate checks 348 named
endpoints. Only propext, Classical.choice and Quot.sound occur transitively.
This is an incremental build, not a fresh rebuild of all external packages.

The comment/string-aware scan covers 2071 project
Lean files and finds no proof-placeholder or bypass tokens. All 561 checked
paper/source files are byte-identical to 6461b818. The conditional package
is unchanged; its earlier fresh-build evidence is linked in record.json.
Source hashes for all 9 changed or added Lean files are recorded.
