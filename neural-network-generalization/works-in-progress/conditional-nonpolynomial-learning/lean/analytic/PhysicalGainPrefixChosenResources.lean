import PhysicalGainPrefixResidualFamily
import PhysicalGainPrefixPrimitiveResources
import UniformProgramGridResources

noncomputable section
set_option maxHeartbeats 1000000
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
namespace ConditionalNonpolynomial.Analytic.PhysicalLong
open NeuralGeneralization.ConcreteModel ConditionalNonpolynomial.AnalyticLookup PhysicalShort
namespace GainPrefixDynamics
variable {d H J : ℕ} {t : ℝ} {f : BooleanFunction d} {P : ControlledMarginPath d H t f}
variable {S : Finset (Cube d)} {states : ℕ→CanonicalProgramState d}

lemma primitive_residual_dimension_budget (M : GainPrefixDynamics P S states J) {W τ : ℝ}
    (h : M.PrimitiveResources W τ) (hτ : 0<τ) (j : Fin J) :
    ((2*canonicalAmbientDimension states J+4*M.layerInputDimension j+
      2*M.quadratureCount j τ+2*M.layerRank j+4:ℕ):ℝ)≤W^984 := by
  have hW0 : 0≤W := by linarith [h.scale]
  obtain ⟨hi,hr,hZ⟩ := M.primitive_layer_bounds h j
  have hn := M.primitive_quadrature_count_bound h hτ j
  have htwo : (2:ℝ)≤W^1 := by simpa using h.scale
  have hfour : (4:ℝ)≤W^2 := by nlinarith [h.scale]
  have hterm1 : 2*(canonicalAmbientDimension states J:ℝ)≤W^2 :=
    resource_mul h.scale htwo (b:=1) (by simpa using h.dimension) (Nat.cast_nonneg _)
  have hterm2 : 4*(M.layerInputDimension j:ℝ)≤W^3 :=
    resource_mul h.scale hfour (b:=1) (by simpa using hi) (Nat.cast_nonneg _)
  have hterm3 : 2*(M.quadratureCount j τ:ℝ)≤W^973 :=
    resource_mul h.scale htwo hn (Nat.cast_nonneg _)
  have hterm4 : 2*(M.layerRank j:ℝ)≤W^3 :=
    resource_mul h.scale htwo hr (Nat.cast_nonneg _)
  have hsum1 := resource_add_same h.scale
    (hterm1.trans (resource_pow_mono h.scale (show 2≤973 by norm_num)))
    (hterm2.trans (resource_pow_mono h.scale (show 3≤973 by norm_num)))
  have hsum2 := resource_add_same h.scale hsum1
    (hterm3.trans (resource_pow_mono h.scale (show 973≤974 by norm_num)))
  have hsum3 := resource_add_same h.scale hsum2
    (hterm4.trans (resource_pow_mono h.scale (show 3≤975 by norm_num)))
  have hsum4 := resource_add_same h.scale hsum3
    (hfour.trans (resource_pow_mono h.scale (show 2≤976 by norm_num)))
  push_cast
  exact hsum4.trans (resource_pow_mono h.scale (by norm_num))

lemma allResidual_primitive_bounds (M : GainPrefixDynamics P S states J) {W τ : ℝ}
    (h : M.PrimitiveResources W τ) (hτ : 0<τ) (j : Fin (J+1)) :
    (M.allResidualCoefficientBudget j:ℝ)≤W^984 ∧ (M.allResidualDimensionBudget j τ:ℝ)≤W^984 := by
  by_cases hj:j.val<J
  · simp only [allResidualCoefficientBudget,allResidualDimensionBudget,dif_pos hj]
    exact ⟨(M.primitive_residual_coefficient_bound h ⟨j,hj⟩).trans
      (resource_pow_mono h.scale (by norm_num)),M.primitive_residual_dimension_budget h hτ ⟨j,hj⟩⟩
  · simp only [allResidualCoefficientBudget,allResidualDimensionBudget,dif_neg hj,Nat.cast_one]
    exact ⟨one_le_pow₀ (by linarith [h.scale]),h.dimension.trans
      (by simpa only [pow_one] using resource_pow_mono h.scale (by norm_num : 1≤984))⟩

 theorem chosenResidualProgram_resources (M : GainPrefixDynamics P S states J)
    {W τ : ℝ} (h : M.PrimitiveResources W τ) (hτ : 0<τ) (hτ1 : τ≤1) (j : Fin (J+1)) :
    ((M.chosenResidualProgram τ hτ hτ1 j).maxDimension:ℝ)≤W^984 ∧
      (M.allResidualCoefficientBudget j:ℝ)≤W^984 := by
  have hh := M.allResidual_primitive_bounds h hτ j
  have hdim : ((M.chosenResidualProgram τ hτ hτ1 j).maxDimension:ℝ)≤M.allResidualDimensionBudget j τ := by
    exact_mod_cast (M.chosenResidualProgram_spec τ hτ hτ1 j).2.2.1
  exact ⟨hdim.trans hh.2,hh.1⟩

#print axioms chosenResidualProgram_resources
end GainPrefixDynamics
end ConditionalNonpolynomial.Analytic.PhysicalLong
