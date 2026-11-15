# Independent audit of the global ordinary-tanh analytic chain

**Coverage update (2026-11-14):** This dated review records the original main-theorem verification. The [full-paper inventory](OnlineLowerTanh-full-paper-coverage.md) records the subsequent formalization of independent appendix results and is the current source for coverage status.

Audit date: 2026-11-08. Repository: `/workspace/nnbayes-next-repo`, Lean project: `neural-network-generalization/lean`.

**Conclusion:** no substantive hypothesis, vacuity, circularity, or definition mismatch was found in the reviewed global single-parity chain or its physical-code/network interface. Both independent Lean probes passed, including exact assignments to the intrinsic and three main endpoint statements. Every inspected declaration reports only `propext`, `Classical.choice`, and `Quot.sound`.

## Scope and method

This is an independent semantic audit of the main theorem's global analytic ingredient. I read the definitions and proof bodies of `OnlineLowerTanhSharpParity`, `NearBulkAllEqual`, `ExactBulkPhase`, `NearPairEquality`, `OptimizerLimit`, `EmpiricalEfficiency`, `CodeExact`, and `CodeNetwork`, and followed their key interfaces through `IntrinsicMaximum`, `Optimizer`, `OptimizerLattice`, `NearBulk`, `LatticeClassification`, `LatticeFiniteEfficiency`, `NearPairResidual`, `ActualEqualization`, `ExactBulk`, `EqualBulkMax`, `OutlierFinite`, `CodeSupport`, `BalancedCode`, and `ConstructionThresholds`. I also inspected the final `Main` and `AnalyticAssembly` use of the intrinsic theorem.

The comparison text was `works-in-progress/online-mistakes/isotropic-tanh-allwidth/source/single-parity-appendix.tex` and `equal-bulk-bias.tex`. The audit concerns the ingredients needed by the main result. It does not assert that every stronger standalone appendix claim, such as all finite equality classifications or the uniqueness of every maximizing bias, is separately exported in Lean.

The local source-import closure of `OnlineLowerTanhSharpParity` contains 226 modules, of which 180 have `Tanh` in their names. A source graph traversal found no import cycle and no dependence on a `Main` module or `OnlineLowerTanhSharpSupport`. A lexical scan of that closure for `sorry`, `admit`, `axiom`, `unsafe`, `implemented_by`, or `native_decide` returned only three comments containing the word `axiom`. This scan supplements, and does not replace, Lean's eventual compiled axiom report. I did not manually rederive every imported analytic lemma.

## Literal definitions and nonvacuity

`parityCorrelation u b` is the uniform finite Boolean-cube average of the full parity sign times `Real.tanh (b + incomingLinear u x)`. `incomingEnergy u` is the sum of all squared incoming coordinates. `IntrinsicParityBound n w` is exactly

```text
∀ u : Fin n → ℝ, w * |parityCorrelation u 0| ≤ sqrt (incomingEnergy u).
```

It does not restrict the real incoming vector to a lattice, bounded coordinates, balanced weights, a finite dictionary, or a certified subclass. `IsIntrinsicMaximizer u` compares the same literal gain against every `v : Fin n → ℝ`. The proof establishes the existence of nonzero actual maximizers in odd dimensions at least three using continuity at the origin, a positive balanced witness, and compactness with a bound outside a ball. Thus the maximizer argument is not vacuous.

`balancedGain r` is selected from a proved compact maximum of the actual balanced coefficient-to-gain ratio on `[1,2]`; `balancedCost r` is its literal positive normalized incoming cost. This definition does not assume the global intrinsic theorem. The final contradiction only needs the maximum property on `[1,2]`, because the constructed common amplitude is proved eventually to lie in that interval.

## Global maximizer chain

The negation of `eventual_intrinsicParityBound` supplies bad odd dimensions tending to infinity and, by the proved maximizer-existence result, actual maximizers whose gains exceed `1 / balancedCost`. `MaximizerLatticeData` and `OptimizerLatticeLimit` are constructed from those maximizers by the proved global localization and empirical subsequence results. Their fields retain the residual energy and total second moment; no sharp-parity or central-limit conclusion is assumed as a field.

`empirical_efficiency_classification` explicitly takes finite-prefix bounds, but these are discharged at its application. `LatticeFiniteEfficiency` derives them from the actual selected physical coordinates, conditioning, and residual-sequence theorems. `LatticeClassification` applies those estimates to finite positive-frequency prefixes. `OptimizerLimit.classified` then proves a single positive odd harmonic, equality of total and limiting second moments, and the limiting gain. There is no discarded escaped second moment at this interface.

`OptimizerLatticeLimit.nearBulk` constructs `NearBalancedSequence` from absolute values of the original maximizer coordinates. Its maximality follows from an exact input-sign symmetry. Its full energy, root-mean-square concentration, bulk fraction, and efficiency lower bound are proved from the optimizer data.

The pair-equality endpoint derives its residual data from the original bulk with the selected physical coordinates erased. `NearPairResidualData.incoming_eq` supplies an exact reindexing identity, rather than an approximation to an unrelated array. The full coefficient lower bound is derived in `NearPairEquality`; it is not an extra hypothesis on the public endpoint. `ActualEqualization` uses a literal pair-averaged competitor and global maximality to force exact equality. `ExactBulk` then converts the pairwise subsequence conclusion into eventual equality throughout the entire selected majority bulk.

## Arbitrary biases, parity, and outliers

