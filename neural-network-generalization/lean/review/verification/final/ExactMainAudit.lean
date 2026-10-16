import NeuralGeneralization.StrongPriorMain
import NeuralGeneralization.AboveMeanFieldMain
import NeuralGeneralization.MeanFieldMain
import NeuralGeneralization.SubcriticalMain
import Lean.Util.CollectAxioms
import Lean.Elab.Command

example : NeuralGeneralization.MainStatements.StrongPriorGeneralization :=
  NeuralGeneralization.MainProofs.strongPrior
#print axioms NeuralGeneralization.MainProofs.strongPrior
example : NeuralGeneralization.MainStatements.AboveMeanFieldGeneralization :=
  NeuralGeneralization.MainProofs.aboveMeanField
#print axioms NeuralGeneralization.MainProofs.aboveMeanField
example : NeuralGeneralization.MainStatements.MeanFieldGeneralization :=
  NeuralGeneralization.MainProofs.meanField
#print axioms NeuralGeneralization.MainProofs.meanField
example : NeuralGeneralization.MainStatements.SubcriticalExponentialLowerBound :=
  NeuralGeneralization.MainProofs.subcriticalExponential
#print axioms NeuralGeneralization.MainProofs.subcriticalExponential

open Lean Elab Command Meta in
run_cmd do
  let targets := #[
    (``NeuralGeneralization.MainStatements.StrongPriorGeneralization, ``NeuralGeneralization.MainProofs.strongPrior),
    (``NeuralGeneralization.MainStatements.AboveMeanFieldGeneralization, ``NeuralGeneralization.MainProofs.aboveMeanField),
    (``NeuralGeneralization.MainStatements.MeanFieldGeneralization, ``NeuralGeneralization.MainProofs.meanField),
    (``NeuralGeneralization.MainStatements.SubcriticalExponentialLowerBound, ``NeuralGeneralization.MainProofs.subcriticalExponential)]
  for (statement, proofName) in targets do
    let info ← getConstInfo proofName
    unless info.isTheorem do throwError "Main proof is not a theorem: {proofName}"
    let exactType ← liftTermElabM <| isDefEq info.type (mkConst statement)
    unless exactType do throwError "Wrong exact main type: {proofName}"
    let axioms ← Lean.collectAxioms proofName
    let allowed := #[``propext, ``Classical.choice, ``Quot.sound]
    unless (axioms.filter fun a => !allowed.contains a).isEmpty do
      throwError "Unexpected axioms for {proofName}: {axioms}"
    logInfo m!"Verified exact main statement and standard-axiom closure: {proofName}"
