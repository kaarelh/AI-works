import NeuralGeneralization.BatchTwoActivationSmoothCutoff
import NeuralGeneralization.BatchTwoActivationBoundedSmoothing
import NeuralGeneralization.BatchTwoActivationCoordinateJet
import NeuralGeneralization.BatchTwoActivationJetAlgebra

/-! Actual bounded C² row features for every globally Lipschitz activation.
Clipping precedes C² smoothing; on the support of the global row cutoff the
clipped and original activations agree. -/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoActivation
variable {I : Type*} [Fintype I] [Nonempty I] [DecidableEq I]

def boundedActivationJet {φ : ℝ→ℝ} {ℓ T τ : ℝ} (hℓ : 0≤ℓ) (hT : 0<T) (hτ : 0<τ)
    (hφ : zeroLipschitzActivation ℓ φ) (p : I) :
    BoundedJet I (4*ℓ*T) ℓ (ℓ/τ) := by
  let ψ := clippedActivation φ (4*T)
  have hl : ∀x y, |ψ x-ψ y|≤ℓ*|x-y| := clippedActivation_lipschitz hℓ hφ.2 _
  have hc := real_lipschitz_continuous hℓ hl
  apply coordinateJet (smoothActivation ψ τ) (smoothActivationFirst ψ τ)
    (smoothActivationSecond ψ τ) (smoothActivation_hasDerivAt hc τ)
    (smoothActivationFirst_hasDerivAt hc τ) (smoothActivationSecond_continuous hc τ)
    _ (smoothActivationFirst_bound hℓ hτ hl) (smoothActivationSecond_bound hτ hl) p
  intro t
  have hb : ∀t,|ψ t|≤4*ℓ*T := fun t=>by
    have h := clippedActivation_bound hℓ (by positivity : 0≤4*T) hφ t
    nlinarith
  exact smoothActivation_bound hc hτ hb t

def cutoffFeatureJet {φ : ℝ→ℝ} {ℓ a T τ B : ℝ} (hℓ : 0≤ℓ)
    (ha : 0<a) (hT : 0<T) (hτ : 0<τ) (hB : 0≤B)
    (hφ : zeroLipschitzActivation ℓ φ)
    (hb : ∀t,|deriv scalarCutoff t|≤B) (hbb : ∀t,|deriv (deriv scalarCutoff) t|≤B)
    (p : I) :
    BoundedJet I (1*(4*ℓ*T)) ((B/T)*(4*ℓ*T)+1*ℓ)
      ((B/T^2+2*a*B/T)*(4*ℓ*T)+2*(B/T)*ℓ+1*(ℓ/τ)) :=
  (smoothCutoffJet ha hT hB hb hbb).mul (boundedActivationJet hℓ hT hτ hφ p)
    (by norm_num) (by positivity) (by positivity) (by positivity)

def actualCutoffFeature (φ : ℝ→ℝ) (a T : ℝ) (p : I) (z : I→ℝ) : ℝ :=
  smoothCutoff a T z*φ (z p)

theorem actualCutoffFeature_bound {φ : ℝ→ℝ} {ℓ a T : ℝ} (hℓ : 0≤ℓ)
    (ha : 0<a) (hT : 0<T) (hφ : zeroLipschitzActivation ℓ φ)
    (p : I) (z : I→ℝ) : |actualCutoffFeature φ a T p z|≤4*ℓ*T := by
  by_cases hz : |z p|≤4*T
  · have hφb := (activation_abs_le hφ (z p)).trans (mul_le_mul_of_nonneg_left hz hℓ)
    unfold actualCutoffFeature
    rw [abs_mul,abs_of_nonneg (smoothCutoff_bounds a T z).1]
    calc
      _ ≤ 1*(ℓ*(4*T)) := mul_le_mul (smoothCutoff_bounds a T z).2 hφb (abs_nonneg _) (by norm_num)
      _ = _ := by ring
  · have hr := smoothCutoff_eq_zero ha hT z p (le_of_not_ge hz)
    simp only [actualCutoffFeature,hr,zero_mul,abs_zero]
    positivity

