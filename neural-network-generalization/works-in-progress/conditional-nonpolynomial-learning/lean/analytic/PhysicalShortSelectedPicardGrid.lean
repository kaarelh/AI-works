import PhysicalShortGridNumerics

noncomputable section
namespace ConditionalNonpolynomial.Analytic.PhysicalShort
open NeuralGeneralization.ConcreteModel ConditionalNonpolynomial.AnalyticLookup
namespace FiniteCanonicalDynamics
variable {d H : ℕ} {t : ℝ} {f : BooleanFunction d} {P : ControlledMarginPath d H t f}
variable {S : Finset (Cube d)} {states : ℕ→CanonicalProgramState d}

 def selectedPicardGrid (M : FiniteCanonicalDynamics P S states) (hd : 1≤d)
    (T : EuclideanSpace ℝ (Fin (d+1))→L[ℝ]CanonicalAmbient states H)
    (η : ℝ) (hη : 0<η) (hη1 : η≤1) :=
  M.actualPicardGrid hd T (M.gridTolerance η) (M.gridTolerance_pos hη) (M.gridTolerance_one hη hη1)
    (M.gridMesh η) M.gridStateRange (M.gridStateRange+1) M.gridAffineRange (M.gridTolerance η)

 theorem selectedPicardGrid_approximates (M : FiniteCanonicalDynamics P S states) (hd : 1≤d)
    (T : EuclideanSpace ℝ (Fin (d+1))→L[ℝ]CanonicalAmbient states H) (hT : ‖T‖≤1)
    (η : ℝ) (hη : 0<η) (hη1 : η≤1) :
    GridApproximatesOn (M.gridMesh η) M.gridStateRange (M.gridMesh η) M.gridStateRange
      (fun a:M.PicardInputIndex→ScalarCode (M.gridMesh η) M.gridStateRange=>
        ‖decodeCoordinates (M.gridMesh η) M.gridStateRange (fun i=>a (.inl i))‖≤3)
      (M.picardCoordinateUpdate T) (M.selectedPicardGrid hd T η hη hη1) (η/2) := by
  have hh:=M.actualPicardGrid_approximates hd T hT (M.gridTolerance η) (M.gridTolerance_pos hη)
    (M.gridTolerance_one hη hη1) (M.gridMesh η) M.gridStateRange (M.gridStateRange+1)
    M.gridAffineRange (M.gridMesh_pos η) (le_refl _) (M.gridTolerance η) (M.gridTolerance_pos hη)
    (M.gridTolerance_one hη hη1) 3 (le_refl _) (M.grid_selected_residual_range hη hη1)
    (M.grid_selected_output_range hη hη1)
  intro a ha
  obtain ⟨b,hb,he⟩:=hh a ha
  exact ⟨b,hb,he.trans (M.grid_selected_error hη)⟩

 theorem selectedPicardGrid_depth (M : FiniteCanonicalDynamics P S states) (hd : 1≤d)
    (T : EuclideanSpace ℝ (Fin (d+1))→L[ℝ]CanonicalAmbient states H)
    (η : ℝ) (hη : 0<η) (hη1 : η≤1) :
    (M.selectedPicardGrid hd T η hη hη1).depth≤90 :=
  M.actualPicardGrid_depth hd T _ _ _ _ _ _ _ _

#print axioms selectedPicardGrid_approximates
end FiniteCanonicalDynamics
end ConditionalNonpolynomial.Analytic.PhysicalShort
