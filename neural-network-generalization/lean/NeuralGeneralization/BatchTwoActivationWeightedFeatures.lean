import NeuralGeneralization.BatchTwoActivationBulkRealization
import NeuralGeneralization.BatchTwoActivationResidualAtoms

/-! Finite weighted feature covariances are realized by ordinary feedforward
weights. The Gaussian source coordinates and source dual certificates become
fixed weights; neither is evaluated as an input-dependent rule. -/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoActivation
open FiniteDifferential GaussianAngularPrice
variable {I J : Type*} [Fintype I] [Fintype J]

def weightedFeatureGram (h : J → I → ℝ) (c : J → ℝ) (i k : I) : ℝ :=
  ∑j,c j*h j i*h j k

def weightedFeatureSource (h : J → I → ℝ) (c : J → ℝ) (i : I) (j : J) : ℝ :=
  Real.sqrt (c j)*h j i

theorem weightedFeatureSource_gram (h : J → I → ℝ) (c : J → ℝ)
    (hc : ∀j,0≤c j) (i k : I) :
    gram (weightedFeatureSource h c) i k = weightedFeatureGram h c i k := by
  unfold gram weightedFeatureSource weightedFeatureGram
  apply Finset.sum_congr rfl
  intro j hj
  have hs := Real.sq_sqrt (hc j)
  calc
    _ = (Real.sqrt (c j))^2*h j i*h j k := by ring
    _ = _ := by rw [hs]

theorem weightedFeatureSource_action (h : J → I → ℝ) (c ξ : J → ℝ) (i : I) :
    fieldLinear (weightedFeatureSource h c) ξ i =
      ∑j,(Real.sqrt (c j)*ξ j)*h j i := by
  simp only [fieldLinear_apply,weightedFeatureSource]
  apply Finset.sum_congr rfl
  intro j hj
  ring

theorem weightedFeatureSource_weight_bound (c ξ : J → ℝ) {V R : ℝ}
    (hV : 0≤V) (hc : ∀j,c j≤V) (hξ : ∀j,|ξ j|≤R) (j : J) :
    |Real.sqrt (c j)*ξ j|≤Real.sqrt V*R := by
  rw [abs_mul,abs_of_nonneg (Real.sqrt_nonneg _)]
  exact mul_le_mul (Real.sqrt_le_sqrt (hc j)) (hξ j) (abs_nonneg _) (Real.sqrt_nonneg _)

theorem finite_feature_evaluation_bound (h : J → I → ℝ) (w : J → ℝ)
    {φ : ℝ → ℝ} {ℓ B W : ℝ} (hφ : zeroLipschitzActivation ℓ φ)
    (hℓ : 0≤ℓ) (hB : 0≤B) (hW : 0≤W) (hh : ∀j i,|h j i|≤B)
    (hw : ∀j,|w j|≤W) (i : I) :
    |φ (∑j,w j*h j i)|≤ℓ*(Fintype.card J:ℝ)*W*B := by
  apply (activation_abs_le hφ _).trans
  have hs : |∑j,w j*h j i|≤(Fintype.card J:ℝ)*W*B := by
    calc
      _ ≤ ∑j,|w j*h j i| := Finset.abs_sum_le_sum_abs _ _
      _ ≤ ∑_j : J,W*B := by
        apply Finset.sum_le_sum
        intro j hj
        rw [abs_mul]
        exact mul_le_mul (hw j) (hh j i) (abs_nonneg _) hW
      _ = _ := by simp; ring
  have hm := mul_le_mul_of_nonneg_left hs hℓ
  nlinarith

theorem cutoff_covariance_coefficient_bounds [Nonempty I] [DecidableEq I] {N : ℕ} (hN : 0<N) (a T : ℝ) (z : I → ℝ) :
    0≤(smoothCutoff a T z)^2/(N:ℝ) ∧ (smoothCutoff a T z)^2/(N:ℝ)≤1 := by
  have hr := smoothCutoff_bounds a T z
  have hn : (1:ℝ)≤N := Nat.one_le_cast.mpr hN
  constructor
  · positivity
  · apply (div_le_iff₀ (Nat.cast_pos.mpr hN)).2
    nlinarith

theorem constant_covariance_coefficient_bounds {N : ℕ} (hN : 0<N) {A : ℝ} (hA : 0≤A) :
    0≤A/(N:ℝ) ∧ A/(N:ℝ)≤A := by
  have hn : (1:ℝ)≤N := Nat.one_le_cast.mpr hN
  constructor
  · positivity
  · apply (div_le_iff₀ (Nat.cast_pos.mpr hN)).2
    nlinarith

end NeuralGeneralization.BatchTwoActivation