theorem cutoffFeature_approximation {φ : ℝ→ℝ} {ℓ a T τ B : ℝ} (hℓ : 0≤ℓ)
    (ha : 0<a) (hT : 0<T) (hτ : 0<τ) (hB : 0≤B)
    (hφ : zeroLipschitzActivation ℓ φ)
    (hb : ∀t,|deriv scalarCutoff t|≤B) (hbb : ∀t,|deriv (deriv scalarCutoff) t|≤B)
    (p : I) (z : I→ℝ) :
    |(cutoffFeatureJet hℓ ha hT hτ hB hφ hb hbb p).value z-actualCutoffFeature φ a T p z|≤2*ℓ*τ := by
  change |smoothCutoff a T z*smoothActivation (clippedActivation φ (4*T)) τ (z p)-
    smoothCutoff a T z*φ (z p)|≤_
  by_cases hz : |z p|≤4*T
  · have he : clippedActivation φ (4*T) (z p)=φ (z p) := by rw [clippedActivation,scalarClip_eq hz]
    have herr := smoothActivation_approximation hℓ hτ (clippedActivation_lipschitz hℓ hφ.2 (4*T)) (z p)
    rw [he] at herr
    rw [←mul_sub,abs_mul,abs_of_nonneg (smoothCutoff_bounds a T z).1]
    apply (mul_le_mul (smoothCutoff_bounds a T z).2 herr (abs_nonneg _) (by norm_num : (0:ℝ)≤1)).trans
    simp
  · have hr := smoothCutoff_eq_zero ha hT z p (le_of_not_ge hz)
    simp only [hr,zero_mul,sub_zero,abs_zero]
    positivity

theorem cutoffFeature_covariance_approximation {φ : ℝ→ℝ} {ℓ a T τ B : ℝ} (hℓ : 0≤ℓ)
    (ha : 0<a) (hT : 0<T) (hτ : 0<τ) (hB : 0≤B)
    (hφ : zeroLipschitzActivation ℓ φ)
    (hb : ∀t,|deriv scalarCutoff t|≤B) (hbb : ∀t,|deriv (deriv scalarCutoff) t|≤B)
    (p q : I) (z : I→ℝ) :
    |(cutoffFeatureJet hℓ ha hT hτ hB hφ hb hbb p).value z*
      (cutoffFeatureJet hℓ ha hT hτ hB hφ hb hbb q).value z-
      actualCutoffFeature φ a T p z*actualCutoffFeature φ a T q z|≤16*ℓ^2*T*τ := by
  let F := cutoffFeatureJet (I:=I) hℓ ha hT hτ hB hφ hb hbb
  have hp := cutoffFeature_approximation hℓ ha hT hτ hB hφ hb hbb p z
  have hq := cutoffFeature_approximation hℓ ha hT hτ hB hφ hb hbb q z
  have hv := (F q).value_bound z
  have hw := actualCutoffFeature_bound hℓ ha hT hφ p z
  change |(F p).value z*(F q).value z-actualCutoffFeature φ a T p z*actualCutoffFeature φ a T q z|≤_
  have he : (F p).value z*(F q).value z-actualCutoffFeature φ a T p z*actualCutoffFeature φ a T q z=
    ((F p).value z-actualCutoffFeature φ a T p z)*(F q).value z+
      actualCutoffFeature φ a T p z*((F q).value z-actualCutoffFeature φ a T q z) := by ring
  rw [he]
  apply (abs_add_le _ _).trans
  rw [abs_mul,abs_mul]
  have h₁ := mul_le_mul hp hv (abs_nonneg _) (by positivity : (0:ℝ)≤2*ℓ*τ)
  have h₂ := mul_le_mul hw hq (abs_nonneg _) (by positivity : (0:ℝ)≤4*ℓ*T)
  nlinarith

end NeuralGeneralization.BatchTwoActivation
