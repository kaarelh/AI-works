# Independent audit of the assembled ordinary-tanh main theorem

**Coverage update (2026-11-14):** This dated review records the original main-theorem verification. The [full-paper inventory](OnlineLowerTanh-full-paper-coverage.md) records the subsequent formalization of independent appendix results and is the current source for coverage status.

**Pass — the improved main online theorem is proved with its intended actual-model statement and no extra mathematical hypotheses.** Independent exact-type gates, main-source elaboration, and transitive axiom checks passed on 2026-11-08 with Lean 4.32.0.

This independent review first checked the target definitions against the manuscript before the proof was complete, then inspected the assembled proof interfaces and independently checked the completed endpoints after the coherent build. The Lean root is `neural-network-generalization/lean`. No proof sources were edited for this audit.

## Conclusion

The assembled proof has the intended semantics. I found no reduced posterior function class, assumed online conclusion, omitted normalization condition, changed Gaussian law, invalid width/scale quantifier interchange, or weakened teacher resource in the reviewed source chain.

The checked endpoints in [OnlineLowerTanhMain.lean](../NeuralGeneralization/OnlineLowerTanhMain.lean) have no parameters:

```lean
NeuralGeneralization.OnlineLower.tanh_concrete_main :
  NeuralGeneralization.OnlineLower.TanhConcreteMainStatement

NeuralGeneralization.OnlineLower.tanh_path_logarithmic_rail_main :
  NeuralGeneralization.OnlineLower.TanhPathLogarithmicRailStatement

NeuralGeneralization.OnlineLower.tanh_square_root_log_loss_lower_bound :
  NeuralGeneralization.OnlineLower.TanhSquareRootLogLossStatement
```

Each of these declarations passed an independent exact-type assignment. Each transitive axiom list is exactly `propext`, `Classical.choice`, and `Quot.sound`; no `sorryAx`, project axiom, or native evaluation trust axiom occurs. The previously inspected target and model source hashes are unchanged, so this proof inhabits the same propositions approved in the original statement audit.

## Dependency and semantic trace

1. **Actual maximizers, not an assumed sharp inequality.** `IntrinsicParityBound n w` literally states `∀ u : Fin n → ℝ, w * |parityCorrelation u 0| ≤ sqrt(incomingEnergy u)`. `eventual_intrinsicParityBound` proves it by contradiction from actual global maximizers of the finite-cube normalized tanh coefficient. `IsIntrinsicMaximizer` compares against all real incoming vectors. The optimizer limit, empirical classification, exact bulk, and outlier arguments retain the original incoming coordinates through their maps and reindexings.

2. **No hidden sharpness fields in the new structures.** `OptimizerLatticeLimit` contains actual lattice data, a strictly increasing subsequence, and scalar/frequency limits. `NearBalancedSequence` contains the actual incoming arrays, their maximality, literal bulk subsets, and quantitative convergence properties; `OptimizerLatticeLimit.nearBulk` constructs all fields from proved results about the original maximizing sequence. `NearPairResidualData` contains an explicit identity between residual incoming arrays and selected original coordinates; its existence is proved. None contains the desired global sharp inequality or online conclusion as an assumed field. The final contradiction constructs these structures from the actual maximizers before using them.

3. **Actual balanced cost.** `balancedCost r` is the inverse correlation cost at the actual chosen balanced gain. `holomorphicOptimizedCost_odd` identifies the analytic interpolation with that literal value on odd degrees, including its square-root and central-binomial factors. `codeBalancedCost_eq_scalarSupportWeight` then identifies the path scalar weights with the costs of the literal shared-carrier physical supports. Thus the scalar path inequalities are not being proved for a substitute asymptotic cost function and then silently reused for actual tanh costs.

4. **All affine neurons.** The intrinsic parity bound is transferred to arbitrary bias and irrelevant incoming coordinates by the exact bias-transfer and conditioning identities. The code-norm theorem quantifies over every real bias and every real physical incoming vector. The logarithmic rail threshold and uniform degree threshold are supplied by `construction_code_thresholds_eventually` and `construction_intrinsic_eventually`; both are proved for the rounded, split-column family.

5. **All actual networks.** `actual_tanh_network_bounds_of_intrinsic` quantifies over every positive width and every `Weights d N 0`. `incoming_sum_eq_cubeAffine`, `firstHidden_eq_cubeAffine`, and `retainedFourierMass_eq_logicalCost` identify the analytic row and Fourier expressions with the actual network definitions. The resulting cost and residual inequalities apply to arbitrary network parameters, not just balanced neurons or code-valued networks.

