import NeuralGeneralization.GaussianPolar
import NeuralGeneralization.TanhSaturation
import Mathlib.Analysis.SpecialFunctions.Trigonometric.Inverse

/-! # The exact Gaussian sign covariance from polar integration -/
noncomputable section
open MeasureTheory ProbabilityTheory Set

namespace NeuralGeneralization.GaussianSignAngle

def angularSign (α θ : ℝ) : ℝ := Real.sign (Real.sin θ) * Real.sign (Real.sin (θ - α))

theorem sign_pos_mul {r : ℝ} (hr : 0 < r) (x : ℝ) :
    Real.sign (r * x) = Real.sign x := by
  rcases lt_trichotomy x 0 with hx | hx | hx
  · rw [Real.sign_of_neg hx, Real.sign_of_neg (mul_neg_of_pos_of_neg hr hx)]
  · simp [hx]
  · rw [Real.sign_of_pos hx, Real.sign_of_pos (mul_pos hr hx)]

theorem angularSign_bound (α θ : ℝ) : |angularSign α θ| ≤ 1 := by
  rw [angularSign, abs_mul]
  exact (mul_le_mul (TanhSaturation.abs_sign_le_one _) (TanhSaturation.abs_sign_le_one _)
    (abs_nonneg _) (by norm_num)).trans_eq (one_mul _)

@[fun_prop] theorem measurable_angularSign (α : ℝ) : Measurable (angularSign α) := by
  unfold angularSign
  exact (TanhSaturation.measurable_sign.comp Real.continuous_sin.measurable).mul
    (TanhSaturation.measurable_sign.comp
      (Real.continuous_sin.measurable.comp (measurable_id.sub_const α)))

theorem angularSign_intervalIntegrable (α a b : ℝ) :
    IntervalIntegrable (angularSign α) volume a b := by
  constructor <;>
    apply (integrable_const (1 : ℝ)).mono' (measurable_angularSign α).aestronglyMeasurable <;>
    exact ae_of_all _ (fun θ => by simpa only [Real.norm_eq_abs] using angularSign_bound α θ)

theorem angularSign_first {α θ : ℝ} (_hα : 0 ≤ α) (hαπ : α ≤ Real.pi)
    (hθ : θ ∈ Ioo (-Real.pi) (α - Real.pi)) : angularSign α θ = -1 := by
  have hx : Real.sin θ < 0 := Real.sin_neg_of_neg_of_neg_pi_lt (by linarith [hθ.2]) hθ.1
  have hy : 0 < Real.sin (θ - α) := by
    rw [← Real.sin_add_two_pi (θ - α)]
    exact Real.sin_pos_of_pos_of_lt_pi (by linarith [hθ.1]) (by linarith [hθ.2])
  simp only [angularSign, Real.sign_of_neg hx, Real.sign_of_pos hy, mul_one]

theorem angularSign_second {α θ : ℝ} (hα : 0 ≤ α) (_hαπ : α ≤ Real.pi)
    (hθ : θ ∈ Ioo (α - Real.pi) 0) : angularSign α θ = 1 := by
  have hx : Real.sin θ < 0 := Real.sin_neg_of_neg_of_neg_pi_lt hθ.2 (by linarith [hθ.1])
  have hy : Real.sin (θ - α) < 0 :=
    Real.sin_neg_of_neg_of_neg_pi_lt (by linarith [hθ.2]) (by linarith [hθ.1])
  simp only [angularSign, Real.sign_of_neg hx, Real.sign_of_neg hy, neg_mul_neg, one_mul]

theorem angularSign_third {α θ : ℝ} (_hα : 0 ≤ α) (hαπ : α ≤ Real.pi)
    (hθ : θ ∈ Ioo 0 α) : angularSign α θ = -1 := by
  have hx : 0 < Real.sin θ := Real.sin_pos_of_pos_of_lt_pi hθ.1 (by linarith [hθ.2])
  have hy : Real.sin (θ - α) < 0 :=
    Real.sin_neg_of_neg_of_neg_pi_lt (by linarith [hθ.2]) (by linarith [hθ.1])
  simp only [angularSign, Real.sign_of_pos hx, Real.sign_of_neg hy, one_mul]

