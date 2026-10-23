import NeuralGeneralization.BatchTwoActivationStatements
import Mathlib.MeasureTheory.Integral.IntervalIntegral.FundThmCalculus
import Mathlib.Analysis.Calculus.MeanValue

/-! Quantitative C² smoothing by averaging twice over intervals. This avoids
any differentiability assumption on the original activation. -/
noncomputable section
open MeasureTheory Set
namespace NeuralGeneralization.BatchTwoActivation

def boxAverage (φ : ℝ→ℝ) (τ t : ℝ) : ℝ :=
  ((∫u in (0:ℝ)..t+τ, φ u)-(∫u in (0:ℝ)..t-τ, φ u))/(2*τ)

def boxDifference (φ : ℝ→ℝ) (τ t : ℝ) : ℝ := (φ (t+τ)-φ (t-τ))/(2*τ)

def smoothActivation (φ : ℝ→ℝ) (τ : ℝ) : ℝ→ℝ := boxAverage (boxAverage φ τ) τ

theorem real_lipschitz_continuous {ℓ : ℝ} (hℓ : 0≤ℓ) {φ : ℝ→ℝ}
    (hφ : ∀x y, |φ x-φ y|≤ℓ*|x-y|) : Continuous φ := by
  have h : LipschitzWith ⟨ℓ,hℓ⟩ φ := by
    apply LipschitzWith.of_dist_le_mul
    intro x y
    change |φ x-φ y|≤ℓ*|x-y|
    exact hφ x y
  exact h.continuous

theorem boxAverage_integral {φ : ℝ→ℝ} (hφ : Continuous φ) (τ t : ℝ) :
    boxAverage φ τ t=(∫u in t-τ..t+τ,φ u)/(2*τ) := by
  unfold boxAverage
  rw [intervalIntegral.integral_interval_sub_left (hφ.intervalIntegrable _ _) (hφ.intervalIntegrable _ _)]

theorem boxAverage_hasDerivAt {φ : ℝ→ℝ} (hφ : Continuous φ) (τ t : ℝ) :
    HasDerivAt (boxAverage φ τ) (boxDifference φ τ t) t := by
  have hp := (hφ.integral_hasStrictDerivAt 0 (t+τ)).hasDerivAt.comp t ((hasDerivAt_id t).add_const τ)
  have hm := (hφ.integral_hasStrictDerivAt 0 (t-τ)).hasDerivAt.comp t ((hasDerivAt_id t).sub_const τ)
  unfold boxAverage boxDifference
  simpa only [Function.comp_def,mul_one,Pi.sub_apply,id_eq] using (hp.sub hm).div_const (2*τ)

theorem boxAverage_continuous {φ : ℝ→ℝ} (hφ : Continuous φ) (τ : ℝ) :
    Continuous (boxAverage φ τ) :=
  continuous_iff_continuousAt.mpr (fun t=>(boxAverage_hasDerivAt hφ τ t).continuousAt)

theorem boxDifference_bound {φ : ℝ→ℝ} {ℓ τ : ℝ} (hτ : 0<τ)
    (hφ : ∀x y, |φ x-φ y|≤ℓ*|x-y|) (t : ℝ) : |boxDifference φ τ t|≤ℓ := by
  unfold boxDifference
  rw [abs_div,abs_of_pos (mul_pos (by norm_num) hτ)]
  apply (div_le_iff₀ (mul_pos (by norm_num) hτ)).2
  have h := hφ (t+τ) (t-τ)
  have he : t+τ-(t-τ)=2*τ := by ring
  rwa [he,abs_of_pos (mul_pos (by norm_num) hτ)] at h

theorem boxAverage_lipschitz {φ : ℝ→ℝ} {ℓ τ : ℝ} (hℓ : 0≤ℓ) (hτ : 0<τ)
    (hφ : ∀x y, |φ x-φ y|≤ℓ*|x-y|) :
    ∀x y, |boxAverage φ τ x-boxAverage φ τ y|≤ℓ*|x-y| := by
  have hc := real_lipschitz_continuous hℓ hφ
  have h : LipschitzWith ⟨ℓ,hℓ⟩ (boxAverage φ τ) := by
    apply lipschitzWith_of_nnnorm_deriv_le (fun t=>(boxAverage_hasDerivAt hc τ t).differentiableAt)
    intro t
    change |deriv (boxAverage φ τ) t|≤ℓ
    rw [(boxAverage_hasDerivAt hc τ t).deriv]
    exact boxDifference_bound hτ hφ t
  intro x y
  exact h.dist_le_mul x y

theorem boxAverage_approximation {φ : ℝ→ℝ} {ℓ τ : ℝ} (hℓ : 0≤ℓ) (hτ : 0<τ)
    (hφ : ∀x y, |φ x-φ y|≤ℓ*|x-y|) (t : ℝ) : |boxAverage φ τ t-φ t|≤ℓ*τ := by
  have hc := real_lipschitz_continuous hℓ hφ
  have he : boxAverage φ τ t-φ t=(∫u in t-τ..t+τ,(φ u-φ t))/(2*τ) := by
    rw [boxAverage_integral hc,intervalIntegral.integral_sub (hc.intervalIntegrable _ _) intervalIntegrable_const]
    simp only [intervalIntegral.integral_const,smul_eq_mul]
    field_simp
    ring
  rw [he,abs_div,abs_of_pos (mul_pos (by norm_num) hτ)]
  apply (div_le_iff₀ (mul_pos (by norm_num) hτ)).2
  have hb : ∀u∈Set.uIoc (t-τ) (t+τ), ‖φ u-φ t‖≤ℓ*τ := by
    intro u hu
    have hu' : t-τ<u ∧ u≤t+τ := by simpa only [Set.uIoc_of_le (by linarith : t-τ≤t+τ),Set.mem_Ioc] using hu
    have habs : |u-t|≤τ := abs_le.mpr ⟨by linarith,by linarith⟩
    exact (hφ u t).trans (mul_le_mul_of_nonneg_left habs hℓ)
  have h := intervalIntegral.norm_integral_le_of_norm_le_const hb
  rw [Real.norm_eq_abs] at h
  have ht : |t+τ-(t-τ)|=2*τ := by rw [show t+τ-(t-τ)=2*τ by ring,abs_of_pos (mul_pos (by norm_num) hτ)]
  rwa [ht] at h


