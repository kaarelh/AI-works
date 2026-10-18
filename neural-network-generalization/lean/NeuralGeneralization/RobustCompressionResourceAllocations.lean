import NeuralGeneralization.RobustCompressionAllocations

/-! # Analytic allocations for the literal natural resource formulas -/

noncomputable section
open NeuralGeneralization.RobustCompressionAllocations

namespace NeuralGeneralization.ConcreteModel.RobustCompressionInput

theorem inverseLayerError_pos (p : RobustCompressionInput) (hL : 0 < p.depth)
    (hA : 0 < p.inverseFailure) (hR : 0 < p.inverseRadius) :
    0 < p.inverseLayerError := by
  unfold inverseLayerError
  positivity

theorem inverseLayerFailure_pos (p : RobustCompressionInput) (hL : 0 < p.depth)
    (hA : 0 < p.inverseFailure) : 0 < p.inverseLayerFailure := by
  unfold inverseLayerFailure
  positivity

theorem sourceClip_pos (p : RobustCompressionInput) (hE : 0 < p.inverseLayerError) :
    0 < p.sourceClip := by unfold sourceClip; positivity

theorem inverseKernelPrecision_pos (p : RobustCompressionInput)
    (hE : 0 < p.inverseLayerError) : 0 < p.inverseKernelPrecision := by
  unfold inverseKernelPrecision
  positivity

theorem bankSize_pos (p : RobustCompressionInput) : 0 < p.bankSize := by
  unfold bankSize
  omega

theorem source_sampling_exponent (p : RobustCompressionInput)
    (hE : 0 < p.inverseLayerError) :
    5000 * ((p.dimension : ℝ) + p.activeRank + p.inverseLayerFailure + p.depth + 1) ≤
      (p.bankSize : ℝ) * ((p.inverseKernelPrecision : ℝ)⁻¹ /
        ((p.activeRank : ℝ)+1))^2 / (2*(p.sourceClip : ℝ)^4) := by
  have hT : (0 : ℝ) < p.sourceClip := by exact_mod_cast p.sourceClip_pos hE
  have ha : (0 : ℝ) < p.inverseKernelPrecision := by
    exact_mod_cast p.inverseKernelPrecision_pos hE
  have hq : (0 : ℝ) < p.activeRank+1 := by positivity
  have hmN : 10000 * p.sourceClip^4 * (p.activeRank+1)^2 *
      p.inverseKernelPrecision^2 *
      (p.dimension+p.activeRank+p.inverseLayerFailure+p.depth+1) ≤ p.bankSize := by
    unfold bankSize
    omega
  have hm : 10000 * (p.sourceClip : ℝ)^4 * ((p.activeRank : ℝ)+1)^2 *
      (p.inverseKernelPrecision : ℝ)^2 *
      ((p.dimension : ℝ)+p.activeRank+p.inverseLayerFailure+p.depth+1) ≤ p.bankSize := by
    exact_mod_cast hmN
  have hmul := mul_le_mul_of_nonneg_right hm
    (show 0 ≤ ((p.inverseKernelPrecision : ℝ)⁻¹ / ((p.activeRank : ℝ)+1))^2 /
      (2*(p.sourceClip : ℝ)^4) by positivity)
  have heq : (10000 * (p.sourceClip : ℝ)^4 * ((p.activeRank : ℝ)+1)^2 *
      (p.inverseKernelPrecision : ℝ)^2 *
      ((p.dimension : ℝ)+p.activeRank+p.inverseLayerFailure+p.depth+1)) *
      (((p.inverseKernelPrecision : ℝ)⁻¹ / ((p.activeRank : ℝ)+1))^2 /
        (2*(p.sourceClip : ℝ)^4)) =
      5000*((p.dimension : ℝ)+p.activeRank+p.inverseLayerFailure+p.depth+1) := by
    field_simp
    ring
  rw [heq] at hmul
  simpa only [mul_div_assoc] using hmul

