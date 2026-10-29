import CarriedGridIteration

/-! Numerical semantics restricted to valid retained input codes. The original
Boolean input codes are retained exactly, so the validity predicate is invariant. -/
noncomputable section
namespace ConditionalNonpolynomial.AnalyticLookup
open ConditionalNonpolynomial.Analytic
variable {ι κ ζ : Type*} [Fintype ι] [Fintype κ] [Fintype ζ]

 def GridApproximatesOn (Qi Ni Qo No : ℕ) (valid : (ι→ScalarCode Qi Ni)→Prop)
    (F : EuclideanSpace ℝ ι→EuclideanSpace ℝ κ)
    (c : CircuitMap (Fintype.card ι*Fintype.card (ScalarGrid Qi Ni))
      (Fintype.card κ*Fintype.card (ScalarGrid Qo No))) (ε : ℝ) : Prop :=
  ∀a,valid a→∃b:κ→ScalarCode Qo No,
    c.eval (encodeCoordinateState Qi Ni a)=encodeCoordinateState Qo No b ∧
      ‖F (decodeCoordinates Qi Ni a)-decodeCoordinates Qo No b‖≤ε

 theorem GridApproximates.restrict {Qi Ni Qo No : ℕ} {valid : (ι→ScalarCode Qi Ni)→Prop}
    {F : EuclideanSpace ℝ ι→EuclideanSpace ℝ κ}
    {c : CircuitMap (Fintype.card ι*Fintype.card (ScalarGrid Qi Ni))
      (Fintype.card κ*Fintype.card (ScalarGrid Qo No))} {ε : ℝ}
    (hc : GridApproximates Qi Ni Qo No F c ε) : GridApproximatesOn Qi Ni Qo No valid F c ε :=
  fun a _=>hc a

 theorem GridApproximatesOn.recodeOutput {Qi Ni Q N Q' N' : ℕ}
    {valid : (ι→ScalarCode Qi Ni)→Prop} {F : EuclideanSpace ℝ ι→EuclideanSpace ℝ κ}
    {c : CircuitMap (Fintype.card ι*Fintype.card (ScalarGrid Qi Ni))
      (Fintype.card κ*Fintype.card (ScalarGrid Q N))} {ε R : ℝ}
    (hc : GridApproximatesOn Qi Ni Q N valid F c ε) (hQ' : 0<Q')
    (hF : ∀a,valid a→‖F (decodeCoordinates Qi Ni a)‖≤R) (hN' : R+ε≤(N':ℝ)) :
    GridApproximatesOn Qi Ni Q' N' valid F (c.then (recodeCoordinates Q N Q' N'))
      (ε+((Fintype.card κ:ℝ)+1)/(2*(Q':ℝ))) := by
  intro a hva
  obtain ⟨b,hb,herr⟩:=hc a hva
  let b':κ→ScalarCode Q' N':=fun j=>scalarEncode Q' N' (scalarDecode Q N (b j))
  refine ⟨b',?_,?_⟩
  · rw [CircuitMap.eval_then,hb,recodeCoordinates_eval]
  · have hbnd : ∀j,|scalarDecode Q N (b j)|≤(N':ℝ) := by
      intro j
      have hnorm : ‖decodeCoordinates Q N b‖≤R+ε := by
        have ht:=norm_le_norm_sub_add (decodeCoordinates Q N b) (F (decodeCoordinates Qi Ni a))
        rw [norm_sub_rev] at ht
        linarith [hF a hva]
      exact (PiLp.norm_apply_le (decodeCoordinates Q N b) j).trans (hnorm.trans hN')
    have hrecode : ‖decodeCoordinates Q N b-decodeCoordinates Q' N' b'‖≤
        ((Fintype.card κ:ℝ)+1)/(2*(Q':ℝ)) := by
      have hh:=euclidean_norm_of_coordinate_bounds (decodeCoordinates Q N b-decodeCoordinates Q' N' b')
        (show 0≤1/(2*(Q':ℝ)) by positivity) (fun j=>scalarEncode_error Q' N' hQ' _ (hbnd j))
      convert hh using 1 <;> ring
    have ht:=dist_triangle (F (decodeCoordinates Qi Ni a)) (decodeCoordinates Q N b) (decodeCoordinates Q' N' b')
    simp only [dist_eq_norm] at ht
    exact ht.trans (add_le_add herr hrecode)

variable {Q N : ℕ} {valid : (ζ→ScalarCode Q N)→Prop}
variable {F : EuclideanSpace ℝ (ζ⊕κ)→EuclideanSpace ℝ κ}
variable {c : CircuitMap (Fintype.card (ζ⊕κ)*Fintype.card (ScalarGrid Q N))
    (Fintype.card κ*Fintype.card (ScalarGrid Q N))} {δ : ℝ}

 def validGridUpdate (hc : GridApproximatesOn Q N Q N (fun a=>valid (fun i=>a (.inl i))) F c δ)
    (a : ζ→ScalarCode Q N) (ha : valid a) (u : κ→ScalarCode Q N) : κ→ScalarCode Q N :=
  Classical.choose (hc (Sum.elim a u) ha)

 theorem validGridUpdate_eval
    (hc : GridApproximatesOn Q N Q N (fun a=>valid (fun i=>a (.inl i))) F c δ)
    (a : ζ→ScalarCode Q N) (ha : valid a) (u : κ→ScalarCode Q N) :
    (carryInputCircuit c).eval (encodeCoordinateState Q N (Sum.elim a u))=
      encodeCoordinateState Q N (Sum.elim a (validGridUpdate hc a ha u)) := by
  apply sumGridCircuits_eval
  · rw [projectGridCoordinates_eval];rfl
  · exact (Classical.choose_spec (hc (Sum.elim a u) ha)).1

 def validGridIteration
    (hc : GridApproximatesOn Q N Q N (fun a=>valid (fun i=>a (.inl i))) F c δ)
    (a : ζ→ScalarCode Q N) (ha : valid a) (u : κ→ScalarCode Q N) : ℕ→κ→ScalarCode Q N
  | 0=>u
  | k+1=>validGridUpdate hc a ha (validGridIteration hc a ha u k)

 theorem validGridIteration_succ_left
    (hc : GridApproximatesOn Q N Q N (fun a=>valid (fun i=>a (.inl i))) F c δ)
    (a : ζ→ScalarCode Q N) (ha : valid a) (u : κ→ScalarCode Q N) (k : ℕ) :
    validGridIteration hc a ha (validGridUpdate hc a ha u) k=validGridIteration hc a ha u (k+1) := by
  induction k generalizing u with
  | zero=>rfl
  | succ k ih=>simp only [validGridIteration,ih]

 theorem validGridIteration_eval
    (hc : GridApproximatesOn Q N Q N (fun a=>valid (fun i=>a (.inl i))) F c δ)
    (a : ζ→ScalarCode Q N) (ha : valid a) (u : κ→ScalarCode Q N) (k : ℕ) :
    (pipeline (List.replicate k (carryInputCircuit c))).eval (encodeCoordinateState Q N (Sum.elim a u))=
      encodeCoordinateState Q N (Sum.elim a (validGridIteration hc a ha u k)) := by
  induction k generalizing u with
  | zero=>simp [pipeline,validGridIteration]
  | succ k ih=>
    rw [List.replicate_succ,pipeline,CircuitMap.eval_then,validGridUpdate_eval hc a ha,ih,validGridIteration_succ_left]

 theorem validGridIteration_step_error
    (hc : GridApproximatesOn Q N Q N (fun a=>valid (fun i=>a (.inl i))) F c δ)
    (a : ζ→ScalarCode Q N) (ha : valid a) (u : κ→ScalarCode Q N) (k : ℕ) :
    ‖decodeCoordinates Q N (validGridIteration hc a ha u (k+1))-
      F (decodeCoordinates Q N (Sum.elim a (validGridIteration hc a ha u k)))‖≤δ := by
  rw [norm_sub_rev]
  exact (Classical.choose_spec (hc (Sum.elim a (validGridIteration hc a ha u k)) ha)).2

#print axioms validGridIteration_eval
#print axioms validGridIteration_step_error
end ConditionalNonpolynomial.AnalyticLookup
