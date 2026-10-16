import NeuralGeneralization
import Lean.Util.CollectAxioms
import Lean.Elab.Command

/-!
# Publication gate for the four main theorems

This check requires all four exact main proofs and rejects unexpected axioms.
A successful component build alone does not satisfy this gate. Missing or
mismatched proof declarations are reported as errors.
-/

open Lean Elab Command Meta in
run_cmd do
  let targets := #[
    (``NeuralGeneralization.MainStatements.StrongPriorGeneralization,
      `NeuralGeneralization.MainProofs.strongPrior),
    (``NeuralGeneralization.MainStatements.AboveMeanFieldGeneralization,
      `NeuralGeneralization.MainProofs.aboveMeanField),
    (``NeuralGeneralization.MainStatements.MeanFieldGeneralization,
      `NeuralGeneralization.MainProofs.meanField),
    (``NeuralGeneralization.MainStatements.SubcriticalExponentialLowerBound,
      `NeuralGeneralization.MainProofs.subcriticalExponential)]
  let env ← getEnv
  let mut missing : Array Name := #[]
  for (statement, proofName) in targets do
    match env.find? proofName with
    | none => missing := missing.push statement
    | some info =>
      unless info.isTheorem do
        throwError "Main proof {proofName} is not a theorem declaration"
      let matchesType ← liftTermElabM <| isDefEq info.type (mkConst statement)
      unless matchesType do
        throwError "Main proof {proofName} has the wrong type for {statement}"
      let axioms ← Lean.collectAxioms proofName
      let allowed := #[``propext, ``Classical.choice, ``Quot.sound]
      let unexpected := axioms.filter fun a => !allowed.contains a
      unless unexpected.isEmpty do
        throwError "Main proof {proofName} has unexpected axioms: {unexpected}"
  unless missing.isEmpty do
    throwError "MAIN VERIFICATION INCOMPLETE: {missing.size}/4 proofs missing: {missing}"
  logInfo "All four exact main statements have closed proofs using only the standard axioms."
