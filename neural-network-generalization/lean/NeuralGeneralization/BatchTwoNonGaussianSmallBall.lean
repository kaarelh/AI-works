import NeuralGeneralization.BatchTwoNonGaussianSmallBallKernel

/-! A polynomial threshold for normalized-sum small balls. Large clone groups
have a logarithmic cylinder cost, obtained directly from relative Lindeberg. -/

noncomputable section
open MeasureTheory Set
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoNonGaussian

theorem normalized_softBall_upper (ν : CoordinateLaw) (N : ℕ)
    {G ρ : ℝ} (hG : 0 ≤ G) (hρ : 0 ≤ ρ) (hρhalf : ρ ≤ 1 / 2) :
    (∫ x, softBall G (normalizedSum N x) ∂Measure.pi (fun _ : Fin N => ν.law)) ≤
      (Measure.pi fun _ : Fin N => ν.law).real {x | |normalizedSum N x| ≤ ρ} +
        Real.exp (-G * ρ ^ 2 / 4) := by
  let μ := Measure.pi fun _ : Fin N => ν.law
  let E : Set (Fin N → ℝ) := {x | |normalizedSum N x| ≤ ρ}
  have hs : MeasurableSet E := by
    apply measurableSet_le _ measurable_const
    unfold normalizedSum
    fun_prop
  have hf : Integrable (fun x => softBall G (normalizedSum N x)) μ := by
    apply Integrable.of_bound (by unfold softBall normalizedSum; fun_prop) 1
    exact ae_of_all _ (fun x => by
      rw [Real.norm_eq_abs, abs_of_pos (show 0 < softBall G (normalizedSum N x) from Real.exp_pos _)]
      exact softBall_le_one hG _)
  have hi : Integrable (E.indicator (fun _ => (1 : ℝ))) μ := (integrable_const 1).indicator hs
  have hpoint (x : Fin N → ℝ) : softBall G (normalizedSum N x) ≤
      E.indicator (fun _ => (1 : ℝ)) x + Real.exp (-G * ρ ^ 2 / 4) := by
    by_cases hx : x ∈ E
    · rw [indicator_of_mem hx]
      exact (softBall_le_one hG _).trans (le_add_of_nonneg_right (Real.exp_pos _).le)
    · rw [indicator_of_notMem hx, zero_add]
      exact softBall_tail hG hρ hρhalf (le_of_not_ge hx)
  have h := integral_mono hf (hi.add (integrable_const _)) hpoint
  simp only [Pi.add_apply] at h
  rw [integral_add hi (integrable_const _), integral_indicator hs] at h
  simpa only [integral_const, probReal_univ, smul_eq_mul, one_mul, mul_one,
    Measure.real, Measure.restrict_apply_univ, measure_univ, ENNReal.toReal_one] using h

def smallBallTilt (ρ : ℝ) : ℝ := 4096 / ρ ^ 4

theorem smallBallTilt_pos {ρ : ℝ} (hρ : 0 < ρ) : 0 < smallBallTilt ρ := by
  unfold smallBallTilt
  positivity

theorem smallBall_gaussian_lower {ρ : ℝ} (hρ : 0 < ρ) (hρone : ρ ≤ 1) :
    ρ ^ 2 / 384 ≤ Real.exp (-1) / Real.sqrt (1 + 2 * smallBallTilt ρ) := by
  have hG := smallBallTilt_pos hρ
  have hs : 0 < Real.sqrt (1 + 2 * smallBallTilt ρ) := Real.sqrt_pos.mpr (by linarith)
  have hsq := Real.sq_sqrt (show 0 ≤ 1 + 2 * smallBallTilt ρ by positivity)
  have hρ4 : ρ ^ 4 ≤ 1 := pow_le_one₀ hρ.le hρone
  have hGρ : smallBallTilt ρ * ρ ^ 4 = 4096 := by unfold smallBallTilt; field_simp
  have hprod : (ρ ^ 2 * Real.sqrt (1 + 2 * smallBallTilt ρ)) ^ 2 = ρ ^ 4 + 8192 := by
    rw [mul_pow, hsq]
    nlinarith [hGρ]
  have hsbound : ρ ^ 2 * Real.sqrt (1 + 2 * smallBallTilt ρ) ≤ 128 := by
    nlinarith [sq_nonneg (ρ ^ 2 * Real.sqrt (1 + 2 * smallBallTilt ρ) - 128)]
  have he : (1 / 3 : ℝ) ≤ Real.exp (-1) := by
    rw [Real.exp_neg]
    simpa only [one_div] using one_div_le_one_div_of_le (Real.exp_pos 1) Real.exp_one_lt_three.le
  apply (le_div_iff₀ hs).mpr
  nlinarith

theorem smallBall_kernel_tail {ρ : ℝ} (hρ : 0 < ρ) :
    Real.exp (-smallBallTilt ρ * ρ ^ 2 / 4) ≤ ρ ^ 2 / 1024 := by
  let t : ℝ := smallBallTilt ρ * ρ ^ 2 / 4
  have ht : 0 < t := by dsimp [t]; exact div_pos (mul_pos (smallBallTilt_pos hρ) (sq_pos_of_pos hρ)) (by norm_num)
  have hte : t ≤ Real.exp t := by linarith [Real.add_one_le_exp t]
  have hi := one_div_le_one_div_of_le ht hte
  have heq : 1 / t = ρ ^ 2 / 1024 := by dsimp [t, smallBallTilt]; field_simp; ring
  have hexp : -smallBallTilt ρ * ρ ^ 2 / 4 = -t := by dsimp [t]; ring
  rw [hexp, Real.exp_neg]
  simpa only [one_div, heq] using hi

/-- Every sufficiently large equal-weight normalized sum has a small-ball
probability polynomial in the radius. The required group size is explicit and
polynomial in the inverse radius and the fixed law's cubic exponential moment. -/
theorem normalized_sum_small_ball (ν : CoordinateLaw) (N : ℕ) (hN : 0 < N)
    {ρ : ℝ} (hρ : 0 < ρ) (hρhalf : ρ ≤ 1 / 2)
    (hsize : 4 * (smallBallTilt ρ) ^ 2 ≤ (N : ℝ))
    (herr : (replacementConstant ν standardGaussian * lindebergPolynomial (smallBallTilt ρ)) ^ 2 ≤ (N : ℝ)) :
    ρ ^ 2 / 1024 ≤
      (Measure.pi fun _ : Fin N => ν.law).real {x | |normalizedSum N x| ≤ ρ} := by
  have hNr : 0 < (N : ℝ) := by exact_mod_cast hN
  have hs : 0 < Real.sqrt N := Real.sqrt_pos.mpr hNr
  have hsq := Real.sq_sqrt hNr.le
  have herr' : replacementConstant ν standardGaussian * lindebergPolynomial (smallBallTilt ρ) /
      Real.sqrt N ≤ 1 := by
    apply (div_le_one hs).mpr
    nlinarith
  have hlo := normalized_softBall_lower ν N hN (smallBallTilt_pos hρ).le hsize herr'
  have hhi := normalized_softBall_upper ν N (smallBallTilt_pos hρ).le hρ.le hρhalf
  have hgauss := smallBall_gaussian_lower hρ (by linarith : ρ ≤ 1)
  have htail := smallBall_kernel_tail hρ
  nlinarith [sq_nonneg ρ]

end NeuralGeneralization.BatchTwoNonGaussian
