# Independent publication provenance audit

29 October 2026. This audit checks the exact Lean sources selected for publication and their dependency provenance. It is separate from, and does not replace, the successful kernel-checking build record.

## Source alignment

The published package has **585 local Lean modules**. Its main theorem imports the same **583-module local closure** as the independently rebuilt source snapshot. The two additional publication modules are `CircuitChecks` and `IndependentLiteralMainAudit`.

All snapshot modules are present. There are six hash differences. `NNBayesStatement`, `AnalyticCeiling`, `TeacherFamilies`, and `FamilyCollapse` only update verification-status comments. `PhysicalGainPrefixResidualFamily` and `PhysicalGainPrefixResidualRealMap` only remove trailing whitespace from four lines in total. Removing comments and whitespace makes all six pairs identical; definitions, theorem statements and proofs are unchanged. All other snapshot sources match byte for byte.

The two trailing-whitespace cleanups occurred during the publication build, **before those modules were compiled**. Their entries in the build source-hash manifest were updated at that time. This audit independently confirmed that neither compiler invocation had begun after the cleanups and that every current source matches the updated manifest. The record does not claim that every source byte remained untouched throughout the entire build.

The build project's **1,304 shared `NeuralGeneralization` source modules**, as well as its root `NeuralGeneralization.lean` entry point, match the repository's published shared library byte for byte. The exact central theorem transitively uses 408 of those shared modules. The publication package's two extra checks introduce no additional shared modules.

## Pinned dependencies

The build project and published project have identical `lean-toolchain`, `lakefile.toml`, and `lake-manifest.json` files. The actual executable reports Lean 4.32.0, release commit `8c9756b28d64dab099da31a4c09229a9e6a2ef35`. The actual mathlib checkout is clean at the pinned commit `81a5d257c8e410db227a6665ed08f64fea08e997`.

The JSON companion records the exact source hashes and the actual resolved Lake search path. No earlier search-path directory contains an object with the name of any of the 585 local modules, so no stale local object can shadow the generated publication object.

## Reproduction-script review

`lean/build.sh` clears inherited `LEAN_PATH`, rejects duplicate local module basenames and import cycles, creates a fresh local output directory, and builds imported collection dependencies through the selected pinned Lake project. It compiles every local source in dependency order, using the source's containing directory as its module root. Its explicit `LEAN_PATH` contains only the fresh local output; Lake supplies the project's standard dependency paths. Source hashes and the import graph are recorded before compilation.

## Proof-hole and shortcut scan

The complete publication closure—585 local modules and 408 shared modules—was scanned after removing nested comments and strings. There were **zero code occurrences** of `sorry`, `sorryAx`, `admit`, `axiom`, `native_decide`, `implemented_by`, `unsafe`, or `skipKernelTC`. This is corroborating evidence, not a substitute for Lean's final theorem axiom reports and the clean build.

The audit found no provenance or build-isolation issue. The machine-readable companion, [source-provenance-audit-2026-10-29.json](source-provenance-audit-2026-10-29.json), records all counts, source hashes, comment-only differences, dependency pins, scan results and search-path checks.
