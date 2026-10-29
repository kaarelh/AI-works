import ParallelGridCircuits

noncomputable section
open scoped BigOperators
namespace ConditionalNonpolynomial.AnalyticLookup
open ConditionalNonpolynomial.Analytic
variable {ι κ : Type*} [Fintype ι] [Fintype κ]

/-- A proved output bound allows every intermediate evaluator to return to a
single fixed grid, rather than letting grid ranges grow with iteration count. -/
theorem GridApproximates.recodeOutput {Qi Ni Q N Q' N' : ℕ}
    {F : EuclideanSpace ℝ ι→EuclideanSpace ℝ κ}
    {c : CircuitMap (Fintype.card ι*Fintype.card (ScalarGrid Qi Ni))
      (Fintype.card κ*Fintype.card (ScalarGrid Q N))}
    {ε R : ℝ} (hc : GridApproximates Qi Ni Q N F c ε) (hQ' : 0<Q')
    (hF : ∀a:ι→ScalarCode Qi Ni,‖F (decodeCoordinates Qi Ni a)‖≤R)
    (hN' : R+ε≤(N':ℝ)) :
    GridApproximates Qi Ni Q' N' F (c.then (recodeCoordinates Q N Q' N'))
      (ε+((Fintype.card κ:ℝ)+1)/(2*(Q':ℝ))) := by
  intro a
  obtain ⟨b,hb,herr⟩:=hc a
  let b':κ→ScalarCode Q' N':=fun j=>scalarEncode Q' N' (scalarDecode Q N (b j))
  refine ⟨b',?_,?_⟩
  · rw [CircuitMap.eval_then,hb,recodeCoordinates_eval]
  · have hbnd : ∀j,|scalarDecode Q N (b j)|≤(N':ℝ) := by
      intro j
      have hnorm : ‖decodeCoordinates Q N b‖≤R+ε := by
        have hh:=norm_sub_le (decodeCoordinates Q N b) (F (decodeCoordinates Qi Ni a))
        have ht:=norm_le_norm_sub_add (decodeCoordinates Q N b) (F (decodeCoordinates Qi Ni a))
        rw [norm_sub_rev] at ht
        linarith [hF a]
      exact (PiLp.norm_apply_le (decodeCoordinates Q N b) j).trans (hnorm.trans hN')
    have hrecode : ‖decodeCoordinates Q N b-decodeCoordinates Q' N' b'‖≤
        ((Fintype.card κ:ℝ)+1)/(2*(Q':ℝ)) := by
      have hh:=euclidean_norm_of_coordinate_bounds (decodeCoordinates Q N b-decodeCoordinates Q' N' b')
        (show 0≤1/(2*(Q':ℝ)) by positivity) (fun j=>scalarEncode_error Q' N' hQ' _ (hbnd j))
      convert hh using 1 <;> ring
    have ht:=dist_triangle (F (decodeCoordinates Qi Ni a)) (decodeCoordinates Q N b)
      (decodeCoordinates Q' N' b')
    simp only [dist_eq_norm] at ht
    exact ht.trans (add_le_add herr hrecode)

/-- Sum-index output wiring, with no assumption that the two output blocks
have the same dimension. -/
def sumGridCircuits {input Q N : ℕ}
    (a : CircuitMap input (Fintype.card ι*Fintype.card (ScalarGrid Q N)))
    (b : CircuitMap input (Fintype.card κ*Fintype.card (ScalarGrid Q N))) :
    CircuitMap input (Fintype.card (ι⊕κ)*Fintype.card (ScalarGrid Q N)) :=
  CircuitMap.ofCircuits fun bit=>match gridWireCoordinate Q N bit with
    | .inl i=>a.select (gridWire Q N i (gridWireValue (ι:=ι⊕κ) Q N bit))
    | .inr j=>b.select (gridWire Q N j (gridWireValue (ι:=ι⊕κ) Q N bit))

 theorem sumGridCircuits_eval {input Q N : ℕ}
    (a : CircuitMap input (Fintype.card ι*Fintype.card (ScalarGrid Q N)))
    (b : CircuitMap input (Fintype.card κ*Fintype.card (ScalarGrid Q N)))
    (x : Input input) (u : ι→ScalarCode Q N) (v : κ→ScalarCode Q N)
    (ha : a.eval x=encodeCoordinateState Q N u) (hb : b.eval x=encodeCoordinateState Q N v) :
    (sumGridCircuits a b).eval x=encodeCoordinateState Q N (Sum.elim u v) := by
  funext bit
  simp only [sumGridCircuits,CircuitMap.eval_ofCircuits,encodeCoordinateState_bit]
  split <;> simp only [CircuitMap.eval_select,ha,hb,encodeCoordinateState_bit,
    gridWireCoordinate_wire,gridWireValue_wire] <;> rename_i he <;> simp [he]

 theorem sumGridCircuits_depth {input Q N : ℕ}
    (a : CircuitMap input (Fintype.card ι*Fintype.card (ScalarGrid Q N)))
    (b : CircuitMap input (Fintype.card κ*Fintype.card (ScalarGrid Q N)))
    (D : ℕ) (ha : a.depth≤D) (hb : b.depth≤D) : (sumGridCircuits a b).depth≤D := by
  apply CircuitMap.depth_ofCircuits_le
  intro bit
  split <;> assumption

 theorem sumGridCircuits_size {input Q N : ℕ}
    (a : CircuitMap input (Fintype.card ι*Fintype.card (ScalarGrid Q N)))
    (b : CircuitMap input (Fintype.card κ*Fintype.card (ScalarGrid Q N))) :
    (sumGridCircuits a b).size≤
      (Fintype.card (ι⊕κ)*Fintype.card (ScalarGrid Q N))*(a.size+b.size) := by
  apply CircuitMap.size_ofCircuits_le
  intro bit
  split <;> simp only [CircuitMap.size_select] <;> omega

#print axioms GridApproximates.recodeOutput
#print axioms sumGridCircuits_eval
end ConditionalNonpolynomial.AnalyticLookup
