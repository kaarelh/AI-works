import NeuralGeneralization.GaussianMarginHeadBound

/-! # Exact sampled Fourier-band matrix conventions -/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators
namespace NeuralGeneralization.GaussianSampleBand
open GaussianBandEnergy GaussianMarginHeadBound FiniteDifferential GaussianAngularPrice
variable {d : ℕ} {J : Type*} [Fintype J]

def sampleMatrix (w : Finset (Fin d) → ℝ) (H : Finset (Finset (Fin d)))
    (s : J → ClippingCube d) : J → Finset (Fin d) → ℝ :=
  fun j S => if S ∈ H then Real.sqrt (w S)*walshCharacter S (s j) else 0

lemma sampleMatrix_field (w : Finset (Fin d) → ℝ) (H : Finset (Finset (Fin d)))
    (s : J → ClippingCube d) (z : Finset (Fin d) → ℝ) (j : J) :
    fieldLinear (sampleMatrix w H s) z j =
      walshProjection H (fieldLinear (WalshGaussianEnergy.matrix w) z) (s j) := by
  classical
  rw [field_eq_expansion]
  unfold walshProjection
  rw [show walshCoefficients (walshExpansion (fun S => Real.sqrt (w S)*z S)) =
    (fun S => Real.sqrt (w S)*z S) from funext (walshCoefficients_expansion _)]
  rw [fieldLinear_apply]
  unfold walshExpansion sampleMatrix maskCoefficients
  apply Finset.sum_congr rfl
  intro S hS
  by_cases hS : S ∈ H <;> simp [hS] <;> ring

lemma sampleMatrix_gram (w : Finset (Fin d) → ℝ) (hw : ∀ S, 0 ≤ w S)
    (H : Finset (Finset (Fin d))) (s : J → ClippingCube d) (i j : J) :
    gram (sampleMatrix w H s) i j = walshTailKernel H w (s i) (s j) := by
  classical
  unfold gram walshTailKernel sampleMatrix
  rw [← Fintype.sum_ite_mem H (fun S => w S*walshCharacter S (s i)*walshCharacter S (s j))]
  apply Finset.sum_congr rfl
  intro S hS
  by_cases hS : S ∈ H
  · simp only [if_pos hS]
    calc
      _ = (Real.sqrt (w S))^2*walshCharacter S (s i)*walshCharacter S (s j) := by ring
      _ = _ := by rw [Real.sq_sqrt (hw S)]
  · simp [hS]

lemma sampleMatrix_trace (w : Finset (Fin d) → ℝ) (hw : ∀ S, 0 ≤ w S)
    (H : Finset (Finset (Fin d))) (s : J → ClippingCube d) :
    (∑ j, ∑ S, sampleMatrix w H s j S^2) = (Fintype.card J:ℝ)*(∑ S ∈ H, w S) := by
  classical
  have hi (j : J) : (∑ S, sampleMatrix w H s j S^2) = ∑ S ∈ H, w S := by
    unfold sampleMatrix
    simp_rw [ite_pow, mul_pow, Real.sq_sqrt (hw _), walshCharacter_sq, mul_one]
    simp
  simp [hi]

lemma sampleBandEnergy_field (w : Finset (Fin d) → ℝ) (H : Finset (Finset (Fin d)))
    (s : J → ClippingCube d) (z : Finset (Fin d) → ℝ) :
    sampleBandEnergy H s (fieldLinear (WalshGaussianEnergy.matrix w) z) =
      ∑ j, fieldLinear (sampleMatrix w H s) z j^2 := by
  simp only [sampleBandEnergy, sampleMatrix_field]

@[fun_prop] lemma measurable_sampleBandEnergy (H : Finset (Finset (Fin d)))
    (s : J → ClippingCube d) : Measurable (sampleBandEnergy H s) := by
  classical
  have hm (j : J) : Measurable (fun z : ClippingCube d → ℝ => walshProjection H z (s j)) := by
    unfold walshProjection walshExpansion
    apply Finset.measurable_sum
    intro S hS
    by_cases hS : S ∈ H
    · simp only [maskCoefficients, if_pos hS]
      unfold walshCoefficients uniformCubeMean
      fun_prop
    · simp only [maskCoefficients, if_neg hS, zero_mul]
      exact measurable_const
  exact Finset.measurable_sum _ (fun j _ => (hm j).pow_const 2)

end NeuralGeneralization.GaussianSampleBand