def smoothActivationFirst (φ : ℝ→ℝ) (τ : ℝ) : ℝ→ℝ := boxDifference (boxAverage φ τ) τ

def smoothActivationSecond (φ : ℝ→ℝ) (τ : ℝ) : ℝ→ℝ := boxDifference (boxDifference φ τ) τ

theorem smoothActivation_hasDerivAt {φ : ℝ→ℝ} (hφ : Continuous φ) (τ t : ℝ) :
    HasDerivAt (smoothActivation φ τ) (smoothActivationFirst φ τ t) t :=
  boxAverage_hasDerivAt (boxAverage_continuous hφ τ) τ t

theorem smoothActivationFirst_hasDerivAt {φ : ℝ→ℝ} (hφ : Continuous φ) (τ t : ℝ) :
    HasDerivAt (smoothActivationFirst φ τ) (smoothActivationSecond φ τ t) t := by
  have hp := (boxAverage_hasDerivAt hφ τ (t+τ)).comp t ((hasDerivAt_id t).add_const τ)
  have hm := (boxAverage_hasDerivAt hφ τ (t-τ)).comp t ((hasDerivAt_id t).sub_const τ)
  unfold smoothActivationFirst smoothActivationSecond boxDifference
  simpa only [Function.comp_def,mul_one,boxDifference,Pi.sub_apply,id_eq] using (hp.sub hm).div_const (2*τ)

theorem smoothActivationSecond_continuous {φ : ℝ→ℝ} (hφ : Continuous φ) (τ : ℝ) :
    Continuous (smoothActivationSecond φ τ) := by
  unfold smoothActivationSecond boxDifference
  fun_prop

theorem smoothActivationFirst_bound {φ : ℝ→ℝ} {ℓ τ : ℝ} (hℓ : 0≤ℓ) (hτ : 0<τ)
    (hφ : ∀x y, |φ x-φ y|≤ℓ*|x-y|) (t : ℝ) : |smoothActivationFirst φ τ t|≤ℓ :=
  boxDifference_bound hτ (boxAverage_lipschitz hℓ hτ hφ) t

theorem smoothActivationSecond_bound {φ : ℝ→ℝ} {ℓ τ : ℝ} (hτ : 0<τ)
    (hφ : ∀x y, |φ x-φ y|≤ℓ*|x-y|) (t : ℝ) : |smoothActivationSecond φ τ t|≤ℓ/τ := by
  unfold smoothActivationSecond boxDifference
  rw [abs_div,abs_of_pos (mul_pos (by norm_num) hτ)]
  apply (div_le_iff₀ (mul_pos (by norm_num) hτ)).2
  calc
    _ ≤ |boxDifference φ τ (t+τ)|+|boxDifference φ τ (t-τ)| := abs_sub _ _
    _ ≤ ℓ+ℓ := add_le_add (boxDifference_bound hτ hφ _) (boxDifference_bound hτ hφ _)
    _ = ℓ/τ*(2*τ) := by field_simp; ring

theorem smoothActivation_approximation {φ : ℝ→ℝ} {ℓ τ : ℝ} (hℓ : 0≤ℓ) (hτ : 0<τ)
    (hφ : ∀x y, |φ x-φ y|≤ℓ*|x-y|) (t : ℝ) : |smoothActivation φ τ t-φ t|≤2*ℓ*τ := by
  have h₁ := boxAverage_approximation hℓ hτ (boxAverage_lipschitz hℓ hτ hφ) t
  have h₂ := boxAverage_approximation hℓ hτ hφ t
  calc
    _ ≤ |boxAverage (boxAverage φ τ) τ t-boxAverage φ τ t|+|boxAverage φ τ t-φ t| :=
      abs_sub_le _ _ _
    _ ≤ ℓ*τ+ℓ*τ := add_le_add h₁ h₂
    _ = _ := by ring

theorem smoothActivation_growth {φ : ℝ→ℝ} {ℓ τ : ℝ} (hℓ : 0≤ℓ) (hτ : 0<τ)
    (hφ : zeroLipschitzActivation ℓ φ) (t : ℝ) : |smoothActivation φ τ t|≤ℓ*(|t|+2*τ) := by
  have h₁ := smoothActivation_approximation hℓ hτ hφ.2 t
  have h₂ := activation_abs_le hφ t
  calc
    _ ≤ |smoothActivation φ τ t-φ t|+|φ t| := by simpa only [sub_zero] using abs_sub_le (smoothActivation φ τ t) (φ t) 0
    _ ≤ 2*ℓ*τ+ℓ*|t| := add_le_add h₁ h₂
    _ = _ := by ring

end NeuralGeneralization.BatchTwoActivation
