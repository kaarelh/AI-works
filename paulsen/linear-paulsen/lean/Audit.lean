import Paulsen
import Lean.Util.CollectAxioms
import Lean.Elab.Command

/-!
# Audit of the formalisation of the linear Paulsen bound

1. The final theorems have exactly the target types `Paulsen.SharpPaulsenBound`
   and `Paulsen.SharpProjectionBound` (defined in `Paulsen.Definitions` and
   `Paulsen.SharpProjection`).
2. Every theorem in the `Paulsen` namespace depends only on `propext`,
   `Classical.choice` and `Quot.sound`.
3. The final proof uses the argument of the accompanying paper: the
   barrier-constant balancing, both seeds (centred remainder, drift), and the
   partition-free assembly; and it does not use the Poisson-constant
   endpoints or the crude termwise remainder budget.
-/

example : Paulsen.SharpPaulsenBound := Paulsen.Linear.sharpPaulsenBound
example : Paulsen.SharpProjectionBound := Paulsen.Linear.sharpProjectionBound

#print axioms Paulsen.Linear.sharpPaulsenBound
#print axioms Paulsen.Linear.sharpProjectionBound

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
  let deps := (paulsenProofDependencies env ``Paulsen.Linear.sharpPaulsenBound).run {} |>.2
  let required := #[
    -- assembly without a block partition
    `Paulsen.Linear.sharpPaulsenBound_of_seeds,
    `Paulsen.Linear.low_density_small_error,
    `Paulsen.quadratic_equalRowBound,
    -- barrier-constant toolbox
    `Paulsen.Linear.HasBarrierBound,
    `Paulsen.Linear.barrier_subset_bound,
    `Paulsen.Linear.balancing_cost_barrier,
    `Paulsen.Linear.core_barrier,
    `Paulsen.Linear.block_barrier,
    `Paulsen.Linear.indicator_exceptional_barrier,
    `Paulsen.Linear.IsSeed.hasCorrection,
    -- many-row seed with the centred remainder
    `Paulsen.Linear.manyRowBound,
    `Paulsen.Linear.tangentRemainder_centred_bound,
    `Paulsen.Linear.correction_of_exceptional_set_barrier,
    -- moderate-row seed with the drift
    `Paulsen.Linear.moderateParsevalBound,
    `Paulsen.Linear.driftMean_diagonal,
    `Paulsen.Linear.exists_drifted_retraction]
  for name in required do
    unless deps.contains name do
      throwError "The final proof does not use {name}"
  let forbidden := #[
    `Paulsen.BoundedPoissonSolvability,
    `Paulsen.sharp_correction_of_poisson,
    `Paulsen.balancing_cost,
    `Paulsen.balancing_cost_target,
    `Paulsen.correction_of_exceptional_set,
    `Paulsen.tangentRemainderBudget]
  for name in forbidden do
    if deps.contains name then
      throwError "The final proof uses the superseded declaration {name}"
  logInfo m!"The final proof depends on {deps.size} project declarations; all required ones are present and no superseded endpoint is used."
