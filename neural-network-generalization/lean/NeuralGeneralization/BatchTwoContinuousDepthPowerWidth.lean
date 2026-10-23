import NeuralGeneralization.BatchTwoContinuousDepthPowerMemorizerMass

/-! An explicit polynomial width threshold for every fixed exponent γ>1. -/
noncomputable section
set_option maxHeartbeats 1400000
namespace NeuralGeneralization.BatchTwoContinuousDepthPower
open ConcreteModel BatchTwoNonGaussian

def widthExponent (ζ : ℝ) : ℕ := ⌈ζ⁻¹⌉₊

def widthThreshold (M r : ℕ) (ρ ζ : ℝ) : ℕ :=
  max M ⌈(16+100*noisePolynomialCoefficient standardGaussian*(slowResourceSize M r ρ)^7)^widthExponent ζ⌉₊

theorem polynomial_threshold_scale {N : ℕ} {ζ T σ : ℝ}
    (hζ : 0<ζ) (hT : 16≤T)
    (hN : T^widthExponent ζ≤(N : ℝ))
    (hscale : σ^2≤(N : ℝ)^(-(1+ζ))) :
    0<N ∧ (N : ℝ)*σ^2≤1/T ∧ σ^2≤1/16 := by
  have hT1 : 1≤T := by linarith
  have hT0 : 0<T := by linarith
  have hN1 : 1≤(N : ℝ) := (one_le_pow₀ hT1).trans hN
  have hNpos : (0 : ℝ)<N := by linarith
  have hq : ζ⁻¹≤(widthExponent ζ : ℝ) := Nat.le_ceil _
  have hqζ : 1≤(widthExponent ζ : ℝ)*ζ := by
    have hh := mul_le_mul_of_nonneg_right hq hζ.le
    rw [inv_mul_cancel₀ hζ.ne'] at hh
    exact hh
  have hpow : T≤(N : ℝ)^ζ := by
    calc
      T = T^(1 : ℝ) := by rw [Real.rpow_one]
      _ ≤ T^((widthExponent ζ : ℝ)*ζ) := Real.rpow_le_rpow_of_exponent_le hT1 hqζ
      _ = (T^widthExponent ζ)^ζ := by rw [←Real.rpow_natCast,←Real.rpow_mul hT0.le]
      _ ≤ (N : ℝ)^ζ := Real.rpow_le_rpow (by positivity) hN hζ.le
  have he : (N : ℝ)*(N : ℝ)^(-(1+ζ))=1/(N : ℝ)^ζ := by
    rw [show -(1+ζ)=(-1 : ℝ)-ζ by ring,Real.rpow_sub hNpos,Real.rpow_neg_one]
    field_simp
  have hsmall : (N : ℝ)*σ^2≤1/T := by
    apply (mul_le_mul_of_nonneg_left hscale hNpos.le).trans
    rw [he]
    exact one_div_le_one_div_of_le hT0 hpow
  refine ⟨by exact_mod_cast hNpos,hsmall,?_⟩
  have hs : σ^2≤(N : ℝ)*σ^2 := by nlinarith [sq_nonneg σ]
  exact hs.trans (hsmall.trans (one_div_le_one_div_of_le (by norm_num : (0 : ℝ)<16) hT))

theorem widthThreshold_properties {M r N : ℕ} {ρ ζ σ : ℝ}
    (hρ : 0<ρ) (hζ : 0<ζ) (hN : widthThreshold M r ρ ζ≤N)
    (hscale : σ^2≤(N : ℝ)^(-(1+ζ))) :
    M≤N ∧ 0<N ∧ (N : ℝ)*σ^2≤1/16 ∧ σ^2≤1/16 ∧
      (N : ℝ)*σ^2*slowEntropyCost M r ρ≤1/100 := by
  let A := noisePolynomialCoefficient standardGaussian
  let S := slowResourceSize M r ρ
  let T := 16+100*A*S^7
  have hA : 0<A := noisePolynomialCoefficient_pos standardGaussian
  have hlog : 0≤Real.log (1/min 1 ρ) :=
    Real.log_nonneg ((one_le_div (lt_min zero_lt_one hρ)).mpr (min_le_left _ _))
  have hS : 0≤S := by dsimp [S,slowResourceSize]; positivity
  have hT : 16≤T := by
    have hh : 0≤100*A*S^7 := by positivity
    dsimp [T]
    linarith
  have hbelow : M≤N := (le_max_left _ _).trans hN
  have hceil : ⌈T^widthExponent ζ⌉₊≤N := (le_max_right _ _).trans hN
  have hwidth : T^widthExponent ζ≤(N : ℝ) := (Nat.le_ceil _).trans (by exact_mod_cast hceil)
  obtain ⟨hNp,hsmall,hσsmall⟩ := polynomial_threshold_scale hζ hT hwidth hscale
  have hP : 0≤slowEntropyCost M r ρ :=
    powerPolynomialNoiseCost_nonneg standardGaussian 2 (r+1) M (by unfold slowEnergyCeiling; positivity)
      (BatchTwoContinuous.FiniteTarget.targetLogBudget_nonneg standardGaussian 2 hρ)
  have hPupper : slowEntropyCost M r ρ≤A*S^7 := slowEntropyCost_polynomial M r hρ
  refine ⟨hbelow,hNp,hsmall.trans (one_div_le_one_div_of_le (by norm_num) hT),hσsmall,?_⟩
  have hTpos : 0<T := by linarith
  calc
    _ ≤ (1/T)*slowEntropyCost M r ρ := mul_le_mul_of_nonneg_right hsmall hP
    _ ≤ (1/T)*(A*S^7) := mul_le_mul_of_nonneg_left hPupper (by positivity)
    _ ≤ 1/100 := by
      rw [one_div_mul_eq_div]
      apply (div_le_iff₀ hTpos).mpr
      dsimp only [T]
      linarith

end NeuralGeneralization.BatchTwoContinuousDepthPower
