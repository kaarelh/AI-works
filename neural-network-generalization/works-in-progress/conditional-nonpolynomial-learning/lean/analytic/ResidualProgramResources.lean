import ArithmeticProgramResources
import ResidualArithmeticProgram

noncomputable section
namespace ConditionalNonpolynomial.AnalyticLookup
open ConditionalNonpolynomial.Analytic
namespace ArithmeticProgram

 theorem maxDimension_append_le {d m o M : ℕ} (P : ArithmeticProgram d m) (R : ArithmeticProgram m o)
    (hP : P.maxDimension≤M) (hR : R.maxDimension≤M) : (P.append R).maxDimension≤M := by
  induction P with
  | nil _=>exact hR
  | cons A T ih=>
    exact max_le (max_le_iff.mp hP).1 (ih R (max_le_iff.mp hP).2 hR)

 theorem maxDimension_carry {d o : ℕ} (P : ArithmeticProgram d o) (c : ℕ) :
    (P.carry c).maxDimension≤c+P.maxDimension := by
  induction P with
  | nil _=>exact le_refl _
  | @cons di mi oi A T ih=>
    change max (c+di) (T.carry c).maxDimension≤c+max di T.maxDimension
    exact max_le (Nat.add_le_add_left (le_max_left _ _) c)
      (ih.trans (Nat.add_le_add_left (le_max_right _ _) c))

 theorem maxDimension_fromRun (X : ℕ→Type) [∀j,Fintype (X j)]
    (A : ∀j,ArithmeticLayer (X j) (X (j+1))) (h M : ℕ)
    (hX : ∀j≤h,Fintype.card (X j)≤M) : (fromRun X A h).maxDimension≤M := by
  induction h with
  | zero=>exact hX 0 le_rfl
  | succ h ih=>
    apply maxDimension_append_le
    · exact ih (fun j hj=>hX j (by omega))
    · exact max_le (hX h (by omega)) (hX (h+1) le_rfl)

end ArithmeticProgram

 theorem canonicalProgramBlock_dimension {d n m : ℕ} (w : Fin n→Fin d→ℝ) (a : Fin n→ℝ)
    (A : Fin m→Fin n→ℝ) (b : Fin n→ℝ) :
    (canonicalProgramBlock w a A b).maxDimension≤d+2*n+2*m+2 := by
  apply ArithmeticProgram.maxDimension_fromRun
  intro j hj
  interval_cases j <;> simp [canonicalCoordinates] <;> omega

 theorem radialProgramBlock_dimension (d : ℕ) (s : ℝ) :
    (radialProgramBlock d s).maxDimension≤2*d+1 := by
  apply ArithmeticProgram.maxDimension_fromRun
  intro j hj
  interval_cases j <;> simp [radialCoordinates] <;> omega

 theorem residualArithmeticProgram_dimension {D d n m O : ℕ}
    (pre : Fin (Fintype.card (Fin d))→Fin D→ℝ) (s : ℝ)
    (w : Fin n→Fin d→ℝ) (a : Fin n→ℝ) (A : Fin m→Fin n→ℝ) (b : Fin n→ℝ)
    (post : Fin O→Fin (Fintype.card (Fin d)+Fintype.card (Fin m⊕Unit))→ℝ) :
    (residualArithmeticProgram pre s w a A b post).maxDimension≤D+O+4*d+2*n+2*m+4 := by
  unfold residualArithmeticProgram
  apply ArithmeticProgram.maxDimension_append_le
  · simp [ArithmeticProgram.single,ArithmeticProgram.maxDimension,radialCoordinates,canonicalCoordinates]
    omega
  apply ArithmeticProgram.maxDimension_append_le
  · exact (radialProgramBlock_dimension d s).trans (by omega)
  apply ArithmeticProgram.maxDimension_append_le
  · simp [ArithmeticProgram.single,ArithmeticProgram.maxDimension,radialCoordinates,canonicalCoordinates]
    omega
  apply ArithmeticProgram.maxDimension_append_le
  · have hh := ((canonicalProgramBlock w a A b).maxDimension_carry (Fintype.card (Fin d))).trans
      (Nat.add_le_add_left (canonicalProgramBlock_dimension w a A b) (Fintype.card (Fin d)))
    simp only [Fintype.card_fin] at hh
    exact hh.trans (by omega)
  · simp [ArithmeticProgram.single,ArithmeticProgram.maxDimension,radialCoordinates,canonicalCoordinates]
    omega

#print axioms residualArithmeticProgram_dimension
end ConditionalNonpolynomial.AnalyticLookup