theorem source_sampling_failure (p : RobustCompressionInput)
    (hE : 0 < p.inverseLayerError) (hη : 0 < p.inverseLayerFailure) :
    ((p.activeRank : ℝ)^2 + p.activeRank * 2^p.dimension +
      (2^p.dimension : ℝ)^2) *
      (2 * Real.exp (-((p.bankSize : ℝ) *
        ((p.inverseKernelPrecision : ℝ)⁻¹ / ((p.activeRank : ℝ)+1))^2 /
          (2*(p.sourceClip : ℝ)^4)))) ≤ (p.inverseLayerFailure : ℝ)⁻¹ := by
  apply source_bank_failure_allocation p.dimension p.activeRank
  · exact_mod_cast hη
  · have h := p.source_sampling_exponent hE
    have hd : (0 : ℝ) ≤ p.depth := by positivity
    have hd' : (0 : ℝ) ≤ p.dimension := by positivity
    have hq : (0 : ℝ) ≤ p.activeRank := by positivity
    have hη' : (0 : ℝ) ≤ p.inverseLayerFailure := by positivity
    linarith

theorem readoutClip_pos (p : RobustCompressionInput)
    (hη : 0 < p.inverseLayerFailure) (hR : 0 < p.inverseRadius) :
    0 < p.readoutClip := by
  unfold readoutClip readoutMoment
  positivity

theorem readout_sampling_exponent (p : RobustCompressionInput)
    (hη : 0 < p.inverseLayerFailure) (hR : 0 < p.inverseRadius) :
    (p.dimension : ℝ) + p.inverseLayerFailure + 1 ≤
      (p.bankSize : ℝ) * (1/(16*(p.inverseRadius : ℝ)))^2 /
        (2*(p.readoutClip : ℝ)^2) := by
  have hB : (0 : ℝ) < p.readoutClip := by exact_mod_cast p.readoutClip_pos hη hR
  have hRR : (0 : ℝ) < p.inverseRadius := by exact_mod_cast hR
  have hmN : 10000 * p.readoutClip^2 * p.inverseRadius^2 *
      (p.dimension+p.inverseLayerFailure+1) ≤ p.bankSize := by
    unfold bankSize
    omega
  have hm : 10000 * (p.readoutClip : ℝ)^2 * (p.inverseRadius : ℝ)^2 *
      ((p.dimension : ℝ)+p.inverseLayerFailure+1) ≤ p.bankSize := by
    exact_mod_cast hmN
  have hmul := mul_le_mul_of_nonneg_right hm
    (show 0 ≤ (1/(16*(p.inverseRadius : ℝ)))^2 / (2*(p.readoutClip : ℝ)^2) by positivity)
  have heq : (10000 * (p.readoutClip : ℝ)^2 * (p.inverseRadius : ℝ)^2 *
      ((p.dimension : ℝ)+p.inverseLayerFailure+1)) *
      ((1/(16*(p.inverseRadius : ℝ)))^2 / (2*(p.readoutClip : ℝ)^2)) =
      (625/32 : ℝ) * ((p.dimension : ℝ)+p.inverseLayerFailure+1) := by
    field_simp
    ring
  rw [heq] at hmul
  have hv : 0 ≤ (p.dimension : ℝ)+p.inverseLayerFailure+1 := by positivity
  have hfactor : (p.bankSize : ℝ) *
      ((1/(16*(p.inverseRadius : ℝ)))^2 / (2*(p.readoutClip : ℝ)^2)) =
      (p.bankSize : ℝ) * (1/(16*(p.inverseRadius : ℝ)))^2 /
        (2*(p.readoutClip : ℝ)^2) := by ring
  rw [hfactor] at hmul
  linarith

theorem readout_sampling_failure (p : RobustCompressionInput)
    (hη : 0 < p.inverseLayerFailure) (hR : 0 < p.inverseRadius) :
    (2^p.dimension : ℝ) *
      (2*Real.exp (-((p.bankSize : ℝ) * (1/(16*(p.inverseRadius : ℝ)))^2 /
        (2*(p.readoutClip : ℝ)^2)))) ≤ (p.inverseLayerFailure : ℝ)⁻¹ := by
  apply readout_failure_allocation p.dimension
  · exact_mod_cast hη
  · exact p.readout_sampling_exponent hη hR

