import NeuralGeneralization
import Lean.Util.CollectAxioms
import Lean.Elab.Command

/-!
# Axiom audit of the main proofs and their project dependencies

This audit checks every imported project theorem and reports exact main-proof
coverage. The four declarations in `MainStatements` and the robustness
declaration in `RobustMainStatements` define propositions; their separately
named declarations prove them. `CheckMain.lean` and `CheckRobust.lean`
additionally require all five proofs to exist. These checks certify the exact main learning
statements and their imported proofs, not every assertion in every paper.
-/

open Lean Elab Command Meta in
run_cmd do
  let env ← getEnv
  let allowed := #[``propext, ``Classical.choice, ``Quot.sound]
  let mut checked : Nat := 0
  for (name, info) in env.constants.toList do
    if (`NeuralGeneralization).isPrefixOf name && info.isTheorem then
      let axioms ← Lean.collectAxioms name
      let unexpected := axioms.filter fun a => !allowed.contains a
      unless unexpected.isEmpty do
        throwError "Unexpected axioms for {name}: {unexpected}"
      checked := checked + 1
  logInfo m!"Audited {checked} proved project declarations: only propext, Classical.choice, Quot.sound."
  let obligations := #[
    (``NeuralGeneralization.MainStatements.StrongPriorGeneralization,
      `NeuralGeneralization.MainProofs.strongPrior),
    (``NeuralGeneralization.MainStatements.AboveMeanFieldGeneralization,
      `NeuralGeneralization.MainProofs.aboveMeanField),
    (``NeuralGeneralization.MainStatements.MeanFieldGeneralization,
      `NeuralGeneralization.MainProofs.meanField),
    (``NeuralGeneralization.MainStatements.SubcriticalExponentialLowerBound,
      `NeuralGeneralization.MainProofs.subcriticalExponential),
    (``NeuralGeneralization.RobustMainStatements.RobustPolynomialDepthGeneralization,
      `NeuralGeneralization.RobustMainProofs.robustPolynomialDepth)]
  let mut complete : Nat := 0
  for (name, proofName) in obligations do
    let some info := env.find? name | throwError "Missing main statement: {name}"
    unless info.isDefinition do
      throwError "Expected a transparent proposition definition for {name}"
    match env.find? proofName with
    | none => logInfo m!"UNPROVED MAIN OBLIGATION: {name}"
    | some proofInfo =>
      unless proofInfo.isTheorem do
        throwError "Expected a theorem for {proofName}"
      let matchesType ← liftTermElabM <| isDefEq proofInfo.type (mkConst name)
      unless matchesType do
        throwError "Main proof {proofName} does not have the exact requested type"
      complete := complete + 1
      logInfo m!"PROVED MAIN STATEMENT: {name}"
  logInfo m!"Main results proved end to end: {complete} / 5. Use CheckMain.lean and CheckRobust.lean for the all-results publication gates."
