import SelectedCanonicalPicardGrid
import AffineGridInitialization
import CanonicalCoordinateEndpoints

noncomputable section
set_option backward.isDefEq.respectTransparency false
namespace ConditionalNonpolynomial.AnalyticLookup
 theorem picard_weight_rounding {A K D N : ℕ} {η c : ℝ} (hη : 0<η)
    (hc : c≤(picardRoundingWeight A K D N:ℝ)) :
    c/(2*(picardOuterMesh A K D N η:ℝ))≤η/4 := by
  have hQ:(0:ℝ)<picardOuterMesh A K D N η:=Nat.cast_pos.mpr (picardOuterMesh_pos _ _ _ _ _)
  apply (div_le_iff₀ (by positivity : 0<2*(picardOuterMesh A K D N η:ℝ))).mpr
  have hh:=picardOuterMesh_product A K D N hη
  linarith

 theorem picard_weight_base (A K D N z : ℕ) (hz : z≤A) :
    (K+1)*(z*(N+1)+2)≤picardRoundingWeight A K D N := by
  have hh:=Nat.mul_le_mul_left (K+1) (Nat.add_le_add_right (Nat.mul_le_mul_right (N+1) hz) 2)
  unfold picardRoundingWeight
  omega
end ConditionalNonpolynomial.AnalyticLookup

namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.ConcreteModel ConditionalNonpolynomial.AnalyticLookup
namespace FiniteCanonicalDynamics
variable {d H : ℕ} {f : BooleanFunction d} {P : ControlledMarginPath d H 1 f}
variable {S : Finset (Cube d)} {states : ℕ→CanonicalProgramState d}

 theorem grid_input_card (M : FiniteCanonicalDynamics P S states) :
    Fintype.card (Fin (d+1))≤Fintype.card M.PicardInputIndex := by
  simp only [PicardInputIndex,Fintype.card_sum]
  omega

 theorem grid_initial_error (M : FiniteCanonicalDynamics P S states) {η : ℝ} (hη : 0<η) :
    baseGridError (Fin (d+1)) (CanonicalAmbientIndex states H) (Fin (H+1))
      (M.gridMesh η) M.gridStateRange≤η/4 := by
  have hb:=picard_weight_base (Fintype.card M.PicardInputIndex) (Fintype.card M.PicardStateIndex)
    (canonicalAmbientDimension states H) M.gridStateRange (Fintype.card (Fin (d+1))) M.grid_input_card
  have hbr : (((Fintype.card M.PicardStateIndex+1)*(Fintype.card (Fin (d+1))*(M.gridStateRange+1)+2):ℕ):ℝ)≤(picardRoundingWeight (Fintype.card M.PicardInputIndex) (Fintype.card M.PicardStateIndex) (canonicalAmbientDimension states H) M.gridStateRange:ℝ) := by exact_mod_cast hb
  have hh:=picard_weight_rounding hη hbr
  convert hh using 1
  unfold baseGridError gridMesh
  push_cast
  ring

 theorem grid_input_error (M : FiniteCanonicalDynamics P S states) {η : ℝ} (hη : 0<η) :
    ((d:ℝ)+2)/(2*(M.gridMesh η:ℝ))≤η/4 := by
  have hcard:=M.grid_input_card
  have hb:=picard_weight_base (Fintype.card M.PicardInputIndex) (Fintype.card M.PicardStateIndex)
    (canonicalAmbientDimension states H) M.gridStateRange (d+1) (by simpa using hcard)
  have hnum : d+2≤(Fintype.card M.PicardStateIndex+1)*((d+1)*(M.gridStateRange+1)+2) := by
    have h1 : d+1≤(d+1)*(M.gridStateRange+1):=Nat.le_mul_of_pos_right _ (by omega)
    have h2 : (d+1)*(M.gridStateRange+1)+2≤(Fintype.card M.PicardStateIndex+1)*((d+1)*(M.gridStateRange+1)+2) :=
      Nat.le_mul_of_pos_left _ (by omega)
    omega
  exact picard_weight_rounding hη (by exact_mod_cast hnum.trans hb)

 theorem grid_initial_range (M : FiniteCanonicalDynamics P S states) {η : ℝ} (hη : 0<η) (hη1 : η≤1) :
    ((Fintype.card M.PicardStateIndex:ℝ)+1)*3+
      ((Fintype.card M.PicardStateIndex:ℝ)+1)*(((Fintype.card (Fin (d+1)):ℝ)*((M.gridStateRange:ℝ)+1)+1)/(2*(M.gridMesh η:ℝ)))≤M.gridStateRange := by
  have he:=M.grid_initial_error hη
  have hlow:=M.gridStateRange_lower
  have hr:=M.gridResidualTotal_nonneg
  have hk:0≤(Fintype.card M.PicardStateIndex:ℝ):=Nat.cast_nonneg _
  have hn:0≤((Fintype.card M.PicardStateIndex:ℝ)+1)/(2*(M.gridMesh η:ℝ)):=by positivity
  unfold baseGridError at he
  nlinarith [mul_nonneg hk hr]

 theorem grid_initial_affine_range (M : FiniteCanonicalDynamics P S states) :
    1+Fintype.card (Fin (d+1))*2*(M.gridStateRange+1)≤M.gridAffineRange := by
  exact Nat.add_le_add_left (Nat.mul_le_mul_right _ (Nat.mul_le_mul_right 2 M.grid_input_card)) 1

 theorem initialCoordinateMap_eq_base (M : FiniteCanonicalDynamics P S states)
    (T : EuclideanSpace ℝ (Fin (d+1))→L[ℝ]CanonicalAmbient states H) :
    M.initialCoordinateMap T=baseVectorMap (M.baseCoordinates T) := by
  exact baseVectorCoefficients_eval (M.baseCoordinates T)

#print axioms grid_input_error
#print axioms grid_initial_range
end FiniteCanonicalDynamics
end ConditionalNonpolynomial.Analytic
