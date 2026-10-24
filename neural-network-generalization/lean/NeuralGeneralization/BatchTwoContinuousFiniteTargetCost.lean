import NeuralGeneralization.BatchTwoContinuousFiniteTargetBudget

/-! Explicit polynomial majorants for the logarithmic target-cylinder cost. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoContinuous.FiniteTarget
open ConcreteModel BatchTwoNonGaussian

def logRadiusBound (ν : CoordinateLaw) (d r C : ℕ) (K ℓ : ℝ) : ℝ :=
  ℓ+inverseRadiusFactor d r C K+2*(r : ℝ)*(noiseBound ν d r C K ℓ+1)

def polynomialNoiseCost (ν : CoordinateLaw) (d r C : ℕ) (K ℓ : ℝ) : ℝ :=
  ((d : ℝ)+2)*(|Real.log (1/coordinateBallConstant ν)|+logRadiusBound ν d r C K ℓ)+
    (r : ℝ)*((C : ℝ)*(1024+2*logRadiusBound ν d r C K ℓ)+2)

theorem logRadiusBound_nonneg (ν : CoordinateLaw) (d r C : ℕ) {K ℓ : ℝ}
    (hK : 0≤K) (hℓ : 0≤ℓ) : 0≤logRadiusBound ν d r C K ℓ := by
  have := inverseRadiusFactor_pos d r C hK
  have := noiseBound_pos ν d r C hK hℓ
  unfold logRadiusBound
  positivity

theorem polynomialNoiseCost_nonneg (ν : CoordinateLaw) (d r C : ℕ) {K ℓ : ℝ}
    (hK : 0≤K) (hℓ : 0≤ℓ) : 0≤polynomialNoiseCost ν d r C K ℓ := by
  have := logRadiusBound_nonneg ν d r C hK hℓ
  unfold polynomialNoiseCost
  positivity

theorem networkCylinderCost_le_polynomial (ν : CoordinateLaw) (d r C : ℕ)
    {K q ℓ : ℝ} (hK : 0≤K) (hq : 0<q) (hℓ : 0≤ℓ) (hlogq : Real.log (1/q)≤ℓ) :
    let b := noiseBound ν d r C K ℓ
    let η := q*cylinderRadius d r K C (2*(b+C+1))
    networkCylinderCost ν d C r η ≤ polynomialNoiseCost ν d r C K ℓ := by
  let b := noiseBound ν d r C K ℓ
  let η := q*cylinderRadius d r K C (2*(b+C+1))
  have hη : 0<η := mul_pos hq (cylinderRadius_pos d r hK (Nat.cast_nonneg C))
  have hlog : Real.log (η⁻¹) ≤ logRadiusBound ν d r C K ℓ := by
    have hh := log_inverseRadius_le d r C hK (noiseBound_pos ν d r C hK hℓ).le
    dsimp only [η,logRadiusBound]
    rw [mul_inv_rev,Real.log_mul
      (inv_pos.mpr (cylinderRadius_pos d r hK (Nat.cast_nonneg C))).ne' (inv_pos.mpr hq).ne']
    simp only [one_div] at hlogq
    linarith
  have hscalar : scalarCylinderCost ν η ≤
      |Real.log (1/coordinateBallConstant ν)|+logRadiusBound ν d r C K ℓ := by
    unfold scalarCylinderCost
    rw [show 1/(coordinateBallConstant ν*η)=(1/coordinateBallConstant ν)*η⁻¹ by ring,
      Real.log_mul (one_div_pos.mpr (coordinateBallConstant_pos ν)).ne' (inv_pos.mpr hη).ne']
    exact add_le_add (le_abs_self _) hlog
  have hmatrix : matrixCylinderCost C η ≤
      (C : ℝ)*(1024+2*logRadiusBound ν d r C K ℓ)+2 := by
    have h1024 : Real.log 1024≤(1024 : ℝ) :=
      (Real.log_le_sub_one_of_pos (by norm_num : (0 : ℝ)<1024)).trans (by norm_num)
    have h2 : Real.log 2≤(2 : ℝ) :=
      (Real.log_le_sub_one_of_pos (by norm_num : (0 : ℝ)<2)).trans (by norm_num)
    have he : Real.log (1024/η^2)=Real.log 1024+2*Real.log (η⁻¹) := by
      rw [Real.log_div (by norm_num) (sq_pos_of_pos hη).ne',Real.log_pow,Real.log_inv]
      ring
    unfold matrixCylinderCost
    rw [he]
    exact add_le_add (mul_le_mul_of_nonneg_left (by linarith) (Nat.cast_nonneg C)) h2
  exact add_le_add (mul_le_mul_of_nonneg_left hscalar (by positivity))
    (mul_le_mul_of_nonneg_left hmatrix (Nat.cast_nonneg r))

end NeuralGeneralization.BatchTwoContinuous.FiniteTarget
