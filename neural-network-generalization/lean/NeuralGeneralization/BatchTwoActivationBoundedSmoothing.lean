import NeuralGeneralization.BatchTwoActivationSmoothing

/-! Clip before smoothing. On the support of the global cutoff this has the
same approximation guarantee, while every scalar observable is globally
bounded. -/
noncomputable section
open MeasureTheory Set
namespace NeuralGeneralization.BatchTwoActivation

def scalarClip (R t : ℝ) : ℝ := max (-R) (min R t)

def clippedActivation (φ : ℝ→ℝ) (R t : ℝ) : ℝ := φ (scalarClip R t)

theorem scalarClip_lipschitz (R : ℝ) : ∀x y, |scalarClip R x-scalarClip R y|≤|x-y| := by
  have h : LipschitzWith 1 (scalarClip R) := (LipschitzWith.id.const_min R).const_max (-R)
  intro x y
  simpa only [Real.dist_eq,NNReal.coe_one,one_mul] using h.dist_le_mul x y

theorem scalarClip_bound {R : ℝ} (hR : 0≤R) (t : ℝ) : |scalarClip R t|≤R := by
  apply abs_le.mpr
  exact ⟨le_max_left _ _,max_le (by linarith) (min_le_left _ _)⟩

theorem scalarClip_eq {R t : ℝ} (ht : |t|≤R) : scalarClip R t=t := by
  have h := abs_le.mp ht
  simp only [scalarClip,min_eq_right h.2,max_eq_right h.1]

theorem clippedActivation_lipschitz {φ : ℝ→ℝ} {ℓ : ℝ} (hℓ : 0≤ℓ)
    (hφ : ∀x y, |φ x-φ y|≤ℓ*|x-y|) (R : ℝ) :
    ∀x y, |clippedActivation φ R x-clippedActivation φ R y|≤ℓ*|x-y| := by
  intro x y
  exact (hφ _ _).trans (mul_le_mul_of_nonneg_left (scalarClip_lipschitz R x y) hℓ)

theorem clippedActivation_bound {φ : ℝ→ℝ} {ℓ R : ℝ} (hℓ : 0≤ℓ) (hR : 0≤R)
    (hφ : zeroLipschitzActivation ℓ φ) (t : ℝ) : |clippedActivation φ R t|≤ℓ*R :=
  (activation_abs_le hφ _).trans (mul_le_mul_of_nonneg_left (scalarClip_bound hR t) hℓ)

theorem boxAverage_bound {φ : ℝ→ℝ} (hc : Continuous φ) {τ B : ℝ} (hτ : 0<τ)
    (hφ : ∀t, |φ t|≤B) (t : ℝ) : |boxAverage φ τ t|≤B := by
  rw [boxAverage_integral hc,abs_div,abs_of_pos (mul_pos (by norm_num) hτ)]
  apply (div_le_iff₀ (mul_pos (by norm_num) hτ)).2
  have h := intervalIntegral.norm_integral_le_of_norm_le_const (f:=φ) (C:=B) (fun u (_ : u∈Set.uIoc (t-τ) (t+τ))=>hφ u)
  rw [Real.norm_eq_abs] at h
  have he : |t+τ-(t-τ)|=2*τ := by rw [show t+τ-(t-τ)=2*τ by ring,abs_of_pos (mul_pos (by norm_num) hτ)]
  rwa [he] at h

theorem smoothActivation_bound {φ : ℝ→ℝ} (hc : Continuous φ) {τ B : ℝ} (hτ : 0<τ)
    (hφ : ∀t, |φ t|≤B) (t : ℝ) : |smoothActivation φ τ t|≤B :=
  boxAverage_bound (boxAverage_continuous hc τ) hτ (boxAverage_bound hc hτ hφ) t

end NeuralGeneralization.BatchTwoActivation
