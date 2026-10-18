import NeuralGeneralization.RobustCompressionResourceAllocations

/-! # The large-width coefficient envelope, before finite-grid rounding -/
noncomputable section
namespace NeuralGeneralization.ConcreteModel.RobustCompressionInput

theorem large_coefficients_allocation (p : RobustCompressionInput) :
    Real.sqrt (p.firstSquaredBound : ℝ) +
      Real.sqrt (p.activeSquaredBound : ℝ)*(p.sourceClip : ℝ) +
      Real.sqrt (p.gaussianSquaredBound : ℝ) + (p.readoutClip : ℝ) ≤
      (p.largeWeightBound : ℝ) := by
  have hs (n : ℕ) : Real.sqrt (n : ℝ) ≤ (n : ℝ)+1 := by
    have heq := Real.sq_sqrt (Nat.cast_nonneg (α := ℝ) n)
    have hn := Real.sqrt_nonneg (n : ℝ)
    nlinarith [sq_nonneg ((n : ℝ)+1-Real.sqrt (n : ℝ))]
  have hmul := mul_le_mul_of_nonneg_right (hs p.activeSquaredBound)
    (Nat.cast_nonneg (α := ℝ) p.sourceClip)
  simp only [largeWeightBound,Nat.cast_add,Nat.cast_mul,Nat.cast_one]
  linarith [hs p.firstSquaredBound,hs p.gaussianSquaredBound]

theorem first_le_largeWeightBound (p : RobustCompressionInput) :
    Real.sqrt (p.firstSquaredBound : ℝ) ≤ (p.largeWeightBound : ℝ) := by
  have h := p.large_coefficients_allocation
  have hi : 0 ≤ Real.sqrt (p.activeSquaredBound : ℝ)*(p.sourceClip : ℝ) := by positivity
  linarith [Real.sqrt_nonneg (p.gaussianSquaredBound : ℝ),Nat.cast_nonneg (α:=ℝ) p.readoutClip]

theorem internal_le_largeWeightBound (p : RobustCompressionInput) :
    Real.sqrt (p.activeSquaredBound : ℝ)*(p.sourceClip : ℝ) +
      Real.sqrt (p.gaussianSquaredBound : ℝ) ≤ (p.largeWeightBound : ℝ) := by
  have h := p.large_coefficients_allocation
  linarith [Real.sqrt_nonneg (p.firstSquaredBound : ℝ),Nat.cast_nonneg (α:=ℝ) p.readoutClip]

theorem readout_le_largeWeightBound (p : RobustCompressionInput) :
    (p.readoutClip : ℝ) ≤ (p.largeWeightBound : ℝ) := by
  have h := p.large_coefficients_allocation
  have hi : 0 ≤ Real.sqrt (p.activeSquaredBound : ℝ)*(p.sourceClip : ℝ) := by positivity
  linarith [Real.sqrt_nonneg (p.firstSquaredBound : ℝ),Real.sqrt_nonneg (p.gaussianSquaredBound : ℝ)]

end NeuralGeneralization.ConcreteModel.RobustCompressionInput