theorem angularSign_fourth {α θ : ℝ} (hα : 0 ≤ α) (_hαπ : α ≤ Real.pi)
    (hθ : θ ∈ Ioo α Real.pi) : angularSign α θ = 1 := by
  have hx : 0 < Real.sin θ := Real.sin_pos_of_pos_of_lt_pi (by linarith [hθ.1]) hθ.2
  have hy : 0 < Real.sin (θ - α) :=
    Real.sin_pos_of_pos_of_lt_pi (by linarith [hθ.1]) (by linarith [hθ.2])
  simp only [angularSign, Real.sign_of_pos hx, Real.sign_of_pos hy, one_mul]

theorem angularSign_integral {α : ℝ} (hα : 0 ≤ α) (hαπ : α ≤ Real.pi) :
    ∫ θ in Ioo (-Real.pi) Real.pi, angularSign α θ = 2 * Real.pi - 4 * α := by
  have h1 : ∫ θ in (-Real.pi)..(α - Real.pi), angularSign α θ = -α := by
    rw [intervalIntegral.integral_congr_Ioo_of_le (by linarith : -Real.pi ≤ α - Real.pi)
      (fun θ hθ => angularSign_first hα hαπ hθ), intervalIntegral.integral_const]
    simp only [smul_eq_mul]
    ring
  have h2 : ∫ θ in (α - Real.pi)..0, angularSign α θ = Real.pi - α := by
    rw [intervalIntegral.integral_congr_Ioo_of_le (by linarith : α - Real.pi ≤ 0)
      (fun θ hθ => angularSign_second hα hαπ hθ), intervalIntegral.integral_const]
    simp only [smul_eq_mul]
    ring
  have h3 : ∫ θ in (0 : ℝ)..α, angularSign α θ = -α := by
    rw [intervalIntegral.integral_congr_Ioo_of_le hα
      (fun θ hθ => angularSign_third hα hαπ hθ), intervalIntegral.integral_const]
    simp only [smul_eq_mul]
    ring
  have h4 : ∫ θ in α..Real.pi, angularSign α θ = Real.pi - α := by
    rw [intervalIntegral.integral_congr_Ioo_of_le hαπ
      (fun θ hθ => angularSign_fourth hα hαπ hθ), intervalIntegral.integral_const]
    simp only [smul_eq_mul, mul_one]
  rw [← integral_Ioc_eq_integral_Ioo,
    ← intervalIntegral.integral_of_le (neg_le_self Real.pi_nonneg)]
  have ha := intervalIntegral.integral_add_adjacent_intervals
    (angularSign_intervalIntegrable α (-Real.pi) (α - Real.pi))
    (angularSign_intervalIntegrable α (α - Real.pi) 0)
  have hb := intervalIntegral.integral_add_adjacent_intervals
    (angularSign_intervalIntegrable α (-Real.pi) 0)
    (angularSign_intervalIntegrable α 0 α)
  have hc := intervalIntegral.integral_add_adjacent_intervals
    (angularSign_intervalIntegrable α (-Real.pi) α)
    (angularSign_intervalIntegrable α α Real.pi)
  linarith

/-- Exact sign covariance of a pair with angle `α`, including the perfectly
correlated and anticorrelated boundary cases. -/
theorem gaussian_sign_angle {α : ℝ} (hα : 0 ≤ α) (hαπ : α ≤ Real.pi) :
    ∫ p : ℝ × ℝ, Real.sign p.2 *
      Real.sign (Real.cos α * p.2 - Real.sin α * p.1) ∂GaussianPolar.standardPair =
      1 - 2 * α / Real.pi := by
  rw [GaussianPolar.homogeneous_integral _ (angularSign α) (by
    intro r hr θ hθ
    have heq : Real.cos α * (r * Real.sin θ) - Real.sin α * (r * Real.cos θ) =
        r * Real.sin (θ - α) := by rw [Real.sin_sub]; ring
    rw [heq, sign_pos_mul hr, sign_pos_mul hr]
    rfl), angularSign_integral hα hαπ]
  field_simp
  ring

theorem gaussian_sign_arcsin {ρ : ℝ} (hρlo : -1 ≤ ρ) (hρhi : ρ ≤ 1) :
    ∫ p : ℝ × ℝ, Real.sign p.2 *
      Real.sign (ρ * p.2 - Real.sqrt (1 - ρ ^ 2) * p.1) ∂GaussianPolar.standardPair =
      (2 / Real.pi) * Real.arcsin ρ := by
  have h := gaussian_sign_angle (Real.arccos_nonneg ρ) (Real.arccos_le_pi ρ)
  rw [Real.cos_arccos hρlo hρhi, Real.sin_arccos] at h
  rw [h, Real.arcsin_eq_pi_div_two_sub_arccos]
  field_simp

end NeuralGeneralization.GaussianSignAngle
