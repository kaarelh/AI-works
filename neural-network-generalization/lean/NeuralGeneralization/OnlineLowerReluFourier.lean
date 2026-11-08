import Mathlib.Analysis.SpecialFunctions.Trigonometric.Bounds
import Mathlib.Analysis.SpecialFunctions.ImproperIntegrals
import Mathlib.MeasureTheory.Measure.Haar.NormedSpace
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Positivity
import Mathlib.Tactic.FunProp

/-!
# A positive integral representation of the absolute value and ReLU

The normalization is defined by a convergent positive integral. Its exact
value (pi) is unnecessary for the online lower bound: the same constant
occurs in every balanced and unbalanced Fourier comparison and cancels.
-/

noncomputable section

namespace NeuralGeneralization.OnlineLowerRelu

open MeasureTheory Set

/-- The cosine difference kernel; division by zero gives value zero at the
single null point `t = 0`. -/
def cosineKernel (z t : ℝ) : ℝ := (1 - Real.cos (t * z)) / t ^ 2

/-- The common positive normalization for the absolute-value Fourier
representation. -/
def fourierAbsConstant : ℝ := ∫ t : ℝ, cosineKernel 1 t

theorem cosineKernel_nonneg (z t : ℝ) : 0 ≤ cosineKernel z t := by
  exact div_nonneg (sub_nonneg.mpr (Real.cos_le_one _)) (sq_nonneg _)

/-- A global integrable Cauchy-density majorant. -/
theorem cosineKernel_one_le (t : ℝ) :
    cosineKernel 1 t ≤ 4 * (1 + t ^ 2)⁻¹ := by
  by_cases ht : t = 0
  · simp [cosineKernel, ht]
  have ht2 : 0 < t ^ 2 := sq_pos_of_ne_zero ht
  have hd : 0 < 1 + t ^ 2 := by positivity
  have hcos : 1 - Real.cos t ≤ t ^ 2 / 2 := by
    linarith [Real.one_sub_sq_div_two_le_cos (x := t)]
  have hcos2 : 1 - Real.cos t ≤ 2 := by linarith [Real.neg_one_le_cos t]
  simp only [cosineKernel, mul_one, ← div_eq_mul_inv]
  by_cases hs : t ^ 2 ≤ 1
  · calc
      (1 - Real.cos t) / t ^ 2 ≤ 1 / 2 := by
        apply (div_le_iff₀ ht2).2
        linarith
      _ ≤ 4 / (1 + t ^ 2) := by
        apply (le_div_iff₀ hd).2
        linarith
  · calc
      (1 - Real.cos t) / t ^ 2 ≤ 2 / t ^ 2 := div_le_div_of_nonneg_right hcos2 ht2.le
      _ ≤ 4 / (1 + t ^ 2) := by
        apply (div_le_div_iff₀ ht2 hd).2
        nlinarith

/-- The normalizing integral converges absolutely. -/
theorem integrable_cosineKernel_one : Integrable (cosineKernel 1) := by
  have hm : Measurable (cosineKernel 1) := by unfold cosineKernel; fun_prop
  apply (integrable_inv_one_add_sq.const_mul 4).mono' hm.aestronglyMeasurable
  exact Filter.Eventually.of_forall (fun t => by
    rw [Real.norm_eq_abs, abs_of_nonneg (cosineKernel_nonneg 1 t)]
    exact cosineKernel_one_le t)

/-- Positivity is certified on the nonempty interval `(pi/2, pi)`. -/
theorem fourierAbsConstant_pos : 0 < fourierAbsConstant := by
  apply (integral_pos_iff_support_of_nonneg (cosineKernel_nonneg 1)
    integrable_cosineKernel_one).2
  have hsubset : Ioo (Real.pi / 2) Real.pi ⊆ Function.support (cosineKernel 1) := by
    intro t ht
    have htpos : 0 < t := by linarith [ht.1, Real.pi_pos]
    have hc : Real.cos t ≤ 0 := Real.cos_nonpos_of_pi_div_two_le_of_le ht.1.le (by
      linarith [ht.2, Real.pi_pos])
    have hk : 0 < cosineKernel 1 t := by
      unfold cosineKernel
      rw [mul_one]
      exact div_pos (by linarith) (sq_pos_of_pos htpos)
    exact hk.ne'
  have hvol : 0 < volume (Ioo (Real.pi / 2) Real.pi) := by
    rw [Real.volume_Ioo]
    exact ENNReal.ofReal_pos.mpr (by linarith [Real.pi_pos])
  exact hvol.trans_le (measure_mono hsubset)

/-- Pointwise scaling, including both zero cases. -/
theorem cosineKernel_scale (z t : ℝ) :
    cosineKernel z t = z ^ 2 * cosineKernel 1 (z * t) := by
  by_cases hz : z = 0
  · simp [cosineKernel, hz]
  by_cases ht : t = 0
  · simp [cosineKernel, ht]
  unfold cosineKernel
  rw [mul_one, mul_comm z t]
  field_simp

