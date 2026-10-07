import Paulsen
import Lean.Util.CollectAxioms
import Lean.Elab.Command

/-!
# Audit of the formalisation of "A linear bound for the Paulsen problem"

1. The final theorems have exactly the target types `Paulsen.SharpPaulsenBound` and
   `Paulsen.SharpProjectionBound`.
2. Every imported theorem of the project depends only on `propext`, `Classical.choice` and
   `Quot.sound` (so no statement of `Paulsen/Paper` is left unproved).
3. The proofs of the two final theorems go through the paper's statements: every
   `lem_*`, `thm_*`, `cor_*`, `eq_*` and `prop_*` theorem of `Paulsen.Paper` is in their
   dependency cone, except the few listed below, which are proved but not needed
   (existential forms whose explicit versions are used, and a definitional
   restatement). Remarks (`rem_*`) are proved as standalone statements.
4. The trace-distance estimate and ordinary resolvent are in the final proof chain.
   Specified older Gaussian and worse-constant routes are excluded.
-/

example : Paulsen.SharpPaulsenBound := Paulsen.Paper.thm_main
example : Paulsen.SharpProjectionBound := Paulsen.Paper.thm_projection

#print axioms Paulsen.Paper.thm_main
#print axioms Paulsen.Paper.thm_projection

open Lean Elab Command in
run_cmd do
  let env ← getEnv
  let allowed := #[``propext, ``Classical.choice, ``Quot.sound]
  let mut checked : Nat := 0
  for (name, info) in env.constants.toList do
    if (`Paulsen).isPrefixOf name && info.isTheorem then
      let axioms ← Lean.collectAxioms name
      let unexpected := axioms.filter fun a => !allowed.contains a
      unless unexpected.isEmpty do
        throwError "Unexpected axioms for {name}: {unexpected}"
      checked := checked + 1
  logInfo m!"Audited {checked} Paulsen theorems. Only propext, Classical.choice, and Quot.sound occur."

open Lean in
partial def paulsenProofDependencies (env : Environment) (name : Name) :
    StateM NameSet Unit := do
  if !((`Paulsen).isPrefixOf name || (`_private.Paulsen).isPrefixOf name) ||
      (← get).contains name then return
  modify fun seen => seen.insert name
  if let some info := env.find? name then
    info.type.getUsedConstants.forM (paulsenProofDependencies env)
    if let some value := info.value? true then
      value.getUsedConstants.forM (paulsenProofDependencies env)

open Lean Elab Command in
run_cmd do
  let env ← getEnv
  let d₁ := (paulsenProofDependencies env ``Paulsen.Paper.thm_main).run {} |>.2
  let deps := (paulsenProofDependencies env ``Paulsen.Paper.thm_projection).run d₁ |>.2
  let standalone := #[`Paulsen.Paper.lem_sample, `Paulsen.Paper.lem_seed_graph,
    `Paulsen.Paper.eq_S, `Paulsen.Paper.eq_nearly_iff, `Paulsen.Paper.thm_main_constant_chain]
  let prefixes := #["lem_", "thm_", "cor_", "eq_", "prop_"]
  let mut required : Nat := 0
  for (name, info) in env.constants.toList do
    if info.isTheorem && name.components.length == 3 && (`Paulsen.Paper).isPrefixOf name then
      let last := name.components.getLast!.toString
      if prefixes.any (last.startsWith ·) && !standalone.contains name then
        required := required + 1
        unless deps.contains name do
          throwError "The final proofs do not use the paper statement {name}"
  let revisedRoute := #[
    ``Paulsen.scaling_trace_identity,
    ``Paulsen.scaling_distance_trace_bound,
    ``Paulsen.rowScale_projection_trace_bound,
    ``Paulsen.Paper.scaling_projection_distance,
    ``Paulsen.Resolvent.moderateNoiseFrame,
    ``Paulsen.Resolvent.factorRoot_sq,
    ``Paulsen.Resolvent.normalizedTangentNoiseFactor_covariance,
    ``Paulsen.Resolvent.covariance_rational_formula,
    ``Paulsen.Resolvent.covariance_loss_le_normal,
    ``Paulsen.Resolvent.residual_decomposition,
    ``Paulsen.Resolvent.driftMean_diagonal,
    ``Paulsen.Resolvent.retainedTangentFactor_covariance]
  for name in revisedRoute do
    unless deps.contains name do
      throwError "The final proofs do not use the revised construction {name}"
  let forbidden := #[
    `Paulsen.Smooth.moderateNoiseFrame,
    `Paulsen.Smooth.covariance,
    `Paulsen.Smooth.normalizedTangentNoiseFactor,
    `Paulsen.Linear.sharpPaulsenBound, `Paulsen.Linear.manyRowBound,
    `Paulsen.Linear.moderateParsevalBound, `Paulsen.Linear.balancing_cost_barrier,
    `Paulsen.Linear.IsSeed.hasCorrection, `Paulsen.Linear.exists_drifted_retraction,
    `Paulsen.Smooth.exists_moderateGaussianSample_with_cross,
    `Paulsen.Smooth.expected_retainedTangent_expansion,
    `Paulsen.euclideanQuadratic_stdGaussian_abs_tail,
    `Paulsen.rowIndependentSeed_dense_core_failure_le,
    `Paulsen.tangentQuadraticMean_conditioned_bias_le,
    `Paulsen.balancing_cost, `Paulsen.balancing_cost_target,
    `Paulsen.sharp_correction_of_poisson, `Paulsen.BoundedPoissonSolvability]
  for name in forbidden do
    if deps.contains name then
      throwError "The final proofs use the superseded library declaration {name}"
  logInfo m!"The final proofs depend on {deps.size} project declarations, including all {required} required paper statements and all {revisedRoute.size} required trace/resolvent declarations; no forbidden earlier route is used."
