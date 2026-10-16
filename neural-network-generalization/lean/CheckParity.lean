import NeuralGeneralization.SubcriticalCircuitCorollary
import Lean.Util.CollectAxioms
import Lean.Elab.Command

open NeuralGeneralization ConcreteModel in
example (d r : ℕ) :
    realizesAtComplexity (r:=r) Real.tanh (parity d) (32*(d+1)^2) :=
  ParityNetwork.parity_realizes_every_depth d r

open NeuralGeneralization ConcreteModel in
example (d r : ℕ) :
    ∃ C, isComplexity (r:=r) Real.tanh (parity d) C ∧ C≤32*(d+1)^2 :=
  ParityNetwork.exists_parity_complexity d r

#print axioms NeuralGeneralization.ParityNetwork.parity_realizes_every_depth
#print axioms NeuralGeneralization.ParityNetwork.exists_parity_complexity
#print axioms NeuralGeneralization.MainProofs.subcriticalSmallNetworkLowerBound

open Lean Elab Command in
run_cmd do
  let allowed := #[``propext, ``Classical.choice, ``Quot.sound]
  for proofName in #[``NeuralGeneralization.ParityNetwork.parity_realizes_every_depth,
      ``NeuralGeneralization.ParityNetwork.exists_parity_complexity,
      ``NeuralGeneralization.MainProofs.subcriticalSmallNetworkLowerBound] do
    let info ← getConstInfo proofName
    unless info.isTheorem do throwError "Expected a theorem: {proofName}"
    let axioms ← Lean.collectAxioms proofName
    unless (axioms.filter fun a => !allowed.contains a).isEmpty do
      throwError "Unexpected axioms for {proofName}: {axioms}"
  logInfo "Actual polynomial parity complexity and its subcritical lower-bound corollary verified."
