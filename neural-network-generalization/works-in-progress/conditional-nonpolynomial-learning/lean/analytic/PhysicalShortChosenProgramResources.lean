import PhysicalShortActualPicardResources
import PhysicalShortResidualResources
import UniformProgramGridResources

noncomputable section
set_option maxHeartbeats 1000000
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
namespace ConditionalNonpolynomial.Analytic.PhysicalShort
open NeuralGeneralization.ConcreteModel ConditionalNonpolynomial.AnalyticLookup
namespace FiniteCanonicalDynamics
variable {d H : ℕ} {t : ℝ} {f : BooleanFunction d} {P : ControlledMarginPath d H t f}
variable {S : Finset (Cube d)} {states : ℕ→CanonicalProgramState d}

lemma primitive_residual_dimension_budget (M : FiniteCanonicalDynamics P S states) {W τ : ℝ}
    (h : M.PrimitiveResources W τ) (hτ : 0<τ) (j : Fin H) :
    ((2*canonicalAmbientDimension states H+4*M.layerInputDimension j+
      2*M.quadratureCount j τ+2*M.layerRank j+4:ℕ):ℝ)≤W^656 := by
  have hW0 : 0≤W := by linarith [h.scale]
  obtain ⟨hi,hr,hZ,hs,hfloor,hgain⟩ := M.primitive_layer_bounds h j
  have hn := M.primitive_quadrature_count_bound h hτ j
  have htwo : (2:ℝ)≤W^1 := by simpa using h.scale
  have hfour : (4:ℝ)≤W^2 := by nlinarith [h.scale]
  have hterm1 : 2*(canonicalAmbientDimension states H:ℝ)≤W^2 :=
    resource_mul h.scale htwo (b:=1) (by simpa using h.dimension) (Nat.cast_nonneg _)
  have hterm2 : 4*(M.layerInputDimension j:ℝ)≤W^3 :=
    resource_mul h.scale hfour (b:=1) (by simpa using hi) (Nat.cast_nonneg _)
  have hterm3 : 2*(M.quadratureCount j τ:ℝ)≤W^649 :=
    resource_mul h.scale htwo hn (Nat.cast_nonneg _)
  have hterm4 : 2*(M.layerRank j:ℝ)≤W^3 :=
    resource_mul h.scale htwo hr (Nat.cast_nonneg _)
  have hsum1 := resource_add_same h.scale
    (hterm1.trans (resource_pow_mono h.scale (show 2≤649 by norm_num)))
    (hterm2.trans (resource_pow_mono h.scale (show 3≤649 by norm_num)))
  have hsum2 := resource_add_same h.scale hsum1
    (hterm3.trans (resource_pow_mono h.scale (show 649≤650 by norm_num)))
  have hsum3 := resource_add_same h.scale hsum2
    (hterm4.trans (resource_pow_mono h.scale (show 3≤651 by norm_num)))
  have hsum4 := resource_add_same h.scale hsum3
    (hfour.trans (resource_pow_mono h.scale (show 2≤652 by norm_num)))
  push_cast
  exact hsum4.trans (resource_pow_mono h.scale (by norm_num))

lemma allResidual_primitive_bounds (M : FiniteCanonicalDynamics P S states) {W τ : ℝ}
    (h : M.PrimitiveResources W τ) (hτ : 0<τ) (j : Fin (H+1)) :
    (M.allResidualCoefficientBudget j:ℝ)≤W^656 ∧ (M.allResidualDimensionBudget j τ:ℝ)≤W^656 := by
  by_cases hj:j.val<H
  · simp only [allResidualCoefficientBudget,allResidualDimensionBudget,dif_pos hj]
    exact ⟨(M.primitive_residual_coefficient_bound h ⟨j,hj⟩).trans
      (resource_pow_mono h.scale (by norm_num)),M.primitive_residual_dimension_budget h hτ ⟨j,hj⟩⟩
  · simp only [allResidualCoefficientBudget,allResidualDimensionBudget,dif_neg hj,Nat.cast_one]
    exact ⟨one_le_pow₀ (by linarith [h.scale]),h.dimension.trans
      (by simpa only [pow_one] using resource_pow_mono h.scale (by norm_num : 1≤656))⟩

 theorem chosenResidualProgram_resources (M : FiniteCanonicalDynamics P S states) (hd : 1≤d)
    {W τ : ℝ} (h : M.PrimitiveResources W τ) (hτ : 0<τ) (hτ1 : τ≤1) (j : Fin (H+1)) :
    ((M.chosenResidualProgram hd τ hτ hτ1 j).maxDimension:ℝ)≤W^656 ∧
      (M.allResidualCoefficientBudget j:ℝ)≤W^656 := by
  have hh := M.allResidual_primitive_bounds h hτ j
  have hdim : ((M.chosenResidualProgram hd τ hτ hτ1 j).maxDimension:ℝ)≤M.allResidualDimensionBudget j τ := by
    exact_mod_cast (M.chosenResidualProgram_spec hd τ hτ hτ1 j).2.2.1
  exact ⟨hdim.trans hh.2,hh.1⟩

 theorem residualGridSizeBudget_polynomial (M : FiniteCanonicalDynamics P S states) (hd : 1≤d)
    {W τ ε : ℝ} (h : M.PrimitiveResources W τ) (hτ : 0<τ) (hτ1 : τ≤1)
    (Q N U : ℕ) (hQ : (Q:ℝ)≤W) (hN : (N:ℝ)≤W) (hU : (U:ℝ)≤W)
    (hε : 0<ε) (hεinv : ε⁻¹≤W) (j : Fin (H+1)) :
    (M.residualGridSizeBudget hd τ hτ hτ1 Q N U ε j:ℝ)≤W^(656*uniformProgramResourceExponent 14) := by
  have hWbig : W≤W^656 := by simpa only [pow_one] using resource_pow_mono h.scale (by norm_num : 1≤656)
  have hdim := M.chosenResidualProgram_resources hd h hτ hτ1 j
  have hh := uniformProgramGrid_budget_resource (M.chosenResidualProgram hd τ hτ hτ1 j)
    (h.scale.trans hWbig) (M.allResidualCoefficientBudget j) U Q N 14 hε
    (M.chosenResidualProgram_spec hd τ hτ hτ1 j).1
    (h.dimension.trans hWbig) (h.dimension.trans hWbig) hdim.1 hdim.2
    (hU.trans hWbig) (hQ.trans hWbig) (hN.trans hWbig) (hεinv.trans hWbig)
  simpa only [residualGridSizeBudget,←pow_mul] using hh

#print axioms chosenResidualProgram_resources
#print axioms residualGridSizeBudget_polynomial
end FiniteCanonicalDynamics
end ConditionalNonpolynomial.Analytic.PhysicalShort