theorem active_rank_failure_budget (p : RobustCompressionInput)
    (hη : 0 < p.inverseLayerFailure) :
    2*(p.energy : ℝ)*(p.inverseSelectionError : ℝ)^3 /
      p.activeRank ≤ (p.inverseLayerFailure : ℝ)⁻¹ := by
  have hH : (0 : ℝ) < p.inverseLayerFailure := by exact_mod_cast hη
  have hqN : 0 < p.activeRank := by unfold activeRank; omega
  have hq : (0 : ℝ) < p.activeRank := by exact_mod_cast hqN
  rw [inv_eq_one_div]
  apply (div_le_div_iff₀ hq hH).mpr
  have heq : (p.activeRank : ℝ) =
      2*p.energy*p.inverseLayerFailure*(p.inverseSelectionError : ℝ)^3+1 := by
    simp only [activeRank,Nat.cast_add,Nat.cast_mul,Nat.cast_pow,Nat.cast_ofNat,Nat.cast_one]
  nlinarith

/-- The chosen cutoff pays all layerwise finite-message entropy, even without
dividing the cutoff by K. -/
theorem message_entropy_budget (p : RobustCompressionInput) {N : ℕ}
    (hN : p.widthBound ≤ N) (hK : 0 < p.energy) :
    (p.depth : ℝ) * ((((p.dimension+1)*p.activeRank+2 : ℕ) : ℝ)*Real.log 2) ≤
      (N : ℝ)*p.energy := by
  have hl2 : Real.log 2 ≤ 1 := by
    have h := Real.log_le_sub_one_of_pos (by norm_num : (0 : ℝ) < 2)
    linarith
  have hcount : (p.dimension+1)*p.activeRank+2 ≤
      2*(p.dimension+1)*(p.activeRank+1) := by nlinarith
  have hcut : 2*p.depth*(p.dimension+1)*(p.activeRank+1) ≤ p.widthBound := by
    unfold widthBound
    omega
  have hNK : (N : ℝ) ≤ (N : ℝ)*p.energy := by
    have hK' : (1 : ℝ) ≤ p.energy := by exact_mod_cast hK
    nlinarith [Nat.cast_nonneg (α := ℝ) N]
  calc
    _ ≤ (p.depth : ℝ)*(((p.dimension+1)*p.activeRank+2 : ℕ) : ℝ) := by
      have h := mul_le_mul_of_nonneg_left hl2
        (show 0 ≤ (p.depth : ℝ)*(((p.dimension+1)*p.activeRank+2 : ℕ) : ℝ) by positivity)
      simpa only [mul_one, mul_assoc] using h
    _ ≤ ((2*p.depth*(p.dimension+1)*(p.activeRank+1) : ℕ) : ℝ) := by
      have h := Nat.mul_le_mul_left p.depth hcount
      have h' : p.depth*((p.dimension+1)*p.activeRank+2) ≤
          2*p.depth*(p.dimension+1)*(p.activeRank+1) := by nlinarith
      exact_mod_cast h'
    _ ≤ (p.widthBound : ℝ) := by exact_mod_cast hcut
    _ ≤ (N : ℝ) := by exact_mod_cast hN
    _ ≤ _ := hNK

theorem gaussian_clipping_allocation (p : RobustCompressionInput)
    (hE : 0 < p.inverseLayerError) :
    64*(p.bankSize : ℝ)/p.gaussianSquaredBound =
      (p.inverseLayerError : ℝ)⁻¹/4 := by
  have hER : (p.inverseLayerError : ℝ) ≠ 0 := by positivity
  have hm : (p.bankSize : ℝ) ≠ 0 := by exact_mod_cast (p.bankSize_pos).ne'
  simp only [gaussianSquaredBound,Nat.cast_mul,Nat.cast_ofNat]
  field_simp
  ring

theorem active_clipping_allocation (p : RobustCompressionInput)
    (hE : 0 < p.inverseLayerError) :
    4*(8*(p.energy : ℝ)+2*p.activeRank)/p.activeSquaredBound =
      (p.inverseLayerError : ℝ)⁻¹ := by
  have hER : (p.inverseLayerError : ℝ) ≠ 0 := by positivity
  have hqN : 0 < p.activeRank := by unfold activeRank; omega
  have hq : (0 : ℝ) < p.activeRank := by exact_mod_cast hqN
  have hV : 8*(p.energy : ℝ)+2*p.activeRank ≠ 0 := by positivity
  simp only [activeSquaredBound,Nat.cast_add,Nat.cast_mul,Nat.cast_ofNat]
  field_simp

