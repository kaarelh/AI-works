# Lean statement and reduction

**The paper's full NNbayes theorem is not yet proved in Lean.** Its exact statement is defined in [NNBayesStatement.lean](NNBayesStatement.lean). The checked proof in [FamilyCollapse.lean](FamilyCollapse.lean) establishes

```lean
conditionalImpossibility_of_posteriorCeiling
  (hceiling : AnalyticPosteriorCeiling) : ConditionalImpossibility
```

`AnalyticPosteriorCeiling` is an explicit, **unproved** proposition about the actual Gaussian neural-network posterior. It is defined in [AnalyticCeiling.lean](AnalyticCeiling.lean); it is not an axiom. The informal paper imports this analytic theorem from the earlier parallel-complexity paper. A Lean proof of that input is still needed to obtain a closed proof of the main claim with only the stated complexity conjecture.

The reduction does substantially more than take a logical contrapositive. Its checked components are:

| Component | Source |
|---|---|
| Actual Gaussian variances, global-margin conditioning, iid sample probability, exact main statement, positive conditioning denominators, and counterexample quantifiers | [NNBayesStatement.lean](NNBayesStatement.lean) |
| Concrete NAND and threshold circuits; nonuniform P/poly and TC¹ definitions | [Circuits.lean](Circuits.lean) |
| Polynomial threshold-to-NAND simulation and TC¹ contained in P/poly | [ThresholdToBoolean.lean](ThresholdToBoolean.lean) |
| Concrete parallel circuit composition and majority gates | [CircuitOperations.lean](CircuitOperations.lean) |
| Finite exceptional dimensions in circuit families | [CircuitFamilies.lean](CircuitFamilies.lean) |
| Explicit boosting with 400(d+1) voters, weak-predictor extraction, and the finite hard-distribution converse | [Boosting](FiniteReductionBoosting.lean), [posterior averaging](FiniteReductionPosterior.lean), [converse](FiniteReductionConverse.lean), [circuit construction](FiniteReductionCircuits.lean) |
| Specialization to the actual Gaussian tanh posterior | [PosteriorBridge.lean](PosteriorBridge.lean) |
| Actual NAND-to-tanh teacher construction and polynomial teacher families | [TeacherCompilation.lean](TeacherCompilation.lean), [TeacherFamilies.lean](TeacherFamilies.lean) |
| Polynomial sample budgets, logarithmic circuit resources, and depth padding | [FamilyResources.lean](FamilyResources.lean) |
| Final family-level reduction and explicit counterexamples, assuming the named analytic input | [FamilyCollapse.lean](FamilyCollapse.lean) |

The central statement uses the existing concrete neural-network model, not an abstract learner chosen to make the conclusion true. Its only conjectural hypothesis is `PPoly ≠ TC1`. The **proved reduction** has the additional analytic-ceiling premise displayed above. Standard-axiom reports and the absence of `sorry` do not remove that premise or certify the main statement on their own.

The missing analytic work includes finite-event entropy extraction with bounds uniform in depth, the canonical-path representation and its parallel evaluation, and their connection to actual posterior circuit mass. The [dependency audit](DEPENDENCY-AUDIT.md) gives further detail.

## Reproduction

The files use the collection's pinned Lean 4.32.0 and mathlib dependencies in [the main Lean project](../../../lean/). Install those dependencies using that project's instructions, then run from this directory:

```sh
./build.sh
```

The script builds the imported collection modules from the selected project's sources and compiles every local file anew in dependency order. It writes generated objects only under `.build/release/`. An alternate copy of the same pinned project and Lake executable may be supplied:

```sh
./build.sh /absolute/path/to/matching-lean-project /absolute/path/to/lake
```

The [verification record](../verification/README.md) records the checked source snapshots, independent statement audit, and the exact scope of the successful build. The imported collection library retains its own verification record; none of its existing main theorems has been changed for this paper.
