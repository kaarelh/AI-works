Verification of GELU merging online coverage, 5 November 2026

The existing population-merging GELU learner now has actual-posterior online
expected risk and logarithmic-confidence bounds, at N>=2C and N sigma^2<=1,
for both optional global-margin choices. Its fixed finite grid has entropy
at most 10^28 C^2 (5+2d+r)^9. Permutation and infinite uniform-IID protocols
are covered, including the actual sampled mistake count on the infinite
stream and the exact sampled tails for both protocols. Repeated inputs have
zero tested-margin risk; literal prefix conditioning and set posteriors agree.
The distinct tanh balanced/signed merging supports remain open, along with
other items in the coverage inventory. No full-coverage claim is made.

Pinned Lean 4.32.0 and mathlib 81a5d257c8e410db227a6665ed08f64fea08e997.
The root build completes with 5329 jobs. All seven compiler/axiom gates pass:
CheckMain, CheckConfidence, CheckParity, CheckRobust, Audit,
CheckCoverageExtensions, and BatchTwoAudit. The ordinary audit checks 16431
proved project declarations; the extension gate checks 435 named
endpoints. Only propext, Classical.choice and Quot.sound occur transitively.
This is an incremental build, not a fresh rebuild of all external packages.

The comment/string-aware scan covers 2096 project
Lean files and finds no proof-placeholder or bypass tokens. All 561 checked
paper/source files are byte-identical to c38815b0. The conditional package
is unchanged; its earlier fresh-build evidence is linked in record.json.
Source hashes for all 9 changed or added Lean files are recorded.
