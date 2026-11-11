Verification of the literal finite-scale ceiling, 11 November 2026

Fifteen new modules prove lem:finite-ceiling in the unchanged continuous-
depth lower-bound paper, including its exact radius and displayed width
threshold and the polynomial bound on that threshold. No larger substitute
threshold or additional sample hypothesis is introduced.

The actual Gaussian block body is closed, convex, centrally symmetric and
has probability at least one half. Its block constants are the literal
paper formulas. The normalized network is proved equal to the existing
tanh network. Exact layer energies and finite-product telescoping give the
paper's uniform perturbation estimate. The Gaussian translated body gives
training mass at least (1/2)*exp(-K/(2*sigma^2)). A continuous representative
is constructed by convex projection, and its actual prior energy tail is
proved. Conditioning yields a closed event of posterior probability at
least 1-beta, on which that representative has energy at most K+1,
Lipschitz ceiling Lambda, and uniform unit-ball error at most h.

The proof uses the existing proved Gaussian transport concentration bound
with a tuned parameter. It uses the extra small-noise margin already in
the displayed width condition, so the final threshold is unchanged. It does
not postulate a sharp Gaussian isoperimetric inequality. The literal width
is bounded by a polynomial of degree 6*ceil(1/zeta), with a coefficient
independent of d, M, T, L, h and beta.

All identified continuous-depth gaps are now closed. Other-paper gaps remain;
see ../../coverage-extension-2026-10-30.txt. This is not a claim of complete
coverage of all sixteen papers. The precise statement map is in
../../finite-ceiling-correspondence-2026-11-11.txt.

Pinned Lean 4.32.0 and mathlib 81a5d257c8e410db227a6665ed08f64fea08e997.
The root build completes with 5419 jobs. All seven compiler/axiom gates pass:
CheckMain, CheckConfidence, CheckParity, CheckRobust, Audit,
CheckCoverageExtensions, and BatchTwoAudit. The ordinary audit checks 17687
proved project declarations; the extension gate checks 1045 named
endpoints, including all 112 new named theorems. Only propext,
Classical.choice, and Quot.sound occur transitively. This is an incremental
build, not a fresh rebuild of all external packages. The BatchTwoAudit log
retains complete multiline axiom output; only trailing whitespace is removed.

The comment/string-aware scan covers 2662 project
Lean files and finds no proof-placeholder or bypass tokens. All 631 checked
paper/source files are byte-identical to parent d90579ed. The conditional
package is unchanged; its earlier fresh-build evidence is linked in
record.json. All 17 changed or added Lean sources have hashes.
