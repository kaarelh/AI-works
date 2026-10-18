import NeuralGeneralization.RobustCompressionBlockMoments
import NeuralGeneralization.RobustCompressionClipping
import Mathlib.Analysis.Normed.Lp.MeasurableSpace

/-! # Concrete first-layer clipping and its posterior error budget -/

noncomputable section
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators NNReal

namespace NeuralGeneralization.RobustCompressionFirstLayer
open ConcreteModel RobustCompressionBlockMoments RobustCompressionClipping

variable {d N r : ℕ}

def firstRowEvaluation (φ : ℝ → ℝ) (x : Cube d)
    (u : EuclideanSpace ℝ (Fin (d + 1))) : ℝ :=
  φ (∑ j, (u j / Real.sqrt (d : ℝ)) * inputVector x j)

def clippedFirstHidden (φ : ℝ → ℝ) (B : ℝ) (w : Weights d N r)
    (x : Cube d) (i : Fin N) : ℝ :=
  firstRowEvaluation φ x (wholeClip B (firstPhysicalRow w i))

def firstClippingError (φ : ℝ → ℝ) (B : ℝ) (w : Weights d N r) (x : Cube d) : ℝ :=
  (∑ i, (firstHidden φ w x i - clippedFirstHidden φ B w x i) ^ 2) / (N : ℝ)

theorem firstRowEvaluation_actual (hd : 0 < d) (φ : ℝ → ℝ)
    (w : Weights d N r) (x : Cube d) (i : Fin N) :
    firstRowEvaluation φ x (firstPhysicalRow w i) = firstHidden φ w x i := by
  have hs : Real.sqrt (d : ℝ) ≠ 0 := (Real.sqrt_pos.mpr (Nat.cast_pos.mpr hd)).ne'
  unfold firstRowEvaluation firstPhysicalRow firstHidden
  congr 1
  apply Finset.sum_congr rfl
  intro j hj
  change (Real.sqrt (d : ℝ) * w (Sum.inl (i, j)) / Real.sqrt (d : ℝ)) * _ = _
  field_simp

theorem measurable_firstPhysicalRow (i : Fin N) :
    Measurable (fun w : Weights d N r => firstPhysicalRow w i) := by
  unfold firstPhysicalRow
  exact (WithLp.measurable_toLp 2 (Fin (d + 1) → ℝ)).comp (by fun_prop)

theorem measurable_firstRowEvaluation {φ : ℝ → ℝ} (hφ : Measurable φ) (x : Cube d) :
    Measurable (firstRowEvaluation φ x) := by
  unfold firstRowEvaluation
  fun_prop

theorem measurable_clippedFirstHidden {φ : ℝ → ℝ} (hφ : Measurable φ)
    (B : ℝ) (x : Cube d) (i : Fin N) :
    Measurable (fun w : Weights d N r => clippedFirstHidden φ B w x i) :=
  (measurable_firstRowEvaluation hφ x).comp
    ((measurable_wholeClip B).comp (measurable_firstPhysicalRow i))

theorem first_clipping_pointwise (hd : 0 < d) (φ : ℝ → ℝ)
    (hφ : ∀ z, |φ z| ≤ 1) (B : ℝ) (hB : 0 < B)
    (w : Weights d N r) (x : Cube d) :
    firstClippingError φ B w x ≤
      4 * ((∑ i, ‖firstPhysicalRow w i‖ ^ 2) / (N : ℝ)) / B ^ 2 := by
  have hi (i : Fin N) :
      (firstHidden φ w x i - clippedFirstHidden φ B w x i) ^ 2 ≤
        4 * ‖firstPhysicalRow w i‖ ^ 2 / B ^ 2 := by
    have hh := bounded_image_clipping_error (firstRowEvaluation φ x)
      (fun u => hφ _) B hB (firstPhysicalRow w i)
    rwa [firstRowEvaluation_actual hd] at hh
  have hh := Finset.sum_le_sum (fun i (_ : i ∈ Finset.univ) => hi i)
  unfold firstClippingError
  apply (div_le_div_of_nonneg_right hh (Nat.cast_nonneg N)).trans_eq
  rw [← Finset.sum_div, ← Finset.mul_sum]
  ring

theorem first_clipping_error_nonneg (φ : ℝ → ℝ) (B : ℝ) (w : Weights d N r) (x : Cube d) :
    0 ≤ firstClippingError φ B w x := by
  unfold firstClippingError
  positivity

theorem measurable_firstClippingError {φ : ℝ → ℝ} (hφ : Continuous φ)
    (B : ℝ) (x : Cube d) :
    Measurable (fun w : Weights d N r => firstClippingError φ B w x) := by
  unfold firstClippingError
  apply Measurable.div_const
  apply Finset.measurable_sum
  intro i hi
  exact (((continuous_firstHidden hφ x i).measurable).sub
    (measurable_clippedFirstHidden hφ.measurable B x i)).pow_const 2

/-- Actual posterior RMS clipping error at each input.  This expectation does
not condition on a subsequent row-selection event, which could bias the rows.
-/
theorem first_clipping_expected_error (hd : 0 < d) (hN : 0 < N)
    {σ K : ℝ} (hσ : 0 < σ) (hK : 0 ≤ K) (hscale : (N : ℝ) * σ ^ 2 ≤ 1)
    (Q : Measure (Weights d N r)) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (smallPrior d N r σ) ≤ ENNReal.ofReal (K / σ ^ 2))
    {φ : ℝ → ℝ} (hφ : Continuous φ) (hbound : ∀ z, |φ z| ≤ 1)
    (B : ℝ) (hB : 0 < B) (x : Cube d) :
    Integrable (fun w => firstClippingError φ B w x) Q ∧
      (∫ w, firstClippingError φ B w x ∂Q) ≤
        4 * (4 * K + 2 * ((d : ℝ) + 1)) / B ^ 2 := by
  obtain ⟨hi, hm⟩ := first_physical_energy_moment hd hN hσ hK hscale Q hKL
  have hint := (hi.const_mul 4).div_const (B ^ 2)
  have hleft := hint.mono' (measurable_firstClippingError hφ B x).aestronglyMeasurable
    (Filter.Eventually.of_forall (fun w => by
      rw [Real.norm_eq_abs, abs_of_nonneg (first_clipping_error_nonneg φ B w x)]
      exact first_clipping_pointwise hd φ hbound B hB w x))
  refine ⟨hleft, ?_⟩
  have he := integral_mono hleft hint (fun w => first_clipping_pointwise hd φ hbound B hB w x)
  rw [integral_div, integral_const_mul] at he
  exact he.trans (div_le_div_of_nonneg_right
    (mul_le_mul_of_nonneg_left hm (by norm_num)) (sq_nonneg B))

end NeuralGeneralization.RobustCompressionFirstLayer
