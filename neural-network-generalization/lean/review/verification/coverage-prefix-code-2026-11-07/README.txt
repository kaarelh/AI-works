Verification of literal prefix-circuit bitstrings, 7 November 2026

The paper's exact 00 / 01 unary-length-and-addresses / 1 x y p grammar
now has an executable serializer and parser. Binary addresses are least-
significant-bit first (the paper does not specify within-field order).
Out-of-range addresses, a zero-gate nonempty tag, truncations and trailing
garbage are rejected. General theorems prove suffix-preserving round trips,
canonical successful parsing, exact bit lengths, injectivity, prefix-freeness
and the three-times-bit-length circuit compilation bound.

Abstract programs are equivalent to the actual valid finite strings.
Kraft's inequality, the literal normalized squared-length prior, partition
bounds, overwrite ratio, all event masses, the entire function prior and
conditioned next-label probabilities are identified. Thus the original
prefix converse learner is unchanged by concrete serialization.

CheckPrefixSerialization.lean additionally runs compiled code for eleven
positive and malformed examples, including NAND and exception semantics,
suffix preservation, address range checks, truncation and trailing bits.
Its output is in ExecutableChecks.txt. No claim about other remaining
paper gaps is made.

Pinned Lean 4.32.0 and mathlib 81a5d257c8e410db227a6665ed08f64fea08e997.
The root build completes with 5353 jobs. All seven compiler/axiom gates pass:
CheckMain, CheckConfidence, CheckParity, CheckRobust, Audit,
CheckCoverageExtensions, and BatchTwoAudit. The ordinary audit checks 16835
proved project declarations; the extension gate checks 647 named
endpoints. Only propext, Classical.choice and Quot.sound occur transitively.
This is an incremental build, not a fresh rebuild of all external packages.

The comment/string-aware scan covers 2121 project
Lean files and finds no proof-placeholder or bypass tokens. All 561 checked
paper/source files are byte-identical to 4c658830. The conditional package
is unchanged; its earlier fresh-build evidence is linked in record.json.
Source hashes for all 8 changed or added Lean files are recorded.
