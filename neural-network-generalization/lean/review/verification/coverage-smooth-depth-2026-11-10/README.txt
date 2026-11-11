Verification of the smooth continuous-depth distribution extension, 10 November 2026

Fifteen new modules construct the actual depth-dependent law D_r and prove
its smooth nonnegative density relative to circle arclength. Arclength is
constructed from both unit-speed angular charts; its total mass is 2 pi.
The scalar convolution density is smooth and compactly supported. The
explicit ambient density restricts to the required circle density.

Strong-prior, finite-power, exact-minimizer mixture, actual iterated-limit,
and width-first critical-prior failure endpoints are proved for this law.
The original teacher, 49/50 sample probability, 1/4 test tolerance, 1/8
training tolerance and one-half failure lower bounds are retained.

The main lower-bound conclusions are covered. A further statement audit
identified that the paper's exact depth-independent Lambda_n Lipschitz
ceiling for every minimum-energy interpolant, and the general exact
memorizer/approximation lemmas that establish it, are not supplied by the
existing alternative proof. These remain explicit coverage gaps. This is
not a claim of complete coverage of cor:smooth or of the sixteen papers.
See ../../smooth-depth-correspondence-2026-11-10.txt for the statement map.

Pinned Lean 4.32.0 and mathlib 81a5d257c8e410db227a6665ed08f64fea08e997.
The root build completes with 5390 jobs. All seven compiler/axiom gates pass:
CheckMain, CheckConfidence, CheckParity, CheckRobust, Audit,
CheckCoverageExtensions, and BatchTwoAudit. The ordinary audit checks 17204
proved project declarations; the extension gate checks 820 named
endpoints, including all 123 new named theorems. Only propext,
Classical.choice, and Quot.sound occur transitively. This is an incremental
build, not a fresh rebuild of all external packages.

The comment/string-aware scan covers 2634 project
Lean files and finds no proof-placeholder or bypass tokens. All 631 checked
paper/source files are byte-identical to parent 0c7c6334. Incoming independent
research commits, including their new online lower-bound papers and proofs,
were preserved before taking this baseline. Those new papers are outside
this sixteen-paper coverage task. The conditional package is unchanged;
its earlier fresh-build evidence is linked in record.json. All 17
changed or added Lean source files have recorded hashes.

Note added 10 November 2026 (statement-fidelity audit by Claude Opus 5.5):
BatchTwoAudit.txt keeps only the first line of each multi-line
`#print axioms` message, so 86 of its lines stop at "[propext,". The other
logs in this folder keep the continuation lines. All the truncated
endpoints have complete lists (propext, Classical.choice, Quot.sound) in
../batch-two-2026-10-23/final-source-check.log, for the proof versions of
that date. For the current proofs, Audit.txt in this folder records that
Audit.lean found only these three axioms for every project theorem in the
imported library. The extension gate (CheckCoverageExtensions) does not
name these endpoints. A re-run that keeps the continuation lines would make
BatchTwoAudit.txt self-contained.
