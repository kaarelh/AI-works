Verification of the literal continuous-depth memorizer and ceiling, 10 November 2026

Thirteen new modules prove the paper's exact bounded-label memorizer at
its literal width M and energy K, the product estimate with constant exp(17),
and the depth-independent Lipschitz ceiling Lambda. The construction covers
arbitrary sample order, every d>=1, n>=1, L>=3 and every N>=M. The output is
globally bounded by one. No interpolation inverse or channel identity is
assumed: the finite inverse, actual dense network, normalized tanh channels,
real-width cloning, tent schedule and their numerical bounds are proved.

The exact-minimizer and actual iterated-limit corollaries now include the
literal Lambda_n ceiling, for both the fixed circle law and its smooth
variant, on one measurable event of sample probability at least 49/50.
Individual error and confidence threshold 2/3 follow explicitly. The actual
Gaussian posterior has vanishing bad-Lambda mass in the strong-prior limit.
See ../../paper-exact-correspondence-2026-11-10.txt for the statement map.

The finite-scale approximation lemma with its displayed width threshold
remains open. This is not a claim of complete coverage of the sixteen papers.

Pinned Lean 4.32.0 and mathlib 81a5d257c8e410db227a6665ed08f64fea08e997.
The root build completes with 5403 jobs. All seven compiler/axiom gates pass:
CheckMain, CheckConfidence, CheckParity, CheckRobust, Audit,
CheckCoverageExtensions, and BatchTwoAudit. The ordinary audit checks 17444
proved project declarations; the extension gate checks 933 named
endpoints, including all 113 new named theorems. Only propext,
Classical.choice, and Quot.sound occur transitively. This is an incremental
build, not a fresh rebuild of all external packages.

The comment/string-aware scan covers 2647 project
Lean files and finds no proof-placeholder or bypass tokens. All 631 checked
paper/source files are byte-identical to parent 15e92f5a. The conditional
package is unchanged; its earlier fresh-build evidence is linked in
record.json. All 15 changed or added Lean sources have hashes.
