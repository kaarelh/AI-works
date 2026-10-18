import NeuralGeneralization.RobustCompressionResourceAllocations

/-! # Literal resource specialization of the complete successful-layer bound -/
noncomputable section
open scoped ENNReal
namespace NeuralGeneralization.ConcreteModel.RobustCompressionInput

theorem successful_layer_resources_real (p : RobustCompressionInput) (N : ℕ)
    (hE : 0 < p.inverseLayerError) {t : ℝ} (ht1 : t^2 ≤ 1) :
    4 * ((4/(Real.sqrt (p.activeSquaredBound : ℝ))^2)*
        ((N : ℝ)*(8*p.energy+2*p.activeRank)) +
      14*N*(p.inverseSelectionError : ℝ)⁻¹ +
      (N : ℝ)*((Real.sqrt (p.activeSquaredBound : ℝ))^2*
          ((p.activeRank : ℝ)/p.sourceClip + 2*(p.inverseKernelPrecision : ℝ)⁻¹)^2 +
        t^2*((p.inverseKernelPrecision : ℝ)⁻¹ +
          2*((p.activeRank : ℝ)/p.sourceClip + 2*(p.inverseKernelPrecision : ℝ)⁻¹))) +
      64*(N : ℝ)*p.bankSize/(Real.sqrt (p.gaussianSquaredBound : ℝ))^2) ≤
        10*(N : ℝ)/p.inverseLayerError := by
  rw [Real.sq_sqrt (Nat.cast_nonneg p.activeSquaredBound),
    Real.sq_sqrt (Nat.cast_nonneg p.gaussianSquaredBound)]
  have hA := p.active_clipping_allocation hE
  have hC := p.gaussian_clipping_allocation hE
  have hG := p.actual_scalar_reconstruction_allocation hE
  have hterm : 0 ≤ (p.inverseKernelPrecision : ℝ)⁻¹ +
      2*((p.activeRank : ℝ)/p.sourceClip + 2*(p.inverseKernelPrecision : ℝ)⁻¹) := by positivity
  have hG' := (mul_le_mul_of_nonneg_right ht1 hterm)
  have hnormA : (4/(p.activeSquaredBound : ℝ))*
      ((N : ℝ)*(8*p.energy+2*p.activeRank)) = (N : ℝ)*(p.inverseLayerError : ℝ)⁻¹ := by
    calc
      _ = (N : ℝ)*(4*(8*p.energy+2*p.activeRank)/(p.activeSquaredBound : ℝ)) := by ring
      _ = _ := by rw [hA]
  have hnormC : 64*(N : ℝ)*p.bankSize/(p.gaussianSquaredBound : ℝ) =
      (N : ℝ)*((p.inverseLayerError : ℝ)⁻¹/4) := by
    calc
      _ = (N : ℝ)*(64*(p.bankSize : ℝ)/(p.gaussianSquaredBound : ℝ)) := by ring
      _ = _ := by rw [hC]
  have hnormR : 14*(N : ℝ)*(p.inverseSelectionError : ℝ)⁻¹ =
      14*((N : ℝ)*(p.inverseLayerError : ℝ)⁻¹/100) := by
    simp only [inverseSelectionError,Nat.cast_mul,Nat.cast_ofNat]
    ring
  rw [hnormA,hnormC,hnormR]
  have hh := RobustCompressionAllocations.hidden_layer_allocation
    (e := (N : ℝ)*(p.inverseLayerError : ℝ)⁻¹) (by positivity) le_rfl le_rfl
      (show (N : ℝ)*((p.activeSquaredBound : ℝ)*
        ((p.activeRank : ℝ)/p.sourceClip+2*(p.inverseKernelPrecision : ℝ)⁻¹)^2 +
          t^2*((p.inverseKernelPrecision : ℝ)⁻¹+
            2*((p.activeRank : ℝ)/p.sourceClip+2*(p.inverseKernelPrecision : ℝ)⁻¹))) ≤
          (N : ℝ)*(p.inverseLayerError : ℝ)⁻¹/8 from by
        calc
          _ ≤ (N : ℝ)*((p.inverseLayerError : ℝ)⁻¹/8) :=
            mul_le_mul_of_nonneg_left (by nlinarith) (Nat.cast_nonneg N)
          _ = _ := by ring)
      (show (N : ℝ)*((p.inverseLayerError : ℝ)⁻¹/4) ≤
          (N : ℝ)*(p.inverseLayerError : ℝ)⁻¹/4 by ring_nf; exact le_rfl)
  simpa only [div_eq_mul_inv,mul_assoc] using hh

theorem successful_layer_resources (p : RobustCompressionInput) (N : ℕ)
    (hE : 0 < p.inverseLayerError) {t : ℝ} (ht1 : t^2 ≤ 1) :
    4 * (ENNReal.ofReal (4/(Real.sqrt (p.activeSquaredBound : ℝ))^2)*
        ENNReal.ofReal ((N : ℝ)*(8*p.energy+2*p.activeRank)) +
      ENNReal.ofReal (14*N*(p.inverseSelectionError : ℝ)⁻¹) +
      ENNReal.ofReal ((N : ℝ)*((Real.sqrt (p.activeSquaredBound : ℝ))^2*
          ((p.activeRank : ℝ)/p.sourceClip + 2*(p.inverseKernelPrecision : ℝ)⁻¹)^2 +
        t^2*((p.inverseKernelPrecision : ℝ)⁻¹ +
          2*((p.activeRank : ℝ)/p.sourceClip + 2*(p.inverseKernelPrecision : ℝ)⁻¹)))) +
      ENNReal.ofReal (64*(N : ℝ)*p.bankSize/(Real.sqrt (p.gaussianSquaredBound : ℝ))^2)) ≤
        ENNReal.ofReal (10*(N : ℝ)/p.inverseLayerError) := by
  have h := ENNReal.ofReal_le_ofReal (p.successful_layer_resources_real N hE ht1)
  rw [ENNReal.ofReal_mul (by norm_num : (0 : ℝ) ≤ 4),
    ENNReal.ofReal_add (by positivity) (by positivity),
    ENNReal.ofReal_add (by positivity) (by positivity),
    ENNReal.ofReal_add (by positivity) (by positivity),
    ENNReal.ofReal_mul (by positivity)] at h
  simpa only [ENNReal.ofReal_ofNat] using h

end NeuralGeneralization.ConcreteModel.RobustCompressionInput