6. **Projections are auxiliary estimates.** The odd-downward Fourier projection and logical code projection occur in inequalities on an unrestricted whole-cube output. `actual_tanh_mem_rectangle_constraints` proves that every capped, closed-feasible actual network output obeys the closed rectangle constraints. `FamilyAssembly` supplies its neural cost/deficit hypotheses, geometric independence, calibration margins, and removed-fiber constraints from proved theorems. No step conditions the Gaussian prior on belonging to the projected subspace.

7. **Scalar obligations are discharged.** `RectangleScalarCertificate` contains actual finite cost-transform inequalities, candidate-cost injectivity and negativity, a cap, and an absorption inequality. It contains no neural minimum, energy gap, posterior limit, or target-construction field. The checked scalar endpoint obtains each field from the actual cost conditions, path ordering, prefix envelope, dimension cap, and polynomial absorption estimates. Main instantiates it with the constructed `actualGainBranch` and the fixed `K₀` chosen by the code theorem.

8. **Full physical order.** `exists_concrete_rectangle_protocol` constructs one `InputOrder` equivalence enumerating the entire physical cube, with exactly `2^(k−1)` first-hit positions. `HistoryAt` is an equality describing the entire prefix: all noncandidate fibers and all earlier candidate fibers, with the current and later fibers unrevealed. `FamilyAssembly` fixes this order and designated set before constructing any learner-width thresholds. Both the comparator's consistency and its wrong sign at the queried physical point are proved.

9. **All possible correct outputs.** The compactness gap uses the cost and the entire finite-cube score. The cost cap does not exclude competitors: all outputs above the cap are separated automatically. The minimum-score classification is used only to exclude a correct score at the minimum. No uniqueness of a network parameterization, optimizer selection rule, or posterior tie-break is assumed.

10. **Ordinary tanh finite-width witnesses.** `odd_parity_expansion_strict_witness` constructs exact finite signed input-flip orbits at the actual balanced gains. It proves the allocation mass is strictly less than one from the explicit Fourier `ℓ¹` bound and `d > 144`. Integer neuron replication keeps incoming vectors unchanged and divides readouts among copies. Zero Fourier coefficients are removed explicitly. A small readout-only dilation produces strict full-cube margins while preserving the strict energy budget and allocation slack. This does not invoke positive homogeneity of tanh.

11. **Every sufficiently large width.** The allocation lemma supplies a witness for every integer `N ≥ N₀`, not merely a subsequence or an infinite-width representation. A width-independent correct-score gap is proved first. Finite-stage thresholds are then combined over the fixed designated set, and the common threshold is enlarged to be at least the actual teacher width and one. There is no interchange of `N → ∞` with `σ → 0`.

12. **Actual normalized Gaussian posterior.** The energy gap is between infima over actual strict-margin parameter events. `network_functionMass_hasExponentialRate` identifies their small-variance rates under the finite product Gaussian prior via the proved whitening and open-set Gaussian-rate theorem. Empty sign events have zero mass and are handled separately. `correctConfidence_tendsto_zero_of_energy_gap` sums over all correct sign functions; each mass includes all of its parameter realizations. `AllLargeWidthsFail` additionally requires a positive denominator for every positive scale and every input position, supplied independently by the constructed bounded teacher and full Gaussian support.

13. **Literal resources and consequences.** The concrete teacher and circuit are established for every sufficiently large construction index. Main's two resource implications preserve the same target/order before the width/scale quantifiers. The width-rate statement concerns arbitrarily large specified teacher widths; it does not assert minimal teacher complexity or a construction at every integer width. Its `log(C+2)` denominator is asymptotically equivalent to the manuscript's `log C`. Existing finite-joint-law lemmas yield majority errors, expected count, and simultaneous all-wrong probability for independent fresh posterior draws.

## Independent validation

The independent gate imported the completed main module and elaborated these three declarations without any available analytic or certificate hypotheses:

```lean
example : TanhConcreteMainStatement := tanh_concrete_main
example : TanhPathLogarithmicRailStatement := tanh_path_logarithmic_rail_main
example : TanhSquareRootLogLossStatement := tanh_square_root_log_loss_lower_bound
```