theorem first_clipping_allocation (p : RobustCompressionInput)
    (hE : 0 < p.inverseLayerError) :
    4*(4*(p.energy : ℝ)+2*((p.dimension : ℝ)+1))/p.firstSquaredBound =
      (p.inverseLayerError : ℝ)⁻¹ := by
  have hER : (p.inverseLayerError : ℝ) ≠ 0 := by positivity
  have hV : 4*(p.energy : ℝ)+2*((p.dimension : ℝ)+1) ≠ 0 := by positivity
  simp only [firstSquaredBound,Nat.cast_add,Nat.cast_mul,Nat.cast_ofNat,Nat.cast_one]
  field_simp

theorem readout_clipping_allocation (p : RobustCompressionInput)
    (hη : 0 < p.inverseLayerFailure) (hR : 0 < p.inverseRadius) :
    (p.readoutMoment : ℝ)/p.readoutClip = 1/(16*(p.inverseRadius : ℝ)) := by
  have hηR : (0 : ℝ) < p.inverseLayerFailure := by exact_mod_cast hη
  have hRR : (p.inverseRadius : ℝ) ≠ 0 := by positivity
  have hK0 : (p.readoutMoment : ℝ) ≠ 0 := by
    simp only [readoutMoment,Nat.cast_add,Nat.cast_mul,Nat.cast_ofNat]
    positivity
  simp only [readoutClip,Nat.cast_mul,Nat.cast_ofNat]
  field_simp

theorem actual_feature_error_allocation (p : RobustCompressionInput)
    (hE : 0 < p.inverseLayerError) :
    (p.activeRank : ℝ)/p.sourceClip + 2*(p.inverseKernelPrecision : ℝ)⁻¹ ≤
      3*(p.inverseLayerError : ℝ)⁻¹ / (128*((p.activeSquaredBound : ℝ)+1)) := by
  have hER : (0 : ℝ) < p.inverseLayerError := by exact_mod_cast hE
  have h := feature_error_allocation (inv_pos.mpr hER)
    (Nat.cast_nonneg (α := ℝ) p.activeRank)
    (Nat.cast_nonneg (α := ℝ) p.activeSquaredBound)
  convert h using 1
  · simp only [sourceClip,inverseKernelPrecision,Nat.cast_mul,Nat.cast_add,
      Nat.cast_ofNat,Nat.cast_one,div_inv_eq_mul]
    field_simp

theorem actual_scalar_reconstruction_allocation (p : RobustCompressionInput)
    (hE : 0 < p.inverseLayerError) :
    (p.activeSquaredBound : ℝ)*
        ((p.activeRank : ℝ)/p.sourceClip + 2*(p.inverseKernelPrecision : ℝ)⁻¹)^2 +
      (p.inverseKernelPrecision : ℝ)⁻¹ +
        2*((p.activeRank : ℝ)/p.sourceClip + 2*(p.inverseKernelPrecision : ℝ)⁻¹) ≤
      (p.inverseLayerError : ℝ)⁻¹/8 := by
  have hER : (0 : ℝ) < p.inverseLayerError := by exact_mod_cast hE
  have he1 : (p.inverseLayerError : ℝ)⁻¹ ≤ 1 := by
    apply inv_le_one_of_one_le₀
    exact_mod_cast hE
  apply scalar_reconstruction_allocation (inv_pos.mpr hER) he1
    (Nat.cast_nonneg (α := ℝ) p.activeSquaredBound) (by positivity)
    (p.actual_feature_error_allocation hE)
  simp only [inverseKernelPrecision,Nat.cast_mul,Nat.cast_add,Nat.cast_ofNat,Nat.cast_one]
  apply le_of_eq
  field_simp

