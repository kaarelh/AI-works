# Verification record

The [standalone writing revision of 29 October](../../../verification/standalone-writing-2026-10-29.md) gives the current paper source and PDF hashes. It clarifies the abstract, local model definitions, and formalization scope without changing the theorem or any Lean source. The full Lean build record below identifies the earlier manuscript snapshot and the unchanged checked proof.

**The main conditional NNbayes theorem is proved in Lean for the concrete Gaussian model.** The only conjectural premise is nonuniform `PPoly ≠ TC1`, as stated in the paper. The analytic posterior ceiling is a proved dependency, not an additional assumption of the final theorem.

The entry points in [ClosedConditionalImpossibility.lean](../lean/ClosedConditionalImpossibility.lean) are:

```lean
theorem conditionalImpossibility : ConditionalImpossibility
theorem conditionalCounterexamples : ConditionalCounterexamples
```

The first states that every prescribed positive scale schedule in `0 < t ≤ 1` fails the universal, distribution-free, all-width polynomial sample guarantee. The second spells out a finite-dimensional, finite-width counterexample to every proposed polynomial. Both use the existing Gaussian prior, global absolute margin, exact noiseless-label conditioning, iid sampling, and strict `>2/3` correct-label criterion. Positive conditioning probability is proved for every target and sample covered by the statement.

## Verification scope

| Statement | Coverage |
|---|---|
| The paper's main conditional impossibility theorem and its displayed finite counterexample formulation | Proved by the two entry points above |
| Actual finite-width posterior circuit ceiling needed in the proof | Proved at exceptional mass `1/6`, with universal integer resource envelopes and scale-independent width threshold |
| The three physical-scale regimes, finite arithmetic and threshold-circuit compilation, teacher compilation, finite boosting, and circuit-family collapse | Proved dependencies of the final entry points |
| The stronger analytic-ceiling proposition stated for every exceptional mass `β ∈ (0,1)` | Not claimed to be fully formalized by this package |
| The fixed-hard-family corollary, with one input law defeating every sample, width, and scale in its stated ranges | Conventional proof in the paper; its full quantifier strengthening is not claimed to be formalized here |
| An exponential lower bound in teacher depth | Not asserted by the paper or the Lean theorem |
| A separately defined exact zero-scale posterior limit at fixed width | Not covered by the positive-scale schedule statement |

The final theorem's circuit classes are concrete finite NAND and threshold circuits. The statistical objects are the actual finite neural-network prior and posterior; they are not abstract oracle fields chosen to encode the desired conclusion. The former component theorem `conditionalImpossibility_of_posteriorCeiling` remains useful, but its premise is now discharged by `analyticPosteriorCeiling` in the closed entry-point module.

## Source and build checks

The final theorem axiom reports contain only `propext`, `Classical.choice`, and `Quot.sound`. They contain no analytic-capacity axiom or `sorryAx`.

The [source-only build log](lean-build.log) and [publication/build record](publication-build.json) identify the exact checked sources, dependency snapshot, toolchain, commands, theorem reports, and PDF hashes. The publication build compiles all 585 local modules from source in a cleared output directory. A separate [independent replay](independent-source-replay.log) checked the complete 583-module main-theorem dependency chain from a frozen source snapshot; its [source hashes](independent-source-snapshot.json) identify that snapshot. The two additional publication modules are the expanded statement audit and earlier circuit sanity checks. [Build instructions](../lean/README.md) use the pinned Lean 4.32.0 and matching mathlib dependencies.

All 1,304 shared collection source modules, the root library entry point and dependency pins were compared with the build project and matched. The exact transitive closure contains 585 local modules and 408 shared collection modules; a code-token audit found no proof holes, added axioms or native proof shortcuts. This scan supplements the successful kernel checks.

The mathematical and statement checks include the [original statement audit](lean-statement-audit.md), [finite-reduction review](statement-and-finite-reduction-audit.md), the [closed-statement audit](closed-statement-audit-2026-10-28.md), [analytic assembly audit](analytic-assembly-audit-2026-10-28.md), [revised-paper review](paper-review-2026-10-29.md), and [source-provenance audit](source-provenance-audit-2026-10-29.md). Dated audit records describe their own checked snapshots; an older record that lists the analytic ceiling as outstanding is a historical status report, not the verification status of the current entry point.

The PDF is rebuilt from the published source, with unresolved references and LaTeX errors checked. Exact build results and source hashes belong in the publication record rather than being inferred from the mere presence of a PDF or an `.olean` file.
