import NeuralGeneralization.RobustCompressionSampling
import Mathlib.Analysis.InnerProductSpace.PiL2

/-!
# Whole-vector clipping for finite source reconstruction

Clipping removes an entire source vector. Consequently its second moment only
decreases, while its first-moment error is controlled by its original second
moment divided by the clipping radius. No coordinatewise tail or width union
bound is used.
-/
noncomputable section
open scoped BigOperators RealInnerProductSpace

namespace NeuralGeneralization.RobustCompressionClipping

variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]

def wholeClip (T : ℝ) (v : E) : E := if ‖v‖ ≤ T then v else 0

theorem wholeClip_norm_le (T : ℝ) (hT : 0 ≤ T) (v : E) :
    ‖wholeClip T v‖ ≤ T := by
  unfold wholeClip
  split_ifs with h
  · exact h
  · simpa using hT

theorem norm_sub_wholeClip_le_sq_div (T : ℝ) (hT : 0 < T) (v : E) :
    ‖v - wholeClip T v‖ ≤ ‖v‖ ^ 2 / T := by
  unfold wholeClip
  split_ifs with h
  · simp only [sub_self, norm_zero]
    positivity
  · simp only [sub_zero]
    apply (le_div_iff₀ hT).mpr
    nlinarith [norm_nonneg v, lt_of_not_ge h]

/-- A literal uniform average of vectors. -/
def finiteAverage {N : ℕ} (f : Fin N → E) : E :=
  (N : ℝ)⁻¹ • ∑ i, f i

theorem norm_finiteAverage_le {N : ℕ} (f : Fin N → E) :
    ‖finiteAverage f‖ ≤ (∑ i, ‖f i‖) / (N : ℝ) := by
  unfold finiteAverage
  rw [norm_smul, Real.norm_eq_abs, abs_of_nonneg (inv_nonneg.mpr (Nat.cast_nonneg N))]
  calc
    (N : ℝ)⁻¹ * ‖∑ i, f i‖ ≤ (N : ℝ)⁻¹ * ∑ i, ‖f i‖ := by
      gcongr
      exact norm_sum_le _ _
    _ = _ := by ring

theorem clipped_average_error {N : ℕ} (u : Fin N → E) (h : Fin N → ℝ)
    (hh : ∀ i, |h i| ≤ 1) (T : ℝ) (hT : 0 < T) :
    ‖finiteAverage (fun i => h i • u i) -
        finiteAverage (fun i => h i • wholeClip T (u i))‖ ≤
      ((∑ i, ‖u i‖ ^ 2) / (N : ℝ)) / T := by
  have heq : finiteAverage (fun i => h i • u i) -
      finiteAverage (fun i => h i • wholeClip T (u i)) =
      finiteAverage (fun i => h i • (u i - wholeClip T (u i))) := by
    simp [finiteAverage, smul_sub, Finset.sum_sub_distrib]
  rw [heq]
  calc
    _ ≤ (∑ i, ‖h i • (u i - wholeClip T (u i))‖) / (N : ℝ) :=
      norm_finiteAverage_le _
    _ ≤ (∑ i, ‖u i‖ ^ 2 / T) / (N : ℝ) := by
      apply div_le_div_of_nonneg_right _ (Nat.cast_nonneg N)
      apply Finset.sum_le_sum
      intro i hi
      rw [norm_smul, Real.norm_eq_abs]
      calc
        |h i| * ‖u i - wholeClip T (u i)‖ ≤
            1 * ‖u i - wholeClip T (u i)‖ :=
          mul_le_mul_of_nonneg_right (hh i) (norm_nonneg _)
        _ ≤ _ := by simpa using norm_sub_wholeClip_le_sq_div T hT (u i)
    _ = _ := by rw [← Finset.sum_div]; ring

section Inner

theorem inner_wholeClip_sq_le (T : ℝ) (u v : E) :
    ⟪wholeClip T u, v⟫ ^ 2 ≤ ⟪u, v⟫ ^ 2 := by
  unfold wholeClip
  split_ifs
  · exact le_rfl
  · simpa using sq_nonneg ⟪u, v⟫

theorem clipped_secondMoment_le {N : ℕ} (u : Fin N → E) (T : ℝ) (v : E) :
    (∑ i, ⟪wholeClip T (u i), v⟫ ^ 2) / (N : ℝ) ≤
      (∑ i, ⟪u i, v⟫ ^ 2) / (N : ℝ) := by
  apply div_le_div_of_nonneg_right _ (Nat.cast_nonneg N)
  exact Finset.sum_le_sum (fun i _ => inner_wholeClip_sq_le T (u i) v)

end Inner

/-- The clipping map is measurable even at the cutoff sphere. -/
theorem measurable_wholeClip [MeasurableSpace E] [BorelSpace E] (T : ℝ) :
    Measurable (wholeClip (E := E) T) := by
  unfold wholeClip
  exact measurable_id.ite
    (measurableSet_le measurable_norm measurable_const) measurable_const

/-- For a bounded activation, deleting a large row costs its squared norm
relative to the threshold. The row may encode arbitrary active coordinates. -/
theorem bounded_image_clipping_error (f : E → ℝ) (hf : ∀ v, |f v| ≤ 1)
    (T : ℝ) (hT : 0 < T) (v : E) :
    (f v - f (wholeClip T v)) ^ 2 ≤ 4 * ‖v‖ ^ 2 / T ^ 2 := by
  unfold wholeClip
  split_ifs with h
  · simp only [sub_self, zero_pow (by norm_num : 2 ≠ 0)]
    positivity
  · have habs : |f v - f 0| ≤ 2 := by
      calc
        |f v - f 0| ≤ |f v| + |f 0| := abs_sub _ _
        _ ≤ 2 := by linarith [hf v, hf 0]
    have hsq : (f v - f 0) ^ 2 ≤ 4 := by
      nlinarith [sq_abs (f v - f 0), abs_nonneg (f v - f 0)]
    have htv : T ^ 2 ≤ ‖v‖ ^ 2 := by
      nlinarith [norm_nonneg v, lt_of_not_ge h]
    apply (le_div_iff₀ (sq_pos_of_pos hT)).mpr
    nlinarith [mul_le_mul_of_nonneg_right hsq (sq_nonneg T)]

end NeuralGeneralization.RobustCompressionClipping
