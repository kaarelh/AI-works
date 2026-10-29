import PhysicalShortGridNumerics
import PhysicalShortPicardPolynomialSize

noncomputable section
set_option maxHeartbeats 1000000
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
namespace ConditionalNonpolynomial.Analytic.PhysicalShort
open NeuralGeneralization.ConcreteModel ConditionalNonpolynomial.AnalyticLookup
namespace FiniteCanonicalDynamics
variable {d H : ℕ} {t : ℝ} {f : BooleanFunction d} {P : ControlledMarginPath d H t f}
variable {S : Finset (Cube d)} {states : ℕ→CanonicalProgramState d}

 theorem gridResidualTotal_le (M : FiniteCanonicalDynamics P S states) (hd : 1≤d) :
    M.gridResidualTotal≤2*canonicalNonlinearBudget P (canonicalSignPrecision P) := by
  unfold gridResidualTotal
  rw [Fin.sum_univ_eq_sum_range (fun j=>M.residualRange (canonicalSignPrecision P) j),Finset.sum_range_succ]
  have hz : M.residualRange (canonicalSignPrecision P) H=0 := by simp [residualRange]
  rw [hz,add_zero]
  exact M.residualRange_sum_le hd H le_rfl

 theorem selected_grid_numeric_resources (M : FiniteCanonicalDynamics P S states) (hd : 1≤d)
    {W η : ℝ} (h : M.PrimitiveResources W η) (hη : 0<η)
    (hI : (Fintype.card M.PicardInputIndex:ℝ)≤W)
    (hK : (Fintype.card M.PicardStateIndex:ℝ)≤W)
    (hΛ : canonicalNonlinearBudget P (canonicalSignPrecision P)≤W) :
    (M.gridStateRange:ℝ)≤W^6 ∧ ((M.gridStateRange+1:ℕ):ℝ)≤W^7 ∧
      (M.gridTolerance η)⁻¹≤W^98 ∧ (M.gridMesh η:ℝ)≤W^105 ∧
      (M.gridAffineRange:ℝ)≤W^42 := by
  have hW0 : 0≤W := by linarith [h.scale]
  have htwo : (2:ℝ)≤W^1 := by simpa using h.scale
  have hthree : (3:ℝ)≤W^2 := by nlinarith [h.scale]
  have hres : M.gridResidualTotal≤W^2 :=
    (M.gridResidualTotal_le hd).trans (resource_mul h.scale htwo (b:=1) (by simpa using hΛ)
      (canonicalNonlinearBudget_nonneg P _))
  have hR3 : 3+M.gridResidualTotal≤W^3 := resource_add_same h.scale hthree hres
  have hK1 : (Fintype.card M.PicardStateIndex:ℝ)+1≤W^2 := resource_add_one h.scale (a:=1) (by simpa using hK)
  have hprod := resource_mul h.scale hK1 hR3 (by linarith [M.gridResidualTotal_nonneg])
  have hN : (M.gridStateRange:ℝ)≤W^6 := (M.gridStateRange_upper).le.trans
    (resource_add_same h.scale hprod (hthree.trans (resource_pow_mono h.scale (by norm_num))))
  have hU : ((M.gridStateRange+1:ℕ):ℝ)≤W^7 := by exact_mod_cast resource_add_one h.scale hN
  have hW7 : W≤W^7 := by simpa only [pow_one] using resource_pow_mono h.scale (by norm_num : 1≤7)
  have hp := picard_grid_numeric_resources (h.scale.trans hW7) hη
    (hI.trans hW7) (hK.trans hW7) (h.dimension.trans hW7)
    (hN.trans (resource_pow_mono h.scale (by norm_num))) (h.tolerance.trans hW7)
  rw [←pow_mul,←pow_mul,←pow_mul] at hp
  exact ⟨hN,hU,hp.1,hp.2.1,hp.2.2⟩

 theorem selected_grid_primitive_resources (M : FiniteCanonicalDynamics P S states) (hd : 1≤d)
    {W η : ℝ} (h : M.PrimitiveResources W η) (hη : 0<η)
    (hI : (Fintype.card M.PicardInputIndex:ℝ)≤W)
    (hK : (Fintype.card M.PicardStateIndex:ℝ)≤W)
    (hΛ : canonicalNonlinearBudget P (canonicalSignPrecision P)≤W) :
    M.PrimitiveResources (W^105) (M.gridTolerance η) := by
  have hp := M.selected_grid_numeric_resources hd h hη hI hK hΛ
  have hW105 : W≤W^105 := by simpa only [pow_one] using resource_pow_mono h.scale (by norm_num : 1≤105)
  exact ⟨h.scale.trans hW105,h.dimension.trans hW105,h.anchors.trans hW105,h.entropy.trans hW105,
    h.amplification.trans hW105,h.floor.trans hW105,hp.2.2.1.trans (resource_pow_mono h.scale (by norm_num))⟩

 theorem selected_actualPicardGrid_polynomial_size (M : FiniteCanonicalDynamics P S states) (hd : 1≤d)
    (T : EuclideanSpace ℝ (Fin (d+1))→L[ℝ]CanonicalAmbient states H) (hT : ‖T‖≤1)
    {W η : ℝ} (h : M.PrimitiveResources W η) (hη : 0<η) (hη1 : η≤1)
    (hI : (Fintype.card M.PicardInputIndex:ℝ)≤W)
    (hK : (Fintype.card M.PicardStateIndex:ℝ)≤W) (hH : (H+1:ℕ)≤W)
    (hΛ : canonicalNonlinearBudget P (canonicalSignPrecision P)≤W) :
    ((M.actualPicardGrid hd T (M.gridTolerance η) (M.gridTolerance_pos hη)
      (M.gridTolerance_one hη hη1) (M.gridMesh η) M.gridStateRange (M.gridStateRange+1)
      M.gridAffineRange (M.gridTolerance η)).size:ℝ)≤W^(105*canonicalPicardResourceExponent) := by
  have hp := M.selected_grid_numeric_resources hd h hη hI hK hΛ
  have hs := M.selected_grid_primitive_resources hd h hη hI hK hΛ
  have hW105 : W≤W^105 := by simpa only [pow_one] using resource_pow_mono h.scale (by norm_num : 1≤105)
  have hh := M.actualPicardGrid_polynomial_size hd T hT hs (M.gridTolerance_pos hη)
    (M.gridTolerance_one hη hη1) (M.gridMesh η) M.gridStateRange (M.gridStateRange+1) M.gridAffineRange
    hp.2.2.2.1 (hp.1.trans (resource_pow_mono h.scale (by norm_num)))
    (hp.2.1.trans (resource_pow_mono h.scale (by norm_num)))
    (hp.2.2.2.2.trans (resource_pow_mono h.scale (by norm_num)))
    (M.gridTolerance_pos hη) hs.tolerance (hI.trans hW105) (hK.trans hW105) (hH.trans hW105)
  simpa only [←pow_mul] using hh

#print axioms selected_grid_numeric_resources
#print axioms selected_actualPicardGrid_polynomial_size
end FiniteCanonicalDynamics
end ConditionalNonpolynomial.Analytic.PhysicalShort
