# Formal dependency audit

26 October 2026. This record distinguishes the exact concrete statement from
its proof obligations. A declaration with type `Prop` defines a target; it does
not establish that target.

## Exact concrete model already available

The existing library in `../../../lean/NeuralGeneralization/` supplies:

- `Network.lean`: the actual augmented Boolean input, finite weight coordinates,
  neuronwise tanh layers, linear readout, strict global margin events, and
  `realizesAtComplexity`. The latter asserts an actual width-`C` teacher with
  every coefficient bounded in absolute value by `C`; it does not posit a
  complexity oracle.
- `Model.lean`: actual finite products of independent centered real Gaussians,
  including `smallPrior` and `powerPrior`.
- `FunctionPrior.lean`: actual Gaussian function masses, global-margin and exact
  training-label conditioning, posterior correct-label probabilities, strict
  `>2/3` confidence failure, arbitrary finite input laws and iid sample laws.
- `ModelFacts.lean`: positivity of the Gaussian conditioning denominator at
  every width at least the teacher width, proved from continuity, Gaussian
  full support and the explicit cloning construction.

The new `NNBayesStatement.lean` uses these concrete objects. It proves that its
canonical scale has exactly the paper's three layerwise variances and that
conditioning is defined on every eligible sample. Its polynomial coefficient
and degree are quantified **before** depth. Its two formulations of the main
claim, one denying a universal polynomial and one exhibiting a counterexample
to each proposed polynomial, have a proved logical equivalence.

The declaration `ConditionalImpossibility` itself remains a proof target until
a closed theorem of precisely that type is supplied. The logically equivalent
counterexample formulation is not a substitute for that proof.

## Existing analytic component proofs

The ten modules in `../../boolean-depth-barriers/lean/` establish:

- finite-dimensional Frobenius two-ball covers and network covers;
- finite concentration and simultaneous Hilbert-space Maurey approximation;
- actual neuronwise network prefix compression, with quantitative width and
  product bounds;
- a polynomial-size geometric prototype decoder;
- relevant-coordinate bounds and norm-nonincreasing freezing of irrelevant
  Boolean input coordinates.

Their exact interfaces and existing proof checks are recorded in that package's
`analytic-interfaces.txt` and `README.md`. In particular, the prototype decoder
is a geometric formula involving real distances. It is **not yet** a proved
TC¹ circuit compiler.

The existing global library's `MeanFieldMain.lean`, `AboveMeanFieldMain.lean`,
and related main files prove actual learning upper bounds at each fixed depth.
They quantify `∀ depth, ∃ polynomial`, so they cannot establish the new
uniform-depth posterior ceiling by changing the order of these quantifiers.
The continuous-depth modules prove concrete lower bounds on their specified
continuous input law; those are not the Boolean-cube circuit ceiling either.

## Obligations needed by the complete paper proof

The source proof in `../../boolean-depth-barriers/source/paper.tex` uses these
additional ingredients. The existing ten analytic modules do not discharge
them:

1. **Circuit classes and gate constructions.** Concrete circuit evaluation,
   polynomial size and logarithmic depth, polynomial-overhead simulation
   between the chosen gate bases, circuit composition, and family resource
   bounds. The new `Circuits.lean` is the local home of these definitions and
   elementary constructions. `ThresholdToBoolean.lean` now supplies an actual
   NAND simulation of each threshold circuit, with size at most
   `7 * (thresholdSize + 1)^2`, and proves `TC1_subset_PPoly` from it. The
   count-based construction has a quadratic gate bound, not an exponential
   truth-table expansion. No circuit-class inclusion is assumed.
2. **Boolean-to-tanh teacher compilation.** An actual bounded-weight tanh
   network realizing each finite Boolean circuit with strict global margin,
   together with polynomial teacher width/depth and admissible depth padding.
   This corresponds to `lem:boolean-teacher`. It is now discharged by
   `TeacherCompilation.lean` and `TeacherFamilies.lean`: the actual NAND
   compiler uses `C = d + gateCount + 256` and
   `r = gateCount + d + 1`, and the family theorem proves the polynomial
   resource and depth-padding bounds. The stronger width-24 compiler is
   optional and is not claimed to be formalized here.
3. **Parallel evaluation of the compressed representation.** Finite-bit
   quantization, lookup/arithmetic circuits, conversion of the geometric
   classifier into a concrete TC¹ circuit, and universal resource accounting.
   The partial analytic compiler does not include these steps.
4. **Actual posterior circuit ceiling.** `thm:uniform-ceiling` must be proved for
   the Gaussian network and exact conditioning defined above. Its derivation
   uses a sample-memorizer target-mass lower bound, finite-event conditional
   entropy extraction, consistent-path repair, near-baseline canonical
   feature parallelization, and the uniform nearcritical block argument. These
   are substantive mathematical inputs; declaring a structure field asserting
   the ceiling would leave this obligation open.
5. **From distribution-free learning to an exact circuit.** The finite
   posterior-to-weak-learning step, deterministic finite boosting, amplification
   by finitely many majority voters, and circuit composition. The new proof
   does not invoke a minimax theorem. These steps must
   preserve the fixed learner width and scale before choosing the input law.
   The local `FiniteReduction*` and `PosteriorBridge.lean` modules now supply
   finite probability/boosting/majority steps and connect them to the actual
   Gaussian posterior, with the ceiling premise explicitly retained. A proof
   using that retained premise is not a proof of item 4.
6. **Asymptotic assembly.** Apply the preceding constructions to arbitrary
   polynomial-size Boolean circuit families, pad depth, choose a sufficiently
   large actual learner width, bound the resulting circuit resources, and
   take the contrapositive. These steps are now proved in
   `FamilyResources.lean` and `FamilyCollapse.lean`. The explicit integer
   resource and padding bounds are proved, and finite exceptional dimensions
   are handled by the actual circuit embedding in `CircuitFamilies.lean`.
   `conditionalImpossibility_of_posteriorCeiling` proves precisely
   `AnalyticPosteriorCeiling → ConditionalImpossibility`. The circuit compiler
   and actual Gaussian posterior ceiling in items 3–4 remain an additional
   analytic premise; they are not silently folded into `PPoly ≠ TC1`.

A proof of the reduction *assuming* item 4 is a useful conditional component,
but it is not a closed proof of the concrete `ConditionalImpossibility`
statement. This distinction must remain explicit in the paper and verification
record until that item and the other needed constructions are discharged.

## Final coverage

The concrete model, circuit classes and their required closure properties,
Boolean-to-tanh compilation, posterior normalization and weak-voter transfer,
deterministic finite boosting, polynomial resource/padding accounting, and the
family-level contrapositive are proved. The final checked reduction has exactly
one additional explicit premise, `AnalyticPosteriorCeiling`, whose analytical
proof includes items 3–4 above. Neither that premise nor the complete concrete
main claim has a closed Lean proof in this package. No minimax theorem is used
in the new finite reduction.
