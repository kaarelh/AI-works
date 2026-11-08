import NeuralGeneralization.OnlineLowerTanhPeriodicHarmonic
import Mathlib.Analysis.Calculus.SmoothSeries
import Mathlib.Analysis.SpecialFunctions.Trigonometric.DerivHyp

/-! # The actual convergent Fourier series of the tanh periodic response -/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.OnlineLowerTanh

def periodicFourierResponse (a b : ℝ) : ℝ :=
  ∑' j : ℕ, periodicCoefficient a j * Real.sin ((2*(j : ℝ)+1)*periodicFrequency a*b)

def periodicFourierDerivative (a b : ℝ) : ℝ :=
  ∑' j : ℕ, periodicCoefficient a j * ((2*(j : ℝ)+1)*periodicFrequency a) *
    Real.cos ((2*(j : ℝ)+1)*periodicFrequency a*b)

def periodicFourierSecond (a b : ℝ) : ℝ :=
  ∑' j : ℕ, -(periodicCoefficient a j * ((2*(j : ℝ)+1)*periodicFrequency a)^2) *
    Real.sin ((2*(j : ℝ)+1)*periodicFrequency a*b)

def periodicFourierMaximum (a : ℝ) : ℝ := periodicFourierResponse a a

theorem periodicDecay_pos {a : ℝ} (ha : 0 < a) : 0 < periodicDecay a := by
  unfold periodicDecay
  positivity

theorem periodicFrequency_pos {a : ℝ} (ha : 0 < a) : 0 < periodicFrequency a := by
  unfold periodicFrequency
  positivity

theorem periodicCoefficient_pos {a : ℝ} (ha : 0 < a) (j : ℕ) :
    0 < periodicCoefficient a j := by
  unfold periodicCoefficient
  apply div_pos (div_pos Real.pi_pos ha)
  apply Real.sinh_pos_iff.mpr
  exact mul_pos (by positivity) (periodicDecay_pos ha)

/-- Exact hyperbolic comparison giving geometric decay of the actual
Fourier coefficients. -/
theorem periodicCoefficient_le_geometric {a : ℝ} (ha : 0 < a) (j : ℕ) :
    periodicCoefficient a j ≤ periodicCoefficient a 0 * periodicRatio a ^ j := by
  let α := periodicDecay a
  have hα : 0 < α := periodicDecay_pos ha
  have hs : 0 < Real.sinh α := Real.sinh_pos_iff.mpr hα
  have hy : 0 ≤ 2*(j : ℝ)*α := by positivity
  have hsy : 0 ≤ Real.sinh (2*(j : ℝ)*α) := Real.sinh_nonneg_iff.mpr hy
  have hcomp : Real.exp (2*(j : ℝ)*α) * Real.sinh α ≤ Real.sinh ((2*(j : ℝ)+1)*α) := by
    rw [show (2*(j : ℝ)+1)*α = α + 2*(j : ℝ)*α by ring, Real.sinh_add]
    have hexp := Real.sinh_add_cosh (2*(j : ℝ)*α)
    have hdiff := Real.cosh_sub_sinh α
    have hpos := mul_nonneg hsy (Real.exp_pos (-α)).le
    nlinarith
  have hpos : 0 < Real.sinh ((2*(j : ℝ)+1)*α) :=
    Real.sinh_pos_iff.mpr (mul_pos (by positivity) hα)
  have hratio : periodicRatio a ^ j = (Real.exp (2*(j : ℝ)*α))⁻¹ := by
    unfold periodicRatio
    rw [← Real.exp_nat_mul, ← Real.exp_neg]
    congr 1
    dsimp [α]
    ring
  rw [hratio]
  unfold periodicCoefficient
  simp only [Nat.cast_zero, mul_zero, zero_add, one_mul]
  change (Real.pi/a) / Real.sinh ((2*(j : ℝ)+1)*α) ≤
    (Real.pi/a) / Real.sinh α * (Real.exp (2*(j : ℝ)*α))⁻¹
  calc
    _ ≤ (Real.pi/a) / (Real.sinh α * Real.exp (2*(j : ℝ)*α)) :=
      div_le_div_of_nonneg_left (div_pos Real.pi_pos ha).le
        (mul_pos hs (Real.exp_pos _)) (by simpa only [mul_comm] using hcomp)
    _ = _ := by rw [div_mul_eq_div_mul_one_div, one_div]

