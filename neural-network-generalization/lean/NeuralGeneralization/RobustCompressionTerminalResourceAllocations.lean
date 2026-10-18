import NeuralGeneralization.RobustCompressionResourceAllocations

/-! # Failure and readout allocations for the stopped terminal comparison -/
noncomputable section
namespace NeuralGeneralization.ConcreteModel.RobustCompressionInput

theorem terminal_failure_allocation (p : RobustCompressionInput)
    (hL : 0 < p.depth) (hA : 0 < p.inverseFailure) (hR : 0 < p.inverseRadius)
    {radius : ℝ} (hrad : (p.inverseRadius : ℝ)⁻¹ ≤ radius) :
    2*(p.depth : ℝ)/p.inverseLayerFailure +
      8*(10*(p.depth : ℝ)/p.inverseLayerError)/radius^2 +
      3/(p.inverseLayerFailure : ℝ) ≤ (p.inverseFailure : ℝ)⁻¹ := by
  have hη := p.inverseLayerFailure_pos hL hA
  have hηr : (0 : ℝ) < p.inverseLayerFailure := by exact_mod_cast hη
  have hLr : (1 : ℝ) ≤ p.depth := by exact_mod_cast hL
  have hc := p.cumulative_abort_allocation hL hA
  have hn := p.cumulative_noise_allocation hL hA hR hrad le_rfl
  have heta : 1/(p.inverseLayerFailure : ℝ) ≤ (p.inverseFailure : ℝ)⁻¹/100 := by
    calc
      _ ≤ (p.depth : ℝ)/p.inverseLayerFailure :=
        div_le_div_of_nonneg_right hLr hηr.le
      _ = _ := hc
  have hnonneg : 0 ≤ (p.inverseFailure : ℝ)⁻¹ := by positivity
  have hsum : 2*(p.depth : ℝ)/p.inverseLayerFailure +
      8*(10*(p.depth : ℝ)/p.inverseLayerError)/radius^2 +
      3/(p.inverseLayerFailure : ℝ) ≤ 7*(p.inverseFailure : ℝ)⁻¹/50 := by
    simp only [div_eq_mul_inv] at hc hn heta ⊢
    nlinarith [hc,hn,heta]
  exact hsum.trans (by nlinarith)

theorem terminal_readout_error_allocation (p : RobustCompressionInput)
    (hL : 0 < p.depth) (hA : 0 < p.inverseFailure) (hR : 0 < p.inverseRadius)
    {radius : ℝ} (hrad : (p.inverseRadius : ℝ)⁻¹ ≤ radius) :
    (p.readoutMoment : ℝ)/p.readoutClip + 1/(16*(p.inverseRadius : ℝ)) ≤ radius/8 := by
  have h := p.readout_clipping_allocation (p.inverseLayerFailure_pos hL hA) hR
  rw [h]
  have he : 1/(16*(p.inverseRadius : ℝ)) + 1/(16*(p.inverseRadius : ℝ)) =
      (p.inverseRadius : ℝ)⁻¹/8 := by ring
  rw [he]
  exact div_le_div_of_nonneg_right hrad (by norm_num)

end NeuralGeneralization.ConcreteModel.RobustCompressionInput
