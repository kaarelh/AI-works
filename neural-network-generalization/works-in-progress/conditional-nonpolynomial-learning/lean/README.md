# Lean proof of the conditional NNbayes theorem

The paper's central theorem has a closed Lean proof in [ClosedConditionalImpossibility.lean](ClosedConditionalImpossibility.lean):

```lean
theorem conditionalImpossibility : ConditionalImpossibility
```

The exact type, defined in [NNBayesStatement.lean](NNBayesStatement.lean), is

```lean
PPoly ≠ TC1 → ∀ T : CanonicalSchedule, ¬ UniversalPolynomialGuarantee T
```

There is **no additional analytic premise**. `analyticPosteriorCeiling` proves the actual Gaussian posterior ceiling that the finite reduction uses. The main theorem and its counterexample formulation report only Lean's standard axioms `propext`, `Classical.choice`, and `Quot.sound`. The complexity-class separation is an explicit hypothesis of the mathematical implication, not an added Lean axiom.

[IndependentLiteralMainAudit.lean](IndependentLiteralMainAudit.lean) expands the conclusion directly into the finite-width Gaussian posterior: every proposed polynomial has an eligible teacher, width, input law and sample count for which confidence-error mass exceeds `1/16` with sample probability greater than `1/2`. It also proves that the conditioning denominator is strictly positive for every sample.

## Statement and scope

The network is the original fully connected tanh network with independent Gaussian weights, global absolute output margin strictly greater than `1/2`, and exact noiseless training labels. Training and testing share an arbitrary input law; samples are IID, so repeated inputs are allowed. A prediction fails the confidence criterion when correct-label posterior probability is at most `2/3`.

Each prescribed scale schedule has `0 < t(d,L,N) ≤ 1`, fixed before the input law and sample. Its first, hidden, and readout variances are `t²/d`, `t²/N`, and `t²/N²`. This includes each fixed `gamma ≥ 1` at finite width. The exact zero-temperature posterior obtained by taking the scale to zero at fixed width is a different limiting object and is not asserted by this theorem.

The denied guarantee has one polynomial jointly in input dimension, bounded-weight teacher width and depth, valid at every learner width at least teacher width and every common input law. This is not an exponential-depth lower bound or a hardness theorem for the uniform input law. The paper's stronger fixed-hard-family corollary is a conventional consequence; it is not a separate formal theorem here. The formal analytic ceiling uses posterior mass `5/6`, the constant needed for the central result; the paper's auxiliary every-beta statement is not separately claimed as formalized.

## Proof map

| Step | Checked source |
|---|---|
| Actual neural model, prior variances, IID probabilities, positive denominators, and exact quantifiers | [NNBayesStatement](NNBayesStatement.lean) |
| Concrete NAND/threshold circuits and nonuniform complexity classes | [Circuits](Circuits.lean), [CircuitFamilies](CircuitFamilies.lean), [ThresholdToBoolean](ThresholdToBoolean.lean) |
| Bounded-weight NAND-to-tanh teacher compiler | [TeacherCompilation](TeacherCompilation.lean), [TeacherFamilies](TeacherFamilies.lean) |
| Actual memorizer lower bound for the conditioning event | [UniformMemorizerDenominatorClosed](analytic/UniformMemorizerDenominatorClosed.lean) |
| Actual finite-event entropy extraction and normalized path repair | [UniformMarginPathWidth](analytic/UniformMarginPathWidth.lean), [FullPosteriorCeilingBridge](analytic/FullPosteriorCeilingBridge.lean) |
| Small-action path to an actual small parallel circuit, uniformly for `0<t≤1` | [PhysicalSmallActionCapacity](analytic/PhysicalSmallActionCapacity.lean) |
| Far-strong path to an actual small parallel circuit | [ActualFarStrongCapacity](analytic/ActualFarStrongCapacity.lean) |
| Long nearcritical path to an actual small parallel circuit | [ActualLongNearcriticalCapacity](analytic/ActualLongNearcriticalCapacity.lean) |
| Exhaustive scale split and actual posterior circuit mass | [UniformCapacityAssembly](analytic/UniformCapacityAssembly.lean), [StructuralPosteriorAssembly](analytic/StructuralPosteriorAssembly.lean) |
| Weak voter extraction, finite boosting, and majority circuits | [FiniteReductionPosterior](FiniteReductionPosterior.lean), [FiniteReductionBoosting](FiniteReductionBoosting.lean), [FiniteReductionCircuits](FiniteReductionCircuits.lean), [PosteriorBridge](PosteriorBridge.lean) |
| Polynomial families, depth padding, and complexity-class contrapositive | [FamilyResources](FamilyResources.lean), [FamilyCollapse](FamilyCollapse.lean) |
| Closed main theorem and literal statement audit | [ClosedConditionalImpossibility](ClosedConditionalImpossibility.lean), [IndependentLiteralMainAudit](IndependentLiteralMainAudit.lean) |

The publication contains 585 local modules: the 583-module closed theorem dependency chain, an independent expanded-statement audit, and the earlier circuit sanity checks. They use the collection's concrete neural-model library and pinned mathlib. The [dependency audit](DEPENDENCY-AUDIT.md) explains how the analytic constructions connect to the original posterior; the [verification record](../verification/README.md) identifies the checked source snapshots and reproducible build.

## Reproduction

Use the collection's pinned Lean 4.32.0 and mathlib dependencies in [the main Lean project](../../../lean/). After installing that project's dependencies, run:

```sh
./build.sh
```

The script builds imported collection modules through Lake, clears its generated local output directory, and compiles all local sources in dependency order. It does not inherit a scratch `LEAN_PATH`. Generated objects remain under `.build/release/`. A matching pinned project and Lake executable may be supplied:

```sh
./build.sh /absolute/path/to/matching-lean-project /absolute/path/to/lake
```