theorem periodicRatio_mem {a : ℝ} (ha : 0 < a) : 0 < periodicRatio a ∧ periodicRatio a < 1 := by
  refine ⟨Real.exp_pos _, ?_⟩
  apply Real.exp_lt_one_iff.mpr
  have := periodicDecay_pos ha
  linarith

theorem periodicCoefficient_square_summable {a : ℝ} (ha : 0 < a) :
    Summable (fun j : ℕ => periodicCoefficient a j * (2*(j : ℝ)+1)^2) := by
  have hq : |periodicRatio a| < 1 := by
    rw [abs_of_pos (periodicRatio_mem ha).1]
    exact (periodicRatio_mem ha).2
  have h0 := summable_geometric_of_abs_lt_one hq
  have h1 := summable_pow_mul_geometric_of_norm_lt_one 1 (r := periodicRatio a) hq
  have h2 := summable_pow_mul_geometric_of_norm_lt_one 2 (r := periodicRatio a) hq
  have hp : Summable (fun j : ℕ => (2*(j : ℝ)+1)^2 * periodicRatio a ^ j) := by
    have h := ((h2.mul_left (4 : ℝ)).add (h1.mul_left (4 : ℝ))).add h0
    apply h.congr
    intro j
    ring
  apply (hp.mul_left (periodicCoefficient a 0)).of_nonneg_of_le
    (fun j => mul_nonneg (periodicCoefficient_pos ha j).le (sq_nonneg _))
  intro j
  have h := mul_le_mul_of_nonneg_right (periodicCoefficient_le_geometric ha j) (sq_nonneg (2*(j : ℝ)+1))
  nlinarith

theorem periodicCoefficient_linear_summable {a : ℝ} (ha : 0 < a) :
    Summable (fun j : ℕ => periodicCoefficient a j * (2*(j : ℝ)+1)) := by
  apply (periodicCoefficient_square_summable ha).of_nonneg_of_le
    (fun j => mul_nonneg (periodicCoefficient_pos ha j).le (by positivity))
  intro j
  have h : (2*(j : ℝ)+1) ≤ (2*(j : ℝ)+1)^2 := by nlinarith [Nat.cast_nonneg (α := ℝ) j]
  exact mul_le_mul_of_nonneg_left h (periodicCoefficient_pos ha j).le

theorem periodicCoefficient_summable {a : ℝ} (ha : 0 < a) : Summable (periodicCoefficient a) := by
  apply (periodicCoefficient_linear_summable ha).of_nonneg_of_le
    (fun j => (periodicCoefficient_pos ha j).le)
  intro j
  have h := mul_nonneg (periodicCoefficient_pos ha j).le (Nat.cast_nonneg (α := ℝ) j)
  nlinarith

theorem periodic_sine_summable {a : ℝ} (ha : 0 < a) (b : ℝ) :
    Summable (fun j : ℕ => periodicCoefficient a j *
      Real.sin ((2*(j : ℝ)+1)*periodicFrequency a*b)) := by
  apply (periodicCoefficient_summable ha).of_norm_bounded
  intro j
  rw [Real.norm_eq_abs, abs_mul, abs_of_pos (periodicCoefficient_pos ha j)]
  simpa only [mul_one] using mul_le_mul_of_nonneg_left (Real.abs_sin_le_one _) (periodicCoefficient_pos ha j).le

theorem periodic_derivative_summable {a : ℝ} (ha : 0 < a) (b : ℝ) :
    Summable (fun j : ℕ => periodicCoefficient a j * ((2*(j : ℝ)+1)*periodicFrequency a) *
      Real.cos ((2*(j : ℝ)+1)*periodicFrequency a*b)) := by
  apply ((periodicCoefficient_linear_summable ha).mul_right (periodicFrequency a)).of_norm_bounded
  intro j
  rw [Real.norm_eq_abs, abs_mul, abs_of_nonneg (by positivity [periodicCoefficient_pos ha j, periodicFrequency_pos ha])]
  have h := mul_le_mul_of_nonneg_left (Real.abs_cos_le_one ((2*(j : ℝ)+1)*periodicFrequency a*b))
    (show 0 ≤ periodicCoefficient a j*((2*(j : ℝ)+1)*periodicFrequency a) by positivity [periodicCoefficient_pos ha j, periodicFrequency_pos ha])
  simpa only [mul_one, mul_assoc] using h

