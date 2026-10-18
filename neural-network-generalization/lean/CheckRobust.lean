import NeuralGeneralization.RobustMain
import Lean.Util.CollectAxioms
import Lean.Elab.Command

/-!
# Publication gate for the complete polynomial-depth robustness theorem

The proof must have exactly the transparent main proposition as its type.
A reduction with a compression premise does not pass this check. The complete
axiom closure must contain only Lean's usual logical/extensionality axioms.
-/

open Lean Elab Command Meta in
run_cmd do
  let statement := ``NeuralGeneralization.RobustMainStatements.RobustPolynomialDepthGeneralization
  let proofName := `NeuralGeneralization.RobustMainProofs.robustPolynomialDepth
  let env ← getEnv
  let some statementInfo := env.find? statement | throwError "Missing robustness statement"
  unless statementInfo.isDefinition do
    throwError "Robustness statement must be a transparent proposition definition"
  let some info := env.find? proofName | throwError "ROBUST MAIN VERIFICATION INCOMPLETE: proof missing"
  unless info.isTheorem do
    throwError "Robustness proof is not a theorem declaration"
  let matchesType ← liftTermElabM <| isDefEq info.type (mkConst statement)
  unless matchesType do
    throwError "Robustness proof has the wrong type or retains extra hypotheses"
  let axioms ← Lean.collectAxioms proofName
  let allowed := #[``propext, ``Classical.choice, ``Quot.sound]
  let unexpected := axioms.filter fun a => !allowed.contains a
  unless unexpected.isEmpty do
    throwError "Robustness proof has unexpected axioms: {unexpected}"
  logInfo "The exact robustness polynomial-depth main statement has a closed proof using only the standard axioms."
