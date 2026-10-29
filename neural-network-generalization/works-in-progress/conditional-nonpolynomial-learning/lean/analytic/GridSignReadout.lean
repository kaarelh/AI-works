import ParallelPicardResources

noncomputable section
namespace ConditionalNonpolynomial.AnalyticLookup
open ConditionalNonpolynomial.Analytic
variable {ι : Type*} [Fintype ι]

 def positiveGridCodes (Q N : ℕ) : List (ScalarCode Q N) :=
  (Finset.univ.filter fun a=>0<scalarDecode Q N a).toList

 def gridSignCircuit (Q N : ℕ) (j : ι) :
    ThresholdCircuit (Fintype.card ι*Fintype.card (ScalarGrid Q N)) :=
  thresholdList ((positiveGridCodes Q N).map (fun a=>inputCircuit (gridWire Q N j a))) 1

@[simp] theorem gridSignCircuit_eval (Q N : ℕ) (j : ι) (a : ι→ScalarCode Q N) :
    (gridSignCircuit Q N j).eval (encodeCoordinateState Q N a)=decide (0<scalarDecode Q N (a j)) := by
  apply Bool.eq_iff_iff.mpr
  simp only [gridSignCircuit,thresholdList_any,List.any_eq_true,List.mem_map]
  constructor
  · rintro ⟨c,⟨v,hv,rfl⟩,he⟩
    have hvpos : 0<scalarDecode Q N v := by simpa [positiveGridCodes] using hv
    have hav : a j=v := by
      simpa only [inputCircuit_eval,encodeCoordinateState_bit,gridWireCoordinate_wire,
        gridWireValue_wire,decide_eq_true_eq] using he
    simpa only [decide_eq_true_eq,hav] using hvpos
  · intro he
    have hp : 0<scalarDecode Q N (a j) := of_decide_eq_true he
    refine ⟨inputCircuit (gridWire Q N j (a j)),⟨a j,?_,rfl⟩,?_⟩
    · simp [positiveGridCodes,hp]
    · simp only [inputCircuit_eval,encodeCoordinateState_bit,gridWireCoordinate_wire,gridWireValue_wire,
        decide_true]

 theorem gridSignCircuit_depth (Q N : ℕ) (j : ι) : (gridSignCircuit Q N j).depth≤1 := by
  apply thresholdList_depth _ _ 0
  intro c hc
  obtain ⟨a,ha,rfl⟩:=List.mem_map.mp hc
  exact le_of_eq (inputCircuit_depth _)

 theorem gridSignCircuit_size (Q N : ℕ) (j : ι) :
    (gridSignCircuit Q N j).size≤Fintype.card (ScalarGrid Q N)+1 := by
  have hlen : (positiveGridCodes Q N).length≤Fintype.card (ScalarGrid Q N) := by
    simp only [positiveGridCodes,Finset.length_toList]
    simpa only [Finset.card_univ,Fintype.card_fin] using
      (Finset.card_filter_le (Finset.univ : Finset (ScalarCode Q N)) (fun a=>0<scalarDecode Q N a))
  simpa only [gridSignCircuit,thresholdList_size,List.map_map,Function.comp_def,
    inputCircuit_size,List.map_const',List.sum_replicate,nsmul_zero,List.length_map,zero_add] using
    Nat.add_le_add_right hlen 1

/-- A final scalar margin survives numerical rounding and is converted to an
actual Boolean threshold output. -/
 theorem gridSignCircuit_correct {Q N : ℕ} (j : ι) (a : ι→ScalarCode Q N)
    (truth : Bool) (z ε : ℝ) (hε : 0≤ε)
    (hmargin : ε<NeuralGeneralization.ConcreteModel.labelReal truth*z)
    (herr : |z-scalarDecode Q N (a j)|≤ε) :
    (gridSignCircuit Q N j).eval (encodeCoordinateState Q N a)=truth := by
  rw [gridSignCircuit_eval]
  have hlo:=neg_le_of_abs_le herr
  have hhi:=le_of_abs_le herr
  cases truth <;> simp only [NeuralGeneralization.ConcreteModel.labelReal_false,
    NeuralGeneralization.ConcreteModel.labelReal_true] at hmargin ⊢
  · apply decide_eq_false_iff_not.mpr
    linarith
  · apply decide_eq_true_eq.mpr
    linarith

#print axioms gridSignCircuit_correct
#print axioms gridSignCircuit_size
end ConditionalNonpolynomial.AnalyticLookup