theorem periodicFourierResponse_hasDerivAt {a : ℝ} (ha : 0 < a) (b : ℝ) :
    HasDerivAt (periodicFourierResponse a) (periodicFourierDerivative a b) b := by
  unfold periodicFourierResponse periodicFourierDerivative
  apply hasDerivAt_tsum (g := fun j y => periodicCoefficient a j * Real.sin ((2*(j : ℝ)+1)*periodicFrequency a*y))
    (g' := fun j y => periodicCoefficient a j * ((2*(j : ℝ)+1)*periodicFrequency a) * Real.cos ((2*(j : ℝ)+1)*periodicFrequency a*y))
    ((periodicCoefficient_linear_summable ha).mul_right (periodicFrequency a))
    _ _ (periodic_sine_summable ha 0) b
  · intro j y
    convert ((Real.hasDerivAt_sin (((2*(j : ℝ)+1)*periodicFrequency a)*y)).comp y
      ((hasDerivAt_id y).const_mul ((2*(j : ℝ)+1)*periodicFrequency a))).const_mul (periodicCoefficient a j) using 1 <;> (try funext z) <;> (try dsimp) <;> first | rfl | ring
  · intro j y
    rw [Real.norm_eq_abs, abs_mul, abs_of_nonneg (by positivity [periodicCoefficient_pos ha j, periodicFrequency_pos ha])]
    have h := mul_le_mul_of_nonneg_left (Real.abs_cos_le_one ((2*(j : ℝ)+1)*periodicFrequency a*y))
      (show 0 ≤ periodicCoefficient a j*((2*(j : ℝ)+1)*periodicFrequency a) by positivity [periodicCoefficient_pos ha j, periodicFrequency_pos ha])
    simpa only [mul_one, mul_assoc] using h

theorem periodicFourierDerivative_hasDerivAt {a : ℝ} (ha : 0 < a) (b : ℝ) :
    HasDerivAt (periodicFourierDerivative a) (periodicFourierSecond a b) b := by
  unfold periodicFourierDerivative periodicFourierSecond
  apply hasDerivAt_tsum (g := fun j y => periodicCoefficient a j * ((2*(j : ℝ)+1)*periodicFrequency a) * Real.cos ((2*(j : ℝ)+1)*periodicFrequency a*y))
    (g' := fun j y => -(periodicCoefficient a j * ((2*(j : ℝ)+1)*periodicFrequency a)^2) * Real.sin ((2*(j : ℝ)+1)*periodicFrequency a*y))
    ((periodicCoefficient_square_summable ha).mul_right (periodicFrequency a ^ 2))
    _ _ (periodic_derivative_summable ha 0) b
  · intro j y
    convert ((Real.hasDerivAt_cos (((2*(j : ℝ)+1)*periodicFrequency a)*y)).comp y
      ((hasDerivAt_id y).const_mul ((2*(j : ℝ)+1)*periodicFrequency a))).const_mul
        (periodicCoefficient a j * ((2*(j : ℝ)+1)*periodicFrequency a)) using 1 <;> (try funext z) <;> (try dsimp) <;> first | rfl | ring
  · intro j y
    rw [Real.norm_eq_abs, abs_mul, abs_neg, abs_of_nonneg (mul_nonneg (periodicCoefficient_pos ha j).le (sq_nonneg _))]
    have h := mul_le_mul_of_nonneg_left (Real.abs_sin_le_one ((2*(j : ℝ)+1)*periodicFrequency a*y))
      (mul_nonneg (periodicCoefficient_pos ha j).le (sq_nonneg ((2*(j : ℝ)+1)*periodicFrequency a)))
    simpa only [mul_one, mul_pow, mul_assoc] using h

end NeuralGeneralization.OnlineLowerTanh
