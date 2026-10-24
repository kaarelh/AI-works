import NeuralGeneralization.BatchTwoActivationScalarCover
import NeuralGeneralization.BatchTwoActivationReluLayer

/-!
# Algebraic rescaling of nonhomogeneous activations

The Bayesian learner's activation is never changed. These exact identities
construct auxiliary neuron activations when normalizing a network for the
capacity proof. They require only the original Lipschitz and zero-at-zero
assumptions, including for activations without positive homogeneity.
-/

noncomputable section
open scoped RealInnerProductSpace

namespace NeuralGeneralization.BatchTwoActivation

def normalizedScalar (φ : ℝ → ℝ) (ℓ a x : ℝ) : ℝ := φ (a*x)/(ℓ*a)

theorem normalizedScalar_admissible {φ : ℝ → ℝ} {ℓ a : ℝ}
    (hφ : zeroLipschitzActivation ℓ φ) (hℓ : 0 < ℓ) (ha : 0 ≤ a) :
    zeroLipschitzActivation 1 (normalizedScalar φ ℓ a) := by
  refine ⟨by simp [normalizedScalar, hφ.1], ?_⟩
  intro x y
  by_cases haz : a = 0
  · simp [normalizedScalar, haz]
  have ha' : 0 < a := lt_of_le_of_ne ha (Ne.symm haz)
  have hden : 0 < ℓ*a := mul_pos hℓ ha'
  have h := hφ.2 (a*x) (a*y)
  rw [← mul_sub, abs_mul, abs_of_nonneg ha] at h
  change |φ (a*x)/(ℓ*a) - φ (a*y)/(ℓ*a)| ≤ 1*|x-y|
  rw [← sub_div, abs_div, abs_of_pos hden, one_mul]
  apply (div_le_iff₀ hden).2
  calc
    _ ≤ ℓ * (a * |x-y|) := h
    _ = _ := by ring

def normalizedUnitActivation {φ : ℝ → ℝ} {ℓ a : ℝ}
    (hφ : zeroLipschitzActivation ℓ φ) (hℓ : 0 < ℓ) (ha : 0 ≤ a) : UnitActivation :=
  ⟨normalizedScalar φ ℓ a, normalizedScalar_admissible hφ hℓ ha⟩

/-- Exact reconstruction includes a zero row, for which both sides vanish. -/
theorem normalizedScalar_reconstruct {φ : ℝ → ℝ} {ℓ a : ℝ}
    (hφ : zeroLipschitzActivation ℓ φ) (hℓ : 0 < ℓ) (ha : 0 ≤ a) (x : ℝ) :
    φ (a*x) = (ℓ*a) * normalizedScalar φ ℓ a x := by
  by_cases haz : a = 0
  · simp [normalizedScalar, haz, hφ.1]
  · unfold normalizedScalar
    exact (mul_div_cancel₀ _ (mul_ne_zero hℓ.ne' haz)).symm

def rescaledUnitActivation (ψ : UnitActivation) (a : ℝ) (ha : 0 ≤ a) : UnitActivation :=
  normalizedUnitActivation ψ.property (by norm_num : (0:ℝ)<1) ha

theorem rescaledUnitActivation_reconstruct (ψ : UnitActivation) (a : ℝ)
    (ha : 0 ≤ a) (x : ℝ) :
    ψ.val (a*x) = a * (rescaledUnitActivation ψ a ha).val x := by
  change ψ.val (a*x) = a * normalizedScalar ψ.val 1 a x
  simpa only [one_mul] using normalizedScalar_reconstruct ψ.property
    (by norm_num : (0:ℝ)<1) ha x

variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]

/-- Every normalized row has the form needed by the heterogeneous peeling
lemma, even for GELU or an arbitrary nonhomogeneous Lipschitz activation. -/
theorem unitActivation_inner_normalized (ψ : UnitActivation) (w h : E) :
    ψ.val ⟪w,h⟫ = ‖w‖ *
      (rescaledUnitActivation ψ ‖w‖ (norm_nonneg w)).val ⟪unitDirection w,h⟫ := by
  rw [← rescaledUnitActivation_reconstruct ψ ‖w‖ (norm_nonneg w),
    ← real_inner_smul_left, norm_smul_unitDirection]

end NeuralGeneralization.BatchTwoActivation
