Verification of the growing-depth norm-ball appendix, 6 November 2026

The strong-prior appendix proposition is now proved using actual tanh
networks. For L>=4, any specified q>=1 input coordinates and every
N>=2^(q+1), every Boolean function on those coordinates has exact +/-1
output and weighted norm at most
200[d q^2 log^2(2q)+(L-2)2^(2q/(L-2))].

The proof supplies cube interpolation with slope (1/2)log(16q), inverse
coefficient bound 4/3, the rounded replication/amplitude schedule, actual
finite-network evaluation, all layer energies, input embedding and exact
cloning at larger widths. The existing infimal strict-margin norm ball
contains at least 2^(2^q) functions when the budget is <=K. At L=d+2,
all Boolean functions have norm <=1000 d^3 log^2(2d). For every positive
C and every degree k, log cardinality exceeds C(d+K+L+1)^k at arbitrarily
large d. This closes the appendix's counting obstruction. It is not a
Gaussian posterior mistake lower bound for a simple target.

Pinned Lean 4.32.0 and mathlib 81a5d257c8e410db227a6665ed08f64fea08e997.
The root build completes with 5348 jobs. All seven compiler/axiom gates pass:
CheckMain, CheckConfidence, CheckParity, CheckRobust, Audit,
CheckCoverageExtensions, and BatchTwoAudit. The ordinary audit checks 16726
proved project declarations; the extension gate checks 600 named
endpoints. Only propext, Classical.choice and Quot.sound occur transitively.
This is an incremental build, not a fresh rebuild of all external packages.

The comment/string-aware scan covers 2115 project
Lean files and finds no proof-placeholder or bypass tokens. All 561 checked
paper/source files are byte-identical to d5e2bf82. The conditional package
is unchanged; its earlier fresh-build evidence is linked in record.json.
Source hashes for all 11 changed or added Lean files are recorded.
