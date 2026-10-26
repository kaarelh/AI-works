# Verification record

**The complete conditional NNbayes theorem is not Lean verified.** The exact statement is formalized, and the complete subsequent reduction is checked with one explicit additional premise: `AnalyticPosteriorCeiling`. That premise is a concrete statement about Gaussian neural-network posterior mass and remains unproved in Lean.

The checked entry point is:

```lean
conditionalImpossibility_of_posteriorCeiling
  (hceiling : AnalyticPosteriorCeiling) : ConditionalImpossibility
```

This is not a closed proof of `ConditionalImpossibility`. The complexity conjecture is part of that exact target; the analytic-ceiling premise is a separate remaining obligation, not another stated conjecture. No file declares the ceiling as an axiom or supplies a placeholder proof.

## Checks completed

- [Independent mathematical audit](final-mathematical-audit.md) of the nine-page paper, including its explicitly cited analytic input.
- [Independent exact-statement audit](lean-statement-audit.md), with [source hashes](lean-statement-audit-sha256.json), comparing the informal theorem to the concrete Lean model and quantifiers.
- [Statement and finite-reduction review](statement-and-finite-reduction-audit.md), independently checking the confidence thresholds, boosting argument, and model correspondence.
- All **16 new Lean modules** were recompiled from source in dependency order. The [successful build log](lean-build.log) contains the principal theorem axiom reports: only `propext`, `Classical.choice`, and `Quot.sound`. It contains no `sorryAx` and no elaboration error. Style-linter suggestions are retained in the log.
- All 1,304 source modules in the imported build project's collection library were compared with the published collection sources and matched. Imported modules were built through Lake; the local modules were compiled anew in `.build/release/`.
- The PDF built cleanly. An independent isolated rebuild reproduced identical extracted text without unresolved references or overfull boxes.

[Publication/build record](publication-build.json) identifies the exact source/PDF hashes, Lean source snapshots, build command, and scope. [Build instructions](../lean/README.md) reproduce the local checks using the collection's pinned Lean 4.32.0 and mathlib dependencies.

## What remains

The [analytic-ceiling proposition](../lean/AnalyticCeiling.lean) requires a depth-uniform proof connecting the actual Gaussian conditioning event to controlled feature paths, then to small logarithmic-depth threshold circuits. The [dependency audit](../lean/DEPENDENCY-AUDIT.md) distinguishes this missing analysis from the completed finite reduction, concrete circuit constructions, teacher compilation, and asymptotic resource bookkeeping.

The earlier parallel-complexity paper gives a conventional proof of that analytic input. Its existing Lean components do not establish the entire input. Passing the current build must therefore not be reported as full formal verification of the paper's central theorem.
