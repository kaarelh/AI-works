import NeuralGeneralization.RobustEntropyMoments
import NeuralGeneralization.RobustEntropyChain
import Mathlib.MeasureTheory.Constructions.Pi

/-! # Gaussian entropy second moments at a common physical scale -/
noncomputable section
open MeasureTheory ProbabilityTheory InformationTheory
open scoped ENNReal NNReal
namespace NeuralGeneralization.RobustCoupling

variable {I : Type*} [Fintype I]

def scaledDiagonalGaussian (v : I → ℝ≥0) (t : ℝ) : Measure (I → ℝ) :=
  Measure.pi (fun i => gaussianReal 0 ((t ^ 2).toNNReal * v i))

instance scaledDiagonalGaussian_probability (v : I → ℝ≥0) (t : ℝ) :
    IsProbabilityMeasure (scaledDiagonalGaussian v t) := by
  unfold scaledDiagonalGaussian
  infer_instance

def divideCoordinates (t : ℝ) (w : I → ℝ) : I → ℝ := fun i => t⁻¹ * w i

@[fun_prop] theorem measurable_divideCoordinates (t : ℝ) : Measurable (divideCoordinates (I := I) t) := by
  unfold divideCoordinates
  fun_prop

theorem map_scaledDiagonalGaussian_divide (v : I → ℝ≥0) {t : ℝ} (ht : 0 < t) :
    (scaledDiagonalGaussian v t).map (divideCoordinates t) =
      Measure.pi (fun i => gaussianReal 0 (v i)) := by
  unfold scaledDiagonalGaussian divideCoordinates
  rw [Measure.pi_map_pi (fun i =>
    (show Measurable (fun x : ℝ => t⁻¹ * x) from measurable_const.mul measurable_id).aemeasurable)]
  congr 1
  funext i
  rw [gaussianReal_map_const_mul, mul_zero]
  apply congrArg (gaussianReal 0)
  apply NNReal.eq
  simp only [NNReal.coe_mul, NNReal.coe_mk, Real.coe_toNNReal _ (sq_nonneg _)]
  field_simp

/-- The scale factor multiplies both the KL contribution and the dimension
term. In particular a KL budget proportional to t⁻² gives a uniform physical
second moment as t tends to zero. -/
theorem scaled_gaussian_entropy_second_moment
    (v : I → ℝ≥0) (hv : ∀ i, v i ≤ 1) {t : ℝ} (ht : 0 < t)
    (Q : Measure (I → ℝ)) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (scaledDiagonalGaussian v t) ≠ ⊤) :
    Integrable (fun w : I → ℝ => ∑ i, w i ^ 2) Q ∧
      (∫ w : I → ℝ, ∑ i, w i ^ 2 ∂Q) ≤
        4 * t ^ 2 * (klDiv Q (scaledDiagonalGaussian v t)).toReal +
          2 * t ^ 2 * Fintype.card I := by
  let Q' := Q.map (divideCoordinates t)
  let G := Measure.pi (fun i => gaussianReal 0 (v i))
  letI : IsProbabilityMeasure Q' :=
    Measure.isProbabilityMeasure_map (measurable_divideCoordinates t).aemeasurable
  have hmapKL : klDiv Q' G ≤ klDiv Q (scaledDiagonalGaussian v t) := by
    dsimp only [G]
    rw [← map_scaledDiagonalGaussian_divide v ht]
    exact RobustEntropy.klDiv_map_le _ _ (measurable_divideCoordinates t)
  have hk : klDiv Q' G ≠ ⊤ := ne_top_of_le_ne_top hKL hmapKL
  obtain ⟨hi, hb⟩ := RobustEntropyMoments.bounded_variance_gaussian_entropy_second_moment v hv Q' hk
  have hi' : Integrable (fun w : I → ℝ => ∑ i, (t⁻¹ * w i) ^ 2) Q :=
    hi.comp_measurable (measurable_divideCoordinates t)
  have hform (w : I → ℝ) : (∑ i, (t⁻¹ * w i) ^ 2) = t⁻¹ ^ 2 * ∑ i, w i ^ 2 := by
    simp [mul_pow, Finset.mul_sum]
  have hcancel : t ^ 2 * t⁻¹ ^ 2 = 1 := by field_simp
  have hiQ : Integrable (fun w : I → ℝ => ∑ i, w i ^ 2) Q := by
    convert hi'.const_mul (t ^ 2) using 1
    funext w
    rw [hform, ← mul_assoc, hcancel, one_mul]
  refine ⟨hiQ, ?_⟩
  change (∫ w, ∑ i, w i ^ 2 ∂Q.map (divideCoordinates t)) ≤ _ at hb
  have hm : Measurable (fun w : I → ℝ => ∑ i, w i ^ 2) := by fun_prop
  rw [integral_map (measurable_divideCoordinates t).aemeasurable hm.aestronglyMeasurable] at hb
  change (∫ w, ∑ i, (t⁻¹ * w i) ^ 2 ∂Q) ≤ _ at hb
  simp_rw [hform] at hb
  rw [integral_const_mul] at hb
  have hb' := mul_le_mul_of_nonneg_left hb (sq_nonneg t)
  rw [← mul_assoc, hcancel, one_mul] at hb'
  have hkr := ENNReal.toReal_mono hKL hmapKL
  have hk' := mul_le_mul_of_nonneg_left hkr (by positivity : 0 ≤ 4 * t ^ 2)
  nlinarith

end NeuralGeneralization.RobustCoupling
