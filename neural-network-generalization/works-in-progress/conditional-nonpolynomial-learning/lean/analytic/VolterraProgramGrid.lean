import VolterraGridSystem

noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
namespace ConditionalNonpolynomial.AnalyticLookup
open ConditionalNonpolynomial.Analytic
namespace VolterraGridSystem
variable {ζ ι : Type} [Fintype ζ] [Fintype ι] {H : ℕ}

 def programGrid (M : VolterraGridSystem ζ ι H)
    (P : Fin (H+1)→ArithmeticProgram (Fintype.card ι) (Fintype.card ι))
    (B : Fin (H+1)→ℕ) (η : ℝ) (j : Fin (H+1)) :=
  uniformProgramGrid (P j) (B j) (M.stateRange+1) (M.mesh η) M.stateRange (M.tolerance η)

 def programStep (M : VolterraGridSystem ζ ι H)
    (P : Fin (H+1)→ArithmeticProgram (Fintype.card ι) (Fintype.card ι))
    (B : Fin (H+1)→ℕ) (η : ℝ) :=
  parallelPicardCircuit (M.mesh η) 1 M.stateRange M.affineRange (M.programGrid P B η) M.coefficients (fun _=>0)

 def residualGridError (M : VolterraGridSystem ζ ι H) (η : ℝ) : ℝ :=
  M.tolerance η+((Fintype.card ι:ℝ)+1)*M.tolerance η+((Fintype.card ι:ℝ)+1)/(2*(M.mesh η:ℝ))

 def preError (M : VolterraGridSystem ζ ι H) (η : ℝ) : ℝ :=
  (((Fintype.card M.StateIndex:ℝ)+1)*(Fintype.card M.InputIndex:ℝ))*
    (((Fintype.card M.InputIndex:ℝ)+1)*(((Fintype.card M.StateIndex:ℝ)+1)*M.residualGridError η))+
  (((Fintype.card M.StateIndex:ℝ)+1)*(((Fintype.card M.InputIndex:ℝ)*((M.stateRange:ℝ)+1)+1)/(2*(M.mesh η:ℝ))))

 theorem programGrid_approximates (M : VolterraGridSystem ζ ι H)
    (P : Fin (H+1)→ArithmeticProgram (Fintype.card ι) (Fintype.card ι))
    (B : Fin (H+1)→ℕ) (hB : ∀j,(P j).bounded (B j)) {η : ℝ} (hη : 0<η) (hη1 : η≤1)
    (happrox : ∀j x,‖M.residual j x-(P j).realMap x‖≤M.tolerance η) (j : Fin (H+1)) :
    GridApproximates (M.mesh η) M.stateRange (M.mesh η) M.stateRange
      (M.residual j) (M.programGrid P B η j) (M.residualGridError η) :=
  uniformProgramGrid_approximates (P j) (B j) (M.stateRange+1) (M.mesh η) M.stateRange (hB j)
    (M.mesh_pos η) (le_refl _) (M.residual j) (M.tolerance_pos hη) (M.tolerance_one hη hη1)
    (fun x _=>happrox j x) (fun a=>M.residual_range j _) (M.selected_residual_range hη hη1 j)

 theorem selected_step_error (M : VolterraGridSystem ζ ι H) {η : ℝ} (hη : 0<η) :
    M.preError η+((Fintype.card M.StateIndex:ℝ)+1)/(2*(M.mesh η:ℝ))≤η/2 :=
  picard_selected_error _ _ _ _ hη

 theorem selected_step_range (M : VolterraGridSystem ζ ι H) {η : ℝ} (hη : 0<η) (hη1 : η≤1) :
    ((Fintype.card M.StateIndex:ℝ)+1)*(3+M.totalBound)+M.preError η≤M.stateRange := by
  have he:=M.selected_step_error hη
  have hlow:=M.stateRange_lower
  have hn:0≤((Fintype.card M.StateIndex:ℝ)+1)/(2*(M.mesh η:ℝ)):=by positivity
  linarith

 theorem programStep_approximates (M : VolterraGridSystem ζ ι H)
    (P : Fin (H+1)→ArithmeticProgram (Fintype.card ι) (Fintype.card ι))
    (B : Fin (H+1)→ℕ) (hB : ∀j,(P j).bounded (B j)) {η : ℝ} (hη : 0<η) (hη1 : η≤1)
    (happrox : ∀j x,‖M.residual j x-(P j).realMap x‖≤M.tolerance η) :
    GridApproximatesOn (M.mesh η) M.stateRange (M.mesh η) M.stateRange
      (fun a:M.InputIndex→ScalarCode (M.mesh η) M.stateRange=>
        ‖decodeCoordinates (M.mesh η) M.stateRange (fun i=>a (.inl i))‖≤3)
      M.update (M.programStep P B η) (η/2) := by
  have herr:0≤M.residualGridError η:=by
    have hτ:=M.tolerance_pos hη
    unfold residualGridError
    positivity
  have hh:=parallelPicardCircuit_approximatesOn (M.mesh η) 1 M.stateRange M.affineRange (M.mesh_pos η)
    M.residual (M.programGrid P B η) M.coefficients (fun _=>0)
    (by simpa only [Nat.cast_one] using M.coefficients_bound) (fun _=>by norm_num) (le_refl _) herr
    (M.programGrid_approximates P B hB hη hη1 happrox)
    (fun a:ζ→ScalarCode (M.mesh η) M.stateRange=>‖decodeCoordinates (M.mesh η) M.stateRange a‖≤3)
    (R:=((Fintype.card M.StateIndex:ℝ)+1)*(3+M.totalBound))
    (by
      intro a ha
      have hh:=M.update_range (decodeCoordinates (M.mesh η) M.stateRange (fun i=>a (.inl i)))
        (fun j=>decodeCoordinates (M.mesh η) M.stateRange (fun i=>a (.inr (j,i)))) ha
      exact hh)
    (by simpa only [Nat.cast_one,mul_one,preError] using M.selected_step_range hη hη1)
  intro a ha
  obtain ⟨b,hb,he⟩:=hh a ha
  refine ⟨b,hb,he.trans ?_⟩
  simpa only [Nat.cast_one,mul_one,preError] using M.selected_step_error hη

 theorem programStep_depth (M : VolterraGridSystem ζ ι H)
    (P : Fin (H+1)→ArithmeticProgram (Fintype.card ι) (Fintype.card ι))
    (B : Fin (H+1)→ℕ) (η : ℝ) (hP : ∀j,(P j).length≤14) :
    (M.programStep P B η).depth≤90 := by
  apply parallelPicardCircuit_depth _ _ _ _ _ _ _ 80
  intro j
  exact (uniformProgramGrid_depth (P j) (B j) (M.stateRange+1) (M.mesh η) M.stateRange (M.tolerance η)).trans
    (by have hh:=hP j;omega)

#print axioms programStep_approximates
#print axioms programStep_depth
end VolterraGridSystem
end ConditionalNonpolynomial.AnalyticLookup