`EqualBulkMax` has a universal quantifier over every real bias. Its odd-degree bound is exact; its even-degree bound uses the next odd balanced coefficient and a uniform relative error proportional to the inverse square of the bulk size. The common threshold and error constant are uniform over `a ∈ [1,2]`. `NearBulkAllEqual.equalBulk_uniform_reference_cap` handles both parities explicitly.

`ExactBulkPhase` obtains a vanishing periodic deficit from the literal whole coefficient, the exactly equal bulk, and the negligible complementary energy. Its odd phase condition is proved from the ambient odd dimension and the bulk/complement decomposition. The dimension-independent phase stability theorem then controls the sum of squared complementary lattice residuals. Combined with the proved fixed gap from the exact bulk amplitude, this gives the uniform `5a/2` lower bound on every unequal nonnegative coordinate.

The final cap conditions over every coordinate outside the full equality class, not just a selected subset of exceptional coordinates. `finite_equal_bulk_not_maximizer` uses the literal ambient dimension `N`, the parity correction, and the complete complement energy. It permits a single outlier; its parameters allow `j = 0`. Thus the even-bulk inverse-square error is still dominated in the smallest exceptional case. `NearBulkAllEqual.eventually_all_equal` applies this finite result after proving the necessary large-size and vanishing-outlier-fraction bounds.

Finally, `SharpParity` compares the all-equal absolute vector with the actual balanced cost, transfers the gain back using exact sign symmetry, and contradicts the selected bad maximizer. No analytic hypothesis remains in its stated eventual theorem.

## Physical-code and network interface

`CodeSupport.tanh_walshCoefficient_eq_conditioned` proves the exact selected/outside-cube decomposition of an actual arbitrary-support Walsh coefficient. The intrinsic bias-transfer identity and conditioning theorem therefore produce a physical affine bound whose norm includes the bias and every incoming coordinate.

`CodeExact.carrierCodeMass_exact_of_intrinsic` and `CodeNetwork.actual_tanh_network_bounds_of_intrinsic` do retain explicit intermediate intrinsic hypotheses. This is transparent in their types. Their conclusions quantify over all real affine neurons, and over every positive finite learner width and every corresponding actual network. They do not quantify only over a finite atom class. The retained Fourier mass is identified with the physical carrier code by an exact injective-orientation reindexing.

`ConstructionThresholds.construction_intrinsic_eventually` proves that every selected support is odd and eventually large uniformly over the logical Fourier index. This discharges those intermediate hypotheses from an eventual odd-degree intrinsic theorem. The current `Main` passes `eventually_intrinsicParityBound` into `tanh_concrete_of_intrinsic`; the global proof does not import or assume that assembly result.

## Certification boundary

The actual Gaussian posterior, its positive normalizers, the fixed permutation, teacher-resource conversion, and the order of learner-width and small-noise quantifiers are assigned to separate audits. This report's semantic conclusions about those items are limited to seeing the unconditional global intrinsic result supplied to the final assembly.

## Independent compiled checks

With Lean 4.32.0, the following command passed with exit code 0:

```text
/workspace/lean-toolchains/lean-4.32.0-linux/bin/lake env /workspace/lean-toolchains/lean-4.32.0-linux/bin/lean /workspace/nnbayes-tanh-lean-2026-11-08/GlobalIntrinsicIndependentProbe.lean
```

The probe assigns the exported theorem to its explicit eventual intrinsic proposition and the exported threshold theorem to its explicit all-large-odd-degree proposition. The axiom report for each of the following is exactly `propext`, `Classical.choice`, and `Quot.sound`:

- `eventual_intrinsicParityBound`
- `exists_intrinsicParityBound_threshold`
- `NearBalancedSequence.eventually_all_equal`
- `NearBalancedSequence.pair_eventually_equal`
- `OptimizerLatticeLimit.classified`

The retained output is `global-intrinsic-independent-probe.log`.

After the coherent Main dependency build passed, I independently ran the corresponding command on `GlobalIndependentProbe.lean`; it passed with exit code 0. I inspected `root/full-main-build.log`, which ends with a successful `OnlineLowerTanhMain` build and `Build completed successfully (4143 jobs).` The probe checks the same intrinsic endpoints and also assigns the following exported declarations to their explicit endpoint types without parameters or hypotheses:

- `OnlineLower.tanh_concrete_main : OnlineLower.TanhConcreteMainStatement`
- `OnlineLower.tanh_path_logarithmic_rail_main : OnlineLower.TanhPathLogarithmicRailStatement`
- `OnlineLower.tanh_square_root_log_loss_lower_bound : OnlineLower.TanhSquareRootLogLossStatement`

That probe also reports precisely the same standard three axioms for all five intrinsic-chain declarations listed above, `carrierCodeMass_exact_of_intrinsic`, `actual_tanh_network_bounds_of_intrinsic`, and all three main declarations. Its complete output is `global-independent-probe.log`.

The first whole-main import attempt occurred during the closure build and stopped before elaboration because `OnlineLowerTanhCodeColumns.olean` was temporarily absent. The successful post-build retry resolves that temporary build-state issue.

The reviewed primary source hashes are retained in `global-independent-source-sha256.txt`; all nine hashes were rechecked successfully after the final probe. These probes consume compiled imports and do not independently rebuild or replay every imported theorem. The coordinated closure build is a separate verification step; I did not launch a competing broad build.

No Lean proof files were changed by this audit.
