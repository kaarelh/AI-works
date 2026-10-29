import GridSignReadout
import BooleanGridInput

/-! Assembly of actual initialization, parallel iteration and Boolean readout. -/
noncomputable section
namespace ConditionalNonpolynomial.AnalyticLookup
open ConditionalNonpolynomial.Analytic
variable {ζ κ : Type*} [Fintype ζ] [Fintype κ]

 def assembledGridClassifier {d Q N Qr Nr : ℕ}
    (initial : CircuitMap d (Fintype.card (ζ⊕κ)*Fintype.card (ScalarGrid Q N)))
    (step : CircuitMap (Fintype.card (ζ⊕κ)*Fintype.card (ScalarGrid Q N))
      (Fintype.card κ*Fintype.card (ScalarGrid Q N))) (k : ℕ)
    (readout : CircuitMap (Fintype.card (ζ⊕κ)*Fintype.card (ScalarGrid Q N))
      (Fintype.card Unit*Fintype.card (ScalarGrid Qr Nr))) : ThresholdCircuit d :=
  let full := (initial.then (pipeline (List.replicate k (carryInputCircuit step)))).then readout
  substituteCircuit full.gates full.outputs (gridSignCircuit Qr Nr ())

 theorem assembledGridClassifier_correct {d Q N Qr Nr : ℕ}
    (initial : CircuitMap d (Fintype.card (ζ⊕κ)*Fintype.card (ScalarGrid Q N)))
    (step : CircuitMap (Fintype.card (ζ⊕κ)*Fintype.card (ScalarGrid Q N))
      (Fintype.card κ*Fintype.card (ScalarGrid Q N))) (k : ℕ)
    (readout : CircuitMap (Fintype.card (ζ⊕κ)*Fintype.card (ScalarGrid Q N))
      (Fintype.card Unit*Fintype.card (ScalarGrid Qr Nr)))
    (F : EuclideanSpace ℝ (ζ⊕κ)→EuclideanSpace ℝ κ) {δ ε : ℝ}
    (hstep : GridApproximates Q N Q N F step δ)
    (a : Input d→ζ→ScalarCode Q N) (u : Input d→κ→ScalarCode Q N)
    (hinit : ∀x,initial.eval x=encodeCoordinateState Q N (Sum.elim (a x) (u x)))
    (z : Input d→ℝ) (f : Input d→Bool) (hε : 0≤ε)
    (hmargin : ∀x,ε<NeuralGeneralization.ConcreteModel.labelReal (f x)*z x)
    (hread : ∀x,∃b:Unit→ScalarCode Qr Nr,
      readout.eval (encodeCoordinateState Q N (Sum.elim (a x) (gridIteration hstep (a x) (u x) k)))=
        encodeCoordinateState Qr Nr b ∧ |z x-scalarDecode Qr Nr (b ())|≤ε) :
    (assembledGridClassifier initial step k readout).eval=f := by
  funext x
  obtain ⟨b,hb,he⟩:=hread x
  unfold assembledGridClassifier
  rw [substituteCircuit_eval]
  change (gridSignCircuit Qr Nr ()).eval (((initial.then _).then readout).eval x)=f x
  rw [CircuitMap.eval_then,CircuitMap.eval_then,hinit x,gridIteration_eval hstep,hb]
  exact gridSignCircuit_correct () b (f x) (z x) ε hε (hmargin x) he

 theorem assembledGridClassifier_size {d Q N Qr Nr : ℕ}
    (initial : CircuitMap d (Fintype.card (ζ⊕κ)*Fintype.card (ScalarGrid Q N)))
    (step : CircuitMap (Fintype.card (ζ⊕κ)*Fintype.card (ScalarGrid Q N))
      (Fintype.card κ*Fintype.card (ScalarGrid Q N))) (k : ℕ)
    (readout : CircuitMap (Fintype.card (ζ⊕κ)*Fintype.card (ScalarGrid Q N))
      (Fintype.card Unit*Fintype.card (ScalarGrid Qr Nr))) :
    (assembledGridClassifier initial step k readout).size ≤ initial.size+
      k*(Fintype.card (ζ⊕κ)*Fintype.card (ScalarGrid Q N))*step.size+
      readout.size+Fintype.card (ScalarGrid Qr Nr)+1 := by
  have hp:=(gridIteration_bounds step k).1
  have hs:=gridSignCircuit_size Qr Nr (ι:=Unit) ()
  unfold assembledGridClassifier
  rw [substituteCircuit_size]
  change ((initial.then _).then readout).size+_≤_
  rw [CircuitMap.size_then,CircuitMap.size_then]
  omega

 theorem assembledGridClassifier_depth {d Q N Qr Nr : ℕ}
    (initial : CircuitMap d (Fintype.card (ζ⊕κ)*Fintype.card (ScalarGrid Q N)))
    (step : CircuitMap (Fintype.card (ζ⊕κ)*Fintype.card (ScalarGrid Q N))
      (Fintype.card κ*Fintype.card (ScalarGrid Q N))) (k : ℕ)
    (readout : CircuitMap (Fintype.card (ζ⊕κ)*Fintype.card (ScalarGrid Q N))
      (Fintype.card Unit*Fintype.card (ScalarGrid Qr Nr))) :
    (assembledGridClassifier initial step k readout).depth≤
      initial.depth+k*step.depth+readout.depth+1 := by
  apply (substituteCircuit_depth _ _ _).trans
  apply Nat.add_le_add
  · exact (CircuitMap.depth_then _ _).trans
      (Nat.add_le_add ((CircuitMap.depth_then _ _).trans
        (Nat.add_le_add le_rfl (gridIteration_bounds step k).2)) le_rfl)
  · exact gridSignCircuit_depth _ _ _

#print axioms assembledGridClassifier_correct
#print axioms assembledGridClassifier_depth
end ConditionalNonpolynomial.AnalyticLookup