/-- Every scaled kernel is integrable. -/
theorem integrable_cosineKernel (z : ℝ) : Integrable (cosineKernel z) := by
  by_cases hz : z = 0
  · subst z
    have he : cosineKernel 0 = fun _ : ℝ => (0 : ℝ) := by
      funext t
      simp [cosineKernel]
    rw [he]
    exact integrable_zero ℝ ℝ volume
  have hc : Integrable (fun t : ℝ => cosineKernel 1 (z * t)) :=
    (integrable_comp_mul_left_iff (cosineKernel 1) hz).2 integrable_cosineKernel_one
  have he : cosineKernel z = fun t => z ^ 2 * cosineKernel 1 (z * t) := by
    funext t
    exact cosineKernel_scale z t
  rw [he]
  exact hc.const_mul (z ^ 2)

/-- The exact integral formula follows from Haar scaling; no evaluation of
an improper sinc integral is required. -/
theorem integral_cosineKernel (z : ℝ) :
    (∫ t : ℝ, cosineKernel z t) = |z| * fourierAbsConstant := by
  by_cases hz : z = 0
  · simp [hz, cosineKernel]
  have he : cosineKernel z = fun t => z ^ 2 * cosineKernel 1 (z * t) := by
    funext t
    exact cosineKernel_scale z t
  rw [he, integral_const_mul, Measure.integral_comp_mul_left]
  simp only [smul_eq_mul, abs_inv]
  change z ^ 2 * (|z|⁻¹ * fourierAbsConstant) = |z| * fourierAbsConstant
  rw [← sq_abs z]
  field_simp [abs_ne_zero.mpr hz]

/-- Actual absolute-value representation with a proved positive denominator. -/
theorem abs_eq_cosine_integral (z : ℝ) :
    |z| = (∫ t : ℝ, cosineKernel z t) / fourierAbsConstant := by
  rw [integral_cosineKernel]
  exact (mul_div_cancel_right₀ _ fourierAbsConstant_pos.ne').symm

/-- The affine term disappears from every parity coefficient of degree at
least two; the remaining integral is the positive Fourier representation. -/
theorem relu_eq_cosine_integral (z : ℝ) :
    max z 0 = z / 2 + (∫ t : ℝ, cosineKernel z t) / (2 * fourierAbsConstant) := by
  have hrelu : max z 0 = (z + |z|) / 2 := by
    by_cases hz : 0 ≤ z
    · rw [max_eq_left hz, abs_of_nonneg hz]
      ring
    · rw [max_eq_right (le_of_not_ge hz), abs_of_nonpos (le_of_not_ge hz)]
      ring
  rw [hrelu, integral_cosineKernel]
  field_simp [fourierAbsConstant_pos.ne']

section FiniteCoefficients

open scoped BigOperators

variable {ι : Type*} [Fintype ι]

/-- The constant cancellation makes the finite cosine quotient absolutely
integrable, including at the apparent singularity at zero. -/
theorem integrable_weighted_cosine (c v : ι → ℝ) (hc : ∑ i, c i = 0) :
    Integrable (fun t : ℝ => (∑ i, c i * Real.cos (t * v i)) / t ^ 2) := by
  have hi : Integrable (fun t : ℝ => ∑ i, c i * cosineKernel (v i) t) :=
    integrable_finsetSum Finset.univ (fun i _ =>
      (integrable_cosineKernel (v i)).const_mul (c i))
  have he (t : ℝ) : (∑ i, c i * Real.cos (t * v i)) / t ^ 2 =
      -(∑ i, c i * cosineKernel (v i) t) := by
    simp only [cosineKernel, ← mul_div_assoc, ← Finset.sum_div, mul_sub, mul_one,
      Finset.sum_sub_distrib, hc, zero_sub, neg_div, neg_neg]
  simp_rw [he]
  exact hi.neg

/-- The exact finite Fourier identity before evaluating the Boolean cosine
product. The two orthogonality hypotheses express that a degree-at-least-two
Walsh character kills the constant and affine parts of a neuron. -/
theorem weighted_relu_cosine_integral (c v : ι → ℝ)
    (hc : ∑ i, c i = 0) (hlinear : ∑ i, c i * v i = 0) :
    (∑ i, c i * max (v i) 0) =
      -(∫ t : ℝ, (∑ i, c i * Real.cos (t * v i)) / t ^ 2) /
        (2 * fourierAbsConstant) := by
  have hpoint (t : ℝ) : (∑ i, c i * cosineKernel (v i) t) =
      -((∑ i, c i * Real.cos (t * v i)) / t ^ 2) := by
    simp only [cosineKernel, ← mul_div_assoc, ← Finset.sum_div, mul_sub, mul_one,
      Finset.sum_sub_distrib, hc, zero_sub, neg_div]
  have hint : (∑ i, c i * (∫ t : ℝ, cosineKernel (v i) t)) =
      -(∫ t : ℝ, (∑ i, c i * Real.cos (t * v i)) / t ^ 2) := by
    calc
      _ = ∫ t : ℝ, ∑ i, c i * cosineKernel (v i) t := by
        rw [integral_finsetSum]
        · simp_rw [integral_const_mul]
        · intro i _
          exact (integrable_cosineKernel (v i)).const_mul (c i)
      _ = ∫ t : ℝ, -((∑ i, c i * Real.cos (t * v i)) / t ^ 2) := by
        congr 1
        funext t
        exact hpoint t
      _ = _ := integral_neg _
  simp_rw [relu_eq_cosine_integral, mul_add, ← mul_div_assoc]
  rw [Finset.sum_add_distrib, ← Finset.sum_div, ← Finset.sum_div, hlinear, zero_div,
    zero_add, hint]

end FiniteCoefficients

end NeuralGeneralization.OnlineLowerRelu
