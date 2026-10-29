import GridSignReadout

/-! An actual one-layer classifier for the union of the balls labelled true.
The distance computation itself is the two-stage distance arithmetic program. -/
noncomputable section
namespace ConditionalNonpolynomial.AnalyticLookup
open ConditionalNonpolynomial.Analytic
variable {J : Type*} [Fintype J]

 def admittedBallCodes (Q N : ℕ) (labels : J→Bool) (r : ℝ) : List (J×ScalarCode Q N) :=
  (Finset.univ.filter fun z=>labels z.1=true ∧ scalarDecode Q N z.2<r).toList

 def gridBallClassifier (Q N : ℕ) (labels : J→Bool) (r : ℝ) :
    ThresholdCircuit (Fintype.card J*Fintype.card (ScalarGrid Q N)) :=
  thresholdList ((admittedBallCodes Q N labels r).map (fun z=>inputCircuit (gridWire Q N z.1 z.2))) 1

@[simp] theorem gridBallClassifier_eval (Q N : ℕ) (labels : J→Bool) (r : ℝ)
    (a : J→ScalarCode Q N) :
    (gridBallClassifier Q N labels r).eval (encodeCoordinateState Q N a)=
      decide (∃j,labels j=true ∧ scalarDecode Q N (a j)<r) := by
  apply Bool.eq_iff_iff.mpr
  simp only [gridBallClassifier,thresholdList_any,List.any_eq_true,List.mem_map,decide_eq_true_eq]
  constructor
  · rintro ⟨c,⟨⟨j,v⟩,hv,rfl⟩,he⟩
    have hmem : labels j=true ∧ scalarDecode Q N v<r := by simpa [admittedBallCodes] using hv
    have hav : a j=v := by
      simpa only [inputCircuit_eval,encodeCoordinateState_bit,gridWireCoordinate_wire,
        gridWireValue_wire,decide_eq_true_eq] using he
    exact ⟨j,hmem.1,hav ▸ hmem.2⟩
  · rintro ⟨j,hj,hr⟩
    refine ⟨inputCircuit (gridWire Q N j (a j)),⟨(j,a j),?_,rfl⟩,?_⟩
    · simp [admittedBallCodes,hj,hr]
    · simp only [inputCircuit_eval,encodeCoordinateState_bit,gridWireCoordinate_wire,
        gridWireValue_wire,decide_true]

 theorem gridBallClassifier_depth (Q N : ℕ) (labels : J→Bool) (r : ℝ) :
    (gridBallClassifier Q N labels r).depth≤1 := by
  apply thresholdList_depth _ _ 0
  intro c hc
  obtain ⟨z,hz,rfl⟩:=List.mem_map.mp hc
  exact le_of_eq (inputCircuit_depth _)

 theorem gridBallClassifier_size (Q N : ℕ) (labels : J→Bool) (r : ℝ) :
    (gridBallClassifier Q N labels r).size≤Fintype.card J*Fintype.card (ScalarGrid Q N)+1 := by
  have hlen : (admittedBallCodes Q N labels r).length≤Fintype.card J*Fintype.card (ScalarGrid Q N) := by
    simp only [admittedBallCodes,Finset.length_toList]
    simpa only [Finset.card_univ,Fintype.card_prod,Fintype.card_fin] using
      (Finset.card_filter_le (Finset.univ : Finset (J×ScalarCode Q N))
        (fun z=>labels z.1=true ∧ scalarDecode Q N z.2<r))
  simpa only [gridBallClassifier,thresholdList_size,List.map_map,Function.comp_def,
    inputCircuit_size,List.map_const',List.sum_replicate,nsmul_zero,List.length_map,zero_add] using
    Nat.add_le_add_right hlen 1

 theorem gridBallClassifier_correct (Q N : ℕ) (labels : J→Bool) (r : ℝ)
    (a : J→ScalarCode Q N) (distances : J→ℝ) (truth : Bool) {ε : ℝ}
    (herr : ∀j,|distances j-scalarDecode Q N (a j)|≤ε)
    (htrue : truth=true→∃j,labels j=true ∧ distances j+ε<r)
    (hfalse : truth=false→∀j,labels j = true → r + ε ≤ distances j) :
    (gridBallClassifier Q N labels r).eval (encodeCoordinateState Q N a)=truth := by
  rw [gridBallClassifier_eval]
  cases truth with
  | false=>
    apply decide_eq_false_iff_not.mpr
    rintro ⟨j,hj,hr⟩
    have hd:=hfalse rfl j hj
    have he:=le_of_abs_le (herr j)
    linarith
  | true=>
    apply decide_eq_true_eq.mpr
    obtain ⟨j,hj,hr⟩:=htrue rfl
    refine ⟨j,hj,?_⟩
    have he:=neg_le_of_abs_le (herr j)
    linarith

#print axioms gridBallClassifier_correct
#print axioms gridBallClassifier_size
end ConditionalNonpolynomial.AnalyticLookup