It also printed the definitions of `TanhConcreteMainStatement`, `AllLargeWidthsFail`, `posteriorAt`, `smallVariance`, and `smallPrior`, confirming the model and quantifiers in the compiled environment. The command exited successfully. A separate elaboration of the frozen `OnlineLowerTanhMain.lean` source also exited successfully.

Independent transitive axiom checks returned only the same three standard axioms for:

- All three main endpoints above.
- `TanhConcreteProtocol.finite_scale` and `AllLargeWidthsFail.mistake_count_limits`.
- `designatedJointWeight_probability`, `designated_expected_count_identity`, and `designated_all_wrong_probability_identity`.
- `posteriorAt_eq_globalConditioned` and `denominatorAt_pos`.

The coherent main dependency build log ends with `Build completed successfully (4143 jobs)`. I inspected this completion record, then ran the independent checks against those artifacts. An earlier import attempt overlapped the ongoing rebuild and encountered temporarily absent dependency artifacts; the recorded final checks were rerun after completion and both returned exit code zero.

A separate read-only traversal found 465 local project modules in the final main import closure, with no missing source file. A lexical scan after removing comments found no `sorry`, `admit`, `axiom`, `unsafe`, `implemented_by`, or `native_decide` markers. These source scans support, but do not substitute for, the successful kernel and transitive-axiom checks.

The toolchain was Lean 4.32.0, commit `8c9756b28d64dab099da31a4c09229a9e6a2ef35`, with the repository's pinned mathlib revision. The public reproduction commands are:

```sh
lake build NeuralGeneralization.OnlineLowerTanhMain
lake env lean CheckOnlineLowerTanh.lean
```

## Statement and publication scope

The prior statement audit found no mismatch in the following literal requirements, and the final definitions retain them: ordinary `Real.tanh`; one hidden layer and a linear readout; the entire Boolean cube; Gaussian variances `Nσ²/d` and `σ²/N`, including the augmented bias coordinate; strict global margin greater than `1/2`; conditioning on every earlier target sign; actual positive posterior normalizers; a single complete nonrepeating permutation fixed before all learner widths; every sufficiently large fixed width followed by `σ↓0`; teacher margin at least one and every parameter bounded by its specified width; and an actual fan-in-two NAND circuit.

The concrete family fixes `m=6k+6` and has exactly `2^(k−1)` designated rounds, `d=Θ(k log² k)`, and `C=O(k² log² k)`. The regularized logarithm `log(C+2)` is asymptotically equivalent to `log C`. The rate is in a specified implementing teacher width, not an asserted minimum width; the width-rate statement promises arbitrarily large specified widths, not a construction at every integer `C`.

The finite-scale theorem uses a scale cutoff that may depend on the fixed learner width. It guarantees correct-label confidence below `1/3` at each designated round and a probability strictly greater than `1−η` for all designated errors under fresh independent posterior sampling. The literal expected-count identity and limit are checked as well. No IID input-order or sample-complexity claim is introduced.

I reviewed the updated paper's scope paragraph in both its LaTeX source and PDF text, as well as the verification README and main correspondence record. Their main-result scope is accurate. The formal scalar argument uses high-order derivative bounds and mixed differences of the actual optimized cost, which may differ from the paper's inverse-Laplace presentation without changing the theorem.

**This audit certifies correspondence and completed verification of the main improved online lower bound and its stated finite-scale consequences. It does not claim that every separately stated appendix theorem is exported in exactly the same form.** Stronger standalone equality/uniqueness classifications and the unused first-derivative residual CLT require their own statement checks if such individual coverage is claimed.

## Frozen source identifiers

SHA-256 at the independent successful checks:

```text
a21103f472ba851b93bf29cc61ca7d17267c7c2bd51f9ffba32ec44f631da1f4  OnlineLowerStatements.lean
772fdcbd133432215f9b719b75f432cf6f740456e33855a43ad7190f03b8ee6e  OnlineLowerTanhConcreteStatement.lean
f6851b7c8207137e0ac44f5fc07129bb62239177dc1c135778676841dba31f5d  OnlineLowerModel.lean
113dbbec4c6f48ae2c48b392b70c1fc1827ac28878f74db3e475e8c96c400e6d  OnlineLowerTeacherModel.lean
527714347a5921e5a64231bd08d3c27715490bfda24da4f15bb3a25d42b8c2dc  OnlineLowerTanhMain.lean
```

The [main correspondence record](OnlineLowerTanh-main-correspondence.md) links the published source-closure manifest and standard gate output.