theorem cumulative_abort_allocation (p : RobustCompressionInput)
    (hL : 0 < p.depth) (hA : 0 < p.inverseFailure) :
    (p.depth : ℝ)/(p.inverseLayerFailure : ℝ) =
      (p.inverseFailure : ℝ)⁻¹/100 := by
  have hLR : (p.depth : ℝ) ≠ 0 := by positivity
  have hAR : (p.inverseFailure : ℝ) ≠ 0 := by positivity
  simp only [inverseLayerFailure,Nat.cast_mul,Nat.cast_ofNat]
  field_simp

theorem cumulative_noise_allocation (p : RobustCompressionInput)
    (hL : 0 < p.depth) (hA : 0 < p.inverseFailure) (hR : 0 < p.inverseRadius)
    {radius α : ℝ} (hrad : (p.inverseRadius : ℝ)⁻¹ ≤ radius)
    (hα : (p.inverseFailure : ℝ)⁻¹ ≤ α) :
    4*(10*(p.depth : ℝ)/(p.inverseLayerError : ℝ))/radius^2 ≤ α/25 := by
  have hLR : (0 : ℝ) < p.depth := by exact_mod_cast hL
  have hAR : (0 : ℝ) < p.inverseFailure := by exact_mod_cast hA
  have hRR : (0 : ℝ) < p.inverseRadius := by exact_mod_cast hR
  have hr : 0 < radius := (inv_pos.mpr hRR).trans_le hrad
  have hprod : 1 ≤ (p.inverseRadius : ℝ)*radius := by
    have h := mul_le_mul_of_nonneg_left hrad hRR.le
    simpa only [mul_inv_cancel₀ hRR.ne'] using h
  have hsq : 1 ≤ ((p.inverseRadius : ℝ)*radius)^2 := by nlinarith
  have heq : 4*(10*(p.depth : ℝ)/(p.inverseLayerError : ℝ))/radius^2 =
      (p.inverseFailure : ℝ)⁻¹/(25*((p.inverseRadius : ℝ)*radius)^2) := by
    simp only [inverseLayerError,Nat.cast_mul,Nat.cast_pow,Nat.cast_ofNat]
    field_simp
    ring
  rw [heq]
  calc
    _ ≤ (p.inverseFailure : ℝ)⁻¹/25 :=
      div_le_div_of_nonneg_left (inv_nonneg.mpr hAR.le) (by norm_num) (by nlinarith)
    _ ≤ α/25 := div_le_div_of_nonneg_right hα (by norm_num)

/-- The common grid coefficient bound dominates all literal coefficients of
the reconstructed ordinary network, with no source-width factor. -/
theorem reconstructed_coefficients_allocation (p : RobustCompressionInput) :
    Real.sqrt (p.firstSquaredBound : ℝ) +
        Real.sqrt (p.activeSquaredBound : ℝ)*(p.sourceClip : ℝ) +
        Real.sqrt (p.gaussianSquaredBound : ℝ) + (p.readoutClip : ℝ) ≤
      (p.weightBound : ℝ) := by
  have hs (n : ℕ) : Real.sqrt (n : ℝ) ≤ (n : ℝ)+1 := by
    have heq := Real.sq_sqrt (Nat.cast_nonneg (α := ℝ) n)
    have hn := Real.sqrt_nonneg (n : ℝ)
    nlinarith [sq_nonneg ((n : ℝ)+1-Real.sqrt (n : ℝ))]
  have hmul := mul_le_mul_of_nonneg_right (hs p.activeSquaredBound)
    (Nat.cast_nonneg (α := ℝ) p.sourceClip)
  have hbound : ((p.firstSquaredBound : ℝ)+1) +
      ((p.activeSquaredBound : ℝ)+1)*(p.sourceClip : ℝ) +
      ((p.gaussianSquaredBound : ℝ)+1) + (p.readoutClip : ℝ) ≤
      (p.weightBound : ℝ) := by
    have h : p.largeWeightBound ≤ p.weightBound := by unfold weightBound; omega
    have hcast : (p.largeWeightBound : ℝ) ≤ p.weightBound := by exact_mod_cast h
    simp only [largeWeightBound,Nat.cast_add,Nat.cast_mul,Nat.cast_one] at hcast
    linarith
  linarith [hs p.firstSquaredBound,hs p.gaussianSquaredBound]

end NeuralGeneralization.ConcreteModel.RobustCompressionInput
