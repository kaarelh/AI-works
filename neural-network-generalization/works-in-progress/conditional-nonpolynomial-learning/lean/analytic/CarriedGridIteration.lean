import GridOutputRecoding

/-! Actual repeated threshold DAGs retain the original input bits exactly.
Only the evolving numerical state is rounded. -/
noncomputable section
open scoped BigOperators
namespace ConditionalNonpolynomial.AnalyticLookup
open ConditionalNonpolynomial.Analytic
variable {ι κ : Type*} [Fintype ι] [Fintype κ]

 def carryInputCircuit {Q N : ℕ}
    (c : CircuitMap (Fintype.card (ι⊕κ)*Fintype.card (ScalarGrid Q N))
      (Fintype.card κ*Fintype.card (ScalarGrid Q N))) :=
  sumGridCircuits (projectGridCoordinates Q N (Sum.inl : ι→ι⊕κ)) c

 def chosenGridUpdate {Q N : ℕ} {F : EuclideanSpace ℝ (ι⊕κ)→EuclideanSpace ℝ κ}
    {c : CircuitMap (Fintype.card (ι⊕κ)*Fintype.card (ScalarGrid Q N))
      (Fintype.card κ*Fintype.card (ScalarGrid Q N))} {δ : ℝ}
    (hc : GridApproximates Q N Q N F c δ) (a : ι→ScalarCode Q N) (u : κ→ScalarCode Q N) :
      κ→ScalarCode Q N := Classical.choose (hc (Sum.elim a u))

 theorem chosenGridUpdate_eval {Q N : ℕ} {F : EuclideanSpace ℝ (ι⊕κ)→EuclideanSpace ℝ κ}
    {c : CircuitMap (Fintype.card (ι⊕κ)*Fintype.card (ScalarGrid Q N))
      (Fintype.card κ*Fintype.card (ScalarGrid Q N))} {δ : ℝ}
    (hc : GridApproximates Q N Q N F c δ) (a : ι→ScalarCode Q N) (u : κ→ScalarCode Q N) :
    (carryInputCircuit c).eval (encodeCoordinateState Q N (Sum.elim a u))=
      encodeCoordinateState Q N (Sum.elim a (chosenGridUpdate hc a u)) := by
  apply sumGridCircuits_eval
  · rw [projectGridCoordinates_eval]
    rfl
  · exact (Classical.choose_spec (hc (Sum.elim a u))).1

 theorem chosenGridUpdate_error {Q N : ℕ} {F : EuclideanSpace ℝ (ι⊕κ)→EuclideanSpace ℝ κ}
    {c : CircuitMap (Fintype.card (ι⊕κ)*Fintype.card (ScalarGrid Q N))
      (Fintype.card κ*Fintype.card (ScalarGrid Q N))} {δ : ℝ}
    (hc : GridApproximates Q N Q N F c δ) (a : ι→ScalarCode Q N) (u : κ→ScalarCode Q N) :
    ‖F (decodeCoordinates Q N (Sum.elim a u))-decodeCoordinates Q N (chosenGridUpdate hc a u)‖≤δ :=
  (Classical.choose_spec (hc (Sum.elim a u))).2

 def gridIteration {Q N : ℕ} {F : EuclideanSpace ℝ (ι⊕κ)→EuclideanSpace ℝ κ}
    {c : CircuitMap (Fintype.card (ι⊕κ)*Fintype.card (ScalarGrid Q N))
      (Fintype.card κ*Fintype.card (ScalarGrid Q N))} {δ : ℝ}
    (hc : GridApproximates Q N Q N F c δ) (a : ι→ScalarCode Q N) (u : κ→ScalarCode Q N) :
      ℕ→κ→ScalarCode Q N
  | 0=>u
  | k+1=>chosenGridUpdate hc a (gridIteration hc a u k)

 theorem gridIteration_succ_left {Q N : ℕ} {F : EuclideanSpace ℝ (ι⊕κ)→EuclideanSpace ℝ κ}
    {c : CircuitMap (Fintype.card (ι⊕κ)*Fintype.card (ScalarGrid Q N))
      (Fintype.card κ*Fintype.card (ScalarGrid Q N))} {δ : ℝ}
    (hc : GridApproximates Q N Q N F c δ) (a : ι→ScalarCode Q N) (u : κ→ScalarCode Q N)
    (k : ℕ) : gridIteration hc a (chosenGridUpdate hc a u) k=gridIteration hc a u (k+1) := by
  induction k generalizing u with
  | zero=>rfl
  | succ k ih=>simp only [gridIteration,ih]

 theorem gridIteration_eval {Q N : ℕ} {F : EuclideanSpace ℝ (ι⊕κ)→EuclideanSpace ℝ κ}
    {c : CircuitMap (Fintype.card (ι⊕κ)*Fintype.card (ScalarGrid Q N))
      (Fintype.card κ*Fintype.card (ScalarGrid Q N))} {δ : ℝ}
    (hc : GridApproximates Q N Q N F c δ) (a : ι→ScalarCode Q N) (u : κ→ScalarCode Q N)
    (k : ℕ) :
    (pipeline (List.replicate k (carryInputCircuit c))).eval (encodeCoordinateState Q N (Sum.elim a u))=
      encodeCoordinateState Q N (Sum.elim a (gridIteration hc a u k)) := by
  induction k generalizing u with
  | zero=>simp [pipeline,gridIteration]
  | succ k ih=>
    rw [List.replicate_succ,pipeline,CircuitMap.eval_then,chosenGridUpdate_eval hc]
    rw [ih]
    rw [gridIteration_succ_left]

 theorem gridIteration_step_error {Q N : ℕ} {F : EuclideanSpace ℝ (ι⊕κ)→EuclideanSpace ℝ κ}
    {c : CircuitMap (Fintype.card (ι⊕κ)*Fintype.card (ScalarGrid Q N))
      (Fintype.card κ*Fintype.card (ScalarGrid Q N))} {δ : ℝ}
    (hc : GridApproximates Q N Q N F c δ) (a : ι→ScalarCode Q N) (u : κ→ScalarCode Q N)
    (k : ℕ) :
    ‖decodeCoordinates Q N (gridIteration hc a u (k+1))-
      F (decodeCoordinates Q N (Sum.elim a (gridIteration hc a u k)))‖≤δ := by
  rw [norm_sub_rev]
  exact chosenGridUpdate_error hc a _

 theorem gridIteration_bounds {Q N : ℕ}
    (c : CircuitMap (Fintype.card (ι⊕κ)*Fintype.card (ScalarGrid Q N))
      (Fintype.card κ*Fintype.card (ScalarGrid Q N))) (k : ℕ) :
    (pipeline (List.replicate k (carryInputCircuit c))).size≤
      k*(Fintype.card (ι⊕κ)*Fintype.card (ScalarGrid Q N))*c.size ∧
    (pipeline (List.replicate k (carryInputCircuit c))).depth≤k*c.depth := by
  have hs : (carryInputCircuit c).size≤
      (Fintype.card (ι⊕κ)*Fintype.card (ScalarGrid Q N))*c.size := by
    simpa only [carryInputCircuit,projectGridCoordinates,CircuitMap.rewire_size,zero_add] using
      sumGridCircuits_size (projectGridCoordinates Q N (Sum.inl : ι→ι⊕κ)) c
  have hd : (carryInputCircuit c).depth≤c.depth := by
    apply sumGridCircuits_depth _ _ c.depth
    · simp [projectGridCoordinates]
    · exact le_refl _
  have hh:=pipeline_bounds (List.replicate k (carryInputCircuit c))
    ((Fintype.card (ι⊕κ)*Fintype.card (ScalarGrid Q N))*c.size) c.depth
    (by intro c' hc';have he:=List.eq_of_mem_replicate hc';subst c';exact hs)
    (by intro c' hc';have he:=List.eq_of_mem_replicate hc';subst c';exact hd)
  simpa only [List.length_replicate,Nat.mul_assoc] using hh

#print axioms gridIteration_eval
#print axioms gridIteration_step_error
#print axioms gridIteration_bounds
end ConditionalNonpolynomial.AnalyticLookup
