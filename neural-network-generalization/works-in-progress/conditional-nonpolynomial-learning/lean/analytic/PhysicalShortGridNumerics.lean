import PicardGridBudgets
import PhysicalShortActualPicardGrid

noncomputable section
open scoped BigOperators
namespace ConditionalNonpolynomial.Analytic.PhysicalShort
open NeuralGeneralization.ConcreteModel ConditionalNonpolynomial.AnalyticLookup
namespace FiniteCanonicalDynamics
variable {d H : ℕ} {t : ℝ} {f : BooleanFunction d} {P : ControlledMarginPath d H t f}
variable {S : Finset (Cube d)} {states : ℕ→CanonicalProgramState d}

 theorem gridResidualRange_nonneg (M : FiniteCanonicalDynamics P S states) (j : Fin (H+1)) :
    0≤M.residualRange (canonicalSignPrecision P) j := by
  unfold residualRange
  split_ifs
  · exact mul_nonneg (by positivity) (canonicalRadius_pos P (canonicalSignPrecision_pos P) j).le
  · exact le_refl _

 def gridResidualTotal (M : FiniteCanonicalDynamics P S states) : ℝ :=
  ∑j:Fin (H+1),M.residualRange (canonicalSignPrecision P) j

 theorem gridResidualTotal_nonneg (M : FiniteCanonicalDynamics P S states) : 0≤M.gridResidualTotal :=
  Finset.sum_nonneg fun j _=>M.gridResidualRange_nonneg j

 def gridStateRange (M : FiniteCanonicalDynamics P S states) : ℕ :=
  ⌈((Fintype.card M.PicardStateIndex:ℝ)+1)*(3+M.gridResidualTotal)⌉₊+2

 theorem gridStateRange_two (M : FiniteCanonicalDynamics P S states) : 2≤M.gridStateRange := by
  unfold gridStateRange
  omega

 theorem gridStateRange_lower (M : FiniteCanonicalDynamics P S states) :
    ((Fintype.card M.PicardStateIndex:ℝ)+1)*(3+M.gridResidualTotal)+2≤(M.gridStateRange:ℝ) := by
  have hh:=Nat.le_ceil (((Fintype.card M.PicardStateIndex:ℝ)+1)*(3+M.gridResidualTotal))
  unfold gridStateRange
  push_cast
  linarith

 theorem gridStateRange_upper (M : FiniteCanonicalDynamics P S states) :
    (M.gridStateRange:ℝ)<((Fintype.card M.PicardStateIndex:ℝ)+1)*(3+M.gridResidualTotal)+3 := by
  have hr:=M.gridResidualTotal_nonneg
  have hh:=Nat.ceil_lt_add_one (show 0≤((Fintype.card M.PicardStateIndex:ℝ)+1)*(3+M.gridResidualTotal) by positivity)
  unfold gridStateRange
  push_cast
  linarith

 def gridTolerance (M : FiniteCanonicalDynamics P S states) (η : ℝ) :=
  picardInnerTolerance (Fintype.card M.PicardInputIndex) (Fintype.card M.PicardStateIndex)
    (canonicalAmbientDimension states H) η
 def gridMesh (M : FiniteCanonicalDynamics P S states) (η : ℝ) :=
  picardOuterMesh (Fintype.card M.PicardInputIndex) (Fintype.card M.PicardStateIndex)
    (canonicalAmbientDimension states H) M.gridStateRange η
 def gridAffineRange (M : FiniteCanonicalDynamics P S states) :=
  1+Fintype.card M.PicardInputIndex*2*(M.gridStateRange+1)

 theorem gridTolerance_pos (M : FiniteCanonicalDynamics P S states) {η : ℝ} (hη : 0<η) :
    0<M.gridTolerance η := picardInnerTolerance_pos _ _ _ hη
 theorem gridTolerance_one (M : FiniteCanonicalDynamics P S states) {η : ℝ} (hη : 0<η) (hη1 : η≤1) :
    M.gridTolerance η≤1 := (picardInnerTolerance_le _ _ _ hη.le).trans hη1
 theorem gridMesh_pos (M : FiniteCanonicalDynamics P S states) (η : ℝ) : 0<M.gridMesh η :=
  picardOuterMesh_pos _ _ _ _ _

 theorem grid_selected_error (M : FiniteCanonicalDynamics P S states) {η : ℝ} (hη : 0<η) :
    M.picardGridError (M.gridMesh η) M.gridStateRange (M.gridTolerance η) (M.gridTolerance η)≤η/2 :=
  picard_selected_error _ _ _ _ hη

 theorem grid_selected_residual_range (M : FiniteCanonicalDynamics P S states)
    {η : ℝ} (hη : 0<η) (hη1 : η≤1) (j : Fin (H+1)) :
    M.residualRange (canonicalSignPrecision P) j+
      (M.gridTolerance η+((canonicalAmbientDimension states H:ℝ)+1)*M.gridTolerance η)≤M.gridStateRange := by
  have ht:=(picardInnerTotal_le (Fintype.card M.PicardInputIndex) (Fintype.card M.PicardStateIndex)
    (canonicalAmbientDimension states H) hη.le).trans hη1
  have hj : M.residualRange (canonicalSignPrecision P) j≤M.gridResidualTotal :=
    Finset.single_le_sum (fun i _=>M.gridResidualRange_nonneg i) (Finset.mem_univ j)
  have hlow:=M.gridStateRange_lower
  have hr:=M.gridResidualTotal_nonneg
  have hk:0≤(Fintype.card M.PicardStateIndex:ℝ):=Nat.cast_nonneg _
  have hmul:=mul_nonneg hk (show 0≤3+M.gridResidualTotal by linarith)
  change _+(M.gridTolerance η+_ *M.gridTolerance η)≤_
  change M.gridTolerance η+((canonicalAmbientDimension states H:ℝ)+1)*M.gridTolerance η≤1 at ht
  nlinarith

 theorem grid_selected_output_range (M : FiniteCanonicalDynamics P S states)
    {η : ℝ} (hη : 0<η) (hη1 : η≤1) :
    ((Fintype.card M.PicardStateIndex:ℝ)+1)*(3+M.gridResidualTotal)+
      M.picardPreError (M.gridMesh η) M.gridStateRange (M.gridTolerance η) (M.gridTolerance η)≤M.gridStateRange := by
  have he:=M.grid_selected_error hη
  have hlow:=M.gridStateRange_lower
  have hn:0≤((Fintype.card M.PicardStateIndex:ℝ)+1)/(2*(M.gridMesh η:ℝ)):=by positivity
  unfold picardGridError at he
  linarith

#print axioms grid_selected_error
#print axioms grid_selected_output_range
end FiniteCanonicalDynamics
end ConditionalNonpolynomial.Analytic.PhysicalShort
