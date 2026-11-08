Verification of continuous nonpolynomial circuit simulation, 7 November 2026

The strong-prior paper's circuit-simulation proposition and finite-complexity
remark are now proved for every continuous nonpolynomial real activation.
Finite interpolation is derived using convolution, nonzero moments,
bounded-degree polynomial closure, and finite linear algebra. Exactly one
feature per finite interpolation node suffices. It is not an assumed axiom.

The actual no-internal-bias network simulates ordinary DAG circuits with
arbitrary sharing and skipped levels. One positive integer a is chosen
before input dimension, gate count, circuit depth, and requested network
depth. For C>=1 and L>=max(2,D+1), width is aC, every weight is bounded by a,
and output is exactly +/-1. A counted constant neuron supplies internal
shifts. Disconnected padding also works when the activation is nonzero at
zero. The existing minimum complexity is <=aC, and every Boolean function
has finite complexity at every L>=2, including dimension zero.

See ../../nonpolynomial-circuit-correspondence-2026-11-07.txt for the detailed
statement map. Other coverage gaps remain; this is not a full-coverage claim.

Pinned Lean 4.32.0 and mathlib 81a5d257c8e410db227a6665ed08f64fea08e997.
The root build completes with 5375 jobs. All seven compiler/axiom gates pass:
CheckMain, CheckConfidence, CheckParity, CheckRobust, Audit,
CheckCoverageExtensions, and BatchTwoAudit. The ordinary audit checks 17000
proved project declarations; the extension gate checks 697 named
endpoints, including all fifty new named theorems. Only propext,
Classical.choice, and Quot.sound occur transitively. This is an incremental
build, not a fresh rebuild of all external packages.

The comment/string-aware scan covers 2131 project
Lean files and finds no proof-placeholder or bypass tokens. All 611 checked
paper/source files are byte-identical to parent a91fed47. This expands the
previous 561-file check to include all current tracked TeX, BibTeX, and PDF
files, while preserving the shallow derivation.md check. Incoming independent
research commits were preserved before taking this baseline. The conditional
package is unchanged; its earlier fresh-build evidence is linked in record.json.
All 12 changed or added Lean source files have recorded hashes.
