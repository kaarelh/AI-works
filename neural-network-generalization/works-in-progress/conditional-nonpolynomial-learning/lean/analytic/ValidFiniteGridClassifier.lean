import FiniteGridClassifier
import ValidGridIteration

noncomputable section
namespace ConditionalNonpolynomial.AnalyticLookup
open ConditionalNonpolynomial.Analytic
variable {ζ κ : Type*} [Fintype ζ] [Fintype κ]
 theorem assembledGridClassifier_correctOn {d Q N Qr Nr : ℕ}
    (initial : CircuitMap d (Fintype.card (ζ⊕κ)*Fintype.card (ScalarGrid Q N)))
    (step : CircuitMap (Fintype.card (ζ⊕κ)*Fintype.card (ScalarGrid Q N))
      (Fintype.card κ*Fintype.card (ScalarGrid Q N))) (k : ℕ)
    (readout : CircuitMap (Fintype.card (ζ⊕κ)*Fintype.card (ScalarGrid Q N))
      (Fintype.card Unit*Fintype.card (ScalarGrid Qr Nr)))
    (F : EuclideanSpace ℝ (ζ⊕κ)→EuclideanSpace ℝ κ) {δ ε : ℝ}
    (valid : (ζ→ScalarCode Q N)→Prop)
    (hstep : GridApproximatesOn Q N Q N (fun a=>valid (fun i=>a (.inl i))) F step δ)
    (a : Input d→ζ→ScalarCode Q N) (u : Input d→κ→ScalarCode Q N)
    (hvalid : ∀x,valid (a x))
    (hinit : ∀x,initial.eval x=encodeCoordinateState Q N (Sum.elim (a x) (u x)))
    (z : Input d→ℝ) (f : Input d→Bool) (hε : 0≤ε)
    (hmargin : ∀x,ε<NeuralGeneralization.ConcreteModel.labelReal (f x)*z x)
    (hread : ∀x,∃b:Unit→ScalarCode Qr Nr,
      readout.eval (encodeCoordinateState Q N (Sum.elim (a x) (validGridIteration hstep (a x) (hvalid x) (u x) k)))=
        encodeCoordinateState Qr Nr b ∧ |z x-scalarDecode Qr Nr (b ())|≤ε) :
    (assembledGridClassifier initial step k readout).eval=f := by
  funext x
  obtain ⟨b,hb,he⟩:=hread x
  unfold assembledGridClassifier
  rw [substituteCircuit_eval]
  change (gridSignCircuit Qr Nr ()).eval (((initial.then _).then readout).eval x)=f x
  rw [CircuitMap.eval_then,CircuitMap.eval_then,hinit x,validGridIteration_eval hstep (a x) (hvalid x),hb]
  exact gridSignCircuit_correct () b (f x) (z x) ε hε (hmargin x) he

#print axioms assembledGridClassifier_correctOn
end ConditionalNonpolynomial.AnalyticLookup
