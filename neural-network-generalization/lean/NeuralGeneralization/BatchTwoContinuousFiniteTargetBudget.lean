import NeuralGeneralization.BatchTwoContinuousFiniteTargetCylinder

/-! The free-matrix action threshold and cylinder log mass remain polynomial
in the logarithm of the requested output tolerance. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1200000
open MeasureTheory
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoContinuous.FiniteTarget
open ConcreteModel BatchTwoNonGaussian

def tailCoefficient (d r C : ℕ) (K ℓ : ℝ) : ℝ :=
  cylinderTailCoefficient d r C K+2*C*ℓ

def noiseBound (ν : CoordinateLaw) (d r C : ℕ) (K ℓ : ℝ) : ℝ :=
  1+16*subGaussianVariance ν*tailCoefficient d r C K ℓ

theorem tailCoefficient_pos (d r C : ℕ) {K ℓ : ℝ} (hK : 0≤K) (hℓ : 0≤ℓ) :
    0<tailCoefficient d r C K ℓ :=
  add_pos_of_pos_of_nonneg (cylinderTailCoefficient_pos d r C hK) (by positivity)

theorem noiseBound_pos (ν : CoordinateLaw) (d r C : ℕ) {K ℓ : ℝ}
    (hK : 0≤K) (hℓ : 0≤ℓ) : 0<noiseBound ν d r C K ℓ := by
  have := tailCoefficient_pos d r C hK hℓ
  have := subGaussianVariance_pos ν
  unfold noiseBound
  positivity

theorem noiseBound_budget (ν : CoordinateLaw) (d r C : ℕ) {K q ℓ : ℝ}
    (hK : 0≤K) (hq : 0<q) (hℓ : 0≤ℓ) (hlogq : Real.log (1/q) ≤ ℓ) :
    let b := noiseBound ν d r C K ℓ
    let ρ := q*cylinderRadius d r K C (2*(b+C+1))
    2*Real.log 9+(C : ℝ)*Real.log (1024/ρ^2)+2*Real.log 2 ≤
      b^2/(8*subGaussianVariance ν) := by
  let b := noiseBound ν d r C K ℓ
  let ρ := q*cylinderRadius d r K C (2*(b+C+1))
  let D := tailCoefficient d r C K ℓ
  let a := inverseRadiusFactor d r C K
  have hb : 0 ≤ b := (noiseBound_pos ν d r C hK hℓ).le
  have hρ : 0 < ρ := mul_pos hq (cylinderRadius_pos d r hK (Nat.cast_nonneg C))
  have hv := subGaussianVariance_pos ν
  have ha : 0 < a := inverseRadiusFactor_pos d r C hK
  have hD : 0 < D := tailCoefficient_pos d r C hK hℓ
  have hl : Real.log (ρ⁻¹) ≤ ℓ+a+2*(r : ℝ)*(b+1) := by
    have hh := log_inverseRadius_le d r C hK hb
    dsimp only [ρ]
    rw [mul_inv_rev,Real.log_mul (inv_pos.mpr (cylinderRadius_pos d r hK (Nat.cast_nonneg C))).ne'
      (inv_pos.mpr hq).ne']
    simp only [one_div] at hlogq
    linarith
  have hlog : Real.log (1024/ρ^2)=Real.log 1024+2*Real.log (ρ⁻¹) := by
    rw [Real.log_div (by norm_num) (sq_pos_of_pos hρ).ne',Real.log_pow,Real.log_inv]
    ring
  have hl9 : Real.log 9 ≤ 9 := (Real.log_le_sub_one_of_pos (by norm_num : (0 : ℝ) < 9)).trans (by norm_num)
  have hl2 : Real.log 2 ≤ 2 := (Real.log_le_sub_one_of_pos (by norm_num : (0 : ℝ) < 2)).trans (by norm_num)
  have hl1024 : Real.log 1024 ≤ 1024 :=
    (Real.log_le_sub_one_of_pos (by norm_num : (0 : ℝ) < 1024)).trans (by norm_num)
  have hcoef : 4*(C : ℝ)*r ≤ D := by
    dsimp [D,tailCoefficient,cylinderTailCoefficient]
    nlinarith [mul_nonneg (Nat.cast_nonneg C : (0 : ℝ) ≤ C) ha.le,
      mul_nonneg (Nat.cast_nonneg C : (0 : ℝ) ≤ C) hℓ]
  have hlogbound : 2*Real.log 9+(C : ℝ)*Real.log (1024/ρ^2)+2*Real.log 2 ≤ D*(b+1) := by
    rw [hlog]
    have hh := mul_le_mul_of_nonneg_left hl (Nat.cast_nonneg C : (0 : ℝ) ≤ C)
    have hconst := mul_le_mul_of_nonneg_left hl1024 (Nat.cast_nonneg C : (0 : ℝ) ≤ C)
    have hB := mul_le_mul_of_nonneg_right hcoef hb
    dsimp [D,tailCoefficient,cylinderTailCoefficient,a] at hB ⊢
    nlinarith
  apply hlogbound.trans
  apply (le_div_iff₀ (mul_pos (by norm_num) hv)).mpr
  change D*(b+1)*(8*subGaussianVariance ν) ≤ b^2
  have hbdef : b=1+16*subGaussianVariance ν*D := rfl
  rw [hbdef]
  nlinarith [sq_nonneg (subGaussianVariance ν*D),mul_nonneg hv.le hD.le]


end NeuralGeneralization.BatchTwoContinuous.FiniteTarget
